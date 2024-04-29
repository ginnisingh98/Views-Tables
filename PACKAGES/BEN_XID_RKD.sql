--------------------------------------------------------
--  DDL for Package BEN_XID_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XID_RKD" AUTHID CURRENT_USER as
/* $Header: bexidrhi.pkh 120.0 2005/05/28 12:36:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_incl_data_elmt_id          in number
 ,p_ext_rcd_in_file_id_o           in number
 ,p_ext_data_elmt_id_o             in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
 ,p_ext_data_elmt_in_rcd_id_o      in number
  );
--
end ben_xid_rkd;

 

/
