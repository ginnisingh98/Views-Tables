--------------------------------------------------------
--  DDL for Package Body WMS_RULE_CONSISTENCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_CONSISTENCIES_PKG" as
/* $Header: WMSHPCOB.pls 120.1 2005/06/21 10:12:49 appldev ship $*/

procedure INSERT_ROW (
  X_ROWID               in out NOCOPY  VARCHAR2,
  X_CONSISTENCY_ID      in NUMBER,
  X_RULE_ID             in NUMBER,
  X_CREATION_DATE       in DATE,
  X_CREATED_BY          in NUMBER,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER,
  X_PARAMETER_ID        in NUMBER,
  X_ATTRIBUTE_CATEGORY  in VARCHAR2,
  X_ATTRIBUTE1          in VARCHAR2,
  X_ATTRIBUTE2          in VARCHAR2,
  X_ATTRIBUTE3          in VARCHAR2,
  X_ATTRIBUTE4          in VARCHAR2,
  X_ATTRIBUTE5          in VARCHAR2,
  X_ATTRIBUTE6          in VARCHAR2,
  X_ATTRIBUTE7          in VARCHAR2,
  X_ATTRIBUTE8          in VARCHAR2,
  X_ATTRIBUTE9          in VARCHAR2,
  X_ATTRIBUTE10         in VARCHAR2,
  X_ATTRIBUTE11         in VARCHAR2,
  X_ATTRIBUTE12         in VARCHAR2,
  X_ATTRIBUTE13         in VARCHAR2,
  X_ATTRIBUTE14         in VARCHAR2,
  X_ATTRIBUTE15         in VARCHAR2
) is
  cursor C is select ROWID from WMS_RULE_CONSISTENCIES
    where RULE_ID        = X_RULE_ID
    and   CONSISTENCY_ID = X_CONSISTENCY_ID
    ;
begin
  insert into WMS_RULE_CONSISTENCIES (
    CONSISTENCY_ID,
    RULE_ID,
    PARAMETER_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
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
    ATTRIBUTE15
  ) values (
    X_CONSISTENCY_ID,
    X_RULE_ID,
    X_PARAMETER_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
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
    X_ATTRIBUTE15
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CONSISTENCY_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_PARAMETER_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c1 is select
      CONSISTENCY_ID,
      RULE_ID,
      PARAMETER_ID,
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
      ATTRIBUTE15
    from WMS_RULE_CONSISTENCIES
    where RULE_ID        = X_RULE_ID
    and   CONSISTENCY_ID = X_CONSISTENCY_ID
    for update of CONSISTENCY_ID nowait;

  tlinfo c1%ROWTYPE;
begin
   OPEN c1;
   FETCH c1 INTO tlinfo;
   IF (c1%notfound) THEN
       CLOSE c1;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
   END IF;
   CLOSE c1;

   IF (    (tlinfo.CONSISTENCY_ID = X_CONSISTENCY_ID)
          AND (tlinfo.RULE_ID = X_RULE_ID)
          AND (tlinfo.PARAMETER_ID = X_PARAMETER_ID)
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
      ) then
        null;
   else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
   end if;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CONSISTENCY_ID     in NUMBER,
  X_RULE_ID            in NUMBER,
  X_LAST_UPDATE_DATE   in DATE,
  X_LAST_UPDATED_BY    in NUMBER,
  X_LAST_UPDATE_LOGIN  in NUMBER,
  X_PARAMETER_ID       in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1         in VARCHAR2,
  X_ATTRIBUTE2         in VARCHAR2,
  X_ATTRIBUTE3         in VARCHAR2,
  X_ATTRIBUTE4         in VARCHAR2,
  X_ATTRIBUTE5         in VARCHAR2,
  X_ATTRIBUTE6         in VARCHAR2,
  X_ATTRIBUTE7         in VARCHAR2,
  X_ATTRIBUTE8         in VARCHAR2,
  X_ATTRIBUTE9         in VARCHAR2,
  X_ATTRIBUTE10        in VARCHAR2,
  X_ATTRIBUTE11        in VARCHAR2,
  X_ATTRIBUTE12        in VARCHAR2,
  X_ATTRIBUTE13        in VARCHAR2,
  X_ATTRIBUTE14        in VARCHAR2,
  X_ATTRIBUTE15        in VARCHAR2
) is
begin
  update WMS_RULE_CONSISTENCIES set
    RULE_ID = X_RULE_ID,
    PARAMETER_ID = X_PARAMETER_ID,
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
    CONSISTENCY_ID = X_CONSISTENCY_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CONSISTENCY_ID = X_CONSISTENCY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
  delete from WMS_RULE_CONSISTENCIES
  where rowid = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE LOAD_ROW (
  X_CONSISTENCY_ID                IN  NUMBER
 ,X_OWNER                         IN  VARCHAR2
 ,X_RULE_ID                       IN  NUMBER
 ,X_PARAMETER_ID                  IN  NUMBER
 ,X_ATTRIBUTE_CATEGORY            IN  VARCHAR2
 ,X_ATTRIBUTE1                    IN  VARCHAR2
 ,X_ATTRIBUTE2                    IN  VARCHAR2
 ,X_ATTRIBUTE3                    IN  VARCHAR2
 ,X_ATTRIBUTE4                    IN  VARCHAR2
 ,X_ATTRIBUTE5                    IN  VARCHAR2
 ,X_ATTRIBUTE6                    IN  VARCHAR2
 ,X_ATTRIBUTE7                    IN  VARCHAR2
 ,X_ATTRIBUTE8                    IN  VARCHAR2
 ,X_ATTRIBUTE9                    IN  VARCHAR2
 ,X_ATTRIBUTE10                   IN  VARCHAR2
 ,X_ATTRIBUTE11                   IN  VARCHAR2
 ,X_ATTRIBUTE12                   IN  VARCHAR2
 ,X_ATTRIBUTE13                   IN  VARCHAR2
 ,X_ATTRIBUTE14                   IN  VARCHAR2
 ,X_ATTRIBUTE15                   IN  VARCHAR2
) IS
BEGIN
   DECLARE
      l_rule_id              NUMBER;
      l_consistency_id       NUMBER;
      l_parameter_id         NUMBER;
      l_user_id              NUMBER := 0;
      l_row_id               VARCHAR2(64);
      l_sysdate              DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_rule_id := fnd_number.canonical_to_number(x_rule_id);
      l_parameter_id  := fnd_number.canonical_to_number(x_parameter_id );
      l_consistency_id  :=
         fnd_number.canonical_to_number(x_consistency_id );

      wms_rule_consistencies_pkg.update_row
	(
         x_consistency_id             => l_consistency_id
         ,x_rule_id                   => l_rule_id
         ,x_last_update_date          => l_sysdate
         ,x_last_updated_by           => l_user_id
         ,x_last_update_login         => 0
         ,x_parameter_id              => l_parameter_id
         ,x_attribute_category        => x_attribute_category
         ,x_attribute1                => x_attribute1
         ,x_attribute2                => x_attribute2
         ,x_attribute3                => x_attribute3
         ,x_attribute4                => x_attribute4
         ,x_attribute5                => x_attribute5
         ,x_attribute6                => x_attribute6
	 ,x_attribute7                => x_attribute7
	 ,x_attribute8                => x_attribute8
	 ,x_attribute9                => x_attribute9
	 ,x_attribute10               => x_attribute10
	 ,x_attribute11               => x_attribute11
	 ,x_attribute12               => x_attribute12
	 ,x_attribute13               => x_attribute13
	 ,x_attribute14               => x_attribute14
	 ,x_attribute15               => x_attribute15
	 );
   EXCEPTION
      WHEN no_data_found THEN
        wms_rule_consistencies_pkg.insert_row
	(
          x_rowid                     => l_row_id
	 ,x_consistency_id            => l_consistency_id
	 ,x_rule_id                   => l_rule_id
	 ,x_creation_date             => l_sysdate
	 ,x_created_by                => l_user_id
	 ,x_last_update_date          => l_sysdate
	 ,x_last_updated_by           => l_user_id
	 ,x_last_update_login         => 0
	 ,x_parameter_id              => l_parameter_id
	 ,x_attribute_category        => x_attribute_category
	 ,x_attribute1                => x_attribute1
	 ,x_attribute2                => x_attribute2
	 ,x_attribute3                => x_attribute3
	 ,x_attribute4                => x_attribute4
	 ,x_attribute5                => x_attribute5
	 ,x_attribute6                => x_attribute6
	 ,x_attribute7                => x_attribute7
	 ,x_attribute8                => x_attribute8
	 ,x_attribute9                => x_attribute9
	 ,x_attribute10               => x_attribute10
	 ,x_attribute11               => x_attribute11
	 ,x_attribute12               => x_attribute12
	 ,x_attribute13               => x_attribute13
	 ,x_attribute14               => x_attribute14
	 ,x_attribute15               => x_attribute15
	 );
   END;
END load_row;
end WMS_RULE_CONSISTENCIES_PKG;

/
