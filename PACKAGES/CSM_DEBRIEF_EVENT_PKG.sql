--------------------------------------------------------
--  DDL for Package CSM_DEBRIEF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_DEBRIEF_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmedebs.pls 120.1.12010000.1 2008/07/28 16:13:34 appldev ship $ */

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

FUNCTION MATERIAL_BILLABLE_FLAG(p_debrief_line_id IN NUMBER, p_inventory_item_id IN NUMBER,
                                p_user_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE DEBRIEF_LINE_INS_INIT (p_debrief_line_id IN NUMBER, p_h_user_id IN NUMBER,
                                 p_flow_type IN VARCHAR2);

PROCEDURE DEBRIEF_LINES_ACC_I(p_debrief_line_id IN NUMBER, p_billing_category IN VARCHAR2,
                              p_user_id IN NUMBER);

PROCEDURE DEBRIEF_LINE_DEL_INIT (p_debrief_line_id IN NUMBER, p_user_id IN NUMBER,
                                 p_flow_type IN VARCHAR2);

PROCEDURE DEBRIEF_LINES_ACC_D(p_debrief_line_id IN NUMBER, p_billing_category IN VARCHAR2,
                              p_user_id IN NUMBER);

PROCEDURE DEBRIEF_LINE_UPD_INIT(p_debrief_line_id IN NUMBER, p_old_inventory_item_id IN NUMBER,
                                p_is_inventory_item_updated IN VARCHAR2, p_old_instance_id IN NUMBER,
                                p_is_instance_updated IN VARCHAR2);

PROCEDURE DEBRIEF_LINES_ACC_U(p_debrief_line_id IN NUMBER, p_billing_category IN VARCHAR2,
                              p_access_id IN NUMBER, p_user_id IN NUMBER);

END CSM_DEBRIEF_EVENT_PKG; -- Package spec

/
