--------------------------------------------------------
--  DDL for Package Body BEN_EFC_STUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_STUBS" AS
/* $Header: beefcstb.pkb 120.0 2005/05/28 02:08:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_cust_mapped_rounding_code >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- For specific rounding codes, defined in hr_lookups for the lookup type
-- of BEN_RNDG, a mapping needs to be defined between the original
-- rounding code and the rounding code to be used after EFC conversion.
--
-- Post Success:
-- Should return the new rounding code.
--
-- ----------------------------------------------------------------------------
function get_cust_mapped_rounding_code
  (p_rndcd_table_name in     varchar2
  ,p_currency_code    in     varchar2
  ,p_rndcd_value      in     varchar2
  )
return varchar2
is
  --
BEGIN
  --
  -- The following is listed as an example only, and should be edited
  -- by the customer to reflect a customer's particular rounding codes.
  --
  if p_currency_code = 'ZZZ' then
    --
    if p_rndcd_table_name='BEN_ACTL_PREM_F' then
      --
      if p_rndcd_value = 'RTNRTTHO' then
        --
        return 'RTNRTEN';
        --
      else
        --
        return null;
        --
      end if;
      --
    elsif p_rndcd_table_name='BEN_ACTY_BASE_RT_F' then
      --
      return 'ZZZRNDCD2';
      --
    elsif p_rndcd_table_name='BEN_BNFT_POOL_RLOVR_RQMT_F' then
      --
      return 'ZZZRNDCD3';
      --
    elsif p_rndcd_table_name='BEN_BNFT_PRVDR_POOL_F' then
      --
      return 'ZZZRNDCD4';
      --
    elsif p_rndcd_table_name='BEN_COMP_LVL_FCTR' then
      --
      return 'ZZZRNDCD5';
      --
    elsif p_rndcd_table_name='BEN_CVG_AMT_CALC_MTHD_F' then
      --
      return 'ZZZRNDCD6';
      --
    elsif p_rndcd_table_name='BEN_POE_RT_F' then
      --
      return 'ZZZRNDCD7';
      --
    elsif p_rndcd_table_name='BEN_PRTL_MO_RT_PRTN_VAL_F' then
      --
      return 'ZZZRNDCD8';
      --
    elsif p_rndcd_table_name='BEN_VRBL_RT_PRFL_F' then
      --
      return 'ZZZRNDCD9';
      --
    end if;
    --
  else
    --
    return null;
    --
  end if;
  --
END get_cust_mapped_rounding_code;
--
END ben_efc_stubs;

/
