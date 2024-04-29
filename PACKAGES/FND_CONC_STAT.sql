--------------------------------------------------------
--  DDL for Package FND_CONC_STAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_STAT" AUTHID CURRENT_USER AS
/* $Header: AFAMRSCS.pls 115.5 2002/02/08 19:28:23 nbhambha ship $ */

   TYPE numtab IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;

   SYS_SEC_ID             CONSTANT NUMBER := -1;
   SYS_MIC_ID             CONSTANT NUMBER := -2;
   USR_SEC_ID             CONSTANT NUMBER := -3;
   USR_MIC_ID             CONSTANT NUMBER := -4;
   REAL_SEC_ID            CONSTANT NUMBER := -5;

   DAYSECS                CONSTANT NUMBER := 86400;

   PROCEDURE put_frontend_cpu(sys_sec IN NUMBER,
			      sys_mic IN NUMBER,
			      usr_sec IN NUMBER,
			      usr_mic IN NUMBER);
   PROCEDURE collect;
   PROCEDURE store_initial;
   PROCEDURE store_final;

END fnd_conc_stat;

 

/
