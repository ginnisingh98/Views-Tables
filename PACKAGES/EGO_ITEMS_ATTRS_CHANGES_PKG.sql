--------------------------------------------------------
--  DDL for Package EGO_ITEMS_ATTRS_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEMS_ATTRS_CHANGES_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOIUACS.pls 115.1 2004/07/09 05:07:36 srajapar noship $ */

----------------------------------------------------------------------

PROCEDURE ADD_LANGUAGE;

  ----------------------------------------------------------------------------
  -- Start of Comments
  -- API name  : Deleting_Obj_Pending_Changes
  -- TYPE      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : Delete the pending changes from EGO_ITEMS_ATTRS_CHANGES_B
  --
  -- Parameters:
  --     IN    : p_api_version           NUMBER
  --           : p_object_name           VARCHAR2
  --           : p_instance_pk1_value    VARCHAR2
  --           : p_instance_pk2_value    VARCHAR2
  --           : p_instance_pk3_value    VARCHAR2
  --           : p_instance_pk4_value    VARCHAR2
  --           : p_instance_pk5_value    VARCHAR2
  --           : p_change_id             NUMBER
  --           : p_change_line_id        NUMBER
  --
  --    OUT    : x_return_status    VARCHAR2
  --             x_msg_count        NUMBER
  --             x_msg_data         VARCHAR2
  --
  ----------------------------------------------------------------------------
  PROCEDURE Deleting_Obj_Pending_Changes
  (p_api_version        IN  NUMBER
  ,p_object_name        IN  VARCHAR2
  ,p_instance_pk1_value IN  VARCHAR2
  ,p_instance_pk2_value IN  VARCHAR2
  ,p_instance_pk3_value IN  VARCHAR2
  ,p_instance_pk4_value IN  VARCHAR2
  ,p_instance_pk5_value IN  VARCHAR2
  ,p_change_id          IN  NUMBER
  ,p_change_line_id     IN  NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  );
----------------------------------------------------------------------

END EGO_ITEMS_ATTRS_CHANGES_PKG;


 

/
