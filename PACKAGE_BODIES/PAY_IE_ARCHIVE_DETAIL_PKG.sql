--------------------------------------------------------
--  DDL for Package Body PAY_IE_ARCHIVE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_ARCHIVE_DETAIL_PKG" as
/* $Header: pyieelin.pkb 120.1 2006/12/11 13:44:37 sgajula noship $ */

/*
   NAME
     pyieelin.pkb -- procedure  IE Tax Details
--
   DESCRIPTION
     this procedure is used by to retrieve Element Information.

  MODIFIED       (DD-MON-YYYY)
  ILeath         10-NOV-2001 - Initial Version.
  aashokan       17-DEC-2004   Bug 4069789
  aashokan       23-DEC-2004   Bug 4083856
  sgajula        11-DEC-2006   Bug 5696117
*/

-------------------------------------------------------------------------
--
FUNCTION get_tax_details(p_run_assignment_action_id number,
                         p_input_value_id number,
                         p_date_earned varchar2)
RETURN varchar2
IS
--
-- Retrieve the details via the element entry values table
--
 cursor element_type_value is
   SELECT peev.screen_entry_value,
          pee.updating_action_id
   FROM pay_element_entry_values_f peev,
        pay_element_entries_f    pee,
        pay_assignment_actions   paa
   WHERE  pee.element_entry_id = peev.element_entry_id
   AND    pee.assignment_id    = paa.assignment_id
   AND    paa.assignment_action_id  = p_run_assignment_action_id
   AND    peev.input_value_id +0  = p_input_value_id
   AND    to_date(p_date_earned, 'YYYY/MM/DD')
   BETWEEN
          pee.effective_start_date
      AND pee.effective_end_date
   AND  to_date(p_date_earned, 'YYYY/MM/DD')
   BETWEEN
          peev.effective_start_date
      AND peev.effective_end_date;
 --
 -- Retrieve the details via the run result
 --
 cursor result_type_value is
     SELECT    result_value
     FROM      pay_run_result_values   prr,
               pay_run_results         pr,
               pay_element_types_f     pet,
               pay_input_values_f      piv
     WHERE     pr.assignment_action_id   =   p_run_assignment_action_id
     and       pr.element_type_id        =   pet.element_type_id
     and       pr.run_result_id          =   prr.run_result_id
     and       prr.input_value_id        =   piv.input_value_id
     and       pet.element_type_id       =   piv.element_type_id
     and       piv.input_value_id        =   p_input_value_id
     and       piv.business_group_id     IS NULL
     and       piv.legislation_code      =  'IE'
     and       to_date(p_date_earned, 'YYYY/MM/DD')
               between piv.effective_start_date
               and piv.effective_end_date
     and       to_date(p_date_earned, 'YYYY/MM/DD')
               between pet.effective_start_date
               and pet.effective_end_date;
--
 l_legislation_code  varchar2(30) := 'IE';
 pay_result_value          varchar2 (60);
 error_string              varchar2 (60);
 l_el_pay_result_value     varchar2 (60);
 l_updating_action_id      number;
--
BEGIN
--
  error_string := to_char(p_input_value_id);
--
  open element_type_value;
  fetch element_type_value into l_el_pay_result_value,
                                l_updating_action_id;
  close element_type_value;
--
-- Check to see whether the element entry value is update recurring
--
  if l_updating_action_id is null then
     --
     -- Not update recurring, so select from Run Results
     --
     open result_type_value;
     fetch result_type_value into pay_result_value;
     close result_type_value;
     --
     if pay_result_value is null then
        --
        -- No R.R. val, so use the value retrieved by the element.
        --
        pay_result_value := l_el_pay_result_value;
     --
     end if;
  --
  else
     --
     -- E.E. Value is update recurring, use the value
     --
     pay_result_value := l_el_pay_result_value;
     --
  end if;
--
  return pay_result_value;
--
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                pay_result_value := NULL;
                hr_utility.trace('TEST pay_result_value : NULL ');
                return pay_result_value;
--
END get_tax_details;
--
-------------------------------------------------------------------------

/*FUNCTION get_parameter accepts payroll_action_id and returns parameter values
 from legislative parameters in pay_payroll_actions */
 --
FUNCTION get_parameter(p_payroll_action_id   NUMBER,
                       p_token_name          VARCHAR2) RETURN VARCHAR2 AS

CURSOR csr_parameter_info(p_pact_id IN NUMBER) IS
SELECT legislative_parameters
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_token_value                     VARCHAR2(50);
l_parameter  pay_payroll_actions.legislative_parameters%TYPE := NULL;
l_delimiter  varchar2(1):=' ';
l_start_pos  NUMBER;
--

BEGIN
--
  hr_utility.set_location('p_token_name = ' || p_token_name,20);
  OPEN csr_parameter_info(p_payroll_action_id);
  FETCH csr_parameter_info INTO l_parameter;
  CLOSE csr_parameter_info;
  l_start_pos := instr(' '||l_parameter,l_delimiter||p_token_name||'=');
 IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||l_parameter,l_delimiter||p_token_name||'=');
  end if;
  IF l_start_pos <> 0 THEN
   l_start_pos := l_start_pos + length(p_token_name||'=');
    l_token_value := substr(l_parameter,
                          l_start_pos,
                          instr(l_parameter||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
                          end if;

--
     l_token_value := trim(l_token_value);
--
  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || 'get_parameters',30);

  RETURN l_token_value;

END get_parameter;


PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT NOCOPY VARCHAR2) IS
CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token))),
       business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;
l_business_group_id               VARCHAR2(20);
l_token_value                     VARCHAR2(50);
BEGIN
  hr_utility.set_location('p_token_name = ' || p_token_name,20);
  OPEN csr_parameter_info(p_payroll_action_id,p_token_name);
  FETCH csr_parameter_info INTO l_token_value,l_business_group_id;
  CLOSE csr_parameter_info;
  p_token_value := trim(l_token_value);
  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || 'get_parameters',30);
END get_parameters;
--------------------------------------------------------------------------------+
 --Function get_paypathid is used to fetch Paypath ids for a Consolidation Set
--------------------------------------------------------------------------------+
 -- Bug No 3060464 Start
 -- Bug 5696117 cached the paypathid to improve the performace
 FUNCTION get_paypathid return varchar2 as
     --Cursor to fetch  paypath ids for all payrolls within a consolidation set
     CURSOR CSR_PAYROLLS
     IS
     SELECT   count(distinct org_information8) paycount,
              org_information8
     FROM     pay_all_payrolls_f papf
        ,     hr_organization_information org
        ,     hr_soft_coding_keyflex sck
      WHERE
              papf.consolidation_set_id    =  pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_ID')
              and  to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'),'YYYY/MM/DD HH24:MI:SS')
              between papf.effective_start_date and papf.effective_end_date
      and     org.org_information_context  = 'IE_PAYPATH_INFORMATION'
      and     papf.SOFT_CODING_KEYFLEX_ID  =  sck.SOFT_CODING_KEYFLEX_ID
      and     org.ORG_INFORMATION_ID       =  to_number(sck.segment2)
      and     org.org_information8 is not null
      group by org_information8;
      --Cursor to fetch first paypath id defined at BG Level
      CURSOR CSR_BG_PAYPATH
      IS
      SELECT  org.org_information8
      FROM    hr_organization_information    org
         ,    pay_payroll_actions            ppa
      WHERE
              ppa.payroll_action_id        =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
      and     org.organization_id          =  ppa.business_group_id
      and     org.org_information_context  =  'IE_PAYPATH_INFORMATION'
      and     rownum=1;
      --Cursor to fetch paypath id for a specified payroll parameter
      CURSOR CSR_PAYROLL_PAYPATH
      IS
      SELECT  org.org_information8
      FROM    hr_organization_information org
      WHERE
              org.org_information_context  = 'IE_PAYPATH_INFORMATION'
              and org.ORG_INFORMATION_ID   =
                      (SELECT  to_number(segment2)
                       FROM
			        hr_soft_coding_keyflex sck
		       ,        pay_all_payrolls_f papf
		       ,        pay_payroll_actions ppa
                       WHERE
			        papf.SOFT_CODING_KEYFLEX_ID =  sck.SOFT_CODING_KEYFLEX_ID
		       and      papf.payroll_id             =  pay_magtape_generic.get_parameter_value('PAYROLL_ID')
		       and      papf.consolidation_set_id   =  pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_ID')
		       and      ppa.effective_date between papf.effective_start_date and papf.effective_end_date
		       and      ppa.payroll_action_id       =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
		       and      papf.payroll_id=ppa.payroll_id);
      l_paypath_ids     csr_payrolls%rowtype;
      l_bg_pathid       csr_bg_paypath%rowtype;
      l_payroll_pathid  csr_payroll_paypath%rowtype;
      cnt number :=0;
      e_submit_error exception;
      l_paypathid varchar2(150);
 BEGIN
 --Only consolidation set specified as parameter in IE PayPath Process
 IF  pay_magtape_generic.get_parameter_value('PAYROLL_ID') is null then
	BEGIN
	  IF (g_consolidation_set_id is null) then
		OPEN csr_payrolls;
		LOOP
   			FETCH csr_payrolls into l_paypath_ids;
   	        EXIT when csr_payrolls%NOTFOUND;
	           l_paypathid:=l_paypath_ids.org_information8;
                   cnt:=cnt+1;
                   --PayPath process errors when a consolidation set has multiple payrolls, which in turn have multiple Paypath ID's
                   if cnt>=2 then
                        raise e_submit_error;
                   end if;
			 g_paypathid := l_paypathid;
		END LOOP;
		g_consolidation_set_id := pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_ID');
	  END IF;
        --If no Paypath ids are specified at payroll level,Paypath id  defined at BG level is picked up.
	if cnt=0 then
		IF (g_payroll_action_id is null) then
	           OPEN  CSR_BG_PAYPATH;
	           FETCH CSR_BG_PAYPATH into l_bg_pathid;
	           --If no paypath ids defined at BG level and payroll level
	           IF CSR_BG_PAYPATH%NOTFOUND THEN
	 	    	l_paypathid:= ' ';
			g_paypathid := l_paypathid;
	 	        return l_paypathid;
	 	     END IF;
		   CLOSE CSR_BG_PAYPATH;
		   g_paypathid := l_bg_pathid.org_information8;
		   g_payroll_action_id := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
	 	   return g_paypathid;
 	   END IF;
     end if;
        --If payrolls in the consolidation set all have the same paypath id, then that paypath id is picked up.
	return g_paypathid;
        EXCEPTION when e_submit_error then
                   l_paypathid:='Error';
			 g_paypathid := l_paypathid ;
	 	   return g_paypathid;
        END;
  ELSE
     --Payroll name as well as the consolidation set specified as parameter then ,select paypath id specified at the payroll level
     IF (g_payroll_id is null or g_consolidation_set_id is null) then
                   OPEN   CSR_PAYROLL_PAYPATH;
                   FETCH  CSR_PAYROLL_PAYPATH into l_payroll_pathid;
                   --Bug No 3086034 Start
                   IF  CSR_PAYROLL_PAYPATH%NOTFOUND THEN
                        --Payroll name specified as a parameter but ,no paypath id defined for that payroll,hence it picks up
                        --paypath id defined at BG Level
                        OPEN  CSR_BG_PAYPATH;
                        FETCH CSR_BG_PAYPATH into l_bg_pathid;
                        CLOSE CSR_BG_PAYPATH;
				        g_paypathid := l_bg_pathid.org_information8;
                        return  g_paypathid;
                   END IF;
                    --Bug No 3086034 End
                   CLOSE  CSR_PAYROLL_PAYPATH;
			 g_paypathid := l_payroll_pathid.org_information8;
			 g_payroll_id := pay_magtape_generic.get_parameter_value('PAYROLL_ID');
			 g_consolidation_set_id :=  pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_ID');
	   return  g_paypathid ;
    END IF;
  END IF;
  return g_paypathid;
END get_paypathid;
-- Bug No 3060464 End

END PAY_IE_ARCHIVE_DETAIL_PKG;

/
