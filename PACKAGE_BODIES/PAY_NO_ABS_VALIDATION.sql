--------------------------------------------------------
--  DDL for Package Body PAY_NO_ABS_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ABS_VALIDATION" AS
/* $Header: pynoabsval.pkb 120.0.12010000.2 2009/09/18 06:37:52 vijranga ship $ */

PROCEDURE CREATE_ABS_VALIDATION ( P_ABS_INFORMATION_CATEGORY varchar2
                                    ,P_PERSON_ID in NUMBER
				    ,P_EFFECTIVE_DATE in DATE
				    ,P_ABS_INFORMATION1 in VARCHAR2
                                    ,P_ABS_INFORMATION2 in VARCHAR2
                                    ,P_ABS_INFORMATION3 in VARCHAR2
                                    ,P_ABS_INFORMATION5 in VARCHAR2
                                    ,P_ABS_INFORMATION6 in VARCHAR2
                                    ,P_ABS_INFORMATION15 in VARCHAR2
                                    ,P_ABS_INFORMATION16 in VARCHAR2
                                    ,P_DATE_START in DATE
                                    ,P_DATE_END in DATE
				    ,P_DATE_PROJECTED_START in DATE
				    ,P_DATE_PROJECTED_END in DATE
                                    ,P_ABS_ATTENDANCE_REASON_ID in NUMBER) is

 CURSOR csr_get_gender(l_person_id NUMBER, l_date DATE) IS
 SELECT sex FROM per_all_people_f
  WHERE person_id = l_person_id
    AND l_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

-- Cursor to fetch global values
CURSOR csr_get_glb_value(p_global_name VARCHAR2, p_effective_date DATE) IS
SELECT fnd_number.canonical_to_number(global_value)
FROM  ff_globals_f
WHERE global_name = p_global_name
AND   legislation_code = 'NO'
AND   p_effective_date BETWEEN effective_start_date AND effective_end_date;

CURSOR csr_get_person_hire_date(p_person_id number,p_effective_date date) IS
SELECT start_date,PER_INFORMATION7 FROM per_all_people_f where
person_id = p_person_id
AND P_EFFECTIVE_DATE BETWEEN EFFECTIVE_START_DATE
     AND EFFECTIVE_END_DATE;

CURSOR CSR_SICKNESS_ELIG_CHECK (personid NUMBER) IS
SELECT (PAA.DATE_END - PAA.DATE_START) + 1 AS DAYS,PAA.DATE_START, PAA.DATE_END
 FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
  AND PAT.ABSENCE_CATEGORY = 'UN'
  AND PAA.DATE_START IS NOT NULL
  AND PAA.DATE_END IS NOT NULL
  AND PAA.PERSON_ID = personid
  ORDER BY DATE_START ;

CURSOR CSR_REASON_CODE ( attn_reason_id NUMBER) IS
select name from PER_ABS_ATTENDANCE_REASONS  par
WHERE PAR.ABS_ATTENDANCE_REASON_ID = attn_reason_id ;

CURSOR CSR_3SC_SICKNESS_CHECK(personid NUMBER, abs_start_date DATE, abs_link_period NUMBER) IS
   SELECT DATE_START
         ,DATE_END
    FROM PER_ABSENCE_ATTENDANCES
   WHERE PERSON_ID = personid
     AND DATE_END BETWEEN (abs_start_date - abs_link_period) AND (abs_start_date -1)
     AND ABS_INFORMATION1 = 'SC'
     AND DATE_START IS NOT NULL
     AND DATE_END IS NOT NULL;

  l_gender varchar2(5);
  l_date_of_birth date;
  l_elig_start_date DATE;
  l_reason_code varchar2(30);
  l_abs_min_gap number;
  l_person_id   number;
  l_abs_start_date date;
  l_abs_end_date date;
  l_person_hire_date date;
  l_entitled_sc           Varchar2(10);
  l_abs_count             Number(5);
  l_months_employed_prev number;
  l_months_employed_curr number;
  l_eligible varchar2(4);
  l_min_worked_months number;
  l_abs_link_period number;
  l_within_n_months number;
  l_months_employed number;
  l_check_start_date date;
  l_tot_abs  Number;  -- Bug#8905705 fix

BEGIN

  OPEN csr_get_gender(P_PERSON_ID,P_EFFECTIVE_DATE);
  FETCH csr_get_gender INTO l_gender;
  CLOSE csr_get_gender;
  --Error If gender is Male and apply leave for Maternity or Part Time Maternity
  IF P_ABS_INFORMATION_CATEGORY IN ('NO_M','NO_PTM') THEN
     IF l_gender = 'M' then
        fnd_message.set_name('PAY','PAY_376876_NO_MATERNITY_LEAVE');
        fnd_message.raise_error;
     END IF;
  END IF;

  --Error If gender is Female and apply leave for Paternity or Part Time Paternity
  IF P_ABS_INFORMATION_CATEGORY IN ('NO_PA','NO_PTP') THEN
     IF l_gender = 'F' then
        fnd_message.set_name('PAY','PAY_376877_NO_PATERNITY_LEAVE');
        fnd_message.raise_error;
     END IF;
  END IF;

  -- Error If initial absence is set to Yes and also a linking absence attached to the same absence
  IF (P_ABS_INFORMATION15 = 'Y' AND P_ABS_INFORMATION16 is NOT NULL) THEN
     Fnd_message.set_name('PAY','PAY_376916_NO_ABS_LINKING_INI');
     fnd_message.raise_error;
  END IF;
 -- Error - If initial absence is set to No and no linking absence is provided
 IF (P_ABS_INFORMATION15 = 'N'  AND P_ABS_INFORMATION16 is NULL) THEN
     Fnd_message.set_name('PAY','PAY_376917_NO_ABS_LINKING_DTL');
     fnd_message.raise_error;
 END IF;
 IF P_ABS_INFORMATION_CATEGORY IN ('NO_S','NO_PTS') AND
    P_ABS_INFORMATION15 is null AND P_ABS_INFORMATION16 is NOT NULL THEN
      Fnd_message.set_name('PAY','PAY_376916_NO_ABS_LINKING_INI');
      fnd_message.raise_error;
 END IF;

	l_person_id := P_PERSON_ID;
	l_abs_start_date := NVL(P_DATE_START,P_DATE_PROJECTED_START);
        l_abs_end_date := NVL(P_DATE_END,P_DATE_PROJECTED_END);

     OPEN csr_get_person_hire_date(l_person_id, l_abs_start_date);
     FETCH csr_get_person_hire_date INTO l_person_hire_date,l_entitled_sc;
     CLOSE csr_get_person_hire_date;

     OPEN csr_get_glb_value('NO_ABS_MIN_GAP',l_abs_start_date);
     FETCH csr_get_glb_value INTO l_abs_min_gap;
     CLOSE csr_get_glb_value;

     OPEN csr_get_glb_value('NO_ABS_LINK_PERIOD',l_abs_start_date);
     FETCH csr_get_glb_value INTO l_abs_link_period;
     CLOSE csr_get_glb_value;


 IF P_ABS_INFORMATION_CATEGORY IN ('NO_S','NO_PTS','NO_CMS') THEN
    -- Error - if the certificate end date is earlier than the certificate start date
    IF P_ABS_INFORMATION3 < P_ABS_INFORMATION2 THEN
       Fnd_message.set_name('PAY','PAY_376908_NO_ST_END_DATE_VAL');
       fnd_message.raise_error;
    END IF;

     --Find the eligiblity date
     l_elig_start_date := l_person_hire_date + l_abs_min_gap ;
     FOR i in CSR_SICKNESS_ELIG_CHECK (l_person_id) LOOP
       IF i.date_start < l_elig_start_date THEN
          l_elig_start_date := l_elig_start_date + i.days ;
       ELSE
          EXIT;
       END IF;
     END LOOP;

     OPEN csr_reason_code (P_ABS_ATTENDANCE_REASON_ID);
     FETCH csr_reason_code INTO l_reason_code;
     CLOSE csr_reason_code ;

      -- Error - When an absence is recorded before eligibility 28 days
      IF (l_abs_start_date < l_elig_start_date) AND (l_reason_code is NULL or l_reason_code <> 'ABS_WA') THEN
         Fnd_message.set_name('PAY','PAY_376910_NO_EMP_NOT_ELIGIBLE');
         Fnd_message.raise_error;
      END IF;

  -- Error - if Self-Certificate is selected and the employee has had Self-Certified Sickness absences
  -- totaling more than 3 days in the previous 14 days
  IF P_ABS_INFORMATION_CATEGORY IN ('NO_S','NO_PTS') AND P_ABS_INFORMATION1 = 'SC' THEN
     l_abs_count := 0;
     l_tot_abs := (l_abs_end_date - l_abs_start_date) + 1;   -- Bug#8905705 fix
     FOR I IN CSR_3SC_SICKNESS_CHECK (l_person_id,l_abs_start_date,l_abs_link_period )
     LOOP
       IF i.DATE_START < (l_abs_start_date - l_abs_link_period) THEN
          l_abs_count := ( i.DATE_END - (l_abs_start_date - l_abs_link_period) ) +1;
       ELSIF i.DATE_END > (l_abs_start_date-1) THEN
          l_abs_count := ((l_abs_start_date-1) - i.DATE_START )+1;
       ELSIF i.DATE_END = i.DATE_START THEN
          l_abs_count := 1;
       ELSE
          l_abs_count := (i.DATE_END - i.DATE_START)+1 ;
       END IF;
       l_tot_abs := l_tot_abs + l_abs_count; -- Bug#8905705 fix
     END LOOP;

      IF l_tot_abs > 3 THEN -- Bug#8905705 fix
       Fnd_message.set_name('PAY','PAY_376869_NO_ABS_SELF_CERT');
         Fnd_message.raise_error;
      END IF;

      --Error - Only 4 self certificate absences are allowed for an year.
        BEGIN
             SELECT count(1)
               INTO l_abs_count
               FROM PER_ABSENCE_ATTENDANCES PAA
              WHERE PAA.PERSON_ID = l_person_id
                AND PAA.DATE_END BETWEEN add_months(l_abs_start_date, -12) AND (l_abs_start_date-1)
                AND PAA.ABS_INFORMATION1 = 'SC'
                AND PAA.DATE_START IS NOT NULL
                AND PAA.DATE_END IS NOT NULL;
        EXCEPTION
           WHEN OTHERS THEN
                l_abs_count := 0;
        END;
        IF l_abs_count >= 4 THEN
  	   Fnd_message.set_name('PAY','PAY_376907_NO_SC_NOT_ELIGIBLE');
           Fnd_message.raise_error;
        END IF;

  END IF;

  IF P_ABS_INFORMATION_CATEGORY IN ('NO_S','NO_PTS') THEN
    -- Error - if the Entitltment for self certificate is No and type is selected as Self certification
    IF l_entitled_sc = 'N' AND P_ABS_INFORMATION1 = 'SC' THEN
      Fnd_message.set_name('PAY','PAY_376907_NO_SC_NOT_ELIGIBLE');
      Fnd_message.raise_error;
    END IF;

      -- Error - if the Self certification is used and the service is less than 2 months
      l_months_employed_curr := trunc(months_between(l_abs_start_date,l_person_hire_date),2);
      IF l_months_employed_curr < 2 AND P_ABS_INFORMATION1 = 'SC' THEN
	 Fnd_message.set_name('PAY','PAY_376907_NO_SC_NOT_ELIGIBLE');
         Fnd_message.raise_error; -- This is warning not error
      END IF;
  END IF;

  END IF;


    IF P_ABS_INFORMATION_CATEGORY IN ('NO_PA','NO_PTP','NO_M','NO_PTM','NO_IE_AL','NO_PTA') THEN

	l_months_employed_prev :=0;
	l_months_employed_curr :=0;
	l_months_employed := 0;
	l_eligible := 'N';

	l_months_employed_curr := trunc(months_between(l_abs_start_date,l_person_hire_date),2);

	OPEN csr_get_glb_value('NO_ABSENCE_MIN_MONTHS_SERVICE_REQUIRED',l_abs_start_date);
	FETCH csr_get_glb_value INTO l_min_worked_months;
	CLOSE csr_get_glb_value;

	IF l_months_employed_curr >= l_min_worked_months THEN --changed to global
		l_eligible := 'Y';
	ELSE
		OPEN csr_get_glb_value('NO_ABSENCE_SERVICE_REQUIRED_WITHIN_MONTHS',l_abs_start_date);
		FETCH csr_get_glb_value INTO l_within_n_months;
		CLOSE csr_get_glb_value;

		l_within_n_months := -1 * l_within_n_months;
		l_check_start_date := add_months(l_abs_start_date - 1,l_within_n_months); --changed to global
		l_months_employed_prev := PAY_NO_ABSENCE.get_months_employed(l_person_id,l_check_start_date,l_person_hire_date);
		l_months_employed := l_months_employed_curr + l_months_employed_prev;
		IF l_months_employed >= l_min_worked_months THEN --changed to global
			l_eligible := 'Y';
		END IF;
		l_within_n_months := -1 * l_within_n_months;
	END IF;

	IF l_eligible = 'N' THEN
		--fnd_message.debug ('Person is not eligible to avail this absence as he/she is not employed for 6/10 months'); -- put proper warning message
		fnd_message.set_name('PAY','PAY_376875_NO_PARENTAL_ELIGIBL');
		fnd_message.set_token('MIN',to_char(l_min_worked_months));
		fnd_message.set_token('LIMIT',to_char(l_within_n_months));
		Fnd_message.raise_error;

       END IF;
       IF P_ABS_INFORMATION_CATEGORY IN ('NO_PA','NO_PTP') THEN
          -- Error - if the absence start date is earlier than the date of birth
          l_date_of_birth := fnd_date.canonical_to_date(P_ABS_INFORMATION1) ;
          IF l_date_of_birth > P_DATE_START THEN
             Fnd_message.set_name('PAY','PAY_376905_NO_DOB_ST_DT_CHECK');
             Fnd_message.raise_error;
          END IF;
       END IF;
       IF  P_ABS_INFORMATION_CATEGORY  ='NO_M' THEN
         IF NVL(P_ABS_INFORMATION5,'N') = 'N' AND  P_ABS_INFORMATION6 IS NOT NULL THEN
            fnd_message.set_name('PER','HR_376901_NO_ABS_NO_SPOUSE');
            fnd_message.raise_error;
         END IF;
       END IF ;
    END IF;
END CREATE_ABS_VALIDATION ;

--Update Mode validations
procedure UPDATE_ABS_VALIDATION (P_ABS_INFORMATION_CATEGORY in varchar2
                                    ,P_ABSENCE_ATTENDANCE_ID in NUMBER
                                    ,P_EFFECTIVE_DATE in DATE
                                    ,P_ABS_INFORMATION1 in VARCHAR2
                                    ,P_ABS_INFORMATION2 in VARCHAR2
                                    ,P_ABS_INFORMATION3 in VARCHAR2
                                    ,P_ABS_INFORMATION5 in VARCHAR2
                                    ,P_ABS_INFORMATION6 in VARCHAR2
                                    ,P_ABS_INFORMATION15 in VARCHAR2
                                    ,P_ABS_INFORMATION16 in VARCHAR2
                                    ,P_DATE_START in DATE
                                    ,P_DATE_END in DATE
				    ,P_DATE_PROJECTED_START in DATE
				    ,P_DATE_PROJECTED_END in DATE
                                    ,P_ABS_ATTENDANCE_REASON_ID in NUMBER) is

-- Get the person Id
CURSOR get_person_id (p_abs_attendance_id in NUMBER) is
SELECT person_id
  FROM PER_ABSENCE_ATTENDANCES
 WHERE ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

 l_person_id NUMBER;
BEGIN

    OPEN get_person_id(P_ABSENCE_ATTENDANCE_ID);
    FETCH get_person_id INTO l_person_id;
    CLOSE get_person_id;

    -- Get the Person ID and pass it to Absence Create level validation package
    CREATE_ABS_VALIDATION (P_ABS_INFORMATION_CATEGORY
                          ,l_person_id
                          ,P_EFFECTIVE_DATE
                          ,P_ABS_INFORMATION1
                          ,P_ABS_INFORMATION2
                          ,P_ABS_INFORMATION3
                          ,P_ABS_INFORMATION5
                          ,P_ABS_INFORMATION6
                          ,P_ABS_INFORMATION15
                          ,P_ABS_INFORMATION16
                          ,P_DATE_START
                          ,P_DATE_END
			  ,P_DATE_PROJECTED_START
			  ,P_DATE_PROJECTED_END
                          ,P_ABS_ATTENDANCE_REASON_ID ) ;

END UPDATE_ABS_VALIDATION;

END  PAY_NO_ABS_VALIDATION;

/
