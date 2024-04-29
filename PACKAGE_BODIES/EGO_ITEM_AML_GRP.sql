--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_AML_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_AML_GRP" AS
/* $Header: EGOGAMLB.pls 120.0 2005/06/28 01:56:59 srajapar noship $ */

-- ==========================================================================
--                         Package variables and cursors
-- ==========================================================================

  G_FILE_NAME                  VARCHAR2(12);
  G_PKG_NAME                   VARCHAR2(30);

  G_USER_ID                    NUMBER;
  G_LOGIN_ID                   NUMBER;
  G_SYSDATE                    DATE;

  G_DEBUG_LEVEL_UNEXPECTED     NUMBER;
  G_DEBUG_LEVEL_ERROR          NUMBER;
  G_DEBUG_LEVEL_EXCEPTION      NUMBER;
  G_DEBUG_LEVEL_EVENT          NUMBER;
  G_DEBUG_LEVEL_PROCEDURE      NUMBER;
  G_DEBUG_LEVEL_STATEMENT      NUMBER;
  G_DEBUG_LOG_HEAD             VARCHAR2(30);

-- ==========================================================================
--                     Private Functions and Procedures
-- ==========================================================================
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
--  sri_debug(G_PKG_NAME||' - '||p_message);
NULL;
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
  G_FILE_NAME  := NVL(G_FILE_NAME,'EGOAMGRB.pls');
  G_PKG_NAME   := NVL(G_PKG_NAME,'EGO_ITEM_AML_GRP');
  --
  -- user values
  --
  G_USER_ID    := NVL(G_USER_ID,FND_GLOBAL.user_id);
  G_LOGIN_ID   := NVL(G_LOGIN_ID,FND_GLOBAL.login_id);
  G_SYSDATE    := NVL(G_SYSDATE,SYSDATE);
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

EXCEPTION
  WHEN OTHERS THEN
    log_now (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
            ,p_module    => 'SetGlobals'
            ,p_message   => 'Unable to intialize Globals'
            );
END SetGobals;


-- ==========================================================================
--                     Public Functions and Procedures
-- ==========================================================================

Procedure Populate_Intf_With_Proddata (
    p_api_version            IN  NUMBER
   ,p_commit                 IN  VARCHAR2
   ,p_data_set_id            IN  NUMBER
   ,p_pf_to_process          IN  NUMBER
   ,p_pf_after_population    IN  NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   ) IS

  l_api_version    NUMBER;
  l_api_name       VARCHAR2(50);

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

BEGIN
  l_api_version := 1.0;
  l_api_name    := 'POPULATE_INTF_WITH_PRODDATA';
  SetGobals();
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
    x_msg_data  := fnd_message.get();
    x_msg_count := 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF (p_pf_to_process IS NULL) THEN
    fnd_message.set_name('EGO', 'EGO_PROCESS_FLAG');
    l_msg_data := fnd_msg_pub.get();
    fnd_message.set_name('EGO','EGO_PKG_MAND_VALUES_MISS1');
    fnd_message.set_token('PACKAGE', G_PKG_NAME ||'.'|| l_api_name);
    fnd_message.set_token('VALUE', l_msg_data);
    x_msg_data  := fnd_message.get();
    x_msg_count := 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
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
    AND PROCESS_FLAG = p_pf_to_process
    AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('EGO','EGO_IPI_NO_LINES');
      x_msg_count := 1;
      x_msg_data :=  fnd_message.get();
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RAISE NO_ROWS_IN_INTF_TABLE;
  END;
  log_now (p_log_level => G_DEBUG_LEVEL_STATEMENT
          ,p_module    => l_api_name
          ,p_message   => 'Found Interface Lines to be processed'
          );

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    -- create save point
    SAVEPOINT POPULATE_INTF_WITH_PRODDATA_SP;
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
                                      end_date),
       process_flag = NVL(p_pf_after_population,process_flag)
  WHERE data_set_id = p_data_set_id
  AND process_flag = p_pf_to_process
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
  log_now(p_log_level => G_DEBUG_LEVEL_STATEMENT
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
          ,process_flag
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
                                         intf.end_date),
           NVL(p_pf_after_population,p_pf_to_process)
        FROM mtl_mfg_part_numbers prod
        WHERE intf.inventory_item_id = prod.inventory_item_id
        AND intf.organization_id = prod.organization_id
        AND intf.manufacturer_id = prod.manufacturer_id
        AND intf.mfg_part_num    = prod.mfg_part_num
      )
  WHERE data_set_id = p_data_set_id
  AND process_flag = p_pf_to_process
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
  log_now(p_log_level => G_DEBUG_LEVEL_STATEMENT
         ,p_module    => l_api_name
         ,p_message   => 'Populate intf table with prod data for UPDATE done'
         );

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;
  log_now (p_log_level => G_DEBUG_LEVEL_PROCEDURE
          ,p_module    => l_api_name
          ,p_message   => 'Procedure successfully completed'
          );
EXCEPTION
    WHEN NO_ROWS_IN_INTF_TABLE THEN
      NULL;
    WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO POPULATE_INTF_WITH_PRODDATA_SP;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      x_msg_data := FND_MSG_PUB.get();
      x_msg_count := 1;
      log_now (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
              ,p_module    => l_api_name
              ,p_message   => x_msg_data
              );
END Populate_Intf_With_Proddata;


END EGO_ITEM_AML_GRP;

/
