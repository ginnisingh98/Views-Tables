--------------------------------------------------------
--  DDL for Package Body CS_SR_TYPES_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_TYPES_MAPPING_PKG" as
/* $Header: csvtmapb.pls 115.13 2003/11/06 23:45:46 aneemuch noship $ */

-- for security
 FUNCTION Check_Duplicate( p_rowid             IN ROWID,
                           p_incident_type_id  IN NUMBER,
                           p_resp_id 	       IN NUMBER,
                           p_template_type     IN VARCHAR,
                           p_application_id    IN NUMBER) RETURN BOOLEAN
  IS

    l_rowid rowid;
    CURSOR l_type_cur IS
    SELECT nvl(1,0),rowid
    FROM   CS_SR_TYPE_MAPPING
    WHERE  incident_type_id  = p_incident_type_id
    AND    responsibility_id  = p_resp_id
    AND    type 	     = p_template_type
    AND    application_id = p_application_id;

    CURSOR l_inc_cur IS
    SELECT nvl(2,0),rowid
    FROM   CS_SR_TYPE_MAPPING
    WHERE  incident_type_id  = p_incident_type_id
    AND    responsibility_id  = p_resp_id
    AND    application_id = p_application_id;

    l_value    NUMBER := 0;
    l_return   boolean := TRUE;
               -- True    There is a duplicate record.
               -- False   There is no duplicate record.

  BEGIN

    if p_template_type is not null then

       OPEN  l_type_cur;
       FETCH l_type_cur INTO l_value,l_rowid;

       if l_type_cur%NOTFOUND then
          l_return := FALSE;
       else
--bug 2942245 to avoid the same record to undergo duplicate checking
          if l_rowid = p_rowid and p_rowid is not null then
             l_return := FALSE;
          end if;
       end if;

       CLOSE l_type_cur;

    elsif p_template_type is null then

       OPEN  l_inc_cur;
       FETCH l_inc_cur INTO l_value,l_rowid;

       if l_inc_cur%NOTFOUND then
          l_return := FALSE;
       else
--bug 2942245 to avoid the same record to undergo duplicate checking
          if l_rowid = p_rowid and p_rowid is not null then
             l_return := FALSE;
          end if;
       end if;

       CLOSE l_inc_cur;

    end if;

--bug 2942245 to avoid the same record to undergo duplicate checking
    if l_value = 0 then
       l_return := FALSE;
    end if;

    return l_return;

END Check_Duplicate;

procedure INSERT_ROW(
  X_ROWID in out NOCOPY VARCHAR2,
  X_INCIDENT_TYPE_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_TEMPLATE_ID	in NUMBER,
  X_TYPE  in VARCHAR2,
  X_START_DATE  in DATE 	,
  X_END_DATE  in DATE 	,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_STATUS_GROUP_ID in NUMBER,
   -- for security
  X_APPLICATION_ID in NUMBER,
  X_BUSINESS_USAGE in VARCHAR2) is
  cursor C is select ROWID from CS_SR_TYPE_MAPPING
    where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID and
          RESPONSIBILITY_ID = X_RESPONSIBILITY_ID and
          APPLICATION_ID = X_APPLICATION_ID;

  G_EXP_DUP_RECORD        EXCEPTION;

begin

 if NOT Check_Duplicate( p_rowid             => null,
                         p_incident_type_id  => x_incident_type_id,
                         p_resp_id 	     => x_responsibility_id,
                         p_template_type     => x_type,
                         p_application_id    => x_application_id)
  then
  insert into CS_SR_TYPE_MAPPING(
        INCIDENT_TYPE_ID,
        RESPONSIBILITY_ID,
        TEMPLATE_ID,
        TYPE,
        START_DATE      ,
 	END_DATE   	,
 	SEEDED_FLAG	,
 	ATTRIBUTE1	,
 	ATTRIBUTE2	,
 	ATTRIBUTE3	,
 	ATTRIBUTE4	,
 	ATTRIBUTE5	,
 	ATTRIBUTE6	,
 	ATTRIBUTE7	,
 	ATTRIBUTE8	,
 	ATTRIBUTE9	,
 	ATTRIBUTE10	,
 	ATTRIBUTE11	,
 	ATTRIBUTE12	,
 	ATTRIBUTE13	,
 	ATTRIBUTE14	,
 	ATTRIBUTE15	,
 	ATTRIBUTE_CATEGORY,
 	CREATION_DATE 	,
 	CREATED_BY  	,
 	LAST_UPDATE_DATE ,
 	LAST_UPDATED_BY ,
 	LAST_UPDATE_LOGIN ,
 	OBJECT_VERSION_NUMBER,
	STATUS_GROUP_ID,
	-- for security
	APPLICATION_ID,
	BUSINESS_USAGE
  ) values (
    X_INCIDENT_TYPE_ID ,
    X_RESPONSIBILITY_ID,
    X_TEMPLATE_ID,
    X_TYPE,
    X_START_DATE 	,
    X_END_DATE  	,
    X_SEEDED_FLAG	,
    X_ATTRIBUTE1	,
    X_ATTRIBUTE2	,
    X_ATTRIBUTE3	,
    X_ATTRIBUTE4	,
    X_ATTRIBUTE5	,
    X_ATTRIBUTE6	,
    X_ATTRIBUTE7	,
    X_ATTRIBUTE8	,
    X_ATTRIBUTE9	,
    X_ATTRIBUTE10	,
    X_ATTRIBUTE11	,
    X_ATTRIBUTE12	,
    X_ATTRIBUTE13	,
    X_ATTRIBUTE14	,
    X_ATTRIBUTE15	,
    X_ATTRIBUTE_CATEGORY,
    X_CREATION_DATE	,
    X_CREATED_BY	,
    X_LAST_UPDATE_DATE	,
    X_LAST_UPDATED_BY	,
    1			,
    1,
    X_STATUS_GROUP_ID,
    -- for security
    X_APPLICATION_ID,
    X_BUSINESS_USAGE
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  else
    raise G_EXP_DUP_RECORD;
  end if;

Exception

  when G_EXP_DUP_RECORD then
    --x_return_status := G_RET_STS_ERROR;
    Fnd_Message.Set_Name('CS', 'CS_ALL_DUPLICATE_RECORD');
    Fnd_Msg_Pub.Add;

  When Others then
    app_exception.raise_exception('ERROR','12',SQLERRM);

end INSERT_ROW;

 procedure LOCK_ROW (
  X_INCIDENT_TYPE_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ROWID OUT NOCOPY VARCHAR2,
  -- for security
  X_APPLICATION_ID in NUMBER
) is
  cursor c is select
        ROWID,OBJECT_VERSION_NUMBER
    from CS_SR_TYPE_MAPPING
    where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
    and RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and APPLICATION_ID = X_APPLICATION_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of OBJECT_VERSION_NUMBER nowait;
  recinfo c%rowtype;


begin
  open c;
  fetch c into recinfo;
  x_rowid := recinfo.rowid;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;


procedure UPDATE_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INCIDENT_TYPE_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_TEMPLATE_ID	in NUMBER,
  X_TYPE  in VARCHAR2,
  X_START_DATE  in DATE 	,
  X_END_DATE  in DATE 	,
  X_SEEDED_FLAG in VARCHAR2,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_STATUS_GROUP_ID in NUMBER,
  -- for security
  X_APPLICATION_ID in NUMBER,
  X_BUSINESS_USAGE in VARCHAR2)
 is

  G_EXP_DUP_RECORD        EXCEPTION;
begin

 if NOT Check_Duplicate( p_rowid             => x_rowid,
                         p_incident_type_id  => x_incident_type_id,
                         p_resp_id 	     => x_responsibility_id,
                         p_template_type     => x_type,
                         p_application_id    => x_application_id)
  then
  update CS_SR_TYPE_MAPPING set
    INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID ,
    RESPONSIBILITY_ID = X_RESPONSIBILITY_ID,
    TEMPLATE_ID = X_TEMPLATE_ID,
    TYPE = X_TYPE,
    START_DATE = X_START_DATE 	,
    END_DATE = X_END_DATE  	,
    SEEDED_FLAG = X_SEEDED_FLAG,
    OBJECT_VERSION_NUMBER =  X_OBJECT_VERSION_NUMBER +1,
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
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	STATUS_GROUP_ID = X_STATUS_GROUP_ID ,
	-- for security
	APPLICATION_ID = X_APPLICATION_ID,
	BUSINESS_USAGE = X_BUSINESS_USAGE
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  else
    raise G_EXP_DUP_RECORD;
  end if;

Exception
  when G_EXP_DUP_RECORD then
    --x_return_status := G_RET_STS_ERROR;
    Fnd_Message.Set_Name('CS', 'CS_ALL_DUPLICATE_RECORD');
    Fnd_Msg_Pub.Add;

  When Others then
    app_exception.raise_exception('ERROR','12',SQLERRM);

end UPDATE_ROW;

procedure DELETE_ROW (
  X_INCIDENT_TYPE_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  -- for security
  X_APPLICATION_ID in NUMBER
) is
begin
  delete from CS_SR_TYPE_MAPPING
  where INCIDENT_TYPE_ID = X_INCIDENT_TYPE_ID
    and RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

Exception
  When Others then
    app_exception.raise_exception('ERROR','12',SQLERRM);

 end DELETE_ROW;

end CS_SR_TYPES_MAPPING_PKG;

/
