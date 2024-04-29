--------------------------------------------------------
--  DDL for Package Body AMW_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CONTROLS_PKG" as
/* $Header: amwcnthb.pls 120.0 2005/05/31 19:34:11 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CONTROL_REV_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LATEST_REVISION_FLAG in VARCHAR2,
  X_REQUESTOR_ID in NUMBER,
  X_CONTROL_ID in NUMBER,
  X_APPROVAL_STATUS in VARCHAR2,
  X_AUTOMATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_JOB_ID in NUMBER,
  X_CREATED_BY_MODULE in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CONTROL_LOCATION in VARCHAR2,
  X_REV_NUM in NUMBER,
  X_APPROVAL_DATE in DATE,
  X_CONTROL_TYPE in VARCHAR2,
  X_CATEGORY in VARCHAR2,
  X_SOURCE in VARCHAR2,
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
  X_END_DATE in DATE,
  X_CURR_APPROVED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PHYSICAL_EVIDENCE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_preventive_control in varchar2 := null,
  x_detective_control in varchar2 := null,
  x_disclosure_control in varchar2 := null,
  x_key_mitigating in varchar2 := null,
  x_verification_source in varchar2 := null,
  x_verification_source_name in varchar2 := null,
  x_verification_instruction in varchar2 := null,
  x_uom_code in varchar2 := null,
  x_control_frequency in number := NULL,
  ---NPANANDI 12.10.2004: ADDED BELOW FOR CTRL CLASSIFICATION
  x_classification IN NUMBER DEFAULT NULL
) is
  cursor C is select ROWID from AMW_CONTROLS_B
    where CONTROL_REV_ID = X_CONTROL_REV_ID
    ;
begin
  insert into AMW_CONTROLS_B (
    OBJECT_VERSION_NUMBER,
    CONTROL_REV_ID,
    ORIG_SYSTEM_REFERENCE,
    LATEST_REVISION_FLAG,
    REQUESTOR_ID,
    CONTROL_ID,
    APPROVAL_STATUS,
    AUTOMATION_TYPE,
    APPLICATION_ID,
    JOB_ID,
    CREATED_BY_MODULE,
    ATTRIBUTE14,
    ATTRIBUTE13,
    ATTRIBUTE15,
    SECURITY_GROUP_ID,
    CONTROL_LOCATION,
    REV_NUM,
    APPROVAL_DATE,
    CONTROL_TYPE,
    CATEGORY,
    SOURCE,
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
    END_DATE,
    CURR_APPROVED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
	preventive_control,
	detective_control,
	disclosure_control,
    key_mitigating,
	verification_source,
	uom_code,
	control_frequency,
	---npanandi 12.10.2004: added below for Ctrl Classification
    classification
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_CONTROL_REV_ID,
    X_ORIG_SYSTEM_REFERENCE,
    X_LATEST_REVISION_FLAG,
    X_REQUESTOR_ID,
    X_CONTROL_ID,
    X_APPROVAL_STATUS,
    X_AUTOMATION_TYPE,
    X_APPLICATION_ID,
    X_JOB_ID,
    X_CREATED_BY_MODULE,
    X_ATTRIBUTE14,
    X_ATTRIBUTE13,
    X_ATTRIBUTE15,
    X_SECURITY_GROUP_ID,
    X_CONTROL_LOCATION,
    X_REV_NUM,
    X_APPROVAL_DATE,
    X_CONTROL_TYPE,
    X_CATEGORY,
    X_SOURCE,
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
    X_END_DATE,
    X_CURR_APPROVED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
	x_preventive_control,
	x_detective_control,
	x_disclosure_control,
    x_key_mitigating,
	x_verification_source,
	X_UOM_CODE,
	X_CONTROL_FREQUENCY,
	---npanandi 12.10.2004: added below for Ctrl Classification
    x_classification
  );

  insert into AMW_CONTROLS_TL (
    CONTROL_REV_ID,
    NAME,
    DESCRIPTION,
    PHYSICAL_EVIDENCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG,
    verification_source_name,
    verification_instruction
  ) select
    X_CONTROL_REV_ID,
    X_NAME,
    X_DESCRIPTION,
    X_PHYSICAL_EVIDENCE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    x_verification_source_name,
    x_verification_instruction
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_CONTROLS_TL T
    where T.CONTROL_REV_ID = X_CONTROL_REV_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CONTROL_REV_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LATEST_REVISION_FLAG in VARCHAR2,
  X_REQUESTOR_ID in NUMBER,
  X_CONTROL_ID in NUMBER,
  X_APPROVAL_STATUS in VARCHAR2,
  X_AUTOMATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_JOB_ID in NUMBER,
  X_CREATED_BY_MODULE in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CONTROL_LOCATION in VARCHAR2,
  X_REV_NUM in NUMBER,
  X_APPROVAL_DATE in DATE,
  X_CONTROL_TYPE in VARCHAR2,
  X_CATEGORY in VARCHAR2,
  X_SOURCE in VARCHAR2,
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
  X_END_DATE in DATE,
  X_CURR_APPROVED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PHYSICAL_EVIDENCE in VARCHAR2,
  x_preventive_control in varchar2,
  x_detective_control in varchar2,
  x_disclosure_control in varchar2,
  x_key_mitigating in varchar2,
  x_verification_source in varchar2,
  x_verification_source_name in varchar2,
  x_verification_instruction in varchar2,
  x_uom_code in varchar2,
  x_control_frequency in number,
  ---npanandi 12.10.2004: added below for Ctrl Classification
  x_classification in number
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ORIG_SYSTEM_REFERENCE,
      LATEST_REVISION_FLAG,
      REQUESTOR_ID,
      CONTROL_ID,
      APPROVAL_STATUS,
      AUTOMATION_TYPE,
      APPLICATION_ID,
      JOB_ID,
      CREATED_BY_MODULE,
      ATTRIBUTE14,
      ATTRIBUTE13,
      ATTRIBUTE15,
      SECURITY_GROUP_ID,
      CONTROL_LOCATION,
      REV_NUM,
      APPROVAL_DATE,
      CONTROL_TYPE,
      CATEGORY,
      SOURCE,
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
      END_DATE,
      CURR_APPROVED_FLAG,
	  preventive_control,
  	  detective_control,
	  disclosure_control,
      key_mitigating,
	  verification_source,
	  UOM_CODE,
	  CONTROL_FREQUENCY,
	  ---npanandi 12.10.2004: added below for Ctrl Classification
      classification
    from AMW_CONTROLS_B
    where CONTROL_REV_ID = X_CONTROL_REV_ID
    for update of CONTROL_REV_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      PHYSICAL_EVIDENCE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG,
      verification_source_name,
      verification_instruction
    from AMW_CONTROLS_TL
    where CONTROL_REV_ID = X_CONTROL_REV_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CONTROL_REV_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE)
           OR ((recinfo.ORIG_SYSTEM_REFERENCE is null) AND (X_ORIG_SYSTEM_REFERENCE is null)))
      AND ((recinfo.LATEST_REVISION_FLAG = X_LATEST_REVISION_FLAG)
           OR ((recinfo.LATEST_REVISION_FLAG is null) AND (X_LATEST_REVISION_FLAG is null)))
      AND ((recinfo.REQUESTOR_ID = X_REQUESTOR_ID)
           OR ((recinfo.REQUESTOR_ID is null) AND (X_REQUESTOR_ID is null)))
      AND (recinfo.CONTROL_ID = X_CONTROL_ID)
      AND ((recinfo.APPROVAL_STATUS = X_APPROVAL_STATUS)
           OR ((recinfo.APPROVAL_STATUS is null) AND (X_APPROVAL_STATUS is null)))
      AND ((recinfo.AUTOMATION_TYPE = X_AUTOMATION_TYPE)
           OR ((recinfo.AUTOMATION_TYPE is null) AND (X_AUTOMATION_TYPE is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.JOB_ID = X_JOB_ID)
           OR ((recinfo.JOB_ID is null) AND (X_JOB_ID is null)))
      AND ((recinfo.CREATED_BY_MODULE = X_CREATED_BY_MODULE)
           OR ((recinfo.CREATED_BY_MODULE is null) AND (X_CREATED_BY_MODULE is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.CONTROL_LOCATION = X_CONTROL_LOCATION)
           OR ((recinfo.CONTROL_LOCATION is null) AND (X_CONTROL_LOCATION is null)))
      AND (recinfo.REV_NUM = X_REV_NUM)
      AND ((recinfo.APPROVAL_DATE = X_APPROVAL_DATE)
           OR ((recinfo.APPROVAL_DATE is null) AND (X_APPROVAL_DATE is null)))
      AND ((recinfo.CONTROL_TYPE = X_CONTROL_TYPE)
           OR ((recinfo.CONTROL_TYPE is null) AND (X_CONTROL_TYPE is null)))
      AND ((recinfo.CATEGORY = X_CATEGORY)
           OR ((recinfo.CATEGORY is null) AND (X_CATEGORY is null)))
      AND ((recinfo.SOURCE = X_SOURCE)
           OR ((recinfo.SOURCE is null) AND (X_SOURCE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
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
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
	  AND ((recinfo.preventive_control = X_preventive_control)
           OR ((recinfo.preventive_control is null) AND (X_preventive_control is null)))
      AND ((recinfo.detective_control = X_detective_control)
           OR ((recinfo.detective_control is null) AND (X_detective_control is null)))
 	  AND ((recinfo.disclosure_control = X_disclosure_control)
           OR ((recinfo.disclosure_control is null) AND (X_disclosure_control is null)))
      AND ((recinfo.key_mitigating = X_key_mitigating)
           OR ((recinfo.key_mitigating is null) AND (X_key_mitigating is null)))
      AND ((recinfo.verification_source = X_verification_source)
           OR ((recinfo.verification_source is null) AND (X_verification_source is null)))
      AND ((recinfo.UOM_CODE = X_UOM_CODE)
           OR ((recinfo.UOM_CODE is null) AND (X_UOM_CODE is null)))
	  AND ((recinfo.CONTROL_FREQUENCY = X_CONTROL_FREQUENCY)
           OR ((recinfo.CONTROL_FREQUENCY is null) AND (X_CONTROL_FREQUENCY is null)))
      ---npanandi 12.10.2004: added below AND clause for Ctrl Classification
      AND ((recinfo.CLASSIFICATION = X_CLASSIFICATION)
           OR ((recinfo.CLASSIFICATION is null) AND (X_CLASSIFICATION is null)))
      AND ((recinfo.CURR_APPROVED_FLAG = X_CURR_APPROVED_FLAG)
           OR ((recinfo.CURR_APPROVED_FLAG is null) AND (X_CURR_APPROVED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.PHYSICAL_EVIDENCE = X_PHYSICAL_EVIDENCE)
               OR ((tlinfo.PHYSICAL_EVIDENCE is null) AND (X_PHYSICAL_EVIDENCE is null)))
 		  AND ((tlinfo.verification_source_name = X_verification_source_name)
               OR ((tlinfo.verification_source_name is null) AND (X_verification_source_name is null)))
 		  AND ((tlinfo.verification_instruction = X_verification_instruction)
               OR ((tlinfo.verification_instruction is null) AND (X_verification_instruction is null)))
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
  X_CONTROL_REV_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REFERENCE in VARCHAR2,
  X_LATEST_REVISION_FLAG in VARCHAR2,
  X_REQUESTOR_ID in NUMBER,
  X_CONTROL_ID in NUMBER,
  X_APPROVAL_STATUS in VARCHAR2,
  X_AUTOMATION_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_JOB_ID in NUMBER,
  X_CREATED_BY_MODULE in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CONTROL_LOCATION in VARCHAR2,
  X_REV_NUM in NUMBER,
  X_APPROVAL_DATE in DATE,
  X_CONTROL_TYPE in VARCHAR2,
  X_CATEGORY in VARCHAR2,
  X_SOURCE in VARCHAR2,
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
  X_END_DATE in DATE,
  X_CURR_APPROVED_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PHYSICAL_EVIDENCE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_preventive_control in varchar2 := null,
  x_detective_control in varchar2 := null,
  x_disclosure_control in varchar2 := null,
  x_key_mitigating in varchar2 := null,
  x_verification_source in varchar2 := null,
  x_verification_source_name in varchar2 := null,
  x_verification_instruction in varchar2 := null,
  X_UOM_CODE IN VARCHAR2 := NULL,
  X_CONTROL_FREQUENCY IN NUMBER := NULL,
  ---npanandi 12.10.2004: added below AND clause for Ctrl Classification
  X_classification IN NUMBER default null
) is
begin
  update AMW_CONTROLS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ORIG_SYSTEM_REFERENCE = X_ORIG_SYSTEM_REFERENCE,
    LATEST_REVISION_FLAG = X_LATEST_REVISION_FLAG,
    REQUESTOR_ID = X_REQUESTOR_ID,
    CONTROL_ID = X_CONTROL_ID,
    APPROVAL_STATUS = X_APPROVAL_STATUS,
    AUTOMATION_TYPE = X_AUTOMATION_TYPE,
    APPLICATION_ID = X_APPLICATION_ID,
    JOB_ID = X_JOB_ID,
    CREATED_BY_MODULE = X_CREATED_BY_MODULE,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    CONTROL_LOCATION = X_CONTROL_LOCATION,
    REV_NUM = X_REV_NUM,
    APPROVAL_DATE = X_APPROVAL_DATE,
    CONTROL_TYPE = X_CONTROL_TYPE,
    CATEGORY = X_CATEGORY,
    SOURCE = X_SOURCE,
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
    END_DATE = X_END_DATE,
    CURR_APPROVED_FLAG = X_CURR_APPROVED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	preventive_control = x_preventive_control,
	detective_control = x_detective_control,
	disclosure_control = x_disclosure_control,
	key_mitigating = x_key_mitigating,
	verification_source = x_verification_source,
	UOM_CODE = X_UOM_CODE,
	CONTROL_FREQUENCY = X_CONTROL_FREQUENCY,
	---npanandi 12.10.2004: added below for Ctrl Classification
    classification = X_classification
  where CONTROL_REV_ID = X_CONTROL_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_CONTROLS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    PHYSICAL_EVIDENCE = X_PHYSICAL_EVIDENCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
	verification_source_name = x_verification_source_name,
	verification_instruction = x_verification_instruction
  where CONTROL_REV_ID = X_CONTROL_REV_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CONTROL_REV_ID in NUMBER
) is
begin
  delete from AMW_CONTROLS_TL
  where CONTROL_REV_ID = X_CONTROL_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_CONTROLS_B
  where CONTROL_REV_ID = X_CONTROL_REV_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMW_CONTROLS_TL T
  where not exists
    (select NULL
    from AMW_CONTROLS_B B
    where B.CONTROL_REV_ID = T.CONTROL_REV_ID
    );

  update AMW_CONTROLS_TL T set (
      NAME,
      DESCRIPTION,
      PHYSICAL_EVIDENCE,
	  verification_source_name,
	  verification_instruction
    ) = (select
      B.NAME,
      B.DESCRIPTION,
      B.PHYSICAL_EVIDENCE,
	  B.verification_source_name,
	  B.verification_instruction
    from AMW_CONTROLS_TL B
    where B.CONTROL_REV_ID = T.CONTROL_REV_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CONTROL_REV_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CONTROL_REV_ID,
      SUBT.LANGUAGE
    from AMW_CONTROLS_TL SUBB, AMW_CONTROLS_TL SUBT
    where SUBB.CONTROL_REV_ID = SUBT.CONTROL_REV_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.PHYSICAL_EVIDENCE <> SUBT.PHYSICAL_EVIDENCE
      or (SUBB.PHYSICAL_EVIDENCE is null and SUBT.PHYSICAL_EVIDENCE is not null)
      or (SUBB.PHYSICAL_EVIDENCE is not null and SUBT.PHYSICAL_EVIDENCE is null)
	  or SUBB.verification_source_name <> SUBT.verification_source_name
      or (SUBB.verification_source_name is null and SUBT.verification_source_name is not null)
      or (SUBB.verification_source_name is not null and SUBT.verification_source_name is null)
	  or SUBB.verification_instruction <> SUBT.verification_instruction
      or (SUBB.verification_instruction is null and SUBT.verification_instruction is not null)
      or (SUBB.verification_instruction is not null and SUBT.verification_instruction is null)
  ));

  insert into AMW_CONTROLS_TL (
    CONTROL_REV_ID,
    NAME,
    DESCRIPTION,
    PHYSICAL_EVIDENCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG,
	verification_source_name,
	verification_instruction
  ) select
    B.CONTROL_REV_ID,
    B.NAME,
    B.DESCRIPTION,
    B.PHYSICAL_EVIDENCE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
	B.verification_source_name,
	B.verification_instruction
  from AMW_CONTROLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_CONTROLS_TL T
    where T.CONTROL_REV_ID = B.CONTROL_REV_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMW_CONTROLS_PKG;

/
