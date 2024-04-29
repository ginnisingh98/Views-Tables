--------------------------------------------------------
--  DDL for Package Body HR_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HISTORY" as
/* $Header: dthistry.pkb 115.6 2004/01/28 01:51:32 sxshah ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
     dthistry.pkb     -- Procedures for DateTrack History
--
   DESCRIPTION
     Procedures used by Forms4 DateTrack History (DTH)
--
  MODIFIED (DD-MON-YYYY)
     P.K.Attwood  03-JUN-1994 - created.
     P.K.Attwood  19-JUL-1994 - Added extra check for _D view. If the _D view
                                cannot be found in user_views go onto check
                                for a synonym, as the user could be logged on
                                as a secure user.
     P.K.Attwood  23-JAN-1996 - Fix for wwbug 295511. Added extra parameter
                                p_view_owner to the get_view_and_prompts
                                procedure. It returns the name of the Oracle
                                account which actually owns the _D view or
                                _F table. This is required for extra secure
                                user logic.
     P.K.Attwood  08-MAY-1998 - 115.1 Changes for wwbug 658889.
                                New DateTrack History feature.
                                The Forms coder can optionally specify an
                                alternative DateTrack History view. If this
                                view name is not specified or cannot be
                                found in the database then the standard _D
                                view or _F table will be used as before.
                                To provide the required behaviour re-wrote
                                get_view_and_prompts procedure and simplified
                                the logic due to security changes in R11.0.
                                Old code specific for database version 10.5
                                and 10.6 has been removed.
     P.K.Attwood  16-MAR-1999 - 115.2 Changes made to provide MLS for
                                DateTrack History prompts.
                                Changed table name references from
                                DT_TITLE_PROMPTS and DT_DATE_PROMPTS to
                                DT_TITLE_PROMPTS_TL and DT_DATE_PROMPTS_TL.
                                Changed the get_view_and_prompts
                                p_language_code parameter from IN to OUT.
                                Value is now derived from userenv('LANG').
                                Added find_language_code procedure.
     M.Enderby    28-NOV-2002 - Changes to derive_view_table_names,
                                GSCC changes (bug 2620598)
     A.Holt      05-Dec-2002 NOCOPY Performance Changes for 11.5.9
     S.Shah	 28-Jan-2004 Bug fix for 3312530 to change l_col var. */
--
-- Global Package Definitions
--
g_package  varchar2(33) := '  hr_history.';  -- Global package name
--
-- Private Procedures to this package
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_language_code >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    Obtains the user's language from userenv('LANG').
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   p_language_code will be set to the value from userenv('LANG').
--
--   Name                           Type     Description
--   p_language_code                varchar2 User's language.
--
-- Post Failure:
--   Processing stops and an error is raised if an unexpected error occurs.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure find_language_code
  (p_language_code        out nocopy varchar2
  ) is
  --
  -- Cursor to find language
  --
  cursor csr_lang is
    select userenv('LANG')
      from dual;
  --
  -- Declare local variables
  --
  l_language_code varchar2(80);
  l_proc          varchar2(72) := g_package||'find_language_code';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Find out if the view definition exists in the current account
  --
  open csr_lang;
  fetch csr_lang into l_language_code;
  if csr_lang%notfound then
    close csr_lang;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  end if;
  close csr_lang;
  --
  p_language_code := l_language_code;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
end find_language_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< find_view_and_details >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks if the specified view exists in the current database account.
--   If it exists also derived the name of the database account and the
--   title prompt from DT_TITLE_PROMPTS_TL.
--
-- Prerequisites:
--   p_view_name must be in upper case.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_view_name                    Yes  varchar2 Name of the view to find.
--   p_language_code                Yes  varchar2 The user entity title name
--                                                will be returned for the
--                                                specified language.
--
-- Post Success:
--   p_view_found will be set to false if the view definition does not exist
--   in user_views. All other OUT parameters will be null.
--
--   Name                           Type     Description
--   p_view_found                   boolean  Indicates if the view definition
--                                           was found in user_views.
--   p_view_owner                   varchar2 Name of the database account
--                                           which owns the view.
--   p_title_prompt                 varchar2 User entity name to include in
--                                           the window title prompt. Derived
--                                           from the DT_TITLE_PROMPTS_TL.
--
-- Post Failure:
--   Processing stops and an error is raised if an unexpected error occurs.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure find_view_and_details
  (p_view_name         in     varchar2
  ,p_language_code     in     varchar2
  ,p_view_found           out nocopy boolean
  ,p_view_owner           out nocopy varchar2
  ,p_title_prompt         out nocopy varchar2
  ) is
  --
  -- Cursor to find view definition
  --
  cursor csr_view_exists is
    select user
      from user_views
     where view_name = p_view_name;
  --
  -- Cursor to obtain the entity title name.
  --
  cursor csr_title is
    select title_prompt
      from dt_title_prompts_tl
     where view_name = p_view_name
       and  language = p_language_code;
  --
  -- Declare local variables
  --
  l_view_found   boolean;
  l_view_owner   varchar2(80);
  l_title_prompt varchar2(80);
  l_proc         varchar2(72) := g_package||'find_view_and_details';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Find out if the view definition exists in the current account
  --
  open csr_view_exists;
  fetch csr_view_exists into l_view_owner;
  if csr_view_exists%found then
    close csr_view_exists;
    l_view_found := true;
    --
    -- Obtain the entity title name.
    --
    open csr_title;
    fetch csr_title into l_title_prompt;
    if csr_title%notfound then
      close csr_title;
      hr_utility.set_message(801,'DTH_34950_MISSING_TITLE');
      hr_utility.set_message_token('VIEW', p_view_name);
      hr_utility.raise_error;
    end if;
    close csr_title;
    hr_utility.set_location(l_proc, 20);
  else
    close csr_view_exists;
    l_view_found   := false;
    l_view_owner   := null;
    l_title_prompt := null;
    --
    -- Note: From R11.0 onwards it is no longer necessary to double check
    --       for a synonym. Secure users now connect to the APPS account
    --       where the view definitions are held.
    --
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  p_view_found   := l_view_found;
  p_view_owner   := l_view_owner;
  p_title_prompt := l_title_prompt;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end find_view_and_details;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< derive_view_table_names >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Takes the provided table name and returns the name of the standard _D
--   DateTrack history view. Just in case the Form FND_SESSION view name
--   has been provided by mistake, the table name is also formatted. Appending
--   an _F suffix if it does not exist. All values are returned in uppercase.
--   For example, if p_table_name is set to 'per_all_people' then
--   p_st_view_name  will be set to PER_ALL_PEOPLE_D
--   p_st_table_name will be set to PER_ALL_PEOPLE_F
--
-- Prerequisites:
--   p_table_name is not null.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_table_name                   Yes  varchar2 Name of the table.
--
-- Post Success:
--   Returns name of the standard _D DateTrack history view and the name of
--   the _F table and the name of table without the '_F' suffix. All in upper
--   case.
--
-- Post Failure:
--   Processing stops and an ORA error is raise.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure derive_view_table_names
  (p_table_name             in     varchar2
  ,p_st_view_name              out nocopy varchar2
  ,p_st_table_name             out nocopy varchar2
  ,p_st_table_name_trim        out nocopy varchar2
  ) is
  --
  -- Declare local variables
  --
  l_table_trim       user_views.view_name%type; -- Table name, without white
                                                -- space, without _F and in
                                                -- uppercase.
  l_name_length      number;                    -- Length of the table
                                                -- name provided without white
                                                -- space.
  l_pos_last_unders  number;                    -- Position of the last '_'
                                                -- in the provided table name.
  l_proc             varchar2(72) := g_package||'derive_view_table_names';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_table_trim      := upper(rtrim(p_table_name));
  l_name_length     := length(l_table_trim);
  l_pos_last_unders := instrb(l_table_trim, '_F', -1);
  --
  -- Remove _F, if it exists, from the end of the base table name.
  --
  if (l_pos_last_unders = (l_name_length - 1)) then
    l_table_trim := substrb(l_table_trim,
                            1,
                            l_name_length - 2);
  end if;
  --
  p_st_view_name       := l_table_trim || '_D';
  p_st_table_name      := l_table_trim || '_F';
  p_st_table_name_trim := l_table_trim;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end derive_view_table_names;
--
-- ----------------------------------------------------------------------------
-- |------------------------< find_table_and_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the current database account has access to the specified table.
--
-- Prerequisites:
--   p_table_name must be in upper case and contain the '_F' suffix.
--   i.e. The "derive_view_table_names" procedure has already been executed.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_table_name                   Yes  varchar2 Table name to validate.
--   p_table_name_trim              Yes  varchar2 Name of the table without
--                                                the '_F' suffix.
--
-- Post Success:
--   If the table synonym exists processing continues and the following
--   OUT parameters will be populated.
--
--   Name                           Type     Description
--   p_table_owner                  varchar2 Name of the database account
--                                           which owns the table.
--   p_title_prompt                 varchar2 User entity name to include in
--                                           the window title prompt. Derived
--                                           from the table name.
--
-- Post Failure:
--   Processing stops and an application error is raised if the table
--   synonym cannot be found.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure find_table_and_details
  (p_table_name         in     varchar2
  ,p_table_name_trim    in     varchar2
  ,p_table_owner           out nocopy varchar2
  ,p_title_prompt          out nocopy varchar2
  ) is
  --
  -- Cursor to find table synonym definition.
  --
  cursor csr_tab_synonym_exists is
    select table_owner
      from user_synonyms syn
     where syn.table_name = p_table_name;
  --
  -- Declare local variables
  --
  l_table_owner   varchar2(30);
  l_title_prompt  varchar2(80);
  l_proc          varchar2(72) := g_package||'find_table_and_details';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Find out if the table synonym definition exists in the current account
  -- Note: From R11.0 onwards, there is no need to check the actual table
  --       definition is held in the current account. Table definitions will
  --       exist in HR where as users connect to the APPS account.
  --
  open csr_tab_synonym_exists;
  fetch csr_tab_synonym_exists into l_table_owner;
  if csr_tab_synonym_exists%notfound then
    close csr_tab_synonym_exists;
    hr_utility.set_message(801, 'DTH_34952_ACCESS_TABLE');
    hr_utility.set_message_token('TABLE', p_table_name);
    hr_utility.raise_error;
  end if;
  close csr_tab_synonym_exists;
  --
  -- Derive the entity title name from the table name.
  -- Remove the product code prefix, replace underscores
  -- with spaces and initcap the result.
  --
  l_title_prompt := substr(p_table_name_trim,
                      (instrb(p_table_name_trim, '_') + 1));
  l_title_prompt := initcap(replace(l_title_prompt, '_', ' '));
  -- Set out parameters
  p_table_owner  := l_table_owner;
  p_title_prompt := l_title_prompt;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end find_table_and_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_date_prompts >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Obtains the effective_start_date and effective_end_date column display
--   prompts, from DT_DATE_PROMPTS_TL, for a particular language.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                Yes  varchar2 Prompts will be returned
--                                                for the specified language.
--
-- Post Success:
--   Details about the prompts are derived and the following OUT parameters
--   will be populated.
--
--   Name                           Type     Description
--   p_effective_start_prompt       varchar2 Effective start date end user
--                                           display prompt, for the specified
--                                           language.
--   p_effective_end_prompt         varchar2 Effective end date end user
--                                           display prompt, for the specified
--                                           language.
--
-- Post Failure:
--   Processing stops and an application error is raised if an unexpected
--   error occurs.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_date_prompts
  (p_language_code          in     varchar2
  ,p_effective_start_prompt    out nocopy varchar2
  ,p_effective_end_prompt      out nocopy varchar2
  ) is
  --
  -- Cursor to obtain the date display prompts.
  --
  cursor csr_prompts is
    select effective_start_prompt
         , effective_end_prompt
      from dt_date_prompts_tl
     where language = p_language_code;
  --
  l_proc  varchar2(72) := g_package||'get_date_prompts';
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Obtain date display prompts.
  --
  open csr_prompts;
  fetch csr_prompts into p_effective_start_prompt
                       , p_effective_end_prompt;
  if csr_prompts%notfound then
    close csr_prompts;
    hr_utility.set_message(801, 'DTH_34951_DATE_PROMPT');
    hr_utility.set_message_token('LANGUAGE', p_language_code);
    hr_utility.raise_error;
  end if;
  close csr_prompts;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end get_date_prompts;
--
-- Procedures declared in the package header
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_view_and_prompts >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_view_and_prompts
  (p_table_name                in     varchar2
  ,p_alternative_history_view  in     varchar2
  ,p_language_code                out nocopy varchar2
  ,p_view_name                    out nocopy varchar2
  ,p_view_owner                   out nocopy varchar2
  ,p_title_prompt                 out nocopy varchar2
  ,p_effective_start_prompt       out nocopy varchar2
  ,p_effective_end_prompt         out nocopy varchar2
  ) is
  --
  -- Declare local variables
  --
  l_view_name      user_views.view_name%type; -- Name of the view, or table,
                                              -- to return OUT of this
                                              -- procedure.
  l_al_view_name   user_views.view_name%type; -- Alternative DT history view
                                              -- in upper case.
  l_st_view_name   user_views.view_name%type; -- Standard DT history _D view
                                              -- in upper case.
  l_al_view_found  boolean default false;     -- Indicates if the alternative
                                              -- DT history view exists.
  l_st_view_found  boolean default false;     -- Indicates if the standard
                                              -- DT history _D view exists.
  l_st_table_name           varchar2(30);     -- Formatted table name, with
                                              -- _F suffix, in upper case.
  l_st_table_name_trim      varchar2(30);     -- Name of the table, without
                                              -- the _F suffix, in upper case.
  l_effective_start_prompt  varchar2(80);     -- Effective start date display
                                              -- column prompt.
  l_effective_end_prompt    varchar2(80);     -- Effective end date display
                                              -- column prompt.
  l_view_owner              varchar2(30);     -- Name of the database account
                                              -- which owns the view or table
                                              -- definition.
  l_title_prompt            varchar2(80);     -- The user entity name to be
                                              -- included in the Form window
                                              -- title.
  l_language_code           varchar2(80);     -- Value from userenv('LANG')
  l_proc  varchar2(72) := g_package||'get_view_and_prompts';
  --
  -- Algorithm :-
  --
  -- Get language from userenv('LANG')
  --
  -- IF alternative_history_view has been specified THEN
  --   Check to see if alternative_history_view exists in user_views
  --   Get the view owner account name from "user" and the title name
  --   from DT_TITLE_PROMPTS_TL.
  -- END IF
  --
  -- IF (alternative_history_view has NOT been specified) OR
  --    (alternative_history_view was specified but was not found) THEN
  --   Check to see if standard <table_name_no_suffix>_D view exists
  --   in user_views
  --   Get the view owner account name from "user" and the title name
  --   from DT_TITLE_PROMPTS_TL.
  --
  --   N.B. From R11.0 onwards it is no longer necessary to double check
  --        for a synonym. Secure users now connect to the APPS account
  --        where the view definitions are held.
  -- END IF
  --
  -- IF (alternative_history_view does not exist) AND
  --    (<table_name_no_suffix>_D view does not exist) THEN
  --
  --   Check that _F table actually exists
  --   Tables are defined in the HR account, not in the APPS account the
  --   user is connected to. So the table name will not exist in user_tables.
  --   Just check a synonym exists in the current account for the table name.
  --   Get the table owner account name from user_synonyms.
  --
  --   N.B. From R11.0 onwards addition logic is not required for secure users
  --        as they are also connected to the APPS account.
  --
  --   When the synonym does exist then:
  --     Derive p_title_prompt value from the table name. The PER_/PAY_/FF_
  --     prefix is removed, the _D or _F suffix is removed, underscore
  --     characters are replaced with spaces and initcap the remaining text.
  --
  -- END IF
  --
  -- Get p_effective_start_prompt value from DT_DATE_PROMPTS_TL
  -- Get p_effective_end_prompt value   from DT_DATE_PROMPTS_TL
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --  Get language from userenv('LANG')
  --
  find_language_code
    (p_language_code => l_language_code
    );
  --
  -- If an alternative history view has been specified then check it can
  -- be found. Also obtain the title and owner database account name.
  --
  if p_alternative_history_view is not null then
    l_al_view_name := upper(p_alternative_history_view);
    find_view_and_details
      (p_view_name     => l_al_view_name
      ,p_language_code => l_language_code
      ,p_view_found    => l_al_view_found
      ,p_view_owner    => l_view_owner
      ,p_title_prompt  => l_title_prompt
      );
  end if;
  --
  -- If the alternative history view has not been specified OR
  -- it was specified but was not found then check to see if the
  -- standard DateTrack History _D view can be found.
  --
  if not l_al_view_found then
    -- First, work out the full table name, name
    -- of the standard _D view and format table.
    derive_view_table_names
      (p_table_name           => p_table_name
      ,p_st_view_name         => l_st_view_name
      ,p_st_table_name        => l_st_table_name
      ,p_st_table_name_trim   => l_st_table_name_trim
      );
    find_view_and_details
      (p_view_name     => l_st_view_name
      ,p_language_code => l_language_code
      ,p_view_found    => l_st_view_found
      ,p_view_owner    => l_view_owner
      ,p_title_prompt  => l_title_prompt
      );
  end if;
  --
  if (not l_st_view_found) AND (not l_al_view_found) then
    --
    -- Neither view exists check the actual _F table exists.
    -- If the table cannot be found then raise an error.
    -- When the table does exist obtain details of the
    -- database account and the entity title name.
    --
    find_table_and_details
      (p_table_name      => l_st_table_name
      ,p_table_name_trim => l_st_table_name_trim
      ,p_table_owner     => l_view_owner
      ,p_title_prompt    => l_title_prompt
      );
    l_view_name := l_st_table_name;
    --
  elsif l_al_view_found then
    --
    -- The alternative view was found.
    --
    l_view_name := l_al_view_name;
    --
  elsif l_st_view_found then
    --
    -- The standard view was found.
    --
    l_view_name := l_st_view_name;
    --
  else
    --
    -- This code point should never be reached. If neither
    -- view can be found, and the table does not exist then
    -- the "check_table_exists" procedure should have already
    -- raised an error.
    --
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  end if;
  --
  -- Obtained effective date prompts for the specified language
  --
  get_date_prompts
    (p_language_code          => l_language_code
    ,p_effective_start_prompt => l_effective_start_prompt
    ,p_effective_end_prompt   => l_effective_end_prompt
    );
  --
  -- Populate OUT parameters
  --
  p_language_code          := l_language_code;
  p_view_name              := l_view_name;
  p_view_owner             := l_view_owner;
  p_title_prompt           := l_title_prompt;
  p_effective_start_prompt := l_effective_start_prompt;
  p_effective_end_prompt   := l_effective_end_prompt;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
end get_view_and_prompts;
--
-- Left an old overload version of the get_view_and_prompts
-- procedure, without the new p_alternative_history_view parameter
-- or changed p_language_code parameter.
-- This old version can be removed after R11.5, as the DTXHISTY
-- Form will have been changed to always call the new version.
--
procedure get_view_and_prompts
( p_table_name             in  varchar2,
  p_language_code          in  varchar2,
  p_view_name              out nocopy varchar2,
  p_view_owner             out nocopy varchar2,
  p_title_prompt           out nocopy varchar2,
  p_effective_start_prompt out nocopy varchar2,
  p_effective_end_prompt   out nocopy varchar2
) is
--
  l_language_code     varchar2(80);
--
begin
  --
  -- Call new overload version setting the new
  -- p_alternative_history_view parameter to null.
  --
  get_view_and_prompts
    (p_table_name               => p_table_name
    ,p_alternative_history_view => null
    ,p_language_code            => l_language_code
    ,p_view_name                => p_view_name
    ,p_view_owner               => p_view_owner
    ,p_title_prompt             => p_title_prompt
    ,p_effective_start_prompt   => p_effective_start_prompt
    ,p_effective_end_prompt     => p_effective_end_prompt
    );
end get_view_and_prompts;
--
-- Function to return column prompt for a given table.
--
FUNCTION fetch_dt_column_prompt(p_table_name    IN VARCHAR2
                               ,p_column_name   IN VARCHAR2
                               ,p_language_code IN VARCHAR2) RETURN VARCHAR2 IS
--
  l_col dt_column_prompts_tl.column_prompt%TYPE;
--
BEGIN
  --
  SELECT dcp.column_prompt
    INTO l_col
    FROM dt_column_prompts_tl dcp
   WHERE dcp.view_name   = p_table_name
     AND dcp.column_name = p_column_name
     AND dcp.language    = p_language_code;
  --
  RETURN(l_col);
EXCEPTION
  WHEN OTHERS THEN
    RETURN(INITCAP(REPLACE(p_column_name, '_', ' ')));
END fetch_dt_column_prompt;
--
end hr_history;

/
