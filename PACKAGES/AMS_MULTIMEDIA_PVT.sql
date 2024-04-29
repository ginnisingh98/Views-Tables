--------------------------------------------------------
--  DDL for Package AMS_MULTIMEDIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MULTIMEDIA_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmuls.pls 115.0 2002/01/14 17:02:32 pkm ship      $ */

TYPE  multimedia_rec_type   IS RECORD (
  obj_lgl_ctnt_id	  NUMBER,
  create_delete_flag	  VARCHAR2(1),
  default_flag            VARCHAR2(1),
  obj_type_code           VARCHAR2(1),
  object_Version_Number   NUMBER,
  object_id               NUMBER,
  context_id              NUMBER,
  image_id 	          NUMBER );

---------------------------------------------------------------------
-- PROCEDURE
--    create_multimedia
--
---------------------------------------------------------------------

PROCEDURE Process_Multimedia
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,

  p_multi_rec           IN  multimedia_rec_type

  );


END AMS_Multimedia_PVT;

 

/
