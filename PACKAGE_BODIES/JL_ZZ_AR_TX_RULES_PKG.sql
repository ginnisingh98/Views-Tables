--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_RULES_PKG" AS
/* $Header: jlzztxrb.pls 120.2 2003/03/03 19:39:38 opedrega ship $ */

  PROCEDURE Insert_Row
       (X_rowid             IN OUT NOCOPY VARCHAR2,
        X_rule_id                         NUMBER,
        X_tax_rule_level                  VARCHAR2,
        X_rule                            VARCHAR2,
        X_tax_category_id                 NUMBER,
        X_contributor_type                VARCHAR2,
        X_cust_trx_type_id                NUMBER,
        X_last_update_date                DATE,
        X_last_updated_by                 NUMBER,
        X_priority                        NUMBER,
        X_description                     VARCHAR2,
        X_org_id                          NUMBER,
        X_last_update_login               NUMBER,
        X_creation_date                   DATE,
        X_created_by                      NUMBER,
        X_calling_sequence  IN            VARCHAR2) IS

    CURSOR C IS
      SELECT rowid
      FROM jl_zz_ar_tx_rules
      WHERE rule = X_rule
      AND tax_rule_level = X_tax_rule_level
      AND tax_category_id = X_tax_category_id
      AND contributor_type = X_contributor_type
      AND cust_trx_type_id = X_cust_trx_type_id
      AND priority = X_priority
      AND org_id = X_org_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_RULES_PKG.INSERT_ROW<-' ||
                                X_calling_sequence;

    debug_info := 'Insert into JL_ZZ_AR_TX_RULES  ';
    INSERT INTO JL_ZZ_AR_TX_RULES(rule_id,
                                  tax_rule_level,
                                  rule,
                                  tax_category_id,
                                  contributor_type,
                                  cust_trx_type_id,
                                  org_id,
                                  last_update_date,
                                  last_updated_by,
                                  priority,
                                  description,
                                  last_update_login,
                                  creation_date,
                                  created_by)
                          VALUES (X_rule_id,
                                  X_tax_rule_level,
                                  X_rule,
                                  X_tax_category_id,
                                  X_contributor_type,
                                  X_cust_trx_type_id,
                                  X_org_id,
                                  X_last_update_date,
                                  X_last_updated_by,
                                  X_priority,
                                  X_description,
                                  X_last_update_login,
                                  X_creation_date,
                                  X_created_by);

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                              'rule = ' || X_rule ||
                              'tax_rule_level = ' || X_tax_rule_level ||
                              'tax_category_id =' ||X_tax_category_id||
                              'contributor_type = ' || X_contributor_type ||
                              'cust_trx_type_id = ' || X_cust_trx_type_id ||
                              'priority =' ||X_priority);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row
       (X_rowid                           VARCHAR2,
        X_rule_id                         NUMBER,
        X_tax_rule_level                  VARCHAR2,
        X_rule                            VARCHAR2,
        X_tax_category_id                 NUMBER,
        X_contributor_type                VARCHAR2,
        X_cust_trx_type_id                NUMBER,
        X_last_update_date                DATE,
        X_last_updated_by                 NUMBER,
        X_priority                        NUMBER,
        X_description                     VARCHAR2,
        X_org_id                          NUMBER,
        X_last_update_login               NUMBER,
        X_creation_date                   DATE,
        X_created_by                      NUMBER,
        X_calling_sequence   IN           VARCHAR2) IS

    CURSOR C IS
      SELECT *
      FROM jl_zz_ar_tx_rules
      WHERE rule = X_rule
      AND tax_rule_level = X_tax_rule_level
      AND tax_category_id = X_tax_category_id
      AND contributor_type = X_contributor_type
      AND cust_trx_type_id = X_cust_trx_type_id
      AND priority = X_priority
      AND org_id = X_org_id
      FOR UPDATE of rule,
                    tax_rule_level,
                    tax_category_id,
                    contributor_type,
                    cust_trx_type_id,
                    priority
      NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'JL_ZZ_AR_TX_RULES_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;

    IF ((Recinfo.rule = X_rule) AND
        (Recinfo.tax_rule_level = X_tax_rule_level) AND
        (Recinfo.tax_category_id = X_tax_category_id) AND
        (Recinfo.contributor_type = X_contributor_type) AND
        (Recinfo.cust_trx_type_id = X_cust_trx_type_id) AND
        (Recinfo.priority = X_priority) AND
        (Recinfo.rule_id = X_rule_id) AND
        (Recinfo.last_updated_by = X_last_updated_by) AND
        (Recinfo.last_update_date = X_last_update_date) AND
        ((Recinfo.description = X_description) OR
         ((Recinfo.description IS NULL) AND
          (X_description IS NULL))) AND
        ((Recinfo.last_update_login = X_last_update_login) OR
         ((Recinfo.last_update_login IS NULL) AND
          (X_last_update_login IS NULL))) AND
        ((Recinfo.creation_date = X_creation_date) OR
         ((Recinfo.creation_date IS NULL) AND
          (X_creation_date IS NULL))) AND
        ((Recinfo.created_by = X_created_by) OR
         ((Recinfo.created_by IS NULL) AND
          (X_created_by IS NULL)))) THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'rule = ' || X_rule ||
                                'tax_rule_level = ' || X_tax_rule_level ||
                                'tax_category_id =' ||X_tax_category_id||
                                'contributor_type = ' || X_contributor_type ||
                                'cust_trx_type_id = ' || X_cust_trx_type_id ||
                                'priority =' ||X_priority);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row
       (X_rowid                           VARCHAR2,
        X_rule_id                         NUMBER,
        X_tax_rule_level                  VARCHAR2,
        X_rule                            VARCHAR2,
        X_tax_category_id                 NUMBER,
        X_contributor_type                VARCHAR2,
        X_cust_trx_type_id                NUMBER,
        X_last_update_date                DATE,
        X_last_updated_by                 NUMBER,
        X_priority                        NUMBER,
        X_description                     VARCHAR2,
        X_org_id                          NUMBER,
        X_last_update_login               NUMBER,
        X_creation_date                   DATE,
        X_created_by                      NUMBER,
        X_calling_sequence        IN      VARCHAR2) IS

  BEGIN
    UPDATE jl_zz_ar_tx_rules
    SET rule_id           = X_rule_id,
        tax_rule_level    = X_tax_rule_level,
        rule              = X_rule,
        tax_category_id   = X_tax_category_id,
        contributor_type  = X_contributor_type,
        cust_trx_type_id  = X_cust_trx_type_id,
        org_id            = X_org_id,
        last_update_date  = X_last_update_date,
        last_updated_by   = X_last_updated_by,
        priority          = X_priority,
        description       = X_description,
        last_update_login = X_last_update_login,
        creation_date     = X_creation_date,
        created_by        = X_created_by
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (X_rowid                   VARCHAR2) IS

  BEGIN
    DELETE
    FROM jl_zz_ar_tx_rules
    WHERE rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

END JL_ZZ_AR_TX_RULES_PKG;

/
