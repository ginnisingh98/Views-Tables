--------------------------------------------------------
--  DDL for Package PAY_JP_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_SOE_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpsoe.pkh 120.1 2006/12/11 07:28:19 ttagawa noship $ */
-------------------------------------------------------------------------------
TYPE lock_status_t is RECORD(
	lock_status     varchar2(30),
	action_status   varchar2(30));
-------------------------------------------------------------------------------
TYPE lock_action_t is RECORD(
	assignment_action_id    number,
        action_status           varchar2(30),
        object_version_number   number,
        payroll_action_id       number,
        action_type             varchar2(30),
        effective_date          date);
-------------------------------------------------------------------------------
FUNCTION messages_exist_flag(
	p_source_id		IN NUMBER,
	p_source_type		IN VARCHAR2) RETURN VARCHAR2;
-------------------------------------------------------------------------------
FUNCTION retro_entries_processed_flag(p_creator_id IN NUMBER) RETURN VARCHAR2;
-------------------------------------------------------------------------------
FUNCTION entry_processed_flag(
	p_element_entry_id	IN NUMBER,
	p_effective_start_date	IN DATE,
	p_effective_end_date	IN DATE) RETURN VARCHAR2;
-------------------------------------------------------------------------------
Function lock_action(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2) return lock_action_t;
-------------------------------------------------------------------------------
Function lock_status(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2) return lock_status_t;
-------------------------------------------------------------------------------
Function get_lock_action_val(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2,
	p_attribute		IN VARCHAR2) return VARCHAR2;
-------------------------------------------------------------------------------
Function get_lock_action_num(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2,
	p_attribute		IN VARCHAR2) return NUMBER;
-------------------------------------------------------------------------------
Function get_lock_status_val(
	p_locked_action_id	IN NUMBER,
	p_locking_action_type	IN VARCHAR2,
	p_attribute		IN VARCHAR2) return VARCHAR2;
-------------------------------------------------------------------------------
PROCEDURE lock_row(
	p_assignment_action_id	IN NUMBER,
	p_object_version_number	IN NUMBER);
-------------------------------------------------------------------------------
PROCEDURE rollback(
	p_validate		IN BOOLEAN DEFAULT FALSE,
	p_rollback_mode		IN VARCHAR2,
	p_assignment_action_id	IN NUMBER,
	p_payroll_action_id	IN NUMBER,
	p_action_type		IN VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE reverse_assact(
	p_assignment_action_id	IN NUMBER);
-------------------------------------------------------------------------------
PROCEDURE run_attributes(
	p_assignment_action_id	IN NUMBER,
	p_itax_category		OUT NOCOPY VARCHAR2,
	p_d_itax_category	OUT NOCOPY VARCHAR2,
	p_yea_category		OUT NOCOPY VARCHAR2,
	p_d_yea_category	OUT NOCOPY VARCHAR2,
	p_allowance_ytd		OUT NOCOPY NUMBER,
	p_taxable_ytd		OUT NOCOPY NUMBER,
	p_si_prem_ytd		OUT NOCOPY NUMBER,
	p_itax_ytd		OUT NOCOPY NUMBER);
-------------------------------------------------------------------------------
FUNCTION get_effective_date(
	p_effective_date	IN DATE,
	p_assignment_id		IN NUMBER) return DATE;
-------------------------------------------------------------------------------
end pay_jp_soe_pkg;

/
