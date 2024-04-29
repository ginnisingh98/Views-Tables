--------------------------------------------------------
--  DDL for Package Body PN_LOC_ACC_MAP_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LOC_ACC_MAP_HDR_PKG" AS
  --$Header: PNACCMPB.pls 120.1 2005/07/25 05:15:54 appldev noship $

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP_HDR with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE insert_row (
x_LOC_ACC_MAP_HDR_ID        IN OUT NOCOPY  NUMBER,
x_MAPPING_NAME              IN             VARCHAR2,
x_last_update_date          IN             DATE,
x_last_updated_by           IN             NUMBER,
x_creation_date             IN             DATE,
x_created_by                IN             NUMBER,
x_last_update_login         IN             NUMBER,
x_attribute_category        IN             VARCHAR2,
x_attribute1                IN             VARCHAR2,
x_attribute2                IN             VARCHAR2,
x_attribute3                IN             VARCHAR2,
x_attribute4                IN             VARCHAR2,
x_attribute5                IN             VARCHAR2,
x_attribute6                IN             VARCHAR2,
x_attribute7                IN             VARCHAR2,
x_attribute8                IN             VARCHAR2,
x_attribute9                IN             VARCHAR2,
x_attribute10               IN             VARCHAR2,
x_attribute11               IN             VARCHAR2,
x_attribute12               IN             VARCHAR2,
x_attribute13               IN             VARCHAR2,
x_attribute14               IN             VARCHAR2,
x_attribute15               IN             VARCHAR2,
x_ORG_ID                    IN             NUMBER  default NULL
) IS
      CURSOR C IS
      SELECT LOC_ACC_MAP_HDR_ID
      FROM PN_LOC_ACC_MAP_HDR_ALL                                       --sdm_MOAC
      WHERE LOC_ACC_MAP_HDR_ID = x_LOC_ACC_MAP_HDR_ID;
BEGIN

  INSERT INTO PN_LOC_ACC_MAP_HDR_ALL                                    --sdm_MOAC
  (LOC_ACC_MAP_HDR_ID,
       MAPPING_NAME,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
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
  VALUES (NVL(x_LOC_ACC_MAP_HDR_ID,PN_LOC_ACC_MAP_HDR_S.NEXTVAL),
      x_MAPPING_NAME,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login,
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
      x_org_id
      )
  RETURNING  LOC_ACC_MAP_HDR_ID INTO x_LOC_ACC_MAP_HDR_ID;
  -- Check if a valid record was created.
      OPEN c;
      FETCH c INTO x_LOC_ACC_MAP_HDR_ID;

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
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP_HDR with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE update_row (
x_LOC_ACC_MAP_HDR_ID        IN             NUMBER,
x_MAPPING_NAME              IN             VARCHAR2,
x_last_update_date          IN             DATE,
x_last_updated_by           IN             NUMBER,
x_last_update_login         IN             NUMBER,
x_attribute_category        IN             VARCHAR2,
x_attribute1                IN             VARCHAR2,
x_attribute2                IN             VARCHAR2,
x_attribute3                IN             VARCHAR2,
x_attribute4                IN             VARCHAR2,
x_attribute5                IN             VARCHAR2,
x_attribute6                IN             VARCHAR2,
x_attribute7                IN             VARCHAR2,
x_attribute8                IN             VARCHAR2,
x_attribute9                IN             VARCHAR2,
x_attribute10               IN             VARCHAR2,
x_attribute11               IN             VARCHAR2,
x_attribute12               IN             VARCHAR2,
x_attribute13               IN             VARCHAR2,
x_attribute14               IN             VARCHAR2,
x_attribute15               IN             VARCHAR2
) IS
BEGIN
  UPDATE PN_LOC_ACC_MAP_HDR_ALL                                 --sdm_MOAC
  SET   last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    MAPPING_NAME = x_MAPPING_NAME,
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
  WHERE LOC_ACC_MAP_HDR_ID = x_LOC_ACC_MAP_HDR_ID;
  IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;
END update_row;


-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP_HDR with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE lock_row (
x_LOC_ACC_MAP_HDR_ID        IN             NUMBER,
x_MAPPING_NAME              IN             VARCHAR2,
x_attribute_category        IN             VARCHAR2,
x_attribute1                IN             VARCHAR2,
x_attribute2                IN             VARCHAR2,
x_attribute3                IN             VARCHAR2,
x_attribute4                IN             VARCHAR2,
x_attribute5                IN             VARCHAR2,
x_attribute6                IN             VARCHAR2,
x_attribute7                IN             VARCHAR2,
x_attribute8                IN             VARCHAR2,
x_attribute9                IN             VARCHAR2,
x_attribute10               IN             VARCHAR2,
x_attribute11               IN             VARCHAR2,
x_attribute12               IN             VARCHAR2,
x_attribute13               IN             VARCHAR2,
x_attribute14               IN             VARCHAR2,
x_attribute15               IN             VARCHAR2
) IS
  CURSOR c1 IS
         SELECT    *
         FROM PN_LOC_ACC_MAP_HDR_ALL                                    --sdm_MOAC
         WHERE LOC_ACC_MAP_HDR_ID = x_LOC_ACC_MAP_HDR_ID
         FOR UPDATE OF LOC_ACC_MAP_HDR_ID NOWAIT;

  tlinfo   c1%ROWTYPE;

BEGIN
  OPEN c1;
    FETCH c1 INTO tlinfo;
     IF (c1%NOTFOUND) THEN
       CLOSE c1;
       RETURN;
     END IF;
  CLOSE c1;

     IF NOT (tlinfo.loc_acc_map_hdr_id =  x_loc_acc_map_hdr_id) THEN
        pn_var_rent_pkg.lock_row_exception('loc_acc_map_hdr_id',tlinfo.loc_acc_map_hdr_id);
     END IF;
     IF NOT (tlinfo.mapping_name =  x_mapping_name) THEN
        pn_var_rent_pkg.lock_row_exception('mapping_name',tlinfo.mapping_name);
     END IF;
     IF NOT (   (tlinfo.attribute_category =  x_Attribute_Category)
          or ((tlinfo.attribute_category IS null) and (x_Attribute_Category IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute_category',tlinfo.attribute_category);
     END IF;
     IF NOT (   (tlinfo.attribute1 =  x_Attribute1)
          or ((tlinfo.attribute1 IS null) and (x_Attribute1 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute1',tlinfo.attribute1);
     END IF;
     IF NOT (   (tlinfo.attribute2 =  x_Attribute2)
          or ((tlinfo.attribute2 IS null) and (x_Attribute2 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute2',tlinfo.attribute2);
     END IF;
     IF NOT (   (tlinfo.attribute3 =  x_Attribute3)
          or ((tlinfo.attribute3 IS null) and (x_Attribute3 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute3',tlinfo.attribute3);
     END IF;
     IF NOT (   (tlinfo.attribute4 =  x_Attribute4)
          or ((tlinfo.attribute4 IS null) and (x_Attribute4 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute4',tlinfo.attribute4);
     END IF;
     IF NOT (   (tlinfo.attribute5 =  x_Attribute5)
          or ((tlinfo.attribute5 IS null) and (x_Attribute5 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute5',tlinfo.attribute5);
     END IF;
     IF NOT (   (tlinfo.attribute6 =  x_Attribute6)
          or ((tlinfo.attribute6 IS null) and (x_Attribute6 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute6',tlinfo.attribute6);
     END IF;
     IF NOT (   (tlinfo.attribute7 =  x_Attribute7)
          or ((tlinfo.attribute7 IS null) and (x_Attribute7 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute7',tlinfo.attribute7);
     END IF;
     IF NOT (   (tlinfo.attribute8 =  x_Attribute8)
          or ((tlinfo.attribute8 IS null) and (x_Attribute8 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute8',tlinfo.attribute8);
     END IF;
     IF NOT (   (tlinfo.attribute9 =  x_Attribute9)
          or ((tlinfo.attribute9 IS null) and (x_Attribute9 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute9',tlinfo.attribute9);
     END IF;
     IF NOT (   (tlinfo.attribute10 =  x_Attribute10)
          or ((tlinfo.attribute10 IS null) and (x_Attribute10 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute10',tlinfo.attribute10);
     END IF;
     IF NOT (   (tlinfo.attribute11 =  x_Attribute11)
          or ((tlinfo.attribute11 IS null) and (x_Attribute11 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute11',tlinfo.attribute11);
     END IF;
     IF NOT (   (tlinfo.attribute12 =  x_Attribute12)
          or ((tlinfo.attribute12 IS null) and (x_Attribute12 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute12',tlinfo.attribute12);
     END IF;
     IF NOT (   (tlinfo.attribute13 =  x_Attribute13)
          or ((tlinfo.attribute13 IS null) and (x_Attribute13 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute13',tlinfo.attribute13);
     END IF;
     IF NOT (   (tlinfo.attribute14 =  x_Attribute14)
          or ((tlinfo.attribute14 IS null) and (x_Attribute14 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute14',tlinfo.attribute14);
     END IF;
     IF NOT (   (tlinfo.attribute15 =  x_Attribute15)
          or ((tlinfo.attribute15 IS null) and (x_Attribute15 IS null))) THEN
        pn_var_rent_pkg.lock_row_exception('attribute15',tlinfo.attribute15);
     END IF;

END lock_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced PN_LOC_ACC_MAP_HDR with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row (
  x_LOC_ACC_MAP_HDR_ID     IN    NUMBER
) IS
BEGIN
  DELETE FROM PN_LOC_ACC_MAP_HDR_ALL                                    --sdm_MOAC
            WHERE LOC_ACC_MAP_HDR_ID = x_LOC_ACC_MAP_HDR_ID;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;
END delete_row;


END PN_LOC_ACC_MAP_HDR_PKG;

/
