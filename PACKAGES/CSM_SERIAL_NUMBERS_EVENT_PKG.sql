--------------------------------------------------------
--  DDL for Package CSM_SERIAL_NUMBERS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SERIAL_NUMBERS_EVENT_PKG" 
/* $Header: csmeslns.pls 120.2 2006/05/22 06:56:35 trajasek noship $*/
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

PROCEDURE REFRESH_MTL_SERIAL_NUMBERS_ACC;

PROCEDURE DELETE_OLD_ORG_SERIAL_NUMBERS(p_organization_id IN number
                                        , p_user_id     IN number
                                        , p_resource_id IN number);

PROCEDURE GET_NEW_ORG_SERIAL_NUMBERS(p_organization_id IN number
                                        , p_user_id     IN number
                                        , p_resource_id IN number);

PROCEDURE INV_LOC_ASS_MSN_MAKE_DIRTY_I(p_csp_inv_loc_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER);

PROCEDURE INV_LOC_ASS_MSN_MAKE_DIRTY_D(p_csp_inv_loc_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER);

PROCEDURE INSERT_MTL_SERIAL_NUMBERS(p_organization_id IN number,
p_last_run_date IN date, p_resource_id IN number, p_user_id IN number);

END; -- Package spec

 

/
