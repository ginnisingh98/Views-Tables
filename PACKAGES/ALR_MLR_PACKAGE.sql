--------------------------------------------------------
--  DDL for Package ALR_MLR_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ALR_MLR_PACKAGE" AUTHID CURRENT_USER as
/* $Header: alrwfmlrs.pls 120.0 2006/08/02 22:09:28 jwsmith noship $ */

ALR_EMAIL_TABLE WF_MAIL.wf_recipient_list_t;

type ALR_MSG_DTLS_REC is record
(
app_id    number,
alert_id  number,
response_set_id number,
open_closed varchar2(1)
);

TYPE alr_msg_dtls_tbl_type is table of ALR_MSG_DTLS_REC
index by binary_integer;

type ALR_INIT_RESP_REC is record
(
var_num number,
name varchar2(30),
data_type varchar2(1),
default_value varchar2(240),
max_len number
);

TYPE alr_init_resp_tbl_type is table of ALR_INIT_RESP_REC
index by binary_integer;

type ALR_INIT_VALID_RESP_REC is record
(
resp_id number,
resp_type varchar2(1),
resp_text long,
resp_name varchar2(240)
);

TYPE alr_init_valid_resp_tbl_type is table of ALR_INIT_VALID_RESP_REC
index by binary_integer;

type ALR_GET_RESP_ACT_REC is record
(
   response_id number,
   action_id number,
   action_name varchar2(80),
   action_type varchar2(1),
   action_body varchar2(2000),
   conc_pgm_id number,
   to_recip varchar2(240),
   cc_recip varchar2(240),
   bcc_recip varchar2(240),
   print_recip varchar2(240),
   printer varchar2(30),
   subject varchar2(240),
   reply_to varchar2(240),
   column_wrap_flag varchar2(1),
   max_sum_msg_width number,
   action_level_type varchar2(1),
   action_level varchar2(1),
   file_name varchar2(240),
   arg_string varchar2(240),
   pgm_app_id number,
   list_app_id number,
   act_resp_set_id number,
   follow_up_after_days number,
   version_num number
);

TYPE alr_get_resp_act_tbl_type is table of ALR_GET_RESP_ACT_REC
index by binary_integer;

TYPE alr_match_resp_act_tbl_type is table of ALR_GET_RESP_ACT_REC
index by binary_integer;

TYPE ALR_RESP_VAR_VALUES_REC is record
(
   variable_name varchar2(30),
   value varchar2(240),
   data_type varchar2(1),
   detail_max_len number
);
TYPE alr_resp_var_values_tbl_type is table of ALR_RESP_VAR_VALUES_REC
index by binary_integer;

--
-- Generic mailer routines
--
-- Send
--   Sends a e-mail notification to the specified list of recipients.
--   This API unlike wf_notification.send does not require workflow
--   message or workflow roles to send a notification.

procedure Send(a_idstring       in varchar2,
               a_module         in varchar2,
               a_replyto        in varchar2 default null,
               a_subject        in varchar2,
               a_message        in varchar2);

procedure Send2(a_idstring       in varchar2,
               a_module         in varchar2,
               a_replyto        in varchar2 default null,
               a_subject        in varchar2,
               a_chunk1         in varchar2,
               a_chunk2         in varchar2);

procedure InitRecipientList;

procedure AddRecipientToList(p_name  in varchar2,
                             p_value in varchar2,
                             p_recipient_type in varchar2);

function Response(p_subscription_guid in raw,
                  p_event in out NOCOPY WF_EVENT_T) return varchar2;

function OpenResponses return number;

procedure GetMessageDetails(msg_handle in number,
                            node_handle in number,
                            alr_msg_dtls_tbl out NOCOPY alr_msg_dtls_tbl_type);

procedure InitResponseVar(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                       alr_init_resp_tbl out NOCOPY alr_init_resp_tbl_type);

procedure InitValidResponses(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                             alr_init_valid_resp_tbl out NOCOPY
                             alr_init_valid_resp_tbl_type);

procedure GetRespActions(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                             alr_init_valid_resp_tbl in
                             alr_init_valid_resp_tbl_type,
                             alr_get_resp_act_tbl out NOCOPY
                             alr_get_resp_act_tbl_type);

procedure GetOutputValues(msg_handle in number, node_handle in number,
                          alr_resp_var_values_tbl out NOCOPY
                          alr_resp_var_values_tbl_type);

procedure SaveRespHistory(msg_handle in number,
                          node_handle in number,
                          alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                          l_from in varchar2,
                          p_response_body in varchar2,
                          p_resp_id in number);

procedure SaveRespVar(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                      msg_handle in number,
                      node_handle in number,
                      alr_init_resp_tbl in
                      alr_init_resp_tbl_type);

procedure SaveOneRespVar(alr_msg_dtls_tbl in alr_msg_dtls_tbl_type,
                      msg_handle in number,
                      node_handle in number,
                      variable_name in varchar2,
                      value in varchar2,
                      alr_init_resp_tbl in
                      alr_init_resp_tbl_type);

procedure SaveRespActHistory(msg_handle in number,
                             node_handle in number,
                             response_msg_id in number,
                             oracle_id in number,
                             seq in number,
                             alr_msg_dtls_tbl in
                               alr_msg_dtls_tbl_type,
                             alr_get_resp_act_tbl in
                               alr_get_resp_act_tbl_type,
                             version_num in number,
                             success_flag in varchar2);

procedure CloseResp(msg_handle in number,
                    node_handle in number,
                    alr_init_valid_resp_tbl in
                        alr_init_valid_resp_tbl_type,
                    open_closed in varchar2,
                    action_set_pass_fail in varchar2);

procedure test;

end ALR_MLR_PACKAGE;

 

/
