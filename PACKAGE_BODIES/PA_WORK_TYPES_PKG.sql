--------------------------------------------------------
--  DDL for Package Body PA_WORK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORK_TYPES_PKG" as
/* $Header: PAWKTYPB.pls 120.1 2005/08/11 10:08:12 eyefimov noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_WORK_TYPE_ID in NUMBER,
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
  X_BILLABLE_CAPITALIZABLE_FLAG in VARCHAR2,
  X_REDUCE_CAPACITY_FLAG in VARCHAR2,
  X_RES_UTILIZATION_PERCENTAGE in NUMBER,
  X_ORG_UTILIZATION_PERCENTAGE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_RES_UTIL_CATEGORY_ID in NUMBER,
  X_ORG_UTIL_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_TRAINING_FLAG in VARCHAR2,
  X_TP_AMT_TYPE_CODE in VARCHAR2,
  X_UNASSIGNED_FLAG  in VARCHAR2
) is

  cursor C is select ROWID from PA_WORK_TYPES_B
    where WORK_TYPE_ID = X_WORK_TYPE_ID
    ;
	/** Added thses variables for PJI changes **/
	l_pji_rowid     VARCHAR2(1000);
        l_pji_event_id  NUMBER;

begin

  insert into PA_WORK_TYPES_B (
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
    WORK_TYPE_ID,
    BILLABLE_CAPITALIZABLE_FLAG,
    REDUCE_CAPACITY_FLAG,
    RES_UTILIZATION_PERCENTAGE,
    ORG_UTILIZATION_PERCENTAGE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    RES_UTIL_CATEGORY_ID,
    ORG_UTIL_CATEGORY_ID,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TRAINING_FLAG,
    TP_AMT_TYPE_CODE ,
    UNASSIGNED_FLAG
  ) values (
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
    X_WORK_TYPE_ID,
    X_BILLABLE_CAPITALIZABLE_FLAG,
    X_REDUCE_CAPACITY_FLAG,
    X_RES_UTILIZATION_PERCENTAGE,
    X_ORG_UTILIZATION_PERCENTAGE,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_RES_UTIL_CATEGORY_ID,
    X_ORG_UTIL_CATEGORY_ID,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_TRAINING_FLAG,
    X_TP_AMT_TYPE_CODE ,
    X_UNASSIGNED_FLAG
  );

	/** If PJI is installed then we need to insert record into PA_PJI_PROJ_EVENTS_LOG table
         ** for every insert/update/delete in pa_work_types_b **/
	IF ((sql%rowcount > 0) AND  (NVL(PA_INSTALL.is_pji_licensed(),'N')='Y')) THEN
		l_pji_rowid   := null;
		l_pji_event_id := null;

		PA_PJI_PROJ_EVENTS_LOG_PKG.Insert_Row(
		X_ROW_ID                => l_pji_rowid
		,X_EVENT_ID             => l_pji_event_id
		,X_EVENT_TYPE           => 'Work Types'
		,X_EVENT_OBJECT         => X_WORK_TYPE_ID
		,X_OPERATION_TYPE       => 'I' -- insert mode
		,X_STATUS               => 'X' --NULL
		,X_ATTRIBUTE_CATEGORY   => NULL
		,X_ATTRIBUTE1           => X_RES_UTILIZATION_PERCENTAGE
		,X_ATTRIBUTE2           => X_ORG_UTILIZATION_PERCENTAGE
		,X_ATTRIBUTE3           => X_BILLABLE_CAPITALIZABLE_FLAG
		,X_ATTRIBUTE4           => X_REDUCE_CAPACITY_FLAG
		,X_ATTRIBUTE5           => X_TRAINING_FLAG
		,X_ATTRIBUTE6           => X_UNASSIGNED_FLAG
		,X_ATTRIBUTE7           => X_TP_AMT_TYPE_CODE
		,X_ATTRIBUTE8           => to_char(X_START_DATE_ACTIVE,'YYYY/MM/DD')/* Bug fix:2428599 */
		,X_ATTRIBUTE9           => to_char(X_END_DATE_ACTIVE ,'YYYY/MM/DD')/* Bug fix:2428599 */
		,X_ATTRIBUTE10          => X_RES_UTIL_CATEGORY_ID
		,X_ATTRIBUTE11          => X_ORG_UTIL_CATEGORY_ID
		,X_ATTRIBUTE12          => NULL
		,X_ATTRIBUTE13          => NULL
		,X_ATTRIBUTE14          => NULL
		,X_ATTRIBUTE15          => NULL
		,X_ATTRIBUTE16          => NULL
		,X_ATTRIBUTE17          => NULL
		,X_ATTRIBUTE18          => NULL
		,X_ATTRIBUTE19          => NULL
		,X_ATTRIBUTE20          => NULL
		);
	End If;
	/** End of PJI changes **/

  insert into PA_WORK_TYPES_TL (
    WORK_TYPE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_WORK_TYPE_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PA_WORK_TYPES_TL T
    where T.WORK_TYPE_ID = X_WORK_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION
	WHEN OTHERS THEN
        X_ROWID := Null;
		RAISE;

end INSERT_ROW;

procedure LOCK_ROW (
  X_WORK_TYPE_ID in NUMBER,
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
  X_BILLABLE_CAPITALIZABLE_FLAG in VARCHAR2,
  X_REDUCE_CAPACITY_FLAG in VARCHAR2,
  X_RES_UTILIZATION_PERCENTAGE in NUMBER,
  X_ORG_UTILIZATION_PERCENTAGE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_RES_UTIL_CATEGORY_ID in NUMBER,
  X_ORG_UTIL_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TRAINING_FLAG in VARCHAR2,
  X_TP_AMT_TYPE_CODE in VARCHAR2,
  X_UNASSIGNED_FLAG  in VARCHAR2
) is

  cursor c is select
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
      BILLABLE_CAPITALIZABLE_FLAG,
      REDUCE_CAPACITY_FLAG,
      RES_UTILIZATION_PERCENTAGE,
      ORG_UTILIZATION_PERCENTAGE,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      RES_UTIL_CATEGORY_ID,
      ORG_UTIL_CATEGORY_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      TRAINING_FLAG,
      TP_AMT_TYPE_CODE,
      UNASSIGNED_FLAG
    from PA_WORK_TYPES_B
    where WORK_TYPE_ID = X_WORK_TYPE_ID
    for update of WORK_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PA_WORK_TYPES_TL
    where WORK_TYPE_ID = X_WORK_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of WORK_TYPE_ID nowait;

begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND (recinfo.BILLABLE_CAPITALIZABLE_FLAG = X_BILLABLE_CAPITALIZABLE_FLAG)
      AND (recinfo.REDUCE_CAPACITY_FLAG = X_REDUCE_CAPACITY_FLAG)
      AND (recinfo.RES_UTILIZATION_PERCENTAGE = X_RES_UTILIZATION_PERCENTAGE)
      AND (recinfo.ORG_UTILIZATION_PERCENTAGE = X_ORG_UTILIZATION_PERCENTAGE)
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.RES_UTIL_CATEGORY_ID = X_RES_UTIL_CATEGORY_ID)
           OR ((recinfo.RES_UTIL_CATEGORY_ID is null) AND (X_RES_UTIL_CATEGORY_ID is null)))
      AND ((recinfo.ORG_UTIL_CATEGORY_ID = X_ORG_UTIL_CATEGORY_ID)
           OR ((recinfo.ORG_UTIL_CATEGORY_ID is null) AND (X_ORG_UTIL_CATEGORY_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND     ((recinfo.TRAINING_FLAG = X_TRAINING_FLAG)
           OR ((recinfo.TRAINING_FLAG is null) AND (X_TRAINING_FLAG is null)))
      AND ((recinfo.TP_AMT_TYPE_CODE = X_TP_AMT_TYPE_CODE)
           OR ((recinfo.TP_AMT_TYPE_CODE is null) AND (X_TP_AMT_TYPE_CODE is null)))
      AND ((recinfo.UNASSIGNED_FLAG = X_UNASSIGNED_FLAG )
           OR ((recinfo.UNASSIGNED_FLAG is null) AND (X_UNASSIGNED_FLAG is null)))
  ) then

    null;

  else

    null;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;

  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_WORK_TYPE_ID in NUMBER,
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
  X_BILLABLE_CAPITALIZABLE_FLAG in VARCHAR2,
  X_REDUCE_CAPACITY_FLAG in VARCHAR2,
  X_RES_UTILIZATION_PERCENTAGE in NUMBER,
  X_ORG_UTILIZATION_PERCENTAGE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_RES_UTIL_CATEGORY_ID in NUMBER,
  X_ORG_UTIL_CATEGORY_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_TRAINING_FLAG in VARCHAR2,
  X_TP_AMT_TYPE_CODE in VARCHAR2,
  X_UNASSIGNED_FLAG  in VARCHAR2
) is

        /** Added thses variables for PJI changes **/
        l_pji_rowid     VARCHAR2(1000);
        l_pji_event_id  NUMBER;

	cursor old_worktype_values IS
	SELECT
		RES_UTILIZATION_PERCENTAGE
		,ORG_UTILIZATION_PERCENTAGE
		,BILLABLE_CAPITALIZABLE_FLAG
		,REDUCE_CAPACITY_FLAG
		,TRAINING_FLAG
		,UNASSIGNED_FLAG
		,TP_AMT_TYPE_CODE
		,START_DATE_ACTIVE
		,END_DATE_ACTIVE
		,RES_UTIL_CATEGORY_ID
		,ORG_UTIL_CATEGORY_ID
	FROM  pa_work_types_b
	WHERE work_type_id = X_WORK_TYPE_ID;

	l_wt_old   old_worktype_values%ROWTYPE;
	l_sql_rowcount   number;

BEGIN

    OPEN old_worktype_values;
    FETCH old_worktype_values INTO l_wt_old;
    IF old_worktype_values%FOUND then

  	update PA_WORK_TYPES_B set
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
    		BILLABLE_CAPITALIZABLE_FLAG = X_BILLABLE_CAPITALIZABLE_FLAG,
    		REDUCE_CAPACITY_FLAG = X_REDUCE_CAPACITY_FLAG,
    		RES_UTILIZATION_PERCENTAGE = X_RES_UTILIZATION_PERCENTAGE,
    		ORG_UTILIZATION_PERCENTAGE = X_ORG_UTILIZATION_PERCENTAGE,
    		START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    		END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    		RES_UTIL_CATEGORY_ID = X_RES_UTIL_CATEGORY_ID,
    		ORG_UTIL_CATEGORY_ID = X_ORG_UTIL_CATEGORY_ID,
    		ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    		ATTRIBUTE1 = X_ATTRIBUTE1,
    		ATTRIBUTE2 = X_ATTRIBUTE2,
    		LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    		LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    		TRAINING_FLAG = X_TRAINING_FLAG,
    		TP_AMT_TYPE_CODE = X_TP_AMT_TYPE_CODE,
    		UNASSIGNED_FLAG = X_UNASSIGNED_FLAG
  	where WORK_TYPE_ID = X_WORK_TYPE_ID;

	l_sql_rowcount := sql%rowcount;

        /** If PJI is installed then we need to insert record into PA_PJI_PROJ_EVENTS_LOG table
         ** for every insert/update/delete in pa_work_types_b **/
        IF ((l_sql_rowcount > 0) AND  (NVL(PA_INSTALL.is_pji_licensed(),'N')='Y')) THEN
                l_pji_rowid   := null;
                l_pji_event_id := null;

                PA_PJI_PROJ_EVENTS_LOG_PKG.Insert_Row(
                X_ROW_ID                => l_pji_rowid
                ,X_EVENT_ID             => l_pji_event_id
                ,X_EVENT_TYPE           => 'Work Types'
                ,X_EVENT_OBJECT         => X_WORK_TYPE_ID
                ,X_OPERATION_TYPE       => 'U' -- update mode
                ,X_STATUS               => 'X' --NULL
                ,X_ATTRIBUTE_CATEGORY   => NULL
                ,X_ATTRIBUTE1           => l_wt_old.RES_UTILIZATION_PERCENTAGE
                ,X_ATTRIBUTE2           => l_wt_old.ORG_UTILIZATION_PERCENTAGE
                ,X_ATTRIBUTE3           => l_wt_old.BILLABLE_CAPITALIZABLE_FLAG
                ,X_ATTRIBUTE4           => l_wt_old.REDUCE_CAPACITY_FLAG
                ,X_ATTRIBUTE5           => l_wt_old.TRAINING_FLAG
                ,X_ATTRIBUTE6           => l_wt_old.UNASSIGNED_FLAG
                ,X_ATTRIBUTE7           => l_wt_old.TP_AMT_TYPE_CODE
                ,X_ATTRIBUTE8           => to_char(l_wt_old.START_DATE_ACTIVE,'YYYY/MM/DD') /* Bug fix:2428599 */
                ,X_ATTRIBUTE9           => to_char(l_wt_old.END_DATE_ACTIVE,'YYYY/MM/DD') /* Bug fix:2428599 */
                ,X_ATTRIBUTE10          => l_wt_old.RES_UTIL_CATEGORY_ID
                ,X_ATTRIBUTE11          => l_wt_old.ORG_UTIL_CATEGORY_ID
                ,X_ATTRIBUTE12          => NULL
                ,X_ATTRIBUTE13          => NULL
                ,X_ATTRIBUTE14          => NULL
                ,X_ATTRIBUTE15          => NULL
                ,X_ATTRIBUTE16          => NULL
                ,X_ATTRIBUTE17          => NULL
                ,X_ATTRIBUTE18          => NULL
                ,X_ATTRIBUTE19          => NULL
                ,X_ATTRIBUTE20          => NULL
		  );
        End If;

   END IF; -- end of fetch
   CLOSE old_worktype_values;
   /** End of PJI changes **/

  if (l_sql_rowcount <= 0 ) then
    raise no_data_found;
  end if;



  update PA_WORK_TYPES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where WORK_TYPE_ID = X_WORK_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

EXCEPTION
	WHEN OTHERS THEN
                If old_worktype_values%isopen then
                        close old_worktype_values;
                End if;
		RAISE;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_WORK_TYPE_ID in NUMBER
) is

        /** Added thses variables for PJI changes **/
        l_pji_rowid     VARCHAR2(1000);
        l_pji_event_id  NUMBER;

        cursor old_worktype_values IS
        SELECT
                RES_UTILIZATION_PERCENTAGE
                ,ORG_UTILIZATION_PERCENTAGE
                ,BILLABLE_CAPITALIZABLE_FLAG
                ,REDUCE_CAPACITY_FLAG
                ,TRAINING_FLAG
                ,UNASSIGNED_FLAG
                ,TP_AMT_TYPE_CODE
                ,START_DATE_ACTIVE
                ,END_DATE_ACTIVE
                ,RES_UTIL_CATEGORY_ID
                ,ORG_UTIL_CATEGORY_ID
        FROM  pa_work_types_b
        WHERE work_type_id = X_WORK_TYPE_ID;

        l_wt_old   old_worktype_values%ROWTYPE;
	l_sql_rowcount    Number ;

BEGIN

    OPEN old_worktype_values;
    FETCH old_worktype_values INTO l_wt_old;
    IF old_worktype_values%FOUND then

   	delete from PA_WORK_TYPES_TL
  	where WORK_TYPE_ID = X_WORK_TYPE_ID;

	l_sql_rowcount := sql%rowcount ;

        /** If PJI is installed then we need to insert record into PA_PJI_PROJ_EVENTS_LOG table
         ** for every insert/update/delete in pa_work_types_b **/
        IF ((l_sql_rowcount > 0) AND  (NVL(PA_INSTALL.is_pji_licensed(),'N')='Y')) THEN
             l_pji_rowid   := null;
             l_pji_event_id := null;

                PA_PJI_PROJ_EVENTS_LOG_PKG.Insert_Row(
                X_ROW_ID                => l_pji_rowid
                ,X_EVENT_ID             => l_pji_event_id
                ,X_EVENT_TYPE           => 'Work Types'
                ,X_EVENT_OBJECT         => X_WORK_TYPE_ID
                ,X_OPERATION_TYPE       => 'D' -- delete mode
                ,X_STATUS               => 'X' --NULL
                ,X_ATTRIBUTE_CATEGORY   => NULL
                ,X_ATTRIBUTE1           => l_wt_old.RES_UTILIZATION_PERCENTAGE
                ,X_ATTRIBUTE2           => l_wt_old.ORG_UTILIZATION_PERCENTAGE
                ,X_ATTRIBUTE3           => l_wt_old.BILLABLE_CAPITALIZABLE_FLAG
                ,X_ATTRIBUTE4           => l_wt_old.REDUCE_CAPACITY_FLAG
                ,X_ATTRIBUTE5           => l_wt_old.TRAINING_FLAG
                ,X_ATTRIBUTE6           => l_wt_old.UNASSIGNED_FLAG
                ,X_ATTRIBUTE7           => l_wt_old.TP_AMT_TYPE_CODE
                ,X_ATTRIBUTE8           => to_char(l_wt_old.START_DATE_ACTIVE,'YYYY/MM/DD')/* Bug fix:2428599 */
                ,X_ATTRIBUTE9           => to_char(l_wt_old.END_DATE_ACTIVE,'YYYY/MM/DD') /* Bug fix:2428599 */
                ,X_ATTRIBUTE10          => l_wt_old.RES_UTIL_CATEGORY_ID
                ,X_ATTRIBUTE11          => l_wt_old.ORG_UTIL_CATEGORY_ID
                ,X_ATTRIBUTE12          => NULL
                ,X_ATTRIBUTE13          => NULL
                ,X_ATTRIBUTE14          => NULL
                ,X_ATTRIBUTE15          => NULL
                ,X_ATTRIBUTE16          => NULL
                ,X_ATTRIBUTE17          => NULL
                ,X_ATTRIBUTE18          => NULL
                ,X_ATTRIBUTE19          => NULL
                ,X_ATTRIBUTE20          => NULL
		 );
        End If;
    End IF; -- end of curosr fetch
    CLOSE old_worktype_values;
    /** End of PJI changes **/

  if (l_sql_rowcount <= 0 ) then
    raise no_data_found;
  end if;

  delete from PA_WORK_TYPES_B
  where WORK_TYPE_ID = X_WORK_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

EXCEPTION
	WHEN OTHERS THEN
		If old_worktype_values%isopen then
			close old_worktype_values;
		End if;
		RAISE;

end DELETE_ROW;

procedure ADD_LANGUAGE
is

begin

  delete from PA_WORK_TYPES_TL T
  where not exists
    (select NULL
    from PA_WORK_TYPES_B B
    where B.WORK_TYPE_ID = T.WORK_TYPE_ID
    );

  update PA_WORK_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PA_WORK_TYPES_TL B
    where B.WORK_TYPE_ID = T.WORK_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WORK_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WORK_TYPE_ID,
      SUBT.LANGUAGE
    from PA_WORK_TYPES_TL SUBB, PA_WORK_TYPES_TL SUBT
    where SUBB.WORK_TYPE_ID = SUBT.WORK_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PA_WORK_TYPES_TL (
    WORK_TYPE_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.WORK_TYPE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_WORK_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_WORK_TYPES_TL T
    where T.WORK_TYPE_ID = B.WORK_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PA_WORK_TYPES_PKG;

/
