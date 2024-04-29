--------------------------------------------------------
--  DDL for Package FND_HELP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_HELP" AUTHID CURRENT_USER as
/* $Header: AFMLHLPS.pls 120.2.12010000.2 2010/02/10 07:15:25 nchiring ship $ */


TYPE results_tab is TABLE of varchar2(1000)
	index by binary_integer;

blank_search exception;

syntax_err   exception;
pragma exception_init(syntax_err, -29902);

--
-- GET_URL
--   Gets the URL for a help document based on the target desired.
-- IN:
-- APPSNAME is the application short name for the application
--          of the help document
-- TARGET is the name of the help target or help file.  For context
--        sensitive help an example would be "FORM.WINDOW".
-- HELPSYSTEM determines whether to generate a url to bring up the
--        entire help system or just the specified document
-- TARGETTYPE specifies whether the target is a help target or filename.
--        valid values are TARGET or FILE)
-- HELPCONTEXT when false, then help root is taken for the global help content, typically
--             represented by FND:LIBRARY.
--             When true, then system displays context sensitive help content.

--
function Get_Url(
  APPSNAME   in varchar2,
  TARGET     in varchar2,
  HELPSYSTEM in boolean  default TRUE,
  TARGETTYPE in varchar2 default 'TARGET',
  CONTEXTHELP in boolean  default TRUE )
return varchar2;

--
-- Get
--   Get GFM identifier for help target
-- IN
--   path - Relative path of target, in the format:
--          /<LANG>/<APP>/<FILE>
--	    /<LANG>/<APP>/@<TARGET>
-- RETURNS
--   GFM-compliant string identifying file to retrieve. Syntax:
--     file_id=<fileid>
--
function Get(
  path in varchar2,
  file_id out nocopy  varchar2) return boolean;


-- Help_Search
--   Implement search
-- IN
--   find_string - string to search for
-- IN OUT
--   results - array of links.
--
-- This procedure implements the Help Document search and can be called
-- by other folks who wish to include help documents in their own search
-- results.  Takes the search string, parses and reshapes it behave more
-- like standard browser searches, finds the matching Help Documents,
-- and returns them as an array of links to be displayed by the caller.
----------------------------------------------------------------------------
procedure Help_Search(
  find_string  in     varchar2 default null,
  scores       in out nocopy results_tab,
  apps         in out nocopy results_tab,
  titles       in out nocopy results_tab,
  file_names   in out nocopy results_tab,
  langpath     in     varchar2 default userenv('LANG'),
  appname      in     varchar2 default null,
  lang         in     varchar2 default null,
  row_limit    in     number default null);

procedure LOAD_DOC (
  x_file_id		in varchar2,
  x_language		in varchar2,
  x_application		in varchar2,
  x_file_name		in varchar2,
  x_custom_level	in varchar2,
  x_title		in varchar2,
  x_version		in varchar2 );

procedure LOAD_TARGET (
  x_file_id 		in varchar2,
  x_target_name		in varchar2 );

procedure CULL_ROW (
  x_file_id 		in varchar2,
  x_language       	in varchar2,
  x_application 	in varchar2,
  x_file_name 		in varchar2,
  x_custom_level        in varchar2 );

-----------------------------------------------------------------------------
-- delete_doc
--   Delete a document from the iHelp system
-- IN:
--   x_application - Application shortname of file owner
--   x_file_name - Name of file to delete
--   x_language - Language to delete (null for all)
--   x_custom_level - Custom level to delete (null for all)
-----------------------------------------------------------------------------
procedure delete_doc (
  x_application   in varchar2,
  x_file_name 	  in varchar2,
  x_language      in varchar2 default null,
  x_custom_level  in varchar2 default null);

end fnd_help;

/
