--------------------------------------------------------
--  DDL for Package Body PER_NL_FDR_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NL_FDR_ARCHIVE" as
/* $Header: penlfdra.pkb 120.2 2007/12/19 13:41:38 abhgangu noship $ */


	/*------------------------------------------------------------------------------
	|Name           : GET_PARAMETER    					        |
	|Type           : Function						        |
	|Description    : Funtion to get the parameters of the archive process          |
	-------------------------------------------------------------------------------*/
    g_year   VARCHAR2(10);

	FUNCTION get_parameter	(p_parameter_string in varchar2
	        		,p_token            in varchar2
	        		,p_segment_number   in number default null )    RETURN varchar2
	IS

	  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
	  l_start_pos  NUMBER;
	  l_delimiter  varchar2(1):=' ';

	BEGIN
		--
		--hr_utility.set_location('Entering get_parameter',52);
		--
		l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
		--
		IF l_start_pos = 0 THEN
			l_delimiter := '|';
			l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
		end if;

		IF l_start_pos <> 0 THEN
			l_start_pos := l_start_pos + length(p_token||'=');
			l_parameter := substr(p_parameter_string,
								  l_start_pos,
								  instr(p_parameter_string||' ',
								  l_delimiter,l_start_pos)
								  - l_start_pos);
			IF p_segment_number IS NOT NULL THEN
				l_parameter := ':'||l_parameter||':';
				l_parameter := substr(l_parameter,
									instr(l_parameter,':',1,p_segment_number)+1,
									instr(l_parameter,':',1,p_segment_number+1) -1
									- instr(l_parameter,':',1,p_segment_number));
			END IF;
		END IF;
		--
		--hr_utility.set_location('Leaving get_parameter',53);
		--hr_utility.set_location('Entering get_parameter l_parameter--'||l_parameter||'--',54);
		RETURN l_parameter;

	END get_parameter;


	/*-----------------------------------------------------------------------------
	|Name       : GET_ALL_PARAMETERS                                               |
	|Type       : Procedure							       |
	|Description: Procedure which returns all the parameters of the archive	process|
	-------------------------------------------------------------------------------*/


	PROCEDURE get_all_parameters	(p_payroll_action_id	IN NUMBER
					,p_report_date		OUT NOCOPY VARCHAR2
					,p_org_struct_id	OUT NOCOPY NUMBER
					,p_person_id		OUT NOCOPY NUMBER
					,p_org_id		OUT NOCOPY NUMBER
					,p_bg_id		OUT NOCOPY NUMBER) IS
	--
	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS

	SELECT PER_NL_FDR_ARCHIVE.get_parameter(legislative_parameters,'REPORT_DATE')
	      ,TO_NUMBER(PER_NL_FDR_ARCHIVE.get_parameter(legislative_parameters,'ORG_STRUCT_ID'))
	      ,TO_NUMBER(PER_NL_FDR_ARCHIVE.get_parameter(legislative_parameters,'PERSON_ID'))
	      ,TO_NUMBER(PER_NL_FDR_ARCHIVE.get_parameter(legislative_parameters,'ORG_ID'))
	      ,business_group_id
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;

	--
	l_parameter_string PAY_PAYROLL_ACTIONS.LEGISLATIVE_PARAMETERS%TYPE;

	BEGIN

		--hr_utility.set_location('Entering get_all_parameters',51);

		OPEN csr_parameter_info (p_payroll_action_id);
		FETCH csr_parameter_info INTO p_report_date
					     ,p_org_struct_id
					     ,p_person_id
					     ,p_org_id
					     ,p_bg_id;
		CLOSE csr_parameter_info;

		select	ppa.legislative_parameters into l_parameter_string
		from	pay_payroll_actions	ppa
		where	ppa.payroll_action_id = p_payroll_action_id;


		IF instr(l_parameter_string,'/',1,2) - instr(l_parameter_string,'/',1,1) = 3 THEN

			p_report_date := substr(l_parameter_string,instr(l_parameter_string,'/',1,1)-4,10);

		END IF;

        --hr_utility.set_location('Leaving get_all_parameters',54);
	END;



	FUNCTION get_IANA_charset RETURN VARCHAR2 IS
	    CURSOR csr_get_iana_charset IS
	        SELECT tag
	          FROM fnd_lookup_values
	         WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
	           AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
	                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
	           AND language = 'US';

	    lv_iana_charset fnd_lookup_values.tag%type;
	BEGIN
	    OPEN csr_get_iana_charset;
	        FETCH csr_get_iana_charset INTO lv_iana_charset;
	    CLOSE csr_get_iana_charset;

	    --hr_utility.trace('IANA Charset = '||lv_iana_charset);
	    RETURN (lv_iana_charset);
	END get_IANA_charset;



	/*-----------------------------------------------------------------------------
	|Name       : WRITETOCLOB_RTF                                                  |
	|Type       : Procedure							       |
	|Description: Procedure to write contents of XML file as CLOB                  |
	-------------------------------------------------------------------------------*/


	PROCEDURE WritetoCLOB_rtf(p_xfdf_clob out nocopy clob, p_XMLTable IN tXMLTable) IS

	l_xfdf_string clob;
	l_str0 varchar2(1000);
	l_str1 varchar2(1000);
	l_str2 varchar2(20);
	l_str3 varchar2(20);
	l_str4 varchar2(1000);
	l_str5 varchar2(1000);
	l_str6 varchar2(1000);
	l_str7 varchar2(1000);
	l_str8 varchar2(20);


	begin
	--fnd_file.put_line(fnd_file.log,'g_year : '||g_year);
    hr_utility.set_location('Entered Procedure Write to clob ',100);
	--	l_str0 := '<?xml version="1.0" encoding="UTF-8"?>';
	--	l_str0 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?>';
		l_str0 := '<?xml version="1.0" encoding="ISO-8859-1"?>';			-- for bug 5376513
		IF g_year < '2008' THEN
          l_str1 := '<Eerstedagsmelding xmlns="http://xml.belastingdienst.nl/schemas/Eerstedagsmelding/2006/02" version="1.0">' ;
		ELSE
          l_str1 := '<Eerstedagsmelding xmlns="http://xml.belastingdienst.nl/schemas/Eerstedagsmelding/'||g_year||'/01" version="1.1">' ;
        END IF;
        l_str2 := '<';
		l_str3 := '>';
	--	l_str4 := '<value>' ;
	--	l_str5 := '</value> </' ;
		l_str4 := '</Eerstedagsmelding>';
		l_str5 := '<Eerstedagsmelding xmlns="http://xml.belastingdienst.nl/schemas/Eerstedagsmelding/2006/02" version="1.0"></Eerstedagsmelding>';
		l_str8 := '</';
		dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
		dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
		dbms_lob.writeAppend( l_xfdf_string, length(l_str0), l_str0);
		if p_XMLTable.count > 0 then
			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
	        	FOR ctr_table IN p_XMLTable.FIRST .. p_XMLTable.LAST LOOP
	        		l_str6 := p_XMLTable(ctr_table).TagName;
	        		l_str7 := p_XMLTable(ctr_table).TagValue;
				if (l_str6 = 'Bericht' OR l_str6 = 'AdministratieveEenheid' OR l_str6 = 'Dienstbetrekking' OR l_str6 = 'NatuurlijkPersoon') then
	        		        if (l_str7 is null) then
	        		        dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2);
					dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6);
					dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3);
					else
						if (l_str7 = 'END') then
							dbms_lob.writeAppend( l_xfdf_string, length(l_str8), l_str8);
	        					dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6);
							dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3);
						end if;
					end if;
			        else
		        		if (l_str7 is not null) then
						dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2);
						dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6);
						dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3);
						dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7);
						dbms_lob.writeAppend( l_xfdf_string, length(l_str8), l_str8);
						dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6);
						dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3);
					elsif (l_str7 is null and l_str6 is not null) then
						dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
					else
						null;
					end if;
				end if;
			END LOOP;
			dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
		else
			dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
		end if;
		DBMS_LOB.CREATETEMPORARY(p_xfdf_clob,TRUE);
		p_xfdf_clob := l_xfdf_string;
		hr_utility.set_location('Finished Procedure Write to CLOB  ',110);
		EXCEPTION
			WHEN OTHERS then
		        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
		        HR_UTILITY.RAISE_ERROR;
	END WritetoCLOB_rtf;



	/*------------------------------------------------------------------------------
	|Name           : CHECK_TAX_DETAILS    					        |
	|Type           : Function                                                      |
	|Description    : Returns 1 if the organization has tax details attached        |
	-------------------------------------------------------------------------------*/


	FUNCTION check_tax_details	(p_org_id IN NUMBER) RETURN NUMBER IS

	l_return_val NUMBER := 0;

	BEGIN

		BEGIN

		select 1 INTO l_return_val
		from	hr_organization_units hou
		where	hou.organization_id = p_org_id
		and	EXISTS	(SELECT 1 FROM hr_organization_information hoi1

							WHERE	hoi1.org_information_context= 'NL_ORG_INFORMATION'
							AND	hoi1.organization_id=hou.organization_id
							AND	hoi1.org_information4 IS NOT NULL
							AND	hoi1.org_information3 IS NOT NULL

							UNION

							SELECT 1 FROM hr_organization_information hoi2

							WHERE	hoi2.org_information_context= 'NL_LE_TAX_DETAILS'
							AND	hoi2.organization_id=hou.organization_id
							AND	hoi2.org_information1 IS NOT NULL
							AND	hoi2.org_information2 IS NOT NULL

					);

		EXCEPTION

			WHEN TOO_MANY_ROWS
				THEN l_return_val := 1;

			WHEN NO_DATA_FOUND
				THEN null;

		END;

		return l_return_val;

	END check_tax_details;


	/*------------------------------------------------------------------------------
	|Name           : GET_REF_DATE                                                  |
	|Type           : Function                                                      |
	|Description    : Function to return the date at which the assignment record    |
	|                 needs to be picked for an employee.                           |
	-------------------------------------------------------------------------------*/


	FUNCTION get_ref_date	(p_person_id IN NUMBER)	return DATE is

	l_ref_date	DATE := to_date('31-12-4712','DD-MM-RRRR');

	BEGIN

		select	ppos.date_start into l_ref_date
		from	per_periods_of_service	ppos
		where	ppos.person_id = p_person_id
		and	ppos.date_start =
				(select max(ppos1.date_start)
				from	per_periods_of_service ppos1
				where	ppos1.person_id = p_person_id);

		BEGIN

			select	distinct pap.effective_start_date into l_ref_date
			from	per_all_people_f	pap
			where	pap.person_id = p_person_id
			and	pap.effective_start_date =
					(select max(pap1.effective_start_date)
					from	per_all_people_f pap1
					where	pap1.person_id = p_person_id
					and	pap1.current_employee_flag = 'Y')
			and 	exists	(select 1 from per_people_extra_info ppei
					where ppei.person_id=p_person_id
					and information_type='NL_FIRST_DAY_REPORT'
					and ppei.pei_information2='Y');

			EXCEPTION

				WHEN NO_DATA_FOUND
				THEN
					null;
		END;

		return l_ref_date;

	END get_ref_date;





	/*------------------------------------------------------------------------------
	|Name           : EMP_CHECK                                                     |
	|Type           : Function                                                      |
	|Description    : Function required for valueset HR_NL_EMPLOYEE_FDR             |
	-------------------------------------------------------------------------------*/


	FUNCTION emp_check	(p_bg_id IN NUMBER
				,p_org_struct_id IN NUMBER
				,p_org_id IN NUMBER
				,p_person_id IN NUMBER
				,p_report_date IN DATE) return NUMBER IS

	l_return_val NUMBER := 0;

	BEGIN

		IF p_org_id is not NULL THEN
			BEGIN

				select	1 INTO l_return_val
				from	per_all_assignments_f		paa,
					per_assignment_status_types	past,
					per_all_people_f		pap,
					per_periods_of_service		ppos,
					per_org_structure_versions	posv

				where	posv.organization_structure_id=p_org_struct_id
				and	p_report_date between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)
				and	(paa.organization_id in
			                ((SELECT	pose.organization_id_child
			                  FROM		per_org_structure_elements pose
			                  WHERE		pose.org_structure_version_id = posv.org_structure_version_id
			                  START	with	pose.organization_id_parent = p_org_id
				          CONNECT	BY prior organization_id_child = organization_id_parent)
			                  UNION
			                 (select p_org_id from dual))
					 OR
					 nvl(paa.establishment_id,-1) = p_org_id)
				and	paa.person_id = p_person_id
				and	paa.primary_flag = 'Y'
				and	past.assignment_status_type_id = paa.assignment_status_type_id
				and	past.per_system_status = 'ACTIVE_ASSIGN'
				and	get_ref_date(pap.person_id) between paa.effective_start_date and paa.effective_end_date
				and	paa.business_group_id = p_bg_id
				and	pap.person_id = p_person_id
				and	ppos.business_group_id = pap.business_group_id
				and	pap.effective_start_date >= to_date('04-07-2006','DD-MM-RRRR')
				and	ppos.person_id = pap.person_id
				and	ppos.date_start =
						(select max(ppos1.date_start)
						from	per_periods_of_service ppos1
						where	ppos1.person_id = ppos.person_id)
				and	ppos.date_start >= to_date('04-07-2006','DD-MM-RRRR')
				and 	(exists(select 1 from per_people_extra_info ppei
                				where ppei.person_id=p_person_id
                				and information_type='NL_FIRST_DAY_REPORT'
                				and ppei.pei_information2='Y')
        				or not exists(select 1 from per_people_extra_info ppei
        				        where ppei.person_id=p_person_id
        				        and information_type='NL_FIRST_DAY_REPORT')
    					);

				EXCEPTION
					WHEN TOO_MANY_ROWS
					THEN
						l_return_val := 1;

					WHEN NO_DATA_FOUND
					THEN
						null;

    			END;

		ELSIF p_org_struct_id is not NULL THEN

			BEGIN

				select	1 INTO l_return_val
				from	per_all_assignments_f		paa,
					per_assignment_status_types	past,
					per_all_people_f		pap,
					per_periods_of_service		ppos,
					per_org_structure_versions	posv

				where	posv.organization_structure_id=p_org_struct_id
				and	p_report_date between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)
				and	paa.person_id = p_person_id
				and	paa.primary_flag = 'Y'
				and	past.assignment_status_type_id = paa.assignment_status_type_id
				and	past.per_system_status = 'ACTIVE_ASSIGN'
				and	get_ref_date(pap.person_id) between paa.effective_start_date and paa.effective_end_date
				and	paa.business_group_id = p_bg_id
				and	pap.person_id = p_person_id
				and	pap.effective_start_date >= to_date('04-07-2006','DD-MM-RRRR')
				and	ppos.business_group_id = pap.business_group_id
				and	ppos.person_id = pap.person_id
				and	ppos.date_start =
						(select max(ppos1.date_start)
						from	per_periods_of_service ppos1
						where	ppos1.person_id = ppos.person_id)
				and	ppos.date_start >= to_date('04-07-2006','DD-MM-RRRR')
				and 	(exists(select 1 from per_people_extra_info ppei
                				where ppei.person_id=p_person_id
                				and information_type='NL_FIRST_DAY_REPORT'
                				and ppei.pei_information2='Y')
        				or not exists(select 1 from per_people_extra_info ppei
        				        where ppei.person_id=p_person_id
        				        and information_type='NL_FIRST_DAY_REPORT')
    					)
				and	(hr_nl_org_info.get_tax_org_id(posv.org_structure_version_id,paa.organization_id) is not null
					OR
					per_nl_fdr_archive.org_check(pap.business_group_id, null, nvl(paa.establishment_id,-1), to_date(p_report_date,'RRRR/MM/DD')) = 1)
				and	paa.organization_id in
						(select	pose.organization_id_parent
						from	per_org_structure_elements pose
						where	posv.org_structure_version_id = pose.org_structure_version_id
						UNION
						select	pose.organization_id_child
						from	per_org_structure_elements pose
						where	posv.org_structure_version_id = pose.org_structure_version_id);


				EXCEPTION
					WHEN TOO_MANY_ROWS
					THEN
						l_return_val := 1;

					WHEN NO_DATA_FOUND
					THEN
						null;


			END;

		END IF;

		return l_return_val;

	END;



	/*------------------------------------------------------------------------------
	|Name           : ORG_CHECK                                                     |
	|Type           : Function                                                      |
	|Description    : Function required for valueset HR_NL_EMPLOYER_FDR             |
	-------------------------------------------------------------------------------*/


	FUNCTION org_check	(p_bg_id IN NUMBER
				,p_org_struct_id IN NUMBER
				,p_org_id IN NUMBER
				,p_report_date IN DATE) return NUMBER IS

	l_return_val NUMBER := 0;

	BEGIN

		/*hr_utility.trace_on(NULL,'NL_FDR');
		hr_utility.set_location('Report date - '||p_report_date,1);*/


		IF p_org_struct_id is NULL THEN

			--hr_utility.set_location('hierarchy not chosen',1);
                       			 BEGIN

                                			select  1 INTO l_return_val
                               			 from    hr_organization_units hou
                                			WHERE   HOU.BUSINESS_GROUP_ID = p_bg_id
                                			AND        HOU.organization_id = p_org_id
                                			AND     EXISTS (SELECT 1 FROM HR_ALL_ORGANIZATION_UNITS HOU1, HR_ORGANIZATION_INFORMATION HOI1
                                                			WHERE HOU1.BUSINESS_GROUP_ID = p_bg_id
                                                			AND HOI1.ORG_INFORMATION_CONTEXT = 'NL_LE_TAX_DETAILS'
                                                			AND HOI1.ORG_INFORMATION1 IS NOT NULL
                                                			AND HOI1.ORG_INFORMATION2 IS NOT NULL
                                                			AND HOU1.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
                                                			AND HOU1.ORGANIZATION_ID = HOU.ORGANIZATION_ID

                                                        			UNION

                                                			SELECT 1 FROM HR_ALL_ORGANIZATION_UNITS HOU2, HR_ORGANIZATION_INFORMATION HOI2
                                                			WHERE HOU2.BUSINESS_GROUP_ID = p_bg_id
                                                			AND HOI2.ORG_INFORMATION_CONTEXT = 'NL_ORG_INFORMATION'
                                                			AND HOI2.ORG_INFORMATION4 IS NOT NULL
                                                			AND HOI2.ORG_INFORMATION3 IS NOT NULL
                                                			AND HOU2.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
                                                			AND HOU2.ORGANIZATION_ID = HOU.ORGANIZATION_ID);

                        			EXCEPTION

                                			WHEN TOO_MANY_ROWS
                                			THEN
                                        			l_return_val := 1;

                                			WHEN NO_DATA_FOUND
                                			THEN
                                        			null;

                        			END;

		ELSE

			--hr_utility.set_location('hierarchy chosen',2);

			BEGIN

				SELECT 1 INTO l_return_val
				FROM	hr_organization_units hou
				WHERE	hou.organization_id = p_org_id
				AND	hou.business_group_id = p_bg_id
				AND	EXISTS	(SELECT 1 FROM hr_organization_units hou1, hr_organization_information hoi1

						WHERE	hoi1.org_information_context= 'NL_ORG_INFORMATION'
						AND	hou1.business_group_id=p_bg_id
						AND	hou1.organization_id=hou.organization_id
						AND	hou1.organization_id= hoi1.organization_id
						AND	hoi1.org_information4 IS NOT NULL
						AND	hoi1.org_information3 IS NOT NULL
						AND	hou1.organization_id in

							(SELECT pose.organization_id_parent
							FROM	per_org_structure_elements pose,per_org_structure_versions posv
							WHERE	posv.org_structure_version_id = pose.org_structure_version_id
							AND	posv.organization_structure_id=p_org_struct_id
							AND	p_report_date between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)

								UNION

							SELECT	pose.organization_id_child
							FROM	per_org_structure_elements pose,per_org_structure_versions posv
							WHERE	posv.org_structure_version_id = pose.org_structure_version_id
							AND	posv.organization_structure_id=p_org_struct_id
							AND	p_report_date between posv.date_from and nvl(posv.date_to,hr_general.end_of_time))

						UNION

						SELECT 1 FROM hr_organization_units hou2, hr_organization_information hoi2

						WHERE	hoi2.org_information_context= 'NL_LE_TAX_DETAILS'
						AND	hou2.business_group_id=p_bg_id
						AND	hou2.organization_id=hou.organization_id
						AND	hou2.organization_id= hoi2.organization_id
						AND	hoi2.org_information1 IS NOT NULL
						AND	hoi2.org_information2 IS NOT NULL
						AND	hou2.organization_id in

							(SELECT pose.organization_id_parent
							FROM	per_org_structure_elements pose,per_org_structure_versions posv
							WHERE	posv.org_structure_version_id = pose.org_structure_version_id
							AND	posv.organization_structure_id=p_org_struct_id
							AND	p_report_date between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)

								UNION

							SELECT	pose.organization_id_child
							FROM	per_org_structure_elements pose,per_org_structure_versions posv
							WHERE	posv.org_structure_version_id = pose.org_structure_version_id
							AND	posv.organization_structure_id=p_org_struct_id
							AND	p_report_date between posv.date_from and nvl(posv.date_to,hr_general.end_of_time))

						);

			EXCEPTION

				WHEN TOO_MANY_ROWS
				THEN
					l_return_val := 1;

				WHEN NO_DATA_FOUND
				THEN
					null;

			END;

		END IF;

		return l_return_val;

	END org_check;



	/*--------------------------------------------------------------------
	|Name       : RANGE_CODE                                              |
	|Type	    : Procedure                                               |
	|Description: This procedure returns an sql string to select a range  |
	|             of assignments eligible for reporting                   |
	----------------------------------------------------------------------*/


	PROCEDURE RANGE_CODE (pactid    IN    NUMBER
	                     ,sqlstr    OUT   NOCOPY VARCHAR2) is


	l_format VARCHAR2(40);

	BEGIN


		sqlstr := 'SELECT DISTINCT person_id
		FROM  per_all_people_f pap
			 ,pay_payroll_actions ppa
		WHERE ppa.payroll_action_id = :payroll_action_id
		AND   ppa.business_group_id = pap.business_group_id
		ORDER BY pap.person_id';



		--hr_utility.trace_on(NULL,'NL_FDR');
		hr_utility.set_location('Leaving Range Code',10);

	EXCEPTION

		WHEN OTHERS THEN
		-- Return cursor that selects no rows
		sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';


	END RANGE_CODE;




	/*--------------------------------------------------------------------
	|Name       : ASSIGNMENT_ACTION_CODE                                  |
	|Type	    : Procedure                                               |
	|Description: This procedure further filters which assignments are    |
	|             eligible for reporting                                  |
	----------------------------------------------------------------------*/


	PROCEDURE ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
					  ,p_start_person_id   in number
					  ,p_end_person_id     in number
					  ,p_chunk             in number) IS


	CURSOR csr_get_asg_person	(p_person_id		NUMBER
					,p_start_person_id	NUMBER
					,p_end_person_id	NUMBER
					,p_payroll_action_id	NUMBER) is
	select	distinct paa.assignment_id	assignment_id

	from	per_all_assignments_f		paa,
		per_assignment_status_types	past,
		pay_payroll_actions		ppa,
		per_all_people_f		pap,
		per_periods_of_service		ppos

	where	p_person_id between p_start_person_id and p_end_person_id
	and	pap.person_id = p_person_id
	and	paa.person_id = pap.person_id
	and	paa.primary_flag = 'Y'
	and	past.assignment_status_type_id = paa.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pap.person_id) between paa.effective_start_date and paa.effective_end_date
	and	pap.effective_start_date >= to_date('04-07-2006','DD-MM-RRRR')
	and	ppos.business_group_id = pap.business_group_id
	and	ppos.person_id = pap.person_id
	and	ppos.date_start =
			(select max(ppos1.date_start)
			from	per_periods_of_service ppos1
			where	ppos1.person_id = ppos.person_id)
	and	ppos.date_start >= to_date('04-07-2006','DD-MM-RRRR')
	and	pap.business_group_id=ppa.business_group_id
	and	ppa.payroll_action_id=p_payroll_action_id
	and	(EXISTS (select	1
			from	per_people_extra_info pei
			where	pei.person_id = p_person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'
			and	pei.pei_information2 = 'Y')
		or NOT EXISTS
			(select	1
			from	per_people_extra_info pei
			where	pei.person_id = p_person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'));


	CURSOR csr_get_asg_org		(p_org_id		NUMBER
					,p_org_struct_id	NUMBER
					,p_start_person_id	NUMBER
					,p_end_person_id	NUMBER
					,p_payroll_action_id	NUMBER
					,p_report_date		VARCHAR2) is

	select	distinct paa.assignment_id	assignment_id

	from	per_all_assignments_f		paa,
		per_assignment_status_types	past,
		per_all_people_f		pap,
		pay_payroll_actions		ppa,
		per_periods_of_service		ppos,
		per_org_structure_versions	posv

	where	posv.organization_structure_id=p_org_struct_id
	and	to_date(p_report_date,'RRRR/MM/DD') between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)
	and	(paa.organization_id in
                ((SELECT	pose.organization_id_child
                  FROM		per_org_structure_elements pose
                  WHERE		pose.org_structure_version_id = posv.org_structure_version_id
                  START	with	pose.organization_id_parent = p_org_id
	          CONNECT	BY prior organization_id_child = organization_id_parent)
                  UNION
                 (select p_org_id from dual))
		 OR
		 nvl(paa.establishment_id,-1) = p_org_id
		 )
	and	paa.person_id = pap.person_id
	and	paa.primary_flag = 'Y'
	and	past.assignment_status_type_id = paa.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pap.person_id) between paa.effective_start_date and paa.effective_end_date
	and	pap.person_id between p_start_person_id and p_end_person_id
	and	pap.business_group_id = ppa.business_group_id
	and	ppa.payroll_action_id = p_payroll_action_id
	and	pap.effective_start_date >= to_date('04-07-2006','DD-MM-RRRR')
	and	ppos.business_group_id = pap.business_group_id
	and	ppos.person_id = pap.person_id
	and	ppos.date_start =
			(select max(ppos1.date_start)
			from	per_periods_of_service ppos1
			where	ppos1.person_id = ppos.person_id)
	and	ppos.date_start >= to_date('04-07-2006','DD-MM-RRRR')
	and	(EXISTS (select	1
			from	per_people_extra_info pei
			where	pei.person_id = pap.person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'
			and	pei.pei_information2 = 'Y')
		or NOT EXISTS
			(select	1
			from	per_people_extra_info pei
			where	pei.person_id = pap.person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'));



	CURSOR csr_get_asg_hier		(p_org_struct_id	NUMBER
					,p_report_date		VARCHAR2
					,p_start_person_id	NUMBER
					,p_end_person_id	NUMBER
					,p_payroll_action_id	NUMBER) is

	select	distinct paa.assignment_id	assignment_id

	from	per_all_assignments_f		paa,
		per_assignment_status_types	past,
		per_all_people_f		pap,
		pay_payroll_actions		ppa,
		per_periods_of_service		ppos,
		per_org_structure_versions	posv

	where	posv.organization_structure_id=p_org_struct_id
	and	to_date(p_report_date,'RRRR/MM/DD') between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)
	and	pap.person_id between p_start_person_id and p_end_person_id
	and	pap.business_group_id = ppa.business_group_id
	and	ppa.payroll_action_id = p_payroll_action_id
	and	pap.effective_start_date >= to_date('04-07-2006','DD-MM-RRRR')
	and	ppos.business_group_id = pap.business_group_id
	and	ppos.person_id = pap.person_id
	and	ppos.date_start =
			(select max(ppos1.date_start)
			from	per_periods_of_service ppos1
			where	ppos1.person_id = ppos.person_id)
	and	ppos.date_start >= to_date('04-07-2006','DD-MM-RRRR')
	and	(EXISTS (select	1
			from	per_people_extra_info pei
			where	pei.person_id = pap.person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'
			and	pei.pei_information2 = 'Y')
		or NOT EXISTS
			(select	1
			from	per_people_extra_info pei
			where	pei.person_id = pap.person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'))
	and	pap.person_id = paa.person_id
	and	paa.primary_flag = 'Y'
	and	past.assignment_status_type_id = paa.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pap.person_id) between paa.effective_start_date and paa.effective_end_date
	and	(hr_nl_org_info.get_tax_org_id(posv.org_structure_version_id,paa.organization_id) is not null
		OR
		per_nl_fdr_archive.org_check(pap.business_group_id, null, nvl(paa.establishment_id,-1), to_date(p_report_date,'RRRR/MM/DD')) = 1)
	and	paa.organization_id in
			(select	pose.organization_id_parent
			from	per_org_structure_elements pose
			where	posv.org_structure_version_id = pose.org_structure_version_id
			UNION
			select	pose.organization_id_child
			from	per_org_structure_elements pose
			where	posv.org_structure_version_id = pose.org_structure_version_id);


	l_report_date VARCHAR2(100);
	l_org_struct_id NUMBER;
	l_person_id NUMBER;
	l_org_id NUMBER;
	l_bg_id NUMBER;
	l_asg_act_id NUMBER;


	BEGIN

		l_org_struct_id := NULL;
		l_person_id	:= NULL;
		l_org_id	:= NULL;

		hr_utility.set_location('Entering assg action Code',20);

		PER_NL_FDR_ARCHIVE.get_all_parameters(p_payroll_action_id, l_report_date, l_org_struct_id, l_person_id, l_org_id, l_bg_id);

		--hr_utility.set_location('Parameters:- date: '||l_report_date||' hier: '||l_org_struct_id||' org: '||l_org_id,30);

		IF l_person_id is not NULL THEN

			--hr_utility.set_location('Person selected',40);

			FOR v_csr_get_asg_person in csr_get_asg_person(l_person_id, p_start_person_id, p_end_person_id, p_payroll_action_id)

			LOOP

				SELECT pay_assignment_actions_s.NEXTVAL
					INTO   l_asg_act_id
				FROM   dual;

				hr_nonrun_asact.insact(l_asg_act_id,v_csr_get_asg_person.assignment_id, p_payroll_action_id,p_chunk,NULL);

				--hr_utility.set_location('Assignment id - '||to_char(v_csr_get_asg_person.assignment_id)||' selected',45);

			END LOOP;

		ELSIF l_org_id is not NULL THEN

			--hr_utility.set_location('Org selected',50);

			FOR v_csr_get_asg_org in csr_get_asg_org(l_org_id, l_org_struct_id, p_start_person_id, p_end_person_id, p_payroll_action_id, l_report_date)

			LOOP

				--hr_utility.set_location('Selecting assignment '||to_char(v_csr_get_asg_org.assignment_id),55);

				SELECT pay_assignment_actions_s.NEXTVAL
					INTO   l_asg_act_id
				FROM   dual;

				hr_nonrun_asact.insact(l_asg_act_id,v_csr_get_asg_org.assignment_id, p_payroll_action_id,p_chunk,NULL);

				--hr_utility.set_location('Assignment id - '||to_char(v_csr_get_asg_org.assignment_id)||' selected',57);

			END LOOP;


		ELSIF l_org_struct_id is not NULL THEN

			--hr_utility.set_location('Hier selected',60);
			--hr_utility.set_location('Hier - '||to_char(l_org_struct_id)||' Pactid - '||p_payroll_action_id||' rep date - '||l_report_date||' start - '||p_start_person_id||' end - '||p_end_person_id,61);

			FOR v_csr_get_asg_hier in csr_get_asg_hier(l_org_struct_id, l_report_date, p_start_person_id, p_end_person_id, p_payroll_action_id)

			LOOP

				--hr_utility.set_location('Assignment id - '||to_char(v_csr_get_asg_hier.assignment_id)||' selected before inserting', 62);

				SELECT pay_assignment_actions_s.NEXTVAL
					INTO   l_asg_act_id
				FROM   dual;

				hr_nonrun_asact.insact(l_asg_act_id,v_csr_get_asg_hier.assignment_id, p_payroll_action_id,p_chunk,NULL);

				--hr_utility.set_location('Assignment id - '||to_char(v_csr_get_asg_hier.assignment_id)||' inserted', 65);

			END LOOP;

		END IF;


	END ASSIGNMENT_ACTION_CODE;




	/*-------------------------------------------------------------------------------
	|Name           : ARCHIVE_CODE                                                  |
	|Type		: Procedure                                                     |
	|Description    : Archival code                                                 |
	-------------------------------------------------------------------------------*/


	PROCEDURE ARCHIVE_CODE (p_assignment_action_id  IN NUMBER
				,p_effective_date       IN DATE) IS


	CURSOR csr_get_org_info(p_assignment_action_id	IN NUMBER,
				p_org_struct_id		IN NUMBER,
				p_report_date		IN VARCHAR2) is

	select	hou.organization_id		org_id,
		hou.name			org_name,
		hoi.org_information4		tax_reg

	from	pay_assignment_actions		paa,
		per_all_assignments_f		pas,
		per_assignment_status_types	past,
		hr_organization_units		hou,
		hr_organization_information	hoi,
		per_org_structure_versions	posv

	where	posv.organization_structure_id=p_org_struct_id
	and	to_date(p_report_date,'RRRR/MM/DD') between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)
	and	paa.assignment_action_id = p_assignment_action_id
	and	pas.assignment_id = paa.assignment_id
	and	past.assignment_status_type_id = pas.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pas.person_id) between pas.effective_start_date and pas.effective_end_date
	and	hou.organization_id = hr_nl_org_info.get_tax_org_id(posv.org_structure_version_id, pas.organization_id)
	and	hoi.organization_id = hou.organization_id
	and	hoi.org_information_context = 'NL_ORG_INFORMATION';


	CURSOR csr_get_leg_info(p_assignment_action_id IN NUMBER) is

	select	hou.organization_id		org_id,
		hou.name			org_name,
		hoi.org_information1		tax_reg

	from	pay_assignment_actions		paa,
		per_all_assignments_f		pas,
		per_assignment_status_types	past,
		hr_organization_units		hou,
		hr_organization_information	hoi

	where	paa.assignment_action_id = p_assignment_action_id
	and	pas.assignment_id = paa.assignment_id
	and	past.assignment_status_type_id = pas.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pas.person_id) between pas.effective_start_date and pas.effective_end_date
	and	hou.organization_id = pas.establishment_id
	and	hoi.organization_id = hou.organization_id
	and	hoi.org_information_context = 'NL_LE_TAX_DETAILS';



	CURSOR csr_get_person_info(p_assignment_action_id IN NUMBER) is

	select	ppos.date_start			hire_date,
	    	pap.employee_number		employee_number,
	    	pap.national_identifier		sofi_number,
	    	pap.per_information1		init,
	    	pap.pre_name_adjunct		prefix,
	    	pap.last_name			last_name,
	    	pap.full_name			full_name,
	    	pap.date_of_birth		date_of_birth,
	    	pap.person_id			person_id,
	    	pap.business_group_id		bg_id,
	    	pas.establishment_id		establishment_id

	from	per_all_people_f		pap,
	    	per_all_assignments_f		pas,
		per_assignment_status_types	past,
	    	pay_assignment_actions		paa,
		per_periods_of_service		ppos

	where	paa.assignment_action_id = p_assignment_action_id
	and	pas.assignment_id = paa.assignment_id
	and	pap.person_id =	pas.person_id
	and	pas.primary_flag = 'Y'
	and	past.assignment_status_type_id = pas.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pap.person_id) between pas.effective_start_date and pas.effective_end_date
	and	pap.effective_start_date =
			(select max(pap1.effective_start_date)
			from	per_all_people_f pap1
			where	pap.person_id = pap1.person_id)
	and	ppos.person_id = pap.person_id
	and	ppos.date_start =
			(select max(date_start)
			from	per_periods_of_service ppos1
			where	ppos1.person_id = pap.person_id);


	CURSOR csr_get_peit(p_person_id NUMBER) IS
	select	ppei.person_extra_info_id	person_extra_info_id,
		ppei.object_version_number	object_version_number
	from	per_people_extra_info ppei
	where	ppei.person_id = p_person_id
	and	ppei.information_type = 'NL_FIRST_DAY_REPORT'
	and	ppei.pei_information2 = 'Y';

	v_csr_get_peit csr_get_peit%rowtype;

	l_report_date VARCHAR2(100);
	l_bg_name per_business_groups.NAME%TYPE;
	l_bg_id NUMBER;
	l_msg_id VARCHAR2(100);
	l_tax_reg_num VARCHAR2(100);
	l_hire_date DATE;
	l_employee_number per_all_people_f.employee_number%TYPE;
	l_sofi_number VARCHAR2(30) := null;
	l_initial VARCHAR2(150);
	l_prefix VARCHAR2(30);
	l_last_name VARCHAR2(150);
	l_full_name VARCHAR2(150);
	l_date_of_birth DATE;
	l_person_id NUMBER;
	l_establishment_id NUMBER;
	l_org_id NUMBER;
	l_org_struct_id NUMBER;
	l_org_name VARCHAR2(150);
	l_file UTL_FILE.FILE_TYPE;
	l_directory_path VARCHAR2(500);
	l_file_name VARCHAR2(50);
	vCtr NUMBER := 0;
	l_xfdf_clob CLOB;
	l_action_info_id NUMBER;
	l_ovn NUMBER;
	l_create_peit VARCHAR2(1);
	l_parameter_string pay_payroll_actions.legislative_parameters%type;



	BEGIN

		--hr_utility.trace_on(NULL,'NL_FDR');
		--hr_utility.set_location('Entered archive code', 90);
 		l_create_peit := 'Y';

		SELECT	PER_NL_FDR_ARCHIVE.get_parameter(ppa.legislative_parameters,'REPORT_DATE')
		INTO	l_report_date
		FROM	pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		WHERE	paa.payroll_action_id = ppa.payroll_action_id
		AND	paa.assignment_action_id = p_assignment_action_id;

		SELECT	ppa.legislative_parameters
		INTO	l_parameter_string
		FROM	pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		WHERE	paa.payroll_action_id = ppa.payroll_action_id
		AND	paa.assignment_action_id = p_assignment_action_id;


        IF instr(l_parameter_string,'/',1,2) - instr(l_parameter_string,'/',1,1) = 3 THEN
			l_report_date := substr(l_parameter_string,instr(l_parameter_string,'/',1,1)-4,10);
		END IF;
        g_year := to_char(to_date(l_report_date,'RRRR/MM/DD'),'RRRR');

		select	TO_NUMBER(PER_NL_FDR_ARCHIVE.get_parameter(ppa.legislative_parameters,'ORG_STRUCT_ID'))
		INTO	l_org_struct_id
		FROM	pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		WHERE	paa.payroll_action_id = ppa.payroll_action_id
		AND	paa.assignment_action_id = p_assignment_action_id;


		SELECT value INTO l_directory_path
		FROM v$parameter WHERE LOWER(name)='utl_file_dir';

		IF INSTR(l_directory_path,',') > 0 THEN
			l_directory_path := SUBSTR(l_directory_path, 1, INSTR(l_directory_path,',')-1);
		END IF;


		OPEN csr_get_person_info(p_assignment_action_id);
		FETCH csr_get_person_info into l_hire_date, l_employee_number, l_sofi_number, l_initial, l_prefix, l_last_name, l_full_name, l_date_of_birth, l_person_id, l_bg_id, l_establishment_id;
		CLOSE csr_get_person_info;

		--hr_utility.set_location('Processing employee number: '||l_employee_number||' with leg emp '||l_establishment_id,95);

		IF l_establishment_id is not NULL and per_nl_fdr_archive.org_check(l_bg_id,null,l_establishment_id,to_date(l_report_date,'RRRR/MM/DD')) = 1 THEN

			--hr_utility.set_location('Entered IF condition for legal employer',97);
			OPEN csr_get_leg_info(p_assignment_action_id);
			FETCH csr_get_leg_info INTO l_org_id, l_org_name, l_tax_reg_num;
			CLOSE csr_get_leg_info;

		ELSE

			--hr_utility.set_location('Entered else condition for HR org',99);
			OPEN csr_get_org_info(p_assignment_action_id, l_org_struct_id, l_report_date);
			FETCH csr_get_org_info INTO l_org_id, l_org_name, l_tax_reg_num;
			CLOSE csr_get_org_info;


		END IF;


		--hr_utility.set_location('Employee number - '||l_employee_number||' selected', 100);


		vXMLTable(vCtr).TagName := 'Bericht';
		vXMLTable(vCtr).TagValue := null;
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'IdBer';
		vXMLTable(vCtr).TagValue := replace(l_last_name,'&','&'||'amp;')||'_'||l_employee_number;
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'Bericht';
		vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'AdministratieveEenheid';
		vXMLTable(vCtr).TagValue := null;
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'LhNr';
		vXMLTable(vCtr).TagValue := to_char(l_tax_reg_num);
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'Dienstbetrekking';
		vXMLTable(vCtr).TagValue := null;
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'DatAanvWz';
		vXMLTable(vCtr).TagValue := to_char(l_hire_date,'RRRR-MM-DD');
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'NatuurlijkPersoon';
		vXMLTable(vCtr).TagValue := null;
		vCtr := vCtr + 1;

		IF l_sofi_number is not null THEN

			vXMLTable(vCtr).TagName := 'SofiNr';
			vXMLTable(vCtr).TagValue := l_sofi_number;
			vCtr := vCtr + 1;

		ELSE

			vXMLTable(vCtr).TagName := 'PersNr';
			vXMLTable(vCtr).TagValue := l_employee_number;
			vCtr := vCtr + 1;

		END IF;

		vXMLTable(vCtr).TagName := 'Voorl';
		vXMLTable(vCtr).TagValue := upper(replace(replace(l_initial,'&','&'||'amp;'),'.'));
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'Voorv';
		vXMLTable(vCtr).TagValue := replace(l_prefix,'&','&'||'amp;');
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'SignNm';
		vXMLTable(vCtr).TagValue := replace(l_last_name,'&','&'||'amp;');
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'Gebdat';
		vXMLTable(vCtr).TagValue := to_char(l_date_of_birth,'RRRR-MM-DD');
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'NatuurlijkPersoon';
		vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'Dienstbetrekking';
		vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		vXMLTable(vCtr).TagName := 'AdministratieveEenheid';
		vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		WritetoCLOB_rtf(l_xfdf_clob, vXMLTable);

		l_file_name := l_employee_number||'_'||to_char(l_tax_reg_num)||'_'||substr(to_char(to_date(l_report_date,'RRRR/MM/DD HH24:MI:SS'),'DD-MM-RR'),1,2)||
			substr(to_char(to_date(l_report_date,'RRRR/MM/DD HH24:MI:SS'),'DD-MM-RR'),4,2)||substr(to_char(to_date(l_report_date,'RRRR/MM/DD HH24:MI:SS'),'DD-MM-RR'),7,2)||'.xml';
		l_file := utl_file.fopen(l_directory_path, l_file_name, 'W');
		utl_file.put_line(l_file,substr(l_xfdf_clob,1,instr(l_xfdf_clob,'<NatuurlijkPersoon>')-1));
		utl_file.put_line(l_file,substr(l_xfdf_clob,instr(l_xfdf_clob,'<NatuurlijkPersoon>'),length(l_xfdf_clob)-instr(l_xfdf_clob,'<NatuurlijkPersoon>')+1));
		utl_file.fclose(l_file);


		pay_action_information_api.create_action_information
			       ( p_action_information_id	=> l_action_info_id
				,p_action_context_id		=> p_assignment_action_id
				,p_action_context_type		=> 'AAP'
				,p_object_version_number	=> l_ovn
		                ,p_effective_date		=> p_effective_date
				,p_source_id			=> NULL
				,p_source_text			=> NULL
				,p_action_information_category	=> 'NL FDR EMPLOYEE DETAILS'
				,p_action_information1		=> nvl(l_employee_number,' ')
				,p_action_information2		=> nvl(l_full_name,' ')
				,p_action_information3		=> nvl(l_sofi_number,' ')
				,p_action_information4		=> nvl(l_org_name,' ')
				,p_action_information5		=> nvl(l_tax_reg_num,' ')
				,p_action_information6		=> nvl(fnd_date.date_to_displaydate(l_hire_date),' ')
				,p_action_information7		=> nvl(fnd_date.date_to_displaydate(l_date_of_birth),' '));


		FOR v_csr_get_peit IN csr_get_peit(l_person_id)
		LOOP

			l_create_peit := 'N';
			hr_person_extra_info_api.update_person_extra_info
				(p_person_extra_info_id=>v_csr_get_peit.person_extra_info_id
				,p_object_version_number=>v_csr_get_peit.object_version_number
				,p_pei_information1=>to_char(to_date(l_report_date, 'RRRR/MM/DD HH24:MI:SS'),'RRRR/MM/DD HH24:MI:SS')
				,p_pei_information2=>'N');

		END LOOP;

		IF l_create_peit = 'Y' THEN

			hr_person_extra_info_api.create_person_extra_info
				(p_person_id=>l_person_id
				,p_information_type=>'NL_FIRST_DAY_REPORT'
				,p_pei_information_category=>'NL_FIRST_DAY_REPORT'
				,p_pei_information1=>to_char(to_date(l_report_date, 'RRRR/MM/DD HH24:MI:SS'),'RRRR/MM/DD HH24:MI:SS')
				,p_pei_information2=>'N'
				,p_person_extra_info_id=>v_csr_get_peit.person_extra_info_id
				,p_object_version_number=>v_csr_get_peit.object_version_number);

		END IF;


	END ARCHIVE_CODE;



	/*-------------------------------------------------------------------------------
	|Name           : ARCHIVE_DEINIT_CODE                                           |
	|Type		: Procedure                                                     |
	|Description    : Deinitialization code                                         |
	-------------------------------------------------------------------------------*/


	PROCEDURE archive_deinit_code(p_actid IN  NUMBER) IS

	CURSOR	csr_get_action_information IS

	select	pai.action_information_id	act_id,
		pai.object_version_number	ovn

	from	pay_action_information		pai,
		pay_assignment_actions		paa

	where	paa.payroll_action_id = p_actid
	and	pai.action_context_id = paa.assignment_action_id
	and	pai.action_information_category = 'NL FDR EMPLOYEE DETAILS';


	CURSOR	csr_get_employer IS

	select	distinct pai.action_information4	org_name,
		pai.action_information5			tax_reg_num

	from	pay_action_information			pai,
		pay_assignment_actions			paa

	where	paa.payroll_action_id = p_actid
	and	pai.action_context_id = paa.assignment_action_id
	and	pai.action_information_category = 'NL FDR EMPLOYEE DETAILS';


	CURSOR	csr_get_employee_details(p_org_name VARCHAR2) IS

	select	pai.action_information1		employee_number,
		pai.action_information2		full_name,
		pai.action_information3		sofi_number,
		pai.action_information6		hire_date,
		pai.action_information7		date_of_birth

	from	pay_action_information		pai,
		pay_assignment_actions		paa

	where	paa.payroll_action_id = p_actid
	and	pai.action_context_id = paa.assignment_action_id
	and	pai.action_information_category = 'NL FDR EMPLOYEE DETAILS'
	and	pai.action_information4 = p_org_name;


	CURSOR csr_get_per_without_employer	(p_org_struct_id	NUMBER
						,p_report_date		VARCHAR2
						,p_payroll_action_id	NUMBER) is

	select	distinct pap.employee_number	emp_no,
		pap.full_name			name

	from	per_all_assignments_f		paa,
		per_assignment_status_types	past,
		per_all_people_f		pap,
		pay_payroll_actions		ppa,
		per_periods_of_service		ppos,
		per_org_structure_versions	posv

	where	posv.organization_structure_id=p_org_struct_id
	and	to_date(p_report_date,'RRRR/MM/DD') between posv.date_from and nvl(posv.date_to,hr_general.end_of_time)
	and	pap.business_group_id = ppa.business_group_id
	and	ppa.payroll_action_id = p_payroll_action_id
	and	pap.effective_start_date >= to_date('04-07-2006','DD-MM-RRRR')
	and	ppos.business_group_id = pap.business_group_id
	and	ppos.person_id = pap.person_id
	and	ppos.date_start =
			(select max(ppos1.date_start)
			from	per_periods_of_service ppos1
			where	ppos1.person_id = ppos.person_id)
	and	ppos.date_start >= to_date('04-07-2006','DD-MM-RRRR')
	and	(EXISTS (select	1
			from	per_people_extra_info pei
			where	pei.person_id = pap.person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'
			and	pei.pei_information2 = 'Y')
		or NOT EXISTS
			(select	1
			from	per_people_extra_info pei
			where	pei.person_id = pap.person_id
			and	pei.information_type = 'NL_FIRST_DAY_REPORT'))
	and	pap.person_id = paa.person_id
	and	paa.primary_flag = 'Y'
	and	past.assignment_status_type_id = paa.assignment_status_type_id
	and	past.per_system_status = 'ACTIVE_ASSIGN'
	and	get_ref_date(pap.person_id) between paa.effective_start_date and paa.effective_end_date
	and	hr_nl_org_info.get_tax_org_id(posv.org_structure_version_id,paa.organization_id) is null
	and	per_nl_fdr_archive.org_check(pap.business_group_id, null, nvl(paa.establishment_id,-1), to_date(p_report_date,'RRRR/MM/DD')) = 0
	and	paa.organization_id in
			(select	pose.organization_id_parent
			from	per_org_structure_elements pose
			where	posv.org_structure_version_id = pose.org_structure_version_id
			UNION
			select	pose.organization_id_child
			from	per_org_structure_elements pose
			where	posv.org_structure_version_id = pose.org_structure_version_id);


	l_bg_name			VARCHAR2(100);
	l_report_date			VARCHAR2(100);
	l_head_length			NUMBER;
	l_org_struct_id			NUMBER;
	l_person_id			NUMBER;
	l_org_id			NUMBER;
	l_bg_id				NUMBER;
	v_csr_get_employer		csr_get_employer%rowtype;
	v_csr_get_employee_details	csr_get_employee_details%rowtype;
	v_csr_get_action_information	csr_get_action_information%rowtype;
	v_csr_get_per_without_employer	csr_get_per_without_employer%rowtype;



	BEGIN

		PER_NL_FDR_ARCHIVE.get_all_parameters(p_actid, l_report_date, l_org_struct_id, l_person_id, l_org_id, l_bg_id);

		SELECT	pbg.name
		INTO	l_bg_name
		FROM	per_business_groups	pbg
		WHERE	pbg.business_group_id = l_bg_id;

		IF l_person_id is NULL and l_org_id is NULL and l_org_struct_id is not NULL THEN

			FOR v_csr_get_per_without_employer IN csr_get_per_without_employer(l_org_struct_id,l_report_date, p_actid)
			LOOP

				FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: Employee number - '||v_csr_get_per_without_employer.emp_no||', '||v_csr_get_per_without_employer.name||' is not attached to an employer with tax details.');

			END LOOP;

		END IF;

		l_head_length := length(hr_general.decode_lookup('NL_FDR_LABELS','REP_HEAD'));

		FND_FILE.PUT(FND_FILE.OUTPUT, lpad(hr_general.decode_lookup('NL_FDR_LABELS','REP_HEAD'),((123-l_head_length)/2)+l_head_length,' '));
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
		FND_FILE.PUT(FND_FILE.OUTPUT, lpad(rpad(' ',l_head_length+1,'-'),((123-l_head_length)/2)+l_head_length,' '));
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 3);
		FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','BG_NAME'),30,' '));
		FND_FILE.PUT(FND_FILE.OUTPUT, ':   ');
		FND_FILE.PUT(FND_FILE.OUTPUT, l_bg_name);
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
		FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','REP_DATE'),30,' '));
		FND_FILE.PUT(FND_FILE.OUTPUT, ':   ');
		FND_FILE.PUT(FND_FILE.OUTPUT, fnd_date.date_to_displaydate(to_date(l_report_date, 'RRRR/MM/DD HH24:MI:SS')));
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 6);



		FOR v_csr_get_employer IN csr_get_employer
		LOOP

			IF hr_ni_chk_pkg.chk_nat_id_format(v_csr_get_employer.tax_reg_num,'DDDDDDDDDADD') <> upper(v_csr_get_employer.tax_reg_num) OR substr(v_csr_get_employer.tax_reg_num,10,1) <> 'L' THEN

				FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: The Tax Registration Number for '||
				v_csr_get_employer.org_name||' has an incorrect format. It should be nnnnnnnnnLnn. Please correct.');

			END IF;


			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','EMPLOYER'),30,' '));
			FND_FILE.PUT(FND_FILE.OUTPUT, ':   ');
			FND_FILE.PUT(FND_FILE.OUTPUT, v_csr_get_employer.org_name);
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','TAX_REG'),30,' '));
			FND_FILE.PUT(FND_FILE.OUTPUT, ':   ');
			FND_FILE.PUT(FND_FILE.OUTPUT, v_csr_get_employer.tax_reg_num);
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 2);

			FND_FILE.PUT(FND_FILE.OUTPUT, lpad(' ',123,'-'));
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','EMP_NO'), 21, ' '));
			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','EMP_NAME'), 40, ' '));
			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','SOFI_NO'), 20, ' '));
			--FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','TAX_REG'), 30, ' '));
			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','HIRE_DATE'), 21, ' '));
			FND_FILE.PUT(FND_FILE.OUTPUT, rpad(hr_general.decode_lookup('NL_FDR_LABELS','BIRTH_DATE'), 21, ' '));
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
			FND_FILE.PUT(FND_FILE.OUTPUT, lpad(' ',123,'-'));
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);


			FOR v_csr_get_employee_details IN csr_get_employee_details(v_csr_get_employer.org_name)
			LOOP

				IF v_csr_get_employee_details.date_of_birth = ' ' THEN

					FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: Employee number - '||v_csr_get_employee_details.employee_number||', '||
					v_csr_get_employee_details.full_name||' has no Date of Birth entered.');

				END IF;

				FND_FILE.PUT(FND_FILE.OUTPUT, rpad(v_csr_get_employee_details.employee_number, 21, ' '));
				FND_FILE.PUT(FND_FILE.OUTPUT, rpad(v_csr_get_employee_details.full_name, 40, ' '));
				FND_FILE.PUT(FND_FILE.OUTPUT, rpad(v_csr_get_employee_details.sofi_number, 20, ' '));
				--FND_FILE.PUT(FND_FILE.OUTPUT, rpad(v_csr_get_employer.tax_reg_num, 30, ' '));
				FND_FILE.PUT(FND_FILE.OUTPUT, rpad(v_csr_get_employee_details.hire_date, 21, ' '));
				FND_FILE.PUT(FND_FILE.OUTPUT, rpad(v_csr_get_employee_details.date_of_birth, 21, ' '));
				FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);

			END LOOP;

			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 3);

		END LOOP;

		--Deleting the data from pay_action_information table

		FOR v_csr_get_action_information in csr_get_action_information
		LOOP

			pay_action_information_api.delete_action_information	(p_action_information_id => v_csr_get_action_information.act_id
										,p_object_version_number => v_csr_get_action_information.ovn);

		END LOOP;

		--Deleting assignment actions that have been created - for bug 5446716

		delete	from pay_assignment_actions
		where	payroll_action_id = p_actid;


	END archive_deinit_code;


END PER_NL_FDR_ARCHIVE;

/
