component accessors="true" output="false" {

	property numeric id;
	property string name;
	property models.redmine.domain.issue.Issue[] issues;

	public boolean function hasIssues() {
		return !isNull(getIssues());
	}

	public void function addIssue(
		required models.redmine.domain.issue.Issue issue
	) {

		if (hasIssues()) {
			arrayAppend(variables.issues, issue);
		} else {
			setIssues([issue]);
		}

	}

	public numeric function getSpentTime() {

		var spentTime = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				spentTime = spentTime + getIssues()[i].getSpentTime();
			}
		}

		return spentTime;

	}

	public numeric function getOverSpentTime() {

		var spentTime = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				spentTime = spentTime + getIssues()[i].getOverSpentTime();
			}
		}

		return spentTime;

	}

	public numeric function getSpentTimeLastMonth() {

		var spentTime = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				if (getIssues()[i].hasTimespent()) {
					for (var j=1;j<=arrayLen(getIssues()[i].getTimeSpent());j++) {
						if (dateDiff("ww", getIssues()[i].getTimeSpent()[j].getDate(), now()) <= 4) {
							spentTime = spentTime + getIssues()[i].getTimeSpent()[j].getTimespent();
						}
					}
				}
			}
		}

		return javaCast("double", spentTime);

	}

	public numeric function getSpentTimeThisMonth() {

		var spentTime = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				if (getIssues()[i].hasTimespent()) {
					for (var j=1;j<=arrayLen(getIssues()[i].getTimeSpent());j++) {
						if (dateFormat(getIssues()[i].getTimeSpent()[j].getDate(), "yyyymm") eq dateFormat(now(), "yyyymm")) {
							spentTime = spentTime + getIssues()[i].getTimeSpent()[j].getTimespent();
						}
					}
				}
			}
		}

		return javaCast("double", spentTime);

	}

	public numeric function unestimatedIssues() {

		var issuecount = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				if (getIssues()[i].getestimatedTime() == 0) {
					issuecount++;
				}
			}
		}

		return issuecount;
	}

	public numeric function overDueIssues() {

		var issuecount = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				if (getIssues()[i].isOverdue()) {
					issuecount++;
				}
			}
		}

		return issuecount;
	}

	public numeric function overTimeIssues() {

		var issuecount = 0;

		if (hasIssues()) {
			for (var i=1;i<=arrayLen(getIssues());i++) {
				if (getIssues()[i].isOvertime()) {
					issuecount++;
				}
			}
		}

		return issuecount;
	}

}