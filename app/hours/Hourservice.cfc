component accessors="true" output="false" {

	property name="HourRepository" inject="hourRepository";

	public models.redmine.app.hours.Hourservice function init() {
		return this;
	}

	public numeric function getTimeSpentForMonth(required numeric month) {

		return hourRepository.getTimeSpentForMonth(month=month);

	}

	public numeric function getTimeSpentCurrentMonth() {

		return hourRepository.getTimeSpentCurrentMonth();

	}

}