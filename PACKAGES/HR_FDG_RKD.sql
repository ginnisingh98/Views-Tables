--------------------------------------------------------
--  DDL for Package HR_FDG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FDG_RKD" AUTHID CURRENT_USER as
/* $Header: hrfdgrhi.pkh 120.0 2005/05/31 00:17:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_data_group_id           in number
  ,p_object_version_number_o      in number
  ,p_application_id_o             in number
  ,p_form_id_o                    in number
  ,p_data_group_name_o            in varchar2
  );
--
end hr_fdg_rkd;

 

/
