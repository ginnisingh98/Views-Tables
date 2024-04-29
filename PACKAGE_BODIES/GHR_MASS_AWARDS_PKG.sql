--------------------------------------------------------
--  DDL for Package Body GHR_MASS_AWARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MASS_AWARDS_PKG" AS
/* $Header: ghrmarpa.pkb 120.12 2006/11/08 16:59:43 ygnanapr noship $ */


g_package          varchar2(32) := 'GHR_MASS_AWARDS_PKG.';
l_information_type varchar2(40) := 'GHR_US_PAR_AWARDS_BONUS';
g_log_name         varchar2(30);
g_log_text         varchar2(2000);


PROCEDURE get_noa_code_desc
(
 p_noa_id              in   ghr_nature_of_actions.nature_of_action_id%type,
 p_effective_date      in   date default trunc(sysdate),
 p_noa_code            out nocopy  ghr_nature_of_actions.code%type,
 p_noa_desc            out nocopy  ghr_nature_of_actions.description%type
 )
 IS

--
-- local variables
--

  l_proc   varchar2(72) :=   g_package || 'get_noa_code_desc';

  cursor c_noa is
        select  noa.code, noa.description
        from    ghr_nature_of_actions noa
        where   noa.nature_of_action_id = p_noa_id
        and     noa.enabled_flag = 'Y'
        and     nvl(p_effective_date,trunc(sysdate))
        between noa.date_from
        and     nvl(noa.date_to,nvl(p_effective_date,trunc(sysdate))) ;
--
BEGIN
--
  hr_utility.set_location('Entering ' || l_proc,5);
  p_noa_code :=  Null;
  p_noa_desc :=  Null;

  for noa_code_desc in c_noa loop
    hr_utility.set_location( l_proc,10);
    p_noa_code         := noa_code_desc.code;
    p_noa_desc         := noa_code_desc.description;
  end loop;
  hr_utility.set_location('Leaving  ' || l_proc,15);

  EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
    p_noa_code         := NULL;
    p_noa_desc         := NULL;
    RAISE;

END get_noa_code_desc;

PROCEDURE get_business_group(p_person_id         in number,
                             p_effective_date    in date,
                             p_business_group_id in out nocopy number) is

   l_business_group_id  number;
  -- -------------------------------------------------------------------------
  -- Cursor to derive business group from person based on person_id.
  -- -------------------------------------------------------------------------
  cursor c_business_group is
    select ppf.business_group_id
    from   per_people_f ppf
    where  ppf.person_id = p_person_id
    and    trunc(p_effective_date)
           between nvl(trunc(ppf.effective_start_date),trunc(sysdate))
           and     nvl(trunc(ppf.effective_end_date),trunc(sysdate-1));
  --
BEGIN

  l_business_group_id := p_business_group_id ; --NOCOPY Changes

  open c_business_group;
    fetch c_business_group into p_business_group_id;
  close c_business_group;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters
    p_business_group_id := l_business_group_id;
    RAISE;

END get_business_group;


FUNCTION get_noa_id (
     p_mass_award_id     in      ghr_mass_awards.mass_award_id%type)
RETURN NUMBER IS
--
CURSOR cur_noa_id IS
  SELECT nature_of_action_id
  FROM   ghr_mass_awards
  WHERE  mass_award_id = p_mass_award_id;

l_ret_val   NUMBER(15);

BEGIN
  l_ret_val := null;
  FOR cur_noa_id_rec IN cur_noa_id LOOP
    l_ret_val :=  cur_noa_id_rec.nature_of_action_id;
  END LOOP;

  RETURN(l_ret_val);

END get_noa_id;

--Bug#3804067 Added new parameter p_mass_action_comments
PROCEDURE get_pa_request_id_ovn  (
 p_mass_award_id         in      ghr_mass_awards.mass_award_id%TYPE,
 p_effective_date        in      date,
 p_person_id             in      per_people_f.person_id%TYPE,
 p_pa_request_id         out nocopy     ghr_pa_requests.pa_request_id%TYPE,
 p_pa_notification_id    out nocopy     ghr_pa_requests.pa_notification_id%TYPE,
 p_rpa_type              out nocopy     ghr_pa_requests.rpa_type%TYPE,
 p_mass_action_sel_flag  out nocopy     ghr_pa_requests.mass_action_select_flag%TYPE,
 p_mass_action_comments  out nocopy     ghr_pa_requests.mass_action_comments%TYPE,
 p_object_version_number out nocopy     ghr_pa_requests.object_version_number%TYPE)

 IS

--
-- local variables
--

  l_proc   varchar2(72) :=   g_package || 'get_pa_request_id_ovn';
--Bug#3804067 Added mass_action_comments
CURSOR cur_rpa IS
  SELECT pa_request_id, object_version_number,
         pa_notification_id,rpa_type, mass_action_select_flag,
	 mass_action_comments
  FROM ghr_pa_requests
  WHERE mass_action_id  = p_mass_award_id
  AND   effective_date  = trunc(p_effective_date)
  AND   person_id       = p_person_id;

BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);
  p_pa_request_id         :=  Null;
  p_object_version_number :=  Null;
  p_pa_notification_id    :=  Null;
  p_rpa_type              :=  Null;
  p_mass_action_sel_flag  :=  Null;
  p_mass_action_comments  :=  Null;

  for cur_rpa_rec in cur_rpa loop
    hr_utility.set_location( l_proc,10);
    p_pa_request_id           := cur_rpa_rec.pa_request_id;
    p_object_version_number   := cur_rpa_rec.object_version_number;
    p_pa_notification_id      := cur_rpa_rec.pa_notification_id;
    p_rpa_type                := cur_rpa_rec.rpa_type;
    p_mass_action_sel_flag    := cur_rpa_rec.mass_action_select_flag;
    --Bug#3804067 Added code for comments.
    p_mass_action_comments    := cur_rpa_rec.mass_action_comments;
  end loop;
  hr_utility.set_location('pa_requst_id value ' || to_char(p_pa_request_id) ,15);
  hr_utility.set_location('pa_notifn_id value ' || to_char(p_pa_notification_id),15);
  hr_utility.set_location('pa_rpa_type  value ' || p_rpa_type,15);
  hr_utility.set_location('pa_ovn value '       || to_char(p_object_version_number),15);
  hr_utility.set_location('select flag value '  || p_mass_action_sel_flag,15);
  hr_utility.set_location('Leaving  ' || l_proc,15);

  EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

   p_pa_request_id         :=NULL;
   p_pa_notification_id    :=NULL;
   p_rpa_type              :=NULL;
   p_mass_action_sel_flag  :=NULL;
   --Bug#3804067 Added mass_action_comments
   p_mass_action_comments  :=NULL;
   p_object_version_number :=NULL;
   hr_utility.set_location('Leaving  ' || l_proc,20);
   RAISE;

 END get_pa_request_id_ovn;

PROCEDURE get_award_details
(
 p_mass_award_id             in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type                  in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date            in      date,
 p_person_id                 in      ghr_pa_requests.person_id%TYPE,
 p_award_amount              out nocopy     ghr_pa_requests.award_amount%TYPE,
 p_award_uom                 out nocopy     ghr_pa_requests.award_uom%TYPE,
 p_award_percentage          out nocopy     ghr_pa_requests.award_percentage%TYPE,
 p_award_agency              out nocopy     ghr_pa_request_extra_info.rei_information3%type,
 p_award_type                out nocopy     ghr_pa_request_extra_info.rei_information4%type,
 p_group_award               out nocopy     ghr_pa_request_extra_info.rei_information6%type,
 p_tangible_benefit_dollars  out nocopy     ghr_pa_request_extra_info.rei_information7%type,
 p_date_award_earned         out nocopy     ghr_pa_request_extra_info.rei_information9%type,
 p_appropriation_code        out nocopy     ghr_pa_request_extra_info.rei_information10%type
)
---- Fetch Remarks and Legal Authority codes.
IS

--
-- local variables
--

  l_proc             varchar2(72) :=  g_package || 'get_award_details';
  l_pa_request_id    ghr_pa_requests.pa_request_id%TYPE;

CURSOR cur_rpa_tmp IS
  SELECT pa_request_id,
         award_amount,
         award_uom,
         award_percentage
  FROM   ghr_pa_requests
  WHERE  mass_action_id  = p_mass_award_id
  AND    rpa_type        = p_rpa_type
  AND    person_id       is null;

CURSOR cur_rpa_per IS
  SELECT pa_request_id,
         award_amount,
         award_uom,
         award_percentage
  FROM   ghr_pa_requests
  WHERE  mass_action_id  = p_mass_award_id
  AND    rpa_type        = p_rpa_type
  AND    person_id       = p_person_id;

CURSOR cur_award_ei(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
  SELECT rei_information3  award_agency,
         rei_information4  award_type,
         rei_information6  group_award,
         rei_information7  tangible_benefit_dollars,
         rei_information9  date_award_earned,
         rei_information10 appropriation_code
  FROM   ghr_pa_request_extra_info
  WHERE  pa_request_id    = c_pa_request_id
  AND    information_type = l_information_type;

BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);
  p_award_amount             := Null;
  p_award_uom                := Null;
  p_award_percentage         := Null;
  p_award_agency             := Null;
  p_award_type               := Null;
  p_group_award              := Null;
  p_tangible_benefit_dollars := Null;
  p_date_award_earned        := Null;
  p_appropriation_code       := Null;

IF p_rpa_type = 'TA' then
  for cur_rpa_tmp_rec in cur_rpa_tmp loop
    hr_utility.set_location( l_proc,10);
    l_pa_request_id          := cur_rpa_tmp_rec.pa_request_id;
    p_award_amount           := cur_rpa_tmp_rec.award_amount;
    p_award_uom              := cur_rpa_tmp_rec.award_uom;
    p_award_percentage       := cur_rpa_tmp_rec.award_percentage;
   hr_utility.set_location(' Rpa type  = ' || p_rpa_type                  ,15);
   hr_utility.set_location(' award amt = ' || to_char(p_award_amount)     ,15);
   hr_utility.set_location(' award uom = ' || p_award_uom                 ,15);
   hr_utility.set_location(' award per = ' || to_char(p_award_percentage) ,15);
  end loop;
else
  for cur_rpa_per_rec in cur_rpa_per loop
    hr_utility.set_location( l_proc,10);
    l_pa_request_id          := cur_rpa_per_rec.pa_request_id;
    p_award_amount           := cur_rpa_per_rec.award_amount;
    p_award_uom              := cur_rpa_per_rec.award_uom;
    p_award_percentage       := cur_rpa_per_rec.award_percentage;
   hr_utility.set_location(' Rpa type  = ' || p_rpa_type                  ,15);
   hr_utility.set_location(' Person_id = ' || to_char(p_person_id)        ,15);
   hr_utility.set_location(' award amt = ' || to_char(p_award_amount)     ,15);
   hr_utility.set_location(' award uom = ' || p_award_uom                 ,15);
   hr_utility.set_location(' award per = ' || to_char(p_award_percentage) ,15);
  end loop;
END IF;

	hr_utility.set_location(' Rpa ID  = ' ||l_pa_request_id          ,15);

  for cur_award_ei_rec in cur_award_ei(l_pa_request_id) loop
    hr_utility.set_location( l_proc,20);
    p_award_agency               := cur_award_ei_rec.award_agency;
    p_award_type                 := cur_award_ei_rec.award_type;
    p_group_award                := cur_award_ei_rec.group_award;
    p_tangible_benefit_dollars   := cur_award_ei_rec.tangible_benefit_dollars;
    p_date_award_earned          := cur_award_ei_rec.date_award_earned;
    p_appropriation_code         := cur_award_ei_rec.appropriation_code;
   hr_utility.set_location(' award agency = ' || p_award_agency               ,15);
   hr_utility.set_location(' award type   = ' || p_award_type                 ,15);
   hr_utility.set_location(' group award  = ' || p_group_award                ,15);
   hr_utility.set_location(' tbd          = ' || p_tangible_benefit_dollars   ,15);
   hr_utility.set_location(' date award   = ' || p_date_award_earned          ,15);
   hr_utility.set_location(' appr Code    = ' || p_appropriation_code         ,15);
  end loop;

  hr_utility.set_location('Leaving  ' || l_proc,35);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

   p_award_amount             := Null;
   p_award_uom                := Null;
   p_award_percentage         := Null;
   p_award_agency             := Null;
   p_award_type               := Null;
   p_group_award              := Null;
   p_tangible_benefit_dollars := Null;
   p_date_award_earned        := Null;
   p_appropriation_code       := Null;

   hr_utility.set_location('Leaving  ' || l_proc,40);
   RAISE;

END get_award_details;

PROCEDURE get_award_lac
(
 p_mass_award_id             in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type                  in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date            in      date,
 p_first_lac1_record         out nocopy     first_lac1_record,
 p_first_lac2_record         out nocopy     first_lac2_record
)

IS

--
-- local variables
--

  l_proc             varchar2(72) :=  g_package || 'get_award_lac';
  l_pa_request_id    ghr_pa_requests.pa_request_id%TYPE;


CURSOR cur_rpa_lac IS
  SELECT first_action_la_code1,
         first_action_la_desc1,
         first_lac1_information1,
         first_lac1_information2,
         first_lac1_information3,
         first_lac1_information4,
         first_lac1_information5,
         first_action_la_code2,
         first_action_la_desc2,
         first_lac2_information1,
         first_lac2_information2,
         first_lac2_information3,
         first_lac2_information4,
         first_lac2_information5
  FROM   ghr_pa_requests
  WHERE  mass_action_id  = p_mass_award_id
  AND    rpa_type        = p_rpa_type
  AND    person_id       is null;

BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);
  p_first_lac1_record        := Null;
  p_first_lac2_record        := Null;

  for cur_rpa_lac_rec in cur_rpa_lac loop
    hr_utility.set_location( l_proc,10);
    p_first_lac1_record.first_action_la_code1   := cur_rpa_lac_rec.first_action_la_code1;
    p_first_lac1_record.first_action_la_desc1   := cur_rpa_lac_rec.first_action_la_desc1;
    p_first_lac1_record.first_lac1_information1 := cur_rpa_lac_rec.first_lac1_information1;
    p_first_lac1_record.first_lac1_information2 := cur_rpa_lac_rec.first_lac1_information2;
    p_first_lac1_record.first_lac1_information3 := cur_rpa_lac_rec.first_lac1_information3;
    p_first_lac1_record.first_lac1_information4 := cur_rpa_lac_rec.first_lac1_information4;
    p_first_lac1_record.first_lac1_information5 := cur_rpa_lac_rec.first_lac1_information5;

    p_first_lac2_record.first_action_la_code2   := cur_rpa_lac_rec.first_action_la_code2;
    p_first_lac2_record.first_action_la_desc2   := cur_rpa_lac_rec.first_action_la_desc2;
    p_first_lac2_record.first_lac2_information1 := cur_rpa_lac_rec.first_lac2_information1;
    p_first_lac2_record.first_lac2_information2 := cur_rpa_lac_rec.first_lac2_information2;
    p_first_lac2_record.first_lac2_information3 := cur_rpa_lac_rec.first_lac2_information3;
    p_first_lac2_record.first_lac2_information4 := cur_rpa_lac_rec.first_lac2_information4;
    p_first_lac2_record.first_lac2_information5 := cur_rpa_lac_rec.first_lac2_information5;
  end loop;

  hr_utility.set_location('Leaving  ' || l_proc,20);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

   p_first_lac1_record        := Null;
   p_first_lac2_record        := Null;

   hr_utility.set_location('Leaving  ' || l_proc,25);
   RAISE;

END get_award_lac;

PROCEDURE get_award_details_shadow
(
 p_pa_request_id             in      ghr_pa_request_ei_shadow.pa_request_id%type,
 p_award_amount              out nocopy     ghr_pa_requests.award_amount%TYPE,
 p_award_uom                 out nocopy     ghr_pa_requests.award_uom%TYPE,
 p_award_percentage          out nocopy     ghr_pa_requests.award_percentage%TYPE,
 p_award_agency              out nocopy     ghr_pa_request_extra_info.rei_information3%type,
 p_award_type                out nocopy     ghr_pa_request_extra_info.rei_information4%type,
 p_group_award               out nocopy     ghr_pa_request_extra_info.rei_information6%type,
 p_tangible_benefit_dollars  out nocopy     ghr_pa_request_extra_info.rei_information7%type,
 p_date_award_earned         out nocopy     ghr_pa_request_extra_info.rei_information9%type,
 p_appropriation_code        out nocopy     ghr_pa_request_extra_info.rei_information10%type
)

IS

--
-- local variables
--

  l_proc             varchar2(72) :=  g_package || 'get_award_details_shadow';
  l_pa_request_id    ghr_pa_requests.pa_request_id%TYPE;

CURSOR cur_rpa_shadow IS
  SELECT
         award_amount,
         award_uom,
         award_percentage
  FROM   ghr_pa_request_shadow
  WHERE  pa_request_id = p_pa_request_id;

CURSOR cur_award_ei_shadow IS
  SELECT rei_information3  award_agency,
         rei_information4  award_type,
         rei_information6  group_award,
         rei_information7  tangible_benefit_dollars,
         rei_information9  date_award_earned,
         rei_information10 appropriation_code
  FROM   ghr_pa_request_ei_shadow
  WHERE  pa_request_id    = p_pa_request_id
  AND    information_type = l_information_type;

BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);
  p_award_amount             := Null;
  p_award_uom                := Null;
  p_award_percentage         := Null;
  p_award_agency             := Null;
  p_award_type               := Null;
  p_group_award              := Null;
  p_tangible_benefit_dollars := Null;
  p_date_award_earned        := Null;
  p_appropriation_code       := Null;

  for cur_rpa_shadow_rec in cur_rpa_shadow loop
    hr_utility.set_location( l_proc,10);
    p_award_amount           := cur_rpa_shadow_rec.award_amount;
    p_award_uom              := cur_rpa_shadow_rec.award_uom;
    p_award_percentage       := cur_rpa_shadow_rec.award_percentage;
   hr_utility.set_location(' pa req id = ' || to_char(p_pa_request_id)    ,10);
   hr_utility.set_location(' award amt = ' || to_char(p_award_amount)     ,10);
   hr_utility.set_location(' award uom = ' || p_award_uom                 ,10);
   hr_utility.set_location(' award per = ' || to_char(p_award_percentage) ,10);
  end loop;

  for cur_award_ei_shadow_rec in cur_award_ei_shadow loop
    hr_utility.set_location( l_proc,20);
    p_award_agency               := cur_award_ei_shadow_rec.award_agency;
    p_award_type                 := cur_award_ei_shadow_rec.award_type;
    p_group_award                := cur_award_ei_shadow_rec.group_award;
    p_tangible_benefit_dollars   := cur_award_ei_shadow_rec.tangible_benefit_dollars;
    p_date_award_earned          := cur_award_ei_shadow_rec.date_award_earned;
    p_appropriation_code         := cur_award_ei_shadow_rec.appropriation_code;
   hr_utility.set_location(' award agency = ' || p_award_agency               ,20);
   hr_utility.set_location(' award type   = ' || p_award_type                 ,20);
   hr_utility.set_location(' group award  = ' || p_group_award                ,20);
   hr_utility.set_location(' tbd          = ' || p_tangible_benefit_dollars   ,20);
   hr_utility.set_location(' date award   = ' || p_date_award_earned          ,20);
   hr_utility.set_location(' Appr Code    = ' || p_appropriation_code         ,20);
  end loop;

  hr_utility.set_location('Leaving  ' || l_proc,35);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

   p_award_amount             := Null;
   p_award_uom                := Null;
   p_award_percentage         := Null;
   p_award_agency             := Null;
   p_award_type               := Null;
   p_group_award              := Null;
   p_tangible_benefit_dollars := Null;
   p_date_award_earned        := Null;
   p_appropriation_code       := Null;

   hr_utility.set_location('Leaving  ' || l_proc,40);
   RAISE;

END get_award_details_shadow;


PROCEDURE main_awards
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_action_type       in      varchar2,
 p_errbuf            out nocopy     varchar2, --\___  error log
 p_status            out nocopy     varchar2, --||
 p_retcode           out nocopy     number,    --/     in conc. manager.
 p_maxcheck         out nocopy number
)


IS

--
-- local variables
--
  l_errbuf          varchar2(2000) := NULL;
  l_status          varchar2(10)   := NULL;
  l_retcode         number         := NULL;
  l_status_flag     varchar2(1)    := NULL;

  l_proc            varchar2(72) :=   g_package || 'main_awards';
  l_effective_date  date;
  l_rpa_type        varchar2(30) := 'A';
  l_prog_name       varchar2(30);

CURSOR cur_ma IS
  SELECT trunc(effective_date) effective_date
  FROM   ghr_mass_awards
  WHERE  mass_award_id = p_mass_award_id;

CURSOR cur_get_seq is
  SELECT to_char(ghr_process_log_s.nextval)
  FROM sys.dual;


BEGIN

  hr_utility.set_location('Entering ' || l_proc,5);
  l_effective_date          :=  Null;

  for cur_ma_rec in cur_ma loop
    hr_utility.set_location( l_proc,10);
    l_effective_date          := cur_ma_rec.effective_date;
  end loop;

  open cur_get_seq;
  fetch cur_get_seq into l_prog_name;
  close cur_get_seq;

  l_prog_name := 'GHR_MAW_PKG-' || l_prog_name;
  g_log_name  := l_prog_name;

  hr_utility.set_location( l_proc,20);
  upd_elig_flag_bef_selection
     ( p_mass_award_id     => p_mass_award_id,
       p_rpa_type          => l_rpa_type,
       p_effective_date    => l_effective_date);


  hr_utility.set_location( l_proc,30);
  ghr_mass_awards_elig.get_eligible_employees
     ( p_mass_award_id     => p_mass_award_id,
       p_action_type       => p_action_type,
       p_errbuf            => l_errbuf,
       p_status            => l_status,
       p_retcode           => l_retcode,
		   p_maxcheck          => p_maxcheck);

       p_errbuf          := l_errbuf;
       p_status          := l_status;
       p_retcode         := l_retcode;

  if l_retcode = 0 then
     l_status_flag := 'P';
  else
     l_status_flag := 'E';
  end if;

  hr_utility.set_location( l_proc,40);
  del_elig_flag_aft_selection
      ( p_mass_award_id     => p_mass_award_id,
        p_rpa_type          => l_rpa_type,
        p_effective_date    => l_effective_date);

  hr_utility.set_location( 'Updating ghr_mass_awards table ...' ||l_proc,50);

  IF p_action_type = 'FINAL' THEN
     update ghr_mass_awards set status_flag = l_status_flag
     where mass_award_id = p_mass_award_id;
  END IF;

  hr_utility.set_location('Leaving  ' || l_proc,60);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_errbuf          := NULL;
       p_status          := NULL;
       p_retcode         := NULL;
		   p_maxcheck        := NULL;
   hr_utility.set_location('Leaving  ' || l_proc,65);
   RAISE;

END main_awards;

PROCEDURE upd_elig_flag_bef_selection
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date
)

is

l_proc               varchar2(72) :=  g_package || 'upd_elig_flag_bef_selection';
l_cntr               number;

begin

    hr_utility.set_location('Entering    ' || l_proc,5);

    select count(*) into l_cntr
    from ghr_pa_requests
    where mass_action_id = p_mass_award_id
    and   rpa_type       = p_rpa_type
    and   pa_notification_id is null;

    hr_utility.set_location('No of rows :' || to_char(l_cntr) || l_proc,10);

    update ghr_pa_requests set
           mass_action_eligible_flag = 'N'
    where mass_action_id = p_mass_award_id
    and   rpa_type       = p_rpa_type
    and   pa_notification_id is null;

--- commit; --- Form will commit

    hr_utility.set_location('Leaving     ' || l_proc,15);

end;

PROCEDURE del_elig_flag_aft_selection
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date
)

IS

l_proc              	      varchar2(72) :=  g_package || 'del_elig_flag_aft_selection';
l_pa_request_id               ghr_pa_requests.pa_request_id%type;

CURSOR cur_rpa_del is
SELECT pa_request_id
FROM   ghr_pa_requests
WHERE  mass_action_id  = p_mass_award_id
AND    rpa_type       = p_rpa_type
AND    mass_action_eligible_flag = 'N'
AND    pa_notification_id is null;

BEGIN
   hr_utility.set_location('Entering    ' || l_proc,5);
   FOR cur_rpa_del_rec in cur_rpa_del
   LOOP
    hr_utility.set_location( l_proc,10);
    l_pa_request_id := cur_rpa_del_rec.pa_request_id;

    -- Delete the shadow extra information
    hr_utility.set_location( l_proc,15);
    delete from ghr_pa_request_ei_shadow
    where pa_request_id = l_pa_request_id;

    -- Delete the shadow information
    hr_utility.set_location( l_proc,20);
    delete from ghr_pa_request_shadow
    where pa_request_id = l_pa_request_id;

    -- Delete the database extra information for the given person_id
    hr_utility.set_location( l_proc,25);
    delete from ghr_pa_request_extra_info
    where pa_request_id    = l_pa_request_id;

    -- Delete the database RPA award routing history record for the given person_id
    hr_utility.set_location( l_proc,35);
    delete from ghr_pa_routing_history
    where pa_request_id = l_pa_request_id;

    -- Delete the database RPA award record for the given person_id
    hr_utility.set_location( l_proc,35);
    delete from ghr_pa_requests
    where pa_request_id = l_pa_request_id;
   END LOOP;
END del_elig_flag_aft_selection;

Procedure marpa_process
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_action_type       in      VARCHAR2,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date,
 p_person_id         in      per_people_f.person_id%TYPE,
 p_pa_request_rec    in out nocopy  ghr_pa_requests%rowtype ,
 p_log_text          out nocopy     varchar2,
 p_maxcheck          out nocopy number
)

IS

l_proc                        varchar2(72) :=  g_package || 'marpa_process';
l_pa_request_rec              ghr_pa_requests%rowtype;
l_log_text                    varchar2(2000);
l_result                      boolean;

l_dummy                       varchar2(30);
l_dummy_number                number;
l_pa_request_id               ghr_pa_requests.pa_request_id%TYPE;
l_pa_notification_id          ghr_pa_requests.pa_notification_id%TYPE;
l_rpa_type                    ghr_pa_requests.rpa_type%TYPE;
l_mass_action_select_flag     ghr_pa_requests.mass_action_select_flag%TYPE;
--Bug#3804067 Added l_mass_aciton_comments variable
l_mass_action_comments        ghr_pa_requests.mass_action_comments%TYPE;
l_object_version_number       ghr_pa_requests.object_version_number%type;

l_1_prh_object_version_number ghr_pa_requests.object_version_number%type;
l_1_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%type;
l_2_prh_object_version_number ghr_pa_requests.object_version_number%type;
l_2_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%type;

l_approval_date               date;
l_approving_off_work_title    ghr_pa_requests.APPROVING_OFFICIAL_WORK_TITLE%type;
l_1_approval_status           varchar2(10);

l_bt_award_amount             ghr_pa_requests.award_amount%type;
l_bt_award_percentage         ghr_pa_requests.award_percentage%type;
l_bs_award_amount             ghr_pa_requests.award_amount%type;
l_bs_award_percentage         ghr_pa_requests.award_percentage%type;
l_bd_award_amount             ghr_pa_requests.award_amount%type;
l_bd_award_percentage         ghr_pa_requests.award_percentage%type;

l_t_award_amount              ghr_pa_requests.award_amount%type;
l_t_award_uom                 ghr_pa_requests.award_uom%type;
l_t_award_percentage          ghr_pa_requests.award_percentage%type;

l_d_award_amount              ghr_pa_requests.award_amount%type;
l_d_award_uom                 ghr_pa_requests.award_uom%type;
l_d_award_percentage          ghr_pa_requests.award_percentage%type;

l_s_award_amount              ghr_pa_requests.award_amount%type;
l_s_award_uom                 ghr_pa_requests.award_uom%type;
l_s_award_percentage          ghr_pa_requests.award_percentage%type;

l_u_prh_object_version_number number;
l_i_pa_routing_history_id     number;
l_i_prh_object_version_number number;

ma_rpaerror                   exception;
--Begin Bug # 4748927
l_asg_ei_data  	per_assignment_extra_info%rowtype;
--End Bug # 4748927

   CURSOR cur_rpa_ei  (p_pa_request_id number) is
   SELECT pa_request_extra_info_id,
          object_version_number,
          rei_information9
     FROM ghr_pa_request_extra_info
    WHERE information_type  = l_information_type
      AND pa_request_id     = p_pa_request_id;

l_ei_pa_request_extra_id  ghr_pa_request_extra_info.pa_request_extra_info_id%type;
l_ei_ovn                  ghr_pa_request_extra_info.object_version_number%type;
l_ei_dae                  ghr_pa_request_extra_info.rei_information9%type;

   CURSOR cur_rpa_ei_shadow  (p_pa_request_id number) is
   SELECT pa_request_extra_info_id
     FROM ghr_pa_request_ei_shadow
    WHERE information_type  = l_information_type
      AND pa_request_id     = p_pa_request_id;

l_ei_shadow_id            ghr_pa_request_ei_shadow.pa_request_extra_info_id%type;
L_CNT         number(10);
l_error_flag BOOLEAN;

BEGIN
  l_pa_request_rec := p_pa_request_rec;

 begin

    if p_action_type = 'FINAL' THEN
       l_approval_date                := sysdate;
       l_1_approval_status            := 'APPROVE';
    end if;

    hr_utility.set_location('Entering ...' || l_proc,120);
    hr_utility.set_location('Noa_family_code  value ' || l_pa_request_rec.noa_family_code,120);
     get_pa_request_id_ovn
      ( p_mass_award_id         => p_mass_award_id,
        p_effective_date        => p_effective_date,
        p_person_id             => p_person_id,
        p_pa_request_id         => l_pa_request_id,
        p_pa_notification_id    => l_pa_notification_id,
        p_rpa_type              => l_rpa_type,
        p_mass_action_sel_flag  => l_mass_action_select_flag,
	--Bug#3804067 Added mass action comments
	p_mass_action_comments  => l_mass_action_comments,
        p_object_version_number => l_object_version_number);

     -- Bug#3804067 assigning comments to l_pa_request_rec.
     l_pa_request_rec.mass_action_comments := l_mass_action_comments;

     if l_rpa_type is null then l_rpa_type := 'A'; end if;

IF l_pa_notification_id is null and l_rpa_type = 'A' then
  IF l_pa_request_id is null THEN
   -- Create SF52
   hr_utility.set_location(l_proc,130);
  begin
   l_log_text  := p_action_type || '-Error while creating the PA Request Rec. ';
   g_log_text  := p_action_type || '-Error while creating the PA Request Rec. ';
	 	hr_utility.set_location('In MAR PA Bef Crt'||l_pa_request_rec.award_amount ,36);
-- Bug 3376761
-- check to see if award amount is within 25% of annual basic pay
-- other wise pass an error message in comments column.
   -- Begin Bug# 4748927
   /*l_award_salary :=
                   ghr_pay_calc.convert_amount(l_pa_request_rec.from_basic_pay
                                              ,l_pa_request_rec.from_pay_basis,'PA');*/

	ghr_history_fetch.fetch_asgei(
							p_assignment_id    => l_pa_request_rec.employee_assignment_id,
							p_information_type => 'GHR_US_ASG_SF52',
							p_date_effective   => p_effective_date,
							p_asg_ei_data      => l_asg_ei_data);
	ghr_pay_calc.award_amount_calc (
						 p_position_id		=> l_pa_request_rec.to_position_id
						,p_pay_plan			=> l_pa_request_rec.from_pay_plan
						,p_award_percentage => l_pa_request_rec.award_percentage
						,p_user_table_id	=> l_pa_request_rec.from_pay_table_identifier
						,p_grade_or_level	=> l_pa_request_rec.from_grade_or_level
						,p_effective_date	=> l_pa_request_rec.effective_date
						,p_basic_pay		=> l_pa_request_rec.from_basic_pay
						,p_adj_basic_pay	=> l_pa_request_rec.from_adj_basic_pay
						,p_duty_station_id	=> l_pa_request_rec.duty_station_id
						,p_prd				=> l_asg_ei_data.aei_information6
						,p_pay_basis		=> l_pa_request_rec.from_pay_basis
						,p_person_id		=> l_pa_request_rec.person_id
--						,p_award_amount		=> l_pa_request_rec.award_amount Bug 5041967
						,p_award_amount		=> l_dummy
						,p_award_salary		=> l_pa_request_rec.award_salary
						);

		IF l_pa_request_rec.award_percentage IS NOT NULL THEN
			l_pa_request_rec.award_amount := l_dummy;
		END IF;
		hr_utility.set_location('l_pa_request_rec.award_amount' || l_pa_request_rec.award_amount,111);
		hr_utility.set_location('l_pa_request_rec.award_salary' || l_pa_request_rec.award_salary,111);

	-- End Bug# 4748927
/*
	IF l_pa_request_rec.award_amount >  ROUND(l_award_salary * 0.25 , 0) THEN
      l_cnt := INSTR(l_pa_request_rec.mass_action_comments, '; Award percentage cannot be greater than 25% of the basic annual pay.',1);
      IF l_cnt =0 then
         l_pa_request_rec.mass_action_comments := l_pa_request_rec.mass_action_comments || 'Award percentage cannot be greater than 25% of the basic annual pay.' ;
      END IF;
   END IF;
*/
	--Pradeep Commented the above and added the below for bug 3934195
	l_error_flag := FALSE;
	check_award_amount (p_noa_code			=> l_pa_request_rec.first_noa_code,
						p_effective_date	=> l_pa_request_rec.effective_date,
						p_award_amount		=> l_pa_request_rec.award_amount,
						p_from_pay_plan		=> l_pa_request_rec.from_pay_plan,
						p_from_basic_pay_pa => l_pa_request_rec.award_salary,
						p_to_position_id	=> l_pa_request_rec.to_position_id,
						p_comments			=> l_pa_request_rec.mass_action_comments,
						p_error_flg			=> l_error_flag
						);
	IF l_error_flag  THEN
		p_maxcheck := 1;
	END IF;
	IF ( l_error_flag
	    AND NVL(l_mass_action_select_flag,'Y') <> 'N' ) THEN
		l_mass_action_select_flag := 'N';
		p_maxcheck := 1;
	END IF;

--END OF Bug 3376761 .

   ghr_sf52_api.create_sf52
   (	p_noa_family_code              => l_pa_request_rec.noa_family_code,
--   	p_routing_group_id             => l_pa_request_rec.routing_group_id,
                                          -- This would be updated after creation.
    	p_proposed_effective_asap_flag => l_pa_request_rec.proposed_effective_asap_flag,
    	p_academic_discipline          => l_pa_request_rec.academic_discipline,
    	p_additional_info_person_id    => l_pa_request_rec.additional_info_person_id,
    	p_additional_info_tel_number   => l_pa_request_rec.additional_info_tel_number,
--	p_altered_pa_request_id            => l_pa_request_rec.altered_pa_request_id,
	p_annuitant_indicator              => l_pa_request_rec.annuitant_indicator,
	p_annuitant_indicator_desc         => l_pa_request_rec.annuitant_indicator_desc,
	p_appropriation_code1              => l_pa_request_rec.appropriation_code1,
	p_appropriation_code2              => l_pa_request_rec.appropriation_code2,
	p_authorized_by_person_id          => l_pa_request_rec.authorized_by_person_id,
	p_authorized_by_title              => l_pa_request_rec.authorized_by_title,
	p_award_amount                     => l_pa_request_rec.award_amount,
	p_award_uom                        => l_pa_request_rec.award_uom,
	p_bargaining_unit_status           => l_pa_request_rec.bargaining_unit_status,
	p_citizenship                      => l_pa_request_rec.citizenship,
	p_concurrence_date             	   => l_pa_request_rec.concurrence_date,
	p_custom_pay_calc_flag             => l_pa_request_rec.custom_pay_calc_flag, -- Expecxt
	p_duty_station_code                => l_pa_request_rec.duty_station_code,
	p_duty_station_desc                => l_pa_request_rec.duty_station_desc,
	p_duty_station_id                  => l_pa_request_rec.duty_station_id,
	p_duty_station_location_id         => l_pa_request_rec.duty_station_location_id,
	p_education_level                  => l_pa_request_rec.education_level,
	p_effective_date                   => l_pa_request_rec.effective_date,
	p_employee_assignment_id           => l_pa_request_rec.employee_assignment_id,
	p_employee_date_of_birth           => l_pa_request_rec.employee_date_of_birth,
	p_employee_first_name              => l_pa_request_rec.employee_first_name,
	p_employee_last_name               => l_pa_request_rec.employee_last_name,
	p_employee_middle_names            => l_pa_request_rec.employee_middle_names,
	p_employee_national_identifier     => l_pa_request_rec.employee_national_identifier,
	p_fegli                            => l_pa_request_rec.fegli,
	p_fegli_desc                       => l_pa_request_rec.fegli_desc,
	p_first_action_la_code1            => l_pa_request_rec.first_action_la_code1,
	p_first_action_la_code2            => l_pa_request_rec.first_action_la_code2,
	p_first_action_la_desc1            => l_pa_request_rec.first_action_la_desc1,
	p_first_action_la_desc2            => l_pa_request_rec.first_action_la_desc2,
--	p_first_noa_cancel_or_correct      => l_pa_request_rec.first_noa_cancel_or_correct,
	p_first_noa_code                   => l_pa_request_rec.first_noa_code,
	p_first_noa_desc                   => l_pa_request_rec.first_noa_desc,
	p_first_noa_id                     => l_pa_request_rec.first_noa_id,
        p_first_noa_information1           => l_pa_request_rec.first_noa_information1,
	p_first_noa_pa_request_id          => l_pa_request_rec.first_noa_pa_request_id,
	p_flsa_category                    => l_pa_request_rec.flsa_category,
	p_from_adj_basic_pay               => l_pa_request_rec.from_adj_basic_pay,
	p_from_basic_pay                   => l_pa_request_rec.from_basic_pay,
	p_from_grade_or_level              => l_pa_request_rec.from_grade_or_level,
	p_from_locality_adj                => l_pa_request_rec.from_locality_adj,
	p_from_occ_code                    => l_pa_request_rec.from_occ_code,
	p_from_other_pay_amount            => l_pa_request_rec.from_other_pay_amount,
	p_from_pay_basis                   => l_pa_request_rec.from_pay_basis,
	p_from_pay_plan                    => l_pa_request_rec.from_pay_plan,
    -- FWFA Changes Bug#4444609
    p_input_pay_rate_determinant       => l_pa_request_rec.input_pay_rate_determinant,
    p_from_pay_table_identifier        => l_pa_request_rec.from_pay_table_identifier,
    -- FWFA Changes
	p_from_position_id                 => l_pa_request_rec.from_position_id,
	p_from_position_org_line1          => l_pa_request_rec.from_position_org_line1,
	p_from_position_org_line2          => l_pa_request_rec.from_position_org_line2,
	p_from_position_org_line3          => l_pa_request_rec.from_position_org_line3,
	p_from_position_org_line4          => l_pa_request_rec.from_position_org_line4,
	p_from_position_org_line5          => l_pa_request_rec.from_position_org_line5,
	p_from_position_org_line6          => l_pa_request_rec.from_position_org_line6,
	p_from_position_number             => l_pa_request_rec.from_position_number,
	p_from_position_seq_no             => l_pa_request_rec.from_position_seq_no,
	p_from_position_title              => l_pa_request_rec.from_position_title,
	p_from_step_or_rate                => l_pa_request_rec.from_step_or_rate,
	p_from_total_salary                => l_pa_request_rec.from_total_salary,
	p_functional_class                 => l_pa_request_rec.functional_class,
	p_notepad                          => l_pa_request_rec.notepad,
	p_part_time_hours                  => l_pa_request_rec.part_time_hours,
    -- FWFA Changes Bug#4444609
	p_pay_rate_determinant             => l_pa_request_rec.pay_rate_determinant,
    -- FWFA Changes
	p_person_id                        => l_pa_request_rec.person_id,
	p_position_occupied                => l_pa_request_rec.position_occupied,
	p_proposed_effective_date          => l_pa_request_rec.proposed_effective_date,
	p_requested_by_person_id           => l_pa_request_rec.requested_by_person_id,
	p_requested_by_title               => l_pa_request_rec.requested_by_title,
	p_requested_date                   => l_pa_request_rec.requested_date,
	p_requesting_office_remarks_de     => l_pa_request_rec.requesting_office_remarks_desc,
        p_requesting_office_remarks_fl     => l_pa_request_rec.requesting_office_remarks_flag,
--	p_request_number                   => l_pa_request_rec.request_number,
	p_resign_and_retire_reason_des     => l_pa_request_rec.resign_and_retire_reason_desc,
	p_retirement_plan                  => l_pa_request_rec.retirement_plan,
	p_retirement_plan_desc             => l_pa_request_rec.retirement_plan_desc,
--	p_second_action_la_code1           => l_pa_request_rec.second_action_la_code1,
--	p_second_action_la_code2           => l_pa_request_rec.second_action_la_code2,
--	p_second_action_la_desc1           => l_pa_request_rec.second_action_la_desc1,
--	p_second_action_la_desc2           => l_pa_request_rec.second_action_la_desc2,
--	p_second_noa_code                  => l_pa_request_rec.second_noa_code,
--	p_second_noa_desc                  => l_pa_request_rec.second_noa_desc,
--	p_second_noa_id                    => l_pa_request_rec.second_noa_id,
--	p_second_noa_pa_request_id         => l_pa_request_rec.
	p_service_comp_date                => l_pa_request_rec.service_comp_date,
	p_supervisory_status               => l_pa_request_rec.supervisory_status,
	p_tenure                           => l_pa_request_rec.tenure,
	p_to_adj_basic_pay                 => l_pa_request_rec.to_adj_basic_pay,
	p_to_basic_pay                     => l_pa_request_rec.to_basic_pay,
	p_to_grade_id                      => l_pa_request_rec.to_grade_id,
	p_to_grade_or_level                => l_pa_request_rec.to_grade_or_level,
	p_to_job_id                        => l_pa_request_rec.to_job_id,
	p_to_locality_adj                  => l_pa_request_rec.to_locality_adj,
	p_to_occ_code                      => l_pa_request_rec.to_occ_code,
	p_to_organization_id               => l_pa_request_rec.to_organization_id,
	p_to_other_pay_amount              => l_pa_request_rec.to_other_pay_amount,
	p_to_au_overtime                   => l_pa_request_rec.to_au_overtime,
	p_to_auo_premium_pay_indicator     => l_pa_request_rec.to_auo_premium_pay_indicator,
	p_to_availability_pay              => l_pa_request_rec.to_availability_pay,
	p_to_ap_premium_pay_indicator      => l_pa_request_rec.to_ap_premium_pay_indicator,
	p_to_retention_allowance           => l_pa_request_rec.to_retention_allowance,
	p_to_supervisory_differential      => l_pa_request_rec.to_supervisory_differential,
	p_to_staffing_differential         => l_pa_request_rec.to_staffing_differential,
	p_to_pay_basis                     => l_pa_request_rec.to_pay_basis,
	p_to_pay_plan                      => l_pa_request_rec.to_pay_plan,
	p_to_position_id                   => l_pa_request_rec.to_position_id,
	p_to_position_org_line1            => l_pa_request_rec.to_position_org_line1,
	p_to_position_org_line2            => l_pa_request_rec.to_position_org_line2,
	p_to_position_org_line3            => l_pa_request_rec.to_position_org_line3,
	p_to_position_org_line4            => l_pa_request_rec.to_position_org_line4,
	p_to_position_org_line5            => l_pa_request_rec.to_position_org_line5,
	p_to_position_org_line6            => l_pa_request_rec.to_position_org_line6,
	p_to_position_number               => l_pa_request_rec.to_position_number,
 	p_to_position_seq_no               => l_pa_request_rec.to_position_seq_no,
	p_to_position_title                => l_pa_request_rec.to_position_title,
	p_to_step_or_rate                  => l_pa_request_rec.to_step_or_rate,
	p_to_total_salary                  => l_pa_request_rec.to_total_salary,
	p_veterans_preference              => l_pa_request_rec.veterans_preference,
	p_veterans_pref_for_rif            => l_pa_request_rec.veterans_pref_for_rif,
	p_veterans_status                  => l_pa_request_rec.veterans_status,
	p_work_schedule                    => l_pa_request_rec.work_schedule,
	p_work_schedule_desc               => l_pa_request_rec.work_schedule_desc,
	p_year_degree_attained             => l_pa_request_rec.year_degree_attained,
	p_first_lac1_information1          => l_pa_request_rec.first_lac1_information1,
	p_first_lac1_information2          => l_pa_request_rec.first_lac1_information2,
	p_first_lac1_information3          => l_pa_request_rec.first_lac1_information3,
	p_first_lac1_information4          => l_pa_request_rec.first_lac1_information4,
	p_first_lac1_information5          => l_pa_request_rec.first_lac1_information5,
	p_first_lac2_information1          => l_pa_request_rec.first_lac2_information1,
	p_first_lac2_information2          => l_pa_request_rec.first_lac2_information2,
	p_first_lac2_information3          => l_pa_request_rec.first_lac2_information3,
	p_first_lac2_information4          => l_pa_request_rec.first_lac2_information4,
	p_first_lac2_information5          => l_pa_request_rec.first_lac2_information5,
        p_second_lac1_information1         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information2         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information3         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information4         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information5         => l_pa_request_rec.second_lac1_information1,
        p_print_sf50_flag                  => 'N', -- true for all ??
	p_printer_name                     => Null,
	p_1_attachment_modified_flag       => 'N',
	p_1_approved_flag                  => 'N',
	p_1_user_name_acted_on             => Null,
	p_1_action_taken                   => 'NOT_ROUTED',
	p_2_user_name_routed_to            => Null,
	p_2_groupbox_id                    => Null,
	p_2_routing_list_id                => Null,
	p_2_routing_seq_number             => Null,
        p_to_retention_allow_percentag => l_pa_request_rec.to_retention_allow_percentage,
        p_to_supervisory_diff_percenta => l_pa_request_rec.to_supervisory_diff_percentage,
        p_to_staffing_diff_percentage  => l_pa_request_rec.to_staffing_diff_percentage ,
        p_award_percentage             => l_pa_request_rec.award_percentage,
	p_pa_request_id                    => l_pa_request_rec.pa_request_id,
	p_par_object_version_number        => l_pa_request_rec.object_version_number,
	p_1_pa_routing_history_id          => l_1_pa_routing_history_id,
	p_1_prh_object_version_number      => l_1_prh_object_version_number,
	p_2_pa_routing_history_id          => l_2_pa_routing_history_id,
	-- Bug#4486823 RRR Changes
	p_award_salary					   => l_pa_request_rec.award_salary,
  -- Bug#4486823 RRR Changes
	p_2_prh_object_version_number      => l_2_prh_object_version_number,
        p_rpa_type                     => p_rpa_type,
        p_mass_action_id               => p_mass_award_id,
        p_mass_action_eligible_flag    => 'Y',

		  --p_mass_action_select_flag  => 'Y'
		  p_mass_action_select_flag    => NVL(l_mass_action_select_flag,'Y')

   ,p_approving_official_full_name     => l_pa_request_rec.approving_official_full_name
   ,p_approval_date                    => l_approval_date
   ,p_approving_official_work_titl     => l_pa_request_rec.approving_official_work_title
   ,p_1_approval_status                => l_1_approval_status
   -- Bug 3376761
   ,p_mass_action_comments             => l_pa_request_rec.mass_action_comments
   -- End of Bug 3376761
    );
     exception
          WHEN OTHERS THEN
           hr_utility.set_location( ' Sql error : '||sqlerrm(sqlcode) ,132);
           hr_utility.set_location(l_proc,132);
           l_log_text := substr(l_log_text || ' Sql error : '|| sqlerrm(sqlcode),1,2000);
           g_log_text := substr(l_log_text || ' Sql error : '|| sqlerrm(sqlcode),1,2000);
			  raise ma_rpaerror;
   end;

   hr_utility.set_location(l_proc,135);
   begin
      l_log_text  := p_action_type || '-Error After creating the RPA before upd ';
      g_log_text  := p_action_type || '-Error After creating the RPA before upd ';
      ghr_par_upd.upd(
           p_pa_request_id   	  => l_pa_request_rec.pa_request_id,
           p_object_version_number   => l_pa_request_rec.object_version_number,
           p_agency_code             => l_pa_request_rec.agency_code,
           p_employee_dept_or_agency => l_pa_request_rec.employee_dept_or_agency,
           p_personnel_office_id     => l_pa_request_rec.personnel_office_id,
           p_from_office_symbol      => l_pa_request_rec.from_office_symbol);
   exception
          WHEN OTHERS THEN
           hr_utility.set_location(l_proc,136);
           l_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
           g_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
           raise ma_rpaerror;
   end;

   hr_utility.set_location(l_proc,138);
   create_shadow_row (p_rpa_data  => l_pa_request_rec);
   hr_utility.set_location(' Shadow created ...'|| l_proc,138);

 ----Initialize the RPA extra information
   FOR cur_rpa_ei_rec in cur_rpa_ei(l_pa_request_rec.pa_request_id)
   LOOP
   hr_utility.set_location( l_proc,10);
        l_ei_pa_request_extra_id := cur_rpa_ei_rec.pa_request_extra_info_id;
        l_ei_ovn                 := cur_rpa_ei_rec.object_version_number;
        l_ei_dae                 := cur_rpa_ei_rec.rei_information9;
       exit;
   END LOOP;

   IF l_ei_dae is not null then
	   IF l_ei_pa_request_extra_id is not null then
			  ghr_par_extra_info_api.update_pa_request_extra_info
				  (p_validate                    => false,
				   p_rei_information3            => null,
				   p_rei_information4            => null,
				   p_rei_information6            => null,
				   p_rei_information7            => null,
				   p_rei_information9            => null,
				   p_rei_information10           => null,
				   p_pa_request_extra_info_id    => l_ei_pa_request_extra_id,
				   p_object_version_number       => l_ei_ovn );
	   END IF;
   END IF;

----Initialize the RPA extra information Shadow.
   FOR cur_rpa_ei_shadow_rec in cur_rpa_ei_shadow(l_pa_request_rec.pa_request_id)
   LOOP
	hr_utility.set_location( l_proc,10);
       l_ei_shadow_id := cur_rpa_ei_shadow_rec.pa_request_extra_info_id;
       exit;
   END LOOP;

   IF l_ei_shadow_id is not null Then
		update ghr_pa_request_ei_shadow
                 set rei_information3  =  null,
                     rei_information4  =  null,
                     rei_information6  =  null,
                     rei_information7  =  null,
                     rei_information9  =  null,
                     rei_information10 =  null
          where pa_request_extra_info_id = l_ei_shadow_id;
   END IF;

----End Initialize.

   hr_utility.set_location(l_proc,140);
   refresh_award_details
     (
      p_mass_award_id      => p_mass_award_id,
      p_rpa_type           => p_rpa_type,
      p_effective_date     => p_effective_date,
      p_person_id          => p_person_id,
      p_pa_request_id      => l_pa_request_rec.pa_request_id );

   ELSE

  --- Update SF52
   l_pa_request_rec.award_amount      := Null;
   l_pa_request_rec.award_uom         := Null;
   l_pa_request_rec.award_percentage  := Null;

   hr_utility.set_location(l_proc,141);
----- Get Award details from the template and also extra information
   get_award_details
       ( p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => 'TA',
         p_effective_date            => p_effective_date,
         p_person_id                 => null,
         p_award_amount              => l_t_award_amount,
         p_award_uom                 => l_t_award_uom,
         p_award_percentage          => l_t_award_percentage,
         p_award_agency              => l_dummy,
         p_award_type                => l_dummy,
         p_group_award               => l_dummy,
         p_tangible_benefit_dollars  => l_dummy,
         p_date_award_earned         => l_dummy,
         p_appropriation_code        => l_dummy);

    l_bt_award_amount                 := l_t_award_amount;
    l_bt_award_percentage             := l_t_award_percentage;
	hr_utility.set_location('l_bt_award_amount' || l_bt_award_amount,142);
	hr_utility.set_location(l_proc,142);
----- Get Award details from the database
   get_award_details
       ( p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => p_rpa_type,
         p_effective_date            => p_effective_date,
         p_person_id                 => p_person_id,
         p_award_amount              => l_d_award_amount,
         p_award_uom                 => l_d_award_uom,
         p_award_percentage          => l_d_award_percentage,
         p_award_agency              => l_dummy,
         p_award_type                => l_dummy,
         p_group_award               => l_dummy,
         p_tangible_benefit_dollars  => l_dummy,
         p_date_award_earned         => l_dummy,
         p_appropriation_code        => l_dummy);

      l_bd_award_amount              := l_d_award_amount;
      l_bd_award_percentage          := l_d_award_percentage;
	hr_utility.set_location('l_bd_award_amount' || l_bd_award_amount,142);
      hr_utility.set_location(l_proc,143);
----- Get Award details from the shadow
      get_award_details_shadow
          ( p_pa_request_id            => l_pa_request_id,
            p_award_amount             => l_s_award_amount,
            p_award_uom                => l_s_award_uom,
            p_award_percentage         => l_s_award_percentage,
            p_award_agency             => l_dummy,
            p_award_type               => l_dummy,
            p_group_award              => l_dummy,
            p_tangible_benefit_dollars => l_dummy,
            p_date_award_earned        => l_dummy,
            p_appropriation_code       => l_dummy );

      l_bs_award_amount              := l_s_award_amount;
      l_bs_award_percentage          := l_s_award_percentage;
	hr_utility.set_location('l_bs_award_amount' || l_bs_award_amount,142);

      hr_utility.set_location(l_proc,144);
      set_ei
      (p_shadow       => l_s_award_amount,
       p_template     => l_t_award_amount,
       p_person       => l_d_award_amount);

      set_ei
      (p_shadow       => l_s_award_uom,
       p_template     => l_t_award_uom,
       p_person       => l_d_award_uom);

      set_ei
      (p_shadow       => l_s_award_percentage,
       p_template     => l_t_award_percentage,
       p_person       => l_d_award_percentage);
		-- Begin Bug# 4748927
		/*
       l_award_salary :=
        ghr_pay_calc.convert_amount(l_pa_request_rec.from_basic_pay
                                   ,l_pa_request_rec.from_pay_basis,'PA');*/

      if l_d_award_percentage is not null then
		 l_d_award_amount :=
         ROUND(l_pa_request_rec.award_salary * NVL(l_d_award_percentage,0) / 100 , 0);
      end if;
      if l_s_award_percentage is not null then
		 l_s_award_amount :=
         ROUND(l_pa_request_rec.award_salary * NVL(l_s_award_percentage,0) / 100 , 0);
      end if;

	  -- End Bug# 4748927

   l_pa_request_rec.award_amount      := l_d_award_amount;
   l_pa_request_rec.award_uom         := l_d_award_uom;
   l_pa_request_rec.award_percentage  := l_d_award_percentage;

	hr_utility.set_location('l_pa_request_rec.award_amount' || l_pa_request_rec.award_amount,111);
	hr_utility.set_location('l_pa_request_rec.award_salary' || l_pa_request_rec.award_salary,111);
	-- End Sundar Test

-- Bug 3376761
-- check to see if the award amount is within 25% of basic pay
-- other write error message in comments column.
/*
   IF l_pa_request_rec.award_amount >  ROUND(l_award_salary * 0.25 , 0) THEN
     l_cnt := INSTR(l_pa_request_rec.mass_action_comments, 'Award percentage cannot be greater than 25% of the basic annual pay.',1);
      IF l_cnt =0 then
         l_pa_request_rec.mass_action_comments := l_pa_request_rec.mass_action_comments || '; Award percentage cannot be greater than 25% of the basic annual pay.' ;
      END IF;
   END IF;
*/
	 	hr_utility.set_location('In MAR PA Bef Upd'||l_pa_request_rec.award_amount ,35);
	--Pradeep Commented the above and added the below for bug 3934195
	l_error_flag := FALSE;
	check_award_amount (p_noa_code			=> l_pa_request_rec.first_noa_code,
						p_effective_date	=> l_pa_request_rec.effective_date,
						p_award_amount		=> l_pa_request_rec.award_amount,
						p_from_pay_plan		=> l_pa_request_rec.from_pay_plan,
						p_from_basic_pay_pa	=> l_pa_request_rec.award_salary,
						p_to_position_id	=> l_pa_request_rec.to_position_id,
						p_comments			=> l_pa_request_rec.mass_action_comments,
						p_error_flg			=> l_error_flag
					);
	IF l_error_flag  THEN
		p_maxcheck := 1;
	END IF;

	IF ( l_error_flag
	   AND NVL(l_mass_action_select_flag,'Y') <> 'N' ) THEN
		l_mass_action_select_flag := 'N';
		p_maxcheck := 1;
	END IF;

--END OF Bug 3376761 .

   hr_utility.set_location(l_proc || 'pa_request_id ' || to_char(l_pa_request_id),150);
   hr_utility.set_location(l_proc || 'Object version ' || to_char(l_object_version_number),151);

  begin
   l_log_text  := 'Error while Updating the PA Request Rec. ';
   g_log_text  := 'Error while Updating the PA Request Rec. ';
   ghr_sf52_api.update_sf52
 (
  p_pa_request_id                => l_pa_request_id,
 -- p_pa_notification_id         => l_pa_request_rec.pa_notification_id,
  p_noa_family_code              => l_pa_request_rec.noa_family_code,
  p_routing_group_id             => l_pa_request_rec.routing_group_id,
  p_par_object_version_number    => l_object_version_number,
  p_proposed_effective_asap_flag => l_pa_request_rec.proposed_effective_asap_flag,
  p_academic_discipline          => l_pa_request_rec.academic_discipline,
  p_additional_info_person_id    => l_pa_request_rec.additional_info_person_id,
  p_additional_info_tel_number   => l_pa_request_rec.additional_info_tel_number ,
  --p_altered_pa_request_id        => l_pa_request_rec.altered_pa_request_id,
  p_annuitant_indicator          => l_pa_request_rec.annuitant_indicator,
  p_annuitant_indicator_desc     => l_pa_request_rec.annuitant_indicator_desc,
  p_appropriation_code1          => l_pa_request_rec.appropriation_code1,
  p_appropriation_code2          => l_pa_request_rec.appropriation_code2,
  p_approval_date                => l_approval_date , --l_pa_request_rec.approval_date,
  p_approving_official_full_name => l_pa_request_rec.approving_official_full_name,
  p_approving_official_work_titl => l_pa_request_rec.approving_official_work_title,
  p_authorized_by_person_id      => l_pa_request_rec.authorized_by_person_id  ,
  p_authorized_by_title          => l_pa_request_rec.authorized_by_title,
  p_award_amount                 => l_pa_request_rec.award_amount,
  p_award_uom                    => l_pa_request_rec.award_uom,
  p_bargaining_unit_status       => l_pa_request_rec.bargaining_unit_status,
  p_citizenship                  => l_pa_request_rec.citizenship,
  p_concurrence_date             => l_pa_request_rec.concurrence_date,
  p_custom_pay_calc_flag         => l_pa_request_rec.custom_pay_calc_flag,
  p_duty_station_code            => l_pa_request_rec.duty_station_code,
  p_duty_station_desc            => l_pa_request_rec.duty_station_desc,
  p_duty_station_id              => l_pa_request_rec.duty_station_id,
  p_duty_station_location_id     => l_pa_request_rec.duty_station_location_id,
  p_education_level              => l_pa_request_rec.education_level,
  p_effective_date               => l_pa_request_rec.effective_date,
  p_employee_assignment_id       => l_pa_request_rec.employee_assignment_id,
  p_employee_date_of_birth       => l_pa_request_rec.employee_date_of_birth,
  p_employee_first_name          => l_pa_request_rec.employee_first_name,
  p_employee_last_name           => l_pa_request_rec.employee_last_name,
  p_employee_middle_names        => l_pa_request_rec.employee_middle_names,
  p_employee_national_identifier => l_pa_request_rec.employee_national_identifier,
  p_fegli                        => l_pa_request_rec.fegli,
  p_fegli_desc                   => l_pa_request_rec.fegli_desc,
  p_first_action_la_code1        => l_pa_request_rec.first_action_la_code1,
  p_first_action_la_code2        => l_pa_request_rec.first_action_la_code2,
  p_first_action_la_desc1        => l_pa_request_rec.first_action_la_desc1,
  p_first_action_la_desc2        => l_pa_request_rec.first_action_la_desc2,
  p_first_noa_cancel_or_correct  => l_pa_request_rec.first_noa_cancel_or_correct,
  p_first_noa_code               => l_pa_request_rec.first_noa_code,
  p_first_noa_desc               => l_pa_request_rec.first_noa_desc,
  p_first_noa_id                 => l_pa_request_rec.first_noa_id,
  p_first_noa_pa_request_id      => l_pa_request_rec.first_noa_pa_request_id,
  p_flsa_category                => l_pa_request_rec.flsa_category,
  p_forwarding_address_line1     => l_pa_request_rec.forwarding_address_line1,
  p_forwarding_address_line2     => l_pa_request_rec.forwarding_address_line2,
  p_forwarding_address_line3     => l_pa_request_rec.forwarding_address_line3,
  p_forwarding_country           => l_pa_request_rec.forwarding_country,
  p_forwarding_country_short_nam => l_pa_request_rec.forwarding_country_short_name,
  p_forwarding_postal_code       => l_pa_request_rec.forwarding_postal_code,
  p_forwarding_region_2          => l_pa_request_rec.forwarding_region_2,
  p_forwarding_town_or_city      => l_pa_request_rec.forwarding_town_or_city,
  p_from_adj_basic_pay           => l_pa_request_rec.from_adj_basic_pay,
  p_from_basic_pay               => l_pa_request_rec.from_basic_pay,
  p_from_grade_or_level          => l_pa_request_rec.from_grade_or_level,
  p_from_locality_adj            => l_pa_request_rec.from_locality_adj,
  p_from_occ_code                => l_pa_request_rec.from_occ_code,
  p_from_other_pay_amount        => l_pa_request_rec.from_other_pay_amount,
  p_from_pay_basis               => l_pa_request_rec.from_pay_basis,
  p_from_pay_plan                => l_pa_request_rec.from_pay_plan,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant       => l_pa_request_rec.input_pay_rate_determinant,
  p_from_pay_table_identifier        => l_pa_request_rec.from_pay_table_identifier,
  -- FWFA Changes
  p_from_position_id             => l_pa_request_rec.from_position_id,
  p_from_position_org_line1      => l_pa_request_rec.from_position_org_line1,
  p_from_position_org_line2      => l_pa_request_rec.from_position_org_line2,
  p_from_position_org_line3      => l_pa_request_rec.from_position_org_line3,
  p_from_position_org_line4      => l_pa_request_rec.from_position_org_line4,
  p_from_position_org_line5      => l_pa_request_rec.from_position_org_line5,
  p_from_position_org_line6      => l_pa_request_rec.from_position_org_line6,
  p_from_position_number         => l_pa_request_rec.from_position_number,
  p_from_position_seq_no         => l_pa_request_rec.from_position_seq_no,
  p_from_position_title          => l_pa_request_rec.from_position_title,
  p_from_step_or_rate            => l_pa_request_rec.from_step_or_rate,
  p_from_total_salary            => l_pa_request_rec.from_total_salary,
  p_functional_class             => l_pa_request_rec.functional_class,
  p_notepad                      => l_pa_request_rec.notepad,
  p_part_time_hours              => l_pa_request_rec.part_time_hours,
  -- FWFA Changes Bug#4444609
  p_pay_rate_determinant         => l_pa_request_rec.pay_rate_determinant,
  p_person_id                    => l_pa_request_rec.person_id,
  p_position_occupied            => l_pa_request_rec.position_occupied,
  p_proposed_effective_date      => l_pa_request_rec.proposed_effective_date,
  p_requested_by_person_id       => l_pa_request_rec.requested_by_person_id,
  p_requested_by_title           => l_pa_request_rec.requested_by_title,
  p_requested_date               => l_pa_request_rec.requested_date,
  p_requesting_office_remarks_de => l_pa_request_rec.requesting_office_remarks_desc,
  p_requesting_office_remarks_fl => l_pa_request_rec.requesting_office_remarks_flag,
  p_request_number               => l_pa_request_rec.request_number,
  p_resign_and_retire_reason_des => l_pa_request_rec.resign_and_retire_reason_desc,
  p_retirement_plan              => l_pa_request_rec.retirement_plan,
  p_retirement_plan_desc         => l_pa_request_rec.retirement_plan_desc,
  p_second_action_la_code1       => l_pa_request_rec.second_action_la_code1,
  p_second_action_la_code2       => l_pa_request_rec.second_action_la_code2,
  p_second_action_la_desc1       => l_pa_request_rec.second_action_la_desc1,
  p_second_action_la_desc2       => l_pa_request_rec.second_action_la_desc2,
  p_second_noa_cancel_or_correct => l_pa_request_rec.second_noa_cancel_or_correct,
  p_second_noa_code              => l_pa_request_rec.second_noa_code,
  p_second_noa_desc              => l_pa_request_rec.second_noa_desc,
  p_second_noa_id                => l_pa_request_rec.second_noa_id,
  p_second_noa_pa_request_id     => l_pa_request_rec.second_noa_pa_request_id,
  p_service_comp_date            => l_pa_request_rec.service_comp_date,
  p_supervisory_status           => l_pa_request_rec.supervisory_status,
  p_tenure                       => l_pa_request_rec.tenure,
  p_to_adj_basic_pay             => l_pa_request_rec.to_adj_basic_pay,
  p_to_basic_pay                 => l_pa_request_rec.to_basic_pay,
  p_to_grade_id                  => l_pa_request_rec.to_grade_id,
  p_to_grade_or_level            => l_pa_request_rec.to_grade_or_level,
  p_to_job_id                    => l_pa_request_rec.to_job_id,
  p_to_locality_adj              => l_pa_request_rec.to_locality_adj,
  p_to_occ_code                  => l_pa_request_rec.to_occ_code,
  p_to_organization_id           => l_pa_request_rec.to_organization_id,
  p_to_other_pay_amount          => l_pa_request_rec.to_other_pay_amount,
  p_to_au_overtime               => l_pa_request_rec.to_au_overtime,
  p_to_auo_premium_pay_indicator => l_pa_request_rec.to_auo_premium_pay_indicator,
  p_to_availability_pay          => l_pa_request_rec.to_availability_pay,
  p_to_ap_premium_pay_indicator  => l_pa_request_rec.to_ap_premium_pay_indicator,
  p_to_retention_allowance       => l_pa_request_rec.to_retention_allowance,
  p_to_supervisory_differential  => l_pa_request_rec.to_supervisory_differential,
  p_to_staffing_differential     => l_pa_request_rec.to_staffing_differential,
  p_to_pay_basis                 => l_pa_request_rec.to_pay_basis,
  p_to_pay_plan                  => l_pa_request_rec.to_pay_plan,
  -- FWFA Changes
  p_to_pay_table_identifier      => l_pa_request_rec.to_pay_table_identifier,
  -- FWFA Changes
  p_to_position_id               => l_pa_request_rec.to_position_id,
  p_to_position_org_line1        => l_pa_request_rec.to_position_org_line1,
  p_to_position_org_line2        => l_pa_request_rec.to_position_org_line2,
  p_to_position_org_line3        => l_pa_request_rec.to_position_org_line3,
  p_to_position_org_line4        => l_pa_request_rec.to_position_org_line4,
  p_to_position_org_line5        => l_pa_request_rec.to_position_org_line5,
  p_to_position_org_line6        => l_pa_request_rec.to_position_org_line6,
  p_to_position_number           => l_pa_request_rec.to_position_number,
  p_to_position_seq_no           => l_pa_request_rec.to_position_seq_no,
  p_to_position_title            => l_pa_request_rec.to_position_title,
  p_to_step_or_rate              => l_pa_request_rec.to_step_or_rate,
  p_to_total_salary              => l_pa_request_rec.to_total_salary,
  p_veterans_preference          => l_pa_request_rec.veterans_preference,
  p_veterans_pref_for_rif        => l_pa_request_rec.veterans_pref_for_rif,
  p_veterans_status              => l_pa_request_rec.veterans_status,
  p_work_schedule                => l_pa_request_rec.work_schedule,
  p_work_schedule_desc           => l_pa_request_rec.work_schedule_desc,
  p_year_degree_attained         => l_pa_request_rec.year_degree_attained,
  p_first_noa_information1       => l_pa_request_rec.first_noa_information1,
  p_first_noa_information2       => l_pa_request_rec.first_noa_information2,
  p_first_noa_information3       => l_pa_request_rec.first_noa_information3,
  p_first_noa_information4       => l_pa_request_rec.first_noa_information4,
  p_first_noa_information5       => l_pa_request_rec.first_noa_information5,
  p_second_lac1_information1     => l_pa_request_rec.second_lac1_information1,
  p_second_lac1_information2     => l_pa_request_rec.second_lac1_information2,
  p_second_lac1_information3     => l_pa_request_rec.second_lac1_information3,
  p_second_lac1_information4     => l_pa_request_rec.second_lac1_information4,
  p_second_lac1_information5     => l_pa_request_rec.second_lac1_information5,
  p_second_lac2_information1     => l_pa_request_rec.second_lac2_information1,
  p_second_lac2_information2     => l_pa_request_rec.second_lac2_information2,
  p_second_lac2_information3     => l_pa_request_rec.second_lac2_information3,
  p_second_lac2_information4     => l_pa_request_rec.second_lac2_information4,
  p_second_lac2_information5     => l_pa_request_rec.second_lac2_information5,
  p_second_noa_information1      => l_pa_request_rec.second_noa_information1,
  p_second_noa_information2      => l_pa_request_rec.second_noa_information2,
  p_second_noa_information3      => l_pa_request_rec.second_noa_information3,
  p_second_noa_information4      => l_pa_request_rec.second_noa_information4,
  p_second_noa_information5      => l_pa_request_rec.second_noa_information5,
  p_first_lac1_information1      => l_pa_request_rec.first_lac1_information1,
  p_first_lac1_information2      => l_pa_request_rec.first_lac1_information2,
  p_first_lac1_information3      => l_pa_request_rec.first_lac1_information3,
  p_first_lac1_information4      => l_pa_request_rec.first_lac1_information4,
  p_first_lac1_information5      => l_pa_request_rec.first_lac1_information5,
  p_first_lac2_information1      => l_pa_request_rec.first_lac2_information1,
  p_first_lac2_information2      => l_pa_request_rec.first_lac2_information2,
  p_first_lac2_information3      => l_pa_request_rec.first_lac2_information3,
  p_first_lac2_information4      => l_pa_request_rec.first_lac2_information4,
  p_first_lac2_information5      => l_pa_request_rec.first_lac2_information5,
-----  p_print_sf50_flag
-----  p_printer_name
-----  p_u_attachment_modified_flag   => l_pa_request_rec.u_attachment_modified_flag,
-----  p_u_approved_flag              => l_pa_request_rec.u_approved_flag,
-----  p_u_user_name_acted_on         => l_pa_request_rec.u_user_name_acted_on,
       p_u_action_taken               => 'NOT_ROUTED',
 p_u_approval_status            => l_1_approval_status, --l_pa_request_rec.u_approval_status,
-----  p_i_user_name_routed_to        => l_pa_request_rec.i_user_name_routed_to,
-----  p_i_groupbox_id                => l_pa_request_rec.i_groupbox_id,
-----  p_i_routing_list_id            => l_pa_request_rec.i_routing_list_id,
-----  p_i_routing_seq_number         => l_pa_request_rec.i_routing_seq_number,

  p_to_retention_allow_percentag => l_pa_request_rec.to_retention_allow_percentage,
  p_to_supervisory_diff_percenta => l_pa_request_rec.to_supervisory_diff_percentage,
  p_to_staffing_diff_percentage  => l_pa_request_rec.to_staffing_diff_percentage,
  p_award_percentage             => l_pa_request_rec.award_percentage,
  p_rpa_type                     => p_rpa_type,
  p_mass_action_id               => p_mass_award_id,
  p_mass_action_eligible_flag    => 'Y',
  p_u_prh_object_version_number  => l_u_prh_object_version_number ,
  p_i_pa_routing_history_id      => l_i_pa_routing_history_id,
  p_i_prh_object_version_number  => l_i_prh_object_version_number

  -- Bug 3376761
 ,p_mass_action_comments       => l_pa_request_rec.mass_action_comments
  -- End of Bug 3376761
     -- Bug#4486823 RRR Changes
	,p_award_salary					   => l_pa_request_rec.award_salary
  -- Bug#4486823 RRR Changes
  ,p_mass_action_select_flag          => NVL(l_mass_action_select_flag,'Y')
  );
  exception
          WHEN OTHERS THEN
           hr_utility.set_location(l_proc,153);
           l_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
           g_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
           raise ma_rpaerror;
  end;

   hr_utility.set_location('u ovn   ' || to_char(l_u_prh_object_version_number),154);
   hr_utility.set_location('prh id  ' || to_char(l_i_pa_routing_history_id),154);
   hr_utility.set_location('prh ovn ' || to_char(l_i_prh_object_version_number),154);
   hr_utility.set_location('par upd ' || to_char(l_object_version_number),154);
   hr_utility.set_location('par upd ' || to_char(l_pa_request_id),155);
   hr_utility.set_location(l_proc,156);
   begin
     l_log_text  := p_action_type || '-Error After updating the RPA before upd ';
     g_log_text  := p_action_type || '-Error After updating the RPA before upd ';
     ghr_par_upd.upd(
          p_pa_request_id   	  => l_pa_request_id,
          p_object_version_number   => l_object_version_number,
          p_agency_code             => l_pa_request_rec.agency_code,
          p_employee_dept_or_agency => l_pa_request_rec.employee_dept_or_agency,
          p_personnel_office_id     => l_pa_request_rec.personnel_office_id,
          p_from_office_symbol      => l_pa_request_rec.from_office_symbol);
   exception
            WHEN OTHERS THEN
             hr_utility.set_location(l_proc,153);
             l_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
             g_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
             raise ma_rpaerror;
   end;

   hr_utility.set_location(l_proc,158);
   l_pa_request_rec.award_amount      := l_s_award_amount;
   l_pa_request_rec.award_uom         := l_s_award_uom;
   l_pa_request_rec.award_percentage  := l_s_award_percentage;

   l_pa_request_rec.pa_request_id         := l_pa_request_id;
   l_pa_request_rec.object_version_number := l_object_version_number;
   update_shadow_row (p_rpa_data  => l_pa_request_rec,
                      p_result    => l_result);
   if l_result then
      hr_utility.set_location('Shadow updated ..'|| l_proc,158);
   else
      hr_utility.set_location('Shadow not found..'|| l_proc,158);
   end if;

   hr_utility.set_location(l_proc,160);
   refresh_award_details
     (
      p_mass_award_id      => p_mass_award_id,
      p_rpa_type           => p_rpa_type,
      p_effective_date     => p_effective_date,
      p_person_id          => p_person_id,
      p_pa_request_id      => l_pa_request_id );

   p_pa_request_rec := l_pa_request_rec;
   p_log_text       := l_log_text;

    hr_utility.set_location('Leaving ...' || l_proc,161);

  END IF; ------ Creation of SF52 and Update of SF52
END IF;
 exception when ma_rpaerror then
                p_pa_request_rec := l_pa_request_rec;
                p_log_text       := l_log_text;
           raise;
           when others then
                p_pa_request_rec := l_pa_request_rec;
                p_log_text       := l_log_text;
           hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),162);
           l_log_text := p_action_type || '-Error raised in marpa process others ';
           l_log_text := l_log_text || ' Sql error : '||sqlerrm(sqlcode);
           raise ma_rpaerror;
 end;
   p_pa_request_rec := l_pa_request_rec;
   p_log_text       := l_log_text;
END marpa_process;

Procedure build_rpa_for_mass_awards
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_action_type       in      VARCHAR2,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date,
 p_person_id         in      per_people_f.person_id%TYPE,
 p_assignment_id     in      per_assignments_f.assignment_id%TYPE,
 p_position_id       in      hr_positions_f.position_id%TYPE,
 p_grade_id          in      number,
 p_location_id       in      hr_locations.location_id%TYPE,
 p_job_id            in      number,
 p_errbuf            out nocopy      varchar2, --\   error log
 p_status            out nocopy      varchar2, --||
 p_retcode           out nocopy      number,
 p_maxcheck         out nocopy number--/   in conc. manager.
)

IS

l_proc              	      varchar2(72) :=  g_package || 'build_rpa_for_mass_awards';
l_dummy                       varchar2(30);
l_dummy_number                number;
l_business_group_id           number;

l_pa_request_rec    	      ghr_pa_requests%rowtype;

l_personnel_officer_name      per_people_f.full_name%type;
l_approval_date               date;
l_approving_off_work_title    ghr_pa_requests.APPROVING_OFFICIAL_WORK_TITLE%type;
l_1_approval_status           varchar2(10);

l_1_prh_object_version_number ghr_pa_requests.object_version_number%type;
l_1_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%type;
l_2_prh_object_version_number ghr_pa_requests.object_version_number%type;
l_2_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%type;

l_multiple_error_flag         boolean;
l_result                      boolean;

l_scd_leave         	      varchar2(30);
l_pa_remark_id                ghr_pa_remarks.pa_remark_id%type;
l_pa_request_id               ghr_pa_requests.pa_request_id%TYPE;
l_pa_notification_id          ghr_pa_requests.pa_notification_id%TYPE;
l_rpa_type                    ghr_pa_requests.rpa_type%TYPE;
l_mass_action_select_flag     ghr_pa_requests.mass_action_select_flag%TYPE;
-- Bug#3804067 Added variable l_mass_action_comments
l_mass_action_comments        ghr_pa_requests.mass_action_comments%TYPE;
l_object_version_number       ghr_pa_requests.object_version_number%type;
l_log_text                    varchar2(2000);
l_routing_group_id            ghr_pa_requests.routing_group_id%type;
l_groupbox_id                 ghr_groupboxes.groupbox_id%type;
l_pa_routing_history_id       ghr_pa_routing_history.pa_routing_history_id%type;
l_prh_object_version_number   ghr_pa_routing_history.object_version_number%type;

l_duty_station_location_id    hr_locations.location_id%TYPE;
l_duty_station_id             ghr_duty_stations_v.duty_station_id%TYPE;
l_duty_station_code           ghr_duty_stations_v.duty_station_code%TYPE;
l_duty_station_desc           ghr_duty_stations_v.duty_station_desc%TYPE;
l_appropriation_code1         varchar2(30);
l_appropriation_code2         varchar2(30);

l_bt_award_amount             ghr_pa_requests.award_amount%type;
l_bt_award_percentage         ghr_pa_requests.award_percentage%type;
l_bs_award_amount             ghr_pa_requests.award_amount%type;
l_bs_award_percentage         ghr_pa_requests.award_percentage%type;
l_bd_award_amount             ghr_pa_requests.award_amount%type;
l_bd_award_percentage         ghr_pa_requests.award_percentage%type;

l_t_award_amount              ghr_pa_requests.award_amount%type;
l_t_award_uom                 ghr_pa_requests.award_uom%type;
l_t_award_percentage          ghr_pa_requests.award_percentage%type;

l_d_award_amount              ghr_pa_requests.award_amount%type;
l_d_award_uom                 ghr_pa_requests.award_uom%type;
l_d_award_percentage          ghr_pa_requests.award_percentage%type;

l_s_award_amount              ghr_pa_requests.award_amount%type;
l_s_award_uom                 ghr_pa_requests.award_uom%type;
l_s_award_percentage          ghr_pa_requests.award_percentage%type;

l_u_prh_object_version_number number;
l_i_pa_routing_history_id     number;
l_i_prh_object_version_number number;

l_pa_request_extra_info_id    number;
l_pa_object_version_number    number;
l_lac1                        first_lac1_record;
l_lac2                        first_lac2_record;
l_rpa_action                  varchar2(40);

-- Bug#3648118 Added the following variable to handle NOCOPY behaviour
l_first_noa_desc	      ghr_pa_requests.first_noa_desc%type;

l_pa_request_num_prefix       varchar2(10) := 'MAW';
l_savepoint                   varchar2(1);

groupboxerr                   exception;
rpaerror                      exception;
ma_rpaerror                   exception;
ma_awdpererr                  exception;    -- Bug 3376761 Anil

   CURSOR  c_routing_history is
   SELECT  prh.pa_routing_history_id,
           prh.object_version_number
     FROM  ghr_pa_routing_history prh
    WHERE  prh.pa_request_id  =  l_pa_request_rec.pa_request_id
    ORDER  by  1 desc;

CURSOR cur_maw_name IS
  SELECT name
  FROM   ghr_mass_awards
  WHERE  mass_award_id = p_mass_award_id;

l_maw_name         ghr_mass_awards.name%type;

l_from_basic_pay_pa           number;
l_comments  varchar2(2000);
l_error_flag boolean;
l_status varchar2(2000);
l_asg_ei_data per_assignment_extra_info%rowtype;
Begin
   p_errbuf    := Null;
   p_status    := Null;
   p_retcode   := Null;

   for cur_maw_name_rec in cur_maw_name
   loop
      l_maw_name := cur_maw_name_rec.name;
   end loop;

   hr_utility.set_location('Entering    ' || l_proc,5);
   l_savepoint := 'P';
   savepoint build_rpa_save_preview;
   hr_utility.set_location('savepoint build_rpa_save_preview    ' || l_proc,5);
 -- The following would be null while creating rpa.

   l_pa_request_rec.additional_info_person_id          :=  NULL;
   l_pa_request_rec.additional_info_tel_number         :=  NULL;
   l_pa_request_rec.Proposed_Effective_Date            :=  NULL;
   l_pa_request_rec.Proposed_Effective_ASAP_flag       :=  'N';
   l_pa_request_rec.requested_by_person_id             :=  NULL;
   l_pa_request_rec.requested_by_title                 :=  NULL;
   l_pa_request_rec.requested_date	               :=  NULL;
   l_pa_request_rec.authorized_by_person_id            :=  NULL;
   l_pa_request_rec.authorized_by_title                :=  NULL;
   l_pa_request_rec.concurrence_Date                   :=  NULL;
--
   l_pa_request_rec.to_step_or_rate                    :=  NULL;
   l_pa_request_rec.to_adj_basic_pay                   :=  NULL;
   l_pa_request_rec.to_basic_pay                       :=  NULL;
   l_pa_request_rec.to_total_salary                    :=  NULL;
   l_pa_request_rec.to_other_pay_amount                :=  NULL;
   l_pa_request_rec.to_au_overtime                     :=  NULL;
   l_pa_request_rec.to_auo_premium_pay_indicator       :=  NULL;
   l_pa_request_rec.to_availability_pay                :=  NULL;
   l_pa_request_rec.to_ap_premium_pay_indicator        :=  NULL;
   l_pa_request_rec.to_retention_allowance             :=  NULL;
   l_pa_request_rec.to_supervisory_differential        :=  NULL;
   l_pa_request_rec.to_staffing_differential           :=  NULL;
   l_pa_request_rec.to_locality_adj                    :=  NULL;
   l_pa_request_rec.to_retention_allow_percentage      :=  NULL;
   l_pa_request_rec.to_supervisory_diff_percentage     :=  NULL;
   l_pa_request_rec.to_staffing_diff_percentage        :=  NULL;


---l_pa_request_rec.to_adj_basic_pay                   :=  0;
---l_pa_request_rec.to_basic_pay                       :=  0;  --APP-37206 CPDF Edit #370.25.2
---l_pa_request_rec.to_total_salary                    :=  0;

   hr_utility.set_location(l_proc,10);
   l_pa_request_rec.mass_action_id                     :=  p_mass_award_id;
   l_pa_request_rec.rpa_type                           :=  p_rpa_type;
   l_pa_request_rec.effective_date                     :=  p_effective_date;
   l_pa_request_rec.person_id                          :=  p_person_id;
   l_pa_request_rec.employee_assignment_id             :=  p_assignment_id;
   l_pa_request_rec.from_position_id                   :=  p_position_id;
   l_pa_request_rec.to_grade_id                        :=  p_grade_id;
   l_pa_request_rec.duty_station_location_id           :=  p_location_id;
   l_pa_request_rec.to_job_id                          :=  p_job_id;

   l_pa_request_rec.first_noa_id                       := get_noa_id(p_mass_award_id);
   l_pa_request_rec.noa_family_code                    :=
          ghr_pa_requests_pkg.get_noa_pm_family
                 (p_nature_of_action_id => l_pa_request_rec.first_noa_id);

   hr_utility.set_location(l_proc,15);
   get_noa_code_desc
      ( p_noa_id              =>  l_pa_request_rec.first_noa_id,
        p_effective_date      =>  p_effective_date,
        p_noa_code            =>  l_pa_request_rec.first_noa_code,
        p_noa_desc            =>  l_pa_request_rec.first_noa_desc );

   hr_utility.set_location(l_proc,20);
   ghr_pa_requests_pkg.get_person_details
      (p_person_id            => p_person_id
       ,p_effective_date      => p_effective_date
       ,p_national_identifier => l_pa_request_rec.employee_national_identifier
       ,p_date_of_birth       => l_pa_request_rec.employee_date_of_birth
       ,p_last_name           => l_pa_request_rec.employee_last_name
       ,p_first_name          => l_pa_request_rec.employee_first_name
       ,p_middle_names        => l_pa_request_rec.employee_middle_names
      );

   hr_utility.set_location(l_proc,25);
   ghr_api.sf52_from_data_elements
        (p_person_id                    => p_person_id
        ,p_assignment_id       	        => l_pa_request_rec.employee_assignment_id
        ,p_effective_date               => p_effective_date
        ,p_altered_pa_request_id        => null
        ,p_noa_id_corrected             => null
        ,p_pa_history_id                => null
        ,p_position_title               => l_pa_request_rec.from_position_title
        ,p_position_number              => l_pa_request_rec.from_position_number
        ,p_position_seq_no              => l_pa_request_rec.from_position_seq_no
        ,p_pay_plan                     => l_pa_request_rec.from_pay_plan
        ,p_job_id                       => l_pa_request_rec.to_job_id
        ,p_occ_code                     => l_pa_request_rec.from_occ_code
        ,p_grade_id                     => l_pa_request_rec.to_grade_id
        ,p_grade_or_level               => l_pa_request_rec.from_grade_or_level
        ,p_step_or_rate                 => l_pa_request_rec.from_step_or_rate
        ,p_total_salary                 => l_pa_request_rec.from_total_salary
        ,p_pay_basis                    => l_pa_request_rec.from_pay_basis
	-- FWFA Changes Bug#4444609
	,p_pay_table_identifier         =>      l_pa_request_rec.from_pay_table_identifier
	-- FWFA Changes
        ,p_basic_pay                    => l_pa_request_rec.from_basic_pay
        ,p_locality_adj                 => l_pa_request_rec.from_locality_adj
        ,p_adj_basic_pay                => l_pa_request_rec.from_adj_basic_pay
        ,p_other_pay                    => l_pa_request_rec.from_other_pay_amount
----Bug 2348413
        ,p_au_overtime                  => l_dummy_number
        ,p_auo_premium_pay_indicator	=> l_dummy
        ,p_availability_pay             => l_dummy_number
        ,p_ap_premium_pay_indicator 	=> l_dummy
        ,p_retention_allowance          => l_dummy_number
        ,p_retention_allow_percentage   => l_dummy_number
        ,p_supervisory_differential 	=> l_dummy_number
        ,p_supervisory_diff_percentage  => l_dummy_number
        ,p_staffing_differential        => l_dummy_number
        ,p_staffing_diff_percentage     => l_dummy_number
----Bug 2348413
        ,p_organization_id          	=> l_pa_request_rec.to_organization_id
        ,p_position_org_line1      	=> l_pa_request_rec.from_position_org_line1
        ,p_position_org_line2       	=> l_pa_request_rec.from_position_org_line2
        ,p_position_org_line3       	=> l_pa_request_rec.from_position_org_line3
        ,p_position_org_line4           => l_pa_request_rec.from_position_org_line4
        ,p_position_org_line5           => l_pa_request_rec.from_position_org_line5
        ,p_position_org_line6       	=> l_pa_request_rec.from_position_org_line6
        ,p_position_id             	=> l_pa_request_rec.from_position_id
        ,p_duty_station_location_id 	=> l_duty_station_location_id
        -- FWFA Changes Bug#4444609
        ,p_pay_rate_determinant    	=> l_dummy
        -- FWFA Changes
        ,p_work_schedule		=> l_pa_request_rec.work_schedule
      );

   hr_utility.set_location(l_proc,30);
	hr_utility.set_location('Bef Get Aw Det'||l_pa_request_rec.award_amount ,31);
----- Get Award details from the template and also extra information
   get_award_details
       ( p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => 'TA',
         p_effective_date            => p_effective_date,
         p_person_id                 => null,
         p_award_amount              => l_t_award_amount,
         p_award_uom                 => l_t_award_uom,
         p_award_percentage          => l_t_award_percentage,
         p_award_agency              => l_dummy,
         p_award_type                => l_dummy,
         p_group_award               => l_dummy,
         p_tangible_benefit_dollars  => l_dummy,
         p_date_award_earned         => l_dummy,
         p_appropriation_code        => l_dummy);

    l_pa_request_rec.award_amount     := l_t_award_amount;
    l_pa_request_rec.award_uom        := l_t_award_uom;
    l_pa_request_rec.award_percentage := l_t_award_percentage;
    l_bt_award_amount                 := l_t_award_amount;
    l_bt_award_percentage             := l_t_award_percentage;
	hr_utility.set_location('Aft Get Aw Det'||l_pa_request_rec.award_amount ,31);
     -- Begin Bug# 4748927
	  /* l_from_basic_pay_pa :=
        ghr_pay_calc.convert_amount(l_pa_request_rec.from_basic_pay
                                   ,l_pa_request_rec.from_pay_basis,'PA');*/
	--End Bug# 4748927
   hr_utility.set_location(l_proc,35);
   l_pa_request_rec.duty_station_location_id := l_duty_station_location_id;

      ghr_pa_requests_pkg.get_SF52_loc_ddf_details
             (p_location_id      => l_duty_station_location_id
             ,p_duty_station_id  => l_pa_request_rec.duty_station_id);

      ghr_pa_requests_pkg.get_duty_station_details
             (p_duty_station_id          => l_pa_request_rec.duty_station_id
             ,p_effective_date           => l_pa_request_rec.effective_date
             ,p_duty_station_code        => l_pa_request_rec.duty_station_code
             ,p_duty_station_desc        => l_pa_request_rec.duty_station_desc);
	-- Begin Bug# 4748927
	if l_pa_request_rec.award_percentage is not null then
		l_pa_request_rec.award_amount :=
		ROUND(l_pa_request_rec.award_salary *
                  NVL(l_pa_request_rec.award_percentage,0) / 100 , 0);

	-- Bug# 4748927 End
	end if;

   l_pa_request_rec.to_position_id        := l_pa_request_rec.from_position_id;
   l_pa_request_rec.to_position_title     := l_pa_request_rec.from_position_title;
   l_pa_request_rec.to_position_number    := l_pa_request_rec.from_position_number;
   l_pa_request_rec.to_position_seq_no    := l_pa_request_rec.from_position_seq_no;
   l_pa_request_rec.to_position_org_line1 := l_pa_request_rec.from_position_org_line1;
   l_pa_request_rec.to_position_org_line2 := l_pa_request_rec.from_position_org_line2;
   l_pa_request_rec.to_position_org_line3 := l_pa_request_rec.from_position_org_line3;
   l_pa_request_rec.to_position_org_line4 := l_pa_request_rec.from_position_org_line4;
   l_pa_request_rec.to_position_org_line5 := l_pa_request_rec.from_position_org_line5;
   l_pa_request_rec.to_position_org_line6 := l_pa_request_rec.from_position_org_line6;

   hr_utility.set_location(l_proc,40);
     ghr_pa_requests_pkg.get_sf52_pos_ddf_details
         (p_position_id               =>  p_position_id
         ,p_date_Effective            =>  l_pa_request_rec.effective_date
         ,p_flsa_category             =>  l_pa_request_rec.flsa_category
         ,p_bargaining_unit_status    =>  l_pa_request_rec.bargaining_unit_status
         ,p_work_schedule             =>  l_dummy
         ,p_functional_class          =>  l_pa_request_rec.functional_class
         ,p_supervisory_status        =>  l_pa_request_rec.supervisory_status
         ,p_position_occupied         =>  l_pa_request_rec.position_occupied
         ,p_appropriation_code1       =>  l_pa_request_rec.appropriation_code1
         ,p_appropriation_code2       =>  l_pa_request_rec.appropriation_code2
         ,p_personnel_office_id       =>  l_pa_request_rec.personnel_office_id
         ,p_office_symbol             =>  l_pa_request_rec.from_office_symbol
         ,p_part_time_hours           =>  l_dummy
         );

  hr_utility.set_location('POI ID ' || l_pa_request_rec.personnel_office_id ,42);
  hr_utility.set_location('From Pos ID ' || to_char(l_pa_request_rec.from_position_id) ,42);
  hr_utility.set_location('To Pos ID ' || to_char(l_pa_request_rec.to_position_id) ,42);
  hr_utility.set_location('Office Symbol  ' || l_pa_request_rec.from_office_symbol ,42);

   hr_utility.set_location(l_proc,45);
   get_business_group
        (p_person_id                 => p_person_id
        ,p_effective_date            => p_effective_date
        ,p_business_group_id         => l_business_group_id
        );

   hr_utility.set_location(l_proc,50);
   l_pa_request_rec.agency_code      :=   ghr_api.get_position_agency_code_pos
                                         (p_position_id       => p_position_id
                                         ,p_business_group_id => l_business_group_id
                                         ,p_effective_date    => p_effective_date
);
  hr_utility.set_location('Agency Code ' || l_pa_request_rec.agency_code ,52);

  l_pa_request_rec.employee_dept_or_agency := ghr_pa_requests_pkg.get_lookup_meaning
												 (800
												 ,'GHR_US_AGENCY_CODE'
												 ,l_pa_request_rec.agency_code
												 );

  hr_utility.set_location('employee_dept_or_agency ' || l_pa_request_rec.employee_dept_or_agency ,52);
  hr_utility.set_location('Noa_family_code  value ' || l_pa_request_rec.noa_family_code,52);
  hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,52);
  hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),52);
  hr_utility.set_location('l_pa_request_rec.award_amount '||l_pa_request_rec.award_amount ,52);

	-- Bug 5041967 Sundar
ghr_history_fetch.fetch_asgei(
							p_assignment_id    => l_pa_request_rec.employee_assignment_id,
							p_information_type => 'GHR_US_ASG_SF52',
							p_date_effective   => p_effective_date,
							p_asg_ei_data      => l_asg_ei_data);
	ghr_pay_calc.award_amount_calc (
						 p_position_id		=> l_pa_request_rec.to_position_id
						,p_pay_plan			=> l_pa_request_rec.from_pay_plan
						,p_award_percentage => l_pa_request_rec.award_percentage
						,p_user_table_id	=> l_pa_request_rec.from_pay_table_identifier
						,p_grade_or_level	=> l_pa_request_rec.from_grade_or_level
						,p_effective_date	=> l_pa_request_rec.effective_date
						,p_basic_pay		=> l_pa_request_rec.from_basic_pay
						,p_adj_basic_pay	=> l_pa_request_rec.from_adj_basic_pay
						,p_duty_station_id	=> l_pa_request_rec.duty_station_id
						,p_prd				=> l_asg_ei_data.aei_information6
						,p_pay_basis		=> l_pa_request_rec.from_pay_basis
						,p_person_id		=> l_pa_request_rec.person_id
--						,p_award_amount		=> l_pa_request_rec.award_amount Bug 5041967
						,p_award_amount		=> l_dummy
						,p_award_salary		=> l_pa_request_rec.award_salary
						);
-- End Bug 5041967 Sundar

  -----------Created marpa_process procedure Call
  begin
  	 	hr_utility.set_location('Bef MAR PA '||l_pa_request_rec.award_amount ,32);
   marpa_process
    (
     p_mass_award_id     => p_mass_award_id
    ,p_action_type       => p_action_type
    ,p_rpa_type          => p_rpa_type
    ,p_effective_date    => p_effective_date
    ,p_person_id         => p_person_id
    ,p_pa_request_rec    => l_pa_request_rec
    ,p_log_text          => l_log_text
	  ,p_maxcheck         => p_maxcheck
    );

	hr_utility.set_location('After MAR PA '||l_pa_request_rec.award_amount ,33);
   commit;
   hr_utility.set_location('commit to have eligibility build_rpa_save_preview    ' ,162);
   l_savepoint := 'P';
   savepoint build_rpa_save_preview;
   hr_utility.set_location('savepoint build_rpa_save_preview - After Preview   ' ,162);
  exception when ma_rpaerror then raise;
            when others then raise ma_rpaerror;
  end;

-------commit;
---------------------Starting Final
---Recent Modification - Group box id must be commited in order to get call work flow

   hr_utility.set_location(l_proc,163);
   -- Employee Data

     get_pa_request_id_ovn
      ( p_mass_award_id         => p_mass_award_id,
        p_effective_date        => p_effective_date,
        p_person_id             => p_person_id,
        p_pa_request_id         => l_pa_request_id,
        p_pa_notification_id    => l_pa_notification_id,
        p_rpa_type              => l_rpa_type,
        p_mass_action_sel_flag  => l_mass_action_select_flag,
	--Bug#3804067 Added mass action comments
	p_mass_action_comments  => l_mass_action_comments,
        p_object_version_number => l_object_version_number);

------ Modified in 115.9
     l_pa_request_rec.mass_action_comments  := l_mass_action_comments;
     l_pa_request_rec.object_version_number := l_object_version_number;
     l_pa_request_rec.pa_request_id         := l_pa_request_id;
  hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,165);
  hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),165);

-------
     if l_rpa_type is null then l_rpa_type := 'A'; end if;

IF p_action_type = 'FINAL' then
   IF l_pa_notification_id is null and l_rpa_type = 'A' and l_mass_action_select_flag <> 'N' THEN

      if l_1_pa_routing_history_id is null then
         l_1_pa_routing_history_id := l_i_pa_routing_history_id;
      end if;
      if l_1_prh_object_version_number is null then
         l_1_prh_object_version_number := l_i_prh_object_version_number;
      end if;

      begin
       hr_utility.set_location('Getting Group Box ' || l_proc,170);

       ghr_mass_actions_pkg.get_personnel_off_groupbox
          (p_position_id          => p_position_id
          ,p_effective_date       => p_effective_date
          ,p_groupbox_id          => l_groupbox_id
          ,p_routing_group_id     => l_routing_group_id );
       hr_utility.set_location('Getting Group Box Success ' || l_proc,170);
       hr_utility.set_location('Routing Group Id  ' || to_char(l_routing_group_id),170);
       hr_utility.set_location('Group Box Id' || to_char(l_groupbox_id),170);

      exception
          WHEN OTHERS THEN
       hr_utility.set_location('Getting Group Box Failure ' || l_proc,170);
               l_log_text := 'Error in POI groupbox ' ||' Sql error : '||sqlerrm(sqlcode);

        -- Call ghr_par_upd.upd here

       raise groupboxerr;
      end;

        -- Call ghr_prh_upd.upd here
    for routing_history_id in c_routing_history loop
      l_pa_routing_history_id      :=   routing_history_id.pa_routing_history_id;
      l_prh_object_version_number  :=   routing_history_id.object_version_number;
      exit;
    end loop;

   hr_utility.set_location('Updating prh  ' || l_proc,175);
  hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,175);
  hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),175);
  hr_utility.set_location('RHVN ' || to_char(l_prh_object_version_number),176);
  hr_utility.set_location('RHID ' || to_char(l_pa_routing_history_id),177);

       ghr_prh_upd.upd(
                p_pa_routing_history_id   => l_pa_routing_history_id,
                p_groupbox_id             => l_groupbox_id,
                p_object_version_number   => l_prh_object_version_number);

    hr_utility.set_location('Updating par  ' || l_proc,180);

	-- Call ghr_par_upd.upd here
       ghr_par_upd.upd(
	   p_pa_request_id   		=> l_pa_request_rec.pa_request_id,
           p_routing_group_id 		=> l_routing_group_id,
	   p_object_version_number      => l_pa_request_rec.object_version_number);

-- Bug 3376761
-- check to see if the award amount is within 25% of basic pay
-- other wise raise award percentage exception.

     l_from_basic_pay_pa :=
        ghr_pay_calc.convert_amount(l_pa_request_rec.from_basic_pay
                                   ,l_pa_request_rec.from_pay_basis,'PA');


     commit;
     hr_utility.set_location('commit(GB) build_rpa_save_preview    ' || l_proc,52);
  hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,52);
  hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),52);

---- Recent Modification End;

     l_savepoint := 'F';
     savepoint build_rpa_save_final;
     hr_utility.set_location('savepoint build_rpa_save_final    ' || l_proc,52);
     hr_utility.set_location(l_proc,52);
	 	hr_utility.set_location('Bef Check Award Amt'||l_pa_request_rec.award_amount ,34);
/*
   IF l_pa_request_rec.award_amount >  ROUND(l_from_basic_pay_pa * 0.25 , 0) THEN
      RAISE ma_awdpererr;
   END IF ;
*/
	--Pradeep Commented the above and added the below for bug 3934195
	get_award_details
       ( p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => l_rpa_type,
         p_effective_date            => p_effective_date,
         p_person_id                 => null,
         p_award_amount              => l_d_award_amount,
         p_award_uom                 => l_d_award_uom,
         p_award_percentage          => l_d_award_percentage,
         p_award_agency              => l_dummy,
         p_award_type                => l_dummy,
         p_group_award               => l_dummy,
         p_tangible_benefit_dollars  => l_dummy,
         p_date_award_earned         => l_dummy,
         p_appropriation_code        => l_dummy);

	l_error_flag := FALSE;
	check_award_amount (p_noa_code  => l_pa_request_rec.first_noa_code,
					p_effective_date => l_pa_request_rec.effective_date,
			      p_award_amount => l_d_award_amount,
			      p_from_pay_plan => l_pa_request_rec.from_pay_plan,
			      p_from_basic_pay_pa => l_from_basic_pay_pa,
					p_to_position_id => l_pa_request_rec.to_position_id,
			      p_comments => l_comments,
					p_error_flg => l_error_flag
					);
	IF l_error_flag  THEN
		p_maxcheck := 1;
	END IF;

	IF ( l_error_flag
		AND NVL(l_mass_action_select_flag,'Y') <> 'N' ) THEN
	   l_mass_action_select_flag := 'N';
		RAISE ma_awdpererr;
   END IF ;

-- End of Bug 3376761

     get_award_lac
        (p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => 'TA',
         p_effective_date            => p_effective_date,
         p_first_lac1_record         => l_lac1,
         p_first_lac2_record         => l_lac2
        );
     l_pa_request_rec.first_action_la_code1   := l_lac1.first_action_la_code1;
     l_pa_request_rec.first_action_la_desc1   := l_lac1.first_action_la_desc1;
     l_pa_request_rec.first_lac1_information1 := l_lac1.first_lac1_information1;
     l_pa_request_rec.first_lac1_information2 := l_lac1.first_lac1_information2;
     l_pa_request_rec.first_lac1_information3 := l_lac1.first_lac1_information3;
     l_pa_request_rec.first_lac1_information4 := l_lac1.first_lac1_information4;
     l_pa_request_rec.first_lac1_information5 := l_lac1.first_lac1_information5;

     l_pa_request_rec.first_action_la_code2   := l_lac2.first_action_la_code2;
     l_pa_request_rec.first_action_la_desc2   := l_lac2.first_action_la_desc2;
     l_pa_request_rec.first_lac2_information1 := l_lac2.first_lac2_information1;
     l_pa_request_rec.first_lac2_information2 := l_lac2.first_lac2_information2;
     l_pa_request_rec.first_lac2_information3 := l_lac2.first_lac2_information3;
     l_pa_request_rec.first_lac2_information4 := l_lac2.first_lac2_information4;
     l_pa_request_rec.first_lac2_information5 := l_lac2.first_lac2_information5;

-- First NOA Code has insertion values. (For only 879 and 885 NOAC's)

          ghr_mass_actions_pkg.replace_insertion_values
            (p_desc                => l_pa_request_rec.first_noa_desc,
             p_information1        => l_pa_request_rec.first_noa_information1,
	     -- Bug#3648118 Passed the local variable as OUT parameter
	     -- because passing l_pa_request_rec.first_noa_desc as OUT parameter
	     -- is making the variable as NULL.
             p_desc_out            => l_first_noa_desc
  	    );

	    l_pa_request_rec.first_noa_desc := l_first_noa_desc;
	    -- Bug#3648118 Changes completed.
     hr_utility.set_location(l_proc,55);
     ghr_pa_requests_pkg.get_SF52_person_ddf_details
        (p_person_id   		        => l_pa_request_rec.person_id,
         p_date_effective             	=> l_pa_request_rec.effective_date,
         p_citizenship  		=> l_pa_request_rec.citizenship,
         p_veterans_preference 	   	=> l_pa_request_rec.veterans_preference,
         p_veterans_pref_for_rif      	=> l_pa_request_rec.veterans_pref_for_rif,
         p_veterans_status 	       	=> l_pa_request_rec.veterans_status,
         p_scd_leave               	=> l_scd_leave
        );

     -- populate service comp date
     hr_utility.set_location(l_proc,60);
     l_pa_request_rec.service_comp_date  := fnd_date.canonical_to_date(l_scd_leave);

   -- get education details
     hr_utility.set_location(l_proc,70);
     ghr_api.return_education_Details
       (p_person_id             => l_pa_request_rec.person_id,
        p_effective_date        => l_pa_request_rec.effective_date,
        p_education_level       => l_pa_request_rec.education_level,
        p_academic_discipline   => l_pa_request_rec.academic_discipline,
        p_year_degree_attained  => l_pa_request_rec.year_degree_attained
        );

     hr_utility.set_location(l_proc,80);
     ghr_pa_requests_pkg.get_SF52_asg_ddf_details
       (p_assignment_id         => l_pa_request_rec.employee_assignment_id
       ,p_date_effective        => l_pa_request_rec.effective_date
       ,p_tenure                => l_pa_request_rec.tenure
       ,p_annuitant_indicator   => l_pa_request_rec.annuitant_indicator
       ,p_pay_rate_determinant  => l_dummy
       ,p_work_schedule         => l_pa_request_rec.work_schedule
       ,p_part_time_hours       => l_pa_request_rec.part_time_hours
       );

  -- Annuitant_indicator
    l_pa_request_rec.annuitant_indicator_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_ANNUITANT_INDICATOR'
                 ,l_pa_request_rec.annuitant_indicator
                 );

  --WORK_SCHEDULE
    l_pa_request_rec.work_schedule_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_WORK_SCHEDULE'
                 ,l_pa_request_rec.work_schedule
                 );

-- get fegli,retirement_plan

     hr_utility.set_location(l_proc,90);
       ghr_api.retrieve_element_entry_value
          (p_element_name        => 'FEGLI'
          ,p_input_value_name    => 'FEGLI'
          ,p_assignment_id       => l_pa_request_rec.employee_assignment_id
          ,p_effective_date      => l_pa_request_rec.effective_date
          ,p_value               => l_pa_request_rec.fegli
          ,p_multiple_error_flag => l_multiple_error_flag
          );

       l_pa_request_rec.fegli_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_FEGLI'
                 ,l_pa_request_rec.fegli
                 );


   --retirement_plan
     hr_utility.set_location(l_proc,100);
       ghr_api.retrieve_element_entry_value
            (p_element_name        => 'Retirement Plan'
            ,p_input_value_name    => 'Plan'
            ,p_assignment_id       => l_pa_request_rec.employee_assignment_id
            ,p_effective_date      => l_pa_request_rec.effective_date
            ,p_value               => l_pa_request_rec.retirement_plan
            ,p_multiple_error_flag => l_multiple_error_flag
            );

       l_pa_request_rec.retirement_plan_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_RETIREMENT_PLAN'
                 ,l_pa_request_rec.retirement_plan
                 );

   -- Descriptions for the codes passed in
      hr_utility.set_location(l_proc,110);
      ghr_mass_actions_pkg.get_personnel_officer_name
              (p_personnel_office_id      => l_pa_request_rec.personnel_office_id,
               p_person_full_name         => l_personnel_officer_name,
               p_approving_off_work_title => l_approving_off_work_title);

      l_pa_request_rec.approving_official_full_name  := l_personnel_officer_name;
      l_pa_request_rec.approving_official_work_title := l_approving_off_work_title;

      l_approval_date                    := sysdate;
      l_1_approval_status                := 'APPROVE';
      l_pa_request_rec.request_number    := l_pa_request_num_prefix ||
                                            to_char(l_pa_request_rec.pa_request_id);


  hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,110);
  hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),110);
-----------Created marpa_process procedure Call
---- To print NPA correctly ..bug..2356373.

     l_pa_request_rec.sf50_approving_ofcl_full_name  := l_personnel_officer_name;
     l_pa_request_rec.sf50_approval_date             := sysdate;
     l_pa_request_rec.sf50_approving_ofcl_work_title := l_approving_off_work_title;

  begin
   marpa_process
    (
     p_mass_award_id     => p_mass_award_id
    ,p_action_type       => p_action_type
    ,p_rpa_type          => p_rpa_type
    ,p_effective_date    => p_effective_date
    ,p_person_id         => p_person_id
    ,p_pa_request_rec    => l_pa_request_rec
    ,p_log_text          => l_log_text
    ,p_maxcheck         =>  p_maxcheck
    );

  exception when ma_rpaerror then raise;
            when others then raise ma_rpaerror;
  end;

  hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,165);
  hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),165);

   hr_utility.set_location('Creating Remarks ' || l_proc,165);
     create_remarks
      (p_mass_award_id     => p_mass_award_id
	  ,p_rpa_type          => 'TA'
      ,p_effective_date    => p_effective_date
      ,p_pa_request_id     => l_pa_request_rec.pa_request_id
      );
   hr_utility.set_location('Creating Remarks Over ' || l_proc,165);


      if p_effective_date > sysdate then
         l_rpa_action := 'FUTURE_ACTION';
      else
         l_rpa_action := 'UPDATE_HR';
      end if;

    hr_utility.set_location('Action before last  ghr_par_upd.upd ' || l_rpa_action || '  ' || l_proc,175);

---Bug  2356373
    ghr_par_upd.upd
    (p_pa_request_id             => l_pa_request_rec.pa_request_id,
     p_object_version_number     => l_pa_request_rec.object_version_number,
     p_personnel_office_id       =>  l_pa_request_rec.personnel_office_id,
     p_employee_dept_or_agency   =>  l_pa_request_rec.employee_dept_or_agency,
     p_to_office_symbol          =>  l_pa_request_rec.to_office_symbol,
     p_sf50_approving_ofcl_full_nam        => l_personnel_officer_name,
     p_sf50_approval_date                  => sysdate ,
     p_sf50_approving_ofcl_work_tit       => l_approving_off_work_title
    );
---Bug  2356373 End

    hr_utility.set_location('Action after last  ghr_par_upd.upd ' || l_rpa_action || '  ' || l_proc,175);

    hr_utility.set_location('Action before ' || l_rpa_action || '  ' || l_proc,185);
    hr_utility.set_location('PA REQ ID ' || to_char(l_pa_request_rec.pa_request_id) ,185);
    hr_utility.set_location('PA OVN    ' || to_char(l_pa_request_rec.object_version_number),185);

  hr_utility.set_location('employee_dept_or_agency ' || l_pa_request_rec.employee_dept_or_agency ,185);
  hr_utility.set_location('POI ID ' || l_pa_request_rec.personnel_office_id ,185);
------

----Update Sf52 for Personnel Action
    begin
      ghr_sf52_api.update_sf52
    (
     p_pa_request_id                => l_pa_request_rec.pa_request_id,
     p_par_object_version_number    => l_pa_request_rec.object_version_number,
----Bug 2348413
     p_effective_date               => l_pa_request_rec.effective_date,
     p_employee_assignment_id       => l_pa_request_rec.employee_assignment_id,
     p_noa_family_code              => l_pa_request_rec.noa_family_code,
----Bug 2348413
     p_routing_group_id             => l_routing_group_id,
     p_u_action_taken               => l_rpa_action,
     p_u_prh_object_version_number  => l_u_prh_object_version_number ,
	 p_first_noa_id					=> l_pa_request_rec.first_noa_id, -- Bug#2740882
     p_i_pa_routing_history_id      => l_i_pa_routing_history_id,
     p_i_prh_object_version_number  => l_i_prh_object_version_number);
    exception
     WHEN OTHERS THEN
      hr_utility.set_location(sqlerrm(sqlcode),1);
      hr_utility.set_location('Update sf52 final Failure ' || l_proc,190);
      l_log_text := 'Error in Update sf52 final ' ||' Sql error : '||sqlerrm(sqlcode);
      raise rpaerror;
    end;

    hr_utility.set_location('Action after ' || l_rpa_action || '  ' || l_proc,200);
 p_status          := 'SUCCESS';
 p_retcode         := 0;
 l_log_text        := 'Last Name: '|| l_pa_request_rec.employee_last_name ||
                      'SSN: '      || l_pa_request_rec.employee_national_identifier ||
                      'Mass Award:'|| to_char(p_mass_award_id)||
                      'SF52 Successfully completed';
 p_errbuf          := l_log_text;

  ghr_wgi_pkg.create_ghr_errorlog(
    p_program_name => g_log_name,
    p_message_name => substr(l_maw_name || '-' || 'Success',1,30),
    p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' || l_log_text,1,2000),
    p_log_date     => sysdate);



 ELSE
  IF l_rpa_type = 'M'  then
     p_status    := 'MANUAL';
     p_retcode   := 0;
     hr_utility.set_location('Manual rpa_type        '  || l_proc,200);
  ELSIF l_mass_action_select_flag = 'N'
			and l_status = 'DESELECTED PRG:' THEN
	  hr_utility.set_location('Deselected by programatically'  || l_proc,200);
     p_errbuf    := 'DESELECTED PRG:';
     p_retcode   := 0;
  ELSIF l_mass_action_select_flag = 'N' then
     hr_utility.set_location('Deselected by user     '  || l_proc,200);
     p_status    := 'DESELECTED';
     p_retcode   := 0;
  ELSE
     hr_utility.set_location('Already Processed      '  || l_proc,200);
     p_status := 'PROCESSED';
     p_retcode   := 0;
  END IF;
 END IF;    ----- For l_pa_notification_id is null and rpa_type = 'A'
END IF;   ----  For p_action = 'FINAL'

Exception
  When groupboxerr then
       rollback to build_rpa_save_preview;
       hr_utility.set_location('rollback grp build_rpa_save_preview    ' || l_proc,1);

  -- Call ghr_par_upd.upd here
  begin

     get_pa_request_id_ovn
      ( p_mass_award_id         => p_mass_award_id,
        p_effective_date        => p_effective_date,
        p_person_id             => p_person_id,
        p_pa_request_id         => l_pa_request_id,
        p_pa_notification_id    => l_pa_notification_id,
        p_rpa_type              => l_rpa_type,
        p_mass_action_sel_flag  => l_mass_action_select_flag,
	--Bug#3804067 Added mass action comments
	p_mass_action_comments  => l_mass_action_comments,
        p_object_version_number => l_object_version_number);

   ghr_par_upd.upd(
	   p_pa_request_id   		=> l_pa_request_id,
           p_mass_action_eligible_flag  => 'Y',
           p_mass_action_select_flag 	=> 'N',
           p_mass_action_comments       => 'PRG: Programatically Deselected',
	   p_object_version_number      => l_object_version_number);
  exception when others then
        l_log_text := substr(l_log_text || ' , Failed in Deselecting, ' ||' Sql error : '||sqlerrm(sqlcode),1,2000);
  end;

    hr_utility.set_location('Error occured  in  group box ' || l_proc , 1);
    IF l_log_text is NULL THEN
      l_log_text   := 'Error while creating / Updating the PA Request Rec.';
    END IF;

    p_retcode := 1;
    p_status   := 'GROUPBOX';
    p_errbuf   := substr(l_log_text || 'Details in GHR_PROCESS_LOG',1,2000);

    hr_utility.set_location('before creating entry in log file',2);
    -- Bug#3718167 Added SSN in the log text below
    l_log_text   :=  substr(',( ' || l_pa_request_rec.employee_last_name || ', '  ||
                             l_pa_request_rec.employee_first_name ||' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			     ') ' || l_log_text,1,2000);

    ghr_wgi_pkg.create_ghr_errorlog(
      p_program_name => g_log_name,
      p_message_name => substr(l_maw_name || '-' || 'GB Err',1,30),
      p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' ||l_log_text,1,2000),
      p_log_date     => sysdate);

    hr_utility.set_location('Groupbox Error ',2);
    hr_utility.set_location('created entry in log file',2);
    commit;

  When rpaerror then

    if l_savepoint = 'F' THEN
       rollback to build_rpa_save_final;
       hr_utility.set_location('rollback rpa build_rpa_save_final    ' || l_proc,1);
    else
       rollback to build_rpa_save_preview;
       hr_utility.set_location('rollback rpa build_rpa_save_preview    ' || l_proc,1);
    end if;

    hr_utility.set_location('Error occured Final Sf52 ' || l_proc , 1);
    IF l_log_text is NULL THEN
      l_log_text   := 'Error while creating / Updating the PA Request Rec.';
    END IF;

    p_retcode := 1;
    p_status   := 'FAILURE';
    p_errbuf   := substr(l_log_text || 'Details in GHR_PROCESS_LOG',1,2000);

    hr_utility.set_location('before creating entry in log file',2);
    -- Bug#3718167 Added SSN in the following log text
    l_log_text   :=  substr(',( ' || l_pa_request_rec.employee_last_name || ', ' ||
                              l_pa_request_rec.employee_first_name ||' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			      ') ' || l_log_text ,1,2000);
    ghr_wgi_pkg.create_ghr_errorlog(
      p_program_name => g_log_name,
      p_message_name => substr(l_maw_name || '-' || 'RPA Err',1,30),
      p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' ||l_log_text,1,2000),
      p_log_date     => sysdate);

    hr_utility.set_location('FINAL SF52 Error ',2);
    hr_utility.set_location('created entry in log file',2);

    hr_utility.set_location('Calling workflow begin entry ',3);
    mass_awards_error_handling
         ( p_pa_request_id         => l_pa_request_rec.pa_request_id,
           p_object_version_number => l_pa_request_rec.object_version_number,
           p_error                 => l_log_text,
           p_result                => l_result);
    if l_result then
         l_log_text := 'Error while routing to group box in call workflow ';
         p_status   := 'OTHER';
         p_retcode  := 1;
         hr_utility.set_location('before creating entry in log file',4);
	 -- Bug#3718167 Added SSN in the following log text
         l_log_text   :=  substr( ',( ' || l_pa_request_rec.employee_last_name || ', '  ||
                             l_pa_request_rec.employee_first_name ||' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			     ') ' || l_log_text,1,2000);
         ghr_wgi_pkg.create_ghr_errorlog(
             p_program_name => g_log_name,
             p_message_name => substr(l_maw_name || '-' || 'RPA WF',1,30),
             p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' || l_log_text,1,2000),
             p_log_date     => sysdate);

              hr_utility.set_location('FINAL SF52 Error - Call Work flow ',4);
              hr_utility.set_location('created entry in log file',4);
    end if;
    hr_utility.set_location('Calling workflow end entry ',3);

    commit;

  When ma_rpaerror then

    if l_savepoint = 'F' THEN
       rollback to build_rpa_save_final;
       hr_utility.set_location('rollback marpa build_rpa_save_final    ' || l_proc,1);
    else
       rollback to build_rpa_save_preview;
       hr_utility.set_location('rollback marpa build_rpa_save_preview    ' || l_proc,1);
    end if;

    hr_utility.set_location('Error occured  in   ' || l_proc , 1);
    IF g_log_text is NOT NULL then
       l_log_text  := g_log_text;
    END IF;
    IF l_log_text is NULL THEN
      l_log_text   := 'Error while creating / Updating the PA Request Rec.';
    END IF;

    p_retcode := 1;
    p_status   := 'FAILURE';
    p_errbuf   := substr(l_log_text || 'Details in GHR_PROCESS_LOG',1,2000);

    hr_utility.set_location('before creating entry in log file',2);
    -- Bug#3718167 Added SSN in the following log text
    l_log_text   :=  substr( ',( ' || l_pa_request_rec.employee_last_name || ', '  ||
                             l_pa_request_rec.employee_first_name ||' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			     ') ' || l_log_text,1,2000);
    ghr_wgi_pkg.create_ghr_errorlog(
      p_program_name => g_log_name,
      p_message_name => substr(l_maw_name || '-' || 'RPA MA',1,30) ,
      p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' || l_log_text,1,2000),
      p_log_date     => sysdate);


    hr_utility.set_location('Error Others  ',2);
    hr_utility.set_location('created entry in log file',2);

    commit;

-- Bug 3376761
-- If Award amount exceeds 25% of annual basic pay

    When ma_awdpererr then


    rollback to build_rpa_save_final;

	 hr_utility.set_location('rollback marpa build_rpa_save_final    ' || l_proc,1);

    hr_utility.set_location('Error occured  in   ' || l_proc , 1);

    --l_log_text   := 'APP-GHR-38611 - Award Percentage cannot be greater than 25% of total annual basic pay.';
    l_log_text   := l_comments;

    p_retcode := 1;
    p_status   := 'FAILURE';
    p_errbuf   := substr(l_log_text || 'Details in GHR_PROCESS_LOG',1,2000);

    hr_utility.set_location('before creating entry in log file',2);
    -- Bug#3718167 Added SSN in the following log text
    l_log_text   :=  substr(',( ' || l_pa_request_rec.employee_last_name || ', ' ||
                              l_pa_request_rec.employee_first_name ||' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			      ') ' || l_log_text ,1,2000);

    ghr_wgi_pkg.create_ghr_errorlog(
      p_program_name => g_log_name,
      p_message_name => substr(l_maw_name || '-' || 'RPA MA',1,60),
      p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' ||l_log_text,1,2000),
      p_log_date     => sysdate);

    hr_utility.set_location('Award percentage Error ',2);
    hr_utility.set_location('created entry in log file',2);

    hr_utility.set_location('Calling workflow begin entry ',3);
    mass_awards_error_handling
         ( p_pa_request_id         => l_pa_request_rec.pa_request_id,
           p_object_version_number => l_pa_request_rec.object_version_number,
           p_error                 => l_log_text,
           p_result                => l_result);
    if l_result then
         l_log_text := 'Error while routing to group box in call workflow ';
         p_status   := 'OTHER';
         p_retcode  := 1;
         hr_utility.set_location('before creating entry in log file',4);
	 -- Bug#3718167 Added SSN in the following log text
         l_log_text   :=  substr( ',( ' || l_pa_request_rec.employee_last_name || ', '  ||
                             l_pa_request_rec.employee_first_name || ' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			     ') ' || l_log_text,1,2000);
         ghr_wgi_pkg.create_ghr_errorlog(
             p_program_name => g_log_name,
             p_message_name => substr(l_maw_name || '-' || 'RPA WF',1,30),
             p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' || l_log_text,1,2000),
             p_log_date     => sysdate);

              hr_utility.set_location('Award percentage Error - Call Work flow ',4);
              hr_utility.set_location('created entry in log file',4);
    end if;
    hr_utility.set_location('Calling workflow end entry ',3);

    commit;

-- End of Bug 3376761

  When others then

    if l_savepoint = 'F' THEN
       rollback to build_rpa_save_final;
       hr_utility.set_location('rollback others build_rpa_save_final    ' || l_proc,1);
    else
       rollback to build_rpa_save_preview;
       hr_utility.set_location('rollback others build_rpa_save_preview    ' || l_proc,1);
    end if;

    hr_utility.set_location('Error occured  in   ' || l_proc , 1);
    IF l_log_text is NULL THEN
      l_log_text   := 'Error while creating / Updating the PA Request Rec.';
    END IF;

    p_retcode := 1;
    p_status   := 'FAILURE';
    p_errbuf   := substr(l_log_text || 'Details in GHR_PROCESS_LOG',1,2000);

    hr_utility.set_location('before creating entry in log file',2);
    -- Bug#3718167 Added SSN to the following log text
    l_log_text   :=  substr( ',( ' || l_pa_request_rec.employee_last_name || ', '  ||
                             l_pa_request_rec.employee_first_name ||' '||l_pa_request_rec.employee_middle_names||
			     '; SSN: '||l_pa_request_rec.employee_national_identifier||
			     ') ' || l_log_text,1,2000);
    ghr_wgi_pkg.create_ghr_errorlog(
      p_program_name => g_log_name,
      p_message_name => substr(l_maw_name || '-' || 'RPA Oth',1,30) ,
      p_log_text     => substr('Person id : ' || to_char(p_person_id) || ' ' || l_log_text,1,2000),
      p_log_date     => sysdate);


    hr_utility.set_location('Error Others  ',2);
    hr_utility.set_location('created entry in log file',2);

    commit;

end build_rpa_for_mass_awards;


PROCEDURE refresh_award_details
(
 p_mass_award_id     in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type          in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date    in      date,
 p_person_id         in      per_people_f.person_id%TYPE,
 p_pa_request_id     in      ghr_pa_requests.pa_request_id%type
)

IS

l_proc   varchar2(72) :=   g_package || 'refresh_award_details';

l_pa_request_extra_info_id    number;
l_pa_request_extra_info_sh_id number;
l_pa_object_version_number    number;
l_dummy                       varchar2(30);
--l_information_type            varchar2(40) :=  'GHR_US_PAR_AWARDS_BONUS';


l_t_award_amount              ghr_pa_requests.award_amount%type;
l_t_award_uom                 ghr_pa_requests.award_uom%type;
l_t_award_percentage          ghr_pa_requests.award_percentage%type;
l_t_award_agency              varchar2(150);
l_t_award_type                varchar2(150);
l_t_group_award               varchar2(150);
l_t_tbd                       varchar2(150);
l_t_date_award_earn           varchar2(150);
l_t_appropriation_code        varchar2(150);

l_d_award_amount              ghr_pa_requests.award_amount%type;
l_d_award_uom                 ghr_pa_requests.award_uom%type;
l_d_award_percentage          ghr_pa_requests.award_percentage%type;
l_d_award_agency              varchar2(150);
l_d_award_type                varchar2(150);
l_d_group_award               varchar2(150);
l_d_tbd                       varchar2(150);
l_d_date_award_earn           varchar2(150);
l_d_appropriation_code        varchar2(150);

l_s_award_amount              ghr_pa_requests.award_amount%type;
l_s_award_uom                 ghr_pa_requests.award_uom%type;
l_s_award_percentage          ghr_pa_requests.award_percentage%type;
l_s_award_agency              varchar2(150);
l_s_award_type                varchar2(150);
l_s_group_award               varchar2(150);
l_s_tbd                       varchar2(150);
l_s_date_award_earn           varchar2(150);
l_s_appropriation_code        varchar2(150);

   CURSOR cur_rpa_ei  (p_pa_request_id number) is
   SELECT pa_request_extra_info_id,
          object_version_number
     FROM ghr_pa_request_extra_info
    WHERE information_type  = l_information_type
      AND pa_request_id     = p_pa_request_id;

   CURSOR cur_rpa_ei_shadow  (p_pa_request_id number) is
   SELECT pa_request_extra_info_id
     FROM ghr_pa_request_ei_shadow
    WHERE information_type  = l_information_type
      AND pa_request_id     = p_pa_request_id;

BEGIN

   hr_utility.set_location('Entering ' || l_proc,5);
   FOR cur_rpa_ei_rec in cur_rpa_ei(p_pa_request_id)
   LOOP
   hr_utility.set_location( l_proc,10);
       l_pa_request_extra_info_id := cur_rpa_ei_rec.pa_request_extra_info_id;
       l_pa_object_version_number := cur_rpa_ei_rec.object_version_number;
       exit;
   END LOOP;

   FOR cur_rpa_ei_shadow_rec in cur_rpa_ei_shadow(p_pa_request_id)
   LOOP
   hr_utility.set_location( l_proc,10);
       l_pa_request_extra_info_sh_id := cur_rpa_ei_shadow_rec.pa_request_extra_info_id;
       exit;
   END LOOP;

   hr_utility.set_location(l_proc,15);
----- Get Award details from the template and also extra information
   get_award_details
       ( p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => 'TA',
         p_effective_date            => p_effective_date,
         p_person_id                 => null,
         p_award_amount              => l_dummy,
         p_award_uom                 => l_dummy,
         p_award_percentage          => l_dummy,
         p_award_agency              => l_t_award_agency,
         p_award_type                => l_t_award_type,
         p_group_award               => l_t_group_award,
         p_tangible_benefit_dollars  => l_t_tbd,
         p_date_award_earned         => l_t_date_award_earn,
         p_appropriation_code        => l_t_appropriation_code);

	      hr_utility.set_location('p_award_amount - l_dummy' || l_dummy,20);
		  hr_utility.set_location(l_proc,20);
----- Get Award details for the employee existing in the database
   get_award_details
       ( p_mass_award_id             => p_mass_award_id,
         p_rpa_type                  => p_rpa_type,
         p_effective_date            => p_effective_date,
         p_person_id                 => p_person_id,
         p_award_amount              => l_dummy,
         p_award_uom                 => l_dummy,
         p_award_percentage          => l_dummy,
         p_award_agency              => l_d_award_agency,
         p_award_type                => l_d_award_type,
         p_group_award               => l_d_group_award,
         p_tangible_benefit_dollars  => l_d_tbd,
         p_date_award_earned         => l_d_date_award_earn,
         p_appropriation_code        => l_d_appropriation_code);

		hr_utility.set_location('p_award_amountD - l_dummy' || l_dummy,20);

      hr_utility.set_location(l_proc,25);
----- Get Award details from the shadow
      get_award_details_shadow
          ( p_pa_request_id            => p_pa_request_id,
            p_award_amount             => l_dummy,
            p_award_uom                => l_dummy,
            p_award_percentage         => l_dummy,
            p_award_agency             => l_s_award_agency,
            p_award_type               => l_s_award_type,
            p_group_award              => l_s_group_award,
            p_tangible_benefit_dollars => l_s_tbd,
            p_date_award_earned        => l_s_date_award_earn,
            p_appropriation_code       => l_s_appropriation_code);
		hr_utility.set_location('p_award_amountS - l_dummy' || l_dummy,20);
    ------------
      hr_utility.set_location(l_proc,30);
      set_ei
      (p_shadow       => l_s_award_agency,
       p_template     => l_t_award_agency,
       p_person       => l_d_award_agency);

      set_ei
      (p_shadow       => l_s_award_type,
       p_template     => l_t_award_type,
       p_person       => l_d_award_type);

      set_ei
      (p_shadow       => l_s_group_award,
       p_template     => l_t_group_award,
       p_person       => l_d_group_award);

      set_ei
      (p_shadow       => l_s_tbd,
       p_template     => l_t_tbd,
       p_person       => l_d_tbd);

      set_ei
      (p_shadow       => l_s_date_award_earn,
       p_template     => l_t_date_award_earn,
       p_person       => l_d_date_award_earn);

      set_ei
      (p_shadow       => l_s_appropriation_code,
       p_template     => l_t_appropriation_code,
       p_person       => l_d_appropriation_code);

    hr_utility.set_location(l_proc,40);
    IF l_pa_request_extra_info_id is null then
      hr_utility.set_location(l_proc,45);
          ghr_par_extra_info_api.create_pa_request_extra_info
              (p_validate                    => false,
               p_pa_request_id               => p_pa_request_id,
               p_information_type            => l_information_type,
               p_rei_information_category    => l_information_type,
               p_rei_information3            => l_t_award_agency,
               p_rei_information4            => l_t_award_type,
               p_rei_information6            => l_t_group_award,
               p_rei_information7            => l_t_tbd,
               p_rei_information9            => l_t_date_award_earn,
               p_rei_information10           => l_t_appropriation_code,
               p_pa_request_extra_info_id    => l_dummy,
               p_object_version_number       => l_dummy
              );
    ELSE
      hr_utility.set_location(l_proc,50);

          ghr_par_extra_info_api.update_pa_request_extra_info
              (p_validate                    => false,
               p_rei_information3            => l_d_award_agency,
               p_rei_information4            => l_d_award_type,
               p_rei_information6            => l_d_group_award,
               p_rei_information7            => l_d_tbd,
               p_rei_information9            => l_d_date_award_earn,
               p_rei_information10           => l_d_appropriation_code,
               p_pa_request_extra_info_id    => l_pa_request_extra_info_id,
               p_object_version_number       => l_pa_object_version_number);
    END IF;
    IF l_pa_request_extra_info_sh_id is null then
          insert into ghr_pa_request_ei_shadow
                      (pa_request_extra_info_id,
                       pa_request_id,
                       information_type,
                       rei_information3,
                       rei_information4,
                       rei_information6,
                       rei_information7,
                       rei_information9,
                       rei_information10)
               values (ghr_pa_request_extra_info_s.nextval,
                       p_pa_request_id,
                       l_information_type,
                       l_s_award_agency,
                       l_s_award_type,
                       l_s_group_award,
                       l_s_tbd,
                       l_s_date_award_earn,
                       l_s_appropriation_code);
    ELSE  update ghr_pa_request_ei_shadow
                 set rei_information3  =  l_s_award_agency,
                     rei_information4  =  l_s_award_type,
                     rei_information6  =  l_s_group_award,
                     rei_information7  =  l_s_tbd,
                     rei_information9  =  l_s_date_award_earn,
                     rei_information10 =  l_s_appropriation_code
          where pa_request_extra_info_id = l_pa_request_extra_info_sh_id;
    END IF;

EXCEPTION

    when others then
         hr_utility.set_location('Error in ghr_par_extra info.create pa req'||
                           ' Sql Err is '|| sqlerrm(sqlcode) || l_proc, 60);
         --raise mass_awarderror;

END refresh_award_details;

Procedure set_ei
(p_shadow       in out nocopy  varchar2,
 p_template     in     varchar2,
 p_person       in out nocopy  varchar2,
 p_refresh_flag in     varchar2 default 'Y')
is

   l_shadow  varchar2(240);
   l_person  varchar2(240);
begin

   l_shadow  := p_shadow  ;/*NOCOPY CHANGES*/
   l_person  := p_person ;

  If p_refresh_flag = 'Y' then
    hr_utility.set_location('in set ei  - Y ',5);
    If nvl(p_person,hr_api.g_varchar2) <>  nvl(p_template,hr_api.g_varchar2) and
       nvl(p_person,hr_api.g_varchar2)  =   nvl(p_shadow,hr_api.g_varchar2) then
      p_person := p_template;
    End if;
  Else
     hr_utility.set_location('in set ei  - N ',6);
     p_person := p_template;
  End if;
     p_shadow := p_template;
EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

      p_shadow  := l_shadow  ;
      p_person  := l_person ;
   RAISE;

End set_ei;

Procedure create_shadow_row ( p_rpa_data in ghr_pa_requests%rowtype) is
Begin
 insert into ghr_pa_request_shadow(
        pa_request_id
       ,academic_discipline
       ,annuitant_indicator
       ,appropriation_code1
       ,appropriation_code2
       ,bargaining_unit_status
       ,citizenship
       ,duty_station_id
       ,duty_station_location_id
       ,education_level
       ,employee_date_of_birth
       ,employee_first_name
       ,employee_last_name
       ,employee_middle_names
       ,employee_national_identifier
       ,fegli
       ,flsa_category
       ,forwarding_address_line1
       ,forwarding_address_line2
       ,forwarding_address_line3
       ,forwarding_country_short_name
       ,forwarding_postal_code
       ,forwarding_region_2
       ,forwarding_town_or_city
       ,functional_class
       ,part_time_hours
       ,pay_rate_determinant
       ,position_occupied
       ,retirement_plan
       ,service_comp_date
       ,supervisory_status
       ,tenure
       ,to_ap_premium_pay_indicator
       ,to_auo_premium_pay_indicator
       ,to_occ_code
       ,to_position_id
       ,to_retention_allowance
       ,to_staffing_differential
       ,to_step_or_ratE
       ,to_supervisory_differential
       ,veterans_preference
       ,veterans_pref_for_riF
       ,veterans_status
       ,work_schedule
       ,year_degree_attained
       ,to_retention_allow_percentage
       ,to_supervisory_diff_percentage
       ,to_staffing_diff_percentage
       ,award_amount
       ,award_uom
       ,award_percentage )
    values (
        p_rpa_data.pa_request_id
       ,p_rpa_data.academic_discipline
       ,p_rpa_data.annuitant_indicator
       ,p_rpa_data.appropriation_code1
       ,p_rpa_data.appropriation_code2
       ,p_rpa_data.bargaining_unit_status
       ,p_rpa_data.citizenship
       ,p_rpa_data.duty_station_id
       ,p_rpa_data.duty_station_location_id
       ,p_rpa_data.education_level
       ,p_rpa_data.employee_date_of_birth
       ,p_rpa_data.employee_first_name
       ,p_rpa_data.employee_last_name
       ,p_rpa_data.employee_middle_names
       ,p_rpa_data.employee_national_identifier
       ,p_rpa_data.fegli
       ,p_rpa_data.flsa_category
       ,p_rpa_data.forwarding_address_line1
       ,p_rpa_data.forwarding_address_line2
       ,p_rpa_data.forwarding_address_line3
       ,p_rpa_data.forwarding_country_short_name
       ,p_rpa_data.forwarding_postal_code
       ,p_rpa_data.forwarding_region_2
       ,p_rpa_data.forwarding_town_or_city
       ,p_rpa_data.functional_class
       ,p_rpa_data.part_time_hours
       ,p_rpa_data.pay_rate_determinant
       ,p_rpa_data.position_occupied
       ,p_rpa_data.retirement_plan
       ,p_rpa_data.service_comp_date
       ,p_rpa_data.supervisory_status
       ,p_rpa_data.tenure
       ,p_rpa_data.to_ap_premium_pay_indicator
       ,p_rpa_data.to_auo_premium_pay_indicator
       ,p_rpa_data.to_occ_code
       ,p_rpa_data.to_position_id
       ,p_rpa_data.to_retention_allowance
       ,p_rpa_data.to_staffing_differential
       ,p_rpa_data.to_step_or_ratE
       ,p_rpa_data.to_supervisory_differential
       ,p_rpa_data.veterans_preference
       ,p_rpa_data.veterans_pref_for_riF
       ,p_rpa_data.veterans_status
       ,p_rpa_data.work_schedule
       ,p_rpa_data.year_degree_attained
       ,p_rpa_data.to_retention_allow_percentage
       ,p_rpa_data.to_supervisory_diff_percentage
       ,p_rpa_data.to_staffing_diff_percentage
       ,p_rpa_data.award_amount
       ,p_rpa_data.award_uom
       ,p_rpa_data.award_percentage );
end create_shadow_row;

Procedure update_shadow_row ( p_rpa_data in  ghr_pa_requests%rowtype,
                              p_result   out nocopy  Boolean ) is
Begin
  update ghr_pa_request_shadow
    set
        academic_discipline               = p_rpa_data.academic_discipline
       ,annuitant_indicator               = p_rpa_data.annuitant_indicator
       ,appropriation_code1               = p_rpa_data.appropriation_code1
       ,appropriation_code2               = p_rpa_data.appropriation_code2
       ,bargaining_unit_status            = p_rpa_data.bargaining_unit_status
       ,citizenship                       = p_rpa_data.citizenship
       ,duty_station_id                   = p_rpa_data.duty_station_id
       ,duty_station_location_id          = p_rpa_data.duty_station_location_id
       ,education_level                   = p_rpa_data.education_level
       ,employee_date_of_birth            = p_rpa_data.employee_date_of_birth
       ,employee_first_name               = p_rpa_data.employee_first_name
       ,employee_last_name                = p_rpa_data.employee_last_name
       ,employee_middle_names             = p_rpa_data.employee_middle_names
       ,employee_national_identifier      = p_rpa_data.employee_national_identifier
       ,fegli                             = p_rpa_data.fegli
       ,flsa_category                     = p_rpa_data.flsa_category
       ,forwarding_address_line1          = p_rpa_data.forwarding_address_line1
       ,forwarding_address_line2          = p_rpa_data.forwarding_address_line2
       ,forwarding_address_line3          = p_rpa_data.forwarding_address_line3
       ,forwarding_country_short_name     = p_rpa_data.forwarding_country_short_name
       ,forwarding_postal_code            = p_rpa_data.forwarding_postal_code
       ,forwarding_region_2               = p_rpa_data.forwarding_region_2
       ,forwarding_town_or_city           = p_rpa_data.forwarding_town_or_city
       ,functional_class                  = p_rpa_data.functional_class
       ,part_time_hours                   = p_rpa_data.part_time_hours
       ,pay_rate_determinant              = p_rpa_data.pay_rate_determinant
       ,position_occupied                 = p_rpa_data.position_occupied
       ,retirement_plan                   = p_rpa_data.retirement_plan
       ,service_comp_date                 = p_rpa_data.service_comp_date
       ,supervisory_status                = p_rpa_data.supervisory_status
       ,tenure                            = p_rpa_data.tenure
       ,to_ap_premium_pay_indicator       = p_rpa_data.to_ap_premium_pay_indicator
       ,to_auo_premium_pay_indicator      = p_rpa_data.to_auo_premium_pay_indicator
       ,to_occ_code                       = p_rpa_data.to_occ_code
       ,to_position_id                    = p_rpa_data.to_position_id
       ,to_retention_allowance            = p_rpa_data.to_retention_allowance
       ,to_staffing_differential          = p_rpa_data.to_staffing_differential
       ,to_step_or_ratE                   = p_rpa_data.to_step_or_ratE
       ,to_supervisory_differential       = p_rpa_data.to_supervisory_differential
       ,veterans_preference               = p_rpa_data.veterans_preference
       ,veterans_pref_for_riF             = p_rpa_data.veterans_pref_for_riF
       ,veterans_status                   = p_rpa_data.veterans_status
       ,work_schedule                     = p_rpa_data.work_schedule
       ,year_degree_attained              = p_rpa_data.year_degree_attained
       ,to_retention_allow_percentage     = p_rpa_data.to_retention_allow_percentage
       ,to_supervisory_diff_percentage    = p_rpa_data.to_supervisory_diff_percentage
       ,to_staffing_diff_percentage       = p_rpa_data.to_staffing_diff_percentage
       ,award_amount                      = p_rpa_data.award_amount
       ,award_uom                         = p_rpa_data.award_uom
       ,award_percentage                  = p_rpa_data.award_percentage
  where pa_request_id = p_rpa_data.pa_request_id;

if sql%notfound then
   p_result := FALSE;
else
   p_result := TRUE;
end if;

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_result := NULL;
   RAISE;


end update_shadow_row;

Procedure create_remarks
(p_mass_award_id             in      ghr_mass_awards.mass_award_id%TYPE,
 p_rpa_type                  in      ghr_pa_requests.rpa_type%TYPE,
 p_effective_date            in      date,
 p_pa_request_id             in      ghr_pa_requests.pa_request_id%type
)

is

l_proc                        varchar2(72)  := g_package || 'create_remarks';
l_pa_remark_id                ghr_pa_remarks.pa_remark_id%type;
l_remark_id            	      ghr_pa_remarks.remark_id%type;
l_description          	      ghr_pa_remarks.description%type;
l_remark_code_information1    ghr_pa_remarks.remark_code_information1%type;
l_remark_code_information2    ghr_pa_remarks.remark_code_information2%type;
l_remark_code_information3    ghr_pa_remarks.remark_code_information3%type;
l_remark_code_information4    ghr_pa_remarks.remark_code_information4%type;
l_remark_code_information5    ghr_pa_remarks.remark_code_information5%type;
l_p_pa_remark_id              ghr_pa_remarks.remark_id%type;
l_p_object_version_number     ghr_pa_remarks.object_version_number%type;

cursor cur_rem_tmp is
  select pa_remark_id,
         remark_id,
         description,
         remark_code_information1,
         remark_code_information2,
         remark_code_information3,
         remark_code_information4,
         remark_code_information5
  from ghr_pa_remarks
  where pa_request_id =
  (select pa_request_id from ghr_pa_requests
   where mass_action_id = p_mass_award_id
   and   rpa_type       = p_rpa_type
   and   person_id  is null)
  order by pa_remark_id;

cursor cur_rem is
   select pa_remark_id,
          object_version_number
   from   ghr_pa_remarks
   where  pa_request_id = p_pa_request_id
   and    remark_id     = l_remark_id
   and    description   = l_description
   order by pa_remark_id;

begin

-- get template remarks and descriptions
   hr_utility.set_location('Entering   '  || l_proc,5);

   for cur_rem_tmp_rec in cur_rem_tmp loop
   l_pa_remark_id              :=  cur_rem_tmp_rec.pa_remark_id;
   l_remark_id                 :=  cur_rem_tmp_rec.remark_id;
   l_description               :=  cur_rem_tmp_rec.description;
   l_remark_code_information1  :=  cur_rem_tmp_rec.remark_code_information1;
   l_remark_code_information2  :=  cur_rem_tmp_rec.remark_code_information2;
   l_remark_code_information3  :=  cur_rem_tmp_rec.remark_code_information3;
   l_remark_code_information4  :=  cur_rem_tmp_rec.remark_code_information4;
   l_remark_code_information5  :=  cur_rem_tmp_rec.remark_code_information5;

   l_p_pa_remark_id            := null;
   l_p_object_version_number   := null;

   for cur_rem_rec in cur_rem loop
   l_p_pa_remark_id            := cur_rem_rec.pa_remark_id;
   l_p_object_version_number   := cur_rem_rec.object_version_number;
   end loop;

   if l_p_pa_remark_id is null then
      ghr_pa_remarks_api.create_pa_remarks
      (
       p_pa_request_id                     =>    p_pa_request_id
      ,p_remark_id                         =>    l_remark_id
      ,p_description                       =>    l_description
      ,p_remark_code_information1          =>    l_remark_code_information1
      ,p_remark_code_information2          =>    l_remark_code_information2
      ,p_remark_code_information3          =>    l_remark_code_information3
      ,p_remark_code_information4          =>    l_remark_code_information4
      ,p_remark_code_information5          =>    l_remark_code_information5
      ,p_pa_remark_id                      =>    l_p_pa_remark_id
      ,p_object_version_number             =>    l_p_object_version_number
       );
    else
      ghr_pa_remarks_api.update_pa_remarks
      (p_pa_remark_id                      => l_p_pa_remark_id
      ,p_object_version_number             => l_p_object_version_number
      ,p_remark_code_information1          => l_remark_code_information1
      ,p_remark_code_information2          => l_remark_code_information2
      ,p_remark_code_information3          => l_remark_code_information3
      ,p_remark_code_information4          => l_remark_code_information4
      ,p_remark_code_information5          => l_remark_code_information5
      ,p_description                       => l_description
       );
   end if;
   end loop;

end create_remarks;

Procedure mass_awards_error_handling
  ( p_pa_request_id             in      ghr_pa_requests.pa_request_id%type,
    p_object_version_number     in      ghr_pa_requests.object_version_number%type,
    p_error                     in      varchar2 default null,
    p_result                    out nocopy      boolean
   )

is

---
--- Local variables
---
l_pa_request_id           ghr_pa_requests.pa_request_id%type;
l_object_version_number   ghr_pa_requests.object_version_number%type;
l_person_id               ghr_pa_requests.person_id%type;
l_employee_first_name     ghr_pa_requests.employee_first_name%type;
l_employee_last_name      ghr_pa_requests.employee_last_name%type;
l_employee_middle_names          ghr_pa_requests.employee_middle_names%type;
l_employee_national_identifier   ghr_pa_requests.employee_national_identifier%type;
l_error                   varchar2(2000);
l_log_text                varchar2(2000);
l_proc                    varchar2(72) := 'mass_awards_error_handling';

CURSOR cur_rpa IS
  SELECT object_version_number,
         person_id,
         employee_last_name,
         employee_first_name,
	 employee_middle_names,
	 employee_national_identifier
  FROM   ghr_pa_requests
  WHERE  pa_request_id    =  l_pa_request_id;


begin

   hr_utility.set_location('Entering ..' || l_proc,5);

       l_pa_request_id            := p_pa_request_id;
       l_object_version_number    := p_object_version_number;
       l_error                    := p_error;

   hr_utility.set_location('pa_request_id = ' ||to_char( l_pa_request_id),5);
   hr_utility.set_location('object_version_number = ' ||to_char(l_object_version_number),5);

       ghr_api.call_workflow (
           p_pa_request_id          => l_pa_request_id,
           p_action_taken           => 'CONTINUE',
           p_error                  => l_error);

  for cur_rpa_rec in cur_rpa loop
    hr_utility.set_location( l_proc,10);
    l_object_version_number   := cur_rpa_rec.object_version_number;
    l_person_id               := cur_rpa_rec.person_id;
    l_employee_last_name      := cur_rpa_rec.employee_last_name;
    l_employee_first_name     := cur_rpa_rec.employee_first_name;
    l_employee_middle_names   := cur_rpa_rec.employee_middle_names;
    l_employee_national_identifier := cur_rpa_rec.employee_national_identifier;
    hr_utility.set_location('object_version_number = ' ||to_char( l_object_version_number),10);
  end loop;

	-- Call ghr_par_upd.upd here
       ghr_par_upd.upd(
	   p_pa_request_id   	    => l_pa_request_id,
           p_rpa_type 	            => 'M',
	   p_object_version_number  => l_object_version_number);

    hr_utility.set_location( 'Made Manual RPA' || to_char(l_pa_request_id) ,20);
    hr_utility.set_location( 'Leaving  ' || l_proc ,25);
    -- Bug#3718167 Added SSN to the following log text
    l_log_text := ' ,' || l_employee_last_name || ', ' || l_employee_first_name||' '||l_employee_middle_names
                  ||'SSN: '|| l_employee_national_identifier;

  ghr_wgi_pkg.create_ghr_errorlog(
    p_program_name => g_log_name,
    p_message_name => substr('Manual RPA',1,30),
    p_log_text     => substr('Person id : ' || to_char(l_person_id) || ' ' || l_log_text,1,2000),
    p_log_date     => sysdate);

       p_result := FALSE;

exception when others then
       p_result := TRUE;
  begin
   ghr_par_upd.upd(
	   p_pa_request_id   		=> l_pa_request_id,
           p_mass_action_eligible_flag  => 'Y',
           p_mass_action_select_flag 	=> 'N',
           p_mass_action_comments       =>
                      'PRG: Prgramatically Deselected, Failed at Call Work flow',
	   p_object_version_number      => l_object_version_number);
  exception when others then
           null;
  end;

end mass_awards_error_handling;

--Pradeep added this procedure for bug 3934195
/* Logic is first set the message name and tokens as usual and then use
the fnd_message.get to get the message that we have assigned.
This is to remove the hard coding and using only the messages.
*/

PROCEDURE check_award_amount (p_noa_code  ghr_pa_requests.first_noa_code%TYPE,
                            p_effective_date ghr_pa_requests.effective_date%TYPE,
                            p_award_amount NUMBER,
                            p_from_pay_plan ghr_pa_requests.from_pay_plan%TYPE,
                            p_from_basic_pay_pa ghr_pa_requests.from_basic_pay%TYPE,
                            p_to_position_id ghr_pa_requests.to_position_id%TYPE,
                            p_comments OUT NOCOPY varchar2,
                            p_error_flg OUT NOCOPY BOOLEAN) 	IS
   l_temp                 NUMBER;
   l_max_allowed_amount   NUMBER;
   l_min_allowed_amount   NUMBER;
  --BUG 5482191
   l_psi                  VARCHAR2(10);
BEGIN
   --bug 5482191

   l_psi := ghr_pa_requests_pkg.get_personnel_system_indicator(p_to_position_id,p_effective_date);


	p_error_flg := FALSE;
   --Check for Maximum Amount.
   fnd_message.set_name ('GHR', 'GHR_38904_AWARD_AMT_TOO_BIG5');

   IF  p_noa_code  = '844' THEN
      l_max_allowed_amount := 5 * p_from_basic_pay_pa / 100;
      fnd_message.set_token ('ALLOWED', '5%');
   ELSIF p_noa_code IN ('840', '841', '879') THEN
      l_max_allowed_amount := 25 * p_from_basic_pay_pa / 100;
      fnd_message.set_token ('ALLOWED', '25%');
   ELSIF p_noa_code IN ('878') THEN
      l_max_allowed_amount := 35 * p_from_basic_pay_pa / 100;
      fnd_message.set_token ('ALLOWED', '35%');
 --bug 5482191
  ELSIF (p_noa_code IN ('849')  and l_psi = '00' ) THEN
      l_max_allowed_amount := 35 * p_from_basic_pay_pa / 100;
      fnd_message.set_token ('ALLOWED', '35%');

   ELSIF p_noa_code  IN ('825', '842', '843', '848') THEN
      l_max_allowed_amount := 25000;
      fnd_message.set_name ('GHR', 'GHR_38905_AWARD_AMT_TOO_BIG6');
      fnd_message.set_token ('ALLOWED', '$25000');
   END IF;

   /*
     Existing Handling of 816 and 815 is not changed make sure
     that 815 and 816 are not included in above list.
   */
   IF p_noa_code = '816' THEN
      IF p_from_pay_plan = 'EE' THEN
         IF (50 * p_from_basic_pay_pa / 100) > 50000 THEN
            l_max_allowed_amount := 50000;
         ELSE
            l_max_allowed_amount := 50 * p_from_basic_pay_pa / 100;
         END IF;

         IF p_award_amount > l_max_allowed_amount THEN
            fnd_message.set_name ('GHR', 'GHR_38898_AWARD_AMT_TOO_BIG3');
				p_comments := p_comments||fnd_message.get;
				p_error_flg := TRUE;
				fnd_message.clear;
         END IF;
       ELSIF (    ghr_pay_calc.leo_position (
                    p_prd => l_temp,
                    p_position_id=> p_to_position_id,
                    p_retained_user_table_id=> l_temp,
                    p_duty_station_id=> l_temp,
                    p_effective_date=> p_effective_date
					  )
            ) THEN

			l_max_allowed_amount := 25 * p_from_basic_pay_pa / 100;
                        IF l_max_allowed_amount < 15000 THEN
				l_max_allowed_amount := 15000;
	    END IF;
			IF p_award_amount  > l_max_allowed_amount  THEN
				fnd_message.set_name ('GHR', 'GHR_38896_AWARD_AMT_TOO_BIG2');
				p_comments := p_comments||fnd_message.get;
				p_error_flg := TRUE;
				fnd_message.clear;
			END IF;
      ELSIF (    NOT ghr_pay_calc.leo_position (
                        p_prd => l_temp,
                        p_position_id=> p_to_position_id,
                        p_retained_user_table_id=> l_temp,
                        p_duty_station_id=> l_temp,
                        p_effective_date=> p_effective_date
                     )
            ) THEN
			l_max_allowed_amount := 25 * p_from_basic_pay_pa / 100;

			IF p_award_amount > l_max_allowed_amount THEN
				fnd_message.set_name ('GHR', 'GHR_AWARD_AMT_TOO_BIG');
				p_comments := p_comments||fnd_message.get;
				p_error_flg := TRUE;
				fnd_message.clear;
			END IF;
      END IF;
   ELSIF   p_noa_code = '815' THEN
      IF p_from_pay_plan = 'EE' THEN
         IF (50 * p_from_basic_pay_pa / 100) > 50000 THEN
            l_max_allowed_amount := 50000;
         ELSE
            l_max_allowed_amount := 50 * p_from_basic_pay_pa / 100;
         END IF;

         IF p_award_amount > l_max_allowed_amount THEN
            fnd_message.set_name ('GHR', 'GHR_38898_AWARD_AMT_TOO_BIG3');
				p_comments := p_comments||fnd_message.get;
				p_error_flg := TRUE;
				fnd_message.clear;
         END IF;
      ELSE
         l_max_allowed_amount := 25 * p_from_basic_pay_pa / 100;
         fnd_message.set_token ('ALLOWED', '25%');
			p_comments := p_comments||fnd_message.get;
			p_error_flg := TRUE;
			fnd_message.clear;
      END IF;
   END IF;

   -- Raise an Error if Award Amount is Greater than the Maximum Allowed Amount.
   --IF p_award_amount > round(l_max_allowed_amount) THEN

   IF p_award_amount > floor(l_max_allowed_amount) THEN
      p_comments := fnd_message.get;
		p_error_flg := TRUE;
      fnd_message.CLEAR;
   ELSE
      fnd_message.CLEAR;
   END IF;

   --Check for Minimum Amount.
   fnd_message.set_name ('GHR', 'GHR_38903_AWARD_AMT_TOO_LESS');

   --Getting the Minimum Allowed Amount.
   IF p_noa_code = '879' THEN
      l_min_allowed_amount := 5 * p_from_basic_pay_pa / 100;
      fnd_message.set_token ('ALLOWED', '5%');
   END IF;

   -- Raise an Error if Award Amount is Less than the Minimum Allowed Amount.
   IF p_award_amount < trunc(l_min_allowed_amount) THEN
      p_comments := fnd_message.get;
		p_error_flg := TRUE;
      fnd_message.clear;
   ELSE
      fnd_message.clear;
   END IF;

END check_award_amount;

END GHR_MASS_AWARDS_PKG;

/
