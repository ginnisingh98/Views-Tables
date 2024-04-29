--------------------------------------------------------
--  DDL for Package BEN_XCC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCC_RKI" AUTHID CURRENT_USER as
/* $Header: bexccrhi.pkh 120.0 2005/05/28 12:23:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ext_crit_cmbn_id               in number
 ,p_crit_typ_cd                    in varchar2
 ,p_oper_cd                        in varchar2
 ,p_val_1                          in varchar2
 ,p_val_2                          in varchar2
 ,p_ext_crit_val_id                in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_xcc_rki;

 

/
