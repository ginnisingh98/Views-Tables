--------------------------------------------------------
--  DDL for Package PA_PROJECT_STUS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_STUS_UTILS" AUTHID CURRENT_USER as
-- $Header: PAPSUTLS.pls 120.2 2006/11/07 05:39:58 vgottimu noship $

--  FUNCTION
--              Is_Project_Closed
--  PURPOSE
--              This function returns 'N' or 'Y'
--              depending on whether the project is closed or not

--
--              It calls the Is_Project_Status_Closed function.
FUNCTION Is_Project_Closed
                          (x_project_id IN NUMBER ) return VARCHAR2;

--Bug 3059344
--pragma RESTRICT_REFERENCES (Is_Project_Closed, WNDS, WNPS);

--  FUNCTION
--              Is_Project_Status_Closed
--  PURPOSE
--              This function returns 'Y'
--              if the given project status has a system status of 'CLOSED',
--              'PENDING_PURGE', 'PARTIALLY_PURGED' and 'PURGED'

FUNCTION Is_Project_Status_Closed
                          (x_project_status_code IN VARCHAR2 ) return VARCHAR2;

--  FUNCTION
--              Is_ARPR_Project_Status_Closed
--  PURPOSE
--              This function returns 'Y'
--              if the given project status has a system status of 'CLOSED' or
--              'PARTIALLY_PURGED'

FUNCTION Is_ARPR_Project_Status_Closed
                          (x_project_status_code IN VARCHAR2 ) return VARCHAR2;


--  FUNCTION
--              Is_Project_In_Purge_Status
--  PURPOSE
--              This function returns 'Y'
--              if the given project status has a system status of 'PENDING_PURGE',
--              'PARTIALLY_PURGED' and 'PURGED'

FUNCTION Is_Project_In_Purge_Status
                          (x_project_status_code IN VARCHAR2 ) return VARCHAR2;

--Bug 3059344
--pragma RESTRICT_REFERENCES (Is_Project_Status_Closed, WNDS, WNPS);

Procedure Handle_Project_Status_Change
                 (x_calling_module                IN VARCHAR2
                 ,X_project_id                    IN NUMBER
                 ,X_old_proj_status_code          IN VARCHAR2
                 ,X_new_proj_status_code          IN VARCHAR2
                 ,X_project_type                  IN VARCHAR2
                 ,X_project_start_date            IN DATE
                 ,X_project_end_date              IN DATE
                 ,X_public_sector_flag            IN VARCHAR2
                 ,X_attribute_category            IN VARCHAR2
                 ,X_attribute1                    IN VARCHAR2
                 ,X_attribute2                    IN VARCHAR2
                 ,X_attribute3                    IN VARCHAR2
                 ,X_attribute4                    IN VARCHAR2
                 ,X_attribute5                    IN VARCHAR2
                 ,X_attribute6                    IN VARCHAR2
                 ,X_attribute7                    IN VARCHAR2
                 ,X_attribute8                    IN VARCHAR2
                 ,X_attribute9                    IN VARCHAR2
                 ,X_attribute10                   IN VARCHAR2
                 ,X_pm_product_code               IN VARCHAR2
                 ,x_init_msg                      IN VARCHAR2 := 'Y'
                 ,x_verify_ok_flag               OUT NOCOPY VARCHAR2						--Bug: 4537865
                 ,x_wf_enabled_flag              OUT NOCOPY VARCHAR2						--Bug: 4537865
                 ,X_err_stage                 IN OUT NOCOPY varchar2						--Bug: 4537865
                 ,X_err_stack                 IN OUT NOCOPY varchar2						--Bug: 4537865
                 ,x_err_msg_count                OUT NOCOPY Number						--Bug: 4537865
                 ,x_warnings_only_flag           OUT NOCOPY VARCHAR2 );						--Bug: 4537865

Procedure Check_Wf_Enabled (x_project_status_code IN VARCHAR2,
                            x_project_type        IN VARCHAR2,
                            x_project_id          IN NUMBER,
                            x_wf_item_type       OUT NOCOPY VARCHAR2,						--Bug: 4537865
                            x_wf_process         OUT NOCOPY VARCHAR2,						--Bug: 4537865
                            x_wf_enabled_flag    OUT NOCOPY VARCHAR2,						--Bug: 4537865
                            x_err_code           OUT NOCOPY NUMBER );						--Bug: 4537865

FUNCTION Is_Starting_Status (x_project_status_code IN VARCHAR2) RETURN VARCHAR2;

-- This function checks whether a given project status is a starting
-- status for any project type

pragma RESTRICT_REFERENCES (Is_Starting_Status, WNDS, WNPS);

FUNCTION Get_Default_Starting_Status (x_project_type IN VARCHAR2)
RETURN VARCHAR2;

-- This function gets the default starting status associated with
-- a project type

pragma RESTRICT_REFERENCES (Get_Default_Starting_Status, WNDS, WNPS);

PROCEDURE Allow_Status_Deletion(
          p_project_status_code  IN VARCHAR2
          , p_status_type        IN VARCHAR2
          , x_err_code          OUT NOCOPY NUMBER								--Bug: 4537865
          , x_err_stage         OUT NOCOPY VARCHAR2								--Bug: 4537865
          , x_err_stack         OUT NOCOPY VARCHAR2								--Bug: 4537865
          , x_allow_deletion_flag         OUT NOCOPY VARCHAR2);							--Bug: 4537865

FUNCTION Allow_Status_Change (o_status_code IN VARCHAR2
							  ,n_status_code IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE Delete_from_Next_Status (p_current_status_code  IN VARCHAR2);

PROCEDURE Insert_into_Next_Status (p_current_status_code IN VARCHAR2
								   , p_next_status_code IN VARCHAR2);

-- Start of comments
--	API name 	: Name_to_Id
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Returns the Id given MTL_SYSTEM_ITEMS given
--			  its item_id.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				.
--				.
--			 	p_item_id			IN NUMBER 	Required
--			  		Corresponds to the column INVENTORY_ITEM_ID in
--			  		the table MTL_SYSTEM_ITEMS, and identifies the
--			  		record to be deleted.
--			  	p_org_id			IN NUMBER 	Required
--					Item organization id. Part of the unique key
--					that uniquely identifies an item record.
--	Version	: Current version	2.0
--				Added IN parameter p_org_id.
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments

PROCEDURE Check_Status_Name_or_Code(
                 p_status_code           IN VARCHAR2
                 ,p_status_name          IN VARCHAR2
                 ,p_status_type          IN VARCHAR2
                 ,p_check_id_flag        IN VARCHAR2
                 ,x_status_code          OUT NOCOPY VARCHAR2							--Bug: 4537865
                 ,x_return_status        OUT NOCOPY VARCHAR2							--Bug: 4537865
                 ,x_error_message_code   OUT NOCOPY VARCHAR2);							--Bug: 4537865

PROCEDURE  get_wf_success_failure_status
				(p_status_code IN VARCHAR2
				,p_status_type IN VARCHAR2
				,x_wf_success_status_code OUT NOCOPY VARCHAR2					--Bug: 4537865
				,x_wf_failure_status_code OUT NOCOPY VARCHAR2					--Bug: 4537865
                                ,x_return_status       OUT    NOCOPY VARCHAR2					--Bug: 4537865
                                ,x_error_message_code  OUT    NOCOPY VARCHAR2 ) ;				--Bug: 4537865

--   Added for lifecycle support
--  This procedure will check for the constraints available for phase type status code before deleting

PROCEDURE check_delete_phase_ok(
          p_project_status_code           IN VARCHAR2
	  , x_err_code                    OUT NOCOPY NUMBER							--Bug: 4537865
          , x_err_stage                   OUT NOCOPY VARCHAR2							--Bug: 4537865
          , x_err_stack                   OUT NOCOPY VARCHAR2							--Bug: 4537865
          , x_allow_deletion_flag         OUT NOCOPY VARCHAR2);							--Bug: 4537865


--Bug5635429  This function will return Y if the project status is being
--used in project types setup. N will be returned otherwise
FUNCTION   is_status_used_in_proj_type(p_project_status_code IN VARCHAR2)
RETURN VARCHAR2;


--Bug 3059344
   G_ProjID_Tab PA_PLSQL_DATATYPES.Char1TabTyp;
   g_project_status_code pa_projects_all.project_status_code%type;
   G_PROJ_STS_CLOSED VARCHAR2(1);


end PA_PROJECT_STUS_UTILS ;

 

/
