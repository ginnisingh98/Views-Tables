--------------------------------------------------------
--  DDL for Package HR_CGD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CGD_SHD" AUTHID CURRENT_USER as
/* $Header: hrcgdrhi.pkh 115.4 2002/12/03 09:09:36 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  cagr_grade_def_id                 number(15),
  id_flex_num                       number(15),
  summary_flag                      varchar2(1),
  enabled_flag                      varchar2(1),
  start_date_active                 date,
  end_date_active                   date,
  segment1                          varchar2(60),
  segment2                          varchar2(60),
  segment3                          varchar2(60),
  segment4                          varchar2(60),
  segment5                          varchar2(60),
  segment6                          varchar2(60),
  segment7                          varchar2(60),
  segment8                          varchar2(60),
  segment9                          varchar2(60),
  segment10                         varchar2(60),
  segment11                         varchar2(60),
  segment12                         varchar2(60),
  segment13                         varchar2(60),
  segment14                         varchar2(60),
  segment15                         varchar2(60),
  segment16                         varchar2(60),
  segment17                         varchar2(60),
  segment18                         varchar2(60),
  segment19                         varchar2(60),
  segment20                         varchar2(60)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_cagr_grade_def_id in number) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Pre Conditions:
--   This is a private function
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cagr_grade_def_id             in number,
	p_id_flex_num                   in number,
	p_summary_flag                  in varchar2,
	p_enabled_flag                  in varchar2,
	p_start_date_active             in date,
	p_end_date_active               in date,
	p_segment1                      in varchar2,
	p_segment2                      in varchar2,
	p_segment3                      in varchar2,
	p_segment4                      in varchar2,
	p_segment5                      in varchar2,
	p_segment6                      in varchar2,
	p_segment7                      in varchar2,
	p_segment8                      in varchar2,
	p_segment9                      in varchar2,
	p_segment10                     in varchar2,
	p_segment11                     in varchar2,
	p_segment12                     in varchar2,
	p_segment13                     in varchar2,
	p_segment14                     in varchar2,
	p_segment15                     in varchar2,
	p_segment16                     in varchar2,
	p_segment17                     in varchar2,
	p_segment18                     in varchar2,
	p_segment19                     in varchar2,
	p_segment20                     in varchar2
	)
	Return g_rec_type;
--
end hr_cgd_shd;

 

/
