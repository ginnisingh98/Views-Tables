--------------------------------------------------------
--  DDL for Package Body PAY_AU_TFN_MAGTAPE_FLAGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_TFN_MAGTAPE_FLAGS" AS
/* $Header: pyautfnf.pkb 120.5.12010000.6 2009/10/19 05:14:11 dduvvuri ship $*/
------------------------------------------------------------------------------+

/* Bug 4066194
   Package created from pay_au_tfn_magtape to avoid circular self references
   which leads to package invalidation
*/

------------------------------------------------------------------------------+
-- This procedure populates the plsql table with values of the
-- assignment id and tax detail flags that need to be reported on the
-- magtape. The table is used in the magtape cursor 'c_tfn_payee' to get the
-- values of all reportable fields and print on the matape.
------------------------------------------------------------------------------+

PROCEDURE populate_tfn_flags(p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE,
                             p_business_group_id in per_business_groups.business_group_id%TYPE,
                             p_legal_employer_id in hr_soft_coding_keyflex.segment1%TYPE,
                             p_report_end_date   in date)  IS

   -- Record used store the Superannuation details of the employee

   TYPE spr_flag_record IS RECORD
     (
      k_assignment_id           per_all_assignments_f.assignment_id%TYPE,
      tfn_for_super             pay_payautax_spr_ent_v.tfn_for_super_flag%TYPE
     );

   TYPE spr_flag_table IS TABLE OF spr_flag_record INDEX BY BINARY_INTEGER;

   l_spr_flag_table             spr_flag_table;


   ----------------------------------------------------------------------------------
   -- Cursor to select the tax details feild values for the current reporting period.
   -- It selects
   --   1. All the employees who has the value of last_update_date segment of
   --      'Tax Information' element entry lying in the current reporting period range
   --   OR
   --   2. Employee who are terminated in the current reporting period.
   --   AND
   --   3. Employee who are not already reported with in the report period range.
   ----------------------------------------------------------------------------------

   /* Bug 2728358 - Added check for employee terminated on report end date */

  /*Bug2920725   Corrected base tables to support security model*/
  /* Bug 4514282 - Removed the view pay_au_tfn_tax_info_v*/

  /* bUG 4925794 - Modified the cursor added per_people_f and its relative joins */
  /* Bug#5864230 moved join  pee.entry_information_category = 'AU_TAX DEDUCTIONS' inside expression */

   CURSOR c_get_tfn_flag_values(c_business_group_id in per_business_groups.business_group_id%TYPE,
                                c_legal_employer_id in hr_soft_coding_keyflex.segment1%TYPE,
                                c_report_end_date   in date)
   IS
  SELECT  /*+ ORDERED */ pee.assignment_id
          ,decode(eev0.screen_entry_value,'YS','Y','YI','Y','YC','Y','NN','N','YN','Y','Y','Y','N','N',Null)
          , eev1.SCREEN_ENTRY_VALUE
          ,  DECODE(  eev3.screen_entry_value,
                      'N', 'N',
                      'Y', 'Y',
                      'NF','N',
                      'NP','N',
                      'NC','N',
                      'YF','Y',
                      'YP','Y',
                      'YC','Y',
                       'N'
           )
          , DECODE(  eev3.screen_entry_value,
                    'Y', 'X',
                'N', 'X',
                    'NF','F',
                    'NP','P',
                    'NC','C',
                    'YF','F',
                    'YP','P',
                    'YC','C',
                     'X')
          ,  decode(eev5.SCREEN_ENTRY_VALUE,'Y','Y','N','N','YY','Y','NY','N',Null)  hecs_flag
          ,  decode(eev5.SCREEN_ENTRY_VALUE,'YY','Y','NY','Y','N') SFSS_ENTRY_VALUE
          ,  to_char(fnd_date.canonical_to_date(eev6.SCREEN_ENTRY_VALUE),'ddmmyyyy')
          ,  decode(decode(eev8.SCREEN_ENTRY_VALUE,'Y','Y','N','N','YY','Y','NY','N','N'),'Y','Y',decode(eev4.SCREEN_ENTRY_VALUE,'Y','Y','N'))
          ,   eev13.SCREEN_ENTRY_VALUE
          ,   pee.effective_start_date
          ,  decode(sign(nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) - c_report_end_date),
                        1,null,pps.actual_termination_date) actual_termination_date
          , decode(eev0.screen_entry_value,'YS','Y','YI','Y','YC','Y','NN','N','YN','N','Y','N','N','N',Null) /*bug7270073*/
     FROM  per_people_f pap  /* Bug 4925794 */
          ,  per_all_assignments_f    paa,/*Bug 3012794*/
       hr_soft_coding_keyflex   hsc,
           per_periods_of_service   pps
       ,   pay_element_entries_f      pee
       ,   pay_element_types_f        pet
       ,   pay_input_values_f         piv0
       ,   pay_element_entry_values_f eev0
       ,   pay_input_values_f         piv1
       ,   pay_element_entry_values_f eev1
       ,   pay_input_values_f         piv3
       ,   pay_element_entry_values_f eev3
       ,   pay_input_values_f         piv4
       ,   pay_element_entry_values_f eev4
       ,   pay_input_values_f         piv5
       ,   pay_element_entry_values_f eev5
       ,   pay_input_values_f         piv6
       ,   pay_element_entry_values_f eev6
       ,   pay_input_values_f         piv8
       ,   pay_element_entry_values_f eev8
       ,   pay_input_values_f         piv13
       ,   pay_element_entry_values_f eev13
       ,   hr_lookups               hrl0
       ,   hr_lookups               hrl1
       ,   hr_lookups               hrl3
       ,   hr_lookups               hrl4
       ,   hr_lookups               hrl5
       ,   hr_lookups               hrl8
    WHERE pap.business_group_id=c_business_group_id
          and  paa.business_group_id        = pap.business_group_id
          and pap.person_id=paa.person_id
          and pps.person_id=paa.person_id
          and paa.period_of_service_id = pps.period_of_service_id
      AND  paa.soft_coding_keyflex_id   = hsc.soft_coding_keyflex_id
      AND  hsc.segment1                 = c_legal_employer_id
      AND  pee.assignment_id            = paa.assignment_id
      AND  pps.person_id                = paa.person_id
      AND  pps.date_start= (select max(pps1.date_start)
                                 from per_periods_of_service pps1
                                  where pps1.person_id=pps.person_id
                                  AND  pps1.date_start <= c_report_end_date
                           )  /*Bug2751008*/
      AND (   pee.entry_information_category = 'AU_TAX DEDUCTIONS' and
             (trunc(fnd_date.canonical_to_date(pee.entry_information1)) BETWEEN c_report_end_date - 13 AND c_report_end_date
            OR nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) BETWEEN c_report_end_date - 13 AND  c_report_end_date
            )
          )  /* Bug#5864230 */
      AND  paa.effective_start_date     = (SELECT max(effective_start_date)
                                             FROM per_assignments_f a
                                            WHERE a.assignment_id = paa.assignment_id)
       and pap.effective_start_date=(select max(effective_start_date)
                                    from per_people_f p
                    where p.person_id=pap.person_id)   --Bug 4925794
      AND  pee.effective_start_date    =
                 (SELECT  max(pee1.effective_start_date)
                    FROM  pay_element_types_f    pet1
                         ,pay_element_links_f    pel1
                         ,pay_element_entries_f  pee1
                   WHERE pet1.element_name     = 'Tax Information'
                 AND pet1.element_type_id  = pel1.element_type_id
                     AND pel1.element_link_id  = pee1.element_link_id
                     AND pee1.assignment_id    = paa.assignment_id
             AND pee1.entry_information1 is not null /*Bug 5356467*/
                     AND pee1.effective_start_date <= c_report_end_date
                     AND pel1.effective_start_date BETWEEN pet1.effective_start_date
                                                       AND pet1.effective_end_date
                  )
     and    pet.ELEMENT_NAME= 'Tax Information'
     and    pet.ELEMENT_TYPE_ID   = piv0.ELEMENT_TYPE_ID
     and    eev0.INPUT_VALUE_ID   = piv0.INPUT_VALUE_ID
     and    eev0.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and    (piv0.NAME)      = 'Australian Resident'
     and    hrl0.lookup_type  (+) = 'AU_AUST_RES_SENR_AUS'
     and    hrl0.lookup_code (+)  = eev0.SCREEN_ENTRY_VALUE
     and    hrl0.enabled_flag  (+)= 'Y'
     and    eev1.INPUT_VALUE_ID   = piv1.INPUT_VALUE_ID
     and    eev1.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and    piv1.ELEMENT_TYPE_ID  = pet.ELEMENT_TYPE_ID
     and    (piv1.NAME)      = 'Tax Free Threshold'
     and    hrl1.lookup_type  (+) = 'YES_NO'
     and    hrl1.lookup_code (+)  = eev1.SCREEN_ENTRY_VALUE
     and    hrl1.enabled_flag  (+)= 'Y'
     and    eev3.INPUT_VALUE_ID   = piv3.INPUT_VALUE_ID
     and    piv3.ELEMENT_TYPE_ID  = pet.ELEMENT_TYPE_ID
     and    eev3.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and    (piv3.NAME)      = 'FTA Claim'
     and    hrl3.lookup_type (+)  = 'HR_AU_FTA_PAYMENT_BASIS'
     and    hrl3.lookup_code  (+) = eev3.SCREEN_ENTRY_VALUE
     and    hrl3.enabled_flag (+) = 'Y'
     and    eev4.INPUT_VALUE_ID   = piv4.INPUT_VALUE_ID
     and    piv4.ELEMENT_TYPE_ID  = pet.ELEMENT_TYPE_ID
     and    eev4.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and    (piv4.NAME)      = 'Savings Rebate'
     and     hrl4.lookup_type(+)   = 'YES_NO'
     and     hrl4.lookup_code(+)   = eev4.SCREEN_ENTRY_VALUE
     and     hrl4.enabled_flag (+) = 'Y'
     and     eev5.INPUT_VALUE_ID   = piv5.INPUT_VALUE_ID
     and     piv5.ELEMENT_TYPE_ID  = pet.ELEMENT_TYPE_ID
     and     eev5.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and     (piv5.NAME)      = 'HECS'
     and     hrl5.lookup_type(+)   = 'AU_HECS_SFSS'
     and     hrl5.lookup_code (+)  = eev5.SCREEN_ENTRY_VALUE
     and     hrl5.enabled_flag (+) = 'Y'
     and     eev6.INPUT_VALUE_ID   = piv6.INPUT_VALUE_ID
     and     piv6.ELEMENT_TYPE_ID  = pet.ELEMENT_TYPE_ID
     and     eev6.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and     (piv6.NAME)      = 'Date Declaration Signed'
     and     eev8.INPUT_VALUE_ID   = piv8.INPUT_VALUE_ID
     and     piv8.ELEMENT_TYPE_ID  = pet.ELEMENT_TYPE_ID
     and     eev8.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
     and     (piv8.NAME)      = 'Spouse'
     and     hrl8.lookup_type  (+) = 'AU_SPOUSE_MLS'
     and     hrl8.lookup_code (+)  = eev8.SCREEN_ENTRY_VALUE
     and     hrl8.enabled_flag (+) = 'Y'
     and     eev13.INPUT_VALUE_ID  = piv13.INPUT_VALUE_ID
     and     piv13.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
     and     eev13.ELEMENT_ENTRY_ID= pee.ELEMENT_ENTRY_ID
     and    (piv13.NAME )    = 'Tax File Number'
     and     pee.effective_start_date between pet.EFFECTIVE_START_DATE and pet.EFFECTIVE_END_DATE
     and     eev0.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev1.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev3.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev4.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev5.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev6.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev8.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev13.effective_start_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
     and     eev0.effective_start_date between piv0.EFFECTIVE_START_DATE and piv0.EFFECTIVE_END_DATE
     and     eev1.effective_start_date between piv1.EFFECTIVE_START_DATE and piv1.EFFECTIVE_END_DATE
     and     eev3.effective_start_date between piv3.EFFECTIVE_START_DATE and piv3.EFFECTIVE_END_DATE
     and     eev4.effective_start_date between piv4.EFFECTIVE_START_DATE and piv4.EFFECTIVE_END_DATE
     and     eev5.effective_start_date between piv5.EFFECTIVE_START_DATE and piv5.EFFECTIVE_END_DATE
     and     eev6.effective_start_date between piv6.EFFECTIVE_START_DATE and piv6.EFFECTIVE_END_DATE
     and     eev8.effective_start_date between piv8.EFFECTIVE_START_DATE and piv8.EFFECTIVE_END_DATE
     and     eev13.effective_start_date between piv13.EFFECTIVE_START_DATE and piv13.EFFECTIVE_END_DATE
     ;




   ----------------------------------------------------------------------------------
   -- Cursor to select the tax details(tfn for superannuation flag) field's value for
   -- all the employees for whom the element entry for 'Superannuation Gurantee information'
   -- element exists.
   ----------------------------------------------------------------------------------

  /*Bug2920725   Corrected base tables to support security model*/

   CURSOR  c_get_tfn_super_flag_value(c_business_group_id in per_business_groups.business_group_id%TYPE,
                                      c_legal_employer_id in hr_soft_coding_keyflex.segment1%TYPE,
                                      c_report_end_date   in date,
                                      c_assignment_id per_assignments_f.assignment_id%TYPE ) IS
   SELECT  pee.assignment_id
          ,pev.screen_entry_value tfn_for_super_flag
     FROM  per_assignments_f      paa,
           hr_soft_coding_keyflex     hsc,
           pay_element_entry_values_f pev,
           pay_input_values_f         piv,
           pay_element_types_f        pet,
           pay_element_entries_f      pee,
           hr_lookups                 hrl0
    WHERE  pet.element_name            = 'Superannuation Guarantee Information'
      AND  pet.element_type_id         = piv.element_type_id
      AND  pev.input_value_id          = piv.input_value_id
      AND  pev.element_entry_id        = pee.element_entry_id
      AND  piv.name                    = 'TFN for Superannuation'
      AND  pee.assignment_id           = c_assignment_id /*bug8634876*/
      AND  paa.assignment_id           = pee.assignment_id
      AND  paa.business_group_id       = c_business_group_id
      AND  paa.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
      AND  hsc.segment1                = c_legal_employer_id
      AND  hrl0.lookup_type  (+)       = 'YES_NO'
      AND  hrl0.lookup_code (+)        = pev.screen_entry_value
      AND  hrl0.enabled_flag  (+)      = 'Y'
      AND  pee.effective_start_date    = (SELECT max(pee1.effective_start_date)
                                            FROM pay_element_entries_f  pee1
                                           WHERE pee1.element_entry_id = pee.element_entry_id
                       AND pee1.effective_start_date <= c_report_end_date
                                         )
      AND  paa.effective_start_date    = (SELECT max(effective_start_date)
                                            FROM per_assignments_f a
                                           WHERE a.assignment_id = paa.assignment_id
                                         )
      AND  pev.effective_start_date    = (SELECT max(pev1.effective_start_date)
                                            FROM pay_element_entry_values_f  pev1
                                           WHERE pev1.element_entry_value_id = pev.element_entry_value_id
                                             AND pev1.effective_start_date <= c_report_end_date
                                         )
      AND  c_report_end_date BETWEEN pet.effective_start_date AND pet.effective_end_date
      AND  c_report_end_date BETWEEN piv.effective_start_date AND piv.effective_end_date;

   l_assignment_id                per_all_assignments_f.assignment_id%TYPE;
   l_australian_res_flag          pay_au_tfn_tax_info_v.australian_resident_flag%TYPE;
   l_tax_free_threshold_flag      pay_au_tfn_tax_info_v.tax_free_threshold_flag%TYPE;
   l_fta_claim_flag               pay_au_tfn_tax_info_v.fta_claim_flag%TYPE;
   l_basis_of_payment             pay_au_tfn_tax_info_v.basis_of_payment%TYPE;
   l_hecs_flag                    pay_au_tfn_tax_info_v.hecs_flag%TYPE;
   l_sfss_flag                    pay_au_tfn_tax_info_v.sfss_flag%TYPE;
   l_declaration_signed_date      pay_au_tfn_tax_info_v.declaration_signed_date%TYPE;
   l_rebate_flag                  pay_au_tfn_tax_info_v.rebate_flag%TYPE;
   l_tax_file_number              pay_au_tfn_tax_info_v.tax_file_number%TYPE;
   l_effective_start_date         pay_au_tfn_tax_info_v.effective_start_date%TYPE;
   l_actual_termination_date      per_periods_of_service.actual_termination_date%TYPE;
   l_current_or_terminated        varchar2(1);
   l_tfn_for_super                pay_payautax_spr_ent_v.tfn_for_super_flag%TYPE;
   l_senior_flag                  pay_au_tfn_tax_info_v.australian_resident_flag%TYPE; /*bug7270073*/
   l_super_assignment_id      per_all_assignments_f.assignment_id%TYPE;

BEGIN

   hr_utility.trace('Start of populate_tfn_flags procedure');

   hr_utility.trace('l_business_group_id  : ' || to_char(p_business_group_id));
   hr_utility.trace('l_legal_employer_id  : ' || p_legal_employer_id);
   hr_utility.trace('l_report_end_date    : ' || to_char(p_report_end_date, 'DD-MON-YYYY') );



   -- Get the values of Tax Information reportable fields and
   -- pupolate values into global table.

   hr_utility.trace('Opening cursor c_get_tfn_flag_values');
   OPEN c_get_tfn_flag_values(p_business_group_id,
                              p_legal_employer_id,
                              p_report_end_date  );
   LOOP
     FETCH c_get_tfn_flag_values INTO
                                  l_assignment_id           ,
                                  l_australian_res_flag     ,
                                  l_tax_free_threshold_flag ,
                                  l_fta_claim_flag          ,
                                  l_basis_of_payment        ,
                                  l_hecs_flag               ,
                                  l_sfss_flag               ,
                                  l_declaration_signed_date ,
                                  l_rebate_flag             ,
                                  l_tax_file_number         ,
                                  l_effective_start_date    ,
                                  l_actual_termination_date ,
                                  l_senior_flag ; /*bug7270073*/
     EXIT WHEN c_get_tfn_flag_values%NOTFOUND;

     -- Employee with tax file number '111 111 111' who is not terminated
     -- in the current report is not eligible to be printed on magtape

     IF (l_tax_file_number = '111 111 111' AND nvl(l_actual_termination_date,p_report_end_date + 1)
                                   NOT BETWEEN (p_report_end_date - 13) AND p_report_end_date) THEN
       hr_utility.trace('Employee is not eligible for magtape');

     ELSE
       hr_utility.trace('Value stored for assignment id : ' || to_char(l_assignment_id));

       -- populate the global table
       g_tfn_flags_table(l_assignment_id).k_assignment_id          := l_assignment_id          ;
       g_tfn_flags_table(l_assignment_id).australian_res_flag      := l_australian_res_flag    ;
       g_tfn_flags_table(l_assignment_id).tax_free_threshold_flag  := l_tax_free_threshold_flag;
       g_tfn_flags_table(l_assignment_id).fta_claim_flag           := l_fta_claim_flag         ;
       g_tfn_flags_table(l_assignment_id).basis_of_payment         := l_basis_of_payment       ;
       g_tfn_flags_table(l_assignment_id).hecs_flag                := l_hecs_flag              ;
       g_tfn_flags_table(l_assignment_id).sfss_flag                := l_sfss_flag              ;
       g_tfn_flags_table(l_assignment_id).declaration_signed_date  := l_declaration_signed_date;
       g_tfn_flags_table(l_assignment_id).rebate_flag              := l_rebate_flag            ;
       g_tfn_flags_table(l_assignment_id).tax_file_number          := l_tax_file_number        ;
       g_tfn_flags_table(l_assignment_id).effective_start_date     := l_effective_start_date   ;
       g_tfn_flags_table(l_assignment_id).senior_flag              := l_senior_flag            ; /*bug7270073*/

       -- Store 'T' as 'current_or_terminated' if the employee is terminated in the current period
       -- Other wise store 'C'

       IF nvl(l_actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) BETWEEN (p_report_end_date - 13)
                                                                                  AND p_report_end_date THEN
          g_tfn_flags_table(l_assignment_id).current_or_terminated := 'T';
       ELSE
          g_tfn_flags_table(l_assignment_id).current_or_terminated := 'C';
       END IF;


     END IF;
   END LOOP;
   hr_utility.trace('closing cursor c_get_tfn_flag_values');
   CLOSE c_get_tfn_flag_values;


   /* bug8634876
      Populate all the eligible assignments populated in the global plsql table
      with the proper value of the 'TFN for Super' flag.
   */

   hr_utility.trace('Populating the supernnuation flag in the global table');

   IF g_tfn_flags_table.count > 0 THEN
    for l_assignment_id in g_tfn_flags_table.first..g_tfn_flags_table.last
    LOOP
     IF g_tfn_flags_table.exists(l_assignment_id) THEN
         OPEN c_get_tfn_super_flag_value(p_business_group_id,
                                   p_legal_employer_id,
                                   p_report_end_date,
                                   g_tfn_flags_table(l_assignment_id).k_assignment_id);

         FETCH c_get_tfn_super_flag_value INTO
                                     l_super_assignment_id,
                                     l_tfn_for_super;

              IF c_get_tfn_super_flag_value%FOUND THEN
                 g_tfn_flags_table(l_assignment_id).tfn_for_super :=l_tfn_for_super;
              ELSE
                 g_tfn_flags_table(l_assignment_id).tfn_for_super := 'N';
              END IF;

         CLOSE c_get_tfn_super_flag_value;
      END IF;
    END LOOP;
   END IF;

   hr_utility.trace('End of populate_tfn_flags procedure');

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.trace('Error in populate_tfn_flags');
      RAISE;

END populate_tfn_flags;




------------------------------------------------------------------------------+
-- This funciton returns the value of the tax detail fields depending on
-- the input provided.
-- It uses the plsql table, searches the assignment_id and returns the value
-- of the flag that is passed as the parameter.
------------------------------------------------------------------------------+

FUNCTION get_tfn_flag_values(p_assignment_id in per_all_assignments_f.assignment_id%TYPE,
                             p_flag_name     in varchar2) RETURN varchar2 IS
BEGIN

   hr_utility.trace('Start of get_tfn_flag_values function');
   hr_utility.trace('Passed p_assignment_id : ' || to_char(p_assignment_id));

   -- Check IF assignment exists in the plsql table of tax details values.
   IF g_tfn_flags_table.exists(p_assignment_id) THEN

     -- Return value of the tax detail field for the employee
     hr_utility.trace('The value of the assignment_id passed : ' || to_char(g_tfn_flags_table(p_assignment_id).k_assignment_id));
     -- Bug 2728374 : Corrected basis of payment string
     IF p_flag_name = 'AUSTRALIAN_RESIDENT_FLAG' THEN
        RETURN g_tfn_flags_table(p_assignment_id).australian_res_flag;

        ELSIF p_flag_name = 'TAX_FREE_THRESHOLD_FLAG' THEN
              RETURN g_tfn_flags_table(p_assignment_id).tax_free_threshold_flag;

        ELSIF p_flag_name = 'FTA_CLAIM_FLAG' THEN
              RETURN g_tfn_flags_table(p_assignment_id).fta_claim_flag;

        ELSIF p_flag_name = 'BASIS_OF_PAYMENT' THEN
              RETURN g_tfn_flags_table(p_assignment_id).basis_of_payment;

        ELSIF p_flag_name = 'HECS_FLAG' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).hecs_flag;

        ELSIF p_flag_name = 'SFSS_FLAG' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).sfss_flag;

        ELSIF p_flag_name = 'DECLARATION_SIGNED_DATE' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).declaration_signed_date;

        ELSIF p_flag_name = 'REBATE_FLAG' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).rebate_flag;

        ELSIF p_flag_name = 'TAX_FILE_NUMBER' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).tax_file_number;

        ELSIF p_flag_name = 'EFFECTIVE_START_DATE' THEN
              RETURN  to_char(g_tfn_flags_table(p_assignment_id).effective_start_date,'DD-MON-YYYY');

        ELSIF p_flag_name = 'CURRENT_OR_TERMINATED' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).current_or_terminated;

        ELSIF p_flag_name = 'TFN_FOR_SUPER' THEN
              RETURN  g_tfn_flags_table(p_assignment_id).tfn_for_super;

        ELSIF p_flag_name = 'SENIOR_FLAG' THEN /*bug7270073*/
              RETURN  g_tfn_flags_table(p_assignment_id).senior_flag;
     ELSE
        RETURN 'N';
     END IF;

   ELSE
     RETURN 'N';
   END IF;

   hr_utility.trace('End of get_tfn_flag_values function');

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.trace('Error in get_tfn_flag_values');
      RAISE;
END get_tfn_flag_values;

------------------------------------------------------------------------------+
-- 9000052 - Used to remove more than one spaces between words in the string
--           This function ensures that every word in the string passed is
--           seperated by exactly 1 space.
-----------------------------------------------------------------------------+
/* Changes for bug 9000052 start */
FUNCTION remove_extra_spaces(p_str in varchar2) return varchar2 IS
l_already_found boolean;
l_return varchar2(1000);
BEGIN
l_return := null;
l_already_found := false;

if p_str is null or p_str = '' then
    return l_return;
end if;

    for i in 1..length(p_str) loop
         if substr(p_str,i,1) = ' ' then
             if NOT l_already_found  then
               l_return := l_return||' ';
               l_already_found := true;
	         end if;
         else
	       if l_already_found then
	          l_already_found := false;
           end if;
               l_return := l_return||substr(p_str,i,1);
         end if;
    end loop;

return l_return;

END;
/* Changes for bug 9000052 end */

END pay_au_tfn_magtape_flags;

/
