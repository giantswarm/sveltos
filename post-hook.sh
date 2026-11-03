#!/bin/bash -e
# Called by git-subtree-utils' ci-update-to-latest.sh after the subtree merge.
# Keeps our Chart.yaml (name, icon, annotations) and takes the upstream versions.

FILE=helm/sveltos/Chart.yaml

# On a conflict, start from our side and copy the upstream versions from theirs.
if git ls-files -u -- "$FILE" | grep -q .; then
	THEIRS=$(mktemp)
	git show ":3:$FILE" >"$THEIRS"
	git show ":2:$FILE" >"$FILE"
	yq -i ".appVersion = load(\"$THEIRS\").appVersion | .version = load(\"$THEIRS\").version" "$FILE"
fi

yq -i '.upstreamChartVersion = .version | .annotations."io.giantswarm.application.upstream-chart-version" = .version' "$FILE"
# Do not stage anything: ci-update-to-latest.sh commits only when it sees unstaged or conflicted files.
