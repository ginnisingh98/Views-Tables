--------------------------------------------------------
--  DDL for Package Body CSI_ML_INTERFACE_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_INTERFACE_TXN_PVT" AS
-- $Header: csimtxnb.pls 120.15.12010000.6 2010/04/05 21:10:00 devijay ship $

PROCEDURE instance_exists(p_inst_interface_id IN NUMBER,
                          x_instance_id OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_error_message OUT NOCOPY VARCHAR2) IS

 l_instance_id NUMBER;
 l_serial_code NUMBER;
 l_fnd_unexpected   VARCHAR2(1);
 e_exists EXCEPTION;
 CURSOR instance_id_cur(p_interface_id IN NUMBER) IS
  SELECT instance_id FROM csi_instance_interface
  WHERE inst_interface_id = p_interface_id;

 CURSOR serial_cur(p_interface_id IN NUMBER) IS
   SELECT cii.instance_id
   FROM csi_item_instances csi,
        csi_instance_interface cii
   WHERE cii.inst_interface_id = p_interface_id
   AND   csi.inventory_item_id = cii.inventory_item_id
   AND   csi.serial_number = cii.serial_number;

 CURSOR nonserial_cur(p_interface_id IN NUMBER) IS
   SELECT a.instance_id
   FROM   csi_item_instances a,
          csi_i_parties b,
          csi_instance_interface c,
          csi_i_party_interface d
   WHERE  a.instance_id = b.instance_id
   AND    a.inventory_item_id = c.inventory_item_id
   AND    c.inst_interface_id = d.inst_interface_id
   AND    c.inst_interface_id = p_interface_id
   AND    a.instance_usage_code NOT IN ('IN_RELATIONSHIP','RETURNED')
   AND    ( (a.inventory_revision IS NULL AND c.inventory_revision IS NULL) OR (a.inventory_revision IS NULL AND c.inventory_revision = FND_API.G_MISS_CHAR) OR (a.inventory_revision = c.inventory_revision))
   AND    ( (a.lot_number IS NULL AND c.lot_number IS NULL) OR (a.lot_number IS NULL AND c.lot_number = FND_API.G_MISS_CHAR) OR (a.lot_number = c.lot_number))
   AND    a.inv_organization_id  = c.inv_organization_id
   AND    a.inv_subinventory_name = c.inv_subinventory_name
   AND    ( (a.inv_locator_id IS NULL AND c.inv_locator_id IS NULL) OR (a.inv_locator_id IS NULL AND c.inv_locator_id = FND_API.G_MISS_NUM) OR (a.inv_locator_id = c.inv_locator_id))
   AND    b.party_id  = d.party_id
   AND    b.party_source_table  = d.party_source_table
   AND    b.relationship_type_code = 'OWNER';

   CURSOR serial_control_cur(p_interface_id IN NUMBER) IS
       select msi.serial_number_control_code
       from   mtl_system_items msi,
              csi_instance_interface cii
       where  msi.inventory_item_id = cii.inventory_item_id
       and    msi.organization_id   = cii.inv_organization_id
       and    cii.inst_interface_id = p_interface_id;

BEGIN
 l_fnd_unexpected   := FND_API.G_RET_STS_UNEXP_ERROR;
 x_return_status := 'E'; --fnd_api.g_ret_sts_success;
 x_error_message := NULL;
 OPEN instance_id_cur(p_inst_interface_id);
 FETCH instance_id_cur INTO l_instance_id;
 CLOSE instance_id_cur;
 IF l_instance_id IS NOT NULL
 THEN
  RAISE e_exists;
 END IF;
 x_instance_id := l_instance_id;
 EXCEPTION
    WHEN e_exists THEN
     x_instance_id := l_instance_id;
     x_return_status := fnd_api.g_ret_sts_success;
    WHEN others THEN
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME','CSI_ML_INTERFACE_TXNS_PVT.INSTANCE_EXISTS');
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := l_fnd_unexpected;

END instance_exists;

 PROCEDURE check_rel_exists(p_subect_id IN NUMBER,
                            p_object_id IN NUMBER,
                            x_exists OUT NOCOPY BOOLEAN,
                            x_relation_rec OUT NOCOPY csi_datastructures_pub.ii_relationship_rec) IS
  CURSOR rel_cur(p_sub_id IN NUMBER,
                 p_ob_id IN NUMBER) IS
  SELECT *
  FROM csi_ii_relationships
  WHERE subject_id = p_sub_id
  AND   object_id = p_ob_id;
  t_rel_rec rel_cur%ROWTYPE;
  l_debug_level  NUMBER := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));
 BEGIN
  x_exists := FALSE;
  OPEN rel_cur(p_subect_id,p_object_id);
  FETCH rel_cur INTO t_rel_rec;
   IF rel_cur%FOUND
   THEN x_exists := TRUE;
   x_relation_rec.relationship_id := t_rel_rec.relationship_id;
   IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'relationship exists: '||t_rel_rec.relationship_id);
  END IF;
   x_relation_rec.relationship_type_code := t_rel_rec.relationship_type_code;
   x_relation_rec.active_start_date:= t_rel_rec.active_start_date;
   x_relation_rec.active_end_date:= t_rel_rec.active_end_date;
   x_relation_rec.object_version_number := t_rel_rec.object_version_number;
   x_relation_rec.display_order:= t_rel_rec.display_order;
   x_relation_rec.position_reference:= t_rel_rec.position_reference;
   END IF;
  CLOSE rel_cur;
 EXCEPTION
 WHEN OTHERS
 THEN x_exists:=FALSE;
 END check_rel_exists;

PROCEDURE process_iface_txns(x_return_status  OUT NOCOPY VARCHAR2 ,
                             x_error_message  OUT NOCOPY VARCHAR2 ,
                             p_txn_from_date  IN         VARCHAR2 ,
                             p_txn_to_date    IN         VARCHAR2 ,
                             p_source_system_name IN     VARCHAR2,
                             p_batch_name     IN         VARCHAR2,
                             p_resolve_ids    IN         VARCHAR2) IS
 l_api_version NUMBER:=1.0;
 l_return_status VARCHAR2(1);
 l_msg_index     NUMBER;
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);
 l_error_message VARCHAR2(2000);
 l_instance_id    NUMBER;
 l_def_usage_code VARCHAR2(30) := 'OUT_OF_ENTERPRISE';
 c_instance_tbl          csi_datastructures_pub.instance_tbl;
 c_ext_attrib_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
 c_party_tbl             csi_datastructures_pub.party_tbl;
 c_party_contact_tbl     csi_ml_util_pvt.party_contact_tbl_type;
 c_account_tbl           csi_datastructures_pub.party_account_tbl;
 c_price_tbl             csi_datastructures_pub.pricing_attribs_tbl;
 c_org_assign_tbl        csi_datastructures_pub.organization_units_tbl;
 c_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
 c_txn_tbl               csi_datastructures_pub.transaction_tbl;
 c_rel_txn_rec           csi_datastructures_pub.transaction_rec;
 c_grp_error_tbl         csi_datastructures_pub.grp_error_tbl;

 u_instance_tbl          csi_datastructures_pub.instance_tbl;
 u_ext_attrib_tbl        csi_datastructures_pub.extend_attrib_values_tbl;
 u_party_tbl             csi_datastructures_pub.party_tbl;
 u_account_tbl           csi_datastructures_pub.party_account_tbl;
 u_price_tbl             csi_datastructures_pub.pricing_attribs_tbl;
 u_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
 u_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
 u_txn_rec               csi_datastructures_pub.transaction_rec;
 u_rel_txn_rec           csi_datastructures_pub.transaction_rec;
 u_grp_error_tbl         csi_datastructures_pub.grp_upd_error_tbl;
 u_instance_id_lst       csi_datastructures_pub.id_tbl;

 g_exc_error             EXCEPTION;
 g_inst_error            EXCEPTION;
 g_upd_error            EXCEPTION;

 l_found                 NUMBER:=0;
 l_rel_success_count     NUMBER:=0;
 l_rel_failure_count     NUMBER:=0;
 l_counter               NUMBER:=0;


 c_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
 u_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
 l_rel_rec               csi_datastructures_pub.ii_relationship_rec;
 l_exists                BOOLEAN;
   inst_idx                PLS_INTEGER;
   prty_idx                PLS_INTEGER;
   ptyacc_idx              PLS_INTEGER;
   extatt_idx              PLS_INTEGER;
   orgass_idx              PLS_INTEGER;
   price_idx               PLS_INTEGER;
   rel_idx                 PLS_INTEGER;
   prty_contact_idx        PLS_INTEGER;
   u_inst_idx              PLS_INTEGER;  --Added for open
   asset_idx               PLS_INTEGER;  -- Asset Index

   l_debug_level           NUMBER:= to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));


   l_commit VARCHAR2(1) ;
   l_init_msg_list VARCHAR2(1);
   l_validation_level NUMBER;
   l_fnd_success           VARCHAR2(1);
   l_fnd_unexpected        VARCHAR2(1);
   l_fnd_g_char            VARCHAR2(1);
   l_fnd_g_num             NUMBER;
   l_fnd_g_date            DATE ;
   l_fnd_g_true            VARCHAR2(1);
   l_api_name              VARCHAR2(255):=
                               'CSI_ML_INTERFACE_TXN_PVT.PROCESS_IFACE_TXN';
   l_txn_type_id           NUMBER;
   g_int_party             NUMBER;
   l_txn_count             NUMBER:=0;
   l_success_count         NUMBER:=0;
   l_failure_count         NUMBER:=0;
   -- Bug 9526806
   l_txn_from_date         DATE := trunc(to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS'));
   l_txn_to_date           DATE := trunc(to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS'));

 -- Bug 9526806
 CURSOR get_txns_cur( p_source_system IN VARCHAR2,
                      p_batch IN VARCHAR2) IS
  SELECT distinct transaction_identifier
  FROM   csi_instance_interface cii
  WHERE  (NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch,cii.batch_name)
          OR NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch,'$CSI_NULL_VALUE$'))
  AND    cii.source_system_name = p_source_system
  AND    trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
  AND    cii.process_status = 'R';

 CURSOR iface_det_cur(p_txn_ident IN VARCHAR2,
                      p_source_system IN VARCHAR2) IS
  SELECT cii.*
  FROM   csi_instance_interface cii
  WHERE  cii.transaction_identifier = p_txn_ident
  AND    cii.source_system_name = p_source_system
  AND    cii.process_status = 'R';

 CURSOR iparty_det_cur(p_inst_interface_id IN NUMBER) IS
  SELECT cpi.*
  FROM   csi_i_party_interface cpi
  WHERE  cpi.inst_interface_id = p_inst_interface_id;

 CURSOR ieav_det_cur(p_inst_interface_id IN NUMBER) IS
  SELECT ci.*
  FROM   csi_iea_value_interface ci
  WHERE  ci.inst_interface_id = p_inst_interface_id;

CURSOR iasset_iface_cur(p_inst_interface_id IN NUMBER) IS
  SELECT cia.*
  FROM   csi_i_asset_interface cia
  WHERE  cia.inst_interface_id = p_inst_interface_id; --bnarayan added for open interfaces R12


 /*CURSOR irel_det_cur(p_txn_ident IN VARCHAR2,
                     p_source_system IN VARCHAR2) IS
 SELECT ciri.relationship_type_code relationship_type_code,
        ciri.subject_interface_id subject_interface_id,
        ciri.object_interface_id  object_interface_id,
        ciri.position_reference position_reference,
        ciri.relationship_start_date active_start_date,
        ciri.relationship_end_date active_end_date,
        ciri.display_order display_order,
        ciri.mandatory_flag mandatory_flag,
        ciri.context context,
        ciri.attribute1 attribute1,
        ciri.attribute2 attribute2,
        ciri.attribute3 attribute3,
        ciri.attribute4 attribute4,
        ciri.attribute5 attribute5,
        ciri.attribute6 attribute6,
        ciri.attribute7 attribute7,
        ciri.attribute8 attribute8,
        ciri.attribute9 attribute9,
        ciri.attribute10 attribute10,
        ciri.attribute11 attribute11,
        ciri.attribute12 attribute12,
        ciri.attribute13 attribute13,
        ciri.attribute14 attribute14,
        ciri.attribute15 attribute15,
        ciri.relationship_direction,
        ciri.created_by created_by,
        cii1.instance_id new_subject_id,
        cii2.instance_id new_object_id,
        cii1.source_transaction_date source_transaction_date,
        cii1.transaction_identifier transaction_identifier
 FROM   csi_ii_relation_interface ciri,
        csi_instance_interface cii1,
        csi_instance_interface cii2
 WHERE  ciri.subject_interface_id = cii1.inst_interface_id
 AND    cii1.transaction_identifier = p_txn_ident
 AND    cii1.source_system_name = p_source_system
 AND    ciri.object_interface_id = cii2.inst_interface_id
 AND    cii2.transaction_identifier = p_txn_ident
 AND    cii2.source_system_name = p_source_system
 AND    cii1.process_status IN ('P')
 AND    cii2.process_status IN ('P'); */

 CURSOR irel_det_cur IS
 SELECT ciri.rel_interface_id rel_interface_id,
        ciri.relationship_type_code relationship_type_code,
        ciri.subject_interface_id subject_interface_id,
        ciri.object_interface_id  object_interface_id,
        ciri.position_reference position_reference,
        ciri.relationship_start_date active_start_date,
        ciri.relationship_end_date active_end_date,
        ciri.display_order display_order,
        ciri.mandatory_flag mandatory_flag,
        ciri.context context,
        ciri.attribute1 attribute1,
        ciri.attribute2 attribute2,
        ciri.attribute3 attribute3,
        ciri.attribute4 attribute4,
        ciri.attribute5 attribute5,
        ciri.attribute6 attribute6,
        ciri.attribute7 attribute7,
        ciri.attribute8 attribute8,
        ciri.attribute9 attribute9,
        ciri.attribute10 attribute10,
        ciri.attribute11 attribute11,
        ciri.attribute12 attribute12,
        ciri.attribute13 attribute13,
        ciri.attribute14 attribute14,
        ciri.attribute15 attribute15,
        ciri.relationship_direction,
        ciri.created_by created_by,
        ciri.subject_id subject_id,
        ciri.object_id object_id
 FROM   csi_ii_relation_interface ciri
 WHERE  ciri.process_status IN ('R')
 AND    (nvl(ciri.source_system_name, '$CSI_NULL_VALUE$') = nvl(p_source_system_name, '$CSI_NULL_VALUE$')
         or nvl(ciri.source_system_name, '$CSI_NULL_VALUE$') = nvl(p_source_system_name, ciri.source_system_name)
        )/*Added for 6443959*/;


 CURSOR internal_party_cur IS
 SELECT internal_party_id FROM csi_install_parameters;

PROCEDURE UPDATE_INTERFACE_TBL
   (p_instance_tbl      IN csi_datastructures_pub.instance_tbl
   ,p_grp_error_tbl     IN csi_datastructures_pub.grp_error_tbl)
IS
  --
  l_intf_id_array                 dbms_sql.Number_Table;
  l_error_array                   dbms_sql.Varchar2_Table;
  l_status_array                  dbms_sql.Varchar2_Table;
  l_num_of_rows                   NUMBER;
  l_upd_stmt                      VARCHAR2(2000);
  l_dummy                         NUMBER;
BEGIN
   FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
   LOOP
      IF p_instance_tbl.EXISTS(j) THEN
         l_intf_id_array(j) := p_instance_tbl(j).interface_id;
         IF p_grp_error_tbl(j).error_message IS NOT NULL THEN
         	l_error_array(j) := p_grp_error_tbl(j).error_message;
         ELSIF p_grp_error_tbl(j).error_message IS NULL THEN
         	l_error_array(j) := 'One or more instances with this transaction identifier failed';
         END IF;
         l_status_array(j) := 'E';
      END IF;
   END LOOP;
   --
   IF l_intf_id_array.count > 0 THEN
     BEGIN
        l_upd_stmt := 'UPDATE CSI_INSTANCE_INTERFACE
                     SET error_text = :error_text
                        ,process_status = :status
                     WHERE inst_interface_id = :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_intf_id_array);
        dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
        dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
   END IF;
END UPDATE_INTERFACE_TBL;

PROCEDURE UPDATE_INTERFACE_TBL
   (p_instance_tbl      IN csi_datastructures_pub.instance_tbl
   ,p_grp_upd_error_tbl     IN csi_datastructures_pub.grp_upd_error_tbl)
IS
  --
  l_intf_id_array                 dbms_sql.Number_Table;
  l_error_array                   dbms_sql.Varchar2_Table;
  l_status_array                  dbms_sql.Varchar2_Table;
  l_num_of_rows                   NUMBER;
  l_upd_stmt                      VARCHAR2(2000);
  l_dummy                         NUMBER;
BEGIN
   FOR j IN p_instance_tbl.FIRST .. p_instance_tbl.LAST
   LOOP
      IF p_instance_tbl.EXISTS(j) THEN
         l_intf_id_array(j) := p_instance_tbl(j).interface_id;
         IF p_grp_upd_error_tbl(j).error_message IS NOT NULL THEN
         	l_error_array(j) := p_grp_upd_error_tbl(j).error_message;
         ELSIF p_grp_upd_error_tbl(j).error_message IS NULL THEN
         	l_error_array(j) := 'One or more instances with this transaction identifier failed';
         END IF;
         l_status_array(j) := 'E';
      END IF;
   END LOOP;
   --
   IF l_intf_id_array.count > 0 THEN
     BEGIN
        l_upd_stmt := 'UPDATE CSI_INSTANCE_INTERFACE
                     SET error_text = :error_text
                        ,process_status = :status
                     WHERE inst_interface_id = :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_intf_id_array);
        dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
        dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
   END IF;
END UPDATE_INTERFACE_TBL;

BEGIN
   l_commit  := fnd_api.g_false;
   l_init_msg_list := fnd_api.g_true;
   l_validation_level := fnd_api.g_valid_level_full;
   l_fnd_success     := FND_API.G_RET_STS_SUCCESS;
   l_fnd_unexpected  := FND_API.G_RET_STS_UNEXP_ERROR;
   l_fnd_g_char      := FND_API.G_MISS_CHAR;
   l_fnd_g_num       := FND_API.G_MISS_NUM;
   l_fnd_g_date      := FND_API.G_MISS_DATE;
   l_fnd_g_true      := FND_API.G_TRUE;

    IF(l_debug_level>1) THEN

   FND_File.Put_Line(Fnd_File.LOG,'Process_iface_txns-P_Source_System_Name : '||p_source_system_name);
   FND_File.Put_Line(Fnd_File.LOG,'Process_iface_txns-P_Batch_Name : '||p_batch_name);
   END IF;

   OPEN internal_party_cur;
   FETCH internal_party_cur INTO g_int_party;
   CLOSE internal_party_cur;

   l_txn_type_id := cse_util_pkg.get_txn_type_id('OPEN_INTERFACE','CSI');


   UPDATE CSI_INSTANCE_INTERFACE a
   SET a.instance_id = (SELECT b.instance_id
                        FROM csi_item_instances b
                        WHERE a.instance_number = b.instance_number)
   WHERE a.instance_number IS NOT NULL
   and a.instance_id is null
    AND a.SOURCE_SYSTEM_NAME = nvl(p_source_system_name, a.SOURCE_SYSTEM_NAME); --Added this condition for #6443959


   BEGIN
     fnd_message.set_name('CSI','CSI_INTERFACE_LOC_TYPE_CODE');
     l_error_message := fnd_message.get;

     UPDATE CSI_INSTANCE_INTERFACE cii
     SET    error_text =l_error_message , process_status ='E'
     WHERE (NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,cii.batch_name)
        OR NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,'$CSI_NULL_VALUE$'))
     AND   cii.source_system_name = p_source_system_name
     AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
     AND   cii.process_status = 'R'
     AND   cii.location_type_code in ('INVENTORY','PO','IN_TRANSIT','WIP','PROJECT');

     IF SQL%FOUND THEN
       FND_File.Put_Line(Fnd_File.LOG, l_error_message||' Total Rows in this error : '||SQL%ROWCOUNT );
     END IF;

   END;

   IF NVL(p_resolve_ids,'Y') = 'Y'
   THEN
      IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'Resolving the Ids based on user values ');
     END IF;
     CSI_ML_UTIL_PVT.resolve_ids(p_txn_from_date,
                                 p_txn_to_date,
                                 p_batch_name,
                                 p_source_system_name,
                                 l_return_status,
                                 l_error_message);

      IF NOT l_return_status = l_fnd_success THEN
          IF(l_debug_level>1) THEN
         FND_File.Put_Line(Fnd_File.LOG,'Error Resolving the Ids: ');
         END IF;
         RAISE g_exc_error;
      END IF;
   END IF;

   /*---- This piece of code required resolved ids or IDS for processing ---*/
   BEGIN
       fnd_message.set_name('CSI','CSI_ML_NO_ASSET_FOR_CT');
       l_error_message   := fnd_message.get;

       UPDATE CSI_INSTANCE_INTERFACE cii
       SET    error_text     =l_error_message
              ,process_status ='E'
        WHERE (NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,cii.batch_name)
        OR NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,'$CSI_NULL_VALUE$'))
        AND   cii.source_system_name = p_source_system_name
        AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
        AND   cii.process_status = 'R'
        AND   exists ( SELECT 1
                    FROM   csi_i_party_interface cipi
                           ,csi_i_asset_interface ciai
                     WHERE  cipi.inst_interface_id = ciai.inst_interface_id
                     AND    cipi.inst_interface_id = cii.inst_interface_id
                     AND    nvl(cipi.party_id,0) <> g_int_party
                     AND    cipi.party_relationship_type_code = 'OWNER'
                   );

       IF SQL%FOUND THEN
          IF(l_debug_level>1) THEN
          FND_File.Put_Line(Fnd_File.LOG, l_error_message||' Total Rows in this error : '||SQL%ROWCOUNT );
          END IF;
        END IF;


        fnd_message.set_name('CSI','CSI_NO_ASSET_ASSN_FOUND');
        l_error_message  := fnd_message.get;

        UPDATE CSI_INSTANCE_INTERFACE cii
        SET  error_text      =l_error_message
             ,process_status ='E'
        WHERE (NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,cii.batch_name)
        OR NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,'$CSI_NULL_VALUE$'))
        AND   cii.source_system_name = p_source_system_name
        AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
        AND   cii.process_status = 'R'
        AND   exists (SELECT 1
                         FROM csi_i_asset_interface ciai
                        WHERE cii.inst_interface_id = ciai.inst_interface_id
                          AND ciai.fa_asset_id IS NULL
                          AND ciai.fa_asset_number IS NULL
                         );

        IF SQL%FOUND THEN
           FND_File.Put_Line(Fnd_File.LOG, l_error_message ||' Total Rows in this error : '||SQL%ROWCOUNT);
        END IF;



        fnd_message.set_name('CSI','CSI_API_ASSET_REQUIRED');
        l_error_message  := fnd_message.get;

        UPDATE CSI_INSTANCE_INTERFACE cii
        SET  error_text      =l_error_message
             ,process_status ='E'
        WHERE (NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,cii.batch_name)
        OR NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,'$CSI_NULL_VALUE$'))
        AND   cii.source_system_name = p_source_system_name
        AND   trunc(cii.source_transaction_date) BETWEEN nvl(l_txn_from_date,trunc(cii.source_transaction_date)) AND nvl(l_txn_to_date,trunc(cii.source_transaction_date))
        AND   cii.process_status = 'R'
        AND   cii.location_type_code  IN ('HZ_PARTY_SITES','HZ_LOCATIONS')
        AND   (exists (SELECT 1
                    FROM   csi_i_party_interface cipi
                    WHERE  cipi.inst_interface_id = cii.inst_interface_id
                    AND    nvl(cipi.party_id,0)   = g_int_party
                    AND    cipi.party_relationship_type_code = 'OWNER'
                   )
              AND   not exists (SELECT 1
                                FROM csi_i_asset_interface ciai
                                WHERE  cii.inst_interface_id = ciai.inst_interface_id
                         ));

        IF SQL%FOUND THEN
           FND_File.Put_Line(Fnd_File.LOG, l_error_message ||' Total Rows in this error : '||SQL%ROWCOUNT);
        END IF;

   END;
   l_txn_count := 0;
   FOR get_txns_rec IN get_txns_cur(p_source_system_name,
                                  p_batch_name)
   LOOP
     l_txn_count := l_txn_count +1;
     IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'Started Processing the Transaction Identifier : '||get_txns_rec.transaction_identifier);
     END IF;
     c_instance_tbl.DELETE;
     c_ext_attrib_tbl.DELETE;
     c_party_tbl.DELETE;
     c_party_contact_tbl.DELETE;
     c_account_tbl.DELETE;
     c_price_tbl.DELETE;
     c_org_assign_tbl.DELETE;
     c_asset_assignment_tbl.DELETE;
     c_txn_tbl.DELETE;
     c_grp_error_tbl.DELETE;
     c_rel_txn_rec.transaction_id := NULL;

     u_instance_tbl.DELETE;
     u_ext_attrib_tbl.DELETE;
     u_party_tbl.DELETE;
     u_account_tbl.DELETE;
     u_price_tbl.DELETE;
     u_org_assignments_tbl.DELETE;
     u_asset_assignment_tbl.DELETE;
     u_txn_rec.transaction_id := NULL;
     u_rel_txn_rec.transaction_id := NULL;
     u_grp_error_tbl.DELETE;
     u_instance_id_lst.DELETE;

     BEGIN
       SAVEPOINT s_txnbegin;
       inst_idx              := 1;
       prty_idx              := 1;
       ptyacc_idx            := 1;
       extatt_idx            := 1;
       price_idx             := 1;
       orgass_idx            := 1;
       prty_contact_idx      := 1;
       u_inst_idx            := 1;
       asset_idx             := 1;--Added for open
       FOR iface_det_rec IN iface_det_cur(get_txns_rec.transaction_identifier,
                                           p_source_system_name)
       LOOP
         IF(l_debug_level>1) THEN
         FND_File.Put_Line(Fnd_File.LOG,'Processing Inst_interface_id : '||iface_det_rec.inst_interface_id);
         END IF;
      --to find out whether the instance exists
          instance_exists(iface_det_rec.inst_interface_id,
                          l_instance_id,
                          l_return_status,
                          l_error_message);
           IF NOT l_return_status = l_fnd_success
           THEN -- create item instance

          IF(l_debug_level>1) THEN
           FND_File.Put_Line(Fnd_File.LOG,'Create New Instance CASE:');
           END IF;
           x_return_status       := l_fnd_success;

         c_instance_tbl(inst_idx).INSTANCE_ID       := NULL;
        c_instance_tbl(inst_idx).INSTANCE_NUMBER   := iface_det_rec.INSTANCE_NUMBER;	-- Enhancement  6138587
         c_instance_tbl(inst_idx).INVENTORY_ITEM_ID := iface_det_rec.inventory_item_id;
         c_instance_tbl(inst_idx).INTERFACE_ID := iface_det_rec.inst_interface_id;
         IF iface_det_rec.EXTERNAL_REFERENCE IS NULL THEN
           c_instance_tbl(inst_idx).EXTERNAL_REFERENCE := l_fnd_g_char;
         ELSE
          c_instance_tbl(inst_idx).EXTERNAL_REFERENCE :=
               iface_det_rec.EXTERNAL_REFERENCE ;
         END IF;
-- need to uncomment once the APIs support these fields
         IF iface_det_rec.config_inst_hdr_id IS NULL THEN
            c_instance_tbl(inst_idx).config_inst_hdr_id := l_fnd_g_num;
         ELSE
            c_instance_tbl(inst_idx).config_inst_hdr_id :=
               iface_det_rec.config_inst_hdr_id ;
         END IF;
         IF iface_det_rec.config_inst_rev_num IS NULL THEN
            c_instance_tbl(inst_idx).config_inst_rev_num:= l_fnd_g_num;
         ELSE
            c_instance_tbl(inst_idx).config_inst_rev_num:=
               iface_det_rec.config_inst_rev_num;
         END IF;
         IF iface_det_rec.config_inst_item_id IS NULL THEN
            c_instance_tbl(inst_idx).config_inst_item_id:= l_fnd_g_num;
         ELSE
            c_instance_tbl(inst_idx).config_inst_item_id:=
               iface_det_rec.config_inst_item_id;
         END IF;
         IF iface_det_rec.config_valid_status IS NULL THEN
            c_instance_tbl(inst_idx).config_valid_status:= l_fnd_g_char;
         ELSE
            c_instance_tbl(inst_idx).config_valid_status:=
               iface_det_rec.config_valid_status;
         END IF;
/*
         IF iface_det_rec.inv_vld_organization_id IS NULL THEN
            c_instance_tbl(inst_idx).INV_MASTER_ORGANIZATION_ID := l_fnd_g_num;
         ELSE
            c_instance_tbl(inst_idx).INV_MASTER_ORGANIZATION_ID :=
               iface_det_rec.inv_vld_organization_id;
         END IF;
*/ -- Code commented for bug 3347509

         IF iface_det_rec.inv_vld_organization_id IS NULL THEN
           c_instance_tbl(inst_idx).VLD_ORGANIZATION_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).VLD_ORGANIZATION_ID := iface_det_rec.inv_vld_organization_id;
         END IF;

         IF iface_det_rec.location_type_code IS NULL THEN
           c_instance_tbl(inst_idx).LOCATION_TYPE_CODE := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).LOCATION_TYPE_CODE := iface_det_rec.location_type_code;
         END IF;

         IF iface_det_rec.location_id IS NULL THEN
           c_instance_tbl(inst_idx).LOCATION_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).LOCATION_ID :=  iface_det_rec.location_id;
         END IF;

         IF iface_det_rec.inv_organization_id IS NULL THEN
           c_instance_tbl(inst_idx).INV_ORGANIZATION_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).INV_ORGANIZATION_ID := iface_det_rec.inv_organization_id;
         END IF;

         IF iface_det_rec.inv_subinventory_name IS NULL THEN
           c_instance_tbl(inst_idx).INV_SUBINVENTORY_NAME := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).INV_SUBINVENTORY_NAME :=  iface_det_rec.inv_subinventory_name;
         END IF;

         IF iface_det_rec.inv_locator_id IS NULL THEN
           c_instance_tbl(inst_idx).INV_LOCATOR_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).INV_LOCATOR_ID := iface_det_rec.inv_locator_id;
         END IF;

         IF iface_det_rec.lot_number IS NULL THEN
           c_instance_tbl(inst_idx).LOT_NUMBER := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).LOT_NUMBER := iface_det_rec.lot_number;
         END IF;

         IF iface_det_rec.project_id IS NULL THEN
           c_instance_tbl(inst_idx).PA_PROJECT_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).PA_PROJECT_ID := iface_det_rec.project_id;
         END IF;

         IF iface_det_rec.task_id IS NULL THEN
           c_instance_tbl(inst_idx).PA_PROJECT_TASK_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).PA_PROJECT_TASK_ID := iface_det_rec.task_id;
         END IF;

         IF iface_det_rec.in_transit_order_line_id IS NULL THEN
           c_instance_tbl(inst_idx).IN_TRANSIT_ORDER_LINE_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).IN_TRANSIT_ORDER_LINE_ID := iface_det_rec.in_transit_order_line_id;
         END IF;

         IF iface_det_rec.wip_job_id IS NULL THEN
           c_instance_tbl(inst_idx).WIP_JOB_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).WIP_JOB_ID := iface_det_rec.wip_job_id;
         END IF;

         IF iface_det_rec.po_order_line_id IS NULL THEN
           c_instance_tbl(inst_idx).PO_ORDER_LINE_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).PO_ORDER_LINE_ID := iface_det_rec.po_order_line_id;
         END IF;

         IF iface_det_rec.inventory_revision IS NULL THEN
           c_instance_tbl(inst_idx).INVENTORY_REVISION := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).INVENTORY_REVISION := iface_det_rec.inventory_revision;
         END IF;

         IF iface_det_rec.serial_number IS NULL THEN
           c_instance_tbl(inst_idx).SERIAL_NUMBER  := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).SERIAL_NUMBER := iface_det_rec.serial_number;
         END IF;

         IF iface_det_rec.mfg_serial_number_flag IS NULL THEN
           c_instance_tbl(inst_idx).MFG_SERIAL_NUMBER_FLAG := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).MFG_SERIAL_NUMBER_FLAG := iface_det_rec.mfg_serial_number_flag;
         END IF;

         IF iface_det_rec.quantity IS NULL THEN
           c_instance_tbl(inst_idx).QUANTITY := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).QUANTITY := iface_det_rec.quantity;
         END IF;

         IF iface_det_rec.unit_of_measure_code IS NULL THEN
           c_instance_tbl(inst_idx).UNIT_OF_MEASURE := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).UNIT_OF_MEASURE := iface_det_rec.unit_of_measure_code;
         END IF;

         IF iface_det_rec.accounting_class_code IS NULL THEN
           c_instance_tbl(inst_idx).ACCOUNTING_CLASS_CODE  := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ACCOUNTING_CLASS_CODE := iface_det_rec.accounting_class_code;
         END IF;

         IF iface_det_rec.instance_condition_id IS NULL THEN
           c_instance_tbl(inst_idx).INSTANCE_CONDITION_ID  := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).INSTANCE_CONDITION_ID := iface_det_rec.instance_condition_id;
         END IF;

         IF iface_det_rec.instance_status_id IS NULL THEN
           c_instance_tbl(inst_idx).INSTANCE_STATUS_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).INSTANCE_STATUS_ID := iface_det_rec.instance_status_id;
         END IF;

         IF iface_det_rec.customer_view_flag IS NULL THEN
           c_instance_tbl(inst_idx).CUSTOMER_VIEW_FLAG  := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).CUSTOMER_VIEW_FLAG := iface_det_rec.customer_view_flag;
         END IF;

         IF iface_det_rec.merchant_view_flag IS NULL THEN
           c_instance_tbl(inst_idx).MERCHANT_VIEW_FLAG  := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).MERCHANT_VIEW_FLAG := iface_det_rec.merchant_view_flag;
         END IF;

         IF iface_det_rec.sellable_flag IS NULL THEN
           c_instance_tbl(inst_idx).SELLABLE_FLAG := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).SELLABLE_FLAG := iface_det_rec.sellable_flag;
         END IF;

         IF iface_det_rec.system_id IS NULL THEN
           c_instance_tbl(inst_idx).SYSTEM_ID  := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).SYSTEM_ID := iface_det_rec.system_id ;
         END IF;

         IF iface_det_rec.instance_type_code IS NULL THEN
           c_instance_tbl(inst_idx).INSTANCE_TYPE_CODE := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).INSTANCE_TYPE_CODE := iface_det_rec.instance_type_code;
         END IF;

         IF iface_det_rec.instance_end_date IS NULL THEN
           c_instance_tbl(inst_idx).ACTIVE_END_DATE  := l_fnd_g_date;
         ELSE
           c_instance_tbl(inst_idx).ACTIVE_END_DATE := iface_det_rec.instance_end_date;
         END IF;
 --  Added
         IF iface_det_rec.instance_start_date IS NULL THEN
           c_instance_tbl(inst_idx).ACTIVE_START_DATE  := l_fnd_g_date;
         ELSE
           c_instance_tbl(inst_idx).ACTIVE_START_DATE := iface_det_rec.instance_start_date;
         END IF;

         IF iface_det_rec.oe_order_line_id IS NULL THEN
           c_instance_tbl(inst_idx).last_oe_order_line_id  := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).last_oe_order_line_id := iface_det_rec.oe_order_line_id;
         END IF;

         IF iface_det_rec.oe_rma_line_id IS NULL THEN
           c_instance_tbl(inst_idx).last_oe_rma_line_id  := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).last_oe_rma_line_id := iface_det_rec.oe_rma_line_id;
         END IF;
 -- End addition
        --c_instance_tbl(inst_idx).LAST_OE_ORDER_LINE_ID := l_fnd_g_num;   -- LAST_OE_ORDER_LINE_ID
        --c_instance_tbl(inst_idx).LAST_OE_RMA_LINE_ID   :=l_fnd_g_num;  -- LAST_OE_RMA_LINE_ID
         c_instance_tbl(inst_idx).LAST_PO_PO_LINE_ID    :=l_fnd_g_num;   -- LAST_PO_PO_LINE_ID
         c_instance_tbl(inst_idx).LAST_OE_PO_NUMBER     :=l_fnd_g_char;  -- LAST_OE_PO_NUMBER
         c_instance_tbl(inst_idx).LAST_WIP_JOB_ID       :=l_fnd_g_num;   -- LAST_WIP_JOB_ID
         c_instance_tbl(inst_idx).LAST_PA_PROJECT_ID    := l_fnd_g_num;   -- LAST_PA_PROJECT_ID
         c_instance_tbl(inst_idx).LAST_PA_TASK_ID       :=l_fnd_g_num;   -- LAST_PA_TASK_ID
         c_instance_tbl(inst_idx).LAST_OE_AGREEMENT_ID  :=l_fnd_g_num;   -- LAST_OE_AGREEMENT_ID

         IF iface_det_rec.install_date IS NULL THEN
           c_instance_tbl(inst_idx).install_date := l_fnd_g_date;
         ELSE
           c_instance_tbl(inst_idx).install_date := iface_det_rec.install_date;
         END IF;

         c_instance_tbl(inst_idx).MANUALLY_CREATED_FLAG := l_fnd_g_char;  -- MANUALLY_CREATED_FLAG

         IF iface_det_rec.return_by_date IS NULL THEN
           c_instance_tbl(inst_idx).RETURN_BY_DATE := l_fnd_g_date;
         ELSE
           c_instance_tbl(inst_idx).RETURN_BY_DATE := iface_det_rec.return_by_date;
         END IF;

         IF iface_det_rec.actual_return_date IS NULL THEN
           c_instance_tbl(inst_idx).ACTUAL_RETURN_DATE := l_fnd_g_date;
         ELSE
           c_instance_tbl(inst_idx).ACTUAL_RETURN_DATE := iface_det_rec.actual_return_date;
         END IF;

         c_instance_tbl(inst_idx).CREATION_COMPLETE_FLAG := l_fnd_g_char;  --CREATION_COMPLETE_FLAG
         c_instance_tbl(inst_idx).COMPLETENESS_FLAG := l_fnd_g_char;  --COMPLETENESS_FLAG
         c_instance_tbl(inst_idx).VERSION_LABEL := l_fnd_g_char;  --VERSION_LABEL
         c_instance_tbl(inst_idx).VERSION_LABEL_DESCRIPTION := l_fnd_g_char;  --VERSION_LABEL_DESCRIPTION

         IF iface_det_rec.instance_context IS NULL THEN
           c_instance_tbl(inst_idx).CONTEXT := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).CONTEXT := iface_det_rec.instance_context;
         END IF;

         IF iface_det_rec.instance_attribute1 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE1 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE1 := iface_det_rec.instance_attribute1;
         END IF;

         IF iface_det_rec.instance_attribute2 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE2 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE2 := iface_det_rec.instance_attribute2;
         END IF;

         IF iface_det_rec.instance_attribute3 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE3 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE3 := iface_det_rec.instance_attribute3;
         END IF;

         IF iface_det_rec.instance_attribute4 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE4 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE4 := iface_det_rec.instance_attribute4;
         END IF;

         IF iface_det_rec.instance_attribute5 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE5 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE5 := iface_det_rec.instance_attribute5;
         END IF;

         IF iface_det_rec.instance_attribute6 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE6 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE6 := iface_det_rec.instance_attribute6;
         END IF;

         IF iface_det_rec.instance_attribute7 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE7 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE7 := iface_det_rec.instance_attribute7;
         END IF;

         IF iface_det_rec.instance_attribute8 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE8 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE8 := iface_det_rec.instance_attribute8;
         END IF;

         IF iface_det_rec.instance_attribute9 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE9 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE9 := iface_det_rec.instance_attribute9;
         END IF;

         IF iface_det_rec.instance_attribute10 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE10 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE10 := iface_det_rec.instance_attribute10;
         END IF;

         IF iface_det_rec.instance_attribute11 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE11 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE11 := iface_det_rec.instance_attribute11;
         END IF;

         IF iface_det_rec.instance_attribute12 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE12 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE12:= iface_det_rec.instance_attribute12;
         END IF;

         IF iface_det_rec.instance_attribute13 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE13 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE13:= iface_det_rec.instance_attribute13;
         END IF;

         IF iface_det_rec.instance_attribute14 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE14 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE14:= iface_det_rec.instance_attribute14;
         END IF;

         IF iface_det_rec.instance_attribute15 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE15 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE15 := iface_det_rec.instance_attribute15;
         END IF;

          --Code Addition start for 9045308--
         IF iface_det_rec.instance_attribute16 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE16 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE16 := iface_det_rec.instance_attribute16;
         END IF;

         IF iface_det_rec.instance_attribute17 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE17 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE17 := iface_det_rec.instance_attribute17;
         END IF;

         IF iface_det_rec.instance_attribute18 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE18 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE18 := iface_det_rec.instance_attribute18;
         END IF;

         IF iface_det_rec.instance_attribute19 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE19 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE19 := iface_det_rec.instance_attribute19;
         END IF;

         IF iface_det_rec.instance_attribute20 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE20 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE20 := iface_det_rec.instance_attribute20;
         END IF;

         IF iface_det_rec.instance_attribute21 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE21 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE21 := iface_det_rec.instance_attribute21;
         END IF;

         IF iface_det_rec.instance_attribute22 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE22 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE22 := iface_det_rec.instance_attribute22;
         END IF;

         IF iface_det_rec.instance_attribute23 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE23 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE23 := iface_det_rec.instance_attribute23;
         END IF;

         IF iface_det_rec.instance_attribute24 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE24 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE24 := iface_det_rec.instance_attribute24;
         END IF;

         IF iface_det_rec.instance_attribute25 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE25 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE25 := iface_det_rec.instance_attribute25;
         END IF;

         IF iface_det_rec.instance_attribute26 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE26 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE26 := iface_det_rec.instance_attribute26;
         END IF;

         IF iface_det_rec.instance_attribute27 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE27 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE27 := iface_det_rec.instance_attribute27;
         END IF;

         IF iface_det_rec.instance_attribute28 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE28 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE28 := iface_det_rec.instance_attribute28;
         END IF;

         IF iface_det_rec.instance_attribute29 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE29 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE29 := iface_det_rec.instance_attribute29;
         END IF;

         IF iface_det_rec.instance_attribute30 IS NULL THEN
           c_instance_tbl(inst_idx).ATTRIBUTE30 := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).ATTRIBUTE30 := iface_det_rec.instance_attribute30;
         END IF;
       --Code end for bug9045308--

         c_instance_tbl(inst_idx).OBJECT_VERSION_NUMBER := 1;
         c_instance_tbl(inst_idx).LAST_TXN_LINE_DETAIL_ID := l_fnd_g_num;

         IF iface_det_rec.install_location_type_code IS NULL THEN
           c_instance_tbl(inst_idx).INSTALL_LOCATION_TYPE_CODE := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).INSTALL_LOCATION_TYPE_CODE := iface_det_rec.install_location_type_code;
         END IF;

         IF iface_det_rec.install_location_id IS NULL THEN
           c_instance_tbl(inst_idx).INSTALL_LOCATION_ID := l_fnd_g_num;
         ELSE
           c_instance_tbl(inst_idx).INSTALL_LOCATION_ID := iface_det_rec.install_location_id;
         END IF;



         c_instance_tbl(inst_idx).CHECK_FOR_INSTANCE_EXPIRY := l_fnd_g_true;
         -- Added for bug 3150717
         IF iface_det_rec.instance_description IS NULL THEN
           c_instance_tbl(inst_idx).instance_description := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).instance_description := iface_det_rec.instance_description;
         END IF;
         -- End addition for bug 3150717

         IF iface_det_rec.operational_status_code IS NULL THEN
           c_instance_tbl(inst_idx).operational_status_code := l_fnd_g_char;
         ELSE
           c_instance_tbl(inst_idx).operational_status_code := iface_det_rec.operational_status_code;
         END IF;
       -- If operational_status_code has a value, then copy it to instance_usage_code
       -- else default it to out_of_enterprise
         IF c_instance_tbl(inst_idx).operational_status_code IS NOT NULL AND
            c_instance_tbl(inst_idx).operational_status_code <> l_fnd_g_char
         THEN
           c_instance_tbl(inst_idx).instance_usage_code := iface_det_rec.operational_status_code;
         ELSE
           c_instance_tbl(inst_idx).instance_usage_code := l_def_usage_code;
         END IF;

       FOR iparty_det_rec in iparty_det_cur(iface_det_rec.inst_interface_id) LOOP
         -- Loop and create Party Table

           c_party_tbl(prty_idx).instance_party_id := NULL;
           c_party_tbl(prty_idx).instance_id       := NULL;
           c_party_tbl(prty_idx).parent_tbl_index   := inst_idx;

           IF iparty_det_rec.inst_interface_id IS NULL THEN
              c_party_tbl(prty_idx).interface_id := l_fnd_g_num;
           ELSE
	         c_party_tbl(prty_idx).interface_id := iparty_det_rec.inst_interface_id;
           END IF;

           IF iparty_det_rec.party_source_table IS NULL THEN
	         c_party_tbl(prty_idx).party_source_table := l_fnd_g_char;
           ELSE
	         c_party_tbl(prty_idx).party_source_table := iparty_det_rec.party_source_table;
           END IF;

           IF iparty_det_rec.party_id IS NULL THEN
             c_party_tbl(prty_idx).party_id := l_fnd_g_num;
           ELSE
             c_party_tbl(prty_idx).party_id := iparty_det_rec.party_id;
           END IF;
/*     --  No need for the following code
           IF iparty_det_rec.party_id = g_int_party
           THEN
              c_instance_tbl(inst_idx).instance_usage_code:= 'IN_INVENTORY';
           ELSE
              c_instance_tbl(inst_idx).instance_usage_code:= 'OUT_OF_ENTERPRISE';
           END IF;
*/
           IF iparty_det_rec.party_relationship_type_code IS NULL THEN
             c_party_tbl(prty_idx).relationship_type_code := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).relationship_type_code := iparty_det_rec.party_relationship_type_code;
           END IF;

           c_party_tbl(prty_idx).contact_flag := iparty_det_rec.contact_flag;

           -- Create table with contact Parties
           IF c_party_tbl(prty_idx).contact_flag = 'Y' THEN
             c_party_contact_tbl(prty_contact_idx).ip_interface_id := iparty_det_rec.ip_interface_id;
             c_party_contact_tbl(prty_contact_idx).inst_interface_id := iparty_det_rec.inst_interface_id;
             c_party_contact_tbl(prty_contact_idx).contact_party_id := iparty_det_rec.contact_party_id;
             c_party_contact_tbl(prty_contact_idx).contact_party_number := iparty_det_rec.contact_party_number;
             c_party_contact_tbl(prty_contact_idx).contact_party_name   := iparty_det_rec.contact_party_name;
             c_party_contact_tbl(prty_contact_idx).contact_party_rel_type := iparty_det_rec.contact_party_rel_type;
             c_party_contact_tbl(prty_contact_idx).parent_tbl_idx := prty_idx;
             prty_contact_idx := prty_contact_idx + 1;
           END IF;

           c_party_tbl(prty_idx).contact_ip_id := l_fnd_g_num;
           --c_party_tbl(prty_idx).active_start_date := l_fnd_g_date;
  -- Added
           IF iparty_det_rec.party_start_date IS NULL THEN
             c_party_tbl(prty_idx).active_start_date := l_fnd_g_date;
           ELSE
             c_party_tbl(prty_idx).active_start_date := iparty_det_rec.party_start_date;
           END IF;
  -- End addition
           IF iparty_det_rec.party_end_date IS NULL THEN
             c_party_tbl(prty_idx).active_end_date := l_fnd_g_date;
           ELSE
             c_party_tbl(prty_idx).active_end_date := iparty_det_rec.party_end_date;
           END IF;

           IF iparty_det_rec.party_context IS NULL THEN
             c_party_tbl(prty_idx).context := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).context := iparty_det_rec.party_context;
           END IF;

           IF iparty_det_rec.party_attribute1 IS NULL THEN
             c_party_tbl(prty_idx).attribute1 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute1 := iparty_det_rec.party_attribute1;
           END IF;

           IF iparty_det_rec.party_attribute2 IS NULL THEN
             c_party_tbl(prty_idx).attribute2 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute2 := iparty_det_rec.party_attribute2;
           END IF;

           IF iparty_det_rec.party_attribute3 IS NULL THEN
             c_party_tbl(prty_idx).attribute3 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute3 := iparty_det_rec.party_attribute3;
           END IF;

           IF iparty_det_rec.party_attribute4 IS NULL THEN
             c_party_tbl(prty_idx).attribute4 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute4 := iparty_det_rec.party_attribute4;
           END IF;

           IF iparty_det_rec.party_attribute5 IS NULL THEN
             c_party_tbl(prty_idx).attribute5 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute5 := iparty_det_rec.party_attribute5;
           END IF;

           IF iparty_det_rec.party_attribute6 IS NULL THEN
             c_party_tbl(prty_idx).attribute6 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute6 := iparty_det_rec.party_attribute6;
           END IF;

           IF iparty_det_rec.party_attribute7 IS NULL THEN
             c_party_tbl(prty_idx).attribute7 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute7 := iparty_det_rec.party_attribute7;
           END IF;

           IF iparty_det_rec.party_attribute8 IS NULL THEN
             c_party_tbl(prty_idx).attribute8 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute8 := iparty_det_rec.party_attribute8;
           END IF;

           IF iparty_det_rec.party_attribute8 IS NULL THEN
             c_party_tbl(prty_idx).attribute9 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute9 := iparty_det_rec.party_attribute9;
           END IF;

           IF iparty_det_rec.party_attribute10 IS NULL THEN
             c_party_tbl(prty_idx).attribute10 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute10 := iparty_det_rec.party_attribute10;
           END IF;

           IF iparty_det_rec.party_attribute11 IS NULL THEN
             c_party_tbl(prty_idx).attribute11 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute11 := iparty_det_rec.party_attribute11;
           END IF;

           IF iparty_det_rec.party_attribute12 IS NULL THEN
             c_party_tbl(prty_idx).attribute12 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute12 := iparty_det_rec.party_attribute12;
           END IF;

           IF iparty_det_rec.party_attribute13 IS NULL THEN
             c_party_tbl(prty_idx).attribute13 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute13 := iparty_det_rec.party_attribute13;
           END IF;

           IF iparty_det_rec.party_attribute14 IS NULL THEN
             c_party_tbl(prty_idx).attribute14 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute14 := iparty_det_rec.party_attribute14;
           END IF;

           IF iparty_det_rec.party_attribute15 IS NULL THEN
             c_party_tbl(prty_idx).attribute15 := l_fnd_g_char;
           ELSE
             c_party_tbl(prty_idx).attribute15 := iparty_det_rec.party_attribute15;
           END IF;

           c_party_tbl(prty_idx).OBJECT_VERSION_NUMBER  := 1;     -- OBJECT_VERSION_NUMBER
           c_party_tbl(prty_idx).PRIMARY_FLAG := l_fnd_g_char;    -- PRIMARY_FLAG
           c_party_tbl(prty_idx).PREFERRED_FLAG := l_fnd_g_char;     -- PREFERRED_FLAG

         IF iparty_det_rec.party_account1_id IS NOT NULL THEN -- Put record in Table

            c_account_tbl(ptyacc_idx).ip_account_id     := l_fnd_g_num;
            c_account_tbl(ptyacc_idx).instance_party_id := l_fnd_g_num;
            c_account_tbl(ptyacc_idx).parent_tbl_index  := prty_idx;

            IF iparty_det_rec.party_account1_id IS NULL THEN
              c_account_tbl(ptyacc_idx).party_account_id := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).party_account_id := iparty_det_rec.party_account1_id;
            END IF;

            IF iparty_det_rec.acct1_relationship_type_code IS NULL THEN
              c_account_tbl(ptyacc_idx).relationship_type_code := l_fnd_g_char;
            ELSE
              c_account_tbl(ptyacc_idx).relationship_type_code := iparty_det_rec.acct1_relationship_type_code;
            END IF;

            IF iparty_det_rec.bill_to_address1 IS NULL THEN
              c_account_tbl(ptyacc_idx).bill_to_address := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).bill_to_address := iparty_det_rec.bill_to_address1;
            END IF;

            IF iparty_det_rec.ship_to_address1 IS NULL THEN
              c_account_tbl(ptyacc_idx).ship_to_address := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).ship_to_address := iparty_det_rec.ship_to_address1;
            END IF;

             --c_account_tbl(ptyacc_idx).ACTIVE_START_DATE := l_fnd_g_date; -- ACTIVE_START_DATE

             IF iparty_det_rec.party_acct1_start_date IS NULL THEN
               c_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date;
             ELSE
               c_account_tbl(ptyacc_idx).active_start_date := iparty_det_rec.party_acct1_start_date;
             END IF;

             IF iparty_det_rec.party_acct1_end_date IS NULL THEN
               c_account_tbl(ptyacc_idx).active_end_date := l_fnd_g_date;
             ELSE
               c_account_tbl(ptyacc_idx).active_end_date := iparty_det_rec.party_acct1_end_date;
             END IF;

             IF iparty_det_rec.account1_context IS NULL THEN
               c_account_tbl(ptyacc_idx).context := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).context := iparty_det_rec.account1_context;
             END IF;

             IF iparty_det_rec.account1_attribute1 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute1 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute1 := iparty_det_rec.account1_attribute1;
             END IF;

             IF iparty_det_rec.account1_attribute2 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute2 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute2 := iparty_det_rec.account1_attribute2;
             END IF;

             IF iparty_det_rec.account1_attribute3 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute3 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute3 := iparty_det_rec.account1_attribute3;
             END IF;

             IF iparty_det_rec.account1_attribute4 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute4 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute4 := iparty_det_rec.account1_attribute4;
             END IF;

             IF iparty_det_rec.account1_attribute5 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute5 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute5 := iparty_det_rec.account1_attribute5;
             END IF;

             IF iparty_det_rec.account1_attribute6 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute6 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute6 := iparty_det_rec.account1_attribute6;
             END IF;

             IF iparty_det_rec.account1_attribute7 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute7 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute7 := iparty_det_rec.account1_attribute7;
             END IF;

             IF iparty_det_rec.account1_attribute8 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute8 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute8 := iparty_det_rec.account1_attribute8;
             END IF;

             IF iparty_det_rec.account1_attribute9 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute9 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute9 := iparty_det_rec.account1_attribute9;
             END IF;

             IF iparty_det_rec.account1_attribute10 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute10 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute10 := iparty_det_rec.account1_attribute10;
             END IF;

             IF iparty_det_rec.account1_attribute11 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute11 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute11 := iparty_det_rec.account1_attribute11;
             END IF;

             IF iparty_det_rec.account1_attribute12 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute12 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute12 := iparty_det_rec.account1_attribute12;
             END IF;

             IF iparty_det_rec.account1_attribute13 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute13 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute13 := iparty_det_rec.account1_attribute13;
             END IF;

             IF iparty_det_rec.account1_attribute14 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute14 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute14 := iparty_det_rec.account1_attribute14;
             END IF;

             IF iparty_det_rec.account1_attribute15 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute15 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute15 := iparty_det_rec.account1_attribute15;
             END IF;

             c_account_tbl(ptyacc_idx).OBJECT_VERSION_NUMBER := 1;
             c_account_tbl(ptyacc_idx).CALL_CONTRACTS  := l_fnd_g_true;
             c_account_tbl(ptyacc_idx).VLD_ORGANIZATION_ID :=  l_fnd_g_num;
           ptyacc_idx := ptyacc_idx + 1;

           END IF;

         IF iparty_det_rec.party_account2_id IS NOT NULL THEN -- Put record in Table

            c_account_tbl(ptyacc_idx).ip_account_id    := l_fnd_g_num;
            c_account_tbl(ptyacc_idx).instance_party_id := l_fnd_g_num;
            c_account_tbl(ptyacc_idx).parent_tbl_index  := prty_idx;

            IF iparty_det_rec.party_account2_id IS NULL THEN
              c_account_tbl(ptyacc_idx).party_account_id := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).party_account_id := iparty_det_rec.party_account2_id;
            END IF;

            IF iparty_det_rec.acct2_relationship_type_code IS NULL THEN
              c_account_tbl(ptyacc_idx).relationship_type_code := l_fnd_g_char;
            ELSE
              c_account_tbl(ptyacc_idx).relationship_type_code := iparty_det_rec.acct2_relationship_type_code;
            END IF;

            IF iparty_det_rec.bill_to_address2 IS NULL THEN
              c_account_tbl(ptyacc_idx).bill_to_address := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).bill_to_address := iparty_det_rec.bill_to_address2;
            END IF;

            IF iparty_det_rec.ship_to_address2 IS NULL THEN
              c_account_tbl(ptyacc_idx).ship_to_address := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).ship_to_address := iparty_det_rec.ship_to_address2;
            END IF;

             --c_account_tbl(ptyacc_idx).ACTIVE_START_DATE := l_fnd_g_date; -- ACTIVE_START_DATE
         -- Added
             IF iparty_det_rec.party_acct2_start_date IS NULL THEN
               c_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date;
             ELSE
               c_account_tbl(ptyacc_idx).active_start_date := iparty_det_rec.party_acct2_start_date;
             END IF;
         -- End addition
             IF iparty_det_rec.party_acct2_end_date IS NULL THEN
               c_account_tbl(ptyacc_idx).active_end_date := l_fnd_g_date;
             ELSE
               c_account_tbl(ptyacc_idx).active_end_date := iparty_det_rec.party_acct2_end_date;
             END IF;

             IF iparty_det_rec.account2_context IS NULL THEN
               c_account_tbl(ptyacc_idx).context := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).context := iparty_det_rec.account2_context;
             END IF;

             IF iparty_det_rec.account2_attribute1 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute1 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute1 := iparty_det_rec.account2_attribute1;
             END IF;

             IF iparty_det_rec.account2_attribute2 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute2 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute2 := iparty_det_rec.account2_attribute2;
             END IF;

             IF iparty_det_rec.account2_attribute3 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute3 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute3 := iparty_det_rec.account2_attribute3;
             END IF;

             IF iparty_det_rec.account2_attribute4 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute4 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute4 := iparty_det_rec.account2_attribute4;
             END IF;

             IF iparty_det_rec.account2_attribute5 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute5 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute5 := iparty_det_rec.account2_attribute5;
             END IF;

             IF iparty_det_rec.account2_attribute6 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute6 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute6 := iparty_det_rec.account2_attribute6;
             END IF;

             IF iparty_det_rec.account2_attribute7 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute7 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute7 := iparty_det_rec.account2_attribute7;
             END IF;

             IF iparty_det_rec.account2_attribute8 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute8 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute8 := iparty_det_rec.account2_attribute8;
             END IF;

             IF iparty_det_rec.account2_attribute9 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute9 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute9 := iparty_det_rec.account2_attribute9;
             END IF;

             IF iparty_det_rec.account2_attribute10 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute10 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute10 := iparty_det_rec.account2_attribute10;
             END IF;

             IF iparty_det_rec.account2_attribute11 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute11 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute11 := iparty_det_rec.account2_attribute11;
             END IF;

             IF iparty_det_rec.account2_attribute12 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute12 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute12 := iparty_det_rec.account2_attribute12;
             END IF;

             IF iparty_det_rec.account2_attribute13 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute13 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute13 := iparty_det_rec.account2_attribute13;
             END IF;

             IF iparty_det_rec.account2_attribute14 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute14 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute14 := iparty_det_rec.account2_attribute14;
             END IF;

             IF iparty_det_rec.account2_attribute15 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute15 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute15 := iparty_det_rec.account2_attribute15;
             END IF;

             c_account_tbl(ptyacc_idx).OBJECT_VERSION_NUMBER := 1;
             c_account_tbl(ptyacc_idx).CALL_CONTRACTS  := l_fnd_g_true;
             c_account_tbl(ptyacc_idx).VLD_ORGANIZATION_ID :=  l_fnd_g_num;
           ptyacc_idx := ptyacc_idx + 1;

           END IF;

         IF iparty_det_rec.party_account3_id IS NOT NULL THEN -- Put record in Table

            c_account_tbl(ptyacc_idx).ip_account_id    := l_fnd_g_num;
            c_account_tbl(ptyacc_idx).instance_party_id := l_fnd_g_num;
            c_account_tbl(ptyacc_idx).parent_tbl_index  := prty_idx;

            IF iparty_det_rec.party_account3_id IS NULL THEN
              c_account_tbl(ptyacc_idx).party_account_id := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).party_account_id := iparty_det_rec.party_account3_id;
            END IF;

            IF iparty_det_rec.acct3_relationship_type_code IS NULL THEN
              c_account_tbl(ptyacc_idx).relationship_type_code := l_fnd_g_char;
            ELSE
              c_account_tbl(ptyacc_idx).relationship_type_code := iparty_det_rec.acct3_relationship_type_code;
            END IF;

            IF iparty_det_rec.bill_to_address3 IS NULL THEN
              c_account_tbl(ptyacc_idx).bill_to_address := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).bill_to_address := iparty_det_rec.bill_to_address3;
            END IF;

            IF iparty_det_rec.ship_to_address3 IS NULL THEN
              c_account_tbl(ptyacc_idx).ship_to_address := l_fnd_g_num;
            ELSE
              c_account_tbl(ptyacc_idx).ship_to_address := iparty_det_rec.ship_to_address3;
            END IF;

             --c_account_tbl(ptyacc_idx).ACTIVE_START_DATE := l_fnd_g_date; -- ACTIVE_START_DATE
           -- Added
             IF iparty_det_rec.party_acct3_start_date IS NULL THEN
               c_account_tbl(ptyacc_idx).active_start_date := l_fnd_g_date;
             ELSE
               c_account_tbl(ptyacc_idx).active_start_date := iparty_det_rec.party_acct3_start_date;
             END IF;
           -- End addition
             IF iparty_det_rec.party_acct3_end_date IS NULL THEN
               c_account_tbl(ptyacc_idx).active_end_date := l_fnd_g_date;
             ELSE
               c_account_tbl(ptyacc_idx).active_end_date := iparty_det_rec.party_acct3_end_date;
             END IF;

             IF iparty_det_rec.account3_context IS NULL THEN
               c_account_tbl(ptyacc_idx).context := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).context := iparty_det_rec.account3_context;
             END IF;

             IF iparty_det_rec.account3_attribute1 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute1 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute1 := iparty_det_rec.account3_attribute1;
             END IF;

             IF iparty_det_rec.account3_attribute2 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute2 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute2 := iparty_det_rec.account3_attribute2;
             END IF;

             IF iparty_det_rec.account3_attribute3 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute3 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute3 := iparty_det_rec.account3_attribute3;
             END IF;

             IF iparty_det_rec.account3_attribute4 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute4 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute4 := iparty_det_rec.account3_attribute4;
             END IF;

             IF iparty_det_rec.account3_attribute5 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute5 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute5 := iparty_det_rec.account3_attribute5;
             END IF;

             IF iparty_det_rec.account3_attribute6 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute6 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute6 := iparty_det_rec.account3_attribute6;
             END IF;

             IF iparty_det_rec.account3_attribute7 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute7 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute7 := iparty_det_rec.account3_attribute7;
             END IF;

             IF iparty_det_rec.account3_attribute8 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute8 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute8 := iparty_det_rec.account3_attribute8;
             END IF;

             IF iparty_det_rec.account3_attribute9 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute9 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute9 := iparty_det_rec.account3_attribute9;
             END IF;

             IF iparty_det_rec.account3_attribute10 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute10 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute10 := iparty_det_rec.account3_attribute10;
             END IF;

             IF iparty_det_rec.account3_attribute11 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute11 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute11 := iparty_det_rec.account3_attribute11;
             END IF;

             IF iparty_det_rec.account3_attribute12 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute12 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute12 := iparty_det_rec.account3_attribute12;
             END IF;

             IF iparty_det_rec.account3_attribute13 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute13 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute13 := iparty_det_rec.account3_attribute13;
             END IF;

             IF iparty_det_rec.account3_attribute14 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute14 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute14 := iparty_det_rec.account3_attribute14;
             END IF;

             IF iparty_det_rec.account3_attribute15 IS NULL THEN
               c_account_tbl(ptyacc_idx).attribute15 := l_fnd_g_char;
             ELSE
               c_account_tbl(ptyacc_idx).attribute15 := iparty_det_rec.account3_attribute15;
             END IF;

             c_account_tbl(ptyacc_idx).OBJECT_VERSION_NUMBER := 1;
             c_account_tbl(ptyacc_idx).CALL_CONTRACTS  := l_fnd_g_true;
             c_account_tbl(ptyacc_idx).VLD_ORGANIZATION_ID :=  l_fnd_g_num;
           ptyacc_idx := ptyacc_idx + 1;
         END IF;  -- Party Account 3

        -- Added the following code to handle contacts.
        -- If contact_party_id is passed then I assume
        -- a contact should be created for the party.
           IF iparty_det_rec.contact_party_id IS NOT NULL AND
              iparty_det_rec.contact_party_id <> fnd_api.g_miss_num
           THEN
             prty_idx:=prty_idx + 1;
             c_party_tbl(prty_idx).instance_party_id:=fnd_api.g_miss_num;
             c_party_tbl(prty_idx).instance_id:=fnd_api.g_miss_num;
             c_party_tbl(prty_idx).party_source_table:=iparty_det_rec.party_source_table;
             c_party_tbl(prty_idx).party_id:=iparty_det_rec.contact_party_id;
             c_party_tbl(prty_idx).relationship_type_code:=iparty_det_rec.contact_party_rel_type;
             c_party_tbl(prty_idx).contact_flag:='Y';
             c_party_tbl(prty_idx).contact_parent_tbl_index:=prty_idx-1;
             c_party_tbl(prty_idx).parent_tbl_index:=inst_idx;
           END IF;
        -- End addition for contacts.

         prty_idx := prty_idx + 1;
       END LOOP;   -- End of Party and Party Account LOOP

	  --bnarayan added for R12 Open Interfaces
         /* Loop through the Cursor based on asset interface table */
       FOR iasset_iface_rec in iasset_iface_cur(iface_det_rec.inst_interface_id)
       LOOP
            c_asset_assignment_tbl( asset_idx ).OBJECT_VERSION_NUMBER  := 1;
            c_asset_assignment_tbl( asset_idx ).parent_tbl_index       := inst_idx;

            IF iasset_iface_rec.instance_asset_id IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).instance_asset_id := l_fnd_g_num;
            ELSE
               c_asset_assignment_tbl( asset_idx ).instance_asset_id := iasset_iface_rec.instance_asset_id ;
            END IF;

            IF iasset_iface_rec.instance_id IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).instance_id := l_fnd_g_num;
            ELSE
               c_asset_assignment_tbl( asset_idx ).instance_id := iasset_iface_rec.instance_id ;
            END IF;

            IF iasset_iface_rec.fa_asset_id IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).fa_asset_id := l_fnd_g_num;
            ELSE
                c_asset_assignment_tbl( asset_idx ).fa_asset_id := iasset_iface_rec.fa_asset_id ;
            END IF;

            IF iasset_iface_rec.fa_book_type_code IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).fa_book_type_code := l_fnd_g_char;
            ELSE
               c_asset_assignment_tbl( asset_idx ).fa_book_type_code := iasset_iface_rec.fa_book_type_code;
            END IF;

            IF iasset_iface_rec.fa_location_id IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).fa_location_id := l_fnd_g_num;
            ELSE
               c_asset_assignment_tbl( asset_idx ).fa_location_id := iasset_iface_rec.fa_location_id ;
            END IF;

            IF iasset_iface_rec.asset_quantity IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).asset_quantity := l_fnd_g_num;
            ELSE
               c_asset_assignment_tbl( asset_idx ).asset_quantity := iasset_iface_rec.asset_quantity ;
            END IF;

            IF iasset_iface_rec.update_status IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).update_status := l_fnd_g_char;
            ELSE
               c_asset_assignment_tbl( asset_idx ).update_status := iasset_iface_rec.update_status ;
            END IF;

            IF iasset_iface_rec.active_start_date IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).active_start_date := l_fnd_g_date;
            ELSE
               c_asset_assignment_tbl( asset_idx ).active_start_date := iasset_iface_rec.active_start_date ;
            END IF;

            IF iasset_iface_rec.active_end_date  IS NULL THEN
               c_asset_assignment_tbl( asset_idx ).active_end_date  := l_fnd_g_date;
            ELSE
               c_asset_assignment_tbl( asset_idx ).active_end_date  := iasset_iface_rec.active_end_date;
            END IF;
            c_asset_assignment_tbl( asset_idx ).fa_sync_flag  := iasset_iface_rec.fa_sync_flag;
            asset_idx             := asset_idx    + 1; -- Increment asset index
        END LOOP;  --end of the asset loop

       FOR ieav_det_rec in ieav_det_cur (iface_det_rec.inst_interface_id) LOOP
         -- Extended Attribute Values

         IF  iface_det_rec.transaction_identifier is NOT NULL THEN

           c_ext_attrib_tbl(extatt_idx).attribute_value_id :=  NULL;
           c_ext_attrib_tbl(extatt_idx).instance_id        :=  NULL;
           c_ext_attrib_tbl(extatt_idx).parent_tbl_index   :=  inst_idx;

           IF ieav_det_rec.attribute_id IS NULL THEN
             c_ext_attrib_tbl(extatt_idx).attribute_id := l_fnd_g_num;
           ELSE
             c_ext_attrib_tbl(extatt_idx).attribute_id := ieav_det_rec.attribute_id;
           END IF;

           IF ieav_det_rec.attribute_code IS NULL THEN
             c_ext_attrib_tbl(extatt_idx).attribute_code := l_fnd_g_char;
           ELSE
             c_ext_attrib_tbl(extatt_idx).attribute_code := ieav_det_rec.attribute_code;
           END IF;

           IF ieav_det_rec.attribute_value IS NULL THEN
             c_ext_attrib_tbl(extatt_idx).attribute_value := l_fnd_g_char;
           ELSE
             c_ext_attrib_tbl(extatt_idx).attribute_value := ieav_det_rec.attribute_value;
           END IF;

           c_ext_attrib_tbl(extatt_idx).ACTIVE_START_DATE := l_fnd_g_date;

           IF ieav_det_rec.ieav_end_date IS NULL THEN
             c_ext_attrib_tbl(extatt_idx).active_end_date := l_fnd_g_date;
           ELSE
             c_ext_attrib_tbl(extatt_idx).active_end_date := ieav_det_rec.ieav_end_date;
           END IF;

           c_ext_attrib_tbl(extatt_idx).context := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute1 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute2 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute3 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute4 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute5 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute6 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute7 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute8 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute9 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute10 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute11 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute12 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute13 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute14 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).attribute15 := l_fnd_g_char;
           c_ext_attrib_tbl(extatt_idx).object_version_number := 1;

         extatt_idx := extatt_idx + 1;
         END IF;
       END LOOP;  -- End of Extended Attributes

       IF (iface_det_rec.pricing_att_start_date  IS NOT NULL OR
           iface_det_rec.pricing_att_end_date    IS NOT NULL OR
           iface_det_rec.pricing_context         IS NOT NULL OR
           iface_det_rec.pricing_attribute1      IS NOT NULL OR
           iface_det_rec.pricing_attribute2      IS NOT NULL OR
           iface_det_rec.pricing_attribute3      IS NOT NULL OR
           iface_det_rec.pricing_attribute4      IS NOT NULL OR
           iface_det_rec.pricing_attribute5      IS NOT NULL OR
           iface_det_rec.pricing_attribute6      IS NOT NULL OR
           iface_det_rec.pricing_attribute7      IS NOT NULL OR
           iface_det_rec.pricing_attribute8      IS NOT NULL OR
           iface_det_rec.pricing_attribute9      IS NOT NULL OR
           iface_det_rec.pricing_attribute10     IS NOT NULL OR
           iface_det_rec.pricing_attribute11     IS NOT NULL OR
           iface_det_rec.pricing_attribute12     IS NOT NULL OR
           iface_det_rec.pricing_attribute13     IS NOT NULL OR
           iface_det_rec.pricing_attribute14     IS NOT NULL OR
           iface_det_rec.pricing_attribute15     IS NOT NULL OR
           iface_det_rec.pricing_attribute16     IS NOT NULL OR
           iface_det_rec.pricing_attribute17     IS NOT NULL OR
           iface_det_rec.pricing_attribute18     IS NOT NULL OR
           iface_det_rec.pricing_attribute19     IS NOT NULL OR
           iface_det_rec.pricing_attribute20     IS NOT NULL OR
           iface_det_rec.pricing_attribute21     IS NOT NULL OR
           iface_det_rec.pricing_attribute22     IS NOT NULL OR
           iface_det_rec.pricing_attribute23     IS NOT NULL OR
           iface_det_rec.pricing_attribute24     IS NOT NULL OR
           iface_det_rec.pricing_attribute25     IS NOT NULL OR
           iface_det_rec.pricing_attribute26     IS NOT NULL OR
           iface_det_rec.pricing_attribute27     IS NOT NULL OR
           iface_det_rec.pricing_attribute28     IS NOT NULL OR
           iface_det_rec.pricing_attribute29     IS NOT NULL OR
           iface_det_rec.pricing_attribute30     IS NOT NULL OR
           iface_det_rec.pricing_attribute31     IS NOT NULL OR
           iface_det_rec.pricing_attribute32     IS NOT NULL OR
           iface_det_rec.pricing_attribute33     IS NOT NULL OR
           iface_det_rec.pricing_attribute34     IS NOT NULL OR
           iface_det_rec.pricing_attribute35     IS NOT NULL OR
           iface_det_rec.pricing_attribute36     IS NOT NULL OR
           iface_det_rec.pricing_attribute37     IS NOT NULL OR
           iface_det_rec.pricing_attribute38     IS NOT NULL OR
           iface_det_rec.pricing_attribute39     IS NOT NULL OR
           iface_det_rec.pricing_attribute40     IS NOT NULL OR
           iface_det_rec.pricing_attribute41     IS NOT NULL OR
           iface_det_rec.pricing_attribute42     IS NOT NULL OR
           iface_det_rec.pricing_attribute43     IS NOT NULL OR
           iface_det_rec.pricing_attribute44     IS NOT NULL OR
           iface_det_rec.pricing_attribute45     IS NOT NULL OR
           iface_det_rec.pricing_attribute46     IS NOT NULL OR
           iface_det_rec.pricing_attribute47     IS NOT NULL OR
           iface_det_rec.pricing_attribute48     IS NOT NULL OR
           iface_det_rec.pricing_attribute49     IS NOT NULL OR
           iface_det_rec.pricing_attribute50     IS NOT NULL OR
           iface_det_rec.pricing_attribute51     IS NOT NULL OR
           iface_det_rec.pricing_attribute52     IS NOT NULL OR
           iface_det_rec.pricing_attribute53     IS NOT NULL OR
           iface_det_rec.pricing_attribute54     IS NOT NULL OR
           iface_det_rec.pricing_attribute55     IS NOT NULL OR
           iface_det_rec.pricing_attribute56     IS NOT NULL OR
           iface_det_rec.pricing_attribute57     IS NOT NULL OR
           iface_det_rec.pricing_attribute58     IS NOT NULL OR
           iface_det_rec.pricing_attribute59     IS NOT NULL OR
           iface_det_rec.pricing_attribute60     IS NOT NULL OR
           iface_det_rec.pricing_attribute61     IS NOT NULL OR
           iface_det_rec.pricing_attribute62     IS NOT NULL OR
           iface_det_rec.pricing_attribute63     IS NOT NULL OR
           iface_det_rec.pricing_attribute64     IS NOT NULL OR
           iface_det_rec.pricing_attribute65     IS NOT NULL OR
           iface_det_rec.pricing_attribute66     IS NOT NULL OR
           iface_det_rec.pricing_attribute67     IS NOT NULL OR
           iface_det_rec.pricing_attribute68     IS NOT NULL OR
           iface_det_rec.pricing_attribute69     IS NOT NULL OR
           iface_det_rec.pricing_attribute70     IS NOT NULL OR
           iface_det_rec.pricing_attribute71     IS NOT NULL OR
           iface_det_rec.pricing_attribute72     IS NOT NULL OR
           iface_det_rec.pricing_attribute73     IS NOT NULL OR
           iface_det_rec.pricing_attribute74     IS NOT NULL OR
           iface_det_rec.pricing_attribute75     IS NOT NULL OR
           iface_det_rec.pricing_attribute76     IS NOT NULL OR
           iface_det_rec.pricing_attribute77     IS NOT NULL OR
           iface_det_rec.pricing_attribute78     IS NOT NULL OR
           iface_det_rec.pricing_attribute79     IS NOT NULL OR
           iface_det_rec.pricing_attribute80     IS NOT NULL OR
           iface_det_rec.pricing_attribute81     IS NOT NULL OR
           iface_det_rec.pricing_attribute82     IS NOT NULL OR
           iface_det_rec.pricing_attribute83     IS NOT NULL OR
           iface_det_rec.pricing_attribute84     IS NOT NULL OR
           iface_det_rec.pricing_attribute85     IS NOT NULL OR
           iface_det_rec.pricing_attribute86     IS NOT NULL OR
           iface_det_rec.pricing_attribute87     IS NOT NULL OR
           iface_det_rec.pricing_attribute88     IS NOT NULL OR
           iface_det_rec.pricing_attribute89     IS NOT NULL OR
           iface_det_rec.pricing_attribute90     IS NOT NULL OR
           iface_det_rec.pricing_attribute91     IS NOT NULL OR
           iface_det_rec.pricing_attribute92     IS NOT NULL OR
           iface_det_rec.pricing_attribute93     IS NOT NULL OR
           iface_det_rec.pricing_attribute94     IS NOT NULL OR
           iface_det_rec.pricing_attribute95     IS NOT NULL OR
           iface_det_rec.pricing_attribute96     IS NOT NULL OR
           iface_det_rec.pricing_attribute97     IS NOT NULL OR
           iface_det_rec.pricing_attribute98     IS NOT NULL OR
           iface_det_rec.pricing_attribute99     IS NOT NULL OR
           iface_det_rec.pricing_attribute100    IS NOT NULL) THEN

       IF iface_det_rec.transaction_identifier is NOT NULL THEN

         c_price_tbl(price_idx).pricing_attribute_id  :=  NULL;
         c_price_tbl(price_idx).instance_id           :=  NULL;
         c_price_tbl(price_idx).parent_tbl_index      :=  inst_idx;
         c_price_tbl(price_idx).active_start_date := l_fnd_g_date;

         IF iface_det_rec.pricing_att_end_date IS NULL THEN
           c_price_tbl(price_idx).active_end_date := l_fnd_g_date;
         ELSE
           c_price_tbl(price_idx).active_end_date := iface_det_rec.pricing_att_end_date;
         END IF;

         IF iface_det_rec.pricing_context IS NULL THEN
           c_price_tbl(price_idx).pricing_context := l_fnd_g_char;
           --changed from context tar 4102867.999
         ELSE
           c_price_tbl(price_idx).pricing_context := iface_det_rec.pricing_context;
           --changed from context tar 4102867.999
         END IF;

         IF iface_det_rec.pricing_attribute1 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute1 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute1 := iface_det_rec.pricing_attribute1;
         END IF;

         IF iface_det_rec.pricing_attribute2 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute2 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute2 := iface_det_rec.pricing_attribute2;
         END IF;

         IF iface_det_rec.pricing_attribute3 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute3 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute3 := iface_det_rec.pricing_attribute3;
         END IF;

         IF iface_det_rec.pricing_attribute4 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute4 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute4 := iface_det_rec.pricing_attribute4;
         END IF;

         IF iface_det_rec.pricing_attribute5 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute5 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute5 := iface_det_rec.pricing_attribute5;
         END IF;

         IF iface_det_rec.pricing_attribute6 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute6 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute6 := iface_det_rec.pricing_attribute6;
         END IF;

         IF iface_det_rec.pricing_attribute7 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute7 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute7 := iface_det_rec.pricing_attribute7;
         END IF;

         IF iface_det_rec.pricing_attribute8 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute8 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute8 := iface_det_rec.pricing_attribute8;
         END IF;

         IF iface_det_rec.pricing_attribute9 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute9 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute9 := iface_det_rec.pricing_attribute9;
         END IF;

         IF iface_det_rec.pricing_attribute10 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute10 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute10 := iface_det_rec.pricing_attribute10;
         END IF;

         IF iface_det_rec.pricing_attribute11 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute11 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute11 := iface_det_rec.pricing_attribute11;
         END IF;

         IF iface_det_rec.pricing_attribute12 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute12 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute12 := iface_det_rec.pricing_attribute12;
         END IF;

         IF iface_det_rec.pricing_attribute13 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute13 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute13 := iface_det_rec.pricing_attribute13;
         END IF;

         IF iface_det_rec.pricing_attribute14 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute14 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute14 := iface_det_rec.pricing_attribute14;
         END IF;

         IF iface_det_rec.pricing_attribute15 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute15 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute15 := iface_det_rec.pricing_attribute15;
         END IF;

         IF iface_det_rec.pricing_attribute16 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute16 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute16 := iface_det_rec.pricing_attribute16;
         END IF;

         IF iface_det_rec.pricing_attribute17 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute17 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute17 := iface_det_rec.pricing_attribute17;
         END IF;

         IF iface_det_rec.pricing_attribute18 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute18 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute18 := iface_det_rec.pricing_attribute18;
         END IF;

         IF iface_det_rec.pricing_attribute19 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute19 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute19 := iface_det_rec.pricing_attribute19;
         END IF;

         IF iface_det_rec.pricing_attribute20 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute20 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute20 := iface_det_rec.pricing_attribute20;
         END IF;

         IF iface_det_rec.pricing_attribute21 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute21 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute21 := iface_det_rec.pricing_attribute21;
         END IF;

         IF iface_det_rec.pricing_attribute22 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute22 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute22 := iface_det_rec.pricing_attribute22;
         END IF;

         IF iface_det_rec.pricing_attribute23 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute23 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute23 := iface_det_rec.pricing_attribute23;
         END IF;

         IF iface_det_rec.pricing_attribute24 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute24 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute24 := iface_det_rec.pricing_attribute24;
         END IF;

         IF iface_det_rec.pricing_attribute25 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute25 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute25 := iface_det_rec.pricing_attribute25;
         END IF;

         IF iface_det_rec.pricing_attribute26 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute26 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute26 := iface_det_rec.pricing_attribute26;
         END IF;

         IF iface_det_rec.pricing_attribute27 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute27 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute27 := iface_det_rec.pricing_attribute27;
         END IF;

         IF iface_det_rec.pricing_attribute28 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute28 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute28 := iface_det_rec.pricing_attribute28;
         END IF;

         IF iface_det_rec.pricing_attribute29 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute29 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute29 := iface_det_rec.pricing_attribute29;
         END IF;

         IF iface_det_rec.pricing_attribute30 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute30 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute30 := iface_det_rec.pricing_attribute30;
         END IF;

         IF iface_det_rec.pricing_attribute31 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute31 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute31 := iface_det_rec.pricing_attribute31;
         END IF;

         IF iface_det_rec.pricing_attribute32 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute32 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute32 := iface_det_rec.pricing_attribute32;
         END IF;

         IF iface_det_rec.pricing_attribute33 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute33 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute33 := iface_det_rec.pricing_attribute33;
         END IF;

         IF iface_det_rec.pricing_attribute34 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute34 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute34 := iface_det_rec.pricing_attribute34;
         END IF;

         IF iface_det_rec.pricing_attribute35 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute35 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute35 := iface_det_rec.pricing_attribute35;
         END IF;

         IF iface_det_rec.pricing_attribute36 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute36 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute36 := iface_det_rec.pricing_attribute36;
         END IF;

         IF iface_det_rec.pricing_attribute37 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute37 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute37 := iface_det_rec.pricing_attribute37;
         END IF;

         IF iface_det_rec.pricing_attribute38 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute38 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute38 := iface_det_rec.pricing_attribute38;
         END IF;

         IF iface_det_rec.pricing_attribute39 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute39 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute39 := iface_det_rec.pricing_attribute39;
         END IF;

         IF iface_det_rec.pricing_attribute40 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute40 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute40 := iface_det_rec.pricing_attribute40;
         END IF;

         IF iface_det_rec.pricing_attribute41 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute41 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute41 := iface_det_rec.pricing_attribute41;
         END IF;

         IF iface_det_rec.pricing_attribute42 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute42 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute42 := iface_det_rec.pricing_attribute42;
         END IF;

         IF iface_det_rec.pricing_attribute43 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute43 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute43 := iface_det_rec.pricing_attribute43;
         END IF;

         IF iface_det_rec.pricing_attribute44 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute44 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute44 := iface_det_rec.pricing_attribute44;
         END IF;

         IF iface_det_rec.pricing_attribute45 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute45 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute45 := iface_det_rec.pricing_attribute45;
         END IF;

         IF iface_det_rec.pricing_attribute46 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute46 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute46 := iface_det_rec.pricing_attribute46;
         END IF;

         IF iface_det_rec.pricing_attribute47 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute47 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute47 := iface_det_rec.pricing_attribute47;
         END IF;

         IF iface_det_rec.pricing_attribute48 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute48 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute48 := iface_det_rec.pricing_attribute48;
         END IF;

         IF iface_det_rec.pricing_attribute49 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute49 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute49 := iface_det_rec.pricing_attribute49;
         END IF;

         IF iface_det_rec.pricing_attribute50 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute50 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute50 := iface_det_rec.pricing_attribute50;
         END IF;

         IF iface_det_rec.pricing_attribute51 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute51 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute51 := iface_det_rec.pricing_attribute51;
         END IF;

         IF iface_det_rec.pricing_attribute52 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute52 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute52 := iface_det_rec.pricing_attribute52;
         END IF;

         IF iface_det_rec.pricing_attribute53 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute53 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute53 := iface_det_rec.pricing_attribute53;
         END IF;

         IF iface_det_rec.pricing_attribute54 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute54 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute54 := iface_det_rec.pricing_attribute54;
         END IF;

         IF iface_det_rec.pricing_attribute55 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute55 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute55 := iface_det_rec.pricing_attribute55;
         END IF;

         IF iface_det_rec.pricing_attribute56 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute56 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute56 := iface_det_rec.pricing_attribute56;
         END IF;

         IF iface_det_rec.pricing_attribute57 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute57 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute57 := iface_det_rec.pricing_attribute57;
         END IF;

         IF iface_det_rec.pricing_attribute58 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute58 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute58 := iface_det_rec.pricing_attribute58;
         END IF;

         IF iface_det_rec.pricing_attribute59 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute59 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute59 := iface_det_rec.pricing_attribute59;
         END IF;

         IF iface_det_rec.pricing_attribute60 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute60 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute60 := iface_det_rec.pricing_attribute60;
         END IF;

         IF iface_det_rec.pricing_attribute61 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute61 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute61 := iface_det_rec.pricing_attribute61;
         END IF;

         IF iface_det_rec.pricing_attribute62 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute62 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute62 := iface_det_rec.pricing_attribute62;
         END IF;

         IF iface_det_rec.pricing_attribute63 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute63 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute63 := iface_det_rec.pricing_attribute63;
         END IF;

         IF iface_det_rec.pricing_attribute64 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute64 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute64 := iface_det_rec.pricing_attribute64;
         END IF;

         IF iface_det_rec.pricing_attribute5 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute65 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute65 := iface_det_rec.pricing_attribute65;
         END IF;

         IF iface_det_rec.pricing_attribute66 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute66 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute66 := iface_det_rec.pricing_attribute66;
         END IF;

         IF iface_det_rec.pricing_attribute67 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute67 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute67 := iface_det_rec.pricing_attribute67;
         END IF;

         IF iface_det_rec.pricing_attribute68 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute68 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute68 := iface_det_rec.pricing_attribute68;
         END IF;

         IF iface_det_rec.pricing_attribute69 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute69 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute69 := iface_det_rec.pricing_attribute69;
         END IF;

         IF iface_det_rec.pricing_attribute70 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute70 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute70 := iface_det_rec.pricing_attribute70;
         END IF;

         IF iface_det_rec.pricing_attribute71 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute71 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute71 := iface_det_rec.pricing_attribute71;
         END IF;

         IF iface_det_rec.pricing_attribute72 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute72 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute72 := iface_det_rec.pricing_attribute72;
         END IF;

         IF iface_det_rec.pricing_attribute73 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute73 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute73 := iface_det_rec.pricing_attribute73;
         END IF;

         IF iface_det_rec.pricing_attribute74 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute74 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute74 := iface_det_rec.pricing_attribute74;
         END IF;

         IF iface_det_rec.pricing_attribute75 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute75 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute75 := iface_det_rec.pricing_attribute75;
         END IF;

         IF iface_det_rec.pricing_attribute76 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute76 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute76 := iface_det_rec.pricing_attribute76;
         END IF;

         IF iface_det_rec.pricing_attribute77 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute77 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute77 := iface_det_rec.pricing_attribute77;
         END IF;

         IF iface_det_rec.pricing_attribute78 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute78 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute78 := iface_det_rec.pricing_attribute78;
         END IF;

         IF iface_det_rec.pricing_attribute79 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute79 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute79 := iface_det_rec.pricing_attribute79;
         END IF;

         IF iface_det_rec.pricing_attribute80 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute80 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute80 := iface_det_rec.pricing_attribute80;
         END IF;

         IF iface_det_rec.pricing_attribute81 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute81 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute81 := iface_det_rec.pricing_attribute81;
         END IF;

         IF iface_det_rec.pricing_attribute82 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute82 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute82 := iface_det_rec.pricing_attribute82;
         END IF;

         IF iface_det_rec.pricing_attribute83 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute83 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute83 := iface_det_rec.pricing_attribute83;
         END IF;

         IF iface_det_rec.pricing_attribute84 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute84 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute84 := iface_det_rec.pricing_attribute84;
         END IF;

         IF iface_det_rec.pricing_attribute85 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute85 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute85 := iface_det_rec.pricing_attribute85;
         END IF;

         IF iface_det_rec.pricing_attribute86 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute86 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute86 := iface_det_rec.pricing_attribute86;
         END IF;

         IF iface_det_rec.pricing_attribute87 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute87 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute87 := iface_det_rec.pricing_attribute87;
         END IF;

         IF iface_det_rec.pricing_attribute88 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute88 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute88 := iface_det_rec.pricing_attribute88;
         END IF;

         IF iface_det_rec.pricing_attribute89 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute89 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute89 := iface_det_rec.pricing_attribute89;
         END IF;

         IF iface_det_rec.pricing_attribute90 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute90 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute90 := iface_det_rec.pricing_attribute90;
         END IF;

         IF iface_det_rec.pricing_attribute91 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute91 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute91 := iface_det_rec.pricing_attribute91;
         END IF;

         IF iface_det_rec.pricing_attribute92 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute92 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute92 := iface_det_rec.pricing_attribute92;
         END IF;

         IF iface_det_rec.pricing_attribute93 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute93 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute93 := iface_det_rec.pricing_attribute93;
         END IF;

         IF iface_det_rec.pricing_attribute94 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute94 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute94 := iface_det_rec.pricing_attribute94;
         END IF;

         IF iface_det_rec.pricing_attribute95 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute95 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute95 := iface_det_rec.pricing_attribute95;
         END IF;

         IF iface_det_rec.pricing_attribute96 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute96 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute96 := iface_det_rec.pricing_attribute96;
         END IF;

         IF iface_det_rec.pricing_attribute97 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute97 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute97 := iface_det_rec.pricing_attribute97;
         END IF;

         IF iface_det_rec.pricing_attribute98 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute98 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute98 := iface_det_rec.pricing_attribute98;
         END IF;

         IF iface_det_rec.pricing_attribute99 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute99 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute99 := iface_det_rec.pricing_attribute99;
         END IF;

         IF iface_det_rec.pricing_attribute100 IS NULL THEN
          c_price_tbl(price_idx).pricing_attribute100 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_attribute100 := iface_det_rec.pricing_attribute100;
         END IF;

         IF iface_det_rec.pricing_flex_context IS NULL THEN
           c_price_tbl(price_idx).pricing_context := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).pricing_context := iface_det_rec.pricing_context;
         END IF;

         IF iface_det_rec.pricing_flex_attribute1 IS NULL THEN
          c_price_tbl(price_idx).attribute1 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute1 := iface_det_rec.pricing_flex_attribute1;
         END IF;

         IF iface_det_rec.pricing_flex_attribute2 IS NULL THEN
          c_price_tbl(price_idx).attribute2 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute2 := iface_det_rec.pricing_flex_attribute2;
         END IF;

         IF iface_det_rec.pricing_flex_attribute3 IS NULL THEN
          c_price_tbl(price_idx).attribute3 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute3 := iface_det_rec.pricing_flex_attribute3;
         END IF;

         IF iface_det_rec.pricing_flex_attribute4 IS NULL THEN
          c_price_tbl(price_idx).attribute4 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute4 := iface_det_rec.pricing_flex_attribute4;
         END IF;

         IF iface_det_rec.pricing_flex_attribute5 IS NULL THEN
          c_price_tbl(price_idx).attribute5 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute5 := iface_det_rec.pricing_flex_attribute5;
         END IF;

         IF iface_det_rec.pricing_flex_attribute6 IS NULL THEN
          c_price_tbl(price_idx).attribute6 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute6 := iface_det_rec.pricing_flex_attribute6;
         END IF;

         IF iface_det_rec.pricing_flex_attribute7 IS NULL THEN
          c_price_tbl(price_idx).attribute7 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute7 := iface_det_rec.pricing_flex_attribute7;
         END IF;

         IF iface_det_rec.pricing_flex_attribute8 IS NULL THEN
          c_price_tbl(price_idx).attribute8 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute8 := iface_det_rec.pricing_flex_attribute8;
         END IF;

         IF iface_det_rec.pricing_flex_attribute9 IS NULL THEN
          c_price_tbl(price_idx).attribute9 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute9 := iface_det_rec.pricing_flex_attribute9;
         END IF;

         IF iface_det_rec.pricing_flex_attribute10 IS NULL THEN
          c_price_tbl(price_idx).attribute10 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute10 := iface_det_rec.pricing_flex_attribute10;
         END IF;

         IF iface_det_rec.pricing_flex_attribute11 IS NULL THEN
          c_price_tbl(price_idx).attribute11 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute11 := iface_det_rec.pricing_flex_attribute11;
         END IF;

         IF iface_det_rec.pricing_flex_attribute12 IS NULL THEN
          c_price_tbl(price_idx).attribute12 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute12 := iface_det_rec.pricing_flex_attribute12;
         END IF;

         IF iface_det_rec.pricing_flex_attribute13 IS NULL THEN
          c_price_tbl(price_idx).attribute13 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute13 := iface_det_rec.pricing_flex_attribute13;
         END IF;

         IF iface_det_rec.pricing_flex_attribute14 IS NULL THEN
          c_price_tbl(price_idx).attribute14 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute14 := iface_det_rec.pricing_flex_attribute14;
         END IF;

         IF iface_det_rec.pricing_flex_attribute15 IS NULL THEN
          c_price_tbl(price_idx).attribute15 := l_fnd_g_char;
         ELSE
          c_price_tbl(price_idx).attribute15 := iface_det_rec.pricing_flex_attribute15;
         END IF;

         c_price_tbl(price_idx).object_version_number := 1;

       END IF;

       price_idx := price_idx + 1;
     END IF;    -- End of Pricing Attributes

     -- Org Assignments
     IF (iface_det_rec.operating_unit            IS NOT NULL OR
         iface_det_rec.ou_relation_type          IS NOT NULL OR
         iface_det_rec.ou_start_date             IS NOT NULL OR
         iface_det_rec.ou_end_date               IS NOT NULL) THEN

     IF iface_det_rec.transaction_identifier IS NOT NULL THEN

       c_org_assign_tbl(orgass_idx).instance_ou_id    :=  NULL;
       c_org_assign_tbl(orgass_idx).instance_id       :=  NULL;
       c_org_assign_tbl(orgass_idx).parent_tbl_index  :=  inst_idx;

       IF iface_det_rec.operating_unit IS NULL THEN
         c_org_assign_tbl(orgass_idx).operating_unit_id := l_fnd_g_num;
       ELSE
         c_org_assign_tbl(orgass_idx).operating_unit_id := iface_det_rec.operating_unit;
       END IF;

       IF iface_det_rec.ou_relation_type IS NULL THEN
         c_org_assign_tbl(orgass_idx).relationship_type_code := l_fnd_g_char;
       ELSE
         c_org_assign_tbl(orgass_idx).relationship_type_code := iface_det_rec.ou_relation_type;
       END IF;

       c_org_assign_tbl(orgass_idx).active_start_date := l_fnd_g_date;

       IF iface_det_rec.ou_end_date IS NULL THEN
         c_org_assign_tbl(orgass_idx).active_end_date := l_fnd_g_date;
       ELSE
         c_org_assign_tbl(orgass_idx).active_end_date := iface_det_rec.ou_end_date;
       END IF;

       c_org_assign_tbl(orgass_idx).context := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute1 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute2 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute3 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute4 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute5 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute6 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute7 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute8 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute9 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute10 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute11 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute12 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute13 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute14 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).attribute15 := l_fnd_g_char;
       c_org_assign_tbl(orgass_idx).object_version_number := 1;

     END IF;

     orgass_idx := orgass_idx + 1;
     END IF;  -- End of Org Assignments

     -- Transaction Table
     c_txn_tbl(inst_idx).transaction_date := iface_det_rec.source_transaction_date;
     c_txn_tbl(inst_idx).source_transaction_date := iface_det_rec.source_transaction_date;
     c_txn_tbl(inst_idx).transaction_type_id:= l_txn_type_id;
     c_txn_tbl(inst_idx).source_group_ref:= iface_det_rec.transaction_identifier;
     c_txn_tbl(inst_idx).transaction_quantity:= iface_det_rec.quantity;
     c_txn_tbl(inst_idx).transaction_uom_code:= iface_det_rec.unit_of_measure_code;
     c_txn_tbl(inst_idx).transacted_by := iface_det_rec.created_by;
     c_txn_tbl(inst_idx).transaction_status_code := 'COMPLETE';
     c_txn_tbl(inst_idx).transaction_action_code := NULL;
     c_txn_tbl(inst_idx).object_version_number   := 1;

     inst_idx := inst_idx + 1;
     ELSE -- update candidate
       IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'CASE -update item instance id: '||l_instance_id);
      END IF;
        --u_instance_tbl(inst_idx).instance_id := l_instance_id;
        u_instance_tbl(u_inst_idx).instance_id := l_instance_id; --Added for open
     -- call resolve_update_ids
        BEGIN
        update csi_instance_interface
        set instance_id = l_instance_id
        where inst_interface_id = iface_Det_rec.inst_interface_id;
        END;

        u_inst_idx:=u_inst_idx+1; -- Added for open
     END IF;-- Added for open

        -- Added for open
           u_txn_rec.transaction_date := iface_det_rec.source_transaction_date;
           u_txn_rec.source_transaction_date := iface_det_rec.source_transaction_date;
     	   u_txn_rec.transaction_type_id:= l_txn_type_id;
           u_txn_rec.source_group_ref:= iface_det_rec.transaction_identifier;
     	   u_txn_rec.transaction_quantity:= iface_det_rec.quantity;
     	   u_txn_rec.transaction_uom_code:= iface_det_rec.unit_of_measure_code;
           u_txn_rec.transacted_by := iface_det_rec.created_by;
           u_txn_rec.transaction_status_code := 'COMPLETE';
           u_txn_rec.transaction_action_code := NULL;
           u_txn_rec.object_version_number   := 1;
         -- End addition for open
   END LOOP;

     IF u_instance_tbl.COUNT >0
     THEN
       IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Resolving Update Related Ids:');
      END IF;
        csi_ml_util_pvt.resolve_update_ids
             (p_source_system_name => p_source_system_name,
              p_txn_identifier => get_txns_rec.transaction_identifier,
              x_return_status => l_return_status,
              x_error_message => l_error_message);
         IF NOT l_return_status = l_fnd_success
         THEN
            FND_File.Put_Line(Fnd_File.LOG,'Error from csi_ml_util_pvt.resolve_update_ids');
            RAISE g_exc_error;
         END IF;

        csi_ml_update_pvt.populate_recs(
                  p_txn_identifier =>u_txn_rec.source_group_ref, --iface_det_rec.transaction_identifier,
                  p_source_system_name =>p_source_system_name,   -- modified txn_identifer for open
                  x_instance_tbl => u_instance_tbl,
                  x_party_tbl => u_party_tbl,
                  x_account_tbl => u_account_tbl,
                  x_ext_attrib_value_tbl => u_ext_attrib_tbl,
                  x_price_tbl => u_price_tbl,
                  x_org_assign_tbl => u_org_assignments_tbl,
                  x_asset_assignment_tbl => u_asset_assignment_tbl, -- bnarayan added for R12
                  x_return_status => l_return_status,
                  x_error_message=> l_error_message);


         IF NOT l_return_status = l_fnd_success
           THEN
            IF(l_debug_level>1) THEN
            FND_File.Put_Line(Fnd_File.LOG,'Error from csi_ml_update_pvt.populate_recs ');
            END IF;
            RAISE g_exc_error;
         END IF;
     END IF;
/*        Commented for open
      	   u_txn_rec.transaction_date := iface_det_rec.source_transaction_date;
     	   u_txn_rec.source_transaction_date := iface_det_rec.source_transaction_date;
     	   u_txn_rec.transaction_type_id:= l_txn_type_id;
           u_txn_rec.source_group_ref:= iface_det_rec.transaction_identifier;
     	   u_txn_rec.transaction_quantity:= iface_det_rec.quantity;
     	   u_txn_rec.transaction_uom_code:= iface_det_rec.unit_of_measure_code;
           u_txn_rec.transacted_by := iface_det_rec.created_by;
           u_txn_rec.transaction_status_code := 'COMPLETE';
           u_txn_rec.transaction_action_code := NULL;
           u_txn_rec.object_version_number   := 1;
           */
   --  END IF; -- End of Update or Create If -- commented for open
 --    END LOOP; -- commented for open

        IF c_instance_tbl.COUNT > 0
        THEN
        l_return_status := NULL;
        csi_item_instance_grp.create_item_instance (
 	  p_api_version           => l_api_version
   	 ,p_commit                => l_commit
         ,p_init_msg_list         => l_init_msg_list
         ,p_validation_level      => l_validation_level
   	 ,p_instance_tbl          => c_instance_tbl
   	 ,p_ext_attrib_values_tbl => c_ext_attrib_tbl
   	 ,p_party_tbl             => c_party_tbl
   	 ,p_account_tbl           => c_account_tbl
   	 ,p_pricing_attrib_tbl    => c_price_tbl
   	 ,p_org_assignments_tbl   => c_org_assign_tbl
   	 ,p_asset_assignment_tbl  => c_asset_assignment_tbl
   	 ,p_txn_tbl               => c_txn_tbl
   	 ,p_grp_error_tbl         => c_grp_error_tbl
   	 ,x_return_status         => l_return_status
   	 ,x_msg_count             => l_msg_count
   	 ,x_msg_data              => l_msg_data);

           IF NOT l_return_status = l_fnd_success
           THEN
     		l_msg_index := 1;
     		l_Error_Message := l_Msg_Data;
		WHILE l_msg_count > 0 LOOP
	  	   l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
          	   l_Msg_Count := l_Msg_Count - 1;
  	        END LOOP;
             RAISE g_exc_error;
           END IF;
     END IF;

     IF c_instance_tbl.COUNT >0
     THEN
        FOR  i in c_instance_tbl.FIRST .. c_instance_tbl.LAST
        LOOP
        IF c_instance_tbl.EXISTS(i)
        THEN
           IF c_instance_tbl(i).processed_flag = 'E'
           THEN
           RAISE g_inst_error;
           END IF;
        END IF;
        END LOOP;
     END IF;

     IF c_instance_tbl.COUNT >0
     THEN
        FOR i IN 1 .. c_instance_tbl.COUNT LOOP
           IF c_instance_tbl(i).instance_id IS NOT NULL
           THEN
             IF(l_debug_level>1) THEN
             FND_File.Put_Line(Fnd_File.LOG,'Instance Crearted with number : '||c_instance_tbl(i).instance_id);
             END IF;
           END IF;
        END LOOP;
     END IF;
        IF u_instance_tbl.COUNT > 0
        THEN
        csi_item_instance_grp.update_item_instance (
 	  p_api_version           => l_api_version
   	 ,p_commit                => l_commit
         ,p_init_msg_list         => l_init_msg_list
         ,p_validation_level      => l_validation_level
   	 ,p_instance_tbl          => u_instance_tbl
   	 ,p_ext_attrib_values_tbl => u_ext_attrib_tbl
   	 ,p_party_tbl             => u_party_tbl
   	 ,p_account_tbl           => u_account_tbl
   	 ,p_pricing_attrib_tbl    => u_price_tbl
   	 ,p_org_assignments_tbl   => u_org_assignments_tbl
   	 ,p_asset_assignment_tbl  => u_asset_assignment_tbl
   	 ,p_txn_rec               => u_txn_rec
         ,x_instance_id_lst       => u_instance_id_lst
         ,p_grp_upd_error_tbl     => u_grp_error_tbl
   	 ,x_return_status         => l_return_status
   	 ,x_msg_count             => l_msg_count
   	 ,x_msg_data              => l_msg_data);

         IF NOT l_return_status = l_fnd_success
         THEN
     		l_msg_index := 1;
     		l_Error_Message := l_Msg_Data;
		   WHILE l_msg_count > 0
           LOOP
	  	   l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
          	   l_Msg_Count := l_Msg_Count - 1;
  	       END LOOP;
             RAISE g_exc_error;
         END IF;
        END IF;

     IF u_instance_tbl.COUNT >0
     THEN
        FOR  i in u_instance_tbl.FIRST .. u_instance_tbl.LAST
        LOOP
        IF u_instance_tbl.EXISTS(i)
        THEN
           IF u_instance_tbl(i).processed_flag = 'E'
           THEN
           RAISE g_upd_error;
           ELSE
             UPDATE csi_instance_interface
             SET   process_status = 'P'
             WHERE instance_id = u_instance_tbl(i).instance_id;
           END IF;
        END IF;
        END LOOP;
     END IF;
     /*
     rel_idx := 1;
     c_relationship_tbl.DELETE;
     u_relationship_tbl.DELETE;
     FOR irel_det_rec IN irel_det_cur(get_txns_rec.transaction_identifier,
                                      p_source_system_name)
     LOOP
     check_rel_exists(irel_det_rec.new_subject_id,
                      irel_det_rec.new_object_id,
                      l_exists,
                      l_rel_rec);
     IF NOT l_exists
     THEN
          c_relationship_tbl(rel_idx).subject_id :=irel_det_rec.new_subject_id;
          c_relationship_tbl(rel_idx).object_id := irel_det_rec.new_object_id;
          c_relationship_tbl(rel_idx).relationship_type_code := irel_det_rec.relationship_type_code;
          c_relationship_tbl(rel_idx).active_start_date:=irel_det_rec.active_start_date;
          c_relationship_tbl(rel_idx).active_end_date:=irel_det_rec.active_end_date;
          c_relationship_tbl(rel_idx).position_reference:= irel_det_rec.position_reference;
          c_relationship_tbl(rel_idx).display_order:= irel_det_rec.display_order;
          c_relationship_tbl(rel_idx).object_version_number := 1;
          c_rel_txn_rec.transaction_date := irel_det_rec.source_transaction_date;
     	  c_rel_txn_rec.source_transaction_date := irel_det_rec.source_transaction_date;
     	  c_rel_txn_rec.transaction_type_id:= l_txn_type_id;
          c_rel_txn_rec.source_group_ref:= irel_det_rec.transaction_identifier;
     	  c_rel_txn_rec.transaction_quantity:= NULL;
     	  c_rel_txn_rec.transaction_uom_code:= NULL;
          c_rel_txn_rec.transacted_by := irel_det_rec.created_by;
          c_rel_txn_rec.transaction_status_code := 'COMPLETE';
          c_rel_txn_rec.transaction_action_code := NULL;
          c_rel_txn_rec.object_version_number   := 1;
       rel_idx := rel_idx + 1;
     ELSE
        u_relationship_tbl(rel_idx).relationship_id :=l_rel_rec.relationship_id;
        u_relationship_tbl(rel_idx).subject_id :=irel_det_rec.new_subject_id;
        u_relationship_tbl(rel_idx).object_id := irel_det_rec.new_object_id;
        u_relationship_tbl(rel_idx).object_version_number := l_rel_rec.object_version_number;
       /* Commented for bug 3150717
       IF NOT l_rel_rec.relationship_type_code = irel_det_rec.relationship_type_code
       THEN

       u_relationship_tbl(rel_idx).relationship_type_code := irel_det_rec.relationship_type_code;
       /*
       END IF;

       IF NOT l_rel_rec.active_start_date= irel_det_rec.active_start_date
       THEN
     	u_relationship_tbl(rel_idx).active_start_date:=irel_det_rec.active_start_date;
       END IF;
       IF NOT l_rel_rec.active_end_date= irel_det_rec.active_end_date
       THEN
     	u_relationship_tbl(rel_idx).active_end_date:=irel_det_rec.active_end_date;
       END IF;
       IF NOT l_rel_rec.position_reference= irel_det_rec.position_reference
       THEN
     	u_relationship_tbl(rel_idx).position_reference:= irel_det_rec.position_reference;
       END IF;
       IF NOT l_rel_rec.display_order= irel_det_rec.display_order
       THEN
         u_relationship_tbl(rel_idx).display_order:= irel_det_rec.display_order;
       END IF;
       IF NOT l_rel_rec.mandatory_flag= irel_det_rec.mandatory_flag
       THEN
         u_relationship_tbl(rel_idx).mandatory_flag:= irel_det_rec.mandatory_flag;
       END IF;
       IF NOT l_rel_rec.context = irel_det_rec.context
       THEN
     	 u_relationship_tbl(rel_idx).context:= irel_det_rec.context;
       END IF;
     --IF NOT l_rel_rec.relationship_direction= irel_det_rec.relationship_direction
     --THEN
     	--u_relationship_tbl(rel_idx).relationship_direction:= irel_det_rec.relationship_direction;
     --END IF;
       IF NOT l_rel_rec.attribute1 = irel_det_rec.attribute1
       THEN
     	u_relationship_tbl(rel_idx).attribute1 := irel_det_rec.attribute1;
       END IF;
       IF NOT l_rel_rec.attribute2 = irel_det_rec.attribute2
       THEN
     	u_relationship_tbl(rel_idx).attribute2 := irel_det_rec.attribute2;
       END IF;
       IF NOT l_rel_rec.attribute3 = irel_det_rec.attribute3
       THEN
     	u_relationship_tbl(rel_idx).attribute3 := irel_det_rec.attribute3;
       END IF;
       IF NOT l_rel_rec.attribute4 = irel_det_rec.attribute4
       THEN
     	u_relationship_tbl(rel_idx).attribute4 := irel_det_rec.attribute4;
       END IF;
       IF NOT l_rel_rec.attribute5 = irel_det_rec.attribute5
       THEN
     	u_relationship_tbl(rel_idx).attribute5 := irel_det_rec.attribute5;
       END IF;
       IF NOT l_rel_rec.attribute6 = irel_det_rec.attribute6
       THEN
     	u_relationship_tbl(rel_idx).attribute6 := irel_det_rec.attribute6;
       END IF;
       IF NOT l_rel_rec.attribute7 = irel_det_rec.attribute7
       THEN
     	u_relationship_tbl(rel_idx).attribute7 := irel_det_rec.attribute7;
       END IF;
       IF NOT l_rel_rec.attribute8 = irel_det_rec.attribute8
       THEN
     	u_relationship_tbl(rel_idx).attribute8 := irel_det_rec.attribute8;
       END IF;
       IF NOT l_rel_rec.attribute9 = irel_det_rec.attribute9
       THEN
     	u_relationship_tbl(rel_idx).attribute9 := irel_det_rec.attribute9;
       END IF;
       IF NOT l_rel_rec.attribute10 = irel_det_rec.attribute10
       THEN
     	u_relationship_tbl(rel_idx).attribute10 := irel_det_rec.attribute10;
       END IF;
       IF NOT l_rel_rec.attribute11 = irel_det_rec.attribute11
       THEN
     	u_relationship_tbl(rel_idx).attribute11 := irel_det_rec.attribute11;
       END IF;
       IF NOT l_rel_rec.attribute12 = irel_det_rec.attribute12
       THEN
     	u_relationship_tbl(rel_idx).attribute12 := irel_det_rec.attribute12;
       END IF;
       IF NOT l_rel_rec.attribute13 = irel_det_rec.attribute13
       THEN
     	u_relationship_tbl(rel_idx).attribute13 := irel_det_rec.attribute13;
       END IF;
       IF NOT l_rel_rec.attribute14 = irel_det_rec.attribute14
       THEN
     	u_relationship_tbl(rel_idx).attribute14 := irel_det_rec.attribute14;
       END IF;
       IF NOT l_rel_rec.attribute15 = irel_det_rec.attribute15
       THEN
     	u_relationship_tbl(rel_idx).attribute15 := irel_det_rec.attribute15;
       END IF;
      	   u_rel_txn_rec.transaction_date := irel_det_rec.source_transaction_date;
     	   u_rel_txn_rec.source_transaction_date := irel_det_rec.source_transaction_date;
     	   u_rel_txn_rec.transaction_type_id:= l_txn_type_id;
           u_rel_txn_rec.source_group_ref:= irel_det_rec.transaction_identifier;
     	   u_rel_txn_rec.transaction_quantity:= NULL;
     	   u_rel_txn_rec.transaction_uom_code:= NULL;
           u_rel_txn_rec.transacted_by := irel_det_rec.created_by;
           u_rel_txn_rec.transaction_status_code := 'COMPLETE';
           u_rel_txn_rec.transaction_action_code := NULL;
           u_rel_txn_rec.object_version_number   := 1;
     rel_idx := rel_idx + 1;
     END IF;
   END LOOP;

    IF c_relationship_tbl.COUNT>0
    THEN
      FND_File.Put_Line(Fnd_File.LOG,'creating relationships :');
         csi_ii_relationships_pub.create_relationship(
 	  p_api_version           => l_api_version
   	 ,p_commit                => l_commit
         ,p_init_msg_list         => l_init_msg_list
         ,p_validation_level      => l_validation_level
   	 ,p_relationship_tbl      => c_relationship_tbl
   	 ,p_txn_rec               => c_rel_txn_rec
   	 ,x_return_status         => l_return_status
   	 ,x_msg_count             => l_msg_count
   	 ,x_msg_data              => l_msg_data);

           IF NOT l_return_status = l_fnd_success
           THEN
     		l_msg_index := 1;
     		l_Error_Message := l_Msg_Data;
		WHILE l_msg_count > 0 LOOP
	  	   l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
          	   l_Msg_Count := l_Msg_Count - 1;
  	        END LOOP;
             RAISE g_exc_error;
           END IF;
         END IF;

         IF u_relationship_tbl.COUNT>0
         THEN

      FND_File.Put_Line(Fnd_File.LOG,'updating relationships :');
         csi_ii_relationships_pub.update_relationship(
 	  p_api_version           => l_api_version
   	 ,p_commit                => l_commit
         ,p_init_msg_list         => l_init_msg_list
         ,p_validation_level      => l_validation_level
   	 ,p_relationship_tbl      => u_relationship_tbl
   	 ,p_txn_rec               => u_rel_txn_rec
   	 ,x_return_status         => l_return_status
   	 ,x_msg_count             => l_msg_count
   	 ,x_msg_data              => l_msg_data);

           IF NOT l_return_status = l_fnd_success
           THEN
     		l_msg_index := 1;
     		l_Error_Message := l_Msg_Data;
		WHILE l_msg_count > 0 LOOP
	  	   l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
	           l_msg_index := l_msg_index + 1;
          	   l_Msg_Count := l_Msg_Count - 1;
  	        END LOOP;
             RAISE g_exc_error;
           END IF;
         END IF;

*/
   l_success_count := l_success_count + 1;  --Bug No: 9260500.  removed this out of comment
   COMMIT;
   EXCEPTION
   WHEN g_inst_error THEN
      ROLLBACK TO s_txnbegin;
      UPDATE_INTERFACE_TBL(c_instance_tbl,
                           c_grp_error_tbl);
      l_failure_count := l_failure_count +1;

   WHEN g_upd_error THEN
      ROLLBACK TO s_txnbegin;
      UPDATE_INTERFACE_TBL(u_instance_tbl,
                           u_grp_error_tbl);
      l_failure_count := l_failure_count +1;

   WHEN g_exc_error THEN
      FND_File.Put_Line(Fnd_File.LOG,'error:'||l_error_message);
      ROLLBACK TO s_txnbegin;
      UPDATE csi_instance_interface
      SET process_Status = 'E',
          error_text = l_error_message
      WHERE transaction_identifier = get_txns_rec.transaction_identifier
      AND   source_system_name = p_source_system_name;
   l_failure_count := l_failure_count +1;
   END;
 END LOOP;

  l_return_status := fnd_api.g_ret_sts_success;

IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'No of Transactions Processed :'||l_txn_count);
  FND_File.Put_Line(Fnd_File.LOG,'No of successful Transactions :'||l_success_count);
  FND_File.Put_Line(Fnd_File.LOG,'No of failed Transactions :'||l_failure_count);
END IF;

 BEGIN
 -- Added for releationships
     SELECT count(*)
       INTO l_found
       FROM csi_ii_relation_interface
      WHERE process_status='R';

    IF l_found>0
    THEN

           csi_ml_util_pvt.resolve_rel_ids
           (p_source_system => p_source_system_name
           ,p_txn_from_date => p_txn_from_date
           ,p_txn_to_date   => p_txn_to_date
           ,x_return_status => l_return_status
           ,x_error_message => l_error_message
            );
  -- Need to check l_error_message
   IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'Start for creating rel in single thread :'||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
  END IF;
     FOR irel_det_rec IN irel_det_cur
     LOOP
     check_rel_exists(irel_det_rec.subject_id,
                      irel_det_rec.object_id,
                      l_exists,
                      l_rel_rec);
     SAVEPOINT create_update_relship;
     l_counter:=l_counter+1;
     IF NOT l_exists
     THEN
          c_relationship_tbl.DELETE;
          c_relationship_tbl(1).subject_id :=irel_det_rec.subject_id;
          c_relationship_tbl(1).object_id := irel_det_rec.object_id;
          c_relationship_tbl(1).relationship_type_code := irel_det_rec.relationship_type_code;
          c_relationship_tbl(1).active_start_date:=irel_det_rec.active_start_date;
          c_relationship_tbl(1).active_end_date:=irel_det_rec.active_end_date;
          c_relationship_tbl(1).position_reference:= irel_det_rec.position_reference;
          c_relationship_tbl(1).display_order:= irel_det_rec.display_order;
          c_relationship_tbl(1).object_version_number := 1;
          c_rel_txn_rec.transaction_date := sysdate; --irel_det_rec.source_transaction_date;
     	  c_rel_txn_rec.source_transaction_date :=sysdate; -- irel_det_rec.source_transaction_date;
     	  c_rel_txn_rec.transaction_type_id:= l_txn_type_id;
          --c_rel_txn_rec.source_group_ref:= irel_det_rec.transaction_identifier;
     	  c_rel_txn_rec.transaction_quantity:= NULL;
     	  c_rel_txn_rec.transaction_uom_code:= NULL;
          c_rel_txn_rec.transacted_by := -1; --irel_det_rec.created_by;
          c_rel_txn_rec.transaction_status_code := 'COMPLETE';
          c_rel_txn_rec.transaction_action_code := NULL;
          c_rel_txn_rec.object_version_number   := 1;
IF(l_debug_level>1) THEN
         FND_File.Put_Line(Fnd_File.LOG,'creating relationships :');
END IF;

         csi_ii_relationships_pvt.create_relationship(
            p_api_version        => l_api_version
           ,p_commit             => l_commit
           ,p_init_msg_list      => l_init_msg_list
           ,p_validation_level   => l_validation_level
           ,p_relationship_tbl   => c_relationship_tbl
           ,p_txn_rec            => c_rel_txn_rec
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data);

           IF NOT l_return_status = l_fnd_success
           THEN
            l_msg_index := 1;
            l_Error_Message := l_Msg_Data;
              WHILE l_msg_count > 0 LOOP
                l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                l_msg_index := l_msg_index + 1;
                l_Msg_Count := l_Msg_Count - 1;
              END LOOP;
             --RAISE g_exc_error;
             UPDATE csi_ii_relation_interface
                SET process_status ='E'
                   ,error_text = l_Error_Message
              WHERE rel_interface_id = irel_det_rec.rel_interface_id;
               l_rel_failure_count := l_rel_failure_count +1;
           ELSE
             UPDATE csi_ii_relation_interface
                SET process_status ='P'
              WHERE rel_interface_id = irel_det_rec.rel_interface_id;
               l_rel_success_count := l_rel_success_count + 1;
           END IF;
     ELSE
        u_relationship_tbl.DELETE;
        u_relationship_tbl(1).relationship_id :=l_rel_rec.relationship_id;
        u_relationship_tbl(1).subject_id :=irel_det_rec.subject_id;
        u_relationship_tbl(1).object_id := irel_det_rec.object_id;
        u_relationship_tbl(1).object_version_number := l_rel_rec.object_version_number;
        u_relationship_tbl(1).relationship_type_code := irel_det_rec.relationship_type_code;

       IF NOT l_rel_rec.active_start_date= irel_det_rec.active_start_date
       THEN
     	u_relationship_tbl(1).active_start_date:=irel_det_rec.active_start_date;
       END IF;
       IF NOT l_rel_rec.active_end_date= irel_det_rec.active_end_date
       THEN
     	u_relationship_tbl(1).active_end_date:=irel_det_rec.active_end_date;
       END IF;
       IF NOT l_rel_rec.position_reference= irel_det_rec.position_reference
       THEN
     	u_relationship_tbl(1).position_reference:= irel_det_rec.position_reference;
       END IF;
       IF NOT l_rel_rec.display_order= irel_det_rec.display_order
       THEN
         u_relationship_tbl(1).display_order:= irel_det_rec.display_order;
       END IF;
       IF NOT l_rel_rec.mandatory_flag= irel_det_rec.mandatory_flag
       THEN
         u_relationship_tbl(1).mandatory_flag:= irel_det_rec.mandatory_flag;
       END IF;
       IF NOT l_rel_rec.context = irel_det_rec.context
       THEN
     	 u_relationship_tbl(1).context:= irel_det_rec.context;
       END IF;

       IF NOT l_rel_rec.attribute1 = irel_det_rec.attribute1
       THEN
     	u_relationship_tbl(1).attribute1 := irel_det_rec.attribute1;
       END IF;
       IF NOT l_rel_rec.attribute2 = irel_det_rec.attribute2
       THEN
     	u_relationship_tbl(1).attribute2 := irel_det_rec.attribute2;
       END IF;
       IF NOT l_rel_rec.attribute3 = irel_det_rec.attribute3
       THEN
     	u_relationship_tbl(1).attribute3 := irel_det_rec.attribute3;
       END IF;
       IF NOT l_rel_rec.attribute4 = irel_det_rec.attribute4
       THEN
     	u_relationship_tbl(1).attribute4 := irel_det_rec.attribute4;
       END IF;
       IF NOT l_rel_rec.attribute5 = irel_det_rec.attribute5
       THEN
     	u_relationship_tbl(1).attribute5 := irel_det_rec.attribute5;
       END IF;
       IF NOT l_rel_rec.attribute6 = irel_det_rec.attribute6
       THEN
     	u_relationship_tbl(1).attribute6 := irel_det_rec.attribute6;
       END IF;
       IF NOT l_rel_rec.attribute7 = irel_det_rec.attribute7
       THEN
     	u_relationship_tbl(1).attribute7 := irel_det_rec.attribute7;
       END IF;
       IF NOT l_rel_rec.attribute8 = irel_det_rec.attribute8
       THEN
     	u_relationship_tbl(1).attribute8 := irel_det_rec.attribute8;
       END IF;
       IF NOT l_rel_rec.attribute9 = irel_det_rec.attribute9
       THEN
     	u_relationship_tbl(1).attribute9 := irel_det_rec.attribute9;
       END IF;
       IF NOT l_rel_rec.attribute10 = irel_det_rec.attribute10
       THEN
     	u_relationship_tbl(1).attribute10 := irel_det_rec.attribute10;
       END IF;
       IF NOT l_rel_rec.attribute11 = irel_det_rec.attribute11
       THEN
     	u_relationship_tbl(1).attribute11 := irel_det_rec.attribute11;
       END IF;
       IF NOT l_rel_rec.attribute12 = irel_det_rec.attribute12
       THEN
     	u_relationship_tbl(1).attribute12 := irel_det_rec.attribute12;
       END IF;
       IF NOT l_rel_rec.attribute13 = irel_det_rec.attribute13
       THEN
     	u_relationship_tbl(1).attribute13 := irel_det_rec.attribute13;
       END IF;
       IF NOT l_rel_rec.attribute14 = irel_det_rec.attribute14
       THEN
     	u_relationship_tbl(1).attribute14 := irel_det_rec.attribute14;
       END IF;
       IF NOT l_rel_rec.attribute15 = irel_det_rec.attribute15
       THEN
     	u_relationship_tbl(1).attribute15 := irel_det_rec.attribute15;
       END IF;
      	   u_rel_txn_rec.transaction_date :=sysdate; -- irel_det_rec.source_transaction_date;
     	   u_rel_txn_rec.source_transaction_date := sysdate; --irel_det_rec.source_transaction_date;
     	   u_rel_txn_rec.transaction_type_id:= l_txn_type_id;
           --u_rel_txn_rec.source_group_ref:= irel_det_rec.transaction_identifier;
     	   u_rel_txn_rec.transaction_quantity:= NULL;
     	   u_rel_txn_rec.transaction_uom_code:= NULL;
           u_rel_txn_rec.transacted_by := -1; --irel_det_rec.created_by;
           u_rel_txn_rec.transaction_status_code := 'COMPLETE';
           u_rel_txn_rec.transaction_action_code := NULL;
           u_rel_txn_rec.object_version_number   := 1;

      IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'updating relationships :');
      END IF;
         csi_ii_relationships_pvt.update_relationship
          ( p_api_version        => l_api_version
           ,p_commit             => l_commit
           ,p_init_msg_list      => l_init_msg_list
           ,p_validation_level   => l_validation_level
           ,p_relationship_tbl   => u_relationship_tbl
           ,p_txn_rec            => u_rel_txn_rec
           ,x_return_status      => l_return_status
           ,x_msg_count          => l_msg_count
           ,x_msg_data           => l_msg_data
           );


           IF NOT l_return_status = l_fnd_success
           THEN
     		l_msg_index := 1;
     		l_Error_Message := l_Msg_Data;
             WHILE l_msg_count > 0 LOOP
               l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
               l_msg_index := l_msg_index + 1;
               l_Msg_Count := l_Msg_Count - 1;
             END LOOP;
             --RAISE g_exc_error;
             UPDATE csi_ii_relation_interface
                SET process_status ='E'
                   ,error_text = l_Error_Message
              WHERE rel_interface_id = irel_det_rec.rel_interface_id;
                 l_rel_failure_count := l_rel_failure_count +1;
           ELSE
             UPDATE csi_ii_relation_interface
                SET process_status ='P'
              WHERE rel_interface_id = irel_det_rec.rel_interface_id;
                 l_rel_success_count := l_rel_success_count + 1;
           END IF;
     END IF;
     IF mod(l_counter,1000)=0
     THEN
       COMMIT;
     END IF;
   END LOOP;
  IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'End for creating rel in single thread :'||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
  FND_File.Put_Line(Fnd_File.LOG,'No of relation transactions processed  :'||l_found);
  FND_File.Put_Line(Fnd_File.LOG,'No of successful relation transactions :'||l_rel_success_count);
  FND_File.Put_Line(Fnd_File.LOG,'No of failed relation transactions :'||l_rel_failure_count);
  END IF;
    END IF;
   EXCEPTION
     WHEN g_exc_error THEN
       ROLLBACK TO create_update_relship;
   END;
   COMMIT;


 -- End addition for relationships


 EXCEPTION
   WHEN g_exc_error THEN
      x_return_status := l_return_status;
      x_error_message := l_error_message;
   WHEN others THEN
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := l_fnd_unexpected;

END process_iface_txns;

END CSI_ML_INTERFACE_TXN_PVT;

/
