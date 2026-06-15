#!/usr/bin/perl

use strict;
use warnings;

my $mode = ($ARGV[0] // '') eq 'source' ? 'source' : 'target';

sub run_command {
    my (@command) = @_;
    my $pid = open my $handle, '-|', @command;
    return wantarray ? ($? || 1, '') : '' unless defined $pid;

    local $/;
    my $output = <$handle> // '';
    close $handle;
    return wantarray ? ($?, $output) : $output;
}

sub parse_version {
    my ($value) = @_;
    return (0, 0, 0) unless defined $value && $value =~ /(\d+)\.(\d+)\.(\d+)/;
    return ($1 + 0, $2 + 0, $3 + 0);
}

sub compare_versions_desc {
    my ($left, $right) = @_;
    for my $index (0 .. 3) {
        my $left_value = $left->[$index] // 0;
        my $right_value = $right->[$index] // 0;
        return $right_value <=> $left_value if $left_value != $right_value;
    }
    return 0;
}

sub version_is_greater {
    my ($left, $right) = @_;
    for my $index (0 .. 2) {
        return 1 if $left->[$index] > $right->[$index];
        return 0 if $left->[$index] < $right->[$index];
    }
    return 0;
}

sub version_is_less {
    my ($left, $right) = @_;
    for my $index (0 .. 2) {
        return 1 if $left->[$index] < $right->[$index];
        return 0 if $left->[$index] > $right->[$index];
    }
    return 0;
}

my ($git_status, $git_output) = run_command(
    'git',
    'for-each-ref',
    '--format=%(refname:short)',
    'refs/heads/',
    'refs/remotes/origin/',
);
exit 0 if $git_status != 0;

my ($current_status, $current_output) = run_command('git', 'branch', '--show-current');
exit 0 if $current_status != 0;

my $current_branch = $current_output;
$current_branch =~ s/^\s+|\s+$//g;
exit 0 unless length $current_branch;

my %seen_input;
my @branches = grep { $_ ne 'HEAD' && !$seen_input{$_}++ } map {
    my $branch = $_;
    $branch =~ s/^\s+|\s+$//g;
    $branch =~ s/^origin\///;
    $branch;
} grep { /\S/ } split /\n/, $git_output;

my @main_branches;
my @release_branches;
my @other_branches;

for my $branch (@branches) {
    if ($branch eq 'main' || $branch eq 'master') {
        push @main_branches, $branch;
        next;
    }

    if ($branch =~ /^release-v(\d+\.\d+\.\d+)(?:_sprint(\d+)|regular_all)$/) {
        my @version = parse_version($1);
        my $sprint = defined $2 ? $2 + 0 : 0;
        push @release_branches, {
            branch => $branch,
            version => [@version, $sprint],
        };
        next;
    }

    push @other_branches, $branch;
}

@release_branches = sort {
    compare_versions_desc($a->{version}, $b->{version})
} @release_branches;

my $version_hint;
if ($current_branch =~ /(?:feat|feature|release|fix|dev|deploy)(?:-|_)?v(\d+\.\d+\.\d+)/i) {
    $version_hint = $1;
}

my @current_version = defined $version_hint ? parse_version($version_hint) : ();
my $matching_release = defined $version_hint
    ? (grep { index($_->{branch}, $version_hint) >= 0 } @release_branches)[0]
    : undef;
my $next_release = @current_version
    ? (grep { version_is_greater($_->{version}, \@current_version) } @release_branches)[0]
    : undef;
my $previous_release = @current_version
    ? (grep { version_is_less($_->{version}, \@current_version) } @release_branches)[0]
    : undef;

my @suggestions;
my %seen_output;
sub push_branch {
    my ($branch) = @_;
    return unless defined $branch && length $branch;
    return if $seen_output{$branch}++;
    push @suggestions, $branch;
}

if ($current_branch =~ /^(feat|feature|release|fix|dev|deploy)/i && defined $matching_release && $current_branch ne $matching_release->{branch}) {
    push_branch($matching_release->{branch});
} elsif ($current_branch =~ /^release/i && defined $next_release && $mode eq 'target') {
    push_branch($next_release->{branch});
} elsif ($current_branch =~ /^release/i && defined $previous_release && $mode eq 'source') {
    push_branch($previous_release->{branch});
}

push_branch($_) for @main_branches;
push_branch($_->{branch}) for grep { !defined $matching_release || $_->{branch} ne $matching_release->{branch} } @release_branches;
push_branch($_) for @other_branches;

print join("\n", @suggestions), "\n" if @suggestions;
