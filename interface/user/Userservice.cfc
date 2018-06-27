component accessors="true" output="false" {

	property models.redmine.app.user.Userservice userservice;
	property name="UserService" inject="models.redmine.app.user.Userservice";

	public models.redmine.interface.user.Userservice function init() {
		return this;
	}

	public models.redmine.domain.user.User[] function calculateScoreAdHoc() {
		return userservice.calculateScoreAdHoc();
	}

	public models.redmine.domain.user.User[] function calculateScore() {
		return userservice.calculateScore();
	}

}