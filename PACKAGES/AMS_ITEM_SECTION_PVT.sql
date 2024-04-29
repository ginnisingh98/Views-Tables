--------------------------------------------------------
--  DDL for Package AMS_ITEM_SECTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ITEM_SECTION_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvpses.pls 115.2 2002/07/16 18:08:34 musman noship $*/

TYPE  section_rec_type   IS RECORD (
   section_id             NUMBER   :=  FND_API.G_MISS_NUM
  ,inventory_item_id      NUMBER   :=  FND_API.G_MISS_NUM
  ,organization_id        NUMBER   :=  FND_API.G_MISS_NUM
  ,start_date             DATE     :=  FND_API.G_MISS_DATE
  ,end_date               DATE	   :=  FND_API.g_MISS_DATE
);


---------------------------------------------------------------------
-- PROCEDURE
--    create_item_sec_assoc
--
---------------------------------------------------------------------

PROCEDURE create_item_sec_assoc
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,

  p_section_rec         IN  section_rec_type

  );


---------------------------------------------------------------------
-- PROCEDURE
--    delete_item_sec_assoc
--
---------------------------------------------------------------------

PROCEDURE delete_item_sec_assoc
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,

  p_section_rec         IN  section_rec_type

  );

END AMS_item_section_PVT;

 

/
