--------------------------------------------------------
--  DDL for Package Body PAY_US_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_XDO_REPORT" AS
/* $Header: payusxml.pkb 120.6.12010000.3 2008/08/06 06:42:21 ubhat ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description : This package prepares XML data and template
                 required for GTN Report

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   07-DEC-2004  sgajula     115.0           Created
   11-DEC-2004  sgajula     115.1           Changed NULL to to_char(NULL) for
                                            db compliance
   04-FEB-2005  sgajula     115.2           Added code to display summary and
                                            Total Net for Last Classification
   04-MAR-2005  rdhingra    115.3           Modified code to display correct
                                            Total Net for Last classification
   05-MAR-2005  ahanda      115.4  4222867  Changed sql which fetches full_name
                                            to remove <, > and &.
   30-SEP-2005  ahanda      115.5  4639655  Added l_countlimit to retrict the data
                                            in a row in  vXMLTable
   23-NOV-2005  rdhingra    115.6  4742356  Updated value of l_countlimit
   02-DEC-2005  rdhingra    115.7  4771769  Added CDATA to take care of  special char
                                            from different names. Reverted changes of
                                            sql to take care of special char from full_name
   19-JAN-2006  rdhingra    115.8  4960092  Modified cursor c_unpay_details in
                                            procedure write_unpay_details to show the
                                            details of unpaid payments at the lowest sort
                                            level
   07-Apr-2006  rdhingra    115.9  5148084  Removed xml PI(processing instruction) from
                                            the procedure write_header.
                                            Removed Procedure FETCH_RTF_BLOB
   19-Feb-2007  saurgupt    115.10 5862861  Modified procedures WRITE_DETAIL_RECORDS and
                                            WRITE_UNPAY_DETAILS. Added the condition to check
                                            the length of xmlstring to avoid overflow error.


*/
  g_proc_name               VARCHAR2(240);
  l_sort1                   VARCHAR2(10);
  l_sort2                   VARCHAR2(10);
  l_sort3                   VARCHAR2(10);
  l_asg_flag                VARCHAR2(1);
  l_consolidation_set_id    NUMBER;
  l_payroll_id              NUMBER;
  l_gre_id                  NUMBER;
  l_tot_gross_earn_class    NUMBER := 0;
  l_tot_imput_earn_class    NUMBER := 0;
  l_tot_gross_pay_class     NUMBER := 0;
  l_tot_gross_non_pay_class NUMBER := 0;
  l_tot_vol_ded_class       NUMBER := 0;
  l_tot_invol_ded_class     NUMBER := 0;
  l_tot_ee_tax_class        NUMBER := 0;
  l_total_net_class         NUMBER := 0;
  l_tot_pre_tax_ded_class   NUMBER := 0;
  vCtr                      NUMBER := 0;
  l_pact_id                 NUMBER;
  l_business_group_id       NUMBER;
  l_param                   pay_payroll_actions.legislative_parameters%type;
  l_start_date              DATE;
  l_end_date                DATE;

  PROCEDURE GET_PARAMETERS
  (
        p_ppa_finder IN NUMBER
  ) IS

    CURSOR c_params(c_p_ppa_finder NUMBER) IS
    SELECT tax_unit_id,
           attribute2,
           to_number(attribute3),
           to_date(attribute4,'MM/DD/YYYY'),
           to_date(attribute5,'MM/DD/YYYY')
      FROM pay_us_rpt_totals
     WHERE organization_id = to_number(p_ppa_finder)
       AND attribute1  = 'GTN';

     l_proc_name    VARCHAR2(100);

  BEGIN

    l_proc_name := g_proc_name || 'GET_PARAMETERS';
    hr_utility.trace ('Entering '|| l_proc_name);

    hr_utility.trace (' p_ppa_finder '|| p_ppa_finder );

    OPEN c_params(p_ppa_finder);
    FETCH c_params INTO l_pact_id,
                        l_param,
                        l_business_group_id,
                        l_start_date,
                        l_end_date;
    CLOSE c_params;
/*
    hr_utility.trace (' l_pact_id '|| l_pact_id );
    hr_utility.trace (' l_param '|| l_param );
    hr_utility.trace (' l_business_group_id '|| l_business_group_id );
    hr_utility.trace (' l_start_date '|| l_start_date );
    hr_utility.trace (' l_end_date '|| l_end_date );
*/
    l_consolidation_set_id
                 := pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',l_param);
    l_payroll_id := pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',l_param);
    l_gre_id     := pay_paygtn_pkg.get_parameter('TRANSFER_GRE',l_param);
    l_sort1      := pay_paygtn_pkg.get_parameter('TRANSFER_SORT1',l_param);
    l_sort2      := pay_paygtn_pkg.get_parameter('TRANSFER_SORT2',l_param);
    l_sort3      := pay_paygtn_pkg.get_parameter('TRANSFER_SORT3',l_param);
    l_asg_flag   := NVL(pay_paygtn_pkg.get_parameter('TRANSFER_EMP_INFO',l_param),'N');
/*
    hr_utility.trace (' l_consolidation_set_id '|| l_consolidation_set_id );
    hr_utility.trace (' l_payroll_id '|| l_payroll_id );
    hr_utility.trace (' l_gre_id '|| l_gre_id );
    hr_utility.trace (' l_sort1 '|| l_sort1 );
    hr_utility.trace (' l_sort2 '|| l_sort2 );
    hr_utility.trace (' l_sort3 '|| l_sort3 );
    hr_utility.trace (' l_asg_flag '|| l_asg_flag );
*/
    hr_utility.trace ('Leaving '||l_proc_name);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         hr_utility.trace ('Inside Exception WHEN NO_DATA_FOUND for '|| l_proc_name);
  END GET_PARAMETERS;

  /* This Procedure writes the header details for GTN Report*/
  PROCEDURE WRITE_HEADER
  IS
    l_business_group_name    hr_organization_units.name%TYPE;
    l_payroll_name           VARCHAR2(80);
    l_print_set_payroll_name VARCHAR2(120);
    l_consolidation_set_name VARCHAR2(80);
    l_gre_name               VARCHAR2(80);
    l_print_sort1_name       VARCHAR2(100);
    l_print_sort2_name       VARCHAR2(100);
    l_print_sort3_name       VARCHAR2(100);
    l_proc_name              VARCHAR2(100);

  BEGIN

    l_proc_name := g_proc_name || 'write_header';
    hr_utility.trace ('Entering '|| l_proc_name);

    l_business_group_name := hr_reports.get_business_group(l_business_group_id);

    --hr_utility.trace (' l_business_group_name  : '|| l_business_group_name  );
    --hr_utility.trace (' l_payroll_id   : '|| l_payroll_id   );

    IF l_payroll_id IS NOT NULL THEN
       SELECT distinct substr(payroll_name,1,80),
              substr('Payroll    : '||payroll_name,1,80)
         INTO l_payroll_name,
              l_print_set_payroll_name
         FROM pay_payrolls_f
        WHERE payroll_id = l_payroll_id
          AND effective_start_date <= l_end_date
          AND effective_end_date >= l_end_date;
    END IF;

    --hr_utility.trace (' l_payroll_name   : '|| l_payroll_name );
    --hr_utility.trace (' l_print_set_payroll_name   : '|| l_print_set_payroll_name );
    --hr_utility.trace (' l_consolidation_set_id   : '|| l_consolidation_set_id );

    IF l_payroll_id IS NULL AND l_consolidation_set_id IS NOT NULL THEN
       SELECT consolidation_set_name,
              substr('Consolidation Set : '||consolidation_set_name,1,80)
         INTO l_consolidation_set_name,
              l_print_set_payroll_name
         FROM pay_consolidation_sets
        WHERE consolidation_set_id = l_consolidation_set_id;
    END IF;

    --hr_utility.trace (' consolidation_set_name   : '|| l_consolidation_set_name );

    IF l_payroll_id IS NOT NULL AND l_consolidation_set_id IS NOT NULL THEN
       SELECT consolidation_set_name,
              substr('Consolidation Set : '||consolidation_set_name,1,80)
         INTO l_consolidation_set_name,
              l_print_set_payroll_name
         FROM pay_consolidation_sets
        WHERE consolidation_set_id = l_consolidation_set_id;
    END IF;

    --hr_utility.trace (' l_gre_id   : '|| l_gre_id );

    IF l_gre_id IS NOT NULL THEN
       SELECT substr(name,1,80)
         INTO l_gre_name
         FROM hr_organization_units
        WHERE organization_id = l_gre_id;
    END IF;

    --hr_utility.trace (' l_gre_name   : '|| l_gre_name );

    IF l_sort1 IS NOT NULL THEN
       l_print_sort1_name := hr_general.decode_lookup('PAY_GTN_SORT',l_sort1) || ' Name';
    END IF;
    IF l_sort2 IS NOT NULL THEN
       l_print_sort2_name := hr_general.decode_lookup('PAY_GTN_SORT',l_sort2) || ' Name';
    END IF;
    IF l_sort3 IS NOT NULL THEN
       l_print_sort3_name := hr_general.decode_lookup('PAY_GTN_SORT',l_sort3) || ' Name';
    END IF;
/*
    hr_utility.trace (' l_sort1   : '|| l_sort1 );
    hr_utility.trace (' l_sort2   : '|| l_sort2 );
    hr_utility.trace (' l_sort3   : '|| l_sort3 );
*/
    vXMLTable.DELETE;
    vCtr := 0;

    /*Removed the xml PI(processing instruction) as the core package inserts it*/
    vXMLTable(vCtr).xmlstring := '';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<start>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<header>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<bgname>'
                                         || '<![CDATA[ '|| l_business_group_name || ' ]]>'
                                         || '</bgname>';

    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<DateHeader>'
                                         || to_char(sysdate,'DD-MON-YYYY HH24:MI')
                                         || '</DateHeader>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<StartDate>'
                                         || to_char(l_start_date,'DD-MON-YYYY')
                                         || '</StartDate>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<EndDate>'
                                         || to_char(l_end_date,'DD-MON-YYYY')
                                         || '</EndDate>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<greHeaderName>'
                                         || '<![CDATA[ '|| l_gre_name || ' ]]>'|| '</greHeaderName>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<PayrollHeaderName>'
                                         || '<![CDATA[ '|| l_payroll_name || ' ]]>'
                                         || '</PayrollHeaderName>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<ConsolidationSetName>'
                                         || '<![CDATA[ '|| l_consolidation_set_name || ' ]]>'
                                         || '</ConsolidationSetName>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<Sort1HeaderName>'
                                         || '<![CDATA[ '|| l_print_sort1_name || ' ]]>'
                                         || '</Sort1HeaderName>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<Sort2HeaderName>'
                                         || '<![CDATA[ '|| l_print_sort2_name || ' ]]>'
                                         || '</Sort2HeaderName>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '<Sort3HeaderName>'
                                         || '<![CDATA[ '|| l_print_sort3_name || ' ]]>'
                                         || '</Sort3HeaderName>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                         || '</header>';

--    hr_utility.trace (' vXMLTable(vCtr).xmlstring   : '|| vXMLTable(vCtr).xmlstring );

    hr_utility.trace ('Leaving '|| l_proc_name);

  END WRITE_HEADER;


PROCEDURE WRITE_DETAIL_RECORDS
(
        p_xfdf_blob OUT NOCOPY BLOB
) IS

cursor c_detail_records(cp_sort1 varchar2,
                        cp_sort2 varchar2,
                        cp_sort3 varchar2,
                        cp_asg_flag varchar2,
                        cp_pact_id number)
                        IS
SELECT   DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ) sort1_name,
         DECODE (LOWER (cp_sort2),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ) sort2_name,
         DECODE (LOWER (cp_sort3),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                )sort3_name,
         attribute12 emp_name,
         TO_NUMBER (attribute2) class_seq1, TO_NUMBER (attribute3) sub_class1,
         attribute4 classification1, attribute5 element_name1,
         SUM (value2) run_val1, to_number(SUM (value3)) run_hours1, COUNT (*) tot_count1,
         to_char(business_group_id) person_id
    FROM pay_us_rpt_totals
   WHERE cp_sort3 IS NOT NULL AND tax_unit_id = cp_pact_id
         AND attribute1 <> 'GTN'
         AND cp_asg_flag = 'Y'
GROUP BY DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ),
         DECODE (LOWER (cp_sort2),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ),
         DECODE (LOWER (cp_sort3),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ),
          to_char(business_group_id),
          attribute12,
         TO_NUMBER (attribute2),
         TO_NUMBER (attribute3),
         attribute4,
         attribute5
  HAVING (   DECODE (SIGN (SUM (value2)),
                     1, SUM (value2),
                     -1, -1 * SUM (value2),
                     0
                    ) > 0
          OR DECODE (SIGN (SUM (value3)),
                     1, SUM (value3),
                     -1, -1 * SUM (value3),
                     0
                    ) > 0
         )
         UNION
         SELECT   DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ) sort1_name,
         DECODE (LOWER (cp_sort2),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ) sort2_name,
         DECODE (LOWER (cp_sort3),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ) sort3_name,
                to_char(NULL),
         TO_NUMBER (attribute2) class_seq1, TO_NUMBER (attribute3) sub_class1,
         attribute4 classification1, attribute5 element_name1,
         SUM (value2) run_val1, SUM (value3) run_hours1, COUNT (*) tot_count1,
         to_char(NULL) person_id
    FROM pay_us_rpt_totals
   WHERE cp_sort3 IS NOT NULL AND tax_unit_id = cp_pact_id
         AND attribute1 <> 'GTN'
GROUP BY DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ),
         DECODE (LOWER (cp_sort2),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ),
         DECODE (LOWER (cp_sort3),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ),
                to_char(NULL),
         TO_NUMBER (attribute2),
         TO_NUMBER (attribute3),
         attribute4,
         attribute5
  HAVING (   DECODE (SIGN (SUM (value2)),
                     1, SUM (value2),
                     -1, -1 * SUM (value2),
                     0
                    ) > 0
          OR DECODE (SIGN (SUM (value3)),
                     1, SUM (value3),
                     -1, -1 * SUM (value3),
                     0
                    ) > 0
         )
UNION
SELECT   DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ) sort1_name,
         DECODE (LOWER (cp_sort2),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ) sort2_name,
         to_char(NULL) sort3_name,to_char(NULL) emp_name, TO_NUMBER (attribute2) class_seq1,
         TO_NUMBER (attribute3) sub_class1, attribute4 classification1,
         attribute5 element_name1, SUM (value2) run_val1,
         SUM (value3) run_hours1, COUNT (*) tot_count1,
         to_char(NULL) person_id
    FROM pay_us_rpt_totals
   WHERE cp_sort2 IS NOT NULL AND tax_unit_id = cp_pact_id
         AND attribute1 <> 'GTN'
GROUP BY DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ),
         DECODE (LOWER (cp_sort2),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 to_char(NULL)
                ),
         to_char(NULL),
         to_char(NULL),
         TO_NUMBER (attribute2),
         TO_NUMBER (attribute3),
         attribute4,
         attribute5
  HAVING (   DECODE (SIGN (SUM (value2)),
                     1, SUM (value2),
                     -1, -1 * SUM (value2),
                     0
                    ) > 0
          OR DECODE (SIGN (SUM (value3)),
                     1, SUM (value3),
                     -1, -1 * SUM (value3),
                     0
                    ) > 0
         )
UNION
SELECT   DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ) sort1_name,
         to_char(NULL) sort2_name, to_char(NULL) sort3_name,to_char(NULL) emp_name, TO_NUMBER (attribute2) class_seq1,
         TO_NUMBER (attribute3) sub_class1, attribute4 classification1,
         attribute5 element_name1, SUM (value2) run_val1,
         SUM (value3) run_hours1, COUNT (*) tot_count1,
         to_char(NULL) person_id
    FROM pay_us_rpt_totals
   WHERE tax_unit_id = cp_pact_id AND attribute1 <> 'GTN'
GROUP BY DECODE (LOWER (cp_sort1),
                 'loc', 'Location Name : ' || location_name,
                 'gre', 'GRE Name : ' || gre_name,
                 'org', 'Organization Name : ' || organization_name,
                 'GRE Name : ' || gre_name
                ),
         to_char(NULL),
         to_char(NULL),
         to_char(NULL),
         TO_NUMBER (attribute2),
         TO_NUMBER (attribute3),
         attribute4,
         attribute5
  HAVING (   DECODE (SIGN (SUM (value2)),
                     1, SUM (value2),
                     -1, -1 * SUM (value2),
                     0
                    ) > 0
          OR DECODE (SIGN (SUM (value3)),
                     1, SUM (value3),
                     -1, -1 * SUM (value3),
                     0
                    ) > 0
         )
ORDER BY 1, 2, 3, 4, 5,6;

  l_person_id         NUMBER;
  l_class_seq         NUMBER;
  l_sub_class         NUMBER;
  l_temp_count        NUMBER := 0;
  l_hours_sum         NUMBER := 0;
  l_val_sum           NUMBER := 0;
  l_count             NUMBER := 0;
  l_tot_gross_earn    NUMBER := 0;
  l_tot_imput_earn    NUMBER := 0;
  l_tot_gross_pay     NUMBER := 0;
  l_tot_gross_non_pay NUMBER := 0;
  l_tot_vol_ded       NUMBER := 0;
  l_tot_invol_ded     NUMBER := 0;
  l_tot_ee_tax        NUMBER := 0;
  l_total_net         NUMBER := 0;
  l_tot_pre_tax_ded   NUMBER := 0;
  l_countloop         NUMBER := 0;
  l_countlimit        NUMBER := 50;
  l_sort1_name        VARCHAR2(240);
  l_sort2_name        VARCHAR2(240);
  l_sort3_name        VARCHAR2(240);
  l_class_name        VARCHAR2(80);
  l_proc_name         VARCHAR2(100);
  l_temp_print varchar2 (1500);
  BEGIN

    l_proc_name := g_proc_name || 'WRITE_DETAIL_RECORDS';
    hr_utility.trace ('Entering '|| l_proc_name);
/*
    hr_utility.trace (' l_sort1 : ' || l_sort1 );
    hr_utility.trace (' l_sort2 : ' || l_sort2 );
    hr_utility.trace (' l_sort3 : ' || l_sort3 );
    hr_utility.trace (' l_asg_flag : ' || l_asg_flag );
    hr_utility.trace (' l_pact_id : ' || l_pact_id );
*/
    vCtr := vCtr + 1;
    vXMLTable(vCtr).xmlstring := '';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<detailblock>';

    FOR detrec IN c_detail_records(l_sort1 ,
                                   l_sort2 ,
                                   l_sort3 ,
                                   l_asg_flag ,
                                   l_pact_id
                                  )
    LOOP
    /* Check whether it is first record.If it is first record initialize the values*/
--    hr_utility.trace (' Loop Start length of vXMLTable(vCtr).xmlstring : ' || length(vXMLTable(vCtr).xmlstring));
    -- bug 5862861 :
    if length(vXMLTable(vCtr).xmlstring) >  30000 then
       vCtr := vCtr + 1;
       vXMLTable(vCtr).xmlstring := '';
    end if;

--    hr_utility.trace (' l_temp_count : ' || l_temp_count ||'  ,  '||' row count : ' || c_detail_records%rowcount  );

    IF l_temp_count <> 0 THEN
    /* The record is not the first Record */
    /* Check whether it is new sort clause.If it is a new sort group print the Summary values
       for Previous sort group, reset them and open new sort group*/
       /*
       hr_utility.trace (' l_temp_count <> 0 ' );
       hr_utility.trace (' l_sort1_name  : ' || l_sort1_name ||' , '||' detrec.sort1_name  : ' || detrec.sort1_name   );
       hr_utility.trace (' l_sort2_name  : ' || l_sort2_name ||' , '||' detrec.sort2_name  : ' || detrec.sort2_name   );
       hr_utility.trace (' l_sort3_name  : ' || l_sort3_name ||' , '||' detrec.sort3_name  : ' || detrec.sort3_name   );
       hr_utility.trace (' l_person_id  : ' || l_person_id ||' , '||' detrec.person_id  : ' || detrec.person_id );
       */

       if     (l_sort1_name = detrec.sort1_name or (l_sort1_name is NULL AND detrec.sort1_name is NULL))
          AND (l_sort2_name = detrec.sort2_name or (l_sort2_name is NULL AND detrec.sort2_name is NULL))
          AND (l_sort3_name = detrec.sort3_name or (l_sort3_name is NULL AND detrec.sort3_name is NULL))
          AND (l_person_id = detrec.person_id or (l_person_id is NULL AND detrec.person_id is NULL)) THEN
          /* Same sort Group*/
          /* Check whether its a new classification*/
          hr_utility.trace (' Same sort Group ' );
          /*
          hr_utility.trace (' l_class_seq : ' || l_class_seq ||' , '||' detrec.class_seq1  : ' || detrec.class_seq1 );

          hr_utility.trace (' l_sub_class : ' || l_sub_class ||' , '||' detrec.sub_class1  : ' || detrec.sub_class1 );
          */
          if l_class_seq = detrec.class_seq1 and l_sub_class = detrec.sub_class1 THEN
             NULL;
          else -- new classification
             /* Summary for the classification should not be displayed for Unpaid payments and Reversals,
                so added a check*/
             if l_class_seq not in (9,10) then
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotEleName>'||'Total '||l_class_name||'</TotEleName>';

                hr_utility.trace (' l_class_seq not in 9,10 ' );
                --
                if l_hours_sum = 0 THEN
                   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourSubTot>'||NULL||'</HourSubTot>';
                else
                   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourSubTot>'||l_hours_sum||'</HourSubTot>';
                end if;
                --
                if l_val_sum = 0 THEN
                   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ValSubTot>'||NULL||'</ValSubTot>';
                else
                   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ValSubTot>'||l_val_sum||'</ValSubTot>';
                end if;
                --
                if l_count = 0 THEN
                   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CountSubTot>'||NULL||'</CountSubTot>';
                else
                   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CountSubTot>'||l_count||'</CountSubTot>';
                end if;
                --
             end if; --l_class_seq not in (9,10)
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassGroup>';
             l_hours_sum := 0;
             l_val_sum := 0;
             l_count := 0;
             l_class_seq   := detrec.class_seq1;
             l_sub_class   := detrec.sub_class1;
             l_class_name  := detrec.classification1;

             --hr_utility.trace (' l_class_name : ' || l_class_name );

     --      vCtr := vCtr + 1;
    /*       if vCtr >= 1000 THEN
              WRITE_TO_CLOB(p_xfdf_blob);
              vCtr := 0;
              vXMLTable.DELETE;
           end if;*/
     --      vXMLTable(vCtr).xmlstring := ' ';

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassName>'||detrec.classification1||'</ClassName>';
             --hr_utility.trace (' vXMLTable(vCtr).xmlstring : ' || vXMLTable(vCtr).xmlstring );
             /*to be deleted*/
             --start
             /*
             if length(vXMLTable(vCtr).xmlstring) >= 1 then
                hr_utility.trace (' length of vXMLTable(vCtr).xmlstring : ' || length(vXMLTable(vCtr).xmlstring) );
                l_temp_print := substr(vXMLTable(vCtr).xmlstring , 1 , 1500);
                hr_utility.trace (' l_temp_print : ' || l_temp_print );
             end if;
             */

             --end
          end if;  -- new classification
       else -- else of sort clause
          /* For Totals By Classification Region Summary of totals should be displayed.
             This section will calculate the same*/
          hr_utility.trace (' else of sort ' );

          if l_sort2_name is NULL and l_sort3_name is NULL THEN
             l_tot_gross_earn_class := l_tot_gross_earn_class + l_tot_gross_earn;
             l_tot_imput_earn_class := l_tot_imput_earn_class + l_tot_imput_earn;
             l_tot_gross_pay_class := l_tot_gross_pay_class + l_tot_gross_pay;
             l_tot_pre_tax_ded_class := l_tot_pre_tax_ded_class + l_tot_pre_tax_ded;
             l_tot_gross_non_pay_class := l_tot_gross_non_pay_class + l_tot_gross_non_pay;
             l_tot_vol_ded_class := l_tot_vol_ded_class + l_tot_vol_ded;
             l_tot_invol_ded_class := l_tot_invol_ded_class + l_tot_invol_ded;
             l_tot_ee_tax_class := l_tot_ee_tax_class + l_tot_ee_tax;
          end if;
          /*End of Calculation Section for Summary of Totals in Totals By Classification Region*/

          /* Fix to show summary details of last classification in the sort group*/
          if l_class_seq not in (9,10) then
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotEleName>'||'Total '||l_class_name||'</TotEleName>';
             --
             if l_hours_sum = 0 THEN
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourSubTot>'||NULL||'</HourSubTot>';
             else
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourSubTot>'||l_hours_sum||'</HourSubTot>';
             end if;
             --
             if l_val_sum = 0 THEN
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ValSubTot>'||NULL||'</ValSubTot>';
             else
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ValSubTot>'||l_val_sum||'</ValSubTot>';
             end if;
             --
             if l_count = 0 THEN
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CountSubTot>'||NULL||'</CountSubTot>';
             else
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CountSubTot>'||l_count||'</CountSubTot>';
             end if;
          end if; -- l_class_seq not in (9,10)

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassGroup>';

          /*This Section prints Summary Totals for Each Sort Group*/
          l_total_net := nvl(l_tot_gross_pay,0) +
                         nvl(l_tot_gross_non_pay,0) -
                         nvl(l_tot_ee_tax,0) -
                         nvl(l_tot_vol_ded,0) -
                         nvl(l_tot_pre_tax_ded,0) -
                         nvl(l_tot_invol_ded,0);

          --hr_utility.trace (' l_total_net : ' || l_total_net );
          --hr_utility.trace (' l_tot_gross_earn : ' || l_tot_gross_earn );

          --
          if l_tot_gross_earn <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Gross Earnings :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_gross_earn||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_imput_earn <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Imputed Earnings :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_imput_earn||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_gross_pay <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Gross Pay :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_gross_pay||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_pre_tax_ded <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Pre-Tax Deductions :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_pre_tax_ded||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_gross_non_pay <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Gross Non-Payroll Payments :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_gross_non_pay||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_vol_ded <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Voluntary :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_vol_ded||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_invol_ded <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Involuntary :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_invol_ded||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --
          if l_tot_ee_tax <> 0 THEN

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total EE Tax :'||'</TotGrossName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_ee_tax||'</TotGrossVal>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          end if;
          --

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Net :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_total_net||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';

          /* End of Summary Totals for Sort Group*/
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortGroup>';

          /* Reset Sort Group Variables an Classification Group varaibles */
          l_hours_sum := 0;
          l_val_sum := 0;
          l_count := 0;
          l_tot_gross_earn :=0;
          l_tot_ee_tax := 0;
          l_tot_invol_ded := 0;
          l_tot_vol_ded :=0;
          l_tot_gross_non_pay := 0;
          l_tot_pre_tax_ded := 0;
          l_tot_gross_pay := 0;
          l_tot_imput_earn := 0;

          /*Print header details for New Sort Group */
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Sort1Name>'||'<![CDATA[ '||detrec.sort1_name|| ' ]]>'||'</Sort1Name>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Sort2Name>'||'<![CDATA[ '||detrec.sort2_name|| ' ]]>'||'</Sort2Name>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Sort3Name>'||'<![CDATA[ '||detrec.sort3_name|| ' ]]>'||'</Sort3Name>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EmpName>'||'<![CDATA[ '||detrec.emp_name|| ' ]]>'||'</EmpName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassName>'||detrec.classification1||'</ClassName>';

          /*Initialize Sort Group Variables and Classification Group varaibles*/
          l_sort1_name  := detrec.sort1_name;
          l_sort2_name  := detrec.sort2_name;
          l_sort3_name  := detrec.sort3_name;
          l_person_id    := detrec.person_id;
          l_class_seq   := detrec.class_seq1;
          l_sub_class   := detrec.sub_class1;
          l_class_name  := detrec.classification1;
       end if;  -- end if of sort clause
    else -- l_temp_count <> 0
       /* This Block will be executed for First Sort Group only,so this is called only once*/
       /*Initialize Sort Group Variables */
       --hr_utility.trace (' in else of l_temp_count <> 0 : ' );

       l_sort1_name  := detrec.sort1_name;
       l_sort2_name  := detrec.sort2_name;
       l_sort3_name  := detrec.sort3_name;
       l_person_id   := detrec.person_id;
       l_class_seq   := detrec.class_seq1;
       l_sub_class   := detrec.sub_class1;
       l_temp_count  := 1;
       /*Print header details for New Sort Group */
       /*
       hr_utility.trace (' in else l_temp_count  : ' || l_temp_count  );
       hr_utility.trace (' in else l_sort1_name  : ' || l_sort1_name ||' , '||' detrec.sort1_name  : ' || detrec.sort1_name   );
       hr_utility.trace (' in else l_sort2_name  : ' || l_sort2_name ||' , '||' detrec.sort2_name  : ' || detrec.sort2_name   );
       hr_utility.trace (' in else l_sort3_name  : ' || l_sort3_name ||' , '||' detrec.sort3_name  : ' || detrec.sort3_name   );
       hr_utility.trace (' in else l_person_id  : ' || l_person_id ||' , '||' detrec.person_id  : ' || detrec.person_id );
       hr_utility.trace (' in else l_class_seq  : ' || l_class_seq ||' , '||' detrec.class_seq1  : ' || detrec.class_seq1 );
       hr_utility.trace (' in else l_sub_class  : ' || l_sub_class ||' , '||' detrec.sub_class1  : ' || detrec.sub_class1 );
       */

       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortGroup>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Sort1Name>'||'<![CDATA[ '||detrec.sort1_name|| ' ]]>'||'</Sort1Name>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Sort2Name>'||'<![CDATA[ '||detrec.sort2_name|| ' ]]>'||'</Sort2Name>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<Sort3Name>'||'<![CDATA[ '||detrec.sort3_name|| ' ]]>'||'</Sort3Name>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EmpName>'||'<![CDATA[ '|| detrec.emp_name|| ' ]]>'||'</EmpName>';

       /*Print header details for New Classification Group */
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassGroup>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassName>'||detrec.classification1||'</ClassName>';
    end if; -- l_temp_count <> 0

     l_hours_sum := l_hours_sum + nvl(detrec.run_hours1,0);
     if detrec.class_seq1 <> 10 then
        l_val_sum := l_val_sum + nvl(detrec.run_val1,0);
     end if;
     if detrec.class_seq1 in (8,10,9) then
        l_count := l_count + nvl(detrec.tot_count1,0);
     end if;
     /* Calculate values for Sort Group Summary Totals*/
     if detrec.class_seq1 = '1' and detrec.classification1 <> 'Non-payroll Payments' THEN
        l_tot_gross_earn := l_tot_gross_earn + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '1' and detrec.classification1 = 'Imputed Earnings' THEN
        l_tot_imput_earn := l_tot_imput_earn + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '1' and detrec.classification1 <> 'Imputed Earnings'  and
        detrec.classification1 <> 'Non-payroll Payments' THEN
        l_tot_gross_pay := l_tot_gross_pay + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '4' and detrec.classification1 = 'Pre-Tax Deductions' THEN
         l_tot_pre_tax_ded := l_tot_pre_tax_ded + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '1' and detrec.classification1 = 'Non-payroll Payments' THEN
        l_tot_gross_non_pay := l_tot_gross_non_pay + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '4' and detrec.classification1 = 'Voluntary Deductions' THEN
        l_tot_vol_ded := l_tot_vol_ded + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '4' and detrec.classification1 = 'Involuntary Deductions' THEN
        l_tot_invol_ded := l_tot_invol_ded + detrec.run_val1;
     end if;
     if detrec.class_seq1 = '2' or detrec.class_seq1 = '3'  THEN
        l_tot_ee_tax := l_tot_ee_tax + detrec.run_val1;
     end if;

     vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EleGroup>';
     vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<EleName>'||'<![CDATA[ '||detrec.element_name1|| ' ]]>'||'</EleName>';

     if detrec.class_seq1 in ('8','10','9') then
        vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CouVal>'||detrec.tot_count1||'</CouVal>';
     else
        vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CouVal>'||NULL||'</CouVal>';
     end if;
        vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourVal>'||detrec.run_hours1||'</HourVal>';
     if detrec.class_seq1 = '10' then
        vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<RunVal>'||NULL||'</RunVal>';
     else
        vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<RunVal>'||detrec.run_val1||'</RunVal>';
     end if;

     vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</EleGroup>';

     /*To restrict the increase in the number of rows in vXMLTable.
       This can also be done after say loop has run n times.
     */
     l_countloop := l_countloop + 1;

     --hr_utility.trace (' l_countloop  : ' || l_countloop  );
     --hr_utility.trace (' l_countlimit  : ' || l_countlimit  );

     IF l_countloop >= l_countlimit THEN
        l_countloop := 0;
        vCtr := vCtr + 1;
        vXMLTable(vCtr).xmlstring := '';
     END IF;

    end LOOP;

    /* For totals by classification*/

    if l_sort2_name is NULL and l_sort3_name is NULL THEN
       l_tot_gross_earn_class := l_tot_gross_earn_class + l_tot_gross_earn;
       l_tot_imput_earn_class := l_tot_imput_earn_class + l_tot_imput_earn;
       l_tot_gross_pay_class := l_tot_gross_pay_class + l_tot_gross_pay;
       l_tot_pre_tax_ded_class := l_tot_pre_tax_ded_class + l_tot_pre_tax_ded;
       l_tot_gross_non_pay_class := l_tot_gross_non_pay_class + l_tot_gross_non_pay;
       l_tot_vol_ded_class := l_tot_vol_ded_class + l_tot_vol_ded;
       l_tot_invol_ded_class := l_tot_invol_ded_class + l_tot_invol_ded;
       l_tot_ee_tax_class := l_tot_ee_tax_class + l_tot_ee_tax;
    end if;

    /* End For totals by classification*/
    if l_temp_count <> 0 THEN
       l_total_net := nvl(l_tot_gross_pay,0) +
                      nvl(l_tot_gross_non_pay,0) -
                      nvl(l_tot_ee_tax,0) -
                      nvl(l_tot_vol_ded,0) -
                      nvl(l_tot_pre_tax_ded,0) -
                      nvl(l_tot_invol_ded,0);

       /* Fix to show summary details of last classification in the detailblock */

       if l_class_seq not in (9,10) then
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotEleName>'||'Total '||l_class_name||'</TotEleName>';

          ---
          if l_hours_sum = 0 THEN
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourSubTot>'||NULL||'</HourSubTot>';
          else
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<HourSubTot>'||l_hours_sum||'</HourSubTot>';
          end if;
          ---
          if l_val_sum = 0 THEN
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ValSubTot>'||NULL||'</ValSubTot>';
          else
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ValSubTot>'||l_val_sum||'</ValSubTot>';
          end if;
          ---
          if l_count = 0 THEN
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CountSubTot>'||NULL||'</CountSubTot>';
          else
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<CountSubTot>'||l_count||'</CountSubTot>';
          end if;
       end if; -- l_class_seq not in (9,10)

       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassGroup>';
       ---
       if l_tot_gross_earn <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Gross Earnings :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_gross_earn||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_imput_earn <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Imputed Earnings :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_imput_earn||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_gross_pay <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Gross Pay :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_gross_pay||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_pre_tax_ded <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Pre-Tax Deductions :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_pre_tax_ded||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_gross_non_pay <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Gross Non-Payroll Payments :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_gross_non_pay||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_vol_ded <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Voluntary :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_vol_ded||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_invol_ded <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Involuntary :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_invol_ded||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---
       if l_tot_ee_tax <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total EE Tax :'||'</TotGrossName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_tot_ee_tax||'</TotGrossVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';
       end if;
       ---

       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumGroup>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossName>'||'Total Net :'||'</TotGrossName>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotGrossVal>'||l_total_net||'</TotGrossVal>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumGroup>';


       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortGroup>';
     end if; --l_temp_count <> 0
     vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</detailblock>';

     hr_utility.trace ('Leaving '|| l_proc_name);

END WRITE_DETAIL_RECORDS;

/* This Procedure writes the details of Totals By Classification Region */
PROCEDURE WRITE_CLASSIF_DETAILS
IS

    CURSOR c_class_details(cp_pact_id number)
    IS
    SELECT   TO_NUMBER (attribute2) CLASS, TO_NUMBER (attribute3) sub_class,
             attribute4 classification_r, attribute5 element_name_r,
             SUM (value2) run_val_r, SUM (value3) run_hours_r, COUNT(*) run_tot_r
        FROM pay_us_rpt_totals
       WHERE tax_unit_id = cp_pact_id AND attribute1 <> 'GTN'
    GROUP BY TO_NUMBER (attribute2),
             TO_NUMBER (attribute3),
             attribute4,
             attribute5
      HAVING (   DECODE (SIGN (SUM (value2)),
                         1, SUM (value2),
                         -1, -1 * SUM (value2),
                         0
                        ) > 0
              OR DECODE (SIGN (SUM (value3)),
                         1, SUM (value3),
                         -1, -1 * SUM (value3),
                         0
                        ) > 0
             )
    ORDER BY 1,2,3,4;

    l_temp_count       NUMBER := 0;
    l_class_id         NUMBER := 0;
    l_sub_class_id     NUMBER := 0;
    l_class_total      NUMBER := 0;
    l_class_hours      NUMBER := 0;
    l_class_count      NUMBER := 0;
    l_countloop        NUMBER := 0;
    l_countlimit       NUMBER := 50;
    l_class_name_temp  VARCHAR2(240);
    l_proc_name        VARCHAR2(100);

BEGIN
    l_proc_name := g_proc_name || 'WRITE_CLASSIF_DETAILS';
    hr_utility.trace ('Entering '|| l_proc_name);

    vCtr := vCtr + 1;
    vXMLTable(vCtr).xmlstring := ' ';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<classblock>';
    l_temp_count := 0;

    for jrec in c_class_details(l_pact_id)
    LOOP
    if l_temp_count <> 0 THEN --Not the first record
       if l_class_id = jrec.class and l_sub_class_id = jrec.sub_class THEN
          NULL;
       else
          if (l_class_id not in (8,9,10) or l_class_count = 0) then
             l_class_count := NULL;
          end if;
          --
          if l_class_total = 0 or  l_class_id = 10 then
             l_class_total := NULL;
          end if;
          --
          if l_class_hours = 0 then
             l_class_hours := NULL;
          end if;
          --
          if l_class_total is not NULL or l_class_hours is not NULL or l_class_count is not NULL THEN
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassByName>'||l_class_name_temp||'</ClassByName>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleByRun>'||l_class_total||'</ClassEleByRun>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleByHours>'||l_class_hours||'</ClassEleByHours>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleByCount>'||l_class_count||'</ClassEleByCount>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumByClass>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumByClass>';
          end if;
          --
          l_class_total :=0;
          l_class_hours :=0;
          l_class_count :=0;
          l_class_id := jrec.class;
          l_sub_class_id := jrec.sub_class;
          l_class_name_temp := jrec.classification_r;

       end if;
    else
       l_class_id := jrec.class;
       l_sub_class_id := jrec.sub_class;
       l_class_name_temp := jrec.classification_r;
       l_temp_count := 1;
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortSumByClass>';
    end if;

    l_class_total := l_class_total + nvl(jrec.run_val_r,0);
    l_class_hours := l_class_hours + nvl(jrec.run_hours_r,0);
    l_class_count := l_class_count + nvl(jrec.run_tot_r,0);

    if jrec.class in (2,6) then
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<SortEleByClass>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleName>'||'<![CDATA[ '|| jrec.element_name_r|| ' ]]>'||'</ClassEleName>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleCnt>'||NULL||'</ClassEleCnt>';
       --
       if jrec.run_hours_r = 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleHrs>'||NULL||'</ClassEleHrs>';
       else
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleHrs>'||jrec.run_hours_r||'</ClassEleHrs>';
       end if;
       --
       if jrec.run_tot_r = 0  THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleRun>'||NULL||'</ClassEleRun>';
       else
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleRun>'||jrec.run_val_r||'</ClassEleRun>';
       end if;
       --
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortEleByClass>';
    end if;

    /*To restrict the increase in the number of rows in vXMLTable. This is done after say loop has run n times.*/

    l_countloop := l_countloop + 1;

    IF l_countloop >= l_countlimit THEN
       l_countloop := 0;
       vCtr := vCtr + 1;
       vXMLTable(vCtr).xmlstring := ' ';
    END IF;
    end LOOP;

    if l_temp_count <> 0 THEN
       if (l_class_id not in (8,9,10) or l_class_count = 0) then
          l_class_count := NULL;
       end if;
       --
       if l_class_total = 0 or  l_class_id = 10 then
          l_class_total := NULL;
       end if;
       --
       if l_class_hours = 0 then
          l_class_hours := NULL;
       end if;
       --
       if l_class_total is not NULL or l_class_hours is not NULL or l_class_count is not NULL THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassByName>'||l_class_name_temp||'</ClassByName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleByRun>'||l_class_total||'</ClassEleByRun>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleByHours>'||l_class_hours||'</ClassEleByHours>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassEleByCount>'||l_class_count||'</ClassEleByCount>';
       end if;
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</SortSumByClass>';
       l_total_net_class := nvl(l_tot_gross_pay_class,0) +
                            nvl(l_tot_gross_non_pay_class,0) -
                            nvl(l_tot_ee_tax_class,0) -
                            nvl(l_tot_vol_ded_class,0) -
                            nvl(l_tot_pre_tax_ded_class,0) -
                            nvl(l_tot_invol_ded_class,0);
       if l_tot_gross_earn_class <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Gross Earnings :'||'</TotClassSumName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_gross_earn_class||'</TotClassSumVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
       end if;
       --
       if l_tot_imput_earn_class <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Imputed Earnings :'||'</TotClassSumName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_imput_earn_class||'</TotClassSumVal>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
       end if;
       --
       if l_tot_gross_pay_class <> 0 THEN
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Gross Pay :'||'</TotClassSumName>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_gross_pay_class||'</TotClassSumVal>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
      end if;
      --
      if l_tot_pre_tax_ded_class <> 0 THEN
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Pre-Tax Deductions :'||'</TotClassSumName>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_pre_tax_ded_class||'</TotClassSumVal>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
      end if;
      --
      if l_tot_gross_non_pay_class <> 0 THEN
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Gross Non-Payroll Payments :'||'</TotClassSumName>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_gross_non_pay_class||'</TotClassSumVal>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
      end if;
      --
      if l_tot_vol_ded_class <> 0 THEN
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Voluntary :'||'</TotClassSumName>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_vol_ded_class||'</TotClassSumVal>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
      end if;
      --
      if l_tot_invol_ded_class <> 0 THEN
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Involuntary :'||'</TotClassSumName>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_invol_ded_class||'</TotClassSumVal>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
      end if;
      --
      if l_tot_ee_tax_class <> 0 THEN
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total EE Tax :'||'</TotClassSumName>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_tot_ee_tax_class||'</TotClassSumVal>';
         vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
      end if;
      --

      vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<ClassSumGroup>';
      vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumName>'||'Total Net :'||'</TotClassSumName>';
      vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<TotClassSumVal>'||l_total_net_class||'</TotClassSumVal>';
      vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</ClassSumGroup>';
   end if;

   vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</classblock>';

   hr_utility.trace ('Leaving '|| l_proc_name);

END WRITE_CLASSIF_DETAILS;

  /****************************************************************
  ** This Procedure writes details of Unprocessed Pre-Payments
  ** and Unpaid Payments
  ****************************************************************/
  PROCEDURE WRITE_UNPAY_DETAILS
  (
        p_xfdf_blob OUT NOCOPY BLOB
  ) IS
    CURSOR c_unpay_details(cp_pact_id NUMBER,
                           cp_sort1   VARCHAR2,
                           cp_sort2   VARCHAR2,
                           cp_sort3   VARCHAR2) IS
      SELECT to_number(attribute3) unpaid_sub_class1,
             decode(lower(cp_sort1),
                        'loc','Location Name : '||location_name,
                        'gre','GRE Name : '||gre_name   ,
                        'org','Organization Name : '||organization_name,
                        'GRE Name : '||gre_name) unpaid_sort1_name,
             decode(lower(cp_sort2),
                        'loc','Location Name : '||location_name,
                        'gre','GRE Name : '||gre_name   ,
                        'org','Organization Name : '||organization_name,
                        null) unpaid_sort2_name,
             decode(lower(cp_sort3),
                        'loc','Location Name : '||location_name,
                        'gre','GRE Name : '||gre_name   ,
                        'org','Organization Name : '||organization_name,
                        null) unpaid_sort3_name,
             to_number(attribute2) unpaid_class_seq1,
             attribute4 unpaid_classification1,
             attribute6     full_name,
             attribute7     asg_no,
             attribute8     pymt_method_name,
             attribute9     account_type,
             attribute10    account_number,
             attribute11    routing_number,
             organization_id aaid,
             location_id     pre_pay_id
        FROM pay_us_rpt_totals
       WHERE tax_unit_id = cp_pact_id
         AND attribute2 = '10'
         AND attribute3 in ('1','2') --Unprocessed/Unpaid Payments
         AND organization_id is not null
         AND attribute1 = 'MESG-LINE'
    ORDER BY 1,2,3,4,5,6,7;

    l_temp_count     NUMBER := 0;
    l_unpaid_class   NUMBER := 0;
    l_countloop      NUMBER := 0;
    l_countlimit     NUMBER := 50;
    l_unpaid_sort1   VARCHAR2(240);
    l_unpaid_sort2   VARCHAR2(240);
    l_unpaid_sort3   VARCHAR2(240);
    l_unpaid_col1    VARCHAR2(30);
    l_unpaid_col2    VARCHAR2(30);
    l_unpaid_col3    VARCHAR2(30);
    l_unpaid_col4    VARCHAR2(30);
    l_unpaid_col5    VARCHAR2(30);
    l_unpaid_col6    VARCHAR2(30);
    l_unpaid_col7    VARCHAR2(30);
    l_proc_name      VARCHAR2(100);

BEGIN
    l_proc_name := g_proc_name || 'WRITE_UNPAY_DETAILS';
    hr_utility.trace ('Entering '|| l_proc_name);

    vCtr := vCtr + 1;
    vXMLTable(vCtr).xmlstring := '';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<unpayblock>';

    l_temp_count := 0;

    for krec in c_unpay_details(l_pact_id ,
                                l_sort1,
                                l_sort2,
                                l_sort3)
    loop

       -- bug 5862861 :
       if length(vXMLTable(vCtr).xmlstring) >  30000 then
          vCtr := vCtr + 1;
          vXMLTable(vCtr).xmlstring := '';
       end if;

       --hr_utility.trace (' l_temp_count : ' || l_temp_count );
       if l_temp_count <> 0 THEN
          --not the first record
          --hr_utility.trace (' l_temp_count <> 0 ' );
          --hr_utility.trace (' l_unpaid_class  : ' || l_unpaid_class ||' , '||' krec.unpaid_sub_class1  : ' || krec.unpaid_sub_class1   );

          if l_unpaid_class = krec.unpaid_sub_class1 THEN
             /*
             hr_utility.trace (' l_unpaid_sort1  : ' || l_unpaid_sort1 ||' , '||' krec.unpaid_sort1_name  : ' || krec.unpaid_sort1_name   );
             hr_utility.trace (' l_unpaid_sort2  : ' || l_unpaid_sort2 ||' , '||' krec.unpaid_sort2_name  : ' || krec.unpaid_sort2_name   );
             hr_utility.trace (' l_unpaid_sort3  : ' || l_unpaid_sort3 ||' , '||' krec.unpaid_sort3_name  : ' || krec.unpaid_sort3_name   );
             */
             if ((l_unpaid_sort1 = krec.unpaid_sort1_name) or
                 (l_unpaid_sort1 is NULL and krec.unpaid_sort1_name is NULL)) and
                ((l_unpaid_sort2 = krec.unpaid_sort2_name) or
                 (l_unpaid_sort2 is NULL and krec.unpaid_sort2_name is NULL)) and
                ((l_unpaid_sort3 = krec.unpaid_sort3_name) or
                 (l_unpaid_sort3 is NULL and krec.unpaid_sort3_name is NULL)) THEN
                NULL;
             else  --new sort by
                hr_utility.trace (' in else of sort ');

                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '</UnpaySort>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaySort>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort1>'
                                               || 'Detail for :'
                                               || '<![CDATA[ '|| krec.unpaid_sort1_name || ' ]]>'
                                               || '</UnpaidSort1>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort2>'
                                               || '<![CDATA[ '|| krec.unpaid_sort2_name || ' ]]>'
                                               || '</UnpaidSort2>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort3>'
                                               || '<![CDATA[ '|| krec.unpaid_sort3_name || ' ]]>'
                                               || '</UnpaidSort3>';
                l_unpaid_sort1 := krec.unpaid_sort1_name;
                l_unpaid_sort2 := krec.unpaid_sort2_name;
                l_unpaid_sort3 := krec.unpaid_sort3_name;
                /*
                hr_utility.trace (' l_unpaid_sort1  : ' || l_unpaid_sort1 );
                hr_utility.trace (' l_unpaid_sort2  : ' || l_unpaid_sort2 );
                hr_utility.trace (' l_unpaid_sort3  : ' || l_unpaid_sort3 );
                */
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol1>'
                                               || l_unpaid_col1||'</UnpaidCol1>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol2>'
                                               || l_unpaid_col2||'</UnpaidCol2>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol3>'
                                               || l_unpaid_col3||'</UnpaidCol3>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol4>'
                                               || l_unpaid_col4||'</UnpaidCol4>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol5>'
                                               || l_unpaid_col5||'</UnpaidCol5>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol6>'
                                               || l_unpaid_col6||'</UnpaidCol6>';
                vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol7>'
                                               || l_unpaid_col7||'</UnpaidCol7>';


             end if; --new sort by
          else --new classification

             hr_utility.trace (' in else of new classification ');


             l_unpaid_class := krec.unpaid_sub_class1;

             --hr_utility.trace (' l_unpaid_class  : ' || l_unpaid_class );

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '</UnpaySort>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                              || '</UnpayClass>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpayClass>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidClassName>'
                                               || 'Detail of :'
                                               || krec.unpaid_classification1
                                               || '</UnpaidClassName>';

             if l_unpaid_class = 1 then
                l_unpaid_col1 := 'Employee Name';
                l_unpaid_col2 := 'Assign No.';
                l_unpaid_col3 := 'Asg Action ID';
                l_unpaid_col4 := NULL;
                l_unpaid_col5 := NULL;
                l_unpaid_col6 := NULL;
                l_unpaid_col7 := NULL;
             end if;

             if l_unpaid_class = 2 then
                l_unpaid_col1 := 'Employee Name';
                l_unpaid_col2 := 'Assign No.';
                l_unpaid_col3 := 'Pre-Pymnt ID';
                l_unpaid_col4 := 'Pymnt Method';
                l_unpaid_col5 := 'Account Type';
                l_unpaid_col6 := 'Account No.';
                l_unpaid_col7 := 'Routing No.';
             end if;
             /*
             hr_utility.trace (' l_unpaid_col1 : ' || l_unpaid_col1 );
             hr_utility.trace (' l_unpaid_col2 : ' || l_unpaid_col2 );
             hr_utility.trace (' l_unpaid_col3 : ' || l_unpaid_col3 );
             hr_utility.trace (' l_unpaid_col4 : ' || l_unpaid_col4 );
             hr_utility.trace (' l_unpaid_col5 : ' || l_unpaid_col5 );
             hr_utility.trace (' l_unpaid_col6 : ' || l_unpaid_col6 );
             hr_utility.trace (' l_unpaid_col7 : ' || l_unpaid_col7 );
             */

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<UnpaySort>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort1>'
                                               ||'Detail for :'
                                               ||'<![CDATA[ '|| krec.unpaid_sort1_name || ' ]]>'
                                               ||'</UnpaidSort1>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort2>'
                                               ||'<![CDATA[ '|| krec.unpaid_sort2_name || ' ]]>'
                                               ||'</UnpaidSort2>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort3>'
                                               ||'<![CDATA[ '|| krec.unpaid_sort3_name || ' ]]>'
                                               ||'</UnpaidSort3>';

             l_unpaid_sort1 := krec.unpaid_sort1_name;
             l_unpaid_sort2 := krec.unpaid_sort2_name;
             l_unpaid_sort3 := krec.unpaid_sort3_name;
             /*
             hr_utility.trace (' l_unpaid_sort1  : ' || l_unpaid_sort1 );
             hr_utility.trace (' l_unpaid_sort2  : ' || l_unpaid_sort2 );
             hr_utility.trace (' l_unpaid_sort3  : ' || l_unpaid_sort3 );
             */

             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol1>'
                                               ||l_unpaid_col1
                                               ||'</UnpaidCol1>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol2>'
                                               ||l_unpaid_col2
                                               ||'</UnpaidCol2>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol3>'
                                               ||l_unpaid_col3
                                               ||'</UnpaidCol3>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol4>'
                                               ||l_unpaid_col4
                                               ||'</UnpaidCol4>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol5>'
                                               ||l_unpaid_col5
                                               ||'</UnpaidCol5>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol6>'
                                               ||l_unpaid_col6
                                               ||'</UnpaidCol6>';
             vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol7>'
                                               ||l_unpaid_col7
                                               ||'</UnpaidCol7>';

          end if; -- new classification
       else --new record

          hr_utility.trace (' in else of new record '  );
          l_temp_count := 1;

          l_unpaid_class := krec.unpaid_sub_class1;

          --hr_utility.trace (' l_unpaid_class  : ' || l_unpaid_class );

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpayClass>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidClassName>'
                                               ||'Detail of :'
                                               ||krec.unpaid_classification1
                                               ||'</UnpaidClassName>';

          if l_unpaid_class = 1 then
             l_unpaid_col1 := 'Employee Name';
             l_unpaid_col2 := 'Assign No.';
             l_unpaid_col3 := 'Asg Action ID';
             l_unpaid_col4 := NULL;
             l_unpaid_col5 := NULL;
             l_unpaid_col6 := NULL;
             l_unpaid_col7 := NULL;
          end if;

          if l_unpaid_class = 2 then
             l_unpaid_col1 := 'Employee Name';
             l_unpaid_col2 := 'Assign No.';
             l_unpaid_col3 := 'Pre-Pymnt ID';
             l_unpaid_col4 := 'Pymnt Method';
             l_unpaid_col5 := 'Account Type';
             l_unpaid_col6 := 'Account No.';
             l_unpaid_col7 := 'Routing No.';
          end if;
          /*
          hr_utility.trace (' l_unpaid_col1 : ' || l_unpaid_col1 );
          hr_utility.trace (' l_unpaid_col2 : ' || l_unpaid_col2 );
          hr_utility.trace (' l_unpaid_col3 : ' || l_unpaid_col3 );
          hr_utility.trace (' l_unpaid_col4 : ' || l_unpaid_col4 );
          hr_utility.trace (' l_unpaid_col5 : ' || l_unpaid_col5 );
          hr_utility.trace (' l_unpaid_col6 : ' || l_unpaid_col6 );
          hr_utility.trace (' l_unpaid_col7 : ' || l_unpaid_col7 );
          */

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<UnpaySort>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort1>'
                                               ||'Detail for :'
                                               ||'<![CDATA[ '|| krec.unpaid_sort1_name || ' ]]>'
                                               ||'</UnpaidSort1>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort2>'
                                               ||'<![CDATA[ '|| krec.unpaid_sort2_name || ' ]]>'
                                               ||'</UnpaidSort2>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidSort3>'
                                               ||'<![CDATA[ '|| krec.unpaid_sort3_name || ' ]]>'
                                               ||'</UnpaidSort3>';

          l_unpaid_sort1 := krec.unpaid_sort1_name;
          l_unpaid_sort2 := krec.unpaid_sort2_name;
          l_unpaid_sort3 := krec.unpaid_sort3_name;
          /*
          hr_utility.trace (' l_unpaid_sort1  : ' || l_unpaid_sort1 );
          hr_utility.trace (' l_unpaid_sort2  : ' || l_unpaid_sort2 );
          hr_utility.trace (' l_unpaid_sort3  : ' || l_unpaid_sort3 );
          */

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol1>'
                                               ||l_unpaid_col1
                                               ||'</UnpaidCol1>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol2>'
                                               ||l_unpaid_col2||'</UnpaidCol2>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol3>'
                                               ||l_unpaid_col3||'</UnpaidCol3>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol4>'
                                               ||l_unpaid_col4||'</UnpaidCol4>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol5>'
                                               ||l_unpaid_col5||'</UnpaidCol5>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol6>'
                                               ||l_unpaid_col6||'</UnpaidCol6>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol7>'
                                               ||l_unpaid_col7||'</UnpaidCol7>';

       end if; --new record

       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '<UnpayEmp>';

       if l_unpaid_class = 1 then

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol1Val>'
                                               ||'<![CDATA[ '|| krec.full_name|| ' ]]>'
                                               ||'</UnpaidCol1Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol2Val>'
                                               ||krec.asg_no||'</UnpaidCol2Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol3Val>'
                                               ||krec.aaid||'</UnpaidCol3Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol4Val>'
                                               ||NULL
                                               ||'</UnpaidCol4Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol5Val>'
                                               ||NULL||'</UnpaidCol5Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol6Val>'||NULL
                                               ||'</UnpaidCol6Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol7Val>'||NULL
                                               ||'</UnpaidCol7Val>';

       else

          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol1Val>'
                                               ||'<![CDATA[ '|| krec.full_name|| ' ]]>'
                                               ||'</UnpaidCol1Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol2Val>'
                                               ||krec.asg_no
                                               ||'</UnpaidCol2Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol3Val>'
                                               ||krec.pre_pay_id||'</UnpaidCol3Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol4Val>'
                                               ||'<![CDATA[ '|| krec.pymt_method_name|| ' ]]>'
                                               ||'</UnpaidCol4Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol5Val>'
                                               ||krec.account_type
                                               ||'</UnpaidCol5Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol6Val>'
                                               ||krec.account_number
                                               ||'</UnpaidCol6Val>';
          vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring
                                               || '<UnpaidCol7Val>'
                                               ||krec.routing_number
                                               ||'</UnpaidCol7Val>';

       end if;
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</UnpayEmp>';
      -- vCtr := vCtr + 1;
       /* commented
       if vCtr >= 1000 then
          WRITE_TO_CLOB(p_xfdf_blob);
          vCtr := 0;
          vXMLTable.DELETE;
       end if;*/
       --vXMLTable(vCtr).xmlstring := ' ';

       /*To restrict the increase in the number of rows in vXMLTable.
         This can also be done after say loop has run n times.
       */

       --hr_utility.trace (' l_countloop  : ' || l_countloop  );
       --hr_utility.trace (' l_countlimit  : ' || l_countlimit  );

       l_countloop := l_countloop + 1;
       IF l_countloop >= l_countlimit THEN
        l_countloop := 0;
        vCtr := vCtr + 1;
        vXMLTable(vCtr).xmlstring := ' ';
       END IF;

    end loop;
    hr_utility.trace (' out of loop l_temp_count : ' || l_temp_count );

    if l_temp_count <> 0 THEN
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</UnpaySort>';
       vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</UnpayClass>';
    end if;

    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</unpayblock>';
    vXMLTable(vCtr).xmlstring := vXMLTable(vCtr).xmlstring || '</start>';

    hr_utility.trace ('Leaving '|| l_proc_name);

  END WRITE_UNPAY_DETAILS;

/****************************************************************************
  Name        : POPULATE_GTN_REPORT_DATA
  Description : Main procedure which returns the generated XML
*****************************************************************************/
  PROCEDURE POPULATE_GTN_REPORT_DATA
  (
        p_ppa_finder IN NUMBER
       ,p_xfdf_blob  OUT NOCOPY BLOB
  ) IS

    l_proc_name      VARCHAR2(100);
    l_err_num number;
    l_err_msg varchar2(300);
  BEGIN
    l_proc_name := g_proc_name || 'POPULATE_GTN_REPORT_DATA';
    hr_utility.trace ('Entering '|| l_proc_name);

    hr_utility.trace (' p_ppa_finder : '|| p_ppa_finder );

    get_parameters(p_ppa_finder);
    write_header;
    write_detail_records(p_xfdf_blob);
    write_classif_details;
    write_unpay_details(p_xfdf_blob);
    write_to_clob(p_xfdf_blob);

    BEGIN
    /*
      DELETE FROM pay_us_rpt_totals
            WHERE tax_unit_id = l_pact_id;*/
      /*Removing the commit as this procedure is now getting
        called from pypaygtn.pkb
      */
      --COMMIT;
     null;
    EXCEPTION
      WHEN OTHERS THEN
       l_err_num := SQLCODE;
       l_err_msg := substr(SQLERRM , 1 , 300 );

       HR_UTILITY.TRACE('Inside Exception WHEN OTHERS in Procedure' || l_proc_name);
       HR_UTILITY.TRACE('l_err_num : ' || l_err_num );
       HR_UTILITY.TRACE('l_err_msg : ' || l_err_msg );

    END;

    hr_utility.trace ('Leaving '|| l_proc_name);

  END POPULATE_GTN_REPORT_DATA;

/****************************************************************************
  Name        : WRITE_TO_CLOB
  Description : Procedure to put the data in a clob
*****************************************************************************/
  PROCEDURE WRITE_TO_CLOB
  (
        p_xfdf_blob OUT NOCOPY BLOB
  ) IS

    l_xfdf_string  CLOB;
    l_proc_name    VARCHAR2(100);

  BEGIN
    l_proc_name := g_proc_name || 'WRITE_TO_CLOB';
    hr_utility.trace ('Entering '|| l_proc_name);

    DBMS_LOB.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    DBMS_LOB.open(l_xfdf_string,dbms_lob.lob_readwrite);

    IF vXMLTable.count > 0 THEN
       FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
           dbms_lob.writeAppend(l_xfdf_string,
                                LENGTH(vXMLTable(ctr_table).xmlstring),
                                vXMLTable(ctr_table).xmlstring );
       END LOOP;
    END IF;

    DBMS_LOB.createtemporary(p_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,p_xfdf_blob);

    hr_utility.trace ('Leaving '|| l_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
       HR_UTILITY.TRACE('Inside Exception WHEN OTHERS of Procedure' || l_proc_name);
       HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
       HR_UTILITY.RAISE_ERROR;
  END WRITE_TO_CLOB;

/****************************************************************************
  Name        : CLOB_TO_BLOB
  Description : Procedure to convert a clob value to a blob value
*****************************************************************************/
  PROCEDURE CLOB_TO_BLOB
  (
        p_clob IN CLOB
       ,p_blob IN OUT NOCOPY BLOB
  ) IS
    l_raw_buffer      RAW(32000);
    l_blob            BLOB;
    l_offset          INTEGER;
    l_length_clob     NUMBER;
    l_buffer_len      NUMBER := 16000; /* 7182157 */
    l_chunk_len       NUMBER;
    l_varchar_buffer  VARCHAR2(32000);
    l_proc_name       VARCHAR2(100);
    l_raw_length      NUMBER; /* 7182157 */

  BEGIN
    l_proc_name := g_proc_name || 'CLOB_TO_BLOB';
    hr_utility.trace ('Entering '|| l_proc_name);

    l_length_clob := dbms_lob.getlength(p_clob);
    l_offset := 1;

    WHILE l_length_clob > 0
    LOOP
          hr_utility.trace('l_length_clob '|| l_length_clob);

          IF l_length_clob < l_buffer_len THEN
             l_chunk_len := l_length_clob;
          ELSE
             l_chunk_len := l_buffer_len;
          END IF;

          DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
          l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
          l_raw_length := utl_raw.length(l_raw_buffer); /* 7182157 */
	  /*Commented the following trace sentence
	    This used to create issues when we were asking
	    traces from the customers
	  */
          --hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
        --  DBMS_LOB.writeappend(p_blob,l_chunk_len,l_raw_buffer); /* 7182157 */
          DBMS_LOB.writeappend(p_blob,l_raw_length,l_raw_buffer); /* 7182157 */
          l_offset := l_offset + l_chunk_len;
          l_length_clob := l_length_clob - l_chunk_len;

          hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
    END LOOP;

    hr_utility.trace ('Leaving '|| l_proc_name);
  END CLOB_TO_BLOB;

BEGIN
--        hr_utility.trace_on(NULL,'trc_payusxml');
        g_proc_name := 'PAY_US_XDO_REPORT.';

END PAY_US_XDO_REPORT;

/
