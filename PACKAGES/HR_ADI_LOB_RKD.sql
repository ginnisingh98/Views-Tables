--------------------------------------------------------
--  DDL for Package HR_ADI_LOB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ADI_LOB_RKD" AUTHID CURRENT_USER as
/* $Header: hrlobrhi.pkh 120.0 2005/05/31 01:18:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_file_id                      in number
  ,p_file_name_o                  in varchar2
  ,p_file_content_type_o          in varchar2
  ,p_upload_date_o                in date
  ,p_program_name_o               in varchar2
  ,p_program_tag_o                in varchar2
  ,p_file_format_o                in varchar2
  );
--
end hr_adi_lob_rkd;

 

/
