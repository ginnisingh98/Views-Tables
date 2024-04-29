--------------------------------------------------------
--  DDL for Package CSM_PO_LOCATIONS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PO_LOCATIONS_EVENT_PKG" 
/* $Header: csmepols.pls 120.1 2005/07/25 00:17:35 trajasek noship $*/
  AUTHID CURRENT_USER AS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE CSP_SHIP_TO_ADDR_MDIRTY_I(p_location_id IN NUMBER,
                                    p_site_use_id IN NUMBER,
                                    p_user_id IN NUMBER);

PROCEDURE CSP_SHIP_TO_ADDR_MDIRTY_U(p_location_id IN NUMBER,
                                    p_site_use_id IN NUMBER,
                                    p_user_id IN NUMBER);

FUNCTION CUST_ACCT_SITE_UPD_WF_EVENT(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

END CSM_PO_LOCATIONS_EVENT_PKG; -- Package spec

 

/
