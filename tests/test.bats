#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  export GITHUB_REPO=vanEssenMax/ddev-lefthook

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  # The add-on manages git hooks, so the test project must be a git checkout.
  git init -q .
  # Keep the project as light as possible: the add-on is host-side only, so
  # tests run the host command directly and never need a db or mutagen. Only
  # the install tests boot containers at all, to prove the post-start wiring.
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --project-type=php --omit-containers=db,ddev-ssh-agent --performance-mode=none
  assert_success
}

health_checks() {
  # Add-on files landed with the ddev-generated marker.
  assert_file_exist .ddev/commands/host/lefthook
  assert_file_exist .ddev/config.lefthook.yaml
  run grep -q '#ddev-generated' .ddev/commands/host/lefthook
  assert_success
  run grep -q '#ddev-generated' .ddev/config.lefthook.yaml
  assert_success
  # The post-start hook ran "ddev lefthook": it generated the example
  # config and wrote lefthook's always-on stub into .git/hooks.
  assert_file_exist lefthook.yml
  assert_file_exist .git/hooks/prepare-commit-msg
  run grep -q lefthook .git/hooks/prepare-commit-msg
  assert_success
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory wires hooks on ddev start" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev start -y
  assert_success
  health_checks
}

@test "syncs hooks from an existing project config" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  cat > .lefthook.yml <<'EOF'
pre-commit:
  jobs:
    - name: noop
      run: "true"
EOF
  run ddev lefthook
  assert_success
  # The configured pre-commit hook got a stub.
  assert_file_exist .git/hooks/pre-commit
  run grep -q lefthook .git/hooks/pre-commit
  assert_success
  # The existing config is respected: no example file generated next to it.
  assert_file_not_exist lefthook.yml
  # With arguments the command is a passthrough to the lefthook binary.
  run ddev lefthook version
  assert_success
}

@test "installer none never fails" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev dotenv set .ddev/.env.lefthook --lefthook-installer none
  assert_success
  run ddev lefthook
  assert_success
}

@test "remove deletes the add-on files and unwires the hooks" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev lefthook
  assert_success
  assert_file_exist .git/hooks/prepare-commit-msg
  run ddev add-on remove lefthook
  assert_success
  assert_file_not_exist .ddev/commands/host/lefthook
  assert_file_not_exist .ddev/config.lefthook.yaml
  # Hooks are unwired, but the user's config is preserved.
  assert_file_not_exist .git/hooks/prepare-commit-msg
  assert_file_exist lefthook.yml
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev start -y
  assert_success
  health_checks
}
