--------------------------------------------------------
--  DDL for Package Body FF_DATABASE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_DATABASE_ITEMS_PKG" as
/* $Header: ffdbi01t.pkb 120.12 2006/11/30 16:11:26 arashid noship $ */

procedure insert_tl_rows
(x_user_name            in     varchar2
,x_user_entity_id       in     number
,x_language             in     varchar2
,x_translated_user_name in     varchar2
,x_description          in     varchar2
) is
l_disable_triggers varchar2(10);
begin
  --
  -- Disable trigger validation.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';

  insert into ff_database_items_tl (
    user_name,
    user_entity_id,
    translated_user_name,
    description,
    language,
    source_lang
  ) select
    x_user_name,
    x_user_entity_id,
    x_translated_user_name,
    x_description,
    l.language_code,
    x_language
  from fnd_languages l
  where l.installed_flag in ('I', 'B')
  and not exists
    (select null
    from ff_database_items_tl t
    where t.user_name = x_user_name
    and t.user_entity_id = x_user_entity_id
    and t.language = l.language_code);

  --
  -- Reset the trigger code.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

exception
  when others then
    --
    -- Reset the trigger code.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    raise;
end insert_tl_rows;

procedure insert_row
(x_rowid                in out nocopy varchar2
,x_user_name            in out nocopy varchar2
,x_user_entity_id       in            number
,x_data_type            in            varchar2
,x_definition_text      in            varchar2
,x_null_allowed_flag    in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
) is
l_disable_triggers     varchar2(2000);
l_user_name            varchar2(2000);
l_translated_user_name varchar2(2000);
begin
  l_user_name := upper(x_user_name);

  --
  -- validate database item names.
  --
  ffdict.validate_dbitem
  (p_dbi_name       => l_user_name
  ,p_user_entity_id => x_user_entity_id
  );

  l_translated_user_name := upper(x_translated_user_name);
  if l_translated_user_name <> l_user_name then
    ffdict.validate_tl_dbi
    (p_user_name      => l_user_name
    ,p_user_entity_id => x_user_entity_id
    ,p_tl_user_name   => l_translated_user_name
    );
  end if;

  --
  -- Disable trigger validation.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';

  insert into ff_database_items (
    user_name,
    user_entity_id,
    data_type,
    definition_text,
    null_allowed_flag
  ) values (
    l_user_name,
    x_user_entity_id,
    upper(x_data_type),
    x_definition_text,
    upper(x_null_allowed_flag)
  ) returning rowid
  into x_rowid
  ;

  insert_tl_rows
  (x_user_name            => l_user_name
  ,x_user_entity_id       => x_user_entity_id
  ,x_language             => userenv('LANG')
  ,x_translated_user_name => l_translated_user_name
  ,x_description          => x_description
  );

  --
  -- Reset the trigger code.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

exception
  when others then
    --
    -- Reset the trigger code.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    raise;

end insert_row;

------------------------- in_use_replaced_names ---------------------------
--
-- NAME
--   in_use_replaced_names
--
-- DESCRIPTION
--   Returns a list of translated DBI names that would disappear because
--   of the new translation, but are actually referenced by compiled
--   Formulas.
--
-- NOTES
--   USER_NAME, and TRANSLATED_USER_NAME must be in valid DBI format.
--
--   REPLACED_NAMES populated with indexes in sequence 1, 2, 3 ...
--
procedure in_use_replaced_names
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_language             in            varchar2
,x_translated_user_name in            varchar2
,x_replaced_names          out nocopy dbms_sql.varchar2s
) is
l_debug boolean := hr_utility.debug_enabled;
l_found varchar2(1);
i       binary_integer;
--
-- Cursor to fetch affected language rows.
--
cursor csr_affected_rows
(x_user_name      in varchar2
,x_user_entity_id in number
,x_new_name       in varchar2
,x_language       in varchar2
) is
select distinct translated_user_name
from   ff_database_items_tl
where  user_name = x_user_name
and    user_entity_id = x_user_entity_id
and    translated_user_name <> x_new_name
and    translated_user_name <> x_user_name
and    x_language in (language, source_lang)
;
--
-- Cursor to check that an old name remains.
--
cursor csr_name_remains
(x_user_name      in varchar2
,x_user_entity_id in number
,x_old_name       in varchar2
,x_language       in varchar2
) is
select null
from   ff_database_items_tl
where  user_name = x_user_name
and    user_entity_id = x_user_entity_id
and    translated_user_name = x_old_name
and    language <> x_language
and    source_lang <> x_language
;
begin
  if l_debug then
    hr_utility.set_location('in_use_replaced_names', 10);
  end if;

  --
  -- Verify that the existing names aren't used in any formulas.
  --
  i := 1;
  for crec in csr_affected_rows
              (x_user_name      => x_user_name
              ,x_user_entity_id => x_user_entity_id
              ,x_new_name       => x_translated_user_name
              ,x_language       => x_language
              ) loop
    --
    -- See if the old name remains on any unaffected rows.
    --
    open csr_name_remains
         (x_user_name      => x_user_name
         ,x_user_entity_id => x_user_entity_id
         ,x_old_name       => crec.translated_user_name
         ,x_language       => x_language
         );
    fetch csr_name_remains
    into  l_found;
    if csr_name_remains%notfound then
      --
      -- All instances of this name will be overwritten. Check whether or
      -- not the name is referenced in any formulas.
      --
      if ffdict.dbitl_used_in_formula
         (p_tl_user_name   => crec.translated_user_name
         ,p_user_name      => x_user_name
         ,p_user_entity_id => x_user_entity_id
         ,p_language       => null
         ) then

        if l_debug then
          hr_utility.trace
          ('Replaced name ' || crec.translated_user_name ||
           ' is still referenced by a Formula.'
          );
        end if;

        x_replaced_names(i) := crec.translated_user_name;
        i := i + 1;
      end if;
    end if;

    close csr_name_remains;
  end loop;

exception
  when others then
    if csr_name_remains%isopen then
      close csr_name_remains;
    end if;

    raise;
end in_use_replaced_names;

----------------------- handle_referencing_formulas -----------------------
--
-- NOTES
--   X_DONT_UPDATE is required because we cannot afford to invalidate
--   seeded Oracle Formulas.
--
--   X_MESSAGE_ROWIDS is used to hold customer Formula message rowids -
--   these messages would be invalid if the update is not performed.
--
procedure handle_referencing_formulas
(x_user_name      in varchar2
,x_user_entity_id in number
,x_tl_user_name   in varchar2
,x_old_tl_name    in varchar2
,x_language       in varchar2
,x_dont_update    in out nocopy boolean
,x_message_rowids in out nocopy dbms_sql.varchar2s
) is
l_formula_ids     dbms_sql.number_table;
l_formula_names   dbms_sql.varchar2s;
l_eff_start_dates dbms_sql.date_table;
l_eff_end_dates   dbms_sql.date_table;
l_bus_group_ids   dbms_sql.number_table;
l_leg_codes       dbms_sql.varchar2s;
l_encoded_message varchar2(2000);
l_rowid           varchar2(2000);
l_debug           boolean := hr_utility.debug_enabled;
begin

  if l_debug then
    hr_utility.set_location('handle_referencing_formulas', 10);
  end if;


  --
  -- Pass compared name to FETCH_REFERENCING_FORMULAS. Note: X_OLD_TL_NAME
  -- is used if NOT NULL.
  --
  ffdict.fetch_referencing_formulas
  (p_tl_user_name    => nvl(x_old_tl_name, x_tl_user_name)
  ,p_user_name       => x_user_name
  ,p_user_entity_id  => x_user_entity_id
  ,p_language        => x_language
  ,p_formula_ids     => l_formula_ids
  ,p_formula_names   => l_formula_names
  ,p_eff_start_dates => l_eff_start_dates
  ,p_eff_end_dates   => l_eff_end_dates
  ,p_bus_group_ids   => l_bus_group_ids
  ,p_leg_codes       => l_leg_codes
  );

  if l_debug then
    hr_utility.set_location('handle_referencing_formulas', 20);
  end if;

  if l_formula_ids.count = 0 then

    if l_debug then
      hr_utility.set_location('handle_referencing_formulas', 30);
    end if;

    return;
  end if;

  for i in 1 .. l_formula_ids.count loop
    --
    -- Seeded Formula case:
    --
    if l_bus_group_ids(i) is null then

      if l_debug then
        hr_utility.set_location('handle_referencing_formulas', 40);
      end if;

      --
      -- Cannot allow seeded Formulas to become invalid.
      --
      x_dont_update := true;

      if x_old_tl_name is not null then

        if l_debug then
          hr_utility.set_location('handle_referencing_formulas', 50);
        end if;

        fnd_message.set_name ('FF','FF_33438_OLDDBINAME_IN_SEED_FF');
        fnd_message.set_token('FORMULA', 'FF93_FORMULA', true);
        fnd_message.set_token('DBI','FF91_DBITEM_NAME', true);
        fnd_message.set_token('OLD_DBI_NAME', x_old_tl_name, false);
        fnd_message.set_token('FF_NAME', l_formula_names(i), false);
        fnd_message.set_token('EFF_DATE', to_char(l_eff_start_dates(i)), false);
        l_encoded_message := fnd_message.get_encoded;
      else

        if l_debug then
          hr_utility.set_location('handle_referencing_formulas', 60);
        end if;

        fnd_message.set_name ('FF','FF_33440_NEWDBINAME_IN_SEED_FF');
        fnd_message.set_token('FORMULA', 'FF93_FORMULA', true);
        fnd_message.set_token('DBI','FF91_DBITEM_NAME', true);
        fnd_message.set_token('NEW_DBI_NAME', x_tl_user_name, false);
        fnd_message.set_token('FF_NAME', l_formula_names(i), false);
        fnd_message.set_token('EFF_DATE', to_char(l_eff_start_dates(i)), false);
        l_encoded_message := fnd_message.get_encoded;
      end if;
    --
    -- Customer Formula case:
    --
    else

      if l_debug then
        hr_utility.set_location('handle_referencing_formulas', 70);
      end if;

      if x_old_tl_name is not null then

        if l_debug then
          hr_utility.set_location('handle_referencing_formulas', 80);
        end if;

        fnd_message.set_name ('FF','FF_33437_OLDDBINAME_IN_CUST_FF');
        fnd_message.set_token('FORMULA', 'FF93_FORMULA', true);
        fnd_message.set_token('DBI','FF91_DBITEM_NAME', true);
        fnd_message.set_token('NEW_DBI_NAME', x_tl_user_name, false);
        fnd_message.set_token('OLD_DBI_NAME', x_old_tl_name, false);
        fnd_message.set_token('FF_NAME', l_formula_names(i), false);
        fnd_message.set_token('EFF_DATE', to_char(l_eff_start_dates(i)), false);
        l_encoded_message := fnd_message.get_encoded;
      else

        if l_debug then
          hr_utility.set_location('handle_referencing_formulas', 90);
        end if;

        fnd_message.set_name ('FF','FF_33439_NEWDBINAME_IN_CUST_FF');
        fnd_message.set_token('FORMULA', 'FF93_FORMULA', true);
        fnd_message.set_token('DBI','FF91_DBITEM_NAME', true);
        fnd_message.set_token('NEW_DBI_NAME', x_tl_user_name, false);
        fnd_message.set_token('FF_NAME', l_formula_names(i), false);
        fnd_message.set_token('EFF_DATE', to_char(l_eff_start_dates(i)), false);
        l_encoded_message := fnd_message.get_encoded;
      end if;
    end if;

    if l_debug then
      hr_utility.set_location('handle_referencing_formulas', 100);
    end if;


    --
    -- Update log file.
    --
    pay_dbitl_update_errors_pkg.insert_row
    (p_user_name       => x_user_name
    ,p_user_entity_id  => x_user_entity_id
    ,p_translated_name => x_tl_user_name
    ,p_message_text    => l_encoded_message
    ,p_rowid           => l_rowid
    );

    --
    -- Invalidate the customer Formula and save log message rowid in case it needs to
    -- be deleted.
    --
    if l_bus_group_ids(i) is not null then

      if l_debug then
        hr_utility.set_location('handle_referencing_formulas', 110);
      end if;

      x_message_rowids(x_message_rowids.count + 1) := l_rowid;

      delete ff_compiled_info_f fci
      where  fci.formula_id = l_formula_ids(i)
      and    fci.effective_start_date = l_eff_start_dates(i)
      and    fci.effective_end_date = l_eff_end_dates(i)
      ;

      delete ff_fdi_usages_f fdi
      where  fdi.formula_id = l_formula_ids(i)
      and    fdi.effective_start_date = l_eff_start_dates(i)
      and    fdi.effective_end_date = l_eff_end_dates(i)
      and    fdi.item_name = x_user_name
      ;
    end if;
  end loop;

  if l_debug then
    hr_utility.set_location('handle_referencing_formulas', 200);
  end if;

end handle_referencing_formulas;

--------------------------- core_update_tl_rows ---------------------------
--
-- NAME
--   core_update_tl_rows
--
-- DESCRIPTION
--   Internal procedure for updating _TL rows. Saves repeating complex
--   code.
--
-- NOTES
--   If x_raise_errors and x_seed_update are both false then the
--   code will act as if x_raise_errors is true.
--
--   x_got_error is only set if there is an error and x_raise_errors is
--   false.
--
procedure core_update_tl_rows
(x_raise_errors      in            boolean
,x_seed_update       in            boolean
,x_user_name         in            varchar2
,x_user_entity_id    in            number
,x_language          in            varchar2
,x_tl_user_name      in out nocopy varchar2
,x_description       in            varchar2
,x_last_update_date  in            date
,x_last_updated_by   in            number
,x_last_update_login in            number
,x_got_error         in out nocopy boolean
) is
l_disable_triggers varchar2(2000);
l_user_name        varchar2(2000);
l_tl_user_name     varchar2(2000);
l_outcome          varchar2(10);
l_replaced_names   dbms_sql.varchar2s;
l_message_rowids   dbms_sql.varchar2s;
l_encoded_message  varchar2(2000);
l_debug            boolean;
l_raise_errors     boolean;
l_dont_update      boolean;
begin
  l_debug := hr_utility.debug_enabled;

  if l_debug then
    hr_utility.set_location('ffdict.core_update_tl_rows',10);
  end if;

  --
  -- Always raise errors for non-seeded update.
  --
  l_raise_errors := (x_raise_errors or not x_seed_update);
  if l_debug then
    if l_raise_errors then
      hr_utility.trace('RAISE (instead of LOG) errors.');
    else
      hr_utility.trace('LOG (instead of RAISE) errors.');
    end if;
  end if;

  l_user_name := upper(x_user_name);
  l_tl_user_name := x_tl_user_name;

  ----------------------------------------------------------
  -- Validate the proposed translated database item name. --
  ----------------------------------------------------------
  if l_raise_errors then
    if l_debug then
      hr_utility.set_location('ffdict.core_update_tl_rows',20);
    end if;

    ffdict.validate_tl_dbi
    (p_user_name      => l_user_name
    ,p_user_entity_id => x_user_entity_id
    ,p_tl_user_name   => l_tl_user_name
    );
  else
    if l_debug then
      hr_utility.set_location('ffdict.core_update_tl_rows',30);
    end if;

    ffdict.core_validate_tl_dbitem
    (p_user_name         => l_user_name
    ,p_user_entity_id    => x_user_entity_id
    ,p_tl_user_name      => l_tl_user_name
    ,p_outcome           => l_outcome
    );

    --
    -- New DB item name cannot be same as existing database item visible from
    -- business group and legislation of current user_entity.
    --
    if l_outcome = 'D' then
      fnd_message.set_name ('FF','FF52_NAME_ALREADY_USED');
      fnd_message.set_token('1', l_tl_user_name, false);
      fnd_message.set_token('2','FF91_DBITEM_NAME', true);
      l_encoded_message := fnd_message.get_encoded;

      pay_dbitl_update_errors_pkg.insert_row
      (p_user_name       => l_user_name
      ,p_user_entity_id  => x_user_entity_id
      ,p_translated_name => l_tl_user_name
      ,p_message_text    => l_encoded_message
      );

      if l_debug then
        hr_utility.set_location('ffdict.core_update_tl_rows',35);
      end if;

      x_got_error := true;
      return;
    end if;

    if l_debug then
      hr_utility.set_location('ffdict.core_update_tl_rows',40);
    end if;

    --
    -- New DB item name cannot be same as existing context name.
    --
    if l_outcome = 'C' then
      fnd_message.set_name ('FF','FF52_NAME_ALREADY_USED');
      fnd_message.set_token('1', l_tl_user_name, false);
      fnd_message.set_token('2','FF92_CONTEXT', true);
      l_encoded_message := fnd_message.get_encoded;

      pay_dbitl_update_errors_pkg.insert_row
      (p_user_name       => l_user_name
      ,p_user_entity_id  => x_user_entity_id
      ,p_translated_name => l_tl_user_name
      ,p_message_text    => l_encoded_message
      );

      if l_debug then
        hr_utility.set_location('ffdict.core_update_tl_rows',45);
      end if;

      x_got_error := true;
      return;
    end if;

    if l_debug then
      hr_utility.set_location('ffdict.core_update_tl_rows',50);
    end if;

    --
    -- New DB item name cannot be same as existing item in any verified
    -- formula. Need to ensure that there is no clash with non-DBI names
    -- used by the formula (inputs, outputs, locals).
    --
    if l_outcome = 'F' then
      l_dont_update := false;

      handle_referencing_formulas
      (x_user_name      => l_user_name
      ,x_user_entity_id => x_user_entity_id
      ,x_tl_user_name   => l_tl_user_name
      ,x_old_tl_name    => null
      ,x_language       => x_language
      ,x_dont_update    => l_dont_update
      ,x_message_rowids => l_message_rowids
      );

      if l_dont_update then

        --
        -- Delete messages that apply to custom Formulas.
        --
        pay_dbitl_update_errors_pkg.delete_rows
        (p_rowids => l_message_rowids
        );

        if l_debug then
          hr_utility.set_location('ffdict.core_update_tl_rows',55);
        end if;

        x_got_error := true;
        return;
      end if;
    end if;

    if l_debug then
      hr_utility.set_location('ffdict.core_update_tl_rows',60);
    end if;
  end if;

  -----------------------------------------------------------------------
  -- Check if any names that will disappear because of this change are --
  -- not being used by compiled formulas.                              --
  -----------------------------------------------------------------------

  --
  -- This test always needs to be performed.
  --
  if l_debug then
    hr_utility.set_location('ffdict.core_update_tl_rows',70);
  end if;

  --
  -- Verify that the existing names aren't used in any formulas.
  --
  in_use_replaced_names
  (x_user_name            => l_user_name
  ,x_user_entity_id       => x_user_entity_id
  ,x_language             => nvl(x_language, userenv('LANG'))
  ,x_translated_user_name => l_tl_user_name
  ,x_replaced_names       => l_replaced_names
  );

  if l_replaced_names.count <> 0 then
    if l_raise_errors then
      if l_debug then
        hr_utility.set_location('ffdict.core_update_tl_rows',75);
      end if;

      hr_utility.set_message(802,'FF75_ITEM_USED_IN_FORMULA');
      hr_utility.set_message_token('1', l_replaced_names(1));
      hr_utility.raise_error;
    else
      l_dont_update := false;
      --
      -- Note: not reinitialising l_message_rowids here because all
      -- messages for custom Formulas will be deleted if there is a
      -- problem with seeded Formulas.
      --
      for i in 1 .. l_replaced_names.count loop
        handle_referencing_formulas
        (x_user_name      => l_user_name
        ,x_user_entity_id => x_user_entity_id
        ,x_tl_user_name   => l_tl_user_name
        ,x_old_tl_name    => l_replaced_names(i)
        ,x_language       => x_language
        ,x_dont_update    => l_dont_update
        ,x_message_rowids => l_message_rowids
        );
      end loop;

      if l_dont_update then

        --
        -- Delete messages that apply to custom Formulas.
        --
        pay_dbitl_update_errors_pkg.delete_rows
        (p_rowids => l_message_rowids
        );

        if l_debug then
          hr_utility.set_location('ffdict.core_update_tl_rows',85);
        end if;

        x_got_error := true;
        return;
      end if;
    end if;
  end if;

  if l_debug then
    hr_utility.set_location('ffdict.core_update_tl_rows',90);
  end if;

  ----------------------------------
  -- Update the translated value. --
  ----------------------------------

  x_tl_user_name := l_tl_user_name;

  --
  -- Disable trigger validation.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';

  update ff_database_items_tl set
    translated_user_name = l_tl_user_name,
    description = x_description,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    source_lang = x_language
  where user_name = l_user_name
  and user_entity_id = x_user_entity_id
  and x_language in (language, source_lang);

  --
  -- Reset the trigger code.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

  if l_debug then
    hr_utility.set_location('ffdict.core_update_tl_rows',200);
  end if;

exception
  when others then

    if l_debug then
      hr_utility.set_location('ffdict.core_update_tl_rows',500);
    end if;

    --
    -- Reset the trigger code.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    raise;
end core_update_tl_rows;

----------------------------- update_tl_rows ------------------------------
--
-- NAME
--   update_tl_rows
--
-- DESCRIPTION
--   Procedure for updating _TL rows.
--
-- NOTES
--   Private routine exposing WHO columns.
--
procedure update_tl_rows
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_language             in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
,x_last_update_date     in            date
,x_last_updated_by      in            number
,x_last_update_login    in            number
) is
l_got_error boolean := false;
begin
  core_update_tl_rows
  (x_raise_errors      => true
  ,x_seed_update       => false
  ,x_user_name         => x_user_name
  ,x_user_entity_id    => x_user_entity_id
  ,x_language          => x_language
  ,x_tl_user_name      => x_translated_user_name
  ,x_description       => x_description
  ,x_last_update_date  => x_last_update_date
  ,x_last_updated_by   => x_last_updated_by
  ,x_last_update_login => x_last_update_login
  ,x_got_error         => l_got_error
  );
end update_tl_rows;

----------------------------- update_tl_rows ------------------------------
procedure update_tl_rows
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_language             in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
) is
begin
  update_tl_rows
  (x_user_name            => x_user_name
  ,x_user_entity_id       => x_user_entity_id
  ,x_language             => x_language
  ,x_translated_user_name => x_translated_user_name
  ,x_description          => x_description
  ,x_last_updated_by      => fnd_global.user_id
  ,x_last_update_date     => sysdate
  ,x_last_update_login    => fnd_global.login_id
  );
end update_tl_rows;

procedure update_tl_row
(x_user_name            in varchar2
,x_user_entity_id       in number
,x_language             in varchar2
,x_source_lang          in varchar2
,x_translated_user_name in varchar2
,x_description          in varchar2
) is
l_disable_triggers varchar2(2000);
l_user_name        varchar2(2000);
l_tl_name          varchar2(2000);
l_old_tl_name      varchar2(2000);
l_dummy            varchar2(2000);
l_found            boolean;
--
-- Cursor to fetch the old name.
--
cursor csr_old_name
(x_user_name      in varchar2
,x_user_entity_id in number
,x_language       in varchar2
,x_new_name       in varchar2
) is
select translated_user_name
from   ff_database_items_tl
where  user_name = x_user_name
and    user_entity_id = x_user_entity_id
and    translated_user_name <> x_new_name
and    translated_user_name <> x_user_name
and    language = x_language
;
--
-- Cursor to check that the old name remains.
--
cursor csr_name_remains
(x_user_name      in varchar2
,x_user_entity_id in number
,x_old_name       in varchar2
,x_language       in varchar2
) is
select null
from   ff_database_items_tl
where  user_name = x_user_name
and    user_entity_id = x_user_entity_id
and    translated_user_name = x_old_name
and    language <> x_language
;
begin
  --
  -- Disable trigger validation. In the future, the triggers may
  -- disappear altogether.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';
  l_user_name := upper(x_user_name);

  --
  -- Verify that the new name isn't going to clash with anything.
  --
  l_tl_name := x_translated_user_name;
  ffdict.validate_tl_dbi
  (p_user_name      => l_user_name
  ,p_user_entity_id => x_user_entity_id
  ,p_tl_user_name   => l_tl_name
  );

  --
  -- Verify that the old name isn't used in a formula.
  --
  open csr_old_name
       (x_user_name      => l_user_name
       ,x_user_entity_id => x_user_entity_id
       ,x_language       => x_language
       ,x_new_name       => l_tl_name
       );
  fetch csr_old_name
  into  l_old_tl_name
  ;
  l_found := csr_old_name%found;
  close csr_old_name;
  if l_found then
    open csr_name_remains
         (x_user_name      => l_user_name
         ,x_user_entity_id => x_user_entity_id
         ,x_old_name       => l_old_tl_name
         ,x_language       => x_language
         );
    fetch csr_name_remains
    into  l_dummy
    ;
    l_found := csr_name_remains%found;
    close csr_name_remains;

    if not l_found and
      ffdict.dbitl_used_in_formula
      (p_tl_user_name   => l_old_tl_name
      ,p_user_name      => l_user_name
      ,p_user_entity_id => x_user_entity_id
      ,p_language       => x_language
      ) then
      hr_utility.set_message(802,'FF75_ITEM_USED_IN_FORMULA');
      hr_utility.set_message_token('1', l_old_tl_name);
      hr_utility.raise_error;
    end if;
  end if;

  update ff_database_items_tl set
    translated_user_name = l_tl_name,
    description = x_description,
    source_lang = x_source_lang
  where user_name = l_user_name
  and user_entity_id = x_user_entity_id
  and language = x_language;

  --
  -- Reset the trigger code.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

exception
  when others then
    --
    -- Reset the trigger code.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    raise;
end update_tl_row;

procedure update_row
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_data_type            in            varchar2
,x_definition_text      in            varchar2
,x_null_allowed_flag    in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
) is
l_update           varchar2(2000);
l_language         varchar2(2000);
l_disable_triggers varchar2(2000);
l_user_name        varchar2(2000);
--
-- Cursor to check if any ff_database_item changes are required.
--
cursor csr_update_base
(x_user_name         in varchar2
,x_user_entity_id    in number
,x_data_type         in varchar2
,x_definition_text   in varchar2
,x_null_allowed_flag in varchar2
) is
select 'Y'
from   ff_database_items dbi
where  dbi.user_name = x_user_name
and    dbi.user_entity_id = x_user_entity_id
and    (dbi.data_type <> x_data_type or
        dbi.definition_text <> x_definition_text or
        dbi.null_allowed_flag <> x_null_allowed_flag
       )
;
begin
  --
  -- Disable trigger validation. In the future, the triggers may
  -- disappear altogether.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';

  --
  -- If anything is changed on the base table then it is necessary
  -- to check whether or not this database item is referenced by
  -- a compiled formula.
  --
  l_user_name := upper(x_user_name);

  open csr_update_base
       (x_user_name         => l_user_name
       ,x_user_entity_id    => x_user_entity_id
       ,x_data_type         => upper(x_data_type)
       ,x_definition_text   => x_definition_text
       ,x_null_allowed_flag => upper(x_null_allowed_flag)
       );
  fetch csr_update_base into l_update;
  close csr_update_base;

  if l_update = 'Y' then
    if ffdict.dbi_used_in_formula(l_user_name, x_user_entity_id) then
      hr_utility.set_message(802,'FF75_ITEM_USED_IN_FORMULA');
      hr_utility.set_message_token('1',x_user_name);
      hr_utility.raise_error;
    end if;

    update ff_database_items set
      data_type = upper(x_data_type),
      definition_text = x_definition_text,
      null_allowed_flag = upper(x_null_allowed_flag)
    where user_name = l_user_name
    and user_entity_id = x_user_entity_id;
  end if;

  --
  -- Now handle the translations.
  --
  update_tl_rows
  (x_user_name            => l_user_name
  ,x_user_entity_id       => x_user_entity_id
  ,x_language             => userenv('LANG')
  ,x_translated_user_name => x_translated_user_name
  ,x_description          => x_description
  );

  --
  -- Reset the trigger code.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

exception
  when others then
    --
    -- Reset the trigger code.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    if csr_update_base%isopen then
      close csr_update_base;
    end if;
    --
    raise;
end update_row;

------------------------- update_seeded_tl_rows ---------------------------
procedure update_seeded_tl_rows
(x_user_name            in varchar2
,x_user_entity_id       in number
,x_language             in varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in varchar2
,x_got_error               out nocopy boolean
) is
l_got_error boolean := false;
begin
  x_got_error := true;
  core_update_tl_rows
  (x_raise_errors      => false
  ,x_seed_update       => true
  ,x_user_name         => x_user_name
  ,x_user_entity_id    => x_user_entity_id
  ,x_language          => x_language
  ,x_tl_user_name      => x_translated_user_name
  ,x_description       => x_description
  ,x_last_update_date  => sysdate
  ,x_last_updated_by   => 1
  ,x_last_update_login => 0
  ,x_got_error         => l_got_error
  );
  x_got_error := l_got_error;
end update_seeded_tl_rows;

procedure delete_tl_rows
(x_user_name            in varchar2
,x_user_entity_id       in number
) is
l_user_name varchar2(2000);
begin
  l_user_name := upper(x_user_name);

  delete /*+ INDEX(dbitl FF_DATABASE_ITEMS_TL_PK) */
  from  ff_database_items_tl dbitl
  where dbitl.user_name = l_user_name
  and dbitl.user_entity_id = x_user_entity_id;
end delete_tl_rows;

procedure delete_row
(x_user_name            in varchar2
,x_user_entity_id       in number
) is
l_disable_triggers varchar2(2000);
l_user_name        varchar2(2000);
begin
  l_user_name := upper(x_user_name);

  ffdict.delete_dbitem_check
  (p_item_name      => l_user_name
  ,p_user_entity_id => x_user_entity_id
  );

  --
  -- Disable trigger validation. In the future, the triggers may
  -- disappear altogether.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';

  ff_database_items_pkg.delete_tl_rows
  (x_user_name      => l_user_name
  ,x_user_entity_id => x_user_entity_id
  );

  delete from ff_database_items
  where user_name = l_user_name
  and user_entity_id = x_user_entity_id;

  --
  -- Reset the trigger code.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

exception
  when others then
    --
    -- Reset the trigger code.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    raise;

end delete_row;

procedure add_language
is
l_disable_triggers varchar2(100);
--
l_userenv_lang varchar2(2000);
--
ueids dbms_sql.number_table;
--
l_debug boolean;
--
l_limit number := 500;
--
-- Drive off ff_user_entities.
--
cursor csr_user_entity_ids is
select a.user_entity_id
from   ff_user_entities a
where  exists
(
  select null
  from   ff_database_items b
  where  a.user_entity_id = b.user_entity_id
)
;
begin
  select userenv('LANG')
  into   l_userenv_lang
  from   dual
  ;

  l_debug := hr_utility.debug_enabled;

  --
  -- Disable trigger code by setting ff_database_items_pkg.g_disable_triggers.
  --
  l_disable_triggers := ff_database_items_pkg.g_disable_triggers;
  ff_database_items_pkg.g_disable_triggers := 'Y';

  if l_debug then
    hr_utility.trace('add_language:delete');
  end if;

  delete from ff_database_items_tl t
  where (t.user_name, t.user_entity_id) not in
  (
    select /*+ use_hash(b) index_ffs(b) */ b.user_name
    ,      b.user_entity_id
    from ff_database_items b
  )
  ;

  commit;


  open csr_user_entity_ids;
  loop
    fetch csr_user_entity_ids bulk collect into ueids limit l_limit;

    if l_debug then
      hr_utility.trace('add_language:update');
    end if;

    forall i in ueids.first .. ueids.last
      update ff_database_items_tl t set (
          translated_user_name,
          description
        ) = (select
          b.translated_user_name,
          b.description
        from  ff_database_items_tl b
        where b.user_entity_id = ueids(i)
        and   b.user_name = t.user_name
        and b.user_entity_id = t.user_entity_id
        and b.language = t.source_lang)
      where (
          t.user_name,
          t.user_entity_id,
          t.language
      ) in (select
          subt.user_name,
          subt.user_entity_id,
          subt.language
        from  ff_database_items_tl subb, ff_database_items_tl subt
        where subb.user_entity_id = ueids(i)
        and subb.user_name = subt.user_name
        and subb.user_entity_id = subt.user_entity_id
        and subb.language = subt.source_lang
        and (subb.translated_user_name <> subt.translated_user_name
          or subb.description <> subt.description
          or (subb.description is null and subt.description is not null)
          or (subb.description is not null and subt.description is null)
      ));

    commit;

    if l_debug then
      hr_utility.trace('add_language:insert');
    end if;

    forall i in ueids.first .. ueids.last
      insert into ff_database_items_tl (
        user_name,
        user_entity_id,
        translated_user_name,
        description,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date,
        language,
        source_lang
      ) select
        b.user_name,
        b.user_entity_id,
        b.translated_user_name,
        b.description,
        b.last_update_date,
        b.last_updated_by,
        b.last_update_login,
        b.created_by,
        b.creation_date,
        l.language_code,
        b.source_lang
      from ff_database_items_tl b,
           fnd_languages l
      where l.installed_flag in ('I', 'B')
      and b.user_entity_id = ueids(i)
      and b.language = l_userenv_lang
      and not exists
      (select null
       from ff_database_items_tl t
       where t.user_name = b.user_name
       and t.user_entity_id = b.user_entity_id
       and t.language = l.language_code)
      ;

    commit;

    --
    -- Do we need to exit the loop ?
    --
    exit when ueids.count < l_limit or csr_user_entity_ids%notfound;
  end loop;

  --
  -- Reset triggers.
  --
  ff_database_items_pkg.g_disable_triggers := l_disable_triggers;

  close csr_user_entity_ids;

  return;

exception
  when others then
    --
    -- Reset triggers.
    --
    if l_disable_triggers is not null then
      ff_database_items_pkg.g_disable_triggers := l_disable_triggers;
    end if;

    if csr_user_entity_ids%isopen then
      close csr_user_entity_ids;
    end if;
    --
    raise;
end add_language;

procedure translate_row
(x_user_name            in varchar2
,x_legislation_code     in varchar2
,x_translated_user_name in varchar2
,x_description          in varchar2
,x_language             in varchar2
,x_owner                in varchar2
) is
l_user_name            varchar2(512);
l_language             varchar2(32);
l_translated_user_name varchar2(512);
l_user_entity_id       number;
l_updated_by           number;
l_found                boolean;
l_debug                boolean;
--
-- Cursor to find the database item in question.
--
cursor csr_find_dbi
(x_user_name        in varchar2
,x_legislation_code in varchar2
) is
select ue.user_entity_id
from   ff_database_items dbi
,      ff_user_entities ue
where  dbi.user_name = x_user_name
and    ue.user_entity_id = dbi.user_entity_id
and    (ue.legislation_code = x_legislation_code or
        ue.legislation_code is null)
;
--
l_got_error boolean := false;
begin
  l_debug := hr_utility.debug_enabled;

  --
  -- Set the language.
  --
  if x_language is null then
    l_language := userenv('LANG');
  else
    l_language := x_language;
  end if;

  if l_debug then
    hr_utility.trace('LANGUAGE: ' || l_language);
  end if;

  --
  -- Find the database item.
  --
  l_user_name := upper(x_user_name);
  open csr_find_dbi
  (x_user_name        => l_user_name
  ,x_legislation_code => x_legislation_code
  );
  fetch csr_find_dbi
  into  l_user_entity_id
  ;
  l_found := csr_find_dbi%found;
  close csr_find_dbi;

  --
  -- The database item was not found so there is nothing to translate.
  --
  if not l_found then
    if l_debug then
      hr_utility.trace
      ('Could not find ' || l_user_name || ':' || x_legislation_code
      );
    end if;
    return;
  end if;

  --
  -- Now handle the translation. CORE_UPDATE_TL_ROWS will perform any
  -- necessary name format conversions.
  --
  l_translated_user_name := x_translated_user_name;

  if x_owner = 'SEED' then
    l_updated_by := 1;
  else
    l_updated_by := 0;
  end if;

  core_update_tl_rows
  (x_raise_errors      => (x_owner <> 'SEED')
  ,x_seed_update       => (x_owner = 'SEED')
  ,x_user_name         => l_user_name
  ,x_user_entity_id    => l_user_entity_id
  ,x_language          => l_language
  ,x_tl_user_name      => l_translated_user_name
  ,x_description       => x_description
  ,x_last_update_date  => sysdate
  ,x_last_updated_by   => l_updated_by
  ,x_last_update_login => 0
  ,x_got_error         => l_got_error
  );

  if l_debug then
    if l_got_error then
       hr_utility.trace('No update with name ' || l_translated_user_name);
    else
      hr_utility.trace('Update with name ' || l_translated_user_name);
    end if;
  end if;

exception
  when others then
    if csr_find_dbi%isopen then
      close csr_find_dbi;
    end if;
    --
    raise;

end translate_row;

end ff_database_items_pkg;

/
