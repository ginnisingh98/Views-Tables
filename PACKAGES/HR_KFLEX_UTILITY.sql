--------------------------------------------------------
--  DDL for Package HR_KFLEX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KFLEX_UTILITY" AUTHID CURRENT_USER as
/* $Header: hrkfutil.pkh 120.0.12010000.2 2008/08/06 08:42:51 ubhat ship $ */
--
-- Package Variables
--
-- -------------------------------------------------------------------------
-- | create varray for ignore key flex field validation
-- -------------------------------------------------------------------------
--
type l_ignore_kfcode_varray is varray(12) of varchar2(30);
procedure create_ignore_kf_validation(p_rec in l_ignore_kfcode_varray);
--
----------------------------------------------------------------------------
-- | check ignore array with key flex currently being processed
----------------------------------------------------------------------------
--
function check_ignore_varray(p_structure in varchar2) return boolean;
--
----------------------------------------------------------------------------
-- | clear varray
----------------------------------------------------------------------------
--
procedure remove_ignore_kf_validation;
--
-- ----------------------------------------------------------------------------
-- |------------------------ ins_or_sel_keyflex_comb -------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This public procedure can be called by any api/business process which
--   involves the insert of key flexfield details for a given entity.
--
--   This procedure will accept populated key flex segment values in two forms :
--
--   Parameter form    : Each segment is passed in individually as p_segment1-30
--   Concatenated form : All segment are passed in together as one concatenated
--                       string of values. The segments in the string are
--                       arranged in segment display order
--
-- Prerequisites:
--   A valid id_flex_code    (flex structure code)
--   A valid id_flex_num     (flex structure number)
--   A valid appl_short_name (application short name)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_segment1 - 30       No   varchar2 Flex segments for relevant key
--                                       flexfield
--   p_concat_segments_in  No   varchar2 Flex segments in a concatenated string
--                                       presorted in segment display order
--   p_flex_num            Yes  number   The structure number for the relevant
--                                       key flexfield.
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--
--
-- Post Success:
--   The procedure calls check_segment_combination which returns the
--   relevant CCID for the key flexfield.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure ins_or_sel_keyflex_comb
-- Flex structure definition details
  (p_appl_short_name               in     fnd_application.application_short_name%TYPE
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_flex_num                      in     number
-- Individual parameter interface
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
-- Concatenated string interface
  ,p_concat_segments_in            in     varchar2 default null
-- Code combination id and Concatenated segment string passed out
  ,p_ccid                          out nocopy    number
  ,p_concat_segments_out           out nocopy    varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------- upd_or_sel_keyflex_comb ------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This public procedure can be called by any api/business process which
--   involves the update key flexfield details for a given entity.
--
--   It takes the CCID of the key flexfield definition and then
--   calls an AOL routine to convert the segment combination into a PLSQL
--   table. The contents of the table are then compared against the IN parameters
--   (i.e. the segment values) of the calling business process and a new table
--   is created which may contain updated segment values. Finally, a call is
--   made to check_segment_combination which will create a new segment
--   combination if required.
--
-- Prerequisites:
--   A valid key flexfield combination
--   A valid id_flex_code    (flex structure code)
--   A valid id_flex_num     (flex structure number)
--   A valid appl_short_name (application short name)
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_ccid                Yes* number   The CCID of the key flexfield code
--                                       combination
--                                       *only req'd for parameter interface
--   p_segment1 - 30       No   varchar2 Flex segments for key flexfield
--   p_concat_segments_in  No   varchar2 Flex segments in a concatenated string
--                                       presorted in segment display order
--   p_flex_code           Yes  varchar2 The id_flex_code of the relevant key
--                                       flexfield structure
--   p_flex_num            Yes  number   The structure number for the key
--                                       flexfield structure
--
-- Post Success:
--   The procedure calls check_segment_combination which returns the
--   relevant CCID for the key flexfield (i.e. if segment values were
--   updated).
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure upd_or_sel_keyflex_comb
-- Flex structure definition details
  (p_appl_short_name               in     fnd_application.application_short_name%TYPE
  ,p_flex_code                     in     fnd_id_flex_segments.id_flex_code%TYPE
  ,p_flex_num                      in     number
-- Individual parameter interface
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
-- Concatenated string interface
  ,p_concat_segments_in            in     varchar2 default null
-- Code combination passed in and returned
  ,p_ccid                          in out nocopy number
-- Concatenated segment string passed out
  ,p_concat_segments_out           out nocopy    varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------ set_profiles ------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure sets the PER_ASSIGNMENT_ID, PER_BUSINESS_GROUP_ID,
--   PER_ORGANIZATION_ID and PER_LOCATION_ID profiles.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_business_group_id   No   number   The business group id
--   p_assignment_id       No   number   The assignment id
--   p_organization_id     No   number   The organization id
--   p_location_id         No   number   The location id
--   p_person_id          No   number    The person id
--
-- Post Success:
--   The procedure writes the three profile options
--
-- Post Failure:
--
--
-- Access Status:
--   Private - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_profiles
(p_business_group_id in     per_all_assignments_f.business_group_id%type default hr_api.g_number
,p_assignment_id     in     per_all_assignments_f.assignment_id%type     default null
,p_organization_id   in     per_all_assignments_f.organization_id%type   default null
,p_location_id       in     per_all_assignments_f.location_id%type       default null
,p_person_id         in        per_all_assignments_f.person_id%type       default null
);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------- set_session_date ---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure sets the session date in fnd_sessions if it is not already
--   set for this session, and sets the session id parameter. If fnd_sessions
--   has already been set then no data is written and p_session_id is set to
--   be -1.
--
--   Note, at the end of the api, you must call unset_session_date to clear the
--   table if applicable.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_effective_date      Yes  Date     The effective date
--
-- Post Success:
--   The procedure populates fnd_sessions as appropriate
--
-- Post Failure:
--
--
-- Access Status:
--   Private - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_date
(p_effective_date        in     date
,p_session_id               out nocopy number
);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------- unset_session_date --------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   If a sessionid is passed in the coresponding row is deleted from
--   fnd_sessions. If p_session_id =-1 then no deletion is atempted.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_session_id          Yes  number   The session id
--
-- Post Success:
--   The procedure deleted from fnd_sessions as appropriate
--
-- Post Failure:
--
--
-- Access Status:
--   Private - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure unset_session_date
(p_session_id            in      number
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------- set_session_language_code--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Set the session language from the language code and clears the
--   key flex cache
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_language_code       Yes  varchar2 the Two digit language code
--
-- Post Success:
-- userenv('LANG') is set to language code
--
-- Post Failure:
-- user session language is not changed
--
--
-- Access Status:
--   Public  - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_language_code
  ( p_language_code      in     fnd_languages.language_code%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------- set_session_nls_language --------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Set the session language from the nls language and clears the
--   key flex cache
--
-- Prerequisites:
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   ====                  ==== ====     ===========
--   p_nls_language        Yes  varchar2 The nls language (NOT the 2 letter language code)
--
-- Post Success:
-- userev('LANG') is set to language code derived from nls language
--
-- Post Failure:
-- user session language is not changed
--
--
-- Access Status:
--   Public  - For Internal Development Use Only
--
-- {End Of Comments}
--
procedure set_session_nls_language
  ( p_nls_language       in     fnd_languages.nls_language%TYPE
  );
end hr_kflex_utility;

/
