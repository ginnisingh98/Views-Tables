--------------------------------------------------------
--  DDL for Package Body PQH_COMMITMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COMMITMENT_PKG" as
/* $Header: pqbgtcom.pkb 120.11 2007/01/05 17:47:55 krajarat noship $ */
--
--
g_package  varchar2(33) := 'pqh_commitment_pkg.';
--
type cmmtmnt_dt_rec is record (cmmtmnt_start_dt          date,
                               actual_cmmtmnt_start_dt   date,
                               cmmtmnt_end_dt            date,
                               actual_cmmtmnt_end_dt     date);

type cmmtmnt_dt_tab is table of  cmmtmnt_dt_rec index by binary_integer;
--
type cmmtmnt_elmnts_rec is record (
Element_type_id           pqh_bdgt_cmmtmnt_elmnts.element_type_id%type,
Formula_id                pqh_bdgt_cmmtmnt_elmnts.formula_id%type,
Salary_basis_flag         pqh_bdgt_cmmtmnt_elmnts.salary_basis_flag%type,
Element_input_value_id    pqh_bdgt_cmmtmnt_elmnts.element_input_value_id%type,
dflt_elmnt_frequency      pqh_bdgt_cmmtmnt_elmnts.dflt_elmnt_frequency%type,
overhead_percentage       pqh_bdgt_cmmtmnt_elmnts.overhead_percentage%type);
--
type cmmtmnt_elmnts_tab is table of cmmtmnt_elmnts_rec index by binary_integer;
--
type bdgt_posn_rec is record(position_id pqh_budget_details.position_id%type);
type bdgt_orgn_rec is record(organization_id pqh_budget_details.organization_id%type);
type bdgt_job_rec is record(job_id pqh_budget_details.job_id%type);
type bdgt_grade_rec is record(grade_id pqh_budget_details.grade_id%type);
type bdgt_entity_rec is record(entity_id pqh_budget_details.position_id%type);

--
type bdgt_posn_tab is table of bdgt_posn_rec index by binary_integer;
type bdgt_orgn_tab  is table of bdgt_orgn_rec index by binary_integer;
type bdgt_job_tab is table of bdgt_job_rec index by binary_integer;
type bdgt_grade_tab is table of bdgt_grade_rec index by binary_integer;

type bdgt_entity_tab is table of bdgt_entity_rec index by binary_integer;
--
g_budget_detail_status      varchar2(30) := NULL;
g_budget_version_status     varchar2(30) := NULL;
--
g_cmmtmnt_calc_dates        cmmtmnt_dt_tab ;
g_bdgt_cmmtmnt_elmnts       cmmtmnt_elmnts_tab;
g_budget_positions          bdgt_posn_tab;
g_budget_orgs	    	    bdgt_orgn_tab;
g_budget_jobs		    bdgt_job_tab;
g_budget_grades		    bdgt_grade_tab;

g_budget_entities	    bdgt_entity_tab;
--
g_table_route_id_p_bgt      number;
g_table_route_id_p_bdt      number;
--
WEEKLY CONSTANT varchar2(1) := 'W';
MONTHLY CONSTANT varchar2(1) := 'M';
SEMIMONTHLY CONSTANT varchar2(1) := 'S';
--
----------------------------------------------------------------------------
-- The Following section is specification for locally called procedures
-- functions.
----------------------------------------------------------------------------
--
PROCEDURE calculate_money_cmmtmnts(p_budgeted_entity_cd  in varchar2,
                                   p_budget_version_id   in number,
                                   p_entity_id           in number,
                                   p_period_frequency    in varchar2 default null);
--
PROCEDURE Validate_budget(p_budgeted_entity_cd  in varchar2,
 			 p_budget_version_id  in number,
                         p_budget_id          out nocopy number,
                         p_budget_name        out nocopy varchar2,
                         p_period_set_name    out nocopy varchar2,
                         p_bdgt_cal_frequency out nocopy varchar2,
                         p_budget_start_date  out nocopy date,
                         p_budget_end_date    out nocopy date);
--
PROCEDURE Validate_entity (p_budgeted_entity_cd in varchar2,
			   p_entity_id          in number,
                           p_budget_version_id  in number,
                           p_entity_name        out nocopy varchar2);
--
PROCEDURE Validate_commitment_dates(p_period_frequency         in varchar2,
                                    p_cmmtmnt_start_dt         in date,
                                    p_cmmtmnt_end_dt           in date,
                                    p_budget_cal_freq          in varchar2,
                                    p_period_set_name          in varchar2,
                                    p_budget_start_date        in date,
                                    p_budget_end_date          in date);
--
PROCEDURE get_table_route;
--
PROCEDURE fetch_bdgt_cmmtmnt_elmnts(p_budget_id            in  number,
                                    p_bdgt_cmmtmnt_elmnts out nocopy cmmtmnt_elmnts_tab);
--
FUNCTION check_non_susp_assignment(p_commit_calculation_dt     in   date,
                               p_assignment_id             in   number )
RETURN BOOLEAN;
--
FUNCTION  populate_commitment_table(p_budgeted_entity_cd        in varchar2,
                                    p_commit_calculation_dt     in   date,
                                    p_actual_cmmtmnt_start_dt   in   date,
                                    p_commit_end_dt             in   date,
                                    p_actual_cmmtmnt_end_dt     in   date,
                                    p_commitment_calc_frequency in   varchar2,
                                    p_budget_calendar_frequency in   varchar2,
                                    p_entity_id               in   number,
                                    p_budget_id                 in   number,
                                    p_budget_version_id         in   number,
                                    p_assignment_id             in   number default null)
RETURN NUMBER;
--
FUNCTION get_commitment_from_elmnt_type(p_commit_calculation_dt          in      date,
                                        p_actual_cmmtmnt_start_dt        in      date,
                                        p_commit_calculation_end_dt      in      date,
                                        p_actual_cmmtmnt_end_dt          in      date,
                                        p_commitment_calc_frequency      in      varchar2,
                                        p_budget_calendar_frequency      in      varchar2,
                                        p_dflt_elmnt_frequency           in      varchar2,
                                        p_business_group_id              in      number,
                                        p_assignment_id                  in      number,
                                        p_payroll_id                     in      number,
                                        p_pay_basis_id                   in      number,
                                        p_element_type_id                in      number,
                                        p_element_input_value_id         in      number,
                                        p_normal_hours                   in      number,
                                        p_asst_frequency                 in      varchar2)
RETURN NUMBER ;
--
FUNCTION get_commitment_from_sal_basis(p_commit_calculation_dt          in      date,
                                       p_actual_cmmtmnt_start_dt        in      date,
                                       p_commit_calculation_end_dt      in      date,
                                       p_actual_cmmtmnt_end_dt          in      date,
                                       p_commitment_calc_frequency      in      varchar2,
                                       p_element_type_id                in      number,
                                       p_budget_calendar_frequency      in      varchar2,
                                       p_dflt_elmnt_frequency           in      varchar2,
                                       p_business_group_id              in      number,
                                       p_assignment_id                  in      number,
                                       p_payroll_id                     in      number,
                                       p_pay_basis_id                   in      number,
                                       p_normal_hours                   in      number,
                                       p_asst_frequency                 in      varchar2)
RETURN NUMBER;
--
FUNCTION get_payroll_period_type(p_payroll_id         in  number,
                                 p_effective_dt       in  date)
RETURN varchar2 ;
--
FUNCTION Convert_Period_Type(p_bus_grp_id		in NUMBER,
	                     p_payroll_id		in NUMBER,
	                     p_asst_std_hours	        in NUMBER   default NULL,
	                     p_figure		        in NUMBER,
	                     p_from_freq		in VARCHAR2,
	                     p_to_freq		        in VARCHAR2,
	                     p_period_start_date	in DATE     default NULL,
	                     p_period_end_date	        in DATE     default NULL,
	                     p_asst_std_freq		in VARCHAR2 default NULL,
                             p_dflt_elmnt_frequency     in VARCHAR2,
                             p_budget_calendar_frequency in VARCHAR2)
RETURN NUMBER ;
--
--------------------------------------------------------------------------
--
PROCEDURE Validate_budget(p_budgeted_entity_cd  in varchar2,
			  p_budget_version_id   in number,
                          p_budget_id          out nocopy number,
                          p_budget_name        out nocopy varchar2,
                          p_period_set_name    out nocopy varchar2,
                          p_bdgt_cal_frequency out nocopy varchar2,
                          p_budget_start_date  out nocopy date,
                          p_budget_end_date    out nocopy date)
is
--
 Cursor csr_bdgt is
   Select bgt.budget_id,budget_name,period_set_name ,budgeted_entity_cd,
          budget_start_date,budget_end_date
    From pqh_budgets bgt
    Where bgt.budget_id in (Select bvr.budget_id
                    From pqh_budget_versions  bvr
                   Where bvr.budget_version_id = p_budget_version_id);
--
-- Obtain the frequency of the time periods for a calendar
--
  Cursor csr_bdgt_cal_freq is
   Select pc.actual_period_type
     from pay_calendars pc
    Where pc.period_set_name = p_period_set_name;
--
l_proc               varchar2(72) := g_package || 'Validate_budget';
l_budgeted_entity_cd varchar2(30) := null;
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 -- VALIDATE IF THIS IS A VALID BUDGET IN PQH_BUDGETS
 --
 Open  csr_bdgt;
 --
 Fetch  csr_bdgt into p_budget_id,p_budget_name,p_period_set_name,l_budgeted_entity_cd,
                      p_budget_start_date,p_budget_end_date;
 --
 If  csr_bdgt%notfound then
     --
     --Raise exception
     --
     Close  csr_bdgt;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BUDGET_VERSION');
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 Else
    --
    -- DETERMINE WHETHER SELETED P_BUDGETED_ENTITY_CD , L_BUDGETED_ENTITY_CD ARE SAME OR NOT.
    --
       If l_budgeted_entity_cd <> p_budgeted_entity_cd then
       --
        FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BUDGET');
        APP_EXCEPTION.RAISE_EXCEPTION;
       --
       End if;
     --
 End if;
 --
 --

 Close  csr_bdgt;
 --
 -- DETERMINE THE CALENDAR FREQ OF THE BUDGET
 --
 Open  csr_bdgt_cal_freq;
 --
 Fetch  csr_bdgt_cal_freq into p_bdgt_cal_frequency;
 --
 If  csr_bdgt_cal_freq%notfound then
     --
     --Raise exception
     --
     Close  csr_bdgt_cal_freq;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BDGT_CALENDAR');
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 End if;
 --
 Close  csr_bdgt_cal_freq;
 --
 hr_utility.set_location('Leaving :'||l_proc,10);
 --
EXCEPTION
      WHEN OTHERS THEN
p_budget_id          := null;
p_budget_name        := null;
p_period_set_name    := null;
p_bdgt_cal_frequency := null;
p_budget_start_date  := null;
p_budget_end_date    := null;
       raise;
--
End Validate_budget;
--
----------------------------------------------------------------------------
PROCEDURE Validate_entity( p_budgeted_entity_cd in varchar2,
			   p_entity_id          in number,
                            p_budget_version_id    in number,
                            p_entity_name       out nocopy varchar2)
is
--
Cursor csr_pos(l_position_id in number) is
   Select name
     From hr_all_positions_f_tl
    Where position_id = l_position_id
      and language = userenv('LANG');
--
Cursor csr_org(l_org_id in number) is
    Select name
    From hr_all_organization_units -- Bug 2471864
   Where organization_id = l_org_id;
--
 Cursor csr_job(l_job_id in number) is
  Select name
  From per_jobs_vl
  Where job_id = l_job_id;
--
Cursor csr_grade(l_grade_id in number) is
  Select name
  From per_grades_vl
  Where grade_id = l_grade_id;

--
-- The foll cursor checks if the passed position is present in the passed
-- budget version.
--
Cursor csr_positions_in_bdgt(l_position_id in number) is
   Select Position_id
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.position_id IS NOT NULL
      AND (bdt.position_id = l_position_id or l_position_id IS NULL);
--
Cursor csr_orgs_in_bdgt(l_organization_id in number) is
   Select Organization_id
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.organization_id IS NOT NULL
      AND (bdt.organization_id = l_organization_id or l_organization_id IS NULL);
--
Cursor csr_jobs_in_bdgt(l_job_id in number) is
   Select Job_id
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.job_id IS NOT NULL
      AND (bdt.job_id = l_job_id or l_job_id IS NULL);
--
Cursor csr_grades_in_bdgt(l_grade_id in number) is
   Select Grade_id
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.grade_id IS NOT NULL
      AND (bdt.grade_id = l_grade_id or l_grade_id IS NULL);
--

rec_no               number(15) := 1;
l_dummy_tab          bdgt_posn_tab;
l_dummy_tab_org      bdgt_orgn_tab;
l_dummy_tab_job      bdgt_job_tab;
l_dummy_tab_grade    bdgt_grade_tab;
l_dummy_tab_entity   bdgt_entity_tab;
--
l_proc               varchar2(72) := g_package || 'Validate_entity';
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 hr_utility.set_location('p_budgeted_entity_cd'||p_budgeted_entity_cd||'p_entity_id'||p_entity_id,5);

 --

 If p_budgeted_entity_cd ='POSITION' then

 	If p_entity_id IS NOT NULL then
 	--
 	-- VALIDATE IF THIS IS A VALID POSITION IN HR_ALL_POSITIONS_F
 	--
 	   Open  csr_pos(p_entity_id);
 		   --
 		   Fetch  csr_pos into p_entity_name;
 		   --
 		   If  csr_pos%notfound then
 		       --
 		       --Raise exception
 		       --
 		       Close  csr_pos;
 		       FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY');
 		       APP_EXCEPTION.RAISE_EXCEPTION;
 		       --
 		   End if;
 		   --
 	   Close  csr_pos;
 	--
 	End if; -- p_entity_id is not null
 	--
 	-- DETERMINE IF THE POSITION BELONGS TO THE BUDGET VERSION
 	--
 	-- g_budget_positions := l_dummy_tab;
 	g_budget_entities     := l_dummy_tab_entity;
 	--
 	Open  csr_positions_in_bdgt(p_entity_id);
 	--
 	--
 	Loop
 	--
 	   Fetch  csr_positions_in_bdgt into g_budget_entities(rec_no).entity_id;
 	   --
 	   hr_utility.set_location(' Fetch Position:'||l_proc,10);
 	   --
 	   If  csr_positions_in_bdgt%notfound then
 	       --
 	       Exit;
 	       --
 	   End if;
 	   rec_no := rec_no + 1;
 	--
 	End loop;
 	--
 	Close  csr_positions_in_bdgt;
 	--
 	rec_no := rec_no - 1;
 	--
 	hr_utility.set_location(' Check rowcount :'||l_proc,15);
 	--
 	If rec_no = 0 then
 	   --
 	   If p_entity_id IS NULL then
 	      --
 	      FND_MESSAGE.SET_NAME('PQH','PQH_NO_ENTITIES_IN_BDGT_VER');
 	      APP_EXCEPTION.RAISE_EXCEPTION;
 	      --
 	   Else
 	      --
 	      FND_MESSAGE.SET_NAME('PQH','PQH_ENTITY_NOT_IN_BDGT_VER');
 	      APP_EXCEPTION.RAISE_EXCEPTION;
 	      --
 	   End if;
 	   --
 	End If;
 	--
 	--
 End if; -- p_budgeted_entity_cd='POSITION'
 --
 If p_budgeted_entity_cd ='ORGANIZATION' then

  	If p_entity_id IS NOT NULL then
  	--
  	-- VALIDATE IF THIS IS A VALID ORGANIZATION IN HR_ALL_ORGANIZATION_UNITS
  	--
  	   Open  csr_org(p_entity_id);
  		   --
  		   Fetch csr_org into p_entity_name;
  		   --
  		   If  csr_org%notfound then
  		       --
  		       --Raise exception
  		       --
  		       Close  csr_org;
  		       FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY');
  		       APP_EXCEPTION.RAISE_EXCEPTION;
  		       --
  		   End if;
  		   --
  	   Close  csr_org;
  	   Null;
  	--
  	End if; -- p_entity_id is not null
  	--
  	-- DETERMINE IF THE ORGANIZATION BELONGS TO THE BUDGET VERSION
  	--
  	--g_budget_orgs := l_dummy_tab_org;
  	g_budget_entities     := l_dummy_tab_entity;
  	--
  	Open  csr_orgs_in_bdgt(p_entity_id);
  	--
  	--
  	Loop
  	--
  	   Fetch  csr_orgs_in_bdgt into g_budget_entities(rec_no).entity_id;
  	   --
  	   hr_utility.set_location(' Fetch Position:'||l_proc,10);
  	   --
  	   If  csr_orgs_in_bdgt%notfound then
  	       --
  	       Exit;
  	       --
  	   End if;
  	   rec_no := rec_no + 1;
  	--
  	End loop;
  	--
  	Close  csr_orgs_in_bdgt;
  	--
  	rec_no := rec_no - 1;
  	--
  	hr_utility.set_location(' Check rowcount :'||l_proc,15);
  	--
  	If rec_no = 0 then
  	   --
  	   If p_entity_id IS NULL then
  	      --
  	      FND_MESSAGE.SET_NAME('PQH','PQH_NO_ENTITIES_IN_BDGT_VER');
  	      APP_EXCEPTION.RAISE_EXCEPTION;
  	      --
  	   Else
  	      --
  	      FND_MESSAGE.SET_NAME('PQH','PQH_ENTITY_NOT_IN_BDGT_VER');
  	      APP_EXCEPTION.RAISE_EXCEPTION;
  	      --
  	   End if;
  	   --
  	End If;
  	--
  	--
  End if; -- p_budgeted_entity_cd='ORGANIZATION'
 --
  If p_budgeted_entity_cd ='JOB' then

   hr_utility.set_location(' Job Strated...:'||l_proc,10);

   	If p_entity_id IS NOT NULL then
   	--
   	-- VALIDATE IF THIS IS A VALID JOB IN PER_JOBS
   	--
   	   Open  csr_job(p_entity_id);
   		   --
   		   Fetch csr_job into p_entity_name;
   		   hr_utility.set_location('  Job Name :'||p_entity_name,10);
   		   --
   		   If  csr_job%notfound then
   		       --
   		       --Raise exception
   		       --
   		       Close  csr_job;
   		       FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY');
   		       APP_EXCEPTION.RAISE_EXCEPTION;
   		       --
   		   End if;
   		   --
   	   Close  csr_job;
   	  	   hr_utility.set_location(' exited out nocopy .... csr_job   :'||p_entity_name,10);
   	--
   	End if; -- p_entity_id is not null
   	--
   	-- DETERMINE IF THE JOB BELONGS TO THE BUDGET VERSION
   	--
   	-- g_budget_jobs := l_dummy_tab_job;
   	g_budget_entities     := l_dummy_tab_entity;
   	--
   	Open  csr_jobs_in_bdgt(p_entity_id);
   	--
   	--
   	Loop
   	--
   	   Fetch  csr_jobs_in_bdgt into g_budget_entities(rec_no).entity_id;
   	   --
   	   hr_utility.set_location(' Fetch Position:'||l_proc,10);
   	   --
   	   If  csr_jobs_in_bdgt%notfound then
   	       --
   	       Exit;
   	       --
   	   End if;
   	   rec_no := rec_no + 1;
   	--
   	End loop;
   	--
   	Close  csr_jobs_in_bdgt;
   	--
   	rec_no := rec_no - 1;
   	--
   	hr_utility.set_location(' Check rowcount :'||l_proc,15);
   	--
   	If rec_no = 0 then
   	   --
   	   If p_entity_id IS NULL then
   	      --
   	      FND_MESSAGE.SET_NAME('PQH','PQH_NO_ENTITIES_IN_BDGT_VER');
   	      APP_EXCEPTION.RAISE_EXCEPTION;
   	      --
   	   Else
   	      --
   	      FND_MESSAGE.SET_NAME('PQH','PQH_ENTITY_NOT_IN_BDGT_VER');
   	      APP_EXCEPTION.RAISE_EXCEPTION;
   	      --
   	   End if;
   	   --
   	End If;
   	--
   	--
   End if; -- p_budgeted_entity_cd='JOB'

 --
   If p_budgeted_entity_cd ='GRADE' then

    	If p_entity_id IS NOT NULL then
    	--
    	-- VALIDATE IF THIS IS A VALID GRADE IN PER_GRADES
    	--
    	   Open  csr_grade(p_entity_id);
    		   --
    		   Fetch csr_grade into p_entity_name;
    		   --
    		   If  csr_grade%notfound then
    		       --
    		       --Raise exception
    		       --
    		       Close  csr_grade;
    		       FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY');
    		       APP_EXCEPTION.RAISE_EXCEPTION;
    		       --
    		   End if;
    		   --
    	   Close  csr_grade;
    	   Null;
    	--
    	End if; -- p_entity_id is not null
    	--
    	-- DETERMINE IF THE GRADE BELONGS TO THE BUDGET VERSION
    	--
    	--g_budget_grades := l_dummy_tab_grade;
    	g_budget_entities     := l_dummy_tab_entity;
    	--
    	Open  csr_grades_in_bdgt(p_entity_id);
    	--
    	--
    	Loop
    	--
    	   Fetch  csr_grades_in_bdgt into g_budget_entities(rec_no).entity_id;
    	   --
    	   hr_utility.set_location(' Fetch Position:'||l_proc,10);
    	   --
    	   If  csr_grades_in_bdgt%notfound then
    	       --
    	       Exit;
    	       --
    	   End if;
    	   rec_no := rec_no + 1;
    	--
    	End loop;
    	--
    	Close  csr_grades_in_bdgt;
    	--
    	rec_no := rec_no - 1;
    	--
    	hr_utility.set_location(' Check rowcount :'||l_proc,15);
    	--
    	If rec_no = 0 then
    	   --
    	   If p_entity_id IS NULL then
    	      --
    	      FND_MESSAGE.SET_NAME('PQH','PQH_NO_ENTITIES_IN_BDGT_VER');
    	      APP_EXCEPTION.RAISE_EXCEPTION;
    	      --
    	   Else
    	      --
    	      FND_MESSAGE.SET_NAME('PQH','PQH_ENTITY_NOT_IN_BDGT_VER');
    	      APP_EXCEPTION.RAISE_EXCEPTION;
    	      --
    	   End if;
    	   --
    	End If;
    	--
    	--
    End if; -- p_budgeted_entity_cd='GRADE'
 --
 hr_utility.set_location('Leaving :'||l_proc,20);
 --
EXCEPTION
      WHEN OTHERS THEN
      p_entity_name := null;
       hr_utility.set_location('Exception :'||l_proc,25);
       raise;
--
End Validate_entity;
--
------------------------------------------------------------------------
--
PROCEDURE get_table_route is
--
 CURSOR csr_table_route (p_table_alias  IN varchar2 )IS
  SELECT table_route_id
  FROM pqh_table_route
  WHERE table_alias =  p_table_alias;
--
l_proc               varchar2(72) := g_package || 'get_table_route';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- get table_route_id for all the tables

  -- table_route_id for per_budgets
    OPEN csr_table_route (p_table_alias  => 'P_BGT');
       FETCH csr_table_route INTO g_table_route_id_p_bgt;
    CLOSE csr_table_route;

  -- table_route_id for per_budget_versions
    OPEN csr_table_route (p_table_alias  => 'P_BVR');
       FETCH csr_table_route INTO g_table_route_id_p_bdt;
    CLOSE csr_table_route;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
--
End;
--
-----------------------------------------------------------------------
--
procedure get_period_details (p_proc_period_type in varchar2,
                              p_base_period_type out nocopy varchar2,
                              p_multiple         out nocopy number) is
--
  proc_name varchar2(72) := 'get_period_details';
--
  no_periods per_time_period_types.number_per_fiscal_year%type := NULL;
--
Cursor csr_period_types is
  select tp.number_per_fiscal_year
  from per_time_period_types tp
  where tp.period_type = p_proc_period_type;
  --
begin
  hr_utility.set_location('Entering:'||proc_name, 5);
  --
  Open csr_period_types;
  --
  Fetch csr_period_types into no_periods;
  --
  Close csr_period_types;
  --
  -- Use the number of periods in a fiscal year to deduce the base
  -- period and multiple.
  --
  if no_periods = 1 then             -- Yearly
    p_base_period_type := MONTHLY;
    p_multiple := 12;
  elsif no_periods = 2 then          -- Semi yearly
    p_base_period_type := MONTHLY;
    p_multiple := 6;
  elsif no_periods = 4 then          -- Quarterly
    p_base_period_type := MONTHLY;
    p_multiple := 3;
  elsif no_periods = 6 then          -- Bi monthly
    p_base_period_type := MONTHLY;
    p_multiple := 2;
  elsif no_periods = 12 then         -- Monthly
    p_base_period_type := MONTHLY;
    p_multiple := 1;
  elsif no_periods = 13 then         -- Lunar monthly
    p_base_period_type := WEEKLY;
    p_multiple := 4;
  elsif no_periods = 24 then         -- Semi monthly
    p_base_period_type := SEMIMONTHLY;
    p_multiple := 1;                 -- Not used for semi-monthly
  elsif no_periods = 26 then         -- Fortnightly
    p_base_period_type := WEEKLY;
    p_multiple := 2;
  elsif no_periods = 52 then         -- Weekly
    p_base_period_type := WEEKLY;
    p_multiple := 1;
  else
    FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_PERIOD_TYPE');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
--
  hr_utility.set_location('Leaving:'||proc_name, 10);
--
Exception When others then
  p_base_period_type := null;
  p_multiple         := null;
  hr_utility.set_location('Exception:'||proc_name, 15);
  raise;
end get_period_details;
--
---------------------------------------------------------------------------------
-- Locally defined function that, given the end-date of a semi-month
-- period and the first period's end-date (p_fpe_date) returns
-- the end date of the following semi-monthly period.
--
function next_semi_month(p_semi_month_date in date,
                         p_fpe_date        in date)
RETURN date is
   --
   day_of_month        varchar2(2);
   last_of_month       date;
   temp_day            varchar2(2);
   --
   func_name CONSTANT varchar2(50) := 'next_semi_month';
begin
    --
    hr_utility.set_location(func_name, 1);
    --
    day_of_month := to_char(p_fpe_date,'DD');
    --
    if (day_of_month = '15') OR (last_day(p_fpe_date) = p_fpe_date) then
      -- The first period's end-date is either the 15th or the end-of-month
      if last_day(p_semi_month_date) = p_semi_month_date then
         -- End of month: add 15 days
         return(p_semi_month_date + 15);
      else
         -- 15th of month: return last day
         return(last_day(p_semi_month_date));
      end if;
    else
      -- The first period's end-date is neither the 15th nor the end-of-month
      -- temp_day = smaller of the 2 day numbers used to calc period end-dates
      day_of_month := to_char(p_semi_month_date,'DD');

      if day_of_month > '15' then
         temp_day := day_of_month - 15;
      else
         temp_day := day_of_month ;
      end if ;
      --
      if day_of_month between '01' AND '15' then
         if last_day(p_semi_month_date+15) = last_day(p_semi_month_date) then
            return(p_semi_month_date + 15);
         else
            -- for p_semi_month_date = Feb 14th, for example
            return(last_day(p_semi_month_date));
         end if;
      else  -- if on the 16th or later
         return(to_date((temp_day ||'-'||
                to_char(add_months(p_semi_month_date,1),'MM-RRRR')
                           ), 'DD-MM-RRRR'));
      end if ;
    end if ;
end next_semi_month;
--
--
------------------------------------------------------------------------------
--
-- This function performs the date calculation according to the
-- base period type for the period type being considered.
-- Note that for WEEKLY base period, the calculation can be
-- performed by adding days ie. straightforward addition operation.
-- For MONTHLY base period, the add_months() function is used.
-- The exception to these general categories is semi-monthly,
-- which is handled explicitly by the SEMIMONTHLY base period.
--
function add_multiple_of_base (p_target_date      in date,
                               p_base_period_type in varchar2,
                               p_multiple         in number,
                               p_fpe_date         in date)
return date is
--
  l_proc  varchar2(72) := g_package || 'add_multiple_of_base';
  rest_of_date varchar2(9);
  temp_date date;
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Errors can occur when performing date manipulation.
  if p_base_period_type = WEEKLY then
     --
     hr_utility.set_location('Base Type is Weekly :'||l_proc, 10);
     return (p_target_date + (7 * p_multiple));
     --
  elsif p_base_period_type = MONTHLY then
     --
     hr_utility.set_location('Base Type is Monthly :'||l_proc, 15);
     return (add_months(p_target_date, p_multiple));
     --
  else
     --
     -- Addition of one semi-month.
     --
     hr_utility.set_location('Base Type is Semi-Month :'||l_proc, 20);
     return(next_semi_month(p_target_date, p_fpe_date));
     --
  end if;
  --
end add_multiple_of_base;
--
-----------------------generate_cmmtmnt_calc_dates----------------------------
--
-- This function divides the period between the supplied commitment
-- start date and end date into smaller periods each of the input
-- period frequency length and stores the start and end dates of these
-- smaller periods in a pl/sql table
--
PROCEDURE generate_cmmtmnt_calc_dates(p_budget_start_date   in date,
                                     p_budget_end_date      in date,
                                     p_budget_cal_freq      in varchar2,
                                     p_period_set_name      in varchar2,
                                     p_period_frequency     in varchar2,
                                     p_cmmtmnt_start_dt     in date,
                                     p_cmmtmnt_end_dt       in date)
is
--
l_base_period        varchar2(100);
l_multiple           number(15);
l_all_periods        cmmtmnt_dt_tab;
l_dummy_tab          cmmtmnt_dt_tab;
--
cnt                  number(15) :=0;
rec_no               number(15) :=0;
--
l_fpe                date;
l_curr_dt            date;
l_next_start_dt      date;
--
l_start_dt_valid     varchar2(1) := 'N';
l_end_dt_valid       varchar2(1) := 'N';
--
l_proc               varchar2(72) := g_package || 'generate_cmmtmnt_calc_dates';
--
 Cursor csr_bdgt_time_periods is
   Select start_date,end_date
     From per_time_periods
    Where period_set_name = p_period_set_name
      AND start_date between p_budget_start_date and p_budget_end_date
       order by start_date;
--
l_periods_rec csr_bdgt_time_periods%rowtype;
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);

  hr_utility.set_location('period set name :'||p_period_set_name,5);
  hr_utility.set_location('p_period_frequency: '||p_period_frequency,5);
  hr_utility.set_location('p_budget_cal_freqe :'||p_budget_cal_freq,5);
 --
 -- Step 1: GENERATE SUB-PERIODS FOR THE ENTIRE BUDGET FISCAL YEAR AND
 -- STORE IT IN A DUMMY PL/SQL TABLE.
 --
 -- If the passed period frequency is the same as the budget calendar
 -- frequency , we can obtain the periods under the budget calendar
 -- from per_time_periods. Else we have to generate the periods using the
 -- input period frequency.
 --
 If p_period_frequency = p_budget_cal_freq then
    --

    For l_periods_rec in csr_bdgt_time_periods Loop
        --
        cnt := cnt + 1;
        l_all_periods(cnt).cmmtmnt_start_dt := l_periods_rec.start_date;
        l_all_periods(cnt).cmmtmnt_end_dt := l_periods_rec.end_date;
        --
    End loop;
    --
 Else
 --
 get_period_details (p_proc_period_type     =>    p_period_frequency,
                     p_base_period_type     =>    l_base_period,
                     p_multiple             =>    l_multiple);
 --
 l_all_periods := l_dummy_tab;
 cnt := 1;
 --
 l_fpe           := add_months(p_budget_start_date,-1);
 l_curr_dt       := p_budget_start_date;
 l_next_start_dt := p_budget_start_date;
 --
 While l_curr_dt <= p_budget_end_date loop
    --
    l_all_periods(cnt).cmmtmnt_start_dt := l_next_start_dt;
    --
    -- Calculate the end date of this period and the start date of the
    -- next period.
    --
    l_next_start_dt := add_multiple_of_base
                       (p_target_date      => l_curr_dt,
                        p_base_period_type => l_base_period,
                        p_multiple         => l_multiple,
                        p_fpe_date         => l_fpe);
    --
    l_all_periods(cnt).cmmtmnt_end_dt := l_next_start_dt - 1;
    --
    cnt := cnt + 1;
    l_curr_dt := l_next_start_dt;
    --
 End Loop;
 --
 End if;
 --
 -- Step 2: NOW EXTRACT ONLY THE PERIODS THAT LIE WITHIN THE SUPPLIED
 -- COMMITMENT START DATE AND END DATE AND STORE IT IN A GLOBAL PL/SQL
 -- TABLE.ALSO, VALIDATE IF THE COMMITMENT START AND END DATE COINCIDE
 -- WITH THE START AND END DATE OF ONE OF THE GENERATED PERIODS.
 --
 -- Initialise the global table;
 g_cmmtmnt_calc_dates := l_dummy_tab;
 --
 For cnt in NVL(l_all_periods.FIRST,0) .. NVL(l_all_periods.LAST,-1) loop
    --
    -- Check if the periods start date is equal to the commitment start date.
    -- If so , then the input commitment start date is valid.
    --
    hr_utility.set_location('Period :'||to_char(l_all_periods(cnt).cmmtmnt_start_dt,'DD/MM/RRRR')||' - ' ||to_char(l_all_periods(cnt).cmmtmnt_end_dt,'DD/MM/RRRR'),10);
    --
    If p_cmmtmnt_start_dt between l_all_periods(cnt).cmmtmnt_start_dt and
                                  l_all_periods(cnt).cmmtmnt_end_dt then
       --
       hr_utility.set_location('Valid Commitment Start Date',15);
       --
       -- The supplied commitment_start_dt is valid
       --
       l_start_dt_valid := 'Y' ;
       --
    End if;
    --
    --
    If l_start_dt_valid = 'Y' then
       --
       -- Now start extracting the periods .
       --
       rec_no := rec_no + 1;
       --
       g_cmmtmnt_calc_dates(rec_no).cmmtmnt_start_dt := l_all_periods(cnt).cmmtmnt_start_dt;
       g_cmmtmnt_calc_dates(rec_no).cmmtmnt_end_dt := l_all_periods(cnt).cmmtmnt_end_dt;
       --
       -- If the commitment start date falls within a period , we have to
       -- register what the period start date was and what the actual
       -- commitment start date was so that once we find the period we
       -- can prorate this value from the commitment start date to the
       -- period end date.
       --
       If p_cmmtmnt_start_dt > l_all_periods(cnt).cmmtmnt_start_dt then
          --
          g_cmmtmnt_calc_dates(rec_no).actual_cmmtmnt_start_dt := p_cmmtmnt_start_dt;
          --
       Else
          --
          g_cmmtmnt_calc_dates(rec_no).actual_cmmtmnt_start_dt :=l_all_periods(cnt).cmmtmnt_start_dt;
          --
       End if;
       --
       -- If the commitment end date falls within a period , we have to
       -- register what the period end date was and what the actual
       -- commitment end date was so that once we find the period we
       -- can prorate this value from the  period start date to the
       -- commitment end date.
       --
       If p_cmmtmnt_end_dt > l_all_periods(cnt).cmmtmnt_end_dt then
          --
          g_cmmtmnt_calc_dates(rec_no).actual_cmmtmnt_end_dt := l_all_periods(cnt).cmmtmnt_end_dt;
          --
       Else
          --
          hr_utility.set_location('Valid Commitment End Date',20);
          --
          l_end_dt_valid := 'Y';
          g_cmmtmnt_calc_dates(rec_no).actual_cmmtmnt_end_dt := p_cmmtmnt_end_dt;
          Exit;
          --
       End if;
       --
   End if; -- start date is valid
   --
 End Loop; -- Get next period

 --
 If l_start_dt_valid <> 'Y' then
 --
    FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_CMMTMNT_START_DT');
    APP_EXCEPTION.RAISE_EXCEPTION;
 --
 End if;
 --
 if l_end_dt_valid <> 'Y' then
 --
    FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_CMMTMNT_END_DT');
    APP_EXCEPTION.RAISE_EXCEPTION;
 --
 End if;
 --
 hr_utility.set_location('Leaving :'||l_proc,25);
 --
EXCEPTION
      WHEN OTHERS THEN
       --
       hr_utility.set_location('Exception :'||l_proc,30);
       raise;
       --
End generate_cmmtmnt_calc_dates;
--
--
--------------------------------Validate_commitment_dates-----------------------
--
PROCEDURE Validate_commitment_dates(
                         p_period_frequency         in varchar2,
                         p_cmmtmnt_start_dt         in date,
                         p_cmmtmnt_end_dt           in date,
                         p_budget_cal_freq          in varchar2,
                         p_period_set_name          in varchar2,
                         p_budget_start_date        in date,
                         p_budget_end_date          in date)
is
--
l_proc        varchar2(72) := g_package||'Validate_commitment_dates';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- 1) Check if p_cmmtmnt_end_dt > p_cmmtmnt_start_dt.
  --
  If p_cmmtmnt_end_dt < p_cmmtmnt_start_dt then
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_END_DT_LESS_THAN_START_DT');
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
  End if;
  --
  -- 2) Check if p_cmmtmnt_start_dt < p_budget_start_date
  --
  if p_cmmtmnt_start_dt < p_budget_start_date then
    --
     FND_MESSAGE.SET_NAME('PQH','PQH_CMT_START_BEF_BDGT_START');
     APP_EXCEPTION.RAISE_EXCEPTION;
    --
  End if;
-- commented by Sumit Goyal
-- for relieving commitments you may have to calculate commitments beyond the budget date range
  --
  -- 3) Check if p_cmmtmnt_start_dt > p_budget_end_date
  --
  if p_cmmtmnt_start_dt > p_budget_end_date then
    --
     FND_MESSAGE.SET_NAME('PQH','PQH_CMTMNT_START_AFT_BDGT_END');
     APP_EXCEPTION.RAISE_EXCEPTION;
    --
  End if;
  --
  -- 4) Check if p_cmmtmnt_end_dt > p_budget_end_date
  --
  if p_cmmtmnt_end_dt > p_budget_end_date then
    --
     FND_MESSAGE.SET_NAME('PQH','PQH_CMTMNT_END_AFT_BDGT_END');
     APP_EXCEPTION.RAISE_EXCEPTION;
    --
  End if;
  --
  -- THE FOLL FUNCTION DOES THE FOLL VALIDATIONS . GIVEN THE FREQUENCY AND THE
  -- FISCAL YEAR OF A BUDGET,THE COMMIMENT START DATE MUST START ON A PERIOD
  -- START DATE .ALSO END DATE SHOULD A PERIOD END DATE WITHIN THE BUDGETS END
  -- DATE OR THE ONE IMMEDIATELY AFTER .
  --
  generate_cmmtmnt_calc_dates(p_budget_start_date => p_budget_start_date,
                              p_budget_end_date   => p_budget_end_date,
                              p_period_set_name   => p_period_set_name,
                              p_budget_cal_freq   => p_budget_cal_freq,
                              p_period_frequency  => p_period_frequency,
                              p_cmmtmnt_start_dt=> p_cmmtmnt_start_dt,
                              p_cmmtmnt_end_dt  => p_cmmtmnt_end_dt);
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
EXCEPTION
      WHEN OTHERS THEN
       raise;
End Validate_commitment_dates;
--
------------------------get_payroll_period_type-------------------------------
--
Function get_payroll_period_type(p_payroll_id         in  number,
                                 p_effective_dt       in  date) RETURN varchar2 is
--
l_period_type              pay_payrolls_f.period_type%type;
--
-- Pick up the period type available for a payroll as of the commitment calculation date.
--
Cursor csr_period_type is
       SELECT   PRL.period_type
         FROM	pay_payrolls_f 			PRL
        WHERE	PRL.payroll_id			= p_payroll_id
          AND	p_effective_dt	BETWEEN PRL.effective_start_date AND PRL.effective_end_date;
--
  l_proc        varchar2(72) := g_package||'get_payroll_period_type';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,5);
  Open csr_period_type;
  Fetch csr_period_type into l_period_type;
  Close csr_period_type;
  hr_utility.set_location('period type is:'||l_period_type,8);
  hr_utility.set_location('Leaving:'||l_proc, 10);
  RETURN l_period_type;
End;
--
-----------------------get_number_per_fiscal_year--------------------------------
--
-- This function returns the number of times a particular frequency
-- occurs in a year.
--
Function get_number_per_fiscal_year(p_frequency  in varchar2) RETURN NUMBER is
--
l_number_per_fiscal_year per_time_period_types.number_per_fiscal_year%type;
--
Cursor csr_period_type is
    SELECT	PT.number_per_fiscal_year
    FROM	per_time_period_types 	PT
    WHERE	UPPER(PT.period_type) 	= UPPER(p_frequency);

  l_check       hr_lookups.meaning%type;
  l_proc        varchar2(72) := g_package||'get_number_per_fiscal_year';
Begin
hr_utility.set_location('Entering:'||l_proc,5);
 Open csr_period_type;
 Fetch csr_period_type into l_number_per_fiscal_year;
 If csr_period_type%notfound then
    hr_utility.set_location('not a valid period type:'||l_proc,10);
    Close csr_period_type;
-- Frequency passed is not a valid period type, checking the lookups
    l_check := hr_general.decode_lookup(p_lookup_type =>'PAY_BASIS',
                                        p_lookup_code => p_frequency);
    If l_check is null then
       hr_utility.set_location('not a valid sal basis :'||l_proc,20);
       l_check := hr_general.decode_lookup(p_lookup_type =>'FREQUENCY',
                                           p_lookup_code => p_frequency);
       If l_check is null then
          hr_utility.set_location('not a valid assignment frequency :'||l_proc,30);
          RETURN -1;
       Else
          if p_frequency ='W' then
             return 52;
          elsif p_frequency ='M' then
             return 12;
          elsif p_frequency ='D' then
             return 365;
          elsif p_frequency ='Y' then
             return 1;
          else
             return -1;
          end if;
       End if;
    Else
       if p_frequency ='ANNUAL' then
          return 1;
       elsif p_frequency ='MONTHLY' then
          return 12;
       else
          return -1;
       end if;
    End if;
 End if;
 Close csr_period_type;
 hr_utility.set_location('Leaving:'||l_proc, 10);
 RETURN l_number_per_fiscal_year;
End;
--
--------------------get_commitment_from_formula-------------------------------
--
Function get_commitment_from_formula(
                 p_formula_id            in number,
                 p_business_group_id     in number   default null,
                 p_payroll_id            in number   default null,
                 p_payroll_action_id     in number   default null,
                 p_assignment_id         in number   default null,
                 p_assignment_action_id  in number   default null,
                 p_org_pay_method_id     in number   default null,
                 p_per_pay_method_id     in number   default null,
                 p_organization_id       in number   default null,
                 p_tax_unit_id           in number   default null,
                 p_jurisdiction_code     in varchar2 default null,
                 p_balance_date          in date     default null,
                 p_element_entry_id      in number   default null,
                 p_element_type_id       in number   default null,
                 p_original_entry_id     in number   default null,
                 p_tax_group             in number   default null,
                 p_pgm_id                in number   default null,
                 p_pl_id                 in number   default null,
                 p_pl_typ_id             in number   default null,
                 p_opt_id                in number   default null,
                 p_ler_id                in number   default null,
                 p_communication_type_id in number   default null,
                 p_action_type_id        in number   default null,
                 p_acty_base_rt_id       in number   default null,
                 p_elig_per_elctbl_chc_id in number   default null,
                 p_enrt_bnft_id          in number   default null,
                 p_regn_id               in number   default null,
                 p_rptg_grp_id           in number   default null,
                 p_cm_dlvry_mthd_cd      in varchar2 default null,
                 p_crt_ordr_typ_cd       in varchar2 default null,
                 p_enrt_ctfn_typ_cd      in varchar2 default null,
                 p_bnfts_bal_id          in number   default null,
                 p_elig_per_id           in number   default null,
                 p_per_cm_id             in number   default null,
                 p_prtt_enrt_actn_id     in number   default null,
                 p_effective_date        in date,
                 p_param1                in varchar2 default null,
                 p_param1_value          in varchar2 default null,
                 p_param2                in varchar2 default null,
                 p_param2_value          in varchar2 default null,
                 p_param3                in varchar2 default null,
                 p_param3_value          in varchar2 default null,
                 p_param4                in varchar2 default null,
                 p_param4_value          in varchar2 default null,
                 p_param5                in varchar2 default null,
                 p_param5_value          in varchar2 default null,
                 p_param6                in varchar2 default null,
                 p_param6_value          in varchar2 default null,
                 p_param7                in varchar2 default null,
                 p_param7_value          in varchar2 default null,
                 p_param8                in varchar2 default null,
                 p_param8_value          in varchar2 default null,
                 p_param9                in varchar2 default null,
                 p_param9_value          in varchar2 default null,
                 p_param10               in varchar2 default null,
                 p_param10_value         in varchar2 default null,
                 p_element_input_value_id      in   number  default null,
                 p_commitment_start_date       in   date    default null,
                 p_commitment_end_date         in   date    default null)
RETURN number is
  --
  l_inputs                  ff_exec.inputs_t;
  l_outputs                 ff_exec.outputs_t;
  l_commitment              number;
  --
  l_proc                    varchar2(100) := g_package || 'get_commitment_from_formula';
  --
  l_input_count             number;
BEGIN
  --
  hr_utility.set_location ('Entering: '||l_proc,05);
  --
  begin
  /*
   * Insert row into fnd_sessions to allow use of global values
   */
   insert into fnd_sessions (session_id, effective_date) values (userenv('sessionid'),trunc(sysdate));
  exception
     when others then null;
  end;
  --
  -- Initialise the formula .
  --
  ff_exec.init_formula
       (p_formula_id     => p_formula_id,
        p_effective_date => p_effective_date,
        p_inputs         => l_inputs,
        p_outputs        => l_outputs);
  --
  -- NOTE that we use special parameter values in order to state which
  -- array locations we put the values into, this is because of the caching
  -- mechanism that formula uses.
  -- Set the Context for the formula.
  --
  hr_utility.set_location ('Set Context '||l_proc,10);
  --
  for l_count in nvl(l_inputs.first,0)..nvl(l_inputs.last,-1) loop
    --
    if l_inputs(l_count).name = 'BUSINESS_GROUP_ID' then
      --
      l_inputs(l_count).value := nvl(p_business_group_id, -1);
      --
    elsif l_inputs(l_count).name = 'PAYROLL_ID' then
      --
      l_inputs(l_count).value := nvl(p_bnfts_bal_id, nvl(p_rptg_grp_id, nvl(p_payroll_id,-1)));
      --
    elsif l_inputs(l_count).name = 'PAYROLL_ACTION_ID' then
      --
      l_inputs(l_count).value := nvl(p_acty_base_rt_id, nvl(p_payroll_action_id, -1));
      --
    elsif l_inputs(l_count).name = 'ASSIGNMENT_ID' then
      --
      l_inputs(l_count).value := nvl(p_assignment_id, -1);
      --
    elsif l_inputs(l_count).name = 'ASSIGNMENT_ACTION_ID' then
      --
      l_inputs(l_count).value := nvl(p_assignment_action_id, -1);
      --
    elsif l_inputs(l_count).name = 'ORG_PAY_METHOD_ID' then
      --
      l_inputs(l_count).value := nvl(p_per_cm_id,nvl(p_prtt_enrt_actn_id, nvl(p_enrt_bnft_id, nvl(p_org_pay_method_id, -1))));
      --
    elsif l_inputs(l_count).name = 'PER_PAY_METHOD_ID' then
      --
      l_inputs(l_count).value := nvl(p_elig_per_id, nvl(p_regn_id, nvl(p_per_pay_method_id, -1)));
      --
    elsif l_inputs(l_count).name = 'ORGANIZATION_ID' then
      --
      l_inputs(l_count).value := nvl(p_organization_id, -1);
      --
    elsif l_inputs(l_count).name = 'TAX_UNIT_ID' then
      --
      l_inputs(l_count).value := nvl(p_tax_unit_id, -1);
      --
    elsif l_inputs(l_count).name = 'JURISDICTION_CODE' then
      --
      l_inputs(l_count).value := nvl(p_cm_dlvry_mthd_cd, nvl(p_crt_ordr_typ_cd,nvl(p_jurisdiction_code, 'xx')));
      --
    elsif l_inputs(l_count).name = 'SOURCE_TEXT' then
      --
      l_inputs(l_count).value := nvl(p_enrt_ctfn_typ_cd, 'xx');
      --
    elsif l_inputs(l_count).name = 'BALANCE_DATE' then
      --
      l_inputs(l_count).value := fnd_date.date_to_canonical(p_balance_date);
      --
    elsif l_inputs(l_count).name = 'ELEMENT_TYPE_ID' then
      --
      l_inputs(l_count).value := nvl(p_element_type_id, -1);
      --
    elsif l_inputs(l_count).name = 'ELEMENT_ENTRY_ID' then
      --
      l_inputs(l_count).value := nvl(p_element_entry_id, -1);
      --
    elsif l_inputs(l_count).name = 'ORIGINAL_ENTRY_ID' then
      --
      l_inputs(l_count).value := nvl(p_original_entry_id, -1);
      --
    elsif l_inputs(l_count).name = 'TAX_GROUP' then
      --
      l_inputs(l_count).value := p_tax_group;
      --
    elsif l_inputs(l_count).name = 'PGM_ID' then
      --
      l_inputs(l_count).value := nvl(p_pgm_id,-1);
      --
    elsif l_inputs(l_count).name = 'PL_ID' then
      --
      l_inputs(l_count).value := nvl(p_pl_id,-1);
      --
    elsif l_inputs(l_count).name = 'PL_TYP_ID' then
      --
      l_inputs(l_count).value := nvl(p_pl_typ_id,-1);
      --
    elsif l_inputs(l_count).name = 'OPT_ID' then
      --
      l_inputs(l_count).value := nvl(p_opt_id,-1);
      --
    elsif l_inputs(l_count).name = 'LER_ID' then
      --
      l_inputs(l_count).value := nvl(p_ler_id,-1);
      --
    elsif l_inputs(l_count).name = 'COMM_TYP_ID' then
      --
      l_inputs(l_count).value := nvl(p_communication_type_id,-1);
      --
    elsif l_inputs(l_count).name = 'ACT_TYP_ID' then
      --
      l_inputs(l_count).value := nvl(p_action_type_id,-1);
      --
    elsif l_inputs(l_count).name = 'ELEMENT_INPUT_VALUE_ID' then
      --
      l_inputs(l_count).value := nvl(p_element_input_value_id,-1);
      --
    elsif l_inputs(l_count).name = 'COMMITMENT_START_DATE' then
      --
      l_inputs(l_count).value := fnd_date.date_to_canonical(p_commitment_start_date);
      --
    elsif l_inputs(l_count).name = 'COMMITMENT_END_DATE' then
      --
      l_inputs(l_count).value := fnd_date.date_to_canonical(p_commitment_end_date);
      --
    elsif l_inputs(l_count).name = p_param1 then
      --
      l_inputs(l_count).value := p_param1_value;
      --
    elsif l_inputs(l_count).name = p_param2 then
      --
      l_inputs(l_count).value := p_param2_value;
      --
    elsif l_inputs(l_count).name = p_param3 then
      --
      l_inputs(l_count).value := p_param3_value;
      --
    elsif l_inputs(l_count).name = p_param4 then
      --
      l_inputs(l_count).value := p_param4_value;
      --
    elsif l_inputs(l_count).name = p_param5 then
      --
      l_inputs(l_count).value := p_param5_value;
      --
    elsif l_inputs(l_count).name = p_param6 then
      --
      l_inputs(l_count).value := p_param6_value;
      --
    elsif l_inputs(l_count).name = p_param7 then
      --
      l_inputs(l_count).value := p_param7_value;
      --
    elsif l_inputs(l_count).name = p_param8 then
      --
      l_inputs(l_count).value := p_param8_value;
      --
    elsif l_inputs(l_count).name = p_param9 then
      --
      l_inputs(l_count).value := p_param9_value;
      --
    elsif l_inputs(l_count).name = p_param10 then
      --
      l_inputs(l_count).value := p_param10_value;
      --
    elsif l_inputs(l_count).name = 'DATE_EARNED' then
      --
      -- Note that you must pass the date as a string, that is because
      -- of the canonical date change of 11.5
      -- Still the fast formula does't accept the full canonical form.
      --
      -- l_inputs(l_count).value := fnd_date.date_to_canonical(p_effective_date);
      l_inputs(l_count).value := to_char(p_effective_date, 'RRRR/MM/DD');
      --
    end if;
    --
  end loop;
  --
  hr_utility.set_location ('Run formula: '||l_proc,15);
  --
  -- We have loaded the input record . Now run the formula.
  --
  ff_exec.run_formula(p_inputs  => l_inputs,
                      p_outputs => l_outputs);
  --
  --
  -- Loop through the returned table and make sure that the returned
  -- values have been found
  --
  for l_count in NVL(l_outputs.first,0)..NVL(l_outputs.last,-1) loop
  --
  --
    if l_outputs(l_count).name = 'COMMITMENT' then
    --
       l_commitment := l_outputs(l_count).value;
    --
    Elsif  l_outputs(l_count).name = 'MESSAGE' then
       null;
    end if;
  --
  end loop;
  --
  hr_utility.set_location ('Entering: '||l_proc,20);
  --
  Return l_commitment;
  --
End;
--
------------------------get_commitment_from_elmnt_type-----------------------------------
--
-- This function returns the commitment for 1 assignment for a given
-- element type
--
FUNCTION get_commitment_from_elmnt_type(p_commit_calculation_dt          in      date,
                                        p_actual_cmmtmnt_start_dt        in      date,
                                        p_commit_calculation_end_dt      in      date,
                                        p_actual_cmmtmnt_end_dt          in      date,
                                        p_commitment_calc_frequency      in      varchar2,
                                        p_budget_calendar_frequency      in      varchar2,
                                        p_dflt_elmnt_frequency           in      varchar2,
                                        p_business_group_id              in      number,
                                        p_assignment_id                  in      number,
                                        p_payroll_id                     in      number,
                                        p_pay_basis_id                   in      number,
                                        p_element_type_id                in      number,
                                        p_element_input_value_id         in      number,
                                        p_normal_hours                   in      number,
                                        p_asst_frequency                 in      varchar2)
RETURN NUMBER is
--
-- This cursor selects all element entries for an assignment and the given
-- element type.
--
Cursor csr_assignment_entries(p_commit_calculation_dt in date,
                              p_assignment_id         in number,
                              p_element_type_id       in number,
                               p_commit_calculation_end_dt in date) is
       Select EE.element_entry_id, EE.creator_type,
              ee.effective_start_date, ee.effective_end_date
         from pay_element_entries_f EE, pay_element_links_f EL
        Where EL.element_type_id = p_element_type_id
          --AND p_commit_calculation_dt between EL.effective_start_date and EL.effective_end_date
          and EL.effective_start_date < p_commit_calculation_end_dt
          and EL.effective_end_date > p_commit_calculation_dt
          AND EL.element_link_id = EE.element_link_id
          AND EE.assignment_id   = p_assignment_id
          --AND p_commit_calculation_dt between EE.effective_start_date and EE.effective_end_date;
          and EE.effective_start_date <= p_commit_calculation_end_dt
          and EE.effective_end_date >= p_commit_calculation_dt;

--
-- This cursor selects the entry value for a given entry_id and
-- input_value_id.
--
Cursor csr_elmnt_entry_value(p_commit_calculation_dt in date,
                             p_input_value_id        in number,
                             p_element_entry_id      in number,
                                 p_commit_calculation_end_dt in date) is
      Select screen_entry_value
        from pay_element_entry_values_f
       Where input_value_id = p_input_value_id
         AND element_entry_id = p_element_entry_id
         --AND p_commit_calculation_dt between effective_start_date and effective_end_date;
         and effective_start_date < p_commit_calculation_end_dt
         and effective_end_date > p_commit_calculation_dt;

-- This cursor get the input value name for a given input value id.
Cursor csr_get_input_value_name( p_input_value_id in number,
                                 p_commit_calculation_dt in date,
                                 p_commit_calculation_end_dt in date) is
       select name from pay_input_values_f piv
       where piv.input_value_id = p_input_value_id
       --and p_commit_calculation_dt between piv.effective_start_date and piv.effective_start_date;
        and piv.effective_end_date > p_commit_calculation_dt
        and piv.effective_start_date <= p_commit_calculation_end_dt ;
-- This cursor gets the pay basis frequency for a particular assignment.
Cursor csr_get_pay_basis_freq (p_pay_basis_id in number) is
      select pay_basis
      from per_pay_bases ppb
      where ppb.pay_basis_id = p_pay_basis_id;

--       select pay_basis from per_pay_bases ppb, per_all_assignments_f paf
--     where paf.pay_basis_id = ppb.pay_basis_id
--       and paf.assignment_id = p_assignment_id
       --and p_commit_calculation_dt between paf.effective_start_date and paf.effective_end_date;
--        and paf.effective_end_date >= p_commit_calculation_dt
--        and paf.effective_start_date <= p_commit_calculation_end_dt

--
--
-- DECLARE all local variables.
--
--
l_entry_value               pay_element_entry_values.screen_entry_value%type;
l_entry_effective_end_date  pay_element_entries_f.effective_end_date%type;
l_entry_effective_start_date pay_element_entries_f.effective_start_date%type;
l_element_frequency         pay_element_entry_values.screen_entry_value%type;
l_element_entry_id          pay_element_entries_f.element_entry_id%type;
l_element_creator_type      pay_element_entries_f.creator_type%type;
--
l_adjusted_start_dt         pqh_element_commitments.commitment_start_date%type;
l_adjusted_end_dt           pqh_element_commitments.commitment_end_date%type;
--
l_entry_commitment          number;
l_converted_amt             number;
--
l_input_value_name          varchar2(250);
--
l_proc        varchar2(72) := g_package||'get_commitment_from_elmnt_type';
--
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
hr_utility.set_location('p_commit_calculation_dt:'||p_commit_calculation_dt, 5);
hr_utility.set_location('p_actual_cmmtmnt_start_dt:'||p_actual_cmmtmnt_start_dt, 5);
hr_utility.set_location('p_commit_calculation_end_dt:'||p_commit_calculation_end_dt, 5);
hr_utility.set_location('p_actual_cmmtmnt_end_dt:'||p_actual_cmmtmnt_end_dt, 5);

--

 -- GET ALL ELEMENT ENTRIES FOR THIS ELEMENT TYPE , AND THIS
 -- ASSIGNMENT, EFFECTIVE AS OF COMMITMENT CALCULATION DATE
 -- FOR EACH ENRTY , CALCULATE COMMITMENT AND CONVERT IT TO REQD FREQUENCY
 --
 l_entry_commitment := 0;
 Open csr_assignment_entries
      (p_commit_calculation_dt => p_actual_cmmtmnt_start_dt,
       p_assignment_id         => p_assignment_id,
       p_element_type_id       => p_element_type_id,
       p_commit_calculation_end_dt => p_actual_cmmtmnt_end_dt);
 Loop
     Fetch csr_assignment_entries into l_element_entry_id,l_element_creator_type,l_entry_effective_start_date,l_entry_effective_end_date;
     If csr_assignment_entries%notfound then
        Close csr_assignment_entries;
        Exit;
     End if;

     hr_utility.set_location('Entry exist for Assgnt '||l_proc,10);
     -- SELECT THE COMMITMENT AMOUNT FOR THIS ELEMENT ENTRY
     l_entry_value := 0;
     hr_utility.set_location('p_input_value_id '||p_element_input_value_id,11);
     hr_utility.set_location('l_element_entry_id '||l_element_entry_id,11);
     hr_utility.set_location('p_commit_calculation_dt '||to_char(p_commit_calculation_dt),11);
     Open csr_elmnt_entry_value
         (p_commit_calculation_dt => l_entry_effective_start_date,
          p_element_entry_id      => l_element_entry_id,
          p_input_value_id        => p_element_input_value_id,
          p_commit_calculation_end_dt => l_entry_effective_end_date);
     Fetch csr_elmnt_entry_value into l_entry_value;

     hr_utility.set_location('Entry Value '||l_entry_value,11);
     --
     If csr_elmnt_entry_value%found then
     --
     -- Only if there is entry value , there is any point in getting the
     -- frequency for which it is available and converting it to reqd frequency.
     --
        hr_utility.set_location('Value is there for this entry',15);

        Close csr_elmnt_entry_value;
        --
        -- SELECT THE FREQUENCY FOR THE ELEMENT ENTRY based on
        -- frequency input value id.Ideally it should be provided when
        -- element entry input value is provided. If it is not provided
        -- we will use budget element frequency as the elements frequency
        --
        -- Comment added by sgoyal
        -- We don't ask for frequency input value anymore on form, hence dflt_elmnt_freq will be used.
        hr_utility.set_location('Frequency is dflt Elmnt '||p_dflt_elmnt_frequency,30);
        --
        -- l_element_frequency := p_dflt_elmnt_frequency;
        --
         if p_dflt_elmnt_frequency is null then
           if l_element_creator_type = 'SP' then
              Open csr_get_input_value_name(
                     p_input_value_id =>p_element_input_value_id,
                     p_commit_calculation_dt =>p_actual_cmmtmnt_start_dt,
                    p_commit_calculation_end_dt => p_actual_cmmtmnt_end_dt);
              Fetch csr_get_input_value_name into l_input_value_name;
              Close csr_get_input_value_name;
              If l_input_value_name = 'Pay Value' then
                 l_element_frequency := p_dflt_elmnt_frequency;
              else
                  Open csr_get_pay_basis_freq(
                   p_pay_basis_id => p_pay_basis_id);
                  Fetch csr_get_pay_basis_freq into l_element_frequency;
                  Close csr_get_pay_basis_freq;
               end if;
           else
                l_element_frequency := p_dflt_elmnt_frequency;
           end if;
        else
             l_element_frequency := p_dflt_elmnt_frequency;
        end if;

        hr_utility.set_location('Figure :' || l_entry_value,31);
        hr_utility.set_location('From :' || l_element_frequency,32);
        hr_utility.set_location('To :' || p_commitment_calc_frequency,33);
        --
        l_converted_amt :=  Convert_Period_Type(
		p_bus_grp_id               => p_business_group_id,
		p_payroll_id	           => p_payroll_id,
		p_asst_std_hours	       => p_normal_hours,
		p_figure                   => fnd_number.canonical_to_number(l_entry_value),
		p_from_freq                => l_element_frequency,
		p_to_freq	               => p_commitment_calc_frequency,
		p_period_start_date	       => p_commit_calculation_dt,
		p_period_end_date          => p_commit_calculation_end_dt,
		p_asst_std_freq            => p_asst_frequency,
                p_dflt_elmnt_frequency     => p_dflt_elmnt_frequency,
                p_budget_calendar_frequency => p_budget_calendar_frequency
                );
        hr_utility.set_location('converted amt is'||l_converted_amt,34);
        --
        -- If the period for which we need to calculate commitment is lesser
        -- than the input period type , we have to further prorate the
        -- calculated commitment value for the no of days in the commitment
        -- calculation period .  This can happen only for the last period for
        -- which commitment is generated.
        --
        If l_entry_effective_start_date >  p_actual_cmmtmnt_start_dt then
           l_adjusted_start_dt := l_entry_effective_start_date;
        Else
           l_adjusted_start_dt := p_actual_cmmtmnt_start_dt;
        End if;

        If l_entry_effective_end_date <  p_actual_cmmtmnt_end_dt   then
           l_adjusted_end_dt := l_entry_effective_end_date;
        Else
           l_adjusted_end_dt := p_actual_cmmtmnt_end_dt;
        End if;
        --
        hr_utility.set_location('Before Proration - Converted Amount: '||l_converted_amt,34);
        l_converted_amt := nvl(l_converted_amt,0) *
            (l_adjusted_end_dt - l_adjusted_start_dt + 1)/
            (p_commit_calculation_end_dt   - p_commit_calculation_dt + 1);
        hr_utility.set_location('After Proration - Converted Amount: '||l_converted_amt,35);
        l_entry_commitment := nvl(l_entry_commitment,0) + nvl(l_converted_amt,0);
    Else
      Close csr_elmnt_entry_value;
    End if; /** There is a entry value,that needs to be converted **/
 End loop; /** element entry commitment calculation **/
hr_utility.set_location('Leaving:'||l_proc, 40);
RETURN l_entry_commitment;
End;
--
----------------------get_commitment_from_sal_basis--------------------------
--
-- This function returns the commitment for 1 assignment for a given
-- element type
--
FUNCTION get_commitment_from_sal_basis(p_commit_calculation_dt          in      date,
                                       p_actual_cmmtmnt_start_dt        in      date,
                                       p_commit_calculation_end_dt      in      date,
                                       p_actual_cmmtmnt_end_dt          in      date,
                                       p_commitment_calc_frequency      in      varchar2,
                                       p_element_type_id                in      number,
                                       p_budget_calendar_frequency      in      varchar2,
                                       p_dflt_elmnt_frequency           in      varchar2,
                                       p_business_group_id              in      number,
                                       p_assignment_id                  in      number,
                                       p_payroll_id                     in      number,
                                       p_pay_basis_id                   in      number,
                                       p_normal_hours                   in      number,
                                       p_asst_frequency                 in      varchar2)
RETURN NUMBER is
--
-- DECLARE all local variables.
--
l_entry_value               number;
l_pay_basis                 per_pay_bases.pay_basis%type;
l_adjusted_start_dt         pqh_element_commitments.commitment_start_date%type;
l_adjusted_end_dt           pqh_element_commitments.commitment_end_date%type;
--
--
l_converted_amt             number;
--
-- If the salary basis flag = 'Y' for the element type , this cursor
-- selects the salary amount and pay basis for an assignment.
--
-- We are filtering here , only those entries of the assignment that belong
-- to the passed element type.
--
    cursor csr_pay_basis (p_pay_basis_id          in  number,
                          p_commit_calculation_dt in date,
                          p_commit_calculation_end_dt in date)  is
          Select ppb.pay_basis,ppb.input_value_id
          from   per_pay_bases ppb
          ,      pay_input_values_f piv  --To ensure that this input value id belongs to the passed element_type
          where  ppb.pay_basis_id = p_pay_basis_id
            and  piv.input_value_id = ppb.input_value_id
            and  piv.element_type_id = p_element_type_id
            and piv.effective_start_date <=  p_commit_calculation_end_dt
            and piv.effective_end_date >= p_commit_calculation_dt;
--            and  p_commit_calculation_dt
--                 between piv.effective_start_date and piv.effective_end_date;
--
   Cursor csr_salary_basis(p_input_value_id        in  number,
                           p_assignment_id         in  number,
                           p_commit_calculation_dt in date,
                          p_commit_calculation_end_dt in date)  is
          Select fnd_number.canonical_to_number(pev.screen_entry_value),
                 pev.effective_start_date, pev.effective_end_date
          from   pay_element_entry_values_f pev
          ,      pay_element_entries_f pee
          where  pee.assignment_id = p_assignment_id
   --         and  p_commit_calculation_dt
   --              between pee.effective_start_date and pee.effective_end_date
            and pee.effective_start_date <=  p_commit_calculation_end_dt
            and pee.effective_end_date >= p_commit_calculation_dt
            and  pev.element_entry_id = pee.element_entry_id
            and  pev.input_value_id = p_input_value_id
            and  pev.effective_start_date  <= p_commit_calculation_end_dt
            and  pev.effective_end_date    >= p_commit_calculation_dt;

--            and  p_commit_calculation_dt
--                between pev.effective_start_date and pev.effective_end_date;
--
  l_proc        varchar2(72) := g_package||'get_commitment_from_sal_basis';
  l_input_value_id number;
  l_eot date := to_date('31-12-4712','DD-MM-RRRR');
--
   l_stDt date;
   l_edDt date;
   ad_stDt date;
   ad_edDt date;
   l_inter_amt number;
Begin
--
--
hr_utility.set_location('Entering:'||l_proc, 5);
--

hr_utility.set_location('p_pay_basis_id'||p_pay_basis_id, 5);
hr_utility.set_location('p_assignment_id'||p_assignment_id,5);
hr_utility.set_location('p_commit_calculation_dt'||p_commit_calculation_dt,5);
hr_utility.set_location('p_element_type_id'||p_element_type_id,5);
     l_entry_value := NULL;
     l_pay_basis   := NULL;
     --
     Open csr_pay_basis(p_pay_basis_id          => p_pay_basis_id,
                        p_commit_calculation_dt => nvl(p_actual_cmmtmnt_start_dt,l_eot),
                        p_commit_calculation_end_dt => p_actual_cmmtmnt_end_dt) ;
     Fetch csr_pay_basis into l_pay_basis,l_input_value_id;
     Close csr_pay_basis;

     hr_utility.set_location('PB Input value is'||l_input_value_id,8);
     if l_input_value_id is null then
        return null;
     end if;
     Open csr_salary_basis(p_assignment_id         => p_assignment_id,
                           p_input_value_id        => l_input_value_id,
                           p_commit_calculation_dt => nvl(p_actual_cmmtmnt_start_dt,l_eot),
                          p_commit_calculation_end_dt => p_commit_calculation_end_dt) ;
     --
     Loop
     Fetch csr_salary_basis into l_entry_value,l_stDt, l_edDt;
     Exit when csr_salary_basis%NotFound;
     --
     --
     -- CONVERT AMOUNT TO BUDGET_CALENDAR FREQUENCY
     --
     hr_utility.set_location('Figure :' || to_char(l_entry_value),10);
     hr_utility.set_location('From :' || l_pay_basis,15);
     hr_utility.set_location('To :' || p_commitment_calc_frequency,20);

     l_inter_amt := Convert_Period_Type(
	p_bus_grp_id	            => p_business_group_id,
	p_payroll_id                => p_payroll_id,
	p_asst_std_hours            => p_normal_hours,
	p_figure                    => l_entry_value,
	p_from_freq	            => l_pay_basis,
	p_to_freq                   => p_commitment_calc_frequency,
	p_period_start_date         => p_commit_calculation_dt,
	p_period_end_date           => p_commit_calculation_end_dt,
	p_asst_std_freq             => p_asst_frequency,
        p_dflt_elmnt_frequency      => p_dflt_elmnt_frequency,
        p_budget_calendar_frequency => p_budget_calendar_frequency
        );

     --
        If ( l_stDt > p_commit_calculation_dt ) then
             ad_stDt := l_stDt;
        else
             ad_stDt := p_commit_calculation_dt;
        end if;

        IF ( l_edDt > p_commit_calculation_end_dt ) then
             ad_edDt := p_commit_calculation_end_dt;
        else
             ad_edDt :=l_edDt;
        end if;

        --
        l_inter_amt := l_inter_amt * (ad_edDt - ad_stDt + 1)/365;
        --
        l_converted_amt := nvl(l_converted_amt,0) + nvl(l_inter_amt,0) ;
        --
	hr_utility.set_location('~~NS:Adjusted Start Date- End Date: '||ad_stDt||' - '||
	   ad_edDt||' - '||l_inter_amt,8);
	hr_utility.set_location('~~NS:l_converted_amt: '||l_converted_amt,8);

     End Loop;
     Close csr_salary_basis;

     --
     If p_actual_cmmtmnt_start_dt <>  p_commit_calculation_dt then
        --
        l_adjusted_start_dt := p_actual_cmmtmnt_start_dt;
        --
     Else
        l_adjusted_start_dt := p_commit_calculation_dt;
        --
     End if;

     If p_actual_cmmtmnt_end_dt <>  p_commit_calculation_end_dt   then
        --
        -- If the period for which we need to calculate commitment is lesser
        -- than the input period type , we have to further prorate the
        -- calculated commitment value for the no of days in the commitment
        -- calculation period .  This can happen only for the last period for
        -- which commitment is generated.
        --
        l_adjusted_end_dt := p_actual_cmmtmnt_end_dt;
        --
     Else
        l_adjusted_end_dt := p_commit_calculation_end_dt;
        --
     End if;
     --
     l_converted_amt := nvl(l_converted_amt,0) *
            (l_adjusted_end_dt - l_adjusted_start_dt + 1)/
            (p_commit_calculation_end_dt   - p_commit_calculation_dt + 1);
     --
     l_converted_amt := round(l_converted_amt,2);
     --
hr_utility.set_location('~~NS:Converted amount: '||l_converted_amt,8);
hr_utility.set_location('Leaving:'||l_proc, 25);
--
RETURN l_converted_amt;
--
End;
--
---------------------------Calculate_overhead---------------------------
--
FUNCTION Calculate_overhead(p_element_commitment  in  number,
                            p_overhead_percentage in  number,
                            p_element_overhead   out nocopy  number)
RETURN NUMBER
is
--
l_message_text_out               fnd_new_messages.message_text%TYPE;
--
l_proc        varchar2(72) := g_package||'calculate_overhead';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 If p_overhead_percentage <  0 then
    -- Log error
    -- get message text for PQH_NEG_OVERHEAD_PERCENT
    --
    FND_MESSAGE.SET_NAME('PQH','PQH_NEG_OVERHEAD_PERCENT');
    l_message_text_out := FND_MESSAGE.GET;
    --
    pqh_process_batch_log.insert_log
    (
        p_message_type_cd    =>  'ERROR',
        p_message_text       =>  l_message_text_out
    );
    RETURN -1;
 ElsIf p_overhead_percentage = 0 then
    p_element_overhead := 0;
 Else
    p_element_overhead := (p_overhead_percentage/100)*p_element_commitment;
 End if;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 RETURN 0;
--
exception when others then
return null;
raise;
End;
--
--------------------------------------------------------------------------------
--
PROCEDURE fetch_bdgt_cmmtmnt_elmnts(p_budget_id            in number,
                                    p_bdgt_cmmtmnt_elmnts out nocopy cmmtmnt_elmnts_tab)
is
--
cnt     number(15) := 0;
--
-- This cursor selects all the element types for which commitment has
-- to be calculated for a given budget.
--
Cursor csr_bdgt_commit_elmnts(p_budget_id in number) is
       Select Element_type_id,
              Formula_id,Salary_basis_flag,
              Element_input_value_id,
              dflt_elmnt_frequency,nvl(Overhead_percentage,0)
         From pqh_bdgt_cmmtmnt_elmnts
        Where budget_id = p_budget_id
        and actual_commitment_type in ('COMMITMENT','BOTH');
--
-- This cursor is used to get the budget versions if there are no elements
-- defined for a budget.
--
Cursor csr_bdgt_version is
    select budget_version_id from pqh_budget_versions
       where budget_id = p_budget_id;
--
l_budget_version_id number;
--
l_proc        varchar2(72) := g_package||'fetch_bdgt_cmmtmnt_elmnts';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
    Open csr_bdgt_commit_elmnts(p_budget_id => p_budget_id);
    --
    -- CALCULATE COMMITMENT FOR EACH ELEMENT TYPE OF A POSITION
    --
    Loop
    --
      cnt := cnt + 1;
      --
      Fetch csr_bdgt_commit_elmnts into
            p_bdgt_cmmtmnt_elmnts(cnt).Element_type_id,
            p_bdgt_cmmtmnt_elmnts(cnt).Formula_id,
            p_bdgt_cmmtmnt_elmnts(cnt).Salary_basis_flag,
            p_bdgt_cmmtmnt_elmnts(cnt).Element_input_value_id,
            p_bdgt_cmmtmnt_elmnts(cnt).dflt_elmnt_frequency,
            p_bdgt_cmmtmnt_elmnts(cnt).Overhead_percentage;
      --
      If csr_bdgt_commit_elmnts%notfound then
         exit;
      End if;
      --
    End loop;
    --
    Close csr_bdgt_commit_elmnts;
    --
    cnt := cnt - 1;
    --
    If cnt = 0 then
       --
       -- Delete commitment value records if a budget does not have
       -- commitment elements.
       --
       Open csr_bdgt_version;
       Loop
          Fetch csr_bdgt_version into l_budget_version_id;
       --
          Delete from  pqh_element_commitments
          where budget_version_id = l_budget_version_id;
          commit;
       --
          If csr_bdgt_version%notfound then
             exit;
          End if;
       End loop;
       --
       Close csr_bdgt_version;
       --
       FND_MESSAGE.SET_NAME('PQH','PQH_NO_BDGT_CMMTMNT_EMNTS');
       APP_EXCEPTION.RAISE_EXCEPTION;
       --
    End if;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
EXCEPTION
      WHEN OTHERS THEN
       raise;
--
End;
--
FUNCTION check_non_susp_assignment(p_commit_calculation_dt     in   date,
                               p_assignment_id             in   number )
RETURN BOOLEAN
is
cursor curs_susp_chk is
SELECT   1
  FROM  per_assignments_f asg, per_assignment_status_types ast
  WHERE asg.assignment_id = p_assignment_id
  AND   p_commit_calculation_dt between asg.effective_start_date and asg.effective_end_date
  AND   asg.assignment_status_type_id = ast.assignment_status_type_id
  AND   ast.per_system_status <> 'TERM_ASSIGN'
  AND   (ast.per_system_status <> 'SUSP_ASSIGN' OR (ast.per_system_status = 'SUSP_ASSIGN' AND   ast.pay_system_status = 'P') );

l_dummy number;
l_is_not_susp boolean := false;
l_proc  varchar2(72) := g_package||'check_non_susp_assignment';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  Open curs_susp_chk;
  Fetch curs_susp_chk into l_dummy;
  if (l_dummy = 1)
  THEN
   l_is_not_susp :=true;
  End if;
  Close curs_susp_chk;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  Return l_is_not_susp;
Exception
When others then
 raise;
End check_non_susp_assignment;

-----------------------populate_commitment_table---------------------------------
--
FUNCTION  populate_commitment_table(p_budgeted_entity_cd        in   varchar2,
				                    p_commit_calculation_dt     in   date,
                                    p_actual_cmmtmnt_start_dt   in   date,
                                    p_commit_end_dt             in   date,
                                    p_actual_cmmtmnt_end_dt     in   date,
                                    p_commitment_calc_frequency in   varchar2,
                                    p_budget_calendar_frequency in   varchar2,
                                    p_entity_id                 in   number,
                                    p_budget_id                 in   number,
                                    p_budget_version_id         in   number,
                                    p_assignment_id             in   number default null)
RETURN NUMBER
is
--
-- Cursor added for LD integration with Position Control
--This cursor checks if Budget is a position controll or not
--
Cursor csr_posctrl_budget_chk IS
Select 1
From   PQH_BUDGETS BGT
Where  BGT.BUDGET_ID =p_budget_id  And
       BGT.POSITION_CONTROL_FLAG ='Y';
    /* BGT.budgeted_entity_cd='POSITION' And   LD Integration is not limited for Position Control Budgets only
       BGT.transfer_to_grants_flags ='Y' And   We will Check for ecumbrance even when Budget is not
                                               being transfered to grants
    */
-- This cursor selects all active assignments for a position and the pay
-- basis of the assignment.Also select business_group_id,payroll id,
-- normal hours,frequency for the assignment.
--
Cursor csr_pos_assignments(p_commit_calculation_dt in date,
                           p_commit_end_dt             in   date,
                           p_position_id           in number) is
       Select assignment_id,pay_basis_id,
              business_group_id,payroll_id,
              normal_hours,frequency,
              effective_start_date,
              effective_end_date
         From per_all_assignments_f
        Where position_id = p_position_id
         And  p_commit_calculation_dt <= effective_end_date
         and p_commit_end_dt >= effective_start_date;


Cursor csr_pos_single_assignment(p_assignment_id in number) is
       Select assignment_id,pay_basis_id,
              business_group_id,payroll_id,
              normal_hours,frequency,
              effective_start_date,
              effective_end_date
         From per_all_assignments_f
        Where assignment_id = p_assignment_id
         And  p_commit_calculation_dt <= effective_end_date
         and p_commit_end_dt >= effective_start_date;
--
--
Cursor csr_org_assignments(p_commit_calculation_dt in date,
                           p_commit_end_dt             in   date,
                           p_organization_id           in number) is
       Select assignment_id,pay_basis_id,
              business_group_id,payroll_id,
              normal_hours,frequency,
              effective_start_date,
              effective_end_date
         From per_all_assignments_f
        Where organization_id = p_organization_id
         And  p_commit_calculation_dt <= effective_end_date
         and p_commit_end_dt >= effective_start_date;
--
Cursor csr_job_assignments(p_commit_calculation_dt in date,
                           p_commit_end_dt             in   date,
                           p_job_id           in number) is
       Select assignment_id,pay_basis_id,
              business_group_id,payroll_id,
              normal_hours,frequency,
              effective_start_date,
              effective_end_date
         From per_all_assignments_f
        Where job_id  = p_job_id
         And  p_commit_calculation_dt <= effective_end_date
         and p_commit_end_dt >= effective_start_date;

--
Cursor csr_grade_assignments(p_commit_calculation_dt in date,
                            p_commit_end_dt             in   date,
                            p_grade_id           in number) is
       Select assignment_id,pay_basis_id,
              business_group_id,payroll_id,
              normal_hours,frequency,
              effective_start_date,
              effective_end_date
         From per_all_assignments_f
        Where grade_id = p_grade_id
         And  p_commit_calculation_dt <= effective_end_date
         and p_commit_end_dt >= effective_start_date;

--
--
-- DECLARE all local variables.
--
--define a record to store the details.
type entity_assignment_rec is record (
assignment_id             per_all_assignments_f.assignment_id%type,
pay_basis_id              per_all_assignments_f.pay_basis_id%type,
business_group_id         per_all_assignments_f.business_group_id%type,
payroll_id                per_all_assignments_f.payroll_id%type,
normal_hours              per_all_assignments_f.normal_hours%type,
frequency                 per_all_assignments_f.frequency%type,
effective_start_date      per_all_assignments_f.effective_start_date%type,
effective_end_date        per_all_assignments_f.effective_end_date%type
);

type element_commitment_rec is record (
assignment_id       per_all_assignments_f.assignment_id%type,
commitment          number,
element_type_id     pqh_bdgt_cmmtmnt_elmnts.element_type_id%type
);



--
type entity_assignments_tab is table of entity_assignment_rec index by binary_integer;
type element_commitments_tab is table of element_commitment_rec index by binary_integer;

--
t_entity_assignments entity_assignments_tab;
t_element_commitment element_commitments_tab;
l_entity_rec_cnt 	   NUMBER := 0;

--
l_assignment_commitment     number;
l_entry_commitment          number;
l_element_overhead          number;
--
l_message_text_out          fnd_new_messages.message_text%TYPE;
cnt                         number;
--
  l_proc        varchar2(72) := g_package||'populate_commitment_table';
--
  l_status      number;
--
-- Variables for LD integration with position control
  l_dummy              number;
  ld_is_present        boolean :=false;
  l_psp_asg_encumbered boolean :=false;
  ld_return_status     varchar2(10);
  l_asg_detail_tab     psp_pqh_integration.encumbrance_table_rec_col;
  ld_call_error        exception;
  l_is_assign_susp     boolean := false;
  already_exists_flag boolean := false;
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
hr_utility.set_location('Checking whether Budget is a Position Control  and Ld profile turned on', 6);

--
--Check whether we need to take LD encumbrnace in to consideration.
--If budget is a Control Budget and LD profile is turned on consider LD Assignment Encumbrance
--
Open csr_posctrl_budget_chk;
Fetch csr_posctrl_budget_chk into l_dummy;
if (csr_posctrl_budget_chk%FOUND AND fnd_profile.value('PSP_ENC_ENABLE_PQH')='Y') THEN
        ld_is_present                                                      :=true;
End if;
Close csr_posctrl_budget_chk;
--
hr_utility.set_location('CALCULATING FOR :'||to_char(p_actual_cmmtmnt_start_dt,'DD/MM/RRRR'),7);
--
--
-- CALCULATE COMMITMENT FOR EACH ASSIGMENT IN A POSITION WHICH IS EFFECTIVE
-- AS OF THE COMMIMENT CALCULATION DATE.
--
If p_entity_id is NOT NULL then
        --
        If p_budgeted_entity_cd ='POSITION' then
                ---
                if (p_assignment_id is null) then
                        --
                        hr_utility.set_location('Opening the assignements based on entity id  ' ||p_entity_id ||' '||p_actual_cmmtmnt_start_dt||' '||p_actual_cmmtmnt_end_dt ,10);

                        Open csr_pos_assignments( p_commit_calculation_dt => p_actual_cmmtmnt_start_dt,
                                                  p_commit_end_dt => p_actual_cmmtmnt_end_dt,
                                                  p_position_id => p_entity_id) ;
                        --
                Else
                        hr_utility.set_location('Opening the assignements based on assignment id ' ||p_assignment_id ,10);
                        Open csr_pos_single_assignment(p_assignment_id => p_assignment_id) ;
                End if;
                --
        Elsif p_budgeted_entity_cd ='JOB' then
                ---
                hr_utility.set_location('Opening the assignements based on Job id ' ,10);
                Open csr_job_assignments(p_job_id => p_entity_id,
                                          p_commit_end_dt => p_actual_cmmtmnt_end_dt,
                                          p_commit_calculation_dt => p_actual_cmmtmnt_start_dt) ;
                --
        Elsif p_budgeted_entity_cd ='GRADE' then
                --
                hr_utility.set_location('Opening the assignements based on Grade id ' ,10);
                Open csr_grade_assignments(p_grade_id => p_entity_id,
                                          p_commit_calculation_dt => p_actual_cmmtmnt_start_dt,
                                          p_commit_end_dt => p_actual_cmmtmnt_end_dt) ;
                --
        Elsif p_budgeted_entity_cd ='ORGANIZATION' then
                --
                hr_utility.set_location('Opening the assignements based on ORGANIZATION id ' ,10);
                Open csr_org_assignments(p_organization_id => p_entity_id,
                                         p_commit_calculation_dt => p_actual_cmmtmnt_start_dt,
                                         p_commit_end_dt => p_actual_cmmtmnt_end_dt) ;
                --
        End if;
        --
End if;
--Loop
--

hr_utility.set_location('--Next assignment--',10);
savepoint assignment_level;
--
l_entity_rec_cnt := 0;
If p_entity_id is NOT NULL then
        --
        If p_budgeted_entity_cd ='POSITION' then
                --
                If (p_assignment_id is null) then
                        --
                        loop
                                l_entity_rec_cnt := l_entity_rec_cnt +1 ;
                                hr_utility.set_location('Fetching the assignements based on Position ' ||l_entity_rec_cnt ,10);
                                Fetch csr_pos_assignments into t_entity_assignments(l_entity_rec_cnt).assignment_id,
                                                                t_entity_assignments(l_entity_rec_cnt).pay_basis_id,
                                                                t_entity_assignments(l_entity_rec_cnt).business_group_id,
                                                                t_entity_assignments(l_entity_rec_cnt).payroll_id,
                                                                t_entity_assignments(l_entity_rec_cnt).normal_hours,
                                                                t_entity_assignments(l_entity_rec_cnt).frequency,
                                                                 t_entity_assignments(l_entity_rec_cnt).effective_start_date,
                                                                 t_entity_assignments(l_entity_rec_cnt).effective_end_date;
                                --
                                If csr_pos_assignments%notfound then
                                        Close csr_pos_assignments;
                                        Exit;
                                End if;
                        end loop;
                        --
                Else
                        --
                        loop
                                l_entity_rec_cnt := l_entity_rec_cnt +1 ;
                                hr_utility.set_location('Fetching the assignements based on assignment id ' ||p_assignment_id ,10);
                                Fetch csr_pos_single_assignment into t_entity_assignments(l_entity_rec_cnt).assignment_id,
                                                                      t_entity_assignments(l_entity_rec_cnt).pay_basis_id,
                                                                      t_entity_assignments(l_entity_rec_cnt).business_group_id,
                                                                      t_entity_assignments(l_entity_rec_cnt).payroll_id,
                                                                      t_entity_assignments(l_entity_rec_cnt).normal_hours,
                                                                      t_entity_assignments(l_entity_rec_cnt).frequency,
                                                                      t_entity_assignments(l_entity_rec_cnt).effective_start_date,
                                                                      t_entity_assignments(l_entity_rec_cnt).effective_end_date;
                                --
                                If csr_pos_single_assignment%notfound then
                                        Close csr_pos_single_assignment;
                                        Exit;
                                End if;
                        end loop;
                        --
                End if;
                --
        Elsif p_budgeted_entity_cd ='JOB' then
                ---
                loop
                        l_entity_rec_cnt := l_entity_rec_cnt +1 ;
                        hr_utility.set_location('Fetching the assignements based on job  ' ,10);
                        Fetch csr_job_assignments into t_entity_assignments(l_entity_rec_cnt).assignment_id,
                                                       t_entity_assignments(l_entity_rec_cnt).pay_basis_id,
                                                       t_entity_assignments(l_entity_rec_cnt).business_group_id,
                                                       t_entity_assignments(l_entity_rec_cnt).payroll_id,
                                                       t_entity_assignments(l_entity_rec_cnt).normal_hours,
                                                       t_entity_assignments(l_entity_rec_cnt).frequency,
                                                       t_entity_assignments(l_entity_rec_cnt).effective_start_date,
                                                       t_entity_assignments(l_entity_rec_cnt).effective_end_date;
                        --
                        If csr_job_assignments%notfound then
                                Close csr_job_assignments;
                                Exit;
                        End if;
                end loop;
                ---
        Elsif p_budgeted_entity_cd ='GRADE' then
                ---
                loop
                        l_entity_rec_cnt := l_entity_rec_cnt +1 ;
                        hr_utility.set_location('Fetching the assignements based on Grade  ' ,10);
                        Fetch csr_grade_assignments into t_entity_assignments(l_entity_rec_cnt).assignment_id,
                                                          t_entity_assignments(l_entity_rec_cnt).pay_basis_id,
                                                          t_entity_assignments(l_entity_rec_cnt).business_group_id,
                                                          t_entity_assignments(l_entity_rec_cnt).payroll_id,
                                                          t_entity_assignments(l_entity_rec_cnt).normal_hours,
                                                          t_entity_assignments(l_entity_rec_cnt).frequency,
                                                          t_entity_assignments(l_entity_rec_cnt).effective_start_date,
                                                          t_entity_assignments(l_entity_rec_cnt).effective_end_date;
                        --
                        If csr_grade_assignments%notfound then
                                Close csr_grade_assignments;
                                Exit;
                        End if;
                END loop;
                ---
        Elsif p_budgeted_entity_cd ='ORGANIZATION' then
                ---
                loop
                        l_entity_rec_cnt := l_entity_rec_cnt +1 ;
                        hr_utility.set_location('Fetching the assignements based on Org  ' ,10);
                        Fetch csr_org_assignments into t_entity_assignments(l_entity_rec_cnt).assignment_id,
                                                       t_entity_assignments(l_entity_rec_cnt).pay_basis_id,
                                                       t_entity_assignments(l_entity_rec_cnt).business_group_id,
                                                       t_entity_assignments(l_entity_rec_cnt).payroll_id,
                                                       t_entity_assignments(l_entity_rec_cnt).normal_hours,
                                                       t_entity_assignments(l_entity_rec_cnt).frequency,
                                                        t_entity_assignments(l_entity_rec_cnt).effective_start_date,
                                                        t_entity_assignments(l_entity_rec_cnt).effective_end_date;
                        --
                        If csr_org_assignments%notfound then
                                Close csr_org_assignments;
                                Exit;
                        End if;
                END loop ;
        End if;
        --
End if;
--
--Check if LD encumbered for this Assignment during given period.
--If yes then we need not calculate any commitments for this Assignment and Period;we will
--delete any existing records from pqh_element_commitmetns for that Assignment and Period

hr_utility.set_location('Fetched all the records - Record Count  '||t_entity_assignments.COUNT ,20);
--

for assign_cnt in NVL(t_entity_assignments.FIRST,0)..NVL(t_entity_assignments.LAST,-1)
loop
          hr_utility.set_location('t_entity_assignments(assign_cnt).effective_start_date '||t_entity_assignments(assign_cnt).effective_start_date  ,20);
          hr_utility.set_location('p_actual_cmmtmnt_start_dt '||p_actual_cmmtmnt_start_dt  ,20);
          hr_utility.set_location('t_entity_assignments(assign_cnt).effective_end_date '||t_entity_assignments(assign_cnt).effective_end_date  ,20);
          hr_utility.set_location('p_actual_cmmtmnt_end_dt '||p_actual_cmmtmnt_end_dt  ,20);

        --Change the commitment_start_date and commitment_end_date as per the
        --assigment details. So that the commitments for the date tracked assigment is calculated correctly.
         if t_entity_assignments(assign_cnt).effective_start_date < p_actual_cmmtmnt_start_dt  then
              hr_utility.set_location('Adjusting effective start date'||p_actual_cmmtmnt_start_dt ,20);
            t_entity_assignments(assign_cnt).effective_start_date := p_actual_cmmtmnt_start_dt ;
         end if;

         if nvl(t_entity_assignments(assign_cnt).effective_end_date,to_date('31-12-4712','DD-MM-RRRR')) > p_actual_cmmtmnt_end_dt  then
            hr_utility.set_location('Adjusting effective end date' ||p_actual_cmmtmnt_end_dt ,20);
            t_entity_assignments(assign_cnt).effective_end_date := p_actual_cmmtmnt_end_dt ;
         end if;

        hr_utility.set_location('Assignment_id :'||to_char(t_entity_assignments(assign_cnt).assignment_id),12);
        l_psp_asg_encumbered :=false;
        IF (ld_is_present) THEN
                hr_utility.set_location('Caling GET_ASG_ENCUMBRANCES with following Params :',13);
                hr_utility.set_location('Encumbrace Start Date :'||to_char(p_actual_cmmtmnt_start_dt),14);
                hr_utility.set_location('Encumbrance End Date  :'||to_char(p_actual_cmmtmnt_end_dt),15);
                PSP_PQH_INTEGRATION.GET_ASG_ENCUMBRANCES( P_ASSIGNMENT_ID =>t_entity_assignments(assign_cnt).assignment_id,
                                                        P_ENCUMBRANCE_START_DATE => t_entity_assignments(assign_cnt).effective_start_date,
                                                        P_ENCUMBRANCE_END_DATE => t_entity_assignments(assign_cnt).effective_end_date,
                                                        P_ENCUMBRANCE_TABLE =>l_asg_detail_tab,
                                                        P_ASG_PSP_ENCUMBERED =>l_psp_asg_encumbered,
                                                        P_RETURN_STATUS =>ld_return_status);

                IF(ld_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE ld_call_error;
                END IF;
                IF(l_psp_asg_encumbered) THEN
                        hr_utility.set_location('LD Encumbered this Assignment:'||to_char(t_entity_assignments(assign_cnt).assignment_id),16);
                END IF;
        END IF;
        l_is_assign_susp := check_non_susp_assignment(t_entity_assignments(assign_cnt).effective_start_date,
                                                      t_entity_assignments(assign_cnt).assignment_id);
        --
        --Process this Assignment only if LD has not encumbered it
        --
        if (l_is_assign_susp            = true) THEN
                if( l_psp_asg_encumbered= false) THEN
                        hr_utility.set_location('Assignment not Encumbered by LD:'||to_char(t_entity_assignments(assign_cnt).assignment_id),18);
                        --
                        -- FOR EACH ASSIGNMENT CALCULATE ELEMENT LEVEL COMMITMENT
                        --
                        For cnt in NVL(g_bdgt_cmmtmnt_elmnts.FIRST,0)..NVL(g_bdgt_cmmtmnt_elmnts.LAST,-1)
                        Loop

                                --
                                hr_utility.set_location('ELMNT TYPE:'||to_char(g_bdgt_cmmtmnt_elmnts(cnt).element_type_id),19);
                                --
                                --
                                l_entry_commitment := 0;
                                --
                                hr_utility.set_location('p_actual_cmmtmnt_start_dt'||p_actual_cmmtmnt_start_dt,20);
                                hr_utility.set_location('p_actual_cmmtmnt_end_dt'||p_actual_cmmtmnt_end_dt,20);
                                --
                                If g_bdgt_cmmtmnt_elmnts(cnt).formula_id is not null then
                                        --
                                        hr_utility.set_location('Calculating for Formula',20);
                                        --
                                        l_entry_commitment := get_commitment_from_formula (p_formula_id => g_bdgt_cmmtmnt_elmnts(cnt).formula_id,
                                                                                            p_business_group_id => t_entity_assignments(assign_cnt).business_group_id,
                                                                                            p_assignment_id => t_entity_assignments(assign_cnt).assignment_id,
                                                                                            p_payroll_id => t_entity_assignments(assign_cnt).payroll_id,
                                                                                            p_element_type_id => g_bdgt_cmmtmnt_elmnts(cnt).element_type_id,
                                                                                            p_effective_date => p_actual_cmmtmnt_start_dt,
                                                                                            p_element_input_value_id => g_bdgt_cmmtmnt_elmnts(cnt).element_input_value_id,
                                                                                            p_commitment_start_date => t_entity_assignments(assign_cnt).effective_start_date,
                                                                                            p_commitment_end_date => t_entity_assignments(assign_cnt).effective_end_date);
                                        --
                                ElsIf g_bdgt_cmmtmnt_elmnts(cnt).salary_basis_flag = 'Y' then
                                        --
                                        hr_utility.set_location('Calculating for Salary Basis',21);
                                        --
                                        -- The commitment for this element type is to be calculated
                                        -- from salary basis;
                                        --
                                        -- If pay basis id is available then calculate commitment based
                                        -- on salary basis.Ideally pay basis id should be available. If
                                        -- it is not available , we will try calculating commitment
                                        -- based on element input value id.
                                        --
                                        If t_entity_assignments(assign_cnt).pay_basis_id IS NOT NULL then
                                                --
                                                --
                                                hr_utility.set_location('Valid Pay Basis id',25);
                                                --
                                                l_entry_commitment := get_commitment_from_sal_basis( p_commit_calculation_dt => p_commit_calculation_dt,
                                                                                                     p_actual_cmmtmnt_start_dt => t_entity_assignments(assign_cnt).effective_start_date,
                                                                                                     p_commit_calculation_end_dt => p_commit_end_dt,
                                                                                                     p_actual_cmmtmnt_end_dt => t_entity_assignments(assign_cnt).effective_end_date,
                                                                                                     p_element_type_id => g_bdgt_cmmtmnt_elmnts(cnt).element_type_id,
                                                                                                     p_commitment_calc_frequency => p_commitment_calc_frequency,
                                                                                                     p_budget_calendar_frequency => p_budget_calendar_frequency,
                                                                                                     p_dflt_elmnt_frequency => g_bdgt_cmmtmnt_elmnts(cnt).dflt_elmnt_frequency,
                                                                                                     p_business_group_id => t_entity_assignments(assign_cnt).business_group_id,
                                                                                                     p_assignment_id => t_entity_assignments(assign_cnt).assignment_id,
                                                                                                     p_payroll_id => t_entity_assignments(assign_cnt).payroll_id,
                                                                                                     p_pay_basis_id => t_entity_assignments(assign_cnt).pay_basis_id,
                                                                                                     p_normal_hours => t_entity_assignments(assign_cnt).normal_hours,
                                                                                                     p_asst_frequency => t_entity_assignments(assign_cnt).frequency);
                                                --
                                        Else
                                                --
                                                hr_utility.set_location('Pay basis id is NULL',30);
                                                --
                                                If g_bdgt_cmmtmnt_elmnts(cnt).element_input_value_id IS NOT NULL then
                                                        --
                                                        hr_utility.set_location('Default to element type calc',35);
                                                        --
                                                        l_entry_commitment := get_commitment_from_elmnt_type( p_commit_calculation_dt => p_commit_calculation_dt,
                                                                                                            p_actual_cmmtmnt_start_dt => t_entity_assignments(assign_cnt).effective_start_date,
                                                                                                            p_commit_calculation_end_dt => p_commit_end_dt,
                                                                                                            p_actual_cmmtmnt_end_dt => t_entity_assignments(assign_cnt).effective_end_date,
                                                                                                            p_commitment_calc_frequency => p_commitment_calc_frequency,
                                                                                                            p_budget_calendar_frequency => p_budget_calendar_frequency,
                                                                                                            p_dflt_elmnt_frequency => g_bdgt_cmmtmnt_elmnts(cnt).dflt_elmnt_frequency,
                                                                                                            p_business_group_id => t_entity_assignments(assign_cnt).business_group_id,
                                                                                                            p_assignment_id => t_entity_assignments(assign_cnt).assignment_id,
                                                                                                            p_payroll_id => t_entity_assignments(assign_cnt).payroll_id,
                                                                                                            p_pay_basis_id => t_entity_assignments(assign_cnt).pay_basis_id,
                                                                                                            p_element_type_id => g_bdgt_cmmtmnt_elmnts(cnt).element_type_id,
                                                                                                            p_element_input_value_id => g_bdgt_cmmtmnt_elmnts(cnt).element_input_value_id,
                                                                                                            p_normal_hours => t_entity_assignments(assign_cnt).normal_hours,
                                                                                                            p_asst_frequency => t_entity_assignments(assign_cnt).frequency);
                                                        --
                                                Else
                                                        -- Log error
                                                        -- get message text for PQH_ERROR_ELMNT_CMMTMNT
                                                        --
                                                        FND_MESSAGE.SET_NAME('PQH','PQH_ERROR_ELMNT_CMMTMNT');
                                                        l_message_text_out                                  := FND_MESSAGE.GET;
                                                        pqh_process_batch_log.insert_log ( p_message_type_cd => 'ERROR', p_message_text => l_message_text_out );
                                                        --RETURN -1;
                                                        rollback to assignment_level;
                                                        if (p_assignment_id is Null) then
                                                                Exit;
                                                        end if;
                                                        --
                                                End if;
                                                --
                                        End if;
                                        --
                                Else
                                        --
                                        hr_utility.set_location('Calc from element type',40);
                                        --
                                        l_entry_commitment := get_commitment_from_elmnt_type( p_commit_calculation_dt =>p_commit_calculation_dt,
                                                                                              p_actual_cmmtmnt_start_dt =>  t_entity_assignments(assign_cnt).effective_start_date,
                                                                                              p_commit_calculation_end_dt => p_commit_end_dt,
                                                                                              p_actual_cmmtmnt_end_dt => t_entity_assignments(assign_cnt).effective_end_date,
                                                                                              p_commitment_calc_frequency => p_commitment_calc_frequency,
                                                                                              p_budget_calendar_frequency => p_budget_calendar_frequency,
                                                                                              p_dflt_elmnt_frequency => g_bdgt_cmmtmnt_elmnts(cnt).dflt_elmnt_frequency,
                                                                                              p_business_group_id => t_entity_assignments(assign_cnt).business_group_id,
                                                                                              p_assignment_id => t_entity_assignments(assign_cnt).assignment_id,
                                                                                              p_payroll_id => t_entity_assignments(assign_cnt).payroll_id,
                                                                                              p_pay_basis_id => t_entity_assignments(assign_cnt).pay_basis_id,
                                                                                              p_element_type_id => g_bdgt_cmmtmnt_elmnts(cnt).element_type_id,
                                                                                              p_element_input_value_id => g_bdgt_cmmtmnt_elmnts(cnt).element_input_value_id,
                                                                                              p_normal_hours => t_entity_assignments(assign_cnt).normal_hours,
                                                                                              p_asst_frequency => t_entity_assignments(assign_cnt).frequency);
                                        --
                                        --
                                End if;
                                --
                                hr_utility.set_location('Entry commitment :'||to_char(nvl(l_entry_commitment,0)),45);
                                --
                                --
                                l_status := Calculate_overhead (p_element_commitment => l_entry_commitment,
                                                                p_overhead_percentage => g_bdgt_cmmtmnt_elmnts(cnt).Overhead_percentage,
                                                                p_element_overhead => l_element_overhead);
                                --
                                hr_utility.set_location('Calculate_overhead finished:'||l_status,45);
                                If l_status = -1 then
                                        rollback to assignment_level;
                                                Exit;
                                End if;
                                hr_utility.set_location('Calculate_overhead is success',45);
                                --
                                --
                                -- If commitment is being re-generated for the same position and same
                                -- dates we will delete the old record with the commitment values .
                                -- Then we will insert a new record.
                                --
                                --Adding into the plsql table if the commitments are not already added otherwise updating and then performing insert to avoid duplicate datas.

                                if t_element_commitment.FIRST is null then
                                     hr_utility.set_location('First element is created in t_element_commitment',40);
                                     t_element_commitment(1).assignment_id := t_entity_assignments(assign_cnt).assignment_id ;
                                     t_element_commitment(1).element_type_id := g_bdgt_cmmtmnt_elmnts(cnt).element_type_id ;
                                     t_element_commitment(1).commitment := (l_entry_commitment+l_element_overhead) ;
                                else
                                    hr_utility.set_location('Its not the first element',40);
                                    already_exists_flag := false;
                                    for element_cnt in NVL(t_element_commitment.FIRST,0)..NVL(t_element_commitment.LAST,-1) loop
                                          hr_utility.set_location('inside for loop',40);
                                          hr_utility.set_location('assignement' || t_element_commitment(element_cnt).assignment_id ||'x'||t_entity_assignments(assign_cnt).assignment_id,40);
                                          hr_utility.set_location('element type'||t_element_commitment(element_cnt).ELEMENT_TYPE_ID ||'x'||g_bdgt_cmmtmnt_elmnts(cnt).element_type_id ,40);
                                      if (t_element_commitment(element_cnt).assignment_id = t_entity_assignments(assign_cnt).assignment_id and
                                          t_element_commitment(element_cnt).ELEMENT_TYPE_ID = g_bdgt_cmmtmnt_elmnts(cnt).element_type_id) then
                                          hr_utility.set_location('Already existing value is updated cnt is:'||element_cnt,40);
                                          t_element_commitment(element_cnt).commitment := t_element_commitment(element_cnt).commitment + l_entry_commitment+l_element_overhead ;
                                          already_exists_flag := true;
                                          EXit;
                                      end if;
                                    end loop;
                                    if (not already_exists_flag ) then
                                     declare
                                      element_cnt number;
                                     begin
                                      element_cnt  := t_element_commitment.COUNT+1 ;
                                     hr_utility.set_location('new element is created @:'||(t_element_commitment.COUNT+1),40);
                                     t_element_commitment(element_cnt).assignment_id := t_entity_assignments(assign_cnt).assignment_id ;
                                     t_element_commitment(element_cnt).ELEMENT_TYPE_ID := g_bdgt_cmmtmnt_elmnts(cnt).element_type_id;
                                     t_element_commitment(element_cnt).commitment := l_entry_commitment+l_element_overhead ;
                                    end;
                                    end if;
                                end if;                                      --
                                --
                                --
                        End loop;
                        /** element type commitment calcultion **/
                        --
                Else
                        /** l_psp_asg_encumbered= true   LD has encumbered **/
                        --  LD Encumbered for this assignment , so there will be no PQH commitmens for this assignment
                        --. Delete Assignment and Period records from pqh_commitment_elements
                        --
                        hr_utility.set_location('Delete LD encumbered commitments'||to_char(t_entity_assignments(assign_cnt).assignment_id),55);
                        --
                        DELETE
                        FROM    pqh_element_commitments
                        WHERE   budget_version_id = p_budget_version_id
                            AND ASSIGNMENT_ID     = t_entity_assignments(assign_cnt).assignment_id
                            AND (COMMITMENT_START_DATE BETWEEN p_actual_cmmtmnt_start_dt AND p_actual_cmmtmnt_end_dt
                             OR p_actual_cmmtmnt_start_dt BETWEEN COMMITMENT_START_DATE AND COMMITMENT_END_DATE);
                End if;
                /** End of check for LD encumbrance **/
        End if;
        /** End of check for suspended assignment **/
End loop;
hr_utility.set_location('Consolidated the values now proceeding to insert',48);
 -- Printing the content of the t_element_commitment
 FOR cnt in NVL(t_element_commitment.FIRST,0)..NVL(t_element_commitment.LAST,-1) LOOP
         hr_utility.set_location(t_element_commitment(cnt).element_type_id||'x'||t_element_commitment(cnt).assignment_id||'x'||t_element_commitment(cnt).commitment,48);
 end loop;
 --end printing
    FOR cnt in NVL(t_element_commitment.FIRST,0)..NVL(t_element_commitment.LAST,-1) LOOP
          hr_utility.set_location('Insert commitment'||cnt,48);
          hr_utility.set_location('ELEMENT_TYPE_ID: '|| t_element_commitment(cnt).element_type_id||'ASSIGNMENT_ID: '||t_element_commitment(cnt).assignment_id,48);
          hr_utility.set_location('BUDGET_VERSION_ID: '||p_BUDGET_VERSION_ID,48);
          --
          INSERT
          INTO    pqh_element_commitments
                  (
                          ELEMENT_COMMITMENT_ID ,
                          BUDGET_VERSION_ID,
                          ASSIGNMENT_ID,
                          ELEMENT_TYPE_ID,
                          COMMITMENT_START_DATE,
                          COMMITMENT_END_DATE,
                          COMMITMENT_CALC_FREQUENCY,
                          COMMITMENT_AMOUNT,
                          CREATION_DATE,
                          CREATED_BY
                  )
                  VALUES
                  (
                          pqh_element_commitments_s.nextval ,
                          p_budget_version_id,
                          t_element_commitment(cnt).assignment_id,
                          t_element_commitment(cnt).element_type_id,
                          p_actual_cmmtmnt_start_dt,
                          p_actual_cmmtmnt_end_dt,
                          p_commitment_calc_frequency,
                          t_element_commitment(cnt).commitment,
                          sysdate,
                          -1
                  )
                  ;
          hr_utility.set_location('Insert commitment2',48);
  end loop;

/** assignment commitment calculation **/
--
hr_utility.set_location('Leaving:'||l_proc, 60);
--
RETURN 0;
--
Exception
When ld_call_error then
        -- Log error

        hr_utility.set_location('Exception raised when inserting record into elements table',1);
        pqh_process_batch_log.insert_log ( p_message_type_cd => 'ERROR', p_message_text => SQLERRM );
        RETURN -1;
When others then
        -- Log error

        hr_utility.set_location('Exception raised when inserting record into elements table',2);
        pqh_process_batch_log.insert_log ( p_message_type_cd => 'ERROR', p_message_text => SQLERRM );
        RETURN -1;
End POPULATE_COMMITMENT_TABLE;


--
PROCEDURE relieve_commitment(
                    errbuf                 out nocopy varchar2,
                    retcode                out nocopy varchar2,
                    p_effective_date        in varchar2,
                    p_budgeted_entity_cd    in varchar2,
                    p_budget_version_id     in number,
                    p_post_to_period_name in varchar2) is
begin
   null;
end;
---------------------------calculate_commitment--------------------------
--
-- This is the main function that calculates commitment for a budget_version
-- or position.Also commitment is calculated only for money . For other UOM's
-- the  commitment for the required period is  already available in the
-- assignment budget values and hence there is no calculation required.
--
-- 2288274 Added paramenters p_budgeted_entity_cd, p_entity_id
-- p_budget_version_id depends on p_budged_entity_cd
--
PROCEDURE calculate_commitment(
                    errbuf                 out nocopy varchar2,
                    retcode                out nocopy varchar2,
                    p_budgeted_entity_cd    in varchar2,
                    p_budget_version_id     in number,
                    p_entity_id		    in number default null,
                  /*  p_cmmtmnt_start_dt      in varchar2,
                    p_cmmtmnt_end_dt        in varchar2,*/
                    p_period_frequency      in varchar2   default null)
IS
--
l_proc             varchar2(72) := g_package||'calculate_commitment';
--
/*l_cmmtmnt_start_dt date;
l_cmmtmnt_end_dt   date;*/
--
Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
 /*     --Kmullapu : Removed these params as we are no longer  using commitment date
                     Commitment dates are defaulted to Budget Dates.
  l_cmmtmnt_start_dt := fnd_date.canonical_to_date(p_cmmtmnt_start_dt);
  l_cmmtmnt_end_dt := fnd_date.canonical_to_date(p_cmmtmnt_end_dt);
 */
  --
  --
  --
  --Since the commitments were recalculated for all the calendar periods for this budget.
  --we are deleting the old records
  delete from pqh_element_commitments where budget_version_id = p_budget_version_id ;

  Calculate_money_cmmtmnts
                     (p_budgeted_entity_cd  => p_budgeted_entity_cd,
                      p_budget_version_id   => p_budget_version_id,
                      p_entity_id           => p_entity_id,
                     /* p_cmmtmnt_start_dt    => l_cmmtmnt_start_dt,
                      p_cmmtmnt_end_dt      => l_cmmtmnt_end_dt,*/
                      p_period_frequency    => p_period_frequency);
  --
  COMMIT;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
-----------------------calculate_money_cmmtmnts--------------------------------
--
PROCEDURE calculate_money_cmmtmnts
                            (p_budgeted_entity_cd    in varchar2,
                             p_budget_version_id     in number,
                             p_entity_id             in number,
                             /*p_cmmtmnt_start_dt      in date,
                             p_cmmtmnt_end_dt        in date,*/
                             p_period_frequency      in varchar2 default null)
IS
--
l_proc        varchar2(72) := g_package||'calculate_money_cmmtmnts';
--
l_position_name             hr_all_positions_f.name%type := NULL;
l_entity_name               pqh_cmmtmnt_entities_v.entity_name%type := NULL;
--
l_budget_id                 pqh_budgets.budget_id%type := NULL;
l_budget_name               pqh_budgets.budget_name%type := NULL;
l_period_set_name           pqh_budgets.period_set_name%type := NULL;
l_budget_cal_freq           pay_calendars.actual_period_type%type;
l_budget_start_date         date;
l_budget_end_date           date;
l_cmmtmnt_start_dt          date;
l_cmmtmnt_end_dt            date;
l_entity_id 		    number(30);
--
l_dummy_tab                 cmmtmnt_elmnts_tab;
--
pos_cnt                     number(15);
cnt                         number(15);
--
Cursor csrGetBudgetName(l_bdgt_id in number) Is
Select budget_name
From pqh_budgets
Where budget_id = l_bdgt_id;

--
l_status                    number(15);
--
l_context_level             number(15);
l_log_context               pqh_process_log.log_context%TYPE;
--
Begin
--

 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- CHECK IF THIS IS A VALID BUDGET VERSION.GET THE BUDGETS CALENDAR FREQ.
 --
 --
 Validate_budget(p_budgeted_entity_cd => p_budgeted_entity_cd,
 		 p_budget_version_id   => p_budget_version_id,
                 p_budget_id          => l_budget_id,
                 p_budget_name        => l_budget_name,
                 p_period_set_name    => l_period_set_name,
                 p_bdgt_cal_frequency => l_budget_cal_freq,
                 p_budget_start_date  => l_budget_start_date,
                 p_budget_end_date    => l_budget_end_date);

     l_cmmtmnt_start_dt := l_budget_start_date;
     l_cmmtmnt_end_dt   := l_budget_end_date;

 --
 -- CHECK IF THIS IS A VALID POSITION . ALSO DOES THIS POSITION
 -- BELONG IN THE PASSED BUDGET VERSION.
 --
 --
 Validate_entity(p_budgeted_entity_cd    => p_budgeted_entity_cd,
 		   p_budget_version_id     => p_budget_version_id,
                   p_entity_id             => p_entity_id,
                   p_entity_name           => l_entity_name);
 --
 -- If the passed frequency is null , we will generate commitments for the
 -- budget calendar frequency .
 --
 --
 --  VALIDATE THE COMMTMNT_START_DATE and CMMTMNT_END_DATE
 --

 Validate_commitment_dates
      (p_period_frequency     => nvl(p_period_frequency,l_budget_cal_freq),
       p_budget_cal_freq      => l_budget_cal_freq,
       p_period_set_name      => l_period_set_name,
       p_cmmtmnt_start_dt     => l_cmmtmnt_start_dt,
       p_cmmtmnt_end_dt       => l_cmmtmnt_end_dt,
       p_budget_start_date    => l_budget_start_date,
       p_budget_end_date      => l_budget_end_date);
 --
 -- Fetch all the commitment elments for this budget.
 --
 g_bdgt_cmmtmnt_elmnts := l_dummy_tab;
 --
 fetch_bdgt_cmmtmnt_elmnts( p_budget_id           => l_budget_id,
                            p_bdgt_cmmtmnt_elmnts => g_bdgt_cmmtmnt_elmnts);
 --
 -- Calculate commitment for each position under the input budget version ,
 -- then each assignment under the position and populate commitment into
 -- pqh_element_commitments table.Commitment is calculated for the period
 -- generated using the supplied  frequency.
 -- From this point onwards we will start logging errors into the Process log.
 -- Start the Log Process
 --
 get_table_route;
 --
-- If p_entity_id IS NOT NULL then
 ---
    --
    pqh_process_batch_log.start_log
    (
        p_batch_id       => l_budget_id,
        p_module_cd      => 'BUDGET_COMMITMENT',
        p_log_context    => l_budget_name
     );
    --
    l_context_level := 1;
    Open csrGetBudgetName(l_budget_id);
    Fetch csrGetBudgetName into l_log_context;
    Close csrGetBudgetName;
    l_log_context := l_log_context ;
    --
    pqh_process_batch_log.set_context_level
          (p_txn_id                =>  l_budget_id,
           p_txn_table_route_id    =>  g_table_route_id_p_bgt,
           p_level                 =>  l_context_level,
           p_log_context           =>  l_log_context);
-- End if;
 --
 l_context_level := l_context_level + 1;
 --
 g_budget_version_status := 'CALCULATION_SUCCESS';
 --
 hr_utility.set_location('Begin Processing positions', 6);
 --
  For pos_cnt in NVL(g_budget_entities.FIRST,0)..NVL(g_budget_entities.LAST,-1) Loop
   --
   If p_budgeted_entity_cd = 'POSITION' then
      l_log_context  := HR_GENERAL.DECODE_POSITION_LATEST_NAME(g_budget_entities(pos_cnt).entity_id);
   elsif p_budgeted_entity_cd ='JOB' then
   	l_log_context  := HR_GENERAL.DECODE_JOB(g_budget_entities(pos_cnt).entity_id);
   elsif p_budgeted_entity_cd ='ORGANIZATION' then
   	l_log_context  := HR_GENERAL.DECODE_ORGANIZATION(g_budget_entities(pos_cnt).entity_id);
   elsif p_budgeted_entity_cd ='GRADE' then
        l_log_context  := HR_GENERAL.DECODE_GRADE(g_budget_entities(pos_cnt).entity_id);
   end if;

  -- l_log_context := l_log_context||'  ('||hr_general.decode_lookup('PQH_BUDGET_ENTITY',p_budgeted_entity_cd)||' )';
   --
   pqh_process_batch_log.set_context_level
          (
          p_txn_id                =>  g_budget_entities(pos_cnt).entity_id,
          p_txn_table_route_id    =>  g_table_route_id_p_bdt,
          p_level                 =>  l_context_level,
          p_log_context           =>  l_log_context
          );
   --
   hr_utility.set_location('Set Savepoint', 9);
   --
   -- Set Save point for each position processed . We will rollback even if
   -- one record for the position failed.
   --
   Savepoint ins_pos_commitment;
   --
   g_budget_detail_status := 'CALCULATION_SUCCESS';
   --
   FOR cnt IN NVL(g_cmmtmnt_calc_dates.FIRST,0)..NVL(g_cmmtmnt_calc_dates.LAST,-1)
   --
   Loop
      hr_utility.set_location('->'||to_char(g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt,'DD/MM/RRRR')||' to '|| to_char(g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt,'DD/MM/RRRR'),13);
      hr_utility.set_location('#->'||to_char(g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,'DD/MM/RRRR')||' to '|| to_char(g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,'DD/MM/RRRR'),14);
      --
      -- The foll function gets all element types for a budget for which
      -- commitment has to be calculated, Calculates the respective commitment
      -- and Stores it into the commitment table.
      --
      hr_utility.set_location('Position id :'||to_char(g_budget_entities(pos_cnt).entity_id),15);
      --
      l_entity_id := g_budget_entities(pos_cnt).entity_id;
      --
      l_status :=  populate_commitment_table
      (p_budgeted_entity_cd       => p_budgeted_entity_cd,
       p_commit_calculation_dt     => g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt,
       p_actual_cmmtmnt_start_dt   => g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,
       p_commit_end_dt             => g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt,
       p_actual_cmmtmnt_end_dt     => g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,
       p_commitment_calc_frequency => nvl(p_period_frequency,l_budget_cal_freq),
       p_budget_calendar_frequency => l_budget_cal_freq,
       p_entity_id                 => l_entity_id,
       p_budget_id                 => l_budget_id,
       p_budget_version_id         => p_budget_version_id);
      --

       --
       -- Rollback for this position ,if there was any error.
       --
       If l_status = -1 then
       --
          Rollback to ins_pos_commitment;
          --
          -- Skip this position  and process next position.
          --
          g_budget_version_status := 'CALCULATION_ERROR';
          g_budget_detail_status := 'CALCULATION_ERROR';
          --
          Exit;
          --
      End if;
      --
    End loop; /** Commitment Calculation dates **/
    --
    -- Save if commitment calculation status for this position.
    --
  hr_utility.set_location('PositionId '||g_budget_entities(pos_cnt).entity_id,13);

  If p_budgeted_entity_cd = 'POSITION' then

     Update pqh_budget_details
     set commitment_gl_status = g_budget_detail_status
     Where budget_version_id = p_budget_version_id
     and position_id = g_budget_entities(pos_cnt).entity_id;

   elsif p_budgeted_entity_cd ='JOB' then

     Update pqh_budget_details
     set commitment_gl_status = g_budget_detail_status
     Where budget_version_id = p_budget_version_id
     and job_id = g_budget_entities(pos_cnt).entity_id;

   elsif p_budgeted_entity_cd ='ORGANIZATION' then

     Update pqh_budget_details
     set commitment_gl_status = g_budget_detail_status
     Where budget_version_id = p_budget_version_id
     and organization_id = g_budget_entities(pos_cnt).entity_id;

   elsif p_budgeted_entity_cd ='GRADE' then
     Update pqh_budget_details
     set commitment_gl_status = g_budget_detail_status
     Where budget_version_id = p_budget_version_id
     and grade_id = g_budget_entities(pos_cnt).entity_id;

   end if;
    --
    COMMIT;
    --
    --
 End loop; /** All positions in budget as of passed effective date **/
 --
 --
 Update pqh_budget_versions
    set commitment_gl_status = g_budget_version_status
  where budget_version_id = p_budget_version_id;
 --
 --
 pqh_process_batch_log.end_log;
 --
 --
hr_utility.set_location('Leaving:'||l_proc, 20);
--
EXCEPTION
      WHEN OTHERS THEN
       raise;
--
End calculate_money_cmmtmnts;
--
---------------------------------------------------------------------------------
--
-- The following functions are borrowed from payroll and tailored for our needs.
--
--------------------Work_schedule_total_hours---------------------------------------
--
-- This function is borrowed from payroll . No changes
-- have been made to it .
--
FUNCTION work_schedule_total_hours( p_bg_id	  in NUMBER,
				    p_ws_name	  in VARCHAR2,
				    p_range_start in DATE DEFAULT NULL,
				    p_range_end	  in DATE DEFAULT NULL) RETURN NUMBER IS

-- local constants
c_ws_tab_name	VARCHAR2(80)	:= 'COMPANY WORK SCHEDULES';

-- local variables
/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7) 	:= 0;
v_range_start	DATE;
v_range_end	DATE;
v_curr_date	DATE;
v_curr_day	VARCHAR2(3);	-- 3 char abbrev for day of wk.
v_ws_name	VARCHAR2(80);	-- Work Schedule Name.
v_gtv_hours	VARCHAR2(80);	-- get_table_value returns varchar2
				-- Remember to FND_NUMBER.CANONICAL_TO_NUMBER result.
v_fnd_sess_row	VARCHAR2(1);
l_exists	VARCHAR2(1);

BEGIN -- work_schedule_total_hours

-- Set range to a single week if no dates are entered:

  hr_utility.set_location('work_schedule_total_hours setting dates', 3);
  v_range_start := NVL(p_range_start, sysdate);
  v_range_end	:= NVL(p_range_end, sysdate + 6);

-- Check for valid range
--
  hr_utility.set_location('work_schedule_total_hours', 5);
--
  IF v_range_start > v_range_end THEN
    hr_utility.set_location('work_schedule_total_hours', 7);
    RETURN v_total_hours;
  END IF;
--
-- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
-- record if one doe not already exist.
--
SELECT	DECODE(COUNT(session_id), 0, 'N', 'Y')
INTO	v_fnd_sess_row
FROM	fnd_sessions
WHERE	session_id	= userenv('sessionid');
--
IF v_fnd_sess_row = 'N' THEN
   insert into fnd_sessions (session_id, effective_date) values(userenv('sessionid'),trunc(sysdate));
END IF;
--
-- Track range dates:
hr_utility.set_location('range start = '||to_char(v_range_start), 5);
hr_utility.set_location('range end = '||to_char(v_range_end), 6);
--
-- Check if the work schedule is an id or a name.  If the work
-- schedule does not exist, then return 0.
--
BEGIN
   select 'Y'
   into   l_exists
   from   pay_user_columns PUC
   where  PUC.USER_COLUMN_NAME 		= p_ws_name
   and    NVL(business_group_id, p_bg_id)  = p_bg_id
   and    NVL(legislation_code,'US')       = 'US';

EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;

if l_exists = 'Y' then
   v_ws_name := p_ws_name;
else
   BEGIN
   select PUC.USER_COLUMN_NAME
   into v_ws_name
   from pay_user_columns PUC
   where PUC.USER_COLUMN_ID = p_ws_name
   and    NVL(business_group_id, p_bg_id)       = p_bg_id
   and    NVL(legislation_code,'US')            = 'US';

   EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN v_total_hours;
   END;
end if;
--
v_curr_date := v_range_start;
--
hr_utility.set_location('work_schedule_total_hours curr_date = '||to_char(v_curr_date), 20);
--
LOOP
  v_curr_day := TO_CHAR(v_curr_date, 'DY');
--
  hr_utility.set_location('curr_day = '||v_curr_day, 20);
--
  hr_utility.set_location('work_schedule_total_hours.gettabval', 25);
  v_total_hours := v_total_hours
                 + FND_NUMBER.CANONICAL_TO_NUMBER(hruserdt.get_table_value
                                                          (p_bg_id,
							   c_ws_tab_name,
							   v_ws_name,
							   v_curr_day));
  v_curr_date := v_curr_date + 1;
--
  hr_utility.set_location('curr_date = '||to_char(v_curr_date), 20);
--
  EXIT WHEN v_curr_date > v_range_end;
--
END LOOP;
--
RETURN v_total_hours;
--
END work_schedule_total_hours;
--
-----------------------Standard_hours_worked---------------------------------
--
-- The foll function was borrowed from payroll but has been revamped because of lookup
-- issues.
--
FUNCTION standard_hours_worked( p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER IS
--
v_wkdays NUMBER		;
l_wkdays NUMBER		;
--
v_total_hours		NUMBER(15,7) := 0;
v_wrkday_hours	        NUMBER(15,7) := 0;-- std hrs/wk div by 5 workdays/wk
v_curr_date		DATE:= NULL;
v_curr_day		VARCHAR2(3):= NULL; -- 3 char abbrev for day of wk.

cursor csr_working_days is
select information3
from per_shared_types
where lookup_type ='FREQUENCY'
and system_type_cd = p_std_freq;
BEGIN -- standard_hours_worked
--
-- Check for valid range. If range_end is NULL or range_end < range_start
-- 0 hours will be returned.
--
hr_utility.set_location('standard_hours_worked', 5);
--
IF p_range_start > p_range_end THEN
  hr_utility.set_location('standard_hours_worked', 7);
  RETURN v_total_hours;
END IF;
--
-- This portion calculates how may hours are worked in a day.
-- from the share types, we are going to get how many working days in the assignment frequency
-- if the value is null or 0 or share type is not there, we will assume it to be 1 day.
--
open csr_working_days ;
fetch csr_working_days into v_wkdays;
if csr_working_days%notfound then
   l_wkdays := 1;
   close csr_working_days;
else
   if nvl(v_wkdays,0) = 0 then
      l_wkdays := 1;
   else
      l_wkdays := v_wkdays;
   end if;
   close csr_working_days;
end if;
v_wrkday_hours := p_std_hrs/l_wkdays;
--
v_curr_date := p_range_start;
--
hr_utility.set_location('standard_hours_worked', 10);

LOOP
  --
  -- Loop through all the working days in the range supplied and find
  -- how may hours were worked , during that period.
  --
  v_curr_day := TO_CHAR(v_curr_date, 'DY');
  --
  hr_utility.set_location('standard_hours_worked', 15);
  --
  IF UPPER(v_curr_day) in ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
    v_total_hours := v_total_hours + v_wrkday_hours;
    hr_utility.set_location('standard_hours_worked v_total_hours = ', v_total_hours);
  END IF;
  --
  v_curr_date := v_curr_date + 1;
  --
  EXIT WHEN v_curr_date > p_range_end;
  --
END LOOP;
--
RETURN v_total_hours;
--
END standard_hours_worked;
--
---------------------Convert_period_Type--------------------------------------
--
-- The following function converts the passed p_figure from one
-- frequency to another . i.e if the value for a year is passed , it
-- will convert the value to the required frequency , say , MONTHLY
--
FUNCTION Convert_Period_Type(
		p_bus_grp_id		in NUMBER,
		p_payroll_id		in NUMBER,
		p_asst_std_hours	in NUMBER   default NULL,
		p_figure		in NUMBER,
		p_from_freq		in VARCHAR2 ,
		p_to_freq		in VARCHAR2 ,
		p_period_start_date	in DATE     default NULL,
		p_period_end_date	in DATE     default NULL,
		p_asst_std_freq		in VARCHAR2 default NULL,
                p_dflt_elmnt_frequency in VARCHAR2,
                p_budget_calendar_frequency in VARCHAR2)
RETURN NUMBER IS
--
-- DECLARE local vars
--
   v_converted_figure		NUMBER;
   v_from_annualizing_factor	NUMBER(10);
   v_to_annualizing_factor	NUMBER(10);

-- LOCAL FUNCTION
--
-- This function determines the number of times a passed frequency
-- occurs in one year eg. a frequency of MONTHLY occurs 12 times in a
-- year
--
FUNCTION Get_Annualizing_Factor(p_bg			in NUMBER,
				p_payroll		in NUMBER,
				p_freq			in VARCHAR2,
				p_asg_std_hrs		in NUMBER,
				p_asg_std_freq		in VARCHAR2)
RETURN NUMBER IS
--
-- DECLARE local constants
--
   c_weeks_per_year	NUMBER(3):= 52;
   c_days_per_year	NUMBER(3):= 200;
   c_months_per_year	NUMBER(3):= 12;
--
-- DECLARE local vars
--
   v_annualizing_factor	    NUMBER(30,7);
   v_periods_per_fiscal_yr  NUMBER(5);
   v_hrs_per_wk		    NUMBER(15,7);
   v_hrs_per_range	    NUMBER(15,7);
   v_use_pay_basis	    NUMBER(1)	:= 0;
   v_pay_basis		    VARCHAR2(80);
   v_range_start	    DATE;
   v_range_end		    DATE;
   v_work_sched_name	    VARCHAR2(80);
   v_ws_id		    NUMBER(9);
   v_period_hours	    BOOLEAN;
--
   l_payroll_period_type    pay_payrolls_f.period_type%type;
--
BEGIN -- Get_Annualizing_Factor
--
--
-- Check for use of salary admin (ie. pay basis) as frequency.
-- Selecting "count" because we want to continue processing even if
-- the from_freq is not a pay basis.
--
--
 hr_utility.set_location('Get_Annualizing_Factor', 5);
 --
 begin	-- Is passes frequency , pay basis?

  --
  -- Decode pay basis and set v_annualizing_factor accordingly.
  --
  hr_utility.set_location('Is it salary basis'||nvl(p_freq,'null'),10);

  --
  --
  SELECT	lookup_code
  INTO		v_pay_basis
  FROM		hr_lookups	 	lkp
  WHERE 	lkp.application_id	= 800
  AND		lkp.lookup_type		= 'PAY_BASIS'
  AND		lkp.lookup_code		= p_freq;
  --
  -- If the passed frequency , uses lookup PAY_BASIS , then the foll
  -- portion will be executed .Otherwise , exception NO DATA FOUND  will
  -- be raised .
  --
  hr_utility.set_location('Get_Annualizing_Factor', 15);
  --
  v_use_pay_basis := 1;
  --
  -- The lookup PAY_BASIS uses 4 lookup_code's - MONTHLY , ANNUAL ,
  -- PERIOD , HOURLY. Get the annualizating factor for the passed
  -- frequency , if it is one of the above 4 lookup codes.
  --
  IF v_pay_basis = 'MONTHLY' THEN
    --
    hr_utility.set_location('Monthly salary basis ',20);
    --
    v_annualizing_factor := 12;
    --
  ELSIF v_pay_basis = 'HOURLY' THEN
    --
    hr_utility.set_location('Hourly salary basis',25);
    --
    IF p_period_start_date IS NOT NULL THEN
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
    ELSE
        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
    END IF;
       --
       -- If this is an Hourly employee and the work schedule name
       -- has not been provided , then the total hours worked during the
       -- given period is calculated using Standard Hours on the
       -- assignment.
       -- removed reference of work schedule as it was always passed as null
       --
       v_hrs_per_range := Standard_Hours_Worked(p_asg_std_hrs,
  				                v_range_start,
					        v_range_end,
					        p_asg_std_freq);
       --
    --
    --  Once the number of hours worked in the given period have been
    --  calculated , calculate the number of hours worked in a year .
    --  We have calculated the no of hours in one budget calendar frequency
    --  period .We need to find the number of times the budget calendar
    --  frequency happens in a year.
    --
    IF v_period_hours THEN
         --
         v_periods_per_fiscal_yr := get_number_per_fiscal_year(p_budget_calendar_frequency);
         --
         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;
         --
    ELSE
         --
         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;
         --
    END IF;
    --
  ELSIF v_pay_basis = 'PERIOD' THEN
    --
    hr_utility.set_location('Period salary basis',40);
    --
    -- If the salary basis is PERIOD , then fetch the period type of the
    -- associated payroll . But as seen in the assignment form , it is
    -- possible to create an assignment with pay basis = PERIOD but the
    -- assignment may not be associated with a payroll. Under such
    -- circumstances , We will fall back to budget element frequency.
    --
    If p_payroll IS NOT NULL then
       --
       hr_utility.set_location('Payroll is Exists',45);
       --
       l_payroll_period_type := get_payroll_period_type
                                    (p_payroll_id         =>  p_payroll,
                                     p_effective_dt       => p_period_start_date);
       --
       v_annualizing_factor := get_number_per_fiscal_year(l_payroll_period_type);
       --
    Else
       -- If pay basis is PERIOD , and no payroll id has been associated with
       -- the assignment,we will use budget element frequency for calculating
       -- commitment . If budget element frequency is also NULL , we will
       -- use budget calendar frequency .
       --
       v_annualizing_factor := get_number_per_fiscal_year(p_dflt_elmnt_frequency);
       --
    End if;

    hr_utility.set_location('Get_Annualizing_Factor', 50);

  ELSIF v_pay_basis = 'ANNUAL' THEN
    --
    hr_utility.set_location('Annual salary basis',55);
    --
    v_annualizing_factor := 1;
    --
  ELSE
    --
    -- Did not recognize "pay basis"
    --
    hr_utility.set_location('Get_Annualizing_Factor', 60);

    v_annualizing_factor := 0;
    RETURN v_annualizing_factor;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --
    hr_utility.set_location('Exception raised !',65);
    --
    -- The only reason why this exception should be raised , is when an invalid
    -- salary basis has been entered .
    --
    v_use_pay_basis := 0;
    --
END;

IF v_use_pay_basis = 0 THEN
  --
  -- If Not using pay basis as frequency...
  -- Check if the frequency is in per_time_period_types.
  -- The Budget Calendar frequency is the period type of the budgets
  -- Calendar . The valid set of period types are available in
  -- per_time_period_types .
  -- This set will be used to validate if the input element frequency is
  -- valid.
  -- If input element frequency is not valid ,fall back on budget element frequency .

  IF (p_freq IS NULL) 			OR
     (UPPER(p_freq) = 'PERIOD') 	OR
     (UPPER(p_freq) = 'NOT ENTERED') 	THEN
    --
    -- Get "annualizing factor" from period type of the payroll.
    --
    hr_utility.set_location('Get_Annualizing_Factor', 70);
    --
    If p_payroll IS NOT NULL then
       --
       l_payroll_period_type := get_payroll_period_type
                                    (p_payroll_id         =>  p_payroll,
                                     p_effective_dt       => p_period_start_date);
       --
       v_annualizing_factor := get_number_per_fiscal_year(l_payroll_period_type);
       --
    Else
       -- If FREQUENCY is PERIOD , and no payroll id has been associated with
       -- the assignment,we will use budget element frequency for calculating
       -- commitment .
       --
       v_annualizing_factor := get_number_per_fiscal_year(p_dflt_elmnt_frequency);
       --
    End if;
    --
  ELSIF UPPER(p_freq) <> 'HOURLY' THEN
    --
    -- This is an actual time period type from per_time_period_types.
    -- We know how to handle this.
    --
    --
    BEGIN
    --
    hr_utility.set_location('Get_Annualizing_Factor',75);

    SELECT	PT.number_per_fiscal_year
    INTO	v_annualizing_factor
    FROM	per_time_period_types 	PT
    WHERE	UPPER(PT.period_type) 	= UPPER(p_freq);

    hr_utility.set_location('Get_Annualizing_Factor',80);
    --
    exception when NO_DATA_FOUND then
     --
     -- Added as part of SALLY CLEANUP.
     -- Could have been passed in an ASG_FREQ dbi which might
     -- have the values of 'Day' or 'Month' which do not map to a
     -- time period type.  So we'll do these by hand.

      hr_utility.set_location('Get_Annualizing_Factor',85);
      IF UPPER(p_freq) = 'DAY' THEN
        v_annualizing_factor := c_days_per_year;
      ELSIF UPPER(p_freq) = 'MONTH' THEN
        v_annualizing_factor := c_months_per_year;
      Else
        null;
      END IF;

    END;

  ELSE  -- Hourly employee...
     --
     hr_utility.set_location('Get_Annualizing_Factor', 90);

     IF p_period_start_date IS NOT NULL THEN
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
     ELSE
        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
     END IF;
         hr_utility.set_location('getting std hours', 100);
         v_hrs_per_range := Standard_Hours_Worked(p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);
     IF v_period_hours THEN
         v_periods_per_fiscal_yr := get_number_per_fiscal_year(p_to_freq);
         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;
      ELSE
         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;
      END IF;
  END IF;
END IF;	-- (v_use_pay_basis = 0)
RETURN v_annualizing_factor;
END Get_Annualizing_Factor;
--
----The Convert_Period_Type function starts here  --------
--
BEGIN
  hr_utility.set_location('Convert_Period_Type', 10);
  hr_utility.set_location('p_from_freq'||p_from_freq, 10);
  hr_utility.set_location('p_to_freq'||p_to_freq, 10);
  --
  -- If From_Freq and To_Freq are the same, then we're done.
  --
  hr_utility.set_location('Starting Conversion p_from_freq'||p_from_freq||' p_to_freq'||p_to_freq,15);

  IF NVL(p_from_freq, 'NOT ENTERED') = NVL(p_to_freq, 'NOT ENTERED') THEN

    RETURN p_figure;

  END IF;

  v_from_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq			=> p_from_freq,
			p_asg_std_hrs		=> p_asst_std_hours,
			p_asg_std_freq		=> p_asst_std_freq);

  v_to_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq			=> p_to_freq,
			p_asg_std_hrs		=> p_asst_std_hours,
			p_asg_std_freq		=> p_asst_std_freq);
  --
  -- Annualize "Figure" and convert to To_Freq.
  --

  hr_utility.set_location('v_from_annualizing_factor '|| v_from_annualizing_factor, 20);
  hr_utility.set_location('v_to_annualizing_factor' || v_to_annualizing_factor, 20);
  hr_utility.set_location('p_figure' || p_figure, 20);

  hr_utility.set_location('Convert_Period_Type', 20);

  IF v_to_annualizing_factor = 0 	OR
     v_to_annualizing_factor = -999	OR
     v_from_annualizing_factor = -999	THEN

    hr_utility.set_location('Convert_Period_Type', 25);

    v_converted_figure := 0;
    RETURN v_converted_figure;

  ELSE

    hr_utility.set_location('Convert_Period_Type', 30);

    v_converted_figure := (p_figure * v_from_annualizing_factor) / v_to_annualizing_factor;

  END IF;

  hr_utility.set_location('Leaving : Convert_Period_Type'||NVL(v_converted_figure,0), 35);

RETURN v_converted_figure;

END Convert_Period_Type;
--

Procedure refresh_asg_ele_commitments (p_assignment_id Number,
                                       p_effective_date Date,
                                       p_element_type_id Number default Null,
                                       p_input_value_id Number default Null)
IS

-- Control Budget (position - money) as of the effective date for the current BG
Cursor csr_get_ctrl_bdgt IS
Select bdgts.budget_id,budget_name,period_set_name ,
        budget_start_date,budget_end_date
From   PQH_BUDGETS bdgts,per_shared_types shtyps
where p_effective_date between budget_start_date and budget_end_date
and position_control_flag ='Y'
and budgeted_entity_cd ='POSITION'
and shtyps.shared_type_id = bdgts.budget_unit1_id
and shtyps.system_type_cd ='MONEY'
and bdgts.business_group_id = hr_general.get_business_group_id;
--
-- Obtain the frequency of the time periods for a calendar
--
  Cursor csr_bdgt_cal_freq(p_period_set_name varchar2) is
   Select pc.actual_period_type
     from pay_calendars pc
    Where pc.period_set_name = p_period_set_name;
--
-- Get Position Id from the Current Assignment
--
Cursor csr_get_assignment IS
Select position_id
from per_all_assignments_f
where assignment_id = p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
-- Get the effective Budget version
Cursor csr_get_bdgt_version(p_budget_id number) IS
Select budget_version_id
from pqh_budget_versions
where budget_id = p_budget_id
and p_effective_date between date_from and date_to;
--
--
Cursor csr_get_period_frequency IS
Select period_type
from PAY_PAYROLLS_f
where payroll_id = (Select payroll_id
                    from per_all_assignments_f
                    where assignment_id =   p_assignment_id);
---
Cursor csr_bdgt_commt_elmnt(p_budget_id number) IS
              Select  Formula_id,
              Salary_basis_flag,
              dflt_elmnt_frequency,
              nvl(Overhead_percentage,0)
         From pqh_bdgt_cmmtmnt_elmnts
        Where budget_id = p_budget_id
        and element_type_id = p_element_type_id
        and element_input_value_id  = p_input_value_id
        and actual_commitment_type in ('COMMITMENT','BOTH');
--
Cursor csr_pos_single_assignment is
       Select pay_basis_id,
              business_group_id,payroll_id,
              normal_hours,frequency
         From per_all_assignments_f
        Where assignment_id = p_assignment_id
         And  p_effective_date between effective_start_date
                                          AND effective_end_date;
Cursor csr_salary_basis(p_pay_basis_id number) is
Select ppb.input_value_id
from   per_pay_bases ppb
   ,      pay_input_values_f piv  --To ensure that this input value id belongs to the passed element_type
where  ppb.pay_basis_id = p_pay_basis_id
            and  piv.input_value_id = ppb.input_value_id
            and  piv.element_type_id = p_element_type_id
            and  p_effective_date between piv.effective_start_date and piv.effective_end_date;
--
Cursor csrGetBudgetName(l_bdgt_id in number) Is
Select budget_name
From pqh_budgets
Where budget_id = l_bdgt_id;

--
l_formula_id                Number;
l_salary_basis_flag         varchar2(10);
l_dflt_elmnt_frequency      varchar2(30);
l_budget_id                 pqh_budgets.budget_id%type := NULL;
l_budget_name               pqh_budgets.budget_name%type := NULL;
l_period_set_name           pqh_budgets.period_set_name%type := NULL;
l_budget_cal_freq           pay_calendars.actual_period_type%type;
l_budget_start_date         date;
l_budget_end_date           date;
l_cmmtmnt_start_dt          date;
l_entity_id                 Number;
l_budget_version_id         Number;
l_cmmtmnt_end_dt            date;
l_dummy_tab                 cmmtmnt_elmnts_tab;
l_status                    number(15);
l_period_frequency          PAY_PAYROLLS_f.period_type%type;
l_pay_basis_id              per_all_assignments_f.pay_basis_id%type;
l_business_group_id         per_all_assignments_f.business_group_id%type;
l_payroll_id                per_all_assignments_f.payroll_id%type;
l_normal_hours              per_all_assignments_f.normal_hours%type;
l_frequency                 per_all_assignments_f.frequency%type;
l_overhead_percentage       Number;
l_entry_commitment          Number := 0;
l_element_overhead          Number(5,2) :=0;
l_input_value_id            Number := p_input_value_id;
l_context_level             number(15);
l_log_context               pqh_process_log.log_context%TYPE;

l_proc               varchar2(72) := g_package || 'refresh_asg_ele_commitments';
Begin

    hr_utility.set_location('Entering:'||l_proc, 5);

  -- Control Budget Id (position - money) as of the effective date for the current BG
        Open csr_get_ctrl_bdgt;
          Fetch csr_get_ctrl_bdgt into l_budget_id,l_budget_name,
                        l_period_set_name,l_budget_start_date,l_budget_end_date;
        Close csr_get_ctrl_bdgt;

     --
     -- DETERMINE THE CALENDAR FREQ OF THE BUDGET
     --
     Open  csr_bdgt_cal_freq(l_period_set_name);
     --
     Fetch  csr_bdgt_cal_freq into l_budget_cal_freq;
     --
     If  csr_bdgt_cal_freq%notfound then
         --
         --Raise exception
         --
         Close  csr_bdgt_cal_freq;
         FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BDGT_CALENDAR');
         APP_EXCEPTION.RAISE_EXCEPTION;
         --
     End if;
     --
     Close  csr_bdgt_cal_freq;
     --


--   Generate Commtmnt Calculation Dates to compute the commitment periods
--  p_period_frequency is assuming the same as p_budget_cal_freq
--
l_cmmtmnt_start_dt:= l_budget_start_date;
l_cmmtmnt_end_dt := l_budget_end_date;

/* Open csr_get_period_frequency;
    Fetch csr_get_period_frequency into l_period_frequency;
Close csr_get_period_frequency; */


 generate_cmmtmnt_calc_dates(p_budget_start_date => l_budget_start_date,
                              p_budget_end_date   => l_budget_end_date,
                              p_period_set_name   => l_period_set_name,
                              p_budget_cal_freq   => l_budget_cal_freq,
                              p_period_frequency  => l_budget_cal_freq,
                              p_cmmtmnt_start_dt=> l_cmmtmnt_start_dt,
                              p_cmmtmnt_end_dt  => l_cmmtmnt_end_dt);

 --
   Open csr_get_bdgt_version(l_budget_id);
     Fetch csr_get_bdgt_version into l_budget_version_id;
   Close csr_get_bdgt_version;
 --
  If p_element_type_id is Null and p_input_value_id is Null then
  --
  --
  -- Fetch all the commitment elments for this budget.
  --
  g_bdgt_cmmtmnt_elmnts := l_dummy_tab;
  --
  fetch_bdgt_cmmtmnt_elmnts( p_budget_id           => l_budget_id,
                            p_bdgt_cmmtmnt_elmnts => g_bdgt_cmmtmnt_elmnts);
  --

 get_table_route;

 Savepoint ins_pos_commitment;
   --
   Open csr_get_assignment;
     Fetch csr_get_assignment into l_entity_id;
   Close csr_get_assignment;

   g_budget_detail_status := 'CALCULATION_SUCCESS';
      --
       FOR cnt IN NVL(g_cmmtmnt_calc_dates.FIRST,0)..NVL(g_cmmtmnt_calc_dates.LAST,-1)
       --
       Loop

      hr_utility.set_location('->'||to_char(g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt,'DD/MM/RRRR')||' to '|| to_char(g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt,'DD/MM/RRRR'),13);
      hr_utility.set_location('#->'||to_char(g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,'DD/MM/RRRR')||' to '|| to_char(g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,'DD/MM/RRRR'),14);
      --
      -- The foll function gets all element types for a budget for which
      -- commitment has to be calculated, Calculates the respective commitment
      -- and Stores it into the commitment table.
      --
      -- l_entity_id is the Current Assignment's Position Id
      --
     -- if (p_effective_date between g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt and
       --    g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt ) then
       --
    If (p_effective_date between g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt and g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt) OR (p_effective_date <= g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt) Then
    --
      l_status :=  populate_commitment_table
      (p_budgeted_entity_cd       => 'POSITION',
       p_commit_calculation_dt     => g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt,
       p_actual_cmmtmnt_start_dt   => g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,
       p_commit_end_dt             => g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt,
       p_actual_cmmtmnt_end_dt     => g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,
       p_commitment_calc_frequency => l_budget_cal_freq,
       p_budget_calendar_frequency => l_budget_cal_freq,
       p_entity_id                 => l_entity_id,
       p_budget_id                 => l_budget_id,
       p_budget_version_id         => l_budget_version_id);
       --
     -- end if;
       --
       -- Rollback for this position ,if there was any error.
       --
       If l_status = -1 then
       --
          Rollback to ins_pos_commitment;
          --
          -- Skip this position  and process next position.
          --
          g_budget_version_status := 'CALCULATION_ERROR';
          g_budget_detail_status := 'CALCULATION_ERROR';
          --
          Exit;
          --
      End if;
      --
    End if;
    --
    End loop; /** Commitment Calculation dates **/
  --
  Else
  --  If input value id is not null and element_type_id is not null then

     Open csr_bdgt_commt_elmnt(l_budget_id);
     --
      Fetch csr_bdgt_commt_elmnt into l_formula_id,l_salary_basis_flag,
                                     l_dflt_elmnt_frequency,
                                     l_overhead_percentage;
     --
     Close csr_bdgt_commt_elmnt;

     -- Fetch Assignment related information
     Open csr_pos_single_assignment;
     --
     Fetch csr_pos_single_assignment into l_pay_basis_id, l_business_group_id,
                        l_payroll_id,l_normal_hours,l_frequency;
     --
     Close csr_pos_single_assignment;
     --
     --
     If (p_input_value_id is Not Null and p_element_type_id is Null ) then
     --
     -- PQH_INVALID_INPUTS_FOR_REF : Element type cannot be null. Please provide
     -- the Element Type id or Please pass input_value_id also null
     --
      FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_INPUTS_FOR_REF');
      APP_EXCEPTION.RAISE_EXCEPTION;
     --
     End if;

     -- If Element Type Id is provided, fetching the input_value_id
     --
     If (p_input_value_id is null and p_element_type_id is not null) then
     --
      Open csr_salary_basis(l_pay_basis_id);
       Fetch csr_salary_basis into l_input_value_id;
      Close csr_salary_basis;
     --
     End if;
     --
   get_table_route;

    Open csrGetBudgetName(l_budget_id);
    Fetch csrGetBudgetName into l_budget_name;
    Close csrGetBudgetName;

    pqh_process_batch_log.start_log
    (
        p_batch_id       => l_budget_id,
        p_module_cd      => 'BUDGET_COMMITMENT',
        p_log_context    => l_budget_name
     );
    --
    l_context_level := 1;

    l_log_context := l_budget_name ;
    --
    pqh_process_batch_log.set_context_level
          (p_txn_id                =>  l_budget_id,
           p_txn_table_route_id    =>  g_table_route_id_p_bgt,
           p_level                 =>  l_context_level,
           p_log_context           =>  l_log_context);
--
--  Fetch input_value_id, if it is null
--

       FOR cnt IN NVL(g_cmmtmnt_calc_dates.FIRST,0)..NVL(g_cmmtmnt_calc_dates.LAST,-1)
       --
       Loop
              --
    hr_utility.set_location('->'||to_char(g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt,'DD/MM/RRRR')||' to '|| to_char(g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt,'DD/MM/RRRR'),13);
    hr_utility.set_location('#->'||to_char(g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,'DD/MM/RRRR')||' to '|| to_char(g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,'DD/MM/RRRR'),14);

              savepoint salary_proposal_level;
              hr_utility.set_location('Default to element type calc',35);
              --
--         If (p_effective_date between g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt and g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt) then
    If (p_effective_date between g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt and g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt) OR (p_effective_date <= g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt) Then
              --
              l_entry_commitment := get_commitment_from_elmnt_type(
                p_commit_calculation_dt      => g_cmmtmnt_calc_dates(cnt).cmmtmnt_start_dt,
                p_actual_cmmtmnt_start_dt    => g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,
                p_commit_calculation_end_dt  => g_cmmtmnt_calc_dates(cnt).cmmtmnt_end_dt,
                p_actual_cmmtmnt_end_dt      => g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,
                p_commitment_calc_frequency  => l_budget_cal_freq,
                p_budget_calendar_frequency  => l_budget_cal_freq,
                p_dflt_elmnt_frequency       => l_dflt_elmnt_frequency,
                p_business_group_id          => l_business_group_id,
                p_assignment_id              => p_assignment_id,
                p_payroll_id                 => l_payroll_id,
                p_pay_basis_id               => l_pay_basis_id,
                p_element_type_id            => p_element_type_id,
                p_element_input_value_id     => l_input_value_id,
                p_normal_hours               => l_normal_hours,
                p_asst_frequency             => l_frequency);
              --
         hr_utility.set_location('l_entry_commitment'||l_entry_commitment,44);
             l_status := Calculate_overhead
                 (p_element_commitment   => l_entry_commitment,
                  p_overhead_percentage  => l_overhead_percentage,
                  p_element_overhead     => l_element_overhead);
         hr_utility.set_location('l_entry_commitment: '||l_entry_commitment,44);
         hr_utility.set_location('l_element_overhead: '||nvl(l_element_overhead,0),44);
         hr_utility.set_location('l_status: '||l_status,45);
             If l_status = -1 then
             	rollback to salary_proposal_level;
             End if;

         hr_utility.set_location('Delete commitment',46);
         --
         Delete from  pqh_element_commitments
          Where budget_version_id  = l_budget_version_id
            AND ASSIGNMENT_ID      = p_assignment_id
            AND ELEMENT_TYPE_ID    = p_element_type_id
            AND (COMMITMENT_START_DATE  between g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt
                                           and g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt OR
                 g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt between COMMITMENT_START_DATE
                                               and COMMITMENT_END_DATE);
         --
         --
         hr_utility.set_location('Insert commitment',48);
         hr_utility.set_location('l_entry_commitment:'||l_entry_commitment,48);
         --
         Insert into pqh_element_commitments(
             ELEMENT_COMMITMENT_ID ,
             BUDGET_VERSION_ID,
             ASSIGNMENT_ID,
             ELEMENT_TYPE_ID,
             COMMITMENT_START_DATE,
             COMMITMENT_END_DATE,
             COMMITMENT_CALC_FREQUENCY,
             COMMITMENT_AMOUNT,
             CREATION_DATE,
             CREATED_BY)
           Values(
             pqh_element_commitments_s.nextval ,
             l_budget_version_id,
             p_assignment_id,
             p_element_type_id,
             g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_start_dt,
             g_cmmtmnt_calc_dates(cnt).actual_cmmtmnt_end_dt,
             l_budget_cal_freq,
             l_entry_commitment+nvl(l_element_overhead,0),
             sysdate,
             -1);

             hr_utility.set_location('Insert commitment2'||(l_entry_commitment+l_element_overhead),48);
             --
        End if;
         --
      End Loop;
  --
  End if;
Exception
When others then
-- Log error
 hr_utility.set_location(sqlerrm,1000);
 pqh_process_batch_log.insert_log
 (
   p_message_type_cd    =>  'ERROR',
   p_message_text       =>  SQLERRM
 );

End refresh_asg_ele_commitments;
--
-------------------------------------------------------------------------------
End;

/
