--------------------------------------------------------
--  DDL for Package PER_BIL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BIL_RKD" AUTHID CURRENT_USER as
/* $Header: pebilrhi.pkh 115.7 2003/04/10 09:18:05 jheer noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_id_value                       in number
 ,p_type_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
 ,p_fk_value1_o                    in number
 ,p_fk_value2_o                    in number
 ,p_fk_value3_o                    in number
 ,p_text_value1_o                  in varchar2
 ,p_text_value2_o                  in varchar2
 ,p_text_value3_o                  in varchar2
 ,p_text_value4_o                  in varchar2
 ,p_text_value5_o                  in varchar2
 ,p_text_value6_o                  in varchar2
 ,p_text_value7_o                  in varchar2
 ,p_num_value1_o                   in number
 ,p_num_value2_o                   in number
 ,p_num_value3_o                   in number
 ,p_date_value1_o                  in date
 ,p_date_value2_o                  in date
 ,p_date_value3_o                  in date
  );
--
end per_bil_rkd;

 

/
