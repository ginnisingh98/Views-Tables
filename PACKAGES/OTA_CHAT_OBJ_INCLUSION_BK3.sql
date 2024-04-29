--------------------------------------------------------
--  DDL for Package OTA_CHAT_OBJ_INCLUSION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_OBJ_INCLUSION_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_chat_obj_inclusion_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_chat_obj_inclusion_b
  (p_chat_id                      in     number
  ,p_object_id                    in     number
  ,p_object_type                  in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_chat_obj_inclusion_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_chat_obj_inclusion_a
  (p_chat_id                      in     number
  ,p_object_id                    in     number
  ,p_object_type                  in     varchar2
  ,p_object_version_number         in     number
  );
--
end ota_chat_obj_inclusion_bk3;

 

/
