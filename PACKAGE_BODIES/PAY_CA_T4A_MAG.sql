--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4A_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4A_MAG" AS
/* $Header: pycat4am.pkb 120.1 2005/06/15 10:21:27 ssouresr noship $ */

 -----------------------------------------------------------------------------
   -- Name     : get_report_parameters
   --
   -- Purpose
   --   The procedure gets the 'parameter' for which the report is being
   --   run i.e., the period, state and business organization.
   --
   -- Arguments
   --   p_pactid                Payroll_action_id passed from pyugen process
   --   p_year_start            Start Date of the period for which the report
   --                           has been requested
   --   p_year_end              End date of the period
   --   p_business_group_id     Business group for which the report is being run
   --   p_report_type           Type of report being run T4
   --
   -- Notes
 ----------------------------------------------------------------------------


PROCEDURE get_report_parameters
        (       p_pactid                IN      NUMBER,
                p_year_start            IN OUT NOCOPY DATE,
                p_year_end              IN OUT NOCOPY DATE,
                p_report_type           IN OUT NOCOPY VARCHAR2,
                p_business_group_id     IN OUT NOCOPY NUMBER,
                p_legislative_parameters OUT NOCOPY VARCHAR2
        ) IS
        BEGIN
                hr_utility.set_location
                ('pay_ca_t4a_mag.get_report_parameters', 10);

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
                ('pay_ca_t4a_mag.get_report_parameters', 20);

        END get_report_parameters;

/* Added to fix performance bug */

Function get_user_entity_id(p_user_name varchar2) return number is

  cursor cur_user_entity_id is
  select user_entity_id
  from   ff_database_items
  where  user_name = p_user_name;

  l_user_entity_id      ff_database_items.user_entity_id%TYPE;

begin

  open  cur_user_entity_id;

  fetch cur_user_entity_id
  into  l_user_entity_id;

  close cur_user_entity_id;
  return l_user_entity_id;

end;

----------------------------------------------------------------------------
  --Name
  --  range_cursor
  --Purpose
  --  This procedure defines a SQL statement
  --  to fetch all the people to be included in the report. This SQL statement
  --  is  used to define the 'chunks' for multi-threaded operation
  --Arguments
  --  p_pactid                  payroll action id for the report
  --  p_sqlstr                  the SQL statement to fetch the people
------------------------------------------------------------------------------
PROCEDURE range_cursor (
        p_pactid        IN      NUMBER,
        p_sqlstr OUT NOCOPY VARCHAR2
)
IS
        p_year_start                    DATE;
        p_year_end                      DATE;
        p_business_group_id             NUMBER;
        p_report_type                   VARCHAR2(30);

        /* added to fix performance bug */
        l_tax_year_ue_id                 NUMBER;
        l_person_id_ue_id                NUMBER;
        l_legislative_parameters         VARCHAR2(200);
        l_tax_year                       VARCHAR2(10);

BEGIN

        hr_utility.set_location( 'pay_ca_t4a_mag.range_cursor', 10);

        get_report_parameters(
                p_pactid,
                p_year_start,
                p_year_end,
                p_report_type,
                p_business_group_id,
                l_legislative_parameters
        );

      l_tax_year_ue_id := get_user_entity_id('CAEOY_TAXATION_YEAR');
      l_person_id_ue_id := get_user_entity_id('CAEOY_PERSON_ID');
      l_tax_year        := pay_ca_t4a_mag.get_parameter('REPORTING_YEAR',
                                                l_legislative_parameters);

        hr_utility.trace('l_tax_year ='||l_tax_year);
        hr_utility.set_location( 'pay_ca_t4a_mag.range_cursor', 20);

       /*  Removed the join from 'Where clause' that checks
           whether GRE has the 'Fed Magnetic Reporting' information or not */

        /* Changed to fix performance bug */
       p_sqlstr := 'select distinct to_number(fai1.value)
                from    ff_archive_items fai1,
                        ff_archive_items fai2,
                        pay_assignment_actions  paa,
                        pay_payroll_actions     ppa,
                        pay_payroll_actions     ppa1
                 where  ppa1.payroll_action_id    = :p_pactid
                 and    ppa.report_type = ''T4A''
                 and ppa.report_qualifier = ''CAEOY''
                 and ppa.report_category = ''CAEOY''
                 and ppa.action_type = ''X''
                 and ppa.action_status = ''C''
                 and ppa.business_group_id = ppa1.business_group_id
                 and ppa.effective_date = ppa1.effective_date
                 and paa.payroll_action_id = ppa.payroll_action_id
                 and paa.action_status = ''C''
                 and fai2.user_entity_id =  '|| l_tax_year_ue_id ||
                 ' and fai2.context1 = paa.payroll_action_id
                 and  fai2.value = '|| l_tax_year ||
                 ' and  fai1.context1 = paa.assignment_action_id
                 and  fai1.user_entity_id =  '||l_person_id_ue_id||
                 ' order by to_number(fai1.value)';

                hr_utility.set_location( 'pay_ca_t4a_mag.range_cursor', 30);

END range_cursor;

--
  -----------------------------------------------------------------------------
  --Name
  --  create_assignment_act
  --Purpose
  --  Creates assignment actions for the payroll action associated with the
  --  report
  --Arguments
  --  p_pactid                          payroll action for the report
  --  p_stperson                        starting person id for the chunk
  --  p_endperson                       last person id for the chunk
  --  p_chunk                           size of the chunk
  --Note
  --  The procedure processes assignments in 'chunks' to facilitate
  --  multi-threaded operation. The chunk is defined by the size and the
  --  starting and ending person id. An interlock is also created against the
  --  pre-processor assignment action to prevent rolling back of the archiver.
  ----------------------------------------------------------------------------
--
PROCEDURE create_assignment_act(
        p_pactid        IN NUMBER,
        p_stperson      IN NUMBER,
        p_endperson IN NUMBER,
        p_chunk         IN NUMBER )
IS

      /* Added variables to fix performance bug */
        l_legislative_parameters VARCHAR2(200);
        l_trans_gre              VARCHAR2(10);
        l_validate_gre              VARCHAR2(10);

 -- Cursor to retrieve all the assignments for all GRE's
        -- archived in a reporting year
       /*  Removed the join from 'Where clause' that checks
           whether GRE has the 'Fed Magnetic Reporting' information or not */

        /* Changed to fix performance bug */
        CURSOR c_all_asg IS
            SELECT paf.person_id,
                 paf.assignment_id,
                 Paa.tax_unit_id,
                 paf.effective_end_date,
                 paa.assignment_action_id
            FROM pay_payroll_actions ppa,
                 pay_assignment_actions paa,
                 per_all_assignments_f paf,
                 pay_payroll_actions ppa1,
                 hr_organization_information hoi1
        WHERE ppa1.payroll_action_id = p_pactid
        AND ppa.report_type = 'T4A'
        and ppa.report_qualifier = 'CAEOY'
        and ppa.report_category = 'CAEOY'
        and ppa.action_type = 'X'
        and ppa.action_status = 'C'
        AND ppa.business_group_id = ppa1.business_group_id
        AND ppa.effective_date = ppa1.effective_date
        AND paa.payroll_action_id = ppa.payroll_action_id
        AND paa.action_status = 'C'
        and hoi1.org_information_context= 'Canada Employer Identification'
        and hoi1.org_information11 = l_trans_gre
        and paa.tax_unit_id = hoi1.organization_id
        AND paf.assignment_id = paa.assignment_id
        AND paf.person_id BETWEEN p_stperson and p_endperson
        AND paf.effective_start_date <= ppa.effective_date
        AND paf.effective_end_date >= ppa.start_date
        AND paf.effective_end_date = (SELECT MAX(paf2.effective_end_date)
                                  FROM per_all_assignments_f paf2
                                  WHERE paf2.assignment_id = paf.assignment_id
                           AND paf2.effective_start_date <= ppa.effective_date);


        --local variables

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

BEGIN

        -- Get the report parameters. These define the report being run.

        hr_utility.set_location( 'pay_ca_t4a_mag.create_assignement_act',10);

        get_report_parameters(
                p_pactid,
                l_year_start,
                l_year_end,
                l_report_type,
                l_business_group_id,
                l_legislative_parameters
                );
--hr_utility.trace_on(null,'T4MAG');
        l_trans_gre := pay_ca_t4a_mag.get_parameter('TRANSMITTER_GRE',
                                             l_legislative_parameters);
        hr_utility.trace('l_trans_gre ='||l_trans_gre);
       l_validate_gre := pay_ca_t4a_mag.validate_gre_data(l_trans_gre, to_char(l_year_end,'YYYY'));

        hr_utility.set_location( 'pay_ca_t4a_mag.create_assignement_act',20);

         if l_validate_gre = '1' then
           hr_utility.raise_error;
         end if;

        IF l_report_type = 'MAG_T4A' THEN
                OPEN c_all_asg;
                LOOP
                        FETCH c_all_asg INTO l_person_id,
                                             l_assignment_id,
                                             l_tax_unit_id,
                                             l_effective_end_date,
                                             l_assignment_action_id;
                        hr_utility.set_location('pay_ca_t4a_mag.create_assignement_act', 30);
                        EXIT WHEN c_all_asg%NOTFOUND;


                --Create the assignment action for the record

                  hr_utility.trace('Assignment Fetched  - ');
                  hr_utility.trace('Assignment Id : '||
                                    to_char(l_assignment_id));
                  hr_utility.trace('Person Id :  '|| to_char(l_person_id));
                  hr_utility.trace('tax unit id : '|| to_char(l_tax_unit_id));
                  hr_utility.trace('Effective End Date :  '||
                                     to_char(l_effective_end_date));

                  hr_utility.set_location(
                                'pay_ca_t4a_mag.create_assignement_act', 40);

                        SELECT pay_assignment_actions_s.nextval
                        INTO lockingactid
                        FROM dual;
                        hr_utility.set_location(
                                'pay_ca_t4a_mag.create_assignement_act', 50);

                        hr_nonrun_asact.insact(lockingactid, l_assignment_id,
                                             p_pactid,p_chunk, l_tax_unit_id);

                        hr_utility.set_location(
                                'pay_ca_t4a_mag.create_assignement_act', 60);

                        hr_nonrun_asact.insint(lockingactid,
                                               l_assignment_action_id);

                        hr_utility.set_location(
                                'pay_ca_t4a_mag.create_assignement_act', 70);

                        hr_utility.trace('Interlock Created  - ');
                        hr_utility.trace('Locking Action : '||
                                           to_char(lockingactid));
                        hr_utility.trace('Locked Action :  '||
                                           to_char(l_assignment_action_id));

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
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;

FUNCTION get_t4a_pp_regno
(
        p_pactid                IN  NUMBER,
        p_tax_unit_id           IN  NUMBER,
        p_pp_regno1             OUT NOCOPY VARCHAR2,
        p_pp_regno2             OUT NOCOPY VARCHAR2,
        p_pp_regno3             OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
cursor c_get_reg_no(cp_pact_id number,
                    cp_tax_unit_id number) is
select to_number(pai.action_information5) ppreg_amt,
       pai.action_information4 ppreg_no
from pay_action_information pai,pay_payroll_actions ppa
where pai.action_context_id = cp_pact_id
and   pai.tax_unit_id = cp_tax_unit_id
and ppa.payroll_action_id = pai.action_context_id
and pai.effective_date = ppa.effective_date
and pai.action_information_category = 'CAEOY PENSION PLAN INFO'
order by 1 desc;

lv_pp_regno1 varchar2(30) := 'X';
ln_pp_regamt1 number(30);
lv_pp_regno2 varchar2(30) := 'X';
ln_pp_regamt2 number(30);
lv_pp_regno3 varchar2(30) := 'X';
ln_pp_regamt3 number(30);
lv_pp_regno varchar2(30);
ln_pp_regamt number(30);

begin

    open c_get_reg_no(p_pactid,p_tax_unit_id);
    loop
      fetch c_get_reg_no into ln_pp_regamt,lv_pp_regno;
      exit when c_get_reg_no%NOTFOUND;

      if c_get_reg_no%rowcount = 1 then
         lv_pp_regno1 := lv_pp_regno;
         ln_pp_regamt1 := ln_pp_regamt;
      elsif c_get_reg_no%rowcount = 2 then
         lv_pp_regno2 := lv_pp_regno;
         ln_pp_regamt2 := ln_pp_regamt;
      elsif c_get_reg_no%rowcount = 3 then
         lv_pp_regno3 := lv_pp_regno;
         ln_pp_regamt3 := ln_pp_regamt;
      end if;

      if c_get_reg_no%rowcount > 3 then
         exit;
      end if;

    end loop;
    close c_get_reg_no;

      p_pp_regno1 := lv_pp_regno1;
      p_pp_regno2 := lv_pp_regno2;
      p_pp_regno3 := lv_pp_regno3;

return '1';

end get_t4a_pp_regno;

FUNCTION get_t4a_footnote_amounts ( p_assignment_action_id in number,p_footnote_code   IN  VARCHAR2) RETURN varchar2 IS
cursor c_get_footnote_amount( cp_assignment_action_id number,cp_footnote_code varchar2) is
select pai.action_information5
from pay_action_information pai
where pai.action_context_id = cp_assignment_action_id
and pai.action_information_category = 'CA FOOTNOTES'
and pai.action_information4 = cp_footnote_code
order by 1 desc;

lv_footnote_amount varchar2(80);

begin

lv_footnote_amount := '0';
    open c_get_footnote_amount(p_assignment_action_id,p_footnote_code);
      fetch c_get_footnote_amount into lv_footnote_amount;

        hr_utility.trace('fetch footnote '|| lv_footnote_amount);

    close c_get_footnote_amount;

return lv_footnote_amount;
     exception
            when no_data_found then
        hr_utility.trace('fetch no footnote ');
            lv_footnote_amount := '0';
            return lv_footnote_amount;
end get_t4a_footnote_amounts;

function validate_gre_data ( p_trans IN VARCHAR2,
                             p_year  IN VARCHAR2) return varchar2 IS

cursor  c_trans_payid ( c_trans_id VARCHAR2,
                        c_year  VARCHAR2) is
Select  ppa.payroll_action_id,ppa.business_group_id
from    hr_organization_information hoi,
        pay_payroll_actions PPA
where   hoi.organization_id = to_number(c_trans_id)
and     hoi.org_information_context='Fed Magnetic Reporting'
and     ppa.report_type = 'T4A'  -- T4 Archiver Report Type
and     hoi.organization_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='))
and     to_char(ppa.effective_date,'YYYY')= c_year
and     to_char(ppa.effective_date,'DD-MM')= '31-12';

cursor c_all_gres(p_trans VARCHAR2,
                  p_year  VARCHAR2,
                  p_bg_id NUMBER) is
Select distinct ppa.payroll_action_id, hoi.organization_id, hou.name
From    pay_payroll_actions ppa,
        hr_organization_information hoi,
        hr_all_organization_units   hou
where   hoi.org_information_context = 'Canada Employer Identification'
and     hoi.org_information11 = p_trans
and     hou.business_group_id = p_bg_id
and     hou.organization_id = hoi.organization_id
and     ppa.report_type = 'T4A'
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
l_bus_no     VARCHAR2(240) ;
l_trans_payid pay_payroll_actions.payroll_action_id%TYPE;
l_gre_payid   pay_payroll_actions.payroll_action_id%TYPE;
l_gre_actid   pay_assignment_actions.assignment_action_id%TYPE;
l_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE;
l_acc_info_flag       CHAR(1);
l_trans_name   VARCHAR2(240);
l_gre_name        VARCHAR2(240);
l_bg_id        NUMBER;

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

  OPEN  c_gre_name(to_number(p_trans));
  FETCH c_gre_name INTO l_trans_name;
  CLOSE c_gre_name;

hr_utility.trace('Transmitter Number'||l_trans_no);
hr_utility.trace('Tech Name'||l_tech_name);
hr_utility.trace('Tech Phno'||l_tech_phno);
hr_utility.trace('Tech area'||l_tech_area);
hr_utility.trace('Tech Lang'||l_lang);

/* Checking for the validity of the above values fetched */
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

/* If Transmitter Level Accounting Information is Missing checking for the GRE level information */

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
            hr_utility.trace('gre namee '||l_gre_name);


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
      return '0';
END validate_gre_data;

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
END pay_ca_t4a_mag;

/
