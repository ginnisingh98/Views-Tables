--------------------------------------------------------
--  DDL for Package Body BEN_EXT_FLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_FLD_PKG" as
/* $Header: bexlt01t.pkb 120.5 2006/02/15 14:53:44 tjesumic noship $ */

procedure INSERT_ROW (
  P_ROWID in out nocopy VARCHAR2,
  P_EXT_FLD_ID in NUMBER,
  P_DECD_FLAG in VARCHAR2,
  P_SHORT_NAME in VARCHAR2,
  P_FRMT_MASK_TYP_CD in VARCHAR2,
  P_CSR_CD in VARCHAR2,
  P_LVL_CD in VARCHAR2,
  P_ALWD_IN_RCD_CD in VARCHAR2,
  P_Group_lvl_cd   in VARCHAR2 default null ,
  P_BUSINESS_GROUP_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BEN_EXT_FLD
    where EXT_FLD_ID = P_EXT_FLD_ID
    ;
begin
  insert into BEN_EXT_FLD (
    EXT_FLD_ID,
    DECD_FLAG,
    SHORT_NAME,
    NAME,
    FRMT_MASK_TYP_CD,
    CSR_CD,
    LVL_CD,
    ALWD_IN_RCD_CD,
    Group_lvl_cd,
    BUSINESS_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    P_EXT_FLD_ID,
    P_DECD_FLAG,
    P_SHORT_NAME,
    P_NAME,
    P_FRMT_MASK_TYP_CD,
    P_CSR_CD,
    P_LVL_CD,
    P_ALWD_IN_RCD_CD,
    P_Group_lvl_cd,
    P_BUSINESS_GROUP_ID,
    P_OBJECT_VERSION_NUMBER,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
    from dual
    where  not exists
    ( select
      'x'  from
      ben_ext_fld
      where short_name = p_short_name
     );


  insert into BEN_EXT_FLD_TL (
    EXT_FLD_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_EXT_FLD_ID,
    P_NAME,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_CREATED_BY,
    P_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BEN_EXT_FLD_TL T
    where T.EXT_FLD_ID = P_EXT_FLD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_EXT_FLD_ID in NUMBER,
  P_DECD_FLAG in VARCHAR2,
  P_SHORT_NAME in VARCHAR2,
  P_FRMT_MASK_TYP_CD in VARCHAR2,
  P_CSR_CD in VARCHAR2,
  P_LVL_CD in VARCHAR2,
  P_ALWD_IN_RCD_CD in VARCHAR2,
  P_BUSINESS_GROUP_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_NAME in VARCHAR2
) is
  cursor c is select
      DECD_FLAG,
      SHORT_NAME,
      FRMT_MASK_TYP_CD,
      CSR_CD,
      LVL_CD,
      ALWD_IN_RCD_CD,
      BUSINESS_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from BEN_EXT_FLD
    where EXT_FLD_ID = P_EXT_FLD_ID
    for update of EXT_FLD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BEN_EXT_FLD_TL
    where EXT_FLD_ID = P_EXT_FLD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of EXT_FLD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DECD_FLAG = P_DECD_FLAG)
      AND ((recinfo.SHORT_NAME = P_SHORT_NAME)
           OR ((recinfo.SHORT_NAME is null) AND (P_SHORT_NAME is null)))
      AND ((recinfo.FRMT_MASK_TYP_CD = P_FRMT_MASK_TYP_CD)
           OR ((recinfo.FRMT_MASK_TYP_CD is null) AND (P_FRMT_MASK_TYP_CD is null)))
      AND ((recinfo.CSR_CD = P_CSR_CD)
           OR ((recinfo.CSR_CD is null) AND (P_CSR_CD is null)))
      AND ((recinfo.LVL_CD = P_LVL_CD)
           OR ((recinfo.LVL_CD is null) AND (P_LVL_CD is null)))
      AND ((recinfo.ALWD_IN_RCD_CD = P_ALWD_IN_RCD_CD)
           OR ((recinfo.ALWD_IN_RCD_CD is null) AND (P_ALWD_IN_RCD_CD is null)))
      AND ((recinfo.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID)
           OR ((recinfo.BUSINESS_GROUP_ID is null) AND (P_BUSINESS_GROUP_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (P_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = P_NAME)
               OR ((tlinfo.NAME is null) AND (P_NAME is null)))
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
  P_EXT_FLD_ID in NUMBER,
  P_DECD_FLAG in VARCHAR2,
  P_SHORT_NAME in VARCHAR2,
  P_FRMT_MASK_TYP_CD in VARCHAR2,
  P_CSR_CD in VARCHAR2,
  P_LVL_CD in VARCHAR2,
  P_ALWD_IN_RCD_CD in VARCHAR2,
  P_Group_lvl_cd  in VARCHAR2 default null,
  P_BUSINESS_GROUP_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BEN_EXT_FLD set
    DECD_FLAG = P_DECD_FLAG,
    SHORT_NAME = P_SHORT_NAME,
    NAME = P_NAME,
    FRMT_MASK_TYP_CD = P_FRMT_MASK_TYP_CD,
    CSR_CD = P_CSR_CD,
    LVL_CD = P_LVL_CD,
    ALWD_IN_RCD_CD = P_ALWD_IN_RCD_CD,
    Group_lvl_cd = P_Group_lvl_cd,
    BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where EXT_FLD_ID = P_EXT_FLD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BEN_EXT_FLD_TL set
    NAME = P_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where EXT_FLD_ID = P_EXT_FLD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_EXT_FLD_ID in NUMBER
) is
begin
  delete from BEN_EXT_FLD_TL
  where EXT_FLD_ID = P_EXT_FLD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BEN_EXT_FLD
  where EXT_FLD_ID = P_EXT_FLD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BEN_EXT_FLD_TL T
  where not exists
    (select NULL
    from BEN_EXT_FLD B
    where B.EXT_FLD_ID = T.EXT_FLD_ID
    );

  update BEN_EXT_FLD_TL T set (
      NAME
    ) = (select
      B.NAME
    from BEN_EXT_FLD_TL B
    where B.EXT_FLD_ID = T.EXT_FLD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXT_FLD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXT_FLD_ID,
      SUBT.LANGUAGE
    from BEN_EXT_FLD_TL SUBB, BEN_EXT_FLD_TL SUBT
    where SUBB.EXT_FLD_ID = SUBT.EXT_FLD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into BEN_EXT_FLD_TL (
    EXT_FLD_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.EXT_FLD_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BEN_EXT_FLD_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BEN_EXT_FLD_TL T
    where T.EXT_FLD_ID = B.EXT_FLD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BEN_EXT_FLD_PKG;



/
