--------------------------------------------------------
--  DDL for Package PA_SWEEPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SWEEPER" AUTHID CURRENT_USER AS
-- $Header: PAFCUAES.pls 120.1 2005/08/08 14:51:08 pbandla noship $

 -- Function : GetBCBalStartDate
 -- Purpose  : Based on TPC, returns the start date
 -- Changed 5/29
 --            If TPC = GL then selects GL period start date where the given GL date falls.
 --            If TPC = PA then selects PA period start date where the given PA date falls.
 --            If TPC = 'N' then get the start_date from pa_bc_balances where EI date falls
 --            for the given task, budget_version and RLMI.
 FUNCTION GetBCBalStartDate(
	p_time_phase_code in varchar2,
	p_project_id in number,
	p_ei_date in date,
	p_bdgt_version in number,
	p_sob_id in number,
        p_org_id in number,
        p_task_id in number,
        p_top_task_id in number,
        p_rlmi in number,
        p_gl_date in date,
        p_pa_date in date) return date ;
 --pragma RESTRICT_REFERENCES(GetBCBalStartDate, WNDS, WNPS );

 -- Function : GetBCBalEndDate
 -- Purpose  : Based on TPC, returns the end date
 -- Changed 5/29
 --            If TPC = GL then selects GL period end date where the given GL date falls.
 --            If TPC = PA then selects PA period end date where the given PA date falls.
 --            If TPC = 'N' then get the end_date from pa_bc_balances where EI date falls
 --            for the given task, budget_version and RLMI.
 FUNCTION GetBCBalEndDate(
	p_time_phase_code in varchar2,
	p_project_id in number,
	p_ei_date in date,
	p_bdgt_version in number,
	p_sob_id in number,
        p_org_id in number,
        p_task_id in number,
        p_top_task_id in number,
        p_rlmi in number,
        p_gl_date in date,
        p_pa_date in date) return date ;
 --pragma RESTRICT_REFERENCES(GetBCBalEndDate, WNDS, WNPS );

 PROCEDURE update_act_enc_balance(
                 x_return_status       OUT NOCOPY VARCHAR2
                 ,x_error_message_code OUT NOCOPY VARCHAR2
                 ,p_project_id         IN  NUMBER DEFAULT NULL);

END PA_SWEEPER;

 

/
