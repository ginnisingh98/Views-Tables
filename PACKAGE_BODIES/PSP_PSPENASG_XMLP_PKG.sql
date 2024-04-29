--------------------------------------------------------
--  DDL for Package Body PSP_PSPENASG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPENASG_XMLP_PKG" AS
/* $Header: PSPENASGB.pls 120.4 2007/10/29 07:21:18 amakrish noship $ */

function cf_change_sourceformula(change_type in varchar2) return char is
  CURSOR c_source IS
	SELECT 	meaning
	FROM	fnd_lookups
	WHERE	lookup_type = 'PSP_ENC_CHANGE_SOURCE'
	AND	lookup_code =  change_type;

   v_source fnd_lookups.meaning%TYPE;

BEGIN

   OPEN 	c_source;
   FETCH 	c_source INTO v_source;
   CLOSE 	c_source;

RETURN v_source;

EXCEPTION
WHEN 	NO_DATA_FOUND
THEN	RETURN('No Data Found');

WHEN 	OTHERS
THEN	RETURN('Other Error');

end;

function cf_org_nameformula(reference_id in number, assignment_id in number, action_type in varchar2, change_type in varchar2) return char is
CURSOR c_org IS
	SELECT	name
	FROM		hr_all_organization_units
	WHERE		organization_id = reference_id;

CURSOR c_org_acct IS
	SELECT	hrou.name
	FROM		hr_all_organization_units hrou,
					Psp_organization_accounts poa
	WHERE		poa.organization_id = hrou.organization_id
	AND			poa.organization_account_id = reference_id;

CURSOR c_org_enc_date IS
	SELECT	hrou.name
	FROM		hr_all_organization_units hrou,
					Psp_enc_end_dates peed
	WHERE		peed.organization_id = hrou.organization_id
	AND		peed.enc_end_date_id = reference_id;


CURSOR c_org_acct_del IS
	SELECT hou.name
	FROM	hr_all_organization_units hou,
		per_all_assignments_f paf
	WHERE	paf.assignment_id =assignment_id
	AND	paf.organization_id= hou.organization_id
	AND	sysdate between paf.effective_start_date and paf.effective_end_date;



 CURSOR c_org_def_sch IS
	SELECT	hrou.name
	FROM		hr_all_organization_units hrou,
					psp_default_labor_schedules pdls
	WHERE		pdls.organization_id = hrou.organization_id
	AND		pdls.org_schedule_id = reference_id;


 CURSOR  c_org_generic_del IS
SELECT hou.name
FROM	hr_organization_units hou ,
	psp_enc_changed_sch_history pecsh
WHERE  hou.organization_id = pecsh.reference_id
AND  	pecsh.request_id = p_request_id
AND 	pecsh.change_type = 'GS'
AND 	pecsh.action_type ='G' ;

v_orgName	hr_all_organization_units.name%TYPE;

BEGIN

IF	action_type = 'I'
THEN

	IF 	change_type IN ('DA', 'SA', 'DS', 'GS')
	THEN
		OPEN   c_org;
		FETCH c_org INTO v_orgName;
		CLOSE c_org;
	END IF;

ELSIF	action_type ='U'  THEN
	IF 	change_type IN ('DA', 'SA','GS') 	THEN
		OPEN  c_org_acct;
		FETCH c_org_acct INTO v_orgName;

		IF c_org_acct%NOTFOUND THEN
		        		 IF change_type IN ( 'GS') THEN
         			 OPEN   c_org_generic_del;
           			 FETCH c_org_generic_del INTO v_orgName;
            			 CLOSE c_org_generic_del;
         		 ELSE
				OPEN c_org_acct_del;
				FETCH 	c_org_acct_del INTO v_OrgName;
				CLOSE c_org_acct_del;
			END IF;  		END IF;			CLOSE c_org_acct;
	ELSIF 	change_type = 'OE'
	THEN
		OPEN 	c_org_enc_date;
		FETCH	c_org_enc_date INTO v_orgName;
		CLOSE	c_org_enc_date;


	ELSIF  change_type ='DS' THEN
		OPEN c_org_def_sch;
		FETCH c_org_def_sch INTO v_orgName;

		IF c_org_def_sch%NOTFOUND THEN
			OPEN c_org_acct_del;
			FETCH 	c_org_acct_del INTO v_OrgName;
			CLOSE c_org_acct_del;
		END IF;			CLOSE c_org_def_sch;
	END IF;   END IF;

 RETURN(v_orgName);

EXCEPTION
	WHEN 	NO_DATA_FOUND
	THEN	RETURN('No Data Found');

	WHEN 	OTHERS
	THEN	RETURN('Other Error');

END;

function cf_element_nameformula(reference_id in number, action_type in varchar2, change_type in varchar2) return char is

CURSOR c_element IS
	SELECT	element_name
	FROM		pay_element_types_f petf
	WHERE		element_type_id = reference_id
	AND ( trunc(sysdate) BETWEEN effective_start_date AND effective_end_date
  OR ( trunc(sysdate) < (select min(effective_start_date ) from pay_element_types_f petf1
where petf1.element_type_id= petf.element_type_id)));

CURSOR c_element_acct IS
	SELECT	pet.element_name
	FROM		pay_element_types_f pet,
					Psp_element_type_accounts peta
	WHERE		pet.element_type_id = peta.element_type_id
	AND			Peta.element_account_id = reference_id
	AND ( trunc(sysdate) BETWEEN pet.effective_start_date AND
pet.effective_end_date
 OR ( trunc(sysdate) < (select min(effective_start_date ) from pay_element_types_f petf1
where petf1.element_type_id= pet.element_type_id)));


CURSOR c_element_acct_del IS
	SELECT	 pet.element_name
	FROM 	 pay_element_types_f  pet,
	psp_enc_lines_history pelh
	WHERE
	pelh.element_account_id= reference_id
	AND 	pelh.enc_element_type_id= pet.element_type_id
	AND	rownum=1 ;

	v_elementName  pay_element_types_f.element_name%TYPE;


BEGIN

        IF	action_type ='U'   	THEN
		IF	change_type IN ('ED')
		THEN
			OPEN   c_element;
			FETCH c_element INTO v_elementName;
			CLOSE c_element;
 		ELSIF	change_type IN ('GE')
		THEN
			OPEN   c_element_acct;
			FETCH c_element_acct INTO v_elementName;

     			IF c_element_acct%NOTFOUND THEN
				OPEN c_element_acct_del;
				FETCH c_element_acct_del INTO v_elementname;
				CLOSE c_element_acct_del;
			 END IF; 			CLOSE c_element_acct;
		END IF;

	ELSIF	action_type  = 'I'
	THEN
		IF	change_type IN ('GE')
		THEN

			OPEN   c_element;
			FETCH c_element INTO v_elementName;
			CLOSE c_element;
		END IF;
END IF;

	RETURN(v_elementName);

EXCEPTION
	WHEN 	NO_DATA_FOUND
	THEN	RETURN('No Data Found');

	WHEN 	OTHERS
	THEN	RETURN('Other Error');

END;

function BeforeReport return boolean is
begin


		--hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
	--hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PSP_PSPENASG_XMLP_PKG ;

/
