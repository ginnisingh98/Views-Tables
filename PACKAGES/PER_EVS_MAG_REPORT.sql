--------------------------------------------------------
--  DDL for Package PER_EVS_MAG_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVS_MAG_REPORT" AUTHID CURRENT_USER as
/* $Header: peevsmag.pkh 120.3.12010000.2 2009/06/01 11:55:43 kagangul ship $ */
--

level_cnt                     number ;

FUNCTION f_evs_rem_spl_char(p_input_string IN VARCHAR2)
RETURN VARCHAR2;

/*
**  Cursor to retrieve Westpac Direct Entry system Header info
*/
cursor c_evs is
SELECT  -- Bug # 8528862 : Need to remove characters like <'. ->
	--'LAST_NAME=P'       	 ,substr(ppf.last_name,1,13)
        'LAST_NAME=P'       	 ,substr(per_evs_mag_report.f_evs_rem_spl_char(ppf.last_name),1,13)
	-- Bug # 8528862 : Need to remove characters like <'. ->
        --,'MIDDLE_NAME=P' 	 ,nvl(substr(ppf.middle_names,1,7),' ')
	,'MIDDLE_NAME=P' 	 ,nvl(substr(per_evs_mag_report.f_evs_rem_spl_char(ppf.middle_names),1,7),' ')
	-- Bug # 8528862 : Need to remove characters like <'. ->
	--,'FIRST_NAME=P'	 ,nvl(substr(ppf.first_name,1,10),' ')
	,'FIRST_NAME=P'		 ,nvl(substr(per_evs_mag_report.f_evs_rem_spl_char(ppf.first_name),1,10),' ')
	,'SSN=P'             	 ,nvl((substr(ppf.national_identifier,1,3) || substr(ppf.national_identifier,5,2) || substr(ppf.national_identifier,8,4)),' ')
	,'DATE_OF_BIRTH=P'	 ,nvl(to_char(ppf.date_of_birth,'MMDDYYYY'),' ')
	,'GENDER=P'		 ,nvl(substr(ppf.sex,1,1),' ')
	,'REQUESTER_ID_CODE=P'   ,nvl(hoi.org_information1,' ')
	,'USER_CONTROL_DATA=P'   ,nvl(hoi.org_information2,' ')
	,'MULTI_REQ_INDICATOR=P' ,nvl(hoi.org_information3,' ')

FROM    pay_assignment_actions       paa
        ,per_all_assignments_f       paf
	,per_all_people_f            ppf
        ,hr_organization_information hoi

 WHERE paa.payroll_action_id = fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(3))
 AND paa.assignment_id = paf.assignment_id
 AND paf.person_id = ppf.person_id
 AND paf.primary_flag = 'Y'
 AND paf.effective_start_date = (SELECT max(paf2.effective_start_date)
                                 FROM per_assignments_f paf2
				 WHERE paf.person_id = paf2.person_id
				 AND paf2.primary_flag = 'Y'
				 )
 AND ppf.effective_start_date =  (SELECT max(ppf2.effective_start_date)
                                  FROM per_all_people_f ppf2
				  WHERE ppf.person_id = ppf2.person_id
				  )
 AND paa.tax_unit_id = hoi.organization_id(+)
 AND hoi.org_information_context(+) = 'EVS Filing'
 ORDER BY national_identifier ;

/* Replaced by the above query to avoid duplicate persons being reported */
/* Select
        'LAST_NAME=P'       	,substr(ppf.last_name,1,13)
  ,     'MIDDLE_NAME=P' 	,nvl(substr(ppf.middle_names,1,7),' ')
  ,     'FIRST_NAME=P'		,nvl(substr(ppf.first_name,1,10),' ')
  ,     'SSN=P'             	,nvl((substr(ppf.national_identifier,1,3) || substr(ppf.national_identifier,5,2) || substr(ppf.national_identifier,8,4)),' ')
  ,     'DATE_OF_BIRTH=P'	,nvl(to_char(ppf.date_of_birth,'MMDDYYYY'),' ')
  ,     'GENDER=P'		,nvl(substr(ppf.sex,1,1),' ')
  ,     'REQUESTER_ID_CODE=P'   ,nvl(hoi.org_information1,' ')
  ,     'USER_CONTROL_DATA=P'   ,nvl(hoi.org_information2,' ')
  ,     'MULTI_REQ_INDICATOR=P' ,nvl(hoi.org_information3,' ')
 From
  pay_assignment_actions paa
 ,per_all_assignments_f      paf
 ,per_all_people_f           ppf
 ,hr_organization_information hoi
 where
      paa.payroll_action_id =
        fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(3))
  and paa.assignment_id = paf.assignment_id
  and paf.person_id = ppf.person_id
  and paf.effective_start_date =
      (select max(paf2.effective_start_date)
       from per_assignments_f paf2
       where  paf.assignment_id = paf2.assignment_id
      )
 -- and ppf.effective_start_date = paf.effective_start_date
  and ppf.effective_start_date =
      (select max(ppf2.effective_start_date)
       from per_all_people_f ppf2
       where  ppf.person_id = ppf2.person_id
      )
 and paa.tax_unit_id = hoi.organization_id(+)
 and hoi.org_information_context(+) = 'EVS Filing'
 Order by   national_identifier ; */


----------------------------------------------------------------------------
-- For PYUGEN
----------------------------------------------------------------------------
procedure get_parameters
  (p_payroll_action_id in number
  );
--
procedure range_cursor
  (pactid in number
  ,sqlstr out nocopy varchar2
  );

PROCEDURE action_creation(
  pactid      IN NUMBER,
  stperson    IN NUMBER,
  endperson   IN NUMBER,
  chunk       IN NUMBER
  );

PROCEDURE init_code(
  p_payroll_action_id in number
  );

----------------------------------------------------------------------------
procedure evs_mag_report_main
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  --
  ,p_start_date                  in  varchar2
  ,p_end_date                    in  varchar2
  ,p_tax_unit_id                 in  number
  ,p_business_group_id           in  number
  ,p_report_category             in  varchar2
  ,p_media_type                  in  varchar2
 );
--
procedure evs_put_record
  (p_file_id                     in utl_file.file_type
  ,p_ssn                         in varchar2
  ,p_last_name                   in varchar2
  ,p_first_name                  in varchar2
  ,p_middle_name                 in varchar2
  ,p_date_of_birth               in date
  ,p_gender                      in varchar2
  ,p_user_control_data           in varchar2
  ,p_requester_id_code           in varchar2
  ,p_multiple_req_indicator      in varchar2
  );
--
end per_evs_mag_report;

/
