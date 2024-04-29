--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_AML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_AML_PVT" AS
/* $Header: EGOVAMLB.pls 120.9.12010000.2 2009/03/19 10:23:16 minxie ship $ */

-- ==========================================================================
--                         Package variables and cursors
-- ==========================================================================

  G_FILE_NAME                  VARCHAR2(12);
  G_PKG_NAME                   VARCHAR2(30);

  G_USER_ID                    fnd_user.user_id%TYPE;
  G_PARTY_ID                   hz_parties.party_id%TYPE;
  G_PARTY_NAME                 hz_parties.party_name%TYPE;
  G_LOGIN_ID                   fnd_user.last_update_login%TYPE;
  G_REQUEST_ID                 NUMBER;
  G_PROG_APPID                 ego_aml_intf.program_application_id%TYPE;
  G_PROG_ID                    ego_aml_intf.program_id%TYPE;
  G_SYSDATE                    fnd_user.creation_date%TYPE;
  G_SESSION_LANG               VARCHAR2(99);
  G_FND_OBJECT_NAME            fnd_objects.obj_name%TYPE;
  G_FND_OBJECT_ID              fnd_objects.object_id%TYPE;

  G_ERROR_TABLE_NAME           VARCHAR2(99);
  G_ERROR_ENTITY_CODE          VARCHAR2(99);
  G_ERROR_FILE_NAME            VARCHAR2(99);
  G_BO_IDENTIFIER              VARCHAR2(99);

  G_CP_ALLOWED                 VARCHAR2(99);
  G_CP_NOT_ALLOWED             VARCHAR2(99);
  G_CP_CO_REQUIRED             VARCHAR2(99);

  G_CONC_RET_STS_SUCCESS       VARCHAR2(1);
  G_CONC_RET_STS_WARNING       VARCHAR2(1);
  G_CONC_RET_STS_ERROR         VARCHAR2(1);

  G_DEBUG_LEVEL_UNEXPECTED     NUMBER;
  G_DEBUG_LEVEL_ERROR          NUMBER;
  G_DEBUG_LEVEL_EXCEPTION      NUMBER;
  G_DEBUG_LEVEL_EVENT          NUMBER;
  G_DEBUG_LEVEL_PROCEDURE      NUMBER;
  G_DEBUG_LEVEL_STATEMENT      NUMBER;
  G_DEBUG_LOG_HEAD             VARCHAR2(30);

  G_PS_TO_BE_PROCESSED         NUMBER;
  G_PS_IN_PROCESS              NUMBER;
  G_PS_GENERIC_ERROR           NUMBER;
  G_PS_VAL_TO_ID_COMPLETE      NUMBER;
  G_PS_TRANSFER_TO_CM          NUMBER;
  G_PS_DFF_VAL_COMPLETE        NUMBER;
  G_PS_SUCCESS                 NUMBER;

  G_PS_MAND_PARAM_MISSING      NUMBER;
  G_PS_INVALID_TRANS_TYPE      NUMBER;
  G_PS_SD_GT_ED_ERROR          NUMBER;
  G_PS_FA_STATUS_ERR           NUMBER;
  G_PS_APPROVAL_STATUS_ERR     NUMBER;
  G_PS_MANUFACTURER_ERR        NUMBER;
  G_PS_ORGANIZATION_ERR        NUMBER;
  G_PS_NOT_MASTER_ORG_ERR      NUMBER;
  G_PS_ITEM_ERR                NUMBER;
  G_PS_CREATE_REC_EXISTS       NUMBER;
  G_PS_REC_NOT_EXISTS          NUMBER;
  G_PS_DUP_INTF_RECORDS        NUMBER;
  G_PS_CHANGE_NOT_ALLOWED      NUMBER;
  G_PS_NO_AML_PRIV             NUMBER;
  G_PS_SD_NOT_NULL             NUMBER;
  G_PS_ED_LT_SYSDATE           NUMBER;
  G_PS_DFF_INVALID             NUMBER;

  TYPE G_MTL_DFF_ATTRIBUTES_REC IS RECORD
    (attribute1    VARCHAR2(1)
    ,attribute2    VARCHAR2(1)
    ,attribute3    VARCHAR2(1)
    ,attribute4    VARCHAR2(1)
    ,attribute5    VARCHAR2(1)
    ,attribute6    VARCHAR2(1)
    ,attribute7    VARCHAR2(1)
    ,attribute8    VARCHAR2(1)
    ,attribute9    VARCHAR2(1)
    ,attribute10   VARCHAR2(1)
    ,attribute11   VARCHAR2(1)
    ,attribute12   VARCHAR2(1)
    ,attribute13   VARCHAR2(1)
    ,attribute14   VARCHAR2(1)
    ,attribute15   VARCHAR2(1)
    );

-- ==========================================================================
--                     Private Functions and Procedures
-- ==========================================================================
PROCEDURE write_aml_rec (p_data_set_id  IN  NUMBER
                        ,p_watch_data   IN  VARCHAR2
                         ) IS
  l_aml_rec  ego_aml_intf%ROWTYPE;
BEGIN
  SELECT *
  INTO l_aml_rec
  from ego_aml_intf
  where data_set_id = p_data_set_id;
--  sri_debug( p_watch_data ||': flag '||l_aml_rec.process_flag||
--            ' item id '||l_aml_rec.inventory_item_id||
--            ' item number '||l_aml_rec.item_number||
--            ' org id '||l_aml_rec.organization_id ||
--            ' org code '||l_aml_rec.organization_code
--            );
EXCEPTION
  WHEN OTHERS THEN
--    sri_debug (' write_aml_rec unable to get the data :-( ');
    NULL;
END;

--
-- write to debug into concurrent log
--
PROCEDURE log_now (p_log_level  IN NUMBER
                  ,p_module     IN VARCHAR2
                  ,p_message    IN VARCHAR2
                  ) IS
BEGIN
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(log_level => p_log_level
                  ,module    => G_DEBUG_LOG_HEAD||p_module
                  ,message   => p_message
                  );
  END IF;
  --
  -- writing to concurrent log
  --
  IF G_REQUEST_ID <> -1 AND p_log_level >= G_DEBUG_LEVEL_PROCEDURE THEN
    FND_FILE.put_line(which => FND_FILE.LOG
                     ,buff  => '['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
                               ||'] '||p_message);
  END IF;
--  sri_debug(G_PKG_NAME||' - '||p_message);
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END log_now;

--
-- Set Global Variables that will be used by the programs
--
PROCEDURE SetGobals IS
BEGIN
  --
  -- fine names
  --
  G_FILE_NAME  := NVL(G_FILE_NAME,'EGOAMPVB.pls');
  G_PKG_NAME   := NVL(G_PKG_NAME,'EGO_ITEM_AML_PVT');
  --
  -- user values
  --
  G_USER_ID    := FND_GLOBAL.user_id;
  G_LOGIN_ID   := FND_GLOBAL.login_id;
  G_REQUEST_ID := NVL(FND_GLOBAL.conc_request_id, -1);
  G_PROG_APPID := FND_GLOBAL.prog_appl_id;
  G_PROG_ID    := FND_GLOBAL.conc_program_id;
  G_SYSDATE    := NVL(G_SYSDATE,SYSDATE);
  G_SESSION_LANG := USERENV('LANG');
  BEGIN
    SELECT party_id, party_name
    INTO G_PARTY_ID, G_PARTY_NAME
    FROM ego_user_v
    WHERE USER_ID = G_USER_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- 3600938 sometimes user_id is not being retrieved
      SELECT party_id, party_name, user_id
      INTO G_PARTY_ID, G_PARTY_NAME, G_USER_ID
      FROM ego_user_v
      WHERE USER_NAME = FND_GLOBAL.USER_NAME;
  END;
  --
  -- error handler parameters
  --
  G_ERROR_TABLE_NAME   := NVL(G_ERROR_TABLE_NAME,'EGO_AML_INTF');
  G_ERROR_ENTITY_CODE  := NVL(G_ERROR_ENTITY_CODE,'EGO_AML');
  G_ERROR_FILE_NAME    := NULL;
  G_BO_IDENTIFIER      := NVL(G_BO_IDENTIFIER,'EGO_AML');
  --
  -- Change Policy constants
  --
  G_CP_ALLOWED       := 'ALLOWED';
  G_CP_NOT_ALLOWED   := 'NOT_ALLOWED';
  G_CP_CO_REQUIRED   := 'CHANGE_ORDER_REQUIRED';
  --
  -- concurrent program return status
  --
  G_CONC_RET_STS_SUCCESS  := '0';
  G_CONC_RET_STS_WARNING  := '1';
  G_CONC_RET_STS_ERROR    := '2';
  --
  -- debug parameter constants
  --
  G_DEBUG_LEVEL_UNEXPECTED := FND_LOG.LEVEL_UNEXPECTED;
  G_DEBUG_LEVEL_ERROR      := FND_LOG.LEVEL_ERROR;
  G_DEBUG_LEVEL_EXCEPTION  := FND_LOG.LEVEL_EXCEPTION;
  G_DEBUG_LEVEL_EVENT      := FND_LOG.LEVEL_EVENT;
  G_DEBUG_LEVEL_PROCEDURE  := FND_LOG.LEVEL_PROCEDURE;
  G_DEBUG_LEVEL_STATEMENT  := FND_LOG.LEVEL_STATEMENT;
  G_DEBUG_LOG_HEAD         := 'fnd.plsql.'||G_PKG_NAME||'.';
  --
  -- object parameters
  --
  G_FND_OBJECT_NAME   := NVL(G_FND_OBJECT_NAME,'EGO_ITEM');
  IF G_FND_OBJECT_ID IS NULL THEN
    SELECT object_id
    INTO G_FND_OBJECT_ID
    FROM fnd_objects
    WHERE obj_name = G_FND_OBJECT_NAME;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    log_now (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
            ,p_module    => 'SetGlobals'
            ,p_message   => 'Unable to intialize Globals'
            );
END SetGobals;

--
-- Set Process Constants
--
PROCEDURE SetProcessConstants IS
BEGIN
  --
  -- status flags
  --
  G_PS_TO_BE_PROCESSED         := 1;
  G_PS_IN_PROCESS              := 2;
  G_PS_GENERIC_ERROR           := 3;
  G_PS_VAL_TO_ID_COMPLETE      := 4;
  G_PS_TRANSFER_TO_CM          := 5;
  G_PS_DFF_VAL_COMPLETE        := 6;
  G_PS_SUCCESS                 := 7;
  --
  -- error flags
  --
  G_PS_MAND_PARAM_MISSING      := POWER(2,3);  -- 8
  G_PS_INVALID_TRANS_TYPE      := POWER(2,4);  -- 16
  G_PS_SD_GT_ED_ERROR          := POWER(2,5);  -- 32
  G_PS_FA_STATUS_ERR           := POWER(2,6);  -- 64
  G_PS_APPROVAL_STATUS_ERR     := POWER(2,7);  -- 128
  G_PS_MANUFACTURER_ERR        := POWER(2,8);  -- 256
  G_PS_ORGANIZATION_ERR        := POWER(2,9);  -- 512
  G_PS_NOT_MASTER_ORG_ERR      := POWER(2,10); -- 1024
  G_PS_ITEM_ERR                := POWER(2,11); -- 2048
  G_PS_CREATE_REC_EXISTS       := POWER(2,12); -- 4096
  G_PS_REC_NOT_EXISTS          := POWER(2,13); -- 8192
  G_PS_DUP_INTF_RECORDS        := POWER(2,14); -- 16384
  G_PS_CHANGE_NOT_ALLOWED      := POWER(2,15); -- 32768
  G_PS_NO_AML_PRIV             := POWER(2,16); -- 65536
  G_PS_SD_NOT_NULL             := POWER(2,17); -- 131072
  G_PS_ED_LT_SYSDATE           := POWER(2,18); -- 262144
  G_PS_DFF_INVALID             := POWER(2,19); -- 524288

EXCEPTION
  WHEN OTHERS THEN
    log_now (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
            ,p_module    => 'SetProcessConstants'
            ,p_message   => 'Unable to set Global Constants'
            );
END SetProcessConstants;

PROCEDURE ValueToIdConversion (p_data_set_id       IN  NUMBER
                              ,x_return_status    OUT NOCOPY VARCHAR2
                              ,x_msg_count        OUT NOCOPY NUMBER
                              ,x_msg_data         OUT NOCOPY VARCHAR2) IS
  l_api_name  VARCHAR2(30);
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name := 'ValueToIdConversion';
  --
  -- records will be processed with process_flag = G_PS_IN_PROCESS
  -- records will be ended with process_flag = G_PS_VAL_TO_ID_COMPLETE
  --
  UPDATE ego_aml_intf
  SET process_flag = G_PS_INVALID_TRANS_TYPE
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND transaction_type NOT IN
    (EGO_ITEM_PUB.G_TTYPE_CREATE
    ,EGO_ITEM_PUB.G_TTYPE_UPDATE
    ,EGO_ITEM_PUB.G_TTYPE_SYNC
    ,EGO_ITEM_PUB.G_TTYPE_DELETE
    );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => ' Transaction type validation complete'
          );

  UPDATE ego_aml_intf aml_intf
  SET process_flag = G_PS_SD_GT_ED_ERROR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND NVL(start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
            > NVL(end_date,NVL(start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE));
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => ' Start Date - End Date validation complete'
          );

  UPDATE ego_aml_intf  aml_intf
  SET process_flag = G_PS_FA_STATUS_ERR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND transaction_type <> EGO_ITEM_PUB.G_TTYPE_DELETE
  AND ( ( NVL(first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                   <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          AND
          first_article_status NOT IN
            (SELECT lookup_code
             FROM fnd_lookup_values fa_lookup
             WHERE fa_lookup.lookup_type = 'EGO_CAT_GRP_MFG_FST_ATCLE_STS'
             AND fa_lookup.language = G_SESSION_LANG)
        )
      OR
        ( first_article_status IS NULL
          AND
          NVL(first_article_status_meaning,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          AND
          first_article_status_meaning NOT IN
             (SELECT meaning
              FROM fnd_lookup_values fa_lookup
              WHERE fa_lookup.lookup_type = 'EGO_CAT_GRP_MFG_FST_ATCLE_STS'
              AND fa_lookup.language = G_SESSION_LANG)
        )
      );

  UPDATE ego_aml_intf  aml_intf
  SET first_article_status =
    DECODE (first_article_status_meaning, EGO_ITEM_PUB.G_INTF_NULL_CHAR,
               EGO_ITEM_PUB.G_INTF_NULL_CHAR,
              (Select lookup_code
               from fnd_lookup_values fa_lookup
               where fa_lookup.lookup_type = 'EGO_CAT_GRP_MFG_FST_ATCLE_STS'
               and fa_lookup.meaning = aml_intf.first_article_status_meaning
               and fa_lookup.language = G_SESSION_LANG)
                 )
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND transaction_type <> EGO_ITEM_PUB.G_TTYPE_DELETE
  AND first_article_status IS NULL
  AND first_article_status_meaning IS NOT NULL;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'VtoID Conversion Complete for First Article Status'
          );

  UPDATE ego_aml_intf  aml_intf
  SET process_flag = G_PS_APPROVAL_STATUS_ERR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND transaction_type <> EGO_ITEM_PUB.G_TTYPE_DELETE
  AND ( ( NVL(approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                        <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          AND
          approval_status NOT IN
            (SELECT lookup_code
             FROM fnd_lookup_values fa_lookup
             WHERE fa_lookup.lookup_type = 'EGO_CAT_GRP_MFG_APPR_STS'
             AND fa_lookup.language = G_SESSION_LANG)
        )
      OR
        ( approval_status IS NULL
          AND
          NVL(approval_status_meaning,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                        <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          AND
          approval_status_meaning NOT IN
             (SELECT meaning
              FROM fnd_lookup_values fa_lookup
              WHERE fa_lookup.lookup_type = 'EGO_CAT_GRP_MFG_APPR_STS'
              AND fa_lookup.language = G_SESSION_LANG)
        )
      );

  UPDATE ego_aml_intf  aml_intf
  SET approval_status =
    DECODE (approval_status_meaning, EGO_ITEM_PUB.G_INTF_NULL_CHAR,
              EGO_ITEM_PUB.G_INTF_NULL_CHAR,
              (Select lookup_code
               from fnd_lookup_values fa_lookup
               where fa_lookup.lookup_type = 'EGO_CAT_GRP_MFG_APPR_STS'
               and fa_lookup.meaning = aml_intf.approval_status_meaning
               and fa_lookup.language = G_SESSION_LANG)
                 )
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND transaction_type <> EGO_ITEM_PUB.G_TTYPE_DELETE
  AND approval_status IS NULL
  AND approval_status_meaning IS NOT NULL;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'VtoID Conversion Complete for Approval Status'
          );

  UPDATE ego_aml_intf  aml_intf
  SET process_flag = G_PS_MANUFACTURER_ERR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND ( (manufacturer_id IS NOT NULL
         AND
         NOT EXISTS
              (SELECT 'x' FROM mtl_manufacturers manu
               WHERE manu.manufacturer_id = aml_intf.manufacturer_id)
        )
        OR
        (manufacturer_id IS NULL
         AND
         NOT EXISTS
              (SELECT 'x' FROM mtl_manufacturers manu
               WHERE manu.manufacturer_name = aml_intf.manufacturer_name)
        )
      );

  UPDATE ego_aml_intf  aml_intf
  SET manufacturer_id =
    (Select manufacturer_id
     from mtl_manufacturers manu
     where manu.manufacturer_name = aml_intf.manufacturer_name)
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND manufacturer_id IS NULL;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'VtoID Conversion Complete for Manufacturers'
          );

  UPDATE ego_aml_intf  aml_intf
  SET process_flag = G_PS_ORGANIZATION_ERR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND ( (organization_id IS NOT NULL
         AND
         NOT EXISTS (SELECT 'x' FROM mtl_parameters mp
                     WHERE mp.organization_id = aml_intf.organization_id)
        )
        OR
        (organization_id IS NULL
         AND
         NOT EXISTS (SELECT 'x' FROM mtl_parameters mp
                     WHERE mp.organization_code = aml_intf.organization_code)
        )
      );

  UPDATE ego_aml_intf  aml_intf
  SET process_flag = G_PS_NOT_MASTER_ORG_ERR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND ( (organization_id IS NOT NULL
         AND
         NOT EXISTS (SELECT 'x' FROM mtl_parameters mp
                     WHERE mp.organization_id = aml_intf.organization_id
                       AND mp.organization_id = mp.master_organization_id)
        )
        OR
        (organization_id IS NULL
         AND
         NOT EXISTS (SELECT 'x' FROM mtl_parameters mp
                     WHERE mp.organization_code = aml_intf.organization_code
                       AND mp.organization_id = mp.master_organization_id)
        )
      );

  UPDATE ego_aml_intf  aml_intf
  SET organization_id =
    (Select organization_id
     from mtl_parameters mp
     where mp.organization_code = aml_intf.organization_code)
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND organization_id IS NULL;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'VtoID Conversion Complete for Organization'
          );

  UPDATE ego_aml_intf  aml_intf
  SET process_flag = G_PS_ITEM_ERR
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND ( (inventory_item_id IS NOT NULL
         AND
         NOT EXISTS
            (SELECT 'x' FROM mtl_system_items_b_kfv item
              WHERE item.organization_id = aml_intf.organization_id
              AND   item.inventory_item_id = aml_intf.inventory_item_id)
        )
        OR
        (inventory_item_id IS NULL
         AND
         NOT EXISTS
            (SELECT 'x' FROM mtl_system_items_b_kfv item
              WHERE item.organization_id = aml_intf.organization_id
              AND   item.concatenated_segments = aml_intf.item_number)
        )
      );

  UPDATE ego_aml_intf  aml_intf
  SET (item_number, prog_int_num1, prog_int_num2,
      prog_int_num3, prog_int_char1) =
    (Select concatenated_segments, item_catalog_group_id, lifecycle_id,
            current_phase_id, NVL(approval_status,'A')
     from mtl_system_items_b_kfv item
     where item.organization_id = aml_intf.organization_id
       and item.inventory_item_id = aml_intf.inventory_item_id)
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND inventory_item_id IS NOT NULL;

  UPDATE ego_aml_intf  aml_intf
  SET (inventory_item_id, prog_int_num1, prog_int_num2,
      prog_int_num3, prog_int_char1) =
    (Select inventory_item_id, item_catalog_group_id, lifecycle_id,
            current_phase_id, NVL(APPROVAL_STATUS,'A')
     from mtl_system_items_b_kfv item
     where item.organization_id = aml_intf.organization_id
       and item.concatenated_segments = aml_intf.item_number)
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS
  AND inventory_item_id IS NULL;

  UPDATE ego_aml_intf aml_intf
  SET process_flag = G_PS_VAL_TO_ID_COMPLETE
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_IN_PROCESS;

  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'VtoID Conversion Complete for Item'
          );
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'ValueToIdConversion');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END ValueToIdConversion;


PROCEDURE TransactionCheck (p_data_set_id    IN NUMBER
                           ,p_mode           IN VARCHAR2
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg_count     OUT NOCOPY NUMBER
                           ,x_msg_data      OUT NOCOPY VARCHAR2) IS
  l_api_name  VARCHAR2(30);
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name := 'TransactionCheck';
  --
  -- records will be processed with process_flag = G_PS_VAL_TO_ID_COMPLETE
  -- records will be ended with process_flag = G_PS_VAL_TO_ID_COMPLETE
  --
  UPDATE ego_aml_intf aml_intf
  SET process_flag = G_PS_CREATE_REC_EXISTS
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE
  AND EXISTS
        (Select 'x'
         from mtl_mfg_part_numbers part_num
         where part_num.inventory_item_id = aml_intf.inventory_item_id
         and part_num.organization_id = aml_intf.organization_id
         and part_num.manufacturer_id = aml_intf.manufacturer_id
         and part_num.mfg_part_num = aml_intf.mfg_part_num
        );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Transaction check complete for CREATE'
          );

  UPDATE ego_aml_intf aml_intf
  SET process_flag = G_PS_REC_NOT_EXISTS
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type IN (EGO_ITEM_PUB.G_TTYPE_UPDATE
                          ,EGO_ITEM_PUB.G_TTYPE_DELETE
                          )
  AND NOT EXISTS
        (Select 'x'
         from mtl_mfg_part_numbers part_num
         where part_num.inventory_item_id = aml_intf.inventory_item_id
         and part_num.organization_id = aml_intf.organization_id
         and part_num.manufacturer_id = aml_intf.manufacturer_id
         and part_num.mfg_part_num = aml_intf.mfg_part_num
        );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Transaction check complete for UPDATE'
          );

  UPDATE ego_aml_intf aml_intf
  SET transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type = EGO_ITEM_PUB.G_TTYPE_SYNC
  AND EXISTS
        (Select 'x'
         from mtl_mfg_part_numbers part_num
         where part_num.inventory_item_id = aml_intf.inventory_item_id
         and part_num.organization_id = aml_intf.organization_id
         and part_num.manufacturer_id = aml_intf.manufacturer_id
         and part_num.mfg_part_num = aml_intf.mfg_part_num
        );

  UPDATE ego_aml_intf aml_intf
  SET transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type = EGO_ITEM_PUB.G_TTYPE_SYNC;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Transaction check complete for SYNC'
          );

-- I think we do not need this
--  UPDATE ego_aml_intf aml_intf
--  SET process_flag = G_PS_SD_NOT_NULL
--  WHERE data_set_id = p_data_set_id
--  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
--  AND transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
--  AND start_date = EGO_ITEM_PUB.G_INTF_NULL_DATE;

  IF p_mode <> MODE_HISTORICAL THEN
    UPDATE ego_aml_intf aml_intf
    SET process_flag = G_PS_ED_LT_SYSDATE
    WHERE data_set_id = p_data_set_id
    AND process_flag = G_PS_VAL_TO_ID_COMPLETE
    AND transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
    AND NVL(end_date,G_SYSDATE) <> EGO_ITEM_PUB.g_INTF_NULL_DATE
    AND NVL(end_date,G_SYSDATE) < G_SYSDATE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'TransactionCheck');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END TransactionCheck;


PROCEDURE performDupRecordCheck
      (p_data_set_id       IN  NUMBER
      ,x_return_status    OUT NOCOPY VARCHAR2
      ,x_msg_count        OUT NOCOPY NUMBER
      ,x_msg_data         OUT NOCOPY VARCHAR2) IS
  l_api_name  VARCHAR2(30);
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name := 'performDupRecordCheck';
  --
  -- records will be processed with process_flag = G_PS_VAL_TO_ID_COMPLETE
  -- records will be ended with process_flag = G_PS_VAL_TO_ID_COMPLETE
  --
  UPDATE ego_aml_intf orig
  SET process_flag = G_PS_DUP_INTF_RECORDS
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND EXISTS
    (SELECT 'X'
     FROM ego_aml_intf
     WHERE data_set_id = p_data_set_id
       AND process_flag = G_PS_VAL_TO_ID_COMPLETE
       AND transaction_id <> orig.transaction_id
       AND inventory_item_id = orig.inventory_item_id
       AND organization_id = orig.organization_id
       AND manufacturer_id = orig.manufacturer_id
       AND mfg_part_num = orig.mfg_part_num
     );

  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Dup Check Complete'
          );
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'performDupRecordCheck');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END performDupRecordCheck;


PROCEDURE performCMSeggregation (p_data_set_id    IN NUMBER
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2) IS

  CURSOR c_item_records (cp_data_set_id IN NUMBER) IS
  SELECT *
  FROM ego_aml_intf
  WHERE data_set_id = cp_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND NVL(prog_int_char2,'N') <> 'Y'
  AND prog_int_num4 IS NOT NULL
  FOR UPDATE OF transaction_id;

  l_dynamic_sql          VARCHAR2(4000);
  l_policy_object_name   VARCHAR2(30);
  l_policy_code          VARCHAR2(30);
  l_attr_object_name     VARCHAR2(30);
  l_attr_code            VARCHAR2(30);
  l_policy_value         VARCHAR2(99);
  l_api_name             VARCHAR2(30);
  l_add_all_to_cm        VARCHAR2(1);

BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name       := 'performCMSeggregation';
  --
  -- records will be processed with process_flag = G_PS_VAL_TO_ID_COMPLETE
  --
  l_add_all_to_cm :=
        EGO_IMPORT_PVT.getAddAllToChangeFlag(p_batch_id => p_data_set_id);
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Value of Add all to CM '||l_add_all_to_cm
          );

  UPDATE ego_aml_intf aml_intf
  SET prog_int_char2 = 'Y'
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND EXISTS (Select 1
              from mtl_system_items_interface
              where request_id = aml_intf.request_id
              and inventory_item_id = aml_intf.inventory_item_id
              and organization_id   = aml_intf.organization_id
              and transaction_type = 'CREATE'
              and process_flag = 7
             );

  UPDATE ego_aml_intf aml_intf
  SET prog_int_num4 =
     (SELECT ic.item_catalog_group_id
      FROM mtl_item_catalog_groups_b ic
      WHERE EXISTS
        (SELECT olc.object_classification_code CatalogId
           FROM ego_obj_type_lifecycles olc
          WHERE olc.object_id = G_FND_OBJECT_ID
            AND olc.lifecycle_id = aml_intf.prog_int_num2
            AND olc.object_classification_code =
                           to_char(ic.item_catalog_group_id)
        )
      AND ROWNUM = 1
      CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
      START WITH item_catalog_group_id = aml_intf.prog_int_num1
     )
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND prog_int_num2 IS NOT NULL;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'CC at which policy is associated obtained'
          );

  IF l_add_all_to_cm = 'Y' THEN
    UPDATE ego_aml_intf aml_intf
    SET process_flag = G_PS_TRANSFER_TO_CM
    WHERE data_set_id = p_data_set_id
      AND process_flag = G_PS_VAL_TO_ID_COMPLETE
      AND NVL(prog_int_char2,'N') <> 'Y'
      AND prog_int_num4 IS NULL;
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'All items with no LC are moved forcefully to CM'
            );
  END IF;

  l_policy_object_name   := 'CATALOG_LIFECYCLE_PHASE';
  l_policy_code          := 'CHANGE_POLICY';
  l_attr_object_name     := 'EGO_CATALOG_GROUP';
  l_attr_code            := 'AML_RULE';
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Policy check started'
          );
  FOR cr in c_item_records(cp_data_set_id => p_data_set_id) LOOP
    l_dynamic_sql :=
      ' BEGIN                                                       '||
      '   ENG_CHANGE_POLICY_PKG.GetChangePolicy                     '||
      '   (p_policy_object_name      =>  :l_policy_object_name      '||
      '   ,p_policy_code             =>  :l_policy_code             '||
      '   ,p_policy_pk1_value        =>  TO_CHAR(:catalog_cat_id)   '||
      '   ,p_policy_pk2_value        =>  TO_CHAR(:lifecycle_id)     '||
      '   ,p_policy_pk3_value        =>  TO_CHAR(:current_phase_id) '||
      '   ,p_policy_pk4_value        =>  NULL                       '||
      '   ,p_policy_pk5_value        =>  NULL                       '||
      '   ,p_attribute_object_name   =>  :l_attr_object_name        '||
      '   ,p_attribute_code          =>  :l_attr_code               '||
      '   ,p_attribute_value         =>  1                          '||
      '   ,x_policy_value            =>  :l_policy_value            '||
      '   );                                                        '||
      ' END;';
    EXECUTE IMMEDIATE l_dynamic_sql
    USING IN l_policy_object_name,
          IN l_policy_code,
          IN cr.prog_int_num4,
          IN cr.prog_int_num2,
          IN cr.prog_int_num3,
          IN l_attr_object_name,
          IN l_attr_code,
         OUT l_policy_value;
    l_policy_value := NVL(l_policy_value ,G_CP_ALLOWED);
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'For Item '||cr.item_number ||
                            ' under transaction '|| cr.transaction_id ||
                            ' policy is '||l_policy_value
            );
    IF l_policy_value = G_CP_NOT_ALLOWED THEN
      UPDATE ego_aml_intf aml_intf
      SET process_flag = G_PS_CHANGE_NOT_ALLOWED
      WHERE CURRENT OF c_item_records;
    ELSIF l_policy_value = G_CP_CO_REQUIRED OR l_add_all_to_cm = 'Y' THEN
      UPDATE ego_aml_intf aml_intf
      SET process_flag = G_PS_TRANSFER_TO_CM
      WHERE CURRENT OF c_item_records;
    END IF;
  END LOOP;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Policy check completed'
          );

EXCEPTION
  WHEN OTHERS THEN
    IF c_item_records%ISOPEN THEN
      CLOSE c_item_records;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'performCMSeggregation');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END performCMSeggregation;


PROCEDURE performItemValidation (p_data_set_id            IN NUMBER
                                ,p_perform_security_check IN BOOLEAN
                                ,x_return_status         OUT NOCOPY VARCHAR2
                                ,x_msg_count             OUT NOCOPY NUMBER
                                ,x_msg_data              OUT NOCOPY VARCHAR2
                                ) IS
  l_aml_edit_priv   VARCHAR2(30);
  l_sec_predicate   VARCHAR2(32767);
  l_dynamic_sql     VARCHAR2(32767);
  l_debug_number    NUMBER;
  l_api_name  VARCHAR2(30);

  CURSOR c_item_records (cp_data_set_id IN NUMBER) IS
  SELECT *
  FROM ego_aml_intf
  WHERE data_set_id = cp_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type IN (EGO_ITEM_PUB.G_TTYPE_CREATE
                          ,EGO_ITEM_PUB.G_TTYPE_UPDATE
                          )
  FOR UPDATE OF transaction_id;

BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name := 'performItemValidation';
  --
  -- records will be processed with process_flag = G_PS_VAL_TO_ID_COMPLETE
  -- records will be ended with process_flag = G_PS_VAL_TO_ID_COMPLETE
  --
  IF p_perform_security_check THEN
    l_aml_edit_priv   := 'EGO_EDIT_ITEM_AML';
    EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => l_aml_edit_priv
       ,p_object_name      => G_FND_OBJECT_NAME
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(G_PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'aml_intf.inventory_item_id'
       ,p_pk2_alias        => 'aml_intf.organization_id'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );
    --             Result of all the operations
    --                   'T'  Successfully got predicate
    --                   'F'  No predicates granted
    --                   'E'  Error
    --                   'U'  Unexpected Error
    --                   'L'  Value too long- predicate too large for
    --                        database VPD.
    --
    --                If 'E', 'U, or 'L' is returned, there will be an error
    --                message on the FND_MESSAGE stack which
    --                can be retrieved with FND_MESSAGE.GET_ENCODED()
    --                If that message is not used, it must be cleared.
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Returning get Security Predicate with status - '
                       ||x_return_status
          );
    IF x_return_status IN ('T','F') THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_sec_predicate IS NULL THEN
        log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => ' Security Predicate is NULL'
                );
      ELSE
        log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'Security Predicate is as follows'
                );
        l_debug_number := CEIL(LENGTH(l_sec_predicate)/100);
        FOR i IN 1..l_debug_number LOOP
          log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
                  ,p_module    => l_api_name
                  ,p_message   => SUBSTR(l_sec_predicate,(i-1)*100,100)
                  );
        END LOOP;
        l_dynamic_sql :=
             ' UPDATE EGO_AML_INTF aml_intf ' ||
             ' SET process_flag = '||G_PS_NO_AML_PRIV ||
             ' WHERE data_set_id = :1'||
             ' AND process_flag = '||G_PS_VAL_TO_ID_COMPLETE||
             ' AND NVL(prog_int_char2,''N'') <> ''Y'''||
             ' AND NOT '|| l_sec_predicate;
        EXECUTE IMMEDIATE l_dynamic_sql
        USING IN p_data_set_id;
      END IF;
    ELSE
      IF x_return_status = 'L' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      x_msg_data := FND_MESSAGE.GET_ENCODED();
      log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
              ,p_module    => l_api_name
              ,p_message   => 'Security Predicate has returned with message - '
                           ||x_msg_data
              );
    END IF;
  ELSE
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'No need to perform Security check'
            );
  END IF;

  UPDATE ego_aml_intf
  SET  mrp_planning_code =
             DECODE(mrp_planning_code,EGO_ITEM_PUB.G_INTF_NULL_NUM,NULL,
                                      mrp_planning_code),
       description =
             DECODE(description,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      description),
       attribute_category =
             DECODE(attribute_category,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute_category),
       attribute1 =
             DECODE(attribute1,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute1),
       attribute2 =
             DECODE(attribute2,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute2),
       attribute3 =
             DECODE(attribute3,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute3),
       attribute4 =
             DECODE(attribute4,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute4),
       attribute5 =
             DECODE(attribute5,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute5),
       attribute6 =
             DECODE(attribute6,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute6),
       attribute7 =
             DECODE(attribute7,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute7),
       attribute8 =
             DECODE(attribute8,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute8),
       attribute9 =
             DECODE(attribute9,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute9),
       attribute10 =
             DECODE(attribute10,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute10),
       attribute11 =
             DECODE(attribute11,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute11),
       attribute12 =
             DECODE(attribute12,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute12),
       attribute13 =
             DECODE(attribute13,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute13),
       attribute14 =
             DECODE(attribute14,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute14),
       attribute15 =
             DECODE(attribute15,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      attribute15),
       first_article_status =
             DECODE(first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      first_article_status),
       approval_status =
             DECODE(approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                      approval_status),
       start_date =
             DECODE(start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE,NULL,
                                      start_date),
       end_date =
             DECODE(end_date,EGO_ITEM_PUB.G_INTF_NULL_DATE,NULL,
                                      end_date)
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE
  AND (   NVL(mrp_planning_code,EGO_ITEM_PUB.G_INTF_NULL_NUM)
              <> EGO_ITEM_PUB.G_INTF_NULL_NUM
          OR
          NVL(description,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute_category,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute1,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute2,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute3,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute4,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute5,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute6,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute7,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute8,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute9,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute10,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute11,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute12,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute13,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute14,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute15,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
              <> EGO_ITEM_PUB.G_INTF_NULL_DATE
          OR
          NVL(end_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
              <> EGO_ITEM_PUB.G_INTF_NULL_DATE
       );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Changing intf table with NULL during CREATE'
          );

  UPDATE ego_aml_intf intf
  SET     (mrp_planning_code
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,first_article_status
          ,approval_status
          ,start_date
          ,end_date
          )
     = (SELECT
           DECODE(intf.mrp_planning_code,EGO_ITEM_PUB.G_INTF_NULL_NUM,NULL,
                                         NULL,prod.mrp_planning_code,
                                         intf.mrp_planning_code),
           DECODE(intf.description,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.description,
                                         intf.description),
           DECODE(intf.attribute_category,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute_category,
                                         intf.attribute_category),
           DECODE(intf.attribute1,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute1,
                                         intf.attribute1),
           DECODE(intf.attribute2,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute2,
                                         intf.attribute2),
           DECODE(intf.attribute3,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute3,
                                         intf.attribute3),
           DECODE(intf.attribute4,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute4,
                                         intf.attribute4),
           DECODE(intf.attribute5,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute5,
                                         intf.attribute5),
           DECODE(intf.attribute6,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute6,
                                         intf.attribute6),
           DECODE(intf.attribute7,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute7,
                                         intf.attribute7),
           DECODE(intf.attribute8,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute8,
                                         intf.attribute8),
           DECODE(intf.attribute9,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute9,
                                         intf.attribute9),
           DECODE(intf.attribute10,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute10,
                                         intf.attribute10),
           DECODE(intf.attribute11,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute11,
                                         intf.attribute11),
           DECODE(intf.attribute12,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute12,
                                         intf.attribute12),
           DECODE(intf.attribute13,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute13,
                                         intf.attribute13),
           DECODE(intf.attribute14,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute14,
                                         intf.attribute14),
           DECODE(intf.attribute15,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.attribute15,
                                         intf.attribute15),
           DECODE(intf.first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.first_article_status,
                                         intf.first_article_status),
           DECODE(intf.approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                         NULL,prod.approval_status,
                                         intf.approval_status),
           DECODE(intf.start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE,NULL,
                                         NULL,prod.start_date,
                                         intf.start_date),
           DECODE(intf.end_date,EGO_ITEM_PUB.G_INTF_NULL_DATE,NULL,
                                         NULL,prod.end_date,
                                         intf.end_date)
        FROM mtl_mfg_part_numbers prod
        WHERE intf.inventory_item_id = prod.inventory_item_id
        AND intf.organization_id = prod.organization_id
        AND intf.manufacturer_id = prod.manufacturer_id
        AND intf.mfg_part_num    = prod.mfg_part_num
      )
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
  AND (   NVL(mrp_planning_code,EGO_ITEM_PUB.G_INTF_NULL_NUM)
              <> EGO_ITEM_PUB.G_INTF_NULL_NUM
          OR
          NVL(description,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute_category,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute1,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute2,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute3,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute4,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute5,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute6,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute7,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute8,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute9,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute10,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute11,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute12,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute13,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute14,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(attribute15,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
          OR
          NVL(start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
              <> EGO_ITEM_PUB.G_INTF_NULL_DATE
          OR
          NVL(end_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
              <> EGO_ITEM_PUB.G_INTF_NULL_DATE
       );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Populate intf table with prod data for UPDATE done'
          );

EXCEPTION
  WHEN OTHERS THEN
    IF c_item_records%ISOPEN THEN
      CLOSE c_item_records;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'performItemValidation');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END performItemValidation;


PROCEDURE resetDFFFieldUsage
  (p_dff_usage_record   IN OUT NOCOPY   G_MTL_DFF_ATTRIBUTES_REC
  )  IS
BEGIN
  p_dff_usage_record.attribute1  := FND_API.G_FALSE;
  p_dff_usage_record.attribute2  := FND_API.G_FALSE;
  p_dff_usage_record.attribute3  := FND_API.G_FALSE;
  p_dff_usage_record.attribute4  := FND_API.G_FALSE;
  p_dff_usage_record.attribute5  := FND_API.G_FALSE;
  p_dff_usage_record.attribute6  := FND_API.G_FALSE;
  p_dff_usage_record.attribute7  := FND_API.G_FALSE;
  p_dff_usage_record.attribute8  := FND_API.G_FALSE;
  p_dff_usage_record.attribute9  := FND_API.G_FALSE;
  p_dff_usage_record.attribute10 := FND_API.G_FALSE;
  p_dff_usage_record.attribute11 := FND_API.G_FALSE;
  p_dff_usage_record.attribute12 := FND_API.G_FALSE;
  p_dff_usage_record.attribute13 := FND_API.G_FALSE;
  p_dff_usage_record.attribute14 := FND_API.G_FALSE;
  p_dff_usage_record.attribute15 := FND_API.G_FALSE;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END resetDFFFieldUsage;

FUNCTION getAttrValue (
    p_part_num_rec      IN              ego_aml_intf%ROWTYPE
   ,p_column_name       IN              VARCHAR2
   ,p_dff_usage_record  IN  OUT NOCOPY  G_MTL_DFF_ATTRIBUTES_REC
   ) RETURN VARCHAR2 IS
BEGIN
  IF p_column_name = 'ATTRIBUTE1' THEN
    p_dff_usage_record.attribute1  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute1;
  ELSIF p_column_name = 'ATTRIBUTE2' THEN
    p_dff_usage_record.attribute2  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute2;
  ELSIF p_column_name = 'ATTRIBUTE3' THEN
    p_dff_usage_record.attribute3  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute3;
  ELSIF p_column_name = 'ATTRIBUTE4' THEN
    p_dff_usage_record.attribute4  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute4;
  ELSIF p_column_name = 'ATTRIBUTE5' THEN
    p_dff_usage_record.attribute5  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute5;
  ELSIF p_column_name = 'ATTRIBUTE6' THEN
    p_dff_usage_record.attribute6  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute6;
  ELSIF p_column_name = 'ATTRIBUTE7' THEN
    p_dff_usage_record.attribute7  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute7;
  ELSIF p_column_name = 'ATTRIBUTE8' THEN
    p_dff_usage_record.attribute8  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute8;
  ELSIF p_column_name = 'ATTRIBUTE9' THEN
    p_dff_usage_record.attribute9  := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute9;
  ELSIF p_column_name = 'ATTRIBUTE10' THEN
    p_dff_usage_record.attribute10 := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute10;
  ELSIF p_column_name = 'ATTRIBUTE11' THEN
    p_dff_usage_record.attribute11 := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute11;
  ELSIF p_column_name = 'ATTRIBUTE12' THEN
    p_dff_usage_record.attribute12 := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute12;
  ELSIF p_column_name = 'ATTRIBUTE13' THEN
    p_dff_usage_record.attribute13 := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute13;
  ELSIF p_column_name = 'ATTRIBUTE14' THEN
    p_dff_usage_record.attribute14 := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute14;
  ELSIF p_column_name = 'ATTRIBUTE15' THEN
    p_dff_usage_record.attribute15 := FND_API.G_TRUE;
    RETURN p_part_num_rec.attribute15;
  ELSE
    RETURN NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END getAttrValue;

PROCEDURE performDFFValidation (p_data_set_id            IN NUMBER
                               ,p_perform_security_check IN BOOLEAN
                               ,x_return_status         OUT NOCOPY VARCHAR2
                               ,x_msg_count             OUT NOCOPY NUMBER
                               ,x_msg_data              OUT NOCOPY VARCHAR2
                               ) IS
-- REFERENCE FROM FND_DFLEX specification
-- TYPE dflex_r IS RECORD
--  (application_id  fnd_application.application_id%TYPE,
--  flexfield_name   fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE);
  l_dflex_r         fnd_dflex.dflex_r;

-- REFERENCE FROM FND_DFLEX specification
-- TYPE dflex_dr IS RECORD
-- (title                  fnd_descriptive_flexs_vl.title%TYPE,
--  table_name             fnd_descriptive_flexs_vl.application_table_name%TYPE,
--  table_app              fnd_application.application_short_name%TYPE,
--  description            fnd_descriptive_flexs_vl.description%TYPE,
--  segment_delimeter      fnd_descriptive_flexs_vl.concatenated_segment_delimiter%TYPE,
--  default_context_field  fnd_descriptive_flexs_vl.default_context_field_name%TYPE,
--  default_context_value  fnd_descriptive_flexs_vl.default_context_value%TYPE,
--  protected_flag         fnd_descriptive_flexs_vl.protected_flag%TYPE,
--  form_context_prompt    fnd_descriptive_flexs_vl.form_context_prompt%TYPE,
--  context_column_name    fnd_descriptive_flexs_vl.context_column_name%TYPE);
  l_dflex_dr        fnd_dflex.dflex_dr;

-- REFERENCE FROM FND_DFLEX specification
-- TYPE context_r IS RECORD
--  (flexfield     dflex_r
--  ,context_code  fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE);
  l_global_ctx_r  fnd_dflex.context_r;
  l_dff_ctx_r     fnd_dflex.context_r;

-- REFERENCE FROM FND_DFLEX specification
-- TYPE context_code_a IS TABLE OF
--    fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE context_name_a IS TABLE OF
--    fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE context_description_a IS TABLE OF
--    fnd_descr_flex_contexts_vl.description%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE boolean_a IS TABLE OF
--    BOOLEAN
--    INDEX BY BINARY_INTEGER;
  l_tbl_ctx_code        fnd_dflex.context_code_a;
  l_tbl_ctx_is_global   fnd_dflex.boolean_a;
-- REFERENCE FROM FND_DFLEX specification
-- TYPE contexts_dr IS RECORD
--  (ncontexts           BINARY_INTEGER,
--  global_context      BINARY_INTEGER,
--  context_code        context_code_a,
--  context_name  context_name_a,
--  context_description context_description_a,
--  is_enabled          boolean_a,
--  is_global           boolean_a);
  l_ctx_dr     fnd_dflex.contexts_dr;

-- REFERENCE FROM FND_DFLEX specification
-- TYPE segment_description_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.description%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE application_column_name_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.application_column_name%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE segment_name_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE sequence_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.column_seq_num%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE display_size_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.display_size%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE row_prompt_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE column_prompt_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE value_set_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.flex_value_set_id%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE default_type_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.default_type%TYPE
--    INDEX BY BINARY_INTEGER;
-- TYPE default_value_a IS TABLE OF
--    fnd_descr_flex_col_usage_vl.default_value%TYPE
--    INDEX BY BINARY_INTEGER;

-- REFERENCE FROM FND_DFLEX specification
-- TYPE segments_dr IS RECORD
--  (nsegments           BINARY_INTEGER,
--  application_column_name application_column_name_a,
--  segment_name        segment_name_a,
--  sequence            sequence_a,
--  is_displayed        boolean_a,
--  display_size        display_size_a,
--  row_prompt          row_prompt_a,
--  column_prompt       column_prompt_a,
--  is_enabled          boolean_a,
--  is_required         boolean_a,
--  description         segment_description_a,
--  value_set           value_set_a,
--  default_type        default_type_a,
--  default_value       default_value_a);
  l_global_seg_dr  fnd_dflex.segments_dr;
  l_dff_seg_dr     fnd_dflex.segments_dr;

  l_std_ctx_code  fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
  l_dff_ctx_code  fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;

  l_last_attribute_category  ego_aml_intf.attribute_category%TYPE;
  l_global_data_elements     ego_aml_intf.attribute_category%TYPE;
  l_global_ctx_index         NUMBER;

  l_dff_fields_used  G_MTL_DFF_ATTRIBUTES_REC;

  l_api_name         VARCHAR2(30);
  l_count            NUMBER;

  CURSOR c_item_records (cp_data_set_id IN NUMBER) IS
  SELECT *
  FROM ego_aml_intf
  WHERE data_set_id = cp_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type IN (EGO_ITEM_PUB.G_TTYPE_CREATE
                          ,EGO_ITEM_PUB.G_TTYPE_UPDATE
                          )
  ORDER BY attribute_category desc
  FOR UPDATE OF transaction_id;

  TYPE DYNAMIC_CUR IS REF CURSOR;
  c_err_cursor       DYNAMIC_CUR;

BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name := 'performDFFValidation';
  --
  -- records will be processed with process_flag = G_PS_VAL_TO_ID_COMPLETE
  -- records will be ended with process_flag = G_PS_DFF_VAL_COMPLETE
  --
  -- check if there are any records for which DFF is input
  --
  SELECT COUNT(*)
  INTO l_count
  FROM ego_aml_intf
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE
  AND transaction_type IN (EGO_ITEM_PUB.G_TTYPE_CREATE
                          ,EGO_ITEM_PUB.G_TTYPE_UPDATE
                          )
  AND ( attribute_category IS NOT NULL
        OR attribute1 IS NOT NULL
        OR attribute2 IS NOT NULL
        OR attribute3 IS NOT NULL
        OR attribute4 IS NOT NULL
        OR attribute5 IS NOT NULL
        OR attribute6 IS NOT NULL
        OR attribute7 IS NOT NULL
        OR attribute8 IS NOT NULL
        OR attribute9 IS NOT NULL
        OR attribute10 IS NOT NULL
        OR attribute11 IS NOT NULL
        OR attribute12 IS NOT NULL
        OR attribute13 IS NOT NULL
        OR attribute14 IS NOT NULL
        OR attribute15 IS NOT NULL
      );
  IF l_count <> 0 THEN
    -- validate the flex field
    FND_DFLEX.get_flexfield
        (appl_short_name  => 'INV'
        ,flexfield_name   => 'MTL_MFG_PART_NUMBERS'
        ,flexfield        => l_dflex_r
        ,flexinfo         => l_dflex_dr
        );
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'Call to FND_DFLEX.get_flexfield complete'
            );
    --
    -- get the contexts defined for the flex field.
    --
    FND_DFLEX.get_contexts
        (flexfield        => l_dflex_r
        ,contexts         => l_ctx_dr
        );
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'Call to FND_DFLEX.get_contexts complete'
            );
    resetDFFFieldUsage (p_dff_usage_record => l_dff_fields_used);
    l_tbl_ctx_is_global := l_ctx_dr.is_global;
    IF (l_tbl_ctx_is_global.COUNT > 0) THEN
      --
      -- context fields defined
      --
      FOR i IN l_tbl_ctx_is_global.FIRST .. l_tbl_ctx_is_global.LAST  LOOP
        l_global_ctx_index := i;
        EXIT WHEN l_tbl_ctx_is_global(i);
      END LOOP;
      log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
              ,p_module    => l_api_name
              ,p_message   => 'Identified Global DFF at loc '
                           ||l_global_ctx_index||' in context table'
              );
      l_dff_ctx_r.flexfield       := l_dflex_r;
      l_global_ctx_r.flexfield    := l_dflex_r;
      l_global_ctx_r.context_code := l_ctx_dr.context_code(l_global_ctx_index);
      l_last_attribute_category   := l_global_ctx_r.context_code;
      l_global_data_elements      := l_global_ctx_r.context_code;

      FND_DFLEX.get_segments
          (context           => l_global_ctx_r
          ,segments          => l_global_seg_dr
          ,enabled_only      => TRUE
          );
      log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
              ,p_module    => l_api_name
              ,p_message   => 'Identified Segments associated with Global DFF'
              );

      FOR cr in c_item_records (cp_data_set_id => p_data_set_id) LOOP
        resetDFFFieldUsage (p_dff_usage_record => l_dff_fields_used);
        IF NVL(cr.attribute_category,l_last_attribute_category)
              <>  l_last_attribute_category THEN
          -- attribute category has changed get the dff record
          l_tbl_ctx_code      := l_ctx_dr.context_code;
          FOR i IN l_tbl_ctx_code.FIRST .. l_tbl_ctx_code.LAST LOOP
            IF l_tbl_ctx_code(i) = cr.attribute_category THEN
              l_last_attribute_category := cr.attribute_category;
              l_dff_ctx_r.context_code := cr.attribute_category;
              FND_DFLEX.get_segments
                 (context           => l_dff_ctx_r
                 ,segments          => l_dff_seg_dr
                 ,enabled_only      => TRUE
                 );
              log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
                      ,p_module    => l_api_name
                      ,p_message   => 'Identified Segments for '
                                   || cr.attribute_category
                      );
              EXIT; -- for loop
            END IF;
          END LOOP;
        END IF;
        -- global segments are available at   l_global_seg_dr
        -- dff segments are available at      l_dff_seg_dr
        FND_FLEX_DESCVAL.set_context_value(l_last_attribute_category);
        IF l_global_seg_dr.application_column_name.COUNT > 0 THEN
          FOR i IN l_global_seg_dr.application_column_name.FIRST ..
                   l_global_seg_dr.application_column_name.LAST  LOOP
            fnd_flex_descval.set_column_value
              (l_global_seg_dr.application_column_name(i)
              ,getAttrValue
                 (p_part_num_rec  => cr
                 ,p_column_name   => l_global_seg_dr.application_column_name(i)
                 ,p_dff_usage_record => l_dff_fields_used
                 )
              );
          END LOOP;
        END IF;
        IF l_last_attribute_category <> l_global_data_elements THEN
          FOR i IN l_dff_seg_dr.application_column_name.FIRST ..
                   l_dff_seg_dr.application_column_name.LAST  LOOP
            fnd_flex_descval.set_column_value
              (l_dff_seg_dr.application_column_name(i)
              ,getAttrValue
                 (p_part_num_rec     => cr
                 ,p_column_name      => l_dff_seg_dr.application_column_name(i)
                 ,p_dff_usage_record => l_dff_fields_used
                 )
              );
          END LOOP;
        END IF;
        log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
                ,p_module    => l_api_name
                ,p_message   => 'Calling FND_FLEX_DESCVAL.validate_desccols'
                );
        IF NOT FND_FLEX_DESCVAL.validate_desccols
                 (appl_short_name       => 'INV'
                 ,desc_flex_name        => 'MTL_MFG_PART_NUMBERS'
  --               ,values_or_ids         IN  VARCHAR2 DEFAULT 'I'
  --               ,validation_date       IN  DATE     DEFAULT SYSDATE
  --               ,enabled_activation    IN  BOOLEAN  DEFAULT TRUE
  --               ,resp_appl_id          IN  NUMBER   DEFAULT NULL
  --               ,resp_id               IN  NUMBER   DEFAULT NULL
             ) THEN
          UPDATE ego_aml_intf
          SET process_flag = G_PS_DFF_INVALID,
              prog_int_char2 = fnd_flex_descval.error_message
          WHERE CURRENT OF c_item_records;
        ELSE
          -- set to NULL all other DFF fields which are not defined
          UPDATE ego_aml_intf intf
          SET   attribute1 =
            (SELECT CASE WHEN l_dff_fields_used.attribute1 = FND_API.G_TRUE
                         THEN intf.attribute1 ELSE NULL END
             FROM DUAL)
               ,attribute2 =
            (SELECT CASE WHEN l_dff_fields_used.attribute2 = FND_API.G_TRUE
                         THEN intf.attribute2 ELSE NULL END
             FROM DUAL)
               ,attribute3 =
            (SELECT CASE WHEN l_dff_fields_used.attribute3 = FND_API.G_TRUE
                         THEN intf.attribute3 ELSE NULL END
             FROM DUAL)
               ,attribute4 =
            (SELECT CASE WHEN l_dff_fields_used.attribute4 = FND_API.G_TRUE
                         THEN intf.attribute4 ELSE NULL END
             FROM DUAL)
               ,attribute5 =
            (SELECT CASE WHEN l_dff_fields_used.attribute5 = FND_API.G_TRUE
                         THEN intf.attribute5 ELSE NULL END
             FROM DUAL)
               ,attribute6 =
            (SELECT CASE WHEN l_dff_fields_used.attribute6 = FND_API.G_TRUE
                         THEN intf.attribute6 ELSE NULL END
             FROM DUAL)
               ,attribute7 =
            (SELECT CASE WHEN l_dff_fields_used.attribute7 = FND_API.G_TRUE
                         THEN intf.attribute7 ELSE NULL END
             FROM DUAL)
               ,attribute8 =
            (SELECT CASE WHEN l_dff_fields_used.attribute8 = FND_API.G_TRUE
                         THEN intf.attribute8 ELSE NULL END
             FROM DUAL)
               ,attribute9 =
            (SELECT CASE WHEN l_dff_fields_used.attribute9 = FND_API.G_TRUE
                         THEN intf.attribute9 ELSE NULL END
             FROM DUAL)
               ,attribute10 =
            (SELECT CASE WHEN l_dff_fields_used.attribute10 = FND_API.G_TRUE
                         THEN intf.attribute10 ELSE NULL END
             FROM DUAL)
               ,attribute11 =
            (SELECT CASE WHEN l_dff_fields_used.attribute11 = FND_API.G_TRUE
                         THEN intf.attribute11 ELSE NULL END
             FROM DUAL)
               ,attribute12 =
            (SELECT CASE WHEN l_dff_fields_used.attribute12 = FND_API.G_TRUE
                         THEN intf.attribute12 ELSE NULL END
             FROM DUAL)
               ,attribute13 =
            (SELECT CASE WHEN l_dff_fields_used.attribute13 = FND_API.G_TRUE
                         THEN intf.attribute13 ELSE NULL END
             FROM DUAL)
               ,attribute14 =
            (SELECT CASE WHEN l_dff_fields_used.attribute14 = FND_API.G_TRUE
                         THEN intf.attribute14 ELSE NULL END
             FROM DUAL)
               ,attribute15 =
            (SELECT CASE WHEN l_dff_fields_used.attribute15 = FND_API.G_TRUE
                         THEN intf.attribute15 ELSE NULL END
             FROM DUAL)
          WHERE CURRENT OF c_item_records;
        END IF;
      END LOOP;
    ELSE
      -- no context fields defined.
      UPDATE ego_aml_intf
      SET process_flag = G_PS_DFF_INVALID
      WHERE data_set_id = p_data_set_id
      AND process_flag = G_PS_VAL_TO_ID_COMPLETE
      AND (attribute1 IS NOT NULL
           OR
           attribute2 IS NOT NULL
           OR
           attribute3 IS NOT NULL
           OR
           attribute4 IS NOT NULL
           OR
           attribute5 IS NOT NULL
           OR
           attribute6 IS NOT NULL
           OR
           attribute7 IS NOT NULL
           OR
           attribute8 IS NOT NULL
           OR
           attribute9 IS NOT NULL
           OR
           attribute10 IS NOT NULL
           OR
           attribute11 IS NOT NULL
           OR
           attribute12 IS NOT NULL
           OR
           attribute13 IS NOT NULL
           OR
           attribute14 IS NOT NULL
           OR
           attribute15 IS NOT NULL
          );
    END IF;
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => ' DFF validation complete'
            );
  ELSE
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'No DFF fields are present for validation'
            );
  END IF; -- there exists some records with DFF fields
  UPDATE ego_aml_intf
  SET process_flag = G_PS_DFF_VAL_COMPLETE
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_VAL_TO_ID_COMPLETE;

EXCEPTION
  WHEN OTHERS THEN
    IF c_item_records%ISOPEN THEN
      CLOSE c_item_records;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'performDFFValidation');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END performDFFValidation;

PROCEDURE populateProductionTable (p_data_set_id     IN NUMBER
                                  ,x_return_status  OUT NOCOPY VARCHAR2
                                  ,x_msg_count      OUT NOCOPY NUMBER
                                  ,x_msg_data       OUT NOCOPY VARCHAR2
                                ) IS
  l_api_name  VARCHAR2(30);
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name := 'populateProductionTable';
  INSERT INTO mtl_mfg_part_numbers
          (manufacturer_id
          ,mfg_part_num
          ,inventory_item_id
          ,organization_id
          ,mrp_planning_code
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,first_article_status
          ,approval_status
          ,start_date
          ,end_date
          ,request_id
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login)
        SELECT
           manufacturer_id
          ,mfg_part_num
          ,inventory_item_id
          ,organization_id
          ,mrp_planning_code
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,first_article_status
          ,approval_status
          ,start_date
          ,end_date
          ,request_id
          ,G_SYSDATE
          ,G_USER_ID
          ,G_SYSDATE
          ,G_USER_ID
          ,G_LOGIN_ID
        FROM ego_aml_intf
        WHERE data_set_id = p_data_set_id
        AND process_flag = G_PS_DFF_VAL_COMPLETE
        AND transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Insert into production table done'
          );

  UPDATE mtl_mfg_part_numbers prod SET
          (mrp_planning_code
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,first_article_status
          ,approval_status
          ,start_date
          ,end_date
          ,request_id
          ,last_update_date
          ,last_updated_by
          ,last_update_login)
     = (SELECT intf.mrp_planning_code
              ,intf.description
              ,intf.attribute_category
              ,intf.attribute1
              ,intf.attribute2
              ,intf.attribute3
              ,intf.attribute4
              ,intf.attribute5
              ,intf.attribute6
              ,intf.attribute7
              ,intf.attribute8
              ,intf.attribute9
              ,intf.attribute10
              ,intf.attribute11
              ,intf.attribute12
              ,intf.attribute13
              ,intf.attribute14
              ,intf.attribute15
              ,intf.first_article_status
              ,intf.approval_status
              ,intf.start_date
              ,intf.end_date
              ,intf.request_id
              ,G_SYSDATE
              ,G_USER_ID
              ,G_LOGIN_ID
        FROM ego_aml_intf intf
        WHERE intf.data_set_id = p_data_set_id
        AND intf.process_flag = G_PS_DFF_VAL_COMPLETE
        AND intf.transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
        AND intf.inventory_item_id = prod.inventory_item_id
        AND intf.organization_id = prod.organization_id
        AND intf.manufacturer_id = prod.manufacturer_id
        AND intf.mfg_part_num    = prod.mfg_part_num
      )
   WHERE EXISTS (select 1
                 from  ego_aml_intf intf1
                 where intf1.data_set_id = p_data_set_id
                 and intf1.process_flag = G_PS_DFF_VAL_COMPLETE
                 and intf1.transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
                 and intf1.inventory_item_id = prod.inventory_item_id
                 and intf1.organization_id = prod.organization_id
                 and intf1.manufacturer_id = prod.manufacturer_id
                 and intf1.mfg_part_num    = prod.mfg_part_num
                );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Update into production table done'
          );

  DELETE mtl_mfg_part_numbers prod
  WHERE EXISTS
    (Select 1
     From ego_aml_intf intf
     Where intf.data_set_id = p_data_set_id
     and intf.process_flag = G_PS_DFF_VAL_COMPLETE
     and intf.transaction_type = EGO_ITEM_PUB.G_TTYPE_DELETE
     and intf.inventory_item_id = prod.inventory_item_id
     and intf.organization_id = prod.organization_id
     and intf.manufacturer_id = prod.manufacturer_id
     and intf.mfg_part_num    = prod.mfg_part_num
    );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => ' Deletion of items from production table done'
          );

  UPDATE ego_aml_intf
  SET process_flag = G_PS_SUCCESS
  WHERE data_set_id = p_data_set_id
  AND process_flag = G_PS_DFF_VAL_COMPLETE;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'populateProductionTable');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
END populateProductionTable;


--
-- Log Error Messages
--
FUNCTION Log_Errors_Now (p_data_set_id     IN NUMBER
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2
                         )
RETURN BOOLEAN IS

  CURSOR c_err_records (cp_data_set_id  IN NUMBER) IS
  SELECT *
  FROM ego_aml_intf
  WHERE data_set_id = cp_data_set_id
  AND process_flag > G_PS_SUCCESS;

  l_dummy_message        fnd_new_messages.message_text%TYPE;
  l_application_context  VARCHAR2(3);
  l_err_token_table      ERROR_HANDLER.Token_Tbl_Type;
  l_err_msg_name         VARCHAR2(99);
  l_message_type         VARCHAR2(9);
  l_entity_index         NUMBER;
  l_intf_table_name      VARCHAR2(99);
  l_entity_code          VARCHAR2(99);
  l_add_to_error_stack   VARCHAR2(99);
  l_message_has_token    BOOLEAN;
  l_api_name             VARCHAR2(30);

BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_name            := 'Log_Errors_Now';
  l_application_context := 'EGO';
  l_message_type        := FND_API.G_RET_STS_ERROR;
  -- this takes precedence over entity id
  l_entity_index       := 0;
  l_intf_table_name    := 'EGO_AML_INTF';
  l_message_has_token  := FALSE;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Started processing errors'
          );

  -- populate the interface table which uses tokens
  UPDATE ego_aml_intf  aml_intf
  SET manufacturer_name =
    (Select manufacturer_name
     from mtl_manufacturers manu
     where manu.manufacturer_id = aml_intf.manufacturer_id)
  WHERE data_set_id = p_data_set_id
  AND manufacturer_id IS NOT NULL
  AND process_flag IN  (G_PS_CREATE_REC_EXISTS
                       ,G_PS_REC_NOT_EXISTS
                       ,G_PS_DUP_INTF_RECORDS
                       );

  UPDATE ego_aml_intf  aml_intf
  SET organization_code =
    (Select organization_code
     from mtl_parameters mp
     where mp.organization_id = aml_intf.organization_id)
  WHERE data_set_id = p_data_set_id
  AND organization_id IS NOT NULL
  AND process_flag IN (G_PS_ITEM_ERR
                      ,G_PS_CREATE_REC_EXISTS
                      ,G_PS_REC_NOT_EXISTS
                      ,G_PS_DUP_INTF_RECORDS
                      ,G_PS_CHANGE_NOT_ALLOWED
                      ,G_PS_NO_AML_PRIV
                      );

  FOR error_rec IN c_err_records (cp_data_set_id => p_data_set_id) LOOP
    l_entity_index := l_entity_index+1;
    log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
            ,p_module    => l_api_name
            ,p_message   => 'Error at row '||error_rec.transaction_id||
                            ' with status '||error_rec.process_flag
            );
    IF error_rec.process_flag = G_PS_MAND_PARAM_MISSING THEN
      l_err_msg_name := 'EGO_INTF_MAND_PARAM_MISSING';
    ELSIF error_rec.process_flag = G_PS_INVALID_TRANS_TYPE THEN
      l_message_has_token := TRUE;
      fnd_message.set_name('EGO', 'EGO_TRANSACTION_TYPE');
      l_dummy_message := fnd_message.get();
      l_err_msg_name := 'EGO_IPI_INVALID_VALUE';
      l_err_token_table(1).TOKEN_NAME := 'NAME';
      l_err_token_table(1).TOKEN_VALUE := l_err_msg_name;
      l_err_token_table(2).TOKEN_NAME := 'VALUE';
      l_err_token_table(2).TOKEN_VALUE := error_rec.transaction_type;
    ELSIF error_rec.process_flag = G_PS_SD_GT_ED_ERROR THEN
      l_err_msg_name := 'EGO_STARTDATE_PRECEDES_ENDDATE';
    ELSIF error_rec.process_flag = G_PS_FA_STATUS_ERR THEN
      l_message_has_token := TRUE;
      fnd_message.set_name('EGO', 'EGO_FIRST_ARTICLE_STATUS');
      l_dummy_message := fnd_message.get();
      l_err_msg_name := 'EGO_IPI_INVALID_VALUE';
      l_err_token_table(1).TOKEN_NAME := 'NAME';
      l_err_token_table(1).TOKEN_VALUE := l_dummy_message;
      l_err_token_table(2).TOKEN_NAME := 'VALUE';
      IF error_rec.first_article_status IS NOT NULL THEN
        l_err_token_table(2).TOKEN_VALUE := error_rec.first_article_status;
      ELSE
        l_err_token_table(2).TOKEN_VALUE
                   := error_rec.first_article_status_meaning;
      END IF;
    ELSIF error_rec.process_flag = G_PS_APPROVAL_STATUS_ERR THEN
      l_message_has_token := TRUE;
      fnd_message.set_name('EGO', 'EGO_APPROVAL_STATUS');
      l_dummy_message := fnd_message.get();
      l_err_msg_name := 'EGO_IPI_INVALID_VALUE';
      l_err_token_table(1).TOKEN_NAME := 'NAME';
      l_err_token_table(1).TOKEN_VALUE := l_dummy_message;
      l_err_token_table(2).TOKEN_NAME := 'VALUE';
      IF error_rec.approval_status IS NOT NULL THEN
        l_err_token_table(2).TOKEN_VALUE := error_rec.approval_status;
      ELSE
        l_err_token_table(2).TOKEN_VALUE := error_rec.approval_status_meaning;
      END IF;
    ELSIF error_rec.process_flag = G_PS_MANUFACTURER_ERR THEN
      l_message_has_token := TRUE;
      fnd_message.set_name('EGO', 'EGO_MFG');
      l_dummy_message := fnd_message.get();
      l_err_msg_name := 'EGO_IPI_INVALID_VALUE';
      l_err_token_table(1).TOKEN_NAME := 'NAME';
      l_err_token_table(1).TOKEN_VALUE := l_dummy_message;
      l_err_token_table(2).TOKEN_NAME := 'VALUE';
      IF error_rec.manufacturer_id IS NOT NULL THEN
        l_err_token_table(2).TOKEN_VALUE := error_rec.manufacturer_id;
      ELSE
        l_err_token_table(2).TOKEN_VALUE := error_rec.manufacturer_name;
      END IF;
    ELSIF error_rec.process_flag = G_PS_ORGANIZATION_ERR THEN
      l_message_has_token := TRUE;
      fnd_message.set_name('EGO', 'EGO_ORGANIZATION');
      l_dummy_message := fnd_message.get();
      l_err_msg_name := 'EGO_IPI_INVALID_VALUE';
      l_err_token_table(1).TOKEN_NAME := 'NAME';
      l_err_token_table(1).TOKEN_VALUE := l_dummy_message;
      l_err_token_table(2).TOKEN_NAME := 'VALUE';
      IF error_rec.organization_id IS NOT NULL THEN
        l_err_token_table(2).TOKEN_VALUE := error_rec.organization_id;
      ELSE
        l_err_token_table(2).TOKEN_VALUE := error_rec.organization_code;
      END IF;
    ELSIF error_rec.process_flag = G_PS_NOT_MASTER_ORG_ERR THEN
      l_message_has_token := TRUE;
      l_err_msg_name := 'EGO_AML_NOT_MASTER_ORG';
      l_err_token_table(1).TOKEN_NAME := 'ORGANIZATION';
      IF error_rec.organization_id IS NOT NULL THEN
        l_err_token_table(1).TOKEN_VALUE := error_rec.organization_id;
      ELSE
        l_err_token_table(1).TOKEN_VALUE := error_rec.organization_code;
      END IF;
    ELSIF error_rec.process_flag = G_PS_ITEM_ERR THEN
      l_message_has_token := TRUE;
      IF error_rec.inventory_item_id IS NOT NULL THEN
        l_err_msg_name := 'EGO_ITEMID_NOTASSGN_TO_ORGID';
        l_err_token_table(1).TOKEN_NAME := 'ITEM_ID';
        l_err_token_table(1).TOKEN_VALUE := error_rec.inventory_item_id;
        l_err_token_table(2).TOKEN_NAME := 'ORG_ID';
        l_err_token_table(2).TOKEN_VALUE := error_rec.organization_id;
      ELSE
        l_err_msg_name := 'EGO_ITEM_NOTASSGN_TO_ORG';
        l_err_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
        l_err_token_table(1).TOKEN_VALUE := error_rec.item_number;
        l_err_token_table(2).TOKEN_NAME := 'ORG_CODE';
        l_err_token_table(2).TOKEN_VALUE := error_rec.organization_code;
      END IF;
    ELSIF error_rec.process_flag = G_PS_CREATE_REC_EXISTS THEN
      l_message_has_token := TRUE;
      l_err_msg_name := 'EGO_MPN_EXISTS';
      l_err_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
      l_err_token_table(1).TOKEN_VALUE := error_rec.item_number;
      l_err_token_table(2).TOKEN_NAME := 'ORG_CODE';
      l_err_token_table(2).TOKEN_VALUE := error_rec.organization_code;
      l_err_token_table(3).TOKEN_NAME := 'MFG_PART_NUM';
      l_err_token_table(3).TOKEN_VALUE := error_rec.mfg_part_num;
      l_err_token_table(4).TOKEN_NAME := 'MFG';
      l_err_token_table(4).TOKEN_VALUE := error_rec.manufacturer_name;
    ELSIF error_rec.process_flag = G_PS_REC_NOT_EXISTS THEN
      l_message_has_token := TRUE;
      IF error_rec.transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE THEN
        l_err_msg_name := 'EGO_MPN_NOT_EXISTS_UPDATE';
      ELSE
        l_err_msg_name := 'EGO_MPN_NOT_EXISTS_DELETE';
      END IF;
      l_err_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
      l_err_token_table(1).TOKEN_VALUE := error_rec.item_number;
      l_err_token_table(2).TOKEN_NAME := 'ORG_CODE';
      l_err_token_table(2).TOKEN_VALUE := error_rec.organization_code;
      l_err_token_table(3).TOKEN_NAME := 'MFG_PART_NUM';
      l_err_token_table(3).TOKEN_VALUE := error_rec.mfg_part_num;
      l_err_token_table(4).TOKEN_NAME := 'MFG';
      l_err_token_table(4).TOKEN_VALUE := error_rec.manufacturer_name;
    ELSIF error_rec.process_flag = G_PS_DUP_INTF_RECORDS THEN
      l_message_has_token := TRUE;
      l_err_msg_name := 'EGO_MPN_INTF_DUP_REC_EXISTS';
      l_err_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
      l_err_token_table(1).TOKEN_VALUE := error_rec.item_number;
      l_err_token_table(2).TOKEN_NAME := 'ORG_CODE';
      l_err_token_table(2).TOKEN_VALUE := error_rec.organization_code;
      l_err_token_table(3).TOKEN_NAME := 'MFG_PART_NUM';
      l_err_token_table(3).TOKEN_VALUE := error_rec.mfg_part_num;
      l_err_token_table(4).TOKEN_NAME := 'MFG';
      l_err_token_table(4).TOKEN_VALUE := error_rec.manufacturer_name;
    ELSIF error_rec.process_flag = G_PS_CHANGE_NOT_ALLOWED THEN
      l_message_has_token := TRUE;
      SELECT name
      INTO l_dummy_message
      FROM pa_ego_phases_v
      WHERE proj_element_id = error_rec.prog_int_num3;
      IF error_rec.transaction_type = EGO_ITEM_PUB.G_TTYPE_CREATE THEN
        l_err_msg_name := 'EGO_ITEM_LC_PREVENTS_AML';
      ELSE
        l_err_msg_name := 'EGO_LC_PREVENTS_AML_MOD';
      END IF;
      l_err_token_table(1).TOKEN_NAME := 'LC_PHASE';
      l_err_token_table(1).TOKEN_VALUE := l_dummy_message;
      l_err_token_table(2).TOKEN_NAME := 'ITEM_NUMBER';
      l_err_token_table(2).TOKEN_VALUE := error_rec.item_number;
      l_err_token_table(3).TOKEN_NAME := 'ORGANIZATION_NAME';
      l_err_token_table(3).TOKEN_VALUE := error_rec.organization_code;
    ELSIF error_rec.process_flag = G_PS_NO_AML_PRIV THEN
      l_message_has_token := TRUE;
      l_err_msg_name := 'EGO_AML_EDIT_PRIV_REQD';
      l_err_token_table(1).TOKEN_NAME := 'ITEM_NUMBER';
      l_err_token_table(1).TOKEN_VALUE := error_rec.item_number;
      l_err_token_table(2).TOKEN_NAME := 'ORG_CODE';
      l_err_token_table(2).TOKEN_VALUE := error_rec.organization_code;
    ELSIF error_rec.process_flag = G_PS_SD_NOT_NULL THEN
      l_err_msg_name := 'EGO_CANNOT_UPD_SD_TO_NULL';
    ELSIF error_rec.process_flag = G_PS_ED_LT_SYSDATE THEN
      l_err_msg_name := 'EGO_ENDDATE_EXCEEDS_SYSDATE';
    ELSIF error_rec.process_flag = G_PS_DFF_INVALID THEN
      l_message_has_token := TRUE;
      l_err_msg_name := 'EGO_GENERIC_MSG_TEXT';
      l_err_token_table(1).TOKEN_NAME := 'MESSAGE';
      l_err_token_table(1).TOKEN_VALUE := error_rec.prog_int_char2;
    END IF;
    ERROR_HANDLER.Add_Error_Message
           (p_message_name              => l_err_msg_name
           ,p_application_id            => l_application_context
           ,p_token_tbl                 => l_err_token_table
           ,p_message_type              => l_message_type
           ,p_row_identifier            => error_rec.transaction_id
           ,p_entity_id                 => NULL
           ,p_entity_index              => l_entity_index
           ,p_table_name                => l_intf_table_name
           ,p_entity_code               => l_intf_table_name
           ,p_addto_fnd_stack           => 'N'
          );
    IF l_message_has_token THEN
      l_err_token_table.DELETE();
      l_message_has_token := FALSE;
    END IF;
  END LOOP;

  --
  -- to flush the buffer into the table
  --
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Start writing errors to table'
          );
  ERROR_HANDLER.Log_Error(p_write_err_to_inttable   => 'Y'
                         ,p_write_err_to_conclog    => 'N'
                         ,p_write_err_to_debugfile  => 'N');
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Completed Logging errors to table'
          );

  UPDATE ego_aml_intf
  SET process_flag = G_PS_GENERIC_ERROR
  WHERE data_set_id = p_data_set_id
  AND process_flag > G_PS_SUCCESS;

  IF l_entity_index = 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_err_records%ISOPEN THEN
      CLOSE c_err_records;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    -- for SQL errors
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', 'Log_Errors_Now');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
    RETURN FALSE;
END Log_Errors_Now;


-- ==========================================================================
--                     Public Functions and Procedures
-- ==========================================================================

Procedure Delete_AML_Interface_Lines (
   p_api_version          IN  NUMBER
  ,p_commit               IN  VARCHAR2
  ,p_data_set_id          IN  NUMBER
  ,p_delete_line_type     IN  NUMBER
  ,x_return_status       OUT  NOCOPY VARCHAR2
  ,x_msg_count           OUT  NOCOPY NUMBER
  ,x_msg_data            OUT  NOCOPY VARCHAR2
  ) IS

  ---------------------------------------------------------------------------
  -- Start of comments
  -- API name  : Delete AML Interface Lines
  -- Type      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : To delete Interface Lines and corresponding error messages
  --               if logged.
  --
  -- Return Parameter:
  --    x_return_status
  --           'S' if successful
  --           'E' in case of any errors
  --
  ---------------------------------------------------------------------------
  l_api_version    NUMBER;
  l_api_name       VARCHAR2(50);
  l_table_name     VARCHAR2(50);

BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_msg_count      := 0;
  x_msg_data       := NULL;
  l_api_version := 1.0;
  l_api_name    := 'DELETE_AML_INTF_LINES';
  SetGobals();
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => ' p_api_version -'||p_api_version
                          ||' p_commit -'||p_commit
                          ||' p_data_set_id -'||p_data_set_id
                          ||' p_delete_line_type -'||p_delete_line_type
          );
  -- standard check for API validation
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count   => x_msg_count
                             ,p_data    => x_msg_data);
    RETURN;
  END IF;
  IF (p_data_set_id IS NULL
      OR
      p_delete_line_type NOT IN
          (EGO_ITEM_PUB.G_INTF_DELETE_ALL
          ,EGO_ITEM_PUB.G_INTF_DELETE_ERROR
          ,EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS
          ,EGO_ITEM_PUB.G_INTF_DELETE_NONE
          )
      ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('EGO','EGO_IPI_INSUFFICIENT_PARAMS');
    fnd_message.set_token('PROG_NAME',G_PKG_NAME||'.'||l_api_name);
    fnd_msg_pub.Add;
    fnd_msg_pub.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count   => x_msg_count
                             ,p_data    => x_msg_data);
    RETURN;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT DELETE_AML_INTF_LINES_SP;
  END IF;

  l_table_name := 'EGO_AML_INTF';
  IF p_delete_line_type = EGO_ITEM_PUB.G_INTF_DELETE_ALL THEN
    --
    -- delete all lines
    --
    DELETE MTL_INTERFACE_ERRORS
    WHERE  table_name = l_table_name
       AND transaction_id IN
           (SELECT transaction_id
            FROM   EGO_AML_INTF
            WHERE  data_set_id = p_data_set_id
            );

    DELETE EGO_AML_INTF
    WHERE  data_set_id = p_data_set_id;

  ELSIF p_delete_line_type = EGO_ITEM_PUB.G_INTF_DELETE_ERROR THEN
    --
    -- delete all error lines
    --
    DELETE MTL_INTERFACE_ERRORS
    WHERE  table_name = l_table_name
       AND transaction_id IN
           (SELECT transaction_id
            FROM   EGO_AML_INTF
            WHERE  data_set_id = p_data_set_id
              AND  process_flag = G_PS_GENERIC_ERROR
            );

    DELETE EGO_AML_INTF
    WHERE  data_set_id = p_data_set_id
      AND  process_flag = G_PS_GENERIC_ERROR;

  ELSIF p_delete_line_type = EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS THEN
      --
      -- delete all success lines
      --
    DELETE EGO_AML_INTF
    WHERE  data_set_id = p_data_set_id
      AND  process_flag = G_PS_SUCCESS;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Completed '||l_api_name
          );

EXCEPTION
  WHEN OTHERS THEN
    IF FND_API.To_Boolean(p_commit) THEN
      ROLLBACK TO DELETE_AML_INTF_LINES_SP;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
    FND_MESSAGE.Set_Token('API_NAME', l_api_name);
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    x_msg_data := FND_MESSAGE.get();
    log_now (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
            ,p_module    => l_api_name
            ,p_message   => x_msg_data
            );
END Delete_AML_Interface_Lines;



Procedure Load_Interface_Lines (
    ERRBUF                   OUT  NOCOPY VARCHAR2
   ,RETCODE                  OUT  NOCOPY VARCHAR2
   ,p_data_set_id             IN  NUMBER
   ,p_delete_line_type        IN  NUMBER
   ,p_mode                    IN  VARCHAR2
   ,p_perform_security_check  IN  VARCHAR2
   ) IS
  ---------------------------------------------------------------------------
  -- Start of comments
  -- API name  : Load_Interface_Lines
  -- Type      : Public
  -- Pre-reqs  : None
  -- FUNCTION  : To bulkload the Interface records into the Production
  --             and Pending changes table.
  --
  -- Parameters:
  --     IN    : p_data_set_id              VARCHAR2
  --                batch identifier
  --           : p_delete_line_type         NUMBER
  --              How the lines are to be processed in the interface table:
  --                    DELETE_ALL      = 0  (delete all lines)
  --                    DELETE_ERROR    = 3  (delete all error lines)
  --                    DELETE_SUCCESS  = 7  (delete all successful lines)
  --           : p_mode                     VARCHAR2
  --              currently only mode 'NORMAL' is supported
  --              How the data to be processed:
  --                    MODE_HISTORICAL = 'HISTORICAL'
  --                     user is populating historical data, so no date
  --                     check and security check will be performed.
  --                    MODE_NORMAL = 'NORMAL'
  --                     user is populating normal data, so perform date
  --                     check and security check.
  --           : p_perform_security_check   VARCHAR2
  --              currently only FND_API.G_TRUE is supported
  --              Whether security check needs to be done
  --                    FND_API.G_TRUE - Perform data security check
  --                    FND_API.G_FALSE - No data security check is done
  --
  --
  --    OUT    : ERRBUF             VARCHAR2
  --               has the error message details
  --             RETCODE            VARCHAR2
  --               '0' if the program is success
  --               '1' if the program has a warning
  --               '2' if the program has an error
  --
  ---------------------------------------------------------------------------
  l_api_version    NUMBER;
  l_api_name       VARCHAR2(30);

  NO_ROWS_IN_INTF_TABLE     EXCEPTION;

  l_delete_line_type        NUMBER;
  l_mode                    VARCHAR2(30);
  l_perform_security_check  BOOLEAN;
  l_prog_mode_history       BOOLEAN;

  l_pend_data_row  EGO_MFG_PART_NUM_CHGS%ROWTYPE;
  l_prod_data_row  MTL_MFG_PART_NUMBERS%ROWTYPE;

  l_msg_data       VARCHAR2(4000);
  l_msg_count      NUMBER;
  l_return_status  VARCHAR2(1);
  l_err_msg_sql    VARCHAR2(4000);

BEGIN
  l_api_version := 1.0;
  l_api_name    := 'LOAD_INTERFACE_LINES';
  ERRBUF        := NULL;
  RETCODE       := G_CONC_RET_STS_SUCCESS;
  SetGobals();
  SetProcessConstants();
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'All globals initialized'
          );
  IF (p_data_set_id IS NULL) THEN
    fnd_message.set_name('EGO', 'EGO_DATA_SET_ID');
    l_msg_data := fnd_msg_pub.get();
    fnd_message.set_name('EGO','EGO_PKG_MAND_VALUES_MISS1');
    fnd_message.set_token('PACKAGE', G_PKG_NAME ||'.'|| l_api_name);
    fnd_message.set_token('VALUE', l_msg_data);
    ERRBUF  := fnd_message.get();
    RETCODE :=  G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
          );
    RETURN;
  END IF;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Mand param check successful'
          );

  BEGIN
    SELECT 'S' INTO l_return_status
    FROM EGO_AML_INTF
    WHERE DATA_SET_ID = p_data_set_id
    AND PROCESS_FLAG = G_PS_TO_BE_PROCESSED
    AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('EGO','EGO_IPI_NO_LINES');
      l_msg_data := fnd_message.get();
      log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
              ,p_module    => l_api_name
              ,p_message   => l_msg_data
              );
      RAISE NO_ROWS_IN_INTF_TABLE;
  END;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Found Interface Lines to be processed'
          );

  -- create save point
  SAVEPOINT LOAD_INTERFACE_LINES_SP;

  -- Initialize message list
  ERROR_HANDLER.initialize();
  ERROR_HANDLER.set_bo_identifier(G_BO_IDENTIFIER);
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Error Handler Initialization successful '
          );
  l_delete_line_type
           := NVL(p_delete_line_type, EGO_ITEM_PUB.G_INTF_DELETE_NONE);
  l_mode   := NVL(p_mode, MODE_NORMAL);
  IF l_mode = MODE_NORMAL THEN
    l_prog_mode_history := FALSE;
  ELSE
    l_prog_mode_history := TRUE;
  END IF;
  l_perform_security_check :=
     FND_API.to_boolean(NVL(p_perform_security_check,FND_API.G_TRUE));
  --
  -- initialize default values on interface table
  --
  UPDATE ego_aml_intf
  SET process_flag = G_PS_IN_PROCESS,
      transaction_type = UPPER(transaction_type),
      transaction_id = NVL(transaction_id, EGO_IPI_TRANSACTION_ID_S.nextval),
      first_article_status =
        (SELECT CASE WHEN
               (first_article_status_meaning = EGO_ITEM_PUB.G_INTF_NULL_CHAR
                AND
                first_article_status IS NULL
               )
             THEN EGO_ITEM_PUB.G_INTF_NULL_CHAR
             ELSE first_article_status
             END
         FROM DUAL),
      approval_status =
        (SELECT CASE WHEN
               (approval_status_meaning = EGO_ITEM_PUB.G_INTF_NULL_CHAR
                AND
                approval_status IS NULL
               )
             THEN EGO_ITEM_PUB.G_INTF_NULL_CHAR
             ELSE approval_status
             END
         FROM DUAL),
      request_id = G_REQUEST_ID,
      program_application_id = G_PROG_APPID,
      program_id = G_PROG_ID,
      program_update_date = SYSDATE,
      prog_int_num1 = NULL,
      prog_int_num2 = NULL,
      prog_int_num3 = NULL,
      prog_int_num4 = NULL,
      prog_int_char1 = NULL,
      prog_int_char2 = 'N'
  WHERE data_set_id = p_data_set_id
    AND process_flag = G_PS_TO_BE_PROCESSED;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Defalting values complete'
          );

  UPDATE ego_aml_intf
  SET process_flag = G_PS_MAND_PARAM_MISSING
  WHERE data_set_id = p_data_set_id
    AND process_flag = G_PS_IN_PROCESS
    AND ( mfg_part_num IS NULL
          OR
          (manufacturer_id IS NULL AND manufacturer_name IS NULL)
          OR
          (organization_id IS NULL AND organization_code IS NULL)
          OR
          (inventory_item_id IS NULL AND item_number IS NULL)
        );
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Mand params check in each row complete '
          );

  valueToIdConversion(p_data_set_id   => p_data_set_id
                     ,x_return_status => l_return_status
                     ,x_msg_count     => l_msg_count
                     ,x_msg_data      => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Value to ID Conversion returned with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  TransactionCheck(p_data_set_id   => p_data_set_id
                  ,p_mode          => l_mode
                  ,x_return_status => l_return_status
                  ,x_msg_count     => l_msg_count
                  ,x_msg_data      => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Trans and Date validation returned with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  performDupRecordCheck (p_data_set_id    => p_data_set_id
                        ,x_return_status  => l_return_status
                        ,x_msg_count      => l_msg_count
                        ,x_msg_data       => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Duplicate records check done with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  performCMSeggregation(p_data_set_id   => p_data_set_id
                       ,x_return_status => l_return_status
                       ,x_msg_count     => l_msg_count
                       ,x_msg_data      => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'CM Seggregation returned with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  performItemValidation(p_data_set_id            => p_data_set_id
                       ,p_perform_security_check => l_perform_security_check
                       ,x_return_status          => l_return_status
                       ,x_msg_count              => l_msg_count
                       ,x_msg_data               => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Item Validation returned with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  performDFFValidation(p_data_set_id            => p_data_set_id
                      ,p_perform_security_check => l_perform_security_check
                      ,x_return_status          => l_return_status
                      ,x_msg_count              => l_msg_count
                      ,x_msg_data               => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Item DFF Validation returned with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  populateProductionTable(p_data_set_id    => p_data_set_id
                         ,x_return_status  => l_return_status
                         ,x_msg_count      => l_msg_count
                         ,x_msg_data       => l_msg_data);
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Production table population returned with status '
                       ||l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
    ERRBUF   := l_msg_data;
    RETCODE  := G_CONC_RET_STS_ERROR;
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => ERRBUF
            );
    ROLLBACK TO LOAD_INTERFACE_LINES_SP;
    RETURN;
  END IF;

  IF Log_Errors_Now (p_data_set_id   => p_data_set_id
                    ,x_return_status => l_return_status
                    ,x_msg_count     => l_msg_count
                    ,x_msg_data      => l_msg_data) THEN
    RETCODE := G_CONC_RET_STS_WARNING;
  ELSE
    IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                      <> FND_API.G_RET_STS_SUCCESS THEN
      ERRBUF   := l_msg_data;
      RETCODE  := G_CONC_RET_STS_ERROR;
      log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
              ,p_module    => l_api_name
              ,p_message   => ERRBUF
              );
      ROLLBACK TO LOAD_INTERFACE_LINES_SP;
      RETURN;
    END IF;
  END IF;

  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Error Logging Returned with status '
                       ||l_return_status
          );

  --
  -- writing the errors into the concurrent log
  --
  l_err_msg_sql := 'SELECT INTF.ITEM_NUMBER as ITEM_NUMBER, '||
                   ' INTF.ORGANIZATION_CODE as ORGANIZATINO_CODE, '||
--                   ' NULL AS REVISION_CODE, '||
                   ' MIERR.ERROR_MESSAGE as ERROR_MESSAGE '||
                   ' FROM  EGO_AML_INTF INTF,  MTL_INTERFACE_ERRORS MIERR '||
                   ' WHERE  MIERR.TRANSACTION_ID = INTF.TRANSACTION_ID '||
                   ' AND    MIERR.REQUEST_ID = INTF.REQUEST_ID '||
                   ' AND    MIERR.request_id = :1';
  EGO_ITEM_OPEN_INTERFACE_PVT.Write_Error_into_ConcurrentLog
    (p_entity_name   => 'EGO_AML'
    ,p_table_name    => 'EGO_AML_INTF'
    ,p_selectQuery   => l_err_msg_sql
    ,p_request_id    => G_REQUEST_ID
    ,x_return_status => l_return_status
    ,x_msg_count     => l_msg_count
    ,x_msg_data      => l_msg_data
    );

  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Returned from EGO_ITEM_OPEN_INTERFACE_PVT.'||
                          'Write_Error_into_concurrentlog with status '||
                          l_return_status
          );
  IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                        = FND_API.G_RET_STS_UNEXP_ERROR THEN
    log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
            ,p_module    => l_api_name
            ,p_message   => l_msg_data
            );
  END IF;

  IF p_delete_line_type <> EGO_ITEM_PUB.G_INTF_DELETE_NONE THEN
    Delete_AML_Interface_Lines(p_api_version      => 1.0
                              ,p_commit           => FND_API.G_FALSE
                              ,p_data_set_id      => p_data_set_id
                              ,p_delete_line_type => p_delete_line_type
                              ,x_return_status    => l_return_status
                              ,x_msg_count        => l_msg_count
                              ,x_msg_data         => l_msg_data
                              );
    IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                        <> FND_API.G_RET_STS_SUCCESS THEN
      ERRBUF   := l_msg_data;
      RETCODE  := G_CONC_RET_STS_ERROR;
      log_now (p_log_level => G_DEBUG_LEVEL_EXCEPTION
              ,p_module    => l_api_name
              ,p_message   => ERRBUF
              );
      ROLLBACK TO LOAD_INTERFACE_LINES_SP;
      RETURN;
    END IF;
  END IF;

  COMMIT WORK;

  --
  -- calling sync im index from here
  --
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Calling Sync IM Index for Mfg Part Nums'
          );
  EGO_ITEM_TEXT_UTIL.Sync_Index();
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Successfully called Sync IM Index for Mfg Part Nums'
          );
  --
  -- calling the business event now
  -- just call once for the entire batch
  --
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Calling Business Events for Mfg Part Nums'
          );
  EGO_WF_WRAPPER_PVT.Raise_Item_Event(
          p_event_name          => EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT
--         ,p_dml_type            IN   VARCHAR2    DEFAULT NULL
         ,p_request_id          => G_REQUEST_ID
--         ,p_Inventory_Item_Id   IN   NUMBER      DEFAULT NULL
--         ,p_Organization_Id     IN   NUMBER      DEFAULT NULL
--         ,p_Revision_id         IN   NUMBER      DEFAULT NULL
--         ,p_category_id         IN   VARCHAR2    DEFAULT NULL
--         ,p_catalog_id          IN   VARCHAR2    DEFAULT NULL
         ,x_msg_data            => l_msg_data
         ,x_return_status       => l_return_status
         );
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
            ,p_module    => l_api_name
            ,p_message   => 'Returning BE for Mfg Part Nums with status '||
                             l_return_status ||' and message: '||l_msg_data
          );
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Procedure completed with status '||RETCODE
          );
EXCEPTION
    WHEN NO_ROWS_IN_INTF_TABLE THEN
      RETCODE :=  G_CONC_RET_STS_SUCCESS;
    WHEN OTHERS THEN
      ROLLBACK TO LOAD_INTERFACE_LINES_SP;
      RETCODE  := G_CONC_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      ERRBUF    := FND_MSG_PUB.get();
      log_now (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
              ,p_module    => l_api_name
              ,p_message   => ERRBUF
              );
END Load_Interface_Lines;


END EGO_ITEM_AML_PVT;

/
