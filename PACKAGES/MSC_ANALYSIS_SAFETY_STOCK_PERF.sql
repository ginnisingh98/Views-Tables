--------------------------------------------------------
--  DDL for Package MSC_ANALYSIS_SAFETY_STOCK_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ANALYSIS_SAFETY_STOCK_PERF" AUTHID CURRENT_USER AS
/*  $Header: MSCIORS.pls 120.1 2007/04/30 18:35:11 minduvad ship $ */

--
--
-- Purpose: populate a temp table with values displayed in
-- Inventory Optimization's Safety Stock and Service Level report
--

   PROCEDURE schedule_details_sl(p_query_id OUT NOCOPY NUMBER, p_period_type NUMBER, plan_id IN VARCHAR2,
      org_id IN VARCHAR2, cat_id IN VARCHAR2, p_item_id IN NUMBER, customer_id IN NUMBER,
      customer_class_code IN VARCHAR2, p_abc_id IN VARCHAR2);

   PROCEDURE schedule_details_ss(query_id OUT NOCOPY NUMBER, plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2,
             item_id IN NUMBER);

   PROCEDURE schedule_details_iv(p_query_id OUT NOCOPY NUMBER, p_period_type IN NUMBER,
      p_plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2, p_abc_id IN VARCHAR2);

   PROCEDURE schedule_aggregate(p_plan_id IN NUMBER);
   FUNCTION get_cat_set_id(p_plan_id number) RETURN NUMBER;

END MSC_ANALYSIS_SAFETY_STOCK_PERF;

/
