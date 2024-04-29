--------------------------------------------------------
--  DDL for Package CSI_II_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_II_RELATIONSHIPS_PKG" AUTHID CURRENT_USER AS
/* $Header: csitiirs.pls 115.13 2003/09/04 00:19:07 sguthiva ship $ */
-- start of comments
-- package name     : csi_ii_relationships_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments

PROCEDURE insert_row(
          px_relationship_id   IN OUT NOCOPY   NUMBER,
          p_relationship_type_code      VARCHAR2,
          p_object_id                   NUMBER,
          p_subject_id                  NUMBER,
          p_position_reference          VARCHAR2,
          p_active_start_date           DATE,
          p_active_end_date             DATE,
          p_display_order               NUMBER,
          p_mandatory_flag              VARCHAR2,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER);

PROCEDURE update_row(
          p_relationship_id             NUMBER,
          p_relationship_type_code      VARCHAR2,
          p_object_id                   NUMBER,
          p_subject_id                  NUMBER,
          p_position_reference          VARCHAR2,
          p_active_start_date           DATE,
          p_active_end_date             DATE,
          p_display_order               NUMBER,
          p_mandatory_flag              VARCHAR2,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER);

PROCEDURE lock_row(
          p_relationship_id             NUMBER,
          p_relationship_type_code      VARCHAR2,
          p_object_id                   NUMBER,
          p_subject_id                  NUMBER,
          p_position_reference          VARCHAR2,
          p_active_start_date           DATE,
          p_active_end_date             DATE,
          p_display_order               NUMBER,
          p_mANDatory_flag              VARCHAR2,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER);

PROCEDURE delete_row(
          p_relationship_id             NUMBER);
END csi_ii_relationships_pkg;

 

/
