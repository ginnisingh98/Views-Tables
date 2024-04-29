--------------------------------------------------------
--  DDL for Package IRC_DEFAULT_POSTING_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DEFAULT_POSTING_BK3" AUTHID CURRENT_USER as
/* $Header: iridpapi.pkh 120.2 2008/02/21 14:12:57 viviswan noship $ */

procedure delete_default_posting_b
(P_DEFAULT_POSTING_ID         IN  NUMBER
);

procedure delete_default_posting_a
(P_DEFAULT_POSTING_ID         IN  NUMBER
);

end irc_default_posting_bk3;

/
