--------------------------------------------------------
--  DDL for Package WIP_POPULATE_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_POPULATE_TEMP" AUTHID CURRENT_USER as
/* $Header: wiputmts.pls 120.0.12000000.1 2007/01/18 22:22:52 appldev ship $ */

PROCEDURE INSERT_TEMP
(p_transaction_mode IN NUMBER,
 p_wip_entity_id IN NUMBER,
 p_line_id IN NUMBER,
 p_transaction_date IN DATE,
 p_transaction_type_id IN NUMBER,
 p_transaction_action_id IN NUMBER,
 p_subinventory IN VARCHAR2,
 p_locator_id IN NUMBER,
 p_repetitive_days IN NUMBER,
 p_assembly_quantity IN NUMBER,
 p_operation_seq_num IN NUMBER,
 p_department_id IN NUMBER,
 p_criteria_sub IN VARCHAR2,
 p_organization_id IN NUMBER,
 p_acct_period_id IN NUMBER,
 p_last_updated_by IN NUMBER,
 p_entity_type IN NUMBER,
 p_next_seq_num IN NUMBER,
 p_calendar_code IN VARCHAR2,
 p_exception_set_id IN NUMBER,
 p_transaction_header_id IN NUMBER,
 p_commit_counter OUT  NOCOPY NUMBER)
 ;

END WIP_POPULATE_TEMP;

 

/
