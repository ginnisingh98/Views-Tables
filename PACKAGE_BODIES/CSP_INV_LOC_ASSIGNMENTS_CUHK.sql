--------------------------------------------------------
--  DDL for Package Body CSP_INV_LOC_ASSIGNMENTS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_INV_LOC_ASSIGNMENTS_CUHK" AS
 /* $Header: cspcilab.pls 115.3 2002/11/26 08:09:38 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspcilab.pls';

  PROCEDURE create_inventory_location_Pre
  (
    px_inv_loc_assignment    IN OUT NOCOPY   CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
    l_api_name varchar2(200) := 'create_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_inv_loc_assignments_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END create_inventory_location_Pre;


  PROCEDURE  create_inventory_location_post
  (
    px_inv_loc_assignment    IN OUT NOCOPY   CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  )  IS
      l_api_name varchar2(200) := 'create_inventory_location_Post' ;
  BEGIN
    Savepoint csp_inv_loc_assignments_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );

END create_inventory_location_post;


  PROCEDURE  Update_inventory_location_pre
  (
    px_inv_loc_assignment    IN OUT NOCOPY  CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
      l_api_name varchar2(200) := 'Update_inventory_location_Pre' ;
  BEGIN
   Savepoint csp_inv_loc_assignments_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );
END Update_inventory_location_pre;


  PROCEDURE  Update_inventory_location_post
  (
    px_inv_loc_assignment    IN OUT NOCOPY   CSP_INV_LOC_ASSIGNMENTS_PKG.inv_loc_assignments_rec_type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
        l_api_name varchar2(200) := 'Update_inventory_location_post' ;
 BEGIN
  Savepoint csp_inv_loc_assignments_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );
END Update_inventory_location_post;
  PROCEDURE  Delete_inventory_location_pre
  (
    p_inv_loc_assignment_id  IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
   l_api_name varchar2(200) := 'Delete_inventory_location_Pre' ;
  BEGIN
  Savepoint csp_inv_loc_assignments_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );
  END Delete_inventory_location_pre;
  PROCEDURE  Delete_inventory_location_post
  (
    p_inv_loc_assignment_id  IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) IS
     l_api_name varchar2(200) := 'Delete_inventory_location_post' ;
  BEGIN
   Savepoint csp_inv_loc_assignments_cuhk;

    x_return_status := fnd_api.g_ret_sts_success;
    NULL;
-- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count,
                                p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN OTHERS THEN
        ROLLBACK TO csp_inv_loc_assignments_cuhk;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (    p_count => x_msg_count,
             p_data  => x_msg_data
        );
 END Delete_inventory_location_post;
END csp_inv_loc_assignments_cuhk;

/
