--------------------------------------------------------
--  DDL for Package MRP_EXCEPTIONS_SC_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_EXCEPTIONS_SC_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPEPKS.pls 115.0 99/07/16 12:32:17 porting ship $ */

  PROCEDURE MRP_COMPUTE_EXCEPTIONS
   (P_QUERY_ID                    IN      NUMBER,
    P_PLANNER			  IN      VARCHAR2,
    P_ORG_ID			  IN      NUMBER,
    P_PLAN_ORG_ID		  IN      NUMBER,
    P_PLAN_NAME                   IN      VARCHAR2,
    P_PLAN_START_DATE             IN      DATE);

END MRP_EXCEPTIONS_SC_PK;

 

/
