--------------------------------------------------------
--  DDL for Package Body JTF_DPF_PHYSICAL_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DPF_PHYSICAL_PAGES_PKG" as
/* $Header: jtfdpfpb.pls 120.2 2005/10/25 05:17:48 psanyal ship $ */
  -- all pages which match the name and appid, and which are seed data
  cursor find_match_with_owner (p_page_name varchar2, p_application_id number,
    x_last_updated_by number) is
    select physical_page_id
      from jtf_dpf_physical_pages_b
      where physical_page_name = p_page_name and
	application_id = p_application_id and
	last_updated_by = x_last_updated_by
      order by last_update_date;

  -- same query, without the last_updated_by test
  cursor find_match(p_page_name varchar2, p_application_id number) is
    select physical_page_id
      from jtf_dpf_physical_pages_b
      where physical_page_name = p_page_name and
	application_id = p_application_id
      order by last_update_date;

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_PHYSICAL_PAGE_ID in NUMBER,
  X_PHYSICAL_PAGE_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PHYSICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_DPF_PHYSICAL_PAGES_B
    where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID
    ;
begin
  insert into JTF_DPF_PHYSICAL_PAGES_B (
    PHYSICAL_PAGE_ID,
    PHYSICAL_PAGE_NAME,
    APPLICATION_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PHYSICAL_PAGE_ID,
    X_PHYSICAL_PAGE_NAME,
    X_APPLICATION_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_DPF_PHYSICAL_PAGES_TL (
    PHYSICAL_PAGE_ID,
    PHYSICAL_PAGE_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PHYSICAL_PAGE_ID,
    X_PHYSICAL_PAGE_DESCRIPTION,
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
    from JTF_DPF_PHYSICAL_PAGES_TL T
    where T.PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID
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
  X_PHYSICAL_PAGE_ID in NUMBER,
  X_PHYSICAL_PAGE_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PHYSICAL_PAGE_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PHYSICAL_PAGE_NAME,
      APPLICATION_ID,
      OBJECT_VERSION_NUMBER
    from JTF_DPF_PHYSICAL_PAGES_B
    where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID
    for update of PHYSICAL_PAGE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PHYSICAL_PAGE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_DPF_PHYSICAL_PAGES_TL
    where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PHYSICAL_PAGE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PHYSICAL_PAGE_NAME = X_PHYSICAL_PAGE_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PHYSICAL_PAGE_DESCRIPTION = X_PHYSICAL_PAGE_DESCRIPTION)
               OR ((tlinfo.PHYSICAL_PAGE_DESCRIPTION is null) AND (X_PHYSICAL_PAGE_DESCRIPTION is null)))
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
  X_PHYSICAL_PAGE_ID in NUMBER,
  X_PHYSICAL_PAGE_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PHYSICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_DPF_PHYSICAL_PAGES_B set
    PHYSICAL_PAGE_NAME = X_PHYSICAL_PAGE_NAME,
    APPLICATION_ID = X_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_DPF_PHYSICAL_PAGES_TL set
    PHYSICAL_PAGE_DESCRIPTION = X_PHYSICAL_PAGE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PHYSICAL_PAGE_ID in NUMBER
) is
begin
  delete from JTF_DPF_PHYSICAL_PAGES_TL
  where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_DPF_PHYSICAL_PAGES_B
  where PHYSICAL_PAGE_ID = X_PHYSICAL_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_DPF_PHYSICAL_PAGES_TL T
  where not exists
    (select NULL
    from JTF_DPF_PHYSICAL_PAGES_B B
    where B.PHYSICAL_PAGE_ID = T.PHYSICAL_PAGE_ID
    );

  update JTF_DPF_PHYSICAL_PAGES_TL T set (
      PHYSICAL_PAGE_DESCRIPTION
    ) = (select
      B.PHYSICAL_PAGE_DESCRIPTION
    from JTF_DPF_PHYSICAL_PAGES_TL B
    where B.PHYSICAL_PAGE_ID = T.PHYSICAL_PAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PHYSICAL_PAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PHYSICAL_PAGE_ID,
      SUBT.LANGUAGE
    from JTF_DPF_PHYSICAL_PAGES_TL SUBB, JTF_DPF_PHYSICAL_PAGES_TL SUBT
    where SUBB.PHYSICAL_PAGE_ID = SUBT.PHYSICAL_PAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PHYSICAL_PAGE_DESCRIPTION <> SUBT.PHYSICAL_PAGE_DESCRIPTION
      or (SUBB.PHYSICAL_PAGE_DESCRIPTION is null and SUBT.PHYSICAL_PAGE_DESCRIPTION is not null)
      or (SUBB.PHYSICAL_PAGE_DESCRIPTION is not null and SUBT.PHYSICAL_PAGE_DESCRIPTION is null)
  ));

  insert into JTF_DPF_PHYSICAL_PAGES_TL (
    PHYSICAL_PAGE_ID,
    PHYSICAL_PAGE_DESCRIPTION,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PHYSICAL_PAGE_ID,
    B.PHYSICAL_PAGE_DESCRIPTION,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_DPF_PHYSICAL_PAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_DPF_PHYSICAL_PAGES_TL T
    where T.PHYSICAL_PAGE_ID = B.PHYSICAL_PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

function find_oldest_prefer_owned_by(
  x_page_name in varchar2,
  x_application_id in varchar2,
  x_last_updated_by number) return number is
  l_candidate number;
begin
  l_candidate := null;
  open find_match_with_owner(x_page_name, x_application_id,
    x_last_updated_by);
  fetch find_match_with_owner into l_candidate;
  close find_match_with_owner;

  if l_candidate is not null then return l_candidate; end if;

  open find_match(x_page_name, x_application_id);
  fetch find_match into l_candidate;
  close find_match;
  return l_candidate;
end;

procedure TRANSLATE_ROW (
  X_PAGE_NAME IN VARCHAR2,
  X_APPLICATION_ID IN VARCHAR2,
  X_PAGE_DESCRIPTION IN VARCHAR2,
  X_OWNER IN VARCHAR2
) is
  l_page_id number;
    l_user_id number;
  begin
    l_user_id := 0;
    if x_owner = 'SEED' then l_user_id := 1; end if;
    l_page_id := find_oldest_prefer_owned_by(x_page_name, x_application_id,
      l_user_id);

    update jtf_dpf_physical_pages_tl set
      physical_page_description = x_page_description,
	last_updated_by = l_user_id,
	last_update_date = sysdate,
	last_update_login = 0,
	source_lang = userenv('LANG')
    where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
      physical_page_id = l_page_id;
  end;

procedure LOAD_ROW (
  X_PAGE_NAME IN VARCHAR2,
  X_APPLICATION_ID IN VARCHAR2,
  X_PAGE_DESCRIPTION IN VARCHAR2,
  X_OWNER IN VARCHAR2
) is
  l_page_id number;
  l_new_phys_id number;
  t_rowid rowid;
  t_user number;
begin
  t_user := 0;
  if x_owner = 'SEED' then t_user := 1; end if;

  -- if there's not already a physical with this name and appid which is
  -- seed data...
  l_page_id := null;
  open find_match_with_owner(x_page_name, x_application_id, t_user);
  fetch find_match_with_owner into l_page_id;
  close find_match_with_owner;

  if l_page_id is null then
    -- cons up a new page_id, smaller than 10000
    l_new_phys_id := null;
    -- arsingh: prevent use of same id by different threads.
    select JTF_DPF_PHYSICAL_PAGES_S.nextval into l_new_phys_id from dual;
    -- select max(physical_page_id) into l_new_phys_id from
    --   jtf_dpf_physical_pages_b where physical_page_id<10000;
    -- if l_new_phys_id is null then
    --   l_new_phys_id := 1;
    -- else
    --   l_new_phys_id := l_new_phys_id+1;
    -- end if;

    -- do an insert
    insert_row(
	X_ROWID				=> t_rowid,
	X_PHYSICAL_PAGE_ID		=> l_new_phys_id,
	X_PHYSICAL_PAGE_NAME		=> x_page_name,
	X_APPLICATION_ID		=> x_application_id,
	X_OBJECT_VERSION_NUMBER		=> 1,
	X_PHYSICAL_PAGE_DESCRIPTION	=> x_page_description,
	X_CREATION_DATE			=> sysdate,
	X_CREATED_BY			=> t_user,
	X_LAST_UPDATE_DATE		=> sysdate,
	X_LAST_UPDATED_BY		=> t_user,
	X_LAST_UPDATE_LOGIN		=> 0);
  else
    -- else do an update
    update_row(
	X_PHYSICAL_PAGE_ID		=> l_page_id,
	X_PHYSICAL_PAGE_NAME		=> x_page_name,
	X_APPLICATION_ID		=> x_application_id,
	X_OBJECT_VERSION_NUMBER		=> 1,
	X_PHYSICAL_PAGE_DESCRIPTION	=> x_page_description,
	X_LAST_UPDATE_DATE		=> sysdate,
	X_LAST_UPDATED_BY		=> t_user,
	X_LAST_UPDATE_LOGIN		=> 0);
  end if;
end;

procedure insert_phy_attributes(
  X_PHYS_ID IN NUMBER,
  x_PAGE_ATTRIBUTE_NAME IN VARCHAR2,
  x_PAGE_ATTRIBUTE_VALUE IN VARCHAR2,
  X_OWNER IN VARCHAR2
) is
  t_user number;
begin
  t_user := 0;
  if x_owner = 'SEED' then t_user := 1; end if;
  insert into jtf_dpf_phy_attribs(
	PHYSICAL_PAGE_ID,
	PAGE_ATTRIBUTE_NAME,
	PAGE_ATTRIBUTE_VALUE,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN)
  values  (
    x_phys_id,
    x_page_attribute_name,
    x_page_attribute_value,
	1,
	t_user,
	sysdate,
	sysdate,
	t_user,
	0);
end;

procedure update_phy_attributes(
  X_PHYS_ID IN NUMBER,
  x_PAGE_ATTRIBUTE_NAME IN VARCHAR2,
  x_PAGE_ATTRIBUTE_VALUE IN VARCHAR2,
  X_OWNER IN VARCHAR2
) is
  t_user number;
begin
  t_user := 0;
  if x_owner = 'SEED' then t_user := 1; end if;
  update jtf_dpf_phy_attribs set
	PAGE_ATTRIBUTE_VALUE = x_page_attribute_value,
		OBJECT_VERSION_NUMBER = object_version_number+1,
		CREATED_BY = t_user,
		CREATION_DATE = sysdate,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = t_user,
		LAST_UPDATE_LOGIN = 0
    where physical_page_id = x_phys_id and
	page_attribute_name = x_page_attribute_name;
end;

end JTF_DPF_PHYSICAL_PAGES_PKG;

/
