--------------------------------------------------------
--  DDL for Package QA_SOLUTION_CAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SOLUTION_CAR_PKG" AUTHID CURRENT_USER as
/* $Header: qasocors.pls 120.0.12000000.1 2007/01/19 07:13:01 appldev ship $ */


  PROCEDURE ENG_CHANGE_ORDER(
                  p_change_notice     IN VARCHAR2,
                  p_change_type       IN VARCHAR2,
                  p_description       IN VARCHAR2,
                  p_approval_list     IN VARCHAR2,
                  p_reason_code       IN VARCHAR2,
                  p_requestor         IN VARCHAR2,
                  p_eco_department    IN VARCHAR2,
                  p_priority_code     IN VARCHAR2,
                  p_collection_id     IN NUMBER,
                  p_occurrence        IN NUMBER,
                  p_organization_code IN VARCHAR2,
                  p_plan_name         IN VARCHAR2,
                  p_launch_action     IN VARCHAR2,
                  p_action_fired      IN VARCHAR2);


  FUNCTION ENG_CHANGE_ORDER_INT(
                     p_change_notice   VARCHAR2,
                     p_change_type     VARCHAR2,
                     p_description     VARCHAR2,
                     p_approval_list   VARCHAR2,
                     p_reason_code     VARCHAR2,
                     p_requestor       VARCHAR2,
                     p_eco_department  VARCHAR2,
                     p_priority_code   VARCHAR2,
                     p_org_code        VARCHAR2)
  RETURN VARCHAR2;


END QA_SOLUTION_CAR_PKG;


 

/
