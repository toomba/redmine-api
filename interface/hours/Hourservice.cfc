component accessors="true" output="false" {


	property name="HourService" inject="app.hours.HourService";

	public models.redmine.interface.hours.Hourservice function init() {
		return this;
	}

	public numeric function getTimeSpentForMonth(required numeric month) {

		return hourservice.getTimeSpentForMonth(month=month);

	}

	public numeric function getTimeSpentCurrentMonth() {

		return hourservice.getTimeSpentCurrentMonth();

	}

}