--------------------------------------------------------
--  DDL for Package Body IRC_ISC_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ISC_UPDATE" AS
/* $Header: iriscupg.pkb 120.0 2005/07/26 15:11 mbocutt noship $*/

-- ----------------------------------------------------------------------------
-- |---------------------------< update_keywords >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_keywords(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
-- This cursor loops over the keywords
-- entered by users in Work Preferences
--
cursor csr_keyword is
  select keywords,search_criteria_id
  from irc_search_criteria
  where search_criteria_id between p_start_pkid and p_end_pkid
        and object_type = 'WPREF'
        and keywords is not null;
  l_rows_processed number := 0;
--
begin
  for l_data in csr_keyword
  loop
      if(irc_query_parser_pkg.isInvalidKeyword(l_data.keywords))
      then
        update irc_search_criteria
        set keywords = ''
        where search_criteria_id = l_data.search_criteria_id;
      end if;
      l_rows_processed := l_rows_processed + 1;
  end loop;
  p_rows_processed := l_rows_processed;
end update_keywords;
--
end irc_isc_update;

/
