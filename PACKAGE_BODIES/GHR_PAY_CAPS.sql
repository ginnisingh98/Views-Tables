--------------------------------------------------------
--  DDL for Package Body GHR_PAY_CAPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAY_CAPS" AS
/* $Header: ghpaycap.pkb 120.16.12010000.11 2010/01/22 08:41:05 utokachi ship $ */
--
pay_cap_failed    EXCEPTION;
--
-- This function returns true if the Pay Plan passed in is an 'FW' equivalent
FUNCTION pp_fw_equivalent (p_pay_plan IN VARCHAR2)
  RETURN BOOLEAN IS
CURSOR cur_ppl IS
  SELECT 1
  FROM   ghr_pay_plans ppl
  WHERE  ppl.pay_plan = p_pay_plan
  AND    ppl.equivalent_pay_plan = 'FW';
--
BEGIN
  FOR cur_ppl_rec IN cur_ppl LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
END pp_fw_equivalent;
--

-- This function returns true if the Pay Plan passed in is an 'GS' equivalent
FUNCTION pp_gs_equivalent (p_pay_plan IN VARCHAR2)
  RETURN BOOLEAN IS
CURSOR cur_ppl IS
  SELECT 1
  FROM   ghr_pay_plans ppl
  WHERE  ppl.pay_plan = p_pay_plan
  AND    ppl.equivalent_pay_plan = 'GS';
--
BEGIN
  FOR cur_ppl_rec IN cur_ppl LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
END pp_gs_equivalent;

--This function returns the date of the update 34 implemented for the retained grade employee
FUNCTION update34_implemented_date (p_person_id IN NUMBER)
  RETURN DATE IS
CURSOR cur_update34_date is
  SELECT fnd_date.canonical_to_date(pei_information3) update34_date
  FROM per_people_extra_info
  WHERE information_type = 'GHR_US_PER_UPDATE34'
  AND person_id          = p_person_id;

l_date      DATE := NULL;
--
BEGIN
  FOR cur_update34_date_rec IN cur_update34_date LOOP
      l_date := cur_update34_date_rec.update34_date;
  END LOOP;
--
  RETURN(l_date);
END update34_implemented_date;

--Bug 5482191. Function added for AFHR
FUNCTION get_job_from_pos(p_effective_date  IN   DATE
                         ,p_position_id     IN   NUMBER)
RETURN VARCHAR2 IS
l_job_id   hr_all_positions_f.job_id%TYPE;
l_job_name per_jobs.name%TYPE;
CURSOR cur_pos IS
    SELECT job_id
    FROM   hr_all_positions_f pos
    WHERE  pos.position_id = p_position_id
    AND    p_effective_date BETWEEN pos.effective_start_date and pos.effective_end_date;
CURSOR cur_job IS
    SELECT name
    FROM   per_jobs
    WHERE  job_id = l_job_id;

BEGIN
    FOR cur_pos_rec IN cur_pos
    LOOP
        l_job_id := cur_pos_rec.job_id;
    END LOOP;
    FOR cur_job_rec IN cur_job
    LOOP
        l_job_name := NVL(cur_job_rec.name,' ');
    END LOOP;
    RETURN(l_job_name);
END get_job_from_pos;


PROCEDURE update34_implement (p_person_id  IN NUMBER
                             ,P_date       IN DATE)

IS

l_date date;
l_person_EXTRA_INFO_ID         NUMBER;
l_OBJECT_VERSION_NUMBER        NUMBER;
BEGIN

l_date := update34_implemented_date (p_person_id);

If l_date is null then
        ghr_person_extra_info_api.create_person_extra_info
                       (p_person_id              => p_person_id
                       ,p_information_type       => 'GHR_US_PER_UPDATE34'
                       ,P_EFFECTIVE_DATE         => p_date
                       ,P_PEI_information_category => 'GHR_US_PER_UPDATE34'
                       ,P_PEI_INFORMATION3        => fnd_date.date_to_canonical(p_date)
                       ,p_PERSON_EXTRA_INFO_ID   => l_PERSON_EXTRA_INFO_ID
                       ,P_OBJECT_VERSION_NUMBER  => L_OBJECT_VERSION_NUMBER);
end if;
END update34_implement;
--

----------------------------------------------------------------------------------------
--------------------------- <adj_basic_pay_cap> ----------------------------------------------
----------------------------------------------------------------------------------------
PROCEDURE adj_basic_pay_cap (p_pay_cap          IN     NUMBER
                            ,p_basic_pay        IN     NUMBER
                            ,p_adj_basic_pay    IN OUT NOCOPY NUMBER
                            ,p_locality_adj     IN OUT NOCOPY NUMBER) IS

l_locality_diff           NUMBER := 0;

BEGIN
   IF p_adj_basic_pay > p_pay_cap THEN
      IF p_pay_cap >=  p_basic_pay  THEN
         l_locality_diff := p_pay_cap - p_basic_pay;
         p_locality_adj  := l_locality_diff;
         p_adj_basic_pay := p_basic_pay + l_locality_diff;
      ELSE
         p_locality_adj  := p_locality_adj;
         p_adj_basic_pay := p_adj_basic_pay;
	 ghr_msl_pkg.g_ses_bp_capped := TRUE;
         hr_utility.set_message(8301,'GHR_38583_PAY_CAP3');
         hr_utility.raise_error;
      END IF;
   END IF;

END adj_basic_pay_cap;

--
--
-- PERFORMANCE CERTIFICATION FUNCTION DECLARATIONS START HERE
--
FUNCTION perf_certified(p_agency_code	IN ghr_pa_requests.from_Agency_code%TYPE,
		       p_org_id		IN hr_positions_f.organization_id%TYPE,
		       p_pay_plan	IN ghr_pa_Requests.from_pay_plan%TYPE,
		       p_effective_date	IN ghr_pa_Requests.effective_date%TYPE)
RETURN BOOLEAN
IS
--
-- Bug 4063133
-- PERFORMANCE CERTIFICATION CURSOR DECLARATIONS START HERE
--
CURSOR cur_per_org_det (p_per_id	per_all_assignments_f.person_id%TYPE,
			p_eff_date	per_all_assignments_f.effective_start_date%TYPE)
IS
SELECT asg.organization_id
FROM   per_all_assignments_f asg
WHERE  asg.person_id = p_per_id
AND    asg.assignment_type <> 'B'
AND    trunc(p_eff_date) between asg.effective_start_date
	and asg.effective_end_date;
--
CURSOR cur_perf_cert_agency(p_eff_date       date,
		    p_agency_code     ghr_pa_Requests.agency_code%TYPE,
		    p_pay_plan	      ghr_pay_plans.pay_plan%TYPE)
IS
SELECT distinct cert_group
FROM   ghr_perf_cert
WHERE  cert_agency	    = substr(p_agency_code,1,2)
AND    cert_agency_sub_code IS NULL
AND    cert_organization    IS NULL
AND    p_eff_date BETWEEN cert_start_date AND  nvl(cert_end_date,to_date('31/12/4712','DD/MM/YYYY') )
AND    ( INSTR(cert_group,p_pay_plan) > 0 );
--
CURSOR cur_perf_cert_agency_sub(p_eff_date       date,
		    p_agency_sub_code ghr_pa_Requests.agency_code%TYPE,
		    p_pay_plan	      ghr_pay_plans.pay_plan%TYPE)
IS
SELECT cert_group
FROM   ghr_perf_cert
WHERE  cert_agency	    IS NULL
AND    cert_agency_sub_code = p_agency_sub_code
AND    cert_organization    IS NULL
AND    p_eff_date BETWEEN cert_start_date AND  nvl(cert_end_date,to_date('31/12/4712','DD/MM/YYYY') )
AND    ( INSTR(cert_group,p_pay_plan) > 0 );
--

CURSOR cur_perf_cert_org(p_eff_date       date,
		    p_org_id          per_positions.organization_id%TYPE,
		    p_pay_plan	      ghr_pay_plans.pay_plan%TYPE)
IS
SELECT cert_group
FROM   ghr_perf_cert
WHERE  cert_agency	     IS NULL
AND    cert_agency_sub_code  IS NULL
AND    cert_organization     = p_org_id
AND    p_eff_date BETWEEN cert_start_date AND  nvl(cert_end_date,to_date('31/12/4712','DD/MM/YYYY') )
AND    ( INSTR(cert_group,p_pay_plan) > 0 );
--
--
CURSOR cur_ESSL_equivalent(p_pay_plan	ghr_pay_plans.pay_plan%TYPE)
IS
SELECT equivalent_pay_plan
FROM   ghr_pay_plans ppl
WHERE  ppl.pay_plan = p_pay_plan;
--
ll_pay_plan		ghr_pay_plans.pay_plan%TYPE;
l_from_Other_pay	ghr_pa_requests.to_other_pay_amount%TYPE;
l_cert_group		ghr_perf_cert.cert_group%type;
l_business_group_id	per_positions.organization_id%TYPE;
--
-- PERFORMANCE CERTIFICATION CURSOR DECLARATIONS END HERE
--
---  New Variables End.

l_cert_agncy			BOOLEAN;
l_cert_agncy_sub		BOOLEAN;
l_cert_org			BOOLEAN;
l_cert				BOOLEAN;

BEGIN

l_cert		:= FALSE;
--
	  -- Performance Certification Changes

	FOR cur_ESSL_equivalent_rec IN cur_ESSL_equivalent(p_pay_plan)
	LOOP
		ll_pay_plan	:= cur_ESSL_equivalent_rec.equivalent_pay_plan;
	END LOOP;
	hr_utility.set_location('INSIDE perf_cert loop'||p_org_id,123453);
		hr_utility.set_location('INSIDE perf_cert loop'||p_effective_date,123453);
			hr_utility.set_location('INSIDE perf_cert loop'||p_pay_plan,123453);
				hr_utility.set_location('INSIDE perf_cert loop'||p_agency_code,123453);
--
-- 1st LEVEL CHECK
-- CHECK if Agency level certification exists
--
	FOR perf_cert IN cur_perf_cert_agency (p_effective_date,
					       p_agency_code,
					       ll_pay_plan)
	LOOP
			l_cert				:= TRUE;
	hr_utility.set_location('INSIDE perf_cert AGNCY loop'||p_org_id,123453);
	END LOOP;

	IF NOT l_cert THEN
		--
		-- 2nd LEVEL CHECK
		-- CHECK if Agency SUBELEMENT CODE level certification exists
		FOR perf_cert IN cur_perf_cert_agency_sub (p_effective_date,
						   p_agency_code,
						   ll_pay_plan)
		LOOP
				l_cert			:= TRUE;
		hr_utility.set_location('INSIDE perf_cert AGNCY SUB loop'||p_org_id,123453);
		END LOOP;

		IF NOT l_cert THEN
			--
			-- 3rd LEVEL CHECK
			-- CHECK if ORGANIZATION level certification exists
			FOR perf_cert IN cur_perf_cert_org (p_effective_date,
			                                    p_org_id,
							    ll_pay_plan)
			LOOP
					l_cert			:= TRUE;
			hr_utility.set_location('INSIDE perf_cert ORG loop'||p_org_id,123453);
			END LOOP;
		END IF;

	END IF;
RETURN 	(l_cert);

END perf_certified;

--
--
-- PERFORMANCE CERTIFICATION FUNCTION DECLARATIONS END HERE
--
--

--Bug# 5132113

function pay_cap_chk_ttl_38(l_user_table_id     IN  pay_user_tables.user_table_id%TYPE,
                             l_user_clomun_name IN  pay_user_columns.user_column_name%TYPE,
                             l_market_pay       IN  number,
                             p_effective_date   IN  ghr_pa_Requests.effective_date%TYPE)
RETURN BOOLEAN IS
CURSOR range_values is
SELECT  udr.row_low_range_or_name,udr.row_high_range
   FROM    pay_user_columns                     udc,
           pay_user_rows_f                      udr,
           pay_user_tables                      udt,
           pay_user_column_instances_f          uci
   WHERE   udt.user_table_id = l_user_table_id
   AND     udr.user_table_id = udt.user_table_id
   AND     NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN udr.effective_start_date AND udr.effective_end_date
   AND     udc.user_table_id = udt.user_table_id
   AND     uci.user_column_id = udc.user_column_id
   AND     udr.user_row_id = uci.user_row_id
   AND     upper(udc.user_column_name) = upper(l_user_clomun_name)
   AND     NVL(p_effective_date,TRUNC(SYSDATE)) BETWEEN uci.effective_start_date AND uci.effective_end_date;

   l_low_range      pay_user_rows_f.row_low_range_or_name%type;
   l_high_range      pay_user_rows_f.row_high_range%type;

BEGIN
    for l_range_values in range_values
    loop
        l_low_range  := l_range_values.row_low_range_or_name;
        l_high_range := l_range_values.row_high_range;
        EXIT;
    END LOOP;
    IF l_low_range  <= l_market_pay AND
           l_high_range >= l_market_pay  then
        RETURN(TRUE);
    ELSE
        RETURN(FALSE);
    END IF;
END;

--Bug# 5132113


----------------------------------------------------------------------------------------
--------------------------- <do_pay_caps> ----------------------------------------------
----------------------------------------------------------------------------------------
PROCEDURE do_pay_caps_main ( p_pa_request_id     IN    NUMBER      --NEW
                        ,p_effective_date       IN    DATE
                        ,p_pay_rate_determinant IN    VARCHAR2
                        ,p_pay_plan             IN    VARCHAR2
                        ,p_to_position_id       IN    NUMBER
                        ,p_pay_basis            IN    VARCHAR2
                        ,p_person_id            IN    NUMBER
                        ,p_noa_code             IN    VARCHAR2      --New
                        ,p_basic_pay            IN    NUMBER
                        ,p_locality_adj         IN OUT NOCOPY   NUMBER
                        ,p_adj_basic_pay        IN OUT NOCOPY   NUMBER
                        ,p_total_salary         IN OUT NOCOPY   NUMBER
                        ,p_other_pay_amount     IN OUT NOCOPY   NUMBER
                        ,p_capped_other_pay     IN OUT NOCOPY   NUMBER      --New
                        ,p_retention_allowance  IN OUT NOCOPY   NUMBER      --New
                        ,p_retention_allow_percentage  IN OUT NOCOPY   NUMBER      --New
                        ,p_supervisory_allowance IN      NUMBER      --New
                        ,p_staffing_differential IN      NUMBER      --New
                        ,p_au_overtime          IN OUT NOCOPY   NUMBER
                        ,p_availability_pay     IN OUT NOCOPY   NUMBER
                        ,p_adj_basic_message       OUT NOCOPY   BOOLEAN
                        ,p_pay_cap_message         OUT NOCOPY   BOOLEAN
                        ,p_pay_cap_adj             OUT NOCOPY   NUMBER
                        ,p_open_pay_fields        OUT NOCOPY  BOOLEAN
                        ,p_message_set            OUT NOCOPY  BOOLEAN
                        ,p_total_pay_check        OUT NOCOPY  VARCHAR2) IS

l_converted_basic_pay     NUMBER;
l_converted_locality_adj  NUMBER;
l_converted_adj_basic_pay NUMBER;
l_converted_total_salary  NUMBER;

l_pay_cap_amount          NUMBER;
l_pay_cap_in_data         ghr_pay_caps.pay_cap_in_rec_type;
l_pay_cap_out_data        ghr_pay_caps.pay_cap_out_rec_type;

l_retained_grade          ghr_pay_calc.retained_grade_rec_type;
l_pay_plan                VARCHAR2(30);

---- New Variables
l_pay_basis               VARCHAR2(30);
l_update34_date           DATE;
l_adjust_op_amt           NUMBER;
l_difference              NUMBER;
l_capped_other_pay        NUMBER;
l_v_capped_other_pay      NUMBER;
l_other_pay_amount        NUMBER;
l_au_overtime             NUMBER;
l_availability_pay        NUMBER;
l_retention_allowance     NUMBER;
l_retention_allow_percentage     NUMBER;
l_ret_allow_from_ele      NUMBER;
l_temp_ret_allowance      NUMBER;
l_810_ra                  NUMBER;
l_supervisory_allowance   NUMBER;
l_staffing_differential   NUMBER;
l_adj_basic_mesg_flag     NUMBER;

l_old_other_pay_amount    NUMBER;
l_old_converted_total_salary NUMBER;
l_ra_diff                 NUMBER;
l_calc_retention_allowance NUMBER;

l_assignment_id           per_assignments_f.assignment_id%type;
l_to_auo_premium_pay_indicator  VARCHAR2(30);
l_to_ap_premium_pay_indicator   VARCHAR2(30);
l_multi_error_flag              BOOLEAN;
l_adj_basic_message             BOOLEAN := FALSE;
l_pay_cap_message               BOOLEAN := FALSE;
l_non_810_error                 BOOLEAN := FALSE;

l_pos_ei_grp2_data  per_position_extra_info%rowtype;
l_leo_indicator           BOOLEAN := FALSE;
l_current_basic_pay         NUMBER;

l_temp_ret_allo_percentage  NUMBER;
l_ele_supervisory NUMBER;
-- Bug 5482191 Start
l_pos_ei_valid_grade  per_position_extra_info%ROWTYPE;
l_grade_or_level      VARCHAR2(60);
l_grade_id            NUMBER;
l_psi		      VARCHAR2(30);--Bug# 8324201

CURSOR cur_grd IS
  SELECT gdf.segment1 pay_plan
        ,gdf.segment2 grade_or_level
  FROM  per_grade_definitions gdf
       ,per_grades            grd
  WHERE grd.grade_id = l_grade_id
  AND   grd.grade_definition_id = gdf.grade_definition_id;
-- Bug 5482191 End

  cursor c_assignment_by_per_id (per_id number, eff_date date) is
        select asg.assignment_id
          from per_assignments_f asg
         where asg.person_id = per_id
           and trunc(eff_date) between asg.effective_start_date
                                   and asg.effective_end_date
           and asg.primary_flag = 'Y';

---
CURSOR cur_get_pos_org(p_pos_id		per_positions.position_id%TYPE,
		      p_eff_Date ghr_pa_requests.effective_date%TYPE)
IS
SELECT ORGANIZATION_ID FROM HR_POSITIONS_F
WHERE  position_id=p_pos_id
AND    p_eff_date between effective_start_Date and effective_end_date;
--
l_business_group_id	per_positions.organization_id%TYPE;
l_agency_subele_code	per_position_definitions.segment4%TYPE;
l_org_id		per_positions.organization_id%TYPE;

FUNCTION convert_amount_to_PA(p_amount    IN NUMBER
                             ,p_pay_basis IN VARCHAR2)
  RETURN NUMBER IS
BEGIN
  RETURN( ghr_pay_calc.convert_amount(p_amount
                                     ,p_pay_basis
                                     ,'PA') );
EXCEPTION
  WHEN ghr_pay_calc.pay_calc_message THEN
    RETURN(NULL);
END convert_amount_to_PA;
--
--
BEGIN
-- Bug#4758111 PRD 2 Processing. Skip Pay Cap calculation for the PRD 2.
--Bug# 8324201 added NSPS condition for PRD 2.
l_psi := ghr_pa_requests_pkg.get_personnel_system_indicator(p_to_position_id, p_effective_date);
IF p_pay_rate_determinant = '2' AND l_psi = '00' THEN --Bug# 8324201
   NULL;
ELSE
  -- set up the in record structure
  l_pay_cap_in_data.effective_date       := p_effective_date;
  l_pay_cap_in_data.pay_rate_determinant := p_pay_rate_determinant;
  l_pay_cap_in_data.pay_plan             := p_pay_plan;
  l_pay_cap_in_data.to_position_id       := p_to_position_id;
  l_pay_cap_in_data.pay_basis            := p_pay_basis;
  l_pay_cap_in_data.person_id            := p_person_id;
  l_pay_cap_in_data.basic_pay            := p_basic_pay;
  l_pay_cap_in_data.locality_adj         := p_locality_adj;
  l_pay_cap_in_data.adj_basic_pay        := p_adj_basic_pay;
  l_pay_cap_in_data.total_salary         := p_total_salary;
  l_pay_cap_in_data.other_pay_amount     := p_other_pay_amount;
  l_pay_cap_in_data.au_overtime          := p_au_overtime;
  l_pay_cap_in_data.availability_pay     := p_availability_pay;
  l_pay_cap_in_data.noa_code             := p_noa_code;
  l_pay_cap_in_data.retention_allowance  := p_retention_allowance;
  l_pay_cap_in_data.retention_allow_percentage  := p_retention_allow_percentage;
  l_pay_cap_in_data.capped_other_pay := p_capped_other_pay;
  l_pay_cap_in_data.supervisory_allowance := p_supervisory_allowance;
  l_pay_cap_in_data.staffing_differential := p_staffing_differential;
  l_pay_cap_in_data.pa_request_id         := p_pa_request_id;

  hr_utility.set_location('One ',1);
  l_retention_allowance                  := p_retention_allowance;
  l_retention_allow_percentage           := p_retention_allow_percentage;
  l_au_overtime                          := p_au_overtime;
  l_availability_pay                     := p_availability_pay;
  l_supervisory_allowance                := p_supervisory_allowance;
  l_staffing_differential                := p_staffing_differential;

  l_other_pay_amount                     := p_other_pay_amount;
  l_capped_other_pay                     := p_capped_other_pay;
  l_v_capped_other_pay                   := p_capped_other_pay;
  l_adj_basic_mesg_flag                  := 0;

        FOR c_assignment_by_per_id_rec in c_assignment_by_per_id (p_person_id, p_effective_date) LOOP
        l_assignment_id   := c_assignment_by_per_id_rec.assignment_id;
        EXIT;
      END LOOP;

--
-- Performance certification initializations
--
--  l_certified				:= FALSE;
--  l_cert_to_not_cert			:= FALSE;
  l_business_group_id			:= FND_PROFILE.value('PER_BUSINESS_GROUP_ID');

 --
 -- Checking with the actual segment being used to store AGENCY CODE
 -- as customer may have saved agency code in other segment
 --
 --
 -- Performance certification initializations
 --
  l_agency_subele_code := ghr_api.get_position_agency_code_pos(
				p_position_id		=> p_to_position_id,
				p_business_group_id	=> l_business_group_id,
				p_effective_date	=> p_effective_date);
  -- This call only picks teh agency details during appointment action
  FOR cur_get_pos_org_rec IN cur_get_pos_org (p_to_position_id, p_effective_date)
  LOOP
	l_org_id	:=	cur_get_pos_org_rec.organization_id;
  END LOOP;

/*  ghr_api.retrieve_element_entry_value (p_element_name    => 'Basic Salary Rate'
                               ,p_input_value_name      => 'Rate'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => p_effective_date
                               ,p_value                 => l_from_basic_pay
                               ,p_multiple_error_flag   => l_multi_error_flag);

  ghr_api.retrieve_element_entry_value (p_element_name    => 'Total Pay'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => p_effective_date
                               ,p_value                 => l_from_total_pay
                               ,p_multiple_error_flag   => l_multi_error_flag);*/

-- Need to check for the entered value and the from side value so that
-- if the emp's certification is suspended, terminated or emp moves from certified to
--  non-certified agency
--
-- END OF PERF CERT INITIALIZATIONS
--

    ghr_api.retrieve_element_entry_value (p_element_name    => 'AUO'
                               ,p_input_value_name      => 'Premium Pay Ind'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => p_effective_date
                               ,p_value                 => l_to_auo_premium_pay_indicator
                               ,p_multiple_error_flag   => l_multi_error_flag);

    ghr_api.retrieve_element_entry_value (p_element_name    => 'Availability Pay'
                               ,p_input_value_name      => 'Premium Pay Ind'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => p_effective_date
                               ,p_value                 => l_to_ap_premium_pay_indicator
                               ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Two ',1);
  -- Bug 710431 If PRD is ABEFU or V then get retained grade details
  --
  IF l_pay_cap_in_data.pay_rate_determinant IN ('A','B','E','F','U','V') THEN
    -- use retained details...
    l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (l_pay_cap_in_data.person_id
                                                                    ,l_pay_cap_in_data.effective_date
                                                                    ,p_pa_request_id);
                                                    -- NB: pa_request_id is now redundant!!
    l_pay_plan  := l_retained_grade.pay_plan;
    l_update34_date := update34_implemented_date(p_person_id);
    if l_update34_date is not null AND p_effective_date >= l_update34_date then
   -----if the pay basis is null then raise a error message
       l_pay_basis := l_retained_grade.pay_basis;
    else
       l_pay_basis := p_pay_basis;
    end if;
    l_grade_or_level := l_retained_grade.grade_or_level; -- 5482191
  ELSE
    l_pay_plan  := l_pay_cap_in_data.pay_plan;
    l_pay_basis := p_pay_basis;

    -- Bug 5482191. Get valid grade data
    ghr_history_fetch.fetch_positionei(
      p_position_id      => p_to_position_id,
      p_information_type => 'GHR_US_POS_VALID_GRADE',
      p_date_effective   => p_effective_date,
      p_pos_ei_data      => l_pos_ei_valid_grade);
    IF l_pos_ei_valid_grade.position_extra_info_id IS NOT NULL THEN
        l_grade_id := l_pos_ei_valid_grade.poei_information4;
        IF l_grade_id IS NOT NULL THEN
            FOR cur_grd_rec IN cur_grd LOOP
                l_grade_or_level := cur_grd_rec.grade_or_level;
            END LOOP;
        END IF;
    END IF;
  END IF;

----Temp Promo changes regarding the pay basis.
      IF l_pay_cap_in_data.pay_rate_determinant IN ('A','B','E','F')
           AND l_retained_grade.temp_step IS NOT NULL THEN
               l_pay_plan  := l_pay_cap_in_data.pay_plan;
               l_pay_basis := p_pay_basis;
      END IF;
----Temp Promo changes regarding the pay basis.

  BEGIN
    -- currently just basic_pay, adj_basic_pay and total salary are checked for
    -- caps since they are compared with a PA table need to convert these to PA also
    -- If we can not convert them just treat them as null, i.e. do not error
    l_converted_basic_pay     := convert_amount_to_PA(l_pay_cap_in_data.basic_pay
                                                     ,l_pay_basis);
    l_converted_locality_adj  := convert_amount_to_PA(l_pay_cap_in_data.locality_adj
                                                     ,l_pay_basis);
    l_converted_adj_basic_pay := convert_amount_to_PA(l_pay_cap_in_data.adj_basic_pay
                                                     ,l_pay_basis);
    l_converted_total_salary  := convert_amount_to_PA(l_pay_cap_in_data.total_salary
                                                     ,l_pay_basis);

    l_converted_locality_adj  := l_converted_adj_basic_pay - l_converted_basic_pay;

    --Fetch the LEO indicator
    ghr_history_fetch.fetch_positionei(
      p_position_id      => p_to_position_id,
      p_information_type => 'GHR_US_POS_GRP2',
      p_date_effective   => p_effective_date,
      p_pos_ei_data      => l_pos_ei_grp2_data);

    IF l_pos_ei_grp2_data.position_extra_info_id IS NOT NULL
      AND l_pos_ei_grp2_data.poei_information16 IN ('1','2') THEN
      l_leo_indicator := TRUE;
    END IF;

    --    Bug 1978801
    -- 3) If Pay Plan ES,IE,AL,SL,IP,ST,CA or with
    --      any PRD Adjusted Basic Pay must not exceed EX-03
    --                   and Total Pay must not exceed EX-01
    -- Bug3604377 EE is added to the list.
    -- Bug 3969209 FE is added to the list

    -- Performance Certification code checks
    -- Check if the agency to which the emp belongs is certified, if not for Agency Subelement code
    -- if not for Organization. If certified then check for Cert_status, Cert_group, start date and
    -- end dates to apply the pay caps accordingly
    -- Bug#4168256 Added Pay Plan EV
    --Bug# 5132113
    --Bug 6457107 Modified poei_information11 to poei_information12 and
    --            poei_information12 to poei_information13
    -- Bug# 7031385 Added prd 0 condition since paycap should not fire for prd T and 4
    IF l_pay_plan in ( 'GP','GR')  and l_pay_cap_in_data.pay_rate_determinant IN ('0') THEN
     -- } 1
         ghr_history_fetch.fetch_positionei(
              p_position_id      => p_to_position_id,
              p_information_type => 'GHR_US_POS_VALID_GRADE',
              p_date_effective   => p_effective_date,
              p_pos_ei_data      => l_pos_ei_valid_grade);
        IF NOT (pay_cap_chk_ttl_38( l_pos_ei_valid_grade.poei_information12,
                                l_pos_ei_valid_grade.poei_information13,
                                l_converted_adj_basic_pay,
                                p_effective_date)) THEN
             hr_utility.set_message(8301,'GHR_37448_PAY_CAP_TTL38');
             hr_utility.raise_error;
        END IF;

    --Bug# 5132113
    --Begin Bug# 7557159
    ELSIF l_pay_plan in('IG') THEN
     -- } 1
        l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                           ,'02'
                           ,'00'
                           ,l_pay_cap_in_data.effective_date);
        IF l_pay_cap_amount < l_converted_adj_basic_pay THEN
            hr_utility.set_message(8301,'GHR_38186_IG_PAY_CAP1');
            hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
            hr_utility.raise_error;
        END IF;
    --End Bug# 7557159
    ELSIF l_pay_plan in ( 'ES','EP','EV','IE','AL','AA','SL','IP','ST','CA','EE', 'FE' )  THEN
      -- } 1
      IF l_pay_plan ='FE' THEN  --Added for bug#5931199
         l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX','02','00'
						                       ,l_pay_cap_in_data.effective_date);
      ELSIF l_pay_plan in ( 'ES','EP','EV','IE','SL','IP','ST')  THEN     --Removed FE bug#5931199
    	-- { 2
       	 IF ( perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date) )  THEN
     		-- { 3 -- check for pay plans initially then check for certification
     	    hr_utility.set_location('CERTIFIED',123455);

	    IF (l_pay_plan in ('ES','EP','EV','IE') ) THEN
	                --Begin Bug# 7633783
               IF l_pay_cap_in_data.pay_rate_determinant = 'D' THEN
                  l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VZ'
										,'00'
		                                                                ,'00'
				                                                ,l_pay_cap_in_data.effective_date);

               ELSE
                    --End Bug# 7633783
                    --Removed FE bug#5931199
                   l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
				                                                ,'02'
								                ,'00'
					                                        ,l_pay_cap_in_data.effective_date);
                    hr_utility.set_location('INSIDE EX-02',123456);
    				    hr_utility.set_location('pay cap amt :'||l_pay_cap_amount,1234567890);
                END IF;
 	    ELSIF (l_pay_plan in ('SL','ST','IP') ) THEN
		--Begin Bug# 6807868, coded as per the Pay cap master chart
                --Begin Bug# 7633783 added PRD S
		--Begin Bug# 8320557
               IF l_pay_cap_in_data.pay_rate_determinant IN ('R','S') THEN
		  l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value
			                            ('EX'
				                    ,'02'
					            ,'00'
						    ,l_pay_cap_in_data.effective_date);
               ELSE
                  --End Bug# 6807868
		  --Bug # 8515337  added date effectivity to consider EX-02 only after 12-Apr-2009
		  -- For SL ST IP and Certified Agency
  	         IF l_pay_cap_in_data.effective_date >= to_date('2009/04/12','YYYY/MM/DD') THEN
                   l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
					                                        ,'02'
									        ,'00'
                                                                                ,l_pay_cap_in_data.effective_date);
                 ELSE
                  l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
					                                       ,'03'
									       ,'00'
                                                                               ,l_pay_cap_in_data.effective_date);
                 END IF;
               END IF; -- Bug# 6807868
	     END IF;
        ELSE -- IF NONE OF THE AGENCIES OR ORGANIZATIONS ARE CERTIFIED
	   -- Bug # 8320557 Modified for SL ST IP pay plans to consider EX-02 for PRD R
	   -- and EX-03 for Other than R PRDs and NON Certified
         IF (l_pay_plan in ('SL','ST','IP') ) THEN
            IF l_pay_cap_in_data.pay_rate_determinant IN ('R') THEN
  	       l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value
			                            ('EX'
				                    ,'02'
					            ,'00'
						    ,l_pay_cap_in_data.effective_date);
            ELSE
               l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
				                                             ,'03'
									     ,'00'
                                                                             ,l_pay_cap_in_data.effective_date);
            END IF;
         ELSE
	--End Bug# 8320557
                --Begin Bug# 7633783
           IF l_pay_cap_in_data.pay_rate_determinant = 'D' THEN
             l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'01'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
   	    ELSE
                 --End Bug# 7633783
             l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
		                                                           ,'03'
			                                                   ,'00'
	                                                                   ,l_pay_cap_in_data.effective_date);
            END IF;
	  END IF;   -- } 2
       END IF;
		    -- } 3
        ELSIF l_pay_plan in ('AL','AA','CA','EE')  THEN
	        -- { 2
			--Begin Bug# 6807868, coded as per the Pay cap master chart
            IF l_pay_cap_in_data.pay_rate_determinant = 'R' AND l_pay_plan in ('AL','CA') THEN
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value
                                    ('EX'
                                    ,'02'
                                    ,'00'
                                    ,l_pay_cap_in_data.effective_date);
            ELSE
            --End Bug# 6807868
			l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
		                                                           ,'03'
			                                                   ,'00'
				                                           ,l_pay_cap_in_data.effective_date);
	        END IF; --Bug# 6807868
	    END IF;
        -- } 2


        -- END OF PERF CERT CHANGES FOR ADJ BASIC PAY
        --
        --check the adjusted basic pay
        IF l_converted_adj_basic_pay > l_pay_cap_amount THEN
            adj_basic_pay_cap (p_pay_cap          => l_pay_cap_amount
                           ,p_basic_pay        => l_converted_basic_pay
                           ,p_adj_basic_pay    => l_converted_adj_basic_pay
                           ,p_locality_adj     => l_converted_locality_adj );

            if l_to_auo_premium_pay_indicator is not null then
                l_au_overtime := ghr_pay_calc.get_ppi_amount(
                                                    l_to_auo_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
            end if;
            if l_to_ap_premium_pay_indicator is not null then
                l_availability_pay := ghr_pay_calc.get_ppi_amount(
                                                    l_to_ap_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
            end if;
            l_other_pay_amount   :=
                     nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                   + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

            l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
            ---Warning Message
            hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
            l_adj_basic_mesg_flag := 1;
        END IF;

        -- } 1 else cond

    -- Bug 5482191 Start
    ELSIF get_job_from_pos(l_pay_cap_in_data.effective_date, p_to_position_id) NOT IN ('0602','0680')
          AND (l_pay_plan IN ('YA','YB','YC','YD','YE','YF','YH','YI','YK','YL','YM','YN','YP') OR
               (l_pay_plan = 'YJ' AND l_grade_or_level IN ('01','02','03'))
              ) THEN
    -- } 1
        IF l_pay_cap_in_data.pay_rate_determinant IN ('0','4','T') THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'04'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
            l_pay_cap_amount := FLOOR((l_pay_cap_amount * 105) / 100);
        ELSIF l_pay_cap_in_data.pay_rate_determinant = 'R' THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'02'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
        --Begin Bug# 7633783
        ELSIF l_pay_cap_in_data.pay_rate_determinant = 'S' THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                    ,'03'
                                                                    ,'00'
                                                                    ,l_pay_cap_in_data.effective_date);
        --End Bug# 7633783
        --Begin bug# 8324201
        ELSIF   l_pay_cap_in_data.pay_rate_determinant = '2' AND ( perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date))  THEN
		 l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'02'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
	--End bug# 8324201
	END IF;
        IF l_pay_cap_amount < l_converted_adj_basic_pay THEN
	     --Begin bug# 8650322
	     adj_basic_pay_cap (p_pay_cap          => l_pay_cap_amount
                               ,p_basic_pay        => l_converted_basic_pay
                               ,p_adj_basic_pay    => l_converted_adj_basic_pay
                               ,p_locality_adj     => l_converted_locality_adj );

	    --End bug# 8650322
	    --Begin bug# 8324201
	    IF   l_pay_cap_in_data.pay_rate_determinant = '2' AND ( perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date)) THEN
		hr_utility.set_message(8301,'GHR_38186_IG_PAY_CAP1');
		hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
		hr_utility.raise_error;
	    ELSE
	    --End bug# 8324201

		    -- Bug 5663050 Start
		    if l_to_auo_premium_pay_indicator is not null then
			l_au_overtime := ghr_pay_calc.get_ppi_amount(
							    l_to_auo_premium_pay_indicator
							   ,l_converted_adj_basic_pay
							   ,l_pay_basis);
		    end if;
		    if l_to_ap_premium_pay_indicator is not null then
			l_availability_pay := ghr_pay_calc.get_ppi_amount(
							    l_to_ap_premium_pay_indicator
							   ,l_converted_adj_basic_pay
							   ,l_pay_basis);
		    end if;
		    l_other_pay_amount   :=
			     nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
			   + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

		    l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
		    -- Bug 5663050 End

		    hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
		    l_adj_basic_mesg_flag := 1;
	    END IF;
        END IF;
    ELSIF get_job_from_pos(l_pay_cap_in_data.effective_date, p_to_position_id) IN ('0602','0680')
          AND (l_pay_plan = 'YG' OR
               (l_pay_plan = 'YJ' AND l_grade_or_level = '04')
              ) THEN
    -- } 1
        IF l_pay_cap_in_data.pay_rate_determinant IN ('0','4','T','R') THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VW'
                                                                         ,'00'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
            IF l_pay_cap_amount < l_converted_adj_basic_pay THEN
                l_converted_adj_basic_pay := l_pay_cap_amount;
                l_converted_locality_adj := l_converted_adj_basic_pay - l_converted_basic_pay;

                -- Bug 5663050 Start
                if l_to_auo_premium_pay_indicator is not null then
                    l_au_overtime := ghr_pay_calc.get_ppi_amount(
                                                        l_to_auo_premium_pay_indicator
                                                       ,l_converted_adj_basic_pay
                                                       ,l_pay_basis);
                end if;
                if l_to_ap_premium_pay_indicator is not null then
                    l_availability_pay := ghr_pay_calc.get_ppi_amount(
                                                        l_to_ap_premium_pay_indicator
                                                       ,l_converted_adj_basic_pay
                                                       ,l_pay_basis);
                end if;
                l_other_pay_amount   :=
                         nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                       + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
                -- Bug 5663050 End

                hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
                l_adj_basic_mesg_flag := 1;
            END IF;
        END IF;
    -- Bug 5482191 End

-- Bug #5948924
-- Commented leo indicator validations As per the pay cap chart - March 2007 leo indicator should not be considered.
-- ELSIF NOT l_leo_indicator THEN

   --
   -- 1) If Pay Plan GS and Equivalent or AD with (bug 2681620 Remove AD)
   --      PRD 0,A,B,U,V Adjusted Basic Pay must not exceed EX-04
   --                and Total Pay must not exceed EX-01
   --  Bug#4168256 Added PRDs 3, J, K
   -- Bug# 7633783 Added PRDs D and S
    --Bug# 9255822,9156723 added PRD Y and Pay plan FP, FO
   ELSIF (pp_gs_equivalent(l_pay_plan) OR l_pay_plan in ('FO','FP'))
       AND (l_pay_cap_in_data.pay_rate_determinant in ('0','3','A','B','J','K','U','V','R','D','S','Y')) THEN
   -- } 1
       ----Bug 2065033
       -- Bug#4168256 Removed Pay Plan EV. Added it with pay plans ES,EP,FE,IE
       IF l_pay_plan in ('EX') THEN
         l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                      ,'01'
                                                                      ,'00'
                                                                      ,l_pay_cap_in_data.effective_date);
       --BEGIN Bug# 6807868
       ELSIF l_pay_cap_in_data.pay_rate_determinant = 'R' THEN
          l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'02'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
       --END Bug# 6807868
        --BEGIN Bug# 9255822
       ELSIF l_pay_cap_in_data.pay_rate_determinant = 'Y' THEN
          l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'04'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
	  l_pay_cap_amount :=  FLOOR((l_pay_cap_amount * 105) / 100);
       --END Bug# 9255822
	--Begin Bug# 7633783
       ELSIF l_pay_plan ='GS' AND l_pay_cap_in_data.pay_rate_determinant = 'D' THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                    ,'01'
                                                                    ,'00'
                                                                    ,l_pay_cap_in_data.effective_date);
       ELSIF l_pay_cap_in_data.pay_rate_determinant = 'S' THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                    ,'03'
                                                                    ,'00'
                                                                    ,l_pay_cap_in_data.effective_date);
        --End Bug# 7633783
       ELSE
          l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'04'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
       END IF;

       --check the adjusted basic pay
       IF l_converted_adj_basic_pay > l_pay_cap_amount THEN
                adj_basic_pay_cap (p_pay_cap          => l_pay_cap_amount
                               ,p_basic_pay        => l_converted_basic_pay
                               ,p_adj_basic_pay    => l_converted_adj_basic_pay
                               ,p_locality_adj     => l_converted_locality_adj );

                if l_to_auo_premium_pay_indicator is not null then
                    l_au_overtime := ghr_pay_calc.get_ppi_amount(
                                                        l_to_auo_premium_pay_indicator
                                                       ,l_converted_adj_basic_pay
                                                       ,l_pay_basis);
                end if;
                if l_to_ap_premium_pay_indicator is not null then
                    l_availability_pay := ghr_pay_calc.get_ppi_amount(
                                                        l_to_ap_premium_pay_indicator
                                                       ,l_converted_adj_basic_pay
                                                       ,l_pay_basis);
                end if;
                l_other_pay_amount   :=
                         nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                       + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
                ---Warning Message
                hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
                l_adj_basic_mesg_flag := 1;
        END IF;
  --END IF;

        --
        -- 2) If Pay Plan GS and Equivalent or AD with  (AD is removed from the requirements)
        --      PRD 5,6,7,E,F,M Adjusted Basic Pay must not exceed EX-05   (EX-05 ->  EX-03)
        --                  and Total Pay must not exceed EX-01
        -- Bug#4168256. After FWFA Changes(i.e. after 01-05-2005(dd-mm-yyyy)),
        --  If Pay Plan GS and Equivalent except AD with
        --      PRD 5,6,7,E,F,M Adjusted Basic Pay must not exceed EX-04
        --                  and Total Pay must not exceed EX-01
	--Bug# 9156723 added Pay plan FP, FO
    ELSIF (pp_gs_equivalent(l_pay_plan)OR l_pay_plan in ('FO','FP'))
            AND (l_pay_cap_in_data.pay_rate_determinant in ('5','6','7','E','F','M')) THEN
    -- } 1

            ----Bug 2065033
            -- Bug#4168256 Removed Pay Plan EV. Added it with pay plans ES,EP,FE,IE
            IF l_pay_plan in ('EX') THEN
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                       ,'01'
                                                                       ,'00'
                                                                       ,l_pay_cap_in_data.effective_date);
            ELSE
                --Bug#4168256 After FWFA, the adj pay cap changed to EX-04.
                -- Adj Pay Cap is EX-04 from the begining. Removing the effective date check.
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                       ,'04'
                                                                       ,'00'
                                                                       ,l_pay_cap_in_data.effective_date);
            END IF;

            --check the adjusted basic pay
            IF l_converted_adj_basic_pay > l_pay_cap_amount THEN
                adj_basic_pay_cap (p_pay_cap          => l_pay_cap_amount
                           ,p_basic_pay        => l_converted_basic_pay
                           ,p_adj_basic_pay    => l_converted_adj_basic_pay
                           ,p_locality_adj     => l_converted_locality_adj );

                if l_to_auo_premium_pay_indicator is not null then
                    l_au_overtime := ghr_pay_calc.get_ppi_amount(
                                                    l_to_auo_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
                end if;
                if l_to_ap_premium_pay_indicator is not null then
                    l_availability_pay := ghr_pay_calc.get_ppi_amount(
                                                    l_to_ap_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
                end if;
                l_other_pay_amount   :=
                     nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                   + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
                ---Warning Message
                hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
                l_adj_basic_mesg_flag := 1;
            END IF;
      --END IF;

        --
        -- 4) If Pay Plan 'FW Equivalent' and PRD anything then Total Salary must not exceed EX-01
        -- No ADj Basic pay check
        --
        --- END IF;

        --
        -- 5) If LEO Position then
        --      If AP or AUO is not null then Adj basic pay must not exceed EX-05
        --      If not recivening             ADj Basic Pay must not exceed EX-04
        --     And total Salary must not exceed EX-01.
        --
-- Bug # 5948924 commented as no need of leo indicator validations as per
 -- March 2007 Pay cap chart
/*  ELSIF l_leo_indicator THEN

        IF (l_au_overtime is not null ) OR (l_availability_pay is not null) THEN
            -- Bug# 4168256 Added the IF condition.
            IF (pp_gs_equivalent(l_pay_plan))
                AND (l_pay_cap_in_data.pay_rate_determinant in ('3','J','K','U','V')) THEN
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'04'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
            ELSE
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'05'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
            END IF;
            --check the adjusted basic pay
            IF l_converted_adj_basic_pay > l_pay_cap_amount THEN
                adj_basic_pay_cap (p_pay_cap          => l_pay_cap_amount
                           ,p_basic_pay        => l_converted_basic_pay
                           ,p_adj_basic_pay    => l_converted_adj_basic_pay
                           ,p_locality_adj     => l_converted_locality_adj );

                if l_to_auo_premium_pay_indicator is not null then
                    l_au_overtime := ghr_pay_calc.get_ppi_amount(
                                                    l_to_auo_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
                end if;
                if l_to_ap_premium_pay_indicator is not null then
                    l_availability_pay := ghr_pay_calc.get_ppi_amount(
                                                    l_to_ap_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
                end if;
                l_other_pay_amount   :=
                     nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                   + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
                ---Warning Message
                hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
                l_adj_basic_mesg_flag := 1;
            END IF;
        ELSIF ( nvl(l_au_overtime,0) = 0 ) AND (nvl(l_availability_pay,0) = 0)  THEN

            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'04'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
            --check the adjusted basic pay
            IF l_converted_adj_basic_pay > l_pay_cap_amount THEN
                adj_basic_pay_cap (p_pay_cap          => l_pay_cap_amount
                          ,p_basic_pay        => l_converted_basic_pay
                           ,p_adj_basic_pay    => l_converted_adj_basic_pay
                           ,p_locality_adj     => l_converted_locality_adj );

                if l_to_auo_premium_pay_indicator is not null then
                    l_au_overtime := ghr_pay_calc.get_ppi_amount(
                                                    l_to_auo_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
                end if;
                if l_to_ap_premium_pay_indicator is not null then
                    l_availability_pay := ghr_pay_calc.get_ppi_amount(
                                                    l_to_ap_premium_pay_indicator
                                                   ,l_converted_adj_basic_pay
                                                   ,l_pay_basis);
                end if;
                l_other_pay_amount   :=
                        nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                        + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
                ---Warning Message
                hr_utility.set_message(8301,'GHR_38581_PAY_CAP1');
                l_adj_basic_mesg_flag := 1;
            END IF;
        END IF;  */
    END IF;
    -- } 1
    hr_utility.set_location('Before entering TPC logic CTS'||l_converted_total_salary,1);
    hr_utility.set_location('p_noa_code is  '||p_noa_code,1);
    --Begin Bug# 7557159
    IF l_pay_plan in('IG') THEN
        l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                           ,'01'
                           ,'00'
                           ,l_pay_cap_in_data.effective_date);
        IF l_pay_cap_amount < l_converted_total_salary THEN
            hr_utility.set_message(8301,'GHR_38187_IG_PAY_CAP2');
            hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
            hr_utility.raise_error;
        END IF;

    --End Bug# 7557159
    --Bug# 5132113
    -- Bug# 7034637
    ELSIF l_pay_plan in('GP','GR') THEN
	    l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VX',
                                          '00','00',l_pay_cap_in_data.effective_date);
        -- Begin Bug# 7034637
        IF l_pay_cap_amount < l_converted_total_salary THEN
            hr_utility.set_message(8301,'GHR_38586_PAY_CAP6');
            hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
            hr_utility.raise_error;
        END IF;
        -- End Bug# 7034637
    --Bug# 5132113
    -- Bug#4168256 Added pay plan EV
    --Bug# 9156723 added Pay plan FP, FO
    ELSIF l_pay_plan in ( 'ES','EP','EV','IE','AL','AA','SL','IP','ST','CA','EE','FE','FP','FO') OR
        pp_gs_equivalent(l_pay_plan) OR
        pp_fw_equivalent(l_pay_plan) THEN

        --check the total pay
        -- Pradeep added this if statement as for EE Pay Plan VZ-00 is the Total Pay Cap.
        IF l_pay_plan in ('EE','FE') THEN  --Added pay plan FE for bug#5931199

            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VZ'
                                                                   ,'00'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
            -- Bug 4063133, 4065855
            -- Performance Certification changes
            -- Bug#4168256 Added pay plan EV
        ELSIF ( l_pay_plan in ( 'ES','EP','EV','IE') ) THEN --Removed FE bug#5931199
            -- Performance Certification Changes
	        IF (   perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date)
	           ) THEN
		        hr_utility.set_location('INSIDE VZ-02',12345);
		        l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VZ'
                                                                   ,'00'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);


	        ELSE -- not certified then old pay cap limit
		        l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'01'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
	        END IF;
            -- Performance Certification changes
        ELSIF ( l_pay_plan in ( 'SL','ST','IP') ) THEN
            -- Bug#5125166 For Certified employees on pay plans SL,ST,IP, pay cap is VZ-00, else EX-01.
	   IF (   perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date)
               )  THEN
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VZ'
                                                                   ,'00'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);

            ELSE -- not certified then old pay cap limit
                l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'01'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
            END IF;

	        -- Bug 4063133, 4065855
        ELSE
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'01'
                                                                   ,'00'
                                                                   ,l_pay_cap_in_data.effective_date);
        END IF;

        --
        hr_utility.set_location('CTS '||l_converted_total_salary,2);
        hr_utility.set_location('PC '||l_pay_cap_amount,3);

        -- MADHURI add logic to check for from basic and to basic
        -- let not the user chaneg the basic if he is moved from cert to not cert
        --
        IF l_converted_total_salary > l_pay_cap_amount THEN
            IF p_noa_code <> '810' THEN
                --
                -- Modifying the input values from Salary to Rate for Payroll Integration
                --
                ghr_api.retrieve_element_entry_value (p_element_name    => 'Basic Salary Rate'
                               ,p_input_value_name      => 'Rate'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => p_effective_date
                               ,p_value                 => l_current_basic_pay
                               ,p_multiple_error_flag   => l_multi_error_flag);
                if nvl(p_basic_pay,0)  >= nvl(l_current_basic_pay,0)  then
                    hr_utility.set_location('Inside the Retro calc -- l_converted_total_sal '||l_converted_total_salary,1);

                    ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                               ,p_input_value_name      => 'Amount'
                               ,p_assignment_id         => l_assignment_id
                               ,p_effective_date        => p_effective_date
                               ,p_value                 => l_ret_allow_from_ele
                               ,p_multiple_error_flag   => l_multi_error_flag);

                    hr_utility.set_location('Inside the Retro calc RA'||l_ret_allow_from_ele,2);
                    hr_utility.set_location('Inside the Retro calc l_RA'||l_retention_allowance,3);

                    ---Bug 2653521.  Calculate the total salary with Old retention Allowance and Comapre with
                    --------------   the pay cap amount. If the total salary is >= the pay cap amount then no
                    --------------   need to increase the retention allowance. But if it is lesser then increase
                    --------------   the retention allowance to that extent to meet the pay cap irrespective of
                    --------------   the NOAC.

                    l_ra_diff                := 0;
                    l_old_other_pay_amount   :=
                         nvl(l_ret_allow_from_ele,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                        + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                    l_old_converted_total_salary := l_converted_adj_basic_pay + nvl(l_old_other_pay_amount,0);
                    if l_old_converted_total_salary < l_pay_cap_amount then
                        l_ra_diff                  :=  nvl(l_pay_cap_amount,0)  - nvl(l_old_converted_total_salary,0);
                        l_calc_retention_allowance := nvl(l_ret_allow_from_ele,0) + nvl(l_ra_diff,0);
                        if l_calc_retention_allowance < l_retention_allowance then
                            l_retention_allowance   := l_calc_retention_allowance;

		                    --Pradeep start of Bug 3306515.
	                        --l_retention_allow_percentage := NULL;
                            --Bug 4744349 added trunc condition
	                        l_retention_allow_percentage := trunc((l_retention_allowance/l_current_basic_pay)*100,2);
		                    --Pradeep end of Bug 3306515.

                        else
                            l_ra_diff               := 0;
                        end if;
                    end if;
                    ---Bug 2653521. fix end

                    IF  nvl(l_retention_allowance,0) > nvl(l_ret_allow_from_ele,0) THEN
                        l_retention_allowance := l_ret_allow_from_ele + l_ra_diff;
                        l_other_pay_amount   :=
                                nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                                + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);

                        l_converted_total_salary := l_converted_adj_basic_pay + nvl(l_other_pay_amount,0);
                    END IF;
                End if;
            END IF;
        END IF;



        hr_utility.set_location('l_converted_total_sal '||l_converted_total_salary,4);

        ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                                                 ,p_input_value_name      => 'Amount'
                                                 ,p_assignment_id         => l_assignment_id
                                                 ,p_effective_date        => p_effective_date
                                                 ,p_value                 => l_810_ra
                                                 ,p_multiple_error_flag   => l_multi_error_flag);

        IF l_converted_total_salary > l_pay_cap_amount THEN
			hr_utility.set_location('Inside TP loop '||l_pay_cap_amount,4);
			l_adjust_op_amt := l_converted_total_salary - l_pay_cap_amount;
			if l_adjust_op_amt < 0 then
				l_adjust_op_amt := l_adjust_op_amt * -1;
			end if;
			l_adjust_op_amt := ghr_pay_calc.convert_amount(l_adjust_op_amt
															  , 'PA'
															  ,l_pay_basis);

			l_temp_ret_allowance := l_retention_allowance;
			-- Bug#3228580 Added Call to convert the Amount into the corresponding pay basis.
			l_difference := ghr_pay_calc.convert_amount(l_converted_total_salary - l_pay_cap_amount
													, 'PA'
														,l_pay_basis);

			if l_difference > nvl(l_temp_ret_allowance,0) then
				l_temp_ret_allowance := 0;
			else
				l_temp_ret_allowance := nvl(l_temp_ret_allowance,0) - l_difference;
			end if;

		    --Pradeep for Bug 3306515.

			l_temp_ret_allo_percentage := trunc((l_temp_ret_allowance/p_basic_pay)*100,2);

			hr_utility.set_location('l_difference is  '||l_difference,1);
			if p_noa_code <> '810' then
			    if nvl(l_retention_allowance,0) > 0 then
				    ----- Raise pay_cap_failed Raise Error Message
			        --Pradeep Changed this error message for Bug 3306515.
				    hr_utility.set_message(8301,'GHR_38893_PAY_CAP7');
				    hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
				    hr_utility.set_message_token('CAL_OP_PERC' ,l_temp_ret_allo_percentage );
				    l_non_810_error := TRUE;
				    l_pay_cap_message   := TRUE;
				    raise pay_cap_failed;
				    -------hr_utility.raise_error;
			    end if;
			end if;

		    if l_810_ra is null AND nvl(l_retention_allowance,0) > 0 then
			    l_capped_other_pay := NULL;
    		else
                --  Bug # 4102958 changes begin
                -- If other pay is zero or null then capped other should be null.
                -- Capped other pay should be converted to original pays basis as it is calculated on PA pay basis.
	            IF NVL(p_other_pay_amount,0) = 0 THEN
                    l_capped_other_pay := NULL;
                ELSE
                    l_capped_other_pay  := ghr_pay_calc.convert_amount(l_pay_cap_amount - l_converted_adj_basic_pay
                                                                            , 'PA'
                                                                            , l_pay_basis);
                END IF;
		        --  l_capped_other_pay       := l_pay_cap_amount - l_converted_adj_basic_pay;
                --  Bug # 4102958 changes end
		    end if;

            hr_utility.set_location('l_capped_other_pay is  '||l_capped_other_pay,1);
	        -- Bug#3228580 Added Call to convert the Amount into the corresponding pay basis.
            l_difference   := ghr_pay_calc.convert_amount(l_converted_total_salary - l_pay_cap_amount
	                                              , 'PA'
                                                       ,l_pay_basis);
            l_converted_total_salary := l_pay_cap_amount;

            if l_difference > nvl(l_retention_allowance,0) then
                if l_retention_allowance is not null then
                    l_retention_allowance := 0;
                    l_retention_allow_percentage := NULL;
                end if;
                l_other_pay_amount   :=
                     nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                   + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);
            else
                l_retention_allowance := nvl(l_retention_allowance,0) - l_difference;

	            --Pradeep for Bug 3306515.
	            --l_retention_allow_percentage := NULL;
                --Bug 4744349 added trunc condition
	            l_retention_allow_percentage := trunc((l_retention_allowance/p_basic_pay)*100,2);

                l_other_pay_amount   :=
                     nvl(l_retention_allowance,0) + nvl(l_au_overtime,0) + nvl(l_availability_pay,0)
                   + nvl(l_supervisory_allowance,0) + nvl(l_staffing_differential,0);
            end if;
		    hr_utility.set_location('l_converted_total_salary is  '||l_converted_total_salary,1);
		    hr_utility.set_location('l_v_capped_other_pay is  '||l_v_capped_other_pay,1);
		    hr_utility.set_location('l_supervisory_allowance is  '||l_supervisory_allowance,1);
		    hr_utility.set_location('l_capped_other_pay is  '||l_capped_other_pay,1);

		    /*  for Bug 3306515 instead of Warning Message give an error  message
			when supervisory allowance is present and give warning message
			and adjust the %  when no supervisory is available.
		    */
			-- Sundar. Comparing Supervisory element value with form value to find whether
			-- it has changed or not.
			ghr_api.retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
                                                 ,p_input_value_name      => 'Amount'
                                                 ,p_assignment_id         => l_assignment_id
                                                 ,p_effective_date        => p_effective_date
                                                 ,p_value                 => l_ele_supervisory
                                                 ,p_multiple_error_flag   => l_multi_error_flag);

		    hr_utility.set_location('l_ele_supervisory is  '||l_ele_supervisory,1);

		    if nvl(l_v_capped_other_pay,0) <> nvl(l_capped_other_pay,0) then
			    --hr_utility.set_message(8301,'GHR_38585_PAY_CAP5');
				IF nvl(l_supervisory_allowance ,0) <> l_ele_supervisory THEN
					hr_utility.set_message(8301,'GHR_38893_PAY_CAP7');
					hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
					hr_utility.set_message_token('CAL_OP_PERC',l_retention_allow_percentage);
					p_pay_cap_message   := TRUE;
					raise pay_cap_failed;
				ELSE
				    hr_utility.set_message(8301,'GHR_38585_PAY_CAP5');
				END IF;

		    end if;


        ELSIF l_converted_total_salary < l_pay_cap_amount  THEN
            l_capped_other_pay := NULL;
			hr_utility.set_location('l_capped_other_pay is  '||l_capped_other_pay,1);
        ELSIF l_converted_total_salary = l_pay_cap_amount  THEN

            if nvl(l_810_ra ,0) > nvl(l_retention_allowance,0) then
                ----Basically no change in the capped other pay
                l_capped_other_pay := p_capped_other_pay;
            elsif l_810_ra is null and l_retention_allowance is null then
                l_capped_other_pay := p_capped_other_pay;
            elsif nvl(l_capped_other_pay,0) = nvl(p_capped_other_pay,0) then
                l_capped_other_pay := p_capped_other_pay;
            else
                l_capped_other_pay := NULL;
            end if;

        END IF;
    -- Bug 5482191 Start
    ELSIF get_job_from_pos(l_pay_cap_in_data.effective_date, p_to_position_id) NOT IN ('0602','0680')
        AND (l_pay_plan IN ('YA','YB','YC','YD','YE','YF','YH','YI','YK','YL','YM','YN','YP') OR
             (l_pay_plan = 'YJ' AND l_grade_or_level IN ('01','02','03'))
            ) THEN
        IF l_pay_cap_in_data.pay_rate_determinant IN ('0','4','T') THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'01'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
        ELSIF l_pay_cap_in_data.pay_rate_determinant = 'R' THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                         ,'02'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
        --Begin bug# 8324201
        ELSIF   l_pay_cap_in_data.pay_rate_determinant = '2' AND ( perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date))  THEN
		 l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VZ'
                                                                         ,'00'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
	--End bug# 8324201
	END IF;
        IF l_pay_cap_amount < l_converted_total_salary THEN
	 --Begin bug# 8324201
	    IF  l_pay_cap_in_data.pay_rate_determinant = '2' AND ( perf_certified(l_agency_subele_code,l_org_id, l_pay_plan, p_effective_date)) THEN
		hr_utility.set_message(8301,'GHR_38187_IG_PAY_CAP2');
		hr_utility.set_message_token('PAY_CAP_AMT',l_pay_cap_amount);
		hr_utility.raise_error;
	    ELSE
		    --End bug# 8324201
		    l_converted_total_salary := l_pay_cap_amount;
		    l_capped_other_pay := l_converted_total_salary - l_converted_adj_basic_pay;
		    hr_utility.set_message(8301,'GHR_38585_PAY_CAP5');      -- Bug 5663050
	    END IF;
	END IF;
    -- Bug 5482191 End
    -- Bug 5663050 Start
    ELSIF get_job_from_pos(l_pay_cap_in_data.effective_date, p_to_position_id) IN ('0602','0680')
          AND (l_pay_plan = 'YG' OR
               (l_pay_plan = 'YJ' AND l_grade_or_level = '04')
              ) THEN
        IF l_pay_cap_in_data.pay_rate_determinant IN ('0','4','T','R') THEN
            l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('VX'
                                                                         ,'00'
                                                                         ,'00'
                                                                         ,l_pay_cap_in_data.effective_date);
            IF l_pay_cap_amount < l_converted_total_salary THEN
                l_converted_total_salary := l_pay_cap_amount;
                l_capped_other_pay := l_converted_total_salary - l_converted_adj_basic_pay;
                hr_utility.set_message(8301,'GHR_38585_PAY_CAP5');
            END IF;
        END IF;
    -- Bug 5663050 End
    END IF;

    if l_update34_date is not null AND p_effective_date >= l_update34_date then
        p_locality_adj        :=  ghr_pay_calc.convert_amount(l_converted_locality_adj
                                                          , 'PA'
                                                          ,l_pay_basis);
    else
        p_locality_adj        := l_converted_locality_adj;
    end if;
    p_adj_basic_pay       :=  ghr_pay_calc.convert_amount(l_converted_adj_basic_pay
                                                      , 'PA'
                                                      ,l_pay_basis);
    p_total_salary        :=  ghr_pay_calc.convert_amount(l_converted_total_salary
                                                      , 'PA'
                                                      ,l_pay_basis);
    if nvl(l_capped_other_pay,0) = nvl(l_other_pay_amount,0) then
        p_capped_other_pay   := NULL;
    else
        p_capped_other_pay    := l_capped_other_pay;
    end if;
    p_retention_allowance := l_retention_allowance;
    p_retention_allow_percentage := l_retention_allow_percentage;

    if (p_other_pay_amount is null) AND (l_other_pay_amount = 0)  then
        p_other_pay_amount := NULL;
    else
        p_other_pay_amount    := l_other_pay_amount;
    end if;
    p_au_overtime         := l_au_overtime;
    p_availability_pay    := l_availability_pay;

    l_pay_cap_in_data.locality_adj         := p_locality_adj;
    l_pay_cap_in_data.adj_basic_pay        := p_adj_basic_pay;
    l_pay_cap_in_data.total_salary         := p_total_salary;
    l_pay_cap_in_data.other_pay_amount     := p_other_pay_amount;
    l_pay_cap_in_data.au_overtime          := p_au_overtime;
    l_pay_cap_in_data.availability_pay     := p_availability_pay;
    l_pay_cap_in_data.retention_allowance  := p_retention_allowance;
    l_pay_cap_in_data.retention_allow_percentage  := p_retention_allow_percentage;
    l_pay_cap_in_data.capped_other_pay     := p_capped_other_pay;
    l_pay_cap_in_data.pa_request_id        := p_pa_request_id;
    --
    ghr_custom_pay_cap.custom_hook
      (l_pay_cap_in_data
      ,l_pay_cap_out_data);
    --
    --
    -- always set the out paramaters
    p_open_pay_fields   := l_pay_cap_out_data.open_pay_fields;
    p_message_set       := l_pay_cap_out_data.message_set;

    --To support some of the countries pay cap like total pay = basic pay
    --Bug 2064497 CHANGES TO SUPPORT PAY CALC FOR STATE/ LOCAL NATIONALS
    IF p_basic_pay = l_pay_cap_out_data.total_salary then

        p_locality_adj         := 0;
        p_adj_basic_pay        := p_basic_pay;
        p_total_salary         := p_basic_pay;
        p_other_pay_amount     := NULL;
        p_retention_allowance  := NULL;
        p_retention_allow_percentage  := NULL;
        p_au_overtime          := NULL;
        p_availability_pay     := NULL;
        p_capped_other_pay     := NULL;
        p_total_pay_check      := nvl(l_pay_cap_out_data.total_pay_check,'Y');

    ELSE
        p_locality_adj        := nvl(l_pay_cap_out_data.locality_adj,l_pay_cap_in_data.locality_adj);
        p_adj_basic_pay       := nvl(l_pay_cap_out_data.adj_basic_pay,l_pay_cap_in_data.adj_basic_pay);
        p_total_salary        := nvl(l_pay_cap_out_data.total_salary,l_pay_cap_in_data.total_salary);
        p_other_pay_amount    := nvl(l_pay_cap_out_data.other_pay_amount,l_pay_cap_in_data.other_pay_amount);
        p_retention_allowance := nvl(l_pay_cap_out_data.retention_allowance,l_pay_cap_in_data.retention_allowance);
        p_retention_allow_percentage := l_retention_allow_percentage;
        p_au_overtime         := nvl(l_pay_cap_out_data.au_overtime,l_pay_cap_in_data.au_overtime);
        p_availability_pay    := nvl(l_pay_cap_out_data.availability_pay,l_pay_cap_in_data.availability_pay);
        p_capped_other_pay    := nvl(l_pay_cap_out_data.capped_other_pay,l_pay_cap_in_data.capped_other_pay);
        p_total_pay_check     := nvl(l_pay_cap_out_data.total_pay_check,'Y');

    END IF;

    p_pay_cap_message     := nvl(l_pay_cap_out_data.pay_cap_message,l_pay_cap_message);
    p_pay_cap_adj         := nvl(l_pay_cap_out_data.pay_cap_adj,l_temp_ret_allowance);
    --
    if nvl(l_pay_cap_out_data.adj_basic_mesg_flag,l_adj_basic_mesg_flag) = 1 then
        p_adj_basic_message := TRUE;
        raise pay_cap_failed;
    end if;
    --
    p_adj_basic_message   := l_adj_basic_message;

  EXCEPTION
    WHEN pay_cap_failed THEN
      -- bug 708295 do not open pay fields any more if cap exceeded
      l_pay_cap_out_data.open_pay_fields := FALSE;
      l_pay_cap_out_data.message_set     := TRUE;
      if l_adj_basic_mesg_flag = 1 then
         l_adj_basic_message := TRUE;
      end if;
	  p_pay_cap_adj         :=nvl(l_pay_cap_out_data.pay_cap_adj,l_temp_ret_allowance);
/* Commenting this call because there is no need to call this again as already there is
call to custom_hook above. Also there is no change in pay component values between raising of
exception and here.
      ghr_custom_pay_cap.custom_hook
          (l_pay_cap_in_data
          ,l_pay_cap_out_data);
*/
    --
  END;
-- Initialization of out and in out parameters in case of exceptions raised by
-- non 810 actions
  IF l_non_810_error THEN
    IF l_update34_date is not null AND p_effective_date >= l_update34_date THEN
      p_locality_adj        :=  ghr_pay_calc.convert_amount(l_converted_locality_adj
                                                          , 'PA'
                                                          ,l_pay_basis);
    ELSE
      p_locality_adj        := l_converted_locality_adj;
    END IF;
    p_adj_basic_pay       :=  ghr_pay_calc.convert_amount(l_converted_adj_basic_pay
                                                          , 'PA'
                                                          ,l_pay_basis);
    p_total_salary        :=  ghr_pay_calc.convert_amount(l_converted_total_salary
                                                          , 'PA'
                                                          ,l_pay_basis);
  if nvl(l_capped_other_pay,0) = nvl(l_other_pay_amount,0) then
     p_capped_other_pay   := NULL;
  else
    p_capped_other_pay    := l_capped_other_pay;
  end if;
    p_retention_allowance := l_retention_allowance;
    p_retention_allow_percentage := l_retention_allow_percentage;

    if (p_other_pay_amount is null) AND (l_other_pay_amount = 0)  then
       p_other_pay_amount := NULL;
    else
       p_other_pay_amount    := l_other_pay_amount;
    end if;
    p_au_overtime         := l_au_overtime;
    p_availability_pay    := l_availability_pay;
   -- Out messages
    p_pay_cap_message     := l_pay_cap_message;
    p_pay_cap_adj         := l_temp_ret_allowance;
    --
    p_total_pay_check     := nvl(l_pay_cap_out_data.total_pay_check,'Y');
    IF l_adj_basic_mesg_flag = 1 then
     p_adj_basic_message := TRUE;
    END IF;
  END IF;
END IF;
EXCEPTION
  WHEN ghr_pay_calc.pay_calc_message THEN
    null;
END do_pay_caps_main;
--
--
PROCEDURE do_pay_caps_sql ( p_pa_request_id     IN    NUMBER      --NEW
                        ,p_effective_date   IN    DATE
                        ,p_pay_rate_determinant IN    VARCHAR2
                        ,p_pay_plan             IN    VARCHAR2
                        ,p_to_position_id       IN    NUMBER
                        ,p_pay_basis            IN    VARCHAR2
                        ,p_person_id            IN    NUMBER
                        ,p_noa_code             IN    VARCHAR2      --New
                        ,p_basic_pay            IN    NUMBER
                        ,p_locality_adj         IN OUT NOCOPY    NUMBER
                        ,p_adj_basic_pay        IN OUT NOCOPY    NUMBER
                        ,p_total_salary         IN OUT NOCOPY    NUMBER
                        ,p_other_pay_amount     IN OUT NOCOPY  NUMBER
                        ,p_capped_other_pay     IN OUT NOCOPY  NUMBER     --New
                        ,p_retention_allowance  IN OUT NOCOPY  NUMBER     --New
                        ,p_retention_allow_percentage  IN OUT NOCOPY  NUMBER     --New
                        ,p_supervisory_allowance IN    NUMBER      --New
                        ,p_staffing_differential IN    NUMBER      --New
                        ,p_au_overtime          IN OUT NOCOPY  NUMBER
                        ,p_availability_pay     IN OUT NOCOPY  NUMBER
                        ,p_adj_basic_message       OUT NOCOPY    BOOLEAN
                        ,p_pay_cap_message         OUT NOCOPY    BOOLEAN
                        ,p_pay_cap_adj             OUT NOCOPY    NUMBER
                        ,p_open_pay_fields         OUT NOCOPY  BOOLEAN
                        ,p_message_set          IN OUT NOCOPY  BOOLEAN
                        ,p_total_pay_check        OUT NOCOPY  VARCHAR2) IS
BEGIN
  do_pay_caps_main ( p_pa_request_id       =>    p_pa_request_id
                   ,p_effective_date       =>    p_effective_date
                   ,p_pay_rate_determinant =>    p_pay_rate_determinant
                   ,p_pay_plan             =>    p_pay_plan
                   ,p_to_position_id       =>    p_to_position_id
                   ,p_pay_basis            =>    p_pay_basis
                   ,p_person_id            =>    p_person_id
                   ,p_noa_code             =>    p_noa_code
                   ,p_basic_pay            =>    p_basic_pay
                   ,p_locality_adj         =>    p_locality_adj
                   ,p_adj_basic_pay        =>    p_adj_basic_pay
                   ,p_total_salary         =>    p_total_salary
                   ,p_other_pay_amount     =>    p_other_pay_amount
                   ,p_capped_other_pay     =>    p_capped_other_pay
                   ,p_retention_allowance  =>    p_retention_allowance
                   ,p_retention_allow_percentage  =>    p_retention_allow_percentage
                   ,p_supervisory_allowance =>   p_supervisory_allowance
                   ,p_staffing_differential =>   p_staffing_differential
                   ,p_au_overtime          =>    p_au_overtime
                   ,p_availability_pay     =>    p_availability_pay
                   ,p_adj_basic_message    =>    p_adj_basic_message
                   ,p_pay_cap_message      =>    p_pay_cap_message
                   ,p_pay_cap_adj          =>    p_pay_cap_adj
                   ,p_open_pay_fields      =>    p_open_pay_fields
                   ,p_message_set          =>    p_message_set
                   ,p_total_pay_check      =>    p_total_pay_check);

  IF p_message_set THEN
    hr_utility.raise_error;
  END IF;

END do_pay_caps_sql;

END ghr_pay_caps;

/
