--------------------------------------------------------
--  DDL for Package Body IGW_AWARD_PARTICULARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_AWARD_PARTICULARS_PKG" as
--$Header: igwprsub.pls 115.10 2002/11/14 18:38:31 vmedikon ship $
  procedure get_award_costs(
                i_award_id in NUMBER,
                i_proposal_id in NUMBER,
                o_direct_cost out NOCOPY NUMBER,
                o_total_cost out NOCOPY NUMBER) is
  prop_start_date    date;

  Begin
      select proposal_start_date
      into prop_start_date
      from igw_proposals
      where proposal_id = i_proposal_id;

      select sum(direct_cost), sum(direct_cost + indirect_cost)
      into o_direct_cost, o_total_cost
      from gms_installments
      where award_id = i_award_id and
          active_flag = 'Y' and
          prop_start_date >= start_date_active and
          prop_start_date <= nvl(end_date_active, sysdate);
   Exception
       when no_data_found then
           o_direct_cost := null;
           o_total_cost := null;
   End get_award_costs;
 ---------------------------------------------------------------------------------------------------
  procedure get_old_award_costs(
                i_award_id in NUMBER,
                o_direct_cost out NOCOPY NUMBER,
                o_total_cost out NOCOPY NUMBER) is

  Begin
      select sum(direct_cost), sum(direct_cost + indirect_cost)
      into o_direct_cost, o_total_cost
      from gms_installments
      where award_id = i_award_id;
   Exception
       when no_data_found then
           o_direct_cost := null;
           o_total_cost := null;
   End get_old_award_costs;
 ---------------------------------------------------------------------------------------------------

  Procedure get_pi (i_award_id in NUMBER, i_proposal_id in NUMBER,
                              o_pi_id out NOCOPY NUMBER, o_pi_name out NOCOPY VARCHAR2) is
  prop_start_date    date;
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
        Exception
             when no_data_found then
                o_pi_id := null;
                o_pi_name := null;
        End;
   End get_pi;

  END IGW_AWARD_PARTICULARS_PKG;

/
