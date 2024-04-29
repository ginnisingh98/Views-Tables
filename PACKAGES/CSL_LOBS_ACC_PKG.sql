--------------------------------------------------------
--  DDL for Package CSL_LOBS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_LOBS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csllbacs.pls 120.0 2005/05/25 10:59:35 appldev noship $ */

  PROCEDURE INSERT_ACC_RECORD (
    p_task_assignment_id IN NUMBER,
    p_resource_id IN NUMBER);

  PROCEDURE DELETE_ACC_RECORD (
    p_task_assignment_id IN NUMBER,
    p_resource_id IN NUMBER);

  PROCEDURE CONC_DOWNLOAD_ATTACHMENTS (
    p_status OUT NOCOPY VARCHAR2,
    p_message OUT NOCOPY VARCHAR2);

  PROCEDURE DOWNLOAD_SR_ATTACHMENTS (
    p_incident_id IN NUMBER);

  PROCEDURE DOWNLOAD_TASK_ATTACHMENTS (
    p_task_id IN NUMBER);

  PROCEDURE DELETE_ATTACHMENTS ( p_entity_name IN VARCHAR2,
                                p_primary_key IN NUMBER,
                                p_resource_id IN NUMBER);

END CSL_LOBS_ACC_PKG;

 

/
