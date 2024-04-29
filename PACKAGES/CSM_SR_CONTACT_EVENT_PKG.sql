--------------------------------------------------------
--  DDL for Package CSM_SR_CONTACT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SR_CONTACT_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmesrcs.pls 120.1 2005/07/25 00:22:27 trajasek noship $ */

-- Generated 6/13/2002 7:52:56 PM from APPS@MOBSVC01.US.ORACLE.COM

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

PROCEDURE SR_CNTACT_MDIRTY_U_FOREACHUSER(p_sr_contact_point_id IN NUMBER);

PROCEDURE SR_CNTACT_MDIRTY_I(p_sr_contact_point_id IN NUMBER, p_user_id IN NUMBER) ;

PROCEDURE SPAWN_USERLOOP_SR_CONTACT_INS(p_sr_contact_point_id IN NUMBER);

PROCEDURE SR_CNTACT_MDIRTY_D(p_sr_contact_point_id IN NUMBER, p_user_id IN NUMBER) ;

PROCEDURE SPAWN_USERLOOP_SR_CONTACT_DEL(p_sr_contact_point_id IN NUMBER);

FUNCTION CONTACT_POINT_UPD_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

END CSM_SR_CONTACT_EVENT_PKG; -- Package spec

 

/
