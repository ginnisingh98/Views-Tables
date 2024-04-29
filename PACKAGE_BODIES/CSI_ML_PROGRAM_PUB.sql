--------------------------------------------------------
--  DDL for Package Body CSI_ML_PROGRAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ML_PROGRAM_PUB" AS
-- $Header: csimconb.pls 120.6 2007/11/27 02:36:30 anjgupta ship $

PROCEDURE asset_vld_preprocessor
  (
      p_source_system_name     IN VARCHAR2,
      x_error_message          OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2

  ) IS

   TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_inst_intr_tbl           NUM_TBL;
   l_sync_sts                NUMBER;
   l_ctr                     NUMBER := 0 ;
   l_error_message           VARCHAR2(2000);
   l_return_status           VARCHAR2(1);
   l_syncup_family_seq       NUMBER := 0;
   l_syncup_vld_flag         VARCHAR2(1) := 'Y';
   l_process_status          VARCHAR2(1) := 'R';
   l_Asset_Error_text        VARCHAR2(2000);
   l_debug_level             NUMBER      := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

  CURSOR syncup_instance_cur IS
    SELECT csii.inst_interface_id,
           csii.instance_id,
           csii.quantity ,
           csii.location_id ,
           csii.location_type_code
    FROM   csi_instance_interface csii
    WHERE  process_status = 'R'
    AND    source_system_name = nvl(p_source_system_name,source_system_name)
    AND    EXISTS ( SELECT 1 FROM csi_i_asset_interface csiai
                    WHERE  csiai.inst_interface_id = csii.inst_interface_id )
    AND    syncup_family IS NULL;

   l_syncup_instance_rec syncup_instance_cur%ROWTYPE;

   l_instance_sync_tbl          CSI_ASSET_PVT.instance_sync_tbl;
   l_instance_asset_sync_tbl    CSI_ASSET_PVT.instance_asset_sync_tbl;
   l_fa_asset_sync_tbl          CSI_ASSET_PVT.fa_asset_sync_tbl;
   l_inst_interface_id          NUMBER ;
 BEGIN

  IF csi_gen_utility_pvt.is_eib_installed = 'Y' THEN

    UPDATE csi_instance_interface
    SET    syncup_family = NULL
    WHERE source_system_name = nvl(p_source_system_name,source_system_name)
    AND   syncup_family is not null
    AND   process_status = 'R';
    COMMIT;

     IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Invoking Pre-processor');
    END IF;

    LOOP
      OPEN syncup_instance_cur;
      FETCH syncup_instance_cur INTO l_syncup_instance_rec;
      EXIT WHEN syncup_instance_cur%NOTFOUND;
      CLOSE syncup_instance_cur;

      IF syncup_instance_cur%ISOPEN THEN
         CLOSE syncup_instance_cur;
      END IF;

      l_instance_sync_tbl(1).inst_interface_id :=l_syncup_instance_rec.inst_interface_id;
      l_instance_sync_tbl(1).instance_id       :=l_syncup_instance_rec.instance_id;
      l_instance_sync_tbl(1).instance_quantity :=l_syncup_instance_rec.quantity;
      l_instance_sync_tbl(1).location_id       :=l_syncup_instance_rec.location_id;
      l_instance_sync_tbl(1).location_type_code:=l_syncup_instance_rec.location_type_code;

      l_inst_interface_id := l_syncup_instance_rec.inst_interface_id;
      csi_asset_pvt.get_syncup_tree
      (    p_source_system_name          => p_source_system_name,
           p_called_from_grp             => fnd_api.g_true,
           px_instance_sync_tbl          => l_instance_sync_tbl,
           px_instance_asset_sync_tbl    => l_instance_asset_sync_tbl,
           x_fa_asset_sync_tbl           => l_fa_asset_sync_tbl,
           x_return_status               => l_return_status,
           x_error_msg                   => l_error_message
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF(l_debug_level>1) THEN
         FND_File.Put_Line(Fnd_File.LOG,'Error : '||l_error_message);
         end if;
         RAISE fnd_api.g_exc_error;
      END IF;

      csi_asset_pvt.asset_syncup_validation
      (    px_instance_sync_tbl          => l_instance_sync_tbl,
           px_instance_asset_sync_tbl    => l_instance_asset_sync_tbl,
           px_fa_asset_sync_tbl          => l_fa_asset_sync_tbl,
           x_return_status               => l_return_status,
           x_error_msg                   => l_error_message
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF(l_debug_level>1) THEN
         FND_File.Put_Line(Fnd_File.LOG,'Error : '||l_error_message);
        END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

       l_ctr := 0;

      IF l_instance_sync_tbl.count > 0 THEN
         FOR c_inst IN l_instance_sync_tbl.FIRST .. l_instance_sync_tbl.LAST
         LOOP
           IF l_instance_sync_tbl(c_inst).inst_interface_id IS NOT NULL THEN
              l_ctr := l_ctr + 1 ;
              l_inst_intr_tbl(l_ctr) := l_instance_sync_tbl(c_inst).inst_interface_id;
           END IF;
         END LOOP;
         l_syncup_vld_flag    := l_instance_sync_tbl(1).vld_status;
         l_syncup_family_seq  := l_syncup_family_seq +1 ;

         IF l_syncup_vld_flag  = 'E' THEN
           FOR i_asst IN l_inst_intr_tbl.first .. l_inst_intr_tbl.last
           LOOP
              UPDATE csi_i_asset_interface
              SET    fa_sync_flag     =  'N'
              WHERE inst_interface_id =  l_inst_intr_tbl(i_asst)
              AND   fa_sync_flag      =  'Y' ;

           END LOOP;
         ELSE
            l_Asset_Error_text  := NULL;
            l_process_status    := NULL;
         END IF;

         FORALL i_asst IN l_inst_intr_tbl.FIRST..l_inst_intr_tbl.LAST
         UPDATE csi_instance_interface csii
         SET syncup_family       =  l_syncup_family_seq,
             process_status      =  NVL(l_process_status ,csii.process_status),
             error_text          =  DECODE(l_process_status,'E',l_Asset_Error_text,
                                           error_text)
         WHERE inst_interface_id = l_inst_intr_tbl(i_asst);
      COMMIT;
      END IF;
      l_inst_intr_tbl.delete;
      l_instance_sync_tbl.delete;
      l_instance_asset_sync_tbl.delete;
      l_fa_asset_sync_tbl.delete;
    END LOOP;
   END IF;
   EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status  := l_return_status ;
        x_error_message  := l_error_message ;
END asset_vld_preprocessor;

PROCEDURE execute_openinterface
 (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_batch_name            IN     VARCHAR2,
    p_resolve_ids           IN     VARCHAR2,
    p_purge_processed_recs  IN     VARCHAR2,
    p_reprocess_option      IN     VARCHAR2) IS

  l_return_status           VARCHAR2(1);
  l_error_message           VARCHAR2(2000);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index               NUMBER;
  l_sql_error               VARCHAR2(2000);
  l_fnd_success             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_fnd_error               VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  l_fnd_unexpected          VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  l_api_name                VARCHAR2(255) := 'CSI_ML_CREATE_PUB.EXECUTE_OPENINTERFACE';

  l_debug_level             NUMBER      := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

CURSOR purge_cur is
SELECT inst_interface_id
  FROM csi_instance_interface
 WHERE process_status='P'
  AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328


  TYPE NumTabType IS VARRAY(10000) OF NUMBER;
       inst_intf_id_del         NumTabType;
       max_buffer_size          NUMBER := 9999;
  BEGIN

   -- x_return_status := l_fnd_success;

    IF p_reprocess_option ='ALL'
    THEN
    UPDATE csi_instance_interface cii
    SET process_status = 'R'
    WHERE  (NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,cii.batch_name)
          OR NVL(cii.batch_name,'$CSI_NULL_VALUE$')=NVL(p_batch_name,'$CSI_NULL_VALUE$'))
    AND   cii.source_system_name = p_source_system_name
    AND   cii.process_Status = 'E';
    COMMIT;
    END IF;


 IF NVL(p_purge_processed_recs,'Y') = 'Y'
 THEN
 OPEN purge_cur;
   LOOP
      FETCH purge_cur BULK COLLECT INTO
      inst_intf_id_del
      LIMIT max_buffer_size;

      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_INSTANCE_INTERFACE
        WHERE inst_interface_id=inst_intf_id_del(i1)
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328


      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_I_PARTY_INTERFACE cipi
        WHERE inst_interface_id=inst_intf_id_del(i1);

 /* bnarayan Added to purge processed asset interface records */
      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
        DELETE FROM CSI_I_ASSET_INTERFACE
        WHERE inst_interface_id=inst_intf_id_del(i1);


      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_IEA_VALUE_INTERFACE
        WHERE inst_interface_id=inst_intf_id_del(i1);

      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_II_RELATION_INTERFACE
        WHERE subject_interface_id=inst_intf_id_del(i1)
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328

      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_II_RELATION_INTERFACE
        WHERE object_interface_id=inst_intf_id_del(i1)
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328
 COMMIT;
       EXIT WHEN purge_cur%NOTFOUND;
   END LOOP;
     COMMIT;
 CLOSE purge_cur;
 END IF;

    asset_vld_preprocessor
    (
      p_source_system_name => p_source_system_name
     ,x_error_message      => l_error_message
     ,x_return_status      => l_return_status
    );
    IF NOT l_return_status = l_fnd_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Step 1: Run the create process to create all instances in the
    --         Interface Tables.

     IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Calling Process_iface_txns: ');
     END IF;
    CSI_ML_interface_txn_pvt.process_iface_txns(l_error_message,
                                       l_return_status,
                                       p_txn_from_date,
                                       p_txn_to_date,
                                       p_source_system_name,
                                       p_batch_name,
                                       p_resolve_ids );

    IF NOT l_return_status = l_fnd_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF(l_debug_level>1) THEN
       FND_File.Put_Line(Fnd_File.LOG,l_error_message);
       END IF;


     WHEN others THEN
       l_sql_error := SQLERRM;
       fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);
       FND_File.Put_Line(Fnd_File.LOG,'CSI_ML_PROGRAM_PUB.execute_openinterface - Into when others exception ');


END execute_openinterface;

PROCEDURE execute_parallel_create
 (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_txn_from_date         IN     varchar2,
    p_txn_to_date           IN     varchar2,
    p_source_system_name    IN     VARCHAR2,
    p_worker_count          IN     NUMBER,
    p_resolve_ids           IN     VARCHAR2,
    p_purge_processed_recs  IN     VARCHAR2) IS

  i                         PLS_INTEGER := 1;
  l_txn_from_date           DATE;
  l_txn_to_date             DATE;
  l_worker_count            NUMBER;
  l_r_worker_count          NUMBER;
  l_count                   NUMBER := 1;
  l_request_id              NUMBER;
  l_errbuf                  VARCHAR2(2000);
  x_r_count                 NUMBER := 0;
  x_count                   NUMBER := 0;
  l_return_status           VARCHAR2(1);
  l_error_message           VARCHAR2(2000);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index               NUMBER;
  l_sql_error               VARCHAR2(2000);
  l_fnd_success             VARCHAR2(1);
  l_fnd_error               VARCHAR2(1);
  l_fnd_unexpected          VARCHAR2(1);
  l_api_name                VARCHAR2(255) :=
                              'CSI_ML_CREATE_PUB.EXECUTE_PARALLEL_CREATE';
  l_inst_id_tbl             CSI_ML_UTIL_PVT.INST_INTERFACE_TBL_TYPE;
  ii                        PLS_INTEGER;
  j                         PLS_INTEGER;
  l_tbl_count               NUMBER :=0;
  l_dummy                   NUMBER;
  l_debug_level             NUMBER      := to_number(nvl(fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));
cursor c_id (pc_worker_id IN NUMBER) is
  SELECT inst_interface_id,parallel_worker_id
  FROM csi_instance_interface
  WHERE parallel_worker_id = pc_worker_id
  AND process_status = 'R'
  AND source_system_name = nvl(p_source_system_name,source_system_name);

 CURSOR candidates_exist_cur IS
    SELECT distinct parallel_worker_id
    FROM csi_instance_interface
    WHERE process_status = 'R'
    AND source_system_name = nvl(p_source_system_name,source_system_name) --included for bug5949328
    AND parallel_worker_id IS NOT NULL
    AND transaction_identifier IS NULL;

 CURSOR SRL_CUR IS
   select serial_number
   from csi_instance_interface
   where source_system_name = nvl(p_source_system_name,source_system_name)
   and   serial_number is not null
   and   process_status = 'R'
   group by serial_number
   having count(*) > 1;

   -- start rel_enh
 CURSOR relations_exist_cur IS
    SELECT distinct parallel_worker_id
    FROM csi_ii_relation_interface
    WHERE process_status = 'R'
    AND source_system_name = nvl(p_source_system_name,source_system_name) --included for bug5949328
    AND parallel_worker_id IS NOT NULL
    AND transaction_identifier IS NULL;
  l_rel_dummy                   NUMBER;
-- end rel_enh

   --
   TYPE SRL_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   --
   l_srl_tbl          SRL_TBL;
   l_ctr              NUMBER;
   --
  r_id   c_id%rowtype;
  req_data      VARCHAR2(10);
  l_old_error   NUMBER;
  l_new_error   NUMBER;
  l_req_count   NUMBER :=0;

   l_rel_count    NUMBER :=0;
  l_valid_count  NUMBER :=0;
  l_insert_count NUMBER :=0;
  l_update_count NUMBER :=0;


CURSOR purge_cur IS
SELECT inst_interface_id
  FROM csi_instance_interface
 WHERE process_status='P'
 AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328

  TYPE NumTabType IS VARRAY(10000) OF NUMBER;
       inst_intf_id_del         NumTabType;
       max_buffer_size          NUMBER := 9999;
BEGIN

   req_data:= fnd_conc_global.request_data;
   IF(l_debug_level>1) THEN
   FND_File.Put_Line(Fnd_File.LOG,'Value of req_data is :'||req_data);
   END IF;
IF req_data IS NULL
THEN
    -- Since req_data is null, I'll assume this is the first run.
  BEGIN
   SELECT COUNT(*)
   INTO   l_old_error
   FROM   csi_instance_interface
   WHERE  process_status='E'
   AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328

  EXCEPTION
   WHEN OTHERS THEN
     l_old_error:=0;
  END;


  l_fnd_success             := FND_API.G_RET_STS_SUCCESS;
  l_fnd_error               := FND_API.G_RET_STS_ERROR;
  l_fnd_unexpected          := FND_API.G_RET_STS_UNEXP_ERROR;


 IF NVL(p_purge_processed_recs,'Y') = 'Y'
 THEN
 OPEN purge_cur;
   LOOP
      FETCH purge_cur BULK COLLECT INTO
      inst_intf_id_del
      LIMIT max_buffer_size;

      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_INSTANCE_INTERFACE
        WHERE inst_interface_id=inst_intf_id_del(i1)
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328;


      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_I_PARTY_INTERFACE cipi
        WHERE inst_interface_id=inst_intf_id_del(i1);

  /* bnarayan Added to purge processed asset interface records */
      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
        DELETE FROM CSI_I_ASSET_INTERFACE
        WHERE inst_interface_id=inst_intf_id_del(i1);


      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_IEA_VALUE_INTERFACE
        WHERE inst_interface_id=inst_intf_id_del(i1);

      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_II_RELATION_INTERFACE
        WHERE subject_interface_id=inst_intf_id_del(i1)
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328;;

      FORALL i1 IN 1 .. inst_intf_id_del.COUNT
       DELETE FROM CSI_II_RELATION_INTERFACE
        WHERE object_interface_id=inst_intf_id_del(i1)
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328;;

 COMMIT;
       EXIT WHEN purge_cur%NOTFOUND;
   END LOOP;
     COMMIT;
 CLOSE purge_cur;
 END IF;

 asset_vld_preprocessor
    (
      p_source_system_name => p_source_system_name
     ,x_error_message      => l_error_message
     ,x_return_status      => l_return_status
    );
    IF NOT l_return_status = l_fnd_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Begin Execute paralle create: '||p_worker_count);
    END IF;
  --  x_return_status := l_fnd_success;

    -- If the worker number is not provided default to 32

     IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'p_worker_count: '||p_worker_count);
    END IF;
    IF (p_worker_count is NULL OR
        p_worker_count > 32) THEN
      l_worker_count := 32;
    ELSE
      l_worker_count := p_worker_count;
    END IF;
    -- srramakr In order to avoid creating multiple instances with serial number violation
    -- we need to assign all the instances having the same serial number to worker 1.
    -- This way, when the instances get validated by the API, if serial uniqueness is violated
    -- the record will error out.
    --
    l_ctr := 0;
    l_srl_tbl.DELETE;
    --
    FOR v_rec in SRL_CUR LOOP
       l_ctr := l_ctr + 1;
       l_srl_tbl(l_ctr) := v_rec.serial_number;
    END LOOP;
    --
    IF l_srl_tbl.count > 0 THEN
       FORALL j in l_srl_tbl.FIRST .. l_srl_tbl.LAST
	  UPDATE CSI_INSTANCE_INTERFACE
	  set parallel_worker_id = 1
	  where serial_number = l_srl_tbl(j)
	  and   source_system_name = nvl(p_source_system_name,source_system_name)
	  and   process_status = 'R';
    END IF;
    commit;
    --
    -- Get the count of the remaining records and divide that number by the number
    -- of workers and assign that number to each record.
     l_txn_from_date := to_date(p_txn_from_date, 'YYYY/MM/DD HH24:MI:SS');
     l_txn_to_date := to_date(p_txn_to_date, 'YYYY/MM/DD HH24:MI:SS');
    SELECT ceil(count(1)/l_worker_count)
    INTO x_count
    FROM csi_instance_interface
    WHERE trunc(source_transaction_date) BETWEEN
                nvl(l_txn_from_date,trunc(source_transaction_date)) AND
                nvl(l_txn_to_date,trunc(source_transaction_date))
    AND transaction_identifier IS NULL
    AND process_status = 'R'
    AND source_system_name = nvl(p_source_system_name,source_system_name)
    AND parallel_worker_id = -1;
    --
    -- After we get the number of workers and how many recs per worker
    -- loop thru resolve IDs so that we are able to do the uniqueness checks

    FOR l_count in 1 .. l_worker_count LOOP

      UPDATE csi_instance_interface
      SET parallel_worker_id = l_count
      WHERE rownum <= x_count
      AND parallel_worker_id = -1
      AND source_system_name = nvl(p_source_system_name,source_system_name) --Added for bug 3621991
      AND process_status = 'R'; --Added for bug 3621991

      COMMIT;

      l_inst_id_tbl.delete;
      ii := 1;
      FOR r_id IN c_id (l_count) LOOP -- Worker ID
         l_inst_id_tbl(ii).inst_interface_id     := r_id.inst_interface_id;
      ii := ii + 1;
      END LOOP;

      l_tbl_count := 0;
      l_tbl_count := l_inst_id_tbl.count;

      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Records In Table: '||l_tbl_count);
      END IF;

    -- Now that the parallel_worker_id column is updated and committed
    -- we can run the create procedure using multiple concurrent workers
    -- We will do this in the same loop so that the process can get started.

    -- Set FND security valiables
    END LOOP;

     IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Before apps initialize: ');
     END IF;

    OPEN candidates_exist_cur;
    FETCH candidates_exist_cur INTO l_dummy;
      IF candidates_exist_cur%NOTFOUND
      THEN l_dummy := NULL;
      END IF;
    CLOSE candidates_exist_cur;

    IF NOT l_dummy IS NULL
    THEN
    FOR l_count in 1..l_worker_count LOOP

    IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Before submit request: ');
    END IF;
       l_request_id := FND_REQUEST.SUBMIT_REQUEST
                            ('CSI',
                             'CSIMCPAW',
                             'Open Interface Parallel Instance Creation Program',
                              NULL,
                              TRUE,
                              p_txn_from_date,       -- Argument1
                              p_txn_to_date,         -- Argument2
                              p_source_system_name,  -- Argument3
                              l_count,               -- Argument4 Worker ID
                              p_resolve_ids);        -- Resolve IDS

     IF(l_debug_level>1) THEN
       FND_File.Put_Line(Fnd_File.LOG,'Calling Open Interface Parallel Instance Creation Process');
       FND_File.Put_Line(Fnd_File.LOG,'Request ID: '||l_request_id||' has been submitted');
       FND_File.Put_Line(Fnd_File.LOG,'');
    END IF;

       IF (l_request_id = 0) THEN
         l_req_count:=l_req_count+1;
         l_errbuf  := FND_MESSAGE.GET;
        IF(l_debug_level>1) THEN
         FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,76,150));
         FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,151,225));
         FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,226,300));
        END IF;
       END IF;
     COMMIT;
     END LOOP;

        IF l_req_count>0
        THEN
          IF(l_debug_level>1) THEN
         fnd_file.put_line(FND_FILE.OUTPUT,'--------------------------------------------------------------------------');
         fnd_file.put_line(FND_FILE.OUTPUT,'                    PARALLEL WORKER SUBMISSION ERROR                      ');
         fnd_file.put_line(FND_FILE.OUTPUT,'--------------------------------------------------------------------------');
         fnd_file.put_line(FND_FILE.OUTPUT,'One or more sub-requests/parallel workers were not submitted successfully.');
         fnd_file.put_line(FND_FILE.OUTPUT,'--------------------------------------------------------------------------');
         END IF;
        END IF;

 IF(l_debug_level>1) THEN
   FND_File.Put_Line(Fnd_File.LOG,'Note : Please check the request "view log" of all the child processors for any un-expected error messages.');
END IF;
        -- All the child requests were successfully requested.
        -- Now I'll put the parent program to sleep/paused state.
        req_data:=to_char(l_old_error);
        fnd_conc_global.set_req_globals (conc_status  => 'PAUSED',
                                         request_data => req_data);
        IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Value of request_data that was passed to fnd_conc_global.set_req_globals is: '||FND_CONC_GLOBAL.request_data);
        END IF;
		errbuf := 'sub-requests submitted';
		retcode := 0;
        return;
    ELSE

         BEGIN
           SELECT COUNT(*)
             INTO l_rel_count
             FROM csi_ii_relation_interface
            WHERE process_status = 'R'
            AND source_system_name = nvl(p_source_system_name,source_system_name) --included for bug5949328;
            AND parallel_worker_id = -1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
             l_rel_count :=0;
          END;

        IF l_rel_count>0
        THEN
          FND_File.Put_Line(Fnd_File.LOG,'l_rel_count <> zero');
          FND_File.Put_Line(Fnd_File.LOG,'Begin - parallel creation of relationships: '||p_worker_count);
          FND_File.Put_Line(Fnd_File.LOG,'p_worker_count: '||p_worker_count);
          IF (p_worker_count IS NULL OR
              p_worker_count > 32)
          THEN
            l_r_worker_count := 32;
          ELSE
            l_r_worker_count := p_worker_count;
          END IF;

          SELECT ceil(count(1)/l_r_worker_count)
            INTO x_r_count
            FROM csi_ii_relation_interface
           WHERE trunc(source_transaction_date) BETWEEN
                 nvl(l_txn_from_date,trunc(source_transaction_date)) AND
                 nvl(l_txn_to_date,trunc(source_transaction_date))
             AND transaction_identifier IS NULL
             AND process_status = 'R'
             AND source_system_name = nvl(p_source_system_name,source_system_name)
             AND parallel_worker_id = -1;

          FOR l_r_count IN 1 .. l_r_worker_count LOOP

             UPDATE csi_ii_relation_interface
                SET parallel_worker_id = l_r_count
              WHERE ROWNUM <= x_r_count
                AND parallel_worker_id = -1
                AND source_system_name = nvl(p_source_system_name,source_system_name)
                AND process_status = 'R';
             COMMIT;
          END LOOP;

       IF(l_debug_level>1) THEN
          FND_File.Put_Line(Fnd_File.LOG,'Before calling csi_ml_util_pvt.resolve_rel_ids');
       END IF;
        -- To resolve id columns
           csi_ml_util_pvt.resolve_rel_ids
           (p_source_system => p_source_system_name
           ,p_txn_from_date => p_txn_from_date
           ,p_txn_to_date   => p_txn_to_date
           ,x_return_status => l_return_status
           ,x_error_message => l_error_message
            );
        IF(l_debug_level>1) THEN
          FND_File.Put_Line(Fnd_File.LOG,'After calling csi_ml_util_pvt.resolve_rel_ids');
        END IF;

           csi_ml_util_pvt.eliminate_dup_records;
           csi_ml_util_pvt.eliminate_dup_subject;
           csi_ml_util_pvt.check_cyclic;

        OPEN relations_exist_cur;
        FETCH relations_exist_cur INTO l_rel_dummy;
             IF relations_exist_cur%NOTFOUND
             THEN
               l_rel_dummy := NULL;
             END IF;
        CLOSE relations_exist_cur;

          IF NOT l_rel_dummy IS NULL
          THEN
           FOR l_count in 1..l_r_worker_count
           LOOP
            IF(l_debug_level>1) THEN
            FND_File.Put_Line(Fnd_File.LOG,'Before submitting request for relationships: ');
            FND_File.Put_Line(Fnd_File.LOG,'Start time in validate mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
            END IF;
            l_request_id := FND_REQUEST.SUBMIT_REQUEST
                            ( 'CSI'
                             ,'CSIMCREL'
                             ,'Open Interface Parallel Relationship Creation Program'
                             ,NULL
                             ,TRUE
                             ,'VALIDATE'
                             ,l_count
                             ,p_txn_from_date
                             ,p_txn_to_date
                             ,p_source_system_name
                             );
            IF(l_debug_level>1) THEN
            FND_File.Put_Line(Fnd_File.LOG,'End time in validate mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
            FND_File.Put_Line(Fnd_File.LOG,'Calling Open Interface Parallel Relationship Creation Process');
            FND_File.Put_Line(Fnd_File.LOG,'Request ID: '||l_request_id||' has been submitted');
            FND_File.Put_Line(Fnd_File.LOG,'');
            END IF;

            IF (l_request_id = 0) THEN
               l_req_count:=l_req_count+1;
               l_errbuf  := FND_MESSAGE.GET;
               IF(l_debug_level>1) THEN
               FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,76,150));
               FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,151,225));
               FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,226,300));
               END IF;
            END IF;
            COMMIT;
           END LOOP;
          END IF;

         req_data:=to_char(l_rel_count);
         fnd_conc_global.set_req_globals (conc_status  => 'PAUSED',
                                          request_data => req_data);
         errbuf := 'sub-requests submitted';
		 retcode := 0;
         RETURN;
        ELSE

        IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'No candidate records in the interface tables: ');
        END IF;
        l_old_error:=0;
        l_new_error:=0;
        errbuf := 'Done!';
		retcode := 0;
         COMMIT;
          RETURN;
        END IF;

    END IF;

ELSE

 IF(l_debug_level>1) THEN
 FND_File.Put_Line(Fnd_File.LOG,'Start time RELATIONSHIP: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
 END IF;
   -- Added for relationship interface
     BEGIN
       SELECT COUNT(*)
         INTO l_rel_count
         FROM csi_ii_relation_interface
        WHERE process_status = 'R'
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328
        -- AND parallel_worker_id = -1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_rel_count :=0;
     END;
      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Value of l_rel_count is: '||l_rel_count);
      END IF;
     BEGIN
       SELECT COUNT(*)
         INTO l_valid_count
         FROM csi_ii_relation_interface
        WHERE process_status = 'V'
         AND source_system_name = nvl(p_source_system_name,source_system_name);	--included for bug5949328
         --AND parallel_worker_id = -1;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_valid_count :=0;
     END;
      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Value of l_valid_count is: '||l_valid_count);
      END IF;
     BEGIN
       SELECT COUNT(*)
         INTO l_update_count
         FROM csi_ii_relation_interface
        WHERE process_status = 'U'
        AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328
       --   AND parallel_worker_id = -1;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_update_count :=0;
     END;

      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Value of l_valid_count is: '||l_valid_count);
      END IF;

     BEGIN
       SELECT COUNT(*)
         INTO l_insert_count
         FROM csi_ii_relation_interface
        WHERE process_status = 'I'
         AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328
          --AND parallel_worker_id = -1;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_insert_count :=0;
     END;
      IF(l_debug_level>1) THEN
      FND_File.Put_Line(Fnd_File.LOG,'Value of l_insert_count is: '||l_insert_count);
      END IF;
 -- End addition for relationship interface
 IF (   l_rel_count    = 0
    AND l_valid_count  = 0
    AND l_update_count = 0
    AND l_insert_count = 0 )
 THEN
    IF(l_debug_level>1) THEN
    FND_File.Put_Line(Fnd_File.LOG,'Values for l_rel_count l_valid_count l_update_count and l_insert_count are zero');
    END IF;

    -- Parent program wakes up after successful completion of child programs.
    l_old_error:=to_number(req_data);
    BEGIN
      SELECT COUNT(*)
      INTO   l_new_error
      FROM   csi_instance_interface
      WHERE  process_status='E'
       AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328

    EXCEPTION
     WHEN OTHERS THEN
         l_new_error:=0;
    END;




    IF l_new_error>l_old_error
    THEN
    -- I found that there were some new errors for the current run.
    --FND_File.Put_Line(Fnd_File.LOG,'Total error records in interface table before submission of program are :'||l_old_error);
    --FND_File.Put_Line(Fnd_File.LOG,'Total error records in interface table after submission of program are  :'||l_new_error);
    IF(l_debug_level>1) THEN
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,'-----------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,'                  OPEN INTERFACE - PARALLEL WORKER ERROR RECORDS                   ');
    fnd_file.put_line(FND_FILE.OUTPUT,'-----------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,to_number(l_new_error-l_old_error)||' records were completed with error. Please check the instance interface table');
    fnd_file.put_line(FND_FILE.OUTPUT,' for detailed error message.');
    fnd_file.put_line(FND_FILE.OUTPUT,'-----------------------------------------------------------------------------------');
    END IF;
      l_old_error:=0;
      l_new_error:=0;
    ELSE
      l_old_error:=0;
      l_new_error:=0;
    END IF;

     errbuf := 'Done!';
     retcode := 0;

       COMMIT;
        RETURN;
 ELSE
-- ******************************************************************
-- Start relationship creation
   IF l_rel_count <> 0
   THEN
     IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'l_rel_count <> zero');
     FND_File.Put_Line(Fnd_File.LOG,'Begin - parallel creation of relationships: '||p_worker_count);
     FND_File.Put_Line(Fnd_File.LOG,'p_worker_count: '||p_worker_count);
     END IF;

       IF (p_worker_count IS NULL OR
           p_worker_count > 32)
       THEN
         l_r_worker_count := 32;
       ELSE
         l_r_worker_count := p_worker_count;
       END IF;

      FND_File.Put_Line(Fnd_File.LOG,'source' || p_source_system_name);

      SELECT ceil(count(1)/l_r_worker_count)
        INTO x_r_count
        FROM csi_ii_relation_interface
       WHERE trunc(source_transaction_date) BETWEEN
             nvl(l_txn_from_date,trunc(source_transaction_date)) AND
             nvl(l_txn_to_date,trunc(source_transaction_date))
        AND transaction_identifier IS NULL
        AND process_status = 'R'
        AND source_system_name = nvl(p_source_system_name,source_system_name)
        AND parallel_worker_id = -1;

      FND_File.Put_Line(Fnd_File.LOG,'xrcount' || x_r_count);
      FND_File.Put_Line(Fnd_File.LOG,'wkcount' || l_r_worker_count);


      FOR l_r_count in 1 .. l_r_worker_count
      LOOP

        FND_File.Put_Line(Fnd_File.LOG,'updating CIRI');
        UPDATE csi_ii_relation_interface
           SET parallel_worker_id = l_r_count
         WHERE ROWNUM <= x_r_count
           AND parallel_worker_id = -1
           AND source_system_name = nvl(p_source_system_name,source_system_name)
           AND process_status = 'R';
        COMMIT;
      END LOOP;

    IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'Before calling csi_ml_util_pvt.resolve_rel_ids');
    END IF;
    -- To resolve id columns
           csi_ml_util_pvt.resolve_rel_ids
           (p_source_system => p_source_system_name
           ,p_txn_from_date => p_txn_from_date
           ,p_txn_to_date   => p_txn_to_date
           ,x_return_status => l_return_status
           ,x_error_message => l_error_message
            );
     IF(l_debug_level>1) THEN
     FND_File.Put_Line(Fnd_File.LOG,'After calling csi_ml_util_pvt.resolve_rel_ids');
     END IF;

     csi_ml_util_pvt.eliminate_dup_records;
     csi_ml_util_pvt.eliminate_dup_subject;
     csi_ml_util_pvt.check_cyclic;

      OPEN relations_exist_cur;
      FETCH relations_exist_cur INTO l_rel_dummy;
        IF relations_exist_cur%NOTFOUND
        THEN l_rel_dummy := NULL;
        END IF;
      CLOSE relations_exist_cur;

      IF NOT l_rel_dummy IS NULL
      THEN
       FOR l_count in 1..l_r_worker_count
       LOOP
       IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Before submitting request for relationships: ');
        FND_File.Put_Line(Fnd_File.LOG,'Start time in validate mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
       END IF;
        l_request_id := FND_REQUEST.SUBMIT_REQUEST
                        ( 'CSI'
                         ,'CSIMCREL'
                         ,'Open Interface Parallel Relationship Creation Program'
                         ,NULL
                         ,TRUE
                         ,'VALIDATE'
                         ,l_count
                         ,p_txn_from_date
                         ,p_txn_to_date
                         ,p_source_system_name
                         );
        IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'End time in validate mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
        FND_File.Put_Line(Fnd_File.LOG,'Calling Open Interface Parallel Relationship Creation Process');
        FND_File.Put_Line(Fnd_File.LOG,'Request ID: '||l_request_id||' has been submitted');
        FND_File.Put_Line(Fnd_File.LOG,'');
        END IF;

         IF (l_request_id = 0) THEN
             l_req_count:=l_req_count+1;
             l_errbuf  := FND_MESSAGE.GET;
             IF(l_debug_level>1) THEN
             FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,76,150));
             FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,151,225));
             FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,226,300));
             END IF;
         END IF;
          COMMIT;
       END LOOP;
      END IF;

        req_data:=to_char(l_rel_count);
        fnd_conc_global.set_req_globals (conc_status  => 'PAUSED',
                                         request_data => req_data);
        errbuf := 'sub-requests submitted';
		retcode := 0;
        RETURN;
   ELSIF l_valid_count <> 0
   THEN
       SELECT COUNT(DISTINCT(parallel_worker_id))
         INTO l_r_worker_count
         FROM csi_ii_relation_interface
        WHERE process_status='V'
         AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328

      FOR l_count IN 1..l_r_worker_count
      LOOP
       IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Before submit request for l_valid_count <> 0: ');
        FND_File.Put_Line(Fnd_File.LOG,'Start time in update mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
       END IF;
          l_request_id := FND_REQUEST.SUBMIT_REQUEST
                            ( 'CSI'
                             ,'CSIMCREL'
                             ,'Open Interface Parallel Relationship Creation Program'
                             ,NULL
                             ,TRUE
                             ,'UPDATE'
                             ,l_count
                             ,p_txn_from_date
                             ,p_txn_to_date
                             ,p_source_system_name
                             );
        IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'End time in update mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
        FND_File.Put_Line(Fnd_File.LOG,'Calling Open Interface Parallel Relationship Creation Process');
        FND_File.Put_Line(Fnd_File.LOG,'Request ID: '||l_request_id||' has been submitted');
        FND_File.Put_Line(Fnd_File.LOG,'');
        END IF;

        IF (l_request_id = 0) THEN
            l_req_count:=l_req_count+1;
            l_errbuf  := FND_MESSAGE.GET;
            IF(l_debug_level>1) THEN
            FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,76,150));
            FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,151,225));
            FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,226,300));
            END IF;
        END IF;
       COMMIT;
      END LOOP;
         req_data:=to_char(l_valid_count);
         fnd_conc_global.set_req_globals (conc_status  => 'PAUSED',
                                          request_data => req_data);
         errbuf := 'sub-requests submitted';
		 retcode := 0;
         RETURN;

   ELSIF l_update_count <> 0
   THEN
       SELECT COUNT(DISTINCT(parallel_worker_id))
         INTO l_r_worker_count
         FROM csi_ii_relation_interface
        WHERE process_status='U'
         AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328;


      FOR l_count IN 1..l_r_worker_count
      LOOP
      IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Before submit request for l_update_count <> 0: ');
        FND_File.Put_Line(Fnd_File.LOG,'Start time in update mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
      END IF;
         l_request_id := FND_REQUEST.SUBMIT_REQUEST
                         ( 'CSI'
                          ,'CSIMCREL'
                          ,'Open Interface Parallel Relationship Creation Program'
                          ,NULL
                          ,TRUE
                          ,'RE-UPDATE'
                          ,l_count
                          ,p_txn_from_date
                          ,p_txn_to_date
                          ,p_source_system_name
                          );
        IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'End time in update mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
        FND_File.Put_Line(Fnd_File.LOG,'Calling Open Interface Parallel Relationship Creation Process');
        FND_File.Put_Line(Fnd_File.LOG,'Request ID: '||l_request_id||' has been submitted');
        FND_File.Put_Line(Fnd_File.LOG,'');
        END IF;

         IF (l_request_id = 0) THEN
           l_req_count:=l_req_count+1;
           l_errbuf  := FND_MESSAGE.GET;
           IF(l_debug_level>1) THEN
           FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,76,150));
           FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,151,225));
           FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,226,300));
           END IF;
         END IF;
        COMMIT;
      END LOOP;
        req_data:=to_char(l_update_count);
        fnd_conc_global.set_req_globals (conc_status  => 'PAUSED',
                                         request_data => req_data);
        errbuf := 'sub-requests submitted';
		retcode := 0;
        RETURN;

   ELSIF l_insert_count <> 0
   THEN
        SELECT COUNT(DISTINCT(parallel_worker_id))
          INTO l_r_worker_count
          FROM csi_ii_relation_interface
         WHERE process_status='I'
         AND source_system_name = nvl(p_source_system_name,source_system_name); --included for bug5949328;


      FOR l_count in 1..l_r_worker_count
      LOOP
      IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'Before submit request for l_insert_count <> 0: ');
        FND_File.Put_Line(Fnd_File.LOG,'Start time in insert mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
      END IF;
         l_request_id := FND_REQUEST.SUBMIT_REQUEST
                           ( 'CSI'
                            ,'CSIMCREL'
                            ,'Open Interface Parallel Relationship Creation Program'
                            ,NULL
                            ,TRUE
                            ,'INSERT'
                            ,l_count
                            ,p_txn_from_date
                            ,p_txn_to_date
                            ,p_source_system_name
                            );
        IF(l_debug_level>1) THEN
        FND_File.Put_Line(Fnd_File.LOG,'End time in insert mode: '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
        FND_File.Put_Line(Fnd_File.LOG,'Calling Open Interface Parallel Relationship Creation Process');
        FND_File.Put_Line(Fnd_File.LOG,'Request ID: '||l_request_id||' has been submitted');
        FND_File.Put_Line(Fnd_File.LOG,'');
        END IF;

         IF (l_request_id = 0) THEN
           l_req_count:=l_req_count+1;
           l_errbuf  := FND_MESSAGE.GET;
           IF(l_debug_level>1) THEN
           FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,76,150));
           FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,151,225));
           FND_File.Put_Line(Fnd_File.LOG,' :'||substr(l_errbuf,226,300));
           END IF;
         END IF;
       COMMIT;
      END LOOP;
        req_data:=to_char(l_insert_count);
        fnd_conc_global.set_req_globals (conc_status  => 'PAUSED',
                                         request_data => req_data);
        errbuf := 'sub-requests submitted';
		retcode := 0;
        RETURN;
  END IF; -- l_rel_count <> 0

 END IF;
-- End relationship creation
-- ******************************************************************
     errbuf := 'Done!';
     retcode := 0;
     COMMIT;
     RETURN;


END IF;


    EXCEPTION

     WHEN others THEN
     FND_File.Put_Line(Fnd_File.LOG,'csi_ml_program_pub.execute_parallel_create -Into when others exception ' || SQLERRM);
       l_sql_error := SQLERRM;
       fnd_message.set_name('CSI','CSI_ML_UNEXP_SQL_ERROR');
       fnd_message.set_token('API_NAME',l_api_name);
       fnd_message.set_token('SQL_ERROR',SQLERRM);


END execute_parallel_create;

END CSI_ML_PROGRAM_PUB;

/
