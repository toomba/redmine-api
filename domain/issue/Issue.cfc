component accessors="true" output="false" {

	property numeric id;
	property string subject;
	property numeric estimatedTime;
	property date startDate;
	property date dueDate;
	property string doneRatio;
	property string status;
	property string type;
	property models.redmine.domain.hours.Hour[] timespent;


	public boolean function hasTimespent() {
		return !isNull(getTimespent());
	}

	public numeric function getSpentTime() {
		var spentTime = 0;

		if (hasTimespent()) {
			for (var i=1;i<=arrayLen(getTimespent());i++) {
				spentTime = spentTime + getTimespent()[i].getTimespent();
			}
		}

		return spentTime;
	}

	public numeric function getOverSpentTime() {
		var spentTime = 0;

		if (hasTimespent()) {
			for (var i=1;i<=arrayLen(getTimespent());i++) {
				if (getTimespent()[i].getTimespent() > getEstimatedTime()) {
					spentTime = spentTime + getTimespent()[i].getTimespent();
				}
			}
		}

		return spentTime;
	}

	public boolean function hasDueDate() {
		return !isNull(getDueDate());
	}

	public boolean function isOverdue() {

		var dueDate = dateAdd('d', -1, now());

		if (hasDueDate()) {
			dueDate = getDueDate();
		}

		return dateCompare(dueDate, now()) == -1;
	}

	public boolean function isOverTime() {
		return getSpentTime() > getEstimatedTime();
	}

	public void function addTimespent(
		required models.redmine.domain.hours.Hour timespent
	) {

		if (hasTimespent()) {

			var timeFound = ArrayFind(variables.timespent, function(item) {
			    return item.getID() == timespent.getID();
			});

			if (!timeFound) {
				arrayAppend(variables.timespent, timespent);
			}

		} else {
			setTimespent([timespent]);
		}
	}

	public date function getFirstTimewrite() {
		if (hasTimespent()) {
			var i = arrayLen(getTimespent());
			return getTimespent()[i].getDate();
		} else {
			return now();
		}
	}


}