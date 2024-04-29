--------------------------------------------------------
--  DDL for Package MSC_ANALYSIS_SAFETY_STOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ANALYSIS_SAFETY_STOCK" AUTHID CURRENT_USER AS
/*  $Header: MSCASSS.pls 120.0 2005/05/25 19:34:55 appldev noship $ */
--
--
-- Purpose: populate a temp table with values displayed in
-- Inventory Optimization's Safety Stock and Service Level report
--

   PROCEDURE schedule_retrieve(query_id OUT NOCOPY NUMBER, plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2,
                              item_id IN NUMBER, customer_id IN NUMBER, customer_class_code IN VARCHAR2);
   FUNCTION get_cat_set_id(arg_plan_id number) RETURN NUMBER;
   FUNCTION get_customer_target_sl(customer_id NUMBER) RETURN NUMBER;

END; -- Package spec

 

/
