--------------------------------------------------------
--  DDL for Package Body AHL_UC_UTILIZATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_UTILIZATION_PUB" AS
/* $Header: AHLPUCUB.pls 115.1 2002/12/04 19:08:48 sracha noship $ */


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UC_Utilization_PUB';


-----------------------------------------
-- Define Procedure for Utilization  --
-----------------------------------------
-- Start of Comments --
--  Procedure name    : Update_Utilization
--  Type        : Public
--  Function    : Updates the utilization based on the counter rules defined in the master configuration
--                given the details of an item/counter id/counter name/uom_code.
--                Casacades the updates down to all the children if the cascade_flag is set to 'Y'.
--  Pre-reqs    :
--  Parameters  :
--  Standard IN  Parameters :
--    p_api_version                   IN      NUMBER                Required
--    p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--    p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--    p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--    x_return_status                 OUT     VARCHAR2               Required
--    x_msg_count                     OUT     NUMBER                 Required
--    x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Utilization Parameters:
--
--    p_Utilization_tbl                IN      Required.
--      For each record, at any given time only one of the following combinations is valid to identify the
--      item instance to be updated:
--        1.  Organization id and Inventory_item_id    AND  Serial Number.
--            This information will identify the part number and serial number of a configuration.
--        2.  Counter ID -- if this is passed a specific counter ONLY will be updated irrespective of the value
--            of p_cascade_flag.
--        3.  CSI_ITEM_INSTANCE_ID -- if this is passed, then this item instance and items down the hierarchy (depends on
--            the value cascade_flag) will be updated.
--      At any given time only one of the following combinations is valid to identify the type of item counters to be
--      updated:
--        1.  UOM_CODE
--        2.  COUNTER_NAME
--
--      Reading_Value                 IN   Required.
--      This will be the value of the counter reading.
--
--      cascade_flag    -- Can take values Y and N. Y indicates that the counter updates will cascade down the hierarchy
--                      beginning at the item number passed. Ift its value is N then only the item counter will be updated.
--

-- End of Comments --


PROCEDURE Update_Utilization(p_api_version       IN            NUMBER,
                             p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
                             p_commit            IN            VARCHAR2  := FND_API.G_FALSE,
                             p_validation_level  IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
                             p_Utilization_tbl   IN            AHL_UC_Utilization_PVT.Utilization_Tbl_Type,
                             x_return_status     OUT  NOCOPY   VARCHAR2,
                             x_msg_count         OUT  NOCOPY   NUMBER,
                             x_msg_data          OUT  NOCOPY   VARCHAR2 ) IS

  l_api_version     CONSTANT NUMBER       := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Update_Utilization';

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Update_Utilization_Pub;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Call Private API.
  AHL_UC_UTILIZATION_PVT.Update_Utilization(
                             p_api_version     => 1.0,
                             p_Utilization_tbl => p_utilization_tbl,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data);

  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);



--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Update_Utilization_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Update_Utilization_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Update_Utilization_Pub;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Update_Utilization',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END  Update_Utilization;

END AHL_UC_Utilization_PUB;

/
