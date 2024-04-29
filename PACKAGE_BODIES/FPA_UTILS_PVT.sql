--------------------------------------------------------
--  DDL for Package Body FPA_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_UTILS_PVT" as
/* $Header: FPAVUTIB.pls 120.6.12010000.2 2009/12/11 07:21:53 jcgeorge ship $ */

/**********************************************************************************
**********************************************************************************/

--The procedure Get_Scenario_Wscore_Color is used to compare the scenario weighted
--score against the Planning Cycle From and To weighted score targets.
--It returns the appropriate color.
function Get_Scenario_Wscore_Color(
  p_pc_id                       IN              number
 ,p_scenario_id                 IN              number
) return varchar2 is

l_sce_wscore                    number;
l_pc_wscore_from                number;
l_pc_wscore_to                  number;

l_color                                         varchar2(1);

begin

  select a.cost_weighted_score
        ,b.pc_inv_crit_score_target_from
        ,b.pc_inv_crit_score_target_to
    into l_sce_wscore
        ,l_pc_wscore_from
        ,l_pc_wscore_to
    from fpa_aw_sce_str_scores_v a
        ,fpa_aw_pc_inv_criteria_v b
   where a.investment_criteria = b.investment_criteria
     and b.investment_criteria = 3
     and a.planning_cycle = b.planning_cycle
     and a.planning_cycle = p_pc_id
     and a.scenario = p_scenario_id;

    if (l_sce_wscore > l_pc_wscore_to) then
      l_color := 'G';
    elsif (l_sce_wscore < l_pc_wscore_to) and (l_sce_wscore > l_pc_wscore_from) then
      l_color := 'Y';
    else
      l_color := 'R';
    end if;

  return l_color;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Get_Scenario_Wscore_Color;

/**********************************************************************************
**********************************************************************************/

--The procedure Get_Scenario_NPV_Color is used to compare the scenario NPV
--value against the Planning Cycle NPV From and To targets.
--It returns the appropriate color.
function Get_Scenario_NPV_Color(
  p_pc_id                       IN              number
 ,p_scenario_id                 IN              number
) return varchar2 is

l_sce_npv                                    number;
l_pc_npv_from                                number;
l_pc_npv_to                                  number;

l_color                                         varchar2(4);

begin

  select nvl(b.net_present_value,0)
        ,c.financial_target_from
        ,c.financial_target_to
    into l_sce_npv
        ,l_pc_npv_from
        ,l_pc_npv_to
      from fpa_aw_sces_v a
          ,fpa_aw_sce_npvs_v b
          ,fpa_aw_pc_financial_targets_v c
       where a.scenario = b.scenario
         and b.scenario = p_scenario_id
         and a.planning_cycle = c.planning_cycle
         and a.planning_cycle = p_pc_id
         and c.financial_metrics = 'NPV';

    if  (l_sce_npv > l_pc_npv_to) then
      l_color := 'GNPV';
    elsif (l_sce_npv < l_pc_npv_to) and (l_sce_npv > l_pc_npv_from) then
      l_color := 'YNPV';
    else
      l_color := 'RNPV';
    end if;

  return l_color;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Get_Scenario_NPV_Color;

/**********************************************************************************
**********************************************************************************/
--The procedure Get_Scenario_ROI_Color is used to compare the scenario ROI
--value against the Planning Cycle ROI From and To targets.
--It returns the appropriate color.
function Get_Scenario_ROI_Color(
  p_pc_id                       IN              number
 ,p_scenario_id                 IN              number
) return varchar2 is

l_sce_roi                                    number;
l_pc_roi_from                                number;
l_pc_roi_to                                  number;

l_color                                         varchar2(4);

begin

  select nvl(b.return_on_inv,0)
        ,c.financial_target_from
        ,c.financial_target_to
    into l_sce_roi
        ,l_pc_roi_from
        ,l_pc_roi_to
      from fpa_aw_sces_v a
          ,fpa_aw_sce_fin_metrics_v b
          ,fpa_aw_pc_financial_targets_v c
       where a.scenario = b.scenario
         and b.scenario = p_scenario_id
         and a.planning_cycle = c.planning_cycle
         and a.planning_cycle = p_pc_id
         and c.financial_metrics = 'ROI';

    if  (l_sce_roi > l_pc_roi_to) then
      l_color := 'GROI';
    elsif (l_sce_roi < l_pc_roi_to) and (l_sce_roi > l_pc_roi_from) then
      l_color := 'YROI';
    else
      l_color := 'RROI';
    end if;

    return l_color;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Get_Scenario_ROI_Color;

/**********************************************************************************
**********************************************************************************/

function Determine_PC_Checklist_status(
  p_pc_id                       IN              number
 ,p_lookup_code                 IN              varchar2
) return varchar2 is

l_sce_count                 number;

l_pc_status                                     varchar2(30);
l_step_status                                   varchar2(30) := 'NOSTEP';

begin

  --Select current pc status
  select pc_status
    into l_pc_status
    from fpa_aw_pc_info_v
   where planning_cycle = p_pc_id;

  CASE
    when l_pc_status is null then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'INPROGRESS';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'SUBMIT_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'APPROVE_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'NOTSTARTED';
      end if;
    when l_pc_status = 'CREATED' then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'INPROGRESS';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'INITIATE';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'SUBMIT_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'APPROVE_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'CLOSE';
      end if;
    when l_pc_status = 'COLLECTING' then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'INPROGRESS';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'SUBMIT_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'APPROVE_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'CLOSE';
      end if;
    when l_pc_status = 'ANALYSIS' then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'INPROGRESS';
      elsif (p_lookup_code = 'SUBMIT_PLAN') then
        if (scenarios_recommended(p_pc_id) = 'T') then
          l_step_status := 'SUBMIT';
         else
          l_step_status := 'NOTSTARTED';
       end if;
      elsif p_lookup_code = 'APPROVE_PLAN' then
        l_step_status := 'NOTSTARTED';
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'CLOSE';
      end if;
    when l_pc_status = 'SUBMITTED' then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'SUBMIT_PLAN' then
        l_step_status := 'DONE';
      elsif (p_lookup_code = 'APPROVE_PLAN') then
        if (scenario_approved(p_pc_id) = 'T') then
          l_step_status := 'APPROVE';
         else
          l_step_status := 'NOTSTARTED';
        end if;
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'CLOSE';
      end if;
    when l_pc_status = 'APPROVED' then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'SUBMIT_PLAN' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'APPROVE_PLAN' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'CLOSE';
      end if;
    when l_pc_status = 'CLOSED' then
      if p_lookup_code = 'REVIEW_CRITERIA' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'INITIATE_PC' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'COLLECT_PROJECTS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'DEVELOP_SCENARIOS' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'SUBMIT_PLAN' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'APPROVE_PLAN' then
        l_step_status := 'DONE';
      elsif p_lookup_code = 'CLOSE_PLAN' then
        l_step_status := 'DONE';
      end if;
  end CASE;

  return l_step_status;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Determine_PC_Checklist_status;

/************************************************************************************
************************************************************************************/
-- This function determines if an organization is member of the
-- Organization hierarchy set in the PJP Profile Option
function Is_Org_In_PJP_Org_Hier(
  p_org_id                       IN              number
) return number is

l_org_count                 number := 0;

begin

  select count(c.org_structure_element_id)
    into l_org_count
    from per_org_structure_elements c,
         per_organization_structures d
   where d.organization_structure_id = fnd_profile.VALUE('PJP_ORGANIZATION_HIERARCHY')
     and c.business_group_id = d.business_group_id
     and c.org_structure_element_id = p_org_id;

  return l_org_count;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Is_Org_In_PJP_Org_Hier;

/************************************************************************************
************************************************************************************/
-- This function validates if a Class code can be assigned to a new Portfolio.
-- The validation is as follow.
-- A class code assigned to a Portfolio with no Organization cannot be used by any
-- other portfolio.
-- A class code assigned to a Portfolio with an Organization cannot be assigned
-- to another portfolio with the same organization
-- hierarchy cannot be assigned to a Portfolio with the same Organization or to a
-- Portfolio with no Organization.
-- A class code assigned to a Portfolio with an Organization in the PJP
-- hierarchy cannot be assigned to Portfolio with any Organization under the PJP
-- hierarchy or to a Portfolio with no Organization.
function Is_Class_Code_Available(
  p_class_code                  IN              number
 ,p_org_id                      IN              number
) return varchar2 is

l_is_available                  VARCHAR2(1) := 'Y';
l_count                     NUMBER;

begin

  --1st check
  -- Can we assign a Class code to a portfolio with no Org?  Only if this class code has
  -- not been assigned yet.
  if p_org_id is null then
    select count(portfolio)
      into l_count
      from fpa_aw_portf_headers_v
     where portfolio_class_code = p_class_code;
     -- if class code already assigned return 'N'.
    if l_count > 0 then
      l_is_available := 'N';
      return l_is_available;
    end if;

  else

    -- 2nd check.
    -- Can we assign a class code to a portfolio with an org?  Only if the class code has
    -- been assigned to a portfolio with no Org.
    select count(portfolio)
      into l_count
      from fpa_aw_portf_headers_v
     where portfolio_class_code = p_class_code
       and portfolio_organization is null;
     -- if class code already assigned return 'N'.
    if l_count > 0 then
      l_is_available := 'N';
      return l_is_available;
    end if;

    -- 3rd check
    -- Can we assign a class code to a portfolio with an org?  Only if the class code has
    -- been assigned to a portfolio with an Org that does not belong to the Org hierarchy
    -- specified in the Profile Option.
    -- to another portfolio with the same organization
    select count(portfolio)
      into l_count
      from fpa_aw_portf_headers_v
     where portfolio_class_code = p_class_code
       and portfolio_organization in (
SELECT e.organization_id_child
 FROM  per_org_structure_elements e
      ,PER_ORG_STRUCTURE_VERSIONS v
WHERE e.org_structure_version_id = v.ORG_STRUCTURE_VERSION_ID
  and v.ORGANIZATION_STRUCTURE_ID = FND_PROFILE.VALUE('PJP_ORGANIZATION_HIERARCHY')
  AND (TRUNC(SYSDATE) BETWEEN TRUNC(v.DATE_FROM) AND TRUNC(nvl(v.DATE_TO, sysdate)))
CONNECT BY PRIOR e.organization_id_child = e.organization_id_parent
AND PRIOR e.org_structure_version_id = v.ORG_STRUCTURE_VERSION_ID
START WITH e.organization_id_child = p_org_id
UNION
SELECT e.organization_id_parent
FROM per_org_structure_elements e
    ,PER_ORG_STRUCTURE_VERSIONS v
WHERE e.org_structure_version_id = v.ORG_STRUCTURE_VERSION_ID
  and v.ORGANIZATION_STRUCTURE_ID = FND_PROFILE.VALUE('PJP_ORGANIZATION_HIERARCHY')
  AND (TRUNC(SYSDATE) BETWEEN TRUNC(v.DATE_FROM) AND TRUNC(nvl(v.DATE_TO, sysdate)))
CONNECT BY PRIOR e.organization_id_parent = e.organization_id_child
AND PRIOR e.org_structure_version_id = v.ORG_STRUCTURE_VERSION_ID
START WITH e.organization_id_child = p_org_id
UNION
SELECT e.organization_id_parent
FROM per_org_structure_elements e
    ,PER_ORG_STRUCTURE_VERSIONS v
WHERE e.org_structure_version_id = v.ORG_STRUCTURE_VERSION_ID
  and v.ORGANIZATION_STRUCTURE_ID = FND_PROFILE.VALUE('PJP_ORGANIZATION_HIERARCHY')
  AND (TRUNC(SYSDATE) BETWEEN TRUNC(v.DATE_FROM) AND TRUNC(nvl(v.DATE_TO, sysdate)))
CONNECT BY PRIOR e.organization_id_parent = e.organization_id_child
AND PRIOR e.org_structure_version_id = v.ORG_STRUCTURE_VERSION_ID
START WITH e.organization_id_parent = p_org_id
);

    -- If there's an Org in the hierarchy with the current class code.
    if l_count > 0 then
      l_is_available := 'N';
      return l_is_available;
    end if;

  end if;

  return l_is_available;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Is_Class_Code_Available;

/************************************************************************************
************************************************************************************/
-- This function validates if an Organization can be assigned to a new Portfolio.
function Is_Organization_Available(
  p_org_id                      IN              number
 ,p_class_code                  IN              number
) return varchar2 is

l_is_available                                  VARCHAR2(1) := 'Y';
l_count                                         NUMBER;

begin

  -- 1st check.
  -- Can we assign the Organization to a portfolio without knowing the Org?  Only
  -- if the org has not been assigned.
  if p_class_code is null then
    select count(portfolio)
      into l_count
      from fpa_aw_portf_headers_v
     where portfolio_organization is not null
       and portfolio_organization = p_org_id;
     -- if class code already assigned return 'N'.
    if l_count > 0 then
      l_is_available := 'N';
      return l_is_available;
    end if;

--  else

  end if;

  return l_is_available;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Is_Organization_Available;

/************************************************************************************
************************************************************************************/

procedure load_gl_calendar (
    p_api_version        IN NUMBER,
    p_commit             IN VARCHAR2,
    p_calendar_name     IN VARCHAR2,
    p_period_type       IN VARCHAR2,
    p_cal_period_type   IN VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER) IS

    -- cursor to check if GL Calendar has been loaded for any other planning cycle.

    cursor c_cal_per_type_valid is
    select 'VALID' from fpa_aw_pc_info_v
    where calendar_name = p_calendar_name
    and   period_type = p_period_type and pc_status <> 'CREATED' and rownum < 2;

    l_valid varchar2(30);
    CAL_PARAMETERS_INVALID EXCEPTION;
    l_str varchar2(2000);
    BEGIN

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Utilities_Pvt.load_gl_calendar.begin',
            'Entering FPA_Utilities_Pvt.load_gl_calendar'
        );
    END IF;

    /** Bug 4995505
    Commeting check below.  Calendar period values will always be loaded.
    **/
--    OPEN c_cal_per_type_valid;
--       fetch c_cal_per_type_valid into l_valid;

 --      if c_cal_per_type_valid%NOTFOUND then
        -- If cursor did not fetch any records,
        -- The calendar periods should be loaded.
        -- Call the OLAP program : LOAD_CALENDAR_PRG
        l_str :=  'call LOAD_CALENDAR_PRG('''||p_calendar_name||''''||' '||''''||p_period_type||''''||' '||''''||p_cal_period_type || ''')';
        dbms_aw.execute(l_str);
--      end if;
--    CLOSE c_cal_per_type_valid;

    IF (p_commit = FND_API.G_TRUE) THEN
        dbms_aw.execute('UPDATE');
        COMMIT;
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Utilities_Pvt.load_gl_calendar.end',
            'Entering FPA_Utilities_Pvt.load_gl_calendar'
        );
    END IF;

    EXCEPTION

     WHEN OTHERS then

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Utilities_Pvt.load_gl_calendar',
            SQLERRM
        );
        END IF;

        FND_MSG_PUB.count_and_get
        (
            p_count    =>      x_msg_count,
            p_data     =>      x_msg_data
        );
        RAISE;

    END;

function scenarios_recommended(
    p_planning_cycle_id IN  NUMBER
                              ) return varchar2 IS
    l_scenario_count number;
    l_scen_recommended varchar2(1);
    BEGIN

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Utils_Pvt.scenarios_recommended.start',
            'Entering FPA_Utils_Pvt.scenarios_recommended'
        );
     END IF;

 -- Count scenarios in Recommended status.
     select count(scenario) into l_scenario_count
        from fpa_aw_sce_info_v
        where planning_cycle = p_planning_cycle_id
        and recommended_flag = 1;

     IF l_scenario_count > 0 then
        l_scen_recommended := 'T';
      else
        l_scen_recommended := 'F';
     end if;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Utils_Pvt.scenarios_recommended.end',
            'Exiting FPA_Utils_Pvt.scenarios_recommended'
        );
     END IF;


    return l_scen_recommended;

    EXCEPTION

     WHEN OTHERS then
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Utils_Pvt.scenarios_recommended',
            SQLERRM
        );
        END IF;
      return l_scen_recommended;

end scenarios_recommended;


function scenario_approved(
    p_planning_cycle_id IN  NUMBER
                              ) return varchar2 IS
    l_scenario_count number;
    l_scen_approved varchar2(1) := 'F';
    BEGIN

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Utils_Pvt.scenario_approved.start',
            'Entering FPA_Utils_Pvt.scenario_approved'
        );
     END IF;

 -- Count scenarios in approved status.
     select count(scenario) into l_scenario_count
        from fpa_aw_sce_info_v
        where planning_cycle = p_planning_cycle_id
        and approved_flag = 1;

     IF l_scenario_count > 0 then
        l_scen_approved := 'T';
      else
        l_scen_approved := 'F';
     end if;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_Utils_Pvt.scenario_approved.end',
            'Exiting FPA_Utils_Pvt.scenario_approved'
        );
     END IF;


    return l_scen_approved;

    EXCEPTION

     WHEN OTHERS then
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Utils_Pvt.scenario_approved',
            SQLERRM
        );
        END IF;
      return l_scen_approved;

end scenario_approved;



-- Called from Advanced filter region to render category name as the label

procedure get_inv_category_name(
                p_planning_cycle_id in number,
                x_inv_category_name out  nocopy  varchar2
                   ) is
   cursor c_inv_cat_name is
     select class_category from pa_class_categories pac, fpa_aw_pc_info_v pci
       where pac.class_category_id = pci.pc_category
       and pci.planning_cycle = p_planning_cycle_id;

     l_inv_cat_name pa_class_categories.class_category%type;

begin
   open c_inv_cat_name;
   fetch c_inv_cat_name into l_inv_cat_name;
   close c_inv_cat_name;

   x_inv_category_name := l_inv_cat_name;
   return;

end;

procedure get_approver_name(
               p_portfolio_id in number,
               x_approver_names  out  nocopy  varchar2
               ) is

   cursor c_approver_names is
     select pe.full_name
       from
       pa_project_parties ppp, pa_project_role_types par , fnd_menu_entries fndm ,fnd_form_functions fndf,
       per_all_people_f pe, per_all_assignments_f prd
       where
       ppp.object_type = 'PJP_PORTFOLIO' and ppp.object_id = p_portfolio_id
       and ppp.PROJECT_ROLE_ID = par.project_role_id
       and par.menu_id = fndm.menu_id
       and fndm.function_id = fndf.function_id
       and fndf.function_name = 'FPA_SEC_APPROVE_PC'
       and ppp.resource_type_id = 101
       AND ppp.resource_source_id = pe.person_id
       AND trunc(sysdate) BETWEEN trunc(ppp.start_date_active)   AND trunc(NVL(ppp.end_date_active,sysdate))
       AND trunc(sysdate) BETWEEN trunc(pe.effective_start_date)   AND trunc(pe.effective_end_date)
       AND ppp.resource_source_id = prd.person_id
       AND prd.primary_flag = 'Y'
       AND prd.assignment_type = 'E'
       AND trunc(sysdate) BETWEEN trunc(prd.effective_start_date)  AND trunc(prd.effective_end_date)
       AND par.language = userenv('LANG')
       AND par.project_role_type = 'PORTFOLIO_APPROVER';


     l_approver_name varchar2(240);
     l_concat_approver_names varchar2(2000);

begin
   open c_approver_names;
   loop
      fetch c_approver_names into l_approver_name;
      exit when c_approver_names%notfound;
      l_concat_approver_names := l_concat_approver_names||l_approver_name||'; ';
   end loop;
   close c_approver_names;
   x_approver_names := rtrim(l_concat_approver_names,'; ');
   return;
exception
   when others then
     null;
end;

function Get_Fin_Metric_Unit(
p_planning_cycle_id IN  NUMBER,
p_metric_code IN VARCHAR2
) return VARCHAR2 is

l_unit varchar2(25);

BEGIN

if p_metric_code = 'NPV' then
  select NVL(currency_code,NULL) into l_unit from fpa_aw_pc_info_v
  where planning_cycle = p_planning_cycle_id;
else
    select NVL(meaning,NULL) into l_unit from fpa_lookups_V
    where lookup_type ='FPA_UNITS'
    AND lookup_code = decode(p_metric_code, 'IRR', 'PERCENT','PAYBACKPERIOD', 'MONTHS');
end if;

return l_unit;
EXCEPTION
  WHEN OTHERS then
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR  THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_ERROR,
            'fpa.sql.FPA_Utils_Pvt.Get_Fin_Metric_Unit',
            SQLERRM
        );
        END IF;
    return l_unit;
END Get_Fin_Metric_Unit;

/****END: Section for common API messages, exception handling and logging.******
********************************************************************************/
-------------------------------------------------------------------
--  Utility Function to Return the Correct Number data
--  even if the decimal character is changed.
-------------------------------------------------------------------
FUNCTION GET_FORMATTED_NUM(P_INPUT_STR IN VARCHAR2 )
RETURN NUMBER IS

L_DECIMAL_MARKER VARCHAR2(1);
L_OUTPUT_STR     NUMBER;

BEGIN
  SELECT SUBSTR(VALUE,1,1)
    INTO L_DECIMAL_MARKER
    FROM NLS_SESSION_PARAMETERS
   WHERE PARAMETER = 'NLS_NUMERIC_CHARACTERS';

    L_OUTPUT_STR := REPLACE( P_INPUT_STR , L_DECIMAL_MARKER,'.');
   RETURN To_Number(L_OUTPUT_STR);

EXCEPTION
  WHEN OTHERS THEN
   NULL;
   RETURN L_OUTPUT_STR;

END GET_FORMATTED_NUM;

end FPA_Utils_PVT;

/
