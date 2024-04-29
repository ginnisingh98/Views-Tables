--------------------------------------------------------
--  DDL for Package PER_BIL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BIL_RKI" AUTHID CURRENT_USER as
/* $Header: pebilrhi.pkh 115.7 2003/04/10 09:18:05 jheer noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_type                           in varchar2
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_id_value                       in number
 ,p_fk_value1                      in number
 ,p_fk_value2                      in number
 ,p_fk_value3                      in number
 ,p_text_value1                    in varchar2
 ,p_text_value2                    in varchar2
 ,p_text_value3                    in varchar2
 ,p_text_value4                    in varchar2
 ,p_text_value5                    in varchar2
 ,p_text_value6                    in varchar2
 ,p_text_value7                    in varchar2
 ,p_num_value1                     in number
 ,p_num_value2                     in number
 ,p_num_value3                     in number
 ,p_date_value1                    in date
 ,p_date_value2                    in date
 ,p_date_value3                    in date
  );
end per_bil_rki;

 

/
