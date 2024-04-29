--------------------------------------------------------
--  DDL for Package Body AZ_SSET_TAXONOMIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_SSET_TAXONOMIES_PKG" as
/* $Header: azttaxssetb.pls 120.1 2007/12/13 08:58:26 sbandi noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAXONOMY_CODE in VARCHAR2,
  X_SELECTION_SET_CODE in VARCHAR2,
  X_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AZ_SELECTION_SET_TAXONOMIES
    where TAXONOMY_CODE = X_TAXONOMY_CODE
    and SELECTION_SET_CODE = X_SELECTION_SET_CODE;

begin
  insert into AZ_SELECTION_SET_TAXONOMIES (
	TAXONOMY_CODE,
	SELECTION_SET_CODE,
	SEQ_NUM,
	ENABLED_FLAG,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
  ) values (
	X_TAXONOMY_CODE,
	X_SELECTION_SET_CODE,
	X_SEQ_NUM,
	X_ENABLED_FLAG,
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


procedure UPDATE_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_SELECTION_SET_CODE in VARCHAR2,
  X_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AZ_SELECTION_SET_TAXONOMIES set
    SEQ_NUM = X_SEQ_NUM,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TAXONOMY_CODE = X_TAXONOMY_CODE
  and SELECTION_SET_CODE = X_SELECTION_SET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER
) is
begin
  delete from AZ_SELECTION_SET_TAXONOMIES
  where TAXONOMY_CODE = X_TAXONOMY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_SELECTION_SET_CODE in VARCHAR2,
  X_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2) IS
begin
    declare
        l_owner_id  number := 1;
        l_row_id    varchar2(64);
        luby        number := null;
    begin

     select last_updated_by into luby
     from AZ_SELECTION_SET_TAXONOMIES
     where TAXONOMY_CODE = X_TAXONOMY_CODE
     and SELECTION_SET_CODE = X_SELECTION_SET_CODE;

     if (luby = 1) THEN
         AZ_SSET_TAXONOMIES_PKG.UPDATE_ROW(
                   X_TAXONOMY_CODE => X_TAXONOMY_CODE,
                   X_SELECTION_SET_CODE => X_SELECTION_SET_CODE,
                    X_SEQ_NUM => X_SEQ_NUM,
		          X_ENABLED_FLAG => X_ENABLED_FLAG,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                );
     end if; -- if luby = 1

    exception
    when NO_DATA_FOUND then

         AZ_SSET_TAXONOMIES_PKG.INSERT_ROW(
                   X_ROWID => l_row_id,
                   X_TAXONOMY_CODE => X_TAXONOMY_CODE,
                   X_SELECTION_SET_CODE => X_SELECTION_SET_CODE,
		   X_SEQ_NUM => X_SEQ_NUM,
		   X_ENABLED_FLAG => X_ENABLED_FLAG,
                   X_CREATION_DATE => sysdate,
                   X_CREATED_BY => l_owner_id,
                   X_LAST_UPDATE_DATE => sysdate,
                   X_LAST_UPDATED_BY => l_owner_id,
                   X_LAST_UPDATE_LOGIN => 0
                 );

    end;

end LOAD_ROW;

end AZ_SSET_TAXONOMIES_PKG;

/
