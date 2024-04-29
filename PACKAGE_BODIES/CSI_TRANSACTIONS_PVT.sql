--------------------------------------------------------
--  DDL for Package Body CSI_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_TRANSACTIONS_PVT" AS
/* $Header: csivtrxb.pls 120.3 2005/12/15 13:41:57 brmanesh noship $ */
-- start of comments
-- PACKAGE name     : csi_transactions_pvt
-- purpose          :
-- history          :
-- note             :
-- END of comments


g_pkg_name  CONSTANT VARCHAR2(30):= 'csi_transactions_pvt';
g_file_name CONSTANT VARCHAR2(12) := 'csivtrxb.pls';

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the transaction_id passed                                                 --- */
/* ---------------------------------------------------------------------------------- */

-- this procudure defines the columns for the dynamic sql.
PROCEDURE define_columns(
p_txnfind_rec                IN   csi_datastructures_pub.transaction_header_rec,
p_cur_get_transactions       IN   NUMBER
)
IS
BEGIN

      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 1, p_txnfind_rec.transaction_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 2, p_txnfind_rec.transaction_date);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 3, p_txnfind_rec.source_transaction_date);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 4, p_txnfind_rec.transaction_type_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 5, p_txnfind_rec.source_group_ref_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 6, p_txnfind_rec.source_group_ref,50);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 7, p_txnfind_rec.source_header_ref_id );
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 8, p_txnfind_rec.source_header_ref,50);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 9, p_txnfind_rec.source_line_ref_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 10, p_txnfind_rec.source_line_ref,50);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 11, p_txnfind_rec.source_dist_ref_id1);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 12, p_txnfind_rec.source_dist_ref_id2);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 13, p_txnfind_rec.inv_material_transaction_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 14, p_txnfind_rec.transaction_quantity);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 15, p_txnfind_rec.transaction_uom_code,3);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 16, p_txnfind_rec.transacted_by);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 17, p_txnfind_rec.transaction_status_code,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 18, p_txnfind_rec.transaction_action_code,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 19, p_txnfind_rec.message_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 21, p_txnfind_rec.attribute1,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 22, p_txnfind_rec.attribute2,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 23, p_txnfind_rec.attribute3,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 24, p_txnfind_rec.attribute4,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 25, p_txnfind_rec.attribute5,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 26, p_txnfind_rec.attribute6,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 27, p_txnfind_rec.attribute7,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 28, p_txnfind_rec.attribute8,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 29, p_txnfind_rec.attribute9,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 30, p_txnfind_rec.attribute10,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 31, p_txnfind_rec.attribute11,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 32, p_txnfind_rec.attribute12,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 33, p_txnfind_rec.attribute13,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 34, p_txnfind_rec.attribute14,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 35, p_txnfind_rec.attribute15,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 36, p_txnfind_rec.object_version_number);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 37, p_txnfind_rec.txn_sub_type_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 38, p_txnfind_rec.transaction_status_code,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 39, p_txnfind_rec.split_reason_code,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_transactions, 40, p_txnfind_rec.txn_user_id);
END define_columns;

-- This procudure gets column values by the dynamic sql.
PROCEDURE get_column_values(
    p_cur_get_transactions      IN   NUMBER,
    x_txnfind_rec               OUT NOCOPY  csi_datastructures_pub.transaction_header_rec
)
IS
BEGIN
      -- get all column values for csi_transactions table
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 1, x_txnfind_rec.transaction_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 2, x_txnfind_rec.transaction_date);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 3, x_txnfind_rec.source_transaction_date);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 4, x_txnfind_rec.transaction_type_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 5, x_txnfind_rec.source_group_ref_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 6, x_txnfind_rec.source_group_ref);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 7, x_txnfind_rec.source_header_ref_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 8, x_txnfind_rec.source_header_ref);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 9, x_txnfind_rec.source_line_ref_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 10, x_txnfind_rec.source_line_ref);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 11, x_txnfind_rec.source_dist_ref_id1);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 12, x_txnfind_rec.source_dist_ref_id2);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 13, x_txnfind_rec.inv_material_transaction_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 14, x_txnfind_rec.transaction_quantity);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 15, x_txnfind_rec.transaction_uom_code);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 16, x_txnfind_rec.transacted_by);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 17, x_txnfind_rec.transaction_status_code);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 18, x_txnfind_rec.transaction_action_code);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 19, x_txnfind_rec.message_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 21, x_txnfind_rec.attribute1);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 22, x_txnfind_rec.attribute2);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 23, x_txnfind_rec.attribute3);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 24, x_txnfind_rec.attribute4);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 25, x_txnfind_rec.attribute5);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 26, x_txnfind_rec.attribute6);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 27, x_txnfind_rec.attribute7);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 28, x_txnfind_rec.attribute8);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 29, x_txnfind_rec.attribute9);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 30, x_txnfind_rec.attribute10);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 31, x_txnfind_rec.attribute11);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 32, x_txnfind_rec.attribute12);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 33, x_txnfind_rec.attribute13);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 34, x_txnfind_rec.attribute14);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 35, x_txnfind_rec.attribute15);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 36, x_txnfind_rec.object_version_number);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 37, x_txnfind_rec.txn_sub_type_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 38, x_txnfind_rec.transaction_status_code);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 39, x_txnfind_rec.split_reason_code);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_transactions, 40, x_txnfind_rec.txn_user_id);
END get_column_values;


PROCEDURE gen_transactions_order_cl(
    p_order_by_rec   IN   csi_datastructures_pub.transaction_sort_rec,
    x_order_by_cl    OUT NOCOPY  VARCHAR2,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  util_order_by_tbl_type;
l_column             VARCHAR2(30)     :=fnd_api.g_miss_char;
BEGIN

      IF p_order_by_rec.transaction_date  = 'Y' THEN
              l_column:=' transaction_date';
      ELSIF   p_order_by_rec.transaction_type_id = 'Y' THEN
              l_column:=' transaction_type_id';
      END IF;

      IF l_column <> fnd_api.g_miss_char  THEN
          x_order_by_cl := ' order by' || l_column;
      ELSE
          x_order_by_cl :=l_order_by_cl;
      END IF;

END gen_transactions_order_cl;

-- This procedure bind the variables for the dynamic sql
PROCEDURE bind(
    p_txnfind_rec            IN   csi_datastructures_pub.transaction_query_rec,
    p_cur_get_transactions   IN   NUMBER
)
IS
BEGIN
      IF( (p_txnfind_rec.transaction_id IS NOT NULL) AND (p_txnfind_rec.transaction_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, 'transaction_id', p_txnfind_rec.transaction_id);
      END IF;

      IF( (p_txnfind_rec.transaction_type_id IS NOT NULL) AND (p_txnfind_rec.transaction_type_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':transaction_type_id', p_txnfind_rec.transaction_type_id);
      END IF;

      IF( (p_txnfind_rec.txn_sub_type_id IS NOT NULL) AND (p_txnfind_rec.txn_sub_type_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':txn_sub_type_id', p_txnfind_rec.txn_sub_type_id);
      END IF;

      IF( (p_txnfind_rec.source_group_ref_id IS NOT NULL) AND (p_txnfind_rec.source_group_ref_id<> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_group_ref_id', p_txnfind_rec.source_group_ref_id);
      END IF;

      IF( (p_txnfind_rec.source_group_ref IS NOT NULL) AND (p_txnfind_rec.source_group_ref <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_group_ref', p_txnfind_rec.source_group_ref);
      END IF;

      IF( (p_txnfind_rec.source_header_ref_id IS NOT NULL) AND (p_txnfind_rec.source_header_ref_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_header_ref_id', p_txnfind_rec.source_header_ref_id);
      END IF;

      IF( (p_txnfind_rec.source_header_ref IS NOT NULL) AND (p_txnfind_rec.source_header_ref <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_header_ref', p_txnfind_rec.source_header_ref);
      END IF;

      IF( (p_txnfind_rec.source_line_ref_id IS NOT NULL) AND (p_txnfind_rec.source_line_ref_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_line_ref_id', p_txnfind_rec.source_line_ref_id);
      END IF;

      IF( (p_txnfind_rec.source_line_ref IS NOT NULL) AND (p_txnfind_rec.source_line_ref <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_line_ref', rtrim(ltrim(p_txnfind_rec.source_line_ref)));
      END IF;

      IF( (p_txnfind_rec.source_transaction_date IS NOT NULL) AND (p_txnfind_rec.source_transaction_date <> fnd_api.g_miss_date) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':source_txn_date', p_txnfind_rec.source_transaction_date);
      END IF;

      IF( (p_txnfind_rec.inv_material_transaction_id IS NOT NULL) AND (p_txnfind_rec.inv_material_transaction_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':inv_material_transaction_id', p_txnfind_rec.inv_material_transaction_id);
      END IF;

      IF( (p_txnfind_rec.message_id IS NOT NULL) AND (p_txnfind_rec.message_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':message_id', p_txnfind_rec.message_id);
      END IF;

      IF( (p_txnfind_rec.instance_id IS NOT NULL) AND (p_txnfind_rec.instance_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':instance_id', p_txnfind_rec.instance_id);
      END IF;


      IF( (p_txnfind_rec.transaction_start_date IS NOT NULL) AND (p_txnfind_rec.transaction_start_date <> fnd_api.g_miss_date) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':transaction_start_date', p_txnfind_rec.transaction_start_date);
      END IF;


      IF( (p_txnfind_rec.transaction_end_date IS NOT NULL) AND (p_txnfind_rec.transaction_end_date <> fnd_api.g_miss_date) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':transaction_end_date', p_txnfind_rec.transaction_end_date);
      END IF;

      IF( (p_txnfind_rec.transaction_status_code IS NOT NULL) AND (p_txnfind_rec.transaction_status_code <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_transactions, ':transaction_status_code', p_txnfind_rec.transaction_status_code);
      END IF;

END bind;

/* ---------------------------------------------------------------------------------- */
/* ---  When instance_id is passed then select from csi_inst_trx_details_v        --- */
/* ---  else from csi_transactions                                                --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE gen_select(
    p_txnfind_rec               IN  csi_datastructures_pub.transaction_query_rec,
    x_select_cl                 OUT NOCOPY   VARCHAR2
)
IS
l_table_name                    VARCHAR2(30);
BEGIN
   IF ( (p_txnfind_rec.instance_id IS NOT NULL) AND (p_txnfind_rec.instance_id <> fnd_api.g_miss_num) ) THEN
   l_table_name:='csi_inst_trx_details_v';
   ELSE
   l_table_name:='csi_transactions';
   END IF;

      x_select_cl := 'SELECT transaction_id,transaction_date, source_transaction_date, '||
        'transaction_type_id, source_group_ref_id, source_group_ref, source_header_ref_id, '||
        'source_header_ref, source_line_ref_id, source_line_ref, source_dist_ref_id1, '||
        'source_dist_ref_id2, inv_material_transaction_id, transaction_quantity, '||
        'transaction_uom_code, transacted_by, transaction_status_code, '||
        'transaction_action_code, message_id, context, attribute1, attribute2, attribute3, '||
        'attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, '||
        'attribute11, attribute12, attribute13, attribute14, attribute15, '||
        'object_version_number, txn_sub_type_id, transaction_status_code, split_reason_code, '||
        'last_updated_by FROM '||l_table_name;

END gen_select;


PROCEDURE gen_transactions_where(
    p_txnfind_rec          IN   csi_datastructures_pub.transaction_query_rec,
    x_transactions_where   OUT NOCOPY   VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT instr(p_rec_item, '%', 1, 1)
    FROM dual;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT instr(p_rec_item, '_', 1, 1)
    FROM dual;

-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
i          NUMBER ;
l_operator VARCHAR2(10);

BEGIN


      IF( (p_txnfind_rec.transaction_id IS NOT NULL) AND (p_txnfind_rec.transaction_id <> fnd_api.g_miss_num) )
      THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'transaction_id = :transaction_id';
      END IF;

      IF( (p_txnfind_rec.transaction_type_id IS NOT NULL) AND (p_txnfind_rec.transaction_type_id <> fnd_api.g_miss_num) )
      THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'transaction_type_id = :transaction_type_id';
      END IF;

      IF( (p_txnfind_rec.txn_sub_type_id IS NOT NULL) AND (p_txnfind_rec.txn_sub_type_id <> fnd_api.g_miss_num) )
      THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'txn_sub_type_id = :txn_sub_type_id';
      END IF;

      IF( (p_txnfind_rec.source_group_ref_id IS NOT NULL) AND (p_txnfind_rec.source_group_ref_id <> fnd_api.g_miss_num) )
      THEN


          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'source_group_ref_id = :source_group_ref_id';
      END IF;

      IF( (p_txnfind_rec.source_group_ref IS NOT NULL) AND (p_txnfind_rec.source_group_ref <> fnd_api.g_miss_char) )
      THEN

      i:=0;
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_txnfind_rec.source_group_ref);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN

              l_operator := ' LIKE ';
              i:=1;
          ELSE

              l_operator := ' = ';
          END IF;
        IF i=0 THEN
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_txnfind_rec.source_group_ref);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN

              l_operator := ' LIKE ';
          ELSE

              l_operator := ' = ';
          END IF;
        END IF;
          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'source_group_ref ' || l_operator || ' :source_group_ref';
      END IF;


      IF( (p_txnfind_rec.source_header_ref_id IS NOT NULL) AND (p_txnfind_rec.source_header_ref_id <> fnd_api.g_miss_num) )
      THEN


          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'source_header_ref_id = :source_header_ref_id';
      END IF;

      IF( (p_txnfind_rec.source_header_ref IS NOT NULL) AND (p_txnfind_rec.source_header_ref <> fnd_api.g_miss_char) )
      THEN
      i:=0;
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_txnfind_rec.source_header_ref);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
              i:=1;
          ELSE
              l_operator := ' = ';
          END IF;
        IF i=0 THEN
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_txnfind_rec.source_header_ref);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
        END IF;
          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'source_header_ref ' || l_operator || ' :source_header_ref';
      END IF;



       IF( (p_txnfind_rec.source_line_ref_id IS NOT NULL) AND (p_txnfind_rec.source_line_ref_id <> fnd_api.g_miss_num) )
      THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'source_line_ref_id = :source_line_ref_id';
      END IF;

     IF( (p_txnfind_rec.source_line_ref IS NOT NULL) AND (p_txnfind_rec.source_line_ref <> fnd_api.g_miss_char) )
      THEN
      i:=0;
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_txnfind_rec.source_line_ref);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
              i:=1;
          ELSE
              l_operator := ' = ';
          END IF;
        IF i=0 THEN
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_txnfind_rec.source_line_ref);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
        END IF;
          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'source_line_ref ' || l_operator || ' :source_line_ref';
      END IF;

      IF( (p_txnfind_rec.source_transaction_date IS NOT NULL) AND (p_txnfind_rec.source_transaction_date <> fnd_api.g_miss_date) )
      THEN
      i:=0;
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_txnfind_rec.source_transaction_date);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
              i:=1;
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_txnfind_rec.source_transaction_date);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;
         IF i=0 THEN
          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
         END IF;
          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
-- bug 4349049         x_transactions_where := x_transactions_where || 'trunc(source_transaction_date) ' || l_operator || ' trunc(:source_txn_date)';
          IF l_operator = ' LIKE ' THEN
            x_transactions_where := x_transactions_where || 'trunc(source_transaction_date) ' || l_operator || ' trunc(:source_txn_date) ';
          ELSE
            x_transactions_where := x_transactions_where || 'source_transaction_date between :source_txn_date and :source_txn_date+1 ';
          END IF;
      END IF;


      IF( (p_txnfind_rec.inv_material_transaction_id IS NOT NULL) AND (p_txnfind_rec.inv_material_transaction_id <> fnd_api.g_miss_num) )
      THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'inv_material_transaction_id = :inv_material_transaction_id';
      END IF;

      IF( (p_txnfind_rec.message_id IS NOT NULL) AND (p_txnfind_rec.message_id <> fnd_api.g_miss_num) )
      THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'message_id = :message_id';
      END IF;


        IF( (p_txnfind_rec.transaction_start_date IS NOT NULL) AND (p_txnfind_rec.transaction_start_date <> fnd_api.g_miss_date) )
        THEN
          IF ( (p_txnfind_rec.transaction_end_date IS NOT NULL) AND (p_txnfind_rec.transaction_end_date <> fnd_api.g_miss_date) )
          THEN
           i:=0;
             IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
             ELSE
              x_transactions_where := x_transactions_where || ' AND ';
             END IF;
          x_transactions_where := x_transactions_where || ' transaction_date between :transaction_start_date AND :transaction_end_date ';
          ELSE
               IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
               ELSE
              x_transactions_where := x_transactions_where || ' AND ';
               END IF;
-- bug 4349049         x_transactions_where := x_transactions_where || 'trunc(transaction_date) ' || l_operator || ' trunc(:transaction_start_date)';
            x_transactions_where := x_transactions_where || 'transaction_date between :transaction_start_date and :transaction_start_date+1 ';
          END IF;
        END IF;

       IF( (p_txnfind_rec.instance_id IS NOT NULL) AND (p_txnfind_rec.instance_id <> fnd_api.g_miss_num) )
       THEN

          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'instance_id = :instance_id';
       END IF;

      IF( (p_txnfind_rec.transaction_status_code IS NOT NULL) AND (p_txnfind_rec.transaction_status_code <> fnd_api.g_miss_char) )
      THEN
          i:=0;
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(p_txnfind_rec.transaction_status_code);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
              i:=1;
          ELSE
              l_operator := ' = ';
          END IF;
        IF i=0 THEN
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(p_txnfind_rec.transaction_status_code);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
        END IF;
          IF(x_transactions_where IS NULL) THEN
              x_transactions_where := ' WHERE ';
          ELSE
              x_transactions_where := x_transactions_where || ' AND ';
          END IF;
          x_transactions_where := x_transactions_where || 'transaction_status_code ' || l_operator || ' :transaction_status_code';
      END IF;
END gen_transactions_where;

PROCEDURE get_transactions(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2             := fnd_api.g_false,
    p_commit                     IN   VARCHAR2             := fnd_api.g_false,
    p_validation_level           IN   NUMBER               := fnd_api.g_valid_level_full,
    p_txnfind_rec                IN   csi_datastructures_pub.transaction_query_rec     ,
    p_rec_requested              IN   NUMBER               := g_default_num_rec_fetch,
    p_start_rec_prt              IN   NUMBER               := 1,
    p_return_tot_count           IN   VARCHAR2             := fnd_api.g_false,
    p_order_by_rec               IN   csi_datastructures_pub.transaction_sort_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_transaction_tbl            OUT NOCOPY  csi_datastructures_pub.transaction_header_tbl,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT  VARCHAR2(30) := 'get_transactions';
l_api_version_number      CONSTANT  NUMBER       := 1.0;
l_returned_rec_count                NUMBER       := 0; -- number of records returned in x_txnfind_rec
l_next_record_ptr                   NUMBER       := 1;
l_ignore                            NUMBER;
-- total number of records accessable by caller
l_tot_rec_count                     NUMBER       := 0;
l_tot_rec_amount                    NUMBER       := 0;
-- status local variables
l_return_status                     VARCHAR2(1); -- return value from procedures
l_return_status_full                VARCHAR2(1); -- calculated return status from
-- dynamic sql statement elements
l_cur_get_transactions              NUMBER;
l_select_cl                         VARCHAR2(2000) := '';
l_order_by_cl                       VARCHAR2(2000);
l_transactions_where                VARCHAR2(2000) := '';
-- local scratch record
l_transaction_rec                   csi_datastructures_pub.transaction_query_rec;
l_crit_transaction_rec              csi_datastructures_pub.transaction_query_rec :=p_txnfind_rec;

l_txn_rec                           csi_datastructures_pub.transaction_header_rec;
l_def_transaction_rec               csi_datastructures_pub.transaction_header_rec;
l_debug_level                       NUMBER;


 BEGIN

      -- standard start of api savepoint
      IF fnd_api.to_boolean(p_commit)
      THEN
          SAVEPOINT get_transactions_pvt;
      END IF;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'get_transactions');
    END IF;

    IF (l_debug_level > 1) THEN

             CSI_gen_utility_pvt.put_line(
                            p_api_version_number      ||'-'||
                            p_init_msg_list           ||'-'||
                            p_commit                  ||'-'||
                            p_validation_level        ||'-'||
                            p_rec_requested           ||'-'||
                            p_start_rec_prt           ||'-'||
                            p_return_tot_count
                                          );

         csi_gen_utility_pvt.dump_txn_query_rec(p_txnfind_rec);
         csi_gen_utility_pvt.dump_txn_sort_rec(p_order_by_rec);


    END IF;



      --
      -- api BODY
      --
      -- *************************************************
      -- generate dynamic sql based on criteria passed in.

IF(    ((p_txnfind_rec.transaction_id IS NULL)              OR (p_txnfind_rec.transaction_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.transaction_type_id IS NULL)         OR (p_txnfind_rec.transaction_type_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.txn_sub_type_id IS NULL)             OR (p_txnfind_rec.txn_sub_type_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.source_group_ref_id IS NULL)         OR (p_txnfind_rec.source_group_ref_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.source_group_ref IS NULL)            OR (p_txnfind_rec.source_group_ref = fnd_api.g_miss_char))
   AND ((p_txnfind_rec.source_header_ref_id IS NULL)        OR (p_txnfind_rec.source_header_ref_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.source_header_ref IS NULL)           OR (p_txnfind_rec.source_header_ref = fnd_api.g_miss_char))
   AND ((p_txnfind_rec.source_line_ref_id IS NULL)          OR (p_txnfind_rec.source_line_ref_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.source_line_ref IS NULL)             OR (p_txnfind_rec.source_line_ref = fnd_api.g_miss_char))
   AND ((p_txnfind_rec.source_transaction_date IS NULL)     OR (p_txnfind_rec.source_transaction_date = fnd_api.g_miss_date))
   AND ((p_txnfind_rec.inv_material_transaction_id IS NULL) OR (p_txnfind_rec.inv_material_transaction_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.message_id IS NULL)                  OR (p_txnfind_rec.message_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.instance_id IS NULL)                 OR (p_txnfind_rec.instance_id = fnd_api.g_miss_num))
   AND ((p_txnfind_rec.transaction_start_date IS NULL)      OR (p_txnfind_rec.transaction_start_date = fnd_api.g_miss_date))
   AND ((p_txnfind_rec.transaction_end_date IS NULL)        OR (p_txnfind_rec.transaction_end_date = fnd_api.g_miss_date))
   AND ((p_txnfind_rec.transaction_status_code IS NULL)     OR (p_txnfind_rec.transaction_status_code = fnd_api.g_miss_char))

   ) THEN
    fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
    fnd_msg_pub.add;
    x_return_status := fnd_api.g_ret_sts_error;
    RAISE fnd_api.g_exc_error;
END IF;
      x_tot_rec_count:=l_tot_rec_count;
      x_returned_rec_count:=l_returned_rec_count;
      gen_select(l_crit_transaction_rec,l_select_cl);
      gen_transactions_where(l_crit_transaction_rec, l_transactions_where);
      gen_transactions_order_cl(p_order_by_rec, l_order_by_cl, l_return_status, x_msg_count, x_msg_data);

       IF dbms_sql.is_open(l_cur_get_transactions) THEN
          dbms_sql.close_cursor(l_cur_get_transactions);
       END IF;

      l_cur_get_transactions := dbms_sql.open_cursor;
      dbms_sql.parse(l_cur_get_transactions, l_select_cl|| l_transactions_where || l_order_by_cl , dbms_sql.native);
      bind(l_crit_transaction_rec, l_cur_get_transactions);
      define_columns(l_def_transaction_rec, l_cur_get_transactions);
      l_ignore := dbms_sql.execute(l_cur_get_transactions);

      LOOP

      IF((dbms_sql.fetch_rows(l_cur_get_transactions)>0) AND ((p_return_tot_count = fnd_api.g_true)
        OR (l_returned_rec_count<p_rec_requested) OR (p_rec_requested=fnd_api.g_miss_num)))
      THEN
                get_column_values(l_cur_get_transactions, l_txn_rec);
                l_tot_rec_count := l_tot_rec_count + 1;
                x_tot_rec_count := l_tot_rec_count;
              IF(l_returned_rec_count < p_rec_requested) AND (l_tot_rec_count >= p_start_rec_prt) THEN
                  l_returned_rec_count := l_returned_rec_count + 1;
                  x_returned_rec_count := l_returned_rec_count;

                  -- defaulting the transaction user name added by brmanesh
                  BEGIN

                    SELECT user_name
                    INTO   l_txn_rec.txn_user_name
                    FROM   fnd_user
                    WHERE  user_id = l_txn_rec.txn_user_id;

                  EXCEPTION
                    WHEN others THEN
                      l_txn_rec.txn_user_name := NULL;
                  END;

                  -- resolved the foreign key columns: Bug# 2136312 - 12/18/01 rtalluri
                  BEGIN

                    SELECT source_txn_type_name
                    INTO   l_txn_rec.transaction_type_name
                    FROM   csi_txn_types
                    WHERE  transaction_type_id = l_txn_rec.transaction_type_id;

                  EXCEPTION
                    WHEN others THEN
                      l_txn_rec.transaction_type_name := NULL;
                  END;

                  BEGIN

                    SELECT name
                    INTO   l_txn_rec.txn_sub_type_name
                    FROM   csi_txn_sub_types
                    WHERE  transaction_type_id = l_txn_rec.transaction_type_id
                    AND    sub_type_id         = l_txn_rec.txn_sub_type_id;

                  EXCEPTION
                    WHEN others THEN
                      l_txn_rec.txn_sub_type_name := NULL;
                  END;

                  BEGIN

                    SELECT application_name
                    INTO   l_txn_rec.source_application_name
                    FROM   fnd_application_vl
                    WHERE  application_id IN (SELECT source_application_id
                                              FROM   csi_txn_types
                                              WHERE  transaction_type_id = l_txn_rec.transaction_type_id);

                  EXCEPTION
                    WHEN others THEN
                      l_txn_rec.source_application_name := NULL;
                  END;

                  BEGIN
                     SELECT   meaning
                     INTO     l_txn_rec.transaction_status_name
                     FROM     csi_lookups
                     WHERE    lookup_code = l_txn_rec.transaction_status_code
                     AND      lookup_type = 'CSI_TRANSACTION_STATUS_CODE';
                  EXCEPTION
                    WHEN others THEN
                      l_txn_rec.transaction_status_name := NULL;
                  END;

                  x_transaction_tbl(l_returned_rec_count) :=l_txn_rec;
              END IF;
      ELSE
          EXIT;
      END IF;
      END LOOP;
      --
      -- end of api body
      --
     dbms_sql.close_cursor(l_cur_get_transactions);

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
               IF fnd_api.to_boolean(p_commit)
               THEN
                ROLLBACK TO get_transactions_pvt;
               END IF;
                        x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                        ROLLBACK TO get_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                    (p_count => x_msg_count ,
                     p_data => x_msg_data
                     );

          WHEN OTHERS THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                        ROLLBACK TO get_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                     (   p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
END get_transactions;

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the transaction_id passed                                                 --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE validate_transaction_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_transaction_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the transaction_date passed                                               --- */
/* ---------------------------------------------------------------------------------- */



PROCEDURE validate_s_transaction_date (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_source_transaction_date    IN   DATE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the transaction_type_id passed                                            --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE validate_transaction_type_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_transaction_type_id        IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* --------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                 --- */
/* ---  the object_version_number passed                                         --- */
/* --------------------------------------------------------------------------------- */

PROCEDURE validate_object_version_num (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_object_version_number      IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the transaction_type_id passed                                            --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE validate_source_object (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_transaction_type_id        IN   NUMBER,
    p_source_line_ref_id         IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the split_reason_code passed                                              --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE validate_split_code (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_split_reason_code          IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER  ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the transactions for the parameters passed                                --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE validate_transactions(
    p_init_msg_list              IN   VARCHAR2              := fnd_api.g_false,
    p_validation_level           IN   NUMBER                := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2,
    p_transaction_rec            IN   csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to create transactions                             --- */
/* ---  and call table handler after performing all the validations               --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE create_transaction(
    p_api_version                IN     NUMBER,
    p_init_msg_list              IN     VARCHAR2              := fnd_api.g_false,
    p_commit                     IN     VARCHAR2              := fnd_api.g_false,
    p_validation_level           IN     NUMBER                := fnd_api.g_valid_level_full,
    p_success_if_exists_flag     IN     VARCHAR2              := 'N',
    p_transaction_rec            IN OUT NOCOPY csi_datastructures_pub.transaction_rec ,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'create_transaction';
l_api_version             CONSTANT NUMBER       := 1.0;
l_transaction_date                 DATE;                                 -- local variable for sysdate
l_return_status_full               VARCHAR2(1);
l_access_flag                      VARCHAR2(1);
l_dummy                            VARCHAR2(1);
l_create_flag                      VARCHAR2(1):='Y';
l_debug_level                      NUMBER;

 BEGIN

       -- standard start of api savepoint
      IF fnd_api.to_boolean(p_commit)
      THEN
         SAVEPOINT create_transactions_pvt;
      END IF;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'create_transaction');
    END IF;

    IF (l_debug_level > 1) THEN
             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_init_msg_list           ||'-'||
                            p_commit                  ||'-'||
                            p_validation_level        ||'-'||
                            p_success_if_exists_flag
                                          );
         csi_gen_utility_pvt.dump_txn_rec(p_transaction_rec);


    END IF;
      --
      -- api body
      --

     IF p_success_if_exists_flag ='Y' THEN
       /* If success flag is Y then  */
         IF ((p_transaction_rec.transaction_id IS NOT NULL) AND
              (p_transaction_rec.transaction_id <> fnd_api.g_miss_num)) THEN
        /* If success flag is Y then  check for id if present return success  */

               BEGIN
                 SELECT 'x'
                   INTO l_dummy
                   FROM csi_transactions
                  WHERE transaction_id=p_transaction_rec.transaction_id
                    AND rownum=1;
                 IF SQL%FOUND THEN
                  x_return_status := fnd_api.g_ret_sts_success;
                  l_create_flag :='N';
                 END IF;

               EXCEPTION WHEN no_data_found THEN
       /* If success flag is Y then if passed id not found then proceed with validations  */
                   validate_transactions(
                   p_init_msg_list    => fnd_api.g_false,
                   p_validation_level => p_validation_level,
                   p_validation_mode  => 'CREATE',
                   p_transaction_rec => p_transaction_rec,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data);
               END;
          ELSE
        /* If success flag is Y then if id not passed proceed with validations  */
                validate_transactions(
                p_init_msg_list    => fnd_api.g_false,
                p_validation_level => p_validation_level,
                p_validation_mode  => 'CREATE',
                p_transaction_rec =>  p_transaction_rec,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data);
           END IF;
       ELSE

       /* If success flag is 'N' then if id passed already exists then return error mesg  */

           IF ((p_transaction_rec.transaction_id IS NOT NULL) AND
              (p_transaction_rec.transaction_id <> fnd_api.g_miss_num)) THEN
               BEGIN
                   SELECT 'x'
                   INTO   l_dummy
                   FROM   csi_transactions
                   WHERE  transaction_id=p_transaction_rec.transaction_id
                   AND    rownum=1;

                   IF SQL%FOUND THEN
                      fnd_message.set_name('CSI', 'CSI_TXN_ID_ALREADY_EXISTS');
                      fnd_message.set_token('transaction_id',p_transaction_rec.transaction_id);
                      fnd_msg_pub.add;
                      x_return_status := fnd_api.g_ret_sts_error;
                    END IF;

               EXCEPTION WHEN no_data_found THEN
       /* If success flag is 'N' then if id passed not exists then proceed with validations  */
                   validate_transactions(
                   p_init_msg_list    => fnd_api.g_false,
                   p_validation_level => p_validation_level,
                   p_validation_mode  => 'CREATE',
                   p_transaction_rec =>  p_transaction_rec,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data);
               END;
             -- added code for flag ='n and id passed
          ELSE
          /* If success flag is 'N' then if id not passed then proceed with validations  */
           validate_transactions(
                p_init_msg_list    => fnd_api.g_false,
                p_validation_level => p_validation_level,
                p_validation_mode  => 'CREATE',
                p_transaction_rec =>  p_transaction_rec,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data);
           END IF;
       END IF;



      IF x_return_status<>fnd_api.g_ret_sts_success THEN

          RAISE fnd_api.g_exc_error;
      END IF;



       SELECT SYSDATE
        INTO l_transaction_date
        FROM dual;

         IF p_transaction_rec.transaction_date=fnd_api.g_miss_date THEN
            l_transaction_date:=l_transaction_date;
         END IF;

         IF p_transaction_rec.gl_interface_status_code IS NULL OR
            p_transaction_rec.gl_interface_status_code = FND_API.G_MISS_NUM
         THEN
            p_transaction_rec.gl_interface_status_code :=1;
         ELSE
           IF p_transaction_rec.gl_interface_status_code NOT IN (1,2,3)
           THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_GL_STATUS');
             FND_MESSAGE.SET_TOKEN('STATUS_CODE',p_transaction_rec.gl_interface_status_code);
             FND_MSG_PUB.Add;
             RAISE fnd_api.g_exc_error;
           END IF;
         END IF;

      --x_transaction_id:=p_transaction_rec.transaction_id;
      -- invoke table handler(csi_transactions_pkg.insert_row)
     IF l_create_flag ='Y' THEN
          p_transaction_rec.object_version_number:=1;
      csi_transactions_pkg.insert_row(
          px_transaction_id             => p_transaction_rec.transaction_id,
          p_transaction_date            => l_transaction_date,
          p_source_transaction_date     => p_transaction_rec.source_transaction_date,
          p_transaction_type_id         => p_transaction_rec.transaction_type_id,
          p_txn_sub_type_id             => p_transaction_rec.txn_sub_type_id,
          p_source_group_ref_id         => p_transaction_rec.source_group_ref_id,
          p_source_group_ref            => p_transaction_rec.source_group_ref,
          p_source_header_ref_id        => p_transaction_rec.source_header_ref_id,
          p_source_header_ref           => p_transaction_rec.source_header_ref,
          p_source_line_ref_id          => p_transaction_rec.source_line_ref_id,
          p_source_line_ref             => p_transaction_rec.source_line_ref,
          p_source_dist_ref_id1         => p_transaction_rec.source_dist_ref_id1,
          p_source_dist_ref_id2         => p_transaction_rec.source_dist_ref_id2,
          p_inv_material_transaction_id => p_transaction_rec.inv_material_transaction_id,
          p_transaction_quantity        => p_transaction_rec.transaction_quantity,
          p_transaction_uom_code        => p_transaction_rec.transaction_uom_code,
          p_transacted_by               => p_transaction_rec.transacted_by,
          p_transaction_status_code     => p_transaction_rec.transaction_status_code,
          p_transaction_action_code     => p_transaction_rec.transaction_action_code,
          p_message_id                  => p_transaction_rec.message_id,
          p_context                     => p_transaction_rec.context,
          p_attribute1                  => p_transaction_rec.attribute1,
          p_attribute2                  => p_transaction_rec.attribute2,
          p_attribute3                  => p_transaction_rec.attribute3,
          p_attribute4                  => p_transaction_rec.attribute4,
          p_attribute5                  => p_transaction_rec.attribute5,
          p_attribute6                  => p_transaction_rec.attribute6,
          p_attribute7                  => p_transaction_rec.attribute7,
          p_attribute8                  => p_transaction_rec.attribute8,
          p_attribute9                  => p_transaction_rec.attribute9,
          p_attribute10                 => p_transaction_rec.attribute10,
          p_attribute11                 => p_transaction_rec.attribute11,
          p_attribute12                 => p_transaction_rec.attribute12,
          p_attribute13                 => p_transaction_rec.attribute13,
          p_attribute14                 => p_transaction_rec.attribute14,
          p_attribute15                 => p_transaction_rec.attribute15,
          p_created_by                  => fnd_global.user_id,
          p_creation_date               => SYSDATE,
          p_last_updated_by             => fnd_global.user_id,
          p_last_update_date            => SYSDATE,
          p_last_update_login           => fnd_global.conc_login_id,
          p_object_version_number       => p_transaction_rec.object_version_number,
          p_split_reason_code           => p_transaction_rec.split_reason_code,
          p_gl_interface_status_code    => p_transaction_rec.gl_interface_status_code
          );

        END IF;
      -- hint: primary key should be returned.
      -- x_transaction_id := px_transaction_id;
            --p_transaction_rec.transaction_id := px_transaction_id;

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      --
      -- end of api body
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                   ROLLBACK TO create_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                   ROLLBACK TO create_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                    (p_count => x_msg_count ,
                     p_data => x_msg_data
                     );

          WHEN OTHERS THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                   ROLLBACK TO create_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );


END create_transaction;


/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to update transactions                             --- */
/* ---  and call table handler after performing all the validations               --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE update_transactions(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2              := fnd_api.g_false,
    p_commit                     IN   VARCHAR2              := fnd_api.g_false,
    p_validation_level           IN   NUMBER                := fnd_api.g_valid_level_full,
    p_transaction_rec            IN   csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )

 IS
CURSOR lock_csr (p_transaction_rec     IN    csi_datastructures_pub.transaction_rec) IS
    SELECT object_version_number
    FROM   csi_transactions
    WHERE  transaction_id = p_transaction_rec.transaction_id
    FOR UPDATE OF object_version_number;


l_api_name                  CONSTANT VARCHAR2(30) := 'update_transactions';
l_api_version               CONSTANT NUMBER       := 1.0;
-- local variables
l_tar_transaction_rec      csi_datastructures_pub.transaction_rec := p_transaction_rec;
l_row_notfound              BOOLEAN := FALSE;
l_object_version_number     NUMBER;
l_last_update_date          DATE;
l_rowid                     ROWID;
l_debug_level               NUMBER;

 BEGIN
      -- standard start of api savepoint
      IF fnd_api.to_boolean(p_commit)
      THEN
         SAVEPOINT update_transactions_pvt;
      END IF;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;
      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

        l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'update_transactions');
    END IF;
    IF (l_debug_level > 1) THEN
             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_init_msg_list           ||'-'||
                            p_commit                  ||'-'||
                            p_validation_level    );
         csi_gen_utility_pvt.dump_txn_rec(p_transaction_rec);


    END IF;

      --
      -- api body
      --

      OPEN lock_csr (p_transaction_rec);
      FETCH lock_csr INTO l_object_version_number;
      IF ( (l_object_version_number<>p_transaction_rec.object_version_number)
         AND (p_transaction_rec.object_version_number <> fnd_api.g_miss_num) ) THEN
         fnd_message.set_name('CSI', 'CSI_RECORD_CHANGED');
          fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF lock_csr%NOTFOUND THEN
        fnd_message.set_name('CSI', 'CSI_RECORD_LOCKED');
         fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE lock_csr;

      -- invoke validation procedures

     validate_transaction_id (
        p_init_msg_list    => fnd_api.g_false,
        p_validation_mode  => 'UPDATE',
        p_transaction_id   => p_transaction_rec.transaction_id,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

       IF x_return_status=fnd_api.g_ret_sts_success THEN
        validate_object_version_num (
        p_init_msg_list             => fnd_api.g_false,
        p_validation_mode           => 'UPDATE',
        p_object_version_number     => p_transaction_rec.object_version_number,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data);
       END IF;

      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;

         IF p_transaction_rec.gl_interface_status_code IS NOT NULL AND
            p_transaction_rec.gl_interface_status_code <> FND_API.G_MISS_NUM AND
            p_transaction_rec.gl_interface_status_code NOT IN (1,2,3)
           THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_GL_STATUS');
             FND_MESSAGE.SET_TOKEN('STATUS_CODE',p_transaction_rec.gl_interface_status_code);
             FND_MSG_PUB.Add;
             RAISE fnd_api.g_exc_error;
         END IF;

      -- invoke table handler(csi_transactions_pkg.update_row)
      csi_transactions_pkg.update_row(
        p_transaction_id           => p_transaction_rec.transaction_id,
        p_transaction_status_code  => p_transaction_rec.transaction_status_code,
        p_transaction_action_code  => p_transaction_rec.transaction_action_code,
        p_source_group_ref         => p_transaction_rec.source_group_ref,
        p_source_group_ref_id      => p_transaction_rec.source_group_ref_id,
        p_source_dist_ref_id2      => p_transaction_rec.source_dist_ref_id2,
        p_source_header_ref        => p_transaction_rec.source_header_ref,
        p_source_header_ref_id     => p_transaction_rec.source_header_ref_id,
        p_source_line_ref          => p_transaction_rec.source_line_ref,
        p_source_line_ref_id       => p_transaction_rec.source_line_ref_id,
        p_last_updated_by          => fnd_global.user_id,
        p_last_update_date         => SYSDATE,
        p_last_update_login        => fnd_global.conc_login_id,
        p_object_version_number    => p_transaction_rec.object_version_number,
        p_gl_interface_status_code => p_transaction_rec.gl_interface_status_code);
      --
      -- end of api body.
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                   ROLLBACK TO update_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                   ROLLBACK TO update_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                    (p_count => x_msg_count ,
                     p_data => x_msg_data
                     );

          WHEN OTHERS THEN
                IF fnd_api.to_boolean(p_commit)
                THEN
                   ROLLBACK TO update_transactions_pvt;
                END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                      END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END update_transactions;

/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to insert records into csi_txn_errors              --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE create_txn_error
 (
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2              := fnd_api.g_false,
    p_commit                     IN   VARCHAR2              := fnd_api.g_false,
    p_validation_level           IN   NUMBER                := fnd_api.g_valid_level_full,
    p_txn_error_rec              IN   csi_datastructures_pub.transaction_error_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_transaction_error_id       OUT NOCOPY  NUMBER
 ) IS
l_api_name                CONSTANT    VARCHAR2(30)          := 'create_txn_error';
l_api_version             CONSTANT    NUMBER                := 1.0;
l_return_status_full                  VARCHAR2(1);
l_access_flag                         VARCHAR2(1);
l_debug_level                         NUMBER;

BEGIN
 -- standard start of api savepoint
      IF fnd_api.to_boolean(p_commit)
      THEN
        SAVEPOINT create_txn_error_pvt;
      END IF;
      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

       -- initialize api return status TO success
      x_return_status := fnd_api.g_ret_sts_success;

   /***** COMMENTED   l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'create_txn_error');
    END IF;
    IF (l_debug_level > 1) THEN
             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_init_msg_list           ||'-'||
                            p_commit                  ||'-'||
                            p_validation_level    );

         -- dump the txn error records
         csi_gen_utility_pvt.dump_txn_error_rec(p_txn_error_rec);


    END IF; **** END OF COMMENT *****/

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
      END IF;

      /* End of addition for 11.5.10 */

      -- invoke table handler(csi_txn_errors_pkg.insert_row)
      csi_txn_errors_pkg.insert_row(
          px_transaction_error_id       => x_transaction_error_id,
          p_transaction_id              => p_txn_error_rec.transaction_id,
          p_message_id                  => p_txn_error_rec.message_id,
          p_error_text                  => p_txn_error_rec.error_text,
          p_source_type                 => p_txn_error_rec.source_type,
          p_source_id                   => p_txn_error_rec.source_id,
          p_processed_flag              => p_txn_error_rec.processed_flag,
          p_created_by                  => fnd_global.user_id,
          p_creation_date               => SYSDATE,
          p_last_updated_by             => fnd_global.user_id,
          p_last_update_date            => SYSDATE,
          p_last_update_login           => fnd_global.conc_login_id,
          p_object_version_number       => 1,
          p_transaction_type_id         => p_txn_error_rec.transaction_type_id ,
          p_source_group_ref            => p_txn_error_rec.source_group_ref,
          p_source_group_ref_id         => p_txn_error_rec.source_group_ref_id,
          p_source_header_ref           => p_txn_error_rec.source_header_ref,
          p_source_header_ref_id        => p_txn_error_rec.source_header_ref_id,
          p_source_line_ref             => p_txn_error_rec.source_line_ref,
          p_source_line_ref_id          => p_txn_error_rec.source_line_ref_id,
          p_source_dist_ref_id1         => p_txn_error_rec.source_dist_ref_id1,
          p_source_dist_ref_id2         => p_txn_error_rec.source_dist_ref_id2,
          p_inv_material_transaction_id	=> p_txn_error_rec.inv_material_transaction_id,
	  p_error_stage			=> p_txn_error_rec.error_stage,
	  p_message_string		=> p_txn_error_rec.message_string,
          p_instance_id                 => p_txn_error_rec.instance_id,
          p_inventory_item_id           => p_txn_error_rec.inventory_item_id,
          p_serial_number               => p_txn_error_rec.serial_number,
          p_lot_number                  => p_txn_error_rec.lot_number,
          p_transaction_error_date      => p_txn_error_rec.transaction_error_date,
          p_src_serial_num_ctrl_code    => p_txn_error_rec.src_serial_num_ctrl_code,
          p_src_location_ctrl_code      => p_txn_error_rec.src_location_ctrl_code,
          p_src_lot_ctrl_code           => p_txn_error_rec.src_lot_ctrl_code,
          p_src_rev_qty_ctrl_code       => p_txn_error_rec.src_rev_qty_ctrl_code,
          p_dst_serial_num_ctrl_code    => p_txn_error_rec.dst_serial_num_ctrl_code,
          p_dst_location_ctrl_code      => p_txn_error_rec.dst_location_ctrl_code,
          p_dst_lot_ctrl_code           => p_txn_error_rec.dst_lot_ctrl_code,
          p_dst_rev_qty_ctrl_code       => p_txn_error_rec.dst_rev_qty_ctrl_code,
          p_comms_nl_trackable_flag     => p_txn_error_rec.comms_nl_trackable_flag);
      -- hint: primary key should be returned.
      -- x_transaction_error_id := px_transaction_error_id;

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      --
      -- end of api body
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
              IF fnd_api.to_boolean(p_commit)
              THEN
                ROLLBACK TO create_txn_error_pvt;
              END IF;
                        x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
              IF fnd_api.to_boolean(p_commit)
              THEN
                ROLLBACK TO create_txn_error_pvt;
              END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                    (p_count => x_msg_count ,
                     p_data => x_msg_data
                     );

          WHEN OTHERS THEN
              IF fnd_api.to_boolean(p_commit)
              THEN
                ROLLBACK TO create_txn_error_pvt;
              END IF;
                        x_return_status := fnd_api.g_ret_sts_unexp_error ;
                      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                      END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );


END create_txn_error;

/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to validate transaction_id                         --- */
/* ---  1. for validation_mode='CREATE' return success or no validation           --- */
/* ---  2. for validation_mode='UPDATE' check for not null and validate against   --- */
/* ---     csi_transactions table                                                 --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE validate_transaction_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_transaction_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status TO success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column

      IF(p_validation_mode ='CREATE') THEN
                 x_return_status := fnd_api.g_ret_sts_success;
       ELSIF(p_validation_mode = 'UPDATE') THEN
          IF ( (p_transaction_id IS NULL) OR (p_transaction_id = fnd_api.g_miss_num) ) THEN
             fnd_message.set_name('CSI', 'CSI_TXN_ID_NOT_PASSED');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          ELSE
                 BEGIN
                     SELECT   'x'
                     INTO     l_dummy
                     FROM     csi_transactions
                     WHERE    transaction_id=p_transaction_id;
                 EXCEPTION
                   WHEN no_data_found THEN
                       fnd_message.set_name('CSI', 'CSI_INVALID_TXN_ID');
                       fnd_message.set_token('transaction_id',p_transaction_id);
                       fnd_msg_pub.add;
                           x_return_status := fnd_api.g_ret_sts_error;
                 END;
          END IF;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_transaction_id;

/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to validate source_transaction_date                --- */
/* ---  1. check for not null and return an error message                         --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE validate_s_transaction_date (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_source_transaction_date    IN   DATE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF ( (p_source_transaction_date IS NULL) OR (p_source_transaction_date = fnd_api.g_miss_date) ) THEN
              fnd_message.set_name('CSI', 'CSI_NO_TXN_DATE');
              fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_s_transaction_date;


/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to validate transaction_type_id                    --- */
/* ---  1. for null return error status                                           --- */
/* ---  2. for not null check for the exsistence in the csi_txn_types table       --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE validate_transaction_type_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_transaction_type_id        IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column

         IF ( (p_transaction_type_id IS NULL) OR (p_transaction_type_id = fnd_api.g_miss_num) ) THEN
                fnd_message.set_name('CSI', 'CSI_NO_TXN_TYPE_ID');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
         ELSE
               BEGIN
                    SELECT  'x'
                    INTO    l_dummy
                    FROM    csi_txn_types
                    WHERE   transaction_type_id=p_transaction_type_id;

                   EXCEPTION
                   WHEN no_data_found THEN
                                fnd_message.set_name('CSI', 'CSI_INVALID_TXN_TYPE_ID');
                                fnd_msg_pub.add;
                                x_return_status := fnd_api.g_ret_sts_error;
               END;
     END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END validate_transaction_type_id;


/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to validate source_object_code                     --- */
/* ---  1. validation will only be performed if source_line_ref_id is passed      --- */
/* ---  2. check for existence of a record if not exsist then return error        --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE validate_source_object (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_transaction_type_id        IN   NUMBER,
    p_source_line_ref_id         IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
 CURSOR c_ref_csr (p_object_code IN VARCHAR2) IS
    SELECT select_id
          ,select_name
          ,from_table
          ,where_clause
    FROM   jtf_objects_vl jov,jtf_object_usages jou
    WHERE  jov.object_code = p_object_code
    AND    jov.object_code = jou.object_code
    AND    jou.object_user_code = 'CSI_TXN';

l_source_ln_ref_id                    NUMBER;
l_source_code                         VARCHAR2(30);
l_id_column                           VARCHAR2(200);
l_name_column                         VARCHAR2(200);
l_FROM_clause                         VARCHAR2(200);
l_where_clause                        VARCHAR2(2000);
l_flag                                VARCHAR2(1):='f';
sql_stmt                              VARCHAR2(2000):='';
l_object_name                         VARCHAR2(80);
l_object_id                           NUMBER;
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;
            BEGIN
                BEGIN
                IF ( (p_source_line_ref_id IS NOT NULL) AND (p_source_line_ref_id <> fnd_api.g_miss_num) ) THEN
                l_flag:='t';
                END IF;
                SELECT source_object_code
                INTO   l_source_code
                FROM   csi_txn_types
                WHERE  transaction_type_id=p_transaction_type_id;
                EXCEPTION
                  WHEN no_data_found THEN
                       l_flag:='f';
                END;

                BEGIN
                  IF ( (l_flag='t') AND (l_source_code IS NOT NULL) ) THEN
                        OPEN c_ref_csr(l_source_code);
                        FETCH c_ref_csr INTO l_id_column,
                                             l_name_column,
                                             l_from_clause,
                                             l_where_clause;

                        IF c_ref_csr%notfound
                        THEN
                        fnd_message.set_name ('CSI', 'CSI_INVALID_OBJECT_CODE');
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                        END IF;

                        IF x_return_status <> fnd_api.g_ret_sts_error THEN
                          IF(l_where_clause IS NULL) THEN
                             l_where_clause := ' WHERE ';
                          ELSE
                          l_where_clause := l_where_clause || ' AND ';
                          END IF;

                           sql_stmt :=  ' SELECT ' ||
                                        l_name_column ||
                                        ' , ' ||
                                        l_id_column ||
                                        ' FROM ' ||
                                        l_FROM_clause ||
                                        l_where_clause ||
                                        l_id_column ||
                                        ' = :source_line_ref_id ';

                            EXECUTE IMMEDIATE sql_stmt
                            INTO l_object_name, l_object_id
                            USING p_source_line_ref_id;
                          END IF;

                         CLOSE c_ref_csr;

                     END IF;
                   EXCEPTION
                   WHEN no_data_found THEN
                                fnd_message.set_name('CSI', 'CSI_REF_NOT_FOUND');
                                fnd_msg_pub.add;
                                x_return_status := fnd_api.g_ret_sts_error;

               END;
         END;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END validate_source_object;


/* ---------------------------------------------------------------------------------- */
/* ---  this procedure is used to validate transaction_id                         --- */
/* ---  1. for validation_mode='CREATE' return success or no validation           --- */
/* ---  2. for validation_mode='UPDATE' check for not null and validate against   --- */
/* ---     csi_transactions table                                                 --- */
/* ---------------------------------------------------------------------------------- */


PROCEDURE validate_object_version_num (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_object_version_number      IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

       IF(p_validation_mode = 'UPDATE') THEN
          IF ( (p_object_version_number IS NULL) OR (p_object_version_number = fnd_api.g_miss_num) ) THEN
             fnd_message.set_name('CSI', 'CSI_MISSING_OBJ_VER_NUM');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_object_version_num;

/* ---------------------------------------------------------------------------------- */
/* ---  This local procedure is used to validate                                  --- */
/* ---  the split_reason_code passed                                              --- */
/* ---------------------------------------------------------------------------------- */

PROCEDURE validate_split_code (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_split_reason_code          IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER  ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column

         IF ( (p_split_reason_code IS NOT NULL) AND (p_split_reason_code <> fnd_api.g_miss_char) ) THEN
               BEGIN
                    SELECT  'x'
                    INTO    l_dummy
                    FROM    csi_lookups
                    WHERE   lookup_type='CSI_SPLIT_REASON_CODE'
                    AND     lookup_code=p_split_reason_code;
               EXCEPTION
                 WHEN no_data_found THEN
                      fnd_message.set_name('CSI', 'CSI_INVALID_REASON_CODE');
                      fnd_msg_pub.add;
                      x_return_status := fnd_api.g_ret_sts_error;
               END;
         END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END validate_split_code;


/* ---------------------------------------------------------------------------------- */
/* ---  This procedure is used to call all validation transactions like           --- */
/* ---  1. transaction_id                                                         --- */
/* ---  2. source_transaction_id                                                  --- */
/* ---  3. transaction_type_id                                                    --- */
/* ---------------------------------------------------------------------------------- */



PROCEDURE validate_transactions(
    p_init_msg_list              IN   VARCHAR2      := fnd_api.g_false,
    p_validation_level           IN   NUMBER        := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2,
    p_transaction_rec            IN   csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'validate_transactions';
 BEGIN
      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
           validate_transaction_id(
              p_init_msg_list               => fnd_api.g_false,
              p_validation_mode             => p_validation_mode,
              p_transaction_id              => p_transaction_rec.transaction_id,
              x_return_status               => x_return_status,
              x_msg_count                   => x_msg_count,
              x_msg_data                    => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;


          validate_s_transaction_date(
              p_init_msg_list               => fnd_api.g_false,
              p_source_transaction_date     => p_transaction_rec.source_transaction_date,
              x_return_status               => x_return_status,
              x_msg_count                   => x_msg_count,
              x_msg_data                    => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_transaction_type_id(
              p_init_msg_list               => fnd_api.g_false,
              p_transaction_type_id         => p_transaction_rec.transaction_type_id,
              x_return_status               => x_return_status,
              x_msg_count                   => x_msg_count,
              x_msg_data                    => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_source_object(
              p_init_msg_list               => fnd_api.g_false,
              p_transaction_type_id         => p_transaction_rec.transaction_type_id,
              p_source_line_ref_id          => p_transaction_rec.source_line_ref_id,
              x_return_status               => x_return_status,
              x_msg_count                   => x_msg_count,
              x_msg_data                    => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;


          validate_split_code(
              p_init_msg_list               => fnd_api.g_false,
              p_split_reason_code           => p_transaction_rec.split_reason_code,
              x_return_status               => x_return_status,
              x_msg_count                   => x_msg_count,
              x_msg_data                    => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;


      END IF;

END validate_transactions;

END csi_transactions_pvt;

/
