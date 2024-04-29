--------------------------------------------------------
--  DDL for Package Body PJI_COMPLETION_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_COMPLETION_GRAPH" as
/*  $Header: PJIATCGB.pls 120.0.12010000.3 2009/08/22 08:27:07 paljain ship $  */
procedure get_bgt_ver_period(
			 p_budget_cost_plan_id IN Number default null,
			 p_budget_rev_plan_id IN Number default null,
			 p_forecast_cost_plan_id IN Number default null,
			 p_forecast_rev_plan_id IN Number default null,
                         p_project_id IN Number,
			 p_table_identifier Varchar ,
			 p_calendar_id IN Number default null) is

	tab_budget_cost_version_id 	PA_PLSQL_DATATYPES.IdTabTyp;
	tab_budget_blined_cost_date	PA_PLSQL_DATATYPES.DateTabTyp;
	tab_budget_rev_version_id 	PA_PLSQL_DATATYPES.IdTabTyp;
	tab_budget_blined_rev_date	PA_PLSQL_DATATYPES.DateTabTyp;
	tab_forecast_cost_version_id 	PA_PLSQL_DATATYPES.IdTabTyp;
	tab_forecast_blined_cost_date	PA_PLSQL_DATATYPES.DateTabTyp;
	tab_forecast_rev_version_id 	PA_PLSQL_DATATYPES.IdTabTyp;
	tab_forecast_blined_rev_date	PA_PLSQL_DATATYPES.DateTabTyp;
	l_plan_version_id     number;

        ins_version_id      PA_PLSQL_DATATYPES.IdTabTyp;
        ins_name              PA_PLSQL_DATATYPES.Char30TabTyp;
	ins_period_id	PA_PLSQL_DATATYPES.NumTabTyp;
        ins_start_date       PA_PLSQL_DATATYPES.DateTabTyp;
        ins_end_date        PA_PLSQL_DATATYPES.DateTabTyp;
        ins_cst_rev_flag    PA_PLSQL_DATATYPES.Char1TabTyp;
        ins_budget_forecast_flag  PA_PLSQL_DATATYPES.Char1TabTyp;

        ins_pltab_counter number :=0;

	/* Bug 4118904
	/* This will denote the index that we can use for carry forward */
	l_last_bud_cost_index	Number;
	l_last_bud_rev_index	Number;
	l_last_for_cost_index	Number;
	l_last_for_rev_index	Number;

	/* this denotes if we found a plan for the current period */
	l_found					Boolean;

	/* Counter to track the number of versions looped thru */
	l_bud_cst_ver_index    Number;
	l_bud_rev_ver_index    Number;
	l_for_cst_ver_index    Number;
	l_for_rev_ver_index    Number;

	/* This indicates if we have already processed the latest baselined version */
	l_latest_bud_cst_ver	Boolean;
	l_latest_bud_rev_ver	Boolean;
	l_latest_for_cst_ver	Boolean;
	l_latest_for_rev_ver	Boolean;
	l_latest_all_ver        Boolean;

	l_version_type           VARCHAR2(30);                  --Bug fix 8593605

	CURSOR c_get_dates is
		SELECT 	name,
		ent_period_id period_id,
		start_date ,
		end_date
		FROM  	pji_time_ent_period_v
		where 	p_table_identifier = 'PJI_TIME_ENT_PERIOD_V'
	UNION ALL
		SELECT 	name,
		ent_qtr_id period_id,
		start_date,
		end_date
		FROM  	pji_time_ent_qtr_v
		where 	p_table_identifier = 'PJI_TIME_ENT_QTR_V'
	UNION ALL
		SELECT  name,
		ent_year_id period_id,
		start_date,
		end_date
		FROM 	pji_time_ent_year_v
		where 	p_table_identifier = 'PJI_TIME_ENT_YEAR_V'
	UNION ALL
		SELECT 	name,
		cal_period_id period_id,
		start_date,
		end_date
		FROM  	pji_time_cal_period_v
		where p_table_identifier = 'PJI_TIME_CAL_PERIOD_V'
		and CALENDAR_ID = p_calendar_id
	UNION ALL
		SELECT 	name,
		cal_qtr_id period_id,
		start_date,
		end_date
		FROM 	pji_time_cal_qtr_v
		where 	p_table_identifier = 'PJI_TIME_CAL_QTR_V'
		and CALENDAR_ID = p_calendar_id
	UNION ALL
		SELECT 	name,
		cal_year_id period_id,
		start_date,
		end_date
		FROM 	pji_time_cal_year_v
		where 	p_table_identifier = 'PJI_TIME_CAL_YEAR_V'
		and CALENDAR_ID = p_calendar_id;


	/* Here order by clause with baselined_date is important because
	   for a period there can be more than one baselined version, to
	   take the closest to the period end date this logic is used*/

	/* BELOW CURSOR WILL BE REPLACED BY FIN PLAN QUERY OR PROCEDURE*/

	Cursor all_budget_ver is
                   select budget_version_id, baselined_date from pa_budget_versions
                   where project_id=p_project_id
                   and fin_plan_type_id=l_plan_version_id
                   and budget_status_code='B'
		   and (version_type = l_version_type OR version_type = 'ALL')		   --Bug fix 8593605 & 8827836
                   order by baselined_date desc;

        begin

	/* Fetching for cost budget in plsql table */
	l_plan_version_id := p_budget_cost_plan_id;
	l_version_type := 'COST';                                   --Bug fix 8593605
	Open all_budget_ver;
	Fetch all_budget_ver BULK COLLECT into tab_budget_cost_version_id,
				               tab_budget_blined_cost_date;
        close all_budget_ver;

	/* Fetching for rev budget in plsql table */
	l_plan_version_id := p_budget_rev_plan_id;
	l_version_type := 'REVENUE';                                  --Bug fix 8593605
	Open all_budget_ver;
	Fetch all_budget_ver BULK COLLECT into tab_budget_rev_version_id,
					       tab_budget_blined_rev_date;
        close all_budget_ver;

	/* Fetching for cost forecast in plsql table */
	l_plan_version_id := p_forecast_cost_plan_id;
	l_version_type := 'COST';                                     --Bug fix 8593605
	Open all_budget_ver;
	Fetch all_budget_ver BULK COLLECT into tab_forecast_cost_version_id,
					       tab_forecast_blined_cost_date;
        close all_budget_ver;

	/* Fetching for rev forecast in plsql table */
	l_plan_version_id := p_forecast_rev_plan_id;
	l_version_type := 'REVENUE';                                   --Bug fix 8593605
	Open all_budget_ver;
	Fetch all_budget_ver BULK COLLECT into tab_forecast_rev_version_id,
				  	       tab_forecast_blined_rev_date;
        close all_budget_ver;

	l_last_bud_cost_index := 0;
	l_last_bud_rev_index  := 0;
	l_last_for_cost_index := 0;
	l_last_for_rev_index  := 0;

	/*
	   These are flags that indicate if we have already processed the latest baselined plan version.
	   if all the latest baselined versions have been processed we will not carry forward any further.
	*/
	l_latest_bud_cst_ver := false;
	l_latest_bud_rev_ver := false;
	l_latest_for_cst_ver := false;
	l_latest_for_rev_ver := false;
	l_latest_all_ver     := false;

    FOR s_period_fetch in c_get_dates
    Loop
		l_found := false;
		l_bud_cst_ver_index := 0;
		l_bud_rev_ver_index := 0;
		l_for_cst_ver_index := 0;
		l_for_rev_ver_index := 0;

		for i in 1..tab_budget_cost_version_id.count
		loop
		/* Checks whether baselined date is between start and end date, if yes then
		   inserts a  record and then exist out of this loop*/
		    l_bud_cst_ver_index := l_bud_cst_ver_index + 1;
			if ((tab_budget_blined_cost_date(i) <= s_period_fetch.end_date) AND (tab_budget_blined_cost_date(i) >= s_period_fetch.start_date)) then
							ins_pltab_counter := ins_pltab_counter + 1;

							ins_version_id(ins_pltab_counter) :=  tab_budget_cost_version_id(i);
							ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
							ins_period_id(ins_pltab_counter) :=   s_period_fetch.period_id;
							ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
							ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
							ins_cst_rev_flag(ins_pltab_counter) := 'C';
							ins_budget_forecast_flag(ins_pltab_counter) := 'B';

							l_last_bud_cost_index := ins_pltab_counter;
							l_found := true;

							if(l_bud_cst_ver_index = 1) then
								l_latest_bud_cst_ver := true;
							end if;
				exit;
			end if;
		end loop;

		/*
		  Bug 4185866. It is possible that no plan versions exist for this type. In this case,
		  ignore this for carry forward.
		*/
		if(l_bud_cst_ver_index = 0) then
			l_latest_bud_cst_ver := true;
		end if;

		/*
		   Bug 4118904. Copy the previous period amount to the current period if no
		   baselined version was found for the current period. Please note that this
		   version's baseline date doesnot actually lie between the period start and end
		   dates. This should be done only till we have hit the latest baselined version
		   of all four types.
		*/
		if(l_found = false and l_last_bud_cost_index <> 0 and l_latest_all_ver = false) then
			ins_pltab_counter := ins_pltab_counter + 1;

			ins_version_id(ins_pltab_counter) :=  ins_version_id(l_last_bud_cost_index);
			ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
			ins_period_id(ins_pltab_counter)  :=  s_period_fetch.period_id;
			ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
			ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
			ins_cst_rev_flag(ins_pltab_counter) := 'C';
			ins_budget_forecast_flag(ins_pltab_counter) := 'B';
		end if;

		l_found := false;
		for i in 1..tab_budget_rev_version_id.count
		loop
		    l_bud_rev_ver_index := l_bud_rev_ver_index + 1;
			if ((tab_budget_blined_rev_date(i) <= s_period_fetch.end_date) AND (tab_budget_blined_rev_date(i) >= s_period_fetch.start_date))then
							ins_pltab_counter := ins_pltab_counter + 1;

							ins_version_id(ins_pltab_counter) :=  tab_budget_rev_version_id(i);
							ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
							ins_period_id(ins_pltab_counter) :=  s_period_fetch.period_id;
							ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
							ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
							ins_cst_rev_flag(ins_pltab_counter) := 'R';
							ins_budget_forecast_flag(ins_pltab_counter) := 'B';

							l_last_bud_rev_index := ins_pltab_counter;
							l_found := true;

							if(l_bud_rev_ver_index = 1) then
								l_latest_bud_rev_ver := true;
							end if;
				exit;
			end if;
		end loop;

		/*
		  Bug 4185866. It is possible that no plan versions exist for this type. In this case,
		  ignore this for carry forward.
		*/
		if(l_bud_rev_ver_index = 0) then
			l_latest_bud_rev_ver := true;
		end if;

		/*
		   Bug 4118904. Copy the previous period amount to the current period if no
		   baselined version was found for the current period. Please note that this
		   version's baseline date doesnot actually lie between the period start and end
		   dates.
		*/
		if(l_found = false and l_last_bud_rev_index <> 0 and l_latest_all_ver = false) then
			ins_pltab_counter := ins_pltab_counter + 1;

			ins_version_id(ins_pltab_counter) :=  ins_version_id(l_last_bud_rev_index);
			ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
			ins_period_id(ins_pltab_counter)  :=  s_period_fetch.period_id;
			ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
			ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
			ins_cst_rev_flag(ins_pltab_counter) := 'R';
			ins_budget_forecast_flag(ins_pltab_counter) := 'B';
		end if;

		l_found := false;
		for i in 1..tab_forecast_cost_version_id.count
		loop
		    l_for_cst_ver_index := l_for_cst_ver_index + 1;
			if ((tab_forecast_blined_cost_date(i) <= s_period_fetch.end_date) AND (tab_forecast_blined_cost_date(i) >= s_period_fetch.start_date))then
							ins_pltab_counter := ins_pltab_counter + 1;

							ins_version_id(ins_pltab_counter) :=  tab_forecast_cost_version_id(i);
							ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
							ins_period_id(ins_pltab_counter)	:=  s_period_fetch.period_id;
							ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
							ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
							ins_cst_rev_flag(ins_pltab_counter) := 'C';
							ins_budget_forecast_flag(ins_pltab_counter) := 'F';

							l_last_for_cost_index := ins_pltab_counter;
							l_found := true;

							if(l_for_cst_ver_index = 1) then
								l_latest_for_cst_ver := true;
							end if;
				exit;
			end if;
		end loop;

		/*
		  Bug 4185866. It is possible that no plan versions exist for this type. In this case,
		  ignore this for carry forward.
		*/
		if(l_for_cst_ver_index = 0) then
			l_latest_for_cst_ver := true;
		end if;

		if(l_found = false and l_last_for_cost_index <> 0 and l_latest_all_ver=false) then
			ins_pltab_counter := ins_pltab_counter + 1;

			ins_version_id(ins_pltab_counter) :=  ins_version_id(l_last_for_cost_index);
			ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
			ins_period_id(ins_pltab_counter)  :=  s_period_fetch.period_id;
			ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
			ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
			ins_cst_rev_flag(ins_pltab_counter) := 'C';
			ins_budget_forecast_flag(ins_pltab_counter) := 'F';
		end if;

		l_found := false;
		for i in 1..tab_forecast_rev_version_id.count
		loop
		    l_for_rev_ver_index := l_for_rev_ver_index + 1;
			if ((tab_forecast_blined_rev_date(i) <= s_period_fetch.end_date) AND (tab_forecast_blined_rev_date(i) >= s_period_fetch.start_date)) then
							ins_pltab_counter := ins_pltab_counter + 1;

							ins_version_id(ins_pltab_counter) :=  tab_forecast_rev_version_id(i);
							ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
							ins_period_id(ins_pltab_counter) :=  s_period_fetch.period_id;
							ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
							ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
							ins_cst_rev_flag(ins_pltab_counter) := 'R';
							ins_budget_forecast_flag(ins_pltab_counter) := 'F';

							l_last_for_rev_index := ins_pltab_counter;
							l_found := true;

							if(l_for_rev_ver_index = 1) then
								l_latest_for_rev_ver := true;
							end if;
				exit;
			end if;
		end loop;

		/*
		  Bug 4185866. It is possible that no plan versions exist for this type. In this case,
		  ignore this for carry forward.
		*/
		if(l_for_rev_ver_index = 0) then
			l_latest_for_rev_ver := true;
		end if;

		if(l_found = false and l_last_for_rev_index <> 0 and l_latest_all_ver=false) then
			ins_pltab_counter := ins_pltab_counter + 1;

			ins_version_id(ins_pltab_counter) :=  ins_version_id(l_last_for_rev_index);
			ins_name(ins_pltab_counter)       :=  s_period_fetch.name;
			ins_period_id(ins_pltab_counter)  :=  s_period_fetch.period_id;
			ins_start_date(ins_pltab_counter) :=  s_period_fetch.start_date;
			ins_end_date(ins_pltab_counter)   :=  s_period_fetch.end_date;
			ins_cst_rev_flag(ins_pltab_counter) := 'R';
			ins_budget_forecast_flag(ins_pltab_counter) := 'F';
		end if;

		/* see if the latest baselined versions have been processed for all four cases.*/
		if(l_latest_all_ver = false and
		   l_latest_bud_cst_ver = true and
		   l_latest_bud_rev_ver = true and
		   l_latest_for_cst_ver = true and
		   l_latest_for_rev_ver = true
		   )
		then
			l_latest_all_ver := true;
		end if;

    end loop;/* End of s_period_fetch in c_get_dates */

     Bud_period_version_ins( p_ins_version_id           => ins_version_id,
                             p_ins_name                 => ins_name,
							 p_ins_period_id			=> ins_period_id,
                             p_ins_start_date           => ins_start_date,
                             p_ins_end_date             => ins_end_date,
                             p_ins_cst_rev_flag         => ins_cst_rev_flag,
                             p_ins_budget_forecast_flag => ins_budget_forecast_flag);

end get_bgt_ver_period;

procedure Bud_period_version_ins (p_ins_version_id      PA_PLSQL_DATATYPES.IdTabTyp,
                                  p_ins_name            PA_PLSQL_DATATYPES.Char30TabTyp,
								  p_ins_period_id		PA_PLSQL_DATATYPES.NumTabTyp,
                                  p_ins_start_date      PA_PLSQL_DATATYPES.DateTabTyp,
                                  p_ins_end_date        PA_PLSQL_DATATYPES.DateTabTyp,
                                  p_ins_cst_rev_flag    PA_PLSQL_DATATYPES.Char1TabTyp,
                                  p_ins_budget_forecast_flag  PA_PLSQL_DATATYPES.Char1TabTyp) is
begin

       delete from  pji_period_budget_ver_tmp;
       FORALL j IN 1..p_ins_version_id.count
	insert into pji_period_budget_ver_tmp(
				name,
				period_id,
				budget_version_id,
				start_date,
				end_date,
				cst_rev_flag,
				bud_for_act_flag)
			values	(p_ins_name(j),
				 p_ins_period_id(j),
      				 p_ins_version_id(j),
				 p_ins_start_date(j),
				 p_ins_end_date(j),
			      	 p_ins_cst_rev_flag(j),
			      	 p_ins_budget_forecast_flag(j));
End Bud_period_version_ins;

End PJI_COMPLETION_GRAPH;

/
