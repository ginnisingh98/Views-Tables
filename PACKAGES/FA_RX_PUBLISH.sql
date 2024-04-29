--------------------------------------------------------
--  DDL for Package FA_RX_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_PUBLISH" AUTHID CURRENT_USER as
/* $Header: FARXPBSS.pls 120.2.12010000.2 2009/07/19 11:59:46 glchen ship $ */

-------------------------------------------
-- Globals
-------------------------------------------
page_break_level CONSTANT NUMBER := -1;
page_carry_forward_level CONSTANT NUMBER := -2;
report_break_level CONSTANT NUMBER := -3;

--* Bug 8402286
--* This value is used in the package to get the message text, that needs to be shouwn in
--* the report heading. Refer to bug#4394814, for furhter details.
--*
G_Moac_Message_Code  Constant Varchar2(100) := 'FND_MO_RPT_PARTIAL_LEDGER';

--*
--* if this value is stored in the fnd_concurrent_programs.multi_org_category,
--* then we need to handle the MOAC changes, of displaying the message.
--*
G_Moac_Mo_Category_Conc_Flag Constant Varchar2(10) := 'M';



----------------------------------------------------------
-- This routine are used by the RXi publishing engine.
-- These routines are meant only to provide information
-- to the publishing engine.
--------
-- The following outlines the how these functions should be called:
--
--
-- Init_Report or Init_Request
-- Get_Report_Info
-- Loop
--	Start_Format
--	Get_Format_Info
--	For i in 1..Get_Param_Count Loop
--		Get_Parameter
--	End Loop
--	For i in 1..Get_Break_Level_Count Loop
--		For j in 1..Get_Column_Count(i) Loop
--			Get_Column_Info
--		End Loop
--		For j in 1..Get_Summary_Column_Count(i) Loop
--			Get_Summary_Column_Info
--		End Loop
--	End Loop
--
--	Output Data
--
--	End_Format
-- While Format_Available
----------------------------------------------------------




------------------------------------------------------------------
-- Get_Report_Name
--
-- Given a report_id, this routine returns
-- the application short name and concurrent program name of the
-- associated concurrent program.
-- If this is a Direct Select RX, it will return a NULL value
-- for p_appname and p_concname
------------------------------------------------------------------
PROCEDURE get_report_name(
	p_report_id IN NUMBER,
	p_appname OUT NOCOPY VARCHAR2,
	p_concname OUT NOCOPY VARCHAR2);

------------------------------------------------------------------
-- Init_Request
--
-- Initializes this package with the given request ID, report ID,
-- attribute set and output format.
-- Should not call this for Direct Select RX.
-- Should only be called once per session.
------------------------------------------------------------------
PROCEDURE init_request(p_request_id IN NUMBER,
		       p_report_id IN NUMBER,
		       p_attribute_set IN VARCHAR2,
		       p_output_format IN VARCHAR2,
		       p_request_type IN VARCHAR2 DEFAULT 'PUBLISH');

------------------------------------------------------------------
-- Init_Report
--
-- Initializes this package with the given report ID, attribute
-- set, output format, and concurrent program arguments.
-- This routine should only be called for Direct Select RX.
-- This routine should only be called once per session.
------------------------------------------------------------------
PROCEDURE init_report(
	p_report_id IN NUMBER,
	p_attribute_set IN VARCHAR2,
	p_output_format IN VARCHAR2,
	p_argument1 IN VARCHAR2 ,
	p_argument2 IN VARCHAR2 ,
	p_argument3 IN VARCHAR2 ,
	p_argument4 IN VARCHAR2 ,
	p_argument5 IN VARCHAR2 ,
	p_argument6 IN VARCHAR2 ,
	p_argument7 IN VARCHAR2 ,
	p_argument8 IN VARCHAR2 ,
	p_argument9 IN VARCHAR2 ,
	p_argument10 IN VARCHAR2 ,
	p_argument11 IN VARCHAR2 ,
	p_argument12 IN VARCHAR2 ,
	p_argument13 IN VARCHAR2 ,
	p_argument14 IN VARCHAR2 ,
	p_argument15 IN VARCHAR2 ,
	p_argument16 IN VARCHAR2 ,
	p_argument17 IN VARCHAR2 ,
	p_argument18 IN VARCHAR2 ,
	p_argument19 IN VARCHAR2 ,
	p_argument20 IN VARCHAR2 ,
	p_argument21 IN VARCHAR2 ,
	p_argument22 IN VARCHAR2 ,
	p_argument23 IN VARCHAR2 ,
	p_argument24 IN VARCHAR2 ,
	p_argument25 IN VARCHAR2 ,
	p_argument26 IN VARCHAR2 ,
	p_argument27 IN VARCHAR2 ,
	p_argument28 IN VARCHAR2 ,
	p_argument29 IN VARCHAR2 ,
	p_argument30 IN VARCHAR2 ,
	p_argument31 IN VARCHAR2 ,
	p_argument32 IN VARCHAR2 ,
	p_argument33 IN VARCHAR2 ,
	p_argument34 IN VARCHAR2 ,
	p_argument35 IN VARCHAR2 ,
	p_argument36 IN VARCHAR2 ,
	p_argument37 IN VARCHAR2 ,
	p_argument38 IN VARCHAR2 ,
	p_argument39 IN VARCHAR2 ,
	p_argument40 IN VARCHAR2 ,
	p_argument41 IN VARCHAR2 ,
	p_argument42 IN VARCHAR2 ,
	p_argument43 IN VARCHAR2 ,
	p_argument44 IN VARCHAR2 ,
	p_argument45 IN VARCHAR2 ,
	p_argument46 IN VARCHAR2 ,
	p_argument47 IN VARCHAR2 ,
	p_argument48 IN VARCHAR2 ,
	p_argument49 IN VARCHAR2 ,
	p_argument50 IN VARCHAR2 ,
	p_argument51 IN VARCHAR2 ,
	p_argument52 IN VARCHAR2 ,
	p_argument53 IN VARCHAR2 ,
	p_argument54 IN VARCHAR2 ,
	p_argument55 IN VARCHAR2 ,
	p_argument56 IN VARCHAR2 ,
	p_argument57 IN VARCHAR2 ,
	p_argument58 IN VARCHAR2 ,
	p_argument59 IN VARCHAR2 ,
	p_argument60 IN VARCHAR2 ,
	p_argument61 IN VARCHAR2 ,
	p_argument62 IN VARCHAR2 ,
	p_argument63 IN VARCHAR2 ,
	p_argument64 IN VARCHAR2 ,
	p_argument65 IN VARCHAR2 ,
	p_argument66 IN VARCHAR2 ,
	p_argument67 IN VARCHAR2 ,
	p_argument68 IN VARCHAR2 ,
	p_argument69 IN VARCHAR2 ,
	p_argument70 IN VARCHAR2 ,
	p_argument71 IN VARCHAR2 ,
	p_argument72 IN VARCHAR2 ,
	p_argument73 IN VARCHAR2 ,
	p_argument74 IN VARCHAR2 ,
	p_argument75 IN VARCHAR2 ,
	p_argument76 IN VARCHAR2 ,
	p_argument77 IN VARCHAR2 ,
	p_argument78 IN VARCHAR2 ,
	p_argument79 IN VARCHAR2 ,
	p_argument80 IN VARCHAR2 ,
	p_argument81 IN VARCHAR2 ,
	p_argument82 IN VARCHAR2 ,
	p_argument83 IN VARCHAR2 ,
	p_argument84 IN VARCHAR2 ,
	p_argument85 IN VARCHAR2 ,
	p_argument86 IN VARCHAR2 ,
	p_argument87 IN VARCHAR2 ,
	p_argument88 IN VARCHAR2 ,
	p_argument89 IN VARCHAR2 ,
	p_argument90 IN VARCHAR2 ,
	p_argument91 IN VARCHAR2 ,
	p_argument92 IN VARCHAR2 ,
	p_argument93 IN VARCHAR2 ,
	p_argument94 IN VARCHAR2 ,
	p_argument95 IN VARCHAR2 ,
	p_argument96 IN VARCHAR2 ,
	p_argument97 IN VARCHAR2 ,
	p_argument98 IN VARCHAR2 ,
	p_argument99 IN VARCHAR2 ,
	p_argument100 IN VARCHAR2 );

------------------------------------------------------------------
-- Get_Report_Info
--
-- This routine returns report level information.
-- These are information that should not change between formats.
------------------------------------------------------------------
PROCEDURE get_report_info(
	p_display_report_title OUT NOCOPY VARCHAR2,
	p_display_set_of_books OUT NOCOPY VARCHAR2,
	p_display_functional_currency OUT NOCOPY VARCHAR2,
	p_display_submission_date OUT NOCOPY VARCHAR2,
	p_display_current_page OUT NOCOPY VARCHAR2,
	p_display_total_page OUT NOCOPY VARCHAR2,
	p_report_title OUT NOCOPY VARCHAR2,
	p_set_of_books_name OUT NOCOPY VARCHAR2,
	p_function_currency_prompt OUT NOCOPY VARCHAR2,
	p_function_currency OUT NOCOPY VARCHAR2,
	p_submission_date OUT NOCOPY VARCHAR2,
	p_report_date_prompt OUT NOCOPY VARCHAR2,  --* bug#2902895, rravunny
	p_current_page_prompt OUT NOCOPY VARCHAR2,
	p_total_page_prompt OUT NOCOPY VARCHAR2,
	p_page_width OUT NOCOPY NUMBER,
	p_page_height OUT NOCOPY NUMBER,
	p_output_format OUT NOCOPY VARCHAR2,
	p_nls_end_of_report OUT NOCOPY VARCHAR2,
	p_nls_no_data_found OUT NOCOPY VARCHAR2);

------------------------------------------------------------------
-- Bug 8460187: RER Project overloaded this function
-- Get_Report_Info
-- This routine returns report level information.
-- These are information that should not change between formats.
------------------------------------------------------------------
PROCEDURE get_report_info(
	p_display_report_title OUT NOCOPY VARCHAR2,
	p_display_set_of_books OUT NOCOPY VARCHAR2,
	p_display_functional_currency OUT NOCOPY VARCHAR2,
	p_display_submission_date OUT NOCOPY VARCHAR2,
	p_display_current_page OUT NOCOPY VARCHAR2,
	p_display_total_page OUT NOCOPY VARCHAR2,
	p_report_title OUT NOCOPY VARCHAR2,
	p_set_of_books_name OUT NOCOPY VARCHAR2,
	p_function_currency_prompt OUT NOCOPY VARCHAR2,
	p_function_currency OUT NOCOPY VARCHAR2,
	p_submission_date OUT NOCOPY VARCHAR2,
	p_current_page_prompt OUT NOCOPY VARCHAR2,
	p_total_page_prompt OUT NOCOPY VARCHAR2,
	p_page_width OUT NOCOPY NUMBER,
	p_page_height OUT NOCOPY NUMBER,
	p_output_format OUT NOCOPY VARCHAR2,
	p_nls_end_of_report OUT NOCOPY VARCHAR2,
	p_nls_no_data_found OUT NOCOPY VARCHAR2);

------------------------------------------------------------------
-- Get_Format_Info
--
-- This routine returns format level information.
-- These are information that may change from format to format.
------------------------------------------------------------------
PROCEDURE get_format_info(
	p_display_parameters OUT NOCOPY VARCHAR2,
	p_display_page_break OUT NOCOPY VARCHAR2,
	p_group_display_type OUT NOCOPY VARCHAR2);

------------------------------------------------------------------
-- Get_Param_Count
--
-- Returns the number of parameters for the current format.
------------------------------------------------------------------
FUNCTION get_param_count RETURN NUMBER;

------------------------------------------------------------------
-- Get_Parameter
--
-- Returns parameter information.
-- Must be called exact number of times as is returned by
-- Get_Param_Count.
------------------------------------------------------------------
PROCEDURE get_parameter(
	p_param_id    IN  NUMBER,
	p_param_name  OUT NOCOPY VARCHAR2,
	p_param_value OUT NOCOPY VARCHAR2);

------------------------------------------------------------------
-- Get_Break_Level
--
-- Returns the number of break levels in the current format.
------------------------------------------------------------------
FUNCTION get_break_level_count RETURN NUMBER;


------------------------------------------------------------------
-- Get_Column_Count
--
-- Returns the number of columns in the given break level.
-- Break level should be between 1 and the returned value of
-- Get_Break_Level.
------------------------------------------------------------------
FUNCTION get_column_count(
	p_break_level IN NUMBER) RETURN NUMBER;


------------------------------------------------------------------
-- Get_Column_Info
--
-- Returns the column information for the given break level.
-- This routine must be called as many times as is returned
-- by Get_Column_Count.
------------------------------------------------------------------
PROCEDURE get_column_info(
	p_break_level IN NUMBER,
	p_column_id OUT NOCOPY NUMBER,
	p_column_name OUT NOCOPY VARCHAR2,
	p_column_type OUT NOCOPY VARCHAR2,
	p_attribute_name OUT NOCOPY VARCHAR2,
	p_length OUT NOCOPY NUMBER,
	p_currency_column_id OUT NOCOPY NUMBER,
	p_precision OUT NOCOPY NUMBER,
	p_minimum_accountable_unit OUT NOCOPY NUMBER,
	p_break OUT NOCOPY VARCHAR2);

------------------------------------------------------------------
-- Get_Summary_Column_Count
--
-- Returns the number of summary columns in the given break level.
-- Break level should be between 1 and the returned value of
-- Get_Break_Level.
------------------------------------------------------------------
FUNCTION get_summary_column_count(
	p_break_level IN NUMBER) RETURN NUMBER;


------------------------------------------------------------------
-- Get_Summary_Column_Info
--
-- Returns the summary column information for the given break level.
-- This routine must be called as many times as is returned
-- by Get_Summary_Column_Count.
------------------------------------------------------------------
PROCEDURE get_summary_column_info(
	p_break_level IN NUMBER,
	p_summary_column_id OUT NOCOPY NUMBER,
	p_prompt OUT NOCOPY VARCHAR2,
	p_source_column_id OUT NOCOPY NUMBER);


------------------------------------------------------------------
-- Start_Format
--
-- This routine should be called at the beginning of every format.
------------------------------------------------------------------
PROCEDURE start_format;

------------------------------------------------------------------
-- End_Format
--
-- This routine should be called at the end of every format.
------------------------------------------------------------------
PROCEDURE end_format;

------------------------------------------------------------------
-- Format Available
--
-- This routine should be called after a format ends to determine
-- if there are any more formats.
------------------------------------------------------------------
FUNCTION format_available RETURN VARCHAR2;


------------------------------------------------------------------
-- Get_Select_Stmt
--
-- This routine returns the main select statment.
-- There will be no bind variables here.
------------------------------------------------------------------
FUNCTION get_select_stmt RETURN VARCHAR2;


------------------------------------------------------------------
-- Get_All_Column_Count
--
-- This routine returns the number of columns in the select
-- statement returned by Get_Select_Stmt
-- May return more than get_break_level_count * get_column_count
-- since the select statement may include currency columns
-- as well.
------------------------------------------------------------------
function get_all_column_count return number;
function get_disp_column_count return number;


------------------------------------------------------------------
-- Get_Format_Col_Info
--
-- This routine returns information required for formatting.
-- It will return the columns in order of the column_id returned
-- by Get_Column_Info. The p_currency_column_id returned here
-- will also point to a valid column_id returned by this routine.
------------------------------------------------------------------
PROCEDURE get_format_col_info(
	p_column_name OUT NOCOPY VARCHAR2,
	p_display_format OUT NOCOPY VARCHAR2,
	p_display_length OUT NOCOPY NUMBER,
	p_break_group_level OUT NOCOPY NUMBER,
	p_format_mask OUT NOCOPY VARCHAR2,
	p_currency_column_id OUT NOCOPY NUMBER,
	p_precision OUT NOCOPY NUMBER,
	p_minunit OUT NOCOPY NUMBER);


------------------------------------------------------------------
-- Get_All_Summary_Count
--
-- This routine returns the number of summary columns
------------------------------------------------------------------
FUNCTION get_all_summary_count RETURN NUMBER;

------------------------------------------------------------------
-- Get_Format_Sum_Info
--
-- This routine returns information about summary columns as required
-- to format.
-- p_source_column_id will point to a valid column_id returned
-- by Get_Format_Column_Info.
-- This routine will return the columns in order of p_summary_column_id
-- returned by Get_Summary_Column_Info
------------------------------------------------------------------
PROCEDURE get_format_sum_info(
	p_source_column_id OUT NOCOPY NUMBER,
	p_reset_level OUT NOCOPY NUMBER,
	p_compute_level OUT NOCOPY NUMBER,
	p_summary_function OUT NOCOPY VARCHAR2);

-----------------------------------------
-- Handle Bind variables
-----------------------------------------
FUNCTION get_bind_count RETURN NUMBER;
FUNCTION get_bind_variable RETURN VARCHAR2;

------------------------------------------------------------------
-- Get_Rows_Purged
--
-- This routine returns the number of rows purged.
------------------------------------------------------------------
PROCEDURE get_rows_purged(request_id IN VARCHAR2, l_report_id IN NUMBER,
                        l_purge_api OUT NOCOPY VARCHAR2, row_num out NUMBER);

Procedure Get_Moac_Message(xMoac_Message out NOCOPY Varchar2);

end fa_rx_publish;

/
