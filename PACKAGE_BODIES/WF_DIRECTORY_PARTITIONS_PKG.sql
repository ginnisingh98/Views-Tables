--------------------------------------------------------
--  DDL for Package Body WF_DIRECTORY_PARTITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIRECTORY_PARTITIONS_PKG" as
/* $Header: wfdpb.pls 120.2.12010000.2 2011/04/28 19:55:24 vshanmug ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor C is select ROWID from WF_DIRECTORY_PARTITIONS
    where ORIG_SYSTEM = X_ORIG_SYSTEM
    ;
begin
  begin
    insert into WF_DIRECTORY_PARTITIONS (
      PARTITION_ID,
      ORIG_SYSTEM
    ) values (
      X_PARTITION_ID,
      X_ORIG_SYSTEM
    );
  exception
    -- handle a special case where translated data may not have been uploaded
    -- e.g. the first time tl table is created.
    when DUP_VAL_ON_INDEX then
      null;
  end;

  insert into WF_DIRECTORY_PARTITIONS_TL (
    ORIG_SYSTEM,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ORIG_SYSTEM,
    X_DISPLAY_NAME,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from WF_DIRECTORY_PARTITIONS_TL T
    where T.ORIG_SYSTEM = X_ORIG_SYSTEM
    and T.LANGUAGE = L.CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg','Insert_Row',x_orig_system);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      PARTITION_ID
    from WF_DIRECTORY_PARTITIONS
    where ORIG_SYSTEM = X_ORIG_SYSTEM
    for update of ORIG_SYSTEM nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WF_DIRECTORY_PARTITIONS_TL
    where ORIG_SYSTEM = X_ORIG_SYSTEM
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ORIG_SYSTEM nowait;
  tlinfo c1%rowtype;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;
  if ( ((recinfo.PARTITION_ID = X_PARTITION_ID)
       OR ((recinfo.PARTITION_ID is null) AND (X_PARTITION_ID is null)))
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ( (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
      ) then
        null;
      else
        wf_core.raise('WF_RECORD_CHANGED');
      end if;
    end if;
  end loop;
  return;

exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg', 'Lock_Row', x_orig_system);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
begin
  update WF_DIRECTORY_PARTITIONS set
    PARTITION_ID = X_PARTITION_ID
  where ORIG_SYSTEM = X_ORIG_SYSTEM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WF_DIRECTORY_PARTITIONS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    SOURCE_LANG = userenv('LANG')
  where ORIG_SYSTEM = X_ORIG_SYSTEM
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg','Update_Row',x_orig_system);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ORIG_SYSTEM in VARCHAR2
) is
begin
  delete from WF_DIRECTORY_PARTITIONS_TL
  where ORIG_SYSTEM = X_ORIG_SYSTEM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WF_DIRECTORY_PARTITIONS
  where ORIG_SYSTEM = X_ORIG_SYSTEM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg','Delete_Row',x_orig_system);
    raise;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WF_DIRECTORY_PARTITIONS_TL T
  where not exists
    (select NULL
    from WF_DIRECTORY_PARTITIONS B
    where B.ORIG_SYSTEM = T.ORIG_SYSTEM
    );

  update WF_DIRECTORY_PARTITIONS_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from WF_DIRECTORY_PARTITIONS_TL B
    where B.ORIG_SYSTEM = T.ORIG_SYSTEM
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ORIG_SYSTEM,
      T.LANGUAGE
  ) in (select
      SUBT.ORIG_SYSTEM,
      SUBT.LANGUAGE
    from WF_DIRECTORY_PARTITIONS_TL SUBB, WF_DIRECTORY_PARTITIONS_TL SUBT
    where SUBB.ORIG_SYSTEM = SUBT.ORIG_SYSTEM
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
  ));

  insert into WF_DIRECTORY_PARTITIONS_TL (
    ORIG_SYSTEM,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ORIG_SYSTEM,
    B.DISPLAY_NAME,
    L.CODE,
    B.SOURCE_LANG
  from WF_DIRECTORY_PARTITIONS_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WF_DIRECTORY_PARTITIONS_TL T
    where T.ORIG_SYSTEM = B.ORIG_SYSTEM
    and T.LANGUAGE = L.CODE);

exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg', 'Add_Language');
    raise;
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_PARTITION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
)
is
  l_rowid       varchar2(30);
  l_orig_system varchar2(30);
begin
  begin
     wf_directory_partitions_pkg.Update_row(
         X_ORIG_SYSTEM => l_orig_system,
         X_PARTITION_ID => X_PARTITION_ID,
         X_DISPLAY_NAME => X_DISPLAY_NAME);
  exception
     when NO_DATA_FOUND then
        wf_directory_partitions_pkg.Insert_Row(
            X_ROWID => l_rowid,
            X_ORIG_SYSTEM => X_ORIG_SYSTEM,
            X_PARTITION_ID => X_PARTITION_ID,
            X_DISPLAY_NAME => X_DISPLAY_NAME);
  end;
exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg','Load_Row',x_orig_system);
    raise;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_ORIG_SYSTEM in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2
)
is
begin
  update WF_DIRECTORY_PARTITIONS_TL
  set    DISPLAY_NAME = X_DISPLAY_NAME,
         SOURCE_LANG = userenv('LANG')
  where  ORIG_SYSTEM = X_ORIG_SYSTEM
  and    userenv('LANG') in (language, source_lang);
exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg','Translate_Row',x_orig_system);
    raise;
end TRANSLATE_ROW;

--<rwunderl:2901155>
procedure UPDATE_VIEW_NAMES (
  X_ORIG_SYSTEM    in VARCHAR2,
  X_PARTITION_ID   in NUMBER,
  X_ROLE_VIEW      in VARCHAR2,
  X_USER_ROLE_VIEW in VARCHAR2,
  X_ROLE_TL_VIEW   in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE
) is
begin
  update WF_DIRECTORY_PARTITIONS wdp
  set
    wdp.ROLE_VIEW        = nvl(X_ROLE_VIEW, wdp.ROLE_VIEW),
    wdp.USER_ROLE_VIEW   = nvl(X_USER_ROLE_VIEW, wdp.USER_ROLE_VIEW),
    wdp.ROLE_TL_VIEW     = nvl(X_ROLE_TL_VIEW, wdp.ROLE_TL_VIEW),
    wdp.LAST_UPDATE_DATE = nvl(X_LAST_UPDATE_DATE, trunc(sysdate))
  where wdp.ORIG_SYSTEM  = X_ORIG_SYSTEM
  and   wdp.PARTITION_ID = X_PARTITION_ID;

  if (sql%notfound and X_ORIG_SYSTEM <> 'PER') then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Directory_Partitions_Pkg','Update_View_Names',
                    x_orig_system);
    raise;
end UPDATE_VIEW_NAMES;

end WF_DIRECTORY_PARTITIONS_PKG;

/
