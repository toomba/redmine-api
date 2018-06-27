component accessors="true" output="false" {

	property name="issueService" inject="issueService";
	property name="username" inject="coldbox:settings:redmine.username";
	property name="password" inject="coldbox:settings:redmine.password";

	public models.redmine.infrastructure.user.UserRepository function init(
		required string issueService,
		required string username,
		required string password
	) {
		variables.issueService = issueService;
		variables.username = username;
		variables.password = password
		return this;
	}


}