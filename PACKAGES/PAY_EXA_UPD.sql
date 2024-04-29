--------------------------------------------------------
--  DDL for Package PAY_EXA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EXA_UPD" AUTHID CURRENT_USER AS
/* $Header: pyexarhi.pkh 115.5 2002/12/10 18:44:35 dsaxby ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This public procedure can only be called from the upd and upd_or_sel
--   processes.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handle Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure convert_defs(p_rec in out nocopy pay_exa_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
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
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
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
procedure upd(
   p_rec        in out nocopy pay_exa_shd.g_rec_type
  ,p_validate   in     boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
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
--   A fully validated row will be updated for the specified entity
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
procedure upd(
   p_external_account_id          in number
  ,p_territory_code               in varchar2
  ,p_prenote_date                 in date             default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the processing required to either insert a new
--   combination or update the existing one. This procedure has the same
--   functionality of pay_exa_ins.ins_or_sel except is has to take into
--   account the building of a partially specified interface by making calls
--   in convert_args and convert_defs.
--   1. If a combination does not exist a new combination is inserted
--      returning the new p_external_account_id and p_object_version_numbers.
--   2. If a combination does exist and the prenote_date is being updated then
--      the combination is upodated.
--   3. If a combination exists and is not updating the prenote_date the
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
--   p_business_group_id                 number   Is specified to enable the
--                                                derivation of the
--                                                id_flex_num within the
--                                                process pay_exa_shd.
--                                                segment_combination_check.
--   p_territory_code                    varchar  Territory code to be placed
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
--                                                new of existing external
--                                                account.
--                                                If p_validate is true,
--                                                this will be set to its in
--                                                value.
--   p_object_version_number             number   If p_validate is false,
--                                                this will be set to the
--                                                object version number of
--                                                the external account.
--                                                If p_validate is set to true,
--                                                this will be set to its in
--                                                value.
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
procedure upd_or_sel(
   p_segment1              in     varchar2 default hr_api.g_varchar2
  ,p_segment2              in     varchar2 default hr_api.g_varchar2
  ,p_segment3              in     varchar2 default hr_api.g_varchar2
  ,p_segment4              in     varchar2 default hr_api.g_varchar2
  ,p_segment5              in     varchar2 default hr_api.g_varchar2
  ,p_segment6              in     varchar2 default hr_api.g_varchar2
  ,p_segment7              in     varchar2 default hr_api.g_varchar2
  ,p_segment8              in     varchar2 default hr_api.g_varchar2
  ,p_segment9              in     varchar2 default hr_api.g_varchar2
  ,p_segment10             in     varchar2 default hr_api.g_varchar2
  ,p_segment11             in     varchar2 default hr_api.g_varchar2
  ,p_segment12             in     varchar2 default hr_api.g_varchar2
  ,p_segment13             in     varchar2 default hr_api.g_varchar2
  ,p_segment14             in     varchar2 default hr_api.g_varchar2
  ,p_segment15             in     varchar2 default hr_api.g_varchar2
  ,p_segment16             in     varchar2 default hr_api.g_varchar2
  ,p_segment17             in     varchar2 default hr_api.g_varchar2
  ,p_segment18             in     varchar2 default hr_api.g_varchar2
  ,p_segment19             in     varchar2 default hr_api.g_varchar2
  ,p_segment20             in     varchar2 default hr_api.g_varchar2
  ,p_segment21             in     varchar2 default hr_api.g_varchar2
  ,p_segment22             in     varchar2 default hr_api.g_varchar2
  ,p_segment23             in     varchar2 default hr_api.g_varchar2
  ,p_segment24             in     varchar2 default hr_api.g_varchar2
  ,p_segment25             in     varchar2 default hr_api.g_varchar2
  ,p_segment26             in     varchar2 default hr_api.g_varchar2
  ,p_segment27             in     varchar2 default hr_api.g_varchar2
  ,p_segment28             in     varchar2 default hr_api.g_varchar2
  ,p_segment29             in     varchar2 default hr_api.g_varchar2
  ,p_segment30             in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments       in     varchar2 default null
  ,p_business_group_id     in     number
-- make territory_code code a mandatory parameter on U interface
  ,p_territory_code        in     varchar2
  ,p_prenote_date          in     date     default hr_api.g_date
  ,p_external_account_id   in out nocopy number
  ,p_object_version_number in out nocopy number
  ,p_validate              in     boolean  default false
  );
--
END pay_exa_upd;

 

/
