--------------------------------------------------------
--  DDL for Package EAM_WL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WL_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: EAMWLUTS.pls 120.0 2005/06/08 02:37:54 appldev noship $ */

FUNCTION get_item_description( p_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;
FUNCTION get_concatenated_segments( p_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;
FUNCTION get_translatable_value(p_lookup_code NUMBER, p_lookup_type VARCHAR2) RETURN VARCHAR2;
FUNCTION get_department_code(p_department_id NUMBER, p_organization_id NUMBER ) RETURN VARCHAR2;
FUNCTION get_wip_entity_name( p_wip_entity_id NUMBER) RETURN VARCHAR2;
FUNCTION get_wo_status( p_wip_entity_id NUMBER) RETURN VARCHAR2;
FUNCTION get_serial_description( p_serial_number VARCHAR2, p_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;
FUNCTION Is_Stock_Enable( p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2;
FUNCTION get_instance_count( p_operation_seq_num NUMBER,
			     p_wip_entity_id NUMBER,
			     p_organization_id NUMBER,
			     p_resource_type NUMBER) RETURN VARCHAR2;
FUNCTION get_wip_job_sequence return NUMBER;
FUNCTION isESignatureRequired(p_transaction_name IN VARCHAR2) return VARCHAR2;

END EAM_WL_UTIL_PKG;

 

/
