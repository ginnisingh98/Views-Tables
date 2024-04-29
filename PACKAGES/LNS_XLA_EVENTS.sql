--------------------------------------------------------
--  DDL for Package LNS_XLA_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_XLA_EVENTS" AUTHID CURRENT_USER AS
/* $Header: LNS_XLA_EVENTS_S.pls 120.2.12010000.3 2010/04/28 14:29:27 mbolli ship $ */
/*========================================================================+
|  Declare PUBLIC Data Types and Variables
+========================================================================*/

procedure create_event(p_loan_id            in  number
			,p_disb_header_id     in  number
                      ,p_loan_amount_adj_id in  number default NULL
		      ,p_loan_line_id            in number default   NULL
                      ,p_event_type_code    in  varchar
                      ,p_event_date         in  date
                      ,p_event_status       in  varchar2
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
		      ,p_bc_flag            in  varchar2
                      ,x_event_id           out nocopy number
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2);

procedure update_event(p_loan_id            in  number
		      ,p_disb_header_id     in  number
                      ,p_loan_amount_adj_id in  number default NULL
		      ,p_loan_line_id            in number default   NULL
                      ,p_event_id           in  number
                      ,p_event_type_code    in  varchar
                      ,p_event_date         in  date
                      ,p_event_status       in  varchar2
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2);

procedure delete_event(p_loan_id            in  number
		      ,p_disb_header_id     in  number
                      ,p_loan_amount_adj_id in  number default NULL
		      ,p_loan_line_id            in number default   NULL
                      ,p_event_id           in  number
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2);

end LNS_XLA_EVENTS;

/
