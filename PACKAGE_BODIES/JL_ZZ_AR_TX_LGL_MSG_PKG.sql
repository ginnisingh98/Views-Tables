--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_LGL_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_LGL_MSG_PKG" AS
/* $Header: jlzztlmb.pls 120.2 2003/03/03 19:36:18 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid                     IN OUT NOCOPY VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_message_id                              NUMBER,
        X_inventory_item_flag                     VARCHAR2,
        X_inventory_organization_id               NUMBER,
        X_start_date_active                       DATE,
        X_end_date_active                         DATE,
        X_org_id                                  NUMBER,
        X_last_update_date                        DATE,
        X_last_updated_by                         NUMBER,
        X_last_update_login                       NUMBER,
        X_creation_date                           DATE,
        X_created_by                              NUMBER,
        X_calling_sequence          IN            VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM jl_zz_ar_tx_lgl_msg
      WHERE rule_id = X_rule_id
      AND rule_data_id = X_rule_data_id
      AND exception_code = X_exception_code
      AND org_id = X_org_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

    BEGIN
      --     Update the calling sequence
      --
      current_calling_sequence := 'jl_zz_ar_tx_lgl_msg_PKG.INSERT_ROW<-' ||
                                  X_calling_sequence;

      debug_info := 'Insert INTO jl_zz_ar_tx_lgl_msg  ';
      INSERT INTO jl_zz_ar_tx_lgl_msg(rule_id,
                                      rule_data_id,
                                      exception_code,
                                      message_id,
                                      inventory_item_flag,
                                      inventory_organization_id,
                                      start_date_active,
                                      end_date_active,
                                      org_id,
                                      last_update_date,
                                      last_updated_by,
                                      last_update_login,
                                      creation_date,
                                      created_by)
                              VALUES (X_rule_id,
                                      X_rule_data_id,
                                      X_exception_code,
                                      X_message_id,
                                      X_inventory_item_flag,
                                      X_inventory_organization_id,
                                      X_start_date_active,
                                      X_end_date_active,
                                      X_org_id,
                                      X_last_update_date,
                                      X_last_updated_by,
                                      X_last_update_login,
                                      X_creation_date,
                                      X_created_by);

    debug_info := 'Open CURSOR C';
    OPEN C;
    debug_info := 'Fetch CURSOR C';
    FETCH C INTO X_rowid;
    IF (C%NOTFOUND) then
      debug_info := 'Close CURSOR C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    debug_info := 'Close CURSOR C';
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              'org_id = '  || X_org_id ||
                              'rule_id = ' || X_rule_id ||
                              'rule_data_id = ' || X_rule_data_id );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row
       (X_rowid                                   VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_message_id                              NUMBER,
        X_inventory_item_flag                     VARCHAR2,
        X_inventory_organization_id               NUMBER,
        X_start_date_active                       DATE,
        X_end_date_active                         DATE,
        X_org_id                                  NUMBER,
        X_last_update_date                        DATE,
        X_last_updated_by                         NUMBER,
        X_last_update_login                       NUMBER,
        X_creation_date                           DATE,
        X_created_by                              NUMBER,
        X_calling_sequence          IN            VARCHAR2) IS

    CURSOR C IS
      SELECT RULE_ID,
             RULE_DATA_ID,
             EXCEPTION_CODE,
             MESSAGE_ID,
             INVENTORY_ITEM_FLAG,
             INVENTORY_ORGANIZATION_ID,
             START_DATE_ACTIVE,
             END_DATE_ACTIVE,
             ORG_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN
      FROM JL_ZZ_AR_TX_LGL_MSG
      WHERE rule_id = X_rule_id
      AND rule_data_id = X_rule_data_id
      AND exception_code = X_exception_code
      AND org_id = X_org_id
      FOR UPDATE of rule_id,
                    exception_code,
                    rule_data_id,
                    org_id
      NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
    --  Update the calling sequence
    --
    current_calling_sequence := 'jl_zz_ar_tx_lgl_msg_PKG.LOCK_ROW<-' ||
                                X_calling_sequence;

    debug_info := 'Open CURSOR C';
    OPEN C;
    debug_info := 'Fetch CURSOR C';
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      debug_info := 'Close CURSOR C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    debug_info := 'Close CURSOR C';
    CLOSE C;
    IF ((Recinfo.rule_id = X_rule_id)      AND
        (Recinfo.rule_data_id = X_rule_data_id) AND
        (Recinfo.message_id = X_message_id) AND
        (Recinfo.exception_code = X_exception_code) AND
        (Recinfo.inventory_item_flag = X_inventory_item_flag) AND
        (Recinfo.last_updated_by = X_last_updated_by) AND
        (Recinfo.last_update_date = X_last_update_date) AND
        ((Recinfo.inventory_organization_id = X_inventory_organization_id) OR
         ((X_inventory_organization_id IS NULL) AND
          (Recinfo.inventory_organization_id IS NULL))) AND
        ((Recinfo.start_date_active = X_start_date_active) OR
         ((X_start_date_active IS NULL) AND
          (Recinfo.start_date_active IS NULL))) AND
        ((Recinfo.end_date_active = X_end_date_active) OR
         ((X_end_date_active IS NULL) AND
          (Recinfo.end_date_active IS NULL))) AND
        ((Recinfo.org_id = X_org_id) OR
         ((X_org_id IS NULL) AND
          (Recinfo.org_id IS NULL))) AND
        ((Recinfo.last_update_login = X_last_update_login) OR
         ((X_last_update_login IS NULL) AND
          (Recinfo.last_update_login IS NULL))) AND
        ((Recinfo.creation_date = X_creation_date) OR
         ((X_creation_date IS NULL) AND
          (Recinfo.creation_date IS NULL))) AND
        ((Recinfo.created_by = X_created_by) OR
         ((X_created_by IS NULL) AND
          (Recinfo.created_by IS NULL)))) THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('AR','AR_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('AR','AR_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'rule_id = ' || X_rule_id ||
                                'rule_data_id = ' || X_rule_data_id );
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row
       (X_rowid                                   VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_message_id                              NUMBER,
        X_inventory_item_flag                     VARCHAR2,
        X_inventory_organization_id               NUMBER,
        X_start_date_active                       DATE,
        X_end_date_active                         DATE,
        X_org_id                                  NUMBER,
        X_last_update_date                        DATE,
        X_last_updated_by                         NUMBER,
        X_last_update_login                       NUMBER,
        X_creation_date                           DATE,
        X_created_by                              NUMBER,
        X_calling_sequence          IN            VARCHAR2) IS

  BEGIN
    UPDATE JL_ZZ_AR_TX_LGL_MSG
    SET rule_id                      = X_rule_id,
        rule_data_id                 = X_rule_data_id,
        exception_code               = X_exception_code,
        message_id                   = X_message_id,
        inventory_item_flag          = X_inventory_item_flag,
        inventory_organization_id    = X_inventory_organization_id,
        start_date_active            = X_start_date_active,
        end_date_active              = X_end_date_active,
        org_id                       = X_org_id,
        last_update_date             = X_last_update_date,
        last_updated_by              = X_last_updated_by,
        last_update_login            = X_last_update_login,
        creation_date                = X_creation_date,
        created_by                   = X_created_by
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (X_rowid         VARCHAR2) IS

  BEGIN
    DELETE
    FROM JL_ZZ_AR_TX_LGL_MSG
    WHERE rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

  PROCEDURE Check_Unique
       (X_rowid                                   VARCHAR2,
        X_rule_id                                 NUMBER,
        X_rule_data_id                            NUMBER,
        X_exception_code                          VARCHAR2,
        X_org_id                                  NUMBER) IS

    dummy  NUMBER;

  BEGIN
    SELECT count(1)
    INTO dummy
    FROM jl_zz_ar_tx_lgl_msg
    WHERE rule_id = X_rule_id
    AND rule_data_id = X_rule_data_id
    AND exception_code = X_exception_code
    AND org_id = X_org_id
    AND ((X_rowid IS NULL) OR (rowid <> X_rowid));

    IF (dummy >= 1) THEN
      FND_MESSAGE.SET_NAME ('JL', 'JL_ZZ_AR_TX_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'Legal Message');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Unique;

END jl_zz_ar_tx_lgl_msg_pkg;

/
