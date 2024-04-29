--------------------------------------------------------
--  DDL for Package Body MSD_APPLY_TEMPLATE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_APPLY_TEMPLATE_DEMAND_PLAN" AS
/* $Header: msdatdpb.pls 120.24 2006/05/29 12:21:07 brampall noship $ */

/* Private Package Variables */





/* Private Procedures	*/



g_sno	number :=	0;

g_call	boolean	:= FALSE;



Procedure	common_post_copy_process(p_new_dp_id in	number);



Procedure	sop_post_copy_process(p_new_dp_id	in number);



Procedure	liab_post_copy_process(p_new_dp_id in	number);



Procedure	common_all_post_process(p_new_dp_id	in number);



Procedure	Update_Formula_Names(p_new_dp_id in	number);



Procedure	Replace_formula_tokens(p_new_dp_id in	number);



Procedure	Parse_Dimension_Select_List(p_new_dp_id	in number);



Procedure	Replace_dimension_tokens(p_new_dp_id in	number);



Procedure	update_ascp_related_data(p_new_dp_id in	number);



Procedure	Validate_formula_parameters(p_new_dp_id	in number);



Procedure	validate_formulas(p_new_dp_id	in number);



Procedure	validate_doc_dim_selections(p_new_dp_id	in number);



Procedure	validate_doc_dimensions(p_new_dp_id	in number);



Procedure	validate_documents(p_new_dp_id in	number);



Procedure	refresh_document_dimensions(p_demand_plan_id in	number);



Procedure	refresh_formulas(p_demand_plan_id	in number);



Procedure	eol_post_copy_process(p_new_dp_id	in number);

Procedure	add_ascp_scenario_for_eol(p_new_dp_id	in number,p_supply_plan_id in	number,	p_supply_plan_name in	varchar2);

Procedure	update_parameter_dates(p_demand_plan_id number);

Function get_dimension_script( p_demand_plan_id	varchar2,p_dimension_code	varchar2,p_dimension_script	varchar2)	return varchar2;



Function get_dimension_code( p_demand_plan_id	varchar2,p_dimension_code	varchar2)	return varchar2;



Function get_level_id	(p_demand_plan_id	number,p_level_id	number)	return number;



Function get_hierarchy_id	(p_demand_plan_id	varchar2,p_hierarchy_id	varchar2)	return number;



/* Public	Procedures and Function	*/



/*******************************************************

This Function	creates	the	plan using template.

Parameter	p_shared_db_location should	be 'MSD'||p_new_dp_id.

Called from	MSDDPLNS.fmb and msd_apply_template_demand_plan.create_plan_using_template.

Calls	msd_copy_demand_plan.copy_demand_plan.

Returns	0	if successful	and	1	if not.

********************************************************/



function apply_template(

p_new_dp_id	in out nocopy	number,

p_target_demand_plan_name	in VARCHAR2,

p_target_demand_plan_descr in	VARCHAR2,

p_shared_db_location in	VARCHAR2,

p_source_dp_id in	NUMBER,

p_organization_id	in number,

p_instance_id	 in	number,

p_errcode	in out nocopy	varchar2

)	return NUMBER	IS



x_ret_val	number;



BEGIN



				-- Copy	Plan from	Template

				x_ret_val	:= msd_copy_demand_plan.copy_demand_plan(

								p_new_dp_id,

		p_target_demand_plan_name,

		p_target_demand_plan_descr,

								'MSD'||	p_new_dp_id,

		p_source_dp_id,

		p_organization_id,

		p_instance_id,

		p_errcode);





				if x_ret_val = 0 then



					-- Processing	common to	all	plan types

		common_post_copy_process(p_new_dp_id);



		-- Processing	for	SOP	Plans

		sop_post_copy_process(p_new_dp_id);



		-- Processing	for	LIABILITY	Plans

		liab_post_copy_process(p_new_dp_id);



		-- Processing	for	EOL	Plans

		eol_post_copy_process(p_new_dp_id);



		-- Process again for all plan	types

		common_all_post_process(p_new_dp_id);



		-- Compile The seeded	docs and formulas

		create_seeded_definitions(p_new_dp_id,p_errcode);



		-- commit	the	changes

		commit;

		return 0;

	end	if;



return 1;



EXCEPTION





				WHEN OTHERS	THEN

				p_new_dp_id	:= null	;

				p_errcode	:= substr(SQLERRM,1,150);

				return 1;





END	apply_template;



/*******************************************************

This Function	is a wrapper over	apply_template function.

Parameter	p_shared_db_location should	be 'MSD'||p_new_dp_id.

Called from	Launch Liability Program.

Calls	MSD_APPLY_TEMPLATE_DEMAND_PLAN.apply_template.

Returns	TRUE if	successful and FALSE if	not.

********************************************************/



function create_plan_using_template(

p_new_dp_id	in out nocopy	number,

p_target_demand_plan_name	in VARCHAR2,

p_target_demand_plan_descr in	VARCHAR2,

p_plan_type	in VARCHAR2,

p_plan_start_date	in date,

p_plan_end_date	in date,

p_supply_plan_id in	number,

p_supply_plan_name in	VARCHAR2,

p_organization_id	in number,

p_instance_id	 in	number,

p_errcode	in out nocopy	varchar2

)	return boolean is



cursor c1	is

select demand_plan_id

from msd_demand_plans

where	plan_type	=	p_plan_type

and	template_flag	=	'Y'

and	default_template = 'Y';



x_ret_val	number;

l_template_id	number;



BEGIN





	open c1;

	fetch	c1 into	l_template_id;

	close	c1;



				-- Create	Plan from	Template

	x_ret_val	:= MSD_APPLY_TEMPLATE_DEMAND_PLAN.apply_template(

								p_new_dp_id,

		p_target_demand_plan_name,

		p_target_demand_plan_descr,

								'MSD'	|| p_new_dp_id,

		l_template_id,

		p_organization_id,

		p_instance_id,

		p_errcode);





				if x_ret_val = 0 then





		-- Update	the	Liability	Specific Columns

		update msd_demand_plans

		set	plan_start_date	=	p_plan_start_date,

		plan_end_date	=	p_plan_end_date,

		liab_plan_id = p_supply_plan_id,

		liab_plan_name = p_supply_plan_name

		where	demand_plan_id = p_new_dp_id;



		-- Update	Dates	of the input parameters

		-- set the start date	and	end	date	for	input	parameters having	time data

		update msd_dp_parameters

		set	start_date = p_plan_start_date,

		end_date = p_plan_end_date

		where	demand_plan_id = p_new_dp_id

		and	forecast_date_used is	not	null

		and	deleteable_flag	=	'N';





					-- set the parameter name	to supply	plan name	for	input	parameters

		update msd_dp_parameters

		set	parameter_name = p_supply_plan_name

		where	demand_plan_id = p_new_dp_id;



					-- set the supply	plan name	to supply	plan name	for	doc	dim	selection

		update msd_dp_doc_dim_selections

		set	supply_plan_name = p_supply_plan_name

		where	demand_plan_id = p_new_dp_id

		and	selection_type = 'I';



					-- set the supply	plan name	to supply	plan name	for	formula	parameters

		update msd_dp_formula_parameters

		set	supply_plan_name = p_supply_plan_name

		where	demand_plan_id = p_new_dp_id

		and	parameter_type = 'I';



					set_prd_lvl_for_liab_reports(p_new_dp_id,p_errcode);



		-- Compile the definitions for seeded	documents	and	formulas

					create_seeded_definitions(p_new_dp_id,p_errcode);



				-- replace formula name	with ID

				update msd_dp_formulas mdf

				set	upload_formula_id	=	(select	formula_id from	msd_dp_formulas	mdf1

				where	mdf1.demand_plan_id	=	p_new_dp_id

				and	mdf1.formula_name	=	mdf.upload_formula_id)

				where	demand_plan_id = p_new_dp_id

				and	upload_formula_id	is not null;



		commit;



		return true;



	else



		return false;



	end	if;



EXCEPTION





				WHEN OTHERS	THEN

				p_new_dp_id	:= null	;

				p_errcode	:= substr(SQLERRM,1,150);

				return false;





END	create_plan_using_template;



/*******************************************************

This Procedure compiles	the	definitions	for	seeded documents and formulas.

Called from	msd_apply_template_demand_plan.create_plan_using_template	and	plan build pre processor.

Calls	refresh_document_dimensions, refresh_formulas, Parse_Dimension_Select_List,

Replace_formula_tokens,	Replace_dimension_tokens,	Validate_formula_parameters,

validate_formulas, validate_doc_dim_selections,	validate_doc_dimensions

and	validate_documents

********************************************************/



Procedure	create_seeded_definitions(p_demand_plan_id in	number,

p_errcode	in out nocopy	varchar2

)



is

cursor get_template_id is
select template_id
from msd_demand_plans
where demand_plan_id=p_demand_plan_id;

l_template_id varchar2(100);

Begin

		open get_template_id;
		fetch get_template_id into l_template_id;
		close get_template_id;

		if l_template_id is null then
				return;
		end if;

	-- refresh documents dimensions	data from	the	template

	refresh_document_dimensions(p_demand_plan_id);



	-- refresh formula data	from template

	refresh_formulas(p_demand_plan_id);



	-- parse the selection script	for	dimensions with	selection	type as	list

	-- Parse_Dimension_Select_List(p_demand_plan_id);	 commented out as	only one set of	ascp specific	measures needs to	be added to	a	doc



	-- replace tokens	in formulas	with values

	Replace_formula_tokens(p_demand_plan_id);



	-- replace tokens	in dimensions	with values

	Replace_dimension_tokens(p_demand_plan_id);



	-- validate	formula	parameters

	Validate_formula_parameters(p_demand_plan_id);



	-- validate	formulas

	validate_formulas(p_demand_plan_id);



	-- validate	dimension	selections

	validate_doc_dim_selections(p_demand_plan_id);



	-- validate	dimensions for seeded	docs

	validate_doc_dimensions(p_demand_plan_id);



	-- validate	seeded documents

	validate_documents(p_demand_plan_id);



EXCEPTION





				WHEN OTHERS	THEN

				p_errcode	:= substr(SQLERRM,1,150);



End	create_seeded_definitions;



/*******************************************************

This Procedure refreshes the document	dimension	definitions	for	the	plan from	the	template.

This is	required to	get	the	original seeded	data and then	create the definitions again from	the	plan.

********************************************************/



Procedure	refresh_document_dimensions(p_demand_plan_id in	number)



is



cursor c1	is

select template_id

from msd_demand_plans

where	demand_plan_id = p_demand_plan_id;



cursor c2	is

select document_name,document_id

from msd_dp_seeded_documents

where	demand_plan_id = p_demand_plan_id;



cursor c3(p_template_id	in number, p_document_name in	varchar2)	is

select document_id

from msd_dp_seeded_documents

where	demand_plan_id = p_template_id

and	document_name	=	p_document_name;



cursor c4(p_document_id	in number) is

select dimension_code

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_demand_plan_id

and	document_id	=	p_document_id;



cursor c5(p_template_id	in number, p_document_id in	number,	p_dimension_code in	varchar2)	is

select selection_script

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_template_id

and	document_id	=	p_document_id

and	dimension_code = p_dimension_code;



l_document_id	number;

l_selection_script varchar2(4000);

l_template_id	number;

cursor watefall_document_id is
select document_id
from msd_dp_seeded_documents
where demand_plan_id=p_demand_plan_id
and document_name = 'MSD_SD_EOL_LWF';

waterfall_doc_id number;

Begin


	waterfall_doc_id := -1;

	open watefall_document_id;
	fetch watefall_document_id into waterfall_doc_id;
	close watefall_document_id;


	open c1;

	fetch	c1 into	l_template_id;

	close	c1;



	-- for each	seeded document	in the plan

	for	c2_cur in	c2 loop



		-- get the corresponding documents ID	from template

		open c3(l_template_id,c2_cur.document_name);

		fetch	c3 into	l_document_id;

		close	c3;



		-- for each	dimension	code in	seeded document	for	the	plan

		for	c4_cur in	c4(c2_cur.document_id) loop



			-- get the selection script	for	the	corresponding	dimension	in template

			open c5(l_template_id, l_document_id,	c4_cur.dimension_code);

			fetch	c5 into	l_selection_script;

			close	c5;



			-- update	the	selection	script for the dimension in	the	plan with	the	selection	script for the corresponding dimension in	template

			if c2_cur.document_id=waterfall_doc_id and  c4_cur.dimension_code = 'MEAS' then
					null;
			else

					update msd_dp_seeded_doc_dimensions
					set	selection_script = l_selection_script
					where	demand_plan_id = p_demand_plan_id
					and	document_id	=	c2_cur.document_id
					and	dimension_code = c4_cur.dimension_code;
			end if;


		end	loop;



	end	loop;



End	refresh_document_dimensions;



/*******************************************************

This Procedure refreshes the formula definitions for the plan	from the template.

This is	required to	get	the	original seeded	data and then	create the definitions again from	the	plan.

********************************************************/



Procedure	refresh_formulas(p_demand_plan_id	in number)



is



cursor c1	is

select template_id

from msd_demand_plans

where	demand_plan_id = p_demand_plan_id;



cursor c2	is

select formula_name,formula_id

from msd_dp_formulas

where	demand_plan_id = p_demand_plan_id;



cursor c3(p_template_id	in number, p_formula_name	in varchar2) is

select equation, custom_field1,	custom_field2, isby, numerator,	denominator

from msd_dp_formulas

where	demand_plan_id = p_template_id

and	formula_name = p_formula_name;



l_equation varchar2(4000);

l_custom_field1	varchar2(4000);

l_custom_field2	varchar2(4000);

l_isby varchar2(4000);

l_numerator	 varchar2(4000);

l_denominator	varchar2(4000);

l_template_id	number;

Begin



	open c1;

	fetch	c1 into	l_template_id;

	close	c1;



	-- for each	formula	in the plan

	for	c2_cur in	c2 loop



			-- get the equation, custom_field1,	isby,	numerator	and	denominator	for	the	corresponding	formula	in template

			open c3(l_template_id, c2_cur.formula_name);

			fetch	c3 into	l_equation,l_custom_field1,l_custom_field2,l_isby,l_numerator,l_denominator;

			close	c3;



			-- update	equation,	custom_field1, isby, numerator and denominator for the formula in	plan with	the	corresponding	formula	in template

			update msd_dp_formulas

			set	equation = l_equation,

			custom_field1	=	l_custom_field1,

			custom_field2	=	l_custom_field2,

			isby = l_isby,

			numerator	=	l_numerator,

			denominator	=	l_denominator

			where	demand_plan_id = p_demand_plan_id

			and	formula_name = c2_cur.formula_name;



	end	loop;



End	refresh_formulas;



/*******************************************************

This Procedure does	the	processing common	to all plan	types	after	the	plan is	copied from	the	template.

Called by	apply_template.

********************************************************/



Procedure	common_post_copy_process(p_new_dp_id in	number)

is



cursor c1	is

select scenario_id,	scenario_name, description

from msd_dp_scenarios_cs_v

where	demand_plan_id = p_new_dp_id;



BEGIN



-- Update	the	template_flag	and	default_template columns as	copy plan	sets these to	'Y'

		update msd_demand_plans

		set	template_flag	=	'N',

		default_template = 'N'

		where	demand_plan_id = p_new_dp_id;



-- Update	the	Name and Description of	Scenarios	as these are seeded	as messages

					for	c1_cur in	c1 loop



			fnd_message.set_name('MSD',c1_cur.scenario_name);



			update msd_dp_scenarios

			set	scenario_name	=	fnd_message.get

			where	demand_plan_id = p_new_dp_id

			and	scenario_id	=	c1_cur.scenario_id;



			fnd_message.set_name('MSD',c1_cur.description);



			update msd_dp_scenarios

			set	description	=	fnd_message.get

			where	demand_plan_id = p_new_dp_id

			and	scenario_id	=	c1_cur.scenario_id;



			fnd_message.set_name('MSD',c1_cur.description);



			update msd_dp_scenarios_tl

			set	description	=	fnd_message.get

			where	demand_plan_id = p_new_dp_id

			and	scenario_id	=	c1_cur.scenario_id;



		end	loop;



END	common_post_copy_process;


/*******************************************************

This Procedure does	the	processing specific	to plan	type 'EOL' and CALULATED type of parameters after the plan	is copied	from the template	and	common processing.

Called by	eol_post_copy_process.

********************************************************/

procedure replace_parameter_tokens(p_demand_plan_id number)
as

cursor c1 is
select parameter_id
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id
and stream_type='CALCULATED';

cursor c2(p_parameter_id number) is
select parameter_sequence,parameter_type,parameter_component,parameter_value,supply_plan_name
from msd_dp_formula_parameters
where demand_plan_id=p_demand_plan_id
and formula_id=p_parameter_id
order by parameter_sequence;

cursor c3(p_demand_plan_id number) is
select parameter_type,parameter_id
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id;

cursor c4(p_demand_plan_id number) is
select parameter_id
from msd_dp_parameters
where demand_plan_id=p_demand_plan_id
and post_calculation is not null;

l_parameter_value varchar2(4000);
begin

for c1_rec in c1
loop
		for c2_rec in c2(c1_rec.parameter_id)
		loop

			if c2_rec.parameter_type = 'I' then
				l_parameter_value	:= 'V.'||c2_rec.parameter_component||get_parameter_id(p_demand_plan_id,c2_rec.parameter_value,	c2_rec.supply_plan_name, c2_rec.parameter_component);
			else
				l_parameter_value	:= c2_rec.parameter_value;
			end	if;

		update msd_dp_parameters
		set equation = 	replace(equation,'%'||c2_rec.parameter_sequence||'%', l_parameter_value)
		where	demand_plan_id = p_demand_plan_id
		and	parameter_id = c1_rec.parameter_id;

		end loop;
end loop;

for c3_rec in c3(p_demand_plan_id)
loop
		for c4_rec in c4(p_demand_plan_id)
		loop
				update msd_dp_parameters
				set post_calculation=replace(post_calculation,c3_rec.parameter_type,c3_rec.parameter_id)
				where demand_plan_id=p_demand_plan_id
				and parameter_id=c4_rec.parameter_id;
		end loop;
end loop;

exception
				when others then
				null;

end replace_parameter_tokens;


/*******************************************************

This Procedure does	the	processing specific	to plan	type 'EOL' after the plan	is copied	from the template	and	common processing.

Called by	apply_template.

********************************************************/



Procedure	update_parameter_dates(p_demand_plan_id number)
is

cursor c1 is
select plan_type
from msd_demand_plans
where demand_plan_id=p_demand_plan_id;

p_plan_type varchar2(10);

begin
		open c1;
		fetch c1 into p_plan_type;
		close c1;

		if p_plan_type = 'EOL' then

				update msd_dp_parameters
				set start_date=msd_common_utilities.get_bucket_start_date(sysdate,1,6,'GREGORIAN'),
				end_date=msd_common_utilities.get_bucket_end_date(sysdate,1,6,'GREGORIAN')
				where parameter_type in ('MSD_ON_HAND')
				and demand_plan_id=p_demand_plan_id;

				update msd_dp_parameters
				set start_date=msd_common_utilities.get_bucket_start_date(sysdate,1,6,'GREGORIAN'),
				end_date=msd_common_utilities.get_bucket_end_date(sysdate,24,6,'GREGORIAN')
				where parameter_type in ('MSD_GROSS_REQ_EXCESS_HORIZON','MSD_INTRANSIT','MSD_ONORDER',
														'MSD_GROSS_REQ_OBS_DATE','MSD_TOTAL_SUPPLY','MSD_ORDER_FORECAST',
														'MSD_FORECAST_BASIS_LIAB','MSD_AUTHORIZATION','MSD_SUPPLY_COMMIT',
														'MSD_SHORTAGE','MSD_FORECAST_LIABILITY','MSD_ESTIMATED_FORECAST_LIAB',
														'MSD_SIM_END_ITEM_DEMAND','MSD_ESTIMATED_GROSS_REQ')
				and demand_plan_id=p_demand_plan_id;


		end if;

end update_parameter_dates;

/*******************************************************

This Procedure does	the	processing specific	to plan	type 'EOL' after the plan	is copied	from the template	and	common processing.

Called by	apply_template.

********************************************************/



Procedure	eol_post_copy_process(p_new_dp_id	in number)

is



cursor c1	is

select plan_type

from msd_demand_plans

where	demand_plan_id = p_new_dp_id;



l_plan_type	varchar2(80);





BEGIN



	-- get the plan	type

	open c1;

	fetch	c1 into	l_plan_type;

	close	c1;



	if l_plan_type = 'EOL' then

			-- insert	ASCP specific	data
			update_ascp_related_data(p_new_dp_id);

			-- Replace associate parameetr types with id's
			replace_associate_parameters(p_new_dp_id);

			-- Replace calculated parameetr equation tokens
			replace_parameter_tokens(p_new_dp_id);

			-- Update the start and end dates for the parameters
			update_parameter_dates(p_new_dp_id);
			/*      Bug 	5169157 */
			/*update msd_dp_parameters set allo_agg_basis_stream_id = (select parameter_id
																															 from msd_dp_parameters
																															 where demand_plan_id=p_new_dp_id
																															 and parameter_type='MSD_FORECAST_BASIS_LIAB')
			where demand_plan_id=p_new_dp_id
			and parameter_type='MSD_SIM_END_ITEM_DEMAND';			*/

			fnd_message.set_name('MSD','MSD_SIM_DEMAND_DEP_DEM_DESC');
			update msd_dp_parameters
			set dependent_demand_desc = fnd_message.get
			where demand_plan_id=p_new_dp_id
			and parameter_type='MSD_SIM_END_ITEM_DEMAND';

	end	if;



END	eol_post_copy_process;

/*******************************************************

This Procedure does	the	processing specific	to plan	type 'EOL' after the plan	is copied	from the template	and	common processing.

********************************************************/

Procedure	replace_associate_parameters(p_new_dp_id	in number)
is
cursor c1(p_parameter_type varchar2) is
select parameter_id
from msd_dp_parameters
where demand_plan_id=p_new_dp_id
and parameter_type=p_parameter_type;

cursor c2 is
select scenario_id
from msd_dp_scenarios
where demand_plan_id=p_new_dp_id;

cursor c3(p_scenario_id number) is
select associate_parameter
from msd_dp_scenarios
where demand_plan_id=p_new_dp_id
and scenario_id=p_scenario_id;


p_associate_parameter varchar2(200);
p_parameter_id number;

sql_stmt varchar2(1000);

begin

	for c2_rec in c2
	loop

		open c3(c2_rec.scenario_id);
		fetch c3 into p_associate_parameter;
		close c3;

		open c1(p_associate_parameter);
		fetch c1 into p_parameter_id;
		close c1;

		update msd_dp_scenarios
		set associate_parameter=p_parameter_id
		where demand_plan_id=p_new_dp_id
		and scenario_id=c2_rec.scenario_id;


	end loop;



END replace_associate_parameters;

/*******************************************************

This Procedure does	the	processing specific	to plan	type 'SOP' after the plan	is copied	from the template	and	common processing.

Called by	apply_template.

********************************************************/



Procedure	sop_post_copy_process(p_new_dp_id	in number)

is



cursor c1	is

select plan_type

from msd_demand_plans

where	demand_plan_id = p_new_dp_id;



l_plan_type	varchar2(80);





BEGIN



	-- get the plan	type

	open c1;

	fetch	c1 into	l_plan_type;

	close	c1;



	if l_plan_type = 'SOP' then





	-- set the start and end dates of	input	parameters to	month	start	date of	18 months	backwards	and	current	month	end	date respectively

	update msd_dp_parameters

	set	start_date = msd_common_utilities.get_bucket_start_date(sysdate,-18,6,'GREGORIAN'),

	end_date = msd_common_utilities.get_bucket_end_date(sysdate,1,6,'GREGORIAN')

	where	demand_plan_id = p_new_dp_id

	and	(supply_plan_flag	<> 'Y'

	or supply_plan_flag	is null);



	-- set the history start and end dates of	scenarios	to month start date	of 18	months backwards	and	current	month	end	date respectively

	-- set the horizon start and end dates of	scenarios	to month start date	of next	month	 and end date	of 19	months forwards	 respectively

	update msd_dp_scenarios

	set	history_start_date = msd_common_utilities.get_bucket_start_date(sysdate,-18,6,'GREGORIAN'),

	history_end_date = msd_common_utilities.get_bucket_end_date(sysdate,1,6,'GREGORIAN'),

	horizon_start_date = msd_common_utilities.get_bucket_start_date(sysdate,2,6,'GREGORIAN'),

	horizon_end_date = msd_common_utilities.get_bucket_end_date(sysdate,19,6,'GREGORIAN')

	where	demand_plan_id = p_new_dp_id;



	-- insert	ASCP specific	data

	update_ascp_related_data(p_new_dp_id);



	end	if;



END	sop_post_copy_process;



/*******************************************************

This Procedure does	the	processing specific	to plan	type 'LIABILITY' after the plan	is copied	from the template	and	common processing.

Called by	apply_template.

********************************************************/



Procedure	liab_post_copy_process(p_new_dp_id in	number)

is



cursor c1	is

select liab_plan_name, plan_type,	organization_id, sr_instance_id

from msd_demand_plans

where	demand_plan_id = p_new_dp_id;





l_supply_plan_name varchar2(240);

l_plan_type	varchar2(80);

l_org_id number;

l_instance_id	number;





BEGIN



	open c1;

	fetch	c1 into	l_supply_plan_name,	l_plan_type, l_org_id, l_instance_id;

	close	c1;



	if l_plan_type = 'LIABILITY' then





		 --	insert default manufacturing calendar	for	PDS	base liability plans

	if l_org_id	<> -1	then



	insert into	msd_dp_calendars

	(

	DEMAND_PLAN_ID

	,CALENDAR_TYPE

	,CALENDAR_CODE

	,CREATION_DATE

	,CREATED_BY

	,LAST_UPDATE_DATE

	,LAST_UPDATED_BY

	,LAST_UPDATE_LOGIN

	,REQUEST_ID

	,PROGRAM_APPLICATION_ID

	,PROGRAM_ID

	,PROGRAM_UPDATE_DATE

	,DELETEABLE_FLAG

	,ENABLE_NONSEED_FLAG

	)

	values

	(

	p_new_dp_id

	,2

	,MSD_COMMON_UTILITIES_LB.get_default_mfg_cal ( l_org_id,l_instance_id)

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	,null

	,'Y'

	);



	-- set min time	level	for	manufacturing	calendar to	Manufacturing	Week

	update msd_demand_plans

	set	m_min_tim_lvl_id = 1

	where	demand_plan_id = p_new_dp_id;



	end	if;



	end	if;

END	liab_post_copy_process;



/*******************************************************

This Procedure does	the	processing common	to all plan	types	after	the	plan is	copied from	the	template and plan	type specific	processing.

Called by	apply_template.

Calls	Update_Formula_Names.

********************************************************/



Procedure	common_all_post_process(p_new_dp_id	in number)

is



cursor c2	is

select parameter_id, price_list_name

from msd_dp_parameters

where	demand_plan_id = p_new_dp_id

and	price_list_name	is not null;



cursor c3	is

select scenario_id,	price_list_name

from msd_dp_scenarios

where	demand_plan_id = p_new_dp_id

and	price_list_name	is not null;



cursor c4	is

select dp_price_list_id, price_list_name

from msd_dp_price_lists

where	demand_plan_id = p_new_dp_id;



BEGIN



 --	for	all	input	parameters with	price	list name	specified

	for	c2_cur in	c2 loop



		-- replace message with	text

		update msd_dp_parameters

		set	price_list_name	=	fnd_message.get_string('MSD',c2_cur.price_list_name)

		where	demand_plan_id = p_new_dp_id

		and	parameter_id = c2_cur.parameter_id;



	end	loop;



	-- for all scenarios with	price	list name	specified

	for	c3_cur in	c3 loop



		-- replace message with	text

		update msd_dp_scenarios

		set	price_list_name	=	fnd_message.get_string('MSD',c3_cur.price_list_name)

		where	demand_plan_id = p_new_dp_id

		and	scenario_id	=	c3_cur.scenario_id;



	end	loop;



	-- for all price list	name specified

	for	c4_cur in	c4 loop



		-- replace message with	text

		update msd_dp_price_lists

		set	price_list_name	=	fnd_message.get_string('MSD',c4_cur.price_list_name)

		where	demand_plan_id = p_new_dp_id

		and	dp_price_list_id = c4_cur.dp_price_list_id;



	end	loop;



	if not g_call	then

		-- Relace	messages with	text

		Update_Formula_Names(p_new_dp_id);

 end if;



END	common_all_post_process;



/*******************************************************

This Procedure replaces	the	descriptions of	Formula	Names	seeded as	messsages	with message text.

Called by	common_all_post_process.

********************************************************/



Procedure	Update_Formula_Names(p_new_dp_id in	number)

is



cursor c1	is

select formula_name, formula_desc, formula_id

from msd_dp_formulas

where	demand_plan_id = p_new_dp_id

order	by creation_sequence;



cursor c2	is

select document_id,	description

from msd_dp_seeded_documents

where	demand_plan_id = p_new_dp_id;



BEGIN



	-- for each	formula	for	the	given	plan

	for	c1_cur in	c1 loop



		--fnd_message.set_name('MSD',c1_cur.formula_desc);



		-- update	the	description	seeded as	message	with message text

		update msd_dp_formulas

		--set	formula_desc = fnd_message.get

		set	formula_desc = fnd_message.get_string('MSD',c1_cur.formula_desc)

		where	formula_id = c1_cur.formula_id

		and	demand_plan_id = p_new_dp_id;



	end	loop;



	for	c2_cur in	c2 loop



		--fnd_message.set_name('MSD',c2_cur.description);



		-- update	the	description	seeded as	message	with message text

		update msd_dp_seeded_documents

		--set	description	=	fnd_message.get

		set	description	=	fnd_message.get_string('MSD',c2_cur.description)

		where	document_id	=	c2_cur.document_id

		and	demand_plan_id = p_new_dp_id;



	end	loop;



	g_call :=	TRUE;



END	Update_Formula_Names;



/*******************************************************

This Procedure replaces	the	tokens in	formula	fields like	equation,	custom_field1	etc	with values	stored in	formula	parameters.

Called by	create_seeded_definitions.

********************************************************/



Procedure	Replace_formula_tokens(p_new_dp_id in	number)

is



cursor c1	is

select formula_id

from msd_dp_formulas

where	demand_plan_id = p_new_dp_id

order	by creation_sequence;



cursor c2(p_formula_id in	number)	is

select where_used, parameter_sequence, parameter_type, parameter_component,	parameter_value, supply_plan_name

from msd_dp_formula_parameters

where	demand_plan_id = p_new_dp_id

and	formula_id = p_formula_id

and	enabled_flag = 'Y'

order	by parameter_sequence;



l_parameter_value	varchar2(4000);



BEGIN





	-- for each	formula	for	the	given	plan

	for	c1_cur in	c1 loop



		-- for each	generic	parameter	of the formula

		for	c2_cur in	c2(c1_cur.formula_id)	loop



			-- prefix	 V.Q.	to the parameter value if	type is	input	parameter	to the parameter ID

			if c2_cur.parameter_type = 'I' then

				l_parameter_value	:= 'V.'||c2_cur.parameter_component||get_parameter_id(p_new_dp_id,c2_cur.parameter_value,	c2_cur.supply_plan_name, c2_cur.parameter_component);

			-- prefix	 SYSF	to the parameter value if	type is	formula	to the formula ID

			elsif	c2_cur.parameter_type	=	'F'	then

				l_parameter_value	:= 'SYSF'||get_formula_id(p_new_dp_id,c2_cur.parameter_value,	c2_cur.supply_plan_name);

			else

				l_parameter_value	:= c2_cur.parameter_value;

			end	if;



			-- update	the	names	with IDS

			update msd_dp_formulas

			set	custom_field1	=	replace(custom_field1,'%'||c2_cur.parameter_sequence||'%', l_parameter_value),

			custom_field2	=	replace(custom_field2,'%'||c2_cur.parameter_sequence||'%', l_parameter_value),

			equation = replace(equation,'%'||c2_cur.parameter_sequence||'%', l_parameter_value)

			where	demand_plan_id = p_new_dp_id

			and	formula_id = c1_cur.formula_id;



		end	loop;





	end	loop;





END	Replace_formula_tokens;





/*******************************************************

This Procedure parses	the	select list	for	dimensions with	selection	type as	List.	e.g. measures	.

The	list contains	values seperated by	'\n'

Called by	create_seeded_definitions

NO MORE	USED

********************************************************/



Procedure	Parse_Dimension_Select_List(p_new_dp_id	in number)

is



cursor c1	is

select document_id,	dimension_code,	selection_sequence

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	(dimension_code, document_id)	in

(select	dimension_code,	document_id	from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_new_dp_id

and	selection_type = 'L')

order	by document_id,dimension_code,selection_sequence;





BEGIN







		update msd_dp_seeded_doc_dimensions

		set	selection_script = ''

		where	demand_plan_id = p_new_dp_id

		and	selection_type = 'L';



	for	c1_cur in	c1 loop



		update msd_dp_seeded_doc_dimensions

		set	selection_script = selection_script||'%'||c1_cur.selection_sequence||'%\n'

		where	demand_plan_id = p_new_dp_id

		and	document_id	=	c1_cur.document_id

		and	dimension_code = c1_cur.dimension_code

		and	selection_type = 'L';



	end	loop;



exception

	when others	then

		null;



END	Parse_Dimension_Select_List;



/*******************************************************

This Procedure replaces	the	tokens in	selection	script with	values of	document selections.

Called by	create_seeded_definitions.

********************************************************/



Procedure	Replace_dimension_tokens(p_new_dp_id in	number)

is



cursor c1	is

select document_id,	dimension_code

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_new_dp_id

order	by sequence_number;



cursor c2(p_document_id	in number,p_dimension_code in	varchar2)	is

select selection_sequence, selection_type, selection_component,	selection_value, supply_plan_name

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	document_id	=	p_document_id

and	dimension_code = p_dimension_code

and	enabled_flag = 'Y'

order	by selection_sequence;



l_selection_value	varchar2(4000);



l_parameter_id number;

l_formula_id number;

l_hierarchy_id number;

l_level_id number;

l_dimension_code varchar2(4);

l_dimension_script varchar2(100);





BEGIN





	for	c1_cur in	c1 loop



		for	c2_cur in	c2(c1_cur.document_id, c1_cur.dimension_code)	loop

			if c2_cur.selection_type = 'I' then

				l_parameter_id :=	get_parameter_id(p_new_dp_id,c2_cur.selection_value, c2_cur.supply_plan_name,	c2_cur.selection_component);

				if l_parameter_id	is not null	then

					l_selection_value	:= 'V.'||c2_cur.selection_component||l_parameter_id;

				else

					l_selection_value	:= null;

				end	if;

			elsif	c2_cur.selection_type	=	'F'	then

				l_formula_id :=	get_formula_id(p_new_dp_id,c2_cur.selection_value, c2_cur.supply_plan_name);

				if l_formula_id	is not null	then

					l_selection_value	:= 'SYSF'||l_formula_id;

				else

					l_selection_value	:= null;

				end	if;

			elsif	c2_cur.selection_type	=	'H'	then

				l_hierarchy_id :=	get_hierarchy_id(p_new_dp_id,c2_cur.selection_value);

				if l_hierarchy_id	is not null	then

					l_selection_value	:= 'H'||c2_cur.selection_value;

				else

					l_selection_value	:= null;

				end	if;

			elsif	c2_cur.selection_type	=	'L'	then

				l_level_id :=	get_level_id(p_new_dp_id,c2_cur.selection_value);

				if l_level_id	is not null	then

					l_selection_value	:= 'L'||c2_cur.selection_value;

				else

					l_selection_value	:= null;

				end	if;

			elsif	c2_cur.selection_type	=	'D'	then

				l_dimension_code :=	get_dimension_code(p_new_dp_id,c2_cur.selection_value);

				l_selection_value	:= l_dimension_code;

			elsif	c2_cur.selection_type	=	'DS' then

				l_dimension_script :=	get_dimension_script(p_new_dp_id,c2_cur.selection_component, c2_cur.selection_value);

				l_selection_value	:= l_dimension_script;

			else

				l_selection_value	:= c2_cur.selection_value;

			end	if;



			update msd_dp_seeded_doc_dimensions

			set	selection_script = replace(selection_script,'%'||c2_cur.selection_sequence||'%', l_selection_value)

			where	demand_plan_id = p_new_dp_id

			and	document_id	=	c1_cur.document_id

			and	dimension_code = c1_cur.dimension_code;



		end	loop;

		/*update msd_dp_seeded_doc_dimensions
		set enabled_flag = decode(nvl(selection_script,'NOT_POSS'), 'NOT_POSS', 'N', enabled_flag)
		where document_id	=	c1_cur.document_id
  	and	dimension_code = c1_cur.dimension_code
  	and demand_plan_id=p_new_dp_id
  	and dimension_code = 'MEAS';*/


	end	loop;



END	Replace_dimension_tokens;



/*******************************************************

This Procedure adds	the	ASCP specific	scenario,	input	parameters,	formulas and adds	more measures	to seeded	docs.

Called by	sop_post_copy_process, eol_post_copy_process.

Calls	add_ascp_scenario, add_ascp_input_parameter, add_ascp_formula	and	add_ascp_measure.

********************************************************/



Procedure	update_ascp_related_data(p_new_dp_id in	number)

is



cursor c1	is

select demand_plan_name

from msd_demand_plans

where	demand_plan_id = p_new_dp_id;



cursor c2(p_demand_plan_name in	varchar2)	is

select distinct	supply_plan_id,	supply_plan_name									-- Bug 4729854

from msd_dp_supply_plans

where	demand_plan_name	=	p_demand_plan_name;



cursor c3(p_demand_plan_name in	varchar2)	is

select count(*)

from msd_dp_supply_plans

where	demand_plan_name	=	p_demand_plan_name;



l_demand_plan_name varchar2(200);

l_count	number;


cursor get_plan_type is
select plan_type
from msd_demand_plans
where demand_plan_id=p_new_dp_id;

p_plan_type varchar2(10);

l_liab_plan_id number;

BEGIN



l_count	:= 0;

	-- get the plan type for the plan

	open get_plan_type;
	fetch get_plan_type into p_plan_type;
	close get_plan_type;

	-- get the name	of the plan	for	the	given	ID

	open c1;

		fetch	c1 into	l_demand_plan_name;

	close	c1;

	if p_plan_type='EOL' then
			select max(supply_plan_id) into l_liab_plan_id from msd_dp_supply_plans where demand_plan_name	=	l_demand_plan_name;
			update msd_demand_plans set liab_plan_id=l_liab_plan_id where demand_plan_id=p_new_dp_id;
	end if;

	-- for each	suuply plan	selected in	Template window

	for	c2_cur in	c2(l_demand_plan_name) loop



		if p_plan_type='EOL' then
				add_ascp_scenario_for_eol(p_new_dp_id, c2_cur.supply_plan_id,	c2_cur.supply_plan_name);
		else
				add_ascp_scenario(p_new_dp_id, c2_cur.supply_plan_id,	c2_cur.supply_plan_name);		-- Bug 4729854
		end if;


		add_ascp_input_parameter(p_new_dp_id,	c2_cur.supply_plan_id, c2_cur.supply_plan_name);	 --	Bug	4729854



		add_ascp_formula(p_new_dp_id,	c2_cur.supply_plan_id, c2_cur.supply_plan_name);				-- Bug 4729854



		add_ascp_measure(p_new_dp_id,	c2_cur.supply_plan_id, c2_cur.supply_plan_name);				 --	Bug	4729854



	end	loop;



	open c3(l_demand_plan_name);

		fetch	c3 into	l_count;

	close	c3;



	if l_count = 0 then



		add_ascp_scenario(p_new_dp_id, null,null);



	end	if;



		-- delete	data as	not	required after this

		delete from	msd_dp_supply_plans

		where	demand_plan_name = l_demand_plan_name;



 EXCEPTION



				WHEN OTHERS	THEN

					null;



END	update_ascp_related_data;



/*******************************************************

This Procedure checks	if any of	mandatory	parameters for the formulas	is disabled	and	validates	the	formulas.

Called by	create_seeded_definitions.

For	Future Use

********************************************************/



Procedure	Validate_formula_parameters(p_new_dp_id	in number)

is



BEGIN

	null;

END	Validate_formula_parameters;





Procedure	validate_formulas(p_new_dp_id	in number)

is



cursor c1	is

select distinct	formula_id

from msd_dp_formula_parameters

where	demand_plan_id = p_new_dp_id

and	mandatory_flag = 'Y'

and	enabled_flag = 'N';



BEGIN



		-- Set all formulas	to valid first

		update msd_dp_formulas

		set	valid_flag = 'Y'

		where	demand_plan_id = p_new_dp_id;



	-- invalidate	the	formula	if any of	the	mandatory	parameter	is disabled

	for	c1_cur in	c1 loop

		update msd_dp_formulas

		set	valid_flag = 'N'

		where	demand_plan_id = p_new_dp_id

		and	formula_id = c1_cur.formula_id;

	end	loop;



END	validate_formulas;



Procedure	validate_doc_dim_selections(p_new_dp_id	in number)

is



cursor c1	is

select plan_type

from msd_demand_plans

where	demand_plan_id = p_new_dp_id;



cursor c2	is

select distinct	selection_value, dimension_code

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	selection_type = 'L';



cursor c3	is

select distinct	selection_value, dimension_code

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	selection_type = 'H';



cursor c4(p_plan_type	in varchar2, p_dimension_code	in varchar2) is

select level_id

from msd_dp_scenario_output_levels

where	demand_plan_id = p_new_dp_id

and	level_id in

(select	level_id from	msd_levels

where	dimension_code = p_dimension_code

and	nvl(plan_type,'DP')	=	decode(p_plan_type,null,'DP','SOP','DP','EOL','DP',p_plan_type))

and	rownum < 2;



cursor c5(p_plan_type	in varchar2, p_dimension_code	in varchar2) is

select hierarchy_id

from msd_dp_hierarchies

where	demand_plan_id = p_new_dp_id

and	hierarchy_id in

(select	hierarchy_id from	msd_hierarchies

where	dimension_code = p_dimension_code

and	nvl(plan_type,'DP')	=	decode(p_plan_type,null,'DP','SOP','DP','EOL','DP',p_plan_type))

and	rownum < 2;



l_count	number;

l_level_id number;

l_plan_type	varchar2(240);

l_hierarchy_id number;



BEGIN



	-- get the plan	type

	open c1;

	fetch	c1 into	l_plan_type;

	close	c1;



	-- For all levels	in seeded	docs

	for	c2_cur in	c2 loop



		-- check if	the	seeded level exists	or has been	removed

		select count(*)	into l_count

		from msd_levels

		where	level_id = c2_cur.selection_value

		and	nvl(plan_type,'DP')	=	decode(l_plan_type,null,'DP','SOP','DP','EOL','DP',l_plan_type);



		-- if	removed	then

		if l_count = 0 then



			-- get any other level in	plan that	exists

			open c4(l_plan_type, c2_cur.dimension_code);



	fetch	c4 into	l_level_id;



				-- if	no such	level	then

				if c4%notfound then



					-- disable the selection

		update msd_dp_doc_dim_selections

					set	enabled_flag = 'N'

		where	demand_plan_id = p_new_dp_id

		and	selection_type = 'L'

		and	selection_value	=	c2_cur.selection_value

		and	dimension_code =	c2_cur.dimension_code;



	else



					-- change	the	level

		update msd_dp_doc_dim_selections

					set	selection_value	=	l_level_id

		where	demand_plan_id = p_new_dp_id

		and	selection_type = 'L'

		and	selection_value	=	c2_cur.selection_value

			and	dimension_code =	c2_cur.dimension_code;



	end	if;



			close	c4;



		end	if;



	end	loop;



	-- For all hierarchies in	seeded docs

	for	c3_cur in	c3 loop



		-- check if	the	seeded hierarchy exists	or has been	removed

		select count(*)	into l_count

		from msd_hierarchies

		where	hierarchy_id = c3_cur.selection_value

		and	nvl(plan_type,'DP')	=	decode(l_plan_type,null,'DP','SOP','DP','EOL','DP',l_plan_type);



		-- if	removed	then

		if l_count = 0 then



			-- get any other hierarachy	in plan	that exists

			open c5(l_plan_type, c3_cur.dimension_code);



	fetch	c5 into	l_hierarchy_id;



				-- if	no such	hierarchy	then

				if c5%notfound then



					-- disable the selection

		update msd_dp_doc_dim_selections

					set	enabled_flag = 'N'

		where	demand_plan_id = p_new_dp_id

		and	selection_type = 'H'

		and	selection_value	=	c3_cur.selection_value

		and	dimension_code =	c3_cur.dimension_code;



	else



					-- change	the	hierarchy

		update msd_dp_doc_dim_selections

					set	selection_value	=	l_hierarchy_id

		where	demand_plan_id = p_new_dp_id

		and	selection_type = 'H'

		and	selection_value	=	c3_cur.selection_value

		and	dimension_code =	c3_cur.dimension_code;



	end	if;



			close	c5;



		end	if;



	end	loop;





END	validate_doc_dim_selections;



/*******************************************************

This Procedure checks	if any of	mandatory	selections for the dimension is	disabled and enables the dimensions.

Called by	create_seeded_definitions.

********************************************************/



Procedure	validate_doc_dimensions(p_new_dp_id	in number)

is



cursor c1	is

select distinct	document_id, dimension_code

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	mandatory_flag = 'Y'

and	enabled_flag = 'N'

and	dimension_code <>	'MEAS'

order	by document_id,	dimension_code;



cursor c2	is

select distinct	document_id
from msd_dp_doc_dim_selections mdds,
msd_dp_parameters mdp
where	mdds.demand_plan_id = p_new_dp_id
and mdp.demand_plan_id=p_new_dp_id
and mdp.parameter_type=mdds.selection_value
and nvl(mdp.parameter_name,'ABCD')=nvl(mdds.supply_plan_name,'ABCD')
and	dimension_code = 'MEAS';



BEGIN



		-- enable	all	dimensions except	measures first

		update msd_dp_seeded_doc_dimensions

		set	enabled_flag = 'Y'

		where	(document_id,	dimension_code)

		in

		/*------Fix	for	bug	4550732--------*/

		(select	document_id, dimension_code	from msd_dp_doc_dim_selections where demand_plan_id=p_new_dp_id)

		and	dimension_code <>	'MEAS';



		/* Bug 4288109 */

		-- disable all dimensions	measures

		update msd_dp_seeded_doc_dimensions	dpdim

		set	enabled_flag = decode(dpdim.selection_type,	'S', 'Y',	'N')

		where	demand_plan_id = p_new_dp_id

		and	dimension_code = 'MEAS'
		and document_id <> (select document_id from msd_dp_seeded_documents where demand_plan_id=p_new_dp_id and
																								document_name='MSD_EOL_WHEREUSED_RE');



	for	c1_cur in	c1 loop



		-- disable dimensions	except measure which have	any	of the mandatory selection disabled

		update msd_dp_seeded_doc_dimensions

		set	enabled_flag = 'N'

		where	demand_plan_id = p_new_dp_id

		and	document_id	=	c1_cur.document_id

		and	dimension_code = c1_cur.dimension_code;



	end	loop;



	for	c2_cur in	c2 loop



		-- enable	measure	dimension	if one of	the	measures is	enabled

		update msd_dp_seeded_doc_dimensions

		set	enabled_flag = 'Y'

		where	demand_plan_id = p_new_dp_id

		and	document_id	=	c2_cur.document_id

		and	dimension_code = 'MEAS';



	end	loop;


END	validate_doc_dimensions;



/*******************************************************

This Procedure checks	if any of	mandatory	dimensions for the document	is disabled	and	validates	the	documents.

Called by	create_seeded_definitions.

********************************************************/



Procedure	validate_documents(p_new_dp_id in	number)

is



cursor c1	is

select distinct	document_id

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_new_dp_id

and	mandatory_flag = 'Y'

and	enabled_flag = 'N';



BEGIN



		-- validate	all	documents	first

		update msd_dp_seeded_documents

		set	valid_flag = 'Y'

		where	demand_plan_id = p_new_dp_id;



	for	c1_cur in	c1 loop



		 --	invalidate documents if	any	of the mandatory dimension is	disabled

		update msd_dp_seeded_documents

		set	valid_flag = 'N'

		where	demand_plan_id = p_new_dp_id

		and	document_id	=	c1_cur.document_id;



	end	loop;



END	validate_documents;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	dimension.

Called from	form whenever	user deletes a dimension.

********************************************************/



procedure	remove_dimension(

p_demand_plan_id in	number,

p_dimension_code in	varchar2,

p_dp_dimension_code	in varchar2)



is



BEGIN

savepoint	sp;



	-- disable the dimension

	update msd_dp_seeded_doc_dimensions

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	dimension_code = p_dp_dimension_code;



	-- disable all dimension selections	which	use	related	hierarchies	and	levels

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	((selection_type = 'H'

	and	selection_value	in

	(select	distinct hierarchy_id	from msd_hierarchies

	where	dimension_code = p_dp_dimension_code))

	or (selection_type = 'L'

	and	selection_value	in

	(select	distinct level_id	from msd_levels

	where	dimension_code = p_dp_dimension_code)));



	-- disable formula_parameters

	update msd_dp_formula_parameters

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	parameter_type = 'D'

	and	parameter_value	=	p_dp_dimension_code;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	remove_dimension;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	parameter.

Called from	form whenever	user deletes an	input	parameter.

********************************************************/



procedure	remove_parameter(

p_demand_plan_id in	number,

p_parameter_id in	number)



is



cursor c1	is

select parameter_type, parameter_name

from msd_dp_parameters

where	demand_plan_id = p_demand_plan_id

and	parameter_id = p_parameter_id;



l_parameter_type varchar2(240);

l_parameter_name varchar2(240);



BEGIN

savepoint	sp;





	-- disable doc dim selections

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	selection_value	=	l_parameter_type

	and	nvl(supply_plan_name,'~!#$%^&*') = nvl(l_parameter_name,'~!#$%^&*')

	and	selection_type = 'I';



	-- disable formula parameters

	update msd_dp_formula_parameters

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	parameter_type = 'I'

	and	nvl(supply_plan_name,'~!#$%^&*') = nvl(l_parameter_name,'~!#$%^&*')

	and	parameter_value	=	l_parameter_type;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	remove_parameter;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario.

Called from	form whenever	user deletes a scenario.

FOR	FUTURE USE

********************************************************/



procedure	remove_scenario(

p_demand_plan_id in	number,

p_scenario_id	in number)



is



cursor c1	is

select supply_plan_name, forecast_based_on,	parameter_name

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	scenario_id	=	p_scenario_id;



l_supply_plan_name varchar2(80);

l_forecast_based_on	varchar2(80);

l_parameter_name varchar2(80);



BEGIN

savepoint	sp;





	open c1;

	fetch	c1 into	l_supply_plan_name,	l_forecast_based_on, l_parameter_name;

	close	c1;



	update msd_dp_formula_parameters

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	parameter_component	=	'SN'

	and	parameter_value	=	l_forecast_based_on

	and	nvl(supply_plan_name,'123456789')	=	nvl(l_parameter_name,'123456789');



	update msd_dp_doc_dim_selections

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	selection_component	=	'SN'

	and	selection_value	=	l_forecast_based_on

	and	nvl(supply_plan_name,'123456789')	=	nvl(l_parameter_name,'123456789');



	if l_supply_plan_name	is not null	then



		delete from	msd_dp_parameters

		where	demand_plan_id = p_demand_plan_id

		and	parameter_name = l_supply_plan_name;



	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	remove_scenario;



procedure	remove_scenario_event(

p_demand_plan_id in	number,

p_scenario_id	in number,

p_event_id in	number)



is

BEGIN

	null;

END	remove_scenario_event;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario output	level.

Called from	form whenever	user deletes a scenario	output level.

********************************************************/



procedure	remove_scenario_output_lvl(

p_demand_plan_id in	number,

p_scenario_id	in number,

p_level_id in	number)



is



cursor c1	is

select enable_nonseed_flag

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	scenario_id	=	p_scenario_id;



l_nonseed_flag varchar2(15);



BEGIN

savepoint	sp;



	open c1;

	fetch	c1 into	l_nonseed_flag;

	close	c1;



	-- do	only for seeded	scenarios

	if l_nonseed_flag	is null	or l_nonseed_flag	<> 'Y' then



	-- disable doc dim selections

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'L'

	and	selection_value	=	p_level_id

	and	enabled_flag = 'Y';



	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	remove_scenario_output_lvl;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario event.

Called from	form whenever	user deletes a scenario	event.

FOR	FUTURE USE

********************************************************/



procedure	remove_event(

p_demand_plan_id in	number,

p_dp_event_id	in number)



is

BEGIN

	null;

END	remove_event;





procedure	remove_price_list(

p_demand_plan_id in	number,

p_dp_price_list_id in	number)



is

BEGIN

	null;

END	remove_price_list;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	calendar.

Called from	form whenever	user deletes a calendar.

FOR	FUTURE USE

********************************************************/



procedure	remove_calendar(

p_demand_plan_id in	number,

p_calendar_type	in varchar2,

p_calendar_code	in varchar2)



is



BEGIN

	null;

END	remove_calendar;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	hierarchy.

Called from	form whenever	user deletes a hierarchy.

********************************************************/



procedure	remove_hierarchy(

p_demand_plan_id in	number,

p_dp_dimension_code	in varchar2,

p_hierarchy_id in	number)

is

BEGIN

savepoint	sp;



	-- disable doc dim selections

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'H'

	and	selection_value	=	p_hierarchy_id;



	-- disable formula parameters

	update msd_dp_formula_parameters

	set	enabled_flag = 'N'

	where	demand_plan_id = p_demand_plan_id

	and	parameter_type = 'H'

	and	parameter_value	=	p_hierarchy_id;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	remove_hierarchy;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	dimension.

Called from	form whenever	user adds	a	dimension.

********************************************************/



procedure	add_dimension(

p_demand_plan_id in	number,

p_dimension_code in	varchar2,

p_dp_dimension_code	in varchar2)

is



BEGIN

savepoint	sp;



	-- enable	dimensions

	update msd_dp_seeded_doc_dimensions

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_Demand_plan_id

	and	dimension_code = p_dp_dimension_code

	and	enabled_flag = 'N';



	-- enable	document selections	that use related hierarchies and levels

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_Demand_plan_id

	and	((selection_type = 'H'

	and	selection_value	in

	(select	distinct hierarchy_id	from msd_hierarchies

	where	dimension_code = p_dp_dimension_code))

	or (selection_type = 'L'

	and	selection_value	in

	(select	distinct level_id	from msd_levels

	where	dimension_code = p_dp_dimension_code)));



	-- enable	formula	paraneters

	update msd_dp_formula_parameters

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_Demand_plan_id

	and	parameter_type = 'D'

	and	parameter_value	=	p_dp_dimension_code

	and	enabled_flag = 'N';



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	add_dimension;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	parameter.

Called from	form whenever	user adds	an input parameter.

********************************************************/



procedure	add_parameter(p_demand_plan_id in	number,

p_parameter_type in	varchar2,

p_parameter_name in	varchar2)



is

BEGIN

savepoint	sp;



	-- enable	doc	dim	selections

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_Demand_plan_id	 and selection_type	=	'I'

	and	selection_value	=	p_parameter_type

	and	nvl(supply_plan_name,'~!#$%^&*') = nvl(p_parameter_name,'~!#$%^&*')

	and	enabled_flag = 'N';



	-- enable	formula	parameters

	update msd_dp_formula_parameters

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_Demand_plan_id

	and	parameter_type = 'I'

	and	parameter_value	=	p_parameter_type

	and	nvl(supply_plan_name,'~!#$%^&*') = nvl(p_parameter_name,'~!#$%^&*')

	and	enabled_flag = 'N';



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	add_parameter;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario.

Called from	form whenever	user adds	a	scenario.

FOR	FUTURE USE

********************************************************/



procedure	add_scenario(

p_demand_plan_id in	number,

p_scenario_name	in varchar2)



is

cursor c1	is

select supply_plan_name, forecast_based_on,	parameter_name

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	scenario_name	=	p_scenario_name;



l_supply_plan_name varchar2(80);

l_forecast_based_on	varchar2(80);

l_parameter_name varchar2(80);



BEGIN

savepoint	sp;



	open c1;

	fetch	c1 into	l_supply_plan_name,	l_forecast_based_on, l_parameter_name;

	close	c1;



	update msd_dp_formula_parameters

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_demand_plan_id

	and	parameter_component	=	'SN'

	and	parameter_value	=	l_forecast_based_on

	and	nvl(supply_plan_name,'123456789')	=	nvl(l_parameter_name,'123456789');



	update msd_dp_doc_dim_selections

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_demand_plan_id

	and	selection_component	=	'SN'

	and	selection_value	=	l_forecast_based_on

	and	nvl(supply_plan_name,'123456789')	=	nvl(l_parameter_name,'123456789');



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	add_scenario;





/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario event.

Called from	form whenever	user adds	a	scenario event.

FOR	FUTURE USE

********************************************************/



procedure	add_event(

p_demand_plan_id in	number,

p_event_id in	number)



is

BEGIN

	null;

END	add_event;



procedure	add_price_list(

p_demand_plan_id in	number,

p_dp_price_list_id in	number)			/*--Bug	#	4549068--	Instead	of price_list_name,	price_list_id	will be	passed.---*/



is

BEGIN

	null;

END	add_price_list;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	calendar.

Called from	form whenever	user adds	a	calendar.

FOR	FUTURE USE

********************************************************/



procedure	add_calendar(

p_demand_plan_id in	number,

p_calendar_type	in varchar2,

p_calendar_code	in varchar2)



is

BEGIN

	null;

END	add_calendar;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	hierarchy.

Called from	form whenever	user adds	a	hierarchy.

********************************************************/



procedure	add_hierarchy(

p_demand_plan_id in	number,

p_dp_dimension_code	in varchar2,

p_hierarchy_id in	number)



is

/*----Bug	4550732----If	a	dimension	is added first time, it	will be	inserted into	seeded dimensions----*/





cursor c1(p_document_id	in number)is

select max(sequence_number)+1

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_demand_plan_id

and	document_id	=	p_document_id

and	axis = 'Z';



cursor c2	is

select distinct	document_id

from msd_dp_seeded_documents

where	demand_plan_id = p_demand_plan_id;




l_sequence_number	number;

l_count	number;

l_dimension_code varchar2(30);

l_coll_dim number;




BEGIN

savepoint	sp;



	-- enable	doc	dim	selections

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'H'

	and	selection_value	=	p_hierarchy_id

	and	enabled_flag = 'N';



 /*----Bug 4550732----If a dimension is	added	first	time,	it will	be inserted	into seeded	dimensions----*/



l_dimension_code:=p_dp_dimension_code;



select count(*)	into l_count

	from msd_dp_seeded_doc_dimensions

	where	demand_plan_id = p_demand_plan_id

	and	dimension_code = l_dimension_code;

	l_coll_dim := 0;

	select count(*) into l_coll_dim
	from msd_dp_dimensions
	where demand_plan_id=p_demand_plan_id
	and dimension_code = l_dimension_code
	and dp_dimension_code=l_dimension_code;

	-- if	not	then

	if l_count = 0  and l_coll_dim <> 0 then







			-- for all the documents in	the	plan

			for	c2_cur in	c2 loop



			-- get the next	sequence number	in 'z' axis	for	the	document

			open c1(c2_cur.document_id);

			fetch	c1 into	l_sequence_number;

			close	c1;



			-- include the dimension in	the	document at	'z'	axis

			insert into	msd_dp_seeded_doc_dimensions

			(

			DEMAND_PLAN_ID

			,DOCUMENT_ID

			,DIMENSION_CODE

			,SEQUENCE_NUMBER

			,AXIS

			,HIERARCHY_ID

			,SELECTION_TYPE

			,SELECTION_SCRIPT

			,ENABLED_FLAG

			,MANDATORY_FLAG

			,LAST_UPDATED_BY

			,CREATION_DATE

			,CREATED_BY

			,LAST_UPDATE_LOGIN

			,REQUEST_ID

			,PROGRAM_APPLICATION_ID

			,PROGRAM_ID

			,PROGRAM_UPDATE_DATE

			,LAST_UPDATE_DATE

			)

				VALUES

				(

	p_demand_plan_id

	,c2_cur.document_id

				,l_dimension_code

				,l_sequence_number

				,'Z'

				,p_hierarchy_id

	,'S'

	,'limit	'||l_dimension_code||' to	'||l_dimension_code||'.L.REL eq	1'

	,'Y'

	,'N'

				,fnd_global.user_id

				,SYSDATE

				,fnd_global.user_id

				,fnd_global.login_id

				,NULL

				,NULL

				,NULL

				,SYSDATE

				,SYSDATE

	);



			end	loop;



	end	if;





EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	add_hierarchy;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario event.

Called from	form whenever	user adds	a	scenario event.

FOR	FUTURE USE

********************************************************/



procedure	add_scenario_event(

p_demand_plan_id in	number,

p_scenario_id	in number,

p_event_id in	number)



is

BEGIN

	null;

END	add_scenario_event;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	scenario output	level.

Called from	form whenever	user adds	a	scenario output	level.

********************************************************/



procedure	add_scenario_output_lvl(

p_demand_plan_id in	number,

p_scenario_id	in number,

p_level_id in	number)



is



cursor c1	is

select enable_nonseed_flag

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	scenario_id	=	p_scenario_id;



cursor c2	is

select dimension_code

from msd_levels

where	level_id = p_level_id;



cursor c3(p_dimension_code in	varchar2)	is

select distinct	hierarchy_id

from msd_dp_hierarchies

where	demand_plan_id = p_demand_plan_id

and	dp_dimension_code	=	p_dimension_code;



cursor c4(p_document_id	in number)is

select max(sequence_number)+1

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_demand_plan_id

and	document_id	=	p_document_id

and	axis = 'Z';



cursor c5	is

select distinct	document_id

from msd_dp_seeded_documents

where	demand_plan_id = p_demand_plan_id;



l_hierarchy_id number;

l_sequence_number	number;

l_count	number;

l_nonseed_flag varchar2(15);

l_dimension_code varchar2(30);



BEGIN

savepoint	sp;



	open c1;

	fetch	c1 into	l_nonseed_flag;

	close	c1;



	open c2;

	fetch	c2 into	l_dimension_code;

	close	c2;



	if l_nonseed_flag	is null	or l_nonseed_flag	<> 'Y' then



	-- enable	doc	dim	selections

	update msd_dp_doc_dim_selections

	set	enabled_flag = 'Y'

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'L'

	and	selection_value	=	p_level_id

	and	enabled_flag = 'N';



	-- find	out	if the dimension of	the	level	is included	in all documents.	assuming that	if included	in one means included	in all.

	select count(*)	into l_count

	from msd_dp_seeded_doc_dimensions

	where	demand_plan_id = p_demand_plan_id

	and	dimension_code = l_dimension_code;



 /*------------bug 4610798--------*/

 --	Dimension	is added when	a	hierachy is	added.

	/*

	-- if	not	then

	if l_count = 0 then



			-- get the first hierarchy for the dimension in	the	plan

			open c3(l_dimension_code);

			fetch	c3 into	l_hierarchy_id;

			close	c3;



			-- for all the documents in	the	plan

			for	c5_cur in	c5 loop



			-- get the next	sequence number	in 'z' axis	for	the	document

			open c4(c5_cur.document_id);

			fetch	c4 into	l_sequence_number;

			close	c4;



			-- include the dimension in	the	document at	'z'	axis

			insert into	msd_dp_seeded_doc_dimensions

			(

			DEMAND_PLAN_ID

			,DOCUMENT_ID

			,DIMENSION_CODE

			,SEQUENCE_NUMBER

			,AXIS

			,HIERARCHY_ID

			,SELECTION_TYPE

			,SELECTION_SCRIPT

			,ENABLED_FLAG

			,MANDATORY_FLAG

			,LAST_UPDATED_BY

			,CREATION_DATE

			,CREATED_BY

			,LAST_UPDATE_LOGIN

			,REQUEST_ID

			,PROGRAM_APPLICATION_ID

			,PROGRAM_ID

			,PROGRAM_UPDATE_DATE

			,LAST_UPDATE_DATE

			)

				VALUES

				(

	p_demand_plan_id

	,c5_cur.document_id

				,l_dimension_code

				,l_sequence_number

				,'Z'

				,l_hierarchy_id

	,'S'

	,'limit	'||l_dimension_code||' to	'||l_dimension_code||'.L.REL eq	1'

	,'Y'

	,'N'

				,fnd_global.user_id

				,SYSDATE

				,fnd_global.user_id

				,fnd_global.login_id

				,NULL

				,NULL

				,NULL

				,SYSDATE

				,SYSDATE

	);



			end	loop;



	end	if;

*/

	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	add_scenario_output_lvl;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	output period.

Time dimensions	uses function	of the form	call SL.LIMIT.ROLLTIM(%1%, %2%,	%3%) for SNOP	Plans

%1%	is used	for	start	bucket,	%2%	is end bucket	and	%3%	is period	type id.

Called from	form whenever	user changes an	output period	type.

********************************************************/



procedure	change_output_period(

p_demand_plan_id in	varchar2,

p_scenario_id	in varchar2,

p_output_period_type_id	in varchar2,

p_old_output_period_type_id	in varchar2)



is



cursor c1	is

select enable_nonseed_flag

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	scenario_id	=	p_scenario_id;



cursor c2	is

select distinct	document_id

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_demand_plan_id

and	dimension_code = 'TIM'

and	upper(selection_script)	like 'CALL SL.LIMIT.ROLLTIM(%'||p_old_output_period_type_id||')';



cursor c3(p_document_id	in number) is

select selection_value,	selection_sequence

from msd_dp_doc_dim_selections

where	demand_plan_id = p_demand_plan_id

and	dimension_code = 'TIM'

and	selection_sequence in	(1,2)

and	document_id	=	p_document_id;



l_nonseed_flag varchar2(15);

l_calendar_code	varchar2(240);

l_start_date date;

l_end_date date;

l_new_selection_value	number;

l_errcode	varchar2(240);



BEGIN

savepoint	sp;



	open c1;

	fetch	c1 into	l_nonseed_flag;

	close	c1;



	-- do	only for seeded	scenarios

	if (l_nonseed_flag is	null or	l_nonseed_flag <>	'Y'	)	and	nvl(p_old_output_period_type_id,0) <>	nvl(p_output_period_type_id,0) then





	-- for all documents having	time in	rolling	buckets

	for	c2_cur in	c2 loop





		-- for first 2 parameters	of the rolling time	fucntion

		for	c3_cur in	c3(c2_cur.document_id) loop



			-- get the first calendar	attached to	the	demand plan	for	the	given	output period	type

			l_calendar_code	:= get_calendar_code(p_demand_plan_id,p_old_output_period_type_id);



			-- first value is	the	start	bucket.	get	the	start	date for the old bucket	and	then get the new start bucket

			if c3_cur.selection_sequence = 1 then

				l_start_date :=	msd_common_utilities.get_bucket_start_date(sysdate,c3_cur.selection_value,p_old_output_period_type_id,l_calendar_code);

	l_new_selection_value	:= msd_common_utilities.get_age_in_buckets(l_start_date,sysdate,p_output_period_type_id,l_calendar_code);

			-- second	value	is the end bucket. get the end date	for	the	old	bucket and then	get	the	new	end	bucket

			elsif	c3_cur.selection_sequence	=	2	then

				l_end_date :=	msd_common_utilities.get_bucket_end_date(sysdate,c3_cur.selection_value,p_old_output_period_type_id,l_calendar_code);

	l_new_selection_value	:= msd_common_utilities.get_age_in_buckets(sysdate,l_end_date,p_output_period_type_id,l_calendar_code);

			end	if;



			-- update	with new values

			update msd_dp_doc_dim_selections

			set	selection_value	=	l_new_selection_value*sign(c3_cur.selection_value)

			where	demand_plan_id = p_demand_plan_id

			and	document_id	=	c2_cur.document_id

			and	dimension_code = 'TIM'

			and	selection_type = 'TL'

			and	selection_value	=	c3_cur.selection_value

			and	selection_sequence = c3_cur.selection_sequence;



		end	loop;



	end	loop;



	-- update	the	selection	value	with new data

	update msd_dp_doc_dim_selections

	set	selection_value	=	p_output_period_type_id

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'TL'

	and	selection_value	=	p_old_output_period_type_id;



	-- create_seeded_definitions(p_demand_plan_id,l_errcode);



	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



end	change_output_period;



/*******************************************************

This Procedure changes the seeded	defintions relevant	for	the	hierarhcy.

Called from	form whenever	user changes a hierarchy

********************************************************/



procedure	change_hierarchy(

p_demand_plan_id in	varchar2,

p_hierarchy_id in	varchar2,

p_old_hierarchy_id in	varchar2)



is



cursor c1	is

select enable_nonseed_flag

from msd_dp_hierarchies

where	demand_plan_id = p_demand_plan_id

and	hierarchy_id = p_old_hierarchy_id;



l_nonseed_flag varchar2(15);

l_errcode	varchar2(240);



BEGIN

savepoint	sp;



	open c1;

	fetch	c1 into	l_nonseed_flag;

	close	c1;



	-- do	only for seeded	hierarchies

	if l_nonseed_flag	is null	or l_nonseed_flag	<> 'Y' then



	update msd_dp_doc_dim_selections

	set	selection_value	=	p_hierarchy_id

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'H'

	and	selection_value	=	p_old_hierarchy_id;



	-- create_seeded_definitions(p_demand_plan_id,l_errcode);



	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



end	change_hierarchy;



procedure	change_output_level(

p_demand_plan_id in	varchar2,

p_scenario_id	in varchar2,

p_level_id in	varchar2,

p_old_level_id in	varchar2)



is



cursor c1	is

select enable_nonseed_flag

from msd_dp_scenario_output_levels

where	demand_plan_id = p_demand_plan_id

and	scenario_id	=	p_scenario_id

and	level_id = p_old_level_id;



l_nonseed_flag varchar2(15);

l_errcode	varchar2(240);



BEGIN



savepoint	sp;





	open c1;

	fetch	c1 into	l_nonseed_flag;

	close	c1;



	-- do	only for seeded	values

	if l_nonseed_flag	is null	or l_nonseed_flag	<> 'Y' then



	update msd_dp_doc_dim_selections

	set	selection_value	=	p_level_id

	where	demand_plan_id = p_demand_plan_id

	and	selection_type = 'L'

	and	selection_value	=	p_old_level_id;



	-- create_seeded_definitions(p_demand_plan_id,l_errcode);



	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



end	change_output_level;



procedure	change_scenario_stream(

p_demand_plan_id in	varchar2,

p_scenario_id	in varchar2,

p_stream_type	in varchar2,

p_stream_name	in varchar2,

p_old_stream_type	in varchar2,

p_old_stream_name	in varchar2)



is

cursor c1	is

select enable_nonseed_flag

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	scenario_id	=	p_scenario_id;



l_nonseed_flag varchar2(15);



BEGIN

savepoint	sp;



	open c1;

	fetch	c1 into	l_nonseed_flag;

	close	c1;



	-- do	only for seeded	scenarios

	if (l_nonseed_flag is	null or	l_nonseed_flag <>	'Y'	)	and

	(nvl(p_old_stream_type,'123456789')	<> nvl(p_stream_type,'123456789')	or nvl(p_old_stream_name,'123456789')	<> nvl(p_stream_name,'123456789')) then



	-- if	there	is already a stream	attached

	if p_old_stream_type is	not	null then



		-- if	the	stream is	being	removed

		if p_stream_type is	null then



			-- disable the doc dim selections

			update msd_dp_doc_dim_selections

			set	enabled_flag = 'N'

			where	demand_plan_id = p_demand_plan_id

			and	selection_component	=	'SN'

			and	selection_value	=	p_old_stream_type;



			-- disable the formula parameters

			update msd_dp_formula_parameters

			set	enabled_flag = 'N'

			where	demand_plan_id = p_demand_plan_id

			and	parameter_component	=	'SN'

			and	parameter_value	=	p_old_stream_type;



		-- if	the	stream is	being	changed

		else



			-- change	the	doc	dim	selections

			update msd_dp_doc_dim_selections

			set	selection_value	=	p_stream_type

			where	demand_plan_id = p_demand_plan_id

			and	selection_component	=	'SN'

			and	selection_value	=	p_old_stream_type;



			-- change	the	formula	parameters

			update msd_dp_formula_parameters

			set	parameter_value	=	p_stream_type

			where	demand_plan_id = p_demand_plan_id

			and	parameter_component	=	'SN'

			and	parameter_value	=	p_old_stream_type;



		end	if;



	-- if	new	stream is	being	attached

	elsif	p_stream_type	is not null	then



			-- enable	the	doc	dim	selections

			update msd_dp_doc_dim_selections

			set	enabled_flag = 'Y'

			where	demand_plan_id = p_demand_plan_id

			and	selection_component	=	'SN'

			and	selection_value	=	p_old_stream_type;



			-- enable	the	formula	parameters

			update msd_dp_formula_parameters

			set	enabled_flag = 'Y'

			where	demand_plan_id = p_demand_plan_id

			and	parameter_component	=	'SN'

			and	parameter_value	=	p_old_stream_type;



	end	if;



	end	if;



EXCEPTION



				WHEN OTHERS	THEN

					rollback to	sp;



END	change_scenario_stream;





/*******************************************************

This Procedure creates input parameters,formulas and adds	measures to	seeded documents.

Called from	form whenever	user attahces	a	supply plan	to a scenario.

Calls	add_ascp_input_parameter,	add_ascp_formula,	add_ascp_measure,	create_seeded_definitions.

********************************************************/



Procedure	attach_supply_plan(p_new_dp_id in	number,p_supply_plan_id	in number,p_supply_plan_name in	varchar2,

															p_old_supply_plan_id in	number default null, p_old_supply_plan_name	in varchar2	default	null)	 --	Bug	4729854

is


cursor get_plan_type is
select plan_type
from msd_demand_plans
where demand_plan_id=p_new_dp_id;

p_plan_type varchar2(10);

p_errcode	varchar2(2000);

l_template_id	number;



cursor c1	is

select template_id

from msd_demand_plans

where	demand_plan_id=p_new_dp_id;



Begin


		open get_plan_type;
		fetch get_plan_type into p_plan_type;
		close get_plan_type;

		if p_plan_type='EOL' then
				add_ascp_scenario_for_eol(p_new_dp_id, p_supply_plan_id,	p_supply_plan_name);
				update msd_demand_plans
				set liab_plan_id=p_supply_plan_id
				where demand_plan_id=p_new_dp_id;
		end if;


		open c1;

		fetch	c1 into	l_template_id;

		close	c1;



		add_ascp_input_parameter(p_new_dp_id,	p_supply_plan_id,	p_supply_plan_name,	p_old_supply_plan_id,	p_old_supply_plan_name);	-- Bug 4729854



		if l_template_id is	not	null then				-- Bug 4745052



				add_ascp_formula(p_new_dp_id,	p_supply_plan_id,p_supply_plan_name, p_old_supply_plan_id, p_old_supply_plan_name);						-- Bug 4729854



				-- add measure although	it may not be	used immidiately.	it may be	used if	this is	the	first	ascp measure or	any	other	measure	is removed.

				add_ascp_measure(p_new_dp_id,	p_supply_plan_id,p_supply_plan_name, p_old_supply_plan_id, p_old_supply_plan_name);						-- Bug 4729854



				-- create_seeded_definitions(p_new_dp_id,p_errcode);

		end	if;



--EXCEPTION



	--			WHEN OTHERS	THEN

		--			null;



End	attach_supply_plan;



/*******************************************************

This Procedure creates scenario	related	to supply	plan.

Called from	update_ascp_related_data

********************************************************/



Procedure	add_ascp_scenario(p_new_dp_id	in number,p_supply_plan_id in	number,	p_supply_plan_name in	varchar2)	-- Bug 4729854

is



cursor c1	is

select count(*)	from

msd_dp_scenarios

where	demand_plan_id = p_new_dp_id

and	supply_plan_flag = 'Y';



cursor c2	is

select scenario_name,	description, demand_plan_id, scenario_id

		from msd_dp_scenarios

		where	supply_plan_flag = 'Y'

		and	demand_plan_id =

		(select	demand_plan_id

		from msd_demand_plans

		where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

		and	template_flag	=	'Y'

		and	default_template = 'Y'

		);



l_scenario_id	number;

l_count	number;

l_description	varchar2(240);

l_name varchar2(240);



BEGIN

	open c1;

		fetch	c1 into	l_count;

	close	c1;





for	c2_cur in	c2 loop









	 fnd_message.set_name('MSD',c2_cur.description);



	 l_description :=	fnd_message.get;





	 fnd_message.set_name('MSD',c2_cur.scenario_name);



	 --	if there exist scenarios with	ascp plan	attached then	name the new scenario	properly replacing 2 with	appropriate	number

	 if	l_count	>	0	then

	 l_name	:= replace(fnd_message.get,'2',l_count+2);

	 else

	 l_name	:= fnd_message.get;

	 end if;



select msd_dp_scenarios_s.nextval	into l_scenario_id from	dual;



	insert into	msd_dp_scenarios

	(demand_plan_id

	 ,scenario_id

	 ,scenario_name

	 ,description

	 ,output_period_type

	 ,horizon_start_date

	 ,horizon_end_date

	 ,forecast_date_used

	 ,forecast_based_on

	 ,last_update_date

	 ,last_updated_by

	 ,creation_date

	 ,created_by

	 ,last_update_login

	 ,request_id

	 ,program_application_id

	 ,program_id

	 ,program_update_date

	 ,attribute_category

	 ,attribute1

	 ,attribute2

	 ,attribute3

	 ,attribute4

	 ,attribute5

	 ,attribute6

	 ,attribute7

	 ,attribute8

	 ,attribute9

	 ,attribute10

	 ,attribute11

	 ,attribute12

	 ,attribute13

	 ,attribute14

	 ,attribute15

	 ,scenario_type

	 ,status

	 ,history_start_date

	 ,history_end_date

	 ,publish_flag

	 ,enable_flag

	 ,price_list_name

	 ,last_revision

	 ,parameter_name

	 ,consume_flag

	 ,error_type

	 ,supply_plan_id

	 ,deleteable_flag

	 ,supply_plan_flag

	 ,supply_plan_name

	 ,dmd_priority_scenario_id 									 --	Bug	4710963

	 ,scenario_designator

	 ,associate_parameter

	 ,sc_type)

	 (select

		p_new_dp_id

	 ,l_scenario_id

	 ,l_name

	 ,l_description

	 ,output_period_type

	 ,decode(p_type.plan_type, 'SOP', msd_common_utilities.get_bucket_start_date(sysdate,2,6,'GREGORIAN'), null)

	 ,decode(p_type.plan_type, 'SOP', msd_common_utilities.get_bucket_end_date(sysdate,19,6,'GREGORIAN'), null)

	 ,forecast_date_used

	 ,forecast_based_on

	 ,SYSDATE

	 ,fnd_global.user_id

	 ,SYSDATE

	 ,fnd_global.user_id

	 ,fnd_global.login_id

	 ,NULL

	 ,NULL

	 ,NULL

	 ,SYSDATE

	 ,attribute_category

	 ,attribute1

	 ,attribute2

	 ,attribute3

	 ,attribute4

	 ,attribute5

	 ,attribute6

	 ,attribute7

	 ,attribute8

	 ,attribute9

	 ,attribute10

	 ,attribute11

	 ,attribute12

	 ,attribute13

	 ,attribute14

	 ,attribute15

	 ,scenario_type

	 ,status

	 ,decode(p_type.plan_type, 'SOP', msd_common_utilities.get_bucket_start_date(sysdate,-18,6,'GREGORIAN'), null)

	 ,decode(p_type.plan_type, 'SOP', msd_common_utilities.get_bucket_end_date(sysdate,1,6,'GREGORIAN'), null)

	 ,publish_flag

	 ,enable_flag

	 ,price_list_name

	 ,last_revision

	 ,parameter_name

	 ,consume_flag

	 ,error_type

	 ,p_supply_plan_id

	 ,deleteable_flag

	 ,supply_plan_flag

	 ,p_supply_plan_name																					 --	Bug	4729854

	 ,dmd_priority_scenario_id																		 --	Bug	4710963

	 ,scenario_designator

	 ,associate_parameter

	 ,sc_type

		from msd_dp_scenarios,

		(select nvl(plan_type,'DP')  plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id) p_type

		where	scenario_id	=	c2_cur.scenario_id

		and	demand_plan_id = c2_cur.demand_plan_id);





 insert	into msd_dp_scenarios_tl

				 ( demand_plan_id

					 ,scenario_id

					 ,description

					 ,language

					 ,source_lang

					 ,creation_date

					 ,created_by

					 ,last_update_date

					 ,last_updated_by

					 ,last_update_login

					 ,request_id

					 ,program_application_id

					 ,program_id

					 ,program_update_date

		 )

	select

						p_new_dp_id

					 ,l_scenario_id

					 ,l_description

					 ,USERENV('LANG')

					 ,USERENV('LANG')

					 ,SYSDATE

					 ,fnd_global.user_id

					 ,SYSDATE

					 ,fnd_global.user_id

					 ,fnd_global.login_id

					 ,NULL

					 ,NULL

					 ,NULL

					 ,SYSDATE

		from dual;





		insert into	msd_dp_scenario_events

		(

		demand_plan_id

		,scenario_id

		,event_id

		,last_update_date

		,last_updated_by

		,creation_date

		,created_by

		,last_update_login

		,request_id

		,program_application_id

		,program_id

		,program_update_date

		,event_association_priority)

		(select

		p_new_dp_id

		,l_scenario_id

		,event_id

		,last_update_date

		,last_updated_by

		,creation_date

		,created_by

		,last_update_login

		,request_id

		,program_application_id

		,program_id

		,program_update_date

		,event_association_priority

		from msd_dp_scenario_events

		where	scenario_id	=	c2_cur.scenario_id

		and	demand_plan_id = c2_cur.demand_plan_id);





insert into	msd_dp_scenario_output_levels

		(

		 demand_plan_id

		 ,scenario_id

		 ,level_id

		 ,last_update_date

		 ,last_updated_by

		 ,creation_date

		 ,created_by

		 ,last_update_login

		 ,request_id

		 ,program_application_id

		 ,program_id

		 ,program_update_date)

		 (select

		 p_new_dp_id

		 ,l_scenario_id

		 ,level_id

		 ,SYSDATE

		 ,fnd_global.user_id

		 ,SYSDATE

		 ,fnd_global.user_id

		 ,fnd_global.login_id

		 ,NULL

		 ,NULL

		 ,NULL

		 ,SYSDATE

		 from	msd_dp_scenario_output_levels

		where	scenario_id	=	c2_cur.scenario_id

		and	demand_plan_id = c2_cur.demand_plan_id);





	l_count	:= l_count +1;



	end	loop;



END	add_ascp_scenario;



/*******************************************************

This Procedure creates input parameters	related	to supply	plan.

Called from	update_ascp_related_data,	attach_supply_plan.

********************************************************/



Procedure	add_ascp_input_parameter(p_new_dp_id in	number,p_supply_plan_id	in number,p_supply_plan_name in	varchar2,

																	 p_old_supply_plan_id	in number	default	null,	p_old_supply_plan_name in	varchar2 default null)		-- Bug 4729854

is

BEGIN





if p_old_supply_plan_id	is not null	then



		-- change	the	parameters if	change in	ascp plan	attahced

		if p_supply_plan_id	is not null	then



			update msd_dp_parameters

			set	parameter_name = p_supply_plan_name,					 --	Bug	4729854

			--Bug	4549059

			capacity_usage_ratio = decode(parameter_type,'MSD_SUPPLY_PLANS',p_supply_plan_name,
			                                             'MSD_SIM_END_ITEM_DEMAND',p_supply_plan_name,
			                                             capacity_usage_ratio)		-- Bug 4729854

			where	demand_plan_id = p_new_dp_id

			and	parameter_name = p_old_supply_plan_name;					-- Bug 4729854



		-- delete	if ascp	plan is	detached

		else

			delete from	msd_dp_parameters

			where	demand_plan_id = p_new_dp_id

			and	parameter_name = p_old_supply_plan_name;				 --	Bug	4729854



		end	if;



elsif	p_supply_plan_id is	not	null then



		insert into	msd_dp_parameters

		(

		demand_plan_id

		,parameter_id

		,parameter_type

		,parameter_name

		,start_date

		,end_date

		,output_scenario_id

		,input_scenario_id

		,input_demand_plan_id

		,forecast_date_used

		,forecast_based_on

		,quantity_used

		,amount_used

		,forecast_used

		,period_type

		,fact_type

		,view_name

		,last_update_date

		,last_updated_by

		,creation_date

		,created_by

		,last_update_login

		,request_id

		,program_application_id

		,program_id

		,program_update_date

		,revision

		,allo_agg_basis_stream_id

		,number_of_period

		,exclude_from_rolling_cycle

		,scn_build_refresh_num

		,rounding_flag

		,deleteable_flag

		,capacity_usage_ratio

		,supply_plan_flag
		, equation
		,stream_type
		,calculated_order
		,post_calculation
		,price_list_name)

		(select

		p_new_dp_id

		,msd_dp_parameters_s.nextval

		,parameter_type

		,p_supply_plan_name																			-- Bug 4729854

		,decode(p_type.plan_type, 'SOP', get_supply_plan_start_date(p_supply_plan_id), null)

		,decode(p_type.plan_type, 'SOP', get_supply_plan_end_date(p_supply_plan_id), null)

		,output_scenario_id

		,input_scenario_id

		,input_demand_plan_id

		,forecast_date_used

		,forecast_based_on

		,quantity_used

		,amount_used

		,forecast_used

		,period_type

		,fact_type

		,view_name

		,SYSDATE

		,fnd_global.user_id

		,SYSDATE

		,fnd_global.user_id

		,fnd_global.login_id

		,NULL

		,NULL

		,NULL

		,SYSDATE

		,revision

		,allo_agg_basis_stream_id

		,number_of_period

		,exclude_from_rolling_cycle

		,scn_build_refresh_num

		,rounding_flag

		,deleteable_flag

		,decode(p_type.plan_type, 'SOP', decode(parameter_type,'MSD_SUPPLY_PLANS',p_supply_plan_name,capacity_usage_ratio)
														, 'EOL', decode(parameter_type,'MSD_SIM_END_ITEM_DEMAND',p_supply_plan_name,capacity_usage_ratio))	 --	Bug	4729854

		,supply_plan_flag
		,equation
		,stream_type
		,calculated_order
		,post_calculation
		,price_list_name

		from msd_dp_parameters,

		(select nvl(plan_type,'DP') plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id) p_type

		where	supply_plan_flag = 'Y'

		and nvl(stream_type,'ABCD') not in ('ARCHIVED','ARCHIVED_TIM')

		and	demand_plan_id	=

		(select	demand_plan_id

		from msd_demand_plans

		where	plan_type	=	p_type.plan_type

		and	template_flag	=	'Y'

		and	default_template = 'Y'

		));



end	if;



END	add_ascp_input_parameter;



/*******************************************************

This Procedure creates formulas	related	to supply	plan.

Called from	update_ascp_related_data,	attach_supply_plan.

********************************************************/



Procedure	add_ascp_formula(p_new_dp_id in	number,p_supply_plan_id	in number,p_supply_plan_name in	varchar2,

													 p_old_supply_plan_id	in number	default	null,p_old_supply_plan_name	in varchar2	default	null)		-- Bug 4729854

is



l_formula_id number;



cursor c1	is

select

	 formula_id

	,creation_sequence

	,formula_name

	,formula_desc

	,custom_type

	,equation

	,custom_field1

	,custom_field2

	,custom_subtype

	,custom_addtlcalc

	,isby

	,valid_flag

	,numerator

	,denominator

	,supply_plan_flag

	,p_supply_plan_name														-- Bug 4729854

	,FORMAT																		 /*	ADDED	NEW	COLUMN FOR THE BUG#4373422	*/

	,START_PERIOD															 /*	ADDED	NEW	COLUMN FOR THE BUG#4744717	*/

	from msd_dp_formulas

	where	demand_plan_id	=

		(select	demand_plan_id

		from msd_demand_plans

		where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

		and	template_flag	=	'Y'

		and	default_template = 'Y'

		)

	and	supply_plan_flag = 'Y';


cursor plan_type is
select plan_type
from msd_demand_plans
where demand_plan_id=p_new_dp_id;

p_plan_type varchar2(10);

BEGIN


	open plan_type;
	fetch plan_type into p_plan_type;
	close plan_type;

	if p_old_supply_plan_id	is not null	then



		-- change	the	formula	if different ascp	plan attached

		if p_supply_plan_id	is not null	then



			update msd_dp_formulas

			set	supply_plan_name = p_supply_plan_name				 --	Bug	4729854

			where	demand_plan_id = p_new_dp_id

			and	supply_plan_name = p_old_supply_plan_name;		-- Bug 4729854



			update msd_dp_formula_parameters

			set	supply_plan_name = p_supply_plan_name						 --	Bug	4729854

			where	demand_plan_id = p_new_dp_id

			and	supply_plan_name = p_old_supply_plan_name;			 --	Bug	4729854



		-- delete	the	formula	if ascp	plan is	detached

		else



			delete from	msd_dp_formulas

			where	demand_plan_id = p_new_dp_id

			and	supply_plan_name = p_old_supply_plan_name;				 --	Bug	4729854

		/*-----Added for the bug 4605807----*/

			delete from	msd_dp_formula_parameters

			where	demand_plan_id = p_new_dp_id

			and	supply_plan_name = p_old_supply_plan_name;				 --	Bug	4729854



		end	if;



elsif	p_supply_plan_id is	not	null then



for	c1_cur in	c1 loop



	select msd_dp_parameters_s.nextval into	l_formula_id from	dual;



	insert into	msd_dp_formulas

	(

	demand_plan_id

	,formula_id

	,creation_sequence

	,formula_name

	,formula_desc

	,custom_type

	,equation

	,custom_field1

	,custom_field2

	,custom_subtype

	,custom_addtlcalc

	,isby

	,valid_flag

	,numerator

	,denominator

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,FORMAT							 /*----NEW COLUMN	ADDED	FOR	THE	BUG# 4373422-----*/

	,START_PERIOD				 /*	ADDED	NEW	COLUMN FOR THE BUG#4744717	*/

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	values

	(

	 p_new_dp_id

	,l_formula_id

	,c1_cur.creation_sequence

	,c1_cur.formula_name

	,c1_cur.formula_desc

	,c1_cur.custom_type

	,c1_cur.equation

	,c1_cur.custom_field1

	,c1_cur.custom_field2

	,c1_cur.custom_subtype

	,c1_cur.custom_addtlcalc

	,c1_cur.isby

	,c1_cur.valid_flag

	,c1_cur.numerator

	,c1_cur.denominator

	,c1_cur.supply_plan_flag

	,p_supply_plan_name												-- Bug 4729854

	,SYSDATE

	,c1_cur.FORMAT							/*----NEW	COLUMN ADDED FOR THE BUG#	4373422-----*/

	,c1_cur.START_PERIOD				/* ADDED NEW COLUMN	FOR	THE	BUG#4744717	 */

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE);



	insert into	msd_dp_formula_parameters

	(

	demand_plan_id

	,formula_id

	,where_used

	,parameter_sequence

	,enabled_flag

	,mandatory_flag

	,parameter_type

	,parameter_component

	,parameter_value

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	(select

	p_new_dp_id

	,l_formula_id

	,where_used

	,parameter_sequence

	,enabled_flag

	,mandatory_flag

	,parameter_type

	,parameter_component

	,parameter_value

	,supply_plan_flag

	,decode(supply_plan_flag,'Y',p_supply_plan_name,null)								-- Bug 4729854

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	from msd_dp_formula_parameters

	where	demand_plan_id	=

		(select	demand_plan_id

		from msd_demand_plans

		where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

		and	template_flag	=	'Y'

		and	default_template = 'Y'

		)

	and	formula_id = c1_cur.formula_id);



end	loop;


if p_plan_type='EOL' then

	insert into	msd_dp_formula_parameters

	(

	demand_plan_id

	,formula_id

	,where_used

	,parameter_sequence

	,enabled_flag

	,mandatory_flag

	,parameter_type

	,parameter_component

	,parameter_value

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	(select

	p_new_dp_id

	,mdp1.parameter_id

	,mdfp.where_used

	,mdfp.parameter_sequence

	,mdfp.enabled_flag

	,mdfp.mandatory_flag

	,mdfp.parameter_type

	,mdfp.parameter_component

	,mdfp.parameter_value

	,mdfp.supply_plan_flag

	,decode(mdfp.supply_plan_flag,'Y',p_supply_plan_name,null)								-- Bug 4729854

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	from msd_dp_formula_parameters mdfp,
	msd_dp_parameters mdp,
	msd_dp_parameters mdp1

	where	mdfp.demand_plan_id	=

		(select	demand_plan_id

		from msd_demand_plans

		where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

		and	template_flag	=	'Y'

		and	default_template = 'Y')
		and mdp.demand_plan_id=mdfp.demand_plan_id
		and mdp.parameter_id=mdfp.formula_id
		and mdp1.demand_plan_id=p_new_dp_id
		and mdp1.parameter_type=mdp.parameter_type);


end if;


/*

 * Bug#	4563958

 * This	procedure	'update_formula_names' should	always be	called whenever	a

 * supply	plan is	attached to	a	scenario.

 * Note: This	procedure	'update_formula_names' will	not	be called	whenever a

 * supply	plan attached	to a scenario	is changed/deleted.

 */

 --	if not g_call	then

 update_formula_names(p_new_dp_id);

 --	end	if;



end	if;

END	add_ascp_formula;



/*******************************************************

This Procedure adds	measures related to	supply plan	to seeded	documents	.

Called from	update_ascp_related_data,	attach_supply_plan.

********************************************************/



Procedure	add_ascp_measure(p_new_dp_id in	number,p_supply_plan_id	in number,p_supply_plan_name in	varchar2,

														p_old_supply_plan_id in	number default null,p_old_supply_plan_name in	varchar2 default null) --	Bug	4729854

is



cursor c1	is

select msd.document_id,	msd.document_name

from msd_dp_seeded_documents msd

where	msd.demand_plan_id = p_new_dp_id;



cursor c2(p_document_name	in varchar2) is

select document_id

from msd_dp_seeded_documents

where	document_name	=	p_document_name

and	demand_plan_id =

(select	demand_plan_id

from msd_demand_plans

where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

and	template_flag	=	'Y'

and	default_template = 'Y');



cursor c3	is

select count(*)

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	supply_plan_flag = 'Y';



cursor c4	is

select distinct	document_id, dimension_code

from msd_dp_seeded_doc_dimensions

where	demand_plan_id = p_new_dp_id

order	by document_id,	dimension_code;



cursor c5(p_document_id	in number, p_dimension_code	in varchar2) is

select selection_sequence

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	supply_plan_name = p_old_supply_plan_name					-- Bug 4729854

and	document_id	=	p_document_id

and	dimension_code = p_dimension_code

order	by selection_sequence;



cursor c6(p_document_id	in number, p_dimension_code	in varchar2, p_selection_sequence	in number)	is

select supply_plan_name, min(selection_sequence)

from msd_dp_doc_dim_selections

where	demand_plan_id = p_new_dp_id

and	supply_plan_name is	not	null

and	supply_plan_name <>	p_old_supply_plan_name			 --	Bug	4729854

and	document_id	=	p_document_id

and	dimension_code = p_dimension_code

and	selection_sequence > p_selection_sequence

group	by supply_plan_name

order	by min(selection_sequence);





l_max_selection_sequence number;

l_document_id	number;

l_count	number;

l_supply_plan_name varchar2(80);

l_selection_sequence	number;

l_seq_diff number	:= 0;

l_selection_count	number;

BEGIN



	if p_old_supply_plan_id	is not null	then



		-- change	the	measure	if different ascp	plan attached

		if p_supply_plan_id	is not null	then



			update msd_dp_doc_dim_selections

			set	supply_plan_name = p_supply_plan_name						-- Bug 4729854

			where	demand_plan_id = p_new_dp_id

			and	supply_plan_name = p_old_supply_plan_name;			-- Bug 4729854



		-- delete	the	measure	if ascp	plan is	detached and update	any	other	ascp specific	measure	to be	first	measure	if this	was	the	first	measure

		else





			-- for each	document,	dimension	in plan

			for	c4_cur in	c4 loop



				l_selection_count	:= 0;



				-- for each	selection	sequence for the detached	plan

				for	c5_cur in	c5(c4_cur.document_id, c4_cur.dimension_code)	loop



				-- get the next	supply plan	name if	any	and	difference in	selection	sequences	for	the	document and dimension.

	-- do	this only	once for a document	and	dimension

	if l_selection_count = 0 then

				open c6(c4_cur.document_id,	c4_cur.dimension_code,c5_cur.selection_sequence);

	fetch	c6 into	l_supply_plan_name,	l_selection_sequence;

	close	c6;



	l_seq_diff :=	l_selection_sequence - c5_cur.selection_sequence;

	end	if;



	-- delete	the	selection	first

				delete from	msd_dp_doc_dim_selections

	where	demand_plan_id = p_new_dp_id

	and	supply_plan_name = p_old_supply_plan_name							 --	Bug	4729854

	and	selection_sequence = c5_cur.selection_sequence

	and	document_id	=	c4_cur.document_id

	and	dimension_code = c4_cur.dimension_code;



				-- set the selection sequence	of the next	ascp measure to	the	selection	sequence of	the	measure	being	deleted	and	increase by	1000 to	avoid	uinque constraint	violation

				update msd_dp_doc_dim_selections

	set	selection_sequence = c5_cur.selection_sequence

	where	demand_plan_id = p_new_dp_id

	and	supply_plan_name = l_supply_plan_name

	and	selection_sequence = l_seq_diff	+	c5_cur.selection_sequence

	and	document_id	=	c4_cur.document_id

	and	dimension_code = c4_cur.dimension_code;



				l_selection_count	:= l_selection_count +1;



	end	loop;



			end	loop;



		end	if;



	elsif	p_supply_plan_id is	not	null then



	open c3;

	fetch	c3 into	l_count;

	close	c3;



	-- increase	selection	sequence if	not	first	first	plan attached

	if l_count > 0 then



	-- for each	document for the plan

	for	c1_cur in	c1 loop



	-- get the document	id of	the	same documnet	in template

	open c2(c1_cur.document_name);

	fetch	c2 into	l_document_id;

	close	c2;



	select max(selection_sequence) into	l_max_selection_sequence from	msd_dp_doc_dim_selections

	where	demand_plan_id = p_new_dp_id;



	-- create	a	new	measure	but	it will	not	be used	as it	is not first plan	attached

	insert into	msd_dp_doc_dim_selections

	(

	demand_plan_id

	,document_id

	,dimension_code

	,enabled_flag

	,mandatory_flag

	,selection_sequence

	,selection_type

	,selection_component

	,selection_value

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	(select

	 p_new_dp_id

	,c1_cur.document_id

	,dimension_code

	,enabled_flag

	,mandatory_flag

	,l_max_selection_sequence	+	selection_sequence

	,selection_type

	,selection_component

	,selection_value

	,supply_plan_flag

	,p_supply_plan_name											 --	Bug	4729854

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	from msd_dp_doc_dim_selections

	where	supply_plan_flag = 'Y'

	and	demand_plan_id =

	 (select demand_plan_id

		from msd_demand_plans

		where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

		and	template_flag	=	'Y'

		and	default_template = 'Y'

		)

		and	document_id	=	l_document_id);



	end	loop;



	-- use seeded	selection	sequence if	first	plan attached

	else /*	l_count	>0 */



	-- for each	document for the plan

	for	c1_cur in	c1 loop





	-- get the document	id of	the	same documnet	in template

	open c2(c1_cur.document_name);

	fetch	c2 into	l_document_id;

	close	c2;



	-- create	a	new	measure	and	it will	be used	as it	is the first plan	attached

	insert into	msd_dp_doc_dim_selections

	(

	demand_plan_id

	,document_id

	,dimension_code

	,enabled_flag

	,mandatory_flag

	,selection_sequence

	,selection_type

	,selection_component

	,selection_value

	,supply_plan_flag

	,supply_plan_name

	,last_update_date

	,last_updated_by

	,creation_date

	,created_by

	,last_update_login

	,request_id

	,program_application_id

	,program_id

	,program_update_date

	)

	(select

	 p_new_dp_id

	,c1_cur.document_id

	,dimension_code

	,enabled_flag

	,mandatory_flag

	,selection_sequence

	,selection_type

	,selection_component

	,selection_value

	,supply_plan_flag

	,p_supply_plan_name							 --	Bug	4729854

	,SYSDATE

	,fnd_global.user_id

	,SYSDATE

	,fnd_global.user_id

	,fnd_global.login_id

	,NULL

	,NULL

	,NULL

	,SYSDATE

	from msd_dp_doc_dim_selections

	where	supply_plan_flag = 'Y'

	and	demand_plan_id =

	 (select demand_plan_id

		from msd_demand_plans

		where	plan_type	=	(select plan_type from msd_demand_plans where demand_plan_id=p_new_dp_id)

		and	template_flag	=	'Y'

		and	default_template = 'Y'

		)

		and	document_id	=	l_document_id);



	end	loop;



	end	if;



	end	if;



END	add_ascp_measure;





Procedure	set_prd_lvl_for_liab_reports(p_demand_plan_id	in number, p_errcode in	out	nocopy varchar2)

is



l_level	varchar2(240);



begin



	select fnd_profile.value('MSC_LIABILITY_CALC_LEVEL') into	l_level	from dual;



	update msd_dp_doc_dim_selections

	set	selection_value	=	nvl(fnd_profile.value('MSC_LIABILITY_CALC_LEVEL'),1)

	where	demand_plan_id = p_demand_plan_id

	and	document_id	in

	(select	document_id

	from msd_dp_seeded_documents

	where	demand_plan_id = p_demand_plan_id

	and	document_name	in ('MSD_LB_DETAILED_REPORT','MSD_LB_SUMMARY_REPORT'))

	and	dimension_code = 'PRD'

	and	selection_type = 'L'

	and	selection_value	in ('1','2');



exception

	when others	then

		p_errcode	:= substr(sqlerrm,1,150);



end	set_prd_lvl_for_liab_reports;



/*******************************************************

This Fucntion	gets the name	of the Supply	Plan name	for	the	given	plan ID.

Called from	add_ascp_scenario, add_ascp_input_parameter, add_ascp_formula, add_ascp_measure.

Returns	Plan Name.

********************************************************/

/*	-- Bug 4729854

Function get_supply_plan_name(p_supply_plan_id in	number)	return varchar2

is

l_plan_name	varchar2(240);



cursor c1	is

select compile_designator

	from msc_plans

	where	plan_id	=	p_supply_plan_id;



BEGIN



	open c1;

	fetch	c1 into	l_plan_name;

	close	c1;



 --	bug	#	4723901





	return l_plan_name;



END;

*/

/*******************************************************

This Fucntion	gets the start date	of the Supply	Plan for the given plan	ID.

Called from	add_ascp_input_parameter.

Returns	Start	Date or	Sysdate	if Start Date	is null( Means Plan	has	not	been run)

********************************************************/



Function get_supply_plan_start_date(p_supply_plan_id in	number)	return date					 --	Bug	4729854

is

l_start_date date;



cursor c1	is

select curr_start_date

	from msc_plans

	where	plan_id	=	p_supply_plan_id;



BEGIN



if(p_supply_plan_id	<>-99) then				 --	Bug	4729854

	open c1;

	fetch	c1 into	l_start_date;

	close	c1;



else l_start_date	:= msd_common_utilities.get_bucket_start_date(sysdate,2,6,'GREGORIAN');	 --	Bug	4729854



end	if;																															 --	Bug	4729854



if l_start_date	is not null	then

		return trunc(l_start_date);

else

		return trunc(sysdate);

end	if;



END;



/*******************************************************

This Fucntion	gets the end date	of the Supply	Plan for the given plan	ID.

Called from	add_ascp_input_parameter.

Returns	End	Date or	Sysdate	if End Date	is null( Means Plan	has	not	been run)

********************************************************/



Function get_supply_plan_end_date(p_supply_plan_id in	number)	return date			-- Bug 4729854

is

l_end_date date;



cursor c1	is

select curr_cutoff_date

	from msc_plans

	where	plan_id	=	p_supply_plan_id;



BEGIN



if(p_supply_plan_id	<>-99) then		-- Bug 4729854

	open c1;

	fetch	c1 into	l_end_date;

	close	c1;

else l_end_date	:= msd_common_utilities.get_bucket_end_date(sysdate,19,6,'GREGORIAN');		 --	Bug	4729854

end	if;

	if l_end_date	is not null	then

		return trunc(l_end_date);

	else

		return trunc(sysdate);

	end	if;



END;



/*******************************************************

This Fucntion	gets the parameter ID	of the input parameter for the given Input Parameter Type	and	Name.

Called from	Replace_formula_tokens,	Replace_dimension_tokens.

Returns	Parameter	ID.

********************************************************/



Function get_parameter_id(p_demand_plan_id in	number,	p_parameter_type in	varchar2,	p_parameter_name in	varchar2,	p_parameter_component	in varchar2)

return number

is



l_parameter_id number;



cursor c1	is

select parameter_id

from msd_dp_parameters

where	demand_plan_id = p_demand_plan_id

and	parameter_type = p_parameter_type

and	nvl(parameter_name,'123456789')	=	nvl(p_parameter_name,'123456789');



cursor c2	is

select scenario_id

from msd_dp_scenarios

where	demand_plan_id = p_demand_plan_id

and	forecast_based_on	=	p_parameter_type

and	nvl(parameter_name,'123456789')	=	nvl(p_parameter_name,'123456789');



BEGIN



	if p_parameter_component like	'%.SN' then



	open c2;

	fetch	c2 into	l_parameter_id;

	close	c2;



	else



	open c1;

	fetch	c1 into	l_parameter_id;

	close	c1;



	end	if;



	return l_parameter_id;



END;



/*******************************************************

This Fucntion	gets the formula ID	of the formual for the given formula Namea and supply	plan name.

Called from	Replace_formula_tokens,	Replace_dimension_tokens.

Returns	Formula	ID.

********************************************************/



Function get_formula_id(p_demand_plan_id in	number,	p_formula_name in	varchar2,	p_supply_plan_name in	varchar2)	return number

is



l_formula_id number;



cursor c1	is

select formula_id

from msd_dp_formulas

where	demand_plan_id = p_demand_plan_id

and	formula_name = p_formula_name

and	nvl(supply_plan_name,'123456789')	=	nvl(p_supply_plan_name,'123456789');



BEGIN



	open c1;

	fetch	c1 into	l_formula_id;

	close	c1;



	return l_formula_id;



END;



/*******************************************************

This Fucntion	gets the First Calendar	Code attahced	to the demand	plan for the given Output	Period.

Thsi is	used in	finding	Bucket start and end dates.

Called from	change_output_period.

Returns	Calendar Code.

********************************************************/



Function get_calendar_code(p_demand_plan_id	in number,p_old_output_period_type_id	in number) return	varchar2

is



cursor c1	is

select calendar_code

from msd_dp_calendars

where	demand_plan_id = p_demand_plan_id

and	calendar_type	=	decode(p_old_output_period_type_id,1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4);



l_calendar_code	varchar2(240);



BEGIN



	open c1;

	fetch	c1 into	l_calendar_code;

	close	c1;



	return l_calendar_code;



END;



function get_hierarchy_id	(p_demand_plan_id	varchar2

													,p_hierarchy_id	varchar2)

return number

as



cursor c_rep_hierarchy_id(p_demand_plan_id in	number,	p_hierarchy_id in	number)	is

select min(mdh.hierarchy_id)

from msd_dp_dimensions mdd,

	msd_dp_hierarchies mdh,

	msd_hierarchies	mh

where	mdd.dimension_code =

	(select	dimension_code

	 from	msd_hierarchies

	 where hierarchy_id	=	p_hierarchy_id)	and

	 mdh.dp_dimension_code=mdd.dp_dimension_code and

	 mdh.demand_plan_id=p_demand_plan_id and

	 mdd.demand_plan_id=p_demand_plan_id and

	 mdd.dimension_code=mh.dimension_code	and

	 mh.hierarchy_id=mdh.hierarchy_id;



cursor c_hierarchy_id(p_demand_plan_id number, p_hierarchy_id	number)	is

select count(mdh.hierarchy_id)

from msd_dp_hierarchies	mdh

where

mdh.demand_plan_id=p_demand_plan_id	and

mdh.hierarchy_id=p_hierarchy_id;



l_exists number;

l_rep_hierarchy	number;



begin



		open c_hierarchy_id(to_number(p_demand_plan_id), to_number(p_hierarchy_id));

		fetch	c_hierarchy_id into	l_exists;

		close	c_hierarchy_id;



		if l_exists>0	then

			return p_hierarchy_id;

		end	if;



		open c_rep_hierarchy_id(to_number(p_demand_plan_id), to_number(p_hierarchy_id));

		fetch	c_rep_hierarchy_id into	l_rep_hierarchy;

		close	c_rep_hierarchy_id;



		return l_rep_hierarchy;



end	get_hierarchy_id;



function get_level_id	(p_demand_plan_id	number

													,p_level_id	number)

return number

as



cursor c_rep_level_id(p_demand_plan_id varchar2, p_level_id	varchar2)	is

select min(ml.level_id)

from msd_dp_dimensions mdd,

	msd_dp_hierarchies mdh,

	msd_hierarchies	mh,

	msd_hierarchy_levels mhl,

	msd_levels ml

where	mdd.dimension_code =

	(select	dimension_code

	 from	msd_hierarchies

	 where hierarchy_id	=	mh.hierarchy_id) and

	 mdh.dp_dimension_code=mdd.dp_dimension_code and

	 mdh.demand_plan_id=p_level_id and

	 mdd.demand_plan_id=p_level_id and

	 mdd.dimension_code=mh.dimension_code	and

	 mh.hierarchy_id=mdh.hierarchy_id	and

	 mhl.hierarchy_id=mh.hierarchy_id	and

	 (mhl.level_id=ml.level_id or	mhl.parent_level_id=ml.level_id) and

	 ml.level_type_code	=	(select	distinct level_type_code from	msd_levels where level_id=p_level_id);



cursor c_level_id(p_demand_plan_id number, p_level_id	number)	is

select count(mdh.hierarchy_id)

from msd_dp_hierarchies	mdh,

msd_hierarchy_levels mhl

where

mdh.demand_plan_id=p_demand_plan_id	and

mhl.hierarchy_id=mdh.hierarchy_id	and

(mhl.level_id=p_level_id or	mhl.parent_level_id=p_level_id);



l_exists number;

l_rep_level	number;



begin



		open c_level_id(to_number(p_demand_plan_id), to_number(p_level_id));

		fetch	c_level_id into	l_exists;

		close	c_level_id;



		if l_exists>0	then

			return p_level_id;

		end	if;



		open c_rep_level_id(to_number(p_demand_plan_id), to_number(p_level_id));

		fetch	c_rep_level_id into	l_rep_level;

		close	c_rep_level_id;



		return l_rep_level;



end	get_level_id;



function get_dimension_code( p_demand_plan_id	varchar2,

														 p_dimension_code	varchar2)

return varchar2

as



cursor c1(p_demand_plan_id number, p_dimension_code	varchar2)	is

select count(*)

from msd_dp_dimensions

where	dimension_code=p_dimension_code	and

demand_plan_id=p_demand_plan_id;



l_exists number;



begin



open c1(to_number(p_demand_plan_id),p_dimension_code);

fetch	c1 into	l_exists;

close	c1;



if l_exists	>	0	then

	return p_dimension_code;

else

	return null;

end	if;



end	get_dimension_code;



function get_dimension_script( p_demand_plan_id	varchar2,

														 p_dimension_code	varchar2,

														 p_dimension_script	varchar2)

return varchar2

as



cursor c1(p_demand_plan_id number, p_dimension_code	varchar2)	is

select count(*)

from msd_dp_dimensions

where	dimension_code=p_dimension_code	and

demand_plan_id=p_demand_plan_id;



l_exists number;



begin



open c1(to_number(p_demand_plan_id),p_dimension_code);

fetch	c1 into	l_exists;

close	c1;



if l_exists	>	0	then

	return p_dimension_script;

else

	return null;

end	if;



end	get_dimension_script;


Procedure	add_ascp_scenario_for_eol(p_new_dp_id	in number,p_supply_plan_id in	number,	p_supply_plan_name in	varchar2)	-- Bug 4729854

is

cursor c1	is
select count(*)	from
msd_dp_scenarios
where	demand_plan_id = p_new_dp_id
and	supply_plan_flag = 'Y'
and associate_parameter is not null;

cursor c2	is
select scenario_name,	description, demand_plan_id, scenario_id
		from msd_dp_scenarios
		where	supply_plan_flag = 'Y'
		and	demand_plan_id =
		(select	demand_plan_id
		from msd_demand_plans
		where	plan_type	=	'EOL'
		and	template_flag	=	'Y'
		and	default_template = 'Y'
		);



l_scenario_id	number;
l_count	number;
l_description	varchar2(240);
l_name varchar2(240);

BEGIN

	open c1;
		fetch	c1 into	l_count;
	close	c1;

	if l_count > 0 then
			update msd_dp_scenarios set supply_plan_name=p_supply_plan_name, supply_plan_id=p_supply_plan_id
			where demand_plan_id=p_new_dp_id
			and supply_plan_flag='Y'
			and associate_parameter is not null
			and supply_plan_id<>p_supply_plan_id;
	else
			for c2_rec in c2
			loop
					select msd_dp_scenarios_s.nextval	into l_scenario_id from	dual;
					fnd_message.set_name('MSD',c2_rec.scenario_name);
					l_name	:= fnd_message.get;
					fnd_message.set_name('MSD',c2_rec.description);
	 				l_description :=	fnd_message.get;

	 				insert into	msd_dp_scenarios
					( demand_plan_id
					  ,scenario_id
					  ,scenario_name
					  ,description
					  ,output_period_type
					  ,horizon_start_date
					  ,horizon_end_date
					  ,forecast_date_used
					  ,forecast_based_on
					  ,last_update_date
					  ,last_updated_by
					  ,creation_date
					  ,created_by
					  ,last_update_login
					  ,request_id
					  ,program_application_id
					  ,program_id
					  ,program_update_date
					  ,attribute_category
					  ,attribute1
					  ,attribute2
					  ,attribute3
					  ,attribute4
					  ,attribute5
					  ,attribute6
					  ,attribute7
					  ,attribute8
					  ,attribute9
					  ,attribute10
					  ,attribute11
					  ,attribute12
					  ,attribute13
					  ,attribute14
					  ,attribute15
					  ,scenario_type
					  ,status
					  ,history_start_date
					  ,history_end_date
					  ,publish_flag
					  ,enable_flag
					  ,price_list_name
					  ,last_revision
					  ,parameter_name
					  ,consume_flag
					  ,error_type
					  ,supply_plan_id
					  ,deleteable_flag
					  ,supply_plan_flag
					  ,supply_plan_name
					  ,dmd_priority_scenario_id 									 --	Bug	4710963
					  ,associate_parameter
					  ,sc_type)
					  (select
						p_new_dp_id
					  ,l_scenario_id
					  ,l_name
					  ,l_description
					  ,output_period_type
					  ,null
					  ,null
					  ,forecast_date_used
					  ,forecast_based_on
					  ,SYSDATE
					  ,fnd_global.user_id
					  ,SYSDATE
					  ,fnd_global.user_id
					  ,fnd_global.login_id
					  ,NULL
					  ,NULL
					  ,NULL
					  ,SYSDATE
					  ,attribute_category
					  ,attribute1
					  ,attribute2
					  ,attribute3
					  ,attribute4
					  ,attribute5
					  ,attribute6
					  ,attribute7
					  ,attribute8
					  ,attribute9
					  ,attribute10
					  ,attribute11
					  ,attribute12
					  ,attribute13
					  ,attribute14
					  ,attribute15
					  ,scenario_type
					  ,status
					  ,null
					  ,null
					  ,publish_flag
					  ,enable_flag
					  ,price_list_name
					  ,last_revision
					  ,parameter_name
					  ,consume_flag
					  ,error_type
					  ,p_supply_plan_id
					  ,deleteable_flag
					  ,supply_plan_flag
					  ,p_supply_plan_name																					 --	Bug	4729854
					  ,dmd_priority_scenario_id																		 --	Bug	4710963
					  ,associate_parameter
					  ,sc_type
						from msd_dp_scenarios
						where	scenario_id	=	c2_rec.scenario_id
						and	demand_plan_id = c2_rec.demand_plan_id);

						insert	into msd_dp_scenarios_tl
				 ( demand_plan_id
					 ,scenario_id
					 ,description
					 ,language
					 ,source_lang
					 ,creation_date
					 ,created_by
					 ,last_update_date
					 ,last_updated_by
					 ,last_update_login
					 ,request_id
					 ,program_application_id
					 ,program_id
					 ,program_update_date
		 )
	select
						p_new_dp_id
					 ,l_scenario_id
					 ,l_description
					 ,USERENV('LANG')
					 ,USERENV('LANG')
					 ,SYSDATE
					 ,fnd_global.user_id
					 ,SYSDATE
					 ,fnd_global.user_id
					 ,fnd_global.login_id
					 ,NULL
					 ,NULL
					 ,NULL
					 ,SYSDATE
		from dual;


		insert into	msd_dp_scenario_events
		(
		demand_plan_id
		,scenario_id
		,event_id
		,last_update_date
		,last_updated_by
		,creation_date
		,created_by
		,last_update_login
		,request_id
		,program_application_id
		,program_id
		,program_update_date
		,event_association_priority)
		(select
		p_new_dp_id
		,l_scenario_id
		,event_id
		,last_update_date
		,last_updated_by
		,creation_date
		,created_by
		,last_update_login
		,request_id
		,program_application_id
		,program_id
		,program_update_date
		,event_association_priority
		from msd_dp_scenario_events
		where	scenario_id	=	c2_rec.scenario_id
		and	demand_plan_id = c2_rec.demand_plan_id);

insert into	msd_dp_scenario_output_levels
		(
		 demand_plan_id
		 ,scenario_id
		 ,level_id
		 ,last_update_date
		 ,last_updated_by
		 ,creation_date
		 ,created_by
		 ,last_update_login
		 ,request_id
		 ,program_application_id
		 ,program_id
		 ,program_update_date)
		 (select
		 p_new_dp_id
		 ,l_scenario_id
		 ,level_id
		 ,SYSDATE
		 ,fnd_global.user_id
		 ,SYSDATE
		 ,fnd_global.user_id
		 ,fnd_global.login_id
		 ,NULL
		 ,NULL
		 ,NULL
		 ,SYSDATE
		 from	msd_dp_scenario_output_levels
		where	scenario_id	=	c2_rec.scenario_id
		and	demand_plan_id = c2_rec.demand_plan_id);

		end loop;

	end if;


END	add_ascp_scenario_for_eol;


END	MSD_APPLY_TEMPLATE_DEMAND_PLAN;

/
