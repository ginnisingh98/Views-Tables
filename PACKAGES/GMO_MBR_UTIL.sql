--------------------------------------------------------
--  DDL for Package GMO_MBR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_MBR_UTIL" AUTHID CURRENT_USER AS
/* $Header: GMOMBRUS.pls 120.4 2006/03/21 02:32 rvsingh noship $ */

/* Global Variable */
  G_ORGANIZATION_ID NUMBER(15) :=NULL;

  /**********************************************************************************
   **  This Function is to retrieve Template Code Based on ERES setup for the event
   **  and event key combination
   ** IN Parameter
   **
   **      P_EVENT_NAME      -- This is ERES Business Event Name
   **      P_EVENT_KEY       -- Transaction Event Key
   ** OUT  Template Code
   ***********************************************************************************/

  FUNCTION GET_TEMPLATE_CODE(P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN VARCHAR2;

  /**********************************************************************************
   **  This Function is to retrieve XML Based on ERES setup for the event
   **  and event key combination
   ** OUT Parameter
   **      XML CLOB
   ** IN Parameters
   **      P_EVENT_NAME      -- This is ERES Business Event Name
   **      P_EVENT_KEY       -- Transaction Event Key
   **
   ***********************************************************************************/

  FUNCTION GET_MBR_XML(P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN CLOB;

  /**********************************************************************************
   **  This proceduce is wrapper on top of above functions to reduce JDBC calls from
   **  View MBR Page
   ** IN Parameter
   **
   **      P_EVENT_NAME      -- This is ERES Business Event Name
   **      P_EVENT_KEY       -- Transaction Event Key
   ** OUT Parameters
   **      X_TEMPLATE_CODE   -- Tamplate Code
   **      X_QUERY_ID        -- Query ID to navigate Evidence Store Query Page
   **      X_MBR_XML         -- XML to generate Master Batch Record
   **
   ***********************************************************************************/

  PROCEDURE GET_TEMPLATE_CODE_AND_XML(P_EVENT_NAME VARCHAR2,
                                      P_EVENT_KEY VARCHAR2,
                                      X_TEMPLATE_CODE OUT NOCOPY VARCHAR2,
                                      X_QUERY_ID OUT NOCOPY NUMBER,
                                      X_MBR_XML OUT NOCOPY CLOB);
  /**********************************************************************************
   **  This proceduce is wrapper on top of above functions to reduce JDBC calls from
   **  View CBR Page
   ** IN Parameter
   **
   **      P_EVENT_NAME      -- This is ERES Business Event Name
   **      P_EVENT_KEY       -- Transaction Event Key
   ** OUT Parameters
   **      X_TEMPLATE_CODE   -- Tamplate Code
   **      X_QUERY_ID        -- Query ID to navigate Evidence Store Query Page
   **
   ***********************************************************************************/
  PROCEDURE GET_TEMPLATE_CODE_AND_QUERYID(P_EVENT_NAME VARCHAR2,
                                      P_EVENT_KEY VARCHAR2,
                                      X_TEMPLATE_CODE OUT NOCOPY VARCHAR2,
                                      X_QUERY_ID OUT NOCOPY NUMBER);

  /**********************************************************************************
   **  This proceduce is wrapper on top of GET_USER_DISPLAY_NAME functions
   **   of GMO_UTILITY to use in XML Map.
   ** IN Parameter
   **
   **      P_USER_ID      -- USER ID
   ** OUT Parameters
   **      P_USER_DISPLAY_NAME   -- User Display Name
   **
   ***********************************************************************************/
PROCEDURE GET_USER_DISPLAY_NAME (P_USER_ID IN NUMBER, P_USER_DISPLAY_NAME OUT nocopy VARCHAR2);

  /**********************************************************************************
   **  This proceduce is return the ORG Code and ORG Name based on Event key passed to MBR Map
   ** IN Parameter
   **
   **      P_MBR_EVT_KEY         -- Event Key passed to Map
   ** OUT Parameters
   **      X_ORG_CODE            -- Organization Code
   **      X_ORG_NAME            -- Organization name
   ***********************************************************************************/

procedure get_organization (P_MBR_EVT_KEY IN VARCHAR2, X_ORG_CODE OUT NOCOPY VARCHAR2,X_ORG_NAME OUT NOCOPY VARCHAR2);

  /**********************************************************************************
   **  This function is wrapper on top of GMO_DISPENSE_SETUP_PVT.IS_DISPENSE_ITEM
   ** IN Parameter
   **
   **      P_INVENTORY_ITEM_ID      -- Inventory Item ID
   **      P_ORGANIZATION_ID        -- Organization ID
   **      P_RECIPE_ID              -- Recipe ID
   ** Return  Parameters
   **      Dispense Config ID
   **
   ***********************************************************************************/
FUNCTION GET_DISPENSE_CONFIG(P_INVENTORY_ITEM_ID IN NUMBER,P_ORGANIZATION_ID IN  NUMBER,P_RECIPE_ID IN  NUMBER) RETURN NUMBER;

  /**********************************************************************************
   **  This function set's the Globale Variable G_ORGANIZATION_ID
   ** IN Parameter
   **
   **      P_MBR_EVT_KEY         -- Event Key passed to Map
   ** Return  Parameters
   **      Number
   **
   ***********************************************************************************/


FUNCTION SET_GLOBAL_ORGID(P_MBR_EVT_KEY IN VARCHAR2) RETURN NUMBER;

END GMO_MBR_UTIL;

 

/
