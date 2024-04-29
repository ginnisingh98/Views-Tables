--------------------------------------------------------
--  DDL for Package BEN_BAI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BAI_RKD" AUTHID CURRENT_USER as
/* $Header: bebairhi.pkh 120.0 2005/05/28 00:33:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_batch_actn_item_id             in number
 ,p_benefit_action_id_o            in number
 ,p_person_id_o                    in number
 ,p_actn_typ_id_o                  in number
 ,p_cmpltd_dt_o                    in date
 ,p_due_dt_o                       in date
 ,p_rqd_flag_o                     in varchar2
 ,p_actn_cd_o                      in varchar2
 ,p_business_group_id_o            in number
 ,p_object_version_number_o        in number
  );
--
end ben_bai_rkd;

 

/
