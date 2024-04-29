--------------------------------------------------------
--  DDL for Package PA_WORKFLOW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKFLOW_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAWFUTLS.pls 120.1 2005/08/19 17:08:03 mwasowic noship $ */



PROCEDURE Insert_WF_Processes
(p_wf_type_code		IN	VARCHAR2
, p_item_type		IN	VARCHAR2
, p_item_key		IN	VARCHAR2
, p_entity_key1		IN	VARCHAR2
, p_entity_key2		IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_description		IN	VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_err_code             	IN OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_err_stage		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_stack		IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Set_Global_Attr
 (p_item_type                   	IN VARCHAR2
  , p_item_key                	IN VARCHAR2
  , p_err_code                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Set_Notification_Messages
 (p_item_type 	              IN VARCHAR2
  , p_item_key                    IN VARCHAR2
);

--
--  FUNCTION
--              get_application_id
--  PURPOSE
--              This function retrieves the application id of a responsibility.
--              If no application id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   02-SEP-99      sbalasub   Created
--
function get_application_id (x_responsibility_id  IN number) return number;
pragma RESTRICT_REFERENCES (get_application_id, WNDS, WNPS);

PROCEDURE get_workflow_info (
			     p_project_status_code        IN     VARCHAR2
			     ,p_project_status_type        IN     VARCHAR2
			     ,x_enable_wf_flag out NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_workflow_item_type out NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_workflow_process OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_wf_success_status_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
			     ,x_wf_failure_status_code OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
			     , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     );

  Procedure  Cancel_Workflow
    (  p_Item_type         IN     VARCHAR2
       , p_Item_key        IN     VARCHAR2
       , x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
       , x_msg_data        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       );

  Procedure  create_workflow_process (
				      p_item_type         IN     VARCHAR2
				      , p_process_name      IN     VARCHAR2
				      , x_item_key       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				      , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
				      , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				      , x_return_status    OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  procedure  start_workflow_process (
				   p_item_type         IN     VARCHAR2
				   , p_process_name      IN     VARCHAR2
				   , p_item_key        IN     number
				   , p_wf_type_code         IN   VARCHAR2
				   , p_entity_key1          IN   VARCHAR2
				   , p_entity_key2          IN   VARCHAR2
				   , p_description          IN   VARCHAR2
				   , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
				   , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			    );

 /* Bug 3787169. This API takes of removing class attributes from the html
	before using the same in workflow.
 */
 procedure  modify_wf_clob_content(
      p_document             IN OUT NOCOPY	pa_page_contents.page_content%TYPE
     ,x_return_status           OUT			NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT			NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT			NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

END pa_workflow_utils;

 

/
