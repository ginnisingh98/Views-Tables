--------------------------------------------------------
--  DDL for Package CSM_INV_LOC_ASS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_INV_LOC_ASS_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeilas.pls 120.1 2005/07/25 00:10:01 trajasek noship $*/
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

PROCEDURE INV_LOC_ASSIGNMENT_INS_INIT (p_csp_inv_loc_assignment_id IN NUMBER);

PROCEDURE INV_LOC_ASS_ACC_I(p_csp_inv_loc_assignment_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE INV_LOC_ASSIGNMENT_DEL_INIT(p_csp_inv_loc_assignment_id IN NUMBER);

PROCEDURE INV_LOC_ASS_ACC_D(p_csp_inv_loc_assignment_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE INV_LOC_ASSIGNMENT_UPD_INIT(p_csp_inv_loc_assignment_id IN NUMBER);

END; -- Package spec

 

/
