--------------------------------------------------------
--  DDL for Package HR_PROCESS_SIT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_SIT_SS" AUTHID CURRENT_USER as
/* $Header: hrsitwrs.pkh 115.8 2002/12/10 01:03:58 lma noship $ */


  gv_wf_review_region_item    constant wf_item_attributes.name%type
                             := 'HR_REVIEW_REGION_ITEM';


---- Declare a row of pereanalysis_criteria ----------------------------------
   TYPE per_analysis_criteria_rec IS RECORD(
         segment1 per_analysis_criteria.segment1%TYPE,
         segment2 per_analysis_criteria.segment2%TYPE,
         segment3 per_analysis_criteria.segment3%TYPE,
         segment4 per_analysis_criteria.segment4%TYPE,
         segment5 per_analysis_criteria.segment5%TYPE,
         segment6 per_analysis_criteria.segment6%TYPE,
         segment7 per_analysis_criteria.segment7%TYPE,
         segment8 per_analysis_criteria.segment8%TYPE,
         segment9 per_analysis_criteria.segment9%TYPE,
         segment10 per_analysis_criteria.segment10%TYPE,
         segment11 per_analysis_criteria.segment11%TYPE,
         segment12 per_analysis_criteria.segment12%TYPE,
         segment13 per_analysis_criteria.segment13%TYPE,
         segment14 per_analysis_criteria.segment14%TYPE,
         segment15 per_analysis_criteria.segment15%TYPE,
         segment16 per_analysis_criteria.segment16%TYPE,
         segment17 per_analysis_criteria.segment17%TYPE,
         segment18 per_analysis_criteria.segment18%TYPE,
         segment19 per_analysis_criteria.segment19%TYPE,
         segment20 per_analysis_criteria.segment20%TYPE,
         segment21 per_analysis_criteria.segment21%TYPE,
         segment22 per_analysis_criteria.segment22%TYPE,
         segment23 per_analysis_criteria.segment23%TYPE,
         segment24 per_analysis_criteria.segment24%TYPE,
         segment25 per_analysis_criteria.segment25%TYPE,
         segment26 per_analysis_criteria.segment26%TYPE,
         segment27 per_analysis_criteria.segment27%TYPE,
         segment28 per_analysis_criteria.segment28%TYPE,
         segment29 per_analysis_criteria.segment29%TYPE,
         segment30 per_analysis_criteria.segment30%TYPE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< insert_sit >--------------------------------|
-- ----------------------------------------------------------------------------
-- Wrapper Package for API hr_process_sit_ss.
--
PROCEDURE save_transaction_data
    (p_person_id                 in   number
    ,p_login_person_id           in   number
    ,p_person_analysis_id        in   number
    ,p_pea_object_version_number in   number
    ,p_effective_date            in   date   default null
    ,p_date_from                 in   date   default null
    ,p_date_to                   in   date   default null
    ,p_analysis_criteria_id      in   number
    ,p_old_analysis_criteria_id  in   number
    ,p_business_group_id         in   number
    ,p_id_flex_num               in   number
    ,p_structure_code            in   varchar2
    ,p_structure_name            in   varchar2
    ,p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   number
    ,p_action                    in   varchar2
    ,p_flow_mode                 in   varchar2 default null
    ,p_transaction_step_id       out nocopy number
    ,p_error_message             out nocopy long
    ,p_attribute_category        in   varchar2
    ,p_attribute1                in   varchar2
    ,p_attribute2                in   varchar2
    ,p_attribute3                in   varchar2
    ,p_attribute4                in   varchar2
    ,p_attribute5                in   varchar2
    ,p_attribute6                in   varchar2
    ,p_attribute7                in   varchar2
    ,p_attribute8                in   varchar2
    ,p_attribute9                in   varchar2
    ,p_attribute10               in   varchar2
    ,p_attribute11               in   varchar2
    ,p_attribute12               in   varchar2
    ,p_attribute13               in   varchar2
    ,p_attribute14               in   varchar2
    ,p_attribute15               in   varchar2
    ,p_attribute16               in   varchar2
    ,p_attribute17               in   varchar2
    ,p_attribute18               in   varchar2
    ,p_attribute19               in   varchar2
    ,p_attribute20               in   varchar2
  );

-- Description:
--  This API creates a special information record for a person identified by
--  person_id.
--
--
-- Prerequisites:
--  A person identified by person_id must exist in per_people_f.
--  Special Information Type identified by id_flex_num must be defined.
--
--
-- In Parameters:
--   Name                      Reqd  Type     Description
-- p_validate                  No    number   If 0, the database remains
--                                            unchanged. If 1 then the
--                                            special information data will
--                                            be created.
-- p_person_id                 Yes   number   ID person
-- p_business_group_id         Yes   number   business group id
-- p_id_flex_num               Yes   number   id flex number
-- p_structure_code            Yes   varchar2 structure code
-- p_structure_name            Yes   varchar2 structure name
-- p_effective_date            Yes   date     The effective date for this
--                                            insert.
-- p_analysis_criteria_id      Yes   number   If p_validate is false, uniquely
--                                              identifies the combination of
--                                              segments passed.  If p_validate
--                                              is true, set to null.
-- p_date_from                 No    date     date from
-- p_date_to                   No    date     date to
--
-- Post Success:
--  A special information record is inserted and the following OUT parameters
--  are set.
--
--   Name                              Type     Description
--   p_person_analysis_id              number   If p_validate is false, uniquely
--                                              identifies the person analysis
--                                              created. if p_validate is true,
--                                              set to null.
--   p_pea_object_version_number       number   If p_validate is false, set to
--                                              the version number of the
--                                              person analysis created. If
--                                              p_validate is true, set to null.
--
--
-- Post Failure:
--  API does not insert a special information record and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
procedure insert_sit
  (p_validate                  in    number default 1
  ,p_person_id                 in    number
  ,p_business_group_id         in    number
  ,p_id_flex_num               in    number
  ,p_effective_date            in    date
  ,p_date_from                 in    date     default null
  ,p_date_to                   in    date     default null
  ,p_analysis_criteria_id      in    number
  ,p_person_analysis_id        out nocopy  number
  ,p_pea_object_version_number out nocopy  number
  ,p_login_person_id           in    number
  ,p_item_type                 in    varchar2
  ,p_item_key                  in    varchar2
  ,p_activity_id               in    number
  ,p_action                    in    varchar2
  ,p_save_mode                 in    varchar2 default null
  ,p_error_message             out nocopy  long
  ,p_attribute_category        in   varchar2
  ,p_attribute1                in   varchar2
  ,p_attribute2                in   varchar2
  ,p_attribute3                in   varchar2
  ,p_attribute4                in   varchar2
  ,p_attribute5                in   varchar2
  ,p_attribute6                in   varchar2
  ,p_attribute7                in   varchar2
  ,p_attribute8                in   varchar2
  ,p_attribute9                in   varchar2
  ,p_attribute10               in   varchar2
  ,p_attribute11               in   varchar2
  ,p_attribute12               in   varchar2
  ,p_attribute13               in   varchar2
  ,p_attribute14               in   varchar2
  ,p_attribute15               in   varchar2
  ,p_attribute16               in   varchar2
  ,p_attribute17               in   varchar2
  ,p_attribute18               in   varchar2
  ,p_attribute19               in   varchar2
  ,p_attribute20               in   varchar2
 );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_sit >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API updates a special information record for a person identified by
--  person_id.
--
--
-- Prerequisites:
--  A person identified by person_id must exist in per_people_f.
--  Special Information Type identified by id_flex_num must be defined.
--
--
-- In Parameters:
--   Name                      Reqd  Type     Description
-- p_validate                  No    number   If 0, the database remains
--                                            unchanged. If 1 then the
--                                            special information data will
--                                            be created.
-- p_person_analysis_id        in    number   person analysis id
-- p_date_from                 in    date     date from
-- p_date_to                   in    date     date to
-- p_analysis_criteria_id      in    number   If p_validate is false, uniquely
--                                              identifies the combination of
--                                              segments passed.  If p_validate
--                                              is true, set to null.
--
-- Post Success:
--  A special information record is updated and the following OUT parameters
--  are set.
--
--   Name                              Type     Description
--   p_pea_object_version_number       number   If p_validate is false, set to
--                                              the version number of the
--                                              person analysis updated. If
--                                              p_validate is true, set to null.
--
--
-- Post Failure:
--  API does not update a special information record and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
procedure update_sit
  (p_validate                  in     number default 1
  ,p_person_id                 in     number
  ,p_person_analysis_id        in     number
  ,p_pea_object_version_number in out nocopy number
  ,p_date_from                 in     date     default hr_api.g_date
  ,p_date_to                   in     date     default hr_api.g_date
  ,p_analysis_criteria_id      in     number
  ,p_login_person_id           in     number
  ,p_business_group_id         in     number
  ,p_id_flex_num               in     number
  ,p_item_type                 in     varchar2
  ,p_item_key                  in     varchar2
  ,p_activity_id               in     number
  ,p_action                    in    varchar2
  ,p_save_mode                 in     varchar2 default null
  ,p_error_message             out nocopy   long
  ,p_attribute_category        in   varchar2
  ,p_attribute1                in   varchar2
  ,p_attribute2                in   varchar2
  ,p_attribute3                in   varchar2
  ,p_attribute4                in   varchar2
  ,p_attribute5                in   varchar2
  ,p_attribute6                in   varchar2
  ,p_attribute7                in   varchar2
  ,p_attribute8                in   varchar2
  ,p_attribute9                in   varchar2
  ,p_attribute10               in   varchar2
  ,p_attribute11               in   varchar2
  ,p_attribute12               in   varchar2
  ,p_attribute13               in   varchar2
  ,p_attribute14               in   varchar2
  ,p_attribute15               in   varchar2
  ,p_attribute16               in   varchar2
  ,p_attribute17               in   varchar2
  ,p_attribute18               in   varchar2
  ,p_attribute19               in   varchar2
  ,p_attribute20               in   varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------<  delete_sit  >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a SIT record on the PER_PERSON_ANALYSES table.
--
-- Prerequisites:
--   The SIT specified by p_perosn_analysis_id and p_pea_object_version_number
--   must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   number   If 0 , the database
--                                                remains unchanged. If 1
--                                                then the employee analysis row will
--                                                be deleted from the database.
--   p_person_analysis_id            Y   number   Person Analysis id.
--   p_pea_object_version_number     Y   number   Version number of the SIT
--                                                record on PER_PERSON_ANALYSES
--                                                not that of PER_ANALYSIS_CRITERIA
-- Post Success:
--   The API deletes the SIT record.
--
-- Post Failure:
--   The API does not delete the SIT and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_sit
  (p_validate                       in     number default 1
  ,p_person_id                      in     number
  ,p_person_analysis_id             in     number
  ,p_pea_object_version_number      in     number
  ,p_analysis_criteria_id           in     number
  ,p_login_person_id                in     number
  ,p_business_group_id              in     number
  ,p_id_flex_num                    in     number
  ,p_item_type                      in     varchar2
  ,p_item_key                       in     varchar2
  ,p_activity_id                    in     number
  ,p_action                    in    varchar2
  ,p_save_mode                      in     varchar2 default null
  ,p_error_message                  out nocopy   long
  );
--

--
-- ----------------------------------------------------------------------------
-- |----------------------< get_segments_from_ccid >--------------------------|
-- ----------------------------------------------------------------------------
-- Wrapper Package for API hr_process_sit_ss.
--
-- Description:
--  This Function gets the segments info for the given per_anlaysis_criteria_id from
--  per_analysis_criteria table and returns as record type.
--
--
-- Prerequisites:
--  A person identified by person_id must exist in per_people_f.
--  Special Information Type identified by id_flex_num must be defined.
--
--
-- In Parameters:
--   Name                      Reqd  Type     Description
-- p_analysis_criteria_id      Yes   number   anlaysis_criteria_id
--
-- Returns:
-- per_analysis_criteria_rec  of per_analysis_criteria rec type.
--  --------------------------------------------------------------------------

FUNCTION get_segments_from_ccid(p_analysis_criteria_id IN NUMBER)
         RETURN per_analysis_criteria_rec ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_transaction_data >---------------------------|
-- Wrapper Package for API hr_process_sit_ss.
--
-- Description:
--  This Function gets the transaction data for the given step id.
-- ----------------------------------------------------------------------------
PROCEDURE get_transaction_data
    (p_transaction_step_id       in    number
    ,p_person_id                 out nocopy  number
    ,p_login_person_id           out nocopy  number
    ,p_person_analysis_id        out nocopy  number
    ,p_pea_object_version_number out nocopy  number
    ,p_effective_date            out nocopy  date
    ,p_date_from                 out nocopy  date
    ,p_date_to                   out nocopy  date
    ,p_analysis_criteria_id      out nocopy  number
    ,p_old_analysis_criteria_id  out nocopy  number
    ,p_business_group_id         out nocopy  number
    ,p_id_flex_num               out nocopy  number
    ,p_structure_code            out nocopy  varchar2
    ,p_structure_name            out nocopy  varchar2
    ,p_action                    out nocopy  varchar2
    ,p_error_message             out nocopy  long
    ,p_attribute_category        out nocopy varchar2
    ,p_attribute1                out nocopy varchar2
    ,p_attribute2                out nocopy varchar2
    ,p_attribute3                out nocopy varchar2
    ,p_attribute4                out nocopy varchar2
    ,p_attribute5                out nocopy varchar2
    ,p_attribute6                out nocopy varchar2
    ,p_attribute7                out nocopy varchar2
    ,p_attribute8                out nocopy varchar2
    ,p_attribute9                out nocopy varchar2
    ,p_attribute10               out nocopy varchar2
    ,p_attribute11               out nocopy varchar2
    ,p_attribute12               out nocopy varchar2
    ,p_attribute13               out nocopy varchar2
    ,p_attribute14               out nocopy varchar2
    ,p_attribute15               out nocopy varchar2
    ,p_attribute16               out nocopy varchar2
    ,p_attribute17               out nocopy varchar2
    ,p_attribute18               out nocopy varchar2
    ,p_attribute19               out nocopy varchar2
    ,p_attribute20               out nocopy varchar2
  );

PROCEDURE process_api
        (p_validate IN BOOLEAN DEFAULT FALSE
        ,p_transaction_step_id IN NUMBER DEFAULT NULL
        ,p_effective_date      IN VARCHAR2 DEFAULT null
);


-- ----------------------------------------------------------------------------
-- |-----------------------< del_transaction_data >---------------------------|
-- Wrapper Package for API hr_process_sit_ss.
--
-- Description:
--  This Function dels the transaction data for the given item type, item key
--  and activity id.
-- ----------------------------------------------------------------------------

PROCEDURE del_transaction_data
    (p_item_type                 in   varchar2
    ,p_item_key                  in   varchar2
    ,p_activity_id               in   varchar2
    ,p_login_person_id           in   varchar2
    ,p_flow_mode                 in   varchar2 default null
);

end hr_process_sit_ss;

 

/
