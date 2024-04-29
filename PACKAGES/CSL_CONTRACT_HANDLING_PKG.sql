--------------------------------------------------------
--  DDL for Package CSL_CONTRACT_HANDLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CONTRACT_HANDLING_PKG" AUTHID CURRENT_USER AS
/* $Header: cslctrhs.pls 115.2 2002/12/10 09:57:14 vekrishn ship $ */

PROCEDURE POST_INSERT_SR_CONTRACT_ACC (
	  p_incident_id IN NUMBER
	, p_resource_id IN NUMBER
	, x_return_status OUT NOCOPY varchar2);
	/* Called after SR-ACC Insert */


PROCEDURE POST_UPDATE_SR_CONTRACT_ACC (
	  p_incident_id             IN  NUMBER
        , p_old_contract_service_id IN  NUMBER
        , p_new_contract_service_id IN  NUMBER
	, p_resource_id             IN  NUMBER
	, x_return_status           OUT NOCOPY VARCHAR2);
	/* Called after SR-ACC Update */


PROCEDURE PRE_DELETE_SR_CONTRACT_ACC (
	  p_incident_id   IN NUMBER
	, p_resource_id   IN NUMBER
	, x_return_status OUT NOCOPY VARCHAR2);
	/* Called before SR-ACC delete */

END CSL_CONTRACT_HANDLING_PKG;

 

/
