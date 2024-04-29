--------------------------------------------------------
--  DDL for Package Body IGW_PROP_COSTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_COSTS" as
--$Header: igwprs2b.pls 115.3 2002/03/28 19:13:47 pkm ship    $

  Function get_annual_direct_costs(i_prop_id   NUMBER) RETURN NUMBER is
  o_annual_cost      number;
  Begin
    select ibp.total_direct_cost
    into o_annual_cost
    from igw_budget_periods  ibp, igw_budgets  ib
    where ibp.proposal_id = i_prop_id and
          ibp.proposal_id = ib.proposal_id  and
          ibp.version_id = ib.version_id and
          ib.final_version_flag = 'Y' and
          ibp.budget_period_id = 1;

    RETURN o_annual_cost;

  Exception
    when no_data_found then
         o_annual_cost := null;
         RETURN o_annual_cost;
  End;


  Function get_total_costs(i_prop_id   NUMBER) RETURN NUMBER is
  o_total_cost      number;
  Begin
    select total_cost
    into o_total_cost
    from igw_budgets
    where proposal_id = i_prop_id and
          final_version_flag = 'Y';

    RETURN o_total_cost;

  Exception
    when no_data_found then
       o_total_cost := null;
       RETURN o_total_cost;

  End;

  END IGW_PROP_COSTS;

/
