--------------------------------------------------------
--  DDL for Package FND_OAM_UMS_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_UMS_LOADER" AUTHID CURRENT_USER as
/* $Header: AFOAMUMSLDS.pls 120.1 2006/05/23 18:02:58 rjaiswal noship $ */

--------------------------------------------------------------------------------
-- UMS Constants
--------------------------------------------------------------------------------

-- bugfix types:

BUGFIX_TYPE_BUGFIX   constant varchar2(30) := 'BUGFIX';
BUGFIX_TYPE_PATCHSET constant varchar2(30) := 'PATCHSET';
BUGFIX_TYPE_INTERNAL constant varchar2(30) := 'INTERNAL';

-- bugfix relation types:

REL_TYPE_PREREQS              constant varchar2(30) := 'PREREQS';
REL_TYPE_INDIRECTLY_PREREQS   constant varchar2(30) := 'INDIRECTLY_PREREQS';
REL_TYPE_INCLUDES             constant varchar2(30) := 'INCLUDES';
REL_TYPE_INDIRECTLY_INCLUDES  constant varchar2(30) := 'INDIRECTLY_INCLUDES';
REL_TYPE_REPLACED_BY          constant varchar2(30) := 'REPLACED_BY';
REL_TYPE_REPLACES             constant varchar2(30) := 'REPLACES';
REL_TYPE_REP_BY_FIRST_NON_OBS constant varchar2(30) := 'REPLACED_BY_FIRST_NON_OBSOLETE';

-- download modes:

DL_MODE_NONE               constant varchar2(30) := 'NONE';
DL_MODE_FILES_ONLY         constant varchar2(30) := 'FILES_ONLY';
DL_MODE_REPLACEMENTS_ONLY  constant varchar2(30) := 'REPLACEMENTS_ONLY';
DL_MODE_REPLACEMENTS_FILES constant varchar2(30) := 'REPLACEMENTS_FILES';
DL_MODE_PREREQS_ONLY       constant varchar2(30) := 'PREREQS_ONLY';
DL_MODE_PREREQS_FILES      constant varchar2(30) := 'PREREQS_FILES';
DL_MODE_LINKS_ONLY         constant varchar2(30) := 'LINKS_ONLY';
DL_MODE_LINKS_FILES        constant varchar2(30) := 'LINKS_FILES';

--------------------------------------------------------------------------------
-- Sets the debug flag.
--
-- p_debug_flag - the debug flag (e.g., 'N', 'Y')
--------------------------------------------------------------------------------
procedure set_debugging(p_debug_flag in varchar2);

--------------------------------------------------------------------------------
-- Uploads a FND_UMS_BUGFIX.
--
-- p_upload_phase - the upload phase (e.g., 'BEGIN' or 'END')
-- p_release_name - the release name (e.g., '11i')
-- p_baseline - the baseline (e.g., 'FND.H')
-- p_bug_number - the bug number (e.g., 1794581)
-- p_download_mode - the download mode (e.g. 'PREREQS_ONLY')
-- p_application_short_name - the application short name (e.g., 'FND')
-- p_release_status - the release status (e.g., 'RELEASED')
-- p_type - the bugfix type (e.g., 'BUGFIX', 'PATCHSET')
-- p_abstract - the bug abstract (e.g., 'FLEXFIELD ROLLUP')
-- p_last_definition_date - the last definition date (e.g., '2001/04/08 14:10:33')
-- p_last_update_date - the last update date (e.g., '2001/04/08 14:10:33')
-- p_custom_mode - custom mode flag (e.g., 'FORCE')
--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfix
  (p_upload_phase           in varchar2,
   p_release_name           in varchar2,
   p_baseline               in varchar2,
   p_bug_number             in varchar2,
   p_download_mode          in varchar2,
   p_application_short_name in varchar2,
   p_release_status         in varchar2,
   p_type                   in varchar2,
   p_abstract               in varchar2,
   p_last_definition_date   in varchar2,
   p_last_update_date       in varchar2,
   p_custom_mode            in varchar2);

--------------------------------------------------------------------------------
-- Uploads a FND_UMS_BUGFIX_FILE.
--
-- p_application_short_name - the application short name (e.g., 'FND')
-- p_location - the file location (e.g., 'java/flexj')
-- p_name - the file name (e.g., 'DescriptiveFlexfield.class')
-- p_version - the file version (e.g., '115.17')
--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfix_file
  (p_application_short_name in varchar2,
   p_location               in varchar2,
   p_name                   in varchar2,
   p_version                in varchar2);

--------------------------------------------------------------------------------
-- Uploads a FND_UMS_BUGFIX_RELATIONSHIP.
--
-- p_relation_type - the relation type (e.g., 'PREREQS')
-- p_related_bugfix_release_name - the related bugfix release name (e.g., '11i')
-- p_related_bugfix_bug_number - the related bugfix bug number (e.g., 1961677)
-- p_related_bugfix_download_mode - the related bugfix download mode (e.g. 'PREREQS_ONLY')
--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfix_relationship
  (p_relation_type                in varchar2,
   p_related_bugfix_release_name  in varchar2,
   p_related_bugfix_bug_number    in varchar2,
   p_related_bugfix_download_mode in varchar2);

--------------------------------------------------------------------------------
-- Uploads a FND_UMS_ONE_BUGFIX.
--
-- p_upload_phase - the upload phase (e.g., 'BEGIN' or 'END')
-- p_release_name - the release name (e.g., '11i')
-- p_baseline - the baseline (e.g., 'FND.H')
-- p_bug_number - the bug number (e.g., 1794581)
--------------------------------------------------------------------------------
procedure up_fnd_ums_one_bugfix
  (p_upload_phase in varchar2,
   p_release_name in varchar2,
   p_baseline in varchar2,
   p_bug_number   in varchar2);

--------------------------------------------------------------------------------
-- Uploads a FND_UMS_BUGFIXES.
--
-- p_upload_phase - the upload phase (e.g., 'BEGIN' or 'END')
-- p_entity_download_mode - the entity download mode
--                          (e.g., 'ONE', 'UPDATED', 'ALL')
-- p_release_name - the release name (e.g., '11i')
-- p_bug_number - the bug number (e.g., 1794581)
--                (Only applies in entity download mode 'ONE')
-- p_start_date - the start date
--                (Only applies in entity download modes 'UPDATED' and 'ALL')
-- p_end_date - the end_date
--              (Only applies in entity download modes 'UPDATED' and 'ALL')
--------------------------------------------------------------------------------
procedure up_fnd_ums_bugfixes
  (p_upload_phase         in varchar2,
   p_entity_download_mode in varchar2,
   p_release_name         in varchar2,
   p_bug_number           in varchar2,
   p_start_date           in varchar2,
   p_end_date             in varchar2);

--------------------------------------------------------------------------------
-- Returns newline character independent of the platform
-- Copy of the fnd_global.newline() function. However, UMS should not depend
-- on any other package.
--------------------------------------------------------------------------------
function newline return varchar2;

end fnd_oam_ums_loader;

 

/
