--------------------------------------------------------
--  DDL for Package AMS_APPROVAL_SUBMIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_APPROVAL_SUBMIT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvapss.pls 115.0 2002/12/01 12:57:47 vmodur noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ams_approval_detail_pvt';

PROCEDURE Submit_Approval(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   p_object_id         IN  NUMBER,
   p_object_type       IN  VARCHAR2,
   p_new_status_id     IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

End Ams_Approval_Submit_Pvt;

 

/
