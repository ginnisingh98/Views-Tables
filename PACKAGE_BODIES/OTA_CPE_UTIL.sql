--------------------------------------------------------
--  DDL for Package Body OTA_CPE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CPE_UTIL" as
/* $Header: otcpewrs.pkb 120.40.12010000.11 2010/03/24 06:21:44 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33)	:= 'OTA_CPE_UTIL.';  -- Global package name

--  ---------------------------------------------------------------------------
--  |----------------------< crt_comp_upd_succ_att >-----------------------------|
--  ---------------------------------------------------------------------------
--

Procedure crt_comp_upd_succ_att(p_event_id in ota_events.event_id%type,
                                p_person_id in number
                               )
is

 l_proc                    varchar2(72) := g_package||' crt_comp_upd_succ_att';

cursor get_crt_prd_enrollments is
select cpe.cert_prd_enrollment_id,
cpe.cert_period_start_date,
cpe.cert_period_end_date,
cre.certification_id
  from
   ota_activity_versions tav,
           ota_cert_enrollments cre,
           ota_cert_prd_enrollments cpe,
           ota_cert_mbr_enrollments cme,
           ota_certification_members cmb,
	   ota_events evt

	   where evt.event_id = p_event_id
	   and evt.activity_version_id = tav.activity_version_id
	   AND cmb.object_id = tav.activity_version_id
    AND cmb.object_type = 'H'
    AND cme.cert_member_id = cmb.certification_member_id
    AND cme.member_status_code <> 'CANCELLED'
    and cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
    and cpe.period_status_code = 'COMPLETED'
    and cpe.cert_enrollment_id = cre.cert_enrollment_id
    and cre.person_id = p_person_id
    AND    ((evt.course_start_date >= cpe.cert_period_start_date
         and nvl(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) <= cpe.cert_period_end_date )
       OR
        (event_type ='SELFPACED'  and cpe.cert_period_end_date >= course_start_date)
         AND     (evt.course_end_date is null or (evt.course_end_date IS NOT NULL AND
         	evt.course_end_date >= cpe.cert_period_start_date)) );

    l_item_key wf_items.item_key%type;

begin

hr_utility.set_location('Entering:'|| l_proc, 10);

 for rec in get_crt_prd_enrollments
 Loop
    if ('Y' = ota_cpe_util.is_cert_success_complete(p_cert_prd_enrollment_id => rec.cert_prd_enrollment_id,
                p_cert_period_start_date       => rec.cert_period_start_date
                ,p_cert_period_end_date         => rec.cert_period_end_date,
                p_person_id => p_person_id)) then
    ota_competence_ss.create_wf_process(p_process     =>'OTA_COMPETENCE_UPDATE_JSP_PRC',
           p_itemtype         =>'HRSSA',
           p_person_id     => p_person_id,
           p_eventid       =>null,
           p_learningpath_ids => null,
            p_certification_id => rec.certification_id ,
           p_itemkey    =>l_item_key);

  end if;

 end loop;
 hr_utility.set_location('Leaving:'|| l_proc, 10);
end crt_comp_upd_succ_att;

--  ---------------------------------------------------------------------------
--  |----------------------< is_cert_success_complete >-----------------------------|
--  ---------------------------------------------------------------------------
--
Function is_cert_success_complete(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
 p_cert_period_start_date in ota_cert_prd_enrollments.cert_period_start_date%type,
p_cert_period_end_date in ota_cert_prd_enrollments.cert_period_start_date%type,
p_person_id in number)
return varchar2
IS


--get all the classes under one certification
 Cursor Csr_Cert_mbr is
 Select
         tav.activity_version_id

FROM
           ota_activity_versions tav,
     --      ota_cert_enrollments cre,
           ota_cert_prd_enrollments cpe,
           ota_cert_mbr_enrollments cme,
           ota_certification_members cmb

WHERE
cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
--  AND   cre.cert_enrollment_id = cpe.cert_enrollment_id
    AND cme.cert_member_id = cmb.certification_member_id
    AND cme.member_status_code <> 'CANCELLED'
    AND cmb.object_id = tav.activity_version_id
    AND cmb.object_type = 'H'
 --   AND tav.activity_version_id= evt.activity_version_id
    AND cpe.cert_prd_enrollment_id =p_cert_prd_enrollment_id; -- 640, 350, 349


Cursor Csr_Crt_mbr_cls_status(p_act_version_id ota_activity_versions.activity_version_id%Type
			      ) is
Select tdb.successful_attendance_flag
From   ota_events evt,ota_delegate_bookings tdb,ota_booking_status_types bst
Where
evt.activity_version_id = p_act_version_id
and   tdb.event_id = evt.event_id
and    tdb.booking_status_type_id = bst.booking_status_type_id
and    bst.type = 'A'
AND    tdb.delegate_person_id = p_person_id
--and tdb.event_id =p_event_id
AND    ((evt.course_start_date >= p_cert_period_start_date
         and nvl(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) <= p_cert_period_end_date )
       OR
        (event_type ='SELFPACED'  and p_cert_period_end_date >= course_start_date)
         AND     (evt.course_end_date is null or (evt.course_end_date IS NOT NULL AND
         	evt.course_end_date >= p_cert_period_start_date)) )
Order by Nvl(tdb.Successful_attendance_flag,'N') desc         ;


  l_act_version_id Number;
  l_mbr_cls_succ_att_flag Varchar2(1) := 'N';
  l_succ_att_flag varchar2(5);
  l_cls_enr_exists varchar2(1) := 'N' ;
Begin
    For I in Csr_Cert_mbr Loop
        hr_utility.trace('Batra act_id' || I.Activity_version_id);

          for rec in Csr_Crt_mbr_cls_status(I.Activity_version_id)
          Loop
            l_cls_enr_exists := 'Y' ;
          l_succ_att_flag := rec.successful_attendance_flag;
          hr_utility.trace('Batra l_succ_att_flag' || l_succ_att_flag);
/*          If Csr_Crt_mbr_cls_status%Notfound then
          hr_utility.trace('Batra in crs not found l_succ_att_flag' || I.Activity_version_id);
             l_mbr_cls_succ_att_flag := 'N' ;
             exit ;
          Else*/
         	If Nvl(l_succ_att_flag,'N') = 'Y' then
         	hr_utility.trace('Batra l_succ_att_flag Y' || I.Activity_version_id);
			l_mbr_cls_succ_att_flag := 'Y' ;
			exit ;
		      Else
		          hr_utility.trace('Batra in else of l_succ_att_flag' || l_succ_att_flag);
			     l_mbr_cls_succ_att_flag := 'N' ;
			     exit ;
           End If;
--	     End If ;
	   End Loop ;
      -- If either no class enrollment exists or found an class enrollment is not set to successful_attendannce
      -- no further process required.
	   If   l_cls_enr_exists = 'N' or l_mbr_cls_succ_att_flag = 'N' then
	         l_mbr_cls_succ_att_flag := 'N' ;
	         exit ;
       End if ;
	--close Csr_Crt_mbr_cls_status;

    End Loop;
hr_utility.trace('Batra before return' || l_mbr_cls_succ_att_flag);
 return l_mbr_cls_succ_att_flag;

end is_cert_success_complete;


--  ---------------------------------------------------------------------------
--  |----------------------< chk_cert_prd_compl >-----------------------------|
--  ---------------------------------------------------------------------------
--
Function chk_cert_prd_compl(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type)
return varchar2
IS

Cursor any_child is
Select cme.cert_mbr_enrollment_id
  from ota_cert_mbr_enrollments cme
 where member_status_code <> 'CANCELLED'
   and member_status_code <> 'COMPLETED'
   and cert_prd_enrollment_id = p_cert_prd_enrollment_id and rownum=1;

Cursor one_child_completed is
Select cme.cert_mbr_enrollment_id
  from ota_cert_mbr_enrollments cme
 where member_status_code = 'COMPLETED'
   and cert_prd_enrollment_id = p_cert_prd_enrollment_id and rownum=1;

    l_proc    VARCHAR2(72) := g_package ||'chk_cert_prd_compl';
    l_exists  Number(9);
    l_complete Number(9);
    l_result  varchar2(3) :='F';

Begin

    hr_utility.set_location(' Entering:' || l_proc,10);

    open any_child;
    fetch any_child into l_exists;
    if any_child%NOTFOUND then
        open one_child_completed;
        fetch one_child_completed into l_complete;
        if one_child_completed%found then
            l_result :='S';
        end if;
        close one_child_completed;
    end if;
    close any_child;

    return l_result;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN NULL;

end chk_cert_prd_compl;

procedure update_cpe_status(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type
                            ,p_certification_status_code OUT NOCOPY VARCHAR2
                            ,p_enroll_from in varchar2 default null
                            ,p_cert_period_end_date   in ota_cert_prd_enrollments.cert_period_end_date%type default null
                            ,p_child_update_flag      in varchar2 default 'Y'
                            ,p_completion_date in date default sysdate)
IS

Cursor csr_mbr_enrl is
Select cme.cert_mbr_enrollment_id
  from ota_cert_mbr_enrollments cme
 where member_status_code <> 'CANCELLED'
   and cert_prd_enrollment_id = p_cert_prd_enrollment_id;

Cursor one_child_active IS
Select cme.cert_mbr_enrollment_id
  from ota_cert_mbr_enrollments cme
 where member_status_code in ('ACTIVE', 'COMPLETED')
   and cert_prd_enrollment_id = p_cert_prd_enrollment_id and rownum=1;

CURSOR csr_cert_enrl IS
select cre.certification_status_code, cre.object_version_number, cre.completion_date,
cre.certification_id,
cre.person_id,
cre.expiration_date, cre.unenrollment_date
FROM ota_cert_enrollments cre,
     ota_cert_prd_enrollments cpe
where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id
  and cpe.cert_enrollment_id = cre.cert_enrollment_id;

CURSOR csr_prd_enrl IS
select period_status_code, object_version_number, completion_date, cert_enrollment_id, cert_period_end_date
FROM ota_cert_prd_enrollments
where cert_prd_enrollment_id = p_cert_prd_enrollment_id;

Cursor get_mbr_completion_date is
Select min(cme.completion_date)
  from ota_cert_mbr_enrollments cme
 where member_status_code = 'COMPLETED'
   and cert_prd_enrollment_id = p_cert_prd_enrollment_id;
l_proc    varchar2(72) := g_package || ' update_cpe_status';


l_cert_enrl_rec csr_cert_enrl%ROWTYPE;
l_prd_enrl_rec csr_prd_enrl%ROWTYPE;

l_complete_cert_prd_ok VARCHAR2(30);
l_period_status_code VARCHAR2(30);
n_period_status_code VARCHAR2(30) := 'ENROLLED';
l_certification_status_code ota_cert_enrollments.certification_status_code%type := 'ENROLLED';

l_object_version_number1 number;
l_object_version_number2 number;
l_object_version_number3 number;

l_completion_date DATE;
l_cert_prd_enrollment_id NUMBER;
l_cert_mbr_enrollment_id NUMBER;

l_period_start_date DATE;
l_period_end_date DATE;

--l_certification_status_code VARCHAR2(30);
l_expiration_date DATE;
l_unenrollment_date DATE;

Begin

    hr_utility.set_location(' Entering:' || l_proc,10);

    if p_child_update_flag = 'Y' then
       for rec_mbr_enrl in csr_mbr_enrl
       loop
          ota_cme_util.update_cme_status(rec_mbr_enrl.cert_mbr_enrollment_id);
       end loop;
    end if;

    --check for period completion
    -- verify the period cert enrol eligibility for marking complete
     l_complete_cert_prd_ok := ota_cpe_util.chk_cert_prd_compl(p_cert_prd_enrollment_id => p_cert_prd_enrollment_id);

     IF l_complete_cert_prd_ok = 'S' THEN
	-- The Plan can be completed
	n_period_status_code := 'COMPLETED';
     ELSIF l_complete_cert_prd_ok = 'F' THEN
	--if atleast one child is in ACTIVE or COMPLETED, mark the parent cpe as ACTIVE
	   open one_child_active;
	   fetch one_child_active into l_cert_mbr_enrollment_id;
	   if one_child_active%found then
	       n_period_status_code := 'ACTIVE';
	   end if;
	   close one_child_active;
     END IF;

     OPEN csr_prd_enrl;
     FETCH csr_prd_enrl INTO l_prd_enrl_rec;
     CLOSE csr_prd_enrl;


     IF n_period_status_code <> l_prd_enrl_rec.period_status_code THEN

	  --update cpe and cre recs
	  if n_period_status_code = 'ACTIVE' THEN
	     l_certification_status_code := 'ENROLLED';
	     l_completion_date := null;
	     l_expiration_date := null;
	  elsif n_period_status_code = 'COMPLETED' THEN
	     --cert enrol overall status code
	     l_certification_status_code := 'CERTIFIED';
	     open get_mbr_completion_date;
         fetch get_mbr_completion_date into l_completion_date;
         close get_mbr_completion_date;

         l_completion_date := trunc(nvl(l_completion_date, p_completion_date));
	     --l_completion_date := trunc(sysdate);
      else
         l_certification_status_code := 'ENROLLED';
	     l_completion_date := null;
	     l_expiration_date := null;
      end if;



      ota_cert_prd_enrollment_api.update_cert_prd_enrollment
		   (p_effective_date               => trunc(sysdate)
		   ,p_cert_enrollment_id           => l_prd_enrl_rec.cert_enrollment_id
		   ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
		   ,p_object_version_number        => l_prd_enrl_rec.object_version_number
		   ,p_period_status_code           => n_period_status_code
		   ,p_completion_date              => l_completion_date);


	  OPEN csr_cert_enrl;
	  FETCH csr_cert_enrl INTO l_cert_enrl_rec;
	  CLOSE csr_cert_enrl;

      if  n_period_status_code = 'COMPLETED' then
          --get the recent expiration_date updated within cpe.. update api
          l_expiration_date := l_cert_enrl_rec.expiration_date;
      end if;

      if (l_certification_status_code = 'ENROLLED') then
        l_unenrollment_date := null;
      else
        l_unenrollment_date := l_cert_enrl_rec.unenrollment_date;
      end if;

      ota_cert_enrollment_api.update_cert_enrollment
		   (p_effective_date               => trunc(sysdate)
		   ,p_cert_enrollment_id           => l_prd_enrl_rec.cert_enrollment_id
		   ,p_certification_id             => l_cert_enrl_rec.certification_id
		   ,p_object_version_number        => l_cert_enrl_rec.object_version_number
		   ,p_certification_status_code    => l_certification_status_code
		   ,p_expiration_date              => l_expiration_date
		   ,p_completion_date              => l_completion_date
                   ,p_unenrollment_date            => l_unenrollment_date);

     end if; -- status code check

     -- update prd end date if passed from admin i/f
     OPEN csr_prd_enrl;
     FETCH csr_prd_enrl INTO l_prd_enrl_rec;
     CLOSE csr_prd_enrl;

     if (p_cert_period_end_date is not null and p_cert_period_end_date <> l_prd_enrl_rec.cert_period_end_date) then
         ota_cert_prd_enrollment_api.update_cert_prd_enrollment
		   (p_effective_date               => trunc(sysdate)
		   ,p_cert_enrollment_id           => l_prd_enrl_rec.cert_enrollment_id
		   ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
		   ,p_object_version_number        => l_prd_enrl_rec.object_version_number
		   ,p_period_status_code           => l_prd_enrl_rec.period_status_code
		   ,p_cert_period_end_date         => p_cert_period_end_date);

     end if;

     --set out params
     p_certification_status_code := l_certification_status_code;

     if l_cert_enrl_rec.person_id is not null
     and l_certification_status_code ='ENROLLED'
     and p_enroll_from = 'ADMIN' then
     OTA_LRNR_ENROLL_UNENROLL_WF.Cert_Enrollment(p_process => 'OTA_CERT_APPROVAL_JSP_PRC',
            p_itemtype 	=> 'HRSSA',
            p_person_id => l_cert_enrl_rec.person_id,
            p_certificationid  => l_cert_enrl_rec.certification_id);
     end if;

EXCEPTION
WHEN others THEN
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_certification_status_code := null;
    hr_utility.set_location(' Leaving:' || l_proc,50);
    raise;
end update_cpe_status;


function is_period_renewable(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type)
return varchar2 is

CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.RENEWABLE_FLAG
        , b.INITIAL_COMPLETION_DURATION
        , cre.expiration_date
from ota_certifications_b b,
     ota_cert_enrollments cre
where cre.certification_id = b.certification_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_max_cpe_exp_dt IS
select
        max(cpe.expiration_date)
from ota_cert_prd_enrollments cpe,
     ota_cert_enrollments cre
where cpe.cert_enrollment_id = cre.cert_enrollment_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_dupl_prd(csr_expiration_date ota_cert_enrollments.expiration_date%type) is
select 'Y' as dupl_prd_exists
  from ota_cert_enrollments
 where cert_enrollment_id = p_cert_enrollment_id
   and expiration_date = csr_expiration_date;

l_proc VARCHAR2(72) := g_package||'is_period_renewable';

l_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;
l_expiration_date ota_cert_enrollments.expiration_date%type;
l_curr_dt date;
l_dupl_prd_exists varchar2(1) := 'N';

rec_crt csr_crt%rowtype;

l_return_val varchar2(1)  := 'N';
l_max_expiration_date date;

Begin
   	hr_utility.set_location('Entering :'||l_proc,5);

    --return N for non renewal certs
    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    if (rec_crt.RENEWABLE_FLAG is null or rec_crt.RENEWABLE_FLAG = 'N')  then
       return 'N';
    end if;

    l_curr_dt :=  trunc(sysdate);

    OPEN csr_max_cpe_exp_dt;
    FETCH csr_max_cpe_exp_dt INTO l_max_expiration_date;
    CLOSE csr_max_cpe_exp_dt;

    /*
    if l_curr_dt > l_max_expiration_date and rec_crt.INITIAL_COMPLETION_DURATION is not null then
     --this is for expired init durn based certs, hence allow re-enroll beyond last day of reg earl enr day
        l_return_val := 'Y';
        return l_return_val;
    end if;
    */

    calc_cre_dates(p_cert_enrollment_id, rec_crt.certification_id, 'V', l_earliest_enroll_date, l_expiration_date);

    --check for dupl prd
   /* open csr_dupl_prd(l_expiration_date);
    fetch csr_dupl_prd into l_dupl_prd_exists;
       if csr_dupl_prd%found then
          return l_dupl_prd_exists;
       end if;
    close csr_dupl_prd; */

    if l_earliest_enroll_date is not null and l_expiration_date is not null then
	--based by dur can re-enroll after the ear_enr_dt since the restriction
	--as applicable to based by date is not applicable ie., learners don't need
	--to finish on same period due date.
	if rec_crt.INITIAL_COMPLETION_DURATION is not null then
	  if l_curr_dt >= l_earliest_enroll_date then
	     l_return_val := 'Y';
      	  else
         	l_return_val := 'N';
          end if;
	else
      	  if l_curr_dt between l_earliest_enroll_date
                       and l_expiration_date then
                l_return_val := 'Y';
      	  else
         	l_return_val := 'N';
      	  end if;
	end if;
    end if;

    hr_utility.set_location('Leaving :'||l_proc,10);

   return l_return_val;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End is_period_renewable;

Function get_earl_enrl_dt(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
			  p_expiration_date  in ota_cert_enrollments.expiration_date%type)
return date
IS

CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.RENEWAL_DURATION
        , b.RENEWAL_DURATION_UNITS
        , b.NOTIFY_DAYS_BEFORE_EXPIRE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.RENEWABLE_FLAG
        , b.VALIDITY_START_TYPE
        , b.PUBLIC_FLAG
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
from ota_certifications_b b,
     ota_cert_enrollments cre
where cre.certification_id = b.certification_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

l_proc VARCHAR2(72) := g_package||' get_earl_enrl_dt';
rec_crt csr_crt%rowtype;

l_next_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;


BEGIN

    hr_utility.set_location('Entering :'||l_proc,5);

    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    --renewal duration logic as it may be null or not null
    --regulatory fixed date, validity starts from target date
    if (rec_crt.initial_completion_date is not null and rec_crt.VALIDITY_START_TYPE = 'T') then
	     if (rec_crt.renewal_duration is not null) then
		 l_next_earliest_enroll_date := p_expiration_date - rec_crt.renewal_duration;
	     end if;
    /*
    --professional fixed date, validity starts from actual completion date
    --elsif(rec_crt.initial_completion_date is not null and rec_crt.VALIDITY_START_TYPE = 'A') then
	--not supported
    --init dur with validity starts from actual target durn
    elsif (rec_crt.INITIAL_COMPLETION_DURATION is not null and rec_crt.VALIDITY_START_TYPE = 'T') then
	  if (rec_crt.renewal_duration is not null) then
		 l_next_earliest_enroll_date := p_expiration_date - rec_crt.renewal_duration;
	      else
		  --popl the values initially and update this with compl date on the day learner completes
		  l_next_earliest_enroll_date := p_expiration_date;
	      end if;
     --regulatory init dur with validity starts from actual completion date
    elsif (rec_crt.INITIAL_COMPLETION_DURATION is not null and rec_crt.VALIDITY_START_TYPE = 'A') then
	--popl the values initially and recalculate this val as "lrnr_compl date + rec_crt.validity_duration"
	-- also recalc the earliest enroll date when renewal_duration is null
	      if (rec_crt.renewal_duration is not null) then
		  l_next_earliest_enroll_date := p_expiration_date - rec_crt.renewal_duration;
	      else
	          l_next_earliest_enroll_date := p_expiration_date;
	      end if;
    */
    end if;

    hr_utility.set_location('Leaving :'||l_proc,10);

return l_next_earliest_enroll_date;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN NULL;

end get_earl_enrl_dt;

PROCEDURE calc_cre_dates(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
                              p_certification_id  in ota_cert_enrollments.certification_id%type,
                              p_mode in varchar2,
                              p_earliest_enroll_date  OUT nocopy ota_cert_enrollments.earliest_enroll_date%type,
			      p_expiration_date  OUT nocopy ota_cert_enrollments.expiration_date%type,
                              p_cert_period_start_date in date default sysdate)
 IS

CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.RENEWAL_DURATION
        , b.RENEWAL_DURATION_UNITS
        , b.NOTIFY_DAYS_BEFORE_EXPIRE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.RENEWABLE_FLAG
        , b.VALIDITY_START_TYPE
        , b.PUBLIC_FLAG
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
from ota_certifications_b b
where certification_id = p_certification_id;


CURSOR csr_cre IS
select
        trunc(cre.earliest_enroll_date) earliest_enroll_date --bug#8775942
        , trunc(cre.expiration_date) expiration_date
from ota_certifications_b b,
     ota_cert_enrollments cre
where cre.certification_id = b.certification_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;


CURSOR csr_max_cpe_exp_dt IS
select
        max(cpe.expiration_date)
from ota_cert_prd_enrollments cpe,
     ota_cert_enrollments cre
where cpe.cert_enrollment_id = cre.cert_enrollment_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

l_proc VARCHAR2(72) := g_package||'calc_cre_dates';
rec_crt csr_crt%rowtype;
rec_cre csr_cre%rowtype;

l_curr_dt date;

l_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;
l_expiration_date ota_cert_enrollments.expiration_date%type;
l_max_expiration_date date;

l_next_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;
l_next_expiration_date ota_cert_enrollments.expiration_date%type;

BEGIN
    hr_utility.set_location('Entering :'||l_proc,5);

    l_curr_dt :=  trunc(nvl(p_cert_period_start_date, sysdate));

    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    if (rec_crt.RENEWABLE_FLAG is null or rec_crt.RENEWABLE_FLAG = 'N') then
	    p_earliest_enroll_date := null;
	    p_expiration_date := null;
       --return null;
       return;
    end if;

    if p_mode = 'I' then
       --initial mode
       -- put the initial calc logic for earliest and exp dates
       --regulatory fixed date, validity starts from target date
       if (rec_crt.initial_completion_date is not null and rec_crt.VALIDITY_START_TYPE = 'T') then
          --Bug 4940007 for late subscriptions
          --exp date for on time subscr
          if l_curr_dt <= trunc(rec_crt.initial_completion_date) then
             l_expiration_date := rec_crt.initial_completion_date + rec_crt.validity_duration;
             --always ren dur popl for date based
             if (rec_crt.renewal_duration is not null) then
                l_earliest_enroll_date := l_expiration_date - rec_crt.renewal_duration;
             end if;
          else
          --elapsed exp date for late subscr
	        l_expiration_date := trunc(rec_crt.initial_completion_date);
             LOOP
	        l_expiration_date := l_expiration_date + rec_crt.validity_duration;
                EXIT WHEN l_curr_dt < trunc(l_expiration_date);
             END LOOP;
                if rec_crt.renewal_duration = rec_crt.validity_duration then
                   --this would be true if renewal is from target
                   --late subscr always have first perd exp as earliest enr dt
                   l_earliest_enroll_date := l_expiration_date;
                else
                   --this would be true if renewal is n days before exp date
                   --late subscr have first perd exp minus renewal days before exp value
                   l_earliest_enroll_date := l_expiration_date - rec_crt.renewal_duration;
                end if;
          end if;
    	elsif (rec_crt.INITIAL_COMPLETION_DURATION is not null) then
	   --initialize as if the learner doesn't complete by due date,
           --then based on when they compl and renewal/validity types recalc these dates
	   --l_expiration_date := trunc(sysdate) + rec_crt.initial_completion_duration;
           --l_expiration_date := trunc(sysdate) + rec_crt.initial_completion_duration + rec_crt.validity_duration;
           --l_earliest_enroll_date := trunc(sysdate) + rec_crt.initial_completion_duration;

            l_expiration_date := trunc(nvl(p_cert_period_start_date, sysdate)) + rec_crt.initial_completion_duration + rec_crt.validity_duration;
            l_earliest_enroll_date := trunc(nvl(p_cert_period_start_date, sysdate)) + rec_crt.initial_completion_duration;
        end if;
       p_earliest_enroll_date := l_earliest_enroll_date;
       p_expiration_date := l_expiration_date;
    elsif p_mode = 'V' then
       --verification mode
       --isrenewal chk requires logic to calc sysdate w/ expdate
       --default to next immediate dates, used for Notifs
       OPEN csr_cre;
       FETCH csr_cre INTO rec_cre;
       CLOSE csr_cre;

       OPEN csr_max_cpe_exp_dt;
       FETCH csr_max_cpe_exp_dt INTO l_max_expiration_date;
       CLOSE csr_max_cpe_exp_dt;

       --for based by dur we don't need re-enroll restriction as is the case
       --with based by date certs which req adding validity_dur to exp dt
       if rec_crt.initial_completion_duration is not null then
       	  l_next_earliest_enroll_date := rec_cre.earliest_enroll_date;
	  l_next_expiration_date := l_max_expiration_date;
       else
               if l_curr_dt <= trunc(l_max_expiration_date) then
		  p_earliest_enroll_date := rec_cre.earliest_enroll_date;
		  p_expiration_date := l_max_expiration_date;
		  return;
	       else
       		  l_next_expiration_date := l_max_expiration_date;

		  --loop next calc exp date and check for curr_dt

		  if l_next_expiration_date is not null then
		     LOOP
		       l_next_expiration_date := l_next_expiration_date + rec_crt.validity_duration;
		       EXIT WHEN l_curr_dt < trunc(l_next_expiration_date);
		     END LOOP;
		     l_next_earliest_enroll_date := get_earl_enrl_dt(p_cert_enrollment_id, l_next_expiration_date);
		  else
		   --return with null
        	   p_earliest_enroll_date := null;
	           p_expiration_date := null;
	           return;
		  end if;

	       end if;
	end if;

       p_earliest_enroll_date := l_next_earliest_enroll_date;
       p_expiration_date := l_next_expiration_date;
    else
       --renew mode
       --default to next immediate dates, used for period renewal and notifs
       OPEN csr_cre;
       FETCH csr_cre INTO rec_cre;
       CLOSE csr_cre;


       --for based by dur we don't need re-enroll restriction as is the case
       --with based by date certs which req adding validity_dur to exp dt
       if rec_crt.initial_completion_duration is not null then
	   --initialize as if the learner doesn't complete by due date,
           --then based on when they compl and renewal/validity types recalc these dates
	   --l_expiration_date := trunc(sysdate) + rec_crt.initial_completion_duration;
	       --l_next_expiration_date := trunc(sysdate) + rec_crt.initial_completion_duration + rec_crt.validity_duration;
           --l_next_earliest_enroll_date := trunc(sysdate) + rec_crt.initial_completion_duration;

	       l_next_expiration_date := trunc(nvl(p_cert_period_start_date, sysdate)) + rec_crt.initial_completion_duration + rec_crt.validity_duration;
           l_next_earliest_enroll_date := trunc(nvl(p_cert_period_start_date, sysdate)) + rec_crt.initial_completion_duration;
       else
          --loop next calc exp date and check for curr_dt
          OPEN csr_max_cpe_exp_dt;
          FETCH csr_max_cpe_exp_dt INTO l_max_expiration_date;
          CLOSE csr_max_cpe_exp_dt;

          l_next_expiration_date := l_max_expiration_date;

          if l_next_expiration_date is not null then
             LOOP
               l_next_expiration_date := l_next_expiration_date + rec_crt.validity_duration;
       	       EXIT WHEN l_curr_dt < trunc(l_next_expiration_date);
             END LOOP;
             l_next_earliest_enroll_date := get_earl_enrl_dt(p_cert_enrollment_id, l_next_expiration_date);
          else
             --return with null
             p_earliest_enroll_date := null;
             p_expiration_date := null;
             return;
	  end if;
       end if;

       p_earliest_enroll_date := l_next_earliest_enroll_date;
       p_expiration_date := l_next_expiration_date;
     end if; --pmode check

    hr_utility.set_location('Leaving :'||l_proc,10);

 EXCEPTION
    WHEN others THEN
        hr_utility.set_location('LEAVING:'|| l_proc, 30);
	    p_earliest_enroll_date := null;
	    p_expiration_date := null;
        RAISE;
END calc_cre_dates;

Function get_next_prd_dur_days(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
                               p_cert_period_start_date in date default sysdate )
return varchar2
IS

CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.validity_duration
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
        , cre.expiration_date
        , b.renewable_flag  --Bug 4545407
from ota_certifications_b b,
     ota_cert_enrollments cre
where cre.certification_id = b.certification_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;


CURSOR csr_max_cpe_exp_dt IS
select
        max(cpe.expiration_date)
from ota_cert_prd_enrollments cpe,
     ota_cert_enrollments cre
where cpe.cert_enrollment_id = cre.cert_enrollment_id
  and cre.cert_enrollment_id = p_cert_enrollment_id;

l_proc VARCHAR2(72) := g_package||' get_next_prd_dur_days';
rec_crt csr_crt%rowtype;

l_curr_dt date;
l_prd_durn varchar2(10);
l_next_expiration_date ota_cert_enrollments.expiration_date%type;
l_max_expiration_date date;
l_due_date date;
l_elapsed_due_date date;

BEGIN

    hr_utility.set_location('Entering :'||l_proc,5);

    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    l_curr_dt := trunc(nvl(p_cert_period_start_date, sysdate));

 --calculate period end date
    if (rec_crt.initial_completion_date is not null) then
      if  rec_crt.renewable_flag = 'Y' then -- For Bug 4545407
       --for date based cert, always due date is derived from the last exp date + val dur
        OPEN csr_max_cpe_exp_dt;
        FETCH csr_max_cpe_exp_dt INTO l_max_expiration_date;
        CLOSE csr_max_cpe_exp_dt;

        if l_max_expiration_date is not null then
           l_next_expiration_date := l_max_expiration_date;
        end if;

        --if the cpe rec is not yet created then l_next_expiration_date
        --is null and due date is same as initial_completion_date
        --whereas if l_next_expiration_date is not null then due date and exp date
        --remains same

        if l_next_expiration_date is not null then
          LOOP
            l_next_expiration_date := l_next_expiration_date + rec_crt.validity_duration;
            EXIT WHEN l_curr_dt < l_next_expiration_date;
          END LOOP;
  	      l_prd_durn := trunc(l_next_expiration_date) - l_curr_dt;
	    else
            --initial period rec
              --Bug 4940007 for late subscriptions
              --due date for on time subscr
              if l_curr_dt <= trunc(rec_crt.initial_completion_date) then
                 l_prd_durn := trunc(rec_crt.initial_completion_date) - l_curr_dt;
              else
              --elapsed due date for late subscr
                    l_elapsed_due_date := trunc(rec_crt.initial_completion_date);
                 LOOP
                    l_elapsed_due_date := l_elapsed_due_date + rec_crt.validity_duration;
		    EXIT WHEN l_curr_dt < l_elapsed_due_date;
		 END LOOP;
                 l_prd_durn := trunc(l_elapsed_due_date) - l_curr_dt;
              end if;
            end if;
      else  --Bug 4545407
        l_prd_durn := trunc(rec_crt.initial_completion_date) - l_curr_dt;
      end if; -- Bug 4545407
    elsif (rec_crt.initial_completion_duration is not null) then
	  l_prd_durn := rec_crt.initial_completion_duration;
    end if;

    l_prd_durn := '' || l_prd_durn;

    hr_utility.set_location('Leaving :'||l_proc,10);

return l_prd_durn;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN null;

end get_next_prd_dur_days;
--
FUNCTION get_cert_mbr_status (p_cert_mbr_id in ota_certification_members.certification_member_id%TYPE,
			      p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
			      p_code in number default 1)
RETURN varchar2 is

Cursor get_cert_mbr_status is
Select member_status_code
       ,ota_utility.get_lookup_meaning('OTA_CERT_MBR_ENROLL_STATUS', member_status_code, 810) member_status
From ota_cert_mbr_enrollments
where
	cert_member_id = p_cert_mbr_id
	and cert_prd_enrollment_id = p_cert_prd_enrollment_id;

l_member_status_code ota_cert_mbr_enrollments.member_status_code%TYPE;
l_member_status varchar2(240);

Begin
	Open get_cert_mbr_status;
	Fetch get_cert_mbr_status into l_member_status_code, l_member_status;
	Close get_cert_mbr_status;

	if ( p_code = 1 ) then
		return l_member_status_code;
	else
		return l_member_status;
	end if;
End get_cert_mbr_status;
--
FUNCTION get_cert_mbr_name (p_cert_mbr_id in ota_certification_members.certification_member_id%TYPE)
RETURN varchar2 is

Cursor get_cert_mbr_data is
Select object_id, object_type
From ota_certification_members
Where certification_member_id = p_cert_mbr_id;

Cursor get_course_name(p_act_ver_id in ota_activity_versions.activity_version_id%TYPE) is
Select version_name
From ota_activity_versions_vl
Where activity_version_id = p_act_ver_id;

l_object_id ota_certification_members.object_id%TYPE;
l_object_type ota_certification_members.object_type%TYPE;
l_member_name varchar2(240);
Begin
	Open get_cert_mbr_data;
	Fetch get_cert_mbr_data into l_object_id, l_object_type;
	Close get_cert_mbr_data;

	if (l_object_type = 'H') then --Course
		Open get_course_name(l_object_id);
		Fetch get_course_name into l_member_name;
		Close get_course_name;
	end if;

	return l_member_name;
End get_cert_mbr_name;

FUNCTION get_cre_status (p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%TYPE,
                         p_mode in varchar2 default 'm')
RETURN varchar2 is

Cursor csr_cre_status is
Select cre.certification_status_code,
       cre.completion_date,
       crt.validity_duration,
       ota_utility.get_lookup_meaning('OTA_CERT_ENROLL_STATUS', cre.certification_status_code, 810) cre_status,
       crt.renewable_flag,
       cre.expiration_date,
       nvl(crt.end_date_active,to_date('4712/12/31','YYYY/MM/DD')) end_date_active
From ota_cert_enrollments cre,
     ota_certifications_b crt
where cre.cert_enrollment_id = p_cert_enrollment_id
  and crt.certification_id = cre.certification_id;

l_proc VARCHAR2(72) := g_package||' get_cre_status';
rec_cre_status csr_cre_status%rowtype;

l_cre_status varchar2(240);
l_cre_status_code varchar2(30);
l_old_exp_date date;
l_curr_date date;

Begin
	open csr_cre_status;
	fetch csr_cre_status into rec_cre_status;
	close csr_cre_status;

	l_curr_date := trunc(sysdate);

       if (l_curr_date <= rec_cre_status.end_date_active) then
        if (rec_cre_status.renewable_flag = 'Y') then
     	  if (rec_cre_status.completion_date is not null and
              not (rec_cre_status.certification_status_code = 'EXPIRED'
              or rec_cre_status.certification_status_code = 'CANCELLED')) then
 	      --l_old_exp_date := rec_cre_status.completion_date + rec_cre_status.validity_duration;
 	      -- this could happen only for certs whose reenrl type is immed after compl.
 	          if (l_curr_date > rec_cre_status.expiration_date) then	  	   --
    	        l_cre_status := ota_utility.get_lookup_meaning('OTA_CERT_ENROLL_STATUS', 'EXPIRED', 810);
        	    l_cre_status_code := 'EXPIRED';
	            --return l_cre_status;
              else
                --return rec_cre_status.cre_status;
                 l_cre_status := rec_cre_status.cre_status;
      	         l_cre_status_code := rec_cre_status.certification_status_code;
    	      end if;
	       else
    	      --return rec_cre_status.cre_status;
              l_cre_status := rec_cre_status.cre_status;
   	          l_cre_status_code := rec_cre_status.certification_status_code;
	       end if;
        else
    	   --return rec_cre_status.cre_status;
           l_cre_status := rec_cre_status.cre_status;
	       l_cre_status_code := rec_cre_status.certification_status_code;
    	end if;
       else
        --concluded
    	        l_cre_status := ota_utility.get_lookup_meaning('OTA_CERT_ENROLL_STATUS', 'CONCLUDED', 810);
        	l_cre_status_code := 'CONCLUDED';

       end if;

        if p_mode = 'm' then
           return l_cre_status;
        else
           return l_cre_status_code;
        end if;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN null;

End get_cre_status;

FUNCTION get_cpe_edit_enabled(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE)
RETURN varchar2 is

Cursor csr_cpe is
Select
       get_cre_status(cre.cert_enrollment_id, 'c') certification_status_code
From ota_cert_enrollments cre,
     ota_cert_prd_enrollments cpe
where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id
  and cre.cert_enrollment_id = cpe.cert_enrollment_id;

l_proc VARCHAR2(72) := g_package||' get_cpe_edit_enabled';
rec_cpe csr_cpe%rowtype;

Begin
	open csr_cpe;
	fetch csr_cpe into rec_cpe;
	close csr_cpe;

	if (rec_cpe.certification_status_code = 'CERTIFIED' or
        rec_cpe.certification_status_code = 'EXPIRED' or
        rec_cpe.certification_status_code = 'ENROLLED') then
      return 'Y';
	else
	  return 'N';
	end if;


EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN null;

End get_cpe_edit_enabled;

FUNCTION chk_prd_end_date(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
                          p_cert_period_end_date in ota_cert_prd_enrollments.cert_period_end_date%TYPE,
                          p_mass_update_flag in varchar2 default 'N') return varchar2 IS

CURSOR csr_cert_enrl IS
select cre.certification_status_code,
       cre.completion_date,
       cre.certification_id,
       cpe.expiration_date,
       cpe.cert_period_end_date,
       cpe.period_status_code,
       crt.renewable_flag,
       crt.initial_completion_duration,
       crt.validity_duration,
       crt.validity_start_type
FROM ota_cert_enrollments cre,
     ota_cert_prd_enrollments cpe,
     ota_certifications_b crt
where cpe.cert_prd_enrollment_id = p_cert_prd_enrollment_id
  and cre.certification_id = crt.certification_id
  and cpe.cert_enrollment_id = cre.cert_enrollment_id;

l_cert_enrl_rec csr_cert_enrl%ROWTYPE;

--
  l_proc  VARCHAR2(72) := g_package||'chk_prd_end_date';
l_return_status varchar2(1):= 'S';
l_bypass_flag varchar2(1) := 'N';

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);

  if p_mass_update_flag = 'N' then
    hr_multi_message.enable_message_list;
  end if;

      OPEN csr_cert_enrl;
      FETCH csr_cert_enrl INTO l_cert_enrl_rec;
      CLOSE csr_cert_enrl;

  --bypass for cert whose start_type counts from compl, and  validity_prd is less than initi compl durn , and compl_date is populated before
      if ( l_cert_enrl_rec.renewable_flag = 'Y' and
      l_cert_enrl_rec.validity_start_type = 'A' and
      (l_cert_enrl_rec.validity_duration < l_cert_enrl_rec.initial_completion_duration) and
      l_cert_enrl_rec.completion_date is not null) then
         l_bypass_flag := 'Y';
      end if;

      if l_cert_enrl_rec.expiration_date is not null then
         if (l_cert_enrl_rec.period_status_code <> 'COMPLETED' and l_bypass_flag = 'N') then
            if (p_cert_period_end_date > l_cert_enrl_rec.expiration_date or
                p_cert_period_end_date < l_cert_enrl_rec.cert_period_end_date) then
                --throw invalid period end data error
                --l_result := 'E';
                if p_mass_update_flag = 'N' then
              	   fnd_message.set_name('OTA','OTA_443893_CPE_PRD_END_DT_ERR');
            	   fnd_message.set_token('DUE_DATE', l_cert_enrl_rec.cert_period_end_date);
            	   fnd_message.set_token('EXP_DATE', l_cert_enrl_rec.expiration_date);
            	   fnd_message.raise_error;
                else
                   l_return_status := 'E';
                end if;
            end if;
         end if;
      end if;

 hr_utility.set_location(' Leaving:'||l_proc, 20);

 if p_mass_update_flag = 'N' then
  l_return_status := hr_multi_message.get_return_status_disable;
 end if;

 return l_return_status;

 EXCEPTION

    WHEN app_exception.application_exception THEN
            hr_utility.set_location(' Leaving:'||l_proc, 25);

            if p_mass_update_flag = 'N' then
             if hr_multi_message.exception_add(p_associated_column1   => 'OTA_CERT_PRD_ENROLLMENTS.CERT_PERIOD_END_DATE') then
               return hr_multi_message.get_return_status_disable;
             end if;
             l_return_status := hr_multi_message.get_return_status_disable;
            else
             l_return_status := 'E';
            end if;

            return l_return_status;

    WHEN others THEN
         hr_utility.set_location('Leaving :'||l_proc,30);
         if p_mass_update_flag = 'N' then
            l_return_status := hr_multi_message.get_return_status_disable;
         else
            l_return_status := 'E';
         end if;

         return l_return_status;

END chk_prd_end_date;

procedure create_cpe_rec(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
			 p_expiration_date    in date,
			 p_cert_period_start_date in date default sysdate,
          		 p_cert_prd_enrollment_id OUT NOCOPY ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
          		 p_certification_status_code OUT NOCOPY VARCHAR2,
            		 p_is_recert in varchar2 default 'N')
IS
CURSOR csr_cert_info(p_certification_id in ota_cert_enrollments.certification_id%type) IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.INITIAL_COMPLETION_DURATION
        , b.INITIAL_COMPL_DURATION_UNITS
        , b.RENEWAL_DURATION
        , b.RENEWAL_DURATION_UNITS
        , b.NOTIFY_DAYS_BEFORE_EXPIRE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.RENEWABLE_FLAG
        , b.VALIDITY_START_TYPE
        , b.PUBLIC_FLAG
        , b.START_DATE_ACTIVE
        , b.END_DATE_ACTIVE
from ota_certifications_b b
where b.certification_id = p_certification_id;

CURSOR csr_cert_mbr(p_certification_id in ota_cert_enrollments.certification_id%type) IS
select
  cmb.CERTIFICATION_MEMBER_ID
, cmb.CERTIFICATION_ID
, cmb.OBJECT_ID
, cmb.OBJECT_TYPE
, cmb.MEMBER_SEQUENCE
, cmb.START_DATE_ACTIVE
, cmb.END_DATE_ACTIVE
 from ota_certification_members cmb
where cmb.certification_id = p_certification_id
and trunc(sysdate) between trunc(cmb.START_DATE_ACTIVE) and nvl(trunc(cmb.end_date_active), to_date('4712/12/31', 'YYYY/MM/DD'));

CURSOR csr_cert_enrl IS
select certification_id, cert_enrollment_id, business_group_id, certification_status_code,
object_version_number, completion_date, expiration_date
FROM ota_cert_enrollments
where cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_prd_enrl(csr_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) IS
select period_status_code, object_version_number, completion_date
FROM ota_cert_prd_enrollments
where cert_prd_enrollment_id = csr_cert_prd_enrollment_id;

Cursor one_child_active(l_cert_prd_enrollment_id in number) IS
Select cme.cert_mbr_enrollment_id
  from ota_cert_mbr_enrollments cme
 where member_status_code in ('ACTIVE', 'COMPLETED')
   and cert_prd_enrollment_id = l_cert_prd_enrollment_id and rownum=1;

CURSOR csr_prd_enrl_count IS
select count(cert_prd_enrollment_id)
FROM ota_cert_prd_enrollments
where cert_enrollment_id = p_cert_enrollment_id;

Cursor get_mbr_completion_date(l_cert_prd_enrollment_id in number) is
Select min(cme.completion_date)
  from ota_cert_mbr_enrollments cme
 where member_status_code = 'COMPLETED'
   and cert_prd_enrollment_id = l_cert_prd_enrollment_id;
l_proc    varchar2(72) := g_package || ' create_cpe_rec';
l_cert_rec csr_cert_info%ROWTYPE;
l_cert_mbr_rec csr_cert_mbr%ROWTYPE;
l_cert_enrl_rec csr_cert_enrl%ROWTYPE;
l_prd_enrl_rec csr_prd_enrl%ROWTYPE;

l_complete_cert_prd_ok VARCHAR2(30);

l_period_status_code VARCHAR2(30);
n_period_status_code VARCHAR2(30);

l_object_version_number1 number;
l_object_version_number2 number;

l_completion_date DATE;
l_prd_completion_date DATE;
l_cert_prd_enrollment_id NUMBER;
l_cert_mbr_enrollment_id NUMBER;

l_period_start_date DATE;
l_period_end_date DATE;

l_expiration_date DATE;
l_earliest_enroll_date DATE;

p_effective_date DATE;
p_business_group_id DATE;

l_certification_status_code VARCHAR2(30);
p_is_history_flag VARCHAR2(1);

l_attribute_category VARCHAR2(30) := NULL;
l_attribute1 VARCHAR2(150) := NULL;
l_attribute2 VARCHAR2(150) := NULL;
l_attribute3 VARCHAR2(150) := NULL;
l_attribute4 VARCHAR2(150) := NULL;
l_attribute5 VARCHAR2(150) := NULL;
l_attribute6 VARCHAR2(150) := NULL;
l_attribute7 VARCHAR2(150) := NULL;
l_attribute8 VARCHAR2(150) := NULL;
l_attribute9 VARCHAR2(150) := NULL;
l_attribute10 VARCHAR2(150) := NULL;
l_attribute11 VARCHAR2(150) := NULL;
l_attribute12 VARCHAR2(150) := NULL;
l_attribute13 VARCHAR2(150) := NULL;
l_attribute14 VARCHAR2(150) := NULL;
l_attribute15 VARCHAR2(150) := NULL;
l_attribute16 VARCHAR2(150) := NULL;
l_attribute17 VARCHAR2(150) := NULL;
l_attribute18 VARCHAR2(150) := NULL;
l_attribute19 VARCHAR2(150) := NULL;
l_attribute20 VARCHAR2(150) := NULL;

l_prd_enrl_count NUMBER;

BEGIN

       OPEN csr_cert_enrl;
       FETCH csr_cert_enrl INTO l_cert_enrl_rec;
       CLOSE csr_cert_enrl;

       l_certification_status_code := l_cert_enrl_rec.certification_status_code;
       l_expiration_date := l_cert_enrl_rec.expiration_date;

      OPEN csr_cert_info(l_cert_enrl_rec.certification_id);
      FETCH csr_cert_info INTO l_cert_rec;
      CLOSE csr_cert_info;

      --initialize period status to ENROLLED
      l_period_status_code := 'ENROLLED';


          --create CPE and CME based on approval mode is off or enrl approval is granted success;


             --calculate period end date
             --l_period_end_date := trunc(sysdate) + get_next_prd_dur_days(p_cert_enrollment_id);
             l_period_end_date := trunc(p_cert_period_start_date) + get_next_prd_dur_days(p_cert_enrollment_id, p_cert_period_start_date);

             /*
             if (l_cert_rec.initial_completion_date is not null) then
                 l_period_end_date := trunc(l_cert_rec.initial_completion_date);
             elsif (l_cert_rec.initial_completion_duration is not null) then
                 l_period_end_date := trunc(sysdate) + l_cert_rec.initial_completion_duration - 1;
             end if;
             */
             ota_utility.Get_Default_Value_Dff(
					   appl_short_name => 'OTA'
                      ,flex_field_name => 'OTA_CERT_PRD_ENROLLMENTS'
                       ,p_attribute_category           => l_attribute_category
                      ,p_attribute1                   => l_attribute1
					  ,p_attribute2                   => l_attribute2
					  ,p_attribute3                   => l_attribute3
					  ,p_attribute4                   => l_attribute4
					  ,p_attribute5                   => l_attribute5
					  ,p_attribute6                   => l_attribute6
					  ,p_attribute7                   => l_attribute7
					  ,p_attribute8                   => l_attribute8
					  ,p_attribute9                   => l_attribute9
					  ,p_attribute10                  => l_attribute10
					  ,p_attribute11                  => l_attribute11
					  ,p_attribute12                  => l_attribute12
					  ,p_attribute13                  => l_attribute13
					  ,p_attribute14                  => l_attribute14
					  ,p_attribute15                  => l_attribute15
					  ,p_attribute16                  => l_attribute16
					  ,p_attribute17                  => l_attribute17
					  ,p_attribute18                  => l_attribute18
					  ,p_attribute19                  => l_attribute19
					  ,p_attribute20                  => l_attribute20);

             ota_cert_prd_enrollment_api.create_cert_prd_enrollment(
               p_effective_date => trunc(sysdate)
    	      ,p_cert_enrollment_id => p_cert_enrollment_id
        	  ,p_period_status_code => l_period_status_code
              ,p_cert_period_start_date => trunc(p_cert_period_start_date) --trunc(sysdate)
              ,p_cert_period_end_date => l_period_end_date
              ,p_business_group_id => l_cert_enrl_rec.business_group_id
              ,p_expiration_date => p_expiration_date
        	  ,p_cert_prd_enrollment_id => l_cert_prd_enrollment_id
              ,p_object_version_number => l_object_version_number1
               ,p_attribute_category           => l_attribute_category
                      ,p_attribute1                   => l_attribute1
					  ,p_attribute2                   => l_attribute2
					  ,p_attribute3                   => l_attribute3
					  ,p_attribute4                   => l_attribute4
					  ,p_attribute5                   => l_attribute5
					  ,p_attribute6                   => l_attribute6
					  ,p_attribute7                   => l_attribute7
					  ,p_attribute8                   => l_attribute8
					  ,p_attribute9                   => l_attribute9
					  ,p_attribute10                  => l_attribute10
					  ,p_attribute11                  => l_attribute11
					  ,p_attribute12                  => l_attribute12
					  ,p_attribute13                  => l_attribute13
					  ,p_attribute14                  => l_attribute14
					  ,p_attribute15                  => l_attribute15
					  ,p_attribute16                  => l_attribute16
					  ,p_attribute17                  => l_attribute17
					  ,p_attribute18                  => l_attribute18
					  ,p_attribute19                  => l_attribute19
					  ,p_attribute20                  => l_attribute20
        	  );

l_attribute_category := NULL;
    l_attribute1  := NULL;
l_attribute2  := NULL;
l_attribute3  := NULL;
l_attribute4  := NULL;
l_attribute5  := NULL;
l_attribute6  := NULL;
l_attribute7  := NULL;
l_attribute8  := NULL;
l_attribute9  := NULL;
l_attribute10  := NULL;
l_attribute11  := NULL;
l_attribute12  := NULL;
l_attribute13  := NULL;
l_attribute14  := NULL;
l_attribute15  := NULL;
l_attribute16  := NULL;
l_attribute17  := NULL;
l_attribute18  := NULL;
l_attribute19  := NULL;
l_attribute20  := NULL;

             ota_utility.Get_Default_Value_Dff(
					   appl_short_name => 'OTA'
                      ,flex_field_name => 'OTA_CERT_MBR_ENROLLMENTS'
                      ,p_attribute_category           => l_attribute_category
                      ,p_attribute1                   => l_attribute1
					  ,p_attribute2                   => l_attribute2
					  ,p_attribute3                   => l_attribute3
					  ,p_attribute4                   => l_attribute4
					  ,p_attribute5                   => l_attribute5
					  ,p_attribute6                   => l_attribute6
					  ,p_attribute7                   => l_attribute7
					  ,p_attribute8                   => l_attribute8
					  ,p_attribute9                   => l_attribute9
					  ,p_attribute10                  => l_attribute10
					  ,p_attribute11                  => l_attribute11
					  ,p_attribute12                  => l_attribute12
					  ,p_attribute13                  => l_attribute13
					  ,p_attribute14                  => l_attribute14
					  ,p_attribute15                  => l_attribute15
					  ,p_attribute16                  => l_attribute16
					  ,p_attribute17                  => l_attribute17
					  ,p_attribute18                  => l_attribute18
					  ,p_attribute19                  => l_attribute19
					  ,p_attribute20                  => l_attribute20);
             FOR l_cert_mbr_rec IN csr_cert_mbr(l_cert_enrl_rec.certification_id) LOOP
              ota_cert_mbr_enrollment_api.create_cert_mbr_enrollment(
     	      p_effective_date => trunc(sysdate)
    	     ,p_cert_prd_enrollment_id => l_cert_prd_enrollment_id
    	     ,p_cert_member_id => l_cert_mbr_rec.certification_member_id
    	     ,p_member_status_code => 'PLANNED'
    	     ,p_business_group_id => l_cert_enrl_rec.business_group_id
    	     ,p_cert_mbr_enrollment_id => l_cert_mbr_enrollment_id
                ,p_object_version_number => l_object_version_number2
                ,p_attribute_category           => l_attribute_category
                      ,p_attribute1                   => l_attribute1
					  ,p_attribute2                   => l_attribute2
					  ,p_attribute3                   => l_attribute3
					  ,p_attribute4                   => l_attribute4
					  ,p_attribute5                   => l_attribute5
					  ,p_attribute6                   => l_attribute6
					  ,p_attribute7                   => l_attribute7
					  ,p_attribute8                   => l_attribute8
					  ,p_attribute9                   => l_attribute9
					  ,p_attribute10                  => l_attribute10
					  ,p_attribute11                  => l_attribute11
					  ,p_attribute12                  => l_attribute12
					  ,p_attribute13                  => l_attribute13
					  ,p_attribute14                  => l_attribute14
					  ,p_attribute15                  => l_attribute15
					  ,p_attribute16                  => l_attribute16
					  ,p_attribute17                  => l_attribute17
					  ,p_attribute18                  => l_attribute18
					  ,p_attribute19                  => l_attribute19
					  ,p_attribute20                  => l_attribute20
                );
             END LOOP;

             -- verify the period cert enrol eligibility for marking complete
             l_complete_cert_prd_ok := chk_cert_prd_compl(p_cert_prd_enrollment_id => l_cert_prd_enrollment_id);

             IF l_complete_cert_prd_ok = 'S' THEN
                -- The Plan can be completed
                n_period_status_code := 'COMPLETED';
             ELSIF l_complete_cert_prd_ok = 'F' THEN
                --if atleast one child is in ACTIVE or COMPLETED, mark the parent cpe as ACTIVE
                   open one_child_active(l_cert_prd_enrollment_id);
                   fetch one_child_active into l_cert_mbr_enrollment_id;
                   if one_child_active%found then
                       n_period_status_code := 'ACTIVE';
                   end if;
                   close one_child_active;
             END IF;

             IF n_period_status_code <> l_period_status_code THEN

                  --update cpe and cre recs
                  if n_period_status_code = 'ACTIVE' THEN

                     -- Bug#7303995
                     open csr_prd_enrl_count;
                     fetch csr_prd_enrl_count into l_prd_enrl_count;
                     close csr_prd_enrl_count;

                     if(l_prd_enrl_count > 1 and p_is_recert = 'N') then
                        l_certification_status_code := 'RENEWING';
                     else
                        l_certification_status_code := 'ENROLLED'; --Bug#7005319
                     end if;

                     l_expiration_date := p_expiration_date;
                     --donot reset the existing certification status code if its not completed
                     --l_certification_status_code := l_cert_enrl_rec.certification_status_code;
                     --dont reset to null on renewal cert prd
                     l_prd_completion_date := null;
                     l_completion_date := l_cert_enrl_rec.completion_date;
                  elsif n_period_status_code = 'COMPLETED' THEN
                     --cert enrol overall status code
                     l_certification_status_code := 'CERTIFIED';
                     open get_mbr_completion_date(l_cert_prd_enrollment_id);
                     fetch get_mbr_completion_date into l_prd_completion_date;
                     close get_mbr_completion_date;

                     l_prd_completion_date := trunc(nvl(l_prd_completion_date, sysdate));
                     l_completion_date := l_prd_completion_date;
                  end if;


                  OPEN csr_prd_enrl(l_cert_prd_enrollment_id);
                  FETCH csr_prd_enrl INTO l_prd_enrl_rec;
                  CLOSE csr_prd_enrl;

    	          ota_cert_prd_enrollment_api.update_cert_prd_enrollment
                           (p_effective_date => trunc(sysdate)
                           ,p_cert_enrollment_id           => p_cert_enrollment_id
                           ,p_cert_prd_enrollment_id       => l_cert_prd_enrollment_id
                           ,p_object_version_number        => l_prd_enrl_rec.object_version_number
                           ,p_period_status_code           => n_period_status_code
                           ,p_completion_date              => l_prd_completion_date);


                  --update cre only if its already CERTIFIED on renew actn
                  -- if l_certification_status_code = 'CERTIFIED' then
    	             ota_cert_enrollment_api.update_cert_enrollment
                           (p_effective_date => trunc(sysdate)
                           ,p_cert_enrollment_id           => p_cert_enrollment_id
                           ,p_certification_id             => l_cert_enrl_rec.certification_id
                           ,p_object_version_number        => l_cert_enrl_rec.object_version_number
                           ,p_certification_status_code    => l_certification_status_code
   	       		   ,p_is_history_flag              => 'N'
                           ,p_completion_date              => l_completion_date
                           ,p_expiration_date              => l_expiration_date);
                  -- end if;

         end if; -- status code check

         --set output params
         p_cert_prd_enrollment_id := l_cert_prd_enrollment_id;
         p_certification_status_code := l_certification_status_code;

EXCEPTION
WHEN others THEN
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_cert_prd_enrollment_id := null;
    p_certification_status_code := null;
    hr_utility.set_location(' Leaving:' || l_proc,50);
    raise;
end create_cpe_rec;

PROCEDURE delete_prd_cascade(p_cert_prd_enrollment_id IN ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                             p_return_code OUT NOCOPY varchar2) IS

      CURSOR csr_attempt IS
      SELECT attempt_id
       FROM ota_attempts
       WHERE cert_prd_enrollment_id = p_cert_prd_enrollment_id
       FOR UPDATE;

      CURSOR csr_scorm_attempt(p_attempt_id ota_attempts.attempt_id%type) IS
      SELECT objective_id
      FROM OTA_SCORM_OBJ_ATTEMPTS
      WHERE attempt_id = p_attempt_id
      FOR UPDATE;

      CURSOR csr_utest_ques(p_attempt_id ota_attempts.attempt_id%type) IS
      SELECT USER_TEST_QUESTION_ID
       FROM OTA_UTEST_QUESTIONS
       WHERE attempt_id = p_attempt_id
       FOR UPDATE;

       l_return_code varchar2(1) := 'S';

   BEGIN
              --Delete attempt dependent scorm attempts and scorm performances
              FOR attempt_rec IN csr_attempt
              LOOP
                   --Delete scorm performances for the passed objective_id
                   FOR scorm_attempt_rec IN csr_scorm_attempt(attempt_rec.attempt_id)
                   LOOP
                   DELETE FROM OTA_SCORM_OBJ_PERFS
                   WHERE objective_id = scorm_attempt_rec.objective_id;

                   --Delete the fetched scorm attempt
                   DELETE FROM OTA_SCORM_OBJ_ATTEMPTS
                   WHERE CURRENT OF csr_scorm_attempt;
                   END LOOP;

		   --Delete attempt specific test data, OTA_UTEST_QUESTIONS
		   --OTA_UTEST_RESPONSES
		   FOR utest_ques_rec IN csr_utest_ques(attempt_rec.attempt_id)
		   LOOP
		     --for each utest ques delete utest responses
		     DELETE FROM OTA_UTEST_RESPONSES
		      WHERE USER_TEST_QUESTION_ID = utest_ques_rec.USER_TEST_QUESTION_ID;

		     --Delete the fetched utest ques record
		     DELETE FROM OTA_UTEST_QUESTIONS
		     WHERE CURRENT OF csr_utest_ques;

		   END LOOP;

		   --Delete the fetched attempt record
		   DELETE FROM OTA_ATTEMPTS
		   WHERE CURRENT OF csr_attempt;

              END LOOP;

	      --delete cert prd performance
              DELETE FROM ota_performances
               WHERE cert_prd_enrollment_id = p_cert_prd_enrollment_id;

	      --delete cert mbr enrollments
              DELETE FROM ota_cert_mbr_enrollments where cert_prd_enrollment_id = p_cert_prd_enrollment_id;

              --delete cert prd enrollments
              DELETE FROM ota_cert_prd_enrollments where cert_prd_enrollment_id = p_cert_prd_enrollment_id;

              p_return_code := l_return_code;
EXCEPTION
WHEN others THEN
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_code := 'E';
END delete_prd_cascade;

procedure update_admin_changes(p_cert_enrollment_id in ota_cert_prd_enrollments.cert_enrollment_id%type,
            			       p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                               p_certification_status_code in ota_cert_enrollments.certification_status_code%type,
            			       p_cert_period_end_date   in ota_cert_prd_enrollments.cert_period_end_date%type default null,
                               p_return_status out NOCOPY VARCHAR2,
                               p_cert_period_completion_date   in ota_cert_prd_enrollments.completion_date%type default trunc(sysdate) ) is

CURSOR csr_cert_enrl IS
select cre.certification_status_code, cre.object_version_number, cre.completion_date,
cre.certification_id,
cre.person_id,
cre.expiration_date
FROM ota_cert_enrollments cre
where cre.cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_prd_enrl IS
select period_status_code, object_version_number, completion_date, cert_enrollment_id, cert_period_start_date, cert_period_end_date
FROM ota_cert_prd_enrollments
where cert_prd_enrollment_id = p_cert_prd_enrollment_id;

l_proc    varchar2(72) := g_package || ' update_admin_changes';
l_cert_enrl_rec csr_cert_enrl%ROWTYPE;
l_prd_enrl_rec csr_prd_enrl%ROWTYPE;
l_return_status varchar2(1) := 'F';
l_new_cre_status_code varchar2(30);
l_new_cpe_status_code varchar2(30);
l_cert_period_end_date  ota_cert_prd_enrollments.cert_period_end_date%type;
l_curr_date date;
l_certification_status_code  varchar2(30);
l_is_period_update boolean := false;
l_cert_period_completion_date   ota_cert_prd_enrollments.completion_date%type;
Begin

       hr_utility.set_location(' Entering:' || l_proc,10);

       OPEN csr_prd_enrl;
       FETCH csr_prd_enrl INTO l_prd_enrl_rec;
       CLOSE csr_prd_enrl;

       if p_cert_prd_enrollment_id is not null then
         l_is_period_update := true;
       else
         l_is_period_update := false;
       end if;

       if p_cert_period_end_date is not null and p_cert_period_end_date <> l_prd_enrl_rec.cert_period_end_date then
          l_cert_period_end_date := p_cert_period_end_date;
       else
          l_cert_period_end_date := l_prd_enrl_rec.cert_period_end_date;
       end if;

       if (p_certification_status_code is not null and p_certification_status_code = 'EXPIRED') then
           --certSubscriptRowVO.setCertificationStatusCode(newCertStatus);
           --certSubscriptRowVO.setPeriodStatusCode(newCertStatus);
    	   l_new_cre_status_code := 'EXPIRED';
           l_new_cpe_status_code := 'EXPIRED';

    	   OPEN csr_cert_enrl;
           FETCH csr_cert_enrl INTO l_cert_enrl_rec;
           CLOSE csr_cert_enrl;

           ota_cert_enrollment_api.update_cert_enrollment
                   (p_effective_date               => trunc(sysdate)
                   ,p_cert_enrollment_id           => p_cert_enrollment_id
                   ,p_certification_id             => l_cert_enrl_rec.certification_id
                   ,p_object_version_number        => l_cert_enrl_rec.object_version_number
                   ,p_certification_status_code    => l_new_cre_status_code);

           if l_is_period_update then
               OPEN csr_prd_enrl;
               FETCH csr_prd_enrl INTO l_prd_enrl_rec;
               CLOSE csr_prd_enrl;

               ota_cert_prd_enrollment_api.update_cert_prd_enrollment
                           (p_effective_date               => trunc(sysdate)
                           ,p_cert_enrollment_id           => p_cert_enrollment_id
                           ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
                           ,p_object_version_number        => l_prd_enrl_rec.object_version_number
                           ,p_period_status_code           => l_new_cpe_status_code
                           ,p_cert_period_end_date         => l_cert_period_end_date);
           end if;
       elsif (p_certification_status_code is not null and p_certification_status_code = 'CERTIFIED') then
              --certSubscriptRowVO.setCertificationStatusCode(newCertStatus);
              --certSubscriptRowVO.setPeriodStatusCode("COMPLETED");
              --//reset the completion date
              --certSubscriptRowVO.setCpeCompletionDate(this.getOADBTransaction().getCurrentDBDate());

          if(p_cert_period_completion_date is null) then
            l_cert_period_completion_date := trunc(sysdate);
          else
            l_cert_period_completion_date := p_cert_period_completion_date;
          end if;
          if (p_cert_period_completion_date < l_prd_enrl_rec.cert_period_start_date or trunc(p_cert_period_completion_date) > trunc(sysdate))  then
           	p_return_status  := 'OTA_467120_CPE_PRD_CMPL_DT_ERR';
        	return;
          end if;

	       l_new_cre_status_code := 'CERTIFIED';
	       l_new_cpe_status_code := 'COMPLETED';
           l_curr_date := trunc(sysdate);

    	   OPEN csr_cert_enrl;
           FETCH csr_cert_enrl INTO l_cert_enrl_rec;
           CLOSE csr_cert_enrl;

           ota_cert_enrollment_api.update_cert_enrollment
                   (p_effective_date               => trunc(sysdate)
                   ,p_cert_enrollment_id           => p_cert_enrollment_id
                   ,p_certification_id             => l_cert_enrl_rec.certification_id
                   ,p_object_version_number        => l_cert_enrl_rec.object_version_number
                   ,p_certification_status_code    => l_new_cre_status_code
                   ,p_completion_date              => l_cert_period_completion_date);

           if l_is_period_update then
               OPEN csr_prd_enrl;
               FETCH csr_prd_enrl INTO l_prd_enrl_rec;
               CLOSE csr_prd_enrl;

               ota_cert_prd_enrollment_api.update_cert_prd_enrollment
                       (p_effective_date               => trunc(sysdate)
                       ,p_cert_enrollment_id           => p_cert_enrollment_id
                       ,p_cert_prd_enrollment_id       => p_cert_prd_enrollment_id
                       ,p_object_version_number        => l_prd_enrl_rec.object_version_number
                       ,p_period_status_code           => l_new_cpe_status_code
                       ,p_cert_period_end_date         => l_cert_period_end_date
    		   ,p_completion_date              => l_cert_period_completion_date);
            end if;
       elsif (p_certification_status_code is not null and p_certification_status_code = 'ENROLLED') then
              --//re-populate the prd status by calling ota_cpe_util.update_cpe_status
              --//which also sets the cre status
              --rePopulateCertStatuses(certPrdEnrollmentId);
           if l_is_period_update then
              update_cpe_status(p_cert_prd_enrollment_id, l_certification_status_code, null, p_cert_period_end_date);
           else
               l_new_cre_status_code := 'ENROLLED';

               OPEN csr_cert_enrl;
               FETCH csr_cert_enrl INTO l_cert_enrl_rec;
               CLOSE csr_cert_enrl;

               ota_cert_enrollment_api.update_cert_enrollment
                       (p_effective_date               => trunc(sysdate)
                       ,p_cert_enrollment_id           => p_cert_enrollment_id
                       ,p_certification_id             => l_cert_enrl_rec.certification_id
                       ,p_object_version_number        => l_cert_enrl_rec.object_version_number
                       ,p_certification_status_code    => l_new_cre_status_code
                       ,p_unenrollment_date            => null);
           end if;
       elsif (p_certification_status_code is null and l_is_period_update) then
           --mass update scrn with just due date chg
           update_cpe_status(p_cert_prd_enrollment_id, l_certification_status_code, null, p_cert_period_end_date);
       end if;

       l_return_status := 'S';

       p_return_status := l_return_status;

       hr_utility.set_location('Leaving :'||l_proc,20);

EXCEPTION
WHEN others THEN
      hr_utility.set_location('Leaving :'||l_proc,30);
      p_return_status := null;
End update_admin_changes;
--
--
-- Bug 4701515
Procedure update_cert_status_to_expired(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2) is

l_proc 	varchar2(72) := g_package || ' update_cert_status_to_expired';

--get all enrollment records in last period for expiry status updation
cursor get_data_for_expiry_status_upd is
Select ceb.certification_id
      ,ceb.name
      ,enr.cert_enrollment_id
      ,enr.person_id
      ,enr.contact_id
      ,prd.cert_prd_enrollment_id
      ,prd.period_status_code
      ,prd.cert_period_end_date
      ,prd.object_version_number
From ota_certifications_vl ceb
    ,ota_cert_enrollments enr
    ,ota_cert_prd_enrollments prd
Where
    ceb.certification_id = enr.certification_id
    and enr.cert_enrollment_id = prd.cert_enrollment_id
    and trunc(sysdate) between nvl(trunc(ceb.start_date_active), trunc(sysdate)) and
        nvl(trunc(ceb.end_date_active), trunc(sysdate))
    and prd.period_status_code in ('ACTIVE', 'ENROLLED', 'INCOMPLETE');

cursor get_data_for_expired_records(p_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) is
Select ceb.certification_id
      ,ceb.name
      ,enr.cert_enrollment_id
      ,enr.person_id
      ,enr.contact_id
      ,prd.cert_prd_enrollment_id
      ,enr.certification_status_code
      ,enr.expiration_date
      ,prd.period_status_code
      ,prd.cert_period_end_date
      ,ceb.initial_completion_date
      ,enr.object_version_number
From ota_certifications_vl ceb
    ,ota_cert_enrollments enr
    ,ota_cert_prd_enrollments prd
Where
    ceb.certification_id = enr.certification_id
    and enr.cert_enrollment_id = prd.cert_enrollment_id
    and trunc(sysdate) between nvl(trunc(ceb.start_date_active), trunc(sysdate))
    and nvl(trunc(ceb.end_date_active), trunc(sysdate))
    and enr.certification_status_code in ('ENROLLED', 'CERTIFIED', 'RENEWING') -- Bug#7303995
    --check if this is max/latest prd then update CRE accordingly
    and prd.cert_prd_enrollment_id = (select max(cpex.cert_prd_enrollment_id)
				      from ota_cert_prd_enrollments cpex
				      where cpex.cert_enrollment_id = enr.cert_enrollment_id
				      and trunc(cpex.cert_period_end_date) < trunc(sysdate)
				      )
    and prd.cert_prd_enrollment_id = p_cert_prd_enrollment_id;

l_log_message varchar2(500);

begin
 hr_utility.set_location('Entering:'||l_proc, 5);

 for exp_sts_upd in get_data_for_expiry_status_upd
 Loop
	if ( trunc(exp_sts_upd.cert_period_end_date) < trunc(sysdate) ) then
	begin
		hr_utility.set_location('Entering:'||l_proc, 10);
		savepoint update_status_to_expired;

		--Update Period CPE status to Expired
		ota_cert_prd_enrollment_api.update_cert_prd_enrollment(
				p_effective_date => trunc(sysdate),
				p_cert_prd_enrollment_id => exp_sts_upd.cert_prd_enrollment_id,
				p_object_version_number => exp_sts_upd.object_version_number,
				p_cert_enrollment_id => exp_sts_upd.cert_enrollment_id,
				p_period_status_code => 'EXPIRED');

		l_log_message := 'Updating period status code to Expired for Certification ' ||
				exp_sts_upd.name || '(' || exp_sts_upd.certification_id || ')' ||
				', subscription id ' || exp_sts_upd.cert_enrollment_id ||
				', period subscription id ' || exp_sts_upd.cert_prd_enrollment_id ||
				', period end date ' || exp_sts_upd.cert_period_end_date;
		if (exp_sts_upd.person_id is not null) then
			l_log_message := l_log_message || ' for person id ' || exp_sts_upd.person_id;
		else
			l_log_message := l_log_message || ' for contact id ' || exp_sts_upd.contact_id;
		end if;

		FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_message);

		--Update Cert CRE status to Expired
		for exp_records in get_data_for_expired_records(exp_sts_upd.cert_prd_enrollment_id)
		Loop
			--if condition to consider bug 4642943
			if ( ( exp_records.expiration_date is not null and
				trunc(sysdate) > trunc(exp_records.expiration_date) )
				or exp_records.initial_completion_date is not null) then

				--Update CRE status to Expired
				ota_cert_enrollment_api.update_cert_enrollment(
						p_effective_date => trunc(sysdate),
						p_cert_enrollment_id => exp_records.cert_enrollment_id,
						p_certification_id => exp_records.certification_id,
						p_object_version_number => exp_records.object_version_number,
						p_certification_status_code => 'EXPIRED');

				l_log_message := 'Updating subscription status code to Expired for Certification ' ||
						exp_records.name || '(' || exp_records.certification_id || ')' ||
						', subscription id ' || exp_records.cert_enrollment_id;

				if (exp_records.person_id is not null) then
					l_log_message := l_log_message || ' for person id ' || exp_records.person_id;
				else
					l_log_message := l_log_message || ' for contact id ' || exp_records.contact_id;
				end if;
				FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_message);
			end if;
		End Loop;
		EXCEPTION
		WHEN OTHERS then
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'When Others Error occured in, '
			|| 'Update to cpe cre calls ,' || 'Cert_Prd_Enrollment_Id=' || to_char(exp_sts_upd.cert_prd_enrollment_id)
			||',' || 'Cert_Enrollment_Id=' || to_char(exp_sts_upd.cert_enrollment_id)
			|| ',' || SUBSTR(SQLERRM, 1, 500));

			ROLLBACK TO update_status_to_expired;
	end;
	end if;
 End Loop;

 commit;
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Data committed to database');
 hr_utility.set_location('Leaving:'||l_proc, 5);
 EXCEPTION
	when others then
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
end update_cert_status_to_expired;
--
Procedure sync_cert_status_to_class_enrl(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2) is

l_proc 	varchar2(72) := g_package || ' sync_cert_status_to_class_enrl';

cursor csr_cpe_status is
select cpe.cert_prd_enrollment_id,
       cpe.period_status_code,
       cpe.cert_period_start_date
  from ota_cert_prd_enrollments cpe,
       ota_cert_enrollments cre
  where cpe.period_status_code not in ('COMPLETED', 'CANCELLED') and
        cpe.cert_enrollment_id = cre.cert_enrollment_id  --bug#6338987
 order by cre.certification_id;

cursor csr_acty_info(p_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type)

is
select cme.cert_mbr_enrollment_id,
       cmb.object_id
  from ota_cert_mbr_enrollments cme,
       ota_certification_members cmb
  where cme.cert_prd_enrollment_id = p_cert_prd_enrollment_id
    and cme.cert_member_id = cmb.certification_member_id
    and object_type = 'H';

  l_booking_status_type          ota_booking_status_types.type%TYPE;
  l_date_status_changed  ota_delegate_bookings.date_status_changed%TYPE;
  do_update boolean := false;
  l_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE;

begin

 hr_utility.set_location('Entering:'||l_proc, 5);

 sync_late_subsc_to_class;

for rec_cpe_status in csr_cpe_status
loop
 hr_utility.set_location('Step:'||l_proc, 10);
    for rec_acty_info in csr_acty_info(rec_cpe_status.cert_prd_enrollment_id)
	loop
	 hr_utility.set_location('Step:'||l_proc, 10.1);
	 -- get latest class enrollment status
         ota_cme_util.get_enrl_status_on_update(rec_acty_info.object_id,
				   rec_cpe_status.cert_prd_enrollment_id,
                                   l_booking_status_type,
				   l_date_status_changed);

	-- if l_booking_status_type is 'A' then bypass update for EXPIRED periods for COMPLETED child status
	if l_booking_status_type = 'A' then
	   if rec_cpe_status.period_status_code <> 'EXPIRED' then
              if trunc(l_date_status_changed) = trunc(rec_cpe_status.cert_period_start_date) then
                 --scenarios 1 and 2
                 -- for 'Attended' class enroll status perform status rollup for CURRENT CPE
     	         hr_utility.set_location('Step:'||l_proc, 10.2);
	         do_update := true;
              end if;
           end if;
        else
           --scenarios 3 and 4
           -- for any class enroll status changes this would update child of EXPIRED CPE and status rollup for CURRENT CPE
       hr_utility.set_location('Step:'||l_proc, 10.3);
	       do_update := true;
	end if;
	    if do_update then
           ota_cme_util.update_cme_status(rec_acty_info.cert_mbr_enrollment_id);
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updated the Certification member status for the cert_mbr_enrollment_id = ' || rec_acty_info.cert_mbr_enrollment_id);
           ota_cme_util.update_cpe_status(rec_acty_info.cert_mbr_enrollment_id, l_cert_prd_enrollment_id, trunc(l_date_status_changed));
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Updated the Certification period status for the cert_prd_enrollment_id = ' || l_cert_prd_enrollment_id);
	    end if;
        do_update :=  false;
        end loop;
end loop;

 hr_utility.set_location('Entering:'||l_proc, 20);

commit;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Data committed to database');

 hr_utility.set_location('Leaving:'||l_proc, 30);

EXCEPTION
    when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
end sync_cert_status_to_class_enrl;
--
FUNCTION get_latest_cpe_col(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%TYPE,
                         p_col_name in varchar2 default 'Period_Status_Meaning')
RETURN varchar2 is

Cursor csr_latest_cpe is
Select cpe.period_status_code Period_Status_Code,
       ota_utility.get_lookup_meaning('OTA_CERT_PRD_ENROLL_STATUS', cpe.period_status_code, 810) Period_Status_Meaning,
       cpe.cert_prd_enrollment_id
From ota_cert_prd_enrollments cpe
where cpe.cert_enrollment_id = p_cert_enrollment_id
  -- and rownum = 1 --Bug#6356854
 order by cpe.cert_prd_enrollment_id desc;

l_proc VARCHAR2(72) := g_package||' get_latest_cpe_col';
rec_latest_cpe csr_latest_cpe%rowtype;

Begin
 hr_utility.set_location('Entering:'||l_proc, 5);

	open csr_latest_cpe;
	fetch csr_latest_cpe into rec_latest_cpe;
	close csr_latest_cpe;

        hr_utility.set_location('Leaving:'||l_proc, 10);

        if upper(p_col_name) = upper('Cert_Prd_Enrollment_Id') then
           return rec_latest_cpe.Cert_Prd_Enrollment_id;
        elsif upper(p_col_name) = upper('Period_Status_Code') then
           return rec_latest_cpe.Period_Status_Code;
        else
           return rec_latest_cpe.Period_Status_Meaning;
        end if;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN null;

End get_latest_cpe_col;

function get_elapsed_due_date(p_certification_id ota_certifications_b.certification_id%type) return date is
CURSOR csr_crt IS
select
          b.certification_id certification_id
        , b.INITIAL_COMPLETION_DATE
        , b.VALIDITY_DURATION
        , b.VALIDITY_DURATION_UNITS
        , b.renewable_flag
from ota_certifications_b b
where b.certification_id = p_certification_id;


l_proc VARCHAR2(72) := g_package||' get_elapsed_due_date';
rec_crt csr_crt%rowtype;

l_elapsed_due_date date;
l_curr_dt date;

BEGIN

    hr_utility.set_location('Entering :'||l_proc,5);

    l_curr_dt := trunc(sysdate);

    OPEN csr_crt;
    FETCH csr_crt INTO rec_crt;
    CLOSE csr_crt;

    if (rec_crt.RENEWABLE_FLAG is null or rec_crt.RENEWABLE_FLAG = 'N') then
       return null;
    end if;

    if  trunc(rec_crt.initial_completion_date) < l_curr_dt then
    --elapsed due date for late subscr
	  l_elapsed_due_date := trunc(rec_crt.initial_completion_date);
       LOOP
	  l_elapsed_due_date := l_elapsed_due_date + rec_crt.validity_duration;
	  EXIT WHEN l_curr_dt < l_elapsed_due_date;
       end loop;
    end if;

    hr_utility.set_location('Leaving :'||l_proc,10);

return l_elapsed_due_date;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN NULL;
end get_elapsed_due_date;

function check_active_periods(p_event_id ota_events.event_id%type) return varchar2
is
cursor csr_onl_sync_flag is
select csu.online_flag,
       csu.synchronous_flag,
       ofr.offering_id
 from  ota_category_usages csu,
       ota_offerings ofr,
       ota_events evt
where evt.event_id = p_event_id
  and evt.parent_offering_id = ofr.offering_id
  and ofr.delivery_mode_id = csu.category_usage_id;

cursor csr_act_id(csr_offering_id number)  is
  select act.activity_version_id
  from ota_activity_versions act,
       ota_offerings ofr
  where ofr.offering_id = csr_offering_id
     and ofr.activity_version_id = act.activity_version_id;

CURSOR csr_chk_prds(l_activity_version_id  number) IS
SELECT null
  FROM ota_certification_members cmb,
       ota_cert_mbr_enrollments cme,
       ota_cert_prd_enrollments cpe,
       ota_cert_enrollments cre
 WHERE
        cre.cert_enrollment_id = cpe.cert_enrollment_id
    AND cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
    AND cme.cert_member_id = cmb.certification_member_id
    AND cmb.object_id = l_activity_version_id
    --pull only curr periods
    AND trunc(sysdate) between trunc(cpe.cert_period_start_date) and trunc(cpe.cert_period_end_date)
    -- don't consider expired or canc prds
    AND cpe.period_status_code not in ('COMPLETED','EXPIRED','CANCELLED');


l_proc   varchar2(72) := g_package||'check_active_periods' ;

rec_onl_sync_flag csr_onl_sync_flag%rowtype;

is_evt_onl_async boolean := false;
l_activity_version_id ota_activity_versions.activity_version_id%type;

l_return_value  varchar2(1) := 'N';

l_dummy varchar2(10);

Begin

hr_utility.set_location('Entering:'||l_proc, 10);

open csr_onl_sync_flag;
fetch csr_onl_sync_flag into rec_onl_sync_flag;
close csr_onl_sync_flag;

--is event online
if rec_onl_sync_flag.online_flag = 'Y' and rec_onl_sync_flag.synchronous_flag = 'N' then
   is_evt_onl_async := true;
end if;

if is_evt_onl_async then
   -- check dependencies on current period components.
   open csr_act_id(rec_onl_sync_flag.offering_id);
   fetch csr_act_id into l_activity_version_id;
   close csr_act_id;

   --for act check if any currently active periods exists with this course
   open csr_chk_prds(l_activity_version_id);
   fetch csr_chk_prds into l_dummy;
   if csr_chk_prds%found then
      l_return_value := 'Y';
   end if;
   close csr_chk_prds;

 end if;

 hr_utility.set_location('Leaving :'||l_proc, 30);

 return l_return_value;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,40);
     return l_return_value;
END check_active_periods;

/* Late Subscription or late renewal to certifications
How this procedure works
------------------------
1)Fetch all certifications which are
  a)renewable
  b)Active(sysdate between certification start and end date)
2)For each certification fetched in step 1, get all the course
  component details which are in PLANNED status(This is
  because the certification period start and end date will
  not be matched with previously completed class)
3)Iterate through all the courses fetched in step 2 and
  get all the classes in the course and
  get the class enrollment details for each class
  It will return result, if it staisfy the conditions
    a)If the class is scheduled class(online synchronous or
      offline synchronous),
        i) the latest certification (period start date - certification
           initial completion duration) should be less than
           or equal to class start date
        ii)the latest certification (period end date - certification
           initial completion duration) should be greater than
           or equal to class end date
    b)If the class is self paced class(online asynchronous or
      offline asynchronous),
        i) the class end date is null
                   or
           the latest certification (period start date - certification
           initial completion duration) should be less than
           or equal to class end date
        ii)the latest certification (period end date - certification
           initial completion duration) should be greater than
           or equal to class start date

4)If the step 3 returns any result, it further should satisfy the conditions
   a)Learner should be completed the class(booking_status_type = 'A') and
   b)(class completion date + certification initial completion duration)
     should be greater than or equal to certification period start date and
   c)class completion date should be less than certification period end date and
   d)class completion date should be between certification start and end date
5)If all the above condtions satisfied,
  take class completion date as new certification period start date
  and calculate certification period end date, expiry date, renewal date
  based on the certification period start date
6)update the new calculated dates

NOTE:This procedure will correct late subscription or late renewal
     only for internal employees. Contacts will not be cosidered
*/
procedure sync_late_subsc_to_class IS

l_proc 	varchar2(72) := g_package || ' sync_late_subsc_to_class';

CURSOR csr_cert_details IS
SELECT ocb.certification_id,
       ocb.name,
       ocb.start_date_active,
       nvl(ocb.end_date_active, to_date('4712/12/31','YYYY/MM/DD')) end_date_active,
       oce.enrollment_date,
       nvl(ocb.initial_completion_duration, (ocb.initial_completion_date - oce.enrollment_date)) initial_completion_duration,
       ocb.renewable_flag,
       ocb.validity_duration,
       oce.cert_enrollment_id,
       oce.person_id,
       oce.contact_id,
       ocpe.cert_prd_enrollment_id,
       ocpe.cert_period_start_date,
       ocpe.cert_period_end_date,
       ocpe.expiration_date
FROM ota_certifications_vl ocb, ota_cert_enrollments oce, ota_cert_prd_enrollments ocpe
WHERE ocb.certification_id = oce.certification_id
AND oce.cert_enrollment_id = ocpe.cert_enrollment_id
AND trunc(SYSDATE) BETWEEN trunc(ocb.start_date_active) AND trunc(nvl(ocb.end_date_active, SYSDATE))
AND ocb.renewable_flag = 'Y'
AND oce.person_id is not null
AND oce.certification_status_code <> 'CERTIFIED'
AND ocpe.period_status_code not in ('COMPLETED', 'CANCELLED')
AND ocpe.cert_prd_enrollment_id = (SELECT MAX(cert_prd_enrollment_id) FROM ota_cert_prd_enrollments ocpe1
                                   WHERE oce.cert_enrollment_id = ocpe1.cert_enrollment_id);

CURSOR csr_course_info(p_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) is
SELECT cme.cert_mbr_enrollment_id,
       cmb.object_id
FROM ota_cert_mbr_enrollments cme,
     ota_certification_members cmb
WHERE cme.cert_prd_enrollment_id = p_cert_prd_enrollment_id
AND cme.cert_member_id = cmb.certification_member_id
AND object_type = 'H'
AND member_status_code = 'PLANNED';

CURSOR get_enrl_status(csr_activity_version_id    IN ota_activity_versions.activity_version_id%TYPE,
                       csr_cert_period_start_date in ota_cert_prd_enrollments.cert_period_start_date%type,
                       csr_cert_period_end_date in ota_cert_prd_enrollments.cert_period_end_date%type,
                       csr_person_id in ota_cert_enrollments.person_id%TYPE,
                       csr_contact_id in ota_cert_enrollments.contact_id%TYPE) IS
SELECT DECODE(bst.type,'C','Z',bst.type) status,
       evt.event_type,
       tdb.DATE_STATUS_CHANGED,
       evt.COURSE_START_DATE,
       evt.COURSE_END_DATE
FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst
WHERE evt.event_id = tdb.event_id
AND bst.booking_status_type_id = tdb.booking_status_type_id
AND (
     --sync sched, online(conf) or offline(ILT)
     --sync always have an end date
     ( evt.event_type = 'SCHEDULED' and
        evt.course_start_date >= csr_cert_period_start_date and
          evt.course_end_date <= csr_cert_period_end_date )
       or
    --async selfpaced, online(selfp) or offline(CBT)
    --async have opt end date
    (event_type ='SELFPACED'  and
     (csr_cert_period_end_date >= evt.course_start_date) AND
       ((evt.course_end_date is null) or
        (evt.course_end_date IS NOT NULL AND evt.course_end_date >= csr_cert_period_start_date))))
   AND evt.activity_version_id = csr_activity_version_id
   AND ((csr_person_id IS NOT NULL AND tdb.delegate_person_id = csr_person_id)
                   OR (csr_contact_id IS NOT NULL AND tdb.delegate_contact_id = csr_contact_id)
   )
    order by status;

CURSOR csr_cert_enrl(p_cert_enrollment_id ota_cert_enrollments.cert_enrollment_id%type) IS
SELECT certification_id,
     cert_enrollment_id,
     business_group_id,
     certification_status_code,
     object_version_number,
     completion_date,
     earliest_enroll_date
FROM ota_cert_enrollments
WHERE cert_enrollment_id = p_cert_enrollment_id;

CURSOR csr_prd_enrl(csr_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) IS
select cert_enrollment_id, cert_prd_enrollment_id, period_status_code, object_version_number, completion_date
FROM ota_cert_prd_enrollments
where cert_prd_enrollment_id = csr_cert_prd_enrollment_id;

l_cert_enrl_rec csr_cert_enrl%ROWTYPE;
l_prd_enrl_rec csr_prd_enrl%ROWTYPE;
l_booking_status_type ota_booking_status_types.type%TYPE;
l_date_status_changed ota_delegate_bookings.date_status_changed%TYPE;

l_cert_period_start_date ota_cert_prd_enrollments.cert_period_start_date%TYPE;
l_cert_period_end_date ota_cert_prd_enrollments.cert_period_end_date%TYPE;
l_cert_completion_date ota_cert_enrollments.completion_date%type;
l_cert_prd_completion_date ota_cert_prd_enrollments.completion_date%type;
l_earliest_enroll_date ota_cert_enrollments.earliest_enroll_date%type;
l_expiration_date ota_cert_prd_enrollments.expiration_date%type;

begin

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sync Late Subscription to certification with classes');

FOR rec_cert_details in csr_cert_details loop
    FOR rec_course_info in csr_course_info(rec_cert_details.cert_prd_enrollment_id) loop
        FOR rec_enr IN get_enrl_status(rec_course_info.object_id,
                                       (rec_cert_details.cert_period_start_date - rec_cert_details.initial_completion_duration),
                                       (rec_cert_details.cert_period_end_date - rec_cert_details.initial_completion_duration),
                                       rec_cert_details.person_id,
                                       rec_cert_details.contact_id)LOOP
              l_booking_status_type := rec_enr.status ;
              l_date_status_changed := rec_enr.date_status_changed;

              IF(l_booking_status_type = 'A' AND
                 (trunc(l_date_status_changed) + rec_cert_details.initial_completion_duration) >= rec_cert_details.cert_period_start_date AND
                  trunc(l_date_status_changed) < rec_cert_details.cert_period_end_date AND
                  trunc(l_date_status_changed) BETWEEN rec_cert_details.start_date_active AND rec_cert_details.end_date_active) THEN

                  --calculate dates
                  l_cert_period_start_date := trunc(l_date_status_changed);
                  l_cert_period_end_date   := l_cert_period_start_date + rec_cert_details.initial_completion_duration;
                  l_cert_completion_date    := trunc(l_date_status_changed);
                  l_cert_prd_completion_date := trunc(l_date_status_changed);

                  ota_cpe_util.calc_cre_dates(rec_cert_details.cert_enrollment_id,
                                              rec_cert_details.certification_id,
                                              null,
                                              l_earliest_enroll_date,
                                              l_expiration_date,
                                              l_cert_period_start_date);

                 --UPDATE cert enrollment dates
                 OPEN csr_cert_enrl(rec_cert_details.cert_enrollment_id);
                 FETCH csr_cert_enrl INTO l_cert_enrl_rec;
                 CLOSE csr_cert_enrl;

                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Certification: ' || rec_cert_details.name);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------');

                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'cert_prd_enrollment_id = ' || rec_cert_details.cert_prd_enrollment_id);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'person_id = ' || rec_cert_details.person_id);

                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Old Period Start Date = ' || rec_cert_details.cert_period_start_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Old Period End Date = ' || rec_cert_details.cert_period_end_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Old Compeletion Date = ' || l_cert_enrl_rec.completion_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Old Earliest Enroll Date = ' || l_cert_enrl_rec.earliest_enroll_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Old Expiration Date = ' || rec_cert_details.expiration_date);

                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'New Period Start Date = ' || l_cert_period_start_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'New Period End Date = ' || l_cert_period_end_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'New Compeletion Date = ' || l_cert_completion_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'New Earliest Enroll Date = ' || l_earliest_enroll_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'New Expiration Date = ' || l_expiration_date);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------------------------------------------------');

                 ota_cert_enrollment_api.update_cert_enrollment
			         (p_effective_date               => sysdate
			         ,p_cert_enrollment_id           => l_cert_enrl_rec.cert_enrollment_id
			         ,p_certification_id             => l_cert_enrl_rec.certification_id
			         ,p_object_version_number        => l_cert_enrl_rec.object_version_number
			         ,p_certification_status_code    => l_cert_enrl_rec.certification_status_code
			         ,p_is_history_flag              => 'N'
			         ,p_earliest_enroll_date         => l_earliest_enroll_date
			         ,p_completion_date              => l_cert_completion_date
			         );

			     --UPDATE cert period enrollment dates
                 OPEN csr_prd_enrl(rec_cert_details.cert_prd_enrollment_id);
                 FETCH csr_prd_enrl INTO l_prd_enrl_rec;
                 CLOSE csr_prd_enrl;

			     ota_cert_prd_enrollment_api.update_cert_prd_enrollment
                    (p_effective_date               => trunc(sysdate)
                    ,p_cert_enrollment_id           => l_prd_enrl_rec.cert_enrollment_id
                    ,p_cert_prd_enrollment_id       => l_prd_enrl_rec.cert_prd_enrollment_id
                    ,p_object_version_number        => l_prd_enrl_rec.object_version_number
                    ,p_period_status_code           => l_prd_enrl_rec.period_status_code
                    ,p_completion_date              => l_cert_prd_completion_date
                    ,p_cert_period_start_date       => l_cert_period_start_date
                    ,p_cert_period_end_date         => l_cert_period_end_date
                    ,p_expiration_date	            => l_expiration_date
                    );

                 COMMIT;
                EXIT;
              END IF;
        END LOOP;
    END LOOP;
END LOOP;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sync Late Subscription to certification with classes is completed.');

EXCEPTION when others then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc ||','||SUBSTR(SQLERRM, 1, 500));
end sync_late_subsc_to_class;
--

END OTA_CPE_UTIL;


/
