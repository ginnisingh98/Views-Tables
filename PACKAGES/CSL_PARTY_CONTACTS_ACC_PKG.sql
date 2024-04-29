--------------------------------------------------------
--  DDL for Package CSL_PARTY_CONTACTS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_PARTY_CONTACTS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslpcacs.pls 115.3 2003/07/23 23:56:57 yliao ship $ */

PROCEDURE INSERT_CONTACT_POINT( p_contact_point_id IN NUMBER
                              , p_resource_id IN NUMBER );

PROCEDURE DELETE_CONTACT_POINT( p_contact_point_id IN NUMBER
                              , p_resource_id IN NUMBER );

PROCEDURE INSERT_HZ_RELATIONSHIP( p_party_id IN NUMBER
                                , p_resource_id IN NUMBER );

PROCEDURE DELETE_HZ_RELATIONSHIP( p_party_id IN NUMBER
                                , p_resource_id IN NUMBER );

PROCEDURE INSERT_CS_HZ_SR_CONTACTS(p_incident_id IN NUMBER
                                  ,p_resource_id IN NUMBER
				  ,p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL);

PROCEDURE DELETE_CS_HZ_SR_CONTACTS(p_incident_id IN NUMBER
                                  ,p_resource_id IN NUMBER
				  ,p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL);

PROCEDURE INSERT_PER_ALL_PEOPLE_F( p_person_id IN NUMBER
                                 , p_resource_id IN NUMBER );

PROCEDURE DELETE_PER_ALL_PEOPLE_F( p_person_id IN NUMBER
                                 , p_resource_id IN NUMBER );

FUNCTION UPDATE_CONTACT_POINT_WFSUB( p_subscription_guid   in     raw
               , p_event               in out NOCOPY wf_event_t)
return varchar2;

END CSL_PARTY_CONTACTS_ACC_PKG;

 

/
