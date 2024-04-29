--------------------------------------------------------
--  DDL for Package AZW_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZW_REPORT" AUTHID CURRENT_USER AS
/* $Header: AZWREPTS.pls 115.5 2000/03/08 11:22:52 pkm ship $ */

 /*
 **
 **	Exceptions
 **
 */
  application_exception exception;

 /*
 **
 **	Exception Pragmas
 **
 */
  pragma exception_init(application_exception, -20001);

  /*
   * Name:
   *     start_page
   *
   * Description:
   *     Entry point for inquiry reports.
   *
   * Parameters:
   *     None.
   *
   * Notes:
   *     It dynamically generates an html page for links to different reports.
   */
  PROCEDURE start_page;

  /*
   * Name:
   *     implementation_param_page
   *
   * Description:
   *     Generates parameter entry page for implementation processes report.
   *
   * Parameters:
   *     None.
   *
   * Notes:
   *     Linked from start_page.
   */
  PROCEDURE implementation_param_page;

  /*
   * Name:
   *     context_param_page
   *
   * Description:
   *     Generates parameter entry page for context processes report.
   *
   * Parameters:
   *     None.
   *
   * Notes:
   *     Linked from start_page.
   */
  PROCEDURE context_param_page;

  /*
   * Name:
   *     product_param_page
   *
   * Description:
   *     Generates parameter entry page for product processes report.
   *
   * Parameters:
   *     None.
   *
   * Notes:
   *     Linked from start_page.
   */
  PROCEDURE product_param_page;

  /*
   * Name:
   *     user_param_page
   *
   * Description:
   *     Generates parameter entry page for user performance report.
   *
   * Parameters:
   *     None.
   *
   * Notes:
   *     Linked from start_page.
   */
  PROCEDURE user_param_page;

  /*
   * Name:
   *     status_param_page
   *
   * Description:
   *     Generates parameter entry page for implementation status report.
   *
   * Parameters:
   *     None.
   *
   * Notes:
   *     Linked from start_page.
   */
  PROCEDURE status_param_page;

  /*
   * Name:
   *     implementation_report
   *
   * Description:
   *     Generates implementation processes report based on selected phases.
   *
   * Parameters:
   *     p_phase - selection criteria passed from paramter entry page.
   *               default is for all phases.
   *
   * Notes:
   *     Linked from implementation_param_page.
   */
  PROCEDURE implementation_report(p_phase IN VARCHAR2 DEFAULT NULL);

  /*
   * Name:
   *     context_report
   *
   * Description:
   *     Generates context processes report based on selected context type.
   *
   * Parameters:
   *     p_context - selection criteria passed from paramter entry page.
   *                 default is for BG context.
   *
   * Notes:
   *     Linked from context_param_page. Possible values for p_context are
   *     BG, SOB, IO, OU, and NONE.
   */
  PROCEDURE context_report(p_context IN VARCHAR2);

  /*
   * Name:
   *     product_report
   *
   * Description:
   *     Generates product processes report based on selected product(s).
   *
   * Parameters:
   *     p_product_list - list of application ids for the products selected,
   *                      concatenated with ",".
   *     p_artificial   - see the notes below.
   *
   * Notes:
   *     Linked from product_param_page.
   *
   *     Due to a possible bug in HTML forms, an extra parameter is used in
   *     the product parameter page in order to force the HTML page to display
   *     the 'Cancel' button.  Since the extra parameter in the HTML page is
   *     sent to the product_report procedure, a second parameter is required
   *     (called p_artificial) as a workaround.
   *
   */
  PROCEDURE product_report(p_product_list IN VARCHAR2,
                           p_artificial   IN VARCHAR2 DEFAULT NULL);

  /*
   * Name:
   *     status_report
   *
   * Description:
   *     Generates processes report based on selected status(es).
   *
   * Parameters:
   *     p_status - status of the processes.  default is for all statuses.
   *
   * Notes:
   *     Linked from status_param_page.
   */
  PROCEDURE status_report(p_status IN VARCHAR2 DEFAULT NULL);

  /*
   * Name:
   *     user_report
   *
   * Description:
   *     Generates processes report based on parameters.
   *
   * Parameters:
   *     p_user           - users working on the processes of interest.
   *                        default null for al users.
   *     p_status         - status of the processes of interest.
   *                        default null for all statuses.
   *     p_time_or_period - execution time (days) or period (dates) of the
   *                        processes of interest. Possible values: T, P.
   *                        default is 'T'.
   *     p_operator	  - used when p_time_or_period is T."<=" or ">=".
   *                        default is '>='.
   *     p_days	          - used when p_time_or_period is T. number of days.
   *                        default is 0 days.
   *     p_start          - used when p_time_or_period is P. start date.
   *     p_end            - used when p_time_or_period is P. end date.
   *
   * Notes:
   *     Linked from user_param_page.
   */
  PROCEDURE user_report(p_user           IN VARCHAR2 DEFAULT NULL,
                        p_status         IN VARCHAR2 DEFAULT NULL,
                        p_time_or_period IN VARCHAR2 DEFAULT 'T',
                        p_operator       IN VARCHAR2 DEFAULT '>=',
                        p_days           IN VARCHAR2 DEFAULT '0',
                        p_start          IN VARCHAR2 DEFAULT NULL,
                        p_end            IN VARCHAR2 DEFAULT NULL);


  /*
   * Name:
   *     task_details
   *
   * Description:
   *     Generates step details report for the specified task parameters.
   *
   * Parameters:
   *		p_process_groups
   *		p_ctx_type
   *		p_status
   *		p_start
   *		p_end
   *		p_time_elapsed
   *     	p_item_type
   *     	p_item_key
   *
   * Notes:
   *     Linked from status reports. Each task has a hyperlink that links.
   * 	 to this report.
   */
   PROCEDURE task_details (
		p_process_groups IN VARCHAR2,
		p_ctx_type IN VARCHAR2,
		p_status IN VARCHAR2,
		p_start IN VARCHAR2,
		p_end IN VARCHAR2,
		p_time_elapsed IN VARCHAR2,
		p_item_type IN VARCHAR2,
		p_item_key  IN VARCHAR2);

 /*
   * Name:
   *     show_all_steps
   *
   * Description:
   *     Generates step details report for all the processes.
   *	 available for the selected products.
   *
   * Parameters:
   *     p_selected_products
   *
   * Notes:
   *     Linked from product planning reports.
   */
   PROCEDURE show_all_steps(p_selected_products IN VARCHAR2);

   /*
   * Name:
   *     display_process_steps
   *
   * Description:
   *	It displays all the available steps for the specified
   *	process. It displays the activities in the same order
   *	of the work flow activities if the selected products
   *	are installed.
   *	It can be called as an an external procedure that
   *	displays the available steps for the specified process.
   *	It can be called from show_all_steps.
   *	And it can be called to display a subprocess, from
   *	print_activity.
   *
   * Parameters:
   *     p_selected_products
   *	 p_item_type
   *	 p_process_name
   *	 p_process_groups
   *	 p_new_call
   *	 p_external_call
   *
   * Notes:
   *
   */
   PROCEDURE display_process_steps (
		    p_selected_products		IN VARCHAR2,
		    p_item_type 		IN VARCHAR2,
                    p_process_name 		IN VARCHAR2,
                    p_context_type_name 	IN VARCHAR2,
                    p_process_groups 		IN VARCHAR2,
		    p_new_call 			IN VARCHAR2 DEFAULT NULL,
		    p_external_call		IN VARCHAR2 DEFAULT NULL);

END AZW_REPORT;

 

/
