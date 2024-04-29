--------------------------------------------------------
--  DDL for Package CSM_CSP_REQ_LINES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CSP_REQ_LINES_EVENT_PKG" 
/* $Header: csmerls.pls 120.1.12010000.2 2008/10/20 10:17:27 trajasek ship $*/
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

PROCEDURE CSP_REQ_LINES_MDIRTY_I(p_requirement_line_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE CSP_REQ_LINES_MDIRTY_D(p_requirement_line_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE CSP_REQ_LINES_MDIRTY_U(p_requirement_line_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE CONC_ORDER_UPDATE(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2);

END CSM_CSP_REQ_LINES_EVENT_PKG; -- Package spec

/
