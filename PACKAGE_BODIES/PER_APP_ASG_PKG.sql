--------------------------------------------------------
--  DDL for Package Body PER_APP_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APP_ASG_PKG" as
/* $Header: peasg02t.pkb 120.3 2006/05/17 19:22:31 irgonzal ship $ */
--
--                         PRIVATE PROCEDURES				--
--
--
-- Procedure
--   set_end_date
-- Purpose
--   Sets an end date on rows which are deleted with delete mode
--   FUTURE_CHANGES or NEXT_CHANGE
--
procedure set_end_date(
	p_new_end_date	date,
	p_assignment_id number )  is
--
begin
--
	update	per_assignments_f a
	set	a.effective_end_date	= p_new_end_date
	where	a.assignment_id		= p_assignment_id
	and	a.effective_end_date	= (
		select	max(a2.effective_end_date)
		from	per_assignments_f a2
		where	a2.assignment_id = a.assignment_id);
--
end set_end_date;


--
-- Private procedure. Called to ensure that child rows are removed before parent is removed from
-- the database. This is a new procedure as per_assignment_budget_values_f is now datetracked and
-- rows will need to be removed from this when the assignment is removed.
--
--
-- SASmith 31-March-1998

 procedure delete_child ( p_assignment_id  in number,
			  p_delete_mode    in varchar2) is

  p_del_flag VARCHAR2(1) := 'N';

--
 BEGIN

 --  hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_child' , 5) ;
--
   BEGIN
      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       select null
       from   per_assignment_budget_values_f
              where  assignment_id = p_assignment_id
       and    p_delete_mode = 'ZAP');

   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag = 'Y' and
      p_delete_mode     = 'ZAP'  THEN
   --
   --   hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_child' , 10) ;

      Delete per_assignment_budget_values_f
      where assignment_id = p_assignment_id;

   END IF;
   --
END delete_child;




--									--
--									--
--                         PUBLIC PROCEDURES				--
-- Procedure
--   cleanup_letters
-- Purpose
--   Remove extra letters for the given assignment
-- Arguments
--   As below
procedure cleanup_letters ( p_assignment_id  	        in number ) is
begin
--
  delete from per_letter_request_lines p
  where p.assignment_id = p_assignment_id
  and   exists
      (select null
       from per_letter_requests r2
       where r2.letter_request_id = p.letter_request_id
       and   r2.request_status = 'PENDING')
  and   not exists
      (select null
       from   per_assignments_f a
       where  assignment_id = p_assignment_id
       and  ( (a.effective_start_date = p.date_from
               and
               a.assignment_status_type_id = p.assignment_status_type_id)
             or (a.effective_end_date =
                      (select max(a2.effective_end_date)
                       from   per_assignments_f a2
                       where  a2.assignment_id = p_assignment_id)
                 and a.effective_end_date = p.date_from   ))) ;
--
end cleanup_letters ;
--								        --
procedure insert_row(
	p_row_id			   in out nocopy varchar2,
	p_assignment_id                    in out nocopy number,
	p_effective_start_date             date,
	p_effective_end_date               date,
	p_business_group_id                number,
	p_recruiter_id                     number,
	p_grade_id                         number,
	p_position_id                      number,
	p_job_id                           number,
	p_assignment_status_type_id        number,
	p_location_id                      number,
	p_location_code                    in out nocopy varchar2,
	p_person_referred_by_id            number,
	p_supervisor_id                    number,
	p_person_id                        number,
	p_recruitment_activity_id          number,
	p_source_organization_id           number,
	p_organization_id                  number,
	p_people_group_id                  number,
	p_people_group_name		   varchar2,
	p_vacancy_id                       number,
	p_assignment_sequence              in out nocopy number,
	p_assignment_type                  in out nocopy varchar2,
	p_primary_flag                     in out nocopy varchar2,
	p_application_id                   number,
	p_change_reason                    varchar2,
	p_comment_id                       number,
	p_date_probation_end               date,
	p_frequency                        varchar2,
	p_frequency_meaning                in out nocopy varchar2,
	p_manager_flag                     varchar2,
	p_normal_hours                     number,
	p_probation_period                 number,
	p_probation_unit                   varchar2,
	p_source_type                      varchar2,
	p_time_normal_finish               varchar2,
	p_time_normal_start                varchar2,
	p_request_id                       number,
	p_program_application_id           number,
	p_program_id                       number,
	p_program_update_date              date,
	p_ass_attribute_category           varchar2,
	p_ass_attribute1                   varchar2,
	p_ass_attribute2                   varchar2,
	p_ass_attribute3                   varchar2,
	p_ass_attribute4                   varchar2,
	p_ass_attribute5                   varchar2,
	p_ass_attribute6                   varchar2,
	p_ass_attribute7                   varchar2,
	p_ass_attribute8                   varchar2,
	p_ass_attribute9                   varchar2,
	p_ass_attribute10                  varchar2,
	p_ass_attribute11                  varchar2,
	p_ass_attribute12                  varchar2,
	p_ass_attribute13                  varchar2,
	p_ass_attribute14                  varchar2,
	p_ass_attribute15                  varchar2,
	p_ass_attribute16                  varchar2,
	p_ass_attribute17                  varchar2,
	p_ass_attribute18                  varchar2,
	p_ass_attribute19                  varchar2,
	p_ass_attribute20                  varchar2,
	p_ass_attribute21                  varchar2,
	p_ass_attribute22                  varchar2,
	p_ass_attribute23                  varchar2,
	p_ass_attribute24                  varchar2,
	p_ass_attribute25                  varchar2,
	p_ass_attribute26                  varchar2,
	p_ass_attribute27                  varchar2,
	p_ass_attribute28                  varchar2,
	p_ass_attribute29                  varchar2,
	p_ass_attribute30                  varchar2,
	p_session_date			   date,
	p_contract_id                      number default null,
	p_cagr_id_flex_num                 number default null,
	p_cagr_grade_def_id                number default null,
	p_establishment_id                 number default null,
	p_collective_agreement_id          number default null,
	p_notice_period			   number   default null,
        p_notice_period_uom		   varchar2 default null,
        p_employee_category		   varchar2 default null,
        p_work_at_home			   varchar2 default null,
        p_job_post_source_name		   varchar2 default null,
        p_grade_ladder_pgm_id		   number default null,
        p_supervisor_assignment_id         number   default null
  ) is
cursor c1 is
	select 	per_assignments_s.nextval
	from	sys.dual;
cursor c2 is
	select	rowid
	from	per_assignments_f
	where	assignment_id		= P_ASSIGNMENT_ID
	and     effective_start_date  	= P_EFFECTIVE_START_DATE
        and     effective_end_date    	= P_EFFECTIVE_END_DATE;
--
l_assignment_status_id number; -- discards output from irc_asg_status api
l_object_version_number number; -- discards output from irc_asg_status api
--
begin
--
--    PRE-INSERT CHECKS
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 1 ) ;
   hr_utility.trace('p_grade_ladder_pgm_id : ' || p_grade_ladder_pgm_id);
   check_apl_end_date ( p_application_id => p_application_id ) ;
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 2 ) ;
   check_current_applicant ( p_person_id => p_person_id,
			     p_session_date => p_session_date ) ;
--
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 3 ) ;
   open c1;
   fetch c1 into P_ASSIGNMENT_ID;
   close c1;
--
   -- Set Assignment Type and Primary flag
   p_assignment_type := 'A' ;
   p_primary_flag    := 'N' ;
   --
   --
   -- Generate new assignment sequence
    hr_assignment.gen_new_ass_sequence
               ( p_person_id,
		 'A',
		 p_assignment_sequence
	        );
   --
   --
   begin
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 4 ) ;
     insert into per_assignments_f (
	assignment_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	recruiter_id,
	grade_id,
	position_id,
	job_id,
	assignment_status_type_id,
	location_id,
	person_referred_by_id,
	supervisor_id,
	person_id,
	recruitment_activity_id,
	source_organization_id,
	organization_id,
	people_group_id,
	vacancy_id,
	assignment_sequence,
	assignment_type,
	primary_flag,
	application_id,
	change_reason,
	comment_id,
	date_probation_end,
	frequency,
	manager_flag,
	normal_hours,
	probation_period,
	probation_unit,
	source_type,
	time_normal_finish,
	time_normal_start,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	ass_attribute_category,
	ass_attribute1,
	ass_attribute2,
	ass_attribute3,
	ass_attribute4,
	ass_attribute5,
	ass_attribute6,
	ass_attribute7,
	ass_attribute8,
	ass_attribute9,
	ass_attribute10,
	ass_attribute11,
	ass_attribute12,
	ass_attribute13,
	ass_attribute14,
	ass_attribute15,
	ass_attribute16,
	ass_attribute17,
	ass_attribute18,
	ass_attribute19,
	ass_attribute20,
	ass_attribute21,
	ass_attribute22,
	ass_attribute23,
	ass_attribute24,
	ass_attribute25,
	ass_attribute26,
	ass_attribute27,
	ass_attribute28,
	ass_attribute29,
	ass_attribute30,
	contract_id,
	cagr_id_flex_num,
	cagr_grade_def_id,
	establishment_id,
	collective_agreement_id,
	notice_period,
	notice_period_uom,
	work_at_home,
	employee_category,
	job_post_source_name ,
	grade_ladder_pgm_id,
        supervisor_assignment_id )
values (
	p_assignment_id,
	p_effective_start_date,
	p_effective_end_date,
	p_business_group_id,
	p_recruiter_id,
	p_grade_id,
	p_position_id,
	p_job_id,
	p_assignment_status_type_id,
	p_location_id,
	p_person_referred_by_id,
	p_supervisor_id,
	p_person_id,
	p_recruitment_activity_id,
	p_source_organization_id,
	p_organization_id,
	p_people_group_id,
	p_vacancy_id,
	p_assignment_sequence,
	p_assignment_type,
	p_primary_flag,
	p_application_id,
	p_change_reason,
	p_comment_id,
	p_date_probation_end,
	p_frequency,
	p_manager_flag,
	p_normal_hours,
	p_probation_period,
	p_probation_unit,
	p_source_type,
	p_time_normal_finish,
	p_time_normal_start,
	p_request_id,
	p_program_application_id,
	p_program_id,
	p_program_update_date,
	p_ass_attribute_category,
	p_ass_attribute1,
	p_ass_attribute2,
	p_ass_attribute3,
	p_ass_attribute4,
	p_ass_attribute5,
	p_ass_attribute6,
	p_ass_attribute7,
	p_ass_attribute8,
	p_ass_attribute9,
	p_ass_attribute10,
	p_ass_attribute11,
	p_ass_attribute12,
	p_ass_attribute13,
	p_ass_attribute14,
	p_ass_attribute15,
	p_ass_attribute16,
	p_ass_attribute17,
	p_ass_attribute18,
	p_ass_attribute19,
	p_ass_attribute20,
	p_ass_attribute21,
	p_ass_attribute22,
	p_ass_attribute23,
	p_ass_attribute24,
	p_ass_attribute25,
	p_ass_attribute26,
	p_ass_attribute27,
	p_ass_attribute28,
	p_ass_attribute29,
	p_ass_attribute30,
	p_contract_id,
	p_cagr_id_flex_num,
	p_cagr_grade_def_id,
	p_establishment_id,
	p_collective_agreement_id,
	p_notice_period,
	p_notice_period_uom,
	p_work_at_home,
	p_employee_category,
	p_job_post_source_name ,
	p_grade_ladder_pgm_id,
        p_supervisor_assignment_id
) ;
   end;
--
   open c2;
   fetch c2 into P_ROW_ID;
   close c2;
--
-- Update people group
--
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 5 ) ;
   per_applicant_pkg.update_group ( p_people_group_id,
				    p_people_group_name ) ;
--
-- Create letter request
--
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 6 ) ;
   per_applicant_pkg.check_for_letter_requests (
                p_business_group_id         => p_business_group_id,
		p_per_system_status   	    => NULL, --***TEMP
		p_assignment_status_type_id => p_assignment_status_type_id,
		p_person_id		    => p_person_id,
		p_assignment_id		    => p_assignment_id,
		p_effective_start_date      => p_effective_start_date,
		p_validation_start_date     => p_effective_start_date,
                p_vacancy_id		    => p_vacancy_id ) ;
--
-- Create default budget values
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 7 ) ;
   per_applicant_pkg.create_default_budget_values (
			p_business_group_id,
			p_assignment_id,
			p_effective_start_date,
			p_effective_end_date) ;
--
--
-- Set the location code if the location id is not null and the code is
-- null
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 8 ) ;
  if ( ( p_location_id is not null ) and ( p_location_code is null ) ) then
     p_location_code := per_applicant_pkg.get_location_code ( p_location_id ) ;
  end if;
--
--
-- Set the frequency meaning if the frequency is not null and the meaning is
-- null
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 9 ) ;
  if ( ( p_frequency is not null ) and ( p_frequency_meaning is null ) ) then
     p_frequency_meaning := hr_general.decode_lookup( 'FREQUENCY',
						      p_frequency ) ;
  end if;
--
--
-- Insert record into iRec Asg Statuses. Otherwise the applications applied
-- through PUI, will not visible in iRec for applicants created through iRec
-- Bug# 2985747
  irc_asg_status_api.create_irc_asg_status
            ( p_validate                  => FALSE
            , p_assignment_id              => p_assignment_id
            , p_assignment_status_type_id  => p_assignment_status_type_id
            , p_status_change_date        => p_effective_start_date
            , p_status_change_reason      => p_change_reason
            , p_assignment_status_id      => l_assignment_status_id
            , p_object_version_number      => l_object_version_number
            );
--
-- Start of OAB code addition
-- Whenever Applicant Information is getting changed/inserted via Applicant forms
-- we need to trigger OAB Lifeevents. The following ben call will trigger LE
-- Bug 3506363

   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 10 ) ;
   hr_utility.set_location ( 'Before OAB Call' , 11 ) ;
   ben_dt_trgr_handle.assignment
            (p_rowid                   => p_row_id
            ,p_assignment_id           => p_assignment_id
            ,p_business_group_id       => p_business_group_id
	    ,p_person_id               => p_person_id
	    ,p_effective_start_date    => p_effective_start_date
	    ,p_effective_end_date      => p_effective_end_date
	    ,p_assignment_status_type_id  => p_assignment_status_type_id
	    ,p_assignment_type         => p_assignment_type
	    ,p_organization_id         => p_organization_id
	    ,p_primary_flag            => p_primary_flag
	    ,p_change_reason           => p_change_reason
	    ,p_employment_category     => null
	    ,p_frequency               => p_frequency
	    ,p_grade_id                => p_grade_id
	    ,p_job_id                  => p_job_id
	    ,p_position_id             => p_position_id
	    ,p_location_id             => p_location_id
	    ,p_normal_hours            => p_normal_hours
	    ,p_payroll_id              => null
	    ,p_pay_basis_id            => null
	    ,p_bargaining_unit_code    => null
	    ,p_labour_union_member_flag => null
            ,p_hourly_salaried_code    => null
            ,p_people_group_id    => p_people_group_id
	    ,p_ass_attribute1 => p_ass_attribute1
	    ,p_ass_attribute2 => p_ass_attribute2
	    ,p_ass_attribute3 => p_ass_attribute3
	    ,p_ass_attribute4 => p_ass_attribute4
	    ,p_ass_attribute5 => p_ass_attribute5
	    ,p_ass_attribute6 => p_ass_attribute6
	    ,p_ass_attribute7 => p_ass_attribute7
	    ,p_ass_attribute8 => p_ass_attribute8
	    ,p_ass_attribute9 => p_ass_attribute9
	    ,p_ass_attribute10 => p_ass_attribute10
	    ,p_ass_attribute11 => p_ass_attribute11
	    ,p_ass_attribute12 => p_ass_attribute12
	    ,p_ass_attribute13 => p_ass_attribute13
	    ,p_ass_attribute14 => p_ass_attribute14
	    ,p_ass_attribute15 => p_ass_attribute15
	    ,p_ass_attribute16 => p_ass_attribute16
	    ,p_ass_attribute17 => p_ass_attribute17
	    ,p_ass_attribute18 => p_ass_attribute18
	    ,p_ass_attribute19 => p_ass_attribute19
	    ,p_ass_attribute20 => p_ass_attribute20
	    ,p_ass_attribute21 => p_ass_attribute21
	    ,p_ass_attribute22 => p_ass_attribute22
	    ,p_ass_attribute23 => p_ass_attribute23
	    ,p_ass_attribute24 => p_ass_attribute24
	    ,p_ass_attribute25 => p_ass_attribute25
	    ,p_ass_attribute26 => p_ass_attribute26
	    ,p_ass_attribute27 => p_ass_attribute27
	    ,p_ass_attribute28 => p_ass_attribute28
	    ,p_ass_attribute29 => p_ass_attribute29
	    ,p_ass_attribute30 => p_ass_attribute30
            );

   hr_utility.set_location ( 'After OAB Call' , 11 ) ;
   hr_utility.set_location ( 'PER_APP_ASG_PKG.insert_row' , 11 ) ;



-- Bug 3506363
-- end of OAB Code change

--
end insert_row;
-----------------------------------------------------------------------------
--
-- Delete Procedure
--
procedure delete_row(p_row_id	           varchar2,
		     p_assignment_id       number,
		     p_new_end_date        date,
		     p_effective_end_date  date,
		     p_validation_end_date date,
		     p_session_date	   date,
		     p_delete_mode         varchar2 ) is

  l_cost_warning boolean; -- used to catch the cost warning from tidy_up_ref_int
                          -- but as Apl asg's can't have costing records no need
			  -- to return to caller.
begin
--
-- Addition of call to delete_child to ensure child rows are removed when parent is removed on mode of
-- 'ZAP'
-- SASmith 31-March-1998

    hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_row' , 5 ) ;
    delete_child ( p_assignment_id
                 ,p_delete_mode);

   delete from per_assignments_f a
   where  a.rowid	= chartorowid(P_ROW_ID);
--


  if ( p_delete_mode = 'ZAP' ) then
        return ;        -- This case is handled by the form at present
     hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_row' , 10 ) ;

  elsif ( p_delete_mode in ('FUTURE_CHANGE','DELETE_NEXT_CHANGE' ) ) then
	if ( p_new_end_date is null ) then
	     if ( p_validation_end_date = hr_general.end_of_time ) then
		 hr_assignment.tidy_up_ref_int ( p_assignment_id,
						 'FUTURE',
						 p_validation_end_date,
						 p_effective_end_date,
						 null,
						 null ,
						 l_cost_warning) ;
		 hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_row' , 15 ) ;
             end if;
        else
            hr_assignment.tidy_up_ref_int ( p_assignment_id,
					    'FUTURE',
					    p_new_end_date,
					    p_effective_end_date,
					    null,
					    null,
					    l_cost_warning ) ;
            hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_row' , 20 ) ;
        end if;
	--
	if ( p_new_end_date is not null ) then
	   set_end_date (  p_new_end_date  , p_assignment_id ) ;
	   hr_utility.set_location ( 'PER_APP_ASG_PKG.delete_row' , 25 ) ;
	end if;
	--
	cleanup_letters ( p_assignment_id ) ;
  else
       app_exception.invalid_argument( 'per_app_asg_pkg.delete_row',
				       'p_delete_mode',
					p_delete_mode ) ;
  end if;
--
end delete_row ;
-----------------------------------------------------------------------------
--
-- Standard lock procedure
--
procedure lock_row(
	p_row_id			   varchar2,
	p_assignment_id                    number,
	p_effective_start_date             date,
	p_effective_end_date               date,
	p_business_group_id                number,
	p_recruiter_id                     number,
	p_grade_id                         number,
	p_position_id                      number,
	p_job_id                           number,
	p_assignment_status_type_id        number,
	p_location_id                      number,
	p_person_referred_by_id            number,
	p_supervisor_id                    number,
	p_person_id                        number,
	p_recruitment_activity_id          number,
	p_source_organization_id           number,
	p_organization_id                  number,
	p_people_group_id                  number,
	p_vacancy_id                       number,
	p_assignment_sequence              number,
	p_assignment_type                  varchar2,
	p_primary_flag                     varchar2,
	p_application_id                   number,
	p_change_reason                    varchar2,
	p_comment_id                       number,
	p_date_probation_end               date,
	p_frequency                        varchar2,
	p_manager_flag                     varchar2,
	p_normal_hours                     number,
	p_probation_period                 number,
	p_probation_unit                   varchar2,
	p_source_type                      varchar2,
	p_time_normal_finish               varchar2,
	p_time_normal_start                varchar2,
	p_request_id                       number,
	p_program_application_id           number,
	p_program_id                       number,
	p_program_update_date              date,
	p_ass_attribute_category           varchar2,
	p_ass_attribute1                   varchar2,
	p_ass_attribute2                   varchar2,
	p_ass_attribute3                   varchar2,
	p_ass_attribute4                   varchar2,
	p_ass_attribute5                   varchar2,
	p_ass_attribute6                   varchar2,
	p_ass_attribute7                   varchar2,
	p_ass_attribute8                   varchar2,
	p_ass_attribute9                   varchar2,
	p_ass_attribute10                  varchar2,
	p_ass_attribute11                  varchar2,
	p_ass_attribute12                  varchar2,
	p_ass_attribute13                  varchar2,
	p_ass_attribute14                  varchar2,
	p_ass_attribute15                  varchar2,
	p_ass_attribute16                  varchar2,
	p_ass_attribute17                  varchar2,
	p_ass_attribute18                  varchar2,
	p_ass_attribute19                  varchar2,
	p_ass_attribute20                  varchar2,
	p_ass_attribute21                  varchar2,
	p_ass_attribute22                  varchar2,
	p_ass_attribute23                  varchar2,
	p_ass_attribute24                  varchar2,
	p_ass_attribute25                  varchar2,
	p_ass_attribute26                  varchar2,
	p_ass_attribute27                  varchar2,
	p_ass_attribute28                  varchar2,
	p_ass_attribute29                  varchar2,
	p_ass_attribute30                  varchar2,
	p_contract_id                      number,
	p_cagr_id_flex_num                 number,
	p_cagr_grade_def_id                number,
	p_establishment_id                 number,
	p_collective_agreement_id          number,
        p_notice_period			   number,
        p_notice_period_uom		   varchar2,
        p_employee_category		   varchar2,
        p_work_at_home			   varchar2,
        p_job_post_source_name		   varchar2,
        p_grade_ladder_pgm_id		   number,
        p_supervisor_assignment_id         number ) is

cursor ASS_CUR is
	select	*
	from	per_assignments_f a
	where	a.rowid	= chartorowid(P_ROW_ID)
	FOR	UPDATE OF ASSIGNMENT_ID NOWAIT;
--
ass_rec	ASS_CUR%rowtype;
--
begin
--
   open ASS_CUR;
--
   fetch ASS_CUR into ASS_REC;
--
   if ASS_CUR%notfound then
		close  ASS_CUR;
                fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                fnd_message.set_token('PROCEDURE',
                        'PER_APP_ASG_PKG.LOCK_ROW');
                fnd_message.set_token('STEP', '1');
                fnd_message.raise_error;
   end if;
   close ASS_CUR;
--
ass_rec.assignment_type := rtrim(ass_rec.assignment_type);
ass_rec.primary_flag := rtrim(ass_rec.primary_flag);
ass_rec.change_reason := rtrim(ass_rec.change_reason);
ass_rec.frequency := rtrim(ass_rec.frequency);
ass_rec.manager_flag := rtrim(ass_rec.manager_flag);
ass_rec.probation_unit := rtrim(ass_rec.probation_unit);
ass_rec.source_type := rtrim(ass_rec.source_type);
ass_rec.time_normal_finish := rtrim(ass_rec.time_normal_finish);
ass_rec.time_normal_start := rtrim(ass_rec.time_normal_start);
ass_rec.ass_attribute_category := rtrim(ass_rec.ass_attribute_category);
ass_rec.ass_attribute1 := rtrim(ass_rec.ass_attribute1);
ass_rec.ass_attribute2 := rtrim(ass_rec.ass_attribute2);
ass_rec.ass_attribute3 := rtrim(ass_rec.ass_attribute3);
ass_rec.ass_attribute4 := rtrim(ass_rec.ass_attribute4);
ass_rec.ass_attribute5 := rtrim(ass_rec.ass_attribute5);
ass_rec.ass_attribute6 := rtrim(ass_rec.ass_attribute6);
ass_rec.ass_attribute7 := rtrim(ass_rec.ass_attribute7);
ass_rec.ass_attribute8 := rtrim(ass_rec.ass_attribute8);
ass_rec.ass_attribute9 := rtrim(ass_rec.ass_attribute9);
ass_rec.ass_attribute10 := rtrim(ass_rec.ass_attribute10);
ass_rec.ass_attribute11 := rtrim(ass_rec.ass_attribute11);
ass_rec.ass_attribute12 := rtrim(ass_rec.ass_attribute12);
ass_rec.ass_attribute13 := rtrim(ass_rec.ass_attribute13);
ass_rec.ass_attribute14 := rtrim(ass_rec.ass_attribute14);
ass_rec.ass_attribute15 := rtrim(ass_rec.ass_attribute15);
ass_rec.ass_attribute16 := rtrim(ass_rec.ass_attribute16);
ass_rec.ass_attribute17 := rtrim(ass_rec.ass_attribute17);
ass_rec.ass_attribute18 := rtrim(ass_rec.ass_attribute18);
ass_rec.ass_attribute19 := rtrim(ass_rec.ass_attribute19);
ass_rec.ass_attribute20 := rtrim(ass_rec.ass_attribute20);
ass_rec.ass_attribute21 := rtrim(ass_rec.ass_attribute21);
ass_rec.ass_attribute22 := rtrim(ass_rec.ass_attribute22);
ass_rec.ass_attribute23 := rtrim(ass_rec.ass_attribute23);
ass_rec.ass_attribute24 := rtrim(ass_rec.ass_attribute24);
ass_rec.ass_attribute25 := rtrim(ass_rec.ass_attribute25);
ass_rec.ass_attribute26 := rtrim(ass_rec.ass_attribute26);
ass_rec.ass_attribute27 := rtrim(ass_rec.ass_attribute27);
ass_rec.ass_attribute28 := rtrim(ass_rec.ass_attribute28);
ass_rec.ass_attribute29 := rtrim(ass_rec.ass_attribute29);
ass_rec.ass_attribute30 := rtrim(ass_rec.ass_attribute30);
ass_rec.contract_id     := rtrim(ass_rec.contract_id);
ass_rec.cagr_id_flex_num  := rtrim(ass_rec.cagr_id_flex_num);
ass_rec.cagr_grade_def_id := rtrim(ass_rec.cagr_grade_def_id);
ass_rec.establishment_id  := rtrim(ass_rec.establishment_id);
ass_rec.collective_agreement_id := rtrim(ass_rec.collective_agreement_id);
ass_rec.notice_period := rtrim(ass_rec.notice_period);
ass_rec.notice_period_uom := rtrim(ass_rec.notice_period_uom);
ass_rec.employee_category := rtrim(ass_rec.employee_category);
ass_rec.work_at_home := rtrim(ass_rec.work_at_home);
ass_rec.job_post_source_name := rtrim(ass_rec.job_post_source_name);
ass_rec.grade_ladder_pgm_id := rtrim(ass_rec.grade_ladder_pgm_id);

--
if ( ((ass_rec.assignment_id = p_assignment_id)
or (ass_rec.assignment_id is null
 and (p_assignment_id is null)))
and ((ass_rec.effective_start_date = p_effective_start_date)
or (ass_rec.effective_start_date is null
 and (p_effective_start_date is null)))
and ((ass_rec.effective_end_date = p_effective_end_date)
or (ass_rec.effective_end_date is null
 and (p_effective_end_date is null)))
and ((ass_rec.notice_period = p_notice_period)
or (ass_rec.notice_period is null
 and (p_notice_period is null)))
and ((ass_rec.notice_period_uom = p_notice_period_uom)
or (ass_rec.notice_period_uom is null
 and (p_notice_period_uom is null)))
and ((ass_rec.work_at_home = p_work_at_home)
or (ass_rec.work_at_home is null
 and (p_work_at_home is null)))
and ((ass_rec.employee_category = p_employee_category)
or (ass_rec.employee_category is null
 and (p_employee_category is null)))
and ((ass_rec.job_post_source_name = p_job_post_source_name)
or (ass_rec.job_post_source_name is null
 and (p_job_post_source_name is null)))
and ((ass_rec.grade_ladder_pgm_id = p_grade_ladder_pgm_id)
or (ass_rec.grade_ladder_pgm_id is null
 and (p_grade_ladder_pgm_id is null)))
and ((ass_rec.contract_id = p_contract_id)
or (ass_rec.contract_id is null
 and (p_contract_id is null)))
and ((ass_rec.collective_agreement_id = p_collective_agreement_id)
or (ass_rec.collective_agreement_id is null
 and (p_collective_agreement_id is null)))
and ((ass_rec.establishment_id = p_establishment_id)
or (ass_rec.establishment_id is null
 and (p_establishment_id is null)))
and ((ass_rec.cagr_grade_def_id = p_cagr_grade_def_id)
or (ass_rec.cagr_grade_def_id is null
 and (p_cagr_grade_def_id is null)))
and ((ass_rec.cagr_id_flex_num = p_cagr_id_flex_num)
or (ass_rec.cagr_id_flex_num is null
 and (p_cagr_id_flex_num is null)))
and ((ass_rec.business_group_id = p_business_group_id)
or (ass_rec.business_group_id is null
 and (p_business_group_id is null)))
and ((ass_rec.recruiter_id = p_recruiter_id)
or (ass_rec.recruiter_id is null
 and (p_recruiter_id is null)))
and ((ass_rec.grade_id = p_grade_id)
or (ass_rec.grade_id is null
 and (p_grade_id is null)))
and ((ass_rec.position_id = p_position_id)
or (ass_rec.position_id is null
 and (p_position_id is null)))
and ((ass_rec.job_id = p_job_id)
or (ass_rec.job_id is null
 and (p_job_id is null)))
and ((ass_rec.assignment_status_type_id = p_assignment_status_type_id)
or (ass_rec.assignment_status_type_id is null
 and (p_assignment_status_type_id is null)))
and ((ass_rec.location_id = p_location_id)
or (ass_rec.location_id is null
 and (p_location_id is null)))
and ((ass_rec.person_referred_by_id = p_person_referred_by_id)
or (ass_rec.person_referred_by_id is null
 and (p_person_referred_by_id is null)))
and ((ass_rec.supervisor_id = p_supervisor_id)
or (ass_rec.supervisor_id is null
 and (p_supervisor_id is null)))
and ((ass_rec.person_id = p_person_id)
or (ass_rec.person_id is null
 and (p_person_id is null)))
and ((ass_rec.recruitment_activity_id = p_recruitment_activity_id)
or (ass_rec.recruitment_activity_id is null
 and (p_recruitment_activity_id is null)))
and ((ass_rec.source_organization_id = p_source_organization_id)
or (ass_rec.source_organization_id is null
 and (p_source_organization_id is null)))
and ((ass_rec.organization_id = p_organization_id)
or (ass_rec.organization_id is null
 and (p_organization_id is null)))
and ((ass_rec.people_group_id = p_people_group_id)
or (ass_rec.people_group_id is null
 and (p_people_group_id is null)))
and ((ass_rec.vacancy_id = p_vacancy_id)
or (ass_rec.vacancy_id is null
 and (p_vacancy_id is null)))
and ((ass_rec.assignment_sequence = p_assignment_sequence)
or (ass_rec.assignment_sequence is null
 and (p_assignment_sequence is null)))
and ((ass_rec.assignment_type = p_assignment_type)
or (ass_rec.assignment_type is null
 and (p_assignment_type is null)))
and ((ass_rec.primary_flag = p_primary_flag)
or (ass_rec.primary_flag is null
 and (p_primary_flag is null)))
and ((ass_rec.application_id = p_application_id)
or (ass_rec.application_id is null
 and (p_application_id is null)))
and ((ass_rec.change_reason = p_change_reason)
or (ass_rec.change_reason is null
 and (p_change_reason is null)))
and ((ass_rec.comment_id = p_comment_id)
or (ass_rec.comment_id is null
 and (p_comment_id is null)))
and ((ass_rec.date_probation_end = p_date_probation_end)
or (ass_rec.date_probation_end is null
 and (p_date_probation_end is null)))
and ((ass_rec.frequency = p_frequency)
or (ass_rec.frequency is null
 and (p_frequency is null)))
and ((ass_rec.manager_flag = p_manager_flag)
or (ass_rec.manager_flag is null
 and (p_manager_flag is null)))
and ((ass_rec.normal_hours = p_normal_hours)
or (ass_rec.normal_hours is null
 and (p_normal_hours is null)))
and ((ass_rec.probation_period = p_probation_period)
or (ass_rec.probation_period is null
 and (p_probation_period is null)))
and ((ass_rec.probation_unit = p_probation_unit)
or (ass_rec.probation_unit is null
 and (p_probation_unit is null)))
and ((ass_rec.source_type = p_source_type)
or (ass_rec.source_type is null
 and (p_source_type is null)))
and ((ass_rec.time_normal_finish = p_time_normal_finish)
or (ass_rec.time_normal_finish is null
 and (p_time_normal_finish is null)))
and ((ass_rec.time_normal_start = p_time_normal_start)
or (ass_rec.time_normal_start is null
 and (p_time_normal_start is null)))
and ((ass_rec.request_id = p_request_id)
or (ass_rec.request_id is null
 and (p_request_id is null)))
and ((ass_rec.program_application_id = p_program_application_id)
or (ass_rec.program_application_id is null
 and (p_program_application_id is null)))
and ((ass_rec.program_id = p_program_id)
or (ass_rec.program_id is null
 and (p_program_id is null)))
and ((ass_rec.program_update_date = p_program_update_date)
or (ass_rec.program_update_date is null
 and (p_program_update_date is null)))) then
if ( ((ass_rec.ass_attribute_category = p_ass_attribute_category)
	or (ass_rec.ass_attribute_category is null
	 and (p_ass_attribute_category is null)))
	and ((ass_rec.ass_attribute1 = p_ass_attribute1)
	or (ass_rec.ass_attribute1 is null
	 and (p_ass_attribute1 is null)))
	and ((ass_rec.ass_attribute2 = p_ass_attribute2)
	or (ass_rec.ass_attribute2 is null
	 and (p_ass_attribute2 is null)))
	and ((ass_rec.ass_attribute3 = p_ass_attribute3)
	or (ass_rec.ass_attribute3 is null
	 and (p_ass_attribute3 is null)))
	and ((ass_rec.ass_attribute4 = p_ass_attribute4)
	or (ass_rec.ass_attribute4 is null
	 and (p_ass_attribute4 is null)))
	and ((ass_rec.ass_attribute5 = p_ass_attribute5)
	or (ass_rec.ass_attribute5 is null
	 and (p_ass_attribute5 is null)))
	and ((ass_rec.ass_attribute6 = p_ass_attribute6)
	or (ass_rec.ass_attribute6 is null
	 and (p_ass_attribute6 is null)))
	and ((ass_rec.ass_attribute7 = p_ass_attribute7)
	or (ass_rec.ass_attribute7 is null
	 and (p_ass_attribute7 is null)))
	and ((ass_rec.ass_attribute8 = p_ass_attribute8)
	or (ass_rec.ass_attribute8 is null
	 and (p_ass_attribute8 is null)))
	and ((ass_rec.ass_attribute9 = p_ass_attribute9)
	or (ass_rec.ass_attribute9 is null
	 and (p_ass_attribute9 is null)))
	and ((ass_rec.ass_attribute10 = p_ass_attribute10)
	or (ass_rec.ass_attribute10 is null
	 and (p_ass_attribute10 is null)))
	and ((ass_rec.ass_attribute11 = p_ass_attribute11)
	or (ass_rec.ass_attribute11 is null
	 and (p_ass_attribute11 is null)))
	and ((ass_rec.ass_attribute12 = p_ass_attribute12)
	or (ass_rec.ass_attribute12 is null
	 and (p_ass_attribute12 is null)))
	and ((ass_rec.ass_attribute13 = p_ass_attribute13)
	or (ass_rec.ass_attribute13 is null
	 and (p_ass_attribute13 is null)))
	and ((ass_rec.ass_attribute14 = p_ass_attribute14)
	or (ass_rec.ass_attribute14 is null
	 and (p_ass_attribute14 is null)))
	and ((ass_rec.ass_attribute15 = p_ass_attribute15)
	or (ass_rec.ass_attribute15 is null
	 and (p_ass_attribute15 is null)))
	and ((ass_rec.ass_attribute16 = p_ass_attribute16)
	or (ass_rec.ass_attribute16 is null
	 and (p_ass_attribute16 is null)))
	and ((ass_rec.ass_attribute17 = p_ass_attribute17)
	or (ass_rec.ass_attribute17 is null
	 and (p_ass_attribute17 is null)))
	and ((ass_rec.ass_attribute18 = p_ass_attribute18)
	or (ass_rec.ass_attribute18 is null
	 and (p_ass_attribute18 is null)))
	and ((ass_rec.ass_attribute19 = p_ass_attribute19)
	or (ass_rec.ass_attribute19 is null
	 and (p_ass_attribute19 is null)))
	and ((ass_rec.ass_attribute20 = p_ass_attribute20)
	or (ass_rec.ass_attribute20 is null
	 and (p_ass_attribute20 is null)))
	and ((ass_rec.ass_attribute21 = p_ass_attribute21)
	or (ass_rec.ass_attribute21 is null
	 and (p_ass_attribute21 is null)))
	and ((ass_rec.ass_attribute22 = p_ass_attribute22)
	or (ass_rec.ass_attribute22 is null
	 and (p_ass_attribute22 is null)))
	and ((ass_rec.ass_attribute23 = p_ass_attribute23)
	or (ass_rec.ass_attribute23 is null
	 and (p_ass_attribute23 is null)))
	and ((ass_rec.ass_attribute24 = p_ass_attribute24)
	or (ass_rec.ass_attribute24 is null
	 and (p_ass_attribute24 is null)))
	and ((ass_rec.ass_attribute25 = p_ass_attribute25)
	or (ass_rec.ass_attribute25 is null
	 and (p_ass_attribute25 is null)))
	and ((ass_rec.ass_attribute26 = p_ass_attribute26)
	or (ass_rec.ass_attribute26 is null
	 and (p_ass_attribute26 is null)))
	and ((ass_rec.ass_attribute27 = p_ass_attribute27)
	or (ass_rec.ass_attribute27 is null
	 and (p_ass_attribute27 is null)))
	and ((ass_rec.ass_attribute28 = p_ass_attribute28)
	or (ass_rec.ass_attribute28 is null
	 and (p_ass_attribute28 is null)))
	and ((ass_rec.ass_attribute29 = p_ass_attribute29)
	or (ass_rec.ass_attribute29 is null
	 and (p_ass_attribute29 is null)))
	and ((ass_rec.ass_attribute30 = p_ass_attribute30)
	or (ass_rec.ass_attribute30 is null
	 and (p_ass_attribute30 is null)))
	) then
		return;	 -- Row successfully locked, no changes
	end if;
end if;
--
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
--
end lock_row  ;
-----------------------------------------------------------------------------
--
-- Standard update procedure
--
procedure update_row(
	p_row_id			   varchar2,
	p_assignment_id                    number,
	p_effective_start_date             date,
	p_effective_end_date               date,
	p_validation_start_date		   date,
	p_business_group_id                number,
	p_recruiter_id                     number,
	p_grade_id                         number,
	p_position_id                      number,
	p_job_id                           number,
	p_assignment_status_type_id        number,
	p_per_system_status	           varchar2,
	p_location_id                      number,
	p_location_code                    in out nocopy varchar2,
	p_person_referred_by_id            number,
	p_supervisor_id                    number,
	p_person_id                        number,
	p_recruitment_activity_id          number,
	p_source_organization_id           number,
	p_organization_id                  number,
	p_people_group_id                  number,
	p_vacancy_id                       number,
	p_assignment_sequence              number,
	p_assignment_type                  varchar2,
	p_primary_flag                     varchar2,
	p_application_id                   number,
	p_change_reason                    varchar2,
	p_comment_id                       number,
	p_date_probation_end               date,
	p_frequency                        varchar2,
	p_frequency_meaning                in out nocopy varchar2,
	p_manager_flag                     varchar2,
	p_normal_hours                     number,
	p_probation_period                 number,
	p_probation_unit                   varchar2,
	p_source_type                      varchar2,
	p_time_normal_finish               varchar2,
	p_time_normal_start                varchar2,
	p_request_id                       number,
	p_program_application_id           number,
	p_program_id                       number,
	p_program_update_date              date,
	p_ass_attribute_category           varchar2,
	p_ass_attribute1                   varchar2,
 	p_ass_attribute2                   varchar2,
	p_ass_attribute3                   varchar2,
	p_ass_attribute4                   varchar2,
	p_ass_attribute5                   varchar2,
	p_ass_attribute6                   varchar2,
	p_ass_attribute7                   varchar2,
	p_ass_attribute8                   varchar2,
	p_ass_attribute9                   varchar2,
	p_ass_attribute10                  varchar2,
	p_ass_attribute11                  varchar2,
	p_ass_attribute12                  varchar2,
	p_ass_attribute13                  varchar2,
	p_ass_attribute14                  varchar2,
	p_ass_attribute15                  varchar2,
	p_ass_attribute16                  varchar2,
	p_ass_attribute17                  varchar2,
	p_ass_attribute18                  varchar2,
	p_ass_attribute19                  varchar2,
	p_ass_attribute20                  varchar2,
	p_ass_attribute21                  varchar2,
	p_ass_attribute22                  varchar2,
	p_ass_attribute23                  varchar2,
	p_ass_attribute24                  varchar2,
	p_ass_attribute25                  varchar2,
	p_ass_attribute26                  varchar2,
	p_ass_attribute27                  varchar2,
	p_ass_attribute28                  varchar2,
	p_ass_attribute29                  varchar2,
	p_ass_attribute30                  varchar2,
	p_session_date		           date,
	p_status_changed		   boolean,
	p_contract_id                      number default null,
	p_cagr_id_flex_num                 number default null,
	p_cagr_grade_def_id                number default null,
	p_establishment_id                 number default null,
	p_collective_agreement_id          number default null,
        p_notice_period			   number   default null,
        p_notice_period_uom		   varchar2 default null,
        p_employee_category		   varchar2 default null,
        p_work_at_home			   varchar2 default null,
        p_job_post_source_name		   varchar2 default null,
        p_grade_ladder_pgm_id		   number default null,
        p_supervisor_assignment_id         number   default null,
        p_payroll_id                       number   default null,  --Bug 4861490
	p_pay_basis_id			   number   default null   --Bug 4861490
) is

  l_cost_warning boolean; -- used to catch the cost warning from tidy_up_ref_int
                          -- but as Apl asg's can't have costing records no need
			  -- to return to caller.
l_previous_asg_status number; -- used to check if asg status changed
l_assignment_status_id number; -- discards output from irc_asg_status api
l_object_version_number number; -- ditto
l_previous_vacancy_id number; -- Added for bug 3680947.
-- Start of fix 3634447
-- Cursor to get the current organization
cursor current_org is
       select paf.organization_id
       from   per_all_assignments_f paf
       where  assignment_id = p_assignment_id
       and    p_effective_start_date between effective_start_date
       and    effective_end_date;
--
l_old_org_id  per_all_assignments_f.organization_id%Type;
--
-- End of fix 3634447
begin
--
--  PRE-UPDATE-CHECKS
--
   hr_utility.set_location('Entering : per_app_asg_pkg.update_row' ,10);
   hr_utility.trace('p_grade_ladder_pgm_id : ' || p_grade_ladder_pgm_id);
   /* TEMP MOVED TO CLIENT FOR DEVELOPMENT
   check_current_applicant ( p_person_id => p_person_id,
			     p_session_date => p_session_date ) ;
   */
--
select assignment_status_type_id, vacancy_id
into l_previous_asg_status, l_previous_vacancy_id
from per_assignments_f where rowid = chartorowid(P_ROW_ID);

-- Start of OAB code addition
-- Whenever Applicant Information is getting changed/inserted via Applicant forms
-- we need to trigger OAB Lifeevents. The following ben call will trigger LE
-- Bug 3506363

   hr_utility.set_location ( 'PER_APP_ASG_PKG.update_row' , 11 ) ;
   hr_utility.set_location ( 'Before OAB Call' , 11 ) ;
   ben_dt_trgr_handle.assignment
            (p_rowid                   => p_row_id
            ,p_assignment_id           => p_assignment_id
            ,p_business_group_id       => p_business_group_id
	    ,p_person_id               => p_person_id
	    ,p_effective_start_date    => p_effective_start_date
	    ,p_effective_end_date      => p_effective_end_date
	    ,p_assignment_status_type_id  => p_assignment_status_type_id
	    ,p_assignment_type         => p_assignment_type
	    ,p_organization_id         => p_organization_id
	    ,p_primary_flag            => p_primary_flag
	    ,p_change_reason           => p_change_reason
	    ,p_employment_category     => null
	    ,p_frequency               => p_frequency
	    ,p_grade_id                => p_grade_id
	    ,p_job_id                  => p_job_id
	    ,p_position_id             => p_position_id
	    ,p_location_id             => p_location_id
	    ,p_normal_hours            => p_normal_hours
	    ,p_payroll_id              => p_payroll_id   --Bug 4861490
	    ,p_pay_basis_id            => p_pay_basis_id -- Bug 4861490
	    ,p_bargaining_unit_code    => null
	    ,p_labour_union_member_flag => null
            ,p_hourly_salaried_code    => null
            ,p_people_group_id    => p_people_group_id
	    ,p_ass_attribute1 => p_ass_attribute1
	    ,p_ass_attribute2 => p_ass_attribute2
	    ,p_ass_attribute3 => p_ass_attribute3
	    ,p_ass_attribute4 => p_ass_attribute4
	    ,p_ass_attribute5 => p_ass_attribute5
	    ,p_ass_attribute6 => p_ass_attribute6
	    ,p_ass_attribute7 => p_ass_attribute7
	    ,p_ass_attribute8 => p_ass_attribute8
	    ,p_ass_attribute9 => p_ass_attribute9
	    ,p_ass_attribute10 => p_ass_attribute10
	    ,p_ass_attribute11 => p_ass_attribute11
	    ,p_ass_attribute12 => p_ass_attribute12
	    ,p_ass_attribute13 => p_ass_attribute13
	    ,p_ass_attribute14 => p_ass_attribute14
	    ,p_ass_attribute15 => p_ass_attribute15
	    ,p_ass_attribute16 => p_ass_attribute16
	    ,p_ass_attribute17 => p_ass_attribute17
	    ,p_ass_attribute18 => p_ass_attribute18
	    ,p_ass_attribute19 => p_ass_attribute19
	    ,p_ass_attribute20 => p_ass_attribute20
	    ,p_ass_attribute21 => p_ass_attribute21
	    ,p_ass_attribute22 => p_ass_attribute22
	    ,p_ass_attribute23 => p_ass_attribute23
	    ,p_ass_attribute24 => p_ass_attribute24
	    ,p_ass_attribute25 => p_ass_attribute25
	    ,p_ass_attribute26 => p_ass_attribute26
	    ,p_ass_attribute27 => p_ass_attribute27
	    ,p_ass_attribute28 => p_ass_attribute28
	    ,p_ass_attribute29 => p_ass_attribute29
	    ,p_ass_attribute30 => p_ass_attribute30
            );

   hr_utility.set_location ( 'After OAB Call' , 11 ) ;

-- Bug 3506363
-- end of OAB Code change
   update per_assignments_f a
   set	a.assignment_id = P_ASSIGNMENT_ID,
	a.effective_start_date = P_EFFECTIVE_START_DATE,
	a.effective_end_date = P_EFFECTIVE_END_DATE,
	a.business_group_id = P_BUSINESS_GROUP_ID,
	a.recruiter_id = P_RECRUITER_ID,
	a.grade_id = P_GRADE_ID,
	a.position_id = P_POSITION_ID,
	a.job_id = P_JOB_ID,
	a.assignment_status_type_id = P_ASSIGNMENT_STATUS_TYPE_ID,
	a.location_id = P_LOCATION_ID,
	a.person_referred_by_id = P_PERSON_REFERRED_BY_ID,
	a.supervisor_id = P_SUPERVISOR_ID,
	a.person_id = P_PERSON_ID,
	a.recruitment_activity_id = P_RECRUITMENT_ACTIVITY_ID,
	a.source_organization_id = P_SOURCE_ORGANIZATION_ID,
	a.organization_id = P_ORGANIZATION_ID,
	a.people_group_id = P_PEOPLE_GROUP_ID,
	a.vacancy_id = P_VACANCY_ID,
	a.assignment_sequence = P_ASSIGNMENT_SEQUENCE,
	a.assignment_type = P_ASSIGNMENT_TYPE,
	a.primary_flag = P_PRIMARY_FLAG,
	a.application_id = P_APPLICATION_ID,
	a.change_reason = P_CHANGE_REASON,
	a.comment_id = P_COMMENT_ID,
	a.date_probation_end = P_DATE_PROBATION_END,
	a.frequency = P_FREQUENCY,
	a.manager_flag = P_MANAGER_FLAG,
	a.normal_hours = P_NORMAL_HOURS,
	a.probation_period = P_PROBATION_PERIOD,
	a.probation_unit = P_PROBATION_UNIT,
	a.source_type = P_SOURCE_TYPE,
	a.time_normal_finish = P_TIME_NORMAL_FINISH,
	a.time_normal_start = P_TIME_NORMAL_START,
	a.request_id = P_REQUEST_ID,
	a.program_application_id = P_PROGRAM_APPLICATION_ID,
	a.program_id = P_PROGRAM_ID,
	a.program_update_date = P_PROGRAM_UPDATE_DATE,
	a.ass_attribute_category = P_ASS_ATTRIBUTE_CATEGORY,
	a.ass_attribute1 = P_ASS_ATTRIBUTE1,
	a.ass_attribute2 = P_ASS_ATTRIBUTE2,
	a.ass_attribute3 = P_ASS_ATTRIBUTE3,
	a.ass_attribute4 = P_ASS_ATTRIBUTE4,
	a.ass_attribute5 = P_ASS_ATTRIBUTE5,
	a.ass_attribute6 = P_ASS_ATTRIBUTE6,
	a.ass_attribute7 = P_ASS_ATTRIBUTE7,
	a.ass_attribute8 = P_ASS_ATTRIBUTE8,
	a.ass_attribute9 = P_ASS_ATTRIBUTE9,
	a.ass_attribute10 = P_ASS_ATTRIBUTE10,
	a.ass_attribute11 = P_ASS_ATTRIBUTE11,
	a.ass_attribute12 = P_ASS_ATTRIBUTE12,
	a.ass_attribute13 = P_ASS_ATTRIBUTE13,
	a.ass_attribute14 = P_ASS_ATTRIBUTE14,
	a.ass_attribute15 = P_ASS_ATTRIBUTE15,
	a.ass_attribute16 = P_ASS_ATTRIBUTE16,
	a.ass_attribute17 = P_ASS_ATTRIBUTE17,
	a.ass_attribute18 = P_ASS_ATTRIBUTE18,
	a.ass_attribute19 = P_ASS_ATTRIBUTE19,
	a.ass_attribute20 = P_ASS_ATTRIBUTE20,
	a.ass_attribute21 = P_ASS_ATTRIBUTE21,
	a.ass_attribute22 = P_ASS_ATTRIBUTE22,
	a.ass_attribute23 = P_ASS_ATTRIBUTE23,
	a.ass_attribute24 = P_ASS_ATTRIBUTE24,
	a.ass_attribute25 = P_ASS_ATTRIBUTE25,
	a.ass_attribute26 = P_ASS_ATTRIBUTE26,
	a.ass_attribute27 = P_ASS_ATTRIBUTE27,
	a.ass_attribute28 = P_ASS_ATTRIBUTE28,
	a.ass_attribute29 = P_ASS_ATTRIBUTE29,
	a.ass_attribute30 = P_ASS_ATTRIBUTE30,
	a.collective_agreement_id = P_COLLECTIVE_AGREEMENT_ID,
	a.cagr_grade_def_id       = P_CAGR_GRADE_DEF_ID,
	a.establishment_id        = P_ESTABLISHMENT_ID,
	a.contract_id             = P_CONTRACT_ID,
	a.cagr_id_flex_num        = P_CAGR_ID_FLEX_NUM,
	a.notice_period		  = P_NOTICE_PERIOD,
        a.notice_period_uom       = P_NOTICE_PERIOD_UOM,
        a.work_at_home		  = P_WORK_AT_HOME,
        a.employee_category	  = P_EMPLOYEE_CATEGORY,
        a.job_post_source_name    = P_JOB_POST_SOURCE_NAME,
        a.grade_ladder_pgm_id     = p_grade_ladder_pgm_id,
        a.supervisor_assignment_id = p_supervisor_assignment_id,
        a.payroll_id     = p_payroll_id,      --Bug 4861490
        a.pay_basis_id   = p_pay_basis_id     --Bug 4861490
   where a.rowid = chartorowid(P_ROW_ID);

-- Start of fix 3634447
-- Get the current organization
open current_org;
fetch current_org into l_old_org_id;
close current_org;
-- Updating security permission when organization is changed
-- from business group to other organization.
if l_old_org_id = p_business_group_id and
   p_organization_id <> p_business_group_id then
    --
    hr_utility.set_location ('per_app_asg_pkg.update_row', 12);
    hr_security_internal.clear_from_person_list(
                         p_person_id => p_person_id);
    --
 end if;
 hr_utility.set_location ('per_app_asg_pkg.update_row', 13);
 hr_security_internal.add_to_person_list(
                      p_effective_date => p_effective_start_date,
 		      p_assignment_id  => p_assignment_id);
 hr_utility.set_location ('per_app_asg_pkg.update_row', 14);
-- End of fix 3634447

-- insert into irc_assignment_statuses if the assignment status has changed
--
if l_previous_asg_status <> p_assignment_status_type_id then
  --
  -- 3652025: if terminated, client already performed this step
  -- when calling terminate_apl_asg API.
  --
  if p_per_system_status <>  'TERM_APL' then
     IRC_ASG_STATUS_API.create_irc_asg_status
            ( p_validate                   => FALSE
            , p_assignment_id              => p_assignment_id
            , p_assignment_status_type_id  => p_assignment_status_type_id
            , p_status_change_date         => p_effective_start_date -- 2754362 p_effective_end_date
            , p_status_change_reason       => p_change_reason
 	    , p_assignment_status_id       => l_assignment_status_id
            , p_object_version_number      => l_object_version_number
             );
  end if;
end if;
--
-- Fix for bug 3680947 starts here.
--
IF ( p_status_changed ) or ( p_per_system_status = 'TERM_APL' )
   OR nvl(l_previous_vacancy_id,-1) <> nvl(p_vacancy_id,-1)
  THEN
  --
  IF nvl(l_previous_vacancy_id,-1) <> nvl(p_vacancy_id,-1) THEN
    --
    delete from per_letter_request_lines plrl
    where plrl.assignment_id = p_assignment_id
    and   plrl.assignment_status_type_id = p_assignment_status_type_id
    and   exists
         (select null
          from per_letter_requests plr
          where plr.letter_request_id = plrl.letter_request_id
          and   plr.request_status = 'PENDING'
          and   plr.auto_or_manual = 'AUTO');
    --
  END IF;
  --
  cleanup_letters( p_assignment_id => p_assignment_id);
  --
  --Performance Fix done by removing +0
  delete from per_letter_requests plr
    where  plr.business_group_id = p_business_group_id
    and    plr.request_status        = 'PENDING'
    and    plr.auto_or_manual        = 'AUTO'
    and not exists
     ( select 1
	   from   per_letter_request_lines plrl
	   where  plrl.letter_request_id = plr.letter_request_id
      ) ;
  --
  per_applicant_pkg.check_for_letter_requests
    (p_business_group_id            => p_business_group_id
    ,p_per_system_status            => p_per_system_status
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_person_id                    => p_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_validation_start_date        => p_validation_start_date
    ,p_vacancy_id 		            => p_vacancy_id
    );
   --
 END IF;
--
-- Fix for bug 3680947 ends here.
--
-- Set the location code if the location id is not null and the code is
-- null
  if ( ( p_location_id is not null ) and ( p_location_code is null ) ) then
     p_location_code := per_applicant_pkg.get_location_code ( p_location_id ) ;
  end if;
--
-- Set the frequency meaning if the frequency is not null and the meaning is
-- null
  if ( ( p_frequency is not null ) and ( p_frequency_meaning is null ) ) then
     p_frequency_meaning := hr_general.decode_lookup( 'FREQUENCY',
						      p_frequency ) ;
  end if;
--
--
  if ( p_per_system_status = 'TERM_APL' ) then
     hr_assignment.tidy_up_ref_int ( p_assignment_id ,
				     'END',
				     p_session_date,
				     p_session_date,
				     null,
				     null,
				     l_cost_warning ) ;
  end if;

--

  hr_utility.set_location(' Leaving : per_app_asg_pkg.update_row' ,100);
--
end update_row;
--
-------------------------------------------------------------------------
---                 Validation Procedures			    ----
-------------------------------------------------------------------------
procedure check_apl_update_allowed( p_application_id in number,
                                    p_assignment_id  in number,
                                    p_person_id      in number,
                                    p_status         out nocopy varchar2 ) is

  cursor get_max_apl_date is
    select max(effective_end_date)
      from per_assignments_f paf,
           per_assignment_status_types past
     where paf.application_id = p_application_id
       and paf.assignment_id = p_assignment_id
       and paf.assignment_type = 'A'
       and paf.assignment_status_type_id = past.assignment_status_type_id
       and past.per_system_status in ('ACTIVE_APL','ACCEPTED',
                           'INTERVIEW1','INTERVIEW2','OFFER');

  max_apl_date  date;

begin

  p_status := 'UNKNOWN';

  open get_max_apl_date;
  fetch get_max_apl_date into max_apl_date;
  if get_max_apl_date%notfound then
    close get_max_apl_date;
    hr_utility.set_message(800,'HR_52377_NOT_ACTIVE_APPLICANT');
    hr_utility.raise_error;
  end if;
  close get_max_apl_date;

  if max_apl_date = hr_general.end_of_time
    then
        p_status := 'UPD_OR_CORR';
    elsif hr_general2.is_person_type(p_person_id,
                                     'EMP',
                                     max_apl_date + 1)
         then
           p_status := 'CORR_ONLY';
    else
      --
      -- Fix for bug 3306906 starts here.
      -- Pass p_status as CORR_ONLY for the terminated application.
      --
      p_status := 'CORR_ONLY';
      --hr_utility.set_message(800,'HR_52377_NOT_ACTIVE_APPLICANT');
      --hr_utility.raise_error;
      --
      -- Fix for bug 3306906 ends here.
      --
  end if;

end check_apl_update_allowed;
--
procedure check_apl_end_date ( p_application_id in number ) is
l_dummy number ;
cursor c1 is
   select 1
   from   per_applications a
   where  a.application_id = p_application_id
   and    a.date_end is null ;
begin
--
  open c1 ;
  fetch c1 into l_dummy ;
  if c1%notfound then
	close c1 ;
	hr_utility.set_message(800,'HR_52377_NOT_ACTIVE_APPLICANT');
	hr_utility.raise_error ;
  end if;
  close c1 ;
--
end check_apl_end_date ;
--
procedure check_current_applicant ( p_person_id    in number,
				    p_session_date in date ) is
l_dummy number ;
cursor c1 is
  select 1
  from   per_people_f
  where  person_id  = p_person_id
  and    current_applicant_flag = 'Y'
  and    p_session_date
         between effective_start_date and effective_end_date ;
begin
--
   open c1 ;
   fetch c1 into l_dummy ;
   if c1%notfound then
       close c1 ;
       hr_utility.set_message(801,'HR_6067_APP_ASS_APPL_ENDED');
       hr_utility.raise_error ;
  end if;
  close c1 ;
--
end check_current_applicant ;
--
procedure check_valid_asg_status ( p_business_group_id         in number,
				   p_legislation_code          in varchar2,
				   p_assignment_status_type_id in number,
				   p_per_system_status         in varchar2 ) is
l_dummy number ;
cursor c1 is
select 1
from   per_assignment_status_types a
,      per_ass_status_type_amends b
where  b.assignment_status_type_id(+)    = a.assignment_status_type_id
and    b.business_group_id(+) + 0            = p_business_group_id
and    nvl(a.business_group_id,p_business_group_id) = p_business_group_id
and    nvl(a.legislation_code,p_legislation_code)   = p_legislation_code
and    nvl(b.active_flag,a.active_flag)  = 'Y'
and    nvl(b.per_system_status,a.per_system_status) = p_per_system_status
and    a.assignment_status_type_id       = p_assignment_status_type_id ;
begin
--
   open c1 ;
   fetch c1 into l_dummy ;
   if c1%notfound then
	close c1 ;
	-- ***TEMP hr_utility.set_message gives up with a value error
	-- for this message
	fnd_message.set_name('PAY','HR_6073_APP_ASS_INVALID_STATUS' );
	app_exception.raise_exception ;
   end if;
   close c1 ;
--
end check_valid_asg_status ;
--
procedure check_future_stat_change ( p_assignment_id in number ) is
l_dummy number ;
cursor c1 is
   select 1
   from per_assignments_f a
   where assignment_id = p_assignment_id
   and exists
        (select null
         from   per_assignment_status_types b
         where  b.per_system_status in ('TERM_APL','ACTIVE_ASSIGN')
         and    a.assignment_status_type_id = b.assignment_status_type_id) ;
begin
--
  open c1 ;
  fetch c1 into l_dummy ;
  if c1%found then
     close c1 ;
     fnd_message.set_name ( 'PAY', 'HR_6083_APP_ASS_APPL_STAT_END' );
     app_exception.raise_exception ;
  end if;
  close c1 ;
--
end check_future_stat_change ;
--
procedure check_end_date ( p_assignment_id in  number ,
			   p_warning_set   out nocopy boolean ) is
l_dummy_date date := NULL  ;
cursor c1 is
  select max(effective_end_date)
  from   per_assignments_f
  where  assignment_id = p_assignment_id ;
begin
--
  open c1 ;
  fetch c1 into l_dummy_date ;
  close c1 ;
  if ( l_dummy_date < hr_general.end_of_time ) then
     hr_utility.set_message ( 801 , 'HR_ASS_FUTURE_END' ) ;
     hr_utility.set_warning ;
     p_warning_set := true ;
  else
     p_warning_set := false ;
  end if;
--
end check_end_date ;
--
procedure check_assignment_continuity ( p_business_group_id in number,
					p_assignment_id     in number,
					p_person_id	    in number,
					p_max_end_date      in date,
					p_session_date	    in date   ) is
l_dummy 	  number ;
l_target_end_date date   := null ;
l_max_end_date    date   := p_max_end_date ;
--
cursor c1 is
  select 1
  from   sys.dual
  where  exists ( select 1
  		  from   per_assignments_f
  		  where  assignment_id <> p_assignment_id ) ;
--
cursor c2 is
  select nvl(a.date_end,to_date('31/12/4712','DD/MM/YYYY'))
  from   per_applications a
  where  a.person_id = p_person_id
  and    p_session_date
	 between a.date_received
	 and     nvl(a.date_end,p_session_date)
  and    a.business_group_id + 0 = p_business_group_id ;
--
cursor c3 is
  select  max(a.effective_end_date)
  from    per_all_assignments_f a
  where   a.person_id = p_person_id
  and     a.business_group_id + 0 = p_business_group_id
  and     a.assignment_id  <> p_assignment_id
  and     a.assignment_type = 'A'
  and     l_max_end_date + 1
                between a.effective_start_date
                and     a.effective_end_date ;
begin
--
   -- Check that there is at least one other assignment for this person
   open c1 ;
   fetch c1 into l_dummy ;
   if c1%notfound then
      close c1 ;
      hr_utility.set_message(801,'HR_7075_APL_ASS_ONLY_ASS' ) ;
      hr_utility.raise_error ;
   end if;
   close c1 ;
--
  -- Get the end date of the given application
  open c2 ;
  fetch c2 into l_target_end_date ;
  if c2%notfound then
     close c2 ;
     hr_utility.set_message(801,'HR_6078_ALL_ZONE_TRIGGER_FAIL');
     hr_utility.set_message_token('TRIGGER' , 'check_assignment_continuity' );
     hr_utility.raise_error ;
  end if;
  close c2 ;
--
--
   loop
     --
     exit when l_target_end_date = l_max_end_date  ;
     --
     open c3 ;
     fetch c3 into l_max_end_date ;
     close c3 ;
     --
     if ( l_max_end_date is null ) then
	hr_utility.set_message(801,'HR_6069_APP_ASS_NO_CONTIN');
	hr_utility.raise_error ;
     end if ;
   --
   end loop ;
--
end check_assignment_continuity ;
--
--
procedure process_end_status ( p_business_group_id in number,
			       p_assignment_id     in number,
			       p_person_id	   in number,
			       p_max_end_date      in date,
			       p_session_date	   in date,
                               p_application_id    in number) is
--
  l_exists varchar2(10);
  --
  cursor csr_hire_exists(cp_asg_id number, cp_effective_date date) is
     select 'Y' from per_all_assignments_f
      where assignment_id = cp_asg_id
        and assignment_type = 'E'
        and effective_start_date > cp_effective_date;
  --
  cursor csr_other_asgs(cp_asg_id number, cp_appl_id number) is
     select 'Y' from per_assignments_f apl
       where apl.assignment_type = 'A'
         and apl.application_id = cp_appl_id
         and apl.assignment_id <> cp_asg_id
         and (apl.effective_end_date = hr_general.end_of_time
              or exists
              (select 'Y' from per_applications apa
                where apa.application_id = cp_appl_id
                  and apa.date_end is not null
                  and apa.date_end >= apl.effective_end_date));

begin
--
-- check_assignment_continuity ( p_business_group_id,  -- 3652025
--		 p_assignment_id,
--		 p_person_id,
--		 p_max_end_date,
--		 p_session_date ) ;
--
--
   --
   -- check whether this assignment has been hired into EMP
   --
   l_exists := 'N';
   open csr_hire_exists(p_assignment_id, p_session_date+1);
   fetch csr_hire_exists into l_exists;
   if csr_hire_exists%FOUND then
     close csr_hire_exists;
     hr_utility.set_message(800,'HR_6071_APP_ASS_INVALID_END');
     hr_utility.raise_error;
   else
     close csr_hire_exists;
   end if;
   --
   -- check whether there are other assignments
   --
   open csr_other_asgs(p_assignment_id, p_application_id);
   fetch csr_other_asgs into l_exists;
   if csr_other_asgs%NOTFOUND then
     close csr_other_asgs;
     hr_utility.set_message(800,'HR_7075_APL_ASS_ONLY_ASS');
     hr_utility.raise_error;
   else
     close csr_other_asgs;
   end if;
   --
   hr_assignment.del_ref_int_check ( p_assignment_id,
				     'END',
				     p_session_date ) ;
--
end process_end_status ;
--
--
-- ***temp OBSOLETE ?
function rec_act_has_source_type ( p_recruitment_activity_id in number,
				   p_source_type             in varchar2 )
				   return boolean is
begin
  return true ;
end ;
--
procedure key_delrec ( p_business_group_id     in number,
		       p_assignment_id         in number,
		       p_person_id	       in number,
		       p_session_date	       in date,
		       p_validation_start_date in date,
		       p_delete_mode           in varchar2 ) is
l_max_end_date date ;
cursor c1 is
  select min(effective_start_date)-1
  from   per_assignments_f
  where  assignment_id = p_assignment_id ;
begin
--
   if ( p_delete_mode in ( 'FUTURE_CHANGE' , 'DELETE_NEXT_CHANGE' ) ) then
   --
      check_future_stat_change( p_assignment_id => p_assignment_id ) ;
   --
   elsif ( p_delete_mode = 'ZAP' ) then
   --
      check_future_stat_change( p_assignment_id => p_assignment_id ) ;
      open c1 ;
      fetch c1 into l_max_end_date ;
      close c1 ;
      --
      check_assignment_continuity ( p_business_group_id,
 				    p_assignment_id,
				    p_person_id,
				    l_max_end_date,
				    p_session_date ) ;
      --
      hr_assignment.del_ref_int_check ( p_assignment_id,
				        'ZAP',
				        p_validation_start_date ) ;
      --
   else  app_exception.invalid_argument( 'PER_APP_ASG_PKG.KEY_DELREC',
	                                 'p_delete_mode',
					  p_delete_mode ) ;
   end if;
--
end key_delrec ;
--
procedure pre_delete_validation ( p_business_group_id     in number,
		                  p_assignment_id         in number,
		                  p_application_id        in number,
		                  p_person_id	          in number,
		                  p_session_date	  in date,
		                  p_validation_start_date in date,
		                  p_validation_end_date   in date,
		                  p_delete_mode           in varchar2,
				  p_new_end_date	  in out nocopy date ) is
l_max_end_date date ;
cursor c1 is
  select min(effective_start_date)-1
  from   per_assignments_f
  where  assignment_id = p_assignment_id ;
--
procedure check_appl_term ( p_application_id      in number,
			    p_validation_end_date in date ,
			    p_new_end_date        in out nocopy date ) is
cursor c1 is
  select date_end
  from   per_applications
  where  application_id = p_application_id
  and    nvl(date_end,to_date('31/12/4712','DD/MM/YYYY'))
	 < p_validation_end_date ;
begin
--
   open c1 ;
   fetch c1 into p_new_end_date ;
   close c1 ;
end check_appl_term ;
--
begin
--
   if ( p_delete_mode in ( 'FUTURE_CHANGE' , 'DELETE_NEXT_CHANGE' ) ) then
   --
      check_future_stat_change( p_assignment_id => p_assignment_id ) ;
      check_appl_term ( p_application_id        => p_application_id,
			p_validation_end_date   => p_validation_end_date,
			p_new_end_date          => p_new_end_date ) ;
   --
   elsif ( p_delete_mode = 'ZAP' ) then
   --
      check_future_stat_change( p_assignment_id => p_assignment_id ) ;
      open c1 ;
      fetch c1 into l_max_end_date ;
      close c1 ;
      --
      check_assignment_continuity ( p_business_group_id,
 				    p_assignment_id,
				    p_person_id,
				    l_max_end_date,
				    p_session_date ) ;
      --
      hr_assignment.del_ref_int_check ( p_assignment_id,
				        'ZAP',
				        p_validation_start_date ) ;
      --
   else  app_exception.invalid_argument( 'PER_APP_ASG_PKG.PRE_DELETE_VALIDATION',
	                                 'p_delete_mode',
					  p_delete_mode ) ;
   end if;
--
end pre_delete_validation ;
--
--
procedure post_delete ( p_assignment_id 	in number,
			p_validation_start_date in date ) is

l_out_parameter	boolean; -- Out parmater used to warn is future changes to the spinal
			 -- point placements will be lost, as assignment this will
			 -- not be used only catched locally.
begin
--
   hr_assignment.del_ref_int_delete ( p_assignment_id,
				      NULL,
				      'ZAP',
				      p_validation_start_date,
				      null,
				      null,
				      null,
				      null,
				      null,
			  	      null,
				      l_out_parameter
				       ) ;

   cleanup_letters ( p_assignment_id ) ;
--
end post_delete ;
--
--
procedure chk_upd_mode ( p_event varchar2,
                           p_object varchar2,
			   p_assignment_id number,
			   p_effective_start_date date,
			   p_update_mode varchar2,
			   p_record_status varchar2,
			   p_per_system_status varchar2,
			   p_allowed out nocopy varchar2 ) IS
   --
   l_dummy varchar2(1) := 'N';
   cursor csr_chk_mode is
      select 'Y' from per_all_assignments_f a
      where p_assignment_id = a.assignment_id
      and (a.effective_start_date < p_effective_start_date);
   --
begin
   if p_object = 'ASSGT' then
	open csr_chk_mode;
	fetch csr_chk_mode into l_dummy;
	if p_event = 'WHEN-VALIDATE-ITEM'
	and ( p_update_mode = 'UPDATE' or p_update_mode is null OR l_dummy = 'Y' ) then
	   --
	   p_allowed := 'STATUSES_UPDATE';
	   --
	elsif p_event = 'WHEN-NEW-RECORD-INSTANCE'
	and p_record_status in ( 'QUERY' , 'CHANGED' )
	and (l_dummy = 'Y' or p_update_mode = 'UPDATE'or p_update_mode is null) then
	   --
	   p_allowed := 'STATUSES_UPDATE';
	   --
	else
	   --
	   p_allowed := 'STATUSES_INSERT';
	   --
	end if;
	close csr_chk_mode;
	l_dummy := 'N';
   elsif ( p_event = 'WHEN-VALIDATE-ITEM' and p_object = 'STATUS' and p_per_system_status = 'TERM_APL') then
	open csr_chk_mode;
	fetch csr_chk_mode into l_dummy;
	if p_update_mode = 'CORRECTION' and l_dummy <> 'Y' then
	   p_allowed := 'STATUSES_INSERT';
           -- 3652025: allow termination on the same day
          -- hr_utility.set_message(801,'HR_6006_APP_ASS_INVL_FIRST_STA' );
          -- hr_utility.raise_error ;
	else
	   p_allowed := 'STATUSES_UPDATE';
	end if;
	close csr_chk_mode;
	l_dummy := 'N';

   end if;
end chk_upd_mode;





--
end PER_APP_ASG_PKG ;

/
