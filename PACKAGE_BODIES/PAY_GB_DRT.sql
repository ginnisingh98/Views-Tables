--------------------------------------------------------
--  DDL for Package Body PAY_GB_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_DRT" AS
/* $Header: pygbdrt.pkb 120.0.12010000.6 2018/06/22 09:54:28 anmosing noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_gb_drt
 Package File Name : pygbdrt.pkb
 Description : GB Payroll localization package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 shekhsum     20-Mar-2018     120.0             	Created
 shekhsum     22-Mar-2018     120.0.12010000.2      Added FF_ARCHIVE_ITEMS and BEN_EXT_RSLT_DTL
 shekhsum     23-Mar-2018     120.0.12010000.3      Added details for penserver.
 shekhsum     27-Mar-2018     120.0.12010000.4      Implemented Review Comments
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_gb_drt.';


	PROCEDURE additional_filter(
              p_person_id NUMBER,
              p_business_group_id NUMBER,
              p_row_id VARCHAR2,
              p_table_name VARCHAR2,
              p_filter_value OUT nocopy VARCHAR2) IS


	  l_procedure VARCHAR2(100) := 'additional_filter';
    l_filter_value VARCHAR2(1) := 'N';
	BEGIN

	  hr_utility.trace('Entering '||g_package||l_procedure);
      hr_utility.trace('p_row_id '||p_row_id);
      hr_utility.trace('p_table_name '||p_table_name);

      IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' THEN

        BEGIN
          SELECT  'Y'  INTO l_filter_value
          FROM    pay_element_entry_values_f peev
                 ,pay_input_values_f piv
          WHERE   peev.input_value_id = piv.input_value_id
          AND     piv.name IN ('Car Identifier','Registration Number','Van Identifier','Address')
          AND     peev.rowid = p_row_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_filter_value := 'N';
        WHEN OTHERS THEN NULL;
        END;
        p_filter_value := l_filter_value;
      END IF;

    IF p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
      BEGIN
        SELECT  'Y'  INTO l_filter_value
        FROM    pay_run_result_values prrv
               ,pay_input_values_f piv
        WHERE   prrv.input_value_id = piv.input_value_id
        AND     piv.name IN ('Car Identifier','Registration Number','Van Identifier','Address')
        AND     prrv.rowid = p_row_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_filter_value := 'N';
        WHEN OTHERS THEN NULL;
      END;
      p_filter_value := l_filter_value;
    END IF;

--BEN_EXT_RSLT_DTL
		IF p_table_name = 'BEN_EXT_RSLT_DTL' THEN
		  BEGIN
		    SELECT  'Y'
		    INTO    l_filter_value
		    FROM    ben_ext_rslt_dtl rsdtl
		          , ben_ext_rslt rslt
		          , ben_ext_dfn exdfn
		    WHERE   rsdtl.ext_rslt_id = rslt.ext_rslt_id
		    AND     rslt.ext_dfn_id = exdfn.ext_dfn_id
		    AND     (
		                    exdfn.name LIKE ('PQP GB PenServer%')
		            OR      exdfn.name = ('PQP GB TP - Teachers Monthly Returns ( England and Wales )')
		            )
		    AND     rsdtl.rowid = p_row_id;
		  EXCEPTION
		    WHEN no_data_found THEN
		      l_filter_value := 'N';
		    WHEN others THEN
		      NULL;
		  END;

		  p_filter_value := l_filter_value;
		END IF;

  --FF_ARCHIVE_ITEMS
		IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN
		  BEGIN
		    SELECT  'Y'
		    INTO    l_filter_value
		    FROM    ff_archive_items ffai
		          , ff_user_entities ffue
		    WHERE   ffue.user_entity_id = ffai.user_entity_id
		    AND     ffue.legislation_code = 'GB'
		    AND     ffue.user_entity_name IN ('X_ADDRESS_LINE1', 'X_ADDRESS_LINE2', 'X_ADDRESS_LINE3'
		                                    , 'X_TOWN_OR_CITY', 'X_REGION_1', 'X_COUNTRY'
		                                    , 'X_POSTAL_CODE', 'X_EMPLOYER_NAME'
		                                    , 'X_LAST_NAME', 'X_MIDDLE_NAME', 'X_FIRST_NAME'
		                                    ,  'X_NATIONAL_IDENTIFIER')
		    AND     ffai.rowid = p_row_id;
		  EXCEPTION
		    WHEN no_data_found THEN
		      l_filter_value := 'N';
		    WHEN others THEN
		      NULL;
		  END;

		  p_filter_value := l_filter_value;
		END IF;

	   hr_utility.trace('p_filter_value '||l_filter_value);
	   hr_utility.trace('Leaving '||g_package||l_procedure);
	END;


	PROCEDURE  mask_value_udf(
               p_person_id IN NUMBER,
               p_business_group_id IN NUMBER,
               p_row_id IN VARCHAR2,
               p_table_name IN VARCHAR2,
               p_column_name IN VARCHAR2,
               p_udf_mask_value OUT nocopy VARCHAR2) IS

	l_procedure VARCHAR2(100) := 'mask_value_udf';
	l_entity_name varchar2(100);
	l_name      ben_ext_dfn.name%TYPE;

CURSOR csr_get_ext_name IS
  SELECT  DISTINCT
          exdfn.name
  FROM    ben_ext_rslt_dtl rsdtl
        , ben_ext_rslt rslt
        , ben_ext_dfn exdfn
  WHERE   rsdtl.ext_rslt_id = rslt.ext_rslt_id
  AND     rslt.ext_dfn_id = exdfn.ext_dfn_id
  AND     rsdtl.rowid = p_row_id
  AND     exdfn.legislation_code = 'GB';

CURSOR csr_get_entity_name IS
  SELECT  ffue.user_entity_name
  INTO    l_entity_name
  FROM    ff_archive_items ffai
        , ff_user_entities ffue
  WHERE   ffue.user_entity_id = ffai.user_entity_id
  AND     ffue.legislation_code = 'GB'
  AND     ffai.rowid = p_row_id;

	BEGIN
	  hr_utility.trace('Entering '||g_package||l_procedure);

		--PAY_ELEMENT_ENTRY_VALUES_F and PAY_RUN_RESULT_VALUES
	  IF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' OR p_table_name = 'PAY_RUN_RESULT_VALUES' THEN
       p_udf_mask_value := 'AAAAA';
    END IF;

		--FF_ARCHIVE_ITEMS
			IF p_table_name = 'FF_ARCHIVE_ITEMS' THEN

		  OPEN csr_get_entity_name;
		  FETCH csr_get_entity_name
		    INTO  l_entity_name;

		  CLOSE csr_get_entity_name;

			  IF l_entity_name IN ('X_ADDRESS_LINE1', 'X_ADDRESS_LINE2', 'X_ADDRESS_LINE3'
			                     , 'X_TOWN_OR_CITY', 'X_REGION_1', 'X_COUNTRY'
			                     , 'X_POSTAL_CODE') THEN
			    p_udf_mask_value := 'MASKED';
			  END IF;
			  IF l_entity_name IN ('X_LAST_NAME', 'X_MIDDLE_NAME', 'X_FIRST_NAME') THEN
			    p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
			                                                  , p_column_name, p_person_id);
			  END IF;
			  IF l_entity_name IN ('X_NATIONAL_IDENTIFIER') THEN
			    p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
			  END IF;
			END IF;

	--BEN_EXT_RSLT_DTL
		IF p_table_name = 'BEN_EXT_RSLT_DTL' THEN
		  OPEN csr_get_ext_name;

		  FETCH csr_get_ext_name
		    INTO    l_name;

		  CLOSE csr_get_ext_name;

		  IF (l_name
		        = 'PQP GB TP - Teachers Monthly Returns ( England and Wales )') THEN
		    IF (p_column_name = 'VAL_02') THEN
		      p_udf_mask_value := 'AAAAA';
		    ELSIF (p_column_name = 'VAL_03') THEN
		      p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
		                                                         , p_column_name, p_person_id);
		    ELSIF (p_column_name = 'VAL_04') THEN
		      p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
		                                                    , p_column_name, p_person_id);
		    ELSIF (p_column_name = 'VAL_05') THEN
		      p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
		                                                    , p_column_name, p_person_id);
		    ELSIF (p_column_name = 'VAL_06') THEN
		      p_udf_mask_value := 'MASKED';
		    ELSIF (p_column_name = 'VAL_07') THEN
		      p_udf_mask_value := 'MASKED';
		    ELSIF (p_column_name = 'VAL_08') THEN
		      p_udf_mask_value := 'MASKED';
		    ELSIF (p_column_name = 'VAL_09') THEN
		      p_udf_mask_value := 'MASKED';
		    ELSIF (p_column_name = 'VAL_10') THEN
		      p_udf_mask_value := 'MASKED';
		    ELSIF (p_column_name = 'VAL_11') THEN
		      p_udf_mask_value := 'AAAAAA';
		    ELSIF (p_column_name = 'VAL_24') THEN
		      p_udf_mask_value := per_drt_udf.overwrite_email (p_row_id, p_table_name
		                                                     , p_column_name, p_person_id);
		    END IF;
		ELSE
		-- penserver extract
            hr_utility.trace('Entering penserver');
			IF(l_name in (('PQP GB PenServer Periodic Changes Interface - Basic Data'),
			             ('PQP GB PenServer Cutover Interface - Basic Data'))) THEN
			    IF(p_column_name = 'VAL_03') THEN --NI
				    p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
				ELSIF(p_column_name = 'VAL_05') THEN --name
					p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
			                                                  , p_column_name, p_person_id);
				ELSIF(p_column_name = 'VAL_06') THEN	--name
					p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
			                                                  , p_column_name, p_person_id);
			  	ELSIF(p_column_name = 'VAL_07') THEN	--name
					p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
			                                                  , p_column_name, p_person_id);
				ELSIF(p_column_name = 'VAL_08') THEN	--name
					p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
			                                                  , p_column_name, p_person_id);
				ELSIF(p_column_name = 'VAL_09') THEN	--name
					p_udf_mask_value := per_drt_udf.overwrite_name (p_row_id, p_table_name
			                                                  , p_column_name, p_person_id);
				END IF;

			ELSIF(l_name in (('PQP GB PenServer Standard Interface - Payment History'),
						    ('PQP GB PenServer Periodic Interface - WPS History'),
						    ('PQP GB PenServer Cutover Interface - Bonus History'),
						    ('PQP GB PenServer Periodic Changes Interface - Short Time Hours History (Accumulated Records)'),
						    ('PQP GB PenServer Cutover Interface - Salary History'),
							('PQP GB PenServer Periodic Changes Interface - Salary History'),
							('PQP GB PenServer Periodic Interface - Scheme Contribution Rate History'),
							('PQP GB PenServer Cutover Interface - Scheme Contribution Rate History'),
							('PQP GB PenServer Cutover Interface - WPS History'),
							('PQP GB PenServer Periodic Changes Interface - Short Time Hours History (Single Records)'),
							('PQP GB PenServer Periodic Changes Interface - Bonus History'),
							('PQP GB PenServer Cutover Interface - Allowance History'),
							('PQP GB PenServer Periodic Changes Interface - Allowance History')))THEN
				IF(p_column_name = 'VAL_03') THEN --NI
				    p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
				END IF;
			ELSIF(l_name in (('PQP GB PenServer Periodic Changes Interface - Service History'),
							 ('PQP GB PenServer Cutover Interface - Service History')))THEN
			    IF(p_column_name = 'VAL_02') THEN --NI
				    p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
			  	END IF;
			ELSIF(l_name in (('PQP GB PenServer Cutover Interface - Part Time Hours History'),
                            ('PQP GB PenServer Periodic Changes Interface - Part Time Hours History'))) THEN
			    IF(p_column_name = 'VAL_04') THEN --NI
				    p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
				  END IF;
			ELSIF(l_name in (('PQP GB PenServer Cutover Interface - Address'),
							 ('PQP GB PenServer Periodic Changes Interface - Address')))THEN
			    IF(p_column_name = 'VAL_02') THEN --NI
				    p_udf_mask_value := per_drt_udf.overwrite_id_number (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
				ELSIF(p_column_name = 'VAL_07') THEN --address
				    p_udf_mask_value := 'MASKED';

				ELSIF(p_column_name = 'VAL_08') THEN --address
				    p_udf_mask_value := 'MASKED';

			  	ELSIF(p_column_name = 'VAL_09') THEN --address
				    p_udf_mask_value := 'MASKED';

			  	ELSIF(p_column_name = 'VAL_10') THEN --address
				    p_udf_mask_value := 'MASKED';

				ELSIF(p_column_name = 'VAL_11') THEN --address
				    p_udf_mask_value := 'MASKED';

				ELSIF(p_column_name = 'VAL_12') THEN --postcode
				    p_udf_mask_value := 'MASKED';
				ELSIF(p_column_name = 'VAL_14') THEN --phone
				    p_udf_mask_value := 'MASKED';
			  	ELSIF(p_column_name = 'VAL_15') THEN --phone
				    p_udf_mask_value := 'MASKED';
			  	ELSIF(p_column_name = 'VAL_18') THEN --email
				    p_udf_mask_value := per_drt_udf.overwrite_email (p_row_id, p_table_name
			                                                       , p_column_name, p_person_id);
			  	END IF;


			END IF;

		  END IF;
		END IF;

	  hr_utility.trace('Leaving '||g_package||l_procedure);
	END;

END pay_gb_drt;

/
