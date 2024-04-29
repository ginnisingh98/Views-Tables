--------------------------------------------------------
--  DDL for Package Body CSI_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TRANSACTIONS_PKG" AS
/* $Header: csittrxb.pls 120.1 2005/07/06 18:47:58 sguthiva noship $ */
-- start of comments
-- package name     : csi_transactions_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments


g_pkg_name CONSTANT VARCHAR2(30):= 'csi_transactions_pkg';
g_file_name CONSTANT VARCHAR2(12) := 'csittrxb.pls';

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
          p_gl_interface_status_code           NUMBER )

 IS
   CURSOR c2 IS SELECT csi_transactions_s.nextval FROM sys.dual;
BEGIN
   IF (px_transaction_id IS NULL) or (px_transaction_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 INTO px_transaction_id;
       CLOSE c2;
   END IF;


   insert INTO csi_transactions(
           transaction_id,
           transaction_date,
           source_transaction_date,
           transaction_type_id,
           txn_sub_type_id,
           source_group_ref_id,
           source_group_ref,
           source_header_ref_id,
           source_header_ref,
           source_line_ref_id,
           source_line_ref,
           source_dist_ref_id1,
           source_dist_ref_id2,
           inv_material_transaction_id,
           transaction_quantity,
           transaction_uom_code,
           transacted_by,
           transaction_status_code,
           transaction_action_code,
           message_id,
           context,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           split_reason_code,
           gl_interface_status_code
          ) values (
           px_transaction_id,
           decode( p_transaction_date, fnd_api.g_miss_date, to_date(null), p_transaction_date),
           decode( p_source_transaction_date, fnd_api.g_miss_date, to_date(null), p_source_transaction_date),
           decode( p_transaction_type_id, fnd_api.g_miss_num, null, p_transaction_type_id),
           decode( p_txn_sub_type_id, fnd_api.g_miss_num, null, p_txn_sub_type_id),
           decode( p_source_group_ref_id, fnd_api.g_miss_num, null, p_source_group_ref_id),
           decode( p_source_group_ref, fnd_api.g_miss_char, null, p_source_group_ref),
           decode( p_source_header_ref_id, fnd_api.g_miss_num, null, p_source_header_ref_id),
           decode( p_source_header_ref, fnd_api.g_miss_char, null, p_source_header_ref),
           decode( p_source_line_ref_id, fnd_api.g_miss_num, null, p_source_line_ref_id),
           decode( p_source_line_ref, fnd_api.g_miss_char, null, p_source_line_ref),
           decode( p_source_dist_ref_id1, fnd_api.g_miss_num, null, p_source_dist_ref_id1),
           decode( p_source_dist_ref_id2, fnd_api.g_miss_num, null, p_source_dist_ref_id2),
           decode( p_inv_material_transaction_id, fnd_api.g_miss_num, null, p_inv_material_transaction_id),
           decode( p_transaction_quantity, fnd_api.g_miss_num, null, p_transaction_quantity),
           decode( p_transaction_uom_code, fnd_api.g_miss_char, null, p_transaction_uom_code),
           decode( p_transacted_by, fnd_api.g_miss_num, null, p_transacted_by),
           decode( p_transaction_status_code, fnd_api.g_miss_char, null, p_transaction_status_code),
           decode( p_transaction_action_code, fnd_api.g_miss_char, null, p_transaction_action_code),
           decode( p_message_id, fnd_api.g_miss_num, null, p_message_id),
           decode( p_context, fnd_api.g_miss_char, null, p_context),
           decode( p_attribute1, fnd_api.g_miss_char, null, p_attribute1),
           decode( p_attribute2, fnd_api.g_miss_char, null, p_attribute2),
           decode( p_attribute3, fnd_api.g_miss_char, null, p_attribute3),
           decode( p_attribute4, fnd_api.g_miss_char, null, p_attribute4),
           decode( p_attribute5, fnd_api.g_miss_char, null, p_attribute5),
           decode( p_attribute6, fnd_api.g_miss_char, null, p_attribute6),
           decode( p_attribute7, fnd_api.g_miss_char, null, p_attribute7),
           decode( p_attribute8, fnd_api.g_miss_char, null, p_attribute8),
           decode( p_attribute9, fnd_api.g_miss_char, null, p_attribute9),
           decode( p_attribute10, fnd_api.g_miss_char, null, p_attribute10),
           decode( p_attribute11, fnd_api.g_miss_char, null, p_attribute11),
           decode( p_attribute12, fnd_api.g_miss_char, null, p_attribute12),
           decode( p_attribute13, fnd_api.g_miss_char, null, p_attribute13),
           decode( p_attribute14, fnd_api.g_miss_char, null, p_attribute14),
           decode( p_attribute15, fnd_api.g_miss_char, null, p_attribute15),
           decode( p_created_by, fnd_api.g_miss_num, null, p_created_by),
           decode( p_creation_date, fnd_api.g_miss_date, to_date(null), p_creation_date),
           decode( p_last_updated_by, fnd_api.g_miss_num, null, p_last_updated_by),
           decode( p_last_update_date, fnd_api.g_miss_date, to_date(null), p_last_update_date),
           decode( p_last_update_login, fnd_api.g_miss_num, null, p_last_update_login),
           decode( p_object_version_number, fnd_api.g_miss_num, null, p_object_version_number),
           decode( p_split_reason_code, fnd_api.g_miss_char, null, p_split_reason_code),
           decode( p_gl_interface_status_code, fnd_api.g_miss_num, null, p_gl_interface_status_code)
           );

          -- commit;
end insert_row;

/* ---------------------------------------------------------------------------------- */
/* ---  this procedure is used to update the record into csi_transactions table.  --- */
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
          p_object_version_number       NUMBER      := fnd_api.g_miss_num ,
          p_split_reason_code           VARCHAR2    := fnd_api.g_miss_char,
          p_gl_interface_status_code    NUMBER      := fnd_api.g_miss_num
          )
 is
 BEGIN
    update csi_transactions
    set
              transaction_date = decode( p_transaction_date, fnd_api.g_miss_date, transaction_date, p_transaction_date),
              source_transaction_date = decode( p_source_transaction_date, fnd_api.g_miss_date, source_transaction_date, p_source_transaction_date),
              transaction_type_id = decode( p_transaction_type_id, fnd_api.g_miss_num, transaction_type_id, p_transaction_type_id),
              txn_sub_type_id = decode( p_txn_sub_type_id, fnd_api.g_miss_num, txn_sub_type_id, p_txn_sub_type_id),
              source_group_ref_id = decode( p_source_group_ref_id, fnd_api.g_miss_num, source_group_ref_id, p_source_group_ref_id),
              source_group_ref = decode( p_source_group_ref, fnd_api.g_miss_char, source_group_ref, p_source_group_ref),
              source_header_ref_id = decode( p_source_header_ref_id, fnd_api.g_miss_num, source_header_ref_id, p_source_header_ref_id),
              source_header_ref = decode( p_source_header_ref, fnd_api.g_miss_char, source_header_ref, p_source_header_ref),
              source_line_ref_id = decode( p_source_line_ref_id, fnd_api.g_miss_num, source_line_ref_id, p_source_line_ref_id),
              source_line_ref = decode( p_source_line_ref, fnd_api.g_miss_char, source_line_ref, p_source_line_ref),
              source_dist_ref_id1 = decode( p_source_dist_ref_id1, fnd_api.g_miss_num, source_dist_ref_id1, p_source_dist_ref_id1),
              source_dist_ref_id2 = decode( p_source_dist_ref_id2, fnd_api.g_miss_num, source_dist_ref_id2, p_source_dist_ref_id2),
              inv_material_transaction_id = decode( p_inv_material_transaction_id, fnd_api.g_miss_num, inv_material_transaction_id, p_inv_material_transaction_id),
              transaction_quantity = decode( p_transaction_quantity, fnd_api.g_miss_num, transaction_quantity, p_transaction_quantity),
              transaction_uom_code = decode( p_transaction_uom_code, fnd_api.g_miss_char, transaction_uom_code, p_transaction_uom_code),
              transacted_by = decode( p_transacted_by, fnd_api.g_miss_num, transacted_by, p_transacted_by),
              transaction_status_code = decode( p_transaction_status_code, fnd_api.g_miss_char, transaction_status_code, p_transaction_status_code),
              transaction_action_code = decode( p_transaction_action_code, fnd_api.g_miss_char, transaction_action_code, p_transaction_action_code),
              message_id = decode( p_message_id, fnd_api.g_miss_num, message_id, p_message_id),
              context = decode( p_context, fnd_api.g_miss_char, context, p_context),
              attribute1 = decode( p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1),
              attribute2 = decode( p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2),
              attribute3 = decode( p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3),
              attribute4 = decode( p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4),
              attribute5 = decode( p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5),
              attribute6 = decode( p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6),
              attribute7 = decode( p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7),
              attribute8 = decode( p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8),
              attribute9 = decode( p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9),
              attribute10 = decode( p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10),
              attribute11 = decode( p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11),
              attribute12 = decode( p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12),
              attribute13 = decode( p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13),
              attribute14 = decode( p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14),
              attribute15 = decode( p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15),
              created_by = decode( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
              creation_date = decode( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
              last_updated_by = decode( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = decode( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = decode( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = object_version_number+1,
              --decode( p_object_version_NUMBER, fnd_api.g_miss_num, object_version_NUMBER, p_object_version_NUMBER),
              split_reason_code = decode( p_split_reason_code, fnd_api.g_miss_char, split_reason_code, p_split_reason_code),
              gl_interface_status_code = decode( p_gl_interface_status_code, fnd_api.g_miss_num, gl_interface_status_code, p_gl_interface_status_code)

    WHERE transaction_id = p_transaction_id;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;
    --commit;
end update_row;

/*
PROCEDURE delete_row(
    p_transaction_id  NUMBER)
 is
 BEGIN
   delete FROM csi_transactions
    WHERE transaction_id = p_transaction_id;
   IF (SQL%NOTFOUND) THEN
       raise no_data_found;
   END IF;
 end delete_row;

PROCEDURE lock_row(
          p_transaction_id    NUMBER,
          p_transaction_date    date,
          p_source_transaction_date    date,
          p_transaction_type_id    NUMBER,
          p_source_group_ref_id    NUMBER,
                p_source_group_ref       VARCHAR2,
          p_source_header_ref_id    NUMBER,
                p_source_header_ref       VARCHAR2,
          p_source_line_ref_id    NUMBER,
                p_source_line_ref        VARCHAR2,
          p_source_dist_ref_id1    NUMBER,
          p_source_dist_ref_id2    NUMBER,
          p_inv_material_transaction_id    NUMBER,
          p_transaction_quantity    NUMBER,
          p_transaction_uom_code    VARCHAR2,
          p_transacted_by    NUMBER,
          p_transaction_status_code    VARCHAR2,
          p_transaction_action_code    VARCHAR2,
          p_message_id    NUMBER,
          p_context    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    date,
          p_last_updated_by    NUMBER,
          p_last_update_date    date,
          p_last_update_login    NUMBER,
          p_object_version_NUMBER    NUMBER,

 is
   CURSOR c is
        SELECT *
         FROM csi_transactions
        WHERE transaction_id =  p_transaction_id
        for update of transaction_id nowait;
   recinfo c%rowtype;
 BEGIN
    open c;
    FETCH c INTO recinfo;
    if (c%notfound) THEN
        close c;
        fnd_message.set_name('fnd', 'form_record_deleted');
        app_exception.raise_exception;
    END IF;
    close c;
    if (
           (      recinfo.transaction_id = p_transaction_id)
       AND (    ( recinfo.transaction_date = p_transaction_date)
            or (    ( recinfo.transaction_date IS NULL )
                AND (  p_transaction_date IS NULL )))
       AND (    ( recinfo.source_transaction_date = p_source_transaction_date)
            or (    ( recinfo.source_transaction_date IS NULL )
                AND (  p_source_transaction_date IS NULL )))
       AND (    ( recinfo.transaction_type_id = p_transaction_type_id)
            or (    ( recinfo.transaction_type_id IS NULL )
                AND (  p_transaction_type_id IS NULL )))
       AND (    ( recinfo.source_group_ref_id = p_source_group_ref_id)
            or (    ( recinfo.source_group_ref_id IS NULL )
                AND (  p_source_group_ref_id IS NULL )))
       AND (    ( recinfo.source_group_ref = p_source_group_ref)
            or (    ( recinfo.source_group_ref IS NULL )
                AND (  p_source_group_ref IS NULL )))
       AND (    ( recinfo.source_header_ref_id = p_source_header_ref_id)
            or (    ( recinfo.source_header_ref_id IS NULL )
                AND (  p_source_header_ref_id IS NULL )))
       AND (    ( recinfo.source_header_ref = p_source_header_ref)
            or (    ( recinfo.source_header_ref IS NULL )
                AND (  p_source_header_ref IS NULL )))
       AND (    ( recinfo.source_line_ref_id = p_source_line_ref_id)
            or (    ( recinfo.source_line_ref_id IS NULL )
                AND (  p_source_line_ref_id IS NULL )))
       AND (    ( recinfo.source_line_ref = p_source_line_ref)
            or (    ( recinfo.source_line_ref IS NULL )
                AND (  p_source_line_ref IS NULL )))
       AND (    ( recinfo.source_dist_ref_id1 = p_source_dist_ref_id1)
            or (    ( recinfo.source_dist_ref_id1 IS NULL )
                AND (  p_source_dist_ref_id1 IS NULL )))
       AND (    ( recinfo.source_dist_ref_id2 = p_source_dist_ref_id2)
            or (    ( recinfo.source_dist_ref_id2 IS NULL )
                AND (  p_source_dist_ref_id2 IS NULL )))
       AND (    ( recinfo.inv_material_transaction_id = p_inv_material_transaction_id)
            or (    ( recinfo.inv_material_transaction_id IS NULL )
                AND (  p_inv_material_transaction_id IS NULL )))
       AND (    ( recinfo.transaction_quantity = p_transaction_quantity)
            or (    ( recinfo.transaction_quantity IS NULL )
                AND (  p_transaction_quantity IS NULL )))
       AND (    ( recinfo.transaction_uom_code = p_transaction_uom_code)
            or (    ( recinfo.transaction_uom_code IS NULL )
                AND (  p_transaction_uom_code IS NULL )))
       AND (    ( recinfo.transacted_by = p_transacted_by)
            or (    ( recinfo.transacted_by IS NULL )
                AND (  p_transacted_by IS NULL )))
       AND (    ( recinfo.transaction_status_code = p_transaction_status_code)
            or (    ( recinfo.transaction_status_code IS NULL )
                AND (  p_transaction_status_code IS NULL )))
       AND (    ( recinfo.transaction_action_code = p_transaction_action_code)
            or (    ( recinfo.transaction_action_code IS NULL )
                AND (  p_transaction_action_code IS NULL )))
       AND (    ( recinfo.message_id = p_message_id)
            or (    ( recinfo.message_id IS NULL )
                AND (  p_message_id IS NULL )))
       AND (    ( recinfo.context = p_context)
            or (    ( recinfo.context IS NULL )
                AND (  p_context IS NULL )))
       AND (    ( recinfo.attribute1 = p_attribute1)
            or (    ( recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( recinfo.attribute2 = p_attribute2)
            or (    ( recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( recinfo.attribute3 = p_attribute3)
            or (    ( recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( recinfo.attribute4 = p_attribute4)
            or (    ( recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( recinfo.attribute5 = p_attribute5)
            or (    ( recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( recinfo.attribute6 = p_attribute6)
            or (    ( recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( recinfo.attribute7 = p_attribute7)
            or (    ( recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( recinfo.attribute8 = p_attribute8)
            or (    ( recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( recinfo.attribute9 = p_attribute9)
            or (    ( recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( recinfo.attribute10 = p_attribute10)
            or (    ( recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( recinfo.attribute11 = p_attribute11)
            or (    ( recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( recinfo.attribute12 = p_attribute12)
            or (    ( recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( recinfo.attribute13 = p_attribute13)
            or (    ( recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( recinfo.attribute14 = p_attribute14)
            or (    ( recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( recinfo.attribute15 = p_attribute15)
            or (    ( recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( recinfo.created_by = p_created_by)
            or (    ( recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( recinfo.creation_date = p_creation_date)
            or (    ( recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( recinfo.last_updated_by = p_last_updated_by)
            or (    ( recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( recinfo.last_update_date = p_last_update_date)
            or (    ( recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( recinfo.last_update_login = p_last_update_login)
            or (    ( recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( recinfo.object_version_NUMBER = p_object_version_NUMBER)
            or (    ( recinfo.object_version_NUMBER IS NULL )
                AND (  p_object_version_NUMBER IS NULL )))
       ) THEN
       return;
   ELSE
       fnd_message.set_name('fnd', 'form_record_changed');
       app_exception.raise_exception;
   END IF;
end lock_row;
*/
END csi_transactions_pkg;

/
