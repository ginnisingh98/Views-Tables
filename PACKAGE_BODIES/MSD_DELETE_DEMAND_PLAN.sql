--------------------------------------------------------
--  DDL for Package Body MSD_DELETE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DELETE_DEMAND_PLAN" AS
/* $Header: msddpdb.pls 120.1 2005/09/30 06:13:26 amitku noship $ */

procedure Delete (errbuf out nocopy varchar2,
		  retcode out nocopy varchar2,
                  planId in varchar2,
		  can_Connect in varchar2,
		  Demand_Plan_Name in varchar2,
		  Shared_DB_Prefix in varchar2,
		  Code_Location in varchar2,
		  Shared_DB_Location in varchar2,
		  Express_Machine_Port in varchar2,
	  	  OWA_Virtual_Path_Name in varchar2,
		  EAD_Name in varchar2,
		  Express_Connect_String in varchar2,
		  DeleteAnyway in varchar2) is


cursor c1 is
select nvl(dp_build_refresh_num,0)
from msd_demand_plans
where demand_plan_id = planId;

l_dp_build_refresh_num number := 0;


BEGIN
retcode := '0';

update msd_demand_plans
  set delete_plan_flag = 'YES'
  where demand_plan_id = planId;

open c1;
fetch c1 into l_dp_build_refresh_num;
close c1;

if l_dp_build_refresh_num >= 0 then
msd_dpe.purge(errbuf, retcode, planId,
		  Demand_Plan_Name,
		  Shared_DB_Prefix,
		  Code_Location,
		  Shared_DB_Location,
		  Express_Machine_Port,
	  	  OWA_Virtual_Path_Name,
		  EAD_Name,
		  Express_Connect_String,
		  DeleteAnyway,
		  can_Connect);
end if;
if ((retcode in ('0','1')) or ((retcode = '2') and ((nvl(can_Connect, 'NO')) = 'YES'))) then

  DELETE FROM msd_demand_plans
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_dimensions
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_parameters
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_scenarios
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_hierarchies
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_express_setup
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_scenario_output_levels
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_scenario_events
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_scenario_entries
  WHERE demand_plan_id = planId;

/* Fix. Need to delete Headers as well when entries are deleted. */

  DELETE FROM msd_dp_scenario_revisions
  WHERE demand_plan_id = planId;

  DELETE FROM msd_dp_events
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_price_lists
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_calendars
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_cs_data_ds
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_parameters_ds
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_level_values_ds
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_seeded_documents
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_seeded_doc_dimensions
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_doc_dim_selections
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_formulas
  WHERE  demand_plan_id = planId;

  DELETE FROM msd_dp_formula_parameters
  WHERE  demand_plan_id = planId;

  /*--------Bug 4615390--------*/
  DELETE FROM msd_dp_iso_organizations
  where demand_plan_id = planId;

  fnd_file.new_line(fnd_file.log, 1);
  fnd_file.put_line(fnd_file.log, 'The Planning Server Demand Plan Definition was processed for deletion.');

else
  update msd_demand_plans
  set delete_plan_flag = 'NO'
  where demand_plan_id = planId;
  fnd_file.new_line(fnd_file.log, 1);
  fnd_file.put_line(fnd_file.log, 'The Planning Server Demand Plan Definition was not processed for deletion.');

  fnd_file.put_line(fnd_file.log, '    ' || errbuf);

end if;
exception
  when others then
    update msd_demand_plans
    set delete_plan_flag = 'NO'
    where demand_plan_id = planId;

    retcode := '2';
end Delete;
End;

/
