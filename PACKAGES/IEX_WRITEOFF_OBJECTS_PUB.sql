--------------------------------------------------------
--  DDL for Package IEX_WRITEOFF_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WRITEOFF_OBJECTS_PUB" AUTHID CURRENT_USER as
/* $Header: iexpwobs.pls 120.0 2004/01/24 03:20:16 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_WRITEOFF_OBJECTS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

subtype writeoff_obj_rec_type         is iex_writeoff_objects_pvt.writeoff_obj_rec_type;
g_miss_writeoff_obj_rec_type          writeoff_obj_rec_type ;

------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME              CONSTANT VARCHAR2(200) := 'IEX_WRITEOFF_OBJECTS_PUB';
 G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_DEFAULT_NUM_REC_FETCH CONSTANT NUMBER := 30;
 G_YES                   CONSTANT VARCHAR2(1) := 'Y';
 G_NO                    CONSTANT VARCHAR2(1) := 'N';
------------------------------------------------------------------------------

PROCEDURE create_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_writeoff_obj_rec           IN   writeoff_obj_rec_type,
    X_writeoff_object_id         OUT  NOCOPY NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    );

PROCEDURE update_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_writeoff_obj_rec           IN   writeoff_obj_rec_type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT  NOCOPY NUMBER
    );

PROCEDURE  delete_writeoff_objects(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_writeoff_object_id         IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
     );


End IEX_WRITEOFF_OBJECTS_PUB;

 

/
