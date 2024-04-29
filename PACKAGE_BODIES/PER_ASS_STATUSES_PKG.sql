--------------------------------------------------------
--  DDL for Package Body PER_ASS_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASS_STATUSES_PKG" AS
/* $Header: peast01t.pkb 120.4.12010000.2 2008/08/07 08:54:40 ghshanka ship $ */
--------------------------------------------------------------------------------
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

procedure KEY_TO_IDS (
  X_USER_STATUS in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ASSIGNMENT_STATUS_TYPE_ID out nocopy VARCHAR2,
  X_BUSINESS_GROUP_ID out nocopy NUMBER
) is
  cursor CSR_BUSINESS_GROUP (
    X_NAME in VARCHAR2
  ) is
    select ORG.ORGANIZATION_ID
    from HR_ALL_ORGANIZATION_UNITS ORG
        ,HR_ORGANIZATION_INFORMATION OI1
    where ORG.ORGANIZATION_ID = OI1.ORGANIZATION_ID
    and OI1.ORG_INFORMATION_CONTEXT = 'CLASS'
    and OI1.ORG_INFORMATION1 = 'HR_BG'
    and OI1.ORG_INFORMATION2 = 'Y'
    and ORG.NAME = X_NAME;
  cursor CSR_ASSIGNMENT_STATUS_TYPE (
    X_USER_STATUS VARCHAR2,
    X_BUSINESS_GROUP_ID in NUMBER,
    X_LEGISLATION_CODE in VARCHAR2
  ) is
    select AST.ASSIGNMENT_STATUS_TYPE_ID
    from PER_ASSIGNMENT_STATUS_TYPES AST
    where AST.USER_STATUS = X_USER_STATUS
    and (  AST.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
        or (   AST.BUSINESS_GROUP_ID is null
           and X_BUSINESS_GROUP_ID is null))
    and (  AST.LEGISLATION_CODE = X_LEGISLATION_CODE
        or (   AST.LEGISLATION_CODE is null
           and X_LEGISLATION_CODE is null));
  cursor csr_max_seq  is
  select max(ASSIGNMENT_STATUS_TYPE_ID)
    from per_assignment_status_types;

  cursor CSR_SEQUENCE is
    select PER_ASSIGNMENT_STATUS_TYPES_S.nextval
    from   dual;
  L_BUSINESS_GROUP_ID NUMBER;
  L_MAX_SEQ NUMBER;
begin
  open CSR_BUSINESS_GROUP (
    X_BUSINESS_GROUP_NAME
  );
  fetch CSR_BUSINESS_GROUP into L_BUSINESS_GROUP_ID;
  close CSR_BUSINESS_GROUP;
  X_BUSINESS_GROUP_ID := L_BUSINESS_GROUP_ID;
  open CSR_ASSIGNMENT_STATUS_TYPE (
    X_USER_STATUS,
    L_BUSINESS_GROUP_ID,
    X_LEGISLATION_CODE
  );

  fetch CSR_ASSIGNMENT_STATUS_TYPE into X_ASSIGNMENT_STATUS_TYPE_ID;
  if (CSR_ASSIGNMENT_STATUS_TYPE%notfound) then
    open CSR_SEQUENCE;
    open CSR_MAX_SEQ;
    fetch CSR_MAX_SEQ into L_MAX_SEQ;
    if CSR_MAX_SEQ%notfound then
       L_MAX_SEQ := 0;
       close CSR_MAX_SEQ;
    end if;
    close CSR_MAX_SEQ;
    fetch CSR_SEQUENCE into X_ASSIGNMENT_STATUS_TYPE_ID;
    close CSR_SEQUENCE; -- fix 7197717
    while(X_ASSIGNMENT_STATUS_TYPE_ID <= L_MAX_SEQ)
    LOOP
      open CSR_SEQUENCE; -- fix 7197717
      fetch CSR_SEQUENCE into X_ASSIGNMENT_STATUS_TYPE_ID;
      close CSR_SEQUENCE; -- fix 7197717
    END LOOP;

  end if;
  close CSR_ASSIGNMENT_STATUS_TYPE;
end KEY_TO_IDS;

PROCEDURE UNIQUENESS_CHECK(P_USER_STATUS                VARCHAR2,
                           P_BUSINESS_GROUP_ID          NUMBER,
                           P_LEGISLATION_CODE           VARCHAR2,
                           P_ROWID                      VARCHAR2,
                           P_ASSIGNMENT_STATUS_TYPE_ID  NUMBER,
                           P_STARTUP_MODE               VARCHAR2,
                           P_PRIMARY_FLAG               VARCHAR2,
                           P_AMENDMENT                  VARCHAR2,
                           P_C_ACTIVE_FLAG              VARCHAR2,
                           P_C_DEFAULT_FLAG             VARCHAR2,
                           P_DEFAULT_FLAG               VARCHAR2,
                           P_ACTIVE_FLAG                VARCHAR2,
                           P_PER_SYSTEM_STATUS          VARCHAR2,
			   P_MODE                       VARCHAR2) IS
L_DUMMY1  number;
L_DUMMY2 number;
v_exists1 number;
v_exists2 number;
v_exists3 number;
v_exists4 number;
CURSOR C1 IS
 	select  1
 	from    per_assignment_status_types_tl ttl,
                per_assignment_status_types t
 	where   upper(ttl.user_status) =  upper(P_USER_STATUS)
 	and     nvl(t.business_group_id, nvl(P_BUSINESS_GROUP_ID, -9999) )
        	  =  nvl(P_BUSINESS_GROUP_ID, -9999)
 	and     nvl(t.legislation_code, nvl(P_LEGISLATION_CODE, 'XXX') )
        	  =  nvl(P_LEGISLATION_CODE, 'XXX')
 	and     (P_ROWID        is null
        	 or P_ROWID    <> t.rowid)
        and     t.assignment_status_type_id = ttl.assignment_status_type_id
        and     ttl.LANGUAGE = userenv('LANG')
 	and     not exists (
         	select  null
         	from    per_ass_status_type_amends a
         	where   a.assignment_status_type_id =
					t.assignment_status_type_id
         	and     a.business_group_id + 0 = P_BUSINESS_GROUP_ID);
CURSOR C2 IS
	select  1
	from    per_ass_status_type_amends_tl atl,
                per_ass_status_type_amends a
	where   upper(atl.user_status)    = upper(P_USER_STATUS)
	and     a.business_group_id + 0     = P_BUSINESS_GROUP_ID
        and     a.ass_status_type_amend_id = atl.ass_status_type_amend_id
        and     atl.LANGUAGE = userenv('LANG')
	and     (P_ROWID is null
	or      a.assignment_status_type_id <> P_ASSIGNMENT_STATUS_TYPE_ID);
BEGIN
 OPEN C1;
 FETCH C1 INTO L_DUMMY1;
 IF C1%NOTFOUND THEN
  CLOSE C1;
  OPEN C2;
  FETCH C2 INTO L_DUMMY2;
  IF C2%NOTFOUND THEN
   CLOSE C2;
   NULL;
  ELSE
   CLOSE C2;
   hr_utility.set_message('801','HR_7602_DEF_STATUS_EXISTS');
   hr_utility.raise_error;
  END IF;
 ELSE
  CLOSE C1;
  hr_utility.set_message('801','HR_7602_DEF_STATUS_EXISTS');
  hr_utility.raise_error;
 END IF;
END UNIQUENESS_CHECK;

PROCEDURE PRE_UPDATE(P_ACTIVE_FLAG         VARCHAR2,
                     P_DEFAULT_FLAG        VARCHAR2,
                     P_USER_STATUS         VARCHAR2,
                     P_PAY_SYSTEM_STATUS   VARCHAR2,
                     P_LAST_UPDATE_DATE    DATE,
                     P_LAST_UPDATED_BY     NUMBER,
                     P_LAST_UPDATE_LOGIN   NUMBER,
                     P_CREATED_BY          NUMBER,
                     P_CREATION_DATE       DATE,
                     P_ASS_STATUS_TYPE_ID  NUMBER,
                     P_AMENDMENT           VARCHAR2) IS
BEGIN
   update per_ass_status_type_amends a
      set    a.active_flag           = P_ACTIVE_FLAG,
             a.default_flag          = P_DEFAULT_FLAG,
             a.user_status           = P_USER_STATUS,
             a.pay_system_status     = P_PAY_SYSTEM_STATUS,
             a.last_update_date      = P_LAST_UPDATE_DATE,
             a.last_updated_by       = P_LAST_UPDATED_BY,
             a.last_update_login     = P_LAST_UPDATE_LOGIN,
             a.created_by            = P_CREATED_BY,
             a.creation_date         = P_CREATION_DATE
      where  a.ass_status_type_amend_id = P_ASS_STATUS_TYPE_ID;
--MLS
   update per_ass_status_type_amends_tl atl
      set    atl.user_status           = P_USER_STATUS,
             atl.last_update_date      = P_LAST_UPDATE_DATE,
             atl.last_updated_by       = P_LAST_UPDATED_BY,
             atl.last_update_login     = P_LAST_UPDATE_LOGIN,
             atl.created_by            = P_CREATED_BY,
             atl.creation_date         = P_CREATION_DATE
      where  atl.ass_status_type_amend_id = P_ASS_STATUS_TYPE_ID
      and    atl.LANGUAGE = userenv('LANG');

END PRE_UPDATE;
PROCEDURE INSERT_AMENDS(P_ASS_STATUS_TYPE_AMEND_ID IN OUT NOCOPY NUMBER,
                        P_ASSIGNMENT_STATUS_TYPE_ID NUMBER,
                        P_BUSINESS_GROUP_ID         NUMBER,
                        P_ACTIVE_FLAG               VARCHAR2,
                        P_DEFAULT_FLAG              VARCHAR2,
                        P_USER_STATUS               VARCHAR2,
                        P_PAY_SYSTEM_STATUS         VARCHAR2,
                        P_PER_SYSTEM_STATUS         VARCHAR2,
                        P_LAST_UPDATE_DATE          DATE,
                        P_LAST_UPDATED_BY           NUMBER,
                        P_LAST_UPDATE_LOGIN         NUMBER,
                        P_CREATED_BY                NUMBER,
                        P_CREATION_DATE             DATE) IS
L_ID NUMBER;
 BEGIN
       select per_ass_status_type_amends_s.nextval
       into   L_ID
       from sys.dual;
       P_ASS_STATUS_TYPE_AMEND_ID := L_ID;
 insert into per_ass_status_type_amends(
                ASS_STATUS_TYPE_AMEND_ID,
        	ASSIGNMENT_STATUS_TYPE_ID,
        	BUSINESS_GROUP_ID,
        	ACTIVE_FLAG,
        	DEFAULT_FLAG,
        	USER_STATUS,
        	PAY_SYSTEM_STATUS,
        	PER_SYSTEM_STATUS,
        	LAST_UPDATE_DATE,
        	LAST_UPDATED_BY,
        	LAST_UPDATE_LOGIN,
        	CREATED_BY,
        	CREATION_DATE)
 values(
         P_ASS_STATUS_TYPE_AMEND_ID,
         P_ASSIGNMENT_STATUS_TYPE_ID,
         P_BUSINESS_GROUP_ID,
         P_ACTIVE_FLAG,
         P_DEFAULT_FLAG,
         P_USER_STATUS,
         P_PAY_SYSTEM_STATUS,
         P_PER_SYSTEM_STATUS,
         P_LAST_UPDATE_DATE,
         P_LAST_UPDATED_BY,
         P_LAST_UPDATE_LOGIN,
         P_CREATED_BY,
         P_CREATION_DATE);
-- MLS
insert into per_ass_status_type_amends_tl(
           ASS_STATUS_TYPE_AMEND_ID,
           LANGUAGE,
           SOURCE_LANG,
           USER_STATUS,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATED_BY,
           CREATION_DATE)
select
           P_ASS_STATUS_TYPE_AMEND_ID,
           L.LANGUAGE_CODE,
           B.LANGUAGE_CODE,
           P_USER_STATUS,
           P_LAST_UPDATE_DATE,
           P_LAST_UPDATED_BY,
           P_LAST_UPDATE_LOGIN,
           P_CREATED_BY,
           P_CREATION_DATE
from FND_LANGUAGES L, FND_LANGUAGES B
where L.INSTALLED_FLAG in ('I', 'B')
  and B.INSTALLED_FLAG = 'B';
-- MLS end
 END INSERT_AMENDS;

--
-- For a given business group / legislation combination there must be one and
-- only one active default assignment status for each personnel system status.
-- The user can define many assignment statuses based on a system status but
-- only one can be the actve default at any one time.
--
procedure chk_dflt_per_sys_statuses
(
 p_business_group_id number,
 p_legislation_code  varchar2
) is
--
  type varchar2_table is table of varchar2(30) index by binary_integer;
--
  cursor csr1 is
    select lookup_code status
    from   hr_lookups
    where  lookup_type = 'PER_ASS_SYS_STATUS'
    order  by lookup_code;
--
  cursor csr2 is
   select  t.per_system_status status
   from    per_assignment_status_types t
   where   t.per_system_status is not null
     and   t.default_flag = 'Y'
     and   t.active_flag  = 'Y'
     and   nvl(t.business_group_id, nvl(p_business_group_id, -9999) ) =
             nvl(p_business_group_id, -9999)
     and   nvl(t.legislation_code,  nvl(p_legislation_code, 'XXX') ) =
             nvl(p_legislation_code, 'XXX')
     and   not exists (select  null
                       from    per_ass_status_type_amends a
                       where   a.assignment_status_type_id =
				 t.assignment_status_type_id
                         and   a.business_group_id =
				 p_business_group_id)
   union all
   select a.per_system_status status
   from   per_ass_status_type_amends a
   where  a.per_system_status is not null
     and  a.default_flag      = 'Y'
     and  a.active_flag       = 'Y'
     and  a.business_group_id = p_business_group_id
   order by 1;
--
   system_statuses     varchar2_table;
   system_status_count number := 0;
   user_statuses       varchar2_table;
   user_status_count   number := 0;
--
begin
--
  --
  -- Populate a list with the personnel system statuses.
  --
  for system_rec in csr1 loop
    system_status_count := system_status_count + 1;
    system_statuses(system_status_count) := system_rec.status;
  end loop;
--
  --
  -- Populate a list with the active default assignment statuses as
  -- defined by the user.
  --
  for user_rec in csr2 loop
    user_status_count := user_status_count + 1;
    user_statuses(user_status_count) := user_rec.status;
  end loop;
--
  --
  -- Make sure that the number of personnel system statuses is matched by the
  -- number of active default assignment statuses.
  --
  if system_status_count <> user_status_count then
    hr_utility.set_message(801, 'HR_7214_ASS_STAT_ONE_ONLY_ONE');
    hr_utility.raise_error;
  end if;
--
  --
  -- Compare the list of personnel system statuses with the user defined
  -- active default assignment statuses. There should be a one to one match
  -- which signals that each personnel system status is used only once as the
  -- active default.
  --
  for i in 1..system_status_count loop
    if system_statuses(i) <> user_statuses(i) then
      hr_utility.set_message(801, 'HR_7214_ASS_STAT_ONE_ONLY_ONE');
      hr_utility.raise_error;
    end if;
  end loop;
--
end chk_dflt_per_sys_statuses;
--
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_EXTERNAL_STATUS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PER_ASSIGNMENT_STATUS_TYPES
    where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID;
begin
  insert into PER_ASSIGNMENT_STATUS_TYPES (
    ASSIGNMENT_STATUS_TYPE_ID,
    BUSINESS_GROUP_ID,
    LEGISLATION_CODE,
    USER_STATUS,
    ACTIVE_FLAG,
    DEFAULT_FLAG,
    PRIMARY_FLAG,
    PAY_SYSTEM_STATUS,
    PER_SYSTEM_STATUS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ASSIGNMENT_STATUS_TYPE_ID,
    X_BUSINESS_GROUP_ID,
    X_LEGISLATION_CODE,
    X_USER_STATUS,
    X_ACTIVE_FLAG,
    X_DEFAULT_FLAG,
    X_PRIMARY_FLAG,
    X_PAY_SYSTEM_STATUS,
    X_PER_SYSTEM_STATUS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PER_ASSIGNMENT_STATUS_TYPES_TL (
    ASSIGNMENT_STATUS_TYPE_ID,
    USER_STATUS,
    EXTERNAL_STATUS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ASSIGNMENT_STATUS_TYPE_ID,
    X_USER_STATUS,
    X_EXTERNAL_STATUS,
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
    from PER_ASSIGNMENT_STATUS_TYPES_TL T
    where T.ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID
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
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2
) is
  cursor c is select
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      ACTIVE_FLAG,
      DEFAULT_FLAG,
      PRIMARY_FLAG,
      PAY_SYSTEM_STATUS,
      PER_SYSTEM_STATUS
    from PER_ASSIGNMENT_STATUS_TYPES
    where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID
    for update of ASSIGNMENT_STATUS_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_STATUS,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PER_ASSIGNMENT_STATUS_TYPES_TL
    where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ASSIGNMENT_STATUS_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID)
           OR ((recinfo.BUSINESS_GROUP_ID is null) AND (X_BUSINESS_GROUP_ID is null)))
      AND ((recinfo.LEGISLATION_CODE = X_LEGISLATION_CODE)
           OR ((recinfo.LEGISLATION_CODE is null) AND (X_LEGISLATION_CODE is null)))
      AND (recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
      AND (recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
      AND (recinfo.PRIMARY_FLAG = X_PRIMARY_FLAG)
      AND ((recinfo.PAY_SYSTEM_STATUS = X_PAY_SYSTEM_STATUS)
           OR ((recinfo.PAY_SYSTEM_STATUS is null) AND (X_PAY_SYSTEM_STATUS is null)))
      AND ((recinfo.PER_SYSTEM_STATUS = X_PER_SYSTEM_STATUS)
           OR ((recinfo.PER_SYSTEM_STATUS is null) AND (X_PER_SYSTEM_STATUS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_STATUS = X_USER_STATUS)
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
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER,
  X_BUSINESS_GROUP_ID in NUMBER,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_EXTERNAL_STATUS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  -- start of bug 5411889
-- added an if condition so that the seeded record status
-- is not changed when updating the record.

 if X_BUSINESS_GROUP_ID is not null then

   update PER_ASSIGNMENT_STATUS_TYPES set
    BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
    USER_STATUS = X_USER_STATUS,  -- Bug 2731841
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    PRIMARY_FLAG = X_PRIMARY_FLAG,
    PAY_SYSTEM_STATUS = X_PAY_SYSTEM_STATUS,
    PER_SYSTEM_STATUS = X_PER_SYSTEM_STATUS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID;

  else

  update PER_ASSIGNMENT_STATUS_TYPES set
    BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID,
    LEGISLATION_CODE = X_LEGISLATION_CODE,
  -- USER_STATUS = X_USER_STATUS,  -- Bug 2731841
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    PRIMARY_FLAG = X_PRIMARY_FLAG,
    PAY_SYSTEM_STATUS = X_PAY_SYSTEM_STATUS,
    PER_SYSTEM_STATUS = X_PER_SYSTEM_STATUS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID;

end if;
-- end of bug 5411889

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PER_ASSIGNMENT_STATUS_TYPES_TL set
    USER_STATUS = X_USER_STATUS,
    EXTERNAL_STATUS = X_EXTERNAL_STATUS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
) is
begin
  delete from PER_ASSIGNMENT_STATUS_TYPES_TL
  where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PER_ASSIGNMENT_STATUS_TYPES
  where ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--
procedure LOAD_ROW (
  X_STATUS in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_PAY_SYSTEM_STATUS in VARCHAR2,
  X_PER_SYSTEM_STATUS in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
)
is
  X_ROWID ROWID;
  X_ASSIGNMENT_STATUS_TYPE_ID NUMBER;
  X_BUSINESS_GROUP_ID NUMBER;
  X_CREATION_DATE DATE :=sysdate;
  X_CREATED_BY NUMBER;
 -- X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
  else
    X_CREATED_BY := 0;
  end if;

  KEY_TO_IDS (
    X_STATUS,
    X_BUSINESS_GROUP_NAME,
    X_LEGISLATION_CODE,
    X_ASSIGNMENT_STATUS_TYPE_ID,
    X_BUSINESS_GROUP_ID
  );
   -- Commenting this as X_LAST_UPDATE_DATE is now an Input parameter.
  /*
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );*/

  begin
   f_luby := fnd_load_util.owner_id(X_OWNER);
   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
     select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from PER_ASSIGNMENT_STATUS_TYPES
     where ASSIGNMENT_STATUS_TYPE_ID = TO_NUMBER(X_ASSIGNMENT_STATUS_TYPE_ID);

   -- Test for customization and version
   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                 db_ludate, X_CUSTOM_MODE)) then
    UPDATE_ROW (
      X_ASSIGNMENT_STATUS_TYPE_ID,
      X_BUSINESS_GROUP_ID,
      X_LEGISLATION_CODE,
      X_ACTIVE_FLAG,
      X_DEFAULT_FLAG,
      X_PRIMARY_FLAG,
      X_PAY_SYSTEM_STATUS,
      X_PER_SYSTEM_STATUS,
      X_USER_STATUS,
      X_USER_STATUS,
      f_ludate,
      f_luby,
      0);
    end if;
  exception
    when no_data_found then
      INSERT_ROW (
        X_ROWID,
        X_ASSIGNMENT_STATUS_TYPE_ID,
        X_BUSINESS_GROUP_ID,
        X_LEGISLATION_CODE,
        X_ACTIVE_FLAG,
        X_DEFAULT_FLAG,
        X_PRIMARY_FLAG,
        X_PAY_SYSTEM_STATUS,
        X_PER_SYSTEM_STATUS,
        X_USER_STATUS,
        X_USER_STATUS,
        X_CREATION_DATE,
        X_CREATED_BY,
        f_ludate,
        f_luby,
        0);
  end;
end LOAD_ROW;
--
procedure TRANSLATE_ROW (
  X_STATUS in VARCHAR2,
  X_BUSINESS_GROUP_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_USER_STATUS in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null
)
is
  X_ASSIGNMENT_STATUS_TYPE_ID NUMBER;
  X_BUSINESS_GROUP_ID NUMBER;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
--  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  KEY_TO_IDS (
    X_STATUS,
    X_BUSINESS_GROUP_NAME,
    X_LEGISLATION_CODE,
    X_ASSIGNMENT_STATUS_TYPE_ID,
    X_BUSINESS_GROUP_ID
  );
  -- Commenting this as X_LAST_UPDATE_DATE is now an Input parameter.
  /*
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );*/

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
      select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      from PER_ASSIGNMENT_STATUS_TYPES_TL
      where ASSIGNMENT_STATUS_TYPE_ID = TO_NUMBER(X_ASSIGNMENT_STATUS_TYPE_ID)
      and LANGUAGE=userenv('LANG');

if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then

  update PER_ASSIGNMENT_STATUS_TYPES_TL set
    USER_STATUS = X_USER_STATUS,
    EXTERNAL_STATUS = X_USER_STATUS,       -- Bug fix 3627126.
    LAST_UPDATE_DATE = db_ludate,
    LAST_UPDATED_BY = db_luby,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
  and ASSIGNMENT_STATUS_TYPE_ID = X_ASSIGNMENT_STATUS_TYPE_ID;
 end if;
end TRANSLATE_ROW;
--
procedure ADD_LANGUAGE
is
begin
  -- process PER_ASSIGNMENT_STATUS_TYPES_TL table
  delete from PER_ASSIGNMENT_STATUS_TYPES_TL T
  where not exists
    (select NULL
    from PER_ASSIGNMENT_STATUS_TYPES B
    where B.ASSIGNMENT_STATUS_TYPE_ID = T.ASSIGNMENT_STATUS_TYPE_ID
    );

  update PER_ASSIGNMENT_STATUS_TYPES_TL T set (
      USER_STATUS
    ) = (select
      B.USER_STATUS
    from PER_ASSIGNMENT_STATUS_TYPES_TL B
    where B.ASSIGNMENT_STATUS_TYPE_ID = T.ASSIGNMENT_STATUS_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ASSIGNMENT_STATUS_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ASSIGNMENT_STATUS_TYPE_ID,
      SUBT.LANGUAGE
    from PER_ASSIGNMENT_STATUS_TYPES_TL SUBB, PER_ASSIGNMENT_STATUS_TYPES_TL SUBT
    where SUBB.ASSIGNMENT_STATUS_TYPE_ID = SUBT.ASSIGNMENT_STATUS_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_STATUS <> SUBT.USER_STATUS
  ));

  insert into PER_ASSIGNMENT_STATUS_TYPES_TL (
    ASSIGNMENT_STATUS_TYPE_ID,
    USER_STATUS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ INDEX(b)*/
    B.ASSIGNMENT_STATUS_TYPE_ID,
    B.USER_STATUS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_ASSIGNMENT_STATUS_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_ASSIGNMENT_STATUS_TYPES_TL T
    where T.ASSIGNMENT_STATUS_TYPE_ID = B.ASSIGNMENT_STATUS_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
  -- process PER_ASS_STATUS_TYPES_AMENDS_TL table
/*
  delete from PER_ASS_STATUS_TYPES_AMENDS_TL T
  where not exists
    (select NULL
    from PER_ASS_STATUS_TYPES_AMENDS B
    where B.ASS_STATUS_TYPE_AMEND_ID = T.ASS_STATUS_TYPE_AMEND_ID
    );

  update PER_ASS_STATUS_TYPES_AMENDS_TL T set (
      USER_STATUS
    ) = (select
      B.USER_STATUS
    from PER_ASS_STATUS_TYPES_AMENDS_TL B
    where B.ASS_STATUS_TYPE_AMEND_ID = T.ASS_STATUS_TYPE_AMEND_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ASS_STATUS_TYPE_AMEND_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ASS_STATUS_TYPE_AMEND_ID,
      SUBT.LANGUAGE
    from PER_ASS_STATUS_TYPES_AMENDS_TL SUBB, PER_ASS_STATUS_TYPES_AMENDS_TL SUBT
    where SUBB.ASS_STATUS_TYPE_AMEND_ID = SUBT.ASS_STATUS_TYPE_AMEND_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_STATUS <> SUBT.USER_STATUS
  ));
*/
  insert into PER_ASS_STATUS_TYPE_AMENDS_TL (
    ASS_STATUS_TYPE_AMEND_ID,
    USER_STATUS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ASS_STATUS_TYPE_AMEND_ID,
    B.USER_STATUS,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_ASS_STATUS_TYPE_AMENDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_ASS_STATUS_TYPE_AMENDS_TL T
    where T.ASS_STATUS_TYPE_AMEND_ID = B.ASS_STATUS_TYPE_AMEND_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
end ADD_LANGUAGE;
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_translation(assignment_status_type_id IN NUMBER,
			       language IN VARCHAR2,
			       user_status IN VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL)
			       IS
/*

This procedure fails if a user status translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated user statuses.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_user_status IN VARCHAR2,
                     p_assignment_status_type_id IN NUMBER,
                     p_bus_grp_id IN NUMBER)
		     IS
       SELECT  1
	 FROM  per_assignment_status_types_tl astt,
	       per_assignment_status_types ast
	 WHERE upper(astt.user_status)=upper(p_user_status)
	 AND   astt.assignment_status_type_id = ast.assignment_status_type_id
	 AND   astt.language = p_language
	 AND   (ast.assignment_status_type_id <> p_assignment_status_type_id
	       OR p_assignment_status_type_id IS NULL)
	 AND   (ast.business_group_id = p_bus_grp_id OR p_bus_grp_id IS NULL)
	 ;

       l_package_name VARCHAR2(80) := 'PER_ASS_STATUSES_PKG.VALIDATE_TRANSLATION';
       l_business_group_id NUMBER := nvl(p_business_group_id, g_business_group_id);

BEGIN
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, user_status,assignment_status_type_id,
		     l_business_group_id);
      	hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,60);
	  CLOSE c_translation;
       ELSE
      	hr_utility.set_location (l_package_name,70);
	  CLOSE c_translation;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
      	hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
--------------------------------------------------------------------------------

END PER_ASS_STATUSES_PKG;

/
