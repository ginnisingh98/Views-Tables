--------------------------------------------------------
--  DDL for Package Body CSI_ML_CREATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_CREATE_PUB" AS
-- $Header: csimcrpb.pls 120.4 2007/11/27 02:35:22 anjgupta ship $

PROCEDURE create_instances
 (
    x_msg_data              OUT NOCOPY   VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_batch_name            IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_resolve_ids           IN     VARCHAR2) IS

    l_txn_tbl                 CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL;
    l_return_status           VARCHAR2(1);
    l_error_message           VARCHAR2(2000);
    l_instance_tbl            CSI_DATASTRUCTURES_PUB.INSTANCE_TBL;
    l_new_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
    l_party_tbl               CSI_DATASTRUCTURES_PUB.PARTY_TBL;
    l_account_tbl             CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
    l_ext_attrib_tbl          CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
    l_price_tbl               CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
    l_org_assign_tbl          CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
    l_asset_assignment_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
    l_grp_error_tbl           CSI_DATASTRUCTURES_PUB.GRP_ERROR_TBL;
    l_api_version             NUMBER   := 1.0;
    l_commit                  VARCHAR2(1) := fnd_api.g_false;
    l_init_msg_list           VARCHAR2(1) := fnd_api.g_true;
    l_validation_level        NUMBER   := fnd_api.g_valid_level_full;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_msg_index               NUMBER;
    l_sql_error               VARCHAR2(2000);
    l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    l_fnd_unexpected          VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
    l_api_name                VARCHAR2(255) :=
                              'CSI_ML_CREATE_PUB.CREATE_INSTANCES';
    x_count                   NUMBER := 0;
    l_count                   NUMBER := 0;
    l_commit_recs             NUMBER := 0;
    l_ext_tbl_count           NUMBER := 0;

    l_inst_id_tbl             CSI_ML_UTIL_PVT.INST_INTERFACE_TBL_TYPE;
    l_party_contact_tbl       CSI_ML_UTIL_PVT.PARTY_CONTACT_TBL_TYPE;
    i                         PLS_INTEGER;
    j                         PLS_INTEGER;
    d                         PLS_INTEGER;
    c                         PLS_INTEGER;
    l_tbl_count               NUMBER :=0;
    l_txn_from_date           DATE;
    l_txn_to_date             DATE;
    l_debug_level    NUMBER      := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

 CURSOR c_id is
  SELECT a.inst_interface_id
  FROM   csi_instance_interface a
  WHERE  a.process_status = 'X';

r_id     c_id%rowtype;
RESOLVE_ERROR  EXCEPTION;

BEGIN

  x_return_status := l_fnd_success;

  -- Get the number of recs that should be processed before doing a
  -- commit;

  SELECT nvl(FND_PROFILE.VALUE('CSI_OPEN_INTERFACE_COMMIT_RECS'),1000)
  INTO   l_commit_recs
  FROM   dual;
     l_txn_from_date := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
     l_txn_to_date := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
  -- get the number of records and fiqure out how many loops to do
  SELECT ceil(count(1)/l_commit_recs)
  INTO x_count
  FROM csi_instance_interface
  WHERE trunc(source_transaction_date) BETWEEN
              nvl(l_txn_from_date,trunc(source_transaction_date)) AND
              nvl(l_txn_to_date,trunc(source_transaction_date))
  AND process_status = 'R'
  AND parallel_worker_id is NULL
  AND source_system_name = nvl(p_source_system_name,source_system_name);

 IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'Number of Loops: '||to_char(x_count));
end if;

  FOR l_count in 1 .. x_count LOOP

    -- first update the tables to have 'R' in the process status field.
    -- Otherwise they will be null

    -- Process Statuses
    -- R = Ready Status
    -- X = Intermediate Process Status
    -- P = Processed No Error
    -- E = Error

    UPDATE csi_instance_interface a
    SET process_status        = 'X'
    WHERE trunc(source_transaction_date) BETWEEN
                            nvl(l_txn_from_date,trunc(source_transaction_date)) AND
                            nvl(l_txn_to_date,trunc(source_transaction_date))
    AND process_status = 'R'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id is NULL
    AND rownum <= l_commit_recs;

    l_inst_id_tbl.delete;
    i := 1;
    FOR r_id IN c_id LOOP
       l_inst_id_tbl(i).inst_interface_id     := r_id.inst_interface_id;
    i := i + 1;
    END LOOP;

    l_tbl_count := 0;
    l_tbl_count := l_inst_id_tbl.count;

    IF nvl(p_resolve_ids,'Y') = 'Y'
    THEN
    -- Resolve all ID fields from Descriptive Fields

       CSI_ML_UTIL_PVT.resolve_ids(p_txn_from_date,
				   p_txn_to_date,
				   p_batch_name,
				   p_source_system_name,
				   l_return_status,
				   l_error_message);

       IF NOT l_return_status = l_fnd_success THEN
	 RAISE RESOLVE_ERROR; --fnd_api.g_exc_error;
       END IF;
    END IF;
    -- After getting IDs now create PL/SQL Tables

    SAVEPOINT create_instances;

    CSI_ML_CREATE_PVT.get_iface_create_recs (p_txn_from_date,
                                             p_txn_to_date,
                                             p_source_system_name,
                                             NULL, -- p_worker_id,
                                             l_commit_recs,
                                             l_instance_tbl,
                                             l_party_tbl,
                                             l_account_tbl,
                                             l_ext_attrib_tbl,
                                             l_price_tbl,
                                             l_org_assign_tbl,
                                             l_txn_tbl,
                                             l_party_contact_tbl,
                                             l_asset_assignment_tbl,
                                             l_return_status,
                                             l_error_message);

    IF NOT l_return_status = l_fnd_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

-- commented the following unnecessary code
/*
    IF l_party_contact_tbl.count > 0 THEN

      FOR c in l_party_contact_tbl.FIRST .. l_party_contact_tbl.LAST LOOP
        d := 1;
        FOR d in l_party_tbl.FIRST .. l_party_tbl.LAST LOOP
          IF  l_party_contact_tbl(c).inst_interface_id = l_party_tbl(d).interface_id AND
              l_party_contact_tbl(c).contact_party_id = l_party_tbl(d).party_id AND
              l_party_contact_tbl(c).contact_party_rel_type = l_party_tbl(d).relationship_type_code AND
              l_party_tbl(d).contact_flag = 'N' THEN
            l_party_tbl(l_party_contact_tbl(c).parent_tbl_idx).contact_parent_tbl_index  := d;
          END IF;
        END LOOP;
      END LOOP;
    END IF;
*/
    csi_item_instance_grp.create_item_instance
     (p_api_version           => l_api_version,
      p_commit                => l_commit,
      p_init_msg_list         => l_init_msg_list,
      p_validation_level      => l_validation_level,
      p_instance_tbl          => l_instance_tbl,
      p_ext_attrib_values_tbl => l_ext_attrib_tbl,
      p_party_tbl             => l_party_tbl,
      p_account_tbl           => l_account_tbl,
      p_pricing_attrib_tbl    => l_price_tbl,
      p_org_assignments_tbl   => l_org_assign_tbl,
      p_asset_assignment_tbl  => l_asset_assignment_tbl,
      p_txn_tbl               => l_txn_tbl,
      p_grp_error_tbl         => l_grp_error_tbl,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);

    IF NOT l_Return_Status = l_fnd_success THEN
      l_msg_index := 1;
      l_Error_Message := l_Msg_Data;
	 WHILE l_msg_count > 0 LOOP
	   l_Error_Message := l_Error_Message||FND_MSG_PUB.GET(l_msg_index,
                                               FND_API.G_FALSE);
           l_msg_index := l_msg_index + 1;
           l_Msg_Count := l_Msg_Count - 1;
  	 END LOOP;
         RAISE fnd_api.g_exc_error;
    END IF;

    l_tbl_count := 0;
    l_tbl_count := l_instance_tbl.count;
    l_ext_tbl_count := l_ext_attrib_tbl.count;
    IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Updating Status of Inst Children '||
         l_tbl_count);
    FND_File.Put_Line(Fnd_File.LOG,'Ext Attr Status Recs '||l_ext_tbl_count);
    FND_File.Put_Line(Fnd_File.LOG,'Before Loop to set Child Status: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
    END IF;

    j := 1;
    IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'After Loop to set Child Status: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
    END IF;
  COMMIT;
  END LOOP; -- End of For Loop

  -- Display errors in Concurrent Manager Log
  CSI_ML_UTIL_PVT.log_create_errors(p_txn_from_date,
                                    p_txn_to_date,
                                    l_return_status,
                                    l_error_message);

  IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'After Log Errors: '||
       to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
  END IF;

  COMMIT;

  EXCEPTION
    WHEN RESOLVE_ERROR THEN
      IF(l_debug_level>1) THEN
       FND_File.Put_Line(Fnd_File.LOG,'Resolve IDs Errored out...');
       FND_File.Put_Line(Fnd_File.LOG,l_error_message);
      END IF;
       x_return_status := l_fnd_error;
       x_msg_data      := l_error_message;
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to create_instances;
      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'In EXPECTED Exception in:'||l_api_name);
      FND_File.Put_Line(Fnd_File.LOG,l_error_message);
      END IF;
      x_return_status := l_fnd_error;
      x_msg_data      := l_error_message;

    WHEN others THEN
      ROLLBACK to create_instances;
      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'In WHEN OTHERS Exception in:'||l_api_name);
      END IF;
      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_msg_data := fnd_message.get;
      FND_File.Put_Line(Fnd_File.LOG,x_msg_data);
      x_return_status := l_fnd_unexpected;

END create_instances;

PROCEDURE create_parallel_instances
 (
    x_msg_data              OUT NOCOPY   VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_worker_id             IN     NUMBER,
    p_resolve_ids           IN     VARCHAR2) IS

    l_txn_tbl                 CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL;
    l_return_status           VARCHAR2(1);
    l_error_message           VARCHAR2(2000);
    l_instance_tbl            CSI_DATASTRUCTURES_PUB.INSTANCE_TBL;
    l_new_instance_rec        CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
    l_party_tbl               CSI_DATASTRUCTURES_PUB.PARTY_TBL;
    l_account_tbl             CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
    l_ext_attrib_tbl          CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
    l_price_tbl               CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
    l_org_assign_tbl          CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
    l_asset_assignment_tbl    CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
    l_grp_error_tbl           CSI_DATASTRUCTURES_PUB.GRP_ERROR_TBL;
    l_api_version             NUMBER   := 1.0;
    l_commit                  VARCHAR2(1) := fnd_api.g_false;
    l_init_msg_list           VARCHAR2(1) := fnd_api.g_true;
    l_validation_level        NUMBER   := fnd_api.g_valid_level_full;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_msg_index               NUMBER;
    l_sql_error               VARCHAR2(2000);
    l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    l_fnd_unexpected          VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
    l_api_name                VARCHAR2(255) :=
                              'CSI_ML_CREATE_PUB.CREATE_PARALLEL_INSTANCES';
    x_count                   NUMBER := 0;
    l_count                   NUMBER := 0;
    l_commit_recs             NUMBER := 0;
    l_ext_tbl_count           NUMBER := 0;

    l_inst_id_tbl             CSI_ML_UTIL_PVT.INST_INTERFACE_TBL_TYPE;
    l_party_contact_tbl       CSI_ML_UTIL_PVT.PARTY_CONTACT_TBL_TYPE;
    i                         PLS_INTEGER;
    j                         PLS_INTEGER;
    d                         PLS_INTEGER;
    c                         PLS_INTEGER;
    l_tbl_count               NUMBER :=0;
    l_source_flag             VARCHAR2(1);
    l_count1                  NUMBER;
    l_debug_level             NUMBER      := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

CURSOR c_id (pc_parallel_worker_id IN NUMBER) is
  SELECT inst_interface_id,process_status
  FROM csi_instance_interface
  WHERE process_status = 'X'
  AND   nvl(transaction_identifier,'-1') = '-1'
  AND parallel_worker_id = pc_parallel_worker_id;

    r_id                      c_id%rowtype;
    RESOLVE_ERROR             EXCEPTION;
     l_txn_from_date          DATE;
     l_txn_to_date            DATE;

BEGIN

 IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'Start Time of Pub: '||
       to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
 END IF;
  x_return_status := l_fnd_success;

  -- Get the number of recs that should be processed before doing a
  -- commit;

  SELECT nvl(FND_PROFILE.VALUE('CSI_OPEN_INTERFACE_COMMIT_RECS'),1000)
  INTO   l_commit_recs
  FROM   dual;

  FND_File.Put_Line(Fnd_File.LOG,'After Commit Profile: '||
       to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));

     l_txn_from_date := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
     l_txn_to_date := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');

  -- Get the number of records and fiqure out how many loops to do
  SELECT ceil(count(1)/l_commit_recs)
  INTO x_count
  FROM csi_instance_interface
  WHERE trunc(source_transaction_date) BETWEEN
              nvl(l_txn_from_date,trunc(source_transaction_date)) AND
              nvl(l_txn_to_date,trunc(source_transaction_date))
  AND   nvl(transaction_identifier,'-1') = '-1'
  AND process_status = 'R'
  AND source_system_name = nvl(p_source_system_name,source_system_name)
  AND parallel_worker_id = p_worker_id;

IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'After Fiqure out Loops: '||
       to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
  FND_File.Put_Line(Fnd_File.LOG,'Number of Loops: '||to_char(x_count));
END IF;

  FOR l_count in 1 .. x_count LOOP
    -- Update the tables to have 'X' in the process status field.
    -- Otherwise they will be null

    -- Process Statuses
    -- R = Ready Status
    -- X = Intermediate Process Status
    -- P = Processed No Error
    -- E = Error

    UPDATE csi_instance_interface a
    SET process_status        = 'X'
    WHERE trunc(source_transaction_date) BETWEEN
                            nvl(l_txn_from_date,trunc(source_transaction_date)) AND
                            nvl(l_txn_to_date,trunc(source_transaction_date))
    AND nvl(transaction_identifier,'-1') = '-1'
    AND process_status = 'R'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id = p_worker_id
    AND rownum <= l_commit_recs;

  IF(l_debug_level>1) THEN

    FND_File.Put_Line(Fnd_File.LOG,'After setting INST IFACE to X: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
 END IF;

    l_inst_id_tbl.delete;
    i := 1;
    FOR r_id IN c_id (p_worker_id) LOOP
       l_inst_id_tbl(i).inst_interface_id     := r_id.inst_interface_id;
    i := i + 1;
    END LOOP;

    COMMIT;

  IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'After ID PL/SQL Table Create: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
  END IF;

    l_tbl_count := 0;
    l_tbl_count := l_inst_id_tbl.count;
  IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Records Found: '||l_tbl_count);
    FND_File.Put_Line(Fnd_File.LOG,'After Looping Child Tables: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));

    -- Resolve all ID fields from Descriptive Fields
    FND_File.Put_Line(Fnd_File.LOG,'Before Resolve IDs: '||
        to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
  END IF;
   IF l_tbl_count>0 -- Added
   THEN
    IF NVL(p_resolve_ids,'Y') = 'Y' THEN
      CSI_ML_UTIL_PVT.resolve_pw_ids(p_txn_from_date,
                                     p_txn_to_date,
                                     p_source_system_name,
                                     p_worker_id,
                                     l_return_status,
                                     l_error_message);
    IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'After Resolve IDs: '||
           to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
    END IF;

      IF NOT l_return_status = l_fnd_success THEN
        RAISE RESOLVE_ERROR; --fnd_api.g_exc_error;
      END IF;
    END IF;

    -- After getting IDs now create PL/SQL Tables
    IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Before PL/SQL Table Create: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
    END IF;

    SAVEPOINT create_parallel_instances;

    CSI_ML_CREATE_PVT.get_iface_create_recs (p_txn_from_date,
                                             p_txn_to_date,
                                             p_source_system_name,
                                             p_worker_id,
                                             l_commit_recs,
                                             l_instance_tbl,
                                             l_party_tbl,
                                             l_account_tbl,
                                             l_ext_attrib_tbl,
                                             l_price_tbl,
                                             l_org_assign_tbl,
                                             l_txn_tbl,
                                             l_party_contact_tbl,
                                             l_asset_assignment_tbl,
                                             l_return_status,
                                             l_error_message);
   IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'After PL/SQL Table Create: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
   END IF;

    IF NOT l_return_status = l_fnd_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Before Contact Loop: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));

-- commented the following unnecessary code
/*
    IF l_party_contact_tbl.count > 0 THEN

      FOR c in l_party_contact_tbl.FIRST .. l_party_contact_tbl.LAST LOOP
        d := 1;
        FOR d in l_party_tbl.FIRST .. l_party_tbl.LAST LOOP
          IF  l_party_contact_tbl(c).inst_interface_id = l_party_tbl(d).interface_id AND
              l_party_contact_tbl(c).contact_party_id = l_party_tbl(d).party_id AND
              l_party_contact_tbl(c).contact_party_rel_type = l_party_tbl(d).relationship_type_code AND
              l_party_tbl(d).contact_flag = 'N' THEN
            l_party_tbl(l_party_contact_tbl(c).parent_tbl_idx).contact_parent_tbl_index  := d;
          END IF;
        END LOOP;
      END LOOP;
    END IF;
*/
    FND_File.Put_Line(Fnd_File.LOG,'After Contact Loop: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));

    FND_File.Put_Line(Fnd_File.LOG,'Before GRP API: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
END IF;
   csi_item_instance_grp.create_item_instance
     (p_api_version           => l_api_version,
      p_commit                => l_commit,
      p_init_msg_list         => l_init_msg_list,
      p_validation_level      => l_validation_level,
      p_instance_tbl          => l_instance_tbl,
      p_ext_attrib_values_tbl => l_ext_attrib_tbl,
      p_party_tbl             => l_party_tbl,
      p_account_tbl           => l_account_tbl,
      p_pricing_attrib_tbl    => l_price_tbl,
      p_org_assignments_tbl   => l_org_assign_tbl,
      p_asset_assignment_tbl  => l_asset_assignment_tbl,
      p_txn_tbl               => l_txn_tbl,
      p_grp_error_tbl         => l_grp_error_tbl,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data);



    IF NOT l_Return_Status = l_fnd_success THEN
      l_msg_index := 1;
      l_Error_Message := l_Msg_Data;
	 WHILE l_msg_count > 0 LOOP
	   l_Error_Message := l_Error_Message||FND_MSG_PUB.GET(l_msg_index,
	                                          FND_API.G_FALSE);
           l_msg_index := l_msg_index + 1;
           l_Msg_Count := l_Msg_Count - 1;
  	 END LOOP;
         RAISE fnd_api.g_exc_error;
    END IF;
IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'After GRP API: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
END IF;
    l_tbl_count := 0;
    l_tbl_count := l_instance_tbl.count;
    l_ext_tbl_count := l_ext_attrib_tbl.count;
  IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Updating Status of Inst Children '||
         l_tbl_count);
    FND_File.Put_Line(Fnd_File.LOG,'Ext Attr Status Recs '||l_ext_tbl_count);
    FND_File.Put_Line(Fnd_File.LOG,'Before Loop to set Child Status: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));

    FND_File.Put_Line(Fnd_File.LOG,'After Loop to set Child Status: '||
         to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
  END IF;
  END IF; -- End addition
  COMMIT;
  END LOOP; -- End of For Loop

  CSI_ML_UTIL_PVT.log_create_pw_errors(p_txn_from_date,
                                       p_txn_to_date,
                                       p_source_system_name,
                                       p_worker_id,
                                       l_return_status,
                                       l_error_message);

IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'After Log Errors: '||
       to_char(sysdate,'DD-MON-YYYY HH:MI:SS:SS'));
END IF;
  COMMIT;

  EXCEPTION
    WHEN RESOLVE_ERROR THEN
    IF(l_debug_level>1) THEN
       FND_File.Put_Line(Fnd_File.LOG,'Resolve Parallel IDs Errored out...');
    END IF;
      j := 1;
      FOR j in l_inst_id_tbl.FIRST .. l_inst_id_tbl.LAST LOOP

        UPDATE csi_instance_interface
        SET parallel_worker_id = -1
        WHERE inst_interface_id = l_inst_id_tbl(j).inst_interface_id;

      END LOOP;
      COMMIT;
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK to create_parallel_instances;

  IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'In EXPECTED Exception in:'||l_api_name);
  END IF;
      j := 1;
      FOR j in l_inst_id_tbl.FIRST .. l_inst_id_tbl.LAST LOOP

        UPDATE csi_instance_interface
        SET parallel_worker_id = -1
        WHERE inst_interface_id = l_inst_id_tbl(j).inst_interface_id;

      END LOOP;
      COMMIT;

      FND_File.Put_Line(Fnd_File.LOG,l_error_message);
      x_return_status := l_fnd_error;
      x_msg_data      := l_error_message;

    WHEN others THEN
      ROLLBACK to create_parallel_instances;

      FND_File.Put_Line(Fnd_File.LOG,'In WHEN OTHERS Exception in:'||l_api_name);

      j := 1;
      FOR j in l_inst_id_tbl.FIRST .. l_inst_id_tbl.LAST LOOP

        UPDATE csi_instance_interface
        SET parallel_worker_id = -1
        WHERE inst_interface_id = l_inst_id_tbl(j).inst_interface_id;

      END LOOP;
      COMMIT;

      l_sql_error := SQLERRM;
      fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_msg_data := fnd_message.get;
      FND_File.Put_Line(Fnd_File.LOG,substr(x_msg_data,1,200));
      x_return_status := l_fnd_unexpected;

END create_parallel_instances;

PROCEDURE create_relationships
 (
    x_msg_data              OUT NOCOPY   VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2,
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2) IS

    l_return_status         VARCHAR2(10);
    l_error_message         VARCHAR2(2000);
    l_relationship_tbl      CSI_DATASTRUCTURES_PUB.II_RELATIONSHIP_TBL;
    l_txn_tbl               CSI_DATASTRUCTURES_PUB.TRANSACTION_TBL;
    l_txn_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
    l_api_version           NUMBER   := 1.0;
    l_commit                VARCHAR2(1) := fnd_api.g_false;
    l_init_msg_list         VARCHAR2(1) := fnd_api.g_true;
    l_validation_level      NUMBER   := fnd_api.g_valid_level_full;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_msg_index             NUMBER;
    l_sql_error             VARCHAR2(2000);
    l_fnd_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_fnd_error             VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
    l_fnd_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
    l_api_name              VARCHAR2(255) :=
                              'CSI_ML_CREATE_PUB.CREATE_RELATIONSHIPS';
    x_count                 NUMBER := 0;
    l_count                 NUMBER := 0;
    l_commit_recs           NUMBER := 0;
    l_relationship_count    NUMBER := 0;
     l_debug_level NUMBER := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

BEGIN

IF(l_debug_level>1) THEN
  FND_File.Put_Line(Fnd_File.LOG,'Start of: '||l_api_name);
END IF;

  x_return_status := l_fnd_success;

  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     ROLLBACK to create_relationships;

IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'In EXPECTED Exception in:'||l_api_name);
     FND_File.Put_Line(Fnd_File.LOG,l_error_message);
END IF;
     x_return_status := l_fnd_error;
     x_msg_data := l_error_message;

   WHEN others THEN
     ROLLBACK to create_relationships;
IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'In WHEN OTHERS Exception in:'||l_api_name);
END IF;
     l_sql_error := SQLERRM;
     fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
     fnd_message.set_token('API_NAME',l_api_name);
     fnd_message.set_token('SQL_ERROR',SQLERRM);
     x_msg_data := fnd_message.get;
    IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,x_msg_data);
    END IF;
     x_return_status := l_fnd_unexpected;

END create_relationships;

END CSI_ML_CREATE_PUB;

/
