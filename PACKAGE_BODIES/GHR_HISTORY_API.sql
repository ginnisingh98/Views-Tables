--------------------------------------------------------
--  DDL for Package Body GHR_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_HISTORY_API" as
/* $Header: ghpahapi.pkb 120.0.12010000.5 2009/07/30 10:38:00 managarw ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Ghr_History_API> >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Package Global variables ---

	g_session_var				g_session_var_type;
	g_pre_update				pa_history_type;
	g_operation_info				table_operation_info_type;


-- End Package global variables

-- ---------------------------------------------------------------------------
-- |--------------------------< set_g_session_var >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure sets the global session variable g_session_var to
--	the values passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	In Paramaters correspond to the like named columns in the g_session_var global
--	variable. See the definition of the global for details.
--
-- Post Success:
-- 	All passed paramaters will have been set in g_session_var.
--
-- Post Failure:
--   No failure conditions.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure set_g_session_var( 	p_pa_request_id 				in number	default	null,
                         	p_noa_id 					in number	default	null,
                         	p_altered_pa_request_id	 		in number	default	null,
	                       	p_noa_id_correct		 		in number	default	null,
      	                  p_person_id 				in number	default	null,
            	            p_assignment_id 				in number	default	null,
					p_date_effective				in date	default	null)
is
	l_proc	varchar2(30):='set_g_session_var';
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	g_session_var.pa_request_id				:= nvl(p_pa_request_id, g_session_var.pa_request_id);
	g_session_var.noa_id 					:= nvl(p_noa_id,g_session_var.noa_id);
	g_session_var.altered_pa_request_id 		:= nvl(p_altered_pa_request_id, g_session_var.altered_pa_request_id);
	g_session_var.noa_id_correct	 			:= nvl(p_noa_id_correct, g_session_var.noa_id_correct);
	g_session_var.person_id 				:= nvl(p_person_id, g_session_var.person_id);
	g_session_var.assignment_id 				:= nvl(p_assignment_id, g_session_var.assignment_id);
	g_session_var.date_effective				:= nvl(p_date_effective, g_session_var.date_effective);
	hr_utility.set_location(' Leaving:'||l_proc, 10);
end set_g_session_var;

-- ---------------------------------------------------------------------------
-- |--------------------------< get_g_session_var >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure gets the global session variable g_session_var into
--	the passed paramaters.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	In Paramaters correspond to the like named columns in the g_session_var global
--	variable. See the definition of the global for details.
--
-- Post Success:
-- 	All passed parameters will contain the corresponding values from g_session_var.
--
-- Post Failure:
--   No failure conditions.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure get_g_session_var( p_pa_request_id 		 out nocopy number,
                         p_noa_id 				 out nocopy number,
                         p_altered_pa_request_id 	 out nocopy number,
                         p_noa_id_correct 		 out nocopy number,
                         p_person_id 			 out nocopy number,
                         p_assignment_id 			 out nocopy number,
				 p_date_effective			 out nocopy date) is

	l_proc	varchar2(30):='get_g_session_var';
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_pa_request_id 				:= g_session_var.pa_request_id;
	p_noa_id 					:= g_session_var.noa_id;
	p_altered_pa_request_id 		:= g_session_var.altered_pa_request_id;
	p_noa_id_correct	 			:= g_session_var.noa_id_correct;
	p_person_id 				:= g_session_var.person_id;
	p_assignment_id 				:= g_session_var.assignment_id;
	p_date_effective				:= g_session_var.date_effective;
	hr_utility.set_location(' Leaving:'||l_proc, 10);
exception when others then
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
        p_pa_request_id          := null;
        p_noa_id                 := null;
        p_altered_pa_request_id  := null;
        p_noa_id_correct         := null;
        p_person_id              := null;
        p_assignment_id          := null;
        p_date_effective         := null;
        raise;
end get_g_session_var;

-- ---------------------------------------------------------------------------
-- |--------------------------< set_g_session_var >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure sets the global session variable g_session_var to
--	the values passed.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_session_var		->	g_session_var_type contains values the g_session_var
--						should be set to.
--
-- Post Success:
-- 	g_session_var will have been set to corresponding values received in p_session_var.
--
-- Post Failure:
--   No failure conditions.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure set_g_session_var( p_session_var in g_session_var_type) is
	l_proc	varchar2(30):='set_g_session_var 2';
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	g_session_var.pa_request_id 				:= nvl( p_session_var.pa_request_id, g_session_var.pa_request_id);
	g_session_var.noa_id 					:= nvl(p_session_var.noa_id, g_session_var.noa_id);
	g_session_var.altered_pa_request_id 		:= nvl(p_session_var.altered_pa_request_id, g_session_var.altered_pa_request_id);
	g_session_var.noa_id_correct 				:= nvl(p_session_var.noa_id_correct, g_session_var.noa_id_correct);
	g_session_var.person_id 				:= p_session_var.person_id;
	g_session_var.assignment_id 				:= p_session_var.assignment_id;
	g_session_var.program_name	 			:= p_session_var.program_name;
	g_session_var.fire_trigger 				:= p_session_var.fire_trigger;
	g_session_var.date_effective				:= nvl(p_session_var.date_effective, g_session_var.date_effective);
	g_session_var.pa_history_id				:= p_session_var.pa_history_id;
	hr_utility.set_location(' Leaving:'||l_proc, 10);
end set_g_session_var;

-- ---------------------------------------------------------------------------
-- |--------------------------< get_g_session_var >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure gets the global session variable g_session_var into
--	the passed p_session_var.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_session_var		->	g_session_var_type that will be populated with
--						from g_session_var.
--
-- Post Success:
-- 	p_session_var will contain the corresponding values from g_session_var.
--
-- Post Failure:
--   No failure conditions.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure get_g_session_var( p_session_var out nocopy g_session_var_type) is
	l_proc	varchar2(30):='get_g_session_var 2';
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_session_var.pa_request_id 				:= g_session_var.pa_request_id;
	p_session_var.noa_id 					:= g_session_var.noa_id;
	p_session_var.altered_pa_request_id 		:= g_session_var.altered_pa_request_id;
	p_session_var.noa_id_correct				:= g_session_var.noa_id_correct;
	p_session_var.person_id 				:= g_session_var.person_id;
	p_session_var.assignment_id 				:= g_session_var.assignment_id;
	p_session_var.program_name	 			:= g_session_var.program_name;
	p_session_var.fire_trigger 				:= g_session_var.fire_trigger;
	p_session_var.date_effective				:= g_session_var.date_effective;
	p_session_var.pa_history_id				:= g_session_var.pa_history_id;
	hr_utility.set_location(' Leaving:'||l_proc, 10);
exception when others then
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
      p_session_var := null;
      raise;
end get_g_session_var;

-- ---------------------------------------------------------------------------
-- |--------------------------< set_operation_info >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure tracks the fact that a given database row was touched in
--	this session. This is meant to be called from database triggers for the
--	tables that OGHR is concerned with tracking.
--	If the row has not already been touched, we add it to the global session var
--	g_operation_info rg. If it has already been touched, it is not necessary to add
--	as it should already have been added.
--	Inserts are handled differently than updates as we are also tracking the pre-values
--	for the row in the case of update.
--	Note that this information is being stored in global session variables so that
--	it can subsequently be stored in GHR_PA_HISTORY when this action is complete (see
--	procedure post_update_process).
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--		p_program_name		->	program from which we are calling (either 'core' or 'sf50').
--		p_date_Effective		->	effective date of the action.
--		p_table_name 		->	name of the table that this row is from.
--		p_table_pk_id		->	primary key of the row.
--		p_operation			->	dml operation being performed on the row (insert, update, delete).
--		p_old_record_data		-> 	row data prior to this dml operation.
--		p_row_id			->	rowid of this row.
--
-- Post Success:
-- 	Historical data about the dml operation being performed on this row will have been
--	noted in the global session vars.
--
-- Post Failure:
--   The program name passed is not supported.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure set_operation_info(
		p_program_name	in  varchar2							,
		p_date_Effective	in  date								,
		p_table_name 	in  ghr_pa_history.table_name%type				,
		p_table_pk_id	in  ghr_pa_history.information1%type			,
		p_operation		in  varchar2							,
		p_old_record_data	in  ghr_pa_history%rowtype					,
		p_row_id		in  rowid
		) is

	l_proc	varchar2(30):='set_operation_info';
	indx	binary_integer;
	l_row_touched	boolean;
Begin

	hr_utility.set_location('Entering:'|| l_proc, 5);
	hr_utility.set_location(l_proc || '. program_name :' || p_program_name, 6);
	hr_utility.set_location(l_proc || '. operation :' || p_operation, 7);
	if lower(p_program_name) = 'core' or
	   lower(p_program_name) = 'sf50' then
		if lower(p_operation) = 'insert' then
			-- Check if this record was previously updated/created within this session
			-- so it should already be in the rg. then don't add row since it is already in rg.
			l_row_touched := row_already_touched(p_row_id);
			if l_row_touched then
			    hr_utility.set_location(l_proc, 15);
			    null;
			else
			    hr_utility.set_location(l_proc, 20);
			    -- track the fact that this row was touched in this session.
			    indx := add_row_operation_info_rg(
					p_table_name	=> upper(p_table_name),
					p_table_pk_id	=> p_table_pk_id,
					p_operation		=> p_operation,
					p_row_id		=> p_row_id);
			end if;
		elsif lower(p_operation) = 'update' then
			-- Check if this record was previously updated/created within this session
			-- so it should be in the rg. then don't update pre. and pre-update.
			l_row_touched := row_already_touched(p_row_id);
			if l_row_touched then
	      	    hr_utility.set_location(l_proc || 'row touched', 25);
			    null;
			else
	      	    hr_utility.set_location(l_proc || 'row not touched', 30);
			    -- track the fact that this row was touched in this session.
			    indx := add_row_operation_info_rg(
					p_table_name	=> p_table_name,
					p_table_pk_id	=> p_table_pk_id,
					p_operation		=> p_operation,
					p_row_id		=> p_row_id);
			    -- since this is an update, save the pre values for this row
			    add_row_pre_update_record_rg(p_old_record_data, indx);
			end if;
		else /* delete */
        	      hr_utility.set_location(l_proc, 35);
			null;
		end if;
	else /* If called from any other process */
		-- To be worked out.
		-- It may need to be handled the way we'll handle core
		-- Until then, throw an error since this program name is not yet supported.
		hr_utility.set_location('ERROR: Program is unsupported. Program name : ' || p_program_name || l_proc, 40);
	      hr_utility.set_message(8301,'GHR_38494_UNKNOWN_PROGRAM_NAME');
		hr_utility.set_message_token('PROGRAM_NAME',p_program_name);
		hr_utility.raise_error;
	end if;
	hr_utility.set_location('Leaving:'|| l_proc, 45);
End set_operation_info;

-- ---------------------------------------------------------------------------
-- |--------------------------< add_row_operation_info_rg >-------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Adds a row to the global session variable g_operation_info. Returns the
--	incremented index for the next row in the record group.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--		p_table_name 		->	name of the table that this row is from.
--		p_table_pk_id		->	primary key of the row.
--		p_operation			->	dml operation being performed on the row (insert, update, delete).
--		p_row_id			->	rowid of this row.
--
-- Post Success:
--	Row will have been added to g_operation_info.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Function add_row_operation_info_rg ( p_table_name 	in ghr_pa_history.table_name%type,
				 	 	 p_table_pk_id	in ghr_pa_history.information1%type,
 						 p_operation	in varchar2,
 						 p_row_id		in rowid) return binary_integer is

	indx	binary_integer;
	l_proc	varchar2(30):='add_row_operation_info_rg';
BEGIN
	hr_utility.set_location('Entering:'|| l_proc, 5);
	indx 						:= g_operation_info.COUNT+1;
	g_operation_info(indx).table_name 	:= p_table_name;
	g_operation_info(indx).table_pk_id 	:= p_table_pk_id;
	g_operation_info(indx).operation 	:= p_operation;
	g_operation_info(indx).row_id 	:= p_row_id;
	hr_utility.set_location('Leaving:'|| l_proc, 10);
	return indx;
END;

-- ---------------------------------------------------------------------------
-- |--------------------------< add_row_pre_update_record_rg >----------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Adds a row to the global session variable g_pre_update_record_rg.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--		p_pre_update_rg 		->	record to be added.
--		p_ind				->	index of this row (index is the same as
--							the index for the corresponding row in
--							g_operation_info).
--
-- Post Success:
--	Row will have been added to g_pre_update.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure add_row_pre_update_record_rg ( p_pre_update_rg in ghr_pa_history%rowtype,
						     p_ind		in	binary_integer) is
	l_proc	 varchar2(30) := 'add_row_pre_update_record_rg';
	l_hist_data	ghr_pa_history%rowtype;
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	-- local variable is used to temporarily hold the data because the
	-- assignment did not work for some unknown reason (a bug in PL/SQL??)
	-- when doing the assignment with p_pre_update directly.
	l_hist_data := p_pre_update_rg;
	g_pre_update(p_ind) := l_hist_data;
	hr_utility.set_location('Leaving:'|| l_proc, 10);
End add_row_pre_update_record_rg ;


-- ---------------------------------------------------------------------------
-- |--------------------------< display_g_session_var >-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Displays the g_session_var information using hr_utility.set_location calls.
--	(trace must be on to see this information). This procedure is meant to be
--	used for debugging only.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	None.
--
-- Post Success:
--	g_session_var data will have been displayed.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure display_g_session_var is
	l_ind		binary_integer;
	l_proc	varchar2(30):='display_g_session_var';
begin
	hr_utility.set_location('Entering:'  || l_proc, 5);
	hr_utility.set_location('pa_request_id='  ||g_session_var.pa_request_id, 6);
	hr_utility.set_location('NOA_ID='||g_session_var.noa_id, 7);
	hr_utility.set_location('altered_pa_request_id=' || g_session_var.altered_pa_request_id, 8);
	hr_utility.set_location('NOA_ID_CORRECT=' || g_session_var.noa_id_correct, 9);
	hr_utility.set_location('PERSON_ID=' || g_session_var.person_id, 10 );
	hr_utility.set_location('ASSIGNMENT_ID=' || g_session_var.assignment_id, 11);

	for l_ind in 1 .. g_pre_update.count LOOP
           null;
	end loop;

	hr_utility.set_location('Leaving:' || l_proc, 10);
exception
	when others then
		raise;
end display_g_session_var;

-- ---------------------------------------------------------------------------
-- |--------------------------< row_already_touched >-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Returns true if row is already in g_operation_info. If it already is in
--	this record group, then this session has already touched this particular
--	row.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_row_id		->	rowid of the row being considered.
--
-- Post Success:
--	Returns TRUE if row has already been put in g_operation_info, FALSE
--	otherwise.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Function row_already_touched(p_row_id		in 	rowid) return boolean is
	ind	binary_integer;
	l_proc	 varchar2(30) := 'row_already_touched' ;
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	if g_operation_info.COUNT > 0 then
		ind := g_operation_info.FIRST;
		hr_utility.set_location(l_proc, 10);
		LOOP
			if g_operation_info(ind).row_id = p_row_id then
				return TRUE ;
			END IF;
			Exit when ind = g_operation_info.LAST;
			ind := g_operation_info.NEXT(ind);
		END LOOP;
		hr_utility.set_location('Leaving:'|| l_proc, 15);
		return FALSE;
	END IF;
	return FALSE;
End;

-- ---------------------------------------------------------------------------
-- |--------------------------< reinit_g_session_var >------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	set g_session_var back to default values.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	None.
--
-- Post Success:
--	g_session_var will contain default settings.
--
-- Post Failure:
--   	No failure conditions.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure reinit_g_session_var is
	l_proc	varchar2(30):='reinit_g_session_var';
begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	g_session_var.pa_request_id				:= null;
	g_session_var.noa_id 					:= null;
	g_session_var.altered_pa_request_id 		:= null;
	g_session_var.noa_id_correct	 			:= null;
	g_session_var.person_id 				:= null;
	g_session_var.assignment_id 				:= null;
	g_session_var.program_name 				:= null;
	g_session_var.fire_trigger 				:= null;
	g_session_var.date_effective 				:= null;
	g_session_var.pa_history_id				:= null;
	g_pre_update.delete;
	g_operation_info.delete;

	hr_utility.set_location('Leaving:' || l_proc, 10);

end reinit_g_session_var;

Procedure fetch_history_info(
	p_table_name				in	varchar2	default null,
	p_table_pk_id				in	varchar2	default null,
	p_row_id					in	rowid		default null,
	p_person_id					in	number	default null,
	p_date_effective				in	date		default null,
	p_altered_pa_request_id			in	number	default null,
	p_noa_id_corrected			in	number	default null,
	p_pa_history_id				in 	number	default null,
	p_hist_data 			  in out nocopy ghr_pa_history%rowtype,
	p_result_code			     out nocopy varchar2) is

	l_people_data				per_all_people_f%rowtype;
	l_asgei_data				per_assignment_extra_info%rowtype;
	l_asgn_data					per_all_assignments_f%rowtype;
	l_peopleei_data				per_people_extra_info%rowtype;
	l_element_entry_value_data		pay_element_entry_values_f%rowtype;
	l_element_entry_data			pay_element_entries_f%rowtype;
	l_posnei_data				per_position_extra_info%rowtype;
	l_peranalyses_data			per_person_analyses%rowtype;
	l_address_data				per_addresses%rowtype;
	l_position_data				hr_all_positions_f%rowtype;
        l_hist_data                             ghr_pa_history%rowtype;
	l_proc	 				varchar2(30) := 'fetch_history_info';

begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
        --
        -- Remember IN OUT parameter IN values
        l_hist_data := p_hist_data;

	if ( lower(p_table_name) = lower(ghr_history_api.g_peop_table) ) then
		hr_utility.set_location(l_proc, 10);
		ghr_history_fetch.fetch_people(p_person_id				=> p_person_id,
				 p_date_effective				=> p_date_effective,
				 p_altered_pa_request_id		=> p_altered_pa_request_id,
			  	 p_noa_id_corrected			=> p_noa_id_corrected,
				 p_rowid					=> p_row_id,
				 p_pa_history_id				=> p_pa_history_id,
				 p_people_data				=> l_people_data,
				 p_result_code				=> p_result_code );

		ghr_history_conv_rg.conv_people_rg_to_hist_rg( p_people_data        => l_people_data,
						   p_history_data       => p_hist_data );
	elsif ( lower(p_table_name) = lower(ghr_history_api.g_asgnei_table) ) then
		hr_utility.set_location(l_proc, 15);
		ghr_history_fetch.fetch_asgei(p_assignment_extra_info_id		=> p_table_pk_id,
				 p_date_effective				=> p_date_effective,
				 p_altered_pa_request_id		=> p_altered_pa_request_id,
			  	 p_noa_id_corrected			=> p_noa_id_corrected,
				 p_rowid					=> p_row_id,
				 p_pa_history_id				=> p_pa_history_id,
				 p_asgei_data				=> l_asgei_data,
				 p_result_code				=> p_result_code );
		ghr_history_conv_rg.conv_asgnei_rg_to_hist_rg(
					p_asgnei_data      => l_asgei_data,
					p_history_data     => p_hist_data );

	elsif ( lower(p_table_name) = lower(ghr_history_api.g_asgn_table) ) then
		hr_utility.set_location(l_proc, 25);
		ghr_history_fetch.fetch_assignment (
		p_assignment_id			=> p_table_pk_id,
		p_date_effective			=> p_date_effective,
		p_altered_pa_request_id		=> p_altered_pa_request_id,
		p_noa_id_corrected		=> p_noa_id_corrected,
		p_rowid				=> p_row_id,
		p_pa_history_id			=> p_pa_history_id,
		p_assignment_data			=> l_asgn_data,
		p_result_code			=> p_result_code
		);
		ghr_history_conv_rg.conv_asgn_rg_to_hist_rg(
					p_assignment_data      => l_asgn_data,
					p_history_data   => p_hist_data );

	elsif ( lower(p_table_name) = lower(ghr_history_api.g_peopei_table) ) then
		hr_utility.set_location(l_proc, 35);
		ghr_history_fetch.fetch_peopleei(
		p_person_extra_info_id		=> p_table_pk_id,
		p_date_effective			=> p_date_effective,
		p_altered_pa_request_id		=> p_altered_pa_request_id,
		p_noa_id_corrected		=> p_noa_id_corrected,
		p_rowid				=> p_row_id,
		p_pa_history_id			=> p_pa_history_id,
		p_peopleei_data			=> l_peopleei_data,
		p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_peopleei_rg_to_hist_rg(
					p_people_ei_data   => l_peopleei_data,
					p_history_data   => p_hist_data );

	elsif ( lower(p_table_name) = lower(ghr_history_api.g_eleevl_table) ) then
		hr_utility.set_location(l_proc, 35);
		ghr_history_fetch.fetch_element_entry_value(
		p_element_entry_value_id	=> p_table_pk_id,
		p_date_effective			=> p_date_effective,
		p_altered_pa_request_id		=> p_altered_pa_request_id,
		p_noa_id_corrected		=> p_noa_id_corrected,
		p_rowid				=> p_row_id,
		p_pa_history_id			=> p_pa_history_id,
		p_element_entry_data		=> l_element_entry_value_data,
		p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_element_entval_rg_to_hist(
					p_element_entval_data   => l_element_entry_value_data,
					p_history_data   => p_hist_data );

	elsif ( lower(p_table_name) = lower(ghr_history_api.g_eleent_table) ) then
		hr_utility.set_location(l_proc, 35);
		ghr_history_fetch.fetch_element_entries(
		p_element_entry_id		=> p_table_pk_id,
		p_date_effective			=> p_date_effective,
		p_altered_pa_request_id		=> p_altered_pa_request_id,
		p_noa_id_corrected		=> p_noa_id_corrected,
		p_rowid				=> p_row_id,
		p_pa_history_id			=> p_pa_history_id,
		p_element_entry_data		=> l_element_entry_data,
		p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_element_entry_rg_to_hist(
					p_element_entries_data   => l_element_entry_data,
					p_history_data   => p_hist_data );

	elsif ( lower(p_table_name) = lower(ghr_history_api.g_posnei_table) ) then
		hr_utility.set_location(l_proc, 35);
		ghr_history_fetch.fetch_positionei(
		p_position_extra_info_id	=> p_table_pk_id,
		p_date_effective			=> p_date_effective,
		p_altered_pa_request_id		=> p_altered_pa_request_id,
		p_noa_id_corrected		=> p_noa_id_corrected,
		p_rowid				=> p_row_id,
		p_pa_history_id			=> p_pa_history_id,
		p_posei_data			=> l_posnei_data,
		p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_positionei_rg_to_hist_rg(
					p_position_ei_data   => l_posnei_data,
					p_history_data   => p_hist_data );

	elsif ( lower(p_table_name) = lower(ghr_history_api.g_perana_table) ) then
		hr_utility.set_location(l_proc, 40);
		ghr_history_fetch.fetch_person_analyses (
			p_person_analysis_id		=> p_table_pk_id,
			p_date_effective			=> p_date_effective,
			p_altered_pa_request_id		=> p_altered_pa_request_id,
			p_noa_id_corrected		=> p_noa_id_corrected,
			p_rowid				=> p_row_id,
			p_pa_history_id			=> p_pa_history_id,
			p_peranalyses_data		=> l_peranalyses_data,
			p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_peranalyses_rg_to_hist_rg(
		p_peranalyses_data  => l_peranalyses_data,
		p_history_data   	  => p_hist_data);
	elsif ( lower(p_table_name) = lower(ghr_history_api.g_addres_table) ) then
		hr_utility.set_location(l_proc, 40);
		ghr_history_fetch.fetch_address(
			p_address_id			=> p_table_pk_id,
			p_date_effective			=> p_date_effective,
			p_altered_pa_request_id		=> p_altered_pa_request_id,
			p_noa_id_corrected		=> p_noa_id_corrected,
			p_rowid				=> p_row_id,
			p_pa_history_id			=> p_pa_history_id,
			p_address_data			=> l_address_data,
			p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_addresses_rg_to_hist_rg(
			p_addresses_data    =>	l_address_data,
			p_history_data   	  =>  p_hist_data);
	elsif ( lower(p_table_name) = lower(ghr_history_api.g_posn_table) ) then
		hr_utility.set_location(l_proc, 40);
		ghr_history_fetch.fetch_position(
			p_position_id			=> p_table_pk_id,
			p_date_effective			=> p_date_effective,
			p_altered_pa_request_id		=> p_altered_pa_request_id,
			p_noa_id_corrected		=> p_noa_id_corrected,
			p_rowid				=> p_row_id,
			p_pa_history_id			=> p_pa_history_id,
			p_position_data			=> l_position_data,
			p_result_code			=> p_result_code);

		ghr_history_conv_rg.conv_position_rg_to_hist_rg(
			p_position_data    =>	l_position_data,
			p_history_data   	  =>  p_hist_data);

	else
		hr_utility.set_location('ERROR: Table is unsupported. Table name : ' || p_table_name || l_proc, 45);
	      hr_utility.set_message(8301,'GHR_38495_UNKNOWN_TABLE_NAME');
		hr_utility.set_message_token('TABLE_NAME',p_table_name);
		hr_utility.raise_error;
	end if;

	hr_utility.set_location(' Leaving:'||l_proc, 20);
exception when others then
      --
      -- Reset IN OUT parameters and set OUT parameters
      --
      p_hist_data   := l_hist_data;
      p_result_code := null;
      raise;

end fetch_history_info;

-- ---------------------------------------------------------------------------
-- |--------------------------< post_update_process >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Takes information from session global variables and inserts appropriate tracking
--	information into ghr_pa_history table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	None.
--
-- Post Success:
--	ghr_pa_history will have been populated with all history information for the
--	database rows that were changed in this session.
--
-- Post Failure:
--   An exception will be generated if there were no records found in history for an
--	element_entry_value.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE post_update_process IS
	indx				binary_integer:=1;
	l_return_status		varchar2(10);
	l_pre_mode			varchar2(10):='PRE';
	l_post_mode			varchar2(10):='POST';
	l_hist_data			ghr_pa_history%rowtype;
	l_eleevl_hist_data	ghr_pa_history%rowtype;
	l_eleevl_data		pay_element_entry_values_f%rowtype;
	l_pre_record		ghr_pa_history%rowtype;
	l_post_data			ghr_pa_history%rowtype;
	l_session_var		g_session_var_type;
	pa_history_id		ghr_pa_history.pa_history_id%type;
	l_interv_on_table		Boolean;
	l_interv_on_eff_date 	Boolean;
	l_rec_avl               Boolean;
	l_pre_effective_end_date	date;
	l_dummy_hist_data		ghr_pa_history%rowtype := null;
	l_hist_data_as_of_date	ghr_pa_history%rowtype;
	l_dml_operation 		ghr_pa_history.dml_operation%type;
	l_pre_values_flag       ghr_pa_history.pre_values_flag%type;
	l_pa_history_id		number;
	l_error_message         varchar2(1000);
	l_proc	 		varchar2(30) := 'post_update_process';

	-- initializes l_hist_data with session variable information.
	PROCEDURE init_record_data(l_session_var in g_session_var_type,
						 l_hist_data in out nocopy ghr_pa_history%rowtype,
						 indx	in	binary_integer) IS
         l_dummy      VARCHAR2(1);
         l_i_hist_data ghr_pa_history%rowtype;
        cursor c_noa_sep_family is
         select 'X' from ghr_nature_of_actions
          where code in ('300','301','302','303','304','312','317',
                        '330','350','351','353','355','356','357','385')
            and nature_of_action_id = l_session_var.noa_id;
	BEGIN
                --
                -- Remember IN OUT parameter IN values
                l_i_hist_data := l_hist_data;

		l_hist_data.process_date 		:= 	sysdate;
		l_hist_data.effective_date 		:= 	l_session_var.date_effective;
		l_hist_data.table_name 			:= 	g_operation_info(indx).table_name;
		l_hist_data.pa_request_id 		:= 	l_session_var.pa_request_id;
		l_hist_data.altered_pa_request_id 	:=	l_session_var.altered_pa_request_id;
		l_hist_data.nature_of_action_id 	:=	l_session_var.noa_id;
		l_hist_data.person_id			:=	l_session_var.person_id;
		l_hist_data.assignment_id		:=	l_session_var.assignment_id;

                -- Bug# 1240717. In case of Separation and NTE dates for assignment extra info
                -- the effective date should be 1 day more than the effective date of RPA.
                IF l_hist_data.table_name = 'PER_ASSIGNMENT_EXTRA_INFO' AND
                   l_hist_data.information5 = 'GHR_US_ASG_NTE_DATES'
                THEN
                  OPEN c_noa_sep_family;
                  FETCH c_noa_sep_family INTO l_dummy;
                  IF c_noa_sep_family%FOUND THEN
                    l_hist_data.effective_date          :=      l_session_var.date_effective + 1;
                  END IF;
                  CLOSE c_noa_sep_family;
                END IF;
        EXCEPTION WHEN OTHERS then
                --
                -- Reset IN OUT parameters and set OUT parameters
                --
                l_hist_data := l_i_hist_data;
                raise;

	END;

	-- populates p_session_var with correct person_id and assignment_id if they
	-- have not already been populated.
	procedure get_asgn_peop (p_session_var	in out nocopy g_session_var_type) is
		cursor c1 (c_position_id number) is
		select
			assignment_id ,
			person_id
		from per_all_assignments_f
		where position_id = c_position_id
                  and assignment_type <> 'B';

		cursor c2 (c_assignment_id number) is
		select
			person_id
		from per_all_assignments_f
		where assignment_id = c_assignment_id
                  and assignment_type <> 'B';

		cursor c3 (c_element_entry_id number) is
		select
			assignment_id
		from pay_element_entries_f
		where element_entry_id = c_element_entry_id;

                l_session_var   g_session_var_type;
		l_proc		varchar2(30):='get_asgn_peop';

	Begin
		hr_utility.set_location( 'Entering : ' || l_proc, 10);
                --
                -- Remember IN OUT parameter IN values
                l_session_var  := p_session_var;

		if p_session_var.assignment_id is null and
		   p_session_var.position_id is not null   then
			hr_utility.set_location( l_proc, 20);
			open c1 (p_session_var.position_id);
			fetch c1 into
				p_session_var.assignment_id,
				p_session_var.person_id;
			if c1%notfound then
				hr_utility.set_location( l_proc, 30);
			end if;
			close c1;
		end if;

		if p_session_var.assignment_id is null and
		   p_session_var.element_entry_id is not null then
			hr_utility.set_location( l_proc, 40);
			open c3( p_session_var.element_entry_id);
			Fetch c3 into
				p_session_var.assignment_id;
			if c3%notfound then
				hr_utility.set_location( l_proc, 50);
			end if;
			close c3;
		end if;

		if p_session_var.person_id is null and
		   p_session_var.assignment_id is not null then
			hr_utility.set_location( l_proc, 60);
			open c2(p_session_var.assignment_id);
			fetch c2 into
				p_session_var.person_id;
			if c2%notfound then
				hr_utility.set_location( l_proc, 20);
			end if;
			close c2;

		end if;
        exception when others then
                --
                -- Reset IN OUT parameters and set OUT parameters
                --
                p_session_var := l_session_var;
                raise;
	End;

BEGIN
	hr_utility.set_location('Entering:'|| l_proc, 5);
	/* 	set fire_trigger to N so that none of the cascading will cause triggers to be fired.
		must be turned back on when cascading is complete. */
	get_g_session_var (l_session_var);
	l_session_var.fire_trigger := 'N';
	-- set session variables (person_id, assignment_id) if value is null
	get_asgn_peop( l_session_var);
	set_g_session_var (l_session_var);
	hr_utility.set_location(l_proc, 10);

	-- The following loop will loop thru all database rows that were touched in this session (everything in
	-- g_operation_info rg). For every row, the corresponding history information will be inserted into
	-- ghr_pa_history.
	WHILE indx <= g_operation_info.COUNT
	LOOP
		hr_utility.set_location(l_proc || 'in post process' || to_char(indx) || g_operation_info(indx).operation, 10);
		l_hist_data  := l_dummy_hist_data;
		l_pre_record := l_dummy_hist_data;
		l_post_data  := l_dummy_hist_data;

		-- if operation is insert then call fetch_history_info passing l_session_var.date_effective - 1
		-- otherwise use l_session_var.dete_effective.
		if g_operation_info(indx).operation = 'insert' then
			l_pre_effective_end_date :=	l_session_var.date_effective - 1;
		elsif g_operation_info(indx).operation = 'update' then
			l_pre_effective_end_date :=	l_session_var.date_effective;
		else
			l_pre_effective_end_date :=	l_session_var.date_effective;
		end if;

		-- if this is a datetrack table, DML operation was an update, and it is not the correction SF52 then
		-- we may use Pre-update from global session
		if (lower(g_operation_info(indx).table_name) in (lower(ghr_history_api.g_eleevl_table),
			lower(ghr_history_api.g_asgn_table),lower(ghr_history_api.g_peop_table),
                        lower(ghr_history_api.g_posn_table),
			lower(ghr_history_api.g_eleent_table)) AND l_session_var.noa_id_correct is NULL AND
			lower(g_operation_info(indx).operation) = 'update') then
				hr_utility.set_location(l_proc || 'using pre_update', 9158);
				l_pre_record	:= g_pre_update(indx);
				-- Pre-record found
				l_return_Status	:= NULL;
		else
			hr_utility.set_location(l_proc || 'calling fetch_history_info', 9157);
			-- Fetch Pre-record
			fetch_history_info(
				p_table_name 		=> g_operation_info(indx).table_name,
				p_hist_data			=> l_hist_data,
				p_table_pk_id 		=> g_operation_info(indx).table_pk_id,
				p_person_id			=> l_session_var.person_id,
				p_date_effective		=> l_pre_effective_end_date,
				p_altered_pa_request_id => l_session_var.altered_pa_request_id,
				p_noa_id_corrected	=> l_session_var.noa_id_correct,
				p_result_code		=> l_return_status);

			l_pre_record	:= l_hist_data;

		end if;
	hr_utility.set_location('l_pre_record.pa_history_id: ' || l_pre_record.pa_history_id || l_proc,2009);
      hr_utility.set_location('l_pre_record.information1: ' || l_pre_record.information1 || l_proc,2010);
      hr_utility.set_location('l_pre_record.person_id: ' || l_pre_record.person_id || l_proc,2011);
      hr_utility.set_location('l_pre_record.effective_date: ' || l_pre_record.effective_date || l_proc,2012);
      hr_utility.set_location('l_pre_record.information9: ' || l_pre_record.information9 || l_proc,2019);
      hr_utility.set_location('l_pre_record.information10: ' || l_pre_record.information10 || l_proc,2020);
      hr_utility.set_location('l_pre_record.information11: ' || l_pre_record.information11 || l_proc,2021);
      hr_utility.set_location('l_pre_record.information12: ' || l_pre_record.information12 || l_proc,2022);
      hr_utility.set_location('l_pre_record.information13: ' || l_pre_record.information13 || l_proc,2023);
      hr_utility.set_location('l_pre_record.information14: ' || l_pre_record.information14 || l_proc,2024);

		IF g_operation_info(indx).operation = 'insert' THEN
			IF l_return_status IS NULL THEN
				hr_utility.set_location(l_proc || 'Insert: history found.', 15);
				-- inserting with pre-values
				l_pre_values_flag := 'Y';
				l_dml_operation := ghr_history_api.g_ins_operation;
			ELSE
				hr_utility.set_location(l_proc || 'Insert: history NOT found.', 20);
				-- inserting with no pre-values
				l_dml_operation := ghr_history_api.g_ins_operation;
				l_pre_values_flag := 'N';
			END IF;
		ELSIF g_operation_info(indx).operation = 'update' THEN
			-- set pre-record rg
			hr_utility.set_location(l_proc || 'Update.', 25);
			IF l_return_status IS NULL THEN
				hr_utility.set_location(l_proc || 'Update: history found.', 15);
				-- set Pre_record_rg and other flags
				-- updating with pre-values
				l_pre_values_flag := 'Y';
				l_dml_operation := ghr_history_api.g_upd_operation;
			ELSE
				hr_utility.set_location(l_proc || 'Update: history NOT found.', 20);
				-- updating with no pre-values
				l_dml_operation := ghr_history_api.g_upd_operation;
				l_pre_values_flag := 'N';
			END IF;
		END IF;


		hr_utility.set_location(l_proc || 'Fetch history info for post-update.', 30);
	--	get post_update using rowid.
	-- 	Need only pass rowid, other parms should be changed to be nullable.
		fetch_history_info(
			p_table_name 		=> g_operation_info(indx).table_name,
			p_hist_data 		=> l_post_data,
			p_row_id			=> g_operation_info(indx).row_id,
			p_result_code		=> l_return_status);

                -- BUG # 5195518 added the below validation as if no record exists with the
		-- row id then no need of inserting into PA History.
                l_rec_avl := TRUE;
		If  g_operation_info(indx).table_name in (ghr_history_api.g_eleevl_table,ghr_history_api.g_eleent_table )
		    and l_return_status is not null then
		    l_rec_avl := FALSE ;
		End if;

		If l_rec_avl then

		l_post_data.pre_values_flag := l_pre_values_flag;
		l_post_data.dml_operation  := l_dml_operation;
		-- set post-update-rg
		init_record_data(l_session_var, l_post_data, indx);
		hr_utility.set_location(l_proc || 'Add post-record record', 35);
		hr_utility.set_location(l_proc || l_post_data.effective_date,36);
		hr_utility.set_location(l_proc || l_return_status,37);

		hr_utility.set_location(l_proc || 'Insert in pa history: effective_date = .' || to_char(l_post_data.effective_date), 40);
		hr_utility.set_location(l_proc || 'Insert in pa history: Process_date = .' || to_char(l_post_data.Process_date), 45);
		hr_utility.set_location(l_proc || 'Insert in pa history: table_name = .' || l_post_data.table_name, 50);
		hr_utility.set_location(l_proc || 'Insert in pa history: pa_request_id = .' || to_char(l_post_data.pa_request_id), 60);
		hr_utility.set_location(l_proc || 'Insert in pa history: nature_of_action_id = .' || to_char(l_post_data.nature_of_action_id), 65);
		hr_utility.set_location(l_proc || 'Insert in pa history: dml_operation = .' || l_post_data.dml_operation, 75);

		ghr_pah_ins.ins(
			p_pa_history_id			=> pa_history_id						,
			p_pa_request_id			=> l_post_data.pa_request_id		,
			p_process_date			=> l_post_data.process_date			,
			p_nature_of_action_id		=> l_post_data.nature_of_action_id	,
			p_effective_date			=> l_post_data.effective_date		,
			p_altered_pa_request_id		=> l_post_data.altered_pa_request_id	,
			p_person_id				=> l_post_data.person_id			,
			p_assignment_id			=> l_post_data.assignment_id		,
			p_dml_operation			=> l_post_data.dml_operation		,
			p_table_name			=> upper(l_post_data.table_name)		,
			p_pre_values_flag			=> l_post_data.pre_values_flag		,
			p_information1			=> l_post_data.information1			,
			p_information2			=> l_post_data.information2			,
			p_information3			=> l_post_data.information3			,
			p_information4			=> l_post_data.information4			,
			p_information5			=> l_post_data.information5			,
			p_information6			=> l_post_data.information6			,
			p_information7			=> l_post_data.information7			,
			p_information8			=> l_post_data.information8			,
			p_information9			=> l_post_data.information9			,
			p_information10			=> l_post_data.information10		,
			p_information11			=> l_post_data.information11		,
			p_information12			=> l_post_data.information12		,
			p_information13			=> l_post_data.information13		,
			p_information14			=> l_post_data.information14		,
			p_information15			=> l_post_data.information15		,
			p_information16			=> l_post_data.information16		,
			p_information17			=> l_post_data.information17		,
			p_information18			=> l_post_data.information18		,
			p_information19			=> l_post_data.information19		,
			p_information20			=> l_post_data.information20		,
			p_information21			=> l_post_data.information21		,
			p_information22			=> l_post_data.information22		,
			p_information23			=> l_post_data.information23		,
			p_information24			=> l_post_data.information24		,
			p_information25			=> l_post_data.information25		,
			p_information26			=> l_post_data.information26		,
			p_information27			=> l_post_data.information27		,
			p_information28			=> l_post_data.information28		,
			p_information29			=> l_post_data.information29		,
			p_information30			=> l_post_data.information30		,
			p_information31			=> l_post_data.information31		,
			p_information32			=> l_post_data.information32		,
			p_information33			=> l_post_data.information33		,
			p_information34			=> l_post_data.information34		,
			p_information35			=> l_post_data.information35		,
			p_information36			=> l_post_data.information36		,
			p_information37			=> l_post_data.information37		,
			p_information38			=> l_post_data.information38		,
			p_information39			=> l_post_data.information39		,
			p_information47			=> l_post_data.information47		,
			p_information48			=> l_post_data.information48		,
			p_information49			=> l_post_data.information49		,
			p_information40			=> l_post_data.information40		,
			p_information41			=> l_post_data.information41		,
			p_information42			=> l_post_data.information42		,
			p_information43			=> l_post_data.information43		,
			p_information44			=> l_post_data.information44		,
			p_information45			=> l_post_data.information45		,
			p_information46			=> l_post_data.information46		,
			p_information50			=> l_post_data.information50		,
			p_information51			=> l_post_data.information51		,
			p_information52			=> l_post_data.information52		,
			p_information53			=> l_post_data.information53		,
			p_information54			=> l_post_data.information54		,
			p_information55			=> l_post_data.information55		,
			p_information56			=> l_post_data.information56		,
			p_information57			=> l_post_data.information57		,
			p_information58			=> l_post_data.information58		,
			p_information59			=> l_post_data.information59		,
			p_information60			=> l_post_data.information60		,
			p_information61			=> l_post_data.information61		,
			p_information62			=> l_post_data.information62		,
			p_information63			=> l_post_data.information63		,
			p_information64			=> l_post_data.information64		,
			p_information65			=> l_post_data.information65		,
			p_information66			=> l_post_data.information66		,
			p_information67			=> l_post_data.information67		,
			p_information68			=> l_post_data.information68		,
			p_information69			=> l_post_data.information69		,
			p_information70			=> l_post_data.information70		,
			p_information71			=> l_post_data.information71		,
			p_information72			=> l_post_data.information72		,
			p_information73			=> l_post_data.information73		,
			p_information74			=> l_post_data.information74		,
			p_information75			=> l_post_data.information75		,
			p_information76			=> l_post_data.information76		,
			p_information77			=> l_post_data.information77		,
			p_information78			=> l_post_data.information78		,
			p_information79			=> l_post_data.information79		,
			p_information80			=> l_post_data.information80		,
			p_information81			=> l_post_data.information81		,
			p_information82			=> l_post_data.information82		,
			p_information83			=> l_post_data.information83		,
			p_information84			=> l_post_data.information84		,
			p_information85			=> l_post_data.information85		,
			p_information86			=> l_post_data.information86		,
			p_information87			=> l_post_data.information87		,
			p_information88			=> l_post_data.information88		,
			p_information89			=> l_post_data.information89		,
			p_information90			=> l_post_data.information90		,
			p_information91			=> l_post_data.information91		,
			p_information92			=> l_post_data.information92		,
			p_information93			=> l_post_data.information93		,
			p_information94			=> l_post_data.information94		,
			p_information95			=> l_post_data.information95		,
			p_information96			=> l_post_data.information96		,
			p_information97			=> l_post_data.information97		,
			p_information98			=> l_post_data.information98		,
			p_information99			=> l_post_data.information99		,
			p_information100			=> l_post_data.information100		,
			p_information101			=> l_post_data.information101		,
			p_information102			=> l_post_data.information102		,
			p_information103			=> l_post_data.information103		,
			p_information104			=> l_post_data.information104		,
			p_information105			=> l_post_data.information105		,
			p_information106			=> l_post_data.information106		,
			p_information107			=> l_post_data.information107		,
			p_information108			=> l_post_data.information108		,
			p_information109			=> l_post_data.information109		,
			p_information110			=> l_post_data.information110		,
			p_information111			=> l_post_data.information111		,
			p_information112			=> l_post_data.information112		,
			p_information113			=> l_post_data.information113		,
			p_information114			=> l_post_data.information114		,
			p_information115			=> l_post_data.information115		,
			p_information116			=> l_post_data.information116		,
			p_information117			=> l_post_data.information117		,
			p_information118			=> l_post_data.information118		,
			p_information119			=> l_post_data.information119		,
			p_information120			=> l_post_data.information120		,
			p_information121			=> l_post_data.information121		,
			p_information122			=> l_post_data.information122		,
			p_information123			=> l_post_data.information123		,
			p_information124			=> l_post_data.information124		,
			p_information125			=> l_post_data.information125		,
			p_information126			=> l_post_data.information126		,
			p_information127			=> l_post_data.information127		,
			p_information128			=> l_post_data.information128		,
			p_information129			=> l_post_data.information129		,
			p_information130			=> l_post_data.information130		,
			p_information131			=> l_post_data.information131		,
			p_information132			=> l_post_data.information132		,
			p_information133			=> l_post_data.information133		,
			p_information134			=> l_post_data.information134		,
			p_information135			=> l_post_data.information135		,
			p_information136			=> l_post_data.information136		,
			p_information137			=> l_post_data.information137		,
			p_information138			=> l_post_data.information138		,
			p_information139			=> l_post_data.information139		,
			p_information140			=> l_post_data.information140		,
			p_information141			=> l_post_data.information141		,
			p_information142			=> l_post_data.information142		,
			p_information143			=> l_post_data.information143		,
			p_information144			=> l_post_data.information144		,
			p_information145			=> l_post_data.information145		,
			p_information146			=> l_post_data.information146		,
			p_information147			=> l_post_data.information147		,
			p_information148			=> l_post_data.information148		,
			p_information149			=> l_post_data.information149		,
			p_information150			=> l_post_data.information150		,
			p_information151			=> l_post_data.information151		,
			p_information152			=> l_post_data.information152		,
			p_information153			=> l_post_data.information153		,
			p_information154			=> l_post_data.information154		,
			p_information155			=> l_post_data.information155		,
			p_information156			=> l_post_data.information156		,
			p_information157			=> l_post_data.information157		,
			p_information158			=> l_post_data.information158		,
			p_information159			=> l_post_data.information159		,
			p_information160			=> l_post_data.information160		,
			p_information161			=> l_post_data.information161		,
			p_information162			=> l_post_data.information162		,
			p_information163			=> l_post_data.information163		,
			p_information164			=> l_post_data.information164		,
			p_information165			=> l_post_data.information165		,
			p_information166			=> l_post_data.information166		,
			p_information167			=> l_post_data.information167		,
			p_information168			=> l_post_data.information168		,
			p_information169			=> l_post_data.information169		,
			p_information170			=> l_post_data.information170		,
			p_information171			=> l_post_data.information171		,
			p_information172			=> l_post_data.information172		,
			p_information173			=> l_post_data.information173		,
			p_information174			=> l_post_data.information174		,
			p_information175			=> l_post_data.information175		,
			p_information176			=> l_post_data.information176		,
			p_information177			=> l_post_data.information177		,
			p_information178			=> l_post_data.information178		,
			p_information179			=> l_post_data.information179		,
			p_information180			=> l_post_data.information180		,
			p_information181			=> l_post_data.information181		,
			p_information182			=> l_post_data.information182		,
			p_information183			=> l_post_data.information183		,
			p_information184			=> l_post_data.information184		,
			p_information185			=> l_post_data.information185		,
			p_information186			=> l_post_data.information186		,
			p_information187			=> l_post_data.information187		,
			p_information188			=> l_post_data.information188		,
			p_information189			=> l_post_data.information189		,
			p_information190			=> l_post_data.information190		,
			p_information191			=> l_post_data.information191		,
			p_information192			=> l_post_data.information192		,
			p_information193			=> l_post_data.information193		,
			p_information194			=> l_post_data.information194		,
			p_information195			=> l_post_data.information195		,
			p_information196			=> l_post_data.information196		,
			p_information197			=> l_post_data.information197		,
			p_information198			=> l_post_data.information198		,
			p_information199			=> l_post_data.information199		,
			p_information200			=> l_post_data.information200
		);
		-- we stored pa_history id into local variable, put it into the record now.
		l_post_data.pa_history_id := pa_history_id;
		if lower(g_operation_info(indx).table_name) not in
				(lower(ghr_history_api.g_eleevl_table),
				 lower(ghr_history_api.g_eleent_table),
				 lower(ghr_history_api.g_perana_table)) then
			-- this is the normal case for most of the tables we are tracking.

		hr_utility.set_location(l_proc || ' g_do_not_cascade ' || ghr_ses_conv_pkg.g_do_not_cascade, 76);

             if nvl(ghr_ses_conv_pkg.g_do_not_cascade,'N') <> 'Y' then
			ghr_history_cascade.Cascade_History_Data(
				p_table_name		=> upper(g_operation_info(indx).table_name),
				p_person_id 		=> l_session_var.person_id,
				p_pre_record		=> l_pre_record,
				p_post_record		=> l_post_data,
				p_cascade_type		=> 'retroactive',
				p_interv_on_table		=> l_interv_on_table,
				p_interv_on_eff_date 	=> l_interv_on_eff_date,
				p_hist_data_as_of_date	=> l_hist_data_as_of_date
			);
                    end if;
		elsif (lower(g_operation_info(indx).table_name) = lower(ghr_history_api.g_eleevl_table)) then
			-- PAY_ELEMENT_ENTRY_VALUES_F is a special case and needs to be handled differently.
			-- Cascade need not be performed for PAY_ELEMENT_ENTRY_VALUES_F,
			-- as it has only one column value so a record will be created only
			-- if the value changes thur sf52 or any other process which need not be
			-- cascaded. But if more than one sf52s were applied on the same date then
			-- we need to update the row with the most recent value.

			-- retrieve the currently effective eleevl row from history and re-apply it to the
			-- core table if necessary.

			-- get the row from ghr_pa_history for this element_entry_value given the effective date
			-- of this action.
 			ghr_history_fetch.get_date_eff_eleevl(
				p_element_entry_value_id	=>	to_number(l_post_data.information1)	,
				p_date_effective			=>	l_post_data.effective_date	,
				p_element_entry_data		=>	l_eleevl_data				,
				p_result_code			=>	l_return_status				,
				p_pa_history_id			=>	l_pa_history_id);
			if (l_return_status is not null) then
				-- this should never happen, but just in case
				hr_utility.set_location('ERROR: no date effective row found in history' || l_proc, 38);
			      hr_utility.set_message(8301,'GHR_38360_NO_RECFND_FOR_DATE');
	     			hr_utility.raise_error;
			end if;
			ghr_history_conv_rg.conv_element_entval_rg_to_hist(
						p_element_entval_data   => l_eleevl_data,
						p_history_data   		=> l_eleevl_hist_data );
			-- check if the element_entry_value from history is different than what we just changed in the core table.
			-- if it is, then there were intervening records on the same date. So, re-apply the date-effective row from history.
			if (l_post_data.information6 <> l_eleevl_hist_data.information6) then
				-- there were intervening records on the same date. So, re-apply the date-effective row from history.
				ghr_corr_canc_sf52.update_eleentval(	p_hist_pre	=>	l_eleevl_hist_data);
			end if;
		else
			-- PAY_ELEMENT_ENTRIES_F, PER_PERSON_ANALYSES (ghr_history_api.g_eleent_table and g_perana_table)
			-- need not be cascaded or updated with
			-- most recent values because they will only ever be inserted by non-correction sf52's. They
			-- will never be updated by non-correction sf52's. Correction's that update these tables
			-- are already handled correctly.
			null;
		end if;

		if l_interv_on_table then
			-- if changes were cascaded in the history table then we may have to cascade
			-- changes in database tables
		hr_utility.set_location(l_proc || ' g_do_not_cascade ' || ghr_ses_conv_pkg.g_do_not_cascade, 78);

       if nvl(ghr_ses_conv_pkg.g_do_not_cascade,'N') <> 'Y' then
			IF NVL(l_post_data.information5,'N') <> 'GHR_US_RETAINED_GRADE' then -- Bug 2715828/3021003
				-- NO need to cascade for Retained Grade.
				ghr_history_cascade.Cascade_appl_table_Data (
					p_table_name		=> upper(g_operation_info(indx).table_name),
					p_person_id 		=> l_session_var.person_id,
					p_pre_record		=> l_pre_record,
					p_post_record		=> l_post_data,
					p_cascade_type		=> 'retroactive',
					p_interv_on_table		=> l_interv_on_table,
					p_interv_on_eff_date 	=> l_interv_on_eff_date,
					p_hist_data_as_of_date	=> l_hist_data_as_of_date
				);
			END IF;  -- IF NVL(l_post_data.information5,'N') <> 'GHR_US_RE....
       end if;
		end if;
       end if;

	indx := indx + 1;
	END LOOP;
	hr_utility.set_location(l_proc, 15);

	/* 	set fire_trigger to Y. Cascading is complete. All triggers should be set to fire again. */
	get_g_session_var (l_session_var);
	l_session_var.fire_trigger := 'Y';
	set_g_session_var (l_session_var);
END post_update_process;

Procedure Post_forms_commit_process( p_eff_date in date) is
	l_session_var	g_session_var_type;
Begin
    hr_utility.set_location('Entering GHR_HISTORY_API.Post_forms_commit_process',1729);
/*Start Bug:7529592 */
    get_g_session_var (l_session_var);

    IF(p_eff_date <> l_session_var.date_effective) THEN
         l_session_var.date_effective:=p_eff_date;
         set_g_session_var(l_session_var);
    END IF;
/*End Bug:7529592 */
	-- Set ghr_api.g_api_dml to  TRUE to bypass Position and Person EI validation
	-- trigger to be fired. This must be set only before post_update_process and
	-- not in the form so that validation trigger gets fired for the first time
	-- but not at the time of cascacade.
	ghr_api.g_api_dml	:= TRUE;

	Post_update_process;
	reinit_g_session_var;

	ghr_api.g_api_dml	:= FALSE;
	new_form_instance_process;
    hr_utility.set_location('Leaving GHR_HISTORY_API.Post_forms_commit_process',1729);

end post_forms_commit_process;

Procedure New_form_instance_process is
	l_session_var	g_session_var_type;
Begin

	reinit_g_session_var;
	l_session_var.program_name := 'core';
	l_session_var.fire_trigger := 'Y';
	set_g_session_var(l_session_var);


end new_form_instance_process;

-- ---------------------------------------------------------------------------
-- |--------------------------< get_session_date >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--	Gets the effective date for the current database session.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--
-- Post Success:
--	p_sess_date will contain the effective_date for the current session.
--
-- Post Failure:
--   	Throws exception if effective_date not found.
--
-- Developer Implementation Notes:
--   	None
--
-- Access Status:
--   	Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure get_session_date ( p_sess_date out nocopy     date) is
   l_proc  varchar2(30);
   cursor c_getsessdate is
   select trunc(effective_date)
           from fnd_sessions
           where session_id = (select userenv('sessionid')
                                           from dual);
Begin
   open c_getsessdate;
   fetch c_getsessdate into p_sess_date;
   if c_getsessdate%notfound then
		close c_getsessdate;
		hr_utility.set_message(8301, 'GHR_SESSION_DATE_NOT_FND');
		hr_utility.raise_error;
   end if;
   close c_getsessdate ;
End get_session_date ;

end GHR_HISTORY_API;

/
