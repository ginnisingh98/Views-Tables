--------------------------------------------------------
--  DDL for Package ASO_APR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_PUB" AUTHID CURRENT_USER AS
  /*  $Header: asopaprs.pls 120.1 2005/06/29 12:36:26 appldev ship $ */
  version              CONSTANT NUMBER := 1.0;

  TYPE approval_instance_rec_type IS RECORD (
    object_approval_id            NUMBER,
    approval_instance_id          NUMBER,
    object_id                     NUMBER,
    object_type                   VARCHAR2 (30),
    approval_status               VARCHAR2 (30),
    requester_name                VARCHAR2 (240),
    requester_userid              NUMBER,
    requester_comments            VARCHAR2 (2000),
    start_date                    DATE,
    end_date                      DATE
  );

  TYPE approval_instance_tbl_type IS TABLE OF approval_instance_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE approvers_list_rec_type IS RECORD (
    approval_det_id               NUMBER,
    object_approval_id            NUMBER,
    approver_person_id            NUMBER,
    approver_user_id              NUMBER,
    notification_id               NUMBER,
    approver_sequence             NUMBER,
    approver_status               VARCHAR2 (30),
    approver_name                 VARCHAR2 (240),
    approval_comments             VARCHAR2 (240),
    date_sent                     DATE,
    date_recieved                 DATE
  );

  TYPE approvers_list_tbl_type IS TABLE OF approvers_list_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE rules_list_rec_type IS RECORD (
    rule_id                       NUMBER,
    object_approval_id            NUMBER,
    rule_action_id                NUMBER,
    rule_description              VARCHAR2 (240),
    approval_level                VARCHAR2 (240)
  );

  TYPE rules_list_tbl_type IS TABLE OF rules_list_rec_type
    INDEX BY BINARY_INTEGER;

  PROCEDURE get_all_approvers (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_approvers_list            OUT NOCOPY /* file.sql.39 change */       approvers_list_tbl_type,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       rules_list_tbl_type
  );

  PROCEDURE start_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_approver_sequence         IN       NUMBER := fnd_api.g_miss_num,
    p_requester_comments        IN       VARCHAR2,
    x_object_approval_id        OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_approval_instance_id      OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE cancel_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2,
    p_commit                    IN       VARCHAR2,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_object_approval_id        IN       NUMBER,
    p_user_id                   IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  -- The following procedure may not be implemented

  PROCEDURE skip_approver (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_approver_id               IN       NUMBER,
    p_approval_instance_id      IN       NUMBER,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  );

  PROCEDURE get_rule_details (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_approval_id        IN       NUMBER,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.rules_list_tbl_type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2);

  PROCEDURE start_approval_workflow (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_approval_id        IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_sender_name               IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2);


END aso_apr_pub;

 

/
