--------------------------------------------------------
--  DDL for Package BEN_XCC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCC_RKD" AUTHID CURRENT_USER as
/* $Header: bexccrhi.pkh 120.0 2005/05/28 12:23:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_crit_cmbn_id               in number
 ,p_crit_typ_cd_o                  in varchar2
 ,p_oper_cd_o                      in varchar2
 ,p_val_1_o                        in varchar2
 ,p_val_2_o                        in varchar2
 ,p_ext_crit_val_id_o              in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_xcc_rkd;

 

/
