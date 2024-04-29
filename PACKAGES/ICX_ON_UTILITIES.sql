--------------------------------------------------------
--  DDL for Package ICX_ON_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ON_UTILITIES" AUTHID CURRENT_USER as
/* $Header: ICXONUS.pls 120.0 2005/10/07 12:16:42 gjimenez noship $ */

type v4000_table is table of varchar2(4000)
        index by binary_integer;

type v2000_table is table of varchar2(2000)
        index by binary_integer;

type v240_table is table of varchar2(240)
        index by binary_integer;

type v80_table is table of varchar2(80)
        index by binary_integer;

type v50_table is table of varchar2(50)
        index by binary_integer;

type v30_table is table of varchar2(30)
        index by binary_integer;

type v1_table is table of varchar2(30)
        index by binary_integer;

type number_table is table of number
        index by binary_integer;

type rowid_table is table of rowid
        index by binary_integer;

procedure findPage(p_flow_appl_id in number default null,
                   p_flow_code in varchar2 default null,
                   p_page_appl_id in number default null,
                   p_page_code in varchar2 default null,
		   p_region_appl_id in number default null,
		   p_region_code in varchar2 default null,
                   p_goto_url in varchar2 default null,
                   p_lines_now in number default null,
                   p_lines_url in varchar2 default null,
                   p_lines_next in number default null,
                   p_hidden_name in varchar2 default null,
                   p_hidden_value in varchar2 default null,
                   p_help_url in varchar2 default null,
		   p_new_url in varchar2 default null);

procedure findForm(p_region_appl_id in number,
                   p_region_code in varchar2,
                   p_goto_url in varchar2 default null,
		   p_goto_target in varchar2 default null,
                   p_lines_now in number default 1,
                   p_lines_url in varchar2 default null,
		   p_lines_target in varchar2 default null,
                   p_lines_next in number default 5,
                   p_hidden_name in varchar2 default null,
                   p_hidden_value in varchar2 default null,
                   p_help_url in varchar2 default null,
		   p_new_url in varchar2 default null,
		   p_LOV_mode in varchar2 default 'N',
		   p_default_title in varchar2 default 'Y',
		   p_flow_appl_id in number default null,
                   p_flow_code in varchar2 default null,
                   p_page_appl_id in number default null,
                   p_page_code in varchar2 default null,
		   p_clear_button in varchar2 default 'Y',
		   p_advanced_button in varchar2 default 'Y');

procedure getRegions(p_where in varchar2 default null);

procedure displayPage;

function formatText(c_text in varchar2,
		    c_bold in varchar2,
		    c_italic in varchar2) return varchar2;

function formatData(c_text in varchar2,
		    c_halign in varchar2,
		    c_valign in varchar2) return varchar2;

function whereSegment(a_1     in      varchar2        default null,
                      c_1     in      varchar2        default null,
                      i_1     in      varchar2        default null,
                      a_2     in      varchar2        default null,
                      c_2     in      varchar2        default null,
                      i_2     in      varchar2        default null,
                      a_3     in      varchar2        default null,
                      c_3     in      varchar2        default null,
                      i_3     in      varchar2        default null,
                      a_4     in      varchar2        default null,
                      c_4     in      varchar2        default null,
                      i_4     in      varchar2        default null,
                      a_5     in      varchar2        default null,
                      c_5     in      varchar2        default null,
                      i_5     in      varchar2        default null,
		      m	      in      varchar2        default null,
		      o       in      varchar2        default 'AND')
                      return varchar2;

function whereSegment(c_attributes in v80_table,
                      c_conditions in v80_table,
                      c_inputs     in v80_table,
		      p_match	   in varchar2,
		      p_and_or	   in varchar2)
                      return varchar2;

procedure unpack_whereSegment(p_whereSegment in varchar2,
                              p_where_clause out NOCOPY varchar2,
                              p_query_binds out NOCOPY ak_query_pkg.bind_tab);

--added by mputman for 1576202
procedure unpack_whereSegment(p_whereSegment in varchar2,
                              p_query_binds IN out NOCOPY ak_query_pkg.bind_tab,
                              p_query_binds_index IN NUMBER);

procedure unpack_parameters(Y in varchar2,
                         c_parameters out NOCOPY v80_table);

procedure unpack_parameters(Y in varchar2,
                         c_parameters out NOCOPY v240_table);

procedure unpack_parameters(Y in varchar2,
                         c_parameters out NOCOPY v2000_table);

procedure checkDate(p_date in varchar2);

function buildOracleONstring(p_rowid	in varchar2,
			p_primary_key	in varchar2,
			p1		in varchar2	default null,
			p2		in varchar2	default null,
			p3		in varchar2	default null,
			p4		in varchar2	default null,
			p5		in varchar2	default null,
			p6		in varchar2	default null,
			p7		in varchar2	default null,
			p8		in varchar2	default null,
			p9		in varchar2	default null,
			p10		in varchar2	default null)
			return varchar2;

function buildOracleONstring2(p_flow_application_id in varchar2,
                        p_flow_code		    in varchar2,
                        p_page_application_id       in varchar2,
                        p_page_code		    in varchar2,
                        p_where_segment		    in varchar2 default null)
                        return varchar2;

procedure printRegions(p_rowid    in varchar2,
                        p_primary_key   in varchar2,
                        p1              in varchar2     default null,
                        p2              in varchar2     default null,
                        p3              in varchar2     default null,
                        p4              in varchar2     default null,
                        p5              in varchar2     default null,
                        p6              in varchar2     default null,
                        p7              in varchar2     default null,
                        p8              in varchar2     default null,
                        p9              in varchar2     default null,
                        p10             in varchar2     default null);

procedure printRegions2(p_flow_application_id in varchar2,
                        p_flow_code                 in varchar2,
                        p_page_application_id       in varchar2,
                        p_page_code                 in varchar2,
                        p_where_segment             in varchar2 default null);


g_on_parameters v240_table;
/* g_on_parameters definition
 1	type		-- Defines query type
			   'DQ'	- Query based on Find Form
			   'W'	- Direct query
			   'D' or else	- Unique Key query
 2	flow_appl_id
 3	flow_code
 4	page_appl_id
 5	page_code
 6	start_row	-- Starting row of query set
 7	end_row		-- Ending row of query set
 8	start_region	-- Region that start applies to in multi region page
 9	encrypted_where
10	rowid 		-- rowid of AK_FLOW_REGION_RELATIONS
11	unique_key_name -- Unique key to be used in ak_query_pkg
12-21	keys(1-10)	-- Key values for unique_key_name
22      display page headers and footers Y/N
*/

c_ampersand constant varchar2(1) := '&';
c_percent   constant varchar2(1) := '%';

end icx_on_utilities;

 

/
