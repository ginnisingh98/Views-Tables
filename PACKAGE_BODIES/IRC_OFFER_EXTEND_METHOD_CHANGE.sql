--------------------------------------------------------
--  DDL for Package Body IRC_OFFER_EXTEND_METHOD_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFER_EXTEND_METHOD_CHANGE" AS
/* $Header: irofrupg.pkb 120.1 2006/08/24 11:23:57 gaukumar noship $*/

-- ----------------------------------------------------------------------------
-- |--------------------------< update_offer_extended_method >-----------------|
-- ----------------------------------------------------------------------------
procedure update_offer_extended_method(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
begin
  update irc_offers
      set OFFER_EXTENDED_METHOD = fnd_profile.VALUE('IRC_OFFER_SEND_METHOD')
      where OFFER_EXTENDED_METHOD is null;

  p_rows_processed := sql%rowcount;
end update_offer_extended_method;
end irc_offer_extend_method_change;

/
