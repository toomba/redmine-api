component accessors="true" output="false" {

	property numeric id;
	property numeric timespent;
	property date date;

	public models.redmine.domain.hours.Hour function init(
		required numeric id,
		required date date,
		required numeric timespent
	) {
		variables.id = id;
		variables.timespent = timespent;
		variables.date = date;
		return this;
	}

}