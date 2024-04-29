--------------------------------------------------------
--  DDL for Package PA_EGO_WRAPPER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EGO_WRAPPER_PUB" AUTHID CURRENT_USER AS
 /* $Header: PAEGOWPS.pls 120.1 2005/08/19 16:21:56 mwasowic noship $ */


-- Start of comments
--	API name 	: check_delete_phase_ok
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_ADMIN_PUB.check_delete_phase_ok
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--	p_phase_id                      IN      NUMBER				       Required
--	P_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--	x_delete_ok			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				8-NOV-02  mrajput   Created.
-- End of comments

PROCEDURE check_delete_phase_ok(
	p_api_version			IN	NUMBER   :=1.0			,
	p_phase_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT NULL		,
	x_delete_ok			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_errorcode			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895



-- Start of comments
--	API name 	: process_phase_delete
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_ADMIN_PUB.process_phase_delete
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--	p_phase_id                      IN      NUMBER				       Required
--	P_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--	P_commit			IN	VARCHAR2			       Optional	    Default      NULL
--      x_errorcode                     OUT     NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				8-NOV-02  mrajput   Created.
-- End of comments

PROCEDURE process_phase_delete(
	p_api_version			IN	NUMBER   :=1.0			,
	p_phase_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT NULL		,
	p_commit       			IN	VARCHAR2 DEFAULT NULL		,
	x_errorcode   			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				,	 --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

-- Start of comments
--	API name 	: check_delete_lifecycle_ok
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_ADMIN_PUB.check_delete_lifecycle_ok
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--	p_lifecycle_id                  IN      NUMBER				       Required
--	P_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--	x_delete_ok			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				8-NOV-02  mrajput   Created.
-- End of comments
PROCEDURE check_delete_lifecycle_ok(
	p_api_version			IN	NUMBER	:=1.0			,
	p_lifecycle_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT NULL		,
	x_delete_ok			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_errorcode			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2); 			  --File.Sql.39 bug 4440895

-- Start of comments
--	API name 	: delete_stale_data_for_lc
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_ADMIN_PUB.delete_stale_data_for_lc
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--	p_lifecycle_id                  IN      NUMBER				       Required
--	P_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--	P_commit			IN	VARCHAR2			       Optional	    Default      NULL
--      x_errorcode                     OUT     NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				8-NOV-02  mrajput   Created.
-- End of comments
PROCEDURE delete_stale_data_for_lc(
	p_api_version			IN	NUMBER	 :=1.0			,
	p_lifecycle_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT NULL		,
	p_commit       			IN	VARCHAR2 DEFAULT NULL		,
	x_errorcode   			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

-- Start of comments
--	API name 	: get_policy_for_phase_change
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_USER_PUB.get_policy_for_phase_change
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--	p_project_id                    IN      NUMBER				       Required
--	p_current_phase_id              IN      NUMBER				       Required
--	p_future_phase_id		IN	NUMBER				       Required
--	p_phase_change_code		IN	VARCHAR2			       Required
--      p_lifecycle_id			IN	NUMBER
--      x_policy_code			OUT	VARCHAR2
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-NOV-02  mrajput   Created.
-- End of comments

PROCEDURE get_policy_for_phase_change(
	p_api_version			IN	NUMBER	  := 1.0		,
        p_project_id                    IN      NUMBER                          , -- Bug 2800909
	p_current_phase_id		IN	NUMBER				,
	p_future_phase_id		IN	NUMBER				,
	p_phase_change_code		IN	VARCHAR2			,
	p_lifecycle_id			IN	NUMBER				,
	x_policy_code			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_error_message			OUT	NOCOPY VARCHAR2			, -- Bug 2760719 --File.Sql.39 bug 4440895
	x_errorcode			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- Start of comments
--	API name 	: sync_phase_change
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_USER_PUB.sync_phase_change
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_project_id			IN	NUMBER				       Required
--	p_lifecycle_id                  IN      NUMBER				       Required
--	p_phase_id                      IN      NUMBER				       Required
--	p_effective_date                IN      NUMBER				       Required
--	P_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--	P_commit			IN	VARCHAR2			       Optional	    Default      NULL
--      x_errorcode                     OUT     NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-NOV-02  mrajput   Created.
-- End of comments

PROCEDURE sync_phase_change(
	p_api_version			IN	NUMBER	:=1.0			,
	p_project_id    		IN	NUMBER				,
	p_lifecycle_id 			IN	NUMBER				,
	p_phase_id 			IN	NUMBER				,
	p_effective_date		IN	DATE				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT NULL		,
	p_commit       			IN	VARCHAR2 DEFAULT NULL		,
	x_errorcode   			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- Start of comments
--	API name 	: check_lc_tracking_project
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_USER_PUB.check_lc_tracking_project
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_project_id			IN	NUMBER				       Required
--      x_is_lifecycle_tracking		OUT	VARCHAR2
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-NOV-02  mrajput   Created.
-- End of comments


PROCEDURE check_lc_tracking_project(
	p_api_version			IN	NUMBER	  :=1.0			,
	p_project_id			IN	NUMBER				,
	x_is_lifecycle_tracking		OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_errorcode			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Start of comments
--	API name 	: check_delete_project_ok
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_USER_PUB.check_delete_project_ok
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_project_id			IN	NUMBER				       Required
--      p_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--      x_delete_ok			OUT	VARCHAR2
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-NOV-02  mrajput   Created.
-- End of comments

PROCEDURE check_delete_project_ok(
	p_api_version		IN	NUMBER	   :=1.0	,
	p_project_id 		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2   DEFAULT NULL	,
	x_delete_ok		OUT	NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	x_return_status		OUT	NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	x_errorcode		OUT	NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	x_msg_count		OUT	NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	x_msg_data		OUT	NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895



-- Start of comments
--	API name 	: delete_all_item_assocs
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_USER_PUB.delete_all_item_assocs
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_project_id			IN	NUMBER				       Required
--      p_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--      p_commit			IN	VARCHAR2                               Optional     Default      NULL
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-NOV-02  mrajput   Created.
-- End of comments

PROCEDURE delete_all_item_assocs(
	p_api_version			IN	NUMBER	 :=1.0			,
	p_project_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT NULL		,
	p_commit       			IN	VARCHAR2 DEFAULT NULL		,
	x_errorcode   			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895





FUNCTION CHECK_PLM_INSTALLED RETURN CHAR;
-- The function will check whether PLM is installed or not
-- and return TRUE if the product PLM is installed.


-- Start of comments
--	API name 	: copy_item_assocs
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_USER_PUB.copy_item_assocs
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_project_id_from		IN	NUMBER				       Required
--      p_project_id_to                 IN      NUMBER				       Required
--      p_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--      p_commit			IN	VARCHAR2                               Optional     Default      NULL
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-DEC-02  anlee   Created.
-- End of comments

PROCEDURE Copy_Item_Assocs
(
      p_api_version            IN      NUMBER    := 1.0
     ,p_project_id_from        IN      NUMBER
     ,p_project_id_to          IN      NUMBER
     ,p_init_msg_list          IN      VARCHAR2 DEFAULT NULL
     ,p_commit                 IN      VARCHAR2 DEFAULT NULL
     ,x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_errorcode              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/* Start for Changes made for Integration with Eng */
-- Start of comments
--	API name 	: check_delete_project_ok_eng
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	ENG_LIFECYCLE_USER_PUB.check_delete_project_ok
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_project_id			IN	NUMBER				       Required
--      p_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--      x_delete_ok			OUT	VARCHAR2
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-FEB-03  mrajput   Created.
-- End of comments

PROCEDURE check_delete_project_ok_eng(
	p_api_version		IN	NUMBER	   :=1.0	,
	p_project_id 		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2   DEFAULT NULL	,
	x_delete_ok		OUT	NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	x_return_status		OUT	NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	x_errorcode		OUT	NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	x_msg_count		OUT	NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	x_msg_data		OUT	NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895

-- Start of comments
--	API name 	: check_delete_task_ok_eng
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	ENG_LIFECYCLE_USER_PUB.check_delete_task_ok
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--      p_task_id			IN	NUMBER				       Required
--      p_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--      x_delete_ok			OUT	VARCHAR2
--	X_return_status			OUT	VARCHAR2
--      x_errorcode                     OUT     NUMBER
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				13-FEB-03  mrajput   Created.
-- End of comments

PROCEDURE check_delete_task_ok_eng(
	p_api_version		IN	NUMBER	   :=1.0	,
	p_task_id 		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2   DEFAULT NULL	,
	x_delete_ok		OUT	NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	x_return_status		OUT	NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	x_errorcode		OUT	NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	x_msg_count		OUT	NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	x_msg_data		OUT	NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895

/* End for Changes made for Integration with Eng */


/* Start Changes for Bug 2778408 */

-- Start of comments
--	API name 	: process_phase_code_delete
--	Type		: Public
--	Pre-reqs	: None.
--	Purpose  	: Calls	EGO_LIFECYCLE_ADMIN_PUB.process_phase_code_delete
--	Parameters	:
--	p_api_version	                IN      NUMBER		                       Optional	    Default	 1.0
--	p_phase_code                    IN      NUMBER				       Required
--	P_init_msg_list			IN	VARCHAR2			       Optional	    Default      NULL
--	P_commit			IN	VARCHAR2			       Optional	    Default      NULL
--      x_errorcode                     OUT     NUMBER
--	X_return_status			OUT	VARCHAR2
--	X_msg_count			OUT	NUMBER
--	X_msg_data			OUT	VARCHAR2
--	History         :
--				14-FEB-03  mrajput   Created.
-- End of comments
PROCEDURE process_phase_code_delete(
	p_api_version			IN	NUMBER   :=1.0			,
	p_phase_code 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit       			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_return_status			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_errorcode   			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				,	 --File.Sql.39 bug 4440895
	x_msg_data			OUT	NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

/* End Changes for Bug 2778408 */
END PA_EGO_WRAPPER_PUB;

 

/
