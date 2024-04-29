--------------------------------------------------------
--  DDL for Package Body PAY_CREATE_ELEMNT_TMPLT_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CREATE_ELEMNT_TMPLT_RECORD" as
/* $Header: paycreatetemplte.pkb 120.7 2005/06/24 13:49 pganguly noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2005 Oracle Corporation UK Ltd.,                *
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

   Name        : pay_create_elemnt_tmplt_record

   Description : This procedure is used to create element template
                 records for a specific legislation.

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ -------- -----------------------------------
   24-JUN-2005 pganguly   115.8           Changed the Extra Element info DDF
                                          dbi name to DEDUCTION_PROCESSING.
   22-JUN-2005 pganguly   115.7           Changed the PCT_DEDN formula to use
                                          insuff_funds_type from insuff_fund
                                          _type. Also changed the deduction
                                          formula to use TOTAL_PAYMENTS_ASG
                                          _RUN from TOTAL_PAYMENTS_PAYMENT.
   21-JUN-2005 pganguly   115.6  4428404  While creating Eligible Comp Balance
                                          for PCT_EARN elements, removed the
                                          Pay Value association.
   19-JUN-2005 pganguly   115.5  4431196  Special Feature elements are created
                                          with 'Information' classification.
                                          Also changed the Template Type of
                                          Direct Payments, Employer Charges
                                          from Deductions to Earnings.
   16-JUN-2005 pganguly   115.4  4419843  Changed the Hours X Rate, Percent of
                                 4428404  Earnings formula to incorporate
                                          get_hourly_rate function.
   15-JUN-2005 pganguly   115.3  4434071  Removed to_char while printing
                                          classification name.
   10-JUN-2005 pganguly   115.2           Changed the Hours X Rate formula to
                                          call the hours function.
                                 4426654  Added p_currency_code parameter in
                                          the earnings template, this is passed
                                          while creating elements/balances.
   19-MAY-2005 pganguly   115.1           Changed the messages names in Hours
                                          X rate formula.
   19-MAY-2005 mmukherj   115.0           Initial Version

*/

  FUNCTION  get_classification_id( p_classification_name IN VARCHAR2,
                                   p_legislation_code in varchar2 )
  RETURN NUMBER IS

    CURSOR get_class_id( cp_classification_name VARCHAR2 ) IS
      SELECT classification_id
      FROM   pay_element_classifications
      WHERE  legislation_code     = p_legislation_code
      AND    classification_name  = cp_classification_name;

    l_classification_id NUMBER;

  BEGIN -- get_classification_id

    OPEN  get_class_id( p_classification_name );
    FETCH get_class_id  INTO l_classification_id;
    CLOSE get_class_id;

    RETURN l_classification_id;

  END get_classification_id;

procedure create_elemnt_tmplt_usages(p_template_id in NUMBER,
                                     p_classification_type in VARCHAR2,
                                     p_legislation_code in varchar2) is

BEGIN

DECLARE

    TYPE char_tabtype IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    l_classification_name char_tabtype;
    l_display_proc_mode   char_tabtype;
    l_display_arrearage   char_tabtype;

    l_classification_id   NUMBER;
    ln_exists             NUMBER;
    ln_ele_tmplt_class_id NUMBER;

BEGIN

   IF p_classification_type = 'Earnings' THEN

       l_classification_name(1) := 'Earnings';
       l_display_proc_mode(1)   := 'Y';
       l_display_arrearage(1)   := NULL;

       l_classification_name(2) := 'Supplemental Earnings';
       l_display_proc_mode(2)   := 'Y';
       l_display_arrearage(2)   := NULL;

       l_classification_name(3) := 'Taxable Benefits';
       l_display_proc_mode(3)   := 'Y';
       l_display_arrearage(3)   := NULL;

       l_classification_name(4) := 'Absence';
       l_display_proc_mode(4)   := 'Y';
       l_display_arrearage(4)   := NULL;

       l_classification_name(5) := 'Direct Payment';
       l_display_proc_mode(5)   := NULL;
       l_display_arrearage(5)   := 'Y';

       l_classification_name(6) := 'Employer Charges';
       l_display_proc_mode(6)   := NULL;
       l_display_arrearage(6)   := 'Y';

     ELSIF p_classification_type = 'Deductions' THEN

       l_classification_name(1) := 'Voluntary Deductions';
       l_display_proc_mode(1)   := NULL;
       l_display_arrearage(1)   := 'Y';

       l_classification_name(2) := 'Pre-Tax Deductions';
       l_display_proc_mode(2)   := NULL;
       l_display_arrearage(2)   := 'Y';

       l_classification_name(3) := 'Involuntary Deductions';
       l_display_proc_mode(3)   := NULL;
       l_display_arrearage(3)   := 'Y';

       l_classification_name(4) := 'Tax Deductions';
       l_display_proc_mode(4)   := NULL;
       l_display_arrearage(4)   := 'Y';

  END IF;

  FOR i IN l_classification_name.FIRST .. l_classification_name.LAST LOOP

    hr_utility.trace('l_classification_name = ' || l_classification_name(i));
    l_classification_id := get_classification_id(l_classification_name(i),p_legislation_code);

   SELECT COUNT(*)
    INTO   ln_exists
    FROM   pay_ele_tmplt_class_usages
    WHERE  classification_id = l_classification_id
    AND    template_id       = p_template_id;

    hr_utility.trace('ln_exists = ' || to_char(ln_exists));

    IF ln_exists = 0 THEN

       SELECT pay_ele_tmplt_class_usg_s.nextval
       INTO   ln_ele_tmplt_class_id
       FROM   dual;

       hr_utility.trace('ln_ele_tmplt_class_id ' ||ln_ele_tmplt_class_id);

       INSERT INTO pay_ele_tmplt_class_usages
                 ( ele_template_classification_id
                  ,classification_id
                  ,template_id
                  ,display_process_mode
                  ,display_arrearage )
        VALUES   ( ln_ele_tmplt_class_id
                  ,l_classification_id
                  ,p_template_id
                  ,l_display_proc_mode(i)
                  ,l_display_arrearage(i));

    END IF;

    END LOOP;

END;

END create_elemnt_tmplt_usages;

procedure create_dedn_flat_amt_templ( p_legislation_code in varchar2,
                                      p_currency_code in varchar2) IS
begin

declare
  l_effective_date              date;
--
  l_template_exists             Char;
--
  l_template_id                 number;
  l_object_version_number       number;
--
  l_special_inputs_element_id   number;
  l_base_element_id             number;
  l_special_features_element_id number;
--
  l_formula_id                  number;
  l_formula_text                varchar2(32000);
  l_formula_name                varchar2(80);
  l_formula_desc                varchar2(240);
--
  l_primary_bal_typ_id          number;
  l_accrued_bal_typ_id          number;
  l_not_taken_bal_typ_id        number;
  l_arrears_bal_typ_id          number;
--
  l_input_value_id              number;
  l_base_pay_value_id           number;
  l_base_amount_id              number;
  l_clear_arr_iv_id             number;
  l_total_owed_iv_id            number;
  l_sf_pay_value_id             number;
  l_sf_accrued_value_id         number;
  l_sf_not_taken_value_id       number;
  l_sf_arrears_contr_value_id   number;
--
  l_defined_balance_id          number;
--
  l_balance_feed_id             number;
--
  l_reg_tax_proc_type           number;
  l_non_per_tax_proc_type       number;
  l_arrearage_rule_id           number;
  l_stop_rule_id                number;
  l_start_rule_id               number;
--
  l_id                          number;
  l_element_type_usage_id       number;
  l_balance_attribute_id        number;

  duplicate_template            exception;
  l_enabled_flag                varchar2(4);


begin

  --hr_utility.trace_on (null,'FLATAMTDEDN');


   /*  Check for Template Existence */

   BEGIN
      SELECT 'Y', Template_id
      INTO   l_template_exists, l_template_id
      FROM   pay_element_templates
      WHERE  Template_type = 'T'
      AND    Legislation_code = p_legislation_code
      AND    template_name = 'Flat Amount Deduction';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_template_exists := 'N';
   END;

   IF (l_template_exists = 'Y')
   THEN
      BEGIN
         delete from PAY_ELE_TMPLT_CLASS_USAGES
         where template_id = l_template_id;

         pay_element_template_api.delete_user_structure(false,true,
                                                        l_template_id);
         l_template_exists := 'N';
         EXCEPTION
         WHEN OTHERS THEN
           l_template_exists := 'N';
           NULL;
      END;
   END IF;

/*  End of Check */

   IF l_template_exists = 'N'
   THEN

        l_effective_date := to_date('1901/01/01', 'YYYY/MM/DD');

        --
        --  PAY_ELEMENT_TEMPLATES row.
        --
        pay_etm_ins.ins
        (p_template_id               => l_template_id
        ,p_effective_date            => l_effective_date
        ,p_template_type             => 'T'
        ,p_template_name             => 'Flat Amount Deduction'
        ,p_base_processing_priority  => 3750
        ,p_max_base_name_length      => 40
        ,p_version_number            => 1
        ,p_legislation_code          => p_legislation_code
        ,p_object_version_number     => l_object_version_number
        );


        --
        -- Formula.
        --

        l_formula_name  := '_FLAT_AMOUNT_DEDN';
        l_formula_desc  := 'Flat Amount formula for Deduction Template';

        l_formula_text :=
'/*****************************************************************************

FORMULA NAME: _FLAT_AMOUNT_DEDN

FORMULA TYPE: Payroll

DESCRIPTION:  Formula for Flat Amount for Deduction Template.
                           Returns pay value (Amount);

*******************************************************************************

FORMULA TEXT

Formula Results :

 dedn_amt        Direct Result for Deduction Amount
 not_taken       Update Deduction Recurring Entry Not Taken
 to_arrears      Update Deduction Recurring Entry Arrears Contr
 set_clear       Update Deduction Recurring Entry Clear Arrears
 STOP_ENTRY      Stop current recurring entry
 to_total_owed   Update Deduction Recurring Entry Accrued
 mesg            Message (Warning)

*******************************************************************************/


/* Database Item Defaults */

default for INSUFFICIENT_FUNDS_TYPE             is ''NOT ENTERED''

/* ===== Database Item Defaults End ===== */

/* ===== Input Value Defaults Begin ===== */

default for Total_Owed                          is 0
default for Clear_Arrears (text)                is ''N''
default for Amount                              is 0
default for EXTRA_ELEMENT_INFO_DDF_DEDUCTION_PROCESSING_INSUFFICIENT_FUNDS_TYPE is ''NOT ENTERED''

/* ===== Input Value Defaults End ===== */

DEFAULT FOR mesg                           is ''NOT ENTERED''


/* ===== Inputs Section Begin ===== */

INPUTS ARE
         Amount
        ,Total_Owed
        ,Clear_Arrears (text)

/* ===== Inputs Section End ===== */

dedn_amt          = Amount
to_total_owed     = 0
to_arrears        = 0
to_not_taken      = 0
total_dedn        = 0
insuff_funds_type = EXTRA_ELEMENT_INFO_DDF_DEDUCTION_PROCESSING_INSUFFICIENT_FUNDS_TYPE
net_amount        = TOTAL_PAYMENTS_ASG_RUN

/* ====  Entry ITD Check Begin ==== */

   IF ( <BASE NAME>_ACCRUED_ENTRY_ITD = 0 AND
        <BASE NAME>_ACCRUED_ASG_ITD <> 0 ) THEN
   (
      to_total_owed = -1 * <BASE NAME>_ACCRUED_ASG_ITD + dedn_amt
   )

   IF ( <BASE NAME>_ARREARS_ENTRY_ITD = 0 AND
        <BASE NAME>_ARREARS_ASG_ITD <> 0 ) THEN
   (
      to_arrears = -1 * <BASE NAME>_ARREARS_ASG_ITD
   )

/* ====  Entry ITD Check End ==== */

/* ===== Arrears Section Begin ===== */

   IF Clear_Arrears = ''Y'' THEN
   (
      to_arrears = -1 * <BASE NAME>_ARREARS_ASG_ITD
      set_clear = ''No''
   )

IF insuff_funds_type = ''PD'' THEN /* Partial Deduction */
(
  IF ( net_amount - dedn_amt >= 0 ) THEN
  (
    to_arrears   = 0
    to_not_taken = 0
    dedn_amt     = dedn_amt
  )
 ELSE
 (
   to_arrears   = 0
   to_not_taken = dedn_amt - net_amount
   dedn_amt     = net_amount
  )
)
ELSE IF insuff_funds_type = ''APD'' THEN /*Arrearage and Partial Deduction */
(
  IF ( net_amount <= 0 ) THEN
  (
      to_arrears   = dedn_amt
      to_not_taken = dedn_amt
      dedn_amt     = 0
  )
  ELSE
  (
     total_dedn = dedn_amt + <BASE NAME>_ARREARS_ASG_ITD
     IF ( net_amount >= total_dedn ) THEN
     (
            to_arrears   = -1 * <BASE NAME>_ARREARS_ASG_ITD
            to_not_taken = 0
            dedn_amt     = total_dedn
     )
     ELSE
     (
       to_arrears   = total_dedn - net_amount
       to_arrears   = to_arrears - <BASE NAME>_ARREARS_ASG_ITD
       IF ( net_amount >= dedn_amt ) THEN
       (
         to_not_taken = 0
         dedn_amt     = net_amount
       )
       ELSE
       (
         to_not_taken = to_arrears
        dedn_amt     = net_amount
       )
     )
  )
)

ELSE IF insuff_funds_type = ''A''  THEN /* Arrearage */
(
   IF ( net_amount <= 0 ) THEN
   (
      to_arrears   = dedn_amt
      to_not_taken = dedn_amt
      dedn_amt     = 0
   )
   ELSE
  (
     total_dedn = dedn_amt + <BASE NAME>_ARREARS_ASG_ITD
     IF ( net_amount >= total_dedn ) THEN
     (
            to_arrears   = -1 * <BASE NAME>_ARREARS_ASG_ITD
            to_not_taken = 0
            dedn_amt     = total_dedn
     )
     ELSE
     (
        IF ( net_amount >= dedn_amt ) THEN
        (
           to_arrears   = 0
           to_not_taken = 0
          dedn_amt     = dedn_amt
        )
       ELSE
       (
         to_arrears   = dedn_amt
         to_not_taken = dedn_amt
         dedn_amt     = 0
       )
     )
  )
)
ELSE IF insuff_funds_type = ''NONE''  THEN /* No Arrearage and No Partial Deduction */
(
  IF ( net_amount - dedn_amt >= 0 ) THEN
  (
    to_arrears   = 0
    to_not_taken = 0
    dedn_amt     = dedn_amt
  )
 ELSE
 (
   to_arrears   = 0
   to_not_taken = 0
   dedn_amt     = 0
  )
)
ELSE /*Error */
(
     IF ( net_amount - dedn_amt < 0 ) THEN
     (
         mesg = GET_MESG(''PAY'',''PAY_INSUFF_FUNDS_FOR_DED'')
         RETURN mesg
    )
)


/* ===== Arrears Section End ===== */

/* ===== Stop Rule Section Begin ===== */

   to_total_owed = dedn_amt

   IF Total_Owed WAS NOT DEFAULTED THEN
   (
      total_accrued  = dedn_amt + <BASE NAME>_ACCRUED_ASG_ITD

      IF total_accrued  >= Total_Owed THEN
      (
         dedn_amt = Total_Owed - <BASE NAME>_ACCRUED_ASG_ITD

          /* The total has been reached - the return will stop the entry under
             these conditions.  Also, zero out Accrued balance.  */

          to_total_owed = -1 * <BASE NAME>_ACCRUED_ASG_ITD
          STOP_ENTRY = ''Y''

          mesg = GET_MESG(''PAY'',''PAY_STOPPED_ENTRY'',
                                  ''BASE_NAME'',''<BASE NAME>'')
       )
   )

/* ===== Stop Rule Section End ===== */

   RETURN dedn_amt,
          to_not_taken,
          to_arrears,
          to_total_owed,
          STOP_ENTRY,
          set_clear,
          mesg

/* End Formula Text */';

        pay_sf_ins.ins
        (p_formula_id                => l_formula_id
        ,p_template_type             => 'T'
        ,p_legislation_code          => p_legislation_code
        ,p_formula_name              => l_formula_name
        ,p_description               => l_formula_desc
        ,p_formula_text              => l_formula_text
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date
        );

       --
       -- End Formula
       --

       --
       -- 'Base' element.
       --

       /* Classification Name would be Voluntary Deductions since we donot
          have Deduction Classification. */

       pay_set_ins.ins
       (p_element_type_id              => l_base_element_id
       ,p_template_id                  => l_template_id
       ,p_element_name                 => null
       ,p_reporting_name               => null
       ,p_relative_processing_priority => 0
       ,p_processing_type              => 'N'
       ,p_classification_name          => 'Voluntary Deductions'
       ,p_input_currency_code          => p_currency_code
       ,p_output_currency_code         => p_currency_code
       ,p_multiple_entries_allowed_fla => 'N'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => NULL
       ,p_payroll_formula_id           => l_formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Base Element Created');

       --
       -- 'Special Features' element.
       --

       pay_set_ins.ins
       (p_element_type_id                    => l_special_features_element_id
       ,p_template_id                        => l_template_id
       ,p_element_name                       => ' Special Features'
       ,p_reporting_name                     => ' SF'
       ,p_relative_processing_priority       => 50
       ,p_processing_type                    => 'N'
       ,p_classification_name                => 'Information'
       ,p_input_currency_code                => p_currency_code
       ,p_output_currency_code               => p_currency_code
       ,p_multiple_entries_allowed_fla       => 'N'
       ,p_post_termination_rule              => 'F'
       ,p_process_in_run_flag                => 'Y'
       ,p_additional_entry_allowed_fla       => 'N'
       ,p_adjustment_only_flag               => 'N'
       ,p_closed_for_entry_flag              => 'N'
       ,p_indirect_only_flag                 => 'N'
       ,p_multiply_value_flag                => 'N'
       ,p_standard_link_flag                 => 'N'
       ,p_object_version_number              => l_object_version_number
       ,p_effective_date                     => l_effective_date
       );

       hr_utility.trace('Special Features Element Created');

       --
       -- Input Values for 'Base' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_base_pay_value_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Pay Value Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_amount_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Amount'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Amount Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_clear_arr_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 3
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N' /* user-enterable. */
       ,p_name                         => 'Clear Arrears'
       ,p_uom                          => 'C'
       ,p_lookup_type                  => 'YES_NO'
       ,p_default_value                => 'N'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Clear Arrears Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_total_owed_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 4
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N' /* user-enterable. */
       ,p_name                         => 'Total Owed'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Total Owed Created');


       --
       -- Input Values for 'Special Features' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_pay_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Pay Value for Special Features Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_accrued_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Accrued'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Accrued Input Value for Special Features Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_not_taken_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 3
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Not Taken'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Not Taken Input Value for Special Features Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_arrears_contr_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 4
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Arrears Contr'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Arrears Contr Input Value for Spec Features Created');

       --
       -- Primary balance types.
       --

       pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => null
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => null
       ,p_comments                     =>
                  'Primary balance for Flat Amount Deductions.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Deductions'
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Primary Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_accrued_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Accrued'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Accrued'
       ,p_comments                     =>
                  'Accrued balance for Flat Amount Deductions.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       hr_utility.trace('Accrued Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_arrears_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Arrears'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Arrears'
       ,p_comments                     =>
                  'Arrears balance for Flat Amount Deductions.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Arrears Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Not Taken'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Not Taken'
       ,p_comments                     =>
                  'Not Taken balance for Flat Amount Deductions.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Not Taken Balance Type Created.');

       --
       -- Balance Feeds.
       --

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Pay Value to Primary Bal Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_input_value_id               => l_sf_accrued_value_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Accrued to Accrued Bal Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_input_value_id               => l_sf_not_taken_value_id
       ,p_scale                        => 1
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Not Taken to Not Taken Bal Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_input_value_id               => l_sf_arrears_contr_value_id
       ,p_scale                        => 1
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Arrears Contr to Arrears Bal Created.');

       --
       -- Formula rules.
       --

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'dedn_amt'
       ,p_result_rule_type             => 'D'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - dedn_amt created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'STOP_ENTRY'
       ,p_result_rule_type             => 'S'
       ,p_element_type_id              => l_base_element_id
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - STOP_ENTRY created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'set_clear'
       ,p_result_rule_type             => 'U'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_clear_arr_iv_id
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - set_clear created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'mesg'
       ,p_result_rule_type             => 'M'
       ,p_severity_level               => 'W'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - mesg created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'to_not_taken'
       ,p_result_rule_type             => 'I'
       ,p_element_type_id              => l_special_features_element_id
       ,p_input_value_id               => l_sf_not_taken_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - to_not_taken created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'to_total_owed'
       ,p_result_rule_type             => 'I'
       ,p_element_type_id              => l_special_features_element_id
       ,p_input_value_id               => l_sf_accrued_value_id
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - to_total_owed created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'to_arrears'
       ,p_result_rule_type             => 'I'
       ,p_element_type_id              => l_special_features_element_id
       ,p_input_value_id               => l_sf_arrears_contr_value_id
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - to_arrears created.');

       --
       -- Defined Balances for Base Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                     'Assignment Calendar Year to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               => 'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Accrued Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                        'Element Entry Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               => 'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Arrears Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               =>
                        'Element Entry Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               => 'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Not Taken Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_create_elemnt_tmplt_record.create_elemnt_tmplt_usages(
         l_template_id,
         'Deductions',
         p_legislation_code);

  END IF;


END;

end create_dedn_flat_amt_templ;

procedure create_earn_flat_amt_templ( p_legislation_code IN VARCHAR2,
                                      p_currency_code    IN VARCHAR2) IS
begin
declare
  l_effective_date              date;
--
  l_template_exists	        Char;
--
  l_template_id                 number;
  l_object_version_number       number;
--
  l_special_inputs_element_id   number;
  l_base_element_id             number;
  l_special_features_element_id number;
--
  l_formula_id                  number;
  l_formula_text                varchar2(32000);
--
  l_primary_balance_id          number;
  l_replacement_balance_id      number;
  l_additional_balance_id       number;
  l_neg_earn_balance_id         number;
  l_el_balance_id               number;
--
  l_input_value_id              number;
  l_base_pay_value_id           number;
  l_base_amount_id              number;
  l_base_sep_pay_id             number;
  l_base_proc_sep_id            number;
--
  l_defined_balance_id          number;
--
  l_balance_feed_id             number;
--
  l_reg_tax_proc_type           number;
  l_non_per_tax_proc_type       number;
  l_sep_pay_excl_rule_id        number;
  l_prc_sep_excl_rule_id        number;
  l_excl_el_no_base_bal         number;
  l_excl_el_no_el_bal           number;
--
  l_id                          number;
  l_element_type_usage_id       number;
  l_balance_attribute_id        number;

  duplicate_template	        exception;
  l_enabled_flag	        varchar2(4);


begin

  --hr_utility.trace_on (null,'FLATAMT');


  /*  Check for Template Existence */

  l_template_exists := 'N';

   BEGIN
      SELECT 'Y', Template_id
      INTO   l_template_exists, l_template_id
      FROM   pay_element_templates
      WHERE  Template_type = 'T'
      AND    Legislation_code = p_legislation_code
      AND    template_name = 'Flat Amount';
   EXCEPTION
      WHEN OTHERS THEN
        NULL;
   END;

   IF (l_template_exists = 'Y')
   THEN
      BEGIN
         delete from PAY_ELE_TMPLT_CLASS_USAGES
         where template_id = l_template_id;

         pay_element_template_api.delete_user_structure(false,true,
                                                        l_template_id);
         l_template_exists := 'N';
         EXCEPTION
         WHEN OTHERS THEN
           l_template_exists := 'N';
           NULL;
      END;
   END IF;

/*  End of Check */

   IF l_template_exists = 'N'
   THEN

        l_effective_date := to_date('1901/01/01', 'YYYY/MM/DD');

        --
        --  PAY_ELEMENT_TEMPLATES row.
        --
        pay_etm_ins.ins
        (p_template_id               => l_template_id
        ,p_effective_date            => l_effective_date
        ,p_template_type             => 'T'
        ,p_template_name             => 'Flat Amount'
        ,p_base_processing_priority  => 1750
        ,p_max_base_name_length      => 25
        ,p_version_number            => 1
        ,p_legislation_code          => p_legislation_code
        ,p_object_version_number     => l_object_version_number
        );

        --
        -- Formula.
        --

        l_formula_text :=
'/*****************************************************************************

FORMULA NAME: _FLAT_AMOUNT_EARN

FORMULA TYPE: Payroll

DESCRIPTION:  Formula for Flat Amount for Earning Template for Internation
              Payroll.
              Returns pay value (Amount);

Formula Results :

 flat_amount           Direct Result for Earnings Amount.
 mesg                  Warning message will be issued for this assignment.

*******************************************************************************/

/* Database Item Defaults */

DEFAULT FOR flat_amount                    is 0
DEFAULT FOR mesg                           is ''NOT ENTERED''

/* Inputs  */

INPUTS ARE        Amount

flat_amount = Amount

RETURN flat_amount,
       mesg

/* End Formula Text */';

        pay_sf_ins.ins
        (p_formula_id                => l_formula_id
        ,p_template_type             => 'T'
        ,p_legislation_code          => p_legislation_code
        ,p_formula_name              => '_FLAT_AMOUNT_EARN'
        ,p_description               => 'Flat Amount formula for Earning Template'
        ,p_formula_text              => l_formula_text
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date
        );

       --
       -- End Formula
       --

       --
       -- 'Base' element.
       --

       pay_set_ins.ins
       (p_element_type_id              => l_base_element_id
       ,p_template_id                  => l_template_id
       ,p_element_name                 => null
       ,p_reporting_name               => null
       ,p_relative_processing_priority => 0
       ,p_processing_type              => 'N'
       ,p_classification_name          => 'Earnings'
       ,p_input_currency_code          => p_currency_code
       ,p_output_currency_code         => p_currency_code
       ,p_multiple_entries_allowed_fla => 'Y'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => 'S'
       ,p_payroll_formula_id           => l_formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Base Element Created');

       --
       -- Input Values for 'Base' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_base_pay_value_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Pay Value Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_amount_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Amount'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Amount Created');


       pay_siv_ins.ins
       (p_input_value_id               => l_input_value_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 3
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Jurisdiction'
       ,p_uom                          => 'C'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value- Jurisdiction');

       --
       -- Primary balance types.
       --

       pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_balance_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => null
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => null
       ,p_comments                     =>
                                'Primary balance for Flat Amount Earnings.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Earnings'
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Primary Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_el_balance_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' EL'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' EL'
       ,p_comments                     =>
                                'Employer Liabilities for Flat Amount Earnings.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Employer Liabilities'
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       --
       -- Balance Feeds.
       --

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed For Primary Balance - Pay Value Created');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed For EL Balance - Pay Value Created');

       --
       -- Formula rules.
       --

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'flat_amount'
       ,p_result_rule_type             => 'D'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - flat_amount created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'mesg'
       ,p_result_rule_type             => 'M'
       ,p_severity_level               => 'W'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - mesg created.');

       --
       -- Defined Balances for the Primary Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_balance_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       --
       -- Defined Balances For Employer Liabilities
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_balance_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_create_elemnt_tmplt_record.create_elemnt_tmplt_usages(
                   l_template_id,
                   'Earnings',
                   p_legislation_code );

   END IF;

end;
END create_earn_flat_amt_templ;

procedure create_earn_hxr_amt_templ( p_legislation_code IN VARCHAR2,
                                     p_currency_code    IN VARCHAR2) IS
begin
declare
  l_effective_date              date;
--
  l_template_exists             Char;
--
  l_template_id                 number;
  l_object_version_number       number;
--
  l_base_element_id             number;
--
  l_formula_id                  number;
  l_formula_text                varchar2(32000);
  l_formula_name                varchar2(80);
  l_formula_desc                varchar2(240);
--
  l_primary_bal_typ_id          number;
  l_hours_bal_typ_id            number;
  l_el_bal_typ_id               number;
--
  l_input_value_id              number;
  l_base_pay_value_iv_id        number;
  l_base_hours_iv_id             number;
  l_base_rate_iv_id             number;
  l_base_multiple_iv_id         number;
  l_base_sep_pay_iv_id          number;
  l_base_proc_sep_iv_id         number;
--
  l_defined_balance_id          number;
--
  l_balance_feed_id             number;
--
  l_reg_tax_proc_type           number;
  l_non_per_tax_proc_type       number;
  l_sep_pay_excl_rule_id        number;
  l_prc_sep_excl_rule_id        number;
  l_dbc1                        number;
  l_dbc2                        number;
  l_dbc3                        number;
  l_excl_el_no_base_bal         number;
  l_excl_el_no_el_bal           number;
--
  l_id                          number;
  l_element_type_usage_id       number;
  l_balance_attribute_id        number;

  duplicate_template            exception;
  l_enabled_flag                varchar2(4);


begin

  --hr_utility.trace_on (null,'HXR');


  /*  Check for Template Existence */

   l_template_exists := 'N';

   BEGIN
      SELECT 'Y', Template_id
      INTO   l_template_exists, l_template_id
      FROM   pay_element_templates
      WHERE  Template_type = 'T'
      AND    Legislation_code = p_legislation_code
      AND    template_name = 'Hours X Rate';
   EXCEPTION
      WHEN OTHERS THEN
        NULL;
   END;

   IF (l_template_exists = 'Y')
   THEN
      BEGIN
         delete from PAY_ELE_TMPLT_CLASS_USAGES
         where template_id = l_template_id;

         pay_element_template_api.delete_user_structure(false,true,
                                                        l_template_id);
         l_template_exists := 'N';
         EXCEPTION
         WHEN OTHERS THEN
           l_template_exists := 'N';
           NULL;
      END;
   END IF;

   /*  End of Check */

   IF l_template_exists = 'N'
   THEN

        l_effective_date := to_date('1901/01/01', 'YYYY/MM/DD');

        --
        --  PAY_ELEMENT_TEMPLATES row.
        --
        pay_etm_ins.ins
        (p_template_id               => l_template_id
        ,p_effective_date            => l_effective_date
        ,p_template_type             => 'T'
        ,p_template_name             => 'Hours X Rate'
        ,p_base_processing_priority  => 1750
        ,p_max_base_name_length      => 25
        ,p_version_number            => 1
        ,p_legislation_code          => p_legislation_code
        ,p_object_version_number     => l_object_version_number
        );

        --
        -- Formula _HOURS_X_RATE
        --

        l_formula_name  := '_HOURS_X_RATE';
        l_formula_desc  := 'Formula for Hours X Rate Template';

        l_formula_text :=
'/*****************************************************************************

FORMULA NAME:   HOURS_X_RATE
FORMULA TYPE:   Payroll
DESCRIPTION:    Creates formula for template element where Hours must
                be input, Multiple defaults to 1 if not input,  and Rate
                is determined by one of the following, in order of preference:
                1) Entry of "Rate" input value
                2) Entry of "Rate Code" input value
                3) Salary Admin "Pay Basis" information
--
INPUTS:  Hours
         Multiple
         Rate
--
Change History
--
**********************************************************************
Formula Results :
 earnings_amount
 mesg

Followings are Indirect result for Hours by Rate element:

None
**********************************************************************/
/* ===== Alias Section Begin ====== */
/* ===== Alias Section End ====== */

/* ===== Defaults Section Begin ===== */

DEFAULT FOR PAY_PROC_PERIOD_START_DATE is ''0001/01/01 00:00:00'' (DATE)
DEFAULT FOR PAY_PROC_PERIOD_END_DATE   is ''0001/01/02 00:00:00'' (DATE)
DEFAULT FOR ASG_SALARY_BASIS           is ''NOT ENTERED''
DEFAULT FOR ASG_SALARY_BASIS_CODE      is ''NOT ENTERED''
DEFAULT FOR ASG_SALARY                 is 0

default for ASG_HOURS                  is 0
default for Hours                      is 0
default for Rate                       is 0
default for Multiple                   is 1
default for ASG_FREQ_CODE              is ''NOT ENTERED''

/* ===== Defaults Section End ===== */

/* ===== Inputs Section Begin ===== */

Inputs are      Hours,
                Rate,
                Multiple

/* ===== Inputs Section End ===== */

/* ===== local variables Start =====  */

l_return_status = 1
l_schedule_source = '' ''
l_schedule = '' ''
mesg = '' ''

/* ===== local variables End =====  */

/* ===== CALCULATION SECTION BEGIN ===== */

   IF Rate WAS DEFAULTED THEN
   (
      IF ASG_SALARY_BASIS WAS DEFAULTED THEN
      (
        mesg =
          GET_MESG(''PAY'',''PAY_RATE_NOT_FOUND'',''BASE_NAME'',
                                             ''<BASE NAME>'')

	  RETURN mesg
      )
      ELSE
      (
         /* Use pay basis input value id and basis to find rate. If
            ASG_HOURLY_SALARY is the amount, then can call
            Convert_Period_Type */

        calc_rate = get_hourly_rate()

      )
  )
  ELSE
  (
    /* Rate is entered */
     calc_rate = Rate
  )

/* ---- Now find Multiple ----- */
  IF Multiple WAS DEFAULTED THEN
     calc_Multiple = 1
  ELSE
     calc_Multiple = Multiple

/* ---- Now find Hours ----- */
  IF Hours WAS DEFAULTED THEN
      IF ASG_HOURS WAS DEFAULTED THEN
        (
         mesg =
                   GET_MESG(''PAY'',''PAY_HOURS_NOT_FOUND'',''BASE_NAME'',
                                                   ''<BASE NAME>'')
         RETURN mesg
	)
      ELSE
         /* Use standard hours entered on Assignment */
        ( calculated_hours =  calculate_actual_hours_worked(
                           PAY_PROC_PERIOD_START_DATE,
                           PAY_PROC_PERIOD_END_DATE,
                           '' '',
                           ''Y'',
                           ''BUSY'',
                           '' '',
                           l_schedule_source,
                           l_schedule,
                           l_return_status,
                           mesg)
          earnings_amount = (calculated_hours * calc_Multiple * calc_rate)
        )
  ELSE
     /* Use entered hours. */
    (
       earnings_amount = (Hours * calc_Multiple * calc_rate)
       calculated_hours = Hours
    )

/* ===== CALCULATION SECTION END ===== */

/* ===== Returns Section Begin ===== */

RETURN
          earnings_amount
        , calculated_hours
        , mesg

/* ===== Returns Section End ===== */

/* End Formula Text */';

        pay_sf_ins.ins
        (p_formula_id                => l_formula_id
        ,p_template_type             => 'T'
        ,p_legislation_code          => p_legislation_code
        ,p_formula_name              => l_formula_name
        ,p_description               => l_formula_desc
        ,p_formula_text              => l_formula_text
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date
        );

       --
       -- End Formula HOURS_X_RATE
       --

       --
       -- 'Base' elements.
       --

       pay_set_ins.ins
       (p_element_type_id              => l_base_element_id
       ,p_template_id                  => l_template_id
       ,p_element_name                 => null
       ,p_reporting_name               => null
       ,p_relative_processing_priority => 0
       ,p_processing_type              => 'N'
       ,p_classification_name          => 'Earnings'
       ,p_input_currency_code          => p_currency_code
       ,p_output_currency_code         => p_currency_code
       ,p_multiple_entries_allowed_fla => 'Y'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => 'S'
       ,p_payroll_formula_id           => l_formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Base Element Created');

       --
       -- Input Values for 'Base' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_base_pay_value_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Pay Value Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_hours_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Hours'
       ,p_uom                          => 'H_DECIMAL2'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Hours Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_rate_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 3
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Rate'
       ,p_uom                          => 'N'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Rate Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_multiple_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 4
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Multiple'
       ,p_uom                          => 'N'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Multiple Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_input_value_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 5
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Jurisdiction'
       ,p_uom                          => 'C'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value- Jurisdiction');

       --
       -- Primary balance types.
       --

       pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => null
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => null
       ,p_comments                     =>
                        'Primary balance for Hours X Rate Earnings.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Hourly Earnings'
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => l_excl_el_no_base_bal
       );

       hr_utility.trace('Primary Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_hours_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Hours'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Hours'
       ,p_category_name                => NULL --'Earnings Hours'
       ,p_comments                     =>
                        'Hours balance for Hours X Rate Earnings.'
       ,p_balance_uom                  => 'H_DECIMAL2'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => l_excl_el_no_base_bal
       );

       hr_utility.trace('Primary Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_el_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' EL'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' EL'
       ,p_comments                     =>
                       'Employer Liabilities balance for Hours X Rate Earnings.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Employer Liabilities'
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => l_excl_el_no_el_bal
       );

       hr_utility.trace('Primary Balance Type Created.');

       --
       -- Balance Feeds.
       --

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Pay Value Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_input_value_id               => l_base_hours_iv_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Hours Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Formula rules.
       --

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'earnings_amount'
       ,p_result_rule_type             => 'D'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - earnings_amount created.');

       /***********
       ** This is Indirect result to special feature element for
       ** Hours X Rate template check pycaehxr.sql
       ************/

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'earnings_hours'
       ,p_result_rule_type             => 'D'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_base_hours_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - earnings_hours created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'mesg'
       ,p_result_rule_type             => 'M'
       ,p_severity_level               => 'W'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - mesg created.');

       --
       -- Defined Balances for Primary Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       --
       -- Defined Balances for Hours Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_hours_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Employer Liabilties Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

 pay_create_elemnt_tmplt_record.create_elemnt_tmplt_usages(
               l_template_id,
               'Earnings',
               p_legislation_code );
  END IF;

end;
END create_earn_hxr_amt_templ;

procedure create_dedn_pct_amt_templ( p_legislation_code varchar2,
                                            p_currency_code in varchar2) IS
begin

declare
  l_effective_date              date;
--
  l_template_exists	        Char;
--
  l_template_id                 number;
  l_object_version_number       number;
--
  l_special_inputs_element_id   number;
  l_base_element_id             number;
  l_special_features_element_id number;
--
  l_formula_id                  number;
  l_formula_text                varchar2(32000);
  l_formula_name                varchar2(80);
  l_formula_desc                varchar2(240);
--
  l_primary_bal_typ_id          number;
  l_eligible_comp_bal_typ_id    number;
  l_accrued_bal_typ_id          number;
  l_not_taken_bal_typ_id        number;
  l_arrears_bal_typ_id          number;
--
  l_input_value_id              number;
  l_base_pay_value_id           number;
  l_base_percent_id             number;
  l_clear_arr_iv_id             number;
  l_total_owed_iv_id            number;
  l_sf_pay_value_id             number;
  l_sf_accrued_value_id         number;
  l_sf_not_taken_value_id       number;
  l_sf_arrears_contr_value_id   number;
--
  l_defined_balance_id          number;
--
  l_balance_feed_id             number;
--
  l_reg_tax_proc_type           number;
  l_non_per_tax_proc_type       number;
  l_arrearage_rule_id           number;
  l_stop_rule_id                number;
  l_start_rule_id               number;
  l_non_recurring_rule_id       number;
--
  l_id                          number;
  l_element_type_usage_id       number;
  l_balance_attribute_id        number;

  duplicate_template	        exception;
  l_enabled_flag	        varchar2(4);


begin

  --hr_utility.trace_on (null,'FLATAMT');


  /*  Check for Template Existence */

  l_template_exists := 'N';

   BEGIN
      SELECT 'Y', Template_id
      INTO   l_template_exists, l_template_id
      FROM   pay_element_templates
      WHERE  Template_type = 'T'
      AND    Legislation_code = p_legislation_code
      AND    template_name = 'Percentage Deduction';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
   END;

   IF (l_template_exists = 'Y')
   THEN
      BEGIN
         delete from PAY_ELE_TMPLT_CLASS_USAGES
         where template_id = l_template_id;

         pay_element_template_api.delete_user_structure(false,true,
                                                        l_template_id);
         l_template_exists := 'N';
         EXCEPTION
         WHEN OTHERS THEN
           l_template_exists := 'N';
           NULL;
      END;
   END IF;

/*  End of Check */

   IF l_template_exists = 'N'
   THEN

        l_effective_date := to_date('1901/01/01', 'YYYY/MM/DD');

        --
        --  PAY_ELEMENT_TEMPLATES row.
        --
        pay_etm_ins.ins
        (p_template_id               => l_template_id
        ,p_effective_date            => l_effective_date
        ,p_template_type             => 'T'
        ,p_template_name             => 'Percentage Deduction'
        ,p_base_processing_priority  => 3750
        ,p_max_base_name_length      => 40
        ,p_version_number            => 1
        ,p_legislation_code          => p_legislation_code
        ,p_object_version_number     => l_object_version_number
        );

        --
        -- Formula.
        --

        l_formula_name := '_PCT_DEDN';
        l_formula_desc := 'Percentage Deduction formula for Deduction Template';

        l_formula_text :=
'/*****************************************************************************

FORMULA NAME: _PCT_DEDN

FORMULA TYPE: Payroll

DESCRIPTION:  Formula for percentage Amount for Deduction Template
                           for International Payroll.
                           Returns pay value (Amount);

*******************************************************************************

FORMULA TEXT

Formula Results :

 dedn_amt          Direct Result for Deduction Amount
 not_taken         Update Deduction Recurring Entry Not Taken
 to_arrears        Update Deduction Recurring Entry Arrears Contr
 set_clear         Update Deduction Recurring Entry Clear Arrears
 STOP_ENTRY        Stop current recurring entry
 to_total_owed     Update Deduction Recurring Entry Accrued
 mesg              Message (Warning)

*******************************************************************************/


/* Database Item Defaults */

default for INSUFFICIENT_FUNDS_TYPE             is ''NOT ENTERED''

/* ===== Database Item Defaults End ===== */

/* ===== Input Value Defaults Begin ===== */

DEFAULT FOR Total_Owed                     IS 0
DEFAULT FOR Clear_Arrears (text)           IS ''N''
DEFAULT FOR Percentage                     IS 0
DEFAULT FOR EXTRA_ELEMENT_INFO_DDF_DEDUCTION_PROCESSING_INSUFFICIENT_FUNDS_TYPE is ''NOT ENTERED''

/* ===== Input Value Defaults End ===== */

DEFAULT FOR mesg                           IS ''NOT ENTERED''

/* ===== Inputs Section Begin ===== */

INPUTS ARE
	 Percentage
        ,Total_Owed
	,Clear_Arrears (text)

/* ===== Inputs Section End ===== */


IF Percentage WAS DEFAULTED THEN
(
    mesg = GET_MESG(''PAY'',''PAY_NO_VALUE_TO_CALC_DED''
                           ,''BASE_NAME'',''<BASE NAME>'')
    RETURN mesg
)
ELSE
(
   dedn_amt = (Percentage * <BASE NAME>_ELIGIBLE_COMP_ASG_RUN  / 100)

/*  ---------------------------------------------------------------------
CUSTOMER :  The formula is generated with a default to use the Eligible
        Compensation to calculate % of Earnings.  The Eligible Compensation
        balance is initially defined with the same balance feeds as the Regular
        Earnings balance.
        You can modify the earnings basis for this calculation by
        adding and deleting balance feeds to the
        <BASE NAME>_ELIGIBLE_COMP balance.
        If you want the formula to use another balance of earnings in
        the run, replace the <BASE NAME>_ELIGIBLE_COMP_ASG_GRE_RUN database item
        reference below with the database item for the balance of choice :
        <BALANCE_NAME_IN_UPPER_CASE/UNDERSCORES>_ASG_GRE_RUN
 ---------------------------------------------------------------------
*/

)

to_total_owed     = 0
to_arrears        = 0
to_not_taken      = 0
total_dedn        = 0
insuff_funds_type = EXTRA_ELEMENT_INFO_DDF_DEDUCTION_PROCESSING_INSUFFICIENT_FUNDS_TYPE
net_amount        = TOTAL_PAYMENTS_ASG_RUN

/* ====  Entry ITD Check Begin ==== */

   IF ( <BASE NAME>_ACCRUED_ENTRY_ITD = 0 AND
        <BASE NAME>_ACCRUED_ASG_ITD <> 0 ) THEN
   (
      to_total_owed = -1 * <BASE NAME>_ACCRUED_ASG_ITD + dedn_amt
   )

   IF ( <BASE NAME>_ARREARS_ENTRY_ITD = 0 AND
        <BASE NAME>_ARREARS_ASG_ITD <> 0 ) THEN
   (
      to_arrears = -1 * <BASE NAME>_ARREARS_ASG_ITD
   )

/* ====  Entry ITD Check End ==== */

/* ===== Arrears Section Begin ===== */

IF Clear_Arrears = ''Y'' THEN
(
      to_arrears = -1 * <BASE NAME>_ARREARS_ASG_ITD
      set_clear = ''No''
)

IF insuff_funds_type = ''PD'' THEN /*Partial Deduction */
(
  IF ( net_amount - dedn_amt >= 0 ) THEN
  (
    to_arrears   = 0
    to_not_taken = 0
    dedn_amt     = dedn_amt
  )
 ELSE
 (
   to_arrears   = 0
   to_not_taken = dedn_amt - net_amount
   dedn_amt     = net_amount
  )
)
ELSE IF insuff_funds_type = ''APD'' THEN /*Arrearage and Partial Deduction */
(
  IF ( net_amount <= 0 ) THEN
  (
      to_arrears   = dedn_amt
      to_not_taken = dedn_amt
      dedn_amt     = 0
  )
  ELSE
  (
     total_dedn = dedn_amt + <BASE NAME>_ARREARS_ASG_ITD
     IF ( net_amount >= total_dedn ) THEN
     (
            to_arrears   = -1 * <BASE NAME>_ARREARS_ASG_ITD
            to_not_taken = 0
            dedn_amt     = total_dedn
     )
     ELSE
     (
       to_arrears   = total_dedn - net_amount
       to_arrears   = to_arrears - <BASE NAME>_ARREARS_ASG_ITD
       IF ( net_amount >= dedn_amt ) THEN
       (
         to_not_taken = 0
         dedn_amt     = net_amount
       )
       ELSE
       (
         to_not_taken = to_arrears
         dedn_amt     = net_amount
       )
     )
  )
)

ELSE IF insuff_funds_type = ''A''  THEN /*Arrearage */
(
   IF ( net_amount <= 0 ) THEN
   (
      to_arrears   = dedn_amt
      to_not_taken = dedn_amt
      dedn_amt     = 0
   )
   ELSE
  (
     total_dedn = dedn_amt + <BASE NAME>_ARREARS_ASG_ITD
     IF ( net_amount >= total_dedn ) THEN
     (
            to_arrears   = -1 * <BASE NAME>_ARREARS_ASG_ITD
            to_not_taken = 0
            dedn_amt     = total_dedn
     )
     ELSE
     (
        IF ( net_amount >= dedn_amt ) THEN
        (
           to_arrears   = 0
           to_not_taken = 0
           dedn_amt     = dedn_amt
        )
       ELSE
       (
         to_arrears   = dedn_amt
         to_not_taken = dedn_amt
         dedn_amt     = 0
       )
     )
  )
)
ELSE IF insuff_funds_type = ''NONE''  THEN /* No Arrearage and No Partial Deduction */
(
  IF ( net_amount - dedn_amt >= 0 ) THEN
  (
    to_arrears   = 0
    to_not_taken = 0
    dedn_amt     = dedn_amt
  )
 ELSE
 (
   to_arrears   = 0
   to_not_taken = 0
   dedn_amt     = 0
  )
)
ELSE /* Error*/
(
     IF ( net_amount - dedn_amt < 0 ) THEN
     (
         mesg = GET_MESG(''PAY'',''PAY_INSUFF_FUNDS_FOR_DED'')
         RETURN mesg
    )
)


/* ===== Arrears Section End ===== */

/* ===== Stop Rule Section Begin ===== */

   to_total_owed = dedn_amt

   IF Total_Owed WAS NOT DEFAULTED THEN
   (
      total_accrued  = dedn_amt + <BASE NAME>_ACCRUED_ASG_ITD

      IF total_accrued  >= Total_Owed THEN
      (
         dedn_amt = Total_Owed - <BASE NAME>_ACCRUED_ASG_ITD

          /* The total has been reached - the return will stop the entry under
             these conditions.  Also, zero out Accrued balance.  */

          to_total_owed = -1 * <BASE NAME>_ACCRUED_ASG_ITD
          STOP_ENTRY = ''Y''

          mesg = GET_MESG(''PAY'',''PAY_STOPPED_ENTRY'',
                                  ''BASE_NAME'',''<BASE NAME>'')
       )
   )

/* ===== Stop Rule Section End ===== */

  RETURN dedn_amt,
         to_not_taken,
         to_arrears,
         to_total_owed,
         STOP_ENTRY,
         set_clear,
         mesg

/* End Formula Text */';

        pay_sf_ins.ins
        (p_formula_id                => l_formula_id
        ,p_template_type             => 'T'
        ,p_legislation_code          => p_legislation_code
        ,p_formula_name              => l_formula_name
        ,p_description               => l_formula_desc
        ,p_formula_text              => l_formula_text
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date
        );

       --
       -- End Formula
       --

       --
       -- 'Base' element.
       --

       pay_set_ins.ins
       (p_element_type_id              => l_base_element_id
       ,p_template_id                  => l_template_id
       ,p_element_name                 => null
       ,p_reporting_name               => null
       ,p_relative_processing_priority => 0
       ,p_processing_type              => 'N'
       ,p_classification_name          => 'Voluntary Deductions'
       ,p_input_currency_code          => p_currency_code
       ,p_output_currency_code         => p_currency_code
       ,p_multiple_entries_allowed_fla => 'Y'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => 'S'
       ,p_payroll_formula_id           => l_formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Base Element Created');

       --
       -- 'Special Features' element.
       --

       pay_set_ins.ins
       (p_element_type_id                    => l_special_features_element_id
       ,p_template_id                        => l_template_id
       ,p_element_name                       => ' Special Features'
       ,p_reporting_name                     => ' SF'
       ,p_relative_processing_priority       => 50
       ,p_processing_type                    => 'N'
       ,p_classification_name                => 'Information'
       ,p_input_currency_code                => p_currency_code
       ,p_output_currency_code               => p_currency_code
       ,p_multiple_entries_allowed_fla       => 'N'
       ,p_post_termination_rule              => 'F'
       ,p_process_in_run_flag                => 'Y'
       ,p_additional_entry_allowed_fla       => 'N'
       ,p_adjustment_only_flag               => 'N'
       ,p_closed_for_entry_flag              => 'N'
       ,p_indirect_only_flag                 => 'N'
       ,p_multiply_value_flag                => 'N'
       ,p_standard_link_flag                 => 'N'
       ,p_object_version_number              => l_object_version_number
       ,p_effective_date                     => l_effective_date
       );

       hr_utility.trace('Special Features Element Created');

       --
       -- Input Values for 'Base' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_base_pay_value_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Pay Value Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_percent_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Percentage'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Amount Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_clear_arr_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 3
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N' /* user-enterable. */
       ,p_name                         => 'Clear Arrears'
       ,p_uom                          => 'C'
       ,p_lookup_type                  => 'YES_NO'
       ,p_default_value                => 'N'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Clear Arrears Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_total_owed_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 4
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N' /* user-enterable. */
       ,p_name                         => 'Total Owed'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Total Owed Created');


       --
       -- Input Values for 'Special Features' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_pay_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Pay Value for Special Features Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_accrued_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Accrued'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Accrued Input Value for Special Features Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_not_taken_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 3
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Not Taken'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Not Taken Input Value for Special Features Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_sf_arrears_contr_value_id
       ,p_element_type_id              => l_special_features_element_id
       ,p_display_sequence             => 4
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Arrears Contr'
       ,p_uom                          => 'M'
       ,p_object_version_number        => l_object_version_number
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Arrears Contr Input Val for Special Features Created');

       --
       -- Primary balance types.
       --

       pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => null
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => null
       ,p_comments                     =>
                  'Primary balance for Percentage Deductions.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Deductions'
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Primary Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_eligible_comp_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Eligible Comp'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Eligible Comp'
       ,p_comments                     =>
                  'Eligible Comp. balance for Percentage Deduction.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Eligible Comp. balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_accrued_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Accrued'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Accrued'
       ,p_comments                     =>
                  'Accrued balance for Percentage Deduction.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       hr_utility.trace('Accrued Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_arrears_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Arrears'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Arrears'
       ,p_comments                     =>
                  'Arrears balance for Percentage Deduction.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Arrears Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Not Taken'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Not Taken'
       ,p_comments                     =>
                  'Not Taken balance for Percentage Deduction.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Wages'
       ,p_base_balance_type_id         => l_primary_bal_typ_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Not Taken Balance Type Created.');

       --
       -- Balance Feeds.
       --

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Pay Value to Primary Bal Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id                    => l_balance_feed_id
       ,p_balance_type_id                    => l_accrued_bal_typ_id
       ,p_input_value_id                     => l_sf_accrued_value_id
       ,p_scale                              => 1
       ,p_object_version_number              => l_object_version_number
       ,p_effective_date                     => l_effective_date
       );

       hr_utility.trace('Balance Feed - Accrued to Accrued Bal Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id                    => l_balance_feed_id
       ,p_balance_type_id                    => l_not_taken_bal_typ_id
       ,p_input_value_id                     => l_sf_not_taken_value_id
       ,p_scale                              => 1
       ,p_object_version_number              => l_object_version_number
       ,p_effective_date                     => l_effective_date
       );

       hr_utility.trace('Balance Feed - Not Taken to Not Taken Bal Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id                    => l_balance_feed_id
       ,p_balance_type_id                    => l_arrears_bal_typ_id
       ,p_input_value_id                     => l_sf_arrears_contr_value_id
       ,p_scale                              => 1
       ,p_object_version_number              => l_object_version_number
       ,p_effective_date                     => l_effective_date
       );

       hr_utility.trace('Balance Feed - Arrears Contr to Arrears Bal Created.');

       --
       -- Formula rules.
       --

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'dedn_amt'
       ,p_result_rule_type             => 'D'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_base_pay_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - dedn_amt created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'STOP_ENTRY'
       ,p_result_rule_type             => 'S'
       ,p_element_type_id              => l_base_element_id
       ,p_exclusion_rule_id            => l_non_recurring_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - STOP_ENTRY created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'set_clear'
       ,p_result_rule_type             => 'U'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_clear_arr_iv_id
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - set_clear created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'mesg'
       ,p_result_rule_type             => 'M'
       ,p_severity_level               => 'W'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - mesg created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'to_not_taken'
       ,p_result_rule_type             => 'I'
       ,p_element_type_id              => l_special_features_element_id
       ,p_input_value_id               => l_sf_not_taken_value_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - to_not_taken created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'to_total_owed'
       ,p_result_rule_type             => 'I'
       ,p_element_type_id              => l_special_features_element_id
       ,p_input_value_id               => l_sf_accrued_value_id
       ,p_exclusion_rule_id            => l_stop_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - to_total_owed created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'to_arrears'
       ,p_result_rule_type             => 'I'
       ,p_element_type_id              => l_special_features_element_id
       ,p_input_value_id               => l_sf_arrears_contr_value_id
       ,p_exclusion_rule_id            => l_arrearage_rule_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - to_arrears created.');

       --
       -- Defined Balances
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                     'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                    'Assignment Calendar Year to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                    'Assignment Calendar Quarter to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                    'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Accrued Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                        'Element Entry Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_accrued_bal_typ_id
       ,p_dimension_name               =>
                   'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Arrears Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               =>
                        'Element Entry Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_arrears_bal_typ_id
       ,p_dimension_name               => 'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Not Taken Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_not_taken_bal_typ_id
       ,p_dimension_name               => 'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Eligible Comp. Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_eligible_comp_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Inception to Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_eligible_comp_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_eligible_comp_bal_typ_id
       ,p_dimension_name               => 'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_create_elemnt_tmplt_record.create_elemnt_tmplt_usages(
         l_template_id,
         'Deductions',
          p_legislation_code);

  END IF;
END;
END create_dedn_pct_amt_templ;

procedure create_earn_pct_amt_templ( p_legislation_code IN VARCHAR2,
                                     p_currency_code    IN VARCHAR2) IS
begin
declare
  l_effective_date              date;
--
  l_template_exists             Char;
--
  l_template_id                 number;
  l_object_version_number       number;
--
  l_base_element_id             number;
--
  l_formula_id                  number;
  l_formula_text                varchar2(32000);
  l_formula_name                varchar2(80);
  l_formula_desc                varchar2(240);
--
  l_primary_bal_typ_id          number;
  l_days_bal_typ_id             number;
  l_el_bal_typ_id               number;
  l_ec_bal_typ_id               number;
--
  l_input_value_id              number;
  l_base_pay_value_iv_id        number;
  l_base_days_iv_id             number;
  l_base_rate_iv_id             number;
  l_base_multiple_iv_id         number;
  l_base_sep_pay_iv_id          number;
  l_base_proc_sep_iv_id         number;
--
  l_defined_balance_id          number;
--
  l_balance_feed_id             number;
--
  l_reg_tax_proc_type           number;
  l_non_per_tax_proc_type       number;
  l_sep_pay_excl_rule_id        number;
  l_prc_sep_excl_rule_id        number;
  l_dbc1                        number;
  l_dbc2                        number;
  l_dbc3                        number;
  l_excl_el_no_base_bal         number;
  l_excl_el_no_el_bal           number;
--
  l_id                          number;
  l_element_type_usage_id       number;
  l_balance_attribute_id        number;

  duplicate_template            exception;
  l_enabled_flag                varchar2(4);


begin

  --hr_utility.trace_on (null,'PCT');


  /*  Check for Template Existence */

   l_template_exists := 'N';

   BEGIN
      SELECT 'Y', Template_id
      INTO   l_template_exists, l_template_id
      FROM   pay_element_templates
      WHERE  Template_type = 'T'
      AND    Legislation_code = p_legislation_code
      AND    template_name = 'Percentage of Earnings';
   EXCEPTION
      WHEN OTHERS THEN
        NULL;
   END;

   IF (l_template_exists = 'Y')
   THEN
      BEGIN
         delete from PAY_ELE_TMPLT_CLASS_USAGES
         where template_id = l_template_id;

         pay_element_template_api.delete_user_structure(false,true,
                                                        l_template_id);
         l_template_exists := 'N';
         EXCEPTION
         WHEN OTHERS THEN
           l_template_exists := 'N';
           NULL;
      END;
   END IF;

   /*  End of Check */

   IF  l_template_exists = 'N'
   THEN

        l_effective_date := to_date('1901/01/01', 'YYYY/MM/DD');

        --
        --  PAY_ELEMENT_TEMPLATES row.
        --
        pay_etm_ins.ins
        (p_template_id               => l_template_id
        ,p_effective_date            => l_effective_date
        ,p_template_type             => 'T'
        ,p_template_name             => 'Percentage of Earnings'
        ,p_base_processing_priority  => 1750
        ,p_max_base_name_length      => 25
        ,p_version_number            => 1
        ,p_legislation_code          => p_legislation_code
        ,p_object_version_number     => l_object_version_number
        );

        --
        -- Formula _EARN_PCT
        --

        l_formula_name  := '_PCT_EARN';
        l_formula_desc  := 'Formula for Percentage of Earnings Template';


        l_formula_text := '
/******************************************************************************
FORMULA NAME: _PCT_EARN

FORMULA TYPE: Payroll

DESCRIPTION:
             This formula applies a percentage to the appropriate
              regular earnings of an employee according to the following
              rules ::
              Salary Admin Pay Basis: REGULAR_SALARY * Percentage
              if Pay Basis not hourly; else
              ASG_SALARY * Percentage * normal period hours

Formula Results :
 template_earning	Direct Result for Earnings Amount (ie. Pay Value).
 mesg		        Message indicating that this earnings will be deleted
                        for this assignment.

************************************************************************/
/* ===== Defaults Section Begin ===== */

default for     Percentage                 is 0
default for     PAY_PROC_PERIOD_START_DATE is ''0001/01/01 00:00:00'' (DATE)
default for     PAY_PROC_PERIOD_END_DATE   is ''0001/01/02 00:00:00'' (DATE)
default for     ASG_FREQ_CODE          	   is ''NOT ENTERED''
default for     ASG_SALARY          	   is 0
default for    <BASE NAME>_ELIGIBLE_COMP_ASG_RUN is 0

/* ===== Defaults Section End ===== */

/* ===== Inputs Section Begin ===== */

Inputs are      Percentage

/* ===== Inputs Section End ===== */

/**********************/
/*  local variables   */
/**********************/

l_return_status = 1
l_schedule_source = '' ''
l_schedule = '' ''
mesg = '' ''

/* ===== CALCULATION SECTION BEGIN ===== */

    IF ASG_SALARY WAS NOT DEFAULTED THEN
    (
        /* The following will return the Periodic Salary */

      calculated_hours =  calculate_actual_hours_worked(
                           PAY_PROC_PERIOD_START_DATE,
                           PAY_PROC_PERIOD_END_DATE,
                           '' '',
                           ''Y'',
                           ''BUSY'',
                           '' '',
                           l_schedule_source,
                           l_schedule,
                           l_return_status,
                           mesg)

      calculated_earnings = get_hourly_rate()

      earnings_amount = ROUNDUP(
	(Percentage * calculated_hours * calculated_earnings / 100),2)
    )
    ELSE

      earnings_amount = ROUNDUP(
                     (Percentage * <BASE NAME>_ELIGIBLE_COMP_ASG_RUN / 100 ),2)

/* ===== CALCULATION SECTION END ===== */

/* ===== Returns Section Begin ===== */


RETURN earnings_amount,
                mesg

/* ===== Returns Section End ===== */

/* End Program */

/* End Formula Text */';

        pay_sf_ins.ins
        (p_formula_id                => l_formula_id
        ,p_template_type             => 'T'
        ,p_legislation_code          => p_legislation_code
        ,p_formula_name              => l_formula_name
        ,p_description               => l_formula_desc
        ,p_formula_text              => l_formula_text
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => l_effective_date
        );

       --
       -- End Formula PERCENTAGE_OF_EARNINGS
       --

       --
       -- 'Base' elements.
       --

       pay_set_ins.ins
       (p_element_type_id              => l_base_element_id
       ,p_template_id                  => l_template_id
       ,p_element_name                 => null
       ,p_reporting_name               => null
       ,p_relative_processing_priority => 0
       ,p_processing_type              => 'N'
       ,p_classification_name          => 'Earnings'
       ,p_input_currency_code          => p_currency_code
       ,p_output_currency_code         => p_currency_code
       ,p_multiple_entries_allowed_fla => 'Y'
       ,p_post_termination_rule        => 'F'
       ,p_process_in_run_flag          => 'Y'
       ,p_additional_entry_allowed_fla => 'N'
       ,p_adjustment_only_flag         => 'N'
       ,p_closed_for_entry_flag        => 'N'
       ,p_indirect_only_flag           => 'N'
       ,p_multiply_value_flag          => 'N'
       ,p_standard_link_flag           => 'N'
       ,p_process_mode                 => 'S'
       ,p_payroll_formula_id           => l_formula_id
       ,p_skip_formula                 => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Base Element Created');

       --
       -- Input Values for 'Base' element.
       --

       pay_siv_ins.ins
       (p_input_value_id               => l_base_pay_value_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 1
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Pay Value'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Pay Value Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_base_days_iv_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 2
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'N'
       ,p_name                         => 'Percentage'
       ,p_uom                          => 'M'
       ,p_exclusion_rule_id            => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value - Percentage Created');

       pay_siv_ins.ins
       (p_input_value_id               => l_input_value_id
       ,p_element_type_id              => l_base_element_id
       ,p_display_sequence             => 5
       ,p_generate_db_items_flag       => 'Y'
       ,p_hot_default_flag             => 'N'
       ,p_mandatory_flag               => 'X'
       ,p_name                         => 'Jurisdiction'
       ,p_uom                          => 'C'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Base Element Input Value- Jurisdiction');

       --
       -- Primary balance types.
       --

       pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => null
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => null
       ,p_comments                     =>
                    'Primary balance for Percentage of Earnings.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Earnings'
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Primary Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_el_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' EL'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' EL'
       ,p_comments                     =>
                  'Primary balance for Percentage of Earnings for EL.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Employer Liabilities'
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Employer Liabities Balance Type Created.');

       pay_sbt_ins.ins
       (p_balance_type_id              => l_ec_bal_typ_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Eligible Comp'
       ,p_currency_code                => p_currency_code
       ,p_reporting_name               => ' Eligible Comp'
       ,p_comments                     =>
                    'Eligible Comp. balance for Percentage Earnings.'
       ,p_balance_uom                  => 'M'
       ,p_category_name                => NULL --'Earnings'
       ,p_input_value_id               => NULL
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       ,p_exclusion_rule_id            => NULL
       );

       hr_utility.trace('Eligible Comp Balance Type Created.');

       --
       -- Balance Feeds.
       --

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed - Pay Value Created.');

       pay_sbf_ins.ins
       (p_balance_feed_id              => l_balance_feed_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_scale                        => 1
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Balance Feed for EL - Pay Value Created.');

       --
       -- Formula rules.
       --

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'earnings_amount'
       ,p_result_rule_type             => 'D'
       ,p_element_type_id              => l_base_element_id
       ,p_input_value_id               => l_base_pay_value_iv_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - earnings_amount created.');

       pay_sfr_ins.ins
       (p_formula_result_rule_id       => l_id
       ,p_shadow_element_type_id       => l_base_element_id
       ,p_result_name                  => 'mesg'
       ,p_result_rule_type             => 'M'
       ,p_severity_level               => 'W'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       hr_utility.trace('Formula Rule - mesg created.');

       --
       -- Defined Balances for Primary Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );


       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_primary_bal_typ_id
       ,p_dimension_name               => 'Payments'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Employer Liabilities Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Person Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Year To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Quarter To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_el_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Calendar Month To Date'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       --
       -- Defined Balances for Eligible Comp Balance
       --

       pay_sdb_ins.ins
       (p_defined_balance_id           => l_defined_balance_id
       ,p_balance_type_id              => l_ec_bal_typ_id
       ,p_dimension_name               =>
                        'Assignment Run'
       ,p_object_version_number        => l_object_version_number
       ,p_effective_date               => l_effective_date
       );

       pay_create_elemnt_tmplt_record.create_elemnt_tmplt_usages(
         l_template_id,
         'Earnings',
         p_legislation_code);

  END IF;
end;
END create_earn_pct_amt_templ;

procedure create_all_templates(p_legislation_code in varchar2, p_currency_code in varchar2) is
Begin

--  hr_utility.trace_on (null,'FLATAMTDEDN');
 pay_create_elemnt_tmplt_record.create_earn_flat_amt_templ(p_legislation_code,
                                                           p_currency_code);
 pay_create_elemnt_tmplt_record.create_earn_pct_amt_templ(p_legislation_code,
                                                          p_currency_code);
 pay_create_elemnt_tmplt_record.create_earn_hxr_amt_templ(p_legislation_code,
                                                          p_currency_code);
 pay_create_elemnt_tmplt_record.create_dedn_pct_amt_templ(p_legislation_code,
                                                          p_currency_code);
 pay_create_elemnt_tmplt_record.create_dedn_flat_amt_templ(p_legislation_code,
                                                           p_currency_code);

end create_all_templates;

END pay_create_elemnt_tmplt_record;


/
