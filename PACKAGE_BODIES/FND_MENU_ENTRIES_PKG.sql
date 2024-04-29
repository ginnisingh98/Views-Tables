--------------------------------------------------------
--  DDL for Package Body FND_MENU_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MENU_ENTRIES_PKG" as
/* $Header: AFMNENTB.pls 120.3 2006/10/16 13:22:48 stadepal ship $ */

  C_PKG_NAME 	CONSTANT VARCHAR2(30) := 'FND_FUNCTION';
  C_LOG_HEAD 	CONSTANT VARCHAR2(30) := 'fnd.plsql.FND_FUNCTION.';

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_MENU_ENTRIES
    where MENU_ID = X_MENU_ID
    and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE
    ;
  L_GRANT_FLAG VARCHAR2(1);
begin
  /* for bug 2216556 default the grant_flag to maintain compatibility with*/
  /* old loader data files that don't have GRANT_FLAG */
  if (X_GRANT_FLAG is NULL) then
    L_GRANT_FLAG := 'Y';
  else
    L_GRANT_FLAG := substrb(X_GRANT_FLAG,1,1);
  end if;

  insert into FND_MENU_ENTRIES (
    MENU_ID,
    ENTRY_SEQUENCE,
    SUB_MENU_ID,
    FUNCTION_ID,
    GRANT_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MENU_ID,
    X_ENTRY_SEQUENCE,
    X_SUB_MENU_ID,
    X_FUNCTION_ID,
    L_GRANT_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

	-- Added for Function Security Cache Invalidation Project.
	fnd_function_security_cache.insert_menu_entry(X_MENU_ID, X_SUB_MENU_ID, X_FUNCTION_ID);

  insert into FND_MENU_ENTRIES_TL (
    MENU_ID,
    ENTRY_SEQUENCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    PROMPT,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MENU_ID,
    X_ENTRY_SEQUENCE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    decode(x_PROMPT,
           fnd_load_util.null_value, null,
           null, x_prompt,
           X_PROMPT),
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_MENU_ENTRIES_TL T
    where T.MENU_ID = X_MENU_ID
    and T.ENTRY_SEQUENCE = X_ENTRY_SEQUENCE
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
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  L_GRANT_FLAG VARCHAR2(1);

  cursor c is select
      SUB_MENU_ID,
      FUNCTION_ID,
      GRANT_FLAG
    from FND_MENU_ENTRIES
    where MENU_ID = X_MENU_ID
    and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE
    for update of MENU_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PROMPT,
      DESCRIPTION
    from FND_MENU_ENTRIES_TL
    where MENU_ID = X_MENU_ID
    and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE
    and LANGUAGE = userenv('LANG')
    for update of MENU_ID nowait;
  tlinfo c1%rowtype;

begin
  /* for bug 2216556 default the grant_flag to maintain compatibility with*/
  /* old loader data files that don't have GRANT_FLAG */
  if (X_GRANT_FLAG is NULL) then
    L_GRANT_FLAG := 'Y';
  else
    L_GRANT_FLAG := substrb(X_GRANT_FLAG,1,1);
  end if;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SUB_MENU_ID = X_SUB_MENU_ID)
           OR ((recinfo.SUB_MENU_ID is null) AND (X_SUB_MENU_ID is null)))
      AND ((recinfo.FUNCTION_ID = X_FUNCTION_ID)
           OR ((recinfo.FUNCTION_ID is null) AND (X_FUNCTION_ID is null)))
      AND ((recinfo.GRANT_FLAG = L_GRANT_FLAG)
           OR ((recinfo.GRANT_FLAG is null) AND (L_GRANT_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    ((tlinfo.PROMPT = X_PROMPT)
           OR ((tlinfo.PROMPT is null) AND (X_PROMPT is null)))
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  L_GRANT_FLAG VARCHAR2(1);
  L_SUB_MENU_ID NUMBER;
  L_FUNCTION_ID NUMBER;
begin
  /* for bug 2216556 default the grant_flag to maintain compatibility with*/
  /* old loader data files that don't have GRANT_FLAG */
  if (X_GRANT_FLAG is NULL) then
    L_GRANT_FLAG := 'Y';
  else
    L_GRANT_FLAG := substrb(X_GRANT_FLAG,1,1);
  end if;

	-- Added for Function Security Cache Invalidation Project
	begin
		-- Acquire sub_menu_id using menu_id and entry_sequence.
		select sub_menu_id into L_SUB_MENU_ID
		from fnd_menu_entries
		where menu_id = X_MENU_ID
		and   entry_sequence = X_ENTRY_SEQUENCE;

	exception
		when no_data_found then
			L_SUB_MENU_ID := null;
			return;
	end;

	-- Added for Function Security Cache Invalidation Project
	begin
		-- Acquire function_id using menu_id and entry_sequence.
		select function_id into L_FUNCTION_ID
		from fnd_menu_entries
		where menu_id = X_MENU_ID
		and   entry_sequence = X_ENTRY_SEQUENCE;

	exception
		when no_data_found then
			L_FUNCTION_ID := null;
			return;
	end;

  update FND_MENU_ENTRIES set
    SUB_MENU_ID = X_SUB_MENU_ID,
    FUNCTION_ID = X_FUNCTION_ID,
    GRANT_FLAG = L_GRANT_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MENU_ID = X_MENU_ID
  and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;

  if (sql%notfound) then
		raise no_data_found;
  else
		-- This means that a menu entry was updated.
		-- Added for Function Security Cache Invalidation Project
      fnd_function_security_cache.update_menu_entry(X_MENU_ID, L_SUB_MENU_ID, L_FUNCTION_ID);
      fnd_function_security_cache.update_menu_entry(X_MENU_ID, X_SUB_MENU_ID, X_FUNCTION_ID);
  end if;

  update FND_MENU_ENTRIES_TL
      set prompt = X_PROMPT,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MENU_ID = X_MENU_ID
  and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure BUMP_ROW(
	X_USER_ID in NUMBER,
	X_SHIFT_VALUE in NUMBER,
	X_ENTRY_SEQUENCE in NUMBER,
	X_MENU_ID in NUMBER
)is

	l_sub_menu_id number;
	l_function_id number;

begin
	-- Bump tl table
	-- Bug 5579233. Commented WHO col's update during bumping.
	-- This is becoz of the changes in fnd_load_util.upload_test() api in R12
	-- which is now considering only LUD but not LUB to return TRUE/FALSE.
	-- Complete details can be found in bug#5579233
	update	fnd_menu_entries_tl
	set		entry_sequence = entry_sequence + X_SHIFT_VALUE
				--last_update_date = sysdate,
				--last_updated_by = 1,
				--last_update_login = 0
	where		menu_id = X_MENU_ID
	and		entry_sequence = X_ENTRY_SEQUENCE;

	begin
		-- Added for Function Security Cache Invalidation Project
		-- Acquire sub_menu_id using menu_id and entry_sequence.
		select sub_menu_id into l_sub_menu_id
		from fnd_menu_entries
		where menu_id = X_MENU_ID
		and   entry_sequence = X_ENTRY_SEQUENCE;

	exception
		when no_data_found then
			l_sub_menu_id := null;
			return;
	end;

	begin
		-- Added for Function Security Cache Invalidation Project
		-- Acquire function_id using menu_id and entry_sequence.
		select function_id into l_function_id
		from fnd_menu_entries
		where menu_id = X_MENU_ID
		and   entry_sequence = X_ENTRY_SEQUENCE;

	exception
		when no_data_found then
			l_function_id := null;
			return;
	end;

	-- Bump base table
	-- Bug 5579233. Commented WHO col's update during bumping.
	-- This is becoz of the changes in fnd_load_util.upload_test() api in R12
	-- which is now considering only LUD but not LUB to return TRUE/FALSE.
	-- Complete details can be found in bug#5579233
	update	fnd_menu_entries
	set		entry_sequence = entry_sequence + X_SHIFT_VALUE
				--last_update_date = sysdate,
				--last_updated_by = 1,
				--last_update_login = 0
	where		menu_id = X_MENU_ID
	and		entry_sequence = X_ENTRY_SEQUENCE;

	fnd_function_security_cache.update_menu_entry(X_MENU_ID, l_sub_menu_id, l_function_id);

end BUMP_ROW;

/* Overloaded version below */
procedure LOAD_ROW (
  X_MODE in VARCHAR2,
  X_ENT_SEQUENCE VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_SUB_MENU_NAME in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
  fnd_menu_entries_pkg.LOAD_ROW (
  X_MODE => X_MODE,
  X_ENT_SEQUENCE => X_ENT_SEQUENCE,
  X_MENU_NAME => X_MENU_NAME,
  X_SUB_MENU_NAME => X_SUB_MENU_NAME,
  X_FUNCTION_NAME => X_FUNCTION_NAME,
  X_GRANT_FLAG => X_GRANT_FLAG,
  X_PROMPT => X_PROMPT,
  X_DESCRIPTION => X_DESCRIPTION,
  X_OWNER => X_OWNER,
  X_CUSTOM_MODE => null,
  X_LAST_UPDATE_DATE => null
);
end LOAD_ROW;

/* Overloaded version above */
procedure LOAD_ROW (
  X_MODE             in VARCHAR2,
  X_ENT_SEQUENCE        VARCHAR2,
  X_MENU_NAME        in VARCHAR2,
  X_SUB_MENU_NAME    in VARCHAR2,
  X_FUNCTION_NAME    in VARCHAR2,
  X_GRANT_FLAG       in VARCHAR2,
  X_PROMPT           in VARCHAR2,
  X_DESCRIPTION      in VARCHAR2,
  X_OWNER            in VARCHAR2,
  X_CUSTOM_MODE      in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
  row_id           varchar2(64);
  sub_mnu_id       number;
  mnu_id           number;
  fun_id           number;
  eseq             number;
  eseqmatch        varchar2(1);
  shiftseq         number;
  X_ENTRY_SEQUENCE number;
  v_mode             varchar2(20);
  f_luby           number;  -- entity owner in file
  f_ludate         date;    -- entity update date in file
  db_luby          number;  -- entity owner in db
  db_ludate        date;    -- entity update date in db
  L_GRANT_FLAG     VARCHAR2(1);
  l_sub_menu_name  varchar2(4000); -- bug2438503
  l_function_name  varchar2(4000); -- bug2438503
  l_sub_menu_id    number; -- Function Security Cache Invalidation
  l_function_id    number; -- Function Security Cache Invalidation

  CURSOR c_mnu_entry IS
  	SELECT	sub_menu_id, function_id
  	FROM		fnd_menu_entries E1
  	WHERE		E1.MENU_ID = mnu_id
        and exists (select NULL
                      from FND_MENU_ENTRIES E2
                     where E1.MENU_ID = E2.MENU_ID
                       and NVL(E1.SUB_MENU_ID, -1) = NVL(E2.SUB_MENU_ID, -1)
                       and NVL(E1.FUNCTION_ID, -1) = NVL(E2.FUNCTION_ID, -1)
                       and E1.ENTRY_SEQUENCE > E2.ENTRY_SEQUENCE);

begin
  /* for bug 2216556 default the grant_flag to maintain compatibility with*/
  /* old loader data files that don't have GRANT_FLAG */
  if (X_GRANT_FLAG is NULL) then
    L_GRANT_FLAG := 'Y';
  else
    L_GRANT_FLAG := substrb(X_GRANT_FLAG,1,1);
  end if;

  if (X_MODE = 'REPLACE' and X_CUSTOM_MODE = 'FORCE') then
    v_mode := 'REPLACE_OVERWRITE';
  elsif (X_MODE = 'MERGE' and X_CUSTOM_MODE = 'FORCE') then
    v_mode := 'MERGE_OVERWRITE';
  elsif (X_MODE = 'MERGE' and X_CUSTOM_MODE <> 'FORCE') then
    v_mode := 'MERGE_NOOVERWRITE';
  else
    v_mode := 'MERGE_NOOVERWRITE';
  end if;

  X_ENTRY_SEQUENCE := to_number(X_ENT_SEQUENCE);

  select decode(X_SUB_MENU_NAME,
                fnd_load_util.null_value, null,
                null, X_SUB_MENU_NAME,
                X_SUB_MENU_NAME) into l_sub_menu_name from dual;

  sub_mnu_id := NULL;

	if (l_sub_menu_name is not null) then
		begin
			select menu_id into sub_mnu_id
			from fnd_menus
			where menu_name = X_SUB_MENU_NAME;
		exception
			when no_data_found then
				/* The sub menu doesn't yet exist so create a dummy menu*/
				/* to serve as a temporary placeholder.  This solves bug */
				/* 2225482 about uploading menus whose children hadn't */
				/* yet been uploaded.  This dummy menu will end up getting */
				/* updated with the real menu information later on during */
				/* the load when the real menu data gets uploaded. */
				fnd_menus_pkg.LOAD_ROW(
					x_menu_name           => X_SUB_MENU_NAME,
					x_menu_type           => NULL,
					x_user_menu_name      => X_SUB_MENU_NAME,
					x_description         => NULL,
					x_owner               => X_OWNER,
					x_custom_mode         => X_CUSTOM_MODE,
					x_last_update_date    => X_LAST_UPDATE_DATE);
				begin
					select menu_id into sub_mnu_id
					from fnd_menus
					where menu_name = X_SUB_MENU_NAME;
				exception /* This should never happen since we have already loaded*/
					when no_data_found then
						fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
						fnd_message.set_token('TABLE', 'FND_MENUS');
						fnd_message.set_token('COLUMN', 'MENU_NAME');
						fnd_message.set_token('VALUE', x_sub_menu_name);
						app_exception.raise_exception;
						return;
				end;
		end;
	else
		sub_mnu_id := null;
	end if;

  select decode(X_FUNCTION_NAME,
                fnd_load_util.null_value, null,
                null, X_FUNCTION_NAME,
                X_FUNCTION_NAME) into l_function_name from dual;

  fun_id := NULL;
  if (l_function_name is not null) then
    begin
      select function_id into fun_id
      from fnd_form_functions
      where function_name = X_FUNCTION_NAME;
    exception
      when no_data_found then
        fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
        fnd_message.set_token('TABLE', 'FND_FORM_FUNCTIONS');
        fnd_message.set_token('COLUMN', 'FUNCTION_NAME');
        fnd_message.set_token('VALUE', x_function_name);
        app_exception.raise_exception;
        return;
    end;
   else fun_id := null;
  end if;

  mnu_id := NULL;
  begin
    -- FOR UPDATE is added, to make the upload of entries for the same menu
    -- from diff ldt files sequential. This is for bug 3657426.
    select menu_id into mnu_id
    from fnd_menus
    where menu_name = X_MENU_NAME
    for update;
  exception
    when no_data_found then
        fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
        fnd_message.set_token('TABLE', 'FND_MENUS');
        fnd_message.set_token('COLUMN', 'MENU_NAME');
        fnd_message.set_token('VALUE', x_menu_name);
        app_exception.raise_exception;
      return;
  end;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  -- Caculate max sequence for bumping purpose
  select nvl(max(entry_sequence), 0) + 1
  into shiftseq
  from fnd_menu_entries
  where menu_id = mnu_id;

  -- Delete orphaned rows from the TL table so they don't cause conflicts.
  -- There shouldn't ever be any, but sometimes the best laid plans...
  delete from fnd_menu_entries_tl
    where menu_id = mnu_id
    and   entry_sequence >= shiftseq;

  if (v_mode = 'REPLACE_OVERWRITE') then
    -- All entries had been pre-deleted in the menu level.
    -- So, all we have to do is insert.
    fnd_menu_entries_pkg.bump_row(f_luby, shiftseq, X_ENTRY_SEQUENCE, mnu_id);

    fnd_menu_entries_pkg.insert_row(
      X_ROWID          => row_id,
      X_MENU_ID        => mnu_id,
      X_ENTRY_SEQUENCE => X_ENTRY_SEQUENCE,
      X_SUB_MENU_ID    => sub_mnu_id,
      X_FUNCTION_ID    => fun_id,
      X_GRANT_FLAG     => L_GRANT_FLAG,
      X_PROMPT         => X_PROMPT,
      X_DESCRIPTION    => X_DESCRIPTION,
      X_CREATION_DATE  => f_ludate,
      X_CREATED_BY     => f_luby,
      X_LAST_UPDATE_DATE => f_ludate,
      X_LAST_UPDATED_BY => f_luby,
      X_LAST_UPDATE_LOGIN => 0);

    return;
  end if;

  -- Predelete any duplicate entries on this menu to avoid any
  -- problems later.  Theoretically duplicates are not allowed, this
  -- is to fix problems with existing bad data in databases.
  delete from FND_MENU_ENTRIES_TL T
  where T.MENU_ID = mnu_id
  and exists (select NULL
  from FND_MENU_ENTRIES E1, FND_MENU_ENTRIES E2
  where T.MENU_ID = E1.MENU_ID
  and T.ENTRY_SEQUENCE = E1.ENTRY_SEQUENCE
  and E1.MENU_ID = E2.MENU_ID
  and NVL(E1.SUB_MENU_ID, -1) = NVL(E2.SUB_MENU_ID, -1)
  and NVL(E1.FUNCTION_ID, -1) = NVL(E2.FUNCTION_ID, -1)
  and E1.ENTRY_SEQUENCE > E2.ENTRY_SEQUENCE);

  -- Since this delete statement may affect more than 1 record, a cursor has been created to
  -- determine the records for deletion.
  delete from FND_MENU_ENTRIES E1
  where E1.MENU_ID = mnu_id
  and exists (select NULL
  from FND_MENU_ENTRIES E2
  where E1.MENU_ID = E2.MENU_ID
  and NVL(E1.SUB_MENU_ID, -1) = NVL(E2.SUB_MENU_ID, -1)
  and NVL(E1.FUNCTION_ID, -1) = NVL(E2.FUNCTION_ID, -1)
  and E1.ENTRY_SEQUENCE > E2.ENTRY_SEQUENCE);

	-- Added for Function Security Cache Invalidation Project.
	-- Seems that I need make sure that each menu entry deleted is taken into account.
	-- This loop uses the cursor c_mnu_entry defined.
	for mentry in c_mnu_entry loop
		fnd_function_security_cache.delete_menu_entry(mnu_id,
                     mentry.sub_menu_id, mentry.function_id);
	end loop;

  begin
    -- Select this entry
    select decode(e.entry_sequence, X_ENTRY_SEQUENCE, 'Y', 'N') seqmatch,
           e.entry_sequence, e.last_updated_by, e.last_update_date
    into eseqmatch, eseq, db_luby, db_ludate
    from fnd_menu_entries e, fnd_menu_entries_tl t
    where e.menu_id = mnu_id
    and  nvl(e.sub_menu_id, -1) = nvl(sub_mnu_id, -1)
    and  nvl(e.function_id, -1) = nvl(fun_id, -1)
    and   e.menu_id = t.menu_id
    and   e.entry_sequence = t.entry_sequence
    and   userenv('LANG') = t.language;


    if ((v_mode = 'MERGE_OVERWRITE') or
         (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE))) then

      if (eseqmatch = 'N') then
        -- If row is found, but position mismatches,
        -- or if row is not found, then we are either going to
        -- update a row to a position which might conflict,
        -- or we are going to create a row with a possible
        -- position conflict.  To avoid this, any existing
        -- rows with the same sequence value must be moved

        fnd_menu_entries_pkg.bump_row(f_luby,shiftseq,X_ENTRY_SEQUENCE,mnu_id);

        -- Update sequence in tl
        update fnd_menu_entries_tl
        set entry_sequence = X_ENTRY_SEQUENCE,
            last_update_date = f_ludate,
            last_updated_by = f_luby,
            last_update_login = 0
        where menu_id = mnu_id
        and entry_sequence = eseq;

			-- Added for Function Security Cache Invalidation Project
			begin
				-- Acquire sub_menu_id using menu_id and entry_sequence.
				select sub_menu_id into l_sub_menu_id
				from fnd_menu_entries
				where menu_id = mnu_id
				and   entry_sequence = eseq;

			exception
				when no_data_found then
					l_sub_menu_id := null;
					return;
			end;

			-- Added for Function Security Cache Invalidation Project
			begin
				-- Acquire function_id using menu_id and entry_sequence.
				select function_id into l_function_id
				from fnd_menu_entries
				where menu_id = mnu_id
				and   entry_sequence = eseq;

			exception
				when no_data_found then
					l_function_id := null;
					return;
			end;

        -- Update sequence in base
        update fnd_menu_entries
        set entry_sequence = X_ENTRY_SEQUENCE,
            last_update_date = f_ludate,
            last_updated_by = f_luby,
            last_update_login = 0
        where menu_id = mnu_id
        and entry_sequence = eseq;

		  fnd_function_security_cache.update_menu_entry(mnu_id, l_sub_menu_id, l_function_id);

      end if;

      -- entry found. and sequence has been taken care of if different.
      -- Check other columns.


		-- Added for Function Security Cache Invalidation Project
		begin
			-- Acquire sub_menu_id using menu_id and entry_sequence.
			select sub_menu_id into l_sub_menu_id
			from fnd_menu_entries
			where menu_id = mnu_id
			and   entry_sequence = X_ENTRY_SEQUENCE;

		exception
			when no_data_found then
				l_sub_menu_id := null;
				return;
		end;

		-- Added for Function Security Cache Invalidation Project
		begin
			-- Acquire function_id using menu_id and entry_sequence.
			select function_id into l_function_id
			from fnd_menu_entries
			where menu_id = mnu_id
			and   entry_sequence = X_ENTRY_SEQUENCE;

		exception
			when no_data_found then
				l_function_id := null;
				return;
		end;

      /* Bug 3227451 - Removed grant flag change check.
         The last_update_date of the base table needs to be updated
         when the upload test passes even if the base table grant flag
         is not updated */

      update  fnd_menu_entries
		set     grant_flag = L_GRANT_FLAG,
		        last_update_date = f_ludate,
		        last_update_login = 0,
		        last_updated_by = f_luby
      where   entry_sequence = X_ENTRY_SEQUENCE
      and     menu_id = mnu_id;

	   fnd_function_security_cache.update_menu_entry(mnu_id, l_sub_menu_id, l_function_id);

      -- Bug2410699 - Modified condition to ensure that
      -- an update occurs when the PROMPT or DESCRIPTION
      -- from the database has a NULL value.  Also no
      -- update occurs if the PROMPT or DESCRIPTION in the
      -- data file has NULL value. Update will occur when
      -- the LDT file has the *NULL* constant defined.

      /* Bug 3227451 - Removed prompt and description change check.
         The last_update_date of the tl table needs to be updated
         when the upload test passes even if neither prompt nor
         description have changed. */
        update fnd_menu_entries_tl
        set prompt = decode(X_PROMPT,
                            fnd_load_util.null_value, null,
                            null, prompt,
                            X_PROMPT),
            description = X_DESCRIPTION,
            last_update_date = f_ludate,
            last_update_login = 0,
            last_updated_by = f_luby
        where entry_sequence = X_ENTRY_SEQUENCE
        and   menu_id = mnu_id
 	and   userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      /* Bug 3227451 - Removed update to base table version info.
         This is no longer needed since we are now updating both base and
         tl tables if either one is updated. */
    end if;
  exception
    when no_data_found then
      -- Both MERGE_OVERWRITE and MERGE_NO_OVERWRITE mode
      -- create new one in base and tl
      fnd_menu_entries_pkg.bump_row(f_luby,shiftseq, X_ENTRY_SEQUENCE, mnu_id);

      fnd_menu_entries_pkg.insert_row(
        X_ROWID          => row_id,
        X_MENU_ID        => mnu_id,
        X_ENTRY_SEQUENCE => X_ENTRY_SEQUENCE,
        X_SUB_MENU_ID    => sub_mnu_id,
        X_FUNCTION_ID    => fun_id,
        X_GRANT_FLAG     => L_GRANT_FLAG,
        X_PROMPT         => X_PROMPT,
        X_DESCRIPTION    => X_DESCRIPTION,
        X_CREATION_DATE  => f_ludate,
        X_CREATED_BY     => f_luby,
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0);
  end;
  -- Delete unreferenced entries, i.e. any entries which
  -- are greater than the linear count or which have fractional values.
  -- Do NOT delete unreferenced entries if running in insert-only mode.
  if (v_mode <> 'INSERT') then
    -- delete them
    null;
  end if;

end LOAD_ROW;


procedure DELETE_ROW (
	X_MENU_ID			in NUMBER,
	X_ENTRY_SEQUENCE	in NUMBER
	) is

	l_sub_menu_id  number;
	l_function_id  number;

begin

	-- Added for Function Security Cache Invalidation Project
	begin
		-- Acquire sub_menu_id using menu_id and entry_sequence.
		select sub_menu_id into l_sub_menu_id
		from fnd_menu_entries
		where menu_id = X_MENU_ID
		and   entry_sequence = X_ENTRY_SEQUENCE;

	exception
		when no_data_found then
			l_sub_menu_id := null;
			return;
	end;

	-- Added for Function Security Cache Invalidation Project
	begin
		-- Acquire function_id using menu_id and entry_sequence.
		select function_id into l_function_id
		from fnd_menu_entries
		where menu_id = X_MENU_ID
		and   entry_sequence = X_ENTRY_SEQUENCE;

	exception
		when no_data_found then
			l_function_id := null;
			return;
	end;

	delete from FND_MENU_ENTRIES
	where MENU_ID = X_MENU_ID
	and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;

	if (sql%notfound) then
		raise no_data_found;
	else
		-- This means that the menu entry was updated.
		-- Added for Function Security Cache Invalidation Project
		-- Acquire sub_menu_id and function_id using menu_id and entry_sequence

		fnd_function_security_cache.delete_menu_entry(X_MENU_ID, l_sub_menu_id,	l_function_id);
	end if;

	delete from FND_MENU_ENTRIES_TL
	where MENU_ID = X_MENU_ID
	and ENTRY_SEQUENCE = X_ENTRY_SEQUENCE;

	if (sql%notfound) then
		raise no_data_found;
	end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_MENU_ENTRIES_TL T
  where not exists
    (select NULL
    from FND_MENU_ENTRIES B
    where B.MENU_ID = T.MENU_ID
    and B.ENTRY_SEQUENCE = T.ENTRY_SEQUENCE
    );

  update FND_MENU_ENTRIES_TL T set (
      PROMPT,
      DESCRIPTION
    ) = (select
      B.PROMPT,
      B.DESCRIPTION
    from FND_MENU_ENTRIES_TL B
    where B.MENU_ID = T.MENU_ID
    and B.ENTRY_SEQUENCE = T.ENTRY_SEQUENCE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MENU_ID,
      T.ENTRY_SEQUENCE,
      T.LANGUAGE
  ) in (select
      SUBT.MENU_ID,
      SUBT.ENTRY_SEQUENCE,
      SUBT.LANGUAGE
    from FND_MENU_ENTRIES_TL SUBB, FND_MENU_ENTRIES_TL SUBT
    where SUBB.MENU_ID = SUBT.MENU_ID
    and SUBB.ENTRY_SEQUENCE = SUBT.ENTRY_SEQUENCE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PROMPT <> SUBT.PROMPT
      or (SUBB.PROMPT is null and SUBT.PROMPT is not null)
      or (SUBB.PROMPT is not null and SUBT.PROMPT is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_MENU_ENTRIES_TL (
    MENU_ID,
    ENTRY_SEQUENCE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    PROMPT,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MENU_ID,
    B.ENTRY_SEQUENCE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.PROMPT,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_MENU_ENTRIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_MENU_ENTRIES_TL T
    where T.MENU_ID = B.MENU_ID
    and T.ENTRY_SEQUENCE = B.ENTRY_SEQUENCE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_MENU_ID     in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  fnd_menu_entries_pkg.TRANSLATE_ROW (
    X_MENU_ID     => X_MENU_ID,
    X_SUB_MENU_ID => X_SUB_MENU_ID,
    X_FUNCTION_ID => X_FUNCTION_ID,
    X_PROMPT => X_PROMPT,
    X_DESCRIPTION => X_DESCRIPTION,
    X_OWNER => X_OWNER,
    X_CUSTOM_MODE => X_CUSTOM_MODE,
    X_LAST_UPDATE_DATE => null
  );
end TRANSLATE_ROW;

/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_MENU_ID     in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
) is
 ent_seq NUMBER;
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db

begin
  select entry_sequence into ent_seq
    from fnd_menu_entries
   where nvl(sub_menu_id, -1) = nvl(X_SUB_MENU_ID, -1)
     and nvl(function_id, -1) = nvl(X_FUNCTION_ID, -1)
     and menu_id = X_MENU_ID;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FND_MENU_ENTRIES_TL
  where MENU_ID = X_MENU_ID
  and ENTRY_SEQUENCE = ent_seq
  and userenv('LANG') = LANGUAGE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FND_MENU_ENTRIES_TL
      set prompt = decode(X_PROMPT,
                          fnd_load_util.null_value, null,
                          null, prompt,
                          X_PROMPT),
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG = userenv('LANG')
    where MENU_ID = X_MENU_ID
    and ENTRY_SEQUENCE = ent_seq
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;


-- Bug 3571184 - Removed 'sql%notfound' and 'raise no_data_found', replaced with
-- an exception handler so all SQL in this block is covered -  per request of GB
-- as in bug - we do not want to roll back any changes made for other children in
-- this tree ...  MSKEES
EXCEPTION
	WHEN NO_DATA_FOUND THEN NULL;

end TRANSLATE_ROW;


/* SUBMIT_COMPILE- Submit a concurrent request to compile the menu/entries*/
/* This routine must be called after loading, inserting, updating, or */
/* deleting data in the menu entries table.  It will submit a concurrent */
/* request which will compile that data into the */
/* FND_COMPILED_MENU_FUNCTIONS table.  This can be called just once at */
/* the end of loading a number or menu entries.  */
/* This routine will check to see if a request has been submitted and */
/* is pending, and will submit one if there is not one pending. */
/* RETURNs:  status- 'P' if the request is already pending */
/*                   'S' if the request was submitted */
/*                   'E' if an error prevented request from being submitted*/
function SUBMIT_COMPILE return varchar2 is
begin
  return(FND_JOBS_PKG.SUBMIT_MENU_COMPILE);
end SUBMIT_COMPILE;

end FND_MENU_ENTRIES_PKG;

/
