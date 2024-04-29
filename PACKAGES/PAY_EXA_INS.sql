--------------------------------------------------------
--  DDL for Package PAY_EXA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EXA_INS" AUTHID CURRENT_USER AS
/* $Header: pyexarhi.pkh 115.5 2002/12/10 18:44:35 dsaxby ship $ */
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
procedure ins(
   p_rec               in out nocopy pay_exa_shd.g_rec_type
  ,p_business_group_id in     number
  ,p_validate          in     boolean default false
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
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  number   Business group id.
--   p_external_account_id          Yes  number   Code combination id of
--                                                external account.
--   p_territory_code                    varchar  Territory code to be placed
--                                                on a freshly created
--                                                combination record.
--                                                nb. Once a combination is
--                                                created the territory code
--                                                cannot be updated.
--   p_prenote_date                      date     Prenote data on combination,
--                                                updating this causes the
--                                                ovn of the combination to be
--                                                incremented.
--   p_segment1                          varchar2 External account combination
--                                                key flexfield.
--   . . .
--   p_segment30                         varchar2 External account combination
--   p_validate                          boolean  If true, the database
--                                                remains unchanged.
--                                                If false, then an external
--                                                account will be created in
--                                                the database.
--                                                key flexfield.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
--   Name                                Type     Description
--   p_object_version_number             number   If p_validate is false,
--                                                this will be set to the
--                                                version number of
--                                                the external account.
--                                                If p_validate is true,
--                                                this parameter will be null.
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
procedure ins(
   p_business_group_id            in number
  ,p_external_account_id          in number
  ,p_territory_code               in varchar2         default null
  ,p_prenote_date                 in date             default null
  ,p_segment1                     in varchar2         default null
  ,p_segment2                     in varchar2         default null
  ,p_segment3                     in varchar2         default null
  ,p_segment4                     in varchar2         default null
  ,p_segment5                     in varchar2         default null
  ,p_segment6                     in varchar2         default null
  ,p_segment7                     in varchar2         default null
  ,p_segment8                     in varchar2         default null
  ,p_segment9                     in varchar2         default null
  ,p_segment10                    in varchar2         default null
  ,p_segment11                    in varchar2         default null
  ,p_segment12                    in varchar2         default null
  ,p_segment13                    in varchar2         default null
  ,p_segment14                    in varchar2         default null
  ,p_segment15                    in varchar2         default null
  ,p_segment16                    in varchar2         default null
  ,p_segment17                    in varchar2         default null
  ,p_segment18                    in varchar2         default null
  ,p_segment19                    in varchar2         default null
  ,p_segment20                    in varchar2         default null
  ,p_segment21                    in varchar2         default null
  ,p_segment22                    in varchar2         default null
  ,p_segment23                    in varchar2         default null
  ,p_segment24                    in varchar2         default null
  ,p_segment25                    in varchar2         default null
  ,p_segment26                    in varchar2         default null
  ,p_segment27                    in varchar2         default null
  ,p_segment28                    in varchar2         default null
  ,p_segment29                    in varchar2         default null
  ,p_segment30                    in varchar2         default null
  ,p_object_version_number        out nocopy number
  ,p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the processing required to either insert a new
--   combination or update the existing one.
--   1. If a combination does not exist a new combination is inserted
--      returning the new p_external_account_id and p_object_version_numbers.
--   2. If a combination does exist and the prenote_date is being updated then
--      the combination is updated.
--   3. If a combination exists and is not being updating the prenote_date and
--      out arguments are set.
--   4. If the segments are null (i.e. a null combination) then the out
--      arguments are set to null.
--
-- Pre Conditions:
--
-- In Arguments:
--   Name                           Reqd Type     Description
--   p_segment1                          varchar2 External account combination
--                                                key flexfield.
--   . . .
--   p_segment30                         varchar2 External account combination
--                                                key flexfield.
--   p_concat_segments                   varchar2 External account combination
--                                                string, if specified takes
--                                                precedence over segment1...30.
--   p_business_group_id            Yes  varchar2 Is specified to enable the
--                                                derivation of the
--                                                id_flex_num within the
--                                                process pay_exa_shd.
--                                                segment_combination_check.
--   p_territory_code               Yes  varchar  Territory code to be placed
--                                                on a freshly created
--                                                combination record,
--                                                nb. Once a combination is
--                                                created the territory code
--                                                cannot be updated.
--   p_prenote_date                      date     Prenote data on combination,
--                                                updating this causes the
--                                                ovn of the combination to be
--                                                incremented.
--   p_validate                          boolean  If true, the database
--                                                remains unchanged.
--                                                If false, then an external
--                                                account will be created in
--                                                the database.
--
-- Post Success:
--   If a combination already exists the out arguments are returned.
--   If a combination exists and the prenote_date is being updated then
--   combination is updated and out arguments returned.
--   If a combination does not exist then the combination is inserted into
--   the pay_external_accounts table and the out arguments are returned.
--   Processing continues.
--
--   Name                                Type     Description
--   p_external_account_id               number   If p_validate is false,
--                                                this will be the ccid of a
--                                                new or existing external
--                                                account,
--                                                If p_validate is true,
--                                                this will be null
--   p_object_version_number             number   If p_validate is false,
--                                                this will be set to the
--                                                object version number of
--                                                a new or existing external
--                                                account.
--                                                If p_validate is true,
--                                                this will be null.
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
procedure ins_or_sel(
   p_segment1              in  varchar2 default null
  ,p_segment2              in  varchar2 default null
  ,p_segment3              in  varchar2 default null
  ,p_segment4              in  varchar2 default null
  ,p_segment5              in  varchar2 default null
  ,p_segment6              in  varchar2 default null
  ,p_segment7              in  varchar2 default null
  ,p_segment8              in  varchar2 default null
  ,p_segment9              in  varchar2 default null
  ,p_segment10             in  varchar2 default null
  ,p_segment11             in  varchar2 default null
  ,p_segment12             in  varchar2 default null
  ,p_segment13             in  varchar2 default null
  ,p_segment14             in  varchar2 default null
  ,p_segment15             in  varchar2 default null
  ,p_segment16             in  varchar2 default null
  ,p_segment17             in  varchar2 default null
  ,p_segment18             in  varchar2 default null
  ,p_segment19             in  varchar2 default null
  ,p_segment20             in  varchar2 default null
  ,p_segment21             in  varchar2 default null
  ,p_segment22             in  varchar2 default null
  ,p_segment23             in  varchar2 default null
  ,p_segment24             in  varchar2 default null
  ,p_segment25             in  varchar2 default null
  ,p_segment26             in  varchar2 default null
  ,p_segment27             in  varchar2 default null
  ,p_segment28             in  varchar2 default null
  ,p_segment29             in  varchar2 default null
  ,p_segment30             in  varchar2 default null
  ,p_concat_segments       in  varchar2 default null
  ,p_business_group_id     in  number
-- make territory_code code a mandatory parameter on I interface
  ,p_territory_code        in  varchar2
  ,p_prenote_date          in  date     default null
  ,p_external_account_id   out nocopy number
  ,p_object_version_number out nocopy number
  ,p_validate              in boolean   default false
  );
--
END pay_exa_ins;

 

/
