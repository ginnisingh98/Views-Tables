--------------------------------------------------------
--  DDL for Package ISC_EDW_BACKLOG_SUM1_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_BACKLOG_SUM1_F_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF3S.pls 120.0 2005/05/25 17:35:13 appldev noship $ */

---------------------------------------------------
-- PROCEDURE Populate
---------------------------------------------------
PROCEDURE Populate( errbuf	IN OUT NOCOPY 	VARCHAR2,
		    retcode	IN OUT NOCOPY 	VARCHAR2);

END ISC_EDW_BACKLOG_SUM1_F_C;

 

/
