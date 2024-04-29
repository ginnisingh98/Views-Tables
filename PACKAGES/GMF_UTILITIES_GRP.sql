--------------------------------------------------------
--  DDL for Package GMF_UTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_UTILITIES_GRP" AUTHID CURRENT_USER AS
    /*  $Header: gmfputls.pls 120.1.12010000.2 2009/11/11 19:31:27 rpatangy ship $ */
    --****************************************************************************************************
--*                                                                                                  *
--* Oracle Process Manufacturing                                                                     *
--* ============================                                                                     *
--*                                                                                                  *
--* Package GMF_UTILITIES_GRP                                                                        *
--* ---------------------------                                                                      *
--* This package contains the common utility functions                                                      *
--* For individual procedures' descriptions, see the                                                 *
--* description in front of each one.                                                                *
--*                                                                                                  *
--*                                                                                                  *
--* HISTORY                                                                                          *
--* =======                                                                                          *
--* 8-Sep -2005   Jahnavi Boppana    created                                                         *
--* 01-Oct-2005   Prasad Marada   Added get organization, get item methods                           *
--*                                                                                                  *
--****************************************************************************************************


   FUNCTION GET_ACCOUNT_DESC(P_ACCOUNT_ID IN NUMBER, P_LEGAL_ENTITY_ID IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_ACCOUNT_CODE(P_ACCOUNT_ID IN NUMBER, P_LEGAL_ENTITY_ID IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_LEGAL_ENTITY(P_LEGAL_ENTITY_ID IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_ORGANIZATION_NAME(P_ORGANIZATION_ID IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_ORGANIZATION_CODE(P_ORGANIZATION_ID IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION GET_ACCOUNT_DESC(P_ACCOUNT_KEY IN VARCHAR2, P_LEGAL_ENTITY_ID IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_item_number(p_inventory_item_id IN NUMBER,
                            p_organization_id   IN NUMBER )  RETURN VARCHAR2;

   FUNCTION get_cost_category(p_category_id IN NUMBER)  RETURN VARCHAR2;

   FUNCTION GET_ACCOUNT_DESC(P_ACCOUNT IN VARCHAR2,
                             P_LEGAL_ENTITY_ID IN NUMBER,
                             P_FLAG IN VARCHAR2) RETURN VARCHAR2;

   FUNCTION BEFOREREPORT RETURN BOOLEAN ;

END GMF_UTILITIES_GRP;

/
