--------------------------------------------------------
--  DDL for Package FII_AR_TRX_DIST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TRX_DIST_F_C" AUTHID CURRENT_USER AS
/* $Header: FIIAR06S.pls 120.1 2005/06/13 09:56:50 sgautam noship $ */

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------

 PROCEDURE PUSH(Errbuf      	IN OUT  NOCOPY VARCHAR2,
                Retcode     	IN OUT  NOCOPY VARCHAR2,
                p_from_date  	IN 	VARCHAR2,
                p_to_date    	IN 	VARCHAR2,
 		p_mode		IN 	VARCHAR2,
                p_seq_id        IN      VARCHAR2);


END FII_AR_TRX_DIST_F_C;

 

/
