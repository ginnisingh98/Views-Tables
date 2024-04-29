--------------------------------------------------------
--  DDL for Package Body GMS_BUDGET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BUDGET_PUB" as
/* $Header: gmsmbupb.pls 120.10.12010000.2 2008/08/25 09:22:44 mumohan ship $ */

/* package global to be used during updates */

-- To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

G_USER_ID  		CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID		CONSTANT NUMBER := FND_GLOBAL.login_id;

----------------------------------------------------------------------------------------

 function G_PA_MISS_NUM return number
 is
 begin
 	return GMS_BUDGET_PUB.G_MISS_NUM;
 end;

 function G_PA_MISS_CHAR return varchar2
 is
 begin
 	return GMS_BUDGET_PUB.G_MISS_CHAR;
 end;

 function G_PA_MISS_DATE return date
 is
 begin
 	return GMS_BUDGET_PUB.G_MISS_DATE;
 end;

 function G_GMS_FALSE return varchar2
 is
 begin
 	return GMS_BUDGET_PUB.G_FALSE;
 end;

 function G_GMS_TRUE return varchar2
 is
 begin
 	return GMS_BUDGET_PUB.G_TRUE;
 end;

-----------------------------------------------------------------------------------

PROCEDURE convert_projnum_to_id
(p_project_number_in 	IN VARCHAR2  	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
,p_project_id_in        	IN NUMBER    	:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,p_project_id_out       	OUT NOCOPY NUMBER
,x_err_code 		IN OUT NOCOPY NUMBER
,x_err_stage		IN OUT NOCOPY VARCHAR2
,x_err_stack		IN OUT NOCOPY VARCHAR2)

IS

cursor 	l_project_id_csr(p_project_id_in NUMBER)
IS
select 	'X'
from	pa_projects
where   project_id = p_project_id_in;

cursor	l_project_number_csr(p_project_number_in VARCHAR2)
is
select project_id
from pa_projects
where segment1 = p_project_number_in;

l_dummy				VARCHAR2(1);
l_old_stack			VARCHAR2(630);

BEGIN

 x_err_code := 0;
 l_old_stack := x_err_stack;
 x_err_stack := x_err_stack ||'-> convert_projnum_to_id';

    IF p_project_id_in  <>  GMS_BUDGET_PUB.G_PA_MISS_NUM
    AND p_project_id_in IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_project_id_csr (p_project_id_in);
      	FETCH l_project_id_csr INTO l_dummy;

      	IF l_project_id_csr%NOTFOUND
      	THEN
		CLOSE l_project_id_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_PROJ_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_project_id_csr;
      	p_project_id_out := p_project_id_in;

    ELSIF  p_project_number_in <>  GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_project_number_in IS NOT NULL
    THEN
	OPEN l_project_number_csr(p_project_number_in);
	FETCH l_project_number_csr INTO p_project_id_out;

      	IF l_project_number_csr%NOTFOUND
      	THEN
		CLOSE l_project_number_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_PROJ_NUM',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_project_number_csr;

     ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_PROJECT_REF_AND_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

END convert_projnum_to_id;
-------------------------------------------------------------------------
PROCEDURE convert_tasknum_to_id
(p_project_id_in 	IN NUMBER
,p_task_id_in        	IN NUMBER    	:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,p_task_number_in      	IN VARCHAR2    	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
,p_task_id_out       OUT NOCOPY NUMBER
,x_err_code 		IN OUT NOCOPY NUMBER
,x_err_stage		IN OUT NOCOPY VARCHAR2
,x_err_stack		IN OUT NOCOPY VARCHAR2)

IS

cursor 	l_task_id_csr(p_project_id_in NUMBER,
			p_task_id_in NUMBER)
IS
select 	'X'
from	pa_tasks
where   project_id = p_project_id_in
and	task_id = p_task_id_in;

cursor	l_task_number_csr(p_project_id_in NUMBER,
			p_task_number_in VARCHAR2)
is
select task_id
from pa_tasks
where task_number = p_task_number_in
and project_id = p_project_id_in;

l_dummy				VARCHAR2(1);
l_old_stack			VARCHAR2(630);

BEGIN

 x_err_code := 0;
 l_old_stack := x_err_stack;
 x_err_stack := x_err_stack ||'-> convert_tasknum_to_id';

    IF p_task_id_in  <>  GMS_BUDGET_PUB.G_PA_MISS_NUM
    AND p_task_id_in IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_task_id_csr (p_project_id_in, p_task_id_in);
      	FETCH l_task_id_csr INTO l_dummy;

      	IF l_task_id_csr%NOTFOUND
      	THEN
		CLOSE l_task_id_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_PROJ_TASK_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_task_id_csr;
      	p_task_id_out := p_task_id_in;

    ELSIF  p_task_number_in <>  GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_task_number_in IS NOT NULL
    THEN
	OPEN l_task_number_csr(p_project_id_in, p_task_number_in);
	FETCH l_task_number_csr INTO p_task_id_out;

      	IF l_task_number_csr%NOTFOUND
      	THEN
		CLOSE l_task_number_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_PROJ_TASK_NUM',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_task_number_csr;

     ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_TASK_NUM_AND_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;


END convert_tasknum_to_id;

-------------------------------------------------------------------------

PROCEDURE convert_awardnum_to_id
(p_award_number_in 	IN VARCHAR2  	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
,p_award_id_in        	IN NUMBER    	:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,p_award_id_out       	OUT NOCOPY NUMBER
,x_err_code 		IN OUT NOCOPY NUMBER
,x_err_stage		IN OUT NOCOPY VARCHAR2
,x_err_stack		IN OUT NOCOPY VARCHAR2)

IS

cursor 	l_award_id_csr(p_award_id_in NUMBER)
IS
select 	'X'
from	gms_awards
where   award_id = p_award_id_in;

cursor	l_award_number_csr(p_award_number_in VARCHAR2)
is
select award_id
from gms_awards
where award_number = p_award_number_in;

l_dummy				VARCHAR2(1);
l_old_stack			VARCHAR2(630);

BEGIN

 x_err_code := 0;
 l_old_stack := x_err_stack;
 x_err_stack := x_err_stack ||'-> convert_awardnum_to_id';

    IF p_award_id_in  <>  GMS_BUDGET_PUB.G_PA_MISS_NUM
    AND p_award_id_in IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_award_id_csr (p_award_id_in);
      	FETCH l_award_id_csr INTO l_dummy;

      	IF l_award_id_csr%NOTFOUND
      	THEN
		CLOSE l_award_id_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_AWARD_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_award_id_csr;
      	p_award_id_out := p_award_id_in;

    ELSIF  p_award_number_in <>  GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_award_number_in IS NOT NULL
    THEN
	OPEN l_award_number_csr(p_award_number_in);
	FETCH l_award_number_csr INTO p_award_id_out;

      	IF l_award_number_csr%NOTFOUND
      	THEN
		CLOSE l_award_number_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_AWARD_NUM',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_award_number_csr;

     ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_AND_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

END convert_awardnum_to_id;
----------------------------------------------------------------------
PROCEDURE convert_reslistname_to_id
(p_resource_list_name_in 	IN VARCHAR2  	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
,p_resource_list_id_in        	IN NUMBER    	:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,p_resource_list_id_out       	OUT NOCOPY NUMBER
,x_err_code 		IN OUT NOCOPY NUMBER
,x_err_stage		IN OUT NOCOPY VARCHAR2
,x_err_stack		IN OUT NOCOPY VARCHAR2)

IS

cursor 	l_resource_list_id_csr(p_resource_list_id_in NUMBER)
IS
select 	'X'
from	pa_resource_lists
where   resource_list_id = p_resource_list_id_in;

cursor	l_resource_list_name_csr(p_resource_list_name_in VARCHAR2)
is
select resource_list_id
from pa_resource_lists
where name = p_resource_list_name_in
and  NVL(migration_code,'M') ='M'; -- Bug 3626671

l_dummy				VARCHAR2(1);
l_old_stack			VARCHAR2(630);

BEGIN

 x_err_code := 0;
 l_old_stack := x_err_stack;
 x_err_stack := x_err_stack ||'-> convert_reslistname_to_id';

    IF p_resource_list_id_in  <>  GMS_BUDGET_PUB.G_PA_MISS_NUM
    AND p_resource_list_id_in IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_resource_list_id_csr (p_resource_list_id_in);
      	FETCH l_resource_list_id_csr INTO l_dummy;

      	IF l_resource_list_id_csr%NOTFOUND
      	THEN
		CLOSE l_resource_list_id_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_RESLIST_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_resource_list_id_csr;
      	p_resource_list_id_out := p_resource_list_id_in;

    ELSIF  p_resource_list_name_in <>  GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_resource_list_name_in IS NOT NULL
    THEN
	OPEN l_resource_list_name_csr(p_resource_list_name_in);
	FETCH l_resource_list_name_csr INTO p_resource_list_id_out;

      	IF l_resource_list_name_csr%NOTFOUND
      	THEN
		CLOSE l_resource_list_name_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_RESLIST_NAME',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_resource_list_name_csr;

     ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_RESNAME_AND_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

END convert_reslistname_to_id;
-------------------------------------------------------------------------------

PROCEDURE convert_listmem_alias_to_id
(p_resource_list_id_in			IN NUMBER
,p_reslist_member_alias_in 	IN VARCHAR2  	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
,p_resource_list_member_id_in        	IN NUMBER    	:= GMS_BUDGET_PUB.G_PA_MISS_NUM
,p_resource_list_member_id_out       	OUT NOCOPY NUMBER
,x_err_code 		IN OUT NOCOPY NUMBER
,x_err_stage		IN OUT NOCOPY VARCHAR2
,x_err_stack		IN OUT NOCOPY VARCHAR2)

IS

cursor 	l_resource_list_member_id_csr(p_resource_list_member_id_in NUMBER)
IS
select 	'X'
from	pa_resource_list_members
where   resource_list_member_id = p_resource_list_member_id_in;

cursor	l_reslist_member_alias_csr(p_resource_list_id_in NUMBER
                                , p_reslist_member_alias_in VARCHAR2)
is
select resource_list_member_id
from pa_resource_list_members
where alias = p_reslist_member_alias_in
and resource_list_id = p_resource_list_id_in
and NVL(migration_code,'M') ='M'; -- Bug 3626671

l_dummy				VARCHAR2(1);
l_old_stack			VARCHAR2(630);

BEGIN

 x_err_code := 0;
 l_old_stack := x_err_stack;
 x_err_stack := x_err_stack ||'-> convert_listmem_alias_to_id';

    IF p_resource_list_member_id_in  <>  GMS_BUDGET_PUB.G_PA_MISS_NUM
    AND p_resource_list_member_id_in IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_resource_list_member_id_csr (p_resource_list_member_id_in);
      	FETCH l_resource_list_member_id_csr INTO l_dummy;

      	IF l_resource_list_member_id_csr%NOTFOUND
      	THEN
		CLOSE l_resource_list_member_id_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_RESLIST_MEM_ID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_resource_list_member_id_csr;
      	p_resource_list_member_id_out := p_resource_list_member_id_in;

    ELSIF  p_reslist_member_alias_in <>  GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_reslist_member_alias_in IS NOT NULL
    THEN
	OPEN l_reslist_member_alias_csr(p_resource_list_id_in, p_reslist_member_alias_in);
	FETCH l_reslist_member_alias_csr INTO p_resource_list_member_id_out;

      	IF l_reslist_member_alias_csr%NOTFOUND
      	THEN
		CLOSE l_reslist_member_alias_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_RESLIST_ALIAS',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      	END IF;

      	CLOSE l_reslist_member_alias_csr;

     ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_RES_ALIAS_AND_ID_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
				x_token_name1 => 'SQLCODE',
				x_token_val1 => sqlcode,
				x_token_name2 => 'SQLERRM',
				x_token_val2 => sqlerrm,
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

END convert_listmem_alias_to_id;
------------------------------------------------------------------------------------------

procedure compare_amount_with_txns( p_award_id 			in 	NUMBER,
				p_project_id 			in	NUMBER,
				p_task_id 			in 	NUMBER,
				p_resource_list_member_id 	in	NUMBER,
				p_start_date			in	DATE,
				p_draft_burdened_cost 		in	NUMBER,
				p_fc_required 			out NOCOPY 	BOOLEAN) is

CURSOR l_txns_csr (	p_award_id 	in 	NUMBER,
			p_project_id 	in 	NUMBER,
			p_task_id	in	NUMBER,
			p_resource_list_member_id in	NUMBER,
			p_start_date	in	DATE) is

select  (nvl(gbal.actual_period_to_date,0) + nvl(gbal.encumb_period_to_date,0))
from    gms_budget_versions gbv,
        gms_budget_lines gbl,
        gms_resource_assignments gra,
        gms_balances gbal
where   gbv.budget_version_id = gra.budget_version_id
and     gra.resource_assignment_id = gbl.resource_assignment_id
and     gbal.award_id = gbv.award_id
and     gbal.project_id = gbv.project_id
and     gbal.budget_version_id = gbv.budget_version_id
and     gbal.task_id = gra.task_id
--and     gbal.resource_list_member_id = gra.resource_list_member_id
--and     gbal.start_date = gbl.start_date
and     gbv.award_id = p_award_id
and     gbv.project_id = p_project_id
and	gbl.start_date = p_start_date
and	gra.resource_list_member_id = p_resource_list_member_id
and	gra.task_id = p_task_id
and     gbv.budget_status_code = 'B'
and     gbv.current_flag ='Y'
and     gbal.balance_type in ('REQ', 'PO', 'AP', 'ENC', 'EXP');

l_txn_amount 	NUMBER;

begin
	open l_txns_csr (p_award_id => p_award_id,
			p_project_id => p_project_id,
			p_task_id => p_task_id,
			p_resource_list_member_id => p_resource_list_member_id,
			p_start_date => p_start_date);
	loop
		fetch l_txns_csr
		into l_txn_amount;
		exit when l_txns_csr%NOTFOUND;

		if p_draft_burdened_cost < l_txn_amount
		then
			p_fc_required := TRUE;
			return;
		else
			p_fc_required := FALSE;
		end if;

	end loop;

	close l_txns_csr;

end compare_amount_with_txns;

-------------------------------------------------------------------------------
-- This Function is used while Submitting and Baselining a Budget to see if
-- Funds checking (FC) is required for this Budget.

-- Conditions for FC requirement is:
-- 1. If Budget Entry Method has been changed in the new draft budget.
-- 2. If Resource List has been changed in the new draft budget.
-- 3. If Budgetted amount is decreased for a particular Resource
-- 4. If a new resource is added to the budget.

FUNCTION is_fc_required (p_project_id IN NUMBER,
                                           p_award_id IN NUMBER)
RETURN boolean IS

l_draft_entry_method varchar2(30);
l_draft_res_list_id number;
l_draft_res_assignment number;
l_draft_burdened_cost number;

l_baselined_entry_method varchar2(30);
l_baselined_res_list_id number;
l_baselined_res_assignment number;
l_project_id number;
l_task_id number;
l_res_list_member number;
l_baselined_burdened_cost number;

l_amount_diff number;
l_start_date date;
l_period_name varchar2(15);

l_fc_required boolean;
l_dummy number;

CURSOR l_budgetary_controls_csr(p_project_id IN NUMBER,
                              p_award_id IN NUMBER)
IS
select 	1
from 	dual
where exists(
	select 	'x'
	from 	gms_budgetary_controls
	where	project_id = p_project_id
	and	award_id = p_award_id
	and 	funds_control_level_code = 'B');


CURSOR l_budget_csr(p_project_id IN NUMBER,
                              p_award_id IN NUMBER)
IS
select
        draft_array.budget_entry_method_code,
        baselined_array.budget_entry_method_code,
        draft_array.resource_list_id,
        baselined_array.resource_list_id,
        draft_array.resource_list_member_id,
        draft_array.project_id,
        draft_array.task_id,
        draft_array.start_date,
        draft_array.period_name,
        baselined_array.burdened_cost,
        draft_array.burdened_cost,
        nvl(draft_array.burdened_cost,0) - nvl(baselined_array.burdened_cost,0) amt_diff
from
        (select gra_b.resource_list_member_id resource_list_member_id,
                gra_b.project_id project_id,
                gra_b.task_id task_id,
                gbl_b.burdened_cost burdened_cost,
                gbl_b.start_date start_date,
                gbl_b.period_name period_name,
                gbv_b.budget_entry_method_code budget_entry_method_code,
                gbv_b.resource_list_id resource_list_id
        from    gms_budget_versions gbv_b,
                gms_budget_lines gbl_b,
                gms_resource_assignments gra_b
        where   gbv_b.budget_version_id = gra_b.budget_version_id
        and     gra_b.resource_assignment_id = gbl_b.resource_assignment_id
        and     gbv_b.award_id = p_award_id
        and     gbv_b.project_id = p_project_id
        and     gbv_b.budget_status_code = 'B'
        and     gbv_b.current_flag ='Y'
) baselined_array,
        (select gra_d.resource_list_member_id resource_list_member_id,
                gra_d.project_id project_id,
                gra_d.task_id task_id,
                gbl_d.burdened_cost burdened_cost,
                gbl_d.start_date start_date,
                gbl_d.period_name period_name,
                gbv_d.budget_entry_method_code budget_entry_method_code,
                gbv_d.resource_list_id resource_list_id
        from    gms_budget_versions gbv_d,
                gms_budget_lines gbl_d,
                gms_resource_assignments gra_d
        where   gbv_d.budget_version_id = gra_d.budget_version_id
        and     gra_d.resource_assignment_id = gbl_d.resource_assignment_id
        and     gbv_d.award_id = p_award_id
        and     gbv_d.project_id = p_project_id
        and     gbv_d.budget_status_code in ('W','S')
) draft_array
where   baselined_array.project_id = draft_array.project_id(+)
and     baselined_array.resource_list_member_id = draft_array.resource_list_member_id (+)
and     baselined_array.task_id = draft_array.task_id(+)
and     baselined_array.start_date = draft_array.start_date(+);


BEGIN

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('*** Start of IS_FC_REQUIRED ***','C');
	END IF;

	open 	l_budgetary_controls_csr(p_project_id, p_award_id);
	fetch 	l_budgetary_controls_csr
	into	l_dummy;

	if l_budgetary_controls_csr%NOTFOUND
	then
		return FALSE;
	end if;

	close 	l_budgetary_controls_csr;

open l_budget_csr (p_project_id, p_award_id);
loop
        fetch   l_budget_csr
        into    l_draft_entry_method,
                l_baselined_entry_method,
                l_draft_res_list_id,
                l_baselined_res_list_id,
                l_res_list_member,
                l_project_id,
                l_task_id,
                l_start_date,
                l_period_name,
                l_baselined_burdened_cost,
                l_draft_burdened_cost,
                l_amount_diff;
                exit when l_budget_csr%NOTFOUND;

-- Check to see if Budget Entry Method has been changed in Draft Budget

                if nvl(l_draft_entry_method,'x') <> nvl(l_baselined_entry_method,'x')
                then
                        return TRUE; -- FC reqd.
                end if;
-- Check to see if Resource List has been changed in Draft Budget

                if nvl(l_draft_res_list_id,0) <> nvl(l_baselined_res_list_id,0)
                then
                        return TRUE; -- FC reqd.
                end if;

-- Check to see if Budget Amount has been changed in Draft Budget

		if nvl(l_draft_burdened_cost,0) <
		   nvl(l_baselined_burdened_cost,0) then
		   	return TRUE; -- FC reqd.
		end if;

-- Check to see if Budget line has been changed in Draft Budget
/** -- To be enabled later ....
                if ((l_amount_diff < 0) and (l_res_list_member is null)) then
                        return FALSE; -- FC not reqd.
		        close l_budget_csr;
                elsif (l_amount_diff < 0) and (l_res_list_member is not null) then
			compare_amount_with_txns( p_award_id => p_award_id,
						p_project_id => l_project_id,
						p_task_id => l_task_id,
						p_resource_list_member_id => l_res_list_member,
						p_start_date => l_start_date,
						p_draft_burdened_cost => l_draft_burdened_cost,
						p_fc_required => l_fc_required);

			if l_fc_required then
                        	return TRUE; -- FC reqd.
                        else
                        	return FALSE; -- FC not reqd.
                        end if;
		        close l_budget_csr;
                end if;

.......**/

end loop;

close l_budget_csr;
return FALSE;

END is_fc_required;
-------------------------------------------------------------------------------
 procedure summerize_project_totals (x_budget_version_id   in     number,
		    		      x_err_code            in out NOCOPY number,
		    		      x_err_stage	    in out NOCOPY varchar2,
		    		      x_err_stack           in out NOCOPY varchar2)
  is
     x_created_by number;
     x_last_update_login number;
     l_old_stack  varchar2(630);
  begin

     IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_PUB.SUMMERIZE_PROJECT_TOTALS ***','C');
     END IF;

     x_err_code := 0;
     l_old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->summerize_project_totals';

     x_created_by := FND_GLOBAL.USER_ID;
     x_last_update_login := FND_GLOBAL.LOGIN_ID;

     -- Get the project_totals
     x_err_stage := 'get project totals <' || to_char(x_budget_version_id)
		    || '>';

     update gms_budget_versions v
     set    (labor_quantity,
	     labor_unit_of_measure,
	     raw_cost,
	     burdened_cost,
	     last_update_date,
	     last_updated_by,
	     last_update_login
            )
     =
       (select sum(nvl(to_number(decode(a.track_as_labor_flag,
					'Y', l.quantity, NULL)),0)),
--             decode(a.track_as_labor_flag, 'Y', a.unit_of_measure, NULL),
	       'HOURS',       -- V4 uses HOURS as the only labor unit
	       pa_currency.round_currency_amt(sum(nvl(l.raw_cost, 0))),
	       pa_currency.round_currency_amt(sum(nvl(l.burdened_cost, 0))),
	       SYSDATE,
	       x_created_by,
	       x_last_update_login
	from   gms_resource_assignments a,
	       gms_budget_lines l
	where  a.budget_version_id = v.budget_version_id
	and    a.resource_assignment_id = l.resource_assignment_id
       )
     where  budget_version_id = x_budget_version_id;

     x_err_stack := l_old_stack;

     IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('*** End of GMS_BUDGET_PUB.SUMMERIZE_PROJECT_TOTALS ***','C');
     END IF;

  exception
      when others then
        -- Modified for bug 2587078
	--x_err_code := SQLCODE;
        x_err_stage := 'GMS_BUDGET_PUB.SUMMERIZE_PROJECT_TOTALS - In when others exception';
        gms_error_pkg.gms_message( x_err_name => 'GMS_BU_SUMM_BUDG_LINES_FAIL',
 	 		          x_err_code => x_err_code,
			          x_err_buff => x_err_stage);
       fnd_msg_pub.add;
       return;

  end summerize_project_totals;
----------------------------------------------------------------------------------------
procedure validate_budget(  x_budget_version_id in NUMBER,
			    x_award_id in NUMBER,
                            x_project_id in NUMBER,
                            x_task_id in NUMBER default NULL,
                            x_resource_list_member_id in NUMBER default NULL,
                            x_start_date in DATE,
                            x_end_date in DATE,
                            x_return_status in out NOCOPY NUMBER,
			    x_calling_form in VARCHAR2 default NULL)

is
TYPE Install_Rec is RECORD( INSTALLMENT_ID NUMBER,
                            TOTAL_FUNDING_AMOUNT NUMBER,
                            INSTALL_BALANCE NUMBER,
                            INSTALL_START_DATE DATE,
                            INSTALL_END_DATE DATE);

TYPE Install_tab is TABLE OF Install_Rec
                 INDEX BY BINARY_INTEGER;

X_Install_Total     Install_tab;

TYPE Budget_Rec is RECORD(  BUDG_PERIOD_START_DATE DATE,
                            BUDG_PERIOD_END_DATE DATE,
                            BUDGET_AMOUNT NUMBER);

TYPE Budget_tab is TABLE OF Budget_Rec
                 INDEX BY BINARY_INTEGER;

X_Budget_Total     Budget_tab;

x_funding_level  varchar2(1);
x_top_task_id    number;
x_budget_funding_level varchar2(1);
x_entry_level_code varchar2(1);
x_period_name varchar2(20);
x_resource_name pa_resource_list_members.alias%type;   /*Modified for bug 4614242*/
x_project_number varchar2(25); -- Added for Bug:2269791
x_period_type	varchar2(1);
x_categorization_code varchar2(30);

CURSOR  x_install_cursor (x_award_id in NUMBER,
                        x_project_id in NUMBER,
                        x_task_id in NUMBER default NULL,
                        x_start_date in DATE,
                        x_end_date in DATE)
IS
select  gi.installment_id,
        gspf.total_funding_amount total_funding_amount,
        trunc(gi.start_date_active) start_date_active,
        nvl(trunc(ga.preaward_date),trunc(gi.start_date_active)) start_date_active_preawd, -- for Bug: 1906414
        trunc(gi.end_date_active) end_date_active
from    gms_installments gi,
	gms_awards ga,
        gms_summary_project_fundings gspf
where   gi.installment_id = gspf.installment_id
and	ga.award_id = gi.award_id
and     gi.award_id = x_award_id
and     gspf.project_id = x_project_id
and     ( (x_budget_funding_level = 'T' and gspf.task_id = x_top_task_id)
         or x_budget_funding_level = 'P')
order by trunc(gi.end_date_active) , trunc(gi.start_date_active);

-- For Bug:2395386 - created 2 Budget cursors - one ordered by Amount and the other by Installment Dates
-- Bug Fix 2912108 Added NVL clause for the burdened_cost column in the following cursors, as it is
--                 resulting into an error, when amounts are saved in the budget form.

CURSOR  x_budget_cursor_by_date (  x_award_id in NUMBER,
                        x_project_id in NUMBER,
                        x_task_id in NUMBER default NULL,
                        x_start_date in DATE,
                        x_end_date in DATE)
IS
select  trunc(gbl.start_date) start_date,
        trunc(gbl.end_date) end_date,
        sum(NVL(gbl.burdened_cost,0)) burdened_cost,
        decode(sum(NVL(gbl.burdened_cost,0)), abs(sum(NVL(gbl.burdened_cost,0))), 1, 0) N
from    gms_budget_versions gbv,
        gms_resource_assignments gra,
        gms_budget_lines gbl
where   gbv.budget_version_id = gra.budget_version_id
and     gra.resource_assignment_id = gbl.resource_assignment_id
and     gbv.project_id = x_project_id
and     gbv.award_id = x_award_id
and     budget_status_code = 'W' -- since we are dealing with a draft budget ONLY
and     ( x_budget_funding_level = 'T'  and exists (select 1 from pa_tasks pat
                                            where  pat.top_task_id = x_top_task_id
                                            and    pat.task_id = gra.task_id)
         or x_budget_funding_level = 'P')
group by trunc(start_date), trunc(end_date)
order by 4,1,2 asc;   /* 6846582, also added decode(Column 'N') in select clause */



CURSOR  x_budget_cursor_by_amount (  x_award_id in NUMBER,
                        x_project_id in NUMBER,
                        x_task_id in NUMBER default NULL,
                        x_start_date in DATE,
                        x_end_date in DATE)
IS
select  trunc(gbl.start_date) start_date,
        trunc(gbl.end_date) end_date,
        sum(NVL(gbl.burdened_cost,0)) burdened_cost
from    gms_budget_versions gbv,
        gms_resource_assignments gra,
        gms_budget_lines gbl
where   gbv.budget_version_id = gra.budget_version_id
and     gra.resource_assignment_id = gbl.resource_assignment_id
and     gbv.project_id = x_project_id
and     gbv.award_id = x_award_id
and     budget_status_code = 'W' -- since we are dealing with a draft budget ONLY
and     ( x_budget_funding_level = 'T'  and exists (select 1 from pa_tasks pat
                                            where  pat.top_task_id = x_top_task_id
                                            and    pat.task_id = gra.task_id)
         or x_budget_funding_level = 'P')
group by trunc(start_date), trunc(end_date)
order by sum(gbl.burdened_cost) asc;

i   NUMBER;
j   NUMBER;
x_budget_rowcount   NUMBER;
x_install_rowcount  NUMBER;
x_install_balance   NUMBER;
x_carry_over_budget NUMBER;

x_override_validation VARCHAR2(1);

l_total_budget_amount NUMBER;
l_total_funding_amount NUMBER;

x_err_code  NUMBER;
x_err_stage VARCHAR2(630);

begin
    	x_return_status := 0;

	-- For Bug:2395386
	gms_client_extn_budget.override_inst_date_validation (p_award_id => x_award_id,
							      p_project_id => x_project_id,
							      p_override_validation => x_override_validation);

-- Added for fixing bug:1794776 -- ABLE TO BUDGET FOR MORE THAN FUNDED IF A NEGATIVE INSTALLMENT WAS APPLIED

-- Check if the total budget amount exceeds total funding amount.
-- If yes, then error out NOCOPY and do not proceed further.
-- Begin, exception and end blocks added for bug 3895592

       Begin
        select  nvl(burdened_cost,0)
        into    l_total_budget_amount
        from    gms_budget_versions
        where  -- budget_status_code in ('W','S') commented for the bug 6860267 and added below condition
                budget_version_id = x_budget_version_id
        and	award_id = x_award_id
        and     project_id = x_project_id;
       exception
          when no_data_found then
	    null;
       end;

        select  sum(nvl(total_funding_amount,0))
        into    l_total_funding_amount
        from    gms_summary_project_fundings gspf,
                gms_installments gi
        where   gspf.installment_id = gi.installment_id
        and     gi.award_id = x_award_id
        and     gspf.project_id = x_project_id;

        if l_total_budget_amount > l_total_funding_amount then
	        if (x_calling_form ='GMSAWEAW') then/*bug 4965360*/
                        x_return_status := 1 ;
                       return;
                 end if ;

	        gms_error_pkg.gms_message(x_err_name => 'GMS_BU_BUDGAMT_FAILURE',
 						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

		x_return_status := 1; -- validation FAILED
		app_exception.raise_exception;

        end if;

-- Initializing the pl/sql tables

    	X_Install_Total.delete;
    	X_Budget_Total.delete;

    	if nvl(x_task_id,0) = 0 then  /*bug 4965360 */
        	null;
    	else
        	select top_Task_id
        	into   x_top_task_id
        	from   pa_tasks
        	where task_id = x_task_id;
    	end if;

	select 	decode(entry_level_code, 'P','P','T')
    	into   	x_entry_level_code
    	from 	gms_budget_versions gbv,
         	pa_budget_entry_methods pbem
    	where 	gbv.budget_Version_id = x_budget_version_id
    	and   	pbem.budget_entry_method_code = gbv.budget_entry_method_code;

	select  decode (task_id, NULL, 'P','T')
    	into    x_funding_level
    	from    gms_installments gi,
		gms_summary_project_fundings gspf
    	where   gi.installment_id = gspf.installment_id
    	and     gi.award_id     = x_award_id
    	and     gspf.project_id = x_project_id
    	and     rownum = 1;

    	if x_entry_level_code = 'T' and x_funding_level = 'T' then
		x_budget_funding_level := 'T';
    	else
          	x_budget_funding_level := 'P';
    	end if;

	select 	alias
	into	x_resource_name
	from 	pa_resource_list_members
	where	resource_list_member_id = x_resource_List_Member_Id;

-- Added for Bug: 2269791
	select 	segment1
	into	x_project_number
	from 	pa_projects
	where	project_id = x_project_id;

	select 	time_phased_type_code, categorization_code
	into	x_period_type, x_categorization_code
	from 	pa_budget_entry_methods pbem,
		gms_budget_versions gbv
	where	gbv.budget_entry_method_code = pbem.budget_entry_method_code
	and	gbv.budget_version_id = x_budget_version_id;

-- Added the IF condition for Bug: 1422606
-- Bug 1555396 : x_start_date and x_end_date should be not null
	if x_period_type in ('G','P') AND x_start_date IS NOT NULL AND x_end_date IS NOT NULL then
		select 	period_name
		into 	x_period_name
		from 	pa_budget_periods_v
		where	period_start_date = x_start_date
		and	period_end_date = x_end_date
		and	period_type_code = x_period_type;
	end if;

------------------------------------------------------
-- Loading the Installment pl/sql table
    	i := 0;

    	for ins_rec in x_install_cursor (    x_award_id => x_award_id,
        	                                x_project_id => x_project_id,
                	                        x_task_id => x_task_id,
                        	                x_start_date => x_start_date,
                                	        x_end_date => x_end_date)
    	loop
        	X_Install_Total(i).INSTALLMENT_ID := ins_rec.installment_id;
        	X_Install_Total(i).TOTAL_FUNDING_AMOUNT := ins_rec.total_funding_amount;
        	X_Install_Total(i).INSTALL_BALANCE := ins_rec.total_funding_amount; -- to begin with, balance = total funding

		-- The following IF statement is added for Bug: 1906414
		if i = 0 then
			X_Install_Total(i).INSTALL_START_DATE := ins_rec.start_date_active_preawd;
        	else
			X_Install_Total(i).INSTALL_START_DATE := ins_rec.start_date_active;
		end if;

        	X_Install_Total(i).INSTALL_END_DATE := ins_rec.end_date_active;

        	i := i + 1;
    	end loop;
------------------------------------------------------
-- Loading the Budget pl/sql table

-- Bug:2395386 - the order of records in the Budget pl/sql table depends
--		 on the value of x_override_validation.

    	j := 0;

	if x_override_validation = 'Y' then

    		for budg_rec in x_budget_cursor_by_amount(    x_award_id => x_award_id,
        	                                x_project_id => x_project_id,
                	                        x_task_id => x_task_id,
                        	                x_start_date => x_start_date,
                                	        x_end_date => x_end_date)
    		loop
        		X_Budget_Total(j).BUDG_PERIOD_START_DATE := budg_rec.start_date;
        		X_Budget_Total(j).BUDG_PERIOD_END_DATE := budg_rec.end_date;
        		X_Budget_Total(j).BUDGET_AMOUNT := budg_rec.burdened_cost;

        		j := j + 1;
    		end loop;
	else
    		for budg_rec in x_budget_cursor_by_date(    x_award_id => x_award_id,
        	                                x_project_id => x_project_id,
                	                        x_task_id => x_task_id,
                        	                x_start_date => x_start_date,
                                	        x_end_date => x_end_date)
    		loop
        		X_Budget_Total(j).BUDG_PERIOD_START_DATE := budg_rec.start_date;
        		X_Budget_Total(j).BUDG_PERIOD_END_DATE := budg_rec.end_date;
        		X_Budget_Total(j).BUDGET_AMOUNT := budg_rec.burdened_cost;

        		j := j + 1;
    		end loop;

	end if;

----------------------------------------------------------------------------

-- Getting the number of records in the Budget and Installment pl/sql tables

    	x_budget_rowcount := X_Budget_Total.count;
    	x_install_rowcount := X_Install_Total.count;
----------------------------------------------------------------------------

    	for Budg_Rec_Count in 0..x_budget_rowcount-1
    	loop
		x_carry_over_budget := X_Budget_Total(Budg_Rec_Count).budget_amount;

        	for Inst_Rec_Count in 0..x_install_rowcount-1
        	loop

-- Bug:2395386 -- Added check to find the value of x_override_validation.

            		if  (x_override_validation = 'Y') or ((trunc(X_Install_Total(Inst_Rec_Count).install_start_date) <= trunc(X_Budget_Total(Budg_Rec_Count).budg_period_end_date))
                	and (trunc(X_Install_Total(Inst_Rec_Count).install_end_date) >= trunc(X_Budget_Total(Budg_Rec_Count).budg_period_start_date))) then

	                	if x_carry_over_budget <= X_Install_Total(Inst_Rec_Count).install_balance then
        	            		X_Install_Total(Inst_Rec_Count).install_balance := X_Install_Total(Inst_Rec_Count).install_balance - x_carry_over_budget;
                	    		x_carry_over_budget := 0;
                    			exit; -- exit installment loop
                		else
                    			x_carry_over_budget := x_carry_over_budget - X_Install_Total(Inst_Rec_Count).install_balance;
                    			X_Install_Total(Inst_Rec_Count).install_balance := 0;
                		end if;

             		end if;
        	end loop; -- for Installment loop

        -- At the end of the installment loop if the carry over is greater than 0 or if the balance in the
        -- installment plsql table is less than 0 then stop and error out.

		if x_carry_over_budget > 0 then
                      if (x_calling_form ='GMSAWEAW') then  /*bug 4965360*/
                             x_return_status := 1 ;
                             return;
                       end if ;
			if x_categorization_code = 'R' then
				if x_period_type = 'R' then -- for a Date Range Budget
					gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_VALIDATE_FAIL_RES_DR',
							x_token_name1 => 'X_START_DATE',
							x_token_val1 => x_start_date,
							x_token_name2 => 'X_END_DATE',
							x_token_val2 => x_end_date,
							x_token_name3 => 'X_RES_NAME',
							x_token_val3 => x_resource_name,
							x_token_name4 => 'X_OVERFLOW_AMT',
							x_token_val4 => to_char(x_carry_over_budget),
							x_token_name5 => 'X_PROJECT_NUM',
							x_token_val5 => x_project_number,
	 						x_err_code => x_err_code,
							x_err_buff => x_err_stage);
				elsif x_period_type = 'N' then -- for a No Time Phased budget
					gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_VALIDATE_FAIL_RES_NT',
							x_token_name1 => 'X_RES_NAME',
							x_token_val1 => x_resource_name,
							x_token_name2 => 'X_OVERFLOW_AMT',
							x_token_val2 => to_char(x_carry_over_budget),
                                                        x_token_name3 => 'X_PROJECT_NUM',
                                                        x_token_val3 => x_project_number,
	 						x_err_code => x_err_code,
							x_err_buff => x_err_stage);
				else -- for either GL or PA period
					gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_VALIDATE_FAIL_RES',
							x_token_name1 => 'X_PERIOD_NAME',
							x_token_val1 => x_period_name,
							x_token_name2 => 'X_RES_NAME',
							x_token_val2 => x_resource_name,
							x_token_name3 => 'X_OVERFLOW_AMT',
							x_token_val3 => to_char(x_carry_over_budget),
                                                        x_token_name4 => 'X_PROJECT_NUM',
                                                        x_token_val4 => x_project_number,
	 						x_err_code => x_err_code,
							x_err_buff => x_err_stage);

				end if;
			else
				if x_period_type = 'R' then -- for a Date Range Budget
					gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_VALID_FAIL_NO_RES_DR',
						x_token_name1 => 'X_START_DATE',
						x_token_val1 => x_start_date,
						x_token_name2 => 'X_END_DATE',
						x_token_val2 => x_end_date,
						x_token_name3 => 'X_OVERFLOW_AMT',
						x_token_val3 =>to_char(x_carry_over_budget),
                                                x_token_name4 => 'X_PROJECT_NUM',
                                                x_token_val4 => x_project_number,
 						x_err_code => x_err_code,
						x_err_buff => x_err_stage);
				elsif x_period_type = 'N' then -- for a No Time Phased budget
					gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_VALID_FAIL_NO_RES_NT',
						x_token_name1 => 'X_OVERFLOW_AMT',
						x_token_val1 =>to_char(x_carry_over_budget),
                                                x_token_name2 => 'X_PROJECT_NUM',
                                                x_token_val2 => x_project_number,
 						x_err_code => x_err_code,
						x_err_buff => x_err_stage);
				else -- for either GL or PA period
					gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_VALIDATE_FAIL_NO_RES',
						x_token_name1 => 'X_PERIOD_NAME',
						x_token_val1 => x_period_name,
						x_token_name2 => 'X_OVERFLOW_AMT',
						x_token_val2 =>to_char(x_carry_over_budget),
                                                x_token_name3 => 'X_PROJECT_NUM',
                                                x_token_val3 => x_project_number,
 						x_err_code => x_err_code,
						x_err_buff => x_err_stage);
				end if;
			end if;

            		x_return_status := 1; -- validation FAILED
			app_exception.raise_exception;
        	end if;

    	end loop;

end validate_budget;
----------------------------------------------------------------------------------------
 procedure validate_budget_mf(  x_budget_version_id in NUMBER,
			    x_award_id in NUMBER,
                            x_project_id in NUMBER,
                            x_task_id in NUMBER default NULL,
                            x_resource_list_member_id in NUMBER default NULL,
                            x_start_date in DATE,
                            x_end_date in DATE,
                            x_return_status in out NOCOPY NUMBER)
 is
  x_time_phased_type_code varchar2(30);
  x_err_code number;
  x_err_stage varchar2(630);

  cursor get_curr_date_range_csr (p_project_id in NUMBER
  				, p_award_id in NUMBER
  				, p_task_id in NUMBER
  				, p_resource_list_member_id in NUMBER)
  is
  select gbv.budget_version_id
  ,	 gbl.start_date
  ,	 gbl.end_date
  from   gms_budget_versions 		gbv
  ,	 gms_resource_assignments 	gra
  ,	 gms_budget_lines		gbl
  where  gbv.budget_version_id = gra.budget_version_id
  and	 gra.resource_assignment_id = gbl.resource_assignment_id
  and	 gbv.project_id = p_project_id
  and	 gbv.award_id = p_award_id
  and    gra.task_id = p_task_id
  and    gra.resource_list_member_id = p_resource_list_member_id
  and     gbv.current_flag = 'Y';/* bug 6444258*/

  cursor get_other_date_range_csr ( p_project_id in NUMBER
  				, p_award_id in NUMBER
  				, p_task_id in NUMBER
  				, p_resource_list_member_id in NUMBER)
  is
  select gbv.budget_version_id
  ,	 gbl.start_date
  ,	 gbl.end_date
  from   gms_budget_versions 		gbv
  ,	 gms_resource_assignments 	gra
  ,	 gms_budget_lines		gbl
  where  gbv.budget_version_id = gra.budget_version_id
  and	 gra.resource_assignment_id = gbl.resource_assignment_id
  and	 gbv.project_id = p_project_id
  and	 gbv.award_id <> p_award_id
  and    gra.task_id = p_task_id
  and    gra.resource_list_member_id = p_resource_list_member_id
  and 	 gbv.current_flag = 'Y';

  cursor time_phased_type_csr ( p_budget_version_id in NUMBER)
  is
  select 	time_phased_type_code
  from 		gms_budget_versions gbv,
  		pa_budget_entry_methods pbem
  where 	gbv.budget_entry_method_code = pbem.budget_entry_method_code
  and		gbv.budget_version_id = p_budget_version_id;



  begin

	x_return_status := 0; -- Initializing x_return_status

  	open time_phased_type_csr (p_budget_version_id => x_budget_version_id);

  	fetch time_phased_type_csr into x_time_phased_type_code;
  	close time_phased_type_csr;

	if x_time_phased_type_code = 'R' then

		FOR other_date_range_rec IN get_other_date_range_csr (p_project_id => x_project_id
  									, p_award_id => x_award_id
  									, p_task_id => x_task_id
  									, p_resource_list_member_id => x_resource_list_member_id)
		LOOP
        	exit when get_other_date_range_csr%NOTFOUND;

        		FOR curr_date_range_rec IN get_curr_date_range_csr (p_project_id => x_project_id
  										, p_award_id => x_award_id
  										, p_task_id => x_task_id
  										, p_resource_list_member_id => x_resource_list_member_id)
			LOOP
				exit when get_curr_date_range_csr%NOTFOUND;

			        if (curr_date_range_rec.start_date < other_date_range_rec.start_date and curr_date_range_rec.end_date < other_date_range_rec.start_date) OR
        			   (curr_date_range_rec.start_date > other_date_range_rec.end_date and curr_date_range_rec.end_date > other_date_range_rec.end_date)OR
				   (curr_date_range_rec.start_date = other_date_range_rec.start_date and curr_date_range_rec.end_date = other_date_range_rec.end_date) then
          				null;
		        	else
					gms_error_pkg.gms_message(x_err_name => 'GMS_BU_DATE_OVERLAP',
								x_err_code => x_err_code,
								x_err_buff => x_err_stage);

					x_return_status := 1; -- validation failed
					app_exception.raise_exception;
		        	end if;

		        END LOOP;
      		END LOOP;

	end if;
  exception
	when NO_DATA_FOUND then
	NULL;

	when OTHERS then
	fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
	fnd_message.set_token('SQLCODE', sqlcode);
	fnd_message.set_token('SQLERRM', sqlerrm);
	raise;

  end validate_budget_mf;
-----------------------------------------------------------------------------------------
--Bug 2830539
PROCEDURE validate_bem_resource_list (p_project_id IN NUMBER,
				 p_award_id   IN NUMBER,
				 p_budget_entry_method_code IN VARCHAR2,
				 p_resource_list_id IN NUMBER)
IS

l_dummy NUMBER:=0;
l_categorization_code VARCHAR2(1);
l_uncategorized_flag  VARCHAR2(1);
l_resource_list_id    NUMBER;
l_budget_entry_method_code1 VARCHAR2(30);
l_budget_entry_method_code VARCHAR2(30);

x_err_code NUMBER;
x_err_stage VARCHAR2(630);


cursor multifunding_csr(p_project_id IN NUMBER,
			p_award_id   IN NUMBER)
IS
  select  budget_version_id,budget_entry_method_code
  from    gms_budget_versions
  where   project_id = p_project_id
  and     award_id <> p_award_id
  and     budget_status_code = 'B'
  and 	  current_flag = 'Y';

cursor entry_method_csr (p_project_id IN NUMBER,
		       p_award_id   IN NUMBER)
IS
  select budget_entry_method_code
  from 	 gms_budget_versions
  where	 project_id = p_project_id
  and 	 award_id = p_award_id
  and 	 budget_status_code in ('W','S');

cursor entry_method_detail_csr(p_budget_entry_method_code IN VARCHAR2)
IS
  select  categorization_code
  from 	  pa_budget_entry_methods
  where   budget_entry_method_code = p_budget_entry_method_code;

cursor resource_list_csr (p_project_id IN NUMBER,
			  p_award_id   IN NUMBER)
IS
  select resource_list_id
  from 	 gms_budget_versions
  where  project_id = p_project_id
  and 	 award_id = p_award_id
  and 	 budget_status_code in ('W','S');

cursor resource_list_detail_csr(p_resource_list_id IN NUMBER)
IS
  select  uncategorized_flag
  from    pa_resource_lists prl,
          pa_implementations pi
  where   prl.business_group_id = pi.business_group_id
  and     prl.resource_list_id = p_resource_list_id;

cursor baselined_budg_csr (p_project_id IN NUMBER,
		           p_award_id   IN NUMBER)
IS
  select  budget_version_id
  from 	  gms_budget_versions
  where	  budget_status_code = 'B'
  and	  project_id = p_project_id
  and	  award_id = p_award_id;

BEGIN

----------------------------------------------------------------------------
-- For multi-funding scenarios, update to Budget Entry Method should not
-- be allowed.
	open multifunding_csr(p_project_id => p_project_id,
			      p_award_id => p_award_id);
	fetch multifunding_csr into l_dummy,l_budget_entry_method_code1;
	close multifunding_csr;

		open entry_method_csr(p_project_id => p_project_id,
					     p_award_id => p_award_id);

		fetch entry_method_csr into l_budget_entry_method_code;
		close entry_method_csr;

	if l_dummy > 0 and   l_budget_entry_method_code1 <> p_budget_entry_method_code then

       -- Midified for GMS enhancement 5583170 as we are allowing user to enter different BEM
       -- in Award budget form.
            NULL ;
      /*
	        gms_error_pkg.gms_message(x_err_name => 'GMS_CANT_CHANGE_BEM',
       		                          x_err_code => x_err_code,
					  x_err_buff => x_err_stage);

	        APP_EXCEPTION.RAISE_EXCEPTION;
       */
	end if;

----------------------------------------------------------------------------
-- Everytime the Budget Entry Method or Resource List is changed they should be
-- validated against each other.

	if p_budget_entry_method_code = GMS_BUDGET_PUB.G_MISS_CHAR then

		open entry_method_csr(p_project_id => p_project_id,
					     p_award_id => p_award_id);

		fetch entry_method_csr into l_budget_entry_method_code;
		close entry_method_csr;
	else
		l_budget_entry_method_code := p_budget_entry_method_code;

	end if;

	if p_resource_list_id = GMS_BUDGET_PUB.G_MISS_NUM then

		open resource_list_csr (p_project_id => p_project_id,
					       p_award_id => p_award_id);

		fetch resource_list_csr into l_resource_list_id;
		close resource_list_csr;
	else
		l_resource_list_id := p_resource_list_id;

	end if;

	open entry_method_detail_csr(p_budget_entry_method_code => l_budget_entry_method_code);
	fetch entry_method_detail_csr into l_categorization_code;
	close entry_method_detail_csr;

	open resource_list_detail_csr (p_resource_list_id => l_resource_list_id);
	fetch resource_list_detail_csr into l_uncategorized_flag;
	close resource_list_detail_csr;

	if ((l_categorization_code = 'N' and l_uncategorized_flag <> 'Y') or
	   (l_categorization_code = 'R' and l_uncategorized_flag = 'Y')) then

                gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_BEM_RESOURCE_LIST',
                                          x_err_code => x_err_code,
                                          x_err_buff => x_err_stage);

                APP_EXCEPTION.RAISE_EXCEPTION;

	end if;

end validate_bem_resource_list;
----------------------------------------------------------------------------------------

--Name:               create_draft_budget
--Type:               Procedure
--Description:        This procedure can be used to create a draft budget.
--
--
--Called subprograms:
--			gms_budget_utils.check_overlapping_dates
--
--
--History:
--

PROCEDURE create_draft_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
, p_budget_version_name         IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_first_budget_period         IN      VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR -- Bug 3104308
)
IS

   CURSOR	l_budget_entry_method_csr
   		(p_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
   IS
   SELECT *
   FROM   pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code
   AND 	  trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));


   CURSOR	l_budget_amount_code_csr
   		( p_budget_type_code	VARCHAR2 )
   IS
   SELECT budget_amount_code
   FROM	  pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;


   CURSOR	l_budget_change_reason_csr ( p_change_reason_code VARCHAR2 )
   IS
   SELECT 'x'
   FROM   pa_lookups
   WHERE  lookup_type = 'BUDGET CHANGE REASON'
   AND    lookup_code = p_change_reason_code;

   CURSOR l_budget_version_csr
   	 ( p_project_id NUMBER
   	 , p_award_id NUMBER
   	 , p_budget_type_code VARCHAR2	)
   IS
   SELECT budget_version_id
   ,      budget_status_code
   FROM gms_budget_versions
   WHERE project_id = p_project_id
   AND   award_id = p_award_id
   AND   budget_type_code = p_budget_type_code
   AND   budget_status_code IN ('W','S');

   CURSOR l_lock_old_budget_csr( p_budget_version_id NUMBER )
   IS
   SELECT 'x'
   FROM   gms_budget_versions bv
   ,      gms_resource_assignments ra
   ,      gms_budget_lines bl
   WHERE  bv.budget_version_id = p_budget_version_id
   AND    bv.budget_version_id = ra.budget_version_id (+)
   AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
   FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;

   -- Bug 3104308 :

   CURSOR	l_budget_periods_csr
   		(p_period_name 		VARCHAR2
   		,p_period_type_code	VARCHAR2	)
   IS
   SELECT period_name
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND 	  period_type_code = p_period_type_code;


   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'create_draft_budget';

   l_project_id					NUMBER;
   l_award_id					NUMBER;
   l_resource_list_id				NUMBER;
   l_old_budget_version_id			NUMBER;
   i						NUMBER;

   l_budget_entry_method_rec			pa_budget_entry_methods%rowtype;
   l_budget_amount_code				pa_budget_types.budget_amount_code%type;
   l_description				VARCHAR2(255);
   l_dummy					VARCHAR2(1);
   l_attribute_category				VARCHAR2(30);
   l_attribute1					VARCHAR2(150);
   l_attribute2					VARCHAR2(150);
   l_attribute3					VARCHAR2(150);
   l_attribute4					VARCHAR2(150);
   l_attribute5					VARCHAR2(150);
   l_attribute6					VARCHAR2(150);
   l_attribute7					VARCHAR2(150);
   l_attribute8					VARCHAR2(150);
   l_attribute9					VARCHAR2(150);
   l_attribute10				VARCHAR2(150);
   l_attribute11				VARCHAR2(150);
   l_attribute12				VARCHAR2(150);
   l_attribute13				VARCHAR2(150);
   l_attribute14				VARCHAR2(150);
   l_attribute15				VARCHAR2(150);
   l_budget_status_code				VARCHAR2(30);
   l_old_stack					VARCHAR2(630);
   l_function_allowed				VARCHAR2(1);
   l_resp_id					NUMBER := 0;
   l_user_id		                        NUMBER := 0;
   l_login_id					NUMBER := 0;
   l_module_name                                VARCHAR2(80);
   l_pm_budget_reference			VARCHAR2(30);
   l_budget_version_name 			VARCHAR2(60);
   l_uncategorized_list_id			NUMBER;
   l_uncategorized_rlmid                        NUMBER;
   l_uncategorized_resid                        NUMBER;
   l_track_as_labor_flag                        VARCHAR2(1);
   l_baselined_version_id 			NUMBER;
   l_baselined_resource_list_id 		NUMBER;
   l_baselined_exists				BOOLEAN;
   l_old_draft_version_id    			NUMBER;
   l_first_budget_period			VARCHAR2(30);  -- Bug 3104308

-- p_multiple_task_msg  VARCHAR2(1) := 'T';

BEGIN  -- create_draft_budget

	x_err_code := 0;
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> create_draft_budget';

    --	Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;


--  Standard begin of API savepoint

    SAVEPOINT create_draft_budget_pub;


--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN

	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;


    -- product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
    THEN

   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
		return;
	END IF;
    ELSE

	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

   END IF;
--------------------------------------------------------------------------------

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_login_id := FND_GLOBAL.Login_id;

    l_module_name := 'GMS_PM_CREATE_DRAFT_BUDGET';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- If a user does not have privileges to update the award, then
    -- cannot create a budget
    -- need to call the gms_security package

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


--------------------------------------------------------------------------------
-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			return;
    		END IF;

	ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_NUM_ID_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
-------------------------------------------------------------------------------

      -- Now verify whether award security allows the user to update
      -- the award
      -- If a user does not have privileges to update the award, then
      -- cannot create a budget

--  dbms_output.put_line('Before award security');

      IF gms_security.allow_query (x_award_id => l_award_id ) = 'N' THEN

         -- The user does not have query privileges on this award
         -- Hence, cannot create a draft budget.Raise error

		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_QRY',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF gms_security.allow_update (x_award_id => l_award_id ) = 'N' THEN

            -- The user does not have update privileges on this award
            -- Hence , raise error

		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_UPD',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

        END IF;
     END IF;


 -- budget type code is mandatory

     IF p_budget_type_code IS NULL
     OR p_budget_type_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN

	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE
     		OPEN l_budget_amount_code_csr( p_budget_type_code );

		FETCH l_budget_amount_code_csr
		INTO l_budget_amount_code;     		--will be used later on during validation of Budget lines.

		IF l_budget_amount_code_csr%NOTFOUND
		THEN
			CLOSE l_budget_amount_code_csr;
			gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_INVALID',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		CLOSE l_budget_amount_code_csr;

     END IF;

 -- entry method code is mandatory

     IF p_entry_method_code IS NULL
     OR p_entry_method_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_ENTRY_METHOD_IS_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

 -- check validity of this budget entry method code, and store associated fields in record


    OPEN l_budget_entry_method_csr(p_entry_method_code);
    FETCH l_budget_entry_method_csr INTO l_budget_entry_method_rec;

    IF   l_budget_entry_method_csr%NOTFOUND
    THEN

	CLOSE l_budget_entry_method_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_ENTRY_METHOD_IS_INVALID',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    CLOSE l_budget_entry_method_csr;

    IF l_budget_entry_method_rec.categorization_code = 'N' THEN

       pa_get_resource.Get_Uncateg_Resource_Info
                        (p_resource_list_id          => l_uncategorized_list_id,
                         p_resource_list_member_id   => l_uncategorized_rlmid,
                         p_resource_id               => l_uncategorized_resid,
                         p_track_as_labor_flag       => l_track_as_labor_flag,
                         p_err_code                  => x_err_code,
                         p_err_stage                 => x_err_stage,
                         p_err_stack                 => x_err_stack );
       IF x_err_code <> 0 THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_NO_UNCATEGORIZED_LIST',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

       l_resource_list_id := l_uncategorized_list_id;

    ELSIF l_budget_entry_method_rec.categorization_code = 'R' THEN

------------------------------------------------------------------------------
-- If resource_list_id is passed in then use it otherwise use the resource_list
-- name (NAME) that is passed in to fetch value of resource_list_id from
-- pa_resource_lists table. If both are missing then raise an error.

	IF (p_resource_list_name <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        	AND p_resource_list_name IS NOT NULL)
    	OR (p_resource_list_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        	AND p_resource_list_id IS NOT NULL)
        THEN
   		convert_reslistname_to_id(p_resource_list_name_in => p_resource_list_name
   				      ,p_resource_list_id_in => p_resource_list_id
   				      ,p_resource_list_id_out => l_resource_list_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_RESOURCE_LIST_NAME',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
    		END IF;

   	ELSE
			gms_error_pkg.gms_message(x_err_name => 'GMS_RESLIST_ID_NAME_MISSING',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
------------------------------------------------------------------------------
/*
         IF (p_resource_list_name <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
             AND p_resource_list_name IS NOT NULL)
         OR (p_resource_list_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
            AND p_resource_list_id IS NOT NULL) THEN

        -- convert resource_list_name to resource_list_id

     	        pa_resource_pub.Convert_List_name_to_id
     		(p_resource_list_name    =>  p_resource_list_name,
         	 p_resource_list_id      =>  p_resource_list_id,
         	 p_out_resource_list_id  =>  l_resource_list_id,
         	 p_return_status         =>  l_return_status );

     	        IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
         	   p_return_status := l_return_status;
         	   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     	        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         	   p_return_status             := l_return_status;
         	   RAISE  FND_API.G_EXC_ERROR;
     	        END IF;

         ELSE -- There is no valid resource list id
	     fnd_message.set_name('GMS', 'GMS_RESOURCE_LIST_IS_MISSING');
     	     RAISE FND_API.G_EXC_ERROR;

         END IF;
*/

    END IF ; -- If l_budget_entry_method_rec.categorization_code = 'N


     -- check validity of the budget change reason code, passing NULL is OK

     IF (p_change_reason_code IS NOT NULL AND
         p_change_reason_code  <> GMS_BUDGET_PUB.G_PA_MISS_CHAR) THEN
     	OPEN l_budget_change_reason_csr( p_change_reason_code );
     	FETCH l_budget_change_reason_csr INTO l_dummy;

     	IF l_budget_change_reason_csr%NOTFOUND THEN

     		CLOSE l_budget_change_reason_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_CHANGE_REASON_INVALID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

     	END IF;

	CLOSE l_budget_change_reason_csr;

     END IF;

     --When description is not passed, set value to NULL

     IF p_description = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_description := NULL;
     ELSE
	l_description := p_description;
     END IF;

--  dbms_output.put_line('Before setting flex fields to NULL, when not passed');

     --When descriptive flex fields are not passed set them to NULL
     IF p_attribute_category = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute_category := NULL;
     ELSE
	l_attribute_category := p_attribute_category;
     END IF;
     IF p_attribute1 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute1 := NULL;
     ELSE
	l_attribute1 := p_attribute1;
     END IF;
     IF p_attribute2 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute2 := NULL;
     ELSE
	l_attribute2 := p_attribute2;
     END IF;
     IF p_attribute3 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute3 := NULL;
     ELSE
	l_attribute3 := p_attribute3;
     END IF;
     IF p_attribute4 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute4 := NULL;
     ELSE
	l_attribute4 := p_attribute4;
     END IF;

     IF p_attribute5 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute5 := NULL;
     ELSE
	l_attribute5 := p_attribute5;
     END IF;

     IF p_attribute6 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute6 := NULL;
     ELSE
	l_attribute6 := p_attribute6;
     END IF;

     IF p_attribute7 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute7 := NULL;
     ELSE
	l_attribute7 := p_attribute7;
     END IF;

     IF p_attribute8 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute8 := NULL;
     ELSE
	l_attribute8 := p_attribute8;
     END IF;
     IF p_attribute9 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute9 := NULL;
     ELSE
	l_attribute9 := p_attribute9;
     END IF;
     IF p_attribute10 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute10 := NULL;
     ELSE
	l_attribute10 := p_attribute10;
     END IF;
     IF p_attribute11 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute11 := NULL;
     ELSE
	l_attribute11 := p_attribute11;
     END IF;
     IF p_attribute12 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute12 := NULL;
     ELSE
	l_attribute12 := p_attribute12;
     END IF;
     IF p_attribute13 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute13 := NULL;
     ELSE
	l_attribute13 := p_attribute13;
     END IF;
     IF p_attribute14 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute14:= NULL;
     ELSE
	l_attribute14:= p_attribute14;
     END IF;

     IF p_attribute15 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute15 := NULL;
     ELSE
	l_attribute15 := p_attribute15;
     END IF;

     -- Get the ID of the old draft budget and then
     -- Lock the old draft budget and it budget lines (if it exists)
     --,because it will be deleted by create_draft.

    OPEN l_budget_version_csr( l_project_id, l_award_id, p_budget_type_code );
    FETCH l_budget_version_csr INTO l_old_budget_version_id, l_budget_status_code;
    CLOSE l_budget_version_csr;

    --if working bugdet is submitted no new working budget can be created

    IF l_budget_status_code = 'S'
    THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_IS_SUBMITTED',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF p_pm_budget_reference =  GMS_BUDGET_PUB.G_PA_MISS_CHAR
    THEN
       l_pm_budget_reference := NULL;
    ELSE
       l_pm_budget_reference := p_pm_budget_reference;
    END IF;

    IF p_budget_version_name =  GMS_BUDGET_PUB.G_PA_MISS_CHAR
    THEN
       l_budget_version_name := NULL;
    ELSE
       l_budget_version_name := p_budget_version_name;
    END IF;

    -- Bug 3104308 : Validation for p_first_budget_period .This will be fired only for
    --               GL/PA budget periods.

    IF p_first_budget_period =  GMS_BUDGET_PUB.G_PA_MISS_CHAR  THEN -- Bug 3104308
       l_first_budget_period := NULL;
    ELSIF (p_first_budget_period IS NOT NULL AND l_budget_entry_method_rec.time_phased_type_code IN ('G','P')) THEN

       OPEN  l_budget_periods_csr(p_first_budget_period,l_budget_entry_method_rec.time_phased_type_code);
       FETCH l_budget_periods_csr into l_first_budget_period;
       IF   l_budget_periods_csr%NOTFOUND THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_PERIOD_IS_INVALID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;
    	CLOSE l_budget_periods_csr;
    END IF;


    OPEN l_lock_old_budget_csr( l_old_budget_version_id );
    CLOSE l_lock_old_budget_csr; 				--FYI, does not release locks

-- Creating a draft budget ....

     gms_budget_utils.get_baselined_version_id(l_project_id,
                                         l_award_id,
					 p_budget_type_code,
					 l_baselined_version_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack
					);


     if (x_err_code > 0) then

	-- baseline version does not exist
        l_baselined_exists := FALSE;
	x_err_code := 0;

     elsif (x_err_code = 0) then
        -- baseliend budget exists, verify if resource lists are the same
        -- resource list used in accumulation

	select resource_list_id
	into   l_baselined_resource_list_id
        from   gms_budget_versions
        where  budget_version_id = l_baselined_version_id;

        if (l_resource_list_id <> l_baselined_resource_list_id) then
		gms_error_pkg.gms_message(x_err_name => 'GMS_BU_BASE_RES_LIST_EXISTS',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
        end if;

        l_baselined_exists := TRUE;

     else
        -- x_err_code < 0
	return;
     end if;

     gms_budget_utils.get_draft_version_id(l_project_id,
                                         l_award_id,
					 p_budget_type_code,
					 l_old_draft_version_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack
					);

     -- if draft exist, delete it
     if (x_err_code = 0) then

	gms_budget_pub.delete_draft_budget
	( p_api_version_number => 1.0
	 ,p_pm_product_code => 'GMS'
	 ,p_project_id => l_project_id
	 ,p_award_id => l_award_id
	 ,p_budget_type_code => p_budget_type_code
	 ,x_err_code => x_err_code
	 ,x_err_stage => x_err_stage  --x_err_stage => x_err_code -- bug fix : 3004115
	 ,x_err_stack => x_err_stack);

	if x_err_code <> 0 -- this err code is from delete_draft_budget
	then
		gms_error_pkg.gms_message(x_err_name => 'GMS_DELETE_DRAFT_FAIL',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	end if;

     elsif (x_err_code > 0) then
	-- reset x_err_code
	x_err_code := 0;

     else
     -- if oracle error, return
	return;
     end if;

     insert into gms_budget_versions(
            budget_version_id,
            project_id,
            award_id,
            budget_type_code,
            version_number,
            budget_status_code,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            current_flag,
            original_flag,
            current_original_flag,
            resource_accumulated_flag,
            resource_list_id,
            version_name,
            budget_entry_method_code,
            baselined_by_person_id,
            baselined_date,
            change_reason_code,
            labor_quantity,
            labor_unit_of_measure,
            raw_cost,
            burdened_cost,
            description,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
	    pm_product_code,
	    pm_budget_reference,
		wf_status_code,
	    first_budget_period ) -- Bug 3104308
         select
            gms_budget_versions_s.nextval,
            l_project_id,
            l_award_id,
            p_budget_type_code,
            1,
            'W',
            SYSDATE,
	    l_user_id,
            SYSDATE,
	    l_user_id,
	    l_login_id,
            'N',
            'N',
            'N',
            'N',
            l_resource_list_id,
            l_budget_version_name,
            p_entry_method_code,
            NULL,
            NULL,
            p_change_reason_code,
            NULL,
            NULL,
            NULL,
            NULL,
            l_description,
            l_attribute_category,
            l_attribute1,
            l_attribute2,
            l_attribute3,
            l_attribute4,
            l_attribute5,
            l_attribute6,
            l_attribute7,
            l_attribute8,
            l_attribute9,
            l_attribute10,
            l_attribute11,
            l_attribute12,
            l_attribute13,
            l_attribute14,
            l_attribute15,
	    p_pm_product_code,
	    p_pm_budget_reference,
	    NULL,
	    l_first_budget_period -- Bug 3104308
	from sys.dual;

----------------------------------------------------------------------------------------------

-- temporary solution
-- COMMIT in DELETE_DRAFT removes all savepoints!!!

    SAVEPOINT create_draft_budget_pub;

  IF FND_API.TO_BOOLEAN( p_commit )
  THEN
	COMMIT;
  END IF;

  x_err_stack := l_old_stack;

EXCEPTION

	WHEN OTHERS
	THEN
		ROLLBACK TO create_draft_budget_pub;
		RAISE;

END create_draft_budget;
----------------------------------------------------------------------------------------
-- Name:               	Submit_Budg_Conc_Process
-- Type:               	Procedure
-- Description:
--
--
--
--
-- Called subprograms: 	fnd_request.submit_request()
--
--
--
--
-- History:
--

PROCEDURE submit_budg_conc_process
( p_reqid			OUT NOCOPY	NUMBER,
  p_project_id			IN	NUMBER,
  p_award_id			IN	NUMBER,
  p_mark_as_original		IN	VARCHAR
)
IS
l_award_number   gms_awards_all.award_number%type ; /*bug 3651888*/
l_org_id         gms_awards_all.org_id%type ; /*bug 4864049 */
begin
/* Bug 3651888 */
        Select award_number ,org_id
         into  l_award_number ,l_org_id
        from   gms_awards_all
        where  award_id = p_award_id;

        --Bug 486404: Shared Service Enhancement :Set the ORG_ID context before invoking Concurrent programs
        FND_REQUEST.SET_ORG_ID(l_org_id);


	p_reqid := fnd_request.submit_request(	'GMS',
						'GMSBUDSB',
						 NULL,NULL,NULL,
						p_project_id,
						l_award_number,  /* Bug3651888 */
						p_mark_as_original);

-- Bug 	3037125 :Introduced the commit
IF NVL(p_reqid,0) <> 0 THEN
    COMMIT;
END IF;

end;
----------------------------------------------------------------------------------------
-- Name:               	Submit_Baseline_Budget
-- Type:               	Procedure
-- Description:        	This procedure is a wrapper for the baseline_budget
--			and this is used as a concurrent process. It will be called
--			by the Award Budgets form (GMSBUEBU)
--
--
-- Called subprograms: 	gms_budget_pub.baseline_budget
--
--
--
--
-- History:
--

PROCEDURE submit_baseline_budget
( ERRBUFF			IN OUT NOCOPY	VARCHAR2
 ,RETCODE			IN OUT NOCOPY  VARCHAR2
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2  /*bug 3651888			:= GMS_BUDGET_PUB.G_PA_MISS_NUM*/
 ,p_mark_as_original		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR)

IS

  l_err_code		number;
  l_err_stage		varchar2(630); -- Bug 2587078
  l_err_stack		varchar2(630);
  l_award_id            number ;
  l_workflow_started	varchar2(1);

begin

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_PUB.SUBMIT_BASELINE_BUDGET ***','C');
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.SUBMIT_BASELINE_BUDGET - Calling gms_budget_pub.baseline_budget','C');
	END IF;

/* Bug 3651888 */
        Select award_id
         into  l_award_id
        from   gms_awards_all
        where  award_number = p_award_number;

	gms_budget_pub.baseline_budget(	p_api_version_number => 1.0,
					x_err_code => l_err_code,
					x_err_stage => l_err_stage,
					x_err_stack => l_err_stack,
					p_commit => 'T',
					p_init_msg_list => 'T',
					p_workflow_started => l_workflow_started,
					p_pm_product_code => 'GMS',
					p_project_id => p_project_id,
					p_award_id => l_award_Id,
					p_budget_type_code => 'AC',
					p_mark_as_original => p_mark_as_original);

	IF L_DEBUG = 'Y' THEN
   	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.SUBMIT_BASELINE_BUDGET - Call to gms_budget_pub.baseline_budget returned l_err_code : '||l_err_code,'C');
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.SUBMIT_BASELINE_BUDGET - Call to gms_budget_pub.baseline_budget returned l_err_stage : '||l_err_stage,'C');
	END IF;

	-- Bug 3022766  : Introduced error code = 3 to represent fundscheck failure status.
	-- Baseline_budget procedure returns following statuses
	-- x_err_code =0 represents success
	-- x_err_code =1 represents unexpected error
	-- x_err_code =2 represents expected error
	-- x_err_code =3 represents Fundscheck failure
	-- x_err_code =4 represents warning

	if l_err_code = 0 or  l_err_code = 3 -- Bug 3022766
	then
		RETCODE := 0;
		ERRBUFF := l_err_stage;

	elsif l_err_code = 4 then

		RETCODE := 1;
		ERRBUFF := l_err_stage;

	else

		RETCODE := 2;
		ERRBUFF := l_err_stage;

	end if;

	IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('*** End of GMS_BUDGET_PUB.SUBMIT_BASELINE_BUDGET ***','C');
	END IF;

exception
when OTHERS then
	RETCODE := 2;
	ERRBUFF := SQLCODE ||'-'||SQLERRM;
	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.SUBMIT_BASELINE_BUDGET - Exception :'||ERRBUFF,'C');
	END IF;

end;

----------------------------------------------------------------------------------------

--Name:               Baseline_Budget
--Type:               Procedure
--Description:        This procedure can be used to baseline
--		      a budget for a given project.
--
--
--Called subprograms: gms_budget_core.verify
--		      gms_budget_core.baseline
--
--
--
--History:
--

PROCEDURE baseline_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_workflow_started		OUT NOCOPY	VARCHAR2
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_mark_as_original		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	)

IS

    CURSOR	l_budget_types_csr
    		( p_budget_type_code	VARCHAR2 )
    IS
      SELECT 1
      FROM   pa_budget_types
      WHERE  budget_type_code = p_budget_type_code;

    CURSOR l_resource_assignments_csr
    		( p_budget_version_id NUMBER )
    IS
      SELECT 1
      FROM gms_resource_assignments
      WHERE budget_version_id = p_budget_version_id;

    CURSOR l_budget_versions_csr
    		( p_project_id NUMBER
    		, p_award_id NUMBER
    		, p_budget_type_code VARCHAR2 )

    IS
      SELECT budget_version_id, budget_status_code
      FROM   gms_budget_versions
      WHERE project_id 		= p_project_id
      AND   award_id            = p_award_id
      AND   budget_type_code 	= p_budget_type_code
      AND   budget_status_code 	in ('W','S');



    CURSOR l_baselined_csr
    		( p_project_id NUMBER
    		, p_award_id NUMBER
    		, p_budget_type_code VARCHAR2 )

    IS
      SELECT 1
      FROM   gms_budget_versions
      WHERE project_id 		= p_project_id
      AND   award_id            = p_award_id
      AND   budget_type_code 	= p_budget_type_code
      AND   budget_status_code 	= 'B';


-- Cursor for Verify_Budget_Rules
/** Modified so that we get group_resource_type_id which is used
--  by GMS_BUDG_CONT_SETUP()

    CURSOR	l_budget_rules_csr(p_draft_version_id NUMBER)
    IS
    SELECT 	v.resource_list_id,
	    	t.project_type_class_code
    FROM   	pa_project_types t,
	    	pa_projects p,
	    	gms_budget_versions v
    WHERE  	v.budget_version_id = p_draft_version_id
    AND		v.project_id = p.project_id
    AND 	p.project_type = t.project_type;

**/

    CURSOR	l_budget_rules_csr(p_draft_version_id NUMBER)
    IS
    SELECT 	v.resource_list_id,
	    	t.project_type_class_code,
		prl.group_resource_type_id
    FROM   	pa_project_types t,
	    	pa_projects p,
	    	pa_resource_lists prl,
	    	gms_budget_versions v
    WHERE  	v.budget_version_id = p_draft_version_id
    AND		v.project_id = p.project_id
    AND		prl.resource_list_id = v.resource_list_id
    AND 	p.project_type = t.project_type;

    CURSOR l_time_phased_type_csr(p_budget_version_id IN NUMBER)
    IS
    SELECT 	pbem.time_phased_type_code, pbem.entry_level_code
    FROM 	gms_budget_versions gbv,
		pa_budget_entry_methods pbem
    WHERE	gbv.budget_version_id = p_budget_version_id
    AND		gbv.budget_entry_method_code = pbem.budget_entry_method_code;

-- Required to obtain Award and Project Numbers to be used in error messages

    CURSOR l_award_csr(p_award_id IN NUMBER)
    IS
    SELECT 	award_number
    FROM 	gms_awards_v
    WHERE	award_id = p_award_id;

    CURSOR l_project_csr(p_project_id IN NUMBER)
    IS
    SELECT 	segment1
    FROM 	pa_projects
    WHERE	project_id = p_project_id;

    CURSOR l_wf_notif_role_csr(p_award_id IN NUMBER)
    IS
    SELECT 	1
    FROM 	gms_notifications
    WHERE	award_id = p_award_id
    AND		event_type = 'BUDGET_BASELINE';

   /*Fix for bug 5620089*/
   CURSOR l_wf_enabled_csr(p_award_id IN NUMBER)
    IS
    SELECT      BUDGET_WF_ENABLED_FLAG
    FROM        gms_awards
    WHERE       award_id = p_award_id;
    /*End of fix for bug 5620089*/

-- ROW LOCKING ---------------------------------------------------------------

	CURSOR l_lock_budget_csr (p_budget_version_id NUMBER)
	IS
	SELECT 'x'
	FROM 	gms_budget_versions
	WHERE budget_version_id = p_budget_version_id
	FOR UPDATE NOWAIT;

------------------------------------------------------------------------------

   l_prev_entry_level_code pa_budget_entry_methods.entry_level_code%type;


   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'baseline_budget';
   l_award_id					NUMBER;
   l_project_id					NUMBER;
   l_award_number				VARCHAR2(15); -- Used to display in Error Messages only
   l_project_number				VARCHAR2(25); -- Used to display in Error Messages only
   l_budget_version_id				NUMBER;
   l_baselined_version_id			NUMBER;
   l_prev_baselined_version_id			NUMBER;
   l_budget_status_code				VARCHAR2(30);
   l_time_phased_type_code			VARCHAR2(1);
   l_mark_as_original				gms_budget_versions.current_original_flag%TYPE;
   i						NUMBER;
   l_row_found					NUMBER;
   l_function_allowed				VARCHAR2(1);
   l_resp_id					NUMBER := 0;
   l_user_id		                        NUMBER := 0;
   l_login_id					NUMBER := 0;
   l_module_name                                VARCHAR2(80);

   l_workflow_is_used 				VARCHAR2(1)	:= NULL;
   l_resource_list_id				NUMBER;

   l_group_resource_type_id			NUMBER; 	-- Used for Budgetary Control Setup.
   l_entry_level_code				VARCHAR2(30); 	-- Used for Budgetary Control Setup.

   l_project_type_class_code 			pa_project_types.project_type_class_code%TYPE;

   l_warnings_only_flag				VARCHAR2(1) := 'Y';
   l_err_msg_count				NUMBER	:= 0;
   l_old_stack					VARCHAR2(630);
   l_fc_return_code 				VARCHAR2(1);
   l_app_short_name				VARCHAR2(30); -- used for summarizing project budgets
   l_return_status				VARCHAR2(30); -- used for summarizing project budgets and gms_sweeping
   l_dummy_num					NUMBER;
   l_dummy_char					VARCHAR2(255);
   l_conc_request_id				NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   l_packet_id					NUMBER;
   v_project_start_date				DATE;
   v_project_completion_date			DATE;
   l_user_profile_value1                        VARCHAR2(30);
   l_set_profile_success1                       BOOLEAN := FALSE;
   l_user_profile_value2                        VARCHAR2(30);
   l_set_profile_success2                       BOOLEAN := FALSE;
   l_funds_check_at_submit                      VARCHAR2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_FUNDS_CHECK_AT_SUBMIT'),'Y'); -- Bug 2290959
   l_wf_enabled_flag                            VARCHAR2(1);--Added for bug 5620089
BEGIN

	gms_error_pkg.set_debug_context; -- Added for Bug: 2510024

	IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('*** Start of GMS_BUDGET_PUB.BASELINE_BUDGET ***','C');
	END IF;

	x_err_code := 0;
        x_err_stage := NULL; -- Bug 2587078
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> Baseline_budget';

    --	Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;

--  Standard begin of API savepoint

    SAVEPOINT baseline_budget_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in FND_API.Compatible_API_Call';
	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);
      fnd_msg_pub.add; -- Bug 2587078


	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    --product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
        x_err_stage := 'Error occured while validating product_code';
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
    THEN

        IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling convert_awardnum_to_id','C');
        END IF;

   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
           IF L_DEBUG = 'Y' THEN
	      gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Call to convert_awardnum_to_id returned x_err_code : '||x_err_code ||' x_err_stage :'||x_err_stage,'C');
           END IF;
 	   return;
	END IF;
    ELSE
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Award information';
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
--------------------------------------------------------------------------------
-- getting the award number to be used in Error Messages...

    open l_award_csr(l_award_id);
    fetch l_award_csr into l_award_number;
    close l_award_csr;

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_login_id := FND_GLOBAL.Login_id;

    l_module_name := 'GMS_PM_BASELINE_BUDGET';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- need to call the gms_security package
    -- If a user does not have privileges to update the award, then
    -- cannot baseline the budget

    IF L_DEBUG = 'Y' THEN
       gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_security.initialize','C');
    END IF;

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Initialize New OUT-parameter to indicate workflow status

-- Set Worflow Started Status -------------------------------------------------

    p_workflow_started		:= 'N';
------------------------------------------------------------------------------------

-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
                IF L_DEBUG = 'Y' THEN
	            gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling convert_projnum_to_id','C');
                END IF;
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
	           IF L_DEBUG = 'Y' THEN
		      gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Call to convert_projnum_to_id returned x_err_code : '||x_err_code ||' x_err_stage :'||x_err_stage,'C');
	           END IF;
		   return;
    		END IF;

	ELSE
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Project information';
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJECT_IS_MISSING', -- 'GMS_PROJ_NUM_ID_MISSING', Bug 2587078
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 2587078
		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

-------------------------------------------------------------------------------

-- getting the project number (segment1) to be used in Error Messages...

    open l_project_csr(l_project_id);
    fetch l_project_csr into l_project_number;
    close l_project_csr;

	IF l_project_id IS NULL   --never happens because previous procedure checks this.
	THEN
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Project information';
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_REF_AND_ID_MISSING', --'GMS_INVALID_PROJ_NUMBER', bug 2587078
					x_err_code => x_err_code,
			 		x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 2587078
		APP_EXCEPTION.RAISE_EXCEPTION;
     	END IF;

 -- budget type code is mandatory

     IF p_budget_type_code IS NULL
     OR p_budget_type_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Budget type information';
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_MISSING',
					x_err_code => x_err_code,
			 		x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 2587078
		APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE
     		OPEN l_budget_types_csr( p_budget_type_code );

		FETCH l_budget_types_csr
		INTO l_row_found;

		IF l_budget_types_csr%NOTFOUND
		THEN

			CLOSE l_budget_types_csr;
                        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Budget type information';
			gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_INVALID',
						x_err_code => x_err_code,
				 		x_err_buff => x_err_stage);
                        fnd_msg_pub.add; -- Bug 2587078
			APP_EXCEPTION.RAISE_EXCEPTION;

		END IF;

		CLOSE l_budget_types_csr;

     END IF;

 -- mark_as_original defaults to YES ('Y') when this is the first time this budget is baselined
 -- otherwise it will default to NO ('N')

    IF p_mark_as_original IS NULL
    OR p_mark_as_original = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR UPPER(p_mark_as_original) NOT IN ('N','Y')
    THEN

	OPEN l_baselined_csr( l_project_id
	                     ,l_award_id
			     ,p_budget_type_code );

	FETCH l_baselined_csr INTO l_row_found;

	IF l_baselined_csr%NOTFOUND
	THEN
       		l_mark_as_original := 'Y';
    	ELSE
    		l_mark_as_original := 'N';
    	END IF;

    	CLOSE l_baselined_csr;

    ELSE
    	l_mark_as_original := UPPER(p_mark_as_original);

    END IF;

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - l_mark_as_original : '||l_mark_as_original,'C');
    END IF;

 -- get the budget version ID associated with this project / budget_type_code combination

    OPEN l_budget_versions_csr ( l_project_id
                                ,l_award_id
    				,p_budget_type_code );

    FETCH l_budget_versions_csr
    INTO l_budget_version_id, l_budget_status_code;

    IF l_budget_versions_csr%NOTFOUND
    THEN
	CLOSE l_budget_versions_csr;
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Budget version information';
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_VERSION',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_budget_versions_csr;

 -- check for budget lines in gms_resource_assignments,
 -- we only permit submit/baseline action when there are budget lines

    OPEN l_resource_assignments_csr(l_budget_version_id);

    FETCH l_resource_assignments_csr
    INTO l_row_found;

    IF l_resource_assignments_csr%NOTFOUND
    THEN
	CLOSE l_resource_assignments_csr;
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Budget lines information';
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_LINES',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_resource_assignments_csr;

    OPEN l_time_phased_type_csr(l_budget_version_id);
    FETCH l_time_phased_type_csr
    INTO l_time_phased_type_code, l_entry_level_code ; -- l_entry_level_code for Budgetary Controls

    IF l_time_phased_type_csr%NOTFOUND
    THEN
	CLOSE l_time_phased_type_csr;
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Time phase information';
	gms_error_pkg.gms_message(x_err_name => 'GMS_TIME_PHASED_TYPE_CODE_MISS',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

-- Dummy call !

    IF L_DEBUG = 'Y' THEN
       gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_budget_core.verify', 'C');
    END IF;

    gms_budget_core.verify( x_budget_version_id  => l_budget_version_id
       		         ,x_err_code		=> x_err_code
			 ,x_err_stage		=> x_err_stage
			 ,x_err_stack		=> x_err_stack	);

    IF x_err_code <> 0
    THEN
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in gms_budget_core.verify';
	gms_error_pkg.gms_message(x_err_name => 'GMS_VERIFY_FAILED',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

-- ------------------------------------------------------------------------------------
--  Added SUBMISSION/BASELINE RULES and WORFLOW
-- ------------------------------------------------------------------------------------

-- Retrieve Required IN-parameters for Verify_Budget_Rules Calls

     OPEN l_budget_rules_csr(l_budget_version_id);

     FETCH l_budget_rules_csr
     INTO	l_resource_list_id
		, l_project_type_class_code
		, l_group_resource_type_id;

     IF ( l_budget_rules_csr%NOTFOUND)
    THEN

	CLOSE l_budget_rules_csr;
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured while validating Budget rules information';
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_RULES_ATTR',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    CLOSE l_budget_rules_csr;


----------------------------------------------------------------------------
-- The budget will be Submitted or Baselined depending on the value
-- of l_budget_status_code and if workflow is enabled or not
--
-- if status is 'W' then
-- 	if workflow enabled then
--		start WF process for Submit and Baseline
--	else
--		set the appropriate status flags and return control
--		to calling program (Form)
--	end if
-- elseif status is 'S' then
--	Baseline (assuming that WF is not enabled)
-- end if
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--	Conditional Funds Checking.
-- 	if is_fc_required returns TRUE then
-- 	update GMS_BUDGET_VERSIONS table and set FC_REQUIRED_FLAG = 'Y'
--	The Funds Checking process is run only if this flag is 'Y'
----------------------------------------------------------------------------

	if is_fc_required (p_project_id => l_project_id,
			p_award_id => l_award_id)
	then
		IF L_DEBUG = 'Y' THEN
		  gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Call to is_fc_required returned TRUE ', 'C');
		END IF;

		UPDATE 	gms_budget_versions
		SET 	fc_required_flag = 'Y'
		WHERE 	award_id = l_award_id
		AND	project_id = l_project_id
		AND	budget_type_code = p_budget_type_code
		AND	budget_status_code in ('W','S');
	else
		IF L_DEBUG = 'Y' THEN
		  gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Call to is_fc_required returned FALSE ', 'C');
		END IF;

		UPDATE 	gms_budget_versions
		SET 	fc_required_flag = 'N'
		WHERE 	award_id = l_award_id
		AND	project_id = l_project_id
		AND	budget_type_code = p_budget_type_code
		AND	budget_status_code in ('W','S');
	end if;


   IF l_budget_status_code = 'W'
   THEN

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Start of Submit process', 'C');
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES - Submit mode', 'C');
	END IF;

-- this is also a dummy call ...
     GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id		=>	l_budget_version_id
    , p_mark_as_original  	=>	l_mark_as_original
    , p_event			=>	'SUBMIT'
    , p_project_id		=>	l_project_id
    , p_award_id		=>	l_award_id
    , p_budget_type_code	=>	p_budget_type_code
    , p_resource_list_id	=>	l_resource_list_id
    , p_project_type_class_code	=>	l_project_type_class_code
    , p_created_by 		=>	G_USER_ID
    , p_calling_module		=>	'GMSMBUPB'
    , p_warnings_only_flag	=> 	l_warnings_only_flag
    , p_err_msg_count		=> 	l_err_msg_count
    , p_err_code		=> 	x_err_code
    , p_err_stage		=> 	x_err_stage
    , p_err_stack		=> 	x_err_stack
    );

-- Warnings-OK Concept -----------------------------------

-- Bug 2587078 : Replacing chekc from l_err_msg_count > 0 to x_err_code <> 0
-- as the l_err_msg_count is not set in all the error cases .

--IF (l_err_msg_count > 0)
IF (x_err_code <> 0)
 THEN
	IF (l_warnings_only_flag 	<> 'Y')
	THEN
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES - Submit';
		gms_error_pkg.gms_message(x_err_name => 'GMS_VERIFY_BUDGET_FAIL_S',
					x_err_code => x_err_code,
			 		x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 25870708
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
END IF;


-- LOCK DRAFT BUDGET VERSION Since Primary Verification Finished
    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Locking the budget', 'C');
    END IF;

    OPEN l_lock_budget_csr(l_budget_version_id);
    CLOSE l_lock_budget_csr;

-- BASELINE RULES -------------------------------------------------------------

    IF L_DEBUG = 'Y' THEN
       gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES - Baseline mode', 'C');
    END IF;

GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES
    (p_draft_version_id		=>	l_budget_version_id
    , p_mark_as_original  	=>	l_mark_as_original
    , p_event			=> 	'BASELINE'
    , p_project_id		=>	l_project_id
    , p_award_id		=>	l_award_id
    , p_budget_type_code	=>	p_budget_type_code
    , p_resource_list_id	=>	l_resource_list_id
    , p_project_type_class_code	=>	l_project_type_class_code
    , p_created_by 		=>	G_USER_ID
    , p_calling_module		=>	'GMSMBUPB'
    , p_warnings_only_flag	=> 	l_warnings_only_flag
    , p_err_msg_count		=> 	l_err_msg_count
    , p_err_code		=> 	x_err_code
    , p_err_stage		=> 	x_err_stage
    , p_err_stack		=> 	x_err_stack
    );


-- Warnings-OK Concept -----------------------------------
-- Bug 2587078 : Replacing chekc from l_err_msg_count > 0 to x_err_code <> 0
-- as the l_err_msg_count is not set in all the error cases .

--IF (l_err_msg_count > 0)
IF (x_err_code <> 0)
 THEN
	IF (l_warnings_only_flag <> 'Y')
	THEN
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in GMS_BUDGET_UTILS.VERIFY_BUDGET_RULES - Baseline ';
	gms_error_pkg.gms_message(x_err_name => 'GMS_VERIFY_BUDGET_FAIL_B',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;
END IF;

-- CHECKING IF WORKFLOW IS ENABLED FOR THIS AWARD

IF L_DEBUG = 'Y' THEN
 gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_wf_pkg.is_budget_wf_used', 'C');
END IF;

GMS_WF_PKG.Is_Budget_Wf_Used
( p_project_id 			=>	l_project_id
, p_award_id 			=>	l_award_id
, p_budget_type_code		=>	p_budget_type_code
, p_pm_product_code		=>	p_pm_product_code
, p_result			=>	l_workflow_is_used
, p_err_code             	=>	x_err_code
, p_err_stage         		=> 	x_err_stage
, p_err_stack			=>	x_err_stack
);

	IF (x_err_code <> 0)
	THEN
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in gms_wf_pkg.is_budget_wf_used';
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_WF_CHECK_FAIL',
					x_err_code => x_err_code,
		 			x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 2587078
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

    IF L_DEBUG = 'Y' THEN
       gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - l_workflow_is_used : '||l_workflow_is_used, 'C');
    END IF;

IF (l_workflow_is_used = 'T' ) THEN -- WORKFLOW IS ENABLED FOR THIS AWARD

	-- when the client extension returns 'T',
	-- the baseline action will be skipped here, since the baselining is done later
	-- by the baseliner as part of the workflow process.

	UPDATE gms_budget_versions
    	SET 	--budget_status_code = 'S',
    	WF_status_code = 'IN_ROUTE',
    	conc_request_id = l_conc_request_id
    	WHERE budget_version_id = l_budget_version_id;

        IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_wf_pkg.start_budget_wf', 'C');
        END IF;

     	GMS_WF_PKG.Start_Budget_Wf
	( p_draft_version_id		=> 	l_budget_version_id
	, p_project_id			=>	l_project_id
	, p_award_id			=>	l_award_id
	, p_budget_type_code		=>	p_budget_type_code
	, p_mark_as_original		=>	l_mark_as_original
	, p_err_code             	=>	x_err_code
	, p_err_stage         		=> 	x_err_stage
	, p_err_stack			=>	x_err_stack
	);

    IF (x_err_code <> 0)
    THEN
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in gms_wf_pkg.start_budget_wf';
	gms_error_pkg.gms_message(x_err_name => 'GMS_START_BUDG_WF_FAIL',
				x_err_code => x_err_code,
		 		x_err_buff => x_err_stage);
        fnd_msg_pub.add; -- Bug 2587078
	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

	p_workflow_started		:= 'Y';

-- NOTE: A commit is required to actually start/activate  the workflow instance opened
-- by the previous Start_Budget_WF procedure.


	IF FND_API.TO_BOOLEAN( p_commit )
    	THEN
		COMMIT;
	END IF;

        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Budget workflow started ';
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_WF_STARTED',
					x_token_name1 => 'AWARD_NUMBER',
					x_token_val1 =>	l_award_number,
					x_token_name2 => 'PROJECT_NUMBER',
					x_token_val2 => l_project_number,
					x_exec_type => 'C', -- for concurrent process
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);
        fnd_msg_pub.add; --2587078
	x_err_code := 0; -- setting x_err_code to zero since this is not an error condition.

	--fnd_file.put_line(FND_FILE.OUTPUT, x_err_stage);
	gms_error_pkg.gms_output(x_output => x_err_stage);

ELSE -- WORKFLOW IS NOT ENABLED FOR THIS AWARD

      IF L_DEBUG = 'Y' THEN
	 gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - l_funds_check_at_submit : '||l_funds_check_at_submit,'C');
      END IF;

      IF l_funds_check_at_submit = 'Y' THEN --Bug 2290959 : Perform fundscheck only if the profile 'GMS : Enable funds check for budget Submission' is set to Yes.

-- CALLING THE FUNDSCHECK PROCESS ...
        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - In gms_budget_balance.update_gms_balance';
	gms_budget_balance.update_gms_balance( x_project_id => l_project_id
					     , x_award_id => l_award_id
					     , x_mode => 'S'
					     , ERRBUF => x_err_stage
					     , RETCODE => l_fc_return_code);

-- Redefining the savepoint because gms_budget_balance.update_gms_balance() clears the
-- original savepoint by issuing commits within it.

	SAVEPOINT baseline_budget_pub;

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - l_fc_return_code : '||l_fc_return_code, 'C');
	END IF;


      END IF; --Bug 2290959

	IF ((l_fc_return_code = 'S' AND l_funds_check_at_submit = 'Y') OR l_funds_check_at_submit = 'N' )THEN --Bug 2290959

        	IF L_DEBUG = 'Y' THEN
		   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating Budget to Submitted status', 'C');
	        END IF;

		UPDATE 	gms_budget_versions
    		SET 	budget_status_code = 'S',
    			WF_status_code = NULL,
    			conc_request_id = l_conc_request_id,
    			current_original_flag = l_mark_as_original -- Added for Bug:1578992
    		WHERE budget_version_id = l_budget_version_id;
                x_err_stage := NULL;
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_SUBMITTED',
					x_token_name1 => 'AWARD_NUMBER',
					x_token_val1 =>	l_award_number,
					x_token_name2 => 'PROJECT_NUMBER',
					x_token_val2 => l_project_number,
					x_exec_type => 'C', -- for concurrent process
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		x_err_code := 0; -- setting x_err_code to zero since this is not an error condition.

		--fnd_file.put_line(FND_FILE.OUTPUT, x_err_stage);
		gms_error_pkg.gms_output(x_output => x_err_stage);

	ELSE
                x_err_stage := NULL;
		gms_error_pkg.gms_message(x_err_name => 'GMS_FC_FAIL_SUBMIT',
					x_token_name1 => 'AWARD_NUMBER',
					x_token_val1 => l_award_number,
					x_token_name2 => 'PROJECT_NUMBER',
					x_token_val2 => l_project_number,
					x_exec_type => 'C', -- for concurrent process
					x_err_code => x_err_code,
			 		x_err_buff => x_err_stage);
		-- Bug 3022766 : Introduced error code = 3 to represent fundscheck failure status
		-- and commented below code.
		--x_err_code := 0; -- Since we don't have to error out NOCOPY the Concurrent Process.
		x_err_code := 3;

		-- End of code changes done for bug 3022766

		--fnd_file.put_line(FND_FILE.OUTPUT, x_err_stage);
		gms_error_pkg.gms_output(x_output => x_err_stage);
		rollback to baseline_budget_pub;

        	IF L_DEBUG = 'Y' THEN
	           gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - End of Submit process', 'C');
                END IF;
		return;
	END IF;

END IF; -- (l_workflow_is_used = 'T' )
IF L_DEBUG = 'Y' THEN
   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - End of Submit process', 'C');
END IF;
---------------------------------------------------------------------------------------
ELSE -- Budget status is 'S', so Baseline the budget

        IF L_DEBUG = 'Y' THEN
          gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Start of Baseline process', 'C');
          gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_budget_core.baseline', 'C');
        END IF;
	gms_budget_core.baseline ( x_draft_version_id 	=> l_budget_version_id
				,x_mark_as_original	=> l_mark_as_original
				,x_verify_budget_rules 	=> 'N'
				,x_err_code		=> x_err_code
				,x_err_stage		=> x_err_stage
				,x_err_stack		=> x_err_stack		);

		IF x_err_code <> 0
		THEN
                        x_err_stage := 	'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in gms_budget_core.baseline';
			gms_error_pkg.gms_message(x_err_name => 'GMS_BASELINE_FAILED',
						x_err_code => x_err_code,
				 		x_err_buff => x_err_stage);
                        fnd_msg_pub.add; -- Bug 2587078
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

-- Bug 5162777 : Derive the the budget_version_id of the previously baselined budget before creating new BC records.
----------- DERIVING THE BUDGET_VERSION_ID OF THE PREVIOUSLY BASELINED BUDGET -----------------

-- Bug 2386041
	begin
	-- First get the budget_version_id of the previously baselined budget. In case there is an error we need to set the current_flag
	-- for this line to Y

              IF L_DEBUG = 'Y' THEN
	          gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Fetching previous budget_version_id', 'C');
              END IF;


	      select	bv.budget_version_id,
	                bem.entry_level_code
	        into    l_prev_baselined_version_id,
		        l_prev_entry_level_code
	        from    gms_budget_versions bv,
		        pa_budget_entry_methods bem
		where 	bv.award_id = l_award_id
		and 	bv.project_id = l_project_id
		and	bv.budget_type_code = p_budget_type_code
		and 	bv.budget_status_code = 'B'
		and 	bv.current_flag = 'R'
		and     bv.budget_entry_method_code = bem.budget_entry_method_code;

	     IF L_DEBUG = 'Y' THEN
	          gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Fetched previous budget_version_id '||l_prev_baselined_version_id, 'C');
              END IF;


	exception
	when NO_DATA_FOUND then
              -- this means that there did not exist any baselined budget earlier
              l_prev_baselined_version_id := null;
	      l_prev_entry_level_code := null;
              IF L_DEBUG = 'Y' THEN
	          gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - There exists no baselined budget earlier', 'C');
              END IF;

	when OTHERS then
           x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - While fetching previous version id, when others exception ';
           gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
	 	   		      x_token_name1 => 'SQLCODE',
	 			      x_token_val1 => sqlcode,
	 			      x_token_name2 => 'SQLERRM',
	 			      x_token_val2 => sqlerrm,
	 			      x_err_code => x_err_code,
	 			      x_err_buff => x_err_stage);

           fnd_msg_pub.add;
	   APP_EXCEPTION.RAISE_EXCEPTION;
	end;
       -- Bug 2386041

---------------------------------------------------------------------------------------------------------

-- Bug 5162777 : The budgetary control records are created before invoking fundscheck process.
----------------------- START  OF BC RECORD CREATION -------------------------

			gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_budg_cont_setup.bud_ctrl_create', 'C');
			gms_budg_cont_setup.bud_ctrl_create(p_project_id => l_project_id
							   ,p_award_id => l_award_id
							   ,p_prev_entry_level_code => l_prev_entry_level_code
							   ,p_entry_level_code => l_entry_level_code
							   ,p_resource_list_id => l_resource_list_id
							   ,p_group_resource_type_id => l_group_resource_type_id
							   ,x_err_code => x_err_code
							   ,x_err_stage => x_err_stage);

			if x_err_code <> 0
			then
                                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occurred in gms_budg_cont_setup.bud_ctrl_create';
				gms_error_pkg.gms_message(x_err_name => 'GMS_BUDG_CONTROL_SETUP_FAIL',
							x_err_code => x_err_code,
			 				x_err_buff => x_err_stage);

				SAVEPOINT baseline_budget_pub;
                                fnd_msg_pub.add; -- Bug 2587078
				APP_EXCEPTION.RAISE_EXCEPTION;
				-- Bug 2386041
			end if;
----------------------- END OF BC RECORD CREATION -------------------------

-- CALLING THE FUNDSCHECK PROCESS ...
	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_budget_balance.update_gms_balance','C');
	END IF;

	gms_budget_balance.update_gms_balance( x_project_id => l_project_id
					     , x_award_id => l_award_id
					     , x_mode => 'B'
					     , ERRBUF => x_err_stage
					     , RETCODE => l_fc_return_code);

-- Redefining the savepoint because gms_budget_balance.update_gms_balance() clears the
-- original savepoint by issuing commits within it.

	SAVEPOINT baseline_budget_pub;

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - l_fc_return_code : '||l_fc_return_code, 'C');
	END IF;

	IF l_fc_return_code = 'S'
	THEN  -- Funds check passed

-- after calling BASELINE, set the budget_status_code back to 'W' (Working)
-- the concept of submitting budget is not available in the public API's!

        	IF L_DEBUG = 'Y' THEN
		  gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating Budget to Working status', 'C');
	        END IF;

		UPDATE gms_budget_versions
		SET budget_status_code = 'W', conc_request_id = l_conc_request_id
		WHERE budget_version_id = l_budget_version_id;

-- 29-May-2000------------------------------------------------------------------------------------
-- if Funds check (during baselining, only) was successful then we have to:
-- 	1. set the current_flag = 'N' for the previously baselined budget (whose current_flag was set to 'R')
-- 	2. set the current_flag = 'Y' for the newly created budget,
-- 	3. Summarize the Project Budget and
-- 	4. Run the default setup for Budgetary Control (if budget is baselined for the first time)
--      5. call sweeper - added for Bug: 1666853
-- 	6. call Workflow process to send notification
--------------------------------------------------------------------------------------------------

-- 	1. set the current_flag = 'N' for the previously baselined budget (whose current_flag was set to 'R' earlier)

                IF L_DEBUG = 'Y' THEN
	            gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current flag to N on previous baselined budget version', 'C');
                END IF;

		update 	gms_budget_versions
		set 	current_flag = 'N'
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and	budget_type_code = p_budget_type_code
		and 	budget_status_code = 'B'
		and 	current_flag = 'R';

-- 	2. set the current_flag = 'Y' for the newly created budget.

		-- Corrected the query for Bug:2542827

                IF L_DEBUG = 'Y' THEN
	            gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current flag to Y on newly created budget version', 'C');
                END IF;

		update 	gms_budget_versions
		set	current_flag = 'Y'
		where 	budget_version_id = (	select 	max(budget_version_id)
						from 	gms_budget_versions
						where 	award_id = l_award_id
						and 	project_id = l_project_id
						and 	budget_type_code = p_budget_type_code);

--------------------------------------------------------------------------------------------------
        -- Bug 2386041
	-- 	After updating the newly created budget we have to get the budget_version_id of this budget
	-- 	which is going to be used by the Project Budget Summarization and Default Budgetary Control
	--	Setup programs

		begin
			select 	budget_version_id
			into 	l_baselined_version_id
			from 	gms_budget_versions
			where	award_id = l_award_id
			and	project_id = l_project_id
			and 	budget_type_code = p_budget_type_code
			and	budget_status_code = 'B'
			and	current_flag = 'Y';

                IF L_DEBUG = 'Y' THEN
	           gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - l_baselined_version_id '||l_baselined_version_id, 'C');
                END IF;

		exception
		when OTHERS
		then
                   x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - While fetching baselined version id, when others exception ';
	           gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
		 	   		      x_token_name1 => 'SQLCODE',
	 				      x_token_val1 => sqlcode,
	 				      x_token_name2 => 'SQLERRM',
	 				      x_token_val2 => sqlerrm,
		 			      x_err_code => x_err_code,
		 			      x_err_buff => x_err_stage);

	           fnd_msg_pub.add;
		   APP_EXCEPTION.RAISE_EXCEPTION;
		end;

-- Bug 2587078 :The Project budget summarization code is shifted after call to sweeper process .

-- 	3. The Budgetary Control records are created before the fundscheck process is invoked.


--      4. call gms_sweeper - added for Bug: 1666853

		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_sweeper.upd_act_enc_bal', 'C');
		END IF;


	        -- get the packet id for the budget and pass it on to the sweeper process.
	        -- locking issue addressed as the scope of locking is limited to the packet.
    	        -- if there are no transactions then no point calling sweeper process. We'll skip it.
	        -- Bug : 2821482.

                begin
                  select distinct packet_id
                    into l_packet_id
                    from gms_bc_packets
                   where budget_version_id = l_baselined_version_id;
                exception
                  -- no data will be found if there are no transactions.
                  when no_data_found then
                    l_packet_id := null;
                end;
	        -- end bug 2821482 changes.

      		if l_packet_id is not null then --> call sweeper if txns exist..bug 2821482.

		gms_sweeper.upd_act_enc_bal(errbuf => x_err_stage,
					retcode => x_err_code,
					x_mode => 'B',
                                        x_packet_id => l_packet_id,  --> bug 2821482
					x_project_id => l_project_id,
					x_award_id => l_award_id);

		if x_err_code <> 0 then -- Changed from 'S' to 0 (zero) for Bug:2464800
                        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occurred in gms_sweeper.upd_act_enc_bal';
			gms_error_pkg.gms_message(x_err_name => 'GMS_BU_SWEEP_FAILED',
					x_err_code => x_err_code,
	 				x_err_buff => x_err_stage);

 			IF L_DEBUG = 'Y' THEN
         		   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current flag to Y on previous baselined budget version', 'C');
			END IF;

	 		-- Bug 2386041
	 		update 	gms_budget_versions
			set 	current_flag = 'Y'
			where 	budget_version_id = l_prev_baselined_version_id;

		        IF L_DEBUG = 'Y' THEN
       			   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current flag to N on newly baselined budget version id', 'C');
		        END IF;

			update 	gms_budget_versions
			set 	current_flag = 'N'
			where 	budget_version_id = l_baselined_version_id;

		        IF L_DEBUG = 'Y' THEN
       			   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating budget to submitted status', 'C');
     	                END IF;

			UPDATE gms_budget_versions
			SET budget_status_code = 'S'
			WHERE budget_version_id = l_budget_version_id;

			commit;
			SAVEPOINT baseline_budget_pub;
                        fnd_msg_pub.add; -- Bug 2587078
			APP_EXCEPTION.RAISE_EXCEPTION;
			-- Bug 2386041
		end if;

      		end if; -- l_packet_id not null. Bug 2821482

-- Bug 2587078 :The Project budget summarization code is shifted here so that project budget summarization
--              is done after Award budget baselining process is completed successfully.

         -- Bug 2386041

-- 	5. Summarize the Project Budget.

		IF L_DEBUG = 'Y' THEN
		   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Start of Project Budget Summarization ', 'C');
		END IF;

		-- Bug 2386041
		    l_user_profile_value1 := fnd_profile.value_specific('PA_SUPER_PROJECT', fnd_global.user_id, fnd_global.resp_id, fnd_global.resp_appl_id);
                if ((l_user_profile_value1 = 'N') OR  (l_user_profile_value1 is null)) then

                   BEGIN

                      SELECT profile_option_value
                      INTO   l_user_profile_value1
                      FROM   fnd_profile_options       p,
                             fnd_profile_option_values v
                      WHERE  p.profile_option_name = 'PA_SUPER_PROJECT'
                      AND    v.profile_option_id = p.profile_option_id
                      AND    v.level_id = 10004
                      AND    v.level_value = fnd_global.user_id;

                   EXCEPTION

                      WHEN no_data_found THEN
                         l_user_profile_value1 := null;

                      WHEN others THEN
                         l_user_profile_value1 := null;

                   END;

                   l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', 'Y', 'USER', fnd_global.user_id);
                end if;

                l_user_profile_value2 := fnd_profile.value_specific('PA_SUPER_PROJECT_VIEW', fnd_global.user_id, fnd_global.resp_id, fnd_global.resp_appl_id);
                if ((l_user_profile_value2 = 'N') OR  (l_user_profile_value2 is null)) then

                   BEGIN

                      SELECT profile_option_value
                      INTO   l_user_profile_value2
                      FROM   fnd_profile_options       p,
                             fnd_profile_option_values v
                      WHERE  p.profile_option_name = 'PA_SUPER_PROJECT_VIEW'
                      AND    v.profile_option_id = p.profile_option_id
                      AND    v.level_id = 10004
                      AND    v.level_value = fnd_global.user_id;

                   EXCEPTION

                      WHEN no_data_found THEN
                         l_user_profile_value2 := null;

                      WHEN others THEN
                         l_user_profile_value2 := null;

                   END;

                   l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', 'Y', 'USER', fnd_global.user_id);

                end if;


		IF L_DEBUG = 'Y' THEN
  		    gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_summarize_budgets.summarize_baselined_versions', 'C');
		END IF;

	        -- Bug 2386041
		gms_summarize_budgets.summarize_baselined_versions( x_project_id => l_project_id
								  , x_time_phased_type_code => l_time_phased_type_code
								  , x_app_short_name => l_app_short_name
								  , RETCODE => l_return_status
								  , ERRBUF => x_err_stage);

		-- Bug 2386041
	         if (l_set_profile_success1 = TRUE) then
                     l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', l_user_profile_value1, 'USER', fnd_global.user_id);
                 end if;
                 if (l_set_profile_success2 = TRUE) then
                     l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', l_user_profile_value2, 'USER', fnd_global.user_id);
                 end if;
	        -- Bug 2386041

                -- Fix for bug : 5511910. We retrun stasus values as 'P' if summarization does not happen.
		--IF l_return_status <> 'S'
                  IF l_return_status  NOT in ( 'S','X') THEN

       	                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occured in gms_summarize_budgets.summarize_baselined_versions';
			gms_error_pkg.gms_message(x_err_name => 'GMS_SUMMARIZE_PA_BUDG_FAIL',
						x_err_code => x_err_code,
		 				x_err_buff => x_err_stage);

 			IF L_DEBUG = 'Y' THEN
         		   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current flag to Y on previous baselined budget version', 'C');
			END IF;

		 	-- Bug 2386041
			update 	gms_budget_versions
			set 	current_flag = 'Y'
			where 	budget_version_id = l_prev_baselined_version_id;

		        IF L_DEBUG = 'Y' THEN
       			   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current flag to N on newly baselined budget version id', 'C');
		        END IF;

			update 	gms_budget_versions
			set 	current_flag = 'N'
			where 	budget_version_id = l_baselined_version_id;

		        IF L_DEBUG = 'Y' THEN
       			   gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating budget to submitted status', 'C');
     	                END IF;

			UPDATE gms_budget_versions
			SET budget_status_code = 'S'
			WHERE budget_version_id = l_budget_version_id;

			commit;
			SAVEPOINT baseline_budget_pub;
                        fnd_msg_pub.add; -- Bug 2587078
			APP_EXCEPTION.RAISE_EXCEPTION;
			-- Bug 2386041

		END IF;

-- 	6. call Workflow process to send notification

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET -Sending workflow notifictaion', 'C');
	END IF;

        open l_wf_notif_role_csr (p_award_id => l_award_id);
	fetch l_wf_notif_role_csr into l_row_found;

        /*Added for bug 5620089*/
        open l_wf_enabled_csr (p_award_id => l_award_id);
        fetch l_wf_enabled_csr into l_wf_enabled_flag;
        /*End of fix for bug 5620089*/

        if l_wf_notif_role_csr%FOUND AND l_wf_enabled_flag = 'Y' then --One more condition added for bug 5620089

		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Calling gms_wf_pkg.start_budget_wf_ntfy_only', 'C');
		END IF;

     		GMS_WF_PKG.Start_Budget_Wf_Ntfy_Only
		( p_draft_version_id		=> 	l_budget_version_id
		, p_project_id			=>	l_project_id
		, p_award_id			=>	l_award_id
		, p_budget_type_code		=>	p_budget_type_code
		, p_mark_as_original		=>	l_mark_as_original
		, p_err_code             	=>	x_err_code
		, p_err_stage         		=> 	x_err_stage
		, p_err_stack			=>	x_err_stack);

		if (x_err_code <> 0) then
                        x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Error occurred in gms_wf_pkg.start_budget_wf_ntfy_only' ;
			gms_error_pkg.gms_message(x_err_name => 'GMS_BU_WF_NTFY_FAIL', -- 'GMS_NTFY_BUDG_WF_FAIL', Bug 2587078
					x_err_code => x_err_code,
		 			x_err_buff => x_err_stage,
					x_exec_type => 'C');
			x_err_code := 4; -- to show a WARNING in the concurrent request window.

			--fnd_file.put_line(FND_FILE.OUTPUT, x_err_stage);
			gms_error_pkg.gms_output(x_output => x_err_stage);
			return;

			-- We don't have to stop the baseline process if the WF Notification process fails.
			-- APP_EXCEPTION.RAISE_EXCEPTION;
		end if;

	end if;

	close l_wf_notif_role_csr;

--------------------------------------------- ----------------------------------------------------------------------------------
-- GMS enhancement for R12 : 5583170
gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - l_return_status IS  ==== : '|| l_return_status,'C');
              If l_return_status  = 'S' then
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Baselining successful ' ;
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_BASELINED',
					x_token_name1 => 'PROJECT_NUMBER',
					x_token_val1 => l_project_number,
					x_exec_type => 'C', -- for concurrent process
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		x_err_code := 0; -- setting x_err_code to zero since this is not an error condition.
                gms_error_pkg.gms_output(x_output => x_err_stage);
                end if ;

               if l_return_status = 'X' then -- fix for bug : 5511910
                         gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_BASELINED_ONLY',
                                        x_exec_type => 'C', -- for concurrent process
                                        x_err_code => x_err_code,
                                        x_err_buff => x_err_stage);

		x_err_code := 0; -- setting x_err_code to zero since this is not an error condition.
		gms_error_pkg.gms_output(x_output => x_err_stage);

               end if;
--   end of GMS enhancement


-- The following ELSIF condition for (l_fc_return_code = 'F') is added for Bug: 2510024

	ELSIF l_fc_return_code = 'F' then 	-- l_fc_return_code = 'F' - Funds check Failed

-- 	since Funds check failed the previously baselined budget (whose current_flag was set to 'R' earlier) has to be restored

		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current_flag to Y on previously baselined budget', 'C');
		END IF;

		update 	gms_budget_versions
		set 	current_flag = 'Y'
		where 	award_id = l_award_id
		and 	project_id = l_project_id
		and	budget_type_code = p_budget_type_code
		and 	budget_status_code = 'B'
		and 	current_flag = 'R';

--	The above update should be committed explicitly since the following error handling routine will rollback.

		commit;

-- 	Redefining the savepoint since the above commit will clear all previously defined savepoints

		SAVEPOINT baseline_budget_pub;
		x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET - Fundscheck failed' ;
		gms_error_pkg.gms_message(x_err_name => 'GMS_FC_FAIL_BASELINE',
					x_token_name1 => 'AWARD_NUMBER',
					x_token_val1 => l_award_number,
					x_token_name2 => 'PROJECT_NUMBER',
					x_token_val2 => l_project_number,
					x_exec_type => 'C', -- for concurrent process
					x_err_code => x_err_code,
			 		x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 2587078
		--fnd_file.put_line(FND_FILE.OUTPUT, x_err_stage);
		gms_error_pkg.gms_output(x_output => x_err_stage);

		-- Bug 3022766 : Introduced error code = 3 to represent fundscheck failure status
		-- and commented below code.
		--x_err_code := 0; -- Since we don't have to error out NOCOPY the Concurrent Process.
		x_err_code := 3;

		-- End of code changes done for bug 3022766

		rollback to baseline_budget_pub;
		return;

        ELSE -- l_fc_return_code = 'H' or 'L'  - Unexpected Error Occured

		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - Updating current_flag to Y on previously baselined budget', 'C');
		END IF;

--      since Funds check failed the previously baselined budget (whose current_flag was set to 'R' earlier) has to be restored

                update  gms_budget_versions
                set     current_flag = 'Y'
                where   award_id = l_award_id
                and     project_id = l_project_id
                and     budget_type_code = p_budget_type_code
                and     budget_status_code = 'B'
                and     current_flag = 'R';

--      The above update should be committed explicitly since the following error handling routine will rollback.

                commit;

--      Redefining the savepoint since the above commit will clear all previously defined savepoints

                SAVEPOINT baseline_budget_pub;
                x_err_stage := 'GMS_BUDGET_PUB.BASELINE_BUDGET -Unexpected error' ;
	        gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
                                x_token_name1 => 'SQLCODE',
                                x_token_val1 => sqlcode,
                                x_token_name2 => 'SQLERRM',
                                x_token_val2 => sqlerrm,
                                x_err_code => x_err_code,
                                x_err_buff => x_err_stage);
                fnd_msg_pub.add; -- Bug 2587078
                --fnd_file.put_line(FND_FILE.OUTPUT, x_err_stage);
                gms_error_pkg.gms_output(x_output => x_err_stage);

                rollback to baseline_budget_pub;
                return;

	END IF;

	IF L_DEBUG = 'Y' THEN
	    gms_error_pkg.gms_debug('GMS_BUDGET_PUB.BASELINE_BUDGET - End of Baseline process', 'C');
	END IF;

END IF; -- <l_budget_status_code = 'W'>

IF L_DEBUG = 'Y' THEN
    gms_error_pkg.gms_debug('*** End of GMS_BUDGET_PUB.BASELINE_BUDGET ***','C');
END IF;

EXCEPTION
	WHEN OTHERS
	THEN
	        x_err_stage :='GMS_BUDGET_PUB.BASELINE_BUDGET - In when others exception';

	        gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_FAILED', -- Bug 2587078
                                x_err_code => x_err_code,
                                x_err_buff => x_err_stage);
                fnd_msg_pub.add;
		ROLLBACK TO baseline_budget_pub;
		RAISE;

END baseline_budget;

----------------------------------------------------------------------------------------
--Name:               add_budget_line
--Type:               Procedure
--Description:        This procedure can be used to add a budgetline to an
--                    existing WORKING budget.
--
--Called subprograms:
--			gms_budget_utils.check_overlapping_dates()
--			gms_budget_pub.summerize_project_totals()
--
--
--
--History:
--

PROCEDURE add_budget_line
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_task_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_task_number			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_alias		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id	IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_budget_start_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_budget_end_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_period_name			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_burdened_cost		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_quantity			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_unit_of_measure		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_track_as_labor_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_line_reference	IN      VARCHAR2                := GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost_source		IN 	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_source	IN 	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_quantity_source		IN 	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 )
IS


   -- needed to get the fields associated to a budget entry method

   CURSOR	l_budget_entry_method_csr
   		(p_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
   IS
   SELECT *
   FROM   pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code
   AND 	  trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

   -- needed to get budget_type_code and award_id based on the budget_version_id

   CURSOR l_budget_version_csr (p_project_id 	NUMBER
   				,p_award_id 	NUMBER
   				,p_budget_type_code	VARCHAR2)
   IS
   SELECT budget_version_id, budget_entry_method_code, resource_list_id
   FROM gms_budget_versions
   WHERE project_id = p_project_id
   AND award_id = p_award_id
   AND budget_status_code = 'W';


   -- needed to do validation on mandatory fields for budget lines

   CURSOR	l_budget_amount_code_csr
   		( p_budget_type_code	VARCHAR2 )
   IS
   SELECT budget_amount_code
   FROM	  pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;

-----------------

   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'add_budget_line';
   i						NUMBER;

   l_award_id					NUMBER;
   l_project_id					NUMBER;
   l_task_id					NUMBER;
   l_budget_version_id				NUMBER;
   l_return_status_task				NUMBER;
   l_budget_entry_method_code			VARCHAR2(30);
   l_resource_list_id				NUMBER;
   l_period_name				VARCHAR2(20);
   l_budget_start_date				DATE;
   l_budget_end_date				DATE;
   l_resource_assignment_id			NUMBER;
   l_member_id					NUMBER;
---------------
   l_description				VARCHAR2(255);
   l_quantity					NUMBER;
   l_raw_cost					NUMBER;
   l_burdened_cost				NUMBER;
   l_unit_of_measure				VARCHAR2(30);
   l_track_as_labor_flag			VARCHAR2(1);
   l_attribute_category				VARCHAR2(30);
   l_attribute1					VARCHAR2(150);
   l_attribute2					VARCHAR2(150);
   l_attribute3					VARCHAR2(150);
   l_attribute4					VARCHAR2(150);
   l_attribute5					VARCHAR2(150);
   l_attribute6					VARCHAR2(150);
   l_attribute7					VARCHAR2(150);
   l_attribute8					VARCHAR2(150);
   l_attribute9					VARCHAR2(150);
   l_attribute10				VARCHAR2(150);
   l_attribute11				VARCHAR2(150);
   l_attribute12				VARCHAR2(150);
   l_attribute13				VARCHAR2(150);
   l_attribute14				VARCHAR2(150);
   l_attribute15				VARCHAR2(150);
---------------
   l_budget_entry_method_rec			pa_budget_entry_methods%rowtype;
   l_budget_amount_code				pa_budget_types.budget_amount_code%type;
   l_resource_name				pa_resource_list_members.alias%type;   /*Changed for bug 4614242*/
   l_function_allowed				VARCHAR2(1);
   l_resp_id					NUMBER := 0;
   l_user_id		                        NUMBER := 0;
   l_login_id					NUMBER := 0;
   l_module_name                                VARCHAR2(80);
   l_old_stack					VARCHAR2(630);

BEGIN

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - start');

	x_err_code := 0;
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> Add_Budget_Line';

    --	Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;

--  Standard begin of API savepoint

    SAVEPOINT add_budget_line_pub;


--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN

	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_login_id := FND_GLOBAL.Login_id;
    l_module_name := 'GMS_PM_ADD_BUDGET_LINE';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- need to call the gms_security package
    -- If a user does not have privileges to update the award, then
    -- cannot add a budget line

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);


--CHECK FOR MANDATORY FIELDS and CONVERT VALUES to ID's

    --product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
    THEN
   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
		return;
	END IF;
    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
--------------------------------------------------------------------------------
-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after award info validation');

-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			return;
    		END IF;

	ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_NUM_ID_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

-------------------------------------------------------------------------------
-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after project info validation');

     IF l_project_id IS NULL
     THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJECT_IS_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

      -- Now verify whether award security allows the user to update
      -- the award
      -- If a user does not have privileges to update the award, then
      -- cannot add a budget line

	IF gms_security.allow_query (x_award_id => l_award_id ) = 'N' THEN

         -- The user does not have query privileges on this award
         -- Hence, cannot update the award. Raise error

		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_QRY',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF gms_security.allow_update (x_award_id => l_award_id ) = 'N' THEN

            -- The user does not have update privileges on this award
            -- Hence , raise error
		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_UPD',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END IF;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after award security validation');

 -- budget type code is mandatory

     IF p_budget_type_code IS NULL
     THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
     ELSE
     		OPEN l_budget_amount_code_csr( p_budget_type_code );

		FETCH l_budget_amount_code_csr
		INTO l_budget_amount_code;     		--will be used later on during validation of Budget lines.

		IF l_budget_amount_code_csr%NOTFOUND
		THEN
			CLOSE l_budget_amount_code_csr;
			gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_INVALID',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		CLOSE l_budget_amount_code_csr;

     END IF;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after budget_amount_code_csr');

 -- Get the budget_version, budget_entry_method_code and resource_list_id from table gms_budget_versions

    OPEN l_budget_version_csr(l_project_id, l_award_id, p_budget_type_code);
    FETCH l_budget_version_csr
    INTO  l_budget_version_id
    ,     l_budget_entry_method_code
    ,     l_resource_list_id;

    IF l_budget_version_csr%NOTFOUND
    THEN
	CLOSE l_budget_version_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_VERSION',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_budget_version_csr;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after budget_version_csr');

-- entry method code is mandatory (and a nullible field in table gms_budget_versions)

     IF l_budget_entry_method_code IS NULL
     THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_ENTRY_METHOD_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

 -- check validity of this budget entry method code, and store associated fields in record

    OPEN l_budget_entry_method_csr(l_budget_entry_method_code);
    FETCH l_budget_entry_method_csr INTO l_budget_entry_method_rec;

    IF   l_budget_entry_method_csr%NOTFOUND
    THEN
	CLOSE l_budget_entry_method_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_ENTRY_METHOD_IS_INVALID',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_budget_entry_method_csr;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after budget_entry_method_csr');

-- if both task id and reference are NULL or not passed, we will assume that budgetting is
-- done at the project level and that requires l_task_id to be '0'
-- if budgeting at the project level,then ignore all tasks

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - entry_lvl_code = '||l_budget_entry_method_rec.entry_level_code);

        IF l_budget_entry_method_rec.entry_level_code = 'P' THEN
           l_task_id := 0;
        END IF;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - before convert_tasknum_to_id = '||to_char(l_project_id));
-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - before convert_tasknum_to_id = '||to_char(p_task_id));

        IF l_budget_entry_method_rec.entry_level_code in ('T','L','M')
        THEN
		convert_tasknum_to_id ( p_project_id_in => l_project_id
				,p_task_id_in => p_task_id
				,p_task_number_in => p_task_number
				,p_task_id_out => l_task_id
				,x_err_code => x_err_code
				,x_err_stage => x_err_stage
				,x_err_stack => x_err_stack);

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after convert_tasknum_to_id = '||to_char(l_task_id));

		IF x_err_code <> 0
		THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_TASK_NUMBER',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

   	END IF;

	IF l_budget_entry_method_rec.entry_level_code = 'T' THEN -- then check whether it is top task

	   IF l_task_id <> pa_task_utils.get_top_task_id( l_task_id ) THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_TASK_IS_NOT_TOP',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	   END IF;

	ELSIF l_budget_entry_method_rec.entry_level_code = 'L' -- then check whether it is lowest task
	  THEN
	    pa_tasks_pkg.verify_lowest_level_task( l_return_status_task,
						   l_task_id);
		IF l_return_status_task <> 0 THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_TASK_IS_NOT_LOWEST',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

	ELSIF l_budget_entry_method_rec.entry_level_code = 'M' -- then check whether it is a top or
				       -- lowest level tasks
	    THEN
	      IF l_task_id <> pa_task_utils.get_top_task_id( l_task_id ) THEN
		 pa_tasks_pkg.verify_lowest_level_task( l_return_status_task
						     	, l_task_id);
		 IF l_return_status_task <> 0 THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_TASK_IS_NOT_TOP_OR_LOWEST',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
                 END IF;
	      END IF;

	END IF;  -- If l_budget_entry_method_rec.entry_level_code = 'T'

        gms_budget_utils.get_valid_period_dates
                  (p_project_id		     => l_project_id
    		  ,p_task_id		     => l_task_id
		  ,p_award_id		     => l_award_id	-- Added for Bug 2200867
    		  ,p_time_phased_type_code   => l_budget_entry_method_rec.time_phased_type_code
    		  ,p_entry_level_code	     => l_budget_entry_method_rec.entry_level_code
    		  ,p_period_name_in	     => p_period_name
    		  ,p_budget_start_date_in    => p_budget_start_date
    		  ,p_budget_end_date_in	     => p_budget_end_date
    		  ,p_period_name_out	     => l_period_name -- p_period_name
    		  ,p_budget_start_date_out   => l_budget_start_date -- p_budget_start_date
    		  ,p_budget_end_date_out     => l_budget_end_date -- p_budget_end_date
    		  ,x_err_code		     => x_err_code
    		  ,x_err_stage		     => x_err_stage  );

		IF x_err_code <> 0
		THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_GET_PERIOD_DATE_FAIL',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after gms_budget_utils.get_valid_period_dates');

-- every budget line need to be checked for it's amount values.

    gms_budget_utils.check_entry_method_flags
             (  p_budget_amount_code 		=> l_budget_amount_code
	       ,p_budget_entry_method_code	=> l_budget_entry_method_code
	       ,p_quantity			=> p_quantity
	       ,p_raw_cost			=> p_raw_cost
	       ,p_burdened_cost		        => p_burdened_cost
	       ,x_err_code		        => x_err_code
	       ,x_err_stage			=> x_err_stage	);

	IF x_err_code <> 0
	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_CHK_ENTRYMETHOD_FAIL',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after gms_budget_utils.check_entry_method_flags');

/*
	We don't have to validate/convert resource_list info
	since we fetch it using cursor ...

    -- convert resource_list name to id
    IF (p_resource_list_name <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_resource_list_name IS NOT NULL)
    OR (p_resource_list_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_resource_list_id IS NOT NULL)
    THEN
    	convert_reslist_name_to_id
    		(p_resource_list_name_in => p_resource_list_name
    		,p_resource_list_id_in => p_resource_list_id
    		,p_resource_list_id_out => l_resource_list_id
    		,x_err_code => x_err_code
    		,x_err_stage => x_err_stage
    		,x_err_stack => x_err_stack);

	    IF x_err_code <> 0
    	THEN
    		x_err_stage := 'GMS_....';
    		return;
    	END IF;

    END IF;
*/

    -- convert resource alias to (resource) member id

    -- if resource alias is (passed and not NULL)
    -- and resource member is (passed and not NULL)
    -- then we convert the alias to the id
    -- else we default to the uncategorized resource member

   IF (p_resource_alias <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_resource_alias IS NOT NULL)

   OR (p_resource_list_member_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
       AND p_resource_list_member_id IS NOT NULL)
   THEN
     	convert_listmem_alias_to_id
     		(p_resource_list_id_in	=> l_resource_list_id 	-- IN
	     	,p_reslist_member_alias_in => p_resource_alias 	-- IN
	     	,p_resource_list_member_id_in => p_resource_list_member_id
	     	,p_resource_list_member_id_out	=> l_member_id
	     	,x_err_code => x_err_code
	     	,x_err_stage => x_err_stage
	     	,x_err_stack => x_err_stack);

     	IF x_err_code <> 0
     	THEN
		return;
     	END IF;

    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_RESOURCE_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


     --When budget line description is not passed, set value to NULL

     IF p_description = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_description := NULL;
     ELSE
     	l_description := p_description;
     END IF;

     IF p_period_name = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_period_name := NULL;
     ELSE
     	l_period_name := p_period_name;
     END IF;

     --When descriptive flex fields are not passed set them to NULL
     IF p_attribute_category = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute_category := NULL;
     ELSE
	l_attribute_category := p_attribute_category;
     END IF;
     IF p_attribute1 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute1 := NULL;
     ELSE
	l_attribute1 := p_attribute1;
     END IF;
     IF p_attribute2 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute2 := NULL;
     ELSE
	l_attribute2 := p_attribute2;
     END IF;
     IF p_attribute3 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute3 := NULL;
     ELSE
	l_attribute3 := p_attribute3;
     END IF;
     IF p_attribute4 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute4 := NULL;
     ELSE
	l_attribute4 := p_attribute4;
     END IF;

     IF p_attribute5 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute5 := NULL;
     ELSE
	l_attribute5 := p_attribute5;
     END IF;

     IF p_attribute6 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute6 := NULL;
     ELSE
	l_attribute6 := p_attribute6;
     END IF;

     IF p_attribute7 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute7 := NULL;
     ELSE
	l_attribute7 := p_attribute7;
     END IF;

     IF p_attribute8 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute8 := NULL;
     ELSE
	l_attribute8 := p_attribute8;
     END IF;
     IF p_attribute9 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute9 := NULL;
     ELSE
	l_attribute9 := p_attribute9;
     END IF;
     IF p_attribute10 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute10 := NULL;
     ELSE
	l_attribute10 := p_attribute10;
     END IF;
     IF p_attribute11 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute11 := NULL;
     ELSE
	l_attribute11 := p_attribute11;
     END IF;
     IF p_attribute12 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute12 := NULL;
     ELSE
	l_attribute12 := p_attribute12;
     END IF;
     IF p_attribute13 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute13 := NULL;
     ELSE
	l_attribute13 := p_attribute13;
     END IF;
     IF p_attribute14 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute14:= NULL;
     ELSE
	l_attribute14:= p_attribute14;
     END IF;

     IF p_attribute15 = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_attribute15 := NULL;
     ELSE
	l_attribute15 := p_attribute15;
     END IF;

     IF p_unit_of_measure = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_unit_of_measure := NULL;
     ELSE
	l_unit_of_measure := p_unit_of_measure;
     END IF;

     IF p_track_as_labor_flag = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
     	l_track_as_labor_flag := NULL;
     ELSE
	l_track_as_labor_flag := p_track_as_labor_flag;
     END IF;

--Remove big numbers in case parameters were not passed, default to NULL; Assign Valid
-- Values to local variables.

     IF p_quantity = GMS_BUDGET_PUB.G_PA_MISS_NUM
     THEN
     	l_quantity := null;
      ELSE
	l_quantity := p_quantity;
      END IF;

     IF p_raw_cost = GMS_BUDGET_PUB.G_PA_MISS_NUM
     THEN
     	l_raw_cost := null;
      ELSE
	l_raw_cost := p_raw_cost;
      END IF;

     IF p_burdened_cost = GMS_BUDGET_PUB.G_PA_MISS_NUM
     THEN
     	l_burdened_cost := null;
      ELSE
	l_burdened_cost := p_burdened_cost;
      END IF;
---------------------------

     IF (p_quantity IS NULL AND p_raw_cost IS NULL AND p_burdened_cost IS NULL AND l_budget_amount_code = 'C')
     THEN
	NULL;  --we don't insert budget lines with all zero's
     ELSE

   begin
	select resource_assignment_id
	into   l_resource_assignment_id
	from   gms_resource_assignments
	where  budget_version_id = l_budget_version_id
	and    project_id = l_project_id
	and    NVL(task_id, 0) = NVL(l_task_id, 0) -- was p_pa_task_id
	and    resource_list_member_id = p_resource_list_member_id;

   exception
	   when NO_DATA_FOUND then
              x_err_stage := 'create new resource assignment <'
		    || to_char(l_budget_version_id) || '><'
		    || to_char(l_project_id) || '><'
		    || to_char(l_task_id) || '><'
		    || to_char(p_resource_list_member_id)
		    || '>';

	      select gms_resource_assignments_s.nextval
	      into   l_resource_assignment_id
	      from   sys.dual;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after selecting from sequence');

	      -- create a new resource assignment
              insert into gms_resource_assignments
	             (resource_assignment_id,
	              budget_version_id,
	              project_id,
	              task_id,
	              resource_list_member_id,
	              last_update_date,
	              last_updated_by,
	              creation_date,
	              created_by,
	              last_update_login,
	              unit_of_measure,
	              track_as_labor_flag)
                 values ( l_resource_assignment_id,
	                l_budget_version_id,
	                l_project_id,
	                l_task_id,
--	                p_resource_list_member_id, commented for bug 3891250
			l_member_id,      -- Added for bug 3891250
	                SYSDATE,
			l_user_id,
	                SYSDATE,
			l_user_id,
			l_login_id,
	                l_unit_of_measure,
	                l_track_as_labor_flag);

	   when OTHERS then
		gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
					x_token_name1 => 'SQLCODE',
					x_token_val1 => sqlcode,
					x_token_name2 => 'SQLERRM',
					x_token_val2 => sqlerrm,
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
   end ;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after insert into gms_resource_assignments');

    -- Copy raw cost into burdened cost if budrened cost is null.
    -- If the resource UOM is currency and raw cost is null then
    -- copy value of quantity amt into raw cost and also set quantity
    -- amt to null.

     if gms_budget_utils.get_budget_amount_code(p_budget_type_code) = 'C' then
        -- Cost Budget

       if gms_budget_utils.check_currency_uom(p_unit_of_measure) = 'Y' then

         if l_raw_cost is null then
           l_raw_cost := l_quantity;
          end if;
          l_quantity := null;
       end if;

       if  l_burdened_cost is null then
          l_burdened_cost := l_raw_cost;
       end if;

     end if;

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - before insert into gms_budget_lines');

     insert into gms_budget_lines
	       (resource_assignment_id,
	        start_date,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
	        end_date,
	        period_name,
	        quantity,
	        raw_cost,
	        burdened_cost,
                change_reason_code,
                description,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
		pm_product_code,
		pm_budget_line_reference,
		quantity_source,
		raw_cost_source,
		burdened_cost_source
                )
             values (
		l_resource_assignment_id,
	        l_budget_start_date,
		SYSDATE,
		l_user_id,
                SYSDATE,
		l_user_id,
		l_login_id,
	        l_budget_end_date,
	        l_period_name,
	        l_quantity,
	        pa_currency.round_currency_amt(l_raw_cost),
	        pa_currency.round_currency_amt(l_burdened_cost),
--                p_change_reason_code,
		NULL, -- change_reason_code only applicable upon update
	        l_description,
                l_attribute_category,
                l_attribute1,
                l_attribute2,
                l_attribute3,
                l_attribute4,
                l_attribute5,
                l_attribute6,
                l_attribute7,
                l_attribute8,
                l_attribute9,
                l_attribute10,
                l_attribute11,
                l_attribute12,
                l_attribute13,
                l_attribute14,
                l_attribute15,
		p_pm_product_code,
		p_pm_budget_line_reference,
		p_quantity_source,
		p_raw_cost_source,
		p_burdened_cost_source
                 );

-- dbms_output.put_line('GMS_BUDGET_PUB.ADD_BUDGET_LINE - after insert into gms_budget_lines');

     end if;

-------------------------------------------------------------------------------------------

-- check for overlapping dates
-- Added the following IF Stmt for Bug: 2791285

    if l_budget_entry_method_rec.time_phased_type_code in ('G','P','R') then

      gms_budget_utils.check_overlapping_dates( x_budget_version_id => l_budget_version_id		--IN
    						  ,x_resource_name	=> l_resource_name		--OUT
    						  ,x_err_code		=> x_err_code		);

      IF x_err_code <> 0
      THEN
  	gms_error_pkg.gms_message(x_err_name => 'GMS_CHECK_DATES_FAILED',
  				x_err_code => x_err_code,
  				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

   end if; -- Time Phased type code

-- summarizing the totals in the table gms_budget_versions

    GMS_BUDGET_PUB.summerize_project_totals( x_budget_version_id => l_budget_version_id
    					    , x_err_code	  => x_err_code
					    , x_err_stage	  => x_err_stage
					    , x_err_stack	  => x_err_stack		);

--   dbms_output.put_line('After summerize_project_totals');
--   dbms_output.put_line('Error code: '||l_err_code);
--   dbms_output.put_line('Error Stage: '||l_err_stage);
--   dbms_output.put_line('Error Stack: '||l_err_stack);


    IF x_err_code <> 0
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_SUMMERIZE_TOTALS_FAILED',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

------------------------------------------------------------------------------------
-- Added for Bug:1325015

	validate_budget(  x_budget_version_id => l_budget_version_id,
			    x_award_id => l_award_id,
                            x_project_id => l_project_id,
                            x_task_id => l_task_id,
                            x_resource_list_member_id => p_resource_list_member_id,
                            x_start_date => l_budget_start_date,
                            x_end_date => l_budget_end_date,
                            x_return_status => x_err_code);

	if x_err_code <> 0 then
		ROLLBACK TO add_budget_line_pub;
	end if;
 -- Commented out this call for GMS enhancement : 5583170 as we don't validates across awards with this enahncement.

/*	validate_budget_mf(  x_budget_version_id => l_budget_version_id,
			    x_award_id => l_award_id,
                            x_project_id => l_project_id,
                            x_task_id => l_task_id,
                            x_resource_list_member_id => p_resource_list_member_id,
                            x_start_date => l_budget_start_date,
                            x_end_date => l_budget_end_date,
                            x_return_status => x_err_code);

	if x_err_code <> 0 then
		ROLLBACK TO add_budget_line_pub;
	end if;
*/
------------------------------------------------------------------------------------


    IF FND_API.TO_BOOLEAN( p_commit )
    THEN
	COMMIT;
    END IF;

   x_err_stack := l_old_stack;

EXCEPTION

	WHEN OTHERS
	THEN
		-- Bug 1831151 : Commented out NOCOPY the following line and added simple roll back statement as
		-- the copy actual functionality was erroring out NOCOPY with error 'save point never established'
		-- ROLLBACK to add_budget_line_pub ;
		ROLLBACK ;
		RAISE;

END add_budget_line;


----------------------------------------------------------------------------------------
-- Name:               delete_draft_budget
-- Type:               Procedure
-- Description:        This procedure can be used to delete a draft budget
--
--
-- Called subprograms:
--
--
--
--History:
--

PROCEDURE delete_draft_budget
( p_api_version_number			IN	NUMBER
 ,x_err_code				IN OUT NOCOPY	NUMBER
 ,x_err_stage				IN OUT NOCOPY	VARCHAR2
 ,x_err_stack				IN OUT NOCOPY	VARCHAR2
 ,p_commit				IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id				IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id				IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	)

IS

   CURSOR l_budget_version_csr
   	 ( p_project_id NUMBER
   	 , p_award_id NUMBER
   	 , p_budget_type_code VARCHAR2	)
   IS
   SELECT budget_version_id
   FROM gms_budget_versions
   WHERE project_id = p_project_id
   AND   award_id   = p_award_id
   AND   budget_type_code = p_budget_type_code
   AND   budget_status_code in ('W','S');-- Bug 1831122

   CURSOR l_budget_type_csr
   	 ( p_budget_type_code VARCHAR2 )
   IS
   SELECT 1
   FROM   pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;


   CURSOR l_lock_budget_csr( p_budget_version_id NUMBER )
   IS
   SELECT 'x'
   FROM   gms_budget_versions bv
   ,      gms_resource_assignments ra
   ,      gms_budget_lines bl
   WHERE  bv.budget_version_id = p_budget_version_id
   AND    bv.budget_version_id = ra.budget_version_id (+)
   AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
   FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;

   l_api_name		CONSTANT	VARCHAR2(30) 		:= 'delete_draft_budget';
   i					NUMBER;
   l_dummy				NUMBER;
   l_budget_version_id			NUMBER;
   l_award_id				NUMBER;
   l_project_id				NUMBER;
   l_budget_type_code			VARCHAR2(30);
   l_function_allowed			VARCHAR2(1);
   l_resp_id				NUMBER := 0;
   l_user_id		                NUMBER := 0;
   l_module_name                        VARCHAR2(80);
   l_old_stack				VARCHAR2(630);

BEGIN

	x_err_code := 0;
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> Delete_Draft_Budget';

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;

--  Standard begin of API savepoint

    SAVEPOINT delete_draft_budget_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

--  product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
    THEN

   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
		return;
	END IF;
    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
--------------------------------------------------------------------------------

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_module_name := 'GMS_PM_DELETE_DRAFT_BUDGET';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- need to call the gms_security package
    -- If a user does not have privileges to update the award, then
    -- cannot delete a budget

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

-----------------------------------------------------------------------------

-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			return;
    		END IF;

	ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_NUM_ID_MISSING',
         				x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
-------------------------------------------------------------------------------

      -- Now verify whether award security allows the user to update
      -- award
      -- If a user does not have privileges to update the award, then
      -- cannot delete a budget

      IF gms_security.allow_query (x_award_id => l_award_id ) = 'N' THEN

         -- The user does not have query privileges on this award
         -- Hence, cannot update the award. Raise error

	gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_QRY',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF gms_security.allow_update (x_award_id => l_award_id ) = 'N' THEN

            -- The user does not have update privileges on this award
            -- Hence , raise error
		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_UPD',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;
     END IF;


-- budget code is mandatory

     IF p_budget_type_code IS NULL
     OR p_budget_type_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE
     		OPEN l_budget_type_csr( p_budget_type_code );

		FETCH l_budget_type_csr INTO l_dummy;

		IF l_budget_type_csr%NOTFOUND
		THEN
			CLOSE l_budget_type_csr;
			gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_INVALID',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		CLOSE l_budget_type_csr;

     END IF;



--  get the corresponding budget_version_id

    OPEN l_budget_version_csr
    	(p_project_id 		=> l_project_id
    	,p_award_id             => l_award_id
    	,p_budget_type_code	=> p_budget_type_code );

    FETCH l_budget_version_csr INTO l_budget_version_id;

    IF l_budget_version_csr%NOTFOUND
    THEN

	CLOSE l_budget_version_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_VERSION',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    CLOSE l_budget_version_csr;

    OPEN l_lock_budget_csr( l_budget_version_id );


-----------------------------------------------------------------------------

/**	for b1_rec in (	select rowid
		from gms_budget_lines
		where resource_assignment_id
		in
			(select resource_assignment_id
			from gms_resource_assignments
			where budget_version_id = l_budget_version_id))
**/
	for b1_rec in ( select 	gbl.rowid,
				gra.resource_list_member_id,
				gra.task_id,
				gbl.start_date,
				gbl.period_name
			from 	gms_resource_assignments gra,
				gms_budget_lines gbl
			where	gbl.resource_assignment_id = gra.resource_assignment_id
			and	gra.budget_version_id = l_budget_version_id )

	loop

		gms_budget_pub.delete_budget_line
		( p_api_version_number => 1.0
		 ,p_pm_product_code => 'GMS'
		 ,p_project_id => l_project_id
		 ,p_award_id => l_award_id
		 ,p_budget_type_code =>	p_budget_type_code
		 ,p_task_id => 	b1_rec.task_id
		 ,p_resource_list_member_id => b1_rec.resource_list_member_id
		 ,p_start_date => b1_rec.start_date
		 ,p_period_name	=> b1_rec.period_name
		 ,x_err_code => x_err_code
		 ,x_err_stage => x_err_stage
		 ,x_err_stack => x_err_stack);

	if x_err_code <> 0
	then
		gms_error_pkg.gms_message(x_err_name => 'GMS_DELETE_BUDGET_LINE_FAIL',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	end if;

	end loop;

	begin
		delete gms_budget_versions
		where budget_version_id = l_budget_version_id;
	exception
	when NO_DATA_FOUND
	then
		gms_error_pkg.gms_message(x_err_name => 'GMS_DELETE_DRAFT_FAIL',
			x_err_code => x_err_code,
			x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	end;

    --!!! temporary solution, because delete_draft has commit

    SAVEPOINT delete_draft_budget_pub;

    CLOSE l_lock_budget_csr; --FYI, does not release locks

    IF fnd_api.to_boolean(p_commit)
    THEN
    	COMMIT;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
		ROLLBACK TO delete_draft_budget_pub;
		RAISE;

END delete_draft_budget;


----------------------------------------------------------------------------------------
-- Name:               delete_budget_line
-- Type:               Procedure
-- Description:        This procedure can be used to delete a budget_line of a draft budget
--
--
-- Called subprograms:
--
--
--
-- History:
--
--

PROCEDURE delete_budget_line
( p_api_version_number			IN	NUMBER
 ,x_err_code				IN OUT NOCOPY	NUMBER
 ,x_err_stage				IN OUT NOCOPY	VARCHAR2
 ,x_err_stack				IN OUT NOCOPY	VARCHAR2
 ,p_commit				IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id				IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id				IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_task_id				IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_task_number				IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_alias			IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id		IN	NUMBER		:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_start_date				IN	DATE		:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_period_name				IN	VARCHAR2	:= GMS_BUDGET_PUB.G_PA_MISS_CHAR	)

IS

   CURSOR l_budget_version_csr
   	 ( p_project_id NUMBER
   	 , p_award_id   NUMBER
   	 , p_budget_type_code VARCHAR2	)
   IS
   SELECT budget_version_id
   ,      resource_list_id
   ,	  budget_entry_method_code
   FROM   gms_budget_versions
   WHERE  project_id = p_project_id
   AND    award_id   = p_award_id
   AND    budget_type_code = p_budget_type_code
   AND    budget_status_code in ('W','S');--Bug 1831122

   CURSOR l_budget_type_csr
   	 ( p_budget_type_code VARCHAR2 )
   IS
   SELECT 1
   FROM   pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;

   CURSOR l_resource_assignment_csr
   	  (p_budget_version_id	NUMBER
   	  ,p_task_id		NUMBER
   	  ,p_member_id		NUMBER	)
   IS
   SELECT resource_assignment_id
   FROM   gms_resource_assignments
   WHERE  budget_version_id = p_budget_version_id
   AND	  task_id = p_task_id
   AND	  resource_list_member_id = p_member_id;

   CURSOR l_budget_line_rowid_csr
   	 ( p_resource_assignment_id NUMBER
   	 , p_start_date		    DATE	)
   IS
   SELECT rowidtochar(rowid)
   FROM   gms_budget_lines
   WHERE  resource_assignment_id = p_resource_assignment_id
   AND    trunc(start_date) = nvl(trunc(p_start_date),trunc(start_date));

   CURSOR l_uncategorized_list_csr
   IS
   SELECT prlm.resource_list_member_id
   FROM   pa_resource_lists prl
   ,      pa_resource_list_members prlm
   ,	  pa_implementations pi
   WHERE  prl.resource_list_id = prlm.resource_list_id
   AND	  prl.business_group_id = pi.business_group_id
   AND    prl.uncategorized_flag='Y'
   and    NVL(prl.migration_code,'M') ='M' -- Bug 3626671
   and    NVL(prlm.migration_code,'M') ='M'; -- Bug 3626671;

   -- needed to get the start_date of a period

   CURSOR	l_budget_entry_method_csr
		(p_budget_entry_method_code	VARCHAR2)
   IS
   SELECT time_phased_type_code
   FROM	  pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code;

   -- needed to get the budget_start_date of a period

   CURSOR	l_budget_periods_csr
   		(p_period_name 			VARCHAR2
   		,p_time_phased_type_code	VARCHAR2	)
   IS
   SELECT trunc(period_start_date), trunc(period_end_date) -- added end_date which is required in validate_budget()
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND 	  period_type_code = p_time_phased_type_code;

   --needed to validate to given start_date

   CURSOR	l_start_date_csr
		(p_start_date			DATE
		,p_time_phased_type_code	VARCHAR2	)
   IS
   SELECT 1
   FROM   pa_budget_periods_v
   WHERE  trunc(period_start_date) = trunc(p_start_date)
   AND	  period_type_code = p_time_phased_type_code;

   --needed to lock the budget line row
   CURSOR l_lock_budget_line_csr( p_budget_line_rowid VARCHAR2)
   IS
   SELECT 'x'
   FROM   gms_budget_lines
   WHERE  rowid = p_budget_line_rowid
   FOR UPDATE NOWAIT;

   l_api_name		CONSTANT	VARCHAR2(30) 		:= 'delete_budget_line';
   i					NUMBER;
   l_dummy				NUMBER;
   l_budget_version_id			NUMBER;
   l_project_id				NUMBER;
   l_award_id				NUMBER;
   l_budget_type_code			VARCHAR2(30);
   l_resource_list_id			NUMBER;
   l_task_id				NUMBER;
   l_resource_list_member_id		NUMBER;
   l_budget_line_rowid			VARCHAR2(20);
   l_alias_not_found_ok	CONSTANT	VARCHAR2(1)		:= 'N';
   l_start_date				DATE;
   l_end_date				DATE;
   l_budget_entry_method_code		VARCHAR2(30);
   l_time_phased_type_code		VARCHAR2(30);
   l_function_allowed		        VARCHAR2(1);
   l_resp_id			        NUMBER := 0;
   l_user_id		                NUMBER := 0;
   l_login_id		                NUMBER := 0;
   l_module_name                        VARCHAR2(80);

   l_raw_cost				NUMBER;
   l_burdened_cost			NUMBER;
   l_quantity				NUMBER;
   l_resource_assignment_id		NUMBER;
   l_track_as_labor_flag		VARCHAR2(2);
   l_last_updated_by			NUMBER;
   l_last_update_login			NUMBER;

   l_old_stack				VARCHAR2(630);

BEGIN

	x_err_code := 0;
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> Delete_Budget_Line';

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;

--  Standard begin of API savepoint

    SAVEPOINT delete_budget_line_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

--  product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_IS_MISSING',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
    THEN
   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
		return;
	END IF;
    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
--------------------------------------------------------------------------------

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_login_id := FND_GLOBAL.Login_id;
    l_module_name := 'GMS_PM_DELETE_BUDGET_LINE';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- need to call the gms_security package
    -- If a user does not have privileges to update the award, then
    -- cannot delete a budget line

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

-----------------------------------------------------------------------------

-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			return;
    		END IF;

	ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_NUM_ID_MISSING',
 					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
-------------------------------------------------------------------------------

      -- Now verify whether award security allows the user to update
      -- award
      -- If a user does not have privileges to update the award, then
      -- cannot delete a budget line

      IF gms_security.allow_query (x_award_id => l_award_id ) = 'N' THEN

         -- The user does not have query privileges on this award
         -- Hence, cannot update the award. Raise error
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_QRY',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF gms_security.allow_update (x_award_id => l_award_id ) = 'N' THEN

            -- The user does not have update privileges on this award
            -- Hence , raise error

		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_UPD',
 					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

        END IF;
     END IF;


-- budget code is mandatory

     IF p_budget_type_code IS NULL
     OR p_budget_type_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_MISSING',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
     ELSE
     		OPEN l_budget_type_csr( p_budget_type_code );

		FETCH l_budget_type_csr INTO l_dummy;

		IF l_budget_type_csr%NOTFOUND
		THEN
			CLOSE l_budget_type_csr;
			x_err_code := 10;
			fnd_message.set_name('GMS','GMS_BUDGET_TYPE_IS_INVALID');
			return;
		END IF;

		CLOSE l_budget_type_csr;

     END IF;


--  get the corresponding budget_version_id
    OPEN l_budget_version_csr
    	(p_project_id 		=> l_project_id
    	,p_award_id		=> l_award_id
    	,p_budget_type_code	=> p_budget_type_code );

    FETCH l_budget_version_csr INTO l_budget_version_id
				  , l_resource_list_id
				  , l_budget_entry_method_code;

    IF l_budget_version_csr%NOTFOUND
    THEN
	CLOSE l_budget_version_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_VERSION',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_budget_version_csr;

-- convert pm_task_reference to pa_task_id
-- if both task_id and task_reference are not passed or NULL, then we will default to 0, because this
-- is the value of task_id when budgetting is done at the project level.

   IF (p_task_id = GMS_BUDGET_PUB.G_PA_MISS_NUM
       OR p_task_id IS NULL OR p_task_id = 0)
   AND (p_task_number = GMS_BUDGET_PUB.G_PA_MISS_CHAR
        OR p_task_number IS NULL )

   THEN

   	l_task_id := 0;

   ELSE
	convert_tasknum_to_id ( p_project_id_in => l_project_id
				,p_task_id_in => p_task_id
				,p_task_number_in => p_task_number
				,p_task_id_out => l_task_id
				,x_err_code => x_err_code
				,x_err_stage => x_err_stage
				,x_err_stack => x_err_stack);
	IF x_err_code <> 0
	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_TASK_VALIDATE_FAIL',  -- jjj - check message tag
 					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;
   END IF;

-- convert resource alias to (resource) member id if passed and NOT NULL

    -- convert resource alias to (resource) member id

    -- if resource alias is (passed and not NULL)
    -- and resource member is (passed and not NULL)
    -- then we convert the alias to the id
    -- else we default to the uncategorized resource member

   IF (p_resource_alias <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_resource_alias IS NOT NULL)
   OR (p_resource_list_member_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
       AND p_resource_list_member_id IS NOT NULL)
   THEN
     	convert_listmem_alias_to_id
     		(p_resource_list_id_in	=> l_resource_list_id 	-- IN
	     	,p_reslist_member_alias_in => p_resource_alias 	-- IN
	     	,p_resource_list_member_id_in => p_resource_list_member_id
	     	,p_resource_list_member_id_out	=> l_resource_list_member_id
	     	,x_err_code => x_err_code
	     	,x_err_stage => x_err_stage
	     	,x_err_stack => x_err_stack);

     	IF x_err_code <> 0
     	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_RES_VALIDATE_FAIL',
 					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
     	END IF;

    ELSE

   	   OPEN l_uncategorized_list_csr;
   	   FETCH l_uncategorized_list_csr INTO l_resource_list_member_id;
   	   CLOSE l_uncategorized_list_csr;

   END IF;


   OPEN l_resource_assignment_csr
   	(l_budget_version_id
   	,l_task_id
   	,l_resource_list_member_id);

   FETCH l_resource_assignment_csr INTO l_resource_assignment_id;

   IF l_resource_assignment_csr%NOTFOUND
   THEN
	CLOSE l_resource_assignment_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_RESOURCE_ASSIGNMENT',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   CLOSE l_resource_assignment_csr;

   OPEN l_budget_entry_method_csr( p_budget_entry_method_code => l_budget_entry_method_code );
   FETCH l_budget_entry_method_csr INTO l_time_phased_type_code;
   CLOSE l_budget_entry_method_csr;


   IF p_period_name IS NOT NULL
   AND p_period_name <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
   THEN


	OPEN l_budget_periods_csr( p_period_name => p_period_name
				 , p_time_phased_type_code => l_time_phased_type_code );

	FETCH l_budget_periods_csr INTO l_start_date, l_end_date;

      	IF l_budget_periods_csr%NOTFOUND
   	THEN
		CLOSE l_budget_periods_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_PERIOD_NAME_INVALID',
 					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
   	END IF;
	CLOSE l_budget_periods_csr;

   ELSIF p_start_date IS NOT NULL
   AND   p_start_date <> GMS_BUDGET_PUB.G_PA_MISS_DATE
   THEN

--  Condition for 'G' or 'P' time-phased-type code as only
--  required for period phased budgets.

         IF (l_time_phased_type_code IN ('G', 'P') )  THEN

	OPEN l_start_date_csr(   p_start_date			=> p_start_date
			 	,p_time_phased_type_code	=> l_time_phased_type_code );

	FETCH l_start_date_csr INTO l_dummy;

   	IF l_start_date_csr%NOTFOUND
   	THEN
		CLOSE l_start_date_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_START_DATE_INVALID',
 					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
   	END IF;

	CLOSE l_start_date_csr;

	END IF;

	l_start_date := p_start_date;
   ELSE
	l_start_date := NULL;  	--when no start_date or period_name is passed or both are NULL
				--, then all periods will be deleted
   END IF;


   OPEN l_budget_line_rowid_csr( l_resource_assignment_id
   				,l_start_date			);

   FETCH l_budget_line_rowid_csr INTO l_budget_line_rowid;

   IF l_budget_line_rowid_csr%NOTFOUND
   THEN
	CLOSE l_budget_line_rowid_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_LINE_NOT_FOUND',
 				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;


   WHILE l_budget_line_rowid_csr%FOUND LOOP

   	BEGIN

	OPEN l_lock_budget_line_csr( l_budget_line_rowid );
	CLOSE l_lock_budget_line_csr;

	select 	l.raw_cost,
		l.burdened_cost,
		l.quantity,
		l.resource_assignment_id,
		a.track_as_labor_flag
	into	l_raw_cost,
		l_burdened_cost,
		l_quantity,
		l_resource_assignment_id,
		l_track_as_labor_flag
	from 	gms_resource_assignments a,
		gms_budget_lines l
	where 	l.rowid = l_budget_line_rowid
	and 	l.resource_assignment_id = a.resource_assignment_id;

	delete from gms_budget_lines
	where rowid = l_budget_line_rowid;

	l_last_updated_by := fnd_global.user_id;
	l_last_update_login := fnd_global.login_id;

	select 	budget_version_id
	into 	l_budget_version_id
	from 	gms_resource_assignments
	where	resource_assignment_id = l_resource_assignment_id;

    -- clean up gms_resource_assignments if necessary

	delete gms_resource_assignments
	where  resource_assignment_id = l_resource_assignment_id
	and    not exists
	       (select 1
	        from   gms_budget_lines
	        where  resource_assignment_id = l_resource_assignment_id);

       -- Update gms_budget_versions only if the denormalized totals are
       -- not being maintained in the form. Example the Copy Actual
       -- process.

	update gms_budget_versions
	set    	raw_cost = pa_currency.round_currency_amt(nvl(raw_cost,0) - nvl(l_raw_cost,0) ),
		burdened_cost = pa_currency.round_currency_amt(nvl(burdened_cost,0) - nvl(l_burdened_cost,0) ),
		labor_quantity = (to_number(
			      decode(l_track_as_labor_flag,
			         'Y', nvl(labor_quantity,0) - nvl(l_quantity,0),
			          nvl(labor_quantity,0))) ),
	   last_update_date = SYSDATE,
	   last_update_login = l_last_update_login,
	   last_updated_by = l_last_updated_by
     where  budget_version_id = l_budget_version_id;

	    if (SQL%NOTFOUND) then
	      Raise NO_DATA_FOUND;
	    end if;
--end if;

--------------------------------------------------------------------------------



	--this exception part is here because this procedure doesn't handle the exceptions itself.
   	EXCEPTION

   	WHEN ROW_ALREADY_LOCKED THEN RAISE;

	WHEN OTHERS
	THEN
		CLOSE l_budget_line_rowid_csr;

		gms_error_pkg.gms_message(x_err_name => 'GMS_UNEXPECTED_ERROR',
					x_token_name1 => 'SQLCODE',
					x_token_val1 => sqlcode,
					x_token_name2 => 'SQLERRM',
					x_token_val2 => sqlerrm,
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

	END;

   	FETCH l_budget_line_rowid_csr INTO l_budget_line_rowid;

   END LOOP;

   CLOSE l_budget_line_rowid_csr;


--summarizing the totals in the table gms_budget_versions

    GMS_BUDGET_PUB.summerize_project_totals( x_budget_version_id => l_budget_version_id
    					    , x_err_code	  => x_err_code
					    , x_err_stage	  => x_err_stage
					    , x_err_stack	  => x_err_stack		);


    IF x_err_code <> 0
    THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_SUMMERIZE_TOTALS_FAILED',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

------------------------------------------------------------------------------------
-- Added for Bug:1325015

	validate_budget(  x_budget_version_id => l_budget_version_id,
			    x_award_id => l_award_id,
                            x_project_id => l_project_id,
                            x_task_id => l_task_id,
                            x_resource_list_member_id => p_resource_list_member_id,
                            x_start_date => l_start_date,
                            x_end_date => l_end_date,
                            x_return_status => x_err_code);

	if x_err_code <> 0 then
		ROLLBACK TO delete_budget_line_pub;
	end if;
 -- Commented out this call for GMS enhancement : 5583170 as we don't validates across awards with this enahncement.
/*
	validate_budget_mf(  x_budget_version_id => l_budget_version_id,
			    x_award_id => l_award_id,
                            x_project_id => l_project_id,
                            x_task_id => l_task_id,
                            x_resource_list_member_id => p_resource_list_member_id,
                            x_start_date => l_start_date,
                            x_end_date => l_end_date,
                            x_return_status => x_err_code);

	if x_err_code <> 0 then
		ROLLBACK TO delete_budget_line_pub;
	end if;
*/
------------------------------------------------------------------------------------

    IF fnd_api.to_boolean(p_commit)
    THEN
    	COMMIT;
    END IF;

	x_err_stack := l_old_stack;

EXCEPTION
	WHEN OTHERS
	THEN
		ROLLBACK TO delete_budget_line_pub;
		RAISE;

END delete_budget_line;

----------------------------------------------------------------------------------------
-- Name:               update_budget
-- Type:               Procedure
-- Description:        This procedure can be used to update a working budget.
--
-- Called subprograms:
--
--
--
-- History:
--

PROCEDURE update_budget
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY 	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_status_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_version_number		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_current_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_original_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_current_original_flag	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_accumulated_flag	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_version_name		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_entry_method_code	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_baselined_by_person_id	IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_baselined_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_quantity			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_unit_of_measure		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_burdened_cost		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_first_budget_period		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_wf_status_code 		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR)

IS


   --needed to check the validity of the incoming budget type

   CURSOR l_budget_type_csr
   	  (p_budget_type_code	VARCHAR2 )
   IS
   SELECT budget_amount_code
   FROM	  pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;

   --needed to check whether budget line already exists

   CURSOR l_budget_line_csr
   	  (p_resource_assignment_id NUMBER
   	  ,p_budget_start_date	   DATE )
   IS
   SELECT 'X'
   FROM   gms_budget_lines
   WHERE  resource_assignment_id = p_resource_assignment_id
   AND    start_date = p_budget_start_date;

   --needed to get the current budget version data

   CURSOR l_budget_version_csr
          ( p_project_id NUMBER
          , p_award_id NUMBER
          , p_budget_type_code VARCHAR2 )
   IS
   SELECT budget_version_id
   ,      budget_entry_method_code
   ,      resource_list_id
   ,      change_reason_code
   ,      description
   FROM   gms_budget_versions
   WHERE  project_id 		= p_project_id
   AND    award_id              = p_award_id
   AND    budget_type_code	= p_budget_type_code
   AND    budget_status_code	in ('W','S');

   --needed to get the current budget entry method data

   CURSOR l_budget_entry_method_csr
          ( p_budget_entry_method_code VARCHAR2)
   IS
   SELECT time_phased_type_code
   ,	  entry_level_code
   ,	  categorization_code
   FROM   pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code;

   --needed to get the resource assignment for this budget_version / task / member combination

   CURSOR l_resource_assignment_csr
   	  (p_budget_version_id	NUMBER
   	  ,p_task_id		NUMBER
   	  ,p_member_id		NUMBER	)
   IS
   SELECT resource_assignment_id
   FROM   gms_resource_assignments
   WHERE  budget_version_id = p_budget_version_id
   AND	  task_id = p_task_id
   AND	  resource_list_member_id = p_member_id;

   -- needed to get the budget_start_date of a period

   CURSOR	l_budget_periods_csr
   		(p_period_name 		VARCHAR2
   		,p_period_type_code	VARCHAR2	)
   IS
   SELECT period_name
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND 	  period_type_code = p_period_type_code;

   -- the uncategorized resource list

   CURSOR l_uncategorized_list_csr
   IS
   SELECT prlm.resource_list_member_id
   FROM   pa_resource_lists prl
   ,      pa_resource_list_members prlm
   ,	  pa_implementations pi
   WHERE  prl.resource_list_id = prlm.resource_list_id
   AND	  prl.business_group_id = pi.business_group_id
   AND    prl.uncategorized_flag='Y'
   and    NVL(prl.migration_code,'M') ='M' -- Bug 3626671
   and    NVL(prlm.migration_code,'M') ='M'; -- Bug 3626671;


   CURSOR	l_budget_change_reason_csr ( p_change_reason_code VARCHAR2 )
   IS
   SELECT 'x'
   FROM   pa_lookups
   WHERE  lookup_type = 'BUDGET CHANGE REASON'
   AND    lookup_code = p_change_reason_code;

   --needed for locking of budget rows

   CURSOR l_lock_budget_csr( p_budget_version_id NUMBER )
   IS
   SELECT 'x'
   FROM   gms_budget_versions bv
   ,      gms_resource_assignments ra
   ,      gms_budget_lines bl
   WHERE  bv.budget_version_id = p_budget_version_id
   AND    bv.budget_version_id = ra.budget_version_id (+)
   AND    ra.resource_assignment_id = bl.resource_assignment_id (+)
   FOR UPDATE OF bv.budget_version_id,ra.budget_version_id,bl.resource_assignment_id NOWAIT;

   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'update_budget';


   l_project_id					NUMBER;
   l_task_id					NUMBER;
   l_award_id					NUMBER;
   l_dummy					VARCHAR2(1);
   l_budget_version_id				NUMBER;
   l_budget_entry_method_code			VARCHAR2(30);
   l_change_reason_code				VARCHAR2(30);
   l_description				VARCHAR2(255);
   l_budget_line_index				NUMBER;
--   l_budget_line_in_rec				gms_budget_pub.budget_line_in_rec_type;
   l_time_phased_type_code			VARCHAR2(30);
   l_resource_assignment_id			NUMBER;
   l_budget_start_date				DATE;
   l_resource_list_id				NUMBER;
   l_resource_list_member_id			NUMBER;
   l_resource_name				pa_resource_list_members.alias%type; /*Changed for bug 4614242*/
   l_budget_amount_code				VARCHAR2(30);
   l_entry_level_code				VARCHAR2(30);
   l_categorization_code			VARCHAR2(30);
   l_resp_id					NUMBER := 0;
   l_user_id		                        NUMBER := 0;
   l_login_id					NUMBER := 0;
   l_baselined_by_person_id			NUMBER;
   l_baselined_date				DATE;
   l_module_name                                VARCHAR2(80);

   l_unit_of_measure				pa_resources.unit_of_measure%type;
   l_quantity					NUMBER;
   l_raw_cost					NUMBER;
   l_burdened_cost				NUMBER;
   l_attribute_category				VARCHAR2(30);
   l_attribute1					VARCHAR2(150);
   l_attribute2					VARCHAR2(150);
   l_attribute3					VARCHAR2(150);
   l_attribute4					VARCHAR2(150);
   l_attribute5					VARCHAR2(150);
   l_attribute6					VARCHAR2(150);
   l_attribute7					VARCHAR2(150);
   l_attribute8					VARCHAR2(150);
   l_attribute9					VARCHAR2(150);
   l_attribute10				VARCHAR2(150);
   l_attribute11				VARCHAR2(150);
   l_attribute12				VARCHAR2(150);
   l_attribute13				VARCHAR2(150);
   l_attribute14				VARCHAR2(150);
   l_attribute15				VARCHAR2(150);
   l_first_budget_period			VARCHAR2(30);
   l_wf_status_code 				VARCHAR2(30);
   l_old_stack					VARCHAR2(630);

   --used by dynamic SQL
   l_statement					VARCHAR2(2000);
   l_update_yes_flag				VARCHAR2(1);
   l_cursor_id					NUMBER;
   l_rows					NUMBER;
   l_new_resource_assignment			BOOLEAN;
   l_function_allowed				VARCHAR2(1);
   l_budget_rlmid                               NUMBER;
 /*  l_budget_alias                               VARCHAR2(30);    Commented for bug 4614242 as this is not used anymore */
   l_uncategorized_list_id			NUMBER;
   l_uncategorized_rlmid                        NUMBER;
   l_uncategorized_resid                        NUMBER;
   l_track_as_labor_flag                        VARCHAR2(1);


-- p_multiple_task_msg     VARCHAR2(1) := 'T';

BEGIN

 -- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET - start');

	x_err_code := 0;
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> Update_budget';

--	Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;

--  Standard begin of API savepoint

    SAVEPOINT update_budget_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    --product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
        THEN
   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
		return;
	END IF;
    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
--------------------------------------------------------------------------------
 -- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET - after award info validation');

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_login_id := FND_GLOBAL.Login_id;

    l_module_name := 'GMS_PM_UPDATE_BUDGET';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- need to call the gms_security package
    -- If a user does not have privileges to update the award, then
    -- cannot update a budget

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

---------------------------------------------------------------------------

-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			return;
    		END IF;

	ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_NUM_ID_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
-------------------------------------------------------------------------------
 -- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET - after project info validation');

      -- Now verify whether award security allows the user to update
      -- award
      -- If a user does not have privileges to update the award, then
      -- cannot update a budget

      IF gms_security.allow_query (x_award_id => l_award_id ) = 'N' THEN

         -- The user does not have query privileges on this award
         -- Hence, cannot update the award. Raise error
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_QRY',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available

         IF gms_security.allow_update (x_award_id => l_award_id ) = 'N' THEN

            -- The user does not have update privileges on this award
            -- Hence , raise error

		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_UPD',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END IF;


 -- budget type code is mandatory

     IF p_budget_type_code IS NULL
     OR p_budget_type_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

     ELSE
     		OPEN l_budget_type_csr( p_budget_type_code );

		FETCH l_budget_type_csr INTO l_budget_amount_code;     -- used later for budget lines

		IF l_budget_type_csr%NOTFOUND
		THEN

			CLOSE l_budget_type_csr;
			gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_INVALID',
						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;

		END IF;

		CLOSE l_budget_type_csr;

     END IF;


   OPEN l_budget_version_csr( l_project_id
   			    , l_award_id
   			    , p_budget_type_code );

   FETCH l_budget_version_csr INTO l_budget_version_id
   				 , l_budget_entry_method_code
   				 , l_resource_list_id
   				 , l_change_reason_code
   				 , l_description;

   IF l_budget_version_csr%NOTFOUND
   THEN
	CLOSE l_budget_version_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_VERSION',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   CLOSE l_budget_version_csr;


   OPEN l_budget_entry_method_csr(l_budget_entry_method_code);

   FETCH l_budget_entry_method_csr into l_time_phased_type_code,
					l_entry_level_code,
					l_categorization_code;
   CLOSE l_budget_entry_method_csr;

 -- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET - after locking budget');
-----------------------------------------------------------------------------------------
-- Start of change for Bug:2830539

-- Validate the Change Reason Code passed in as a parameter

     IF (p_change_reason_code <> GMS_BUDGET_PUB.G_PA_MISS_CHAR) THEN

	OPEN l_budget_change_reason_csr (p_change_reason_code);
	FETCH l_budget_change_reason_csr INTO l_dummy;

	IF l_budget_change_reason_csr%NOTFOUND THEN

       	CLOSE l_budget_change_reason_csr;
        	gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_CHANGE_REASON',
               	                 x_err_code => x_err_code,
               	                 x_err_buff => x_err_stage);

        	APP_EXCEPTION.RAISE_EXCEPTION;
   	END IF;

       	CLOSE l_budget_change_reason_csr;
     END IF;

-- Validate the Budget Entry Method and Resource List passed in as a parameter.
-- Even if either Budget Entry Method or Resource List is passed in then we
-- have to validate against each other.

     IF ((p_budget_entry_method_code <> GMS_BUDGET_PUB.G_PA_MISS_CHAR) or (p_resource_list_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM)) THEN

	validate_bem_resource_list(p_project_id => l_project_id,
				   p_award_id => l_award_id,
				   p_budget_entry_method_code => p_budget_entry_method_code,
				   p_resource_list_id => p_resource_list_id);

     END IF;

-- Once the above validations have passed update the GMS_BUDGET_VERSIONS table
-- with the appropriate values.

    -- Bug 3104308 : Validation for p_first_budget_period .This will be fired only for
    --               GL/PA budget periods.

    IF  (p_first_budget_period <> GMS_BUDGET_PUB.G_PA_MISS_CHAR AND p_first_budget_period IS NOT NULL
          AND l_time_phased_type_code IN ('G','P')) THEN

       OPEN  l_budget_periods_csr(p_first_budget_period,l_time_phased_type_code);
       FETCH l_budget_periods_csr into l_first_budget_period;
       IF   l_budget_periods_csr%NOTFOUND THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_PERIOD_IS_INVALID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;
    	CLOSE l_budget_periods_csr;
    END IF;

    OPEN l_lock_budget_csr( l_budget_version_id );

    UPDATE  GMS_BUDGET_VERSIONS
    SET     change_reason_code = decode(p_change_reason_code,
                                        GMS_BUDGET_PUB.G_MISS_CHAR,
                                        change_reason_code,
                                        p_change_reason_code),
            budget_entry_method_code = decode(p_budget_entry_method_code,
                                        GMS_BUDGET_PUB.G_MISS_CHAR,
                                        budget_entry_method_code,
                                        p_budget_entry_method_code),
            resource_list_id = decode(p_resource_list_id,
                                      GMS_BUDGET_PUB.G_MISS_NUM,
                                      resource_list_id,
                                      p_resource_list_id),
            current_original_flag = decode(p_current_original_flag,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      current_original_flag,
                                      p_current_original_flag),
            budget_status_code = decode(p_budget_status_code,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      budget_status_code,
                                      p_budget_status_code),
            version_name = decode(p_version_name,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      version_name,
                                      p_version_name),
            description = decode(p_description,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      description,
                                      p_description),
            attribute_category = decode(p_attribute_category,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute_category,
                                      p_attribute_category),
            attribute1 = decode(p_attribute1,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute1,
                                      p_attribute1),
            attribute2 = decode(p_attribute2,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute2,
                                      p_attribute2),
            attribute3 = decode(p_attribute3,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute3,
                                      p_attribute3),
            attribute4 = decode(p_attribute4,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute4,
                                      p_attribute4),
            attribute5 = decode(p_attribute5,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute5,
                                      p_attribute5),
            attribute6 = decode(p_attribute6,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute6,
                                      p_attribute6),
            attribute7 = decode(p_attribute7,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute7,
                                      p_attribute7),
            attribute8 = decode(p_attribute8,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute8,
                                      p_attribute8),
            attribute9 = decode(p_attribute9,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute9,
                                      p_attribute9),
            attribute10 = decode(p_attribute10,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute10,
                                      p_attribute10),
            attribute11 = decode(p_attribute11,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute11),
            attribute12 = decode(p_attribute12,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute12,
                                      p_attribute12),
            attribute13 = decode(p_attribute13,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute13,
                                      p_attribute13),
            attribute14 = decode(p_attribute14,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute14,
                                      p_attribute14),
            attribute15 = decode(p_attribute15,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute15,
                                      p_attribute15),
	    last_update_date = SYSDATE,
	    last_updated_by = G_USER_ID,
	    last_update_login = G_LOGIN_ID,
	    first_budget_period = decode(p_first_budget_period,
	                                 GMS_BUDGET_PUB.G_MISS_CHAR,
					 first_budget_period,
					 p_first_budget_period ) --Bug 3104308 : Added first_budget_period column in update
    WHERE   budget_version_id = l_budget_version_id;

   CLOSE l_lock_budget_csr;

-- End of changes for Bug: 2830539
-------------------------------------------------------------------

-- check for overlapping dates
-- Added the following IF Stmt for Bug: 2791285

   if l_time_phased_type_code in ('G','P','R') then

      gms_budget_utils.check_overlapping_dates( x_budget_version_id 	=> l_budget_version_id		--IN
    						  ,x_resource_name	=> l_resource_name		--OUT
    						  ,x_err_code		=> x_err_code		);

      IF x_err_code <> 0
      THEN
  	  gms_error_pkg.gms_message(x_err_name => 'GMS_CHECK_DATES_FAILED',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	  APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

   end if; -- l_time_phased_type_code

        --summarizing the totals in the table gms_budget_versions

        gms_budget_pub.summerize_project_totals( x_budget_version_id => l_budget_version_id
    	    				        , x_err_code	  => x_err_code
					    	, x_err_stage	  => x_err_stage
					    	, x_err_stack	  => x_err_stack		);



    	IF x_err_code <> 0
    	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_SUMMERIZE_TOTALS_FAILED',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;


--    END IF;  --if there are budget lines


    IF FND_API.TO_BOOLEAN( p_commit )
    THEN
	COMMIT;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION

	WHEN OTHERS
	THEN
		ROLLBACK TO update_budget_pub;
		RAISE;

END update_budget;

----------------------------------------------------------------------------------------
-- Name:               update_budget_line
-- Type:               Procedure
-- Description:        This procedure can be used to update a budgetline of an
--                    existing WORKING budget.
--
--
-- History:
--

PROCEDURE update_budget_line
( p_api_version_number		IN	NUMBER
 ,x_err_code			IN OUT NOCOPY	NUMBER
 ,x_err_stage			IN OUT NOCOPY	VARCHAR2
 ,x_err_stack			IN OUT NOCOPY	VARCHAR2
 ,p_commit			IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_init_msg_list		IN	VARCHAR2 		:= GMS_BUDGET_PUB.G_GMS_FALSE
 ,p_pm_product_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_project_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_project_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_task_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_task_number			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_award_id			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_award_number		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_alias		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_resource_list_member_id	IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_budget_start_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_budget_end_date		IN	DATE			:= GMS_BUDGET_PUB.G_PA_MISS_DATE
 ,p_period_name			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_description			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_burdened_cost		IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_quantity			IN	NUMBER			:= GMS_BUDGET_PUB.G_PA_MISS_NUM
 ,p_unit_of_measure		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_track_as_labor_flag		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute_category		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute1			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute2			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute3			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute4			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute5			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute6			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute7			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute8			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute9			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute10			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute11			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute12			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute13			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute14			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_attribute15			IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_raw_cost_source		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_source	IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 ,p_quantity_source		IN	VARCHAR2		:= GMS_BUDGET_PUB.G_PA_MISS_CHAR
 )
IS


  --and check for valid resource_list / member combination

   CURSOR	l_resource_csr
		(p_resource_list_member_id NUMBER
		,p_resource_list_id	   NUMBER)
   IS
   SELECT 'X'
   FROM   pa_resource_list_members
   WHERE  resource_list_id = p_resource_list_id
   AND    resource_list_member_id = p_resource_list_member_id;

   -- needed to get the fields associated to a budget entry method

   CURSOR	l_budget_entry_method_csr
   		(p_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
   IS
   SELECT *
   FROM   pa_budget_entry_methods
   WHERE  budget_entry_method_code = p_budget_entry_method_code
   AND 	  trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

   -- needed to do validation on mandatory fields for budget lines

   CURSOR	l_budget_amount_code_csr
   		( p_budget_type_code	VARCHAR2 )
   IS
   SELECT budget_amount_code
   FROM	  pa_budget_types
   WHERE  budget_type_code = p_budget_type_code;

   -- Added for Bug:2830539
   -- needed to validate the change reason code for the Budget Line
   CURSOR	l_budget_change_reason_csr ( p_change_reason_code VARCHAR2 )
   IS
   SELECT 'x'
   FROM   pa_lookups
   WHERE  lookup_type = 'BUDGET CHANGE REASON'
   AND    lookup_code = p_change_reason_code;

   -- needed to get the budget_start_date of a period

   CURSOR	l_budget_periods_csr
   		(p_period_name 		VARCHAR2
   		,p_period_type_code	VARCHAR2	)
   IS
   SELECT trunc(period_start_date), trunc(period_end_date)
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND 	  period_type_code = p_period_type_code;


   -- needed to get the related budget_version, entry_method and resource_list

   CURSOR	l_budget_version_csr
   		( p_project_id		NUMBER
   		, p_award_id		NUMBER
   		, p_budget_type_code	VARCHAR2)
   IS
   SELECT budget_version_id
   ,      budget_entry_method_code
   ,      resource_list_id
   FROM   gms_budget_versions
   WHERE  project_id 		= p_project_id
   AND    award_id 	        = p_award_id
   AND	  budget_type_code	= p_budget_type_code
   AND    budget_status_code	IN ('W','S');


   -- needed to get the member id of the uncategorized resource list

   CURSOR l_uncat_list_member_csr
   IS
   SELECT prlm.resource_list_member_id
   FROM   pa_resource_lists prl
   ,      pa_resource_list_members prlm
   ,	  pa_implementations pi
   WHERE  prl.resource_list_id = prlm.resource_list_id
   AND    prl.business_group_id = pi.business_group_id
   AND    prl.uncategorized_flag='Y'
   and    NVL(prl.migration_code,'M') ='M' -- Bug 3626671
   and    NVL(prlm.migration_code,'M') ='M'; -- Bug 3626671;



   --needed to get the resource assignment for this budget_version / task / member combination

   CURSOR l_resource_assignment_csr
   	  (p_budget_version_id	NUMBER
   	  ,p_task_id		NUMBER
   	  ,p_member_id		NUMBER	)
   IS
   SELECT resource_assignment_id
   FROM   gms_resource_assignments
   WHERE  budget_version_id = p_budget_version_id
   AND	  task_id = p_task_id
   AND	  resource_list_member_id = p_member_id;


   --needed to check whether budget line already exists

   CURSOR l_budget_line_csr
   	  (p_resource_assigment_id NUMBER
   	  ,p_budget_start_date	   DATE )
   IS
   SELECT rowidtochar(rowid)
   FROM   gms_budget_lines
   WHERE  resource_assignment_id = p_resource_assigment_id
   AND    trunc(start_date) = nvl(trunc(p_budget_start_date),trunc(start_date));

   --needed to lock the budget line row
   CURSOR l_lock_budget_line_csr( p_budget_line_rowid VARCHAR2)
   IS
   SELECT 'x'
   FROM   gms_budget_lines
   WHERE  rowid = p_budget_line_rowid
   FOR UPDATE NOWAIT;
---------------------------------------------------------------
   l_api_name			CONSTANT	VARCHAR2(30) 		:= 'update_budget_line';
   i						NUMBER;

   l_project_id					NUMBER;
   l_task_id					NUMBER;
   l_award_id					NUMBER;
   l_alias_not_found_ok		CONSTANT	VARCHAR2(1)		:= 'Y';
   l_budget_version_id				NUMBER;
   l_budget_entry_method_code			VARCHAR2(30);
   l_resource_list_id				NUMBER;
   l_time_phased_type_code			VARCHAR2(30);
   l_resource_list_member_id			NUMBER;
   l_period_name				VARCHAR2(20);
   l_budget_start_date				DATE;
   l_budget_end_date				DATE;
   l_raw_cost					NUMBER;
   l_burdened_cost				NUMBER;
   l_quantity					NUMBER;
   l_unit_of_measure				pa_resources.unit_of_measure%type;
   l_track_as_labor_flag			pa_resource_list_members.track_as_labor_flag%type;
   l_resource_assignment_id			gms_resource_assignments.resource_assignment_id%type;
   l_budget_entry_method_rec			pa_budget_entry_methods%rowtype;
   l_wbs_level					NUMBER;
   l_return_status_task				NUMBER;
   l_budget_amount_code				pa_budget_types.budget_amount_code%type;
   l_description				VARCHAR2(255);
   l_change_reason_code				VARCHAR2(30); -- NUMBER; BUG 2739513, this should be varchar2 not number
   l_project_start_date				DATE;
   l_project_end_date				DATE;
   l_task_start_date				DATE;
   l_task_end_date				DATE;
 /*  l_resource_name				VARCHAR2(30);      Commented for bug 4614242 as this is not used anywhere */
   l_dummy					VARCHAR2(1);
   l_budget_line_rowid				VARCHAR(20);
   l_function_allowed				VARCHAR2(1);
   l_resp_id					NUMBER := 0;
   l_user_id		                        NUMBER := 0;
   l_login_id					NUMBER := 0;
   l_module_name                                VARCHAR2(80);
   l_attribute_category				VARCHAR2(30);
   l_attribute1					VARCHAR2(150);
   l_attribute2					VARCHAR2(150);
   l_attribute3					VARCHAR2(150);
   l_attribute4					VARCHAR2(150);
   l_attribute5					VARCHAR2(150);
   l_attribute6					VARCHAR2(150);
   l_attribute7					VARCHAR2(150);
   l_attribute8					VARCHAR2(150);
   l_attribute9					VARCHAR2(150);
   l_attribute10				VARCHAR2(150);
   l_attribute11				VARCHAR2(150);
   l_attribute12				VARCHAR2(150);
   l_attribute13				VARCHAR2(150);
   l_attribute14				VARCHAR2(150);
   l_attribute15				VARCHAR2(150);
   l_old_stack					VARCHAR2(630);

BEGIN -- update_budget_line

-- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET_LINE - start');

	x_err_code := 0;
	l_old_stack := x_err_stack;
	x_err_stack := x_err_stack ||'-> Update_Budget_Line';

--	Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

	FND_MSG_PUB.initialize;

    END IF;

--  Standard begin of API savepoint

    SAVEPOINT update_budget_line_pub;


--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_INCOMPATIBLE_API_CALL',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    --product_code is mandatory

    IF p_pm_product_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
    OR p_pm_product_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PRODUCT_CODE_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

----------------------------------------------------------------------------
-- If award_id is passed in then use it otherwise use the award_number
-- that is passed in to fetch value of award_id from gms_awards table
-- If both are missing then raise an error.

    IF (p_award_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_award_number IS NOT NULL)
    OR (p_award_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_award_id IS NOT NULL)
        THEN
   	convert_awardnum_to_id(p_award_number_in => p_award_number
   	                      ,p_award_id_in => p_award_id
   			      ,p_award_id_out => l_award_id
   			      ,x_err_code => x_err_code
   			      ,x_err_stage => x_err_stage
   			      ,x_err_stack => x_err_stack);

   	IF x_err_code <> 0
	THEN
		return;
	END IF;
    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_AWARD_NUM_ID_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
--------------------------------------------------------------------------------

-- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET_LINE - after award info validation');

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    l_login_id := FND_GLOBAL.login_id;

    l_module_name := 'GMS_PM_UPDATE_BUDGET_LINE';

    -- As part of enforcing award security, which would determine
    -- whether the user has the necessary privileges to update the award
    -- need to call the gms_security package
    -- If a user does not have privileges to update the award, then
    -- cannot update a budget line

    gms_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

--------------------------------------------------------------------------------

-- If project_id is passed in then use it otherwise use the project_number
-- (segment1) that is passed in to fetch value of project_id from pa_projects
-- table. If both are missing then raise an error.

	IF (p_project_number <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
        AND p_project_number IS NOT NULL)
    	OR (p_project_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
        AND p_project_id IS NOT NULL)
   	THEN
   		convert_projnum_to_id(p_project_number_in => p_project_number
   		                      ,p_project_id_in => p_project_id
   				      ,p_project_id_out => l_project_id
   				      ,x_err_code => x_err_code
   				      ,x_err_stage => x_err_stage
   				      ,x_err_stack => x_err_stack);

	   	IF x_err_code <> 0
    		THEN
			return;
    		END IF;

	ELSE
		gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_NUM_ID_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
-------------------------------------------------------------------------------

-- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET_LINE - after project info validation');

     IF l_project_id IS NULL
     THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_PROJECT_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

      -- Now verify whether award security allows the user to update
      -- award
      -- If a user does not have privileges to update the award, then
      -- cannot update a budget line

      IF gms_security.allow_query (x_award_id => l_award_id ) = 'N' THEN

         -- The user does not have query privileges on this award
         -- Hence, cannot update the award. Raise error
		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_QRY',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available

         IF gms_security.allow_update (x_award_id => l_award_id ) = 'N' THEN

            -- The user does not have update privileges on this award
            -- Hence , raise error

		gms_error_pkg.gms_message(x_err_name => 'GMS_AWD_SECURITY_ENFORCED_UPD',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

        END IF;
     END IF;


 -- budget type code is mandatory
--  dbms_output.put_line('Checking budget type code');

     IF p_budget_type_code IS NULL
     OR p_budget_type_code = GMS_BUDGET_PUB.G_PA_MISS_CHAR
     THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
     ELSE
	OPEN l_budget_amount_code_csr( p_budget_type_code );

	FETCH l_budget_amount_code_csr
	INTO l_budget_amount_code;     		--will be used later on during validation of Budget lines.

		IF l_budget_amount_code_csr%NOTFOUND
		THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_TYPE_IS_INVALID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

		CLOSE l_budget_amount_code_csr;

     END IF;

 -- Get the budget_version_id, budget_entry_method_code and resource_list_id from table pa_budget_version

--  dbms_output.put_line('Get budget version, entry method and resource list');

    OPEN l_budget_version_csr( l_project_id
                             , l_award_id
    			     , p_budget_type_code );
    FETCH l_budget_version_csr
    INTO  l_budget_version_id
    ,     l_budget_entry_method_code
    ,     l_resource_list_id;

    IF l_budget_version_csr%NOTFOUND
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_BUDGET_VERSION',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_budget_version_csr;


 -- entry method code is mandatory (and a nullible field in table pa_budget_versions)

    IF l_budget_entry_method_code IS NULL
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_ENTRY_METHOD_IS_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

-- check validity of this budget entry method code, and store associated fields in record
-- dbms_output.put_line('check validity of entry method');

    OPEN l_budget_entry_method_csr(l_budget_entry_method_code);
    FETCH l_budget_entry_method_csr INTO l_budget_entry_method_rec;

    IF   l_budget_entry_method_csr%NOTFOUND
    THEN
	gms_error_pkg.gms_message(x_err_name => 'GMS_ENTRY_METHOD_IS_INVALID',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_budget_entry_method_csr;

    IF p_period_name <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
    AND p_period_name IS NOT NULL
    THEN

    	OPEN l_budget_periods_csr( p_period_name
    				  ,l_budget_entry_method_rec.time_phased_type_code);

    	FETCH l_budget_periods_csr INTO l_budget_start_date, l_budget_end_date; -- l_budget_end_date added new

    	IF   l_budget_periods_csr%NOTFOUND
    	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_PERIOD_IS_INVALID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;

    	CLOSE l_budget_periods_csr;

    ELSIF  p_budget_start_date <> GMS_BUDGET_PUB.G_PA_MISS_DATE
       AND p_budget_start_date IS NOT NULL
    THEN

    	l_budget_start_date := trunc(p_budget_start_date);

-- if a valid p_budget_end_date is passed in then use it to update the table

		IF  p_budget_end_date <> GMS_BUDGET_PUB.G_PA_MISS_DATE AND p_budget_end_date IS NOT NULL
       		THEN
       			l_budget_end_date := trunc(p_budget_end_date);
       		END IF;
    ELSE
	gms_error_pkg.gms_message(x_err_name => 'GMS_START_DATE_MISSING',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


        -- convert p_task_number to p_task_id
	-- if both task id and number are not passed or NULL, we will assume that budgetting is
	-- done at the project level and that requires l_task_id to be '0'


        IF (p_task_id = GMS_BUDGET_PUB.G_PA_MISS_NUM
            OR p_task_id IS NULL OR p_task_id = 0 )
        AND (p_task_number = GMS_BUDGET_PUB.G_PA_MISS_CHAR
             OR p_task_number IS NULL )
        THEN

        	l_task_id := 0;
        ELSE
		convert_tasknum_to_id ( p_project_id_in => l_project_id
				,p_task_id_in => p_task_id
				,p_task_number_in => p_task_number
				,p_task_id_out => l_task_id
				,x_err_code => x_err_code
				,x_err_stage => x_err_stage
				,x_err_stack => x_err_stack);

		IF x_err_code <> 0
		THEN
			gms_error_pkg.gms_message(x_err_name => 'GMS_TASK_VALIDATE_FAIL',  -- jjj - check message tag
 						x_err_code => x_err_code,
						x_err_buff => x_err_stage);

			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;

        END IF;

    -- convert resource alias to (resource) member id

    -- if resource alias is (passed and not NULL)
    -- and resource member is (passed and not NULL)
    -- then we convert the alias to the id
    -- else we default to the uncategorized resource member

   IF (p_resource_alias <> GMS_BUDGET_PUB.G_PA_MISS_CHAR
       AND p_resource_alias IS NOT NULL)

   OR (p_resource_list_member_id <> GMS_BUDGET_PUB.G_PA_MISS_NUM
       AND p_resource_list_member_id IS NOT NULL)
   THEN
     	convert_listmem_alias_to_id
     		(p_resource_list_id_in	=> l_resource_list_id 	-- IN
	     	,p_reslist_member_alias_in => p_resource_alias 	-- IN
	     	,p_resource_list_member_id_in => p_resource_list_member_id
	     	,p_resource_list_member_id_out	=> l_resource_list_member_id
	     	,x_err_code => x_err_code
	     	,x_err_stage => x_err_stage
	     	,x_err_stack => x_err_stack);

     	IF x_err_code <> 0
     	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_RES_VALIDATE_FAIL',  -- jjj - check message tag
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;

     	END IF;


   ELSE

	-- if the budget is not categorized by resource (categorization_code = 'N')
	-- then get the member id for the uncategorized resource list

    	IF l_budget_entry_method_rec.categorization_code = 'N'
    	THEN

		OPEN l_uncat_list_member_csr;
		FETCH l_uncat_list_member_csr INTO l_resource_list_member_id;
		CLOSE l_uncat_list_member_csr;

	ELSIF l_budget_entry_method_rec.categorization_code = 'R'
	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_RESOURCE_IS_MISSING',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

   END IF;

    --check whether this is a valid member for this list

    OPEN l_resource_csr( l_resource_list_member_id
    			,l_resource_list_id	);

    FETCH l_resource_csr INTO l_dummy;

    IF l_resource_csr%NOTFOUND
    THEN

	CLOSE l_resource_csr;
		gms_error_pkg.gms_message(x_err_name => 'GMS_LIST_MEMBER_INVALID',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_resource_csr;

-- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET_LINE - after resource info validation');

    --get the resource assignment id

    OPEN l_resource_assignment_csr( l_budget_version_id
    				   ,l_task_id
    				   ,l_resource_list_member_id		);

    FETCH l_resource_assignment_csr INTO l_resource_assignment_id;

    IF l_resource_assignment_csr%NOTFOUND
    THEN
	CLOSE l_resource_assignment_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_NO_RESOURCE_ASSIGNMENT',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    CLOSE l_resource_assignment_csr;

-- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET_LINE - after checking existence of resource assignment');

--  dbms_output.put_line('Checking existence of budget line');
    OPEN l_budget_line_csr( l_resource_assignment_id
    			   ,l_budget_start_date	);

    FETCH l_budget_line_csr INTO l_budget_line_rowid;

    IF l_budget_line_csr%NOTFOUND
    THEN

	CLOSE l_budget_line_csr;
	gms_error_pkg.gms_message(x_err_name => 'GMS_BUDGET_LINE_NOT_FOUND',
				x_err_code => x_err_code,
				x_err_buff => x_err_stage);

	APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

    CLOSE l_budget_line_csr;
------------------------------------------------------------------------------------------------------
-- Start of changes for Bug:2830539

    IF p_change_reason_code <> GMS_BUDGET_PUB.G_PA_MISS_CHAR THEN

	OPEN l_budget_change_reason_csr (p_change_reason_code);
	FETCH l_budget_change_reason_csr INTO l_dummy;

	IF l_budget_change_reason_csr%NOTFOUND THEN

       	        CLOSE l_budget_change_reason_csr;
        	gms_error_pkg.gms_message(x_err_name => 'GMS_INVALID_CHANGE_REASON',
               	                 x_err_code => x_err_code,
               	                 x_err_buff => x_err_stage);

        	APP_EXCEPTION.RAISE_EXCEPTION;
   	END IF;

       	CLOSE l_budget_change_reason_csr;

    END IF;

-- dbms_output.put_line('GMS_BUDGET_PUB.UPDATE_BUDGET_LINE - after checking existence of budget line');

-- Once the above validations have passed update the GMS_BUDGET_LINES table
-- with the appropriate values.

    OPEN l_lock_budget_line_csr( l_budget_line_rowid );

    UPDATE  GMS_BUDGET_LINES
    SET     change_reason_code = decode(p_change_reason_code,
                                        GMS_BUDGET_PUB.G_MISS_CHAR,
                                        change_reason_code,
                                        p_change_reason_code),
            burdened_cost = decode(p_burdened_cost,
                                        GMS_BUDGET_PUB.G_MISS_NUM,
                                        burdened_cost,
                                        p_burdened_cost),
            description = decode(p_description,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      description,
                                      p_description),
            attribute_category = decode(p_attribute_category,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute_category,
                                      p_attribute_category),
            attribute1 = decode(p_attribute1,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute1,
                                      p_attribute1),
            attribute2 = decode(p_attribute2,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute2,
                                      p_attribute2),
            attribute3 = decode(p_attribute3,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute3,
                                      p_attribute3),
            attribute4 = decode(p_attribute4,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute4,
                                      p_attribute4),
            attribute5 = decode(p_attribute5,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute5,
                                      p_attribute5),
            attribute6 = decode(p_attribute6,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute6,
                                      p_attribute6),
            attribute7 = decode(p_attribute7,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute7,
                                      p_attribute7),
            attribute8 = decode(p_attribute8,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute8,
                                      p_attribute8),
            attribute9 = decode(p_attribute9,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute9,
                                      p_attribute9),
            attribute10 = decode(p_attribute10,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute10,
                                      p_attribute10),
            attribute11 = decode(p_attribute11,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute11),
            attribute12 = decode(p_attribute12,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute12,
                                      p_attribute12),
            attribute13 = decode(p_attribute13,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute13,
                                      p_attribute13),
            attribute14 = decode(p_attribute14,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute14,
                                      p_attribute14),
            attribute15 = decode(p_attribute15,
                                      GMS_BUDGET_PUB.G_MISS_CHAR,
                                      attribute15,
                                      p_attribute15),
	    last_update_date = SYSDATE,
	    last_updated_by = G_USER_ID,
	    last_update_login = G_LOGIN_ID
    WHERE   resource_assignment_id = l_resource_assignment_id
    AND	    start_date = l_budget_start_date
    AND     end_date = l_budget_end_date;

    CLOSE l_lock_budget_line_csr;

-- End of changes for Bug:2830539
----------------------------------------------------------------------------------

--We don't have to check for overlapping dates because begin and and date can not be changed.

            GMS_BUDGET_PUB.summerize_project_totals( x_budget_version_id => l_budget_version_id
    	    				            , x_err_code	  => x_err_code
					    	    , x_err_stage	  => x_err_stage
					    	    , x_err_stack	  => x_err_stack		);


    	IF x_err_code <> 0
    	THEN
		gms_error_pkg.gms_message(x_err_name => 'GMS_SUMMERIZE_TOTALS_FAILED',
					x_err_code => x_err_code,
					x_err_buff => x_err_stage);

		APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;

------------------------------------------------------------------------------------
-- Added for Bug:1325015

	validate_budget(  x_budget_version_id => l_budget_version_id,
			    x_award_id => l_award_id,
                            x_project_id => l_project_id,
                            x_task_id => l_task_id,
                            x_resource_list_member_id => p_resource_list_member_id,
                            x_start_date => l_budget_start_date,
                            x_end_date => l_budget_end_date,
                            x_return_status => x_err_code);

	if x_err_code <> 0 then
		ROLLBACK TO update_budget_line_pub;
	END IF;
 -- Commented out this call for GMS enhancement : 5583170 as we don't validates across awards with this enahncement.
/*
	validate_budget_mf(  x_budget_version_id => l_budget_version_id,
			    x_award_id => l_award_id,
                            x_project_id => l_project_id,
                            x_task_id => l_task_id,
                            x_resource_list_member_id => p_resource_list_member_id,
                            x_start_date => l_budget_start_date,
                            x_end_date => l_budget_end_date,
                            x_return_status => x_err_code);

	if x_err_code <> 0 then
		ROLLBACK TO update_budget_line_pub;
	end if;
*/
------------------------------------------------------------------------------------

    IF FND_API.TO_BOOLEAN( p_commit )
    THEN
	COMMIT;
    END IF;

    x_err_stack := l_old_stack;

EXCEPTION

	WHEN OTHERS
	THEN
		ROLLBACK TO update_budget_line_pub;
		RAISE;

END update_budget_line;
----------------------------------------------------------------------------------------

end GMS_BUDGET_PUB;

/
