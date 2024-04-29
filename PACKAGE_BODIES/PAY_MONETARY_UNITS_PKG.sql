--------------------------------------------------------
--  DDL for Package Body PAY_MONETARY_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MONETARY_UNITS_PKG" as
/* $Header: pymon01t.pkb 115.3 2003/08/05 07:01:07 scchakra ship $ */
--
-- define globals for validating translation.
--
g_business_group_id number(15);
g_legislation_code  varchar2(150);
g_currency_code     varchar2(15);
--
procedure pop_flds(p_terr_code IN VARCHAR2,
		   p_country   IN OUT NOCOPY VARCHAR2) is

cursor c2 is
select territory_short_name
from fnd_territories_vl
where territory_code = p_terr_code;
--
begin
--
hr_utility.set_location('pay_monetary_units_pkg.pop_flds',1);
--
open c2;
--
  fetch c2 into p_country;
--
close c2;
--
end pop_flds;


procedure chk_unq_row(p_cur_code  IN VARCHAR2,
		      p_unit_name IN VARCHAR2,
                      p_bgroup_id IN NUMBER,
                      p_rowid     IN VARCHAR2,
		      p_leg_code  IN VARCHAR2 default null,
		      p_rel_value IN NUMBER   default null) is
l_exists varchar2(1);

cursor c3(p_mode in varchar2) is
select 'x'
from   pay_monetary_units pmu
      ,pay_monetary_units_tl pmut
where  pmu.currency_code = p_cur_code
and    (  (p_mode = 'MONETARY_UNIT_NAME'
          and upper(translate(pmut.monetary_unit_name,'x_','x '))
	      = upper(translate(p_unit_name,'x_','x '))
	  )
       or (p_mode = 'RELATIVE_VALUE'
          and pmu.relative_value = p_rel_value))
and    pmut.monetary_unit_id = pmu.monetary_unit_id
and    pmut.language = userenv('LANG')
and    (  (pmu.legislation_code is null
          and pmu.business_group_id + 0 = p_bgroup_id)
       or (pmu.business_group_id is null
          and pmu.legislation_code = p_leg_code)
       or (pmu.business_group_id is null
          and pmu.legislation_code is null))
and    (p_rowid is null
       or (p_rowid is not null and chartorowid(p_rowid) <> pmu.rowid));
--
begin
--
hr_utility.set_location('pay_monetary_units_pkg.chk_unq_row',1);
--
if p_unit_name is not null then
  open c3('MONETARY_UNIT_NAME');
  --
  fetch c3 into l_exists;
  IF c3%found THEN
  hr_utility.set_message(801, 'PAY_6777_DEF_CURR_UNIT_EXISTS');
  hr_utility.set_message_token('1','name');
  close c3;
  hr_utility.raise_error;
  END IF;
  --
  close c3;
end if;
--
if p_rel_value is not null then
  open c3('RELATIVE_VALUE');
  --
  fetch c3 into l_exists;
  IF c3%found THEN
  hr_utility.set_message(801, 'PAY_6777_DEF_CURR_UNIT_EXISTS');
  hr_utility.set_message_token('1','value');
  close c3;
  hr_utility.raise_error;
  END IF;
  --
  close c3;
end if;
--
end chk_unq_row;


procedure get_id(p_munit_id IN OUT NOCOPY NUMBER) is

cursor c4 is
select pay_monetary_units_s.nextval
from sys.dual;
--
begin
--
hr_utility.set_location('pay_monetary_units_pkg.get_id',1);
--
open c4;
--
  fetch c4 into p_munit_id;
--
close c4;
--
end get_id;


procedure stb_del_valid(p_munit_id IN NUMBER) is
l_exists varchar2(1);

cursor c5 is
select 'x'
from pay_coin_anal_elements
where monetary_unit_id = p_munit_id;
--
begin
--
hr_utility.set_location('pay_monetary_units_pkg.stb_del_valid',1);
--
open c5;
--
  fetch c5 into l_exists;
  IF c5%found THEN
  hr_utility.set_message(801, 'PAY_6780_DEF_CURR_UNIT_RULES');
  close c5;
  hr_utility.raise_error;
  END IF;
--
close c5;
--
end stb_del_valid;
--
-- Start of Table Handlers for PAY_MONETARY_UNITS and PAY_MONETARY_UNITS_TL.
--
procedure INSERT_ROW (
  X_ROWID              in out nocopy VARCHAR2,
  X_MONETARY_UNIT_ID   in out nocopy NUMBER,
  X_CURRENCY_CODE      in VARCHAR2,
  X_BUSINESS_GROUP_ID  in NUMBER,
  X_LEGISLATION_CODE   in VARCHAR2,
  X_RELATIVE_VALUE     in NUMBER,
  X_COMMENTS           in LONG,
  X_MONETARY_UNIT_NAME in VARCHAR2,
  X_CREATION_DATE      in DATE,
  X_CREATED_BY         in NUMBER,
  X_LAST_UPDATE_DATE   in DATE,
  X_LAST_UPDATED_BY    in NUMBER,
  X_LAST_UPDATE_LOGIN  in NUMBER
) is
  --
  cursor C is select ROWID from PAY_MONETARY_UNITS
    where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID;
begin
  --
  chk_unq_row(p_cur_code  => X_CURRENCY_CODE
             ,p_unit_name => X_MONETARY_UNIT_NAME
	     ,p_rel_value => X_RELATIVE_VALUE
             ,p_bgroup_id => X_BUSINESS_GROUP_ID
  	     ,p_leg_code  => X_LEGISLATION_CODE
  	     ,p_rowid     => X_ROWID
             );
  --
  get_id(x_monetary_unit_id);
  --
  insert into PAY_MONETARY_UNITS (
    MONETARY_UNIT_ID,
    CURRENCY_CODE,
    BUSINESS_GROUP_ID,
    LEGISLATION_CODE,
    RELATIVE_VALUE,
    COMMENTS,
    MONETARY_UNIT_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MONETARY_UNIT_ID,
    X_CURRENCY_CODE,
    X_BUSINESS_GROUP_ID,
    X_LEGISLATION_CODE,
    X_RELATIVE_VALUE,
    X_COMMENTS,
    X_MONETARY_UNIT_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PAY_MONETARY_UNITS_TL (
    MONETARY_UNIT_ID,
    MONETARY_UNIT_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MONETARY_UNIT_ID,
    X_MONETARY_UNIT_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PAY_MONETARY_UNITS_TL T
    where T.MONETARY_UNIT_ID = X_MONETARY_UNIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;
--
procedure LOCK_ROW (
  X_MONETARY_UNIT_ID   in NUMBER,
  X_CURRENCY_CODE      in VARCHAR2,
  X_BUSINESS_GROUP_ID  in NUMBER,
  X_LEGISLATION_CODE   in VARCHAR2,
  X_RELATIVE_VALUE     in NUMBER,
  X_COMMENTS           in LONG,
  X_MONETARY_UNIT_NAME in VARCHAR2
) is
  cursor c is select
      CURRENCY_CODE,
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      RELATIVE_VALUE,
      COMMENTS
    from PAY_MONETARY_UNITS
    where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID
    for update of MONETARY_UNIT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MONETARY_UNIT_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PAY_MONETARY_UNITS_TL
    where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MONETARY_UNIT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CURRENCY_CODE = X_CURRENCY_CODE)
      AND ((recinfo.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID)
           OR ((recinfo.BUSINESS_GROUP_ID is null) AND (X_BUSINESS_GROUP_ID is null)))
      AND ((recinfo.LEGISLATION_CODE = X_LEGISLATION_CODE)
           OR ((recinfo.LEGISLATION_CODE is null) AND (X_LEGISLATION_CODE is null)))
      AND (recinfo.RELATIVE_VALUE = X_RELATIVE_VALUE)
      AND ((recinfo.COMMENTS = X_COMMENTS)
           OR ((recinfo.COMMENTS is null) AND (X_COMMENTS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MONETARY_UNIT_NAME = X_MONETARY_UNIT_NAME)
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
--
procedure UPDATE_ROW (
  X_ROWID              in VARCHAR2,
  X_MONETARY_UNIT_ID   in NUMBER,
  X_CURRENCY_CODE      in VARCHAR2,
  X_BUSINESS_GROUP_ID  in NUMBER,
  X_LEGISLATION_CODE   in VARCHAR2,
  X_RELATIVE_VALUE     in NUMBER,
  X_COMMENTS           in LONG,
  X_MONETARY_UNIT_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE   in DATE,
  X_LAST_UPDATED_BY    in NUMBER,
  X_LAST_UPDATE_LOGIN  in NUMBER
) is
begin
hr_utility.set_location('Entering Update_row',30);
  --
  chk_unq_row(p_cur_code  => X_CURRENCY_CODE
             ,p_unit_name => X_MONETARY_UNIT_NAME
	     ,p_rel_value => X_RELATIVE_VALUE
             ,p_bgroup_id => X_BUSINESS_GROUP_ID
  	     ,p_leg_code  => X_LEGISLATION_CODE
  	     ,p_rowid     => X_ROWID
             );
  --
  update PAY_MONETARY_UNITS set
    CURRENCY_CODE = X_CURRENCY_CODE,
    BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    RELATIVE_VALUE = X_RELATIVE_VALUE,
    COMMENTS = X_COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PAY_MONETARY_UNITS_TL set
    MONETARY_UNIT_NAME = X_MONETARY_UNIT_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  --
  if (sql%notfound) then
    insert into PAY_MONETARY_UNITS_TL
    (MONETARY_UNIT_ID,
     MONETARY_UNIT_NAME,
     LANGUAGE,
     SOURCE_LANG
     )
    select
     X_MONETARY_UNIT_ID,
     X_MONETARY_UNIT_NAME,
     L.LANGUAGE_CODE,
     userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      (select NULL
       from PAY_MONETARY_UNITS_TL T
       where T.MONETARY_UNIT_ID = X_MONETARY_UNIT_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);
  end if;
  --
end UPDATE_ROW;
--
procedure DELETE_ROW (
  X_MONETARY_UNIT_ID in NUMBER
) is
begin
  delete from PAY_MONETARY_UNITS_TL
  where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PAY_MONETARY_UNITS
  where MONETARY_UNIT_ID = X_MONETARY_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--
procedure ADD_LANGUAGE
is
begin
  delete from PAY_MONETARY_UNITS_TL T
  where not exists
    (select NULL
    from PAY_MONETARY_UNITS B
    where B.MONETARY_UNIT_ID = T.MONETARY_UNIT_ID
    );

  update PAY_MONETARY_UNITS_TL T set (
      MONETARY_UNIT_NAME
    ) = (select
      B.MONETARY_UNIT_NAME
    from PAY_MONETARY_UNITS_TL B
    where B.MONETARY_UNIT_ID = T.MONETARY_UNIT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MONETARY_UNIT_ID,
      T.MONETARY_UNIT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MONETARY_UNIT_ID,
      SUBT.MONETARY_UNIT_ID,
      SUBT.LANGUAGE
    from PAY_MONETARY_UNITS_TL SUBB, PAY_MONETARY_UNITS_TL SUBT
    where SUBB.MONETARY_UNIT_ID = SUBT.MONETARY_UNIT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MONETARY_UNIT_NAME <> SUBT.MONETARY_UNIT_NAME
  ));

  insert into PAY_MONETARY_UNITS_TL (
    MONETARY_UNIT_ID,
    MONETARY_UNIT_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MONETARY_UNIT_ID,
    B.MONETARY_UNIT_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_MONETARY_UNITS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_MONETARY_UNITS_TL T
    where T.MONETARY_UNIT_ID = B.MONETARY_UNIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
procedure TRANSLATE_ROW
  (X_RELATIVE_VALUE        in NUMBER
  ,X_MONETARY_UNIT_NAME    in VARCHAR2
  ,X_CURRENCY_CODE         in VARCHAR2
  ,X_LEGISLATION_CODE      in VARCHAR2
  ,X_BUSINESS_GROUP_NAME   in VARCHAR2
  ,X_OWNER                 in VARCHAR2
  ) is
  --
  l_last_updated_by   number;
  l_last_update_login number;
  l_last_update_date  date;
  --
begin
  --
  if X_OWNER = 'SEED' then
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => 1
      );
  else
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => -1
      );
  end if;
  --
  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;
  l_last_update_date  := sysdate;
  --
  update PAY_MONETARY_UNITS_TL pmut
     set pmut.MONETARY_UNIT_NAME = nvl(X_MONETARY_UNIT_NAME,MONETARY_UNIT_NAME)
        ,pmut.SOURCE_LANG = USERENV('LANG')
	,pmut.LAST_UPDATE_DATE = l_last_update_date
        ,pmut.LAST_UPDATED_BY  = l_last_updated_by
        ,pmut.LAST_UPDATE_LOGIN = l_last_update_login
   where USERENV('LANG') in (pmut.LANGUAGE,pmut.SOURCE_LANG)
     and exists
         ( select null
	   from   pay_monetary_units pmu
	   where  pmu.relative_value = x_relative_value
           and    pmu.currency_code = x_currency_code
	   and    pmu.monetary_unit_id = pmut.monetary_unit_id
	   and    (x_legislation_code is null
                  or pmu.legislation_code = x_legislation_code)
           and    (x_business_group_name is null
                  or pmu.business_group_id =
                     hr_api.return_business_group_id(x_business_group_name))
         );
  --
end TRANSLATE_ROW;
--
procedure LOAD_ROW (
  X_CURRENCY_CODE        in VARCHAR2,
  X_BUSINESS_GROUP_NAME  in VARCHAR2,
  X_LEGISLATION_CODE     in VARCHAR2,
  X_RELATIVE_VALUE       in NUMBER,
  X_COMMENTS             in LONG,
  X_MONETARY_UNIT_NAME   in VARCHAR2,
  X_OWNER                in VARCHAR2
  ) is
  --
  l_rowid rowid;
  l_monetary_unit_id number;
  l_business_group_id number;
  --
  l_sysdate           date := sysdate;
  l_created_by        number;
  l_creation_date     date;
  l_last_updated_by   number;
  l_last_update_login number;
  l_last_update_date  date;
  --
  cursor c_get_mon_unit(p_bg_id in number) is
    select pmu.monetary_unit_id, pmu.rowid
      from pay_monetary_units pmu
     where pmu.relative_value = x_relative_value
       and pmu.currency_code = x_currency_code
       and (x_legislation_code is null
           or pmu.legislation_code = x_legislation_code)
       and (p_bg_id is null
           or pmu.business_group_id = p_bg_id);
  --
begin
  -- Translate developer keys to internal parameters
  if X_OWNER = 'SEED' then
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => 1
      );
  else
    hr_general2.init_fndload
      (p_resp_appl_id => 801
      ,p_user_id      => -1
      );
  end if;
  -- Set the WHO Columns
  l_created_by      := fnd_global.user_id;
  l_creation_date   := l_sysdate;
  l_last_update_date  := l_sysdate;
  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;
  --
  if x_business_group_name is not null then
    l_business_group_id := hr_api.return_business_group_id(x_business_group_name);
  end if;
  --
  open c_get_mon_unit(l_business_group_id);
  fetch c_get_mon_unit into l_monetary_unit_id, l_rowid;
  close c_get_mon_unit;
  --
  -- Update or insert row as appropriate
  begin
    UPDATE_ROW
      ( X_ROWID              => L_ROWID
       ,X_MONETARY_UNIT_ID   => L_MONETARY_UNIT_ID
       ,X_CURRENCY_CODE      =>	X_CURRENCY_CODE
       ,X_BUSINESS_GROUP_ID  =>	L_BUSINESS_GROUP_ID
       ,X_LEGISLATION_CODE   =>	X_LEGISLATION_CODE
       ,X_RELATIVE_VALUE     =>	X_RELATIVE_VALUE
       ,X_COMMENTS           =>	X_COMMENTS
       ,X_MONETARY_UNIT_NAME =>	X_MONETARY_UNIT_NAME
       ,X_LAST_UPDATE_DATE   => L_LAST_UPDATE_DATE
       ,X_LAST_UPDATED_BY    => L_LAST_UPDATED_BY
       ,X_LAST_UPDATE_LOGIN  => L_LAST_UPDATE_LOGIN
       );
  exception
    when no_data_found then
    INSERT_ROW
      ( X_ROWID              => L_ROWID
       ,X_MONETARY_UNIT_ID   =>	L_MONETARY_UNIT_ID
       ,X_CURRENCY_CODE      =>	X_CURRENCY_CODE
       ,X_BUSINESS_GROUP_ID  =>	L_BUSINESS_GROUP_ID
       ,X_LEGISLATION_CODE   =>	X_LEGISLATION_CODE
       ,X_RELATIVE_VALUE     =>	X_RELATIVE_VALUE
       ,X_COMMENTS           =>	X_COMMENTS
       ,X_MONETARY_UNIT_NAME =>	X_MONETARY_UNIT_NAME
       ,X_CREATION_DATE      =>	L_CREATION_DATE
       ,X_CREATED_BY         =>	L_CREATED_BY
       ,X_LAST_UPDATE_DATE   =>	L_LAST_UPDATE_DATE
       ,X_LAST_UPDATED_BY    =>	L_LAST_UPDATED_BY
       ,X_LAST_UPDATE_LOGIN  =>	L_LAST_UPDATE_LOGIN
      );
  end;
end LOAD_ROW;
--
procedure SET_TRANSLATION_GLOBALS
  (P_BUSINESS_GROUP_ID  in NUMBER
  ,P_LEGISLATION_CODE   in VARCHAR2
  ,P_CURRENCY_CODE      in VARCHAR2
  ) is
  --
begin
  --
  g_business_group_id := p_business_group_id;
  g_legislation_code  := p_legislation_code;
  g_currency_code     := p_currency_code;
  --
end SET_TRANSLATION_GLOBALS;
--
-- This procedure fails if a monetary unit name translation is already present
-- in the table for a given language.  Otherwise, no action is performed.
-- It is used to ensure uniqueness of translated monetary unit names.
--
procedure VALIDATE_TRANSLATION
  (P_MONETARY_UNIT_ID   in NUMBER
  ,P_LANGUAGE           in VARCHAR2
  ,P_MONETARY_UNIT_NAME in VARCHAR2
  ,P_BUSINESS_GROUP_ID  in NUMBER   default null
  ,P_LEGISLATION_CODE   in VARCHAR2 default null
  ) is
  --
  -- This cursor implements the validation we require,
  -- and expects that the various package globals are set before
  -- the call to this procedure is made.  This is done from the
  -- user-named trigger 'TRANSLATIONS' in the form
  --
  cursor c_translation(p_language           in varchar2
                      ,p_monetary_unit_name in varchar2
                      ,p_monetary_unit_id   in number
                      ,p_business_group_id  in number
		      ,p_legislation_code   in varchar2) is
    select 1
      from pay_monetary_units pmu,
           pay_monetary_units_tl pmut
     where upper(pmut.monetary_unit_name) = upper(p_monetary_unit_name)
       and pmu.currency_code = g_currency_code
       and pmut.language = p_language
       and pmu.monetary_unit_id = pmut.monetary_unit_id
       and (pmu.monetary_unit_id <> p_monetary_unit_id
           or p_monetary_unit_id is null)
       and (pmu.business_group_id = p_business_group_id
           or p_business_group_id is null)
       and (pmu.legislation_code = p_legislation_code
           or p_legislation_code is null);
  --
  l_proc_name  VARCHAR2(80)  := 'PAY_MONETARY_UNITS_PKG.VALIDATE_TRANSLATION';
  l_bus_grp_id NUMBER        := nvl(p_business_group_id, g_business_group_id);
  l_leg_code   VARCHAR2(150) := nvl(p_legislation_code, g_legislation_code);
  l_exists     number(1);
  --
begin
  hr_utility.set_location(l_proc_name, 5);
  --
  open c_translation(p_language
                    ,p_monetary_unit_name
		    ,p_monetary_unit_id
		    ,l_bus_grp_id
		    ,l_leg_code);
  fetch c_translation into l_exists;
  --
  if c_translation%found then
    close c_translation;
    fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
    fnd_message.raise_error;
  else
    close c_translation;
  end if;
  --
  hr_utility.set_location(l_proc_name, 10);
end VALIDATE_TRANSLATION;
--
end PAY_MONETARY_UNITS_PKG;

/
