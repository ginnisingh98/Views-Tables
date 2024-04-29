--------------------------------------------------------
--  DDL for Package CSM_CONTRACT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CONTRACT_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmectrs.pls 120.1 2005/07/22 09:05:47 trajasek noship $*/

PROCEDURE INSERT_CONTRACT_HEADER
  ( p_incident_id IN NUMBER
  , p_user_id IN NUMBER
  ) ;

PROCEDURE SR_CONTRACT_ACC_I (p_incident_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE SR_CONTRACT_ACC_D (p_incident_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE SR_CONTRACT_ACC_U (p_incident_id IN NUMBER, p_old_contract_service_id IN NUMBER,
                             p_contract_service_id IN NUMBER, p_user_id IN NUMBER);

END CSM_CONTRACT_EVENT_PKG;


 

/
