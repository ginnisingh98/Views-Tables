--------------------------------------------------------
--  DDL for Package Body PN_LOC_ACC_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LOC_ACC_MAP_PKG" as
-- $Header: PNEXACCB.pls 120.2 2005/11/28 02:01:43 appldev noship $
-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE insert_row (
x_LOC_ACC_MAP_ID      IN OUT NOCOPY NUMBER,
x_LOC_ACC_MAP_HDR_ID  IN NUMBER,
x_last_update_date    IN DATE,
x_last_updated_by     IN NUMBER,
x_creation_date       IN DATE,
x_created_by          IN NUMBER,
x_last_update_login   IN NUMBER,
x_PROPERTY_ID         IN NUMBER,
x_LOCATION_ID         IN NUMBER,
x_ACCOUNT_LOW         IN VARCHAR2,
x_ACCOUNT_HIGH        IN VARCHAR2,
x_EXPENSE_TYPE_CODE   IN VARCHAR2,
x_EFFECTIVE_FROM_DATE IN DATE,
x_EFFECTIVE_TO_DATE   IN DATE,
x_RECOVERABLE_FLAG    IN VARCHAR2,
x_SEGMENT1_LOW        IN VARCHAR2,
x_SEGMENT1_HIGH       IN VARCHAR2,
x_SEGMENT2_LOW        IN VARCHAR2,
x_SEGMENT2_HIGH       IN VARCHAR2,
x_SEGMENT3_LOW        IN VARCHAR2,
x_SEGMENT3_HIGH       IN VARCHAR2,
x_SEGMENT4_LOW        IN VARCHAR2,
x_SEGMENT4_HIGH       IN VARCHAR2,
x_SEGMENT5_LOW        IN VARCHAR2,
x_SEGMENT5_HIGH       IN VARCHAR2,
x_SEGMENT6_LOW        IN VARCHAR2,
x_SEGMENT6_HIGH       IN VARCHAR2,
x_SEGMENT7_LOW        IN VARCHAR2,
x_SEGMENT7_HIGH       IN VARCHAR2,
x_SEGMENT8_LOW        IN VARCHAR2,
x_SEGMENT8_HIGH       IN VARCHAR2,
x_SEGMENT9_LOW        IN VARCHAR2,
x_SEGMENT9_HIGH       IN VARCHAR2,
x_SEGMENT10_LOW       IN VARCHAR2,
x_SEGMENT10_HIGH      IN VARCHAR2,
x_SEGMENT11_LOW       IN VARCHAR2,
x_SEGMENT11_HIGH      IN VARCHAR2,
x_SEGMENT12_LOW       IN VARCHAR2,
x_SEGMENT12_HIGH      IN VARCHAR2,
x_SEGMENT13_LOW       IN VARCHAR2,
x_SEGMENT13_HIGH      IN VARCHAR2,
x_SEGMENT14_LOW       IN VARCHAR2,
x_SEGMENT14_HIGH      IN VARCHAR2,
x_SEGMENT15_LOW       IN VARCHAR2,
x_SEGMENT15_HIGH      IN VARCHAR2,
x_SEGMENT16_LOW       IN VARCHAR2,
x_SEGMENT16_HIGH      IN VARCHAR2,
x_SEGMENT17_LOW       IN VARCHAR2,
x_SEGMENT17_HIGH      IN VARCHAR2,
x_SEGMENT18_LOW       IN VARCHAR2,
x_SEGMENT18_HIGH      IN VARCHAR2,
x_SEGMENT19_LOW       IN VARCHAR2,
x_SEGMENT19_HIGH      IN VARCHAR2,
x_SEGMENT20_LOW       IN VARCHAR2,
x_SEGMENT20_HIGH      IN VARCHAR2,
x_SEGMENT21_LOW       IN VARCHAR2,
x_SEGMENT21_HIGH      IN VARCHAR2,
x_SEGMENT22_LOW       IN VARCHAR2,
x_SEGMENT22_HIGH      IN VARCHAR2,
x_SEGMENT23_LOW       IN VARCHAR2,
x_SEGMENT23_HIGH      IN VARCHAR2,
x_SEGMENT24_LOW       IN VARCHAR2,
x_SEGMENT24_HIGH      IN VARCHAR2,
x_SEGMENT25_LOW       IN VARCHAR2,
x_SEGMENT25_HIGH      IN VARCHAR2,
x_SEGMENT26_LOW       IN VARCHAR2,
x_SEGMENT26_HIGH      IN VARCHAR2,
x_SEGMENT27_LOW       IN VARCHAR2,
x_SEGMENT27_HIGH      IN VARCHAR2,
x_SEGMENT28_LOW       IN VARCHAR2,
x_SEGMENT28_HIGH      IN VARCHAR2,
x_SEGMENT29_LOW       IN VARCHAR2,
x_SEGMENT29_HIGH      IN VARCHAR2,
x_SEGMENT30_LOW       IN VARCHAR2,
x_SEGMENT30_HIGH      IN VARCHAR2,
x_attribute_category  IN VARCHAR2,
x_attribute1          IN VARCHAR2,
x_attribute2          IN VARCHAR2,
x_attribute3          IN VARCHAR2,
x_attribute4          IN VARCHAR2,
x_attribute5          IN VARCHAR2,
x_attribute6          IN VARCHAR2,
x_attribute7          IN VARCHAR2,
x_attribute8          IN VARCHAR2,
x_attribute9          IN VARCHAR2,
x_attribute10         IN VARCHAR2,
x_attribute11         IN VARCHAR2,
x_attribute12         IN VARCHAR2,
x_attribute13         IN VARCHAR2,
x_attribute14         IN VARCHAR2,
x_attribute15         IN VARCHAR2,
x_ORG_ID              IN NUMBER  default NULL
) IS

  CURSOR C IS
  SELECT LOC_ACC_MAP_ID
  FROM PN_LOC_ACC_MAP_ALL
  WHERE LOC_ACC_MAP_ID = x_LOC_ACC_MAP_ID;

  CURSOR org_cur IS
    SELECT org_id
    FROM pn_loc_acc_map_hdr_all
    WHERE loc_acc_map_hdr_id = x_LOC_ACC_MAP_HDR_ID;

  l_org_id NUMBER;

BEGIN

  IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
  ELSE
    l_org_id := x_org_id;
  END IF;

       INSERT INTO PN_LOC_ACC_MAP_ALL
        (LOC_ACC_MAP_ID,
       LOC_ACC_MAP_HDR_ID,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       PROPERTY_ID,
       LOCATION_ID,
       ACCOUNT_LOW,
       ACCOUNT_HIGH,
       EXPENSE_TYPE_CODE,
       EFFECTIVE_FROM_DATE,
       EFFECTIVE_TO_DATE,
       RECOVERABLE_FLAG,
       SEGMENT1_LOW,
       SEGMENT1_HIGH,
       SEGMENT2_LOW,
       SEGMENT2_HIGH,
       SEGMENT3_LOW,
       SEGMENT3_HIGH,
       SEGMENT4_LOW,
       SEGMENT4_HIGH,
       SEGMENT5_LOW,
       SEGMENT5_HIGH,
       SEGMENT6_LOW,
       SEGMENT6_HIGH,
       SEGMENT7_LOW,
       SEGMENT7_HIGH,
       SEGMENT8_LOW,
       SEGMENT8_HIGH,
       SEGMENT9_LOW,
       SEGMENT9_HIGH,
       SEGMENT10_LOW,
       SEGMENT10_HIGH,
       SEGMENT11_LOW,
       SEGMENT11_HIGH,
       SEGMENT12_LOW,
       SEGMENT12_HIGH,
       SEGMENT13_LOW,
       SEGMENT13_HIGH,
       SEGMENT14_LOW,
       SEGMENT14_HIGH,
       SEGMENT15_LOW,
       SEGMENT15_HIGH,
       SEGMENT16_LOW,
       SEGMENT16_HIGH,
       SEGMENT17_LOW,
       SEGMENT17_HIGH,
       SEGMENT18_LOW,
       SEGMENT18_HIGH,
       SEGMENT19_LOW,
       SEGMENT19_HIGH,
       SEGMENT20_LOW,
       SEGMENT20_HIGH,
       SEGMENT21_LOW,
       SEGMENT21_HIGH,
       SEGMENT22_LOW,
       SEGMENT22_HIGH,
       SEGMENT23_LOW,
       SEGMENT23_HIGH,
       SEGMENT24_LOW,
       SEGMENT24_HIGH,
       SEGMENT25_LOW,
       SEGMENT25_HIGH,
       SEGMENT26_LOW,
       SEGMENT26_HIGH,
       SEGMENT27_LOW,
       SEGMENT27_HIGH,
       SEGMENT28_LOW,
       SEGMENT28_HIGH,
       SEGMENT29_LOW,
       SEGMENT29_HIGH,
       SEGMENT30_LOW,
       SEGMENT30_HIGH,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       ORG_ID)
        VALUES (NVL(x_LOC_ACC_MAP_ID,PN_LOC_ACC_MAP_S.NEXTVAL),
              x_LOC_ACC_MAP_HDR_ID,
                  x_last_update_date,
              x_last_updated_by,
              x_creation_date,
              x_created_by,
              x_last_update_login,
              x_PROPERTY_ID,
              x_LOCATION_ID,
              x_ACCOUNT_LOW,
              x_ACCOUNT_HIGH,
              x_EXPENSE_TYPE_CODE,
              x_EFFECTIVE_FROM_DATE,
              x_EFFECTIVE_TO_DATE,
              x_RECOVERABLE_FLAG,
              x_SEGMENT1_LOW,
              x_SEGMENT1_HIGH,
              x_SEGMENT2_LOW,
              x_SEGMENT2_HIGH,
              x_SEGMENT3_LOW,
              x_SEGMENT3_HIGH,
              x_SEGMENT4_LOW,
              x_SEGMENT4_HIGH,
              x_SEGMENT5_LOW,
              x_SEGMENT5_HIGH,
              x_SEGMENT6_LOW,
              x_SEGMENT6_HIGH,
              x_SEGMENT7_LOW,
              x_SEGMENT7_HIGH,
              x_SEGMENT8_LOW,
              x_SEGMENT8_HIGH,
              x_SEGMENT9_LOW,
              x_SEGMENT9_HIGH,
              x_SEGMENT10_LOW,
              x_SEGMENT10_HIGH,
              x_SEGMENT11_LOW,
              x_SEGMENT11_HIGH,
              x_SEGMENT12_LOW,
              x_SEGMENT12_HIGH,
              x_SEGMENT13_LOW,
              x_SEGMENT13_HIGH,
              x_SEGMENT14_LOW,
              x_SEGMENT14_HIGH,
              x_SEGMENT15_LOW,
              x_SEGMENT15_HIGH,
              x_SEGMENT16_LOW,
              x_SEGMENT16_HIGH,
              x_SEGMENT17_LOW,
              x_SEGMENT17_HIGH,
              x_SEGMENT18_LOW,
              x_SEGMENT18_HIGH,
              x_SEGMENT19_LOW,
              x_SEGMENT19_HIGH,
              x_SEGMENT20_LOW,
              x_SEGMENT20_HIGH,
              x_SEGMENT21_LOW,
              x_SEGMENT21_HIGH,
              x_SEGMENT22_LOW,
              x_SEGMENT22_HIGH,
              x_SEGMENT23_LOW,
              x_SEGMENT23_HIGH,
              x_SEGMENT24_LOW,
              x_SEGMENT24_HIGH,
              x_SEGMENT25_LOW,
              x_SEGMENT25_HIGH,
              x_SEGMENT26_LOW,
              x_SEGMENT26_HIGH,
              x_SEGMENT27_LOW,
              x_SEGMENT27_HIGH,
              x_SEGMENT28_LOW,
              x_SEGMENT28_HIGH,
              x_SEGMENT29_LOW,
              x_SEGMENT29_HIGH,
              x_SEGMENT30_LOW,
              x_SEGMENT30_HIGH,
              x_attribute_category,
              x_attribute1,
              x_attribute2,
              x_attribute3,
              x_attribute4,
              x_attribute5,
              x_attribute6,
              x_attribute7,
              x_attribute8,
              x_attribute9,
              x_attribute10,
              x_attribute11,
              x_attribute12,
              x_attribute13,
              x_attribute14,
              x_attribute15,
              l_org_id
              )
      RETURNING  LOC_ACC_MAP_ID INTO x_LOC_ACC_MAP_ID;
      -- Check if a valid record was created.
      OPEN c;
      FETCH c INTO x_LOC_ACC_MAP_ID;

      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;
END insert_row;


 -------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE update_row (
x_LOC_ACC_MAP_ID                    IN                   NUMBER,
x_LOC_ACC_MAP_HDR_ID                IN                   NUMBER,
x_last_update_date                  IN                   DATE,
x_last_updated_by                   IN                   NUMBER,
x_last_update_login                 IN                   NUMBER,
x_PROPERTY_ID                       IN                   NUMBER,
x_LOCATION_ID                       IN                   NUMBER,
x_ACCOUNT_LOW                       IN                   VARCHAR2,
x_ACCOUNT_HIGH                      IN                   VARCHAR2,
x_EXPENSE_TYPE_CODE                 IN                   VARCHAR2,
x_EFFECTIVE_FROM_DATE               IN                   DATE,
x_EFFECTIVE_TO_DATE                 IN                   DATE,
x_RECOVERABLE_FLAG                  IN                   VARCHAR2,
x_SEGMENT1_LOW                      IN                   VARCHAR2,
x_SEGMENT1_HIGH                     IN                   VARCHAR2,
x_SEGMENT2_LOW                      IN                   VARCHAR2,
x_SEGMENT2_HIGH                     IN                   VARCHAR2,
x_SEGMENT3_LOW                      IN                   VARCHAR2,
x_SEGMENT3_HIGH                     IN                   VARCHAR2,
x_SEGMENT4_LOW                      IN                   VARCHAR2,
x_SEGMENT4_HIGH                     IN                   VARCHAR2,
x_SEGMENT5_LOW                      IN                   VARCHAR2,
x_SEGMENT5_HIGH                     IN                   VARCHAR2,
x_SEGMENT6_LOW                      IN                   VARCHAR2,
x_SEGMENT6_HIGH                     IN                   VARCHAR2,
x_SEGMENT7_LOW                      IN                   VARCHAR2,
x_SEGMENT7_HIGH                     IN                   VARCHAR2,
x_SEGMENT8_LOW                      IN                   VARCHAR2,
x_SEGMENT8_HIGH                     IN                   VARCHAR2,
x_SEGMENT9_LOW                      IN                   VARCHAR2,
x_SEGMENT9_HIGH                     IN                   VARCHAR2,
x_SEGMENT10_LOW                     IN                   VARCHAR2,
x_SEGMENT10_HIGH                    IN                   VARCHAR2,
x_SEGMENT11_LOW                     IN                   VARCHAR2,
x_SEGMENT11_HIGH                    IN                   VARCHAR2,
x_SEGMENT12_LOW                     IN                   VARCHAR2,
x_SEGMENT12_HIGH                    IN                   VARCHAR2,
x_SEGMENT13_LOW                     IN                   VARCHAR2,
x_SEGMENT13_HIGH                    IN                   VARCHAR2,
x_SEGMENT14_LOW                     IN                   VARCHAR2,
x_SEGMENT14_HIGH                    IN                   VARCHAR2,
x_SEGMENT15_LOW                     IN                   VARCHAR2,
x_SEGMENT15_HIGH                    IN                   VARCHAR2,
x_SEGMENT16_LOW                     IN                   VARCHAR2,
x_SEGMENT16_HIGH                    IN                   VARCHAR2,
x_SEGMENT17_LOW                     IN                   VARCHAR2,
x_SEGMENT17_HIGH                    IN                   VARCHAR2,
x_SEGMENT18_LOW                     IN                   VARCHAR2,
x_SEGMENT18_HIGH                    IN                   VARCHAR2,
x_SEGMENT19_LOW                     IN                   VARCHAR2,
x_SEGMENT19_HIGH                    IN                   VARCHAR2,
x_SEGMENT20_LOW                     IN                   VARCHAR2,
x_SEGMENT20_HIGH                    IN                   VARCHAR2,
x_SEGMENT21_LOW                     IN                   VARCHAR2,
x_SEGMENT21_HIGH                    IN                   VARCHAR2,
x_SEGMENT22_LOW                     IN                   VARCHAR2,
x_SEGMENT22_HIGH                    IN                   VARCHAR2,
x_SEGMENT23_LOW                     IN                   VARCHAR2,
x_SEGMENT23_HIGH                    IN                   VARCHAR2,
x_SEGMENT24_LOW                     IN                   VARCHAR2,
x_SEGMENT24_HIGH                    IN                   VARCHAR2,
x_SEGMENT25_LOW                     IN                   VARCHAR2,
x_SEGMENT25_HIGH                    IN                   VARCHAR2,
x_SEGMENT26_LOW                     IN                   VARCHAR2,
x_SEGMENT26_HIGH                    IN                   VARCHAR2,
x_SEGMENT27_LOW                     IN                   VARCHAR2,
x_SEGMENT27_HIGH                    IN                   VARCHAR2,
x_SEGMENT28_LOW                     IN                   VARCHAR2,
x_SEGMENT28_HIGH                    IN                   VARCHAR2,
x_SEGMENT29_LOW                     IN                   VARCHAR2,
x_SEGMENT29_HIGH                    IN                   VARCHAR2,
x_SEGMENT30_LOW                     IN                   VARCHAR2,
x_SEGMENT30_HIGH                    IN                   VARCHAR2,
x_attribute_category                IN                   VARCHAR2,
x_attribute1                        IN                     VARCHAR2,
x_attribute2                        IN                   VARCHAR2,
x_attribute3                        IN                   VARCHAR2,
x_attribute4                        IN                   VARCHAR2,
x_attribute5                        IN                   VARCHAR2,
x_attribute6                        IN                   VARCHAR2,
x_attribute7                        IN                   VARCHAR2,
x_attribute8                        IN                   VARCHAR2,
x_attribute9                        IN                   VARCHAR2,
x_attribute10                       IN                   VARCHAR2,
x_attribute11                       IN                   VARCHAR2,
x_attribute12                       IN                   VARCHAR2,
x_attribute13                       IN                   VARCHAR2,
x_attribute14                       IN                   VARCHAR2,
x_attribute15                       IN                   VARCHAR2
) IS
BEGIN
        UPDATE PN_LOC_ACC_MAP_ALL                                               --sdm_MOAC
        SET last_update_date = x_last_update_date,
            last_updated_by = x_last_updated_by,
            last_update_login = x_last_update_login,
            LOC_ACC_MAP_HDR_ID = x_LOC_ACC_MAP_HDR_ID,
            PROPERTY_ID = x_PROPERTY_ID,
            LOCATION_ID = x_LOCATION_ID,
            ACCOUNT_LOW = x_ACCOUNT_LOW,
            ACCOUNT_HIGH = x_ACCOUNT_HIGH,
            EXPENSE_TYPE_CODE = x_EXPENSE_TYPE_CODE,
            EFFECTIVE_FROM_DATE = x_EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE  = x_EFFECTIVE_TO_DATE,
            RECOVERABLE_FLAG  = x_RECOVERABLE_FLAG,
            SEGMENT1_LOW = x_SEGMENT1_LOW,
            SEGMENT1_HIGH = x_SEGMENT1_HIGH,
            SEGMENT2_LOW = x_SEGMENT2_LOW,
            SEGMENT2_HIGH = x_SEGMENT2_HIGH,
            SEGMENT3_LOW = x_SEGMENT3_LOW,
            SEGMENT3_HIGH = x_SEGMENT3_HIGH,
            SEGMENT4_LOW = x_SEGMENT4_LOW,
            SEGMENT4_HIGH = x_SEGMENT4_HIGH,
            SEGMENT5_LOW = x_SEGMENT5_LOW,
            SEGMENT5_HIGH = x_SEGMENT5_HIGH,
            SEGMENT6_LOW = x_SEGMENT6_LOW,
            SEGMENT6_HIGH = x_SEGMENT6_HIGH,
            SEGMENT7_LOW = x_SEGMENT7_LOW,
            SEGMENT7_HIGH = x_SEGMENT7_HIGH,
            SEGMENT8_LOW = x_SEGMENT8_LOW,
            SEGMENT8_HIGH = x_SEGMENT8_HIGH,
            SEGMENT9_LOW = x_SEGMENT9_LOW,
            SEGMENT9_HIGH = x_SEGMENT9_HIGH,
            SEGMENT10_LOW = x_SEGMENT10_LOW,
            SEGMENT10_HIGH = x_SEGMENT10_HIGH,
            SEGMENT11_LOW = x_SEGMENT11_LOW,
            SEGMENT11_HIGH = x_SEGMENT11_HIGH,
            SEGMENT12_LOW = x_SEGMENT12_LOW,
            SEGMENT12_HIGH = x_SEGMENT12_HIGH,
            SEGMENT13_LOW = x_SEGMENT13_LOW,
            SEGMENT13_HIGH = x_SEGMENT13_HIGH,
            SEGMENT14_LOW = x_SEGMENT14_LOW,
            SEGMENT14_HIGH = x_SEGMENT14_HIGH,
            SEGMENT15_LOW = x_SEGMENT15_LOW,
            SEGMENT15_HIGH = x_SEGMENT15_HIGH,
            SEGMENT16_LOW = x_SEGMENT16_LOW,
            SEGMENT16_HIGH = x_SEGMENT16_HIGH,
            SEGMENT17_LOW = x_SEGMENT17_LOW,
            SEGMENT17_HIGH = x_SEGMENT17_HIGH,
            SEGMENT18_LOW = x_SEGMENT18_LOW,
            SEGMENT18_HIGH = x_SEGMENT18_HIGH,
            SEGMENT19_LOW = x_SEGMENT19_LOW,
            SEGMENT19_HIGH = x_SEGMENT19_HIGH,
            SEGMENT20_LOW = x_SEGMENT20_LOW,
            SEGMENT20_HIGH = x_SEGMENT20_HIGH,
            SEGMENT21_LOW = x_SEGMENT21_LOW,
            SEGMENT21_HIGH = x_SEGMENT21_HIGH,
            SEGMENT22_LOW = x_SEGMENT22_LOW,
            SEGMENT22_HIGH = x_SEGMENT22_HIGH,
            SEGMENT23_LOW = x_SEGMENT23_LOW,
            SEGMENT23_HIGH = x_SEGMENT23_HIGH,
            SEGMENT24_LOW = x_SEGMENT24_LOW,
            SEGMENT24_HIGH = x_SEGMENT24_HIGH,
            SEGMENT25_LOW = x_SEGMENT25_LOW,
            SEGMENT25_HIGH = x_SEGMENT25_HIGH,
            SEGMENT26_LOW = x_SEGMENT26_LOW,
            SEGMENT26_HIGH = x_SEGMENT26_HIGH,
            SEGMENT27_LOW = x_SEGMENT27_LOW,
            SEGMENT27_HIGH = x_SEGMENT27_HIGH,
            SEGMENT28_LOW = x_SEGMENT28_LOW,
            SEGMENT28_HIGH = x_SEGMENT28_HIGH,
            SEGMENT29_LOW = x_SEGMENT29_LOW,
            SEGMENT29_HIGH = x_SEGMENT29_HIGH,
            SEGMENT30_LOW = x_SEGMENT30_LOW,
            SEGMENT30_HIGH = x_SEGMENT30_HIGH,
            attribute1 = x_attribute1,
            attribute2 = x_attribute2,
            attribute3 = x_attribute3,
            attribute4 = x_attribute4,
            attribute5 = x_attribute5,
            attribute6 = x_attribute6,
            attribute7 = x_attribute7,
            attribute8 = x_attribute8,
            attribute9 = x_attribute9,
            attribute10 = x_attribute10,
            attribute11 = x_attribute11,
            attribute12 = x_attribute12,
            attribute13 = x_attribute13,
            attribute14 = x_attribute14,
            attribute15 = x_attribute15
        WHERE LOC_ACC_MAP_ID = x_LOC_ACC_MAP_ID;
        IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
        END IF;
END update_row;


 -------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE lock_row (
x_LOC_ACC_MAP_ID                    IN                   NUMBER,
x_LOC_ACC_MAP_HDR_ID                IN                   NUMBER,
x_PROPERTY_ID                       IN                   NUMBER,
x_LOCATION_ID                       IN                   NUMBER,
x_ACCOUNT_LOW                       IN                   VARCHAR2,
x_ACCOUNT_HIGH                      IN                   VARCHAR2,
x_EXPENSE_TYPE_CODE                 IN                   VARCHAR2,
x_EFFECTIVE_FROM_DATE               IN                   DATE,
x_EFFECTIVE_TO_DATE                 IN                   DATE,
x_RECOVERABLE_FLAG                  IN                   VARCHAR2,
x_SEGMENT1_LOW                      IN                   VARCHAR2,
x_SEGMENT1_HIGH                     IN                   VARCHAR2,
x_SEGMENT2_LOW                      IN                   VARCHAR2,
x_SEGMENT2_HIGH                     IN                   VARCHAR2,
x_SEGMENT3_LOW                      IN                   VARCHAR2,
x_SEGMENT3_HIGH                     IN                   VARCHAR2,
x_SEGMENT4_LOW                      IN                   VARCHAR2,
x_SEGMENT4_HIGH                     IN                   VARCHAR2,
x_SEGMENT5_LOW                      IN                   VARCHAR2,
x_SEGMENT5_HIGH                     IN                   VARCHAR2,
x_SEGMENT6_LOW                      IN                   VARCHAR2,
x_SEGMENT6_HIGH                     IN                   VARCHAR2,
x_SEGMENT7_LOW                      IN                   VARCHAR2,
x_SEGMENT7_HIGH                     IN                   VARCHAR2,
x_SEGMENT8_LOW                      IN                   VARCHAR2,
x_SEGMENT8_HIGH                     IN                   VARCHAR2,
x_SEGMENT9_LOW                      IN                   VARCHAR2,
x_SEGMENT9_HIGH                     IN                   VARCHAR2,
x_SEGMENT10_LOW                     IN                   VARCHAR2,
x_SEGMENT10_HIGH                    IN                   VARCHAR2,
x_SEGMENT11_LOW                     IN                   VARCHAR2,
x_SEGMENT11_HIGH                    IN                   VARCHAR2,
x_SEGMENT12_LOW                     IN                   VARCHAR2,
x_SEGMENT12_HIGH                    IN                   VARCHAR2,
x_SEGMENT13_LOW                     IN                   VARCHAR2,
x_SEGMENT13_HIGH                    IN                   VARCHAR2,
x_SEGMENT14_LOW                     IN                   VARCHAR2,
x_SEGMENT14_HIGH                    IN                   VARCHAR2,
x_SEGMENT15_LOW                     IN                   VARCHAR2,
x_SEGMENT15_HIGH                    IN                   VARCHAR2,
x_SEGMENT16_LOW                     IN                   VARCHAR2,
x_SEGMENT16_HIGH                    IN                   VARCHAR2,
x_SEGMENT17_LOW                     IN                   VARCHAR2,
x_SEGMENT17_HIGH                    IN                   VARCHAR2,
x_SEGMENT18_LOW                     IN                   VARCHAR2,
x_SEGMENT18_HIGH                    IN                   VARCHAR2,
x_SEGMENT19_LOW                     IN                   VARCHAR2,
x_SEGMENT19_HIGH                    IN                   VARCHAR2,
x_SEGMENT20_LOW                     IN                   VARCHAR2,
x_SEGMENT20_HIGH                    IN                   VARCHAR2,
x_SEGMENT21_LOW                     IN                   VARCHAR2,
x_SEGMENT21_HIGH                    IN                   VARCHAR2,
x_SEGMENT22_LOW                     IN                   VARCHAR2,
x_SEGMENT22_HIGH                    IN                   VARCHAR2,
x_SEGMENT23_LOW                     IN                   VARCHAR2,
x_SEGMENT23_HIGH                    IN                   VARCHAR2,
x_SEGMENT24_LOW                     IN                   VARCHAR2,
x_SEGMENT24_HIGH                    IN                   VARCHAR2,
x_SEGMENT25_LOW                     IN                   VARCHAR2,
x_SEGMENT25_HIGH                    IN                   VARCHAR2,
x_SEGMENT26_LOW                     IN                   VARCHAR2,
x_SEGMENT26_HIGH                    IN                   VARCHAR2,
x_SEGMENT27_LOW                     IN                   VARCHAR2,
x_SEGMENT27_HIGH                    IN                   VARCHAR2,
x_SEGMENT28_LOW                     IN                   VARCHAR2,
x_SEGMENT28_HIGH                    IN                   VARCHAR2,
x_SEGMENT29_LOW                     IN                   VARCHAR2,
x_SEGMENT29_HIGH                    IN                   VARCHAR2,
x_SEGMENT30_LOW                     IN                   VARCHAR2,
x_SEGMENT30_HIGH                    IN                   VARCHAR2,
x_attribute_category                IN                   VARCHAR2,
x_attribute1                        IN                   VARCHAR2,
x_attribute2                        IN                   VARCHAR2,
x_attribute3                        IN                   VARCHAR2,
x_attribute4                        IN                   VARCHAR2,
x_attribute5                        IN                   VARCHAR2,
x_attribute6                        IN                   VARCHAR2,
x_attribute7                        IN                   VARCHAR2,
x_attribute8                        IN                   VARCHAR2,
x_attribute9                        IN                   VARCHAR2,
x_attribute10                       IN                   VARCHAR2,
x_attribute11                       IN                   VARCHAR2,
x_attribute12                       IN                   VARCHAR2,
x_attribute13                       IN                   VARCHAR2,
x_attribute14                       IN                   VARCHAR2,
x_attribute15                       IN                   VARCHAR2
) IS
  CURSOR c1 IS
         SELECT    *
         FROM PN_LOC_ACC_MAP_ALL
         WHERE LOC_ACC_MAP_ID = x_LOC_ACC_MAP_ID
         FOR UPDATE OF LOC_ACC_MAP_ID NOWAIT;

  tlinfo   c1%ROWTYPE;

BEGIN
        OPEN c1;
      FETCH c1 INTO tlinfo;

      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;

      CLOSE c1;
         IF NOT (tlinfo.LOC_ACC_MAP_ID = x_loc_acc_map_id) THEN
         pn_var_rent_pkg.lock_row_exception('lOC_ACC_MAP_ID',tlinfo.loc_acc_map_id);
         END IF;

         IF NOT (tlinfo.LOC_ACC_MAP_HDR_ID = x_LOC_ACC_MAP_HDR_ID ) THEN
         pn_var_rent_pkg.lock_row_exception('LOC_ACC_MAP_HDR_ID',tlinfo.LOC_ACC_MAP_HDR_ID);
         END IF;

         IF NOT ((tlinfo.PROPERTY_ID = x_PROPERTY_ID)
                  OR ((tlinfo.PROPERTY_ID IS NULL) AND (x_PROPERTY_ID IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('PROPERTY_ID',tlinfo.PROPERTY_ID);
         END IF;

         IF NOT ((tlinfo.LOCATION_ID = x_LOCATION_ID)
                  OR ((tlinfo.LOCATION_ID IS NULL) AND (x_LOCATION_ID IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlinfo.LOCATION_ID);
         END IF;

         IF NOT (tlinfo.ACCOUNT_LOW = x_ACCOUNT_LOW) THEN
         pn_var_rent_pkg.lock_row_exception('ACCOUNT_LOW',tlinfo.ACCOUNT_LOW);
         END IF;

         IF NOT (tlinfo.ACCOUNT_HIGH = x_ACCOUNT_HIGH) THEN
         pn_var_rent_pkg.lock_row_exception('ACCOUNT_HIGH',tlinfo.ACCOUNT_HIGH);
         END IF;

         IF NOT (tlinfo.EXPENSE_TYPE_CODE = x_EXPENSE_TYPE_CODE) THEN
         pn_var_rent_pkg.lock_row_exception('EXPENSE_TYPE_CODE',tlinfo.EXPENSE_TYPE_CODE);
         END IF;

         IF NOT (tlinfo.EFFECTIVE_FROM_DATE = x_EFFECTIVE_FROM_DATE) THEN
         pn_var_rent_pkg.lock_row_exception('EFFECTIVE_FROM_DATE',tlinfo.EFFECTIVE_FROM_DATE);
         END IF;

         IF NOT (tlinfo.EFFECTIVE_TO_DATE = x_EFFECTIVE_TO_DATE) THEN
         pn_var_rent_pkg.lock_row_exception('EFFECTIVE_TO_DATE',tlinfo.EFFECTIVE_TO_DATE);
         END IF;

         IF NOT ((tlinfo.RECOVERABLE_FLAG  = x_RECOVERABLE_FLAG )
                  OR ((tlinfo.RECOVERABLE_FLAG  IS NULL) AND (x_RECOVERABLE_FLAG IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('RECOVERABLE_FLAG',tlinfo.RECOVERABLE_FLAG);
         END IF;

         IF NOT ((tlinfo.SEGMENT1_LOW = x_SEGMENT1_LOW )
                  OR ((tlinfo.SEGMENT1_LOW IS NULL) AND (x_SEGMENT1_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT1_LOW',tlinfo.SEGMENT1_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT1_HIGH = x_SEGMENT1_HIGH )
                  OR ((tlinfo.SEGMENT1_HIGH IS NULL) AND (x_SEGMENT1_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT1_HIGH',tlinfo.SEGMENT1_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT2_LOW = x_SEGMENT2_LOW )
                  OR ((tlinfo.SEGMENT2_LOW IS NULL) AND (x_SEGMENT2_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT2_LOW',tlinfo.SEGMENT2_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT2_HIGH = x_SEGMENT2_HIGH )
                  OR ((tlinfo.SEGMENT2_HIGH IS NULL) AND (x_SEGMENT2_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT2_HIGH',tlinfo.SEGMENT2_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT3_LOW = x_SEGMENT3_LOW )
                  OR ((tlinfo.SEGMENT3_LOW IS NULL) AND (x_SEGMENT3_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT3_LOW',tlinfo.SEGMENT3_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT3_HIGH = x_SEGMENT3_HIGH )
                  OR ((tlinfo.SEGMENT3_HIGH IS NULL) AND (x_SEGMENT3_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT3_HIGH',tlinfo.SEGMENT3_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT4_LOW = x_SEGMENT4_LOW )
                  OR ((tlinfo.SEGMENT4_LOW IS NULL) AND (x_SEGMENT4_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT4_LOW',tlinfo.SEGMENT4_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT4_HIGH = x_SEGMENT4_HIGH )
                  OR ((tlinfo.SEGMENT4_HIGH IS NULL) AND (x_SEGMENT4_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT4_HIGH',tlinfo.SEGMENT4_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT5_LOW = x_SEGMENT5_LOW )
                  OR ((tlinfo.SEGMENT5_LOW IS NULL) AND (x_SEGMENT5_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT5_LOW',tlinfo.SEGMENT5_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT5_HIGH = x_SEGMENT5_HIGH )
                  OR ((tlinfo.SEGMENT5_HIGH IS NULL) AND (x_SEGMENT5_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT5_HIGH',tlinfo.SEGMENT5_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT6_LOW = x_SEGMENT6_LOW )
                  OR ((tlinfo.SEGMENT6_LOW IS NULL) AND (x_SEGMENT6_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT6_LOW',tlinfo.SEGMENT6_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT6_HIGH = x_SEGMENT6_HIGH )
                  OR ((tlinfo.SEGMENT6_HIGH IS NULL) AND (x_SEGMENT6_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT6_HIGH',tlinfo.SEGMENT6_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT7_LOW = x_SEGMENT7_LOW )
                  OR ((tlinfo.SEGMENT7_LOW IS NULL) AND (x_SEGMENT7_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT7_LOW',tlinfo.SEGMENT7_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT7_HIGH = x_SEGMENT7_HIGH )
                  OR ((tlinfo.SEGMENT7_HIGH IS NULL) AND (x_SEGMENT7_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT7_HIGH',tlinfo.SEGMENT7_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT8_LOW = x_SEGMENT8_LOW )
                  OR ((tlinfo.SEGMENT8_LOW IS NULL) AND (x_SEGMENT8_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT8_LOW',tlinfo.SEGMENT8_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT8_HIGH = x_SEGMENT8_HIGH )
                  OR ((tlinfo.SEGMENT8_HIGH IS NULL) AND (x_SEGMENT8_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT8_HIGH',tlinfo.SEGMENT8_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT9_LOW = x_SEGMENT9_LOW )
                  OR ((tlinfo.SEGMENT9_LOW IS NULL) AND (x_SEGMENT9_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT9_LOW',tlinfo.SEGMENT9_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT9_HIGH = x_SEGMENT9_HIGH )
                  OR ((tlinfo.SEGMENT9_HIGH IS NULL) AND (x_SEGMENT9_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT9_HIGH',tlinfo.SEGMENT9_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT10_LOW = x_SEGMENT10_LOW )
                  OR ((tlinfo.SEGMENT10_LOW IS NULL) AND (x_SEGMENT10_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT10_LOW',tlinfo.SEGMENT10_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT10_HIGH = x_SEGMENT10_HIGH )
                  OR ((tlinfo.SEGMENT10_HIGH IS NULL) AND (x_SEGMENT10_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT10_HIGH',tlinfo.SEGMENT10_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT11_LOW = x_SEGMENT11_LOW )
                  OR ((tlinfo.SEGMENT11_LOW IS NULL) AND (x_SEGMENT11_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT11_LOW',tlinfo.SEGMENT11_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT11_HIGH = x_SEGMENT11_HIGH )
                  OR ((tlinfo.SEGMENT11_HIGH IS NULL) AND (x_SEGMENT11_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT11_HIGH',tlinfo.SEGMENT11_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT12_LOW = x_SEGMENT12_LOW )
                  OR ((tlinfo.SEGMENT12_LOW IS NULL) AND (x_SEGMENT12_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT12_LOW',tlinfo.SEGMENT12_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT12_HIGH = x_SEGMENT12_HIGH )
                  OR ((tlinfo.SEGMENT12_HIGH IS NULL) AND (x_SEGMENT12_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT12_HIGH',tlinfo.SEGMENT12_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT13_LOW = x_SEGMENT13_LOW )
                  OR ((tlinfo.SEGMENT13_LOW IS NULL) AND (x_SEGMENT13_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT13_LOW',tlinfo.SEGMENT13_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT13_HIGH = x_SEGMENT13_HIGH )
                  OR ((tlinfo.SEGMENT13_HIGH IS NULL) AND (x_SEGMENT13_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT13_HIGH',tlinfo.SEGMENT13_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT14_LOW = x_SEGMENT14_LOW )
                  OR ((tlinfo.SEGMENT14_LOW IS NULL) AND (x_SEGMENT14_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT14_LOW',tlinfo.SEGMENT14_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT14_HIGH = x_SEGMENT14_HIGH )
                  OR ((tlinfo.SEGMENT14_HIGH IS NULL) AND (x_SEGMENT14_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT14_HIGH',tlinfo.SEGMENT14_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT15_LOW = x_SEGMENT15_LOW )
                  OR ((tlinfo.SEGMENT15_LOW IS NULL) AND (x_SEGMENT15_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT15_LOW',tlinfo.SEGMENT15_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT15_HIGH = x_SEGMENT15_HIGH )
                  OR ((tlinfo.SEGMENT15_HIGH IS NULL) AND (x_SEGMENT15_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT15_HIGH',tlinfo.SEGMENT15_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT16_LOW = x_SEGMENT16_LOW )
                  OR ((tlinfo.SEGMENT16_LOW IS NULL) AND (x_SEGMENT16_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT16_LOW',tlinfo.SEGMENT16_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT16_HIGH = x_SEGMENT16_HIGH )
                  OR ((tlinfo.SEGMENT16_HIGH IS NULL) AND (x_SEGMENT16_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT16_HIGH',tlinfo.SEGMENT16_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT17_LOW = x_SEGMENT17_LOW )
                  OR ((tlinfo.SEGMENT17_LOW IS NULL) AND (x_SEGMENT17_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT17_LOW',tlinfo.SEGMENT17_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT17_HIGH = x_SEGMENT17_HIGH )
                  OR ((tlinfo.SEGMENT17_HIGH IS NULL) AND (x_SEGMENT17_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT17_HIGH',tlinfo.SEGMENT17_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT18_LOW = x_SEGMENT18_LOW )
                  OR ((tlinfo.SEGMENT18_LOW IS NULL) AND (x_SEGMENT18_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT18_LOW',tlinfo.SEGMENT18_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT18_HIGH = x_SEGMENT18_HIGH )
                  OR ((tlinfo.SEGMENT18_HIGH IS NULL) AND (x_SEGMENT18_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT18_HIGH',tlinfo.SEGMENT18_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT19_LOW = x_SEGMENT19_LOW )
                  OR ((tlinfo.SEGMENT19_LOW IS NULL) AND (x_SEGMENT19_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT19_LOW',tlinfo.SEGMENT19_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT19_HIGH = x_SEGMENT19_HIGH )
                  OR ((tlinfo.SEGMENT19_HIGH IS NULL) AND (x_SEGMENT19_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT19_HIGH',tlinfo.SEGMENT19_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT20_LOW = x_SEGMENT20_LOW )
                  OR ((tlinfo.SEGMENT20_LOW IS NULL) AND (x_SEGMENT20_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT20_LOW',tlinfo.SEGMENT20_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT20_HIGH = x_SEGMENT20_HIGH )
                  OR ((tlinfo.SEGMENT20_HIGH IS NULL) AND (x_SEGMENT20_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT20_HIGH',tlinfo.SEGMENT20_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT21_LOW = x_SEGMENT21_LOW )
                  OR ((tlinfo.SEGMENT21_LOW IS NULL) AND (x_SEGMENT21_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT21_LOW',tlinfo.SEGMENT21_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT21_HIGH = x_SEGMENT21_HIGH )
                  OR ((tlinfo.SEGMENT21_HIGH IS NULL) AND (x_SEGMENT21_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT21_HIGH',tlinfo.SEGMENT21_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT22_LOW = x_SEGMENT22_LOW )
                  OR ((tlinfo.SEGMENT22_LOW IS NULL) AND (x_SEGMENT22_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT22_LOW',tlinfo.SEGMENT22_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT22_HIGH = x_SEGMENT22_HIGH )
                  OR ((tlinfo.SEGMENT22_HIGH IS NULL) AND (x_SEGMENT22_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT22_HIGH',tlinfo.SEGMENT22_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT23_LOW = x_SEGMENT23_LOW )
                  OR ((tlinfo.SEGMENT23_LOW IS NULL) AND (x_SEGMENT23_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT23_LOW',tlinfo.SEGMENT23_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT23_HIGH = x_SEGMENT23_HIGH )
                  OR ((tlinfo.SEGMENT23_HIGH IS NULL) AND (x_SEGMENT23_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT23_HIGH',tlinfo.SEGMENT23_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT24_LOW = x_SEGMENT24_LOW )
                  OR ((tlinfo.SEGMENT24_LOW IS NULL) AND (x_SEGMENT24_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT24_LOW',tlinfo.SEGMENT24_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT24_HIGH = x_SEGMENT24_HIGH )
                  OR ((tlinfo.SEGMENT24_HIGH IS NULL) AND (x_SEGMENT24_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT24_HIGH',tlinfo.SEGMENT24_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT25_LOW = x_SEGMENT25_LOW )
                  OR ((tlinfo.SEGMENT25_LOW IS NULL) AND (x_SEGMENT25_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT25_LOW',tlinfo.SEGMENT25_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT25_HIGH = x_SEGMENT25_HIGH )
                  OR ((tlinfo.SEGMENT25_HIGH IS NULL) AND (x_SEGMENT25_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT25_HIGH',tlinfo.SEGMENT25_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT26_LOW = x_SEGMENT26_LOW )
                  OR ((tlinfo.SEGMENT26_LOW IS NULL) AND (x_SEGMENT26_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT26_LOW',tlinfo.SEGMENT26_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT26_HIGH = x_SEGMENT26_HIGH )
                  OR ((tlinfo.SEGMENT26_HIGH IS NULL) AND (x_SEGMENT26_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT26_HIGH',tlinfo.SEGMENT26_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT27_LOW = x_SEGMENT27_LOW )
                  OR ((tlinfo.SEGMENT27_LOW IS NULL) AND (x_SEGMENT27_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT27_LOW',tlinfo.SEGMENT27_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT27_HIGH = x_SEGMENT27_HIGH )
                  OR ((tlinfo.SEGMENT27_HIGH IS NULL) AND (x_SEGMENT27_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT27_HIGH',tlinfo.SEGMENT27_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT28_LOW = x_SEGMENT28_LOW )
                  OR ((tlinfo.SEGMENT28_LOW IS NULL) AND (x_SEGMENT28_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT28_LOW',tlinfo.SEGMENT28_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT28_HIGH = x_SEGMENT28_HIGH )
                  OR ((tlinfo.SEGMENT28_HIGH IS NULL) AND (x_SEGMENT28_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT28_HIGH',tlinfo.SEGMENT28_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT29_LOW = x_SEGMENT29_LOW )
                  OR ((tlinfo.SEGMENT29_LOW IS NULL) AND (x_SEGMENT29_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT29_LOW',tlinfo.SEGMENT29_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT29_HIGH = x_SEGMENT29_HIGH )
                  OR ((tlinfo.SEGMENT29_HIGH IS NULL) AND (x_SEGMENT29_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT29_HIGH',tlinfo.SEGMENT29_HIGH);
         END IF;

         IF NOT ((tlinfo.SEGMENT30_LOW = x_SEGMENT30_LOW )
                  OR ((tlinfo.SEGMENT30_LOW IS NULL) AND (x_SEGMENT30_LOW IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT30_LOW',tlinfo.SEGMENT30_LOW);
         END IF;

         IF NOT ((tlinfo.SEGMENT30_HIGH = x_SEGMENT30_HIGH )
                  OR ((tlinfo.SEGMENT30_HIGH IS NULL) AND (x_SEGMENT30_HIGH IS NULL))) THEN
         pn_var_rent_pkg.lock_row_exception('SEGMENT30_HIGH',tlinfo.SEGMENT30_HIGH);
         END IF;

         IF NOT  ((tlinfo.attribute_category = x_attribute_category)
                  OR ((tlinfo.attribute_category is null) AND (x_attribute_category is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute_category',tlinfo.attribute_category);
         END IF;

         IF NOT ((tlinfo.attribute1 = x_attribute1)
                  OR ((tlinfo.attribute1 is null) AND (x_attribute1 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute1',tlinfo.attribute1);
         END IF;

         IF NOT ((tlinfo.attribute2 = x_attribute2)
                  OR ((tlinfo.attribute2 is null) AND (x_attribute2 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute2',tlinfo.attribute2);
         END IF;

         IF NOT ((tlinfo.attribute3 = x_attribute3)
                  OR ((tlinfo.attribute3 is null) AND (x_attribute3 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute3',tlinfo.attribute3);
         END IF;

         IF NOT ((tlinfo.attribute4 = x_attribute4)
                  OR ((tlinfo.attribute4 is null) AND (x_attribute4 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute4',tlinfo.attribute4);
         END IF;

         IF NOT ((tlinfo.attribute5 = x_attribute5)
                  OR ((tlinfo.attribute5 is null) AND (x_attribute5 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute5',tlinfo.attribute5);
         END IF;

         IF NOT ((tlinfo.attribute6 = x_attribute6)
                  OR ((tlinfo.attribute6 is null) AND (x_attribute6 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute6',tlinfo.attribute6);
         END IF;

         IF NOT ((tlinfo.attribute7 = x_attribute7)
                  OR ((tlinfo.attribute7 is null) AND (x_attribute7 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute7',tlinfo.attribute7);
         END IF;

         IF NOT ((tlinfo.attribute8 = x_attribute8)
                  OR ((tlinfo.attribute8 is null) AND (x_attribute8 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute8',tlinfo.attribute8);
         END IF;

         IF NOT ((tlinfo.attribute9 = x_attribute9)
                  OR ((tlinfo.attribute9 is null) AND (x_attribute9 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute9',tlinfo.attribute9);
         END IF;

         IF NOT ((tlinfo.attribute10 = x_attribute10)
                  OR ((tlinfo.attribute10 is null) AND (x_attribute10 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute10',tlinfo.attribute10);
         END IF;

         IF NOT ((tlinfo.attribute11 = x_attribute11)
                  OR ((tlinfo.attribute11 is null) AND (x_attribute11 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute11',tlinfo.attribute11);
         END IF;

         IF NOT ((tlinfo.attribute12 = x_attribute12)
                  OR ((tlinfo.attribute12 is null) AND (x_attribute12 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute12',tlinfo.attribute12);
         END IF;

         IF NOT ((tlinfo.attribute13 = x_attribute13)
                  OR ((tlinfo.attribute13 is null) AND (x_attribute13 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute13',tlinfo.attribute13);
         END IF;

         IF NOT ((tlinfo.attribute14 = x_attribute14)
                  OR ((tlinfo.attribute14 is null) AND (x_attribute14 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute14',tlinfo.attribute14);
         END IF;

         IF NOT ((tlinfo.attribute15 = x_attribute15)
                  OR ((tlinfo.attribute15 is null) AND (x_attribute15 is null))) THEN
         pn_var_rent_pkg.lock_row_exception('attribute15',tlinfo.attribute15);
         END IF;

END lock_row;

 -------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row (
        x_LOC_ACC_MAP_ID           IN    NUMBER
) IS
BEGIN
      DELETE FROM PN_LOC_ACC_MAP_ALL                                            --sdm_MOAC
      WHERE  LOC_ACC_MAP_ID = x_LOC_ACC_MAP_ID;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;
END delete_row;


END PN_LOC_ACC_MAP_PKG;

/
