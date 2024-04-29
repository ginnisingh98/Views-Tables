--------------------------------------------------------
--  DDL for Package PAY_BATCH_BALANCEADJ_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_BALANCEADJ_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: paybbawebadi.pkh 120.7.12010000.1 2008/07/27 21:44:48 appldev ship $ */

PROCEDURE create_batch_header(p_batch_name        in varchar2,
                              p_business_group_id in number,
                              p_batch_reference   in varchar2 default null,
                              p_batch_source      in varchar2 default null,
                              p_batch_status      in varchar2 default 'U',
                              p_batch_id          out nocopy number );

PROCEDURE update_batch_header(p_batch_id          in number,
                              p_batch_name        in varchar2 default hr_api.g_varchar2,
                              p_batch_reference   in varchar2 default hr_api.g_varchar2,
                              p_batch_source      in varchar2 default hr_api.g_varchar2,
                              p_batch_status      in varchar2 default hr_api.g_varchar2);

PROCEDURE update_batch_groups_lines(p_batch_id                in number,
                                    p_batch_name              in varchar2,
				    p_batch_group_id          in number,   -- NEW
				    p_batch_line_id           in number,   -- NEW
				    p_effective_date          in date, -- effective date
				    p_employee_id             in varchar2, -- Employee Name
				    p_assignment_id           in varchar2, -- assignment_number
				    p_element_name            in varchar2,
				    p_element_type_id         in number,
				    p_element_link_id         in number,
				    p_payroll_id              in number default null,
				    p_business_group_id       in number,
				    p_consolidation_set_id    in number default null,
				    p_gre_id                  in number default null,
				    p_prepay_flag             in varchar2 ,
				    p_costing_flag            in varchar2 ,
				    p_cost_allocation_keyflex in number default null,
				    p_concatenated_segments   in varchar2 default null,
				    segment1                in varchar2 default null,
				    segment2                in varchar2 default null,
				    segment3                in varchar2 default null,
				    segment4                in varchar2 default null,
				    segment5                in varchar2 default null,
				    segment6                in varchar2 default null,
				    segment7                in varchar2 default null,
				    segment8                in varchar2 default null,
				    segment9                in varchar2 default null,
				    segment10               in varchar2 default null,
				    segment11               in varchar2 default null,
				    segment12               in varchar2 default null,
				    segment13               in varchar2 default null,
				    segment14               in varchar2 default null,
				    segment15               in varchar2 default null,
				    segment16               in varchar2 default null,
				    segment17               in varchar2 default null,
				    segment18               in varchar2 default null,
				    segment19               in varchar2 default null,
				    segment20               in varchar2 default null,
				    segment21               in varchar2 default null,
				    segment22               in varchar2 default null,
				    segment23               in varchar2 default null,
				    segment24               in varchar2 default null,
				    segment25               in varchar2 default null,
				    segment26               in varchar2 default null,
				    segment27               in varchar2 default null,
				    segment28               in varchar2 default null,
				    segment29               in varchar2 default null,
				    segment30               in varchar2 default null,
				    p_ee_value1               in varchar2 default null,
				    p_ee_value2               in varchar2 default null,
				    p_ee_value3               in varchar2 default null,
				    p_ee_value4               in varchar2 default null,
				    p_ee_value5               in varchar2 default null,
				    p_ee_value6               in varchar2 default null,
				    p_ee_value7               in varchar2 default null,
				    p_ee_value8               in varchar2 default null,
				    p_ee_value9               in varchar2 default null,
				    p_ee_value10              in varchar2 default null,
				    p_ee_value11              in varchar2 default null,
				    p_ee_value12              in varchar2 default null,
				    p_ee_value13              in varchar2 default null,
				    p_ee_value14              in varchar2 default null,
				    p_ee_value15              in varchar2 default null,
				    p_col1                    in number default null,
				    p_col2                    in number default null,
				    p_col3                    in number default null,
				    p_col4                    in number default null,
				    p_col5                    in number default null,
				    p_col_val1                in varchar2 default null,
				    p_col_val2                in varchar2 default null,
				    p_col_val3                in varchar2 default null,
				    p_col_val4                in varchar2 default null,
				    p_col_val5                in varchar2 default null);


PROCEDURE upload_data(p_batch_id                in number,
                      p_batch_name              in varchar2,
                      p_effective_date          in date, -- effective date
		      p_employee_id             in varchar2, -- Employee Name
		      p_assignment_id           in varchar2, -- assignment_number
		      p_element_name            in varchar2,
		      p_element_type_id         in number,
		      p_element_link_id         in number default null,
		      p_payroll_id              in varchar2 default null, -- Payroll Name
		      p_business_group_id       in number,
		      p_consolidation_set_id    in number default null,
		      p_gre_id                  in varchar2 default null,
		      p_prepay_flag             in varchar2 ,
		      p_costing_flag            in varchar2 ,
		      p_cost_allocation_keyflex in number default null,
		      p_concatenated_segments   in varchar2 default null,
		      segment1                in varchar2 default null,
		      segment2                in varchar2 default null,
		      segment3                in varchar2 default null,
		      segment4                in varchar2 default null,
		      segment5                in varchar2 default null,
		      segment6                in varchar2 default null,
		      segment7                in varchar2 default null,
		      segment8                in varchar2 default null,
		      segment9                in varchar2 default null,
		      segment10               in varchar2 default null,
		      segment11               in varchar2 default null,
		      segment12               in varchar2 default null,
		      segment13               in varchar2 default null,
		      segment14               in varchar2 default null,
		      segment15               in varchar2 default null,
		      segment16               in varchar2 default null,
		      segment17               in varchar2 default null,
		      segment18               in varchar2 default null,
		      segment19               in varchar2 default null,
		      segment20               in varchar2 default null,
		      segment21               in varchar2 default null,
		      segment22               in varchar2 default null,
		      segment23               in varchar2 default null,
		      segment24               in varchar2 default null,
		      segment25               in varchar2 default null,
		      segment26               in varchar2 default null,
		      segment27               in varchar2 default null,
		      segment28               in varchar2 default null,
		      segment29               in varchar2 default null,
		      segment30               in varchar2 default null,
		      p_ee_value1               in varchar2 default null,
		      p_ee_value2               in varchar2 default null,
		      p_ee_value3               in varchar2 default null,
		      p_ee_value4               in varchar2 default null,
		      p_ee_value5               in varchar2 default null,
		      p_ee_value6               in varchar2 default null,
		      p_ee_value7               in varchar2 default null,
		      p_ee_value8               in varchar2 default null,
		      p_ee_value9               in varchar2 default null,
		      p_ee_value10              in varchar2 default null,
		      p_ee_value11              in varchar2 default null,
		      p_ee_value12              in varchar2 default null,
		      p_ee_value13              in varchar2 default null,
		      p_ee_value14              in varchar2 default null,
		      p_ee_value15              in varchar2 default null,
		      p_col1                    in number default null,
		      p_col2                    in number default null,
		      p_col3                    in number default null,
		      p_col4                    in number default null,
		      p_col5                    in number default null,
		      p_col_val1                in varchar2 default null,
		      p_col_val2                in varchar2 default null,
		      p_col_val3                in varchar2 default null,
		      p_col_val4                in varchar2 default null,
		      p_col_val5                in varchar2 default null,
		      p_batch_line_id           in number default null,
		      p_batch_group_id          in number default null,
		      p_batch_line_status       in varchar2 default null,
		      p_mode                    in varchar2 default null);

FUNCTION convert_internal_to_display(p_element_type_id               IN     VARCHAR2,
                                     p_input_value                   IN     VARCHAR2,
				     p_input_value_number            IN     NUMBER,
				     p_session_date                  IN     DATE,
				     p_batch_id                      IN     NUMBER,
				     p_calling_mode                  IN     VARCHAR2
				     ) return varchar2;
--

g_element_type_id number default null;

g_ip_id1      number   default null;
g_ip_id2      number   default null;
g_ip_id3      number   default null;
g_ip_id4      number   default null;
g_ip_id5      number   default null;
g_ip_id6      number   default null;
g_ip_id7      number   default null;
g_ip_id8      number   default null;
g_ip_id9      number   default null;
g_ip_id10      number   default null;
g_ip_id11      number   default null;
g_ip_id12      number   default null;
g_ip_id13      number   default null;
g_ip_id14      number   default null;
g_ip_id15      number   default null;

-- Bug: 5200900
g_ee_value1 varchar2(60) default null;
g_ee_value2 varchar2(60) default null;
g_ee_value3 varchar2(60) default null;
g_ee_value4 varchar2(60) default null;
g_ee_value5 varchar2(60) default null;
g_ee_value6 varchar2(60) default null;
g_ee_value7 varchar2(60) default null;
g_ee_value8 varchar2(60) default null;
g_ee_value9 varchar2(60) default null;
g_ee_value10 varchar2(60) default null;
g_ee_value11 varchar2(60) default null;
g_ee_value12 varchar2(60) default null;
g_ee_value13 varchar2(60) default null;
g_ee_value14 varchar2(60) default null;
g_ee_value15 varchar2(60) default null;

g_batch_id     number;

g_pactid_flag  boolean default FALSE;
g_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
g_flex_num     number;

g_display_sequence   number;

/* Pl/Sql table to store and compare unique combination
   values to create batch_group_id */

  TYPE batch_group_rec IS RECORD(batch_id number(30)
                                ,consolidation_set_id   number(30)
				,payroll_id             number(30)
				,effective_date         date
				,prepay_flag            varchar2(2)
				,batch_group_status     varchar2(2)
				,batch_group_id         number(30)
				);

  TYPE batch_group_table IS TABLE OF batch_group_rec
  INDEX BY BINARY_INTEGER;

  gtr_batch_group_data batch_group_table;

end pay_batch_balanceadj_wrapper;

/
