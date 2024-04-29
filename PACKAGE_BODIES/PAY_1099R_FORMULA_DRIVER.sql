--------------------------------------------------------
--  DDL for Package Body PAY_1099R_FORMULA_DRIVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_1099R_FORMULA_DRIVER" AS
/* $Header: py1099fd.pkb 115.5 99/07/17 05:40:44 porting ship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_1099R_formula_driver

    Description : Allows the creation of formulas which are neccessary
                  for 1099R reporting on a federal level. This set of
                  formulas includes those for US,STATE,WV,IN,NY

    Uses        : For any 1099R installation.

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----        ----     ----    ------     -----------
    05-NOV-96   GPERRY   40.0               Created.
    18-NOV-96   HEKIM    40.1               Added State specific formulas.
    05-MAR-96   HEKIM    40.2               Added WV,IN, NY formulas
    05-OCT-98   AHANDA   40.4               Added formulas for New Federal Format
    20-OCT-98   AHANDA   40.5               Added formulas for Old State Format
    14-DEC-98   AHANDA   40.6/110.2         Changed formula name for Non Federal States.
    26-JAN-99   AHANDA   40.7/110.3         Changed script to delete only formulas which
                                            it is creating. Moved delete statement
                                            inside the loop.
   16-jun-99   achauhan  110.5              Changed dbms_output to
                                            hr_utility.trace
*/
--
/**/
----------------------------------------------------------------------------------------
-- Name
--   setup
-- Purpose
--   Seeds formula data in ff_formulas_f table for 1099R federal formulas.
-- Arguments
--   None
-- Notes
----------------------------------------------------------------------------------------
--
PROCEDURE Setup IS
  --
  -- Define table structures to hold parameter details.
  --
  -- note: we are only inserting into the ff_formulas_f table.
  -- The only fields that we have to cater for are the following :
  --    LEGISLATION_CODE
  --    FORMULA_TYPE_ID
  --    FORMULA_NAME
  --    DESCRIPTION
  --
  l_formula_name_table        	char80_data_table;
  l_description_table       	char240_data_table;
  --
  l_formula_id 			number;
  l_legislation_code            varchar2(30) := 'US';
  l_formula_type_id             number;
  --
  -- The l_case_count variable is used to keep count of the number of
  -- formulas we are seeding. NOTE - this must be changed if formulae
  -- are to be added or removed from the seeding process.
  --
  l_case_count 			number := 44;
  --
  -- Note that l_message is used throughout this module to hold the
  -- message which will be displayed if an exception is raised.
  --
  l_message            VARCHAR2(200);
  --
  cursor c_formula_type_id is
    select formula_type_id
    from   ff_formula_types fft
    where  fft.formula_type_name = 'Oracle Payroll';
  --
BEGIN
  -- **************************************************************************
  --                              PL/SQL TABLE SEEDING
  -- **************************************************************************
  --
  -- This part of the procedure is where we seed all of the tables that we
  -- use to insert into the FF_FORMULAS_F table. This will allow the insertion
  -- of further formulas to be that much more simpler.
  --
  -- First we seed the formulas table, these are the names of all the formulas
  -- that we plan to seed.
  --
  hr_utility.trace('Seeding formula name table');
  --
  l_message := 'Seeding formula name table';
  --
  l_formula_name_table(1)  := 'US_1099R_FILE_TOTALS';
  l_formula_name_table(2)  := 'US_1099R_PAYEES';
  l_formula_name_table(3)  := 'US_1099R_PAYER';
  l_formula_name_table(4)  := 'US_1099R_PAYER_TOTALS';
  l_formula_name_table(5)  := 'US_1099R_TRANSMITTER';
  l_formula_name_table(6)  := 'US_1099R_STATE_TOTALS';
  l_formula_name_table(7)  := 'STATE_1099R_PAYEES';
  l_formula_name_table(8)  := 'STATE_1099R_PAYER';
  l_formula_name_table(9)  := 'WV_1099R_PAYEES';
  l_formula_name_table(10) := 'WV_1099R_PAYER';
  l_formula_name_table(11) := 'IN_1099R_EMPLOYER';
  l_formula_name_table(12) := 'IN_1099R_SUPPLEMENTAL';
  l_formula_name_table(13) := 'IN_1099R_FINAL';
  l_formula_name_table(14) := 'IN_1099R_TRANSMITTER';
  l_formula_name_table(15) := 'IN_1099R_TOTAL';
  l_formula_name_table(16) := 'NY_1099R_TRANSMITTER';
  l_formula_name_table(17) := 'NY_1099R_EMPLOYER';
  l_formula_name_table(18) := 'NY_1099R_EMPLOYEE';
  l_formula_name_table(19) := 'NY_1099R_TOTAL';
  l_formula_name_table(20) := 'NY_1099R_FINAL';

  l_formula_name_table(21) := 'US_1099R_NFED_TRANSMITTER';
  l_formula_name_table(22) := 'US_1099R_NFED_STATE_TOTALS';
  l_formula_name_table(23) := 'US_1099R_NFED_PAYER_TOTALS';
  l_formula_name_table(24) := 'US_1099R_NFED_FILE_TOTALS';

/* Formula for Old Magnetic Reports(Retry) */
  l_formula_name_table(25) := 'US_OLD_1099R_FILE_TOTALS';
  l_formula_name_table(26) := 'US_OLD_1099R_PAYEES';
  l_formula_name_table(27) := 'US_OLD_1099R_PAYER';
  l_formula_name_table(28) := 'US_OLD_1099R_PAYER_TOTALS';
  l_formula_name_table(29) := 'US_OLD_1099R_TRANSMITTER';
  l_formula_name_table(30) := 'US_OLD_1099R_STATE_TOTALS';
  l_formula_name_table(31) := 'STATE_OLD_1099R_PAYEES';
  l_formula_name_table(32) := 'STATE_OLD_1099R_PAYER';
  l_formula_name_table(33) := 'WV_OLD_1099R_PAYEES';
  l_formula_name_table(34) := 'WV_OLD_1099R_PAYER';
  l_formula_name_table(35) := 'IN_OLD_1099R_EMPLOYER';
  l_formula_name_table(36) := 'IN_OLD_1099R_SUPPLEMENTAL';
  l_formula_name_table(37) := 'IN_OLD_1099R_FINAL';
  l_formula_name_table(38) := 'IN_OLD_1099R_TRANSMITTER';
  l_formula_name_table(39) := 'IN_OLD_1099R_TOTAL';
  l_formula_name_table(40) := 'NY_OLD_1099R_TRANSMITTER';
  l_formula_name_table(41) := 'NY_OLD_1099R_EMPLOYER';
  l_formula_name_table(42) := 'NY_OLD_1099R_EMPLOYEE';
  l_formula_name_table(43) := 'NY_OLD_1099R_TOTAL';
  l_formula_name_table(44) := 'NY_OLD_1099R_FINAL';

  --
  --
  -- Now we seed the formula descriptions of the formulas that we plan to seed.
  --
  hr_utility.trace('Seeding formula description table');
  --
  l_message := 'Seeding formula table descriptions';
  --
  l_description_table(1)  := '1099R File totals formula for retirement processing';
  l_description_table(2)  := '1099R Payees information formula';
  l_description_table(3)  := '1099R Payer information formula';
  l_description_table(4)  := '1099R Payer totals formula';
  l_description_table(5)  := '1099R Transmitter formula';
  l_description_table(6)  := '1099R State totals process formula';
  l_description_table(7)  := 'State 1099R Payees information formula';
  l_description_table(8)  := 'State 1099R Payer information formula';
  l_description_table(9)  := 'West Virginia 1099R Payees information formula';
  l_description_table(10) := 'West Virginia 1099R Payer information formula';
  l_description_table(11) := 'Indiana 1099R Employer Record formula';
  l_description_table(12) := 'Indiana 1099R Supplemental Record formula';
  l_description_table(13) := 'Indiana 1099R Final Record formula  ';
  l_description_table(14) := 'Indiana 1099R Transmitter Record formula  ';
  l_description_table(15) := 'Indiana 1099R Total Record formula  ';
  l_description_table(16) := 'NY 1099R Transmitter formula';
  l_description_table(17) := 'NY 1099R Employer Record formula';
  l_description_table(18) := 'NY 1099R Employee Record formula';
  l_description_table(19) := 'NY 1099R Total Record formula  ';
  l_description_table(20) := 'NY 1099R Final Record formula  ';

  l_description_table(21) := '1099R Transmitter formula for Fed Report (New Format)';
  l_description_table(22) := '1099R State totals process formula for Fed Report (New Format)';
  l_description_table(23) := '1099R Payer totals formula for Fed Report (New Format)';
  l_description_table(24) := '1099R File totals formula for Ferdal Report (New Format)';

  l_description_table(25) := 'Old 1099R File totals formula for retirement processing';
  l_description_table(26) := 'Old 1099R Payees information formula';
  l_description_table(27) := 'Old 1099R Payer information formula';
  l_description_table(28) := 'Old 1099R Payer totals formula';
  l_description_table(29) := 'Old 1099R Transmitter formula';
  l_description_table(30) := 'Old 1099R State totals process formula';
  l_description_table(31) := 'Old State 1099R Payees information formula';
  l_description_table(32) := 'Old State 1099R Payer information formula';
  l_description_table(33) := 'Old West Virginia 1099R Payees information formula';
  l_description_table(34) := 'Old West Virginia 1099R Payer information formula';
  l_description_table(35) := 'Old Indiana 1099R Employer Record formula';
  l_description_table(36) := 'Old Indiana 1099R Supplemental Record formula';
  l_description_table(37) := 'Old Indiana 1099R Final Record formula  ';
  l_description_table(38) := 'Old Indiana 1099R Transmitter Record formula  ';
  l_description_table(39) := 'Old Indiana 1099R Total Record formula  ';
  l_description_table(40) := 'Old NY 1099R Transmitter formula';
  l_description_table(41) := 'Old NY 1099R Employer Record formula';
  l_description_table(42) := 'Old NY 1099R Employee Record formula';
  l_description_table(43) := 'Old NY 1099R Total Record formula  ';
  l_description_table(44) := 'Old NY 1099R Final Record formula  ';

  --
  --
  -- **************************************************************************
  --                              SET FORMULA_TYPE_ID
  -- **************************************************************************
  --
  hr_utility.trace('Setting formula type id');
  --
  l_message := 'Setting formula type id';
  --
  -- Steps to set this variable are as follows :
  --  1) Open previously defined cursor
  --  2) Attempt to fetch row
  --  3) If row not found then raise error
  --  4) If not then continue processing
  --
  open c_formula_type_id;
    --
    fetch c_formula_type_id into l_formula_type_id;
    --
    if c_formula_type_id%notfound then
      --
      -- Raise error as formula id can not be found
      --
      raise NO_DATA_FOUND;
      --
    end if;
    --
  close c_formula_type_id;
  --
  -- *************************************************************************
  --                        SEED FF_FORMULAS_F TABLE
  -- *************************************************************************
  --
  hr_utility.trace('Seeding ff_formulas_f table');
  --
  l_message := 'Seeding ff_formulas_f table';
  --
  FOR l_count in 1..l_case_count LOOP

      -- **************************************************************************
      --                               DELETION STEPS
      -- **************************************************************************
      --
      -- This part of the procedure deletes all previous definitions from the
      -- FF_FORMULAS_F, FF_FDI_USAGES_F and FF_COMPILED_INFO_F tables.
      --
      l_message := 'Attempting to delete previous definitions of 1099R federal
                    formulas from FF_COMPILED_INFO_F for formula - ' ||
                                         l_formula_name_table(l_count);
      --
      -- Delete all cases where 1099R Federal Formulas have been compiled
      -- from FF_COMPILED_INFO_F
      --
      delete from ff_compiled_info_f fci
      where  fci.formula_id in (select ff.formula_id
                            from   ff_formulas_f ff
                            where  formula_name = l_formula_name_table(l_count));
      --
      l_message := 'Attempting to delete previous definitions of 1099R federal
                    formulas from FF_FDI_USAGES_F for formula - ' ||
                                         l_formula_name_table(l_count);
      --
      -- Delete all cases where 1099R Federal Formulas have been compiled
      -- from FF_FDI_USAGES_F
      --
      delete from ff_fdi_usages_f
       where formula_id in (select formula_id
                            from   ff_formulas_f
                            where  formula_name = l_formula_name_table(l_count));
      --
      hr_utility.trace('Attempting to delete previous definitions of 1099R federal
                       formulas from FF_FORMULAS_F');
      --
      l_message := 'Attempting to delete previous definitions of 1099R federal
                    formulas from FF_FORMULAS_F for formula name - '||
                                         l_formula_name_table(l_count);

      --
      -- Delete all cases where 1099R Federal Formulas have been seeded previously
      -- in the FF_FORMULAS_F table.
      --
      delete from ff_formulas_f ff
      where  ff.formula_name = l_formula_name_table(l_count);
      --
      --
      --
      hr_utility.trace('Getting sequence for next record to seed in
                       ff_formulas_f');
      --
      l_message := 'Getting sequence for next record to seed in ff_formulas_f';
      --
      select ff_formulas_s.nextval
      into   l_formula_id
      from   sys.dual;
      --
      hr_utility.trace('Seeding formula : '||l_formula_name_table(l_count));
      --
      l_message := 'Seeding formula : '||l_formula_name_table(l_count);
      --
      insert into ff_formulas_f
      (FORMULA_ID,
       EFFECTIVE_START_DATE,
       EFFECTIVE_END_DATE,
       BUSINESS_GROUP_ID,
       LEGISLATION_CODE,
       FORMULA_TYPE_ID,
       FORMULA_NAME,
       DESCRIPTION,
       FORMULA_TEXT,
       STICKY_FLAG,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       CREATED_BY,
       CREATION_DATE)
       values
       (l_formula_id,
       pay_1099R_formula_driver.c_start_of_time,
       pay_1099R_formula_driver.c_end_of_time,
       null,
       l_legislation_code,
       l_formula_type_id,
       l_formula_name_table(l_count),
       l_description_table(l_count),
       null,
       null,
       null,
       null,
       null,
       null,
       null);
       --
       hr_utility.trace('Seeding '||l_formula_name_table(l_count));
       --
  end loop;
  --
  hr_utility.trace('Successful');
  --
  COMMIT;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  --
  hr_utility.trace('ERROR : Cannot get formula type id for Application');
  --
  WHEN OTHERS THEN
  --
  hr_utility.trace('ERROR : ' ||l_message||' - ORA '||to_char(SQLCODE));
  hr_utility.trace('ERROR : ' ||l_message||' - ORA '||to_char(SQLCODE));
  --
END setup;
--
END pay_1099R_formula_driver;

/
