--------------------------------------------------------
--  DDL for Package PV_BATCH_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_BATCH_ASSIGN_PUB" AUTHID CURRENT_USER as
/* $Header: pvbtasns.pls 120.1 2005/09/01 10:51:19 appldev ship $*/


    G_PKG_NAME      CONSTANT VARCHAR2(30):='PV_BATCH_ASSIGN_PUB';
    g_log_to_file   VARCHAR2(1) := 'Y';

    PROCEDURE PROCESS_UNASSIGNED(
          ERRBUF      OUT NOCOPY   VARCHAR2,
          RETCODE     OUT NOCOPY   VARCHAR2,
          P_COUNTRY   IN   VARCHAR2,
          P_USERNAME  IN   VARCHAR2,
	  P_FROMDATE  IN   VARCHAR2);


END;

 

/
