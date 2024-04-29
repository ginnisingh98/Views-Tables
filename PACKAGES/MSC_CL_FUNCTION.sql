--------------------------------------------------------
--  DDL for Package MSC_CL_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_FUNCTION" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCLFNS.pls 120.1 2005/10/20 01:41:38 abhikuma noship $ */

v_dblink                      VARCHAR2(128);
 TYPE TblLstTyp IS TABLE OF VARCHAR2(30);
 G_ERROR                      CONSTANT NUMBER := 2;
FUNCTION GET_ALL_ORGS ( p_org_group IN VARCHAR2,
   			p_instance_id IN NUMBER)
RETURN VARCHAR2;

 PROCEDURE  UPDATE_DATE_COLUMNS(ERRBUF               OUT NOCOPY VARCHAR2,
                                  RETCODE              OUT NOCOPY NUMBER,
                                  pINSTANCE_ID         IN  NUMBER,
                                  pNUM_OF_DAYS         IN  NUMBER);

END MSC_CL_FUNCTION;
 

/
