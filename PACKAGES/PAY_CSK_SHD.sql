--------------------------------------------------------
--  DDL for Package PAY_CSK_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CSK_SHD" AUTHID CURRENT_USER as
/* $Header: pycskrhi.pkh 115.0 99/07/17 05:55:45 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  costing_keyflex_id                number(15),
  concatenated_segments             varchar2(240),
  id_flex_num                       number(15),
  summary_flag                      varchar2(9),      -- Increased length
  enabled_flag                      varchar2(9),      -- Increased length
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
  segment20                         varchar2(60),
  segment21                         varchar2(60),
  segment22                         varchar2(60),
  segment23                         varchar2(60),
  segment24                         varchar2(60),
  segment25                         varchar2(60),
  segment26                         varchar2(60),
  segment27                         varchar2(60),
  segment28                         varchar2(60),
  segment29                         varchar2(60),
  segment30                         varchar2(60)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
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
	p_costing_keyflex_id            in number,
	p_concatenated_segments         in varchar2,
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
	p_segment20                     in varchar2,
	p_segment21                     in varchar2,
	p_segment22                     in varchar2,
	p_segment23                     in varchar2,
	p_segment24                     in varchar2,
	p_segment25                     in varchar2,
	p_segment26                     in varchar2,
	p_segment27                     in varchar2,
	p_segment28                     in varchar2,
	p_segment29                     in varchar2,
	p_segment30                     in varchar2
	)
	Return g_rec_type;
--
end pay_csk_shd;

 

/
