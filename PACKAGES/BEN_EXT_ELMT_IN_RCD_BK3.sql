--------------------------------------------------------
--  DDL for Package BEN_EXT_ELMT_IN_RCD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELMT_IN_RCD_BK3" AUTHID CURRENT_USER as
/* $Header: bexerapi.pkh 120.0 2005/05/28 12:32:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_ELMT_IN_RCD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_ELMT_IN_RCD_b
  (
   p_ext_data_elmt_in_rcd_id        in  number
  ,p_legislation_code               in varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_ELMT_IN_RCD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_ELMT_IN_RCD_a
  (
   p_ext_data_elmt_in_rcd_id        in  number
  ,p_legislation_code               in varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_ELMT_IN_RCD_bk3;

 

/
