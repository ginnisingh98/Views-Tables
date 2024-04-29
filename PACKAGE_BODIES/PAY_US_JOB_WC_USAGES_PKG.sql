--------------------------------------------------------
--  DDL for Package Body PAY_US_JOB_WC_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_JOB_WC_USAGES_PKG" as
/* $Header: pyuswcdf.pkb 115.0 99/07/17 06:48:16 porting ship $ */

PROCEDURE run (errbuf              	OUT 	VARCHAR2,
  		            retcode              	OUT 	NUMBER,
  		            p_business_group_id 	IN      NUMBER,
  		            p_state_code              	IN      VARCHAR2,
			    p_default_wc_code		IN  	NUMBER) IS

--
-- Local Variables :
--
l_state_code          VARCHAR2(50) := p_state_code;
l_Business_group_id   NUMBER := p_business_group_id;
l_default_code        NUMBER := p_default_wc_code;
l_exists              NUMBER := 0;
l_valid               NUMBER := 0;
--
CURSOR csr_jobs( l_business_group_id NUMBER) IS
SELECT job_id
FROM per_jobs
WHERE business_group_id = l_business_group_id
ORDER BY name;
--
CURSOR csr_valid_job_code(p_job_code NUMBER, l_state_code VARCHAR2) IS
SELECT 1
FROM pay_wc_funds wcf, pay_wc_rates wcr
WHERE wcr.wc_code = p_job_code         /* reference */
  AND wcr.fund_id = wcf.fund_id        /* for this fund */
  AND wcf.state_code = l_state_code; /* in this state */
--
CURSOR csr_records_exist(l_state_code VARCHAR2, l_business_group_id NUMBER) IS
SELECT 1
FROM pay_job_wc_code_usages
WHERE state_code = l_state_code
  AND business_group_id = l_business_group_id;
--
BEGIN /* Main program */
--
/*Check for existing records*/
OPEN csr_records_exist(l_state_code, l_business_group_id);
FETCH csr_records_exist INTO l_exists;
IF csr_records_exist%FOUND THEN
 hr_utility.set_message(801,'PAY_51838_JWC_JOB_ALREADY_ASS');
 RAISE hr_utility.hr_error;
END IF;
CLOSE csr_records_exist;


--
/* Check that a valid job code has been defined */
OPEN csr_valid_job_code(l_default_code, l_state_code);
FETCH csr_valid_job_code INTO l_valid;
IF csr_valid_job_code%NOTFOUND THEN
 hr_utility.set_message(801,'PAY_51838_JWC_JOB_CD_INVALID');
 RAISE hr_utility.hr_error;
END IF;
CLOSE csr_valid_job_code;
--
--
  FOR cur_rec IN csr_jobs(l_business_group_id) LOOP
--
    INSERT INTO pay_job_wc_code_usages
          (state_code,
           business_group_id,
           job_id,
           wc_code)
    VALUES(l_state_code,
           l_business_group_id,
           cur_rec.job_id,
           l_default_code);
--
--
  END LOOP;
--
EXCEPTION
   --
   WHEN hr_utility.hr_error THEN
     --
     -- Set up error message and error return code.
     --
     errbuf  := hr_utility.get_message;
     retcode := 2;
     --
--
WHEN others THEN
--
     -- Set up error message and return code.
     --
     errbuf  := sqlerrm;
     retcode := 2;
--
END run;

END pay_us_job_wc_usages_pkg;
--


/
