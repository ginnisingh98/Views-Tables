--------------------------------------------------------
--  DDL for Package BEN_XIC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XIC_RKI" AUTHID CURRENT_USER as
/* $Header: bexicrhi.pkh 120.2 2005/06/08 15:56:05 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ext_incl_chg_id                in number
 ,p_chg_evt_cd                     in varchar2
 ,p_chg_evt_source                 in varchar2
 ,p_ext_rcd_in_file_id             in number
 ,p_ext_data_elmt_in_rcd_id        in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_xic_rki;

 

/
