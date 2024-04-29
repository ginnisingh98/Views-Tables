--------------------------------------------------------
--  DDL for Package Body PER_REFRESH_POSITION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REFRESH_POSITION" AS
/* $Header: hrpsfref.pkb 120.1 2005/08/12 16:27:02 hsajja noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package   varchar2(100)	:= '  per_refresh_position.';  -- Global package name
gl_pos_ovn  number            ;                              -- Internal holder for pos ovn
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_copied_flag >------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_copied_flag ( p_row                    in     rowid
                            ,p_position_id           in     number
			    ,p_effective_date        in     date
			    ,p_date_effective        in     date
			    ,p_object_version_number in out nocopy number)
is
--
l_proc                    varchar2(100) := g_package||'set_copied_flag';
l_validation_start_date   date;
l_validation_end_date     date;
l_effective_start_date    date;
l_effective_end_date      date;
--
l_object_version_number   number := p_object_version_number;
--
begin
   --
   hr_utility.set_location('Entering : '||l_proc, 10);
   --
   if p_row is not null then
      --
      hr_utility.set_location(l_proc||' lock date track pos table call '||p_object_version_number, 20);
      --
      hr_psf_shd.lck(p_effective_date          => p_effective_date
                     , p_datetrack_mode        => 'CORRECTION'
  		     , p_position_id           => p_position_id
		     , p_object_version_number => p_object_version_number
		     , p_validation_start_date => l_validation_start_date
		     , p_validation_end_date   => l_validation_end_date );
      --
      hr_utility.set_location(l_proc||' updt date track pos table call ', 20);
      --
      hr_psf_upd.upd(p_position_id                => p_position_id
                     , p_effective_start_date     => l_effective_start_date
		     , p_effective_end_date       => l_effective_end_date
		     , p_copied_to_old_table_flag => 'Y'
		     , p_object_version_number    => p_object_version_number
		     , p_effective_date           => p_effective_date
		     , p_date_effective           => p_date_effective
		     , p_datetrack_mode           => 'CORRECTION');
      --
      hr_utility.set_location(l_proc||' after upd date track pos ovn: '||p_object_version_number,20);
      --
   else
      --
      hr_utility.set_location(l_proc, 30);
      --
      rollback to refresh;
   end if;
   --
   hr_utility.set_location(l_proc, 40);
   --
exception
  when others then
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(l_proc, 50);
    raise;
end set_copied_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_position_table >------------------------|
-- ----------------------------------------------------------------------------
--
function check_position_table(p_position_id             in  varchar2
                              , p_object_version_number out nocopy number)
return boolean
is
--
l_proc      varchar2(100) := g_package||'check_position_table';
--
l_object_version_number   number := p_object_version_number;
--
cursor c_ovn(p_position_id number) is
  select object_version_number
  from   per_all_positions
  where  position_id = p_position_id;
begin
    --
    hr_utility.set_location('Entering : '||l_proc, 10);
    --
    open c_ovn(p_position_id);
    fetch c_ovn into p_object_version_number;
    --
    if  c_ovn%found then
    -- if record found then return true
           return(true);
    else
       return(false);
    end if; --c_ovn%found
    close c_ovn;
    --
exception
  when others then
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(l_proc, 20);
    raise;
end check_position_table;
-- ----------------------------------------------------------------------------
-- |------------------------< refresh_all_position >------------------------|
-- ----------------------------------------------------------------------------
--
procedure refresh_all_position ( errbuf                      out nocopy varchar2
 	   		        , retcode                    out nocopy number
			        , p_refresh_date                 date     default trunc(sysdate))
is
l_position_id            number := '';
l_effective_date         date   := '';
l_object_version_number  number := '';
begin
    -- calling the refresh_position with position_id.
    --
    hr_utility.set_location('Entering:'||g_package||'refresh_all_position', 5);
    --
    refresh_position ( p_refresh_date          => p_refresh_date
                     , p_position_id           => l_position_id
                     , p_effective_date        => l_effective_date
                     , p_object_version_number => l_object_version_number
		     , errbuf                  => errbuf
		     , retcode                 => retcode );
    --
    hr_utility.set_location('Leaving:'||g_package||'refresh_all_position', 500);
    --
end refresh_all_position;
--
-- ----------------------------------------------------------------------------
-- |------------------------< refresh_position >------------------------|
-- ----------------------------------------------------------------------------
--
procedure refresh_position ( p_refresh_date                  date
                             ,p_position_id                  number   default null
                             ,p_effective_date               date
                             ,p_full_hr	                     varchar2 default 'Y'
                             ,p_object_version_number in out nocopy number
    	 		     ,errbuf                     out nocopy varchar2
 	    	             ,retcode                    out nocopy varchar2) is
--
l_proc         	      varchar2(100) := g_package||'refresh_position';
l_position_id	           number := -99.99;
l_request_id			 number;
l_program_application_id  number;
l_program_id		      number;
l_program_update_date	 date;
l_rowid			      rowid;
-- out params
l_object_version_number   number(15);
--
-- PMFLETCH p_object_version_number is not set until the end of processing
--          **within the cursor loop** . It can therefore be set so multiple different
--          values so we need to store the incoming value and reset it on exception.
l_original_object_version_num   number(15) := p_object_version_number;
-- position cursor
cursor c_pos(p_position_id number) is
   select rowid
          ,	position_id
          ,	effective_start_date
          ,	effective_end_date
          ,	availability_status_id
          ,	business_group_id
          ,	entry_step_id
          ,	job_id
          ,	location_id
          ,	organization_id
          ,	pay_freq_payroll_id
          ,	position_definition_id
          ,	position_transaction_id
          ,	prior_position_id
          ,	relief_position_id
          ,	successor_position_id
          ,	supervisor_position_id
          ,	amendment_date
          ,	amendment_recommendation
          ,	amendment_ref_number
          ,	bargaining_unit_cd
          ,	comments
          ,	current_job_prop_end_date
          ,	current_org_prop_end_date
          ,	avail_status_prop_end_date
          ,	date_effective
          ,	hr_general.get_position_date_end(position_id) date_end
          ,	earliest_hire_date
          ,	fill_by_date
          ,	frequency
          ,	fte
          ,	max_persons
          ,	hr_general.decode_position_latest_name(position_id) name
          ,	overlap_period
          ,	overlap_unit_cd
          ,	pay_term_end_day_cd
          ,	pay_term_end_month_cd
          ,	permanent_temporary_flag
          ,	permit_recruitment_flag
          ,	position_type
          ,	posting_description
          ,	probation_period
          ,	probation_period_unit_cd
          ,	replacement_required_flag
          ,	review_flag
          ,	seasonal_flag
          ,	security_requirements
          ,	status
          ,	term_start_day_cd
          ,	term_start_month_cd
          ,	time_normal_finish
          ,	time_normal_start
          ,	update_source_cd
          ,	working_hours
          ,	works_council_approval_flag
          ,	work_period_type_cd
          ,	work_term_end_day_cd
          ,	work_term_end_month_cd
          ,	information1
          ,	information2
          ,	information3
          ,	information4
          ,	information5
          ,	information6
          ,	information7
          ,	information8
          ,	information9
          ,	information10
          ,	information11
          ,	information12
          ,	information13
          ,	information14
          ,	information15
          ,	information16
          ,	information17
          ,	information18
          ,	information19
          ,	information20
          ,	information21
          ,	information22
          ,	information23
          ,	information24
          ,	information25
          ,	information26
          ,	information27
          ,	information28
          ,	information29
          ,	information30
          ,	information_category
          ,	attribute1
          ,	attribute2
          ,	attribute3
          ,	attribute4
          ,	attribute5
          ,	attribute6
          ,	attribute7
          ,	attribute8
          ,	attribute9
          ,	attribute10
          ,	attribute11
          ,	attribute12
          ,	attribute13
          ,	attribute14
          ,	attribute15
          ,	attribute16
          ,	attribute17
          ,	attribute18
          ,	attribute19
          ,	attribute20
          ,	attribute21
          ,	attribute22
          ,	attribute23
          ,	attribute24
          ,	attribute25
          ,	attribute26
          ,	attribute27
          ,	attribute28
          ,	attribute29
          ,	attribute30
          ,	attribute_category
          ,	request_id
          ,	program_application_id
          ,	program_id
          ,	program_update_date
          ,	created_by
          ,	creation_date
          ,	last_updated_by
          ,	last_update_date
          ,	last_update_login
          ,	object_version_number
          ,	entry_grade_id
          ,	entry_grade_rule_id
          ,	proposed_fte_for_layoff
          ,	proposed_date_for_layoff
          ,	pay_basis_id
          ,	supervisor_id
		  , copied_to_old_table_flag
   from   hr_all_positions_f
   where  (copied_to_old_table_flag <> 'Y'
   or     copied_to_old_table_flag is null )
   --and    effective_start_date <= p_refresh_date
   and    position_id = p_position_id
   order by position_id, effective_start_date desc;
--
--
--
cursor c_all_pos is
   select rowid
          ,	position_id
          ,	effective_start_date
          ,	effective_end_date
          ,	availability_status_id
          ,	business_group_id
          ,	entry_step_id
          ,	job_id
          ,	location_id
          ,	organization_id
          ,	pay_freq_payroll_id
          ,	position_definition_id
          ,	position_transaction_id
          ,	prior_position_id
          ,	relief_position_id
          ,	successor_position_id
          ,	supervisor_position_id
          ,	amendment_date
          ,	amendment_recommendation
          ,	amendment_ref_number
          ,	bargaining_unit_cd
          ,	comments
          ,	current_job_prop_end_date
          ,	current_org_prop_end_date
          ,	avail_status_prop_end_date
          ,	date_effective
          ,	hr_general.get_position_date_end(position_id) date_end
          ,	earliest_hire_date
          ,	fill_by_date
          ,	frequency
          ,	fte
          ,	max_persons
          ,	hr_general.decode_position_latest_name(position_id) name
          ,	overlap_period
          ,	overlap_unit_cd
          ,	pay_term_end_day_cd
          ,	pay_term_end_month_cd
          ,	permanent_temporary_flag
          ,	permit_recruitment_flag
          ,	position_type
          ,	posting_description
          ,	probation_period
          ,	probation_period_unit_cd
          ,	replacement_required_flag
          ,	review_flag
          ,	seasonal_flag
          ,	security_requirements
          ,	status
          ,	term_start_day_cd
          ,	term_start_month_cd
          ,	time_normal_finish
          ,	time_normal_start
          ,	update_source_cd
          ,	working_hours
          ,	works_council_approval_flag
          ,	work_period_type_cd
          ,	work_term_end_day_cd
          ,	work_term_end_month_cd
          ,	information1
          ,	information2
          ,	information3
          ,	information4
          ,	information5
          ,	information6
          ,	information7
          ,	information8
          ,	information9
          ,	information10
          ,	information11
          ,	information12
          ,	information13
          ,	information14
          ,	information15
          ,	information16
          ,	information17
          ,	information18
          ,	information19
          ,	information20
          ,	information21
          ,	information22
          ,	information23
          ,	information24
          ,	information25
          ,	information26
          ,	information27
          ,	information28
          ,	information29
          ,	information30
          ,	information_category
          ,	attribute1
          ,	attribute2
          ,	attribute3
          ,	attribute4
          ,	attribute5
          ,	attribute6
          ,	attribute7
          ,	attribute8
          ,	attribute9
          ,	attribute10
          ,	attribute11
          ,	attribute12
          ,	attribute13
          ,	attribute14
          ,	attribute15
          ,	attribute16
          ,	attribute17
          ,	attribute18
          ,	attribute19
          ,	attribute20
          ,	attribute21
          ,	attribute22
          ,	attribute23
          ,	attribute24
          ,	attribute25
          ,	attribute26
          ,	attribute27
          ,	attribute28
          ,	attribute29
          ,	attribute30
          ,	attribute_category
          ,	request_id
          ,	program_application_id
          ,	program_id
          ,	program_update_date
          ,	created_by
          ,	creation_date
          ,	last_updated_by
          ,	last_update_date
          ,	last_update_login
          ,	object_version_number
          ,	entry_grade_id
          ,	entry_grade_rule_id
          ,	proposed_fte_for_layoff
          ,	proposed_date_for_layoff
          ,	pay_basis_id
          ,	supervisor_id
		  , copied_to_old_table_flag
   from   hr_all_positions_f
   where  (copied_to_old_table_flag <> 'Y'
   or     copied_to_old_table_flag is null )
   --and    effective_start_date <= p_refresh_date
   order by position_id, effective_start_date desc;
   --
   rec c_pos%rowtype;
   ---
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   per_refresh_position.refreshing_position := true;
   --
   hr_utility.set_location(l_proc||' p_refresh_date ' || p_refresh_date, 5);
   --
   if p_position_id is not null then
      open c_pos(p_position_id);
   else
      open c_all_pos;
   end if;

   loop
      if p_position_id is not null then
        fetch c_pos into rec;
        exit when c_pos%NOTFOUND;
      else
        fetch c_all_pos into rec;
        exit when c_all_pos%NOTFOUND;
      end if;
      --
      savepoint refresh;
      --
	 -- (reset gl variable )
      --
      gl_pos_ovn := '' ;
	 --
      hr_utility.set_location(l_proc||' POSITION ID ' || rec.position_id, 10);
      --
      if rec.position_id <> l_position_id then
        --
          l_rowid 	           := rec.rowid ;
          l_position_id           := rec.position_id ;
          l_object_version_number := rec.object_version_number;
          --      call per_all_positions api.
          if (check_position_table(rec.position_id, l_object_version_number)) then
          --
          hr_utility.set_location(l_proc||' Lock per_all_positions api call ', 20);
          --
  	  begin
	       -- lock
		  if  p_full_hr = 'N' or rec.effective_start_date <=  p_refresh_date then

		  per_pos_shd.lck(p_position_id             => rec.position_id
	                       , p_object_version_number => l_object_version_number);
                  --
                  hr_utility.set_location(l_proc||' upd per_all_positions api call ', 30);
                  --
        	  per_pos_upd.upd
                    (p_position_id                  => rec.position_id
                    ,p_successor_position_id        => rec.successor_position_id
                    ,p_relief_position_id	    => rec.relief_position_id
                    ,p_location_id	            => rec.location_id
                    ,p_position_definition_id       => rec.position_definition_id
                    ,p_date_effective               => rec.date_effective
                    ,p_comments                     => rec.comments
                    ,p_date_end                     => rec.date_end
                    ,p_frequency                    => rec.frequency
                    ,p_name                         => rec.name
                    ,p_probation_period             => rec.probation_period
                    ,p_probation_period_units       => rec.probation_period_unit_cd
                    ,p_replacement_required_flag    => rec.replacement_required_flag
                    ,p_time_normal_finish           => rec.time_normal_finish
                    ,p_time_normal_start            => rec.time_normal_start
                    ,p_status                       => rec.status
                    ,p_working_hours                => rec.working_hours
                    ,p_attribute_category           => rec.attribute_category
                    ,p_attribute1                   => rec.attribute1
                    ,p_attribute2                   => rec.attribute2
                    ,p_attribute3                   => rec.attribute3
                    ,p_attribute4                   => rec.attribute4
                    ,p_attribute5                   => rec.attribute5
                    ,p_attribute6                   => rec.attribute6
                    ,p_attribute7                   => rec.attribute7
                    ,p_attribute8                   => rec.attribute8
                    ,p_attribute9                   => rec.attribute9
                    ,p_attribute10                  => rec.attribute10
                    ,p_attribute11                  => rec.attribute11
                    ,p_attribute12                  => rec.attribute12
                    ,p_attribute13                  => rec.attribute13
                    ,p_attribute14                  => rec.attribute14
                    ,p_attribute15                  => rec.attribute15
                    ,p_attribute16                  => rec.attribute16
                    ,p_attribute17                  => rec.attribute17
                    ,p_attribute18                  => rec.attribute18
                    ,p_attribute19                  => rec.attribute19
                    ,p_attribute20                  => rec.attribute20
                    ,p_object_version_number        => l_object_version_number
                    ,p_validate                     => FALSE
                    );
            --
		  -- Store POS OVN in gl variable to help see the last pos ovn
		  --
            gl_pos_ovn := l_object_version_number ;
            --
               hr_utility.set_location(l_proc, 60);
               --
               l_object_version_number := rec.object_version_number;
               --
               begin
	           set_copied_flag ( p_row                 => l_rowid
                                  ,p_position_id           => rec.position_id
		   	                ,p_effective_date        => rec.effective_start_date
		    	                ,p_date_effective        => rec.date_effective
			                ,p_object_version_number => l_object_version_number );
               exception
               when others then
                  rollback to refresh;
	             errbuf  := 'S'||l_position_id||'-'||sqlerrm ;
                     retcode := 1 ;
  	             if p_position_id is not null then
  	               raise;
  	             end if;
               end;
               -- set object version number for single position refresh request.
               if p_effective_date between rec.effective_start_date and rec.effective_end_date then
                  p_object_version_number := l_object_version_number;
               end if;
               --
		  end if; -- refresh only if the date is valid
		  --
            hr_utility.set_location(l_proc, 40);
        	  --
  	      exception
  	          when others then
  		     if p_position_id is not null then
  		            raise;
  		     end if;
  		     l_rowid := null;
  	             errbuf  := 'U'||l_position_id||'-'||sqlerrm ;
  	             retcode := 1 ;
        	     --
                     hr_utility.set_location(' Exp:'||errbuf, 40);
        	     --
  	       end;
          else
       	      --
              hr_utility.set_location(l_proc, 50);
      	      --
              begin
       	      --
              hr_utility.set_location(l_proc||' insert per_all_positions api call ', 50);
       	      --
		    per_pos_ins.ins
                    (p_position_id                  => rec.position_id
                    ,p_business_group_id            => rec.business_group_id
                    ,p_job_id                       => rec.job_id
                    ,p_organization_id              => rec.organization_id
                    ,p_successor_position_id        => rec.successor_position_id
                    ,p_relief_position_id           => rec.relief_position_id
                    ,p_location_id                  => rec.location_id
                    ,p_position_definition_id       => rec.position_definition_id
                    ,p_date_effective               => rec.date_effective
                    ,p_comments                     => rec.comments
                    ,p_date_end                     => rec.date_end
                    ,p_frequency                    => rec.frequency
                    ,p_name                         => rec.name
                    ,p_probation_period             => rec.probation_period
                    ,p_probation_period_units       => rec.probation_period_unit_cd
                    ,p_replacement_required_flag    => rec.replacement_required_flag
                    ,p_time_normal_finish           => rec.time_normal_finish
                    ,p_time_normal_start            => rec.time_normal_start
                    ,p_status                       => rec.status
                    ,p_working_hours                => rec.working_hours
                    ,p_attribute_category           => rec.attribute_category
                    ,p_attribute1                   => rec.attribute1
                    ,p_attribute2                   => rec.attribute2
                    ,p_attribute3                   => rec.attribute3
                    ,p_attribute4                   => rec.attribute4
                    ,p_attribute5                   => rec.attribute5
                    ,p_attribute6                   => rec.attribute6
                    ,p_attribute7                   => rec.attribute7
                    ,p_attribute8                   => rec.attribute8
                    ,p_attribute9                   => rec.attribute9
                    ,p_attribute10                  => rec.attribute10
                    ,p_attribute11                  => rec.attribute11
                    ,p_attribute12                  => rec.attribute12
                    ,p_attribute13                  => rec.attribute13
                    ,p_attribute14                  => rec.attribute14
                    ,p_attribute15                  => rec.attribute15
                    ,p_attribute16                  => rec.attribute16
                    ,p_attribute17                  => rec.attribute17
                    ,p_attribute18                  => rec.attribute18
                    ,p_attribute19                  => rec.attribute19
                    ,p_attribute20                  => rec.attribute20
                    ,p_object_version_number        => l_object_version_number
                    ,p_validate                     => FALSE
                    );
              --
		    -- Store POS OVN in gl variable to help see the last pos ovn
		    --
              gl_pos_ovn := l_object_version_number ;
        	    --
              hr_utility.set_location(l_proc, 65);
              --
              l_object_version_number := rec.object_version_number;
              --
              begin
	          set_copied_flag ( p_row                 => l_rowid
                                ,p_position_id           => rec.position_id
		   	                 ,p_effective_date        => rec.effective_start_date
		    	                 ,p_date_effective        => rec.date_effective
			                 ,p_object_version_number => l_object_version_number );
              exception
              when others then
                 rollback to refresh;
	            errbuf  := 'S'||l_position_id||'-'||sqlerrm ;
                    retcode := 1 ;
  	            if p_position_id is not null then
  	              raise;
  	            end if;
              end;
              -- set object version number for single position refresh request.
              if p_effective_date between rec.effective_start_date and rec.effective_end_date then
                 p_object_version_number := l_object_version_number;
              end if;
              --
              hr_utility.set_location(l_proc||' after ins per_all_positions ', 50);
        	    --
  		  exception
  		     when others then
                         hr_utility.set_location(l_proc||' When Others raised ', 50);
  		         if p_position_id is not null then
  		             raise;
  		         end if;
  		     l_rowid := null;
  		     errbuf  := 'I'||l_position_id||'-'||sqlerrm ;
  		     retcode := 1 ;
        	     --
                     hr_utility.set_location(' Exp:'||errbuf, 50);
        	     --
  		  end;
          end if; -- check_position_table(position_id)
      end if;  -- rec.position_id <> l_position_id
      --
      hr_utility.set_location(l_proc, 70);
      --
      if p_position_id is null then
        commit;
      end if;
      --
   end loop; -- rec in c_pos loop
   --
   if p_position_id is not null then
      close c_pos;
   else
      close c_all_pos;
   end if;
   --
   per_refresh_position.refreshing_position := false;
exception
   when others then
      --
      per_refresh_position.refreshing_position := false;
      --
      p_object_version_number := l_original_object_version_num;
      --
      if p_position_id is not null then
          raise;
      end if;
      errbuf  := 'Oth '||l_position_id||sqlerrm ;
       --
      hr_utility.set_location(l_proc||' '||errbuf, 70);
      --
      retcode := 2 ;
END refresh_position;
--
-- ----------------------------------------------------------------------------
-- |------------------------< refresh_position_purge >------------------------|
-- ----------------------------------------------------------------------------
procedure refresh_position_purge (p_position_id in number) is

l_ovn number := 0;
cursor c_chk_pos is
   select object_version_number
   from per_all_positions p
   where position_id = p_position_id
   and position_id not in ( select position_id from hr_all_positions_f where position_id = p_position_id) ;
begin
   hr_utility.set_location('Entering:'||g_package||'refresh_position_purge', 600);
   for i in c_chk_pos loop
       per_pos_del.del
       ( p_position_id             => p_position_id ,
         p_object_version_number   => i.object_version_number ,
         p_validate                => false );
       --
   end loop;
   hr_utility.set_location('Leaving:'||g_package||'refresh_position_purge', 600);
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< refresh_single_position >------------------------|
-- ----------------------------------------------------------------------------
--
procedure refresh_single_position ( p_refresh_date                  date
                                   , p_position_id                  number
                                   , p_effective_date               date
                                   , p_object_version_number in out nocopy number)
is
l_errbuf    varchar2(2000);
l_retcode   number;
begin
    -- calling the refresh_position with position_id.
    --
    hr_utility.set_location('Entering:'||g_package||'refresh_single_position', 5);
    --
    if not (hr_position_api.full_hr) then
    refresh_position ( p_refresh_date          => p_refresh_date
                     , p_position_id           => p_position_id
                     , p_effective_date        => p_effective_date
                     , p_full_hr               => 'N'
                     , p_object_version_number => p_object_version_number
                     , errbuf                  => l_errbuf
                     , retcode                 => l_retcode );
    else
    refresh_position ( p_refresh_date          => p_refresh_date
                     , p_position_id           => p_position_id
                     , p_effective_date        => p_effective_date
                     , p_full_hr               => 'Y'
                     , p_object_version_number => p_object_version_number
                     , errbuf                  => l_errbuf
                     , retcode                 => l_retcode );
    end if;
    --
    -- purge position if purged from hr_all_positions_f
    --
    refresh_position_purge(p_position_id => p_position_id);
    --
    -- following update is put in place for Non HR Products who refers per_all_positions
    --
    update per_all_positions
    set date_end = hr_general.get_position_date_end(position_id)
    where position_id = p_position_id;
    --
    hr_utility.set_location('Entering:'||g_package||'refresh_single_position', 500);
    --
end refresh_single_position;
--
function get_position_ovn return number
is
--
-- Retrive POS OVN from gl variable
--
begin
return(gl_pos_ovn);
end;
--
END PER_REFRESH_POSITION;

/
