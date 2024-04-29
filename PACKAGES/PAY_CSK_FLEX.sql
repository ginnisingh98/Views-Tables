--------------------------------------------------------
--  DDL for Package PAY_CSK_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CSK_FLEX" AUTHID CURRENT_USER as
/* $Header: pycskfli.pkh 115.0 99/07/17 05:55:37 porting ship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< kf >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    key flexfields by calling the relevant validation
--    procedures.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_rec (Record structure for relevant entity).
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--
--  Developer Implementation Notes:
--    Customer/Development defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure kf(p_rec               in pay_csk_shd.g_rec_type);
FUNCTION get_cost_allocation_id(p_business_group_id          in number,
                                p_cost_allocation_keyflex_id in number,
                                p_concatenated_segments      in varchar2,
                                p_segment1         in varchar2 default NULL,
                                p_segment2         in varchar2 default NULL,
                                p_segment3         in varchar2 default NULL,
                                p_segment4         in varchar2 default NULL,
                                p_segment5         in varchar2 default NULL,
                                p_segment6         in varchar2 default NULL,
                                p_segment7         in varchar2 default NULL,
                                p_segment8         in varchar2 default NULL,
                                p_segment9         in varchar2 default NULL,
                                p_segment10        in varchar2 default NULL,
                                p_segment11        in varchar2 default NULL,
                                p_segment12        in varchar2 default NULL,
                                p_segment13        in varchar2 default NULL,
                                p_segment14        in varchar2 default NULL,
                                p_segment15        in varchar2 default NULL,
                                p_segment16        in varchar2 default NULL,
                                p_segment17        in varchar2 default NULL,
                                p_segment18        in varchar2 default NULL,
                                p_segment19        in varchar2 default NULL,
                                p_segment20        in varchar2 default NULL,
                                p_segment21        in varchar2 default NULL,
                                p_segment22        in varchar2 default NULL,
                                p_segment23        in varchar2 default NULL,
                                p_segment24        in varchar2 default NULL,
                                p_segment25        in varchar2 default NULL,
                                p_segment26        in varchar2 default NULL,
                                p_segment27        in varchar2 default NULL,
                                p_segment28        in varchar2 default NULL,
                                p_segment29        in varchar2 default NULL,
                                p_segment30        in varchar2 default NULL)
                                return NUMBER;

--
end pay_csk_flex;

 

/
