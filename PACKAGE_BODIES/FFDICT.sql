--------------------------------------------------------
--  DDL for Package Body FFDICT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FFDICT" as
/* $Header: ffdict.pkb 120.14.12010000.2 2010/01/06 11:59:03 asnell ship $ */
--
-- Temporary storage for UE details to be used in cascade delete of DB items
-- to get round mutating ff_user_entities
--
  tmp_ue_id ff_user_entities.user_entity_id%TYPE;
  tmp_bg_id ff_user_entities.business_group_id%TYPE;
  tmp_leg_code ff_user_entities.legislation_code%TYPE;
--
-- Temporary storage for global database item information.
--
  g_glb_id ff_globals_f.global_id%TYPE;
  g_glb_ueid ff_user_entities.user_entity_id%TYPE;
  g_glb_dbi ff_database_items.user_name%TYPE;
--
g_debug boolean := hr_utility.debug_enabled;
------------------------------ fetch_ue_details -------------------------------
--
--  NAME
--    fetch_ue_details
--  DESCRIPTION
--    Fetches UE details (assuming a cascade delete from ff_user_entities is
--    not in progress).
--
-------------------------------------------------------------------------------
--
procedure fetch_ue_details(p_user_entity_id in number) is
l_business_group_id number;
l_legislation_code  varchar2(30);
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('ffdict.fetch_ue_details',1);
  end if;
--
  if tmp_ue_id is null or tmp_ue_id <> p_user_entity_id then
    begin
      select ue.business_group_id
      ,      nvl(ue.legislation_code, bg.legislation_code)
      into   l_business_group_id
      ,      l_legislation_code
      from   ff_user_entities ue
      ,      per_business_groups_perf bg
      where  ue.user_entity_id = p_user_entity_id
      and    bg.business_group_id (+)= ue.business_group_id
      ;
    exception
      when no_data_found then
        if g_debug then
          hr_utility.set_location('ffdict.fetch_ue_details',2);
        end if;
        --
        hr_utility.set_message (802, 'FF_33021_ORPHANED_DBITEMS');
        hr_utility.raise_error;
    end;
    --
    set_ue_details
    (user_entity_id    => p_user_entity_id
    ,business_group_id => l_business_group_id
    ,legislation_code  => l_legislation_code
    );
  end if;
  --
  if g_debug then
    hr_utility.set_location('ffdict.fetch_ue_details',3);
  end if;
end fetch_ue_details;
--
--------------------------- set_global_dbi_details ----------------------------
--
--  NAME
--    set_global_dbi_details
--  DESCRIPTION
--    Stores global dbi's details.
--
-------------------------------------------------------------------------------
--
procedure set_global_dbi_details (global_id in number) is
cursor csr_ueid(p_global_id in number) is
select /*+ INDEX(ue FF_USER_ENTITIES_N51) */ dbi.user_entity_id
,      dbi.user_name
from   ff_user_entities ue
,      ff_database_items dbi
where  ue.creator_type = 'S'
and    ue.creator_id = p_global_id
and    dbi.user_entity_id = ue.user_entity_id
;
l_glb_dbi  varchar2(2000);
l_glb_ueid number;
l_debug    boolean;
begin
  l_debug := hr_utility.debug_enabled;
  if l_debug then
    hr_utility.set_location('ffdict.set_global_dbi_details',1);
  end if;

  --
  -- Only fetch the details if necessary.
  --
  if g_glb_id is null or g_glb_id <> global_id then
    open csr_ueid(p_global_id => global_id);
    fetch csr_ueid
    into  l_glb_ueid
    ,     l_glb_dbi
    ;
    if csr_ueid%found then
      g_glb_id := global_id;
      g_glb_ueid := l_glb_ueid;
      g_glb_dbi := l_glb_dbi;
    else
      if l_debug then
        hr_utility.set_location('ffdict.set_global_dbi_details',2);
      end if;
    end if;
    close csr_ueid;
  end if;
exception
  when others then
    if csr_ueid%isopen then
      close csr_ueid;
    end if;
    --
    raise;
end set_global_dbi_details;
--
------------------------------ get_context_level ------------------------------
--
--  NAME
--    get_context_level
--  DESCRIPTION
--    Effectively a stub function as context levels are dynamically allocated
--    in the formula engines. The return value is always 1.
-------------------------------------------------------------------------------
--
function get_context_level return number is
--
begin
  return 1;
end get_context_level;
--
--------------------------- will_clash_with_formula ---------------------------
--
--  NAME
--    will_clash_with_formula
--  DESCRIPTION
--    Determines whether formula name will clash with other formulas in the
--    formula type passed within other business groups or legislations which
--    cannot be seen from current business group or legislation.
--    eg If bus grp and leg code are both null, the item to be added will be
--    visible from all other business groups and legislations, so if we add it
--    it may clash with an existing name, even though that name is not visible
--    from null business group.
--    If a clash is present, return TRUE, otherwise return FALSE.
--
-------------------------------------------------------------------------------
--
function will_clash_with_formula(p_item_name in varchar2,
                                 p_formula_type_id in number,
                                 p_bus_grp in number,
                                 p_leg_code in varchar2) return boolean is
  dummy varchar2(1);
  startup_mode varchar2(10);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.will_clash_with_formula',1);
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);
--
-- Ensure name does not clash with anywhere which will be able to 'see' the
-- formula being validated.
--
  select null into dummy from dual where exists
  (select null
   from ff_formulas_f a
   where a.formula_name = p_item_name
   and   a.formula_type_id = p_formula_type_id
   and
    ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = p_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          p_leg_code =
          (select b.legislation_code
           from   per_business_groups_perf b
           where  b.business_group_id = a.business_group_id)
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = p_bus_grp
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and a.legislation_code = p_leg_code)
        )
      )
    ));
  -- Exception not raised, so name will clash - return TRUE

  return TRUE;
exception
  when no_data_found then
    -- No data found, so name will not clash - return FALSE
    return FALSE;
end will_clash_with_formula;
--
----------------------------- is_used_in_formula ------------------------------
--
function is_used_in_formula (p_item_name in varchar2,
                             p_bus_grp in number,
                             p_leg_code in varchar2) return boolean is
dummy varchar2(1);
startup_mode varchar2(10);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.is_used_in_formula',1);
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);
--
  -- set error tracking information
  hr_utility.set_location('ffdict.is_used_in_formula',2);
  -- Check if there any rows in FDIU for this item but take into account
  -- the business group of the formula
  select 'X' into dummy from dual where exists
  (select null
   from ff_formulas_f a,
        ff_fdi_usages_f b
   where a.formula_id = b.formula_id
   and   (b.item_name = p_item_name or
          b.alternative_item_name = p_item_name)
   and
    ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = p_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          p_leg_code =
          (select c.legislation_code
           from   per_business_groups_perf c
           where  c.business_group_id = a.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = p_bus_grp
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and a.legislation_code = p_leg_code)
        )
      )
    ));

  -- Exception not raised, so item is used in formulae - return TRUE
  return TRUE;
exception
  when no_data_found then
  -- No data found, so item not used - return FALSE
  return FALSE;
end is_used_in_formula;
--
---------------------------- dbitl_used_in_formula ----------------------------
--
-- NOTES
-- p_language is currently unused. This may change if a purer solution is
-- tried sometime in the future.
--
function dbitl_used_in_formula (p_tl_user_name   in varchar2
                               ,p_user_name      in varchar2
                               ,p_user_entity_id in number
                               ,p_language       in varchar2
                               ) return boolean is
dummy        varchar2(1);
startup_mode varchar2(10);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.dbitl_used_in_formula',1);
  end if;

  --
  -- Get the startup mode based upon the business group and legislation.
  --
  if (tmp_ue_id is null or tmp_ue_id <> p_user_entity_id) then
    fetch_ue_details(p_user_entity_id);
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.dbitl_used_in_formula',2);
  end if;

  startup_mode := ffstup.get_mode(tmp_bg_id, tmp_leg_code);

  --
  -- Check if there any rows in FDIU for this item but take into account
  -- the business group of the formula
  --
  select 'X' into dummy from dual where exists
  (select null
   from ff_fdi_usages_f b,
        ff_formulas_f a
   where b.alternative_item_name = p_tl_user_name
   and   a.formula_id = b.formula_id
   and   a.effective_start_date = b.effective_start_date
   and
   ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = tmp_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          tmp_leg_code =
          (select c.legislation_code
           from   per_business_groups_perf c
           where  c.business_group_id = a.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = tmp_bg_id
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and
           a.legislation_code = tmp_leg_code)
        )
      )
   )
  );

  if g_debug then
    hr_utility.set_location('ffdict.dbitl_used_in_formula',3);
  end if;

  return TRUE;

exception
  when no_data_found then
    if g_debug then
      hr_utility.set_location('ffdict.dbitl_used_in_formula',4);
    end if;
    return FALSE;

end dbitl_used_in_formula;
------------------------- fetch_referencing_formulas --------------------------
--  NOTES
--    p_language is currently unused. This may change if a purer solution is
--    tried sometime in the future.
-------------------------------------------------------------------------------
--
procedure fetch_referencing_formulas
(p_tl_user_name   in varchar2
,p_user_name      in varchar2
,p_user_entity_id in number
,p_language       in varchar2
,p_formula_ids       out nocopy dbms_sql.number_table
,p_formula_names     out nocopy dbms_sql.varchar2s
,p_eff_start_dates   out nocopy dbms_sql.date_table
,p_eff_end_dates     out nocopy dbms_sql.date_table
,p_bus_group_ids     out nocopy dbms_sql.number_table
,p_leg_codes         out nocopy dbms_sql.varchar2s
) is
cursor csr_ref_formulas
(p_tl_user_name in varchar2
,p_bus_group_id in number
,p_leg_code     in varchar2
,p_startup_mode in varchar2
) is
select b.formula_id
,      a.formula_name
,      b.effective_start_date
,      b.effective_end_date
,      a.business_group_id
,      a.legislation_code
from   ff_fdi_usages_f b,
       ff_formulas_f a
where  b.alternative_item_name = p_tl_user_name
and    a.formula_id = b.formula_id
and    a.effective_start_date = b.effective_start_date
and    a.effective_end_date   = b.effective_end_date
and
( p_startup_mode = 'MASTER'
   or
   ( p_startup_mode = 'SEED'
     and
     ( a.legislation_code = p_leg_code
       or
       (a.legislation_code is null and a.business_group_id is null)
       or
       p_leg_code =
       (select c.legislation_code
        from   per_business_groups_perf c
        where  c.business_group_id = a.business_group_id
       )
     )
   )
   or
   ( p_startup_mode = 'NON-SEED'
     and
     ( a.business_group_id = p_bus_group_id
       or
       (a.legislation_code is null and a.business_group_id is null)
       or
       (a.business_group_id is null and
        a.legislation_code = p_leg_code)
     )
   )
)
union
select b.formula_id
,      a.formula_name
,      b.effective_start_date
,      b.effective_end_date
,      a.business_group_id
,      a.legislation_code
from   ff_fdi_usages_f b,
       ff_formulas_f a
where  b.item_name = p_tl_user_name
and    a.formula_id = b.formula_id
and    a.effective_start_date = b.effective_start_date
and    a.effective_end_date   = b.effective_end_date
and
( p_startup_mode = 'MASTER'
   or
   ( p_startup_mode = 'SEED'
     and
     ( a.legislation_code = p_leg_code
       or
       (a.legislation_code is null and a.business_group_id is null)
       or
       p_leg_code =
       (select c.legislation_code
        from   per_business_groups_perf c
        where  c.business_group_id = a.business_group_id
       )
     )
   )
   or
   ( p_startup_mode = 'NON-SEED'
     and
     ( a.business_group_id = p_bus_group_id
       or
       (a.legislation_code is null and a.business_group_id is null)
       or
       (a.business_group_id is null and
        a.legislation_code = p_leg_code)
     )
   )
)
;
--
l_startup_mode varchar2(20);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.fetch_referencing_formulas',10);
  end if;

  --
  -- Get the startup mode based upon the business group and legislation.
  --
  if (tmp_ue_id is null or tmp_ue_id <> p_user_entity_id) then
    fetch_ue_details(p_user_entity_id);
  end if;

  l_startup_mode := ffstup.get_mode(tmp_bg_id, tmp_leg_code);

  if g_debug then
    hr_utility.set_location('ffdict.fetch_referencing_formulas',20);
    hr_utility.trace('BG_ID: ' || tmp_bg_id || ' LEG_CODE: ' || tmp_leg_code);
    hr_utility.trace('DBI: ' || p_tl_user_name);
    hr_utility.trace('MODE: ' || l_startup_mode);
  end if;

  open csr_ref_formulas
       (p_tl_user_name => p_tl_user_name
       ,p_bus_group_id => tmp_bg_id
       ,p_leg_code     => tmp_leg_code
       ,p_startup_mode => l_startup_mode
       );

  fetch csr_ref_formulas bulk collect
  into  p_formula_ids
  ,     p_formula_names
  ,     p_eff_start_dates
  ,     p_eff_end_dates
  ,     p_bus_group_ids
  ,     p_leg_codes
  ;

  close csr_ref_formulas;

  if g_debug then
    hr_utility.set_location('ffdict.fetch_referencing_formulas',30);
  end if;

exception
  when others then
    if g_debug then
      hr_utility.set_location('ffdict.fetch_referencing_formulas',40);
    end if;

    if csr_ref_formulas%isopen then
      close csr_ref_formulas;
    end if;

    raise;
end fetch_referencing_formulas;
--
----------------------------- dbi_used_in_formula -----------------------------
--
--  NAME
--    dbi_used_in_formula
--  DESCRIPTION
--    Returns TRUE if a base database item name is used in a formula
--    (ie is referenced in the FDIU table) visible from the current business
--    group and legislation.
--  NOTES
--    The purpose of this interface is to avoid a formula becoming invalid
--    upon the update or deletion of a database item.
--
-------------------------------------------------------------------------------
--
function dbi_used_in_formula (p_user_name in varchar2
                             ,p_user_entity_id in number
                             ) return boolean is
dummy        varchar2(1);
startup_mode varchar2(10);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.dbi_used_in_formula',1);
  end if;

  --
  -- Get the startup mode based upon the business group and legislation.
  --
  if (tmp_ue_id is null or tmp_ue_id <> p_user_entity_id) then
    fetch_ue_details(p_user_entity_id);
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.dbi_used_in_formula',2);
  end if;

  startup_mode := ffstup.get_mode(tmp_bg_id, tmp_leg_code);

  --
  -- Check if there any rows in FDIU for this item but take into account
  -- the business group of the formula
  --
  select 'X' into dummy from dual where exists
  (select null
   from ff_fdi_usages_f b,
        ff_formulas_f a
   where b.item_name = p_user_name
   and   a.formula_id = b.formula_id
   and   a.effective_start_date = b.effective_start_date
   and
   ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = tmp_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          tmp_leg_code =
          (select c.legislation_code
           from   per_business_groups_perf c
           where  c.business_group_id = a.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = tmp_bg_id
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and
           a.legislation_code = tmp_leg_code)
        )
      )
   )
  );

  if g_debug then
    hr_utility.set_location('ffdict.dbi_used_in_formula',3);
  end if;

  return TRUE;

exception
  when no_data_found then
    if g_debug then
      hr_utility.set_location('ffdict.dbi_used_in_formula',4);
    end if;
    return FALSE;
end dbi_used_in_formula;
--
--------------------------- non_dbi_used_in_formula ---------------------------
--
--  NAME
--    non_dbi_used_in_formula
--
--  DESCRIPTION
--    Returns TRUE if a potential translated database item name is used in a
--    formula (ie is referenced in the FDIU table) by something other than
--    a database item. The formula is visible from the current business
--    group and legislation.
--
--  NOTES
--    The purpose of this interface is to allow for updates where a
--    translated database item is being updated with a name it is already
--    using.
--
--    The database item clash validation (tl_dbi_will_clash) must have
--    already been performed.
--
-------------------------------------------------------------------------------
--
function non_dbi_used_in_formula
(p_item_name in varchar2
,p_bus_grp   in number
,p_leg_code  in varchar2
) return boolean is
dummy               varchar2(1);
startup_mode        varchar2(10);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.non_dbi_used_in_formula',1);
  end if;

  startup_mode := ffstup.get_mode(p_bus_grp, p_leg_code);

  --
  -- Check if there any rows in FDIU for this item but take into account
  -- the business group of the formula.
  --
  select 'X' into dummy from dual where exists
  (select null
   from ff_fdi_usages_f b,
        ff_formulas_f a
   where b.item_name = p_item_name
   and   b.usage <> 'D'
   and   a.formula_id = b.formula_id
   and   a.effective_start_date = b.effective_start_date
   and
   ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = p_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          p_leg_code =
          (select c.legislation_code
           from   per_business_groups_perf c
           where  c.business_group_id = a.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = p_bus_grp
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and
           a.legislation_code = p_leg_code)
        )
      )
   )
  );

  if g_debug then
    hr_utility.set_location('ffdict.non_dbi_used_in_formula',2);
  end if;

  return TRUE;

exception
  when no_data_found then
    if g_debug then
      hr_utility.set_location('ffdict.non_dbi_used_in_formula',3);
    end if;
    return FALSE;

end non_dbi_used_in_formula;
--
--------------------------- will_clash_with_dbitem ---------------------------
--
--  NAME
--    will_clash_with_dbitem
--  DESCRIPTION
--    Determines whether named item will clash with dbitems in other
--    business groups or legislations which may not be visible from current
--    business group or legislation. eg If bus grp and leg code are both null,
--    the item to be added will be visible from all other business groups and
--    legislations, so if we add it it may clash with an existing name, even
--    though that name is not visible from null business group.
--    If a clash is present, return TRUE, otherwise return FALSE.
------------------------------------------------------------------------------
--
function will_clash_with_dbitem(p_item_name in varchar2,
                                p_bus_grp in number,
                                p_leg_code in varchar2) return boolean is
  dummy varchar2(1);
  startup_mode varchar2(10);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.will_clash_with_dbitem',1);
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);

--
-- Ensure name does not clash with anywhere which will be able to 'see' the
-- database item being validated.
--
  begin
    select null into dummy from dual where exists
    (select /*+ ORDERED
                INDEX(a FF_DATABASE_ITEMS_PK)
                INDEX(b FF_USER_ENTITIES_PK) */ null
     from ff_database_items a,
          ff_user_entities b
     where a.user_entity_id = b.user_entity_id
     and   a.user_name = p_item_name
     and
      ( startup_mode = 'MASTER'
        or
        ( startup_mode = 'SEED'
          and
          ( b.legislation_code = p_leg_code
            or
            (b.legislation_code is null and b.business_group_id is null)
            or
            p_leg_code =
            (select c.legislation_code
             from   per_business_groups_perf c
             where  c.business_group_id = b.business_group_id
            )
          )
        )
        or
        ( startup_mode = 'NON-SEED'
          and
          ( b.business_group_id = p_bus_grp
            or
            (b.legislation_code is null and b.business_group_id is null)
            or
            (b.business_group_id is null and b.legislation_code = p_leg_code)
          )
        )
      ));
   exception
     when no_data_found then
       select null into dummy from dual where exists
       (select /*+ ORDERED
                   INDEX(a FF_DATABASE_ITEMS_TL_N1)
                   INDEX(b FF_USER_ENTITIES_PK) */ null
        from ff_database_items_tl a,
             ff_user_entities b
        where a.user_entity_id = b.user_entity_id
        and   a.translated_user_name = p_item_name
        and
         ( startup_mode = 'MASTER'
           or
           ( startup_mode = 'SEED'
             and
             ( b.legislation_code = p_leg_code
               or
               (b.legislation_code is null and b.business_group_id is null)
               or
               p_leg_code =
               (select c.legislation_code
                from   per_business_groups_perf c
                where  c.business_group_id = b.business_group_id
               )
             )
           )
           or
           ( startup_mode = 'NON-SEED'
             and
             ( b.business_group_id = p_bus_grp
               or
               (b.legislation_code is null and b.business_group_id is null)
               or
               (b.business_group_id is null and b.legislation_code = p_leg_code)
             )
           )
         ));
     when others then
       raise;
  end;
  -- Exception not raised, so name will clash - return TRUE
  return TRUE;
exception
  when no_data_found then
    -- No data found, so name will not clash - return FALSE
    return FALSE;
end will_clash_with_dbitem;
--
------------------------------ tl_dbi_will_clash -----------------------------
--
--  NAME
--    tl_dbi_will_clash
--  DESCRIPTION
--    Returns TRUE if a translated user name, p_tl_user_name, clashes with
--    another database item's base or translated user name(s).
--
------------------------------------------------------------------------------
--
function tl_dbi_will_clash
(p_tl_user_name      in varchar2
,p_user_name         in varchar2
,p_user_entity_id    in number
,p_business_group_id in number
,p_legislation_code  in varchar2
) return boolean is
dummy varchar2(1);
startup_mode varchar2(10);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.tl_dbi_will_clash',1);
  end if;

  --
  -- If p_user_name = p_tl_user_name then return FALSE as p_user_name
  -- will already have been validated.
  --
  if p_user_name = p_tl_user_name then
    if g_debug then
      hr_utility.set_location('ffdict.tl_dbi_will_clash',2);
    end if;
    return FALSE;
  end if;

  --
  -- Get startup_mode based on current business group and legislation.
  --
  startup_mode :=
  ffstup.get_mode(p_business_group_id, p_legislation_code);

  begin
    --
    -- Check for clash with other FF_DATABASE_ITEMS rows.
    --
    select null into dummy from dual where exists
    (select /*+ ORDERED
                INDEX(a FF_DATABASE_ITEMS_PK)
                INDEX(b FF_USER_ENTITIES_PK) */ null
     from ff_database_items a,
          ff_user_entities b
     where a.user_name = p_tl_user_name
     and   a.user_entity_id <> p_user_entity_id
     and   a.user_entity_id = b.user_entity_id
     and
      ( startup_mode = 'MASTER'
        or
        ( startup_mode = 'SEED'
          and
          ( b.legislation_code = p_legislation_code
            or
            (b.legislation_code is null and b.business_group_id is null)
            or
            p_legislation_code =
            (select c.legislation_code
             from   per_business_groups_perf c
             where  c.business_group_id = b.business_group_id
            )
          )
        )
        or
        ( startup_mode = 'NON-SEED'
          and
          ( b.business_group_id = p_business_group_id
            or
            (b.legislation_code is null and b.business_group_id is null)
            or
            (b.business_group_id is null and b.legislation_code = p_legislation_code)
          )
        )
      ));
   exception
     when no_data_found then
       if g_debug then
         hr_utility.set_location('ffdict.tl_dbi_will_clash',3);
       end if;

       --
       -- No clash against FF_DATABASE_ITEMS so check against FF_DATABASE_ITEMS_TL.
       --
       select null into dummy from dual where exists
       (select /*+ ORDERED
                   INDEX(a FF_DATABASE_ITEMS_TL_N1)
                   INDEX(b FF_USER_ENTITIES_PK) */ null
        from ff_database_items_tl a,
             ff_user_entities b
        where a.translated_user_name = p_tl_user_name
        and   (a.user_name <> p_user_name or a.user_entity_id <> p_user_entity_id)
        and   a.user_entity_id = b.user_entity_id
        and
         ( startup_mode = 'MASTER'
           or
           ( startup_mode = 'SEED'
             and
             ( b.legislation_code = p_legislation_code
               or
               (b.legislation_code is null and b.business_group_id is null)
               or
               p_legislation_code =
               (select c.legislation_code
                from   per_business_groups_perf c
                where  c.business_group_id = b.business_group_id
               )
             )
           )
           or
           ( startup_mode = 'NON-SEED'
             and
             ( b.business_group_id = p_business_group_id
               or
               (b.legislation_code is null and b.business_group_id is null)
               or
               (b.business_group_id is null and b.legislation_code = p_legislation_code)
             )
           )
         ));
  end;

  --
  -- There is a clash.
  --
  if g_debug then
    hr_utility.set_location('ffdict.tl_dbi_will_clash',4);
  end if;

  return TRUE;
exception
  when no_data_found then
    if g_debug then
      hr_utility.set_location('ffdict.tl_dbi_will_clash',5);
    end if;
    return FALSE;
end tl_dbi_will_clash;
--
--------------------------- will_clash_with_global ---------------------------
--
--  NAME
--    will_clash_with_global
--  DESCRIPTION
--    Determines whether global will clash with other globals in other
--    business groups or legislations which cannot be seen from current
--    business group or legislation. eg If bus grp and leg code are both null,
--    the item to be added will be visible from all other business groups and
--    legislations, so if we add it it may clash with an existing name, even
--    though that name is not visible from null business group.
--    If a clash is present, return TRUE, otherwise return FALSE.
-----------------------------------------------------------------------------
--
function will_clash_with_global(p_item_name in varchar2,
                                p_bus_grp in number,
                                p_leg_code in varchar2) return boolean is
  dummy varchar2(1);
  startup_mode varchar2(10);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.will_clash_with_global',1);
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);
--
-- Ensure name does not clash with anywhere which will be able to 'see' the
-- formula being validated.
--
  begin
    select null into dummy from dual where exists
    (select null
     from ff_globals_f a
     where a.global_name = p_item_name
     and
      ( startup_mode = 'MASTER'
        or
        ( startup_mode = 'SEED'
          and
          ( a.legislation_code = p_leg_code
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            p_leg_code =
            (select c.legislation_code
             from   per_business_groups_perf c
             where  c.business_group_id = a.business_group_id
            )
          )
        )
        or
        ( startup_mode = 'NON-SEED'
          and
          ( a.business_group_id = p_bus_grp
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            (a.business_group_id is null and a.legislation_code = p_leg_code)
          )
        )
      ));
  exception
    when no_data_found then
      select null into dummy from dual where exists
      (select null
       from ff_globals_f a
       ,    ff_globals_f_tl b
       where b.global_name = p_item_name
       and   a.global_id = b.global_id
       and
        ( startup_mode = 'MASTER'
          or
          ( startup_mode = 'SEED'
            and
            ( a.legislation_code = p_leg_code
              or
              (a.legislation_code is null and a.business_group_id is null)
              or
              p_leg_code =
              (select c.legislation_code
               from   per_business_groups_perf c
               where  c.business_group_id = a.business_group_id
              )
            )
          )
          or
          ( startup_mode = 'NON-SEED'
            and
            ( a.business_group_id = p_bus_grp
              or
              (a.legislation_code is null and a.business_group_id is null)
              or
              (a.business_group_id is null and a.legislation_code = p_leg_code)
            )
          )
        ));

    when others then
      raise;
  end;
  -- Exception not raised, so name will clash - return TRUE
  return TRUE;
exception
  when no_data_found then
    -- No data found, so name will not clash - return FALSE
    return FALSE;
end will_clash_with_global;
--
--------------------------- will_clash_with_global ---------------------------
--
--  NAME
--    will_clash_with_global
--  DESCRIPTION
--    Same principle as the original will_clash_with_global, except that
--    translated names may clash with values for the same global_id.
-----------------------------------------------------------------------------
--
function will_clash_with_global(p_global_id in number,
                                p_item_name in varchar2,
                                p_bus_grp in number,
                                p_leg_code in varchar2) return boolean is
  dummy varchar2(1);
  startup_mode varchar2(10);
  l_debug      boolean := hr_utility.debug_enabled;
begin
  -- set error tracking information
  if l_debug then
    hr_utility.set_location('ffdict.will_clash_with_global:2',1);
  end if;
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);
--
-- Ensure name does not clash with anywhere which will be able to 'see' the
-- formula being validated.
--
  begin
    select null into dummy from dual where exists
    (select null
     from ff_globals_f a
     where a.global_name = p_item_name
     and   a.global_id <> p_global_id
     and
      ( startup_mode = 'MASTER'
        or
        ( startup_mode = 'SEED'
          and
          ( a.legislation_code = p_leg_code
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            p_leg_code =
            (select c.legislation_code
             from   per_business_groups_perf c
             where  c.business_group_id = a.business_group_id
            )
          )
        )
        or
        ( startup_mode = 'NON-SEED'
          and
          ( a.business_group_id = p_bus_grp
            or
            (a.legislation_code is null and a.business_group_id is null)
            or
            (a.business_group_id is null and a.legislation_code = p_leg_code)
          )
        )
      ));
  exception
    when no_data_found then
      select null into dummy from dual where exists
      (select null
       from ff_globals_f a
       ,    ff_globals_f_tl b
       where b.global_name = p_item_name
       and   a.global_id = b.global_id
       and   a.global_id <> p_global_id
       and
        ( startup_mode = 'MASTER'
          or
          ( startup_mode = 'SEED'
            and
            ( a.legislation_code = p_leg_code
              or
              (a.legislation_code is null and a.business_group_id is null)
              or
              p_leg_code =
              (select c.legislation_code
               from   per_business_groups_perf c
               where  c.business_group_id = a.business_group_id
              )
            )
          )
          or
          ( startup_mode = 'NON-SEED'
            and
            ( a.business_group_id = p_bus_grp
              or
              (a.legislation_code is null and a.business_group_id is null)
              or
              (a.business_group_id is null and a.legislation_code = p_leg_code)
            )
          )
        ));

    when others then
      raise;
  end;
  -- Exception not raised, so name will clash - return TRUE
  return TRUE;
exception
  when no_data_found then
    -- No data found, so name will not clash - return FALSE
    return FALSE;
end will_clash_with_global;
--
--------------------------- will_clash_with_entity ---------------------------
--
--  NAME
--    will_clash_with_entity
--  DESCRIPTION
--    Determines whether the name will clash with user entities in other
--    business groups or legislations which cannot be seen from current
--    business group or legislation. eg If bus grp and leg code are both null,
--    the item to be added will be visible from all other business groups and
--    legislations, so if we add it it may clash with an existing name, even
--    though that name is not visible from null business group.
--    If a clash is present, return TRUE, otherwise return FALSE.
--
------------------------------------------------------------------------------
--
function will_clash_with_entity(p_item_name in varchar2,
                                p_bus_grp in number,
                                p_leg_code in varchar2) return boolean is
  dummy varchar2(1);
  startup_mode varchar2(10);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.will_clash_with_entity',1);
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);
--
-- Ensure name does not clash with anywhere which will be able to 'see' the
-- formula being validated.
--
  select null into dummy from dual where exists
  (select null
   from ff_user_entities a
   where a.user_entity_name = p_item_name
   and
    ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = p_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          p_leg_code =
          (select c.legislation_code
           from   per_business_groups_perf c
           where  c.business_group_id = a.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = p_bus_grp
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and a.legislation_code = p_leg_code)
        )
      )
    ));
  -- Exception not raised, so name will clash - return TRUE
  return TRUE;
exception
  when no_data_found then
    -- No data found, so name will not clash - return FALSE
    return FALSE;
end will_clash_with_entity;
--
-------------------------- will_clash_with_function --------------------------
--
--  NAME
--    will_clash_with_function
--  DESCRIPTION
--    Determines whether the name will clash with functions in other
--    business groups or legislations which cannot be seen from current
--    business group or legislation. Function names must not be duplicated
--    for functions with class 'U' (User Defined).
--    Also checks for clash against ANY function alias subject to business
--    group and legislation visibility.
--    If a clash is present, return TRUE, otherwise return FALSE.
--
------------------------------------------------------------------------------
--
function will_clash_with_function(p_item_name in varchar2,
                                  p_class in varchar2,
                                  p_bus_grp in number,
                                  p_leg_code in varchar2) return boolean is
  dummy varchar2(1);
  startup_mode varchar2(10);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.will_clash_with_function',1);
--
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (p_bus_grp,p_leg_code);
--
-- Check for functions which have same name as p_item_name and class of 'U'
-- or functions which have alias the same as p_item_name
-- within the business group criteria
--
  select null into dummy from dual where exists
  (select null
   from ff_functions a
   where
   (
     (a.name = p_item_name and a.class = p_class and p_class = 'U')
     or
     (a.alias_name = p_item_name)
   )
   and
    ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( a.legislation_code = p_leg_code
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          p_leg_code =
          (select c.legislation_code
           from   per_business_groups_perf c
           where  c.business_group_id = a.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( a.business_group_id = p_bus_grp
          or
          (a.legislation_code is null and a.business_group_id is null)
          or
          (a.business_group_id is null and a.legislation_code = p_leg_code)
        )
      )
    ));
  -- Exception not raised, so name will clash - return TRUE
  return TRUE;
exception
  when no_data_found then
    -- No data found, so name will not clash - return FALSE
    return FALSE;
end will_clash_with_function;
--
-------------------------- will_clash_with_context ---------------------------
--
--  NAME
--    will_clash_with_context
--  DESCRIPTION
--    Returns TRUE if named item will clash with a name used as a context.
--    Otherwise returns FALSE.
--
------------------------------------------------------------------------------
--
function will_clash_with_context(p_item_name in varchar2) return boolean is
dummy varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.will_clash_with_context',1);
  -- Check if there any rows in FF_CONTEXTS for this name
--
  select 'X' into dummy from dual where exists
  (select null from ff_contexts where context_name = upper(p_item_name));
--
  -- Exception not raised, so item is a context - return TRUE.
  return TRUE;
exception
  when no_data_found then
  -- No data found, so item not used - return FALSE
  return FALSE;
end will_clash_with_context;
--
------------------------------ validate_formula -------------------------------
--
--  NAME
--    validate_formula
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid formula
--    name. Fails with exception and error if name is invalid.
--
-------------------------------------------------------------------------------
--
procedure validate_formula(p_formula_name in out nocopy varchar2,
                           p_formula_type_id in number,
                           p_bus_grp in number,
                           p_leg_code in varchar2) is
rgeflg varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_formula',1);
--
  begin
    -- Check if name legal format eg no spaces, or special characters
    hr_chkfmt.checkformat (p_formula_name, 'DB_ITEM_NAME', p_formula_name,
                           null,null,'Y',rgeflg,null);
  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF93_FORMULA');
      hr_utility.raise_error;
  end;
--
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_formula',2);
--
  if (will_clash_with_formula(p_formula_name, p_formula_type_id,
                              p_bus_grp,p_leg_code)) then
    hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_formula_name);
    hr_utility.set_message_token(802,'2','FF93_FORMULA');
    hr_utility.raise_error;
  end if;
end validate_formula;
--
------------------------------ validate_formula -------------------------------
--
--  NAME
--    validate_formula - Overload
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid formula
--    name. Fails with exception and error if name is invalid.
--    Overloaded to allow date effective formula creation.
--
-------------------------------------------------------------------------------
--
procedure validate_formula
  (p_formula_name         in out nocopy varchar2
  ,p_formula_type_id      in     number
  ,p_bus_grp              in     number
  ,p_leg_code             in     varchar2
  ,p_effective_start_date in     date
  ,p_effective_end_date   in out nocopy date
  ) is
--
rgeflg varchar2(1);
--
cursor csr_formula_clash(p_startup_mode varchar2) is
  select 'X'
  from   ff_formulas_f ff
  where  upper(ff.formula_name) = upper(p_formula_name)
  and    ff.formula_type_id = p_formula_type_id
  -- bug 9187920 check should not be date effective (name is reserved)
  --and    p_effective_start_date between ff.effective_start_date
  --                              and     ff.effective_end_date
  and    (p_startup_mode = 'MASTER'
  or     (p_startup_mode = 'SEED' and
           (ff.legislation_code = p_leg_code
            or
            (ff.legislation_code is null and ff.business_group_id is null)
            or
            p_leg_code =
            (select c.legislation_code
             from per_business_groups_perf c
             where c.business_group_id = ff.business_group_id
            )
          )
         )
  or     (p_startup_mode = 'NON-SEED'
  and    (ff.business_group_id = p_bus_grp
  or     (ff.legislation_code is null
  and    ff.business_group_id is null)
  or     (ff.business_group_id is null
  and    ff.legislation_code = p_leg_code))));
--
cursor csr_new_end_date(p_startup_mode varchar2) is
  select (min(ff.effective_start_date)-1)
  from   ff_formulas_f ff
  where  ff.formula_name = p_formula_name
  and    ff.formula_type_id = p_formula_type_id
  and    p_effective_end_date between ff.effective_start_date
                              and     ff.effective_end_date
  and    (p_startup_mode = 'MASTER'
  or     (p_startup_mode = 'SEED' and
           (ff.legislation_code = p_leg_code
            or
            (ff.legislation_code is null and ff.business_group_id is null)
            or
            p_leg_code =
            (select c.legislation_code
             from per_business_groups_perf c
             where c.business_group_id = ff.business_group_id
            )
          )
         )
  or     (p_startup_mode = 'NON-SEED'
  and    (ff.business_group_id = p_bus_grp
  or     (ff.legislation_code is null
  and    ff.business_group_id is null)
  or     (ff.business_group_id is null
  and    ff.legislation_code = p_leg_code))));
--
l_dummy              varchar2(1);
l_effective_end_date date := null;
l_startup_mode       varchar2(10);
l_name        ff_formulas_f.formula_name%type := p_formula_name;
l_pdummy            varchar2(80);
--
begin
--
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_formula',1);
--
--
  begin
  --
    -- Check if name legal format eg no spaces, or special characters
  --  hr_chkfmt.checkformat (p_formula_name, 'DB_ITEM_NAME', p_formula_name,
  --                         null,null,'Y',rgeflg,null);

    -- Allowing spaces in formula names(Bug Fix: 4768014)
    hr_chkfmt.checkformat (l_name,'PAY_NAME',l_pdummy, null, null, 'N', l_pdummy, null);

  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF93_FORMULA');
      hr_utility.raise_error;
  --
  end;
--
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_formula',2);
--
  l_startup_mode := ffstup.get_mode(p_bus_grp,p_leg_code);
--
  open csr_formula_clash(l_startup_mode);
  fetch csr_formula_clash into l_dummy;
  if csr_formula_clash%found then
  --
    close csr_formula_clash;
    hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_formula_name);
    hr_utility.set_message_token(802,'2','FF93_FORMULA');
    hr_utility.raise_error;
  --
  else
  --
    close csr_formula_clash;
  --
  end if;
  --
  open csr_new_end_date(l_startup_mode);
  fetch csr_new_end_date into l_effective_end_date;
  if l_effective_end_date is not null then
  --
    close csr_new_end_date;
    p_effective_end_date := l_effective_end_date;
  --
  else
  --
    close csr_new_end_date;
    p_effective_end_date := p_effective_end_date;
  --
  end if;
--
end validate_formula;
--
------------------------------ validate_dbitem -------------------------------
--
--  NAME
--    validate_dbitem
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid database
--    item name. Fails with exception and error if name is invalid.
--
------------------------------------------------------------------------------
--
procedure validate_dbitem(p_dbi_name in out nocopy varchar2,
                          p_user_entity_id in number) is
bg_id number;
leg_code varchar2(30);
rgeflg varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_dbitem',1);
--
  -- Check if name legal format eg no spaces, or special characters
  begin
    -- Check if name legal format eg no spaces, or special characters
  hr_chkfmt.checkformat (p_dbi_name, 'DB_ITEM_NAME', p_dbi_name,
                         null,null,'Y',rgeflg,null);
  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF91_DBITEM_NAME');
      hr_utility.raise_error;
  end;
--
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_dbitem',2);
--
-- Fetch business group and legislation details for current user entity
  select business_group_id, legislation_code
  into   bg_id, leg_code
  from  ff_user_entities
  where user_entity_id = p_user_entity_id;
--
-- set error tracking information
  hr_utility.set_location('ffdict.validate_dbitem',3);
--
  -- New DB item name cannot be same as existing database item visible from
  -- business group and legislation of current user_entity
  if (will_clash_with_dbitem(p_dbi_name, bg_id, leg_code)) then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_dbi_name);
    hr_utility.set_message_token(802,'2','FF91_DBITEM_NAME');
    hr_utility.raise_error;
  end if;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_dbitem',4);
--
  -- New DB item name cannot be same as existing item in any verified formula
  if (ffdict.non_dbi_used_in_formula(p_dbi_name, bg_id, leg_code)) then
    hr_utility.set_message (802,'FF75_ITEM_USED_IN_FORMULA');
    hr_utility.set_message_token('1',p_dbi_name);
    hr_utility.raise_error;
  end if;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_dbitem',5);
--
  -- New DB item name cannot be same as existing context name
  if (ffdict.will_clash_with_context(p_dbi_name)) then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_dbi_name);
    hr_utility.set_message_token(802,'2','FF92_CONTEXT');
    hr_utility.raise_error;
  end if;
end validate_dbitem;
--
-------------------------- core_validate_tl_dbitem ---------------------------
--
procedure core_validate_tl_dbitem
(p_user_name         in varchar2
,p_user_entity_id    in number
,p_tl_user_name      in out nocopy varchar2
,p_outcome              out nocopy varchar2
) is
l_tl_user_name varchar2(2000);
i              binary_integer;
j              binary_integer;
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.core_validate_tl_dbi',1);
  end if;

  --
  -- Initialise outcome to SUCCESS.
  --
  p_outcome := 'S';

  --
  -- Validate (and possibly reformat) the name so that it is a valid
  -- database item name.
  --
  l_tl_user_name :=
  ff_dbi_utils_pkg.str2dbiname(p_str => p_tl_user_name);
  p_tl_user_name := l_tl_user_name;

  if g_debug then
    hr_utility.set_location('ffdict.core_validate_tl_dbi',2);
  end if;

  --
  -- Fetch business group and legislation details for current user entity.
  --
  if (tmp_ue_id is null or tmp_ue_id <> p_user_entity_id) then
    fetch_ue_details(p_user_entity_id);
  end if;

  --
  -- New DB item name cannot be same as existing database item visible from
  -- business group and legislation of current user_entity.
  --
  if tl_dbi_will_clash
     (p_tl_user_name      => l_tl_user_name
     ,p_user_name         => p_user_name
     ,p_user_entity_id    => p_user_entity_id
     ,p_business_group_id => tmp_bg_id
     ,p_legislation_code  => tmp_leg_code
     ) then

    if g_debug then
      hr_utility.set_location('ffdict.core_validate_tl_dbi',3);
    end if;

    p_outcome := 'D';
    return;
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.core_validate_tl_dbi',4);
  end if;

  --
  -- New DB item name cannot be same as a Formula Context name.
  --
  if ffdict.will_clash_with_context(l_tl_user_name) then

    if g_debug then
      hr_utility.set_location('ffdict.core_validate_tl_dbi',5);
    end if;

    p_outcome := 'C';
    return;
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.core_validate_tl_dbi',6);
  end if;

  --
  -- New DB item name cannot be same as existing item in any verified formula.
  -- Need to ensure that there is no clash with non-DBI and Context item
  -- names used by the formula (inputs, outputs, locals).
  --
  if ffdict.non_dbi_used_in_formula
     (p_item_name => l_tl_user_name
     ,p_bus_grp   => tmp_bg_id
     ,p_leg_code  => tmp_leg_code
     ) then
    if g_debug then
      hr_utility.set_location('ffdict.core_validate_tl_dbi',7);
    end if;

    p_outcome := 'F';
    return;
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.core_validate_tl_dbi',8);
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.core_validate_tl_dbi',9);
  end if;
end core_validate_tl_dbitem;
--
------------------------------ validate_tl_dbi -------------------------------
--
procedure validate_tl_dbi
(p_user_name      in varchar2
,p_user_entity_id in number
,p_tl_user_name   in out nocopy varchar2
) is
l_tl_user_name varchar2(2000);
l_outcome      varchar2(10);
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('ffdict.validate_tl_dbi',1);
  end if;

  l_tl_user_name := p_tl_user_name;

  if g_debug then
    hr_utility.set_location('ffdict.validate_tl_dbi',2);
  end if;

  core_validate_tl_dbitem
  (p_user_name         => p_user_name
  ,p_user_entity_id    => p_user_entity_id
  ,p_tl_user_name      => l_tl_user_name
  ,p_outcome           => l_outcome
  );

  if g_debug then
    hr_utility.set_location('ffdict.validate_tl_dbi',3);
  end if;

  --
  -- New DB item name cannot be same as existing database item visible from
  -- business group and legislation of current user_entity.
  --
  if l_outcome = 'D' then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1', l_tl_user_name);
    hr_utility.set_message_token(802,'2','FF91_DBITEM_NAME');
    hr_utility.raise_error;
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.validate_tl_dbi',4);
  end if;

  --
  -- New DB item name cannot be same as existing context name.
  --
  if l_outcome = 'C' then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1', l_tl_user_name);
    hr_utility.set_message_token(802,'2','FF92_CONTEXT');
    hr_utility.raise_error;
  end if;

  if g_debug then
    hr_utility.set_location('ffdict.validate_tl_dbi',5);
  end if;

  --
  -- New DB item name cannot be same as existing item in any verified
  -- formula. Need to ensure that there is no clash with non-DBI and
  -- Context item names used by the formula (inputs, outputs, locals).
  --
  if l_outcome = 'F' then
    hr_utility.set_message (802,'FF75_ITEM_USED_IN_FORMULA');
    hr_utility.set_message_token('1', l_tl_user_name);
    hr_utility.raise_error;
  end if;

  p_tl_user_name := l_tl_user_name;
end validate_tl_dbi;
--
------------------------------ validate_context -------------------------------
--
--  NAME
--    validate_context
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid context
--    name. Fails with exception and error if name is invalid.
--
-------------------------------------------------------------------------------
--
procedure validate_context(p_ctx_name in out nocopy varchar2) is
rgeflg varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_context',1);
--
  -- Check if name legal format eg no spaces, or special characters
  begin
    -- Check if name legal format eg no spaces, or special characters
    hr_chkfmt.checkformat (p_ctx_name, 'DB_ITEM_NAME', p_ctx_name,
                           null,null,'Y',rgeflg,null);
  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF92_CONTEXT');
      hr_utility.raise_error;
  end;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_context',2);
--
  -- New DB item name cannot be same as existing context name
  if (ffdict.will_clash_with_context(p_ctx_name)) then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_ctx_name);
    hr_utility.set_message_token(802,'2','FF92_CONTEXT');
    hr_utility.raise_error;
  end if;
-- set error tracking information
  hr_utility.set_location('ffdict.validate_context',3);
--
  -- Pass null so all formulae are considered
  if (ffdict.is_used_in_formula(p_ctx_name, null, null)) then
    hr_utility.set_message (802,'FF75_ITEM_USED_IN_FORMULA');
    hr_utility.set_message_token('1',p_ctx_name);
    hr_utility.raise_error;
  end if;
-- set error tracking information
  hr_utility.set_location('ffdict.validate_context',4);
--
  -- Pass null bus grp and leg code so all DB items are considered
  if (ffdict.will_clash_with_dbitem(p_ctx_name, null, null)) then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_ctx_name);
    hr_utility.set_message_token(802,'2','FF91_DBITEM_NAME');
    hr_utility.raise_error;
  end if;
--
end validate_context;
--
---------------------------- validate_user_entity -----------------------------
--
--  NAME
--    validate_user_entity
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid user
--    entity name. Fails with exception and error if name is invalid.
--
-------------------------------------------------------------------------------
--
procedure validate_user_entity(p_ue_name in out nocopy varchar2,
                               p_bus_grp in number,
                               p_leg_code in varchar2) is
rgeflg varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_user_entity',1);
--
  -- Check if name legal format eg no spaces, or special characters
  begin
    -- Check if name legal format eg no spaces, or special characters
    hr_chkfmt.checkformat (p_ue_name, 'DB_ITEM_NAME', p_ue_name,
                           null,null,'Y',rgeflg,null);
  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF94_USER_ENTITY');
      hr_utility.raise_error;
  end;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_user_entity',2);
--
  if (will_clash_with_entity(p_ue_name,p_bus_grp,p_leg_code)) then
    hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_ue_name);
    hr_utility.set_message_token(802,'2','FF94_USER_ENTITY');
    hr_utility.raise_error;
  end if;
end validate_user_entity;
--
----------------------------- validate_function ------------------------------
--
--  NAME
--    validate_function
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid function
--    name. Fails with exception and error if name is invalid.
--
------------------------------------------------------------------------------
--
procedure validate_function(p_func_name in out nocopy varchar2,
                            p_class in varchar2,
                            p_alias in varchar2,
                            p_bus_grp in number,
                            p_leg_code in varchar2) is
rgeflg varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_function',1);
--
  -- Check if name legal format eg no spaces, or special characters
  begin
    -- Check if name legal format eg no spaces, or special characters
    hr_chkfmt.checkformat (p_func_name, 'DB_ITEM_NAME', p_func_name,
                           null,null,'Y',rgeflg,null);
  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF95_FUNCTION');
      hr_utility.raise_error;
  end;
-- set error tracking information
  hr_utility.set_location('ffdict.validate_function',2);
--
  -- Check function name
  if (will_clash_with_function(p_func_name,p_class, p_bus_grp,p_leg_code)) then
    hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_func_name);
    hr_utility.set_message_token(802,'2','FF95_FUNCTION');
    hr_utility.raise_error;
  end if;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_function',3);
--
  -- Check alias - cannot be same as another alias or function name
  if (p_alias is not null) then
    if (will_clash_with_function(p_alias,p_class, p_bus_grp,p_leg_code)) then
      hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
      hr_utility.set_message_token('1',p_func_name);
      hr_utility.set_message_token(802,'2','FF95_FUNCTION');
      hr_utility.raise_error;
    end if;
  end if;
end validate_function;
--
------------------------------ validate_global -------------------------------
--
--  NAME
--    validate_global
--  DESCRIPTION
--    Procedure which succeeds if name supplied will make a valid global
--    variable name. Fails with exception and error if name is invalid.
--
------------------------------------------------------------------------------
--
procedure validate_global(p_glob_name in out nocopy varchar2,
                          p_bus_grp in number,
                          p_leg_code in varchar2) is
rgeflg varchar2(1);
begin
-- set error tracking information
  hr_utility.set_location('ffdict.validate_global',1);
--
  -- Check if name legal format eg no spaces, or special characters
  begin
    -- Check if name legal format eg no spaces, or special characters
    hr_chkfmt.checkformat (p_glob_name, 'DB_ITEM_NAME', p_glob_name,
                           null,null,'Y',rgeflg,null);
  exception
    when hr_utility.hr_error then
      hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
      hr_utility.set_message_token(802,'VALUE_NAME','FF90_GLOBAL_NAME');
      hr_utility.raise_error;
  end;

  -- set error tracking information
  hr_utility.set_location('ffdict.validate_global',2);
--
  if (will_clash_with_global(p_glob_name,p_bus_grp,p_leg_code)) then
    hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_glob_name);
    hr_utility.set_message_token(802,'2','FF90_GLOBAL_NAME');
    hr_utility.raise_error;
  end if;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_global',3);
--
  if (is_used_in_formula(p_glob_name, p_bus_grp, p_leg_code)) then
    hr_utility.set_message(802,'FF75_ITEM_USED_IN_FORMULA');
    hr_utility.set_message_token('1',p_glob_name);
    hr_utility.raise_error;
  end if;
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_global',4);
--
  if (will_clash_with_dbitem(p_glob_name, p_bus_grp, p_leg_code)) then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_glob_name);
    hr_utility.set_message_token(802,'2','FF91_DBITEM_NAME');
    hr_utility.raise_error;
  end if;
-- set error tracking information
  hr_utility.set_location('ffdict.validate_global',5);
--
  if (will_clash_with_context(p_glob_name)) then
    hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
    hr_utility.set_message_token('1',p_glob_name);
    hr_utility.set_message_token(802,'2','FF92_CONTEXT');
    hr_utility.raise_error;
  end if;
end validate_global;
--
---------------------------- validate_tl_global -------------------------------
procedure validate_tl_global(p_global_id in number,
                             p_glob_name in varchar2,
                             p_bus_grp in number,
                             p_leg_code in varchar2) is
l_glob_name varchar2(2000);
l_dbi       varchar2(2000);
begin
  l_glob_name := p_glob_name;
  --
  -- This is an existing global - the usual case.
  --
  if p_global_id is not null then
    if will_clash_with_global(p_global_id => p_global_id
                             ,p_item_name => p_glob_name
                             ,p_bus_grp   => p_bus_grp
                             ,p_leg_code  => p_leg_code
                             ) then
      hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
      hr_utility.set_message_token('1',p_glob_name);
      hr_utility.set_message_token(802,'2','FF90_GLOBAL_NAME');
      hr_utility.raise_error;
    end if;

    if g_glb_id is null or g_glb_id <> p_global_id then
      set_global_dbi_details(global_id => p_global_id);
      if g_glb_id is null or g_glb_id <> p_global_id then
        --
        -- For some reason, the database item does not exist.
        --
        return;
      end if;
    end if;

    ffdict.validate_tl_dbi
    (p_user_name      => g_glb_dbi
    ,p_user_entity_id => g_glb_ueid
    ,p_tl_user_name   => l_glob_name
    );
  --
  -- This is a new global e.g. global translation button from form before
  -- the record has been saved.
  --
  else
    if will_clash_with_global(p_item_name => p_glob_name
                             ,p_bus_grp   => p_bus_grp
                             ,p_leg_code  => p_leg_code
                             ) then
      hr_utility.set_message(802,'FF52_NAME_ALREADY_USED');
      hr_utility.set_message_token('1',p_glob_name);
      hr_utility.set_message_token(802,'2','FF90_GLOBAL_NAME');
      hr_utility.raise_error;
    end if;

    --
    -- Now look at the generated database item name.
    --
    l_dbi := ff_dbi_utils_pkg.str2dbiname(p_str => l_glob_name);

    if (will_clash_with_dbitem(l_dbi, tmp_bg_id, tmp_leg_code)) then
      hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
      hr_utility.set_message_token('1',l_dbi);
      hr_utility.set_message_token(802,'2','FF91_DBITEM_NAME');
      hr_utility.raise_error;
    end if;

    if (ffdict.non_dbi_used_in_formula(l_dbi, tmp_bg_id, tmp_leg_code)) then
      hr_utility.set_message (802,'FF75_ITEM_USED_IN_FORMULA');
      hr_utility.set_message_token('1',l_dbi);
      hr_utility.raise_error;
    end if;

    if (ffdict.will_clash_with_context(l_dbi)) then
      hr_utility.set_message (802,'FF52_NAME_ALREADY_USED');
      hr_utility.set_message_token('1',l_dbi);
      hr_utility.set_message_token(802,'2','FF92_CONTEXT');
      hr_utility.raise_error;
    end if;
  end if;
end validate_tl_global;
--
-------------------------------- validate_rcu ---------------------------------
--
--  NAME
--    validate_rcu
--  DESCRIPTION
--    Check adding route context usage does not make any compiled formulae
--    invalid. Can also be used for checking route parameters.
--    Returns TRUE if OK, FALSE if not OK
--
-------------------------------------------------------------------------------
--
procedure validate_rcu(p_route_id in number) is
dummy varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_rcu',1);
--
  -- Look for any compiled formulas which use database items based on this
  -- route.
  select 'X' into dummy from dual
  where exists
  (
    select /*+ ORDERED
               INDEX(C FF_USER_ENTITIES_FK1)
               INDEX(B FF_DATABASE_ITEMS_FK1)
               INDEX(A FF_FDI_USAGES_F_N50) */
          null
     from ff_user_entities c,
          ff_database_items b,
          ff_fdi_usages_f a
    where a.item_name = b.user_name
    and   a.usage     = 'D'
    and   b.user_entity_id = c.user_entity_id
    and   c.route_id  = p_route_id
  );
  -- if select succeeds, then at least one compiled formula uses route
  -- so raise an error
  hr_utility.set_message (802,'FF76_WILL_INVALIDATE_FORMULA');
  hr_utility.raise_error;

exception
  -- route items not used, so succeed
  when no_data_found then
    null;
end validate_rcu;
--
-------------------------------- validate_rpv ---------------------------------
--
--  NAME
--    validate_rpv
--  DESCRIPTION
--    Check adding route parameter value does not make any compiled formulae
--    invalid.  Returns TRUE if OK, FALSE if not OK
--    Only do validation if operation is not resulting from a cascade delete
--    of user entities when this validation will have bee done already
--
-------------------------------------------------------------------------------
--
procedure validate_rpv(p_user_entity_id in number) is
  dummy varchar2(1);
  bg_id number;
  leg_code varchar2(30);
  startup_mode varchar2(10);
  mutating_table exception;
  invalid_cursor exception;
  pragma exception_init (mutating_table, -4091);
  pragma exception_init (invalid_cursor, -1001);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_rpv',1);
--
-- attempt to get BG details from ff_user_entities, which might be mutating
-- so trap error. If it is mutating, can skip validation because a cascade
-- delete is in progress and the deletion will have been validated already
--
  select business_group_id, legislation_code
  into   bg_id, leg_code
  from ff_user_entities
  where user_entity_id = p_user_entity_id;
--
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_rpv',2);
  -- get startup_mode based on current business group and legislation
  startup_mode := ffstup.get_mode (bg_id,leg_code);
--
  -- set error tracking information
  hr_utility.set_location('ffdict.validate_rpv',3);
  -- Look for any compiled formulas which use database items based on this
  -- user entity. Need to consider business group and legislation
  select 'X' into dummy from dual
  where exists
  (
    select /*+ ORDERED
               INDEX(C FF_DATABASE_ITEMS_FK1)
               INDEX(A FF_FDI_USAGES_F_N50)
               INDEX(B FF_FORMULAS_F_PK) */ null
    from ff_database_items c,
         ff_fdi_usages_f a,
         ff_formulas_f b
    where a.formula_id = b.formula_id
    and   a.item_name = c.user_name
    and   a.usage     = 'D'
    and   c.user_entity_id = p_user_entity_id
    and
    ( startup_mode = 'MASTER'
      or
      ( startup_mode = 'SEED'
        and
        ( b.legislation_code = leg_code
          or
          (legislation_code is null and business_group_id is null)
          or
          leg_code =
          (select d.legislation_code
           from   per_business_groups_perf d
           where  d.business_group_id = b.business_group_id
          )
        )
      )
      or
      ( startup_mode = 'NON-SEED'
        and
        ( b.business_group_id = bg_id
          or
          (b.legislation_code is null and b.business_group_id is null)
          or
          (b.business_group_id is null and b.legislation_code = leg_code)
        )
      )
    )
  );
  -- if select succeeds, then at least one compiled formula uses route
  -- so raise an error
  hr_utility.set_message (802,'FF76_WILL_INVALIDATE_FORMULA');
  hr_utility.raise_error;
exception
  -- route items not used, so succeed
  when no_data_found then
    -- set error tracking information
    hr_utility.set_location('ffdict.validate_rpv',4);
  when mutating_table then
    -- set error tracking information
    hr_utility.set_location('ffdict.validate_rpv',5);
  when invalid_cursor then
    hr_utility.set_location('ffdict.validate_rpv',6);
end validate_rpv;
--
---------------------------- create_global_dbitem -----------------------------
--
--  NAME
--    create_global_dbitem
--  DESCRIPTION
--    Does third party inserts to create a database item which is used within
--    formulae to access the global variable value
--
-------------------------------------------------------------------------------
--
procedure create_global_dbitem(p_name in varchar2,
                               p_data_type in varchar2,
                               p_global_id in number,
                               p_business_group_id in number,
                               p_legislation_code in varchar2,
                               p_created_by in number,
                               p_creation_date in date) is
l_route_id number;
l_route_parameter_id number;
item_present exception;
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',1);
--
-- Check whether DB item has already been created for this global
  begin
    select creator_id
    into l_route_id
    from ff_user_entities
    where creator_id = p_global_id
    and creator_type = 'S';
    raise item_present;
  exception
    when no_data_found then
       null;
  end;
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',2);
--
  -- Get route id for globals route. If not exists, create new one.
  begin
    select route_id
    into l_route_id
    from ff_routes
    where route_name = 'FF_GLOBALS';
  exception
    when no_data_found then
       l_route_id := null;
  end;
--
  if l_route_id is null then
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',3);
--
    insert into ff_routes
      (route_id,
       route_name,
       user_defined_flag,
       description,
       text,
       created_by,
       creation_date
      )
    values
      (
        ff_routes_s.nextval,
        'FF_GLOBALS',
        'N',
        'Route for globals',
        'ff_globals where global_id = &U1',
        p_created_by,
        p_creation_date
      );
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',4);
--
    insert into ff_route_parameters
      (route_parameter_id,
       route_id,
       data_type,
       parameter_name,
       sequence_no
      )
    values
      (ff_route_parameters_s.nextval,
       ff_routes_s.currval,
       'T',
       'GLOBAL_ID',
       1
      );
    -- set error tracking information
    hr_utility.set_location('ffdict.create_global_dbitem',5);
--
    select ff_routes_s.currval, ff_route_parameters_s.currval
    into   l_route_id, l_route_parameter_id
    from sys.dual;
  else
    -- set error tracking information
    hr_utility.set_location('ffdict.create_global_dbitem',6);
--
    -- Route exists so select parameter id (should only be one)
    select route_parameter_id
    into l_route_parameter_id
    from ff_route_parameters
    where route_id = l_route_id;
  end if;
--
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',7);
--
  -- Create user entity for this global
  insert into ff_user_entities
    (user_entity_id,
     business_group_id,
     legislation_code,
     route_id,
     notfound_allowed_flag,
     user_entity_name,
     creator_id,
     creator_type,
     entity_description,
     created_by,
     creation_date
    )
  values
    (ff_user_entities_s.nextval,
     p_business_group_id,
     p_legislation_code,
     l_route_id,
     'N',
     p_name||'_GLOBAL_UE',
     p_global_id,
     'S',
     'User entity for global '||p_name,
     p_created_by,
     p_creation_date
    );
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',8);
--
  -- insert parameter value for this user entity. Don't forget to add quotes
  -- for parameter value (global name)
  insert into ff_route_parameter_values
    (route_parameter_id,
     user_entity_id,
     value,
     created_by,
     creation_date
    )
  values
    (l_route_parameter_id,
     ff_user_entities_s.currval,
     p_global_id,
     p_created_by,
     p_creation_date
    );
  -- set error tracking information
  hr_utility.set_location('ffdict.create_global_dbitem',9);
--
  insert into ff_database_items
    (user_name,
     user_entity_id,
     data_type,
     definition_text,
     null_allowed_flag,
     description,
     created_by,
     creation_date
    )
  values
    (p_name,
     ff_user_entities_s.currval,
     p_data_type,
     decode(p_data_type,'D',
           'FFFUNC.CD(DECODE(DATA_TYPE,''D'',GLOBAL_VALUE,NULL))',
           'N',
           'FFFUNC.CN(DECODE(DATA_TYPE,''N'',GLOBAL_VALUE,NULL))',
           'GLOBAL_VALUE'),
     'N',
     'Database Item for '||p_name,
     p_created_by,
     p_creation_date
    );
exception
  when item_present then
    null;
end create_global_dbitem;
--
---------------------------- delete_global_dbitem -----------------------------
--
--  NAME
--    delete_global_dbitem
--  DESCRIPTION
--    Does third party deletes to remove a database item which is used within
--    formulae to access the global variable value
--
-------------------------------------------------------------------------------
--
procedure delete_global_dbitem(p_global_id in number) is
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.delete_global_dbitem',1);
--
-- Delete user entity created for this global with a cascade delete of
-- child records in ff_database_items and ff_route_parameter_values
--
  delete from ff_user_entities
  where creator_id = p_global_id
  and creator_type = 'S';
end delete_global_dbitem;
--
----------------------------- delete_ftcu_check ------------------------------
--
--  NAME
--    delete_ftcu_check
--  DESCRIPTION
--    Check deleting formula type context usage does not make any compiled
--    formulae invalid. Returns TRUE if OK, FALSE if not OK
--
------------------------------------------------------------------------------
--
procedure delete_ftcu_check(p_ftype_id in number,
                            p_context_id in number) is
dummy varchar2(1);
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.delete_ftcu_check',1);
--
  -- Look for any compiled formulas belonging to the formula type passed
  -- which use the context
  select 'X' into dummy from dual
  where exists
  (
    select null from ff_formulas_f a,
                     ff_fdi_usages_f b,
                     ff_contexts c
    where a.formula_type_id = p_ftype_id
    and   a.formula_id = b.formula_id
    and   b.item_name = upper(c.context_name)
    and   c.context_id = p_context_id
    and   b.usage = 'U'
  );
  -- if select succeeds, then at least one compiled formula uses context
  -- so raise an error
  hr_utility.set_message (802,'FF76_WILL_INVALIDATE_FORMULA');
  hr_utility.raise_error;

exception
  -- route items not used, so succeed
  when no_data_found then
    null;
end delete_ftcu_check;
--
---------------------------- delete_dbitem_check -----------------------------
--
--  NAME
--    delete_dbitem_check
--  DESCRIPTION
--    Procedure which succeeds if it is OK to delete named DB item.
--    Overloaded because sometimes business group and legislation are known
--
------------------------------------------------------------------------------
--
procedure delete_dbitem_check(p_item_name in varchar2,
                              p_business_group_id in number,
                              p_legislation_code in varchar2) is
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.delete_dbitem_check(2)',1);
--
  -- if database item used in a formula, fail
  if (ffdict.is_used_in_formula(p_item_name, p_business_group_id,
                                p_legislation_code)) then
    hr_utility.set_message(802,'FF75_ITEM_USED_IN_FORMULA');
    hr_utility.set_message_token('1',p_item_name);
    hr_utility.raise_error;
  end if;
end delete_dbitem_check;
--
---------------------------- delete_dbitem_check -----------------------------
--
--  NAME
--    delete_dbitem_check
--  DESCRIPTION
--    Procedure which succeeds if it is OK to delete named DB item.
--
------------------------------------------------------------------------------
--
procedure delete_dbitem_check(p_item_name in varchar2,
                              p_user_entity_id in number) is
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.delete_dbitem_check',1);

  -- if database item used in a formula, fail
  if ffdict.dbi_used_in_formula(p_item_name, p_user_entity_id) then
    hr_utility.set_message(802,'FF75_ITEM_USED_IN_FORMULA');
    hr_utility.set_message_token('1',p_item_name);
    hr_utility.raise_error;
  end if;
end delete_dbitem_check;
--
------------------------------- set_ue_details --------------------------------
--
--  NAME
--    set_ue_details
--  DESCRIPTION
--    Stores details of UE pending a delete (for use by delete_dbitem_check)
--
-------------------------------------------------------------------------------
--
procedure set_ue_details (user_entity_id in number,
                          business_group_id in number,
                          legislation_code in varchar2) is
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.set_ue_details',1);
--
  tmp_ue_id := user_entity_id;
  tmp_bg_id := business_group_id;
  tmp_leg_code := legislation_code;
end set_ue_details;
--
------------------------------ clear_ue_details -------------------------------
--
--  NAME
--    clear_ue_details
--  DESCRIPTION
--    Clears details of UE following a delete
--
-------------------------------------------------------------------------------
--
procedure clear_ue_details is
begin
  -- set error tracking information
  hr_utility.set_location('ffdict.clear_ue_details',1);
--
  tmp_ue_id := null;
  tmp_bg_id := null;
  tmp_leg_code := null;
end clear_ue_details;
--
---------------------------- update_global_dbitem -----------------------------
--
procedure update_global_dbitem(p_global_id    in number,
                               p_new_name     in varchar2,
                               p_description  in varchar2,
                               p_source_lang  in varchar2,
                               p_language     in varchar2) is
l_dbi_tl_name varchar2(2000);
begin
  if g_glb_id is null or g_glb_id <> p_global_id then
    set_global_dbi_details(global_id => p_global_id);
    if g_glb_id is null or g_glb_id <> p_global_id then
      --
      -- For some reason, the database item does not exist.
      --
      return;
    end if;
  end if;

  --
  -- Convert the global name to a dbi name.
  --
  ff_database_items_pkg.update_tl_row
  (x_user_name            => g_glb_dbi
  ,x_user_entity_id       => g_glb_ueid
  ,x_language             => p_language
  ,x_source_lang          => p_source_lang
  ,x_translated_user_name => p_new_name
  ,x_description          => p_description
  );
end update_global_dbitem;
--
end ffdict;

/
