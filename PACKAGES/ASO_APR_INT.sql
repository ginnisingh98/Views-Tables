--------------------------------------------------------
--  DDL for Package ASO_APR_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_INT" AUTHID CURRENT_USER AS
  /*  $Header: asoiaprs.pls 120.2 2005/11/03 16:01:46 skulkarn ship $ */
  version              CONSTANT NUMBER := 1.0;

  PROCEDURE get_all_approvers (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_clear_transaction_flag    IN       VARCHAR2 DEFAULT fnd_api.g_true,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_approvers_list            OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.approvers_list_tbl_type,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.rules_list_tbl_type
  );

  PROCEDURE start_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_approver_sequence         IN       NUMBER DEFAULT fnd_api.g_miss_num,
    p_requester_comments        IN       VARCHAR2,
    x_object_approval_id        OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_approval_instance_id      OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );

  PROCEDURE cancel_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_object_approval_id        IN       NUMBER,
    p_user_id                   IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );
  -- The following procedure may not be implemented

  PROCEDURE skip_approver (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_approver_id               IN       NUMBER,
    p_approval_instance_id      IN       NUMBER,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );

  FUNCTION get_approver_name (
    p_user_id                            NUMBER,
    p_person_id                          NUMBER
  )
    RETURN VARCHAR2;

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
    P_Object_approval_id        IN       NUMBER,
    P_itemtype                  IN       VARCHAR2,
    P_sender_name               IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
  );

  PROCEDURE upd_status_self_appr
  ( p_qte_hdr_id                IN             NUMBER,
    p_obj_ver_num               IN             NUMBER,
    p_last_update_date          IN             DATE,
    x_obj_ver_num               OUT NOCOPY     NUMBER,
    x_last_update_date          OUT NOCOPY     DATE,
    x_return_status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
  );



END aso_apr_int;

 

/
