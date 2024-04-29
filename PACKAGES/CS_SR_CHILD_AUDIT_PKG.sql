--------------------------------------------------------
--  DDL for Package CS_SR_CHILD_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_CHILD_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: cssrauds.pls 120.1 2005/10/14 14:36:09 smisra noship $*/


/***************
Custom Function corrsponds to the business events published by SR child entities.
This custom function will be called from the subscriptions of the update/create/delete events for the
following SR child entities.
1. SR Tasks
2. SR Notes
3. SR Solution Links.
4. SR Task Assignments

***************/

FUNCTION CS_SR_Audit_ChildEntities
                (P_subscription_guid  IN RAW,
                 P_event              IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2 ;



/***************
 Procedure to create an audit record in SR audit table when ever a SR or SR child entity is updated.
***************/

PROCEDURE CS_SR_AUDIT_CHILD
             (P_incident_id           IN NUMBER,
              P_updated_entity_code   IN VARCHAR2 ,
              p_updated_entity_id     IN NUMBER ,
              p_entity_update_date    IN DATE ,
              p_entity_activity_code  IN VARCHAR2 ,
              p_status_id	      IN NUMBER DEFAULT NULL,
              p_old_status_id	      IN NUMBER DEFAULT NULL,
              p_closed_date	      IN DATE DEFAULT NULL,
              p_old_closed_date	      IN DATE DEFAULT NULL,
              p_owner_id	      IN NUMBER DEFAULT NULL,
              p_old_owner_id	      IN NUMBER DEFAULT NULL,
              p_owner_group_id	      IN NUMBER DEFAULT NULL,
              p_old_owner_group_id    IN NUMBER DEFAULT NULL,
              p_resource_type	      IN VARCHAR2 DEFAULT NULL,
              p_old_resource_type     IN VARCHAR2 DEFAULT NULL,
              p_owner_status_upd_flag IN VARCHAR2 DEFAULT 'NONE',
              p_update_program_code   IN VARCHAR2 DEFAULT 'NONE',
              p_user_id               IN NUMBER   DEFAULT NULL,
              p_old_inc_responded_by_date  IN DATE    DEFAULT NULL,
              p_old_incident_resolved_date IN DATE    DEFAULT NULL,
              x_audit_id             OUT NOCOPY NUMBER,
              x_return_status        OUT NOCOPY VARCHAR2,
	      x_msg_count            OUT NOCOPY NUMBER,
	      x_msg_data             OUT NOCOPY VARCHAR2 );


END CS_SR_CHILD_AUDIT_PKG;

 

/
