--------------------------------------------------------
--  DDL for Package BEN_XRE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRE_RKU" AUTHID CURRENT_USER as
/* $Header: bexrerhi.pkh 120.0 2005/05/28 12:40:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_rslt_err_id                in number
 ,p_err_num                        in number
 ,p_err_txt                        in varchar2
 ,p_typ_cd                         in varchar2
 ,p_person_id                      in number
 ,p_business_group_id              in number
 ,p_object_version_number          in number
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_ext_rslt_id                    in number
 ,p_effective_date                 in date
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
end ben_xre_rku;

 

/
