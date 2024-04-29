--------------------------------------------------------
--  DDL for Package Body QA_ALERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_ALERT_PKG" AS
/* $Header: qaalrb.pls 115.2 2002/11/27 19:12:21 jezheng ship $ */


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
  ) IS

  BEGIN
      INSERT INTO ALR_ACTIONS(
          application_id,
          action_id,
          name,
          alert_id,
          action_type,
          end_date_active,
          enabled_flag,
          description,
          action_level_type,
          date_last_executed,
          file_name,
          argument_string,
          concurrent_program_id,
          program_application_id,
          list_application_id,
          list_id,
          to_recipients,
          cc_recipients,
          bcc_recipients,
          print_recipients,
          printer,
          subject,
          reply_to,
          response_set_id,
          follow_up_after_days,
          column_wrap_flag,
          maximum_summary_message_width,
          body,
          version_number,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
      VALUES (
          p_application_id,
          alr_actions_s.nextval,
          p_name,
          p_alert_id,
          p_action_type,
          p_end_date_active,
          p_enabled_flag,
          p_description,
          p_action_level_type,
          p_date_last_executed,
          p_file_name,
          p_argument_string,
          p_concurrent_program_id,
          p_program_application_id,
          p_list_application_id,
          p_list_id,
          p_to_recipients,
          p_cc_recipients,
          p_bcc_recipients,
          p_print_recipients,
          p_printer,
          p_subject,
          p_reply_to,
          p_response_set_id,
          p_follow_up_after_days,
          p_column_wrap_flag,
          p_max_summary_message_width,
          p_body,
          p_version_number,
          p_creation_date,
          p_created_by,
          p_last_update_date,
          p_last_updated_by,
          p_last_update_login)
      RETURNING action_id INTO x_action_id;

      x_return_status := fnd_api.g_ret_sts_success;

      EXCEPTION WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;

  END insert_alr_actions;


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
  ) IS

  BEGIN

      IF p_rowid IS NOT NULL THEN
          --
          -- rowid is given, use it as WHERE clause to achieve best
          -- performance.
          --
          UPDATE ALR_ACTIONS
          SET
              application_id                = p_application_id,
              action_id                     = nvl(p_action_id, action_id),
              name                          = p_name,
              alert_id                      = p_alert_id,
              action_type                   = p_action_type,
              end_date_active               = p_end_date_active,
              enabled_flag                  = p_enabled_flag,
              description                   = p_description,
              action_level_type             = p_action_level_type,
              date_last_executed            = p_date_last_executed,
              file_name                     = p_file_name,
              argument_string               = p_argument_string,
              concurrent_program_id         = p_concurrent_program_id,
              program_application_id        = p_program_application_id,
              list_application_id           = p_list_application_id,
              list_id                       = p_list_id,
              to_recipients                 = p_to_recipients,
              cc_recipients                 = p_cc_recipients,
              bcc_recipients                = p_bcc_recipients,
              print_recipients              = p_print_recipients,
              printer                       = p_printer,
              subject                       = p_subject,
              reply_to                      = p_reply_to,
              response_set_id               = p_response_set_id,
              follow_up_after_days          = p_follow_up_after_days,
              column_wrap_flag              = p_column_wrap_flag,
              maximum_summary_message_width = p_max_summary_message_width,
              body                          = p_body,
              version_number                = p_version_number,
              last_update_date              = p_last_update_date,
              last_updated_by               = p_last_updated_by,
              last_update_login             = p_last_update_login
          WHERE rowid = p_rowid;

      ELSE
          --
          -- rowid is NULL, use application_id+alert_id+name as key.
          --
          -- Duplicating the SQL has better performance than to fiddle
          -- with nvl(p_rowid) in one SQL.  Better readability too.
          --
          UPDATE ALR_ACTIONS
          SET
              action_id                     = nvl(p_action_id, action_id),
              name                          = p_name,
              alert_id                      = p_alert_id,
              action_type                   = p_action_type,
              end_date_active               = p_end_date_active,
              enabled_flag                  = p_enabled_flag,
              description                   = p_description,
              action_level_type             = p_action_level_type,
              date_last_executed            = p_date_last_executed,
              file_name                     = p_file_name,
              argument_string               = p_argument_string,
              concurrent_program_id         = p_concurrent_program_id,
              program_application_id        = p_program_application_id,
              list_application_id           = p_list_application_id,
              list_id                       = p_list_id,
              to_recipients                 = p_to_recipients,
              cc_recipients                 = p_cc_recipients,
              bcc_recipients                = p_bcc_recipients,
              print_recipients              = p_print_recipients,
              printer                       = p_printer,
              subject                       = p_subject,
              reply_to                      = p_reply_to,
              response_set_id               = p_response_set_id,
              follow_up_after_days          = p_follow_up_after_days,
              column_wrap_flag              = p_column_wrap_flag,
              maximum_summary_message_width = p_max_summary_message_width,
              body                          = p_body,
              version_number                = p_version_number,
              last_update_date              = p_last_update_date,
              last_updated_by               = p_last_updated_by,
              last_update_login             = p_last_update_login
          WHERE
              application_id = p_application_id AND
              alert_id = p_alert_id AND
              name = p_name;

      END IF; -- p_rowid

      IF (sql%notfound) THEN
          x_return_status := fnd_api.g_ret_sts_error;
      ELSE
          x_return_status := fnd_api.g_ret_sts_success;
      END IF;

  END update_alr_actions;


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
  ) IS

      l_sequence NUMBER;

  BEGIN
      SELECT nvl(max(sequence),0)+1
      INTO   l_sequence
      FROM   alr_action_sets
      WHERE  application_id = p_application_id AND
             alert_id = p_alert_id;

      INSERT INTO alr_action_sets (
          action_set_id,
          application_id,
          name,
          alert_id,
          end_date_active,
          enabled_flag,
          recipients_view_only_flag,
          description,
          suppress_flag,
          suppress_days,
          sequence,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
      VALUES (
          alr_action_sets_s.nextval,
          p_application_id,
          p_name,
          p_alert_id,
          p_end_date_active,
          p_enabled_flag,
          p_recipients_view_only_flag,
          p_description,
          p_suppress_flag,
          p_suppress_days,
          l_sequence,
          p_creation_date,
          p_created_by,
          p_last_update_date,
          p_last_updated_by,
          p_last_update_login)
      RETURNING action_set_id INTO x_action_set_id;

      x_sequence := l_sequence;
      x_return_status := fnd_api.g_ret_sts_success;

      EXCEPTION WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;

  END insert_alr_action_sets;




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
  ) IS
      l_sequence NUMBER;

  BEGIN
      SELECT nvl(max(sequence),0) + 1
      INTO   l_sequence
      FROM   alr_action_set_members
      WHERE  application_id = 250 AND
             alert_id = 10177 AND
             action_set_id = p_action_set_id;

      INSERT INTO alr_action_set_members (
          action_set_member_id,
          application_id,
          action_set_id,
          action_id,
          action_group_id,
          alert_id,
          sequence,
          end_date_active,
          enabled_flag,
          summary_threshold,
          abort_flag,
          error_action_sequence,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
      VALUES (
          alr_action_set_members_s.nextval,
          p_application_id,
          p_action_set_id,
          p_action_id,
          p_action_group_id,
          p_alert_id,
          l_sequence,
          p_end_date_active,
          p_enabled_flag,
          p_summary_threshold,
          p_abort_flag,
          p_error_action_sequence,
          p_creation_date,
          p_created_by,
          p_last_update_date,
          p_last_updated_by,
          p_last_update_login)
      RETURNING action_set_member_id INTO x_action_set_member_id;

      x_sequence := l_sequence;
      x_return_status := fnd_api.g_ret_sts_success;

      EXCEPTION WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;

  END insert_alr_action_set_members;




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
  ) IS

  BEGIN
      INSERT INTO alr_action_set_outputs(
          application_id,
          action_set_id,
          alert_id,
          name,
          sequence,
          suppress_flag,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
      SELECT
          p_application_id,
          p_action_set_id,
          p_alert_id,
          a.name,
          a.sequence,
          a.default_suppress_flag,
          p_creation_date,
          p_created_by,
          p_last_update_date,
          p_last_updated_by,
          p_last_update_login
      FROM  alr_alert_outputs a
      WHERE a.application_id = p_application_id AND
            a.alert_id = p_alert_id AND
            a.enabled_flag = 'Y';

      x_return_status := fnd_api.g_ret_sts_success;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          -- allow no data found
          x_return_status := fnd_api.g_ret_sts_success;

      WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;

  END insert_alr_action_set_outputs;


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
  ) IS

  BEGIN
      INSERT INTO alr_action_set_inputs(
          application_id,
          action_set_id,
          alert_id,
          name,
          value,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
      SELECT
          p_application_id,
          p_action_set_id,
          p_alert_id,
          a.name,
          a.default_value,
          p_creation_date,
          p_created_by,
          p_last_update_date,
          p_last_updated_by,
          p_last_update_login
      FROM  alr_alert_inputs a
      WHERE a.application_id = p_application_id AND
            a.alert_id = p_alert_id AND
            a.enabled_flag = 'Y';

      x_return_status := fnd_api.g_ret_sts_success;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          -- allow no data found
          x_return_status := fnd_api.g_ret_sts_success;

      WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;

  END insert_alr_action_set_inputs;
















END qa_alert_pkg;

/
