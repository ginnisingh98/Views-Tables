--------------------------------------------------------
--  DDL for Package Body AZW_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_REPORT" AS
/* $Header: AZWREPTB.pls 115.64 2000/03/08 11:22:40 pkm ship $ */
/* Global Variables **********************************************************/
  g_current_mode VARCHAR2(255);  -- Wizard Mode
  g_mode_label   fnd_lookups.meaning%TYPE; -- Wizard Mode label
  g_blank     VARCHAR2(8) := ' ';  -- for padding in the hierarchy
  g_indent    INTEGER := 3;        -- for indentation in hierarchy
  g_web_agent VARCHAR2(255) := ''; -- URL for the host server
  /* labels  */
  g_planning VARCHAR2(2000) := NULL;  -- Planning Reports
  g_monitor  VARCHAR2(2000) := NULL;  -- Status Reports
  g_related  VARCHAR2(2000) := NULL;  -- Related Reports
  g_ipr      VARCHAR2(2000) := NULL;  -- Implementation Process Report (IPR)
  g_cpr      VARCHAR2(2000) := NULL;  -- Context Process Report (CPR)
  g_ppr      VARCHAR2(2000) := NULL;  -- Product Process Report (PPR)
  g_isr      VARCHAR2(2000) := NULL;  -- Implementation Status Report (ISR)
  g_upr      VARCHAR2(2000) := NULL;  -- User Performance Report (UPR)
  g_ok          VARCHAR2(2000) := NULL;  -- OK
  g_ok_hlp	VARCHAR2(2000) := NULL; -- OK Button Status Help
  g_cancel      VARCHAR2(2000) := NULL;  -- Cancel
  g_cancel_hlp	VARCHAR2(2000) := NULL; -- Cancel Button Status Help
  g_all         VARCHAR2(2000) := NULL;  -- All
  g_phase       VARCHAR2(2000) := NULL;  -- Phase
  g_proc_status VARCHAR2(2000) := NULL;  -- Process Status
  g_status      VARCHAR2(2000) := NULL;  -- Status
  g_installed   VARCHAR2(2000) := NULL;  -- Product Installed
  g_summary	VARCHAR2(2000) := NULL;  -- Report Summary
  g_process_group	VARCHAR2(2000) := NULL;  -- Process Group

  g_num_procs			VARCHAR2(2000) := NULL;  -- # of Processes
  g_num_active_procs		VARCHAR2(2000) := NULL;  -- # of Active Processes
  g_num_completed_procs		VARCHAR2(2000) := NULL;  -- # of Complete Processes
  g_num_notstarted_procs	VARCHAR2(2000) := NULL;  -- # of Not Started Processes

  g_num_tasks	VARCHAR2(2000) := NULL;  -- # of tasks worked on

  g_details	VARCHAR2(2000) := NULL;  -- Report Details
  g_selected    VARCHAR2(2000) := NULL;  -- Product Selected
  g_hierarchy   VARCHAR2(2000) := NULL;  -- Process Hierarchy
  g_ctxt_type   VARCHAR2(2000) := NULL;  -- Context Type
  g_ctxt_name   VARCHAR2(2000) := NULL;  -- Context Name
  g_user        VARCHAR2(2000) := NULL;  -- User
  g_duration    VARCHAR2(2000) := NULL;  -- Duration
  g_start       VARCHAR2(2000) := NULL;  -- Start Date
  g_from       VARCHAR2(2000) := NULL;  -- From
  g_to       VARCHAR2(2000) := NULL;  -- To
  g_end         VARCHAR2(2000) := NULL;  -- End Date
  g_days        VARCHAR2(2000) := NULL;  -- Days
  g_dateformat_msg	VARCHAR2(2000) := NULL;  -- used by user_param
  g_timeformat  VARCHAR2(2000) := NULL;  -- HH:MM AM/PM
  g_atmost      fnd_lookups.meaning%TYPE := NULL;  -- At most
  g_atleast     fnd_lookups.meaning%TYPE := NULL;  -- At least
  g_description VARCHAR2(2000) := NULL; -- Process Description
  g_comments    VARCHAR2(2000) := NULL;  -- Process Comments
  /* messages */
  g_welcome_msg VARCHAR2(2000) := NULL; -- welcome message in start_page
  g_ipr_msg     VARCHAR2(2000) := NULL; -- instructions for IPR
  g_cpr_msg     VARCHAR2(2000) := NULL; -- instructions for CPR
  g_ppr_msg     VARCHAR2(2000) := NULL; -- instructions for PPR
  g_isr_msg     VARCHAR2(2000) := NULL; -- instructions for ISR
  g_upr_msg     VARCHAR2(2000) := NULL; -- instructions for UPR
  g_help_target VARCHAR2(2000) := NULL;  -- Help Target
  g_ipr_desc    VARCHAR2(2000) := NULL; -- Short Description for IPR
  g_cpr_desc    VARCHAR2(2000) := NULL; -- Short Description for CPR
  g_ppr_desc    VARCHAR2(2000) := NULL; -- Short Description for PPR
  g_isr_desc    VARCHAR2(2000) := NULL; -- Short Description for ISR
  g_upr_desc    VARCHAR2(2000) := NULL; -- Short Description for UPR
  g_param_hdr	VARCHAR2(2000) := NULL; -- Report Parameters header
  g_param_note	VARCHAR2(2000) := NULL; -- Report Parameters note
  g_mn_menu	VARCHAR2(2000) := NULL; -- Main Icon Menu Balloon Help
  g_exit	VARCHAR2(2000) := NULL; -- Exit Icon Balloon Help
  g_help	VARCHAR2(2000) := NULL; -- Help Icon Balloon Help
  g_as_of	VARCHAR2(2000)   := NULL; -- As of

  g_no_prod_inst 	VARCHAR2(2000) := NULL; -- no products installed
  g_no_prod_sel 	VARCHAR2(2000) := NULL; -- no products selected
  g_back_top  	 VARCHAR2(2000) := NULL; -- Back to top


  g_report_legend	VARCHAR2(2000)  := NULL; -- Report Legend
  g_group_legend	VARCHAR2(2000) := NULL; -- Process Group legend desc
  g_subgrp_legend	VARCHAR2(2000) := NULL; -- Process Sub-Group legend desc
  g_process_legend	VARCHAR2(2000) := NULL; -- Process legend desc
  g_task_legend		VARCHAR2(2000) := NULL; -- Task legend desc

  g_task_details	VARCHAR2(2000)  := NULL; -- Task Step Details
  g_step_name		VARCHAR2(2000)  := NULL; -- Step Name
  g_step_response	VARCHAR2(2000)  := NULL; -- Response

  g_task_params		VARCHAR2(2000)  := NULL; -- Task Parameters

  g_step_details	VARCHAR2(2000)  := NULL; -- Step Details
  g_process		VARCHAR2(2000)  := NULL; -- Process
  g_steps		VARCHAR2(2000)  := NULL; -- Steps
  g_step_msg		VARCHAR2(2000)  := NULL; -- Message

  g_step_all_procs	VARCHAR2(2000)  := NULL; -- Step details for all processes

  g_active_by		VARCHAR2(2000)  := NULL; -- Active By




  /*  Java Script Messages */
  -- Select a product before OK
  g_js_slct_prd 	 VARCHAR2(2000) := NULL;
  -- Select the Time Elapsed option
  g_js_slct_time_elapsed VARCHAR2(2000) := NULL;
  g_image_path	CONSTANT VARCHAR2(20) := '/OA_MEDIA';

  --
  -- Used by display_process_steps to display page header only once
  -- if a subprocess exists.
  --
  g_FirstTime BOOLEAN := TRUE;
/* Type Definitions **********************************************************/

  TYPE id_tbl_t IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

  TYPE PlanProcessGroupRec IS RECORD(
    phase			AZ_PLANNING_REPORTS.PHASE%TYPE,
    display_name		AZ_PLANNING_REPORTS.DISPLAY_NAME%TYPE,
    processes_count		PLS_INTEGER,
    node_id			AZ_PLANNING_REPORTS.NODE_ID%TYPE
  );

  TYPE StatusProcessGroupRec IS RECORD(
    node_id			AZ_MONITOR_REPORTS.NODE_ID%TYPE,
    display_name		AZ_MONITOR_REPORTS.DISPLAY_NAME%TYPE,
    processes_count		INTEGER,
    active_procs_count		INTEGER,
    complete_procs_count	INTEGER,
    not_started_procs_count	INTEGER
  );
  -- used by report summary
  TYPE PlanProcessGroups IS TABLE OF PlanProcessGroupRec
  		INDEX BY BINARY_INTEGER;
  TYPE StatusProcessGroups IS TABLE OF StatusProcessGroupRec
  		INDEX BY BINARY_INTEGER;

 TYPE HierarchyLevels IS TABLE OF VARCHAR2(240)
  		INDEX BY BINARY_INTEGER;

  g_upper_process_names 	HierarchyLevels;
  g_curr_process_level		PLS_INTEGER;
  g_inst_count			PLS_INTEGER := 0;
  g_instance_ids 		id_tbl_t;
  g_prev_act_name 		wf_process_activities.activity_name%TYPE := NULL;

/* Private Procedure Declarations ********************************************/

  PROCEDURE get_context_processes(p_context    IN VARCHAR2);
  PROCEDURE get_implementation_processes(p_phase      IN NUMBER);
  PROCEDURE get_monitor_group_parent(p_group_id   IN VARCHAR2,
			             p_user IN VARCHAR2);
  PROCEDURE get_planning_group_parent(p_group_id   IN VARCHAR2,
                                      p_phase      IN NUMBER);
  PROCEDURE get_product_processes(p_application_id IN NUMBER);
  PROCEDURE get_report_title_desc(p_rpt_code IN VARCHAR2,
  				  p_rpt_title IN OUT VARCHAR2,
  				  p_rpt_desc IN OUT VARCHAR2);
  PROCEDURE get_status_groups(p_status IN VARCHAR2);
  PROCEDURE get_status_processes(p_status IN VARCHAR2);
  PROCEDURE get_status_tasks(p_status IN VARCHAR2);
  PROCEDURE get_user_trees_by_atleast(p_user       IN VARCHAR2,
                                      p_status     IN VARCHAR2,
                                      p_duration   IN NUMBER);
  PROCEDURE get_user_trees_by_atmost(p_user       IN VARCHAR2,
                                     p_status     IN VARCHAR2,
                                     p_duration   IN NUMBER);
  PROCEDURE get_user_trees_by_period(p_user       IN VARCHAR2,
                                     p_status     IN VARCHAR2,
                                     p_startdate  IN DATE,
                                     p_enddate    IN DATE);
  PROCEDURE get_translated_labels;
  PROCEDURE get_web_agent;
  PROCEDURE get_process_type_name (p_node_id   IN VARCHAR2,
			     p_item_type OUT VARCHAR2,
			     p_process_name  OUT VARCHAR2);
  PROCEDURE get_task_type_key (p_node_id   IN VARCHAR2,
			     p_item_type OUT VARCHAR2,
			     p_item_key  OUT VARCHAR2);
  PROCEDURE print_html_style;
  PROCEDURE print_imp_start_page;
  PROCEDURE print_upgrade_start_page;
  PROCEDURE print_context_subheader(p_context IN VARCHAR2);
  PROCEDURE print_product_subheader(p_ids IN id_tbl_t);
  PROCEDURE print_ipr_report_parameters (p_phase IN VARCHAR2);
  PROCEDURE print_ipr_installed_products (p_phase IN VARCHAR2);
  PROCEDURE print_planning_reports_summary (p_phase IN VARCHAR2);
  PROCEDURE populate_process_groups_array (p_phase IN NUMBER,
  			process_groups IN OUT NOCOPY PlanProcessGroups);
  PROCEDURE print_status_subheader (p_status IN VARCHAR2);
  PROCEDURE print_isr_installed_products;
  PROCEDURE print_isr_report_summary (p_status IN VARCHAR2);
  PROCEDURE populate_isr_process_groups (
			process_groups IN OUT NOCOPY StatusProcessGroups);
  PROCEDURE print_user_subheader(p_user           IN VARCHAR2,
                                 p_status         IN VARCHAR2,
                                 p_time_or_period IN VARCHAR2,
                                 p_operator       IN VARCHAR2,
                                 p_days           IN VARCHAR2,
                                 p_start          IN VARCHAR2,
                                 p_end            IN VARCHAR2);
  PROCEDURE print_user_report_summary;
  PROCEDURE print_param_page_header(p_title IN VARCHAR2,
                                    p_msg IN VARCHAR2,
                                    p_mode_label IN VARCHAR2 DEFAULT NULL);
  PROCEDURE print_param_page_footer;
  PROCEDURE print_selected_prods_table (p_ids IN id_tbl_t);
  PROCEDURE print_footer_separator_line;
  PROCEDURE print_ok_cancel_buttons(p_ok_action	IN VARCHAR2);

  PROCEDURE print_report_header(p_title IN VARCHAR2,
  			p_type IN BOOLEAN,
		  	p_param_page IN VARCHAR2);
  PROCEDURE print_related_reports(p_rpt1 IN VARCHAR2,
                                  p_rpt2 IN VARCHAR2 DEFAULT NULL);
  PROCEDURE print_welcome_header(p_title IN VARCHAR2);
  PROCEDURE print_pp_jscripts;
  PROCEDURE print_up_jscripts;
  PROCEDURE print_back_to_top (p_col_span IN NUMBER);
  PROCEDURE raise_error_msg (
			ErrCode		IN NUMBER,
			ErrMsg 		IN VARCHAR2,
			ProcedureName   IN VARCHAR2,
  			Statement 	IN VARCHAR2);

  PROCEDURE print_time_stamp (v_string VARCHAR2);
  PROCEDURE print_legend_link;
  PROCEDURE print_legend (p_status BOOLEAN DEFAULT FALSE);
  PROCEDURE print_step_details_header (p_display_msg IN VARCHAR2 DEFAULT NULL);
  PROCEDURE print_activity(
		p_selected_products 	IN VARCHAR2,
		p_instance_id 		IN NUMBER,
		p_display_msg 		IN VARCHAR2);
  PROCEDURE print_js_open_url (blnStep IN BOOLEAN DEFAULT FALSE);
  PROCEDURE print_task_steps(
           p_item_type     IN VARCHAR2,
           p_item_key      IN VARCHAR2,
           p_process_name  IN VARCHAR2,
           p_process_level IN NUMBER);

/* Function Definitions ******************************************************/

/*
**
**	CHECK_ACTIVITY_PRODUCTS
**	=======================
**
**	Private Function.
**	It checks if any of the selected products is in
**	the defined list of installed products for the
**	current activity.
**	It returns Y or N to match
**
*/
FUNCTION check_activity_products (
		p_selected_products IN VARCHAR2,
		p_instance_id IN NUMBER) RETURN VARCHAR2 IS

  v_app_id     	NUMBER;
  v_cnt        	BINARY_INTEGER;
  v_ids        	id_tbl_t;
  v_inst_prods	wf_activity_attr_values.TEXT_VALUE%TYPE;

BEGIN

  v_cnt := 1;
  v_app_id := azw_proc.parse_application_ids(p_selected_products, v_cnt);
  WHILE (v_app_id > -1) LOOP
    v_ids(v_cnt) := v_app_id;
    v_cnt := v_cnt + 1;
    v_app_id := azw_proc.parse_application_ids(p_selected_products, v_cnt);
  END LOOP;

  SELECT TEXT_VALUE INTO v_inst_prods
  FROM wf_activity_attr_values
  WHERE NAME = 'AZW_IA_WFPROD'
  AND PROCESS_ACTIVITY_ID = p_instance_id
  AND TEXT_VALUE <> 'AZW_IA_WFPROD';

  FOR  v_cnt IN 1..v_ids.COUNT LOOP
    IF (INSTR(v_inst_prods, TO_CHAR(v_ids(v_cnt))) > 0) THEN
	return('Y');
    END IF;
  END LOOP;
  return('N');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('N');
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'CHECK_ACTIVITY_PRODUCTS', '');
END check_activity_products;

 /*------------------------------------------------------------------------
   * GET_APPLICATION_NAME
   *
   * Private function.
   * Given an application id, return the application name.
   *-----------------------------------------------------------------------*/
  FUNCTION get_application_name(p_app_id IN NUMBER) RETURN VARCHAR2 IS
    v_name fnd_application_vl.application_name%TYPE := TO_CHAR(p_app_id);

  BEGIN
    SELECT application_name
    INTO   v_name
    FROM   fnd_application_vl
    WHERE  application_id = p_app_id;

    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN v_name;
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
      		'GET_APPLICATION_NAME', '');
  END get_application_name;

  /*------------------------------------------------------------------------
   * GET_APPLICATION_SHORT_NAME
   *
   * Private function.
   * Given an application id, return the application short name.
   *-----------------------------------------------------------------------*/
  FUNCTION get_application_short_name(p_app_id IN NUMBER) RETURN VARCHAR2 IS
    v_name fnd_application_vl.application_short_name%TYPE := TO_CHAR(p_app_id);

  BEGIN
    SELECT application_short_name
    INTO   v_name
    FROM   fnd_application_vl
    WHERE  application_id = p_app_id;

    RETURN v_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN v_name;
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
         raise_error_msg (SQLCODE, SQLERRM,
      		'GET_APPLICATION_SHORT_NAME', '');
  END get_application_short_name;

  /*------------------------------------------------------------------------
   * GET_REPORT_PROCEDURE
   *
   * Private function.
   * Given a report code, return the name of the package and the procedure
   * that generates the parameter entry page for the report.
   *-----------------------------------------------------------------------*/
  FUNCTION get_report_procedure(p_rpt_code IN VARCHAR2) RETURN VARCHAR2 IS
    v_value  VARCHAR2(240) := p_rpt_code;

  BEGIN
    IF (p_rpt_code LIKE '%IPR') THEN
      v_value := 'azw_report.implementation_param_page';
    ELSIF (p_rpt_code LIKE '%CPR') THEN
      v_value := 'azw_report.context_param_page';
    ELSIF (p_rpt_code LIKE '%PPR') THEN
      v_value := 'azw_report.product_param_page';
    ELSIF (p_rpt_code LIKE '%ISR') THEN
      v_value := 'azw_report.status_param_page';
    ELSIF (p_rpt_code LIKE '%IPRR') THEN
      v_value := 'azw_report.implementation_report';
    ELSIF (p_rpt_code LIKE '%CPRR') THEN
      v_value := 'azw_report.context_report';
    ELSIF (p_rpt_code LIKE '%PPRR') THEN
      v_value := 'azw_report.product_report';
    ELSIF (p_rpt_code LIKE '%ISRR') THEN
      v_value := 'azw_report.status_report';
    ELSIF (p_rpt_code LIKE '%UPRR') THEN
      v_value := 'azw_report.user_report';
    ELSE                              --  (p_rpt_code LIKE '%UPR') THEN
      v_value := 'azw_report.user_param_page';
    END IF;
    RETURN v_value;
  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
         raise_error_msg (SQLCODE, SQLERRM,
      		'GET_REPORT_PROCEDURE', '');
  END get_report_procedure;

  /*------------------------------------------------------------------------
   * GET_TRANSLATION
   *
   * Private function.
   * Given a lookup type and a lookup code, returns its translated meaning.
   *-----------------------------------------------------------------------*/
  FUNCTION get_translation(p_type IN VARCHAR2, p_code IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_meaning  fnd_lookups.meaning%TYPE := p_code;

  BEGIN
    SELECT meaning
    INTO   v_meaning
    FROM   fnd_lookups
    WHERE  lookup_type = p_type
    AND    lookup_code = p_code;

    RETURN v_meaning;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN v_meaning;
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_TRANSLATION', '');
  END get_translation;

  /*------------------------------------------------------------------------
   * LPAD_NBSP
   *
   * Private function.
   * Given a hierarchy node and its level, returns a string left-padded with
   * '&nbsp;' based on the level.
   *-----------------------------------------------------------------------*/
  FUNCTION lpad_nbsp(p_level IN NUMBER) RETURN VARCHAR2 IS
    v_node VARCHAR2(2000);
    v_cnt  NUMBER;
  BEGIN
    FOR v_cnt IN 1..(p_level-1) LOOP
      v_node := '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'|| v_node;
    END LOOP;
    RETURN v_node;
  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'LPAD_NBSP', '');
  END lpad_nbsp;

/*
**
**	GET_PARENT_STRUCTURE
**	====================
**
**	Returns all the parents specified in the array till
**	the specified level, in a directory structure.
**  	For example it will return
**	"\Common Applications\System Administration\" for the
**	Process "Printers"
**	All the upper level parent names must have already been
**	populated in the passed array.
**
*/
FUNCTION get_parent_structure (
		p_upper_group_names IN HierarchyLevels,
		p_level IN NUMBER,
		p_seperator IN VARCHAR2 DEFAULT '\') RETURN VARCHAR2 IS
  i 		PLS_INTEGER;
  v_output	VARCHAR2(4000);
BEGIN
  FOR i IN 1..p_level LOOP
    IF (i = p_level) THEN
      v_output := v_output || p_upper_group_names(i);
    ELSE
      v_output := v_output || p_upper_group_names(i) || p_seperator;
    END IF;
  END LOOP;
  return (v_output);
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_PARENT_STRUCTURE', '');
END get_parent_structure;

/*
**
**      IS_ACT_NOTFOUND
**      ===============
**
**      It checks if the specified instance ID has already been inserted
**      in the g_instance_ids PL/SQL table. Not to process an activity twice.
**      Called from display_process_steps, print_activity.
**
*/

FUNCTION is_act_notfound(p_instance_id IN NUMBER) return boolean IS
   i 	PLS_INTEGER;
BEGIN

    IF g_inst_count > 0 THEN
      FOR i IN 1..g_inst_count LOOP
        IF (g_instance_ids(i) = p_instance_id) THEN
	  return FALSE;
        END IF;
      END LOOP;
    END IF;
    return TRUE;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
          'IS_ACT_NOTFOUND', '');

END is_act_notfound;

/*
**
**	URL_ENCODE
**	==========
**
**	Private Function.
**	It replaces all the spaces in the URL to '+' sign.
**
*/
FUNCTION url_encode (p_url IN VARCHAR2) RETURN VARCHAR2 IS
  v_url VARCHAR2(4000):= p_url;

BEGIN
  v_url := REPLACE(v_url, ':', '%3A');
  v_url := REPLACE(v_url, '&', '%26');
  v_url := REPLACE(v_url, ' ', '+');
  return(v_url);
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'URL_ENCODE', '');
END url_encode;

/*
**
**      FORMAT_STEP_BODY
**      ================
**
**      Private Function.
**      When a formated text is displayed in HTML format the text is shown as a
**      big blob of text. This function is created to retain the format and not
**      to lose the basic text format like carriage returns, line feeds, tabs, ect.
**      It also replaces the '<' and '>' to their HTML representation.
**
*/

FUNCTION format_step_body(p_body IN VARCHAR2) RETURN VARCHAR2 IS

  v_body VARCHAR2(4000):= p_body;

BEGIN

  v_body := REPLACE(v_body, '>', '&#62');
  v_body := REPLACE(v_body, '<', '&#60');
  v_body := REPLACE(v_body, FND_GLOBAL.LOCAL_CHR(10), '<BR>');
  v_body := REPLACE(v_body, FND_GLOBAL.LOCAL_CHR(13), NULL);

  return(v_body);
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
          'FORMAT_STEP_BODY', '');
END format_step_body;

/* Procedure Definitions *****************************************************/

/*
**
**      ADD_INSTANCE_TO_ARRAY
**      =====================
**
**      Adds a new element at the end of the g_instance_ids.
**      which is used to keep track if the current instance has
**      been processed or not. Not to tarce an activity twice.
**
*/

PROCEDURE add_instance_to_array(p_instance_id IN NUMBER) IS

BEGIN

 g_instance_ids(g_inst_count + 1) := p_instance_id;
 g_inst_count := g_inst_count + 1;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
          'ADD_INSTANCE_TO_ARRAY', '');

END add_instance_to_array;

  /*------------------------------------------------------------------------
   * CONTEXT_PARAM_PAGE
   *
   * Public procedure.
   * Generates parameter entry page in HTML for the context process report.
   * Performs the following steps:
   *   1. Get the URL for host server and all display strings if the URL is ''.
   *   2. Print the title and the instruction as the header.
   *   3. Display all the choices of context types in a drop down list, making
   *      BG as the default option.
   *   4. Print the OK and Cancel buttons as the footer. OK buttons calls the
   *      context report ans passes the user selected context type; Cancel
   *      button returns to the starting welcome page.
   *-----------------------------------------------------------------------*/
  PROCEDURE context_param_page IS

    CURSOR context_types_cursor IS
      SELECT   lookup_code,
               meaning,
               DECODE(lookup_code, 'NONE', 1, 'BG', 2, 'SOB', 3, 'OU', 4, 5)
                 display_order
      FROM     fnd_lookups
      WHERE    lookup_type = 'AZ_CONTEXT_TYPE'
      ORDER BY display_order;

  BEGIN
    g_help_target := get_report_procedure('AZW_RPT_CPR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    print_param_page_header(g_cpr, g_cpr_msg, NULL);

    htp.p('<table align="center" border="0" cellpadding="0" ' ||
    		'cellspacing="2" width="96%">');
    htp.p('<tr><td colspan=4><br></td>');
    htp.p('<form name="Form1" method="post" ' ||
    		'action="azw_report.context_report"></tr>');
    htp.p('<tr><td align=right width=50%><font class=normal>' ||
    			g_ctxt_type || '</font></td>');
    htp.p('<td align=left colspan=3><select name="p_context" size=1>');
    -- construct pop-up list of context types BG, IO, OU, SOB and NONE
    -- if v_context.lookup_code like '%BG%' make it default

    FOR one_context IN context_types_cursor LOOP
      IF (one_context.lookup_code LIKE '%BG%') THEN
        htp.p('<option selected value="'||one_context.lookup_code||'"> '||
              one_context.meaning || '</option>');
      ELSE
        htp.p('<option value="'||one_context.lookup_code||'"> '||
              one_context.meaning || '</option>');
      END IF;
    END LOOP;
    htp.p('</select></td></tr>');

    -- print OK and Cancel buttons
    print_param_page_footer;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'CONTEXT_PARAM_PAGE', '');
  END context_param_page;

  /*------------------------------------------------------------------------
   * CONTEXT_REPORT
   *
   * Public procedure.  Invoked by the OK button in context_param_page.
   * Generates the context process report in HTML.  It performs the following
   * steps:
   *   1. Get the URL for host server and all display strings if the URL is ''.
   *   2. Print report header and subheader.
   *   4. Print HTML Table opening tag and header.
   *   5. Get all processes of the specified context into the intermediate
   *      table.
   *   6. Retrieve the trees in the intermediate table.  For each node, print
   *      Table Row and Table Data.
   *   7. Print Table closing tag.
   *   8. Print links to related reports.
   *-----------------------------------------------------------------------*/
  PROCEDURE context_report(p_context IN VARCHAR2) IS
    v_count	 NUMBER;
    CURSOR hierarchies_cursor IS
      SELECT     LPAD(g_blank, g_indent*(LEVEL-1))||display_name hierarchy,
                 node_type,
                 context_type_name,
                 description,
                 parent_node_id,
                 node_id,
                 LEVEL
      FROM       az_planning_reports
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id
      AND	 PRIOR phase = phase;

  BEGIN
    print_time_stamp('Start the report');
--    dbms_output.put_line('context_report: '||p_context);
    g_help_target := get_report_procedure('AZW_RPT_CPRR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    print_report_header(g_cpr, TRUE, 'azw_report.context_param_page');

    print_context_subheader(p_context);

    get_context_processes(p_context);

    --
    -- 	Display the report summary
    --
    print_planning_reports_summary(-1);

    print_legend_link;

    --
    -- 	Display the Report Details
    --
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="3">' ||
	      '<FONT CLASS="tableHeader">'|| g_details ||'</FONT></TD></TR>');
    htp.p('<TR>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
     	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_ctxt_type ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_description ||'</FONT></TH>');

    v_count := 0;
    FOR one_node IN hierarchies_cursor LOOP
      htp.tableRowOpen;
      IF (one_node.parent_node_id IS NULL) THEN
        IF (v_count > 0) THEN
	  print_back_to_top(2);
	END IF;
     	htp.p('<TD ALIGN="LEFT" COLSPAN="3" BGCOLOR="#666666" ' ||
     		'NOWRAP><i><FONT COLOR="#FFFFFF"><A NAME="PH-1_'||
     		 one_node.node_id || '">' ||
            	one_node.hierarchy || '</A></FONT></i></TD>');
      ELSIF (one_node.node_type = 'G') THEN
        htp.tableData('<A NAME="'|| v_count ||'"><i>'||
        	lpad_nbsp(one_node.level) || one_node.hierarchy ||
                      '</A></i>', 'LEFT', '', 'NOWRAP');
        htp.tableData('<i>'|| one_node.context_type_name || '</i>');
	v_count := v_count + 1;
      ELSE
        htp.tableData('<b>'|| lpad_nbsp(one_node.level) || one_node.hierarchy ||
                      '</b>', 'LEFT', '', 'NOWRAP');
        htp.tableData(one_node.context_type_name);
        htp.tableData(one_node.description);
      END IF;
      htp.tableRowClose;
    END LOOP;
    print_back_to_top(2);
    -- print Table closing tag
    htp.tableClose;
    -- print report legend
    print_legend;

    --
    -- 	Print related report links
    --
    print_related_reports('AZW_RPT_IPR', 'AZW_RPT_PPR');
    print_time_stamp('End the report');

--    COMMIT;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- print Table closing tag
      htp.tableClose;
      print_related_reports('AZW_RPT_IPR', 'AZW_RPT_PPR');
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'CONTEXT_REPORT', '');
  END context_report;

  /*------------------------------------------------------------------------
   * GET_CONTEXT_PROCESSES
   *
   * Private procedure.  Called by context_report.
   * Populate context process hierarchies in the intermediate table.
   * It performs the following steps:
   *   1. Get all distinct processes of the given context type from
   *      az_processes_all_v into the intermediate table.
   *   2. Find all distinct parent ids for the processes found in Step 1.
   *   3. For each parent id in Step 2, get all distinct hierarchy ancestors
   *      in az_groups_v into the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_context_processes(p_context    IN VARCHAR2) IS
    CURSOR processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name node_id,
             apv.display_name,
             apv.context_type_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.description
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  (apv.context_type = p_context OR apv.context_type = 'NONE')
      AND    apv.process_type = 'IMP'
      AND    apv.parent_id = ag.group_id
      AND    ag.process_type = apv.process_type;

    CURSOR parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  apv.context_type = p_context OR apv.context_type = 'NONE';

    v_locator	NUMBER;
  BEGIN
    v_locator := 1;
    FOR one_proc IN processes_cursor LOOP
      INSERT INTO az_planning_reports
      (NODE_ID, PHASE, NODE_TYPE, DISPLAY_NAME,
        CONTEXT_TYPE_NAME,PARENT_NODE_ID, DESCRIPTION)
      VALUES
      (one_proc.node_id, -1, 'P', one_proc.display_name,
       one_proc.context_type_name, one_proc.parent_node_id, one_proc.description);
    END LOOP;

    v_locator := 2;
    -- kick off recursive search for parents
    FOR one_process IN parents_cursor LOOP
      get_planning_group_parent(one_process.parent_id, -1);
    END LOOP;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_CONTEXT_PROCESSES', 'v_locator := ' || v_locator);
  END get_context_processes;

  /*------------------------------------------------------------------------
   * GET_IMPLEMENTATION_PROCESSES
   *
   * Private procedure.  Called by implementation_report.
   * Populate implementation process hierarchies in the intermediate table.
   * It performs the following steps:
   *   1. Get all distinct processes of the given phase from az_processes_all_v
   *      and az_flow_phases_v into the intermediate table.
   *   2. Find all distinct parent ids for the processes found in Step 1.
   *   3. For each parent id in Step 2, get all distinct hierarchy ancestors
   *      in az_groups_v into the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_implementation_processes(p_phase      IN NUMBER)
                                         IS
    CURSOR processes_cursor IS
       SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||
             apv.item_type ||'.'||apv.process_name node_id,
             apv.display_name,
             TO_CHAR(agv.display_order, '0000')||'.'|| apv.parent_id parent_node_id,
             apv.description
      FROM   az_processes_all_v apv,
             az_groups agv,
             az_flow_phases_v afpv
      WHERE  afpv.phase = p_phase
      AND    afpv.item_type = apv.item_type
      AND    afpv.process_name = apv.process_name
      AND    apv.parent_id = agv.group_id
      AND    apv.process_type = 'IMP'
      AND    agv.process_type = apv.process_type;

    CURSOR parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes apv,
             az_flow_phases_v afpv
      WHERE  apv.item_type = afpv.item_type
      AND    apv.process_name = afpv.process_name
      AND    apv.process_type = 'IMP'
      AND    afpv.phase = p_phase;

  v_locator NUMBER;
  BEGIN
    v_locator := 1;
    FOR one_process IN processes_cursor LOOP
      INSERT INTO az_planning_reports
       (NODE_ID, PHASE, NODE_TYPE, DISPLAY_NAME,
        CONTEXT_TYPE_NAME,PARENT_NODE_ID, DESCRIPTION)
       VALUES
            (one_process.node_id, p_phase, 'P', one_process.display_name, '',
             one_process.parent_node_id, one_process.description);
    END LOOP;
    v_locator := 2;
    -- kick off the recursive search for parents
    FOR one_process IN parents_cursor LOOP
      get_planning_group_parent(one_process.parent_id, p_phase);
    END LOOP;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_IMPLEMENTATION_PROCESSES', 'v_locator := ' || v_locator);
  END get_implementation_processes;

  /*------------------------------------------------------------------------
   * GET_MONITOR_GROUP_PARENT
   *
   * Private procedure.  Called by reports that use az_monitor_reports as the
   * intermediate data storage (get_user_trees_by_period,
   * get_user_trees_by_atleast, get_user_trees_by_atmost, get_status_groups).
   * Given a group id, recursively get all its group parents into the
   * intermediate table if the parent does not exist in the table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_monitor_group_parent(p_group_id   IN VARCHAR2,
                                     p_user       IN VARCHAR2)
                                     IS
    CURSOR group_parent_cursor IS
       SELECT TO_CHAR(agv.display_order, '0000')||'.'||agv.group_id node_id,
         agv.display_name,
         TO_CHAR(ag.display_order, '0000')||'.'|| agv.hierarchy_parent_id  parent_node_id,
         agv.status,
         agv.hierarchy_parent_id h_parent_id
        FROM   az_groups_v agv,
               az_groups ag
        WHERE   agv.group_id = p_group_id
        AND   	agv.process_type = g_current_mode
        AND   	ag.process_type = g_current_mode
        AND    	agv.hierarchy_parent_id = ag.group_id
        UNION
        SELECT TO_CHAR(agv.display_order, '0000')||'.'||agv.group_id node_id,
               agv.display_name,
               NULL parent_node_id,
               agv.status,
               NULL  h_parent_id
        FROM    az_groups_v agv
        WHERE   agv.group_id = p_group_id
        AND     agv.process_type = g_current_mode
        AND     agv.hierarchy_parent_id IS NULL;

    v_exist_cnt    NUMBER := -1;
    v_group        group_parent_cursor%ROWTYPE;
    v_status       fnd_lookups.meaning%TYPE;
    v_locator	   NUMBER;
  BEGIN
    v_locator := 1;
    OPEN group_parent_cursor;
    FETCH group_parent_cursor INTO v_group;

    v_locator := 2;
    SELECT COUNT(*)
    INTO   v_exist_cnt
    FROM   az_monitor_reports amr
    WHERE  amr.node_id = v_group.node_id
    AND    amr.assigned_user = p_user;

    IF (v_exist_cnt = 0) THEN
      v_status := get_translation('AZ_PROCESS_STATUS', v_group.status);
      v_locator := 3;
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
      (v_group.node_id, p_user, 'G', v_group.display_name, '',
       '', v_group.parent_node_id, v_status, '', '', '', NULL);
      v_locator := 4;
      CLOSE group_parent_cursor;
      IF (v_group.h_parent_id IS NOT NULL) THEN
        get_monitor_group_parent(v_group.h_parent_id, p_user);
      END IF;
    ELSE                 -- the node is already in the table
      CLOSE group_parent_cursor;
    END IF;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_MONITOR_GROUP_PARENT', 'v_locator := ' || v_locator);
  END get_monitor_group_parent;

  /*------------------------------------------------------------------------
   * GET_PLANNING_GROUP_PARENT
   *
   * Private procedure.  Called by reports that use az_planning_reports as the
   * intermediate data storage (get_implementation_processes,
   * get_context_processes, get_product_processes).
   * Given a group id, recursively get all its group parents into the
   * intermediate table if the parent does not exist in the table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_planning_group_parent(p_group_id   IN VARCHAR2,
                                      p_phase      IN NUMBER)
                                      IS
    CURSOR group_parent_cursor IS
       SELECT TO_CHAR(agv.display_order, '0000')||'.'||agv.group_id node_id,
              agv.display_name,
              DECODE(agv.hierarchy_parent_id, '', '',
                   TO_CHAR(ag.display_order, '0000')||'.'||
              agv.hierarchy_parent_id) parent_node_id,
              agv.hierarchy_parent_id h_parent_id
       FROM   az_groups_v agv,
              az_groups ag
       WHERE  agv.group_id = p_group_id
       AND    agv.process_type = g_current_mode
       AND    ag.process_type = g_current_mode
       AND    agv.hierarchy_parent_id = ag.group_id
       UNION
       SELECT TO_CHAR(agv.display_order, '0000')||'.'||agv.group_id node_id,
              agv.display_name,
              NULL,
              NULL
       FROM   az_groups_v agv
       WHERE  agv.group_id = p_group_id
       AND    agv.process_type = g_current_mode
       AND    agv.hierarchy_parent_id IS NULL;

    v_exist_cnt    NUMBER := -1;
    v_group        group_parent_cursor%ROWTYPE;
    v_locator	   NUMBER;
  BEGIN
    v_locator := 1;
    OPEN group_parent_cursor;
    FETCH group_parent_cursor INTO v_group;

    v_locator := 2;
    SELECT COUNT(*)
    INTO   v_exist_cnt
    FROM   az_planning_reports apr
    WHERE  apr.node_id = v_group.node_id
    AND    apr.phase = p_phase;

    IF (v_exist_cnt = 0) THEN
      v_locator := 3;
      INSERT INTO az_planning_reports
       (NODE_ID, PHASE, NODE_TYPE, DISPLAY_NAME,
        CONTEXT_TYPE_NAME,PARENT_NODE_ID, DESCRIPTION)
      VALUES
      (v_group.node_id, p_phase, 'G', v_group.display_name, '',
       v_group.parent_node_id, NULL);
      v_locator := 4;
      CLOSE group_parent_cursor;
      IF (v_group.h_parent_id IS NOT NULL) THEN
        get_planning_group_parent(v_group.h_parent_id, p_phase);
        v_locator := 5;
      END IF;
    ELSE                       -- the node is already in the table
      CLOSE group_parent_cursor;
    END IF;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_PLANNING_GROUP_PARENT', 'v_locator := ' || v_locator);
  END get_planning_group_parent;

  /*------------------------------------------------------------------------
   * GET_PRODUCT_PROCESSES
   *
   * Private procedure.  Called by product_report.
   * Populate product process hierarchies in the intermediate table.
   * Performs the following steps:
   *   1. Get all distinct processes for the given application id from
   *      az_product_flows into the intermediate table if the process does
   *      not exist in the table.
   *   2. Find all distinct parent ids for the processes found in Step 1.
   *   3. For each parent id in Step 2, get all distinct hierarchy ancestors
   *      in az_groups_v into the intermediate table if the parent does not
   *      exist in the table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_product_processes(p_application_id IN NUMBER)
                                  IS
    CURSOR processes_cursor IS
      SELECT DISTINCT TO_CHAR(apf.display_order, '0000')||'.'||apf.item_type
               ||'.'||apf.process_name node_id,
             wav.display_name display_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apf.parent_id
               parent_node_id,
               meaning context_type_name,
             wav.description
      FROM   az_product_flows apf,
     	     az_groups ag,
             wf_activities_vl wav,
             fnd_lookups fnd
      WHERE  apf.application_id = p_application_id
      AND    apf.process_type = 'IMP'
      AND    wav.end_date IS NULL
      AND    wav.item_type like 'AZ%'
      AND    wav.name like 'AZ%'
      AND    apf.item_type = wav.item_type
      AND    apf.process_name = wav.name
      AND    ag.process_type = apf.process_type
      AND    apf.parent_id = ag.group_id
      AND    fnd.lookup_type = 'AZ_CONTEXT_TYPE'
      AND    fnd.lookup_code = apf.context_type;

    CURSOR parents_cursor IS
      SELECT DISTINCT apf.parent_id
      FROM   az_product_flows apf
      WHERE  apf.application_id = p_application_id;

    v_exist_cnt NUMBER;
    v_locator   NUMBER;

  BEGIN
    v_locator := 1;
    FOR one_process IN processes_cursor LOOP
      -- check if the process is already in the table
      v_exist_cnt := -1;
      v_locator := 2;
      SELECT COUNT(*)
      INTO   v_exist_cnt
      FROM   az_planning_reports apr
      WHERE  apr.node_id = one_process.node_id
      AND    apr.phase = -1;
      v_locator := 3;
      IF (v_exist_cnt = 0) THEN
        INSERT INTO az_planning_reports
       (NODE_ID, PHASE, NODE_TYPE, DISPLAY_NAME,
        CONTEXT_TYPE_NAME,PARENT_NODE_ID, DESCRIPTION)
      VALUES
        (one_process.node_id, -1, 'P', one_process.display_name,
         one_process.context_type_name, one_process.parent_node_id, one_process.description);
      END IF;
    END LOOP;

    -- kick off recursive search for parents
    v_locator := 4;
    FOR one_process IN parents_cursor LOOP
      get_planning_group_parent(one_process.parent_id, -1);
    END LOOP;
  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_PRODUCT_PROCESSES', 'v_locator := ' || v_locator);
  END get_product_processes;

  /*------------------------------------------------------------------------
   * GET_REPORT_TITLE_DESC
   *
   * Private function.
   * Given a report code, returns the translated title and short description
   * for the report.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_report_title_desc(p_rpt_code IN VARCHAR2,
  				  p_rpt_title IN OUT VARCHAR2,
  				  p_rpt_desc IN OUT VARCHAR2) IS
  BEGIN
    IF (p_rpt_code LIKE '%IPR') THEN
      p_rpt_title := g_ipr;
      p_rpt_desc := g_ipr_desc;
    ELSIF (p_rpt_code LIKE '%CPR') THEN
      p_rpt_title := g_cpr;
      p_rpt_desc := g_cpr_desc;
    ELSIF (p_rpt_code LIKE '%PPR') THEN
      p_rpt_title := g_ppr;
      p_rpt_desc := g_ppr_desc;
    ELSIF (p_rpt_code LIKE '%ISR') THEN
      p_rpt_title := g_isr;
      p_rpt_desc := g_isr_desc;
    ELSE      -- IF (p_rpt_code LIKE '%UPR') THEN
      p_rpt_title := g_upr;
      p_rpt_desc := g_upr_desc;
    END IF;
 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_REPORT_TITLE_DESC', '');
  END get_report_title_desc;

  /*------------------------------------------------------------------------
   * GET_STATUS_GROUPS
   *
   * Private procedure. Called by status_report.
   * Populate groups with processes with a particular status into the
   * intermediate table.  Performs the following steps:
   *   1. If all statuses is chosen, get all group parents in az_groups_v into
   *      the intermediate table.
   *   2. Otherwise, find all distinct group parents that has a process with
   *      the status.  For each parent found, recursively get all its ancestors
   *      into the table if the parent does not exist in the table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_status_groups(p_status IN VARCHAR2) IS

                                /* distinct parents for one status (A, C, N) */

    CURSOR status_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes apv
      WHERE  apv.status_code = p_status
      AND    apv.process_type = g_current_mode;

                                          /* distinct parents for 'I' status */
    CURSOR incomplete_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes apv
      WHERE  (apv.status_code = 'N'
      OR     apv.status_code = 'A')
      AND    apv.process_type = g_current_mode;

                                /* distinct parents for all statuses */

    CURSOR all_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes apv
      WHERE  apv.process_type = g_current_mode;

    v_status  fnd_lookups.meaning%TYPE;
    v_locator  PLS_INTEGER := 0;
  BEGIN
--    dbms_output.put_line('get_status_groups: '||p_status);
    IF (p_status IS NULL) THEN              /* get parents for all processes */
      v_locator := 1;
      FOR one_proc IN all_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, ' ');
      END LOOP
      COMMIT;
      /* get parents for I status */
    ELSIF (p_status = 'I') THEN
      v_locator := 2;
      FOR one_proc IN incomplete_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, ' ');
      END LOOP;
    ELSE                   /* get parents for processes of A, C, or N status */
      v_locator := 3;
      FOR one_proc IN status_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, ' ');
      END LOOP;
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_STATUS_GROUPS', 'v_locator := ' || v_locator);
  END get_status_groups;

  /*------------------------------------------------------------------------
   * GET_STATUS_PROCESSES
   *
   * Private procedure.  Called by status_report.
   * Populate processes with a particular status in the intermediate table.
   * Performs the following steps:
   *   1. If all statuses is chosen, get all processes from az_processes_all_v
   * 	  into the intermediate table.
   *   2. Otherwise, get processes of the specified status form
   * 	  az_processes_all_v into the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_status_processes(p_status IN VARCHAR2)
    IS
                                          /* processes for A, C, or N status */
    CURSOR status_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.context_type_name,
             apv.context_name,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.status = p_status
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = g_current_mode
      AND    apv.parent_id = ag.group_id;

                                                   /* processes for I status */
    CURSOR incomplete_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.context_type_name,
             apv.context_name,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  (apv.status = 'N' OR apv.status = 'A')
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = g_current_mode
      AND    apv.parent_id = ag.group_id;

                                               /* processes for all statuses */
    CURSOR all_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.context_type_name,
             apv.context_name,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.process_type = g_current_mode
      AND    ag.process_type = g_current_mode
      AND apv.parent_id = ag.group_id;

    v_status 	fnd_lookups.meaning%TYPE;
    v_locator  PLS_INTEGER := 0;
  BEGIN
--  dbms_output.put_line('get_status_processes:'||p_status);

    IF (p_status IS NULL) THEN                         /* get all processes */
      v_locator := 1;
      FOR one_proc IN all_processes_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_proc.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, ' ', 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '',one_proc.comments);
      END LOOP;
                                              /* get processes for I status */
    ELSIF (p_status = 'I') THEN
      v_locator := 2;
      FOR one_proc IN incomplete_processes_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_proc.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, ' ', 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);

      END LOOP;
    ELSE                                /* get processes of A, C or N status */
      v_locator := 3;
      v_status := get_translation('AZ_PROCESS_STATUS', p_status);
      FOR one_proc IN status_processes_cursor LOOP
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, ' ', 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);
      END LOOP;
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_STATUS_PROCESSES', 'v_locator := ' || v_locator);
  END get_status_processes;

  /*------------------------------------------------------------------------
   * GET_STATUS_TASKS
   *
   * Private procedure. Called by status_report.
   * Populate tasks belong to processes with a particular status into the
   * intermediate table.  Performs the following steps:
   *   1. If all statuses is chosen, get all tasks in az_tasks_v into the
   *      intermediate table.
   *   2. Otherwise, get all tasks that belong to processes with the specified
   *      status into the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_status_tasks(p_status IN VARCHAR2) IS

                             /* tasks of processes with one status (A, C, N) */

    CURSOR status_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  apv.status = p_status
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    apv.process_type = g_current_mode
      AND    atv.context_id = apv.context_id;

                                        /* tasks of processes with I status  */

    CURSOR incomplete_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  (apv.status = 'N'
      OR     apv.status = 'A')
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    apv.process_type = g_current_mode
      AND    atv.context_id = apv.context_id;

                                      /* tasks for processes of all statuses */

    CURSOR all_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    apv.process_type = g_current_mode
      AND    atv.context_id = apv.context_id;

    v_status 	fnd_lookups.meaning%TYPE;
    v_locator	PLS_INTEGER := 0;
  BEGIN
--    dbms_output.put_line('get_status_tasks: '||p_status);

    IF (p_status = 'N') THEN     /* Not Started processes do not have tasks */
      RETURN;
    ELSIF (p_status IS NULL) THEN             /* get tasks for all processes */
      v_locator := 1;
      FOR one_task IN all_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, one_task.assigned_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration, NULL);
      END LOOP;
                                      /* get tasks for processes of I status */
    ELSIF (p_status = 'I') THEN
     v_locator := 2;
     FOR one_task IN incomplete_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, one_task.assigned_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration,NULL);
      END LOOP;
    ELSE                         /* get tasks for processes of A or C status */
      v_locator := 3;
      FOR one_task IN status_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, one_task.assigned_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration,NULL);
      END LOOP;
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_STATUS_TASKS', 'v_locator := ' || v_locator);
  END get_status_tasks;

  /*------------------------------------------------------------------------
   * GET_TRANSLATED_LABELS
   *
   * Private procedure.
   * Retrieve all the translatable texts used in the reports.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_translated_labels IS
    v_locator  PLS_INTEGER := 0;
  BEGIN
    g_current_mode := fnd_profile.value('AZ_CURRENT_MODE');
    g_planning := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PR');
    g_monitor  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_SR');
    g_related  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_RELATED');
    g_ipr := FND_MESSAGE.get_string('AZ', 'AZW_RPT_IPR');
    g_cpr := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CPR');
    g_ppr := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PPR');
    g_isr := FND_MESSAGE.get_string('AZ', 'AZW_RPT_ISR');
    g_upr := FND_MESSAGE.get_string('AZ', 'AZW_RPT_UPR');
    g_as_of := FND_MESSAGE.get_string('AZ', 'AZW_RPT_AS_OF');
    g_ok          := FND_MESSAGE.get_string('AZ', 'AZW_RPT_OK');
    g_cancel      := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CANCEL');
    g_phase       := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PHASE');
    g_proc_status := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PS');
    g_status      := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STATUS');
    g_installed   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PRDINSTL');
    g_summary     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_SUMMARY');
    g_process_group   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PROC_GROUPS');
    g_num_procs    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NUM_PROCESSES');
    g_num_active_procs     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NUM_ACTIVE_PROCS');
    g_num_completed_procs  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NUM_COMPLETED_PROCS');
    g_num_notstarted_procs := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NUM_NOT_STARTED_PROCS');
    g_num_tasks := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NUM_TASKS');

    g_details     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_DETAILS');
    g_selected    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PRDSLCT');
    g_back_top    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_BACK_TOP');
    g_hierarchy   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PH');
    g_ctxt_type   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CTXTYPE');
    g_ctxt_name   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CTXTNAME');
    g_user        := FND_MESSAGE.get_string('AZ', 'AZW_RPT_USER');
    g_duration    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_XTIME');
    g_start       := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STARTDATE');
    g_from        := FND_MESSAGE.get_string('AZ', 'AZW_RPT_FROM');
    g_to          := FND_MESSAGE.get_string('AZ', 'AZW_RPT_TO');
    g_active_by   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_ACTIVE_BY');
    g_end         := FND_MESSAGE.get_string('AZ', 'AZW_RPT_ENDDATE');
    g_days        := FND_MESSAGE.get_string('AZ', 'AZW_RPT_DAYS');
    g_all         := FND_MESSAGE.get_string('AZ', 'AZW_RPT_ALL');
    g_description := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PRO_DESC');
    g_comments    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_COMMTS');

    g_atmost      := get_translation('AZ_REPORT_DURATION_RANGE', '<=');
    g_atleast     := get_translation('AZ_REPORT_DURATION_RANGE', '>=');

    g_welcome_msg := FND_MESSAGE.get_string('AZ', 'AZW_RPT_WELCOME');
    g_ipr_msg     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_IPR_INTRO');
    g_cpr_msg     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CPR_INTRO');
    g_ppr_msg     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PPR_INTRO');
    g_isr_msg     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_ISR_INTRO');
    g_upr_msg     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_UPR_INTRO');

    g_param_hdr	  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PARAM');
    g_param_note  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PARAM_NOTE');
    g_mn_menu := FND_MESSAGE.get_string('AZ', 'AZW_RPT_MAIN_MENU');
    g_exit        := FND_MESSAGE.get_string('AZ', 'AZW_RPT_EXIT');
    g_help        := FND_MESSAGE.get_string('AZ', 'AZW_RPT_HLP');
    g_ipr_desc    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_IPR_DESC');
    g_cpr_desc    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CPR_DESC');
    g_ppr_desc    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PPR_DESC');
    g_isr_desc    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_ISR_DESC');
    g_upr_desc    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_UPR_DESC');
    g_ok_hlp	  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_OK_HLP');
    g_cancel_hlp  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_CANCEL_HLP');

    g_js_slct_prd 	   := FND_MESSAGE.get_string('AZ',
    					'AZW_RPT_JS_SLCT_PRD_MSG');
    g_js_slct_time_elapsed := FND_MESSAGE.get_string('AZ',
    					'AZW_RPT_JS_TIME_ELAPSED_MSG');

    v_locator := 3;
    SELECT meaning
    INTO   g_mode_label
    FROM   fnd_lookups
    WHERE  lookup_type = 'AZ_PROCESS_TYPE'
    AND    lookup_code = g_current_mode;

    g_no_prod_inst := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NO_PROD_INSTALLED');
    g_no_prod_sel := FND_MESSAGE.get_string('AZ', 'AZW_RPT_NO_PROD_SELECTED');

    g_report_legend  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_LEGEND');
    g_group_legend   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_GROUP_LEGEND');
    g_subgrp_legend  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_SUBGRP_LEGEND');
    g_process_legend := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PROCESS_LEGEND');
    g_task_legend    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_TASK_LEGEND');

    g_task_details   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_TSK_DETAIL');
    g_step_name	     := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STEP_NAME');
    g_step_response  := FND_MESSAGE.get_string('AZ', 'AZW_RPT_RESPONSE');

    g_task_params    := FND_MESSAGE.get_string('AZ', 'AZW_RPT_TSK_PRMTRS');

    g_step_details   := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STP_DETAIL');
    g_process        := FND_MESSAGE.get_string('AZ', 'AZW_RPT_PROCESS');
    g_steps          := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STEPS');
    g_step_msg       := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STP_MSG');

    g_step_all_procs := FND_MESSAGE.get_string('AZ', 'AZW_RPT_STP_ALL_PROCS');

    g_dateformat_msg := FND_MESSAGE.get_string('AZ', 'AZW_RPT_DATEFORMAT_MSG');

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_TRANSLATED_LABELS', 'v_locator := ' || v_locator);
  END get_translated_labels;

  /*------------------------------------------------------------------------
   * GET_USER_TREES_BY_ATLEAST
   *
   * Private procedure.  Called by user_report.
   * Populate the hierarchies based on the selected criteria into the
   * intermediate table.  Performs the following steps:
   *   1. If no status is chosen, get tasks, processes, and groups for both
   *      Active and Completed statuses based on the 'at least' duration search
   *      criterion into the intermediate table.
   *   2. Otherwise, get tasks, processes, and groups for the particular status
   *      based on the 'at least' duration search criterion into
   *      the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_user_trees_by_atleast(p_user       IN VARCHAR2,
                                      p_status     IN VARCHAR2,
                                      p_duration   IN NUMBER)
                                      IS

                      /* cursors for at least case with one status (A or C) */

    CURSOR atleast_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  atv.assigned_user = p_user
      AND    atv.status = p_status
      AND    atv.duration >= p_duration
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    atv.context_id = apv.context_id
      AND    apv.process_type = g_current_mode;

    CURSOR atleast_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             apv.context_type_name,
             apv.context_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.parent_id = ag.group_id
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = g_current_mode
      AND    EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE apv.context_id = atv.context_id
             AND   apv.item_type = atv.item_type
             AND   apv.process_name = atv.root_activity
	     AND   atv.assigned_user = p_user
	     AND   atv.status = p_status
	     AND   atv.duration >= p_duration);

    CURSOR atleast_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE apv.item_type = atv.item_type
	     AND   apv.process_name = atv.root_activity
	     AND   apv.context_id = atv.context_id
	     AND   atv.status = p_status
	     AND   atv.assigned_user = p_user
	     AND   atv.duration >= p_duration
	     AND   apv.process_type = g_current_mode);

                   /* cursors for at least case with both statuses (A and C) */

    CURSOR atleast_both_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM az_tasks_v atv,
           az_processes_all_v apv
      WHERE atv.assigned_user = p_user
      AND   atv.duration >= p_duration
      AND   atv.item_type = apv.item_type
      AND   atv.root_activity = apv.process_name
      AND   atv.context_id = apv.context_id
      AND    apv.process_type = g_current_mode;

    CURSOR atleast_both_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             apv.context_type_name,
             apv.context_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.parent_id = ag.group_id
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = g_current_mode
      AND    EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    atv.duration >= p_duration);

    CURSOR atleast_both_parents_cursor IS
     SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE apv.item_type = atv.item_type
             AND   apv.process_name = atv.root_activity
             AND   apv.context_id = atv.context_id
             AND   atv.assigned_user = p_user
             AND   atv.duration >= p_duration
             AND   apv.process_type = g_current_mode);

    v_status 	fnd_lookups.meaning%TYPE;
    v_locator	PLS_INTEGER := 0;

  BEGIN
    IF (p_status IS NOT NULL) THEN                /* with one status, A or C */
      -- get tasks
      v_locator := 1;
      FOR one_task IN atleast_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, p_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration, NULL);
      END LOOP;
      -- get processes
      v_status := get_translation('AZ_PROCESS_STATUS', p_status);
      v_locator := 2;
      FOR one_proc IN atleast_processes_cursor LOOP
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, p_user, 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);
      END LOOP;
      -- start recursive search for group parents
      v_locator := 3;
      FOR one_proc IN atleast_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, p_user);
      END LOOP;

    ELSE                      /* p_status is null, for both A and C statuses */
      v_locator := 4;
      -- get tasks
      FOR one_task IN atleast_both_tasks_cursor LOOP
        v_status:=get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, p_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration,NULL);
      END LOOP;
      v_locator := 5;
      -- get processes
      FOR one_proc IN atleast_both_processes_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_proc.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, p_user, 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);
      END LOOP;
      v_locator := 6;
      -- start recursive search for group parents
      FOR one_proc IN atleast_both_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, p_user);
      END LOOP;
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_USER_TREES_BY_ATLEAST', 'v_locator := ' || v_locator);
  END get_user_trees_by_atleast;

  /*------------------------------------------------------------------------
   * GET_USER_TREES_BY_ATMOST
   *
   * Private procedure.  Called by user_report.
   * Populate the hierarchies based on the selected criteria into the
   * intermediate table.  Performs the following steps:
   *   1. If no status is chosen, get tasks, processes, and groups for both
   *      Active and Completed statuses based on the 'at most' duration search
   *      criterion into the intermediate table.
   *   2. Otherwise, get tasks, processes, and groups for the particular status
   *      based on the 'at most' duration search criterion into
   *      the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_user_trees_by_atmost(p_user       IN VARCHAR2,
                                     p_status     IN VARCHAR2,
                                     p_duration   IN NUMBER)
                                     IS

                       /* cursors for at most case with one status (A or C) */

    CURSOR atmost_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  atv.assigned_user = p_user
      AND    atv.status = p_status
      AND    atv.duration <= p_duration
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    atv.context_id = apv.context_id
      AND    apv.process_type = g_current_mode;

    CURSOR atmost_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             apv.context_type_name,
             apv.context_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.parent_id = ag.group_id
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = apv.process_type
      AND    EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    atv.status = p_status
	     AND    atv.duration <= p_duration);

    CURSOR atmost_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.status = p_status
	     AND    atv.assigned_user = p_user
	     AND    atv.duration <= p_duration
	     AND    apv.process_type = g_current_mode);

                   /* cursors for at most case with both statuses (A and C) */

    CURSOR atmost_both_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.assigned_user,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  atv.assigned_user = p_user
      AND    atv.duration <= p_duration
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    atv.context_id = apv.context_id
      AND    apv.process_type = g_current_mode;

    CURSOR atmost_both_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             apv.context_type_name,
             apv.context_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.parent_id = ag.group_id
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = apv.process_type
      AND    EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    atv.duration <= p_duration);

    CURSOR atmost_both_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    atv.duration <= p_duration
	     AND    apv.process_type = g_current_mode);

    v_status 	fnd_lookups.meaning%TYPE;
    v_locator	PLS_INTEGER := 0;
  BEGIN

    IF (p_status IS NOT NULL) THEN                /* with one status, A or C */
      -- get tasks
      v_locator := 1;
      FOR one_task IN atmost_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
         (one_task.node_id, p_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration,NULL);
      END LOOP;
      v_locator := 2;
      -- get processes
      v_status := get_translation('AZ_PROCESS_STATUS', p_status);
      FOR one_proc IN atmost_processes_cursor LOOP
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, p_user, 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);
      END LOOP;
      v_locator := 3;
      -- start recursive search for group parents
      FOR one_proc IN atmost_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, p_user);
      END LOOP;

    ELSE                      /* p_status is null, for both A and C statuses */
      v_locator := 4;
      -- get tasks
        FOR one_task IN atmost_both_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, p_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration,NULL);
      END LOOP;
      v_locator := 5;
      -- get processes
      FOR one_proc IN atmost_both_processes_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_proc.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, p_user, 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '',one_proc.comments);
      END LOOP;
      v_locator := 6;
      -- start recursive search for group parents
      FOR one_proc IN atmost_both_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, p_user);
      END LOOP;
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_USER_TREES_BY_ATMOST', 'v_locator := ' || v_locator);
  END get_user_trees_by_atmost;

  /*------------------------------------------------------------------------
   * GET_USER_TREES_BY_PERIOD
   *
   * Private procedure.  Called by user_report.
   * Populate the hierarchies based on the selected criteria into the
   * intermediate table.  Performs the following steps:
   *   1. If no status is chosen, get tasks, processes, and groups for both
   *      Active and Completed statuses based on the start and end period into
   *      the intermediate table.
   *   2. Otherwise, get tasks, processes, and groups for the particular status
   *      based on the start and end period into the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_user_trees_by_period(p_user       IN VARCHAR2,
                                     p_status     IN VARCHAR2,
                                     p_startdate  IN DATE,
                                     p_enddate    IN DATE)
                                     IS

                         /* cursors for period case with one status (A or C) */

    CURSOR period_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  atv.assigned_user = p_user
      AND    atv.status = p_status
      AND    ((atv.begin_date >= p_startdate AND atv.begin_date <= p_enddate)
      OR      (atv.end_date >= p_startdate AND atv.end_date <= p_enddate)
      OR      (atv.begin_date <= p_startdate AND
              (atv.end_date >= p_enddate OR atv.end_date IS NULL)))
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    atv.context_id = apv.context_id
      AND    apv.process_type = g_current_mode;

    CURSOR period_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             apv.context_type_name,
             apv.context_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.parent_id = ag.group_id
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = apv.process_type
      AND    EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    atv.status = p_status
	     AND    ((atv.begin_date >= p_startdate AND atv.begin_date <= p_enddate)
	     OR      (atv.end_date >= p_startdate AND atv.end_date <= p_enddate)
	     OR      (atv.begin_date <= p_startdate AND
                     (atv.end_date >= p_enddate OR atv.end_date IS NULL))));

    CURSOR period_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.status = p_status
	     AND    atv.assigned_user = p_user
	     AND    ((atv.begin_date >= p_startdate AND atv.begin_date <= p_enddate)
	     OR      (atv.end_date >= p_startdate AND atv.end_date <= p_enddate)
	     OR      (atv.begin_date <= p_startdate AND
                     (atv.end_date >= p_enddate OR atv.end_date IS NULL)))
	     AND    apv.process_type = g_current_mode);

                     /* cursors for period case with both statuses (A and C) */

    CURSOR period_both_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
             apv.context_type_name,
             atv.context_name,
             TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id,
             atv.status,
             atv.begin_date,
             atv.end_date,
             atv.duration
      FROM   az_tasks_v atv,
             az_processes_all_v apv
      WHERE  atv.assigned_user = p_user
      AND    ((atv.begin_date >= p_startdate AND atv.begin_date <= p_enddate)
      OR      (atv.end_date >= p_startdate AND atv.end_date <= p_enddate)
      OR      (atv.begin_date <= p_startdate AND
              (atv.end_date >= p_enddate OR atv.end_date IS NULL)))
      AND    atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    atv.context_id = apv.context_id
      AND    apv.process_type = g_current_mode;

    CURSOR period_both_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id,
             apv.display_name,
             apv.context_type_name,
             apv.context_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id
               parent_node_id,
             apv.status,
             apv.comments
      FROM   az_processes_all_v apv,
     	     az_groups ag
      WHERE  apv.parent_id = ag.group_id
      AND    apv.process_type = g_current_mode
      AND    ag.process_type = apv.process_type
      AND    EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    ((atv.begin_date >= p_startdate AND atv.begin_date <= p_enddate)
	     OR      (atv.end_date >= p_startdate AND atv.end_date <= p_enddate)
	     OR      (atv.begin_date <= p_startdate AND
                     (atv.end_date >= p_enddate OR atv.end_date IS NULL))));

    CURSOR period_both_parents_cursor IS
      SELECT DISTINCT apv.parent_id
      FROM   az_processes_all_v apv
      WHERE  EXISTS(
             SELECT 1
             FROM   az_tasks_v atv
             WHERE  apv.item_type = atv.item_type
	     AND    apv.process_name = atv.root_activity
	     AND    apv.context_id = atv.context_id
	     AND    atv.assigned_user = p_user
	     AND    ((atv.begin_date >= p_startdate AND atv.begin_date <= p_enddate)
	     OR      (atv.end_date >= p_startdate AND atv.end_date <= p_enddate)
	     OR      (atv.begin_date <= p_startdate AND
                      (atv.end_date >= p_enddate OR atv.end_date IS NULL)))
	     AND    apv.process_type = g_current_mode);

    v_status 	fnd_lookups.meaning%TYPE;
    v_locator	PLS_INTEGER := 0;
  BEGIN
/*
dbms_output.enable(1000000);
dbms_output.put_line('p_startdate=[' || p_startdate || ']');
dbms_output.put_line('p_enddate=[' || p_enddate || ']');
*/
    IF (p_status IS NOT NULL) THEN                        /* for one status  */
      v_locator := 1;
      -- get tasks
      FOR one_task IN period_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, p_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration,NULL);
      END LOOP;
      v_locator := 2;
      -- get processes
      v_status := get_translation('AZ_PROCESS_STATUS', p_status);
      FOR one_proc IN period_processes_cursor LOOP
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, p_user, 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);
      END LOOP;
      v_locator := 3;
      -- start recursive search for group parents
      FOR one_proc IN period_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, p_user);
      END LOOP;

    ELSE                              /* p_status is null, for both statuses */
      v_locator := 4;
      -- get tasks
      FOR one_task IN period_both_tasks_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_task.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_task.node_id, p_user, 'T', '',
         one_task.context_type_name, one_task.context_name,
         one_task.parent_node_id, v_status, one_task.begin_date,
         one_task.end_date, one_task.duration, NULL);
      END LOOP;
      v_locator := 5;
      -- get processes
      FOR one_proc IN period_both_processes_cursor LOOP
        v_status := get_translation('AZ_PROCESS_STATUS', one_proc.status);
      INSERT INTO az_monitor_reports
       (NODE_ID, ASSIGNED_USER, NODE_TYPE, DISPLAY_NAME,
         CONTEXT_TYPE_NAME, CONTEXT_NAME, PARENT_NODE_ID,
          STATUS_CODE_NAME, START_DATE, END_DATE, DURATION, COMMENTS)
      VALUES
        (one_proc.node_id, p_user, 'P', one_proc.display_name,
         one_proc.context_type_name, one_proc.context_name,
         one_proc.parent_node_id, v_status, '', '', '', one_proc.comments);
      END LOOP;
      v_locator := 6;
      -- start recursive search for group parents
      FOR one_proc IN period_both_parents_cursor LOOP
        get_monitor_group_parent(one_proc.parent_id, p_user);
      END LOOP;
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_USER_TREES_BY_PERIOD', 'v_locator := ' || v_locator);
  END get_user_trees_by_period;

  /*------------------------------------------------------------------------
   * GET_WEB_AGENT
   *
   * Private procedure.
   * Retrieve the value for fnd profile option 'WEB_APPS_AGENT', the string
   * represents the URL for the host server.
   *-----------------------------------------------------------------------*/
  PROCEDURE get_web_agent IS
    v_slash NUMBER;
    v_len   NUMBER;

  BEGIN
    FND_PROFILE.get('APPS_WEB_AGENT', g_web_agent);
    --
    -- checking the slash at the end
    --
    v_len := LENGTH(g_web_agent);
    v_slash := INSTR(g_web_agent, '/', -1, 1);
    IF (v_slash <> v_len) THEN
      g_web_agent := g_web_agent || '/';
    END IF;

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_WEB_AGENT', '');
  END get_web_agent;

/*
**
**	GET_PROCESS_TYPE_KEY
**	====================
**
**	The node id specified in the az_planning_reports temp
**	table is composed of multiple fields. two of them are
**	the item_type and process name fields.
**	this procedure extracts and returns these two fields
**	from the input node_id.
**
*/
PROCEDURE get_process_type_name (p_node_id   IN VARCHAR2,
			     p_item_type OUT VARCHAR2,
			     p_process_name  OUT VARCHAR2) IS

  start_pos 	PLS_INTEGER;
  end_pos	PLS_INTEGER;

BEGIN

  start_pos := INSTR(p_node_id, '.', 1) + 1;
  end_pos := INSTR(p_node_id, '.', start_pos);
  p_item_type := TRIM(SUBSTR(p_node_id, start_pos, (end_pos - start_pos)));
  p_process_name := TRIM(SUBSTR(p_node_id, (INSTR(p_node_id, '.', -1) + 1)));

 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_PROCESS_TYPE_NAME', '');
END get_process_type_name;

  /*------------------------------------------------------------------------
   * IMPLEMENTATION_PARAM_PAGE
   *
   * Public procedure.
   * Generates parameter entry page in HTML for the implememtation process
   * report. Performs the following steps:
   *   1. Get the URL for host server and all display strings if the URL is
   *      null.
   *   2. Print the title and the instruction as the header.
   *   3. Display all the valid phases in a drop down list, making blank as
   *      the default, meaning for all phases.
   *   4. Print the OK and Cancel buttons as the footer. OK button calls the
   *      implementation report and passes the user selected phase; Cancel
   *      button calls the starting welcome page.
   *-----------------------------------------------------------------------*/
  PROCEDURE implementation_param_page IS

    CURSOR valid_phases_cursor IS
      SELECT   DISTINCT phase
      FROM     az_product_phases_v
      ORDER BY phase;

  BEGIN
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    g_help_target := get_report_procedure ('AZW_RPT_IPR');

    print_param_page_header (g_ipr, g_ipr_msg, NULL);

    htp.p('<table align="center" border="0" cellpadding="0" ' ||
		    'cellspacing="2" width="96%">');
    htp.p('<tr><td colspan=4><br></td>');
    htp.p('<form name="Form1" method="post" ' ||
    		'action="azw_report.implementation_report"></tr>');
    htp.p('<tr><td align=right width="50%"><font class=normal>' ||
    			g_phase || '</font></td>');
    --
    -- create the pop-up list of phase values
    --
    htp.p('<td align=left colspan=3><select name="p_phase" size=1>');
    -- by default the blank choice means selecting all phases
    htp.p('<option value="">'|| g_all ||'</option>');

    FOR one_phase IN valid_phases_cursor LOOP
      htp.p('<option value"'|| one_phase.phase ||'">'|| one_phase.phase ||
            '</option>');
    END LOOP;
    htp.p('</select></td></tr>');

    print_param_page_footer;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'IMPLEMENTATION_PARAM_PAGE', '');
  END implementation_param_page;

  /*------------------------------------------------------------------------
   * IMPLEMENTATION_REPORT
   *
   * Public procedure.  Invoked by the OK button in implementation_param_page.
   * Generates the implementation process report in HTML.  It performs the
   * following steps:
   *   1. Get the URL for host server and all display strings if the URL is ''.
   *   2. Print report header and subheader.
   *   4. Print Table opening tag and header based on selected phase.
   *   4. If the parameter is null, get all valid phases, and
   *      a. for each phase, get the processes into the intermediate table.
   *      b. for each phase, retrieve the trees from the intermediate table.
   *         for each row retrieved, print the Table Row and Table Data.
   *   5. If the parameter is not null, get the processes for the specified
   *      phase into the intermediate table, and retrieve the trees from the
   *      intermediate table. For each row retrieved, print the Table Row and
   *      Table Data.
   *   6. Print HTML Table closing tag.
   *   7. Print links to related reports.
   *-----------------------------------------------------------------------*/
  PROCEDURE implementation_report(p_phase IN VARCHAR2) IS
    v_phase      NUMBER;

    CURSOR valid_phases_cursor IS
      SELECT   DISTINCT phase
      FROM     az_product_phases_v
      ORDER BY phase;

    CURSOR hierarchies_cursor(x_phase NUMBER) IS
      SELECT     phase,
                 LPAD(g_blank, g_indent*(LEVEL-1))||display_name hierarchy,
                 node_type,
                 description,
                 node_id,
                 parent_node_id,
                 LEVEL
      FROM       az_planning_reports
      WHERE 	 phase = x_phase
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id
      AND	 PRIOR phase = phase;

      v_count		PLS_INTEGER;
      blnBackToTop	BOOLEAN;
      v_locator	PLS_INTEGER := 0;
  BEGIN
    print_time_stamp('Start the report');
    g_help_target := get_report_procedure('AZW_RPT_IPRR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      print_time_stamp('After getting the APP_WEB_AGENT');
      get_translated_labels;
    END IF;

    print_time_stamp('Start Insert into temp table');
    IF (p_phase IS NULL) THEN
      FOR one IN valid_phases_cursor LOOP
        get_implementation_processes(one.phase);
      END LOOP;
    ELSE
      v_phase := TO_NUMBER(p_phase);
      get_implementation_processes(v_phase);
    END IF;
    print_time_stamp('End Insert into temp table');

    --
    --	Display the report header, date, installed products and it's summary.
    --
    print_report_header (g_ipr, TRUE, 'azw_report.implementation_param_page');
    print_time_stamp('After Displaying table header');
    print_ipr_report_parameters(p_phase);

    print_ipr_installed_products (p_phase);
    print_time_stamp('Start displaying summary');
    print_planning_reports_summary (p_phase);
    print_time_stamp('After displaying summary');

    print_legend_link;

    --
    -- 	Display Report Details
    --
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
	      '<FONT CLASS="tableHeader">'|| g_details ||'</FONT></TD></TR>');
    htp.p('<TR>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
     	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_description ||'</FONT></TH>');

    IF (p_phase IS NULL) THEN                              -- for all phases
      -- print hierarchy for each phase
      v_count := 0;
      blnBackToTop := FALSE;
      FOR one IN valid_phases_cursor LOOP
       IF (v_count > 0) THEN
          blnBackToTop := TRUE;
          print_back_to_top(2);
        END IF;
        htp.p('<TR><TH ALIGN="CENTER" BGCOLOR="#336699"' ||
	       ' COLSPAN="2"><FONT CLASS="tableSubHeader">'|| g_phase
       		|| ' ' || one.phase || '</FONT></TH></TR>');
        v_locator := 1;
        FOR one_node IN hierarchies_cursor(one.phase) LOOP
          IF (one_node.parent_node_id IS NULL) THEN
            IF (v_count > 0 AND NOT blnBackToTop) THEN
              print_back_to_top(2);
            ELSE
              blnBackToTop := FALSE;
            END IF;
            htp.p('<TR><TD ALIGN="LEFT" COLSPAN="2" BGCOLOR="#666666" ' ||
	        'NOWRAP><i><FONT COLOR="#FFFFFF"><A NAME="PH'||
            	one_node.phase || '_' ||
            	one_node.node_id || '">' ||
            	one_node.hierarchy || '</A></FONT></i></TD>');
          ELSIF (one_node.node_type = 'G' ) THEN
           -- htp.tableData(one_node.phase, 'RIGHT');
            htp.tableRowOpen;
            htp.tableData('<i>'|| lpad_nbsp(one_node.level) || one_node.hierarchy
                          ||'</i>', 'LEFT', '', 'NOWRAP');
          ELSE
          --  htp.tableData(one_node.phase, 'RIGHT');
            htp.tableRowOpen;
            htp.tableData('<b>'|| lpad_nbsp(one_node.level) || one_node.hierarchy
                          ||'</b>', 'LEFT', '', 'NOWRAP');
            htp.tableData(one_node.description);
          END IF;
          htp.tableRowClose;
	  v_count := v_count + 1;
        END LOOP;
      END LOOP;
    ELSE                    	 -- for one phase
      htp.p('<TR><TH ALIGN="CENTER" BGCOLOR="#336699"' ||
	       ' COLSPAN="2"><FONT CLASS="tableSubHeader">'|| g_phase
       		|| ' ' || v_phase || '</FONT></TH></TR>');
      v_count := 0;
      -- print hierarchy for the phase
      v_locator := 2;
      FOR one_node IN hierarchies_cursor(v_phase) LOOP
        htp.tableRowOpen;
        IF (one_node.parent_node_id IS NULL) THEN
          IF (v_count > 0) THEN
	    print_back_to_top(2);
	  END IF;
     	  htp.p('<TD ALIGN="LEFT" COLSPAN="2" BGCOLOR="#666666" '||
     	  	'NOWRAP><i><FONT COLOR="#FFFFFF"><A NAME="PH'||
            	one_node.phase || '_' ||
            	one_node.node_id || '">' ||
            	one_node.hierarchy ||'</A></FONT></i></TD>');
        ELSIF (one_node.node_type = 'G') THEN
          htp.tableData('<i>'||lpad_nbsp(one_node.level) || one_node.hierarchy
                        || '</i>', 'LEFT', '', 'NOWRAP');
        ELSE
          htp.tableData('<b>'||lpad_nbsp(one_node.level) || one_node.hierarchy
                        || '</b>', 'LEFT', '', 'NOWRAP');
          htp.tableData(one_node.description, 'LEFT', '', 'NOWRAP');
        END IF;
        htp.tableRowClose;
	v_count := v_count +1;
      END LOOP;
    END IF;
    print_back_to_top(2);
    htp.tableClose;
    print_time_stamp('End displaying report details');
    print_legend;
    --
    -- print related report links
    --
    print_related_reports('AZW_RPT_CPR', 'AZW_RPT_PPR');

    COMMIT;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- print Table closing tag
      htp.tableClose;
      print_related_reports('AZW_RPT_CPR', 'AZW_RPT_PPR');
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'IMPLEMENTATION_REPORT', 'v_locator := ' || v_locator);
  END implementation_report;

/*
**
**	PRINT_BACK_TO_TOP
**	=================
**
**	Private Procedure.
**	This procedure prints the back to top row in the report body,
**	which is a link to the top of the report summary.
**
*/
PROCEDURE print_back_to_top (p_col_span IN NUMBER) IS

BEGIN

  htp.p('<TR><TD ALIGN="LEFT" COLSPAN="'|| p_col_span ||'"><A HREF="#TOP">' ||
      '<FONT SIZE="-1">' || g_back_top || '</FONT></A></TD></TR>');

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_BACK_TO_TOP', '');
END print_back_to_top;

/*
**
** 	PRINT_HTML_STYLE
**	================
**
** 	Private procedure.
** 	Print out the HTML style sheet used by the BIS 11i UI standard.
** 	The HTML style is a set of predefined font formats used through
** 	out the reports. This procedure must be called by all the
**	display procedures, to be able to use the predefined fonts.
**
*/
PROCEDURE print_html_style IS

BEGIN
   htp.p('<STYLE type="text/css">');
   htp.p('<!--');

   htp.p('font.button {font-family: arial, sans-serif; ' ||
	   'color: black; text-decoration: none; font-size: 10pt}');
   htp.p('font.disable {font-family: arial, sans-serif; ' ||
   	'color: #666666; text-decoration: none; font-size: 10pt}');
   htp.p('font.tableHeader {font-family: arial, sans-serif; ' ||
   	'font-weight: bold; color: white; ' ||
   	'text-decoration: none; font-size: 10pt}');
   htp.p('font.tableSubHeader {font-family: times new roman; ' ||
   	'font-weight: bold; color: white; ' ||
   	'text-decoration: none; font-size: 10pt}');
   htp.p('font.normal {font-family: arial, sans-serif; ' ||
   	'color: black; font-size: 10pt}');
   htp.p('font.normalLink {font-family: arial, sans-serif; font-size: 10pt}');
   htp.p('font.normalBold {color: black; font-family: arial, ' ||
   	'sans-serif; font-size: 10pt; font-weight: bold}');
   htp.p('font.banner {font-family: arial, sans-serif; font-size: 16pt; ' ||
   	'font-weight: bold; color: white; text-decoration: none}');
   htp.p('font.subtitle {font-family: arial, sans-serif; font-size: 14pt; ' ||
   	'color: black; text-decoration: none}');
   htp.p('font.curOption {font-family: arial, sans-serif; font-size: 10pt; ' ||
   	'color: #666666; text-decoration: none}');
   htp.p('--></STYLE>');

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_HTML_STYLE', '');
END print_html_style;

/*------------------------------------------------------------------------
   * PRINT_CONTEXT_SUBHEADER
   *
   * Private procedure. Called by context_report.
   * Print the context type chosen for the context report.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_context_subheader(p_context IN VARCHAR2) IS

  BEGIN
    htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="96%">');
    htp.p('<TR><TD WIDTH="50%" ALIGN="LEFT">');
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    htp.p('<TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
    htp.p('<TR><TD ALIGN="RIGHT">'|| g_ctxt_type || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>' ||
    		get_translation('AZ_CONTEXT_TYPE', p_context) ||'</B></TD></TR>');
    htp.p('</TABLE>');
    htp.p('</TD><TD WIDTH="50%" ALIGN="RIGHT">');
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    htp.p('<TR><TD ALIGN="RIGHT">' || g_as_of || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>'||
  				FND_DATE.date_to_displayDT(SYSDATE) || '</B></TD></TR>');
    htp.p('<TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
    htp.p('</TABLE>');
    htp.p('</TD>');
    htp.p('</TR>');
    htp.p('</TABLE>');
    htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="98%">');
    htp.p('<TR><TD BGCOLOR="#CCCCCC"><IMG SRC="' || g_image_path ||'/FNDDBPXC.gif"></TD></TR>');
    htp.p('</TABLE>');
    htp.p('  <BR>');

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_CONTEXT_SUBHEADER', '');
  END print_context_subheader;

  /*------------------------------------------------------------------------
   * PRINT_IMP_START_PAGE
   *
   * Private procedure. Called by start page.
   * Print start page for Fresh Implementation.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_imp_start_page IS
      v_link VARCHAR2(240);
  BEGIN

    htp.nl;
    htp.nl;
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=50%>');

    htp.p('<tr><td><table border=0 cellspacing=0 cellpadding=0 width=80%>');

    -- display hyper-linked reports in group 1
    htp.tableRowOpen;
    htp.p('<td bgcolor="#336699" width=1%><br></td>');
    htp.p('<td bgcolor="#336699" width=90% align="left" NOWRAP>'||
          '<font class="tableheader">'|| g_planning ||'</font></td>');

    htp.p('</tr></table></td></tr>');

    htp.p('<tr><td><font size=-2><BR></font></td></tr>');
    htp.p('<tr><td><table border=0 cellspacing=0 cellpadding=0 width=80%>');

    v_link := get_report_procedure('AZW_RPT_IPR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 '||'alt="'||
          g_ipr_desc ||'"><font face="Arial" size=2><b><a href="'||
          g_web_agent || v_link||'" OnMouseOver="window.status=' ||
    		'''' || g_ipr_desc || '''' || ';return true;">'|| g_ipr ||'</a></b></td></tr>');

    v_link := get_report_procedure('AZW_RPT_PPR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 alt="'||
          g_ppr_desc || '"><font face="Arial" size=2><b><a href="'||
          g_web_agent|| v_link||'" OnMouseOver="window.status=' ||
    		'''' || g_ppr_desc || '''' || ';return true;">'
    		|| g_ppr||'</a></b></td></tr>');

    v_link := get_report_procedure('AZW_RPT_CPR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 alt="'||
          g_cpr_desc || '"><font face="Arial" size=2><b><a href="'||
          g_web_agent|| v_link||'" OnMouseOver="window.status=' ||
    		'''' || g_cpr_desc || '''' || ';return true;">'
    		|| g_cpr||'</a></b></td></tr>');
    htp.p('</td></tr></table></table><small><br></small>');
    htp.p('</td><td valign=TOP height=9></td>');

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=50%>');
    htp.p('<tr><td><table border=0 cellspacing=0 cellpadding=0 width=80%>');

    -- display hyper-linked reports in group 2
    htp.tableRowOpen;
    htp.p('<td bgcolor="#336699" width=1%><br></td>');
    htp.p('<td bgcolor="#336699" width=90% align="left" NOWRAP>'||
          '<font class="tableheader">'|| g_monitor ||'</font></td>');
    htp.p('</tr></table></td></tr>');

    htp.p('<tr><td><font size=-2><BR></font></td></tr>');
    htp.p('<tr><td><table border=0 cellspacing=0 cellpadding=0 width=80%>');

    v_link := get_report_procedure('AZW_RPT_ISR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 alt="'||
          g_isr_desc || '"><font face="Arial" size=2><b><a href="'||
          g_web_agent|| v_link||'" OnMouseOver="window.status=' ||
    		'''' || g_isr_desc || '''' || ';return true;">'
          ||g_isr||' (' || g_mode_label || ')'||'</a></b></td></tr>');

    v_link := get_report_procedure('AZW_RPT_UPR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 alt="'||
          g_upr_desc || '"><font face="Arial" size=2><b><a href="'||
          g_web_agent|| v_link||'"  OnMouseOver="window.status=' ||
    		'''' || g_upr_desc || '''' || ';return true;">'
          ||g_upr||' (' || g_mode_label || ')'||'</a></b></td></tr>');

    htp.p('</td>');
    htp.p('</td></tr></table><small><br></small>');
    htp.p('</td>');

    htp.tableClose;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_IMP_START_PAGE', '');
  END print_imp_start_page;
  /*------------------------------------------------------------------------
   * PRINT_UPGRADE_START_PAGE
   *
   * Private procedure. Called by start page.
   * Print start page for Upgrade Implementation.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_upgrade_start_page IS
    v_link VARCHAR2(240);
  BEGIN

    htp.nl;
    htp.nl;
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=50%>');

    htp.p('<tr><td><table border=0 cellspacing=0 cellpadding=0 width=80%>');

    -- display hyper-linked reports in group 2

    htp.tableRowOpen;
    htp.p('<td bgcolor="#336699" width=1%><br></td>');
    htp.p('<td bgcolor="#336699" width=90% align="left" NOWRAP>'||
          '<font class="tableheader">'|| g_monitor ||'</font></td>');
    htp.p('</tr></table></td></tr>');

    htp.p('<tr><td><font size=-2><BR></font></td></tr>');
    htp.p('<tr><td><table border=0 cellspacing=0 cellpadding=0 width=80%>');

    v_link := get_report_procedure('AZW_RPT_ISR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 alt="'||
          g_isr_desc ||'"><font face="Arial" size=2><b><a href="'||
          g_web_agent||  v_link||'" OnMouseOver="window.status=' ||
    		'''' || g_isr_desc || '''' || ';return true;">'
          ||g_isr||' (' || g_mode_label || ')'||'</a></b></td></tr>');

    v_link := get_report_procedure('AZW_RPT_UPR');
    htp.p('<tr><td align="left" valign="middle" NOWRAP>'||
          '<image src=/OA_MEDIA/FNDWATHS.gif height=18 width=18 alt="'||
          g_upr_desc ||'"><font face="Arial" size=2><b><a href="'||
          g_web_agent|| v_link||'" OnMouseOver="window.status=' ||
    		'''' || g_upr_desc || '''' || ';return true;">'
          ||g_upr||' (' || g_mode_label || ')'||'</a></b></td></tr>');

    htp.p('</td>');
    htp.p('</td></tr></table><small><br></small>');
    htp.p('</td>');

    htp.tableClose;
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_UPGRADE_START_PAGE', '');
  END print_upgrade_start_page;

/*
**
**	PRINT_IPR_SREPORT_PARAMETERS
**	============================
**
** 	Private Procedure.
**	It displays the date and time stamp at the upper right corner of
**	the report and the selected phase parameter at the left.
**
*/
PROCEDURE print_ipr_report_parameters (p_phase IN VARCHAR2) IS

BEGIN
  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="96%">');
  htp.p('<TR>');
  htp.p('    <TD WIDTH="50%" ALIGN="LEFT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        <TR><TD ALIGN="RIGHT">'|| g_phase || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>');
     IF (p_phase IS NOT NULL) THEN
      htp.p(p_phase);
    ELSE
      htp.p(g_all);
    END IF;
  htp.p('</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD><TD WIDTH="50%" ALIGN="RIGHT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">' || g_as_of || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>'||
  				FND_DATE.date_to_displayDT(SYSDATE) || '</B></TD></TR>');
  htp.p('        <TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD>');
  htp.p('</TR>');
  htp.p('</TABLE>');
  htp.p('');
  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="98%">');
  htp.p('<TR><TD BGCOLOR="#CCCCCC"><IMG SRC="'|| g_image_path ||'/FNDDBPXC.gif"></TD></TR>');
  htp.p('</TABLE>');
  htp.p('  <BR>');

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_IPR_SREPORT_PARAMETERS', '');
END print_ipr_report_parameters;

/*
**
**	PRINT_IPR_INSTALLED_PRODUCTS
**	============================
**
**	Private Procedure.
**	It displays the installed products table for the implementaion report.
**	It is called from implementation_report.
*/
PROCEDURE print_ipr_installed_products (p_phase IN VARCHAR2) IS

  CURSOR all_phases IS
     	SELECT DISTINCT appv.phase,
	    		appv.application_short_name short_name,
		       	appv.application_name name
	FROM      az_product_phases_v appv
      	ORDER BY 1, 3;

  CURSOR per_phase(x_phase NUMBER) IS
	SELECT DISTINCT appv.phase,
	    		appv.application_short_name short_name,
		       	appv.application_name name
	FROM      az_product_phases_v appv
      	WHERE    appv.phase = x_phase
      	ORDER BY 1, 3;

  product_rec 	all_phases%ROWTYPE;
  v_prev_phase	az_product_phases_v.phase%TYPE;
  v_count	PLS_INTEGER;
  v_locator	PLS_INTEGER := 0;
BEGIN
  -- Print the Table header
  htp.p('<TABLE ALIGN="center" BORDER="1" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
  	'<FONT CLASS="tableHeader">'|| g_installed ||'</FONT></TD></TR>');

  -- open the correspondig cursor according to the p_phase argument.
  IF (p_phase IS NULL) THEN
    v_locator := 1;
    OPEN all_phases;
  ELSE
    v_locator := 2;
    OPEN per_phase(p_phase);
  END IF;

  v_prev_phase := 0;
  v_count := 0;
  LOOP
    IF (p_phase IS NULL) THEN
      v_locator := 3;
      FETCH all_phases INTO product_rec;
      EXIT WHEN all_phases%NOTFOUND;
    ELSE
      v_locator := 4;
      FETCH per_phase INTO product_rec;
      EXIT WHEN per_phase%NOTFOUND;
    END IF;
    -- If there is a new phase record
    IF (v_count = 0 OR v_prev_phase <> product_rec.phase) THEN
      IF (v_count > 0 AND MOD(v_count, 2) = 1) THEN
        -- display an empty table data and close
        -- both table data and table row
        htp.p('<TD>&nbsp;</TD></TR>');
        v_count := v_count + 1;
      END IF;
      -- Display the phase number header.
      htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
      		'<FONT CLASS="tableSubHeader"> '|| g_phase || ' ' ||
      			product_rec.phase ||'</FONT></TD></TR>');
      -- Display the product name in the first column
      htp.p('<TR><TD>'|| product_rec.name ||'</TD>');
    ELSE
      IF (MOD(v_count, 2) = 0) THEN	-- if v_count is even then new record for the same phase
        -- Display the product name in the first column
        htp.p('<TR><TD>'|| product_rec.name ||'</TD>');
      ELSE
        -- Display the product name in the Second column
        htp.p('<TD>'|| product_rec.name ||'</TD></TR>');
      END IF;
    END IF;
    v_count := v_count + 1;
    v_prev_phase := product_rec.phase;
  END LOOP;
  IF (p_phase IS NULL) THEN
    v_locator := 5;
    CLOSE all_phases;
  ELSE
   v_locator := 6;
    CLOSE per_phase;
  END IF;
  IF (v_count > 0 AND MOD(v_count, 2) = 1) THEN
    htp.p('<TD>&nbsp;</TD></TR>');
  END IF;
  -- If there are no products installed
  IF (v_count = 0) THEN
    htp.p('<TR><TD COLSPAN="2"><i>' || g_no_prod_inst || '</i></TD></TR>');
  END IF;
  htp.p('</TABLE><BR>');
  return;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_IPR_INSTALLED_PRODUCTS', 'v_locator := ' || v_locator);
END print_ipr_installed_products;

/*
**
**	PRINT_PLANNING_REPORTS_SUMMARY
**	==============================
**
**	Private Procedure.
**	It displays the report summary which contains the total number
**	of installed processes for each process group.
**
*/
PROCEDURE print_planning_reports_summary (p_phase IN VARCHAR2) IS

  process_groups PlanProcessGroups;

  v_prev_phase		az_product_phases_v.phase%TYPE;
  v_count		PLS_INTEGER;
  v_display_data	VARCHAR2(500);
  v_locator		PLS_INTEGER := 0;
BEGIN
  -- Print the Table header

  htp.p('<TABLE ALIGN="center" BORDER="1" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="4">' ||
  	'<FONT CLASS="tableHeader"><A NAME="TOP">' ||
  		g_summary ||'</A></FONT></TD></TR>');
  htp.p('<TR>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_process_group ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_num_procs ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_process_group ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_num_procs ||'</FONT></TD>');
  htp.p('</TR>');

  --
  -- Select the report summary data and populate the array with it.
  --
  v_locator := 1;
  populate_process_groups_array (p_phase, process_groups);

  v_prev_phase := 0;
  v_count := 0;
  v_locator := 2;
  FOR i IN 1..process_groups.COUNT LOOP
    v_display_data := '<A HREF="#PH'||
    		process_groups(i).phase || '_' ||
    		process_groups(i).node_id || '">'||
    		process_groups(i).display_name || '</A>';
    -- If there is a new phase record
    IF (v_count = 0 OR v_prev_phase <> process_groups(i).phase) THEN
      IF (v_count > 0 AND MOD(v_count, 2) = 1) THEN
        -- display an empty table data and close
        -- both table data and table row
        htp.p('<TD>&nbsp;</TD><TD>&nbsp;</TD></TR>');
        v_count := v_count + 1;
      END IF;
      IF (process_groups(i).phase > 0) THEN
        -- Display the phase number header.
        htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="4">' ||
	      	'<FONT CLASS="tableSubHeader">' || g_phase || ' ' ||
      		process_groups(i).phase || '</FONT></TD></TR>');
      END IF;
      -- Display the product name in the first column
      htp.p('<TR><TD>'|| v_display_data ||'</TD>' ||
      	'<TD ALIGN="CENTER">'|| process_groups(i).processes_count || '</TD>');
    ELSE
      -- if v_count is even then new record for the same phase
      IF (MOD(v_count, 2) = 0) THEN
        -- Display the product name in the first column
        htp.p('<TR><TD>'|| v_display_data ||'</TD><TD ALIGN="CENTER">'
        	|| process_groups(i).processes_count ||'</TD>');
      ELSE
        -- Display the product name in the Second column
        htp.p('<TD>'|| v_display_data || '</TD><TD ALIGN="CENTER">'||
        	process_groups(i).processes_count ||'</TD></TR>');
      END IF;
    END IF;
    v_count := v_count + 1;
    v_prev_phase := process_groups(i).phase;
  END LOOP;
  -- if v_count is odd then we need to close with an empty table data
  IF (MOD(v_count, 2) = 1) THEN
    htp.p('<TD>&nbsp;</TD><TD>&nbsp;</TD></TR>');
  END IF;
  htp.p('</TABLE><BR>');
  return;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_PLANNING_REPORTS_SUMMARY', 'v_locator := ' || v_locator);
END print_planning_reports_summary;

/*
**
**	POPULATE_PROCESS_GROUPS_ARRAY
**	=============================
**
** 	Private procedure.
**	This procedure is responsible for selecting the available Process Groups,
**	counts the number of processes available for each and  populates the
**	passed array with the data to be used by the calling function
**	(print_planning_reports_summary).
**
*/
PROCEDURE populate_process_groups_array (
				p_phase IN NUMBER,
				process_groups IN OUT NOCOPY PlanProcessGroups) IS

  CURSOR all_phases IS
	SELECT  phase,
		display_name,
		node_type,
		parent_node_id,
		node_id
	FROM       az_planning_reports
	START WITH parent_node_id IS NULL
	CONNECT BY PRIOR node_id = parent_node_id
	AND	 PRIOR phase = phase;

  CURSOR per_phase(x_phase NUMBER) IS
	SELECT  phase,
		display_name,
		node_type,
		parent_node_id,
		node_id
	FROM	az_planning_reports
	WHERE 	phase = x_phase
	START WITH parent_node_id IS NULL
	CONNECT BY PRIOR node_id = parent_node_id
	AND	 PRIOR phase = phase;

  product_rec 	all_phases%ROWTYPE;
  v_count 	PLS_INTEGER;
  v_proc_count	PLS_INTEGER;
  v_locator	PLS_INTEGER := 0;
BEGIN
  --
  --	Select all the upper limit parents and poulate the array.
  --
  -- open the corresponding cursor according to the p_phase argument.

  v_count := 1;
  v_proc_count := 0;
  IF (p_phase IS NULL) THEN
    v_locator := 1;
    OPEN all_phases;
  ELSE
    v_locator := 2;
    OPEN per_phase(p_phase);
  END IF;
  LOOP
    IF (p_phase IS NULL) THEN
      v_locator := 3;
      FETCH all_phases INTO product_rec;
      EXIT WHEN all_phases%NOTFOUND;
    ELSE
      v_locator := 4;
      FETCH per_phase INTO product_rec;
      EXIT WHEN per_phase%NOTFOUND;
    END IF;

    IF (product_rec.parent_node_id IS NULL) THEN	-- upper parent group
      process_groups(v_count).phase := product_rec.phase;
      process_groups(v_count).display_name := product_rec.display_name;
      process_groups(v_count).node_id := product_rec.node_id;
      process_groups(v_count).processes_count := 0;
      IF (v_count > 1) THEN
        process_groups(v_count-1).processes_count := v_proc_count;
      END IF;
      v_proc_count := 0;	-- reset it for the next process group.
      v_count := v_count + 1;
    ELSIF (product_rec.node_type = 'P') THEN
      v_proc_count := v_proc_count + 1;
    END IF;
  END LOOP;
  --
  -- Check if the last record is a process
  --
  v_locator := 5;
  IF (product_rec.node_type = 'P') THEN
    process_groups(v_count-1).processes_count := v_proc_count;
  END IF;

  IF (p_phase IS NULL) THEN
    v_locator := 6;
    CLOSE all_phases;
  ELSE
    v_locator := 7;
    CLOSE per_phase;
  END IF;
  return;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'POPULATE_PROCESS_GROUPS_ARRAY', 'v_locator := ' || v_locator);
END populate_process_groups_array;

  /*------------------------------------------------------------------------
   * PRINT_PARAM_PAGE_HEADER
   *
   * Private procedure.
   * Given page title and text, generates the header in HTML for the parameter
   * entry page.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_param_page_header(p_title IN VARCHAR2,
                                    p_msg IN VARCHAR2,
                                    p_mode_label IN VARCHAR2 DEFAULT NULL) IS

  BEGIN
--    dbms_output.put_line('print_param_page_header: '||p_title);

    IF (p_mode_label IS NOT NULL) THEN
      print_report_header (p_title || ' (' || p_mode_label || ')', FALSE, NULL);
    ELSE
      print_report_header (p_title, FALSE, NULL);
    END IF;


    htp.p('<table align=center border="0" cellpadding="0" cellspacing="0" ' ||
    		'width="96%">');
    htp.p('<tr><td><br></td></tr>');
    htp.p('<tr><td align=center><font class=subtitle>'||
    		g_param_hdr ||'</font></td></tr>');
    htp.p('<tr><td><br></td></tr>');
    htp.p('<tr><td align=left><font class=normal>'||
		g_param_note ||'</font></td></tr>');
    htp.p('<tr><td><br></td></tr>');
    htp.p('</table>');

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_PARAM_PAGE_HEADER', '');
  END print_param_page_header;

  /*------------------------------------------------------------------------
   * PRINT_PARAM_PAGE_FOOTER
   *
   * Private procedure. Called by xxxx_param_page.
   * prints the OK and Cancel buttons in HTML for the parameter entry page.
   * OK always links to the report; Cancel always returns to the start page.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_param_page_footer IS

  BEGIN
    -- Print the horizontal seperator
    print_footer_separator_line();
    -- Print the ok and cancel buttons
    print_ok_cancel_buttons('javascript:void(document.Form1.submit())');

    htp.p('</form>');
    htp.centerClose;
    htp.bodyClose;
    htp.htmlClose;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_PARAM_PAGE_FOOTER', '');
  END print_param_page_footer;

  /*----------------------------------------------------------------------------
   * PRINT_FOOTER_SEPERATOR_LINE
   *
   * Private procedure.  Called by print_param_page_footer and product_param_page.
   * Displays the thin horizontal line seperating the main param page form its
   * footer.
   *--------------------------------------------------------------------------*/
  PROCEDURE print_footer_separator_line IS

  BEGIN
    htp.p('<tr><td colspan=4><br></td></tr>');
    htp.p('<tr><td colspan=4><br></td></tr>');
    -- light grey single pixel separator line between parameters and buttons
    htp.p('<tr><td bgcolor=#CCCCCC colspan=4>' ||
    	'<img src="'|| g_image_path ||'/FNDDBPXC.gif"></td></tr>');
    htp.p('<tr><td colspan=4><br></td></tr>');
    htp.p('</tr></table>');

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_FOOTER_SEPERATOR_LINE', '');
  END print_footer_separator_line;

  /*----------------------------------------------------------------------------
   * PRINT_OK_CANCEL_BUTTONS
   *
   * Private procedure. Called by print_param_page_footer and product_param_page.
   *
   *---------------------------------------------------------------------------*/
  PROCEDURE print_ok_cancel_buttons(p_ok_action IN VARCHAR2) IS

  BEGIN

    -- Table for the OK and Cancel buttons
    htp.p('<table align=center border=0 cellpadding=0 cellspacing=2 width=96%>');
    htp.p('<tr><td align=right width=370>');
    htp.p('<table align=right border=0 cellpadding=0 cellspacing=0>');
    htp.p('<tr>');
    -- OK button
    htp.p('<td align=right rowspan=5><img src="'|| g_image_path ||'/FNDBRNDL.gif"></td>');
    htp.p('<td bgcolor=#333333><img src="'|| g_image_path ||'/FNDDBPX3.gif"></td>');
    htp.p('<td align=left rowspan=5><img src="'|| g_image_path ||'/FNDBSQRR.gif"></td>');
    htp.p('<td rowspan=5 width=3></td>');
    htp.p('</tr>');
    htp.p('<tr><td bgcolor=#FFFFFF>' ||
    	'<img src="'|| g_image_path ||'/FNDDBPXW.gif"></td></tr>');
    htp.p('<tr><td bgcolor=#CCCCCC height=20 nowrap><a href="'||
    			p_ok_action ||'" OnMouseOver="window.status=' ||
    		'''' || g_ok_hlp || '''' || ';return true;" ' ||
    		'><font class=button>'|| g_ok ||'</font></a></td></tr>');
    htp.p('<tr><td bgcolor=#666666>' ||
    	'<img src="'|| g_image_path ||'/FNDDBPX6.gif"></td></tr>');
    htp.p('<tr><td bgcolor=#333333>' ||
    	'<img src="'|| g_image_path ||'/FNDDBPX3.gif"></td></tr>');
    htp.p('</table></td>');
    htp.p('<td align=left width=400>');
    htp.p('<table align=left border=0 cellpadding=0 cellspacing=0>');
    htp.p('<tr>');
    -- Cancel button
    htp.p('<td align=right rowspan=5>' ||
	    '<img src="'|| g_image_path ||'/FNDBSQRL.gif"></td>');
    htp.p('<td bgcolor=#333333><img src="'|| g_image_path ||'/FNDDBPX3.gif"></td>');
    htp.p('<td align=left rowspan=5>' ||
    	'<img src="'|| g_image_path ||'/FNDBRNDR.gif"></td></tr>');
    htp.p('<tr><td bgcolor=#FFFFFF>' ||
    	'<img src="'|| g_image_path ||'/FNDDBPXW.gif"></td></tr>');
    htp.p('<tr><td bgcolor=#CCCCCC height=20 nowrap>' ||
    	'<a href="javascript:history.back();" ' ||
      'onMouseOver="window.status='||''''|| g_cancel_hlp ||''''||
      ';return true"><font class=button>'|| g_cancel ||'</font></a></td></tr>');
    htp.p('<tr><td bgcolor=#666666>' ||
    		'<img src="'|| g_image_path ||'/FNDDBPX6.gif"></td></tr>');
    htp.p('<tr><td bgcolor=#333333>' ||
    	'<img src="'|| g_image_path ||'/FNDDBPX3.gif"></td></tr>');
    htp.p('</table></td></tr></table>');
    htp.p('<br><br><br><br><br><br>');

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_OK_CANCEL_BUTTONS', '');
  END print_ok_cancel_buttons;

  /*------------------------------------------------------------------------
   * PRINT_PP_JSCRIPTS
   *
   * Private procedure.  Called by product_param_page.
   * the print_pp_jscripts prints the JavaScript functions that are used in
   * the product_parameter_page in order to maintain a comma-delimited list
   * of products that have been selected by the user.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_pp_jscripts IS

  BEGIN
   htp.p('<SCRIPT LANGUAGE=Javascript>');

   htp.p('function determine_checked_boxes()');
   htp.p('{');
   htp.p('   var loop_count = document.forms[0].p_product_count.value');
   htp.p('   document.forms[0].p_product_list.value = "" ');
--   htp.p('   alert("number of installed products = " + loop_count)');
   htp.p(' ');
   htp.p('   for(var i=0; i<loop_count; i++)');
   htp.p('   {');
   htp.p('      if(document.forms[0].elements[i].checked)');
   htp.p('      {');
--   htp.p('         alert("checked box " + i + " = " + ' ||
--		'document.forms[0].elements[i].value)');
   htp.p('         if( document.forms[0].p_product_list.value  == "" )');
   htp.p('         {');
   htp.p('            document.forms[0].p_product_list.value  =');
   htp.p('                          document.forms[0].elements[i].value');
   htp.p('         }');
   htp.p('         else');
   htp.p('         {');
   htp.p('            document.forms[0].p_product_list.value  += ","');
   htp.p('            document.forms[0].p_product_list.value  += ');
   htp.p('                          document.forms[0].elements[i].value');
   htp.p('         }');
   htp.p('      }');
   htp.p('   }');
   htp.p('   return true');
   htp.p('');
   htp.p('} // determine_checked_boxes');

   htp.p('function set_final_product_list(field)');
   htp.p('{');

   htp.p('    var tmp = determine_checked_boxes() ');
   htp.p('    document.forms[1].p_product_list.value = ' ||
	   		'document.forms[0].p_product_list.value');
--   htp.p('    msg = "final product list = " + ' ||
--		'document.forms[1].p_product_list.value');
--   htp.p('    alert(msg)  ');
   htp.p('    return true');
   htp.p('');
   htp.p('} // set_final_product_list');
   htp.p('');
   htp.p('function SubmitCurrentForm(varProductList)');
   htp.p('{');
   htp.p('	set_final_product_list(varProductList);');
   htp.p('	if (document.forms[1].p_product_list.value == "")');
   htp.p('		alert("'|| g_js_slct_prd ||'");');
   htp.p('	else');
   htp.p('		document.Form1.submit();');
   htp.p('}');
   htp.p('</SCRIPT>');
   htp.br;
  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_PP_JSCRIPTS', '');
  END print_pp_jscripts;


/*
**
**	PRINT_PRODUCT_SUBHEADER
**	=======================
**
**	Private Procedure.
**	Display the selected products table.
**	Called from product_report procedure.
**
*/
PROCEDURE print_product_subheader (p_ids IN id_tbl_t)  IS

BEGIN

 --
 --	Print The Date header
 --
 htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="96%">');
  htp.p('<TR>');
  htp.p('    <TD WIDTH="50%" ALIGN="LEFT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD><TD WIDTH="50%" ALIGN="RIGHT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">' || g_as_of || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>'||
  				FND_DATE.date_to_displayDT(SYSDATE) || '</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD>');
  htp.p('</TR>');
  htp.p('</TABLE>');

  --
  -- Print the Selected Products Table header
  --
  print_selected_prods_table(p_ids);

  return;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_PRODUCT_SUBHEADER', '');
END print_product_subheader;

/*
**
**      print_selected_prods_table
**      ==========================
**
**      Private Procedure.
**      Display the selected products table.
**      Called from print_product_subheader and show_all_steps procedures.
**
*/
PROCEDURE print_selected_prods_table (p_ids IN id_tbl_t)  IS

  v_text        VARCHAR2(240);
  v_count       PLS_INTEGER;

BEGIN

  htp.p('<TABLE ALIGN="center" BORDER="1" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
        '<FONT CLASS="tableHeader">'|| g_selected ||'</FONT></TD></TR>');

  v_count := 0;
  FOR v_index IN 1..p_ids.COUNT LOOP
    v_text :=  get_application_name(p_ids(v_index));
    IF (MOD(v_count, 2) = 0) THEN
      htp.p('<TR><TD WIDTH="50%">'|| v_text ||'</TD>');
    ELSE
      htp.p('<TD WIDTH="50%">'|| v_text ||'</TD></TR>');
    END IF;
    v_count := v_count + 1;
  END LOOP;
  -- if the last record was odd then we need to add a new empty cell
  IF (v_count > 0 AND MOD(v_count, 2) = 1) THEN
    htp.p('<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD></TR>');
  END IF;
  -- If there are no products selected
  IF (v_count = 0) THEN
    htp.p('<TR><TD COLSPAN="2"><i>' || g_no_prod_sel ||'</i></TD></TR>');
  END IF;
  htp.p('</TABLE><BR>');

  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="98%">');
  htp.p('<TR><TD BGCOLOR="#CCCCCC"><IMG SRC="'|| g_image_path ||'/FNDDBPXC.gif"></TD></TR>');
  htp.p('</TABLE>');
  htp.p('  <BR>');
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
          'PRINT_SELECTED_PRODS_TABLE', '');
END print_selected_prods_table;

  /*------------------------------------------------------------------------
   * PRINT_RELATED_REPORTS
   *
   * Private procedure. Called by xxxx_report.
   * Given the related report codes, generate the links to the reports.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_related_reports(p_rpt1 IN VARCHAR2, p_rpt2 IN VARCHAR2) IS
    v_text  	VARCHAR2(240);
    v_desc	VARCHAR2(2000);
  BEGIN

    -- Get the report title and short desc
    get_report_title_desc(p_rpt1, v_text, v_desc);

    htp.hr('ALL');
    htp.p('<table border=0 cellpadding=1 cellspacing=1 width="60%">');
    htp.tableRowOpen;
	    htp.p('<td colspan="2" align="left"><font class="normalbold">' ||
	    	'<A NAME="RELATED_REPORTS">'|| g_related ||'</A></font></td>');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.p('<td align="left" width="50%"><a href="' || g_web_agent || get_report_procedure(p_rpt1) ||
          	'" onMouseOver="window.status=' || '''' || v_desc || '''' || ';return true">' ||
                  '<img src="'|| g_image_path ||'/azrelat.gif" border=0 '
                  ||' alt="'|| v_desc ||'">&nbsp;'|| v_text ||'</a></td>');

    IF (p_rpt2 IS NOT NULL) THEN
      -- Get the report title and short desc
      get_report_title_desc(p_rpt2, v_text, v_desc);

      htp.p('<td align="left" width="50%"><a href="'|| g_web_agent || get_report_procedure(p_rpt2) ||
      		'" onMouseOver="window.status=' || '''' || v_desc || '''' || ';return true">' ||
                    '<img src="'|| g_image_path ||'/azrelat.gif" border=0 '||
                    ' alt="'|| v_desc ||'">&nbsp;'|| v_text || '</a></td>');
    END IF;

    htp.tableRowClose;
    htp.tableClose;
    htp.bodyClose;
    htp.htmlClose;
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_RELATED_REPORTS', '');
  END print_related_reports;

  /*------------------------------------------------------------------------
   * PRINT_REPORT_HEADER
   *
   * Private procedure. Called by xxxx_report.
   * Given a report title, prints a report header comformant with BIS standard.
   *-----------------------------------------------------------------------*/
  PROCEDURE print_report_header(p_title IN VARCHAR2, p_type IN BOOLEAN, p_param_page IN VARCHAR2) IS
     v_js_string 	VARCHAR2(2000);
     report_help_url 	VARCHAR2(240);

  BEGIN

   report_help_url := fnd_help.get_url('AZ', g_help_target);

    htp.htmlOpen;
    htp.headOpen;

    htp.title(p_title);
    print_html_style;
    htp.headClose;
    htp.p('<BODY BGCOLOR="#FFFFFF" LINK="#0000A0" VLINK="#0000A0">');

    v_js_string:='<SCRIPT LANGUAGE=Javascript> function help_window() '||
                 '{help_win=window.open('||''''|| report_help_url
                 ||''''||','||''''||'help_win'||''''||','
                 ||''''||'resizable=yes,scrollbars=yes,toolbar=yes,width=550,'
                 ||'height=250'||''''||')}';

    htp.p(v_js_string);
    htp.p('function exit_window() { self.close(); }');
    htp.p('');
    htp.p('');
    htp.p('</SCRIPT>');

    htp.tableOpen('align=center bgcolor=#336699 border=0 cellpadding=0 ' ||
    		'cellspacing=0 valign=center width=100%');
    htp.tableRowOpen;
    htp.p('<td width=1%><br></td>');
    htp.p('<td><font class="banner"> '|| p_title ||'</font></td>');

    IF p_type THEN

      -- Related Reports Button
      htp.p('<td width=2%><br></td>');
      htp.p('<td width=4%><a href="#RELATED_REPORTS" ' ||
           'onMouseOver="window.status=' || '''' ||
	    g_related || '''' || ';return true">' ||
	  '<img src="'|| g_image_path ||'/azrelat.gif" border="0" alt="'||
           g_related ||'"></a></td>');

      -- Parameters Page Button
      htp.p('<td width=2%><br></td>');
      htp.p('<td width=4%><a href="' || p_param_page || '" ' ||
           'onMouseOver="window.status=' || '''' ||
	    g_param_hdr || '''' || ';return true">' ||
	  '<img src="'|| g_image_path ||'/azparam.gif" border="0" alt="'||
           g_param_hdr ||'"></a></td>');
     END IF;
   -- Main Menu Button
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=4%><a href="azw_report.start_page" ' ||
                'onMouseOver="window.status=' || '''' ||
                g_mn_menu || '''' || ';return true">' ||
                '<img src="'|| g_image_path ||'/azmenu.gif" border="0" alt="'||
                g_mn_menu ||'"></a></td>');
   -- Exit Button
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=4%><a href="javascript:exit_window()" ' ||
                'onMouseOver="window.status=' || '''' ||
                g_exit || '''' || ';return true">' ||
                '<img src="/OA_MEDIA/FNDEXIT.gif" border="0" alt="'||
                g_exit ||'"></a></td>');
   -- Help Button
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=4%><a href="javascript:help_window()" ' ||
                ' onMouseOver="window.status=' || '''' ||
                g_help || '''' || ';return true">' ||
                '<img src="'|| g_image_path ||'/azhelp.gif" border="0" alt="'||
                g_help ||'"></a></td>');
   -- Oracle Applications Logo
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=12%><img src="'|| g_image_path ||'/azapplo.gif"></td>');
    htp.p('<td width=1%><br></td></tr>');
    htp.p('</table>');
  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_REPORT_HEADER', '');
  END print_report_header;

/*------------------------------------------------------------------------
 * PRINT_STATUS_SUBHEADER
 *
 * Private procedure. Called by status_report.
 * Print the status chosen and the product short names for the installed
 * products.
 *-----------------------------------------------------------------------*/
PROCEDURE print_status_subheader(p_status IN VARCHAR2) IS

    v_text        VARCHAR2(240);
    v_product_cnt INTEGER := 0;
    v_line_cnt    INTEGER := 1;

BEGIN

  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="96%">');
  htp.p('<TR>');
  htp.p('    <TD WIDTH="50%" ALIGN="LEFT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        <TR><TD ALIGN="RIGHT">'|| g_proc_status || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>');
     IF (p_status IS NOT NULL) THEN
      htp.p(get_translation('AZ_PROCESS_STATUS', p_status));
    ELSE
      htp.p(g_all);
    END IF;
  htp.p('</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD><TD WIDTH="50%" ALIGN="RIGHT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">' || g_as_of || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>'||
  				FND_DATE.date_to_displayDT(SYSDATE) || '</B></TD></TR>');
  htp.p('        <TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD>');
  htp.p('</TR>');
  htp.p('</TABLE>');
  htp.p('');
  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="98%">');
  htp.p('<TR><TD BGCOLOR="#CCCCCC"><IMG SRC="'|| g_image_path ||'/FNDDBPXC.gif"></TD></TR>');
  htp.p('</TABLE>');
  htp.p('  <BR>');
  --
  -- Display Installed products table
  --
  print_isr_installed_products;

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_STATUS_SUBHEADER', '');
END print_status_subheader;

/*
**
**	PRINT_STATUS_INSTALLED_PRODS
**	============================
**
**	Private Procedure.
**	It displays the installed products table for the implementation
**	status report. It is called from print_status_subheader.
**
*/
PROCEDURE print_isr_installed_products IS

  CURSOR installed_products IS
    SELECT   distinct application_short_name short_name,
	       application_name name
    FROM     az_product_phases_v appv
    ORDER BY 1;

  product_rec 	installed_products%ROWTYPE;
  v_count	PLS_INTEGER;

BEGIN
  -- Print the Table header
  htp.p('<TABLE ALIGN="center" BORDER="1" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
  	'<FONT CLASS="tableHeader">'|| g_installed ||'</FONT></TD></TR>');

  v_count := 0;
  FOR product_rec IN installed_products LOOP
    -- if v_count is even then new record for the same phase
    IF (MOD(v_count, 2) = 0) THEN
      -- Display the product name in the first column
      htp.p('<TR><TD>'|| product_rec.name ||'</TD>');
    ELSE
      -- Display the product name in the Second column
      htp.p('<TD>'|| product_rec.name ||'</TD></TR>');
    END IF;
    v_count := v_count + 1;
  END LOOP;
  IF (v_count > 0 AND MOD(v_count, 2) = 1) THEN
    htp.p('<TD>&nbsp;</TD></TR>');
  END IF;
  -- If there are no products installed
  IF (v_count = 0) THEN
    htp.p('<TR><TD COLSPAN="2"><i>' || g_no_prod_inst ||'</i></TD></TR>');
  END IF;
  htp.p('</TABLE><BR>');

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_STATUS_INSTALLED_PRODS', '');
END print_isr_installed_products;

/*
**
**	PRINT_ISR_REPORT_SUMMARY
**	========================
**
**	Private Procedure.
**	It displays the report summary for the implementation status report.
**	The report summary displays the total number of processes, number of
**	active, completed and not started processes for each process group.
**	It is called from status_report procedure.
**
*/
PROCEDURE print_isr_report_summary (p_status IN VARCHAR2) IS

  process_groups StatusProcessGroups;

  v_display_data	VARCHAR2(500);
  v_colspan		INTEGER;
  v_locator		PLS_INTEGER := 0;
BEGIN
  -- Print the Table header
  v_locator := 1;
  htp.p('<TABLE ALIGN="center" BORDER="1" CELLPADDING="1" CELLSPACING="1">');

  IF (p_status IS NULL) THEN
    v_colspan := 5;
  ELSIF (p_status = 'I') THEN
    v_colspan := 4;
  ELSE
    v_colspan := 2;
  END IF;

  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="'|| v_colspan ||'">' ||
  	'<FONT CLASS="tableHeader"><A NAME="TOP">' ||
  		g_summary ||'</A></FONT></TD></TR>');
  htp.p('<TR>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_process_group ||'</FONT></TD>');
  IF (p_status IS NULL OR p_status = 'I') THEN
    htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_num_procs ||'</FONT></TD>');
  END IF;
  IF (p_status IS NULL OR p_status = 'C') THEN
    htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_num_completed_procs ||'</FONT></TD>');
  END IF;
  IF (p_status IS NULL OR p_status = 'A' OR p_status = 'I') THEN
    htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_num_active_procs ||'</FONT></TD>');
  END IF;
  IF (p_status IS NULL OR p_status = 'N' OR p_status = 'I') THEN
    htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699"><FONT CLASS="tableSubHeader">'||
  		g_num_notstarted_procs ||'</FONT></TD>');
  END IF;
  htp.p('</TR>');

  --
  -- Select the report summary data and populate the array with it.
  --
  populate_isr_process_groups (process_groups);
  v_locator := 2;
  FOR i IN 1..process_groups.COUNT LOOP
    v_display_data := '<A HREF="#'||
    		process_groups(i).node_id || '">'||
    		process_groups(i).display_name || '</A>';
    htp.p('<TR><TD>'|| v_display_data ||'</TD>');
    IF (p_status IS NULL OR p_status = 'I') THEN
      htp.p('<TD ALIGN="CENTER">'
        	|| process_groups(i).processes_count ||'</TD>');
    END IF;
    IF (p_status IS NULL OR p_status = 'C') THEN
      htp.p('<TD ALIGN="CENTER">'
        	|| process_groups(i).complete_procs_count ||'</TD>');
    END IF;
    IF (p_status IS NULL OR p_status = 'A' OR p_status = 'I') THEN
      htp.p('<TD ALIGN="CENTER">'
        	|| process_groups(i).active_procs_count ||'</TD>');
    END IF;
    IF (p_status IS NULL OR p_status = 'N' OR p_status = 'I') THEN
      htp.p('<TD ALIGN="CENTER">'
        	|| process_groups(i).not_started_procs_count ||'</TD>');
    END IF;
    htp.p('</TR>');
  END LOOP;
  htp.p('</TABLE><BR>');
  return;

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_ISR_REPORT_SUMMARY', 'v_locator := ' || v_locator);
END print_isr_report_summary;

/*
**
**	POPULATE_ISR_PROCESS_GROUPS
**	===========================
**
** 	Private procedure.
**	This procedure is responsible for selecting the available Process Groups,
**	counts the number of processes, active, completed and not started processes
**	for each and  populates the passed array with the data to be used by the
**	calling procedure (print_isr_report_summary).
**
*/
PROCEDURE populate_isr_process_groups (
			process_groups IN OUT NOCOPY StatusProcessGroups) IS

  CURSOR products_cursor IS
      SELECT	node_id,
	        display_name,
                node_type,
                parent_node_id,
                status_code_name
      FROM       az_monitor_reports
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id;

  product_rec		products_cursor%ROWTYPE;
  v_index 		INTEGER;
  v_total_procs		INTEGER;
  v_active_procs	INTEGER;
  v_complete_procs	INTEGER;
  v_not_started_procs	INTEGER;
  bln_IsProcess		BOOLEAN;

  v_ActiveStatus 	VARCHAR2(80);
  v_CompleteStatus 	VARCHAR2(80);
  v_NotStartedStatus 	VARCHAR2(80);
  v_locator		PLS_INTEGER := 0;
BEGIN
  --
  -- 	Initialize all counters.
  --
  v_index := 1;
  v_total_procs := 0;
  v_active_procs := 0;
  v_complete_procs := 0;
  v_not_started_procs := 0;
  v_locator := 1;
  --
  -- 	Loop through each retrived record.
  --
  FOR product_rec IN products_cursor LOOP
    IF (product_rec.parent_node_id IS NULL) THEN	-- upper parent group
      v_locator := 2;
      process_groups(v_index).display_name := product_rec.display_name;
      process_groups(v_index).node_id := product_rec.node_id;
      process_groups(v_index).processes_count := 0;
      process_groups(v_index).active_procs_count := 0;
      process_groups(v_index).complete_procs_count := 0;
      process_groups(v_index).not_started_procs_count := 0;
      IF (v_index > 1) THEN
        process_groups(v_index-1).processes_count := v_total_procs;
        process_groups(v_index-1).active_procs_count := v_active_procs;
        process_groups(v_index-1).complete_procs_count := v_complete_procs;
        process_groups(v_index-1).not_started_procs_count := v_not_started_procs;
      END IF;
      --
      -- Reset all counters for the next process group.
      --
      v_total_procs := 0;
      v_active_procs := 0;
      v_complete_procs := 0;
      v_not_started_procs := 0;

      v_index := v_index + 1;
      bln_IsProcess := FALSE;
    ELSIF (product_rec.node_type = 'P') THEN
      v_locator := 3;
      v_ActiveStatus := get_translation('AZ_PROCESS_STATUS', 'A');
      v_CompleteStatus := get_translation('AZ_PROCESS_STATUS', 'C');
      v_NotStartedStatus := get_translation('AZ_PROCESS_STATUS', 'N');

      v_total_procs := v_total_procs + 1;
      IF (product_rec.status_code_name = v_ActiveStatus) THEN
        v_active_procs := v_active_procs + 1;
      ELSIF (product_rec.status_code_name = v_CompleteStatus) THEN
        v_complete_procs := v_complete_procs + 1;
      ELSIF (product_rec.status_code_name = v_NotStartedStatus) THEN
        v_not_started_procs := v_not_started_procs + 1;
      END IF;
      bln_IsProcess := TRUE;
    END IF;
  END LOOP;
  --
  -- Check if the last record is a process
  --
  IF (bln_IsProcess) THEN
    v_locator := 4;
    process_groups(v_index-1).processes_count := v_total_procs;
    process_groups(v_index-1).active_procs_count := v_active_procs;
    process_groups(v_index-1).complete_procs_count := v_complete_procs;
    process_groups(v_index-1).not_started_procs_count := v_not_started_procs;
  END IF;

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'POPULATE_ISR_PROCESS_GROUPS', 'v_locator := ' || v_locator);
END populate_isr_process_groups;

/*------------------------------------------------------------------------
 * PRINT_USER_SUBHEADER
 *
 * Private procedure. Called by user_report.
 * Print the selected search criteria, such as user, process status, duration
 * or period, for the user performance report.
 *-----------------------------------------------------------------------*/
PROCEDURE print_user_subheader(p_user           IN VARCHAR2,
                                 p_status         IN VARCHAR2,
                                 p_time_or_period IN VARCHAR2,
                                 p_operator       IN VARCHAR2,
                                 p_days           IN VARCHAR2,
                                 p_start          IN VARCHAR2,
                                 p_end            IN VARCHAR2) IS

  p_display_name  wf_roles.display_name%TYPE;
  v_locator 	PLS_INTEGER := 0;
BEGIN

  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="96%">');
  htp.p('<TR>');
  htp.p('    <TD WIDTH="50%" ALIGN="LEFT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        <TR><TD ALIGN="RIGHT">' || g_user || '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>');
    v_locator := 1;
    IF (p_user IS NOT NULL) THEN
      SELECT  display_name INTO p_display_name
      FROM    wf_roles
      WHERE   name = p_user;
      htp.p(p_user || ' (' || p_display_name || ')');
    ELSE
      htp.p(g_all);
    END IF;
    v_locator := 2;
    htp.p('</B></TD></TR>');
  htp.p('        <TR><TD ALIGN="RIGHT">'|| g_status ||'</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>');
    IF (p_status IS NOT NULL) THEN
      htp.p(get_translation('AZ_PROCESS_STATUS', p_status));
    ELSE
      htp.p(g_all);
    END IF;
  v_locator := 3;
  htp.p('</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD><TD WIDTH="50%" ALIGN="RIGHT">');
  htp.p('        <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('        <TR><TD ALIGN="RIGHT">' || g_as_of ||
			'</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>'||
  			FND_DATE.date_to_displayDT(SYSDATE) ||  '</B></TD></TR>');
  IF (p_time_or_period = 'T') THEN	-- Time Elapsed
      htp.p('<TR><TD ALIGN="RIGHT">' || g_duration ||
			'</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>');
      IF (p_operator = '<=') THEN
         htp.p(g_atmost);
      ELSE
         htp.p(g_atleast);
      END IF;
      htp.p(' '|| p_days ||' '|| g_days);
      htp.p('</B></TD></TR>');
  ELSE					-- Date Range
     htp.p('<TR><TD ALIGN="RIGHT">' || g_active_by
		|| '</TD><TD>&nbsp;</TD><TD ALIGN="LEFT"><B>' ||
     p_start || ' - ' || p_end || '</B></TD></TR>');
  END IF;
  v_locator := 4;
  htp.p('<TR><TD ALIGN="RIGHT">&nbsp;</TD><TD ALIGN="LEFT"><B>&nbsp;</B></TD></TR>');
  htp.p('        </TABLE>');
  htp.p('    </TD>');
  htp.p('</TR>');
  htp.p('</TABLE>');
  htp.p('');
  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="98%">');
  htp.p('<TR><TD BGCOLOR="#CCCCCC"><IMG SRC="'|| g_image_path ||'/FNDDBPXC.gif"></TD></TR>');
  htp.p('</TABLE>');
  htp.p('  <BR>');

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_USER_SUBHEADER', 'v_locator := ' || v_locator);
END print_user_subheader;

  /*------------------------------------------------------------------------
   * PRINT_UP_JSCRIPTS
   *
   * Private procedure.  Called by user_param_page.
   * the print_up_jscripts prints the JavaScript functions that are used in
   * the user_parameter_page in order to do the following:
   * a) ensure that one radio button has been clicked
   * b) validate the 'days' field
   * c) set the appropriate fields to BLANK if a radio button is de-selected
   *-----------------------------------------------------------------------*/
  PROCEDURE print_up_jscripts IS

  BEGIN
   htp.p('<SCRIPT LANGUAGE=Javascript>');

   htp.p('function set_fields_to_null()');
   htp.p('{');
   htp.p('    if (document.Form1.p_time_or_period[0].checked)');
   htp.p('    {');
   htp.p('        document.Form1.p_start.value = "";');
   htp.p('        document.Form1.p_end.value   = "";');
   htp.p('    }');
   htp.p('    else if (document.Form1.p_time_or_period[1].checked)');
   htp.p('    {');
   htp.p('        document.Form1.p_days.value = "0";');
   htp.p('    }');
   htp.p('}');
   htp.p('');
   htp.p('function CheckRelativeRadioButton(varChangedField)');
   htp.p('{');
   htp.p('    if (varChangedField == "p_days" ||
   	varChangedField == "p_operator")');
   htp.p('    {');
   htp.p('        document.Form1.p_time_or_period[0].checked = true;');
   htp.p('        document.Form1.p_start.value = "";');
   htp.p('        document.Form1.p_end.value   = "";');
   htp.p('');
   htp.p('    }');
   htp.p('    else if (varChangedField == "p_start" ||
   	varChangedField == "p_end")');
   htp.p('    {');
   htp.p('        document.Form1.p_time_or_period[1].checked = true;');
   htp.p('        document.Form1.p_days.value = "0";');
   htp.p('    }');
   htp.p('}');
   htp.p('');
   htp.p('function DisplayAlert(Ctrl, strAlert)');
   htp.p('{');
   htp.p('    alert (strAlert);');
   htp.p('    Ctrl.focus();');
   htp.p('    return;');
   htp.p('}');
   htp.p('');
   htp.p('function is_numeric(input_field)');
   htp.p('{');
   htp.p('   input_string = "" + input_field;');
   htp.p('');
   htp.p('   for(var i = 0; i< input_string.length; i++)');
   htp.p('   {');
   htp.p('     var one_char = input_string.charAt(i);');
   htp.p('');
   htp.p('     if( one_char < "0" || one_char > "9")');
   htp.p('     {');
   htp.p('       return false;');
   htp.p('     }');
   htp.p('   }');
   htp.p('   return true;');
   htp.p('}');
   htp.p('');
   htp.p('function SubmitCurrentForm(CurForm)');
   htp.p('{');
   htp.p('    var value_string = CurForm.p_days.value;');
   htp.p('');
   htp.p('    if (!is_numeric(value_string))');
   htp.p('    {');
   htp.p('        DisplayAlert(CurForm.p_days, "'||
   		g_js_slct_time_elapsed ||'");');
   htp.p('        return false;');
   htp.p('    }');
   htp.p('    else');
   htp.p('        CurForm.submit();');
   htp.p('}');
   htp.p('</SCRIPT>');

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_UP_JSCRIPTS', '');
  END print_up_jscripts;

/*------------------------------------------------------------------------
 * PRINT_WELCOME_HEADER
 *
 * Private procedure.  Called by start_page.
 * The print_welcome_header routine displays the FNDEXIT icon, the FNDHELP
 * icon, and the date (without a sub-header).
 * Note that the print_report_header routine will display an information
 * icon instead of the FNDEXIT icon.
 *-----------------------------------------------------------------------*/
PROCEDURE print_welcome_header(p_title IN VARCHAR2) IS
    v_js_string 	VARCHAR2(32767);
    report_help_url    	VARCHAR2(2000);

BEGIN

    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    htp.htmlOpen;
    htp.headOpen;
    htp.title(g_welcome_msg);
    print_html_style;  	-- print the 11i HTML style sheet.
    htp.headClose;

    htp.p('<body bgcolor="#FFFFFF" LINK="#0000A0" VLINK="#0000A0">');

    report_help_url := fnd_help.get_url('AZ', 'azw_report.start_page');

    v_js_string := '<SCRIPT LANGUAGE=Javascript> function help_window() '||
                   '{help_win=window.open('||''''|| report_help_url
                   ||''''||','||''''||'help_win'
                   ||''''||','||''''||'resizable=yes,scrollbars=yes,'||
                   'toolbar=yes, width=550, height=250'||''''||')}';

    htp.p(v_js_string);

    htp.p('function exit_window() { self.close(); }');
    htp.p('');
    htp.p('');
    htp.p('</SCRIPT>');
    htp.tableOpen('align=center bgcolor=#336699 border=0 cellpadding=0 ' ||
    		'cellspacing=0 valign=center width=100%');
    htp.tableRowOpen;
    htp.p('<td width=1%><br></td>');
    htp.p('<td><font class=banner> '|| g_welcome_msg ||'</font></td>');
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=4%><a href="javascript:exit_window()" ' ||
                'onMouseOver="window.status=' || '''' ||
                	g_exit || '''' || ';return true">' ||
                '<img src="/OA_MEDIA/FNDEXIT.gif" border="0" alt="'||
                	g_exit ||'"></a></td>');
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=4%><a href="javascript:help_window()" ' ||
                ' onMouseOver="window.status=' || '''' ||
                	g_help || '''' || ';return true">' ||
                '<img src="'|| g_image_path ||'/azhelp.gif" border="0" alt="'||
                	g_help ||'"></a></td>');
    htp.p('<td width=2%><br></td>');
    htp.p('<td width=12%><img src="'|| g_image_path ||'/azapplo.gif"></td>');
    htp.p('<td width=1%><br></td></tr>');
    htp.p('</table>');
    htp.p(FND_DATE.date_to_displaydate(SYSDATE));
EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_WELCOME_HEADER', '');
END print_welcome_header;

  /*------------------------------------------------------------------------
   * PRODUCT_PARAM_PAGE
   *
   * Public procedure.
   * Generates parameter entry page in HTML for the product process report.
   * Performs the following steps:
   *   1. Get the URL for host server and all display strings if the URL is
   *      null.
   *   2. Print the title and the instruction as the header.
   *   3. Display all products covered by Wizard in a two-column checkbox
   *      layout with the application ids as the internal codes.
   *   4. Print the OK and Cancel buttons as the footer. OK button calls the
   *      implementation report and passes the user selected product ids;
   *      Cancel button calls the starting welcome page.
   *-----------------------------------------------------------------------*/
  PROCEDURE product_param_page IS

    CURSOR product_list_cursor IS
      SELECT   ag.dependency_parent_id,
	       ag.application_id,
	       fav.application_name
      FROM     az_groups ag,
               fnd_application_vl fav
      WHERE    ag.application_id IS NOT NULL
      AND      ag.application_id = fav.application_id
      AND      ag.process_type = g_current_mode
      ORDER BY ag.dependency_parent_id,
               ag.display_order;

    v_product     product_list_cursor%ROWTYPE;
    v_group       az_groups.dependency_parent_id%TYPE;
    v_column      INTEGER := 0;
    v_product_cnt INTEGER := 0;
    v_locator	  PLS_INTEGER := 0;
  BEGIN
    g_help_target := get_report_procedure('AZW_RPT_PPR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    /*
     *  The first form contains a hidden field labelled 'p_product_list', and
     *  its value is a comma-delimited list of installed product codes.  Each
     *  time that a checkbox is clicked, the value of p_product_list is
     *  updated. Note that the first form does not contain any SUBMIT or
     *  Cancel buttons.
     *
     *  The second form contains the report parameter field 'p_product_list'
     *  and a SUBMIT button and a Cancel button.  When users click on the
     *  SUBMIT button in the second form, report parameter field
     *  'p_product_list' in the second form is assigned the value of the
     *  hidden field 'p_product_list' in the first form.
     *
     *  Due to a possible bug in HTML forms, an extra parameter is used in
     *  the product parameter page in order to force the HTML page to display
     *  the 'Cancel' button.  Since the extra parameter in the HTML page is
     *  sent to the product_report procedure, a second parameter is required
     *  (called p_artificial) as a workaround.
     */

    print_param_page_header(g_ppr, g_ppr_msg, NULL);

    print_pp_jscripts;

    htp.centerOpen;
    v_locator := 1;
    OPEN product_list_cursor;
    FETCH product_list_cursor INTO v_product;
    v_group := v_product.dependency_parent_id;
    v_column := 0;

    /*
     *  Open the first form and generate a table consisting of a two-column
     *  list of radio buttons, each of which displays an installed product.
     *
     *  The internal value of each radio button equals the product code, and
     *  when users click on the 'SUBMIT' button, the JavaScript function
     *  'determine_checked_boxes' is invoked.  This JavaScript constructs a
     *  string that is a comma-delimited list of product codes that is based
     *  on the checkboxes that have been selected.  This string is assigned
     *  as the value of a hidden field 'p_product_list'.  Note that all the
     *  checkboxes and the hidden field are contained within form #0.
     *
     *  Next, the hidden field 'p_product_list' in form #0 is assigned to a
     *  hidden field named 'p_product_list' in form #1.  At this point, the
     *  appropriate PL/SQL procedure is invoked in order to display the
     *  report data.
     *
     *  NOTES
     *  -----
     *  Users can return to the product parameter page in two distinct ways.
     *
     *  1) a) Users can click on 'Cancel' (which returns users to
     *        the previous page), or specify a new URL
     *     b) navigate back to the product parameter page
     *
     *  2) Users can do something similar to the following:
     *     a) click the 'OK' button on the product parameter page
     *     b) click the 'Context Process Report' button that is located
     *        at the bottom of the product report page
     *     c) select a Context type and click the 'OK' button
     *     d) click the 'Product Process Report' button that is located
     *        at the bottom of the context report page
     *
     *  In scenario #1, the product parameter page will display only the
     *  checkboxes, if any, that were checked by the users.
     *
     *  In scenario #2, NONE of the checkboxes will be selected in the
     *  product parameter page.
     */

    htp.p('<form>');
    htp.p('<table border=0 cellpadding=1 cellspacing=1>');
    v_locator := 2;
    WHILE product_list_cursor%FOUND LOOP
      v_product_cnt := v_product_cnt + 1;
      IF (v_group <> v_product.dependency_parent_id) THEN
        -- print a line break bewteen groups
        htp.p('</tr><tr><td colspan=3 height=10></td></tr>');

        v_group := v_product.dependency_parent_id;
        v_column := 0;
      END IF;

      IF (v_column = 0) THEN
        -- print check box with v_product.application_name and
        -- v_product.application_id in the first column
        htp.tableRowOpen;

        htp.p('<td align="left">'||
              '<input type=checkbox name='||'p_product_list'||v_product_cnt||
              ' value='||v_product.application_id||
              ' UNCHECKED> '||v_product.application_name||' </td>');

        v_column := v_column + 1;
        htp.tableData(lpad_nbsp(3));     -- tab one column

      ELSE
        -- print check box with v_product.application_name and
        -- v_product.application_id in the third column

        htp.p('<td align="left">'||'<input type=checkbox name='||
              'p_product_list'||v_product_cnt||' value='||
              v_product.application_id||
              ' UNCHECKED> '||v_product.application_name||' </td>');

        v_column := 0;

      END IF;
      FETCH product_list_cursor INTO v_product;
    END LOOP;
    htp.tableRowClose;
    v_locator := 4;
    CLOSE product_list_cursor;
    htp.tableClose;

    -- add the hidden field 'p_product_list' which will be used in order
    -- to maintain the comma-delimited list of selected product codes

    htp.p('<input type="hidden" name="p_product_list" value="">');

    -- hidden field for the number of installed products
    htp.p('<input type="hidden" name="p_product_count" value="'||
          v_product_cnt||'">');
    htp.p('</form>');

    -- the second form contains the report parameter field 'p_product_list'
    htp.p('<form name="Form1" method="post" action="azw_report.product_report">');

    -- Print the horizontal seperator
    htp.p('<table align=center border=0 cellpadding=0 cellspacing=2 width=96%>');
    --
    -- Print Footer line seperator.
    --
    print_footer_separator_line();
    --
    -- Print the ok and cancel buttons
    --
    v_locator := 5;
    print_ok_cancel_buttons('javascript:void(' ||
	    'SubmitCurrentForm(document.Form1.p_product_list))');
    htp.p('<input type="hidden" name="p_product_list" value="">');
    htp.p('</form>');
    htp.centerClose;
    htp.bodyClose;
    htp.htmlClose;

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRODUCT_PARAM_PAGE', 'v_locator := ' || v_locator);
  END product_param_page;

/*------------------------------------------------------------------------
 * PRODUCT_REPORT
 *
 * Public procedure. Invoked by the OK button in product_param_page.
 * Generates the product process report in HTML.  It performs the following
 * steps:
 *   1. Get the URL for host server and all display strings if the URL is ''.
 *   2. Get the string of concatenated product ids into an array of numbers.
 *   3. Print report header and subheader.
 *   5. Print Table opening tag and header.
 *   6. For each product id in the array, get the processes for the product
 *      into the intermediate table.
 *   7. Get the trees from the intermediate table.  For each node, print
 *      the data.
 *   8. Print Table closing tag.
 *   9. Print links to related reports.
 *
 * Notes:
 *   Second argument is a work around.  Refer to the spec for detail.
 *-----------------------------------------------------------------------*/
PROCEDURE product_report(p_product_list IN VARCHAR2,
                           p_artificial   IN VARCHAR2) IS
    v_app_id     NUMBER;
    v_cnt        BINARY_INTEGER;
    v_ids        id_tbl_t;
    v_count	 PLS_INTEGER;

    CURSOR hierarchies_cursor IS
      SELECT     LPAD(g_blank, g_indent*(LEVEL-1))||display_name hierarchy,
                 node_type,
                 description,
                 parent_node_id,
                 node_id,
                 context_type_name,
                 LEVEL
      FROM       az_planning_reports
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id
      AND	 PRIOR phase = phase;

   v_locator   		PLS_INTEGER := 0;
   v_upper_group_names 	HierarchyLevels;
   v_item_type 		wf_process_activities.PROCESS_ITEM_TYPE%TYPE;
   v_process_name	wf_process_activities.PROCESS_NAME%TYPE;
   v_process_groups	VARCHAR2(4000);

BEGIN
    print_time_stamp('Start report');
    g_help_target := get_report_procedure('AZW_RPT_PPRR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    print_js_open_url(TRUE);

    print_time_stamp('End Translating messages and getting APP_WEB_AGENT');
    v_locator := 1;
    --
    -- get the product list string into the id table
    --
    v_cnt := 1;
    v_app_id := azw_proc.parse_application_ids(p_product_list, v_cnt);
    WHILE (v_app_id > -1) LOOP
      v_ids(v_cnt) := v_app_id;
      v_cnt := v_cnt + 1;
      v_app_id := azw_proc.parse_application_ids(p_product_list, v_cnt);
    END LOOP;
    v_locator := 2;
    print_report_header (g_ppr, TRUE, 'azw_report.product_param_page');

    print_product_subheader (v_ids);

    v_locator := 3;
    print_time_stamp('Start insert into temp table');
    FOR  v_index IN 1..v_ids.COUNT LOOP
      --dbms_output.put_line('app_id: '||v_ids(v_index));
      get_product_processes(v_ids(v_index));
    END LOOP;
    print_time_stamp('End insert into temp table');
    v_locator := 4;
    --
    -- 	Print the Product Report Summary
    --
    print_planning_reports_summary (-1);
    print_time_stamp('End display report summary');

    print_legend_link;

    --
    --	Add a hyperlink to the Step Details report that
    --  shows all the steps for all the processes available
    --  to the selected products
    --
    htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="1" CELLSPACING="1" WIDTH="100%">');
    /*htp.p('<TR><TD ALIGN="CENTER"><A HREF=javascript:void(OpenURL("' ||
	    'azw_report.show_all_steps?p_selected_products='||
	    		p_product_list || '")) onMouseOver=window.status="' ||
	    		g_step_all_procs || '";return true><FONT SIZE="-1">' ||
  		g_step_all_procs || '</FONT></A></TD></TR>');*/
    htp.p('<TR><TD ALIGN="CENTER"><A HREF=javascript:void(OpenURL("' ||
	    'azw_report.show_all_steps?p_selected_products='||
	    		p_product_list || '"))><FONT SIZE="-1">' ||
  		g_step_all_procs || '</FONT></A></TD></TR>');
    htp.p('</TABLE>');
    htp.p('<BR>');

    --
    -- 	Display Report Details
    --
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
	      '<FONT CLASS="tableHeader">'|| g_details ||'</FONT></TD></TR>');
    htp.p('<TR>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
     	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_description ||'</FONT></TH>');

    -- print hierarchies nodes
    v_count := 0;
    v_locator := 5;
    FOR one_node IN hierarchies_cursor LOOP
      --
      --   Keep track of all the upper groups to be able to display
      --   them in a flat directory structure like
      --   "\Common Applications\System Administration\"
      --
      v_upper_group_names(one_node.level) := TRIM(one_node.hierarchy);

       IF (one_node.parent_node_id IS NULL) THEN
         IF (v_count > 0) THEN
	    print_back_to_top(2);
	 END IF;
     	 htp.p('<TR><TD ALIGN="LEFT" COLSPAN="2" BGCOLOR="#666666" NOWRAP>' ||
	   	'<i><FONT COLOR="#FFFFFF"><A NAME="PH-1_'||
            	one_node.node_id || '">' ||
            	one_node.hierarchy || '</A></FONT></i></TD>');
       ELSIF (one_node.node_type = 'G') THEN
         htp.tableRowOpen;
         htp.tableData('<i>'||lpad_nbsp(one_node.level)|| one_node.hierarchy ||
                       '</i>', 'LEFT', '', 'NOWRAP');
       ELSE
         get_process_type_name (one_node.node_id, v_item_type, v_process_name);
         v_process_groups := get_parent_structure(v_upper_group_names, one_node.level - 1, '\\');
         htp.tableRowOpen;
         htp.tableData(lpad_nbsp(one_node.level) || '<A HREF=javascript:void(OpenURL("'||
         	'azw_report.display_process_steps?p_selected_products=' || p_product_list ||
         		'&p_item_type=' || v_item_type ||
			'&p_process_name=' || v_process_name ||
			'&p_context_type_name=' || url_encode(one_node.context_type_name) ||
			'&p_process_groups=' || url_encode(v_process_groups) ||
			'&p_new_call=YES&p_external_call=YES' || '"))><b>'
			|| TRIM(one_node.hierarchy) ||
                       '</b></A>', 'LEFT', '', 'NOWRAP');
         htp.tableData(one_node.description, 'LEFT', '', 'NOWRAP');
       END IF;
       htp.tableRowClose;
       v_count := v_count + 1;
    END LOOP;
    v_locator := 6;
    print_back_to_top(2);
    -- print Table closing tag
    htp.tableClose;
    -- print report legend
    print_legend;
    -- print related report links
    print_related_reports('AZW_RPT_IPR', 'AZW_RPT_CPR');
    print_time_stamp('End display report details');
    COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      -- print Table closing tag
      htp.tableClose;
      print_related_reports('AZW_RPT_IPR', 'AZW_RPT_CPR');
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'PRODUCT_REPORT', 'v_locator := ' || v_locator);
END product_report;

/*------------------------------------------------------------------------
 * START_PAGE
 *
 * Public procedure.
 * Define 5 hyperlinks for the following reports:
 *  Implementation Process Report (IPR) (group 1)
 *  Context Process Report        (CPR) (group 1)
 *  Product Process Report        (PPR) (group 1)
 *  Implementation Status Report  (ISR) (group 2)
 *  User Performance Report       (UPR) (group 2)
 *-----------------------------------------------------------------------*/
PROCEDURE start_page IS
    v_link VARCHAR2(240);
BEGIN
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    -- display the header containing the welcome message and two icons
    print_welcome_header(g_welcome_msg);

    --  branch out depending on the current Wizard Mode
    IF (g_current_mode = 'IMP') THEN
       print_imp_start_page;
    ELSE
       print_upgrade_start_page;
    END IF;
    htp.bodyClose;
    htp.htmlClose;

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
 	  'START_PAGE', '');
END start_page;

  /*------------------------------------------------------------------------
   * STATUS_PARAM_PAGE
   *
   * Public procedure.
   * Generates parameter entry page in HTML for implmentation status report.
   * Performs the following steps:
   *   1. Get the URL for host server and all display strings if the URL is
   *      null.
   *   2. Print the title and the instruction as the header.
   *   3. Display all valid statuses in a drop down list with the lookup_codes
   *      as the internal code, making the blank as the default option meaning
   *      all statuses.
   *   4. Print the OK and Cancel buttons as the footer. OK button calls the
   *      status report and passes the user selected status(es); Cancel button
   *      calls the starting welcome page.
   *-----------------------------------------------------------------------*/
  PROCEDURE status_param_page IS

    CURSOR statuses_cursor IS
      SELECT	lookup_code, meaning
      FROM 	fnd_lookups
      WHERE 	lookup_type = 'AZ_PROCESS_STATUS'
      ORDER BY  lookup_code;

  BEGIN
    g_help_target := get_report_procedure('AZW_RPT_ISR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;

    print_param_page_header(g_isr, g_isr_msg, g_mode_label);

    htp.p('<table align="center" border="0" cellpadding="0" ' ||
	    'cellspacing="2" width="96%">');
    htp.p('<tr><td colspan=4><br></td>');
    htp.p('<form name="Form1" method="post" ' ||
    	'action="azw_report.status_report"></tr>');

    -- create the pop-up list of process status
    htp.p('<tr><td align=right WIDTH="50%"><font class=normal>' ||
    	g_proc_status || '</font></td>');
    htp.p('<td align=left colspan=3><select name="p_status" size=1>');

    -- make the blank as the default and first option meaning for all statuses
    htp.p('<option value="">'|| g_all ||'</option>');

    FOR one_status IN statuses_cursor LOOP
      IF (one_status.lookup_code <> 'ALL') THEN
            htp.p('<option value="'||one_status.lookup_code||'"> '||
                  one_status.meaning||'</option>');
      END IF;
    END LOOP;
    htp.p('</select></td></tr>');

    print_param_page_footer;

  EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'STATUS_PARAM_PAGE', '');
  END status_param_page;

  /*------------------------------------------------------------------------
   * STATUS_REPORT
   *
   * Public procedure.  Invoked by the OK button in status_param_page.
   * Generates the implementation status report in HTML.  It performs the
   * following steps:
   *   1. Get the URL for host server and all display strings if the URL is ''.
   *   2. Print report header and subheader.
   *   4. Print Table Header based on the selected status.
   *   5. Get tasks, processes, groups for the particular status into the
   *      intermediate table.
   *   6. Get the trees from the intermediate table.  For each node, print the
   *      Table Row and Table Data based on the selected status.
   *   7. Print Table closing tag.
   *   8. Print links to related reports.
   *-----------------------------------------------------------------------*/
  PROCEDURE status_report(p_status IN VARCHAR2) IS

    CURSOR hierarchies_cursor IS
      SELECT     LPAD(g_blank, g_indent*(LEVEL-1))||display_name hierarchy,
                 node_type,
                 context_type_name,
                 context_name,
                 status_code_name,
                 assigned_user,
                 FND_DATE.date_to_displaydate(start_date) start_date,
                 FND_DATE.date_to_displaydate(end_date) end_date,
                 DECODE(duration, '', '', duration||' '||g_days) time_elapsed,
                 LEVEL,
                 parent_node_id,
                 node_id,
                 COMMENTS
      FROM       az_monitor_reports
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id;

   v_colspan	PLS_INTEGER;
   v_count	PLS_INTEGER;
   v_locator	PLS_INTEGER := 0;
   v_href		VARCHAR2(4000);
   v_upper_group_names HierarchyLevels;

   v_ctx_type_name	az_monitor_reports.context_type_name%TYPE;
   v_process_groups	VARCHAR2(4000);
   v_item_type		AZ_TASKS_V.ITEM_TYPE%TYPE;
   v_item_key		AZ_TASKS_V.ITEM_KEY%TYPE;

  BEGIN
    print_time_stamp('Start report');
    g_help_target := get_report_procedure('AZW_RPT_ISRR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;
    v_locator := 1;
    print_report_header(g_isr || ' (' || g_mode_label || ')',
                                 TRUE, 'azw_report.status_param_page');

    print_js_open_url;

    print_status_subheader (p_status);


    print_time_stamp('Start Temp Table Inserts/Queries.');
    get_status_groups(p_status);
    get_status_processes(p_status);
    get_status_tasks(p_status);
    print_time_stamp('End Temp Table Inserts/Queries.');

    --
    -- Display the Report Summary
    --
    print_isr_report_summary (p_status);

    print_legend_link;

    --
    -- print report details and header based on p_status
    --
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    IF (p_status IS NULL OR p_status='A' OR p_status='C' OR p_status='I') THEN
      v_colspan := 8;
    ELSE
      v_colspan := 4;
    END IF;
    htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="'|| v_colspan ||'">' ||
	      '<FONT CLASS="tableHeader">'|| g_details ||'</FONT></TD></TR>');

    htp.p('<TR>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
     	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_ctxt_type ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_ctxt_name ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_status ||'</FONT></TH>');
    IF (p_status IS NULL OR p_status='A' OR p_status='C' OR p_status='I') THEN
      htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
          'NOWRAP><FONT CLASS="tableSubHeader">'|| g_user ||'</FONT></TH>');
      htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
          'NOWRAP><FONT CLASS="tableSubHeader">'|| g_start ||'</FONT></TH>');
      htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
          'NOWRAP><FONT CLASS="tableSubHeader">'|| g_end ||'</FONT></TH>');
      htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
          'NOWRAP><FONT CLASS="tableSubHeader">'|| g_duration ||'</FONT></TH>');
    END IF;
    htp.tableRowClose;
    v_count := 0;
    v_locator := 2;
    FOR one_node IN hierarchies_cursor LOOP
      --
      --   Keep track of all the upper groups to be able to display
      --   them in a flat directory structure like
      --   "\Common Applications\System Administration\"
      --
      v_upper_group_names(one_node.level) := TRIM(one_node.hierarchy);
      -- print hierarchy, context type, context name and status
      htp.tableRowOpen;
      IF (one_node.parent_node_id IS NULL) THEN
        IF (v_count > 0) THEN
          print_back_to_top(v_colspan);
        END IF;
        htp.p('<TR><TD ALIGN="LEFT" COLSPAN="'|| v_colspan
           ||'" BGCOLOR="#666666" ' ||
            'NOWRAP><i><FONT COLOR="#FFFFFF"><A NAME="' ||
            one_node.node_id || '">' ||
            one_node.hierarchy || '</A></FONT></i></TD>');
      ELSIF (one_node.node_type = 'G') THEN
        htp.tableData('<i>'||lpad_nbsp(one_node.level)|| one_node.hierarchy ||
                      '</i>', 'LEFT', '', 'NOWRAP');
        htp.tableData('<i>'||one_node.context_type_name||'</i>');
        htp.tableData('<i>'||one_node.context_name||'</i>');
        htp.tableData('<i>'||one_node.status_code_name||'</i>', 'LEFT', '', 'NOWRAP');
        IF (p_status IS NULL OR p_status='A' OR p_status='C' OR p_status='I')
        THEN
          -- print assigned user, start/end dates, and duration
          htp.tableData('<i>'||one_node.assigned_user||'</i>');
          htp.tableData('<i>'||one_node.start_date||'</i>');
          htp.tableData('<i>'||one_node.end_date||'</i>');
          htp.tableData('<i>'||one_node.time_elapsed||'</i>', 'RIGHT');
        END IF;
      ELSIF (one_node.node_type = 'P') THEN
	-- To be used by the task HREF
	v_process_groups := get_parent_structure(v_upper_group_names, one_node.level, '\\');
	v_ctx_type_name := one_node.context_type_name;

        htp.tableData('<b>'||lpad_nbsp(one_node.level)|| one_node.hierarchy ||
                      '</b>', 'LEFT', '', 'NOWRAP');
        htp.tableData(one_node.context_type_name||'</b>');
        htp.tableData(one_node.context_name||'</b>');
        htp.tableData(one_node.status_code_name||'</b>', 'LEFT', '', 'NOWRAP');
        IF (p_status IS NULL OR p_status='A' OR p_status='C' OR p_status='I')
        THEN
          -- print assigned user, start/end dates, and duration
          htp.tableData('<b>'||one_node.assigned_user||'</b>');
          htp.tableData('<b>'||one_node.start_date||'</b>');
          htp.tableData('<b>'||one_node.end_date||'</b>');
          htp.tableData('<b>'||one_node.time_elapsed||'</b>', 'RIGHT');
        END IF;
        IF (one_node.comments IS NOT NULL) THEN
        htp.tableRowClose;
        htp.tableRowOpen;
        htp.tableData('<b>' || lpad_nbsp(one_node.level)||'('||
        	g_comments ||':'||one_node.comments
        	||')</b>', 'LEFT', '', 'NOWRAP');
        END IF;
      ELSE       /* node_type = 'T' */
        get_task_type_key(one_node.node_id, v_item_type, v_item_key);
        v_href := '<A HREF=javascript:void(OpenURL("' ||
          	'azw_report.task_details?' ||
			'p_process_groups=' || url_encode(v_process_groups) ||
			'&p_ctx_type=' || url_encode(v_ctx_type_name) ||
			'&p_status=' || url_encode(one_node.status_code_name) ||
			'&p_start=' || url_encode(one_node.start_date) ||
			'&p_end=' || url_encode(one_node.end_date)||
			'&p_time_elapsed=' || url_encode(one_node.time_elapsed) ||
          		'&p_item_type=' || v_item_type ||
          		'&p_item_key=' || v_item_key || '")) onMouseOver=window.status='
          		|| g_task_details || '";return true>';
        htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
        htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
        htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
	htp.p('<TD ALIGN="LEFT" BGCOLOR="#DDDDDD" NOWRAP>'|| v_href || one_node.status_code_name || '</A></TD>');

        IF (p_status IS NULL OR p_status='A' OR p_status='C' OR p_status='I') THEN
          -- print assigned user, start/end dates, and duration
          htp.tableData(one_node.assigned_user, '', '', '', '', '',
                        'bgcolor=#DDDDDD');
          htp.tableData(one_node.start_date, '', '', '', '', '',
                        'bgcolor=#DDDDDD');
          htp.tableData(one_node.end_date||'&nbsp;', '', '', '', '', '',
                        'bgcolor=#DDDDDD');
          htp.tableData(one_node.time_elapsed, 'RIGHT', '', '', '', '',
                        'bgcolor=#DDDDDD');
        END IF;
      END IF;

      -- print Table row closing tag
      htp.tableRowClose;
      v_count := v_count + 1;
    END LOOP;
    v_locator := 3;
    print_back_to_top(v_colspan);
    -- print Table closing tag
    htp.tableClose;
    -- print report legend
    print_legend (TRUE);

    -- print related report links
    print_related_reports('AZW_RPT_UPR');
    print_time_stamp('End report');

    COMMIT;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- print Table closing tag
      htp.tableClose;
      print_related_reports('AZW_RPT_UPR');
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'STATUS_REPORT', 'v_locator := ' || v_locator);
  END status_report;

  /*------------------------------------------------------------------------
   * USER_PARAM_PAGE
   *
   * Public procedure.
   * Generates parameter entry page in HTML for user performance report.
   * Performs the following steps:
   *   1. Get the URL for host server and all display strings if the URL is
   *      null.
   *   2. Print the title and the instruction as the header.
   *   3. Display the selection boxes for users, process statuses, duration
   *      and start and end periods.
   *   4. Print the OK and Cancel buttons as the footer. OK button calls the
   *      user report and passes the selected parameters; Cancel button calls
   *      the starting welcome page.
   *-----------------------------------------------------------------------*/
  PROCEDURE user_param_page IS

    CURSOR valid_users_cursor IS
     SELECT   DISTINCT wf.text_value name,
     		wfr.display_name
      FROM     wf_item_attribute_values wf, wf_roles wfr
      WHERE    wf.item_type LIKE 'AZ%'
      AND 	wf.text_value = wfr.name
      AND      wf.name = 'AZW_IA_ROLE'
      ORDER BY 1;

    CURSOR statuses_cursor IS
      SELECT   lookup_code, meaning
      FROM     fnd_lookups
      WHERE    lookup_type = 'AZ_PROCESS_STATUS'
      AND      lookup_code IN ('A', 'C')
      ORDER BY lookup_code;

    CURSOR duration_ranges_cursor IS
      SELECT   lookup_code, meaning
      FROM     fnd_lookups
      WHERE    lookup_type = 'AZ_REPORT_DURATION_RANGE'
      ORDER BY lookup_code;
    v_locator	PLS_INTEGER := 0;

  BEGIN

   /*
    *  The User Performance Parameter Page consists of one table
    *  with three pop-up lists (user, status, and execution time),
    *  a numeric 'days' field, a date-from field, and a date-to field:
    *
    *
    *                            ----------
    *                       User |        |
    *                            ----------
    *                            ----------
    *             Process Status |        |
    *                            ----------
    *                            ----------       -----
    *         o   Execution Time |        |       |   |  Days
    *                            ----------       -----
    *                            --------------   ------------
    *         o       Start Date |            | - |          |
    *                            --------------   ------------
    *
    *
    *  Fields that are on a "row" with a radio button can only be
    *  assigned a value when their radio button has been selected,
    *  otherwise the input field will be set to blank.  Due to the
    *  extremely large number of date formats, the validation for
    *  the start date and the end date is performed on the server
    *  rather than the client.
    */

   /*
    *  Java functions appear at the beginning of the body.  These
    *  functions keep track of the currently clicked radio button,
    *  determine when to set fields to blank, and perform numeric
    *  validation of the 'p_days' field.
    *
    *  The 'execution' radio button is the default value.  Each
    *  time users click on a radio button, the affected fields
    *  are set to blank.  For example, when users click on the
    *  'execution' radio button, the start and end dates are set
    *  to blanks.
    *
    *  NOTES
    *  1) the Java function 'set_fields_to_null' determines which
    *     radio button has been clicked
    *
    *  2) the default radio button does not have an actual value;
    *     hence, it is hard-coded to zero because it precedes the
    *     'period_from' radio button
    *
    *  3) due to point 2), if the default radio button is changed
    *     (i.e., to the other radio button or a new radio button),
    *     then its value must be altered in the Java function, and
    *     its value is one less than the order of its appearance
    *     in the HTML page when the HTML page is traversed from
    *     left-to-right and from top-to-bottom.
    */
    g_help_target := get_report_procedure('AZW_CPT_UPR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;
    print_param_page_header(g_upr, g_upr_msg, g_mode_label);
    print_up_jscripts;

    htp.p('<form name="Form1" method="post" action="azw_report.user_report">');
    htp.p('<table align=center border=0 cellpadding=0 cellspacing=2 width=96%>');
    htp.p('<tr><td colspan=2><br></td></tr>');

    --
    --   Display the list of users (extracted from the database).
    --
    htp.p('<tr><td align=right width=50%><font class=normal>'||
    	g_user ||'</font></td>');
    htp.p('<td align=left width=50%><select name="p_user" size=1>');
    htp.p('<option value="">'||g_all||'</option>');
    v_locator := 1;
    FOR one_user IN valid_users_cursor LOOP
      -- print each valid user as an option
      htp.p('<option value="'||one_user.name||'">'|| one_user.name
       	|| ' (' || one_user.display_name || ')' ||
           '</option>');
    END LOOP;
    htp.p('</select></font><td></tr>');

    --
    --   Display the list of status values.
    --
    htp.p('<tr><td align=right width=50%><font class=normal>'||
    	g_status ||'</font></td>');
    htp.p('<td align=left width=50%><select name="p_status" size=1>');
    htp.p('<option value="">'||g_all||'</option>');
    v_locator := 2;
    FOR one_status IN statuses_cursor LOOP
       -- print each status as an option
       htp.p('<option value="'||one_status.lookup_code||'">'||
             one_status.meaning||'</option>');
    END LOOP;
    htp.p('</select></td></tr>');

    --  Note that the default value for the radio button is "T",
    --  which represents the date range.

    --
    -- Display Both Radio buttons in the first <TD> with a
    -- rowspan of 2 (to align the radio buttons)
    --
    htp.p('<tr><td align=right WIDTH="50%" ROWSPAN=2>');
    htp.p('<table border=0>');
	htp.p('<TR>');
        	htp.p('<TD><input type=radio name=p_time_or_period value="T" ' ||
       		  'CHECKED align=right onClick="set_fields_to_null()"></td>');
		htp.p('<td align=right><font class=normal>'||
			g_duration ||'</font></td>');
	htp.p('</TR>');
	htp.p('<TR><TD><BR></TD></TR>');
	htp.p('<TR>');
        	htp.p('<TD><input type=radio name=p_time_or_period value="P" ' ||
        		' align=right onClick="set_fields_to_null()"></td>');
                htp.p('<td align=right><font class=normal>'||
                	g_active_by ||'</font></td>');
	htp.p('</TR>');
	htp.p('</TABLE>');
        htp.p('</td>');
	--
	-- Display the rest of the Time Elapsed row.
        --
        htp.p('<td align=left>');
	  htp.p('<select name="p_operator" size=1 ' ||
			'onChange="CheckRelativeRadioButton(' ||
			'''' ||'p_operator' || '''' || ')">');
          v_locator := 3;
	  FOR one_range IN duration_ranges_cursor LOOP
      		-- htp.p one_range as an option, with '>=' as the default value
      		IF (one_range.lookup_code = '>=') THEN
        		htp.p('<option selected value="'||one_range.lookup_code||'">'||
              			one_range.meaning||'</option>');
      		ELSE
        		htp.p('<option value="'||one_range.lookup_code||'">'||' '||
              			one_range.meaning||'</option>');
      		END IF;
	  END LOOP;

	  htp.p('</select>&nbsp;&nbsp;');
          htp.p('<input type=text value ="0" name="p_days" ' ||
			'onChange="CheckRelativeRadioButton(' ||
			'''' ||'p_days' || '''' || ')" ' ||
                	'size=3><font class="normal">'|| g_days ||'</font>');
    htp.p('</td></tr>');

    --
    -- Display the Start Date "From" - "To" row.
    --
    htp.p('<tr>');
    htp.p('<td align=left valign="bottom">');
    htp.p('<TABLE BORDER="0">');
    htp.p('<TR><TD ALIGN="LEFT">' || g_from || '</TD><TD>&nbsp;</TD>');
    htp.p('<TD ALIGN="LEFT">' || g_to  || '</TD></TR>');
    htp.p('<TR><TD ALIGN="LEFT">');
    htp.p('<input type=text name="p_start" size=10 ' ||
		'onChange="CheckRelativeRadioButton(' ||
		'''' ||'p_start' || '''' || ')">');
    htp.p('</TD><TD>-</TD><TD ALIGN="LEFT">');
    htp.p('<input type=text name="p_end" size=10 ' ||
		'onChange="CheckRelativeRadioButton(' ||
		'''' ||'p_end' || '''' || ')">');
    htp.p('</td></tr></TABLE></TD></TR>');
    htp.p('<tr><td width=50%></td><td align="left" width="50%"><font class=normal>' ||
    	g_dateformat_msg || ' ' || FND_DATE.user_mask ||'</FONT></TD></TR>');

    -- Print the horizontal seperator
    print_footer_separator_line();
    -- Print the ok and cancel buttons
    print_ok_cancel_buttons('javascript:' ||
	    'void(SubmitCurrentForm(document.Form1))');

    htp.p('</form>');
    htp.centerClose;
    htp.bodyClose;
    htp.htmlClose;
 EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'USER_PARAM_PAGE', 'v_locator := ' || v_locator);
  END user_param_page;

  /*------------------------------------------------------------------------
   * USER_REPORT
   *
   * Public procedure.  Invoked by the OK button in user_param_page.
   * Generates the user performance report in HTML.  It performs the following
   * steps:
   *   1. Get the URL for host server and all display strings if the URL is ''.
   *   2. Print report header and subheader.
   *   4. Print Table opening tag and header based on selected user.
   *   4. If one particular user is chosen, get user trees by other search
   *      criteria into the intermediate table based on duration ('at most' or
   *      'at least') or period.  Retrieve the trees from the intermediate
   *      table.  For each row retrieved, print Table Row and Table Data.
   *   5. If all users is chosen, for each user, get user trees by other search
   *      criteria into the intermediate table based on duration ('at most' or
   *      'at least') or period.  For each user, retrieve the trees from the
   *      intermediate table,  For each row retrieved, print Table Row and
   *      Table Data.
   *   6. Print Table closing tag.
   *   7. Print links to related reports.
   *-----------------------------------------------------------------------*/
  PROCEDURE user_report (p_user            IN VARCHAR2,
                        p_status          IN VARCHAR2,
                        p_time_or_period  IN VARCHAR2,
                        p_operator        IN VARCHAR2,
                        p_days            IN VARCHAR2,
                        p_start           IN VARCHAR2,
                        p_end             IN VARCHAR2) IS

    v_start      DATE;
    v_end        DATE;

    CURSOR valid_users_cursor IS
      SELECT   DISTINCT wf.text_value user_name,
     		wfr.display_name
      FROM     wf_item_attribute_values wf, wf_roles wfr
      WHERE    wf.item_type LIKE 'AZ%'
      AND 	wf.text_value = wfr.name
      AND      wf.name = 'AZW_IA_ROLE'
      ORDER BY 1;

    CURSOR hierarchies_cursor(x_user VARCHAR2) IS
      SELECT     assigned_user,
                 LPAD(g_blank, g_indent*(LEVEL-1))||display_name hierarchy,
                 node_type,
                 context_type_name,
                 context_name,
                 status_code_name,
                 FND_DATE.date_to_displaydate(start_date) start_date,
                 FND_DATE.date_to_displaydate(end_date) end_date,
                 DECODE(duration, '', '', duration||' '||g_days) time_elapsed,
                 parent_node_id,
                 LEVEL,
                 node_id,
                 comments
      FROM       az_monitor_reports
      WHERE      assigned_user = x_user
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id
      AND	 PRIOR assigned_user = assigned_user
      AND        assigned_user = x_user;

    v_count 		INTEGER;
    i			PLS_INTEGER;
    v_locator		PLS_INTEGER := 0;
    v_item_type		AZ_TASKS_V.ITEM_TYPE%TYPE;
    v_item_key		AZ_TASKS_V.ITEM_KEY%TYPE;
    v_href		VARCHAR2(4000);
    v_upper_group_names HierarchyLevels;

    v_ctx_type_name		az_monitor_reports.context_type_name%TYPE;
    v_process_groups	VARCHAR2(4000);

  BEGIN

    print_time_stamp('Start report');
    g_help_target := get_report_procedure('AZW_RPT_UPRR');
    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;
    print_report_header(g_upr || ' (' || g_mode_label || ')', TRUE, 'azw_report.user_param_page');

    print_js_open_url;

    IF (p_time_or_period = 'P') THEN
      IF (p_start IS NULL) THEN
      	v_start := TO_DATE('01/01/1950', 'DD/MM/YYYY');
      ELSE
        v_start := FND_DATE.displaydate_to_date(p_start);
      END IF;
      IF (p_end IS NULL) THEN
        v_end := SYSDATE + 1;
      ELSE
        v_end := FND_DATE.displaydate_to_date(p_end);
      END IF;
    END IF;

    print_user_subheader(p_user, p_status, p_time_or_period, p_operator,
                         p_days, FND_DATE.date_to_displaydate(v_start),
                         FND_DATE.date_to_displaydate(v_end));
    v_locator := 1;
    print_time_stamp('Start of Temp Table Inserts');
    IF (p_user IS NOT NULL) THEN
      IF (p_time_or_period = 'T') THEN
        IF (p_operator = '<=') THEN
	  v_locator := 2;
          get_user_trees_by_atmost(p_user, p_status, TO_NUMBER(p_days));
        ELSE
	  v_locator := 3;
          get_user_trees_by_atleast(p_user, p_status, TO_NUMBER(p_days));
        END IF;
      ELSE
        v_locator := 4;
        get_user_trees_by_period(p_user, p_status, v_start, v_end) ;
      END IF;
      print_time_stamp('End of Temp Table Inserts');
      print_legend_link;

      -- print hierarchy for the user
      htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
      htp.tableRowOpen;
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_ctxt_type ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_ctxt_name ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_status ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_start ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_end ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_duration ||'</FONT></TD>');
       htp.tableRowClose;
      v_locator := 5;
      FOR one_node IN hierarchies_cursor(p_user) LOOP
        --
        --   Keep track of all the upper groups to be able to display
        --   them in a flat directory structure like
        --   "\Common Applications\System Administration\"
        --
        v_upper_group_names(one_node.level) := TRIM(one_node.hierarchy);
        htp.tableRowOpen;
        IF (one_node.parent_node_id IS NULL) THEN
          htp.p('<TR><TD ALIGN="LEFT" COLSPAN="7" BGCOLOR="#666666" ' ||
            'NOWRAP><i><FONT COLOR="#FFFFFF">' ||
            one_node.hierarchy || '</FONT></i></TD>');
        ELSIF (one_node.node_type = 'G') THEN
          htp.tableData('<i>'||lpad_nbsp(one_node.level)|| one_node.hierarchy ||
                        '</i>', 'LEFT', '', 'NOWRAP');
          htp.tableData('<i>'||one_node.context_type_name||'</i>');
          htp.tableData('<i>'||one_node.context_name||'</i>');
          htp.tableData('<i>'||one_node.status_code_name||'</i>', 'LEFT', '','NOWRAP');
          htp.tableData('<i>'||one_node.start_date||'</i>');
          htp.tableData('<i>'||one_node.end_date||'</i>');
          htp.tableData('<i>'||one_node.time_elapsed||'</i>', 'RIGHT');

        ELSIF (one_node.node_type = 'P') THEN

	  -- To be used by the task HREF
	  v_process_groups := get_parent_structure(v_upper_group_names, one_node.level, '\\');
	  v_ctx_type_name := one_node.context_type_name;

          htp.tableData('<b>'||lpad_nbsp(one_node.level)|| one_node.hierarchy ||
                        '</b>', 'LEFT', '', 'NOWRAP');
          htp.tableData(one_node.context_type_name);
          htp.tableData(one_node.context_name);
          htp.tableData(one_node.status_code_name, 'LEFT', '','NOWRAP');
          htp.tableData(one_node.start_date);
          htp.tableData(one_node.end_date);
          htp.tableData(one_node.time_elapsed, 'RIGHT');
          IF (one_node.comments IS NOT NULL) THEN
           htp.tableRowClose;
           htp.tableRowOpen;
           htp.tableData('<b>' || lpad_nbsp(one_node.level)||'('|| g_comments ||':'||
	           one_node.comments ||')</b>', 'LEFT', '', 'NOWRAP');
          END IF;
        ELSE
          get_task_type_key(one_node.node_id, v_item_type, v_item_key);
          v_href := '<A HREF=javascript:void(OpenURL("azw_report.task_details?' ||
			'p_process_groups=' || url_encode(v_process_groups) ||
			'&p_ctx_type=' || url_encode(v_ctx_type_name) ||
			'&p_status=' || url_encode(one_node.status_code_name) ||
			'&p_start=' || url_encode(one_node.start_date) ||
			'&p_end=' || url_encode(one_node.end_date)||
			'&p_time_elapsed=' || url_encode(one_node.time_elapsed) ||
          		'&p_item_type=' || v_item_type ||
          		'&p_item_key=' || v_item_key || '")) onMouseOver=window.status="'
          		|| g_task_details ||  '";return true>';
          htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
          htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
          htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
          htp.p('<TD ALIGN="LEFT" BGCOLOR="#DDDDDD" NOWRAP>'|| v_href || one_node.status_code_name || '</A></TD>');
	  htp.p('<TD ALIGN="LEFT" BGCOLOR="#DDDDDD" NOWRAP>'  || one_node.start_date || '</TD>');
          htp.p('<TD ALIGN="LEFT" BGCOLOR="#DDDDDD" NOWRAP>' || one_node.end_date || '&nbsp;</TD>');
     	  htp.p('<TD ALIGN="RIGHT" BGCOLOR="#DDDDDD" NOWRAP>'  || one_node.time_elapsed || '</TD>');
        END IF;
        htp.tableRowClose;
 /*
dbms_output.put_line('Name=' ||  one_node.hierarchy);
 dbms_output.put_line('Type=' ||  one_node.node_type);
 dbms_output.put_line('start=' ||  one_node.start_date);
 dbms_output.put_line('end=' ||  one_node.end_date);
*/
      END LOOP;
       htp.tableClose;
    ELSE
      print_time_stamp('Start of Temp Table Inserts');
      IF (p_time_or_period = 'T') THEN
        IF (p_operator = '<=') THEN
          FOR one_user IN valid_users_cursor LOOP
            get_user_trees_by_atmost(one_user.user_name, p_status,
                                     TO_NUMBER(p_days));
          END LOOP;
        ELSE
          FOR one_user IN valid_users_cursor LOOP
            get_user_trees_by_atleast(one_user.user_name, p_status,
                                      TO_NUMBER(p_days));
          END LOOP;
        END IF;
      ELSE
        FOR one_user IN valid_users_cursor LOOP
          get_user_trees_by_period(one_user.user_name, p_status, v_start,v_end);
        END LOOP;
      END IF;
      print_time_stamp('End of Temp Table Inserts');

      print_user_report_summary;

      print_legend_link;

      htp.p('<table border=0 cellpadding=1 cellspacing=1>');
      -- print hierarchy for each user
      htp.tableRowOpen;
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
          '<FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
           '<FONT CLASS="tableSubHeader">'|| g_ctxt_type ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
            '<FONT CLASS="tableSubHeader">'|| g_ctxt_name ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
            '<FONT CLASS="tableSubHeader">'|| g_status ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
            '<FONT CLASS="tableSubHeader">'|| g_start ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
            '<FONT CLASS="tableSubHeader">'|| g_end ||'</FONT></TD>');
      htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
            '<FONT CLASS="tableSubHeader">'|| g_duration ||'</FONT></TD>');
      htp.tableRowClose;

      i := 0;
      v_locator := 6;
      FOR one IN valid_users_cursor LOOP
        v_locator := 7;
        SELECT count(*)
        INTO v_count
        FROM az_monitor_reports
        WHERE assigned_user = one.user_name;
        v_locator := 8;
        IF (v_count <> 0) THEN
          IF (i > 0) THEN
            print_back_to_top(7);
          END IF;
          htp.p('<TR><TD ALIGN="LEFT" COLSPAN="7" BGCOLOR="#336699">' ||
  	    '<FONT CLASS="tableSubHeader"><A NAME="'|| one.user_name ||'">'||
  	    		g_user || ': ' || one.user_name || ' (' || one.display_name || ')'
  	    		|| '</A></FONT></TD></TR>');
          FOR one_node IN hierarchies_cursor(one.user_name) LOOP
            --
            --   Keep track of all the upper groups to be able to display
            --   them in a flat directory structure like
            --   "\Common Applications\System Administration\"
            --
            v_upper_group_names(one_node.level) := TRIM(one_node.hierarchy);
            htp.tableRowOpen;
            IF (one_node.parent_node_id IS NULL) THEN
              htp.p('<TR><TD ALIGN="LEFT" COLSPAN="7" BGCOLOR="#666666" ' ||
               'NOWRAP><i><FONT COLOR="#FFFFFF">' ||
               one_node.hierarchy || '</FONT></i></TD>');
            ELSIF (one_node.node_type = 'G') THEN
              htp.tableData('<i>'||lpad_nbsp(one_node.level) || one_node.hierarchy
                          ||'</i>', 'LEFT', '', 'NOWRAP');
              htp.tableData('<i>'||one_node.context_type_name||'</i>');
              htp.tableData('<i>'||one_node.context_name||'</i>');
              htp.tableData('<i>'||one_node.status_code_name||'</i>');
              htp.tableData('<i>'||one_node.start_date||'</i>');
              htp.tableData('<i>'||one_node.end_date||'</i>');
              htp.tableData('<i>'||one_node.time_elapsed||'</i>', 'RIGHT');
            ELSIF (one_node.node_type = 'P') THEN
    	      -- To be used by the task HREF
	      v_process_groups := get_parent_structure(
	      			v_upper_group_names,
	      			one_node.level, '\\');
	      v_ctx_type_name := one_node.context_type_name;
              htp.tableData('<b>'||lpad_nbsp(one_node.level) ||
              		one_node.hierarchy
                          ||'</b>', 'LEFT', '', 'NOWRAP');
              htp.tableData(one_node.context_type_name);
              htp.tableData(one_node.context_name);
              htp.tableData(one_node.status_code_name);
              htp.tableData(one_node.start_date);
              htp.tableData(one_node.end_date);
              htp.tableData(one_node.time_elapsed, 'RIGHT');
              IF (one_node.comments IS NOT NULL) THEN
                htp.tableRowClose;
                htp.tableRowOpen;
                htp.tableData('<b>' || lpad_nbsp(one_node.level)|| '('|| g_comments ||':'||
	                 one_node.comments || ')</b>', 'LEFT', '', 'NOWRAP');
              END IF;
            ELSE
              get_task_type_key(one_node.node_id, v_item_type, v_item_key);
              v_href := '<A HREF=javascript:void(OpenURL("' ||
          	'azw_report.task_details?' ||
			'p_process_groups=' || url_encode(v_process_groups) ||
			'&p_ctx_type=' || url_encode(v_ctx_type_name) ||
			'&p_status=' || url_encode(one_node.status_code_name) ||
			'&p_start=' || url_encode(one_node.start_date) ||
			'&p_end=' || url_encode(one_node.end_date)||
			'&p_time_elapsed=' || url_encode(one_node.time_elapsed) ||
          		'&p_item_type=' || v_item_type ||
          		'&p_item_key=' || v_item_key || '")) onMouseOver=window.status="'
          		|| g_task_details || '";return true>';
              htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
              htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
              htp.p('<td bgcolor=#DDDDDD>&nbsp;</td>');
              htp.p('<TD ALIGN="LEFT" BGCOLOR="#DDDDDD" NOWRAP>'|| v_href || one_node.status_code_name || '</A></TD>');
	      htp.p('<TD BGCOLOR="#DDDDDD" NOWRAP>' || one_node.start_date || '</A></TD>');
              htp.p('<TD BGCOLOR="#DDDDDD" NOWRAP>' || one_node.end_date || '</A>&nbsp;</TD>');
     	      htp.p('<TD ALIGN="RIGHT" BGCOLOR="#DDDDDD" NOWRAP>' ||  one_node.time_elapsed || '</A></TD>');
            END IF;
            htp.tableRowClose;
          END LOOP;
          i := i + 1;
        END IF;
      END LOOP;
      print_back_to_top(7);
      htp.tableClose;
    END IF;

    -- print Table closing tag
    -- htp.tableClose;

    -- print report legend
    print_legend (TRUE);

    -- print related report links
    print_related_reports('AZW_RPT_ISR');
    print_time_stamp('End of Report');
    COMMIT;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- print Table closing tag
      htp.tableClose;
      print_related_reports('AZW_RPT_ISR');
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'USER_REPORT', 'v_locator := ' || v_locator);
  END user_report;

/*
**
**	PRIINT_USER_REPORT_SUMMARY
**	==========================
**
**	Private Procedure.
**	It displays the report summary which contains the total number
**	of tasks for each user specified in the temp table az_monitor_reports.
**
*/
PROCEDURE print_user_report_summary IS

  CURSOR user_task_count IS
    SELECT ASSIGNED_USER, COUNT(NODE_TYPE) NUM_TASKS
    FROM AZ_MONITOR_REPORTS
    WHERE NODE_TYPE='T'
    GROUP BY ASSIGNED_USER;

BEGIN
  -- Print the Table header
  htp.p('<TABLE ALIGN="center" BORDER="1" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="2">' ||
  	'<FONT CLASS="tableHeader"><A NAME="TOP">' || g_summary
  		||'</A></FONT></TD></TR>');
  htp.p('<TR>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699" ><FONT CLASS="tableSubHeader">'||
  		g_user ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699" ><FONT CLASS="tableSubHeader">'||
  		g_num_tasks ||'</FONT></TD>');
  htp.p('</TR>');


  FOR  current_rec IN user_task_count LOOP
    htp.p('<TR><TD ALIGN="LEFT"><A HREF="#'|| current_rec.assigned_user ||'">'||
    	current_rec.assigned_user ||'</A></TD>');
    htp.p('<TD ALIGN="CENTER">'|| current_rec.num_tasks ||'</TD></TR>');
  END LOOP;
  htp.p('</TABLE><BR>');
  return;

EXCEPTION
  WHEN application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    raise_error_msg (SQLCODE, SQLERRM,
	  'PRIINT_USER_REPORT_SUMMARY', '');
END print_user_report_summary;

/*
**	RAISE_ERROR_MSG
**	===============
**
**	It generates a generic error message for all the reports.
**	It is called from all exception handling blocks.
**
*/
PROCEDURE raise_error_msg (
			ErrCode		IN NUMBER,
			ErrMsg 		IN VARCHAR2,
			ProcedureName   IN VARCHAR2,
  			Statement 	IN VARCHAR2) IS

  v_message VARCHAR2(2048);
BEGIN
  v_message := SUBSTR(fnd_message.get_string('AZ',
    		'AZW_PLSQL_EXCEPTION'), 1, 2048);

  v_message := REPLACE(v_message, '&AZW_ERROR_CODE', ErrCode);
  v_message := REPLACE(v_message, '&AZW_ERROR_MESG', ErrMsg);
  v_message := REPLACE(v_message, '&AZW_ERROR_PROC',
  		'AZW_REPORT.' || ProcedureName);
  IF (Statement IS NOT NULL) THEN
    v_message := REPLACE(v_message, '&AZW_ERROR_STMT', Statement);
  ELSE
    v_message := REPLACE(v_message, '&AZW_ERROR_STMT', 'v_locator := 0');
  END IF;
  --
  -- ErrMsg must not be more than 2048 bytes
  --
  raise_application_error(-20001, v_message);

END raise_error_msg;

/*
**
**	PRINT_TIME_STAMP
**	================
**
**	It displays the system time with the associated message
**	as an HTML comment, it would be visible only in the HTML
**	source.
**	It is used for performance issues and to know how long
**	a certain process is taking by calling this function
**	before and after the process.
**
*/
PROCEDURE print_time_stamp (v_string VARCHAR2) IS

BEGIN
--   htp.p('<!-- '|| v_string ||' =['|| TO_CHAR(SYSDATE, 'HH24:MI:SS') ||'] -->');
 NULL;
END print_time_stamp;

/*
**
**	PRINT_LEGEND_LINK
**	=================
**
**	It displays the hyperlink to the report legend table.
**	at the bottom of the report.
**
*/
PROCEDURE print_legend_link IS

BEGIN
  htp.p('<TABLE ALIGN="CENTER" BORDER="0" CELLPADDING="1" CELLSPACING="1" WIDTH="100%">');
  htp.p('<TR><TD ALIGN="CENTER"><A HREF="#LEGEND"><FONT SIZE="-1">' ||
  		g_report_legend || '</FONT></A></TD></TR>');
  htp.p('</TABLE>');
  htp.p('<BR>');
END print_legend_link;

/*
**
**	PRINT_LEGEND
**	============
**
**	It displays the report legend table.
**
*/
PROCEDURE print_legend (p_status BOOLEAN DEFAULT FALSE) IS

BEGIN
  htp.p('<BR>');
  htp.p('<TABLE ALIGN="CENTER" BORDER="1" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<A NAME="LEGEND"><FONT CLASS="tableHeader">' || g_report_legend ||'</A></FONT></TD></TR>');
  htp.p('<TR><TD BGCOLOR="#666666"><i><FONT COLOR="#FFFFFF">'|| g_group_legend ||'</FONT></i></TD></TR>');
  htp.p('<TR><TD><i>'|| g_subgrp_legend ||'</i></TD></TR>');
  htp.p('<TR><TD><b>'|| g_process_legend ||'</b></TD></TR>');
  IF (p_status) THEN
    htp.p('<TR><TD BGCOLOR="#DDDDDD">'|| g_task_legend ||'</TD></TR>');
  END IF;
  htp.tableClose;
END print_legend;

/*
**
**	TASK_DETAILS
**	============
**
**	It displays the step details for the specified task.
**	The status reports should have a hyper link for each
**	task that calls this procedure.
**
*/
PROCEDURE task_details (
		p_process_groups IN VARCHAR2,
		p_ctx_type IN VARCHAR2,
		p_status IN VARCHAR2,
		p_start IN VARCHAR2,
		p_end IN VARCHAR2,
		p_time_elapsed IN VARCHAR2,
		p_item_type IN VARCHAR2,
		p_item_key  IN VARCHAR2) IS

v_process_name       wf_items.root_activity%TYPE;

BEGIN
  g_help_target := get_report_procedure('AZW_RPT_ISRR');
  IF (g_web_agent IS NULL) THEN
    get_web_agent;
    get_translated_labels;
  END IF;
  htp.p('<HTML>');
  htp.title(g_task_details);
  print_html_style;
  htp.p('<BODY>');

  -- Print the Table header
  htp.p('<TABLE ALIGN="center" BORDER="0" CELLPADDING="1" CELLSPACING="1">');
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="6">' ||
  	'<FONT CLASS="tableHeader">' || g_task_params ||'</FONT></TD></TR>');
  htp.tableRowOpen;
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_ctxt_type ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_status ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_start ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_end ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699">' ||
  	'<FONT CLASS="tableSubHeader">'|| g_duration ||'</FONT></TD>');
  htp.tableRowClose;
  htp.tableRowOpen;

  --
  --
  --
  g_curr_process_level := 1;
  g_upper_process_names(1) := SUBSTR(p_process_groups, INSTR(p_process_groups, '\', -1) + 1);
  htp.p('<TD>' || p_process_groups ||'</TD>');
  htp.p('<TD>' || p_ctx_type ||'</TD>');
  htp.p('<TD>' || p_status ||'</TD>');
  htp.p('<TD>' || p_start ||'</TD>');
  htp.p('<TD>' || p_end ||'</TD>');
  htp.p('<TD>' || p_time_elapsed ||'</TD>');
  htp.tableRowClose;
  htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="6">' ||
  	'<FONT CLASS="tableHeader">' || g_task_details ||'</FONT></TD></TR>');
  htp.p('<TR>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699" ><FONT CLASS="tableSubHeader">'||
  		g_hierarchy ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699" ><FONT CLASS="tableSubHeader">'||
  		g_step_name ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699" ><FONT CLASS="tableSubHeader">'||
  		g_step_response ||'</FONT></TD>');
  htp.p('<TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="3"><FONT CLASS="tableSubHeader">'||
  		g_comments ||'</FONT></TD>');
  htp.p('</TR>');

  --
  --  Get the main process name
  --
  SELECT root_activity INTO v_process_name
  FROM wf_items
  WHERE item_type = p_item_type
  AND   item_key = p_item_key;

  --
  --  Update the global array of the upper process names
  --
  g_curr_process_level := 1;
  g_upper_process_names(1) := SUBSTR(p_process_groups, INSTR(p_process_groups, '\', -1) + 1);
  htp.p('<TR BGCOLOR="#666666"><TD><FONT COLOR="#FFFFFF">' ||
             g_upper_process_names(g_curr_process_level)
             || '</FONT></TD><TD COLSPAN="5">&nbsp;</TD></TR>');

  --
  --  Call the print task steps procedure by level equal to 1
  --  which mean call it by the main process name.
  --
  print_task_steps(p_item_type, p_item_key, v_process_name, 1);

  htp.p('</TABLE>');
  htp.p('</BODY></HTML>');
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'TASK_DETAILS', '');
END task_details;

/*
**
**      PRINT_TASK_STEPS
**      ================
**
**      Private procedure.
**      It prints the task steps that the user went through for
**      the specified process name. This function is recuerssive.
**      It prints all the notices and functions except start
**      and end. When a sub-process is encountered it calls itself
**      and so on. This function will keep track of the process names
**      that it passed though in a temp array to display the process
**      hierarchy when a sub-process is encountered. To show the
**      subprocess the same way it is shown in the Product Planning
**      report.
**
*/

PROCEDURE print_task_steps(
           p_item_type     IN VARCHAR2,
           p_item_key      IN VARCHAR2,
           p_process_name  IN VARCHAR2,
           p_process_level IN NUMBER) IS

  CURSOR process_steps IS
    SELECT wiasv.activity_type_code type
             ,wiasv.activity_name name
             ,wiasv.activity_display_name display_name
             ,wiasv.activity_result_display_name result_name
             ,wiasv.activity_begin_date begin_date
             ,wiasv.activity_end_date end_date
             ,wiasv.notification_id
    FROM   wf_item_activity_statuses_v wiasv,
           wf_process_activities wpa
    WHERE wiasv.item_type = p_item_type
    AND   wiasv.item_key  = p_item_key
    AND   wiasv.item_type = wpa.process_item_type
    AND   wpa.process_name = p_process_name
    AND   wpa.instance_id = wiasv.activity_id
    ORDER BY 5, 6;
 v_user_comments  wf_notifications.user_comment%TYPE := NULL;
BEGIN

    --
    -- Start looping through all the steps for the current specified process
    --
    FOR step IN process_steps LOOP
      --
      --  Get the user comment if there is a notification
      --
      IF step.notification_id IS NOT NULL THEN
        SELECT user_comment INTO v_user_comments
        FROM wf_notifications
        WHERE notification_id  = step.notification_id;
     END IF;

     IF step.type = 'PROCESS' THEN
        --
        --  fill the global array with the process names
        --  to use it in displaying the process hierarchy
        --  for all sub-processes.
        --
        g_curr_process_level := p_process_level + 1;
        g_upper_process_names(g_curr_process_level) := step.display_name;
        htp.p('<TR BGCOLOR="#DDDDDD"><TD>' ||
                        get_parent_structure(g_upper_process_names, g_curr_process_level)
                        || '</TD><TD COLSPAN="5">&nbsp;</TD></TR>');
        print_task_steps(p_item_type, p_item_key, step.name, g_curr_process_level);
      ELSIF step.type = 'FUNCTION' AND step.name = 'START' THEN
        NULL;
      ELSIF step.type = 'FUNCTION' AND step.name = 'END' THEN
        IF p_process_level > 1 THEN
          htp.p('<TR><TD>&nbsp;</TD><TD COLSPAN=5 BGCOLOR="#DDDDDD">&nbsp;<TD></TR>');
        END IF;
        g_curr_process_level := g_curr_process_level - 1;
      ELSE
        htp.p('<TR><TD>&nbsp;</TD>');
        htp.p('<TD>'||step.display_name ||'</TD>');
        htp.p('<TD>'||step.result_name ||'</TD>');
        htp.p('<TD>'||v_user_comments ||'</TD></TR>');
      END IF;
    END LOOP;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM, 'PRINT_TASK_STEPS', '');
END print_task_steps;

/*
**
**	GET_TASK_TYPE_KEY
**	=================
**
**	The node id specified in the az_monitor_reports temp
**	table is composed of multiple fields. two of them are
**	the item_type and item_key fields.
**	this procedure extracts and returns these two fields
**	from the input node_id.
**	It is called from the status and user report, to be
**	able to build the URL that display the step details
**	for each task.
**
*/
PROCEDURE get_task_type_key (p_node_id   IN VARCHAR2,
			     p_item_type OUT VARCHAR2,
			     p_item_key  OUT VARCHAR2) IS
BEGIN

  p_item_type := TRIM(SUBSTR(p_node_id, 1, (INSTR(p_node_id, '.', 1) - 1)));
  p_item_key := TRIM(SUBSTR(p_node_id, (INSTR(p_node_id, '.', -1) + 1)));
  --
  -- Remove leading zeros
  --
  WHILE (INSTR(p_item_key, '0', 1) = 1) LOOP
    p_item_key := SUBSTR(p_item_key, 2);
  END LOOP;
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'GET_TASK_TYPE_KEY', '');
END get_task_type_key;

/*
**
**	SHOW_ALL_STEPS
**	==============
**
**	It displays the step details for all the processes
**	available for the specified products.
**	It will open a new window showing the steps that he
**	user needs to go through in order to implement the
**	selected products.
**
*/
PROCEDURE show_all_steps(p_selected_products IN VARCHAR2) IS


    v_current_id	az_groups.application_id%TYPE;
    i 			INTEGER;

     CURSOR hierarchies_cursor IS
      SELECT     display_name hierarchy,
                 node_type,
                 description,
                 parent_node_id,
                 node_id,
                 context_type_name,
                 LEVEL
      FROM       az_planning_reports
      START WITH parent_node_id IS NULL
      CONNECT BY PRIOR node_id = parent_node_id
      AND	 PRIOR phase = phase;

     v_item_type 	wf_process_activities.PROCESS_ITEM_TYPE%TYPE;
     v_process_name	wf_process_activities.PROCESS_NAME%TYPE;

     v_process_groups		VARCHAR2(4000);
     v_last_printed		VARCHAR2(4000);
     v_upper_group_names 	HierarchyLevels;
     v_app_id     NUMBER;
     v_cnt        BINARY_INTEGER;
     v_ids        id_tbl_t;
     v_count	 PLS_INTEGER;
     v_locator	 PLS_INTEGER := 0;

  BEGIN

    IF (g_web_agent IS NULL) THEN
      get_web_agent;
      get_translated_labels;
    END IF;
    v_locator := 1;

    htp.htmlOpen;
    htp.headOpen;
    htp.title(g_step_details);
    htp.headClose;


    --
    -- get the product list string into the id table
    --
    v_cnt := 1;
    v_locator := 2;
    v_app_id := azw_proc.parse_application_ids(p_selected_products, v_cnt);
    WHILE (v_app_id > -1) LOOP
      v_ids(v_cnt) := v_app_id;
      v_cnt := v_cnt + 1;
      v_app_id := azw_proc.parse_application_ids(p_selected_products, v_cnt);
    END LOOP;

    print_html_style;

    print_selected_prods_table(v_ids);

    print_step_details_header;

    v_locator := 3;
    FOR i IN 1..v_ids.COUNT LOOP
      get_product_processes(v_ids(i));
    END LOOP;


    v_locator := 4;
    FOR one_node IN hierarchies_cursor LOOP
      --
      --   Keep track of all the upper groups to be able to display
      --   them in a flat directory structure like
      --   "\Common Applications\System Administration\"
      --
      v_upper_group_names(one_node.level) := TRIM(one_node.hierarchy);

      IF (one_node.node_type = 'P') THEN
         v_locator := 5;
         v_process_groups := get_parent_structure(v_upper_group_names, one_node.level - 1);
         IF v_process_groups = v_last_printed THEN
           v_process_groups := '&nbsp;';
         ELSE
           v_last_printed := v_process_groups;
        END IF;
        get_process_type_name (one_node.node_id, v_item_type, v_process_name);
        v_locator := 6;
        display_process_steps(p_selected_products,
        		v_item_type,
        		v_process_name,
                        one_node.context_type_name,
        		v_process_groups,
        		'YES');
        v_locator := 8;
      END IF;
    END LOOP;
    v_locator := 7;
    htp.p('</TABLE>');
    htp.p('</BODY>');
    htp.htmlClose;
    COMMIT;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'SHOW_ALL_STEPS', 'v_locator := ' || v_locator);
END show_all_steps;

/*
**
**	PRINT_STEP_DETAILS_HEADER
**	=========================
**
**	This procedure displays the report header an table header
**	for the step details reports.
**	Called from show_all_steps and from show_process_steps.
**
*/
PROCEDURE print_step_details_header (p_display_msg IN VARCHAR2 DEFAULT NULL) IS
 v_colspan	PLS_INTEGER;

BEGIN
     IF (p_display_msg = 'YES') THEN
        htp.htmlOpen;
        htp.headOpen;
        htp.title(g_step_details);
        htp.headClose;
	v_colspan := 4;
     ELSE
	v_colspan := 3;
     END IF;

    print_html_style;
    htp.p('<body bgcolor=#FFFFFF>');
    htp.p('<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">');
    htp.p('<TR><TD ALIGN="CENTER" BGCOLOR="#336699" COLSPAN="'|| v_colspan ||'">' ||
  	'<FONT CLASS="tableHeader">' || g_step_details ||'</FONT></TD></TR>');
    htp.p('<TR><TH ALIGN="LEFT" BGCOLOR="#336699" '||
     	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_hierarchy ||'</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">' || g_process || '</FONT></TH>');
    htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_steps ||'</FONT></TH>');
    IF (p_display_msg = 'YES') THEN
      htp.p('<TH ALIGN="LEFT" BGCOLOR="#336699" '||
      	'NOWRAP><FONT CLASS="tableSubHeader">'|| g_step_msg ||'</FONT></TH>');
    END IF;
    htp.p('</TR>');
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_STEP_DETAILS_HEADER', '');
END print_step_details_header;

/*
**
**	DISPLAY_PROCESS_STEPS
**	=====================
**
**	Public Procedure.
**	It displays all the available steps for the specified
**	process. It displays the activities in the same order
**	of the work flow activities if the selected products
**	are installed.
**	It can be called as an an external procedure that
**	displays the available steps for the specified process.
**	It can be called from show_all_steps.
**	And it can be called to display a subprocess, from
**	print_activity.
**
*/
PROCEDURE display_process_steps (
		    p_selected_products		IN VARCHAR2,
		    p_item_type  		IN VARCHAR2,
                    p_process_name 		IN VARCHAR2,
                    p_context_type_name 	IN VARCHAR2,
                    p_process_groups 		IN VARCHAR2,
		    p_new_call 			IN VARCHAR2 DEFAULT NULL,
		    p_external_call		IN VARCHAR2 DEFAULT NULL) IS

    l_dname  		wf_activities_vl.display_name%TYPE;
    proc_version 	NUMBER;

    CURSOR start_act_cur IS
      select instance_id, activity_name, start_end
      FROM wf_process_activities wpa
      where wpa.process_item_type = p_item_type
      and   wpa.process_name = p_process_name
      and   wpa.start_end = 'START'
      and   wpa.process_version = proc_version;

    v_locator  PLS_INTEGER := 0;

  BEGIN

    IF (p_external_call = 'YES') AND (g_FirstTime) THEN
      IF (g_web_agent IS NULL) THEN
      	get_web_agent;
      	get_translated_labels;
      END IF;
      v_locator := 1;
      print_step_details_header(p_external_call);
      g_FirstTime := FALSE;
    END IF;

    v_locator := 2;

    select display_name, version
    into l_dname, proc_version
    from wf_activities_vl wav
    where wav.item_type = p_item_type
    and   wav.name = p_process_name
    and   wav.end_date IS NULL;

    v_locator := 3;
    IF (p_new_call = 'YES') THEN
      g_curr_process_level := 1;
      g_upper_process_names(1) := l_dname;
      v_locator := 4;
      --
      --  Delete the records found in the
      --  g_instance_ids table array.
      --
      g_instance_ids.DELETE;
      g_inst_count := 0;
    ELSE
      g_curr_process_level := g_curr_process_level + 1;
      g_upper_process_names(g_curr_process_level) := l_dname;
    END IF;

    IF (g_curr_process_level > 1) THEN
      htp.p('<TR><TD>&nbsp;</TD><TD BGCOLOR="#DDDDDD">'||
      		get_parent_structure(g_upper_process_names, g_curr_process_level) ||
      		'</TD><TD BGCOLOR="#DDDDDD">&nbsp;</TD>');
      g_prev_act_name := NULL;
    ELSE
      htp.p('<TR><TD BGCOLOR="#666666"><FONT COLOR="#FFFFFF">' || p_process_groups ||
      	 	'</FONT></TD><TD BGCOLOR="#666666"><FONT COLOR="#FFFFFF">'||
      		get_parent_structure(g_upper_process_names, g_curr_process_level));
      IF (p_context_type_name IS NOT NULL) THEN
        htp.p('(' || p_context_type_name || ')');
      END IF;
      htp.p('</FONT></TD><TD BGCOLOR="#666666">&nbsp;</TD>');
    END IF;

    IF (p_external_call = 'YES') THEN
      IF (g_curr_process_level > 1) THEN
        htp.p('<TD BGCOLOR="#DDDDDD">&nbsp;</TD>');
      ELSE
        htp.p('<TD BGCOLOR="#666666">&nbsp;</TD>');
      END IF;
    END IF;
    htp.p('</TR>');

    --
    -- 	Display each link.
    --
    v_locator := 6;
    FOR each_start IN start_act_cur LOOP
      IF (is_act_notfound(each_start.instance_id)) THEN
	add_instance_to_array(each_start.instance_id);
        print_activity (p_selected_products, each_start.instance_id, p_external_call);
      END IF;
    END LOOP;

    IF (p_external_call = 'YES') AND (p_new_call = 'YES') THEN
      htp.p('</TABLE></BODY></HTML>');
    END IF;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'DISPLAY_PROCESS_STEPS', 'v_locator := ' || v_locator);
END display_process_steps;

/*
**
**	PRINT_ACTIVITY
**	==============
**
** 	Private procedure.
**	It prints the activity if it is a notice according to the
**	response order. It calls display_process if a subprocess is
**	encountered. It is a recursive function that displays all the
**	next activities in the path according to the response code.
**	If it is a function it decides which path to take by calling
**	check_activity_products function.
**
*/
PROCEDURE print_activity(
		p_selected_products 	IN VARCHAR2,
		p_instance_id 		IN NUMBER,
		p_display_msg 		IN VARCHAR2) IS

    l_act_type wf_activities.type%TYPE;
    l_mesg     wf_activities_vl.message%TYPE;
    l_dname    wf_activities_vl.display_name%TYPE;

    l_body     wf_messages_vl.body%TYPE;

    act_type wf_process_activities.activity_item_type%TYPE;
    act_name wf_process_activities.activity_name%TYPE;
    v_result	VARCHAR2(200);

    CURSOR act_cur IS
      SELECT wat.to_process_activity instance_id, result_code
      from  wf_activity_transitions wat
      where wat.from_process_activity = p_instance_id
      order By result_code;

  BEGIN

    select activity_item_type, activity_name
    into act_type, act_name
    from wf_process_activities wpa
    where wpa.instance_id = p_instance_id;

    select type, message, display_name
    into l_act_type, l_mesg, l_dname
    from wf_activities_vl wav
    where wav.item_type = act_type
    and   wav.name = act_name
    and   wav.end_date IS NULL;

    IF l_act_type = 'NOTICE' THEN

      -- To show an empty line at the end of a sub-process
      -- if it is followed by a NOTICE
      IF (g_prev_act_name = 'END') THEN
        IF (p_display_msg = 'YES') THEN
          htp.p('<TR><TD COLSPAN="2">&nbsp;</TD><TD BGCOLOR="#DDDDDD" COLSPAN="2">&nbsp;</TD></TR>');
        ELSE
          htp.p('<TR><TD COLSPAN="2">&nbsp;</TD><TD BGCOLOR="#DDDDDD">&nbsp;</TD></TR>');
        END IF;
        g_prev_act_name := NULL;
      END IF;

      IF (p_display_msg = 'YES') THEN
        select body into l_body
        from wf_messages_vl wmv
        where wmv.type = act_type
        and   wmv.name = l_mesg;
        htp.p('<TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD VALIGN="TOP">'||
		 l_dname ||'</TD><TD>'|| format_step_body(l_body) ||'</TD></TR>');
        htp.p('<TR><TD COLSPAN="4">&nbsp;</TD></TR>');
      ELSE
        htp.p('<TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>'|| l_dname ||'</TD></TR>');
      END IF;
    ELSIF l_act_type = 'PROCESS' THEN
      display_process_steps(p_selected_products,
      			act_type,
      			act_name,
      			'&nbsp;',
      			'&nbsp;',
      			'NO',
      			p_display_msg);
      g_curr_process_level := g_curr_process_level - 1;
    ELSIF (l_act_type = 'FUNCTION' AND (act_name <> 'START' AND act_name <> 'END')) THEN
      --
      --  Check if any of the selected products
      --  exist in the activity installed products.
      --
      v_result := check_activity_products(p_selected_products, p_instance_id);
    ELSIF (l_act_type = 'FUNCTION' AND act_name = 'END') THEN
      g_prev_act_name := 'END';
    ELSE
      g_prev_act_name := NULL;
    END IF;

    --
    -- For each process/activity linked to the specified
    -- activity.
    --
    FOR each_act IN act_cur LOOP
      IF (is_act_notfound(each_act.instance_id)) THEN
	IF (l_act_type <> 'FUNCTION') OR
	   (l_act_type = 'FUNCTION' AND (act_name = 'START' OR act_name = 'END')) OR
	   ((l_act_type = 'FUNCTION') AND (v_result = each_act.result_code)) THEN
	  add_instance_to_array(each_act.instance_id);
          print_activity(p_selected_products, each_act.instance_id, p_display_msg);
        END IF;
      END IF;
    END LOOP;

EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_ACTIVITY', '');
END print_activity;

/*
**
**	PRINT_JS_OPEN_URL
**	=================
**
**	This procedure displays the Java Script required to open
**	a URL in a new window and set focus to it.
**
*/
PROCEDURE print_js_open_url (blnStep IN BOOLEAN DEFAULT FALSE) IS

BEGIN
  htp.p('<SCRIPT LANGUAGE=Javascript>');
  htp.p('function OpenURL(vURL)');
  htp.p('{');
  IF (blnStep) THEN
    htp.p('    var NewWindow = window.open(vURL, "STEPS", ');
  ELSE
    htp.p('    var NewWindow = window.open(vURL, "TASKS", ');
  END IF;

   htp.p('"scrollbars=yes,menubar=yes,toolbar=no,status=yes,location=no,resizable=yes");');

   htp.p('    NewWindow.focus();');
   htp.p('}');
   htp.p('</SCRIPT>');
EXCEPTION
    WHEN application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      raise_error_msg (SQLCODE, SQLERRM,
 	  'PRINT_JS_OPEN_URL', '');
END print_js_open_url;

END AZW_REPORT;

/
