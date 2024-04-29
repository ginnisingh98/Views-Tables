--------------------------------------------------------
--  DDL for Package Body PER_TASKFLOW_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_TASKFLOW_MIGRATION" AS
/* $Header: petflupg.pkb 115.4 2004/01/12 03:00:47 adhunter noship $ */
--
procedure migrateNavUnitdata
            ( p_process_number   IN     varchar2
            , p_max_number_proc  IN     varchar2
            , p_param1           IN     varchar2
            , p_param2           IN     varchar2
            , p_param3           IN     varchar2
            , p_param4           IN     varchar2
            , p_param5           IN     varchar2
            , p_param6           IN     varchar2
            , p_param7           IN     varchar2
            , p_param8           IN     varchar2
            , p_param9           IN     varchar2
            , p_param10          IN     varchar2
            )
--
is
  cursor csr_installed_languages is
   select language_code,
   nls_language
  from fnd_languages
  where installed_flag in ('I','B');

l_userenv_language_code	varchar2(4) := userenv('LANG');
l_current_nls_language	varchar2(30);
l_current_language	varchar2(4);

begin
/*
** clear out any existing data for this range of records
*/
delete from HR_NAVIGATION_UNITS_TL T
where not exists
   (select NULL
    from HR_NAVIGATION_UNITS B
    where B.NAV_UNIT_ID = T.NAV_UNIT_ID
    );
/*
**
** For each installed language insert a new record into the TL table for
** each record in the range provided that is present in the base table.
*/
for c_language in csr_installed_languages loop

/*
** Set language for iteration....
*/

hr_kflex_utility.set_session_nls_language(c_language.nls_language);
  l_current_language := c_language.language_code;

   /*
   ** insert the TL rows
   */

  insert into hr_navigation_units_tl (
    nav_unit_id
   ,language
   ,source_lang
   ,default_label
   ,created_by
   ,creation_date
   ,last_updated_by
   ,last_update_date
)
  select b.nav_unit_id
        ,l_current_language
        ,l_userenv_language_code
        ,b.default_label
        ,1
        ,sysdate
        ,1
        ,sysdate
  from hr_navigation_units b
  where not exists
    (select '1'
     from hr_navigation_units_tl t
     where t.nav_unit_id = b.nav_unit_id
       and t.language = l_current_language);

end loop;

hr_kflex_utility.set_session_language_code(l_userenv_language_code );

Exception
--
When Others Then
  --
  hr_kflex_utility.set_session_language_code(l_userenv_language_code );
  --
  raise;

end migrateNavUnitData;

procedure migrateNavPathdata
            ( p_process_number   IN     varchar2
            , p_max_number_proc  IN     varchar2
            , p_param1           IN     varchar2
            , p_param2           IN     varchar2
            , p_param3           IN     varchar2
            , p_param4           IN     varchar2
            , p_param5           IN     varchar2
            , p_param6           IN     varchar2
            , p_param7           IN     varchar2
            , p_param8           IN     varchar2
            , p_param9           IN     varchar2
            , p_param10          IN     varchar2
            )
--
is
  cursor csr_installed_languages is
   select language_code,
   nls_language
  from fnd_languages
  where installed_flag in ('I','B');

l_userenv_language_code	varchar2(4) := userenv('LANG');
l_current_nls_language	varchar2(30);
l_current_language	varchar2(4);

begin
/*
** clear out any existing data for this range of records
*/
delete from HR_NAVIGATION_PATHS_TL T
where not exists
   (select NULL
    from HR_NAVIGATION_PATHS B
    where B.NAV_PATH_ID = T.NAV_PATH_ID
    );
/*
**
** For each installed language insert a new record into the TL table for
** each record in the range provided that is present in the base table.
*/
for c_language in csr_installed_languages loop

/*
** Set language for iteration....
*/

hr_kflex_utility.set_session_nls_language(c_language.nls_language);
  l_current_language := c_language.language_code;

   /*
   ** insert the TL rows
   */

  insert into hr_navigation_paths_tl (
    nav_path_id
   ,language
   ,source_lang
   ,override_label
   ,created_by
   ,creation_date
   ,last_updated_by
   ,last_update_date
)
  select b.nav_path_id
        ,l_current_language
        ,l_userenv_language_code
        ,b.override_label
        ,1
        ,sysdate
        ,1
        ,sysdate
  from hr_navigation_paths b
  where not exists
    (select '1'
     from hr_navigation_paths_tl t
     where t.nav_path_id = b.nav_path_id
       and t.language = l_current_language);

end loop;

hr_kflex_utility.set_session_language_code(l_userenv_language_code );

Exception
--
When Others Then
  --
  hr_kflex_utility.set_session_language_code(l_userenv_language_code );
  --
  raise;

end migrateNavPathData;

end per_taskflow_migration;

/
