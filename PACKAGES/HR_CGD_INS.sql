--------------------------------------------------------
--  DDL for Package HR_CGD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CGD_INS" AUTHID CURRENT_USER as
/* $Header: hrcgdrhi.pkh 115.4 2002/12/03 09:09:36 hjonnala ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_or_sel >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the processing required to insert a new
--   combination or return the the combination id for an existing
--   combination.
--   1. If a combination does not exist a new combination is inserted
--      returning the new p_cagr_grade_def_id, if id_flex_num is given.
--   2. If the segments are null (i.e. a null combination) then the out
--      arguments are set to null.
--   3. If a combination does exist and the id_flex_num is given,
--      the p_cagr_grade_def_id is returned.
--   4. The INS_OR_SEL parameter indicates if a combination was inserted
--      or selected, or is set to 'NUL' for a null combination
--
--
-- Pre Conditions:
--
-- In Arguments:
--   p_id_flex_num
--   p_business_group_id
--
-- Out Arguments
--   p_cagr_grade_def_id
--   p_concatenated_segments
--   p_ins_or_sel
--
-- Post Success:
--   If a combination already exists the out arguments are returned.
--   If a combination does not exist then the combination is inserted into
--   the soft coded table and the out arguments are returned.
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
         (p_segment1               in  varchar2 default null,
          p_segment2               in  varchar2 default null,
          p_segment3               in  varchar2 default null,
          p_segment4               in  varchar2 default null,
          p_segment5               in  varchar2 default null,
          p_segment6               in  varchar2 default null,
          p_segment7               in  varchar2 default null,
          p_segment8               in  varchar2 default null,
          p_segment9               in  varchar2 default null,
          p_segment10              in  varchar2 default null,
          p_segment11              in  varchar2 default null,
          p_segment12              in  varchar2 default null,
          p_segment13              in  varchar2 default null,
          p_segment14              in  varchar2 default null,
          p_segment15              in  varchar2 default null,
          p_segment16              in  varchar2 default null,
          p_segment17              in  varchar2 default null,
          p_segment18              in  varchar2 default null,
          p_segment19              in  varchar2 default null,
          p_segment20              in  varchar2 default null,
          p_id_flex_num            in  number default null,
          p_business_group_id      in  number,
          p_cagr_grade_def_id      out nocopy number,
          p_concatenated_segments  out nocopy varchar2);
--
end hr_cgd_ins;

 

/
