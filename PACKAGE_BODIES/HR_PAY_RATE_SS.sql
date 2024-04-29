--------------------------------------------------------
--  DDL for Package Body HR_PAY_RATE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAY_RATE_SS" AS
/* $Header: hrpaywrs.pkb 120.10.12010000.8 2009/10/30 10:16:36 gpurohit ship $*/


g_package  varchar2(30) := 'hr_pay_rate_ss';

    inv_next_sal_date_warn boolean;
    proposed_salary_warn boolean;
    approved_warn boolean;
    payroll_warn boolean;
    basischanged boolean;
 -- Package scope global variables.
  l_transaction_table hr_transaction_ss.transaction_table;

 l_count INTEGER := 0;
 p_count INTEGER := 0;
 l_praddr_ovrlap VARCHAR2(2);
-- ln_no_of_components INTEGER  := 0;

  -- p_login_person_id       per_all_people_f.person_id%TYPE;
 l_trans_step_id  hr_api_transaction_steps.transaction_step_id%type;
 ltt_trans_obj_vers_num  hr_api_transaction_steps.object_version_number%type;
 p_trans_rec_count INTEGER;
 g_data_error            exception;
 g_exceeded_grade_range  exception;
 g_asg_api_name          constant  varchar2(80)
                         default 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
 -- 04/12/02 Salary Basis Enhancement Change Begins
 g_mid_pay_period_change  constant varchar2(30) := 'HR_MID_PAY_PERIOD_CHANGE';

function check_ele_eligibility(p_asg_id in number,
                               p_eff_date in varchar2) Return boolean IS

l_proc varchar2(200) := g_package || 'check_ele_eligibility';

Cursor c1 (p_aid number, p_date date) IS
select ivf.element_type_id
 from per_all_assignments_f paf,
      per_pay_bases pb, pay_input_values_f ivf
where paf.assignment_id = p_aid
--and paf.assignment_type = 'E'
and pb.pay_basis_id = paf.pay_basis_id
and pb.input_value_id = ivf.input_value_id
and p_date between paf.effective_start_date and paf.effective_end_date
and p_date between ivf.effective_start_date and ivf.effective_end_date;


l_tmp number := null;
begin

 hr_utility.set_location(' Entering:' || l_proc,5);

 Open c1 (p_asg_id, to_date(p_eff_date,'RRRR-MM-DD'));
   Fetch c1 into l_tmp;
 Close c1;
   l_tmp := hr_entry_api.get_link(p_asg_id, l_tmp,
                                 to_date(p_eff_date,'RRRR-MM-DD'));

   if (l_tmp is not null) then
      hr_utility.set_location(' Leaving:' || l_proc,10);
      return true;
   end If;
   hr_utility.set_location(' Leaving:' || l_proc,15);
  return false;
Exception when others then
  hr_utility.set_location(' Leaving:' || l_proc,555);
  return false;
end check_ele_eligibility;


-- 05/14/2002 - Bug 2374140 Fix Begins
-- ------------------------------------------------------------------------
-- |------------------ < check_mid_pay_period_change > --------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if a mid pay period change was performed when a salary basis
--  was changed.  If yes, we need to set the WF item attribute
--  HR_MID_PAY_PERIOD_CHANGE ='Y' so that a notification will be sent to the
--  Payroll Contact.
--
--  This procedure is invoked by the WF HR_CHK_SAL_BASIS_MID_PAY_PERIOD process.
--
-- ------------------------------------------------------------------------
procedure check_mid_pay_period_change
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_act_id       in number,
              funmode        in varchar2,
              result         out nocopy varchar2 ) IS


l_proc varchar2(200) := g_package || 'check_mid_pay_period_change';
l_assignment_id     per_all_assignments_f.assignment_id%type default null;
l_payroll_id        per_all_assignments_f.payroll_id%type default null;
l_old_pay_basis_id  per_all_assignments_f.pay_basis_id%type default null;
l_new_pay_basis_id  per_all_assignments_f.pay_basis_id%type default null;
l_pay_period_start_date    date default null;
l_pay_period_end_date      date default null;

l_asg_txn_step_id          hr_api_transaction_steps.transaction_step_id%type
                           default null;
l_effective_date           date default null;


CURSOR csr_check_mid_pay_period(p_eff_date_csr   in date
                                 ,p_payroll_id_csr in number) IS
select start_date, end_date
from   per_time_periods
where  p_eff_date_csr > start_date
and    p_eff_date_csr <= end_date
and    payroll_id = p_payroll_id_csr;

-- The following cursor is copied from hr_transaction_ss.process_transaction.
CURSOR csr_trs is
select trs.transaction_step_id
      ,trs.api_name
      ,trs.item_type
      ,trs.item_key
      ,trs.activity_id
      ,trs.creator_person_id
from   hr_api_transaction_steps trs
where  trs.item_type = p_item_type
and    trs.item_key = p_item_key
order by trs.processing_order
            ,trs.transaction_step_id ; --#2313279
--

-- Get existing assignment data
CURSOR csr_get_old_asg_data IS
SELECT pay_basis_id
FROM   per_all_assignments_f
WHERE  assignment_id = l_assignment_id
AND    l_effective_date between effective_start_date
                            and effective_end_date
AND    assignment_type = 'E';


BEGIN
  hr_utility.set_location(' Entering:' || l_proc,5);
  IF ( funmode = 'RUN' )
  THEN
     hr_utility.set_location(l_proc,10);
     -- Get the ASG and Pay Rate transaction step id
     FOR I in  csr_trs
     LOOP
        IF I.api_name = g_asg_api_name
        THEN
           l_asg_txn_step_id := I.transaction_step_id;
           EXIT;
        END IF;
     END LOOP;

     IF l_asg_txn_step_id IS NOT NULL
     THEN
        hr_utility.set_location(l_proc,15);
        l_effective_date := to_date(
        hr_transaction_ss.get_wf_effective_date
          (p_transaction_step_id => l_asg_txn_step_id),
                        hr_transaction_ss.g_date_format);

        -- Get the pay_basis_id and payroll_id
        l_new_pay_basis_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_PAY_BASIS_ID');

        l_payroll_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_PAYROLL_ID');

        l_assignment_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_ASSIGNMENT_ID');

        -- Now get the old pay basis id
        OPEN csr_get_old_asg_data;
        FETCH csr_get_old_asg_data into l_old_pay_basis_id;
        IF csr_get_old_asg_data%NOTFOUND
        THEN
	   hr_utility.set_location(l_proc,20);
           -- could be a new hire or applicant hire, there is no asg rec
           CLOSE csr_get_old_asg_data;
        ELSE
           CLOSE csr_get_old_asg_data;
        END IF;

        IF l_old_pay_basis_id IS NOT NULL and
           l_new_pay_basis_id IS NOT NULL and
           l_old_pay_basis_id <> l_new_pay_basis_id and
           l_payroll_id IS NOT NULL
        THEN
	   hr_utility.set_location(l_proc,25);
           -- perform mid pay period check
           OPEN csr_check_mid_pay_period
              (p_eff_date_csr   => l_effective_date
              ,p_payroll_id_csr => l_payroll_id);
           FETCH csr_check_mid_pay_period into l_pay_period_start_date
                                             ,l_pay_period_end_date;
           IF csr_check_mid_pay_period%NOTFOUND
           THEN
	      hr_utility.set_location(l_proc,30);
              -- That means the effective date is not in mid pay period
              CLOSE csr_check_mid_pay_period;
              -- Need to set the item attribute to 'N' because this may be
              -- a Return For Correction and the value of the item attribute
              -- was set to 'Y' previously.
              wf_engine.setItemAttrText
                  (itemtype => p_item_type
                  ,itemkey  => p_item_key
                  ,aname    => g_mid_pay_period_change
                  ,avalue   => 'N');
           ELSE
	      hr_utility.set_location(l_proc,35);
              -- Only set the WF Item attribute HR_MID_PAY_PERIOD_CHANGE to
              -- 'Y' when there is payroll installed and the employee is not a
              -- new hire (ie. first time salary basis was entered).
              -- We determine New Hire by looking at the old db assignment rec
              -- pay_basis_id.  If that is null, then this is the first time
              -- salary basis was entered.  We don't need to perform the check
              -- because there is no element type changed.
              CLOSE csr_check_mid_pay_period;
              wf_engine.setItemAttrText
                  (itemtype => p_item_type
                  ,itemkey  => p_item_key
                  ,aname    => g_mid_pay_period_change
                  ,avalue   => 'Y');

              result := 'COMPLETE:'||'Y';

           END IF;
        END IF;
     ELSE
        hr_utility.set_location(l_proc,40);
        result := 'COMPLETE:'||'N';
     END IF;   -- asg txn step is not null
  ELSIF ( funmode = 'CANCEL' ) then
     hr_utility.set_location(l_proc,45);
     --
     NULL;
     --
  END IF;

hr_utility.set_location(' Leaving:' || l_proc,50);
END check_mid_pay_period_change;

-- 05/14/2002 - Bug 2374140 Fix Ends

 /*-----------------------------------------------------------
 -- This function calculates and returns quartile value for a pay
 -- rate
 --------------------------------------------------------------*/
   FUNCTION get_quartile (
     p_annual_salary NUMBER ,
     p_grade_min     NUMBER ,
     p_grade_max     NUMBER ,
     p_grade_mid     NUMBER )
  RETURN NUMBER
  IS

    l_proc varchar2(200) := g_package || 'get_quartile';
    ln_quartile NUMBER ;
    ln_grade_dif NUMBER ;

  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    IF p_grade_min IS NULL OR
       p_grade_max IS NULL OR
       p_grade_mid IS NULL
    THEN
      hr_utility.set_location(' Leaving:' || l_proc,10);
      return NULL ;
    END IF ;

    ln_grade_dif := p_grade_max- p_grade_min ;


    IF p_annual_salary < ( p_grade_min + ln_grade_dif/4)
    THEN
      hr_utility.set_location(l_proc,15);
      ln_quartile := 1 ;
    ELSIF p_annual_salary < ( p_grade_min + ln_grade_dif/2 )
    THEN
      hr_utility.set_location(l_proc,20);
      ln_quartile := 2 ;
    ELSIF p_annual_salary < ( p_grade_min + (ln_grade_dif * 3/4))
    THEN
      hr_utility.set_location(l_proc,25);
      ln_quartile := 3;

    ELSIF  p_annual_salary < p_grade_max
    THEN
      hr_utility.set_location(l_proc,30);
      ln_quartile := 4 ;
    ELSE
      hr_utility.set_location(l_proc,35);
      ln_quartile := NULL ;
    END IF ;

    hr_utility.set_location(' Leaving:' || l_proc,40);
    return ln_quartile ;

  END get_quartile;


FUNCTION get_quotient(p_divider integer,
                      p_divisor integer) return integer is

 l_proc varchar2(200) := g_package || 'get_quotient';
 i integer := 1;
 diff integer;
 cnt integer := 20;
BEGIN
      hr_utility.set_location(' Entering:' || l_proc,5);
      if (p_divisor = p_divider) then
       hr_utility.set_location(' Leaving:' || l_proc,10);
        return 1;
      end if;
      diff := p_divisor;
      loop
         diff := diff - p_divider;
         if(diff < p_divider) then
          exit;
         end if;
         i := i + 1;
	 -- put a limit of 20 times .. incase we get into infinite loop
	 if(i = cnt) then
	  exit;
	 end if;
      end loop;
      hr_utility.set_location(' Leaving:' || l_proc,15);
      return i;
END;

FUNCTION format_number(p_number number,
                       p_precision number) return varchar2 is

l_proc varchar2(200) := g_package || 'format_number';

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,5);
  IF (fnd_profile.value('CURRENCY:THOUSANDS_SEPARATOR') = 'Y' AND
      p_number is not null) THEN

    declare
      p_input varchar2(200);
      p_decimalSep   CHAR(1);
      p_groupSep     CHAR(1);
      p_afDec        VARCHAR2(80);
      p_wNum         VARCHAR2(80);
      p_len          INTEGER;
      p_times        INTEGER;
      p_prc_len      INTEGER;
      i              INTEGER;
      p_rem          NUMBER;
      p_quo          NUMBER;
      p_bf           VARCHAR2(80);
      p_af           VARCHAR2(80);
      p_indx         NUMBER;
      p_negative     BOOLEAN := false;
    begin
      hr_utility.set_location( l_proc,10);
      p_input := to_char(p_number);
      -- check if we have negative number
      IF (substr(p_input, 1, 1) = '-') THEN
         hr_utility.set_location( l_proc,15);
         p_negative := true;
	 p_input := substr(p_input, 2, length(p_input));
      END IF;
      p_decimalSep   := substr(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),1,1);
      p_groupSep := substr(fnd_profile.value('ICX_NUMERIC_CHARACTERS'),2,1);
      if(p_decimalSep = ',') then
         hr_utility.set_location( l_proc,20);
         p_input := replace(p_input,p_decimalSep,p_groupSep);
      end if;
      if(instr(p_input, '.') = 0) then
        hr_utility.set_location( l_proc,25);
        p_afDec := '.0';
        p_wNum := p_input;
      else
        hr_utility.set_location( l_proc,30);
        p_afDec  := substr(p_input, instr(p_input, '.'));
        p_wNum   := substr(p_input, 1, (length(p_input) - length(p_afDec)));
      end if;
      p_len    := length(p_wNum);
      p_times  := 0;
      p_rem    := MOD(p_len, 3);
      if(p_len is null) then
         hr_utility.set_location( l_proc,35);
         p_quo := 0;
      else
         hr_utility.set_location( l_proc,40);
         p_quo    := get_quotient(3, p_len);
      end if;
      p_bf     := null;
      p_af     := null;
      p_indx   := 3;

      IF (p_quo > 1 AND p_rem = 0) THEN
         hr_utility.set_location( l_proc,45);
         p_times := p_quo - 1;
      ELSE
         IF (p_quo <> 1 OR p_len > 3) THEN
	   hr_utility.set_location( l_proc,50);
            p_times := p_quo;
         END IF;
      END IF;

      FOR i in 1..p_times LOOP
         p_bf   := substr(p_wNum, 1, (p_len - p_indx));
         p_af   := substr(p_wNum, length(p_bf)+ 1);
         p_wNum := p_bf || p_groupSep || p_af;
         p_indx := p_indx + 3;
      END LOOP;

      if(p_decimalSep = ',') then
         hr_utility.set_location( l_proc,55);
         p_afDec := replace(p_afDec,'.',p_decimalSep);
      end if;
      -- append zeroes equal to precision length
      p_prc_len := length(p_afDec);
      for i IN 0.. p_precision - p_prc_len
      loop
         p_afDec := p_afDec || '0';
      end loop;
      -- if negative, then append it back
      if(p_negative) then
         hr_utility.set_location( l_proc,60);
         p_wNum := '-'||p_wNum;
      end if;
      hr_utility.set_location(' Leaving:' || l_proc,65);
      return (p_wNum || p_afDec);
    END;
  END IF;
  hr_utility.set_location(' Leaving:' || l_proc,70);
  return to_char(p_number);
END;


FUNCTION  get_last_pay_change (
  p_assignment_id NUMBER ,
  p_bus_group_id  NUMBER ,
  p_precision     NUMBER,
  p_percent       OUT NOCOPY VARCHAR2) return VARCHAR2 IS

  l_proc varchar2(200) := g_package || 'get_last_pay_change';
  ln_last_pay1  NUMBER ;
  ln_last_pay2  NUMBER ;

  CURSOR c_last_pay IS
    Select pp.proposed_salary_n*pay_annualization_factor
    From per_pay_proposals pp, per_assignments_f paf,
         per_pay_bases ppb
    Where pp.assignment_id = p_assignment_id
    And pp.business_group_id = p_bus_group_id
    And pp.approved = 'Y'
    And pp.assignment_id = paf.assignment_id
    And trunc(pp.change_date) between paf.effective_start_date and paf.effective_end_date
    And paf.pay_basis_id = ppb.pay_basis_id
    Order By change_date desc;

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,5);
  OPEN c_last_pay ;
  FETCH c_last_pay INTO ln_last_pay1;
  FETCH c_last_pay INTO ln_last_pay2 ;
  IF c_last_pay%NOTFOUND
  THEN
    CLOSE c_last_pay ;
    hr_utility.set_location(' Leaving:' || l_proc,10);
    return NULL ;
  END IF ;
  CLOSE c_last_pay ;

  if not ln_last_pay2 = 0 then
    hr_utility.set_location(l_proc,15);
    p_percent := format_number(round(((ln_last_pay1-ln_last_pay2)/ln_last_pay2)*100,p_precision), p_precision);
  end if;

  hr_utility.set_location(' Leaving:' || l_proc,20);
  return format_number(round((ln_last_pay1-ln_last_pay2), p_precision), p_precision);

  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,555);
    raise;

END ;




  FUNCTION get_flsa_status (
    p_assignment_id NUMBER ,
    p_bus_group_id  NUMBER ,
    p_date     DATE ,
    p_job_id   NUMBER) return VARCHAR2
  IS

  l_proc varchar2(200) := g_package || 'get_flsa_status';

  CURSOR lc_flsa_status IS
  SELECT  job_information3
  FROM per_jobs jobs , per_assignments_f asg
  WHERE jobs.job_id = asg.job_id
--  AND   jobs.business_group_id = asg.business_group_id
  -- Fix 2094081
  AND p_date between asg.effective_start_date and asg.effective_end_date
  -- End Fix 2094081
  AND   asg.assignment_id = p_assignment_id
  AND   asg.business_group_id = p_bus_group_id ;

  CURSOR lc_txn_flsa_status IS
  SELECT  job_information3
  FROM per_jobs jobs
  WHERE jobs.job_id = p_job_id
  AND   jobs.business_group_id = p_bus_group_id ;

  lv_flsa_status VARCHAR2(150);
  lv_flsa_meaning VARCHAr2(80);

  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    IF( p_job_id is not null) THEN
        hr_utility.set_location( l_proc,10);
        OPEN lc_txn_flsa_status ;
        FETCH lc_txn_flsa_status into lv_flsa_status ;
        IF lc_txn_flsa_status%NOTFOUND THEN
          CLOSE lc_txn_flsa_status;
        hr_utility.set_location(' Leaving:' || l_proc,15);
        return NULL ;
        END IF;
        CLOSE lc_txn_flsa_status;
    ELSE
        hr_utility.set_location( l_proc,20);
        OPEN lc_flsa_status ;
        FETCH lc_flsa_status into lv_flsa_status ;
        IF lc_flsa_status%NOTFOUND THEN
          CLOSE lc_flsa_status;
	  hr_utility.set_location(' Leaving:' || l_proc,25);
        return NULL ;
        END IF;
        CLOSE lc_flsa_status;
    END IF ;

    lv_flsa_meaning := hr_misc_web.get_lookup_meaning (
      lv_flsa_status ,
      'US_EXEMPT_NON_EXEMPT',
      p_date);
hr_utility.set_location(' Leaving:' || l_proc,30);
    return lv_flsa_meaning ;
  END get_flsa_status;

      /* ======================================================================
    || Function: get_precision
    ||----------------------------------------------------------------------
    || Description: Gets precisions for a given currency
    ||
    ||
    || Pre Conditions: a valid currency code
    ||
    ||
    || In Parameters: p_uom
    ||                p_currency_code
    ||                p_date
    ||
    ||
    || out nocopy Parameters:
    ||
    ||
    || In out nocopy Parameters:
    ||
    ||
    || Post Success:
    ||
    ||     returns precision
    ||
    || Post Failure:
    ||     Raises Error
    ||
    || Access Status:
    ||     Public.
    ||
    ||=================================================================== */



   FUNCTION  get_precision(
     p_uom           VARCHAR2 ,
     p_currency_code VARCHAR2 ,
     p_date          DATE ) RETURN  NUMBER
   IS

   l_proc varchar2(200) := g_package || 'get_precision';
     CURSOR c_precision IS
     SELECT CUR.PRECISION
     FROM FND_CURRENCIES_VL CUR
     WHERE CUR.CURRENCY_CODE=p_currency_code
     AND p_date BETWEEN
      NVL(CUR.START_DATE_ACTIVE,p_date) AND
      NVL(CUR.END_DATE_ACTIVE,p_date+1);

     ln_precision NUMBER ;

   BEGIN
     hr_utility.set_location(' Entering:' || l_proc,5);
     IF p_uom = 'N'
     THEN
       hr_utility.set_location(l_proc,10);
       ln_precision:= 5 ;
     ELSE
       hr_utility.set_location(l_proc,15);
       OPEN c_precision ;
       FETCH c_precision into ln_precision ;
       CLOSE c_precision ;

     END IF ;
     hr_utility.set_location(' Leaving:' || l_proc,20);
     return ln_precision ;
   EXCEPTION
   WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,25);
    raise;
   END get_precision ;

/*===============================================================
 | Procedure: check_gsp_txn
 | Function: This is called from process_api to check
 | whether current txn is gsp txn by reading 'p_gsp_dummy_txn_value'
 | parameter value from the hr_api_transaction_values table
 |================================================================
 */
PROCEDURE check_gsp_txn
       (p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%type
                ,p_effective_date in varchar2
                ,p_gsp_assignment out nocopy varchar2
                )
IS

l_proc varchar2(200) := g_package || 'check_gsp_txn';
begin
    hr_utility.set_location(' Entering:' || l_proc,5);
    p_gsp_assignment := null; -- default value
    IF p_transaction_step_id IS NOT NULL
      THEN
          hr_utility.set_location(l_proc,10);
          p_gsp_assignment :=
          hr_transaction_api.get_varchar2_value
                           (p_transaction_step_id => p_transaction_step_id,
                            p_name =>'p_gsp_dummy_txn');
     END IF;
     hr_utility.set_location(' Leaving:' || l_proc,15);
end check_gsp_txn;


 /*===============================================================
  | Procedure: check_gsp_asg_txn_data
  | Function: This is a cover routine invoked by Java.
  |
  |================================================================
  */
  PROCEDURE check_gsp_asg_txn_data
             (p_item_type                        in     varchar2
             ,p_item_key                         in     varchar2
             ,p_act_id                           in     number
             ,p_effective_date                   in     date
             ,p_assignment_id                    in     number
             ,p_asg_txn_step_id                  in     number
             ,p_get_defaults_date                in     date
             ,p_excep_message                       out nocopy varchar2
             ,p_flow_mode                        in     varchar2 -- 2355929
          ) IS

  --  lv_grade_ladder_excep      exception;
    l_proc varchar2(200) := g_package || 'check_gsp_asg_txn_data';
    ln_txn_pay_basis_id        number;
    ln_transaction_step_id     number default null;
    ln_transaction_id          number default null;
    lv_msg_text                varchar2(32000) default null;
    l_effective_date  date default null;

    -- cursor to get the grade ladder id from the assignment record
    CURSOR lc_asg_grade_ladder_id IS
    SELECT paf.grade_ladder_pgm_id,paf.assignment_type
    FROM   per_all_assignments_f    paf
    WHERE  assignment_id = p_assignment_id
    and    p_effective_date between effective_start_date
                                and effective_end_date;

    -- cursor to find whether assigned grade ladder id updates
    -- the salary using Grade Step Progression
    CURSOR lc_sal_updateable_grade_ladder
    (p_grade_ladder_id in per_all_assignments_f.grade_ladder_pgm_id%TYPE,
     p_effective_date in date
     ) IS
     select pgm_id  from ben_pgm_f
        where
         -- grade ladder does not allow update of  salary
         (update_salary_cd <> 'NO_UPDATE' and update_salary_cd is not null)
         -- salary updated by the  progression system should not be manually overidden
         --and  (gsp_allow_override_flag is null or gsp_allow_override_flag = 'N')
         and
         pgm_id = p_grade_ladder_id
         and    p_effective_date between effective_start_date
                                and effective_end_date;



  -- Bug 2355929 Fix Begins
       lv_applicant_asg_type   PER_ALL_ASSIGNMENTS_F.assignment_type%TYPE
                           default null;
  -- Bug 2355929 Fix Ends
  --ln_job_id    number default null;
  -- GSP
  lc_temp_grade_ladder_id PER_ALL_ASSIGNMENTS_F.grade_ladder_pgm_id%TYPE default null;
  p_old_grade_ladder_id PER_ALL_ASSIGNMENTS_F.grade_ladder_pgm_id%TYPE default null;
  p_new_grade_ladder_id PER_ALL_ASSIGNMENTS_F.grade_ladder_pgm_id%TYPE default null;
  ln_txn_grade_ladder_id PER_ALL_ASSIGNMENTS_F.grade_ladder_pgm_id%TYPE default null;

BEGIN

 hr_utility.set_location(' Entering:' || l_proc,5);
 lv_msg_text := '';
 lv_msg_text := lv_msg_text ||
         hr_util_misc_web.return_msg_text(
                     p_message_name =>'HR_PAY_RATE_GSP_NO_UPD'
                     ,p_Application_id  =>'PER');

  -- Read from the database to determine if there is an existing
  -- assignment and also grade ladder assignment.
  IF p_flow_mode IS NOT NULL and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  THEN
     hr_utility.set_location(l_proc,10);
     NULL;
  ELSE
     hr_utility.set_location(l_proc,15);
     OPEN lc_asg_grade_ladder_id;
     FETCH lc_asg_grade_ladder_id into p_old_grade_ladder_id,lv_applicant_asg_type;
     CLOSE lc_asg_grade_ladder_id;
  END IF;
  -- GSP won't support for CWK
  IF lv_applicant_asg_type = 'C'
  THEN
     hr_utility.set_location(' Leaving:' || l_proc,20);
     return;
  END IF;

  IF lv_applicant_asg_type = 'A'
  THEN
     hr_utility.set_location(l_proc,25);
     -- zap the p_old_grade_ladder_pgm_id
     p_old_grade_ladder_id := null;
     --p_flow_mode := hr_process_assignment_ss.g_hire_an_applicant;
  END IF;

  IF p_asg_txn_step_id IS NOT NULL
  THEN
     hr_utility.set_location(l_proc,30);
     -- In a chained process navigated from the Assignment page.
     -- Get the grade_ladder_id from the txn step
     ln_transaction_step_id := p_asg_txn_step_id;
     ln_txn_grade_ladder_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_GRADE_LADDER_PGM_ID');

     p_new_grade_ladder_id := ln_txn_grade_ladder_id;
     -- check whether grade ladder won't allow salary update
     open lc_sal_updateable_grade_ladder(p_grade_ladder_id => p_new_grade_ladder_id,
                      p_effective_date => p_effective_date);
     fetch lc_sal_updateable_grade_ladder into lc_temp_grade_ladder_id;
     if (lc_sal_updateable_grade_ladder%FOUND) THEN
        -- set exception message
        -- it's an error, we cannot proceed further
         p_excep_message := lv_msg_text;
      END IF;

  ELSE
     hr_utility.set_location(l_proc,35);
     -- 2 possibilities:
     --  1) On re-entry of a Save For Later transaction where the user last
     --     stopped at the Pay Rate page, asg_txn_step_id is not known now
     --    OR
     --  2) In Pay Rate standalone mode, thus there is no asg_txn_step_id.
     --
     -- Need to see if an asg txn step id exists or not.
     hr_assignment_common_save_web.get_step
       (p_item_type           => p_item_type
       ,p_item_key            => p_item_key
       ,p_api_name            => g_asg_api_name
       ,p_transaction_step_id => ln_transaction_step_id
       ,p_transaction_id      => ln_transaction_id);

     IF nvl(ln_transaction_step_id, -1) > 0
     THEN
        hr_utility.set_location(l_proc,40);
        -- It's a Save For Later transaction, Pay Rate was being chained
        -- to the Assignment page but user last stopped at the Pay Rate
        -- page.
        -- Get the grade_ladder_id from the txn step
        -- p_asg_txn_step_id := ln_transaction_step_id;
        ln_txn_grade_ladder_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_GRADE_LADDER_PGM_ID');
        p_new_grade_ladder_id := ln_txn_grade_ladder_id;

        -- check whether grade ladder won't allow salary update
        open lc_sal_updateable_grade_ladder( p_grade_ladder_id => p_new_grade_ladder_id,
                       p_effective_date => p_effective_date);
        fetch lc_sal_updateable_grade_ladder into lc_temp_grade_ladder_id;
        if (lc_sal_updateable_grade_ladder%FOUND) THEN
	   hr_utility.set_location(l_proc,45);
           -- set exception message
           -- it's an error, we cannot proceed further
           p_excep_message := lv_msg_text;
        END IF;

     ELSE
        hr_utility.set_location(l_proc,50);
        -- There is no passed ASG transaction step id and
        -- It's Pay Rate standalone.
        IF p_old_grade_ladder_id IS NOT NULL
        THEN
	        hr_utility.set_location(l_proc,55);
                -- check whether grade ladder won't allow salary update
                open lc_sal_updateable_grade_ladder(p_grade_ladder_id => p_old_grade_ladder_id,
                    p_effective_date => p_effective_date);
                fetch lc_sal_updateable_grade_ladder into lc_temp_grade_ladder_id;
                if (lc_sal_updateable_grade_ladder%FOUND) THEN
                   -- set exception message
                   -- it's an error, we cannot proceed further
                   p_excep_message := lv_msg_text;
                END IF;

        END IF; -- p_old_grade_ladder_pgm_id is not null
     END IF;
  END IF; -- end p_asg_txn_step_id is NOT null

hr_utility.set_location(' Leaving:' || l_proc,60);
  EXCEPTION
   -- WHEN lv_grade_ladder_excep THEN

         -- The Java caller PayRateAMImpl.java will throw the exception.
    --     null;

    WHEN OTHERS THEN
       hr_utility.set_location(' Leaving:' || l_proc,560);
       RAISE;

 END check_gsp_asg_txn_data;

-- End of GSP changes

  /*===============================================================
  | Procedure: check_asg_txn_data
  | Function: This is a cover routine invoked by Java.
  |
  |================================================================
  */
  PROCEDURE check_asg_txn_data
             (p_item_type                        in     varchar2
             ,p_item_key                         in     varchar2
             ,p_act_id                           in     number
             ,p_effective_date                   in     date
             ,p_assignment_id                    in     number
             ,p_asg_txn_step_id                  in out nocopy number
             ,p_get_defaults_date                in out nocopy date
             ,p_business_group_id                   out nocopy number
             ,p_currency                            out nocopy varchar2
             ,p_format_string                       out nocopy varchar2
             ,p_salary_basis_name                   out nocopy varchar2
             ,p_pay_basis_name                      out nocopy varchar2
             ,p_pay_basis                           out nocopy varchar2
             ,p_grade_basis                           out nocopy varchar2
             ,p_pay_annualization_factor            out nocopy number
             ,p_fte_factor            		    out nocopy number
             ,p_grade                               out nocopy varchar2
             ,p_grade_annualization_factor          out nocopy number
             ,p_minimum_salary                      out nocopy number
             ,p_maximum_salary                      out nocopy number
             ,p_midpoint_salary                     out nocopy number
             ,p_prev_salary                         out nocopy number
             ,p_last_change_date                    out nocopy date
             ,p_element_entry_id                    out nocopy number
             ,p_basis_changed                       out nocopy number
             ,p_uom                                 out nocopy varchar2
             ,p_grade_uom                           out nocopy varchar2
             ,p_change_amount                       out nocopy number
             ,p_change_percent                      out nocopy number
             ,p_quartile                            out nocopy number
             ,p_comparatio                          out nocopy number
             ,p_last_pay_change                     out nocopy varchar2
             ,p_flsa_status                         out nocopy varchar2
             ,p_currency_symbol                     out nocopy varchar2
             ,p_precision                           out nocopy number
             ,p_excep_message                       out nocopy varchar2
             ,p_pay_proposal_id                     out nocopy number
             ,p_current_salary                      out nocopy number
             ,p_proposal_ovn                        out nocopy number
             ,p_api_mode                            out nocopy varchar2
             ,p_warning_message                     out nocopy varchar2
             ,p_new_pay_basis_id                    out nocopy number
             ,p_old_pay_basis_id                    out nocopy number
             ,p_old_pay_annualization_factor        out nocopy number
             ,p_old_fte_factor                      out nocopy number
             ,p_old_salary_basis_name               out nocopy varchar2
             ,p_salary_basis_change_type            out nocopy varchar2
             ,p_flow_mode                           in out nocopy varchar2 -- 2355929
             ,p_element_type_id_changed             out nocopy varchar2
             ,p_old_currency_code                   out nocopy varchar2
             ,p_old_currency_symbol                 out nocopy varchar2
             ,p_old_pay_basis                       out nocopy varchar2 --4002387
             ,p_old_to_new_currency_rate            out nocopy number   --4002387
             ,p_offered_salary 	out nocopy number
             ,p_proc_sel_txn	                   in varchar2 default null
              ) IS

    l_proc varchar2(200) := g_package || 'check_asg_txn_data';
    lv_no_sal_basis_excep      exception;
    ln_percent                 varchar2(300);
    ln_txn_pay_basis_id        number;
    ln_transaction_step_id     number default null;
    ln_transaction_id          number default null;
    lv_msg_text                varchar2(32000) default null;
    ln_business_group_id       per_all_people_f.business_group_id%type
                               default null;
    -- The following defintions were copied from pepaprpo.pkb get_defaults proc
    lv_currency                VARCHAR2(15) default null;
    lv_format_string           VARCHAR2(40) default null;
    lv_salary_basis_name       per_pay_bases.name%type default null;
    lv_pay_basis_name          VARCHAR2(80) default null;
    lv_pay_basis               per_pay_bases.pay_basis%type default null;
    lv_grade_basis               per_pay_bases.rate_basis%type default null;
    lv_pay_annualization_factor per_pay_bases.pay_annualization_factor%type;
    lv_fte_factor 		number;
    lv_grade                   VARCHAR2(240) default null;
    lv_grade_annualization_factor per_pay_bases.grade_annualization_factor%type;
    ln_minimum_salary          number default null;
    ln_maximum_salary          number default null;
    ln_midpoint_salary         number default null;
    ln_prev_salary             number default null;
    ld_last_change_date        date   default null;
    ln_element_entry_id        number default null;
    ln_basis_changed           number default null;
    lv_uom                     VARCHAR2(30) default null;
    lv_grade_uom               VARCHAR2(30) default null;
    ln_change_amount           number default null;
    ln_change_percent          number default null;
    ln_quartile                number default null;
    ln_comparatio              number default null;
    lv_last_pay_change         varchar2(200) default null;
    lv_flsa_status             hr_lookups.meaning%type default null;
    lv_currency_symbol         fnd_currencies.symbol%type default null;
    ln_precision               number default null;
    ln_pay_proposal_id         per_pay_proposals.pay_proposal_id%type ;
    ln_current_salary          number default null;
    ln_proposal_ovn            per_pay_proposals.object_version_number%type;
    lv_api_mode                varchar2(30) default null;
    ld_get_defaults_date       date default null;
    lv_warning_message         varchar2(4000) default '';
    ln_old_pay_annual_factor   number default null;
    ln_old_fte_factor          number default null;
    lv_old_salary_basis_name   per_pay_bases.name%type default null;
    lv_excep_message           varchar2(4000) default null;
    lv_salary_basis_change_type varchar2(30) default 'NEW';
    ln_payroll_id              per_all_assignments_f.payroll_id%type;
    lb_savepoint_exists        boolean default null;
    lb_changed                 boolean default false;

    lv_sal_rev_period_frequency
                      per_all_assignments_f.sal_review_period_frequency%TYPE;
    lv_message                 varchar2(32000) default null;
    ld_temp_date               date default null;
    ln_prev_salary2            number default null;


    CURSOR lc_get_curr_asg_pay_basis_id IS
    SELECT paf.payroll_id
          ,paf.pay_basis_id
          ,paf.business_group_id
          ,paf.assignment_type
          ,ppb.name     old_salary_basis_name
          ,ppb.pay_annualization_factor    old_pay_annual_factor
    FROM   per_all_assignments_f    paf
          ,per_pay_bases            ppb
    WHERE  assignment_id = p_assignment_id
    and    p_effective_date between effective_start_date
                                and effective_end_date
    and    paf.pay_basis_id = ppb.pay_basis_id(+);

  -- 05/11/02 - Bug 2340234 Fix Begins
  -- The following cursor was copied from
  -- per_pay_proposals_populate.get_prev_salary procedure.
  CURSOR lc_previous_pay  IS
  SELECT pro.proposed_salary_n
        ,pro.change_date
  FROM   per_pay_proposals pro
  WHERE  pro.assignment_id = p_assignment_id
  AND    pro.change_date =(select max(pro2.change_date)
                            from per_pay_proposals pro2
                            where pro2.assignment_id = p_assignment_id
                            and pro2.change_date < p_effective_date);
  -- 05/11/02 - Bug 2340234 Fix Begins

   cursor csr_applicant_offer is
   select paf.pay_basis_id,
              paf.assignment_type,
              ppp.proposed_salary_n
   from
   per_all_assignments_f paf,
   per_pay_proposals     ppp
   where paf.assignment_id       = p_assignment_id
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and ppp.assignment_id = paf.assignment_id
    and p_effective_date between ppp.change_date and ppp.date_to;

    p_offered_salary_basis_id	number;
    p_offered_asg_type	varchar2(2);

  -- Bug 2355929 Fix Begins
  lv_applicant_asg_type    per_all_assignments_f.assignment_type%type
                           default null;

  -- Bug 2355929 Fix Ends
  ln_job_id    number default null;

  lv_tmp_currency                   PAY_ELEMENT_TYPES_F.INPUT_CURRENCY_CODE%TYPE;
  lv_tmp_salary_basis_name          PER_PAY_BASES.NAME%TYPE;
  lv_tmp_pay_basis_name             HR_LOOKUPS.MEANING%TYPE;
  lv_tmp_pay_basis                  PER_PAY_BASES.PAY_BASIS%TYPE;
  ln_tmp_pay_annual_factor              PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR%TYPE;
  lv_tmp_grade_basis                    PER_PAY_BASES.RATE_BASIS%TYPE;
  ln_tmp_grade_annual_factor            PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR%TYPE;
  ln_tmp_element_type_id            PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
  lv_tmp_uom                        PAY_INPUT_VALUES_F.UOM%TYPE;
  lv_tmp_currency_symbol            FND_CURRENCIES_VL.SYMBOL%TYPE;


BEGIN

  hr_utility.set_location(' Entering:' || l_proc,5);

  ld_get_defaults_date := p_effective_date;

  -- Read from the database to determine if there is an existing
  -- assignment and also salary basis.
  --
  -- Bug 2355929 Fix Begins
  -- The input parm p_flow_mode will have the following values:
  --  i)  REGISTRATION - hiring a new employee
  --  ii) HrCommonUpdateOab - hiring an applicant or updating an existing
  --                          employee record.
  -- We need to set p_flow_mode to 'APPLICANT_HIRE' so that we will not
  -- call hr_applicant_api.hire_applicant in the ASG process_api when we
  -- are updating an existing employee record.
  -- If the flow mode is registration, don't read from the db.  In a New Hire
  -- process, the Salary Basis added in the ASG page will be in the database.
  -- If we read from the db, the p_old_pay_basis_id will be set and will be the
  -- same as the new pay basis id.  The change type will become NOCHANGE and
  -- validate_salary_details proc will issue the following errors:
  --   i) No previous approved pay proposal exists for this person.
  --  ii) Future dated proposals exist for this assignment.
  --

  IF p_flow_mode IS NOT NULL and
     p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
  THEN
     hr_utility.set_location(l_proc,10);
     NULL;
  ELSE
     hr_utility.set_location(l_proc,15);
     OPEN lc_get_curr_asg_pay_basis_id;
     FETCH lc_get_curr_asg_pay_basis_id into ln_payroll_id
                                         ,p_old_pay_basis_id
                                         ,ln_business_group_id
                                         ,lv_applicant_asg_type
                                         ,lv_old_salary_basis_name
                                         ,ln_old_pay_annual_factor;
     CLOSE lc_get_curr_asg_pay_basis_id;

     ln_old_fte_factor := per_saladmin_utility.get_fte_factor(p_assignment_id,
                                                              p_effective_date);

     PER_PAY_PROPOSALS_POPULATE.GET_BASIS_DETAILS(p_effective_date   =>   p_effective_date
                             ,p_assignment_id   => p_assignment_id
                             ,p_currency    => lv_tmp_currency
                             ,p_salary_basis_name =>  lv_tmp_salary_basis_name
                             ,p_pay_basis_name =>   lv_tmp_pay_basis_name
                             ,p_pay_basis  =>  lv_tmp_pay_basis
                             ,p_pay_annualization_factor => ln_tmp_pay_annual_factor
                             ,p_grade_basis         => lv_tmp_grade_basis
                             ,p_grade_annualization_factor => ln_tmp_grade_annual_factor
                             ,p_element_type_id        => ln_tmp_element_type_id
                             ,p_uom                   => lv_tmp_uom);

     lv_tmp_currency_symbol:= hr_salary2_web.get_currency_symbol(
                              lv_tmp_currency,
                              p_effective_date  ) ;

     p_old_currency_code :=      lv_tmp_currency;
     p_old_currency_symbol :=   lv_tmp_currency_symbol;

  END IF;

  IF lv_applicant_asg_type = 'A'
  THEN
     hr_utility.set_location(l_proc,20);
     -- zap the ln_payroll_id, lv_old_salary_basis_name and
     -- ln_old_pay_annual_factor to null
     -- Change the p_flow_mode to reflect APPLICANT_HIRE
     ln_payroll_id := null;
     p_old_pay_basis_id := null;
     lv_old_salary_basis_name := null;
     ln_old_pay_annual_factor := null;
     ln_old_fte_factor := null;
     p_flow_mode := hr_process_assignment_ss.g_hire_an_applicant;
  END IF;

  -- Bug 2355929 Fix Ends

  IF p_asg_txn_step_id IS NOT NULL
  THEN
     hr_utility.set_location(l_proc,25);
     -- In a chained process navigated from the Assignment page.
     -- Get the pay_basis_id from the txn step
     ln_transaction_step_id := p_asg_txn_step_id;
     ln_txn_pay_basis_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_PAY_BASIS_ID');
     p_new_pay_basis_id := ln_txn_pay_basis_id;

     ln_payroll_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_PAYROLL_ID');

     lv_sal_rev_period_frequency := hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_SAL_REVIEW_PERIOD_FREQUENCY');

     ln_job_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_JOB_ID');

     -- 05/03/2002 Fix Begins
     -- Issue an error when the old and new pay basis id are null regardless
     -- it's a New Hire or Applicant Hire.
     IF p_old_pay_basis_id IS NULL and p_new_pay_basis_id IS NULL
     THEN
        hr_utility.set_location(l_proc,30);
        -- it's an error, we cannot proceed further
           lv_msg_text := lv_msg_text ||
                          hr_util_misc_web.return_msg_text(
                            p_message_name =>'HR_289855_SAL_ASS_NOT_SAL_ELIG'
                           ,p_Application_id  =>'PER');
           p_excep_message := lv_msg_text;
           raise lv_no_sal_basis_excep;
     END IF;
     -- 05/03/2002 Fix Ends
  ELSE
     hr_utility.set_location(l_proc,35);
     -- 2 possibilities:
     --  1) On re-entry of a Save For Later transaction where the user last
     --     stopped at the Pay Rate page, asg_txn_step_id is not known now
     --    OR
     --  2) In Pay Rate standalone mode, thus there is no asg_txn_step_id.
     --
     -- Need to see if an asg txn step id exists or not.
     hr_assignment_common_save_web.get_step
       (p_item_type           => p_item_type
       ,p_item_key            => p_item_key
       ,p_api_name            => g_asg_api_name
       ,p_transaction_step_id => ln_transaction_step_id
       ,p_transaction_id      => ln_transaction_id);

     IF nvl(ln_transaction_step_id, -1) > 0
     THEN
        hr_utility.set_location(l_proc,40);
        -- It's a Save For Later transaction, Pay Rate was being chained
        -- to the Assignment page but user last stopped at the Pay Rate
        -- page.
        -- Get the value of pay basis id from the txn table.
        p_asg_txn_step_id := ln_transaction_step_id;

        ln_txn_pay_basis_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_PAY_BASIS_ID');

        ln_payroll_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_PAYROLL_ID');

        p_new_pay_basis_id := ln_txn_pay_basis_id;

        lv_sal_rev_period_frequency := hr_transaction_api.get_varchar2_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_SAL_REVIEW_PERIOD_FREQUENCY');


        ln_job_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_JOB_ID');

        -- 05/03/2002 Fix Begins
        -- Issue an error when the old and new pay basis id are null regardless
        -- it's a New Hire or Applicant Hire.
        IF p_old_pay_basis_id IS NULL and p_new_pay_basis_id IS NULL
        THEN
	   hr_utility.set_location(l_proc,45);
           -- it's an error, we cannot proceed further
              lv_msg_text := lv_msg_text ||
                          hr_util_misc_web.return_msg_text(
                            p_message_name =>'HR_289855_SAL_ASS_NOT_SAL_ELIG'
                           ,p_Application_id  =>'PER');
              p_excep_message := lv_msg_text;
              raise lv_no_sal_basis_excep;
        END IF;
        -- 05/03/2002 Fix Ends
     ELSE
        hr_utility.set_location(l_proc,50);
        -- There is no passed ASG transaction step id and none in
        -- the database.
        -- It's Pay Rate standalone.  Get the pay basis id from the asg
        -- rec in the database.
        -- Set the old and new pay basis id to be the same.
        IF p_old_pay_basis_id IS NULL
        THEN
	   hr_utility.set_location(l_proc,55);
           -- it's an error, we cannot proceed further
           lv_msg_text := lv_msg_text ||
                          hr_util_misc_web.return_msg_text(
                            p_message_name =>'HR_289855_SAL_ASS_NOT_SAL_ELIG'
                           ,p_Application_id  =>'PER');
           p_excep_message := lv_msg_text;
           raise lv_no_sal_basis_excep;
        ELSE
	   hr_utility.set_location(l_proc,60);
           -- p_old_pay_basis_id is already set
           p_new_pay_basis_id := p_old_pay_basis_id;
        END IF;
     END IF;
  END IF; -- end p_asg_txn_step_id is NOT null

  open csr_applicant_offer;
  fetch csr_applicant_offer into p_offered_salary_basis_id,
		p_offered_asg_type, p_offered_salary ;
  close csr_applicant_offer;

   if (p_offered_salary_basis_id <> p_new_pay_basis_id OR p_offered_asg_type <> 'A') then
       p_offered_salary := null;
   end if;

  IF p_new_pay_basis_id IS NOT NULL and
     nvl(p_old_pay_basis_id, -1) <> p_new_pay_basis_id
  THEN
     hr_utility.set_location(l_proc,65);
     IF p_old_pay_basis_id IS NULL
     THEN
        hr_utility.set_location(l_proc,70);
        -- Adding a new salary basis
        lv_salary_basis_change_type := 'NEW';
     ELSE
        hr_utility.set_location(l_proc,75);
        -- Changing an existing salary basis
        lv_salary_basis_change_type := 'CHANGE';
     END IF;
  ELSE
     hr_utility.set_location(l_proc,80);
     IF p_old_pay_basis_id = p_new_pay_basis_id
     THEN
        hr_utility.set_location(l_proc,85);
        -- An existing salary basis is already in the db, the user is trying to
        -- add pay proposal data.
        -- get the default values based on the existing assignment id
        lv_salary_basis_change_type := 'NOCHANGE';
     END IF;
  END IF;

  IF lv_salary_basis_change_type = 'NEW' Or
     lv_salary_basis_change_type = 'CHANGE' Or
     nvl(ln_transaction_step_id, -1) > 0 -- bug# 2343933
  THEN
     hr_utility.set_location(l_proc,90);
     -- that means p_new_pay_basis_id IS NOT NULL and
     -- p_old_pay_basis_id <> p_new_pay_basis_id
     -- We need to simulate saving of the assignment data in the
     -- transaction table to the database because the get_defaults call
     -- only operates on data which is already in the database.
     -- A rollback will remove all simulation of saving ASG data.

     savepoint check_asg_txn_data_save;
     lb_savepoint_exists := TRUE;

     -- Must set the element warning to TRUE so that the ASG wrapper will not
     -- roll back the ASG changes if element_warning = 'TRUE' whenever there
     -- is element entries changed.
     --HR_PROCESS_ASSIGNMENT_SS.PROCESS_API
     --   (p_validate                => FALSE
     --   ,p_transaction_step_id     => ln_transaction_step_id
     --   ,p_flow_mode               => p_flow_mode);   -- 2355929 Fix
     -- Bug 2547283: need to update person info and asg info.
     IF NOT (p_flow_mode IS NOT NULL and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration)
     THEN
       hr_utility.set_location(l_proc,95);
       if p_proc_sel_txn is null then
          hr_new_user_reg_ss.process_selected_transaction
             (p_item_type => p_item_type,
              p_item_key => p_item_key);
        end if;
     END IF;
  END IF;

   -- Call my_get_defaults first because we need to pass the new element entery
   -- to the validate salary procedure.
   my_get_defaults
      (p_assignment_id               => p_assignment_id
      ,p_date                        => ld_get_defaults_date
      ,p_business_group_id           => ln_business_group_id
      ,p_currency                    => lv_currency
      ,p_format_string               => lv_format_string
      ,p_salary_basis_name           => lv_salary_basis_name
      ,p_pay_basis_name              => lv_pay_basis_name
      ,p_pay_basis                   => lv_pay_basis
      ,p_grade_basis                   => lv_grade_basis
      ,p_pay_annualization_factor    => lv_pay_annualization_factor
      ,p_fte_factor    	     => lv_fte_factor
      ,p_grade                       => lv_grade
      ,p_grade_annualization_factor  => lv_grade_annualization_factor
      ,p_minimum_salary              => ln_minimum_salary
      ,p_maximum_salary              => ln_maximum_salary
      ,p_midpoint_salary             => ln_midpoint_salary
      ,p_prev_salary                 => ln_prev_salary
      ,p_last_change_date            => ld_last_change_date
      ,p_element_entry_id            => ln_element_entry_id
      ,p_basis_changed               => ln_basis_changed
      ,p_uom                         => lv_uom
      ,p_grade_uom                   => lv_grade_uom
      ,p_change_amount               => ln_change_amount
      ,p_change_percent              => ln_change_percent
      ,p_quartile                    => ln_quartile
      ,p_comparatio                  => ln_comparatio
      ,p_last_pay_change             => lv_last_pay_change
      ,p_flsa_status                 => lv_flsa_status
      ,p_currency_symbol             => lv_currency_symbol
      ,p_precision                   => ln_precision
      ,p_job_id                      => ln_job_id);

  -- Validate Salary Details first
  validate_salary_details (p_assignment_id    => p_assignment_id
                          ,p_bg_id            => ln_business_group_id
                          ,p_effective_date   => to_char(p_effective_date
                                                        ,'RRRR-MM-DD')
                          ,p_payroll_id       => ln_payroll_id
                          ,p_old_pay_basis_id => p_old_pay_basis_id
                          ,p_new_pay_basis_id => p_new_pay_basis_id
                          ,excep_message      => lv_excep_message
                          ,p_pay_proposal_id  => ln_pay_proposal_id
                          ,p_current_salary   => ln_current_salary
                          ,p_ovn              => ln_proposal_ovn
                          ,p_api_mode         => lv_api_mode
                          ,p_warning_message  => lv_warning_message
	,p_asg_type          => p_offered_asg_type);

  -- 05/09/02 Bug 2367833 Fix Begins
  -- When the lv_salary_basis_change_type = 'NOCHANGE', we need to check that
  -- if there is existence of pay proposal data.  If there is none, we need
  -- to set lv_salary_basis_change_type to 'NOCHANGE_NOPAYPROPOSAL' so that
  -- the Pay Rate page will disable the radio button for Multiple Components
  -- in the Proposed Pay Rate region.
  IF lv_salary_basis_change_type = 'NOCHANGE' and
     ln_pay_proposal_id is NULL
  THEN
     hr_utility.set_location(l_proc,100);
     lv_salary_basis_change_type := 'NOCHANGE_NOPAYPROPOSAL';
  END IF;
  -- 05/09/02 Bug 2367833 Fix Ends

  --4002387 start
  IF lv_salary_basis_change_type = 'CHANGE' and
     ln_pay_proposal_id is NULL
  THEN
     hr_utility.set_location(l_proc,100);
     lv_salary_basis_change_type := 'CHANGE_NOPAYPROPOSAL';
  END IF;
  --4002387 end

  -- Need to simulate the core api per_pyp_bus.derive_next_sal_perf_date
  -- to check the Salary Review Period Frequency when there is an ASG txn
  -- step id exists.  The Salary Review Period Frequency is entered in ASG
  -- page but the ASG api validates against the lookup code only but the
  -- Pay Rate api restricts the lookup code to be only Year, Month, Week and
  -- Day.  The Frequency lookup code also has Quarter Minute and Hour.
  -- When a user select Quarter Minute or Hour in ASG Salary Review Period
  -- Frequency, the user won't get an error in the ASG api but will get the
  -- following error on reentry of the Pay Rate page in a Return for Correction:  --  HR_51258_INVL_FREQ_PERIOD / HR_51258_PYP_INVAL_FREQ_PERIOD.
  -- The per_pyp_bus (pepyprhi.pkb) only checks the sal_review_period_frequency
  -- but not the perf_review_period_frequency.  So, we will just check the
  -- sal_review_period_frequency only.
  BEGIN
     IF lv_sal_rev_period_frequency IS NOT NULL
     THEN
        hr_utility.set_location(l_proc,105);
        -- Check the frequency to see if it is 'Y', 'M', 'W' or 'D'.  I can't
        -- call the function derive_next_sal_perf_date directly because it is
        -- private.
        IF lv_sal_rev_period_frequency = 'Y' OR
           lv_sal_rev_period_frequency = 'M' OR
           lv_sal_rev_period_frequency = 'W' OR
           lv_sal_rev_period_frequency = 'D'
        THEN
           -- it's ok
	   hr_utility.set_location(l_proc,110);
           NULL;
        ELSE
	   hr_utility.set_location(l_proc,115);
           lv_message := hr_util_misc_web.return_msg_text(
                            p_message_name =>'HR_51258_PYP_INVAL_FREQ_PERIOD'
                           ,p_Application_id  =>'PAY');
        END IF;
     END IF;
  END;

  IF lv_message IS NOT NULL
  THEN
     hr_utility.set_location(l_proc,120);
     lv_message := lv_message || '  ';
  END IF;

  p_warning_message := lv_warning_message;
  p_excep_message := lv_message || lv_excep_message;
  --
  -- 04/23/02 Salary Basis Enhancement Change Begins
  IF lv_salary_basis_change_type = 'CHANGE'
  THEN
     hr_utility.set_location(l_proc,125);
     -- If it is a change to a salary basis, we need to derive previous salary
     -- again. This is because in my_get_defaults which calls
     -- per_pay_proposals_populate.get_defaults,  that procedure will set prev
     -- salary to null when the old and new salary basis's element type id is
     -- different.  The Current Pay Rate region will show zero in the Salary
     -- and Annual Equivalent columns.
     -- This zapping of prev salary to null happens in
     -- per_pay_proposals_populate.get_prev_salary procedure.

     OPEN lc_previous_pay;
     FETCH lc_previous_pay into ln_prev_salary2
                               ,ld_last_change_date;
     CLOSE lc_previous_pay;

     IF ln_prev_salary is NULL and ln_prev_salary2 IS NOT NULL
     THEN
        hr_utility.set_location(l_proc,130);
        -- Element type id is changed because in the procedure
        -- per_pay_proposals_populate.get_prev_salary, it will zap the
        -- previous salary to null if element type id are not equal between
        -- the old and new salary basis.
        p_element_type_id_changed := 'Y';
        ln_prev_salary := ln_prev_salary2;
     ELSE
        hr_utility.set_location(l_proc,135);
        p_element_type_id_changed := 'N';
     END IF;
  END IF;

  --4002387 start
  BEGIN
    SELECT pay_basis INTO p_old_pay_basis
      FROM per_pay_bases
     WHERE pay_basis_id = p_old_pay_basis_id;
  EXCEPTION
    WHEN OTHERS THEN
     p_old_pay_basis := '';
  END;

  p_old_to_new_currency_rate := hr_currency_pkg.get_rate_sql(
                                    p_from_currency   => lv_tmp_currency,
                                    p_to_currency     => lv_currency,
                                    p_conversion_date => p_effective_date,
                                    p_rate_type       => hr_currency_pkg.get_rate_type (
                                                         p_business_group_id => ln_business_group_id,
                                                         p_conversion_date   => p_effective_date,
                                                         p_processing_type   => 'P'));

  --4002387 end

  IF lb_savepoint_exists
  THEN
     hr_utility.set_location(l_proc,140);
     rollback to check_asg_txn_data_save;
     lb_savepoint_exists := FALSE;
  END IF;

  p_asg_txn_step_id := ln_transaction_step_id;
  p_get_defaults_date := ld_get_defaults_date;
  p_business_group_id := ln_business_group_id;
  p_currency := lv_currency;
  p_format_string := lv_format_string;
  p_salary_basis_name := lv_salary_basis_name;
  p_pay_basis_name := lv_pay_basis_name;
  p_pay_basis := lv_pay_basis;
  p_grade_basis := lv_grade_basis;
  p_pay_annualization_factor := lv_pay_annualization_factor;
  p_fte_factor := lv_fte_factor;
  p_grade := lv_grade;
  p_grade_annualization_factor := lv_grade_annualization_factor;
  p_minimum_salary := ln_minimum_salary;
  p_maximum_salary := ln_maximum_salary;
  p_midpoint_salary := ln_midpoint_salary;
  p_prev_salary := ln_prev_salary;
  p_last_change_date := ld_last_change_date;
  p_element_entry_id := ln_element_entry_id;
  p_basis_changed := ln_basis_changed;
  p_uom := lv_uom;
  p_grade_uom := lv_grade_uom;
  p_change_amount := ln_change_amount;
  p_change_percent := ln_change_percent;
  p_quartile := ln_quartile;
  p_comparatio := ln_comparatio;
  p_last_pay_change := lv_last_pay_change;
  p_flsa_status := lv_flsa_status;
  p_currency_symbol := lv_currency_symbol;
  p_precision := ln_precision;
  p_pay_proposal_id := ln_pay_proposal_id;
  p_current_salary := ln_current_salary;
  p_proposal_ovn := ln_proposal_ovn;
  p_api_mode := lv_api_mode;
  p_old_pay_annualization_factor := ln_old_pay_annual_factor;
  p_old_fte_factor := ln_old_fte_factor;
  p_old_salary_basis_name := lv_old_salary_basis_name;
  p_salary_basis_change_type := lv_salary_basis_change_type;

hr_utility.set_location(' Leaving:' || l_proc,145);

  EXCEPTION
    WHEN lv_no_sal_basis_excep THEN
         hr_utility.set_location(' Leaving:' || l_proc,555);
         -- The Java caller PayRateAMImpl.java will throw the exception.
         null;

    WHEN OTHERS THEN
       IF lb_savepoint_exists
       THEN
          rollback to check_asg_txn_data_save;
       END IF;
       hr_utility.set_location(' Leaving:' || l_proc,560);
       RAISE;

 END check_asg_txn_data;


 PROCEDURE MY_GET_DEFAULTS(p_assignment_id      IN     NUMBER
                        ,p_job_id             IN NUMBER
                        ,p_date               IN OUT NOCOPY DATE
                        ,p_business_group_id     OUT NOCOPY NUMBER
                        ,p_currency              OUT NOCOPY VARCHAR2
                        ,p_format_string         OUT NOCOPY VARCHAR2
                        ,p_salary_basis_name     OUT NOCOPY VARCHAR2
                        ,p_pay_basis_name        OUT NOCOPY VARCHAR2
                        ,p_pay_basis             OUT NOCOPY VARCHAR2
                        ,p_grade_basis             OUT NOCOPY VARCHAR2
                        ,p_pay_annualization_factor OUT NOCOPY NUMBER
                        ,p_fte_factor 		 OUT NOCOPY NUMBER
                        ,p_grade                 OUT NOCOPY VARCHAR2
                        ,p_grade_annualization_factor OUT NOCOPY NUMBER
                        ,p_minimum_salary        OUT NOCOPY NUMBER
                        ,p_maximum_salary        OUT NOCOPY NUMBER
                        ,p_midpoint_salary       OUT NOCOPY NUMBER
                        ,p_prev_salary           OUT NOCOPY NUMBER
                        ,p_last_change_date      OUT NOCOPY DATE
                        ,p_element_entry_id      OUT NOCOPY NUMBER
                        ,p_basis_changed         OUT NOCOPY NUMBER
                        ,p_uom                   OUT NOCOPY VARCHAR2
                        ,p_grade_uom             OUT NOCOPY VARCHAR2
                        ,p_change_amount                out nocopy number
                        ,p_change_percent               out nocopy number
                        , p_quartile                     out nocopy number
                        , p_comparatio                   out nocopy number
                        , p_last_pay_change              out nocopy varchar2
                        , p_flsa_status                  out nocopy varchar2
                        , p_currency_symbol              out nocopy varchar2
                        , p_precision                    out nocopy number
                       ) IS

l_proc varchar2(200) := g_package || 'MY_GET_DEFAULTS';
    ln_percent            varchar2(300) ;
    ln_ann_sal		  number;

  cursor grade_basis is
  SELECT ppb.rate_basis
  FROM PER_ALL_ASSIGNMENTS_F PAF, per_pay_bases ppb
  WHERE PAF.ASSIGNMENT_ID=p_assignment_id
  AND p_date BETWEEN PAF.EFFECTIVE_START_DATE AND PAF.EFFECTIVE_END_DATE
  and paf.pay_basis_id = ppb.pay_basis_id;

  cursor grade_details is
    SELECT fnd_number.canonical_to_number(PGR.MINIMUM)
    ,      fnd_number.canonical_to_number(PGR.MAXIMUM)
    ,      fnd_number.canonical_to_number(PGR.MID_VALUE)
    FROM   PER_PAY_BASES PPB
    ,      PAY_GRADE_RULES_F PGR
    ,      PER_ALL_ASSIGNMENTS_F ASG
    WHERE  ASG.ASSIGNMENT_ID=p_assignment_id
    AND    PPB.PAY_BASIS_ID=ASG.PAY_BASIS_ID
    AND    PPB.RATE_ID=PGR.RATE_ID
    AND    ASG.GRADE_ID=PGR.GRADE_OR_SPINAL_POINT_ID
    AND    p_date BETWEEN asg.effective_start_date
                  AND     asg.effective_end_date
    AND    p_date BETWEEN pgr.effective_start_date
                  AND     pgr.effective_end_date;

    BEGIN
    hr_utility.set_location(' Entering:' || l_proc,5);
    per_pay_proposals_populate.get_defaults(
    p_assignment_id      =>   p_assignment_id  ,
    p_date               => p_date,
    p_business_group_id   =>  p_business_group_id,
    p_currency         =>    p_currency,
    p_format_string       =>   p_format_string ,
    p_salary_basis_name     =>  p_salary_basis_name ,
    p_pay_basis_name        =>  p_pay_basis_name ,
    p_pay_basis             =>  p_pay_basis,
    p_pay_annualization_factor =>   p_pay_annualization_factor,
    p_grade                 =>    p_grade,
    p_grade_annualization_factor  =>  p_grade_annualization_factor,
    p_minimum_salary        => p_minimum_salary,
    p_maximum_salary        => p_maximum_salary,
    p_midpoint_salary      =>  p_midpoint_salary,
    p_prev_salary          =>  p_prev_salary ,
    p_last_change_date      =>  p_last_change_date,
    p_element_entry_id      => p_element_entry_id,
    p_basis_changed         => basischanged,
    p_uom                   =>  p_uom,
    p_grade_uom             => p_grade_uom );

    open grade_basis;
    fetch grade_basis into p_grade_basis;
    close grade_basis;

    if (p_grade_basis = 'HOURLY' and p_pay_basis = 'HOURLY') then
      open grade_details;
      fetch grade_details into p_minimum_salary, p_maximum_salary, p_midpoint_salary;
      close grade_details;
    end if;

    p_basis_changed := hr_java_conv_util_ss.get_number(p_boolean => basischanged );

     p_fte_factor := per_saladmin_utility.get_fte_factor(p_assignment_id,p_date);

     if ( p_midpoint_salary = 0) then
        p_comparatio := 0;
    elsif (p_grade_basis = 'HOURLY' and p_pay_basis = 'HOURLY') then
             p_comparatio := round(( (100*p_prev_salary)/p_midpoint_salary), 3 );
     elsif ((fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE') is null OR
               fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE') = 'Y') AND p_pay_basis <> 'HOURLY') then
        p_comparatio := round(( (100*p_prev_salary *p_pay_annualization_factor)/
                            	(p_midpoint_salary*p_fte_factor)), 3 );
     else
        p_comparatio :=round(( (100*p_prev_salary *
                            p_pay_annualization_factor)/
                            p_midpoint_salary), 3 );
      end if;

    if (p_grade_basis = 'HOURLY' and p_pay_basis = 'HOURLY') then
	ln_ann_sal := p_prev_salary;
     elsif ((fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE') is null OR
               fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE') = 'Y') AND p_pay_basis <> 'HOURLY') then
     	ln_ann_sal := (p_prev_salary * p_pay_annualization_factor)/p_fte_factor;
     else
    	ln_ann_sal := p_prev_salary * p_pay_annualization_factor;
     end if;

     p_quartile :=  get_quartile (
        ln_ann_sal,
        p_minimum_salary ,
        p_maximum_salary ,
        p_midpoint_salary );

     p_currency_symbol:= hr_salary2_web.get_currency_symbol(
                              p_currency,
                              p_date  ) ;

     p_precision :=  get_precision(
                        p_uom ,
                        p_currency,
                        p_date  );

     p_last_pay_change := get_last_pay_change (
                             p_assignment_id ,
                             p_business_group_id,
			     p_precision,
                             ln_percent ) ;

     p_last_pay_change := p_last_pay_change || ' (' || ln_percent || '%)';


     p_flsa_status := get_flsa_status
                        ( p_assignment_id ,
                          p_business_group_id ,
                          p_date ,
                          p_job_id ) ;



   hr_utility.set_location(' Leaving:' || l_proc,10);

    EXCEPTION
    WHEN OTHERS THEN
     hr_utility.set_location(' Leaving:' || l_proc,555);
     RAISE;

     END my_get_defaults;

  -------------------------------------------------
  -- Function
  -- get_rate_type
  --
  --
  -- Purpose
  --
  --  Returns the rate type given the business group, effective date and
  --  processing type
  --
  --  Current processing types are:-
  --			              P - Payroll Processing
  --                                  R - General HRMS reporting
  -- 				      I - Business Intelligence System
  --
  -- History
  --  22/01/99	wkerr.uk	Created
  --
  --  Argumnents
  --  p_business_group_id	The business group
  --  p_effective_date		The date for which to return the rate type
  --  p_processing_type		The processing type of which to return the rate
  --
  --  Returns null if no rate type found
  --
  --
  FUNCTION get_rate_type (
		p_business_group_id	NUMBER,
		p_conversion_date	DATE,
		p_processing_type	VARCHAR2 ) RETURN VARCHAR2 IS
--
        l_proc varchar2(200) := g_package || 'get_rate_type';
        l_row_name varchar2(30);
        l_value    pay_user_column_instances_f.value%type;
        l_conversion_type varchar2(30);
  BEGIN
--
        hr_utility.set_location(' Entering:' || l_proc,5);
        if p_processing_type = 'P' then
	   hr_utility.set_location(l_proc,10);
           l_row_name := 'PAY' ;
        elsif p_processing_type = 'R' then
	   hr_utility.set_location(l_proc,15);
           l_row_name := 'HRMS';
        elsif p_processing_type = 'I' then
	   hr_utility.set_location(l_proc,20);
           l_row_name := 'BIS';
        else
	   hr_utility.set_location(' Leaving:' || l_proc,25);
  	   return null;
  	end if;
--
	l_value := hruserdt.get_table_value(p_business_group_id,
                                            'EXCHANGE_RATE_TYPES',
                                            'Conversion Rate Type' ,
					    l_row_name ,
					    p_conversion_date) ;
--
--      l_value is a user_conversion_type
--      we want to return the conversion_type, hence:
--
        select conversion_type
        into l_conversion_type
        from gl_daily_conversion_types
        where user_conversion_type = l_value;
--
        hr_utility.set_location(' Leaving:' || l_proc,30);
        return l_conversion_type;
--
  EXCEPTION
     WHEN OTHERS THEN
        hr_utility.set_location(' Leaving:' || l_proc,555);
	RETURN null;  -- Don't know what the problem was with the user the table.
--                 However don't want to percolate an exception from get_table_value
--                 Request from payroll team for this to be put in.
  END get_rate_type;
  -----------------------------------------------------

--
  --
  -- Function
  --   get_rate
  --
  -- Purpose
  -- 	Returns the rate between the two currencies for a given conversion
  --    date and rate type.
  --
  -- History
  --   22-APR-1998 	wkerr.uk   	Created
  --
  --
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_rate_type		Rate Type
  --
  FUNCTION get_rate (
		p_from_currency		VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_rate_type	        VARCHAR2) RETURN NUMBER IS



  BEGIN

     -- Check if both currencies are identical
     IF ( p_from_currency = p_to_currency ) THEN

	return( 1 );
     END IF;


     RETURN gl_currency_api.get_rate(p_from_currency,
			            p_to_currency,
			            p_conversion_date,
			            p_rate_type) ;

  END get_rate;




-- Function
  --   convert_amount
  --
  -- Purpose
  -- 	Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type.
  --    The amount returned is rounded to the precision and minimum
  --    account unit of the to currency.
  --
  -- History
  --   02-Jun-1998 	wkerr.uk   	Created
  --
  --
  -- Arguments
  --   p_from_currency		From currency
  --   p_to_currency		To currency
  --   p_conversion_date	Conversion date
  --   p_amount			Amount to be converted from the from currency
  -- 				into the to currency
  --   p_rate_type		Rate Type
  --
  FUNCTION convert_amount (
		p_from_currency		VARCHAR2,
		p_to_currency		VARCHAR2,
		p_conversion_date	DATE,
		p_amount		NUMBER,
		p_rate_type		VARCHAR2) RETURN NUMBER IS


  BEGIN

     -- Check if both currencies are identical
     IF ( p_from_currency = p_to_currency ) THEN

	return( p_amount );
     END IF;

     RETURN gl_currency_api.convert_amount(p_from_currency,
					   p_to_currency,
					   p_conversion_date,
					   p_rate_type,
					   p_amount);
  END convert_amount;

-- Start of Procedure start_transaction
Procedure start_transaction(itemtype     in     varchar2
                           ,itemkey      in     varchar2
                           ,actid        in     number
                           ,funmode      in     varchar2
                           ,p_creator_person_id in number
                           ,result         out nocopy  varchar2 ) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc varchar2(200) := g_package || 'start_transaction';
  l_transaction_privilege    hr_api_transactions.transaction_privilege%type;
  l_transaction_id           hr_api_transactions.transaction_id%type;
  l_transaction_step_id      hr_api_transaction_steps.transaction_step_id%type;

--  l_person_id        hr_api_transactions.creator_person_id%type := p_selected_person_id;

Cursor c_get_transaction_step_id
       is
       select
       transaction_step_id
       from
       hr_api_transaction_steps
       where
       transaction_id = l_transaction_id;

Begin
  hr_utility.set_location(' Entering:' || l_proc,5);
  if funmode = 'RUN' then
    hr_utility.set_location( l_proc,10);
    savepoint start_transaction;

    -- check to see if the TRANSACTION_ID attribute has been created
    if hr_workflow_utility.item_attribute_exists(p_item_type => itemtype
                                                ,p_item_key  => itemkey
                                                ,p_name      => 'TRANSACTION_ID') then

      -- the TRANSACTION_ID exists so ensure that it is null

      if hr_transaction_ss.get_transaction_id(p_item_type => itemtype
                                              ,p_item_key  => itemkey) is not null then

        -- a current transaction is in progress we cannot overwrite it
        -- get the Transaction Step Id
	hr_utility.set_location( l_proc,15);
        l_transaction_id := hr_transaction_ss.get_transaction_id(p_item_type => itemtype
                                              ,p_item_key  => itemkey);
        open c_get_transaction_step_id;
        fetch c_get_transaction_step_id into l_transaction_step_id;
        /*if c_get_transaction_step_id%found then
          close c_get_transaction_step_id;
          hr_utility.set_message(801, 'HR_51750_WEB_TRANSAC_STARTED');
          hr_utility.raise_error;
        end if;*/
        close c_get_transaction_step_id;
        hr_transaction_ss.delete_transaction_step(l_transaction_step_id,null,p_creator_person_id);
      end if;

    else
       hr_utility.set_location( l_proc,20);
       -- the TRANSACTION_ID does not exist so create it
      wf_engine.additemattr(itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'TRANSACTION_ID');

    end if;

    -- check to see if the TRANSACTION_PRIVILEGE attribute has been created
    if not hr_workflow_utility.item_attribute_exists(p_item_type => itemtype
                                                    ,p_item_key  => itemkey
                                                    ,p_name      => 'TRANSACTION_PRIVILEGE') then

     -- the TRANSACTION_PRIVILEGE does not exist so create it
     hr_utility.set_location( l_proc,25);
     wf_engine.additemattr(itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'TRANSACTION_PRIVILEGE');
    end if;

    -- get the TRANSACTION_PRIVILEGE
    l_transaction_privilege := wf_engine.getitemattrtext(itemtype => itemtype
                                                        ,itemkey  => itemkey
                                                        ,aname    => 'TRANSACTION_PRIVILEGE');
    -- check to see if the TRANSACTION_PRIVILEGE is null
    if l_transaction_privilege is null then
      hr_utility.set_location( l_proc,30);
      -- default the TRANSACTION_PRIVILEGE to PRIVATE
      l_transaction_privilege := 'PRIVATE';
      wf_engine.setitemattrtext(itemtype => itemtype
                               ,itemkey  => itemkey
                               ,aname    => 'TRANSACTION_PRIVILEGE'
                               ,avalue   => l_transaction_privilege);
    end if;

    -- call the BP API to create the transaction
    hr_transaction_api.create_transaction(p_validate               => false
                                         ,p_creator_person_id      => p_creator_person_id
                                         ,p_transaction_privilege  => l_transaction_privilege
                                         ,p_transaction_id         => l_transaction_id );
    -- set the TRANSACTION_ID
    wf_engine.setitemattrnumber(itemtype => itemtype
                                ,itemkey  => itemkey
                                ,aname    => 'TRANSACTION_ID'
                                ,avalue   => l_transaction_id);

    -- transaction has been successfully created so commit and return success
    -- commit;
    result := 'SUCCESS';

elsif funmode = 'CANCEL' then
    hr_utility.set_location( l_proc,35);
    null;
end if;

hr_utility.set_location(' Leaving:' || l_proc,40);

Exception
  when others then
    rollback to start_transaction;
    hr_utility.set_location(' Leaving:' || l_proc,555);
    raise;
End start_transaction;

-- End of Procedure start_transaction

/********************************************************/
/**** Implementation change using Oracle Object Types ***/
/********************************************************/

/** Procedure called from Actions Page to derive
    Effective Date  **/

 PROCEDURE validate_salary_details (
  p_assignment_id   IN VARCHAR2,
  p_effective_date  IN date DEFAULT NULL,
  p_item_type IN VARCHAR2 DEFAULT NULL,
  p_item_key IN VARCHAR2 DEFAULT NULL,
  excep_message     OUT NOCOPY VARCHAR2,
  p_pay_proposal_id OUT NOCOPY NUMBER,
  p_current_salary OUT NOCOPY NUMBER,
  p_ovn OUT NOCOPY NUMBER,
  p_api_mode OUT NOCOPY VARCHAR2,
  p_proposal_change_date OUT NOCOPY DATE
  )
  IS

  l_proc varchar2(200) := g_package || 'validate_salary_details';
    Cursor c_assignment IS
    SELECT
    paf.BUSINESS_GROUP_ID,
    paf.payroll_id
    FROM    per_all_assignments_f paf
    WHERE  paf.assignment_id = p_assignment_id
    AND  NVL(p_effective_date, TRUNC(SYSDATE)) BETWEEN
    paf.effective_start_date
    AND paf.effective_end_date
    AND assignment_type = 'E';


     Cursor c_last_salary (p_bg_id VARCHAR2) IS
     Select pay_proposal_id ,
     change_date ,
     next_sal_review_date,
     next_perf_review_date ,
     proposal_reason,
     proposed_salary_n,
     approved,
     review_date,
     multiple_components,
     object_version_number
     from PER_PAY_PROPOSALS
     Where assignment_id = p_assignment_id
     AND   business_group_id = p_bg_id
     order by change_date desc ;


     l_pay_proposal_id             NUMBER ;
     l_approved              	   VARCHAR2(1) ;
     l_change_date            	   DATE ;
     l_next_sal_review_date        DATE;
     l_next_perf_Review_date       DATE ;
     l_proposal_reason        	   VARCHAR2(30) ;
     l_current_salary        	   NUMBER ;
     l_review_date            	   DATE ;
     l_multiple_components    	   Varchar2(1) ;
     ln_ovn                        NUMBER ;
     lv_system_status
        per_assignment_status_types.per_system_status%TYPE;
     lv_payroll_status             per_time_periods.status%TYPE;
     lv_exists                     VARCHAR2(1);
     ld_payroll_start_date         DATE ;
     message                       VARCHAR2(500);
     temp                          VARCHAR2(100);
     l_payroll_id                   per_all_assignments_f.payroll_id%TYPE;
     l_bg_id                        per_all_assignments_f.business_group_id%TYPE;
     l_person_type                 VARCHAR2(5) := 'E';
  BEGIN

      hr_utility.set_location(' Entering:' || l_proc,5);
      begin
        if (p_item_type is not null) and (p_item_key is not null)
        then
	  hr_utility.set_location(l_proc,10);
          l_person_type := wf_engine.GetItemAttrText(itemtype => p_item_type,
                             itemkey  => p_item_key,
                             aname => 'HR_SELECTED_PERSON_TYPE_ATTR');
        end if;
      exception
       when others then
         l_person_type := 'E';
      end;

      if l_person_type <> 'C'
      then

        hr_utility.set_location(l_proc,15);
	Open c_assignment ;
        fetch c_assignment into l_bg_id, l_payroll_id;
          IF (c_assignment%NOTFOUND) THEN
            message := message || hr_util_misc_web.return_msg_text(
                  p_message_name=>'HR_PR_INI_MSG05',
                  p_Application_id=>'PER');
            message := message || '( ' || p_assignment_id || ',' || p_effective_date || ')';
            message := message || '  ';
          END IF;
        close c_assignment;


        Open c_last_Salary (l_bg_id) ;
        fetch c_last_Salary into l_pay_Proposal_Id ,
          l_Change_Date ,
          l_next_Sal_Review_Date,
          l_Next_Perf_Review_Date ,
          l_Proposal_Reason,
          l_Current_Salary,
          l_Approved,
          l_Review_Date,
          l_Multiple_Components,
          ln_ovn ;

          IF (c_last_salary%NOTFOUND) OR (l_pay_proposal_id IS NULL )
          -- first proposal can not be created
          THEN
	    hr_utility.set_location(l_proc,20);
            -- No previous approved pay proposal exists for this  person.
            message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_INI_MSG01',
                 p_Application_id=>'PER');

            message := message || '  ';
          END IF ;
        close c_last_Salary ;


        -- check if a valid payroll exist for the assignment
        -- validation 1
        -- check if this proposal is approved
        -- if not approved , raise error

        IF l_Approved <>'Y'
        THEN
	  hr_utility.set_location(l_proc,25);
          message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_INI_MSG02',
                 p_Application_id=>'PER');
          message := message || '  ';
        END IF ;

        -- check if eligible for salary basis/element
        IF (NOT check_ele_eligibility(p_assignment_id,
                                   to_char(p_effective_date,'RRRR-MM-DD'))) THEN
          hr_utility.set_location(l_proc,30);
          message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_13016_SAL_ELE_NOT_ELIG',
                 p_Application_id=>'PER');
          message := message || '  ';
        END IF;

        -- check that last_change date is <= effective date
        -- if equal to effective date we are in correction mode

        IF l_change_date is not null THEN
	  hr_utility.set_location(l_proc,35);
          p_proposal_change_date := l_change_date + 1;
          --message := message || hr_util_misc_web.return_msg_text(
          --       p_message_name=>'HR_PR_INI_MSG04',
          --       p_Application_id=>'PER');
          --message := message || ' ' || p_proposal_change_date;
        END IF;
        excep_message := message;
        p_pay_proposal_id := l_pay_Proposal_Id;
        p_current_salary := l_Current_Salary;
        p_ovn := ln_ovn;
        p_api_mode := 'INSERT';

      else
        hr_utility.set_location(l_proc,40);
        excep_message := null;
        p_pay_proposal_id := null;
        p_current_salary := null;
        p_ovn := null;
        p_api_mode := null;
      end if;

      hr_utility.set_location(' Leaving:' || l_proc,45);
END validate_salary_details;


PROCEDURE validate_salary_details (
  p_assignment_id      IN VARCHAR2,
  p_bg_id              IN VARCHAR2,
  p_effective_date     IN VARCHAR2,
  p_payroll_id         IN VARCHAR2,
  p_old_pay_basis_id   in number,
  p_new_pay_basis_id   in number,
  excep_message        OUT NOCOPY VARCHAR2,
  p_pay_proposal_id    OUT NOCOPY NUMBER,
  p_current_salary     OUT NOCOPY NUMBER,
  p_ovn                OUT NOCOPY NUMBER,
  p_api_mode           OUT NOCOPY VARCHAR2,
  p_warning_message    OUT NOCOPY VARCHAR2,
  p_asg_type	in varchar2   default 'E'
  )
  IS

     l_proc varchar2(200) := g_package || 'validate_salary_details';
     Cursor c_last_salary IS
     Select pay_proposal_id ,
     change_date ,
     next_sal_review_date,
     next_perf_review_date ,
     proposal_reason,
     proposed_salary_n,
     approved,
     review_date,
     multiple_components,
     object_version_number
     from PER_PAY_PROPOSALS
     Where assignment_id = p_assignment_id
     AND   business_group_id = p_bg_id
     order by change_date desc ;

     CURSOR c_assignment_status IS
     SELECT ast.per_system_status,
            ptp.status
     FROM   per_all_assignments_f                   asg,
            per_time_periods                ptp,
            per_assignment_status_types     ast
     WHERE  asg.assignment_id     =   p_assignment_id
     AND    asg.assignment_status_type_id = ast.assignment_status_type_id
     AND    to_date(p_effective_date,'RRRR-MM-DD')
            between asg.effective_start_date
                and asg.effective_end_date
     AND    asg.payroll_id=ptp.payroll_id;

     CURSOR c_future_assignment_changes IS
     Select 'Y'
     FROM  per_all_assignments_f
     WHERE effective_start_date > to_date(p_effective_date,'RRRR-MM-DD')
     AND   assignment_id = p_assignment_id
     AND   business_group_id = p_bg_id ;

     CURSOR c_grade_step_placement  IS
     SELECT 'Y'
     FROM  per_spinal_point_placements_f pspp
     WHERE pspp.assignment_id=p_assignment_id
     AND   to_date(p_effective_date,'RRRR-MM-DD')  between
             pspp.effective_start_date and pspp.effective_end_date ;

     CURSOR  c_payroll_period ( p_payroll_id NUMBER )  IS
     SELECT  start_date
     FROM    per_time_periods
     WHERE   trunc(sysdate) between start_date and end_date
     AND     payroll_id = p_payroll_id;

     l_pay_proposal_id             NUMBER ;
     l_approved              	   VARCHAR2(1) ;
     l_change_date            	   DATE ;
     l_next_sal_review_date        DATE;
     l_next_perf_Review_date       DATE ;
     l_proposal_reason        	   VARCHAR2(30) ;
     l_current_salary        	   NUMBER ;
     l_review_date            	   DATE ;
     l_multiple_components    	   Varchar2(1) ;
     ln_ovn                        NUMBER ;
     lv_system_status
        per_assignment_status_types.per_system_status%TYPE;
     lv_payroll_status             per_time_periods.status%TYPE;
     lv_exists                     VARCHAR2(1);
     ld_payroll_start_date         DATE ;
     message                       VARCHAR2(500) := '';
     temp                          VARCHAR2(100) := '';
     warn_message                  VARCHAR2(1000) := '';

      -- Bug 2354730 Fix Begins
      lv_pay_proposal_rec_found    boolean default false;
      -- Bug 2354730 Fix Ends

  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);

    -- get last salary details
    -- p_new_pay_basis_id always has a value
    -- p_old_pay_basis_id can be null
    -- Only validate if salary basis is the same or different but not when
    -- p_old_pay_basis_id is null, which is new.

    --4002387 previously we were doing validations only when salary basis is not changed
    --        now we will do validations when previous proposal data exists
    --        no matter salary basis is changed or not
    IF p_old_pay_basis_id IS NOT NULL OR p_new_pay_basis_id IS NOT NULL
    THEN
       hr_utility.set_location( l_proc,10);
       -- Bug 2354730 Fix Begins
       -- Only validate pay proposal data when there's no change to the
       -- salary basis. That means Pay Rate is standalone, in which case
       -- pay proposal data may exist.  If we cannot find a record in
       -- per_pay_proposal, bypass the rest of validation.  If a record is
       -- found, then do validation.

       -- In other cases, such as adding a new salary basis or changing an
       -- existing salary basis in which new pay proposal data has not been
       -- entered yet, we want to bypass the logic to look for pay proposal
       -- data.

       Open c_last_Salary ;
       fetch c_last_Salary into l_pay_Proposal_Id ,
         l_Change_Date ,
         l_next_Sal_Review_Date,
         l_Next_Perf_Review_Date ,
         l_Proposal_Reason,
         l_Current_Salary,
         l_Approved,
         l_Review_Date,
         l_Multiple_Components,
         ln_ovn ;

       IF (c_last_salary%NOTFOUND)
       THEN
          hr_utility.set_location( l_proc,15);
          NULL;  -- bypass the rest of the validations
       ELSE
          hr_utility.set_location( l_proc,20);
          lv_pay_proposal_rec_found := TRUE;
       END IF;

       close c_last_Salary ;

  END IF;

       -- hr_utility.trace(' first proposal can not be created ' );
       -- hr_utility.trace(message );
       -- check if a valid payroll exist for the assignment
       -- validation 1
       -- check if this proposal is approved
       -- if not approved , raise error

  IF lv_pay_proposal_rec_found
  THEN
     hr_utility.set_location( l_proc,25);
     IF l_Approved <>'Y'
     THEN
         hr_utility.set_location( l_proc,30);
         message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG02_WEB',
                 p_Application_id=>'PER');
         message := message || '  ';
     END IF ;

      -- check if eligible for salary basis/element
      IF (NOT check_ele_eligibility(p_assignment_id,
                                    p_effective_date)) THEN
				    hr_utility.set_location( l_proc,35);
         message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_13016_SAL_ELE_NOT_ELIG',
                 p_Application_id=>'PER');
         message := message || '  ';
      END IF;

     --hr_utility.trace(message );
     --  validation 2
     -- check that last_change date is <= effective date
     -- if equal to effective date we are in correction mode

     IF l_change_date <= to_date(p_effective_date,'RRRR-MM-DD')
     THEN
        IF (l_change_date = to_date(p_effective_date,'RRRR-MM-DD') AND p_asg_type <> 'A')
        THEN
	hr_utility.set_location( l_proc,40);
          message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG03_WEB',
                 p_Application_id=>'PER');
          message := message || '  ';
        END IF ;
     ELSE
     hr_utility.set_location( l_proc,45);
        message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG04_WEB',
                 p_Application_id=>'PER');
         message := message || '  ';
       END IF ;
  END IF;  -- lv_pay_proposal_rec_found = TRUE
  -- Bug 2354730 Fix Ends

  -- hr_utility.trace(message );
  -- validate that assignment is not terminated on the date of the
  -- change
  open c_assignment_status  ;
  fetch c_assignment_status into
  lv_system_status, lv_payroll_status ;

  IF lv_system_status =  'TERM_ASSIGN'
  THEN
  hr_utility.set_location( l_proc,50);
     message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG16_WEB',
                 p_Application_id=>'PER');
     message := message || '  ';
   END IF ;

   close c_assignment_status ;
   -- hr_utility.trace(message );
   -- validation 3
   -- validate that assignment does not have future changes to
   -- be effective after the effective date , if so raise warning
   OPEN  c_future_assignment_changes ;
   FETCH c_future_assignment_changes into lv_exists ;
   IF c_future_assignment_changes%NOTFOUND
   THEN
   hr_utility.set_location( l_proc,55);
      lv_exists := 'N';
   END IF ;

   CLOSE c_future_assignment_changes ;

   -- hr_utility.trace(message );
   IF lv_exists ='Y' THEN
   hr_utility.set_location( l_proc,60);
      -- future assignment changes exists warning
   -- bug 3033365 raise a warning
      /*message := message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG05_WEB',
                 p_Application_id=>'PER');
      message := message || '  ';*/
      warn_message := warn_message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG05_WEB',
                 p_Application_id=>'PER');
      warn_message := warn_message || '  ';
   END IF ;

   -- raise a warnign if effective date is before the last payroll
   -- period

   OPEN c_payroll_period ( p_payroll_id ) ;
   FETCH c_payroll_period into ld_payroll_start_date ;
   CLOSE c_payroll_period ;

   IF to_date(p_effective_date,'RRRR-MM-DD')  < ld_payroll_start_date
      AND p_payroll_id is not null
   THEN
   hr_utility.set_location( l_proc,65);
      -- hr_utility.trace('effective Date is less than ld_payroll_start_date ');
         warn_message := warn_message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG17_WEB',
                 p_Application_id=>'PER');
         warn_message := warn_message || '  ';
   END IF ;

   -- validation 4
   -- raise a warning if assignment is placed on the grade step
   -- hr_utility.trace(message );
   OPEN c_grade_step_placement ;
   FETCH c_grade_step_placement into lv_exists ;

   IF c_grade_step_placement%NOTFOUND
   THEN
   hr_utility.set_location( l_proc,70);
      lv_exists := 'N' ;
   END IF ;

   -- statement here for error checking ;
   CLOSE c_grade_step_placement ;

   IF lv_exists ='Y'
   THEN
   hr_utility.set_location( l_proc,75);
      -- hr_utility.trace('c_grade_step_placement warning');
      warn_message := warn_message || hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_PR_MSG06_WEB',
                 p_Application_id=>'PER');
      warn_message := warn_message || '  ';
   END IF ;

   -- hr_utility.trace(message );

   excep_message := message;
   p_warning_message := warn_message;
   p_pay_proposal_id := l_pay_Proposal_Id;
   p_current_salary := l_Current_Salary;
   p_ovn := ln_ovn;
   p_api_mode := 'INSERT';

   --  hr_utility.trace(excep_message );


hr_utility.set_location(' Leaving:' || l_proc,80);
END validate_salary_details;


-- GSP changes
PROCEDURE get_transaction_step_details(p_item_type     IN  VARCHAR2,
                              p_item_key        IN VARCHAR2,
                              p_transaction_step_id          IN VARCHAR2,
                              trans_exists      OUT NOCOPY VARCHAR2,
                              no_of_components  OUT NOCOPY NUMBER ,
                              is_multiple_payrate     OUT NOCOPY VARCHAR2 )
IS

  l_proc varchar2(200) := g_package || 'get_transaction_step_details';

  ln_transaction_id      hr_api_transactions.transaction_id%TYPE;
  ltt_trans_step_ids     hr_util_web.g_varchar2_tab_type;
  ltt_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
  ln_trans_step_rows     NUMBER  ;
  lv_activity_name       VARCHAR2(100);
  lv_activity_display_name VARCHAR2(100);
  ln_no_of_components    NUMBER ;
  lv_trans_exists VARCHAR2(10) := 'NO';
  ln_transaction_step_id NUMBER;
  lv_pay_rate_type VARCHAR2(10) := '';


BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    trans_exists := '';
    no_of_components := 0;
    is_multiple_payrate := '';

    --hr_utility.trace(' ********** In is_transaction_exists ');
    --hr_utility.trace(' p_item_type' || p_item_type || ' ' ||
    --                 ' p_item_key' || p_item_key || ' ' ||
    --                 ' p_transaction_step_id' || p_transaction_step_id );

        ln_transaction_id := hr_transaction_ss.get_transaction_id
                             (p_Item_Type   => p_item_type,
                              p_Item_Key    => p_item_key);

        IF p_transaction_step_id IS NOT NULL
        THEN
	   hr_utility.set_location(l_proc,10);
                ln_no_of_components :=
                hr_transaction_api.get_number_value
                        (p_transaction_step_id => p_transaction_step_id,
                         p_name => 'p_no_of_components');

                IF ln_no_of_components IS NOT NULL THEN
		 hr_utility.set_location(l_proc,15);
                    no_of_components := ln_no_of_components;
                END IF;

                lv_pay_rate_type :=
                hr_transaction_api.get_varchar2_value
                        (p_transaction_step_id => p_transaction_step_id,
                         p_name => 'P_MULTIPLE_COMPONENTS');

                IF lv_pay_rate_type IS NOT NULL THEN
		 hr_utility.set_location(l_proc,20);
                    is_multiple_payrate := lv_pay_rate_type;
                END IF;

                lv_trans_exists := 'YES';
                trans_exists := lv_trans_exists;

        END IF;

	hr_utility.set_location(' Leaving:' || l_proc,25);
  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,555);
        raise;
END get_transaction_step_details;
-- End of GSP changes



PROCEDURE is_transaction_exists(p_item_type     IN  VARCHAR2,
                              p_item_key        IN VARCHAR2,
                              p_act_id          IN VARCHAR2,
                              trans_exists      OUT NOCOPY VARCHAR2,
                              no_of_components  OUT NOCOPY NUMBER ,
                              is_multiple_payrate     OUT NOCOPY VARCHAR2 )
IS


l_proc varchar2(200) := g_package || 'is_transaction_exists';
  ln_transaction_id      hr_api_transactions.transaction_id%TYPE;
  ltt_trans_step_ids     hr_util_web.g_varchar2_tab_type;
  ltt_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
  ln_trans_step_rows     NUMBER  ;
  lv_activity_name       VARCHAR2(100);
  lv_activity_display_name VARCHAR2(100);
  ln_no_of_components    NUMBER ;
  lv_trans_exists VARCHAR2(10) := 'NO';
  ln_transaction_step_id NUMBER;
  lv_pay_rate_type VARCHAR2(10) := '';


BEGIN
hr_utility.set_location(' Entering:' || l_proc,5);
    trans_exists := '';
    no_of_components := 0;
    is_multiple_payrate := '';

     -- hr_utility.trace_on(null,'dev_log');

   -- hr_utility.trace(' ********** In is_transaction_exists ');
    --hr_utility.trace(' p_item_type' || p_item_type || ' ' ||
    --                 ' p_item_key' || p_item_key || ' ' ||
    --                 ' p_act_id' || p_act_id );

    IF( hr_transaction_ss.check_txn_step_exists(
           p_item_type,
           p_item_key,
           p_act_id )= TRUE )
    THEN

hr_utility.set_location(l_proc,10);
        ln_transaction_id := hr_transaction_ss.get_transaction_id
                             (p_Item_Type   => p_item_type,
                              p_Item_Key    => p_item_key);

        -- hr_utility.trace(' ln_transaction_id ' || ln_transaction_id);

        IF ln_transaction_id IS NOT NULL
        THEN
	hr_utility.set_location(l_proc,15);
            hr_transaction_api.get_transaction_step_info
                   (p_Item_Type   => p_item_type,
                    p_Item_Key    => p_item_key,
                    p_activity_id =>p_act_id,
                    p_transaction_step_id => ltt_trans_step_ids,
                    p_object_version_number => ltt_trans_obj_vers_num,
                    p_rows                  => ln_trans_step_rows);


        -- if no transaction steps are found , return
            IF ln_trans_step_rows < 1
            THEN
	    hr_utility.set_location(' Leaving:' || l_proc,20);
                RETURN ;
            ELSE
hr_utility.set_location(l_proc,25);
                hr_mee_workflow_service.get_activity_name
                (p_item_type  => p_item_type
                ,p_item_key   => p_item_key
                ,p_actid      => p_act_id
                ,p_activity_name => lv_activity_name
                ,p_activity_display_name => lv_activity_display_name);


               -- hr_utility.trace(' lv_activity_name ' || lv_activity_name);

                ln_transaction_step_id  :=
                    hr_transaction_ss.get_activity_trans_step_id
                    (p_activity_name =>lv_activity_name,
                    p_trans_step_id_tbl => ltt_trans_step_ids);


                ln_no_of_components :=
                hr_transaction_api.get_number_value
                        (p_transaction_step_id => ln_transaction_step_id,
                         p_name => 'p_no_of_components');

                IF ln_no_of_components IS NOT NULL THEN
		hr_utility.set_location(l_proc,30);
                    no_of_components := ln_no_of_components;
                END IF;

               -- hr_utility.trace(' ln_no_of_components ' || ln_no_of_components);

                lv_pay_rate_type :=
                hr_transaction_api.get_varchar2_value
                        (p_transaction_step_id => ln_transaction_step_id,
                         p_name => 'P_MULTIPLE_COMPONENTS');

                IF lv_pay_rate_type IS NOT NULL THEN
		hr_utility.set_location(l_proc,35);
                    is_multiple_payrate := lv_pay_rate_type;
                END IF;

               -- hr_utility.trace(' is_multiple_payrate ' || is_multiple_payrate);

                lv_trans_exists := 'YES';
                trans_exists := lv_trans_exists;

                -- hr_utility.trace(' trans_exists ' || trans_exists);
            END IF;
      END IF;
  END IF;


hr_utility.set_location(' Leaving:' || l_proc,40);
  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,555);
        raise;
END is_transaction_exists;



  PROCEDURE validate_component_api_java(
    p_ltt_salary_data    IN OUT NOCOPY sshr_sal_prop_tab_typ,
    p_ltt_component      IN OUT NOCOPY sshr_sal_comp_tab_typ ,
    p_validate           IN BOOLEAN DEFAULT FALSE )
  IS

  l_proc varchar2(200) := g_package || 'validate_component_api_java';
    ln_count 		     NUMBER ;
    i        	 	     NUMBER ;
    ln_object_version_number NUMBER ;
    ln_component_id          NUMBER ;
    lv_message_number         VARCHAR2(15);

  BEGIN
hr_utility.set_location(' Entering:' || l_proc,5);
   -- hr_utility.trace(' ***** IN  validate_component_api_java *****');

    -- get the no of components
    --ln_count := p_ltt_component.count ;

    ln_count := p_ltt_salary_data(1).no_of_components;

    -- hr_utility.trace('No Of Components In Component Proc' || ln_count);
    -- now call the component API for each component
    FOR i in 1..ln_count
    LOOP
      hr_maintain_proposal_api.insert_proposal_component(
        p_component_id=>ln_component_id ,
        p_pay_proposal_id=>p_ltt_salary_data(1).pay_proposal_id,
        p_business_group_id=>p_ltt_salary_data(1).business_group_id,
        p_approved       =>  p_ltt_component(i).approved,
        p_component_reason =>p_ltt_component(i).component_reason,
        p_change_amount_n  => to_number(p_ltt_component(i).change_amount),
        p_change_percentage   =>p_ltt_component(i).change_percent,
        p_comments         =>NULL,
        p_attribute_category =>p_ltt_component(i).attribute_category,
        p_attribute1 => p_ltt_component(i).attribute1,
        p_attribute2 => p_ltt_component(i).attribute2,
        p_attribute3 => p_ltt_component(i).attribute3,
        p_attribute4 => p_ltt_component(i).attribute4,
        p_attribute5 => p_ltt_component(i).attribute5,
        p_attribute6 => p_ltt_component(i).attribute6,
        p_attribute7 => p_ltt_component(i).attribute7,
        p_attribute8 => p_ltt_component(i).attribute8,
        p_attribute9 => p_ltt_component(i).attribute9,
        p_attribute10 => p_ltt_component(i).attribute10,
        p_attribute11 => p_ltt_component(i).attribute11,
        p_attribute12 => p_ltt_component(i).attribute12,
        p_attribute13 => p_ltt_component(i).attribute13,
        p_attribute14 => p_ltt_component(i).attribute14,
        p_attribute15 => p_ltt_component(i).attribute15,
        p_attribute16 => p_ltt_component(i).attribute16,
        p_attribute17 => p_ltt_component(i).attribute17,
        p_attribute18 => p_ltt_component(i).attribute18,
        p_attribute19 => p_ltt_component(i).attribute19,
        p_attribute20 => p_ltt_component(i).attribute20,
        p_object_version_number =>ln_object_version_number,
        p_validate=>FALSE,
        p_validation_strength=>'WEAK');

        p_ltt_component(i).component_id := ln_component_id ;
    END LOOP ;

     -- hr_utility.trace(' ***** OUT  validate_component_api_java *****');


hr_utility.set_location(' Leaving:' || l_proc,10);
    EXCEPTION
    WHEN hr_utility.hr_error THEN
    hr_utility.set_location(' Leaving:' || l_proc,555);
--        ROLLBACK;
     -- hr_utility.trace('Utility Exception in validate_component_api_java');
      raise;
        --hr_message.provide_error;
        -- lv_message_number := hr_message.last_message_number;
        --hr_errors_api.addErrorToTable(
        --  p_errormsg => hr_message.get_message_text,
        --  p_errorcode => lv_message_number);

    WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,560);
        ROLLBACK;
        -- hr_utility.trace(' Others Exception in validate_component_api_java');
        raise;
      --hr_util_disp_web.display_fatal_errors (
       -- p_message => UPPER(gv_package_name ||
        --              '.validate_component_api: '|| SQLERRM));
  END validate_component_api_java ;



     PROCEDURE validate_salary_ins_api_java (
     p_item_type                    IN     wf_items.item_type%type ,
     p_item_key                     IN     wf_items.item_key%TYPE ,
     p_Act_id                       IN     NUMBER,
     p_ltt_salary_data              IN OUT NOCOPY sshr_sal_prop_tab_typ ,
     p_ltt_component                IN OUT NOCOPY sshr_sal_comp_tab_typ,
     p_validate                     IN     BOOLEAN DEFAULT FALSE ,
     p_effective_date               IN     VARCHAR2 DEFAULT NULL,
     p_inv_next_sal_date_warning       out nocopy boolean,
     p_proposed_salary_warning         out nocopy boolean,
     p_approved_warning                out nocopy boolean,
     p_payroll_warning                 out nocopy boolean
    ) IS


l_proc varchar2(200) := g_package || 'validate_salary_ins_api_java';
     l_pay_proposal_id         NUMBER ;
     l_object_version_number   NUMBER ;
     l_next_sal_date_warning   BOOLEAN ;
     l_proposed_sal_warning    BOOLEAN ;
     l_approved_warning        BOOLEAN ;
     l_payroll_warning         BOOLEAN ;
     l_element_entry_id        NUMBER ;
     ln_count                  NUMBER ;
     i                         NUMBER ;
     l_component_id            NUMBER ;
     lv_message_number         VARCHAR2(15);
     lv_proposal_reason        VARCHAR2(250);
     message                   VARCHAR2(2500) default '';
     ld_effec_date             date DEFAULT NULL;
     lb_save_point_exists      boolean default false;

cursor csr_payproposal is
        select pay_proposal_id, object_version_number
        from per_pay_proposals
        where assignment_id = p_ltt_salary_data(1).assignment_id
 	                    and change_date = ld_effec_date;

   BEGIN

      -- hr_utility.trace(' ***** IN  validate_salary_ins_api_java *****');

   /*
      message := message ||
                ' attribute_category' || p_ltt_salary_data(1).attribute_category       ||
                ' attribute1' || p_ltt_salary_data(1).attribute1                       ||
                ' attribute2' || p_ltt_salary_data(1).attribute2                       ||
                ' attribute3' || p_ltt_salary_data(1).attribute3                       ||
                ' attribute4' || p_ltt_salary_data(1).attribute4                       ||
                ' attribute5' || p_ltt_salary_data(1).attribute5                       ||
                ' attribute6' || p_ltt_salary_data(1).attribute6                       ||
                ' attribute7' || p_ltt_salary_data(1).attribute7                       ||
                ' attribute8' || p_ltt_salary_data(1).attribute8                       ||
                ' attribute9' || p_ltt_salary_data(1).attribute9                       ||
                ' attribute10' || p_ltt_salary_data(1).attribute10                     ||
                ' attribute11' || p_ltt_salary_data(1).attribute11                     ||
                ' attribute12' || p_ltt_salary_data(1).attribute12                     ||
                ' attribute13' || p_ltt_salary_data(1).attribute13                     ||
                ' attribute14' || p_ltt_salary_data(1).attribute14                     ||
                ' attribute15' || p_ltt_salary_data(1).attribute15                     ||
                ' attribute16' || p_ltt_salary_data(1).attribute16                     ||
                ' attribute17' || p_ltt_salary_data(1).attribute17                     ||
                ' attribute18' || p_ltt_salary_data(1).attribute18                     ||
                ' attribute19' || p_ltt_salary_data(1).attribute19                     ||
                ' attribute20' || p_ltt_salary_data(1).attribute20                     ||
                ' no_of_components' || p_ltt_salary_data(1).no_of_components  ;


     hr_utility.trace(message);
     */

hr_utility.set_location(' Entering:' || l_proc,5);
     if(p_effective_date is null) then
     hr_utility.set_location(l_proc,10);
        ld_effec_date := p_ltt_salary_data(1).effective_date;
     else
     hr_utility.set_location(l_proc,15);
        ld_effec_date := to_date(p_effective_date, 'RRRR-MM-DD');
     end if;
     -- check if multiple components exists
     -- call the salary API in validate mode
     SAVEPOINT insert_salary ;
     lb_save_point_exists := TRUE;

       -- start a block for the salary proposal api
       l_element_entry_id := p_ltt_salary_data(1).element_entry_id ;


       IF p_ltt_salary_data(1).multiple_components = 'Y'
       THEN
       hr_utility.set_location(l_proc,20);
         lv_proposal_reason := NULL ;
       ELSE
       hr_utility.set_location(l_proc,25);
         lv_proposal_reason :=  p_ltt_salary_data(1).proposal_reason ;
       END IF ;

         -- hr_utility.trace(' *****************************************************');
         -- hr_utility.trace(' Start hr_maintain_proposal_api.insert_salary_proposal');
        --  hr_utility.trace(' *****************************************************');




      /* validate = FALSE it is not rolledback
         validate = TRUE it is rolledback
         For multiple components to validated we need to insert the proposal record
         that is the reason this API is called in FALSE mode and later it is rollbacked
      */

    open csr_payproposal;
    fetch csr_payproposal into l_pay_proposal_id, l_object_version_number;
    IF csr_payproposal%found THEN

/* although this code is called unconditionally this scenario will only occur for an applicant having
   an offer. for other cases this will never be true since we throw warning from validate_salary_details
   and do not show the Pay Rate page itself	*/

       hr_maintain_proposal_api.update_salary_proposal(
         p_pay_proposal_id=>l_pay_proposal_id ,
         p_change_date=> ld_effec_date,   -- 2355929
         p_comments=>p_ltt_salary_data(1).comments,
         p_next_sal_review_date=>p_ltt_salary_data(1).next_sal_review_date,
         p_proposal_reason =>lv_proposal_reason,
         p_proposed_salary_n =>p_ltt_salary_data(1).proposed_salary ,
         p_forced_ranking  =>to_number(p_ltt_salary_data(1).ranking) ,
         p_performance_review_id=>
         p_ltt_salary_data(1).Performance_review_id,
         p_attribute_category =>p_ltt_salary_data(1).attribute_category,
         p_attribute1 => p_ltt_salary_data(1).attribute1,
         p_attribute2 => p_ltt_salary_data(1).attribute2,
         p_attribute3 => p_ltt_salary_data(1).attribute3,
         p_attribute4 => p_ltt_salary_data(1).attribute4,
         p_attribute5 => p_ltt_salary_data(1).attribute5,
         p_attribute6 => p_ltt_salary_data(1).attribute6,
         p_attribute7 => p_ltt_salary_data(1).attribute7,
         p_attribute8 => p_ltt_salary_data(1).attribute8,
         p_attribute9 => p_ltt_salary_data(1).attribute9,
         p_attribute10 => p_ltt_salary_data(1).attribute10,
         p_attribute11 => p_ltt_salary_data(1).attribute11,
         p_attribute12 => p_ltt_salary_data(1).attribute12,
         p_attribute13 => p_ltt_salary_data(1).attribute13,
         p_attribute14 => p_ltt_salary_data(1).attribute14,
         p_attribute15 => p_ltt_salary_data(1).attribute15,
         p_attribute16 => p_ltt_salary_data(1).attribute16,
         p_attribute17 => p_ltt_salary_data(1).attribute17,
         p_attribute18 => p_ltt_salary_data(1).attribute18,
         p_attribute19 => p_ltt_salary_data(1).attribute19,
         p_attribute20 => p_ltt_salary_data(1).attribute20,
         p_object_version_number=>l_object_version_number ,
         p_multiple_components=>p_ltt_salary_data(1).multiple_components,
         p_approved=>'Y',
         p_validate=>FALSE ,
         p_inv_next_sal_date_warning=>l_next_sal_date_warning,
         p_proposed_salary_warning=>l_proposed_sal_warning,
         p_approved_warning=>l_approved_warning,
         p_payroll_warning =>l_payroll_warning) ;

    ELSE

       hr_maintain_proposal_api.insert_salary_proposal(
         p_pay_proposal_id=>l_pay_proposal_id ,
         p_assignment_id=>p_ltt_salary_data(1).assignment_id ,
         p_business_group_id=>p_ltt_salary_data(1).business_group_id ,
         --p_change_date=>p_ltt_salary_data(1).effective_date,
         p_change_date=> ld_effec_date,   -- 2355929
         p_comments=>p_ltt_salary_data(1).comments,
         p_next_sal_review_date=>p_ltt_salary_data(1).next_sal_review_date,
         p_proposal_reason =>lv_proposal_reason,
         p_proposed_salary_n =>p_ltt_salary_data(1).proposed_salary ,
         p_forced_ranking  =>to_number(p_ltt_salary_data(1).ranking) ,
         p_performance_review_id=>
         p_ltt_salary_data(1).Performance_review_id,
         p_attribute_category =>p_ltt_salary_data(1).attribute_category,
         p_attribute1 => p_ltt_salary_data(1).attribute1,
         p_attribute2 => p_ltt_salary_data(1).attribute2,
         p_attribute3 => p_ltt_salary_data(1).attribute3,
         p_attribute4 => p_ltt_salary_data(1).attribute4,
         p_attribute5 => p_ltt_salary_data(1).attribute5,
         p_attribute6 => p_ltt_salary_data(1).attribute6,
         p_attribute7 => p_ltt_salary_data(1).attribute7,
         p_attribute8 => p_ltt_salary_data(1).attribute8,
         p_attribute9 => p_ltt_salary_data(1).attribute9,
         p_attribute10 => p_ltt_salary_data(1).attribute10,
         p_attribute11 => p_ltt_salary_data(1).attribute11,
         p_attribute12 => p_ltt_salary_data(1).attribute12,
         p_attribute13 => p_ltt_salary_data(1).attribute13,
         p_attribute14 => p_ltt_salary_data(1).attribute14,
         p_attribute15 => p_ltt_salary_data(1).attribute15,
         p_attribute16 => p_ltt_salary_data(1).attribute16,
         p_attribute17 => p_ltt_salary_data(1).attribute17,
         p_attribute18 => p_ltt_salary_data(1).attribute18,
         p_attribute19 => p_ltt_salary_data(1).attribute19,
         p_attribute20 => p_ltt_salary_data(1).attribute20,
         p_object_version_number=>l_object_version_number ,
         p_multiple_components=>p_ltt_salary_data(1).multiple_components,
         p_approved=>'Y',
         p_validate=>FALSE ,
         p_element_entry_id=>l_element_entry_id,
         p_inv_next_sal_date_warning=>l_next_sal_date_warning,
         p_proposed_salary_warning=>l_proposed_sal_warning,
         p_approved_warning=>l_approved_warning,
         p_payroll_warning =>l_payroll_warning) ;

    END IF;


        --  hr_utility.trace(' *****************************************************');
         -- hr_utility.trace(' l_pay_proposal_id' || l_pay_proposal_id);
         -- hr_utility.trace(' l_element_entry_id ' || l_element_entry_id);
         if ( l_next_sal_date_warning) then hr_utility.trace(' l_next_sal_date_warning ' ); end if;
         if ( l_proposed_sal_warning) then hr_utility.trace(' l_proposed_sal_warning ' ); end if;
         if ( l_approved_warning) then hr_utility.trace(' l_approved_warning ' ); end if;
         if ( l_payroll_warning) then hr_utility.trace(' l_payroll_warning ' ); end if;
        -- hr_utility.trace(' *****************************************************');



       -- hr_utility.trace(' End hr_maintain_proposal_api.insert_salary_proposal');

       p_ltt_salary_data(1).pay_proposal_id := l_pay_proposal_id ;

       p_ltt_salary_data(1).element_entry_id := l_element_entry_id ;


       IF p_ltt_salary_data(1).multiple_components = 'Y'
       THEN
       hr_utility.set_location(l_proc,30);
          -- hr_utility.trace(' Start validate_component_api_java.insert_salary_proposal');

         validate_component_api_java(
           p_ltt_salary_data,
           p_ltt_component ,
           p_validate ) ;
         -- hr_utility.trace(' End validate_component_api_java.insert_salary_proposal');


       END IF ;


     IF p_validate
     THEN
     hr_utility.set_location(l_proc,40);
       ROLLBACK to insert_salary ;
       lb_save_point_exists := FALSE;
     END IF ;

     p_inv_next_sal_date_warning := l_next_sal_date_warning;
     p_proposed_salary_warning := l_proposed_sal_warning;
     p_approved_warning := l_approved_warning;
     p_payroll_warning := l_payroll_warning;


hr_utility.set_location(' Leaving:' || l_proc,45);
     EXCEPTION
     WHEN hr_utility.hr_error THEN

       IF lb_save_point_exists
       THEN
          ROLLBACK to insert_salary;
       END IF;

       --hr_utility.trace(' validate_salary_ins_api_java Execption hr_utility ');
       hr_utility.set_location(' Leaving:' || l_proc,555);
       raise;
       --hr_message.provide_error;
       --lv_message_number := hr_message.last_message_number;
       --hr_errors_api.addErrorToTable(
       --  p_errormsg => hr_message.get_message_text,
       --  p_errorcode => lv_message_number
       --  );

     WHEN OTHERS THEN
       --hr_util_disp_web.display_fatal_errors (
        -- p_message => UPPER(gv_package_name || '.validate_salary_insert_api: '
         --             ||SQLERRM));
         --hr_utility.trace(' validate_salary_ins_api_java When Others Execption  '|| SQLERRM);
        IF lb_save_point_exists
        THEN
           ROLLBACK to insert_salary;
        END IF;
hr_utility.set_location(' Leaving:' || l_proc,560);
         raise;


     END  validate_salary_ins_api_java;





      /* -------------------------------------------------------
  -- Procedure: maintain_txn_java
  -- Procedure to store data into txn table
  ----------------------------------------------------------*/
  PROCEDURE maintain_txn_java (
    p_item_type                   IN wf_items.item_type%type
   ,p_item_key                    IN wf_items.item_key%TYPE
   ,p_Act_id                      IN NUMBER
   ,p_ltt_salary_data             in sshr_sal_prop_tab_typ
   ,p_ltt_component               in sshr_sal_comp_tab_typ
   ,p_review_proc_call            in VARCHAR2
   ,p_flow_mode                   in varchar2
   ,p_step_id                     out nocopy NUMBER
   ,p_rptg_grp_id                 IN VARCHAR2 DEFAULT NULL
   ,p_plan_id                     IN VARCHAR2 DEFAULT NULL
   ,p_effective_date_option       IN VARCHAR2  DEFAULT NULL
   ) IS

l_proc varchar2(200) := g_package || 'maintain_txn_java';
    ln_transaction_id       NUMBER ;
    lv_result    VARCHAR2(100);
    li_count     INTEGER ;
    lv_api_name  hr_api_transaction_steps.api_name%type ;
    ln_ovn       hr_api_transaction_steps.object_version_number%TYPE;
    ln_transaction_step_id  hr_api_transaction_steps.transaction_step_id%TYPE default null;
    ltt_trans_step_ids      hr_util_web.g_varchar2_tab_type;
    ltt_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
    ln_trans_step_rows      number  default 0;
    lv_activity_name        wf_item_activity_statuses_v.activity_name%TYPE;
    ln_no_of_components     NUMBER ;
    lv_review_url           VARCHAR2(1000) ;
    lv_activity_display_name VARCHAR2(100);
    message VARCHAR2(10000) := '';
    ln_creator_person_id NUMBER;
    result VARCHAR2(100);

    cursor get_transaction_step_id(
        c_item_type  in wf_items.item_type%type
	   ,c_item_key in wf_items.item_key%type
    ) IS
    SELECT transaction_step_id
    FROM   hr_api_transaction_steps
    WHERE  item_type = c_item_type
    AND    item_key  = c_item_key
    --AND    api_name = 'HR_PAY_RATE_SS.process_api_java';
    AND    api_name = 'HR_PAY_RATE_SS.PROCESS_API';

   gtt_trans_steps  hr_transaction_ss.transaction_table;

   BEGIN
   hr_utility.set_location(' Entering:' || l_proc,5);
     -- bug # 1641590

       -- hr_utility.trace('Start Maintain Transaction');

     lv_review_url := gv_package_name||'.salary_review';
     --lv_api_name := gv_package_name||'.process_api_java' ;
     lv_api_name := gv_package_name||'.PROCESS_API' ;



     ln_creator_person_id := wf_engine.GetItemAttrNumber(p_item_type,
                           p_item_key,
                           'CREATOR_PERSON_ID');

     -- hr_utility.trace('Creator Person Id ' || ln_creator_person_id);

     --insert into dev_test values (' In Maintain Transaction ');
    -- commit;


     -- prepare salary proposal data to be stored in transaction table
     li_count := 1 ;

     gtt_trans_steps(li_count).param_name := 'P_REVIEW_PROC_CALL' ;
     gtt_trans_steps(li_count).param_value := p_review_proc_call;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'P_EFFECTIVE_DATE_OPTION' ;
     gtt_trans_steps(li_count).param_value := p_effective_date_option;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'P_REVIEW_ACTID' ;
     gtt_trans_steps(li_count).param_value := p_Act_id;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;

     -- 04/24/02 Change Begins
     gtt_trans_steps(li_count).param_name := 'P_FLOW_MODE' ;
     gtt_trans_steps(li_count).param_value := p_flow_mode;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;
     -- 04/24/02 Change Ends

     -- GSP changes
     gtt_trans_steps(li_count).param_name := 'p_gsp_dummy_txn' ;
     gtt_trans_steps(li_count).param_value := 'NO';
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;
     li_count := li_count+1 ;
     -- end of GSP changes


     gtt_trans_steps(li_count).param_name := 'p_current_salary' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).current_salary ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'p_assignment_id' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).assignment_id  ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;
     li_count := li_count+1 ;

     gtt_trans_steps(li_count).param_name := 'p_bus_group_id' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).business_group_id  ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;
     li_count := li_count+1 ;


     gtt_trans_steps(li_count).param_name := 'p_effective_date' ;
     gtt_trans_steps(li_count).param_value :=
       to_char(p_ltt_salary_data(1).effective_date,hr_transaction_ss.g_date_format);
     gtt_trans_steps(li_count).param_data_type := 'DATE' ;
     li_count := li_count+1 ;


     gtt_trans_steps(li_count).param_name := 'p_salary_effective_date' ;
     gtt_trans_steps(li_count).param_value :=
       to_char(p_ltt_salary_data(1).salary_effective_date,hr_transaction_ss.g_date_format);
     gtt_trans_steps(li_count).param_data_type := 'DATE' ;
     li_count := li_count+1 ;

     hr_mee_workflow_service.get_activity_name
                (p_item_type  => p_item_type
                ,p_item_key   => p_item_key
                ,p_actid      => p_act_id
                ,p_activity_name => lv_activity_name
                ,p_activity_display_name => lv_activity_display_name);

     gtt_trans_steps(li_count).param_name := 'p_activity_name' ;
     gtt_trans_steps(li_count).param_value := lv_activity_name ;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count := li_count+1 ;


     gtt_trans_steps(li_count).param_name := 'p_change_amount' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).salary_change_amount ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_change_percent' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).salary_change_percent ;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;


     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_proposed_salary' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).proposed_salary;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

      li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_annual_change' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).annual_change;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    -- hr_utility.trace('setting  p_annual_change ' || p_ltt_salary_data(1).annual_change);


     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_proposal_reason' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).proposal_reason;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_currency' ;
     gtt_trans_steps(li_count).param_value :=
       p_ltt_salary_data(1).currency;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_pay_basis_name' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).pay_basis_name;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_annual_equivalent' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).annual_equivalent;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_total_percent' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).total_percent;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_selection_mode' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).selection_mode;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_quartile' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).quartile;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    -- hr_utility.trace('setting  p_quartile ' || p_ltt_salary_data(1).quartile);

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_comparatio' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).comparatio;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     -- hr_utility.trace('setting  p_comparatio ' || p_ltt_salary_data(1).comparatio);

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_ranking' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).ranking;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;


     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_comments' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).comments;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    -- hr_utility.trace('setting  p_comments ' || p_ltt_salary_data(1).comments);

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_element_entry_id' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).element_entry_id;
     gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

     li_count:= li_count + 1 ;
     gtt_trans_steps(li_count).param_name := 'p_multiple_components' ;
     gtt_trans_steps(li_count).param_value :=
          p_ltt_salary_data(1).multiple_components;
     gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

     -- store flexes here
     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
      := 'p_attribute_category';
     gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute_category;
     gtt_trans_steps(li_count).param_data_type
      := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
      := 'p_no_of_components';
     gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).no_of_components;
     gtt_trans_steps(li_count).param_data_type
      := 'NUMBER';

    -- hr_utility.trace(' p_no_of_components ' || p_ltt_salary_data(1).no_of_components);

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute1';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute1;
     gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute2';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute2;
     gtt_trans_steps(li_count).param_data_type
         := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute3';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute3;
     gtt_trans_steps(li_count).param_data_type
       := 'VARCHAR2';


     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute4';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute4;
     gtt_trans_steps(li_count).param_data_type
         := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute5';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute5;
     gtt_trans_steps(li_count).param_data_type
         := 'VARCHAR2';

     li_count := li_count + 1 ;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute6';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute6;
     gtt_trans_steps(li_count).param_data_type
         := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute7';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute7;
     gtt_trans_steps(li_count).param_data_type
         := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute8';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute8;
     gtt_trans_steps(li_count).param_data_type
         := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute9';
     gtt_trans_steps(li_count).param_value
        := p_ltt_salary_data(1).attribute9;
     gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute10';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute10;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute11';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute11;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute12';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute12;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute13';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute13;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute14';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute14;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute15';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute15;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute16';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute16;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

     li_count := li_count + 1;
     gtt_trans_steps(li_count).param_name
       := 'p_attribute17';
     gtt_trans_steps(li_count).param_value
       := p_ltt_salary_data(1).attribute17;
     gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute18';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute18;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute19';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute19;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    li_count := li_count + 1;
    gtt_trans_steps(li_count).param_name
      := 'p_attribute20';
    gtt_trans_steps(li_count).param_value
      := p_ltt_salary_data(1).attribute20;
    gtt_trans_steps(li_count).param_data_type
        := 'VARCHAR2';

    -- hr_utility.trace('Populated Proposal Values ');
    -- store components record here
    -- each component record will be stored as individual parameters with
    -- suffix no identifying the record number
    -- for example, component row 1 will be stored as component_id1,
    -- change_amount1, change_percent1 etc.

   -- ln_no_of_components := p_ltt_component.count - 1 ;
   -- ln_no_of_components := to_number(p_ltt_salary_data(1).comments);

    ln_no_of_components := p_ltt_salary_data(1).no_of_components;


    li_count:= li_count +1 ;
    gtt_trans_steps(li_count).param_name := 'p_no_of_components' ;
    gtt_trans_steps(li_count).param_value := ln_no_of_components ;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    --insert into dev_test values (' Written Proposal Values ');
    message := ' ln_no_of_components =' || ln_no_of_components;
    --insert into dev_test values (' Written Proposal Values ');
    -- commit;

    -- hr_utility.trace('No Of Components' || ln_no_of_components);
    FOR i in 1..ln_no_of_components
    LOOP
      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_approved'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).approved ;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_component_reason'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).component_reason ;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_reason_meaning'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).reason_meaning ;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_change_amount'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).change_amount ;
      gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_change_percent'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).change_percent ;
      gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;


      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_change_annual'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).change_annual ;
      gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_comments'||i ;
      gtt_trans_steps(li_count).param_value:= p_ltt_component(i).comments;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute_category'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute_category;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;


      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute1'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute1;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute2'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute2;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute3'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute3;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute4'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute4;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute5'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute5;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute6'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute6;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute7'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute7;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;


      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute8'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute8;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;


      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute9'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute9;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute10'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute10;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute11'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute11;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute12'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute12;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute13'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute13;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute14'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute14;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute15'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute15;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute16'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute16;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute17'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute17;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute18'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute18;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute19'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute19;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

      li_count := li_count + 1 ;
      gtt_trans_steps(li_count).param_name := 'p_cattribute20'||i ;
      gtt_trans_steps(li_count).param_value:=
        p_ltt_component(i).attribute20;
      gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    END LOOP ; -- components loop end here


    -- 04/12/02 Salary Basis Enhancement Begins
    -- The following are the output parameters from the call to my_get_defaults
    -- in process_salary_java procedure.
    -- The literal "default" stands for "output parameters from the
    -- my_get_defaults call.
    -- We need to save the output parameters with the prefix of default is
    -- because we want to avoid duplicate name, such as p_comparatio which
    -- is saved in the beginning of the procedure, from being saved into
    -- the transaction table.

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_salary_basis_change_type';
    gtt_trans_steps(li_count).param_value :=
               p_ltt_salary_data(1).salary_basis_change_type;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_date';
    gtt_trans_steps(li_count).param_value :=
        to_char(p_ltt_salary_data(1).default_date,
                hr_transaction_ss.g_date_format);
    gtt_trans_steps(li_count).param_data_type := 'DATE' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_bg_id';
    gtt_trans_steps(li_count).param_value := p_ltt_salary_data(1).default_bg_id;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_currency';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_currency;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_format_string';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_format_string;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_salary_basis_name';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_salary_basis_name;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_pay_basis_name';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_pay_basis_name;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_pay_basis';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_pay_basis;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name :=
                      'p_default_pay_annual_factor';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_pay_annual_factor;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_grade';
    gtt_trans_steps(li_count).param_value := p_ltt_salary_data(1).default_grade;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name :=
                      'p_default_grade_annual_factor';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_grade_annual_factor;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_minimum_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_minimum_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_maximum_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_maximum_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_midpoint_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_midpoint_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_prev_salary';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_prev_salary;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_last_change_date';
    gtt_trans_steps(li_count).param_value :=
              to_char(p_ltt_salary_data(1).default_last_change_date,
                      hr_transaction_ss.g_date_format);
    gtt_trans_steps(li_count).param_data_type := 'DATE' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_element_entry_id';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_element_entry_id;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_basis_changed';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_basis_changed;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_uom';
    gtt_trans_steps(li_count).param_value := p_ltt_salary_data(1).default_uom;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_grade_uom';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_grade_uom;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_change_amount';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_change_amount;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_change_percent';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_change_percent;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_quartile';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_quartile;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_comparatio';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_comparatio;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_last_pay_change';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_last_pay_change;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_flsa_status';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_flsa_status;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_currency_symbol';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_currency_symbol;
    gtt_trans_steps(li_count).param_data_type := 'VARCHAR2' ;

    li_count := li_count + 1 ;
    gtt_trans_steps(li_count).param_name := 'p_default_precision';
    gtt_trans_steps(li_count).param_value :=
                          p_ltt_salary_data(1).default_precision;
    gtt_trans_steps(li_count).param_data_type := 'NUMBER' ;


    -- 04/12/02 Salary Basis Enhancement Ends

    --insert into dev_test values (' prepared component values for writing to Txn Tables');
    --commit;

   -- hr_utility.trace('Populated Component values in Global Struct');

/********
    -- check if there is a txn for this transaction
    ln_transaction_id :=
      hr_transaction_ss.get_transaction_id
      (p_Item_Type => p_item_type
      ,p_Item_Key => p_item_key);

    hr_utility.trace('No Txn Exists' || ln_transaction_id);
    -- insert into dev_test values (' Txn does not exist in Maintain function');
    --commit;

    -- if txn is not started , create a new one
    IF ln_transaction_id IS NULL
    THEN
    hr_utility.set_location(l_proc,10);
       hr_utility.trace('Start Txn' );

        start_transaction(p_item_type
                           ,p_item_key
                           ,p_act_id
                           ,'RUN'
                           ,ln_creator_person_id
                           ,result );

       hr_utility.trace('Started Txn with result '||result);
       -- insert into dev_test values (' result of start_transaction' || lv_result);
       -- commit;

      ln_transaction_id :=
        hr_transaction_ss.get_transaction_id
          (p_Item_Type => p_item_type
          ,p_Item_Key => p_item_key);

        --insert into dev_test values (' ln_transaction_id = ' || ln_transaction_id);
       -- commit;
    END IF;




     hr_utility.trace('Created Txn' || ln_transaction_id);
    --insert into dev_test values (' Created Txn');
    --commit;

     -- now we have a valid txn id , let's find out txn steps
     hr_transaction_api.get_transaction_step_info
       (p_Item_Type     => p_item_type
       ,p_Item_Key      => p_item_key
       ,p_activity_id   => p_act_id
       ,p_transaction_step_id => ltt_trans_step_ids
       ,p_object_version_number => ltt_trans_obj_vers_num
       ,p_rows                  => ln_trans_step_rows);

     hr_utility.trace('get_transaction_step_info completed');

     IF ln_trans_step_rows < 1 THEN
     hr_utility.set_location(l_proc,15);

       --There is no transaction step for this transaction.
       --Create a step within this new transaction

       hr_utility.trace('create_transaction_step ');

       hr_transaction_api.create_transaction_step
	   (p_validate => false
        ,p_creator_person_id => ln_creator_person_id
	    ,p_transaction_id => ln_transaction_id
	    ,p_api_name => lv_api_name
	    ,p_Item_Type => p_item_type
	    ,p_Item_Key => p_item_key
	    ,p_activity_id => p_act_id
	    ,p_transaction_step_id => ln_transaction_step_id
        ,p_object_version_number =>ln_ovn ) ;

        hr_utility.trace('ln_transaction_id ' || ln_transaction_id);
         hr_utility.trace('ln_transaction_step_id ' || ln_transaction_step_id);
     ELSE

hr_utility.set_location(l_proc,20);
       --There are transaction steps for this transaction.
       --Get the Transaction Step ID for this activity.

         hr_utility.trace('Txn Step Id'|| ln_transaction_step_id);
       ln_transaction_step_id :=
         hr_Transaction_ss.get_activity_trans_step_id (
	       p_activity_name => lv_activity_name,
	       p_trans_step_id_tbl => ltt_trans_step_ids);

     END IF;

     message := '';
     FOR i in 1..li_count
     LOOP
        message := message || gtt_trans_steps(i).param_value;
     END LOOP;

       hr_utility.trace('GLOBAL STRUCTURE' || message );

    --insert into dev_test values (' created Txn Step');
    --commit;
************/

     -- save the txn data
     --hr_transaction_ss.save_transaction_step(

      -- hr_utility.trace('Create Transaction and Transaction Step ');

      open  get_transaction_step_id
        (c_item_type => p_item_type
        ,c_item_key => p_item_key
        );

      fetch get_transaction_step_id into ln_transaction_step_id;
      close get_transaction_step_id;

      -- hr_utility.trace(' existing ln_transaction_step_id ' || ln_transaction_step_id);

      hr_transaction_ss.save_transaction_step(
       p_Item_Type              => p_item_type
       ,p_Item_Key              => p_item_key
       ,p_ActID                 => p_act_id
       ,p_login_person_id       => ln_creator_person_id
       ,p_transaction_step_id   => ln_transaction_step_id
       ,p_transaction_data      => gtt_trans_steps
       ,p_api_name              => lv_api_name
       ,p_plan_id               => p_plan_id
       ,p_rptg_grp_id           => p_rptg_grp_id
       ,p_effective_date_option => p_effective_date_option);


      -- hr_utility.trace(' Transaction Step Id ' || ln_transaction_step_id );

      --  hr_utility.trace('Saved Txn Steps to Txn Tables');
       --insert into dev_test values (' written values to Txn Tables');
    --commit;
     -- transaction data has been stored ,
     -- transition this activity
     -- hr_mee_workflow_service.transition_activity
     --   (p_item_type => p_item_type
     --   ,p_item_key => p_item_key
     --   ,p_actid => p_act_id
     --   ,p_result_code => 'NEXT');


      p_step_id := ln_transaction_step_id;

      hr_utility.set_location(' Leaving:' || l_proc,25);
     EXCEPTION
       WHEN OTHERS THEN
         message := 'Exception in maintain_txn_java' || SQLERRM;

        -- hr_utility.trace(message);
	hr_utility.set_location(' Leaving:' || l_proc,555);
         raise;
         --insert into dev_test values(message);
         --commit;
   END maintain_txn_java;


   PROCEDURE process_salary_java (
     p_item_type 	    IN     VARCHAR ,
     p_item_key  	    IN     VARCHAR2 ,
     p_act_id    	    IN     VARCHAR2 ,
     ltt_salary_data        IN OUT NOCOPY sshr_sal_prop_tab_typ,
     ltt_component          IN OUT NOCOPY sshr_sal_comp_tab_typ,
     p_api_mode             IN     VARCHAR2,
     p_review_proc_call     IN     VARCHAR2,
     p_save_mode            IN     VARCHAR2,
     p_flow_mode            in out nocopy varchar2,  -- 2355929
     p_step_id                 OUT NOCOPY NUMBER,
     p_warning_msg_name     IN OUT NOCOPY varchar2,
     p_error_msg_text       IN OUT NOCOPY varchar2,
     p_rptg_grp_id          IN VARCHAR2 DEFAULT NULL,
     p_plan_id              IN VARCHAR2 DEFAULT NULL,
     p_effective_date_option IN VARCHAR2  DEFAULT NULL
  )
  IS

l_proc varchar2(200) := g_package || 'process_salary_java';
    --ltt_salary_data    ltt_salary ;
    --ltt_component      ltt_components ;
    ln_count           NUMBER ;
    i                  NUMBER ;
    lv_message_number  VARCHAR2(80);
    lv_action_value    VARCHAR2(30);
    ln_transaction_id  NUMBER ;
    ln_transaction_step_id NUMBER ;
    message VARCHAR2(5000) := '';
    ln_assignment_id           per_all_assignments_f.assignment_id%type;

    -- 04/19/02 Salary Basis Enhancement Change Begins
    lb_inv_next_sal_date_warning    boolean default false;
    lb_proposed_salary_warning      boolean default false;
    lb_approved_warning             boolean default false;
    lb_payroll_warning              boolean default false;
    ln_save_prev_salary             number default null;
    ln_save_pay_annual_factor       number default null;
    lb_save_point_pay2_exists       boolean default false;
    -- 04/19/02 Salary Basis Enhancement Change Ends

    ln_job_id   number default null;
    ln_fte_factor   number default null;
    ln_grade_basis   varchar2(30)   default null;
    lv_disp_warn_error_max_rate varchar2(20) default null;

  BEGIN

hr_utility.set_location(' Entering:' || l_proc,5);
     -- 04/24/02 Change Begins
     -- Save the previous salary and old pay annualization factor because
     -- my_get_defaults will overwrite these 2 values when a salary basis is
     -- changed and element_type_id is different between the old and the new.
     ln_save_prev_salary := ltt_salary_data(1).default_prev_salary;
     ln_save_pay_annual_factor := ltt_salary_data(1).default_pay_annual_factor;
     -- 04/24/02 Change Ends

     if(p_save_mode = 'SAVE_FOR_LATER') then
       if p_flow_mode is not null and
          p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
       then
       hr_utility.set_location(l_proc,10);
          rollback;
       end if;

        maintain_txn_java(p_item_type   => p_item_type
                         ,p_item_key    => p_item_key
                         ,p_Act_id      => p_Act_id
                         ,p_ltt_salary_data  => ltt_salary_data
                         ,p_ltt_component    => ltt_component
                         ,p_review_proc_call => p_review_proc_call
                         ,p_step_id          => p_step_id
                         ,p_flow_mode        => p_flow_mode
                         ,p_rptg_grp_id      => p_rptg_grp_id
                         ,p_plan_id          => p_plan_id
                         ,p_effective_date_option => p_effective_date_option
                         );
     else

     -- Parameters Passed
     /*
     message := ' PROPOSAL VALUES' ||
                ' p_item_type' || p_item_type                                       ||
                ' p_item_key' || p_item_key                                          ||
                ' p_act_id' || p_act_id                                              ||
                ' pay_proposal_id' || ltt_salary_data(1).pay_proposal_id             ||
                ' assignment_id' || ltt_salary_data(1).assignment_id                 ||
                ' business_group_id' || ltt_salary_data(1).business_group_id         ||
                ' effective_date' || ltt_salary_data(1).effective_date               ||
                ' comments' || ltt_salary_data(1).comments                           ||
                ' next_sal_review_date' || ltt_salary_data(1).next_sal_review_date   ||
                ' salary_change_amount' || ltt_salary_data(1).salary_change_amount   ||
                ' salary_change_percent' || ltt_salary_data(1).salary_change_percent ||
                ' annual_change' || ltt_salary_data(1).annual_change                 ||
                ' proposed_salary' || ltt_salary_data(1).proposed_salary             ||
                ' proposed_percent' || ltt_salary_data(1).proposed_percent           ||
                ' proposal_reason' || ltt_salary_data(1).proposal_reason             ||
                ' ranking' || ltt_salary_data(1).ranking                             ||
                ' current_salary' || ltt_salary_data(1).current_salary               ||
                ' performance_review_id' || ltt_salary_data(1).performance_review_id ||
                ' multiple_components' || ltt_salary_data(1).multiple_components     ||
                ' element_entry_id' || ltt_salary_data(1).element_entry_id           ||
                ' selection_mode' || ltt_salary_data(1).selection_mode               ||
                ' ovn' || ltt_salary_data(1).ovn                                     ||
                ' currency' || ltt_salary_data(1).currency                           ||
                ' pay_basis_name' || ltt_salary_data(1).pay_basis_name               ||
                ' annual_equivalent' || ltt_salary_data(1).annual_equivalent         ||
                ' total_percent' || ltt_salary_data(1).total_percent                 ||
                ' quartile' || ltt_salary_data(1).quartile                           ||
                ' comparatio' || ltt_salary_data(1).comparatio                       ||
                ' lv_selection_mode' || ltt_salary_data(1).lv_selection_mode         ||
                ' attribute_category' || ltt_salary_data(1).attribute_category       ||
                ' attribute1' || ltt_salary_data(1).attribute1                       ||
                ' attribute2' || ltt_salary_data(1).attribute2                       ||
                ' attribute3' || ltt_salary_data(1).attribute3                       ||
                ' attribute4' || ltt_salary_data(1).attribute4                       ||
                ' attribute5' || ltt_salary_data(1).attribute5                       ||
                ' attribute6' || ltt_salary_data(1).attribute6                       ||
                ' attribute7' || ltt_salary_data(1).attribute7                       ||
                ' attribute8' || ltt_salary_data(1).attribute8                       ||
                ' attribute9' || ltt_salary_data(1).attribute9                       ||
                ' attribute10' || ltt_salary_data(1).attribute10                     ||
                ' attribute11' || ltt_salary_data(1).attribute11                     ||
                ' attribute12' || ltt_salary_data(1).attribute12                     ||
                ' attribute13' || ltt_salary_data(1).attribute13                     ||
                ' attribute14' || ltt_salary_data(1).attribute14                     ||
                ' attribute15' || ltt_salary_data(1).attribute15                     ||
                ' attribute16' || ltt_salary_data(1).attribute16                     ||
                ' attribute17' || ltt_salary_data(1).attribute17                     ||
                ' attribute18' || ltt_salary_data(1).attribute18                     ||
                ' attribute19' || ltt_salary_data(1).attribute19                     ||
                ' attribute20' || ltt_salary_data(1).attribute20                     ||
                ' no_of_components' || ltt_salary_data(1).no_of_components  ;

                   hr_utility.trace(message);

              for i in 1 .. ltt_component(i).
             message := ' COMPONENT VALUES' ||
                'component_id'|| ltt_component(i).component_id                  ||
                'pay_proposal_id'|| ltt_component(i).pay_proposal_id            ||
                'approved'|| ltt_component(i).approved                          ||
                'component_reason'|| ltt_component(i).component_reason          ||
                'reason_meaning'|| ltt_component(i).reason_meaning              ||
                'change_amount'|| ltt_component(i).change_amount                ||
                'change_percent'|| ltt_component(i).change_percent              ||
                'change_annual'|| ltt_component(i).change_annual                ||
                'comments'|| ltt_component(i).comments                          ||
                'ovn'|| ltt_component(i).ovn                                    ||
                'attribute_category'|| ltt_component(i).attribute_category      ||
                'attribute1'|| ltt_component(i).attribute1                      ||
                'attribute2'|| ltt_component(i).attribute2                      ||
                'attribute3'|| ltt_component(i).attribute3                      ||
                'attribute4'|| ltt_component(i).attribute4                      ||
                'attribute5'|| ltt_component(i).attribute5                      ||
                'attribute6'|| ltt_component(i).attribute6                      ||
                'attribute7'|| ltt_component(i).attribute7                      ||
                'attribute8'|| ltt_component(i).attribute8                      ||
                'attribute9'|| ltt_component(i).attribute9                      ||
                'attribute10'|| ltt_component(i).attribute10                    ||
                'attribute11'|| ltt_component(i).attribute11                    ||
                'attribute12'|| ltt_component(i).attribute12                    ||
                'attribute13'|| ltt_component(i).attribute13                    ||
                'attribute14'|| ltt_component(i).attribute14                    ||
                'attribute15'|| ltt_component(i).attribute15                    ||
                'attribute16'|| ltt_component(i).attribute16                    ||
                'attribute17'|| ltt_component(i).attribute17                    ||
                'attribute18'|| ltt_component(i).attribute18                    ||
                'attribute19'|| ltt_component(i).attribute19                    ||
                'attribute20'|| ltt_component(i).attribute20                    ||
                'object_version_number'|| ltt_component(i).object_version_number ;

       hr_utility.trace(message);
    */
        --insert into dev_test values (message);
        --commit;

     -- check here for date flex fields format

     -- check here for component date flex fields format
     -- if error , then redisplay form

       -- prepare data to call salary APIs
       -- store components in the table
       -- call salary APIs to validate data
       -- if validation succeeds , store data in txn doc

       -- set a savepoint

       savepoint pay2 ;
       lb_save_point_pay2_exists := TRUE;

       hr_assignment_common_save_web.get_step
         (p_item_type           => p_item_type
         ,p_item_key            => p_item_key
         ,p_api_name            => g_asg_api_name
         ,p_transaction_step_id => ln_transaction_step_id
         ,p_transaction_id      => ln_transaction_id);

       if ln_transaction_step_id is not null then
         -- if an assignment step already exists then apply the
         -- assignment data

         ln_assignment_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_ASSIGNMENT_ID');

         ln_job_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => ln_transaction_step_id
           ,p_name                => 'P_JOB_ID');

         -- Must set the element warning to TRUE so that the ASG wrapper will
         -- not roll back the ASG changes if element_warning = 'TRUE' whenever
         -- there is element entries changed.
         --HR_PROCESS_ASSIGNMENT_SS.PROCESS_API
         --    (p_validate            => FALSE
         --    ,p_transaction_step_id => ln_transaction_step_id
         --    ,p_flow_mode               => p_flow_mode);
         -- Bug 2547283: need to update person info and asg info.
         hr_new_user_reg_ss.process_selected_transaction
                   (p_item_type => p_item_type,
                    p_item_key => p_item_key);
         IF (( hr_process_person_ss.g_assignment_id is not null) and
           (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
         THEN
	 hr_utility.set_location(l_proc,15);
          -- Set the Assignment Id to the one just created, don't use the
           -- transaction table.
             ltt_salary_data(1).assignment_id := hr_process_person_ss.g_assignment_id;
          END IF;
       end if;


       -- 04/12/02 Salary Basis Enhancement Begins
       -- Call my_get_defaults to save the default values to the
       -- transaction table before rolling back.

       ltt_salary_data(1).default_date := ltt_salary_data(1).effective_date;

       my_get_defaults
         (p_assignment_id               => ltt_salary_data(1).assignment_id
         ,p_date                        => ltt_salary_data(1).default_date
         ,p_business_group_id           => ltt_salary_data(1).default_bg_id
         ,p_currency                    => ltt_salary_data(1).default_currency
         ,p_format_string               =>
                               ltt_salary_data(1).default_format_string
         ,p_salary_basis_name           =>
                               ltt_salary_data(1).default_salary_basis_name
         ,p_pay_basis_name              =>
                               ltt_salary_data(1).default_pay_basis_name
         ,p_pay_basis                   => ltt_salary_data(1).default_pay_basis
         ,p_grade_basis                   => ln_grade_basis
         ,p_pay_annualization_factor    =>
                               ltt_salary_data(1).default_pay_annual_factor
         ,p_fte_factor    	=>	ln_fte_factor
         ,p_grade                       => ltt_salary_data(1).default_grade
         ,p_grade_annualization_factor  =>
                               ltt_salary_data(1).default_grade_annual_factor
         ,p_minimum_salary              =>
                               ltt_salary_data(1).default_minimum_salary
         ,p_maximum_salary              =>
                               ltt_salary_data(1).default_maximum_salary
         ,p_midpoint_salary             =>
                               ltt_salary_data(1).default_midpoint_salary
         ,p_prev_salary                 =>
                               ltt_salary_data(1).default_prev_salary
         ,p_last_change_date            =>
                               ltt_salary_data(1).default_last_change_date
         ,p_element_entry_id            =>
                               ltt_salary_data(1).default_element_entry_id
         ,p_basis_changed               =>
                               ltt_salary_data(1).default_basis_changed
         ,p_uom                         => ltt_salary_data(1).default_uom
         ,p_grade_uom                   => ltt_salary_data(1).default_grade_uom
         ,p_change_amount               =>
                               ltt_salary_data(1).default_change_amount
         ,p_change_percent              =>
                               ltt_salary_data(1).default_change_percent
         ,p_quartile                    => ltt_salary_data(1).default_quartile
         ,p_comparatio                  => ltt_salary_data(1).default_comparatio
         ,p_last_pay_change             =>
                               ltt_salary_data(1).default_last_pay_change
         ,p_flsa_status                 =>
                               ltt_salary_data(1).default_flsa_status
         ,p_currency_symbol             =>
                               ltt_salary_data(1).default_currency_symbol
         ,p_precision                   => ltt_salary_data(1).default_precision
         ,p_job_id                      =>  ln_job_id
         );


       -- 04/12/02 Salary Basis Enhancement Begins
       -- Need to set the element_entry_id returned from the my_get_defaults
       -- before calling validate_salary_ins_api_java.  Otherwise, you'll get
       -- the following error:
       -- Procedure hr_entry_api.up_ele_entry_param_val at Step 1.
       -- Cause: The procedure hr_entry_api.up_ele_entry_param_val has created
       --        an error at Step 1.

       ltt_salary_data(1).element_entry_id :=
                ltt_salary_data(1).default_element_entry_id;

       -- Now call validate_salary_ins_api_java which requires an
       -- element entry id existing.

       -- 04/24/02 Change Begins
       -- Always reset the previous salary and old annualization factor
       -- with the values passed in which were saved at the beginning of the
       -- procedure.  The reason is that my_get_defaults will call
       -- per_pay_proposals_populate.get_defaults which will zap the
       -- previous salary to null if element_type_id is different
       -- between the old and the new.
       ltt_salary_data(1).default_prev_salary := ln_save_prev_salary;
       ltt_salary_data(1).default_pay_annual_factor :=ln_save_pay_annual_factor;
       -- 04/24/02 Change Ends


       if (p_api_mode = 'INSERT') then
       hr_utility.set_location(l_proc,20);
        validate_salary_ins_api_java (
           p_item_type          => p_item_type
          ,p_item_key           => p_item_key
          ,p_act_id             => p_act_id
          ,p_ltt_salary_data    => ltt_salary_data
          ,p_ltt_component      => ltt_component
          ,p_validate           => TRUE
          ,p_inv_next_sal_date_warning  => lb_inv_next_sal_date_warning
          ,p_proposed_salary_warning    => lb_proposed_salary_warning
          ,p_approved_warning           => lb_approved_warning
          ,p_payroll_warning            => lb_payroll_warning
        );
       end if;

       -- The following warning message names were obtained from PERWSEPY.fmb.
       IF lb_inv_next_sal_date_warning
       THEN
       hr_utility.set_location(l_proc,25);
          -- Need to construct the output p_warning_msg_name parm with the
          -- following format:
          -- PER,HR_7340_SAL_ASS_TERMINATED|PAY,HR_APP_PROPOS_APP_COMP| .....
          p_warning_msg_name := 'PER,HR_7340_SAL_ASS_TERMINATED|';
       END IF;

       IF lb_proposed_salary_warning
       THEN
       hr_utility.set_location(l_proc,30);
       -- fix for bug#2826852
       -- new config option
       -- get the activity attribute  DISP_WARN_ERROR_PAY_RATE
         lv_disp_warn_error_max_rate:= wf_engine.GetActivityAttrText(itemtype =>p_item_type,
                                       itemkey =>p_item_key,
                                       actid =>p_act_id,
                                       aname =>'DISP_WARN_ERROR_PAY_RATE',
                                       ignore_notfound =>true);
            if(lv_disp_warn_error_max_rate='WARNING') then
                p_warning_msg_name := p_warning_msg_name ||
                                     'PAY,HR_SAL_SAL_ELE_RANGE_WARN|';
            elsif(lv_disp_warn_error_max_rate='ERROR') then
                hr_utility.set_message(801, 'HR_SAL_SAL_ELE_RANGE_WARN');
                raise g_exceeded_grade_range;
             end if;
       END IF;

       IF lb_approved_warning
       THEN
       hr_utility.set_location(l_proc,35);
          p_warning_msg_name := p_warning_msg_name ||
                                'PAY,HR_APP_PROPOS_APP_COMP|';
       END IF;

       IF lb_payroll_warning
       THEN
       hr_utility.set_location(l_proc,40);
          p_warning_msg_name := p_warning_msg_name ||
                                'PER,HR_SAL_PAYROLL_PERIOD_CLOSED|';
       END IF;


       rollback to pay2 ;
       lb_save_point_pay2_exists := false;

        -- hr_utility.trace('Validated Proposal and Components');

       -- 05/03/02 Salary Basis Enhancement Begins

       --start registration
       -- This is to rollback the dummy person created during the process
       -- request phase of the assignment page for the new user registration.
       -- The rollback is only for New Hire, not for Applicant Hire because
       -- there is no dummy person created in Applicant Hire in the txn.
       IF p_flow_mode is not null and
          p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
       THEN
       hr_utility.set_location(l_proc,45);
          rollback;
       END IF;
       --end registration

       -- Pass the default value obtained from my_get_defaults to
       -- maintain_txn_java in order to be saved to the txn table.

       maintain_txn_java (
         p_item_type                 => p_item_type
        ,p_item_key                  => p_item_key
        ,p_act_id                    => p_act_id
        ,p_ltt_salary_data           => ltt_salary_data
        ,p_ltt_component             => ltt_component
        ,p_review_proc_call          => p_review_proc_call
        ,p_step_id                   => p_step_id
        ,p_flow_mode                 => p_flow_mode
        ,p_rptg_grp_id               => p_rptg_grp_id
        ,p_plan_id                   => p_plan_id
        ,p_effective_date_option     => p_effective_date_option
        );

       -- hr_utility.trace('End of process_salary_java');
       -- hr_utility.trace_off;
      END IF; -- end of save for later

hr_utility.set_location(' Leaving:' || l_proc,50);
     EXCEPTION
     WHEN hr_utility.hr_error THEN
          p_error_msg_text := hr_message.get_message_text;

          --start registration
          -- This is to rollback the dummy person created during the process
          -- request phase of the assignment page for the new user registration.
          -- The rollback is only for New Hire, not for Applicant Hire because
          -- there is no dummy person created in Applicant Hire in the txn.
          IF p_flow_mode is not null and
             p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
          THEN
             rollback;
          END IF;
          --end registration

          IF lb_save_point_pay2_exists
          THEN
             rollback;
          END IF;
	  hr_utility.set_location(' Leaving:' || l_proc,555);

     WHEN g_exceeded_grade_range THEN
          p_error_msg_text :=      hr_util_misc_web.return_msg_text(
                 p_message_name=>'HR_SAL_SAL_ELE_RANGE_WARN',
                 p_Application_id=>'PAY');

          --start registration
          -- This is to rollback the dummy person created during the process
          -- request phase of the assignment page for the new user registration.
          -- The rollback is only for New Hire, not for Applicant Hire because
          -- there is no dummy person created in Applicant Hire in the txn.

          IF p_flow_mode is not null and
             p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
          THEN
             rollback;
          END IF;
          --end registration

          IF lb_save_point_pay2_exists
          THEN
             rollback;
          END IF;
	  hr_utility.set_location(' Leaving:' || l_proc,560);

     WHEN OTHERS THEN
          p_error_msg_text := hr_message.get_message_text;

          --start registration
          -- This is to rollback the dummy person created during the process
          -- request phase of the assignment page for the new user registration.
          -- The rollback is only for New Hire, not for Applicant Hire because
          -- there is no dummy person created in Applicant Hire in the txn.

          IF p_flow_mode is not null and
             p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
          THEN
             rollback;
          END IF;
          --end registration

          IF lb_save_point_pay2_exists
          THEN
             rollback;
          END IF;
	  hr_utility.set_location(' Leaving:' || l_proc,565);

  END process_salary_java ;

  -- ---------------------------------------------------------
  -- Procedure to get salary details from transaction tables
  -- --------------------------------------------------------------
  PROCEDURE get_transaction_details (
    p_item_type       IN wf_items.item_type%type ,
    p_item_key        IN wf_items.item_key%TYPE ,
    p_Act_id          IN VARCHAR2,
    p_ltt_salary_data IN OUT NOCOPY sshr_sal_prop_tab_typ,
    p_ltt_component   IN OUT NOCOPY sshr_sal_comp_tab_typ ) IS

l_proc varchar2(200) := g_package || 'get_transaction_details';
    ln_transaction_step_id NUMBER;
    ln_transaction_id      hr_api_transactions.transaction_id%TYPE;
    ltt_trans_step_ids     hr_util_web.g_varchar2_tab_type;
    ltt_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
    ln_trans_step_rows     NUMBER  ;
    lv_activity_name       wf_item_activity_statuses_v.activity_name%type ;
    ln_no_of_components    NUMBER ;
    i                      INTEGER ;
    lv_activity_display_name VARCHAR2(100);
   BEGIN
   hr_utility.set_location(' Entering:' || l_proc,5);

       -- hr_utility.trace_on(null,'dev_log');



     ln_transaction_id := hr_transaction_ss.get_transaction_id
                             (p_Item_Type   => p_item_type,
                              p_Item_Key    => p_item_key);

      IF ln_transaction_id IS NOT NULL
      THEN
hr_utility.set_location(l_proc,10);
        -- hr_utility.trace('Transaction Exists');
        hr_transaction_api.get_transaction_step_info
                   (p_Item_Type   => p_item_type,
                    p_Item_Key    => p_item_key,
                    p_activity_id =>p_act_id,
                    p_transaction_step_id => ltt_trans_step_ids,
                    p_object_version_number => ltt_trans_obj_vers_num,
                    p_rows                  => ln_trans_step_rows);


        -- if no transaction steps are found , return
        IF ln_trans_step_rows < 1
        THEN
	hr_utility.set_location(' Leaving:' || l_proc,15);
          -- hr_utility.trace('no transaction steps are found ');
          RETURN ;
        ELSE
hr_utility.set_location(l_proc,20);
         -- hr_utility.trace(' Transaction Step Found');
          hr_mee_workflow_service.get_activity_name
                (p_item_type  => p_item_type
                ,p_item_key   => p_item_key
                ,p_actid      => p_act_id
                ,p_activity_name => lv_activity_name
                ,p_activity_display_name => lv_activity_display_name);

          ln_transaction_step_id  :=
          hr_transaction_ss.get_activity_trans_step_id
          (p_activity_name =>lv_activity_name,
           p_trans_step_id_tbl => ltt_trans_step_ids);

          -- hr_utility.trace(' ln_transaction_step_id ' || ln_transaction_step_id);

          -- now get the individual salary data
          p_ltt_salary_data(1).current_salary :=
          hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_current_salary');

          -- hr_utility.trace(' p_current_salary ' || p_ltt_salary_data(1).current_salary);

          p_ltt_salary_data(1).assignment_id :=
          hr_transaction_api.get_number_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_assignment_id');



          p_ltt_salary_data(1).business_group_id :=
          hr_transaction_api.get_number_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_bus_group_id');

        --  hr_utility.trace(' p_bus_group_id ' || p_ltt_salary_data(1).business_group_id);

          p_ltt_salary_data(1).effective_date :=
          hr_transaction_api.get_date_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_effective_date');

          -- GSP change
          p_ltt_salary_data(1).salary_effective_date :=
          hr_transaction_api.get_date_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_effective_date');

          p_ltt_salary_data(1).gsp_dummy_txn :=
          hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_gsp_dummy_txn');
          --End of GSP change

          p_ltt_salary_data(1).salary_change_amount:=
          hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_transaction_step_id,
                    p_name =>'p_change_amount');

         --  hr_utility.trace(' p_change_amount ' || p_ltt_salary_data(1).salary_change_amount);

          p_ltt_salary_data(1).annual_change:=
          hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_transaction_step_id,
                    p_name =>'p_annual_change');

         -- hr_utility.trace(' p_annual_change ' || p_ltt_salary_data(1).annual_change);


          p_ltt_salary_data(1).salary_change_percent:=
          hr_transaction_api.get_number_value
                     (p_transaction_step_id => ln_transaction_step_id,
                      p_name =>'p_change_percent');

          p_ltt_salary_data(1).proposed_salary:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_proposed_salary');

          p_ltt_salary_data(1).proposal_reason:=
            hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_proposal_reason');

          p_ltt_salary_data(1).currency:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_currency');


          p_ltt_salary_data(1).pay_basis_name:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_pay_basis_name');

          p_ltt_salary_data(1).element_entry_id:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_element_entry_id');


          p_ltt_salary_data(1).annual_equivalent:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_annual_equivalent');


          p_ltt_salary_data(1).total_percent:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_total_percent');

          p_ltt_salary_data(1).selection_mode:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_selection_mode');

          p_ltt_salary_data(1).quartile:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_quartile');

          p_ltt_salary_data(1).comparatio:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_comparatio');

          p_ltt_salary_data(1).ranking:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_ranking');


          p_ltt_salary_data(1).multiple_components:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_multiple_components');


          p_ltt_salary_data(1).comments:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_comments');


          p_ltt_salary_data(1).attribute_category :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute_category'
            );

          p_ltt_salary_data(1).attribute1 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute1'
            );

        -- hr_utility.trace(' p_attribute1 ' || p_ltt_salary_data(1).attribute1);

         p_ltt_salary_data(1).attribute2 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute2'
            );

        --   hr_utility.trace(' p_attribute2 ' || p_ltt_salary_data(1).attribute2);

         p_ltt_salary_data(1).attribute3 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute3'
            );

         p_ltt_salary_data(1).attribute4 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute4'
            );


         p_ltt_salary_data(1).attribute5 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute5'
            );

         p_ltt_salary_data(1).attribute6 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute6'
            );


         p_ltt_salary_data(1).attribute7 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute7'
            );

         p_ltt_salary_data(1).attribute8 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute8'
            );

         p_ltt_salary_data(1).attribute9 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute9'
            );

         p_ltt_salary_data(1).attribute10 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute10'
            );

         p_ltt_salary_data(1).attribute11 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute11'
            );

         p_ltt_salary_data(1).attribute12 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute12'
            );

         p_ltt_salary_data(1).attribute13 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute13'
            );

         p_ltt_salary_data(1).attribute14 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute14'
            );

         p_ltt_salary_data(1).attribute15 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute15'
            );

         p_ltt_salary_data(1).attribute16 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute16'
            );


         p_ltt_salary_data(1).attribute17 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute17'
            );

         p_ltt_salary_data(1).attribute18 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute18'
            );

         p_ltt_salary_data(1).attribute19 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute19'
            );

         p_ltt_salary_data(1).attribute20 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute20'
            );

         p_ltt_salary_data(1).no_of_components :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_no_of_components'
            );

         -- 04/12/02 Salary Basis Enhancement Begins
         p_ltt_salary_data(1).salary_basis_change_type :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_salary_basis_change_type'
            );

         p_ltt_salary_data(1).default_date :=
            hr_transaction_api.get_date_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_date'
            );

         p_ltt_salary_data(1).default_bg_id :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_bg_id'
            );

         p_ltt_salary_data(1).default_currency :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_currency'
            );

         p_ltt_salary_data(1).default_format_string :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_format_string'
            );

         p_ltt_salary_data(1).default_salary_basis_name :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_salary_basis_name'
            );

         p_ltt_salary_data(1).default_pay_basis_name :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_pay_basis_name'
            );

         p_ltt_salary_data(1).default_pay_basis :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_pay_basis'
            );

         p_ltt_salary_data(1).default_pay_annual_factor :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_pay_annual_factor'
            );

         p_ltt_salary_data(1).default_grade :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_grade'
            );

         p_ltt_salary_data(1).default_grade_annual_factor :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_grade_annual_factor'
            );

         p_ltt_salary_data(1).default_minimum_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_minimum_salary'
            );

         p_ltt_salary_data(1).default_maximum_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_maximum_salary'
            );

         p_ltt_salary_data(1).default_midpoint_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_midpoint_salary'
            );

         p_ltt_salary_data(1).default_prev_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_prev_salary'
            );

         p_ltt_salary_data(1).default_last_change_date :=
            hr_transaction_api.get_date_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_last_change_date'
            );

         p_ltt_salary_data(1).default_element_entry_id :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_element_entry_id'
            );

         p_ltt_salary_data(1).default_basis_changed :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_basis_changed'
            );

         p_ltt_salary_data(1).default_uom :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_uom'
            );

         p_ltt_salary_data(1).default_grade_uom :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_grade_uom'
            );

         p_ltt_salary_data(1).default_change_amount :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_change_amount'
            );

         p_ltt_salary_data(1).default_change_percent :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_change_percent'
            );

         p_ltt_salary_data(1).default_quartile :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_quartile'
            );

         p_ltt_salary_data(1).default_comparatio :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_comparatio'
            );

         p_ltt_salary_data(1).default_last_pay_change :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_last_pay_change'
            );

         p_ltt_salary_data(1).default_flsa_status :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_flsa_status'
            );

         p_ltt_salary_data(1).default_currency_symbol :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_currency_symbol'
            );

         p_ltt_salary_data(1).default_precision :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_precision'
            );

         -- 04/12/02 Salary Basis Enhancement Ends'

        --   hr_utility.trace('Populated Proposal Values');

          -- now get the component records
          ln_no_of_components :=
          hr_transaction_api.get_number_value
                        (p_transaction_step_id => ln_transaction_step_id,
                         p_name => 'p_no_of_components');

        --  hr_utility.trace('ln_no_of_components' || ln_no_of_components);

          FOR  i in 1..ln_no_of_components
          LOOP

           -- hr_utility.trace(' Retrieving ' || i || ' compoent ');
            p_ltt_component(i).change_amount :=
            hr_transaction_api.get_number_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_change_amount'||i);
          --  hr_utility.trace('change_amount ' || p_ltt_component(i).change_amount);



            p_ltt_component(i).component_reason :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_component_reason'||i);
          --  hr_utility.trace('p_component_reason ' || p_ltt_component(i).component_reason);

            p_ltt_component(i).reason_meaning :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_reason_meaning'||i);
           -- hr_utility.trace('p_reason_meaning ' || p_ltt_component(i).reason_meaning);

    /*
              hr_misc_web.get_lookup_meaning(
                p_ltt_component(i).component_reason,
                'PROPOSAL_REASON',
                p_ltt_salary_data(1).effective_date);
            hr_utility.trace('reason_meaning ' || p_ltt_component(i).reason_meaning);
    */

            p_ltt_component(i).change_percent :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name => 'p_change_percent'||i);

             --    hr_utility.trace('p_change_percent ' || p_ltt_component(i).change_percent);

            p_ltt_component(i).change_annual :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name => 'p_change_annual'||i);

            p_ltt_component(i).comments :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_comments'||i);


            p_ltt_component(i).approved :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_approved'||i);

            p_ltt_component(i).attribute_category :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute_category'||i);

            p_ltt_component(i).attribute1 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute1'||i);

                   --    hr_utility.trace('p_cattribute1 ' || p_ltt_component(i).attribute1);


            p_ltt_component(i).attribute2:=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute2'||i);

           --  hr_utility.trace('p_cattribute1 ' || p_ltt_component(i).attribute2);


            p_ltt_component(i).attribute3 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute3'||i);

            --   hr_utility.trace('p_cattribute1 ');

            p_ltt_component(i).attribute4 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute4'||i);

            p_ltt_component(i).attribute5 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute5'||i);

              --  hr_utility.trace('p_cattribute5 ');

            p_ltt_component(i).attribute6 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute6'||i);

            p_ltt_component(i).attribute7 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute7'||i);

              --   hr_utility.trace('p_cattribute7 ');


            p_ltt_component(i).attribute8 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute8'||i);

            p_ltt_component(i).attribute9 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute9'||i);

               --     hr_utility.trace('p_cattribute9 ');

            p_ltt_component(i).attribute10 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute10'||i);

            p_ltt_component(i).attribute11 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute11'||i);

            p_ltt_component(i).attribute12 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute12'||i);

               --     hr_utility.trace('p_cattribute12 ');

            p_ltt_component(i).attribute13 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute13'||i);

            p_ltt_component(i).attribute14 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute14'||i);

                --   hr_utility.trace('p_cattribute14 ');

            p_ltt_component(i).attribute15 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute15'||i);

            p_ltt_component(i).attribute16 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute16'||i);

                --  hr_utility.trace('p_cattribute16 ');

            p_ltt_component(i).attribute17 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute17'||i);

            p_ltt_component(i).attribute18 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute18'||i);

                --  hr_utility.trace('p_cattribute18 ');

            p_ltt_component(i).attribute19 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute19'||i);

            p_ltt_component(i).attribute20 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute20'||i);

                --   hr_utility.trace('p_cattribute20 ' || p_ltt_component(i).attribute20);

          END LOOP ;

        END IF ;
     END IF ;


hr_utility.set_location(' Leaving:' || l_proc,25);
      -- hr_utility.trace_off;

     EXCEPTION
     WHEN OTHERS THEN
     hr_utility.set_location(' Leaving:' || l_proc,555);
      raise;
   END get_transaction_details;

  --GSP changes
  -- ---------------------------------------------------------
  -- Procedure to get salary details from transaction tables
  -- --------------------------------------------------------------
  PROCEDURE get_txn_details_for_review (
    p_item_type       IN wf_items.item_type%type ,
    p_item_key        IN wf_items.item_key%TYPE ,
    p_transaction_step_id          IN VARCHAR2,
    p_ltt_salary_data IN OUT NOCOPY sshr_sal_prop_tab_typ,
    p_ltt_component   IN OUT NOCOPY sshr_sal_comp_tab_typ ) IS

l_proc varchar2(200) := g_package || 'get_txn_details_for_review';
    ln_transaction_step_id NUMBER;
    ln_transaction_id      hr_api_transactions.transaction_id%TYPE;
    ltt_trans_step_ids     hr_util_web.g_varchar2_tab_type;
    ltt_trans_obj_vers_num hr_util_web.g_varchar2_tab_type;
    ln_trans_step_rows     NUMBER  ;
    lv_activity_name       wf_item_activity_statuses_v.activity_name%type ;
    ln_no_of_components    NUMBER ;
    i                      INTEGER ;
    lv_activity_display_name VARCHAR2(100);
    lv_currency VARCHAR2(10);
    uom PAY_INPUT_VALUES_F.UOM%TYPE;
    return_mask    VARCHAR2(100);

    lv_old_currency                   PAY_ELEMENT_TYPES_F.INPUT_CURRENCY_CODE%TYPE;
    lv_old_salary_basis_name          PER_PAY_BASES.NAME%TYPE;
    lv_old_pay_basis_name             HR_LOOKUPS.MEANING%TYPE;
    lv_old_pay_basis                  PER_PAY_BASES.PAY_BASIS%TYPE;
    ln_old_pay_annual_factor              PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR%TYPE;
    lv_old_grade_basis                    PER_PAY_BASES.RATE_BASIS%TYPE;
    ln_old_grade_annual_factor            PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR%TYPE;
    ln_old_element_type_id            PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
    lv_old_uom                        PAY_INPUT_VALUES_F.UOM%TYPE;
    lv_old_currency_symbol            FND_CURRENCIES_VL.SYMBOL%TYPE;
    lv_tmp_currency 			PAY_ELEMENT_TYPES_F.INPUT_CURRENCY_CODE%TYPE;
    lv_old_fte_factor			number default null;
    l_factor				number default null;

   BEGIN

      hr_utility.set_location(' Entering:' || l_proc,5);
    -- hr_utility.trace('starting of get_transaction_details');

      IF p_transaction_step_id IS NOT NULL
      THEN

hr_utility.set_location(l_proc,10);
          ln_transaction_step_id  := p_transaction_step_id;

	  PER_PAY_PROPOSALS_POPULATE.GET_BASIS_DETAILS(p_effective_date   =>   hr_transaction_api.get_date_value
							                       (p_transaction_step_id => ln_transaction_step_id,
							                        p_name => 'p_effective_date')
                             ,p_assignment_id   => hr_transaction_api.get_number_value
				                  (p_transaction_step_id => ln_transaction_step_id,
				                   p_name => 'p_assignment_id')
                             ,p_currency    => lv_old_currency
                             ,p_salary_basis_name =>  lv_old_salary_basis_name
                             ,p_pay_basis_name =>   lv_old_pay_basis_name
                             ,p_pay_basis  =>  lv_old_pay_basis
                             ,p_pay_annualization_factor => ln_old_pay_annual_factor
                             ,p_grade_basis         => lv_old_grade_basis
                             ,p_grade_annualization_factor => ln_old_grade_annual_factor
                             ,p_element_type_id        => ln_old_element_type_id
                             ,p_uom                   => lv_old_uom);

lv_old_fte_factor :=  per_saladmin_utility.get_fte_factor(
			hr_transaction_api.get_number_value				                 	 (p_transaction_step_id => ln_transaction_step_id,
			  p_name => 'p_assignment_id'),
			hr_transaction_api.get_date_value				                 	 (p_transaction_step_id => ln_transaction_step_id,
			  p_name => 'p_effective_date'));

          lv_currency :=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_currency');

           uom := hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_uom');

          fnd_currency.BUILD_FORMAT_MASK(return_mask, 25, 5, null);

          IF lv_old_currency <> lv_currency THEN
		lv_tmp_currency := lv_old_currency;
          ELSE
		lv_tmp_currency := lv_currency;
          END IF;

          -- now get the individual salary data
          p_ltt_salary_data(1).current_salary :=
          hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name =>'p_current_salary');

          if (uom='N') then
             p_ltt_salary_data(1).curr_sal_mc := to_char(p_ltt_salary_data(1).current_salary,return_mask) || ' ' || lv_tmp_currency;
          else
             p_ltt_salary_data(1).curr_sal_mc := hr_util_misc_ss.get_in_preferred_currency_str(p_ltt_salary_data(1).current_salary,lv_tmp_currency,trunc(sysdate));
          end if;

          p_ltt_salary_data(1).assignment_id :=
          hr_transaction_api.get_number_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_assignment_id');


          p_ltt_salary_data(1).business_group_id :=
          hr_transaction_api.get_number_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_bus_group_id');

          p_ltt_salary_data(1).effective_date :=
          hr_transaction_api.get_date_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_effective_date');

          -- GSP change
          p_ltt_salary_data(1).salary_effective_date :=
          hr_transaction_api.get_date_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_effective_date');

          p_ltt_salary_data(1).gsp_dummy_txn :=
          hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name =>'p_gsp_dummy_txn');
          -- End of GSP change

          p_ltt_salary_data(1).salary_change_amount:=
          hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_transaction_step_id,
                    p_name =>'p_change_amount');

          if (uom='N') then
             if (p_ltt_salary_data(1).salary_change_amount is not null) then
                p_ltt_salary_data(1).chg_amt_mc := to_char(p_ltt_salary_data(1).salary_change_amount,return_mask) || ' ' || lv_currency;
             else
                p_ltt_salary_data(1).chg_amt_mc := null;
             end if;
          else
             p_ltt_salary_data(1).chg_amt_mc := hr_util_misc_ss.get_in_preferred_currency_str(p_ltt_salary_data(1).salary_change_amount,lv_currency,trunc(sysdate));
          end if;

          p_ltt_salary_data(1).annual_change:=
          hr_transaction_api.get_number_value
                   (p_transaction_step_id => ln_transaction_step_id,
                    p_name =>'p_annual_change');


          p_ltt_salary_data(1).salary_change_percent:=
          hr_transaction_api.get_number_value
                     (p_transaction_step_id => ln_transaction_step_id,
                      p_name =>'p_change_percent');

          p_ltt_salary_data(1).proposed_salary:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_proposed_salary');

          if (uom='N') then
           p_ltt_salary_data(1).prop_sal_mc := to_char(p_ltt_salary_data(1).proposed_salary,return_mask) || ' ' || lv_currency;
           else
          p_ltt_salary_data(1).prop_sal_mc := hr_util_misc_ss.get_in_preferred_currency_str(p_ltt_salary_data(1).proposed_salary,lv_currency,trunc(sysdate));
          end if;

          p_ltt_salary_data(1).proposal_reason:=
            hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_proposal_reason');

          p_ltt_salary_data(1).currency:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_currency');

          p_ltt_salary_data(1).pay_basis_name:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_pay_basis_name');

          p_ltt_salary_data(1).element_entry_id:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_element_entry_id');

          p_ltt_salary_data(1).annual_equivalent:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_annual_equivalent');

          if (uom='N') then
           p_ltt_salary_data(1).prop_ann_eqv_mc := to_char(p_ltt_salary_data(1).annual_equivalent,return_mask) || ' ' || lv_currency;
           else
          p_ltt_salary_data(1).prop_ann_eqv_mc := hr_util_misc_ss.get_in_preferred_currency_str(p_ltt_salary_data(1).annual_equivalent,lv_currency,trunc(sysdate));
          end if;

          p_ltt_salary_data(1).total_percent:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_total_percent');

          p_ltt_salary_data(1).selection_mode:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_selection_mode');

          p_ltt_salary_data(1).quartile:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_quartile');

          p_ltt_salary_data(1).comparatio:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_comparatio');

          p_ltt_salary_data(1).ranking:=
                  hr_transaction_api.get_number_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_ranking');

          p_ltt_salary_data(1).multiple_components:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_multiple_components');

          p_ltt_salary_data(1).comments:=
                  hr_transaction_api.get_varchar2_value
                  (p_transaction_step_id => ln_transaction_step_id,
                   p_name => 'p_comments');

          p_ltt_salary_data(1).attribute_category :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute_category'
            );

          p_ltt_salary_data(1).attribute1 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute1'
            );

         p_ltt_salary_data(1).attribute2 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute2'
            );

         p_ltt_salary_data(1).attribute3 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute3'
            );

         p_ltt_salary_data(1).attribute4 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute4'
            );


         p_ltt_salary_data(1).attribute5 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute5'
            );

         p_ltt_salary_data(1).attribute6 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute6'
            );


         p_ltt_salary_data(1).attribute7 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute7'
            );

         p_ltt_salary_data(1).attribute8 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute8'
            );

         p_ltt_salary_data(1).attribute9 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute9'
            );

         p_ltt_salary_data(1).attribute10 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute10'
            );

         p_ltt_salary_data(1).attribute11 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute11'
            );

         p_ltt_salary_data(1).attribute12 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute12'
            );

         p_ltt_salary_data(1).attribute13 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute13'
            );

         p_ltt_salary_data(1).attribute14 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute14'
            );

         p_ltt_salary_data(1).attribute15 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute15'
            );

         p_ltt_salary_data(1).attribute16 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute16'
            );


         p_ltt_salary_data(1).attribute17 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute17'
            );

         p_ltt_salary_data(1).attribute18 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute18'
            );

         p_ltt_salary_data(1).attribute19 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute19'
            );

         p_ltt_salary_data(1).attribute20 :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_attribute20'
            );

         p_ltt_salary_data(1).no_of_components :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_no_of_components'
            );

         -- 04/12/02 Salary Basis Enhancement Begins
         p_ltt_salary_data(1).salary_basis_change_type :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_salary_basis_change_type'
            );

         p_ltt_salary_data(1).default_date :=
            hr_transaction_api.get_date_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_date'
            );

         p_ltt_salary_data(1).default_bg_id :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_bg_id'
            );

         p_ltt_salary_data(1).default_currency :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_currency'
            );

         p_ltt_salary_data(1).default_format_string :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_format_string'
            );

         p_ltt_salary_data(1).default_salary_basis_name :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_salary_basis_name'
            );

         p_ltt_salary_data(1).default_pay_basis_name :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_pay_basis_name'
            );

         p_ltt_salary_data(1).default_pay_basis :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_pay_basis'
            );

         p_ltt_salary_data(1).default_pay_annual_factor :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_pay_annual_factor'
            );

   if ((fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE') is null OR
        fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE') = 'Y') and
	   p_ltt_salary_data(1).default_pay_basis = 'HOURLY') then
      l_factor := p_ltt_salary_data(1).default_pay_annual_factor*lv_old_fte_factor;
   else
      l_factor := p_ltt_salary_data(1).default_pay_annual_factor;
   end if;

          if (uom='N') then
           p_ltt_salary_data(1).curr_ann_eqv_mc := to_char((l_factor*p_ltt_salary_data(1).current_salary),return_mask) || ' ' || lv_tmp_currency;
           else
          p_ltt_salary_data(1).curr_ann_eqv_mc := hr_util_misc_ss.get_in_preferred_currency_str((l_factor*p_ltt_salary_data(1).current_salary),lv_tmp_currency,trunc(sysdate));
          end if;

         p_ltt_salary_data(1).default_grade :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_grade'
            );

         p_ltt_salary_data(1).default_grade_annual_factor :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_grade_annual_factor'
            );

         p_ltt_salary_data(1).default_minimum_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_minimum_salary'
            );

         p_ltt_salary_data(1).default_maximum_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_maximum_salary'
            );

         p_ltt_salary_data(1).default_midpoint_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_midpoint_salary'
            );

         p_ltt_salary_data(1).default_prev_salary :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_prev_salary'
            );

         p_ltt_salary_data(1).default_last_change_date :=
            hr_transaction_api.get_date_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_last_change_date'
            );

         p_ltt_salary_data(1).default_element_entry_id :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_element_entry_id'
            );

         p_ltt_salary_data(1).default_basis_changed :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_basis_changed'
            );

         p_ltt_salary_data(1).default_uom :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_uom'
            );

         p_ltt_salary_data(1).default_grade_uom :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_grade_uom'
            );

         p_ltt_salary_data(1).default_change_amount :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_change_amount'
            );

         p_ltt_salary_data(1).default_change_percent :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_change_percent'
            );

         p_ltt_salary_data(1).default_quartile :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_quartile'
            );

         p_ltt_salary_data(1).default_comparatio :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_comparatio'
            );

         p_ltt_salary_data(1).default_last_pay_change :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_last_pay_change'
            );

         p_ltt_salary_data(1).default_flsa_status :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_flsa_status'
            );

         p_ltt_salary_data(1).default_currency_symbol :=
            hr_transaction_api.get_varchar2_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_currency_symbol'
            );

         p_ltt_salary_data(1).default_precision :=
            hr_transaction_api.get_number_value (
              p_transaction_step_id => ln_transaction_step_id,
              p_name                => 'p_default_precision'
            );

         -- 04/12/02 Salary Basis Enhancement Ends'

          -- now get the component records
          ln_no_of_components :=
          hr_transaction_api.get_number_value
                        (p_transaction_step_id => ln_transaction_step_id,
                         p_name => 'p_no_of_components');

          FOR  i in 1..ln_no_of_components
          LOOP

            --hr_utility.trace(' Retrieving ' || i || ' compoent ');
            p_ltt_component(i).change_amount :=
            hr_transaction_api.get_number_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_change_amount'||i);

            if (uom='N') then
            p_ltt_component(i).chg_amt_mc := to_char(p_ltt_component(i).change_amount,return_mask) || ' ' || lv_currency;
            else
           p_ltt_component(i).chg_amt_mc := hr_util_misc_ss.get_in_preferred_currency_str(p_ltt_component(i).change_amount,lv_currency,trunc(sysdate));
           end if;

            p_ltt_component(i).component_reason :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_component_reason'||i);

            p_ltt_component(i).reason_meaning :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_reason_meaning'||i);
    /*
              hr_misc_web.get_lookup_meaning(
                p_ltt_component(i).component_reason,
                'PROPOSAL_REASON',
                p_ltt_salary_data(1).effective_date);
            hr_utility.trace('reason_meaning ' || p_ltt_component(i).reason_meaning);
    */

            p_ltt_component(i).change_percent :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name => 'p_change_percent'||i);

            p_ltt_component(i).change_annual :=
            hr_transaction_api.get_number_value
                           (p_transaction_step_id => ln_transaction_step_id,
                            p_name => 'p_change_annual'||i);

            p_ltt_component(i).comments :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_comments'||i);

            p_ltt_component(i).approved :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_approved'||i);

            p_ltt_component(i).attribute_category :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute_category'||i);

            p_ltt_component(i).attribute1 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute1'||i);

            p_ltt_component(i).attribute2:=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute2'||i);

            p_ltt_component(i).attribute3 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute3'||i);

            p_ltt_component(i).attribute4 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute4'||i);

            p_ltt_component(i).attribute5 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute5'||i);

              --  hr_utility.trace('p_cattribute5 ');

            p_ltt_component(i).attribute6 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute6'||i);

            p_ltt_component(i).attribute7 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute7'||i);

              --   hr_utility.trace('p_cattribute7 ');


            p_ltt_component(i).attribute8 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute8'||i);

            p_ltt_component(i).attribute9 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute9'||i);

               --     hr_utility.trace('p_cattribute9 ');

            p_ltt_component(i).attribute10 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute10'||i);

            p_ltt_component(i).attribute11 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute11'||i);

            p_ltt_component(i).attribute12 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute12'||i);

               --     hr_utility.trace('p_cattribute12 ');

            p_ltt_component(i).attribute13 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute13'||i);

            p_ltt_component(i).attribute14 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute14'||i);

                --   hr_utility.trace('p_cattribute14 ');

            p_ltt_component(i).attribute15 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute15'||i);

            p_ltt_component(i).attribute16 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute16'||i);

                --  hr_utility.trace('p_cattribute16 ');

            p_ltt_component(i).attribute17 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute17'||i);

            p_ltt_component(i).attribute18 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute18'||i);

                --  hr_utility.trace('p_cattribute18 ');

            p_ltt_component(i).attribute19 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute19'||i);

            p_ltt_component(i).attribute20 :=
            hr_transaction_api.get_varchar2_value
                         (p_transaction_step_id => ln_transaction_step_id,
                          p_name => 'p_cattribute20'||i);

                --   hr_utility.trace('p_cattribute20 ' || p_ltt_component(i).attribute20);

          END LOOP ;

     END IF ;

hr_utility.set_location(' Leaving:' || l_proc,15);
     EXCEPTION
     WHEN OTHERS THEN
      hr_utility.trace('There is an exception in get_transaction_details' || SQLERRM);
      hr_utility.set_location(' Leaving:' || l_proc,555);
      raise;
   END get_txn_details_for_review;
  --End of GSP changes

PROCEDURE PROCESS_API (
    p_transaction_step_id IN hr_api_transaction_steps.transaction_step_id%type,
    p_effective_date      in varchar2,
    p_validate IN boolean
) IS

l_proc varchar2(200) := g_package || 'PROCESS_API';
    ltt_salary_data  sshr_sal_prop_tab_typ;
    ltt_component    sshr_sal_comp_tab_typ;
    lv_item_type     VARCHAR2(100);
    lv_item_key      VARCHAR2(100);
    ln_act_id        NUMBER ;
    message          VARCHAR2(10000);



    -- 04/19/02 Salary Basis Enhancement Change Begins
    lb_inv_next_sal_date_warning    boolean default false;
    lb_proposed_salary_warning      boolean default false;
    lb_approved_warning             boolean default false;
    lb_payroll_warning              boolean default false;
    lv_warning_msg_name             varchar2(8000) default null;
    ln_payroll_id                   per_all_assignments_f.payroll_id%type
                                    default null;
    -- 04/19/02 Salary Basis Enhancement Change Ends
    l_effective_date    VARCHAR2(100) default null;
    ld_effective_date   date default null;


    -- 05/13/02 - Bug 2360907 Fix Begins
    ld_date             date default null;
    -- 05/13/02 - Bug 2360907 Fix Ends

    -- GSP changes
    lc_gsp_assignment varchar2(30) default null;
    -- End of GSP changes

--
l_business_group_id        number;
l_currency    varchar2(250);
l_format_string            varchar2(250);
l_salary_basis_name        varchar2(250);
l_pay_basis_name           varchar2(250);
l_pay_basis                varchar2(250);
l_grade_basis                varchar2(250);
l_pay_annualization_factor              number;
l_fte_factor              number;
l_grade       varchar2(250);
l_grade_annualization_factor            number;
l_minimum_salary           number;
l_maximum_salary           number;
l_midpoint_salary          number;
l_prev_salary              number;
l_last_change_date         date;
l_element_entry_id         number;
l_basis_changed            number;
l_uom         varchar2(250);
l_grade_uom                varchar2(250);
l_change_amount            number;
l_change_percent           number;
l_quartile    number;
l_comparatio               number;
l_last_pay_change          varchar2(250);
l_flsa_status              varchar2(250);
l_currency_symbol          varchar2(250);
l_precision                number;
l_excep_message            varchar2(250);
l_pay_proposal_id          number;
l_current_salary           number;
l_proposal_ovn             number;
l_api_mode    varchar2(250);
l_warning_message          varchar2(250);
l_new_pay_basis_id         number;
l_old_pay_basis_id         number;
l_old_pay_annualization_factor          number;
l_old_fte_factor          number;
l_old_salary_basis_name    varchar2(250);
l_salary_basis_change_type              varchar2(250);
l_flow_mode                 varchar2(250);
l_element_type_id_changed               varchar2(250);
l_old_currency_code        varchar2(250);
l_old_currency_symbol      varchar2(250);
l_old_pay_basis            varchar2(250);
l_old_to_new_currency_rate              number;
l_offered_salary		number;

l_asg_txn_step_id varchar2(250);
l_assignment_id number;
l_get_defaults_date date;
--

  BEGIN
hr_utility.set_location(' Entering:' || l_proc,5);
      if (p_effective_date is not null) then
      hr_utility.set_location(l_proc,10);
        l_effective_date:= p_effective_date;
      else
      hr_utility.set_location(l_proc,15);
        l_effective_date:= hr_transaction_ss.get_wf_effective_date
                             (p_transaction_step_id => p_transaction_step_id);
      end if;

      -- check for GSP assignment
         check_gsp_txn(p_transaction_step_id,l_effective_date,lc_gsp_assignment);
         if( lc_gsp_assignment = 'YES')THEN
             return;
         END IF;
      --end of GSP changes

      savepoint insert_salary_details;

      ltt_salary_data := sshr_sal_prop_tab_typ(sshr_sal_prop_obj_typ(
                null,-- pay_proposal_id       NUMBER,
                null,-- assignment_id         NUMBER,
                null,--business_group_id     NUMBER,
                null,--effective_date        DATE,
                null,--comments              VARCHAR2(2000),
                null,--next_sal_review_date  DATE,
                null,--salary_change_amount  NUMBER ,
                null,--salary_change_percent NUMBER ,
                null,--annual_change         NUMBER ,
                null,--proposed_salary       NUMBER ,
                null,--proposed_percent      NUMBER ,
                null,--proposal_reason       VARCHAR2(30),
                null,--ranking               NUMBER,
                null,--current_salary        NUMBER,
                null,--performance_review_id NUMBER,
                null,--multiple_components   VARCHAR2(1),
                null,--element_entry_id      NUMBER ,
                null,--selection_mode        VARCHAR2(1),
                null,--ovn                   NUMBER,
                null,--currency              VARCHAR2(15),
                null,--pay_basis_name        VARCHAR2(80),
                null,--annual_equivalent     NUMBER ,
                null,--total_percent        NUMBER ,
                null,--quartile              NUMBER ,
                null,--comparatio            NUMBER ,
                null,--lv_selection_mode     VARCHAR2(1),
                null,--attribute_category           VARCHAR2(150),
                null,--attribute1            VARCHAR2(150),
                null,--attribute2            VARCHAR2(150),
                null,--attribute3            VARCHAR2(150),
                null,--attribute4            VARCHAR2(150),
                null,--attribute5            VARCHAR2(150),
                null,--attribute6            VARCHAR2(150),
                null,--attribute7            VARCHAR2(150),
                null,--attribute8            VARCHAR2(150),
                null,--attribute9            VARCHAR2(150),
                null,--attribute10           VARCHAR2(150),
                null,--attribute11           VARCHAR2(150),
                null,--attribute12           VARCHAR2(150),
                null,--attribute13           VARCHAR2(150),
                null,--attribute14           VARCHAR2(150),
                null,--attribute15           VARCHAR2(150),
                null,--attribute16           VARCHAR2(150),
                null,--attribute17           VARCHAR2(150),
                null,--attribute18           VARCHAR2(150),
                null,--attribute19           VARCHAR2(150),
                null,--attribute20           VARCHAR2(150),
                null, --no_of_components       NUMBER,
                -- 04/12/02 Salary Basis Enhancement Begins
                null,  -- salary_basis_change_type varchar2(30)
                null,  -- default_date           date
                null,  -- default_bg_id          number
                null,  -- default_currency       VARCHAR2(15)
                null,  -- default_format_string  VARCHAR2(40)
                null,  -- default_salary_basis_name  varchar2(30)
                null,  -- default_pay_basis_name     varchar2(80)
                null,  -- default_pay_basis      varchar2(30)
                null,  -- default_pay_annual_factor  number
                null,  -- default_grade          VARCHAR2(240)
                null,  -- default_grade_annual_factor number
                null,  -- default_minimum_salary      number
                null,  -- default_maximum_salary      number
                null,  -- default_midpoint_salary     number
                null,  -- default_prev_salary         number
                null,  -- default_last_change_date    date
                null,  -- default_element_entry_id    number
                null,  -- default_basis_changed       number
                null,  -- default_uom                 VARCHAR2(30)
                null,  -- default_grade_uom           VARCHAR2(30)
                null,  -- default_change_amount       number
                null,  -- default_change_percent      number
                null,  -- default_quartile            number
                null,  -- default_comparatio          number
                null,  -- default_last_pay_change     varchar2(200)
                null,  -- default_flsa_status         varchar2(80)
                null,  -- default_currency_symbol     varchar2(4)
                null,   -- default_precision           number
                -- 04/12/02 Salary Basis Enhancement Ends
                -- GSP
                null,    -- salary_effective_date       date
                null,     -- gsp_dummy_txn flag
                --End of GSP
 		null,
 		null,
 		null,
 		null,
 		null
          ));




        ltt_component := sshr_sal_comp_tab_typ(
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null ),
        sshr_sal_comp_obj_typ(
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null )
        );


    hr_transaction_api.get_transaction_step_info(
        p_transaction_step_id => p_transaction_step_id
       ,p_item_type => lv_item_type
       ,p_item_key => lv_item_key
       ,p_activity_id => ln_act_id);

    -- get salary data from txn table
    get_transaction_details ( lv_item_type ,
                         lv_item_key,
                         ln_act_id ,
                         ltt_salary_data ,
                         ltt_component) ;


    -- 04/12/02 Salary Basis Enhancement Begins
    -- start registration
    -- If it's a new user registration flow than the assignmentId which is
    -- coming from transaction table will not be valid because the person
    -- has just been created by the process_api of the
    -- hr_process_person_ss.process_api we can get that person Id and
    -- assignment id by making a call to the global parameters but we need
    -- to branch out the code.

    -- Adding the session id check to avoid connection pooling problems.
    IF (( hr_process_person_ss.g_assignment_id is not null) and
           (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
    THEN
    hr_utility.set_location(l_proc,20);
       -- Set the Assignment Id to the one just created, don't use the
       -- transaction table.
       ltt_salary_data(1).assignment_id := hr_process_person_ss.g_assignment_id;
    END IF;

    l_asg_txn_step_id := p_transaction_step_id;
    l_assignment_id := ltt_salary_data(1).assignment_id;
    l_get_defaults_date := ltt_salary_data(1).default_date;
    ld_effective_date := to_date(l_effective_date,'RRRR-MM-DD');

    begin
    	select VARCHAR2_VALUE into l_flow_mode from hr_api_transaction_values where TRANSACTION_STEP_ID = p_transaction_step_id and NAME = 'P_FLOW_MODE';
    exception
    when no_data_found then
    	l_flow_mode := null;
    end;
    hr_pay_rate_ss.check_asg_txn_data
             (lv_item_type
             ,lv_item_key
             ,ln_act_id
             ,ld_effective_date
             ,l_assignment_id
             ,l_asg_txn_step_id
             ,l_get_defaults_date
             ,l_business_group_id
             ,l_currency
             ,l_format_string
             ,l_salary_basis_name
             ,l_pay_basis_name
             ,l_pay_basis
             ,l_grade_basis
             ,l_pay_annualization_factor
             ,l_fte_factor
             ,l_grade
             ,l_grade_annualization_factor
             ,l_minimum_salary
             ,l_maximum_salary
             ,l_midpoint_salary
             ,l_prev_salary
             ,l_last_change_date
             ,l_element_entry_id
             ,l_basis_changed
             ,l_uom
             ,l_grade_uom
             ,l_change_amount
             ,l_change_percent
             ,l_quartile
             ,l_comparatio
             ,l_last_pay_change
             ,l_flsa_status
             ,l_currency_symbol
             ,l_precision
             ,l_excep_message
             ,l_pay_proposal_id
             ,l_current_salary
             ,l_proposal_ovn
             ,l_api_mode
             ,l_warning_message
             ,l_new_pay_basis_id
             ,l_old_pay_basis_id
             ,l_old_pay_annualization_factor
             ,l_old_fte_factor
             ,l_old_salary_basis_name
             ,l_salary_basis_change_type
             ,l_flow_mode
             ,l_element_type_id_changed
             ,l_old_currency_code
             ,l_old_currency_symbol
             ,l_old_pay_basis
             ,l_old_to_new_currency_rate
             ,l_offered_salary
             ,'N'
              );
    -- 04/12/02 Salary Basis Enhancement Ends

    -- 04/25/02  Salary Basis Enhancement Change Begins
    -- For all scenarios, especially the two listed below:
    --  i) A change in salary basis whereby the element type id is different
    --     between the old and new salary basis
    --  ii)A New Hire flow;
    -- We need to get the element_entry_id
    -- from the database instead of using the one in transaction table
    -- because the element entry id will be different when it comes to
    -- commit the New Hire flow.  Also, in a re-entry of a Save For Later
    -- for a new hire, you will get the following error if we don't get
    -- the element entry id from the database:
    -- Procedure hr_entry_api.upd_ele_entry_param_val at Step 1.
    -- Cause: The procedure hr_entry_api.upd_ele_entry_param_val has created
    --        an error at Step 1.

    -- 05/13/02 - Bug 2360907 Fix Begins
    -- If the input parm p_effective_date is not null,that means it's a re-entry
    -- of a Save For Later transaction and the user has changed the date.  We
    -- should use the l_effective_date which is set to either the input parm
    -- p_effective_date value or the WF effective date.
    ld_date := to_date(l_effective_date,
                       hr_process_assignment_ss.g_date_format);

    PER_PAY_PROPOSALS_POPULATE.get_element_id
          (p_assignment_id     => ltt_salary_data(1).assignment_id
          ,p_business_group_id => ltt_salary_data(1).business_group_id
          ,p_change_date       => ld_date        -- Bug 2360907 Fix
          ,p_payroll_value     => ln_payroll_id
          ,p_element_entry_id  => ltt_salary_data(1).element_entry_id);

    -- 05/13/02 - Bug 2360907 Fix Ends
    -- 04/25/02  Salary Basis Enhancement Change Ends


    -- hr_utility.trace('********* After get_transaction_details *********' );
/*


    message := ' PROPOSAL VALUES' ||
                ' pay_proposal_id' || ltt_salary_data(1).pay_proposal_id             ||
                ' assignment_id' || ltt_salary_data(1).assignment_id                 ||
                ' business_group_id' || ltt_salary_data(1).business_group_id         ||
                ' effective_date' || ltt_salary_data(1).effective_date               ||
                ' comments' || ltt_salary_data(1).comments                           ||
                ' next_sal_review_date' || ltt_salary_data(1).next_sal_review_date   ||
                ' salary_change_amount' || ltt_salary_data(1).salary_change_amount   ||
                ' salary_change_percent' || ltt_salary_data(1).salary_change_percent ||
                ' annual_change' || ltt_salary_data(1).annual_change                 ||
                ' proposed_salary' || ltt_salary_data(1).proposed_salary             ||
                ' proposed_percent' || ltt_salary_data(1).proposed_percent           ||
                ' proposal_reason' || ltt_salary_data(1).proposal_reason             ||
                ' ranking' || ltt_salary_data(1).ranking                             ||
                ' current_salary' || ltt_salary_data(1).current_salary               ||
                ' performance_review_id' || ltt_salary_data(1).performance_review_id ||
                ' multiple_components' || ltt_salary_data(1).multiple_components     ||
                ' element_entry_id' || ltt_salary_data(1).element_entry_id           ||
                ' selection_mode' || ltt_salary_data(1).selection_mode               ||
                ' ovn' || ltt_salary_data(1).ovn                                     ||
                ' currency' || ltt_salary_data(1).currency                           ||
                ' pay_basis_name' || ltt_salary_data(1).pay_basis_name               ||
                ' annual_equivalent' || ltt_salary_data(1).annual_equivalent         ||
                ' total_percent' || ltt_salary_data(1).total_percent                 ||
                ' quartile' || ltt_salary_data(1).quartile                           ||
                ' comparatio' || ltt_salary_data(1).comparatio                       ||
                ' lv_selection_mode' || ltt_salary_data(1).lv_selection_mode         ||
                ' attribute_category' || ltt_salary_data(1).attribute_category       ||
                ' attribute1' || ltt_salary_data(1).attribute1                       ||
                ' attribute2' || ltt_salary_data(1).attribute2                       ||
                ' attribute3' || ltt_salary_data(1).attribute3                       ||
                ' attribute4' || ltt_salary_data(1).attribute4                       ||
                ' attribute5' || ltt_salary_data(1).attribute5                       ||
                ' attribute6' || ltt_salary_data(1).attribute6                       ||
                ' attribute7' || ltt_salary_data(1).attribute7                       ||
                ' attribute8' || ltt_salary_data(1).attribute8                       ||
                ' attribute9' || ltt_salary_data(1).attribute9                       ||
                ' attribute10' || ltt_salary_data(1).attribute10                     ||
                ' attribute11' || ltt_salary_data(1).attribute11                     ||
                ' attribute12' || ltt_salary_data(1).attribute12                     ||
                ' attribute13' || ltt_salary_data(1).attribute13                     ||
                ' attribute14' || ltt_salary_data(1).attribute14                     ||
                ' attribute15' || ltt_salary_data(1).attribute15                     ||
                ' attribute16' || ltt_salary_data(1).attribute16                     ||
                ' attribute17' || ltt_salary_data(1).attribute17                     ||
                ' attribute18' || ltt_salary_data(1).attribute18                     ||
                ' attribute19' || ltt_salary_data(1).attribute19                     ||
                ' attribute20' || ltt_salary_data(1).attribute20                    ;

                   hr_utility.trace(message);
      */


    -- 04/19/02 Salary Basis Enhancement Change Begins
    validate_salary_ins_api_java (
      p_item_type                  => lv_item_type
     ,p_item_key                   => lv_item_key
     ,p_Act_id                     => ln_act_id
     ,p_ltt_salary_data            => ltt_salary_data
     ,p_ltt_component              => ltt_component
     ,p_validate                   => p_validate
     ,p_effective_date             => l_effective_date
     ,p_inv_next_sal_date_warning  => lb_inv_next_sal_date_warning
     ,p_proposed_salary_warning    => lb_proposed_salary_warning
     ,p_approved_warning           => lb_approved_warning
     ,p_payroll_warning            => lb_payroll_warning
    );

    -- hr_utility.trace('After validate_salary_ins_api_java' );

    -- The following warning message names were obtained from PERWSEPY.fmb.
    IF lb_inv_next_sal_date_warning
    THEN
    hr_utility.set_location(l_proc,25);
       -- Need to construct the output p_warning_msg_name parm with the
       -- following format:
       -- PER,HR_7340_SAL_ASS_TERMINATED|PAY,HR_APP_PROPOS_APP_COMP| .....
       lv_warning_msg_name := 'PER,HR_7340_SAL_ASS_TERMINATED|';
    END IF;

    IF lb_proposed_salary_warning
    THEN
    hr_utility.set_location(l_proc,30);
       lv_warning_msg_name := lv_warning_msg_name ||
                             'PAY,HR_SAL_SAL_ELE_RANGE_WARN|';
    END IF;

    IF lb_approved_warning
    THEN
    hr_utility.set_location(l_proc,35);
       lv_warning_msg_name := lv_warning_msg_name ||
                             'PAY,HR_APP_PROPOS_APP_COMP|';
    END IF;

    IF lb_payroll_warning
    THEN
    hr_utility.set_location(l_proc,40);
       lv_warning_msg_name := lv_warning_msg_name ||
                            'PER,HR_SAL_PAYROLL_PERIOD_CLOSED|';
    END IF;

    -- The warnings are for debugging only.  In the actual commit phase, we
    -- don't issue any warnings.

hr_utility.set_location(' Leaving:' || l_proc,45);
  EXCEPTION
  WHEN hr_utility.hr_error THEN
        rollback to insert_salary_details;

hr_utility.set_location(' Leaving:' || l_proc,555);
        -- ---------------------------------------------------
        -- an application error has been raised
        -- ----------------------------------------------------
        RAISE;

  WHEN OTHERS THEN
     ROLLBACK  to insert_salary_details;
hr_utility.set_location(' Leaving:' || l_proc,560);
     RAISE;

  -- 04/19/02 Salary Basis Enhancement Change Ends

  END PROCESS_API;


procedure prate_applicant_hire
  (p_person_id in number,
   p_bg_id    in number,
   p_org_id   in number,
   p_effective_date in date default sysdate,
   p_salaray_basis_id out nocopy varchar,
   p_offered_salary out nocopy varchar,
   p_offered_salary_basis out nocopy varchar
   ) is

   cursor csr_applicant_offer is
   select pay.pay_proposal_id,
          asf.assignment_id,
          asf.pay_basis_id,
          pay.proposed_salary_n,
          pb.name
   from
   per_all_assignments_f asf,
   per_pay_proposals     pay,
   per_pay_bases         pb,
   pay_input_values_f    pv
   where asf.person_id       = p_person_id
    and asf.assignment_type   = 'O'
    and asf.business_group_id = p_bg_id
    and asf.organization_id   = p_org_id
    and p_effective_date between asf.effective_start_date and asf.effective_end_date
    and pay.assignment_id    =asf.assignment_id
    and pb.business_group_id = p_bg_id
    and pb.pay_basis_id      = nvl(asf.pay_basis_id,-1)
    and pb.input_value_id    = pv.input_value_id
    and p_effective_date between pv.effective_start_date and pv.effective_end_date;


   app_offer_row csr_applicant_offer%ROWTYPE;


begin
 -- Default return values
  p_salaray_basis_id :='-1';
  p_offered_salary :='-1';
  p_offered_salary_basis :='-1';



  open csr_applicant_offer;
  fetch csr_applicant_offer into app_offer_row;
  close csr_applicant_offer;

  if app_offer_row.pay_proposal_id is not null then

  p_salaray_basis_id := to_char(app_offer_row.pay_basis_id);

  p_offered_salary := to_char(app_offer_row.proposed_salary_n);

  p_offered_salary_basis := app_offer_row.name;

  end if;

 exception
  when others then
   close csr_applicant_offer;

end prate_applicant_hire;



procedure delete_transaction_step
             (p_transaction_id    in number,
              p_login_person_id   in number ) is

l_proc varchar2(200) := g_package || 'delete_transaction_step';
l_transaction_step_id number;
cursor c1(p_transaction_id number) is
select transaction_step_id
from hr_api_transaction_steps
where transaction_id = p_transaction_id
and api_name = 'HR_PAY_RATE_SS.PROCESS_API';
BEGIN
hr_utility.set_location(' Entering:' || l_proc,5);
open c1(p_transaction_id);
fetch c1 into l_transaction_step_id;
close c1;
HR_TRANSACTION_SS.delete_transaction_step(
  p_transaction_step_id =>l_transaction_step_id,
  p_login_person_id  => p_login_person_id);
  hr_utility.set_location(' Leaving:' || l_proc,10);
END;


END hr_pay_rate_ss;

/
