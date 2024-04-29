--------------------------------------------------------
--  DDL for Package Body OTA_MLS_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_MLS_MIGRATION" AS
/* $Header: otmlsmig.pkb 115.1 2003/05/19 07:56:30 jbharath noship $ */

-- ----------------------------------------------------------------------------
-- |---------------------< migrateActivityDefinitionData >--------------------|
-- ----------------------------------------------------------------------------
procedure migrateActivityDefinitionData(
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

  l_userenv_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        FND_LANGUAGES.LANGUAGE_CODE%TYPE ;
  l_rows_processed number := 0;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from ota_activity_definitions_tl
  where activity_id between p_start_pkid
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
    ota_mls_utility.set_session_nls_language(c_language.nls_language);
    l_current_language := c_language.language_code;

    /*
    ** Insert the TL rows.
    */

   Insert into OTA_ACTIVITY_DEFINITIONS_TL
    (Activity_Id,
     Language,
     Name,
     Description,
     Source_Lang,
     Created_By,
     Creation_Date,
     Last_Updated_By,
     Last_Update_Date,
     Last_Update_Login )
  Select
    M.Activity_Id,
    L_Current_Language,
    M.Name,
    M.Description,
    L_Userenv_language_code,
    M.Created_By,
    M.Creation_date,
    M.Last_Updated_By,
    M.Last_Update_Date,
    M.Last_Update_Login
  From OTA_ACTIVITY_DEFINITIONS M
  Where M.Activity_id Between P_start_pkid and P_end_pkid
  And   Not Exists (Select    '1'
                    From     OTA_ACTIVITY_DEFINITIONS_TL T
                    Where   T.Activity_Id = M.Activity_Id
                    And        T.Language = L_Current_Language ) ;


    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  ota_mls_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;
end;

-- ---------------------------------------------------------------------------------
-- |------------------------< migrateActivityVersionData >-------------------------|
-- ---------------------------------------------------------------------------------
procedure migrateActivityVersionData(
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

  l_userenv_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        FND_LANGUAGES.LANGUAGE_CODE%TYPE;
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from ota_activity_versions_tl
  where activity_version_id between p_start_pkid
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
    ota_mls_utility.set_session_nls_language(c_language.nls_language);
    l_current_language := c_language.language_code;

    /*
    ** Insert the TL rows.
    */
   Insert into OTA_ACTIVITY_VERSIONS_TL
    (Activity_Version_Id,
     Language,
     Version_Name,
     Description,
     Intended_Audience,
     Objectives,
     Source_Lang,
     Created_By,
     Creation_Date,
     Last_Updated_By,
     Last_Update_Date,
     Last_Update_Login )
  Select
    M.Activity_Version_Id,
    L_Current_Language,
    M.Version_Name,
    M.Description,
    M.Intended_Audience,
    M.Objectives,
    L_Userenv_language_code,
    M.Created_By,
    M.Creation_date,
    M.Last_Updated_By,
    M.Last_Update_Date,
    M.Last_Update_Login
  From OTA_ACTIVITY_VERSIONS M
  Where M.Activity_version_id Between P_start_pkid and P_end_pkid
  And   Not Exists (Select   '1'
                    From     OTA_ACTIVITY_VERSIONS_TL T
                    Where    T.Activity_version_Id = M.Activity_version_Id
                    And      T.Language = L_Current_Language ) ;

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  ota_mls_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateEventData >---------------------------|
-- ----------------------------------------------------------------------------
procedure migrateEventData(
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

  l_userenv_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        FND_LANGUAGES.LANGUAGE_CODE%TYPE;
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from ota_events_tl
  where event_id between p_start_pkid
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
    ota_mls_utility.set_session_nls_language(c_language.nls_language);
    l_current_language := c_language.language_code;

    /*
    ** Insert the TL rows.
    */
    Insert into OTA_EVENTS_TL
    (Event_Id,
     Language,
     Title,
     Source_Lang,
     Created_By,
     Creation_Date,
     Last_Updated_By,
     Last_Update_Date,
     Last_Update_Login )
    Select
     M.Event_Id,
     L_Current_Language,
     M.Title,
     L_Userenv_language_code,
     M.Created_By,
     M.Creation_date,
     M.Last_Updated_By,
     M.Last_Update_Date,
     M.Last_Update_Login
    From OTA_EVENTS M
    Where M.Event_id Between P_start_pkid and P_end_pkid
    And   Not Exists (Select  '1'
                      From    OTA_EVENTS_TL T
                      Where   T.Event_Id = M.Event_Id
                      And     T.Language = L_Current_Language ) ;



    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  ota_mls_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |------------------< migrateBookingStatusTypeData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateBookingStatusTypeData(
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

  l_userenv_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        FND_LANGUAGES.LANGUAGE_CODE%TYPE;
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from ota_booking_status_types_tl
  where booking_status_type_id between p_start_pkid
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
    ota_mls_utility.set_session_nls_language(c_language.nls_language);
    l_current_language := c_language.language_code;

    /*
    ** Insert the TL rows.
    */
    Insert into OTA_BOOKING_STATUS_TYPES_TL
    (Booking_Status_type_Id,
     Language,
     Name,
     Description,
     Source_Lang,
     Created_By,
     Creation_Date,
     Last_Updated_By,
     Last_Update_Date,
     Last_Update_Login )
    Select
     M.Booking_Status_type_Id,
     L_Current_Language,
     M.Name,
     M.Description,
     L_Userenv_language_code,
     M.Created_By,
     M.Creation_date,
     M.Last_Updated_By,
     M.Last_Update_Date,
     M.Last_Update_Login
    From OTA_BOOKING_STATUS_TYPES M
    Where M.Booking_status_type_id Between P_start_pkid and P_end_pkid
    And   Not Exists (Select  '1'
                      From    OTA_BOOKING_STATUS_TYPES_TL T
                      Where   T.Booking_status_type_Id = M.Booking_Status_type_Id
                      And     T.Language = L_Current_Language ) ;


    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  ota_mls_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;

-- ----------------------------------------------------------------------------
-- |---------------------------< migrateResourceData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateResourceData(
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

  l_userenv_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE := userenv('LANG');
  l_current_nls_language    VARCHAR2(30);
  l_current_language        FND_LANGUAGES.LANGUAGE_CODE%TYPE;
  l_rows_processed number := 0;
  l_end_of_time date := hr_general.end_of_time;

begin

  /*
  ** Clear out any existing data for this range of records
  **
  ** Don't delete just yet.
  **
  delete from ota_suppliable_resources_tl
  where supplied_resource_id between p_start_pkid
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
    ota_mls_utility.set_session_nls_language(c_language.nls_language);
    l_current_language := c_language.language_code;

    /*
    ** Insert the TL rows.
    */
    Insert into OTA_SUPPLIABLE_RESOURCES_TL
    (Supplied_Resource_Id,
     Language,
     Name,
     Special_Instruction,
     Source_Lang,
     Created_By,
     Creation_Date,
     Last_Updated_By,
     Last_Update_Date,
     Last_Update_Login )
    Select
     M.Supplied_Resource_Id,
     L_Current_Language,
     nvl(fnd_flex_ext.get_segs('OTA', 'RES',
                               rd.id_flex_num,
   			       rd.resource_definition_id), M.Name),
     M.Special_Instruction,
     L_Userenv_language_code,
     M.Created_By,
     M.Creation_date,
     M.Last_Updated_By,
     M.Last_Update_Date,
     M.Last_Update_Login
    From OTA_SUPPLIABLE_RESOURCES M, OTA_RESOURCE_DEFINITIONS RD
    Where M.Resource_definition_id = Rd.Resource_definition_id
    And   M.Supplied_resource_id Between P_start_pkid and P_end_pkid
    And   Not Exists (Select  '1'
                      From    OTA_SUPPLIABLE_RESOURCES_TL T
                      Where   T.Supplied_resource_id = M.Supplied_resource_id
                      And     T.Language = L_Current_Language ) ;

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

  ota_mls_utility.set_session_language_code( l_userenv_language_code );

Exception
  --
  When Others Then
    --
    ota_mls_utility.set_session_language_code( l_userenv_language_code );
    --
    raise;

end;
--
end ota_mls_migration;

/
