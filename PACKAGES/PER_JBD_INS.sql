--------------------------------------------------------
--  DDL for Package PER_JBD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JBD_INS" AUTHID CURRENT_USER as
/* $Header: pejbdrhi.pkh 115.0 99/07/18 13:54:50 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out per_jbd_shd.g_rec_type,
  p_validate   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_job_definition_id            out number,
  p_id_flex_num                  in number,
  p_end_date_active              in date             default null,
  p_segment1                     in varchar2         default null,
  p_segment2                     in varchar2         default null,
  p_segment3                     in varchar2         default null,
  p_segment4                     in varchar2         default null,
  p_segment5                     in varchar2         default null,
  p_segment6                     in varchar2         default null,
  p_segment7                     in varchar2         default null,
  p_segment8                     in varchar2         default null,
  p_segment9                     in varchar2         default null,
  p_segment10                    in varchar2         default null,
  p_segment11                    in varchar2         default null,
  p_segment12                    in varchar2         default null,
  p_segment13                    in varchar2         default null,
  p_segment14                    in varchar2         default null,
  p_segment15                    in varchar2         default null,
  p_segment16                    in varchar2         default null,
  p_segment17                    in varchar2         default null,
  p_segment18                    in varchar2         default null,
  p_segment19                    in varchar2         default null,
  p_segment20                    in varchar2         default null,
  p_segment21                    in varchar2         default null,
  p_segment22                    in varchar2         default null,
  p_segment23                    in varchar2         default null,
  p_segment24                    in varchar2         default null,
  p_segment25                    in varchar2         default null,
  p_segment26                    in varchar2         default null,
  p_segment27                    in varchar2         default null,
  p_segment28                    in varchar2         default null,
  p_segment29                    in varchar2         default null,
  p_segment30                    in varchar2         default null,
  p_validate                     in boolean   default false
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the processing required to insert a new
--   combination or return the the ovn and combination id for an existing
--   combination.
--   1. If a combination does not exist a new combination is inserted
--      returning the new p_job_definition_id.
--   2. If the segments are null (i.e. a null combination) then the out
--      arguments are set to null.
--   3. If a combination does exist the p_job_definition_id is returned.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_business_group_id     => is specified to enable the derivation of the
--                              id_flex_num within the process
--                              per_jbd_shd.segment_combination_check.
--
-- Post Success:
--   If a combination already exists the out arguments are returned.
--   If a combination does not exist then the combination is inserted into
--   the per_job_definitions and the out arguments are returned.
--   Processing continues.
--
-- Post Failure:
--   This process has no specific error handling and will only error if an
--   application error has ocurred at a lower level.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure ins_or_sel
         (p_segment1              in  varchar2 default null,
          p_segment2              in  varchar2 default null,
          p_segment3              in  varchar2 default null,
          p_segment4              in  varchar2 default null,
          p_segment5              in  varchar2 default null,
          p_segment6              in  varchar2 default null,
          p_segment7              in  varchar2 default null,
          p_segment8              in  varchar2 default null,
          p_segment9              in  varchar2 default null,
          p_segment10             in  varchar2 default null,
          p_segment11             in  varchar2 default null,
          p_segment12             in  varchar2 default null,
          p_segment13             in  varchar2 default null,
          p_segment14             in  varchar2 default null,
          p_segment15             in  varchar2 default null,
          p_segment16             in  varchar2 default null,
          p_segment17             in  varchar2 default null,
          p_segment18             in  varchar2 default null,
          p_segment19             in  varchar2 default null,
          p_segment20             in  varchar2 default null,
          p_segment21             in  varchar2 default null,
          p_segment22             in  varchar2 default null,
          p_segment23             in  varchar2 default null,
          p_segment24             in  varchar2 default null,
          p_segment25             in  varchar2 default null,
          p_segment26             in  varchar2 default null,
          p_segment27             in  varchar2 default null,
          p_segment28             in  varchar2 default null,
          p_segment29             in  varchar2 default null,
          p_segment30             in  varchar2 default null,
          p_business_group_id     in  number,
          p_job_definition_id     out number,
          p_name                  out varchar2,
          p_validate              in boolean default false);
--
end per_jbd_ins;

 

/
