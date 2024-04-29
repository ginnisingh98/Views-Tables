--------------------------------------------------------
--  DDL for Package Body WMS_CONTAINER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONTAINER_GRP" AS
/* $Header: WMSGCNTB.pls 120.5 2005/08/05 16:23:22 qxliu noship $ */

--  Global constant holding the package name
g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_CONTAINER_GRP';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSGCNTB.pls 120.5 2005/08/05 16:23:22 qxliu noship $';

-- Various debug levels
G_ERROR     CONSTANT NUMBER := 1;
G_INFO      CONSTANT NUMBER := 5;
G_MESSAGE   CONSTANT NUMBER := 9;

PROCEDURE mdebug(msg IN VARCHAR2, LEVEL NUMBER := G_MESSAGE) IS
BEGIN
  INV_TRX_UTIL_PUB.TRACE(msg, g_pkg_name, LEVEL);
END;

PROCEDURE Auto_Create_LPNs (
  p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2
, p_commit        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_caller        IN         VARCHAR2
, p_gen_lpn_rec   IN         WMS_Data_Type_Definitions_PUB.AutoCreateLPNRecordType
, p_lpn_table     OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
) IS

  l_debug number;
  l_api_name VARCHAR2(20);

  l_msgdata VARCHAR2(1000);
  l_ucc_128_suffix_flag VARCHAR2(1);
  l_serial_range WMS_Data_Type_Definitions_PUB.SerialRangeTableType;
  l_lpn_attr WMS_Data_Type_Definitions_PUB.LPNRecordType;

BEGIN
  l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_api_name := 'Auto_Create_LPNs';

  x_return_status := fnd_api.g_ret_sts_success;

  /* Validate input parameters in p_gen_lpn_rec */
  /* Required parameters: organization_id, quantity */
  IF p_gen_lpn_rec.organization_id IS NULL THEN
      IF (l_debug = 1) THEN
          mdebug('Organization is required, can not auto create LPN ');
      END IF;
      fnd_message.set_name('INV','INV_ORG_REQUIRED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

  ELSIF p_gen_lpn_rec.quantity IS NULL THEN
      IF (l_debug = 1) THEN
          mdebug('Quantity is required, can not auto create LPN ');
      END IF;
      fnd_message.set_name('WMS','WMS_QUANTITY_REQUIRED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

  END IF;

  /* Set value for ucc_128_suffix_flag
     1 - Y
     2 - N
  */
  IF p_gen_lpn_rec.ucc_128_suffix_flag = 1 THEN
      l_ucc_128_suffix_flag := 'Y';
  ELSIF p_gen_lpn_rec.ucc_128_suffix_flag = 2 THEN
      l_ucc_128_suffix_flag := 'N';
  ELSE
      /* Invalid value for ucc_128_suffix_flag, set it to N */
      IF (l_debug = 1) THEN
          mdebug('Invalid value for ucc_128_suffix_flag '||p_gen_lpn_rec.ucc_128_suffix_flag||', consider it as N');
      END IF;
      l_ucc_128_suffix_flag := 'N';
  END IF;


  /* Set value for p_lpn_attributes */
  l_lpn_attr.organization_id   := p_gen_lpn_rec.organization_id;
  l_lpn_attr.source_transaction_id := p_gen_lpn_rec.source_transaction_id;
  l_lpn_attr.subinventory_code := p_gen_lpn_rec.subinventory_code;
  l_lpn_attr.locator_id        := p_gen_lpn_rec.locator_id;
  l_lpn_attr.inventory_item_id := p_gen_lpn_rec.container_item_id;
  l_lpn_attr.lpn_context       := p_gen_lpn_rec.lpn_context;

  /* Call Auto_Create_LPNs prcedure in private package */
  WMS_CONTAINER_PVT.Auto_Create_LPNs (
    p_api_version         =>   p_api_version
  , p_init_msg_list       =>   p_init_msg_list
  , p_commit              =>   p_commit
  , x_return_status       =>   x_return_status
  , x_msg_count           =>   x_msg_count
  , x_msg_data            =>   x_msg_data
  , p_caller              =>   p_caller

  , p_quantity            =>   p_gen_lpn_rec.quantity
  , p_lpn_prefix          =>   p_gen_lpn_rec.lpn_prefix
  , p_lpn_suffix          =>   p_gen_lpn_rec.lpn_suffix
  , p_starting_number     =>   p_gen_lpn_rec.starting_num
  , p_total_lpn_length    =>   p_gen_lpn_rec.total_lpn_length
  , p_ucc_128_suffix_flag =>   l_ucc_128_suffix_flag

  , p_lpn_attributes      =>   l_lpn_attr
  , p_serial_ranges       =>   l_serial_range
  , x_created_lpns        =>   p_lpn_table
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;

END Auto_Create_LPNs;

PROCEDURE Create_LPNs (
  p_api_version   IN            NUMBER
, p_init_msg_list IN            VARCHAR2
, p_commit        IN            VARCHAR2
, x_return_status OUT    NOCOPY VARCHAR2
, x_msg_count     OUT    NOCOPY NUMBER
, x_msg_data      OUT    NOCOPY VARCHAR2
, p_caller        IN            VARCHAR2
, p_lpn_table     IN OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
) IS
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  /* Call Create_LPNs prcedure in private package */
  WMS_CONTAINER_PVT.Create_LPNs (
    p_api_version    =>   p_api_version
  , p_init_msg_list  =>   p_init_msg_list
  , p_commit         =>   p_commit
  , x_return_status  =>   x_return_status
  , x_msg_count      =>   x_msg_count
  , x_msg_data       =>   x_msg_data
  , p_caller         =>   p_caller
  , p_lpn_table      =>   p_lpn_table
  );

END Create_LPNs;

PROCEDURE Modify_LPNs (
  p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2
, p_commit        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_caller        IN         VARCHAR2
, p_lpn_table     IN         WMS_Data_Type_Definitions_PUB.LPNTableType
) IS
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;

  /* Call Modify_LPNs prcedure in private package */
  WMS_CONTAINER_PVT.Modify_LPNs (
    p_api_version   =>   p_api_version
  , p_init_msg_list =>   p_init_msg_list
  , p_commit        =>   p_commit
  , x_return_status =>   x_return_status
  , x_msg_count     =>   x_msg_count
  , x_msg_data      =>   x_msg_data
  , p_caller        =>   p_caller
  , p_lpn_table     =>   p_lpn_table
  );

END Modify_LPNs;

PROCEDURE LPN_Purge_Actions (
  p_api_version   IN            NUMBER
, p_init_msg_list IN            VARCHAR2
, p_commit        IN            VARCHAR2
, x_return_status OUT    NOCOPY VARCHAR2
, x_msg_count     OUT    NOCOPY NUMBER
, x_msg_data      OUT    NOCOPY VARCHAR2
, p_caller        IN            VARCHAR2
, p_action        IN            VARCHAR2
, p_lpn_purge_rec IN OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNPurgeRecordType
) IS

  l_debug number;
  l_api_name VARCHAR2(20);
  l_valid_lpns WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType;
  l_purge_count WMS_DATA_TYPE_DEFINITIONS_PUB.NumberTableType;
  l_msgdata VARCHAR2(1000);

BEGIN
  l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  l_api_name := 'LPN_Purge_Actions';

  x_return_status := fnd_api.g_ret_sts_success;

  IF (l_debug = 1) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version);
    mdebug('ver='||p_api_version||' initmsg='||p_init_msg_list||' commit='||p_commit||' caller='||p_caller);
    mdebug('p_action='||p_action||' p_lpn_purge_rec.lpn_ids has '||p_lpn_purge_rec.lpn_ids.count||' records');
  END IF;

  l_valid_lpns := p_lpn_purge_rec.lpn_ids;

  IF (p_action = G_LPN_PURGE_ACTION_VALIDATE) THEN
    -- Validate only
    -- Call WMS_PURGE_PVT.Check_Purge_LPNs
    --  with p_lock_flag as 'N'
    IF (l_debug = 1 ) THEN
      mdebug('Validate only, Calling WMS_PURGE_PVT.Check_Purge_LPNs with p_lock_flag as N');
    END IF;

    WMS_PURGE_PVT.Check_Purge_LPNs(
      p_api_version     =>  p_api_version
    , p_init_msg_list   =>  p_init_msg_list
    , p_commit          =>  p_commit
    , x_return_status   =>  x_return_status
    , x_msg_count       =>  x_msg_count
    , x_msg_data        =>  x_msg_data
    , p_caller          =>  p_caller
    , p_lock_flag       =>  'N'
    , p_lpn_id_table    =>  l_valid_lpns
    );

    IF x_return_status = fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
        mdebug('Number of validated LPNs: '||l_valid_lpns.count);
      END IF;
      p_lpn_purge_rec.lpn_ids := l_valid_lpns;
    ELSE
      IF (l_debug = 1) THEN
        mdebug('Error calling Check_Purge_LPNs');
      END IF;
    END IF;

  ELSIF (p_action = G_LPN_PURGE_ACTION_DELETE) THEN
    -- Validate then delete
    -- Call WMS_PURGE_PVT.Check_Purge_LPNs
    --  with p_lock_flag as 'Y'
    -- Then call WMS_PURGE_PVT.Purge_LPNs to delete LPNs
    IF (l_debug = 1 ) THEN
      mdebug('Validate, Calling WMS_PURGE_PVT.Check_Purge_LPNs with p_lock_flag as Y');
    END IF;

    WMS_PURGE_PVT.Check_Purge_LPNs(
      p_api_version     =>  p_api_version
    , p_init_msg_list   =>  p_init_msg_list
    , p_commit          =>  p_commit
    , x_return_status   =>  x_return_status
    , x_msg_count       =>  x_msg_count
    , x_msg_data        =>  x_msg_data
    , p_caller          =>  p_caller
    , p_lock_flag       =>  'Y'
    , p_lpn_id_table    =>  l_valid_lpns
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      IF (l_debug = 1) THEN
        mdebug('Error calling Check_Purge_LPNs, can not proceed');
      END IF;
      RETURN;
    ELSE
      IF (l_debug = 1) THEN
        mdebug('Number of validated LPNs: '||l_valid_lpns.count);
      END IF;
      IF (l_valid_lpns.count <> p_lpn_purge_rec.lpn_ids.count) THEN
        IF (l_debug = 1) THEN
          mdebug('Validation failed, can not proceed');
        END IF;
        fnd_message.set_name('WMS','WMS_LPN_PURGE_VALIDATION');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        -- Validation passed, call Purge_LPNs to delete LPNs
        IF (l_debug = 1) THEN
          mdebug('Validation passed, calling WMS_PURGE_PVT.Purge_LPNs');
        END IF;
        WMS_PURGE_PVT.Purge_LPNs(
          p_api_version     =>  p_api_version
        , p_init_msg_list   =>  p_init_msg_list
        , p_commit          =>  p_commit
        , x_return_status   =>  x_return_status
        , x_msg_count       =>  x_msg_count
        , x_msg_data        =>  x_msg_data
        , p_caller          =>  p_caller
        , p_lpn_id_table    =>  l_valid_lpns
        , p_purge_count     =>  l_purge_count
        );
       END IF; -- End if of l_valid_lpns.count<>p_lpn_purge_rec.lpn_ids.count

    END IF; -- End if of x_return_status<>fnd_api.g_ret_sts_success

  END IF; -- End if of p_action
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;

END LPN_Purge_Actions;

END WMS_Container_GRP;

/
