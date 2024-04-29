--------------------------------------------------------
--  DDL for Package CSM_CSP_REQ_HEADERS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CSP_REQ_HEADERS_EVENT_PKG" 
/* $Header: csmerhs.pls 120.1 2005/07/25 00:20:00 trajasek noship $*/
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

PROCEDURE CSP_REQ_HEADERS_MDIRTY_I(p_requirement_header_id IN NUMBER,
                                   p_user_id IN NUMBER);

PROCEDURE CSP_REQ_HEADERS_MDIRTY_D(p_requirement_header_id IN NUMBER,
                                   p_user_id IN NUMBER);

PROCEDURE CSP_REQ_HEADERS_MDIRTY_U(p_requirement_header_id IN NUMBER,
                                   p_user_id IN NUMBER);

END CSM_CSP_REQ_HEADERS_EVENT_PKG; -- Package spec

 

/
