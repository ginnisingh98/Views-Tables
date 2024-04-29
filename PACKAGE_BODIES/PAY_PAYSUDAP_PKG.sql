--------------------------------------------------------
--  DDL for Package Body PAY_PAYSUDAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYSUDAP_PKG" PAY_PAYSUDAP_PKG	AS
/* $Header: pyappab.pkb 115.1 99/07/17 05:42:13 porting ship $ */
--
--
--
PROCEDURE BAND_OVERLAP( p_accrual_plan_id IN number,
                        p_accrual_band_id IN number,
                        p_lower_limit     IN number,
                        p_upper_limit     IN number) IS
--
   l_comb_exists VARCHAR2(2);
--
   CURSOR dup_rec IS
   select 'Y'
   from   pay_accrual_bands
   where (p_lower_limit between lower_limit and upper_limit
     or
          p_upper_limit between lower_limit and upper_limit
     or
          lower_limit between p_lower_limit and p_upper_limit
     or
          upper_limit between p_lower_limit and p_upper_limit)
   and  ((p_accrual_band_id is null)
     or  (p_accrual_band_id is not null
      and accrual_band_id <> p_accrual_band_id))
   and    accrual_plan_id = p_accrual_plan_id;
--
BEGIN
--
   l_comb_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN dup_rec;
   FETCH dup_rec INTO l_comb_exists;
   CLOSE dup_rec;
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- record is duplicated
--
   IF (l_comb_exists = 'Y') THEN
      hr_utility.set_message(801, 'HR_13161_PTO_BAND_OVERLAP');
      hr_utility.raise_error;
   END IF;
--
--
END BAND_OVERLAP;
--
PROCEDURE CEILING_CHECK( p_accrual_band_id IN number,
                         p_accrual_plan_id IN number,
                         p_ceiling         IN number) IS
--
   l_record_exists VARCHAR2(2);
--
   CURSOR dup_rec IS
   select 'Y'
   from   pay_accrual_bands
   where  accrual_plan_id = p_accrual_plan_id
   and   (p_accrual_band_id is null
     or   p_accrual_band_id is not null
      and accrual_band_id <> p_accrual_band_id)
   and  ((p_ceiling is null
      and ceiling is not null)
     or  (p_ceiling is not null
      and ceiling is null));
--
BEGIN
--
   l_record_exists := 'N';
--
-- open fetch and close the cursor - if a record is found then the local
-- variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN dup_rec;
   FETCH dup_rec INTO l_record_exists;
   CLOSE dup_rec;
--
-- go ahead and check the value of the local variable - if it's 'Y' then this
-- record is duplicated
--
   IF (l_record_exists = 'Y') THEN
      hr_utility.set_message(801, 'HR_13165_PTO_INVALID_CEILING');
      hr_utility.raise_error;
   END IF;
--
--
END CEILING_CHECK;
--
--
--
END ;

/
