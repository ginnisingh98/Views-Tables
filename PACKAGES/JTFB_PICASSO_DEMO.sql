--------------------------------------------------------
--  DDL for Package JTFB_PICASSO_DEMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTFB_PICASSO_DEMO" AUTHID CURRENT_USER as
/* $Header: jtfbdems.pls 120.1 2005/07/02 02:33:21 appldev ship $ */
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name
--   jtfb_picasso_demo
--
-- Purpose
--    This package consists of procedures and functions to populate Demo data.
--
-- Functions
--    get_dynamic_footer
--    get_dynamic_name
--    get_dynamic_report_col2
--    get_dynamic_report_col4
--    get_dynamic_report_col6
--    get_dynamic_report_col8
--    get_dynamic_report_col10
--    get_dynamic_report_col12
--    get_xaxis_label_name
--    get_yaxis_label_name
--
--
-- Procedures
--    load_jtfb_demo_bin
--    load_jtfb_demo_bin1
--    load_jtfb_demo_report
--
-- Notes
--
-- History
--    15-MAY-2001, Pandian Athimoolam, Created the functions to return
--       the graph xaxis and yaxis label name
--    10-MAY-2001, Elanchelvan Elango, Replaced inserts with API calls
--    09-MAY-2001, Pandian Athimoolam, Created
--
-- End of Comments
--
--
/*****************************************************************************/
-- Start of Package Globals
--
   g_pkg_name  constant varchar2(30) := 'jtfb_picasso_demo';
--
-- End of Global Package Globals
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : load_jtfb_demo_bin
-- Type       : Public
-- Function:
--    Loads the first Data-Out BIN
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Notes:
--    None.
--
-- End Of Comments
procedure load_jtfb_demo_bin(
   p_context in varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : load_jtfb_demo_bin1
-- Type       : Public
-- Function:
--    Loads the Data-Out BIN1
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Notes:
--    None.
--
-- End Of Comments
procedure load_jtfb_demo_bin1(
   p_context in varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : load_jtfb_demo_report
-- Type       : Public
-- Function:
--    Loads the first Report
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Notes:
--    None.
--
-- End Of Comments
procedure load_jtfb_demo_report(
   p_context in varchar2 default null
);
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_footer
-- Type       : Public
-- Function:
--    Gets a dynamic Footer
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic footer text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_footer(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_name
-- Type       : Public
-- Function:
--    Gets a dynamic Name
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic name
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_name(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_report_col2
-- Type       : Public
-- Function:
--    Gets a dynamic label for col2, the first column of the Data-Out BINS
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic column text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_report_col2(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_report_col4
-- Type       : Public
-- Function:
--    Gets a dynamic label for col4, the second column of the Data-Out BINS
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic column text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_report_col4(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_report_col6
-- Type       : Public
-- Function:
--    Gets a dynamic label for col6, the third column of the Data-Out BINS
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic column text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_report_col6(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_report_col8
-- Type       : Public
-- Function:
--    Gets a dynamic label for col8, the fourth column of the Data-Out BINS
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic column text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_report_col8(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_report_col10
-- Type       : Public
-- Function:
--    Gets a dynamic label for col10, the fifth column of the Data-Out BINS
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic column text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_report_col10(
   p_context in varchar2 default null
) return varchar2;
--
--
/*****************************************************************************/
-- Start Of Comments
--
-- Name       : get_dynamic_report_col12
-- Type       : Public
-- Function:
--    Gets a dynamic label for col12, the sixth column of the Data-Out BINS
--
-- Pre-Reqs:
--    None.
--
-- Parameters:
--    p_context
--       in varchar2 default null
--
-- Returns:
--    varchar2 (approximately 80 characters ?)
--       The dynamic column text
-- Notes:
--    None.
--
-- End Of Comments
function get_dynamic_report_col12(
   p_context in varchar2 default null
) return varchar2;
--
--
function get_xaxis_label_name(
   p_context in varchar2 default null
) return varchar2;
--
--
function get_yaxis_label_name(
   p_context in varchar2 default null
) return varchar2;
--
--
end jtfb_picasso_demo;

 

/
