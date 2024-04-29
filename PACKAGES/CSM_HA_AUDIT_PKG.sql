--------------------------------------------------------
--  DDL for Package CSM_HA_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_HA_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmhadts.pls 120.0.12010000.1 2010/04/08 06:37:56 saradhak noship $*/

PROCEDURE AUDIT_RECORD(p_ha_payload_id IN NUMBER, p_audit_type IN VARCHAR2);

END CSM_HA_AUDIT_PKG;


/
