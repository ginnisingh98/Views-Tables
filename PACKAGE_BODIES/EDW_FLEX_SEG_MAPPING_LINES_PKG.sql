--------------------------------------------------------
--  DDL for Package Body EDW_FLEX_SEG_MAPPING_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_FLEX_SEG_MAPPING_LINES_PKG" as
/* $Header: EDWFMLIB.pls 115.3 99/07/17 16:18:35 porting ship  $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_SEG_MAPPING_LINE_ID in NUMBER,
  X_INSTANCE_CODE in VARCHAR2,
  X_STRUCTURE_NUM in NUMBER,
  X_STRUCTURE_NAME in VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_SEGMENT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_LEVEL_ID  in NUMBER,
  X_WH_DIMENSION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

 cursor C is select ROWID from BIS_FLEX_SEG_MAPPING_LINES
    where seg_mapping_line_id = X_seg_mapping_line_id;


begin
  insert into BIS_FLEX_SEG_MAPPING_LINES (
    SEG_MAPPING_LINE_ID,
    INSTANCE_CODE,
    STRUCTURE_NUM,
    STRUCTURE_NAME,
    VALUE_SET_ID,
    SEGMENT_NAME,
    APPLICATION_ID,
    ID_FLEX_CODE,
    APPLICATION_COLUMN_NAME,
    DIMENSION_ID,
    LEVEL_ID,
    WH_DIMENSION_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SEG_MAPPING_LINE_ID,
    X_INSTANCE_CODE,
    X_STRUCTURE_NUM,
    X_STRUCTURE_NAME,
    X_VALUE_SET_ID,
    X_SEGMENT_NAME,
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_APPLICATION_COLUMN_NAME,
    X_DIMENSION_ID ,
    X_LEVEL_ID  ,
    X_WH_DIMENSION_NAME ,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
  X_SEG_MAPPING_LINE_ID in NUMBER,
  X_INSTANCE_CODE in VARCHAR2,
  X_STRUCTURE_NUM in NUMBER,
  X_STRUCTURE_NAME in VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_SEGMENT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_LEVEL_ID  in NUMBER,
  X_WH_DIMENSION_NAME in VARCHAR2
) is
  cursor c is select
      INSTANCE_CODE,
      STRUCTURE_NUM,
      STRUCTURE_NAME,
      VALUE_SET_ID,
      SEGMENT_NAME,
      APPLICATION_ID,
      ID_FLEX_CODE,
      DIMENSION_ID,
      LEVEL_ID,
      WH_DIMENSION_NAME
    from BIS_FLEX_SEG_MAPPING_LINES
    where seg_mapping_line_id = X_seg_mapping_line_id
    for update of SEG_MAPPING_LINE_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (nvl(recinfo.INSTANCE_CODE, 'AA') = nvl(X_INSTANCE_CODE, 'AA'))
      AND (nvl(recinfo.STRUCTURE_NUM, 1) = nvl(X_STRUCTURE_NUM, 1))
      AND (recinfo.STRUCTURE_NAME = X_STRUCTURE_NAME)
      AND (nvl(recinfo.VALUE_SET_ID, 1) = nvl(X_VALUE_SET_ID, 1))
      AND (recinfo.SEGMENT_NAME = X_SEGMENT_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.ID_FLEX_CODE = X_ID_FLEX_CODE)
      AND(recinfo.DIMENSION_ID   = X_DIMENSION_ID)
      AND (recinfo.LEVEL_ID      = X_LEVEL_ID)
      AND (nvl(recinfo.WH_DIMENSION_NAME, 'AA') = nvl(X_WH_DIMENSION_NAME, 'AA'))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SEG_MAPPING_LINE_ID in NUMBER,
  X_INSTANCE_CODE in VARCHAR2,
  X_STRUCTURE_NUM in NUMBER,
  X_STRUCTURE_NAME in VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_SEGMENT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_LEVEL_ID  in NUMBER,
  X_WH_DIMENSION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BIS_FLEX_SEG_MAPPING_LINES set
    INSTANCE_CODE = X_INSTANCE_CODE,
    STRUCTURE_NUM = X_STRUCTURE_NUM,
    STRUCTURE_NAME = X_STRUCTURE_NAME,
    VALUE_SET_ID = X_VALUE_SET_ID,
    SEGMENT_NAME = X_SEGMENT_NAME,
    APPLICATION_ID = X_APPLICATION_ID,
    ID_FLEX_CODE = X_ID_FLEX_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME,
    DIMENSION_ID	 = X_DIMENSION_ID,
    LEVEL_ID		 = X_LEVEL_ID,
    WH_DIMENSION_NAME    = X_WH_DIMENSION_NAME
    where seg_mapping_line_id = X_seg_mapping_line_id;



  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_SEG_MAPPING_LINE_ID in NUMBER
) is
begin
  delete from BIS_FLEX_SEG_MAPPING_LINES
    where seg_mapping_line_id = X_seg_mapping_line_id;


  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end EDW_FLEX_SEG_MAPPING_LINES_PKG;

/
