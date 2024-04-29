--------------------------------------------------------
--  DDL for Package IRC_OFFER_EXTEND_METHOD_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_EXTEND_METHOD_CHANGE" AUTHID CURRENT_USER AS
/* $Header: irofrupg.pkh 120.0 2006/08/24 10:53:08 gaukumar noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< update_offer_extended_method >-----------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure updates all the offer records so that the
--   offer_extended_method to the current value in the profile option.
--
--
procedure update_offer_extended_method(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number);
--
end irc_offer_extend_method_change;

 

/
