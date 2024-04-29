--------------------------------------------------------
--  DDL for Package Body PAY_GB_PAYE_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_PAYE_SYNC" 
--  /* $Header: pygbpayesync.pkb 120.0.12010000.3 2009/07/03 06:22:09 jvaradra noship $ */
as

/* write_util_file will fetct the affected records and report it in the output file */

PROCEDURE write_util_file(errbuf               OUT    NOCOPY VARCHAR2,
                          retcode              OUT    NOCOPY NUMBER,
                          p_tax_ref            IN VARCHAR2,
                          p_business_group_id  IN NUMBER,
                          p_eff_date           IN VARCHAR2
                          )
IS

   l_count            number;

   l_person_id        per_all_people_f.person_id%type := -1;
   l_tax_code_id      pay_input_values_f.input_value_id%type;
   l_ele_type_id      pay_element_types_f.element_type_id%type;
   l_tax_basis_id     pay_input_values_f.input_value_id%type;

   l_sft_coding_id    hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
   l_last_person_id   per_all_people_f.person_id%type := -1;

   l_last_cpe_st_date date;

   l_curr_cpe_start_date date;

   /* BEGIN For witing the warning messages in log file */

   TYPE paye_future_record IS RECORD(l_name            VARCHAR2(60),
                                     assignment_num    VARCHAR2(60),
                                     effective_date    DATE);

   Type paye_future_table Is Table Of paye_future_record Index By Binary_Integer;

   paye_future_file paye_future_table;

  /* END For witing the warning messages in log file */


   l_tax_ref           varchar2(60);
   l_effective_date    date;
   l_business_group_id number;
   l_cpe_start_date    date;

   -- Fetch the Soft coding id for Tax reference
   CURSOR c_soft_coding_id
       IS
   SELECT soft_coding_keyflex_id
     FROM hr_soft_coding_keyflex
    WHERE segment1 = l_tax_ref;

    --  Fetch the PAYE Details element details
   CURSOR c_ele_typ_id(c_eff_date date)
       IS
   SELECT petf.element_type_id
     FROM pay_element_types_f petf
    WHERE petf.element_name = 'PAYE Details'
      AND petf.legislation_code = 'GB'
      AND c_eff_date between petf.effective_start_date and petf.effective_end_date;


 /*   -- Fetch the Tax code input value id
   CURSOR c_tax_code_id(c_ele_type_id number)
       IS
   SELECT input_value_id
     FROM pay_input_values_f
    WHERE element_type_id = c_ele_type_id
      AND legislation_code = 'GB'
      AND name = 'Tax Code';


    -- Fetch the Tax Basis input value id
   CURSOR c_tax_basis_id(c_ele_type_id number)
       IS
   SELECT input_value_id
     FROM pay_input_values_f
    WHERE element_type_id = c_ele_type_id
      AND legislation_code = 'GB'
      AND name = 'Tax Basis';  */

   -- Fetch the Person for whom PAYE aggregation is enabled
   CURSOR c_get_agg_person(c_bg_id          number,
                           c_effective_date date
                          )
       IS
    SELECT DISTINCT papf.person_id
     FROM per_all_people_f papf
          ,per_periods_of_service ppos
    WHERE ppos.person_id = papf.person_id
      AND (papf.current_employee_flag = 'Y'
           OR
           ppos.final_process_date >= c_effective_date
           )
      AND papf.per_information10 = 'Y'
      AND papf.business_group_id = c_bg_id
      AND c_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
    ORDER BY papf.person_id desc;

   -- Fetch the
   CURSOR c_get_details(c_person_id  number,
             c_ele_type_id number,
             c_effective_date date,
             c_taxref varchar2,
             c_sft_coding_id  number,
             c_cpe_start_date date)
       IS
   SELECT papf.last_name lname,
          paaf.person_id pid,
          paaf.assignment_id aid,
          paaf.assignment_number anum,
          pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, c_taxref, c_effective_date) cpe_start,
         -- pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, c_taxref, c_effective_date) cpe_end,
          peef.effective_start_date effst,
          peef.effective_end_date effend,
          peef.object_version_number ovn,
          min(decode(pivf.name, 'Tax Code', peevf.screen_entry_value, null)) Tax_Code,
          --  min(decode(pivf.name, 'Tax Basis', substr(HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',peevf.screen_entry_value),1,80),null)) Tax_Basis,
          min(decode(pivf.name, 'Tax Basis',peevf.screen_entry_value,null)) Tax_Basis,
          min(decode(pivf.name, 'Refundable', substr(HR_GENERAL.DECODE_LOOKUP('GB_REFUNDABLE',peevf.screen_entry_value),1,80),null)) Refundable,
          hr_chkfmt.changeformat(nvl(min(decode(pivf.name, 'Pay Previous', peevf.screen_entry_value, null)), 0), 'M', 'GBP') Pay_Previous,
          hr_chkfmt.changeformat(nvl(min(decode(pivf.name, 'Tax Previous', peevf.screen_entry_value, null)), 0), 'M', 'GBP') Tax_Previous,
          min(decode(pivf.name, 'Authority', substr(HR_GENERAL.DECODE_LOOKUP('GB_AUTHORITY',peevf.screen_entry_value),1,80),null)) Authority
     from per_all_people_f papf,
          per_all_assignments_f paaf,
          pay_element_entries_f peef,
          pay_element_entry_values_f peevf,
          pay_input_values_f pivf,
         -- per_assignment_status_types past,
          pay_all_payrolls_f pap,
          hr_soft_coding_keyflex hsck
    where papf.person_id = c_person_id
      and papf.person_id = paaf.person_id
      and c_effective_date between papf.effective_start_date and papf.effective_end_date
      and paaf.assignment_id = peef.assignment_id
      and c_effective_date between paaf.effective_start_date and paaf.effective_end_date
      and peef.element_type_id = c_ele_type_id
      and peef.element_entry_id = peevf.element_entry_id
      and c_effective_date between peef.effective_start_date and peef.effective_end_date
      and peevf.input_value_id  = pivf.input_value_id
      and c_effective_date between peevf.effective_start_date and peevf.effective_end_date
      and c_effective_date between pivf.effective_start_date and pivf.effective_end_date
     -- AND paaf.assignment_status_type_id = past.assignment_status_type_id
     -- AND past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
      AND paaf.payroll_id = pap.payroll_id
      AND c_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date
      --AND pap.soft_coding_keyflex_id= c_sft_coding_id
      AND pap.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
      AND hsck.segment1 = c_taxref
      /*AND c_effective_date between pay_gb_eoy_archive.get_agg_active_start (paaf.assignment_id, c_taxref,c_effective_date)
                                        AND pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, c_taxref,c_effective_date)  */
      AND pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, c_taxref,c_effective_date) = c_cpe_start_date
      AND pay_p45_pkg.PAYE_SYNC_P45_ISSUED_FLAG(paaf.assignment_id,l_effective_date) = 'N'
      group by  papf.last_name,
                paaf.person_id,
                paaf.assignment_number,
                paaf.assignment_id,
                peef.effective_start_date,
                peef.effective_end_date,
                peef.object_version_number,
                pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, c_taxref, c_effective_date)
               -- pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, c_taxref, c_effective_date)
      order by  peef.effective_start_date desc,paaf.assignment_id desc;


out_name varchar2(1000);
in_name varchar2(1000);

j_count number := 0;


    j_tax_code             pay_element_entry_values_f.screen_entry_value%type;
    j_tax_basis            pay_element_entry_values_f.screen_entry_value%type;
    j_refundable           pay_element_entry_values_f.screen_entry_value%type;
    j_tax_previous         pay_element_entry_values_f.screen_entry_value%type;
    j_pay_previous         pay_element_entry_values_f.screen_entry_value%type;
    j_authority            pay_element_entry_values_f.screen_entry_value%type;


paye_sync_eff_date       EXCEPTION; -- raised when effective date is not between Tax start yeat and sysdate


/* Cursor to identify if the person has different PAYE details across the aggregated assignments in same CPE */
 cursor c_get_count(c_person_id number)
     is
 SELECT count(1) cnt,cpe_date
   FROM (SELECT distinct
                ppev.TAX_CODE,
                ppev.Tax_Basis,
                ppev.Pay_Previous,
                ppev.Tax_Previous,
                ppev.Refundable,
                ppev.Authority,
                ppev.cpe_date
           FROM (SELECT ele.rowid ROW_ID,
                        min(decode(inv.name, 'Tax Code', eev.screen_entry_value, null)) Tax_Code,
                        min(decode(inv.name, 'Tax Basis', eev.screen_entry_value, null)) Tax_Basis,
                        min(decode(inv.name, 'Refundable', eev.screen_entry_value, null)) Refundable,
                        min(decode(inv.name, 'Pay Previous', nvl(eev.screen_entry_value,0), null)) Pay_Previous,
                        min(decode(inv.name, 'Tax Previous', nvl(eev.screen_entry_value,0), null)) Tax_Previous,
                        min(decode(inv.name, 'Authority', eev.screen_entry_value, null)) Authority,
                        pay_gb_eoy_archive.get_agg_active_start (paaf.assignment_id, l_tax_ref,l_effective_date) cpe_date
                   FROM pay_element_entries_f ele,
                        pay_element_entry_values_f eev,
                        pay_input_values_f inv,
                        pay_element_links_f lnk,
                        pay_element_types_f elt,
                        pay_all_payrolls_f papf,
                        per_all_assignments_f paaf,
                        hr_soft_coding_keyflex hsck
                  WHERE ele.element_entry_id = eev.element_entry_id
                    AND l_effective_date between ele.effective_start_date and ele.effective_end_date
                    AND eev.input_value_id + 0 = inv.input_value_id
                    AND l_effective_date between eev.effective_start_date and eev.effective_end_date
                    AND inv.element_type_id = elt.element_type_id
                    AND l_effective_date between inv.effective_start_date and inv.effective_end_date
                    AND ele.element_link_id = lnk.element_link_id
                    AND l_effective_date between lnk.effective_start_date and lnk.effective_end_date
                    AND elt.element_type_id = l_ele_type_id
                    AND l_effective_date between elt.effective_start_date and elt.effective_end_date
                    AND ele.assignment_id=paaf.assignment_id
                    AND l_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                    AND paaf.payroll_id = papf.payroll_id
                    AND l_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
                    AND papf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
                    AND hsck.segment1 = l_tax_ref
                    AND paaf.person_id = c_person_id
                    AND pay_p45_pkg.PAYE_SYNC_P45_ISSUED_FLAG(paaf.assignment_id,l_effective_date) = 'N'
                    AND pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, l_tax_ref,l_effective_date) <> l_cpe_start_date
               GROUP BY pay_gb_eoy_archive.get_agg_active_start (paaf.assignment_id, l_tax_ref,l_effective_date),
                        ele.rowid) ppev )
          GROUP BY cpe_date;

/*--------------------------------------------------------------*/
/* Procedure to check if there are any future date tracked rows */
/*   for PAYE Details element                                   */
/*--------------------------------------------------------------*/

PROCEDURE check_future_changes (p_person_id  in number,
                                p_effective_date in date,
                                p_ele_type_id in number,
                                p_tax_ref in varchar2)
      IS

   Cursor c_get_assignment(c_person_id number,
                           c_tax_ref   varchar,
                           c_effective_date date)
        is
    Select paaf.assignment_id,
           paaf.assignment_number,
           pap.last_name
      from per_all_people_f pap,
           per_all_assignments_f paaf,
           pay_all_payrolls_f papf,
           hr_soft_coding_keyflex hsck
     where paaf.person_id = pap.person_id
       and paaf.person_id = c_person_id
       and c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
       and c_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date
       and paaf.payroll_id = papf.payroll_id
       and papf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
       and hsck.segment1 = c_tax_ref
       and c_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;


    Cursor c_get_future_date(c_ass_id number,c_ele_type_id number,c_eff_date date)
         is
    select min(ele.effective_start_date)
       from pay_element_entries_f ele
      where ele.effective_start_date >= c_eff_date
        and ele.assignment_id = c_ass_id
        and ele.element_type_id = c_ele_type_id;

  l_assignment_num   varchar2(60);
  l_last_name        varchar2(60);
  l_future_date      date := null;

BEGIN

    For i in c_get_assignment(p_person_id,p_tax_ref,p_effective_date)
    LOOP

      l_assignment_num := i.assignment_number;
      l_last_name := i.last_name;

      OPEN c_get_future_date (i.assignment_id,p_ele_type_id,p_effective_date);
      FETCH c_get_future_date into l_future_date;
      CLOSE c_get_future_date;

      IF l_future_date is not null
      THEN

         paye_future_file(g_number).l_name := l_last_name;
         paye_future_file(g_number).assignment_num := l_assignment_num;
         paye_future_file(g_number).effective_date := l_future_date;

         g_number := g_number + 1;

      END IF;

    END LOOP;

EXCEPTION
   when others then
        raise;
END check_future_changes;

BEGIN

  -- hr_utility.trace_on(null,'paye');

   -- Store the BG id, Tax Ref and Effective date in local variable
   l_tax_ref           := p_tax_ref;
   l_effective_date    := fnd_date.canonical_to_date(p_eff_date);
   l_business_group_id := p_business_group_id;

   l_effective_date    := to_char(l_effective_date,'DD-MON-YYYY');

   l_cpe_start_date    := fnd_date.canonical_to_date('0001/01/01 00:00:00');


    /* Check whether Effective date is between 06-Apr-2009 and sysdate (Current Date)  */

    IF  l_effective_date BETWEEN to_date('06/04/2009','dd/mm/yyyy') AND sysdate
    THEN
        hr_utility.set_location('Effective Date is between tax start year and Current date',6);
    ELSE
        hr_utility.set_location('The Effective Date must be between 06-Apr-2009 and Current Date.',8);
        RAISE paye_sync_eff_date;
    END IF;


   hr_utility.set_location('step1 l_effective_date '|| to_char(l_effective_date,'DD-MON-YYYY') ,10);


   fnd_file.put(FND_FILE.OUTPUT,'---------------- Download Parameters --------------------');
   fnd_file.NEW_LINE(FND_FILE.OUTPUT);
   fnd_file.put(FND_FILE.OUTPUT,'* Run Date             : '|| to_char(sysdate,'DD-MON-YYYY'));
   fnd_file.NEW_LINE(FND_FILE.OUTPUT);
   fnd_file.put(FND_FILE.OUTPUT,'* Effective Date       : '|| to_char(l_effective_date,'DD-MON-YYYY'));
   fnd_file.NEW_LINE(FND_FILE.OUTPUT);
   fnd_file.put(FND_FILE.OUTPUT,'* Tax Reference        : '|| l_tax_ref);
   fnd_file.NEW_LINE(FND_FILE.OUTPUT);
   fnd_file.put(FND_FILE.OUTPUT,'* Download Request Id  : '|| FND_GLOBAL.CONC_REQUEST_ID);
   fnd_file.NEW_LINE(FND_FILE.OUTPUT);
   fnd_file.NEW_LINE(FND_FILE.OUTPUT);

   hr_utility.set_location('step2',20);

   -------------------------------------------------
   /* Get the Soft coding id for the tax reference */
   -------------------------------------------------

   OPEN c_soft_coding_id;
   FETCH c_soft_coding_id  into l_sft_coding_id;
   CLOSE c_soft_coding_id;

   ----------------------------------------------
   /* Get the Element Type Id for PAYE Details */
   ----------------------------------------------

   OPEN c_ele_typ_id(l_effective_date);
   FETCH c_ele_typ_id into l_ele_type_id;
   CLOSE c_ele_typ_id;

   ----------------------------------------------
   /* Get the Input Value Id for Tax Code */
   ----------------------------------------------

/*   OPEN c_tax_code_id(l_ele_type_id);
   FETCH c_tax_code_id into l_tax_code_id;
   CLOSE c_tax_code_id; */

   ----------------------------------------------
   /* Get the Input Value Id for Tax Basis */
   ----------------------------------------------

/*   OPEN c_tax_basis_id(l_ele_type_id);
   FETCH c_tax_basis_id into l_tax_basis_id;
   CLOSE c_tax_basis_id;  */


   ------------------------------------------------------------
   /* Collect All Aggregated assignments for the given Tax Ref*/
   ------------------------------------------------------------

   hr_utility.set_location('Step3 l_sft_coding_id :' || l_sft_coding_id ,15);

   FOR i in c_get_agg_person(L_BUSINESS_GROUP_ID,
                             l_effective_date
                            )
   LOOP

      hr_utility.set_location('Step4 l_ele_type_id :' || l_ele_type_id ,20);

      l_person_id := i.person_id;

      /* BEGIN  -- call the below procedure to check if any future dated changes exists */

      check_future_changes(l_person_id,l_effective_date,l_ele_type_id,l_tax_ref);

      /* END  -- call the below procedure to check if any future dated changes exists */

      hr_utility.set_location('Step5',25);

      FOR i IN c_get_count(l_person_id)
      LOOP

         If i.cnt > 1
         THEN

           l_curr_cpe_start_date := i.cpe_date;

           hr_utility.set_location('Step6 count: ' || i.cnt ,25);
           hr_utility.set_location('Step6 l_curr_cpe_start_date ' || l_curr_cpe_start_date ,25);

           IF  j_count = 0
           THEN

               fnd_file.put(FND_FILE.OUTPUT,rpad('Last Name',15,' ') ||'~'||
                                   rpad('Assignment Num',15,' ') ||'~'||
                                   rpad('T_Code',8,' ') ||'~'||
                                   rpad('T_Basis',8,' ')||'~'||
                                   rpad('Refund',13,' ')||'~'||
                                   rpad('T_Prev',12,' ')||'~'||
                                   rpad('P_Prev',12,' ')||'~'||
                                   rpad('Authority',10,' ')||'~'||
                                   rpad('S_Code',8,' ') ||'~'||
                                   rpad('S_Basis',8,' ')||'~'||
                                   rpad('S_Refund',13,' ')||'~'||
                                   rpad('S_T_Prev',12,' ')||'~'||
                                   rpad('S_P_Prev',12,' ')||'~'||
                                   rpad('S_Authrity',10,' ')||'~'||
                                   rpad('Person_Id',10,' ') ||'~'||
                                   rpad('Assign_ID',10,' ') ||'~'||
                                   rpad('Cpe_S_Date',12,' ') ||'~'||
                                   rpad('Eff_S_Date',12,' ') ||'~'||
                                   rpad('Eff_E_Date',12,' ') ||'~'||
                                   rpad('OVN',10,' ')

                        );
            fnd_file.NEW_LINE(FND_FILE.OUTPUT);

            fnd_file.put(FND_FILE.OUTPUT,'---------       --------------  ------   -------  ------        ------       ');
            fnd_file.put(FND_FILE.OUTPUT,'------       ---------  ------   -------  --------      --------     --------     ');
            fnd_file.put(FND_FILE.OUTPUT,'---------- ---------  ---------  ----------   ----------   ----------   ----');

            fnd_file.NEW_LINE(FND_FILE.OUTPUT);

            j_count := 1;

         END IF;

         hr_utility.set_location('Step7 l_tax_ref'        || l_tax_ref,10);
         hr_utility.set_location('Step7 l_person_id'      || l_person_id,10);
         hr_utility.set_location('Step7 l_ele_type_id'    || l_ele_type_id,10);
         hr_utility.set_location('Step7 l_sft_coding_id'  || l_sft_coding_id,10);
         hr_utility.set_location('Step7 l_effective_date' || l_effective_date,10);

         --Loop throught the result set and write the details to the Output File.
         FOR required_info in c_get_details(l_person_id,
                                             l_ele_type_id,
                                             l_effective_date,
                                             l_tax_ref,
                                             l_sft_coding_id,
                                             l_curr_cpe_start_date
                                             )
         LOOP

            hr_utility.set_location('Step8',10);

            IF (l_last_person_id <> required_info.pid)
            THEN

               fnd_file.NEW_LINE(FND_FILE.OUTPUT);
               l_last_person_id := required_info.pid;

               l_last_cpe_st_date := required_info.cpe_start;

               j_tax_code   := required_info.tax_code;
               j_tax_basis  := required_info.tax_basis;
               j_refundable := required_info.Refundable;
               j_tax_previous := required_info.Tax_Previous;
               j_pay_previous := required_info.Pay_Previous;
               j_authority := required_info.Authority;

            ELSE

               IF l_last_cpe_st_date <> required_info.cpe_start
               THEN

                  l_last_cpe_st_date := required_info.cpe_start;
                  j_tax_code   := required_info.tax_code;
                  j_tax_basis  := required_info.tax_basis;
                  j_refundable := required_info.Refundable;
                  j_tax_previous := required_info.Tax_Previous;
                  j_pay_previous := required_info.Pay_Previous;
                  j_authority := required_info.Authority;

               END IF;

            END IF;

            hr_utility.set_location('Step9 l_last_cpe_st_date '|| l_last_cpe_st_date,10);

            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.lname,15,' ')||'~'); --last_name
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.anum,15,' ')||'~');         --Assg_Num
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.tax_code,8,' ')||'~');     --Tax_code
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.tax_basis,8,' ')||'~');    --Tax_basis
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.Refundable,13,' ')||'~');   --Refuns
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.Tax_Previous,12,' ')||'~'); --Tax_Prev
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.Pay_Previous,12,' ')||'~'); --Pay_Prev
            fnd_file.put(FND_FILE.OUTPUT, rpad(nvl(required_info.Authority,' '),10,' ')||'~');    --Authority
            fnd_file.put(FND_FILE.OUTPUT, rpad(j_tax_code,8,' ')||'~'); --S_tax_code
            fnd_file.put(FND_FILE.OUTPUT, rpad(j_tax_basis,8,' ')||'~'); --S_tax_basis
            fnd_file.put(FND_FILE.OUTPUT, rpad(j_refundable,13,' ')||'~'); --S_refundable
            fnd_file.put(FND_FILE.OUTPUT, rpad(j_tax_previous,12,' ')||'~'); --S_Tax_prev
            fnd_file.put(FND_FILE.OUTPUT, rpad(j_pay_previous,12,' ')||'~'); --S_Pay_prev
            fnd_file.put(FND_FILE.OUTPUT, rpad(nvl(j_authority,' '),10,' ')||'~'); --S_Authority
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.pid,10,' ')||'~');       --Pers_Id
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.aid,10,' ')||'~');       --Asg_Id
            fnd_file.put(FND_FILE.OUTPUT, rpad(to_char(required_info.cpe_start,'DD-MON-YYYY'),12,' ')||'~'); --CPE_St_Date
            fnd_file.put(FND_FILE.OUTPUT, rpad(to_char(required_info.effst,'DD-MON-YYYY'),12,' ')||'~');     --Ele Ent St Date
            fnd_file.put(FND_FILE.OUTPUT, rpad(to_char(required_info.effend,'DD-MON-YYYY'),12,' ')||'~');    --Ele Ent Ed Date
            fnd_file.put(FND_FILE.OUTPUT, rpad(required_info.ovn,10,' '));       --Ele OVN

            fnd_file.NEW_LINE(FND_FILE.OUTPUT);

         END LOOP;

      END IF;

    END LOOP;

   END LOOP;

   IF (j_count = 0)
   THEN

      fnd_file.put(FND_FILE.OUTPUT,'No Records Found. All the Aggregated Assignments for the given Tax Districts shares the same Tax details');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);

   ELSE
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'Keys :');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'------');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'T_Code  : Tax Code               S_Code  : Suggested Tax Code                  OVN         : Element Entry Object Version Number');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'T_Basis : Tax Basis              S_Basis : Suggested Tax Basis                 Eff_E_Date  : Element Entry Effective End Date');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'T_Prev  : Tax Previous           S_Prev  : Suggested Tax Previous              Eff_S_Date  : Element Entry Effective Start Date');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'P_Prev  : Pay Previous           S_Prev  : Suggested Pay Previous              Cpe_S_Date  : Start Date of the Continous period of employment');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'Refund  : Refundable Flag        S_Refund  : Suggested Refundable Flag');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'Legends :  C  --> Cummulative');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'-------    N  --> Non-Cummulative');
      fnd_file.NEW_LINE(FND_FILE.OUTPUT);
      fnd_file.put(FND_FILE.OUTPUT,'           ~  --> De-limiter');


   END IF;

   IF paye_future_file.count > 1
  then
    fnd_file.NEW_LINE(FND_FILE.OUTPUT);
    fnd_file.NEW_LINE(FND_FILE.OUTPUT);
    fnd_file.put(FND_FILE.OUTPUT,'* Please review the log files for any warnings messages.');
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.put(FND_FILE.LOG,'The below listed assignments has future dated changes to PAYE Details elements.');
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.put(FND_FILE.LOG,'Manual update may be required for this records.');
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.put(FND_FILE.LOG,'Last_Name                  Assignment_Number           Effective_Date');
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.put(FND_FILE.LOG,'---------                  -----------------           ---------------');

    For i in 1..paye_future_file.last
    LOOP

    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.put(FND_FILE.LOG,rpad(paye_future_file(i).l_name,27,' ')||rpad(paye_future_file(i).assignment_num,28,' ')||to_char(paye_future_file(i).effective_date,'dd-MON-YYY'));

    END LOOP;

    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.NEW_LINE(FND_FILE.LOG);
    fnd_file.NEW_LINE(FND_FILE.LOG);
    paye_future_file.delete;

  END IF;

 EXCEPTION

 WHEN paye_sync_eff_date THEN

   retcode:=2;
   errbuf := 'The Effective Date Parameter must be given a value between 06-APR-2009 and Current Date (' ||to_char(sysdate,'dd-mon-yyyy') ||')';

 WHEN others THEN

    retcode:=2;
    errbuf := 'Exception occured :'||sqlerrm;

 END write_util_file;


/* Procedure to Upload the file */
PROCEDURE read_util_file(errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER,
                         p_filename IN VARCHAR2,
                         P_RUN_MODE in VARCHAR2)
       IS
TYPE paye_sync_record IS RECORD(
     last_name            varchar2(255),
     person_id            varchar2(30),
     assignment_number    varchar2(60),
     assignment_id        varchar2(60),
     effective_start_date date,
     effective_end_date   date,
     tax_code             varchar2(20),
     tax_basis            varchar2(20),
     refundable           varchar2(20),
     previous_pay         number,
     previous_tax         number,
     sug_tax_code         varchar2(20),
     sug_tax_basis        varchar2(20),
     sug_refundable       varchar2(20),
     sug_previous_pay     number,
     sug_previous_tax     number,
     cpe_start_date       date,
     assg_ovn             number,
     peef_ovn             number,
     authority            varchar2(20),
     sug_authority        varchar2(20),
     record_changed       varchar2(5),
     err_message    varchar2(1000),
     new_person_cpe_flag      varchar2(1),
     element_entry_id     number,
     tax_code_iv_id       number,
     tax_basis_iv_id      number,
     pay_previous_iv_id   number,
     tax_previous_iv_id   number,
     authority_iv_id      number,
     refundable_iv_id     number);

Type paye_sync_table Is Table Of paye_sync_record Index By Binary_Integer;

TYPE db_paye_record IS RECORD(
last_name                       per_all_people_f.last_name%type,
person_id                       per_all_people_f.person_id%type,
assignment_id                   per_all_assignments_f.assignment_id%type,
assignment_number               per_all_assignments_f.assignment_number%type,
payroll_id                      per_all_assignments_f.payroll_id%type,
effective_start_date            pay_element_entries_f.effective_start_date%type,
effective_end_date              pay_element_entries_f.effective_end_date%type,
cpe_start_date                  date,
eef_object_version_number       pay_element_entries_f.object_version_number%type,
element_entry_id                pay_element_entries_f.element_entry_id%type,
creator_id                      pay_element_entries_f.creator_id%type,
tax_code_iv_id                  pay_input_values_f.input_value_id%type,
tax_code                        pay_element_entry_values_f.screen_entry_value%type,
tax_basis_iv_id                 pay_input_values_f.input_value_id%type,
tax_basis                       pay_element_entry_values_f.screen_entry_value%type,
pay_previous_iv_id              pay_input_values_f.input_value_id%type,
pay_previous                    pay_element_entry_values_f.screen_entry_value%type,
tax_previous_iv_id              pay_input_values_f.input_value_id%type,
tax_previous                    pay_element_entry_values_f.screen_entry_value%type,
authority_iv_id                 pay_input_values_f.input_value_id%type,
authority                       pay_element_entry_values_f.screen_entry_value%type,
refundable_iv_id                pay_input_values_f.input_value_id%type,
refundable                      pay_element_entry_values_f.screen_entry_value%type
);

cursor get_element_type_id
    is
select element_type_id
  from pay_element_types_f
 where element_name = 'PAYE Details'
   and legislation_code = 'GB';

cursor csr_db_paye_det(P_IN_ASSIGNMENT_ID number,
                       P_IN_TAX_DISTRICT varchar2,
                       P_IN_ELE_TYP_ID number,
                       P_EFF_DATE date)
    is
select papf.last_name,
       papf.person_id,
       paaf.assignment_id,
       paaf.assignment_number,
       paaf.payroll_id,
       peef.effective_start_date,
       peef.effective_end_date,
       pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, P_IN_TAX_DISTRICT, P_EFF_DATE) cpe_start_date,
       --paaf.object_version_number,
       peef.element_entry_id,
       peef.creator_id,
       peef.object_version_number,
       min(decode(inv.name, 'Tax Code',     eev.input_value_id, null))     tax_code_id ,
       min(decode(inv.name, 'Tax Code',     eev.screen_entry_value, null)) tax_code_sv ,
       min(decode(inv.name, 'Tax Basis',    eev.input_value_id, null))     tax_basis_id ,
       min(decode(inv.name, 'Tax Basis',    eev.screen_entry_value, null)) tax_basis_sv ,
       min(decode(inv.name, 'Pay Previous', eev.input_value_id, null))     pay_previous_id ,
       min(decode(inv.name, 'Pay Previous', eev.screen_entry_value, null)) pay_previous_sv ,
       min(decode(inv.name, 'Tax Previous', eev.input_value_id, null))     tax_previous_id ,
       min(decode(inv.name, 'Tax Previous', eev.screen_entry_value, null)) tax_previous_sv ,
       min(decode(inv.name, 'Authority',    eev.input_value_id, null))     authority_id ,
       min(decode(inv.name, 'Authority',    eev.screen_entry_value, null)) authority_sv ,
       min(decode(inv.name, 'Refundable',   eev.input_value_id, null))     refundable_id ,
       min(decode(inv.name, 'Refundable',   eev.screen_entry_value, null)) refundable_sv
  from per_all_people_f    papf,
       per_all_assignments_f      paaf,
       pay_element_entries_f      peef,
       pay_element_entry_values_f eev,
       pay_input_values_f         inv,
       pay_all_payrolls_f        pap,
       per_periods_of_service    ppos, -- Added for considering Terminated Employees till FPD
       hr_soft_coding_keyflex     flex
 where paaf.assignment_id = P_IN_ASSIGNMENT_ID
   and paaf.assignment_type = 'E'
   and paaf.person_id = papf.person_id
   and paaf.payroll_id = pap.payroll_id
   /* Bug Fix to pick assignments that are terminated and before FPD
   -- and papf.current_employee_flag = 'Y'
   */
   and ppos.person_id = papf.person_id
   and (papf.current_employee_flag = 'Y'
           OR
        ppos.final_process_date >= P_EFF_DATE)
   /* End of FPD Bug Fix */
   and papf.per_information10 = 'Y'
   and flex.soft_coding_keyflex_id = pap.soft_coding_keyflex_id
   and flex.segment1 = P_IN_TAX_DISTRICT
   and inv.element_type_id = P_IN_ELE_TYP_ID
   and inv.input_value_id = eev.input_value_id
   and peef.element_type_id = P_IN_ELE_TYP_ID
   and peef.assignment_id = paaf.assignment_id
   -- and --peef.entry_information_category = 'GB_PAYE'
   and eev.element_entry_id=peef.element_entry_id
   and P_EFF_DATE between papf.effective_start_date and papf.effective_end_date
   and P_EFF_DATE between paaf.effective_start_date and paaf.effective_end_date
   and P_EFF_DATE between peef.effective_start_date and peef.effective_end_date
   and P_EFF_DATE between eev.effective_start_date and eev.effective_end_date
   and P_EFF_DATE between inv.effective_start_date and inv.effective_end_date
   and P_EFF_DATE between pap.effective_start_date and pap.effective_end_date
 group by papf.last_name,
          papf.person_id,
          paaf.assignment_id,
          paaf.assignment_number,
          paaf.payroll_id,
          peef.effective_start_date,
          peef.effective_end_date,
          pay_gb_eoy_archive.get_agg_active_start(paaf.assignment_id, P_IN_TAX_DISTRICT, P_EFF_DATE),
          --paaf.object_version_number,
          peef.element_entry_id,
          peef.creator_id,
          peef.object_version_number;

--
l_filename               VARCHAR2(100);
l_location         VARCHAR2(2000);
l_file_handle            utl_file.file_type;
-- DS
tab_paye_file            paye_sync_table;
db_paye_details          db_paye_record;
l_record_no              NUMBER := 0;
-- exceptions
e_fatal_error            exception;
invalid_file_format      exception;
no_rec_found_in_file     exception;
l_processing             boolean := false;
l_present_line           VARCHAR2(500) := null;

P_PAYE_ELE_ID            number;
l_curr_person_id         number;
l_prev_person_id         number := -1;
l_person_index           number := 0;

l_curr_person_cpe         date;
l_prev_person_cpe         date := fnd_date.canonical_to_date('4712/12/31 00:00:00');


l_arg1 varchar2(30) := null;
l_arg2 date;
v_date_format varchar2(40) := 'DD-MON-YYYY';

download_cp_eff_date     date;
download_cp_req_id       number;
download_cp_tax_ref      varchar2(100);

l_pkg varchar2(40) := 'pygbpayesync upload : ';
-----
  /* Check if original PAYE details in the file and in the database are same.
   *  If not same return false, else return true.
   *  db_rec record holds the details fetched from database.
   *  tab_paye_file plsql table holds the details mentioned in the file.
   */
function compare_file_db_details(l_count number,
                                 db_rec db_paye_record)
return boolean
    is

l_tax_basis varchar2(100);
l_refundable varchar2(100);

BEGIN
  /* Debug Information */
  hr_utility.trace( l_pkg ||'Parameters: l_count :'||l_count);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).person_id||'::DB-'||db_rec.person_id);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).assignment_id||'::DB-'||db_rec.assignment_id);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).assignment_number||'::DB-'||db_rec.assignment_number);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).last_name||'::DB-'||db_rec.last_name);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).effective_start_date||'::DB-'||db_rec.effective_start_date);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).effective_end_date||'::DB-'||db_rec.effective_end_date);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).cpe_start_date||'::DB-'||db_rec.cpe_start_date);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).peef_ovn||'::DB-'||db_rec.eef_object_version_number);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).tax_code||'::DB-'||db_rec.tax_code);
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).tax_basis||'::DB-'||HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',db_rec.tax_basis));
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).refundable||'::DB-'||HR_GENERAL.DECODE_LOOKUP('GB_REFUNDABLE',db_rec.refundable));
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).previous_pay||'::DB-'||nvl(db_rec.pay_previous,0));
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).previous_tax||'::DB-'||nvl(db_rec.tax_previous,0));
  hr_utility.trace( l_pkg ||'FILE-'||tab_paye_file(l_count).authority||'::DB-'||db_rec.authority);
  /* End Debug information */

  IF((nvl(tab_paye_file(l_count).person_id, -1) = db_rec.person_id) and
     (nvl(tab_paye_file(l_count).assignment_id, -1) = db_rec.assignment_id) and
     (nvl(tab_paye_file(l_count).assignment_number, -1) = db_rec.assignment_number) and
     (nvl(substr(tab_paye_file(l_count).last_name,1,15),'NULL') = substr(db_rec.last_name,1,15)) and
     (tab_paye_file(l_count).effective_start_date = db_rec.effective_start_date) and
     (tab_paye_file(l_count).effective_end_date = db_rec.effective_end_date) and
     (tab_paye_file(l_count).cpe_start_date = db_rec.cpe_start_date) and
     (nvl(tab_paye_file(l_count).peef_ovn, -1) = db_rec.eef_object_version_number) and
     (nvl(tab_paye_file(l_count).tax_code,'NULL') = nvl(db_rec.tax_code,'NULL')) and
     (nvl(tab_paye_file(l_count).tax_basis,'NULL') = nvl(HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',db_rec.tax_basis),'NULL')) and
     (nvl(tab_paye_file(l_count).refundable,'NULL') = nvl(HR_GENERAL.DECODE_LOOKUP('GB_REFUNDABLE',db_rec.refundable),'NULL')) and
     (nvl(tab_paye_file(l_count).previous_pay,0) = nvl(db_rec.pay_previous,0)) and
     (nvl(tab_paye_file(l_count).previous_tax,0) = nvl(db_rec.tax_previous,0)) and
     (nvl(tab_paye_file(l_count).authority,'NULL') = nvl(db_rec.authority,'NULL'))
     )
   THEN

     IF(tab_paye_file(l_count).sug_tax_code = db_rec.tax_code and
        tab_paye_file(l_count).sug_tax_basis = HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',db_rec.tax_basis) and
        tab_paye_file(l_count).sug_refundable = HR_GENERAL.DECODE_LOOKUP('GB_REFUNDABLE',db_rec.refundable) and
        tab_paye_file(l_count).sug_previous_pay = nvl(db_rec.pay_previous,0) and
        tab_paye_file(l_count).sug_previous_tax = nvl(db_rec.tax_previous,0) and
        nvl(tab_paye_file(l_count).sug_authority,'NULL') = nvl(db_rec.authority,'NULL')
       )
      THEN
          tab_paye_file(l_count).record_changed := 'N';
      END IF;
      return true;
 ELSE

   return false;

 END IF;

 return true;

END compare_file_db_details;



------------
/* This procedure will set the error message for all the assignments of
 * the person belonging to a CPE. Setting this will ensure that if any validation
 * error occurs for one assignment, all the persons assignments belonging to that
 * CPE will not be picked for PAYE details updation.
 */
PROCEDURE set_person_level_error_mesg(P_PERSON_START_INDEX number,
                                      P_PERSON_ID number,
                                      P_PERSON_CPE date,
                                      P_ERR_MSG VARCHAR2)
       IS

v_person_start_index number;

BEGIN
  hr_utility.trace( l_pkg ||'Parameters: P_PERSON_START_INDEX :'||P_PERSON_START_INDEX);
  hr_utility.trace( l_pkg ||'Parameters: P_PERSON_ID :'||P_PERSON_ID);
  hr_utility.trace( l_pkg ||'Parameters: P_PERSON_CPE Start :'||P_PERSON_CPE);
  hr_utility.trace( l_pkg ||'Parameters: P_ERR_MSG :'||P_ERR_MSG);

  v_person_start_index := P_PERSON_START_INDEX;

  IF (tab_paye_file(v_person_start_index).person_id = P_PERSON_ID and
      tab_paye_file(v_person_start_index).cpe_start_date = P_PERSON_CPE )
  THEN
     WHILE TRUE
     LOOP
        IF (tab_paye_file(v_person_start_index).person_id = P_PERSON_ID and
            tab_paye_file(v_person_start_index).cpe_start_date = P_PERSON_CPE)
        THEN
            tab_paye_file(v_person_start_index).err_message := P_ERR_MSG;
            hr_utility.trace( l_pkg ||'Error message Set. '||tab_paye_file(v_person_start_index).err_message);
            hr_utility.trace( l_pkg ||'v_person_start_index: '||v_person_start_index);
            v_person_start_index := v_person_start_index + 1;
            if (tab_paye_file.count = v_person_start_index) then
             exit; -- reached the last record.
            end if;
        ELSE --next person record hence exit
           EXIT; -- break loop
        END if;

     END LOOP;

   END if;

END set_person_level_error_mesg;

------------
/* This function is used to read each assignment line and split the data into columns.
 * This function takes the below arguments
 * in_line - Each Line, which contains the delimiter tokens.
 * token_index - Nth Occurance of the token.
 * delim - Delimiter token.
 * return value - String between (N-1)th Occurence and Nth Occurence of the delimiter.
 */

function get_token(
   in_line  varchar2,
   token_index number,
   delim     varchar2 default '~'
)
   return    varchar2
is
   start_pos number;
   end_pos   number;
begin
   if token_index = 1 then
       start_pos := 1;
   else
       start_pos := instr(in_line, delim, 1, token_index - 1);
       if start_pos = 0 then
           return null;
       else
           start_pos := start_pos + length(delim);
       end if;
   end if;

   end_pos := instr(in_line, delim, start_pos, 1);

   if end_pos = 0 then
       return trim(substr(in_line, start_pos));
   else
       return trim(substr(in_line, start_pos, end_pos - start_pos));
   end if;

end get_token;

------------
/* This function is used to count the number of occurances of the given delimiter.
 * in_line - Input Line
 * return value - Number of occurances.
 */

function count_tokens (in_line  varchar2,
                       delim     varchar2 default '~')
return number is
  l_token_count number := 0;
  l_start number :=0;
begin
  while true loop
     l_start := instr(in_line, delim, l_start+length(delim), 1);
     if l_start = 0 then
        -- No More Token Found. Hence return the count.
        exit;
     else
        -- One more Token Found. Increment the count.
        l_token_count := l_token_count+1;
     end if;
  end loop;
  return l_token_count;
end count_tokens;


------------
BEGIN --main Begin

  hr_utility.set_location( l_pkg ||'PAYE Upload',5);
  l_filename := p_filename;
  fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_location);
  fnd_file.PUT_LINE(FND_FILE.LOG, 'Directory:'|| l_location);
  fnd_file.PUT_LINE(FND_FILE.LOG, 'File Name:'|| l_filename);
  fnd_file.PUT_LINE(FND_FILE.LOG, 'Run Mode:'||P_RUN_MODE);

  IF l_location IS NULL
  THEN
    -- error : I/O directory not defined
    retcode := 2;
    errbuf := 'Input directory not defined. Set PER_DATA_EXCHANGE_DIR profile (HR: Data Exchange directory).';
    hr_utility.trace( l_pkg ||'Input directory not defined in PER_DATA_EXCHANGE_DIR profile.');
    raise e_fatal_error;

  END IF;

   OPEN get_element_type_id;
   FETCH get_element_type_id into P_PAYE_ELE_ID;
   CLOSE get_element_type_id;

  IF(P_PAYE_ELE_ID is null)
  THEN
    retcode:=2;
    errbuf := 'PAYE Details element not found in the system.';
    raise e_fatal_error;
  END IF;

  fnd_file.PUT_LINE(FND_FILE.LOG, 'P_PAYE_ELE_ID:'||P_PAYE_ELE_ID);
  l_file_handle := utl_file.fopen(l_location,l_filename,'r');
  utl_file.get_line(l_file_handle,l_present_line);

 BEGIN
 /* The first line of the file should be 'Download Parameters'
  * Read each line for Download Parameter information.
  * If parameter information is null then throw exception.     */
  IF (l_present_line = '---------------- Download Parameters --------------------')
  THEN
     WHILE TRUE
     LOOP
         utl_file.get_line(l_file_handle,l_present_line);
         IF (substr(l_present_line,1,24)='* Effective Date       :')
         THEN
           download_cp_eff_date := to_date(trim(substr(l_present_line,26,11)), v_date_format);
         ELSIF (substr(l_present_line,1,24)='* Tax Reference        :')
         THEN
           download_cp_tax_ref  := trim(substr(l_present_line,26));
         ELSIF (substr(l_present_line,1,24)='* Download Request Id  :')
         THEN
           download_cp_req_id   := trim(substr(l_present_line,26,9));
         ELSIF (substr(l_present_line,1,24)='* Run Date             :')
         THEN
           null;
         ELSIF (l_present_line is null)
         THEN
           null;
         ELSE -- Further data available in file.
           exit;
         END IF;
     END LOOP;

     IF ((download_cp_eff_date is null) or (download_cp_tax_ref is null) or (download_cp_req_id is null))
     THEN
       retcode := 2;
       errbuf := 'Invalid file format.';
       fnd_file.PUT_LINE(FND_FILE.LOG,'Download Parameters section altered.');
       hr_utility.trace( l_pkg ||'download_cp_eff_date is null or download_cp_tax_ref is null or download_cp_req_id is null');
       raise invalid_file_format;
     END IF;

   /* Validate the given Download Req ID in Database and fetch the Tax Reference
    * and effective date parameters. Compare this against the details mentioned
    * in the file. If diff raise exception, else proceed.
    */
     begin
       select argument1,  --Tax Reference
       fnd_date.canonical_to_date(argument3)   --Effective Date
       into l_arg1, l_arg2
       from fnd_concurrent_requests
       where request_id=download_cp_req_id;

       if ((l_arg1 <> download_cp_tax_ref) or
           (l_arg2 <> download_cp_eff_date)) then
           retcode := 2;
           errbuf := 'Download Parameters section altered.';
           fnd_file.PUT_LINE(FND_FILE.LOG,'Download Parameters section altered.');
           hr_utility.trace( l_pkg ||'download_cp_tax_ref :'||download_cp_tax_ref);
           hr_utility.trace( l_pkg ||'Download Request tax ref Argument :'||l_arg1);
           hr_utility.trace( l_pkg ||'download_cp_eff_date :'||download_cp_eff_date);
           hr_utility.trace( l_pkg ||'Download Request eff date Argument :'||l_arg2);
           raise invalid_file_format;
       end if;

     exception
       when no_data_found then
        retcode := 2;
        errbuf := 'Download Parameters Request ID '||download_cp_req_id||' does not exist in the system';
        fnd_file.PUT_LINE(FND_FILE.LOG,'Download Parameters Request ID '||download_cp_req_id||' does not exist in the system');
        raise invalid_file_format;
     end;

     fnd_file.PUT_LINE(FND_FILE.LOG,'Download cp req_id :'||download_cp_req_id);
     fnd_file.PUT_LINE(FND_FILE.LOG,'Download cp tax_ref :'||download_cp_tax_ref);
     fnd_file.PUT_LINE(FND_FILE.LOG,'Download cp eff_date :'||download_cp_eff_date);

  ELSE --Beginning line is not 'Download Parameters'
     retcode := 2;
     errbuf := 'Invalid file format.';
     fnd_file.PUT_LINE(FND_FILE.LOG,'File not started with Download Parameters section.');
     hr_utility.trace( l_pkg ||'Beginning line is :'||l_present_line);
     raise invalid_file_format;
  END IF;

 /* Read each line from file to get the Records to be updated
  * If No Records Found, come out appropriately.              */
  WHILE TRUE
  LOOP

    IF (substr(l_present_line,1,41)='Last Name      ~Assignment Num ~T_Code  ~')
    THEN
       null;

    ELSIF (substr(l_present_line,1,9)='---------')
    THEN
       null;

    ELSIF (substr(l_present_line,1,16)='No Records Found')
    THEN
       retcode := 0;
       errbuf := 'No Records found in the file mentioned.';
       fnd_file.PUT_LINE(FND_FILE.OUTPUT,'No Records Found in the file mentioned. ('||l_filename||')');
       raise no_rec_found_in_file;

    ELSIF (l_present_line is null)
    THEN
       null;

    ELSE -- Records found.
       l_processing := true;
       exit;

    END IF;

    utl_file.get_line(l_file_handle,l_present_line);

  END LOOP;

 EXCEPTION
 /* If end of file is reached before reading the records to be updated,
  * throw exception.
  */
    WHEN NO_DATA_FOUND
    THEN
      retcode := 2;
      errbuf := 'Invalid file format.';
      fnd_file.PUT_LINE(FND_FILE.OUTPUT,'Could not find any records to be updated or the No Records Found message in the mentioned file.');
      raise invalid_file_format;
 END;

  /* Records found for processing. Loop through the records, identify the columns,
   * and fill in the plsql table.
   */
  WHILE l_processing
  LOOP
    IF (trim(l_present_line) is not null)
    THEN

      hr_utility.trace( l_pkg ||'Inside loop, reading line:'||l_present_line);

        if (count_tokens(l_present_line) <> 19) then
           retcode := 2;
           errbuf := 'Record Format altered.';
           fnd_file.PUT_LINE(FND_FILE.OUTPUT,'Delimiter count is not as expected. Record Format altered.');
           raise invalid_file_format;
        end if;

      tab_paye_file(l_record_no).last_name         := get_token(l_present_line,1);
      tab_paye_file(l_record_no).assignment_number := get_token(l_present_line,2);
      tab_paye_file(l_record_no).tax_code          := get_token(l_present_line,3);
      tab_paye_file(l_record_no).tax_basis         := get_token(l_present_line,4);
      tab_paye_file(l_record_no).refundable        := get_token(l_present_line,5);
      tab_paye_file(l_record_no).previous_tax      := to_number(replace(get_token(l_present_line,6),',',NULL));
      tab_paye_file(l_record_no).previous_pay      := to_number(replace(get_token(l_present_line,7),',',NULL));
      tab_paye_file(l_record_no).authority         := get_token(l_present_line,8);
      tab_paye_file(l_record_no).sug_tax_code      := get_token(l_present_line,9);
      tab_paye_file(l_record_no).sug_tax_basis     := get_token(l_present_line,10);
      tab_paye_file(l_record_no).sug_refundable    := get_token(l_present_line,11);
      tab_paye_file(l_record_no).sug_previous_tax  := to_number(replace(get_token(l_present_line,12),',',NULL));
      tab_paye_file(l_record_no).sug_previous_pay  := to_number(replace(get_token(l_present_line,13),',',NULL));
      tab_paye_file(l_record_no).sug_authority     := get_token(l_present_line,14);
      tab_paye_file(l_record_no).person_id         := get_token(l_present_line,15);
      tab_paye_file(l_record_no).assignment_id     := get_token(l_present_line,16);
      tab_paye_file(l_record_no).cpe_start_date    := to_date(get_token(l_present_line,17),v_date_format);
      tab_paye_file(l_record_no).effective_start_date := to_date(get_token(l_present_line,18),v_date_format);
      tab_paye_file(l_record_no).effective_end_date   := to_date(get_token(l_present_line,19),v_date_format);
      tab_paye_file(l_record_no).peef_ovn             := get_token(l_present_line,20);


      tab_paye_file(l_record_no).tax_basis := HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',tab_paye_file(l_record_no).tax_basis);
      tab_paye_file(l_record_no).sug_tax_basis := HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',tab_paye_file(l_record_no).sug_tax_basis);

      hr_utility.trace( l_pkg ||'last_name:'||tab_paye_file(l_record_no).last_name);
      hr_utility.trace( l_pkg ||'person_id:'||tab_paye_file(l_record_no).person_id);
      hr_utility.trace( l_pkg ||'assignment_id:'||tab_paye_file(l_record_no).assignment_id);
      hr_utility.trace( l_pkg ||'assignment_number:'||tab_paye_file(l_record_no).assignment_number);
      hr_utility.trace( l_pkg ||'effective_start_date:'||tab_paye_file(l_record_no).effective_start_date);
      hr_utility.trace( l_pkg ||'effective_end_date:'||tab_paye_file(l_record_no).effective_end_date);
      hr_utility.trace( l_pkg ||'cpe_start_date:'||tab_paye_file(l_record_no).cpe_start_date);
      hr_utility.trace( l_pkg ||'peef_ovn:'||tab_paye_file(l_record_no).peef_ovn);
      hr_utility.trace( l_pkg ||'tax_code:'||tab_paye_file(l_record_no).tax_code);
      hr_utility.trace( l_pkg ||'tax_basis:'||tab_paye_file(l_record_no).tax_basis);
      hr_utility.trace( l_pkg ||'refundable:'||tab_paye_file(l_record_no).refundable);
      hr_utility.trace( l_pkg ||'previous_pay:'||tab_paye_file(l_record_no).previous_pay);
      hr_utility.trace( l_pkg ||'previous_tax:'||tab_paye_file(l_record_no).previous_tax);

      l_curr_person_id := tab_paye_file(l_record_no).person_id;
      l_curr_person_cpe := tab_paye_file(l_record_no).cpe_start_date;
      IF( l_curr_person_id <> l_prev_person_id  or
          l_curr_person_cpe <> l_prev_person_cpe )
      THEN

        tab_paye_file(l_record_no).new_person_cpe_flag := 'Y';
        l_prev_person_id := l_curr_person_id;
        l_prev_person_cpe := l_curr_person_cpe;

      END IF;

      l_record_no := l_record_no +1;

    END IF;

    BEGIN

      utl_file.get_line(l_file_handle,l_present_line);

      IF (l_present_line = 'Keys :')
      THEN
        exit;
      END IF;
        --
      hr_utility.set_location( l_pkg ||'PAYE Upload',50);
      hr_utility.trace( l_pkg ||'line: '|| l_present_line);
        --
    EXCEPTION
      WHEN no_data_found
      THEN
        l_processing := false;
        EXIT;
    END;

  END LOOP;

  fnd_file.PUT_LINE(FND_FILE.LOG, 'Reading File complete. Total Records present :'||l_record_no);
  utl_file.fclose(l_file_handle);

/* Loop through the assignments and validate them. Below are the list of validations:
     1. Check if the assignment details are not changed after download program.
     2. Check if the sugg values are consistent across assignments of the same person.
*/
  FOR l_count in 0..(l_record_no-1)
  LOOP

      hr_utility.trace( l_pkg ||'Inside validating loop :'||l_count);

      IF(tab_paye_file(l_count).new_person_cpe_flag = 'Y')
      THEN
           l_person_index := l_count;
        END if;

      OPEN csr_db_paye_det( tab_paye_file(l_count).assignment_id,
                              download_cp_tax_ref,
                        to_number(P_PAYE_ELE_ID),
                        download_cp_eff_date );

      hr_utility.trace( l_pkg ||'Before checking against DB for '||tab_paye_file(l_count).assignment_id||' and '||download_cp_tax_ref||' and '||P_PAYE_ELE_ID);

      FETCH csr_db_paye_det
       INTO db_paye_details.last_name,
            db_paye_details.person_id,
            db_paye_details.assignment_id,
            db_paye_details.assignment_number,
            db_paye_details.payroll_id,
            db_paye_details.effective_start_date,
            db_paye_details.effective_end_date,
            db_paye_details.cpe_start_date,
            db_paye_details.element_entry_id,
            db_paye_details.creator_id,
            db_paye_details.eef_object_version_number,
            db_paye_details.tax_code_iv_id,
            db_paye_details.tax_code,
            db_paye_details.tax_basis_iv_id,
            db_paye_details.tax_basis,
            db_paye_details.pay_previous_iv_id,
            db_paye_details.pay_previous,
            db_paye_details.tax_previous_iv_id,
            db_paye_details.tax_previous,
            db_paye_details.authority_iv_id,
            db_paye_details.authority,
            db_paye_details.refundable_iv_id,
            db_paye_details.refundable        ;

        IF (csr_db_paye_det%notfound)
        THEN

          fnd_file.PUT_LINE(FND_FILE.LOG, 'No records found on the mentioned date for assignment '||tab_paye_file(l_count).assignment_number);
          set_person_level_error_mesg(l_person_index, tab_paye_file(l_count).person_id, tab_paye_file(l_count).cpe_start_date,'PAYE Details for assignment(s) of this person, changed in the database.');

        END IF;

      hr_utility.trace( l_pkg ||'Cursor Count:'||csr_db_paye_det%rowcount);
      CLOSE csr_db_paye_det;
      hr_utility.trace( l_pkg ||'DB last_name:'||db_paye_details.last_name);
      hr_utility.trace( l_pkg ||'DB person_id:'||db_paye_details.person_id);
      hr_utility.trace( l_pkg ||'DB assignment_id:'||db_paye_details.assignment_id);
      hr_utility.trace( l_pkg ||'After fetching data from DB');


      /* Check if the person level suggested values are same and set err message appropriately */
      IF NOT(nvl(tab_paye_file(l_count).sug_tax_code,'NULL') = nvl(tab_paye_file(l_person_index).sug_tax_code,'NULL') AND
             nvl(tab_paye_file(l_count).sug_tax_basis,'NULL') = nvl(tab_paye_file(l_person_index).sug_tax_basis,'NULL') AND
             nvl(tab_paye_file(l_count).sug_refundable,'NULL') = nvl(tab_paye_file(l_person_index).sug_refundable,'NULL') AND
             nvl(tab_paye_file(l_count).sug_previous_pay,0) = nvl(tab_paye_file(l_person_index).sug_previous_pay,0) AND
             nvl(tab_paye_file(l_count).sug_previous_tax,0) = nvl(tab_paye_file(l_person_index).sug_previous_tax,0) AND
             nvl(tab_paye_file(l_count).sug_authority,'NULL') = nvl(tab_paye_file(l_person_index).sug_authority,'NULL') )
      THEN

         set_person_level_error_mesg(l_person_index, tab_paye_file(l_count).person_id, tab_paye_file(l_count).cpe_start_date,
                'Suggested PAYE Details mentioned in the file, not uniform across the assignment(s) of this person which are with in the same CPE.');

      END IF;

      /* Check the file data with database data to compare if there are any changes to data after download program */
      /* If already a error message set, no need to check with DB. */
      IF (tab_paye_file(l_count).err_message is null) then
      IF NOT(compare_file_db_details(l_count, db_paye_details))
      THEN

         fnd_file.PUT_LINE(FND_FILE.LOG, 'Compare with DB Failed for assignment'||tab_paye_file(l_count).assignment_number);
         set_person_level_error_mesg(l_person_index, tab_paye_file(l_count).person_id, tab_paye_file(l_count).cpe_start_date, 'PAYE Details for assignment(s) of this person, changed in the database.');

      END IF;
      end if;



      /* Set the Element entry id and input value id details */
      tab_paye_file(l_count).element_entry_id  := db_paye_details.element_entry_id;
      tab_paye_file(l_count).tax_code_iv_id    := db_paye_details.tax_code_iv_id;
      tab_paye_file(l_count).tax_basis_iv_id   := db_paye_details.tax_basis_iv_id;
      tab_paye_file(l_count).pay_previous_iv_id := db_paye_details.pay_previous_iv_id;
      tab_paye_file(l_count).tax_previous_iv_id := db_paye_details.tax_previous_iv_id;
      tab_paye_file(l_count).authority_iv_id   := db_paye_details.authority_iv_id;
      tab_paye_file(l_count).refundable_iv_id  := db_paye_details.refundable_iv_id;

      /* Clear the variable */
      db_paye_details.last_name := null;
      db_paye_details.person_id := null;
      db_paye_details.assignment_id := null;
      db_paye_details.assignment_number := null;
      db_paye_details.payroll_id := null;
      db_paye_details.effective_start_date := null;
      db_paye_details.effective_end_date := null;
      db_paye_details.cpe_start_date := null;
      db_paye_details.element_entry_id := null;
      db_paye_details.creator_id := null;
      db_paye_details.eef_object_version_number := null;
      db_paye_details.tax_code_iv_id := null;
      db_paye_details.tax_code := null;
      db_paye_details.tax_basis_iv_id := null;
      db_paye_details.tax_basis := null;
      db_paye_details.pay_previous_iv_id := null;
      db_paye_details.pay_previous := null;
      db_paye_details.tax_previous_iv_id := null;
      db_paye_details.tax_previous := null;
      db_paye_details.authority_iv_id := null;
      db_paye_details.authority := null;
      db_paye_details.refundable_iv_id := null;
      db_paye_details.refundable := null;


   END LOOP; --END OF VALIDATIONS LOOP

   /* Loop through the assignments and perform the below:
      If error message set for this assignment, then skip this assignment
      If no error, and there is no change in the exisiting and suggested values then skip
      If no error, and the existing values are diff from sugg values call hr_entry_api
      If run in validate mode dont commit, else commit
   */
   BEGIN
   --SAVEPOINT PRE_STATE;

      fnd_file.PUT_LINE(FND_FILE.OUTPUT,'List of Assignments Successfully Uploaded:');
      fnd_file.PUT_LINE(FND_FILE.OUTPUT,rpad('Person Name',20,' ')||rpad('Assignment Num',20,' ')||rpad('Comments',30,' '));
      fnd_file.PUT_LINE(FND_FILE.OUTPUT,rpad('-----------',20,' ')||rpad('--------------',20,' ')||rpad('--------',30,' '));

    FOR l_count in 0..(l_record_no-1)
    LOOP

       IF (tab_paye_file(l_count).err_message is null)
       THEN
          fnd_file.PUT_LINE(FND_FILE.LOG,'Processing assignment '||tab_paye_file(l_count).assignment_number||' record.');
          IF (tab_paye_file(l_count).record_changed = 'N')
          THEN

            fnd_file.PUT_LINE(FND_FILE.OUTPUT,rpad(tab_paye_file(l_count).last_name,20,' ')||rpad(tab_paye_file(l_count).assignment_number,20,' ')||'No Change');

          ELSIF (nvl(tab_paye_file(l_count).record_changed,'Y') = 'Y')
          THEN

            hr_utility.trace( l_pkg ||'Arguments to hr_entry_api call');
            hr_utility.trace( l_pkg ||'SessionDate:'||download_cp_eff_date);
            hr_utility.trace( l_pkg ||'p_element_entry_id:'||tab_paye_file(l_count).element_entry_id);
            hr_utility.trace( l_pkg ||'p_input_value_id1:'||tab_paye_file(l_count).tax_code_iv_id);
            hr_utility.trace( l_pkg ||'p_input_value_id2:'||tab_paye_file(l_count).tax_basis_iv_id);
            hr_utility.trace( l_pkg ||'p_input_value_id3:'||tab_paye_file(l_count).pay_previous_iv_id);
            hr_utility.trace( l_pkg ||'p_input_value_id4:'||tab_paye_file(l_count).tax_previous_iv_id);
            hr_utility.trace( l_pkg ||'p_input_value_id5:'||tab_paye_file(l_count).refundable_iv_id);
            hr_utility.trace( l_pkg ||'p_input_value_id6:'||tab_paye_file(l_count).authority_iv_id);
            hr_utility.trace( l_pkg ||'p_entry_value1:'||tab_paye_file(l_count).sug_tax_code);
            hr_utility.trace( l_pkg ||'p_entry_value2:'||tab_paye_file(l_count).sug_tax_basis);
            hr_utility.trace( l_pkg ||'p_entry_value3:'||tab_paye_file(l_count).sug_previous_pay);
            hr_utility.trace( l_pkg ||'p_entry_value4:'||tab_paye_file(l_count).sug_previous_tax);
            hr_utility.trace( l_pkg ||'p_entry_value5:'||tab_paye_file(l_count).sug_refundable);
            hr_utility.trace( l_pkg ||'p_entry_value6:'||tab_paye_file(l_count).sug_authority);

         BEGIN
            -- For bug 8485686
            pqp_gb_ad_ee.g_global_paye_validation := 'N';

            hr_entry_api.update_element_entry(p_dt_update_mode => 'UPDATE',
                                              p_session_date  => download_cp_eff_date,
                                              p_element_entry_id => tab_paye_file(l_count).element_entry_id,
                                              p_input_value_id1 => tab_paye_file(l_count).tax_code_iv_id,
                                              p_input_value_id2 => tab_paye_file(l_count).tax_basis_iv_id,
                                              p_input_value_id3 => tab_paye_file(l_count).pay_previous_iv_id,
                                              p_input_value_id4 => tab_paye_file(l_count).tax_previous_iv_id,
                                              p_input_value_id5 => tab_paye_file(l_count).refundable_iv_id,
                                              p_input_value_id6 => tab_paye_file(l_count).authority_iv_id,
                                              p_entry_value1 => tab_paye_file(l_count).sug_tax_code,
                                              p_entry_value2 => tab_paye_file(l_count).sug_tax_basis,
                                              p_entry_value3 => tab_paye_file(l_count).sug_previous_pay,
                                              p_entry_value4 => tab_paye_file(l_count).sug_previous_tax,
                                              p_entry_value5 => tab_paye_file(l_count).sug_refundable,
                                              p_entry_value6 => tab_paye_file(l_count).sug_authority
                                            );

             -- For bug 8485686
             pqp_gb_ad_ee.g_global_paye_validation := 'Y';

            fnd_file.PUT_LINE(FND_FILE.OUTPUT,rpad(tab_paye_file(l_count).last_name,20,' ')||rpad(tab_paye_file(l_count).assignment_number,20,' ')||'Record Updated');

         EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.NEW_LINE(FND_FILE.OUTPUT);
            fnd_file.PUT_LINE(FND_FILE.OUTPUT,'Errored for Assignment Number : '||tab_paye_file(l_count).assignment_number);
            --ROLLBACK TO PRE_STATE;
             raise;
         END;

         END IF ;

      END IF ;

   END LOOP ;

  IF (P_RUN_MODE = 'GB_VALIDATE_COMMIT')
  THEN
      COMMIT;
  ELSIF (P_RUN_MODE = 'GB_VALIDATE')
  THEN
       ROLLBACK ;
  END IF ;

 EXCEPTION
 WHEN OTHERS
 THEN
    fnd_file.PUT_LINE(FND_FILE.OUTPUT,sqlerrm);
    --ROLLBACK TO PRE_STATE;
    raise;

 END;

  /* Report the errored assignments in the output file and clear the plsql table */
  fnd_file.PUT_LINE(FND_FILE.OUTPUT,' ');
  fnd_file.PUT_LINE(FND_FILE.OUTPUT,'List of Failed Assignments:');
  fnd_file.PUT_LINE(FND_FILE.OUTPUT,RPAD('Person Name',20,' ')||RPAD('Assignment Number',20,' ')||RPAD('Error Message',200,' '));
  fnd_file.PUT_LINE(FND_FILE.OUTPUT,RPAD('-----------',20,' ')||RPAD('-----------------',20,' ')||RPAD('-------------',200,' '));

  FOR l_count in 0..(l_record_no-1)
  LOOP

    IF (tab_paye_file(l_count).err_message is not null)
    THEN
       fnd_file.PUT_LINE(FND_FILE.OUTPUT, RPAD(tab_paye_file(l_count).last_name,20,' ')||RPAD(tab_paye_file(l_count).assignment_number,20,' ')||RPAD(tab_paye_file(l_count).err_message,200,' '));
    END IF ;

    tab_paye_file.delete(l_count);

  END LOOP;
  fnd_file.PUT_LINE(FND_FILE.LOG, 'Program Completed Sucessfully.');
  hr_utility.set_location( l_pkg ||'PAYE Upload',80);
  EXCEPTION
  WHEN e_fatal_error
  THEN
    hr_utility.set_location( l_pkg ||'PAYE Upload',100);

  WHEN UTL_FILE.INVALID_OPERATION
  THEN

    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',110);
    retcode:=2;
    errbuf := 'Reading Flat File - Invalid Operation (file not found).';

  WHEN UTL_FILE.INTERNAL_ERROR
  THEN

    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',120);
    retcode:=2;
    errbuf := 'Reading Flat File - Internal Error.';
  WHEN UTL_FILE.INVALID_MODE
  THEN

    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',130);
    retcode:=2;
    errbuf := 'Reading Flat File - Invalid Mode.';

  WHEN UTL_FILE.INVALID_PATH
  THEN

    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',140);
    retcode:=2;
    errbuf := 'Reading Flat File - Invalid Path.';

 WHEN UTL_FILE.INVALID_FILEHANDLE
 THEN

    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',150);
    retcode:=2;
    errbuf := 'Reading Flat File - Invalid File Handle.';

 WHEN UTL_FILE.READ_ERROR
 THEN

    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',160);
    retcode:=2;
    errbuf := 'Reading Flat File - Read Error.';

 WHEN NO_DATA_FOUND
 THEN
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',170);
    retcode:=2;
    errbuf := 'No Data Found.';

 WHEN INVALID_FILE_FORMAT
 THEN
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',180);

 WHEN NO_REC_FOUND_IN_FILE
 THEN
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location( l_pkg ||'PAYE Upload',190);

 WHEN others
 THEN
    retcode:=2;
    errbuf := 'Exception occured :'||sqlerrm;
    hr_utility.set_location( l_pkg ||'PAYE Upload',200);
END read_util_file;


END pay_gb_paye_sync;


/
