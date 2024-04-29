--------------------------------------------------------
--  DDL for Package ITA_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITA_NOTIFICATION_PKG" AUTHID CURRENT_USER as
/* $Header: itapnots.pls 120.2 2006/07/25 21:29:17 cpetriuc noship $ */


function GET_ORG_CONNECTIONS_STRING return VARCHAR2;


function GET_AUDIT_UNITS_STRING(p_org_id NUMBER) return VARCHAR2;


function GET_HIERARCHY_ENTITIES_STRING(p_org_type_code VARCHAR2, p_org_id NUMBER, p_control_id NUMBER) return VARCHAR2;


procedure SEND_NOTIFICATION_TO_ALL(p_change_id NUMBER);


procedure SEND_NOTIFICATION_TO_OWNER(
p_control_id IN NUMBER,
p_control_name IN VARCHAR2,
p_source IN VARCHAR2,
p_process_owner_id IN NUMBER,
p_return_status OUT NOCOPY VARCHAR2,
p_setup_group IN VARCHAR2,
p_application IN VARCHAR2,
p_org_type IN VARCHAR2,
p_org IN VARCHAR2,
p_setup_parameter IN VARCHAR2,
p_rec_value IN VARCHAR2,
p_prior_value IN VARCHAR2,
p_current_value IN VARCHAR2,
p_updated_on IN DATE,
p_updated_by IN VARCHAR2);


end ITA_NOTIFICATION_PKG;

 

/
