--------------------------------------------------------
--  DDL for Package Body IGW_VIEW_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_VIEW_PARAMETERS" as
--$Header: igwprprb.pls 115.8 2002/10/18 01:36:51 vmedikon ship $

  Function get_project_location_id (i_proposal_id   NUMBER) RETURN NUMBER is
  o_project_location_id      number(15);
  Begin
    select performing_organization_id
    into o_project_location_id
    from igw_prop_locations
    where proposal_id = i_proposal_id AND
          rownum = 1;
    RETURN o_project_location_id;
  exception
     when no_data_found then
         o_project_location_id := NULL;
         RETURN o_project_location_id;
  End;
------------------------------------------------------------------------------------------

  Function get_project_location_name(i_organization_id   NUMBER) RETURN VARCHAR2 is
  o_project_location_name      	hr_all_organization_units.NAME%TYPE;
  Begin
    if (i_organization_id is null) then
        o_project_location_name := NULL;
        RETURN o_project_location_name;
    else
        select name
        into o_project_location_name
        from hr_organization_units
        where organization_id = i_organization_id;
        RETURN o_project_location_name;
    end if;
  End;
----------------------------------------------------------------------------------------------

  Function get_major_goals (i_proposal_id   NUMBER) RETURN VARCHAR2 is
  o_major_goals      varchar2(250);
  Begin
    select substr(abstract, 1, 250)
    into o_major_goals
    from igw_prop_abstracts
    where proposal_id = i_proposal_id AND
          abstract_type = 'IGW_ABSTRACT_TYPES' AND
          abstract_type_code = 'IGW1';
    RETURN o_major_goals;
  exception
     when no_data_found then
         o_major_goals := NULL;
         RETURN o_major_goals;
  End;
---------------------------------------------------------------------------------------------------
  Function get_pi_id (i_award_id   NUMBER,
                      i_proposal_id  NUMBER) RETURN NUMBER is
   o_pi_id      number;
   prop_start_date    date;
  Begin
      select proposal_start_date
      into prop_start_date
      from igw_proposals
      where proposal_id = i_proposal_id;

      o_pi_id := 0;

      select person_id
      into o_pi_id
      from gms_personnel gp
      where award_id = i_award_id and
            award_role = 'AM' and
            prop_start_date >= start_date_active and
            prop_start_date <= nvl(end_date_active, sysdate);

      return o_pi_id;
   Exception
       when no_data_found then
       begin
           select person_id
           into o_pi_id
           from gms_personnel gp
           where award_id = i_award_id and
                 award_role = 'AM' and
                 rownum = 1;
           return o_pi_id;
        Exception
             when no_data_found then
                o_pi_id := null;
                return o_pi_id;
        End;
  End get_pi_id;
---------------------------------------------------------------------------------------------------
 Function get_pi_name (i_award_id   NUMBER,
                      i_proposal_id NUMBER) RETURN VARCHAR2 is
   prop_start_date    date;
   o_pi_id   number;
   o_pi_name  	per_all_people_f.FULL_NAME%TYPE;
  Begin
      select proposal_start_date
      into prop_start_date
      from igw_proposals
      where proposal_id = i_proposal_id;

      o_pi_id := 0;
      o_pi_name := 'pi';

      select gp.person_id, ppx.full_name
      into o_pi_id, o_pi_name
      from gms_personnel gp, per_people_x ppx
      where gp.award_id = i_award_id and
            gp.award_role = 'AM' and
            prop_start_date >= gp.start_date_active and
            prop_start_date <= nvl(gp.end_date_active, sysdate) and
            gp.person_id = ppx.person_id;
      return o_pi_name;
   Exception
       when no_data_found then
       begin
           select gp.person_id, ppx.full_name
           into o_pi_id, o_pi_name
           from gms_personnel gp, per_people_x ppx
           where gp.award_id = i_award_id and
                 gp.award_role = 'AM' and
                 gp.person_id = ppx.person_id and
                 rownum = 1;
           return o_pi_name;
        Exception
             when no_data_found then
                o_pi_id := null;
                o_pi_name := null;
              return o_pi_name;
        End;
     End get_pi_name;

----------------------------------------------------------------------------------------------------
  Function get_percent_effort (i_proposal_id   NUMBER,
                               i_person_id  NUMBER) RETURN NUMBER is
   o_percent_effort      number;

  begin
              select percent_effort
              into o_percent_effort
              from igw_prop_persons
              where proposal_id = i_proposal_id
              AND person_id = i_person_id;
              return o_percent_effort;
  exception
       when others then
             o_percent_effort := NULL;
             return o_percent_effort;

  End get_percent_effort;

  ----------------------------------------------------------------------------------------------------
   Function get_direct_cost (i_award_id   NUMBER,
                             i_proposal_id  NUMBER) RETURN NUMBER is

  prop_start_date    date;
  o_direct_cost    number;
  Begin
      select proposal_start_date
      into prop_start_date
      from igw_proposals
      where proposal_id = i_proposal_id;

      select sum(direct_cost)
      into o_direct_cost
      from gms_installments
      where award_id = i_award_id and
          active_flag = 'Y' and
          prop_start_date >= start_date_active and
          prop_start_date <= nvl(end_date_active, sysdate);
          return o_direct_cost;
   Exception
       when no_data_found then
           o_direct_cost := null;
           return o_direct_cost;
  End get_direct_cost;

  --------------------------------------------------------------------------------------------------------
     Function get_total_cost (i_award_id   NUMBER,
                             i_proposal_id  NUMBER) RETURN NUMBER is

  prop_start_date    date;
  o_total_cost    number;
  Begin
      select proposal_start_date
      into prop_start_date
      from igw_proposals
      where proposal_id = i_proposal_id;

      select sum(direct_cost + indirect_cost)
      into o_total_cost
      from gms_installments
      where award_id = i_award_id and
          active_flag = 'Y' and
          prop_start_date >= start_date_active and
          prop_start_date <= nvl(end_date_active, sysdate);
          return o_total_cost;
   Exception
       when no_data_found then
           o_total_cost := null;
           return o_total_cost;
  End get_total_cost;

  ---------------------------------------------------------------------------------------------------------
  Function get_old_direct_cost (i_award_id   NUMBER) RETURN NUMBER is

  o_old_direct_cost    number;
  Begin
      select sum(direct_cost)
      into o_old_direct_cost
      from gms_installments
      where award_id = i_award_id;
          return o_old_direct_cost;
   Exception
       when no_data_found then
           o_old_direct_cost := null;
           return o_old_direct_cost;
  End get_old_direct_cost;

  -------------------------------------------------------------------------------------------------------------
   Function get_old_total_cost (i_award_id   NUMBER) RETURN NUMBER is

  o_old_total_cost    number;
  Begin
      select sum(direct_cost + indirect_cost)
      into o_old_total_cost
      from gms_installments
      where award_id = i_award_id;
          return o_old_total_cost;
   Exception
       when no_data_found then
           o_old_total_cost := null;
           return o_old_total_cost;
  End get_old_total_cost;

  END IGW_VIEW_PARAMETERS;

/
