--------------------------------------------------------
--  DDL for Package FND_IMUTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IMUTL" AUTHID CURRENT_USER as
/* $Header: AFIMUTLS.pls 120.2 2005/09/24 12:00:16 skghosh ship $ */

-----------------------------------------------------------------------------
/* Parse_Search
**   Format search string to support more browser-like functionality
*/
procedure Parse_Search(
   search_string   in     varchar2,
   select_clause   in out nocopy varchar2,
   and_clause      in out nocopy varchar2,
   index_col       in     varchar2);
-----------------------------------------------------------------------------
/* process_imt_reserve_char
**   Appends a mask for all IMT reserve characters
*/
FUNCTION process_imt_reserve_char(p_search_token IN VARCHAR2) RETURN VARCHAR2;
-----------------------------------------------------------------------------
/* process_imt_reserve_word
**   Encloses all IMT reserve words in a set of curly braces.
*/
FUNCTION process_imt_reserve_word(p_search_token IN VARCHAR2) RETURN VARCHAR2;
-----------------------------------------------------------------------------
/* help_cleanup
**   Remove all expired or orphaned rows
**   Commits in an autonomous transaction
*/
PROCEDURE help_cleanup;
-----------------------------------------------------------------------------
/* maintain_index
**   Maintain an iM index
**
**   Arguments -
**     p_index_name - the name of the index to maintain
**     p_callback   - (optional) name of the package.procedure to
**                    execute before maintain the index.  Procedure may not
**                    have any mandatory arguments.
**                    (i.e.:  fnd_imutl.help_cleanup)
**     p_app_short_name - the short name of the application that owns the
**                    index (i.e.  FND, SQLGL, INV)
**     p_mode       - Valid Modes are FAST - fast optimization
**                                    FULL - full optimization
**                                    <anything else> synchronizes index
**                    Synchronize is what you usually want.  It updates
**                    the index to include your recent DML changes.
**                    FAST or FULL optimization should probably run during
**                    off-peak hours to defragment your index and reclaim
**                    memory from deleted records and close gaps.
*/
PROCEDURE maintain_index(p_index_name     in varchar2,
                         p_callback       in varchar2 default null,
                         p_app_short_name in varchar2 default 'FND',
                         p_mode           in varchar2 default 'sync');
-----------------------------------------------------------------------------

end FND_IMUTL;

 

/

  GRANT EXECUTE ON "APPS"."FND_IMUTL" TO "ICX";
  GRANT DEBUG ON "APPS"."FND_IMUTL" TO "ICX";
