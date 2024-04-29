--------------------------------------------------------
--  DDL for Package Body GHR_BEN_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_BEN_VALIDATION" AS
/* $Header: ghbenval.pkb 120.11.12010000.3 2009/07/07 05:51:06 utokachi ship $ */
--
--g_debug BOOLEAN := hr_utility.debug_enabled;

g_debug BOOLEAN := TRUE;

PROCEDURE validate_benefits(
    p_effective_date               in date
  , p_which_eit                    in varchar2
  , p_pa_request_id                in number default null
  , p_first_noa_code               in varchar2 default null
  , p_noa_family_code              in varchar2 default null
  , p_passed_element               in varchar2 default null
  , p_health_plan                  in varchar2 default null
  , p_enrollment_option            in varchar2 default null
  , p_date_fehb_elig               in date default null
  , p_date_temp_elig               in date default null
  , p_temps_total_cost             in varchar2 default null
  , p_pre_tax_waiver               in varchar2 default null
  , p_tsp_scd                      in varchar2 default null
  , p_tsp_amount                   in number default null
  , p_tsp_rate                     in number default null
  , p_tsp_status                   in varchar2 default null
  , p_tsp_status_date              in date default null
  , p_agency_contrib_date          in date default null
  , p_emp_contrib_date             in date default null
  , p_tenure                       in varchar2 default null
  , p_retirement_plan              in varchar2 default null
  , p_fegli_elig_exp_date          in date default null
  , p_fers_elig_exp_date           in date default null
  , p_annuitant_indicator          in varchar2 default null
  , p_assignment_id                in number default null)

IS
l_payroll_id ghr_pa_request_extra_info.rei_information3%type;
l_noa_family_code ghr_pa_requests.noa_family_code%type;
l_st_month VARCHAR2(20);
l_end_month VARCHAR2(20);
l_pay_month VARCHAR2(20);
l_start_date per_time_periods.start_date%type;
l_validate BOOLEAN;

	 CURSOR c_payroll_id(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
		SELECT rei_information3 payroll_id
		  FROM   ghr_pa_request_extra_info
		  WHERE  pa_request_id       =   c_pa_request_id
		  AND    information_type    =   'GHR_US_PAR_PAYROLL_TYPE';

	CURSOR c_start_date(c_payroll_id pay_payrolls_f.payroll_id%type, c_year varchar2, c_month varchar2) IS
		SELECT min(start_date) start_date
	   FROM per_time_periods
	   WHERE payroll_id = c_payroll_id
	   AND TO_CHAR(start_date,'YYYY') = c_year
	   AND TO_CHAR(start_date,'MM') = c_month;

		FUNCTION check_element_exist(p_assignment_id in number,
									  p_element_name varchar2,
									  p_effective_date date) RETURN BOOLEAN
		IS
		 l_new_element_name varchar2(250);
		 l_business_group_id per_all_people_f.business_group_id%type;
		 l_element_type_id pay_element_types_f.element_type_id%type;
		 l_exists BOOLEAN;

		 CURSOR c_element_exist(c_assignment_id per_all_assignments_f.assignment_id%type,
								c_effective_date per_all_assignments_f.effective_start_date%type,
								c_element_type_id pay_element_types_f.element_type_id%type)
			IS
			SELECT 1
				FROM pay_element_entries_f ele
				WHERE ele.assignment_id = c_assignment_id
				AND c_effective_date BETWEEN ele.effective_start_date AND ele.effective_end_date
				AND element_type_id = c_element_type_id;

		CURSOR c_element_type_id (c_element_name pay_element_types_f.element_name%type,
								  c_business_group_id pay_element_links_f.business_group_id%type,
								  c_effective_date per_all_assignments_f.effective_start_date%type)
			IS
			SELECT elt.element_type_id
			FROM pay_element_links eli, pay_element_types_f elt
			WHERE elt.element_type_id = eli.element_type_id
			AND eli.business_group_id = c_business_group_id
			AND elt.element_name = c_element_name;
		BEGIN
			l_exists := FALSE;
--			l_business_group_id := FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
			FND_PROFILE.get('PER_BUSINESS_GROUP_ID', l_business_group_id);

			IF g_debug = TRUE THEN
					hr_utility.set_location('Entering check_element_exist',12);
					hr_utility.set_location('l_business_group_id ' || l_business_group_id,12);
			END IF;
			l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name(p_element_name,l_business_group_id,p_effective_date,null);

			IF g_debug = TRUE THEN
					hr_utility.set_location('l_new_element_name ' || l_new_element_name,12);
			END IF;

			FOR l_cur_el_type IN c_element_type_id(l_new_element_name,l_business_group_id,p_effective_date) LOOP
				l_element_type_id := l_cur_el_type.element_type_id;
			END LOOP;

			IF g_debug = TRUE THEN
					hr_utility.set_location('l_element_type_id ' || l_element_type_id,12);
					hr_utility.set_location('p_assignment_id ' || p_assignment_id,12);
			END IF;

			FOR l_cur_el_exists IN c_element_exist(p_assignment_id, p_effective_date, l_element_type_id) LOOP
				l_exists := TRUE;
				IF g_debug = TRUE THEN
					hr_utility.set_location(l_new_element_name || 'element exists',12);
				END IF;
			END LOOP;

			RETURN l_exists;
		END check_element_exist;
BEGIN
	-- Validation for Health Plan
	-- If called from element entry
	l_validate := TRUE;
	hr_utility.set_location('which eit' || p_which_eit,12);
	IF (p_which_eit = 'E' AND p_passed_element = 'Health Benefits') OR  p_which_eit = 'R'
	THEN
			IF g_debug = TRUE THEN

				hr_utility.set_location('p_health_plan' || p_health_plan,12);
				hr_utility.set_location('p_noa_family_code' || p_noa_family_code,12);
			END IF;

			 IF p_which_eit = 'R' AND p_noa_family_code IN ('CONV_APP','EXT_NTE') THEN
					IF  p_health_plan IS NULL AND
						p_enrollment_option IS NULL AND
						p_temps_total_cost IS NULL THEN
						-- Check if element exists already
							l_validate := NOT(check_element_exist(p_assignment_id => p_assignment_id,
															  p_element_name => 'Health Benefits',
															  p_effective_date => p_effective_date));
					END IF;

			 END IF; -- IF p_which_eit = 'R' AND p_no

		IF l_validate = TRUE THEN
			IF p_health_plan IS NULL THEN
				hr_utility.set_message(8301,'GHR_38942_HB_NULL_PLAN_ENROLL');
				hr_utility.raise_error;
			END IF;

			-- Enrollment Option
			IF p_enrollment_option IS NULL THEN
				hr_utility.set_message(8301,'GHR_38942_HB_NULL_PLAN_ENROLL');
				hr_utility.raise_error;
				NULL;
			ELSE
				IF p_health_plan = 'ZZ' AND p_enrollment_option NOT IN('W','X','Y','Z') THEN
					hr_utility.set_message(8301,'GHR_38950_FEHB_INV_PLAN_OPTION');
					hr_utility.raise_error;
				END IF;

				IF p_health_plan <> 'ZZ' AND p_enrollment_option NOT IN('1','2','4','5') THEN
					hr_utility.set_message(8301,'GHR_38960_FEHB_NOT_ZZ');
					hr_utility.raise_error;
				END IF; -- IF NVL(l_health_plan,hr
			END IF; -- IF l_enrollment_option IS NULL T

			-- Pretax waiver Validation
			IF p_health_plan = 'ZZ' AND p_pre_tax_waiver = 'Y' THEN
				hr_utility.set_message(8301,'GHR_38956_PRE_TAX_ZZ_PLAN');
				hr_utility.raise_error;
			END IF;
		END IF; -- IF l_validate = TRUE T
	END IF; -- IF (p_which_eit = 'E' AND

	IF (p_which_eit = 'E' AND p_passed_element = 'TSP') OR  p_which_eit = 'R' THEN
			l_validate := TRUE;
			IF NVL(p_retirement_plan,hr_api.g_varchar2) NOT IN ('D','K','L','M','N','P','1','3','6','C','E','F','G','R','T','H','W') THEN
				IF p_tsp_amount IS NOT NULL OR p_tsp_rate IS NOT NULL THEN
					hr_utility.set_message(8301,'GHR_38958_TSP_AMT_NOT_FERS');
					hr_utility.raise_error;
				END IF;

				-- TSP Status should be null
				IF p_tsp_status IS NOT NULL THEN
					hr_utility.set_message(8301,'GHR_38958_TSP_AMT_NOT_FERS');
					hr_utility.raise_error;
				END IF;
			END IF; -- IF NVL(l_retirement_plan,hr_api.g_v

			IF p_which_eit = 'E' THEN
				-- TSP Status should not be null
				IF p_tsp_status IS NULL THEN
					hr_utility.set_message(8301,'GHR_38976_TSP_STS_REQD');
					hr_utility.raise_error;
				END IF;
			END IF;

			IF g_debug = TRUE THEN
				hr_utility.set_location('If Retirement plan is not in FERS or CSRS ',1234);
			END IF;

			-- Either only Amount should be entered or Rate...
			IF p_tsp_amount IS NOT NULL AND p_tsp_rate IS NOT NULL THEN
				hr_utility.set_message(8301,'GHR_38685_RATE_AMOUNT_COMBO');
				hr_utility.raise_error;
			END IF;

			-- Status must be 'Y' or 'W'
			IF p_tsp_amount IS NOT NULL OR p_tsp_rate IS NOT NULL THEN
				IF NVL(p_tsp_status,hr_api.g_varchar2) NOT IN ('Y','W') THEN
					hr_utility.set_message(8301,'GHR_38678_INCORRECT_STATUS');
					hr_utility.raise_error;
				END IF;
			END IF;

			IF g_debug = TRUE THEN
				hr_utility.set_location('p_tsp_status' || p_tsp_status,1234);
			END IF;

			IF p_tsp_status IN ('Y','W') THEN
				-- Either Amount or Rate should be entered
				IF p_tsp_amount IS NULL AND p_tsp_rate IS NULL THEN
					hr_utility.set_message(8301,'GHR_38677_INV_RATE_OR_STATUS');
					hr_utility.raise_error;
				END IF;
			END IF;


			-- TSP Status date should be entered if Status is entered
			-- Status Date should not be blank
			IF p_tsp_status IS NOT NULL THEN
				IF p_tsp_status_date IS NULL THEN
					hr_utility.set_message(8301,'GHR_38675_INVALID_STATUS_DATE');
					hr_utility.raise_error;
				END IF;
			ELSE
				IF p_tsp_status_date IS NOT NULL THEN
					hr_utility.set_message(8301,'GHR_38676_INVALID_STATUS');
					hr_utility.raise_error;
				END IF;
			END IF;

			IF g_debug = TRUE THEN
				hr_utility.set_location('TSP Status date' ,1234);
			END IF;


			-- 2.2.2.1.6.	If retirement Plan is 2, 4, or 5 and user has entered TSP information, provide error:
			-- "TSP information is not appropriate for retirement plans 2, 4, or 5.
			-- Please remove any TSP values from the Benefits EIT."
			IF p_retirement_plan IN ('2','4','5') THEN
				IF p_tsp_amount IS NOT NULL OR
					p_tsp_rate IS NOT NULL OR
					p_tsp_status IS NOT NULL OR
					p_tsp_status_date IS NOT NULL THEN
					-- Raise Error message
					hr_utility.set_message(8301,'GHR_38965_TSP_OTH');
					hr_utility.raise_error;
				END IF;
			END IF; -- IF p_retirement_plan IN ('2','4','5') THEN
			IF g_debug = TRUE THEN
				hr_utility.set_location('If retirement Plan is 2, 4, or 5',1234);
			END IF;
	END IF; -- IF (p_which_eit = 'E' AND p_passed_element = 'Health Benefits')

	IF p_which_eit = 'R' OR p_which_eit = 'P' THEN
		-- Validation for FEHB eligibility
		IF g_debug = TRUE THEN
				hr_utility.set_location('p_date_fehb_elig ' || to_char(p_date_fehb_elig,'dd/mm/yyyy') ,1234);
		END IF;

		IF p_date_fehb_elig IS NOT NULL THEN
			IF p_date_fehb_elig <=  p_effective_date THEN
				hr_utility.set_message(8301,'GHR_38951_BEN_ELIG_DATE');
				hr_utility.set_message_token('BEN_ELIG_DATE','FEHB Eligibility Expiration Date');
				hr_utility.raise_error;
			END IF;
			IF p_first_noa_code IN ('115','122','149','171','515','522','549','571') THEN
				hr_utility.set_message(8301,'GHR_38952_FEHB_ELIG_FOR_TMP');
				hr_utility.raise_error;
			END IF;
		END IF;

		IF g_debug = TRUE THEN
				hr_utility.set_location('p_date_temp_elig ' || to_char(p_date_temp_elig,'dd/mm/yyyy') ,1234);
		END IF;
		-- Date Temp Eligibility Expires - Validation
		IF p_date_temp_elig IS NOT NULL THEN
			IF p_first_noa_code IS NOT NULL THEN
				IF p_first_noa_code IN ('115','122','149','171','515','522','549','571') AND p_tenure = '0' THEN
					IF p_date_temp_elig <=  p_effective_date THEN
						hr_utility.set_message(8301,'GHR_38953_TMP_ELIG_FUT_DATE');
						hr_utility.raise_error;
					END IF;
				END IF;
				-- If tenure code is not 0, then value should be null
				IF p_first_noa_code IN ('115','122','149','171','515','522','549','571') AND NVL(p_tenure,hr_api.g_varchar2)  <> '0' THEN
						hr_utility.set_message(8301,'GHR_38954_TMP_ELIG_BLANK');
						hr_utility.raise_error;
				END IF;
				-- This field is valid only for Temp. appointments. else throw error.
				-- Bug 4668813
				hr_utility.set_location('p_first_noa_code'|| p_first_noa_code,223);

				IF p_which_eit = 'R' AND (p_first_noa_code IS NOT NULL AND p_first_noa_code NOT IN ('115','122','149','171','515','522','549','571')) THEN
						hr_utility.set_message(8301,'GHR_38955_TMP_ELIG_FOR_TMP');
						hr_utility.raise_error;
				END IF;
			ELSIF p_which_eit = 'P' THEN
				IF p_date_temp_elig <=  p_effective_date THEN
					hr_utility.set_message(8301,'GHR_38953_TMP_ELIG_FUT_DATE');
					hr_utility.raise_error;
				END IF;
			END IF; -- IF p_first_noa_code IS NOT NULL THEN
		END IF; -- IF p_rei_information4 IS NOT

		--
		IF p_date_temp_elig IS NOT NULL AND p_date_temp_elig > NVL(p_effective_date,TRUNC(SYSDATE)) THEN
			IF p_health_plan IS NOT NULL THEN
				IF p_health_plan <> 'ZZ' AND p_enrollment_option <> 'Z' THEN
					hr_utility.set_message(8301,'GHR_38964_FEHB_TMP_PLAN');
					hr_utility.raise_error;
				END IF;
			END IF;
		END IF; -- 	IF p_date_temp_elig IS NOT NULL

		IF g_debug = TRUE THEN
			hr_utility.set_location('p_fegli_elig_exp_date ' || to_char(p_fegli_elig_exp_date,'dd/mm/yyyy') ,1234);
		END IF;

		 -- FEGLI Eligibility Expiration Validation
		IF p_fegli_elig_exp_date IS NOT NULL THEN
			IF p_fegli_elig_exp_date <= NVL(p_effective_date,TRUNC(SYSDATE)) THEN
				hr_utility.set_message(8301,'GHR_38951_BEN_ELIG_DATE');
				hr_utility.set_message_token('BEN_ELIG_DATE','FEGLI Eligibility Expiration Date');
				hr_utility.raise_error;
			END IF;
		END IF; -- IF p_fegli_elig_exp_date IS NOT NULL THEN

		IF g_debug = TRUE THEN
			hr_utility.set_location('-- FEGLI Eligibility Expiration Validatio',1234);
		END IF;
		 -- FERS Eligibility Expiration Validation
		IF p_fers_elig_exp_date IS NOT NULL THEN
			IF p_fers_elig_exp_date <= NVL(p_effective_date,TRUNC(SYSDATE)) THEN
				hr_utility.set_message(8301,'GHR_38951_BEN_ELIG_DATE');
				hr_utility.set_message_token('BEN_ELIG_DATE','FERS Eligibility Expiration Date');
				hr_utility.raise_error;
			END IF;
		END IF; -- IF p_fers_elig_exp_date IS NOT NULL THEN
		IF g_debug = TRUE THEN
			hr_utility.set_location('-- FERS Eligibility Expiration Validation',1234);
		END IF;

		IF p_which_eit = 'R' AND p_noa_family_code IN ('CONV_APP','EXT_NTE') THEN
					IF  p_tsp_amount IS NULL AND
						p_tsp_rate IS NULL AND
						p_tsp_status IS NULL AND
						p_tsp_status_date IS NULL THEN
						-- Check if element exists already
							l_validate := NOT(check_element_exist(p_assignment_id => p_assignment_id,
															  p_element_name => 'TSP',
															  p_effective_date => p_effective_date));
					END IF;

		 END IF; -- IF p_which_eit = 'R' AND p_no

		IF l_validate = TRUE THEN
			IF p_retirement_plan IN ('D','K','L','M','N','P') THEN
				IF LTRIM(p_tsp_scd) IS NULL THEN
					-- Raise Error message
					hr_utility.set_message(8301,'GHR_38957_TSP_FERS');
					hr_utility.raise_error;
				END IF;
			END IF; -- IF p_retirement_plan IN ('D','K','L'...
		END IF;

		IF p_tsp_scd IS NOT NULL AND p_retirement_plan IS NOT NULL THEN
			IF p_retirement_plan NOT IN ('D','K','L','M','N','P') THEN
				-- Raise Error message
				hr_utility.set_message(8301,'GHR_38392_NON_TSP_FERS');--Bug# 4769233
				hr_utility.raise_error;
			END IF;
		END IF;

		IF p_retirement_plan NOT IN ('D','K','L','M','N','P','1','3','6','C','E','F','G','R','T','H','W') THEN
			-- Emp Contrib Elig date should be Null
			IF p_emp_contrib_date IS NOT NULL THEN
				hr_utility.set_message(8301,'GHR_38958_TSP_AMT_NOT_FERS');
				hr_utility.raise_error;
			END IF;
		END IF; -- IF NVL(l_retirement_plan,hr_api.g_v

		IF g_debug = TRUE THEN
			hr_utility.set_location('If Retirement plan is not in FERS or CSRS ',1234);
		END IF;

		-- IF TSP status is I then the date must be future.
		IF p_tsp_status = 'I' AND NVL(p_effective_date, TRUNC(SYSDATE)) > p_agency_contrib_date THEN
			hr_utility.set_message(8301,'GHR_38680_INV_AGENCY_CONTRIB');
			hr_utility.raise_error;
		END IF;

		IF g_debug = TRUE THEN
			hr_utility.set_location(' IF TSP status is I',1234);
		END IF;





		-- 2.2.2.1.6.	If retirement Plan is 2, 4, or 5 and user has entered TSP information, provide error:
		-- "TSP information is not appropriate for retirement plans 2, 4, or 5.
		-- Please remove any TSP values from the Benefits EIT."
		IF p_which_eit = 'R' THEN
			IF (p_retirement_plan IN ('2','4','5') AND p_annuitant_indicator IN ('2','3','9') )
				OR p_retirement_plan IN ('J','X') THEN
				IF p_agency_contrib_date IS NOT NULL OR
				   p_emp_contrib_date IS NOT NULL THEN
					-- Raise Error message
					hr_utility.set_message(8301,'GHR_38965_TSP_OTH');
					hr_utility.raise_error;
				END IF;
			END IF; -- IF p_retirement_plan IN ('2','4','5') THEN
		END IF;

		IF g_debug = TRUE THEN
			hr_utility.set_location('If retirement Plan is 2, 4, or 5',1234);
		END IF;

		IF p_which_eit = 'R' THEN
			-- If Agency or Emp contrib dates are entered, then status cannot be null
			IF p_agency_contrib_date IS NOT NULL OR p_emp_contrib_date IS NOT NULL THEN
				IF p_tsp_status IS NULL THEN
					hr_utility.set_message(8301,'GHR_38679_BLANK_STATUS');
					hr_utility.raise_error;
				END IF;
			END IF;

			-- Bug 4691271 and 4687755
			-- If FERS, the value should be not null. Else it should be null.
			--Begin Bug# 8622486
			/*IF p_retirement_plan IN ('D','K','L','M','N','P') THEN
				IF p_agency_contrib_date IS NULL THEN -- Bug 4693453
					hr_utility.set_message(8301,'GHR_38977_TSP_AGNCY_DATE_REQD');
					hr_utility.raise_error;
				END IF;
			ELS*/

			IF p_retirement_plan NOT IN ('D','K','L','M','N','P') AND p_agency_contrib_date IS NOT NULL THEN
					hr_utility.set_message(8301,'GHR_38961_NOT_FERS_AGNCY_DATE');
					hr_utility.raise_error;
			END IF;
			--end Bug# 8622486
		END IF;

		-- 2.2.1.1.3. AND 2.2.2.1.3 TSP Agncy Contrib Elig Date is required for all FERS covered employees.
		-- If the employee's retirement plan is D, K, L, M, N, or P and the defaulted value is removed by the user
		-- and a valid date is not entered provide error message: "TSP Agency Contrib Elig Date is required for all FERS employees.
		-- Please enter a valid date."

		-- First find out the valid date
		  -- Get Payroll ID
		FOR l_cur_payroll_id IN c_payroll_id(p_pa_request_id) LOOP
			l_payroll_id := l_cur_payroll_id.payroll_id;
		END LOOP;
/*Bug#6312182*/
/*Start: Commented the code as the logic for determining the eligibility date has been changed.
		IF to_number(to_char(p_effective_date,'MM')) BETWEEN 1 AND 6 THEN
			FOR l_cur_start_date IN c_start_date(l_payroll_id,to_char(p_effective_date,'YYYY'), '12') LOOP
				l_start_date := l_cur_start_date.start_date;
			END LOOP;
			l_st_month := 'January';
			l_end_month := 'June';
			l_pay_month := 'December';
		ELSE
			FOR l_cur_start_date IN c_start_date(l_payroll_id,to_char(p_effective_date+365,'YYYY'), '06') LOOP
				l_start_date := l_cur_start_date.start_date;
			END LOOP;
			l_st_month := 'July';
			l_end_month := 'December';
			l_pay_month := 'June';
		END IF; -- IF to_number(to_char(l_effective_date,'MM'))
:End*/
	   --Begin Bug# 8622486
            /*IF to_number(to_char(p_effective_date,'MM')) BETWEEN 6 AND 11 THEN
              FOR l_cur_start_date IN c_start_date(l_payroll_id,
                                                   to_char(p_effective_date + 365, 'YYYY'),'06') LOOP
                l_start_date := l_cur_start_date.start_date;
		l_st_month := 'June';
		l_end_month := 'November';
		l_pay_month := 'next June';
              END LOOP;
            ELSE
              FOR l_cur_start_date IN c_start_date(l_payroll_id,
                                                   to_char(p_effective_date + 31,'YYYY'),'12') LOOP
                l_start_date := l_cur_start_date.start_date;
		l_st_month := 'December';
		l_end_month := 'May';
		l_pay_month := 'next December';
              END LOOP;
            END IF; */-- IF to_number(to_char(p_effective_date,'MM'))
	    --End Bug# 8622486
/*Bug#6312182*/
		-- neet to set based on effective date...
		-- Bug 4673241 Added NOA's
		IF p_which_eit = 'R' AND p_first_noa_code IN ('130','132','145','147','140','141','143') THEN
			NULL;
		--Begin Bug# 8622486
		/*ELSIF p_agency_contrib_date <> l_start_date THEN
				-- Raise Error message
				hr_utility.set_message(8301,'GHR_38959_AGNCY_DATE_STRT_DATE');
				hr_utility.set_message_token('ST_MONTH',l_st_month);
				hr_utility.set_message_token('END_MONTH',l_end_month);
				hr_utility.set_message_token('PAY_MONTH',l_pay_month);
				hr_utility.raise_error;*/
		--end Bug# 8622486
		END IF;

		IF g_debug = TRUE THEN
			hr_utility.set_location('Get Payroll ID',1234);
		END IF;


		-- TSP Emp Contrib Elig date validation
		IF p_emp_contrib_date IS NOT NULL THEN
			IF p_noa_family_code = 'APP' AND p_first_noa_code NOT IN ('130','132','145','147') THEN
				-- Raise Error message
				hr_utility.set_message(8301,'GHR_38962_APP_EMP_ELIG_DATE');
				hr_utility.raise_error;
			ELSE
				IF NVL(p_effective_date,TRUNC(SYSDATE)) <= p_emp_contrib_date THEN
					-- Raise Error message
					hr_utility.set_message(8301,'GHR_38951_BEN_ELIG_DATE');
					hr_utility.set_message_token('BEN_ELIG_DATE','TSP Emp Contrib Elig date');
					hr_utility.raise_error;
				END IF;
				-- Amount or Rate should be null
				IF p_tsp_amount IS NOT NULL OR p_tsp_rate IS NOT NULL THEN
					-- Raise Error message
					hr_utility.set_message(8301,'GHR_38963_TSP_EMP_ELIG_DATE');
					hr_utility.raise_error;
				END IF;
			END IF; -- IF l_noa_family_code = 'APP' THEN
		END IF;
		IF g_debug = TRUE THEN
			hr_utility.set_location('IF p_rei_information18 IS NOT NULL',1234);
		END IF;


	END IF; -- IF p_which_eit = 'R' THEN




END validate_benefits;


PROCEDURE validate_create_element(
  p_effective_date               in date
  ,p_assignment_id                in number     default null
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_element_link_id              in number    default null
  ,p_element_type_id              in number	   default null
  ) IS


CURSOR c_element(c_element_name pay_element_types_f.element_name%type,
			 c_assignment_id per_all_assignments_f.assignment_id%type,
			 c_effective_date pay_element_entries_f.effective_start_date%type,
			 c_business_group_id pay_element_links_f.business_group_id%type
			 ) is
SELECT a.element_name element_name,
        b.name           ipv_name,
       f.input_value_id           input_value_id,
       e.effective_start_date     effective_start_date,
       e.effective_end_date       effective_end_date,
       e.element_entry_id         element_entry_id,
       e.assignment_id            assignment_id,
       e.object_version_number    object_version_number,
       f.element_entry_value_id   element_entry_value_id,
       f.screen_entry_value       screen_entry_value
FROM   pay_element_types_f        a,
       pay_input_values_f         b,
       pay_element_entries_f      e,
	   pay_element_entry_values_f f,
	   pay_element_links_f        g
WHERE  a.element_type_id      = b.element_type_id
AND	   e.element_type_id	  = a.element_type_id
AND    f.element_entry_id     = e.element_entry_id
AND    f.input_value_id       = b.input_value_id
AND    g.element_type_id      = a.element_type_id
AND    c_effective_date between g.effective_start_date and g.effective_end_date
AND    c_effective_date between a.effective_start_date and a.effective_end_date
AND    c_effective_date between b.effective_start_date and b.effective_end_date
AND    g.business_group_id = c_business_group_id
--and    e.effective_start_date = f.effective_start_date
--and    e.effective_end_date   = f.effective_end_date
and e.assignment_id         =  c_assignment_id
and a.element_name = c_element_name
AND c_effective_date BETWEEN e.effective_start_date AND e.effective_end_date;

CURSOR c_get_person_id(c_assignment_id per_all_assignments_f.assignment_id%type,
					   c_effective_date per_all_assignments_f.effective_start_date%type)
IS
SELECT person_id
FROM per_all_assignments_f asg
WHERE asg.assignment_id = c_assignment_id
AND c_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

CURSOR c_element_name(c_element_link_id pay_element_links_f.element_link_id%type,
                      c_effective_date pay_element_links_f.effective_start_date%type,
					  c_business_group_id pay_element_links_f.business_group_id%type) IS
	SELECT element_name
	FROM pay_element_types_f pet, pay_element_links_f pel
	where pet.element_type_id = pel.element_type_id
	and c_effective_date between pel.effective_start_date and pel.effective_end_date
	and pel.business_group_id = c_business_group_id
	and pel.element_link_id = c_element_link_id;

l_rate number;
l_tsp_status varchar2(20);
l_tsp_status_date varchar2(20);
l_amount number;
l_business_group_id per_all_people_f.business_group_id%type;
l_session_date fnd_sessions.effective_date%type;

l_health_plan varchar2(20);
l_enrollment_option varchar2(20);
l_temps_total_cost  varchar2(20);
l_pre_tax_waiver varchar2(20);
l_premium_rate varchar2(20);
l_per_benefit_info per_people_extra_info%rowtype;
l_person_id per_all_people_f.person_id%type;
l_new_element_name pay_element_types_f.element_name%type;
l_element_name pay_element_types_f.element_name%type;
l_ret_plan_name varchar2(200);
l_retirement_plan ghr_pa_requests.retirement_plan%type;
l_debug_mode BOOLEAN;
BEGIN
	-- Initialization
	IF ghr_utility.is_ghr = 'TRUE' THEN
		IF g_debug = TRUE THEN
			hr_utility.set_location('Entering validate_create_element',110);
		END IF;

		l_business_group_id := FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
		l_debug_mode := FALSE;

		IF g_debug = TRUE THEN
			hr_utility.set_location('l_business_group_id -- ' || l_business_group_id,110);
		END IF;

		-- Check for the element Name
		FOR l_cur_element_name IN c_element_name(p_element_link_id,p_effective_date,l_business_group_id) LOOP
			l_new_element_name := l_cur_element_name.element_name;
		END LOOP;

		IF g_debug = TRUE THEN
			hr_utility.set_location('New Element name -- ' || l_new_element_name,110);
		END IF;

		l_element_name := pqp_fedhr_uspay_int_utils.return_old_element_name(l_new_element_name,l_business_group_id,p_effective_date);

		IF g_debug = TRUE THEN
			hr_utility.set_location('Element name -- ' || l_element_name,110);
		END IF;

		l_ret_plan_name := pqp_fedhr_uspay_int_utils.return_new_element_name('Retirement Plan',l_business_group_id,p_effective_date,null);

		FOR l_cur_element IN c_element(l_ret_plan_name,p_assignment_id, p_effective_date,l_business_group_id) LOOP
			  IF l_cur_element.ipv_name = 'Plan' then
				l_retirement_plan := l_cur_element.screen_entry_value;
			  END IF;
		END LOOP;

		IF g_debug = TRUE THEN
			hr_utility.set_location('Retirement plan -- ' || l_retirement_plan,110);
		END IF;

		IF l_element_name = 'TSP' THEN
			FOR l_cur_element IN c_element(l_new_element_name,p_assignment_id, p_effective_date,l_business_group_id) LOOP
				  IF l_cur_element.ipv_name = 'Rate' then
					l_rate := to_number(l_cur_element.screen_entry_value);
				  ELSIF l_cur_element.ipv_name = 'Status' then
					l_tsp_status := substr(l_cur_element.screen_entry_value,1,1);
				  ELSIF l_cur_element.ipv_name = 'Status Date' then
					l_tsp_status_date := fnd_date.canonical_to_date(l_cur_element.screen_entry_value);
				  ELSIF l_cur_element.ipv_name = 'Amount' then
					l_amount := to_number(l_cur_element.screen_entry_value);
				  END IF;
			END LOOP;

			IF g_debug = TRUE THEN
				hr_utility.set_location('Entering validation tsp',110);
			END IF;

			ghr_ben_validation.validate_benefits(
			p_effective_date               => p_effective_date
		  , p_which_eit                    => 'E'
		  , p_passed_element               => 'TSP'
		  , p_tsp_amount                   => l_amount
		  , p_tsp_rate                     => l_rate
		  , p_tsp_status                   => l_tsp_status
		  , p_tsp_status_date              => l_tsp_status_date
		  , p_retirement_plan              => l_retirement_plan
			);
		ELSIF l_element_name = 'Health Benefits' THEN
			FOR l_cur_element IN c_element(l_new_element_name,p_assignment_id, p_effective_date,l_business_group_id) LOOP
			  IF l_cur_element.ipv_name = 'Enrollment' then
				l_enrollment_option := l_cur_element.screen_entry_value;
			  ELSIF l_cur_element.ipv_name = 'Health Plan' then
				l_health_plan := l_cur_element.screen_entry_value;
			  ELSIF l_cur_element.ipv_name = 'Temps Total Cost' then
				l_temps_total_cost := l_cur_element.screen_entry_value;
			  ELSIF l_cur_element.ipv_name = 'Pre tax Waiver' then
				l_pre_tax_waiver := l_cur_element.screen_entry_value;
			  ELSIF l_cur_element.ipv_name = 'Premium Rate' then
				l_premium_rate := to_number(l_cur_element.screen_entry_value);
			  END IF;
			END LOOP;

			IF g_debug = TRUE THEN
				hr_utility.set_location('Entering validation fehb',110);
			END IF;

			-- Validation part
			validate_benefits(
			p_effective_date               => p_effective_date
		  , p_which_eit                    => 'E'
		  , p_passed_element               => 'Health Benefits'
		  , p_health_plan                  => l_health_plan
		  , p_enrollment_option            => l_enrollment_option
		  , p_temps_total_cost             => l_temps_total_cost
		  , p_pre_tax_waiver               => l_pre_tax_waiver
			);

		END IF; -- IF l_element_name = 'TSP
	END IF; -- IF ghr_utility.is_ghr = 'TRUE

END validate_create_element;

PROCEDURE validate_update_element(
  p_effective_date               in date
  ,P_ASSIGNMENT_ID_O                in number     default null
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,P_ELEMENT_LINK_ID_O              in number    default null
  ,P_ELEMENT_TYPE_ID_O              in number	   default null
  ) IS
BEGIN
	IF g_debug = TRUE THEN
		hr_utility.set_location('Entering validate_update_element',110);
	END IF;
	validate_create_element(
		  p_effective_date               => p_effective_date
		  ,P_ASSIGNMENT_ID               => P_ASSIGNMENT_ID_O
		  ,p_validation_start_date       => p_validation_start_date
		  ,p_validation_end_date         => p_validation_end_date
		  ,p_element_entry_id            => p_element_entry_id
		  ,p_effective_start_date        => p_effective_start_date
		  ,p_effective_end_date          => p_effective_end_date
		  ,P_ELEMENT_LINK_ID             => P_ELEMENT_LINK_ID_O
		  ,P_ELEMENT_TYPE_ID             => P_ELEMENT_TYPE_ID_O
		  );

END validate_update_element;

PROCEDURE validate_create_personei(
p_person_extra_info_id number,
p_information_type in varchar2,
p_person_id in number
) IS
CURSOR c_assignment(c_person_id per_assignments_f.person_id%type,
					c_effective_date per_assignments_f.effective_start_date%type) IS
SELECT assignment_type, assignment_id
FROM per_all_assignments_f asg
WHERE asg.person_id = c_person_id
AND c_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

CURSOR c_sess_date(c_session_id fnd_sessions.session_id%type)
IS
SELECT effective_date
FROM fnd_sessions
WHERE session_id = c_session_id;

CURSOR c_per_ei(c_per_extra_info_id per_people_extra_info.person_extra_info_id%type,
				c_information_type per_people_extra_info.information_type%type) IS
SELECT *
FROM per_people_extra_info ppei
WHERE ppei.person_extra_info_id = c_per_extra_info_id
AND ppei.information_type = c_information_type;

l_effective_date fnd_sessions.effective_date%type;
l_session_id fnd_sessions.session_id%type;
l_assignment_type per_all_assignments_f.assignment_type%type;
l_assignment_id per_all_assignments_f.assignment_id%type;
l_agency_contrib_date date;
l_emp_contrib_date date;
l_fers_elig_exp_date date;
l_fegli_elig_exp_date date;
l_date_temp_elig date;
l_date_fehb_elig date;
l_tsp_scd date;
l_business_group_id per_all_people_f.business_group_id%type;
l_asg_ei_data per_assignment_extra_info%rowtype;
l_annuitant_indicator per_assignment_extra_info.aei_information5%type;
l_session  ghr_history_api.g_session_var_type;
l_noa_id number;
l_noa_family_code ghr_noa_families.noa_family_code%type;

-- Bug 4760226
CURSOR c_noa_family_code(c_noa_id ghr_nature_of_actions.nature_of_action_id%type,
						 c_effective_date ghr_nature_of_actions.date_from%type) IS
SELECT noa_family_code
FROM ghr_noa_families
WHERE nature_of_action_id = c_noa_id
AND c_effective_date BETWEEN NVL(start_date_active,to_date('01/01/1951','dd/mm/yyyy'))
AND NVL(end_date_active,to_date('31/12/4712','dd/mm/yyyy'));

BEGIN
	IF ghr_utility.is_ghr = 'TRUE' AND p_information_type  IN ('GHR_US_PER_BENEFIT_INFO','GHR_US_PER_SCD_INFORMATION') THEN
		IF g_debug = TRUE THEN
			hr_utility.set_location('Inside validate_create_personei',12);
		END IF;
		l_session_id := USERENV('sessionid');
		ghr_history_api.get_g_session_var(l_session);

		IF l_session.pa_request_id IS NOT NULL THEN
			l_effective_date := l_session.date_effective;
			FOR l_cur_noa_code IN c_noa_family_code(l_session.noa_id, l_effective_date) LOOP
				l_noa_family_code := l_cur_noa_code.noa_family_code;
			END LOOP;
		ELSE
			FOR l_cur_sess_date IN c_sess_date(l_session_id) LOOP
				l_effective_date := l_cur_sess_date.effective_date;
			END LOOP;
		END IF;

		IF g_debug = TRUE THEN
			hr_utility.set_location('eff.date ' || l_effective_date,12);
		END IF;

		-- Fire only for Appt, Conv to appt and extension actions
		IF l_noa_family_code IN ('APPT','CONV_APPT','EXT_NTE')
			AND l_session.noa_id_correct IS NULL THEN
			-- Get Assignment type
			FOR l_asg_cur IN c_assignment(p_person_id,l_effective_date) LOOP
				l_assignment_type := l_asg_cur.assignment_type;
				l_assignment_id := l_asg_cur.assignment_id;
			END LOOP;

			IF g_debug = TRUE THEN
				hr_utility.set_location('Assignment_type ' || l_assignment_type,12);
				hr_utility.set_location('Assignment_id ' || l_assignment_id,12);
				hr_utility.set_location('p_information_type ' || p_information_type,12);
			END IF;

			-- Validation only if person is employee
			IF l_assignment_type = 'E' THEN
				FOR l_cur_per_ei IN c_per_ei(p_person_extra_info_id,p_information_type) LOOP
					IF p_information_type = 'GHR_US_PER_BENEFIT_INFO' THEN
						l_date_fehb_elig := fnd_date.canonical_to_date(l_cur_per_ei.pei_information4);
						l_date_temp_elig := fnd_date.canonical_to_date(l_cur_per_ei.pei_information5);
						l_fegli_elig_exp_date := fnd_date.canonical_to_date(l_cur_per_ei.pei_information3);
						l_fers_elig_exp_date := fnd_date.canonical_to_date(l_cur_per_ei.pei_information11);
						l_agency_contrib_date := fnd_date.canonical_to_date(l_cur_per_ei.pei_information14);
						l_emp_contrib_date := fnd_date.canonical_to_date(l_cur_per_ei.pei_information15);
					ELSIF p_information_type = 'GHR_US_PER_SCD_INFORMATION' THEN
						l_tsp_scd := fnd_date.canonical_to_date(l_cur_per_ei.pei_information6);
					END IF;
				END LOOP;
				-- Get Annuitant indicator
				ghr_history_fetch.fetch_asgei
				(p_assignment_id          =>  l_assignment_id,
				 p_information_type  	  =>  'GHR_US_ASG_SF52',
				 p_date_effective         =>  l_effective_date,
				 p_asg_ei_data       	  =>  l_asg_ei_data
				 );
				l_annuitant_indicator := l_asg_ei_data.aei_information5;
				IF g_debug = TRUE THEN
					hr_utility.set_location('l_annuitant_indicator ' || l_annuitant_indicator,12);
					hr_utility.set_location('l_tsp_scd ' || to_char(l_tsp_scd,'dd/mm/yyyy'),12);
				END IF;
				-- Call Validation package
				validate_benefits(
				p_effective_date               => l_effective_date
			  , p_which_eit                    => 'P'
			  , p_date_fehb_elig               => l_date_fehb_elig
			  , p_date_temp_elig               => l_date_temp_elig
			  , p_tsp_scd                      => l_tsp_scd
			  , p_agency_contrib_date          => l_agency_contrib_date
			  , p_emp_contrib_date             => l_emp_contrib_date
			  , p_fegli_elig_exp_date          => l_fegli_elig_exp_date
			  , p_fers_elig_exp_date           => l_fers_elig_exp_date
			  , p_annuitant_indicator          => l_annuitant_indicator);
			END IF; -- IF l_assignment_type = 'E' THEN
		END IF; -- IF l_noa_family_code IN ('APPT','CONV_APPT','EXT_NTE')
	END IF; -- IF ghr_utility.is_ghr

END validate_create_personei;


end GHR_BEN_VALIDATION;

/
