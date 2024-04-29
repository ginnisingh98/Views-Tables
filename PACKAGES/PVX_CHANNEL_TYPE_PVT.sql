--------------------------------------------------------
--  DDL for Package PVX_CHANNEL_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_CHANNEL_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxchnls.pls 115.6 2002/11/20 02:06:01 pklin ship $ */

TYPE channel_type_rec_type is RECORD
(
   CHANNEL_TYPE_ID             NUMBER,
   CHANNEL_LOOKUP_TYPE         VARCHAR2(30),
   CHANNEL_LOOKUP_CODE         VARCHAR2(30),
   INDIRECT_CHANNEL_FLAG       VARCHAR2(1),
   LAST_UPDATE_DATE            DATE,
   LAST_UPDATED_BY             NUMBER,
   CREATION_DATE               DATE,
   CREATED_BY                  NUMBER,
   LAST_UPDATE_LOGIN           NUMBER,
   OBJECT_VERSION_NUMBER       NUMBER,
   RANK			       NUMBER
);


PROCEDURE Create_channel_type(
   p_api_version       IN  NUMBER    := 1.0
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_channel_type_rec  IN  channel_type_rec_type
  ,x_channel_type_id   OUT NOCOPY NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE Delete_channel_type(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_channel_type_id   IN  NUMBER
  ,p_object_version    IN  NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE Update_channel_type(
   p_api_version       IN  NUMBER    := 1.0
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_channel_type_rec  IN  channel_type_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE Complete_channel_type_rec(
   p_channel_type_rec   IN  channel_type_rec_type
  ,x_complete_rec       OUT NOCOPY channel_type_rec_type
);

END pvx_channel_type_pvt;

 

/
