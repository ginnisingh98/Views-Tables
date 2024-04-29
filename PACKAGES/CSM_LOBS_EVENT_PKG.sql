--------------------------------------------------------
--  DDL for Package CSM_LOBS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_LOBS_EVENT_PKG" AUTHID CURRENT_USER  AS
/* $Header: csmelobs.pls 120.4 2006/02/13 02:48:55 trajasek noship $*/
PROCEDURE CONC_DOWNLOAD_ATTACHMENTS (p_status OUT NOCOPY VARCHAR2,
                                     p_message OUT NOCOPY VARCHAR2);
--Bug 4938130
PROCEDURE INSERT_ALL_ACC_RECORDS (p_user_id IN NUMBER);
PROCEDURE INSERT_ACC_RECORD(p_task_assignment_id IN NUMBER, p_user_id IN NUMBER);
PROCEDURE DELETE_ACC_RECORD(p_task_assignment_id IN NUMBER, p_resource_id IN NUMBER);

PROCEDURE INSERT_ACC_ON_UPLOAD(p_PK1_value IN NUMBER, p_user_id IN NUMBER, p_entity_name IN VARCHAR,
		  					   p_data_typeid IN NUMBER,p_dodirty BOOLEAN);


END CSM_LOBS_EVENT_PKG; -- Package spec

 

/
