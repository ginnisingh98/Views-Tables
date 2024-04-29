--------------------------------------------------------
--  DDL for Package Body QP_PB_INPUT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PB_INPUT_LINES_PKG" as
/* $Header: QPXUPBLB.pls 120.1 2005/10/07 06:01:22 prarasto noship $ */

procedure INSERT_ROW (
	X_ROWID in out nocopy VARCHAR2,
	X_PB_INPUT_LINE_ID in NUMBER,
	X_PB_INPUT_HEADER_ID in NUMBER,
	X_CREATION_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_CONTEXT in VARCHAR2,
	X_ATTRIBUTE in VARCHAR2,
	X_ATTRIBUTE_VALUE in VARCHAR2,
	X_ATTRIBUTE_TYPE in VARCHAR2,
	X_CONTEXT_NAME in VARCHAR2,
	X_ATTRIBUTE_NAME in VARCHAR2,
	X_ATTRIBUTE_VALUE_NAME in VARCHAR2,
	X_ATTRIBUTE_TYPE_VALUE in VARCHAR2
) is
  cursor C is select ROWID from QP_PB_INPUT_LINES
  where PB_INPUT_LINE_ID = X_PB_INPUT_LINE_ID;

begin
   insert into QP_PB_INPUT_LINES(
	PB_INPUT_LINE_ID,
	PB_INPUT_HEADER_ID,
	CONTEXT,
	ATTRIBUTE,
	ATTRIBUTE_VALUE,
	ATTRIBUTE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
	X_PB_INPUT_LINE_ID,
	X_PB_INPUT_HEADER_ID,
	X_CONTEXT,
	X_ATTRIBUTE,
	X_ATTRIBUTE_VALUE,
	X_ATTRIBUTE_TYPE,
	X_CREATION_DATE,
	X_CREATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
	X_PB_INPUT_LINE_ID in NUMBER,
	X_PB_INPUT_HEADER_ID in NUMBER,
	X_CREATION_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_CONTEXT in VARCHAR2,
	X_ATTRIBUTE in VARCHAR2,
	X_ATTRIBUTE_VALUE in VARCHAR2,
	X_ATTRIBUTE_TYPE in VARCHAR2,
	X_CONTEXT_NAME in VARCHAR2,
	X_ATTRIBUTE_NAME in VARCHAR2,
	X_ATTRIBUTE_VALUE_NAME in VARCHAR2,
	X_ATTRIBUTE_TYPE_VALUE in VARCHAR2)
is
begin
null;
end LOCK_ROW;

procedure UPDATE_ROW (
	X_PB_INPUT_LINE_ID in NUMBER,
	X_PB_INPUT_HEADER_ID in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER,
	X_CONTEXT in VARCHAR2,
	X_ATTRIBUTE in VARCHAR2,
	X_ATTRIBUTE_VALUE in VARCHAR2,
	X_ATTRIBUTE_TYPE in VARCHAR2,
	X_CONTEXT_NAME in VARCHAR2,
	X_ATTRIBUTE_NAME in VARCHAR2,
	X_ATTRIBUTE_VALUE_NAME in VARCHAR2,
	X_ATTRIBUTE_TYPE_VALUE in VARCHAR2)
is
begin
   update QP_PB_INPUT_LINES set
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	CONTEXT = X_CONTEXT,
	ATTRIBUTE = X_ATTRIBUTE,
	ATTRIBUTE_VALUE = X_ATTRIBUTE_VALUE,
	ATTRIBUTE_TYPE = X_ATTRIBUTE_TYPE
   where PB_INPUT_LINE_ID = X_PB_INPUT_LINE_ID;

end UPDATE_ROW;

procedure DELETE_ROW (
	X_PB_INPUT_LINE_ID in NUMBER
)
is
begin
  delete from QP_PB_INPUT_LINES
  where PB_INPUT_LINE_ID = X_PB_INPUT_LINE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end QP_PB_INPUT_LINES_PKG;

/
