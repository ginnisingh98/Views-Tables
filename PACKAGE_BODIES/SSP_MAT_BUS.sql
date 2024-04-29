--------------------------------------------------------
--  DDL for Package Body SSP_MAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_MAT_BUS" as
/* $Header: spmatrhi.pkb 120.5.12010000.3 2008/08/13 13:27:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_mat_bus.';  -- Global package name
--
--  Business Validation Rules
--
-- -----------------------------------------------------------------------------
-- |---------------------------------<  Validate_Female_Sex >-------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Maternity details may only be entered for Females
--
Procedure validate_female_sex (p_person_id in number) is
--
p_sex  varchar2(30);
l_proc  varchar2(72) := g_package||'validate_female_sex';
--
cursor csr_person is
	--
	-- Get the sex of the person
	--
	select p.sex
	from per_all_people_f p
	where p.person_id = p_person_id;
	--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error
		(p_api_name		=> l_proc,
		p_argument		=> 'person_id',
		p_argument_value	=> p_person_id);
	--
	end check_parameters;
	--
BEGIN
--
hr_utility.set_location ('Entering '||l_proc,1);
--
check_parameters;
--
open csr_person;
fetch csr_person into p_sex;
--
if csr_person%notfound then
  --
  -- The person id is not valid
  --
  close csr_person;
  fnd_message.set_name ('SSP' , 'SSP_35057_BAD_PERSON_ID' ) ;
  fnd_message.raise_error;
  --
elsif p_sex <> 'F' then
  --
  -- The person is not female (and therefore may not have maternity)
  --
  close csr_person;
  fnd_message.set_name ('SSP', 'SSP_35002_PER_NOT_FEMALE');
  fnd_message.raise_error;
  --
else
  close csr_person;
end if;
--
hr_utility.set_location ('Leaving '||l_proc,10);
--
END validate_female_sex;

--
-- -----------------------------------------------------------------------------
-- ---------------------< unique_person_due_date >------------------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Ensure that no existing baby due_dates have been previously entered
--    for this person
--
Procedure unique_person_due_date (
	--
	p_due_date in date,
	p_person_id in number,
        p_leave_type in varchar2,
	p_maternity_id in number) is
	--
l_proc varchar2 (72) := g_package||'unique_person_due_date';
--
cursor csr_duplicate_due_date is
	--
	-- Get that the due date is unique for the person
	--
	select	1
	from	ssp_maternities h
	where	due_date = p_due_date
	and	person_id = p_person_id
        and     nvl(leave_type,'MA') = nvl(p_leave_type,'MA')
	and	maternity_id <> nvl(p_maternity_id,0);
	--
duplicate_due_date_rec csr_duplicate_due_date%ROWTYPE;
--
BEGIN
--
hr_utility.set_location (l_proc,1);
--
open csr_duplicate_due_date;
fetch csr_duplicate_due_date into duplicate_due_date_rec;
--
if csr_duplicate_due_date%FOUND then
  --
    close csr_duplicate_due_date;
    fnd_message.set_name ('SSP', 'SSP_35009_DUP_DUE_DATE');
    fnd_message.raise_error;
  --
end if;
--
close csr_duplicate_due_date;
--
hr_utility.set_location (l_proc,100);
--
END unique_person_due_date;
--
-- -----------------------------------------------------------------------------
-- -------------------------< check_actual_birth >-----------------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Ensure the birth date is not defined in the future
--

Procedure check_actual_birth (p_actual_birth_date in date) is
BEGIN
    if p_actual_birth_date > SYSDATE then
       fnd_message.set_name('SSP','SSP_35003_INV_FUTURE_DATE');
       fnd_message.raise_error;
    end if;
END check_actual_birth;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_live_birth >------------------------------
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Check that the a birth date is entered if live_birth_flag is No
--

 Procedure check_live_birth (p_live_birth_flag in out nocopy varchar2, p_actual_birth_date in date) is
 BEGIN
     if p_live_birth_flag = 'N' and p_actual_birth_date is null then
        fnd_message.set_name ('SSP', 'SSP_35004_LIVE_BIRTH_FLAG');
        fnd_message.raise_error;
        p_live_birth_flag := 'Y';
     end if;
 END check_live_birth;
--
-- ---------------------------------------------------------------------------
-- |------------------------------< check_date_notified  >--------------------
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Ensure the birth notification date is not before the actual birth date
--

Procedure check_date_notified (p_notification_of_birth_date in date,
                                    p_actual_birth_date in date) is
BEGIN
    if p_notification_of_birth_date < p_actual_birth_date then
      fnd_message.set_name ('SSP', 'SSP_35012_EARLY_BIRTH_NOTIFIC');
      fnd_message.raise_error;
    elsif p_notification_of_birth_date > SYSDATE then
      fnd_message.set_name ('SSP', 'SSP_35019_INV_NOTIF_DATE');
      fnd_message.raise_error;
    end if;
END check_date_notified;
--
-- -----------------------------------------------------------------------------
-- ---------------------< check_stated_ret_date >------------------------------
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    1.  Cannot enter a stated reurn date if return status is No
--    2.  Stated return date cannot be before the maternity pay period
--        start date
--    3.  Stated return date cannot be before the earliest mpp start date
--

Procedure check_stated_ret_date (p_stated_return_date in date,
                                       p_intend_to_return in varchar2,
                                       p_mpp_start_date in date,
                                       p_earliest_mpp_start in date) is
BEGIN
    if p_intend_to_return = 'N' and p_stated_return_date is not null then
       fnd_message.set_name('SSP', 'SSP_35013_INV_EVNT_RET_DATE');
       fnd_message.raise_error;
    elsif p_stated_return_date < nvl(p_mpp_start_date, p_stated_return_date) then
       fnd_message.set_name ('SSP', 'SSP_35006_RET_DATE_LT_MPP');
       fnd_message.raise_error;
    elsif p_stated_return_date < nvl(p_earliest_mpp_start, p_stated_return_date) then
       fnd_message.set_name ('SSP','SSP_35007_RET_DTE_LT_EMPSD');
       fnd_message.raise_error;
    end if;
END check_stated_ret_date;
--
--------------------------------------------------------------------------------
-- ----------------------------< check_MPP_start_date >-------------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--     If no actual_birth_date is entered, the mpp_start_date cannot be before
--     the earliest_mpp_start_date. Otherwise the actual_birth_date is the next
--     sunday after the actual_birth_date.
--

Procedure check_MPP_start_date (p_mpp_start_date in out nocopy date,
				p_earliest_mpp_start_date in date,
				p_actual_birth_date in date) is
BEGIN
   if p_mpp_start_date < p_earliest_mpp_start_date and p_actual_birth_date IS NULL then
     fnd_message.set_name ('PER', 'SSP_35114_SMCAL_EMPP_TOO_EARLY');
     fnd_message.raise_error;
   end if;

   if NOT(p_actual_birth_date IS NULL) then
      if (p_mpp_start_date IS NULL) OR (p_mpp_start_date < p_earliest_mpp_start_date) THEN
         ssp_mat_bus.default_mpp_date(p_actual_birth_date, p_mpp_start_date);
      end if;
   end if;

END check_MPP_start_date;

Procedure check_MPP_start_date_2 (p_mpp_start_date in date,
                                  p_person_id in number,
                                  p_ewc in date,
			       	  p_earliest_mpp_start_date in date,
                                  p_due_date in date,
                                  p_prev_mpp_start_date in date,
				  p_actual_birth_date in date) is

cursor pregnancy_related_absences is
select paa.sickness_start_date,
       paa.sickness_end_date
from   per_absence_attendances paa
where  paa.person_id = p_person_id
and    paa.pregnancy_related_illness = 'Y'
and    (p_ewc - 28) <= nvl(paa.sickness_end_date, fnd_date.canonical_to_date('4712/12/31 00:00:00'))
and    p_ewc >= paa.sickness_start_date;
--
l_pregnancy_related_illness pregnancy_related_absences%ROWTYPE;
--  bug 2649315, translation fix
l_sunday    varchar2(100) := to_char(to_date('07/01/2001','DD/MM/YYYY'),'fmDAY');

BEGIN
--
-- Find out if there are any pregnancy related absences
--
  OPEN pregnancy_related_absences;
  FETCH pregnancy_related_absences into l_pregnancy_related_illness;
  --
  -- Do not apply Sunday only validation to those maternities
  -- where the person has a pregnancy related absence
  -- within four weeks of the EWC
  --
  --  this conditions checks if the baby is born earlier then the mpp start date
  --  if yes then it allows the mpp start date to be ABD + 1 else raises the error.
  if   p_due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00') and
       (p_prev_mpp_start_date is null or p_actual_birth_date < p_prev_mpp_start_date) and
       p_actual_birth_date is not null then
         if  p_mpp_start_date = p_actual_birth_date + 1  then
             CLOSE pregnancy_related_absences;
             null;
         elsif p_due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00') and
               p_actual_birth_date > p_prev_mpp_start_date and
               p_actual_birth_date is not null then
                 -- user cannot reset the value of MPP
                 if p_prev_mpp_start_date <> p_mpp_start_date then
                   fnd_message.set_name('SSP','SSP_36078_MPP_RESET_MPP');
                   fnd_message.raise_error;
                 end if;
         elsif ( p_due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00')
                and p_mpp_start_date = p_actual_birth_date + 1 ) or
                ( pregnancy_related_absences%FOUND and
                p_mpp_start_date = l_pregnancy_related_illness.sickness_start_date ) then
                  CLOSE pregnancy_related_absences;
                  null;
         -- Bug 3944196 - additional check
         elsif ( p_due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00') and
                 p_actual_birth_date + 1 = p_prev_mpp_start_date and
                 p_actual_birth_date is not null) then
                 CLOSE pregnancy_related_absences;
                 null;
         else
            CLOSE pregnancy_related_absences;
            fnd_message.set_name('SSP','SSP_36077_MPP_PREMATURE_DAY');
            fnd_message.raise_error;
         end if;
  -- This condition checks if the baby was born during the MPP, if yes then
  -- the user cannot set the MPP start date here
  /*
  elsif pregnancy_related_absences%FOUND and
        p_mpp_start_date <> l_pregnancy_related_illness.sickness_start_date then
          CLOSE pregnancy_related_absences;
          fnd_message.set_name('SSP','SSP_36079_MPP_SICKNESS_DAY');
          fnd_message.raise_error;
  */
  -- begin bug fix 5331152
  elsif pregnancy_related_absences%FOUND and
        p_mpp_start_date = l_pregnancy_related_illness.sickness_start_date then
          CLOSE pregnancy_related_absences;
          fnd_message.set_name('SSP','SSP_35051_MPP_ILLNESS_DATE');
          fnd_message.raise_error;
  elsif pregnancy_related_absences%FOUND and
        p_mpp_start_date = l_pregnancy_related_illness.sickness_start_date + 1 then
          CLOSE pregnancy_related_absences;
          null;
  -- end bug fix 5331152
  elsif p_due_date >= fnd_date.canonical_to_date('2003/04/06 00:00:00') and
        p_actual_birth_date is not null and
        p_mpp_start_date <> p_actual_birth_date + 1 then
          CLOSE pregnancy_related_absences;
          fnd_message.set_name('SSP','SSP_36077_MPP_PREMATURE_DAY');
          fnd_message.raise_error;
  elsif to_char(to_date(to_char(p_mpp_start_date,'DD/MM/YYYY'),'DD/MM/YYYY'),'fmDAY') <> l_sunday
        and
        p_due_date < fnd_date.canonical_to_date('2007/04/01 00:00:00') then
          CLOSE pregnancy_related_absences;
          fnd_message.set_name('SSP','SSP_35054_MPP_NOT_SUNDAY');
          fnd_message.raise_error;
  end if;

END check_MPP_start_date_2;

--------------------------------------------------------------------------------
-- ----------------------------< check_forward_MPP_date >-----------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--     The MPP start date cannot be before the start date of maternity allowance
--

Procedure check_forward_MPP_date (p_start_date_mat_allow in date,
                                 p_mpp_start_date in out nocopy date) is
BEGIN
    if p_mpp_start_date is null and p_start_date_mat_allow is not null
    then
      p_mpp_start_date := p_start_date_mat_allow;
    elsif p_mpp_start_date > nvl(p_start_date_mat_allow, p_mpp_start_date)
      then
      fnd_message.set_name ('SSP', 'SSP_35014_FWD_MPP_START');
      fnd_message.raise_error;
    end if;
END check_forward_MPP_date;
--
-- -----------------------------------------------------------------------------
-- -----------------------< get_SMP_element_details >---------------------------
-- -----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Retrieve statutory SMP details
-->>>>

PROCEDURE get_SMP_element_details
(
p_effective_date   in  date,
p_element_name     in  varchar2,
p_element_details  out nocopy ssp_SMP_pkg.csr_SMP_element_details%ROWTYPE
) is

  l_proc  varchar2(72) := g_package||'get_SMP_element_details';

begin

  open ssp_SMP_pkg.csr_SMP_element_details(p_effective_date, p_element_name);
  fetch ssp_SMP_pkg.csr_SMP_element_details into p_element_details;
  close ssp_SMP_pkg.csr_SMP_element_details;

end get_SMP_element_details;
--
-- -----------------------------------------------------------------------------
-- ----------------------------< late_evidence >--------------------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check whether maternity evidence was late
--

FUNCTION  late_evidence
          (p_maternity_id  in number,
           p_evidence_rcvd in date,
           p_effective_date in date,
           p_element_name  in varchar2)
  return boolean is
--
  l_element_details   ssp_SMP_pkg.csr_SMP_element_details%ROWTYPE;
  l_late_evidence     BOOLEAN;
  l_chk_date          DATE;
  cursor c1 is
    select m.mpp_start_date
    from   ssp_maternities m
    where  m.maternity_id = p_maternity_id;
  c1_rec c1%ROWTYPE;

BEGIN
  get_SMP_element_details(p_effective_date, p_element_name, l_element_details);
--
  open c1;
  fetch c1 into c1_rec;
  close c1;
--
  l_chk_date := c1_rec.mpp_start_date + l_element_details.latest_smp_evidence;

  if p_evidence_rcvd > l_chk_date then
    return(TRUE);
  else
    return(FALSE);
  end if;
END late_evidence;
--
-- -----------------------------------------------------------------------------
-- ----------------------< evd_before_ewc_due_date_change >---------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check the evidence date is valid if the due date is being
--              changed, in case this invalidates evidence being input.
--

PROCEDURE evd_before_ewc_due_date_change
(
p_qualifying_week in date,
p_ewc             in date,
p_maternity_id    in number
) is
  l_element_details    ssp_SMP_pkg.csr_SMP_element_details%ROWTYPE;
  l_chk_date  date;
  l_proc  varchar2(72) := g_package||'evd_before_ewc_due_date_change';

  cursor csr_evidence is
    select evidence_date from ssp_medicals
     where maternity_id = p_maternity_id;

BEGIN
  get_SMP_element_details(p_qualifying_week,
                          'Statutory Maternity Pay', l_element_details);
  --
  l_chk_date := p_ewc - l_element_details.earliest_SMP_evidence;

  for csr_ev in csr_evidence loop
    if csr_ev.evidence_date < l_chk_date then
      fnd_message.set_name ('SSP', 'SSP_36075_EVIDENCE_NOW_INVALID');
      fnd_message.raise_error;
    end if;
  end loop;
  --
END evd_before_ewc_due_date_change;

-- -----------------------------------------------------------------------------
-- -----------------------------------< evd_before_ewc >------------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check the evidence date is valid
--

PROCEDURE evd_before_ewc
          (p_ewc           in date,
           p_evidence_date in date,
           p_effective_date in date,
           p_element_name  in varchar2) is
  l_element_details    ssp_SMP_pkg.csr_SMP_element_details%ROWTYPE;
  l_chk_date  DATE;
BEGIN
  get_SMP_element_details(p_effective_date, p_element_name, l_element_details);
  --
  l_chk_date := p_ewc - l_element_details.earliest_SMP_evidence;
  if p_evidence_date < l_chk_date then
    fnd_message.set_name ('SSP', 'SSP_35028_LATE_EVID_DATE');
    fnd_message.raise_error;
  end if;
END evd_before_ewc;

-- -----------------------------------------------------------------------------
-- --------------------------------< default_mpp_date >-------------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Default the MPP start date if the birth date has been specified
--    and the mpp_date is null
--
PROCEDURE default_mpp_date(p_actual_birth_date in date,
			   p_mpp_start_date in out nocopy date)
is
  l_day_number number;
BEGIN
--
-- Amended the logic of the procedure by re-introducing the check
--for mpp_date is null. which was removed without a reason.
--
  if p_actual_birth_date is not null and
       p_mpp_start_date is null then
--  if p_actual_birth_date is not null then
    begin
      l_day_number := to_number(to_char(p_actual_birth_date,'D'));
      if l_day_number <> 1 then
	p_mpp_start_date := p_actual_birth_date + (8 - l_day_number);
      elsif l_day_number = 1 then
	p_mpp_start_date := p_actual_birth_date;
      end if;
    end;
  end if;
END default_mpp_date;

-- -----------------------------------------------------------------------------
-- ----------------------------< default_date_notification >--------------------
-- -----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Default the date notification when an actual birth date is entered
--    to sysdate
--
PROCEDURE default_date_notification(p_actual_birth_date in date,
				    p_notif_of_birth_date in out nocopy date
				    ) is
BEGIN
  if p_actual_birth_date is not null and
      p_notif_of_birth_date is null then
	p_notif_of_birth_date := SYSDATE;
  end if;
END default_date_notification;

PROCEDURE default_date_notification(p_actual_birth_date in date,
                                    p_effective_date    in date,
                                    p_notif_of_birth_date in out nocopy date
                                    ) is
BEGIN
  if p_actual_birth_date is not null and
      p_notif_of_birth_date is null then
        p_notif_of_birth_date := p_effective_date;
  end if;
END default_date_notification;

PROCEDURE CHECK_CHILD_EXPECTED_DATE(p_due_date in date,
            p_matching_date in date) is
    Begin
        If p_due_date < p_matching_date then
            fnd_message.set_name('SSP','SSP_36094_CHILD_EXPECTED_DATE');
            fnd_message.raise_error;
        End if;
    End;

PROCEDURE CHECK_APP_START_DATE(p_mpp_start_date in date,
            p_placement_date in date,
            p_due_date in date) is
     Begin

        If p_placement_date is not null and p_mpp_start_date > p_placement_date then
            fnd_message.set_name('SSP','SSP_36085_APP_DATE_PLACEMENT');
            fnd_message.raise_error;
        end if;

        If p_mpp_start_date < ssp_sap_pkg.EARLIEST_APP_START_DATE(p_due_date) then
            fnd_message.set_name('SSP','SSP_36083_APP_DATE_EARLY');
            fnd_message.raise_error;
        End if;

        If p_placement_date is null and p_mpp_start_date > p_due_date then
            fnd_message.set_name('SSP','SSP_36098_APP_DATE_LATE');
            fnd_message.raise_error;
        End if;

     End ;

PROCEDURE CHECK_PPPA_START_DATE(p_ppp_start_date in date,
            p_placement_date in date,
            p_due_date     in date) is
begin
  if p_placement_date is null and p_ppp_start_date is not null then
     fnd_message.set_name('SSP','SSP_36090_PPP_DATE_PLACE_NULL');
     fnd_message.raise_error;
  end if;

  if p_ppp_start_date < ssp_pad_pkg.EARLIEST_PPP_START_DATE(p_placement_date)
     then
       fnd_message.set_name('SSP','SSP_36088_PPP_DATE_PLACE_EARLY');
       fnd_message.raise_error;
  end if;

  if p_ppp_start_date > ssp_pad_pkg.LATEST_PPP_START_DATE(p_placement_date)
     then
       fnd_message.set_name('SSP','SSP_36087_PPP_DATE_PLACE_LATE');
       fnd_message.raise_error;
  end if;
end;

PROCEDURE CHECK_PPP_START_DATE(p_ppp_start_date in date,
            p_birth_date in date,
            p_ewc in date,
            p_due_date in date) is
begin
  if p_birth_date is null and p_ppp_start_date is not null then
     fnd_message.set_name('SSP','SSP_36092_PPP_DATE_BIRTH_NULL');
     fnd_message.raise_error;
  end if;

  if p_ppp_start_date > ssp_pab_pkg.LATEST_PPP_START_DATE(p_birth_date,
                                                          p_ewc,
                                                          p_due_date)
     then
       fnd_message.set_name('SSP','SSP_36097_PPP_DATE_BIRTH_LATE');
       fnd_message.raise_error;
  end if;

  if p_ppp_start_date < ssp_pab_pkg.EARLIEST_PPP_START_DATE(p_birth_date)
     then
       fnd_message.set_name('SSP','SSP_36096_PPP_DATE_BIRTH');
       fnd_message.raise_error;
  end if;

end;

PROCEDURE CHECK_PLACEMENT_DATE( p_placement_date in date,
            P_MATCHING_DATE IN DATE) is
begin
    If p_placement_date < P_MATCHING_DATE then
            fnd_message.set_name('SSP','SSP_36091_PLACE_DATE_MATCHING');
            fnd_message.raise_error;
    End if;
End;

PROCEDURE CHECK_DISRUPTED_PLACEMENT_DATE (p_disrupted_placement_date in date,
            p_mpp_start_date in date) is
Begin
    If p_disrupted_placement_date < p_mpp_start_date then
         fnd_message.set_name('SSP','SSP_36095_APP_DATE_DISRUPTED');
         fnd_message.raise_error;
    End if;
End ;


Procedure check_adopt_child_birth_dt(p_actual_birth_date in date,
            p_due_date in date) is
BEGIN
    NULL;
/* Removed 18 year check due to legislation change
    if months_between(p_due_date,p_actual_birth_date)/12 > 18 then
         fnd_message.set_name('SSP','SSP_36093_ACTUALBIRTH_DATE_18');
         fnd_message.raise_error;
    end if;
*/
END;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_kit_days >-------------------------------
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Check that the a
 --date entered is within the MPP/APP periods
--    and if MA type, also check that it is 2 weeks after Birth Date
--
Procedure check_kit_days(p_rec in ssp_mat_shd.g_rec_type) is

    cursor c_get_ma_end_date is                /* Bug 6003570 */
    select max(date_end) end_date
    from per_absence_attendances
    where maternity_id=p_rec.maternity_id;

      l_2_weeks constant number := 14;
      l_2_weeks_after_birth date;
      l_start_date          date := p_rec.mpp_start_date;
      l_end_date            date;
      l_get_ma_end_date     date;

      procedure validate_kit(p_start in date,
                             p_end   in date,
                             p_date  in date) is
      begin
           if p_date is not null then
              if p_start is null then
                 fnd_message.set_name ('SSP', 'SSP_35083_KIT_DAY_NO_MPP_APP');
                 fnd_message.raise_error;
              end if;
              if p_date < p_start or
                 p_date > p_end then
                 fnd_message.set_name ('SSP', 'SSP_35081_KIT_DAY_PERIOD');
                 fnd_message.set_token('DATE1', p_start);
                 fnd_message.set_token('DATE2',p_end);
                 fnd_message.raise_error;
              else
	       /*Bug 7025371  if p_date <= l_2_weeks_after_birth then */
                 if p_date between p_rec.actual_birth_date+1 and p_rec.actual_birth_date + 15 then
                    fnd_message.set_name ('SSP', 'SSP_35082_KIT_DAY_NOT_ALLOWS');
                    fnd_message.raise_error;
                 end if;
              end if;
           end if;
      end;


BEGIN

     l_2_weeks_after_birth := to_date('01/01/0001','DD/MM/YYYY');
     --
     if p_rec.mat_information_category is not null then
        if p_rec.leave_type = 'MA' then
           if p_rec.actual_birth_date is not null then
              l_2_weeks_after_birth := p_rec.actual_birth_date + 14;
           end if;

	  -- begin
	   open c_get_ma_end_date;
	   fetch c_get_ma_end_date into   l_get_ma_end_date;
	   close c_get_ma_end_date;
	  -- end;

           l_end_date := least(ssp_smp_pkg.get_max_SMP_date(p_rec.maternity_id), nvl(l_get_ma_end_date,to_date('31-12-4712','DD-MM-YYYY')));

        else -- type = 'AD'
           l_end_date := ssp_sap_pkg.get_max_SAP_date(p_rec.maternity_id);
        end if;
        --


        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information1));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information2));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information3));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information4));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information5));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information6));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information7));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information8));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information9));
        validate_kit(l_start_date,l_end_date,fnd_date.canonical_to_date(p_rec.mat_information10));
     end if;
END check_kit_days;
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in out nocopy ssp_mat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_earliest_mpp_start date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  unique_person_due_date (p_rec.due_date,
                        p_rec.person_id,
                        p_rec.leave_type,
                        p_rec.maternity_id);

  if nvl(p_rec.leave_type,'MA') = 'MA' then
     validate_female_sex (p_rec.person_id);
  --
  -- unique_person_due_date (p_rec.due_date,
  --			p_rec.person_id,
  --			p_rec.maternity_id);
  --
     check_live_birth (p_rec.live_birth_flag, p_rec.actual_birth_date);
  --
     default_mpp_date (p_rec.actual_birth_date, p_rec.mpp_start_date);
  --
     check_date_notified (p_rec.notification_of_birth_date,
			p_rec.actual_birth_date);
  --
     l_earliest_mpp_start := ssp_SMP_pkg.earliest_mpp_start_date (p_rec.due_date);
  --
     check_stated_ret_date (p_rec.stated_return_date,
			p_rec.intend_to_return_flag,
			p_rec.mpp_start_date,
			l_earliest_mpp_start);
  --
     if p_rec.start_date_maternity_allowance is not null then
         check_forward_MPP_date (p_rec.start_date_maternity_allowance,
				p_rec.mpp_start_date) ;
     end if;

  --
     check_kit_days(p_rec);
  --
  elsif p_rec.leave_type ='AD' then
     l_earliest_mpp_start := ssp_SAP_pkg.earliest_App_start_date (p_rec.due_date);
  --
     check_stated_ret_date (p_rec.stated_return_date,
                        p_rec.intend_to_return_flag,
                        p_rec.mpp_start_date,
                        l_earliest_mpp_start);
  --
     check_kit_days(p_rec);
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in out nocopy ssp_mat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_earliest_mpp_start date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  unique_person_due_date (p_rec.due_date,
			  p_rec.person_id,
                          p_rec.leave_type,
			  p_rec.maternity_id);
  --
  --
  if nvl(p_rec.leave_type,'MA') = 'MA' then

     check_live_birth (p_rec.live_birth_flag, p_rec.actual_birth_date);
  --
     default_mpp_date (p_rec.actual_birth_date, p_rec.mpp_start_date);
  --
     check_date_notified (p_rec.notification_of_birth_date, p_rec.actual_birth_date);
  --
     l_earliest_mpp_start := ssp_SMP_pkg.earliest_mpp_start_date (p_rec.due_date);
     check_stated_ret_date (p_rec.stated_return_date, p_rec.intend_to_return_flag,
                             p_rec.mpp_start_date, l_earliest_mpp_start);
  --
     if p_rec.start_date_maternity_allowance is not null then
       check_forward_MPP_date (p_rec.start_date_maternity_allowance, p_rec.mpp_start_date) ;
     end if;
  --
     check_kit_days(p_rec);
  --
  elsif p_rec.leave_type ='AD' then
     l_earliest_mpp_start := ssp_SAP_pkg.earliest_App_start_date (p_rec.due_date);

     check_stated_ret_date (p_rec.stated_return_date,
                        p_rec.intend_to_return_flag,
                        p_rec.mpp_start_date,
                        l_earliest_mpp_start);
  --
     check_kit_days(p_rec);
  --
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ssp_mat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ssp_mat_bus;

/
