--------------------------------------------------------
--  DDL for Package MSC_ANALYSIS_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ANALYSIS_BUDGET" AUTHID CURRENT_USER AS
/*  $Header: MSCAIBS.pls 115.4 2004/03/10 23:29:59 mhasan noship $ */

   FUNCTION get_customer_target_sl(customer_id NUMBER) RETURN NUMBER;

   PROCEDURE schedule_retrieve(query_id OUT NOCOPY NUMBER, plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2,
                              abc_id IN VARCHAR2, calendar_type IN NUMBER);
END; -- Package spec

 

/
