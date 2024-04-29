--------------------------------------------------------
--  DDL for Package CSM_ITEM_INSTANCE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_ITEM_INSTANCE_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeibs.pls 120.2 2006/05/31 12:58:20 trajasek noship $ */


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

PROCEDURE ITEM_INSTANCE_MDIRTY_U_ECHUSER(p_instance_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE II_RELATIONSHIPS_ACC_I(p_relationship_id IN NUMBER,
                                 p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE ITEM_INSTANCES_ACC_PROCESSOR(p_instance_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flowtype IN VARCHAR2,
                                       p_error_msg     OUT NOCOPY    VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE II_RELATIONSHIPS_ACC_D(p_relationship_id IN NUMBER,
                                 p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE ITEM_INSTANCES_ACC_D(p_instance_id IN NUMBER,
                               p_user_id IN NUMBER,
                               p_error_msg     OUT NOCOPY   VARCHAR2,
                               x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE REFRESH_INSTANCES_ACC (p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE GET_IB_AT_LOCATION(p_instance_id IN NUMBER, p_party_site_id IN NUMBER, p_party_id IN NUMBER,
                             p_location_id IN NUMBER, p_user_id IN NUMBER, p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_COUNTERS_INS (p_instance_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE DELETE_IB_AT_LOCATION(p_incident_id IN NUMBER, p_instance_id IN NUMBER, p_party_site_id IN NUMBER, p_party_id IN NUMBER,
                             p_location_id IN NUMBER, p_user_id IN NUMBER, p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_COUNTERS_DEL (p_instance_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE DELETE_IB_NOTIN_INV (p_inv_item_id IN NUMBER, p_org_id IN NUMBER, p_user_id IN NUMBER);

END CSM_ITEM_INSTANCE_EVENT_PKG; -- Package spec



 

/
