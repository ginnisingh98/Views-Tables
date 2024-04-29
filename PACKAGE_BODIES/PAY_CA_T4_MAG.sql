--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4_MAG" AS
 /* $Header: pycat4mg.pkb 120.2.12010000.5 2009/02/18 13:20:42 sapalani ship $ */

 /*
    Name     : get_report_parameters

    Purpose
      The procedure gets the 'parameter' for which the report is being
      run i.e., the period, state and business organization.

    Arguments
      p_pactid                  Payroll_action_id passed from pyugen process
      p_year_start              Start Date of the period for which the report
                                has been requested
      p_year_end                End date of the period
      p_business_group_id       Business group for which the report is being run
      p_report_type             Type of report being run T4

    Notes
  */


PROCEDURE get_report_parameters
        (       p_pactid                IN             NUMBER,
                p_year_start            IN OUT NOCOPY  DATE,
                p_year_end              IN OUT NOCOPY  DATE,
                p_report_type           IN OUT NOCOPY  VARCHAR2,
                p_business_group_id     IN OUT NOCOPY  NUMBER,
                p_legislative_parameters OUT NOCOPY VARCHAR2
        ) IS
        BEGIN
        /*      hr_utility.trace_on('Y','T4MAG'); */
                hr_utility.set_location
                ('pay_ca_t4_mag.get_report_parameters', 10);

                SELECT  ppa.start_date,
                        ppa.effective_date,
                        ppa.business_group_id,
                        ppa.report_type,
                        ppa.legislative_parameters
                  INTO  p_year_start,
                        p_year_end,
                        p_business_group_id,
                        p_report_type,
                        p_legislative_parameters
                  FROM  pay_payroll_actions ppa
                 WHERE  payroll_action_id = p_pactid;

                hr_utility.set_location
                ('pay_ca_t4_mag.get_report_parameters', 20);

        END get_report_parameters;


/*
  Name
    range_cursor
  Purpose
    This procedure defines a SQL statement
    to fetch all the people to be included in the report. This SQL statement
    is  used to define the 'chunks' for multi-threaded operation
  Arguments
    p_pactid                    payroll action id for the report
    p_sqlstr                    the SQL statement to fetch the people
*/

PROCEDURE range_cursor (
        p_pactid        IN      NUMBER,
        p_sqlstr        OUT NOCOPY  VARCHAR2
)
IS
        p_year_start                    DATE;
        p_year_end                      DATE;
        p_business_group_id             NUMBER;
        p_report_type                   VARCHAR2(30);
        l_legislative_parameters        VARCHAR2(200);

BEGIN

        hr_utility.set_location( 'pay_ca_t4_mag.range_cursor', 10);

        get_report_parameters(
                p_pactid,
                p_year_start,
                p_year_end,
                p_report_type,
                p_business_group_id,
                l_legislative_parameters
        );

        hr_utility.set_location( 'pay_ca_t4_mag.range_cursor', 20);

        p_sqlstr := 'select distinct to_number(fai1.value)
                from    ff_archive_items fai1,
                        ff_database_items fdi1,
                        ff_archive_items fai2,
                        ff_database_items fdi2,
                        pay_assignment_actions  paa,
                        pay_payroll_actions     ppa,
                        pay_payroll_actions     ppa1
                 where  ppa1.payroll_action_id    = :payroll_action_id
                 and    ppa.business_group_id+0 = ppa1.business_group_id
                 and    ppa.effective_date = ppa1.effective_date
                 and    ppa.report_type = ''T4''
                 and    ppa.payroll_action_id = paa.payroll_action_id
                 and    fdi2.user_name = ''CAEOY_TAXATION_YEAR''
                 and    fai2.user_entity_id = fdi2.user_entity_id
                 and    fai2.value = pay_ca_t4_mag.get_parameter(''REPORTING_YEAR'',ppa1.legislative_parameters)
                 and    paa.payroll_action_id= fai2.context1
                 and    paa.action_status = ''C''
                 and    paa.assignment_action_id = fai1.context1
                 and    fai1.user_entity_id = fdi1.user_entity_id
                 and    fdi1.user_name = ''CAEOY_PERSON_ID''
                 order by to_number(fai1.value)'  ;

                hr_utility.set_location( 'pay_ca_t4_mag.range_cursor',
                                        30);

END range_cursor;


/*
  Name
    create_assignment_act
  Purpose
    Creates assignment actions for the payroll action associated with the
    report
  Arguments
    p_pactid                            payroll action for the report
    p_stperson                  starting person id for the chunk
    p_endperson                 last person id for the chunk
    p_chunk                             size of the chunk
  Note
    The procedure processes assignments in 'chunks' to facilitate
    multi-threaded operation. The chunk is defined by the size and the
    starting and ending person id. An interlock is also created against the
    pre-processor assignment action to prevent rolling back of the archiver.
*/

PROCEDURE create_assignment_act(
        p_pactid        IN NUMBER,
        p_stperson      IN NUMBER,
        p_endperson IN NUMBER,
        p_chunk         IN NUMBER )
IS

        /* Cursor to retrieve all the assignments for all GRE's
           archived in a reporting year */

        CURSOR c_all_asg IS
            SELECT paf.person_id,
                 paf.assignment_id,
                 Paa.tax_unit_id,
                 paf.effective_end_date,
                 paa.assignment_action_id
            FROM pay_payroll_actions ppa,
                 pay_assignment_actions paa,
                 per_all_assignments_f paf,
                 pay_payroll_actions ppa1
        WHERE ppa1.payroll_action_id = p_pactid
          AND ppa.report_type = 'T4'
          AND ppa.business_group_id+0 = ppa1.business_group_id
          AND ppa.effective_date = ppa1.effective_date
          AND paa.payroll_action_id = ppa.payroll_action_id
          AND paa.action_status = 'C'
          AND exists ( /* Query to select all GRE 's under a transmitter GRE */
                        select 'X'
                        from
                        hr_organization_information hoi1,
                        hr_organization_information hoi
                        where hoi.organization_id = paa.tax_unit_id
                        and hoi.org_information_context = 'Canada Employer Identification'
                        and to_number(hoi.org_information11) = pay_ca_t4_mag.get_parameter('TRANSMITTER_GRE',ppa1.legislative_parameters)
                        and hoi1.org_information_context = 'Fed Magnetic Reporting'
                        and hoi.org_information5 = 'T4/RL1'
                        and hoi1.organization_id = to_number(hoi.org_information11)
                      )
          AND paf.assignment_id = paa.assignment_id
          AND paf.person_id BETWEEN p_stperson AND p_endperson
          AND paf.assignment_type = 'E'
          AND paf.effective_start_date <= ppa.effective_date
          AND paf.effective_end_date >= ppa.start_date
          AND paf.effective_end_date = (SELECT MAX(paf2.effective_end_date)
                                        FROM per_all_assignments_f paf2
                                        WHERE paf2.assignment_id = paf.assignment_id
                                        AND paf2.effective_start_date <= ppa.effective_date )
          ORDER BY paf.person_id;


        /* local variables */

        l_year_start            DATE;
        l_year_end              DATE;
        l_effective_end_date    DATE;
        l_report_type           VARCHAR2(30);
        l_business_group_id     NUMBER;
        l_person_id             NUMBER;
        l_assignment_id         NUMBER;
        l_assignment_action_id  NUMBER;
        l_value                 NUMBER;
        l_tax_unit_id           NUMBER;
        lockingactid            NUMBER;

        l_trans_gre               VARCHAR2(10);
        l_validate_gre            VARCHAR2(10);
        l_legislative_parameters  VARCHAR2(200);

BEGIN

        /* Get the report parameters. These define the report being run.*/

        hr_utility.set_location( 'pay_ca_t4_mag.create_assignement_act',10);

        get_report_parameters(
                p_pactid,
                l_year_start,
                l_year_end,
                l_report_type,
                l_business_group_id,
                l_legislative_parameters
                );

        /* Open the appropriate cursor */

        l_trans_gre := pay_ca_t4a_mag.get_parameter('TRANSMITTER_GRE',
                                             l_legislative_parameters);
        hr_utility.trace('l_trans_gre ='||l_trans_gre);
        l_validate_gre := pay_ca_t4_mag.validate_gre_data(l_trans_gre, to_char(l_year_end,'YYYY'));
        hr_utility.set_location( 'pay_ca_t4_mag.create_assignement_act',20);

        IF l_report_type = 'PYT4MAG' THEN
                OPEN c_all_asg;
                LOOP
                        FETCH c_all_asg INTO l_person_id,
                                             l_assignment_id,
                                             l_tax_unit_id,
                                             l_effective_end_date,
                                             l_assignment_action_id;

                        hr_utility.set_location(
                                'pay_ca_t4_mag.create_assignement_act', 30);

                        EXIT WHEN c_all_asg%NOTFOUND;


                /* Create the assignment action for the record */

                  hr_utility.trace('Assignment Fetched  - ');
                  hr_utility.trace('Assignment Id : '|| to_char(l_assignment_id));
                  hr_utility.trace('Person Id :  '|| to_char(l_person_id));
                  hr_utility.trace('tax unit id : '|| to_char(l_tax_unit_id));
                  hr_utility.trace('Effective End Date :  '||
                                     to_char(l_effective_end_date));

                  hr_utility.set_location(
                                'pay_ca_t4_mag.create_assignement_act', 40);

                        SELECT pay_assignment_actions_s.nextval
                        INTO lockingactid
                        FROM dual;

                        hr_utility.set_location(
                                'pay_ca_t4_mag.create_assignement_act', 50);

                        hr_nonrun_asact.insact(lockingactid, l_assignment_id, p_pactid,p_chunk, l_tax_unit_id);

                        hr_utility.set_location(
                                'pay_ca_t4_mag.create_assignement_act', 60);

                        hr_nonrun_asact.insint(lockingactid, l_assignment_action_id);

                        hr_utility.set_location(
                                'pay_ca_t4_mag.create_assignement_act', 70);

                        hr_utility.trace('Interlock Created  - ');
                        hr_utility.trace('Locking Action : '|| to_char(lockingactid));
                        hr_utility.trace('Locked Action :  '|| to_char(l_assignment_action_id));

                END LOOP;
                Close c_all_asg;
        END IF;

END create_assignment_act;

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin

     token_val := name||'=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

end get_parameter;


function get_dbitem_value(p_asg_act_id in number,
                          p_dbitem_name in varchar2,
                          p_jurisdiction varchar2 default null) return varchar2
is
lv_value varchar2(60);

cursor c_get_dbitem_value(cp_dbitem varchar2,
                          cp_jurisdiction varchar2) is
SELECT fai1.value
FROM FF_ARCHIVE_ITEMS FAI1,
     ff_database_items fdi1,
     ff_archive_item_contexts faic,
     ff_contexts fc
WHERE FAI1.USER_ENTITY_ID = fdi1.user_entity_id
and fdi1.user_name = cp_dbitem
and fai1.archive_item_id = faic.archive_item_id
and fc.context_id = faic.context_id
and fc.context_name = 'JURISDICTION_CODE'
and faic.context = cp_jurisdiction
AND FAI1.CONTEXT1 = p_asg_act_id;

begin

   open c_get_dbitem_value(p_dbitem_name,
                           p_jurisdiction);
   fetch c_get_dbitem_value into lv_value;
   if c_get_dbitem_value%NOTFOUND then
      lv_value := 'ZZZ';
   end if;
   close c_get_dbitem_value;

   return lv_value;

end;

FUNCTION  convert_2_xml(p_data           IN varchar2,
                        p_tag            IN varchar2,
                        p_datatype       IN char default 'T',
                        p_format         IN varchar2 default NULL,
                        p_null_allowed   IN VARCHAR2 DEFAULT 'N' )
return varchar2 is

  l_data          varchar2(4000);
  l_output        varchar2(4000);
BEGIN
  if p_null_allowed = 'N'
    and (TRIM(p_data) is null or (p_datatype in ('N','C') and to_number(p_data) = 0)) then
    return ' ';
  end if;

  l_data := trim(p_data);
  l_data := REPLACE(l_data, '&' , '&' || 'amp;');
  l_data := REPLACE(l_data, '<'     , '&' || 'lt;');
  l_data := REPLACE(l_data, '>'     , '&' || 'gt;');
  l_data := REPLACE(l_data, ''''    , '&' || 'apos;');
  l_data := REPLACE(l_data, '"'     , '&' || 'quot;');
  --------------------------------------------------------
  --- P_Datatype: T = Text, N = Number, C=Currency, D=Date
  --------------------------------------------------------
  IF p_datatype = 'T' or p_datatype = 'D' then
    l_output := '<' || trim(p_tag) || '>' || trim(l_data) || '</' || trim(p_tag) || '>
';
  ELSIF p_datatype = 'N' or p_datatype = 'C' then
    IF TRIM(p_format) is not null then
        select to_char(to_number(p_data), p_format)
          into l_data from dual;
    ELSIF p_datatype = 'C' then  -- Currency should be two decimal places
        select to_char(to_number(p_data), '99999999999999999999999999999999999990.99')
          into l_data from dual;
    END IF;
    l_output := '<' || trim(p_tag) || '>' || trim(l_data) || '</' || trim(p_tag) || '>
';
  END IF;

  return l_output;
END;

FUNCTION get_arch_val( p_context_id IN NUMBER,
                         p_user_name  IN VARCHAR2)
RETURN varchar2 IS

cursor cur_archive (b_context_id NUMBER, b_user_name VARCHAR2) is
select fai.value
from   ff_archive_items fai,
       ff_database_items fdi
where  fai.user_entity_id = fdi.user_entity_id
and    fai.context1  = b_context_id
and    fdi.user_name = b_user_name;

l_return  VARCHAR2(240);
BEGIN
        open cur_archive(p_context_id,p_user_name);
        fetch cur_archive into l_return;
        close cur_archive;
    RETURN (l_return);
END ;

/* Function convert_t4_oth_info_amt
      - For Bug 6855236
      - To process the other info amounts for T4 Magnetic Media.
      - Call to this function is made in fast formula T4_EMPLOYEE.
      - Formatted XML strings for other info amounts are returned through out paramaters
      - Additionally formatted strings for .a03 file are returned through out paramaters
*/

FUNCTION convert_t4_oth_info_amt(p_assignment_action_id IN Number,
                            p_payroll_action_id         IN Number,
                            p_jusrisdiction             IN varchar2,
                            p_tax_unit_id               IN Number,
                            p_fail                      IN char,
                            p_oth_rep1                  OUT nocopy varchar2,
                            p_oth_rep2                  OUT nocopy varchar2,
                            p_oth_rep3                  OUT nocopy varchar2,
                            p_write_f31                 OUT nocopy varchar2,
                            p_transfer_other_info1_str1 OUT nocopy varchar2,
                            p_transfer_other_info1_str2 OUT nocopy varchar2,
                            p_transfer_other_info1_str3 OUT nocopy varchar2,
                            p_transfer_other_info2_str1 OUT nocopy varchar2,
                            p_transfer_other_info2_str2 OUT nocopy varchar2,
                            p_transfer_other_info2_str3 OUT nocopy varchar2,
                            p_transfer_other_info3_str1 OUT nocopy varchar2,
                            p_transfer_other_info3_str2 OUT nocopy varchar2,
                            p_transfer_other_info3_str3 OUT nocopy varchar2,
                            p_transfer_other_info4_str1 OUT nocopy varchar2,
                            p_transfer_other_info4_str2 OUT nocopy varchar2,
                            p_transfer_other_info4_str3 OUT nocopy varchar2,
                            p_transfer_oth1_rep1        OUT nocopy varchar2,
                            p_transfer_oth1_rep2        OUT nocopy varchar2,
                            p_transfer_oth1_rep3        OUT nocopy varchar2,
                            p_transfer_oth2_rep2        OUT nocopy varchar2,
                            p_transfer_oth2_rep3        OUT nocopy varchar2,
                            p_transfer_oth3_rep2        OUT nocopy varchar2,
                            p_transfer_oth3_rep3        OUT nocopy varchar2,
                            p_transfer_oth4_rep3        OUT nocopy varchar2,
                            p_cnt                       OUT nocopy Number)
return varchar2 is

    l_other_info                varchar2(100);
    l_cnt                       Number      :=0;
    l_amt                       Number      :=0;

    l_write_f30                 varchar2(400) := ' ';
    l_write_f31                 varchar2(400) := ' ';
    l_oth_rep1                  varchar2(400);
    l_oth_rep2                  varchar2(400);
    l_oth_rep3                  varchar2(400);
    l_transfer_other_info1_str1 varchar2(400);
    l_transfer_other_info1_str2 varchar2(400);
    l_transfer_other_info1_str3 varchar2(400);
    l_transfer_other_info2_str1 varchar2(400);
    l_transfer_other_info2_str2 varchar2(400);
    l_transfer_other_info2_str3 varchar2(400);
    l_transfer_other_info3_str1 varchar2(400);
    l_transfer_other_info3_str2 varchar2(400);
    l_transfer_other_info3_str3 varchar2(400);
    l_transfer_other_info4_str1 varchar2(400);
    l_transfer_other_info4_str2 varchar2(400);
    l_transfer_other_info4_str3 varchar2(400);
    l_transfer_oth1_rep1        varchar2(400);
    l_transfer_oth1_rep2        varchar2(400);
    l_transfer_oth1_rep3        varchar2(400);
    l_transfer_oth2_rep2        varchar2(400);
    l_transfer_oth2_rep3        varchar2(400);
    l_transfer_oth3_rep2        varchar2(400);
    l_transfer_oth3_rep3        varchar2(400);
    l_transfer_oth4_rep3        varchar2(400);

    type string_table is table of varchar2(50) index by binary_integer;
    t_dbi string_table;
    t_tag string_table;

BEGIN

    /* DBIs of other info amounts */
    t_dbi(1) := 'CAEOY_T4_OTHER_INFO_AMOUNT30_PER_JD_GRE_YTD';
    t_dbi(2) := 'CAEOY_T4_OTHER_INFO_AMOUNT31_PER_JD_GRE_YTD';
    t_dbi(3) := 'CAEOY_T4_OTHER_INFO_AMOUNT32_PER_JD_GRE_YTD';
    t_dbi(4) := 'CAEOY_T4_OTHER_INFO_AMOUNT33_PER_JD_GRE_YTD';
    t_dbi(5) := 'CAEOY_T4_OTHER_INFO_AMOUNT34_PER_JD_GRE_YTD';
    t_dbi(6) := 'CAEOY_T4_OTHER_INFO_AMOUNT35_PER_JD_GRE_YTD';
    t_dbi(7) := 'CAEOY_T4_OTHER_INFO_AMOUNT36_PER_JD_GRE_YTD';
    t_dbi(8) := 'CAEOY_T4_OTHER_INFO_AMOUNT37_PER_JD_GRE_YTD';
    t_dbi(9) := 'CAEOY_T4_OTHER_INFO_AMOUNT38_PER_JD_GRE_YTD';
    t_dbi(10) := 'CAEOY_T4_OTHER_INFO_AMOUNT39_PER_JD_GRE_YTD';
    t_dbi(11) := 'CAEOY_T4_OTHER_INFO_AMOUNT40_PER_JD_GRE_YTD';
    t_dbi(12) := 'CAEOY_T4_OTHER_INFO_AMOUNT41_PER_JD_GRE_YTD';
    t_dbi(13) := 'CAEOY_T4_OTHER_INFO_AMOUNT42_PER_JD_GRE_YTD';
    t_dbi(14) := 'CAEOY_T4_OTHER_INFO_AMOUNT43_PER_JD_GRE_YTD';
    t_dbi(15) := 'CAEOY_T4_OTHER_INFO_AMOUNT53_PER_JD_GRE_YTD';
    t_dbi(16) := 'CAEOY_T4_OTHER_INFO_AMOUNT70_PER_JD_GRE_YTD';
    t_dbi(17) := 'CAEOY_T4_OTHER_INFO_AMOUNT71_PER_JD_GRE_YTD';
    t_dbi(18) := 'CAEOY_T4_OTHER_INFO_AMOUNT72_PER_JD_GRE_YTD';
    t_dbi(19) := 'CAEOY_T4_OTHER_INFO_AMOUNT73_PER_JD_GRE_YTD';
    t_dbi(20) := 'CAEOY_T4_OTHER_INFO_AMOUNT74_PER_JD_GRE_YTD';
    t_dbi(21) := 'CAEOY_T4_OTHER_INFO_AMOUNT75_PER_JD_GRE_YTD';
    t_dbi(22) := 'CAEOY_T4_OTHER_INFO_AMOUNT77_PER_JD_GRE_YTD';
    t_dbi(23) := 'CAEOY_T4_OTHER_INFO_AMOUNT78_PER_JD_GRE_YTD';
    t_dbi(24) := 'CAEOY_T4_OTHER_INFO_AMOUNT79_PER_JD_GRE_YTD';
    t_dbi(25) := 'CAEOY_T4_OTHER_INFO_AMOUNT80_PER_JD_GRE_YTD';
    t_dbi(26) := 'CAEOY_T4_OTHER_INFO_AMOUNT81_PER_JD_GRE_YTD';
    t_dbi(27) := 'CAEOY_T4_OTHER_INFO_AMOUNT82_PER_JD_GRE_YTD';
    t_dbi(28) := 'CAEOY_T4_OTHER_INFO_AMOUNT83_PER_JD_GRE_YTD';
    t_dbi(29) := 'CAEOY_T4_OTHER_INFO_AMOUNT84_PER_JD_GRE_YTD';
    t_dbi(30) := 'CAEOY_T4_OTHER_INFO_AMOUNT85_PER_JD_GRE_YTD';

    /* XML Tags for corresponding other info amounts*/
    t_tag(1) := 'hm_brd_lodg_amt';
    t_tag(2) := 'spcl_wrk_site_amt';
    t_tag(3) := 'prscb_zn_trvl_amt';
    t_tag(4) := 'med_trvl_amt';
    t_tag(5) := 'prsnl_vhcl_amt';
    t_tag(6) := 'rsn_per_km_amt';
    t_tag(7) := 'low_int_loan_amt';
    t_tag(8) := 'empe_hm_loan_amt';
    t_tag(9) := 'sob_a00_feb_amt';
    t_tag(10) := 'sod_d_a00_feb_amt';
    t_tag(11) := 'oth_tx_ben_amt';
    t_tag(12) := 'sod_d1_a00_feb_amt';
    t_tag(13) := 'empt_cmsn_amt';
    t_tag(14) := 'cfppa_amt';
    t_tag(15) := 'dfr_sob_amt';
    t_tag(16) := 'mun_ofcr_examt';
    t_tag(17) := 'indn_empe_amt';
    t_tag(18) := 'oc_incamt';
    t_tag(19) := 'oc_dy_cnt';
    t_tag(20) := 'pr_90_cntrbr_amt';
    t_tag(21) := 'pr_90_ncntrbr_amt';
    t_tag(22) := 'cmpn_rpay_empr_amt';
    t_tag(23) := 'fish_gro_ern_amt';
    t_tag(24) := 'fish_net_ptnr_amt';
    t_tag(25) := 'fish_shr_prsn_amt';
    t_tag(26) := 'plcmt_emp_agcy_amt';
    t_tag(27) := 'drvr_taxis_oth_amt';
    t_tag(28) := 'brbr_hrdrssr_amt';
    t_tag(29) := 'pub_trnst_pass_amt';
    t_tag(30) := 'epaid_hlth_pln_amt';

    l_transfer_oth1_rep1  := rpad(lpad('.00,',12),  6*12, lpad('.00,',12));
    --l_transfer_oth2_rep1  := rpad(lpad('.00,',12), 10*12, lpad('.00,',12));
    --l_transfer_oth2_rep2  := rpad(lpad('.00,',10),  2*10, lpad('.00,',10));
    --l_transfer_oth3_rep1  := rpad(lpad('.00,',12), 10*12, lpad('.00,',12));
    l_transfer_oth3_rep2  := rpad(lpad('.00,',12),  6*12, lpad('.00,',12));
    --l_transfer_oth4_rep1  := rpad(lpad('.00,',12), 10*12, lpad('.00,',12));
    --l_transfer_oth4_rep2  := rpad(lpad('.00,',12), 10*12, lpad('.00,',12));
    l_transfer_oth4_rep3  := rpad(lpad('.00,',12),  4*12, lpad('.00,',12));

    hr_utility.trace('p_assignment_action_id = '||p_assignment_action_id);
    hr_utility.trace('p_payroll_action_id = '||p_payroll_action_id);
    hr_utility.trace('p_fail = '||p_fail);

    for i in 1..t_dbi.COUNT
    loop
     l_amt := fnd_number.canonical_to_number(get_dbitem_value(p_assignment_action_id,t_dbi(i),p_jusrisdiction));
     if (p_fail <> 'Y') and (l_amt >0) then
        if(i=19) then
          l_other_info := CONVERT_2_XML(l_amt, t_tag(i), 'N');  --For oth. code 73 (<oc_dy_cnt>)
        else
          l_other_info := CONVERT_2_XML(l_amt, t_tag(i), 'C');  -- Bug 7424296
        end if;
        l_cnt := l_cnt+1;

        hr_utility.trace('l_other_info = '||l_other_info);
        hr_utility.trace('l_cnt = '||l_cnt);

        if l_cnt <= 3 then
            l_write_f30 := l_write_f30||l_other_info;
        elsif l_cnt <=6 then
            l_write_f31 := l_write_f31||l_other_info;
        elsif l_cnt <= 8 then
             l_transfer_other_info1_str1 := l_transfer_other_info1_str1 || l_other_info;
        elsif l_cnt <= 10 then
             l_transfer_other_info1_str2 := l_transfer_other_info1_str2 || l_other_info;
        elsif l_cnt <= 12 then
             l_transfer_other_info1_str3 := l_transfer_other_info1_str3 || l_other_info;
        elsif l_cnt <= 14 then
             l_transfer_other_info2_str1 := l_transfer_other_info2_str1 || l_other_info;
        elsif l_cnt <= 16 then
             l_transfer_other_info2_str2 := l_transfer_other_info2_str2 || l_other_info;
        elsif l_cnt <= 18 then
             l_transfer_other_info2_str3 := l_transfer_other_info2_str3 || l_other_info;
        elsif l_cnt <= 20 then
             l_transfer_other_info3_str1 := l_transfer_other_info3_str1 || l_other_info;
        elsif l_cnt <= 22 then
             l_transfer_other_info3_str2 := l_transfer_other_info3_str2 || l_other_info;
        elsif l_cnt <= 24 then
             l_transfer_other_info3_str3 := l_transfer_other_info3_str3 || l_other_info;
        elsif l_cnt <= 26 then
             l_transfer_other_info4_str1 := l_transfer_other_info4_str1 || l_other_info;
        elsif l_cnt <= 28 then
             l_transfer_other_info4_str2 := l_transfer_other_info4_str2 || l_other_info;
        else
             l_transfer_other_info4_str3 := l_transfer_other_info4_str3 || l_other_info;
        end if;
     end if;

       /* Formatting strings for .a03 audit report */
       if i <=6 then
             l_oth_rep1 := l_oth_rep1 || to_char(l_amt, '9999999.99') ||',';
       elsif i <=12 then
            if p_fail = 'Y' or l_cnt <= 6 then
                l_oth_rep1   := l_oth_rep1  || to_char(l_amt, '9999999.99') ||',';
                l_transfer_oth1_rep1  := l_transfer_oth1_rep1 || lpad('.00,',12);
            else
                  l_oth_rep1   := l_oth_rep1 || lpad('.00,',12);
                  l_transfer_oth1_rep1  := l_transfer_oth1_rep1 || to_char(nvl(l_amt,0), '9999999.99') ||',';
            end if;
       elsif i <=18 then
            if p_fail = 'Y' or l_cnt <= 6 then
                  l_oth_rep2 := l_oth_rep2  || to_char(l_amt, '9999999.99') ||',';
                  l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('.00,',12);
                  l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('.00,',12);
            elsif l_cnt <= 12 then
                  l_oth_rep2 := l_oth_rep2  || lpad('.00,',12);
                  l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || to_char(l_amt, '9999999.99') ||',';
                  l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('.00,',12);
            else
                  l_oth_rep2 := l_oth_rep2  || lpad('.00,',12);
                  l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('.00,',12);
                  l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || to_char(l_amt, '9999999.99') ||',';
            end if;
       elsif i <=24 then
            if p_fail = 'Y' or l_cnt <= 6 then
                  if i =19 then
                    l_oth_rep2 := l_oth_rep2  || lpad( to_char(l_amt, '999') ||',',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('0,',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('0,',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad('0,',12);
                  else
                    l_oth_rep2 := l_oth_rep2  || to_char(l_amt, '9999999.99') ||',';
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('.00,',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('.00,',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad('.00,',12);
                  end if;
            elsif l_cnt <= 12 then
                  if i =19 then
                    l_oth_rep2 := l_oth_rep2  || lpad('0,',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad(to_char(l_amt,'999')||',',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('0,',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad('0,',12);
                  else
                    l_oth_rep2 := l_oth_rep2  || lpad('.00,',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || to_char(l_amt, '9999999.99') ||',';
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('.00,',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad('.00,',12);
                  end if;
            elsif l_cnt <= 18 then
                  if i =19 then
                    l_oth_rep2 := l_oth_rep2  || lpad('0,',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('0,',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad(to_char(l_amt, '999') ||',',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad('0,',12);
                  else
                    l_oth_rep2 := l_oth_rep2  || lpad('.00,',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('.00,',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || to_char(l_amt, '9999999.99') ||',';
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad('.00,',12);
                  end if;
            else
                  if i =19 then
                    l_oth_rep2 := l_oth_rep2  || lpad('0,',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('0,',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('0,',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || lpad(to_char(l_amt, '999') ||',',12);
                  else
                    l_oth_rep2 := l_oth_rep2  || lpad('.00,',12);
                    l_transfer_oth1_rep2 := l_transfer_oth1_rep2 || lpad('.00,',12);
                    l_transfer_oth2_rep2 := l_transfer_oth2_rep2 || lpad('.00,',12);
                    l_transfer_oth3_rep2 := l_transfer_oth3_rep2 || to_char(l_amt, '9999999.99') ||',';
                  end if;
           end if;
       elsif i <=30 then
           if p_fail = 'Y' or l_cnt <= 6 then
                 l_oth_rep3 := l_oth_rep3  || to_char(l_amt, '9999999.99') ||',';
                  l_transfer_oth1_rep3 := l_transfer_oth1_rep3 || lpad('.00,',12);
                  l_transfer_oth2_rep3 := l_transfer_oth2_rep3 || lpad('.00,',12);
                  l_transfer_oth3_rep3 := l_transfer_oth3_rep3 || lpad('.00,',12);
                  l_transfer_oth4_rep3 := l_transfer_oth4_rep3 || lpad('.00,',12);
           elsif l_cnt <= 12 then
                  l_oth_rep3 := l_oth_rep3  || lpad('.00,',12);
                  l_transfer_oth1_rep3 := l_transfer_oth1_rep3 || to_char(l_amt, '9999999.99') ||',';
                  l_transfer_oth2_rep3 := l_transfer_oth2_rep3 || lpad('.00,',12);
                  l_transfer_oth3_rep3 := l_transfer_oth3_rep3 || lpad('.00,',12);
                  l_transfer_oth4_rep3 := l_transfer_oth4_rep3 || lpad('.00,',12);
           elsif l_cnt <= 18 then
                  l_oth_rep3 := l_oth_rep3  || lpad('.00,',12);
                  l_transfer_oth1_rep3 := l_transfer_oth1_rep3 || lpad('.00,',12);
                  l_transfer_oth2_rep3 := l_transfer_oth2_rep3 || to_char(l_amt, '9999999.99') ||',';
                  l_transfer_oth3_rep3 := l_transfer_oth3_rep3 || lpad('.00,',12);
                  l_transfer_oth4_rep3 := l_transfer_oth4_rep3 || lpad('.00,',12);
           elsif l_cnt <= 24 then
                  l_oth_rep3 := l_oth_rep3  || lpad('.00,',12);
                  l_transfer_oth1_rep3 := l_transfer_oth1_rep3 || lpad('.00,',12);
                  l_transfer_oth2_rep3 := l_transfer_oth2_rep3 || lpad('.00,',12);
                  l_transfer_oth3_rep3 := l_transfer_oth3_rep3 || to_char(l_amt, '9999999.99') ||',';
                  l_transfer_oth4_rep3 := l_transfer_oth4_rep3 || lpad('.00,',12);
           else
                  l_oth_rep3 := l_oth_rep3  || lpad('.00,',12);
                  l_transfer_oth1_rep3 := l_transfer_oth1_rep3 || lpad('.00,',12);
                  l_transfer_oth2_rep3 := l_transfer_oth2_rep3 || lpad('.00,',12);
                  l_transfer_oth3_rep3 := l_transfer_oth3_rep3 || lpad('.00,',12);
                  l_transfer_oth4_rep3 := l_transfer_oth4_rep3 || to_char(l_amt, '9999999.99') ||',';
           end if;
       end if;
    end loop;

    p_cnt                       := l_cnt;
    p_oth_rep1                  := l_oth_rep1;
    p_oth_rep2                  := l_oth_rep2;
    p_oth_rep3                  := l_oth_rep3;
    p_write_f31                 := l_write_f31;
    p_transfer_other_info1_str1 := l_transfer_other_info1_str1;
    p_transfer_other_info1_str2 := l_transfer_other_info1_str2;
    p_transfer_other_info1_str3 := l_transfer_other_info1_str3;
    p_transfer_other_info2_str1 := l_transfer_other_info2_str1;
    p_transfer_other_info2_str2 := l_transfer_other_info2_str2;
    p_transfer_other_info2_str3 := l_transfer_other_info2_str3;
    p_transfer_other_info3_str1 := l_transfer_other_info3_str1;
    p_transfer_other_info3_str2 := l_transfer_other_info3_str2;
    p_transfer_other_info3_str3 := l_transfer_other_info3_str3;
    p_transfer_other_info4_str1 := l_transfer_other_info4_str1;
    p_transfer_other_info4_str2 := l_transfer_other_info4_str2;
    p_transfer_other_info4_str3 := l_transfer_other_info4_str3;
    p_transfer_oth1_rep1        := l_transfer_oth1_rep1;
    p_transfer_oth1_rep2        := l_transfer_oth1_rep2;
    p_transfer_oth1_rep3        := l_transfer_oth1_rep3;
    p_transfer_oth2_rep2        := l_transfer_oth2_rep2;
    p_transfer_oth2_rep3        := l_transfer_oth2_rep3;
    p_transfer_oth3_rep2        := l_transfer_oth3_rep2;
    p_transfer_oth3_rep3        := l_transfer_oth3_rep3;
    p_transfer_oth4_rep3        := l_transfer_oth4_rep3;

    /*
    hr_utility.trace('p_cnt                       = '|| l_cnt);
    hr_utility.trace('p_oth_rep1                  = '|| l_oth_rep1);
    hr_utility.trace('p_oth_rep2                  = '|| l_oth_rep2);
    hr_utility.trace('p_oth_rep3                  = '|| l_oth_rep3);
    hr_utility.trace('write_f30                   = '|| l_write_f30);
    hr_utility.trace('p_write_f31                 = '|| l_write_f31);
    hr_utility.trace('p_transfer_other_info1_str1 = '|| l_transfer_other_info1_str1);
    hr_utility.trace('p_transfer_other_info1_str2 = '|| l_transfer_other_info1_str2);
    hr_utility.trace('p_transfer_other_info1_str3 = '|| l_transfer_other_info1_str3);
    hr_utility.trace('p_transfer_other_info2_str1 = '|| l_transfer_other_info2_str1);
    hr_utility.trace('p_transfer_other_info2_str2 = '|| l_transfer_other_info2_str2);
    hr_utility.trace('p_transfer_other_info2_str3 = '|| l_transfer_other_info2_str3);
    hr_utility.trace('p_transfer_other_info3_str1 = '|| l_transfer_other_info3_str1);
    hr_utility.trace('p_transfer_other_info3_str2 = '|| l_transfer_other_info3_str2);
    hr_utility.trace('p_transfer_other_info3_str3 = '|| l_transfer_other_info3_str3);
    hr_utility.trace('p_transfer_other_info4_str1 = '|| l_transfer_other_info4_str1);
    hr_utility.trace('p_transfer_other_info4_str2 = '|| l_transfer_other_info4_str2);
    hr_utility.trace('p_transfer_other_info4_str3 = '|| l_transfer_other_info4_str3);
    hr_utility.trace('p_transfer_oth1_rep1        = '|| l_transfer_oth1_rep1);
    hr_utility.trace('p_transfer_oth1_rep2        = '|| l_transfer_oth1_rep2);
    hr_utility.trace('p_transfer_oth1_rep3        = '|| l_transfer_oth1_rep3);
    hr_utility.trace('p_transfer_oth2_rep2        = '|| l_transfer_oth2_rep2);
    hr_utility.trace('p_transfer_oth2_rep3        = '|| l_transfer_oth2_rep3);
    hr_utility.trace('p_transfer_oth3_rep2        = '|| l_transfer_oth3_rep2);
    hr_utility.trace('p_transfer_oth3_rep3        = '|| l_transfer_oth3_rep3);
    hr_utility.trace('p_transfer_oth4_rep3        = '|| l_transfer_oth4_rep3);

    */

return l_write_f30;

END;

FUNCTION validate_gre_data ( p_trans IN VARCHAR2,
                             p_year  IN VARCHAR2)
RETURN varchar2 IS

cursor  c_trans_payid ( c_trans_id VARCHAR2,
                        c_year  VARCHAR2) is
Select  ppa.payroll_action_id, ppa.business_group_id
from    hr_organization_information hoi,
        pay_payroll_actions PPA,
        pay_ca_legislation_info pcli,
        pay_ca_legislation_info pcli1
where   hoi.organization_id = to_number(c_trans_id)
and     hoi.org_information_context='Fed Magnetic Reporting'
and     ppa.report_type = 'T4'  -- T4 Archiver Report Type
and     hoi.organization_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='))
and     to_char(ppa.effective_date,'YYYY')= c_year
and     to_char(ppa.effective_date,'DD-MM')= '31-12'
and     pcli.information_type = 'MAX_CPP_EARNINGS'
and     ppa.effective_date between pcli.start_date and pcli.end_date
and     pcli1.information_type = 'MAX_EI_EARNINGS'
and     ppa.effective_date between pcli1.start_date and pcli1.end_date;

cursor c_all_gres(p_trans VARCHAR2,
                  p_year  VARCHAR2,
                  p_bg_id NUMBER) is
Select distinct ppa.payroll_action_id, hoi.organization_id, hou.name
From    pay_payroll_actions ppa,
        hr_organization_information hoi,
        hr_all_organization_units       hou
where   hoi.org_information_context = 'Canada Employer Identification'
and     hoi.org_information11        = p_trans
and     hou.business_group_id         = p_bg_id
and     hou.organization_id         = hoi.organization_id
and     ppa.report_type = 'T4'
and     ppa.effective_date = to_date('31-12'||p_year,'DD-MM-YYYY')
and     ppa.business_group_id  = p_bg_id
and     hoi.organization_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='));

cursor  c_gre_name (b_org_id   VARCHAR2) is
select hou.name
from   hr_all_organization_units hou
where  hou.organization_id = to_number(b_org_id);

/* Local variables  */
l_trans_gre  hr_all_organization_units.organization_id%TYPE;
l_year       VARCHAR2(10);
l_gre        hr_all_organization_units.organization_id%TYPE;
l_bus_grp    hr_all_organization_units.business_group_id%TYPE;
l_trans_no   VARCHAR2(240);
l_tech_name  VARCHAR2(240) ;
l_tech_area  VARCHAR2(240) ;
l_tech_phno  VARCHAR2(240) ;
l_lang       VARCHAR2(240) ;
l_acc_name   VARCHAR2(240) ;
l_acc_area   VARCHAR2(240) ;
l_acc_phno   VARCHAR2(240) ;
l_trans_bus_no VARCHAR2(240);
l_trans_name   VARCHAR2(240);
l_bus_no     VARCHAR2(240) ;
l_bg_id     number ;
l_trans_payid pay_payroll_actions.payroll_action_id%TYPE;
l_gre_payid   pay_payroll_actions.payroll_action_id%TYPE;
l_gre_actid   pay_assignment_actions.assignment_action_id%TYPE;
l_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE;
l_acc_info_flag       CHAR(1);
l_gre_name        VARCHAR2(240);

BEGIN

  /* Fetching the Payroll Action Id for Trasnmitter GRE   */

  --hr_utility.trace_on(null,'T4MAG');
  hr_utility.trace('Inside the Validation Code');
  hr_utility.trace('The Transmitter GRE id passed is '||p_trans);
   open c_trans_payid(p_trans,p_year);
   fetch c_trans_payid into l_trans_payid,l_bg_id;
   IF c_trans_payid%notfound THEN
          close c_trans_payid;
          hr_utility.trace('The Transmitter GRE id not found '||p_trans);
          hr_utility.raise_error;
          return '1';
   else
        close c_trans_payid;
   END IF;

  hr_utility.trace('Fetched the Payroll Id for transmitter GRE'|| l_trans_payid);
  hr_utility.trace('The Reporting Year is '||p_year);

   /*Fetching the Trasnmitter Level Data   */

      l_trans_no := get_arch_val(l_trans_payid, 'CAEOY_TRANSMITTER_NUMBER');
      l_tech_name:= get_arch_val(l_trans_payid, 'CAEOY_TECHNICAL_CONTACT_NAME');
      l_tech_area:= get_arch_val(l_trans_payid, 'CAEOY_TECHNICAL_CONTACT_AREA_CODE');
      l_tech_phno:= get_arch_val(l_trans_payid, 'CAEOY_TECHNICAL_CONTACT_PHONE');
      l_lang     := get_arch_val(l_trans_payid, 'CAEOY_TECHNICAL_CONTACT_LANGUAGE');
      l_acc_name := get_arch_val(l_trans_payid, 'CAEOY_ACCOUNTING_CONTACT_NAME');
      l_acc_area := get_arch_val(l_trans_payid, 'CAEOY_ACCOUNTING_CONTACT_AREA_CODE');
      l_acc_phno := get_arch_val(l_trans_payid, 'CAEOY_ACCOUNTING_CONTACT_PHONE');
      l_trans_bus_no := get_arch_val(l_trans_payid, 'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER');
--      l_trans_name   := get_arch_val(l_trans_payid, 'CAEOY_TRANSMITTER_NAME');
  OPEN  c_gre_name(to_number(p_trans));
  FETCH c_gre_name INTO l_trans_name;
  CLOSE c_gre_name;

  hr_utility.trace('Transmitter Number'||l_trans_no);
  hr_utility.trace('Tech Name'||l_tech_name);
  hr_utility.trace('Tech Phno'||l_tech_phno);
  hr_utility.trace('Tech area'||l_tech_area);
  hr_utility.trace('Tech Lang'||l_lang);

  /* Checking for the validity of the above values fetched */
  hr_utility.trace('Checking the Transmitter No ');
  IF  l_trans_no IS NULL
   OR TRANSLATE(l_trans_no,'M0123456789','M9999999999') <> 'MM999999' THEN
          hr_utility.trace('Incorrect Transmitter No format');
          hr_utility.set_message(801,'PAY_74155_INCORRECT_TRANSMT_NO');
          hr_utility.set_message_token('GRE_NAME',l_trans_name);
          pay_core_utils.push_message(801,'PAY_74155_INCORRECT_TRANSMT_NO','P');
          pay_core_utils.push_token('GRE_NAME',l_trans_name);
          hr_utility.raise_error;
          return '1';
  END IF;

     if l_tech_name is  null or
        l_tech_area is  null or
        l_tech_phno is  null or
        l_lang      is  null then
                hr_utility.trace('Technical contact details missing');
                hr_utility.set_message(801,'PAY_74158_INCORRECT_TCHN_INFO');
                hr_utility.set_message_token('GRE_NAME',l_trans_name);
                pay_core_utils.push_message(801,'PAY_74158_INCORRECT_TCHN_INFO','P');
                pay_core_utils.push_token('GRE_NAME',l_trans_name);
                hr_utility.raise_error;
                return '1';
     end if;

     if l_acc_name is null or
        l_acc_phno is null or
        l_acc_area is null then
                l_acc_info_flag := 'N';
     else
                l_acc_info_flag := 'Y';
     end if;
     hr_utility.trace('The value of the Flag is '||l_acc_info_flag);
     hr_utility.trace('The value of the bgid '||to_char(l_bg_id));


  /* Checking for the GRE level information */

  open c_all_gres(p_trans,p_year,l_bg_id);
  loop
  fetch c_all_gres into l_gre_payid, l_gre, l_gre_name;
     hr_utility.trace('The Gre id fetched is '||l_gre);
     if c_all_gres%notfound then
        close c_all_gres;
        exit;
     end if;

     hr_utility.trace('Before fetching the GREs for this Transmitter '||l_gre||'-'||p_year);

     if l_gre <> to_number(p_trans) then
            hr_utility.trace('Inside the loop'||l_gre_payid);
            hr_utility.trace('Checking GRE level data');
            hr_utility.trace('The Payroll Action Id for Gre is '|| l_gre_payid);
            l_bus_no := get_arch_val(l_gre_payid,'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER');
            --l_tax_unit_id  := get_arch_val(l_gre_payid, 'CAEOY_TAX_UNIT_ID');
            l_acc_name := get_arch_val(l_gre_payid, 'CAEOY_ACCOUNTING_CONTACT_NAME');
            l_acc_area := get_arch_val(l_gre_payid, 'CAEOY_ACCOUNTING_CONTACT_AREA_CODE');
            l_acc_phno := get_arch_val(l_gre_payid, 'CAEOY_ACCOUNTING_CONTACT_PHONE');

            hr_utility.trace('Tax unit Id'||l_tax_unit_id);
            hr_utility.trace('Acc Name '||l_acc_name);
            hr_utility.trace('Acc Area '||l_acc_area);
            hr_utility.trace('Acc Phone '||l_acc_phno);

           if l_bus_no is null
           or TRANSLATE(l_bus_no,'0123456789RP','9999999999RP') <> '999999999RP9999' then
               hr_utility.trace('No Business Number Entereed ');
               hr_utility.set_message(801,'PAY_74154_INCORRECT_BN');
               hr_utility.set_message_token('GRE_NAME',l_gre_name);
               pay_core_utils.push_message(801,'PAY_74154_INCORRECT_BN','P');
               pay_core_utils.push_token('GRE_NAME',l_gre_name);
               hr_utility.raise_error;
               return '1';
            end if;

            if (l_acc_name is null or
               l_acc_area is null or
               l_acc_phno is null ) and
               l_acc_info_flag = 'N' then
                       hr_utility.trace('No Accounting Contact info present');
                       hr_utility.set_message(801,'PAY_74157_INCORRECT_ACNT_INFO');
                       hr_utility.set_message_token('GRE_NAME',l_gre_name);
                       pay_core_utils.push_message(801,'PAY_74157_INCORRECT_ACNT_INFO','P');
                       pay_core_utils.push_token('GRE_NAME',l_gre_name);
                       hr_utility.raise_error;
                       return '1';
            end if;

        elsif l_gre = to_number(p_trans) then

            if l_trans_bus_no is null
            or TRANSLATE(l_trans_bus_no,'0123456789RP','9999999999RP') <> '999999999RP9999' then
               hr_utility.trace('No Business Number Entereed ');
               hr_utility.set_message(801,'PAY_74154_INCORRECT_BN');
               hr_utility.set_message_token('GRE_NAME',l_trans_name);
               pay_core_utils.push_message(801,'PAY_74154_INCORRECT_BN','P');
               pay_core_utils.push_token('GRE_NAME',l_trans_name);
               hr_utility.raise_error;
               return '1';
            end if;
            if l_acc_info_flag = 'N' then
               hr_utility.trace('No Accounting Contact info present');
               hr_utility.set_message(801,'PAY_74157_INCORRECT_ACNT_INFO');
               hr_utility.set_message_token('GRE_NAME',l_trans_name);
               pay_core_utils.push_message(801,'PAY_74157_INCORRECT_ACNT_INFO','P');
               pay_core_utils.push_token('GRE_NAME',l_trans_name);
               hr_utility.raise_error;
               return '1';
            end if;
        end if;
  end loop;
  RETURN '0';
END validate_gre_data;
END pay_ca_t4_mag;

/
