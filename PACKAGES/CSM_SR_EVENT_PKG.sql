--------------------------------------------------------
--  DDL for Package CSM_SR_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SR_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmesrs.pls 120.3.12010000.2 2009/09/18 03:17:24 trajasek ship $ */

-- Generated 6/13/2002 7:54:10 PM from APPS@MOBSVC01.US.ORACLE.COM

-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Melvin P   05/02/02 Base creation
   -- Enter package declarations as shown below

-- global variable to track count of IB items at a location
g_ib_count     NUMBER := 0;

PROCEDURE PURGE_INCIDENTS_CONC (p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

FUNCTION IS_SR_TASK ( p_task_id IN NUMBER) RETURN BOOLEAN;

FUNCTION IS_TASK_STATUS_DOWNLOADABLE(p_task_id IN NUMBER) RETURN BOOLEAN;

FUNCTION IS_ASSGN_STATUS_DOWNLOADABLE(p_task_assignment_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE SPAWN_SR_CONTACTS_INS(p_incident_id IN NUMBER, p_sr_contact_point_id IN NUMBER DEFAULT NULL,
                                p_user_id IN NUMBER, p_flowtype IN VARCHAR2);

PROCEDURE SR_ITEM_INS_INIT(p_incident_id IN NUMBER, p_instance_id IN NUMBER, p_party_site_id IN NUMBER,
                           p_party_id IN NUMBER, p_location_id IN NUMBER, p_organization_id IN NUMBER,
                           p_user_id IN NUMBER, p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_ITEM_INSTANCES_INS (p_instance_id IN NUMBER, p_organization_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE INCIDENTS_ACC_I(p_incident_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE SPAWN_SR_CONTACT_DEL(p_incident_id IN NUMBER, p_sr_contact_point_id IN NUMBER DEFAULT NULL,
                               p_user_id IN NUMBER, p_flowtype IN VARCHAR2);

PROCEDURE SR_ITEM_DEL_INIT(p_incident_id IN NUMBER, p_instance_id IN NUMBER, p_party_site_id IN NUMBER,
                           p_party_id IN NUMBER, p_location_id IN NUMBER, p_organization_id IN NUMBER,
                           p_user_id IN NUMBER, p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_ITEM_INSTANCES_DEL (p_instance_id IN NUMBER, p_organization_id IN NUMBER,
                                    p_user_id IN NUMBER);

PROCEDURE INCIDENTS_ACC_D(p_incident_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE SR_INS_INIT(p_incident_id IN NUMBER);

--12.1
PROCEDURE SR_DEL_INIT(p_incident_id IN NUMBER,p_user_id IN NUMBER DEFAULT NULL);

PROCEDURE SR_UPD_INIT(p_incident_id IN NUMBER, p_is_install_site_updated IN VARCHAR2,
                      p_old_install_site_id IN NUMBER,
                      p_is_incident_location_updated IN VARCHAR2,
                      p_old_incident_location_id IN NUMBER, p_is_sr_customer_updated IN VARCHAR2,
                      p_old_sr_customer_id IN NUMBER, p_is_sr_instance_updated IN VARCHAR2,
                      p_old_instance_id IN NUMBER, p_is_inventory_item_updated IN VARCHAR2,
                      p_old_inventory_item_id IN NUMBER, p_old_organization_id IN NUMBER,
                      p_old_party_id IN NUMBER, p_old_location_id IN NUMBER,
                      p_is_contr_service_id_updated IN VARCHAR2, p_old_contr_service_id IN NUMBER);

FUNCTION IS_SR_OPEN ( p_task_id IN NUMBER) RETURN BOOLEAN;

--12.1
FUNCTION IS_SR_DOWNLOADED_TO_OWNER( p_task_id IN NUMBER) RETURN BOOLEAN;

--12.1.2 procedure called by workflow through mobile query
PROCEDURE GET_PROFORMA_INVOICE  (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT NOCOPY VARCHAR2
  );


END csm_sr_event_pkg; -- Package spec

/
