--------------------------------------------------------
--  DDL for Package Body HR_CANCEL_HIRE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CANCEL_HIRE_API" as
/* $Header: pecahapi.pkb 120.4.12010000.4 2008/10/01 10:44:02 ghshanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_cancel_hire_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< cancel_hire (overloaded >---------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_hire
  (p_validate            IN     BOOLEAN  DEFAULT FALSE
  ,p_person_id           IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_supervisor_warning     OUT NOCOPY BOOLEAN
  ,p_recruiter_warning      OUT NOCOPY BOOLEAN
  ,p_event_warning          OUT NOCOPY BOOLEAN
  ,p_interview_warning      OUT NOCOPY BOOLEAN
  ,p_review_warning         OUT NOCOPY BOOLEAN
  ,p_vacancy_warning        OUT NOCOPY BOOLEAN
  ,p_requisition_warning    OUT NOCOPY BOOLEAN
  ,p_budget_warning         OUT NOCOPY BOOLEAN
  ,p_payment_warning        OUT NOCOPY BOOLEAN
    ) is

  l_pay_proposal_warning boolean :=FALSE;

  begin

  cancel_hire
  (p_validate               =>p_validate
  ,p_person_id              =>p_person_id
  ,p_effective_date         =>p_effective_date
  ,p_supervisor_warning     =>p_supervisor_warning
  ,p_recruiter_warning      =>p_recruiter_warning
  ,p_event_warning          =>p_event_warning
  ,p_interview_warning      =>p_interview_warning
  ,p_review_warning         =>p_review_warning
  ,p_vacancy_warning        =>p_vacancy_warning
  ,p_requisition_warning    =>p_requisition_warning
  ,p_budget_warning         =>p_budget_warning
  ,p_payment_warning        =>p_payment_warning
  ,p_pay_proposal_warning  => l_pay_proposal_warning );

  end ;

-- -----------------------------------------------------------------------------
-- |--------------------------< cancel_hire >-----------------------------------|
-- ------------------------------------------------------------------------------
procedure cancel_hire
  (p_validate            IN     BOOLEAN  DEFAULT FALSE
  ,p_person_id           IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_supervisor_warning     OUT NOCOPY BOOLEAN
  ,p_recruiter_warning      OUT NOCOPY BOOLEAN
  ,p_event_warning          OUT NOCOPY BOOLEAN
  ,p_interview_warning      OUT NOCOPY BOOLEAN
  ,p_review_warning         OUT NOCOPY BOOLEAN
  ,p_vacancy_warning        OUT NOCOPY BOOLEAN
  ,p_requisition_warning    OUT NOCOPY BOOLEAN
  ,p_budget_warning         OUT NOCOPY BOOLEAN
  ,p_payment_warning        OUT NOCOPY BOOLEAN
   ,p_pay_proposal_warning out nocopy boolean ) is
  --
  -- Declare cursors and local variables
  --

  --
  -- Fetches various person details to call the existing code.
  --
  CURSOR csr_get_per_details IS
  SELECT DISTINCT
         paa.business_group_id
        ,pos.period_of_service_id
        ,pos.date_start
  FROM   per_periods_of_service pos
        ,per_all_assignments_f paa
  WHERE  paa.person_id = p_person_id
  AND    p_effective_date BETWEEN
         paa.effective_start_date AND paa.effective_end_date
  AND    paa.person_id = pos.person_id
--
-- 115.3 (START)
--
  AND    pos.date_start IN
         (SELECT MAX(pos2.date_start)
          FROM   per_periods_of_service pos2
          WHERE  pos2.person_id = p_person_id)
--
-- 115.3 (END)
--
 AND    paa.period_of_service_id = pos.period_of_service_id;

 --bug no 5105026 starts here
   CURSOR csr_old_prd_srvc IS
   SELECT DISTINCT
          paa.business_group_id
         ,pos.period_of_service_id
         ,pos.date_start
   FROM   per_periods_of_service pos
         ,per_all_assignments_f paa
   WHERE  paa.person_id = p_person_id
   AND    p_effective_date BETWEEN
          paa.effective_start_date AND paa.effective_end_date
   AND    paa.person_id = pos.person_id
   AND    paa.period_of_service_id = pos.period_of_service_id;
 --bug no 5105026 ends here

  l_proc                 VARCHAR2(72) := g_package||'cancel_hire';
  l_system_person_type   per_person_types.system_person_type%TYPE;
  l_business_group_id    NUMBER;
  l_period_of_service_id NUMBER;
  l_date_start           DATE;
  l_effective_date       DATE;
  l_cancel_type          VARCHAR2(10)  :=  'HIRE';
  l_where                VARCHAR2(30)  :=  'BEGIN';
  l_supervisor_warning   BOOLEAN       := FALSE;
  l_recruiter_warning    BOOLEAN       := FALSE;
  l_event_warning        BOOLEAN       := FALSE;
  l_interview_warning    BOOLEAN       := FALSE;
  l_review_warning       BOOLEAN       := FALSE;
  l_vacancy_warning      BOOLEAN       := FALSE;
  l_requisition_warning  BOOLEAN       := FALSE;
  l_budget_warning       BOOLEAN       := FALSE;
  l_payment_warning      BOOLEAN       := FALSE;

  --
-- fix 7001197

cursor csr_emp_apl_chk is

select max(effective_start_date)
from per_person_type_usages_f ppf1
where ppf1.person_id =  p_person_id

and ppf1.effective_start_date >
    ( select max(ppf2.effective_start_date)
    from per_person_type_usages_f ppf2 , per_person_types ppt2
    where ppf2.person_id = p_person_id
         and ppt2.person_type_id= ppf2.person_type_id
        and ppt2.system_person_type='APL'
        and ppt2.business_group_id = l_business_group_id )

and exists (
select '1' from
per_person_types ppt
where ppt.person_type_id= ppf1.person_type_id
and ppt.system_person_type='EX_APL'
and ppt.business_group_id = l_business_group_id );


cursor csr_rehired_date is
select max(effective_start_date)
from per_person_type_usages_f pptf
where person_id = p_person_id
and exists (
select '1' from
per_person_types ppt
where ppt.person_type_id= pptf.person_type_id
and ppt.system_person_type='EMP'
and ppt.business_group_id = l_business_group_id );

cursor csr_apl_date is
select max(effective_start_date)
from per_person_type_usages_f pptf
where person_id = p_person_id
and exists (
select '1' from
per_person_types ppt
where ppt.person_type_id= pptf.person_type_id
and ppt.system_person_type='APL'
and ppt.business_group_id = l_business_group_id );


 CURSOR csr_person_types
    (p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    )
  IS
    SELECT typ.system_person_type
      FROM  per_person_types typ
          ,per_person_type_usages_f ptu
     WHERE
        typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
       AND typ.person_type_id = ptu.person_type_id
       AND p_effective_date BETWEEN ptu.effective_start_date
                                AND ptu.effective_end_date
       AND ptu.person_id = p_person_id
  ORDER BY DECODE(typ.system_person_type
                 ,'EMP'   ,1
                 ,'CWK'   ,2
                 ,'APL'   ,3
                 ,'EX_EMP',4
                 ,'EX_CWK',5
                 ,'EX_APL',6
                          ,7
                 );

cursor csr_fut_person_check (l_date date) is
select '1'
from per_person_type_usages_f where
person_id=p_person_id and
effective_start_date > l_date;

l_efd date :=null;

  cursor future_pay_proposals is
  select 'exist'
  from   per_pay_proposals
  where  assignment_id  in (
          select distinct (assignment_id)
          from per_all_assignments_f
          where person_id= p_person_id
          and assignment_type ='E'
          and l_efd -1 between effective_start_date and effective_end_date
          and primary_flag='Y'
          )
          and change_date >= l_efd;

l_last_person_type    VARCHAR2(2000);
l_exists varchar2(10) :=null;
l_fut_exists varchar2(1);
l_rehired_date date;
l_apl_date date;
l_curr_person_type VARCHAR2(2000):=NULL;

--
-- fix 7001197
--

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint cancel_hire;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Initialise local variables
  --
  OPEN  csr_get_per_details;
  FETCH csr_get_per_details INTO l_business_group_id
                                ,l_period_of_service_id
                                ,l_date_start;
  CLOSE csr_get_per_details;

  IF l_business_group_id IS NULL
  OR l_period_of_service_id IS NULL
  OR l_date_start IS NULL THEN
    --
    -- This person does not have a valid period of service.
    --
 --bug no 5105026 starts here
	   OPEN csr_old_prd_srvc;
	   FETCH csr_old_prd_srvc INTO l_business_group_id
					,l_period_of_service_id
					,l_date_start;
	  CLOSE csr_old_prd_srvc;
	  IF l_business_group_id IS NULL
	  OR l_period_of_service_id IS NULL
	  OR l_date_start IS NULL THEN

		    fnd_message.set_name('PER','HR_6346_EMP_ASS_NO_POS');
		    fnd_message.raise_error;
	   else
		   hr_utility.set_message(800,'HR_449773_POS_NOT_CRRNT');
		   hr_utility.raise_error;
	   end if;
--bug no 5105026 ends here
  END IF;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_cancel_hire_bk1.cancel_hire_b
      (p_person_id                     => p_person_id
      ,p_effective_date                => l_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'cancel_hire'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Lock the appropriate rows.
  --
  per_cancel_hire_or_apl_pkg.lock_per_rows
    (p_person_id           => p_person_id
    ,p_primary_id          => l_period_of_service_id
    ,p_primary_date        => l_date_start
    ,p_business_group_id   => l_business_group_id
    ,p_person_type         => 'EMP');

  --
  -- Validation in addition to Row Handlers. There is one loop
  -- to the validation server side package per warning.
  --
   -- BUG 7001197
  hr_utility.set_location('cancel_hire '||p_person_id,100);
  hr_utility.set_location('cancel_hire ||p_effective_date '||p_effective_date,100);

  open csr_emp_apl_chk ;
  fetch csr_emp_apl_chk into l_efd;
    if csr_emp_apl_chk%found and l_efd is not null then
      close csr_emp_apl_chk;

      -- this cursor returns when the ex apl was made  and with this date
      -- we can process with our logic of cancelling the emp_apl hire.

      if l_efd > p_effective_date then
      -- user is trying to perform cancel hire before the hire was done
      -- restricting this so that user changes the date to beyond any future
      -- Person type changes.
        hr_utility.set_message(801,'HR_7078_EMP_ENTER_CANCEL_TYPE');
         hr_utility.raise_error;
      end if;

       hr_utility.set_location('cancel_hire || l_efd '||l_efd,101);

-- to find out the from which person type the hire was made

  FOR l_person_type IN csr_person_types
    (p_effective_date               => l_efd-1
    ,p_person_id                    => p_person_id
    )
  LOOP
    IF (l_last_person_type IS NULL)
    THEN
      l_last_person_type := l_person_type.system_person_type;
    ELSE
      l_last_person_type := l_last_person_type||'_'||l_person_type.system_person_type;
    END IF;
  END LOOP;

   elsif l_efd is null then
   -- this case is used to handle the case when the emp.apl is hired
   -- by retaining one application where he will still be an emp.apl after hire
   -- so changing the logic accordingly to perfrom the cancel hire
     close csr_emp_apl_chk;

 hr_utility.set_location('cancel_hire l_efd is null '||l_efd,104);



    hr_utility.set_location('cancel_hire l_efd is null '||l_efd,102);
   open csr_rehired_date;
   fetch csr_rehired_date into l_rehired_date;
   close csr_rehired_date;


    open csr_fut_person_check(p_effective_date);
    fetch csr_fut_person_check into l_fut_exists;
    if csr_fut_person_check%found then

        close csr_fut_person_check;
          hr_utility.set_location('cancel_hire || l_efd '||l_efd,999);
    	 hr_utility.set_message(801,'HR_7078_EMP_ENTER_CANCEL_TYPE');
         hr_utility.raise_error;
    else
    	close csr_fut_person_check;
    end if;

  l_efd:=l_rehired_date;

  FOR l_person_type IN csr_person_types
    (p_effective_date               => l_rehired_date -1 --p_effective_date
    ,p_person_id                    => p_person_id
    )
  LOOP
    IF (l_last_person_type IS NULL)
    THEN
      l_last_person_type := l_person_type.system_person_type;
    ELSE
      l_last_person_type := l_last_person_type||'_'||l_person_type.system_person_type;
    END IF;
  END LOOP;

     if l_last_person_type ='EMP_APL' then
       open csr_apl_date;
       fetch csr_apl_date into l_apl_date;
       close csr_apl_date ;

          if l_apl_date > l_rehired_date then

            hr_utility.set_message(801,'HR_7078_EMP_ENTER_CANCEL_TYPE');
            hr_utility.raise_error;

          end if;
    end if;

   end if;

  -- BUG 7001197
  if csr_emp_apl_chk%isopen then
  close  csr_emp_apl_chk;
  end if;

  if csr_rehired_date%isopen then
  close csr_person_types;
  end if;

 if csr_fut_person_check%isopen then
 close csr_person_types;
 end if;

 if csr_person_types%isopen then
 close csr_person_types;
 end if;

  hr_utility.set_location('l_last_person_type '||l_last_person_type,101);

   if l_last_person_type  in ('EMP_APL','EMP_APL_EX_CWK') then

    --  cancelling back to EMP_APL from EMP_EX-APL
    -- NEW CODE TO FIX THE BUG 7001197


   hr_utility.set_location('Perform the checks and cancel the hire ',101);

    hr_utility.set_location('l_last_person_type '||l_last_person_type,101);
    hr_utility.set_location('l_date_start '||l_date_start,101);
    hr_utility.set_location('hr_api.g_eot '||hr_api.g_eot,101);
    hr_utility.set_location(' l_period_of_service_id '||l_period_of_service_id,101);

     per_cancel_hire_or_apl_pkg.cancel_emp_apl_hire
     (
      p_person_id            =>  p_person_id
     ,p_date_start           =>  l_efd
     ,p_end_of_time          =>  hr_api.g_eot
     ,p_business_group_id    =>  l_business_group_id
     ,p_period_of_service_id =>  l_period_of_service_id
      );


   hr_utility.set_location('after performing cancel hire ',102);

   -- the foll piece of code is to handle the case
   -- when any cancel hire returns in data corruption
   -- the basic intention of the cancel hire is to revert back to
   -- emp-apl person type . this will handle the case of when the Applicant was terminated
   -- using End Application from and not through the process of Hiring.


  FOR l_person_type IN csr_person_types
    (p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    )
  LOOP
    IF (l_curr_person_type IS NULL)
    THEN
      l_curr_person_type := l_person_type.system_person_type;
    ELSE
      l_curr_person_type := l_curr_person_type||'_'||l_person_type.system_person_type;
    END IF;
  END LOOP;

   hr_utility.set_location('after performing cancel hire ',103);
   hr_utility.set_location('l_curr_person_type '||l_curr_person_type,102);

   if l_curr_person_type  not in ('EMP_APL','EMP_APL_EX_CWK') then

             hr_utility.set_location('raise the error',102);
            hr_utility.set_message(801,'HR_7078_EMP_ENTER_CANCEL_TYPE');
            hr_utility.raise_error;

   end if;

  open future_pay_proposals;
  fetch future_pay_proposals into l_exists;
  close future_pay_proposals;

  if l_exists is not null then

  p_pay_proposal_warning :=TRUE;

  end if;

--
--

  ELSE
  -- existing CODE which takes care if not cancelling an emp_apl hire.
  LOOP

    EXIT WHEN l_where = 'END';

    per_cancel_hire_or_apl_pkg.pre_cancel_checks
      (
       p_person_id           =>  p_person_id
      ,p_where               =>  l_where
      ,p_business_group_id   =>  l_business_group_id
      ,p_system_person_type  =>  'EMP'
      ,p_primary_id          =>  l_period_of_service_id
      ,p_primary_date        =>  l_date_start
      ,p_cancel_type         =>  l_cancel_type
      );

    IF l_where IN ('SUPERVISOR','RECRUITER','EVENT','INTERVIEW'
                  ,'REVIEW','VACANCY','REQUISITION','BUDGET_VALUE'
                  ,'PAYMENT') THEN

      if l_where = 'SUPERVISOR' then
        l_supervisor_warning := TRUE;
        l_where := 'RECRUITER';
      elsif l_where = 'RECRUITER' then
        l_recruiter_warning := TRUE;
        l_where := 'EVENT';
      elsif l_where = 'EVENT' then
        l_event_warning := TRUE;
        l_where := 'INTERVIEW';
      elsif l_where = 'INTERVIEW' then
        l_interview_warning := TRUE;
        l_where := 'REVIEW';
      elsif l_where = 'REVIEW' then
        l_review_warning := TRUE;
        l_where := 'VACANCY';
      elsif l_where = 'VACANCY' then
        l_vacancy_warning := TRUE;
        l_where := 'REQUISITION';
      elsif l_where = 'REQUISITION' then
        l_requisition_warning := TRUE;
        l_where := 'BUDGET_VALUE';
      elsif l_where = 'BUDGET_VALUE' then
        l_budget_warning := TRUE;
        l_where := 'PAYMENT';
      elsif l_where = 'PAYMENT' then
        l_payment_warning := TRUE;
        l_where := 'END';
      elsif l_where <> 'END' then
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE','cancel_hire',false);
        fnd_message.set_token('STEP','1');
        fnd_message.raise_error;
      end if;

    END IF;

  END LOOP;

  --
  -- Process Logic. Perform the cancel hire.
  --

  per_cancel_hire_or_apl_pkg.do_cancel_hire
    (
     p_person_id            =>  p_person_id
    ,p_date_start           =>  l_date_start
    ,p_end_of_time          =>  hr_api.g_eot
    ,p_business_group_id    =>  l_business_group_id
    ,p_period_of_service_id =>  l_period_of_service_id
    );

END IF; --BUG 7001197
-- BUG 7001197
--
-- 115.3 (START)
  --
  -- Manage overlapping PDS condition if any
  --
  hr_employee_api.manage_rehire_primary_asgs
    (p_person_id
    ,l_date_start
    ,'Y'
    );
--
-- 115.3 (END)
--
  --
  -- Call After Process User Hook
  --
  begin
    hr_cancel_hire_bk1.cancel_hire_a
      (p_person_id                     => p_person_id
      ,p_effective_date                => l_effective_date
      ,p_supervisor_warning            => l_supervisor_warning
      ,p_recruiter_warning             => l_recruiter_warning
      ,p_event_warning                 => l_event_warning
      ,p_interview_warning             => l_interview_warning
      ,p_review_warning                => l_review_warning
      ,p_vacancy_warning               => l_vacancy_warning
      ,p_requisition_warning           => l_requisition_warning
      ,p_budget_warning                => l_budget_warning
      ,p_payment_warning               => l_payment_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'cancel_hire'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_supervisor_warning  := l_supervisor_warning;
  p_recruiter_warning   := l_recruiter_warning;
  p_event_warning       := l_event_warning;
  p_interview_warning   := l_interview_warning;
  p_review_warning      := l_review_warning;
  p_vacancy_warning     := l_vacancy_warning;
  p_requisition_warning := l_requisition_warning;
  p_budget_warning      := l_budget_warning;
  p_payment_warning     := l_payment_warning;

  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to cancel_hire;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to cancel_hire;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end cancel_hire;
--
end hr_cancel_hire_api;

/
