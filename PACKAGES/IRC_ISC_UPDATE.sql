--------------------------------------------------------
--  DDL for Package IRC_ISC_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ISC_UPDATE" AUTHID CURRENT_USER AS
/* $Header: iriscupg.pkh 120.0 2005/07/26 15:11 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |------------------------< update_keywords >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description : This package clears invalid keywords entenred in Work
--               Preferences from irc_search_criteria table
--
--
procedure update_keywords(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
end irc_isc_update;

 

/
