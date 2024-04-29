--------------------------------------------------------
--  DDL for Package ICX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_UTIL" AUTHID CURRENT_USER as
/* $Header: ICXUTILS.pls 120.0 2005/10/07 12:21:16 gjimenez noship $ */

-- Declaration of a table of varchar2(240) that is returned by the
-- transfer_Row_To_Column utility
type char240_table is table of varchar2(240) index by binary_integer;

type char4000_table is table of varchar2(4000) index by binary_integer;

type g_prompts_table is table of varchar2(80)
        index by binary_integer;

type g_lookup_code_table is table of varchar2(30)
        index by binary_integer;

type g_lookup_meaning_table is table of varchar2(80)
        index by binary_integer;

type attributes_table is table of varchar2(30)
	index by binary_integer;

procedure LOVScript;

function LOVButton (c_attribute_app_id in number,
                    c_attribute_code in varchar2,
                    c_region_app_id in number,
                    c_region_code in varchar2,
                    c_form_name in varchar2,
                    c_frame_name in varchar2 default null,
                    c_where_clause in varchar2 default null,
	       	    c_image_align in varchar2 default 'CENTER')
                    return varchar2;


procedure LOV (c_attribute_app_id in number,
               c_attribute_code in varchar2,
               c_region_app_id in number,
               c_region_code in varchar2,
               c_form_name in varchar2,
               c_frame_name in varchar2 default null,
               c_where_clause in varchar2 default null,
	       c_js_where_clause in varchar2 default null);


procedure LOVHeader (c_attribute_code in varchar2,
		     p_LOV_foreign_key_name in varchar2,
                     p_LOV_region_id in number,
                     p_LOV_region in varchar2,
                     c_form_name in varchar2,
                     c_frame_name in varchar2 default null,
	 	     c_lines in number default 1,
		     x in number default 1,
		     a_1 in varchar2 default null,
 		     c_1 in varchar2 default 'DSTART',
		     i_1 in varchar2 default null,
		     a_2 in varchar2 default null,
		     c_2 in varchar2 default null,
	    	     i_2 in varchar2 default null,
		     a_3 in varchar2 default null,
		     c_3 in varchar2 default null,
	    	     i_3 in varchar2 default null,
		     a_4 in varchar2 default null,
		     c_4 in varchar2 default null,
	    	     i_4 in varchar2 default null,
		     a_5 in varchar2 default null,
		     c_5 in varchar2 default null,
	    	     i_5 in varchar2 default null);

procedure LOVValues (p_LOV_foreign_key_name in varchar2,
		     p_LOV_region_id in number,
                     p_LOV_region in varchar2,
		     p_attribute_app_id in number,
                     p_attribute_code in varchar2,
                     p_region_app_id in number,
                     p_region_code in varchar2,
                     c_form_name in varchar2,
                     c_frame_name in varchar2 default null,
                     c_where_clause in varchar2 default null,
                     x in number default 0,
 	             start_row in number default 1,
		     p_end_row in number default null,
		     a_1 in varchar2 default null,
		     c_1 in varchar2 default 'DSTART',
	    	     i_1 in varchar2 default null,
		     a_2 in varchar2 default null,
		     c_2 in varchar2 default null,
	    	     i_2 in varchar2 default null,
		     a_3 in varchar2 default null,
		     c_3 in varchar2 default null,
	    	     i_3 in varchar2 default null,
		     a_4 in varchar2 default null,
		     c_4 in varchar2 default null,
	    	     i_4 in varchar2 default null,
		     a_5 in varchar2 default null,
		     c_5 in varchar2 default null,
	    	     i_5 in varchar2 default null,
                     case_sensitive in varchar2 default null);

procedure copyright;

procedure getPrompts( p_region_application_id in number,
		      p_region_code in varchar2,
		      p_title out NOCOPY varchar2,
		      p_prompts out NOCOPY g_prompts_table);

function getPrompt( p_region_application_id in number,
                    p_region_code in varchar2,
		    p_attribute_application_id in number,
	     	    p_attribute_code in varchar2)
		    return varchar2;

procedure getLookups( p_lookup_type in varchar2,
		      p_lookup_codes out NOCOPY g_lookup_code_table,
		      p_lookup_meanings out NOCOPY g_lookup_meaning_table);

procedure getLookup( p_lookup_type in varchar2,
                     p_lookup_code in varchar2,
                     p_meaning out NOCOPY varchar2);

procedure error_page_setup;

procedure add_error(V_ERROR_IN varchar2);

function error_count
         return number;

procedure error_page_print;

procedure no_html_error_page_print;

function get_color(v_name in varchar2)
	return varchar2;


procedure parse_string (
	in_str		in	varchar2,
	delimiter	in	varchar2,
	str_part1	out NOCOPY varchar2,
	str_part2	out NOCOPY varchar2);

function  item_flex_seg (
	ri		in 	rowid)
return varchar2;

pragma restrict_references (item_flex_seg,WNDS,RNPS,WNPS);

function  category_flex_seg (
	cat_id		in 	number)
return varchar2;

pragma restrict_references (category_flex_seg,WNDS,RNPS,WNPS);

-- The transfer_Row_To_Column utility takes one record returned by an
-- Object Navigator query and changes the record into a pl/sql table
procedure transfer_Row_To_Column(result_record  in  ak_query_pkg.result_rec,
                                 result_table   out NOCOPY icx_util.char240_table);

procedure transfer_Row_To_Column(result_record  in  ak_query_pkg.result_rec,
                                 result_table   out NOCOPY icx_util.char4000_table);

PROCEDURE DynamicButton(P_ButtonText      varchar2,
                        P_ImageFileName   varchar2,
                        P_OnMouseOverText varchar2,
                        P_HyperTextCall   varchar2,
                        P_LanguageCode    varchar2,
                        P_JavaScriptFlag  boolean,
			P_DisabledFlag	  boolean default FALSE);

PROCEDURE paintDynamicButton(P_ButtonText      varchar2,
                        P_ImageFileName   varchar2,
                        P_OnMouseOverText varchar2,
                        P_HyperTextCall   varchar2,
                        P_LanguageCode    varchar2,
                        P_DisabledFlag    boolean default FALSE);

PROCEDURE DynamicButtonIn(P_ButtonText      varchar2,
                        P_ImageFileName   varchar2,
                        P_OnMouseOverText varchar2,
                        P_HyperTextCall   varchar2,
                        P_LanguageCode    varchar2,
                        P_JavaScriptFlag  boolean,
                        P_DisabledFlag    boolean default FALSE);

-- The replace_quotes function takes a string as an in parameter, and
-- returns a string with all single and double quotes preceeded with a \.
-- This function is designed to escape out all quotes in a phrase that is
-- used with javascript.  The \ character is the escape character for
-- javascript.  If a string with quotes already preceeded by the \ escape
-- character is passed to the replace_quotes function, the return string
-- will only have one \ infront of each quote.
function replace_quotes(p_string in varchar2) return varchar2;

function replace_jsdw_quotes(p_string in varchar2) return varchar2;

function replace_onMouseOver_quotes(p_string in varchar2) return varchar2;

-- The replace_alt_quotes function takes a string as an in parameter, and
-- returns a string with all single and double quotes preceeded with a \.
-- This function is designed to escape out all quotes in a phrase that is
-- used for alt text for html images.  The \ character is the escape character
-- for javascript.  If a string with quotes already preceeded by the \ escape
-- character is passed to the replace_quotes function, the return string
-- will only have one \ infront of each quote.
function replace_alt_quotes(p_string in varchar2) return varchar2;


end icx_util;

 

/
