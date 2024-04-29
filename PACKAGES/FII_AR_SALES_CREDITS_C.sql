--------------------------------------------------------
--  DDL for Package FII_AR_SALES_CREDITS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_SALES_CREDITS_C" AUTHID CURRENT_USER AS
/* $Header: FIIARSCS.pls 115.1 2003/11/22 00:13:29 juding noship $ */


PROCEDURE MAIN(Errbuf          IN OUT  NOCOPY VARCHAR2,
               Retcode         IN OUT  NOCOPY VARCHAR2,
               p_program_type  IN      VARCHAR2 DEFAULT 'I');

FUNCTION delete_salescredit_sub (
  p_subscription_guid IN RAW,
  p_event IN OUT NOCOPY WF_EVENT_T)
  RETURN VARCHAR2;

FUNCTION update_salescredit_sub (
  p_subscription_guid IN RAW,
  p_event IN OUT NOCOPY WF_EVENT_T)
  RETURN VARCHAR2;

END FII_AR_SALES_CREDITS_C;

 

/
