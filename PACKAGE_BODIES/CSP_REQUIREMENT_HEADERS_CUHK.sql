--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_HEADERS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_HEADERS_CUHK" AS
  /* $Header: cspcrqhb.pls 115.3 2002/11/26 08:06:33 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspcrqhb.pls';


  PROCEDURE Create_requirement_header_Pre
  ( px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
  l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_requirement_headers_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END Create_requirement_header_Pre;


  PROCEDURE  Create_requirement_header_post
  (
    px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
  l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_requirement_headers_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END create_requirement_header_post;


  PROCEDURE  Update_requirement_header_pre
  (
    px_requirement_header    IN OUT NOCOPY  CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
  l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_requirement_headers_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END Update_requirement_header_pre;

  PROCEDURE  Update_requirement_header_post
  (
    px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
  l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_requirement_headers_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END Update_requirement_header_post;
  PROCEDURE  Delete_requirement_header_pre
  (
    p_header_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
  l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_requirement_headers_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END Delete_requirement_header_pre;
  PROCEDURE  Delete_requirement_header_post
  (
    p_header_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
  l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_requirement_headers_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_requirement_headers_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END Delete_requirement_header_post;
END csp_requirement_headers_cuhk;

/
