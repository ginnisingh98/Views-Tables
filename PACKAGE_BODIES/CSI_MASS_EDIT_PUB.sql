--------------------------------------------------------
--  DDL for Package Body CSI_MASS_EDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_MASS_EDIT_PUB" as
/* $Header: csipmeeb.pls 120.17.12010000.6 2009/12/08 13:13:17 sjawaji ship $ */
-- Start of Comments
-- Package name     : CSI_MASS_EDIT_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSI_MASS_EDIT_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipmeeb.pls';

/* local routine to wrap the gen utility debug stuff */

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    FND_FILE.PUT_LINE (FND_FILE.LOG, p_message );
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE debug_out(
    p_message IN varchar2)
  IS
  BEGIN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, p_message );
  END debug_out;



  PROCEDURE conc_report (
    p_temp_merror_tbl          IN  CSI_MASS_EDIT_PUB.Mass_Upd_Rep_Error_Tbl,
    p_name                     IN  VARCHAR2,
    p_batch_id                 IN  NUMBER,
    p_batch_name               IN  VARCHAR2
    ) IS
   l_temp_merror_tbl           csi_mass_edit_pub.Mass_Upd_Rep_Error_Tbl;
   l_repo_merror_tbl           csi_mass_edit_pub.Mass_Upd_Rep_Error_Tbl;
   l_rep_instance_id           NUMBER;
   l_rep_txn_line_id           NUMBER;

  BEGIN
    -- Sorting the error table based on the Instance_Id
    l_temp_merror_tbl.delete;
    l_temp_merror_tbl := p_temp_merror_tbl;
    IF p_temp_merror_tbl.COUNT > 0 THEN
    For i in l_temp_merror_tbl.FIRST .. l_temp_merror_tbl.LAST
    LOOP
      If l_temp_merror_tbl.exists(i)
      Then
        l_repo_merror_tbl(l_repo_merror_tbl.count + 1) := l_temp_merror_tbl(i);
        l_rep_instance_id := l_temp_merror_tbl(i).Instance_Id;
        -- l_rep_txn_line_id := l_temp_merror_tbl(i).txn_line_detail_id;
        l_temp_merror_tbl.DELETE(i);
        If l_temp_merror_tbl.count > 0
        Then
          For j in l_temp_merror_tbl.FIRST .. l_temp_merror_tbl.LAST
          Loop
            If l_temp_merror_tbl.EXISTS(j)
            Then
              If l_temp_merror_tbl(j).INSTANCE_ID        = l_rep_instance_id
                -- AND
                -- l_temp_merror_tbl(j).txn_line_detail_id = l_rep_txn_line_id
              Then
                 l_repo_merror_tbl(l_repo_merror_tbl.count + 1) := l_temp_merror_tbl(j);
                 l_temp_merror_tbl.DELETE(j);
              End If;
            End If;
          End Loop;
        End If;
      End If;
    End Loop;
   END IF; -- IF p_temp_merror_tbl.COUNT > 0 THEN
    If l_repo_merror_tbl.count > 0
    Then
      /*
      -- Log File
      debug(' ');
      debug('************************ Begin  Report for Batch ('||P_BATCH_NAME||')  ************************');
      debug(' ');
      debug('Instance  Error Code  Error Message');
      debug('--------  ----------  -------------');
      For i in l_repo_merror_tbl.FIRST .. l_repo_merror_tbl.LAST
      LOOP
        debug(rpad(to_char(l_repo_merror_tbl(i).instance_id),10,' ')||rpad(l_repo_merror_tbl(i).error_code,12,' ')||substr(l_repo_merror_tbl(i).error_message,1,length(l_repo_merror_tbl(i).error_message)));
      ENd Loop;
      debug(' ');
      debug('************************ End Of Report for Batch ('||P_BATCH_NAME||')  ************************');
      debug(' ');
      */
      Debug(' ');
      Debug('Mass Edit Batch Status : FAILED');
      Debug(' ');

      -- Out File
      Debug_out(' ');
      Debug_out('Mass Edit Batch Status : FAILED');
      Debug_out(' ');
      debug_out(' ');
      debug_out('************************ Begin  Report for Batch ('||P_BATCH_NAME||')  ************************');
      debug_out(' ');
      Debug_out('Instance/s in this batch completed with the following error.');
      For i in l_repo_merror_tbl.FIRST .. l_repo_merror_tbl.FIRST
      LOOP
      Debug_out('Error message: '||substr(l_repo_merror_tbl(i).error_message,1,length(l_repo_merror_tbl(i).error_message)));
      end loop;
      Debug_out(' ');
      /* -- Commented for bug 5167944
      debug_out('Instance  Error Code  Error Message');
      debug_out('--------  ----------  -------------');
      For i in l_repo_merror_tbl.FIRST .. l_repo_merror_tbl.LAST
      LOOP
        debug_out(rpad(to_char(l_repo_merror_tbl(i).instance_id),10,' ')||rpad(l_repo_merror_tbl(i).error_code,12,' ')||substr(l_repo_merror_tbl(i).error_message,1,length(l_repo_merror_tbl(i).error_message)));
      ENd Loop;
      debug_out(' ');
      */
      debug_out('************************ End Of Report for Batch ('||P_BATCH_NAME||')  ************************');
      debug_out(' ');

    End If;

  End conc_report;


PROCEDURE update_error_status (
    p_error_tbl             IN   csi_mass_edit_pub.Mass_Upd_Rep_Error_Tbl,
    p_txn_line_id           IN   NUMBER,
    p_entry_id              IN   NUMBER
   ) is
l_instance_id    NUMBER;
l_error_flag     VARCHAR2(1) := 'N';
PRAGMA AUTONOMOUS_TRANSACTION;
Begin

  -- Updating Batch status
  UPDATE csi_mass_edit_entries_b
  SET    status_code = 'FAILED'
  WHERE  entry_id    = p_entry_id;

  -- Updating status for each failed transaction_line_detail_id with instance
  IF p_error_tbl.COUNT > 0 THEN
  FOR j in p_error_tbl.FIRST .. p_error_tbl.LAST
  LOOP
    -- UPDATE csi_t_txn_line_details
    -- SET    error_explanation   = p_grp_error_tbl(j).Error_Message,
    --        processing_status   = 'ERROR',
    --        error_code          = 'E'
    -- WHERE  transaction_line_id = p_txn_line_id
    -- AND    instance_id         = p_grp_error_tbl(j).Instance_ID;
    If l_instance_id is null
    Then
      l_instance_id := p_error_tbl(j).instance_id;
    End If;

    If l_instance_id = p_error_tbl(j).instance_id
    Then
      If  p_error_tbl(j).ERROR_CODE in ('E','U')
      Then
         l_error_flag := 'E';
      ElsIf p_error_tbl(j).ERROR_CODE = 'W'
           AND
            l_error_flag <> 'E'
      Then
           l_error_flag := 'W';
      End If;
    End If;

    If l_instance_id <> p_error_tbl(j).instance_id
    Then
      If l_error_flag = 'E'
      Then
         UPDATE csi_t_txn_line_details
         SET    processing_status   = 'ERROR',
                ERROR_CODE          = 'E'
         WHERE  transaction_line_id = p_txn_line_id
         AND    instance_id         = l_instance_id;
      Else
         UPDATE csi_t_txn_line_details
         SET    processing_status   = 'WARNING',
                ERROR_CODE          = 'W'
         WHERE  transaction_line_id = p_txn_line_id
         AND    instance_id         = l_instance_id;
      End If;
      l_error_flag := 'N';
      If  p_error_tbl(j).ERROR_CODE in ('E','U')
      Then
         l_error_flag := 'E';
      ElsIf p_error_tbl(j).ERROR_CODE = 'W'
      Then
         l_error_flag := 'W';
      End If;
      l_instance_id := p_error_tbl(j).instance_id;
    End If;
  END LOOP;
  END IF; -- IF p_error_tbl.COUNT > 0 THEN

  Commit;

End update_error_status;

PROCEDURE UPDATE_MUSYS_ERR_STATUS (
    p_entry_id              IN   NUMBER
   ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  -- Updating Batch status
  UPDATE csi_mass_edit_entries_b
  SET    status_code = 'FAILED'
  WHERE  entry_id    = p_entry_id;

COMMIT;

END UPDATE_MUSYS_ERR_STATUS;

PROCEDURE validate_loc_pty
( p_instance_id     IN      NUMBER  ,
  p_txn_line_id     IN      NUMBER  ,
  x_return_status   OUT NOCOPY     VARCHAR2
 ) IS

CURSOR core_csr (p_instance_id IN NUMBER) IS
SELECT cii.location_id                location_id
      ,cii.location_type_code         location_type_code
      ,cii.install_location_id        install_location_id
      ,cii.install_location_type_code install_location_type_code
      ,cip.party_id                   party_id
      ,cip.party_source_table         party_source_table
FROM  csi_item_instances cii
     ,csi_i_parties      cip
WHERE cii.instance_id = p_instance_id
AND   cip.instance_id = cii.instance_id
AND   cip.relationship_type_code = 'OWNER';

CURSOR source_csr (p_txn_line_id IN NUMBER,p_instance_id IN NUMBER) IS
SELECT cil.location_id                 location_id
       ,cil.location_type_code         location_type_code
       ,cil.install_location_id        install_location_id
       ,cil.install_location_type_code install_location_type_code
       ,cid.party_source_id            party_id
       ,cid.party_source_table         party_source_table
FROM  csi_t_txn_line_details cil
     ,csi_t_party_details    cid
WHERE cil.transaction_line_id = p_txn_line_id
AND   cil.instance_id         = p_instance_id
AND   cid.txn_line_detail_id  = cil.txn_line_detail_id
AND   cid.relationship_type_code = 'OWNER';

l_core_csr      core_csr%ROWTYPE;
l_source_csr    source_csr%ROWTYPE;

BEGIN

OPEN   core_csr (p_instance_id);
FETCH  core_csr INTO l_core_csr;
CLOSE  core_csr;

OPEN   source_csr (p_txn_line_id,p_instance_id);
FETCH  source_csr INTO l_source_csr;
CLOSE  source_csr;

  IF    NVL(l_core_csr.location_id,-1) <> NVL(l_source_csr.location_id,-1)
    OR NVL(l_core_csr.location_type_code,'#@*') <> NVL(l_source_csr.location_type_code,'#@*')
    OR NVL(l_core_csr.install_location_id,-1) <> NVL(l_source_csr.install_location_id,-1) --third addition
    OR NVL(l_core_csr.install_location_type_code,'#@*') <> NVL(l_source_csr.install_location_type_code,'#@*')
    OR l_core_csr.party_id <> l_source_csr.party_id
    OR l_core_csr.party_source_table <> l_source_csr.party_source_table
  THEN
    x_return_status:='F';
  END IF;
  x_return_status:='T';
EXCEPTION
  WHEN OTHERS THEN
  x_return_status:='F';
END;

/* ---------------------------------------------------------------- */
-- Procedure Initiate_Mass_Edit is registered as concurrent program
-- This program fires periodically at the specified time interval
-- and kicks of the Process_mass_edit_batch(Another concurrent process)
-- whenever it finds records with status SCHEDULED.
/* ---------------------------------------------------------------- */
PROCEDURE Initiate_Mass_Edit
   (
     errbuf                       OUT NOCOPY    VARCHAR2
    ,retcode                      OUT NOCOPY    NUMBER
    ,p_entry_id                   IN  NUMBER
    )
 IS
l_api_name                   CONSTANT VARCHAR2(30) := 'Initiate_Mass_Edit';
l_api_version                CONSTANT NUMBER       := 1.0;
l_return_status_full                  VARCHAR2(1);
l_access_flag                         VARCHAR2(1);
l_line_count                          NUMBER;
l_debug_level                         NUMBER;
l_entry_id                            NUMBER       := 0;
l_request_id                          NUMBER     ;
l_errbuf                              VARCHAR2(2000);
l_mass_edit_tbl                       csi_mass_edit_pub.mass_edit_tbl;
i                                     NUMBER;
--l_txn_rec                             csi_datastructures_pub.transaction_rec;
l_count                               NUMBER;
l_warning                             NUMBER := 0;
l_error                               NUMBER := 0;
l_success                             NUMBER := 0;
l_temp                                BOOLEAN;

CURSOR mass_edit_csr(p_entry_id in NUMBER) IS
    SELECT entry_id
    FROM   csi_mass_edit_entries_vl
    WHERE  status_code = 'SCHEDULED'
    AND    schedule_date <= SYSDATE
    AND    entry_id = nvl(p_entry_id,entry_id);

 BEGIN

      debug(' ');
      debug( 'Initiate Mass Edit Concurrent Process');
      debug(' ');

      debug_out(' ');
      debug_out( 'Initiate Mass Edit Concurrent Program');
      debug_out(' ');

      BEGIN
        i:=0;
        FOR l_mass_edit_csr IN mass_edit_csr(p_entry_id)
        LOOP
          i:=i+1;
          l_mass_edit_tbl(i).entry_id := l_mass_edit_csr.entry_id;
        END LOOP;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
      END;
      l_count:=l_mass_edit_tbl.count;


      IF l_count > 0
      THEN
        FOR call_csr IN 1..l_count
        LOOP
          Process_mass_edit_batch(errbuf,retcode,l_mass_edit_tbl(call_csr).entry_id);
          /*
          l_request_id := FND_REQUEST.SUBMIT_REQUEST('CSI', 'CSIMEDT', 'Mass Edit Concurrent program ' , NULL, FALSE, l_mass_edit_tbl(call_csr).entry_id);--, l_txn_rec);

          debug('Calling Process Mass Edit Batch Concurrent Process');
          debug('');
          debug('Submitting with Parameters');
          debug('Batch Id        : '|| l_mass_edit_tbl(call_csr).entry_id);
          debug('');
          IF (l_request_id = 0) THEN
            l_errbuf  := FND_MESSAGE.GET;
            debug('Call to Process Mass Edit Batch Concurrent Process has errored');
            debug('For Batch Id'||l_mass_edit_tbl(call_csr).entry_id);
            debug('Error message   :'||substr(l_errbuf,1,75));
            debug('                :'||substr(l_errbuf,76,150));
            debug('                :'||substr(l_errbuf,151,225));
            debug('                :'||substr(l_errbuf,226,300));
          END IF;
          */
          If errbuf = 'W'
          Then
            l_warning := l_warning + 1;
          Elsif errbuf = 'E'
          Then
            l_error    := l_error + 1;
          Else
            l_success  := l_success + 1;
          End If;
        END LOOP;

        If l_error > 0
        Then
          l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        ElsIf l_warning > 0
        Then
         l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','');
        End If;

      ELSE
         debug(' ');
         debug('Unable to find any records to call Process Mass Edit Batch Concurrent Process ');
         debug(' ');
      END IF;

      --
      -- End of API body
      --

EXCEPTION
 WHEN OTHERS THEN
    debug('When others exception from Initiate_Mass_Edit');
END Initiate_Mass_Edit;

/* ------------------------------------------------------------------- */
-- Procedure Process_mass_edit_batch is registered as concurrent program
-- This program gets initiated by initiate_mass_edit concurren program.
/* ------------------------------------------------------------------- */
PROCEDURE Process_mass_edit_batch
   ( errbuf                       OUT NOCOPY    VARCHAR2
    ,retcode                      OUT NOCOPY    NUMBER
    ,p_Entry_id                   IN     NUMBER
   ) IS

  -- Cursors
  CURSOR selected_instance_csr (p_txn_line_id IN NUMBER) IS
   SELECT ctld.instance_id
         ,ctld.transaction_line_id
         ,nvl(ctld.location_id, FND_API.G_MISS_NUM) location_id
         ,nvl(ctld.location_type_code, FND_API.G_MISS_CHAR) location_type_code
         ,nvl(ctld.install_location_id, FND_API.G_MISS_NUM) install_location_id
         ,nvl(ctld.install_location_type_code, FND_API.G_MISS_CHAR) install_location_type_code
         ,cii.object_version_number
         ,cii.instance_usage_code
   FROM   csi_t_txn_line_details ctld,
          csi_item_instances cii
   WHERE  ctld.transaction_line_id = p_txn_line_id
   AND    ctld.INSTANCE_ID is not null
   AND    ctld.preserve_detail_flag = 'Y'
   AND    cii.instance_id = ctld.instance_id;

  CURSOR core_inst_pty_acct_csr (p_txn_line_id IN NUMBER) IS
    SELECT cip.instance_party_id          pty_instance_party_id,
           cip.instance_id                pty_instance_id,
           cip.party_source_table         pty_party_source_table,
           cip.party_id                   pty_party_id,
           cip.relationship_type_code     pty_rel_type_code,
           cip.object_version_number      pty_obj_version_number
          ,cia.ip_account_id              pty_acc_ip_account_id,
           cia.instance_party_id          pty_acc_instance_party_id,
           cia.party_account_id           pty_acc_party_account_id,
           cia.relationship_type_code     pty_acct_rel_type_code,
           cia.object_version_number      pty_acct_obj_version_number
    FROM   csi_i_parties cip,
           csi_ip_accounts cia,
           csi_t_txn_line_details ctld
    WHERE  cip.instance_id            = ctld.instance_id
    AND    cip.contact_flag           ='N'
    AND    cip.relationship_type_code = 'OWNER'
    AND    ctld.transaction_line_id   = p_txn_line_id
    AND    ctld.instance_exists_flag  = 'Y'
    AND    ctld.preserve_detail_flag  = 'Y'
    AND    cia.instance_party_id      = cip.instance_party_id
    AND    cia.relationship_type_code = 'OWNER'

    UNION
    SELECT cip.instance_party_id          pty_instance_party_id,
           cip.instance_id                pty_instance_id,
           cip.party_source_table         pty_party_source_table,
           cip.party_id                   pty_party_id,
           cip.relationship_type_code     pty_rel_type_code,
           cip.object_version_number      pty_obj_version_number,
           null              			  pty_acc_ip_account_id,
           null              			  pty_acc_instance_party_id,
           null              			  pty_acc_party_account_id,
           null              			  pty_acct_rel_type_code,
           null              			  pty_acct_obj_version_number
    FROM   csi_i_parties cip,
           csi_t_txn_line_details ctld
    WHERE  cip.instance_id            = ctld.instance_id
    AND    cip.contact_flag           ='N'
    AND    cip.relationship_type_code = 'OWNER'
    AND    ctld.transaction_line_id   = p_txn_line_id
    AND    ctld.instance_exists_flag  = 'Y'
    AND    ctld.preserve_detail_flag  = 'Y'
	AND    cip.party_id in (SELECT INTERNAL_PARTY_ID FROM csi_install_parameters)
	AND    NOT EXISTS (SELECT 'X' FROM csi_i_parties cip, csi_ip_accounts cia
						WHERE cip.INSTANCE_PARTY_ID = cia.INSTANCE_PARTY_ID
						AND   cip.instance_id = ctld.instance_id
			            AND   cip.contact_flag           = 'N'
			            AND   cip.relationship_type_code = 'OWNER');

  CURSOR curr_asso_csr (p_instance_id IN NUMBER) IS
    SELECT cip.instance_party_id          pty_instance_party_id,
           cip.instance_id                pty_instance_id,
           cip.party_source_table         pty_party_source_table,
           cip.party_id                   pty_party_id,
           cip.relationship_type_code     pty_rel_type_code,
           cip.object_version_number      pty_obj_version_number
    FROM   csi_i_parties cip
    WHERE  cip.instance_id            = p_instance_id
    AND    cip.contact_flag           = 'N'
    AND    nvl(cip.active_end_date,sysdate) >= sysdate;

  CURSOR core_iea_val_csr (p_txn_line_id IN NUMBER) IS
    SELECT ciev.attribute_value_id
          ,ciev.attribute_id
          ,ctld.instance_id  --  Bug 7613909
          ,ciev.attribute_value
          ,ciev.object_version_number
    FROM   csi_iea_values ciev,
           csi_t_txn_line_details ctld
    WHERE  ciev.instance_id (+)     = ctld.instance_id   --  Bug 7613909
    AND    ctld.transaction_line_id = p_txn_line_id
    AND    ctld.instance_id is not null;
   -- Local Variables
   l_txn_rec                         csi_datastructures_pub.transaction_rec;

   -- Variables for Dummy record details
   d_txn_line_query_rec        csi_t_datastructures_grp.txn_line_query_rec;
   d_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec;
   d_line_dtl_tbl              csi_t_datastructures_grp.txn_line_detail_tbl;
   d_pty_dtl_tbl               csi_t_datastructures_grp.txn_party_detail_tbl;
   d_pty_acct_tbl              csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
   d_ii_rltns_tbl              csi_t_datastructures_grp.txn_ii_rltns_tbl;
   d_org_assgn_tbl             csi_t_datastructures_grp.txn_org_assgn_tbl;
   d_ext_attrib_tbl            csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
   d_csi_ea_tbl                csi_t_datastructures_grp.csi_ext_attribs_tbl;
   d_csi_eav_tbl               csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
   d_txn_systems_tbl           csi_t_datastructures_grp.txn_systems_tbl;
   l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(2000);

   -- New Tables for the selected instances in the batch
   n_instance_tbl              csi_datastructures_pub.instance_tbl;
   n_party_tbl                 csi_datastructures_pub.party_tbl;
   n_party_account_tbl         csi_datastructures_pub.party_account_tbl;
   n_ext_attrib_values_tbl     csi_datastructures_pub.extend_attrib_values_tbl;
   n_price_tbl                 csi_datastructures_pub.pricing_attribs_tbl;
   n_org_assignments_tbl       csi_datastructures_pub.organization_units_tbl;
   n_asset_assignment_tbl      csi_datastructures_pub.instance_asset_tbl;
   n_txn_rec                   csi_datastructures_pub.transaction_rec;
   n_rel_txn_rec               csi_datastructures_pub.transaction_rec;
   n_grp_error_tbl             csi_datastructures_pub.grp_upd_error_tbl;
   n_instance_id_lst           csi_datastructures_pub.id_tbl;

   l_api_version               NUMBER:=1.0;
   l_commit                    VARCHAR2(1) ;
   l_msg_index                 NUMBER;
   l_error_message             VARCHAR2(2000);
   l_warning_message           VARCHAR2(2000);
   l_errbuf                    VARCHAR2(2000);
   n_inst_ind                  NUMBER := 0;
   l_parent_tbl_index          NUMBER := 0;
   l_pty_index                 NUMBER := 0;
   l_acct_index                NUMBER := 0;
   l_cont_index                number := 0;
   l_ext_attr_ind              NUMBER := 0;

   -- NEW OWNER Party variables
   l_pty_src_table             VARCHAR2(80);
   l_pty_party_id              NUMBER;
   l_pty_rel_typ               VARCHAR2(80);
   -- Assoc to expire
   l_assoc_src_table           VARCHAR2(80);
   l_assoc_party_id            NUMBER;
   l_assoc_rel_typ             VARCHAR2(80);
   l_assoc_end_date            DATE;
   -- NEW OWNER Account variables
   l_pry_account_id            NUMBER;
   l_acct_rel_typ              VARCHAR2(80);
   l_acct_bill_to              NUMBER;
   l_acct_ship_to              NUMBER;
   l_party_detail_id           NUMBER;
   l_pty_tbl_ind               NUMBER := 0;


   l_debug_level               NUMBER;
   l_status                    VARCHAR2(1) :='N';
   l_txn_line_id               NUMBER;
   l_instance_id               NUMBER;
   l_batch_type                VARCHAR2(30);
   l_found_batch               VARCHAR2(30);
   l_conc_status               BOOLEAN;

   l_medit_error_tbl           csi_mass_edit_pub.mass_edit_error_tbl;
   l_temp_merror_tbl           csi_mass_edit_pub.Mass_Upd_Rep_Error_Tbl;
   l_repo_merror_tbl           csi_mass_edit_pub.Mass_Upd_Rep_Error_Tbl;
   l_rep_instance_id           NUMBER;
   l_rep_txn_line_id           NUMBER;
   l_found_error               VARCHAR2(1) := 'N';

   px_medit_rec                csi_mass_edit_pub.mass_edit_rec;

   l_note_id                   NUMBER;
   l_batch_desc                VARCHAR2(2000);
   l_name                      VARCHAR2(50);
   l_batch_meaning             VARCHAR2(50);
   l_batch_sch_date            DATE;
   l_jtf_error                 VARCHAR2(1) := 'N';
   l_jtf_err_ind               NUMBER := 0;
   l_grp_api_ind               NUMBER := 0;

   l_system_cascade            VARCHAR2(1) := 'N'; -- ER 6031179
   l_perform_system_mu         VARCHAR2(1) := 'N';
   l_new_owner                 VARCHAR2(1);
   l_old_owner                 VARCHAR2(1);
   l_ext_attrib_exists         BOOLEAN;     -- Bug 8495187


BEGIN
  l_debug_level:=fnd_profile.value('DEBUG_LEVEL');

    debug(' Processing .... ');
    debug(' ');

  -- Checking for Batch Status
  BEGIN
    SELECT  a.txn_line_id,
            a.batch_type,
            b.meaning,
            a.description,
            a.name,
            a.schedule_date,
            a.system_cascade
    INTO    l_txn_line_id,
            l_batch_type,
            l_batch_meaning,
            l_batch_desc,
            l_name,
            l_batch_sch_date,
            l_system_cascade
    FROM    csi_mass_edit_entries_vl a,
            csi_lookups b
    WHERE   a.entry_id       = p_entry_id
    AND     a.status_code    = 'SCHEDULED'
    AND     a.schedule_date <= SYSDATE
    AND     b.lookup_type    = 'CSI_IB_TXN_TYPE_CODE'
    AND     b.lookup_code    = a.batch_type;

    l_status := 'Y';
    debug('Found data for mass edit processing...  ');
    debug(' ');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('No data for processing Mass Edit...  ');
      debug('Aborting Concurrent Program');
      debug(' ');
      errbuf := 'E';
    WHEN OTHERS THEN
      debug('When others exception from Mass Edit Entry processing query..'||to_char(sqlcode)||'-'||substr(sqlerrm, 1, 255));
      raise fnd_api.g_exc_error;
  END;

  debug(' Processing Mass Edit Batch :'||l_name);
  debug('                Batch Id    : '||p_entry_id);
  debug('                Batch Type  : '||l_batch_meaning);
  debug(' ');

  debug_out(' ');
  debug_out(' ');
  debug_out('Processing Mass Edit Batch : '||l_name);
  debug_out('               Batch Id    : '||p_entry_id);
  debug_out('               Batch Type  : '||l_batch_meaning);
  debug_out(' ');


  -- Building Transaction rec
  n_txn_rec.transaction_type_id     := 3;
  --n_txn_rec.source_transaction_date := SYSDATE;
  n_txn_rec.source_transaction_date := l_batch_sch_date;
  n_txn_rec.transaction_date := SYSDATE;
  n_txn_rec.SOURCE_HEADER_REF_ID    := p_entry_id;
  n_txn_rec.SOURCE_GROUP_REF        := l_batch_type;

  -- Batch Type Validation
  BEGIN
    SELECT ib_txn_type_code
    INTO   l_found_batch
    FROM   csi_txn_sub_types
    WHERE  transaction_type_id = 3
    AND    ib_txn_type_code    = l_batch_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('Batch Type is not set for processing Mass Edit...  ');
      debug('Aborting Concurrent Program');
      errbuf := 'E';
      debug(' ');
    WHEN OTHERS THEN
      debug('When others exception from Mass Edit Entry processing query..'||to_char(sqlcode)||'-'||substr(sqlerrm, 1, 255));
      raise fnd_api.g_exc_error;
  END;

  IF l_found_batch is not null
  THEN
    l_status := 'Y';
  ELSE
    l_status := 'N';
  END IF;

  IF l_status = 'Y'
  THEN

    -- Setting the Batch Status to 'Processing'
    UPDATE csi_mass_edit_entries_b
    SET    status_code = 'PROCESSING',
           request_id  = FND_GLOBAL.CONC_REQUEST_ID
    WHERE  entry_id = p_entry_id;
    COMMIT;

    -- Common Validations
    -- Validating the Current Location Attributes and Owner Party of the
    -- Instances selecetd for processing with actual table values

    -- px_medit_rec.entry_id    :=  p_entry_id;
    px_medit_rec.txn_line_id :=  l_txn_line_id;
    px_medit_rec.batch_type  :=  l_batch_type;
    px_medit_rec.name  :=  l_name;
    -- px_medit_rec.description :=  l_batch_desc;

    csi_mass_edit_pvt.validate_batch(
                          px_mass_edit_rec      => px_medit_rec,
                          p_mode                => 'CP',
                          x_mass_edit_error_tbl => l_medit_error_tbl,
                          x_return_status       => l_return_status
                         );
    debug('Return status from validation routine : '|| l_return_status);

    If l_return_status <> fnd_api.g_ret_sts_success
    Then
      If l_medit_error_tbl.count > 0
      Then
        l_temp_merror_tbl.delete;
        For e in l_medit_error_tbl.FIRST .. l_medit_error_tbl.LAST
        Loop
          l_temp_merror_tbl(e).Entry_Id           := l_medit_error_tbl(e).entry_id;
          l_temp_merror_tbl(e).Txn_Line_Detail_Id := l_medit_error_tbl(e).Txn_Line_Detail_Id;
          l_temp_merror_tbl(e).Instance_Id        := l_medit_error_tbl(e).Instance_Id;
          l_temp_merror_tbl(e).Error_Message      := l_medit_error_tbl(e).Error_Text;
          l_temp_merror_tbl(e).Error_Code         := l_medit_error_tbl(e).Error_Code;
          l_temp_merror_tbl(e).NAME               := l_medit_error_tbl(e).NAME;
          l_temp_merror_tbl(e).Entity_Name        := 'TXNLINE';
        End Loop;
      End If;
      If l_return_status = 'E'
      Then
        l_found_error := 'E';
        -- debug('Call update error status');
        update_error_status(l_temp_merror_tbl,l_txn_line_id,p_entry_id);
        -- debug('Call error report');
        conc_report ( p_temp_merror_tbl => l_temp_merror_tbl,
                      p_name            => 'VALERROR',
                      p_batch_id        => p_entry_id,
                      p_batch_name      => l_name
                     );
        debug('Aborting Concurrent Program by raising exception');
        -- l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'E';
      Else
        If l_return_status = 'W'
        Then
          l_found_error := 'W';
          errbuf := 'W';
        End If;
        l_return_status := 'T';
      End If;
    Else
      l_return_status := 'T';
    End If;

   BEGIN
    savepoint START_PROCESSING;
    IF l_return_status = 'T'
    THEN
      --l_total_count:=0;
      --l_error_count:=0;

      -- Populating the New Data from dummy record
      d_txn_line_query_rec.TRANSACTION_LINE_ID         := l_txn_line_id;
      d_txn_line_query_rec.SOURCE_TRANSACTION_TABLE    := 'CSI_MASS_EDIT_ENTRIES';
      d_txn_line_query_rec.source_transaction_id       := p_entry_id;
      d_txn_line_detail_query_rec.TRANSACTION_LINE_ID  := l_txn_line_id;
      d_txn_line_detail_query_rec.instance_exists_flag := 'N';

      csi_t_txn_details_grp.get_transaction_details(
        p_api_version                => 1.0,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => fnd_api.g_true,
        p_validation_level           => fnd_api.g_valid_level_full,
        p_txn_line_query_rec         => d_txn_line_query_rec,
        p_txn_line_detail_query_rec  => d_txn_line_detail_query_rec,
        x_txn_line_detail_tbl        => d_line_dtl_tbl,
        p_get_parties_flag           => fnd_api.g_true,
        x_txn_party_detail_tbl       => d_pty_dtl_tbl,
        p_get_pty_accts_flag         => fnd_api.g_true,
        x_txn_pty_acct_detail_tbl    => d_pty_acct_tbl,
        p_get_ii_rltns_flag          => fnd_api.g_true,
        x_txn_ii_rltns_tbl           => d_ii_rltns_tbl,
        p_get_org_assgns_flag        => fnd_api.g_true,
        x_txn_org_assgn_tbl          => d_org_assgn_tbl,
        p_get_ext_attrib_vals_flag   => fnd_api.g_true,
        x_txn_ext_attrib_vals_tbl    => d_ext_attrib_tbl,
        p_get_csi_attribs_flag       => fnd_api.g_false,
        x_csi_ext_attribs_tbl        => d_csi_ea_tbl,
        p_get_csi_iea_values_flag    => fnd_api.g_false,
        x_csi_iea_values_tbl         => d_csi_eav_tbl,
        p_get_txn_systems_flag       => fnd_api.g_false,
        x_txn_systems_tbl            => d_txn_systems_tbl,
        x_return_status              => l_return_status,
        x_msg_count                  => l_msg_count,
        x_msg_data                   => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      debug('After get_transaction_details :');
      debug('  line_dtl_tbl.count   :'||d_line_dtl_tbl.count);
      debug('  pty_dtl_tbl.count    :'||d_pty_dtl_tbl.count);
      debug('  pty_acct_tbl.count   :'||d_pty_acct_tbl.count);
      debug('  ext_attrib_tbl.count :'||d_ext_attrib_tbl.count);

      debug('Dump Txn Details Information .....');

      csi_t_gen_utility_pvt.dump_txn_tables(
        p_ids_or_index_based => 'I',
        p_line_detail_tbl    =>   d_line_dtl_tbl,
        p_party_detail_tbl   =>   d_pty_dtl_tbl,
        p_pty_acct_tbl       =>   d_pty_acct_tbl,
        p_ii_rltns_tbl       =>   d_ii_rltns_tbl,
        p_org_assgn_tbl      =>   d_org_assgn_tbl,
        p_ea_vals_tbl        =>   d_ext_attrib_tbl);

      -- Building Instance rec
      FOR l_instance_csr IN selected_instance_csr(l_txn_line_id)
      LOOP
        n_inst_ind := n_inst_ind + 1;
        n_instance_tbl(n_inst_ind).instance_id           := l_instance_csr.instance_id;
        n_instance_tbl(n_inst_ind).object_version_number := l_instance_csr.object_version_number;
        -- System
        If nvl(d_line_dtl_tbl(1).csi_system_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        Then
          n_instance_tbl(n_inst_ind).system_id           := d_line_dtl_tbl(1).csi_system_id;
        End If;
        -- Instance Status
        If nvl(d_line_dtl_tbl(1).instance_status_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        Then
          n_instance_tbl(n_inst_ind).instance_status_id  := d_line_dtl_tbl(1).instance_status_id;
        End If;
        -- External Reference
        If nvl(d_line_dtl_tbl(1).external_reference,fnd_api.g_miss_char) <> fnd_api.g_miss_char
        Then
          n_instance_tbl(n_inst_ind).external_reference  := d_line_dtl_tbl(1).external_reference;
        End If;
        -- Version Label
        If nvl(d_line_dtl_tbl(1).version_label,fnd_api.g_miss_char) <> fnd_api.g_miss_char
        Then
          n_instance_tbl(n_inst_ind).version_label       := d_line_dtl_tbl(1).version_label;
        End If ;
        -- Transfer Date
        IF nvl(d_line_dtl_tbl(1).active_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
        Then
          n_instance_tbl(n_inst_ind).active_start_date   := d_line_dtl_tbl(1).active_start_date;
        End If;
        -- Termination Date
        IF nvl(d_line_dtl_tbl(1).active_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
        Then
          n_instance_tbl(n_inst_ind).active_end_date   := d_line_dtl_tbl(1).active_end_date;
        End If;

        IF nvl(d_line_dtl_tbl(1).active_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date THEN
          debug('Setting Termination Date in instance Rec');
          n_txn_rec.source_transaction_date := d_line_dtl_tbl(1).active_end_date;
        End If;
        debug('Termination Date.........................:'||n_txn_rec.source_transaction_date);

        -- Install Date
        IF nvl(d_line_dtl_tbl(1).installation_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
        Then
          n_instance_tbl(n_inst_ind).install_date        := d_line_dtl_tbl(1).installation_date;
        End If;

        -- Install and Current Location Changes
        IF l_batch_type in ('XFER','MOVE')
        Then
          IF nvl(l_instance_csr.instance_usage_code,fnd_api.g_miss_char) = 'IN_RELATIONSHIP'
          Then
             n_instance_tbl(n_inst_ind).location_id                := fnd_api.g_miss_num;
             n_instance_tbl(n_inst_ind).location_type_code         := fnd_api.g_miss_char;
             n_instance_tbl(n_inst_ind).install_location_id        := fnd_api.g_miss_num;
             n_instance_tbl(n_inst_ind).install_location_type_code := fnd_api.g_miss_char;
          Else
            IF nvl(d_line_dtl_tbl(1).location_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
            Then
              n_instance_tbl(n_inst_ind).location_id                := d_line_dtl_tbl(1).location_id;
            End If;
            IF nvl(d_line_dtl_tbl(1).location_type_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
            Then
              n_instance_tbl(n_inst_ind).location_type_code         := d_line_dtl_tbl(1).location_type_code;
            End If;
            IF nvl(d_line_dtl_tbl(1).install_location_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
            Then
              n_instance_tbl(n_inst_ind).install_location_id        := d_line_dtl_tbl(1).install_location_id;
            End If;
            IF nvl(d_line_dtl_tbl(1).install_location_type_code,fnd_api.g_miss_char) <> fnd_api.g_miss_char
            Then
              n_instance_tbl(n_inst_ind).install_location_type_code := d_line_dtl_tbl(1).install_location_type_code;
            End If;
          End If;
        End If;
      END LOOP;

      -- Identifying New Owner Account details
      IF d_pty_acct_tbl.count > 0
      THEN
        FOR i in d_pty_acct_tbl.FIRST .. d_pty_acct_tbl.LAST
        LOOP
          IF d_pty_acct_tbl(i).relationship_type_code = 'OWNER'
          THEN
            l_pry_account_id := d_pty_acct_tbl(i).ACCOUNT_ID;
            l_acct_rel_typ   := d_pty_acct_tbl(i).RELATIONSHIP_TYPE_CODE;
            l_acct_bill_to   := d_pty_acct_tbl(i).BILL_TO_ADDRESS_ID;
            l_acct_ship_to   := d_pty_acct_tbl(i).SHIP_TO_ADDRESS_ID;
          END IF;
        END LOOP;
      END IF;
      l_parent_tbl_index := 0;
      l_pty_index        := 0;
      l_acct_index       := 0;
      l_cont_index       := 0;
      l_ext_attr_ind     := 0;      -- bug 7613909
      FOR l_core_inst_pty_det IN core_inst_pty_acct_csr(l_txn_line_id)
      LOOP
        -- debug('l_core_inst_pty_det.instance_id '||l_core_inst_pty_det.pty_instance_id);
        -- Party Table
       l_parent_tbl_index := l_parent_tbl_index + 1;

       IF d_pty_dtl_tbl.count > 0 THEN

        FOR j in d_pty_dtl_tbl.FIRST .. d_pty_dtl_tbl.LAST
        LOOP
          -- Building New owner party
          IF d_pty_dtl_tbl(j).relationship_type_code = 'OWNER'
            AND
             nvl(d_pty_dtl_tbl(j).contact_flag,fnd_api.g_miss_char) = 'N'
            AND
             l_batch_type = 'XFER'
          THEN
            l_pty_index        := l_pty_index + 1;
            n_party_tbl(l_pty_index).parent_tbl_index       := l_parent_tbl_index;
            n_party_tbl(l_pty_index).instance_party_id      := l_core_inst_pty_det.pty_instance_party_id;
            n_party_tbl(l_pty_index).instance_id            := l_core_inst_pty_det.pty_instance_id;
            n_party_tbl(l_pty_index).party_source_table     := d_pty_dtl_tbl(j).PARTY_SOURCE_TABLE;
            n_party_tbl(l_pty_index).party_id               := d_pty_dtl_tbl(j).PARTY_SOURCE_ID;
            n_party_tbl(l_pty_index).relationship_type_code := d_pty_dtl_tbl(j).RELATIONSHIP_TYPE_CODE;
            n_party_tbl(l_pty_index).object_version_number  := l_core_inst_pty_det.pty_obj_version_number;
            n_party_tbl(l_pty_index).contact_flag           := 'N';


            IF nvl(d_pty_dtl_tbl(j).active_start_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date THEN
              debug('Setting Party Transfer Date in Transaction Rec');
              n_txn_rec.source_transaction_date := d_pty_dtl_tbl(j).active_start_date;
            End If;
            debug('Transfer Date.........................:'||n_txn_rec.source_transaction_date);

            l_party_detail_id := d_pty_dtl_tbl(j).txn_party_detail_id;
            l_pty_tbl_ind     := l_pty_index;

            l_acct_index := l_acct_index + 1;
            n_party_account_tbl(l_acct_index).ip_account_id          := l_core_inst_pty_det.pty_acc_ip_account_id;
            n_party_account_tbl(l_acct_index).instance_party_id      := l_core_inst_pty_det.pty_acc_instance_party_id;
            n_party_account_tbl(l_acct_index).parent_tbl_index       := l_pty_index;
            n_party_account_tbl(l_acct_index).party_account_id       := l_pry_account_id;
            n_party_account_tbl(l_acct_index).relationship_type_code := l_acct_rel_typ;
            n_party_account_tbl(l_acct_index).bill_to_address        := l_acct_bill_to;
            n_party_account_tbl(l_acct_index).ship_to_address        := l_acct_ship_to;
            n_party_account_tbl(l_acct_index).object_version_number  := l_core_inst_pty_det.pty_acct_obj_version_number;
          ELSIF d_pty_dtl_tbl(j).relationship_type_code = 'OWNER'
            AND
             nvl(d_pty_dtl_tbl(j).contact_flag,fnd_api.g_miss_char) = 'N'
            AND
             l_batch_type = 'MOVE'
          THEN
            l_pty_index        := l_pty_index + 1;
            n_party_tbl(l_pty_index).parent_tbl_index       := l_parent_tbl_index;
            n_party_tbl(l_pty_index).instance_party_id      := l_core_inst_pty_det.pty_instance_party_id;
            n_party_tbl(l_pty_index).instance_id            := l_core_inst_pty_det.pty_instance_id;
            n_party_tbl(l_pty_index).party_source_table     := l_core_inst_pty_det.pty_party_source_table;
            n_party_tbl(l_pty_index).party_id               := l_core_inst_pty_det.pty_party_id;
            n_party_tbl(l_pty_index).relationship_type_code := l_core_inst_pty_det.pty_rel_type_code;
            n_party_tbl(l_pty_index).object_version_number  := l_core_inst_pty_det.pty_obj_version_number;
            n_party_tbl(l_pty_index).contact_flag           := 'N';

            l_party_detail_id := d_pty_dtl_tbl(j).txn_party_detail_id;
            l_pty_tbl_ind     := l_pty_index;

            l_acct_index := l_acct_index + 1;
            n_party_account_tbl(l_acct_index).ip_account_id          := l_core_inst_pty_det.pty_acc_ip_account_id;
            n_party_account_tbl(l_acct_index).instance_party_id      := l_core_inst_pty_det.pty_acc_instance_party_id;
            n_party_account_tbl(l_acct_index).parent_tbl_index       := l_pty_index;
            n_party_account_tbl(l_acct_index).party_account_id       := l_core_inst_pty_det.pty_acc_party_account_id;
            n_party_account_tbl(l_acct_index).relationship_type_code := l_core_inst_pty_det.pty_acct_rel_type_code;
            n_party_account_tbl(l_acct_index).bill_to_address        := l_acct_bill_to;
            n_party_account_tbl(l_acct_index).ship_to_address        := l_acct_ship_to;
            n_party_account_tbl(l_acct_index).object_version_number  := l_core_inst_pty_det.pty_acct_obj_version_number;

            -- Building New Party other than owner
          ELSIF d_pty_dtl_tbl(j).relationship_type_code <> 'OWNER'
               AND
                nvl(d_pty_dtl_tbl(j).contact_flag,fnd_api.g_miss_char) = 'N'
               AND
                d_pty_dtl_tbl(j).active_end_date is null
               AND
                l_batch_type in ('XFER','MOVE','GEN')
          THEN
            l_pty_index        := l_pty_index + 1;
            n_party_tbl(l_pty_index).parent_tbl_index       := l_parent_tbl_index;
            n_party_tbl(l_pty_index).instance_id            := l_core_inst_pty_det.pty_instance_id;
            n_party_tbl(l_pty_index).party_source_table     := d_pty_dtl_tbl(j).PARTY_SOURCE_TABLE;
            n_party_tbl(l_pty_index).party_id               := d_pty_dtl_tbl(j).PARTY_SOURCE_ID;
            n_party_tbl(l_pty_index).relationship_type_code := d_pty_dtl_tbl(j).RELATIONSHIP_TYPE_CODE;
            n_party_tbl(l_pty_index).contact_flag           := 'N';
            l_party_detail_id := d_pty_dtl_tbl(j).txn_party_detail_id;
            l_pty_tbl_ind     := l_pty_index;
            -- Building Association to be expired
          ELSIF d_pty_dtl_tbl(j).relationship_type_code <> 'OWNER'
               AND
                nvl(d_pty_dtl_tbl(j).contact_flag,fnd_api.g_miss_char) = 'N'
               AND
                nvl(d_pty_dtl_tbl(j).active_end_date,fnd_api.g_miss_date) <> fnd_api.g_miss_date
               AND
                l_batch_type in ('XFER','MOVE','GEN')
          THEN
            FOR l_asso_exp_rec IN curr_asso_csr(l_core_inst_pty_det.pty_instance_id)
            LOOP
              IF l_asso_exp_rec.pty_party_source_table = d_pty_dtl_tbl(j).PARTY_SOURCE_TABLE
                AND
                 l_asso_exp_rec.pty_party_id           = d_pty_dtl_tbl(j).PARTY_SOURCE_ID
                AND
                 l_asso_exp_rec.pty_rel_type_code      = d_pty_dtl_tbl(j).RELATIONSHIP_TYPE_CODE
              THEN
                l_pty_index        := l_pty_index + 1;
                n_party_tbl(l_pty_index).parent_tbl_index       := l_parent_tbl_index;
                n_party_tbl(l_pty_index).instance_party_id      := l_asso_exp_rec.pty_instance_party_id;
                n_party_tbl(l_pty_index).instance_id            := l_core_inst_pty_det.pty_instance_id;
                n_party_tbl(l_pty_index).party_source_table     := d_pty_dtl_tbl(j).PARTY_SOURCE_TABLE;
                n_party_tbl(l_pty_index).party_id               := d_pty_dtl_tbl(j).PARTY_SOURCE_ID;
                n_party_tbl(l_pty_index).relationship_type_code := d_pty_dtl_tbl(j).RELATIONSHIP_TYPE_CODE;
                n_party_tbl(l_pty_index).active_end_date        := d_pty_dtl_tbl(j).ACTIVE_END_DATE;
                n_party_tbl(l_pty_index).object_version_number  := l_asso_exp_rec.pty_obj_version_number;
                n_party_tbl(l_pty_index).contact_flag           := 'N';
              END IF;
            END LOOP;
          END IF;
          IF l_party_detail_id is not null
          THEN
            -- Building Accounts
            IF d_pty_acct_tbl.count > 0
            THEN
              FOR k IN d_pty_acct_tbl.FIRST .. d_pty_acct_tbl.LAST
              LOOP
                IF d_pty_acct_tbl(K).TXN_PARTY_DETAIL_ID = l_party_detail_id
                THEN
                  IF d_pty_acct_tbl(K).relationship_type_code <> 'OWNER'
                  THEN
                    l_acct_index := l_acct_index + 1;
                    n_party_account_tbl(l_acct_index).parent_tbl_index       := l_pty_tbl_ind;
                    n_party_account_tbl(l_acct_index).party_account_id       := d_pty_acct_tbl(K).ACCOUNT_ID;
                    n_party_account_tbl(l_acct_index).relationship_type_code := d_pty_acct_tbl(K).RELATIONSHIP_TYPE_CODE;
                    n_party_account_tbl(l_acct_index).bill_to_address        := d_pty_acct_tbl(K).BILL_TO_ADDRESS_ID;
                    n_party_account_tbl(l_acct_index).ship_to_address        := d_pty_acct_tbl(K).SHIP_TO_ADDRESS_ID;
                  END IF;
                END IF;
              END LOOP;
            END IF;
            -- Building Contacts
            FOR l in d_pty_dtl_tbl.FIRST .. d_pty_dtl_tbl.LAST
            LOOP
              IF d_pty_dtl_tbl(l).contact_party_id = l_party_detail_id
              THEN
                l_pty_index := l_pty_index + 1;
                n_party_tbl(l_pty_index).parent_tbl_index         := l_parent_tbl_index;
                n_party_tbl(l_pty_index).contact_parent_tbl_index := l_pty_tbl_ind;
                n_party_tbl(l_pty_index).instance_id              := l_core_inst_pty_det.pty_instance_id;
                n_party_tbl(l_pty_index).party_source_table       := d_pty_dtl_tbl(l).PARTY_SOURCE_TABLE;
                n_party_tbl(l_pty_index).party_id                 := d_pty_dtl_tbl(l).PARTY_SOURCE_ID;
                n_party_tbl(l_pty_index).relationship_type_code   := d_pty_dtl_tbl(l).RELATIONSHIP_TYPE_CODE;
                n_party_tbl(l_pty_index).contact_flag             := 'Y';
              END IF;
            END LOOP;
            l_party_detail_id := '';
          END IF;
        END LOOP; -- Loop end for each record in party_detail table
       END IF;
        -- Building extended attribs
        IF d_ext_attrib_tbl.count > 0
        THEN
          FOR m in d_ext_attrib_tbl.FIRST .. d_ext_attrib_tbl.LAST
          LOOP
            l_ext_attrib_exists := FALSE;   -- Bug 8495187
            FOR l_core_ieav_val_rec IN core_iea_val_csr(l_txn_line_id)
            LOOP
              IF  l_core_ieav_val_rec.instance_id  = l_core_inst_pty_det.pty_instance_id  THEN      -- bug 7613909
                IF  l_core_ieav_val_rec.attribute_id = d_ext_attrib_tbl(m).attribute_source_id      -- bug 7613909
                THEN
                  l_ext_attr_ind := l_ext_attr_ind + 1;
                  -- Attribute already existing to this Instance
                  n_ext_attrib_values_tbl(l_ext_attr_ind).parent_tbl_index      := l_parent_tbl_index;
                  n_ext_attrib_values_tbl(l_ext_attr_ind).attribute_value_id    := l_core_ieav_val_rec.attribute_value_id;
                  n_ext_attrib_values_tbl(l_ext_attr_ind).attribute_value       := d_ext_attrib_tbl(m).attribute_value;
                  n_ext_attrib_values_tbl(l_ext_attr_ind).object_version_number := l_core_ieav_val_rec.object_version_number;
                  l_ext_attrib_exists := TRUE;   -- Bug 8495187
               /* ELSE                 -- Bug 8495187
                  l_ext_attr_ind := l_ext_attr_ind + 1;
                  -- Create new attribute to this Instance
                  n_ext_attrib_values_tbl(l_ext_attr_ind).parent_tbl_index      := l_parent_tbl_index;
                  n_ext_attrib_values_tbl(l_ext_attr_ind).instance_id           := l_core_ieav_val_rec.instance_id;
                  n_ext_attrib_values_tbl(l_ext_attr_ind).attribute_id          := d_ext_attrib_tbl(m).attribute_source_id;
                  n_ext_attrib_values_tbl(l_ext_attr_ind).attribute_value       := d_ext_attrib_tbl(m).attribute_value; */      -- Bug 8495187
                END IF;
              END IF;                               -- bug 7613909
            END LOOP;
            IF l_ext_attrib_exists = FALSE THEN  -- Bug 8495187  start
              l_ext_attr_ind := l_ext_attr_ind + 1;
              -- Create new attribute to this Instance
              n_ext_attrib_values_tbl(l_ext_attr_ind).parent_tbl_index      := l_parent_tbl_index;
              n_ext_attrib_values_tbl(l_ext_attr_ind).instance_id           := l_core_inst_pty_det.pty_instance_id;
              n_ext_attrib_values_tbl(l_ext_attr_ind).attribute_id          := d_ext_attrib_tbl(m).attribute_source_id;
              n_ext_attrib_values_tbl(l_ext_attr_ind).attribute_value       := d_ext_attrib_tbl(m).attribute_value;

            END IF;   -- Bug 8495187  end
          END LOOP;
        END IF;
      END LOOP; -- Loop end for each instance rec
      debug('Details passed to group API : ');
      debug('  Instance_tbl      '||n_instance_tbl.count);
      debug('  party_tbl         '||n_party_tbl.count);
      debug('  party_account_tbl '||n_party_account_tbl.count);
      debug('  Extendedattr_tbl  '||n_ext_attrib_values_tbl.count);
      IF n_instance_tbl.count > 0
      THEN

        csi_t_gen_utility_pvt.dump_csi_instance_tbl(n_instance_tbl);
        csi_t_gen_utility_pvt.dump_csi_party_tbl(n_party_tbl);
        csi_t_gen_utility_pvt.dump_csi_account_tbl(n_party_account_tbl);
        debug('Source Transaction Date in Transaction: '||n_txn_rec.source_transaction_date);
        debug('Transaction Date in Transaction: '||n_txn_rec.transaction_date);

        csi_item_instance_grp.update_item_instance (
                p_api_version           => 1.0
               ,p_commit                => fnd_api.g_false
               ,p_init_msg_list         => fnd_api.g_true
               ,p_validation_level      => fnd_api.g_valid_level_full
               ,p_instance_tbl          => n_instance_tbl
               ,p_ext_attrib_values_tbl => n_ext_attrib_values_tbl
               ,p_party_tbl             => n_party_tbl
               ,p_account_tbl           => n_party_account_tbl
               ,p_pricing_attrib_tbl    => n_price_tbl
               ,p_org_assignments_tbl   => n_org_assignments_tbl
               ,p_asset_assignment_tbl  => n_asset_assignment_tbl
               ,p_txn_rec               => n_txn_rec
               ,x_instance_id_lst       => n_instance_id_lst
               ,p_grp_upd_error_tbl     => n_grp_error_tbl
               ,x_return_status         => l_return_status
               ,x_msg_count             => l_msg_count
               ,x_msg_data              => l_msg_data);
          debug('Group API Return status :'|| l_return_status);
         -- IF NOT l_return_status = fnd_api.g_ret_sts_success
         -- THEN
         --   l_msg_index := 1;
         --   l_Error_Message := l_Msg_Data;
         --   WHILE l_msg_count > 0
         --   LOOP
         --      l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
         --      l_msg_index := l_msg_index + 1;
         --      l_Msg_Count := l_Msg_Count - 1;
         --   END LOOP;
         --     RAISE fnd_api.g_exc_error;
         -- END IF;
         -- END IF;

          If n_grp_error_tbl.count > 0
          Then
            l_return_status := fnd_api.g_ret_sts_error;
            errbuf := 'E';
        -- Added for bug 5169999
          Elsif l_return_status = 'W'
          Then
		     errbuf := 'W';
             l_errbuf :='W';
            l_msg_index := 1;

            l_warning_message := l_msg_data;
            WHILE l_msg_count > 0
            LOOP
               l_warning_message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
               debug_out('Warning message '||l_msg_index||' from OKS API is :'||l_warning_message);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
          End If;


          If NOT (l_return_status = fnd_api.g_ret_sts_success) AND
                  errbuf <>'W'
          Then
            -- Buildinig the error table for sorting and reporting
            If nvl(n_grp_error_tbl.count,0) > 0
            Then
              If l_found_error = 'W'
              Then
                For i in n_grp_error_tbl.FIRST .. n_grp_error_tbl.LAST
                LOOP
                  l_grp_api_ind := l_temp_merror_tbl.count + 1;
                  l_temp_merror_tbl(l_grp_api_ind).Entry_Id           := p_entry_id;
                  -- l_temp_merror_tbl(l_grp_api_ind).Txn_Line_Detail_Id := n_grp_error_tbl(i).Txn_Line_Detail_Id;
                  l_temp_merror_tbl(l_grp_api_ind).Instance_Id        := n_grp_error_tbl(i).Instance_id;
                  l_temp_merror_tbl(l_grp_api_ind).Error_Message      := n_grp_error_tbl(i).Error_Message;
                  l_temp_merror_tbl(l_grp_api_ind).Error_Code         := 'E';
                  l_temp_merror_tbl(l_grp_api_ind).NAME               := l_name;
                  l_temp_merror_tbl(l_grp_api_ind).Entity_Name        := n_grp_error_tbl(i).Entity_Name;
                End Loop;
              Else
                For i in n_grp_error_tbl.FIRST .. n_grp_error_tbl.LAST
                LOOP
                  l_temp_merror_tbl(i).Entry_Id           := p_entry_id;
                  -- l_temp_merror_tbl(l_temp_merror_tbl.count + 1).Txn_Line_Detail_Id := n_grp_error_tbl(i).Txn_Line_Detail_Id;
                  l_temp_merror_tbl(i).Instance_Id        := n_grp_error_tbl(i).Instance_id;
                  l_temp_merror_tbl(i).Error_Message      := n_grp_error_tbl(i).Error_Message;
                  l_temp_merror_tbl(i).Error_Code         := 'E';
                  l_temp_merror_tbl(i).NAME               := l_name;
                  l_temp_merror_tbl(i).Entity_Name        := n_grp_error_tbl(i).Entity_Name;
                End Loop;
              End If;
            END IF;
            -- debug('Call update error status');
            update_error_status(l_temp_merror_tbl,l_txn_line_id,p_entry_id);
            -- debug('Call error report');
            conc_report ( p_temp_merror_tbl => l_temp_merror_tbl,
                          p_name            => 'GRPERROR',
                          p_batch_id        => p_entry_id,
                          p_batch_name      => l_name
                         );
            debug('Aborting Concurrent Program by raising exception');
            RAISE fnd_api.g_exc_error;
          Else
            -- For each Instance need to Create Notes
            IF  n_instance_tbl.count > 0
            THEN
              IF l_batch_desc IS NOT NULL
              THEN
                l_temp_merror_tbl.delete;
                FOR i in n_instance_tbl.FIRST .. n_instance_tbl.LAST
                LOOP
                    JTF_NOTES_PUB.CREATE_NOTE
                       (
                          p_parent_note_id         => NULL,
                          p_api_version            => 1,
                          p_init_msg_list          => NULL,
                          p_commit                 => FND_API.G_FALSE,
                          p_validation_level       => fnd_api.g_valid_level_full, --0,
                          x_return_status          => l_return_status,
                          x_msg_count              => l_msg_count,
                          x_msg_data               => l_msg_data,
                          x_jtf_note_id            => l_note_id,
                          p_org_id                 => NULL,
                          p_source_object_id       => n_instance_tbl(i).instance_id,
                          p_source_object_code     => 'CP',
                          p_notes                  => l_batch_desc,
                          --  p_notes_detail           => COMMENTS,
                          p_note_status            => 'I',
                          p_entered_by             => FND_GLOBAL.USER_ID,
                          p_entered_date           => SYSDATE,
                          p_last_update_date       => SYSDATE,
                          p_last_updated_by        => FND_GLOBAL.USER_ID,
                          p_creation_date          => SYSDATE,
                          p_created_by             => FND_GLOBAL.USER_ID
                       );

                    debug('JTF API Return status :'||l_return_status);
                    IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS)
                    Then
                      If l_jtf_error = 'N'
                      Then
                        l_jtf_error := 'Y';
                        errbuf := 'E';
                      End If;

                      l_msg_index := 1;
                      l_Error_Message := l_Msg_Data;
                      WHILE l_msg_count > 0
                      LOOP
                        l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                        l_msg_index := l_msg_index + 1;
                        l_Msg_Count := l_Msg_Count - 1;
                      END LOOP;

                      l_jtf_err_ind := l_temp_merror_tbl.count + 1;
                      l_temp_merror_tbl(l_jtf_err_ind).Entry_Id           := p_entry_id;
                      -- l_temp_merror_tbl(l_jtf_err_ind).Txn_Line_Detail_Id := n_grp_error_tbl(i).Txn_Line_Detail_Id;
                      l_temp_merror_tbl(l_jtf_err_ind).Instance_Id        := n_grp_error_tbl(i).Instance_id;
                      l_temp_merror_tbl(l_jtf_err_ind).Error_Message      := l_Error_Message;
                      l_temp_merror_tbl(l_jtf_err_ind).Error_Code         := 'E';
                      l_temp_merror_tbl(l_jtf_err_ind).NAME               := l_name;
                      l_temp_merror_tbl(l_jtf_err_ind).Entity_Name        := 'JTFNOTES';
                    END IF;
                END LOOP;
              END IF;
              If l_jtf_error <> 'Y'
              Then
                Debug('Notes created for instance successfully');
                Debug_out('Notes created for instance successfully');
                Debug('Checking for system mass update');
                Debug_out('Checking for system mass update');
                -- Bug 7483403
                IF NVL(l_system_cascade, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
                  l_system_cascade := 'N';
                END IF;  -- NVL(l_system_cascade, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
                IF l_system_cascade = 'N' THEN
                  -- The system cascade is not set
                  -- Update the mass update status and exit
                   -- Updating the status of transaction line for the batch
                    UPDATE csi_t_transaction_lines
                    SET    processing_status   = 'PROCESSED'
                    WHERE  transaction_line_id = l_txn_line_id;

                    -- Update the status of all the transaction line details for the batch
                    UPDATE csi_t_txn_line_details
                    SET    error_explanation   = '',
                           processing_status   = 'PROCESSED',
                           error_code          = 'P'
                    WHERE  transaction_line_id = l_txn_line_id
                    AND    instance_id is not null;

                    -- Updating batch status
                    UPDATE csi_mass_edit_entries_b
                    SET    status_code = 'SUCCESSFUL'
                    WHERE  entry_id    = p_entry_id;

                   IF l_errbuf='W'
                   THEN
                    Debug(' ');
                    Debug(' **** Mass Edit Batch ('||l_name||') Status : WARNING');
                    Debug(' ');

                    Debug_out(' ');
                    Debug_out('Mass Edit Batch ('||l_name||') Status : WARNING');
                    Debug_out(' ');
                    Debug_out('---------------------------------------------------');
                   ELSE
                    Debug(' ');
                    Debug(' **** Mass Edit Batch ('||l_name||') Status : SUCCESSFUL');
                    Debug(' ');

                    Debug_out(' ');
                    Debug_out('Mass Edit Batch ('||l_name||') Status : SUCCESSFUL');
                    Debug_out(' ');
                    Debug_out('---------------------------------------------------');
                   END IF;
                END IF;  -- l_system_cascade = 'N'
                -- End Bug 7483403

              Else
                -- debug('Call update error status');
                update_error_status(l_temp_merror_tbl,l_txn_line_id,p_entry_id);

                -- debug('Call error report');
                conc_report ( p_temp_merror_tbl => l_temp_merror_tbl,
                              p_name            => 'JTFERROR',
                              p_batch_id        => p_entry_id,
                              p_batch_name      => l_name
                             );
                debug('Aborting Concurrent Program by raising exception');
                RAISE fnd_api.g_exc_error;
              End If;
            END IF; -- End If for Notes API
          END IF; -- End If for Failure/success
      END IF; -- End If for Grp APi

      -- Added for the ER 6031179
      -- Checking to see if there are instances which needs to be updated
      -- This block will update systems for transfer owner batch
      -- The system will be updated if all the active item instances
      -- which are part of the system is included in the transfer owner batch

      IF NVL(l_system_cascade, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
        l_system_cascade := 'N';
      END IF;

      debug('System Cascade : ' || l_system_cascade);
      Debug_out('System Cascade :' || l_system_cascade);

      BEGIN
        SELECT 'x' INTO l_new_owner
        FROM CSI_T_PARTY_DETAILS WHERE TXN_LINE_DETAIL_ID IN(
          SELECT TXN_LINE_DETAIL_ID FROM CSI_T_TXN_LINE_DETAILS CTLD, CSI_MASS_EDIT_ENTRIES_VL CMEE
          WHERE CTLD.TRANSACTION_LINE_ID =  CMEE.TXN_LINE_ID
              AND CMEE.ENTRY_ID = p_entry_id
              AND INSTANCE_ID IS NULL)
        AND PARTY_SOURCE_TABLE = 'HZ_PARTIES'
        AND RELATIONSHIP_TYPE_CODE = 'OWNER'
        AND ROWNUM = 1;

        SELECT 'x' INTO l_old_owner
        FROM CSI_T_PARTY_DETAILS WHERE TXN_LINE_DETAIL_ID IN(
            SELECT TXN_LINE_DETAIL_ID FROM CSI_T_TXN_LINE_DETAILS CTLD, CSI_MASS_EDIT_ENTRIES_VL CMEE
            WHERE CTLD.TRANSACTION_LINE_ID =  CMEE.TXN_LINE_ID
              AND CMEE.ENTRY_ID = p_entry_id
              AND INSTANCE_ID IS NOT NULL)
          AND PARTY_SOURCE_TABLE = 'HZ_PARTIES'
          AND RELATIONSHIP_TYPE_CODE = 'OWNER'
          AND ROWNUM = 1;

      debug('l_old_owner type - ' || l_old_owner);
      debug('l_new_owner type - ' || l_new_owner);

       IF  l_old_owner IS NOT NULL AND l_new_owner IS NOT NULL THEN
        l_perform_system_mu := 'Y';
       END IF;

      EXCEPTION
        WHEN OTHERS THEN
        debug('The Batch doesn not qualify for system mass update
              as the owner type is not HZ_PARTIES');
         l_perform_system_mu := 'N';
      END;

      -- The processing of systems must proceed only if the owner type is HZ_PARTIES
      IF l_batch_type in ('XFER') AND l_system_cascade = 'Y' AND l_perform_system_mu = 'Y' THEN
        IF n_instance_tbl.count > 0 THEN

        -- Call the PROCESS_SYSTEM_MASS_UPDATE to
        -- 1. Identify the systems which are part of the mass update transfer owner batch
        -- 2. After identifying the systems, update them

        PROCESS_SYSTEM_MASS_UPDATE (
                p_api_version           => 1.0
               ,p_commit                => fnd_api.g_false
               ,p_Entry_id              => p_Entry_id
               ,p_instance_tbl          => n_instance_tbl
               ,p_ext_attrib_values_tbl => n_ext_attrib_values_tbl   -- Not used, retained for future enhancements
               ,p_party_tbl             => n_party_tbl
               ,p_account_tbl           => n_party_account_tbl
               ,p_txn_rec               => n_txn_rec
               ,x_return_status         => l_return_status
               ,x_msg_count             => l_msg_count
               ,x_msg_data              => l_msg_data);

              IF NOT l_return_status = fnd_api.g_ret_sts_success
              THEN
              l_msg_index := 1;
              l_Error_Message := l_Msg_Data;
              WHILE l_msg_count > 0
              LOOP
                l_Error_Message := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                --debug_out('  ');
                l_msg_index := l_msg_index + 1;
                l_Msg_Count := l_Msg_Count - 1;
              END LOOP;
               -- RAISE fnd_api.g_exc_error;
              END IF;
       --  END IF;

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          -- Updating the status of transaction line for the batch
          UPDATE csi_t_transaction_lines
          SET    processing_status   = 'PROCESSED'
          WHERE  transaction_line_id = l_txn_line_id;

          -- Update the status of all the transaction line details for the batch
          UPDATE csi_t_txn_line_details
          SET    error_explanation   = '',
                 processing_status   = 'PROCESSED',
                 error_code          = 'P'
          WHERE  transaction_line_id = l_txn_line_id
          AND    instance_id is not null;

          -- Updating batch status
          UPDATE csi_mass_edit_entries_b
          SET    status_code = 'SUCCESSFUL'
          WHERE  entry_id    = p_entry_id;

         IF l_errbuf='W'
         THEN
          Debug(' ');
          Debug(' **** Mass Edit Batch ('||l_name||') Status : WARNING');
          Debug(' ');

          Debug_out(' ');
          Debug_out('Mass Edit Batch ('||l_name||') Status : WARNING');
          Debug_out(' ');
          Debug_out('---------------------------------------------------');
         ELSE
          Debug(' ');
          Debug(' **** Mass Edit Batch ('||l_name||') Status : SUCCESSFUL');
          Debug(' ');

          Debug_out(' ');
          Debug_out('Mass Edit Batch ('||l_name||') Status : SUCCESSFUL');
          Debug_out(' ');
          Debug_out('---------------------------------------------------');
         END IF; -- l_errbuf='W'
       ELSE
         -- debug('Call update error status');
                update_error_status(l_temp_merror_tbl,l_txn_line_id,p_entry_id);

          -- debug('Call error report');
          conc_report ( p_temp_merror_tbl => l_temp_merror_tbl,
                        p_name            => 'JTFERROR',
                        p_batch_id        => p_entry_id,
                        p_batch_name      => l_name
                       );

          UPDATE_MUSYS_ERR_STATUS(p_entry_id);

          debug('Aborting Concurrent Program by raising exception');
          RAISE fnd_api.g_exc_error;
        END IF;  -- l_return_status = fnd_api.g_ret_sts_success


        END IF; -- n_instance_tbl.count Loop
      END IF; -- l_batch_type in ('XFER')
      -- End of Addition for the ER 6031179

    END IF; -- Common Validations
  END;
  END IF; -- Batch Not Found

  Commit;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
       ROLLBACK TO START_PROCESSING;
       debug( 'Program Errored : ');
       -- l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
       errbuf := 'E';
   WHEN fnd_api.g_exc_unexpected_error THEN
       ROLLBACK TO START_PROCESSING;
       debug( 'Program Errored : ');
       -- l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
       errbuf := 'E';
   WHEN OTHERS THEN
       ROLLBACK TO START_PROCESSING;
       debug( 'When others exception from Process_mass_edit_batch');
       debug( to_char(SQLCODE)||substr(SQLERRM, 1, 255));
       -- l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
       errbuf := 'E';
END Process_mass_edit_batch;

PROCEDURE CREATE_MASS_EDIT_BATCH
   (
    p_api_version          		IN   NUMBER,
    p_commit                	IN   VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN   NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_mass_edit_inst_tbl       IN OUT NOCOPY csi_mass_edit_pub.mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    mass_edit_error_tbl,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  ) IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(30) := 'CREATE_MASS_EDIT_BATCH_PUB';

  l_debug_level                  NUMBER;

  l_return_status                VARCHAR2(1)   := FND_API.G_ret_sts_success;
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(512);


  Begin
    -- Standard Start of API savepoint
    SAVEPOINT create_mass_edit_pub;

    csi_t_gen_utility_pvt.add('API Being Executed     : CREATE_MASS_EDIT_BATCH_PUB');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;
    -- main code starts here
    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    debug('px_txn_line_detail_tbl.count: '||px_mass_edit_inst_tbl.count);

    csi_mass_edit_pvt.create_mass_edit_batch
           (
            p_api_version              => l_api_version,
            p_commit                   => p_commit,
            p_init_msg_list            => p_init_msg_list,
            p_validation_level         => p_validation_level,
            px_mass_edit_rec           => px_mass_edit_rec,
            px_txn_line_rec            => px_txn_line_rec,
            px_mass_edit_inst_tbl      => px_mass_edit_inst_tbl,
            px_txn_line_detail_rec     => px_txn_line_detail_rec,
            px_txn_party_detail_tbl    => px_txn_party_detail_tbl,
            px_txn_pty_acct_detail_tbl => px_txn_pty_acct_detail_tbl,
            px_txn_ext_attrib_vals_tbl => px_txn_ext_attrib_vals_tbl,
            x_mass_edit_error_tbl      => x_mass_edit_error_tbl,
            x_return_status            => x_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data
            );


    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data
           );

    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_mass_edit_pub;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO create_mass_edit_pub;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data
                );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO create_mass_edit_pub;
              IF   FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                    FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name
                  );
              END IF;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data
                  );

  End CREATE_MASS_EDIT_BATCH;

Procedure validate_dup_batch_instances
(
	 p_txn_line_id      IN  NUMBER,
	 px_mass_edit_inst_tbl       IN mass_edit_inst_tbl,
     x_output	in out nocopy varchar2
)
IS
CURSOR selected_instance_csr (p_txn_line_id IN NUMBER) IS
       select   cii.instance_id,
		cii.instance_number
       from     csi_instance_search_v cii,
		csi_t_txn_line_details tld
       where    tld.transaction_line_id = p_txn_line_id and
		tld.instance_id is not null and
		tld.instance_id = cii.instance_id and
		nvl(tld.active_end_date(+),sysdate+1) > sysdate;
BEGIN
	FOR l_instance_csr IN selected_instance_csr(p_txn_line_id)
    LOOP
		if px_mass_edit_inst_tbl.count > 0 then
			for i in px_mass_edit_inst_tbl.first..px_mass_edit_inst_tbl.last
			loop
				IF l_instance_csr.instance_id = px_mass_edit_inst_tbl(i).instance_id THEN
					IF x_output IS NOT NULL THEN
						x_output := x_output || ',' ;
					END IF;
					x_output := x_output || l_instance_csr.instance_number;
				END IF;
			end loop;
		end if;
	END LOOP;
END;

PROCEDURE UPDATE_MASS_EDIT_BATCH (
    p_api_version               IN     NUMBER,
    p_commit                    IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN     NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec            IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_mass_edit_inst_tbl       IN OUT NOCOPY mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    mass_edit_error_tbl,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2) IS


    l_api_version             NUMBER          := 1.0;
    l_api_name                VARCHAR2(30) := 'UPDATE_MASS_EDIT_BATCH_PUB';
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(200);
    l_return_status           VARCHAR2(1);
    x_output varchar2(4000);
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_mass_edit_pub;

    csi_t_gen_utility_pvt.add('API Being Executed     : UPDATE_MASS_EDIT_BATCH_PUB');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;

    END IF;
    -- main code starts here

    validate_dup_batch_instances(
            px_txn_line_rec.TRANSACTION_LINE_ID,
            px_mass_edit_inst_tbl,
            x_output);

    IF x_output IS NOT NULL THEN
	FND_MESSAGE.set_name('CSI','CSI_MU_DUP_BATCH_INSTANCES');
    	FND_MESSAGE.set_token('INST_NUM',x_output);
        FND_MSG_PUB.add;
	RAISE FND_API.g_exc_error;
    END IF;

-- call API to run
     csi_t_gen_utility_pvt.add('px_txn_line_detail_tbl.count: '||px_mass_edit_inst_tbl.count);


    csi_mass_edit_pvt.update_mass_edit_batch
                     (
                      p_api_version              => l_api_version,
                      p_commit                   => p_commit,
                      p_init_msg_list            => p_init_msg_list,
                      p_validation_level         => p_validation_level,
                      px_mass_edit_rec           => px_mass_edit_rec,
                      px_txn_line_rec            => px_txn_line_rec,
                      px_mass_edit_inst_tbl      => px_mass_edit_inst_tbl,
                      px_txn_line_detail_rec     => px_txn_line_detail_rec,
                      px_txn_party_detail_tbl    => px_txn_party_detail_tbl,
                      px_txn_pty_acct_detail_tbl => px_txn_pty_acct_detail_tbl,
                      px_txn_ext_attrib_vals_tbl => px_txn_ext_attrib_vals_tbl,
                      x_mass_edit_error_tbl      => x_mass_edit_error_tbl,
                      x_return_status            => l_return_status,
                      x_msg_count                => l_msg_count,
                      x_msg_data                 => l_msg_data
                      );


    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
    END IF;

    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO update_mass_edit_pub;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO update_mass_edit_pub;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data
                );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO update_mass_edit_pub;
              IF   FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                    FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name
                  );
              END IF;
              FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data
                  );

END update_mass_edit_batch;

PROCEDURE DELETE_MASS_EDIT_BATCH
   (
    p_api_version               IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_mass_edit_rec          	IN  mass_edit_rec,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  ) IS

    l_api_version             NUMBER          := 1.0;
    l_api_name                VARCHAR2(30)    := 'DELETE_MASS_EDIT_BATCH';
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_return_status           VARCHAR2(1);

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_mass_edit_batch;

    csi_t_gen_utility_pvt.add('API Being Executed     : DELETE_MASS_EDIT_BATCH');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT
       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;
    END IF;
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --
     csi_utility_grp.check_ib_active;

     -- check required params
     -- either the batch id OR the batch name is required for a delete
  IF ( nvl(p_mass_edit_rec.entry_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
     AND nvl(p_mass_edit_rec.name, fnd_api.g_miss_char) = fnd_api.g_miss_char ) THEN

      FND_MESSAGE.set_name('CSI','CSI_API_REQD_PARAM_MISSING');
      FND_MESSAGE.set_token('API_NAME',l_api_name);
      FND_MESSAGE.set_token('MISSING_PARAM','Batch ID OR Batch Name');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
  END IF;

  csi_mass_edit_pvt.delete_mass_edit_batch (
         p_api_version      => p_api_version,
         p_commit           => p_commit,
         p_init_msg_list    => p_init_msg_list,
         p_validation_level => p_validation_level,
         p_mass_edit_rec    => p_mass_edit_rec,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data
        );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get
         (p_count  =>  x_msg_count,
          p_data   =>  x_msg_data
         );

    csi_t_gen_utility_pvt.add('API Executed         : Delete Mass Edit Batch');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Delete_Mass_Edit_Batch;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Mass_Edit_Batch;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Delete_Mass_Edit_Batch;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

  END Delete_Mass_Edit_Batch;

/* This is the wrapper API to handle multiple batch deletes. Calls the DELETE_MASS_EDIT_BATCH */

PROCEDURE DELETE_MASS_EDIT_BATCHES
   (
    p_api_version               IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_mass_edit_tbl          	IN  mass_edit_tbl,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  ) IS

    l_api_version             NUMBER          := 1.0;
    l_api_name                VARCHAR2(30)    := 'DELETE_MASS_EDIT_BATCHES';
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_return_status           VARCHAR2(1);

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_mass_edit_batches;

    csi_t_gen_utility_pvt.add('API Being Executed     : DELETE_MASS_EDIT_BATCHES');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT
       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;
    END IF;
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --
     csi_utility_grp.check_ib_active;

     -- check required params
     -- either the batch id OR the batch name is required for a delete
     IF p_mass_edit_tbl.count > 0 THEN
      FOR m_ind in p_mass_edit_tbl.FIRST .. p_mass_edit_tbl.LAST LOOP
          IF ( nvl(p_mass_edit_tbl(m_ind).entry_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
             AND nvl(p_mass_edit_tbl(m_ind).name, fnd_api.g_miss_char) = fnd_api.g_miss_char ) THEN

              FND_MESSAGE.set_name('CSI','CSI_API_REQD_PARAM_MISSING');
              FND_MESSAGE.set_token('API_NAME',l_api_name);
              FND_MESSAGE.set_token('MISSING_PARAM','Batch ID OR Batch Name');
              FND_MSG_PUB.add;
              RAISE FND_API.g_exc_error;
          END IF;

          csi_mass_edit_pvt.delete_mass_edit_batch (
                 p_api_version      => p_api_version,
                 p_commit           => p_commit,
                 p_init_msg_list    => p_init_msg_list,
                 p_validation_level => p_validation_level,
                 p_mass_edit_rec    => p_mass_edit_tbl(m_ind),
                 x_return_status    => l_return_status,
                 x_msg_count        => l_msg_count,
                 x_msg_data         => l_msg_data
                );

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
      END LOOP;
     END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get
         (p_count  =>  x_msg_count,
          p_data   =>  x_msg_data
         );

    csi_t_gen_utility_pvt.add('API Executed         : Delete Mass Edit Batches');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Delete_Mass_Edit_Batches;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Mass_Edit_Batches;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Delete_Mass_Edit_Batches;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

  END Delete_Mass_Edit_Batches;

  /*
     This API gets all the transaction line details and also the child records for each of
     these line details, for a given mass edit batch.
  */

  PROCEDURE GET_MASS_EDIT_DETAILS (
    p_api_version          	IN  NUMBER,
    p_commit               	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     	IN  NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN  OUT NOCOPY mass_edit_rec,
    x_txn_line_detail_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl ,
    x_txn_party_detail_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_ext_attrib_vals_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER ,
    x_msg_data                  OUT NOCOPY VARCHAR2)
IS

    l_api_version             NUMBER          := 1.0;
    l_api_name                VARCHAR2(30)    := 'GET_MASS_EDIT_DETAILS';
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_return_status           VARCHAR2(1);

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT get_mass_edit_details;

    csi_t_gen_utility_pvt.add('API Being Executed     : GET_MASS_EDIT_DETAILS');
    csi_t_gen_utility_pvt.add('Transaction Start Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT
       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;
    END IF;
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --
     csi_utility_grp.check_ib_active;

     -- check required params
     -- Currently the Get queries txn details for a given source transaction id (batch). So a unique
     -- identifier like the batch id/txn line ID OR the batch name is required for a Get

  IF ( nvl(px_mass_edit_rec.entry_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
     AND nvl(px_mass_edit_rec.name, fnd_api.g_miss_char) = fnd_api.g_miss_char
     AND nvl(px_mass_edit_rec.txn_line_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
     ) THEN
      FND_MESSAGE.set_name('CSI','CSI_API_REQD_PARAM_MISSING');
      FND_MESSAGE.set_token('API_NAME',l_api_name);
      FND_MESSAGE.set_token('MISSING_PARAM','Batch ID / Batch Name / Transaction Line ID');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
  END IF;

  csi_mass_edit_pvt.get_mass_edit_details (
         p_api_version              => p_api_version,
         p_commit                   => p_commit,
         p_init_msg_list            => p_init_msg_list,
         p_validation_level         => p_validation_level,
         px_mass_edit_rec           => px_mass_edit_rec,
         x_txn_line_detail_tbl      => x_txn_line_detail_tbl,
         x_txn_party_detail_tbl     => x_txn_party_detail_tbl,
         x_txn_pty_acct_detail_tbl  => x_txn_pty_acct_detail_tbl,
         x_txn_ext_attrib_vals_tbl  => x_txn_ext_attrib_vals_tbl,
         x_return_status            => l_return_status,
         x_msg_count                => l_msg_count,
         x_msg_data                 => l_msg_data
        );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get
         (p_count  =>  x_msg_count,
          p_data   =>  x_msg_data
         );

    csi_t_gen_utility_pvt.add('API Executed         : Get Mass Edit Details');
    csi_t_gen_utility_pvt.add('Transaction End Time :'||to_char(sysdate, 'MM/DD/YY HH24:MI:SS'));

    csi_t_gen_utility_pvt.set_debug_off;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Get_mass_edit_details;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Get_mass_edit_details;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Get_mass_edit_details;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

  END Get_mass_edit_details;

/*----------------------------------------------------*/
/* Procedure name: PROCESS_SYSTEM_MASS_UPDATE         */
/* Description :   procedure used to update System in */
/*                 mass update batch                  */
/*----------------------------------------------------*/

PROCEDURE PROCESS_SYSTEM_MASS_UPDATE
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_entry_id             IN NUMBER
    ,p_instance_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_tbl
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
 )
 IS

  CURSOR mu_new_party_csr(p_transaction_line_id NUMBER) IS
    SELECT tp.party_source_table PartySourceTable,
    tp.party_source_id PartyId,
    ta.account_id AccountId,
    party.party_number PartyNumber
     FROM csi_t_txn_line_details tld,
          csi_t_party_details tp,
          csi_t_party_accounts ta,
          hz_parties party,
          hz_cust_accounts account
    WHERE tld.txn_line_detail_id = tp.txn_line_detail_id
          AND tld.transaction_line_id    = p_transaction_line_id
          AND tld.INSTANCE_ID           IS NULL
          AND tp.txn_party_detail_id     = ta.txn_party_detail_id
          AND tp.party_source_id         = party.party_id
          AND ta.account_id              = account.cust_account_id
          AND tp.relationship_type_code  = 'OWNER'
          AND tp.party_source_table      = 'HZ_PARTIES';
 -- Bug 7350165
 -- CURSOR mu_customer_id_csr (p_party_id IN NUMBER, p_account_number IN NUMBER) IS
 --   SELECT CUST_ACCOUNT_ID  CUSTOMER_ID
 --     FROM HZ_CUST_ACCOUNTS
 --     WHERE PARTY_ID = p_party_id
 --        AND ACCOUNT_NUMBER = p_account_number;

  CURSOR mu_system_csr (p_system_id IN NUMBER) IS
    SELECT  SYSTEM_TYPE_CODE,
            SYSTEM_NUMBER,
            PARENT_SYSTEM_ID,
            COTERMINATE_DAY_MONTH,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            CONTEXT,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            OPERATING_UNIT_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID
      FROM CSI_SYSTEMS_B
      WHERE SYSTEM_ID = p_system_id;

  CURSOR mu_system_tl_csr (p_system_id IN NUMBER) IS
    SELECT  NAME,
            DESCRIPTION
      FROM CSI_SYSTEMS_TL
      WHERE SYSTEM_ID = p_system_id;



  l_api_name               CONSTANT VARCHAR2(30)     := 'PROCESS_SYSTEM_MASS_UPDATE';
  l_api_version            CONSTANT NUMBER           := 1.0;
  l_debug_level            NUMBER;
  l_txn_line_id               NUMBER;

  upd_system_tbl             csi_datastructures_pub.mu_systems_tbl;
  l_txn_sys_rec              csi_datastructures_pub.system_rec;
  l_t_txn_sys_rec               csi_t_datastructures_grp.txn_system_rec;
  l_mu_new_party_rec         mu_new_party_csr%ROWTYPE;
  --l_mu_customer_id_rec       mu_customer_id_csr%ROWTYPE; -- 7350165
  l_mu_system_rec               mu_system_csr%ROWTYPE;
  l_mu_system_tl_rec          mu_system_tl_csr%ROWTYPE;


  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;

 BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT       PROCESS_SYSTEM_MASS_UPDATE;

  debug('Inside PROCESS_SYSTEM_MASS_UPDATE');

  csi_utility_grp.check_ib_active;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
            p_api_version,
            l_api_name       ,
            G_PKG_NAME       )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check the profile option debug_level for debug message reporting
  l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

  -- If debug_level = 1 then dump the procedure name
  IF (l_debug_level > 0) THEN
	  csi_gen_utility_pvt.put_line( 'PROCESS_SYSTEM_MASS_UPDATE');
  END IF;

  debug('Starting System Cascade for Entry ID - ' || p_entry_id);
  -- Identifying systems
  -- Fetching the transaction line id
  BEGIN
  SELECT  cmee.txn_line_id
    INTO    l_txn_line_id
    FROM    csi_mass_edit_entries_vl cmee,
            csi_lookups clkps
    WHERE   cmee.entry_id       = p_entry_id
    --AND     cmee.status_code    = 'SCHEDULED'
    AND     cmee.schedule_date <= SYSDATE
    AND     clkps.lookup_type    = 'CSI_IB_TXN_TYPE_CODE'
    AND     clkps.lookup_code    = cmee.batch_type;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      debug('No data Found while fetching txn line id for system cascade');
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      debug('Others Exception while fetching txn line id for system cascade');
      RAISE FND_API.G_EXC_ERROR;
  END;
  debug('l_txn_line_id - ' || l_txn_line_id);

  IDENTIFY_SYSTEM_FOR_UPDATE (
        p_txn_line_id           => l_txn_line_id
       ,p_upd_system_tbl        => upd_system_tbl
       ,x_return_status         => l_return_status);

  IF NOT l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF upd_system_tbl.COUNT > 0 THEN

  -- Validations of the identified systems
  VALIDATE_SYSTEM_BATCH (
        p_entry_id              => p_entry_id
       ,p_txn_line_id           => l_txn_line_id
       ,p_upd_system_tbl        => upd_system_tbl
       ,x_return_status         => l_return_status);

  IF NOT l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- System update
  -- Fetch the new Party Information (Party Id, Account Id)
  BEGIN
    OPEN   mu_new_party_csr (l_txn_line_id);
    FETCH  mu_new_party_csr INTO l_mu_new_party_rec;
    CLOSE  mu_new_party_csr;
  EXCEPTION
   WHEN OTHERS THEN
      debug('In to Others Exception while finding new party information');
      debug( to_char(SQLCODE)||substr(SQLERRM, 1, 255));
      RAISE FND_API.G_EXC_ERROR;
  END;

  -- Fetch Customer id from party id and account id
 /* BEGIN
    OPEN   mu_customer_id_csr (l_mu_new_party_rec.PartyId, l_mu_new_party_rec.AccountId);
    FETCH  mu_customer_id_csr INTO l_mu_customer_id_rec;
    CLOSE  mu_customer_id_csr;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('CSI', 'CSI_CUSTOMER_ID_NOT_FOUND');
      fnd_message.set_token('PARTY_ID',l_mu_new_party_rec.PartyId);
      fnd_message.set_token('ACCOUNT_NUMBER',l_mu_new_party_rec.AccountId);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;

   WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('CSI', 'CSI_MULTIPLE_CUSTOMER_ID_FOUND');
      fnd_message.set_token('PARTY_ID',l_mu_new_party_rec.PartyId);
      fnd_message.set_token('ACCOUNT_NUMBER',l_mu_new_party_rec.AccountId);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN
      debug('In to Others Exception while finding customer id');
      RAISE FND_API.G_EXC_ERROR;
  END;
  */
   FOR system_rec_ind IN upd_system_tbl.FIRST .. upd_system_tbl.LAST
   LOOP
    l_txn_sys_rec.SYSTEM_ID := upd_system_tbl(system_rec_ind).SYSTEM_ID;
    -- Fix for the bug 7350165
    l_txn_sys_rec.CUSTOMER_ID := l_mu_new_party_rec.AccountId;
    --l_txn_sys_rec.CUSTOMER_ID := l_mu_customer_id_rec.CUSTOMER_ID;
    l_txn_sys_rec.REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

    -- Assign null values to the contact ids, site use ids
    -- TODO New enhancement has to be made at the mass update page
    -- to capture contact ids, site use id and that information
    -- should be populated here

    -- Important : Also note the base update package has been modified to
    -- accept null values update_row_for_mu
    l_txn_sys_rec.SHIP_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    l_txn_sys_rec.BILL_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    l_txn_sys_rec.TECHNICAL_CONTACT_ID := FND_API.G_MISS_NUM;
    l_txn_sys_rec.SERVICE_ADMIN_CONTACT_ID := FND_API.G_MISS_NUM;
    l_txn_sys_rec.SHIP_TO_SITE_USE_ID := FND_API.G_MISS_NUM;
    l_txn_sys_rec.BILL_TO_SITE_USE_ID := FND_API.G_MISS_NUM;
    l_txn_sys_rec.INSTALL_SITE_USE_ID := FND_API.G_MISS_NUM;

    -- Fetch the existing values of the system
    -- Other information which are non related to the system party owner
    -- is retained
    OPEN   mu_system_csr (upd_system_tbl(system_rec_ind).SYSTEM_ID);
    FETCH  mu_system_csr INTO l_mu_system_rec;
    CLOSE  mu_system_csr;

    OPEN   mu_system_tl_csr (upd_system_tbl(system_rec_ind).SYSTEM_ID);
    FETCH  mu_system_tl_csr INTO l_mu_system_tl_rec;
    CLOSE  mu_system_tl_csr;

    -- retaining the existing values of the system
    l_txn_sys_rec.SYSTEM_TYPE_CODE := l_mu_system_rec.SYSTEM_TYPE_CODE;
    l_txn_sys_rec.SYSTEM_NUMBER := l_mu_system_rec.SYSTEM_NUMBER;
    l_txn_sys_rec.PARENT_SYSTEM_ID := l_mu_system_rec.PARENT_SYSTEM_ID;
    l_txn_sys_rec.COTERMINATE_DAY_MONTH := l_mu_system_rec.COTERMINATE_DAY_MONTH;
    l_txn_sys_rec.START_DATE_ACTIVE := l_mu_system_rec.START_DATE_ACTIVE;
    l_txn_sys_rec.END_DATE_ACTIVE := l_mu_system_rec.END_DATE_ACTIVE;
    l_txn_sys_rec.CONTEXT := l_mu_system_rec.CONTEXT;
    l_txn_sys_rec.NAME := l_mu_system_tl_rec.NAME;
    l_txn_sys_rec.DESCRIPTION := l_mu_system_tl_rec.DESCRIPTION;
    l_txn_sys_rec.ATTRIBUTE1 := l_mu_system_rec.ATTRIBUTE1;
    l_txn_sys_rec.ATTRIBUTE2 := l_mu_system_rec.ATTRIBUTE2;
    l_txn_sys_rec.ATTRIBUTE3 := l_mu_system_rec.ATTRIBUTE3;
    l_txn_sys_rec.ATTRIBUTE4 := l_mu_system_rec.ATTRIBUTE4;
    l_txn_sys_rec.ATTRIBUTE5 := l_mu_system_rec.ATTRIBUTE5;
    l_txn_sys_rec.ATTRIBUTE6 := l_mu_system_rec.ATTRIBUTE6;
    l_txn_sys_rec.ATTRIBUTE7 := l_mu_system_rec.ATTRIBUTE7;
    l_txn_sys_rec.ATTRIBUTE8 := l_mu_system_rec.ATTRIBUTE8;
    l_txn_sys_rec.ATTRIBUTE9 := l_mu_system_rec.ATTRIBUTE9;
    l_txn_sys_rec.ATTRIBUTE10 := l_mu_system_rec.ATTRIBUTE10;
    l_txn_sys_rec.ATTRIBUTE11 := l_mu_system_rec.ATTRIBUTE11;
    l_txn_sys_rec.ATTRIBUTE12 := l_mu_system_rec.ATTRIBUTE12;
    l_txn_sys_rec.ATTRIBUTE13 := l_mu_system_rec.ATTRIBUTE13;
    l_txn_sys_rec.ATTRIBUTE14 := l_mu_system_rec.ATTRIBUTE14;
    l_txn_sys_rec.ATTRIBUTE15 := l_mu_system_rec.ATTRIBUTE15;
    l_txn_sys_rec.OBJECT_VERSION_NUMBER := l_mu_system_rec.OBJECT_VERSION_NUMBER;
    l_txn_sys_rec.OPERATING_UNIT_ID := l_mu_system_rec.OPERATING_UNIT_ID;
    l_txn_sys_rec.PROGRAM_APPLICATION_ID := l_mu_system_rec.PROGRAM_APPLICATION_ID;
    l_txn_sys_rec.PROGRAM_ID := l_mu_system_rec.PROGRAM_ID;

    -- To Create System transaction lines in CSI_T_TXN_SYSTEMS
    -- Construct system transaction record
    -- This transaction record is not really used for MU TR processing, but
    -- transactions are created for any future enhacements/tracking
    --
    l_t_txn_sys_rec.TRANSACTION_LINE_ID := l_txn_line_id;
    l_t_txn_sys_rec.SYSTEM_NAME := l_mu_system_tl_rec.NAME;
    l_t_txn_sys_rec.DESCRIPTION := l_mu_system_tl_rec.DESCRIPTION;
    l_t_txn_sys_rec.SYSTEM_TYPE_CODE := l_mu_system_rec.SYSTEM_TYPE_CODE;
    l_t_txn_sys_rec.SYSTEM_NUMBER := l_mu_system_rec.SYSTEM_NUMBER;
    -- Bug 7350165
    l_t_txn_sys_rec.CUSTOMER_ID := l_mu_new_party_rec.AccountId;
    --l_t_txn_sys_rec.CUSTOMER_ID := l_mu_customer_id_rec.CUSTOMER_ID;
    l_t_txn_sys_rec.BILL_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.SHIP_TO_CONTACT_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.TECHNICAL_CONTACT_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.SERVICE_ADMIN_CONTACT_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.SHIP_TO_SITE_USE_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.BILL_TO_SITE_USE_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.INSTALL_SITE_USE_ID := FND_API.G_MISS_NUM;
    l_t_txn_sys_rec.COTERMINATE_DAY_MONTH := l_mu_system_rec.COTERMINATE_DAY_MONTH;
    l_t_txn_sys_rec.START_DATE_ACTIVE := l_mu_system_rec.START_DATE_ACTIVE;
    l_t_txn_sys_rec.END_DATE_ACTIVE := l_mu_system_rec.END_DATE_ACTIVE;
    l_t_txn_sys_rec.CONTEXT := l_txn_line_id;
    l_t_txn_sys_rec.ATTRIBUTE1 := l_mu_system_rec.ATTRIBUTE1;
    l_t_txn_sys_rec.ATTRIBUTE2 := l_mu_system_rec.ATTRIBUTE2;
    l_t_txn_sys_rec.ATTRIBUTE3 := l_mu_system_rec.ATTRIBUTE3;
    l_t_txn_sys_rec.ATTRIBUTE4 := l_mu_system_rec.ATTRIBUTE4;
    l_t_txn_sys_rec.ATTRIBUTE5 := l_mu_system_rec.ATTRIBUTE5;
    l_t_txn_sys_rec.ATTRIBUTE6 := l_mu_system_rec.ATTRIBUTE6;
    l_t_txn_sys_rec.ATTRIBUTE7 := l_mu_system_rec.ATTRIBUTE7;
    l_t_txn_sys_rec.ATTRIBUTE8 := l_mu_system_rec.ATTRIBUTE8;
    l_t_txn_sys_rec.ATTRIBUTE9 := l_mu_system_rec.ATTRIBUTE9;
    l_t_txn_sys_rec.ATTRIBUTE10 := l_mu_system_rec.ATTRIBUTE10;
    l_t_txn_sys_rec.ATTRIBUTE11 := l_mu_system_rec.ATTRIBUTE11;
    l_t_txn_sys_rec.ATTRIBUTE12 := l_mu_system_rec.ATTRIBUTE12;
    l_t_txn_sys_rec.ATTRIBUTE13 := l_mu_system_rec.ATTRIBUTE13;
    l_t_txn_sys_rec.ATTRIBUTE14 := l_mu_system_rec.ATTRIBUTE14;
    l_t_txn_sys_rec.ATTRIBUTE15 := l_mu_system_rec.ATTRIBUTE15;
    l_t_txn_sys_rec.OBJECT_VERSION_NUMBER := l_mu_system_rec.OBJECT_VERSION_NUMBER;

    debug('Creating system t transaction');
    csi_t_txn_systems_pvt.create_txn_system(
      p_api_version                => 1.0,
      p_commit                     => FND_API.G_FALSE,
      p_init_msg_list              => FND_API.G_FALSE,
      p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
      p_txn_system_rec             => l_t_txn_sys_rec,
      x_txn_system_id              => upd_system_tbl(system_rec_ind).SYSTEM_ID,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data
   );

    debug('Calling UPDATE_SYSTEM');
    -- Calling CSI_SYSTEMS_PVT to update the system
    -- with l_txn_sys_rec as the system parameter
    CSI_SYSTEMS_PVT.UPDATE_SYSTEM(
      p_api_version                => 1.0,
      p_commit                     => FND_API.G_FALSE,
      p_init_msg_list              => FND_API.G_FALSE,
      p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
      p_system_rec                 => l_txn_sys_rec,
      p_txn_rec                    => p_txn_rec,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data);

    IF NOT l_return_status = fnd_api.g_ret_sts_success
    THEN
      debug('Error updating systems in PROCESS_SYSTEM_MASS_UPDATE - System ID - ' || upd_system_tbl(system_rec_ind).SYSTEM_ID);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   END LOOP; -- upd_system_tbl

   ELSE -- upd_system_tbl.COUNT > 0
    x_return_status := fnd_api.g_ret_sts_success;
   END IF; -- upd_system_tbl.COUNT > 0

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO PROCESS_SYSTEM_MASS_UPDATE;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO PROCESS_SYSTEM_MASS_UPDATE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
       ROLLBACK TO PROCESS_SYSTEM_MASS_UPDATE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                );
       END IF;
       FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
 END PROCESS_SYSTEM_MASS_UPDATE; -- PROCESS_SYSTEM_MASS_UPDATE

/*----------------------------------------------------*/
/* Procedure name: IDENTIFY_SYSTEM_FOR_UPDATE         */
/* Description :   procedure used to identifies System for */
/*                 mass update batch                  */
/*----------------------------------------------------*/
PROCEDURE IDENTIFY_SYSTEM_FOR_UPDATE
 (
     p_txn_line_id          IN           NUMBER
    ,p_upd_system_tbl      OUT NOCOPY   csi_datastructures_pub.mu_systems_tbl
    ,x_return_status       OUT NOCOPY   VARCHAR2
 )
 IS

  -- Cursors
  CURSOR distinct_system_cur (txn_line_id IN NUMBER) IS
   SELECT distinct cii.system_id system_id
   FROM   csi_t_txn_line_details ctld,
          csi_item_instances cii
   WHERE  ctld.transaction_line_id = txn_line_id
   AND    ctld.INSTANCE_ID is not null
   AND    ctld.preserve_detail_flag = 'Y'
   AND    cii.instance_id = ctld.instance_id;

  l_active_instance_count           NUMBER := 0;
  l_mu_instance_count               NUMBER := 0;
  l_sys_ind                  		    NUMBER := 0;
  l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;


 BEGIN

 debug('Inside IDENTIFY_SYSTEM_FOR_UPDATE');

 FOR l_mu_systems_csr IN distinct_system_cur(p_txn_line_id)
 LOOP
   debug ('System ID - ' || l_mu_systems_csr.system_id);
   IF l_mu_systems_csr.system_id IS NOT NULL THEN
    -- To get the count of active item instances in the system
     SELECT COUNT(1)
     INTO l_active_instance_count
     FROM csi_item_instances cisv,
      CSI_SYSTEMS_B csb
      WHERE cisv.SYSTEM_ID                    = l_mu_systems_csr.system_id
      AND cisv.system_id                      = csb.system_id
      AND NVL(cisv.ACTIVE_END_DATE,sysdate+1) > sysdate
      AND NVL(csb.END_DATE_ACTIVE,sysdate +1) > sysdate;

    debug('Total Active Instance in the System - ' || l_active_instance_count);

    -- To get total instances included in the mass update batch belonging to the system
     SELECT COUNT(1)
       INTO l_mu_instance_count
       FROM csi_t_txn_line_details ctld,
      csi_item_instances cii
      WHERE ctld.transaction_line_id = p_txn_line_id
      AND cii.system_id                = l_mu_systems_csr.system_id
      AND ctld.INSTANCE_ID            IS NOT NULL
      AND ctld.preserve_detail_flag    = 'Y'
      AND cii.instance_id              = ctld.instance_id;

    debug('Total Instances in Batch belonging to System - ' || l_mu_instance_count);

    IF l_mu_instance_count > 0 THEN
      IF l_mu_instance_count = l_active_instance_count THEN
      -- All the active item instances which are part of the system is included in the transfer owner batch
      -- Adding the system id to be updated
      l_sys_ind := l_sys_ind + 1;
      p_upd_system_tbl(l_sys_ind).SYSTEM_ID := l_mu_systems_csr.system_id;
      debug('System Qualifying for Mass Update - ' || l_mu_systems_csr.system_id);
      debug_out('System Qualifying for Mass Update - ' || l_mu_systems_csr.system_id);

      END IF; -- l_mu_instance_count = l_active_instance_count
    END IF; -- l_mu_instance_count > 0
   END IF; -- l_mu_systems_csr.system_id IS NOT NULL
 END LOOP; -- distinct_system_cur(p_txn_line_id)

 debug('Total Number of Systems to be updated - ' || p_upd_system_tbl.COUNT);
 debug_out('Total Number of Systems to be updated - ' || p_upd_system_tbl.COUNT);
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 debug('End IDENTIFY_SYSTEM_FOR_UPDATE');
 EXCEPTION
  WHEN OTHERS THEN
   debug('Exception in IDENTIFY_SYSTEM_FOR_UPDATE');
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END IDENTIFY_SYSTEM_FOR_UPDATE; -- IDENTIFY_SYSTEM_FOR_UPDATE

/*----------------------------------------------------*/
/* Procedure name: VALIDATE_SYSTEM_BATCH               */
/* Description :   procedure to validate systems before*/
/*                  before mass update                 */
/*----------------------------------------------------*/
PROCEDURE VALIDATE_SYSTEM_BATCH
 (
     p_entry_id             IN           NUMBER
    ,p_txn_line_id          IN           NUMBER
    ,p_upd_system_tbl       IN   csi_datastructures_pub.mu_systems_tbl
    ,x_return_status        OUT NOCOPY   VARCHAR2
 )
 IS

 CURSOR SYS_ACCOUNT_CSR (p_entry_id IN NUMBER) IS
 SELECT TA.ACCOUNT_ID ACCOUNT_ID,
        TP.PARTY_SOURCE_ID PARTY_ID
   FROM CSI_T_PARTY_DETAILS TP,
    CSI_T_PARTY_ACCOUNTS TA     ,
    CSI_T_TXN_LINE_DETAILS CTLD ,
    CSI_MASS_EDIT_ENTRIES_VL CMEE
  WHERE CMEE.ENTRY_ID            = p_entry_id
    AND TA.TXN_PARTY_DETAIL_ID   = TP.TXN_PARTY_DETAIL_ID
    AND TP.TXN_LINE_DETAIL_ID    = CTLD.TXN_LINE_DETAIL_ID
    AND CTLD.TRANSACTION_LINE_ID = CMEE.TXN_LINE_ID
    AND CTLD.INSTANCE_ID         IS NOT NULL
    AND ROWNUM                   = 1;

 -- Bug 7350165
 --CURSOR SYS_CUST_CSR (p_party_id IN NUMBER, p_account_number IN NUMBER) IS
 --   SELECT CUST_ACCOUNT_ID  CUSTOMER_ID
 --     FROM HZ_CUST_ACCOUNTS
 --     WHERE PARTY_ID = p_party_id
 --        AND ACCOUNT_NUMBER = p_account_number;

 -- l_sys_cust_rec          SYS_CUST_CSR%ROWTYPE; bug 7350165
 l_sys_acct_rec          SYS_ACCOUNT_CSR%ROWTYPE;
 l_mu_sys_error_tbl      csi_mass_edit_pub.mass_edit_sys_error_tbl;
 l_errors_found              VARCHAR2(1) := 'N';
 l_warnings_found            VARCHAR2(1) := 'N';

 BEGIN

  debug('Inside VALIDATE_SYSTEM_BATCH');

  -- Validation logic
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN   SYS_ACCOUNT_CSR (p_entry_id);
  FETCH  SYS_ACCOUNT_CSR INTO l_sys_acct_rec;
  CLOSE  SYS_ACCOUNT_CSR;

  -- Bug 7350165
  -- Fetch Customer id from party id and account id
 /* BEGIN
    OPEN   SYS_CUST_CSR (l_sys_acct_rec.Party_Id, l_sys_acct_rec.Account_Id);
    FETCH  SYS_CUST_CSR INTO l_sys_cust_rec;
    CLOSE  SYS_CUST_CSR;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('CSI', 'CSI_CUSTOMER_ID_NOT_FOUND');
      fnd_message.set_token('PARTY_ID',l_sys_acct_rec.Party_Id);
      fnd_message.set_token('ACCOUNT_NUMBER',l_sys_acct_rec.Account_Id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;

   WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('CSI', 'CSI_MULTIPLE_CUSTOMER_ID_FOUND');
      fnd_message.set_token('PARTY_ID',l_sys_acct_rec.Party_Id);
      fnd_message.set_token('ACCOUNT_NUMBER',l_sys_acct_rec.Account_Id);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN
      debug('In to Others Exception while finding customer id');
      RAISE FND_API.G_EXC_ERROR;
  END;
  */
  debug('Total Number of Systems qualifying for mass update - ' || p_upd_system_tbl.COUNT);
   IF p_upd_system_tbl.COUNT > 0 THEN
   FOR system_rec_ind IN p_upd_system_tbl.FIRST .. p_upd_system_tbl.LAST
   LOOP

      -- Validate the system with the transaction details
      -- The validation verify whether the system got updated after the batch has been created
      -- Following validations take place
      --
      -- 1. Whether the System is active or not - VLD_SYSTEM_ACTIVE
      -- 2. To check if the current owner of the system matches with the
      --    current owner for the batch - VLD_SYSTEM_CURRENT_OWNER
      -- 3. To check if the transfer ownership date doesnt exceed the sysdate
      --    and system termination date - VLD_SYSTEM_TERM_DATE
      -- 4. To check if the system location ids changed after batch was
      --    scheduled - VLD_SYSTEM_LOCATION_CHGD

      IF NVL(p_upd_system_tbl(system_rec_ind).SYSTEM_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

        -- Whether the System is active or not
        debug('Executing VLD_SYSTEM_ACTIVE');
        CSI_MASS_EDIT_PVT.VLD_SYSTEM_ACTIVE(
                 p_upd_system_tbl(system_rec_ind).SYSTEM_ID,
                 p_txn_line_id,
                 l_mu_sys_error_tbl);

        -- Checking current owner
        debug('Executing VLD_SYSTEM_CURRENT_OWNER');
        CSI_MASS_EDIT_PVT.VLD_SYSTEM_CURRENT_OWNER(
                 p_upd_system_tbl(system_rec_ind).SYSTEM_ID,
                 l_sys_acct_rec.Account_Id,
                 --l_sys_cust_rec.CUSTOMER_ID,
                 p_txn_line_id,
                 l_mu_sys_error_tbl);

        -- Checking Transfer ownerhips date doesnt exceed system termination date
        -- Commented since the system updation happens at sysdate
        -- and VLD_SYSTEM_ACTIVE would have checked this condition
        /*debug('Executing VLD_SYSTEM_TERM_DATE');
        CSI_MASS_EDIT_PVT.VLD_SYSTEM_TERM_DATE(
                 upd_system_tbl(system_rec_ind).SYSTEM_ID,
                 l_mu_sys_error_tbl); */

        -- Checking whether location id/contact id changed after batch was created
        -- This procedure is not implemented for the ER 6031179 as the locations will
        -- be cleared. But this is retained for future enhacenments
        -- This should check to make sure that location id hasnt changed since
        -- the batch was created. If it has changed an error message must be
        -- displayed
        debug('Executing VLD_SYSTEM_LOCATION_CHGD');
        CSI_MASS_EDIT_PVT.VLD_SYSTEM_LOCATION_CHGD(
                 p_upd_system_tbl(system_rec_ind).SYSTEM_ID,
                 p_txn_line_id,
                 l_mu_sys_error_tbl);
      END IF; -- NVL(l_system_rec.system_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   END LOOP; -- system_rec_ind IN
   END IF; -- p_upd_system_tbl.COUNT

   -- Check the Error table
   IF l_mu_sys_error_tbl.count > 0 THEN
    debug('Total Number of errors after system validation: '||l_mu_sys_error_tbl.count);
    FOR f in l_mu_sys_error_tbl.first .. l_mu_sys_error_tbl.last LOOP
      IF (l_mu_sys_error_tbl(f).error_code = fnd_api.g_ret_sts_error AND
         l_errors_found = 'N') THEN
        l_errors_found := 'Y';
        debug('Errors found from system validation');
        debug('Error message: '||substr(l_mu_sys_error_tbl(f).ERROR_TEXT,1,length(l_mu_sys_error_tbl(f).ERROR_TEXT)));

        debug_out('Errors found from system validation');
        debug_out('Error message: '||substr(l_mu_sys_error_tbl(f).ERROR_TEXT,1,length(l_mu_sys_error_tbl(f).ERROR_TEXT)));
      ELSIF (l_mu_sys_error_tbl(f).error_code = 'W' AND
             l_warnings_found = 'N') THEN
        l_warnings_found := 'Y';
        debug('Warnings found from system validation');
        debug('Warning message: '||substr(l_mu_sys_error_tbl(f).ERROR_TEXT,1,length(l_mu_sys_error_tbl(f).ERROR_TEXT)));

        debug_out('Warnings found from system validation');
        debug_out('Warning message: '||substr(l_mu_sys_error_tbl(f).ERROR_TEXT,1,length(l_mu_sys_error_tbl(f).ERROR_TEXT)));

      END IF;
    END LOOP;

    IF (l_errors_found = 'Y' and l_warnings_found = 'Y' OR
        l_errors_found = 'Y' and l_warnings_found = 'N') THEN
      debug('Errors found from VALIDATE_SYSTEM_BATCH and raising FND_API.G_EXC_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_errors_found = 'N' and l_warnings_found = 'Y') THEN
      x_return_status       := 'W';
    END IF;
    debug('Return Status from VALIDATE_SYSTEM_BATCH: '||x_return_status);
    ELSE
        x_return_status := fnd_api.g_ret_sts_success;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          debug('Encountered FND_API.G_EXC_ERROR in VALIDATE_SYSTEM_BATCH');
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN OTHERS THEN
          debug('Encountered WHEN OTHERS in VALIDATE_SYSTEM_BATCH');
          debug( to_char(SQLCODE)||substr(SQLERRM, 1, 255));
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_SYSTEM_BATCH; -- VALIDATE_SYSTEM_BATCH

End CSI_MASS_EDIT_PUB;

/
