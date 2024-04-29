--------------------------------------------------------
--  DDL for Package Body PER_IREC_ICD_ENRLL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IREC_ICD_ENRLL_PROCESS" as
/* $Header: periricd.pkb 120.15.12010000.3 2010/04/08 10:30:00 vmummidi ship $ */

g_package  varchar2(80) := 'PER_IREC_ICD_ENRLL_PROCESS';

-- ----------------------------------------------------------------------------
-- CURSORS
-- ----------------------------------------------------------------------------

-- ***************************************************************************
-- Cursor to get persons and vacancies in a business group employed in the BG
-- and not yet enrolled.
-- ***************************************************************************
cursor vacancypersonQuery(pBGId in number) is
  SELECT
    vac.VACANCY_ID,paaf.person_id,paaf.assignment_id,
    PIL.PER_IN_LER_ID, PAAF.BUSINESS_GROUP_ID
  FROM
    PER_ALL_VACANCIES vac, per_all_assignments_f paaf,
    BEN_PER_IN_LER pil, ben_ler_f ler
  WHERE
    vac.BUSINESS_GROUP_ID = pBGId and
    paaf.BUSINESS_GROUP_ID = vac.BUSINESS_GROUP_ID and
    pil.BUSINESS_GROUP_ID = paaf.BUSINESS_GROUP_ID and
    ler.BUSINESS_GROUP_ID = paaf.BUSINESS_GROUP_ID and
    paaf.vacancy_id = vac.Vacancy_Id and
    paaf.assignment_type = 'E' AND
    paaf.primary_flag='Y' and
    sysdate BETWEEN paaf.effective_start_date AND paaf.effective_end_date AND
    NOT EXISTS ( SELECT ben.person_id FROM ben_prtt_enrt_rslt_f ben
                  where paaf.person_id = ben.person_id) AND
    ler.typ_cd = 'IREC' AND
    pil.LF_EVT_OCRD_DT BETWEEN ler.effective_start_date(+) AND ler.effective_end_date(+) and
    ler.ler_id = pil.ler_id AND
    pil.person_id=paaf.person_id AND
    pil.PER_IN_LER_STAT_CD='STRTD' AND
    pil.assignment_id = paaf.assignment_id
  order by
    vac.vacancy_id,paaf.person_id;

-- ***************************************************************************
-- Cursor to get all persons employed for the vacancy and not yet enrolled
-- ***************************************************************************
cursor personQuery(pVacancyId in number) is
  SELECT
    paaf.person_id, paaf.assignment_id, PIL.PER_IN_LER_ID,
    PAAF.BUSINESS_GROUP_ID
  FROM
    per_all_assignments_f paaf,BEN_PER_IN_LER pil, ben_ler_f ler
  WHERE
     pil.BUSINESS_GROUP_ID = paaf.BUSINESS_GROUP_ID and
     ler.BUSINESS_GROUP_ID = paaf.BUSINESS_GROUP_ID and
     paaf.vacancy_id = pVacancyId and
     paaf.assignment_type = 'E' AND
     paaf.primary_flag='Y' and
     sysdate BETWEEN paaf.effective_start_date AND paaf.effective_end_date AND
     NOT EXISTS ( SELECT ben.person_id FROM ben_prtt_enrt_rslt_f ben
                  where paaf.person_id = ben.person_id) and
    ler.typ_cd = 'IREC' AND
    pil.LF_EVT_OCRD_DT BETWEEN ler.effective_start_date(+) AND ler.effective_end_date(+) and
    ler.ler_id = pil.ler_id AND
    pil.person_id=paaf.person_id AND
    pil.PER_IN_LER_STAT_CD='STRTD' AND
    pil.assignment_id = paaf.assignment_id
  order by
    paaf.person_id;

-- ***************************************************************************
-- Functions to get the names for Person, Vacancy, Business Group
-- ***************************************************************************
--
function get_person_hire_date(p_assignment_id number)
return DATE is
--
  l_hire_date DATE;
--
  cursor c_hire_date is
   select min(EFFECTIVE_START_DATE)
     from PER_ALL_ASSIGNMENTS_F
    where ASSIGNMENT_ID = p_assignment_id
      and ASSIGNMENT_TYPE = 'E'
      and PRIMARY_FLAG = 'Y';
--
begin
--
  open c_hire_date;
    fetch c_hire_date into l_hire_date;
    if c_hire_date%FOUND then
      close c_hire_date;
      return l_hire_date;
    else
      close c_hire_date;
      return null;
    end if;
--
end get_person_hire_date;
function get_person_full_name(p_person_id number)
return varchar2 is
--
l_dummy varchar2(240);
cursor c_person_name is
      select full_name
        from per_all_people_f
       where person_id = p_person_id
       AND SYSDATE BETWEEN effective_start_date AND effective_end_date;
--
begin
--
  open c_person_name;
    fetch c_person_name into l_dummy;
    if c_person_name%FOUND then
      close c_person_name;
      return l_dummy;
    else
      close c_person_name;
      return '  ';
    end if;
--
end get_person_full_name;

function get_vacancy_name(p_vacancy_id number)
return varchar2 is
--
l_dummy varchar2(30);
cursor c_vacancy_name is
      select name
        from per_all_vacancies
       where vacancy_id = p_vacancy_id;
--
begin
--
  open c_vacancy_name;
    fetch c_vacancy_name into l_dummy;
    if c_vacancy_name%FOUND then
      close c_vacancy_name;
      return l_dummy;
    else
      close c_vacancy_name;
      return '  ';
    end if;
--
end get_vacancy_name;

function get_business_group_name(p_bg_id number)
return varchar2 is
--
l_dummy varchar2(240);
cursor c_bg_name is
  SELECT haou.NAME
  FROM HR_ORGANIZATION_UNITS haou, HR_ORGANIZATION_INFORMATION haoi
  WHERE
    haou.organization_id = haoi.organization_id AND
    haoi.org_information_context = 'CLASS' AND
    haoi.org_information1 = 'HR_BG' AND
    haoi.org_information2 = 'Y' AND
    not exists (select 1 from HR_ORGANIZATION_INFORMATION haoi2
      where haou.organization_id=haoi2.organization_id
      and haoi2.org_information_context='BG Recruitment'
      and haoi2.org_information9='Y') AND
    BUSINESS_GROUP_ID=p_bg_id;
--
begin
--
  open c_bg_name;
    fetch c_bg_name into l_dummy;
    if c_bg_name%FOUND then
      close c_bg_name;
      return l_dummy;
    else
      close c_bg_name;
      return '  ';
    end if;
--
end get_business_group_name;

--
--
-- ----------------------------------------------------------------------------
--  is_offer_accepted_or_extended
--
--
-- ----------------------------------------------------------------------------
--
function is_offer_accepted_or_extended
            (  pPersonId     in     number
             , pAssignmentId in     number)
return Boolean
is
--
  l_proc varchar2(80) default g_package||'.is_offer_accepted_or_extended';
  l_person_name_with_id varchar2(300);
  l_description varchar2(500);
  l_offer_status irc_offer_status_history.offer_status%TYPE;
  l_change_reason irc_offer_status_history.change_reason%TYPE;
  l_decline_reason irc_offer_status_history.decline_reason%TYPE;
  cursor csr_offer_status is
         select * from(
         select ofrhis.offer_status, ofrhis.change_reason, ofrhis.decline_reason
         from irc_offer_status_history ofrhis, irc_offers ofr, per_all_assignments_f paaf
         where paaf.assignment_id = pAssignmentId and ofr.applicant_assignment_id = paaf.assignment_id
         and ofrhis.offer_id = ofr.offer_id and ofr.latest_offer='Y'
         and sysdate between paaf.effective_start_date and paaf.effective_end_date order by status_change_date desc)
         where rownum<2;
--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);
  l_person_name_with_id:=get_person_full_name(pPersonId)||'(person_id='||pPersonId||')';
  open  csr_offer_status;
  fetch csr_offer_status into l_offer_status,
                              l_change_reason,
                              l_decline_reason;
  --
  if csr_offer_status%notfound then
    --
    close csr_offer_status;
    --
    return false;
  else
    close csr_offer_status;

-- check if the offer is in accepted state
-- Also check the change reason is 'APL_HIRED'
-- Note : ('APL_HIRED' is introduced with patch 6006935)
--
    if (l_offer_status='CLOSED' and l_change_reason in ('APL_ACCEPTED','APL_HIRED'))
      or l_offer_status='EXTENDED' THEN
      return true;
    end if;

    fnd_message.set_name('PER','IRC_412236_INV_OFFER_STATUS');
    fnd_message.set_token('PERSON_NAME',l_person_name_with_id);
    l_description:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_file.put_line(fnd_file.log,l_description);
--REVIEW : The enrollment process did not run for AAAAAA for the following reason.
--         The person did not have an offer extended OR
--         The person declined the offer.
    return false;
    hr_utility.set_location(' Leaving:'||l_proc, 130);
  end if;
--
END is_offer_accepted_or_extended;
--
--
--
--
-- ----------------------------------------------------------------------------
--  is_person_future_terminated
--
--
-- ----------------------------------------------------------------------------
--
function is_person_future_terminated
            (  pPersonId     in     number)
return Boolean
is
--
  l_proc varchar2(80) default g_package||'.is_person_future_terminated';
  l_person_name varchar2(300);
  l_description varchar2(500);

  cursor csr_future_person_rec is
    SELECT ppf.full_name
    FROM per_all_people_f ppf
    WHERE ppf.person_id = pPersonId and
          ppf.effective_end_date > To_Date('30-12-4712','dd-mm-yyyy') and
          ppf.current_employee_flag IS null;
--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);

  open  csr_future_person_rec;
  fetch csr_future_person_rec into l_person_name;
  --
  if csr_future_person_rec%notfound then
    --
    close csr_future_person_rec;
    --
    return false;
  else
    close csr_future_person_rec;

    fnd_message.set_name('PER','IRC_412243_INVALID_PERSON_ID');
    fnd_message.set_token('PERSON_NAME',l_person_name||'(person_id='||pPersonId||')');
    l_description:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_file.put_line(fnd_file.log,l_description);
    return true;
  end if;
--
END is_person_future_terminated;
--
--
--
-- ----------------------------------------------------------------------------
--  populate_pay_elements
--     called from concurrent process to populate Pay Elements :
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_pay_elements
            (  errbuf    out nocopy  varchar2
             , retcode   out nocopy  number
             , pBgId      in         number
             , pVacancyid in         number   default null
             , pPersonId  in         number   default null)
 is
--
  l_proc               varchar2(80) default g_package||'.populate_pay_elements';
  l_person_name        varchar2(240);
  l_vacancy_name       varchar2(30);
  l_bg_name            varchar2(240);
  l_description_start  varchar2(500);
  l_description_end    varchar2(500);
--
BEGIN
  hr_utility.set_location('Entering'||l_proc,10);
  hr_utility.set_location(' Person Id:'||pPersonId||' Vacancy Id:'||pVacancyid||' BusinessGroup Id:'||pBgId, 20);

  hr_utility.set_location('Calling the CP with UserName:'||fnd_global.user_name||',UserId='||fnd_global.user_id,30);
  hr_utility.set_location('Responsibility Application Id:'||fnd_global.resp_appl_id||',Responsibility Id:'||fnd_global.resp_id,40);
  hr_utility.set_location('Security Group Id:'||fnd_global.security_group_id, 50);

    fnd_message.set_name('PER','IRC_412237_CRT_ENRLM_STRTD');
    l_description_start:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_message.set_name('PER','IRC_412238_CRT_ENRLM_CMPLTD');
    l_description_end:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

  if pPersonId is not null THEN
    l_person_name:=get_person_full_name(pPersonId);
    l_vacancy_name:=get_vacancy_name(pVacancyid);
    l_bg_name:=get_business_group_name(pBgId);
    fnd_file.put_line(fnd_file.log,l_description_start||
'
Person    :'||l_person_name||
'
Person Id :'||pPersonId);
    fnd_file.put_line(fnd_file.log,
'Vacancy    :'||l_vacancy_name||
'
Vacancy Id :'||pVacancyId);
    fnd_file.put_line(fnd_file.log,
'Business Group    :'||l_bg_name||
'
Business Group Id :'||pBgId);
    fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');
--REVIEW: The iRecruitment Create Enrollment process is started.
--        Person    : XXXXXX
--        Person Id : 121212
    populate_for_person(errbuf, retcode, pPersonId);
    fnd_file.put_line(fnd_file.log, l_description_end);
--REVIEW: The iRecruitment Create Enrollment process is completed.

  else
    if pVacancyid is not null THEN
      l_vacancy_name:=get_vacancy_name(pVacancyid);
      l_bg_name:=get_business_group_name(pBgId);
      fnd_file.put_line(fnd_file.log,l_description_start||
'
Vacancy    :'||l_vacancy_name||
'
Vacancy Id :'||pVacancyid);
      fnd_file.put_line(fnd_file.log,
'Business Group    :'||l_bg_name||
'
Business Group Id :'||pBgId);
      fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');
      populate_for_vacancy(errbuf, retcode, pVacancyid);
      fnd_file.put_line(fnd_file.log, l_description_end);
    else
      if pBgId is not null THEN
        l_bg_name:=get_business_group_name(pBgId);
        fnd_file.put_line(fnd_file.log,l_description_start||
'
Business Group    :'||l_bg_name||
'
Business Group Id :'||pBgId);
    fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');
        populate_for_bg(errbuf, retcode, pBgId);
        fnd_file.put_line(fnd_file.log, l_description_end);
      else
        fnd_message.set_name('PER','HR_289541_PJU_INV_BG_ID');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location('retcode='||retcode||' and errbuf='||errbuf, 60);
  hr_utility.set_location(' Leaving:'||l_proc, 70);
--
END populate_Pay_Elements;
--

--
--
-- ----------------------------------------------------------------------------
--  populate_for_bg
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_for_bg
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pBgId      in         number)
is
--
  l_proc varchar2(80) default    g_package||'.populate_for_bg';
--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);
for vacancypersonQuery_rec in vacancypersonQuery(pBgId) LOOP
  fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');
  if is_person_future_terminated(vacancypersonQuery_rec.person_id) then
    --do not run the process if the person is terminated in future.
    hr_utility.set_location('Entering'||l_proc, 20);
  else
    if is_offer_accepted_or_extended(
                             vacancypersonQuery_rec.person_id,
                             vacancypersonQuery_rec.assignment_id)
    then
      run_enrollment(errbuf, retcode,
                     vacancypersonQuery_rec.person_id,
                     vacancypersonQuery_rec.assignment_id,
                     vacancypersonQuery_rec.PER_IN_LER_id,
                     vacancypersonQuery_rec.BUSINESS_GROUP_id);
    end if;
  end if;
  fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');
end loop;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
END populate_for_bg;
--

--
--
-- ----------------------------------------------------------------------------
--  populate_for_vacancy
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_for_vacancy
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pVacancyId      in         number)
is
--
  l_proc varchar2(80) default    g_package||'.populate_for_vacancy';
--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);
for personQuery_rec in personQuery(pVacancyId) LOOP
  fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');

  if is_person_future_terminated(personQuery_rec.person_id) then
    --do not run the process if the person is terminated in future.
    hr_utility.set_location('Entering'||l_proc, 20);
  else
    if is_offer_accepted_or_extended(
                             personQuery_rec.person_id,
                             personQuery_rec.assignment_id)
    then
      run_enrollment(errbuf, retcode,
                           personQuery_rec.person_id,
                           personQuery_rec.assignment_id,
                           personQuery_rec.PER_IN_LER_id,
                           personQuery_rec.BUSINESS_GROUP_id);
    end if;
  end if;
  fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');

end loop;
hr_utility.set_location(' Leaving:'||l_proc, 20);
--
END populate_for_vacancy;
--

--
--
-- ----------------------------------------------------------------------------
--  populate_for_person
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_for_person
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pPersonId in         number)
is
--
  l_proc varchar2(80) default    g_package||'.populate_for_person';
  l_assignment_id      number;
  l_per_in_ler_id      NUMBER;
  l_business_group_id  NUMBER;
  l_description        varchar2(500);
  cursor csr_assignment is
         select PAAF.assignment_id,PAAF.BUSINESS_GROUP_ID,PIL.PER_IN_LER_ID
         from per_all_assignments_f PAAF, BEN_PER_IN_LER pil, ben_ler_f ler
         where PAAF.person_id = pPersonId and PAAF.assignment_type='E' and
               paaf.primary_flag='Y' and
               pil.BUSINESS_GROUP_ID = paaf.BUSINESS_GROUP_ID and
               ler.BUSINESS_GROUP_ID = paaf.BUSINESS_GROUP_ID and
               SYSDATE BETWEEN PAAF.effective_start_date AND PAAF.effective_end_date AND
               NOT EXISTS ( SELECT ben.person_id FROM ben_prtt_enrt_rslt_f ben
                 where paaf.person_id = ben.person_id AND ROWNUM = 1) AND
               ler.typ_cd = 'IREC' AND
               pil.LF_EVT_OCRD_DT BETWEEN ler.effective_start_date(+) AND ler.effective_end_date(+) and
               ler.ler_id = pil.ler_id AND pil.person_id=paaf.person_id AND
               pil.PER_IN_LER_STAT_CD='STRTD' AND
               pil.assignment_id = paaf.assignment_id;
--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);
        fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');

  open  csr_assignment;
  fetch csr_assignment into l_assignment_id,l_business_group_id,l_per_in_ler_id;
  --
  if csr_assignment%notfound then
  --
    close csr_assignment;
    fnd_message.set_name('PER','IRC_412239_INV_OFFER_COMP');
    fnd_message.set_token('PERSON_NAME',get_person_full_name(pPersonId)||'(person_id='||pPersonId||')');
    l_description:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_file.put_line(fnd_file.log,l_description);
    hr_utility.set_location(l_proc,20);
  --
  else
    close csr_assignment;

    if is_person_future_terminated(pPersonid) then
      --do not run the process if the person is terminated in future.
      hr_utility.set_location(l_proc,30);
    else
      if is_offer_accepted_or_extended(pPersonid,l_assignment_id) then
        run_enrollment(errbuf, retcode,
                     pPersonId,
                     l_assignment_id,
                     l_per_in_ler_id,
                     l_business_group_id);
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
          fnd_file.put_line(fnd_file.log,
'+---------------------------------------------------------------------------+');
--
END populate_for_person;
--

--
--
-- ----------------------------------------------------------------------------
--  run_enrollment
--
--
-- ----------------------------------------------------------------------------
--
PROCEDURE run_enrollment
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , pPersonId     in     number
             , pAssignmentId in     number
             , pPerInLerId   in     number
             , pBgId         in     number)
is
--
l_person_name          varchar2(240);
l_prt_id               number(15);
l_person_name_with_id  varchar2(260);
l_description          VARCHAR2(500);
l_hire_date            DATE;
l_proc varchar2(80) default    g_package||'.run_enrollment';
cursor c_participation is
    select prtt_enrt_rslt_id
    from ben_prtt_enrt_rslt_f
    where person_id = pPersonId;
BEGIN
--
  hr_utility.set_location('Entering '||l_proc, 10);
  l_person_name_with_id:=get_person_full_name(pPersonId)||'(person_id='||pPersonId||')';
  l_person_name:=get_person_full_name(pPersonId);
  l_hire_date:=get_person_hire_date(pAssignmentId);

  fnd_message.set_name('PER','IRC_412240_CRT_ENRLM_INITIAT');
  fnd_message.set_token('PERSON_NAME',l_person_name_with_id);
  fnd_message.set_token('HIRE_DATE',l_hire_date);
  l_description:=substrb(fnd_message.get,1,500);
  fnd_message.clear;

  fnd_file.put_line(fnd_file.log, l_description);

  ben_irec_process.create_enrollment_for_irec(
                                    p_irec_per_in_ler_id  => pPerInLerId
                                    ,p_person_id          => pPersonId
                                    ,p_business_group_id  => pBgId
                                    ,p_effective_date     => l_hire_date);
  open c_participation;
  fetch c_participation into l_prt_id;
--
  if c_participation%FOUND then
--
    close c_participation;
    -- as the life event run is enrolled successfully set the life_run status to PROCD
    update ben_per_in_ler
    set per_in_ler_stat_cd = 'PROCD',
        PROCD_DT           = Trunc(sysdate)
    where per_in_ler_id    = pPerInLerId;
    -- issue commit so that data is committed.
    commit;

    fnd_message.set_name('PER','IRC_412241_CRT_ENRLM_SUCCESS');
    fnd_message.set_token('PERSON_NAME',l_person_name);
    l_description:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_file.put_line(fnd_file.log, l_description);
--
  else
--
    close c_participation;
    -- Set the return parameters to indicate failure
    errbuf:=fnd_message.get;

    fnd_message.set_name('PER','IRC_412242_CRT_ENRLM_ERRORED');
    fnd_message.set_token('PERSON_NAME',l_person_name);
    l_description:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_file.put_line(fnd_file.log, l_description||
'
'||errbuf);
    retcode := 2;
--
  end if;
--
--
  hr_utility.set_location('Leaving '||l_proc, 20);
EXCEPTION
--
  when others then
    --
    hr_utility.set_location(substr(SQLERRM,1,30),1234);
    hr_utility.set_location(substr(SQLERRM,31,60),1235);
    hr_utility.set_location(substr(SQLERRM,61,90),1236);
    hr_utility.set_location(substr(SQLERRM,91,120),1237);
    errbuf:=fnd_message.get;
    --
    -- Set the return parameters to indicate failure
    --
    fnd_message.set_name('PER','IRC_412242_CRT_ENRLM_ERRORED');
    fnd_message.set_token('PERSON_NAME',l_person_name);
    l_description:=substrb(fnd_message.get,1,500);
    fnd_message.clear;

    fnd_file.put_line(fnd_file.log, l_description||
'
'||errbuf);
--REVIEW : The enrollment process errored out for the person XXXXXXX with the following message.
--         ERROR :  <TOKEN FOR ERROR MESSAGE>

    retcode := 2;
    hr_utility.set_location('Leaving '||l_proc, 30);
END run_enrollment;
--
--
END PER_IREC_ICD_ENRLL_PROCESS;

/
