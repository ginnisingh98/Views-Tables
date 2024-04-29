--------------------------------------------------------
--  DDL for Package Body WMS_OP_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OP_PLANS_PKG" AS
/* $Header: WMSOPTBB.pls 120.1 2006/06/19 06:55:28 amohamme noship $ */

--
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT nocopy VARCHAR2
  ,x_operation_plan_id         	    IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_operation_plan_name	    IN     VARCHAR2
  ,x_language                       IN     VARCHAR2
  ,x_source_lang                    IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  )IS
    CURSOR C IS SELECT ROWID FROM WMS_OP_PLANS_B
      WHERE operation_plan_id = x_operation_plan_id;
BEGIN

   INSERT INTO WMS_OP_PLANS_B (
       operation_plan_id
      ,last_updated_by
      ,last_update_date
      ,created_by
      ,creation_date
      ,last_update_login
      ,system_task_type
      ,organization_id
      ,user_defined
      ,enabled_flag
      ,effective_date_from
      ,effective_date_to
      ,activity_type_id
      ,common_to_all_org
      ,plan_type_id
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
      ,default_flag
      ,template_flag
      ,crossdock_to_wip_flag
) values (
       x_operation_plan_id
      ,x_last_updated_by
      ,x_last_update_date
      ,x_created_by
      ,x_creation_date
      ,x_last_update_login
      ,x_system_task_type
      ,x_organization_id
      ,x_user_defined
      ,x_enabled_flag
      ,x_effective_date_from
      ,x_effective_date_to
      ,x_activity_type_id
      ,x_common_to_all_org
      ,x_plan_type_id
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
      ,x_default_flag
      ,x_template_flag
      ,x_crossdock_to_wip_flag
     );

  insert into WMS_OP_PLANS_TL (
    operation_plan_id
   ,last_updated_by
   ,last_update_date
   ,created_by
   ,creation_date
   ,last_update_login
   ,operation_plan_name
   ,description
   ,language
   ,source_lang
  ) select
    x_operation_plan_id
   ,x_last_updated_by
   ,x_last_update_date
   ,x_created_by
   ,x_creation_date
   ,x_last_update_login
   ,x_operation_plan_name
   ,x_description
   ,l.language_code
   ,userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_OP_PLANS_TL T
    where T.OPERATION_PLAN_ID = X_OPERATION_PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
     CLOSE C;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END INSERT_ROW;
--
--
PROCEDURE UPDATE_ROW (
   x_operation_plan_id         	    IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_operation_plan_name            IN     VARCHAR2
  ,x_language                       IN     VARCHAR2
  ,x_source_lang                    IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  )IS
BEGIN
   UPDATE WMS_OP_PLANS_B SET
       last_updated_by 	= x_last_updated_by
      ,last_update_date = x_last_update_date
      ,last_update_login = x_last_update_login
      ,system_task_type = x_system_task_type
      ,organization_id = x_organization_id
      ,user_defined = x_user_defined
      ,enabled_flag = x_enabled_flag
      ,effective_date_from = x_effective_date_from
      ,effective_date_to  = x_effective_date_to
      ,activity_type_id = x_activity_type_id
      ,common_to_all_org = x_common_to_all_org
      ,plan_type_id = x_plan_type_id
      ,attribute_category = x_attribute_category
      ,attribute1 = x_attribute1
      ,attribute2 = x_attribute2
      ,attribute3 = x_attribute3
      ,attribute4 = x_attribute4
      ,attribute5 = x_attribute5
      ,attribute6 = x_attribute6
      ,attribute7 = x_attribute7
      ,attribute8 = x_attribute8
      ,attribute9 = x_attribute9
      ,attribute10 = x_attribute10
      ,attribute11 = x_attribute11
      ,attribute12 = x_attribute12
      ,attribute13 = x_attribute13
      ,attribute14 = x_attribute14
      ,attribute15 = x_attribute15
      ,default_flag = x_default_flag
      ,template_flag = x_template_flag
     ,crossdock_to_wip_flag = x_crossdock_to_wip_flag
   WHERE operation_plan_id = x_operation_plan_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_OP_PLANS_TL set
    operation_plan_name = x_operation_plan_name,
    description = x_description,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OPERATION_PLAN_ID = X_OPERATION_PLAN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

END UPDATE_ROW;
--
PROCEDURE LOAD_ROW(
   x_operation_plan_id         	    IN     NUMBER
  ,x_owner                          IN     VARCHAR2
  ,x_last_update_date               IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_operation_plan_name            IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  ,x_custom_mode 		    IN 	   VARCHAR2
  ) IS

      l_operation_plan_id   NUMBER;
      l_row_id              VARCHAR2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
      BEGIN
      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(X_OWNER);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
      BEGIN
      l_operation_plan_id := fnd_number.canonical_to_number(x_operation_plan_id);
      select LAST_UPDATED_BY,LAST_UPDATE_DATE
      INTO db_luby,db_ludate
      from wms_op_plans_B where
      operation_plan_id = l_operation_plan_id ;
      -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      -- Update existing row
      WMS_OP_PLANS_PKG.update_row (
   		x_operation_plan_id         	 => l_operation_plan_id
  	       ,x_last_updated_by                => f_luby
  	       ,x_last_update_date               => f_ludate
               ,x_last_update_login              => 0
               ,x_operation_plan_name            => x_operation_plan_name
               ,x_language                       => NULL
               ,x_source_lang                    => NULL
               ,x_description                    => x_description
               ,x_system_task_type               => x_system_task_type
               ,x_organization_id                => x_organization_id
               ,x_user_defined                   => x_user_defined
               ,x_enabled_flag                   => x_enabled_flag
               ,x_effective_date_from            => x_effective_date_from
               ,x_effective_date_to              => x_effective_date_to
               ,x_activity_type_id               => x_activity_type_id
               ,x_common_to_all_org              => x_common_to_all_org
               ,x_plan_type_id                   => x_plan_type_id
               ,x_attribute_category             => x_attribute_category
               ,x_attribute1                     => x_attribute1
               ,x_attribute2                     => x_attribute2
               ,x_attribute3                     => x_attribute3
               ,x_attribute4                     => x_attribute4
               ,x_attribute5                     => x_attribute5
               ,x_attribute6                     => x_attribute6
               ,x_attribute7                     => x_attribute7
               ,x_attribute8                     => x_attribute8
               ,x_attribute9                     => x_attribute9
               ,x_attribute10                    => x_attribute10
               ,x_attribute11                    => x_attribute11
               ,x_attribute12                    => x_attribute12
               ,x_attribute13                    => x_attribute13
               ,x_attribute14                    => x_attribute14
               ,x_attribute15                    => x_attribute15
               ,x_default_flag			 => x_default_flag
	       ,x_template_flag			 => x_template_flag
	       ,x_crossdock_to_wip_flag          => x_crossdock_to_wip_flag
          );
	  end if;
   EXCEPTION
      WHEN no_data_found THEN
      -- Record doesn't exist - insert in all cases
	 WMS_OP_PLANS_PKG.insert_row (
                x_rowid                          => l_row_id
               ,x_operation_plan_id         	 => l_operation_plan_id
  	       ,x_last_updated_by                => f_luby
  	       ,x_last_update_date               => f_ludate
  	       ,x_created_by                     => f_luby
  	       ,x_creation_date                  => f_ludate
               ,x_last_update_login              => 0
               ,x_operation_plan_name            => x_operation_plan_name
               ,x_language                       => NULL
               ,x_source_lang                    => NULL
               ,x_description                    => x_description
               ,x_system_task_type               => x_system_task_type
               ,x_organization_id                => x_organization_id
               ,x_user_defined                   => x_user_defined
               ,x_enabled_flag                   => x_enabled_flag
               ,x_effective_date_from            => x_effective_date_from
               ,x_effective_date_to              => x_effective_date_to
               ,x_activity_type_id               => x_activity_type_id
               ,x_common_to_all_org              => x_common_to_all_org
               ,x_plan_type_id                   => x_plan_type_id
               ,x_attribute_category             => x_attribute_category
               ,x_attribute1                     => x_attribute1
               ,x_attribute2                     => x_attribute2
               ,x_attribute3                     => x_attribute3
               ,x_attribute4                     => x_attribute4
               ,x_attribute5                     => x_attribute5
               ,x_attribute6                     => x_attribute6
               ,x_attribute7                     => x_attribute7
               ,x_attribute8                     => x_attribute8
               ,x_attribute9                     => x_attribute9
               ,x_attribute10                    => x_attribute10
               ,x_attribute11                    => x_attribute11
               ,x_attribute12                    => x_attribute12
               ,x_attribute13                    => x_attribute13
               ,x_attribute14                    => x_attribute14
               ,x_attribute15                    => x_attribute15
               ,x_default_flag			 => x_default_flag
	       ,x_template_flag			 => x_template_flag
	       ,x_crossdock_to_wip_flag          => x_crossdock_to_wip_flag
         );
   END;
END LOAD_ROW;


--  Added by Grace Xiao 07/28/03

PROCEDURE delete_row (
  x_operation_plan_id  IN NUMBER
) IS

BEGIN

  delete from WMS_OP_PLANS_B
  where OPERATION_PLAN_ID = X_OPERATION_PLAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_OP_PLANS_TL
  where operation_plan_id = X_OPERATION_PLAN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END delete_row;


--  Added by Grace Xiao 07/28/03

PROCEDURE lock_row (
   x_operation_plan_id         	    IN     NUMBER
  ,x_operation_plan_name	    IN     VARCHAR2
  ,x_description                    IN     VARCHAR2
  ,x_system_task_type               IN     NUMBER
  ,x_organization_id                IN     NUMBER
  ,x_user_defined                   IN     VARCHAR2
  ,x_enabled_flag                   IN     VARCHAR2
  ,x_effective_date_from            IN     DATE
  ,x_effective_date_to              IN     DATE
  ,x_activity_type_id               IN     NUMBER
  ,x_common_to_all_org              IN     VARCHAR2
  ,x_plan_type_id                   IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2 DEFAULT NULL
  ,x_attribute1                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute2                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute3                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute4                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute5                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute6                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute7                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute8                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute9                     IN     VARCHAR2 DEFAULT NULL
  ,x_attribute10                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute11                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute12                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute13                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute14                    IN     VARCHAR2 DEFAULT NULL
  ,x_attribute15                    IN     VARCHAR2 DEFAULT NULL
  ,x_default_flag                   IN     VARCHAR2
  ,x_template_flag                  IN     VARCHAR2
  ,x_crossdock_to_wip_flag          IN     VARCHAR2
  ) IS
     cursor C IS SELECT
   system_task_type
  ,organization_id
  ,user_defined
  ,enabled_flag
  ,effective_date_from
  ,effective_date_to
  ,activity_type_id
  ,common_to_all_org
  ,plan_type_id
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
  ,default_flag
  ,template_flag
  ,crossdock_to_wip_flag
       from wms_op_plans_b
	where operation_plan_id = x_operation_plan_id
  	for UPDATE of OPERATION_PLAN_ID NOWAIT;
recinfo		C%rowtype;


cursor c1 is select
        operation_plan_name,
        description,
        decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
        from wms_op_plans_tl
        where operation_plan_id = x_operation_plan_id
        and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        for UPDATE of OPERATION_PLAN_ID NOWAIT;
--recinfo1	c1%rowtype;

BEGIN
	OPEN C;
	fetch C into recinfo;
        if(C%NOTFOUND) then
		close C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;

	if (           ((recinfo.SYSTEM_TASK_TYPE = x_system_task_type)
			OR	(	(recinfo.SYSTEM_TASK_TYPE is null)
				AND	(x_system_task_type is null)))
             AND        (       (recinfo.ACTIVITY_TYPE_ID = x_activity_type_id)
                        OR     (       (recinfo.ACTIVITY_TYPE_ID is null)
                                AND     (x_activity_type_id is null)))
             AND        (       (recinfo.PLAN_TYPE_ID = x_plan_type_id)
                        OR     (       (recinfo.PLAN_TYPE_ID is null)
                                AND     (x_plan_type_id is null)))
             AND        (       (recinfo.COMMON_TO_ALL_ORG = x_common_to_all_org)
                        OR     (       (recinfo.COMMON_TO_ALL_ORG is null)
                                AND     (X_COMMON_TO_ALL_ORG is null)))
             AND        (       (recinfo.EFFECTIVE_DATE_FROM = X_EFFECTIVE_DATE_FROM)
                        OR     (       (recinfo.effective_date_from is null)
                                AND     (x_effective_date_from is null)))
             AND        (       (recinfo.EFFECTIVE_DATE_TO = X_EFFECTIVE_DATE_TO)
                        OR     (       (recinfo.effective_date_to is null)
                                AND     (x_effective_date_to is null)))
             AND        (       (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
                        OR     (       (recinfo.ORGANIZATION_ID is null)
                                AND     (x_ORGANIZATION_ID is null)))
             AND        (       (recinfo.USER_DEFINED = X_USER_DEFINED)
                        OR     (       (recinfo.USER_DEFINED is null)
                                AND     (x_USER_DEFINED is null)))
             AND        (       (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
                        OR     (       (recinfo.ENABLED_FLAG is null)
                                AND     (x_ENABLED_FLAG is null)))
             AND        (       (recinfo.TEMPLATE_FLAG = X_TEMPLATE_FLAG)
                        OR     (       (recinfo.TEMPLATE_FLAG is null)
                                AND     (x_TEMPLATE_FLAG is null)))
             AND        (       (recinfo.crossdock_to_wip_flag = x_crossdock_to_wip_flag)
                        OR     (       (recinfo.crossdock_to_wip_flag is null)
                                AND     (x_crossdock_to_wip_flag is null)))
             AND        (       (recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
                        OR     (       (recinfo.DEFAULT_FLAG is null)
                                AND     (x_DEFAULT_FLAG is null)))
             AND        (       (recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
			OR     (       (recinfo.ATTRIBUTE_CATEGORY is null)
				AND     (X_ATTRIBUTE_CATEGORY is null)))
             AND        (       (recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
                        OR     (       (recinfo.ATTRIBUTE1 is null)
				AND     (X_ATTRIBUTE1 is null)))
             AND        (      (recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
			OR     (       (recinfo.ATTRIBUTE10 is null)
				AND     (X_ATTRIBUTE10 is null)))
             AND        (      (recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
		        OR     (       (recinfo.ATTRIBUTE11 is null)
				AND     (X_ATTRIBUTE11 is null)))
             AND        (      (recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
		        OR     (       (recinfo.ATTRIBUTE8 is null)
				AND     (X_ATTRIBUTE8 is null)))
             AND        (      (recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
	      	        OR     (       (recinfo.ATTRIBUTE9 is null)
				       AND     (X_ATTRIBUTE9 is null)))
             AND        (      (recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
	      	        OR     (       (recinfo.ATTRIBUTE15 is null)
				AND     (X_ATTRIBUTE15 is null)))
	     AND        (      (recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
	      	        OR     (       (recinfo.ATTRIBUTE14 is null)
				AND     (X_ATTRIBUTE14 is null)))
             AND        (      (recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
		        OR     (       (recinfo.ATTRIBUTE3 is null)
				AND     (X_ATTRIBUTE3 is null)))
             AND        (      (recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
		        OR     (       (recinfo.ATTRIBUTE4 is null)
				AND (X_ATTRIBUTE4 is null)))
             AND        (      (recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
			OR     (       (recinfo.ATTRIBUTE5 is null)
			        AND (X_ATTRIBUTE5 is null)))
             AND        (      (recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
			OR     (       (recinfo.ATTRIBUTE6 is null)
				AND (X_ATTRIBUTE6 is null)))
             AND        (      (recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
			OR     (       (recinfo.ATTRIBUTE7 is null)
				AND (X_ATTRIBUTE7 is null)))
             AND        (      (recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
			OR     (       (recinfo.ATTRIBUTE2 is null)
				AND (X_ATTRIBUTE2 is null)))
             AND        (      (recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
			OR     (       (recinfo.ATTRIBUTE12 is null)
				AND (X_ATTRIBUTE12 is null)))
             AND        (      (recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
			OR     (       (recinfo.ATTRIBUTE13 is null)
				       AND (X_ATTRIBUTE13 is null)))
      ) then
                  null;

	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                APP_EXCEPTION.Raise_Exception;
	end if;

	for tlinfo in c1 loop
	   if (tlinfo.BASELANG = 'Y') then
	      if (    (tlinfo.OPERATION_PLAN_NAME = X_OPERATION_PLAN_NAME)
		      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
			   OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
	      ) then
		return;
             else
              fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
              app_exception.raise_exception;
             end if;
           end if;
        end loop;
        return;
end LOCK_ROW;

--added BY grace 12/09/03

PROCEDURE translate_row
  (
   x_operation_plan_id        IN  VARCHAR2 ,
   x_owner                    IN  VARCHAR2 ,
   x_last_update_date         IN  VARCHAR2 ,
   x_operation_plan_name      IN  VARCHAR2 ,
   x_description              IN  VARCHAR2 ,
   x_custom_mode 	      IN  VARCHAR2
   ) IS

   f_luby    number;  -- entity owner in file
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db
BEGIN
   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(X_OWNER);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  /*
   UPDATE wms_op_plans_b SET
     last_update_date        = Sysdate,
     last_updated_by         = Decode(x_owner, 'SEED', 1, 0),
     last_update_login       = 0
     WHERE operation_plan_id = fnd_number.canonical_to_number(x_operation_plan_id);
     */
  BEGIN
   -- Test for customization and version
   select LAST_UPDATED_BY,LAST_UPDATE_DATE
   INTO db_luby,db_ludate
   from wms_op_plans_B where
    operation_plan_id = fnd_number.canonical_to_number(x_operation_plan_id);
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, x_custom_mode)) then

      -- Update translations for this language
   UPDATE wms_op_plans_tl SET
     operation_plan_name     = x_operation_plan_name,
     description             = x_description,
     last_update_date        = f_ludate,
     last_updated_by         = f_luby,
     last_update_login       = 0,
     source_lang             = userenv('LANG')
     WHERE operation_plan_id = fnd_number.canonical_to_number(x_operation_plan_id) AND userenv('LANG') IN (language, source_lang);
   END IF;
   exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
END translate_row;



procedure ADD_LANGUAGE
  is
begin
   delete from WMS_OP_PLANS_TL T
     where not exists
     (select NULL
      from WMS_OP_PLANS_B B
      where B.OPERATION_PLAN_ID = T.OPERATION_PLAN_ID
      );

   update WMS_OP_PLANS_TL T set (
      OPERATION_PLAN_NAME,
      DESCRIPTION
    ) = (select
      B.OPERATION_PLAN_NAME,
      B.DESCRIPTION
    from WMS_OP_PLANS_TL B
    where B.OPERATION_PLAN_ID = T.OPERATION_PLAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OPERATION_PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OPERATION_PLAN_ID,
      SUBT.LANGUAGE
    from WMS_OP_PLANS_TL SUBB, WMS_OP_PLANS_TL SUBT
    where SUBB.OPERATION_PLAN_ID = SUBT.OPERATION_PLAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OPERATION_PLAN_NAME <> SUBT.OPERATION_PLAN_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WMS_OP_PLANS_TL (
    DESCRIPTION,
    CREATED_BY,
    OPERATION_PLAN_NAME,
    LAST_UPDATE_LOGIN,
    OPERATION_PLAN_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DESCRIPTION,
    B.CREATED_BY,
    B.OPERATION_PLAN_NAME,
    B.LAST_UPDATE_LOGIN,
    B.OPERATION_PLAN_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_OP_PLANS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_OP_PLANS_TL T
    where T.OPERATION_PLAN_ID = B.OPERATION_PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END WMS_OP_PLANS_PKG;

/
