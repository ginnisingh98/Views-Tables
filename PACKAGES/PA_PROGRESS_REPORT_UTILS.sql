--------------------------------------------------------
--  DDL for Package PA_PROGRESS_REPORT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_REPORT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPRUTLS.pls 120.1 2005/08/19 16:45:29 mwasowic noship $ */
	procedure	Get_Report_Start_End_Dates(
			P_Object_Type			IN	Varchar2,
			P_Object_Id	         	IN	Number,
                        P_Report_Type_Id                IN      Number,
			P_Reporting_Cycle_Id		IN	Number,
			P_Reporting_Offset_Days		IN	Number,
			P_Publish_Report		IN	Varchar2,
                        p_report_effective_from         IN      Date := NULL,
			X_Report_Start_Date		OUT	NOCOPY Date, --File.Sql.39 bug 4440895
			X_Report_End_Date		OUT	NOCOPY Date --File.Sql.39 bug 4440895
			);

  /************************************************************************
   This function detremines the whether a particular action
   is allowed or not on the progress report, based on the
   system status of the progres report
   IN PARAMETERS  p_current_rep_status - Current user status code of the report
                  p_action  - Action the user wants to perform.Possible values are
                            - 'REWORK'
                            - 'EDIT'
                            - 'SUBMIT'
                            - 'PUBLISH'
                            - 'CANCEL'
                   p_version_id - Version_id of the progress report
   OUT PARAMETERS x_ret_code - Y ; if action allowed, N- Action not allowed
                  x_retun_status - Success or Failure status
                  x_msg_count    - Exception message count
                  x_msg_data     - Exception message
    *************************************************************************/
	Function check_action_allowed
  	(
   		p_current_rep_status  IN  VARCHAR2,
   		p_action_code         IN  VARCHAR2,
   		p_version_id          IN  NUMBER) RETURN VARCHAR2;
   	--	x_ret_code       out varchar2,
   	--	x_return_status  out varchar2,
   	--	x_msg_count      out number,
   	--	x_msg_data       out varchar2);


procedure Validate_Prog_Proj_Dates (p_project_id         IN   Number,
                                    p_scheduled_st_date  IN   Date,
                                    p_scheduled_ed_date  IN   Date,
                                    p_estimated_st_date  IN   Date,
                                    p_estimated_ed_date  IN   Date,
                                    p_actual_st_date     IN   Date,
                                    p_actual_ed_date     IN   Date,
                                    p_percent_complete   IN   Number,
                                    p_est_to_complete    IN   Number,
                                    x_return_status     OUT   NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                    x_msg_count         OUT   NOCOPY Number, --File.Sql.39 bug 4440895
                                    x_msg_data          OUT   NOCOPY Varchar2); --File.Sql.39 bug 4440895

PROCEDURE update_perccomplete
  (
   p_object_id  NUMBER,
   p_object_type VARCHAR2,
   p_percent_complete NUMBER,
   p_asof_date   DATE,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) ;

PROCEDURE is_template_editable
  (
   p_page_id  NUMBER,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) ;

FUNCTION progress_report_exists
  (
   p_object_id  NUMBER,
   p_object_type VARCHAR2
   ) RETURN BOOLEAN;


PROCEDURE remove_progress_report_setup
  (
   p_object_id                   IN     NUMBER := NULL,
   p_object_type                 IN     VARCHAR2 := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) ;

 /* This is the function to get the page_id for the specified objcet of given
    page type.The function will try to get the page id for the object in the
    following order.
    1. Find any page_id associted to the object_id.
       Association exists at object level?
        Yes - Use the page id associted at the object level
        No  -
    2. Find the page associated at the project type level
       Association exists?
       Yes - Use the association at Project Type level.
       No ?
     3. Get the default page associated at the page type level
        This is stored in attribute3 in fnd_lookup_values of
        lookup_code='PA_PAGE_TYPES' and lookup_code = page_type_code
        Each page type owners must seed a default layout for the page
        and populate the attribute3 with that value.
     If the defaulting logic is going to be different, plrease use your own
     method to derive the page_id for the object.
 */
 FUNCTION get_object_page_id (
          p_page_type_code IN varchar2,
          p_object_type    IN varchar2,
          p_object_id      IN NUMBER,
          p_report_type_id IN NUMBER := null)
 return   number;

FUNCTION get_object_region (
          p_object_type    IN varchar2,
          p_object_id      IN NUMBER ,
          p_placeholder_reg_code varchar2)
 return   varchar2;

FUNCTION pagelayout_exists
  (
   p_object_id  NUMBER,
   p_object_type VARCHAR2
   ) RETURN BOOLEAN;

 FUNCTION is_delete_page_layout_ok(
				   p_page_type_code IN varchar2,
				   p_object_type    IN varchar2,
				   p_object_id      IN NUMBER,
                                   p_report_type_id IN NUMBER
				   )
   RETURN VARCHAR2 ;

 FUNCTION is_edit_page_layout_ok(
                                   p_page_type_code IN varchar2,
                                   p_object_type    IN varchar2,
                                   p_object_id      IN NUMBER,
                                   p_report_type_id IN NUMBER
                                   )
   RETURN VARCHAR2 ;

Function Check_Security_For_ProgRep(p_object_Type    IN VARCHAR2,
                                    p_object_Id      IN NUMBER,
                                    p_report_Type_id IN NUMBER,
                                    p_Action         IN VARCHAR) return VARCHAR2;

Function Check_Security_For_ProgRep(p_object_Type    IN VARCHAR2,
                                    p_object_Id      IN NUMBER,
                                    p_report_type_id IN NUMBER) return NUMBER;

Function is_cycle_ok_to_delete(p_reporting_cycle_id  IN  NUMBER) return varchar2;

Function get_latest_working_report_id(p_object_Type    IN VARCHAR2,
                                      p_object_Id      IN NUMBER,
                                      p_report_type_id IN  NUMBER) return NUMBER;

function get_tab_menu_name(p_project_id IN NUMBER) return VARCHAR2;

PROCEDURE copy_project_tab_menu(
	p_src_project_id IN NUMBER,
	p_dest_project_id IN NUMBER,
	x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_return_status OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PROGRESS_REPORT_UTILS;
 

/
