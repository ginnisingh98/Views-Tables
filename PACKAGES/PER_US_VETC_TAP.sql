--------------------------------------------------------
--  DDL for Package PER_US_VETC_TAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VETC_TAP" AUTHID CURRENT_USER AS
/* $Header: petapvtc.pkh 115.6 2002/03/13 07:37:13 pkm ship    $ */
/*
 * **************************************************************************
*

  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All Rights Reserved.

  PRODUCT
    Oracle Human Resources

  NAME


  DESCRIPTION
    Magnetic tape format procedure.

1.0 Overview

  A PL/SQL package will be written for each type of magnetic tape. The packag
e
  will include all cursors and procedures required for the particular magneti
c
  tape format. A stored procedure provides the top level of control flow for
  the magnetic tape file generation. This may call other procedures dependant

  on the state of the cursors and the input parameters.

  The stored procedure will be called before each execution of a
  formula. Parameters returned as results of the previous formula execution
  will be passed to the procedure. The procedure must handle all context
  cursors needed and may also set parameters required by the formula.

  Using NACHA as an example, for the file header record formula, a call
  to a cursor which fetches legal_company_id must be performed.

  The interface between the 'C' process and the stored procedure will make
  extensive use of PL/SQL tables. PL/SQL tables are single column tables whic
h
  are accessed by an integer index value. Items in the tables will use indexe
s
  begining with 1 and increasing contiguously to the number of elements. The
  index number will be used to match items in the name and value tables.

  The first element in the value tables will always be the number of elements
  available in the table. The elements in the tables will be of type VARCHAR2
  any conversion necessary should be performed within the PL/SQL procedure.

  The parameters returned by formula execution will be passed
  to the stored procedure. Parameters may or may not be altered by the PL/SQL
  procedure and will be passed back to the formula for the next execution.
  Context tables will always be reset by the PL/SQL procedure.

  The names of the tables used to interface with the PL/SQL procedure are
       param_names     type IN/OUT
       param_values    type IN/OUT
       context_names   type OUT
       context_values  type OUT

  The second item in the output_parameter_value table will be the formula ID
  of the next formula to be executed (the first item is the number of values
  in the table).

    Change List
    -----------
    Date        Name      Vers    Bug No   Description
    ----        ----      ----    ------   -----------
    18-AUG-98   ASAHAY    110.0            Created.
    24-AUG-98   ASAHAY    110.1            VETS100_reporting Name =
					   Consolidated
    24-SEP-98   ASAHAY    110.2            Corrected typo in S_VETC_VETS_NH
    18-SEP-00   ASAHAY    110.3            added cursor for min count
    20-SEP-00   ASAHAY    110.4            commented check for GRE
					   in VETS Count
    28-SEP-00   ASAHAY    110.5            Corrected Date Formats

  Package header:
-- Cursors

*/


LEVEL_CNT NUMBER;

/*
Selects tax_unit_id and/or establishment_id - so indicating what type of organization we are processing. i.e. Whether it is a tax unit only, establishment only or a combination.
*/

CURSOR S_VETC_GRE IS
SELECT	'TRANSFER_TAX_UNIT_ID=P',
	htuv.tax_unit_id,
       	'TRANSFER_ESTABLISHMENT_ID1=P',
	 est.establishment_id
FROM    hr_establishments_v est,
        hr_organization_units hou1,
        hr_organization_units hou2,
        hr_tax_units_v htuv
WHERE   htuv.tax_unit_id(+)  	= hou1.organization_id
AND     hou1.organization_id   	=
        pay_magtape_generic.get_parameter_value('TRANSFER_ORG_ID')
AND     est.establishment_id(+)	= hou2.organization_id
AND     hou2.organization_id   	=
        pay_magtape_generic.get_parameter_value('TRANSFER_ORG_ID')
AND     hou2.business_group_id  =
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID');



/* Select company and establishment details. Will loop through hierarchy if we have GRE parent and EST siblings - producing one page per GRE/EST pairing. */

CURSOR S_VETC_RE IS
SELECT  'TRANSFER_GRE_STATE=P'					,
        psr1.state_code 					,
	'TRANSFER_EST_STATE=P'					,
        psr2.state_code 					,
        'TRANSFER_ESTABLISHMENT_ID=P'				,
	est.establishment_id					,
	   'TRANSFER_MSC=P'					,
	   to_char(count(distinct(est.establishment_id)))	,
        'TRANSFER_VETS100_COMPANY_NUMBER=P'			,
	htuv.vets100_company_number 				,
        'TRANSFER_VETS100_UNIT_NUMBER=P'			,
	est.vets100_unit_number   				,
        'TRANSFER_SIC=P'					,
	est.sic                                			,
        'TRANSFER_HQ_VETS100_REPORTING_NAME=P'			,
	upper(nvl(htuv.vets100_reporting_name, htuv.name)) 	,
        'TRANSFER_EST_VETS100_REPORTING_NAME=P'			,
/*        upper(nvl(est.vets100_reporting_name, est.name)) 	, */
        'CONSOLIDATED'                                          ,
        'TRANSFER_HQLOC_ADDRESS=P'				,
	upper(rpad(cloc.address_line_1 ||' '|| cloc.address_line_2 ||' '||
                cloc.address_line_3,35))                   	,
        'TRANSFER_ELOC_ADDRESS=P'				,
	upper(rpad(eloc.address_line_1 ||' '|| eloc.address_line_2 ||' '||
                eloc.address_line_3,35))                   	,
        'TRANSFER_HQLOC_TOWN_OR_CITY=P'				,
	upper(cloc.town_or_city)                           	,
        'TRANSFER_HQLOC_REGION_1=P'				,
	upper(cloc.region_1)           	                    	,
        'TRANSFER_ELOC_TOWN_OR_CITY=P'				,
	upper(eloc.town_or_city)                           	,
        'TRANSFER_ELOC_REGION_1=P'				,
	upper(eloc.region_1)                               	,
        'TRANSFER_HQLOC_REGION_2=P'				,
	upper(cloc.region_2)                               	,
        'TRANSFER_HQLOC_POSTAL_CODE=P'				,
	upper(cloc.postal_code)                            	,
        'TRANSFER_ELOC_REGION_2=P'				,
	upper(eloc.region_2)                               	,
        'TRANSFER_ELOC_POSTAL_CODE=P'				,
	upper(eloc.postal_code)                            	,
        'TRANSFER_EIN=P'					,
	htuv.employer_identification_number			,
        'TRANSFER_DUN=P'					,
	htuv.dun_and_bradstreet_number
FROM    hr_locations 		cloc	,
        hr_locations 		eloc	,
        hr_tax_units_v 		htuv	,
        hr_establishments_v 	est	,
        hr_organization_units 	hou1	,
        hr_organization_units 	hou2	,
        pay_state_rules         psr1	,
        pay_state_rules         psr2
WHERE   htuv.tax_unit_id (+)    =  hou1.organization_id
AND     hou1.organization_id 	=
        pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID')
AND     cloc.location_id(+)  	= htuv.location_id
AND     cloc.region_2           = psr1.state_code
AND     eloc.location_id(+)  	= est.location_id
AND     est.establishment_id 	=  hou2.organization_id
AND     eloc.region_2           = psr2.state_code
AND     eloc.region_2           =
nvl(pay_magtape_generic.get_parameter_value('TRANSFER_STATE'), eloc.region_2)
AND     ((hou2.organization_id  =
        pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID1')
              AND
	pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID1')
		is not null)
              OR
     (	      pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
		is not null
              AND  est.establishment_id in
		--
		-- Start with the GRE, head down to find the establishments,
	(
	 select ose.organization_id_child
	 from   per_org_structure_elements ose
	 where  ose.org_structure_version_id +0  =
pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
	 connect by prior ose.organization_id_child = ose.organization_id_parent
	 and	ose.org_structure_version_id +0 =
pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
	 start with ose.organization_id_parent =
        pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID')
	 and    ose.org_structure_version_id + 0 =
pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
	)
      )    )
group by
        psr1.state_code 					,
        psr2.state_code 					,
	est.establishment_id					,
	htuv.vets100_company_number 				,
	est.vets100_unit_number   				,
	est.sic                                			,
	upper(nvl(htuv.vets100_reporting_name, htuv.name)) 	,
	upper(rpad(cloc.address_line_1 ||' '|| cloc.address_line_2 ||' '||
                cloc.address_line_3,35))                   	,
	upper(rpad(eloc.address_line_1 ||' '|| eloc.address_line_2 ||' '||
                eloc.address_line_3,35))                   	,
	upper(cloc.town_or_city)                           	,
	upper(cloc.region_1)           	                    	,
	upper(eloc.town_or_city)                           	,
	upper(eloc.region_1)                               	,
	upper(cloc.region_2)                               	,
	upper(cloc.postal_code)                            	,
	upper(eloc.region_2)                               	,
	upper(eloc.postal_code)                            	,
	htuv.employer_identification_number			,
	htuv.dun_and_bradstreet_number
;


/*  This has to be in a separate query becase of the counting mechanism
    and the fact we have to display a row for the job category even if the
    category is not used in any jobs */

CURSOR S_VETC_JOBS IS
SELECT  'TRANSFER_JOB_CATEGORY_NAME=P',
        upper(rpad(meaning,32,'.'))|| lookup_code,
        'TRANSFER_JOB_CATEGORY_CODE=P',
        lookup_code
FROM    hr_lookups
WHERE   lookup_type = 'US_EEO1_JOB_CATEGORIES'
ORDER BY lookup_code ;



/* Count all people within job categories where person is assigned to current
   tax unit and establishment. If the establishment on the assignment is null
   then we search the hierarchy (using the current establishment as root)  to
   pick up Personnel Organizations and count the employee if his assignment
   personnel organization is part of the hierarchy. Thereby we can default
   establishments by making use of existing Personnel Information.
*/

CURSOR S_VETC_VETS IS
SELECT  'TRANSFER_NO_DIS_VETS=P',
	count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,'OTEDV',1,'DVOEV',1,null))  no_dis_vets,
        'TRANSFER_NO_VIET_VETS=P',
	count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,'DVOEV',1,'VOEVV',1,null)) no_viet_vets,
        'TRANSFER_NO_OT_EV=P',
nvl(count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,'VOEVV',1,null)),0)
FROM    per_people_f	      		peo,
        per_assignments_f              	ass,
        hr_organization_information  	hoi1,
        hr_organization_information 	hoi2,
        hr_soft_coding_keyflex          scf,
        per_jobs                       	job
WHERE   peo.person_id                  	= ass.person_id
AND     job.job_information_category   	= 'US'
AND     job.date_from 			<=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))   >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     job.job_information1           	=
        pay_magtape_generic.get_parameter_value('TRANSFER_JOB_CATEGORY_CODE')
AND     ass.job_id                     	= job.job_id
AND     peo.effective_start_date       	<=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.effective_end_date         	>=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.current_employee_flag      	= 'Y'
AND     ass.assignment_type  		= 'E'
AND     ass.primary_flag     		= 'Y'
AND     ass.assignment_status_type_id+0   = hoi1.org_information1
AND     hoi1.org_information_context    = 'Reporting Statuses'
AND     hoi1.organization_id            =
        pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.employment_category         = hoi2.org_information1
AND     hoi2.organization_id            =
        pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     hoi2.org_information_context    = 'Reporting Categories'
AND     ass.effective_start_date        <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.effective_end_date          >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.soft_coding_keyflex_id 	= scf.soft_coding_keyflex_id
-- AND     scf.segment1  			=
--         pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID')
/* AND  	EXISTS
                      (
                       SELECT    htuv.tax_unit_id
                       FROM      hr_tax_units_v htuv,
                                 hr_locations gloc
                       WHERE     htuv.tax_unit_id  =  scf.segment1
                       AND       htuv.location_id  =  gloc.location_id
                       AND       gloc.region_2      = -- :gre_state
        pay_magtape_generic.get_parameter_value('TRANSFER_GRE_STATE')
                       ) */
AND     (scf.segment9  = -- :establishment_id
        pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
                  OR       scf.segment9 is null
                  AND
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID') <> -1
                   AND  ass.organization_id IN
                      (
                       SELECT -- :establishment_id
to_number(pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID'))
                       FROM    dual
                       UNION
                       SELECT ose.organization_id_child
                       FROM   per_org_structure_elements ose
                       WHERE  ose.org_structure_version_id + 0 =
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
--                       AND       ose.organization_id_child = ass.organization_id
                        CONNECT BY PRIOR ose.organization_id_child =
                                ose.organization_id_parent
                       AND        ose.org_structure_version_id + 0 =
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
--                       AND       ose.organization_id_child = ass.organization_id
                       START WITH ose.organization_id_parent =
	pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
                      )
               );


/* Count all people within job categories where person is assigned to current
   tax unit and establishment. If the establishment on the assignment is null
   then we search the hierarchy (using the current establishment as root)  to
   pick up Personnel Organizations and count the employee if his assignment
   personnel organization is part of the hierarchy. Thereby we can default
   establishments by making use of existing Personnel Information.
*/

CURSOR  S_VETC_VETS_NH IS
SELECT  'TRANSFER_TOT_NEW_HIRES=P',
	count(peo.person_id) tot_new_hires,
        'TRANSFER_NO_NH_DIS_VETS=P',
	count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,'OTEDV',1,'DVOEV',1,null))no_nh_dis_vets,
        'TRANSFER_NO_NH_VIET_VETS=P',
	count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,'DVOEV',1,'VOEVV',1,null))no_nh_viet_vets,
        'TRANSFER_NO_NH_OT_EV=P',
nvl(count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,'VOEVV',1,null)),0)
FROM    per_people_f            	peo,
        per_assignments_f              	ass,
        hr_organization_information   	hoi1,
        hr_organization_information   	hoi2,
        hr_soft_coding_keyflex        	scf,
        per_jobs                        job
WHERE   peo.person_id                	= ass.person_id
AND     job.job_information_category   	= 'US'
AND     job.date_from 			<=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))   >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     job.job_information1                     =
pay_magtape_generic.get_parameter_value('TRANSFER_JOB_CATEGORY_CODE')
AND     ass.job_id                                       = job.job_id
AND     peo.effective_start_date                <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.effective_end_date                 >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.current_employee_flag             = 'Y'
AND     peo.start_date between
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
and
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.assignment_type                      = 'E'
AND     ass.primary_flag                              = 'Y'
AND     ass.assignment_status_type_id+0  = hoi1.org_information1
AND     hoi1.org_information_context        = 'Reporting Statuses'
AND     hoi1.organization_id                        =
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.employment_category             = hoi2.org_information1
AND     hoi2.org_information_context        = 'Reporting Categories'
AND     hoi2.organization_id                        =
        pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.effective_start_date                  <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.effective_end_date                    >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.soft_coding_keyflex_id            = scf.soft_coding_keyflex_id
-- AND     scf.segment1  =
-- 	pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID')
/* AND  EXISTS
                      (
                       SELECT    htuv.tax_unit_id
                       FROM      hr_tax_units_v htuv,
                                        hr_locations gloc
                       WHERE    htuv.tax_unit_id  =  scf.segment1
                       AND         htuv.location_id  =  gloc.location_id
                       AND         gloc.region_2      = -- :gre_state
        pay_magtape_generic.get_parameter_value('TRANSFER_GRE_STATE')
                       ) */
AND     (scf.segment9  = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
                  OR       scf.segment9 is null
                  AND    --  :P_ORG_STRUCTURE_VERSION_ID
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID') <> -1
                  AND  ass.organization_id IN
                      (
                       SELECT
	to_number(pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID'))
                       FROM    dual
                       UNION
                       SELECT ose.organization_id_child
                       FROM   per_org_structure_elements ose
                       WHERE  ose.org_structure_version_id + 0 =
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
--                       AND       ose.organization_id_child = ass.organization_id
                        CONNECT BY PRIOR ose.organization_id_child =
                                ose.organization_id_parent
                       AND        ose.org_structure_version_id + 0 =
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
--                       AND       ose.organization_id_child = ass.organization_id
                       START WITH ose.organization_id_parent =
	pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
                      )
               );


/*
Count employee assignments. We use this to determine company size and so distinguish between those companies with 50 or more employees.
*/

cursor S_VETC_ASG_COUNT is
SELECT  'TRANSFER_COUNT_ASSIGNMENTS=P',
	count(ass.assignment_id)
FROM    per_assignments_f            ass,
        hr_establishments_v          hev,
        hr_locations                 hl,
        pay_state_rules              psr,
        hr_organization_information  hoi1,
        hr_soft_coding_keyflex       scf,
        per_jobs                     job
WHERE   job.job_information_category        = 'US'
AND     job.date_from <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))   >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     job.job_information1                is not null
AND     ass.job_id                          = job.job_id
AND     ass.business_group_id+0               =
        pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.assignment_type                 = 'E'
AND     ass.primary_flag                    = 'Y'
AND     ass.assignment_status_type_id +0      = hoi1.org_information1
AND     hoi1.org_information_context        = 'Reporting Statuses'
AND     hoi1.organization_id                =
        pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.effective_start_date            <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.effective_end_date              >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.soft_coding_keyflex_id          = scf.soft_coding_keyflex_id
AND     hev.establishment_id                =
        pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
AND     hev.location_id                     = hl.location_id
AND     hl.region_2                         = psr.state_code
AND     hl.region_2                         =
nvl(pay_magtape_generic.get_parameter_value('TRANSFER_STATE'), hl.region_2)
AND     scf.segment1                        =
        pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID')
AND     (scf.segment9  =
        pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
             OR       scf.segment9 is null
             AND      -- :P_ORG_STRUCTURE_VERSION_ID
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID') <> -1
             AND      ass.organization_id IN
        (
         SELECT
         to_number(pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID'))
         FROM   dual
         UNION
         SELECT ose.organization_id_child
         FROM   per_org_structure_elements ose
         WHERE  ose.org_structure_version_id + 0 =
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
--         AND    ose.organization_id_child    = ass.organization_id
         CONNECT BY PRIOR ose.organization_id_child =
                                ose.organization_id_parent
         AND ose.org_structure_version_id + 0 =
	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
--         AND ose.organization_id_child    = ass.organization_id
         START WITH ose.organization_id_parent =
         pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
));

cursor S_VETC_MIN_COUNT is
SELECT  'TRANSFER_MIN_COUNT_ASSIGNMENTS=P',
        count (distinct pds.person_id)
FROM    per_periods_of_service          pds,
        per_assignments_f               ass,
        hr_soft_coding_keyflex          scf,
        per_jobs                        job
WHERE   pds.date_start <
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     (nvl(pds.actual_termination_date,
        to_date('12/31/4712','MM/DD/YYYY')) >
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS'))
AND     pds.person_id           = ass.person_id
AND     ass.assignment_type     = 'E'
AND     ass.primary_flag        = 'Y'
AND     ass.business_group_id   =
        pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.effective_start_date <
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
        and ass.effective_end_date >
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.job_id = job.job_id
AND     job.job_information_category = 'US'
AND     job.date_from           <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to,to_date('31/12/4712','DD/MM/YYYY')) >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.soft_coding_keyflex_id      = scf.soft_coding_keyflex_id
AND     scf.segment1            =
        pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID')
AND     (scf.segment9           =
        pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
              OR        scf.segment9 is null
AND     pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')  <> -1
AND     ass.organization_id IN
                      (
                       SELECT to_number(pay_magtape_generic.get_parameter_value(
'TRANSFER_ESTABLISHMENT_ID'))
                       FROM    dual
                       UNION
                       SELECT ose.organization_id_child
                       FROM   per_org_structure_elements ose
                       WHERE  ose.org_structure_version_id + 0 =
        pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
                       CONNECT BY PRIOR ose.organization_id_child =
                       ose.organization_id_parent
                       AND    ose.org_structure_version_id + 0 =
        pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
                       START WITH ose.organization_id_parent =
        pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
                      ));

end;

 

/
