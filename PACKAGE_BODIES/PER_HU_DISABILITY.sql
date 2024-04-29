--------------------------------------------------------
--  DDL for Package Body PER_HU_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_DISABILITY" as
/* $Header: pehudisp.pkb 120.1 2006/09/21 09:07:14 mgettins noship $ */
PROCEDURE check_hu_disability(p_category varchar2
                              ,p_degree number) is

BEGIN
/*if p_degree is not null then
        if p_category='HU_WC_LT_50_PERC' then
           if  (p_degree >=50) then
                hr_utility.set_message(800,'HR_HU_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
           end if;
        elsif p_category='HU_WC_50_PERC' then
            if  (p_degree <> 50 ) then
                hr_utility.set_message(800,'HR_HU_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
           end if;
        elsif p_category='HU_WC_GT_67_PERC' then
            if (p_degree <=67) then
                hr_utility.set_message(800,'HR_HU_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
           end if;
        elsif p_category='HU_WC_67_PERC' then
            if (p_degree <>67) then
                hr_utility.set_message(800,'HR_HU_INVALID_DIS_DEGREE');
                hr_utility.raise_error;
           end if;
        end if;
   end if;*/
   null;
END check_hu_disability;

PROCEDURE create_hu_disability(p_category varchar2
                              ,p_degree number) is

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    --per_hu_disability.check_hu_disability(p_category => p_category
    --                                     ,p_degree   => p_degree);
    null;
	--
  END IF;
END create_hu_disability;
--

PROCEDURE update_hu_disability(p_category varchar2
                              ,p_degree number) is
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
     --
     --per_hu_disability.check_hu_disability(p_category => p_category
     --                                   ,p_degree   => p_degree);
     null;
	 --
  END IF;
  --
END update_hu_disability;

END PER_HU_DISABILITY;

/
