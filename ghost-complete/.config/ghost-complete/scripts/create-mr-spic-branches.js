#!/usr/bin/env node
const { execFileSync } = require('node:child_process');

const mode = process.argv[2] === 'source' ? 'source' : 'target';

function runGit(args) {
  try {
    return execFileSync('git', args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return '';
  }
}

function parseVersion(value) {
  const match = String(value ?? '').match(/(\d+)\.(\d+)\.(\d+)/);
  return match ? match.slice(1).map(Number) : [0, 0, 0];
}

function compareDesc(left, right) {
  for (let index = 0; index < 4; index += 1) {
    const diff = (right[index] ?? 0) - (left[index] ?? 0);
    if (diff !== 0) return diff;
  }
  return 0;
}

function greaterThan(left, right) {
  for (let index = 0; index < 3; index += 1) {
    if (left[index] > right[index]) return true;
    if (left[index] < right[index]) return false;
  }
  return false;
}

function lessThan(left, right) {
  for (let index = 0; index < 3; index += 1) {
    if (left[index] < right[index]) return true;
    if (left[index] > right[index]) return false;
  }
  return false;
}

const refs = runGit(['for-each-ref', '--format=%(refname:short)', 'refs/heads/', 'refs/remotes/origin/']);
const currentBranch = runGit(['branch', '--show-current']);
if (!refs || !currentBranch) process.exit(0);

const branches = [...new Set(refs.split('\n').map((branch) => branch.trim().replace(/^origin\//, '')).filter((branch) => branch && branch !== 'HEAD'))];
const mainBranches = [];
const releaseBranches = [];
const otherBranches = [];

for (const branch of branches) {
  if (branch === 'main' || branch === 'master') {
    mainBranches.push(branch);
  } else {
    const releaseMatch = branch.match(/^release-v(\d+\.\d+\.\d+)(?:_sprint(\d+)|regular_all)$/);
    if (releaseMatch) {
      releaseBranches.push({
        branch,
        version: [...parseVersion(releaseMatch[1]), Number(releaseMatch[2] ?? 0)],
      });
    } else {
      otherBranches.push(branch);
    }
  }
}

releaseBranches.sort((left, right) => compareDesc(left.version, right.version));
const versionHint = currentBranch.match(/(?:feat|feature|release|fix|dev|deploy)(?:-|_)?v(\d+\.\d+\.\d+)/i)?.[1];
const currentVersion = versionHint ? parseVersion(versionHint) : [];
const matchingRelease = versionHint ? releaseBranches.find((entry) => entry.branch.includes(versionHint)) : null;
const nextRelease = versionHint ? releaseBranches.find((entry) => greaterThan(entry.version, currentVersion)) : null;
const previousRelease = versionHint ? releaseBranches.find((entry) => lessThan(entry.version, currentVersion)) : null;

const suggestions = [];
const seen = new Set();
function pushBranch(branch) {
  if (!branch || seen.has(branch)) return;
  seen.add(branch);
  suggestions.push(branch);
}

if (/^(feat|feature|release|fix|dev|deploy)/i.test(currentBranch) && matchingRelease && currentBranch !== matchingRelease.branch) {
  pushBranch(matchingRelease.branch);
} else if (/^release/i.test(currentBranch) && nextRelease && mode === 'target') {
  pushBranch(nextRelease.branch);
} else if (/^release/i.test(currentBranch) && previousRelease && mode === 'source') {
  pushBranch(previousRelease.branch);
}

mainBranches.forEach(pushBranch);
releaseBranches.filter((entry) => entry.branch !== matchingRelease?.branch).forEach((entry) => pushBranch(entry.branch));
otherBranches.forEach(pushBranch);

if (suggestions.length > 0) {
  process.stdout.write(`${suggestions.join('\n')}\n`);
}
