component accessors="true" output="false" {
	property name="projectRepository"	inject="projectRepository";
	property name="hourRepository" 		inject="hourRepository";
	property name="cache" 				inject="cachebox:default";

	public models.redmine.app.user.Userservice function init() {
		return this;
	}

	public models.redmine.domain.user.User[] function calculateScoreAdHoc() {

		var cacheName = getFunctionCalledName();
		var users = cache.get(cacheName);

		if (isNull(users)) {

			var users = hourRepository.getUserHours(type="adhoc");
			for (var i=1; i<=arrayLen(users); i++) {
				for (var j=1; j<=arrayLen(users[i].getIssues()); j++) {
					var issue = users[i].getIssues()[j];
					projectRepository.enrichIssue(issue);
				}
			}

			arraySort(users, function (current_element, next_element) {

				if (next_element.getSpentTimeThisMonth() < current_element.getSpentTimeThisMonth()) return -1;
				if (next_element.getSpentTimeThisMonth() == current_element.getSpentTimeThisMonth()) return 0;
				if (next_element.getSpentTimeThisMonth() > current_element.getSpentTimeThisMonth()) return 1;

			});

			cache.set(cacheName, users);
		}

		return users;
	}

	public models.redmine.domain.user.User[] function calculateScore() {

		var cacheName = getFunctionCalledName();
		var users = cache.get(cacheName);

		if (isNull(users)) {

			var users = hourRepository.getUserHours(type="all");
			for (var i=1; i<=arrayLen(users); i++) {
				for (var j=1; j<=arrayLen(users[i].getIssues()); j++) {
					var issue = users[i].getIssues()[j];
					projectRepository.enrichIssue(issue);
				}
			}

			arraySort(users, function (current_element, next_element) {

				if (next_element.getOverSpentTime() < current_element.getOverSpentTime()) return -1;
				if (next_element.getOverSpentTime() == current_element.getOverSpentTime()) return 0;
				if (next_element.getOverSpentTime() > current_element.getOverSpentTime()) return 1;

			});

			cache.set(cacheName, users);

		}

		return users;
	}

}