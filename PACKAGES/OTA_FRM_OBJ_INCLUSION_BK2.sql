--------------------------------------------------------
--  DDL for Package OTA_FRM_OBJ_INCLUSION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_OBJ_INCLUSION_BK2" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_frm_obj_inclusion_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_frm_obj_inclusion_b
( p_effective_date               in  date
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_primary_flag                 in  varchar2
  ,p_start_date_active            in  date
  ,p_end_date_active              in  date
  ,p_forum_id                     in  number
  ,p_object_version_number        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_frm_obj_inclusion_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_frm_obj_inclusion_a
  (p_effective_date               in  date
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_primary_flag                 in  varchar2
  ,p_start_date_active            in  date
  ,p_end_date_active              in  date
  ,p_forum_id                     in  number
  ,p_object_version_number        in number
  );

end ota_frm_obj_inclusion_bk2 ;

 

/