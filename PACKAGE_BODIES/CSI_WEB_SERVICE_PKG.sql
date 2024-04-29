--------------------------------------------------------
--  DDL for Package Body CSI_WEB_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_WEB_SERVICE_PKG" AS
/* $Header: csiwsb.pls 120.1 2007/12/04 17:40:57 fli noship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSI_WEB_SERVICE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csiwsb.pls';

/*----------------------------------------------------------*/
/* procedure name: get_item_instance_obj                    */
/* description :   procedure used to get instance details   */
/*                 given the instance id or instance number */
/*----------------------------------------------------------*/
PROCEDURE get_item_instance_obj
( p_api_version           IN  NUMBER,
  p_commit                IN  VARCHAR2 := FND_API.g_FALSE,
  p_init_msg_list         IN  VARCHAR2 := FND_API.g_FALSE,
  p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_instance_id           IN  NUMBER,
  p_instance_number       IN  VARCHAR2,
  x_item_instance_obj     OUT NOCOPY  CSI_ITEM_INSTANCE_OBJ,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'get_item_instance_obj';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_debug_level           NUMBER;
  l_instance_id           NUMBER;
  l_msg_index             NUMBER;
  l_msg_count             NUMBER;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT get_item_instance_obj;

  -- Check for freeze_flag in csi_install_parameters is set to 'Y'
  csi_utility_grp.check_ib_active;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    csi_gen_utility_pvt.put_line('Incompatible API call');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Check the profile option debug_level for debug message reporting
  l_debug_level := fnd_profile.value('CSI_DEBUG_LEVEL');

  -- If debug_level = 1 then dump the procedure name
  IF (l_debug_level > 0) THEN
    csi_gen_utility_pvt.put_line('CSI_WEB_SERVICE_PKG.get_item_instance_obj');
  END IF;

  -- If the debug level = 2 then dump all the parameters values.
  IF (l_debug_level > 1) THEN
    csi_gen_utility_pvt.put_line('get_item_instance_obj '    ||
                                  p_api_version         ||'-'||
                                  p_commit              ||'-'||
                                  p_init_msg_list       ||'-'||
                                  p_validation_level );
    csi_gen_utility_pvt.put_line('  Instance Id     : '||p_instance_id);
    csi_gen_utility_pvt.put_line('  Instance Number : '||p_instance_number);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_instance_id IS NOT NULL THEN
    IF p_instance_number IS NOT NULL THEN
      BEGIN
        SELECT  csi.instance_id
        INTO    l_instance_id
        FROM    csi_item_instances csi
        WHERE   csi.instance_id = p_instance_id
        AND     csi.instance_number = p_instance_number;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line('  ERROR-CSI_CANT_GET_ITEM_INSTANCE: '
              ||'No item found with instance id '||p_instance_id
              ||' and instance number '||p_instance_number);
          END IF;
          FND_MESSAGE.SET_NAME('CSI','CSI_CANT_GET_ITEM_INSTANCE');
	  FND_MESSAGE.SET_TOKEN('ERROR','No item found with instance id '
            ||p_instance_id||' and instance number '||p_instance_number);
	  FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          IF (l_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line('  ERROR-CSI_CANT_GET_ITEM_INSTANCE: '
              ||SQLERRM);
          END IF;
          FND_MESSAGE.SET_NAME('CSI','CSI_CANT_GET_ITEM_INSTANCE');
	  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	  FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END;
    ELSE
      l_instance_id := p_instance_id;
    END IF;
  ELSIF p_instance_number IS NOT NULL THEN
    BEGIN
      SELECT  csi.instance_id
      INTO    l_instance_id
      FROM    csi_item_instances csi
      WHERE   csi.instance_number = p_instance_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug_level > 1) THEN
          csi_gen_utility_pvt.put_line('  ERROR-CSI_CANT_GET_ITEM_INSTANCE: '
            ||'No item found with instance number '||p_instance_number);
        END IF;
        FND_MESSAGE.SET_NAME('CSI','CSI_CANT_GET_ITEM_INSTANCE');
        FND_MESSAGE.SET_TOKEN('ERROR','No item found with instance number '
          ||p_instance_number);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
        IF (l_debug_level > 1) THEN
          csi_gen_utility_pvt.put_line('  ERROR-CSI_CANT_GET_ITEM_INSTANCE: '
            ||SQLERRM);
        END IF;
        FND_MESSAGE.SET_NAME('CSI','CSI_CANT_GET_ITEM_INSTANCE');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  ELSE
    IF (l_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line('  ERROR-CSI_CANT_GET_ITEM_INSTANCE: '
        ||'Must specify at least instance id or instance number');
    END IF;
    FND_MESSAGE.SET_NAME('CSI','CSI_CANT_GET_ITEM_INSTANCE');
    FND_MESSAGE.SET_TOKEN('ERROR','Must specify at least instance id or instance number');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_instance_id IS NOT NULL THEN
    x_item_instance_obj := CSI_ITEM_INSTANCE_OBJ(l_instance_id);
  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO get_item_instance_obj;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                              l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END get_item_instance_obj;

END;

/
