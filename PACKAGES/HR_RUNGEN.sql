--------------------------------------------------------
--  DDL for Package HR_RUNGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RUNGEN" AUTHID CURRENT_USER as
/* $Header: pyrungen.pkh 115.3 2002/12/09 15:13:39 divicker ship $ */
  --
  -- Exception Handlers
  --
  zero_req_id                 Exception;
  pragma exception_init(zero_req_id, -9999);

--
PROCEDURE generate_runs (
		ERRBUF			 OUT NOCOPY VARCHAR2,
		RETCODE			 OUT NOCOPY NUMBER,
		p_process_name			IN VARCHAR2	default 'RUN',
 		p_pay_action_id			IN NUMBER	default NULL,
		p_payroll_id			IN NUMBER	default NULL,
		p_consolidation_set_id		IN NUMBER	default NULL,
		p_earned_date			IN VARCHAR2	default NULL,
		p_date_paid			IN VARCHAR2	default NULL,
		p_assignment_set_id		IN NUMBER	default NULL,
		p_ele_set_id			IN NUMBER	default NULL,
		p_leg_params			IN VARCHAR2	default 'R',
		p_pay_advice_message		IN VARCHAR2	default NULL);
--
--		p_retry_action_date		IN VARCHAR2	default NULL,
--
-- NOTE: The process name is the 'ACTION_TYPE' on payroll action;
--	 Leg params is 'R'egular, 'S'upplemental, 'SEPCHECK', or 'SPECIALPROC'.
--
PROCEDURE Del_Asg_Amends (p_assignment_set_id	IN NUMBER);
--
END hr_rungen;

 

/
