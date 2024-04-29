--------------------------------------------------------
--  DDL for Package ASO_APR_APPROVALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_APPROVALS_PKG" AUTHID CURRENT_USER AS
  /*  $Header: asotapps.pls 120.1 2005/06/29 12:38:38 appldev ship $ */
  -- Start of Comments
  -- Package name     : ASO_APR_APPROVALS_PKG
  -- Purpose          :
  -- History          :
  -- NOTE             :
  -- End of Comments

  PROCEDURE header_insert_row (
    px_object_approval_id       IN OUT NOCOPY /* file.sql.39 change */    NUMBER,
    p_object_id                          NUMBER,
    p_object_type                        VARCHAR2,
    p_approval_instance_id               NUMBER,
    p_approval_status                    VARCHAR2,
    p_application_id                     NUMBER,
    p_start_date                         DATE,
    p_end_date                           DATE,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER,
    p_requester_userid                   NUMBER,
    p_requester_comments                 VARCHAR2,
    p_requester_group_id                 NUMBER
  );

  PROCEDURE header_update_row (
    p_object_approval_id                 NUMBER,
    p_object_id                          NUMBER,
    p_object_type                        VARCHAR2,
    p_approval_instance_id               NUMBER,
    p_approval_status                    VARCHAR2,
    p_application_id                     NUMBER,
    p_start_date                         DATE,
    p_end_date                           DATE,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER,
    p_requester_userid                   NUMBER,
    p_requester_comments                 VARCHAR2,
    p_requester_group_id                 NUMBER
  );

  PROCEDURE header_lock_row (
    p_object_approval_id                 NUMBER,
    p_object_id                          NUMBER,
    p_object_type                        VARCHAR2,
    p_approval_instance_id               NUMBER,
    p_approval_status                    VARCHAR2,
    p_application_id                     NUMBER,
    p_start_date                         DATE,
    p_end_date                           DATE,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER,
    p_requester_userid                   NUMBER,
    p_requester_comments                 VARCHAR2,
    p_requester_group_id                 NUMBER
  );

  PROCEDURE header_delete_row (
    p_object_approval_id                 NUMBER
  );
  --- Procedures for the detail table

  PROCEDURE detail_insert_row (
    px_approval_det_id          IN OUT NOCOPY /* file.sql.39 change */     NUMBER,
    p_object_approval_id                 NUMBER,
    p_approver_person_id                 NUMBER,
    p_approver_user_id                   NUMBER,
    p_approver_sequence                  NUMBER,
    p_approver_status                    VARCHAR2,
    p_approver_comments                  VARCHAR2,
    p_date_sent                          DATE,
    p_date_received                      DATE,
    p_creation_date                      DATE,
    p_last_update_date                   DATE,
    p_created_by                         NUMBER,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  );

  PROCEDURE detail_update_row (
    p_approval_det_id                    NUMBER,
    p_object_approval_id                 NUMBER,
    p_approver_person_id                 NUMBER,
    p_approver_user_id                   NUMBER,
    p_approver_sequence                  NUMBER,
    p_approver_status                    VARCHAR2,
    p_approver_comments                  VARCHAR2,
    p_date_sent                          DATE,
    p_date_received                      DATE,
    p_creation_date                      DATE,
    p_last_update_date                   DATE,
    p_created_by                         NUMBER,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  );

  PROCEDURE detail_lock_row (
    p_approval_det_id                    NUMBER,
    p_object_approval_id                 NUMBER,
    p_approver_person_id                 NUMBER,
    p_approver_user_id                   NUMBER,
    p_approver_sequence                  NUMBER,
    p_approver_status                    VARCHAR2,
    p_approver_comments                  VARCHAR2,
    p_date_sent                          DATE,
    p_date_received                      DATE,
    p_creation_date                      DATE,
    p_last_update_date                   DATE,
    p_created_by                         NUMBER,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  );

  PROCEDURE detail_delete_row (
    p_approval_det_id                    NUMBER
  );
  -- Proedures for the Rule Table

  PROCEDURE rule_insert_row (
    px_rule_id                  IN OUT NOCOPY /* file.sql.39 change */     NUMBER,
    p_oam_rule_id                        NUMBER,
    p_rule_action_id                     NUMBER,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_object_approval_id                 NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  );

  PROCEDURE rule_update_row (
    p_rule_id                            NUMBER,
    p_oam_rule_id                        NUMBER,
    p_rule_action_id                     NUMBER,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_object_approval_id                 NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_attribute16                        VARCHAR2,
    p_attribute17                        VARCHAR2,
    p_attribute18                        VARCHAR2,
    p_attribute19                        VARCHAR2,
    p_attribute20                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  );

  PROCEDURE rule_lock_row (
    p_rule_id                            NUMBER,
    p_oam_rule_id                        NUMBER,
    p_rule_action_id                     NUMBER,
    p_creation_date                      DATE,
    p_created_by                         NUMBER,
    p_last_update_date                   DATE,
    p_last_updated_by                    NUMBER,
    p_last_update_login                  NUMBER,
    p_object_approval_id                 NUMBER,
    p_attribute1                         VARCHAR2,
    p_attribute2                         VARCHAR2,
    p_attribute3                         VARCHAR2,
    p_attribute4                         VARCHAR2,
    p_attribute5                         VARCHAR2,
    p_attribute6                         VARCHAR2,
    p_attribute7                         VARCHAR2,
    p_attribute8                         VARCHAR2,
    p_attribute9                         VARCHAR2,
    p_attribute10                        VARCHAR2,
    p_attribute11                        VARCHAR2,
    p_attribute12                        VARCHAR2,
    p_attribute13                        VARCHAR2,
    p_attribute14                        VARCHAR2,
    p_attribute15                        VARCHAR2,
    p_context                            VARCHAR2,
    p_security_group_id                  NUMBER,
    p_object_version_number              NUMBER
  );

  PROCEDURE rule_delete_row (
    p_rule_id                            NUMBER
  );
END aso_apr_approvals_pkg;

 

/
