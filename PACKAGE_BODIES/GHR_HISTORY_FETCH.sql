--------------------------------------------------------
--  DDL for Package Body GHR_HISTORY_FETCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_HISTORY_FETCH" as
/* $Header: ghhisfet.pkb 120.6.12010000.5 2009/06/04 07:40:23 vmididho ship $ */
-- Global Constant
c_not_found		varchar2(30):='not_found';
--made the declaration in header
--g_info_type             per_position_extra_info.information_type%type;

	Procedure Traverse(
		p_pa_history_id		 in number,
		p_root_pa_request_id	 in number,
		p_noa_id			 in number,
		p_information1		 in number,
		p_table_name		 in varchar2,
		p_result			out nocopy boolean,
		p_hist_data			out nocopy ghr_pa_history%rowtype);

	Procedure get_min_hist_id(
		p_pa_request_id	 in	number,
		p_noa_id		 in	number,
		p_pa_history_id	out nocopy	number,
		p_result		out nocopy	boolean);


	Procedure Fetch_for_correction(
		p_table_name			in	varchar2,
		p_information1			in	number	default null,
		p_date_effective			in	date		default null,
		p_altered_pa_request_id		in	number	default null,
		p_noa_id_corrected		in	number	default null,
	  	p_hist_data				out nocopy	ghr_pa_history%rowtype,
		p_result_code			out nocopy	varchar2 );

	Procedure get_hist_rec_ason_max_date(
		p_information1		 in 	varchar2,
		p_max_date_effective	 in	date,
		p_table_name		 in	varchar2,
		p_hist_data			out nocopy	ghr_pa_history%rowtype,
		p_result			out nocopy	Boolean);

	Procedure get_hist_rec_ason_date(
		p_information1		 in 	varchar2,
		p_date_effective		 in	date,
		p_table_name		 in	varchar2,
		p_pa_history_id	 	 in	number,
		p_hist_data			out nocopy	ghr_pa_history%rowtype,
		p_result			out nocopy	Boolean);

	Procedure filter_best_candidate_record(
		p_hist_data			in     ghr_pa_history%rowtype,
		p_pa_req_id_skip		in	 number default NULL,
		p_noa_id_skip		in	 number default NULL,
		p_save_noa_id		in out nocopy number,
		p_save_found		in out nocopy boolean,
		p_save_history_id		in out nocopy number,
		p_save_pa_request_id	in out nocopy number,
		p_save_pa_hist_data	in out nocopy ghr_pa_history%rowtype);

	Procedure fetch_for_histid (
		p_table_name			in	varchar2,
		p_information1			in	number	default null,
		p_date_effective			in	date		default null,
		p_pa_history_id			in	number	default null,
  		p_hist_data				out nocopy	ghr_pa_history%rowtype,
		p_result_code			out nocopy	varchar2 );


	Procedure fetch_for_date_eff(
		p_table_name			in	varchar2,
		p_information1			in	number	default null,
		p_date_effective			in	date		default null,
  		p_hist_data				out nocopy	ghr_pa_history%rowtype,
		p_result_code			out nocopy	varchar2 );


	Procedure Fetch_hist_data(
		p_table_name			in	varchar2,
		p_information1			in	number	default null,
		p_date_effective			in	date		default null,
		p_altered_pa_request_id		in	number	default null,
		p_noa_id_corrected		in	number	default null,
		p_pa_history_id			in	number	default null,
	  	p_hist_data				out nocopy	ghr_pa_history%rowtype,
		p_result_code			out nocopy	varchar2 );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Ghr_History_Fetch> >--------------------------|
-- ----------------------------------------------------------------------------

--
-- This procedue fetches the most recent record as of p_max_date_Effective
-- it also traverses in the correction chain to find the most recent correction of the
-- chain.
--

Procedure	get_hist_rec_ason_max_date(
		p_information1		 in 	varchar2,
		p_max_date_effective	 in	date,
		p_table_name		 in	varchar2,
		p_hist_data			out nocopy	ghr_pa_history%rowtype,
		p_result			out nocopy	Boolean) is


	l_proc			varchar2(30):='get_hist_rec_ason_max_date';

	l_history_id 		number;
	l_root_pa_request_id	number;
	l_noa_id			number;
	l_save_pa_history_data	ghr_pa_history%rowtype;
	l_hist_rec			ghr_pa_history%rowtype;

	l_found			boolean:=FALSE;

	l_root_hist_id_broken	number;
	l_root_pa_req_id_broken	number;

	-- This cursor fetches the most recent record for cp_max_date_effective
	cursor ghr_hist_ndt_canc3 (cp_information1		in varchar2,
					   cp_max_date_effective	in date,
					   cp_table_name			in varchar2) is
		select	*
		from 		ghr_pa_history hist_1
		where 	( altered_pa_request_id is null OR
				  not exists (select 'exists'
							from ghr_pa_history hist_2
							where hist_1.altered_pa_request_id 	= hist_2.pa_request_id
							and   hist_1.information1 		= hist_2.information1
							and   hist_1.nature_of_action_id	= hist_2.nature_of_action_id
							and   hist_1.table_name			= hist_2.table_name)
				)
			and 	information1   = cp_information1
			and	effective_date = cp_max_date_effective
			and   table_name     = cp_table_name
		order by	pa_history_id desc;

Begin

	hr_utility.set_location (' Entering : ' || l_proc, 10);

	for ghr_hist_ndt_canc3_rec in
		ghr_hist_ndt_canc3 (cp_information1		=> p_information1,
			    		  cp_max_date_effective	=> p_max_date_effective,
					  cp_table_name		=> p_table_name)
	Loop
		l_hist_rec	:=	ghr_hist_ndt_canc3_rec;

		filter_best_candidate_record(
			p_hist_data			=> l_hist_rec,
			p_save_noa_id		=> l_noa_id,
			p_save_found		=> l_found,
			p_save_history_id		=> l_history_id,
			p_save_pa_request_id	=> l_root_pa_request_id,
			p_save_pa_hist_data	=> l_save_pa_history_data);

	End loop;

	if not l_found then
		p_result := FALSE;
		hr_utility.set_location( 'NOT FOUND ' || l_proc, 50);
	else
		if l_root_pa_request_id is null then
			-- ie core form change is the pre_record
			-- so no need to traverse.
			p_hist_data := l_save_pa_history_data;
			p_result := TRUE;
		else
			hr_utility.set_location('Selected Root Request Id ' || l_root_pa_request_id || l_proc, 60);
			Traverse(
				p_pa_history_id		=> NULL,
				p_root_pa_request_id	=> l_root_pa_request_id,
				p_noa_id			=> l_noa_id,
				p_information1		=> p_information1,
				p_table_name		=> p_table_name,
				p_result			=> l_found,
				p_hist_data			=> p_hist_data);


			if not l_found then
				p_result := FALSE;
				hr_utility.set_location('Traverse Failed ' || l_proc, 70);
				hr_utility.set_location(' l_root_pa_request_id : ' || l_root_pa_request_id || l_proc, 65);
				hr_utility.set_location(' l_noa_id             : ' || l_noa_id             || l_proc, 65);

			      hr_utility.set_message(8301,'GHR_38496_TRAVERSE_FAILED');
			      hr_utility.raise_error;
			else
				p_result := TRUE;
			end if;
		end if;
	end if;

	hr_utility.set_location (' Leaving : ' || l_proc, 100);

End;

-- This procedure fetched most recent, prior to p_pa_history_id,  on p_date_Effective
-- It also traverses in the chain if it finds the record on p_date_Effective.
Procedure	get_hist_rec_ason_date(
		p_information1		 in 	varchar2,
		p_date_effective		 in	date,
		p_table_name		 in	varchar2,
		p_pa_history_id	 	 in	number,
		p_hist_data			out nocopy	ghr_pa_history%rowtype,
		p_result			out nocopy	Boolean) is


	l_proc			varchar2(30):='get_hist_rec_ason_date';

	l_root_pa_history_id	number;
	l_history_id 		number;
	l_root_pa_request_id	number;
	l_noa_id			number;
	l_save_pa_history_data	ghr_pa_history%rowtype;
	l_hist_rec			ghr_pa_history%rowtype;

	l_found			boolean:=FALSE;

	l_root_hist_id_broken	number;
	l_root_pa_req_id_broken	number;
	l_pa_request_id_for_hist		number;
	l_noa_id_for_hist				number;
	l_root_pa_req_for_pa_req		number;
	l_noa_id_for_pa_req			number;
	-- This cursor fetches records from  history table for table_name = p_table_name
	-- for the same date as cp_date_effective, where row is either a root pa_request record
	-- or core form record with history_id less than cp_root_pa_history_id ie record were created
	-- before cp_root_pa_history_id was created or if it is a broken chain record then its root
	-- must have been created before cp_root_pa_history_id.
	cursor ghr_hist_ndt_canc(cp_root_pa_history_id		in number,
					 cp_information1 			in varchar2,
					 cp_date_effective		in date,
					 cp_pa_history_id			in number,
					 cp_table_name			in varchar2) is
		select	*
		from 		ghr_pa_history hist_1
		where
			-- root request or broken chain)
			( altered_pa_request_id is null OR
			  not exists (select 'exists'
						from ghr_pa_history hist_2
						where hist_1.altered_pa_request_id 	= hist_2.pa_request_id
						and   hist_1.information1		= hist_2.information1
						and   hist_1.nature_of_action_id	= hist_2.nature_of_action_id
						and   hist_1.table_name			= hist_2.table_name)
				)
			-- and pa_history_id of the root of the record must be <= cp_root_pa_history_id
			and  (cp_root_pa_history_id >=
							(select min(pa_history_id)
							from ghr_pa_history
							where pa_request_id =
							(select 	min(pa_request_id)
							from 		ghr_pa_requests
							connect by 	pa_request_id = prior altered_pa_request_id
							start with 	pa_request_id = (select pa_request_id
												from 	ghr_pa_history
												where pa_history_id = hist_1.pa_history_id))
							and nature_of_action_id = hist_1.nature_of_action_id)
				-- or fetch record created by core form change with lower history_id
				OR
				(cp_root_pa_history_id >= hist_1.pa_history_id and
				 hist_1.pa_request_id is null))
				-- Bug #6356058 modified above to pick the latest core form change
				-- with history id greater than the root.
				/*(hist_1.pa_history_id >= cp_root_pa_history_id and
				 hist_1.pa_request_id is null))*/
			and	information1	=  cp_information1
			and 	effective_date	=  cp_date_effective
			and 	pa_history_id	<> cp_pa_history_id
			and	table_name		=  cp_table_name
		order by	pa_history_id desc;

	cursor get_root_hist_id(
		cp_pa_req_id	in	number,
		cp_noa_id		in	number) is
	select min(pa_history_id),
		 min(pa_request_id),
		 min(nature_of_action_id)
	from ghr_pa_history
	where pa_request_id =
		(select 	min(pa_request_id)
		from 		ghr_pa_requests
		connect by 	pa_request_id = prior altered_pa_request_id
		start with 	pa_request_id = cp_pa_req_id)
	and nature_of_action_id = cp_noa_id;

	cursor get_req_and_noa (cp_pa_history_id in number) is
	select
		pa_request_id,
		nature_of_action_id
	from ghr_pa_history
	where pa_history_id = cp_pa_history_id;

Begin

	hr_utility.set_location (' Entering : ' || l_proc, 10);

	open get_req_and_noa( p_pa_history_id);
	fetch get_req_and_noa into
		l_pa_request_id_for_hist,
		l_noa_id_for_hist;
	close get_req_and_noa;

	open get_root_hist_id(
		cp_pa_req_id	=> l_pa_request_id_for_hist,
		cp_noa_id		=> l_noa_id_for_hist) ;
	fetch get_root_hist_id into
		l_root_pa_history_id,
		l_root_pa_req_for_pa_req,
		l_noa_id_for_pa_req;

	if get_root_hist_id%notfound then
		-- error
		close get_root_hist_id;
      	hr_utility.set_message(8301,'GHR_38352_ROOT_HISTID_NFND');
      	hr_utility.raise_error;
	else
		close get_root_hist_id;
		hr_utility.set_location('l_root_pa_req_for_pa_req : ' || l_root_pa_req_for_pa_req || l_proc, 12);
		hr_utility.set_location('l_noa_id_for_pa_req : ' || l_noa_id_for_pa_req || l_proc, 12);

		if	l_root_pa_req_for_pa_req 	= l_pa_request_id_for_hist and
			l_noa_id_for_pa_req		= l_noa_id_for_hist then
			NULL;
		else
			hr_utility.set_location(' Skip settings NULLed' || l_proc, 12);
			l_root_pa_req_for_pa_req	:= NULL;
			l_noa_id_for_pa_req		:= NULL;
		end if;
	end if;

	hr_utility.set_location( 'l_root_pa_history_id :' || l_root_pa_history_id || l_proc, 13);
	hr_utility.set_location( 'p_pa_history_id : ' || p_pa_history_id || l_proc, 13);
	hr_utility.set_location( 'p_information1 : ' || p_information1 || l_proc, 13);
	hr_utility.set_location( 'p_p_table_name : ' || p_table_name || l_proc, 13);
	hr_utility.set_location( 'p_date_Effective : ' || p_date_Effective || l_proc, 13);

	for ghr_hist_ndt_canc_rec in
		ghr_hist_ndt_canc(cp_root_pa_history_id	=> l_root_pa_history_id,
				  	cp_information1		=> p_information1,
				 	cp_date_effective		=> p_date_effective,
				  	cp_pa_history_id		=> p_pa_history_id,
					cp_table_name		=> p_table_name)

	Loop
		l_hist_rec	:=	ghr_hist_ndt_canc_rec;
		filter_best_candidate_record(
			p_hist_data			=> l_hist_rec,
			p_pa_req_id_skip		=> l_root_pa_req_for_pa_req,
			p_noa_id_skip		=> l_noa_id_for_pa_req,
			p_save_noa_id		=> l_noa_id,
			p_save_found		=> l_found,
			p_save_history_id		=> l_history_id,
			p_save_pa_request_id	=> l_root_pa_request_id,
			p_save_pa_hist_data	=> l_save_pa_history_data);
	End loop;

	if not l_found then
		p_result := FALSE;
		hr_utility.set_location( 'NOT FOUND ' || l_proc, 50);
	else
		if l_root_pa_request_id is null then
			-- ie core form change is the pre_record
			-- so no need to traverse.
			p_hist_data := l_save_pa_history_data;
			p_result := TRUE;
		else
			hr_utility.set_location('Selected Root Hist Id ' || l_root_pa_history_id || l_proc, 60);
			hr_utility.set_location('Selected Root Request Id ' || l_root_pa_request_id || l_proc, 60);

			Traverse(
				p_pa_history_id		=> p_pa_history_id,
				p_root_pa_request_id	=> l_root_pa_request_id,
				p_noa_id			=> l_noa_id,
				p_information1		=> p_information1,
				p_table_name		=> p_table_name,
				p_result			=> l_found,
				p_hist_data			=> p_hist_data);

			if not l_found then
				p_result := FALSE;
				hr_utility.set_location(' p_pa_history_id      : ' || p_pa_history_id      || l_proc, 65);
 				hr_utility.set_location(' l_root_pa_request_id : ' || l_root_pa_request_id || l_proc, 65);
				hr_utility.set_location(' l_noa_id             : ' || l_noa_id             || l_proc, 65);

				hr_utility.set_location('Traverse Failed ' || l_proc, 70);
			      hr_utility.set_message(8301,'GHR_38497_TRAVERSE_FAILED');
			      hr_utility.raise_error;
			else
				hr_utility.set_location('Selected Hist Id ' || p_hist_data.pa_history_id || l_proc, 61);
				hr_utility.set_location('Selected PaRequest Id ' || p_hist_data.pa_request_id || l_proc, 62);
				p_result := TRUE;
			end if;
		end if;
	end if;

	hr_utility.set_location (' Leaving : ' || l_proc, 100);

End get_hist_rec_ason_date;

-- This procedure is called by get_hist_rec_ason_max_date and get_hist_rec_ason_date
-- it decides if  p_hist_data is the best candidate record so far.

Procedure filter_best_candidate_record(
		p_hist_data			in     ghr_pa_history%rowtype,
		p_pa_req_id_skip		in	 number default NULL,
		p_noa_id_skip		in	 number default NULL,
		p_save_noa_id		in out nocopy number,
		p_save_found		in out nocopy boolean,
		p_save_history_id		in out nocopy number,
		p_save_pa_request_id	in out nocopy number,
		p_save_pa_hist_data	in out nocopy ghr_pa_history%rowtype) is


	-- this cursor fetches min(pahistory_id) for cp_pa_request_id and cp_nature_of_Action_id
	cursor c_get_min_hist (cp_pa_request_id in number,
				     cp_nature_of_Action_id in number) is
		select
			min(pa_history_id)
		from ghr_pa_history
		where
			pa_request_id 		= cp_pa_request_id
		and	nature_of_action_id	= nvl(cp_nature_of_action_id, nature_of_action_id);

	-- This cursor finds the root pa_request_id
	cursor c_get_root_req (cp_pa_request_id in number) is
		select
			min(pa_request_id)
		from 		ghr_pa_requests
		connect by 	pa_request_id = prior altered_pa_request_id
		start with 	pa_request_id = cp_pa_request_id;

--- Bug 6314442 start
--- Even if the history id is less after checking the core form changes
--- if the pa_request_id is not null check for correction if any ---

   cursor cur_pa_corr is
   select pa_history_id
   from ghr_pa_history
   where effective_date = p_hist_data.effective_date
   and   pa_history_id  > p_save_history_id
   and   information1   = p_hist_data.information1
   and   table_name     = p_hist_data.table_name
   and   pa_request_id  in (select pa_request_id
			    from ghr_pa_requests
			    where pa_notification_id is not null
			    start with pa_request_id 	 = p_hist_data.pa_request_id
			    connect by prior pa_request_id = altered_pa_request_id);

   l_corr_record_found BOOLEAN;
--- Bug 6314442 end


	l_root_hist_id_broken	number;
	l_root_pa_req_id_broken	number;

	l_proc			varchar2(30):='filter_best_candidate_record';

Begin
   l_corr_record_found := FALSE;
	hr_utility.set_location (' Entering : ' || l_proc, 10);
	hr_utility.set_location (' p_hist_data.pa_history_id '	|| p_hist_data.pa_history_id, 11);
	hr_utility.set_location (' p_pa_req_id_skip '			|| p_pa_req_id_skip, 11);
	hr_utility.set_location (' p_noa_id_skip '			|| p_noa_id_skip, 11);

	if p_hist_data.pa_request_id is null then
		-- Core Form change created this record.
		hr_utility.set_location (' Core Form 1' || l_proc, 20);
		if p_hist_data.pa_history_id > nvl(p_save_history_id, 0) then
			hr_utility.set_location (' Accept Core Form 2' || l_proc, 21);
			p_save_found 		:= TRUE;
			p_save_history_id 	:= p_hist_data.pa_history_id;
			p_save_pa_request_id	:= null;
			p_save_noa_id		:= null;
			p_save_pa_hist_data	:= p_hist_data;
		end if;
	elsif p_hist_data.altered_pa_request_id is NULL then
		-- root pa_request_id record.
		hr_utility.set_location (' Root pa req 1' || l_proc, 30);
		if p_hist_data.pa_request_id		= nvl(p_pa_req_id_skip, -1) and
		   p_hist_data.nature_of_action_id	= nvl(p_noa_id_skip, -1) then
			hr_utility.set_location('Skip this record : Hist ID ' || p_hist_data.pa_history_id, 35);
		else

		--Bug 6314442 added to check any corrections are available after manual changes
                 for cur_pa_corr_rec in cur_pa_corr
                 loop
                    l_corr_record_found := TRUE;
                 end loop;

                --Bug 6314442 added l_corr_record_found
		-- Bug # 6976905 added another condition while checking correction record for dual action
			if p_hist_data.pa_history_id > nvl(p_save_history_id, 0) or (l_corr_record_found and nvl(p_hist_data.pa_request_id,'-1') <> nvl(p_save_pa_request_id,'-1')) then
				hr_utility.set_location (' Accept Root pa req 2' || l_proc, 31);
				p_save_found 		:= TRUE;
				p_save_history_id 	:= p_hist_data.pa_history_id;
				p_save_pa_request_id	:= p_hist_data.pa_request_id;
				p_save_noa_id		:= p_hist_data.nature_of_action_id;
				p_save_pa_hist_data	:= p_hist_data;
			end if;
		end if;
	else
		-- Borken chain root
		-- get root pa_request_id
		hr_utility.set_location (' Broken Chain 1' || l_proc, 40);
		open c_get_root_req( p_hist_data.pa_request_id);
		Fetch c_get_root_req into l_root_pa_req_id_broken;
		if c_get_root_req%notfound then
			close c_get_root_req;
			hr_utility.set_location (' Root for Broken Chain not found (Error) ' || l_proc, 41);
			-- this must never happen
			-- raise error;
		else
			close c_get_root_req;
		end if;
		-- get root pa_history_id on the basis of pa_request_id and NOA_id

		open c_get_min_hist ( l_root_pa_req_id_broken,
					    p_hist_data.nature_of_action_id);
		Fetch c_get_min_hist into l_root_hist_id_broken;
		if c_get_min_hist%notfound then
			close c_get_min_hist;
			hr_utility.set_location (' Min Hist not found Broken Chain (Error) ' || l_proc, 42);
			-- this must never happen
			-- raise error;
		else
			close c_get_min_hist;
		end if;

		if l_root_pa_req_id_broken 		= nvl(p_pa_req_id_skip, -1) and
		   p_hist_data.nature_of_action_id	= nvl(p_noa_id_skip, -1) then

			hr_utility.set_location('Skip this record : Hist ID ' || p_hist_data.pa_history_id, 50);
		else
		    if l_root_hist_id_broken > nvl(p_save_history_id, 0) then
 	              	      hr_utility.set_location (' Accept Broken Chain 3' || l_proc, 43);
			      p_save_found 		:= TRUE;
			      p_save_history_id 	:= l_root_hist_id_broken;
			      p_save_pa_request_id	:= l_root_pa_req_id_broken;
			      p_save_noa_id		:= p_hist_data.nature_of_action_id;
			      p_save_pa_hist_data	:= p_hist_data;

			end if;
		end if;
	end if;

	hr_utility.set_location (' p_save_noa_id		 ' || p_save_noa_id, 90);
	hr_utility.set_location (' p_save_history_id	 ' || p_save_history_id, 90);
	hr_utility.set_location (' p_save_pa_request_id	 ' || p_save_pa_request_id, 90);
	hr_utility.set_location (' Leaving : ' || l_proc, 100);


End;


Procedure fetch_for_histid (
	p_table_name			in	varchar2,
	p_information1			in	number	default null,
	p_date_effective			in	date		default null,
	p_pa_history_id			in	number	default null,
  	p_hist_data				out nocopy	ghr_pa_history%rowtype,
	p_result_code			out nocopy	varchar2 )  is

	l_proc			varchar2(30):='Fetch_for_histid';
	l_max_date_effective	date;
	l_date_effective        date;
	l_root_pa_history_id	ghr_pa_history.pa_history_id%type;
	l_hist_data			ghr_pa_history%rowtype;
	l_found			boolean:=FALSE;

	l_result_code		varchar2(30);

	-- This cursor fetches records from history table for table_name = p_table_name
	-- for the same date as cp_date_effective, where row is either a root pa_request record
	-- or core form record with history_id less than cp_root_pa_history_id ie record were created
	-- before cp_root_pa_history_id was created or if it is a broken chain record then its root
	-- must have been created before cp_root_pa_history_id.
	cursor ghr_hist_ndt_canc(cp_root_pa_history_id	in number,
					 cp_information1 		in varchar2,
					 cp_date_effective	in date,
					 cp_pa_history_id		in number,
					 cp_table_name		in varchar2) is
		select	*
		from 		ghr_pa_history		hist_1
		where
			-- root request or broken chain)
			( altered_pa_request_id is null OR
			  not exists (select 'exists'
						from ghr_pa_history hist_2
						where hist_1.altered_pa_request_id 	= hist_2.pa_request_id
						and   hist_1.information1		= hist_2.information1
						and   hist_1.nature_of_action_id	= hist_2.nature_of_action_id)
				)
			-- and pa_history_id of the root of the record must be <= cp_root_pa_history_id
			and  (cp_root_pa_history_id >=
							(select min(pa_history_id)
							from ghr_pa_history
							where pa_request_id =
							(select 	min(pa_request_id)
							from 		ghr_pa_requests
							connect by 	pa_request_id = prior altered_pa_request_id
							start with 	pa_request_id = (select	pa_request_id
												from 	ghr_pa_history
												where	pa_history_id = hist_1.pa_history_id))
							and nature_of_action_id = hist_1.nature_of_action_id)
				-- or fetch record created by core form change with lower history_id
				OR
				(cp_root_pa_history_id >= hist_1.pa_history_id and
				 hist_1.pa_request_id is null))
			and	information1    = cp_information1
			and 	effective_date  = cp_date_effective
			and 	pa_history_id  <> cp_pa_history_id
			and   table_name      = cp_table_name
		order by	pa_history_id desc;

	-- This cursor fetched the date on which te record was created for assignment_ei table
	-- prior to cp_date_effective (ie date of the predecessor record).
	cursor ghr_hist_ndt_canc2 (cp_information1	in varchar2,
					   cp_date_effective	in date,
					   cp_table_name		in varchar2) is
		select	max(effective_date)
		from 		ghr_pa_history hist_1
		where
			-- root request or broken chain)
			( altered_pa_request_id is null OR
			  not exists (select 'exists'
						from ghr_pa_history hist_2
						where hist_1.altered_pa_request_id 	= hist_2.pa_request_id
						and   hist_1.information1		= hist_2.information1
						and   hist_1.nature_of_action_id	= hist_2.nature_of_action_id
						and   hist_1.table_name			= hist_2.table_name)
			)
			and 	information1    = cp_information1
			and 	effective_date   <  cp_date_effective
			and   table_name      = cp_table_name;

-- Bug # 6635881 This cursor fetched the date on which te record was created and correction has
--been done on the same day for eg:- A new position has been created on the same day
--of the RPA Action and doing correction to assign that new position then position details need to be fetched
         cursor ghr_hist_ndt_canc3 (cp_information1	in varchar2,
	   		            cp_date_effective	in date,
				    cp_table_name	in varchar2,
				    cp_pa_history_id	in number) is
		select	max(effective_date)
		from 	ghr_pa_history hist_1
		where
		        -- root request or broken chain)
			( altered_pa_request_id is null OR
			  not exists (select 'exists'
						from ghr_pa_history hist_2
						where hist_1.altered_pa_request_id 	= hist_2.pa_request_id
						and   hist_1.information1		= hist_2.information1
						and   hist_1.nature_of_action_id	= hist_2.nature_of_action_id
						and   hist_1.table_name			= hist_2.table_name)
			 )
			and 	information1    =  cp_information1
			and 	effective_date  =  cp_date_effective
			and     table_name      =  cp_table_name
			and     pa_history_id   <> cp_pa_history_id;



Begin

	/* get pre. */
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	hr_utility.set_location( ' Displaying parameters : ' || l_proc, 11);
	hr_utility.set_location( ' p_table_name            : ' || p_table_name || l_proc, 11);
	hr_utility.set_location( ' p_information1          : ' || p_information1 || l_proc, 11);
	hr_utility.set_location( ' p_pa_history_id         : ' || p_pa_history_id || l_proc, 11);

	get_hist_rec_ason_date(
		p_information1	=> p_information1,
		p_date_effective	=> p_date_effective,
		p_table_name	=> p_table_name,
		p_pa_history_id	=> p_pa_history_id ,
		p_hist_data		=> l_hist_data,
		p_result		=> l_found);
		hr_utility.set_location (' End Loop 1' || l_proc, 60);

	p_hist_data	:=	l_hist_data;

---Bug 2413991 --AVR
	    if not l_found then
           if g_info_type = 'GHR_US_POS_VALID_GRADE' then
		        fetch_for_date_eff(
			        p_table_name	=> p_table_name,
			        p_information1	=> p_information1,
			        p_date_effective	=> p_date_effective,
		  	        p_hist_data		=> l_hist_data,
			        p_result_code	=> l_result_code);

	              p_hist_data	:=	l_hist_data;
                 if l_result_code = c_not_found then
                    l_found := FALSE;
                 else
                    l_found := TRUE;
                 end if;
           end if;
       end if;
---Bug 2413991 --AVR

	if not l_found then
		hr_utility.set_location( 'Loop1 not found ' || l_proc, 70);
		open ghr_hist_ndt_canc2
			(cp_information1		=> p_information1,
			 cp_date_effective	=> p_date_effective,
			 cp_table_name		=> p_table_name);
		fetch ghr_hist_ndt_canc2 into l_max_date_effective;
		if ( l_max_date_effective is null ) then
			/* max function always returns a result, so checking for %NOTFOUND is always false.
		   	   date_effective is a mandatory column, so we can check if there were any rows by
		   	   checking if the max_date_effective is null. */
			   /* handle case where there is no pre here. */
			close ghr_hist_ndt_canc2;
			open ghr_hist_ndt_canc3
			 (cp_information1	=> p_information1,
			  cp_date_effective	=> p_date_effective,
			  cp_table_name		=> p_table_name,
			  cp_pa_history_id      => p_pa_history_id);
			fetch ghr_hist_ndt_canc3 into l_date_effective;
                        if ( l_date_effective is null ) then
			    hr_utility.set_location( 'NOT FOUND ' || l_proc, 80);
			    p_result_code := c_not_found;
      			    close ghr_hist_ndt_canc3;
			else
			    close ghr_hist_ndt_canc3;
			    get_hist_rec_ason_max_date(
				p_information1		=> p_information1,
				p_max_date_effective	=> l_date_effective,
				p_table_name		=> p_table_name,
				p_hist_data		=> l_hist_data,
				p_result		=> l_found);
			    p_hist_data := l_hist_data;
    			    if not l_found then
				/* handle case where there is no pre here. */
				p_result_code := c_not_found;
				hr_utility.set_location (' NOT Found ' || l_proc, 150);
        		    else
				hr_utility.set_location (' Found ' || l_proc, 160);
     			    end if;
			 end if;
  		 else
			close ghr_hist_ndt_canc2;
			hr_utility.set_location( 'l_max_date_effective :  ' || l_max_date_effective || l_proc, 80);
			get_hist_rec_ason_max_date(
				p_information1		=> p_information1,
				p_max_date_effective	=> l_max_date_effective,
				p_table_name		=> p_table_name,
				p_hist_data			=> l_hist_data,
				p_result			=> l_found);
			p_hist_data := l_hist_data;
			if not l_found then
				/* handle case where there is no pre here. */
				p_result_code := c_not_found;
				hr_utility.set_location (' NOT Found ' || l_proc, 150);
			else
				hr_utility.set_location (' Found ' || l_proc, 160);
			end if;
		end if;
	End if;
	hr_utility.set_location (' Leaving ' || l_proc, 112);
End;

Procedure fetch_for_date_eff(
	p_table_name			in	varchar2,
	p_information1			in	number	default null,
	p_date_effective			in	date		default null,
  	p_hist_data				out nocopy	ghr_pa_history%rowtype,
	p_result_code			out nocopy	varchar2 )  is

	l_proc			varchar2(30):='gen_fet1';
	l_max_date_effective	date;
	l_hist_data			ghr_pa_history%rowtype;

	l_found			boolean:=FALSE;

	-- This cursor finds the date of the record which was last created as of cp_date_Effective.
	cursor ghr_hist_post (cp_information1	in	varchar2,
				    cp_date_effective	in	date,
				    cp_table_name		in	varchar2) is
		select	max(effective_date)
		from 		ghr_pa_history hist_1
		where 	( altered_pa_request_id is null OR
				  not exists (select 'exists'
							from ghr_pa_history hist_2
							where hist_1.altered_pa_request_id 	= hist_2.pa_request_id
							and   hist_1.information1	= hist_2.information1
							and   hist_1.nature_of_action_id		= hist_2.nature_of_action_id
							and	hist_1.table_name			=	hist_2.table_name)
				)
			and 	information1	=  cp_information1
			and 	effective_date 	<= cp_date_effective
			and	table_name		=  cp_table_name;

Begin

	/* This part of the procedure will fetch the Pre-record values
	if called before update to database updates the record.
	if update to database has already applied the changes then it
	will return the post-update record. The session variable
	pre-update-record will hold the values which can be used for
	pre-record values
	*/
	hr_utility.set_location( l_proc, 20);
	open ghr_hist_post(
		cp_information1	=> p_information1,
		cp_date_effective	=> p_date_effective,
		cp_table_name	=> p_table_name);

	fetch ghr_hist_post into l_max_date_effective;
	if ( l_max_date_effective is null ) then
		/* max function always returns a result, so checking for %NOTFOUND is always false.
		   date_effective is a mandatory column, so we can check if there were any rows by
		   checking if the max_date_effective is null. */
		hr_utility.set_location( l_proc, 70);
		/* handle case where there is no pre here. */
		p_result_code := c_not_found;
		close ghr_hist_post;
	else
		close ghr_hist_post;
		get_hist_rec_ason_max_date(
			p_information1		=> p_information1,
			p_max_date_effective	=> l_max_date_effective,
			p_table_name		=> p_table_name,
			p_hist_data			=> l_hist_data,
			p_result			=> l_found);

		if not l_found then
			/* handle case where there is no pre here. */
			p_result_code := c_not_found;
			hr_utility.set_location (' NOT Found ' || l_proc, 80);
		else
			hr_utility.set_location (' Found ' || l_proc, 80);
			p_hist_data := l_hist_data;
		end if;
	end if;

	hr_utility.set_location( ' Leaving : ' || l_proc, 100);

End fetch_for_date_eff;


Procedure Traverse(
	p_pa_history_id		 in number,
	p_root_pa_request_id	 in number,
	p_noa_id			 in number,
	p_information1		 in number,
	p_table_name		 in varchar2,
	p_result			out nocopy boolean,
	p_hist_data			out nocopy ghr_pa_history%rowtype) is

	-- This cursor traverses in the correction tree and finds the last node in the chain
	-- other than with history_id = cp_pa_history_id.
	-- Bug 3278827 Added +0 to nature_of_action_id to use GHR_PA_HISTORY_N1 Index.
	cursor ghr_hist_ndt_traverse_corrs(cp_pa_history_id	in	number default hr_api.g_number,
					   cp_pa_request_id	in	number,
					   cp_noa_id		in	number,
					   cp_information1	in	varchar2,
					   cp_table_name	in	varchar2) is
		select	*
		from	ghr_pa_history
		where	information1 	 = cp_information1
		and	pa_history_id	<> nvl(cp_pa_history_id, 0)
		and   table_name         = cp_table_name
		and   pa_request_id in
				(select pa_request_id
				 from ghr_pa_requests
				 start with pa_request_id 		= cp_pa_request_id
				 connect by prior pa_request_id	= altered_pa_request_id)
		and  nature_of_action_id + 0  = cp_noa_id
		order by pa_history_id desc;

	l_hist_data	ghr_pA_history%rowtype;
	l_proc	varchar2(30):='Traverse';
Begin
	-- traverse.
	hr_utility.set_location (' Entering : ' || l_proc, 10);
	hr_utility.set_location ('hist id '  || p_pa_history_id || l_proc, 20);
	hr_utility.set_location ('pa req '   || p_root_pa_request_id || l_proc, 30);
	hr_utility.set_location ('noa Id '   || p_noa_id || l_proc, 40);

	open ghr_hist_ndt_traverse_corrs(
		cp_pa_history_id	=> p_pa_history_id,
		cp_pa_request_id	=> p_root_pa_request_id,
		cp_noa_id		=> p_noa_id,
		cp_information1	=> p_information1,
		cp_table_name	=> p_table_name);

	fetch ghr_hist_ndt_traverse_corrs into l_hist_data;
	p_result:= ghr_hist_ndt_traverse_corrs%found;
	close ghr_hist_ndt_traverse_corrs;
	p_hist_data := l_hist_data;
	hr_utility.set_location ('Hist ID : ' || l_hist_data.pa_history_id, 90);
	hr_utility.set_location ('Leaving : ' || l_proc, 100);
End;

Procedure Fetch_for_correction(
	p_table_name			in	varchar2,
	p_information1			in	number	default null,
	p_date_effective			in	date		default null,
	p_altered_pa_request_id		in	number	default null,
	p_noa_id_corrected		in	number	default null,
  	p_hist_data				out nocopy	ghr_pa_history%rowtype,
	p_result_code			out nocopy	varchar2 ) is

	cursor ghr_hist_corr(
			cp_information1			in	varchar2,
			cp_altered_pa_request_id	in	number,
			cp_noa_id_corrected		in	number,
			cp_table_name			in	varchar2) is
		select 	*
		from		ghr_pa_history
		where		information1		= cp_information1
			and 	nature_of_action_id	= cp_noa_id_corrected
			and	pa_request_id		= cp_altered_pa_request_id
			and	table_name			= cp_table_name;

	l_pa_history_id	number;
	l_result		boolean;
	l_proc		varchar2(30):='Fetch_for_correction';

Begin

	hr_utility.set_location (' Entering ' || l_proc, 10);

	open ghr_hist_corr(
		cp_information1			=> p_information1,
		cp_altered_pa_request_id	=> p_altered_pa_request_id,
		cp_noa_id_corrected		=> p_noa_id_corrected,
		cp_table_name			=> p_table_name) ;

	fetch ghr_hist_corr into p_hist_data;
	if ( ghr_hist_corr%NOTFOUND ) then
		hr_utility.set_location ( l_proc, 20);
		get_min_hist_id(
			p_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id		=> p_noa_id_corrected,
			p_pa_history_id	=> l_pa_history_id,
			p_result		=> l_result);
		if l_result then
			fetch_for_histid (
				p_table_name	=> p_table_name,
				p_information1	=> p_information1,
				p_date_effective	=> p_date_effective,
				p_pa_history_id	=> l_pa_history_id,
				p_hist_data		=> p_hist_data,
				p_result_code	=> p_result_code);
		else
			hr_utility.set_location (' NOT Found ' || l_proc, 40);
			p_result_code := c_not_found;
		end if;
	end if;
	close ghr_hist_corr;
	hr_utility.set_location( 'Leaving : ' || l_proc, 100);

End Fetch_for_correction;


Procedure Fetch_hist_data(
	p_table_name			in	varchar2,
	p_information1			in	number	default null,
	p_date_effective			in	date		default null,
	p_altered_pa_request_id		in	number	default null,
	p_noa_id_corrected		in	number	default null,
	p_pa_history_id			in	number	default null,
  	p_hist_data				out nocopy	ghr_pa_history%rowtype,
	p_result_code			out nocopy	varchar2 ) is

	l_proc		varchar2(30):='Fetch_hist_data';
Begin

	hr_utility.set_location (' Entering ' || l_proc, 10);
	if p_pa_history_id is not null then
		fetch_for_histid (
			p_table_name	=> p_table_name,
			p_information1	=> p_information1,
			p_date_effective	=> p_date_effective,
			p_pa_history_id	=> p_pa_history_id,
		  	p_hist_data		=> p_hist_data,
			p_result_code	=> p_result_code);

	elsif p_altered_pa_request_id is not null and
		p_noa_id_corrected 	is not null		then
		Fetch_for_correction(
			p_table_name		=> p_table_name,
			p_information1		=> p_information1,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
		  	p_hist_data			=> p_hist_data,
			p_result_code		=> p_result_code);

	elsif p_date_effective is not null	then
		fetch_for_date_eff(
			p_table_name	=> p_table_name,
			p_information1	=> p_information1,
			p_date_effective	=> p_date_effective,
		  	p_hist_data		=> p_hist_data,
			p_result_code	=> p_result_code);
	end if;
	hr_utility.set_location (' Leaving ' || l_proc, 100);

End Fetch_hist_data;

--
-- Procedure get_min_hist_id will get the pa_history_id for the pa_request_id and noa
--
Procedure get_min_hist_id(
			p_pa_request_id	 in	number,
			p_noa_id		 in	number,
			p_pa_history_id	out nocopy	number,
			p_result		out nocopy	boolean) is

	cursor get_hist_id
		(cp_pa_request_id	in	number,
		 cp_noa_id		in	number) is
		select pa_history_id
		from 		ghr_pa_history
		where		pa_request_id		= cp_pa_request_id
			and	nature_of_action_id	= cp_noa_id;

	l_proc		varchar2(30):='get_min_hist_id';

Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	open get_hist_id(
		cp_pa_request_id	=> p_pa_request_id,
		cp_noa_id		=> p_noa_id);
	fetch get_hist_id into p_pa_history_id;
	p_result :=  get_hist_id%found;
	close get_hist_id;
	hr_utility.set_location('Leaving:'|| l_proc, 10);

End get_min_hist_id;

/* Following pacakge is redundent
--
--
-- Procedure get_hist_id will get the pa_history_id for the pa_request_id and noa
--
Procedure get_hist_id(
			p_pa_request_id	in	number,
			p_noa_id	in	number,
			p_pa_history_id	out nocopy	number,
			p_result	out nocopy	boolean) is
	cursor get_hist_id is
		select pa_history_id
		from 		ghr_pa_history
		where		pa_request_id		= p_pa_request_id
			and	nature_of_action_id	= p_noa_id;
	l_proc		varchar2(30):='get_hist_id';
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	open get_hist_id;
	fetch get_hist_id into p_pa_history_id;
	if get_hist_id%notfound then
		p_result := FALSE;
	else
		p_result := TRUE;
	end if;
	close get_hist_id;
End;

*/

--
-- Procedure fetch_people fetches the last record from per_people_f or ghr_pa_history
-- which was created between effective start date and effective end date
--
Procedure fetch_people (
			p_person_id					in	number	default null,
			p_date_effective				in	date		default null,
			p_altered_pa_request_id			in	number	default null,
			p_noa_id_corrected			in	number	default null,
			p_rowid					in	rowid		default null,
			p_pa_history_id				in	number	default null,
			p_people_data				out nocopy	per_all_people_f%rowtype,
			p_result_code				out nocopy	varchar2 )  is
	l_result_code		varchar2(100);
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30):='fetch_people';
	l_people_data		per_all_people_f%rowtype;

	cursor per_people_f_cursor is
		select 	*
		from 		per_all_people_f
		where 	person_id = p_person_id
			and 	p_date_effective between effective_start_date and effective_end_date;

	cursor per_people_f_rowid_cursor is
		select 	*
		from 		per_all_people_f
		where 	rowid = p_rowid;
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open per_people_f_rowid_cursor;
		fetch per_people_f_rowid_cursor into p_people_data;
		if ( per_people_f_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_people_f_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	elsif ( p_pa_history_id is null 		and
		    p_altered_pa_request_id is null and
		    p_noa_id_corrected is null ) then
            /* This part of the procedure will fetch the Pre-record values
            if called before update to database updates the record.
            if update to database has already applied the changes then it
            will return the post-update record. The session variable
            pre-update-record will hold the values which can be used for
            pre-record values
            */
		hr_utility.set_location( l_proc, 20);
		open per_people_f_cursor;
		fetch per_people_f_cursor into p_people_data;
		if ( per_people_f_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_people_f_cursor;
		hr_utility.set_location( l_proc, 25);
	else
		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_peop_table,
			p_information1		=> p_person_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_people_rg(
				p_history_data	=> l_hist_data,
				p_people_data	=> l_people_data);
			p_people_data := l_people_data;
		end if;

	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 45);
   exception
	when no_data_found then
		p_result_code := c_not_found;
	when others then
		raise;
End fetch_people;
--
Procedure fetch_asgei (
	p_assignment_extra_info_id		in	number	default null,
	p_date_effective				in	date		default null,
	p_altered_pa_request_id			in	number	default null,
	p_noa_id_corrected			in	number	default null,
	p_rowid					in	rowid		default null,
	p_pa_history_id				in	number	default null,
      p_get_ovn_flag                      in    varchar2    default 'N'	,
  	p_asgei_data				out nocopy	per_assignment_extra_info%rowtype,
	p_result_code				out nocopy	varchar2 )  is

	cursor per_asgei_rowid_cursor is
		select 	*
		from 		per_assignment_extra_info
		where 	rowid = p_rowid;

	cursor c_get_ovn is
      	select  object_version_number
            from    per_assignment_extra_info
            where   assignment_extra_info_id = p_assignment_extra_info_id;

	l_result_code		varchar2(30);
	l_asgei_data		per_assignment_extra_info%rowtype;
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30):='fetch_asgei';

Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
		hr_utility.set_location( l_proc, 10);
		open per_asgei_rowid_cursor;
		fetch per_asgei_rowid_cursor into p_asgei_data;
		if ( per_asgei_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_asgei_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	else
		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_asgnei_table,
			p_information1		=> p_assignment_extra_info_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_asgnei_rg(
				p_history_data	=> l_hist_data,
				p_asgnei_data	=> l_asgei_data);
			p_asgei_data := l_asgei_data;
		      if upper(p_get_ovn_flag) = 'Y' then
		         for ovn in c_get_ovn loop
            		p_asgei_data.object_version_number := ovn.object_version_number;
				exit;
		         end loop;
			end if;
		end if;
      end if;
End;
--
-- Procedure fetches the last record from per_position_extra_info or
-- ghr_position_extra_info_h_v
--
Procedure fetch_positionei (
	p_position_extra_info_id		in	number	default null,
	p_date_effective				in	date		default null,
	p_altered_pa_request_id			in	number	default null,
	p_noa_id_corrected			in	number	default null,
	p_rowid					in	rowid		default null,
	p_pa_history_id				in	number	default null,
      p_get_ovn_flag                      in    varchar2    default 'N',
	p_posei_data				out nocopy	per_position_extra_info%rowtype,
	p_result_code				out nocopy	varchar2 )  is

	cursor per_posei_rowid_cursor is
		select 	*
		from 		per_position_extra_info
		where 	rowid = p_rowid;

	cursor c_get_ovn is
      	select  object_version_number
            from    per_position_extra_info
            where   position_extra_info_id = p_position_extra_info_id;

	l_result_code		varchar2(30);
	l_posei_data		per_position_extra_info%rowtype;
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30):='fetch_positionei';

Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
		hr_utility.set_location( l_proc, 10);
		open per_posei_rowid_cursor;
		fetch per_posei_rowid_cursor into p_posei_data;
		if ( per_posei_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_posei_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	else
		hr_utility.set_location( l_proc || 'altered_pa_request_id: ' || p_altered_pa_request_id, 115);
		hr_utility.set_location( l_proc || 'noa_id_corrected: ' || p_noa_id_corrected, 215);
		hr_utility.set_location( l_proc || 'position_extra_info_id: ' || p_position_extra_info_id, 215);

		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_posnei_table,
			p_information1		=> p_position_extra_info_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			hr_utility.set_location (' NOT FOUND ' || l_result_code || l_proc, 90);
			-- Bug # 7646662 to get the effective date of the history record
			g_cascad_eff_date := l_hist_data.effective_date;
			ghr_history_conv_rg.conv_to_positionei_rg(
				p_history_data		=> l_hist_data,
				p_position_ei_data	=> l_posei_data);
			p_posei_data := l_posei_data;
		      if upper(p_get_ovn_flag) = 'Y' then
		         for ovn in c_get_ovn loop
            		p_posei_data.object_version_number := ovn.object_version_number;
				exit;
		         end loop;
			end if;
		end if;
      end if;
       hr_utility.set_location('poei_info5 ' || l_posei_data.poei_information5,1);
	hr_utility.set_location ('Leaving : ' || l_proc, 100);

End fetch_positionei;
--
-- Procedure fetch_assignment fetches the last record from per_assignment or ghr_assignments_h_v
--
Procedure fetch_assignment (
		p_assignment_id				in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_assignment_data				out nocopy	per_all_assignments_f%rowtype,
		p_result_code				out nocopy	varchar2 )  is
	l_result_code		varchar2(100);
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30):='fetch_assignment';
	l_assignment_data		per_all_assignments_f%rowtype;
	cursor per_assignment_f_cursor is
		select 	*
		from 		per_all_assignments_f
		where 	assignment_id = p_assignment_id
			and 	p_date_effective between effective_start_date and effective_end_date;
	cursor per_assignment_f_rowid_cursor is
		select 	*
		from 		per_all_assignments_f
		where 	rowid = p_rowid;
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open per_assignment_f_rowid_cursor;
		fetch per_assignment_f_rowid_cursor into p_assignment_data;
		if ( per_assignment_f_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_assignment_f_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	elsif ( p_pa_history_id is null 		and
			p_altered_pa_request_id is null and
		    p_noa_id_corrected is null ) then
            /* This part of the procedure will fetch the Pre-record values
            if called before update to database updates the record.
            if update to database has already applied the changes then it
            will return the post-update record. The session variable
            pre-update-record will hold the values which can be used for
            pre-record values
            */
		hr_utility.set_location( l_proc, 20);
		open per_assignment_f_cursor;
		fetch per_assignment_f_cursor into p_assignment_data;
		if ( per_assignment_f_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_assignment_f_cursor;
		hr_utility.set_location( l_proc, 25);
	else
 		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_asgn_table,
			p_information1		=> p_assignment_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_asgn_rg(
				p_history_data	=> l_hist_data,
				p_assignment_data	=> l_assignment_data);
			p_assignment_data := l_assignment_data;
		end if;

	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 45);
exception
	when no_data_found then
		p_result_code := c_not_found;
	when OTHERS then
	raise;
End fetch_assignment;
--
-- Procedure fetch_element_entries fetches the last record from pay_element_entries_f or
-- ghr_elements_entries_h_v
--
Procedure fetch_element_entries (
		p_element_entry_id			in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_element_entry_data			out nocopy	pay_element_entries_f%rowtype,
		p_result_code				out nocopy	varchar2 )  is
	l_result_code		varchar2(100);
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30) := 'fetch_element_entries';
	l_element_entry_data	pay_element_entries_f%rowtype;
	cursor pay_e_entry_f_cursor is
		select 	*
		from 		pay_element_entries_f
		where 	element_entry_id = p_element_entry_id
			and 	p_date_effective between effective_start_date and effective_end_date;
	cursor pay_e_entry_f_rowid_cursor is
		select 	*
		from 		pay_element_entries_f
		where 	rowid = p_rowid;
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open pay_e_entry_f_rowid_cursor;
		fetch pay_e_entry_f_rowid_cursor into p_element_entry_data;
		if ( pay_e_entry_f_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close pay_e_entry_f_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	elsif ( p_pa_history_id is null 	and
		  p_altered_pa_request_id is null  	and
		  p_noa_id_corrected is null ) then
            /* This part of the procedure will fetch the Pre-record values
            if called before update to database updates the record.
            if update to database has already applied the changes then it
            will return the post-update record. The session variable
            pre-update-record will hold the values which can be used for
            pre-record values
            */
		hr_utility.set_location( l_proc, 20);
		open pay_e_entry_f_cursor;
		fetch pay_e_entry_f_cursor into p_element_entry_data;
		if ( pay_e_entry_f_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close pay_e_entry_f_cursor;
	else
		hr_utility.set_location( l_proc, 25);
 		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_eleent_table,
			p_information1		=> p_element_entry_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_element_entry_rg(
				p_history_data		=> l_hist_data,
				p_element_entries_data	=> l_element_entry_data);
			p_element_entry_data := l_element_entry_data;
		end if;
	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 45);
   exception
	when no_data_found then
		p_result_code := c_not_found;
	when OTHERS then
	raise;
End fetch_element_entries;
--
-- Procedure fetch_peopleei fetches the last record from per_people_extra_info or
-- ghr_people_extra_info_h_v
--
Procedure fetch_peopleei (
		p_person_extra_info_id			in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
            p_get_ovn_flag                      in    varchar2    default 'N',
		p_peopleei_data				in out nocopy	per_people_extra_info%rowtype,
		p_result_code				out nocopy	varchar2 )  is
	l_result_code		varchar2(100);
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30) := 'fetch_peopleei';
	l_peopleei_data		per_people_extra_info%rowtype;
	cursor per_peopleei_rowid_cursor is
		select 	*
		from 		per_people_extra_info
		where 	rowid = p_rowid;
       cursor c_get_ovn is
       	select  object_version_number
            from    per_people_extra_info
            where   person_extra_info_id = p_person_extra_info_id;
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	hr_utility.set_location('extra info id:'|| to_char(p_person_extra_info_id) || l_proc, 6);
	hr_utility.set_location('date_effective:'|| to_char(p_date_effective) || l_proc, 7);
	hr_utility.set_location('noa_id_corrected:'|| to_char(p_noa_id_corrected) || l_proc, 8);
	hr_utility.set_location('altered_pa_request_id:'|| to_char(p_altered_pa_request_id) || l_proc, 9);
	hr_utility.set_location(' Information11:'|| p_peopleei_data.pei_information11 || l_proc, 48);
	hr_utility.set_location(' Information5:'||p_peopleei_data.pei_information5 || l_proc, 49);
	hr_utility.set_location(' p_pa_history_id:'||p_pa_history_id || l_proc, 51);
	hr_utility.set_location(' p_person_extra_info_id:'||p_person_extra_info_id || l_proc, 52);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open per_peopleei_rowid_cursor;
		fetch per_peopleei_rowid_cursor into p_peopleei_data;
		if ( per_peopleei_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_peopleei_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	else
		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_peopei_table,
			p_information1		=> p_person_extra_info_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			hr_utility.set_location (' NOT FOUND ' || l_result_code || l_proc, 90);
			ghr_history_conv_rg.conv_to_peopleei_rg(
				p_history_data		=> l_hist_data,
				p_people_ei_data		=> l_peopleei_data);
			p_peopleei_data := l_peopleei_data;
		      if upper(p_get_ovn_flag) = 'Y' then
		         for ovn in c_get_ovn loop
            		p_peopleei_data.object_version_number := ovn.object_version_number;
				exit;
		         end loop;
			end if;
		end if;
	end if;

	hr_utility.set_location(' Information11:'|| p_peopleei_data.pei_information11 || l_proc, 46);
	hr_utility.set_location(' Information5:'||p_peopleei_data.pei_information5 || l_proc, 47);
	hr_utility.set_location(' Leaving:'||l_proc, 45);
exception
	when no_data_found then
		p_result_code := c_not_found;
	when OTHERS then
	raise;
End fetch_peopleei;

Procedure fetch_asgei ( p_assignment_id     in  number,
                        p_information_type  in  varchar2,
                        p_date_effective    in  date,
                        p_asg_ei_data       out nocopy per_assignment_extra_info%rowtype
                      )
is
	l_proc                varchar2(72) := 'Fetch_Asgei (2)';
      l_asg_ei_data         ghr_assignment_extra_info_h_v%rowtype;
      l_pa_history_id       ghr_pa_history.pa_history_id%type;
      l_max_effective_date  date;
      l_session             ghr_history_api.g_session_var_type;
      l_extra_info_id       per_assignment_extra_info.assignment_extra_info_id%type;
      l_result              varchar2(20);
       cursor  c_extra_info_id is
      	select      aei.assignment_extra_info_id
            from        per_assignment_extra_info aei
            where       aei.assignment_id      =  p_assignment_id
            and         aei.information_type   =  p_information_type;
Begin
	hr_utility.set_location('Entering  ' || l_proc,5);
      For  extra_info in c_extra_info_id loop
          l_extra_info_id   :=   extra_info.assignment_extra_info_id;
      End loop;
      If l_extra_info_id is not null then
           hr_utility.set_location(l_proc,10);
      	ghr_history_api.get_g_session_var(l_session);
      	ghr_history_fetch.fetch_asgei ( p_assignment_extra_info_id  => l_extra_info_id,
							  p_date_effective            => p_date_effective,
                                            p_altered_pa_request_id     => l_session.altered_pa_request_id,
                                            p_noa_id_corrected          => l_session.noa_id_correct,
	                                      p_pa_history_id			=> l_session.pa_history_id,
	                                      p_asgei_data                => p_asg_ei_data,
		                                p_get_ovn_flag              => 'Y',
                                            p_result_code               => l_result
                                            );
      End if;
     hr_utility.set_location('Leaving  ' ||l_proc,20);
End fetch_asgei;

Procedure fetch_peopleei(p_person_id         in  number,
                         p_information_type  in  varchar2,
                         p_date_effective    in  date,
                         p_per_ei_data       in out nocopy per_people_extra_info%rowtype
                       )
is
	l_proc                varchar2(72) := 'Fetch_peoplei (2)';
      l_per_ei_data         ghr_people_extra_info_h_v%rowtype;
      l_pa_history_id       ghr_pa_history.pa_history_id%type;
      l_max_effective_date  date;
      l_session             ghr_history_api.g_session_var_type;
      l_extra_info_id       per_people_extra_info.person_extra_info_id%type;
      l_result              varchar2(20);
      cursor  c_extra_info_id is
      	select      pei.person_extra_info_id
            from        per_people_extra_info pei
            where       pei.person_id          =  p_person_id
            and         pei.information_type   =  p_information_type;
Begin
	hr_utility.set_location('Entering  ' || l_proc,5);
      For  extra_info in c_extra_info_id loop
      	l_extra_info_id   :=   extra_info.person_extra_info_id;
      End loop;
      If l_extra_info_id is not null then
            hr_utility.set_location(l_proc,10);
      	ghr_history_api.get_g_session_var(l_session);
      	ghr_history_fetch.fetch_peopleei ( p_person_extra_info_id  => l_extra_info_id,
							     p_date_effective        => p_date_effective,
                                               p_altered_pa_request_id => l_session.altered_pa_request_id,
                                               p_noa_id_corrected      => l_session.noa_id_correct,
	                                         p_pa_history_id         => l_session.pa_history_id,
	                                         p_peopleei_data         => p_per_ei_data,
                                               p_get_ovn_flag          => 'Y',
                                               p_result_code           => l_result
                                             );
      End if;
      hr_utility.set_location('Leaving ' ||l_proc,20);
End fetch_peopleei;

Procedure fetch_positionei(p_position_id         in  number,
                           p_information_type    in  varchar2,
                           p_date_effective      in  date,
                           p_pos_ei_data         out nocopy per_position_extra_info%rowtype
                          )
is
	l_proc                varchar2(72) := 'Fetch_positionei (2)';
      l_pos_ei_data         ghr_position_extra_info_h_v%rowtype;
      l_pa_history_id       ghr_pa_history.pa_history_id%type;
      l_max_effective_date  date;
      l_session             ghr_history_api.g_session_var_type;
      l_extra_info_id       per_position_extra_info.position_extra_info_id%type;
      l_result              varchar2(20);


     cursor  c_extra_info_id is
      	select      ghr_pos.position_extra_info_id
            from        per_position_extra_info ghr_pos
            where       ghr_pos.position_id          =  p_position_id
            and         ghr_pos.information_type     =  p_information_type;

Begin
        g_info_type := p_information_type;
	hr_utility.set_location('Entering  ' || l_proc,5);
	hr_utility.set_location('FETCH: Position_id  ' || p_position_id ||l_proc,6);
	hr_utility.set_location('FETCH: information_type  ' || p_information_type || l_proc,7);
      for extra_info in c_extra_info_id loop
      	l_extra_info_id := extra_info.position_extra_info_id;
      end loop;
      If l_extra_info_id is not null then
        hr_utility.set_location(l_proc,10);
      	ghr_history_api.get_g_session_var(l_session);
      	ghr_history_fetch.fetch_positionei(p_position_extra_info_id   => l_extra_info_id,
					   p_date_effective          => p_date_effective,
                                           p_altered_pa_request_id   => l_session.altered_pa_request_id,
                                           p_noa_id_corrected        => l_session.noa_id_correct,
                                           p_pa_history_id           => l_session.pa_history_id,
	                                   p_posei_data              => p_pos_ei_data,
			                   p_get_ovn_flag            => 'Y',
                                           p_result_code             => l_result
                                           );
       End if;
      -- Bug# 8267598 assigned g_info_type to NULL after fetching position extra info
      -- g_info_type := NULL;
         hr_utility.set_location('Leaving ' ||l_proc,20);
End fetch_positionei;
-- The following procedure gets the date_effective row from the
-- ghr_pa_history for the element_entry_values table.
--VSM (What about this procedure) ??
Procedure get_date_eff_eleevl(p_element_entry_value_id	in	number,
					p_date_effective			in 	date,
					p_element_entry_data		out nocopy	pay_element_entry_values_f%rowtype,
					p_result_code			out nocopy	varchar2,
					p_pa_history_id			out nocopy	number) IS
	l_hist_data				ghr_pa_history%rowtype;
--	l_result				Boolean;
	l_proc				varchar2(30) := 'get_date_eff_eleevl';
	l_element_entval_data		pay_element_entry_values_f%rowtype;
BEGIN
	hr_utility.set_location( l_proc, 20);
	fetch_for_date_eff(
		p_table_name	=> ghr_history_api.g_eleevl_table,
		p_information1	=> p_element_entry_value_id,
		p_date_effective	=> p_date_effective,
	  	p_hist_data		=> l_hist_data,
		p_result_code	=> p_result_code);
	p_pa_history_id	:=	l_hist_data.pa_history_id;
	hr_utility.set_location( l_proc, 75);
	ghr_history_conv_rg.conv_to_element_entval_rg(
		p_history_data		=> l_hist_data,
		p_element_entval_data	=> l_element_entval_data );
	p_element_entry_data := l_element_entval_data;
	hr_utility.set_location( l_proc, 25);
END get_date_eff_eleevl;

Procedure fetch_element_entry_value (
		p_element_entry_value_id		in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_element_entry_data			out nocopy	pay_element_entry_values_f%rowtype,
		p_result_code				out nocopy	varchar2 )  is
	l_hist_data				ghr_pa_history%rowtype;
	l_result_code			varchar2(100);
	l_proc				varchar2(30) := 'fetch_element_entry_values';
	l_element_entval_data		pay_element_entry_values_f%rowtype;
	cursor pay_e_entry_value_f_cursor is
		select 	*
		from 		pay_element_entry_values_f
		where 	element_entry_value_id = p_element_entry_value_id
		and 	p_date_effective between effective_start_date and effective_end_date;
	cursor pay_e_entry_val_f_rowid is
		select 	*
		from 		pay_element_entry_values_f
		where 	rowid = p_rowid;

Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open pay_e_entry_val_f_rowid;
		fetch pay_e_entry_val_f_rowid into p_element_entry_data;
		if ( pay_e_entry_val_f_rowid%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close pay_e_entry_val_f_rowid;
		hr_utility.set_location( l_proc, 15);
	elsif ( p_pa_history_id is null 	and
		  p_altered_pa_request_id is null  	and
		  p_noa_id_corrected is null ) then
            /* This part of the procedure will fetch the Pre-record values
            if called before update to database updates the record.
            if update to database has already applied the changes then it
            will return the post-update record. The session variable
            pre-update-record will hold the values which can be used for
            pre-record values
            */
		hr_utility.set_location( l_proc, 20);
		open pay_e_entry_value_f_cursor;
		fetch pay_e_entry_value_f_cursor into p_element_entry_data;
		if ( pay_e_entry_value_f_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close pay_e_entry_value_f_cursor;
	else
		hr_utility.set_location( l_proc, 25);
 		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_eleevl_table,
			p_information1		=> p_element_entry_value_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_element_entval_rg(
				p_history_data		=> l_hist_data,
				p_element_entval_data	=> l_element_entval_data);
			p_element_entry_data := l_element_entval_data;
		end if;
	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 45);
   exception
	when no_data_found then
		p_result_code := c_not_found;
	when OTHERS then
	raise;
End fetch_element_entry_value;

Procedure fetch_element_entry_value
	(p_element_name              in   pay_element_types_f.element_name%type,
	 p_input_value_name          in   pay_input_values_f.name%type,
	 p_assignment_id             in   per_assignments_f.assignment_id%type,
	 p_date_effective            in   date,
	 p_screen_entry_value        out nocopy  pay_element_entry_values_f.screen_entry_value%type
	 )
 is
  l_proc                        varchar2(72) := 'fetch_element_entry_value';
  l_session                     ghr_history_api.g_session_var_type;
  l_element_entry_value_id      pay_element_entry_values.element_entry_value_id%type;
  l_result                      varchar2(15);
  l_element_entry_data          pay_element_entry_values_f%rowtype;
  l_object_version_number       pay_element_entries_f.object_version_number%type;
  l_input_value_id              pay_element_entry_values_f.input_value_id%type;
  l_element_link_id             pay_element_entries_f.element_link_id%type;
  l_element_entry_id            pay_element_entries_f.element_entry_id%type;
  l_screen_entry_value          pay_element_entry_values_f.screen_entry_value%type;
  l_element_type_id             pay_element_types_f.element_type_id%type;
  l_processing_type             pay_element_types.processing_type%type;

    Cursor fetch_element_entry_value_id(p_element_name IN VARCHAR2
                                       ,p_bg_id        IN NUMBER)
    is
      select eev.element_entry_value_id
	  from pay_element_types_f elt,
	       pay_input_values_f ipv,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(p_date_effective) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(p_date_effective) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and trunc(p_date_effective) between ele.effective_start_date
				   and ele.effective_end_date
	   and trunc(p_date_effective) between eev.effective_start_date
				   and eev.effective_end_date
	   and elt.element_type_id = ipv.element_type_id
	   and upper(elt.element_name) = upper(p_element_name)
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = p_assignment_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
	   and upper(ipv.name) = upper(p_input_value_name)
--	   and NVL(elt.business_group_id,0)=NVL(ipv.business_group_id,0)
           and (elt.business_group_id is NULL or elt.business_group_id=p_bg_id);
--
--added bg id check  for business group id striping
--
Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and  p_eff_date between effective_start_date
             and effective_end_date;

--
 ll_bg_id                    NUMBER;
 ll_pay_basis                VARCHAR2(80);
 ll_effective_date           DATE;
 l_new_element_name          VARCHAR2(80);
--

begin
    hr_utility.set_location('Entering  ' || l_proc,5);
    -- Initialization
    ghr_history_api.get_g_session_var(l_session);
    ll_effective_date        := p_date_effective;
 -- Pick the business group id and also pay basis for later use
 For BG_rec in Cur_BG(p_assignment_id,ll_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;

----
---- The New Changes after 08/22 patch
---- For all elements in HR User old function will fetch the same name.
----     because of is_script will be FALSE
----
---- For all elements (except BSR) in Payroll user old function.
----     for BSR a new function which will fetch from assignmnet id.
----


IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE') = 'INT')) THEN
     hr_utility.set_location('PAYROLL User -- BSR -- from asgid-- ' || l_proc, 5);
           l_new_element_name :=
                   pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => ll_bg_id,
                                           p_effective_date     => ll_effective_date);
 ELSIF (fnd_profile.value('HR_USER_TYPE') <> 'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE') = 'INT'))) THEN
       hr_utility.set_location('HR USER or PAYROLL User without BSR element -- from elt name -- ' || l_proc, 5);
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => ll_bg_id,
                                           p_effective_date     => ll_effective_date,
                                           p_pay_basis          => NULL);

 END IF;

--
-- the p_element_name is replaced with l_new_element_name
-- in further calls.
--
    If l_session.noa_id_correct is not null then

-- History package call fetch_element_entry_value picks new element name
-- again in its call so sending old element name.
      ghr_history_fetch.fetch_element_info_cor
	(p_element_name      		=>  p_element_name,
         p_input_value_name             =>  p_input_value_name,
         p_assignment_id     		=>  p_assignment_id,
         p_effective_date    		=>  p_date_effective,
         p_element_link_id      	=>  l_element_link_id,
         p_input_value_id       	=>  l_input_value_id,
         p_element_entry_id     	=>  l_element_entry_id,
         p_value                	=>  l_screen_entry_value,
         p_object_version_number        =>  l_object_version_number
        );
        p_screen_entry_value  := l_screen_entry_value;
     Else
 	 For fetch_elv_id  in fetch_element_entry_value_id(
	                                         l_new_element_name,
						 ll_bg_id)
         loop
         l_element_entry_value_id :=  fetch_elv_id.element_entry_value_id;
         If l_element_entry_value_id is not null then
           hr_utility.set_location(l_proc || 'inside cursor    '|| to_char(l_element_entry_value_id) ,6);
           fetch_element_entry_value(
	                        p_element_entry_value_id => l_element_entry_value_id,
                                p_date_effective         => p_date_effective,
                                p_altered_pa_request_id  => l_session.altered_pa_request_id,
                                p_noa_id_corrected       => l_session.noa_id_correct,
                                p_pa_history_id          => l_session.pa_history_id,
                                p_element_entry_data     => l_element_entry_data,
                                p_result_code            => l_result
                               );
         Else
	     hr_utility.set_location(l_proc || 'before exit',7);
	     exit;
         End if;
         If nvl(lower(l_result),hr_api.g_varchar2) <> c_not_found then
            hr_utility.set_location(l_proc ||  'l_result' || l_result,8);
            p_screen_entry_value :=  l_element_entry_data.screen_entry_value;
            hr_utility.set_location(l_proc || 'Value' ||  l_element_entry_data.screen_entry_value,8);
            exit;
         End if;
      End loop;
  End if;
End fetch_element_entry_value;

Procedure fetch_element_info_cor (
	 p_element_name      		in     pay_element_types_f.element_name%type
	,p_input_value_name  		in     pay_input_values_f.name%type
	,p_assignment_id     		in     pay_element_entries_f.assignment_id%type
	,p_effective_date    		in     date
	,p_element_link_id      	out nocopy pay_element_links_f.element_link_id%type
	,p_input_value_id       	out nocopy pay_input_values_f.input_value_id%type
	,p_element_entry_id     	out nocopy pay_element_entries_f.element_entry_id%type
	,p_value                	out nocopy pay_element_entry_values_f.screen_entry_value%type
	,p_object_version_number 	out nocopy pay_element_entries_f.object_version_number%type  ) is
--	,p_multiple_error_flag  	out nocopy varchar2


	l_proc                  varchar2(72) := 'fetch_element_info_cor';
	l_session               ghr_history_api.g_session_var_type;
	l_element_entry_id      pay_element_entries_f.element_entry_id%type;
      l_input_value_id        pay_input_values_f.input_value_id%type;
      l_pa_request_id         ghr_pa_requests.pa_request_id%type;
      l_processing_type       pay_element_types_f.processing_type%type;
      l_element_type_id       pay_element_types_f.element_type_id%type;
      l_element_entry_value_id pay_element_entry_values.element_entry_value_id%type;
      l_element_entry_data    pay_element_entry_values_f%rowtype;
      l_result                varchar2(30);

-- Modified Cursor for Payroll Changes
--
Cursor     c_ele_type(p_element_name VARCHAR2,p_bg_id  NUMBER) is
  select   elt.element_type_id,
           elt.processing_type
  from     pay_element_types_f elt
  where    upper(elt.element_name) =  upper(p_element_name)
  and      p_effective_date
  between  elt.effective_start_date and elt.effective_end_date
  and      (elt.business_group_id is null or elt.business_group_id=p_bg_id);

-- Modified Cursor for Payroll Changes
--
cursor   c_ele_info_cor (l_ele_type_id  in NUMBER
			,input_name     in varchar2
			,asg_id         in number
			,eff_date       in date
			,bg_id          in number) is
select     ele.pa_request_id,
           ipv.input_value_id,
           eli.element_link_id,
           ele.element_entry_id
         from
               pay_input_values_f ipv,
               pay_element_links_f eli,
               ghr_element_entries_h_v ele
         where
           trunc(eff_date)    between ipv.effective_start_date
                                   and ipv.effective_end_date
           and   trunc(eff_date) between eli.effective_start_date
                                  and eli.effective_end_date
           and   trunc(eff_date) between ele.effective_start_date
                                   and ele.effective_end_date
           and  ipv.element_type_id   = l_ele_type_id
           and ipv.element_type_id     = eli.element_type_id
           and ele.assignment_id       = asg_id
           and ele.element_link_id     = eli.element_link_id
           and upper(ipv.name)         = upper(input_name)
           and ele.nature_of_action_id = l_session.noa_id_correct
           and ele.pa_request_id  in
          (select a.pa_request_id
           from   ghr_pa_requests a
           connect by a.pa_request_id = prior a.altered_pa_request_id
           start with a.pa_request_id = l_session.altered_pa_request_id
          )
--	  and NVL(ipv.business_group_id,0)=NVL(eli.business_group_id,0)
	  and (ipv.business_group_id is null or ipv.business_group_id=bg_id)
          order by 1 desc;

 Cursor c_gev is
    select gev.screen_entry_value
    from   ghr_element_entry_values_h_v gev
    where  gev.element_entry_id = l_element_entry_id
    and    gev.input_value_id   = l_input_value_id
    and    gev.pa_request_id    = l_pa_request_id;


 cursor    c_ele_ovn is
     select  object_version_number
     from    pay_element_entries_f
     where   element_entry_id = l_element_entry_id
     and     p_effective_date
     between effective_start_date and effective_end_date;

-- Modified Cursor for Payroll Changes
--
Cursor fetch_element_entry_value_id(p_element_type_id IN NUMBER,
                                    p_bg_id           IN NUMBER) is
      select eev.element_entry_value_id
	  from pay_input_values_f ipv,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(p_effective_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and trunc(p_effective_date) between ele.effective_start_date
				   and ele.effective_end_date
	   and trunc(p_effective_date) between eev.effective_start_date
				   and eev.effective_end_date
	   and ipv.element_type_id=p_element_type_id
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = p_assignment_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
	   and upper(ipv.name) = upper(p_input_value_name)
	   and (ipv.business_group_id is NULL or ipv.business_group_id=p_bg_id);
--
Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;

 l_fam_code                  VARCHAR2(80);
--
 ll_bg_id                    NUMBER;
 ll_effective_date           DATE;
 ll_pay_basis                VARCHAR2(80);
 l_new_element_name          VARCHAR2(80);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  ghr_history_api.get_g_session_var(l_session);
  --   Pick pay basis from PAR

 For BG_rec in Cur_BG(p_assignment_id,p_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;

----
---- The New Changes after 08/22 patch
---- For all elements in HR User old function will fetch the same name.
----     because of is_script will be FALSE
----
---- For all elements (except BSR) in Payroll user old function.
----     for BSR a new function which will fetch from assignmnet id.
----

IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE') = 'INT')) THEN
    hr_utility.set_location('PAYROLL User -- BSR -- from asgid-- '||l_proc, 1);
           l_new_element_name :=
                   pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => ll_bg_id,
                                           p_effective_date     => ll_effective_date);
 ELSIF (fnd_profile.value('HR_USER_TYPE') <> 'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE') = 'INT'))) THEN
       hr_utility.set_location('HR USER or PAYROLL User without BSR element -- from elt name -- '||l_proc, 1);
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => ll_bg_id,
                                           p_effective_date     => ll_effective_date,
                                           p_pay_basis          => NULL);

 END IF;

--
--
hr_utility.trace('NEW ELE NAME- ghhisfet.pkb is '||l_new_element_name);
-- commenting this and using the same above
--  ghr_history_api.get_g_session_var(l_session);
  l_input_value_id    :=  Null;
  l_element_entry_id  :=  Null;
   --
    hr_utility.set_location('Element - CORRECTION ' ,1);
    hr_utility.set_location('NOA ID COR ' || to_char(l_session.noa_id_correct),1);
    hr_utility.set_location('PAR ID COR ' || to_char(l_session.altered_pa_request_id),1);
    hr_utility.set_location('Element Name ' || l_new_element_name,2);
    hr_utility.set_location('IV  Name ' || p_input_value_name,3);
    hr_utility.set_location('Asg id ' || to_char(p_assignment_id),4);
 --  hr_utility.set_location('Eff. Date ' || p_effective_date,5);

     for ele_type in c_ele_type(l_new_element_name
                                ,ll_bg_id)
     loop
       hr_utility.set_location(l_proc ,20);
       l_element_type_id   :=   ele_type.element_type_id;
       l_processing_type   :=   ele_type.processing_type;
       hr_utility.set_location('proc type ' || l_processing_type,2);
    end loop;

    If nvl(l_processing_type,hr_api.g_varchar2) = 'R' then
	For fetch_elv_id  in fetch_element_entry_value_id(
	                                            l_element_type_id
						   ,ll_bg_id)
        loop
        l_element_entry_value_id :=  fetch_elv_id.element_entry_value_id;
        If l_element_entry_value_id is not null then
          hr_utility.set_location(l_proc || 'inside cursor    '|| to_char(l_element_entry_value_id) ,6);

          fetch_element_entry_value(p_element_entry_value_id => l_element_entry_value_id,
                                p_date_effective         => p_effective_date,
                                p_altered_pa_request_id  => l_session.altered_pa_request_id,
                                p_noa_id_corrected       => l_session.noa_id_correct,
                                p_pa_history_id          => l_session.pa_history_id,
                                p_element_entry_data     => l_element_entry_data,
                                p_result_code            => l_result
                               );

          l_element_entry_id  :=  l_element_entry_data.element_entry_id;

          p_input_value_id    :=  l_element_entry_data.input_value_id;
          p_element_entry_id  :=  l_element_entry_id;
          p_value             :=  l_element_entry_data.screen_entry_value;

        Else
	    hr_utility.set_location(l_proc || 'before exit',7);
	    exit;
        End if;
        If nvl(lower(l_result),hr_api.g_varchar2) <> c_not_found then
          hr_utility.set_location(l_proc ||  'l_result' || l_result,8);
          p_value :=  l_element_entry_data.screen_entry_value;
          hr_utility.set_location(l_proc || 'Value' ||  l_element_entry_data.screen_entry_value,8);
          exit;
       End if;
    End loop;

  Elsif nvl(l_processing_type,hr_api.g_varchar2) = 'N' then
    hr_utility.set_location('NOA ID COR ' || to_char(l_session.noa_id_correct),1);
    hr_utility.set_location('PAR ID COR ' || to_char(l_session.altered_pa_request_id),1);
    hr_utility.set_location('Element Name ' || l_new_element_name,2);
    hr_utility.set_location('IV  Name ' || p_input_value_name,3);
    hr_utility.set_location('Asg id ' || to_char(p_assignment_id),4);
    hr_utility.set_location('Eff. Date ' || (p_effective_date),5);
    hr_utility.set_location('Element type id ' || to_char(l_element_type_id),1);

/*
   If it is a correction action, then we have to read the
   element values from the history table to get the correct data
   This is definitely required for a non-recurring element,because
   the same element can repeat n number of times for the same pay period
*/

     for ele_info_cor in   c_ele_info_cor (l_element_type_id
					  ,p_input_value_name
             			          ,p_assignment_id
				          ,p_effective_date
					  ,ll_bg_id) loop
       hr_utility.set_location('Element  In.Val. Id ' || ele_info_cor.input_value_id,3);
       hr_utility.set_location('Element  entry Id ' || ele_info_cor.element_entry_id,3);
       l_input_value_id          := ele_info_cor.input_value_id;
       p_element_link_id         := ele_info_cor.element_link_id;
       l_element_entry_id        := ele_info_cor.element_entry_id;
       l_pa_request_id           := ele_info_cor.pa_request_id;
      exit;
    end loop;

    p_element_entry_id  :=  l_element_entry_id;
    p_input_value_id    :=  l_input_value_id;

  Else
    -- unknown processing type
    --raise error;
    Null;
  End if;

  if l_element_entry_id is not null then
      for ele_ovn in c_ele_ovn loop
        hr_utility.set_location(l_proc || 'retrieve_element_cor ',1);
        p_object_version_number   := ele_ovn.object_version_number;
      end loop;
      if l_input_value_id is not null then -- l_input_value_id would anyway have a value only for Non Rec. Elements.
        hr_utility.set_location(l_proc || 'get eev',2);
        for screen_value in c_gev loop
          p_value   :=   screen_value.screen_entry_value;
          hr_utility.set_location('Scr. value is ' || screen_value.screen_entry_value,1);
        end loop;
      end if;
  end if;

 End  fetch_element_info_cor;


Procedure fetch_address (
	p_address_id				in	number	default null,
	p_date_effective				in	date		default null,
	p_altered_pa_request_id			in	number	default null,
	p_noa_id_corrected			in	number	default null,
	p_rowid					in	rowid		default null,
	p_pa_history_id				in	number	default null,
	p_address_data				out nocopy	per_addresses%rowtype,
	p_result_code				out nocopy	varchar2 )  is
	l_result_code		varchar2(100);
	l_hist_data			ghr_pa_history%rowtype;
	l_proc			varchar2(30):='fetch_address';
	l_address_data		per_addresses%rowtype;

	cursor per_address_rowid_cursor is
		select 	*
		from 		per_addresses
		where 	rowid = p_rowid;

begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open per_address_rowid_cursor;
		fetch per_address_rowid_cursor into p_address_data;
		if ( per_address_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_address_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	else

		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_addres_table,
			p_information1		=> p_address_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_addresses_rg(
				p_history_data	=> l_hist_data,
				p_addresses_data	=> l_address_data);
			p_address_data := l_address_data;
		end if;
	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 45);
   exception
	when no_data_found then
		p_result_code := c_not_found;
	when OTHERS then
	raise;
End fetch_address ;
--
-- Procedure fetch_person_analyses fetches the last record from per_person_analyses or ghr_pa_history
-- which was created between effective start date and effective end date
--
Procedure fetch_person_analyses (
			p_person_analysis_id			in	number	default null,
			p_date_effective				in	date		default null,
			p_altered_pa_request_id			in	number	default null,
			p_noa_id_corrected			in	number	default null,
			p_rowid					in	rowid		default null,
			p_pa_history_id				in	number	default null,
			p_peranalyses_data			out nocopy	per_person_analyses%rowtype,
			p_result_code				out nocopy	varchar2 )  is
	l_peranalyses_data	per_person_analyses%rowtype;
	l_proc			varchar2(30) := 'fetch_person_analyses';
	l_hist_data			ghr_pa_history%rowtype;
	l_result_code		varchar2(100);
	cursor per_peranalyses_rowid_cursor is
		select 	*
		from 		per_person_analyses
		where 	rowid = p_rowid;
Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
            /*  This part of the procedure is used to fetch the exact row
            which will be the post-update record. So if the procedure was
            passed with p_row_id parameter it'll always return the
            post-update record.
            */
		hr_utility.set_location( l_proc, 10);
		open per_peranalyses_rowid_cursor;
		fetch per_peranalyses_rowid_cursor into p_peranalyses_data;
		if ( per_peranalyses_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_peranalyses_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	else

		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_perana_table,
			p_information1		=> p_person_analysis_id,
			p_date_effective		=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data			=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_peranalyses_rg(
				p_history_data		=> l_hist_data,
				p_peranalyses_data	=> l_peranalyses_data);
			p_peranalyses_data := l_peranalyses_data;
		end if;

	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 45);
exception
	when no_data_found then
		p_result_code := c_not_found;
	when OTHERS then
	raise;
End fetch_person_analyses;

 procedure fetch_positionei (
    p_position_extra_info_id     in out nocopy    number
   ,p_date_effective             in out nocopy    date
   ,p_position_id                  out nocopy     number
   ,p_information_type             out nocopy     varchar2
   ,p_request_id                   out nocopy     number
   ,p_program_application_id       out nocopy     number
   ,p_program_id                   out nocopy     number
   ,p_program_update_date          out nocopy     date
   ,p_poei_attribute_category      out nocopy     varchar2
   ,p_poei_attribute1              out nocopy     varchar2
   ,p_poei_attribute2              out nocopy     varchar2
   ,p_poei_attribute3              out nocopy     varchar2
   ,p_poei_attribute4              out nocopy     varchar2
   ,p_poei_attribute5              out nocopy     varchar2
   ,p_poei_attribute6              out nocopy     varchar2
   ,p_poei_attribute7              out nocopy     varchar2
   ,p_poei_attribute8              out nocopy     varchar2
   ,p_poei_attribute9              out nocopy     varchar2
   ,p_poei_attribute10             out nocopy     varchar2
   ,p_poei_attribute11             out nocopy     varchar2
   ,p_poei_attribute12             out nocopy     varchar2
   ,p_poei_attribute13             out nocopy     varchar2
   ,p_poei_attribute14             out nocopy     varchar2
   ,p_poei_attribute15             out nocopy     varchar2
   ,p_poei_attribute16             out nocopy     varchar2
   ,p_poei_attribute17             out nocopy     varchar2
   ,p_poei_attribute18             out nocopy     varchar2
   ,p_poei_attribute19             out nocopy     varchar2
   ,p_poei_attribute20             out nocopy     varchar2
   ,p_poei_information_category    out nocopy     varchar2
   ,p_poei_information1            out nocopy     varchar2
   ,p_poei_information2            out nocopy     varchar2
   ,p_poei_information3            out nocopy     varchar2
   ,p_poei_information4            out nocopy     varchar2
   ,p_poei_information5            out nocopy     varchar2
   ,p_poei_information6            out nocopy     varchar2
   ,p_poei_information7            out nocopy     varchar2
   ,p_poei_information8            out nocopy     varchar2
   ,p_poei_information9            out nocopy     varchar2
   ,p_poei_information10           out nocopy     varchar2
   ,p_poei_information11           out nocopy     varchar2
   ,p_poei_information12           out nocopy     varchar2
   ,p_poei_information13           out nocopy     varchar2
   ,p_poei_information14           out nocopy     varchar2
   ,p_poei_information15           out nocopy     varchar2
   ,p_poei_information16           out nocopy     varchar2
   ,p_poei_information17           out nocopy     varchar2
   ,p_poei_information18           out nocopy     varchar2
   ,p_poei_information19           out nocopy     varchar2
   ,p_poei_information20           out nocopy     varchar2
   ,p_poei_information21           out nocopy     varchar2
   ,p_poei_information22           out nocopy     varchar2
   ,p_poei_information23           out nocopy     varchar2
   ,p_poei_information24           out nocopy     varchar2
   ,p_poei_information25           out nocopy     varchar2
   ,p_poei_information26           out nocopy     varchar2
   ,p_poei_information27           out nocopy     varchar2
   ,p_poei_information28           out nocopy     varchar2
   ,p_poei_information29           out nocopy     varchar2
   ,p_poei_information30           out nocopy     varchar2
   ,p_object_version_number        out nocopy     number
   ,p_last_update_date             out nocopy     date
   ,p_last_updated_by              out nocopy     number
   ,p_last_update_login            out nocopy     number
   ,p_created_by                   out nocopy     number
   ,p_creation_date                out nocopy     date
   ,p_result_code                  out nocopy     varchar2
 )
 Is
   r_poi          per_position_extra_info%rowtype;
   l_proc         varchar2(30):='fetch_positionei (1)';
   l_result_code  varchar2(30);
 Begin
    hr_utility.set_location('Entering :' || l_proc, 10);
    ghr_history_fetch.fetch_positionei(
            p_position_extra_info_id     => p_position_extra_info_id
          , p_date_effective             => p_date_effective
          , p_posei_data                 => r_poi
          , p_result_code                => p_result_code);
    hr_utility.set_location(l_proc, 20);
          p_position_extra_info_id      :=   r_poi.position_extra_info_id;
          p_position_id                 :=   r_poi.position_id;
          p_information_type            :=   r_poi.information_type;
          p_request_id                  :=   r_poi.request_id;
          p_program_application_id      :=   r_poi.program_application_id;
          p_program_id                  :=   r_poi.program_id;
          p_program_update_date         :=   r_poi.program_update_date;
          p_poei_attribute_category     :=   r_poi.poei_attribute_category;
          p_poei_attribute1             :=   r_poi.poei_attribute1;
          p_poei_attribute2             :=   r_poi.poei_attribute2;
          p_poei_attribute3             :=   r_poi.poei_attribute3;
          p_poei_attribute4             :=   r_poi.poei_attribute4;
          p_poei_attribute5             :=   r_poi.poei_attribute5;
          p_poei_attribute6             :=   r_poi.poei_attribute6;
          p_poei_attribute7             :=   r_poi.poei_attribute7;
          p_poei_attribute8             :=   r_poi.poei_attribute8;
          p_poei_attribute9             :=   r_poi.poei_attribute9;
          p_poei_attribute10            :=   r_poi.poei_attribute10;
          p_poei_attribute11            :=   r_poi.poei_attribute11;
          p_poei_attribute12            :=   r_poi.poei_attribute12;
          p_poei_attribute13            :=   r_poi.poei_attribute13;
          p_poei_attribute14            :=   r_poi.poei_attribute14;
          p_poei_attribute15            :=   r_poi.poei_attribute15;
          p_poei_attribute16            :=   r_poi.poei_attribute16;
          p_poei_attribute17            :=   r_poi.poei_attribute17;
          p_poei_attribute18            :=   r_poi.poei_attribute18;
          p_poei_attribute19            :=   r_poi.poei_attribute19;
          p_poei_attribute20            :=   r_poi.poei_attribute20;
          p_poei_information_category   :=   r_poi.poei_information_category;
          p_poei_information1           :=   r_poi.poei_information1;
          p_poei_information2           :=   r_poi.poei_information2;
          p_poei_information3           :=   r_poi.poei_information3;
          p_poei_information4           :=   r_poi.poei_information4;
          p_poei_information5           :=   r_poi.poei_information5;
          p_poei_information6           :=   r_poi.poei_information6;
          p_poei_information7           :=   r_poi.poei_information7;
          p_poei_information8           :=   r_poi.poei_information8;
          p_poei_information9           :=   r_poi.poei_information9;
          p_poei_information10          :=   r_poi.poei_information10;
          p_poei_information11          :=   r_poi.poei_information11;
          p_poei_information12          :=   r_poi.poei_information12;
          p_poei_information13          :=   r_poi.poei_information13;
          p_poei_information14          :=   r_poi.poei_information14;
          p_poei_information15          :=   r_poi.poei_information15;
          p_poei_information16          :=   r_poi.poei_information16;
          p_poei_information17          :=   r_poi.poei_information17;
          p_poei_information18          :=   r_poi.poei_information18;
          p_poei_information19          :=   r_poi.poei_information19;
          p_poei_information20          :=   r_poi.poei_information20;
          p_poei_information21          :=   r_poi.poei_information21;
          p_poei_information22          :=   r_poi.poei_information22;
          p_poei_information23          :=   r_poi.poei_information23;
          p_poei_information24          :=   r_poi.poei_information24;
          p_poei_information25          :=   r_poi.poei_information25;
          p_poei_information26          :=   r_poi.poei_information26;
          p_poei_information27          :=   r_poi.poei_information27;
          p_poei_information28          :=   r_poi.poei_information28;
          p_poei_information29          :=   r_poi.poei_information29;
          p_poei_information30          :=   r_poi.poei_information30;
          p_object_version_number       :=   r_poi.object_version_number;
          p_last_update_date            :=   r_poi.last_update_date;
          p_last_updated_by             :=   r_poi.last_updated_by;
          p_last_update_login           :=   r_poi.last_update_login;
          p_created_by                  :=   r_poi.created_by;
          p_creation_date               :=   r_poi.creation_date;
    hr_utility.set_location('Leaving :' || l_proc, 100);
end fetch_positionei;

--
-- Procedure fetches the last record from per_positions or
-- ghr_positions_h_v
--
Procedure fetch_position (
	p_position_id			in	number	default null,
	p_date_effective			in	date		default null,
	p_altered_pa_request_id		in	number	default null,
	p_noa_id_corrected		in	number	default null,
	p_rowid				in	rowid		default null,
	p_pa_history_id			in	number	default null,
        p_get_ovn_flag                in    varchar2    default 'N',
	p_position_data			out nocopy	hr_all_positions_f%rowtype,
	p_result_code			out nocopy	varchar2 )  is

	cursor per_posn_f_cursor is
		select 	*
		from 	hr_all_positions_f
		where 	position_id = p_position_id
                  and   p_date_effective between effective_start_date and
                                                 effective_end_date;

	cursor per_posn_f_rowid_cursor is
		select 	*
		from 		hr_all_positions_f
		where 	rowid = p_rowid;

	cursor c_get_ovn is
      	select  object_version_number
            from    hr_all_positions
            where   position_id = p_position_id
              and   p_date_effective between effective_start_date and
                                             effective_end_date;

	cursor c_get_end_date is
		select 	date_end
		from 		hr_all_positions_f
		where		position_id = p_position_id
                  and p_date_effective between effective_start_date and
                                               effective_end_date;

	l_result_code		varchar2(30);
	l_position_data		hr_all_positions_f%rowtype;
	l_hist_data		ghr_pa_history%rowtype;
	l_proc			varchar2(30):='fetch_positionei';

Begin
	hr_utility.set_location('Entering:'|| l_proc, 5);
	p_result_code := null;
	if ( p_rowid is not null ) then
		hr_utility.set_location( l_proc, 10);
		open per_posn_f_rowid_cursor;
		fetch per_posn_f_rowid_cursor into p_position_data;
		if ( per_posn_f_rowid_cursor%NOTFOUND ) then
			p_result_code := c_not_found;
		end if;
		close per_posn_f_rowid_cursor;
		hr_utility.set_location( l_proc, 15);
	else
		hr_utility.set_location( l_proc || 'altered_pa_request_id: ' || p_altered_pa_request_id, 115);
		hr_utility.set_location( l_proc || 'noa_id_corrected: ' || p_noa_id_corrected, 215);
		hr_utility.set_location( l_proc || 'position_id: ' || p_position_id, 215);

		Fetch_hist_data(
			p_table_name		=> ghr_history_api.g_posn_table,
			p_information1		=> p_position_id,
			p_date_effective	=> p_date_effective,
			p_altered_pa_request_id	=> p_altered_pa_request_id,
			p_noa_id_corrected	=> p_noa_id_corrected,
			p_pa_history_id		=> p_pa_history_id,
		  	p_hist_data		=> l_hist_data,
			p_result_code		=> l_result_code);

		p_result_code := l_result_code;
		if nvl(l_result_code, 'found') <> c_not_found then
			ghr_history_conv_rg.conv_to_position_rg(
				p_history_data		=> l_hist_data,
				p_position_data		=> l_position_data);
			p_position_data := l_position_data;
		      if upper(p_get_ovn_flag) = 'Y' then
		         for ovn in c_get_ovn loop
            		    p_position_data.object_version_number := ovn.object_version_number;
				exit;
		         end loop;
			end if;
			for ghr_pos in c_get_end_date loop
			   p_position_data.date_end	:= ghr_pos.date_end;
			   exit;
			end loop;
		end if;
      end if;
	hr_utility.set_location ('Leaving : ' || l_proc, 100);

End fetch_position;

procedure fetch_peopleei (
    p_person_extra_info_id      in out nocopy    number
   ,p_date_effective            in out nocopy    date
   ,p_person_id                    out nocopy     number
   ,p_information_type             out nocopy     varchar2
   ,p_request_id                   out nocopy     number
   ,p_program_application_id       out nocopy     number
   ,p_program_id                   out nocopy     number
   ,p_program_update_date          out nocopy     date
   ,p_pei_attribute_category       out nocopy     varchar2
   ,p_pei_attribute1               out nocopy     varchar2
   ,p_pei_attribute2               out nocopy     varchar2
   ,p_pei_attribute3               out nocopy     varchar2
   ,p_pei_attribute4               out nocopy     varchar2
   ,p_pei_attribute5               out nocopy     varchar2
   ,p_pei_attribute6               out nocopy     varchar2
   ,p_pei_attribute7               out nocopy     varchar2
   ,p_pei_attribute8               out nocopy     varchar2
   ,p_pei_attribute9               out nocopy     varchar2
   ,p_pei_attribute10              out nocopy     varchar2
   ,p_pei_attribute11              out nocopy     varchar2
   ,p_pei_attribute12              out nocopy     varchar2
   ,p_pei_attribute13              out nocopy     varchar2
   ,p_pei_attribute14              out nocopy     varchar2
   ,p_pei_attribute15              out nocopy     varchar2
   ,p_pei_attribute16              out nocopy     varchar2
   ,p_pei_attribute17              out nocopy     varchar2
   ,p_pei_attribute18              out nocopy     varchar2
   ,p_pei_attribute19              out nocopy     varchar2
   ,p_pei_attribute20              out nocopy     varchar2
   ,p_pei_information_category     out nocopy     varchar2
   ,p_pei_information1              out nocopy     varchar2
   ,p_pei_information2             out nocopy     varchar2
   ,p_pei_information3             out nocopy     varchar2
   ,p_pei_information4             out nocopy     varchar2
   ,p_pei_information5             out nocopy     varchar2
   ,p_pei_information6             out nocopy     varchar2
   ,p_pei_information7             out nocopy     varchar2
   ,p_pei_information8             out nocopy     varchar2
   ,p_pei_information9             out nocopy     varchar2
   ,p_pei_information10            out nocopy     varchar2
   ,p_pei_information11            out nocopy     varchar2
   ,p_pei_information12            out nocopy     varchar2
   ,p_pei_information13            out nocopy     varchar2
   ,p_pei_information14            out nocopy     varchar2
   ,p_pei_information15            out nocopy     varchar2
   ,p_pei_information16            out nocopy     varchar2
   ,p_pei_information17            out nocopy     varchar2
   ,p_pei_information18            out nocopy     varchar2
   ,p_pei_information19            out nocopy     varchar2
   ,p_pei_information20            out nocopy     varchar2
   ,p_pei_information21            out nocopy     varchar2
   ,p_pei_information22            out nocopy     varchar2
   ,p_pei_information23            out nocopy     varchar2
   ,p_pei_information24            out nocopy     varchar2
   ,p_pei_information25            out nocopy     varchar2
   ,p_pei_information26            out nocopy     varchar2
   ,p_pei_information27            out nocopy     varchar2
   ,p_pei_information28            out nocopy     varchar2
   ,p_pei_information29            out nocopy     varchar2
   ,p_pei_information30            out nocopy     varchar2
   ,p_object_version_number        out nocopy     number
   ,p_last_update_date             out nocopy     date
   ,p_last_updated_by              out nocopy     number
   ,p_last_update_login            out nocopy     number
   ,p_created_by                   out nocopy     number
   ,p_creation_date                out nocopy     date
   ,p_result_code                  out nocopy     varchar2
 )
 Is
   r_pei          per_people_extra_info%rowtype;
   l_proc         varchar2(30):='fetch_peopleei (1)';
   l_result_code  varchar2(30);
 Begin
    hr_utility.set_location(' Entering : ' || l_proc, 10);
    ghr_history_fetch.fetch_peopleei(
            p_person_extra_info_id     => p_person_extra_info_id
          , p_date_effective           => p_date_effective
          , p_peopleei_data            => r_pei
          , p_result_code              => p_result_code);

    hr_utility.set_location( l_proc, 20);
          p_person_extra_info_id       :=   r_pei.person_extra_info_id;
          p_person_id                  :=   r_pei.person_id;
          p_information_type           :=   r_pei.information_type;
          p_request_id                 :=   r_pei.request_id;
          p_program_application_id     :=   r_pei.program_application_id;
          p_program_id                 :=   r_pei.program_id;
          p_program_update_date        :=   r_pei.program_update_date;
          p_pei_attribute_category     :=   r_pei.pei_attribute_category;
          p_pei_attribute1             :=   r_pei.pei_attribute1;
          p_pei_attribute2             :=   r_pei.pei_attribute2;
          p_pei_attribute3             :=   r_pei.pei_attribute3;
          p_pei_attribute4             :=   r_pei.pei_attribute4;
          p_pei_attribute5             :=   r_pei.pei_attribute5;
          p_pei_attribute6             :=   r_pei.pei_attribute6;
          p_pei_attribute7             :=   r_pei.pei_attribute7;
          p_pei_attribute8             :=   r_pei.pei_attribute8;
          p_pei_attribute9             :=   r_pei.pei_attribute9;
          p_pei_attribute10            :=   r_pei.pei_attribute10;
          p_pei_attribute11            :=   r_pei.pei_attribute11;
          p_pei_attribute12            :=   r_pei.pei_attribute12;
          p_pei_attribute13            :=   r_pei.pei_attribute13;
          p_pei_attribute14            :=   r_pei.pei_attribute14;
          p_pei_attribute15            :=   r_pei.pei_attribute15;
          p_pei_attribute16            :=   r_pei.pei_attribute16;
          p_pei_attribute17            :=   r_pei.pei_attribute17;
          p_pei_attribute18            :=   r_pei.pei_attribute18;
          p_pei_attribute19            :=   r_pei.pei_attribute19;
          p_pei_attribute20            :=   r_pei.pei_attribute20;
          p_pei_information_category   :=   r_pei.pei_information_category;
          p_pei_information1           :=   r_pei.pei_information1;
          p_pei_information2           :=   r_pei.pei_information2;
          p_pei_information3           :=   r_pei.pei_information3;
          p_pei_information4           :=   r_pei.pei_information4;
          p_pei_information5           :=   r_pei.pei_information5;
          p_pei_information6           :=   r_pei.pei_information6;
          p_pei_information7           :=   r_pei.pei_information7;
          p_pei_information8           :=   r_pei.pei_information8;
          p_pei_information9           :=   r_pei.pei_information9;
          p_pei_information10          :=   r_pei.pei_information10;
          p_pei_information11          :=   r_pei.pei_information11;
          p_pei_information12          :=   r_pei.pei_information12;
          p_pei_information13          :=   r_pei.pei_information13;
          p_pei_information14          :=   r_pei.pei_information14;
          p_pei_information15          :=   r_pei.pei_information15;
          p_pei_information16          :=   r_pei.pei_information16;
          p_pei_information17          :=   r_pei.pei_information17;
          p_pei_information18          :=   r_pei.pei_information18;
          p_pei_information19          :=   r_pei.pei_information19;
          p_pei_information20          :=   r_pei.pei_information20;
          p_pei_information21          :=   r_pei.pei_information21;
          p_pei_information22          :=   r_pei.pei_information22;
          p_pei_information23          :=   r_pei.pei_information23;
          p_pei_information24          :=   r_pei.pei_information24;
          p_pei_information25          :=   r_pei.pei_information25;
          p_pei_information26          :=   r_pei.pei_information26;
          p_pei_information27          :=   r_pei.pei_information27;
          p_pei_information28          :=   r_pei.pei_information28;
          p_pei_information29          :=   r_pei.pei_information29;
          p_pei_information30          :=   r_pei.pei_information30;
          p_object_version_number      :=   r_pei.object_version_number;
          p_last_update_date           :=   r_pei.last_update_date;
          p_last_updated_by            :=   r_pei.last_updated_by;
          p_last_update_login          :=   r_pei.last_update_login;
          p_created_by                 :=   r_pei.created_by;
          p_creation_date              :=   r_pei.creation_date;
  hr_utility.set_location(' Leaving : ' || l_proc, 100);
end fetch_peopleei ;

procedure fetch_asgei (
    p_assignment_extra_info_id  in out nocopy    number
   ,p_date_effective            in out nocopy    date
   ,p_assignment_id                out nocopy     number
   ,p_information_type             out nocopy     varchar2
   ,p_request_id                   out nocopy     number
   ,p_program_application_id       out nocopy     number
   ,p_program_id                   out nocopy     number
   ,p_program_update_date          out nocopy     date
   ,p_aei_attribute_category       out nocopy     varchar2
   ,p_aei_attribute1               out nocopy     varchar2
   ,p_aei_attribute2               out nocopy     varchar2
   ,p_aei_attribute3               out nocopy     varchar2
   ,p_aei_attribute4               out nocopy     varchar2
   ,p_aei_attribute5               out nocopy     varchar2
   ,p_aei_attribute6               out nocopy     varchar2
   ,p_aei_attribute7               out nocopy     varchar2
   ,p_aei_attribute8               out nocopy     varchar2
   ,p_aei_attribute9               out nocopy     varchar2
   ,p_aei_attribute10              out nocopy     varchar2
   ,p_aei_attribute11              out nocopy     varchar2
   ,p_aei_attribute12              out nocopy     varchar2
   ,p_aei_attribute13              out nocopy     varchar2
   ,p_aei_attribute14              out nocopy     varchar2
   ,p_aei_attribute15              out nocopy     varchar2
   ,p_aei_attribute16              out nocopy     varchar2
   ,p_aei_attribute17              out nocopy     varchar2
   ,p_aei_attribute18              out nocopy     varchar2
   ,p_aei_attribute19              out nocopy     varchar2
   ,p_aei_attribute20              out nocopy     varchar2
   ,p_aei_information_category     out nocopy     varchar2
   ,p_aei_information1             out nocopy     varchar2
   ,p_aei_information2             out nocopy     varchar2
   ,p_aei_information3             out nocopy     varchar2
   ,p_aei_information4             out nocopy     varchar2
   ,p_aei_information5             out nocopy     varchar2
   ,p_aei_information6             out nocopy     varchar2
   ,p_aei_information7             out nocopy     varchar2
   ,p_aei_information8             out nocopy     varchar2
   ,p_aei_information9             out nocopy     varchar2
   ,p_aei_information10            out nocopy     varchar2
   ,p_aei_information11            out nocopy     varchar2
   ,p_aei_information12            out nocopy     varchar2
   ,p_aei_information13            out nocopy     varchar2
   ,p_aei_information14            out nocopy     varchar2
   ,p_aei_information15            out nocopy     varchar2
   ,p_aei_information16            out nocopy     varchar2
   ,p_aei_information17            out nocopy     varchar2
   ,p_aei_information18            out nocopy     varchar2
   ,p_aei_information19            out nocopy     varchar2
   ,p_aei_information20            out nocopy     varchar2
   ,p_aei_information21            out nocopy     varchar2
   ,p_aei_information22            out nocopy     varchar2
   ,p_aei_information23            out nocopy     varchar2
   ,p_aei_information24            out nocopy     varchar2
   ,p_aei_information25            out nocopy     varchar2
   ,p_aei_information26            out nocopy     varchar2
   ,p_aei_information27            out nocopy     varchar2
   ,p_aei_information28            out nocopy     varchar2
   ,p_aei_information29            out nocopy     varchar2
   ,p_aei_information30            out nocopy     varchar2
   ,p_object_version_number        out nocopy     number
   ,p_last_update_date             out nocopy     date
   ,p_last_updated_by              out nocopy     number
   ,p_last_update_login            out nocopy     number
   ,p_created_by                   out nocopy     number
   ,p_creation_date                out nocopy     date
   ,p_result_code                  out nocopy     varchar2
 )
 Is
   r_aei          per_assignment_extra_info%rowtype;
   l_proc         varchar2(30):='fetch_asgei (1)';
   l_result_code  varchar2(30);
 Begin
    hr_utility.set_location(' Entering : ' || l_proc, 10);
    ghr_history_fetch.fetch_asgei(
            p_assignment_extra_info_id   => p_assignment_extra_info_id
          , p_date_effective             => p_date_effective
          , p_asgei_data                 => r_aei
          , p_result_code                => p_result_code);

    hr_utility.set_location( l_proc, 20);
          p_assignment_extra_info_id       :=   r_aei.assignment_extra_info_id;
          p_assignment_id                  :=   r_aei.assignment_id;
          p_information_type           :=   r_aei.information_type;
          p_request_id                 :=   r_aei.request_id;
          p_program_application_id     :=   r_aei.program_application_id;
          p_program_id                 :=   r_aei.program_id;
          p_program_update_date        :=   r_aei.program_update_date;
          p_aei_attribute_category     :=   r_aei.aei_attribute_category;
          p_aei_attribute1             :=   r_aei.aei_attribute1;
          p_aei_attribute2             :=   r_aei.aei_attribute2;
          p_aei_attribute3             :=   r_aei.aei_attribute3;
          p_aei_attribute4             :=   r_aei.aei_attribute4;
          p_aei_attribute5             :=   r_aei.aei_attribute5;
          p_aei_attribute6             :=   r_aei.aei_attribute6;
          p_aei_attribute7             :=   r_aei.aei_attribute7;
          p_aei_attribute8             :=   r_aei.aei_attribute8;
          p_aei_attribute9             :=   r_aei.aei_attribute9;
          p_aei_attribute10            :=   r_aei.aei_attribute10;
          p_aei_attribute11            :=   r_aei.aei_attribute11;
          p_aei_attribute12            :=   r_aei.aei_attribute12;
          p_aei_attribute13            :=   r_aei.aei_attribute13;
          p_aei_attribute14            :=   r_aei.aei_attribute14;
          p_aei_attribute15            :=   r_aei.aei_attribute15;
          p_aei_attribute16            :=   r_aei.aei_attribute16;
          p_aei_attribute17            :=   r_aei.aei_attribute17;
          p_aei_attribute18            :=   r_aei.aei_attribute18;
          p_aei_attribute19            :=   r_aei.aei_attribute19;
          p_aei_attribute20            :=   r_aei.aei_attribute20;
          p_aei_information_category   :=   r_aei.aei_information_category;
          p_aei_information1           :=   r_aei.aei_information1;
          p_aei_information2           :=   r_aei.aei_information2;
          p_aei_information3           :=   r_aei.aei_information3;
          p_aei_information4           :=   r_aei.aei_information4;
          p_aei_information5           :=   r_aei.aei_information5;
          p_aei_information6           :=   r_aei.aei_information6;
          p_aei_information7           :=   r_aei.aei_information7;
          p_aei_information8           :=   r_aei.aei_information8;
          p_aei_information9           :=   r_aei.aei_information9;
          p_aei_information10          :=   r_aei.aei_information10;
          p_aei_information11          :=   r_aei.aei_information11;
          p_aei_information12          :=   r_aei.aei_information12;
          p_aei_information13          :=   r_aei.aei_information13;
          p_aei_information14          :=   r_aei.aei_information14;
          p_aei_information15          :=   r_aei.aei_information15;
          p_aei_information16          :=   r_aei.aei_information16;
          p_aei_information17          :=   r_aei.aei_information17;
          p_aei_information18          :=   r_aei.aei_information18;
          p_aei_information19          :=   r_aei.aei_information19;
          p_aei_information20          :=   r_aei.aei_information20;
          p_aei_information21          :=   r_aei.aei_information21;
          p_aei_information22          :=   r_aei.aei_information22;
          p_aei_information23          :=   r_aei.aei_information23;
          p_aei_information24          :=   r_aei.aei_information24;
          p_aei_information25          :=   r_aei.aei_information25;
          p_aei_information26          :=   r_aei.aei_information26;
          p_aei_information27          :=   r_aei.aei_information27;
          p_aei_information28          :=   r_aei.aei_information28;
          p_aei_information29          :=   r_aei.aei_information29;
          p_aei_information30          :=   r_aei.aei_information30;
          p_object_version_number      :=   r_aei.object_version_number;
          p_last_update_date           :=   r_aei.last_update_date;
          p_last_updated_by            :=   r_aei.last_updated_by;
          p_last_update_login          :=   r_aei.last_update_login;
          p_created_by                 :=   r_aei.created_by;
          p_creation_date              :=   r_aei.creation_date;
  hr_utility.set_location(' Leaving : ' || l_proc, 100);
end fetch_asgei ;


-- ---------------------------------------------------------------------------
-- |--------------------------< return_special_information >----------------|
-- --------------------------------------------------------------------------

Procedure return_special_information
(p_person_id       in  number
,p_structure_name  in  varchar2
,p_effective_date  in  date
,p_special_info    out nocopy ghr_api.special_information_type
)
is
l_proc                 varchar2(72)  := 'return_special_information ';
l_id_flex_num          fnd_id_flex_structures.id_flex_num%type;
l_analysis_criteria_id per_analysis_criteria.analysis_criteria_id%type;
l_session              ghr_history_api.g_session_var_type;
l_person_analysis_id   per_person_analyses.person_analysis_id%type;
l_pa_request_id        ghr_pa_requests.pa_request_id%type;

Cursor c_flex_num is
  select    flx.id_flex_num
  from      fnd_id_flex_structures_tl flx
  where     flx.id_flex_code           = 'PEA'  --
  and       flx.application_id         =  800   --
  and       flx.id_flex_structure_name =  p_structure_name
  and       flx.language               =  'US';

   --6856387 added order by pa_history_id asc as in 10g if both from date and person analysis id is
   -- same then it is not ordering on pa_history_id(In 10g ordering will not happen based on primary key)
 Cursor    c_person_analyses is
   select  TO_NUMBER(gan.INFORMATION1) person_analysis_id,
	   FND_DATE.CANONICAL_TO_DATE(gan.information9) date_from,
           FND_DATE.CANONICAL_TO_DATE(gan.information10) date_to ,
           pa_request_id,
           TO_NUMBER(gan.INFORMATION6) analysis_Criteria_id
   from    ghr_pa_history gan ,                         -- ghr_person_analyses_h_v gan,
           per_person_analyses  per
   where   gan.table_name              = 'PER_PERSON_ANALYSES'
   and     TO_NUMBER(gan.information7) =  p_person_id                   -- information7 holds person_id
   and     per.person_id	       =  TO_NUMBER(gan.information7)
   and     TO_NUMBER(gan.INFORMATION11)=  l_id_flex_num                 -- information11 holds id_flex_Number
   and     per.id_flex_num             =  TO_NUMBER(gan.INFORMATION11)
   and     to_char(per.person_analysis_id)  =  gan.INFORMATION1     -- information1 holds person_analysis_id (3206581)
   and     p_effective_date
   between nvl(fnd_date.canonical_to_date(gan.information9),p_effective_date)
   and     nvl(fnd_date.canonical_to_date(gan.information10),p_effective_date) -- information9,information10 holds date_from,date_to
   order  by 2,1 desc, pa_history_id asc;

---- The following cursor is used only when the l_session.noa_id_correct is not null
---  and from the gh52doup.pkb
---  Not much impact so changing the select statement.

  Cursor c_pan_ovn is
    select object_version_number
    from   per_person_analyses pan
    where  person_analysis_id = l_person_analysis_id;

  Cursor    c_sit      is
    select pea.analysis_criteria_id,
           pea.segment1,
           pea.segment2,
           pea.segment3,
           pea.segment4,
           pea.segment5,
           pea.segment6,
           pea.segment7,
           pea.segment8,
           pea.segment9,
           pea.segment10,
           pea.segment11,
           pea.segment12,
           pea.segment13,
           pea.segment14,
           pea.segment15,
           pea.segment16,
           pea.segment17,
           pea.segment18,
           pea.segment19,
           pea.segment20,
           pea.segment21,
           pea.segment22,
           pea.segment23,
           pea.segment24,
           pea.segment25,
           pea.segment26,
           pea.segment27,
           pea.segment28,
           pea.segment29,
           pea.segment30
   from    per_analysis_Criteria pea
   where   pea.analysis_Criteria_id =  l_analysis_criteria_id
   and     p_effective_date
   between nvl(pea.start_date_active,p_effective_date)
   and     nvl(pea.end_date_active,p_effective_date);

BEGIN

  -- get g_session_var
  ghr_history_api.get_g_session_var(l_session);
  FOR flex_num IN c_flex_num LOOP
    l_id_flex_num  :=  flex_num.id_flex_num;
   END LOOP;

  IF l_id_flex_num IS NULL THEN
    hr_utility.set_message(8301,'GHR_38275_INV_SP_INFO_TYPE');
    hr_utility.raise_error;
  END IF;

 hr_utility.set_location('got here 1234', 4777);
 hr_utility.set_location('p_person_id: ' || p_person_id, 4777);
 hr_utility.set_location('l_id_flex_num: ' || l_id_flex_num, 4777);
 hr_utility.set_location('l_session.noa_id_correct: ' || l_session.noa_id_correct, 4777);
 hr_utility.set_location('l_session.altered_pa_request_id: ' || l_session.altered_pa_request_id, 4777);

 FOR per_analyses IN  c_person_analyses  LOOP
 --Bug 3103339
        l_pa_request_id                      := per_analyses.pa_request_id;
     IF (l_pa_request_id  = l_session.altered_pa_request_id) THEN
	p_special_info.person_analysis_id    := per_analyses.person_analysis_id;
	l_person_analysis_id                 := per_analyses.person_analysis_id;
	l_analysis_criteria_id               := per_analyses.analysis_criteria_id;
	EXIT;
     ELSE
	p_special_info.person_analysis_id    := per_analyses.person_analysis_id;
	l_person_analysis_id                 := per_analyses.person_analysis_id;
	l_analysis_criteria_id               := per_analyses.analysis_criteria_id;

      END IF;
 --Bug 3103339
  END LOOP;

 hr_utility.set_location('got here 1235', 4778);

  -- get ovn

  FOR pan_ovn IN c_pan_ovn LOOP
      p_special_info.object_version_number := pan_ovn.object_version_number;
    END LOOP;

 hr_utility.set_location('got here 1236', 4779);

 FOR special_info IN c_sit LOOP
    p_special_info.segment1   := special_info.segment1;
    p_special_info.segment2   := special_info.segment2;
    p_special_info.segment3   := special_info.segment3;
    p_special_info.segment4   := special_info.segment4;
    p_special_info.segment5   := special_info.segment5;
    p_special_info.segment6   := special_info.segment6;
    p_special_info.segment7   := special_info.segment7;
    p_special_info.segment8   := special_info.segment8;
    p_special_info.segment9   := special_info.segment9;
    p_special_info.segment10  := special_info.segment10;
    p_special_info.segment11  := special_info.segment11;
    p_special_info.segment12  := special_info.segment12;
    p_special_info.segment13  := special_info.segment13;
    p_special_info.segment14  := special_info.segment14;
    p_special_info.segment15  := special_info.segment15;
    p_special_info.segment16  := special_info.segment16;
    p_special_info.segment17  := special_info.segment17;
    p_special_info.segment18  := special_info.segment18;
    p_special_info.segment19  := special_info.segment19;
    p_special_info.segment20  := special_info.segment20;
    p_special_info.segment21  := special_info.segment21;
    p_special_info.segment22  := special_info.segment22;
    p_special_info.segment23  := special_info.segment23;
    p_special_info.segment24  := special_info.segment24;
    p_special_info.segment25  := special_info.segment25;
    p_special_info.segment26  := special_info.segment26;
    p_special_info.segment27  := special_info.segment27;
    p_special_info.segment28  := special_info.segment28;
    p_special_info.segment29  := special_info.segment29;
    p_special_info.segment30  := special_info.segment30;
  END LOOP;

 hr_utility.set_location('got here 1237', 4780);
End return_special_information;

Procedure Fetch_ASGEI_prior_root_sf50
	(
	p_assignment_id			in	number  ,
	p_information_type		in	varchar2,
	p_altered_pa_request_id		in	number  ,
	p_noa_id_corrected		in	number  ,
	p_date_effective			in	date		default null,
      p_get_ovn_flag                in    varchar2    default 'N'	,
  	p_asgei_data			out nocopy	per_assignment_extra_info%rowtype)  as


	cursor get_root_hist_id(
		cp_pa_req_id	in	number,
		cp_noa_id		in	number) is
	select min(pa_history_id)
	from ghr_pa_history
	where pa_request_id =
		(select 	min(pa_request_id)
		from 		ghr_pa_requests
		connect by 	pa_request_id = prior altered_pa_request_id
		start with 	pa_request_id = cp_pa_req_id)
	and nature_of_action_id = cp_noa_id;

	cursor  c_extra_info_id is
		select      aei.assignment_extra_info_id
		from        per_assignment_extra_info aei
		where       aei.assignment_id      =  p_assignment_id
		and         aei.information_type   =  p_information_type;

	l_pa_history_id	number;
--	l_pa_request_id	number;
	l_extra_info_id	number;
	l_result_code	varchar2(30);
	l_proc		varchar2(30):='Fetch_ASGEI_asof_root_sf50';

Begin
	hr_utility.set_location('Entering  ' || l_proc,5);
      For  extra_info in c_extra_info_id loop
          l_extra_info_id   :=   extra_info.assignment_extra_info_id;
      End loop;
      If l_extra_info_id is null then
		hr_utility.set_location('EI Not Found  ' || l_proc, 20);
		return;
	end if;

	open get_root_hist_id( p_altered_pa_request_id, p_noa_id_corrected);
	fetch get_root_hist_id into l_pa_history_id;
	if get_root_hist_id%NotFound then
		close get_root_hist_id;
		hr_utility.set_location('Root History Not Found ' || l_proc, 30);
		return;
	else
		close get_root_hist_id;
		hr_utility.set_location('Calling Fetch_asgei ' || l_proc, 50);
		fetch_asgei (
			p_assignment_extra_info_id	=> l_extra_info_id,
			p_date_effective			=> p_date_effective,
			p_pa_history_id			=> l_pa_history_id,
		      p_get_ovn_flag                => p_get_ovn_flag,
		  	p_asgei_data			=> p_asgei_data,
			p_result_code			=> l_result_code);
	end if;
	hr_utility.set_location('Leaving  ' || l_proc, 100);

End Fetch_ASGEI_prior_root_sf50;


Procedure Fetch_asgn_prior_root_sf50
	(
	p_assignment_id			in	number  ,
	p_altered_pa_request_id		in	number  ,
	p_noa_id_corrected		in	number  ,
	p_date_effective		in	date		default null,
--      p_get_ovn_flag                  in      varchar2    default 'N'	,
  	p_assignment_data		out nocopy	per_all_assignments_f%rowtype)  as



	cursor get_root_hist_id(
		cp_pa_req_id	in	number,
		cp_noa_id		in	number) is
	select min(pa_history_id)
	from ghr_pa_history
	where pa_request_id =
		(select 	min(pa_request_id)
		from 		ghr_pa_requests
		connect by 	pa_request_id = prior altered_pa_request_id
		start with 	pa_request_id = cp_pa_req_id)
	and nature_of_action_id = cp_noa_id;


	l_pa_history_id	number;
	l_result_code	varchar2(30);
	l_proc		varchar2(30):='Fetch_asgn_prior_root_sf50';

Begin
	hr_utility.set_location('Entering  ' || l_proc,5);

	open get_root_hist_id( p_altered_pa_request_id, p_noa_id_corrected);
	fetch get_root_hist_id into l_pa_history_id;
	if get_root_hist_id%NotFound then
		close get_root_hist_id;
		hr_utility.set_location('Root History Not Found ' || l_proc, 30);
		return;
	else
		close get_root_hist_id;
		hr_utility.set_location('Calling Fetch_asgn ' || l_proc, 50);
		fetch_assignment (
			p_assignment_id		=> p_assignment_id,
			p_date_effective	=> p_date_effective,
			p_pa_history_id		=> l_pa_history_id,
		        --p_get_ovn_flag        => p_get_ovn_flag,
		  	p_assignment_data	=> p_assignment_data,
			p_result_code		=> l_result_code);
	end if;
	hr_utility.set_location('Leaving  ' || l_proc, 100);

End Fetch_asgn_prior_root_sf50;

End GHR_HISTORY_FETCH;

/
