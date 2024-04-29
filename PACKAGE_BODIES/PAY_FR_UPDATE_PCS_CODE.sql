--------------------------------------------------------
--  DDL for Package Body PAY_FR_UPDATE_PCS_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_UPDATE_PCS_CODE" as
/* $Header: pyfrupcs.pkb 115.3 2004/01/02 00:08 ayegappa noship $ */

procedure update_old_pcs_codes (errbuf                 OUT NOCOPY VARCHAR2,
                                 retcode               OUT NOCOPY NUMBER,
		                 p_business_group_id   in         number)
is

cursor csr_get_job (c_business_group_id  number) is
select   pj.job_id             job_id
        ,pj.name               job_name
        ,pj.job_information1   pcs_code
from     per_jobs pj
where    business_group_id        = c_business_group_id
and      JOB_INFORMATION_CATEGORY = 'FR'
and      not exists (select 1
                     from   fnd_common_lookups fcl
		     where  fcl.lookup_type = 'FR_NEW_PCS_CODE'
		     and    fcl.lookup_code = pj.job_information1);

cursor csr_get_new_code (c_pcs_code in varchar2) is
select   description new_code
from     fnd_common_lookups
where    lookup_code = c_pcs_code
and      lookup_type = 'FR_PCS_CODE';

l_new_code      fnd_common_lookups.description%type;

--Getting the message
l_value         varchar2(240);

begin
   FOR get_pcs_code IN csr_get_job (p_business_group_id)
   LOOP
          l_new_code := null;
	  l_value    := null;
          OPEN csr_get_new_code (get_pcs_code.pcs_code);
	  FETCH csr_get_new_code INTO l_new_code;
	  CLOSE csr_get_new_code;
          IF l_new_code IS NULL THEN
             l_value := pay_fr_general.get_payroll_message('PAY_75193_OLD_CODE', null, null, null);
	     fnd_file.put_line(fnd_file.log, get_pcs_code.job_name||', old pcs code '|| get_pcs_code.pcs_code||l_value||' '||get_pcs_code.job_id);
             /* Making the old pcs code to be null.  The user will take the jobs from the log message and change the
	     old pcs codes to new pcs codes manually */
	     update per_jobs
	     set    job_information1 = NULL
	     where  business_group_id        = p_business_group_id
             and    JOB_INFORMATION_CATEGORY = 'FR'
	     and    job_id                   = get_pcs_code.job_id;
	  ELSE
             update per_jobs
	     set    job_information1 = l_new_code
	     where  business_group_id        = p_business_group_id
             and    JOB_INFORMATION_CATEGORY = 'FR'
	     and    job_id                   = get_pcs_code.job_id;
             l_value := pay_fr_general.get_payroll_message('PAY_75194_UPDATED', null, null, null);
	     fnd_file.put_line(fnd_file.log, get_pcs_code.job_name||', old pcs code '|| get_pcs_code.pcs_code||' converted to ' ||l_new_code||'.  '||l_value||' '||get_pcs_code.job_id);
	  END IF;
   END LOOP;
end update_old_pcs_codes;

End pay_fr_update_pcs_code;

/
