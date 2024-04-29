--------------------------------------------------------
--  DDL for Package CSM_DEBRIEF_HEADER_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_DEBRIEF_HEADER_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmedbhs.pls 120.1 2005/07/24 23:45:22 trajasek noship $ */
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

PROCEDURE DEBRIEF_HEADER_INS_INIT(p_debrief_header_id IN NUMBER, p_h_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2);

PROCEDURE DEBRIEF_HEADER_MDIRTY_I(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE DEBRIEF_HEADER_DEL_INIT(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2);

PROCEDURE DEBRIEF_HEADER_MDIRTY_D(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE DEBRIEF_HEADER_MDIRTY_U(p_debrief_header_id IN NUMBER, p_user_id IN NUMBER);

END CSM_DEBRIEF_HEADER_EVENT_PKG;

 

/
