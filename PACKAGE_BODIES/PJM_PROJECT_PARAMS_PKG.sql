--------------------------------------------------------
--  DDL for Package Body PJM_PROJECT_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PROJECT_PARAMS_PKG" AS
/* $Header: PJMPPRMB.pls 115.2 2002/12/09 08:13:57 alaw noship $ */

PROCEDURE insert_row
( X_ROWID                        IN OUT NOCOPY VARCHAR2
, X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
, X_SEIBAN_NUMBER_FLAG           IN     NUMBER
, X_COSTING_GROUP_ID             IN     NUMBER
, X_PLANNING_GROUP               IN     VARCHAR2
, X_WIP_ACCT_CLASS_CODE          IN     VARCHAR2
, X_EAM_ACCT_CLASS_CODE          IN     VARCHAR2
, X_START_DATE_ACTIVE            IN     DATE
, X_END_DATE_ACTIVE              IN     DATE
, X_IPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_ERV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_FREIGHT_EXPENDITURE_TYPE     IN     VARCHAR2
, X_TAX_EXPENDITURE_TYPE         IN     VARCHAR2
, X_MISC_EXPENDITURE_TYPE        IN     VARCHAR2
, X_PPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_DIR_ITEM_EXPENDITURE_TYPE    IN     VARCHAR2
, X_ATTRIBUTE_CATEGORY           IN     VARCHAR2
, X_ATTRIBUTE1                   IN     VARCHAR2
, X_ATTRIBUTE2                   IN     VARCHAR2
, X_ATTRIBUTE3                   IN     VARCHAR2
, X_ATTRIBUTE4                   IN     VARCHAR2
, X_ATTRIBUTE5                   IN     VARCHAR2
, X_ATTRIBUTE6                   IN     VARCHAR2
, X_ATTRIBUTE7                   IN     VARCHAR2
, X_ATTRIBUTE8                   IN     VARCHAR2
, X_ATTRIBUTE9                   IN     VARCHAR2
, X_ATTRIBUTE10                  IN     VARCHAR2
, X_ATTRIBUTE11                  IN     VARCHAR2
, X_ATTRIBUTE12                  IN     VARCHAR2
, X_ATTRIBUTE13                  IN     VARCHAR2
, X_ATTRIBUTE14                  IN     VARCHAR2
, X_ATTRIBUTE15                  IN     VARCHAR2
, X_CREATION_DATE                IN     DATE
, X_CREATED_BY                   IN     NUMBER
, X_LAST_UPDATE_DATE             IN     DATE
, X_LAST_UPDATED_BY              IN     NUMBER
, X_LAST_UPDATE_LOGIN            IN     NUMBER
) IS

  CURSOR c IS
    SELECT rowid FROM pjm_project_parameters
    WHERE project_id = X_project_id
    AND organization_id = X_organization_id
    ;

BEGIN

  INSERT INTO pjm_project_parameters
  ( project_id
  , organization_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , seiban_number_flag
  , costing_group_id
  , planning_group
  , wip_acct_class_code
  , eam_acct_class_code
  , start_date_active
  , end_date_active
  , ipv_expenditure_type
  , erv_expenditure_type
  , freight_expenditure_type
  , taX_expenditure_type
  , misc_expenditure_type
  , ppv_expenditure_type
  , dir_item_expenditure_type
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  ) values
  ( X_project_id
  , X_organization_id
  , X_creation_date
  , X_created_by
  , X_last_update_date
  , X_last_updated_by
  , X_last_update_login
  , X_seiban_number_flag
  , X_costing_group_id
  , X_planning_group
  , X_wip_acct_class_code
  , X_eam_acct_class_code
  , X_start_date_active
  , X_end_date_active
  , X_ipv_expenditure_type
  , X_erv_expenditure_type
  , X_freight_expenditure_type
  , X_taX_expenditure_type
  , X_misc_expenditure_type
  , X_ppv_expenditure_type
  , X_dir_item_expenditure_type
  , X_attribute_category
  , X_attribute1
  , X_attribute2
  , X_attribute3
  , X_attribute4
  , X_attribute5
  , X_attribute6
  , X_attribute7
  , X_attribute8
  , X_attribute9
  , X_attribute10
  , X_attribute11
  , X_attribute12
  , X_attribute13
  , X_attribute14
  , X_attribute15
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%notfound) THEN
    CLOSE c;
    RAISE no_data_found;
  END IF;
  CLOSE c;

END insert_row;


PROCEDURE lock_row
( X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
, X_COSTING_GROUP_ID             IN     NUMBER
, X_WIP_ACCT_CLASS_CODE          IN     VARCHAR2
, X_EAM_ACCT_CLASS_CODE          IN     VARCHAR2
, X_START_DATE_ACTIVE            IN     DATE
, X_END_DATE_ACTIVE              IN     DATE
, X_IPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_ERV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_FREIGHT_EXPENDITURE_TYPE     IN     VARCHAR2
, X_TAX_EXPENDITURE_TYPE         IN     VARCHAR2
, X_MISC_EXPENDITURE_TYPE        IN     VARCHAR2
, X_PPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_DIR_ITEM_EXPENDITURE_TYPE    IN     VARCHAR2
, X_ATTRIBUTE_CATEGORY           IN     VARCHAR2
, X_ATTRIBUTE1                   IN     VARCHAR2
, X_ATTRIBUTE2                   IN     VARCHAR2
, X_ATTRIBUTE3                   IN     VARCHAR2
, X_ATTRIBUTE4                   IN     VARCHAR2
, X_ATTRIBUTE5                   IN     VARCHAR2
, X_ATTRIBUTE6                   IN     VARCHAR2
, X_ATTRIBUTE7                   IN     VARCHAR2
, X_ATTRIBUTE8                   IN     VARCHAR2
, X_ATTRIBUTE9                   IN     VARCHAR2
, X_ATTRIBUTE10                  IN     VARCHAR2
, X_ATTRIBUTE11                  IN     VARCHAR2
, X_ATTRIBUTE12                  IN     VARCHAR2
, X_ATTRIBUTE13                  IN     VARCHAR2
, X_ATTRIBUTE14                  IN     VARCHAR2
, X_ATTRIBUTE15                  IN     VARCHAR2
) IS

  CURSOR c IS
  SELECT costing_group_id
  ,      wip_acct_class_code
  ,      eam_acct_class_code
  ,      start_date_active
  ,      end_date_active
  ,      ipv_expenditure_type
  ,      erv_expenditure_type
  ,      freight_expenditure_type
  ,      taX_expenditure_type
  ,      misc_expenditure_type
  ,      ppv_expenditure_type
  ,      dir_item_expenditure_type
  ,      attribute_category
  ,      attribute1
  ,      attribute2
  ,      attribute3
  ,      attribute4
  ,      attribute5
  ,      attribute6
  ,      attribute7
  ,      attribute8
  ,      attribute9
  ,      attribute10
  ,      attribute11
  ,      attribute12
  ,      attribute13
  ,      attribute14
  ,      attribute15
  FROM pjm_project_parameters
  WHERE project_id = X_project_id
  AND organization_id = X_organization_id
  FOR UPDATE OF project_id NOWAIT;

  recinfo c%rowtype;

BEGIN

  OPEN c;
  FETCH c INTO recinfo;
  IF (c%notfound) THEN
    CLOSE c;
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE c;

  IF (    (   ( recinfo.costing_group_id = X_costing_group_id )
           OR (   ( recinfo.costing_group_id IS NULL )
              AND ( X_costing_group_id IS NULL ) ) )
      AND (   ( recinfo.wip_acct_class_code = X_wip_acct_class_code )
           OR (   ( recinfo.wip_acct_class_code IS NULL )
              AND ( X_wip_acct_class_code IS NULL ) ) )
      AND (   ( recinfo.eam_acct_class_code = X_eam_acct_class_code )
           OR (   ( recinfo.eam_acct_class_code IS NULL )
              AND ( X_eam_acct_class_code IS NULL ) ) )
      AND (   ( recinfo.ipv_expenditure_type = X_ipv_expenditure_type )
           OR (   ( recinfo.ipv_expenditure_type IS NULL )
              AND ( X_ipv_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.erv_expenditure_type = X_erv_expenditure_type )
           OR (   ( recinfo.erv_expenditure_type IS NULL )
              AND ( X_erv_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.freight_expenditure_type = X_freight_expenditure_type )
           OR (   ( recinfo.freight_expenditure_type IS NULL )
              AND ( X_freight_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.tax_expenditure_type = X_tax_expenditure_type )
           OR (   ( recinfo.tax_expenditure_type IS NULL )
              AND ( X_tax_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.misc_expenditure_type = X_misc_expenditure_type )
           OR (   ( recinfo.misc_expenditure_type IS NULL )
              AND ( X_misc_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.ppv_expenditure_type = X_ppv_expenditure_type )
           OR (   ( recinfo.ppv_expenditure_type IS NULL )
              AND ( X_ppv_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.dir_item_expenditure_type = X_dir_item_expenditure_type )
           OR (   ( recinfo.dir_item_expenditure_type IS NULL )
              AND ( X_dir_item_expenditure_type IS NULL ) ) )
      AND (   ( recinfo.start_date_active = X_start_date_active )
           OR (   ( recinfo.start_date_active IS NULL )
              AND ( X_start_date_active IS NULL ) ) )
      AND (   ( recinfo.end_date_active = X_end_date_active )
           OR (   ( recinfo.end_date_active IS NULL )
              AND ( X_end_date_active IS NULL ) ) )
      AND (   ( recinfo.attribute_category = X_attribute_category )
           OR (   ( recinfo.attribute_category IS NULL )
              AND ( X_attribute_category IS NULL ) ) )
      AND (   ( recinfo.attribute1 = X_attribute1 )
           OR (   ( recinfo.attribute1 IS NULL )
              AND ( X_attribute1 IS NULL ) ) )
      AND (   ( recinfo.attribute2 = X_attribute2 )
           OR (   ( recinfo.attribute2 IS NULL )
              AND ( X_attribute2 IS NULL ) ) )
      AND (   ( recinfo.attribute3 = X_attribute3 )
           OR (   ( recinfo.attribute3 IS NULL )
              AND ( X_attribute3 IS NULL ) ) )
      AND (   ( recinfo.attribute4 = X_attribute4 )
           OR (   ( recinfo.attribute4 IS NULL )
              AND ( X_attribute4 IS NULL ) ) )
      AND (   ( recinfo.attribute5 = X_attribute5 )
           OR (   ( recinfo.attribute5 IS NULL )
              AND ( X_attribute5 IS NULL ) ) )
      AND (   ( recinfo.attribute6 = X_attribute6 )
           OR (   ( recinfo.attribute6 IS NULL )
              AND ( X_attribute6 IS NULL ) ) )
      AND (   ( recinfo.attribute7 = X_attribute7 )
           OR (   ( recinfo.attribute7 IS NULL )
              AND ( X_attribute7 IS NULL ) ) )
      AND (   ( recinfo.attribute8 = X_attribute8 )
           OR (   ( recinfo.attribute8 IS NULL )
              AND ( X_attribute8 IS NULL ) ) )
      AND (   ( recinfo.attribute9 = X_attribute9 )
           OR (   ( recinfo.attribute9 IS NULL )
              AND ( X_attribute9 IS NULL ) ) )
      AND (   ( recinfo.attribute10 = X_attribute10 )
           OR (   ( recinfo.attribute10 IS NULL )
              AND ( X_attribute10 IS NULL ) ) )
      AND (   ( recinfo.attribute11 = X_attribute11 )
           OR (   ( recinfo.attribute11 IS NULL )
              AND ( X_attribute11 IS NULL ) ) )
      AND (   ( recinfo.attribute12 = X_attribute12 )
           OR (   ( recinfo.attribute12 IS NULL )
              AND ( X_attribute12 IS NULL ) ) )
      AND (   ( recinfo.attribute13 = X_attribute13 )
           OR (   ( recinfo.attribute13 IS NULL )
              AND ( X_attribute13 IS NULL ) ) )
      AND (   ( recinfo.attribute14 = X_attribute14 )
           OR (   ( recinfo.attribute14 IS NULL )
              AND ( X_attribute14 IS NULL ) ) )
      AND (   ( recinfo.attribute15 = X_attribute15 )
           OR (   ( recinfo.attribute15 IS NULL )
              AND ( X_attribute15 IS NULL ) ) )
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;

END lock_row;


PROCEDURE update_row
( X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
, X_COSTING_GROUP_ID             IN     NUMBER
, X_WIP_ACCT_CLASS_CODE          IN     VARCHAR2
, X_EAM_ACCT_CLASS_CODE          IN     VARCHAR2
, X_START_DATE_ACTIVE            IN     DATE
, X_END_DATE_ACTIVE              IN     DATE
, X_IPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_ERV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_FREIGHT_EXPENDITURE_TYPE     IN     VARCHAR2
, X_TAX_EXPENDITURE_TYPE         IN     VARCHAR2
, X_MISC_EXPENDITURE_TYPE        IN     VARCHAR2
, X_PPV_EXPENDITURE_TYPE         IN     VARCHAR2
, X_DIR_ITEM_EXPENDITURE_TYPE    IN     VARCHAR2
, X_ATTRIBUTE_CATEGORY           IN     VARCHAR2
, X_ATTRIBUTE1                   IN     VARCHAR2
, X_ATTRIBUTE2                   IN     VARCHAR2
, X_ATTRIBUTE3                   IN     VARCHAR2
, X_ATTRIBUTE4                   IN     VARCHAR2
, X_ATTRIBUTE5                   IN     VARCHAR2
, X_ATTRIBUTE6                   IN     VARCHAR2
, X_ATTRIBUTE7                   IN     VARCHAR2
, X_ATTRIBUTE8                   IN     VARCHAR2
, X_ATTRIBUTE9                   IN     VARCHAR2
, X_ATTRIBUTE10                  IN     VARCHAR2
, X_ATTRIBUTE11                  IN     VARCHAR2
, X_ATTRIBUTE12                  IN     VARCHAR2
, X_ATTRIBUTE13                  IN     VARCHAR2
, X_ATTRIBUTE14                  IN     VARCHAR2
, X_ATTRIBUTE15                  IN     VARCHAR2
, X_LAST_UPDATE_DATE             IN     DATE
, X_LAST_UPDATED_BY              IN     NUMBER
, X_LAST_UPDATE_LOGIN            IN     NUMBER
) IS
BEGIN

  UPDATE pjm_project_parameters
  SET  costing_group_id               = X_costing_group_id
  ,    wip_acct_class_code            = X_wip_acct_class_code
  ,    eam_acct_class_code            = X_eam_acct_class_code
  ,    ipv_expenditure_type           = X_ipv_expenditure_type
  ,    erv_expenditure_type           = X_erv_expenditure_type
  ,    freight_expenditure_type       = X_freight_expenditure_type
  ,    taX_expenditure_type           = X_taX_expenditure_type
  ,    misc_expenditure_type          = X_misc_expenditure_type
  ,    ppv_expenditure_type           = X_ppv_expenditure_type
  ,    dir_item_expenditure_type      = X_dir_item_expenditure_type
  ,    start_date_active              = X_start_date_active
  ,    end_date_active                = X_end_date_active
  ,    attribute_category             = X_attribute_category
  ,    attribute1                     = X_attribute1
  ,    attribute2                     = X_attribute2
  ,    attribute3                     = X_attribute3
  ,    attribute4                     = X_attribute4
  ,    attribute5                     = X_attribute5
  ,    attribute6                     = X_attribute6
  ,    attribute7                     = X_attribute7
  ,    attribute8                     = X_attribute8
  ,    attribute9                     = X_attribute9
  ,    attribute10                    = X_attribute10
  ,    attribute11                    = X_attribute11
  ,    attribute12                    = X_attribute12
  ,    attribute13                    = X_attribute13
  ,    attribute14                    = X_attribute14
  ,    attribute15                    = X_attribute15
  ,    last_update_date               = X_last_update_date
  ,    last_updated_by                = X_last_updated_by
  ,    last_update_login              = X_last_update_login
  WHERE project_id = X_project_id
  AND organization_id = X_organization_id;

  IF (sql%notfound ) THEN
    RAISE no_data_found;
  END IF;

END update_row;


PROCEDURE delete_row
( X_PROJECT_ID                   IN     NUMBER
, X_ORGANIZATION_ID              IN     NUMBER
) IS
BEGIN

  DELETE FROM pjm_project_parameters
  WHERE project_id = X_project_id
  AND organization_id = X_organization_id;

  IF (sql%notfound ) THEN
    RAISE no_data_found;
  END IF;

END delete_row;


PROCEDURE update_planning_group
( X_PROJECT_ID                   IN     NUMBER
, X_PLANNING_GROUP               IN     VARCHAR2
) IS

  --
  -- Making this procedure as AUTONOMOUS transaction
  --
  -- pragma autonomous_transaction;

  CURSOR pp IS
    SELECT organization_id
    FROM   pjm_project_parameters
    WHERE  project_id = X_project_id
    FOR UPDATE OF planning_group NOWAIT;

BEGIN

  FOR pprec IN pp LOOP

    UPDATE pjm_project_parameters
    SET    planning_group    = X_planning_group
    ,      last_update_date  = sysdate
    ,      last_updated_by   = fnd_global.user_id
    ,      last_update_login = fnd_global.login_id
    WHERE  project_id = X_project_id
    AND    organization_id = pprec.organization_id;

  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  raise;

END update_planning_group;

END PJM_PROJECT_PARAMS_PKG;

/
