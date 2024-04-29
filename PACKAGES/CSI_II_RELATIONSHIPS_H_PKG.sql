--------------------------------------------------------
--  DDL for Package CSI_II_RELATIONSHIPS_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_II_RELATIONSHIPS_H_PKG" AUTHID CURRENT_USER AS
/* $Header: csitirhs.pls 115.12 2003/09/04 00:20:45 sguthiva ship $ */
-- start of comments
-- package name     : csi_ii_relationships_h_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments
PROCEDURE insert_row(
          px_relationship_history_id   IN OUT NOCOPY NUMBER  ,
          p_relationship_id                   NUMBER  ,
          p_transaction_id                    NUMBER  ,
          p_old_subject_id                    NUMBER  ,
          p_new_subject_id                    NUMBER  ,
          p_old_position_reference            VARCHAR2,
          p_new_position_reference            VARCHAR2,
          p_old_active_start_date             DATE    ,
          p_new_active_start_date             DATE    ,
          p_old_active_end_date               DATE    ,
          p_new_active_end_date               DATE    ,
          p_old_mandatory_flag                VARCHAR2,
          p_new_mandatory_flag                VARCHAR2,
          p_old_context                       VARCHAR2,
          p_new_context                       VARCHAR2,
          p_old_attribute1                    VARCHAR2,
          p_new_attribute1                    VARCHAR2,
          p_old_attribute2                    VARCHAR2,
          p_new_attribute2                    VARCHAR2,
          p_old_attribute3                    VARCHAR2,
          p_new_attribute3                    VARCHAR2,
          p_old_attribute4                    VARCHAR2,
          p_new_attribute4                    VARCHAR2,
          p_old_attribute5                    VARCHAR2,
          p_new_attribute5                    VARCHAR2,
          p_old_attribute6                    VARCHAR2,
          p_new_attribute6                    VARCHAR2,
          p_old_attribute7                    VARCHAR2,
          p_new_attribute7                    VARCHAR2,
          p_old_attribute8                    VARCHAR2,
          p_new_attribute8                    VARCHAR2,
          p_old_attribute9                    VARCHAR2,
          p_new_attribute9                    VARCHAR2,
          p_old_attribute10                   VARCHAR2,
          p_new_attribute10                   VARCHAR2,
          p_old_attribute11                   VARCHAR2,
          p_new_attribute11                   VARCHAR2,
          p_old_attribute12                   VARCHAR2,
          p_new_attribute12                   VARCHAR2,
          p_old_attribute13                   VARCHAR2,
          p_new_attribute13                   VARCHAR2,
          p_old_attribute14                   VARCHAR2,
          p_new_attribute14                   VARCHAR2,
          p_old_attribute15                   VARCHAR2,
          p_new_attribute15                   VARCHAR2,
          p_full_dump_flag                    VARCHAR2,
          p_created_by                        NUMBER  ,
          p_creation_date                     DATE    ,
          p_last_updated_by                   NUMBER  ,
          p_last_update_date                  DATE    ,
          p_last_update_login                 NUMBER  ,
          p_object_version_number             NUMBER  );

PROCEDURE update_row(
          p_relationship_history_id           NUMBER  ,
          p_relationship_id                   NUMBER  ,
          p_transaction_id                    NUMBER  ,
          p_old_subject_id                    NUMBER  ,
          p_new_subject_id                    NUMBER  ,
          p_old_position_reference            VARCHAR2,
          p_new_position_reference            VARCHAR2,
          p_old_active_start_date             DATE    ,
          p_new_active_start_date             DATE    ,
          p_old_active_end_date               DATE    ,
          p_new_active_end_date               DATE    ,
          p_old_mandatory_flag                VARCHAR2,
          p_new_mandatory_flag                VARCHAR2,
          p_old_context                       VARCHAR2,
          p_new_context                       VARCHAR2,
          p_old_attribute1                    VARCHAR2,
          p_new_attribute1                    VARCHAR2,
          p_old_attribute2                    VARCHAR2,
          p_new_attribute2                    VARCHAR2,
          p_old_attribute3                    VARCHAR2,
          p_new_attribute3                    VARCHAR2,
          p_old_attribute4                    VARCHAR2,
          p_new_attribute4                    VARCHAR2,
          p_old_attribute5                    VARCHAR2,
          p_new_attribute5                    VARCHAR2,
          p_old_attribute6                    VARCHAR2,
          p_new_attribute6                    VARCHAR2,
          p_old_attribute7                    VARCHAR2,
          p_new_attribute7                    VARCHAR2,
          p_old_attribute8                    VARCHAR2,
          p_new_attribute8                    VARCHAR2,
          p_old_attribute9                    VARCHAR2,
          p_new_attribute9                    VARCHAR2,
          p_old_attribute10                   VARCHAR2,
          p_new_attribute10                   VARCHAR2,
          p_old_attribute11                   VARCHAR2,
          p_new_attribute11                   VARCHAR2,
          p_old_attribute12                   VARCHAR2,
          p_new_attribute12                   VARCHAR2,
          p_old_attribute13                   VARCHAR2,
          p_new_attribute13                   VARCHAR2,
          p_old_attribute14                   VARCHAR2,
          p_new_attribute14                   VARCHAR2,
          p_old_attribute15                   VARCHAR2,
          p_new_attribute15                   VARCHAR2,
          p_full_dump_flag                    VARCHAR2,
          p_created_by                        NUMBER  ,
          p_creation_date                     DATE    ,
          p_last_updated_by                   NUMBER  ,
          p_last_update_date                  DATE    ,
          p_last_update_login                 NUMBER  ,
          p_object_version_number             NUMBER  );



END csi_ii_relationships_h_pkg;

 

/
