--------------------------------------------------------
--  DDL for Package QA_ALERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_ALERT_PKG" AUTHID CURRENT_USER AS
/* $Header: qaalrs.pls 115.2 2002/11/27 19:12:36 jezheng ship $ */


  --
  -- Create an Alert Action record.  Action ID will be generated from
  -- alr_actions_s and returned in x_action_id parameter.
  --
  -- Output variable: x_return_status will be
  --    fnd_api.g_ret_sts_success if successful
  --    fnd_api.g_ret_sts_error if error
  --
  PROCEDURE insert_alr_actions(
      p_application_id                 NUMBER,
      p_name                           VARCHAR2,
      p_alert_id                       NUMBER,
      p_action_type                    VARCHAR2,
      p_end_date_active                DATE,
      p_enabled_flag                   VARCHAR2,
      p_description                    VARCHAR2,
      p_action_level_type              VARCHAR2,
      p_date_last_executed             DATE,
      p_file_name                      VARCHAR2,
      p_argument_string                VARCHAR2,
      p_concurrent_program_id          NUMBER,
      p_program_application_id         NUMBER,
      p_list_application_id            NUMBER,
      p_list_id                        NUMBER,
      p_to_recipients                  VARCHAR2,
      p_cc_recipients                  VARCHAR2,
      p_bcc_recipients                 VARCHAR2,
      p_print_recipients               VARCHAR2,
      p_printer                        VARCHAR2,
      p_subject                        VARCHAR2,
      p_reply_to                       VARCHAR2,
      p_response_set_id                NUMBER,
      p_follow_up_after_days           NUMBER,
      p_column_wrap_flag               VARCHAR2,
      p_max_summary_message_width      NUMBER,
      p_body                           VARCHAR2,
      p_version_Number                 NUMBER,
      p_creation_date                  DATE,
      p_created_by                     NUMBER,
      p_last_update_date               DATE,
      p_last_updated_by                NUMBER,
      p_last_update_login              NUMBER,
      x_action_id                  OUT NOCOPY NUMBER,
      x_return_status              OUT NOCOPY VARCHAR2
  );

  --
  -- Update an Alert Action record.  This function can be used to
  -- update in two different modes.  When p_rowid is given, then
  -- it will be used as the update clause (used in Forms).  When
  -- it is null, then p_application_id + p_alert_id + p_name
  -- will be used as key.
  --
  -- Output variable: x_return_status will be
  --    fnd_api.g_ret_sts_success if successful
  --    fnd_api.g_ret_sts_error if record is not found
  --
  PROCEDURE update_alr_actions(
      p_rowid                          VARCHAR2,
      p_application_id                 NUMBER,
      p_action_id                      NUMBER,
      p_name                           VARCHAR2,
      p_alert_id                       NUMBER,
      p_action_type                    VARCHAR2,
      p_end_date_active                DATE,
      p_enabled_flag                   VARCHAR2,
      p_description                    VARCHAR2,
      p_action_level_type              VARCHAR2,
      p_date_last_executed             DATE,
      p_file_name                      VARCHAR2,
      p_argument_string                VARCHAR2,
      p_concurrent_program_id          NUMBER,
      p_program_application_id         NUMBER,
      p_list_application_id            NUMBER,
      p_list_id                        NUMBER,
      p_to_recipients                  VARCHAR2,
      p_cc_recipients                  VARCHAR2,
      p_bcc_recipients                 VARCHAR2,
      p_print_recipients               VARCHAR2,
      p_printer                        VARCHAR2,
      p_subject                        VARCHAR2,
      p_reply_to                       VARCHAR2,
      p_response_set_id                NUMBER,
      p_follow_up_after_days           NUMBER,
      p_column_wrap_flag               VARCHAR2,
      p_max_summary_message_width      NUMBER,
      p_body                           VARCHAR2,
      p_version_Number                 NUMBER,
      p_last_update_date               DATE,
      p_last_updated_by                NUMBER,
      p_last_update_login              NUMBER,
      x_return_status              OUT NOCOPY VARCHAR2
  );


  --
  --  Create an alr_action_sets record.
  --  Return the created action_set_id and sequence into
  --  x_action_set_id and x_sequence params.
  --
  -- Output variable: x_return_status will be
  --    fnd_api.g_ret_sts_success if successful
  --    fnd_api.g_ret_sts_error if not
  --
  PROCEDURE insert_alr_action_sets(
      p_application_id                 NUMBER,
      p_alert_id                       NUMBER,
      p_name                           VARCHAR2,
      p_end_date_active                DATE,
      p_enabled_flag                   VARCHAR2,
      p_recipients_view_only_flag      VARCHAR2,
      p_description                    VARCHAR2,
      p_suppress_flag                  VARCHAR2,
      p_suppress_days                  NUMBER,
      p_creation_date                  DATE,
      p_created_by                     NUMBER,
      p_last_update_date               DATE,
      p_last_updated_by                NUMBER,
      p_last_update_login              NUMBER,
      x_action_set_id              OUT NOCOPY NUMBER,
      x_sequence                   OUT NOCOPY NUMBER,
      x_return_status              OUT NOCOPY VARCHAR2
  );


  --
  --  Create an alr_action_set_members record.
  --  Return the created action_set_member_id and sequence into
  --  x_action_set_member_id and x_sequence params.
  --
  -- Output variable: x_return_status will be
  --    fnd_api.g_ret_sts_success if successful
  --    fnd_api.g_ret_sts_error if not
  --
  PROCEDURE insert_alr_action_set_members(
      p_application_id                 NUMBER,
      p_action_set_id                  NUMBER,
      p_action_id                      NUMBER,
      p_action_group_id                NUMBER,
      p_alert_id                       NUMBER,
      p_end_date_active                DATE,
      p_enabled_flag                   VARCHAR2,
      p_summary_threshold              VARCHAR2,
      p_abort_flag                     VARCHAR2,
      p_error_action_sequence          NUMBER,
      p_creation_date                  DATE,
      p_created_by                     NUMBER,
      p_last_update_date               DATE,
      p_last_updated_by                NUMBER,
      p_last_update_login              NUMBER,
      x_action_set_member_id       OUT NOCOPY NUMBER,
      x_sequence                   OUT NOCOPY NUMBER,
      x_return_status              OUT NOCOPY VARCHAR2
  );


  --
  --  Create an alr_action_set_outputs record.
  --
  -- Output variable: x_return_status will be
  --    fnd_api.g_ret_sts_success if successful
  --    fnd_api.g_ret_sts_error if not
  --
  PROCEDURE insert_alr_action_set_outputs(
      p_application_id                 NUMBER,
      p_action_set_id                  NUMBER,
      p_alert_id                       NUMBER,
      p_creation_date                  DATE,
      p_created_by                     NUMBER,
      p_last_update_date               DATE,
      p_last_updated_by                NUMBER,
      p_last_update_login              NUMBER,
      x_return_status              OUT NOCOPY VARCHAR2
  );


  --
  --  Create an alr_action_set_inputs record.
  --
  -- Output variable: x_return_status will be
  --    fnd_api.g_ret_sts_success if successful
  --    fnd_api.g_ret_sts_error if not
  --
  PROCEDURE insert_alr_action_set_inputs(
      p_application_id                 NUMBER,
      p_action_set_id                  NUMBER,
      p_alert_id                       NUMBER,
      p_creation_date                  DATE,
      p_created_by                     NUMBER,
      p_last_update_date               DATE,
      p_last_updated_by                NUMBER,
      p_last_update_login              NUMBER,
      x_return_status              OUT NOCOPY VARCHAR2
  );


END qa_alert_pkg;

 

/
