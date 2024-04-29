--------------------------------------------------------
--  DDL for Package BEN_CTK_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTK_RKU" AUTHID CURRENT_USER as
/* $Header: bectkrhi.pkh 120.0 2005/05/28 01:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_group_per_in_ler_id          in number
  ,p_task_id                      in number
  ,p_group_pl_id                  in number
  ,p_lf_evt_ocrd_dt               in date
  ,p_status_cd                    in varchar2
  ,p_access_cd                    in varchar2
  ,p_task_last_update_date        in date
  ,p_task_last_update_by          in number
  ,p_object_version_number        in number
  ,p_group_pl_id_o                in number
  ,p_lf_evt_ocrd_dt_o             in date
  ,p_status_cd_o                  in varchar2
  ,p_access_cd_o                  in varchar2
  ,p_task_last_update_date_o      in date
  ,p_task_last_update_by_o        in number
  ,p_object_version_number_o      in number
  );
--
end ben_ctk_rku;

 

/