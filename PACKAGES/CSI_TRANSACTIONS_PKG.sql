--------------------------------------------------------
--  DDL for Package CSI_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TRANSACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: csittrxs.pls 120.1 2005/07/06 18:46:55 sguthiva noship $ */
-- start of comments
-- PACKAGE name     : csi_transactions_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments
/* ---------------------------------------------------------------------------------- */
/* ---  this PROCEDURE is used to insert the record INTO csi_transactions table.  --- */
/* ---------------------------------------------------------------------------------- */
PROCEDURE insert_row(
          px_transaction_id             IN OUT NOCOPY NUMBER  ,
          p_transaction_date                   DATE    ,
          p_source_transaction_date            DATE    ,
          p_transaction_type_id                NUMBER  ,
          p_txn_sub_type_id                    NUMBER  ,
          p_source_group_ref_id                NUMBER  ,
          p_source_group_ref                   VARCHAR2,
          p_source_header_ref_id               NUMBER  ,
          p_source_header_ref                  VARCHAR2,
          p_source_line_ref_id                 NUMBER  ,
          p_source_line_ref                    VARCHAR2,
          p_source_dist_ref_id1                NUMBER  ,
          p_source_dist_ref_id2                NUMBER  ,
          p_inv_material_transaction_id        NUMBER  ,
          p_transaction_quantity               NUMBER  ,
          p_transaction_uom_code               VARCHAR2,
          p_transacted_by                      NUMBER  ,
          p_transaction_status_code            VARCHAR2,
          p_transaction_action_code            VARCHAR2,
          p_message_id                         NUMBER  ,
          p_context                            VARCHAR2,
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
          p_created_by                         NUMBER  ,
          p_creation_date                      DATE    ,
          p_last_updated_by                    NUMBER  ,
          p_last_update_date                   DATE    ,
          p_last_update_login                  NUMBER  ,
          p_object_version_number              NUMBER  ,
          p_split_reason_code                  VARCHAR2,
          p_gl_interface_status_code           NUMBER);

/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to update the record into csi_transactions table.  --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE update_row(
          p_transaction_id              NUMBER      := fnd_api.g_miss_num ,
          p_transaction_date            DATE        := fnd_api.g_miss_date,
          p_source_transaction_date     DATE        := fnd_api.g_miss_date,
          p_transaction_type_id         NUMBER      := fnd_api.g_miss_num ,
          p_txn_sub_type_id             NUMBER      := fnd_api.g_miss_num ,
          p_source_group_ref_id         NUMBER      := fnd_api.g_miss_num ,
          p_source_group_ref            VARCHAR2    := fnd_api.g_miss_char,
          p_source_header_ref_id        NUMBER      := fnd_api.g_miss_num ,
          p_source_header_ref           VARCHAR2    := fnd_api.g_miss_char,
          p_source_line_ref_id          NUMBER      := fnd_api.g_miss_num ,
          p_source_line_ref             VARCHAR2    := fnd_api.g_miss_char,
          p_source_dist_ref_id1         NUMBER      := fnd_api.g_miss_num ,
          p_source_dist_ref_id2         NUMBER      := fnd_api.g_miss_num ,
          p_inv_material_transaction_id NUMBER      := fnd_api.g_miss_num ,
          p_transaction_quantity        NUMBER      := fnd_api.g_miss_num ,
          p_transaction_uom_code        VARCHAR2    := fnd_api.g_miss_char,
          p_transacted_by               NUMBER      := fnd_api.g_miss_num ,
          p_transaction_status_code     VARCHAR2    := fnd_api.g_miss_char,
          p_transaction_action_code     VARCHAR2    := fnd_api.g_miss_char,
          p_message_id                  NUMBER      := fnd_api.g_miss_num ,
          p_context                     VARCHAR2    := fnd_api.g_miss_char,
          p_attribute1                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute2                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute3                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute4                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute5                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute6                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute7                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute8                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute9                  VARCHAR2    := fnd_api.g_miss_char,
          p_attribute10                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute11                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute12                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute13                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute14                 VARCHAR2    := fnd_api.g_miss_char,
          p_attribute15                 VARCHAR2    := fnd_api.g_miss_char,
          p_created_by                  NUMBER      := fnd_api.g_miss_num ,
          p_creation_date               DATE        := fnd_api.g_miss_date,
          p_last_updated_by             NUMBER      := fnd_api.g_miss_num ,
          p_last_update_date            DATE        := fnd_api.g_miss_date,
          p_last_update_login           NUMBER      := fnd_api.g_miss_num ,
          p_object_version_NUMBER       NUMBER      := fnd_api.g_miss_num ,
          p_split_reason_code           VARCHAR2    := fnd_api.g_miss_char,
          p_gl_interface_status_code    NUMBER      := fnd_api.g_miss_num
          );
/*
PROCEDURE lock_row(
          p_transaction_id              NUMBER,
          p_transaction_date            date,
          p_source_transaction_date     date,
          p_transaction_type_id         NUMBER,
          p_source_group_ref_id         NUMBER,
                p_source_group_ref              VARCHAR2,
          p_source_header_ref_id        NUMBER,
                p_source_header_ref             VARCHAR2,
          p_source_line_ref_id          NUMBER,
                p_source_line_ref               VARCHAR2,
          p_source_dist_ref_id1         NUMBER,
          p_source_dist_ref_id2         NUMBER,
          p_inv_material_transaction_id NUMBER,
          p_transaction_quantity        NUMBER,
          p_transaction_uom_code        VARCHAR2,
          p_transacted_by                       NUMBER,
          p_transaction_status_code      VARCHAR2,
          p_transaction_action_code      VARCHAR2,
          p_message_id                          NUMBER,
          p_context                             VARCHAR2,
          p_attribute1                          VARCHAR2,
          p_attribute2                          VARCHAR2,
          p_attribute3                          VARCHAR2,
          p_attribute4                          VARCHAR2,
          p_attribute5                          VARCHAR2,
          p_attribute6                          VARCHAR2,
          p_attribute7                          VARCHAR2,
          p_attribute8                          VARCHAR2,
          p_attribute9                          VARCHAR2,
          p_attribute10                         VARCHAR2,
          p_attribute11                         VARCHAR2,
          p_attribute12                         VARCHAR2,
          p_attribute13                         VARCHAR2,
          p_attribute14                         VARCHAR2,
          p_attribute15                         VARCHAR2,
          p_created_by                          NUMBER,
          p_creation_date                       date,
          p_last_updated_by             NUMBER,
          p_last_update_date                    date,
          p_last_update_login                   NUMBER,
          p_object_version_NUMBER       NUMBER)

PROCEDURE delete_row(
    p_transaction_id  NUMBER);

*/
END csi_transactions_pkg;

 

/
