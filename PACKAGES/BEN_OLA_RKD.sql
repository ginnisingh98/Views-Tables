--------------------------------------------------------
--  DDL for Package BEN_OLA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OLA_RKD" AUTHID CURRENT_USER as
/* $Header: beolarhi.pkh 120.0 2005/05/28 09:51:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_csr_activities_id              in number
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
end ben_ola_rkd;

 

/
