--------------------------------------------------------
--  DDL for Package Body PAY_DB_LOCALISATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DB_LOCALISATION_PKG" as
/* $Header: pylocaln.pkb 115.3 99/09/06 08:20:51 porting ship  $ */
--
 /*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
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
--
    Name        : pay_db_localisation_pkg

    Description :

    Uses        : n/a
    Used By     : n/a

    Test List
    ---------
    Procedure                     Name       Date        Test Id Status
    +----------------------------+----------+-----------+-------+--------------+
    +----------------------------+----------+-----------+-------+--------------+
--
    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    26-Nov-92   J.S.Hobbs     3.0                First Created.
    20-Jan-93   J.S.Hobbs     3.1                brought uo to new standards.
    16-Feb-93   J.S.Hobbs     3.2                Added create_BF_localisation
    16-Mar-93   J.S.Hobbs     3.3                Added create_payments_balance.
    01-Apr-93   J.S.Hobbs     3.4                Tidied up package.
    17-JUN-93   A.McGhee      3.5                Removed FORMULA_ID column
					         from pay_payment_types
						 insert.
    04-AUG-93   J.S.Hobbs     3.6                Added extra column for
						 inserting into element
						 classifications ie.
						 COSTABLE_FLAG.
    05-Aug-93   J.S.Hobbs     3.7                Chnaged insert into
					     PER_ASSIGNMENT_INFO_TYPES so that
					     ACTIVE_INACTIVE_FLAG is set
					     correctly.
    16-Sep-93   M Kaddir      4.1                 Removed SQL which creates
                                                  PAY VALUE translation
    29-Sep-93   J.S.Hobbs     4.4 /   B203       Removed
			      3.18               create_name_translations as
						 this table has been dropped
						 and replaced with a lookup
						 type.
    29-SEP-93   M. Callaghan  4.5                Not null column:
                                                 assignment_remuneration_flag
                                                 added for pay_balance_types.
    03-NOV-93   C.Swan        4.6                Added setting of
                                                 MULTIPLE_OCCURENCES_FLAG on
                                                 insertion of
                                                 PER_ASSIGNMENT_INFO_TYPES.
    05-OCT-94   R.Fine        40.10		 Renamed package to
						 pay_db_localisation_pkg
    21-OCT-94   R.Fine        40.11		 Changed calls to renamed
						 packages:
						 pyautogn is now pay_autogn;
						 pygbatgn is now pay_gbatgn.
    21-Apr-99   A.Mills       115.2    875795    Changed legislation rule_type
                                                 'L' rule_modes to DD/MM
                                                 format.
   06-Sept-99   sbilling      115.3              Changed call to insert_row()
                                                                            */
--
 ---------------------------- create_payments_balance ------------------------
 /*
 NAME
   create_payments_balance
 DESCRIPTION
   Creates a payments balance for a legislation. This is to be used in the
   creation of organization payment methods.
 NOTES
 */
--
PROCEDURE create_payments_balance(p_legislation_code varchar2) is
--
 balance_type      number;
 balance_dimension number;
 v_rowid           varchar2(100);
--
begin
--
 -- Get the id of the payments dimension for the legislation.
 select bd.balance_dimension_id
 into   balance_dimension
 from   pay_balance_dimensions bd
 where  bd.legislation_code = p_legislation_code
   and  upper(bd.dimension_name) = upper('Payments');
--
--
pay_balance_types_pkg.insert_row(
 X_ROWID                        => v_rowid,
 X_BALANCE_TYPE_ID              => balance_type,
 X_BUSINESS_GROUP_ID            => NULL,
 X_LEGISLATION_CODE             => p_legislation_code,
 X_CURRENCY_CODE                => 'GBP',
 X_ASSIGNMENT_REMUNERATION_FLAG => 'Y',
 X_BALANCE_NAME                 => p_legislation_code || ' Payments Balance',
-- --
 X_BASE_BALANCE_NAME            => p_legislation_code || ' Payments Balance',
-- --
 X_BALANCE_UOM                  => 'M',
 X_COMMENTS                     => NULL,
 X_LEGISLATION_SUBGROUP         => NULL,
 X_REPORTING_NAME               => NULL,
 X_ATTRIBUTE_CATEGORY           => NULL,
 X_ATTRIBUTE1                   => NULL,
 X_ATTRIBUTE2                   => NULL,
 X_ATTRIBUTE3                   => NULL,
 X_ATTRIBUTE4                   => NULL,
 X_ATTRIBUTE5                   => NULL,
 X_ATTRIBUTE6                   => NULL,
 X_ATTRIBUTE7                   => NULL,
 X_ATTRIBUTE8                   => NULL,
 X_ATTRIBUTE9                   => NULL,
 X_ATTRIBUTE10                  => NULL,
 X_ATTRIBUTE11                  => NULL,
 X_ATTRIBUTE12                  => NULL,
 X_ATTRIBUTE13                  => NULL,
 X_ATTRIBUTE14                  => NULL,
 X_ATTRIBUTE15                  => NULL,
 X_ATTRIBUTE16                  => NULL,
 X_ATTRIBUTE17                  => NULL,
 X_ATTRIBUTE18                  => NULL,
 X_ATTRIBUTE19                  => NULL,
 X_ATTRIBUTE20                  => NULL
);
--
 -- Create a defined balance for the legislation using the payments
 -- dimension.
 insert into pay_defined_balances
 (DEFINED_BALANCE_ID,
  BALANCE_TYPE_ID,
  BALANCE_DIMENSION_ID,
  FORCE_LATEST_BALANCE_FLAG,
  LEGISLATION_CODE)
 select
  pay_defined_balances_s.nextval,
  balance_type,
  balance_dimension,
  'Y',
  p_legislation_code
 from sys.dual;
--
END create_payments_balance;
--
 --------------------------- create_BF_localisation ---------------------------
 /*
 NAME
 DESCRIPTION
 NOTES
 */
--
PROCEDURE create_BF_localisation is
--
begin
--
--   +=====================================================================+
--   |    Insert leg rules:                                                |
--   +=====================================================================+
--
  -- Time periods are not independent.
  insert into pay_legislation_rules
   (LEGISLATION_CODE, RULE_TYPE, RULE_MODE)
  values
   ('BF', 'I', 'N');
--
  -- The legislative start date is 6th April.
  insert into pay_legislation_rules
   (LEGISLATION_CODE, RULE_TYPE, RULE_MODE)
  values
   ('BF', 'L', '06/04');
--
--   +==================================================================+
--   |    Insert Element Classfications (no building blocks yet !)      |
--   +==================================================================+
--
--  This section creates the typical set of startup element
--  classifications for the UK. The primary classifications
--  created reflect those in R9:
--
--        Non Payment
--        Direct Payment
--        Earnings
--        Employer Charges
--        Pre-Tax Deductions
--        Tax Deductions
--        Voluntary Deductions
--
--  Further to this, the following sub classifications are
--  added for the Earnings primary classification:
--
--        PAYE
--        NI Employee
--        NI Employer
--
--
   declare
      class_id number;
      earnings_class number;
      function do_insert(l_classification_name varchar2,
                         l_description varchar2,
                         l_costing_debit_or_credit varchar2,
                         l_default_high_priority number,
                         l_default_low_priority number,
                         l_default_priority number,
                         l_distributable_over_flag varchar2,
                         l_non_payments_flag varchar2,
                         l_parent_id number,
			 l_costable_flag varchar2) return number is
         new_id number;
      begin
         insert into pay_element_classifications
            (classification_id,
             business_group_id,
             legislation_code,
             classification_name,
             description,
             legislation_subgroup,
             costing_debit_or_credit,
             default_high_priority,
             default_low_priority,
             default_priority,
             distributable_over_flag,
             non_payments_flag,
             parent_classification_id,
	     costable_flag)
         values
             (pay_element_classifications_s.nextval,
              NULL,
              'BF',
              l_classification_name,
              l_description,
              NULL,
              l_costing_debit_or_credit,
              l_default_high_priority,
              l_default_low_priority,
              l_default_priority,
              l_distributable_over_flag,
              l_non_payments_flag,
              l_parent_id,
	      l_costable_flag);
--
         select pay_element_classifications_s.currval
         into   new_id
         from   dual;
--
         return new_id;
      end do_insert;
--
   begin
      class_id := do_insert( 'Non Payment',
               'Used for element types which should not result in a payment',
                            NULL, 1000, 1, 500, 'N', 'Y', NULL, 'N');
--
      class_id := do_insert( 'Direct Payment',
                  'Used for element types which result in a direct payment',
                            'D', 2000, 1001, 1500, 'N', 'N', NULL, 'Y');
--
      --  insert EARNINGS classification and it's sub classifications
--
      earnings_class := do_insert( 'Earnings',
                         'Used for element types which constitute earnings',
                                  'D', 3000, 2001, 2500, 'Y', 'N', NULL, 'Y');
--
         class_id := do_insert( 'PAYE',
                               'Pay As You Earn',
                       'D', NULL, NULL, NULL, 'N', 'N', earnings_class, 'Y');
--
         class_id := do_insert( 'NI Employee',
                               'Employee NI',
                       'D', NULL, NULL, NULL, 'N', 'N', earnings_class, 'Y');
--
         class_id := do_insert( 'NI Employer',
                               'Employer NI',
                       'D', NULL, NULL, NULL, 'N', 'N', earnings_class, 'Y');
--
      class_id := do_insert( 'Employer Charges',
                            'Used for employer charges eg. Employer''s NI',
                            'D', 4000, 3001, 3500, 'N', 'N', NULL, 'Y');
--
      class_id := do_insert( 'Pre-Tax Deductions',
                            NULL,
                            'C', 5000, 4001, 4500, 'N', 'N', NULL, 'Y');
--
      class_id := do_insert( 'Tax Deductions',
                            'Used for tax deductions eg. PAYE and NI',
                            'C', 6000, 5001, 5500, 'N', 'N', NULL, 'Y');
--
      class_id := do_insert( 'Voluntary Deductions',
                            NULL,
                            'C', 7000, 6001, 6500, 'N', 'N', NULL, 'Y');
   end;
--
--
--   +==================================================================+
--   |    Insert Balance Types (no building blocks yet !)               |
--   +==================================================================+
--
   declare
      procedure do_insert(l_balance_name varchar2,
                          l_balance_uom  varchar2,
                          l_assign_remun varchar2) is
      begin
         insert into pay_balance_types
           (balance_type_id,
            assignment_remuneration_flag,
            balance_name,
            balance_uom,
            legislation_code)
         values
           (pay_balance_types_s.nextval,
            l_assign_remun,
            l_balance_name,
            l_balance_uom,
            'BF');
      end;
   begin
      do_insert( 'Employee NI-able Earnings', 'M', 'N');
      do_insert( 'Employer NI-able Earnings', 'M', 'N');
      do_insert( 'Net Earnings', 'M', 'Y');
      do_insert( 'Total Deductions', 'M', 'N');
   end;
--
   INSERT INTO PER_ASSIGNMENT_INFO_TYPES
   (INFORMATION_TYPE
   ,ACTIVE_INACTIVE_FLAG
   ,MULTIPLE_OCCURENCES_FLAG
   ,DESCRIPTION
   ,LEGISLATION_CODE
   ,REQUEST_ID
   ,PROGRAM_APPLICATION_ID
   ,PROGRAM_ID
   ,PROGRAM_UPDATE_DATE
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
   ,CREATED_BY
   ,CREATION_DATE)
   select 'BF_ASS_INFO'
   ,'Y'
   ,'N'
   ,'Burkina Faso Assignment Extra Details'
   ,'BF'
   ,null
   ,null
   ,null
   ,null
   ,null
   ,null
   ,null
   ,0
   ,sysdate
   from dual;
--
   INSERT INTO PAY_PAYMENT_TYPES
   (PAYMENT_TYPE_ID
   ,TERRITORY_CODE
   ,CURRENCY_CODE
   ,CATEGORY
   ,PAYMENT_TYPE_NAME
   ,ALLOW_AS_DEFAULT
   ,DESCRIPTION
   ,PRE_VALIDATION_REQUIRED
   ,VALIDATION_DAYS
   ,VALIDATION_VALUE
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
   ,CREATED_BY
   ,CREATION_DATE)
   select PAY_PAYMENT_TYPES_S.NEXTVAL
   ,null
   ,'GBP'
   ,'CA'
   ,'BF_PAYMENT'
   ,'Y'
   ,'Burkina Faso Cash Payments in Pounds Sterling'
   ,null
   ,null
   ,null
   ,null
   ,null
   ,null
   ,0
   ,sysdate
   from dual;
--
--   +==================================================================+
--   |    Insert Balance Dimensions and their FF routes                 |
--   |    The procedure db_autogen.build_bf_dimensions is               |
--   |    automatically generated using the balances.c file             |
--   +==================================================================+
--
  -- This creates temporary balance dimensions for the legislation.
  pay_autogn.insert_bf_dimensions;
--
  -- Create payments balance for legislation
  pay_db_localisation_pkg.create_payments_balance('BF');
--
--   +==================================================================+
--   |    E X C E P T I O N   H A N D L I N G                           |
--   +==================================================================+
--
end create_BF_localisation;
--
--
 --------------------------- create_GB_localisation ---------------------------
 /*
 NAME
 DESCRIPTION
 NOTES
 */
--
PROCEDURE create_GB_localisation is
--
begin
--
--   +=====================================================================+
--   |    Insert leg rules:                                                |
--   +=====================================================================+
--
  -- Time periods are not independent.
  insert into pay_legislation_rules
   (LEGISLATION_CODE, RULE_TYPE, RULE_MODE)
  values
   ('GB', 'I', 'N');
--
  -- The legislative start date is 6th April.
  insert into pay_legislation_rules
   (LEGISLATION_CODE, RULE_TYPE, RULE_MODE)
  values
   ('GB', 'L', '06/04');
--
--   +==================================================================+
--   |    Insert Element Classfications (no building blocks yet !)      |
--   +==================================================================+
--
--  This section creates the typical set of startup element
--  classifications for the GB. The primary classifications
--  created reflect those in R9:
--
--        Non Payment
--        Direct Payment
--        Earnings
--        Employer Charges
--        Pre-Tax Deductions
--        Tax Deductions
--        Voluntary Deductions
--
--  Further to this, the following sub classifications are
--  added for the Earnings primary classification:
--
--        PAYE
--        NI Employee
--        NI Employer
--
--
   declare
      class_id number;
      earnings_class number;
      function do_insert(l_classification_name varchar2,
                         l_description varchar2,
                         l_costing_debit_or_credit varchar2,
                         l_default_high_priority number,
                         l_default_low_priority number,
                         l_default_priority number,
                         l_distributable_over_flag varchar2,
                         l_non_payments_flag varchar2,
                         l_parent_id number) return number is
         new_id number;
      begin
         insert into pay_element_classifications
            (classification_id,
             business_group_id,
             legislation_code,
             classification_name,
             description,
             legislation_subgroup,
             costing_debit_or_credit,
             default_high_priority,
             default_low_priority,
             default_priority,
             distributable_over_flag,
             non_payments_flag,
             parent_classification_id)
         values
             (pay_element_classifications_s.nextval,
              NULL,
              'GB',
              l_classification_name,
              l_description,
              NULL,
              l_costing_debit_or_credit,
              l_default_high_priority,
              l_default_low_priority,
              l_default_priority,
              l_distributable_over_flag,
              l_non_payments_flag,
              l_parent_id);
--
         select pay_element_classifications_s.currval
         into   new_id
         from   dual;
--
         return new_id;
      end do_insert;
--
   begin
      class_id := do_insert( 'Non Payment',
               'Used for element types which should not result in a payment',
                            NULL, 1000, 1, 500, 'N', 'Y', NULL);
--
      class_id := do_insert( 'Direct Payment',
                  'Used for element types which result in a direct payment',
                            'D', 2000, 1001, 1500, 'N', 'N', NULL);
--
      --  insert EARNINGS classification and it's sub classifications
--
      earnings_class := do_insert( 'Earnings',
                         'Used for element types which constitute earnings',
                                  'D', 3000, 2001, 2500, 'Y', 'N', NULL);
--
         class_id := do_insert( 'PAYE',
                               'Pay As You Earn',
                          NULL, NULL, NULL, NULL, 'N', 'N', earnings_class);
--
         class_id := do_insert( 'NI Employee',
                               'Employee NI',
                          NULL, NULL, NULL, NULL, 'N', 'N', earnings_class);
--
         class_id := do_insert( 'NI Employer',
                               'Employer NI',
                          NULL, NULL, NULL, NULL, 'N', 'N', earnings_class);
--
      class_id := do_insert( 'Employer Charges',
                            'Used for employer charges eg. Employer''s NI',
                            'D', 4000, 3001, 3500, 'N', 'N', NULL);
--
      class_id := do_insert( 'Pre-Tax Deductions',
                            NULL,
                            'C', 5000, 4001, 4500, 'N', 'N', NULL);
--
      class_id := do_insert( 'Tax Deductions',
                            'Used for tax deductions eg. PAYE and NI',
                            'C', 6000, 5001, 5500, 'N', 'N', NULL);
--
      class_id := do_insert( 'Voluntary Deductions',
                            NULL,
                            'C', 7000, 6001, 6500, 'N', 'N', NULL);
   end;
--
--
--   +==================================================================+
--   |    Insert Balance Types (no building blocks yet !)               |
--   +==================================================================+
--
   declare
      procedure do_insert(l_balance_name varchar2,
                          l_balance_uom varchar2,
                          l_assign_remun varchar2) is
      begin
         insert into pay_balance_types
           (balance_type_id,
            assignment_remuneration_flag,
            balance_name,
            balance_uom,
            legislation_code)
         values
           (pay_balance_types_s.nextval,
            l_assign_remun,
            l_balance_name,
            l_balance_uom,
            'GB');
      end;
   begin
      do_insert( 'Employee NI-able Earnings', 'M', 'N');
      do_insert( 'Employer NI-able Earnings', 'M', 'N');
      do_insert( 'Net Earnings', 'M', 'Y');
      do_insert( 'Total Deductions', 'M', 'N');
   end;
--
--   +==================================================================+
--   |    Insert Balance Dimensions and their FF routes                 |
--   |    The procedure db_autogen.build_uk_dimensions is               |
--   |    automatically generated using the balances.c file             |
--   +==================================================================+
--
  -- This is a copy of db_autogen.build_uk_dimensions for use in
  -- creating temporary balance dimensions for the legislation.
  pay_gbatgn.insert_gb_dimensions;
--
  -- Create payments balance for legislation
  pay_db_localisation_pkg.create_payments_balance('GB');
--
--   +==================================================================+
--   |    E X C E P T I O N   H A N D L I N G                           |
--   +==================================================================+
--
end create_GB_localisation;
--
end pay_db_localisation_pkg;

/
