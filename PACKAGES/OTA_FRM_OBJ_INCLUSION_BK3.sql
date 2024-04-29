--------------------------------------------------------
--  DDL for Package OTA_FRM_OBJ_INCLUSION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_OBJ_INCLUSION_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_frm_obj_inclusion_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_frm_obj_inclusion_b
  ( p_forum_id                      in     number
  ,p_object_id                     in     number
  ,p_object_type                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_frm_obj_inclusion_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_frm_obj_inclusion_a
  ( p_forum_id                      in     number
  ,p_object_id                     in     number
  ,p_object_type                   in     varchar2
  ,p_object_version_number         in     number
  );
--
end ota_frm_obj_inclusion_bk3;

 

/
