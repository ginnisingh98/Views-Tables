--------------------------------------------------------
--  DDL for Package Body JTF_AM_SKILL_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AM_SKILL_RULES_PKG" as
/* $Header: jtfamtrb.pls 115.0 2003/01/30 23:54:34 nsinghai noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RULE_ID in NUMBER,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_PRODUCT_ID_PASSED in NUMBER,
  X_CATEGORY_ID_PASSED in NUMBER,
  X_PROBLEM_CODE_PASSED in NUMBER,
  X_COMPONENT_ID_PASSED in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_AM_SKILL_RULES
    where RULE_ID = X_RULE_ID
    ;
begin
  insert into JTF_AM_SKILL_RULES (
    RULE_ID,
    DOCUMENT_TYPE,
    PRODUCT_ID_PASSED,
    CATEGORY_ID_PASSED,
    PROBLEM_CODE_PASSED,
    COMPONENT_ID_PASSED,
    ACTIVE_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
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
    SECURITY_GROUP_ID
  ) values(
    X_RULE_ID,
    X_DOCUMENT_TYPE,
    X_PRODUCT_ID_PASSED,
    X_CATEGORY_ID_PASSED,
    X_PROBLEM_CODE_PASSED,
    X_COMPONENT_ID_PASSED,
    X_ACTIVE_FLAG,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
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
    X_SECURITY_GROUP_ID
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
  X_RULE_ID in NUMBER,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_PRODUCT_ID_PASSED in NUMBER,
  X_CATEGORY_ID_PASSED in NUMBER,
  X_PROBLEM_CODE_PASSED in NUMBER,
  X_COMPONENT_ID_PASSED in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER
) is
  cursor c1 is select
      DOCUMENT_TYPE,
      PRODUCT_ID_PASSED,
      CATEGORY_ID_PASSED,
      PROBLEM_CODE_PASSED,
      COMPONENT_ID_PASSED,
      ACTIVE_FLAG,
      OBJECT_VERSION_NUMBER,
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
      SECURITY_GROUP_ID,
      RULE_ID
    from JTF_AM_SKILL_RULES
    where RULE_ID = X_RULE_ID
    for update of RULE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.RULE_ID = X_RULE_ID)
          AND (tlinfo.DOCUMENT_TYPE = X_DOCUMENT_TYPE)
          AND (tlinfo.PRODUCT_ID_PASSED = X_PRODUCT_ID_PASSED)
          AND (tlinfo.CATEGORY_ID_PASSED = X_CATEGORY_ID_PASSED)
          AND (tlinfo.PROBLEM_CODE_PASSED = X_PROBLEM_CODE_PASSED)
          AND (tlinfo.COMPONENT_ID_PASSED = X_COMPONENT_ID_PASSED)
          AND (tlinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
          AND (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
          AND ((tlinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
               OR ((tlinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RULE_ID in NUMBER,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_PRODUCT_ID_PASSED in NUMBER,
  X_CATEGORY_ID_PASSED in NUMBER,
  X_PROBLEM_CODE_PASSED in NUMBER,
  X_COMPONENT_ID_PASSED in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_AM_SKILL_RULES set
    DOCUMENT_TYPE = X_DOCUMENT_TYPE,
    PRODUCT_ID_PASSED = X_PRODUCT_ID_PASSED,
    CATEGORY_ID_PASSED = X_CATEGORY_ID_PASSED,
    PROBLEM_CODE_PASSED = X_PROBLEM_CODE_PASSED,
    COMPONENT_ID_PASSED = X_COMPONENT_ID_PASSED,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
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
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULE_ID = X_RULE_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
) is
begin
  delete from JTF_AM_SKILL_RULES
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_OWNER           in VARCHAR2,
  X_RULE_ID in NUMBER,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_PRODUCT_ID_PASSED in NUMBER,
  X_CATEGORY_ID_PASSED in NUMBER,
  X_PROBLEM_CODE_PASSED in NUMBER,
  X_COMPONENT_ID_PASSED in NUMBER,
  X_ACTIVE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER) IS

  l_row_id rowid;
  l_last_updated_by number := -1;
  l_object_version_number number := 1;
  l_user_id  number ;

  CURSOR c_last_updated IS
    SELECT last_updated_by,
           object_version_number
      from JTF_AM_SKILL_RULES
     WHERE rule_id = x_rule_id;

begin
  if (X_OWNER = 'SEED') then
        l_user_id := 1;
  else
        l_user_id := 0;
  end if;

  OPEN c_last_updated;
  FETCH c_last_updated into l_last_updated_by, l_object_version_number ;
      IF c_last_updated%NOTFOUND THEN
         l_object_version_number := 1;
         jtf_am_skill_rules_pkg.insert_row(
                X_ROWID                 => l_row_id ,
                X_RULE_ID               => X_RULE_ID,
                X_DOCUMENT_TYPE         => X_DOCUMENT_TYPE,
                X_PRODUCT_ID_PASSED     => X_PRODUCT_ID_PASSED,
                X_CATEGORY_ID_PASSED    => X_CATEGORY_ID_PASSED,
                X_PROBLEM_CODE_PASSED   => X_PROBLEM_CODE_PASSED,
                X_COMPONENT_ID_PASSED   => X_COMPONENT_ID_PASSED,
                X_ACTIVE_FLAG           => X_ACTIVE_FLAG,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
                X_ATTRIBUTE3            => X_ATTRIBUTE3 ,
                X_ATTRIBUTE4            => X_ATTRIBUTE4 ,
                X_ATTRIBUTE5            => X_ATTRIBUTE5 ,
                X_ATTRIBUTE6            => X_ATTRIBUTE6 ,
                X_ATTRIBUTE7            => X_ATTRIBUTE7 ,
                X_ATTRIBUTE8            => X_ATTRIBUTE8 ,
                X_ATTRIBUTE9            => X_ATTRIBUTE9 ,
                X_ATTRIBUTE10           => X_ATTRIBUTE10 ,
                X_ATTRIBUTE11           => X_ATTRIBUTE11 ,
                X_ATTRIBUTE12           => X_ATTRIBUTE12 ,
                X_ATTRIBUTE13           => X_ATTRIBUTE13 ,
                X_ATTRIBUTE14           => X_ATTRIBUTE14 ,
                X_ATTRIBUTE15           => X_ATTRIBUTE15 ,
                X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY ,
                X_SECURITY_GROUP_ID     => X_SECURITY_GROUP_ID,
                X_OBJECT_VERSION_NUMBER => l_object_version_number ,
                X_CREATION_DATE         => sysdate      ,
                X_CREATED_BY            => l_user_id ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0 );
      ELSIF c_last_updated%FOUND THEN
         IF l_last_updated_by IN (1,0) THEN
            l_object_version_number :=   l_object_version_number + 1;
            jtf_am_skill_rules_pkg.update_row(
                X_RULE_ID               => X_RULE_ID,
                X_DOCUMENT_TYPE         => X_DOCUMENT_TYPE,
                X_PRODUCT_ID_PASSED     => X_PRODUCT_ID_PASSED,
                X_CATEGORY_ID_PASSED    => X_CATEGORY_ID_PASSED,
                X_PROBLEM_CODE_PASSED   => X_PROBLEM_CODE_PASSED,
                X_COMPONENT_ID_PASSED   => X_COMPONENT_ID_PASSED,
                X_ACTIVE_FLAG           => X_ACTIVE_FLAG,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
                X_ATTRIBUTE3            => X_ATTRIBUTE3 ,
                X_ATTRIBUTE4            => X_ATTRIBUTE4 ,
                X_ATTRIBUTE5            => X_ATTRIBUTE5 ,
                X_ATTRIBUTE6            => X_ATTRIBUTE6 ,
                X_ATTRIBUTE7            => X_ATTRIBUTE7 ,
                X_ATTRIBUTE8            => X_ATTRIBUTE8 ,
                X_ATTRIBUTE9            => X_ATTRIBUTE9 ,
                X_ATTRIBUTE10           => X_ATTRIBUTE10 ,
                X_ATTRIBUTE11           => X_ATTRIBUTE11 ,
                X_ATTRIBUTE12           => X_ATTRIBUTE12 ,
                X_ATTRIBUTE13           => X_ATTRIBUTE13 ,
                X_ATTRIBUTE14           => X_ATTRIBUTE14 ,
                X_ATTRIBUTE15           => X_ATTRIBUTE15 ,
                X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY ,
                X_SECURITY_GROUP_ID     => X_SECURITY_GROUP_ID,
                X_OBJECT_VERSION_NUMBER => l_object_version_number,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0 );
           END IF;
      END IF;
  CLOSE c_last_updated;

end LOAD_ROW;

end JTF_AM_SKILL_RULES_PKG;

/
