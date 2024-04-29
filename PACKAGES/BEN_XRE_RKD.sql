--------------------------------------------------------
--  DDL for Package BEN_XRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRE_RKD" AUTHID CURRENT_USER as
/* $Header: bexrerhi.pkh 120.0 2005/05/28 12:40:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_rslt_err_id                in number
 ,p_err_num_o                      in number
 ,p_err_txt_o                      in varchar2
 ,p_typ_cd_o                       in varchar2
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_ext_rslt_id_o                  in number
  );
--
end ben_xre_rkd;

 

/
