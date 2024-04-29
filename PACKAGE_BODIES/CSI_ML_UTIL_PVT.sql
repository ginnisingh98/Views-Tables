--------------------------------------------------------
--  DDL for Package Body CSI_ML_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_UTIL_PVT" AS
-- $Header: csimutlb.pls 120.7 2007/10/31 00:49:13 anjgupta ship $

PROCEDURE resolve_ids
 (  p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_batch_name            IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2) IS

l_txn_from_date   DATE := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_txn_to_date     DATE := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');

 CURSOR ins_intf_cur IS
  SELECT inst_interface_id
    FROM csi_instance_interface
   WHERE trunc(source_transaction_date)
 BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
     AND nvl(l_txn_to_date,trunc(source_transaction_date))
     AND process_status  IN ('X','R')
     AND parallel_worker_id IS NULL
     AND transaction_identifier IS NOT NULL
     AND source_system_name = nvl(p_source_system_name,source_system_name);

 CURSOR pty1_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.party_source_table = 'HZ_PARTIES'
     AND cpi.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier IS NOT NULL
                                       AND trunc(source_transaction_date)
                                   BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                       AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                       AND process_status IN ('X','R')
                                       AND parallel_worker_id IS NULL
                                       AND source_system_name =
                                           nvl(p_source_system_name,source_system_name));
 CURSOR pty2_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.party_source_table = 'EMPLOYEE'
     AND cpi.inst_interface_id IN (SELECT inst_interface_id
                                     FROM csi_instance_interface cii
                                    WHERE cii.transaction_identifier IS NOT NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status IN ('X','R')
                                      AND parallel_worker_id IS NULL
                                      AND source_system_name =
                                          nvl(p_source_system_name,source_system_name));
 CURSOR pty3_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.inst_interface_id IN (SELECT inst_interface_id
                                     FROM csi_instance_interface cii
                                    WHERE cii.transaction_identifier IS NOT NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status IN ('X','R')
                                      AND parallel_worker_id IS NULL
                                      AND source_system_name =
                                          nvl(p_source_system_name,source_system_name));
 CURSOR iea_intf_cur IS
  SELECT ieav_interface_id
    FROM csi_iea_value_interface a
   WHERE a.attribute_level = 'ITEM'
     AND a.inst_interface_id IN (SELECT inst_interface_id
                                   FROM csi_instance_interface cii
                                  WHERE cii.transaction_identifier IS NOT NULL
                                    AND trunc(source_transaction_date)
                                BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                    AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                    AND process_status IN ('X','R')
                                    AND parallel_worker_id IS NULL
                                    AND source_system_name =
                                        nvl(p_source_system_name,source_system_name));

 CURSOR asst_intf_cur IS
  SELECT ia_interface_id
    FROM csi_i_asset_interface a
   WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                   FROM csi_instance_interface cii
                                  WHERE cii.transaction_identifier IS NOT NULL
                                    AND trunc(source_transaction_date)
                                BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                    AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                    AND process_status IN ('X','R')
                                    AND parallel_worker_id IS NULL
                                    AND source_system_name =
                                        nvl(p_source_system_name,source_system_name));

  TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   inst_intf_id_upd         NumTabType;
   ip_intf_id_upd1          NumTabType;
   ip_intf_id_upd2          NumTabType;
   ip_intf_id_upd3          NumTabType;
   iea_intf_id_upd          NumTabType;
   asst_intf_id_upd         NumTabType;
   max_buffer_size          NUMBER := 1000;

l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.RESOLVE_IDS';
l_fnd_success     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
l_fnd_g_num       NUMBER      := FND_API.G_MISS_NUM;
l_fnd_g_char      VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_fnd_g_date      DATE        := FND_API.G_MISS_DATE;
l_sql_error       VARCHAR2(2000);
BEGIN

  x_return_status := l_fnd_success;
  -- Get the source system id for all of the rows

   OPEN ins_intf_cur;
   LOOP
      FETCH ins_intf_cur BULK COLLECT INTO
      inst_intf_id_upd
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.inventory_item_id =
                                (SELECT inventory_item_id
                                   FROM mtl_system_items_kfv
                                  WHERE concatenated_segments =
                                        a.inv_concatenated_segments
                                    AND ROWNUM=1)
         WHERE inst_interface_id=inst_intf_id_upd(i1)
           AND a.inventory_item_id IS NULL
           AND a.inv_concatenated_segments IS NOT NULL;

      FORALL i2 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.inv_vld_organization_id =
                                (SELECT organization_id
                                   FROM hr_all_organization_units
                                  WHERE name = a.inv_vld_organization_name)
         WHERE inst_interface_id=inst_intf_id_upd(i2)
           AND a.inv_vld_organization_id IS NULL
           AND a.inv_vld_organization_name IS NOT NULL;

      FORALL i3 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.instance_condition_id =
                                (SELECT status_id
                                   FROM mtl_material_statuses
                                  WHERE status_code = a.instance_condition)
         WHERE inst_interface_id=inst_intf_id_upd(i3)
           AND a.instance_condition_id IS NULL
           AND a.instance_condition IS NOT NULL;

      FORALL i4 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.instance_status_id =
                                (SELECT instance_status_id
                                   FROM csi_instance_statuses
                                  WHERE name = a.instance_status)
         WHERE inst_interface_id=inst_intf_id_upd(i4)
           AND a.instance_status_id IS NULL
           AND a.instance_status IS NOT NULL;


      FORALL i6 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.system_id =    (SELECT system_id
                                   FROM csi_systems_b
                                  WHERE system_number = a.system_number)
         WHERE inst_interface_id=inst_intf_id_upd(i6)
           AND a.system_id IS NULL
           AND a.system_number IS NOT NULL;

      FORALL i7 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.unit_of_measure_code =
                                (SELECT uom_code
                                   FROM mtl_units_of_measure_vl
                                  WHERE unit_of_measure_tl = a.unit_of_measure)
         WHERE inst_interface_id=inst_intf_id_upd(i7)
           AND a.unit_of_measure_code IS NULL
           AND a.unit_of_measure IS NOT NULL;

      FORALL i8 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.inv_organization_id =
                                (SELECT organization_id
                                   FROM hr_all_organization_units
                                  WHERE NAME = a.inv_organization_name)
         WHERE inst_interface_id=inst_intf_id_upd(i8)
           AND a.inv_organization_id IS NULL
           AND a.inv_organization_name IS NOT NULL;

      FORALL i9 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.project_id =   (SELECT project_id
                                   FROM pa_projects_all
                                  WHERE segment1 = a.project_number)
         WHERE inst_interface_id=inst_intf_id_upd(i9)
           AND a.project_id IS NULL
           AND a.project_number IS NOT NULL;

      FORALL i10 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.task_id   =    (SELECT task_id
                                   FROM pa_tasks pt,
                                        pa_projects_all pp
                                  WHERE pt.task_number = a.task_number
                                    AND pp.segment1 = a.project_number
                                    AND pt.project_id = pp.project_id)
         WHERE inst_interface_id=inst_intf_id_upd(i10)
           AND a.task_id IS NULL
           AND a.task_number IS NOT NULL
           AND a.project_number IS NOT NULL;

      FORALL i11 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.wip_job_id  =  (SELECT wip_entity_id
                                   FROM wip_entities
                                  WHERE wip_entity_name = a.wip_job_name)
         WHERE inst_interface_id=inst_intf_id_upd(i11)
           AND a.wip_job_id IS NULL
           AND a.wip_job_name IS NOT NULL;


      FORALL i16 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.operating_unit=(SELECT organization_id
                                   FROM hr_operating_units
                                  WHERE name = a.operating_unit_name)
         WHERE inst_interface_id=inst_intf_id_upd(i16)
           AND a.operating_unit IS NULL
           AND a.operating_unit_name IS NOT NULL;

       COMMIT;
       EXIT WHEN ins_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE ins_intf_cur;

   OPEN pty1_intf_cur;
   LOOP
      FETCH pty1_intf_cur BULK COLLECT INTO
      ip_intf_id_upd1
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd1.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_id  =  (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.party_name
                                    AND party_number = NVL(cpi.party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd1(i1)
           AND cpi.party_id IS NULL
           AND cpi.party_name IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd1.count
        UPDATE csi_i_party_interface cpi
           SET cpi.contact_party_id =
                                (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.contact_party_name
                                    AND party_number = NVL(cpi.contact_party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd1(i2)
           AND cpi.contact_party_id IS NULL
           AND cpi.contact_party_name IS NOT NULL;

       COMMIT;
       EXIT WHEN pty1_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty1_intf_cur;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id=(SELECT vendor_id
                       FROM po_vendors
                      WHERE vendor_name = cpi.party_name
                     )
     WHERE cpi.party_source_table = 'PO_VENDORS'
       AND cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier IS NOT NULL
                                        AND trunc(source_transaction_date)
                                    BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                        AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                        AND process_status IN ('X','R')
                                        AND parallel_worker_id IS NULL
                                        AND source_system_name =
                                            nvl(p_source_system_name,source_system_name))
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

   OPEN pty2_intf_cur;
   LOOP
      FETCH pty2_intf_cur BULK COLLECT INTO
      ip_intf_id_upd2
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd2.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_id  =  (SELECT person_id
                                   FROM per_all_people_f
                                  WHERE full_name = cpi.party_name)
         WHERE ip_interface_id=ip_intf_id_upd2(i1)
           AND cpi.party_id IS NULL
           AND cpi.party_name IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd2.count
        UPDATE csi_i_party_interface cpi
           SET cpi.contact_party_id=
                                (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.contact_party_name
                                    AND party_number = NVL(cpi.contact_party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd2(i2)
           AND cpi.contact_party_id IS NULL
           AND cpi.contact_party_name IS NOT NULL;

       COMMIT;
       EXIT WHEN pty2_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty2_intf_cur;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id=(SELECT team_id
                       FROM jtf_rs_teams_vl
                      WHERE team_name = cpi.party_name)
     WHERE cpi.party_source_table = 'TEAM'
       AND cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier IS NOT NULL
                                        AND trunc(source_transaction_date)
                                    BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                        AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                        AND parallel_worker_id IS NULL
                                        AND source_system_name = nvl(p_source_system_name,source_system_name))
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT group_id
                         FROM jtf_rs_groups_vl
                        WHERE group_name = cpi.party_name)
     WHERE cpi.party_source_table = 'GROUP'
       AND cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier IS NOT NULL
                                        AND trunc(source_transaction_date)
                                    BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                        AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                        AND process_status IN ('X','R')
                                        AND parallel_worker_id IS NULL
                                        AND source_system_name = nvl(p_source_system_name,source_system_name))
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

   OPEN pty3_intf_cur;
   LOOP
      FETCH pty3_intf_cur BULK COLLECT INTO
      ip_intf_id_upd3
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account1_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account1_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i1)
           AND cpi.party_account1_id IS NULL
           AND cpi.party_account1_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account2_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account2_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i2)
           AND cpi.party_account2_id IS NULL
           AND cpi.party_account2_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

      FORALL i3 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account3_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account3_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i3)
           AND cpi.party_account3_id IS NULL
           AND cpi.party_account3_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

       COMMIT;
       EXIT WHEN pty3_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty3_intf_cur;


   OPEN asst_intf_cur;
   LOOP
      FETCH asst_intf_cur BULK COLLECT INTO
	  asst_intf_id_upd
      LIMIT max_buffer_size;

      FORALL asst1 in 1 .. asst_intf_id_upd.count
        UPDATE csi_i_asset_interface a
           SET a.fa_asset_id =  (SELECT asset_id
                                   FROM fa_additions_b
                                  WHERE asset_number =
                                        a.fa_asset_number
                                    )
         WHERE a.ia_interface_id=asst_intf_id_upd(asst1)
           AND a.fa_asset_id IS NULL
           AND a.fa_asset_number IS NOT NULL;
       COMMIT;
       EXIT WHEN asst_intf_cur%NOTFOUND;
   END LOOP;


     -- Extended Attribute Interface Table Values

  BEGIN
   OPEN iea_intf_cur;
   LOOP
      FETCH iea_intf_cur BULK COLLECT INTO
      iea_intf_id_upd
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. iea_intf_id_upd.count
        UPDATE csi_iea_value_interface a
           SET a.inventory_item_id    =
                                (SELECT inventory_item_id
                                   FROM mtl_system_items_kfv
                                  WHERE concatenated_segments =
                                        a.inv_concatenated_segments
                                    AND ROWNUM=1)
         WHERE ieav_interface_id=iea_intf_id_upd(i1)
           AND a.inventory_item_id IS NULL
           AND a.inv_concatenated_segments IS NOT NULL;

      FORALL i2 in 1 .. iea_intf_id_upd.count
        UPDATE csi_iea_value_interface a
           SET a.master_organization_id =
                                (SELECT organization_id
                                   FROM hr_all_organization_units
                                  WHERE name = master_organization_name)
         WHERE ieav_interface_id=iea_intf_id_upd(i2)
           AND a.master_organization_id IS NULL
           AND master_organization_name IS NOT NULL;

       COMMIT;
       EXIT WHEN iea_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE iea_intf_cur;

     UPDATE csi_iea_value_interface a
        SET a.attribute_id=(SELECT attribute_id
                              FROM csi_i_extended_attribs
                             WHERE attribute_level = a.attribute_level
                               AND attribute_code = a.attribute_code)
     WHERE a.attribute_level = 'GLOBAL'
       AND a.inst_interface_id IN (SELECT inst_interface_id
                                     FROM csi_instance_interface cii
                                    WHERE cii.transaction_identifier IS NOT NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status IN ('X','R')
                                      AND parallel_worker_id IS NULL
                                      AND source_system_name = nvl(p_source_system_name,source_system_name))
       AND a.attribute_id IS NULL
       AND a.attribute_level IS NOT NULL
       AND a.attribute_code IS NOT NULL;

     UPDATE csi_iea_value_interface a
        SET a.attribute_id  = (SELECT attribute_id
                                 FROM csi_i_extended_attribs
                                WHERE attribute_level = a.attribute_level
                                  AND attribute_code = a.attribute_code
                                  AND inventory_item_id = a.inventory_item_id
                                  AND a.attribute_id IS NULL
                                  AND master_organization_id = a.master_organization_id
                                  AND NVL(attribute_category,'$CSI_NULL_VALUE$')=
                                      NVL(a.attribute_category,'$CSI_NULL_VALUE$'))
     WHERE a.attribute_level = 'ITEM'
       AND a.inst_interface_id IN (SELECT inst_interface_id
                                     FROM csi_instance_interface cii
                                    WHERE cii.transaction_identifier IS NOT NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status IN ('X','R')
                                      AND parallel_worker_id IS NULL
                                      AND source_system_name = nvl(p_source_system_name,source_system_name))
       AND a.attribute_id IS NULL
       AND a.attribute_level IS NOT NULL
       AND a.attribute_code IS NOT NULL
       AND a.inventory_item_id IS NOT NULL;

  EXCEPTION
   WHEN others THEN
       fnd_message.set_name('CSI','CSI_ML_EXT_ATTR_ID_ERROR');
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;
  END;

    EXCEPTION
     WHEN others THEN
       l_sql_error := SQLERRM;
       fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;

END resolve_ids;

PROCEDURE resolve_pw_ids
 (
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_worker_id             IN     NUMBER,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2) IS

l_txn_from_date   DATE := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_txn_to_date     DATE := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');

 CURSOR ins_intf_cur IS
  SELECT inst_interface_id
    FROM csi_instance_interface
   WHERE trunc(source_transaction_date)
 BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
     AND nvl(l_txn_to_date,trunc(source_transaction_date))
     AND nvl(transaction_identifier,'-1') = '-1'
     AND process_status = 'X'
     AND source_system_name = nvl(p_source_system_name,source_system_name)
     AND parallel_worker_id = p_worker_id;

 CURSOR pty1_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.party_source_table = 'HZ_PARTIES'
      AND cpi.inst_interface_id IN (SELECT inst_interface_Id
                                      FROM csi_instance_interface
                                     WHERE transaction_identifier IS NULL
                                       AND trunc(source_transaction_date)
                                   BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                       AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                       AND process_status = 'X'
                                       AND source_system_name =
                                           nvl(p_source_system_name,source_system_name)
                                       AND parallel_worker_id = p_worker_id);

 CURSOR pty2_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.party_source_table = 'EMPLOYEE'
     AND cpi.inst_interface_id IN (SELECT inst_interface_Id
                                     FROM csi_instance_interface
                                    WHERE transaction_identifier IS NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status = 'X'
                                      AND source_system_name = nvl(p_source_system_name,source_system_name)
                                      AND parallel_worker_id = p_worker_id);
 CURSOR pty3_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.inst_interface_id IN (SELECT inst_interface_Id
                                     FROM csi_instance_interface
                                    WHERE transaction_identifier IS NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status = 'X'
                                      AND source_system_name = nvl(p_source_system_name,source_system_name)
                                      AND parallel_worker_id = p_worker_id);

 CURSOR iea_intf_cur IS
  SELECT ieav_interface_id
    FROM csi_iea_value_interface a
   WHERE a.attribute_level = 'ITEM'
     AND a.inst_interface_id IN (SELECT inst_interface_Id
                                   FROM csi_instance_interface
                                  WHERE transaction_identifier IS NULL
                                    AND trunc(source_transaction_date)
                                BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                    AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                    AND process_status = 'X'
                                    AND source_system_name = nvl(p_source_system_name,source_system_name)
                                    AND parallel_worker_id = p_worker_id);

 CURSOR asst_intf_cur IS
  SELECT ia_interface_id
    FROM csi_i_asset_interface a
   WHERE a.inst_interface_id IN (SELECT inst_interface_Id
                                   FROM csi_instance_interface
                                  WHERE transaction_identifier IS NULL
                                    AND trunc(source_transaction_date)
                                BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                    AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                    AND process_status = 'X'
                                    AND source_system_name = nvl(p_source_system_name,source_system_name)
                                    AND parallel_worker_id = p_worker_id);

  TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   inst_intf_id_upd         NumTabType;
   ip_intf_id_upd1          NumTabType;
   ip_intf_id_upd2          NumTabType;
   ip_intf_id_upd3          NumTabType;
   iea_intf_id_upd          NumTabType;
   asst_intf_id_upd         NumTabType;
   max_buffer_size          NUMBER := 1000;

l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.RESOLVE_IDS';
l_fnd_success     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
l_fnd_g_num       NUMBER      := FND_API.G_MISS_NUM;
l_fnd_g_char      VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_fnd_g_date      DATE        := FND_API.G_MISS_DATE;
l_sql_error       VARCHAR2(2000);

BEGIN

  x_return_status := l_fnd_success;

  -- Get the source system id for all of the rows

  -- Get all of the ID values in the Interface Tables where the source system
  -- has the derive id flag = Y
   OPEN ins_intf_cur;
   LOOP
      FETCH ins_intf_cur BULK COLLECT INTO
      inst_intf_id_upd
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.inventory_item_id =
                                (SELECT inventory_item_id
                                   FROM mtl_system_items_kfv
                                  WHERE concatenated_segments =
                                        a.inv_concatenated_segments
                                    AND ROWNUM=1)
         WHERE inst_interface_id=inst_intf_id_upd(i1)
           AND a.inventory_item_id IS NULL
           AND a.inv_concatenated_segments IS NOT NULL;

      FORALL i2 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.inv_vld_organization_id =
                                (SELECT organization_id
                                   FROM hr_all_organization_units
                                  WHERE name = a.inv_vld_organization_name)
         WHERE inst_interface_id=inst_intf_id_upd(i2)
           AND a.inv_vld_organization_id IS NULL
           AND a.inv_vld_organization_name IS NOT NULL;

      FORALL i3 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.instance_condition_id =
                                (SELECT status_id
                                   FROM mtl_material_statuses
                                  WHERE status_code = a.instance_condition)
         WHERE inst_interface_id=inst_intf_id_upd(i3)
           AND a.instance_condition_id IS NULL
           AND a.instance_condition IS NOT NULL;

      FORALL i4 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.instance_status_id =
                                (SELECT instance_status_id
                                   FROM csi_instance_statuses
                                  WHERE name = a.instance_status)
         WHERE inst_interface_id=inst_intf_id_upd(i4)
           AND a.instance_status_id IS NULL
           AND a.instance_status IS NOT NULL;

      FORALL i6 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.system_id =    (SELECT system_id
                                   FROM csi_systems_b
                                  WHERE system_number = a.system_number)
         WHERE inst_interface_id=inst_intf_id_upd(i6)
           AND a.system_id IS NULL
           AND a.system_number IS NOT NULL;

      FORALL i7 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.unit_of_measure_code =
                                (SELECT uom_code
                                   FROM mtl_units_of_measure_vl
                                  WHERE unit_of_measure_tl = a.unit_of_measure)
         WHERE inst_interface_id=inst_intf_id_upd(i7)
           AND a.unit_of_measure_code IS NULL
           AND a.unit_of_measure IS NOT NULL;

      FORALL i8 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.inv_organization_id =
                                (SELECT organization_id
                                   FROM hr_all_organization_units
                                  WHERE NAME = a.inv_organization_name)
         WHERE inst_interface_id=inst_intf_id_upd(i8)
           AND a.inv_organization_id IS NULL
           AND a.inv_organization_name IS NOT NULL;

      FORALL i9 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.project_id =   (SELECT project_id
                                   FROM pa_projects_all
                                  WHERE segment1 = a.project_number)
         WHERE inst_interface_id=inst_intf_id_upd(i9)
           AND a.project_id IS NULL
           AND a.project_number IS NOT NULL;

      FORALL i10 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.task_id   =    (SELECT task_id
                                   FROM pa_tasks pt,
                                        pa_projects_all pp
                                  WHERE pt.task_number = a.task_number
                                    AND pp.segment1 = a.project_number
                                    AND pt.project_id = pp.project_id)
         WHERE inst_interface_id=inst_intf_id_upd(i10)
           AND a.task_id IS NULL
           AND a.task_number IS NOT NULL
           AND a.project_number IS NOT NULL;

      FORALL i11 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.wip_job_id  =  (SELECT wip_entity_id
                                   FROM wip_entities
                                  WHERE wip_entity_name = a.wip_job_name)
         WHERE inst_interface_id=inst_intf_id_upd(i11)
           AND a.wip_job_id IS NULL
           AND a.wip_job_name IS NOT NULL;

      FORALL i16 in 1 .. inst_intf_id_upd.count
        UPDATE csi_instance_interface a
           SET a.operating_unit=(SELECT organization_id
                                   FROM hr_operating_units
                                  WHERE name = a.operating_unit_name)
         WHERE inst_interface_id=inst_intf_id_upd(i16)
           AND a.operating_unit IS NULL
           AND a.operating_unit_name IS NOT NULL;

       COMMIT;
       EXIT WHEN ins_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE ins_intf_cur;

   OPEN pty1_intf_cur;
   LOOP
      FETCH pty1_intf_cur BULK COLLECT INTO
      ip_intf_id_upd1
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd1.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_id  =  (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.party_name
                                    AND party_number = NVL(cpi.party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd1(i1)
           AND cpi.party_id IS NULL
           AND cpi.party_name IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd1.count
        UPDATE csi_i_party_interface cpi
           SET cpi.contact_party_id =
                                (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.contact_party_name
                                    AND party_number = NVL(cpi.contact_party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd1(i2)
           AND cpi.contact_party_id IS NULL
           AND cpi.contact_party_name IS NOT NULL;

       COMMIT;
       EXIT WHEN pty1_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty1_intf_cur;
    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id=(SELECT vendor_id
                       FROM po_vendors
                      WHERE vendor_name = cpi.party_name)
    WHERE cpi.party_source_table = 'PO_VENDORS'
      AND cpi.inst_interface_id IN (SELECT inst_interface_Id
                                      FROM csi_instance_interface
                                     WHERE transaction_identifier IS NULL
                                       AND trunc(source_transaction_date)
                                   BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                       AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                       AND process_status = 'X'
                                       AND source_system_name =
                                           nvl(p_source_system_name,source_system_name)
                                       AND parallel_worker_id = p_worker_id)
      AND cpi.party_id IS NULL
      AND cpi.party_name IS NOT NULL;

   OPEN pty2_intf_cur;
   LOOP
      FETCH pty2_intf_cur BULK COLLECT INTO
      ip_intf_id_upd2
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd2.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_id  =  (SELECT person_id
                                   FROM per_all_people_f
                                  WHERE full_name = cpi.party_name)
         WHERE ip_interface_id=ip_intf_id_upd2(i1)
           AND cpi.party_id IS NULL
           AND cpi.party_name IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd2.count
        UPDATE csi_i_party_interface cpi
           SET cpi.contact_party_id=
                                (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.contact_party_name
                                    AND party_number = NVL(cpi.contact_party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd2(i2)
           AND cpi.contact_party_id IS NULL
           AND cpi.contact_party_name IS NOT NULL;

       COMMIT;
       EXIT WHEN pty2_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty2_intf_cur;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT team_id
                         FROM jtf_rs_teams_vl
                        WHERE team_name = cpi.party_name)
    WHERE cpi.party_source_table = 'TEAM'
      AND cpi.inst_interface_id IN (SELECT inst_interface_Id
                                      FROM csi_instance_interface
                                     WHERE transaction_identifier IS NULL
                                       AND trunc(source_transaction_date)
                                   BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                       AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                       AND process_status = 'X'
                                       AND source_system_name = nvl(p_source_system_name,source_system_name)
                                       AND parallel_worker_id = p_worker_id)
      AND cpi.party_id IS NULL
      AND cpi.party_name IS NOT NULL;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT group_id
                         FROM jtf_rs_groups_vl
                        WHERE group_name = cpi.party_name)
    WHERE cpi.party_source_table = 'GROUP'
      AND cpi.inst_interface_id IN (SELECT inst_interface_Id
                                      FROM csi_instance_interface
                                     WHERE transaction_identifier IS NULL
                                       AND trunc(source_transaction_date)
                                   BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                       AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                       AND process_status = 'X'
                                       AND source_system_name = nvl(p_source_system_name,source_system_name)
                                       AND parallel_worker_id = p_worker_id)
      AND cpi.party_id IS NULL
      AND cpi.party_name IS NOT NULL;

   OPEN pty3_intf_cur;
   LOOP
      FETCH pty3_intf_cur BULK COLLECT INTO
      ip_intf_id_upd3
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account1_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account1_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i1)
           AND cpi.party_account1_id IS NULL
           AND cpi.party_account1_number IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account2_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account2_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i2)
           AND cpi.party_account2_id IS NULL
           AND cpi.party_account2_number IS NOT NULL;

      FORALL i3 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account3_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account3_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i3)
           AND cpi.party_account3_id IS NULL
           AND cpi.party_account3_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

       COMMIT;
       EXIT WHEN pty3_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty3_intf_cur;

   OPEN asst_intf_cur;
   LOOP
      FETCH asst_intf_cur BULK COLLECT INTO
	  asst_intf_id_upd
      LIMIT max_buffer_size;

      FORALL asst1 in 1 .. asst_intf_id_upd.count
        UPDATE csi_i_asset_interface a
           SET a.fa_asset_id =  (SELECT asset_id
                                   FROM fa_additions_b
                                  WHERE asset_number =
                                        a.fa_asset_number
                                    )
         WHERE a.ia_interface_id=asst_intf_id_upd(asst1)
           AND a.fa_asset_id IS NULL
           AND a.fa_asset_number IS NOT NULL;
       COMMIT;
       EXIT WHEN asst_intf_cur%NOTFOUND;
   END LOOP;


     -- Extended Attribute Interface Table Values

     BEGIN
   OPEN iea_intf_cur;
   LOOP
      FETCH iea_intf_cur BULK COLLECT INTO
      iea_intf_id_upd
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. iea_intf_id_upd.count
        UPDATE csi_iea_value_interface a
           SET a.inventory_item_id    =
                                (SELECT inventory_item_id
                                   FROM mtl_system_items_kfv
                                  WHERE concatenated_segments =
                                        a.inv_concatenated_segments
                                    AND ROWNUM=1)
         WHERE ieav_interface_id=iea_intf_id_upd(i1)
           AND a.inventory_item_id IS NULL
           AND a.inv_concatenated_segments IS NOT NULL;

      FORALL i2 in 1 .. iea_intf_id_upd.count
        UPDATE csi_iea_value_interface a
           SET a.master_organization_id =
                                (SELECT organization_id
                                   FROM hr_all_organization_units
                                  WHERE name = master_organization_name)
         WHERE ieav_interface_id=iea_intf_id_upd(i2)
           AND a.master_organization_id IS NULL
           AND a.master_organization_name IS NOT NULL;

       COMMIT;
       EXIT WHEN iea_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE iea_intf_cur;

     UPDATE csi_iea_value_interface a
        SET a.attribute_id=(SELECT attribute_id
                              FROM csi_i_extended_attribs
                             WHERE attribute_level = a.attribute_level
                               AND attribute_code = a.attribute_code)
     WHERE a.attribute_level = 'GLOBAL'
       AND a.inst_interface_id IN (SELECT inst_interface_Id
                                     FROM csi_instance_interface
                                    WHERE transaction_identifier IS NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status = 'X'
                                      AND source_system_name = nvl(p_source_system_name,source_system_name)
                                      AND parallel_worker_id = p_worker_id)
       AND a.attribute_id IS NULL
       AND a.attribute_level IS NOT NULL
       AND a.attribute_code IS NOT NULL;

     UPDATE csi_iea_value_interface a
        SET a.attribute_id=(SELECT attribute_id
                              FROM csi_i_extended_attribs
                             WHERE attribute_level = a.attribute_level
                               AND attribute_code = a.attribute_code
                               AND inventory_item_id = a.inventory_item_id
                               AND master_organization_id = a.master_organization_id
                               AND NVL(attribute_category,l_fnd_g_char)=
                                   NVL(a.attribute_category,l_fnd_g_char) )
     WHERE a.attribute_level = 'ITEM'
       AND a.inst_interface_id IN (SELECT inst_interface_Id
                                     FROM csi_instance_interface
                                    WHERE transaction_identifier IS NULL
                                      AND trunc(source_transaction_date)
                                  BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
                                      AND nvl(l_txn_to_date,trunc(source_transaction_date))
                                      AND process_status = 'X'
                                      AND source_system_name = nvl(p_source_system_name,source_system_name)
                                      AND parallel_worker_id = p_worker_id)
       AND a.attribute_id IS NULL
       AND a.attribute_level IS NOT NULL
       AND a.attribute_code IS NOT NULL
       AND a.inventory_item_id IS NOT NULL
       AND a.master_organization_id IS NOT NULL;

    EXCEPTION
     WHEN others THEN
       fnd_message.set_name('CSI','CSI_ML_EXT_ATTR_ID_ERROR');
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;
    END;

    EXCEPTION
     WHEN others THEN
       l_sql_error := SQLERRM;
       fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;

END resolve_pw_ids;

PROCEDURE resolve_update_ids
 (  p_source_system_name    IN     VARCHAR2,
    p_txn_identifier        IN     VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2) IS

 CURSOR pty1_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.party_source_table = 'HZ_PARTIES'
     AND cpi.inst_interface_id IN (SELECT inst_interface_id
                                     FROM csi_instance_interface cii
                                    WHERE cii.transaction_identifier = p_txn_identifier)
     AND cpi.party_source_table = 'HZ_PARTIES';

 CURSOR pty3_intf_cur IS
  SELECT ip_interface_id
    FROM csi_i_party_interface cpi
   WHERE cpi.inst_interface_id IN (SELECT inst_interface_id
                                     FROM csi_instance_interface cii
                                    WHERE cii.transaction_identifier = p_txn_identifier
                                      AND cii.source_system_name = p_source_system_name);

  TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   ip_intf_id_upd1          NumTabType;
   ip_intf_id_upd3          NumTabType;
   max_buffer_size          NUMBER := 1000;

l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.RESOLVE_UPDATE_IDS';
l_fnd_success     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
l_fnd_g_num       NUMBER      := FND_API.G_MISS_NUM;
l_fnd_g_char      VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_fnd_g_date      DATE        := FND_API.G_MISS_DATE;
l_sql_error       VARCHAR2(2000);
g_derive_ids      VARCHAR2(1);


BEGIN

  x_return_status := l_fnd_success;

  UPDATE csi_instance_interface a
     SET pricing_attribute_id =
              (SELECT pricing_attribute_id
                 FROM csi_i_pricing_attribs
                WHERE instance_id = a.instance_id
                  AND pricing_context = a.pricing_context)
  WHERE transaction_identifier = p_txn_identifier
    AND source_system_name = p_source_system_name
    AND a.pricing_attribute_id IS NULL
    AND a.instance_id IS NOT NULL
    AND a.pricing_context IS NOT NULL;

  UPDATE csi_instance_interface a
     SET instance_ou_id = (SELECT instance_ou_id
                             FROM csi_i_org_assignments
                            WHERE instance_id = a.instance_id
                              AND operating_unit_id = a.operating_unit
                              AND relationship_type_code = a.ou_relation_type)
   WHERE transaction_identifier = p_txn_identifier
     AND source_system_name = p_source_system_name
     AND a.instance_ou_id IS NULL
     AND a.instance_id IS NOT NULL
     AND a.operating_unit IS NOT NULL
     AND a.ou_relation_type IS NOT NULL;

   OPEN pty1_intf_cur;
   LOOP
      FETCH pty1_intf_cur BULK COLLECT INTO
      ip_intf_id_upd1
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd1.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_id  =  (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.party_name
                                    AND party_number = NVL(cpi.party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd1(i1)
           AND cpi.party_id IS NULL
           AND cpi.party_name IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd1.count
        UPDATE csi_i_party_interface cpi
           SET cpi.contact_party_id =
                                (SELECT party_id
                                   FROM hz_parties
                                  WHERE party_name = cpi.contact_party_name
                                    AND party_number = NVL(cpi.contact_party_number,party_number))
         WHERE ip_interface_id=ip_intf_id_upd1(i2)
           AND cpi.contact_party_id IS NULL
           AND cpi.contact_party_name IS NOT NULL;

       COMMIT;
       EXIT WHEN pty1_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty1_intf_cur;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT vendor_id
                         FROM po_vendors
                        WHERE vendor_name = cpi.party_name)
     WHERE cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier = p_txn_identifier)
       AND cpi.party_source_table = 'PO_VENDORS'
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT person_id
                         FROM per_all_people_f
                        WHERE full_name = cpi.party_name)
     WHERE cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier = p_txn_identifier)
       AND cpi.party_source_table = 'EMPLOYEE'
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT team_id
                         FROM jtf_rs_teams_vl
                        WHERE team_name = cpi.party_name)
     WHERE cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier = p_txn_identifier)
       AND cpi.party_source_table = 'TEAM'
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

    UPDATE CSI_I_PARTY_INTERFACE cpi
       SET party_id = (SELECT group_id
                         FROM jtf_rs_groups_vl
                        WHERE group_name = cpi.party_name)
     WHERE cpi.inst_interface_id IN (SELECT inst_interface_id
                                       FROM csi_instance_interface cii
                                      WHERE cii.transaction_identifier = p_txn_identifier)
       AND cpi.party_source_table = 'GROUP'
       AND cpi.party_id IS NULL
       AND cpi.party_name IS NOT NULL;

   OPEN pty3_intf_cur;
   LOOP
      FETCH pty3_intf_cur BULK COLLECT INTO
      ip_intf_id_upd3
      LIMIT max_buffer_size;

      FORALL i1 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account1_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account1_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i1)
           AND cpi.party_account1_id IS NULL
           AND cpi.party_account1_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

      FORALL i2 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account2_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account2_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i2)
           AND cpi.party_account2_id IS NULL
           AND cpi.party_account2_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

      FORALL i3 in 1 .. ip_intf_id_upd3.count
        UPDATE csi_i_party_interface cpi
           SET cpi.party_account3_id=
                                (SELECT cust_account_id
                                   FROM hz_cust_accounts
                                  WHERE account_number = cpi.party_account3_number
                                    AND party_id = cpi.party_id)
         WHERE ip_interface_id=ip_intf_id_upd3(i3)
           AND cpi.party_account3_id IS NULL
           AND cpi.party_account3_number IS NOT NULL
           AND cpi.party_id IS NOT NULL;

       COMMIT;
       EXIT WHEN pty3_intf_cur%NOTFOUND;
   END LOOP;
     COMMIT;
   CLOSE pty3_intf_cur;

     UPDATE csi_i_party_interface a
        SET instance_party_id = (SELECT instance_party_id
                                   FROM csi_i_parties
                                  WHERE party_id = a.party_id
                                    AND instance_id =
                                 (SELECT instance_id
                                    FROM csi_instance_interface cii
                                   WHERE cii.inst_interface_id=a.inst_interface_id)
                                     AND relationship_type_code =
                                         a.party_relationship_type_code
                                     AND   contact_flag <>'Y')
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND instance_party_id IS NULL
        AND a.party_id IS NOT NULL;

     UPDATE csi_i_party_interface a
        SET contact_ip_id  = (SELECT instance_party_id
                                FROM csi_i_parties
                               WHERE party_id = a.contact_party_id
                                 AND   instance_id =
                               (SELECT instance_id
                                  FROM csi_instance_interface cii
                                 WHERE cii.inst_interface_id=a.inst_interface_id)
                                 AND relationship_type_code =
                                       a.contact_party_rel_type
                                 AND contact_flag <>'Y')
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND contact_ip_id IS NULL
        AND a.contact_party_id IS NOT NULL;

     UPDATE csi_i_party_interface a
        SET instance_party_id = (SELECT instance_party_id
                                   FROM csi_i_parties
                                  WHERE instance_id =
                                 (SELECT instance_id
                                    FROM csi_instance_interface cii
                                   WHERE cii.inst_interface_id=a.inst_interface_id)
                                    AND relationship_type_code =
                                        a.party_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND party_relationship_type_code = 'OWNER'
        AND instance_party_id IS NULL;

     UPDATE csi_i_party_interface a
        SET ip_account1_id=(SELECT ip_account_id
                              FROM csi_ip_accounts
                             WHERE instance_party_id = a.instance_party_id
                               AND party_account_id = a.party_account1_id
                               AND relationship_type_code =
                                   a.acct1_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND ip_account1_id IS NULL ;

     UPDATE csi_i_party_interface a
        SET ip_account2_id = (SELECT ip_account_id
                                FROM csi_ip_accounts
                               WHERE instance_party_id = a.instance_party_id
                                 AND party_account_id = a.party_account2_id
                                 AND relationship_type_code =
                                     a.acct2_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND ip_account2_id IS NULL;

     UPDATE csi_i_party_interface a
        SET ip_account3_id = (SELECT ip_account_id
                                FROM csi_ip_accounts
                               WHERE instance_party_id = a.instance_party_id
                                 AND party_account_id = a.party_account3_id
                                 AND relationship_type_code =
                                     a.acct3_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND ip_account3_id IS NULL;

     UPDATE csi_i_party_interface a
        SET ip_account1_id = (SELECT ip_account_id
                                FROM csi_ip_accounts
                               WHERE instance_party_id = a.instance_party_id
                                 AND relationship_type_code =
                                     a.acct1_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND acct1_relationship_type_code = 'OWNER'
        AND ip_account1_id IS NULL;

     UPDATE csi_i_party_interface a
        SET ip_account2_id = (SELECT ip_account_id
                                FROM csi_ip_accounts
                               WHERE instance_party_id = a.instance_party_id
                                 AND relationship_type_code =
                                     a.acct2_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND acct2_relationship_type_code = 'OWNER'
        AND ip_account2_id IS NULL;

     UPDATE csi_i_party_interface a
        SET ip_account3_id = (SELECT ip_account_id
                                FROM csi_ip_accounts
                               WHERE instance_party_id = a.instance_party_id
                                 AND relationship_type_code =
                                     a.acct3_relationship_type_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND acct3_relationship_type_code = 'OWNER'
        AND ip_account3_id IS NULL;

     UPDATE csi_iea_value_interface a
        SET attribute_id =(SELECT attribute_id
                             FROM csi_i_extended_attribs
                            WHERE attribute_level = a.attribute_level
                              AND attribute_code = a.attribute_code)
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND attribute_level = 'GLOBAL'
        AND attribute_id IS NULL;

     UPDATE csi_iea_value_interface a
        SET attribute_id=(SELECT attribute_id
                            FROM csi_i_extended_attribs
                           WHERE attribute_level = a.attribute_level
                             AND attribute_code = a.attribute_code
                             AND inventory_item_id = a.inventory_item_id
                             AND master_organization_id = a.master_organization_id
                             AND NVL(attribute_category,l_fnd_g_char)=
                                 NVL(a.attribute_category,l_fnd_g_char))
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND attribute_level = 'ITEM'
        AND attribute_id IS NULL;

     UPDATE csi_iea_value_interface a
        SET attribute_value_id = (SELECT attribute_value_id
                                    FROM csi_iea_values
                                   WHERE attribute_id = a.attribute_id
                                     AND attribute_value = a.attribute_value
                                     AND instance_id =
                                     (SELECT cii1.instance_id
                                        FROM csi_instance_interface cii1
                                       WHERE cii1.inst_interface_id =a.inst_interface_id))
      WHERE a.inst_interface_id IN (SELECT inst_interface_id
                                      FROM csi_instance_interface cii
                                     WHERE cii.transaction_identifier = p_txn_identifier
                                       AND cii.source_system_name = p_source_system_name)
        AND attribute_value_id IS NULL;

    EXCEPTION
     WHEN others THEN
       l_sql_error := SQLERRM;
       fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;

END resolve_update_ids;

FUNCTION Get_Txn_Type_Id(P_Txn_Type IN VARCHAR2,
                         P_App_Short_Name IN VARCHAR2) RETURN NUMBER IS
l_Txn_Type_Id NUMBER;

CURSOR Txn_Type_Cur IS
    SELECT ctt.Transaction_Type_Id Transaction_Type_Id
    FROM   CSI_Txn_Types ctt,
           FND_Application fa
    WHERE  ctt.Source_Transaction_Type = P_Txn_Type
    AND    fa.application_id   = ctt.Source_Application_ID
    AND    fa.Application_Short_Name = P_App_Short_Name;
BEGIN
  OPEN Txn_Type_Cur;
  FETCH Txn_Type_Cur INTO l_Txn_Type_Id;
  CLOSE Txn_Type_Cur;
RETURN l_Txn_Type_Id;
END Get_Txn_Type_Id;

PROCEDURE log_create_errors (p_txn_from_date         IN     VARCHAR2,
                             p_txn_to_date           IN     VARCHAR2,
                             x_return_status         OUT NOCOPY   VARCHAR2,
                             x_error_message         OUT NOCOPY   VARCHAR2) IS

l_txn_from_date   DATE := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_txn_to_date     DATE := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');

CURSOR c_error is
  SELECT * from csi_instance_interface
  WHERE process_status = 'E'
  AND trunc(source_transaction_date) BETWEEN
            nvl(l_txn_from_date,trunc(source_transaction_date)) AND
            nvl(l_txn_to_date,trunc(source_transaction_date))
  AND parallel_worker_id IS NULL
  ORDER BY inst_interface_id;

r_error     c_error%rowtype;

l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.LOG_CREATE_ERRORS';
l_fnd_success     VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
l_sql_error       VARCHAR2(2000);
BEGIN

  x_return_status := l_fnd_success;

  FND_File.Put_Line(Fnd_File.LOG,'************BEGIN OF MASS LOAD ERRORS************');
  FND_File.Put_Line(Fnd_File.LOG,'INST_INTERFACE_ID       ERROR TEXT');
  FND_File.Put_Line(Fnd_File.LOG,'----------------------  ----------------------------------------------------------');
  FOR r_error in c_error LOOP
    FND_File.Put_Line(Fnd_File.LOG,r_error.inst_interface_id||'                        '||r_error.error_text);
  END LOOP;

  FND_File.Put_Line(Fnd_File.LOG,'************END OF MASS LOAD ERRORS************');

  EXCEPTION
    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := l_fnd_unexpected;

END log_create_errors;

PROCEDURE log_create_pw_errors (p_txn_from_date         IN     VARCHAR2,
                                p_txn_to_date           IN     VARCHAR2,
                                p_source_system_name    IN     VARCHAR2,
                                p_worker_id             IN     NUMBER,
                                x_return_status         OUT NOCOPY   VARCHAR2,
                                x_error_message         OUT NOCOPY   VARCHAR2) IS


CURSOR c_error (pc_txn_from_date      IN DATE,
                pc_txn_to_date        IN DATE,
                pc_source_system_name IN VARCHAR2,
                pc_worker_id          IN NUMBER) is
  SELECT * from csi_instance_interface
  WHERE process_status = 'E'
  AND trunc(source_transaction_date) BETWEEN
            nvl(pc_txn_from_date,trunc(source_transaction_date)) AND
            nvl(pc_txn_to_date,trunc(source_transaction_date))
  AND parallel_worker_id = pc_worker_id
  AND source_system_name = nvl(pc_source_system_name,source_system_name)
  ORDER BY inst_interface_id;

r_error     c_error%rowtype;

l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.LOG_CREATE_PW_ERRORS';
l_fnd_success     VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
l_sql_error       VARCHAR2(2000);
l_txn_from_date   DATE := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_txn_to_date     DATE := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
BEGIN

  x_return_status := l_fnd_success;

  FND_File.Put_Line(Fnd_File.LOG,'************BEGIN OF MASS LOAD ERRORS************');
  FND_File.Put_Line(Fnd_File.LOG,'INST_INTERFACE_ID       ERROR TEXT');
  FND_File.Put_Line(Fnd_File.LOG,'----------------------  ----------------------------------------------------------');
  FOR r_error in c_error(l_txn_from_date,
                         l_txn_to_date,
                         p_source_system_name,
                         p_worker_id) LOOP
    FND_File.Put_Line(Fnd_File.LOG,r_error.inst_interface_id||'                        '||r_error.error_text);
  END LOOP;

  FND_File.Put_Line(Fnd_File.LOG,'************END OF MASS LOAD ERRORS************');

  EXCEPTION
    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := l_fnd_unexpected;

END log_create_pw_errors;

PROCEDURE set_pty_process_status (p_txn_from_date         IN     VARCHAR2,
                                  p_txn_to_date           IN     VARCHAR2,
                                  x_return_status         OUT NOCOPY   VARCHAR2,
                                  x_error_message         OUT NOCOPY   VARCHAR2) IS


l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.SET_PTY_PROCESS_STATUS';
l_fnd_success     VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
l_sql_error       VARCHAR2(2000);
l_txn_from_date   DATE := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_txn_to_date     DATE := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
BEGIN

  x_return_status := l_fnd_success;

  EXCEPTION
    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := l_fnd_unexpected;

END set_pty_process_status;

PROCEDURE set_ext_process_status (p_txn_from_date         IN     VARCHAR2,
                                  p_txn_to_date           IN     VARCHAR2,
                                  x_return_status         OUT NOCOPY   VARCHAR2,
                                  x_error_message         OUT NOCOPY   VARCHAR2) IS


l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.SET_EXT_PROCESS_STATUS';
l_fnd_success     VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
l_sql_error       VARCHAR2(2000);
l_txn_from_date   DATE := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_txn_to_date     DATE := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
BEGIN

  x_return_status := l_fnd_success;

  EXCEPTION
    WHEN others THEN
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := l_fnd_unexpected;

END set_ext_process_status;

PROCEDURE resolve_rel_ids
 (  p_source_system         IN     VARCHAR2,
    p_txn_from_date         IN     varchar2,
    p_txn_to_date           IN     varchar2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    x_error_message         OUT NOCOPY   VARCHAR2) IS


  TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   rel_intf_id_upd          NumTabType;
   object_id_upd            NumTabType;
   subject_id_upd           NumTabType;
   max_buffer_size          NUMBER := 1000;

l_api_name        VARCHAR2(255) := 'CSI_ML_UTIL_PVT.RESOLVE_REL_IDS';
l_fnd_success     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnd_error       VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
l_fnd_unexpected  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
l_fnd_g_num       NUMBER      := FND_API.G_MISS_NUM;
l_fnd_g_char      VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_fnd_g_date      DATE        := FND_API.G_MISS_DATE;
l_sql_error       VARCHAR2(2000);
BEGIN


  x_return_status := l_fnd_success;
  -- Get the source system id for all of the rows
LOOP
 COMMIT;

   --Changed for bug 5875269
  UPDATE csi_ii_relation_interface cir
   SET cir.object_id = decode(cir.object_id,NULL
                              ,(SELECT cii.instance_id
                                  FROM csi_instance_interface cii
                                 WHERE cii.inst_interface_id = cir.object_interface_id)
                              ,cir.object_id ),
       cir.subject_id = decode(cir.subject_id,NULL
                               ,(SELECT cii.instance_id
                                   FROM csi_instance_interface cii
                                  WHERE cii.inst_interface_id = cir.subject_interface_id)
                               ,cir.subject_id )
 WHERE ((cir.object_id IS NULL AND EXISTS (SELECT 'x' FROM csi_instance_interface WHERE
	inst_interface_id = cir.object_interface_id AND instance_id IS NOT NULL))
 OR (cir.subject_id IS NULL AND EXISTS (SELECT 'x' FROM csi_instance_interface WHERE
	inst_interface_id = cir.subject_interface_id AND instance_id IS NOT NULL)))
   AND cir.process_status='R'
   AND ROWNUM<10001;

  EXIT WHEN SQL%NOTFOUND;

END LOOP;
COMMIT;


    EXCEPTION
     WHEN others THEN
       l_sql_error := SQLERRM;
       fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       FND_File.Put_Line(Fnd_File.LOG,'Error is ' || l_sql_error);
       x_error_message := fnd_message.get;
       x_return_status := l_fnd_unexpected;

END resolve_rel_ids;

PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_ml_util_pvt.ii_rel_interface_tbl
    ) IS
    --
    CURSOR REL_CUR IS
     SELECT rel_interface_id
           ,relationship_type_code
           ,object_id
           ,subject_id
       FROM csi_ii_relation_interface cir
      WHERE cir.object_id = p_object_id
        AND cir.process_status = 'R'
        AND cir.relationship_type_code<>'CONNECTED-TO';
     --
     l_ctr      NUMBER := 0;
  BEGIN
     FOR rel in REL_CUR LOOP
        l_ctr := l_ctr + 1;
        p_rel_tbl(l_ctr).rel_interface_id := rel.rel_interface_id;
        p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
        p_rel_tbl(l_ctr).object_id := rel.object_id;
        p_rel_tbl(l_ctr).subject_id := rel.subject_id;
     END LOOP;
  END Get_Next_Level;


  PROCEDURE Get_Children
    (p_object_id     IN  NUMBER,
     p_rel_tbl       OUT NOCOPY csi_ml_util_pvt.ii_rel_interface_tbl
    ) IS
    --
    l_rel_tbl                 csi_ml_util_pvt.ii_rel_interface_tbl;
    l_rel_tbl_next_lvl        csi_ml_util_pvt.ii_rel_interface_tbl;
    l_rel_tbl_temp            csi_ml_util_pvt.ii_rel_interface_tbl;
    l_rel_tbl_final           csi_ml_util_pvt.ii_rel_interface_tbl;
    l_next_ind                NUMBER := 0;
    l_final_ind               NUMBER := 0;
    l_ctr                     NUMBER := 0;
    l_found                   NUMBER;
  BEGIN
     csi_ml_util_pvt.Get_Next_Level
       ( p_object_id                 => p_object_id,
         p_rel_tbl                   => l_rel_tbl
       );

     <<Next_Level>>

     l_rel_tbl_next_lvl.delete;
     l_next_ind := 0;
     --
     IF l_rel_tbl.count > 0 THEN
        FOR l_ind IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
           l_final_ind := l_final_ind + 1;
           l_rel_tbl_final(l_final_ind) := l_rel_tbl(l_ind);
           /* get the next level using this Subject ID as the parent */
           csi_ml_util_pvt.Get_Next_Level
             ( p_object_id                 => l_rel_tbl(l_ind).subject_id,
               p_rel_tbl                   => l_rel_tbl_temp
             );
           --
           IF l_rel_tbl_temp.count > 0 THEN
              FOR l_temp_ind IN l_rel_tbl_temp.FIRST .. l_rel_tbl_temp.LAST LOOP
                 IF l_rel_tbl_final.count > 0 THEN
                    l_found := 0;
                    FOR i IN l_rel_tbl_final.FIRST .. l_rel_tbl_final.LAST LOOP
                       IF l_rel_tbl_final(i).object_id = l_rel_tbl_temp(l_temp_ind).object_id THEN
                          l_found := 1;
                          exit;
                       END IF;
                    END LOOP;
                 END IF;
                 IF l_found = 0 THEN
                    l_next_ind := l_next_ind + 1;
                    l_rel_tbl_next_lvl(l_next_ind) := l_rel_tbl_temp(l_temp_ind);
                 END IF;
              END LOOP;
           END IF;
        END LOOP;
        --
        IF l_rel_tbl_next_lvl.count > 0 THEN
           l_rel_tbl.DELETE;
           l_rel_tbl := l_rel_tbl_next_lvl;
           --
           goto Next_Level;
        END IF;
     END IF;
     --
     p_rel_tbl := l_rel_tbl_final;

  END Get_Children;


PROCEDURE Get_top_most_parent
     ( p_subject_id      IN  NUMBER,
       p_rel_type_code   IN  VARCHAR2,
       p_process_status  IN  VARCHAR2,
       p_object_id       OUT NOCOPY NUMBER
     ) IS
     l_object_id       NUMBER;
     l_subject_id      NUMBER := p_subject_id;
  BEGIN
   IF p_rel_type_code IS NULL OR
      p_subject_id IS NULL
   THEN
        l_object_id := -9999;
        p_object_id := l_object_id;
     RETURN;
   END IF;
   LOOP
     BEGIN
        SELECT cir.object_id
          INTO l_object_id
          FROM csi_ii_relation_interface cir
         WHERE cir.subject_id = l_subject_id
           AND cir.relationship_type_code = p_rel_type_code
           AND nvl(cir.relationship_end_date,(sysdate+1)) > sysdate
           AND EXISTS (SELECT 'x'
                         FROM csi_item_instances cii
                        WHERE cii.instance_id = cir.object_id
                          AND cii.location_type_code NOT IN ('INVENTORY','PO','IN_TRANSIT','WIP','PROJECT')
                      );
        l_subject_id := l_object_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           p_object_id := l_subject_id;
           EXIT;
     END;
     END LOOP;
  END Get_top_most_parent;


PROCEDURE Validate_relationship(
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    p_mode                       IN          VARCHAR2,
    p_worker_id                  IN          NUMBER,
    p_txn_from_date              IN          varchar2,
    p_txn_to_date                IN          varchar2,
    p_source_system_name         IN          VARCHAR2
    )
IS
l_exists                     VARCHAR2(1);
l_quantity                   NUMBER;
l_rel_id_array               dbms_sql.Number_Table;
l_status_array               dbms_sql.Varchar2_Table;
l_error_array                dbms_sql.Varchar2_Table;
l_iface_error_text           VARCHAR2(2000);
rel_row                      NUMBER;
l_upd_stmt                   VARCHAR2(2000);
l_num_of_rows                NUMBER;
l_upd_obj_id                 NUMBER;

l_instance_rec               csi_datastructures_pub.instance_rec;
l_instance_id_lst            csi_datastructures_pub.id_tbl;
l_item_attribute_tbl         csi_item_instance_pvt.item_attribute_tbl;
l_location_tbl               csi_item_instance_pvt.location_tbl;
l_generic_id_tbl             csi_item_instance_pvt.generic_id_tbl;
l_lookup_tbl                 csi_item_instance_pvt.lookup_tbl;
l_party_tbl                  csi_datastructures_pub.party_tbl;
l_asset_assignment_tbl       csi_datastructures_pub.instance_asset_tbl;
l_ins_count_rec              csi_item_instance_pvt.ins_count_rec;
l_txn_rec                    csi_datastructures_pub.transaction_rec;
l_ii_relationship_rec_tab    csi_ml_util_pvt.ii_relationship_rec_tab;
l_rel_hist_tbl               csi_diagnostics_pkg.T_NUM;
l_txn_id_tbl                 csi_diagnostics_pkg.T_NUM;
l_config_root_tbl            csi_diagnostics_pkg.T_NUM;
l_msg_data                   VARCHAR2(2000);
l_msg_index                  NUMBER;
l_msg_count                  NUMBER;
x_msg_count                  NUMBER;
l_dummy                      NUMBER;
l_ins                        NUMBER;
l_txn_type_id                NUMBER;
l_user_id                    NUMBER := FND_GLOBAL.USER_ID;
l_login_id                   NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
SKIP_ERROR                   EXCEPTION;
px_oks_txn_inst_tbl          oks_ibint_pub.txn_instance_tbl;
px_child_inst_tbl            csi_item_instance_grp.child_inst_tbl;

CURSOR c_id (pc_parallel_worker_id IN NUMBER, l_txn_from_date DATE, l_txn_to_date DATE) IS
 SELECT rel_interface_id
       ,process_status
       ,object_id
       ,subject_id
       ,relationship_type_code
       ,relationship_end_date
   FROM csi_ii_relation_interface
  WHERE  trunc(source_transaction_date)
 BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
    AND nvl(l_txn_to_date,trunc(source_transaction_date))
    AND nvl(transaction_identifier,'-1') = '-1'
    AND process_status = 'R'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id = pc_parallel_worker_id;


CURSOR upd_ins_csr (pc_parallel_worker_id IN NUMBER, l_txn_from_date DATE, l_txn_to_date DATE) IS
 SELECT rel_interface_id
       ,subject_id
       ,relationship_type_code
   FROM csi_ii_relation_interface
  WHERE trunc(source_transaction_date)
 BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
    AND nvl(l_txn_to_date,trunc(source_transaction_date))
    AND nvl(transaction_identifier,'-1') = '-1'
    AND process_status = 'V'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id = pc_parallel_worker_id;

CURSOR re_upd_csr (pc_parallel_worker_id IN NUMBER, l_txn_from_date DATE, l_txn_to_date DATE) IS
 SELECT rel_interface_id
       ,subject_id
       ,relationship_type_code
       ,config_root_node
   FROM csi_ii_relation_interface
  WHERE trunc(source_transaction_date)
 BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
    AND nvl(l_txn_to_date,trunc(source_transaction_date))
    AND nvl(transaction_identifier,'-1') = '-1'
    AND process_status = 'U'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id = pc_parallel_worker_id;

CURSOR ins_rel_csr (pc_parallel_worker_id IN NUMBER, l_txn_from_date DATE, l_txn_to_date DATE) IS
 SELECT rel_interface_id
       ,subject_id
       ,relationship_type_code
       ,object_id
       ,position_reference
       ,relationship_start_date
       ,relationship_end_date
       ,display_order
       ,mandatory_flag
       ,context
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
   FROM csi_ii_relation_interface
  WHERE trunc(source_transaction_date)
 BETWEEN nvl(l_txn_from_date,trunc(source_transaction_date))
    AND nvl(l_txn_to_date,trunc(source_transaction_date))
    AND nvl(transaction_identifier,'-1') = '-1'
    AND process_status = 'I'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id = pc_parallel_worker_id;

l_txn_from_date DATE;
l_txn_to_date DATE;

BEGIN

 l_txn_from_date := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
 l_txn_to_date := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');


FND_File.Put_Line(Fnd_File.LOG,'Mode p_mode is :'||p_mode);
FND_File.Put_Line(Fnd_File.LOG,'Worker id p_worker_id is :'||p_worker_id);
 IF p_mode='VALIDATE'
 THEN
 FND_File.Put_Line(Fnd_File.LOG,'Inside for Validate mode');
 rel_row:=0;
 FOR r_id IN c_id (p_worker_id, l_txn_from_date, l_txn_to_date ) LOOP
 l_iface_error_text := NULL;
 rel_row:=rel_row+1;
 FND_MSG_PUB.initialize;
  BEGIN

 -- 1. Validate relationship_type_code
       BEGIN
        SELECT 'x'
          INTO l_exists
          FROM csi_ii_relation_types
         WHERE relationship_type_code=r_id.relationship_type_code;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('CSI', 'CSI_INVALID_RELSHIP_CODE');
            fnd_message.set_token('RELATIONSHIP_TYPE_CODE',r_id.relationship_type_code);
            fnd_msg_pub.add;
                  l_msg_index := 1;
            fnd_msg_pub.count_and_get
                 (p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data
                  );
                 l_msg_count := x_msg_count;
                WHILE l_msg_count > 0
                LOOP
                  x_msg_data := fnd_msg_pub.get
                  (l_msg_index,
                   fnd_api.g_false
                   );
                  csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                END LOOP;
             l_iface_error_text := substr(x_msg_data,1,2000);
        RAISE SKIP_ERROR;
       END;



 -- 2. Validate object_id
       IF r_id.object_id IS NOT NULL
       THEN
          BEGIN
             SELECT quantity
               INTO l_quantity
               FROM csi_item_instances
              WHERE instance_id=r_id.object_id
                AND (SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE));

                 IF l_quantity <> 1
                 THEN
                   fnd_message.set_name('CSI', 'CSI_NON_ATO_PTO_ITEM');
                   fnd_message.set_token('OBJECT_ID',r_id.object_id);
                   fnd_msg_pub.add;
                   l_msg_index := 1;
                    fnd_msg_pub.count_and_get
                   (p_count  =>  x_msg_count,
                    p_data   =>  x_msg_data
                    );
                   l_msg_count := x_msg_count;
                    WHILE l_msg_count > 0
                    LOOP
                     x_msg_data := fnd_msg_pub.get
                     (l_msg_index,
                      fnd_api.g_false
                      );
                     csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                    END LOOP;
                    l_iface_error_text := substr(x_msg_data,1,2000);
                  RAISE SKIP_ERROR;
                 END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('CSI', 'CSI_EXPIRED_OBJECT');
               fnd_message.set_token('OBJECT_ID',r_id.object_id);
               fnd_msg_pub.add;
                   l_msg_index := 1;
                    fnd_msg_pub.count_and_get
                   (p_count  =>  x_msg_count,
                    p_data   =>  x_msg_data
                    );
                   l_msg_count := x_msg_count;
                    WHILE l_msg_count > 0
                    LOOP
                     x_msg_data := fnd_msg_pub.get
                     (l_msg_index,
                      fnd_api.g_false
                      );
                     csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                    END LOOP;
                    l_iface_error_text := substr(x_msg_data,1,2000);
                  RAISE SKIP_ERROR;
          END;
 -- 2.1 Validate MACD lock functionality for object_id
          IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => r_id.object_id)
          THEN
            fnd_message.set_name('CSI','CSI_LOCKED_INSTANCE');
            fnd_message.set_token('INSTANCE_ID',r_id.object_id);
            fnd_msg_pub.add;
            l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
          END IF;
       END IF;

 -- 3. Validate subject_id
       IF ((r_id.subject_id IS NOT NULL) AND
           (r_id.subject_id <> fnd_api.g_miss_num))
       THEN
          BEGIN
           SELECT 'x'
             INTO l_exists
             FROM csi_item_instances
            WHERE instance_id=r_id.subject_id
              AND (SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE));
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('CSI', 'CSI_EXPIRED_SUBJECT');
              fnd_message.set_token('SUBJECT_ID',r_id.subject_id);
              fnd_msg_pub.add;
              l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
          END;
 -- 3.1 Validate MACD lock functionality for subject_id
          IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => r_id.subject_id)
          THEN
            fnd_message.set_name('CSI','CSI_LOCKED_INSTANCE');
            fnd_message.set_token('INSTANCE_ID',r_id.subject_id);
            fnd_msg_pub.add;
            l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
          END IF;
       END IF;

 -- 4. Validate active_end_date
       IF ((r_id.relationship_end_date IS NOT NULL) AND
           (r_id.relationship_end_date <> fnd_api.g_miss_date))
       THEN
            fnd_message.set_name('CSI', 'CSI_ACTIVE_END_DATE');
            fnd_message.set_token('ACTIVE_END_DATE',r_id.relationship_end_date);
            fnd_msg_pub.add;
            l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
       END IF;
 -- 5. Validate
    IF r_id.relationship_type_code <> 'CONNECTED-TO'
    THEN
 -- 5.1 Validate for existence of subject_id (subject_exists routine)
       BEGIN
        SELECT 'x'
          INTO l_exists
          FROM csi_ii_relationships
         WHERE subject_id=r_id.subject_id
           AND relationship_type_code = r_id.relationship_type_code
           AND (active_end_date IS NULL OR active_end_date > SYSDATE)
           AND ROWNUM=1;
           fnd_message.set_name('CSI','CSI_SUB_RELCODE_EXIST');
           fnd_message.set_token('RELATIONSHIP_TYPE_CODE',r_id.relationship_type_code);
           fnd_message.set_token('SUBJECT_ID',r_id.subject_id);
           fnd_msg_pub.add;
            l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
       END;
 -- 5.2 Validate check for object
           csi_ii_relationships_pvt.check_for_object
             (p_subject_id             =>r_id.subject_id,
              p_object_id              =>r_id.object_id,
              p_relationship_type_code =>r_id.relationship_type_code,
              x_return_status          =>x_return_status,
              x_msg_count              =>x_msg_count,
              x_msg_data               =>x_msg_data
           );
         IF x_return_status<>fnd_api.g_ret_sts_success THEN
            l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
         END IF;
    ELSIF r_id.relationship_type_code='CONNECTED-TO'
    THEN
     BEGIN
      SELECT 'x'
        INTO l_exists
        FROM csi_ii_relationships
       WHERE (( subject_id=r_id.object_id AND
                object_id=r_id.subject_id)
          OR  ( subject_id=r_id.subject_id AND
                object_id=r_id.object_id))
         AND relationship_type_code = r_id.relationship_type_code
         AND (active_end_date IS NULL OR active_end_date > SYSDATE)
         AND ROWNUM = 1;
      fnd_message.set_name('CSI','CSI_RELATIONSHIP_EXISTS');
      fnd_message.set_token('RELATIONSHIP_TYPE',r_id.relationship_type_code);
      fnd_message.set_token('SUBJECT_ID',r_id.subject_id);
      fnd_message.set_token('OBJECT_ID',r_id.object_id);
      fnd_msg_pub.add;
      l_msg_index := 1;
         fnd_msg_pub.count_and_get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data
           );
          l_msg_count := x_msg_count;
           WHILE l_msg_count > 0
           LOOP
            x_msg_data := fnd_msg_pub.get
            (l_msg_index,
             fnd_api.g_false
             );
            csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
           END LOOP;
           l_iface_error_text := substr(x_msg_data,1,2000);
          RAISE SKIP_ERROR;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        NULL;
     END;
     IF csi_ii_relationships_pvt.Is_link_type
        (p_instance_id => r_id.object_id )
     THEN
       IF csi_ii_relationships_pvt.relationship_for_link
          (p_instance_id     => r_id.object_id
          ,p_mode            => 'CREATE'
          ,p_relationship_id => NULL )
       THEN
         fnd_message.set_name('CSI','CSI_LINK_EXISTS');
         fnd_message.set_token('INSTANCE_ID',r_id.object_id);
         fnd_msg_pub.add;
            l_msg_index := 1;
              fnd_msg_pub.count_and_get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
               );
              l_msg_count := x_msg_count;
               WHILE l_msg_count > 0
               LOOP
                x_msg_data := fnd_msg_pub.get
                (l_msg_index,
                 fnd_api.g_false
                 );
                csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               l_iface_error_text := substr(x_msg_data,1,2000);
              RAISE SKIP_ERROR;
       END IF;
     END IF;

     IF csi_ii_relationships_pvt.Is_link_type
        (p_instance_id => r_id.subject_id )
     THEN
       IF csi_ii_relationships_pvt.relationship_for_link
          (p_instance_id     => r_id.subject_id
          ,p_mode            => 'CREATE'
          ,p_relationship_id => NULL )
       THEN
        fnd_message.set_name('CSI','CSI_LINK_EXISTS');
        fnd_message.set_token('INSTANCE_ID',r_id.subject_id);
        fnd_msg_pub.add;
        l_msg_index := 1;
          fnd_msg_pub.count_and_get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data
           );
          l_msg_count := x_msg_count;
           WHILE l_msg_count > 0
           LOOP
            x_msg_data := fnd_msg_pub.get
            (l_msg_index,
             fnd_api.g_false
             );
            csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
           END LOOP;
            l_iface_error_text := substr(x_msg_data,1,2000);
           RAISE SKIP_ERROR;
       END IF;
     END IF;

    END IF;  -- <IF p_relationship_tbl(1).relationship_type_code <> 'CONNECTED-TO'>


       l_error_array(rel_row)  := NULL;
       l_status_array(rel_row) := 'V';
       l_rel_id_array(rel_row) := r_id.rel_interface_id;
  EXCEPTION
  WHEN SKIP_ERROR THEN
      FND_File.Put_Line(Fnd_File.LOG,'After validation setting status E');
      l_error_array(rel_row)  := l_iface_error_text;
      l_status_array(rel_row) := 'E';
      l_rel_id_array(rel_row) := r_id.rel_interface_id;

   WHEN others THEN
      FND_File.Put_Line(Fnd_File.LOG,'In others status E' || SQLERRM);
      l_error_array(rel_row)  := l_iface_error_text;
      l_status_array(rel_row) := 'E';
      l_rel_id_array(rel_row) := r_id.rel_interface_id;
  END;
 END LOOP;

 FND_File.Put_Line(Fnd_File.LOG,'Trying to update count');
  -- Update Interface Table
  IF l_rel_id_array.count > 0 THEN
  FND_File.Put_Line(Fnd_File.LOG,'Updating status in validate mode');
     BEGIN
        l_upd_stmt := 'UPDATE csi_ii_relation_interface
                          SET error_text       =  :error_text
                             ,process_status   =  :status
                        WHERE rel_interface_id =  :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_rel_id_array);
        dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
        dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
     COMMIT;
  END IF;
 -- The program that called this program in VALIDATE mode has to go into
 -- a wait mode until the completion of all the VALIDATE mode parallel
 -- requests.
 ELSIF p_mode='UPDATE'
 THEN
  FND_File.Put_Line(Fnd_File.LOG,'Inside for Update mode');
   rel_row := 0;
  -- Get the root node and update the instance for updating the instance(subject) location
  FOR l_upd_ins_csr IN upd_ins_csr(p_worker_id, l_txn_from_date, l_txn_to_date)
  LOOP
   BEGIN
   l_iface_error_text := NULL;
   rel_row:=rel_row+1;
   FND_MSG_PUB.initialize;
     csi_ml_util_pvt.Get_top_most_parent
      ( p_subject_id      => l_upd_ins_csr.subject_id
       ,p_rel_type_code   => l_upd_ins_csr.relationship_type_code
       ,p_process_status  => 'V'
       ,p_object_id       => l_upd_obj_id
      );

      IF l_upd_ins_csr.subject_id = l_upd_obj_id
      THEN
          l_iface_error_text :='Cannot cascade location to INV,PO,IN-TRANSIT,WIP OR PROJECT using OI';
         RAISE SKIP_ERROR;
      END IF;

      l_instance_rec.instance_usage_code :='IN_RELATIONSHIP';

        SELECT active_end_date
              ,location_type_code
              ,location_id
              ,inv_organization_id
              ,inv_subinventory_name
              ,inv_locator_id
              ,pa_project_id
              ,pa_project_task_id
              ,in_transit_order_line_id
              ,wip_job_id
              ,po_order_line_id
          INTO l_instance_rec.active_end_date
              ,l_instance_rec.location_type_code
              ,l_instance_rec.location_id
              ,l_instance_rec.inv_organization_id
              ,l_instance_rec.inv_subinventory_name
              ,l_instance_rec.inv_locator_id
              ,l_instance_rec.pa_project_id
              ,l_instance_rec.pa_project_task_id
              ,l_instance_rec.in_transit_order_line_id
              ,l_instance_rec.wip_job_id
              ,l_instance_rec.po_order_line_id
          FROM csi_item_instances
         WHERE instance_id=l_upd_obj_id;

        SELECT instance_id
              ,object_version_number
          INTO l_instance_rec.instance_id
              ,l_instance_rec.object_version_number
          FROM csi_item_instances
         WHERE instance_id = l_upd_ins_csr.subject_id;


l_return_status := FND_API.G_RET_STS_SUCCESS;
/*
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.instance_id               := '||l_instance_rec.instance_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.object_version_number     := '||l_instance_rec.object_version_number);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.active_end_date           := '||l_instance_rec.active_end_date);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.location_type_code        := '||l_instance_rec.location_type_code);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.location_id               := '||l_instance_rec.location_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.inv_organization_id       := '||l_instance_rec.inv_organization_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.inv_subinventory_name     := '||l_instance_rec.inv_subinventory_name);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.inv_locator_id            := '||l_instance_rec.inv_locator_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.pa_project_id             := '||l_instance_rec.pa_project_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.pa_project_task_id        := '||l_instance_rec.pa_project_task_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.in_transit_order_line_id  := '||l_instance_rec.in_transit_order_line_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.wip_job_id                := '||l_instance_rec.wip_job_id);
FND_File.Put_Line(Fnd_File.LOG,'l_instance_rec.po_order_line_id          := '||l_instance_rec.po_order_line_id);
FND_File.Put_Line(Fnd_File.LOG,'Before update l_return_status            := '||l_return_status);
*/
              l_txn_rec.transaction_type_id := csi_ml_util_pvt.get_txn_type_id('OPEN_INTERFACE','CSI');
              l_txn_rec.transaction_date := sysdate;
              l_txn_rec.source_transaction_date := sysdate;

              csi_item_instance_pvt.update_item_instance
              (p_api_version        =>  1.0
              ,p_commit             =>  fnd_api.g_false
              ,p_init_msg_list      =>  fnd_api.g_false
              ,p_validation_level   =>  fnd_api.g_valid_level_full
              ,p_instance_rec       =>  l_instance_rec
              ,p_txn_rec            =>  l_txn_rec
              ,x_instance_id_lst    =>  l_instance_id_lst
              ,x_return_status      =>  l_return_status
              ,x_msg_count          =>  x_msg_count
              ,x_msg_data           =>  x_msg_data
              ,p_item_attribute_tbl =>  l_item_attribute_tbl
              ,p_location_tbl       =>  l_location_tbl
              ,p_generic_id_tbl     =>  l_generic_id_tbl
              ,p_lookup_tbl         =>  l_lookup_tbl
              ,p_ins_count_rec      =>  l_ins_count_rec
              ,p_called_from_rel    =>  fnd_api.g_false
              ,p_oks_txn_inst_tbl   =>  px_oks_txn_inst_tbl
              ,p_child_inst_tbl     =>  px_child_inst_tbl
              ,p_validation_mode    =>  'V'
              );
FND_File.Put_Line(Fnd_File.LOG,'After  update l_return_status            := '||l_return_status);
FND_File.Put_Line(Fnd_File.LOG,'After  update x_msg_data            := '||x_msg_data);



            IF NOT(l_return_status = fnd_api.g_ret_sts_success)
            THEN
            /*
               fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
               fnd_message.set_token('instance_id',l_instance_rec.instance_id);
               fnd_msg_pub.add;
               */
               l_msg_index := 1;

               fnd_msg_pub.count_and_get
               ( p_count  =>  x_msg_count
                ,p_data   =>  x_msg_data
               );
               l_msg_count := x_msg_count;
                WHILE l_msg_count > 0
                LOOP
                 x_msg_data := fnd_msg_pub.get
                 ( l_msg_index
                  ,fnd_api.g_false
                 );
                 csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                l_iface_error_text := substr(x_msg_data,1,2000);
               RAISE SKIP_ERROR;
            END IF;

       l_error_array(rel_row)     := NULL;
       l_status_array(rel_row)    := 'U';
       l_rel_id_array(rel_row)    := l_upd_ins_csr.rel_interface_id;
       l_config_root_tbl(rel_row) := l_upd_obj_id;
   EXCEPTION
   WHEN SKIP_ERROR THEN
      l_error_array(rel_row)     := l_iface_error_text;
      l_status_array(rel_row)    := 'E';
      l_rel_id_array(rel_row)    := l_upd_ins_csr.rel_interface_id;
      l_config_root_tbl(rel_row) := l_upd_obj_id;
   END;
  END LOOP;

  -- Update Interface Table
  IF l_rel_id_array.count > 0 THEN
    FND_File.Put_Line(Fnd_File.LOG,'Updating status in update mode');
     BEGIN
        l_upd_stmt := 'UPDATE csi_ii_relation_interface
                          SET error_text       =  :error_text
                             ,process_status   =  :status
                        WHERE rel_interface_id =  :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_rel_id_array);
        dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
        dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
     COMMIT;
  END IF;

 ELSIF p_mode='RE-UPDATE'
 THEN
  FND_File.Put_Line(Fnd_File.LOG,'Inside for re-update mode');
   rel_row := 0;
  -- Get the root node and update the instance for updating the instance(subject) location
  FOR l_re_upd_csr IN re_upd_csr(p_worker_id, l_txn_from_date, l_txn_to_date)
  LOOP
   BEGIN
   l_iface_error_text := NULL;
   rel_row := rel_row+1;
   FND_MSG_PUB.initialize;

     csi_ml_util_pvt.Get_top_most_parent
      ( p_subject_id      => l_re_upd_csr.subject_id
       ,p_rel_type_code   => l_re_upd_csr.relationship_type_code
       ,p_process_status  => 'U'
       ,p_object_id       => l_upd_obj_id
      );

      IF l_re_upd_csr.subject_id = l_upd_obj_id
      THEN
          l_iface_error_text :='Cannot cascade location to INV,PO,IN-TRANSIT,WIP OR PROJECT using OI';
         RAISE SKIP_ERROR;
      END IF;

      l_instance_rec.instance_usage_code :='IN_RELATIONSHIP';

        SELECT active_end_date
              ,location_type_code
              ,location_id
              ,inv_organization_id
              ,inv_subinventory_name
              ,inv_locator_id
              ,pa_project_id
              ,pa_project_task_id
              ,in_transit_order_line_id
              ,wip_job_id
              ,po_order_line_id
          INTO l_instance_rec.active_end_date
              ,l_instance_rec.location_type_code
              ,l_instance_rec.location_id
              ,l_instance_rec.inv_organization_id
              ,l_instance_rec.inv_subinventory_name
              ,l_instance_rec.inv_locator_id
              ,l_instance_rec.pa_project_id
              ,l_instance_rec.pa_project_task_id
              ,l_instance_rec.in_transit_order_line_id
              ,l_instance_rec.wip_job_id
              ,l_instance_rec.po_order_line_id
          FROM csi_item_instances
         WHERE instance_id=l_upd_obj_id;

        SELECT instance_id
              ,object_version_number
          INTO l_instance_rec.instance_id
              ,l_instance_rec.object_version_number
          FROM csi_item_instances
         WHERE instance_id = l_re_upd_csr.subject_id;

l_return_status := FND_API.G_RET_STS_SUCCESS;

              l_txn_rec.transaction_type_id := csi_ml_util_pvt.get_txn_type_id('OPEN_INTERFACE','CSI');
              l_txn_rec.transaction_date := sysdate;
              l_txn_rec.source_transaction_date := sysdate;

              csi_item_instance_pvt.update_item_instance
              (p_api_version        =>  1.0
              ,p_commit             =>  fnd_api.g_false
              ,p_init_msg_list      =>  fnd_api.g_false
              ,p_validation_level   =>  fnd_api.g_valid_level_full
              ,p_instance_rec       =>  l_instance_rec
              ,p_txn_rec            =>  l_txn_rec
              ,x_instance_id_lst    =>  l_instance_id_lst
              ,x_return_status      =>  l_return_status
              ,x_msg_count          =>  x_msg_count
              ,x_msg_data           =>  x_msg_data
              ,p_item_attribute_tbl =>  l_item_attribute_tbl
              ,p_location_tbl       =>  l_location_tbl
              ,p_generic_id_tbl     =>  l_generic_id_tbl
              ,p_lookup_tbl         =>  l_lookup_tbl
              ,p_ins_count_rec      =>  l_ins_count_rec
              ,p_called_from_rel    =>  fnd_api.g_false
              ,p_oks_txn_inst_tbl        =>  px_oks_txn_inst_tbl
              ,p_child_inst_tbl          =>  px_child_inst_tbl
              ,p_validation_mode    =>  'U'
              );

FND_File.Put_Line(Fnd_File.LOG,'After  update x_msg_data            := '||x_msg_data);
FND_File.Put_Line(Fnd_File.LOG,'After  update l_return_status            := '||l_return_status);


            IF NOT(l_return_status = fnd_api.g_ret_sts_success)
            THEN

               l_msg_index := 1;

               fnd_msg_pub.count_and_get
               ( p_count  =>  x_msg_count
                ,p_data   =>  x_msg_data
               );
               l_msg_count := x_msg_count;
                WHILE l_msg_count > 0
                LOOP
                 x_msg_data := fnd_msg_pub.get
                 ( l_msg_index
                  ,fnd_api.g_false
                 );
                 csi_gen_utility_pvt.put_line( ' MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                l_iface_error_text := substr(x_msg_data,1,2000);
               RAISE SKIP_ERROR;
            END IF;
       l_error_array(rel_row)     := NULL;
       l_status_array(rel_row)    := 'I';
       l_rel_id_array(rel_row)    := l_re_upd_csr.rel_interface_id;
       l_config_root_tbl(rel_row) := l_upd_obj_id;
   EXCEPTION
   WHEN SKIP_ERROR THEN

      l_error_array(rel_row)     := l_iface_error_text;
      l_status_array(rel_row)    := 'E';
      l_rel_id_array(rel_row)    := l_re_upd_csr.rel_interface_id;
      l_config_root_tbl(rel_row) := l_upd_obj_id;
   END;

  END LOOP;

  -- Update Interface Table
  IF l_rel_id_array.count > 0 THEN
    FND_File.Put_Line(Fnd_File.LOG,'Updating status in re-update mode');
     BEGIN
        l_upd_stmt := 'UPDATE csi_ii_relation_interface
                          SET error_text       =  :error_text
                             ,process_status   =  :status
                        WHERE rel_interface_id =  :intf_id';
        l_num_of_rows := dbms_sql.open_cursor;
        dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
        dbms_sql.bind_array(l_num_of_rows,':intf_id',l_rel_id_array);
        dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
        dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
        l_dummy := dbms_sql.execute(l_num_of_rows);
        dbms_sql.close_cursor(l_num_of_rows);
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
     COMMIT;
  END IF;

 ELSIF p_mode='INSERT'
 THEN
   FND_File.Put_Line(Fnd_File.LOG,'Inside for Insert mode');
  -- This run also has to insert records into csi_ii_relationships
  -- ,csi_ii_relationships_h and csi_transactions
      l_ins:=0;
      l_txn_type_id := csi_ml_util_pvt.get_txn_type_id('OPEN_INTERFACE','CSI');

      FOR l_ins_rel_csr IN ins_rel_csr(p_worker_id, l_txn_from_date, l_txn_to_date)
      LOOP
       l_ins:=l_ins+1;
        SELECT csi_ii_relationships_h_s.NEXTVAL
          INTO l_rel_hist_tbl(l_ins)
          FROM dual;

        SELECT csi_ii_relationships_s.NEXTVAL
          INTO l_ii_relationship_rec_tab.rel_interface_id(l_ins)
          FROM dual;

        SELECT csi_transactions_s.NEXTVAL
          INTO l_txn_id_tbl(l_ins)
          FROM dual;

       l_status_array(l_ins) := 'P';
       l_rel_id_array(l_ins) := l_ins_rel_csr.rel_interface_id;

       l_ii_relationship_rec_tab.relationship_type_code(l_ins)	:= l_ins_rel_csr.relationship_type_code;
       l_ii_relationship_rec_tab.object_id(l_ins)	        := l_ins_rel_csr.object_id;
       l_ii_relationship_rec_tab.subject_id(l_ins)	        := l_ins_rel_csr.subject_id;
       l_ii_relationship_rec_tab.position_reference(l_ins)	:= l_ins_rel_csr.position_reference;
       l_ii_relationship_rec_tab.active_start_date(l_ins)	:= l_ins_rel_csr.relationship_start_date;
       l_ii_relationship_rec_tab.active_end_date(l_ins)	:= l_ins_rel_csr.relationship_end_date;
       l_ii_relationship_rec_tab.display_order(l_ins)	:= l_ins_rel_csr.display_order;
       l_ii_relationship_rec_tab.mandatory_flag(l_ins)	:= l_ins_rel_csr.mandatory_flag;
       l_ii_relationship_rec_tab.context(l_ins)	        := l_ins_rel_csr.context;
       l_ii_relationship_rec_tab.attribute1(l_ins)	    := l_ins_rel_csr.attribute1;
       l_ii_relationship_rec_tab.attribute2(l_ins)	    := l_ins_rel_csr.attribute2;
       l_ii_relationship_rec_tab.attribute3(l_ins)	    := l_ins_rel_csr.attribute3;
       l_ii_relationship_rec_tab.attribute4(l_ins)	    := l_ins_rel_csr.attribute4;
       l_ii_relationship_rec_tab.attribute5(l_ins)	    := l_ins_rel_csr.attribute5;
       l_ii_relationship_rec_tab.attribute6(l_ins)	    := l_ins_rel_csr.attribute6;
       l_ii_relationship_rec_tab.attribute7(l_ins)	    := l_ins_rel_csr.attribute7;
       l_ii_relationship_rec_tab.attribute8(l_ins)	    := l_ins_rel_csr.attribute8;
       l_ii_relationship_rec_tab.attribute9(l_ins)	    := l_ins_rel_csr.attribute9;
       l_ii_relationship_rec_tab.attribute10(l_ins)	    := l_ins_rel_csr.attribute10;
       l_ii_relationship_rec_tab.attribute11(l_ins)	    := l_ins_rel_csr.attribute11;
       l_ii_relationship_rec_tab.attribute12(l_ins)	    := l_ins_rel_csr.attribute12;
       l_ii_relationship_rec_tab.attribute13(l_ins)	    := l_ins_rel_csr.attribute13;
       l_ii_relationship_rec_tab.attribute14(l_ins)	    := l_ins_rel_csr.attribute14;
       l_ii_relationship_rec_tab.attribute15(l_ins)	    := l_ins_rel_csr.attribute15;
      END LOOP;

      FORALL i in 1 .. l_ii_relationship_rec_tab.rel_interface_id.count
	   INSERT INTO CSI_II_RELATIONSHIPS(
         RELATIONSHIP_ID
        ,RELATIONSHIP_TYPE_CODE
        ,OBJECT_ID
        ,SUBJECT_ID
        ,POSITION_REFERENCE
        ,ACTIVE_START_DATE
        ,ACTIVE_END_DATE
        ,DISPLAY_ORDER
        ,MANDATORY_FLAG
        ,CONTEXT
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER)
	   VALUES(
         l_ii_relationship_rec_tab.REL_INTERFACE_ID(i)
        ,l_ii_relationship_rec_tab.RELATIONSHIP_TYPE_CODE(i)
        ,l_ii_relationship_rec_tab.OBJECT_ID(i)
        ,l_ii_relationship_rec_tab.SUBJECT_ID(i)
        ,l_ii_relationship_rec_tab.POSITION_REFERENCE(i)
        ,l_ii_relationship_rec_tab.ACTIVE_START_DATE(i)
        ,l_ii_relationship_rec_tab.ACTIVE_END_DATE(i)
        ,l_ii_relationship_rec_tab.DISPLAY_ORDER(i)
        ,l_ii_relationship_rec_tab.MANDATORY_FLAG(i)
        ,l_ii_relationship_rec_tab.CONTEXT(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE1(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE2(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE3(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE4(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE5(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE6(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE7(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE8(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE9(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE10(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE11(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE12(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE13(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE14(i)
        ,l_ii_relationship_rec_tab.ATTRIBUTE15(i)
        ,l_user_id
        ,sysdate
        ,l_user_id
        ,sysdate
        ,-1
        ,1);


      FORALL i in 1 .. l_ii_relationship_rec_tab.rel_interface_id.count
	   INSERT INTO CSI_II_RELATIONSHIPS_H(
	      RELATIONSHIP_HISTORY_ID
	     ,RELATIONSHIP_ID
	     ,TRANSACTION_ID
	     ,NEW_SUBJECT_ID
	     ,NEW_POSITION_REFERENCE
	     ,NEW_ACTIVE_START_DATE
	     ,NEW_ACTIVE_END_DATE
	     ,NEW_MANDATORY_FLAG
	     ,NEW_CONTEXT
	     ,NEW_ATTRIBUTE1
	     ,NEW_ATTRIBUTE2
	     ,NEW_ATTRIBUTE3
	     ,NEW_ATTRIBUTE4
	     ,NEW_ATTRIBUTE5
	     ,NEW_ATTRIBUTE6
	     ,NEW_ATTRIBUTE7
	     ,NEW_ATTRIBUTE8
	     ,NEW_ATTRIBUTE9
	     ,NEW_ATTRIBUTE10
	     ,NEW_ATTRIBUTE11
	     ,NEW_ATTRIBUTE12
	     ,NEW_ATTRIBUTE13
	     ,NEW_ATTRIBUTE14
	     ,NEW_ATTRIBUTE15
	     ,FULL_DUMP_FLAG
	     ,CREATED_BY
	     ,CREATION_DATE
	     ,LAST_UPDATED_BY
	     ,LAST_UPDATE_DATE
	     ,LAST_UPDATE_LOGIN
	     ,OBJECT_VERSION_NUMBER)
	   VALUES(
	      l_rel_hist_tbl(i)
	     ,l_ii_relationship_rec_tab.REL_INTERFACE_ID(i)
	     ,l_txn_id_tbl(i)
	     ,l_ii_relationship_rec_tab.SUBJECT_ID(i)
	     ,l_ii_relationship_rec_tab.POSITION_REFERENCE(i)
	     ,l_ii_relationship_rec_tab.ACTIVE_START_DATE(i)
	     ,l_ii_relationship_rec_tab.ACTIVE_END_DATE(i)
	     ,l_ii_relationship_rec_tab.MANDATORY_FLAG(i)
	     ,l_ii_relationship_rec_tab.CONTEXT(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE1(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE2(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE3(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE4(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE5(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE6(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE7(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE8(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE9(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE10(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE11(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE12(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE13(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE14(i)
	     ,l_ii_relationship_rec_tab.ATTRIBUTE15(i)
	     ,'Y'
	     ,l_user_id
	     ,sysdate
	     ,l_user_id
	     ,sysdate
	     ,-1
	     ,1);


      FORALL i in 1 .. l_txn_id_tbl.count
        INSERT INTO CSI_TRANSACTIONS(
          TRANSACTION_ID
         ,TRANSACTION_DATE
         ,SOURCE_TRANSACTION_DATE
         ,SOURCE_HEADER_REF
         ,TRANSACTION_TYPE_ID
         ,CREATED_BY
         ,CREATION_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,OBJECT_VERSION_NUMBER
         )
         VALUES(
          l_txn_id_tbl(i)
         ,SYSDATE
         ,SYSDATE
         ,'Full Dump Insert'
         ,l_txn_type_id
         ,l_user_id
         ,sysdate
         ,l_user_id
         ,sysdate
         ,-1
         ,1
         );

    IF l_rel_id_array.count > 0 THEN
      FND_File.Put_Line(Fnd_File.LOG,'Updating status in insert mode');
       BEGIN
          l_upd_stmt := 'UPDATE csi_ii_relation_interface
                            SET process_status   =  :status
                          WHERE rel_interface_id =  :intf_id';
          l_num_of_rows := dbms_sql.open_cursor;
          dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
          dbms_sql.bind_array(l_num_of_rows,':intf_id',l_rel_id_array);
          dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
          l_dummy := dbms_sql.execute(l_num_of_rows);
          dbms_sql.close_cursor(l_num_of_rows);
       EXCEPTION
          WHEN OTHERS THEN
             NULL;
       END;
       COMMIT;
    END IF;

 END IF; -- p_mode='VALIDATE'
FND_File.Put_Line(Fnd_File.LOG,'End time RELATIONSHIP: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
END validate_relationship;

-- Duplicate subject
PROCEDURE Eliminate_dup_subject IS
 CURSOR dup_csr IS
   SELECT subject_id
         ,relationship_type_code
         ,count(*)
    FROM csi_ii_relation_interface
   WHERE process_status='R'
     AND relationship_type_code <> 'CONNECTED-TO'
GROUP BY subject_id,relationship_type_code
  HAVING count(*) > 1;

 CURSOR upd_csr (p_rel_id IN NUMBER
                ,p_subject_id IN NUMBER
                ,p_rel_type IN VARCHAR2) IS
   SELECT cir.rel_interface_id
     FROM csi_ii_relation_interface cir
    WHERE cir.subject_id = p_subject_id
      AND cir.relationship_type_code = p_rel_type
      AND cir.rel_interface_id <> p_rel_id;

   l_ret_relationship_id      NUMBER;
   TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_rel_id_tbl     NUMLIST;
   l_ctr            NUMBER := 0;

   TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   TYPE V30TabType IS VARRAY(10000) OF VARCHAR2(30);

   l_subject_id_upd           NumTabType;
   l_count_upd                NumTabType;
   l_rel_type_code_upd        V30TabType;

   MAX_BUFFER_SIZE         NUMBER := 1000;
  BEGIN
     OPEN dup_csr;
     LOOP
        FETCH dup_csr BULK COLLECT INTO
           l_subject_id_upd,
           l_rel_type_code_upd,
           l_count_upd
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR k in 1..l_subject_id_upd.count
        LOOP
           l_ret_relationship_id := -9999;
          BEGIN
           SELECT MAX(cir.rel_interface_id)
             INTO l_ret_relationship_id
             FROM csi_ii_relation_interface cir
            WHERE cir.subject_id = l_subject_id_upd(k)
              AND cir.relationship_type_code = l_rel_type_code_upd(k);
          END;

          FOR upd_rec IN upd_csr(l_ret_relationship_id
                                ,l_subject_id_upd(k)
                                ,l_rel_type_code_upd(k))
          LOOP
            l_ctr := l_ctr + 1;
            l_rel_id_tbl(l_ctr) := upd_rec.rel_interface_id;
          END LOOP;
        END LOOP;
       EXIT WHEN dup_csr%NOTFOUND;
     END LOOP;

     IF dup_csr%ISOPEN THEN
        CLOSE dup_csr;
     END IF;

     IF l_rel_id_tbl.count > 0
     THEN
       FORALL j IN l_rel_id_tbl.FIRST .. l_rel_id_tbl.LAST
         UPDATE csi_ii_relation_interface
            SET process_status='E'
               ,error_text='Duplicate subject_id record'
               ,parallel_worker_id=0
         WHERE rel_interface_id = l_rel_id_tbl(j);
         COMMIT;
     END IF;
END Eliminate_dup_subject;
-- End duplicate subject

-- Duplicate records
PROCEDURE Eliminate_dup_records IS
 CURSOR dup_csr IS
   SELECT object_id
         ,subject_id
         ,relationship_type_code
         ,count(*)
    FROM csi_ii_relation_interface
   WHERE process_status='R'
GROUP BY object_id,subject_id,relationship_type_code
  HAVING count(*) > 1;

 CURSOR upd_csr (p_rel_id     IN NUMBER
                ,p_object_id  IN NUMBER
                ,p_subject_id IN NUMBER
                ,p_rel_type   IN VARCHAR2) IS
   SELECT cir.rel_interface_id
     FROM csi_ii_relation_interface cir
    WHERE cir.object_id = p_object_id
      AND cir.subject_id = p_subject_id
      AND cir.relationship_type_code = p_rel_type
      AND cir.rel_interface_id <> p_rel_id;

   l_ret_relationship_id      NUMBER;
   TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_rel_id_tbl     NUMLIST;
   l_ctr            NUMBER := 0;

   TYPE NumTabType IS VARRAY(10000) OF NUMBER;
   TYPE V30TabType IS VARRAY(10000) OF VARCHAR2(30);

   l_object_id_upd            NumTabType;
   l_subject_id_upd           NumTabType;
   l_count_upd                NumTabType;
   l_rel_type_code_upd        V30TabType;

   MAX_BUFFER_SIZE         NUMBER := 1000;
  BEGIN
     OPEN dup_csr;
     LOOP
        FETCH dup_csr BULK COLLECT INTO
           l_object_id_upd,
           l_subject_id_upd,
           l_rel_type_code_upd,
           l_count_upd
        LIMIT MAX_BUFFER_SIZE;
        --
        FOR k IN 1..l_object_id_upd.count
        LOOP
           l_ret_relationship_id := -9999;
          BEGIN
           SELECT MAX(cir.rel_interface_id)
             INTO l_ret_relationship_id
             FROM csi_ii_relation_interface cir
            WHERE cir.subject_id = l_subject_id_upd(k)
              AND cir.object_id = l_object_id_upd(k)
              AND cir.relationship_type_code = l_rel_type_code_upd(k);
          END;

          FOR upd_rec IN upd_csr(l_ret_relationship_id
                                ,l_object_id_upd(k)
                                ,l_subject_id_upd(k)
                                ,l_rel_type_code_upd(k))
          LOOP
            l_ctr := l_ctr + 1;
            l_rel_id_tbl(l_ctr) := upd_rec.rel_interface_id;
          END LOOP;
        END LOOP;
       EXIT WHEN dup_csr%NOTFOUND;
     END LOOP;

     IF dup_csr%ISOPEN THEN
        CLOSE dup_csr;
     END IF;

     IF l_rel_id_tbl.count > 0
     THEN
       FORALL j IN l_rel_id_tbl.FIRST .. l_rel_id_tbl.LAST
         UPDATE csi_ii_relation_interface
            SET process_status='E'
               ,error_text='Duplicate record'
               ,parallel_worker_id=0
         WHERE rel_interface_id = l_rel_id_tbl(j);
         COMMIT;
     END IF;
END Eliminate_dup_records;
-- End duplicate records

-- Start check cyclic
PROCEDURE check_cyclic IS
CURSOR chk_cyclic_csr IS
 SELECT object_id
       ,subject_id
       ,rel_interface_id
       ,relationship_type_code
   FROM csi_ii_relation_interface
  WHERE process_status='R';
l_rel_tbl                    csi_ml_util_pvt.ii_rel_interface_tbl;
l_error                      BOOLEAN :=FALSE;
l_rel_id_array               dbms_sql.Number_Table;
l_status_array               dbms_sql.Varchar2_Table;
l_error_array                dbms_sql.Varchar2_Table;
l_num_of_rows                NUMBER;
l_dummy                      NUMBER;
rel_row                      NUMBER;
l_upd_stmt                   VARCHAR2(2000);
BEGIN
   l_rel_tbl.DELETE;
   FOR l_chk_cyclic_csr IN chk_cyclic_csr
   LOOP
     l_error := FALSE;
     csi_ml_util_pvt.get_children
      (p_object_id   => l_chk_cyclic_csr.subject_id,
       p_rel_tbl     => l_rel_tbl
       );

    IF l_rel_tbl.count > 0
    THEN
      FOR j IN l_rel_tbl.FIRST .. l_rel_tbl.LAST
      LOOP
        IF l_rel_tbl(j).subject_id = l_chk_cyclic_csr.subject_id
        THEN
          l_error := TRUE;
          exit;
        END IF;
      END LOOP;
        IF l_error
        THEN
          rel_row:=0;
          FOR i IN l_rel_tbl.FIRST .. l_rel_tbl.LAST
          LOOP
             rel_row:=rel_row+1;
             l_error_array(rel_row)   := 'You are trying to create a parent child loop.';
             l_status_array(rel_row)  := 'E';
             l_rel_id_array(rel_row)  := l_rel_tbl(i).rel_interface_id;
          END LOOP;

          IF l_rel_id_array.count > 0 THEN
            FND_File.Put_Line(Fnd_File.LOG,'Updating status in for parent child loop ');
             BEGIN
                l_upd_stmt := 'UPDATE csi_ii_relation_interface
                                  SET process_status   =  :status
                                     ,error_text       =  :error_text
                                     ,parallel_worker_id =0
                                WHERE rel_interface_id =  :intf_id';
                l_num_of_rows := dbms_sql.open_cursor;
                dbms_sql.parse(l_num_of_rows,l_upd_stmt,dbms_sql.native);
                dbms_sql.bind_array(l_num_of_rows,':intf_id',l_rel_id_array);
                dbms_sql.bind_array(l_num_of_rows,':status',l_status_array);
                dbms_sql.bind_array(l_num_of_rows,':error_text',l_error_array);
                l_dummy := dbms_sql.execute(l_num_of_rows);
                dbms_sql.close_cursor(l_num_of_rows);
             EXCEPTION
                WHEN OTHERS THEN
                   NULL;
             END;
             COMMIT;
          END IF;
        END IF;
    END IF;
   END LOOP;
END check_cyclic;
-- End check cyclic

END CSI_ML_UTIL_PVT;

/
