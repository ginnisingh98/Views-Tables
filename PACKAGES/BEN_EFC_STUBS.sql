--------------------------------------------------------
--  DDL for Package BEN_EFC_STUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_STUBS" AUTHID CURRENT_USER AS
/* $Header: beefcstb.pkh 120.0 2005/05/28 02:08:51 appldev noship $ */
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
return varchar2;
--
END ben_efc_stubs;

 

/
