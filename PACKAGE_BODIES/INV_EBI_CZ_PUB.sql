--------------------------------------------------------
--  DDL for Package Body INV_EBI_CZ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EBI_CZ_PUB" AS
/* $Header: INVEIPCZB.pls 120.0.12010000.3 2009/08/21 09:25:22 smukka noship $ */

PROCEDURE process_init_msg(
   p_profile_name        IN           VARCHAR2
  ,p_inventory_item_id   IN           NUMBER
  ,p_organization_id     IN           NUMBER
  ,x_profile_value       OUT NOCOPY   VARCHAR2
  ,x_database_id         OUT NOCOPY   VARCHAR2
  ,x_system_id           OUT NOCOPY   VARCHAR2
  ,x_return_status       OUT NOCOPY   VARCHAR2
  ,x_msg_count           OUT NOCOPY   NUMBER
  ,x_msg_data            OUT NOCOPY   VARCHAR2

 ) AS

   l_bom_item_type_code     mtl_system_items_b.bom_item_type%TYPE;
   l_item_number            mtl_system_items_kfv.concatenated_segments%TYPE;

  BEGIN

    FND_MSG_PUB.initialize;
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    IF( p_inventory_item_id IS NOT NULL AND
        p_inventory_item_id <> fnd_api.g_miss_num AND
        p_organization_id IS NOT NULL AND
        p_organization_id <> fnd_api.g_miss_num) THEN

      SELECT bom_item_type ,concatenated_segments
      INTO l_bom_item_type_code ,l_item_number
      FROM mtl_system_items_kfv
      WHERE
        inventory_item_id = p_inventory_item_id AND
        organization_id   = p_organization_id;

    END IF;

    IF(NVL(l_bom_item_type_code,4) <> 1) THEN

      FND_MESSAGE.set_name('INV','INV_EBI_CONFIG_NOT_A_MODEL');
      FND_MESSAGE.set_token('ITEM', l_item_number);
      FND_MSG_PUB.add;
      RAISE  FND_API.g_exc_error;

    END IF;

    IF(p_profile_name IS NOT NULL AND p_profile_name <> fnd_api.g_miss_char) THEN

      SELECT fpov.PROFILE_OPTION_VALUE  INTO x_profile_value
      FROM FND_PROFILE_OPTION_VALUES fpov,FND_PROFILE_OPTIONS fpo
      WHERE fpov.PROFILE_OPTION_ID = fpo.PROFILE_OPTION_ID
        AND fpo.PROFILE_OPTION_NAME = p_profile_name;

    END IF;

    x_database_id := FND_WEB_CONFIG.database_id;

    select instance_name INTO x_system_id from v$instance;


EXCEPTION
  WHEN FND_API.g_exc_error THEN

     x_return_status :=  FND_API.g_ret_sts_error;

     IF(x_msg_data IS NULL) THEN
       FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
       );
     END IF;

  WHEN OTHERS THEN
     x_return_status := FND_API.g_ret_sts_unexp_error;

     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> INV_EBI_CZ_PUB.process_cz_init_msg ';
     ELSE
       x_msg_data      :=  SQLERRM||' INV_EBI_CZ_PUB.process_cz_init_msg ';
      END IF;

END process_init_msg;

END INV_EBI_CZ_PUB;

/
