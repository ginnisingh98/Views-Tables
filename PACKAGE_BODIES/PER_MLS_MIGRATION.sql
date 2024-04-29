--------------------------------------------------------
--  DDL for Package Body PER_MLS_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MLS_MIGRATION" AS
/* $Header: pemlsmig.pkb 115.10 2004/04/29 04:34:34 adudekul noship $ */
--
-- Fix for bug 3481355 starts here. Commented out the JOB procedure.
--
-- ----------------------------------------------------------------------------
-- |--------------------------< migrateJobData >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Fix for the bug 3481355 ends here.
--
-- ----------------------------------------------------------------------------
-- |------------------------< migratePositionData >-------------------------|
-- ----------------------------------------------------------------------------
procedure migratePositionData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from hr_all_positions_f_tl
  where position_id between p_start_pkid
                        and p_end_pkid;
  */

  /*
  **
  ** Note the issue found by Jon and Phil whereby a validation/generation
  ** failure in the derivation of the string due to unresolvable references to
  ** profile options is not an error but a signaled by a null string. If this
  ** happens use the name from the base table.
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
    insert into hr_all_positions_f_tl (
        position_id,
	language,
	source_lang,
	name,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login )
    select j.position_id,
           l_current_language,
	   l_userenv_language_code,
	   nvl(fnd_flex_ext.get_segs('PER', 'POS',
	                             jd.id_flex_num,
				     jd.position_definition_id),
               j.name),
           j.created_by,
	   j.creation_date,
	   j.last_updated_by,
	   j.last_update_date,
	   j.last_update_login
      from hr_all_positions_f j,
           per_position_definitions jd
     where j.position_definition_id = jd.position_definition_id
       and j.position_id between p_start_pkid
                        and p_end_pkid
     -- Fix for bug 3359423 starts here. check for the max EED and not the EOT.
     --  and j.effective_end_date = l_end_of_time
       and j.effective_end_date = (select max(effective_end_date)
                                   from   hr_all_positions_f pos
                                   where  pos.position_id = j.position_id)
     -- Fix for bug 3359423 ends here.
       and not exists (select '1'
                         from hr_all_positions_f_tl jtl
			where jtl.position_id = j.position_id
			  and jtl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateGradeData >---------------------------|
-- ----------------------------------------------------------------------------
procedure migrateGradeData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_grades_tl
  where grade_id between p_start_pkid
                        and p_end_pkid;
  */

  /*
  **
  ** Note the issue found by Jon and Phil whereby a validation/generation
  ** failure in the derivation of the string due to unresolvable references to
  ** profile options is not an error but a signaled by a null string. If this
  ** happens use the name from the base table.
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
    insert into per_grades_tl(
        grade_id,
	language,
	source_lang,
	name,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select g.grade_id,
           l_current_language,
	   l_userenv_language_code,
	   nvl(fnd_flex_ext.get_segs('PER', 'GRD',
	                             gd.id_flex_num,
				     gd.grade_definition_id),
               g.name),
	   g.created_by,
	   g.creation_date,
	   g.last_updated_by,
	   g.last_update_date,
	   g.last_update_login
      from per_grades g,
           per_grade_definitions gd
     where g.grade_definition_id = gd.grade_definition_id
       and g.grade_id between p_start_pkid
                        and p_end_pkid
       and not exists (select '1'
                         from per_grades_tl gtl
			where gtl.grade_id = g.grade_id
			  and gtl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateRatingScaleData >---------------------------|
-- ----------------------------------------------------------------------------
procedure migrateRatingScaleData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_rating_scales_tl
  where rating_scale_id between p_start_pkid
                        and p_end_pkid;
  */

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
    insert into per_rating_scales_tl(
        rating_scale_id,
	language,
	source_lang,
	name,
	description,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select r.rating_scale_id,
           l_current_language,
	   l_userenv_language_code,
           r.name,
	   r.description,
	   r.created_by,
	   r.creation_date,
	   r.last_updated_by,
	   r.last_update_date,
	   r.last_update_login
      from per_rating_scales r
     where r.rating_scale_id between p_start_pkid
                                 and p_end_pkid
       and not exists (select '1'
                         from per_rating_scales_tl rtl
			where rtl.rating_scale_id = r.rating_scale_id
			  and rtl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateRatingLevelData >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateRatingLevelData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_rating_levels_tl
  where rating_level_id between p_start_pkid
                        and p_end_pkid;
  */

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
    insert into per_rating_levels_tl(
        rating_level_id,
	language,
	source_lang,
	name,
	behavioural_indicator,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select r.rating_level_id,
           l_current_language,
	   l_userenv_language_code,
	   r.name,
	   r.behavioural_indicator,
	   r.created_by,
	   r.creation_date,
	   r.last_updated_by,
	   r.last_update_date,
	   r.last_update_login
      from per_rating_levels r
     where r.rating_level_id between p_start_pkid
                                 and p_end_pkid
       and not exists (select '1'
                         from per_rating_levels_tl rtl
			where rtl.rating_level_id = r.rating_level_id
			  and rtl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |-------------------------< migrateCompetenceData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateCompetenceData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_competences_tl
  where competence_id between p_start_pkid
                        and p_end_pkid;
  */

  /*
  **
  ** Note the issue found by Jon and Phil whereby a validation/generation
  ** failure in the derivation of the string due to unresolvable references to
  ** profile options is not an error but a signaled by a null string. If this
  ** happens use the name from the base table.
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
    insert into per_competences_tl(
        competence_id,
	language,
	source_lang,
	name,
	competence_alias,
	behavioural_indicator,
	description,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select c.competence_id,
           l_current_language,
	   l_userenv_language_code,
	   nvl(fnd_flex_ext.get_segs('PER', 'CMP',
	                             cd.id_flex_num,
				     cd.competence_definition_id),
               c.name),
	   c.competence_alias,
	   c.behavioural_indicator,
	   c.description,
	   c.created_by,
	   c.creation_date,
	   c.last_updated_by,
	   c.last_update_date,
	   c.last_update_login
      from per_competences c,
           per_competence_definitions cd
     where c.competence_definition_id = cd.competence_definition_id
       and c.competence_id between p_start_pkid
                               and p_end_pkid
       and not exists (select '1'
                         from per_competences_tl ctl
			where ctl.competence_id = c.competence_id
			  and ctl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |-----------------------< migrateQualificationData >-----------------------|
-- ----------------------------------------------------------------------------
procedure migrateQualificationData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_qualifications_tl
  where qualification_id between p_start_pkid
                             and p_end_pkid;
  */

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
    insert into per_qualifications_tl(
        qualification_id,
	language,
	source_lang,
	title,
	group_ranking,
	license_restrictions,
	awarding_body,
	grade_attained,
	reimbursement_arrangements,
	training_completed_units,
	membership_category,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select q.qualification_id,
           l_current_language,
	   l_userenv_language_code,
	   q.title,
	   q.group_ranking,
	   q.license_restrictions,
	   q.awarding_body,
	   q.grade_attained,
	   q.reimbursement_arrangements,
	   q.training_completed_units,
	   q.membership_category,
	   q.created_by,
	   q.creation_date,
	   q.last_updated_by,
	   q.last_update_date,
	   q.last_update_login
      from per_qualifications q
     where q.qualification_id between p_start_pkid
                                  and p_end_pkid
       and not exists (select '1'
                         from per_qualifications_tl qtl
			where qtl.qualification_id = q.qualification_id
			  and qtl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |----------------------< migrateSubjectsTakenData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateSubjectsTakenData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_subjects_taken_tl
  where subjects_taken_id between p_start_pkid
                              and p_end_pkid;
  */

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
    insert into per_subjects_taken_tl(
        subjects_taken_id,
	language,
	source_lang,
	grade_attained,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select s.subjects_taken_id,
           l_current_language,
	   l_userenv_language_code,
           s.grade_attained,
	   s.created_by,
	   s.creation_date,
	   s.last_updated_by,
	   s.last_update_date,
	   s.last_update_login
      from per_subjects_taken s
     where s.subjects_taken_id between p_start_pkid
                                   and p_end_pkid
       and not exists (select '1'
                         from per_subjects_taken_tl stl
			where stl.subjects_taken_id = s.subjects_taken_id
			  and stl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |---------------------< migrateQualificationTypeData >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateQualificationTypeData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_installed_languages is
    select language_code,
           nls_Language
      from fnd_languages
     where installed_flag in ('I', 'B');

  l_userenv_language_code   VARCHAR2(4) := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        VARCHAR2(4);
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from per_qualification_types_tl
  where qualification_type_id between p_start_pkid
                        and p_end_pkid;
  */

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
    insert into per_qualification_types_tl(
        qualification_type_id,
	language,
	source_lang,
	name,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login)
    select q.qualification_type_id,
           l_current_language,
	   l_userenv_language_code,
	   q.name,
	   q.created_by,
	   q.creation_date,
	   q.last_updated_by,
	   q.last_update_date,
	   q.last_update_login
      from per_qualification_types q
     where q.qualification_type_id between p_start_pkid
                                       and p_end_pkid
       and not exists (select '1'
                         from per_qualification_types_tl qtl
			where qtl.qualification_type_id = q.qualification_type_id
			  and qtl.language = l_current_language);

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  hr_kflex_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    hr_kflex_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

end per_mls_migration;

/
