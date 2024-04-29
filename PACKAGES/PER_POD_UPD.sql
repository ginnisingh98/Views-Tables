--------------------------------------------------------
--  DDL for Package PER_POD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POD_UPD" AUTHID CURRENT_USER as
/* $Header: pepodrhi.pkh 115.5 2002/12/04 10:55:53 eumenyio ship $ */
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
--   This private function can only be called from the upd process.
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
--   errors within this procedure will be a PL/SQL value error due
--   to conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_pod_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the processing required to either insert a new
--   combination or update the existing one. This procedure has the same
--   functionality of per_pod_ins.ins_or_sel except is has to take into
--   account the building of a partially specified interface by making calls
--   in convert_args and convert_defs.
--   1. If a combination does not exist a new combination is inserted
--      returning the new p_position_definition_id.
--   2. If a combination exists the out arguments are set.
--   4. If the segments are null (i.e. a null combination) then the out
--      arguments are set to null.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_business_group_id     => is specified to enable the derivation of the
--                              id_flex_num within the process
--                              per_pod_shd.segment_combination_check.
--
-- Post Success:
--   If a combination already exists the out arguments are returned.
--   If a combination does not exist then the combination is inserted into
--   the per_position_definitions table and the out arguments are returned.
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
procedure upd_or_sel
         (p_segment1               in     varchar2 default hr_api.g_varchar2,
          p_segment2               in     varchar2 default hr_api.g_varchar2,
          p_segment3               in     varchar2 default hr_api.g_varchar2,
          p_segment4               in     varchar2 default hr_api.g_varchar2,
          p_segment5               in     varchar2 default hr_api.g_varchar2,
          p_segment6               in     varchar2 default hr_api.g_varchar2,
          p_segment7               in     varchar2 default hr_api.g_varchar2,
          p_segment8               in     varchar2 default hr_api.g_varchar2,
          p_segment9               in     varchar2 default hr_api.g_varchar2,
          p_segment10              in     varchar2 default hr_api.g_varchar2,
          p_segment11              in     varchar2 default hr_api.g_varchar2,
          p_segment12              in     varchar2 default hr_api.g_varchar2,
          p_segment13              in     varchar2 default hr_api.g_varchar2,
          p_segment14              in     varchar2 default hr_api.g_varchar2,
          p_segment15              in     varchar2 default hr_api.g_varchar2,
          p_segment16              in     varchar2 default hr_api.g_varchar2,
          p_segment17              in     varchar2 default hr_api.g_varchar2,
          p_segment18              in     varchar2 default hr_api.g_varchar2,
          p_segment19              in     varchar2 default hr_api.g_varchar2,
          p_segment20              in     varchar2 default hr_api.g_varchar2,
          p_segment21              in     varchar2 default hr_api.g_varchar2,
          p_segment22              in     varchar2 default hr_api.g_varchar2,
          p_segment23              in     varchar2 default hr_api.g_varchar2,
          p_segment24              in     varchar2 default hr_api.g_varchar2,
          p_segment25              in     varchar2 default hr_api.g_varchar2,
          p_segment26              in     varchar2 default hr_api.g_varchar2,
          p_segment27              in     varchar2 default hr_api.g_varchar2,
          p_segment28              in     varchar2 default hr_api.g_varchar2,
          p_segment29              in     varchar2 default hr_api.g_varchar2,
          p_segment30              in     varchar2 default hr_api.g_varchar2,
          p_business_group_id      in     number,
          p_position_definition_id in out nocopy number,
          p_name                      out nocopy varchar2,
          p_validate               in     boolean default false);
--
end per_pod_upd;

 

/
