--------------------------------------------------------
--  DDL for Package Body PAY_US_ONLINE_W4_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ONLINE_W4_XML_PKG" 
/* $Header: pyw4xmlp.pkb 120.2.12010000.1 2008/07/28 00:01:20 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2005 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_online_w4_xml_pkg

    Description : This package contains the procedure generate_xml to
                  generate the XML extract for Online W4 PDF

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------
    31-MAY-2005 rsethupa   115.0            Created
    14-JUN-2005 rsethupa   115.1            Comma printed between name
                                            and address lines only if
					    required
    31-JAN-2006 jgoswami   115.2   5012064  Modified c_get_personal_details
                                            added date filters
    21-MAY-2007 vaprakas  115.3  6029939  Modified code to fix a display issue.

    *****************************************************************

    ****************************************************************************
    Procedure Name: generate_xml
    Description: Returns the XML extract for Online W4 PDF
    ***************************************************************************/
AS
   PROCEDURE generate_xml (
      p_person_id             IN              per_people_f.person_id%TYPE,
      p_transaction_step_id   IN              hr_api_transaction_steps.transaction_step_id%TYPE,
      p_temp_dir              IN              VARCHAR2,
      p_appl_short_name       IN              VARCHAR2,
      p_template_code         IN              VARCHAR2,
      p_default_language      IN              VARCHAR2,
      p_default_territory     IN              VARCHAR2,
      p_xml_string            OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR c_get_updated_values (cp_transaction_step_id IN NUMBER)
      IS
         SELECT fs.varchar2_value fs_value, allo.number_value allo_value,
                aa.number_value aa_value, ex.varchar2_value ex_value,
                lnd.varchar2_value lnd_value
           FROM hr_api_transaction_values fs,
                hr_api_transaction_values allo,
                hr_api_transaction_values aa,
                hr_api_transaction_values ex,
                hr_api_transaction_values lnd
          WHERE fs.transaction_step_id = cp_transaction_step_id
            AND fs.NAME = 'P_FILING_STATUS'
            AND allo.transaction_step_id = fs.transaction_step_id
            AND allo.NAME = 'P_ALLOWANCES'
            AND aa.transaction_step_id = fs.transaction_step_id
            AND aa.NAME = 'P_ADDITIONAL_TAX'
            AND ex.transaction_step_id = fs.transaction_step_id
            AND ex.NAME = 'P_EXEMPT'
            AND lnd.transaction_step_id = fs.transaction_step_id
            AND lnd.NAME = 'P_LAST_NAME_DIFF';

      CURSOR c_get_personal_details (cp_person_id IN NUMBER)
      IS
         SELECT ppf.first_name,
	        SUBSTR (ppf.middle_names, 1, 1) middle_initial,
                ppf.last_name,
                ppf.national_identifier,
                pad.address_line1,
		pad.address_line2,
		pad.address_line3,
                pad.town_or_city || ', ' || pad.region_2 || ', ' || pad.postal_code city_town_zip
           FROM per_people_f ppf, per_addresses pad
          WHERE ppf.person_id = cp_person_id
            AND ppf.person_id = pad.person_id
            AND trunc(sysdate) between ppf.effective_start_date
                                   and ppf.effective_end_date
            AND pad.primary_flag = 'Y'
            AND trunc(sysdate) between pad.date_from
                                   and nvl(pad.date_to, trunc(sysdate));

      CURSOR c_get_lookup_codes (cp_meaning IN VARCHAR2)
      IS
         SELECT lookup_code
           FROM fnd_common_lookups fcl
          WHERE lookup_type = 'US_FIT_FILING_STATUS'
            AND application_id = 800
            AND meaning = cp_meaning;

      l_filing_status         VARCHAR2 (100);
      l_allowances            NUMBER;
      l_additional_amount     NUMBER;
      l_exempt                VARCHAR2 (100);
      l_last_name_diff        VARCHAR2 (2);
      l_first_name            VARCHAR2 (100);
      l_middle_initial        VARCHAR2 (100);
      l_last_name             VARCHAR2 (100);
      l_national_identifier   VARCHAR2 (100);
      l_home_address          VARCHAR2 (255);
      l_address_line1         VARCHAR2 (255);
      l_address_line2         VARCHAR2 (255);
      l_address_line3         VARCHAR2 (255);
      l_city_state_zip        VARCHAR2 (100);
      l_count                 NUMBER (15);
      l_year                  VARCHAR2 (4);
      l_filing_status_code    VARCHAR2 (2);
      l_fs_married            VARCHAR2 (2);
      l_fs_single             VARCHAR2 (2);
      l_fs_married_withhold   VARCHAR2 (2);
      l_xml_string            VARCHAR2 (32767) DEFAULT NULL;
      l_last_name_flag        VARCHAR2 (1);
      l_date                  DATE;
      l_signature             VARCHAR2 (100);
   BEGIN
      --hr_utility.trace_on (NULL, 'pyw4xmlp');
      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 10);
      hr_utility.TRACE ('p_person_id: ' || p_person_id);
      hr_utility.TRACE ('p_transaction_step_id: ' || p_transaction_step_id);
      hr_utility.TRACE ('p_temp_dir: ' || p_temp_dir);
      hr_utility.TRACE ('p_appl_short_name: ' || p_appl_short_name);
      hr_utility.TRACE ('p_template_code: ' || p_template_code);
      hr_utility.TRACE ('p_default_language: ' || p_default_language);
      hr_utility.TRACE ('p_default_territory: ' || p_default_territory);
      l_count := 0;

      OPEN c_get_personal_details (p_person_id);

      FETCH c_get_personal_details
       INTO l_first_name, l_middle_initial, l_last_name,
            l_national_identifier, l_address_line1, l_address_line2,
	    l_address_line3, l_city_state_zip;

      CLOSE c_get_personal_details;

      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 20);

      OPEN c_get_updated_values (p_transaction_step_id);

      FETCH c_get_updated_values
       INTO l_filing_status, l_allowances, l_additional_amount, l_exempt,
            l_last_name_diff;

      CLOSE c_get_updated_values;

      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 30);

      OPEN c_get_lookup_codes (l_filing_status);

      FETCH c_get_lookup_codes
       INTO l_filing_status_code;

      CLOSE c_get_lookup_codes;

      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 40);

      IF l_filing_status_code = '01'
      THEN
         l_fs_single := 'Y';
      ELSIF l_filing_status_code = '02'
      THEN
         l_fs_married := 'Y';
      ELSE
         l_fs_married_withhold := 'Y';
      END IF;

      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 50);

      SELECT SYSDATE, TO_CHAR (SYSDATE, 'YYYY')
        INTO l_date, l_year
        FROM DUAL;

      l_xml_data_table (l_count).xml_tag := '<YEAR>';
      l_xml_data_table (l_count).xml_data := l_year;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<FIRST_NAME>';
      IF l_middle_initial IS NOT NULL
      THEN
         l_xml_data_table (l_count).xml_data :=
                                        l_first_name || ', ' || l_middle_initial;
      ELSE
         l_xml_data_table (l_count).xml_data := l_first_name;
      END IF;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<LAST_NAME>';
      l_xml_data_table (l_count).xml_data := l_last_name;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<NATIONAL_IDENTIFIER>';
      l_xml_data_table (l_count).xml_data := l_national_identifier;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<HOME_ADDRESS>';
      l_home_address := l_address_line1;
      IF l_address_line2 IS NOT NULL
      THEN
         l_home_address := l_home_address || ', ' || l_address_line2;
      END IF;
      IF l_address_line3 IS NOT NULL
      THEN
         l_home_address := l_home_address || ', ' || l_address_line3;
      END IF;
      l_xml_data_table (l_count).xml_data := l_home_address;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<CITY_STATE_ZIP>';
      l_xml_data_table (l_count).xml_data := l_city_state_zip;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<FILING_STATUS_SINGLE>';
      l_xml_data_table (l_count).xml_data := l_fs_single;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<FILING_STATUS_MARRIED>';
      l_xml_data_table (l_count).xml_data := l_fs_married;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<FILING_STATUS_MARRIED_WITHHOLD>';
      l_xml_data_table (l_count).xml_data := l_fs_married_withhold;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<LAST_NAME_DIFF>';
      l_xml_data_table (l_count).xml_data := l_last_name_diff;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<TOTAL_ALLOWANCES>';
      l_xml_data_table (l_count).xml_data := l_allowances;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<ADDITIONAL_AMOUNT>';
      IF l_additional_amount = 0
      THEN
          l_xml_data_table (l_count).xml_data := l_additional_amount;
      ELSE
          l_xml_data_table (l_count).xml_data := ltrim(to_char(round(l_additional_amount,2),'9999999999999.00'));
      END IF;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<EXEMPT>';

      IF l_exempt = 'Yes'
      THEN
         l_xml_data_table (l_count).xml_data := 'Exempt';
      ELSE
         l_xml_data_table (l_count).xml_data := NULL;
      END IF;

      l_count := l_count + 1;
      IF l_middle_initial IS NOT NULL
      THEN
	 l_signature := l_first_name || ' ' || l_middle_initial || '. ' || l_last_name;
      ELSE
         l_signature := l_first_name || ' ' || l_last_name;
      END IF;

      l_xml_data_table (l_count).xml_tag := '<SIGNATURE>';
      l_xml_data_table (l_count).xml_data := l_signature;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<DATE>';
      l_xml_data_table (l_count).xml_data := l_date;

      l_count := l_count + 1;
      l_xml_data_table (l_count).xml_tag := '<FORMW4_YEAR>';
      l_xml_data_table (l_count).xml_data := l_year;

      l_xml_string := '<?xml version="1.0" encoding="UTF-8"?>';
      l_xml_string :=
            l_xml_string
         || '<xapi:requestset xmlns:xapi="http://xmlns.oracle.com/oxp/xapi">';
      l_xml_string := l_xml_string || '<xapi:request>';
      l_xml_string := l_xml_string || '<xapi:delivery>';
      l_xml_string :=
            l_xml_string
         || '<xapi:filesystem output="'
         || p_temp_dir
         || 'onlinew4_'
         || p_person_id
         || '.pdf">';
      l_xml_string := l_xml_string || '</xapi:filesystem>';
      l_xml_string := l_xml_string || '</xapi:delivery>';
      l_xml_string := l_xml_string || '<xapi:document output-type="pdf">';
      l_xml_string :=
            l_xml_string
         || '<xapi:template type="xsl-fo" location="xdo://'
         || p_appl_short_name
         || '.'
         || p_template_code
         || '.'
         || p_default_language
         || '.'
         || p_default_territory
         || '">';
      l_xml_string := l_xml_string || '<xapi:data>';
      l_xml_string := l_xml_string || '<START>';
      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 60);

      FOR counter IN l_xml_data_table.FIRST .. l_xml_data_table.LAST
      LOOP
         l_xml_string :=
               l_xml_string
            || l_xml_data_table (counter).xml_tag
            || l_xml_data_table (counter).xml_data
            || '</'
            || SUBSTR (l_xml_data_table (counter).xml_tag, 2);
      END LOOP;

      l_xml_string :=
            l_xml_string
         || '</START></xapi:data></xapi:template></xapi:document></xapi:request></xapi:requestset>';
      p_xml_string := l_xml_string;
      hr_utility.set_location ('pay_us_online_w4_xml_pkg.generate_xml', 70);
   END generate_xml;
END pay_us_online_w4_xml_pkg;

/
