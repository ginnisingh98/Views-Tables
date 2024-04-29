--------------------------------------------------------
--  DDL for Package BEN_OLA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OLA_RKU" AUTHID CURRENT_USER as
/* $Header: beolarhi.pkh 120.0 2005/05/28 09:51:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_csr_activities_id              in number
 ,p_ordr_num                       in number
 ,p_function_name                  in varchar2
 ,p_user_function_name             in varchar2
 ,p_function_type                  in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_start_date                     in date
 ,p_end_date                       in date
 ,p_ordr_num_o                     in number
 ,p_function_name_o                in varchar2
 ,p_user_function_name_o           in varchar2
 ,p_function_type_o                in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
 ,p_start_date_o                   in date
 ,p_end_date_o                     in date
  );
--
end ben_ola_rku;

 

/
