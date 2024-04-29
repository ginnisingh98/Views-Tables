--------------------------------------------------------
--  DDL for Package QA_PLANS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PLANS_API" AUTHID CURRENT_USER AS
/* $Header: qltplanb.pls 115.4 2003/10/03 19:06:16 anagarwa ship $ */


FUNCTION exists_qa_plans(plan_id IN NUMBER)
    RETURN BOOLEAN;

PROCEDURE fetch_qa_plans (plan_id IN NUMBER);

FUNCTION org_id(plan_id IN NUMBER)
    RETURN NUMBER;

FUNCTION plan_id(plan_name IN VARCHAR2)
    RETURN NUMBER;

FUNCTION valid_plan_id (plan_id IN NUMBER)
    RETURN BOOLEAN;

FUNCTION plan_name(plan_id IN NUMBER)
    RETURN VARCHAR2;

FUNCTION get_org_id (p_org_code IN VARCHAR2)
    RETURN NUMBER;

FUNCTION get_plan_type (p_lookup_code IN VARCHAR2) RETURN VARCHAR2;

END qa_plans_api;

 

/
