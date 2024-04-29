--------------------------------------------------------
--  DDL for Package Body XDO_FONT_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_FONT_MAPPINGS_PKG" as
/* $Header: XDOFNTMB.pls 120.0 2005/09/01 20:26:18 bokim noship $ */


procedure INSERT_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_BASE_FONT in VARCHAR2,
          P_STYLE in VARCHAR2,
          P_WEIGHT in VARCHAR2,
          P_LANGUAGE in VARCHAR2,
          P_TERRITORY in VARCHAR2,
          P_TARGET_FONT_TYPE in VARCHAR2,
          P_TARGET_FONT in VARCHAR2,
          P_TTC_NUMBER in NUMBER,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into XDO_FONT_MAPPINGS (
                                 MAPPING_CODE,
                                 BASE_FONT,
                                 STYLE,
                                 WEIGHT,
                                 LANGUAGE,
                                 TERRITORY,
                                 TARGET_FONT_TYPE,
                                 TARGET_FONT,
                                 TTC_NUMBER,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_LOGIN
  ) values (
            P_MAPPING_CODE,
            P_BASE_FONT,
            P_STYLE,
            P_WEIGHT,
            P_LANGUAGE,
            P_TERRITORY,
            P_TARGET_FONT_TYPE,
            P_TARGET_FONT,
            P_TTC_NUMBER,
            P_CREATION_DATE,
            P_CREATED_BY,
            P_LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN
  );
end INSERT_ROW;


procedure UPDATE_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_BASE_FONT in VARCHAR2,
          P_STYLE in VARCHAR2,
          P_WEIGHT in VARCHAR2,
          P_LANGUAGE in VARCHAR2,
          P_TERRITORY in VARCHAR2,
          P_TARGET_FONT_TYPE in VARCHAR2,
          P_TARGET_FONT in VARCHAR2,
          P_TTC_NUMBER in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_FONT_MAPPINGS
     set TARGET_FONT_TYPE = P_TARGET_FONT_TYPE,
         TARGET_FONT = P_TARGET_FONT,
         TTC_NUMBER = P_TTC_NUMBER,
         LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = P_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
   where MAPPING_CODE = P_MAPPING_CODE
     and BASE_FONT = P_BASE_FONT
     and STYLE = P_STYLE
     and WEIGHT = P_WEIGHT
     and LANGUAGE = P_LANGUAGE
     and TERRITORY = P_TERRITORY;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure LOAD_ROW (
          P_MAPPING_CODE in VARCHAR2,
          P_BASE_FONT in VARCHAR2,
          P_STYLE in VARCHAR2,
          P_WEIGHT in VARCHAR2,
          P_LANGUAGE in VARCHAR2,
          P_TERRITORY in VARCHAR2,
          P_TARGET_FONT_TYPE in VARCHAR2,
          P_TARGET_FONT in VARCHAR2,
          P_TTC_NUMBER in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is

begin
  begin

    UPDATE_ROW (
          P_MAPPING_CODE,
          P_BASE_FONT,
          P_STYLE,
          P_WEIGHT,
          P_LANGUAGE,
          P_TERRITORY,
          P_TARGET_FONT_TYPE,
          P_TARGET_FONT,
          P_TTC_NUMBER,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
    );

  exception when no_data_found then

    INSERT_ROW (
          P_MAPPING_CODE,
          P_BASE_FONT,
          P_STYLE,
          P_WEIGHT,
          P_LANGUAGE,
          P_TERRITORY,
          P_TARGET_FONT_TYPE,
          P_TARGET_FONT,
          P_TTC_NUMBER,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
    );

  end;

end LOAD_ROW;

end XDO_FONT_MAPPINGS_PKG;

/
