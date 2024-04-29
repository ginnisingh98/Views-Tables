--------------------------------------------------------
--  DDL for Package Body GHR_HISTORY_CASCADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_HISTORY_CASCADE" as
/* $Header: ghcascad.pkb 120.0.12010000.3 2009/07/14 10:29:48 vmididho ship $ */
--
-- forward declare all local procedures/functions
Procedure Cascade_People (
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype
);

Procedure Cascade_asgn (
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype
);

Procedure Cascade_peopleei (
	p_post_record	in	ghr_pa_history%rowtype
);

Procedure Cascade_asgnei (
	p_post_record	in	ghr_pa_history%rowtype);

Procedure Cascade_posnei (
	p_post_record	in	ghr_pa_history%rowtype
	);

/*
Procedure Cascade_posn (
	p_post_record	in	ghr_pa_history%rowtype
	);
*/

Procedure Cascade_posn (
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype
);

Procedure Cascade_perana (
	p_post_record	in	ghr_pa_history%rowtype
	);

Procedure Cascade_addresses (
	p_post_record	in	ghr_pa_history%rowtype	);

Procedure correct_people_row (
	p_people_data in out nocopy per_all_people_f%rowtype);

Procedure correct_asgn_row (
	p_asgn_data	in out nocopy per_all_assignments_f%rowtype);

Procedure correct_peopleei_row ( p_peopleei_data	in out nocopy per_people_extra_info%rowtype);

Procedure correct_addresses_row( p_addr_data	in out nocopy per_addresses%rowtype);

Procedure correct_perana_row( p_perana_data	in out nocopy per_person_analyses%rowtype);

Procedure Correct_posnei_row (p_posnei_data in out nocopy per_position_extra_info%rowtype);

Procedure Correct_posn_row (p_posn_data in out nocopy hr_all_positions_f%rowtype);

Procedure Correct_asgnei_row (
	p_asgnei_data in out nocopy per_assignment_extra_info%rowtype);

Procedure cascade_change( p_pre_record           in     ghr_pa_history%rowtype,
			        p_post_record          in     ghr_pa_history%rowtype,
			        p_apply_record         in out nocopy ghr_pa_history%rowtype,
				  p_true_false           in out nocopy ghr_history_cascade.condition_rg_type
                        );

Procedure cascade_field_value( p_pre_field               in     ghr_pa_history.information1%type,
				       p_post_field              in     ghr_pa_history.information1%type,
					 p_apply_field             in out nocopy ghr_pa_history.information1%type,
					 p_result                  in out nocopy    boolean
				     );


Function Stop_cascade( p_true_false    ghr_history_cascade.condition_rg_type
                     ) Return boolean;


Procedure cascade_dependencies( p_record         in     ghr_pa_history%rowtype,
                                p_apply_record   in out nocopy ghr_pa_history%rowtype
                             );

Procedure Fetch_most_recent_record(
		p_table_name 	 in	varchar2,
		p_table_pk_id	 in	varchar2,
		p_person_id		 in	number,
		p_history_data in out nocopy 	ghr_pa_history%rowtype,
		p_result_code  in out nocopy varchar2
);

FUNCTION cascade_pa_req_field(p_refresh_field		in out nocopy varchar2,
					 p_shadow_field		in out nocopy varchar2,
					 p_sf52_field		in out nocopy varchar2,
					p_changed			in out nocopy boolean) return boolean;

FUNCTION cascade_pa_req_field(p_refresh_field  in out nocopy  date,
					p_shadow_field  in out nocopy  date,
					p_sf52_field    in out nocopy  date,
					p_changed		in out nocopy boolean) return boolean;

PROCEDURE copy_pa_req_field(	p_refresh_field in out nocopy  date,
					p_sf52_field    in out nocopy  date,
					p_changed	    in out nocopy 	boolean) ;

PROCEDURE copy_pa_req_field(	p_refresh_field in out nocopy  varchar2,
					p_sf52_field    in out nocopy  varchar2,
					p_changed	    in out nocopy 	boolean) ;
-- end of forward declare of local procedures/functions

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_history_data>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in ghr_pa_history table. If changes
--	have been made to a table and there were changes following it, this procedure
--	will correctly 'cascade' those changes to all following records.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_table_name		->	name of the table that this cascade is for.
--	p_person_id			->	person_id that this record is associated with.
--	p_pre_record		->	old value of row that has been changed by current sf52.
--	p_post_record		->	new value of row that has been changed by current sf52.
--	p_cascade_type		->	either 'retroactive' or cancel.
--	p_interv_on_table		->	output flag that indicates if there are any following records for this change.
--	p_interv_on_eff_date 	->	output flag that indicates if there are any following records on the same
--						date for this change.
--	p_hist_data_as_of_date	->	output data from history for the effective date of this action.
--
-- Post Success:
-- 	All data will have been cascaded to all following rows.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Cascade_History_data ( p_table_name		in	varchar2,
                                 p_person_id		in	varchar2,
				         p_pre_record		in	ghr_pa_history%rowtype,
 					   p_post_record        in	ghr_pa_history%rowtype,
					   p_cascade_type		in	varchar2,
					   p_interv_on_table out nocopy   boolean,
					   p_interv_on_eff_date out nocopy   boolean,
   					   p_hist_data_as_of_date	 out nocopy ghr_pa_history%rowtype )
is

	l_session_var	ghr_history_api.g_session_var_type;
	l_proc		varchar2(72) := 'Cascade_History_data';
	l_record_data	ghr_pa_history%rowtype;
	l_true_false	ghr_history_cascade.condition_rg_type;
	l_stop		boolean;
	l_num			number := 1;
	l_history_id	number;
	l_root_pa_history_id	ghr_pa_history.pa_history_id%type;
	l_root_pa_request_id	ghr_pa_history.pa_request_id%type;
	l_cascade_history		ghr_pa_history%rowtype;


-- To cascade changes in the history table, we need to fetch the history_ids in the exact order
-- in which changes have to be applied. For eg.
--  History_id     pa_request_id   altered_pa_request_id  effective_date
--
--    1              1                                       13-JUL-1997
--    2              2                                       15-JUL-1997
--    3              3                                       16-JUL-1997
--    4              4                                       17-JUL-1997
--    5              5                        2              16-JUL-1997
--    6              6                        5              16-JUL-1997
--    7              7                        4              17-JUL-1997
--    8              8                                       14-JUL-1997
--
--    Assuming that pa_request_id 8, corresponds to a retroaction, the foll. is the logic to
--    fetch other records to be cascaded.
--    Fetch only those records with effective_date > 14-JUL-1997, and the order in which they have
--    to  be cascaded is
--    2, followed by its correction 5,6
--    3
--    4  followed by its correction 7
--   To do this we first fetch all the history_ids which have null altered_pa_request_id
--   Then run a nested fetch to select all child records of the already fetched history_records one after the other.
--   cursor to fetch those history_ids from ghr_pa_history, which will be used as the root

--   Cursor to select all root history_ids

	Cursor c_history(c_table_name     varchar2,
                       c_information1   varchar2,
                       c_person_id      number,
                       c_effective_date date,
                       c_root_hist_id     number)
	is
		select PAH.*
		from ghr_pa_history pah
		where
		(table_name = c_table_name and information1 = c_information1 and nvl(person_id, -1) = nvl(c_person_id,-1)) and
		((effective_date = c_effective_date and
		(( c_root_hist_id < pah.pa_history_id and pah.pa_request_id is null)	or
		(pah.pa_request_id is not null and pah.altered_pa_request_id is null and c_root_hist_id <
		(select min(pa_history_id) from ghr_pa_history where pa_request_id = pah.pa_request_id
		and nature_of_action_id = pah.nature_of_action_id))			or
		(altered_pa_request_id is not null and c_root_hist_id <
				(select min(pa_history_id) from ghr_pa_history pah2
				 where pa_request_id = (select min(pa_request_id) from ghr_pa_requests
								connect by pa_request_id = prior altered_pa_request_id
								start with pa_request_id = pah.pa_request_id) and
										nature_of_action_id = pah.nature_of_action_id and
										not exists (select 'exists'
												from ghr_pa_history pah3
												where pah3.pa_request_id = pah.altered_pa_request_id and
													table_name = c_table_name and
													information1 = c_information1
													and pah3.nature_of_action_id = pah.nature_of_action_id)
												)
								)
					)) OR
		(effective_date > c_effective_date and
		((pah.pa_request_id is null) or
		(pah.pa_request_id is not null and pah.altered_pa_request_id is null) or
		(pah.altered_pa_request_id is not null and not exists
				(select 'exists'
				from ghr_pa_history pah4
				where pah4.pa_request_id = pah.altered_pa_request_id
				and table_name = c_table_name
				and information1	= c_information1
				and pah4.nature_of_action_id = pah.nature_of_action_id)))))
		order by effective_date , pa_history_id;


-- Cursor to fetch history_id in the order in which changes are to be cascaded.
	Cursor c_cascade_history(c_table_name    varchar2,
                               c_information1  varchar2,
                               c_person_id     number,
                               c_history_id    number,
                               c_noa_id        number,
					 c_pa_request_id number)
     is
		Select      pah.*
		from        ghr_pa_history pah
		where       table_name              = c_table_name
		and         information1            = c_information1
--		and         person_id               = c_person_id
-- see comments in the cursor c_history
		and		pa_request_id in
					(select pa_request_id
					 from ghr_pa_requests
					 start with pa_request_id 		= c_pa_request_id
					 connect by prior pa_request_id	= altered_pa_request_id)
		and  nature_of_action_id   = c_noa_id
		order by 	pa_history_id;
	-- This cursor will retrieve the real root history id of a correction chain.
	-- i.e. - The root NOA independent of any particular table or row change.
	cursor get_root_hist_id(cp_pa_history_id	in	number) is
		select min(pa_history_id)
		from ghr_pa_history
		where pa_request_id =
			(select 	min(pa_request_id)
			from 		ghr_pa_requests
			connect by 	pa_request_id 		= prior altered_pa_request_id
			start with 	pa_request_id 		= 	(select 	pa_request_id
										from 		ghr_pa_history
										where 	pa_history_id = cp_pa_history_id))
		AND	nature_of_action_id			= 	(select 	nature_of_action_id
										from 		ghr_pa_history
										where 	pa_history_id = cp_pa_history_id);

begin
      hr_utility.set_location('Entering  '|| l_proc,5);
      hr_utility.set_location('p_table_name  '|| p_table_name || l_proc,5);
      hr_utility.set_location('p_cascade_type  '|| p_cascade_type || l_proc,5);

	p_interv_on_eff_date	:=  FALSE;
	p_interv_on_table  	:=  FALSE;

	ghr_history_api.get_g_session_var( l_session_var);

	-- Initialize the true_false table with TRUE
	-- Since only information 4 thru' information101 can be cascaded
      hr_utility.set_location(l_proc,10);
	For rowno in 7..101 loop   -- Bug 1161542 changed 4..101 to 7..101
    		l_true_false(rowno) := TRUE;
	End loop;
      hr_utility.set_location(l_proc,15);
      hr_utility.set_location('p_post_record.pa_history_id: ' || p_post_record.pa_history_id || l_proc,2004);
      hr_utility.set_location('p_post_record.information1: ' || p_post_record.information1 || l_proc,2006);
      hr_utility.set_location('p_post_record.person_id: ' || p_post_record.person_id || l_proc,2007);
      hr_utility.set_location('p_post_record.effective_date: ' || p_post_record.effective_date || l_proc,2008);
      hr_utility.set_location('p_post_record.information9: ' || p_post_record.information9 || l_proc,2013);
      hr_utility.set_location('p_post_record.information10: ' || p_post_record.information10 || l_proc,2014);
      hr_utility.set_location('p_post_record.information11: ' || p_post_record.information11 || l_proc,2015);
      hr_utility.set_location('p_post_record.information12: ' || p_post_record.information12 || l_proc,2016);
      hr_utility.set_location('p_post_record.information13: ' || p_post_record.information13 || l_proc,2017);
      hr_utility.set_location('p_post_record.information14: ' || p_post_record.information14 || l_proc,2018);

      hr_utility.set_location('p_pre_record.pa_request_id: ' || p_pre_record.pa_request_id || l_proc,2008);
      hr_utility.set_location('p_pre_record.pa_history_id: ' || p_pre_record.pa_history_id || l_proc,2009);
      hr_utility.set_location('p_pre_record.information1: ' || p_pre_record.information1 || l_proc,2010);
      hr_utility.set_location('p_pre_record.person_id: ' || p_pre_record.person_id || l_proc,2011);
      hr_utility.set_location('p_pre_record.effective_date: ' || p_pre_record.effective_date || l_proc,2012);
      hr_utility.set_location('p_pre_record.information9: ' || p_pre_record.information9 || l_proc,2019);
      hr_utility.set_location('p_pre_record.information10: ' || p_pre_record.information10 || l_proc,2020);
      hr_utility.set_location('p_pre_record.information11: ' || p_pre_record.information11 || l_proc,2021);
      hr_utility.set_location('p_pre_record.information12: ' || p_pre_record.information12 || l_proc,2022);
      hr_utility.set_location('p_pre_record.information13: ' || p_pre_record.information13 || l_proc,2023);
      hr_utility.set_location('p_pre_record.information14: ' || p_pre_record.information14 || l_proc,2024);

	if (p_post_record.pa_request_id is null) then
	      hr_utility.set_location('gh: ' || l_proc,1000);
		--this is a core change, set root pa_history_id is the pa_history_id itself.
		l_root_pa_history_id := p_post_record.pa_history_id;
	else
	      hr_utility.set_location('gh: ' || l_proc,1001);
		open get_root_hist_id(cp_pa_history_id	=> p_post_record.pa_history_id);
	      hr_utility.set_location('gh: ' || l_proc,1002);
		fetch get_root_hist_id into l_root_pa_history_id;
	      hr_utility.set_location('gh: ' || l_proc,1003);
		if l_root_pa_history_id is null then
			close get_root_hist_id;
  			hr_utility.set_message(8301,'GHR_38490_ROOT_HISTID_NFND');
	      	hr_utility.raise_error;
		end if;
		close get_root_hist_id;
	end if;
      hr_utility.set_location('gh: ' || l_proc,1005);
      hr_utility.set_location('l_root_pa_history_id: ' || l_root_pa_history_id || l_proc,2003);
      hr_utility.set_location('p_post_record.information1: ' || p_post_record.information1 || l_proc,4010);
      hr_utility.set_location('p_post_record.person_id : ' || p_post_record.person_id || l_proc,4011);
      hr_utility.set_location('p_table_name: ' || p_table_name || l_proc,4012);
      hr_utility.set_location('p_post_record.effective_date ' || p_post_record.effective_date || l_proc,2013);

	-- Retrieve all root history_ids
	For history_data in c_history(p_table_name,
      		                  p_post_record.information1,
                  		      p_post_record.person_id,
                              	P_post_record.effective_date,
						l_root_pa_history_id
	                              ) loop
		l_history_id  :=  history_data.pa_history_id;
            hr_utility.set_location(l_proc,20);
            hr_utility.set_location('l_history_id: ' || l_history_id || l_proc,2002);
      hr_utility.set_location('l_root_pa_history_id: ' || l_root_pa_history_id || l_proc,2003);
      hr_utility.set_location('p_post_record.information1: ' || p_post_record.information1 || l_proc,4010);
      hr_utility.set_location('p_post_record.person_id : ' || p_post_record.person_id || l_proc,4011);
      hr_utility.set_location('p_table_name: ' || p_table_name || l_proc,4012);
      hr_utility.set_location('history_data.pa_history_id : ' || history_data.pa_history_id || l_proc,4019);
      hr_utility.set_location('history_data.nature_of_action_id : ' || history_data.nature_of_action_id || l_proc,4020);
	hr_utility.set_location('history_data.pa_request_id : ' || history_data.pa_request_id || l_proc,4021);

		-- If any record is retrieved then set p_interv_on_table to TRUE
		p_interv_on_table := TRUE;
		if (history_data.pa_request_id is not null) then
			-- non core change, open cursor to
			-- retrieve all subsequent child records in the order of correction, of the root history_id
			open c_cascade_history(	p_table_name,
	     	        				p_post_record.information1,
				                  p_post_record.person_id ,
				                  history_data.pa_history_id,
				                  history_data.nature_of_action_id,
							history_data.pa_request_id
					           );
		end if;
		LOOP
			-- note that there are two exit locations for this loop. This is the first. It
			-- is meant to handle non-core changes. The second appears at the end of the loop and
			-- is meant to handle core changes.
			if (history_data.pa_request_id is not null) then
				-- non core change, fetch cursor.
				fetch c_cascade_history into l_record_data;
				if c_cascade_history%NOTFOUND then
					exit;
				end if;
			else
				--core change
				l_record_data := history_data;
			end if;
                  hr_utility.set_location(l_proc,25);
	            hr_utility.set_location('l_record_data.pa_history_id: ' || l_record_data.pa_history_id || l_proc,2005);
      hr_utility.set_location('l_record_data.information1: ' || l_record_data.information1 || l_proc,3010);
      hr_utility.set_location('l_record_data.person_id: ' || l_record_data.person_id || l_proc,3011);
      hr_utility.set_location('l_record_data.effective_date: ' || l_record_data.effective_date || l_proc,3012);
      hr_utility.set_location('l_record_data.information9: ' || l_record_data.information9 || l_proc,3019);
      hr_utility.set_location('l_record_data.information10: ' || l_record_data.information10 || l_proc,3020);
      hr_utility.set_location('l_record_data.information11: ' || l_record_data.information11 || l_proc,3021);
      hr_utility.set_location('l_record_data.information12: ' || l_record_data.information12 || l_proc,3022);
      hr_utility.set_location('l_record_data.information13: ' || l_record_data.information13 || l_proc,3023);
      hr_utility.set_location('l_record_data.information14: ' || l_record_data.information14 || l_proc,3024);

			if l_record_data.effective_date = l_session_var.date_effective then
				p_interv_on_eff_date := TRUE;
				p_hist_data_as_of_date := l_record_data;
			end if;

			-- If cascade_type is 'retroactive' the new changes by the current SF52, which is the
			--  post_record in the history has to be cascaded to all the above fetched records from history
			if lower(p_cascade_Type)    = 'retroactive' then

                        hr_utility.set_location(l_proc,30);
				cascade_Change(p_pre_record   => p_Pre_record,
                                       p_post_record  => p_Post_record,
                                       p_apply_record => l_record_data,
                                       p_true_false   => l_true_false
                                       );
                        hr_utility.set_location(l_proc,35);

			elsif lower(p_cascade_Type) = 'cancel' then

                        hr_utility.set_location(l_proc,40);
				cascade_Change(p_pre_record   => p_Post_record,
                                       p_post_record  => p_Pre_record,
                                       p_apply_record => l_record_data,
                                       p_true_false   => l_true_false
                                      );
                        hr_utility.set_location(l_proc,45);

			else
                        hr_utility.set_location(l_proc,50);
				hr_utility.set_message(8301, 'GHR_38225_UNKNOWN_CASCADE_TYPE');
				hr_utility.raise_error;
				--	raise error /* Unknown type */
			end if;
      hr_utility.set_location('l_record_data.pa_history_id: ' || l_record_data.pa_history_id || l_proc,2009);
      hr_utility.set_location('l_record_data.information1: ' || l_record_data.information1 || l_proc,2010);
      hr_utility.set_location('l_record_data.person_id: ' || l_record_data.person_id || l_proc,2011);
      hr_utility.set_location('l_record_data.effective_date: ' || l_record_data.effective_date || l_proc,2012);
      hr_utility.set_location('l_record_data.information9: ' || l_record_data.information9 || l_proc,2019);
      hr_utility.set_location('l_record_data.information10: ' || l_record_data.information10 || l_proc,2020);
      hr_utility.set_location('l_record_data.information11: ' || l_record_data.information11 || l_proc,2021);
      hr_utility.set_location('l_record_data.information12: ' || l_record_data.information12 || l_proc,2022);
      hr_utility.set_location('l_record_data.information13: ' || l_record_data.information13 || l_proc,2023);
      hr_utility.set_location('l_record_data.information14: ' || l_record_data.information14 || l_proc,2024);
			-- update history record  with changes to be cascaded :
                 	hr_utility.set_location(l_proc,80);
			ghr_pah_upd.upd
			(
			p_pa_history_id                        =>  l_record_data.pa_history_id,
			p_pa_request_id                        =>  l_record_data.pa_request_id,
			p_process_date                         =>  l_record_data.process_date,
			p_nature_of_action_id                  =>  l_record_data.nature_of_action_id,
			P_effective_date                       =>  l_record_data.effective_date,
			p_altered_pa_request_id                =>  l_record_data.altered_pa_request_id,
			p_person_id                            =>  l_record_data.person_id,
			p_assignment_id                        =>  l_record_data.assignment_id,
			p_dml_operation                  	   =>  l_record_data.dml_operation,
			p_table_name                           =>  l_record_data.table_name,
			p_pre_values_flag                      =>  l_record_data.pre_values_flag,
			p_information1                         =>  l_record_data.information1,
			p_information2                         =>  l_record_data.information2,
			p_information3                         =>  l_record_data.information3,
			p_information4                         =>  l_record_data.information4,
			p_information5                         =>  l_record_data.information5,
			p_information6                         =>  l_record_data.information6,
			p_information7                         =>  l_record_data.information7,
			p_information8                         =>  l_record_data.information8,
			p_information9                         =>  l_record_data.information9,
			p_information10                        =>  l_record_data.information10,
			p_information11                        =>  l_record_data.information11,
			p_information12                        =>  l_record_data.information12,
			p_information13                        =>  l_record_data.information13,
			p_information14                        =>  l_record_data.information14,
			p_information15                        =>  l_record_data.information15,
			p_information16                        =>  l_record_data.information16,
			P_information17                        =>  l_record_data.information17,
			p_information18                        =>  l_record_data.information18,
			p_information19                        =>  l_record_data.information19,
			P_information20                        =>  l_record_data.information20,
		      p_information21                        =>  l_record_data.information21,
			p_information22                        =>  l_record_data.information22,
			p_information23                        =>  l_record_data.information23,
			p_information24                        =>  l_record_data.information24,
			p_information25                        =>  l_record_data.information25,
			p_information26                        =>  l_record_data.information26,
			p_information27                        =>  l_record_data.information27,
			p_information28                        =>  l_record_data.information28,
			p_information29                        =>  l_record_data.information29,
			p_information30                        =>  l_record_data.information30,
			p_information31                        =>  l_record_data.information31,
			p_information32                        =>  l_record_data.information32,
			p_information33                        =>  l_record_data.information33,
			p_information34                        =>  l_record_data.information34,
			p_information35                        =>  l_record_data.information35,
			p_information36                        =>  l_record_data.information36,
			p_information37                        =>  l_record_data.information37,
			p_information38                        =>  l_record_data.information38,
			p_information39                        =>  l_record_data.information39,
			p_information40                        =>  l_record_data.information40,
			p_information41                        =>  l_record_data.information41,
			p_information42                        =>  l_record_data.information42,
			P_information43   	               =>  l_record_data.information43,
			p_information44                        =>  l_record_data.information44,
			p_information45                        =>  l_record_data.information45,
			p_information46                        =>  l_record_data.information46,
			p_information47                        =>  l_record_data.information47,
			p_information48                        =>  l_record_data.information48,
			p_information49                        =>  l_record_data.information49,
			p_information50                        =>  l_record_data.information50,
			P_information51                        =>  l_record_data.information51,
			p_information52                        =>  l_record_data.information52,
			p_information53                        =>  l_record_data.information53,
			p_information54                        =>  l_record_data.information54,
			p_information55                        =>  l_record_data.information55,
			p_information56                        =>  l_record_data.information56,
			p_information57                        =>  l_record_data.information57,
			p_information58                        =>  l_record_data.information58,
			p_information59                        =>  l_record_data.information59,
			p_information60                        =>  l_record_data.information60,
			p_information61                        =>  l_record_data.information61,
			p_information62   	               =>  l_record_data.information62,
			p_information63                        =>  l_record_data.information63,
			p_information64                        =>  l_record_data.information64,
			p_information65                        =>  l_record_data.information65,
			p_information66                        =>  l_record_data.information66,
			p_information67                        =>  l_record_data.information67,
			p_information68                        =>  l_record_data.information68,
			p_information69                        =>  l_record_data.information69,
			P_information70                        =>  l_record_data.information70,
			p_information71                        =>  l_record_data.information71,
                  p_information72                        =>  l_record_data.information72,
			p_information73                        =>  l_record_data.information73,
			p_information74                        =>  l_record_data.information74,
			p_information75                        =>  l_record_data.information75,
			p_information76                        =>  l_record_data.information76,
			p_information77                        =>  l_record_data.information77,
			p_information78                        =>  l_record_data.information78,
			p_information79                        =>  l_record_data.information79,
			p_information80                        =>  l_record_data.information80,
			p_information81                        =>  l_record_data.information81,
			p_information82                        =>  l_record_data.information82,
			p_information83                        =>  l_record_data.information83,
			p_information84                        =>  l_record_data.information84,
			p_information85                        =>  l_record_data.information85,
			p_information86                        =>  l_record_data.information86,
			p_information87                        =>  l_record_data.information87,
			p_information88                        =>  l_record_data.information88,
			p_information89                        =>  l_record_data.information89,
			p_information90                        =>  l_record_data.information90,
			p_information91                        =>  l_record_data.information91,
			p_information92                        =>  l_record_data.information92,
			p_information93                        =>  l_record_data.information93,
			p_information94                        =>  l_record_data.information94,
			p_information95                        =>  l_record_data.information95,
			p_information96                        =>  l_record_data.information96,
			p_information97                        =>  l_record_data.information97,
			p_information98                        =>  l_record_data.information98,
			p_information99                        =>  l_record_data.information99,
			p_information100                       =>  l_record_data.information100,
			p_information101                       =>  l_record_data.information101,
			p_information102                       =>  l_record_data.information102,
			p_information103                       =>  l_record_data.information103,
			p_information104                       =>  l_record_data.information104,
			p_information105                       =>  l_record_data.information105,
			p_information106                       =>  l_record_data.information106,
			p_information107                       =>  l_record_data.information107,
			p_information108                       =>  l_record_data.information108,
			p_information109                       =>  l_record_data.information109,
			p_information110                       =>  l_record_data.information110,
			p_information111                       =>  l_record_data.information111,
			p_information112                       =>  l_record_data.information112,
			p_information113                       =>  l_record_data.information113,
			p_information114                       =>  l_record_data.information114,
			p_information115                       =>  l_record_data.information115,
			p_information116                       =>  l_record_data.information116,
			p_information117                       =>  l_record_data.information117,
			p_information118                       =>  l_record_data.information118,
			p_information119                       =>  l_record_data.information119,
			p_information120                       =>  l_record_data.information120,
			p_information121                       =>  l_record_data.information121,
			p_information122                       =>  l_record_data.information122,
			p_information123                       =>  l_record_data.information123,
			p_information124                       =>  l_record_data.information124,
			p_information125                       =>  l_record_data.information125,
			p_information126                       =>  l_record_data.information126,
			p_information127                       =>  l_record_data.information127,
			p_information128                       =>  l_record_data.information128,
			p_information129                       =>  l_record_data.information129,
			p_information130                       =>  l_record_data.information130,
			p_information131                       =>  l_record_data.information131,
			p_information132                       =>  l_record_data.information132,
			p_information133                       =>  l_record_data.information133,
			p_information134                       =>  l_record_data.information134,
			p_information135                       =>  l_record_data.information135,
		  	p_information136                       =>  l_record_data.information136,
			p_information137                       =>  l_record_data.information137,
			p_information138                       =>  l_record_data.information138,
			p_information139                       =>  l_record_data.information139,
			p_information140                       =>  l_record_data.information140,
			p_information141                       =>  l_record_data.information141,
			p_information142                       =>  l_record_data.information142,
			p_information143                       =>  l_record_data.information143,
			p_information144                       =>  l_record_data.information144,
			p_information145                       =>  l_record_data.information145,
			p_information146                       =>  l_record_data.information146,
			p_information147                       =>  l_record_data.information147,
			p_information148                       =>  l_record_data.information148,
			p_information149                       =>  l_record_data.information149,
			p_information150                       =>  l_record_data.information150,
			p_information151                       =>  l_record_data.information151,
			p_information152                       =>  l_record_data.information152,
			p_information153                       =>  l_record_data.information153,
			p_information154                       =>  l_record_data.information154,
			p_information155                       =>  l_record_data.information155,
			p_information156                       =>  l_record_data.information156,
			p_information157                       =>  l_record_data.information157,
			p_information158                       =>  l_record_data.information158,
			p_information159                       =>  l_record_data.information159,
			p_information160                       =>  l_record_data.information160,
			p_information161                       =>  l_record_data.information161,
			p_information162                       =>  l_record_data.information162,
			p_information163                       =>  l_record_data.information163,
			p_information164                       =>  l_record_data.information164,
			p_information165                       =>  l_record_data.information165,
			p_information166                       =>  l_record_data.information166,
			p_information167                       =>  l_record_data.information167,
			p_information168                       =>  l_record_data.information168,
			p_information169                       =>  l_record_data.information169,
			p_information170                       =>  l_record_data.information170,
			p_information171                       =>  l_record_data.information171,
			p_information172                       =>  l_record_data.information172,
			p_information173                       =>  l_record_data.information173,
			p_information174                       =>  l_record_data.information174,
			p_information175                       =>  l_record_data.information175,
			p_information176                       =>  l_record_data.information176,
			p_information177                       =>  l_record_data.information177,
			p_information178                       =>  l_record_data.information178,
			p_information179                       =>  l_record_data.information179,
			p_information180                       =>  l_record_data.information180,
			p_information181                       =>  l_record_data.information181,
			p_information182                       =>  l_record_data.information182,
			p_information183                       =>  l_record_data.information183,
			p_information184                       =>  l_record_data.information184,
			p_information185                       =>  l_record_data.information185,
			p_information186                       =>  l_record_data.information186,
			p_information187                       =>  l_record_data.information187,
			p_information188                       =>  l_record_data.information188,
			p_information189                       =>  l_record_data.information189,
			p_information190                       =>  l_record_data.information190,
			p_information191                       =>  l_record_data.information191,
			p_information192                       =>  l_record_data.information192,
			p_information193                       =>  l_record_data.information193,
			p_information194                       =>  l_record_data.information194,
			p_information195                       =>  l_record_data.information195,
			p_information196                       =>  l_record_data.information196,
			p_information197                       =>  l_record_data.information197,
			p_information198                       =>  l_record_data.information198,
			p_information199                       =>  l_record_data.information199,
			p_information200                       =>  l_record_data.information200
			);

			--  Determine whether to continue cascading , which is identified by looking at the
			--  true_false flag for all the columns that can be cascaded,
			--  If all of them are set to false, then stop cascading.

                 	hr_utility.set_location(l_proc,85);
			l_stop  := Stop_cascade(l_true_false);
               	hr_utility.set_location(l_proc,90);
		      If not l_stop  then
				hr_utility.set_location(l_proc,95);
			      exit;
		      End if;
            	hr_utility.set_location(l_proc,95);
			if (history_data.pa_request_id is null) then
				-- core change, only want to do one iteration of this loop.
				exit;
			end if;
		END LOOP; -- End of child loop
		if (history_data.pa_request_id is not null) then
			-- this was not a core change,so we opened this cursor.
			close c_cascade_history;
		end if;
      	hr_utility.set_location(l_proc,100);
	End loop; -- End of root loop
	hr_utility.set_location('Leaving  ' || l_proc,105);
Exception
When Others then
   -- RESET In/Out params and SET Out Params
   p_interv_on_table        :=null;
   p_interv_on_eff_date     :=null;
   p_hist_data_as_of_date   :=null;
hr_utility.set_location('Leaving  ' || l_proc,110);
Raise;

End cascade_history_data;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_appl_table_data>-----------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in corresponding core application table. If changes
--	have been made to a table and there were changes following it, this procedure
--	will correctly 'cascade' those changes to all following records. Note that
--	the actuall application table cascades are handled by calling the appropriate sub-procedure.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_table_name		->	name of the table that this cascade is for.
--	p_person_id			->	person_id that this record is associated with.
--	p_pre_record		->	old value of row that has been changed by current sf52.
--	p_post_record		->	new value of row that has been changed by current sf52.
--	p_cascade_type		->	either 'retroactive' or cancel.
--	p_interv_on_table		->	input flag that indicates if there are any following records for this change.
--	p_interv_on_eff_date 	->	input flag that indicates if there are any following records on the same
--						date for this change.
--	p_hist_data_as_of_date	->	input record that containst the data from history for the effective_date
--						of this action.
--
-- Post Success:
-- 	All data will have been cascaded to all following rows.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

--
-- Procedure Cascade_Appl_table_data calls individual table cascade procedures
Procedure Cascade_Appl_table_data (
	p_table_name			in	varchar2,
	p_person_id 			in	varchar2,
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_table			in	Boolean,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype

) is

	l_proc	varchar2(30):='Cascade_appl_table_data';
Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	if lower(p_table_name) = lower(ghr_history_api.g_peop_table) then
		hr_utility.set_location( l_proc, 20);
		Cascade_People(
			p_pre_record			=> p_pre_record,
			p_post_record			=> p_post_record,
			p_cascade_type			=> p_cascade_type,
			p_interv_on_eff_date		=> p_interv_on_eff_date,
			p_hist_data_as_of_date		=> p_hist_data_as_of_date);

	elsif lower(p_table_name) = lower(ghr_history_api.g_asgn_table) then
		hr_utility.set_location( l_proc, 30);
		Cascade_asgn (
			p_pre_record			=> p_pre_record,
			p_post_record			=> p_post_record,
			p_cascade_type			=> p_cascade_type,
			p_interv_on_eff_date		=> p_interv_on_eff_date,
			p_hist_data_as_of_date		=> p_hist_data_as_of_date);
	elsif lower(p_table_name) = lower(ghr_history_api.g_eleent_table) then
		hr_utility.set_location( l_proc, 40);
		-- this is already handled in cancel/correction procedures
		-- retroactive actions need not cascade change in element_entry
		null;
	elsif lower(p_table_name) = lower(ghr_history_api.g_eleevl_table) then
		hr_utility.set_location( l_proc, 50);
		-- this is already handled in cancel/correction procedures
		-- retroactive actions need not cascade change in element_entry_values
		null;
	elsif lower(p_table_name) = lower(ghr_history_api.g_peopei_table) then
		hr_utility.set_location( l_proc, 60);
		Cascade_peopleei (
			p_post_record	=> p_post_record);
	elsif lower(p_table_name) = lower(ghr_history_api.g_asgnei_table) then
		hr_utility.set_location( l_proc, 70);
		Cascade_asgnei (
			p_post_record	=> p_post_record);
	elsif lower(p_table_name) = lower(ghr_history_api.g_addres_table) then
		hr_utility.set_location( l_proc, 80);
		Cascade_addresses (
			p_post_record	=> p_post_record);
	elsif lower(p_table_name) = lower(ghr_history_api.g_posnei_table) then
		hr_utility.set_location( l_proc, 90);
		Cascade_posnei (
			p_post_record	=> p_post_record);
	elsif lower(p_table_name) = lower(ghr_history_api.g_posn_table) then
		hr_utility.set_location( l_proc, 90);
                /*
		Cascade_posn (
			p_post_record	=> p_post_record);
                */
		Cascade_posn(
			p_pre_record			=> p_pre_record,
			p_post_record			=> p_post_record,
			p_cascade_type			=> p_cascade_type,
			p_interv_on_eff_date		=> p_interv_on_eff_date,
			p_hist_data_as_of_date		=> p_hist_data_as_of_date);

	elsif lower(p_table_name) in 	(lower(ghr_history_api.g_perana_table)) then
		-- This table need not cascade.
		hr_utility.set_location( l_proc, 95);
		Cascade_perana (
			p_post_record	=> p_post_record);
		null;
	else
		hr_utility.set_location( 'Unidentified table ' || l_proc, 100);
		--raise error
		hr_utility.set_message(8301, 'GHR_38363_UNKNOWN_TABLE');
		hr_utility.raise_error;
	end if;
	hr_utility.set_location( 'Leaving : ' || l_proc, 200);

End;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_people>-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_people_f core application table. If the
--	current action made changes to per_people_f and there were changes following it, this procedure
--	will correctly 'cascade' those changes to all following records. This procedure can
--	be called in either 'retroactive' (p_post_record values will be cascaded) or 'cancel'
--	(p_pre_record values will be cascaded) mode.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_person_id			->	person_id that this record is associated with.
--	p_pre_record		->	old value of row that has been changed by current sf52.
--	p_post_record		->	new value of row that has been changed by current sf52.
--	p_cascade_type		->	either 'retroactive' or cancel.
--	p_interv_on_table		->	input flag that indicates if there are any following records for this change.
--	p_interv_on_eff_date 	->	input flag that indicates if there are any following records on the same
--						date for this change.
--	p_hist_data_as_of_date	->	input record that contains the data from history for the effective_date
--						of this action.
--
-- Post Success:
-- 	All data will have been cascaded to all following rows.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cascade_People (
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype
) is

	l_true_false	ghr_history_cascade.condition_rg_type;
	l_people_data	per_all_people_f%rowtype;
	l_hist_peop_data	ghr_pa_history%rowtype;
	l_stop		Boolean;
	l_proc		varchar2(30):='Cascade_People';

	-- this cursor is meant to retrieve all following records in per_people_f table.
	Cursor c_people( c_date_Effective in date, c_person_id	in number) is
	Select *
	from per_all_people_f
	where effective_start_date >= c_date_effective and
	person_id = c_person_id;

Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	For rowno in 4..101 loop
    		l_true_false(rowno) := TRUE;
	End loop;
	hr_utility.set_location( l_proc, 15);
	if p_interv_on_eff_date then
		-- This is to take care of multiple actions on the same date.
		-- When a correction is made to a SF52 and other process had
		-- updated the same row on the same date, the data in the
		-- core table might be incorrect since the date effectivity has the
		-- granularity of a day, and not date and time. So, this will
		-- re-apply the data from history for the effective date of the current action to the
		-- core table. This will insure that the core table will contain the correct information
		-- in all cases.
		hr_utility.set_location( l_proc, 20);
		ghr_history_conv_rg.Conv_to_people_rg(
				p_people_data => l_people_data,
				p_history_data => p_hist_data_as_of_date);
		correct_people_row( p_people_data => l_people_data);
		hr_utility.set_location( l_proc, 30);
	elsif	(lower(p_cascade_type) = 'cancel') then
		-- if this is a cancellation and there are no intervening rows on this effective date,
		-- then apply the pre-record to the core people table for this effective date.
		hr_utility.set_location( l_proc, 35);
		ghr_history_conv_rg.Conv_to_people_rg(
				p_people_data => l_people_data,
				p_history_data => p_pre_record);
		correct_people_row( p_people_data => l_people_data);
	end if;

	hr_utility.set_location( l_proc, 40);
	-- Fetch all the following rows.
	open c_people( p_post_record.effective_date, to_number(p_post_record.information1));
	while true
	Loop
		hr_utility.set_location( l_proc, 50);
		fetch c_people into l_people_data;
		exit when not c_people%found;
		ghr_history_conv_rg.conv_people_rg_to_hist_rg( p_people_data  => l_people_data,
							p_history_data => l_hist_peop_data);

		if lower(p_cascade_Type)    = 'retroactive' then
			hr_utility.set_location( l_proc, 60);
			-- for retroactive action post-record values have to be cascaded
			-- whereever pre-record values exist.
				cascade_Change(p_pre_record   => p_Pre_record,
                                       p_post_record  => p_Post_record,
                                       p_apply_record => l_hist_peop_data,
                                       p_true_false   => l_true_false);

		elsif lower(p_cascade_Type) = 'cancel' then
			-- for cancellation action pre-record values have to be cascaded
			-- whereever post-record values exist.
			hr_utility.set_location( l_proc, 70);
				cascade_Change(p_pre_record   => p_Post_record,
                                       p_post_record  => p_Pre_record,
                                       p_apply_record => l_hist_peop_data,
                                       p_true_false   => l_true_false);
		else
			hr_utility.set_location( l_proc, 80);
		      hr_utility.set_message(8301, 'GHR_38225_UNKNOWN_CASCADE_TYPE');
		      hr_utility.raise_error;
		      --	raise error /* Unknown type */
		end if;

		-- As a column value
		l_stop  := Stop_cascade(l_true_false);
		if not l_stop  then
			hr_utility.set_location( l_proc || ' exit loop ', 90);
		      exit;
		else
			hr_utility.set_location( l_proc, 100);
			ghr_history_conv_rg.conv_to_people_rg(
						p_people_data  => l_people_data,
						p_history_data => l_hist_peop_data);
			correct_people_row( p_people_data => l_people_data);
		end if;
	end loop;
	hr_utility.set_location( l_proc, 200);
	close c_people;
End;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_asgn>---------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_assignments_f core application table. If the
--	current action made changes to per_assignments_f and there were changes following it, this procedure
--	will correctly 'cascade' those changes to all following records. This procedure can
--	be called in either 'retroactive' (p_post_record values will be cascaded) or 'cancel'
--	(p_pre_record values will be cascaded) mode.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pre_record		->	old value of row that has been changed by current sf52.
--	p_post_record		->	new value of row that has been changed by current sf52.
--	p_cascade_type		->	either 'retroactive' or cancel.
--	p_interv_on_table		->	input flag that indicates if there are any following records for this change.
--	p_interv_on_eff_date 	->	input flag that indicates if there are any following records on the same
--						date for this change.
--	p_hist_data_as_of_date	->	input record that contains the data from history for the effective_date
--						of this action.
--
-- Post Success:
-- 	All data will have been cascaded to all following rows.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Cascade_asgn (
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype
) is

	l_true_false	ghr_history_cascade.condition_rg_type;
	l_asgn_data		per_all_assignments_f%rowtype;
	l_hist_asgn_data	ghr_pa_history%rowtype;
	l_stop		Boolean;
	l_proc		varchar2(30):='Cascade_asgn';

	-- this cursor is meant to retrieve all following records in per_assignments_f table.
	Cursor c_asgn( c_date_Effective in date, c_asgn_id	in number) is
	Select *
	from per_all_assignments_f
	where effective_start_date >= c_date_effective and
	assignment_id = c_asgn_id;

Begin

	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	For rowno in 4..101 loop
    		l_true_false(rowno) := TRUE;
	End loop;
	hr_utility.set_location( l_proc, 15);
	if p_interv_on_eff_date then
		-- This is to take care of multiple actions on the same date.
		-- When a correction is made to a SF52 and other process had
		-- updated the same row on the same date, the data in the
		-- core table might be incorrect since the date effectivity has the
		-- granularity of a day, and not date and time. So, this will
		-- re-apply the data from history for the effective date of the current action to the
		-- core table. This will insure that the core table will contain the correct information
		-- in all cases.
		hr_utility.set_location( l_proc, 20);

		ghr_history_conv_rg.Conv_to_asgn_rg(
				p_assignment_data 	=> l_asgn_data,
				p_history_data 	=> p_hist_data_as_of_date);

		correct_asgn_row( p_asgn_data => l_asgn_data);
		hr_utility.set_location( l_proc, 30);
	elsif (lower(p_cascade_type) = 'cancel') then
		-- if this is a cancellation and there are no intervening rows on this effective date,
		-- then apply the pre-record to the core people table for this effective date.
		hr_utility.set_location( l_proc, 35);
		ghr_history_conv_rg.Conv_to_asgn_rg(
				p_assignment_data => l_asgn_data,
				p_history_data 	=> p_pre_record);
		correct_asgn_row( p_asgn_data => l_asgn_data);
	end if;

	hr_utility.set_location( l_proc, 40);
	-- Fetch all the following rows.
	open c_asgn( p_post_record.effective_date, to_number(p_post_record.information1));
	while true
	Loop
		hr_utility.set_location( l_proc, 50);
		fetch c_asgn into l_asgn_data;
		exit when not c_asgn%found;

		ghr_history_conv_rg.conv_asgn_rg_to_hist_rg(
			p_assignment_data => l_asgn_data,
			p_history_data 	=> l_hist_asgn_data);

		if lower(p_cascade_Type)    = 'retroactive' then
			hr_utility.set_location( l_proc, 60);
			-- for retroactive action post-record values have to be cascaded
			-- whereever pre-record values exist.
			cascade_Change(p_pre_record   => p_Pre_record,
                                 p_post_record  => p_Post_record,
                                 p_apply_record => l_hist_asgn_data,
                                 p_true_false   => l_true_false);

		elsif lower(p_cascade_Type) = 'cancel' then
			-- for cancellation action pre-record values have to be cascaded
			-- whereever post-record values exist.
			hr_utility.set_location( l_proc, 70);
				cascade_Change(p_pre_record   => p_Post_record,
                                       p_post_record  => p_Pre_record,
                                       p_apply_record => l_hist_asgn_data,
                                       p_true_false   => l_true_false);
		else
			hr_utility.set_location( l_proc, 80);
  		      hr_utility.set_message(8301, 'GHR_38225_UNKNOWN_CASCADE_TYPE');
		      hr_utility.raise_error;
		      --	raise error /* Unknown type */
		end if;

		-- As a column value
		l_stop  := Stop_cascade(l_true_false);
		if not l_stop  then
			hr_utility.set_location( l_proc || ' exit loop ', 90);
		      exit;
		else
			hr_utility.set_location( l_proc, 100);
			ghr_history_conv_rg.conv_to_asgn_rg(
						p_assignment_data	=> l_asgn_data,
						p_history_data 	=> l_hist_asgn_data);

			correct_asgn_row( p_asgn_data => l_asgn_data);
		end if;
	end loop;
	hr_utility.set_location( l_proc, 200);
	close c_asgn;
End cascade_Asgn;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_peopleei>-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_people_extra_info core application table.
--	Since extra information tables are not date-tracked by core, cascade of these
--	tables simply re-applies the most recent record in history according to
--	the sysdate. This is necessary because update to database will have applied
--	any changes to this table regardless of effective date of the action. So, this
--	cascade ensures that this non-datetrack table contains the correct data
--	according to the sysdate.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_post_record		->	new value of row that has been changed by current sf52.
--
-- Post Success:
-- 	Data will have been re-applied to the non-datetrack table.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cascade_peopleei (
	p_post_record	in	ghr_pa_history%rowtype
) is

	l_hist_peopleei_data	ghr_pa_history%rowtype;
	l_peopleei_data		per_people_extra_info%rowtype;
	l_result_code		varchar2(30);
	l_proc			varchar2(30):='Cascade_peopleei';

Begin


	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- This procedure will fetch
	-- the most recent record from history and update the database.
	hr_utility.set_location( l_proc, 20);
	Fetch_most_recent_record(
		p_table_name 	=> ghr_history_api.g_peopei_table,
		p_table_pk_id	=> p_post_record.information1,
		p_person_id		=> p_post_record.person_id,
		p_history_data	=> l_hist_peopleei_data,
		p_result_code     => l_result_code);
	if l_result_code = 'not_found' then
		-- this should never be the case
		-- raise error.
		hr_utility.set_location( l_proc, 30);
	      hr_utility.set_message(8301, 'GHR_38364_NO_PEOPLE_RECORD');
	      hr_utility.raise_error;
	else
		hr_utility.set_location( l_proc, 40);
		ghr_history_conv_rg.Conv_to_peopleei_rg(
			p_people_ei_data  => l_peopleei_data,
			p_history_data => l_hist_peopleei_data);
		hr_utility.set_location( 'l_peopleei_data.person_extra_info_id: ' || l_peopleei_data.person_extra_info_id ||l_proc, 46);
		hr_utility.set_location( 'l_peopleei_data.pei_information11: ' || l_peopleei_data.pei_information11 ||l_proc, 47);
		correct_peopleei_row( p_peopleei_data => l_peopleei_data);
	end if;
	hr_utility.set_location( l_proc, 90);

End cascade_peopleei;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_asgneei>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_assignment_extra_info core application table.
--	Since extra information tables are not date-tracked by core, cascade of these
--	tables simply re-applies the most recent record in history according to
--	the sysdate. This is necessary because update to database will have applied
--	any changes to this table regardless of effective date of the action. So, this
--	cascade ensures that this non-datetrack table contains the correct data
--	according to the sysdate.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_post_record		->	new value of row that has been changed by current sf52.
--
-- Post Success:
-- 	Data will have been re-applied to the non-datetrack table.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Cascade_asgnei (
	p_post_record	in	ghr_pa_history%rowtype
) is

	l_hist_asgnei_data	ghr_pa_history%rowtype;
	l_asgnei_data		per_assignment_extra_info%rowtype;
	l_result_code		varchar2(30);
	l_proc			varchar2(30):='Cascade_asgnei';

Begin


	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- This procedure will fetch
	-- the most recent record from history and update the database.
	hr_utility.set_location( l_proc, 20);
	Fetch_most_recent_record(
		p_table_name 	=> ghr_history_api.g_asgnei_table,
		p_table_pk_id	=> p_post_record.information1,
		p_person_id		=> p_post_record.person_id,
		p_history_data	=> l_hist_asgnei_data,
		p_result_code     => l_result_code);
	if l_result_code = 'not_found' then
		-- this should never be the case
		-- raise error.
		hr_utility.set_location( l_proc, 30);
	      hr_utility.set_message(8301, 'GHR_38365_NO_ASGN_RECORD');
	      hr_utility.raise_error;
	else
		hr_utility.set_location( l_proc, 40);
		ghr_history_conv_rg.Conv_to_asgnei_rg(
			p_asgnei_data  => l_asgnei_data,
			p_history_data => l_hist_asgnei_data);
		correct_asgnei_row( p_asgnei_data => l_asgnei_data);
	end if;
	hr_utility.set_location( l_proc, 90);

End cascade_asgnei;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_posneei>------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_position_extra_info core application table.
--	Since extra information tables are not date-tracked by core, cascade of these
--	tables simply re-applies the most recent record in history according to
--	the sysdate. This is necessary because update to database will have applied
--	any changes to this table regardless of effective date of the action. So, this
--	cascade ensures that this non-datetrack table contains the correct data
--	according to the sysdate.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_post_record		->	new value of row that has been changed by current sf52.
--
-- Post Success:
-- 	Data will have been re-applied to the non-datetrack table.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cascade_posnei (
	p_post_record	in	ghr_pa_history%rowtype) is

	l_hist_posnei_data	ghr_pa_history%rowtype;
	l_posnei_data		per_position_extra_info%rowtype;
	l_result_code		varchar2(30);
	l_proc			varchar2(30):='Cascade_posnei';

	l_curr_sess_date        fnd_sessions.effective_date%type;

Begin

	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- This procedure will fetch
	-- the most recent record from history and update the database.
	hr_utility.set_location( l_proc, 20);
	Fetch_most_recent_record(
		p_table_name 	=> ghr_history_api.g_posnei_table,
		p_table_pk_id	=> p_post_record.information1,
		p_person_id		=> p_post_record.person_id,
		p_history_data	=> l_hist_posnei_data,
		p_result_code     => l_result_code);
	if l_result_code = 'not_found' then
		-- this should never be the case
		-- raise error.
		hr_utility.set_location( l_proc, 30);
	      hr_utility.set_message(8301, 'GHR_38366_NO_POSNEI_RECORD');
	      hr_utility.raise_error;
	else
		hr_utility.set_location( l_proc, 40);
		GHR_HISTORY_API.get_session_date(l_curr_sess_date);

		ghr_history_conv_rg.Conv_to_positionei_rg(
			p_position_ei_data  => l_posnei_data,
			p_history_data => l_hist_posnei_data);

		 --Bug  #7646662
		 ghr_session.set_session_var_for_core(ghr_history_fetch.g_cascad_eff_date);
		 Begin
		 correct_posnei_row( p_posnei_data => l_posnei_data);
		 Exception
		 when others then
		      ghr_session.set_session_var_for_core( l_curr_sess_date);
		      raise;
		 End;
                 ghr_session.set_session_var_for_core(l_curr_sess_date);
		 --Bug  #7646662
	end if;
	hr_utility.set_location( l_proc, 90);

End cascade_posnei;

/*
-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_posn>---------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_positions core application table.
--	Since this table is not date-tracked by core, cascade of this
--	tables simply re-applies the most recent record in history according to
--	the sysdate. This is necessary because update to database will have applied
--	any changes to this table regardless of effective date of the action. So, this
--	cascade ensures that this non-datetrack table contains the correct data
--	according to the sysdate.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_post_record		->	new value of row that has been changed by current sf52.
--
-- Post Success:
-- 	Data will have been re-applied to the non-datetrack table.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cascade_posn (
	p_post_record	in	ghr_pa_history%rowtype) is

	l_hist_posn_data		ghr_pa_history%rowtype;
	l_posn_data			hr_all_positions_f%rowtype;
	l_result_code		varchar2(30);
	l_proc			varchar2(30):='Cascade_posn';

Begin

	-- This procedure will fetch
	-- the most recent record from history and update the database.
	hr_utility.set_location( l_proc, 20);
	Fetch_most_recent_record(
		p_table_name 	=> ghr_history_api.g_posn_table,
		p_table_pk_id	=> p_post_record.information1,
		p_person_id		=> p_post_record.person_id,
		p_history_data	=> l_hist_posn_data,
		p_result_code     => l_result_code);
	if l_result_code = 'not_found' then
		-- this should never be the case
		-- raise error.
		hr_utility.set_location( l_proc, 30);
	      hr_utility.set_message(8301, 'GHR_38491_NO_POSN_RECORD');
	      hr_utility.raise_error;
	else
		hr_utility.set_location( l_proc, 40);
		ghr_history_conv_rg.Conv_to_position_rg(
			p_position_data  => l_posn_data,
			p_history_data => l_hist_posn_data);

		correct_posn_row( p_posn_data => l_posn_data);
	end if;
	hr_utility.set_location( l_proc, 90);

End cascade_posn;
*/


-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_posn>---------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in hr_all_positions_f core application table. If the
--	current action made changes to hr_all_positions_f and there were changes following it, this procedure
--	will correctly 'cascade' those changes to all following records. This procedure can
--	be called in either 'retroactive' (p_post_record values will be cascaded) or 'cancel'
--	(p_pre_record values will be cascaded) mode.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pre_record		->	old value of row that has been changed by current sf52.
--	p_post_record		->	new value of row that has been changed by current sf52.
--	p_cascade_type		->	either 'retroactive' or cancel.
--	p_interv_on_table		->	input flag that indicates if there are any following records for this change.
--	p_interv_on_eff_date 	->	input flag that indicates if there are any following records on the same
--						date for this change.
--	p_hist_data_as_of_date	->	input record that contains the data from history for the effective_date
--						of this action.
--
-- Post Success:
-- 	All data will have been cascaded to all following rows.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

Procedure Cascade_posn (
	p_pre_record			in	ghr_pa_history%rowtype,
	p_post_record			in	ghr_pa_history%rowtype,
	p_cascade_type			in	varchar2,
	p_interv_on_eff_date		in	Boolean,
	p_hist_data_as_of_date		in	ghr_pa_history%rowtype
) is

	l_true_false	ghr_history_cascade.condition_rg_type;
	l_posn_data		hr_all_positions_f%rowtype;
	l_hist_posn_data	ghr_pa_history%rowtype;
	l_stop		Boolean;
	l_proc		varchar2(30):='Cascade_posn';

	-- this cursor is meant to retrieve all following records in per_assignments_f table.
	Cursor c_posn( c_date_Effective in date, c_posn_id	in number) is
	Select *
	from hr_all_positions_f
	where effective_start_date >= c_date_effective and
	position_id = c_posn_id;

Begin

	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	For rowno in 4..101 loop
    		l_true_false(rowno) := TRUE;
	End loop;
	hr_utility.set_location( l_proc, 15);
	if p_interv_on_eff_date then
		-- This is to take care of multiple actions on the same date.
		-- When a correction is made to a SF52 and other process had
		-- updated the same row on the same date, the data in the
		-- core table might be incorrect since the date effectivity has the
		-- granularity of a day, and not date and time. So, this will
		-- re-apply the data from history for the effective date of the current action to the
		-- core table. This will insure that the core table will contain the correct information
		-- in all cases.
		hr_utility.set_location( l_proc, 20);

		ghr_history_conv_rg.Conv_to_position_rg(
				p_position_data 	=> l_posn_data,
				p_history_data 	=> p_hist_data_as_of_date);

		correct_posn_row( p_posn_data => l_posn_data);
		hr_utility.set_location( l_proc, 30);
	elsif (lower(p_cascade_type) = 'cancel') then
		-- if this is a cancellation and there are no intervening rows on this effective date,
		-- then apply the pre-record to the core people table for this effective date.
		hr_utility.set_location( l_proc, 35);
		ghr_history_conv_rg.Conv_to_position_rg(
				p_position_data => l_posn_data,
				p_history_data 	=> p_pre_record);
		correct_posn_row( p_posn_data => l_posn_data);
	end if;

	hr_utility.set_location( l_proc, 40);
	-- Fetch all the following rows.
	open c_posn( p_post_record.effective_date, to_number(p_post_record.information1));
	while true
	Loop
		hr_utility.set_location( l_proc, 50);
		fetch c_posn into l_posn_data;
		exit when not c_posn%found;

		ghr_history_conv_rg.conv_position_rg_to_hist_rg(
			p_position_data => l_posn_data,
			p_history_data 	=> l_hist_posn_data);

		if lower(p_cascade_Type)    = 'retroactive' then
			hr_utility.set_location( l_proc, 60);
			-- for retroactive action post-record values have to be cascaded
			-- whereever pre-record values exist.
			cascade_Change(p_pre_record   => p_Pre_record,
                                 p_post_record  => p_Post_record,
                                 p_apply_record => l_hist_posn_data,
                                 p_true_false   => l_true_false);

		elsif lower(p_cascade_Type) = 'cancel' then
			-- for cancellation action pre-record values have to be cascaded
			-- whereever post-record values exist.
			hr_utility.set_location( l_proc, 70);
				cascade_Change(p_pre_record   => p_Post_record,
                                       p_post_record  => p_Pre_record,
                                       p_apply_record => l_hist_posn_data,
                                       p_true_false   => l_true_false);
		else
			hr_utility.set_location( l_proc, 80);
  		      hr_utility.set_message(8301, 'GHR_38225_UNKNOWN_CASCADE_TYPE');
		      hr_utility.raise_error;
		      --	raise error /* Unknown type */
		end if;

		-- As a column value
		l_stop  := Stop_cascade(l_true_false);
		if not l_stop  then
			hr_utility.set_location( l_proc || ' exit loop ', 90);
		      exit;
		else
			hr_utility.set_location( l_proc, 100);
			ghr_history_conv_rg.conv_to_position_rg(
						p_position_data	=> l_posn_data,
						p_history_data 	=> l_hist_posn_data);

			correct_posn_row( p_posn_data => l_posn_data);
		end if;
	end loop;
	hr_utility.set_location( l_proc, 200);
	close c_posn;
End cascade_posn;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_addresses>----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_addresses core application table.
--	Since extra information tables are not date-tracked by core, cascade of these
--	tables simply re-applies the most recent record in history according to
--	the sysdate. This is necessary because update to database will have applied
--	any changes to this table regardless of effective date of the action. So, this
--	cascade ensures that this non-datetrack table contains the correct data
--	according to the sysdate.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_post_record		->	new value of row that has been changed by current sf52.
--
-- Post Success:
-- 	Data will have been re-applied to the non-datetrack table.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cascade_addresses (
	p_post_record	in	ghr_pa_history%rowtype) is

	l_hist_addresses_data	ghr_pa_history%rowtype;
	l_addresses_data		per_addresses%rowtype;
	l_result_code		varchar2(30);
	l_proc			varchar2(30):='Cascade_addresses';

Begin


	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- This procedure will fetch
	-- the most recent record from history and update the database.
	hr_utility.set_location( l_proc, 20);
	Fetch_most_recent_record(
		p_table_name 	=> ghr_history_api.g_addres_table,
		p_table_pk_id	=> p_post_record.information1,
		p_person_id		=> p_post_record.person_id,
		p_history_data	=> l_hist_addresses_data,
		p_result_code     => l_result_code);
	if l_result_code = 'not_found' then
		-- this should never be the case
		-- raise error.
		hr_utility.set_location( l_proc, 30);
	      hr_utility.set_message(8301, 'GHR_38367_NO_ADDRESS_RECORD');
	      hr_utility.raise_error;
	else
		hr_utility.set_location( l_proc, 40);
			ghr_history_conv_rg.Conv_to_addresses_rg(
			p_addresses_data  => l_addresses_data,
			p_history_data 	=> l_hist_addresses_data);
			correct_addresses_row( p_addr_data => l_addresses_data);
	end if;
	hr_utility.set_location( l_proc, 90);
End cascade_addresses;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_perana>-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure cascades data changes in per_person_analyses core application table.
--	Since this table is not date-tracked by core, cascade of these
--	tables simply re-applies the most recent record in history according to
--	the sysdate. This is necessary because update to database will have applied
--	any changes to this table regardless of effective date of the action. So, this
--	cascade ensures that this non-datetrack table contains the correct data
--	according to the sysdate.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_post_record		->	new value of row that has been changed by current sf52.
--
-- Post Success:
-- 	Data will have been re-applied to the non-datetrack table.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Cascade_perana (
	p_post_record	in	ghr_pa_history%rowtype) is

	l_hist_perana_data	ghr_pa_history%rowtype;
	l_perana_data		per_person_analyses%rowtype;
	l_result_code		varchar2(30);
	l_proc			varchar2(30):='Cascade_perana';

Begin


	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- This procedure will fetch
	-- the most recent record from history and update the database.
	hr_utility.set_location( l_proc, 20);
	Fetch_most_recent_record(
		p_table_name 	=> ghr_history_api.g_perana_table,
		p_table_pk_id	=> p_post_record.information1,
		p_person_id		=> p_post_record.person_id,
		p_history_data	=> l_hist_perana_data,
		p_result_code     => l_result_code);
	if l_result_code = 'not_found' then
		-- this should never be the case
		-- raise error.
		hr_utility.set_location( l_proc, 30);
	      hr_utility.set_message(8301, 'GHR_38367_NO_ADDRESS_RECORD');
	      hr_utility.raise_error;
	else
		hr_utility.set_location( l_proc, 40);
			ghr_history_conv_rg.Conv_to_peranalyses_rg(
			p_peranalyses_data 	=> l_perana_data,
			p_history_data 		=> l_hist_perana_data);
			correct_perana_row( p_perana_data => l_perana_data);
	end if;
	hr_utility.set_location( l_proc, 90);
End cascade_perana;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_people_row>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_people_f table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_people_data		->	per_people_f record that is being applied.
--
-- Post Success:
-- 	per_people_f record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
-- Procedure Correct_people_row will update the Per_People_F row in correct mode
Procedure Correct_people_row (p_people_data in out nocopy per_all_people_f%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_people_getovn(  cp_person_id	number,
					 cp_eff_st_dt	date
					,cp_eff_end_dt	date) is
	select object_version_number
	from per_all_people_f
	where person_id = cp_person_id
	and	effective_start_date	= cp_eff_st_dt;

--	and	effective_end_date	= cp_eff_end_dt;

	l_datetrack_mode			varchar2(30):=hr_api.g_correction;
	l_dob_null_warning		boolean;
	l_name_combination_warning	boolean;
        l_orig_hire_warning             boolean;
	l_people_data                   per_all_people_f%rowtype;
	l_proc 				varchar2(30):='Correct_people_Row';
        l_date1                         per_all_people_f.effective_start_date%type;

Begin

	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- Initialise Local Variables
	   l_people_data:=p_people_data;
	--
	open c_people_getovn( 	cp_person_id	=> 	p_people_data.person_id,
					cp_eff_st_dt	=> 	p_people_data.effective_start_date,
					cp_eff_end_dt	=>	p_people_data.effective_end_date );
	Fetch c_people_getovn into p_people_data.object_version_number;
	if c_people_getovn%notfound then
		close c_people_getovn;
	      hr_utility.set_message(8301, 'GHR_38368_PEOPLE_OVN_NFND');
	      hr_utility.raise_error;
	else
		close c_people_getovn;
	end if;
    l_date1 := p_people_data.effective_start_date;

    per_per_upd.upd(
      p_person_id                             => p_people_data.person_id                     ,
      p_effective_start_date                  => l_date1,
      p_effective_end_date                    => p_people_data.effective_end_date            ,
      p_person_type_id                        => p_people_data.person_type_id                ,
      p_last_name                             => p_people_data.last_name                     ,
      p_start_date                            => p_people_data.start_date                    ,
      p_applicant_number                      => p_people_data.applicant_number              ,
      p_background_check_status               => p_people_data.background_check_status       ,
      p_background_date_check                 => p_people_data.background_date_check         ,
      p_blood_type                            => p_people_data.blood_type                    ,
      p_comment_id                            => p_people_data.comment_id                    ,
      p_correspondence_language               => p_people_data.correspondence_language       ,
      p_current_applicant_flag                => p_people_data.current_applicant_flag        ,
      p_current_emp_or_apl_flag               => p_people_data.current_emp_or_apl_flag       ,
      p_current_employee_flag                 => p_people_data.current_employee_flag         ,
      p_date_employee_data_verified           => p_people_data.date_employee_data_verified   ,
      p_date_of_birth                         => p_people_data.date_of_birth                 ,
      p_email_address                         => p_people_data.email_address                 ,
      p_employee_number                       => p_people_data.employee_number               ,
      p_expense_check_send_to_addres          => p_people_data.expense_check_send_to_address ,
      p_fast_path_employee                    => p_people_data.fast_path_employee            ,
      p_first_name                            => p_people_data.first_name                    ,
      p_fte_capacity                          => p_people_data.fte_capacity                  ,
      p_full_name                             => p_people_data.full_name                     ,
      p_hold_applicant_date_until             => p_people_data.hold_applicant_date_until     ,
      p_honors                                => p_people_data.honors                        ,
      p_internal_location                     => p_people_data.internal_location             ,
      p_known_as                              => p_people_data.known_as                      ,
      p_last_medical_test_by                  => p_people_data.last_medical_test_by          ,
      p_last_medical_test_date                => p_people_data.last_medical_test_date        ,
      p_mailstop                              => p_people_data.mailstop                      ,
      p_marital_status                        => p_people_data.marital_status                ,
      p_middle_names                          => p_people_data.middle_names                  ,
      p_nationality                           => p_people_data.nationality                   ,
      p_national_identifier                   => p_people_data.national_identifier           ,
      p_office_number                         => p_people_data.office_number                 ,
      p_on_military_service                   => p_people_data.on_military_service           ,
     -- 2461762
     -- p_order_name                            => p_people_data.order_name                    ,
      p_pre_name_adjunct                      => p_people_data.pre_name_adjunct              ,
      p_previous_last_name                    => p_people_data.previous_last_name            ,
      p_projected_start_date                  => p_people_data.projected_start_date          ,
      p_rehire_authorizor                     => p_people_data.rehire_authorizor             ,
      p_rehire_recommendation                 => p_people_data.rehire_recommendation         ,
      p_resume_exists                         => p_people_data.resume_exists                 ,
      p_resume_last_updated                   => p_people_data.resume_last_updated           ,
      p_registered_disabled_flag              => p_people_data.registered_disabled_flag      ,
      p_second_passport_exists                => p_people_data.second_passport_exists        ,
      p_sex                                   => p_people_data.sex                           ,
      p_student_status                        => p_people_data.student_status                ,
      p_suffix                                => p_people_data.suffix                        ,
      p_title                                 => p_people_data.title                         ,
      p_vendor_id                             => p_people_data.vendor_id                     ,
      p_work_schedule                         => p_people_data.work_schedule                 ,
      p_work_telephone                        => p_people_data.work_telephone                ,
      p_request_id                            => p_people_data.request_id                    ,
      p_program_application_id                => p_people_data.program_application_id        ,
      p_program_id                            => p_people_data.program_id                    ,
      p_program_update_date                   => p_people_data.program_update_date           ,
      p_attribute_category                    => p_people_data.attribute_category            ,
      p_attribute1                            => p_people_data.attribute1                    ,
      p_attribute2                            => p_people_data.attribute2                    ,
      p_attribute3                            => p_people_data.attribute3                    ,
      p_attribute4                            => p_people_data.attribute4                    ,
      p_attribute5                            => p_people_data.attribute5                    ,
      p_attribute6                            => p_people_data.attribute6                    ,
      p_attribute7                            => p_people_data.attribute7                    ,
      p_attribute8                            => p_people_data.attribute8                    ,
      p_attribute9                            => p_people_data.attribute9                    ,
      p_attribute10                           => p_people_data.attribute10                   ,
      p_attribute11                           => p_people_data.attribute11                   ,
      p_attribute12                           => p_people_data.attribute12                   ,
      p_attribute13                           => p_people_data.attribute13                   ,
      p_attribute14                           => p_people_data.attribute14                   ,
      p_attribute15                           => p_people_data.attribute15                   ,
      p_attribute16                           => p_people_data.attribute16                   ,
      p_attribute17                           => p_people_data.attribute17                   ,
      p_attribute18                           => p_people_data.attribute18                   ,
      p_attribute19                           => p_people_data.attribute19                   ,
      p_attribute20                           => p_people_data.attribute20                   ,
      p_attribute21                           => p_people_data.attribute21                   ,
      p_attribute22                           => p_people_data.attribute22                   ,
      p_attribute23                           => p_people_data.attribute23                   ,
      p_attribute24                           => p_people_data.attribute24                   ,
      p_attribute25                           => p_people_data.attribute25                   ,
      p_attribute26                           => p_people_data.attribute26                   ,
      p_attribute27                           => p_people_data.attribute27                   ,
      p_attribute28                           => p_people_data.attribute28                   ,
      p_attribute29                           => p_people_data.attribute29                   ,
      p_attribute30                           => p_people_data.attribute30                   ,
      p_per_information_category              => p_people_data.per_information_category      ,
      p_per_information1                      => p_people_data.per_information1              ,
      p_per_information2                      => p_people_data.per_information2              ,
      p_per_information3                      => p_people_data.per_information3              ,
      p_per_information4                      => p_people_data.per_information4              ,
      p_per_information5                      => p_people_data.per_information5              ,
      p_per_information6                      => p_people_data.per_information6              ,
      p_per_information7                      => p_people_data.per_information7              ,
      p_per_information8                      => p_people_data.per_information8              ,
      p_per_information9                      => p_people_data.per_information9              ,
      p_per_information10                     => p_people_data.per_information10             ,
      p_per_information11                     => p_people_data.per_information11             ,
      p_per_information12                     => p_people_data.per_information12             ,
      p_per_information13                     => p_people_data.per_information13             ,
      p_per_information14                     => p_people_data.per_information14             ,
      p_per_information15                     => p_people_data.per_information15             ,
      p_per_information16                     => p_people_data.per_information16             ,
      p_per_information17                     => p_people_data.per_information17             ,
      p_per_information18                     => p_people_data.per_information18             ,
      p_per_information19                     => p_people_data.per_information19             ,
      p_per_information20                     => p_people_data.per_information20             ,
      p_per_information21                     => p_people_data.per_information21             ,
      p_per_information22                     => p_people_data.per_information22             ,
      p_per_information23                     => p_people_data.per_information23             ,
      p_per_information24                     => p_people_data.per_information24             ,
      p_per_information25                     => p_people_data.per_information25             ,
      p_per_information26                     => p_people_data.per_information26             ,
      p_per_information27                     => p_people_data.per_information27             ,
      p_per_information28                     => p_people_data.per_information28             ,
      p_per_information29                     => p_people_data.per_information29             ,
      p_per_information30                     => p_people_data.per_information30             ,
      p_object_version_number                 => p_people_data.object_version_number         ,
      p_date_of_death                         => p_people_data.date_of_death                 ,
      p_rehire_reason                         => p_people_data.rehire_reason                 ,
      p_effective_date		                => p_people_data.effective_start_date          ,
      p_datetrack_mode		                => l_datetrack_mode                            ,
      p_name_combination_warning              => l_name_combination_warning                  ,
      p_dob_null_warning                      => l_dob_null_warning,
      p_orig_hire_warning                     => l_orig_hire_warning,
      p_npw_number                            => p_people_data.npw_number,
      p_current_npw_flag                      => p_people_data.current_npw_flag
    );
    hr_utility.set_location( 'Leaving : ' || l_proc, 20);
Exception
When Others then
   -- RESET In/Out Params and SET Out Params
   p_people_data:=l_people_data;
   hr_utility.set_location( 'Leaving : ' || l_proc, 25);
   Raise;

End Correct_people_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_asgn_row>-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_assignments_f table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_asgn_data		->	per_assignments_f record that is being applied.
--
-- Post Success:
-- 	per_assignments_f record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Correct_asgn_row (
	p_asgn_data	in out nocopy per_all_assignments_f%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_asgn_getovn( 	 cp_assignment_id	number,
					 cp_eff_st_dt	date
					,cp_eff_end_dt	date) is
	select object_version_number
	from per_all_assignments_f
	where assignment_id = cp_assignment_id
	and effective_start_date	= cp_eff_st_dt;

--	and effective_end_date		= cp_eff_end_dt;

	l_asgn_data		       per_all_assignments_f%rowtype;
	l_payroll_id_updated           boolean;
	l_other_manager_warning        boolean;
	l_no_managers_warning          boolean;
	l_hourly_salaried_warning      boolean;
	l_org_now_no_manager_warning   boolean;
	l_validation_start_date        date;
	l_validation_end_date          date;
	l_object_version_number        number;
	l_effective_date               date:= p_asgn_data.effective_Start_date;
	l_datetrack_mode               varchar2(30):=hr_api.g_correction;
	l_validate                     boolean;

	l_proc	varchar2(30):='correct_asgn_row';

Begin
	hr_utility.set_location('Entering : ' || l_proc, 10);

     -- Initialise local variables
	l_asgn_data:=p_asgn_data;
     --
	open c_asgn_getovn( 	cp_assignment_id	=>	p_asgn_data.assignment_id,
					cp_eff_st_dt	=>	p_asgn_data.effective_start_date,
					cp_eff_end_dt	=>	p_asgn_data.effective_end_date );
	Fetch c_asgn_getovn into p_asgn_data.object_version_number;
	if c_asgn_getovn%notfound then
		close c_asgn_getovn;
	      hr_utility.set_message(8301, 'GHR_38369_ASGN_OVN_NFND');
	      hr_utility.raise_error;
	else
		close c_asgn_getovn;
	end if;

   Per_asg_upd.upd(
      p_assignment_id                         => p_asgn_data.assignment_id                   ,
      p_effective_start_date                  => p_asgn_data.effective_start_date            ,
      p_effective_end_date                    => p_asgn_data.effective_end_date              ,
      p_business_group_id                     => p_asgn_data.business_group_id               ,
--
      p_recruiter_id                          => p_asgn_data.recruiter_id                    ,
      p_grade_id                              => p_asgn_data.grade_id                        ,
      p_position_id                           => p_asgn_data.position_id                     ,
      p_job_id                                => p_asgn_data.job_id                          ,
      p_assignment_status_type_id             => p_asgn_data.assignment_status_type_id       ,
      p_payroll_id                            => p_asgn_data.payroll_id                      ,
      p_location_id                           => p_asgn_data.location_id                     ,
      p_person_referred_by_id                 => p_asgn_data.person_referred_by_id           ,
      p_supervisor_id                         => p_asgn_data.supervisor_id                   ,
      p_special_ceiling_step_id               => p_asgn_data.special_ceiling_step_id         ,
      p_recruitment_activity_id               => p_asgn_data.recruitment_activity_id         ,
      p_source_organization_id                => p_asgn_data.source_organization_id          ,
      p_organization_id                       => p_asgn_data.organization_id                 ,
      p_people_group_id                       => p_asgn_data.people_group_id                 ,
      p_soft_coding_keyflex_id                => p_asgn_data.soft_coding_keyflex_id          ,
      p_vacancy_id                            => p_asgn_data.vacancy_id                      ,
      p_pay_basis_id                          => p_asgn_data.pay_basis_id                    ,
      p_assignment_type                       => p_asgn_data.assignment_type                 ,
      p_primary_flag                          => p_asgn_data.primary_flag                    ,
      p_application_id                        => p_asgn_data.application_id                  ,
      p_assignment_number                     => p_asgn_data.assignment_number               ,
      p_change_reason                         => p_asgn_data.change_reason                   ,
      p_comment_id                            => p_asgn_data.comment_id                      ,
      p_date_probation_end                    => p_asgn_data.date_probation_end              ,
      p_default_code_comb_id                  => p_asgn_data.default_code_comb_id            ,
      p_employment_category                   => p_asgn_data.employment_category             ,
      p_frequency                             => p_asgn_data.frequency                       ,
      p_internal_address_line                 => p_asgn_data.internal_address_line           ,
      p_manager_flag                          => p_asgn_data.manager_flag                    ,
      p_normal_hours                          => p_asgn_data.normal_hours                    ,
      p_perf_review_period                    => p_asgn_data.perf_review_period              ,
      p_perf_review_period_frequency          => p_asgn_data.perf_review_period_frequency    ,
      p_period_of_service_id                  => p_asgn_data.period_of_service_id            ,
      p_probation_period                      => p_asgn_data.probation_period                ,
      p_probation_unit                        => p_asgn_data.probation_unit                  ,
      p_sal_review_period                     => p_asgn_data.sal_review_period               ,
      p_sal_review_period_frequency           => p_asgn_data.sal_review_period_frequency     ,
      p_set_of_books_id                       => p_asgn_data.set_of_books_id                 ,
      p_source_type                           => p_asgn_data.source_type                     ,
      p_time_normal_finish                    => p_asgn_data.time_normal_finish              ,
      p_time_normal_start                     => p_asgn_data.time_normal_start               ,
      p_request_id                            => p_asgn_data.request_id                      ,
      p_program_application_id                => p_asgn_data.program_application_id          ,
      p_program_id                            => p_asgn_data.program_id                      ,
      p_program_update_date                   => p_asgn_data.program_update_date             ,
      p_ass_attribute_category                => p_asgn_data.ass_attribute_category          ,
      p_ass_attribute1                        => p_asgn_data.ass_attribute1                  ,
      p_ass_attribute2                        => p_asgn_data.ass_attribute2                  ,
      p_ass_attribute3                        => p_asgn_data.ass_attribute3                  ,
      p_ass_attribute4                        => p_asgn_data.ass_attribute4                  ,
      p_ass_attribute5                        => p_asgn_data.ass_attribute5                  ,
      p_ass_attribute6                        => p_asgn_data.ass_attribute6                  ,
      p_ass_attribute7                        => p_asgn_data.ass_attribute7                  ,
      p_ass_attribute8                        => p_asgn_data.ass_attribute8                  ,
      p_ass_attribute9                        => p_asgn_data.ass_attribute9                  ,
      p_ass_attribute10                       => p_asgn_data.ass_attribute10                 ,
      p_ass_attribute11                       => p_asgn_data.ass_attribute11                 ,
      p_ass_attribute12                       => p_asgn_data.ass_attribute12                 ,
      p_ass_attribute13                       => p_asgn_data.ass_attribute13                 ,
      p_ass_attribute14                       => p_asgn_data.ass_attribute14                 ,
      p_ass_attribute15                       => p_asgn_data.ass_attribute15                 ,
      p_ass_attribute16                       => p_asgn_data.ass_attribute16                 ,
      p_ass_attribute17                       => p_asgn_data.ass_attribute17                 ,
      p_ass_attribute18                       => p_asgn_data.ass_attribute18                 ,
      p_ass_attribute19                       => p_asgn_data.ass_attribute19                 ,
      p_ass_attribute20                       => p_asgn_data.ass_attribute20                 ,
      p_ass_attribute21                       => p_asgn_data.ass_attribute21                 ,
      p_ass_attribute22                       => p_asgn_data.ass_attribute22                 ,
      p_ass_attribute23                       => p_asgn_data.ass_attribute23                 ,
      p_ass_attribute24                       => p_asgn_data.ass_attribute24                 ,
      p_ass_attribute25                       => p_asgn_data.ass_attribute25                 ,
      p_ass_attribute26                       => p_asgn_data.ass_attribute26                 ,
      p_ass_attribute27                       => p_asgn_data.ass_attribute27                 ,
      p_ass_attribute28                       => p_asgn_data.ass_attribute28                 ,
      p_ass_attribute29                       => p_asgn_data.ass_attribute29                 ,
      p_ass_attribute30                       => p_asgn_data.ass_attribute30                 ,
      p_title                                 => p_asgn_data.title                           ,
      p_object_version_number                 => p_asgn_data.object_version_number           ,
	p_payroll_id_updated                    => l_payroll_id_updated                        ,
	p_other_manager_warning                 => l_other_manager_warning                     ,
	p_no_managers_warning                   => l_no_managers_warning                       ,
	p_org_now_no_manager_warning            => l_org_now_no_manager_warning                ,
        p_hourly_salaried_warning               => l_hourly_salaried_warning                   ,
	p_validation_start_date                 => l_validation_start_date                     ,
	p_validation_end_date                   => l_validation_end_date                       ,
	p_effective_date                        => l_effective_date                        ,
	p_datetrack_mode                        => l_datetrack_mode                            ,
	p_validate                              => l_validate
	);

	hr_utility.set_location('Leaving : ' || l_proc, 20);
Exception
When Others then
   -- RESET In/Out params and SET Out Params
   p_asgn_data:=l_asgn_data;
   hr_utility.set_location('Leaving : ' || l_proc,25);
   Raise;

End correct_asgn_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_peopleei_row>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_people_extra_info table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_peopleei_data		->	per_people_extra_info record that is being applied.
--
-- Post Success:
-- 	per_people_extra_info record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Correct_peopleei_row ( p_peopleei_data	in out nocopy per_people_extra_info%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_peopleei_getovn( cp_people_ei_id	number) is
	select object_version_number
	from per_people_extra_info
	where person_extra_info_id = cp_people_ei_id;

	l_peopleei_data	  per_people_extra_info%rowtype;
	l_proc		  varchar2(30):='correct_peopleei_row';
Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	hr_utility.set_location( 'p_peopleei_data.person_extra_info_id : ' || p_peopleei_data.person_extra_info_id || l_proc, 11);
	hr_utility.set_location( 'p_peopleei_data.pei_information11 : ' || p_peopleei_data.pei_information11 || l_proc, 12);

	--Initialise Local Variables
	l_peopleei_data := p_peopleei_data;
	--

	open c_peopleei_getovn( p_peopleei_data.person_extra_info_id );
	Fetch c_peopleei_getovn into p_peopleei_data.object_version_number;
	if c_peopleei_getovn%notfound then
	hr_utility.set_location( 'Entering : ' || l_proc, 11);
		close c_peopleei_getovn;
	      hr_utility.set_message(8301, 'GHR_38370_PEOPLEEI_OVN_NFND');
	      hr_utility.raise_error;
	else
		close c_peopleei_getovn;
	end if;
    pe_pei_upd.upd(
      p_person_extra_info_id     => p_peopleei_data.person_extra_info_id     ,
--      p_person_id                => p_peopleei_data.person_id                ,
--      p_information_type         => p_peopleei_data.information_type         ,
      p_request_id               => p_peopleei_data.request_id               ,
      p_program_application_id   => p_peopleei_data.program_application_id   ,
      p_program_id               => p_peopleei_data.program_id               ,
      p_program_update_date      => p_peopleei_data.program_update_date      ,
      p_pei_attribute_category   => p_peopleei_data.pei_attribute_category   ,
      p_pei_attribute1           => p_peopleei_data.pei_attribute1           ,
      p_pei_attribute2           => p_peopleei_data.pei_attribute2           ,
      p_pei_attribute3           => p_peopleei_data.pei_attribute3           ,
      p_pei_attribute4           => p_peopleei_data.pei_attribute4           ,
      p_pei_attribute5           => p_peopleei_data.pei_attribute5           ,
      p_pei_attribute6           => p_peopleei_data.pei_attribute6           ,
      p_pei_attribute7           => p_peopleei_data.pei_attribute7           ,
      p_pei_attribute8           => p_peopleei_data.pei_attribute8           ,
      p_pei_attribute9           => p_peopleei_data.pei_attribute9           ,
      p_pei_attribute10          => p_peopleei_data.pei_attribute10          ,
      p_pei_attribute11          => p_peopleei_data.pei_attribute11          ,
      p_pei_attribute12          => p_peopleei_data.pei_attribute12          ,
      p_pei_attribute13          => p_peopleei_data.pei_attribute13          ,
      p_pei_attribute14          => p_peopleei_data.pei_attribute14          ,
      p_pei_attribute15          => p_peopleei_data.pei_attribute15          ,
      p_pei_attribute16          => p_peopleei_data.pei_attribute16          ,
      p_pei_attribute17          => p_peopleei_data.pei_attribute17          ,
      p_pei_attribute18          => p_peopleei_data.pei_attribute18          ,
      p_pei_attribute19          => p_peopleei_data.pei_attribute19          ,
      p_pei_attribute20          => p_peopleei_data.pei_attribute20          ,
      p_pei_information_category => p_peopleei_data.pei_information_category ,
      p_pei_information1         => p_peopleei_data.pei_information1         ,
      p_pei_information2         => p_peopleei_data.pei_information2         ,
      p_pei_information3         => p_peopleei_data.pei_information3         ,
      p_pei_information4         => p_peopleei_data.pei_information4         ,
      p_pei_information5         => p_peopleei_data.pei_information5         ,
      p_pei_information6         => p_peopleei_data.pei_information6         ,
      p_pei_information7         => p_peopleei_data.pei_information7         ,
      p_pei_information8         => p_peopleei_data.pei_information8         ,
      p_pei_information9         => p_peopleei_data.pei_information9         ,
      p_pei_information10        => p_peopleei_data.pei_information10        ,
      p_pei_information11        => p_peopleei_data.pei_information11        ,
      p_pei_information12        => p_peopleei_data.pei_information12        ,
      p_pei_information13        => p_peopleei_data.pei_information13        ,
      p_pei_information14        => p_peopleei_data.pei_information14        ,
      p_pei_information15        => p_peopleei_data.pei_information15        ,
      p_pei_information16        => p_peopleei_data.pei_information16        ,
      p_pei_information17        => p_peopleei_data.pei_information17        ,
      p_pei_information18        => p_peopleei_data.pei_information18        ,
      p_pei_information19        => p_peopleei_data.pei_information19        ,
      p_pei_information20        => p_peopleei_data.pei_information20        ,
      p_pei_information21        => p_peopleei_data.pei_information21        ,
      p_pei_information22        => p_peopleei_data.pei_information22        ,
      p_pei_information23        => p_peopleei_data.pei_information23        ,
      p_pei_information24        => p_peopleei_data.pei_information24        ,
      p_pei_information25        => p_peopleei_data.pei_information25        ,
      p_pei_information26        => p_peopleei_data.pei_information26        ,
      p_pei_information27        => p_peopleei_data.pei_information27        ,
      p_pei_information28        => p_peopleei_data.pei_information28        ,
      p_pei_information29        => p_peopleei_data.pei_information29        ,
      p_pei_information30        => p_peopleei_data.pei_information30        ,
      p_object_version_number    => p_peopleei_data.object_version_number
	);
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);

Exception
When Others then
   -- RESET In/Out params and SET Out Params
   p_peopleei_data:=l_peopleei_data;
   hr_utility.set_location('Leaving  ' || l_proc,25);
   Raise;

End;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_asgnei_row>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_assignment_extra_info table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_asgnei_data		->	per_assignment_extra_info record that is being applied.
--
-- Post Success:
-- 	per_assignment_extra_info record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------

-- Procedure Correct_asgnei_row will update the Per_People_F row in correct mode
Procedure Correct_asgnei_row (p_asgnei_data in out nocopy per_assignment_extra_info%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_asgnei_getovn( cp_assignment_ei_id	number) is
	select object_version_number
	from per_assignment_extra_info
	where assignment_extra_info_id = cp_assignment_ei_id;

	l_asgnei_data 	per_assignment_extra_info%rowtype;
	l_proc 		varchar2(30):='Correct_asgnei_Row';

Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 20);
	-- Initialise Local variables
	l_asgnei_data := p_asgnei_data;
	--
	open c_asgnei_getovn( p_asgnei_data.assignment_extra_info_id );
	Fetch c_asgnei_getovn into p_asgnei_data.object_version_number;
	if c_asgnei_getovn%notfound then
		close c_asgnei_getovn;
		-- raise error
	      hr_utility.set_message(8301, 'GHR_38371_ASGNEI_OVN_NFND');
	      hr_utility.raise_error;
	else
		close c_asgnei_getovn;
	end if;
	pe_aei_upd.upd(
      p_assignment_extra_info_id              => p_asgnei_data.assignment_extra_info_id      ,
      p_request_id                            => p_asgnei_data.request_id                    ,
      p_program_application_id                => p_asgnei_data.program_application_id        ,
      p_program_id                            => p_asgnei_data.program_id                    ,
      p_program_update_date                   => p_asgnei_data.program_update_date           ,
      p_aei_attribute_category                => p_asgnei_data.aei_attribute_category        ,
      p_aei_attribute1                        => p_asgnei_data.aei_attribute1                ,
      p_aei_attribute2                        => p_asgnei_data.aei_attribute2                ,
      p_aei_attribute3                        => p_asgnei_data.aei_attribute3                ,
      p_aei_attribute4                        => p_asgnei_data.aei_attribute4                ,
      p_aei_attribute5                        => p_asgnei_data.aei_attribute5                ,
      p_aei_attribute6                        => p_asgnei_data.aei_attribute6                ,
      p_aei_attribute7                        => p_asgnei_data.aei_attribute7                ,
      p_aei_attribute8                        => p_asgnei_data.aei_attribute8                ,
      p_aei_attribute9                        => p_asgnei_data.aei_attribute9                ,
      p_aei_attribute10                       => p_asgnei_data.aei_attribute10               ,
      p_aei_attribute11                       => p_asgnei_data.aei_attribute11               ,
      p_aei_attribute12                       => p_asgnei_data.aei_attribute12               ,
      p_aei_attribute13                       => p_asgnei_data.aei_attribute13               ,
      p_aei_attribute14                       => p_asgnei_data.aei_attribute14               ,
      p_aei_attribute15                       => p_asgnei_data.aei_attribute15               ,
      p_aei_attribute16                       => p_asgnei_data.aei_attribute16               ,
      p_aei_attribute17                       => p_asgnei_data.aei_attribute17               ,
      p_aei_attribute18                       => p_asgnei_data.aei_attribute18               ,
      p_aei_attribute19                       => p_asgnei_data.aei_attribute19               ,
      p_aei_attribute20                       => p_asgnei_data.aei_attribute20               ,
      p_aei_information_category              => p_asgnei_data.aei_information_category      ,
      p_aei_information1                      => p_asgnei_data.aei_information1              ,
      p_aei_information2                      => p_asgnei_data.aei_information2              ,
      p_aei_information3                      => p_asgnei_data.aei_information3              ,
      p_aei_information4                      => p_asgnei_data.aei_information4              ,
      p_aei_information5                      => p_asgnei_data.aei_information5              ,
      p_aei_information6                      => p_asgnei_data.aei_information6              ,
      p_aei_information7                      => p_asgnei_data.aei_information7              ,
      p_aei_information8                      => p_asgnei_data.aei_information8              ,
      p_aei_information9                      => p_asgnei_data.aei_information9              ,
      p_aei_information10                     => p_asgnei_data.aei_information10             ,
      p_aei_information11                     => p_asgnei_data.aei_information11             ,
      p_aei_information12                     => p_asgnei_data.aei_information12             ,
      p_aei_information13                     => p_asgnei_data.aei_information13             ,
      p_aei_information14                     => p_asgnei_data.aei_information14             ,
      p_aei_information15                     => p_asgnei_data.aei_information15             ,
      p_aei_information16                     => p_asgnei_data.aei_information16             ,
      p_aei_information17                     => p_asgnei_data.aei_information17             ,
      p_aei_information18                     => p_asgnei_data.aei_information18             ,
      p_aei_information19                     => p_asgnei_data.aei_information19             ,
      p_aei_information20                     => p_asgnei_data.aei_information20             ,
      p_aei_information21                     => p_asgnei_data.aei_information21             ,
      p_aei_information22                     => p_asgnei_data.aei_information22             ,
      p_aei_information23                     => p_asgnei_data.aei_information23             ,
      p_aei_information24                     => p_asgnei_data.aei_information24             ,
      p_aei_information25                     => p_asgnei_data.aei_information25             ,
      p_aei_information26                     => p_asgnei_data.aei_information26             ,
      p_aei_information27                     => p_asgnei_data.aei_information27             ,
      p_aei_information28                     => p_asgnei_data.aei_information28             ,
      p_aei_information29                     => p_asgnei_data.aei_information29             ,
      p_aei_information30                     => p_asgnei_data.aei_information30             ,
      p_object_version_number                 => p_asgnei_data.object_version_number
	);
   hr_utility.set_location( 'Leaving : ' || l_proc, 20);
Exception
When Others then
   -- RESET In/Out Params and SET Out params
   p_asgnei_data:=l_asgnei_data;
   hr_utility.set_location( 'Leaving : ' || l_proc, 25);
   Raise;

End;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_posnei_row>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_position_extra_info table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_posnei_data		->	per_position_extra_info record that is being applied.
--
-- Post Success:
-- 	per_position_extra_info record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
-- Procedure Correct_posnei_row will update the Per_position_extra_info row in correct mode
Procedure Correct_posnei_row (p_posnei_data in out nocopy per_position_extra_info%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_posnei_getovn( cp_position_ei_id	number) is
	select object_version_number
	from per_position_extra_info
	where position_extra_info_id = cp_position_ei_id;

	l_posnei_data 	per_position_extra_info%rowtype;
	l_proc 		varchar2(30):='Correct_posnei_Row';

Begin
     	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	-- Initialise Local Variables
	l_posnei_data := p_posnei_data;
	--
	open c_posnei_getovn( p_posnei_data.position_extra_info_id );
	Fetch c_posnei_getovn into p_posnei_data.object_version_number;
	if c_posnei_getovn%notfound then
		close c_posnei_getovn;
		-- raise error
	      hr_utility.set_message(8301, 'GHR_38372_POSNEI_OVN_NFND');
	      hr_utility.raise_error;
	else
		close c_posnei_getovn;
	end if;



	pe_poi_upd.upd(
      p_position_extra_info_id              => p_posnei_data.position_extra_info_id      ,
      p_request_id                            => p_posnei_data.request_id                    ,
      p_program_application_id                => p_posnei_data.program_application_id        ,
      p_program_id                            => p_posnei_data.program_id                    ,
      p_program_update_date                   => p_posnei_data.program_update_date           ,
      p_poei_attribute_category                => p_posnei_data.poei_attribute_category        ,
      p_poei_attribute1                        => p_posnei_data.poei_attribute1                ,
      p_poei_attribute2                        => p_posnei_data.poei_attribute2                ,
      p_poei_attribute3                        => p_posnei_data.poei_attribute3                ,
      p_poei_attribute4                        => p_posnei_data.poei_attribute4                ,
      p_poei_attribute5                        => p_posnei_data.poei_attribute5                ,
      p_poei_attribute6                        => p_posnei_data.poei_attribute6                ,
      p_poei_attribute7                        => p_posnei_data.poei_attribute7                ,
      p_poei_attribute8                        => p_posnei_data.poei_attribute8                ,
      p_poei_attribute9                        => p_posnei_data.poei_attribute9                ,
      p_poei_attribute10                       => p_posnei_data.poei_attribute10               ,
      p_poei_attribute11                       => p_posnei_data.poei_attribute11               ,
      p_poei_attribute12                       => p_posnei_data.poei_attribute12               ,
      p_poei_attribute13                       => p_posnei_data.poei_attribute13               ,
      p_poei_attribute14                       => p_posnei_data.poei_attribute14               ,
      p_poei_attribute15                       => p_posnei_data.poei_attribute15               ,
      p_poei_attribute16                       => p_posnei_data.poei_attribute16               ,
      p_poei_attribute17                       => p_posnei_data.poei_attribute17               ,
      p_poei_attribute18                       => p_posnei_data.poei_attribute18               ,
      p_poei_attribute19                       => p_posnei_data.poei_attribute19               ,
      p_poei_attribute20                       => p_posnei_data.poei_attribute20               ,
      p_poei_information_category              => p_posnei_data.poei_information_category      ,
      p_poei_information1                      => p_posnei_data.poei_information1              ,
      p_poei_information2                      => p_posnei_data.poei_information2              ,
      p_poei_information3                      => p_posnei_data.poei_information3              ,
      p_poei_information4                      => p_posnei_data.poei_information4              ,
      p_poei_information5                      => p_posnei_data.poei_information5              ,
      p_poei_information6                      => p_posnei_data.poei_information6              ,
      p_poei_information7                      => p_posnei_data.poei_information7              ,
      p_poei_information8                      => p_posnei_data.poei_information8              ,
      p_poei_information9                      => p_posnei_data.poei_information9              ,
      p_poei_information10                     => p_posnei_data.poei_information10             ,
      p_poei_information11                     => p_posnei_data.poei_information11             ,
      p_poei_information12                     => p_posnei_data.poei_information12             ,
      p_poei_information13                     => p_posnei_data.poei_information13             ,
      p_poei_information14                     => p_posnei_data.poei_information14             ,
      p_poei_information15                     => p_posnei_data.poei_information15             ,
      p_poei_information16                     => p_posnei_data.poei_information16             ,
      p_poei_information17                     => p_posnei_data.poei_information17             ,
      p_poei_information18                     => p_posnei_data.poei_information18             ,
      p_poei_information19                     => p_posnei_data.poei_information19             ,
      p_poei_information20                     => p_posnei_data.poei_information20             ,
      p_poei_information21                     => p_posnei_data.poei_information21             ,
      p_poei_information22                     => p_posnei_data.poei_information22             ,
      p_poei_information23                     => p_posnei_data.poei_information23             ,
      p_poei_information24                     => p_posnei_data.poei_information24             ,
      p_poei_information25                     => p_posnei_data.poei_information25             ,
      p_poei_information26                     => p_posnei_data.poei_information26             ,
      p_poei_information27                     => p_posnei_data.poei_information27             ,
      p_poei_information28                     => p_posnei_data.poei_information28             ,
      p_poei_information29                     => p_posnei_data.poei_information29             ,
      p_poei_information30                     => p_posnei_data.poei_information30             ,
      p_object_version_number                 => p_posnei_data.object_version_number
	);

	hr_utility.set_location( 'Leaving : ' || l_proc, 20);

Exception
When Others then
   -- RESET In/Out params and SET Out params
   p_posnei_data:=l_posnei_data;
   hr_utility.set_location( 'Leaving : ' || l_proc, 25);
   Raise;
End Correct_posnei_Row;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_posn_row>-----------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_positions table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_posn_data		->	per_positions record that is being applied.
--
-- Post Success:
-- 	per_positions record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
-- Procedure Correct_posn_row will update the Per_positions row in correct mode
Procedure Correct_posn_row (p_posn_data in out nocopy hr_all_positions_f%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_posn_getovn( cp_position_id	number
			     ,cp_eff_st_dt	date
			     ,cp_eff_end_dt	date) is
	select object_version_number
	from hr_all_positions_f
	where position_id = cp_position_id
          and effective_start_date = cp_eff_st_dt;

	l_posn_data 			hr_all_positions_f%rowtype;
	l_position_data_rec        	ghr_sf52_pos_update.position_data_rec_type;
	l_proc 				varchar2(30):='Correct_posn_Row';
	l_datetrack_mode		varchar2(30):=hr_api.g_correction;
        l_date2                         hr_all_positions_f.effective_start_date%type;

Begin
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	--Initialise Local Variables
	l_posn_data := p_posn_data;
	--

	open c_posn_getovn( p_posn_data.position_id ,
                            p_posn_data.effective_start_date,
                            p_posn_data.effective_end_date);
	Fetch c_posn_getovn into p_posn_data.object_version_number;
	if c_posn_getovn%notfound then
		close c_posn_getovn;
		-- raise error
	      hr_utility.set_message(8301, 'GHR_38492_POSN_OVN_NFND');
	      hr_utility.raise_error;
	else
		close c_posn_getovn;
	end if;
        l_date2 :=  p_posn_data.effective_start_date;
	hr_psf_upd.upd (
		p_position_id                  =>	p_posn_data.position_id			 ,
                p_effective_start_date         =>       l_date2,
                p_effective_end_date           =>       p_posn_data.effective_end_date           ,
                p_availability_status_id       =>       p_posn_data.availability_status_id       ,
                p_entry_step_id                =>       p_posn_data.entry_step_id                ,
                p_entry_grade_rule_id          =>       p_posn_data.entry_grade_rule_id          ,
                p_location_id                  =>       p_posn_data.location_id                  ,
                p_pay_freq_payroll_id          =>       p_posn_data.pay_freq_payroll_id          ,
                p_position_definition_id       =>       p_posn_data.position_definition_id       ,
                p_position_transaction_id      =>       p_posn_data.position_transaction_id      ,
                p_prior_position_id            =>       p_posn_data.prior_position_id            ,
                p_relief_position_id           =>       p_posn_data.relief_position_id           ,
                p_entry_grade_id               =>       p_posn_data.entry_grade_id               ,
                p_successor_position_id        =>       p_posn_data.successor_position_id        ,
                p_supervisor_position_id       =>       p_posn_data.supervisor_position_id       ,
                p_amendment_date               =>       p_posn_data.amendment_date               ,
                p_amendment_recommendation     =>       p_posn_data.amendment_recommendation     ,
                p_amendment_ref_number         =>       p_posn_data.amendment_ref_number         ,
                p_bargaining_unit_cd           =>       p_posn_data.bargaining_unit_cd           ,
                p_comments                     =>       p_posn_data.comments                     ,
                p_current_job_prop_end_date    =>       p_posn_data.current_job_prop_end_date    ,
                p_current_org_prop_end_date    =>       p_posn_data.current_org_prop_end_date    ,
                p_avail_status_prop_end_date   =>       p_posn_data.avail_status_prop_end_date   ,
                p_date_effective               =>       p_posn_data.date_effective               ,
                p_date_end                     =>       p_posn_data.date_end                     ,
                p_earliest_hire_date           =>       p_posn_data.earliest_hire_date           ,
                p_fill_by_date                 =>       p_posn_data.fill_by_date                 ,
                p_frequency                    =>       p_posn_data.frequency                    ,
                p_fte                          =>       p_posn_data.fte                          ,
                p_max_persons                  =>       p_posn_data.max_persons                  ,
                p_name                         =>       p_posn_data.name                         ,
                p_overlap_period               =>       p_posn_data.overlap_period               ,
                p_overlap_unit_cd              =>       p_posn_data.overlap_unit_cd              ,
                p_pay_term_end_day_cd          =>       p_posn_data.pay_term_end_day_cd          ,
                p_pay_term_end_month_cd        =>       p_posn_data.pay_term_end_month_cd        ,
                p_permanent_temporary_flag     =>       p_posn_data.permanent_temporary_flag     ,
                p_permit_recruitment_flag      =>       p_posn_data.permit_recruitment_flag      ,
                p_position_type                =>       p_posn_data.position_type                ,
                p_posting_description          =>       p_posn_data.posting_description          ,
                p_probation_period             =>       p_posn_data.probation_period             ,
                p_probation_period_unit_cd     =>       p_posn_data.probation_period_unit_cd     ,
                p_replacement_required_flag    =>       p_posn_data.replacement_required_flag    ,
                p_review_flag                  =>       p_posn_data.review_flag                  ,
                p_seasonal_flag                =>       p_posn_data.seasonal_flag                ,
                p_security_requirements        =>       p_posn_data.security_requirements        ,
                p_status                       =>       p_posn_data.status                       ,
                p_term_start_day_cd            =>       p_posn_data.term_start_day_cd            ,
                p_term_start_month_cd          =>       p_posn_data.term_start_month_cd          ,
                p_time_normal_finish           =>       p_posn_data.time_normal_finish           ,
                p_time_normal_start            =>       p_posn_data.time_normal_start            ,
                p_update_source_cd             =>       p_posn_data.update_source_cd             ,
                p_working_hours                =>       p_posn_data.working_hours                ,
                p_works_council_approval_flag  =>       p_posn_data.works_council_approval_flag  ,
                p_work_period_type_cd          =>       p_posn_data.work_period_type_cd          ,
                p_work_term_end_day_cd         =>       p_posn_data.work_term_end_day_cd         ,
                p_work_term_end_month_cd       =>       p_posn_data.work_term_end_month_cd       ,
                p_proposed_fte_for_layoff      =>       p_posn_data.proposed_fte_for_layoff      ,
                p_proposed_date_for_layoff     =>       p_posn_data.proposed_date_for_layoff     ,
                p_pay_basis_id                 =>       p_posn_data.pay_basis_id                 ,
                p_supervisor_id                =>       p_posn_data.supervisor_id                ,
                p_copied_to_old_table_flag     =>       p_posn_data.copied_to_old_table_flag     ,
                p_information1                 =>       p_posn_data.information1                 ,
                p_information2                 =>       p_posn_data.information2                 ,
                p_information3                 =>       p_posn_data.information3                 ,
                p_information4                 =>       p_posn_data.information4                 ,
                p_information5                 =>       p_posn_data.information5                 ,
                p_information6                 =>       p_posn_data.information6                 ,
                p_information7                 =>       p_posn_data.information7                 ,
                p_information8                 =>       p_posn_data.information8                 ,
                p_information9                 =>       p_posn_data.information9                 ,
                p_information10                =>       p_posn_data.information10                ,
                p_information11                =>       p_posn_data.information11                ,
                p_information12                =>       p_posn_data.information12                ,
                p_information13                =>       p_posn_data.information13                ,
                p_information14                =>       p_posn_data.information14                ,
                p_information15                =>       p_posn_data.information15                ,
                p_information16                =>       p_posn_data.information16                ,
                p_information17                =>       p_posn_data.information17                ,
                p_information18                =>       p_posn_data.information18                ,
                p_information19                =>       p_posn_data.information19                ,
                p_information20                =>       p_posn_data.information20                ,
                p_information21                =>       p_posn_data.information21                ,
                p_information22                =>       p_posn_data.information22                ,
                p_information23                =>       p_posn_data.information23                ,
                p_information24                =>       p_posn_data.information24                ,
                p_information25                =>       p_posn_data.information25                ,
                p_information26                =>       p_posn_data.information26                ,
                p_information27                =>       p_posn_data.information27                ,
                p_information28                =>       p_posn_data.information28                ,
                p_information29                =>       p_posn_data.information29                ,
                p_information30                =>       p_posn_data.information30                ,
                p_information_category         =>       p_posn_data.information_category         ,
                p_attribute1                   =>       p_posn_data.attribute1                   ,
                p_attribute2                   =>       p_posn_data.attribute2                   ,
                p_attribute3                   =>       p_posn_data.attribute3                   ,
                p_attribute4                   =>       p_posn_data.attribute4                   ,
                p_attribute5                   =>       p_posn_data.attribute5                   ,
                p_attribute6                   =>       p_posn_data.attribute6                   ,
                p_attribute7                   =>       p_posn_data.attribute7                   ,
                p_attribute8                   =>       p_posn_data.attribute8                   ,
                p_attribute9                   =>       p_posn_data.attribute9                   ,
                p_attribute10                  =>       p_posn_data.attribute10                  ,
                p_attribute11                  =>       p_posn_data.attribute11                  ,
                p_attribute12                  =>       p_posn_data.attribute12                  ,
                p_attribute13                  =>       p_posn_data.attribute13                  ,
                p_attribute14                  =>       p_posn_data.attribute14                  ,
                p_attribute15                  =>       p_posn_data.attribute15                  ,
                p_attribute16                  =>       p_posn_data.attribute16                  ,
                p_attribute17                  =>       p_posn_data.attribute17                  ,
                p_attribute18                  =>       p_posn_data.attribute18                  ,
                p_attribute19                  =>       p_posn_data.attribute19                  ,
                p_attribute20                  =>       p_posn_data.attribute20                  ,
                p_attribute21                  =>       p_posn_data.attribute21                  ,
                p_attribute22                  =>       p_posn_data.attribute22                  ,
                p_attribute23                  =>       p_posn_data.attribute23                  ,
                p_attribute24                  =>       p_posn_data.attribute24                  ,
                p_attribute25                  =>       p_posn_data.attribute25                  ,
                p_attribute26                  =>       p_posn_data.attribute26                  ,
                p_attribute27                  =>       p_posn_data.attribute27                  ,
                p_attribute28                  =>       p_posn_data.attribute28                  ,
                p_attribute29                  =>       p_posn_data.attribute29                  ,
                p_attribute30                  =>       p_posn_data.attribute30                  ,
                p_attribute_category           =>       p_posn_data.attribute_category           ,
		p_request_id                   =>	p_posn_data.request_id                   ,
		p_program_application_id       =>	p_posn_data.program_application_id       ,
		p_program_id                   =>	p_posn_data.program_id                   ,
		p_program_update_date          =>	p_posn_data.program_update_date          ,
		p_object_version_number        =>	p_posn_data.object_version_number        ,
                p_datetrack_mode               =>       l_datetrack_mode                         ,
                p_effective_date               =>       p_posn_data.effective_start_date
		);
	l_position_data_rec.position_id	:= p_posn_data.position_id;
	l_position_data_rec.organization_id	:= p_posn_data.organization_id;
    	l_position_data_rec.job_id		:= p_posn_data.job_id;
        -- Line Added by Edward Nunez 17-APR-2000 for bug# 1268773
        -- l_position_data_rec.effective_date      := p_posn_data.effective_start_date;
        -- Changes made by Venkat 30-JAN-2003 for No Copy Changes
        -- Assigning l_date1 instaed of p_posn_data.effective_start date because of nocopy changes
        l_position_data_rec.effective_date      := l_date2;
    	hr_utility.set_location(l_proc || 'change in data element-pos ' || p_posn_data.job_id,15);

    ghr_sf52_pos_update.update_position_info
                        (p_pos_data_rec   =>  l_position_data_rec
                        );

	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
Exception
When Others then
   -- RESET In/Out Params and SET Out Params
   p_posn_data:=l_posn_data;
   hr_utility.set_location( 'Leaving : ' || l_proc, 25);
   Raise;

End Correct_posn_Row;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_addresses_row>------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_addresses table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_addr_data		->	per_addresses record that is being applied.
--
-- Post Success:
-- 	per_addresses record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure correct_addresses_row( p_addr_data	in out nocopy per_addresses%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_addr is
	select object_version_number
	from per_addresses
	where address_id = p_addr_data.address_id;

	l_addr_data	per_addresses%rowtype;
	l_session_var	ghr_history_api.g_session_var_type;
	l_proc		varchar2(30):='correct_addresses_row';

Begin
	hr_utility.set_location(' entering : ' || l_proc, 10);
	--Initialise Local Variables
	l_addr_data := p_addr_data;
	--
	ghr_history_api.get_g_session_var( l_session_var);
	hr_utility.set_location(l_proc, 20);

	open c_addr;
	fetch c_addr into p_addr_data.object_version_number;
	if c_addr%notfound then
		hr_utility.set_location(l_proc, 21);
		close c_addr;
	      hr_utility.set_message(8301, 'GHR_38373_ADDRESS_OVN_NFND');
	      hr_utility.raise_error;
	end if;
	close c_addr;
	hr_utility.set_location(l_proc, 30);

	per_add_upd.upd(
		p_address_id                   => p_addr_data.address_id ,
		p_date_from                    => p_addr_data.date_from ,
		p_address_line1                => p_addr_data.address_line1 ,
		p_address_line2                => p_addr_data.address_line2 ,
		p_address_line3                => p_addr_data.address_line3 ,
		p_address_type                 => p_addr_data.address_type ,
		p_comments                     => p_addr_data.comments ,
		p_country                      => p_addr_data.country ,
		p_date_to                      => p_addr_data.date_to ,
		p_postal_code                  => p_addr_data.postal_code ,
		p_region_1                     => p_addr_data.region_1 ,
		p_region_2                     => p_addr_data.region_2 ,
		p_region_3                     => p_addr_data.region_3 ,
		p_telephone_number_1           => p_addr_data.telephone_number_1 ,
		p_telephone_number_2           => p_addr_data.telephone_number_2 ,
		p_telephone_number_3           => p_addr_data.telephone_number_3 ,
		p_town_or_city                 => p_addr_data.town_or_city ,
		p_object_version_number        => p_addr_data.object_version_number ,
		p_effective_date               => l_session_var.date_effective);
 	hr_utility.set_location(' leaving : ' || l_proc, 40);

Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_addr_data:=l_addr_data;
   hr_utility.set_location( 'Leaving : ' || l_proc, 45);
   Raise;

End correct_addresses_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< correct_perana_row>---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies the record given to the per_person_analyses table.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_perana_data		->	per_person_analyses record that is being applied.
--
-- Post Success:
-- 	per_person_analyses record will have been applied.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure correct_perana_row( p_perana_data	in out nocopy per_person_analyses%rowtype) is

	-- this cursor gets the object_version_number from core table, so the core
	-- table can be updated.
	cursor c_perana is
	select object_version_number
	from per_person_analyses
	where person_analysis_id = p_perana_data.person_analysis_id;

	l_perana_data	per_person_analyses%rowtype;
	l_session_var	ghr_history_api.g_session_var_type;
	l_proc		varchar2(30):='correct_perana_row';

Begin
	hr_utility.set_location(' entering : ' || l_proc, 10);
	-- Initialise Local Variables
   	   l_perana_data := p_perana_data;
	--

	ghr_history_api.get_g_session_var( l_session_var);
	hr_utility.set_location(l_proc, 20);

	open c_perana;
	fetch c_perana into p_perana_data.object_version_number;
	if c_perana%notfound then
		hr_utility.set_location(l_proc, 21);
		close c_perana;
	      hr_utility.set_message(8301, 'GHR_99999_PERANA_OVN_NFND');
	      hr_utility.raise_error;
	end if;
	close c_perana;
	hr_utility.set_location(l_proc, 30);

	per_pea_upd.upd(
		p_person_analysis_id      	=>	p_perana_data.person_analysis_id,
  		p_analysis_criteria_id        =>	p_perana_data.analysis_criteria_id,
  		p_comments                    =>	p_perana_data.comments,
  		p_date_from                   =>	p_perana_data.date_from,
  		p_date_to                     =>	p_perana_data.date_to,
  		p_id_flex_num                 =>	p_perana_data.id_flex_num,
  		p_attribute_category          =>	p_perana_data.attribute_category,
  		p_attribute1                  =>	p_perana_data.attribute1,
  		p_attribute2                  =>	p_perana_data.attribute2,
  		p_attribute3                  =>	p_perana_data.attribute3,
  		p_attribute4                  =>	p_perana_data.attribute4,
  		p_attribute5                  =>	p_perana_data.attribute5,
  		p_attribute6                  =>	p_perana_data.attribute6,
		p_attribute7                  =>	p_perana_data.attribute7,
		p_attribute8                  =>	p_perana_data.attribute8,
		p_attribute9                  =>	p_perana_data.attribute9,
  		p_attribute10                 =>	p_perana_data.attribute10,
   		p_attribute11                 =>	p_perana_data.attribute11,
    		p_attribute12                 =>	p_perana_data.attribute12,
    		p_attribute13                 =>	p_perana_data.attribute13,
    		p_attribute14                 =>	p_perana_data.attribute14,
    		p_attribute15                 =>	p_perana_data.attribute15,
   		p_attribute16                 =>	p_perana_data.attribute16,
   		p_attribute17                 =>	p_perana_data.attribute17,
    		p_attribute18                 =>	p_perana_data.attribute18,
    		p_attribute19                 =>	p_perana_data.attribute19,
    		p_attribute20                 =>	p_perana_data.attribute20,
  		p_object_version_number       =>	p_perana_data.object_version_number
  	);

 	hr_utility.set_location(' leaving : ' || l_proc, 40);

Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_perana_data:=l_perana_data;
   hr_utility.set_location( 'Leaving : ' || l_proc, 45);
   Raise;

End correct_perana_row;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_change>-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure calls cascade_field_value to cascade changes for every field
--	in ghr_pa_hisory record. it also handles the dependent fields by calling
--	cascade_dependencies if information101 field needs to be cascaded.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pre_record		->	contains row as it appeared prior to this action.
--	p_post_record		->	contains row as it appeared after this action
--	p_apply_record		->	contains the row that we are (possibly) applying the
--						cascaded data to.
--	p_true_false		-> 	contains true_false flags for all fields to indicate if
--						the given field is still in need of cascading.
--
-- Post Success:
-- 	The changes will have been cascaded the the p_apply_record as appropriate.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure cascade_change(p_pre_record           in     ghr_pa_history%rowtype,
                         p_post_record          in     ghr_pa_history%rowtype,
                         p_apply_record         in out nocopy ghr_pa_history%rowtype,
                         p_true_false           in out nocopy ghr_history_cascade.condition_rg_type)
is

	l_apply_record	ghr_pa_history%rowtype;
	l_true_false	ghr_history_cascade.condition_rg_type;
	l_proc   varchar2(72) := 'cascade_change';

Begin
      hr_utility.set_location('Entering  ' || l_proc,5);
      --Initialise Local variables
      l_apply_record:=p_apply_record;
      l_true_false:=p_true_false;
      --

-- Information1, Information2 and Information3 will not be cascaded as it is reserved for
-- Table Primary Key, effective_start_date and Effective_end_date respectively

-- Bug 1161542
  /*    hr_utility.set_location(l_proc,10);
	cascade_field_value
	(p_pre_field   => p_pre_record.information4,
 	 p_post_field  => p_post_record.information4,
 	 p_apply_field => p_apply_record.information4,
 	 p_result      => p_true_false(4)
	);

      hr_utility.set_location(l_proc,15);
	cascade_field_value
	(p_pre_field   => p_pre_record.information5,
 	 p_post_field  => p_post_record.information5,
 	 p_apply_field => p_apply_record.information5,
 	 p_result      => p_true_false(5)
	);

      hr_utility.set_location(l_proc,20);
	cascade_field_value
	(p_pre_field   => p_pre_record.information6,
 	 p_post_field  => p_post_record.information6,
 	 p_apply_field => p_apply_record.information6,
 	 p_result      => p_true_false(6)
	); */ -- Bug 1161542

      hr_utility.set_location(l_proc,25);
	---Added for Bug  3413335
	      IF p_post_record.table_name <>  ghr_history_api.g_perana_table THEN
     		hr_utility.set_location(l_proc,34);
                 cascade_field_value
		(p_pre_field   => p_pre_record.information7,
 		 p_post_field  => p_post_record.information7,
 		 p_apply_field => p_apply_record.information7,
 		 p_result      => p_true_false(7)
		);
	     ELSE
               IF p_post_record.information11 is not null THEN
                 hr_utility.set_location(l_proc,36);
		cascade_field_value
		(p_pre_field   => p_pre_record.information7,
 		 p_post_field  => p_post_record.information7,
 		 p_apply_field => p_apply_record.information7,
 		 p_result      => p_true_false(7)
		);
        	END IF;
             END IF;

      hr_utility.set_location(l_proc,30);
	---Added for Bug  3413335
	      IF p_post_record.table_name <>  ghr_history_api.g_perana_table THEN
     		hr_utility.set_location(l_proc,34);
                 cascade_field_value
	         (p_pre_field   => p_pre_record.information8,
 	          p_post_field  => p_post_record.information8,
 	          p_apply_field => p_apply_record.information8,
 	 	  p_result      => p_true_false(8)
		 );
	     ELSE
               IF p_post_record.information11 is not null THEN
                 hr_utility.set_location(l_proc,36);
		cascade_field_value
		(p_pre_field   => p_pre_record.information8,
 		 p_post_field  => p_post_record.information8,
 		 p_apply_field => p_apply_record.information8,
 		 p_result      => p_true_false(8)
		);
        	END IF;
             END IF;

	if (p_post_record.table_name = ghr_history_api.g_addres_table) then
		if (p_true_false(9) = FALSE) then
			null;
		else
			If  (nvl(p_pre_record.information9,hr_api.g_varchar2) <> nvl(p_post_record.information9,hr_api.g_varchar2) or
				nvl(p_pre_record.information10,hr_api.g_varchar2) <> nvl(p_post_record.information10,hr_api.g_varchar2) or
				nvl(p_pre_record.information11,hr_api.g_varchar2) <> nvl(p_post_record.information11,hr_api.g_varchar2) or
				nvl(p_pre_record.information14,hr_api.g_varchar2) <> nvl(p_post_record.information14,hr_api.g_varchar2) or
				nvl(p_pre_record.information16,hr_api.g_varchar2) <> nvl(p_post_record.information16,hr_api.g_varchar2) or
				nvl(p_pre_record.information17,hr_api.g_varchar2) <> nvl(p_post_record.information17,hr_api.g_varchar2) or
				nvl(p_pre_record.information18,hr_api.g_varchar2) <> nvl(p_post_record.information18,hr_api.g_varchar2) or
				nvl(p_pre_record.information19,hr_api.g_varchar2) <> nvl(p_post_record.information19,hr_api.g_varchar2) or
				nvl(p_pre_record.information23,hr_api.g_varchar2) <> nvl(p_post_record.information23,hr_api.g_varchar2)) and
                      	(nvl(p_pre_record.information9,hr_api.g_varchar2)  =   nvl(p_apply_record.information9,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information10,hr_api.g_varchar2)  =   nvl(p_apply_record.information10,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information11,hr_api.g_varchar2)  =   nvl(p_apply_record.information11,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information14,hr_api.g_varchar2)  =   nvl(p_apply_record.information14,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information16,hr_api.g_varchar2)  =   nvl(p_apply_record.information16,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information17,hr_api.g_varchar2)  =   nvl(p_apply_record.information17,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information18,hr_api.g_varchar2)  =   nvl(p_apply_record.information18,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information19,hr_api.g_varchar2)  =   nvl(p_apply_record.information19,hr_api.g_varchar2) and
                       	nvl(p_pre_record.information23,hr_api.g_varchar2)  =   nvl(p_apply_record.information23,hr_api.g_varchar2))
			 then
			    	hr_utility.set_location(l_proc,20);
			    	p_apply_record.information9  :=  p_post_record.information9;
			    	p_apply_record.information10  :=  p_post_record.information10;
			    	p_apply_record.information11  :=  p_post_record.information11;
			    	p_apply_record.information14  :=  p_post_record.information14;
			    	p_apply_record.information16  :=  p_post_record.information16;
			    	p_apply_record.information17  :=  p_post_record.information17;
			    	p_apply_record.information18  :=  p_post_record.information18;
			    	p_apply_record.information19  :=  p_post_record.information19;
				p_apply_record.information23  :=  p_post_record.information23;
			else
			    	p_true_false(9) := FALSE;
			    	p_true_false(10) := FALSE;
			    	p_true_false(11) := FALSE;
			    	p_true_false(14) := FALSE;
			    	p_true_false(16) := FALSE;
			    	p_true_false(17) := FALSE;
			    	p_true_false(18) := FALSE;
			    	p_true_false(19) := FALSE;
			    	p_true_false(23) := FALSE;
			end if;
		end if;
	else
	      hr_utility.set_location(l_proc,35);
		 ---Added for Bug  3413335
	      IF p_post_record.table_name <>  ghr_history_api.g_perana_table THEN
     		hr_utility.set_location(l_proc,34);
		cascade_field_value
		(p_pre_field   => p_pre_record.information9,
 		 p_post_field  => p_post_record.information9,
 		 p_apply_field => p_apply_record.information9,
 		 p_result      => p_true_false(9)
		);
	     ELSE
               IF p_post_record.information11 is not null THEN
                 hr_utility.set_location(l_proc,36);
		 cascade_field_value
		(p_pre_field   => p_pre_record.information9,
 		 p_post_field  => p_post_record.information9,
 		 p_apply_field => p_apply_record.information9,
 		 p_result      => p_true_false(9)
		);
        	END IF;
             END IF;

	      hr_utility.set_location(l_proc,40);
		---Added for Bug  3413335
	      IF p_post_record.table_name <>  ghr_history_api.g_perana_table THEN
     		hr_utility.set_location(l_proc,44);
		cascade_field_value
		(p_pre_field   => p_pre_record.information10,
 		 p_post_field  => p_post_record.information10,
 		 p_apply_field => p_apply_record.information10,
 		 p_result      => p_true_false(10)
		);
	     ELSE
               IF p_post_record.information11 is not null THEN
                 hr_utility.set_location(l_proc,46);
		 cascade_field_value
		(p_pre_field   => p_pre_record.information10,
 		 p_post_field  => p_post_record.information10,
 		 p_apply_field => p_apply_record.information10,
 		 p_result      => p_true_false(10)
		);
        	END IF;
             END IF;

             -- Start processing for Bug  3413335
             IF p_post_record.table_name <>  ghr_history_api.g_perana_table THEN
     		hr_utility.set_location(l_proc,45);
		cascade_field_value
		(p_pre_field   => p_pre_record.information11,
 		 p_post_field  => p_post_record.information11,
 		 p_apply_field => p_apply_record.information11,
 		 p_result      => p_true_false(11)
		);
             ELSE
               IF p_post_record.information11 is not null THEN
                 hr_utility.set_location(l_proc,45);
		 cascade_field_value
		 (p_pre_field   => p_pre_record.information11,
 		 p_post_field  => p_post_record.information11,
 		 p_apply_field => p_apply_record.information11,
 		 p_result      => p_true_false(11)
                 );
               END IF;
             END IF;
             -- End processing for Bug  3413335

      	hr_utility.set_location(l_proc,60);
		cascade_field_value
		(p_pre_field   => p_pre_record.information14,
 		 p_post_field  => p_post_record.information14,
 		 p_apply_field => p_apply_record.information14,
 		 p_result      => p_true_false(14)
		);

     		hr_utility.set_location(l_proc,70);
		cascade_field_value
		(p_pre_field   => p_pre_record.information16,
 		 p_post_field  => p_post_record.information16,
 		 p_apply_field => p_apply_record.information16,
 		 p_result      => p_true_false(16)
		);

	      hr_utility.set_location(l_proc,75);
		cascade_field_value
		(p_pre_field   => p_pre_record.information17,
 		 p_post_field  => p_post_record.information17,
 		 p_apply_field => p_apply_record.information17,
 		 p_result      => p_true_false(17)
		);

     		hr_utility.set_location(l_proc,80);
		cascade_field_value
		(p_pre_field   => p_pre_record.information18,
 		 p_post_field  => p_post_record.information18,
 		 p_apply_field => p_apply_record.information18,
 		 p_result      => p_true_false(18)
		);

     		hr_utility.set_location(l_proc,85);
		cascade_field_value
		(p_pre_field   => p_pre_record.information19,
 		 p_post_field  => p_post_record.information19,
 		 p_apply_field => p_apply_record.information19,
 		 p_result      => p_true_false(19)
		);

     	 	hr_utility.set_location(l_proc,101);
		cascade_field_value
		(p_pre_field   => p_pre_record.information23,
 		 p_post_field  => p_post_record.information23,
 		 p_apply_field => p_apply_record.information23,
 		 p_result      => p_true_false(23)
		);
	end if;
      hr_utility.set_location(l_proc,50);
	cascade_field_value
	(p_pre_field   => p_pre_record.information12,
 	 p_post_field  => p_post_record.information12,
 	 p_apply_field => p_apply_record.information12,
 	 p_result      => p_true_false(12)
	);

      hr_utility.set_location(l_proc,55);
	cascade_field_value
	(p_pre_field   => p_pre_record.information13,
 	 p_post_field  => p_post_record.information13,
 	 p_apply_field => p_apply_record.information13,
 	 p_result      => p_true_false(13)
	);

      hr_utility.set_location(l_proc,65);
	cascade_field_value
	(p_pre_field   => p_pre_record.information15,
 	 p_post_field  => p_post_record.information15,
 	 p_apply_field => p_apply_record.information15,
 	 p_result      => p_true_false(15)
	);

      hr_utility.set_location(l_proc,90);
	cascade_field_value
	(p_pre_field   => p_pre_record.information20,
 	 p_post_field  => p_post_record.information20,
 	 p_apply_field => p_apply_record.information20,
 	 p_result      => p_true_false(20)
	);

      hr_utility.set_location(l_proc,95);
	cascade_field_value
	(p_pre_field   => p_pre_record.information21,
 	 p_post_field  => p_post_record.information21,
 	 p_apply_field => p_apply_record.information21,
 	 p_result      => p_true_false(21)
	);

      hr_utility.set_location(l_proc,100);
	cascade_field_value
	(p_pre_field   => p_pre_record.information22,
 	 p_post_field  => p_post_record.information22,
 	 p_apply_field => p_apply_record.information22,
 	 p_result      => p_true_false(22)
	);

      hr_utility.set_location(l_proc,102);
	cascade_field_value
	(p_pre_field   => p_pre_record.information24,
 	 p_post_field  => p_post_record.information24,
 	 p_apply_field => p_apply_record.information24,
 	 p_result      => p_true_false(24)
	);

      hr_utility.set_location(l_proc,103);
	cascade_field_value
	(p_pre_field   => p_pre_record.information25,
 	 p_post_field  => p_post_record.information25,
 	 p_apply_field => p_apply_record.information25,
 	 p_result      => p_true_false(25)
	);

      hr_utility.set_location(l_proc,104);
	cascade_field_value
	(p_pre_field   => p_pre_record.information26,
 	 p_post_field  => p_post_record.information26,
 	 p_apply_field => p_apply_record.information26,
 	 p_result      => p_true_false(26)
	);

      hr_utility.set_location(l_proc,105);
	cascade_field_value
	(p_pre_field   => p_pre_record.information27,
 	 p_post_field  => p_post_record.information27,
 	 p_apply_field => p_apply_record.information27,
 	 p_result      => p_true_false(27)
	);

      hr_utility.set_location(l_proc,106);
	cascade_field_value
	(p_pre_field   => p_pre_record.information28,
 	 p_post_field  => p_post_record.information28,
 	 p_apply_field => p_apply_record.information28,
 	 p_result      => p_true_false(28)
	);

      hr_utility.set_location(l_proc,107);
	cascade_field_value
	(p_pre_field   => p_pre_record.information29,
 	 p_post_field  => p_post_record.information29,
 	 p_apply_field => p_apply_record.information29,
 	 p_result      => p_true_false(29)
	);

      hr_utility.set_location(l_proc,108);
	cascade_field_value
	(p_pre_field   => p_pre_record.information30,
 	 p_post_field  => p_post_record.information30,
 	 p_apply_field => p_apply_record.information30,
 	 p_result      => p_true_false(30)
	);

      hr_utility.set_location(l_proc,109);
	cascade_field_value
	(p_pre_field   => p_pre_record.information31,
 	 p_post_field  => p_post_record.information31,
 	 p_apply_field => p_apply_record.information31,
 	 p_result      => p_true_false(31)
	);

      hr_utility.set_location(l_proc,110);
	cascade_field_value
	(p_pre_field   => p_pre_record.information32,
 	 p_post_field  => p_post_record.information32,
 	 p_apply_field => p_apply_record.information32,
 	 p_result      => p_true_false(32)
	);

      hr_utility.set_location(l_proc,111);
	cascade_field_value
	(p_pre_field   => p_pre_record.information33,
 	 p_post_field  => p_post_record.information33,
 	 p_apply_field => p_apply_record.information33,
 	 p_result      => p_true_false(33)
	);

      hr_utility.set_location(l_proc,112);
	cascade_field_value
	(p_pre_field   => p_pre_record.information34,
 	 p_post_field  => p_post_record.information34,
 	 p_apply_field => p_apply_record.information34,
 	 p_result      => p_true_false(34)
	);

      hr_utility.set_location(l_proc,113);
      cascade_field_value
	(p_pre_field   => p_pre_record.information35,
 	 p_post_field  => p_post_record.information35,
 	 p_apply_field => p_apply_record.information35,
 	 p_result      => p_true_false(35)
	);

      hr_utility.set_location(l_proc,114);
	cascade_field_value
	(p_pre_field   => p_pre_record.information36,
 	 p_post_field  => p_post_record.information36,
 	 p_apply_field => p_apply_record.information36,
 	 p_result      => p_true_false(36)
	);

      hr_utility.set_location(l_proc,115);
	cascade_field_value
	(p_pre_field   => p_pre_record.information37,
 	 p_post_field  => p_post_record.information37,
 	 p_apply_field => p_apply_record.information37,
 	 p_result      => p_true_false(37)
	);

      hr_utility.set_location(l_proc,116);
      cascade_field_value
	(p_pre_field   => p_pre_record.information38,
 	 p_post_field  => p_post_record.information38,
 	 p_apply_field => p_apply_record.information38,
 	 p_result      => p_true_false(38)
	);

      hr_utility.set_location(l_proc,117);
	cascade_field_value
	(p_pre_field   => p_pre_record.information39,
 	 p_post_field  => p_post_record.information39,
 	 p_apply_field => p_apply_record.information39,
 	 p_result      => p_true_false(39)
	);

      hr_utility.set_location(l_proc,118);
	cascade_field_value
	(p_pre_field   => p_pre_record.information40,
 	 p_post_field  => p_post_record.information40,
 	 p_apply_field => p_apply_record.information40,
 	 p_result      => p_true_false(40)
	);

      hr_utility.set_location(l_proc,119);
	cascade_field_value
	(p_pre_field   => p_pre_record.information41,
 	 p_post_field  => p_post_record.information41,
 	 p_apply_field => p_apply_record.information41,
 	 p_result      => p_true_false(41)
	);

      hr_utility.set_location(l_proc,120);
	cascade_field_value
	(p_pre_field   => p_pre_record.information42,
 	 p_post_field  => p_post_record.information42,
 	 p_apply_field => p_apply_record.information42,
 	 p_result      => p_true_false(42)
	);

      hr_utility.set_location(l_proc,121);
	cascade_field_value
	(p_pre_field   => p_pre_record.information43,
 	 p_post_field  => p_post_record.information43,
 	 p_apply_field => p_apply_record.information43,
 	 p_result      => p_true_false(43)
	);

      hr_utility.set_location(l_proc,122);
	cascade_field_value
	(p_pre_field   => p_pre_record.information44,
 	 p_post_field  => p_post_record.information44,
 	 p_apply_field => p_apply_record.information44,
 	 p_result      => p_true_false(44)
	);

      hr_utility.set_location(l_proc,123);
	cascade_field_value
	(p_pre_field   => p_pre_record.information45,
 	 p_post_field  => p_post_record.information45,
 	 p_apply_field => p_apply_record.information45,
 	 p_result      => p_true_false(45)
	);

      hr_utility.set_location(l_proc,124);
	cascade_field_value
	(p_pre_field   => p_pre_record.information46,
 	 p_post_field  => p_post_record.information46,
 	 p_apply_field => p_apply_record.information46,
 	 p_result      => p_true_false(46)
	);

      hr_utility.set_location(l_proc,125);
	cascade_field_value
	(p_pre_field   => p_pre_record.information47,
 	 p_post_field  => p_post_record.information47,
 	 p_apply_field => p_apply_record.information47,
 	 p_result      => p_true_false(47)
	);

      hr_utility.set_location(l_proc,126);
	cascade_field_value
	(p_pre_field   => p_pre_record.information48,
 	 p_post_field  => p_post_record.information48,
 	 p_apply_field => p_apply_record.information48,
 	 p_result      => p_true_false(48)
	);

      hr_utility.set_location(l_proc,127);
	cascade_field_value
	(p_pre_field   => p_pre_record.information49,
 	 p_post_field  => p_post_record.information49,
 	 p_apply_field => p_apply_record.information49,
 	 p_result      => p_true_false(49)
	);

      hr_utility.set_location(l_proc,128);
	cascade_field_value
	(p_pre_field   => p_pre_record.information50,
 	 p_post_field  => p_post_record.information50,
 	 p_apply_field => p_apply_record.information50,
 	 p_result      => p_true_false(50)
	);

      hr_utility.set_location(l_proc,129);
	cascade_field_value
	(p_pre_field   => p_pre_record.information51,
 	 p_post_field  => p_post_record.information51,
 	 p_apply_field => p_apply_record.information51,
 	 p_result      => p_true_false(51)
	);

      hr_utility.set_location(l_proc,130);
	cascade_field_value
	(p_pre_field   => p_pre_record.information52,
 	 p_post_field  => p_post_record.information52,
 	 p_apply_field => p_apply_record.information52,
 	 p_result      => p_true_false(52)
	);

      hr_utility.set_location(l_proc,131);
	cascade_field_value
	(p_pre_field   => p_pre_record.information53,
 	 p_post_field  => p_post_record.information53,
 	 p_apply_field => p_apply_record.information53,
 	 p_result      => p_true_false(53)
	);

      hr_utility.set_location(l_proc,132);
	cascade_field_value
	(p_pre_field   => p_pre_record.information54,
 	 p_post_field  => p_post_record.information54,
 	 p_apply_field => p_apply_record.information54,
 	 p_result      => p_true_false(54)
	);

      hr_utility.set_location(l_proc,133);
	cascade_field_value
	(p_pre_field   => p_pre_record.information55,
 	 p_post_field  => p_post_record.information55,
 	 p_apply_field => p_apply_record.information55,
 	 p_result      => p_true_false(55)
	);

      hr_utility.set_location(l_proc,134);
	cascade_field_value
	(p_pre_field   => p_pre_record.information56,
 	 p_post_field  => p_post_record.information56,
 	 p_apply_field => p_apply_record.information56,
 	 p_result      => p_true_false(56)
	);

      hr_utility.set_location(l_proc,135);
	cascade_field_value
	(p_pre_field   => p_pre_record.information57,
 	 p_post_field  => p_post_record.information57,
 	 p_apply_field => p_apply_record.information57,
 	 p_result      => p_true_false(57)
	);

      hr_utility.set_location(l_proc,136);
	cascade_field_value
	(p_pre_field   => p_pre_record.information58,
 	 p_post_field  => p_post_record.information58,
 	 p_apply_field => p_apply_record.information58,
 	 p_result      => p_true_false(58)
	);

      hr_utility.set_location(l_proc,137);
	cascade_field_value
	(p_pre_field   => p_pre_record.information59,
 	 p_post_field  => p_post_record.information59,
 	 p_apply_field => p_apply_record.information59,
 	 p_result      => p_true_false(59)
	);

      hr_utility.set_location(l_proc,138);
	cascade_field_value
	(p_pre_field   => p_pre_record.information60,
 	 p_post_field  => p_post_record.information60,
 	 p_apply_field => p_apply_record.information60,
 	 p_result      => p_true_false(60)
	);

      hr_utility.set_location(l_proc,139);
	cascade_field_value
	(p_pre_field   => p_pre_record.information61,
 	 p_post_field  => p_post_record.information61,
 	 p_apply_field => p_apply_record.information61,
 	 p_result      => p_true_false(61)
	);

      hr_utility.set_location(l_proc,140);
	cascade_field_value
	(p_pre_field   => p_pre_record.information62,
 	 p_post_field  => p_post_record.information62,
 	 p_apply_field => p_apply_record.information62,
 	 p_result      => p_true_false(62)
	);

      hr_utility.set_location(l_proc,141);
	cascade_field_value
	(p_pre_field   => p_pre_record.information63,
 	 p_post_field  => p_post_record.information63,
 	 p_apply_field => p_apply_record.information63,
 	 p_result      => p_true_false(63)
	);

      hr_utility.set_location(l_proc,142);
      cascade_field_value
	(p_pre_field   => p_pre_record.information64,
 	 p_post_field  => p_post_record.information64,
 	 p_apply_field => p_apply_record.information64,
 	 p_result      => p_true_false(64)
	);

      hr_utility.set_location(l_proc,143);
	cascade_field_value
	(p_pre_field   => p_pre_record.information65,
 	 p_post_field  => p_post_record.information65,
 	 p_apply_field => p_apply_record.information65,
 	 p_result      => p_true_false(65)
	);

      hr_utility.set_location(l_proc,144);
	cascade_field_value
	(p_pre_field   => p_pre_record.information66,
 	 p_post_field  => p_post_record.information66,
 	 p_apply_field => p_apply_record.information66,
 	 p_result      => p_true_false(66)
	);

      hr_utility.set_location(l_proc,145);
	cascade_field_value
	(p_pre_field   => p_pre_record.information67,
 	 p_post_field  => p_post_record.information67,
 	 p_apply_field => p_apply_record.information67,
 	 p_result      => p_true_false(67)
	);

      hr_utility.set_location(l_proc,146);
	cascade_field_value
	(p_pre_field   => p_pre_record.information68,
 	 p_post_field  => p_post_record.information68,
 	 p_apply_field => p_apply_record.information68,
 	 p_result      => p_true_false(68)
	);

      hr_utility.set_location(l_proc,147);
	cascade_field_value
	(p_pre_field   => p_pre_record.information69,
 	 p_post_field  => p_post_record.information69,
 	 p_apply_field => p_apply_record.information69,
 	 p_result      => p_true_false(69)
	);

      hr_utility.set_location(l_proc,148);
	cascade_field_value
	(p_pre_field   => p_pre_record.information70,
 	 p_post_field  => p_post_record.information70,
 	 p_apply_field => p_apply_record.information70,
 	 p_result      => p_true_false(70)
	);

      hr_utility.set_location(l_proc,149);
	cascade_field_value
	(p_pre_field   => p_pre_record.information71,
 	 p_post_field  => p_post_record.information71,
 	 p_apply_field => p_apply_record.information71,
 	 p_result      => p_true_false(71)
	);

      hr_utility.set_location(l_proc,150);
	cascade_field_value
	(p_pre_field   => p_pre_record.information72,
 	 p_post_field  => p_post_record.information72,
 	 p_apply_field => p_apply_record.information72,
 	 p_result      => p_true_false(72)
	);

      hr_utility.set_location(l_proc,151);
	cascade_field_value
	(p_pre_field   => p_pre_record.information73,
 	 p_post_field  => p_post_record.information73,
 	 p_apply_field => p_apply_record.information73,
 	 p_result      => p_true_false(73)
	);

      hr_utility.set_location(l_proc,152);
	cascade_field_value
	(p_pre_field   => p_pre_record.information74,
 	 p_post_field  => p_post_record.information74,
 	 p_apply_field => p_apply_record.information74,
 	 p_result      => p_true_false(74)
	);

      hr_utility.set_location(l_proc,153);
	cascade_field_value
	(p_pre_field   => p_pre_record.information75,
 	 p_post_field  => p_post_record.information75,
 	 p_apply_field => p_apply_record.information75,
 	 p_result      => p_true_false(75)
	);

      hr_utility.set_location(l_proc,154);
	cascade_field_value
	(p_pre_field   => p_pre_record.information76,
 	 p_post_field  => p_post_record.information76,
 	 p_apply_field => p_apply_record.information76,
 	 p_result      => p_true_false(76)
	);

      hr_utility.set_location(l_proc,155);
	cascade_field_value
	(p_pre_field   => p_pre_record.information77,
 	 p_post_field  => p_post_record.information77,
 	 p_apply_field => p_apply_record.information77,
 	 p_result      => p_true_false(77)
	);

      hr_utility.set_location(l_proc,156);
	cascade_field_value
	(p_pre_field   => p_pre_record.information78,
 	 p_post_field  => p_post_record.information78,
 	 p_apply_field => p_apply_record.information78,
 	 p_result      => p_true_false(78)
	);

      hr_utility.set_location(l_proc,157);
	cascade_field_value
	(p_pre_field   => p_pre_record.information79,
 	 p_post_field  => p_post_record.information79,
 	 p_apply_field => p_apply_record.information79,
 	 p_result      => p_true_false(79)
	);

      hr_utility.set_location(l_proc,158);
	cascade_field_value
	(p_pre_field   => p_pre_record.information80,
 	 p_post_field  => p_post_record.information80,
 	 p_apply_field => p_apply_record.information80,
 	 p_result      => p_true_false(80)
	);

      hr_utility.set_location(l_proc,159);
	cascade_field_value
	(p_pre_field   => p_pre_record.information81,
 	 p_post_field  => p_post_record.information81,
 	 p_apply_field => p_apply_record.information81,
 	 p_result      => p_true_false(81)
	);

      hr_utility.set_location(l_proc,160);
	cascade_field_value
	(p_pre_field   => p_pre_record.information82,
 	 p_post_field  => p_post_record.information82,
 	 p_apply_field => p_apply_record.information82,
 	 p_result      => p_true_false(82)
	);

      hr_utility.set_location(l_proc,161);
	cascade_field_value
	(p_pre_field   => p_pre_record.information83,
 	 p_post_field  => p_post_record.information83,
 	 p_apply_field => p_apply_record.information83,
 	 p_result      => p_true_false(83)
	);

      hr_utility.set_location(l_proc,162);
	cascade_field_value
	(p_pre_field   => p_pre_record.information84,
 	 p_post_field  => p_post_record.information84,
 	 p_apply_field => p_apply_record.information84,
 	 p_result      => p_true_false(84)
	);

      hr_utility.set_location(l_proc,163);
	cascade_field_value
	(p_pre_field   => p_pre_record.information85,
 	 p_post_field  => p_post_record.information85,
 	 p_apply_field => p_apply_record.information85,
 	 p_result      => p_true_false(85)
	);

      hr_utility.set_location(l_proc,164);
	cascade_field_value
	(p_pre_field   => p_pre_record.information86,
 	 p_post_field  => p_post_record.information86,
 	 p_apply_field => p_apply_record.information86,
 	 p_result      => p_true_false(86)
	);

      hr_utility.set_location(l_proc,165);
	cascade_field_value
	(p_pre_field   => p_pre_record.information87,
 	 p_post_field  => p_post_record.information87,
 	 p_apply_field => p_apply_record.information87,
 	 p_result      => p_true_false(87)
	);

      hr_utility.set_location(l_proc,166);
	cascade_field_value
	(p_pre_field   => p_pre_record.information88,
 	 p_post_field  => p_post_record.information88,
 	 p_apply_field => p_apply_record.information88,
 	 p_result      => p_true_false(88)
	);

      hr_utility.set_location(l_proc,167);
	cascade_field_value
	(p_pre_field   => p_pre_record.information89,
 	 p_post_field  => p_post_record.information89,
 	 p_apply_field => p_apply_record.information89,
 	 p_result      => p_true_false(89)
	);

      hr_utility.set_location(l_proc,168);
	cascade_field_value
	(p_pre_field   => p_pre_record.information90,
 	 p_post_field  => p_post_record.information90,
 	 p_apply_field => p_apply_record.information90,
 	 p_result      => p_true_false(90)
	);

      hr_utility.set_location(l_proc,169);
	cascade_field_value
	(p_pre_field   => p_pre_record.information91,
 	 p_post_field  => p_post_record.information91,
 	 p_apply_field => p_apply_record.information91,
 	 p_result      => p_true_false(91)
	);

      hr_utility.set_location(l_proc,170);
	cascade_field_value
	(p_pre_field   => p_pre_record.information92,
 	 p_post_field  => p_post_record.information92,
 	 p_apply_field => p_apply_record.information92,
 	 p_result      => p_true_false(92)
	);

      hr_utility.set_location(l_proc,171);
	cascade_field_value
	(p_pre_field   => p_pre_record.information93,
 	 p_post_field  => p_post_record.information93,
 	 p_apply_field => p_apply_record.information93,
 	 p_result      => p_true_false(93)
	);

      hr_utility.set_location(l_proc,172);
	cascade_field_value
	(p_pre_field   => p_pre_record.information94,
 	 p_post_field  => p_post_record.information94,
 	 p_apply_field => p_apply_record.information94,
 	 p_result      => p_true_false(94)
	);

      hr_utility.set_location(l_proc,173);
	cascade_field_value
	(p_pre_field   => p_pre_record.information95,
 	 p_post_field  => p_post_record.information95,
 	 p_apply_field => p_apply_record.information95,
 	 p_result      => p_true_false(95)
	);

      hr_utility.set_location(l_proc,174);
	cascade_field_value
	(p_pre_field   => p_pre_record.information96,
 	 p_post_field  => p_post_record.information96,
 	 p_apply_field => p_apply_record.information96,
 	 p_result      => p_true_false(96)
	);

      hr_utility.set_location(l_proc,175);
	cascade_field_value
	(p_pre_field   => p_pre_record.information97,
 	 p_post_field  => p_post_record.information97,
 	 p_apply_field => p_apply_record.information97,
 	 p_result      => p_true_false(97)
	);

      hr_utility.set_location(l_proc,180);
	cascade_field_value
	(p_pre_field   => p_pre_record.information98,
 	 p_post_field  => p_post_record.information98,
 	 p_apply_field => p_apply_record.information98,
 	 p_result      => p_true_false(98)
	);

      hr_utility.set_location(l_proc,181);
	cascade_field_value
	(p_pre_field   => p_pre_record.information99,
 	 p_post_field  => p_post_record.information99,
 	 p_apply_field => p_apply_record.information99,
 	 p_result      => p_true_false(99)
	);

      hr_utility.set_location(l_proc,182);
	cascade_field_value
	(p_pre_field   => p_pre_record.information100,
 	 p_post_field  => p_post_record.information100,
 	 p_apply_field => p_apply_record.information100,
 	 p_result      => p_true_false(100)
	);

      hr_utility.set_location(l_proc,183);
	cascade_field_value
	(p_pre_field   => p_pre_record.information101,
 	 p_post_field  => p_post_record.information101,
 	 p_apply_field => p_apply_record.information101,
 	 p_result      => p_true_false(101)
	);
      hr_utility.set_location('Leaving ' ||l_proc,184);

-- If information101 is supposed to be cascaded, then information102 thru' information125
-- have to be cascaded as well, because of their dependency on the former.

      If p_true_false(101) then
      	hr_utility.set_location(l_proc,185);
		cascade_dependencies(p_record        =>  p_post_record,
					   p_apply_record  =>  p_apply_record
				        );
            hr_utility.set_location(l_proc,190);
	End if;

Exception
When Others then
  --RESET In/Out Params and SET Out Params
  p_apply_record:=l_apply_record;
  p_true_false:=l_true_false;
  hr_utility.set_location('Leaving ' ||l_proc,200);
  Raise;

End cascade_change;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_field_value>--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies changes to p_apply_field under the following conditions:
--	1) 	p_result is true (cascading on this field is still continuing).
--	2) 	p_post_field is not null (we are not cascading nulls).
--	3) 	p_pre_field, p_post_field are NOT the same (this field was changed by the sf52
--		we are processing).
--	4) 	p_apply_field and p_pre_field are the same (subsequent changes have not been made
--		to this row by a later action).
--
--	p_result will be set to false (this will halt any further cascading of this field) under
--	the following conditions:
--	1) if p_post_field is null (we are not cascading nulls).
--	2) if p_pre_field and p_post_field are the same (this field was not changed by the sf52 we are processing).
--	3) If p_pre_field and p_apply_field are NOT the same (a change was made to this row by a subsequent action).
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pre_field			->	contains field as it appeared prior to this action.
--	p_post_field		->	contains field as it appeared after this action.
--	p_apply_field		->	contains the field that we are (possibly) applying the
--						cascaded data to.
--	p_result			-> 	IN/OUT Boolean flag to indicate if this field (still) needs to be cascaded.
--
-- Post Success:
-- 	The changes will have been applied the the p_apply_field as appropriate.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure cascade_field_value( p_pre_field               in     ghr_pa_history.information1%type,
                               p_post_field              in     ghr_pa_history.information1%type,
                               p_apply_field             in out nocopy ghr_pa_history.information1%type,
                               p_result                  in out nocopy    boolean )
is

	l_apply_field	ghr_pa_history.information1%type;
	l_result	boolean;
	l_proc     varchar2(72) := 'cascade_field_value';
begin

-- Proceed only if the column still needs to cascaded. i.e if that column was altered by another SF52, we should
-- stop cascading for that column

      hr_utility.set_location('Entering  ' ||l_proc,5);
      -- Initialise Local Variables
        l_apply_field := p_apply_field;
	l_result      := p_result;
      --
	If p_result then
 		hr_utility.set_location(l_proc,10);
-- removed following line in order to allow cascading of null values.
--		If p_post_field is not null then
			hr_utility.set_location(l_proc,15);
			If  nvl(p_pre_field,hr_api.g_varchar2)  <>  nvl(p_post_field,hr_api.g_varchar2)  and
                      nvl(p_pre_field,hr_api.g_varchar2)  =   nvl(p_apply_field,hr_api.g_varchar2) then
			    hr_utility.set_location(l_proc,20);
			     p_apply_field  :=  p_post_field;
		       Else
				p_result   := FALSE;
			end if;

/* Removed following three lines in order to allow cascading of null values.
		Else
			p_result   := FALSE;
		End if;
*/
	End if;
     	hr_utility.set_location('Leaving  '|| l_proc,25);
Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_apply_field:=l_apply_field;
   p_result:=l_result;
   hr_utility.set_location('Leaving  : '||l_proc,30);
   Raise;

End cascade_field_value;

-- ---------------------------------------------------------------------------
-- |--------------------------< stop_cascade>---------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure loops through the p_true_false records and
--	returns TRUE as soon as it finds a record with a TRUE value. This procedure
--	is used to determine if there are still fields that need to be cascaded for
--	the given row.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_true_false			-> 	array of boolean values to be scanned.
--
-- Post Success:
-- 	The function will have returned the appropriate value.
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
Function Stop_cascade( p_true_false    ghr_history_cascade.condition_rg_type)
Return boolean
is

l_proc   varchar2(72) := 'Stop_cascade';
l_dummy  boolean := FALSE;


Begin
--  If the true_false flags for even one of the columns is TRUE, we have to proceed cascade
--  else if all flags are FALSE, then we can stop cascading.

      hr_utility.set_location('Entering  ' || l_proc,5);
	For rowno in 7..101 loop  -- Bug 1161542 changed 4..101 to 7..101
		If p_true_false(rowno) then
                 	hr_utility.set_location(l_proc,10);
			l_dummy := TRUE;
			exit;
		End if;
 		hr_utility.set_location(l_proc,15);
	End loop;
	hr_utility.set_location(l_proc,20);
	Return l_dummy;
	hr_utility.set_location(l_proc,25);
End stop_cascade;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_dependencies>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies fields 102 thru 120 to p_apply_record.
--	This is meant to be called when information1 field has changed. Information2
--	thru information120 are meant to be dependent on information101 and thus
--	only/always cascaded if information101 needs to be cascaded.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_record			-> 	contains fields to be cascaded.
--	p_apply_record		-> 	record to cascade changes to.
--
-- Post Success:
-- 	Data from p_record will have been applied to p_apply_record for fields
--	information102 thru information120.
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

Procedure cascade_dependencies( p_record         in     ghr_pa_history%rowtype,
                                p_apply_record   in out nocopy ghr_pa_history%rowtype )
is

	l_apply_record	ghr_pa_history%rowtype;
	l_proc          varchar2(72)  := 'cascade_dependencies';
begin

-- Since information102 thru' 125 are always dependent on information101,
-- cascade changes to these columns if information101 is supposed to be cascaded.

	hr_utility.set_location('Entering  ' || l_proc , 5);
	--Initialise Local Variables
	  l_apply_record := p_apply_record;
        --

	p_apply_record.information102  :=  p_record.information102;
	p_apply_record.information103  :=  p_record.information103;
	p_apply_record.information104  :=  p_record.information104;
	p_apply_record.information105  :=  p_record.information105;
	p_apply_record.information106  :=  p_record.information106;
	p_apply_record.information107  :=  p_record.information107;
	p_apply_record.information108  :=  p_record.information108;
	p_apply_record.information109  :=  p_record.information109;
	p_apply_record.information110  :=  p_record.information110;
	p_apply_record.information111  :=  p_record.information111;
	p_apply_record.information112  :=  p_record.information112;
	p_apply_record.information113  :=  p_record.information113;
	p_apply_record.information114  :=  p_record.information114;
	p_apply_record.information115  :=  p_record.information115;
	p_apply_record.information116  :=  p_record.information116;
	p_apply_record.information117  :=  p_record.information117;
	p_apply_record.information118  :=  p_record.information118;
	p_apply_record.information119  :=  p_record.information119;
	p_apply_record.information120  :=  p_record.information120;

	hr_utility.set_location('Leaving  ' || l_proc,10);

Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_apply_record:=l_apply_record;
   hr_utility.set_location('Leaving  ' || l_proc,15);
   Raise;

End cascade_dependencies;

-- ---------------------------------------------------------------------------
-- |--------------------------< fetch_most_recent_record>---------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure fetches the most recent (according to sysdate) record from history
--	for the p_table_name, p_table_pk_id, p_person_id specified.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_table_name		-> 	table name to fetch from.
--	p_table_pk_id		->	table_pk_id of row to be fetched.
--	p_person_id			-> 	person_id the row is associated with.
--	p_history_data		->	fetched record will be returned here.
--	p_result_code		-> 	indicates success or failure. If null,
--						procedure succeeded. Otherwise,
--						contains error message.
--
-- Post Success:
-- 	Row will have been fetched from ghr_pa_history.
--
-- Post Failure:
--   p_result_code will contain failure message.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure Fetch_most_recent_record(
		p_table_name 	 in	varchar2,
		p_table_pk_id	 in	varchar2,
		p_person_id		 in	number,
		p_history_data in out nocopy 	ghr_pa_history%rowtype,
		p_result_code  in out nocopy varchar2
) is

	l_history_data		ghr_pa_history%rowtype;
	l_result_code		varchar2(200);
	l_date_effective	date:=sysdate;
	l_proc 		varchar2(30):='fetch_most_recent_record';

Begin
	-- This procedure passes sysdate for the most recent record to fetch_history_info
	-- Assuming there will be no future action already applied to the extra_information table
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	--Initialise local variables
	  l_history_data := p_history_data;
	  l_result_code  := p_result_code;
	--

	ghr_history_api.fetch_history_info(
		p_table_name	=> p_table_name,
		p_table_pk_id	=> p_table_pk_id,
		p_person_id		=> p_person_id,
		p_date_effective	=> l_date_effective,
		p_hist_data		=> p_history_data,
		p_result_code	=> p_result_code);
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);

Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_history_data:=l_history_data;
   p_result_code:=l_result_code;
   hr_utility.set_location( 'Leaving : ' || l_proc, 25);
Raise;

End fetch_most_recent_record;

-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_pa_req_field>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure applies changes to p_apply_field under the following conditions:
--	1) 	p_result is true (cascading on this field is still continuing).
--	2) 	p_post_field is not null (we are not cascading nulls).
--	3) 	p_pre_field, p_post_field are NOT the same (this field was changed by the sf52
--		we are processing).
--	4) 	p_apply_field and p_pre_field are the same (subsequent changes have not been made
--		to this row by a later action).
--
--	p_result will be set to false (this will halt any further cascading of this field) under
--	the following conditions:
--	1) if p_post_field is null (we are not cascading nulls).
--	2) if p_pre_field and p_post_field are the same (this field was not changed by the sf52 we are processing).
--	3) If p_pre_field and p_apply_field are NOT the same (a change was made to this row by a subsequent action).
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--	p_pre_field			->	contains field as it appeared prior to this action.
--	p_post_field		->	contains field as it appeared after this action.
--	p_apply_field		->	contains the field that we are (possibly) applying the
--						cascaded data to.
--	p_result			-> 	IN/OUT Boolean flag to indicate if this field (still) needs to be cascaded.
--
-- Post Success:
-- 	The changes will have been applied the the p_apply_field as appropriate.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION cascade_pa_req_field(p_refresh_field		in out nocopy varchar2,
					 p_shadow_field		in out nocopy varchar2,
					 p_sf52_field		in out nocopy varchar2,
					p_changed			in out nocopy boolean) return boolean
IS
	l_refresh_field		 varchar2(150);
	l_shadow_field		 varchar2(150);
	l_sf52_field		 varchar2(150);
 	l_changed_boo		 boolean;  -- Created for NOCOPY changes
 	l_changed 		 boolean := FALSE;

	l_proc   varchar2(72) := 'cascade_pa_req_field';

BEGIN
	hr_utility.set_location('entering: ' || l_proc,10);
        -- Initialise Local Variables
	l_refresh_field	:= p_refresh_field;
	l_shadow_field	:= p_shadow_field;
	l_sf52_field	:= p_sf52_field;
 	l_changed_boo   := p_changed;
--
	if (p_refresh_field is not null) then
		If (p_refresh_field <> nvl(p_sf52_field,hr_api.g_varchar2)) then
			if (nvl(p_shadow_field,hr_api.g_varchar2) = nvl(p_sf52_field,hr_api.g_varchar2)) then
				p_shadow_field 	:= p_refresh_field;
				p_sf52_field 	:= p_refresh_field;
				l_changed 		:= TRUE;
				p_changed 		:= TRUE;
			end if;
		end if;
	end if;
/*
-- Currently functionality is limited to copying UE and APUE which have been changed by the
-- user to refresh rg.
-- It is not refreshing the shadoe and sf52 RGs
--
	if (nvl(p_shadow_field,hr_api.g_varchar2) <> nvl(p_sf52_field,hr_api.g_varchar2)) then
		p_refresh_field	:= p_sf52_field;
		l_changed 		:= TRUE;
	else
		-- ie. either field is AP or APUE and user did not change it.
		-- then refresh shadow record group.
		-- this should take care of refreshing shadow table. As desc. are not in shadow table.
		p_shadow_field := p_refresh_field;
	end if;
*/
	hr_utility.set_location('leaving: ' || l_proc,20);
	return l_changed;
Exception
When Others then
   --Reset In/Out Params and SET Out Params
   p_refresh_field	:=l_refresh_field;
   p_shadow_field	:=l_shadow_field;
   p_sf52_field	:=l_sf52_field;
   p_changed	:=l_changed_boo;
   hr_utility.set_location('leaving: ' || l_proc,25);
   Raise;

END;

--
-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_pa_req_field>-------------------------|
-- ---------------------------------------------------------------------------
FUNCTION cascade_pa_req_field(p_refresh_field  in out nocopy  date,
				p_shadow_field  in out nocopy  date,
				p_sf52_field    in out nocopy  date,
				p_changed		in out nocopy boolean) return boolean
IS


 	l_changed_boo      boolean;  -- Created for NOCOPY changes
	l_proc             varchar2(72) := 'cascade_pa_req_field';
	l_changed          boolean := FALSE;
        l_refresh_field    varchar2(150);
        l_shadow_field     varchar2(150);
        l_sf52_field       varchar2(150);
BEGIN
    --
    -- function added on 29-oct-1998 to avoid the conversion problems for date
    -- fields. This overloading function converts the date to varchar and
    -- calls the original cascade_pa_req_field function.
    --
    hr_utility.set_location('entering: ' || l_proc,10);
    --Initialise local variables
    l_refresh_field := fnd_date.date_to_canonical(p_refresh_field);
    l_shadow_field  := fnd_date.date_to_canonical(p_shadow_field);
    l_sf52_field    := fnd_date.date_to_canonical(p_sf52_field);
    l_changed_boo   := p_changed;
    --

    l_changed := cascade_pa_req_field (p_refresh_field => l_refresh_field,
                                       p_shadow_field  => l_shadow_field,
                                       p_sf52_field    => l_sf52_field,
						   p_changed	 => p_changed);

    p_refresh_field := fnd_date.canonical_to_date(l_refresh_field);
    p_shadow_field  := fnd_date.canonical_to_date(l_shadow_field);
    p_sf52_field    := fnd_date.canonical_to_date(l_sf52_field);

    return l_changed;
    hr_utility.set_location('leaving: ' || l_proc,20);

Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_refresh_field	:=l_refresh_field;
   p_shadow_field	:=l_shadow_field;
   p_sf52_field	:=l_sf52_field;
   p_changed	:=l_changed_boo;
   hr_utility.set_location('leaving: ' || l_proc,25);
   Raise;

END;

--
-- ---------------------------------------------------------------------------
-- |--------------------------< copy_pa_req_field>-------------------------|
-- ---------------------------------------------------------------------------
PROCEDURE copy_pa_req_field(	p_refresh_field in out nocopy  date,
					p_sf52_field    in out nocopy  date,
					p_changed	    in out nocopy 	boolean)
IS
	l_proc          varchar2(72) := 'copy_pa_req_field (date)';
	l_changed       boolean := FALSE;
        l_refresh_field varchar2(150);
        l_sf52_field    varchar2(150);
        l_changed_boo	BOOLEAN;
BEGIN

    hr_utility.set_location('entering: ' || l_proc,10);
    --Initialise Local Variables
    l_refresh_field := fnd_date.date_to_canonical(p_refresh_field);
    l_sf52_field    := fnd_date.date_to_canonical(p_sf52_field);
    l_changed_boo   := p_changed;
    --
    copy_pa_req_field (	p_refresh_field 	=> l_refresh_field,
                       	p_sf52_field    	=> l_sf52_field,
				p_changed		=> l_changed);

    p_refresh_field := fnd_date.canonical_to_date(l_refresh_field);
    p_sf52_field    := fnd_date.canonical_to_date(l_sf52_field);

    hr_utility.set_location('leaving: ' || l_proc,20);

Exception
When Others then
   -- RESET In/Out Params and SET Out Params
   p_refresh_field:= l_refresh_field;
   p_sf52_field   := l_sf52_field;
   p_changed      := l_changed_boo;
   hr_utility.set_location('leaving : ' || l_proc,25);
   Raise;

END;

--
-- ---------------------------------------------------------------------------
-- |--------------------------< copy_pa_req_field>-------------------------|
-- ---------------------------------------------------------------------------
PROCEDURE copy_pa_req_field(	p_refresh_field in out nocopy  varchar2,
					p_sf52_field    in out nocopy  varchar2,
					p_changed	    in out nocopy 	boolean)
IS

      l_refresh_field    varchar2(150);
      l_sf52_field       varchar2(150);
      l_changed	 	 BOOLEAN;
      l_proc             varchar2(72) := 'copy_pa_req_field (varchar2)';
BEGIN

   hr_utility.set_location('entering: ' || l_proc,10);
    -- Initialise local variables
   l_refresh_field:= p_refresh_field;
   l_sf52_field   := p_sf52_field;
   l_changed      := p_changed;
    --

    if (p_sf52_field <> p_refresh_field) then
	p_sf52_field := p_refresh_field;
	p_changed := TRUE;
    end if;

    hr_utility.set_location('leaving: ' || l_proc,20);

Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_refresh_field := l_refresh_field;
   p_sf52_field    := l_sf52_field;
   p_changed       := l_changed;
   hr_utility.set_location('leaving: ' || l_proc,25);
   Raise;

END;

--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< cascade_pa_req>-------------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   	This procedure calls cascade_field_value to cascade changes for every field
--	in ghr_pa_hisory record. it also handles the dependent fields by calling
--	cascade_dependencies if information101 field needs to be cascaded.
--
-- Pre-Requisities:
--   	None.
--
-- In Parameters:
--
-- Post Success:
-- 	The changes will have been cascaded the the p_apply_record as appropriate.
--
-- Post Failure:
--   Error would have been displayed to user and exception raised.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure cascade_pa_req(p_rfrsh_rec	      in out nocopy ghr_pa_requests%rowtype,
				 p_shadow_rec           in out nocopy ghr_pa_requests%rowtype,
				 p_sf52_rec			in out nocopy ghr_pa_requests%rowtype,
				 p_changed			in out nocopy boolean)
is

	l_rfrsh_rec		ghr_pa_requests%rowtype;
	l_shadow_rec		ghr_pa_Requests%rowtype;
	l_sf52_rec		ghr_pa_Requests%rowtype;
	l_changed_boo		Boolean;

	l_proc   	        varchar2(72) := 'cascade_pa_req';
	l_changed	        boolean := FALSE;
begin

	-- Only those fields which are in shadow table can be refreshed. And this procedure
	-- must not call cascade_pa_req_field to refresh any other field which is not in the
	-- shadow table.


	hr_utility.set_location('par cascade: annuitant_indicator' || l_proc,15);
	-- Initialise local variables
	   l_rfrsh_rec   := p_rfrsh_rec;
	   l_shadow_Rec  := p_shadow_rec;
	   l_sf52_rec    := p_sf52_rec;
	   l_changed_boo := p_changed;
	 --

	l_changed := cascade_pa_req_field(p_rfrsh_rec.annuitant_indicator,
		               		    p_shadow_rec.annuitant_indicator,
		               		    p_sf52_rec.annuitant_indicator,
						    p_changed);

	hr_utility.set_location('par cascade: annuitant_indicator_desc' || l_proc,15);
	-- if annuitant_indicator has changed than change annuitant_indicator_desc.
	if (l_changed) then
		p_sf52_rec.annuitant_indicator_desc		:= p_rfrsh_rec.annuitant_indicator_desc;
	end if;

	hr_utility.set_location('par cascade: appropriation_code1' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.appropriation_code1,
		               		    p_shadow_rec.appropriation_code1,
		               		    p_sf52_rec.appropriation_code1,
						    p_changed);

	hr_utility.set_location('par cascade: appropriation_code2' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.appropriation_code2,
		               		    p_shadow_rec.appropriation_code2,
		               		    p_sf52_rec.appropriation_code2,
						    p_changed);

	hr_utility.set_location('par cascade: bargaining_unit_status' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.bargaining_unit_status,
		               		    p_shadow_rec.bargaining_unit_status,
		               		    p_sf52_rec.bargaining_unit_status,
						    p_changed);

	hr_utility.set_location('par cascade: citizenship' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.citizenship,
		               		    p_shadow_rec.citizenship,
		               		    p_sf52_rec.citizenship,
						    p_changed);

	hr_utility.set_location('par cascade: duty_station_id' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.duty_station_id,
		               		    p_shadow_rec.duty_station_id,
		               		    p_sf52_rec.duty_station_id,
						    p_changed);

	-- if duty_station_id has changed than change duty_station_desc, and duty_station_code
	if (l_changed) then
		p_sf52_rec.duty_station_desc 		:= p_rfrsh_rec.duty_station_desc ;
		p_sf52_rec.duty_station_code		:= p_rfrsh_rec.duty_station_code;
	end if;

	-- if education_level is cascaded, automatically cascade academic discipline and year degree attained. This is
	-- so that nulls will be cascaded for academic discipline and year degree attained, if necessary.
	hr_utility.set_location('par cascade: education_level' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.education_level,
		               		    p_shadow_rec.education_level,
		               		    p_sf52_rec.education_level,
						    p_changed);

	if l_changed then
		p_sf52_rec.academic_discipline	:=	p_rfrsh_rec.academic_discipline;
		p_shadow_rec.academic_discipline	:=	p_rfrsh_rec.academic_discipline;
		p_sf52_rec.year_degree_attained	:=	p_rfrsh_rec.year_degree_attained;
		p_shadow_rec.year_degree_attained	:=	p_rfrsh_rec.year_degree_attained;
	end if;

	hr_utility.set_location('par cascade: fegli' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.fegli,
		               		    p_shadow_rec.fegli,
		               		    p_sf52_rec.fegli,
						    p_changed);

	-- if fegli has changed than change fegli_desc.
	if (l_changed) then
		p_sf52_rec.fegli_desc 		:= p_rfrsh_rec.fegli_desc ;
	end if;

	hr_utility.set_location('par cascade: flsa_category' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.flsa_category,
		               		    p_shadow_rec.flsa_category,
		               		    p_sf52_rec.flsa_category,
						    p_changed);

	hr_utility.set_location('par cascade: forwarding_address_line1' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_address_line1,
		               		    p_shadow_rec.forwarding_address_line1,
		               		    p_sf52_rec.forwarding_address_line1,
						    p_changed);

	hr_utility.set_location('par cascade: forwarding_address_line2' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_address_line2,
		               		    p_shadow_rec.forwarding_address_line2,
		               		    p_sf52_rec.forwarding_address_line2,
						    p_changed);

	hr_utility.set_location('par cascade: forwarding_address_line3' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_address_line3,
		               		    p_shadow_rec.forwarding_address_line3,
		               		    p_sf52_rec.forwarding_address_line3,
						    p_changed);

	hr_utility.set_location('par cascade: forwarding_country_short_name' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_country_short_name,
		               		    p_shadow_rec.forwarding_country_short_name,
		               		    p_sf52_rec.forwarding_country_short_name,
						    p_changed);

	-- if forwarding country short name has changed than change forwarding country.
	if (l_changed) then
		p_sf52_rec.forwarding_country 	:= p_rfrsh_rec.forwarding_country ;
		p_shadow_rec.forwarding_country 	:= p_rfrsh_rec.forwarding_country ;
	end if;

	hr_utility.set_location('par cascade: forwarding_postal_code' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_postal_code,
		               		    p_shadow_rec.forwarding_postal_code,
		               		    p_sf52_rec.forwarding_postal_code,
						    p_changed);

	hr_utility.set_location('par cascade: forwarding_town_or_city' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_town_or_city,
		               		    p_shadow_rec.forwarding_town_or_city,
		               		    p_sf52_rec.forwarding_town_or_city,
						    p_changed);

	hr_utility.set_location('par cascade: forwarding_country' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.forwarding_region_2,
		               		    p_shadow_rec.forwarding_region_2,
		               		    p_sf52_rec.forwarding_region_2,
						    p_changed);

	hr_utility.set_location('par cascade: functional_class' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.functional_class,
		               		    p_shadow_rec.functional_class,
		               		    p_sf52_rec.functional_class,
						    p_changed);

	hr_utility.set_location('par cascade: pay_rate_determinant' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.pay_rate_determinant,
		               		    p_shadow_rec.pay_rate_determinant,
		               		    p_sf52_rec.pay_rate_determinant,
						    p_changed);

	hr_utility.set_location('par cascade: position_occupied' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.position_occupied,
		               		    p_shadow_rec.position_occupied,
		               		    p_sf52_rec.position_occupied,
						    p_changed);

	hr_utility.set_location('par cascade: retirement_plan' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.retirement_plan,
		               		    p_shadow_rec.retirement_plan,
		               		    p_sf52_rec.retirement_plan,
						    p_changed);

	-- if retirement_plan has changed than change retirement_plan_desc.
	if (l_changed) then
		p_sf52_rec.retirement_plan_desc	:= p_rfrsh_rec.retirement_plan_desc;
	end if;

	hr_utility.set_location('par cascade: supervisory_status' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.supervisory_status,
		               		    p_shadow_rec.supervisory_status,
		               		    p_sf52_rec.supervisory_status,
						    p_changed);

	hr_utility.set_location('par cascade: tenure' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.tenure,
		               		    p_shadow_rec.tenure,
		               		    p_sf52_rec.tenure,
						    p_changed);

	hr_utility.set_location('par cascade: veterans_preference' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.veterans_preference,
		               		    p_shadow_rec.veterans_preference,
		               		    p_sf52_rec.veterans_preference,
						    p_changed);

	hr_utility.set_location('par cascade: veterans_pref_for_rif' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.veterans_pref_for_rif,
		               		    p_shadow_rec.veterans_pref_for_rif,
		               		    p_sf52_rec.veterans_pref_for_rif,
						    p_changed);

	hr_utility.set_location('par cascade: veterans_status' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.veterans_status,
		               		    p_shadow_rec.veterans_status,
		               		    p_sf52_rec.veterans_status,
						    p_changed);

	hr_utility.set_location('par cascade: work_schedule' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.work_schedule,
		               		    p_shadow_rec.work_schedule,
		               		    p_sf52_rec.work_schedule,
						    p_changed);

	-- if work_schedule has changed then change work_schedule_desc.
	if (l_changed) then
		p_sf52_rec.work_schedule_desc		:= p_rfrsh_rec.work_schedule_desc;
		p_shadow_rec.work_schedule_desc	:= p_rfrsh_rec.work_schedule_desc;
	end if;

	hr_utility.set_location('par cascade: part_time_hours' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.part_time_hours,
		               		    p_shadow_rec.part_time_hours,
		               		    p_sf52_rec.part_time_hours,
						    p_changed);

	-- part_time_hours is a special case. We should cascade part_time_hours even if it is null.
	-- so, if part_time_hours was not changed by cascade_pa_req_field and the refresh value for
	-- PTH is null, then we need to handle the cascade here.
	if (not l_changed and p_rfrsh_rec.part_time_hours is null) then
		If (p_sf52_rec.part_time_hours is not null) then
			if (nvl(p_shadow_rec.part_time_hours,hr_api.g_number) = nvl(p_sf52_rec.part_time_hours,hr_api.g_number)) then
				p_changed := TRUE;
				p_shadow_rec.part_time_hours 	:= p_rfrsh_rec.part_time_hours;
				p_sf52_rec.part_time_hours 	:= p_rfrsh_rec.part_time_hours;
			end if;
		end if;
	end if;

	hr_utility.set_location('par cascade: service_comp_date' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.service_comp_date,
		               		    p_shadow_rec.service_comp_date,
		               		    p_sf52_rec.service_comp_date,
						    p_changed);

	hr_utility.set_location('par cascade: to_position_id' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_position_id,
		               		    p_shadow_rec.to_position_id,
		               		    p_sf52_rec.to_position_id,
						    p_changed);

	if p_sf52_rec.first_noa_code not in ('893', '892') then
		if p_sf52_rec.custom_pay_calc_flag <> 'Y' then
			l_changed := cascade_pa_req_field(p_rfrsh_rec.to_step_or_rate,
				               		    p_shadow_rec.to_step_or_rate,
			      	         		    p_sf52_rec.to_step_or_rate,
								    p_changed);
		end if;
	end if;

	hr_utility.set_location('par cascade:  auo premium pay indc' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_auo_premium_pay_indicator,
		               		    p_shadow_rec.to_auo_premium_pay_indicator,
		               		    p_sf52_rec.to_auo_premium_pay_indicator,
						    p_changed);

        -- Bug# 1257515: cascading AUO Amount when auo Ind NOT NULL,
        -- otherwise copying it.
        IF p_sf52_rec.to_auo_premium_pay_indicator IS NOT NULL THEN
  	  hr_utility.set_location('par cascade:  auo premium pay amount' || l_proc,15);
	  l_changed := cascade_pa_req_field(p_rfrsh_rec.to_au_overtime,
		               		    p_shadow_rec.to_au_overtime,
		               		    p_sf52_rec.to_au_overtime,
					    p_changed);
        ELSE
	  copy_pa_req_field(p_rfrsh_rec.to_au_overtime,
			    p_sf52_rec.to_au_overtime,
			    p_changed);
        END IF;

	hr_utility.set_location('par cascade:  to_occ_code' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_occ_code,
		               		    p_shadow_rec.to_occ_code,
		               		    p_sf52_rec.to_occ_code,
						    p_changed);
	if (l_changed) then
		p_sf52_rec.to_job_id			:= p_rfrsh_rec.to_job_id;
	end if;

	hr_utility.set_location('par cascade:  Premium Pay Indc' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_ap_premium_pay_indicator,
		               		    p_shadow_rec.to_ap_premium_pay_indicator,
		               		    p_sf52_rec.to_ap_premium_pay_indicator,
						    p_changed);

        -- Bug# 2196971 : cascading AP Amount when ap Ind NOT NULL,
        -- otherwise copying it.
            IF p_sf52_rec.to_ap_premium_pay_indicator IS NOT NULL THEN
               hr_utility.set_location('par cascade:  ap premium pay amount' || l_proc,15);
               l_changed := cascade_pa_req_field(p_rfrsh_rec.to_availability_pay,
                                                 p_shadow_rec.to_availability_pay,
                                                 p_sf52_rec.to_availability_pay,
                                                 p_changed);
            ELSE
               copy_pa_req_field(p_rfrsh_rec.to_availability_pay,
                                 p_sf52_rec.to_availability_pay,
                                 p_changed);
            END IF;
	hr_utility.set_location('par cascade:  Retention Allowance' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_retention_allowance,
		               		    p_shadow_rec.to_retention_allowance,
		               		    p_sf52_rec.to_retention_allowance,
						    p_changed);

	hr_utility.set_location('par cascade:  Retention Allowance' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_retention_allow_percentage,
		               		    p_shadow_rec.to_retention_allow_percentage,
		               		    p_sf52_rec.to_retention_allow_percentage,
						    p_changed);

	hr_utility.set_location('par cascade:  Superv. Diff' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_supervisory_differential,
		               		    p_shadow_rec.to_supervisory_differential,
		               		    p_sf52_rec.to_supervisory_differential,
						    p_changed);

	hr_utility.set_location('par cascade:  Superv. Diff' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_supervisory_diff_percentage,
		               		    p_shadow_rec.to_supervisory_diff_percentage,
		               		    p_sf52_rec.to_supervisory_diff_percentage,
						    p_changed);

	hr_utility.set_location('par cascade:  Staffing Diff.' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_staffing_differential,
		               		    p_shadow_rec.to_staffing_differential,
		               		    p_sf52_rec.to_staffing_differential,
						    p_changed);

	hr_utility.set_location('par cascade:  Staffing Diff. Percentage' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.to_staffing_diff_percentage,
		               		    p_shadow_rec.to_staffing_diff_percentage,
		               		    p_sf52_rec.to_staffing_diff_percentage,
						    p_changed);

	hr_utility.set_location('par cascade: duty_station_location_id' || l_proc,15);
	l_changed := cascade_pa_req_field(p_rfrsh_rec.duty_station_location_id,
		       		          p_shadow_rec.duty_station_location_id,
		              		    p_sf52_rec.duty_station_location_id,
						    p_changed);

	-- always refresh national_identifier and date_of_birth
	copy_pa_req_field(p_rfrsh_rec.employee_national_identifier,
				p_sf52_rec.employee_national_identifier,
				p_changed);

	copy_pa_req_field(p_rfrsh_rec.employee_date_of_birth,
				p_sf52_rec.employee_date_of_birth,
				p_changed);

	-- Cascade Name
	-- if this a name change family
	-- then retain what-ever user entered
	if p_sf52_rec.noa_family_code = 'CHG_NAME' then
		null;
	else
		-- copy refreshed values from refresh_rec
		copy_pa_req_field(p_rfrsh_rec.employee_first_name,
					p_sf52_rec.employee_first_name,
					p_changed);
		copy_pa_req_field(p_rfrsh_rec.employee_last_name,
					p_sf52_rec.employee_last_name,
					p_changed);
		copy_pa_req_field(p_rfrsh_rec.employee_middle_names,
					p_sf52_rec.employee_middle_names,
					p_changed);
	end if;
	copy_pa_req_field(p_rfrsh_rec.from_adj_basic_pay,
				p_sf52_rec.from_adj_basic_pay,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_agency_code,
				p_sf52_rec.from_agency_code,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_agency_desc,
				p_sf52_rec.from_agency_desc,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_basic_pay,
				p_sf52_rec.from_basic_pay,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_grade_or_level,
				p_sf52_rec.from_grade_or_level,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_locality_adj,
				p_sf52_rec.from_locality_adj,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_occ_code,
				p_sf52_rec.from_occ_code,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_office_symbol,
				p_sf52_rec.from_office_symbol,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_other_pay_amount,
				p_sf52_rec.from_other_pay_amount,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_pay_basis,
				p_sf52_rec.from_pay_basis,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_pay_plan,
				p_sf52_rec.from_pay_plan,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_id,
				p_sf52_rec.from_position_id,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_org_line1,
				p_sf52_rec.from_position_org_line1,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_org_line2,
				p_sf52_rec.from_position_org_line2,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_org_line3,
				p_sf52_rec.from_position_org_line3,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_org_line4,
				p_sf52_rec.from_position_org_line4,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_org_line5,
				p_sf52_rec.from_position_org_line5,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_org_line6,
				p_sf52_rec.from_position_org_line6,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_number,
				p_sf52_rec.from_position_number,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_seq_no,
				p_sf52_rec.from_position_seq_no,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_position_title,
				p_sf52_rec.from_position_title,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_step_or_rate,
				p_sf52_rec.from_step_or_rate,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.from_total_salary,
				p_sf52_rec.from_total_salary,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_id,
				p_sf52_rec.to_position_id,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_grade_id,
				p_sf52_rec.to_grade_id,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_grade_or_level,
				p_sf52_rec.to_grade_or_level,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_office_symbol,
				p_sf52_rec.to_office_symbol,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_organization_id,
				p_sf52_rec.to_organization_id,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_pay_basis,
				p_sf52_rec.to_pay_basis,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_pay_plan,
				p_sf52_rec.to_pay_plan,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_org_line1,
				p_sf52_rec.to_position_org_line1,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_org_line2,
				p_sf52_rec.to_position_org_line2,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_org_line3,
				p_sf52_rec.to_position_org_line3,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_org_line4,
				p_sf52_rec.to_position_org_line4,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_org_line5,
				p_sf52_rec.to_position_org_line5,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_org_line6,
				p_sf52_rec.to_position_org_line6,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_number,
				p_sf52_rec.to_position_number,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_seq_no,
				p_sf52_rec.to_position_seq_no,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_position_title,
				p_sf52_rec.to_position_title,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_basic_pay,
				p_sf52_rec.to_basic_pay,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_locality_adj,
				p_sf52_rec.to_locality_adj,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_adj_basic_pay,
				p_sf52_rec.to_adj_basic_pay,
				p_changed);
	copy_pa_req_field(p_rfrsh_rec.to_total_salary,
				p_sf52_rec.to_total_salary,
				p_changed);

	-- Assignment_id remains same so is not copied from sf52_rec.
Exception
When Others then
   --RESET In/Out Params and SET Out Params
   p_rfrsh_rec	:=l_rfrsh_rec;
   p_shadow_rec	:=l_shadow_rec;
   p_sf52_rec	:=l_sf52_rec;
   p_changed	:=l_changed_boo;
   hr_utility.set_location('leaving: ' || l_proc,25);
   Raise;

end cascade_pa_req;

End ghr_history_cascade;

/
