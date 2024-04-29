--------------------------------------------------------
--  DDL for Package JTM_CONC_PROG_RUN_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_CONC_PROG_RUN_STATUS_PUB" AUTHID CURRENT_USER  AS
/* $Header: jtmpurgs.pls 120.1 2005/08/24 02:18:12 saradhak noship $ */

procedure PURGE(
    P_Status      OUT NOCOPY  VARCHAR2,
    P_Message      OUT NOCOPY  VARCHAR2);

END JTM_CONC_PROG_RUN_STATUS_PUB;

 

/
