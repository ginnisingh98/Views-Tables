--------------------------------------------------------
--  DDL for Package Body HZ_BUS_OBJ_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BUS_OBJ_DEFINITIONS_PKG" AS
/*$Header: ARHBODTB.pls 120.2 2006/04/22 00:47:47 smattegu noship $ */

PROCEDURE Insert_Row (
    x_business_object_code                  IN OUT NOCOPY VARCHAR2,
    x_child_bo_code                         IN OUT NOCOPY VARCHAR2,
    x_tca_mandated_flag                     IN     VARCHAR2,
    x_user_mandated_flag                    IN     VARCHAR2,
    x_root_node_flag                        IN     VARCHAR2,
    x_entity_name                           IN OUT NOCOPY VARCHAR2,
    x_bo_indicator_flag                     IN     VARCHAR2,
    x_display_flag                          IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
    x_bo_version_number                     IN     NUMBER,
    x_creation_date			    IN     DATE,
    x_created_by			    IN     NUMBER,
    x_last_update_date			    IN     DATE,
    x_last_updated_by			    IN     NUMBER,
    x_last_update_login			    IN     NUMBER,
    x_object_version_number                 IN     NUMBER
) IS
    l_success                               VARCHAR2(1) := 'N';
     l_code  varchar2(1);
     cursor C1 is select '1'   from ar_lookups a
     where  a.lookup_type = 'HZ_BUSINESS_OBJECTS' and
     a.lookup_code =  x_business_object_code;
     cursor C2 is select '1'   from ar_lookups b where
           b.lookup_type = 'HZ_BUSINESS_OBJECTS' and
         nvl( x_child_bo_code, b.lookup_code)  = b.lookup_code;
  BEGIN
        OPEN C1;
        FETCH C1 INTO l_code;
        if (c1%notfound) then
           close c1;
           --raise no_data_found;
           raise self_is_null ;
        end if;
        CLOSE C1;
      OPEN C2;
        FETCH C2 INTO l_code;
        if (c2%notfound) then
           close c2;
           --raise no_data_found;
           raise self_is_null ;
        end if;
        CLOSE C2;
      INSERT INTO HZ_BUS_OBJ_DEFINITIONS (
        business_object_code,
        child_bo_code,
        tca_mandated_flag,
        user_mandated_flag,
        root_node_flag,
        entity_name,
        bo_indicator_flag,
        display_flag,
        multiple_flag,
        bo_version_number,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        object_version_number
      )
      VALUES (
        x_business_object_code,
        DECODE(x_child_bo_code,
               FND_API.G_MISS_CHAR, NULL,
               x_child_bo_code),
        x_tca_mandated_flag,
        x_user_mandated_flag,
        x_root_node_flag,
        x_entity_name,
        x_bo_indicator_flag,
        x_display_flag,
        x_multiple_flag,
        DECODE(x_bo_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_bo_version_number),
        x_creation_date,
        x_created_by,
        x_last_update_date,
        x_last_updated_by,
        x_last_update_login,
        x_object_version_number
      )  ;
END Insert_Row;
PROCEDURE Update_Row (
    x_business_object_code                  IN     VARCHAR2,
    x_child_bo_code                         IN     VARCHAR2,
    x_tca_mandated_flag                     IN     VARCHAR2,
    x_user_mandated_flag                    IN     VARCHAR2,
    x_root_node_flag                        IN     VARCHAR2,
    x_entity_name                           IN     VARCHAR2,
    x_bo_indicator_flag                     IN     VARCHAR2,
    x_display_flag                          IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
    x_bo_version_number                     IN     NUMBER,
    x_last_update_date			    IN     DATE,
    x_last_updated_by			    IN     NUMBER,
    x_last_update_login			    IN     NUMBER,
    x_object_version_number                 IN     NUMBER
) IS
BEGIN
    UPDATE HZ_BUS_OBJ_DEFINITIONS
    SET
      business_object_code = x_business_object_code,
      child_bo_code = DECODE(x_child_bo_code,
               NULL, child_bo_code,
               FND_API.G_MISS_CHAR, NULL,
               x_child_bo_code),
      tca_mandated_flag =  DECODE(x_tca_mandated_flag,
                        NULL, tca_mandated_flag,
                        FND_API.G_MISS_CHAR, tca_mandated_flag,
                        x_tca_mandated_flag),
      user_mandated_flag =  DECODE(x_user_mandated_flag,
                        NULL, user_mandated_flag,
                        FND_API.G_MISS_CHAR, user_mandated_flag,
                        x_user_mandated_flag),
      root_node_flag =  DECODE(x_root_node_flag,
                        NULL, root_node_flag,
                        FND_API.G_MISS_CHAR, root_node_flag,
                        x_root_node_flag),
      entity_name = x_entity_name,
      bo_indicator_flag =  DECODE(x_bo_indicator_flag,
                        NULL, bo_indicator_flag,
                        FND_API.G_MISS_CHAR, bo_indicator_flag,
                        x_bo_indicator_flag),
      display_flag  =  DECODE(x_display_flag,
                        NULL, display_flag,
                        FND_API.G_MISS_CHAR, display_flag,
                        x_display_flag),
      multiple_flag  =  DECODE(x_multiple_flag,
                        NULL, multiple_flag,
                        FND_API.G_MISS_CHAR, multiple_flag,
                        x_multiple_flag),
      bo_version_number = DECODE( x_bo_version_number,
               NULL, bo_version_number,
               FND_API.G_MISS_NUM, bo_version_number,
               x_bo_version_number),
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login,
      object_version_number = x_object_version_number
    WHERE business_object_code  = x_business_object_code
       and nvl(child_bo_code, 'N') = nvl( x_child_bo_code, 'N')
       and entity_name = x_entity_name;
    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;
END Update_Row;
PROCEDURE LOAD_ROW (
    x_business_object_code     IN OUT NOCOPY     VARCHAR2,
    x_child_bo_code            IN OUT NOCOPY    VARCHAR2,
    x_entity_name              IN OUT NOCOPY     VARCHAR2,
    x_tca_mandated_flag        IN     VARCHAR2,
    x_user_mandated_flag       IN     VARCHAR2,
    x_root_node_flag           IN     VARCHAR2,
    x_bo_indicator_flag        IN     VARCHAR2,
    x_display_flag             IN     VARCHAR2,
    x_multiple_flag            IN     VARCHAR2,
    x_bo_version_number        IN     NUMBER,
    x_object_version_number    IN     NUMBER,
    x_last_update_date         IN     VARCHAR2,
    X_CUSTOM_MODE              IN     VARCHAR2,
    x_owner		       IN     VARCHAR2 ) IS

  row_id     	varchar2(64);
  l_object_version_number  number;
  l_bo_version_number  number;
  l_lud    date;   -- entity owner in file
  l_luby   fnd_user.user_id%TYPE; -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

BEGIN
  SELECT  NVL2(x_object_version_number, 1, x_object_version_number + 1)
    INTO  l_object_version_number FROM  dual;

  SELECT NVL2(x_bo_version_number, 1, x_bo_version_number + 1)
    INTO l_bo_version_number FROM  dual;

  l_lud := nvl(to_date(x_last_update_date,'YYYY/MM/DD'), sysdate);
  l_luby :=  fnd_load_util.owner_id(X_OWNER);

 SELECT  LAST_UPDATED_BY, LAST_UPDATE_DATE
   INTO  db_luby, db_ludate
   FROM  HZ_BUS_OBJ_DEFINITIONS
  WHERE business_object_code  = x_business_object_code
    AND nvl(child_bo_code, 'N') = nvl( x_child_bo_code, 'N')
    AND entity_name = x_entity_name;

  IF (fnd_load_util.upload_test(l_luby, l_lud, db_luby,
                                db_ludate, X_CUSTOM_MODE)) THEN
    Update_Row (
      x_business_object_code => x_business_object_code,
      x_child_bo_code => x_child_bo_code,
      x_tca_mandated_flag => x_tca_mandated_flag,
      x_user_mandated_flag => x_user_mandated_flag ,
      x_root_node_flag => x_root_node_flag ,
      x_entity_name => x_entity_name ,
      x_bo_indicator_flag => x_bo_indicator_flag ,
      x_display_flag => x_display_flag,
      x_multiple_flag => x_multiple_flag,
      x_bo_version_number => l_bo_version_number ,
      x_last_update_date => l_lud,
      x_last_updated_by => l_luby,
      x_last_update_login => l_luby,
      x_object_version_number => l_object_version_number);
  END IF;

 exception
   when NO_DATA_FOUND then
    Insert_Row (
    x_business_object_code => x_business_object_code,
    x_child_bo_code => x_child_bo_code,
    x_tca_mandated_flag => x_tca_mandated_flag,
    x_user_mandated_flag => x_user_mandated_flag ,
    x_root_node_flag => x_root_node_flag ,
    x_entity_name => x_entity_name ,
    x_bo_indicator_flag => x_bo_indicator_flag ,
    x_display_flag => x_display_flag,
    x_multiple_flag => x_multiple_flag,
    x_bo_version_number => l_bo_version_number ,
    x_creation_date => l_lud,
    x_created_by   => l_luby,
    x_last_update_date => l_lud,
    x_last_updated_by => l_luby,
    x_last_update_login => l_luby,
    x_object_version_number => l_object_version_number);
end LOAD_ROW;
PROCEDURE Select_Row (
    x_business_object_code                  IN OUT NOCOPY VARCHAR2,
    x_child_bo_code                         IN OUT NOCOPY VARCHAR2,
    x_tca_mandated_flag                     OUT    NOCOPY VARCHAR2,
    x_user_mandated_flag                    OUT    NOCOPY VARCHAR2,
    x_root_node_flag                        OUT    NOCOPY VARCHAR2,
    x_entity_name                           IN OUT NOCOPY VARCHAR2,
    x_bo_indicator_flag                     OUT    NOCOPY VARCHAR2,
    x_display_flag                          OUT    NOCOPY VARCHAR2,
    x_bo_version_number                     OUT    NOCOPY NUMBER,
    x_object_version_number                 OUT    NOCOPY NUMBER
) IS
BEGIN
   SELECT
    business_object_code,
      NVL(child_bo_code, FND_API.G_MISS_CHAR),
      tca_mandated_flag,
      user_mandated_flag,
      NVL(root_node_flag, FND_API.G_MISS_CHAR),
      entity_name,
      bo_indicator_flag,
      display_flag,
      NVL(bo_version_number, FND_API.G_MISS_NUM),
      object_version_number
    INTO
      x_business_object_code,
      x_child_bo_code,
      x_tca_mandated_flag,
      x_user_mandated_flag,
      x_root_node_flag,
      x_entity_name,
      x_bo_indicator_flag,
      x_display_flag,
      x_bo_version_number,
      x_object_version_number
    FROM HZ_BUS_OBJ_DEFINITIONS
    WHERE business_object_code = x_business_object_code
       and nvl(child_bo_code, 'N') = nvl( x_child_bo_code, 'N')
       and entity_name = x_entity_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'hz_bus_obj_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', x_business_object_code);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
END Select_Row;
PROCEDURE Delete_Row (
    x_business_object_code                  IN     VARCHAR2,
    x_child_bo_code                         IN     VARCHAR2,
    x_entity_name                           IN     VARCHAR2

) IS
BEGIN
    DELETE FROM HZ_BUS_OBJ_DEFINITIONS
    WHERE business_object_code = x_business_object_code
       and nvl(child_bo_code, 'N') = nvl( x_child_bo_code, 'N')
       and entity_name = x_entity_name;
    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;
END Delete_Row;
END HZ_BUS_OBJ_DEFINITIONS_PKG;

/
