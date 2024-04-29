--------------------------------------------------------
--  DDL for Package BEN_XID_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XID_RKI" AUTHID CURRENT_USER as
/* $Header: bexidrhi.pkh 120.0 2005/05/28 12:36:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ext_incl_data_elmt_id          in number
 ,p_ext_rcd_in_file_id             in number
 ,p_ext_data_elmt_id               in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_ext_data_elmt_in_rcd_id        in number
  );
end ben_xid_rki;

 

/
