--------------------------------------------------------
--  DDL for Package BEN_XCT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCT_RKU" AUTHID CURRENT_USER as
/* $Header: bexctrhi.pkh 120.0 2005/05/28 12:27:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_crit_typ_id                in number
 ,p_crit_typ_cd                    in varchar2
 ,p_ext_crit_prfl_id               in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_excld_flag                     in varchar2
 ,p_crit_typ_cd_o                  in varchar2
 ,p_ext_crit_prfl_id_o             in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
 ,p_excld_flag_o                   in varchar2
  );
--
end ben_xct_rku;

 

/
