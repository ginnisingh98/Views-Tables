--------------------------------------------------------
--  DDL for Package Body PER_ABT_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABT_MIGRATION" AS
/* $Header: peabtmig.pkb 120.0 2005/05/31 04:47:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< migrateABTData >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure migrateABTData
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
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4);
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);

begin
  l_userenv_language_code := userenv('LANG');

  /*
  ** Clear out any existing data for this range of records
  **
  */
  delete from per_abs_attendance_types_tl t
  where not exists
       (select null
        from per_absence_attendance_types b
        where b.absence_attendance_type_id = t.absence_attendance_type_id
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
    ** Insert the TL rows.
    */
    insert into per_abs_attendance_types_tl(
        absence_attendance_type_id,
	language,
	source_lang,
	name,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select b.absence_attendance_type_id,
           l_current_language,
	   l_userenv_language_code,
	   b.name,
	   b.created_by,
	   b.creation_date,
	   b.last_updated_by,
	   b.last_update_date,
	   b.last_update_login
      from per_absence_attendance_types b
     where not exists (select '1'
                      from per_abs_attendance_types_tl tl
		      where tl.absence_attendance_type_id = b.absence_attendance_type_id
			  and tl.language = l_current_language);


  end loop;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end migrateABTData;

end per_abt_migration;

/
