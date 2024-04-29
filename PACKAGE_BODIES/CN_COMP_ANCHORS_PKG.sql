--------------------------------------------------------
--  DDL for Package Body CN_COMP_ANCHORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_ANCHORS_PKG" as
/* $Header: cntancb.pls 115.4 2002/11/21 21:08:59 hlchen ship $ */

procedure INSERT_ROW
  (X_ROWID              IN OUT NOCOPY VARCHAR2,
   X_COMP_ANCHOR_ID     IN OUT NOCOPY NUMBER,
   X_ROLE_QUOTA_CATE_ID IN     NUMBER,
   X_QUOTA_CATEGORY_ID  IN     NUMBER,
   X_ATTAINMENT         IN     NUMBER,
   X_TYPE               IN     VARCHAR2,
   X_COMMISSION         IN     NUMBER,
   X_ATTRIBUTE_CATEGORY IN     VARCHAR2,
   X_ATTRIBUTE1         IN     VARCHAR2,
   X_ATTRIBUTE2         IN     VARCHAR2,
   X_ATTRIBUTE3         IN     VARCHAR2,
   X_ATTRIBUTE4         IN     VARCHAR2,
   X_ATTRIBUTE5         IN     VARCHAR2,
   X_ATTRIBUTE6         IN     VARCHAR2,
   X_ATTRIBUTE7         IN     VARCHAR2,
   X_ATTRIBUTE8         IN     VARCHAR2,
   X_ATTRIBUTE9         IN     VARCHAR2,
   X_ATTRIBUTE10        IN     VARCHAR2,
   X_ATTRIBUTE11        IN     VARCHAR2,
   X_ATTRIBUTE12        IN     VARCHAR2,
   X_ATTRIBUTE13        IN     VARCHAR2,
   X_ATTRIBUTE14        IN     VARCHAR2,
   X_ATTRIBUTE15        IN     VARCHAR2,
   X_CREATION_DATE      IN     DATE,
   X_CREATED_BY         IN     NUMBER,
   X_LAST_UPDATE_DATE   IN     DATE,
   X_LAST_UPDATED_BY    IN     NUMBER,
   X_LAST_UPDATE_LOGIN  IN     NUMBER,
   X_OBJECT_VERSION_NUMBER  IN   NUMBER
  ) IS
     cursor C is select ROWID from cn_comp_anchors
       where COMP_ANCHOR_ID = x_comp_anchor_id;

     CURSOR id IS SELECT cn_comp_anchors_s.NEXTVAL FROM dual;
BEGIN
   IF (x_comp_anchor_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_comp_anchor_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

   insert into CN_COMP_ANCHORS
     (LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      COMP_ANCHOR_ID,
      ROLE_QUOTA_CATE_ID,
      QUOTA_CATEGORY_ID,
      ATTAINMENT,
      TYPE,
      COMMISSION,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      LAST_UPDATE_DATE,
      OBJECT_VERSION_NUMBER
      )
     VALUES
     (X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_COMP_ANCHOR_ID,
      X_ROLE_QUOTA_CATE_ID,
      X_QUOTA_CATEGORY_ID,
      X_ATTAINMENT,
      X_TYPE,
      X_COMMISSION,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      x_last_update_date,
      X_OBJECT_VERSION_NUMBER
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW
  (X_COMP_ANCHOR_ID     IN     NUMBER,
   X_ROLE_QUOTA_CATE_ID IN     NUMBER,
   X_QUOTA_CATEGORY_ID  IN     NUMBER,
   X_ATTAINMENT         IN     NUMBER,
   X_TYPE               IN     VARCHAR2,
   X_COMMISSION         IN     NUMBER,
   X_ATTRIBUTE_CATEGORY IN     VARCHAR2,
   X_ATTRIBUTE1         IN     VARCHAR2,
   X_ATTRIBUTE2         IN     VARCHAR2,
   X_ATTRIBUTE3         IN     VARCHAR2,
   X_ATTRIBUTE4         IN     VARCHAR2,
   X_ATTRIBUTE5         IN     VARCHAR2,
   X_ATTRIBUTE6         IN     VARCHAR2,
   X_ATTRIBUTE7         IN     VARCHAR2,
   X_ATTRIBUTE8         IN     VARCHAR2,
   X_ATTRIBUTE9         IN     VARCHAR2,
   X_ATTRIBUTE10        IN     VARCHAR2,
   X_ATTRIBUTE11        IN     VARCHAR2,
   X_ATTRIBUTE12        IN     VARCHAR2,
   X_ATTRIBUTE13        IN     VARCHAR2,
   X_ATTRIBUTE14        IN     VARCHAR2,
   X_ATTRIBUTE15        IN     VARCHAR2,
   X_OBJECT_VERSION_NUMBER  IN   NUMBER
   )
  IS
     cursor c1 is
	SELECT
	  ROLE_QUOTA_CATE_ID,
	  QUOTA_CATEGORY_ID,
	  ATTAINMENT,
	  TYPE,
	  COMMISSION,
	  ATTRIBUTE_CATEGORY,
	  ATTRIBUTE1,
	  ATTRIBUTE2,
	  ATTRIBUTE3,
	  ATTRIBUTE4,
	  ATTRIBUTE5,
	  ATTRIBUTE6,
	  ATTRIBUTE7,
	  ATTRIBUTE8,
	  ATTRIBUTE9,
	  ATTRIBUTE10,
	  ATTRIBUTE11,
	  ATTRIBUTE12,
	  ATTRIBUTE13,
	  ATTRIBUTE14,
	  ATTRIBUTE15,
	  comp_anchor_id,
          OBJECT_VERSION_NUMBER
	  FROM cn_comp_anchors
	  WHERE COMP_ANCHOR_ID = x_comp_anchor_id
	  for update of COMP_ANCHOR_ID nowait;
     tlinfo c1%ROWTYPE;

     record_changed EXCEPTION;
BEGIN
   OPEN c1;
   FETCH c1 INTO tlinfo;

   IF (c1%notfound) THEN
      CLOSE c1;
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      RAISE no_data_found;
   END IF;
   CLOSE c1;

   if ((tlinfo.COMP_ANCHOR_ID = X_COMP_ANCHOR_ID)
       AND (tlinfo.ROLE_QUOTA_CATE_ID = X_ROLE_QUOTA_CATE_ID)
       AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
       AND (tlinfo.QUOTA_CATEGORY_ID = X_QUOTA_CATEGORY_ID)
       AND (tlinfo.ATTAINMENT = X_ATTAINMENT)
       AND (tlinfo.TYPE = X_TYPE)
       AND (tlinfo.COMMISSION = X_COMMISSION)
       AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
	    OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
       AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
	    OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
       AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
	    OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
       AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
	    OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
       AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
	    OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
       AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
	    OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
       AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
	    OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
       AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
            OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
       AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
            OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
       AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
            OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
       AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
            OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
       AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
            OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
       AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
            OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
       AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
            OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
       AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
            OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
       AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
            OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
	      ) THEN
      null;
    ELSE
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      RAISE record_changed;
   end if;
   return;
end LOCK_ROW;

procedure UPDATE_ROW
  (X_COMP_ANCHOR_ID     IN     NUMBER,
   X_ROLE_QUOTA_CATE_ID IN     NUMBER,
   X_QUOTA_CATEGORY_ID  IN     NUMBER,
   X_ATTAINMENT         IN     NUMBER,
   X_TYPE               IN     VARCHAR2,
   X_COMMISSION         IN     NUMBER,
   X_ATTRIBUTE_CATEGORY IN     VARCHAR2,
   X_ATTRIBUTE1         IN     VARCHAR2,
   X_ATTRIBUTE2         IN     VARCHAR2,
   X_ATTRIBUTE3         IN     VARCHAR2,
   X_ATTRIBUTE4         IN     VARCHAR2,
   X_ATTRIBUTE5         IN     VARCHAR2,
   X_ATTRIBUTE6         IN     VARCHAR2,
   X_ATTRIBUTE7         IN     VARCHAR2,
   X_ATTRIBUTE8         IN     VARCHAR2,
   X_ATTRIBUTE9         IN     VARCHAR2,
   X_ATTRIBUTE10        IN     VARCHAR2,
   X_ATTRIBUTE11        IN     VARCHAR2,
   X_ATTRIBUTE12        IN     VARCHAR2,
   X_ATTRIBUTE13        IN     VARCHAR2,
   X_ATTRIBUTE14        IN     VARCHAR2,
   X_ATTRIBUTE15        IN     VARCHAR2,
   X_LAST_UPDATE_DATE   IN     DATE,
   X_LAST_UPDATED_BY    IN     NUMBER,
   X_LAST_UPDATE_LOGIN  IN     NUMBER,
   X_OBJECT_VERSION_NUMBER  IN   NUMBER
  ) IS
BEGIN
   update CN_COMP_ANCHORS SET
     ROLE_QUOTA_CATE_ID = X_ROLE_QUOTA_CATE_ID,
     QUOTA_CATEGORY_ID = X_QUOTA_CATEGORY_ID,
     ATTAINMENT = X_ATTAINMENT,
     TYPE = X_TYPE,
     COMMISSION = X_COMMISSION,
     ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
     ATTRIBUTE1 = X_ATTRIBUTE1,
     ATTRIBUTE2 = X_ATTRIBUTE2,
     ATTRIBUTE3 = X_ATTRIBUTE3,
     ATTRIBUTE4 = X_ATTRIBUTE4,
     ATTRIBUTE5 = X_ATTRIBUTE5,
     ATTRIBUTE6 = X_ATTRIBUTE6,
     ATTRIBUTE7 = X_ATTRIBUTE7,
     ATTRIBUTE8 = X_ATTRIBUTE8,
     ATTRIBUTE9 = X_ATTRIBUTE9,
     ATTRIBUTE10 = X_ATTRIBUTE10,
     ATTRIBUTE11 = X_ATTRIBUTE11,
     ATTRIBUTE12 = X_ATTRIBUTE12,
     ATTRIBUTE13 = X_ATTRIBUTE13,
     ATTRIBUTE14 = X_ATTRIBUTE14,
     ATTRIBUTE15 = X_ATTRIBUTE15,
     COMP_ANCHOR_ID = X_COMP_ANCHOR_ID,
     LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = X_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = x_last_update_login,
     OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
     where COMP_ANCHOR_ID = x_comp_anchor_id;

   if (sql%notfound) THEN
      raise no_data_found;
   end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_COMP_ANCHOR_ID in NUMBER
) is
begin
  delete from CN_COMP_ANCHORS
  where COMP_ANCHOR_ID = X_COMP_ANCHOR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end CN_COMP_ANCHORS_PKG;

/
