--------------------------------------------------------
--  DDL for Package OTA_TCC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TCC_RKD" AUTHID CURRENT_USER as
/* $Header: ottccrhi.pkh 120.0 2005/05/29 07:36:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
 procedure after_delete
  (p_cross_charge_id              in number
  ,p_business_group_id_o          in number
  ,p_gl_set_of_books_id_o         in number
  ,p_object_version_number_o      in number
  ,p_type_o                       in varchar2
  ,p_from_to_o                    in varchar2
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  );
--
end ota_tcc_rkd;

 

/
