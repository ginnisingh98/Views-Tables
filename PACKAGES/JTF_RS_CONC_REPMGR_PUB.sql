--------------------------------------------------------
--  DDL for Package JTF_RS_CONC_REPMGR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_CONC_REPMGR_PUB" AUTHID CURRENT_USER as
  /* $Header: jtfrsbps.pls 120.0 2005/05/11 08:19:22 appldev ship $ */
-- Type		: Public
-- Purpose	: Inserts IN  the JTF_RS_REP_MANAGERS
-- Modification History
-- DATE		 NAME	       PURPOSE
-- 4-DEC-2000    SR CHOUDHURY  CREATED
-- 5-FEB-2001    N SINGHAI     Added procedure sysnc_role_relation
--
procedure populate_repmgr
  (ERRBUF   OUT NOCOPY VARCHAR2,
   RETCODE  OUT NOCOPY VARCHAR2);

procedure sync_rep_mgr
  (ERRBUF   OUT NOCOPY VARCHAR2,
   RETCODE  OUT NOCOPY VARCHAR2);

end jtf_rs_conc_repmgr_pub;

 

/
