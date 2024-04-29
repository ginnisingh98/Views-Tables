--------------------------------------------------------
--  DDL for Package WFE_HTML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFE_HTML_UTIL" AUTHID CURRENT_USER as
/* $Header: wfehtms.pls 120.2 2005/09/01 09:54:18 aiqbal ship $ */

--
-- Types
--
type headerRecType is record (
  def_type   varchar2(8),              /* FUNCTION, TITLE, ICON */
  level      number,                   /* level number */
  span       number,                   /* colspan value for this title */
  trattr     varchar2(240),            /* attribute for TR tag */
  attr       varchar2(240),            /* attribute for TD tag */
  value      varchar2(4000)            /* function value or title */
);
-- All the FUNCTION records must come before TITLE records.
-- Function orders are:
--  1. Delete
--  2. ListDetail
--  3. Edit

type headerTabType is table of headerRecType index by binary_integer;

type dataRecType is record (
  guid       raw(16),
  level      number,
  showtitle  boolean,         -- if showtitle is true, ignore the rest
  selectable boolean,
  deletable  boolean,
  hasdetail  boolean,
  trattr     varchar2(240),   -- attribute for TR tag
  tdattr     varchar2(240),
  col01      varchar2(4000),
  col02      varchar2(4000),
  col03      varchar2(4000),
  col04      varchar2(4000),
  col05      varchar2(4000),
  col06      varchar2(4000),
  col07      varchar2(4000),
  col08      varchar2(4000),
  col09      varchar2(4000),
  col10      varchar2(4000),
  col11      varchar2(4000),
  col12      varchar2(4000),
  col13      varchar2(4000),
  col14      varchar2(4000),
  col15      varchar2(4000)
);

type dataTabType is table of dataRecType index by binary_integer;

type tmpTabType is table of varchar2(4000) index by binary_integer;

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error;

procedure simple_table (
  headerTab  headerTabType,
  dataTab    dataTabType,
  tabattr    varchar2    default null,
  show_1st_title boolean default TRUE,
  show_level number      default null
);

--
-- generate_check_all
--   generate the javascript to check all the check boxes
-- IN
--   p_jscript_tag - if 'Y' generate the SCRIPT tag
--
procedure generate_check_all (
  p_jscript_tag in varchar2 default 'Y'
);

--
-- generate_confirm
--   generate the javascript to do the confirm box
-- IN
--   p_jscript_tag - if 'Y' generate the SCRIPT tag
--
procedure generate_confirm (
  p_jscript_tag in varchar2 default 'Y'
);

-- gotoURL
--   javascript script implementation of go to an url
-- IN
--   p_url - the url provided
--
procedure gotoURL (
  p_url  in varchar2,
  p_noblankpage in varchar2 default null
);

procedure test;

end WFE_HTML_UTIL;

 

/
