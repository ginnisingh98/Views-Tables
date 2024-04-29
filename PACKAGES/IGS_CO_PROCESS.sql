--------------------------------------------------------
--  DDL for Package IGS_CO_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGSCO22S.pls 120.3 2005/09/28 05:43:24 appldev ship $ */
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This package will consist of procedures that will perform validation
            and processing of correspondence related information and data.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  mnade           6/1/2005        FA 157 Added p_award_prd_cd parameter to corp_post_process
  pradhakr        13-Aug-2002     Added the parameter p_destination, in the procedure corp_submit_fulfil_request,
                                  which takes the destination name (i.e) printer name if the media type
                                  selected is printer. Changes as part of bug# 2472250
  gmaheswa        15-Nov-2003     Bug : 3006800 Added New parameter p_fax_number in corp_submit_fulfil_request.
  ssawhney        3-may-04        IBC.C patchset changes bug 3565861 + 3442719 + signature of corp_get_letter_type changed
  ssaleem         09-SEP-2004   3630073. Added p_org_unit_id as a new parameter
  pacross         11-SEP-2005   Added p_preview parameter for Correspondance preview and edit
  (reverse chronological order - newest change first)
  ***************************************************************/
  --
  --  This procedure will accept document id as a parameter and
  --  return system letter code for the document.
  --
  PROCEDURE corp_get_letter_type(
    p_map_id            IN       NUMBER,
    p_document_id       OUT NOCOPY      NUMBER,
    p_sys_ltr_code      OUT NOCOPY      VARCHAR2,
    p_letter_type       OUT NOCOPY      VARCHAR2,
    p_version_id        OUT NOCOPY      NUMBER
  );
  --
  --Based on the selection type this procedure will build and return a select statement.
  --
  PROCEDURE corp_build_sql_stmt(
    p_document_id       IN       NUMBER,
    p_sys_ltr_code      IN       VARCHAR2, -- ADDED NEW**
    p_select_type       IN       VARCHAR2,
    p_list_id           IN       NUMBER,
    p_person_id         IN       NUMBER,
    p_letter_type       IN       VARCHAR2,
    p_parameter_1       IN       VARCHAR2,
    p_parameter_2       IN       VARCHAR2,
    p_parameter_3       IN       VARCHAR2,
    p_parameter_4       IN       VARCHAR2,
    p_parameter_5       IN       VARCHAR2,
    p_parameter_6       IN       VARCHAR2,
    p_parameter_7       IN       VARCHAR2,
    p_parameter_8       IN       VARCHAR2,
    p_parameter_9       IN       VARCHAR2,
    p_sql_stmt          OUT NOCOPY      VARCHAR2,
    p_exception         OUT NOCOPY      VARCHAR2
  );
  --
  --This procedure will check and return attributes assigned to a document.
  --
  PROCEDURE corp_check_document_attributes(
    p_map_id            IN       NUMBER,
    p_elapsed_days      OUT NOCOPY      NUMBER,
    p_no_of_repeats     OUT NOCOPY      NUMBER
  );
  --
  --  This procedure will check interaction history and return a value to
  --  inform whether a document can be sent or not.
  --
  PROCEDURE corp_check_interaction_history(
    p_person_id         IN       NUMBER,
    p_sys_ltr_code      IN       VARCHAR2,
    p_document_id       IN       NUMBER,
    p_application_id    IN       NUMBER       DEFAULT NULL,
    p_course_cd         IN       VARCHAR2     DEFAULT NULL,
    p_adm_seq_no        IN       NUMBER       DEFAULT NULL,
    p_awd_cal_type      IN       VARCHAR2     DEFAULT NULL,
    p_awd_seq_no        IN       NUMBER       DEFAULT NULL,
    p_elapsed_days      IN       NUMBER,
    p_no_of_repeats     IN       NUMBER,
    p_send_letter       OUT NOCOPY      VARCHAR2
  );
  --
  --  This procedure will accept parameters and submit fulfilment requests.
  --
  PROCEDURE corp_submit_fulfil_request(
    p_letter_type       IN       VARCHAR2,
    p_person_id         IN       NUMBER,
    p_email_address     IN       VARCHAR2,
    p_content_id        IN       NUMBER,
    p_award_year        IN       VARCHAR2,  --New
    p_sys_ltr_code      IN       VARCHAR2,  --New
    p_adm_appl_number   IN       NUMBER,    --New
    p_nominated_course_cd IN     VARCHAR2,  --New
    p_appl_sequence_number IN    NUMBER,    --New
    p_fulfillment_req   IN       VARCHAR2,
    p_crm_user_id       IN       NUMBER,
    p_media_type        IN       VARCHAR2,
    p_destination       IN       VARCHAR2,  --  Added the parameter p_destination as part of bug# 2472250
    p_fax_number        IN       VARCHAR2 DEFAULT NULL,
    p_reply_days        IN       VARCHAR2 DEFAULT NULL,
    p_panel_code        IN       VARCHAR2 DEFAULT NULL,
    p_request_id        OUT NOCOPY      NUMBER,
    p_request_status    OUT NOCOPY      VARCHAR2,
    p_reply_email       IN  VARCHAR2  DEFAULT NULL,
    p_sender_email      IN  VARCHAR2  DEFAULT NULL,
    p_cc_email          IN  VARCHAR2  DEFAULT NULL,
    p_org_unit_id       IN  NUMBER    DEFAULT NULL,
    p_preview           IN  VARCHAR2  DEFAULT NULL,
    p_awd_cal_type        IN       VARCHAR2,
    p_awd_ci_seq_number   IN       NUMBER,
    p_awd_prd_cd          IN       VARCHAR2,
    p_preview_version_id  IN       NUMBER DEFAULT NULL,
    p_preview_version     IN       NUMBER DEFAULT NULL
  );
  --
  --  This procedure will perform post-processing.
  --
  PROCEDURE corp_post_process(
    p_person_id              IN       NUMBER,
    p_request_id             IN       NUMBER,
    p_document_id            IN       NUMBER,
    p_sys_ltr_code           IN       VARCHAR2,
    p_document_type          IN       VARCHAR2,
    p_adm_appl_number        IN       NUMBER,
    p_nominated_course_cd    IN       VARCHAR2,
    p_appl_seq_number        IN       NUMBER,
    p_awd_cal_type           IN       VARCHAR2,
    p_awd_ci_seq_number      IN       NUMBER,
    p_award_year             IN       VARCHAR2,
    p_delivery_type          IN       VARCHAR2,
    p_version_id             IN       NUMBER,   -- ssawhney
    p_award_prd_cd           IN       VARCHAR2  -- mnade fa 157
  );
  --
  --  This procedure returns the view name for the system letter code.
  --
  PROCEDURE corp_get_system_letter_view(
    p_sys_ltr_code      IN       VARCHAR2,
    p_view_name         OUT NOCOPY      VARCHAR2,
    p_where_clause      OUT NOCOPY      VARCHAR2
  );
  --
  --  This procedure accepts 5 parameters and builds a where
  --  clause for student selection.
  --
  PROCEDURE corp_get_parameter_value(
    p_sys_ltr_code     IN       VARCHAR2,
    p_parameter_1      IN       VARCHAR2,
    p_parameter_2      IN       VARCHAR2,
    p_parameter_3      IN       VARCHAR2,
    p_parameter_4      IN       VARCHAR2,
    p_parameter_5      IN       VARCHAR2,
    p_parameter_6      IN       VARCHAR2,
    p_parameter_7      IN       VARCHAR2,
    p_parameter_8      IN       VARCHAR2,
    p_parameter_9      IN       VARCHAR2,
    p_parameter_value  OUT NOCOPY      VARCHAR2
  );
  --
  --  This procedure will check the request status in OSS Interaction Table
  --  against CRM Interaction History and update the OSS Interaction table.
  --
  PROCEDURE corp_check_request_status(
    errbuf              OUT NOCOPY      VARCHAR2,
    retcode             OUT NOCOPY      NUMBER,
    p_person_id         IN       NUMBER       DEFAULT NULL,
    p_document_id       IN       NUMBER       DEFAULT NULL,
    p_application_id    IN       NUMBER       DEFAULT NULL,
    p_course_cd         IN       VARCHAR2     DEFAULT NULL,
    p_adm_seq_no        IN       NUMBER       DEFAULT NULL,
    p_awd_cal_type      IN       VARCHAR2     DEFAULT NULL,
    p_awd_seq_no        IN       NUMBER       DEFAULT NULL,
    p_elapsed_days      IN       NUMBER       DEFAULT NULL,
    p_no_of_repeats     IN       NUMBER       DEFAULT NULL,
    p_sys_ltr_code      IN       VARCHAR2       DEFAULT NULL
  );
  --
  --  This procedure will return true or false based on the validation.
  --
  PROCEDURE corp_validate_parameters(
    p_sys_ltr_code      IN       VARCHAR2,
    p_document_id       IN       NUMBER,
    p_select_type       IN       VARCHAR2,
    p_list_id           IN       NUMBER         DEFAULT NULL,
    p_person_id         IN       NUMBER         DEFAULT NULL,
    p_parameter_1       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_2       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_3       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_4       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_5       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_6       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_7       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_8       IN       VARCHAR2       DEFAULT NULL,
    p_parameter_9       IN       VARCHAR2       DEFAULT NULL,
    p_override_flag     IN       VARCHAR2,
    p_delivery_type     IN       VARCHAR2,
    p_exception         OUT NOCOPY      VARCHAR2
  );
  --
  --  This is a package variable to identify whether the corp_submit_fulfil_request.
  --  process was unsuccessfull and abort the call to corp_post_process.
  --
    l_corp_submit_fulfil_request BOOLEAN DEFAULT FALSE;
  --
  --  This is a package variable to identify whether the message which is the header
  --  has been printed in the log file. To avoid re-printing of the header.
  --
   l_message_logged BOOLEAN DEFAULT FALSE;

END igs_co_process;

 

/
