--------------------------------------------------------
--  DDL for Package HR_JPRTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JPRTS" AUTHID CURRENT_USER AS
/* $Header: pyjprts.pkh 120.1 2005/09/26 19:27:33 ttagawa noship $ */
/* ------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------
-- Define Global Value, which are parameter values in HR_JP_PARAMETERS.
-- HR_JPBAL, HR_JPDRB call them.
-- ------------------------------------------------------------------------------------ */
g_asg_run		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_RUN';
g_asg_proc_ptd		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_PTD';
g_asg_mtd_jp		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_MTD                      EFFECTIVE_DATE 01-01 RESET 12';
g_ast_ytd_jp		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01';
g_asg_fytd_jp		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_FYTD                     DATE_EARNED          RESET 01';
g_asg_aug2jul_jp	PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_AUGTD                    EFFECTIVE_DATE 01-08 RESET 01';
g_asg_jul2jun_jp	PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_JULTD                    EFFECTIVE_DATE 01-07 RESET 01';
g_retro			PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_RETRO_RUN';
g_asg_itd		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_LTD';
g_element_itd		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ELM_LTD';
g_element_ptd		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ELM_PTD';
g_payment		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_PAYMENTS';
g_asg_fytd2_jp		PAY_BALANCE_DIMENSIONS.DIMENSION_NAME%TYPE := '_ASG_BYTD';
/* ------------------------------------------------------------------------------------ */
	FUNCTION span_start(
		p_input_date		IN DATE,
		p_frequency		IN NUMBER,
		p_start_dd_mm  		IN VARCHAR2)
	RETURN date ;
--	PRAGMA RESTRICT_REFERENCES (span_start, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION span_end(
	        p_input_date   IN DATE,
	        p_frequency    IN NUMBER,
	        p_end_dd_mm  IN VARCHAR2)
	RETURN date ;
--	PRAGMA RESTRICT_REFERENCES (span_end, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION span_start_fisical_year(
		p_input_date		IN DATE,
		p_business_group_id	NUMBER
		)
	RETURN date;
--	PRAGMA RESTRICT_REFERENCES (span_start_fisical_year, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION span_end_fisical_year(
		p_input_date		IN DATE,
		p_business_group_id	NUMBER
		)
	RETURN date;
--	PRAGMA RESTRICT_REFERENCES (span_end_fisical_year, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	-- what is the latest reset date for a particular dimension
	FUNCTION dimension_reset_date(
		p_dimension_name		IN VARCHAR2,
		p_user_date			IN DATE)
	RETURN date;
--	PRAGMA RESTRICT_REFERENCES (dimension_reset_date, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	-- what is the latest reset last date for a particular dimension
	FUNCTION dimension_reset_last_date(
		p_dimension_name		IN VARCHAR2,
		p_user_date			IN DATE)
	RETURN date;
--	PRAGMA RESTRICT_REFERENCES (dimension_reset_last_date, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION dimension_reset_date_userdef(
		p_dimension_name		IN VARCHAR2,
		p_user_date			IN DATE,
		p_storage_type			IN VARCHAR2, -- ('FLEX' for Org.Developer,
							     --  'GLOBAL' for Global Value)
		p_storage_name			IN VARCHAR2,
		p_business_group_id		NUMBER
		)
	RETURN date;
--	PRAGMA RESTRICT_REFERENCES (dimension_reset_date_userdef, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION dim_reset_last_date_userdef(
		p_dimension_name		IN VARCHAR2,
		p_user_date			IN DATE,
		p_storage_type			IN VARCHAR2, -- ('FLEX' for Org.Developer,
							     --  'GLOBAL' for Global Value)
		p_storage_name			IN VARCHAR2,
		p_business_group_id		NUMBER
		)
	RETURN date;
--	PRAGMA RESTRICT_REFERENCES (dim_reset_last_date_userdef, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_bal_date_earned(
		p_assignment_id 	IN NUMBER,
		p_balance_type_id	IN NUMBER,	-- balance
		p_from_date		IN DATE,	-- since effective date of
		p_to_date 		IN DATE,	-- sum up to this date
		p_action_sequence 	IN NUMBER)	-- sum up to this sequence
	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (calc_bal_date_earned, WNDS, WNPS);
--
-- This procedure is no more used since pay_balance_pkg.get_value work this logic instead.
-- Blank out by keyazawa for bug.
--/* ------------------------------------------------------------------------------------ */
--	FUNCTION calc_bal_bue(
--		p_assignment_id 	IN NUMBER,
--		p_balance_type_id	IN NUMBER,	-- balance
--		p_from_date		IN DATE,	-- since effective date of
--		p_to_date 		IN DATE)	-- sum up to this date
--	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (calc_bal_bue, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION calc_bal_eff_date(
		p_assignment_id 	IN NUMBER,
		p_balance_type_id	IN NUMBER,	-- balance
		p_from_date		IN DATE,	-- since effective date of
		p_to_date 		IN DATE,	-- sum up to this date
		p_action_sequence 	IN NUMBER)	-- sum up to this sequence
	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (calc_bal_eff_date, WNDS, WNPS);
--
-- This procedure is no more used since pay_balance_pkg.get_value work this logic instead.
-- Blank out by keyazawa for bug.
--/* ------------------------------------------------------------------------------------ */
--	FUNCTION asg_mtd_jp(
--		p_assignment_action_id	IN NUMBER,
--		p_balance_type_id	IN NUMBER)  -- balance
----		p_dimension_name	IN VARCHAR2)
--	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (asg_mtd_jp, WNDS, WNPS);
--
--
-- This procedure is no more used since pay_balance_pkg.get_value work this logic instead.
-- Blank out by keyazawa for bug.
--/* ------------------------------------------------------------------------------------ */
--	FUNCTION asg_ytd_jp(
--		p_assignment_action_id	IN NUMBER,
--		p_balance_type_id	IN NUMBER)  -- balance
----		p_dimension_name	IN VARCHAR2)
--	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (asg_ytd_jp, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION asg_fytd_jp(
		p_assignment_action_id	IN NUMBER,
		p_balance_type_id	IN NUMBER)  -- balance
--		p_dimension_name	IN VARCHAR2)
	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (asg_fytd_jp, WNDS, WNPS);
--
--
-- This procedure is no more used since pay_balance_pkg.get_value work this logic instead.
-- Blank out by keyazawa for bug.
--/* ------------------------------------------------------------------------------------ */
--	FUNCTION asg_aug2jul_jp(
--		p_assignment_action_id	IN NUMBER,
--		p_balance_type_id	IN NUMBER)  -- balance
----		p_dimension_name	IN VARCHAR2)
--	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (asg_aug2jul_jp, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
	FUNCTION retro_jp(
		p_assignment_action_id	IN NUMBER,
		p_balance_type_id	IN NUMBER)	-- balance
	RETURN NUMBER;
--	PRAGMA RESTRICT_REFERENCES (retro_jp, WNDS, WNPS);
/* ------------------------------------------------------------------------------------ */
--
END hr_jprts;
 

/
