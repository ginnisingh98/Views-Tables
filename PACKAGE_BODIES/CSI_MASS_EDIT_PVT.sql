--------------------------------------------------------
--  DDL for Package Body CSI_MASS_EDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_MASS_EDIT_PVT" as
/* $Header: csivmeeb.pls 120.10.12010000.2 2008/11/06 20:32:21 mashah ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSI_MASS_EDIT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivmeeb.pls';

/* local routine to wrap the gen utility debug stuff */

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;


PROCEDURE CREATE_MASS_EDIT_BATCH
   (
    p_api_version               IN   NUMBER,
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
    x_mass_edit_error_tbl       OUT NOCOPY    csi_mass_edit_pub.mass_edit_error_tbl,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  ) IS

    l_api_name               CONSTANT VARCHAR2(30)   := 'CREATE_MASS_EDIT_PVT';
    l_api_version            CONSTANT NUMBER         := 1.0;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1);

    l_txn_line_rec                 csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_detail_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_detail_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_detail_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_ii_rltns_tbl     	   csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_org_assgn_tbl    	   csi_t_datastructures_grp.txn_org_assgn_tbl;
    l_txn_ext_attrib_vals_tbl      csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl              csi_t_datastructures_grp.txn_systems_tbl;
    err_indx                       PLS_INTEGER := 0;
    l_mass_edit_error_tbl          csi_mass_edit_pub.mass_edit_error_tbl;
    l_error_message                VARCHAR2(2000);
    l_msg_index                    NUMBER;
    l_internal_party_id            NUMBER := NULL;


    CURSOR instance_csr (p_ins_id IN NUMBER) IS
    SELECT  *
    FROM    csi_item_instances
    WHERE   instance_id = p_ins_id;

    l_instance_csr    instance_csr%ROWTYPE;

    l_sub_type_id            NUMBER;
    l_instance_party_id      NUMBER;
    l_ip_account_id          NUMBER;

    tld_indx                PLS_INTEGER := 0;
    t_p_indx                PLS_INTEGER := 0;
    t_pa_indx               PLS_INTEGER := 0;
    inst_idx                PLS_INTEGER := 0;
    pty_idx                 PLS_INTEGER := 0;
    ptyacc_idx              PLS_INTEGER := 0;
    l_source_txn_type_id    NUMBER;
    l_source_txn_table      csi_t_transaction_lines.source_transaction_table%type;


  Begin
    -- Standard Start of API savepoint
    SAVEPOINT CREATE_MASS_EDIT_BATCH_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to succcess
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

    g_entry_id   := px_mass_edit_rec.entry_id;
    g_batch_name := px_mass_edit_rec.name;

    --validate the uniqueness of the batch name
    validate_batch_name(p_batch_name => px_mass_edit_rec.name,
                        p_api_name   => 'CREATE_MASS_EDIT_BATCH',
                        x_mass_edit_error_tbl => l_mass_edit_error_tbl);

    -- Validate that the status of the batch is NOT Processed or Successful
    IF nvl(px_mass_edit_rec.status_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
    THEN
           validate_batch_status(p_batch_id  => px_mass_edit_rec.entry_id,
                                 x_mass_edit_error_tbl => l_mass_edit_error_tbl);
    ELSE
           px_mass_edit_rec.status_code := 'CREATED'; -- Default, if not passed
    END IF;

    --validate batchtype
    validate_batch_type(p_batch_type  => px_mass_edit_rec.BATCH_TYPE,
                        p_api_name    => 'CREATE_MASS_EDIT_BATCH',
                        x_sub_type_id => l_sub_type_id,
                        x_mass_edit_error_tbl => l_mass_edit_error_tbl);

    debug('Sub_type_id= '||l_sub_type_id);
    debug('px_mass_edit_inst_tbl count: '||px_mass_edit_inst_tbl.count);

    csi_t_gen_utility_pvt.dump_txn_line_rec(
        p_txn_line_rec => px_txn_line_rec);

    l_source_txn_type_id    := px_txn_line_rec.source_transaction_type_id;
    l_source_txn_table      := px_txn_line_rec.source_transaction_table;

    --check if all the txn_line_detail recs have a instance id
    IF px_mass_edit_inst_tbl.count > 0 THEN
       FOR i IN px_mass_edit_inst_tbl.FIRST .. px_mass_edit_inst_tbl.LAST
       LOOP
         IF NVL(px_mass_edit_inst_tbl(i).instance_id , fnd_api.g_miss_num)
                  = fnd_api.g_miss_num
         THEN
            FND_MESSAGE.set_name('CSI','CSI_MU_MISSING_INSTANCE');
            FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name) ;
            FND_MESSAGE.set_token('TXN_LINE_DETAIL_ID',px_mass_edit_inst_tbl(i).txn_line_detail_id) ;
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => px_mass_edit_inst_tbl(i).instance_id,
                    p_txn_line_detail_id   => px_mass_edit_inst_tbl(i).txn_line_detail_id,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                );
            RAISE FND_API.g_exc_error;
         END IF ;
       END LOOP ;
    END IF;

    csi_t_gen_utility_pvt.dump_mass_edit_rec(px_mass_edit_rec);

    -- Insert row in CSI_MASS_EDIT_ENTRIES table and CSI_T_TRANSACITON_LINES AND CSI_T_TRANSACTION_LINE_DETAILS

   CSI_MASS_EDIT_ENTRIES_B_PKG.Insert_Row(
            px_ENTRY_ID             => px_mass_edit_rec.ENTRY_ID,
            px_TXN_LINE_ID          => px_mass_edit_rec.TXN_LINE_ID,
            px_TXN_LINE_DETAIL_ID   => px_mass_edit_rec.TXN_LINE_DETAIL_ID,
            p_STATUS_CODE           => px_mass_edit_rec.STATUS_CODE,
            p_SCHEDULE_DATE         => px_mass_edit_rec.SCHEDULE_DATE,
            p_START_DATE            => px_mass_edit_rec.START_DATE,
            p_END_DATE              => px_mass_edit_rec.END_DATE,
            p_NAME                  => px_mass_edit_rec.NAME,
            p_BATCH_TYPE            => px_mass_edit_rec.BATCH_TYPE,
            p_DESCRIPTION           => px_mass_edit_rec.DESCRIPTION,
            p_CREATED_BY            => csi_mass_edit_pub.g_user_id,
            p_CREATION_DATE         => sysdate,
            p_LAST_UPDATED_BY       => csi_mass_edit_pub.g_user_id,
            p_LAST_UPDATE_DATE      => sysdate,
            p_LAST_UPDATE_LOGIN     => csi_mass_edit_pub.g_login_id,
            p_OBJECT_VERSION_NUMBER => 1.0,
            p_SYSTEM_CASCADE        => px_mass_edit_rec.SYSTEM_CASCADE
            );


           debug('Mass edit entry id: '||px_mass_edit_rec.ENTRY_ID);
           debug('Transaction line id: '||px_mass_edit_rec.TXN_LINE_ID);
           debug('Transaction line detail id: '||px_mass_edit_rec.TXN_LINE_DETAIL_ID);

      -- query all instances from the px_mass_edit_inst_tbl into the px_txn_line_detail_tbl
      IF px_mass_edit_inst_tbl.count > 0 THEN
          -- Validate the batch first
          csi_mass_edit_pvt.validate_batch (px_mass_edit_rec,
                    'CRT',    -- Create
                    l_mass_edit_error_tbl,
                    l_return_status);

       IF (l_mass_edit_error_tbl.count = 0 OR
           l_return_status = 'W') THEN
         -- Build the data and call the Update transaction details API

         FOR inst_idx IN px_mass_edit_inst_tbl.FIRST .. px_mass_edit_inst_tbl.LAST
         LOOP
             debug('Instance ID('||inst_idx||'): '||px_mass_edit_inst_tbl(inst_idx).instance_id
                   ||' Active End date: '||px_mass_edit_inst_tbl(inst_idx).active_end_date);
             OPEN  instance_csr (px_mass_edit_inst_tbl(inst_idx).instance_id);
             FETCH instance_csr INTO l_instance_csr;
             IF instance_csr%NOTFOUND Then
                CLOSE instance_csr;
                FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_INSTANCE');
                FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name) ;
                FND_MESSAGE.set_token('INSTANCE_ID',px_mass_edit_inst_tbl(inst_idx).instance_id) ;
                log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => px_mass_edit_inst_tbl(inst_idx).instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
               Raise fnd_api.g_exc_error;
             End If;
             CLOSE instance_csr;

            --add the txn_line_id to all records in the detail rec and default the instance_exists flag to 'Y'
             l_txn_line_detail_tbl(inst_idx).transaction_line_id := px_mass_edit_rec.TXN_LINE_ID;
             l_txn_line_detail_tbl(inst_idx).instance_exists_flag := 'Y';
             l_txn_line_detail_tbl(inst_idx).source_transaction_flag := 'Y';
             l_txn_line_detail_tbl(inst_idx).sub_type_id := l_sub_type_id;
             l_txn_line_detail_tbl(inst_idx).instance_id := l_instance_csr.instance_id;
             l_txn_line_detail_tbl(inst_idx).inventory_item_id := l_instance_csr.inventory_item_id;
             l_txn_line_detail_tbl(inst_idx).inv_organization_id := l_instance_csr.last_vld_organization_id;
             l_txn_line_detail_tbl(inst_idx).quantity := l_instance_csr.quantity;
             l_txn_line_detail_tbl(inst_idx).unit_of_measure := l_instance_csr.unit_of_measure;
             l_txn_line_detail_tbl(inst_idx).csi_system_id := l_instance_csr.system_id;
             l_txn_line_detail_tbl(inst_idx).location_type_code := l_instance_csr.location_type_code;
             l_txn_line_detail_tbl(inst_idx).location_id := l_instance_csr.location_id;
             l_txn_line_detail_tbl(inst_idx).install_location_type_code := l_instance_csr.install_location_type_code;
             l_txn_line_detail_tbl(inst_idx).install_location_id := l_instance_csr.install_location_id;
             l_txn_line_detail_tbl(inst_idx).installation_date := l_instance_csr.install_date;
             l_txn_line_detail_tbl(inst_idx).active_end_date := l_instance_csr.active_end_date;
             l_txn_line_detail_tbl(inst_idx).external_reference := l_instance_csr.external_reference;
             l_txn_line_detail_tbl(inst_idx).instance_status_id := l_instance_csr.instance_status_id;
             l_txn_line_detail_tbl(inst_idx).serial_number := l_instance_csr.serial_number;
             l_txn_line_detail_tbl(inst_idx).lot_number := l_instance_csr.lot_number;

             -- Populate the Install Parameters Record
             IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
               csi_gen_utility_pvt.populate_install_param_rec;
             END IF;

             l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

             -- store the current owner party and account information for all the instances in the batch
             --query instance_party_id
             Begin
                SELECT INSTANCE_PARTY_ID
                INTO   l_instance_party_id
                FROM   CSI_I_PARTIES
                WHERE  INSTANCE_ID = l_instance_csr.instance_id and
                       PARTY_ID = l_instance_csr.owner_party_id and
                       PARTY_SOURCE_TABLE = l_instance_csr.owner_party_source_table and
                       RELATIONSHIP_TYPE_CODE = 'OWNER';

                l_txn_party_detail_tbl(pty_idx).instance_party_id := l_instance_party_id;
                l_txn_party_detail_tbl(pty_idx).party_source_id := l_instance_csr.owner_party_id;
                l_txn_party_detail_tbl(pty_idx).party_source_table := l_instance_csr.owner_party_source_table;
                l_txn_party_detail_tbl(pty_idx).relationship_type_code := 'OWNER';
                l_txn_party_detail_tbl(pty_idx).contact_flag := 'N';
                l_txn_party_detail_tbl(pty_idx).txn_line_details_index := inst_idx;

                debug('Checking to see if the Owner Party is an Internal Party from CSI_INSTALL_PARAMETERS');
                debug('Owner Party ID = '||l_instance_csr.owner_party_id);
                debug('Internal Party ID = '||l_internal_party_id);

                --query ip_account_id only if the source is HZ
                IF nvl(l_internal_party_id,99999) <> l_instance_csr.owner_party_id THEN

                  IF (l_instance_csr.owner_party_source_table = 'HZ_PARTIES') THEN
                     SELECT IP_ACCOUNT_ID
                     INTO   l_ip_account_id
                     FROM   CSI_IP_ACCOUNTS
                     WHERE  INSTANCE_PARTY_ID = l_instance_party_id AND
                            RELATIONSHIP_TYPE_CODE = 'OWNER' AND
                            PARTY_ACCOUNT_ID = l_instance_csr.owner_party_account_id;

                     l_txn_pty_acct_detail_tbl(ptyacc_idx).account_id := l_instance_csr.owner_party_account_id;
                     l_txn_pty_acct_detail_tbl(ptyacc_idx).ip_account_id := l_ip_account_id;
                     l_txn_pty_acct_detail_tbl(ptyacc_idx).relationship_type_code := 'OWNER';
                     l_txn_pty_acct_detail_tbl(ptyacc_idx).txn_party_details_index := pty_idx;
                     ptyacc_idx := ptyacc_idx + 1;
                  END IF;
               END IF; -- Check for Internal Party ID
             Exception
               When No_data_found Then
                 -- there has to be only one record here else an exception
                 FND_MESSAGE.set_name('CSI','CSI_INT_INST_OWNER_MISSING');
                 FND_MESSAGE.set_token('INSTANCE_ID',l_instance_csr.instance_id);
                 log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => l_instance_csr.instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
                 RAISE fnd_api.g_exc_error;
               When too_many_rows Then
                 FND_MESSAGE.set_name('CSI','CSI_MANY_INST_OWNER_FOUND');
                 FND_MESSAGE.set_token('INSTANCE_ID',l_instance_csr.instance_id);
                 log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => l_instance_csr.instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
                 RAISE fnd_api.g_exc_error;
               When others Then
                 FND_MESSAGE.set_name('CSI','CSI_API_OWNER_OTHERS_EXCEPTION');
                 log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => l_instance_csr.instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
                 RAISE fnd_api.g_exc_unexpected_error;
             End;

                pty_idx := pty_idx +1;

        END LOOP ;
        --assigning the transaction line values from the  Mass edit table handler call
        l_txn_line_rec.transaction_line_id         := px_mass_edit_rec.txn_line_id;
	l_txn_line_rec.source_transaction_id       := px_mass_edit_rec.ENTRY_ID;
	l_txn_line_rec.object_version_number       := 1.0;

        IF ( ( nvl(l_source_txn_type_id,fnd_api.g_miss_num) = fnd_api.g_miss_num)
         AND (nvl(l_source_txn_table,fnd_api.g_miss_char) = fnd_api.g_miss_char ))
        THEN
           --Default these values for mass update transactions
           l_txn_line_rec.source_transaction_type_id  := '3'; -- SOURCE_TRANSACTION_TYPE_ID for MASS_EDIT is 3
           l_txn_line_rec.source_transaction_table    := 'CSI_MASS_EDIT_ENTRIES';
        ELSE -- source_txn_type_id is not null. external caller
           l_txn_line_rec.source_transaction_type_id  := px_txn_line_rec.source_transaction_type_id;
           l_txn_line_rec.source_transaction_table    := px_txn_line_rec.source_transaction_table;
        END IF;

        tld_indx := nvl(l_txn_line_detail_tbl.LAST,0) + 1;
        l_txn_line_detail_tbl(tld_indx).txn_line_detail_id    := px_mass_edit_rec.txn_line_detail_id;
        l_txn_line_detail_tbl(tld_indx).transaction_line_id   := px_mass_edit_rec.txn_line_id;
        l_txn_line_detail_tbl(tld_indx).object_version_number := 1.0;
        -- Just loop through the child tables passed by the caller to reassign the txn_line_details_index on them
        IF px_txn_party_detail_tbl.count > 0 THEN
           t_p_indx := nvl(l_txn_party_detail_tbl.LAST,0) + 1;
          For pc_ind in px_txn_party_detail_tbl.FIRST .. px_txn_party_detail_tbl.LAST LOOP
           -- since the child tables are always for the dummy line detail and carry the new values, we assign the ID
            px_txn_party_detail_tbl(pc_ind).txn_line_detail_id := px_mass_edit_rec.txn_line_detail_id;
            l_txn_party_detail_tbl(t_p_indx) := px_txn_party_detail_tbl(pc_ind);

             -- Transaction Party account details table
            IF px_txn_pty_acct_detail_tbl.count > 0 THEN
              t_pa_indx := nvl(l_txn_pty_acct_detail_tbl.LAST,0) + 1;
              FOR pac_ind IN px_txn_pty_acct_detail_tbl.FIRST .. px_txn_pty_acct_detail_tbl.LAST
              LOOP
                IF px_txn_pty_acct_detail_tbl(pac_ind).txn_party_details_index = pc_ind THEN
                   px_txn_pty_acct_detail_tbl(pac_ind).txn_party_details_index := t_p_indx;
                   l_txn_pty_acct_detail_tbl(t_pa_indx) := px_txn_pty_acct_detail_tbl(pac_ind);
                   t_pa_indx := t_pa_indx + 1;
                END IF;
              END LOOP;
            END IF;

             -- Resetting the Transaction Party Contacts table
            FOR con_ind IN px_txn_party_detail_tbl.FIRST .. px_txn_party_detail_tbl.LAST
            LOOP
              IF nvl(px_txn_party_detail_tbl(con_ind).contact_flag,fnd_api.g_miss_char) = 'Y' THEN
               IF px_txn_party_detail_tbl(con_ind).contact_party_id = pc_ind THEN
                  px_txn_party_detail_tbl(con_ind).contact_party_id := t_p_indx;
               END IF;
              END IF;
            END LOOP;

            t_p_indx := t_p_indx + 1;

          End Loop;
        END IF;

        IF px_txn_ext_attrib_vals_tbl.count > 0 THEN
          For ea in px_txn_ext_attrib_vals_tbl.FIRST .. px_txn_ext_attrib_vals_tbl.LAST LOOP
          -- since the child tables are always for the dummy line detail and carry the new values, we just reassign it
            l_txn_ext_attrib_vals_tbl(ea).txn_line_detail_id := px_mass_edit_rec.txn_line_detail_id;
          End Loop;
        END IF;
      -- right now we do not process org assignments, txn systems, relationships

        csi_t_txn_details_grp.update_transaction_dtls(
           p_api_version              => p_api_version,
           p_commit                   => fnd_api.g_false,
           p_init_msg_list            => p_init_msg_list,
           p_validation_level         => p_validation_level,
           p_txn_line_rec             => l_txn_line_rec,
           px_txn_line_detail_tbl     => l_txn_line_detail_tbl,
           px_txn_ii_rltns_tbl        => l_txn_ii_rltns_tbl,
           px_txn_party_detail_tbl    => l_txn_party_detail_tbl,
           px_txn_pty_acct_detail_tbl => l_txn_pty_acct_detail_tbl,
           px_txn_org_assgn_tbl       => l_txn_org_assgn_tbl,
           px_txn_ext_attrib_vals_tbl => l_txn_ext_attrib_vals_tbl,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            l_msg_index := 1;
            WHILE l_msg_count > 0 loop

              -- Set Error Table Index
              err_indx := nvl(l_mass_edit_error_tbl.last,0) + 1;

              l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
              l_mass_edit_error_tbl(err_indx).instance_id        := NULL;
              l_mass_edit_error_tbl(err_indx).entry_id           := g_entry_id;
              l_mass_edit_error_tbl(err_indx).name               := g_batch_name;
              l_mass_edit_error_tbl(err_indx).txn_line_detail_id := NULL;
              l_mass_edit_error_tbl(err_indx).error_text         := l_error_message;
              l_mass_edit_error_tbl(err_indx).error_code         := fnd_api.g_ret_sts_error;
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
             RAISE fnd_api.g_exc_error;
          ELSE
             x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          END IF;
       ELSE -- validate batch has errors
         debug('Validate Batch Failed. Pl. check and fix the Errors.');
         RAISE fnd_api.g_exc_error;
       END IF; -- check for batch validate
      END IF; -- px_mass_edit_inst_tbl count > 0

      Debug('CREATE_MASS_EDIT_BATCH API Successfully completed');
       -- Standard call to get message count and IF count is  get message info.
       FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data
           );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO CREATE_MASS_EDIT_BATCH_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          FND_MSG_PUB.Count_And_Get
              (p_count  =>  x_msg_count,
               p_data   =>  x_msg_data
              );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          ROLLBACK TO CREATE_MASS_EDIT_BATCH_PVT;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data
                );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          ROLLBACK TO CREATE_MASS_EDIT_BATCH_PVT;
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

--  validation_routines
    --validate the mass update batch ID/name
  FUNCTION Is_valid_batch (
    p_batch_name        IN  VARCHAR2,
    p_batch_id          IN  NUMBER,
    x_mass_edit_rec     OUT NOCOPY csi_mass_edit_pub.mass_edit_rec)
   RETURN BOOLEAN
  IS

   l_mass_edit_rec   csi_mass_edit_entries_vl%rowtype;
   l_dup_batch_name  NUMBER := NULL;

   CURSOR dup_batch_name (p_batch_id IN NUMBER, p_batch_name IN VARCHAR2) IS
     SELECT 1
     FROM   csi_mass_edit_entries_tl
     WHERE  entry_id <> p_batch_id
     AND    name = p_batch_name;

   BEGIN
    debug('Batch Name: '||p_batch_name||' Batch ID: '||p_batch_id);

    IF nvl(p_batch_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

         SELECT *
         INTO l_mass_edit_rec
         FROM csi_mass_edit_entries_vl
         WHERE entry_id = p_batch_id;

       -- to validate duplicate batch name in an update scenaio...

         IF nvl(p_batch_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
          IF p_batch_name <> l_mass_edit_rec.name THEN

             OPEN dup_batch_name (p_batch_id,p_batch_name);
             FETCH dup_batch_name INTO l_dup_batch_name;
             CLOSE dup_batch_name;

             IF l_dup_batch_name IS NOT NULL THEN
               debug('Duplicate Batch Name: '||p_batch_name||' Batch ID: '||p_batch_id);
               FND_MESSAGE.set_name('CSI','CSI_MU_DUPLICATE_BATCH_NAME');
               FND_MESSAGE.set_token('BATCH_NAME',p_batch_name) ;
               Return FALSE;
             END IF;

          END IF;
         END IF;

    ELSIF nvl(p_batch_name, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN

         SELECT entry_id
               ,name
               ,txn_line_id
               ,batch_type
               ,status_code
               ,schedule_date
         INTO l_mass_edit_rec.entry_id
             ,l_mass_edit_rec.name
             ,l_mass_edit_rec.txn_line_id
             ,l_mass_edit_rec.batch_type
             ,l_mass_edit_rec.status_code
             ,l_mass_edit_rec.schedule_date
         FROM csi_mass_edit_entries_vl
         WHERE name = p_batch_name;

    END IF;

    x_mass_edit_rec.entry_id    := l_mass_edit_rec.entry_id;
    x_mass_edit_rec.name        := l_mass_edit_rec.name;
    x_mass_edit_rec.txn_line_id := l_mass_edit_rec.txn_line_id;
    x_mass_edit_rec.batch_type  := l_mass_edit_rec.batch_type ;
    x_mass_edit_rec.status_code := l_mass_edit_rec.status_code;
    x_mass_edit_rec.schedule_date := l_mass_edit_rec.schedule_date;

    Select txn_line_detail_id
    Into x_mass_edit_rec.txn_line_detail_id
    From csi_t_txn_line_details
    Where transaction_line_id = l_mass_edit_rec.txn_line_id
    And instance_id is null; -- there can be ONLY one record with no instance ID(dummy...)

    Return TRUE;

  EXCEPTION
       WHEN OTHERS THEN
          Return FALSE;
  END Is_valid_batch;

    --validate the uniqueness of the batch name
  PROCEDURE validate_batch_name(
              p_batch_name           IN  VARCHAR2,
              p_api_name             IN  VARCHAR2,
              x_mass_edit_error_tbl  OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl)
  IS
  l_found  VARCHAR2(1) := null;
  BEGIN
    debug('Validating batch name');
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_batch_name,
      p_param_name  => 'px_mass_edit_rec.name',
      p_api_name    => p_api_name);

    BEGIN
              SELECT 'X' INTO l_found
              FROM csi_mass_edit_entries_vl
              WHERE name = p_batch_name;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_found :=null;
    END;

    If(l_found is not null) THEN
      debug('Duplicate batch name');
      Raise fnd_api.g_exc_error;
    END IF;

  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
            FND_MESSAGE.set_name('CSI','CSI_MU_DUPLICATE_BATCH_NAME');
            FND_MESSAGE.set_token('BATCH_NAME',p_batch_name) ;
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
       WHEN OTHERS THEN
      	    fnd_message.set_name('CSI','CSI_INT_UNEXP_SQL_ERROR');
	    fnd_message.set_token('SQL_ERROR',SQLERRM);
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
  END validate_batch_name;

    --validate batchtype
  PROCEDURE validate_batch_type(
              p_batch_type           IN  VARCHAR2,
              p_api_name             IN  VARCHAR2,
              x_sub_type_id          OUT NOCOPY NUMBER ,
              x_mass_edit_error_tbl  OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl)
  IS

   l_sub_type_id            NUMBER        := -1;

  BEGIN
   debug('Validating batch type ');
   csi_t_vldn_routines_pvt.check_reqd_param(
      p_value       => p_batch_type,
      p_param_name  => 'px_mass_edit_rec.BATCH_TYPE',
      p_api_name    => p_api_name);

     SELECT sub_type_id
     INTO   l_sub_type_id
     FROM   CSI_TXN_SUB_TYPES
     WHERE  transaction_type_id = 3
     AND    IB_TXN_TYPE_CODE     = p_batch_type;

     x_sub_type_id := l_sub_type_id;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_TYPE');
            FND_MESSAGE.set_token('BATCH_TYPE',p_batch_type) ;
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
       WHEN OTHERS THEN
      	    fnd_message.set_name('CSI','CSI_INT_UNEXP_SQL_ERROR');
	    fnd_message.set_token('SQL_ERROR',SQLERRM);
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
  END validate_batch_type;

  PROCEDURE validate_batch_status(
    p_batch_id             IN  NUMBER,
    x_mass_edit_error_tbl  OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl)
  IS

  l_status   csi_mass_edit_entries_b.status_code%type  := null;

  BEGIN
    debug('Validating batch status');

    BEGIN

      SELECT status_code
      INTO l_status
      FROM csi_mass_edit_entries_b cmee,
           csi_lookups cl
      WHERE cmee.entry_id = p_batch_id
      AND cmee.status_code = cl.lookup_code
      AND cl.lookup_type = 'CSI_MU_BATCH_STATUSES';

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_status :=null;
          Raise fnd_api.g_exc_unexpected_error;
    END;

    If l_status in ('SUCCESSFUL','PROCESSING') THEN
      debug('Invalid Status for this batch - Cannot be Successful or Processed');
      Raise fnd_api.g_exc_error;
    END IF;

    EXCEPTION
       WHEN fnd_api.g_exc_error THEN
            FND_MESSAGE.set_name('CSI','CSI_MU_BATCH_UPD_DISALLOWED');
            FND_MESSAGE.set_token('BATCH_STATUS',l_status) ;
            FND_MESSAGE.set_token('BATCH_NAME',g_batch_name) ;
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
       WHEN fnd_api.g_exc_unexpected_error THEN
            FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_STATUS');
            FND_MESSAGE.set_token('BATCH_STATUS',l_status) ;
            FND_MESSAGE.set_token('BATCH_NAME',g_batch_name) ;
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
       WHEN OTHERS THEN
      	    fnd_message.set_name('CSI','CSI_INT_UNEXP_SQL_ERROR');
	    fnd_message.set_token('SQL_ERROR',SQLERRM);
            log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => x_mass_edit_error_tbl
                );
            Raise;
  END validate_batch_status;

  PROCEDURE log_mu_error (
    p_index                 IN  NUMBER,
    p_instance_id           IN  NUMBER,
    p_txn_line_detail_id    IN  NUMBER,
    p_error_code            IN  VARCHAR2,
    x_mass_edit_error_tbl   OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl)
  IS
   BEGIN
      debug('logging an error in Mass edit error table');
      x_mass_edit_error_tbl(p_index).entry_id           := g_entry_id;
      x_mass_edit_error_tbl(p_index).name               := g_batch_name;
      x_mass_edit_error_tbl(p_index).txn_line_detail_id := p_txn_line_detail_id;
      x_mass_edit_error_tbl(p_index).instance_id        := p_instance_id;
      x_mass_edit_error_tbl(p_index).error_code         := p_error_code;
      x_mass_edit_error_tbl(p_index).error_text         := fnd_message.get;
  END log_mu_error;


PROCEDURE UPDATE_MASS_EDIT_BATCH (
    p_api_version               IN     NUMBER,
    p_commit                    IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN     NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec            IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_mass_edit_inst_tbl       IN OUT NOCOPY csi_mass_edit_pub.mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    csi_mass_edit_pub.mass_edit_error_tbl,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2) IS

   l_api_version                  NUMBER          := 1.0;
   l_api_name                     VARCHAR2(30)    := 'UPDATE_MASS_EDIT_BATCH_PVT';
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(200);
   l_return_status                VARCHAR2(1);
   l_txn_line_rec                 csi_t_datastructures_grp.txn_line_rec;
   l_txn_line_detail_tbl          csi_t_datastructures_grp.txn_line_detail_tbl;
   l_txn_party_detail_tbl         csi_t_datastructures_grp.txn_party_detail_tbl;
   l_txn_pty_acct_detail_tbl      csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
   l_txn_ii_rltns_tbl    	  csi_t_datastructures_grp.txn_ii_rltns_tbl;
   l_txn_org_assgn_tbl    	  csi_t_datastructures_grp.txn_org_assgn_tbl;
   l_txn_ext_attrib_vals_tbl      csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
   l_txn_systems_tbl              csi_t_datastructures_grp.txn_systems_tbl;
   l_mass_edit_rec                csi_mass_edit_pub.mass_edit_rec;
   err_indx                       PLS_INTEGER := 0;
   tld_idx                        PLS_INTEGER := 0;
   inst_idx                       PLS_INTEGER := 0;
   pty_idx                        PLS_INTEGER := 0;
   ptyacc_idx                     PLS_INTEGER := 0;

   l_mass_edit_error_tbl          csi_mass_edit_pub.mass_edit_error_tbl;
   l_error_message                VARCHAR2(2000);
   l_msg_index                    NUMBER;
   l_sub_type_id                  NUMBER;
   l_create_instance_tdls         VARCHAR2(1) := 'N';
   l_instance_party_id            NUMBER;
   l_ip_account_id                NUMBER;
   l_invalid_operation            VARCHAR2(1) := 'N';
   l_internal_party_id            NUMBER := NULL;

    CURSOR instance_csr (p_ins_id IN NUMBER) IS
      SELECT  *
      FROM    csi_item_instances
      WHERE   instance_id = p_ins_id;

    l_instance_csr  instance_csr%ROWTYPE;

BEGIN
   SAVEPOINT UPDATE_MASS_EDIT_PVT;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to succcess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;
    END IF;

    -- Check required parameters
    csi_t_vldn_routines_pvt.check_reqd_param(
       p_value       => px_mass_edit_rec.entry_id,
       p_param_name  => 'px_mass_edit_rec.entry_id',
       p_api_name    => l_api_name);

    g_entry_id   := px_mass_edit_rec.entry_id;
    g_batch_name := px_mass_edit_rec.name;

    -- Assign the mass edit rec to a local variable so it can be passed to the update row
    l_mass_edit_rec := px_mass_edit_rec;

    IF ( (nvl(px_mass_edit_rec.entry_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num)
      OR ( nvl(px_mass_edit_rec.name, fnd_api.g_miss_char) <> fnd_api.g_miss_char )) THEN

      IF NOT Is_valid_batch (p_batch_name     => g_batch_name,
                             p_batch_id       => g_entry_id,
                             x_mass_edit_rec  => px_mass_edit_rec
                            )
      THEN
        IF nvl(px_mass_edit_rec.entry_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_NAME');
          FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name);
        ELSE
          FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_ID');
          FND_MESSAGE.set_token('BATCH_ID',px_mass_edit_rec.entry_id);
        END IF;

        log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => null,
                    p_txn_line_detail_id   => null,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                );
        Raise fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Check to see if there is an instance id on the detail record if so fail

    IF nvl(px_txn_line_detail_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
     IF nvl(px_txn_line_detail_rec.instance_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        -- trying to provide an instance on the dummy line detail rec for mass update
        l_invalid_operation := 'Y';
        FND_MESSAGE.SET_NAME('CSI','CSI_MU_BATCH_INST_ON_DTL_REC');
        FND_MESSAGE.SET_TOKEN('INSTANCE_ID',px_txn_line_detail_rec.instance_id);
        FND_MESSAGE.SET_TOKEN('TXN_LINE_DETAIL_ID',px_txn_line_detail_rec.txn_line_detail_id);
        FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name);
     ELSIF px_txn_line_detail_rec.txn_line_detail_id <> px_mass_edit_rec.txn_line_detail_id THEN
        l_invalid_operation := 'Y';
        FND_MESSAGE.SET_NAME('CSI','CSI_MU_BATCH_INVALID_DATA');
        FND_MESSAGE.SET_TOKEN('TXN_LINE_DETAIL_ID1',px_mass_edit_rec.txn_line_detail_id);
        FND_MESSAGE.SET_TOKEN('TXN_LINE_DETAIL_ID2',px_txn_line_detail_rec.txn_line_detail_id);
        FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name);
     END IF;
     IF l_invalid_operation = 'Y' THEN
        log_mu_error
                (
                    p_index                => 1,
                    p_instance_id          => px_txn_line_detail_rec.instance_id,
                    p_txn_line_detail_id   => px_txn_line_detail_rec.txn_line_detail_id,
                    p_error_code           => fnd_api.g_ret_sts_error,
                    x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                );
        RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;

    csi_t_gen_utility_pvt.dump_mass_edit_rec(px_mass_edit_rec);

    -- Validate that the status of the batch is NOT Processed or Successful
    validate_batch_status(p_batch_id  => px_mass_edit_rec.entry_id,
                          x_mass_edit_error_tbl => l_mass_edit_error_tbl);

   debug('txn_line_detail_id: '||px_txn_line_detail_rec.txn_line_detail_id);
   debug('px_txn_party_detail_tbl Count:    '||px_txn_party_detail_tbl.count);
   debug('px_txn_pty_acct_detail_tbl Count: '||px_txn_pty_acct_detail_tbl.count);
   debug('px_txn_ext_attrib_vals_tbl Count: '||px_txn_ext_attrib_vals_tbl.count);

   IF (px_mass_edit_inst_tbl.count > 0 OR
       nvl(px_txn_line_detail_rec.txn_line_detail_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num) THEN
     IF (px_txn_party_detail_tbl.count > 0 OR
         px_txn_pty_acct_detail_tbl.count > 0 OR
         px_txn_ext_attrib_vals_tbl.count > 0) THEN
         csi_t_vldn_routines_pvt.check_reqd_param(
            p_value       => px_txn_line_detail_rec.txn_line_detail_id,
            p_param_name  => 'px_txn_line_detail_rec.txn_line_detail_id',
            p_api_name    => l_api_name);
     END IF;

     -- assign all the required local pl/sql tables for calling the transaction details API
      l_txn_line_rec                  := px_txn_line_rec;
      -- added the IF below for bug 4769442
      IF nvl(l_txn_line_rec.source_transaction_type_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
      THEN
           --Default this seeded value for mass update transactions
           l_txn_line_rec.source_transaction_type_id  := '3'; -- SOURCE_TRANSACTION_TYPE_ID for MASS_EDIT is 3
      END IF;


      IF nvl(px_txn_line_detail_rec.txn_line_detail_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
           l_txn_line_detail_tbl(tld_idx)  := px_txn_line_detail_rec;
           l_txn_party_detail_tbl          := px_txn_party_detail_tbl;
           l_txn_pty_acct_detail_tbl       := px_txn_pty_acct_detail_tbl;
           l_txn_ext_attrib_vals_tbl       := px_txn_ext_attrib_vals_tbl;
           tld_idx := nvl(l_txn_line_detail_tbl.last,0) + 1;
           pty_idx := nvl(l_txn_party_detail_tbl.last,0) + 1;
           ptyacc_idx := nvl(l_txn_pty_acct_detail_tbl.last,0) + 1;
      END IF;

      csi_t_gen_utility_pvt.dump_txn_tables(
        p_ids_or_index_based => 'I',
        p_line_detail_tbl    => l_txn_line_detail_tbl,
        p_party_detail_tbl   => l_txn_party_detail_tbl,
        p_pty_acct_tbl       => l_txn_pty_acct_detail_tbl,
        p_ii_rltns_tbl       => l_txn_ii_rltns_tbl,
        p_org_assgn_tbl      => l_txn_org_assgn_tbl,
        p_ea_vals_tbl        => l_txn_ext_attrib_vals_tbl);


     IF px_mass_edit_inst_tbl.count > 0 THEN
      FOR i IN px_mass_edit_inst_tbl.FIRST .. px_mass_edit_inst_tbl.LAST LOOP
        IF nvl(px_mass_edit_inst_tbl(i).txn_line_detail_id,fnd_api.g_miss_num) =  fnd_api.g_miss_num THEN
           l_create_instance_tdls := 'Y';
           validate_batch_type(p_batch_type  => px_mass_edit_rec.BATCH_TYPE,
                            p_api_name       => 'UPDATE_MASS_EDIT_BATCH',
                            x_sub_type_id    => l_sub_type_id,
                            x_mass_edit_error_tbl  => l_mass_edit_error_tbl);
           exit;
        END IF;
      END LOOP;
     END IF;

     debug('l_create_instance_tdls flag: '||l_create_instance_tdls);

      IF l_create_instance_tdls = 'N' THEN
          csi_mass_edit_pvt.validate_batch (px_mass_edit_rec,
                                            'UPD',    -- Update
                                            l_mass_edit_error_tbl,
                                            l_return_status);
      END IF;

      debug('Done validating batch, no. of errors: '||l_mass_edit_error_tbl.count);
      debug('Return status: '||l_return_status);

    IF (l_mass_edit_error_tbl.count = 0 OR
        l_return_status = 'W') THEN
     IF px_mass_edit_inst_tbl.count > 0 THEN
      FOR inst_idx IN px_mass_edit_inst_tbl.FIRST .. px_mass_edit_inst_tbl.LAST LOOP
        IF nvl(px_mass_edit_inst_tbl(inst_idx).txn_line_detail_id, fnd_api.g_miss_num)
           = fnd_api.g_miss_num
        THEN
             debug('px_mass_edit_inst_tbl('||inst_idx||').instance_id = '
                    ||px_mass_edit_inst_tbl(inst_idx).instance_id);
             OPEN  instance_csr (px_mass_edit_inst_tbl(inst_idx).instance_id);
             FETCH instance_csr INTO l_instance_csr;
             IF instance_csr%NOTFOUND Then
                CLOSE instance_csr;
                FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_INSTANCE');
                FND_MESSAGE.set_token('INSTANCE_ID',px_mass_edit_inst_tbl(inst_idx).instance_id) ;
                FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name);
                log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => px_mass_edit_inst_tbl(inst_idx).instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
               Raise fnd_api.g_exc_error;
             End If;
             CLOSE instance_csr;
            --add the txn_line_id to all records in the detail rec and default the instance_exists flag to 'Y'
             l_txn_line_rec.SOURCE_TRANSACTION_ID       := px_mass_edit_rec.entry_id;
             l_txn_line_rec.SOURCE_TRANSACTION_TABLE    := 'CSI_MASS_EDIT_ENTRIES';
             l_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID  := 3;
             l_txn_line_detail_tbl(tld_idx).transaction_line_id := px_mass_edit_rec.TXN_LINE_ID;
             l_txn_line_detail_tbl(tld_idx).instance_exists_flag := 'Y';
             l_txn_line_detail_tbl(tld_idx).source_transaction_flag := 'Y';
             l_txn_line_detail_tbl(tld_idx).sub_type_id := l_sub_type_id;
             l_txn_line_detail_tbl(tld_idx).instance_id := l_instance_csr.instance_id;
             l_txn_line_detail_tbl(tld_idx).inventory_item_id := l_instance_csr.inventory_item_id;
             l_txn_line_detail_tbl(tld_idx).inv_organization_id := l_instance_csr.last_vld_organization_id;
             l_txn_line_detail_tbl(tld_idx).quantity := l_instance_csr.quantity;
             l_txn_line_detail_tbl(tld_idx).unit_of_measure := l_instance_csr.unit_of_measure;
             l_txn_line_detail_tbl(tld_idx).csi_system_id := l_instance_csr.system_id;
             l_txn_line_detail_tbl(tld_idx).location_type_code := l_instance_csr.location_type_code;
             l_txn_line_detail_tbl(tld_idx).location_id := l_instance_csr.location_id;
             l_txn_line_detail_tbl(tld_idx).install_location_type_code := l_instance_csr.install_location_type_code;
             l_txn_line_detail_tbl(tld_idx).install_location_id := l_instance_csr.install_location_id;
             l_txn_line_detail_tbl(tld_idx).installation_date := l_instance_csr.install_date;
             l_txn_line_detail_tbl(tld_idx).active_end_date := l_instance_csr.active_end_date;
             l_txn_line_detail_tbl(tld_idx).external_reference := l_instance_csr.external_reference;
             l_txn_line_detail_tbl(tld_idx).instance_status_id := l_instance_csr.instance_status_id;
             l_txn_line_detail_tbl(tld_idx).serial_number := l_instance_csr.serial_number;
             l_txn_line_detail_tbl(tld_idx).lot_number := l_instance_csr.lot_number;

             -- Populate the Install Parameters Record
             IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
               csi_gen_utility_pvt.populate_install_param_rec;
             END IF;

             l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;

             -- store the current owner party and account information for all the instances in the batch
             --query instance_party_id
             Begin
                SELECT INSTANCE_PARTY_ID
                INTO   l_instance_party_id
                FROM   CSI_I_PARTIES
                WHERE  INSTANCE_ID = l_instance_csr.instance_id and
                       PARTY_ID = l_instance_csr.owner_party_id and
                       PARTY_SOURCE_TABLE = l_instance_csr.owner_party_source_table and
                       RELATIONSHIP_TYPE_CODE = 'OWNER';

                l_txn_party_detail_tbl(pty_idx).instance_party_id := l_instance_party_id;
                l_txn_party_detail_tbl(pty_idx).party_source_id := l_instance_csr.owner_party_id;
                l_txn_party_detail_tbl(pty_idx).party_source_table := l_instance_csr.owner_party_source_table;
                l_txn_party_detail_tbl(pty_idx).relationship_type_code := 'OWNER';
                l_txn_party_detail_tbl(pty_idx).contact_flag := 'N';
                l_txn_party_detail_tbl(pty_idx).txn_line_details_index := tld_idx;

                debug('Checking to see if the Owner Party is an Internal Party from CSI_INSTALL_PARAMETERS');
                debug('Owner Party ID = '||l_instance_csr.owner_party_id);
                debug('Internal Party ID = '||l_internal_party_id);

                --query ip_account_id only if the source is HZ
                IF nvl(l_internal_party_id,99999) <> l_instance_csr.owner_party_id THEN

                  IF (l_instance_csr.owner_party_source_table = 'HZ_PARTIES') THEN
                     SELECT IP_ACCOUNT_ID
                     INTO   l_ip_account_id
                     FROM   CSI_IP_ACCOUNTS
                     WHERE  INSTANCE_PARTY_ID = l_instance_party_id AND
                            RELATIONSHIP_TYPE_CODE = 'OWNER' AND
                            PARTY_ACCOUNT_ID = l_instance_csr.owner_party_account_id;

                     l_txn_pty_acct_detail_tbl(ptyacc_idx).account_id := l_instance_csr.owner_party_account_id;
                     l_txn_pty_acct_detail_tbl(ptyacc_idx).ip_account_id := l_ip_account_id;
                     l_txn_pty_acct_detail_tbl(ptyacc_idx).relationship_type_code := 'OWNER';
                     l_txn_pty_acct_detail_tbl(ptyacc_idx).txn_party_details_index := pty_idx;
                     ptyacc_idx := ptyacc_idx + 1;
                  END IF;
                END IF; -- Check for Internal Party ID
                tld_idx := tld_idx + 1;
             EXCEPTION
               When No_data_found Then
                 -- there has to be only one record here else an exception
                 FND_MESSAGE.set_name('CSI','CSI_INT_INST_OWNER_MISSING');
                 FND_MESSAGE.set_token('INSTANCE_ID',l_instance_csr.instance_id);
                 log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => l_instance_csr.instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
                 RAISE fnd_api.g_exc_error;
               When too_many_rows Then
                 FND_MESSAGE.set_name('CSI','CSI_MANY_INST_OWNER_FOUND');
                 FND_MESSAGE.set_token('INSTANCE_ID',l_instance_csr.instance_id);
                 log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => l_instance_csr.instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
                 RAISE fnd_api.g_exc_error;
               When others Then
                 FND_MESSAGE.set_name('CSI','CSI_API_OWNER_OTHERS_EXCEPTION');
                 log_mu_error
                    (
                        p_index                => nvl(l_mass_edit_error_tbl.last, 0) + 1,
                        p_instance_id          => l_instance_csr.instance_id,
                        p_txn_line_detail_id   => null,
                        p_error_code           => fnd_api.g_ret_sts_error,
                        x_mass_edit_error_tbl  => l_mass_edit_error_tbl
                    );
                 RAISE fnd_api.g_exc_unexpected_error;
             End;
             pty_idx := pty_idx +1;
        ELSE -- if line_detail_id = g_miss_num
           -- Setting txn line detail, active end date and object version number only for updates
           l_txn_line_detail_tbl(tld_idx).txn_line_detail_id    :=
                      px_mass_edit_inst_tbl(inst_idx).txn_line_detail_id;
           l_txn_line_detail_tbl(tld_idx).transaction_line_id    :=
                      px_mass_edit_rec.txn_line_id;
           l_txn_line_detail_tbl(tld_idx).active_end_date       :=
                      px_mass_edit_inst_tbl(inst_idx).active_end_date;
           l_txn_line_detail_tbl(tld_idx).object_version_number :=
                      px_mass_edit_inst_tbl(inst_idx).object_version_number;

           tld_idx := nvl(l_txn_line_detail_tbl.last,0) + 1;
           debug('Setting the active and date and object version number and incrementing index for deleted rows - PL/SQL Table Row: '||tld_idx);

        END IF;
      END LOOP ; -- mass_edit_inst loop
     END IF; -- mass_edit_inst.count > 0

    --  call the Update API
        debug('Calling csi_t_txn_details_grp.update_transaction_dtls API');
        csi_t_gen_utility_pvt.dump_txn_line_rec(l_txn_line_rec);
        debug('l_txn_line_detail_tbl count:     '||l_txn_line_detail_tbl.count);
        debug('l_txn_party_detail_tbl count:    '||l_txn_party_detail_tbl.count);
        debug('l_txn_pty_acct_detail_tbl count: '||l_txn_pty_acct_detail_tbl.count);

        csi_t_txn_details_grp.update_transaction_dtls(
           p_api_version              => p_api_version,
           p_commit                   => fnd_api.g_false,
           p_init_msg_list            => p_init_msg_list,
           p_validation_level         => p_validation_level,
           p_txn_line_rec             => l_txn_line_rec,
           px_txn_line_detail_tbl     => l_txn_line_detail_tbl,
           px_txn_ii_rltns_tbl        => l_txn_ii_rltns_tbl,
           px_txn_party_detail_tbl    => l_txn_party_detail_tbl,
           px_txn_pty_acct_detail_tbl => l_txn_pty_acct_detail_tbl,
           px_txn_org_assgn_tbl       => l_txn_org_assgn_tbl,
           px_txn_ext_attrib_vals_tbl => l_txn_ext_attrib_vals_tbl,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          l_msg_index := 1;
          WHILE l_msg_count > 0 loop

            -- Set Error Table Index
            err_indx := nvl(l_mass_edit_error_tbl.last,0) + 1;

            l_error_message := l_error_message || fnd_msg_pub.get(l_msg_index,FND_API.G_FALSE);
            l_mass_edit_error_tbl(err_indx).instance_id        := NULL;
            l_mass_edit_error_tbl(err_indx).entry_id           := g_entry_id;
            l_mass_edit_error_tbl(err_indx).txn_line_detail_id := NULL;
            l_mass_edit_error_tbl(err_indx).error_text         := l_error_message;
            l_mass_edit_error_tbl(err_indx).error_code         := fnd_api.g_ret_sts_error;
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
            err_indx := err_indx + 1;
           END LOOP;
           RAISE fnd_api.g_exc_error;
        ELSE
            x_mass_edit_error_tbl := l_mass_edit_error_tbl;
        END IF;

        IF l_create_instance_tdls = 'Y' THEN
         debug('Calling validate_batch after updating txn details');
          csi_mass_edit_pvt.validate_batch (px_mass_edit_rec,
                                            'UPD',    -- Update
                                            l_mass_edit_error_tbl,
                                            l_return_status);

          debug('Done validating batch, no. of errors: '||l_mass_edit_error_tbl.count);
          debug('Return status: '||l_return_status);

          IF (l_return_status = 'E') THEN
           RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

    ELSE -- Validate Batch returned errors and they were errors and warnings
        debug('Validate Batch Failed. Pl. check and fix the Errors.');
        RAISE FND_API.G_EXC_ERROR;
    END IF; -- Check return of Validate Batch
  END IF; -- IF mass edit inst tbl.count OR line_detail_rec exists

 -- calling table handler at the end to handle cases where only mu rec is updated in a batch
  CSI_MASS_EDIT_ENTRIES_B_PKG.update_Row(
             p_ENTRY_ID              => px_mass_edit_rec.ENTRY_ID,
             p_TXN_LINE_ID           => px_mass_edit_rec.TXN_LINE_ID,
             p_STATUS_CODE           => l_mass_edit_rec.STATUS_CODE,
             p_SCHEDULE_DATE         => l_mass_edit_rec.SCHEDULE_DATE,
             p_START_DATE            => l_mass_edit_rec.START_DATE,
             p_END_DATE              => l_mass_edit_rec.END_DATE,
             p_NAME                  => l_mass_edit_rec.NAME,
             p_CREATED_BY            => fnd_api.g_miss_num,
             p_CREATION_DATE         => fnd_api.g_miss_date,
             p_LAST_UPDATED_BY       => csi_mass_edit_pub.g_user_id,
             p_LAST_UPDATE_DATE      => sysdate,
             p_LAST_UPDATE_LOGIN     => csi_mass_edit_pub.g_login_id,
             p_OBJECT_VERSION_NUMBER => l_mass_edit_rec.OBJECT_VERSION_NUMBER,
             p_DESCRIPTION           => l_mass_edit_rec.DESCRIPTION,
             p_BATCH_TYPE            => px_mass_edit_rec.BATCH_TYPE,
             p_SYSTEM_CASCADE        => l_mass_edit_rec.SYSTEM_CASCADE
            );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO update_mass_edit_pvt;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_mass_edit_error_tbl := l_mass_edit_error_tbl;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO update_mass_edit_pvt;

          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data
                );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          debug( to_char(SQLCODE)||substr(SQLERRM, 1, 255));
          ROLLBACK TO update_mass_edit_pvt;
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

END UPDATE_MASS_EDIT_BATCH;

PROCEDURE DELETE_MASS_EDIT_BATCH
   (
    p_api_version               IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_mass_edit_rec          	IN  csi_mass_edit_pub.mass_edit_rec,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  ) IS

    l_api_version             NUMBER          := 1.0;
    l_api_name                VARCHAR2(30)    := 'DELETE_MASS_EDIT_BATCH';
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_return_status           VARCHAR2(1);
    l_mass_edit_rec           csi_mass_edit_pub.mass_edit_rec;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_mass_edit_batch_pvt;

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

     -- Validate the Batch
  IF ( (nvl(p_mass_edit_rec.entry_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num)
    OR ( nvl(p_mass_edit_rec.name, fnd_api.g_miss_char) = fnd_api.g_miss_char ))
  THEN

    IF NOT Is_valid_batch (p_batch_name     => p_mass_edit_rec.name,
                           p_batch_id       => p_mass_edit_rec.entry_id,
                           x_mass_edit_rec  => l_mass_edit_rec
                          )
    THEN
       IF nvl(p_mass_edit_rec.entry_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
          FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_NAME');
          FND_MESSAGE.set_token('BATCH_NAME',p_mass_edit_rec.name);
       ELSE
          FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_ID');
          FND_MESSAGE.set_token('BATCH_ID',p_mass_edit_rec.entry_id);
       END IF;
       FND_MSG_PUB.add;
       Raise fnd_api.g_exc_error;
    END IF;
    IF nvl(l_mass_edit_rec.status_code, 'CREATED') = 'PROCESSING' THEN
          debug('Cannot Delete a Batch that is being Processed: '||l_mass_edit_rec.status_code);
          FND_MESSAGE.set_name('CSI','CSI_MU_BATCH_UPD_DISALLOWED');
          FND_MESSAGE.set_token('BATCH_NAME',l_mass_edit_rec.name);
          FND_MESSAGE.set_token('BATCH_STATUS',l_mass_edit_rec.status_code) ;
          FND_MSG_PUB.add;
          Raise fnd_api.g_exc_error;
    END IF;
  END IF;

  csi_t_txn_details_grp.delete_transaction_dtls (
         p_api_version            => p_api_version,
         p_commit                 => p_commit,
         p_init_msg_list          => p_init_msg_list,
         p_validation_level       => p_validation_level,
         p_transaction_line_id    => l_mass_edit_rec.txn_line_id,
         x_return_status          => l_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data
        );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

 -- call table handler to delete mass edit entry

    csi_mass_edit_entries_b_pkg.delete_row(
      p_entry_id => l_mass_edit_rec.entry_id);

 -- call Service contracts API to delete the contracts rules, if any.

    OKS_IBINT_PUB.DELETE_BATCH(
            p_api_version   => 1.0,
            p_init_msg_list => 'F',
            p_batch_id      => l_mass_edit_rec.entry_id,
            x_return_status => l_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data);

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

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Delete_Mass_Edit_Batch_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Mass_Edit_Batch_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Delete_Mass_Edit_Batch_pvt;
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


  PROCEDURE GET_MASS_EDIT_DETAILS (
    p_api_version          	IN  NUMBER,
    p_commit               	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     	IN  NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN  OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
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
    l_txn_line_query_rec      csi_t_datastructures_grp.txn_line_query_rec ;
    l_txn_line_detail_query_rec csi_t_datastructures_grp.txn_line_detail_query_rec ;
    x_tmp_ii_rltns_tbl        csi_t_datastructures_grp.txn_ii_rltns_tbl ;
    x_tmp_org_assgn_tbl       csi_t_datastructures_grp.txn_org_assgn_tbl ;
    x_tmp_ext_attribs_tbl     csi_t_datastructures_grp.csi_ext_attribs_tbl ;
    x_tmp_iea_values_tbl      csi_t_datastructures_grp.csi_ext_attrib_vals_tbl ;
    x_tmp_systems_tbl         csi_t_datastructures_grp.txn_systems_tbl ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT get_mass_edit_details_pvt;

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

    -- Assign Txn Line query attributes (Get txn details) for the Mass Update

       IF px_mass_edit_rec.txn_line_id IS NOT NULL
         OR px_mass_edit_rec.txn_line_id <> fnd_api.g_miss_num
       THEN
           l_txn_line_query_rec.transaction_line_id := px_mass_edit_rec.txn_line_id ;
           l_txn_line_detail_query_rec.transaction_line_id := px_mass_edit_rec.txn_line_id ;
       END IF ;

       IF px_mass_edit_rec.entry_id IS NOT NULL
         OR px_mass_edit_rec.entry_id <> fnd_api.g_miss_num
       THEN
           l_txn_line_query_rec.source_transaction_id := px_mass_edit_rec.entry_id ;
           l_txn_line_query_rec.source_transaction_type_id := 3 ;
           l_txn_line_query_rec.source_transaction_table := 'CSI_MASS_EDIT_ENTRIES' ;
       END IF ;

     -- Validate the Batch
       IF ( (nvl(px_mass_edit_rec.entry_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num)
         OR ( nvl(px_mass_edit_rec.name, fnd_api.g_miss_char) = fnd_api.g_miss_char ))
       THEN

         IF NOT Is_valid_batch (p_batch_name     => px_mass_edit_rec.name,
                                p_batch_id       => px_mass_edit_rec.entry_id,
                                x_mass_edit_rec  => px_mass_edit_rec
                               )
         THEN
            IF nvl(px_mass_edit_rec.entry_id, fnd_api.g_miss_num) = fnd_api.g_miss_num THEN
               FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_NAME');
               FND_MESSAGE.set_token('BATCH_NAME',px_mass_edit_rec.name);
            ELSE
               FND_MESSAGE.set_name('CSI','CSI_MU_INVALID_BATCH_ID');
               FND_MESSAGE.set_token('BATCH_ID',px_mass_edit_rec.entry_id);
            END IF;

            FND_MSG_PUB.add;
            Raise fnd_api.g_exc_error;
         END IF;
       END IF;

        csi_t_txn_details_grp.get_transaction_details(
               p_api_version              => p_api_version,
               p_commit                   => p_commit,
               p_init_msg_list            => p_init_msg_list,
               p_validation_level         => p_validation_level,
               p_txn_line_query_rec       => l_txn_line_query_rec,
               p_txn_line_detail_query_rec => l_txn_line_detail_query_rec,
               x_txn_line_detail_tbl      => x_txn_line_detail_tbl,
               p_get_parties_flag         => 'Y',
               x_txn_party_detail_tbl     => x_txn_party_detail_tbl,
               p_get_pty_accts_flag       => 'Y',
               x_txn_pty_acct_detail_tbl  => x_txn_pty_acct_detail_tbl,
               p_get_ext_attrib_vals_flag => 'Y',
               x_txn_ext_attrib_vals_tbl  => x_txn_ext_attrib_vals_tbl,
               p_get_ii_rltns_flag        => 'N',
               x_txn_ii_rltns_tbl         => x_tmp_ii_rltns_tbl,
               p_get_org_assgns_flag      => 'N',
               x_txn_org_assgn_tbl        => x_tmp_org_assgn_tbl,
               p_get_csi_attribs_flag     => 'N',
               x_csi_ext_attribs_tbl      => x_tmp_ext_attribs_tbl,
               p_get_csi_iea_values_flag  => 'N',
               x_csi_iea_values_tbl       => x_tmp_iea_values_tbl,
               p_get_txn_systems_flag     => 'N',
               x_txn_systems_tbl          => x_tmp_systems_tbl,
               x_return_status            => l_return_status,
               x_msg_count                => l_msg_count,
               x_msg_data                 => l_msg_data);

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

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Get_mass_edit_details_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Get_mass_edit_details_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

      csi_t_gen_utility_pvt.set_debug_off;

    WHEN OTHERS THEN

      ROLLBACK TO Get_mass_edit_details_pvt;
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

PROCEDURE vld_item_instance_active (p_instance_id_tab          IN NumTabType,
                                    p_txn_line_detail_id_tab   IN NumTabType,
                                    px_mass_edit_error_tbl      IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

  e_indx                    NUMBER := 0;
  l_inst_active             NUMBER := NULL;


  CURSOR inst_active (pc_instance_id IN NUMBER) IS
  SELECT 1
  FROM   csi_item_instances
  WHERE  instance_id = pc_instance_id
  AND    (active_end_date is NULL OR
        nvl(active_end_date, sysdate+1) > sysdate);

BEGIN
  -- Set Error Table Index
  e_indx := nvl(px_mass_edit_error_tbl.last,0) + 1;

  FOR ind IN 1 .. p_instance_id_tab.COUNT LOOP

    OPEN inst_active(p_instance_id_tab(ind));
    FETCH inst_active INTO l_inst_active;
    CLOSE inst_active;

    IF l_inst_active is NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_MU_INACTIVE_INSTANCE');
      FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
      FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
      px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
      px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
      px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
      px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
      px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
      px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
      e_indx := e_indx + 1;
  END IF;

  END LOOP;
  debug('  Error Table Count when exiting vld_item_instance active is: '||px_mass_edit_error_tbl.count);

END vld_item_instance_active;

PROCEDURE vld_batch_inst_same_owner(p_txn_line_id_tab      IN NumTabType,
                                    px_mass_edit_error_tbl  IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

    TYPE NumTabType is  varray(10000) of number;

    l_account_id_tab            NumTabType;
    l_party_source_id_tab       NumTabType;
    l_party_source_table_tab    Char30TabType;
    l_transaction_line_id_tab   NumTabType;
    l_txn_line_detail_id_tab    NumTabType;
    l_txn_party_detail_id_tab   NumTabType;
    l_instance_id_tab           NumTabType;
    l_old_party_id              NUMBER := NULL;
    l_old_account_id            NUMBER := NULL;
    e_indx                      NUMBER := 0;

    MAX_BUFFER_SIZE      number := 1000;

    CURSOR party_csr (pc_txn_line_id IN NUMBER) IS
      SELECT cil.transaction_line_id  transaction_line_id
            ,cid.party_source_id      party_id
            ,cid.party_source_table   party_source_table
            ,cil.txn_line_detail_id   txn_line_detail_id
            ,cil.instance_id          instance_id
            ,cid.txn_party_detail_id  txn_party_detail_id
      FROM  csi_t_txn_line_details cil
           ,csi_t_party_details cid
      WHERE cil.transaction_line_id = pc_txn_line_id
      AND   cil.instance_id IS NOT NULL
      AND   cid.txn_line_detail_id = cil.txn_line_detail_id
      AND   cid.relationship_type_code = 'OWNER';

    CURSOR account_csr (pc_txn_line_id IN NUMBER,
                        pc_txn_party_detail_id IN NUMBER) IS
     SELECT cia.account_id
      FROM  csi_t_txn_line_details cil
           ,csi_t_party_details cid
           ,csi_t_party_accounts cia
      WHERE cil.transaction_line_id = pc_txn_line_id
      AND   cil.instance_id IS NOT NULL
      AND   cid.txn_line_detail_id = cil.txn_line_detail_id
      AND   cid.relationship_type_code = 'OWNER'
      AND   cid.txn_party_detail_id = cia.txn_party_detail_id
      AND   cia.txn_party_detail_id = pc_txn_party_detail_id;

  BEGIN
    -- Set Error Table Index
    e_indx := nvl(px_mass_edit_error_tbl.last,0) + 1;

    --FOR i IN 1 .. p_txn_line_id_tab.COUNT LOOP

    IF p_txn_line_id_tab.COUNT > 0 THEN
    debug('Count of Main transaction line id tbl: '||p_txn_line_id_tab.count);
    debug('Transaction line id  '||p_txn_line_id_tab(1));

    OPEN party_csr(p_txn_line_id_tab(1));
    LOOP

      FETCH party_csr BULK COLLECT
      INTO  l_transaction_line_id_tab,
            l_party_source_id_tab,
            l_party_source_table_tab,
            l_txn_line_detail_id_tab,
            l_instance_id_tab,
            l_txn_party_detail_id_tab
      LIMIT MAX_BUFFER_SIZE;

    FOR ind IN 1 .. l_transaction_line_id_tab.COUNT LOOP
      l_old_party_id := l_party_source_id_tab(1);

      debug('Count of transaction line id tbl: '||l_transaction_line_id_tab.count);
      debug('Old Party ID: '||l_old_party_id);
      debug('New Party Source ID: '||l_party_source_id_tab(ind));

      IF l_old_party_id <> l_party_source_id_tab(ind) THEN
        debug('This instance party id does not match the other instances in the batch: '||l_instance_id_tab(ind));
        FND_MESSAGE.SET_NAME('CSI','CSI_MU_BATCH_DIFF_OWNER_PTY');
        FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
        FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_instance_id_tab(ind));
        px_mass_edit_error_tbl(e_indx).instance_id        := l_instance_id_tab(ind);
        px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
        px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
        px_mass_edit_error_tbl(e_indx).txn_line_detail_id := l_txn_line_detail_id_tab(ind);
        px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
        px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
        e_indx := e_indx + 1;
      END IF;

      IF l_party_source_table_tab(ind) = 'HZ_PARTIES' THEN

        OPEN account_csr(p_txn_line_id_tab(1),
                        l_txn_party_detail_id_tab(ind));
        LOOP

          debug('Party Detail ID for Account: '||l_txn_party_detail_id_tab(ind));
          FETCH account_csr BULK COLLECT
          INTO  l_account_id_tab
          LIMIT MAX_BUFFER_SIZE;

        IF l_old_account_id IS NULL THEN
           l_old_account_id := l_account_id_tab(1);
        END IF;

        FOR ind IN 1 .. l_account_id_tab.COUNT LOOP

          debug('Old Account ID: '||l_old_account_id);
          debug('New Account ID: '||l_account_id_tab(ind));

          IF l_old_account_id <> l_account_id_tab(ind) THEN
            debug(' Account This instance party id does not match the other instances in the batch: '||l_instance_id_tab(ind));
            FND_MESSAGE.SET_NAME('CSI','CSI_MU_BATCH_DIFF_OWNER_ACCT');
            FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_instance_id_tab(ind));
            px_mass_edit_error_tbl(e_indx).instance_id        := l_instance_id_tab(ind);
            px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
            px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
            px_mass_edit_error_tbl(e_indx).txn_line_detail_id := l_txn_line_detail_id_tab(ind);
            px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
            px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
            e_indx := e_indx + 1;
          END IF;


        END LOOP; -- Acct Csr

        EXIT when account_csr%NOTFOUND;
        END LOOP; -- Account

        IF account_csr%ISOPEN THEN
          CLOSE account_csr;
        END IF;

      END IF; -- HZ_PARTIES check


    END LOOP; -- Party Csr

    EXIT when party_csr%NOTFOUND;
    END LOOP; -- Party

    IF party_csr%ISOPEN THEN
      CLOSE party_csr;
    END IF;

--   END LOOP;
END IF;
    debug('  Error Table Count when exiting vld_item_instance active is: '||px_mass_edit_error_tbl.count);

END vld_batch_inst_same_owner;

PROCEDURE vld_batch_inst_curr_owner (p_txn_line_id_tab          IN NumTabType,
                                     px_mass_edit_error_tbl  IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

    l_party_rec_count_tab                NumTabType;
    l_transaction_line_id_tab            NumTabType;
    l_owner_party_source_table_tab       Char30TabType;
    l_owner_party_id_tab                 NumTabType;
    l_owner_party_account_id_tab         NumTabType;
    l_txn_line_detail_id_tab             NumTabType;
    l_instance_id_tab                    NumTabType;
    e_indx                                    NUMBER := 0;

    MAX_BUFFER_SIZE      number := 1000;

    CURSOR inst_csr (pc_txn_line_id IN NUMBER) IS
      SELECT cil.transaction_line_id          transaction_line_id
            ,cii.owner_party_source_table     owner_party_source_table
            ,cii.owner_party_id               owner_party_id
            ,cii.owner_party_account_id       owner_party_account_id
            ,cil.txn_line_detail_id           txn_line_detail_id
            ,cii.instance_id                  instance_id
      FROM  csi_t_txn_line_details cil
           ,csi_item_instances cii
      WHERE cil.transaction_line_id = pc_txn_line_id
      AND   cil.instance_id IS NOT NULL
      AND   cil.instance_id = cii.instance_id;

    CURSOR party_csr (pc_txn_line_id IN NUMBER) IS
      SELECT ctpd.txn_party_detail_id,
             ctpd.txn_line_detail_id,
             ctpd.party_source_id,
             ctpd.party_source_table
      FROM csi_t_party_details ctpd
      WHERE ctpd.txn_line_detail_id = pc_txn_line_id;

    party_rec    party_csr%rowtype;

    CURSOR acct_csr (pc_txn_party_detail_id IN NUMBER) IS
      SELECT ctpa.txn_account_detail_id,
             ctpa.txn_party_detail_id,
             ctpa.account_id
      FROM csi_t_party_accounts ctpa
      WHERE ctpa.txn_party_detail_id = pc_txn_party_detail_id;

    acct_rec    acct_csr%rowtype;

  BEGIN
    -- Set Error Table Index
    e_indx := nvl(px_mass_edit_error_tbl.last,0) + 1;

      FOR i IN 1 .. p_txn_line_id_tab.COUNT LOOP

    OPEN inst_csr(p_txn_line_id_tab(i));
    LOOP

      FETCH inst_csr BULK COLLECT
      INTO  l_transaction_line_id_tab,
            l_owner_party_source_table_tab,
            l_owner_party_id_tab,
            l_owner_party_account_id_tab,
            l_txn_line_detail_id_tab,
            l_instance_id_tab
      LIMIT MAX_BUFFER_SIZE;

      FOR ind IN 1 .. l_transaction_line_id_tab.COUNT LOOP

        FOR party_rec IN party_csr (l_txn_line_detail_id_tab(ind)) LOOP

          IF party_rec.party_source_id <> l_owner_party_id_tab(ind) THEN
            -- Raise Error values have changed.
             FND_MESSAGE.SET_NAME('CSI','CSI_MU_PTY_DIFF_OWNER_PTY');
             FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_instance_id_tab(ind));
             px_mass_edit_error_tbl(e_indx).instance_id        := l_instance_id_tab(ind);
             px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
             px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
             px_mass_edit_error_tbl(e_indx).txn_line_detail_id := l_txn_line_detail_id_tab(ind);
             px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
             px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
             e_indx := e_indx + 1;
          END IF;

            FOR acct_rec IN acct_csr (party_rec.txn_party_detail_id) LOOP

            IF acct_rec.account_id <> l_owner_party_account_id_tab(ind) THEN
              -- Raise Error values have changed.
              FND_MESSAGE.SET_NAME('CSI','CSI_MU_ACCT_DIFF_OWNER_ACCTT');
              FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
              FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_instance_id_tab(ind));
              px_mass_edit_error_tbl(e_indx).instance_id        := l_instance_id_tab(ind);
              px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
              px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
              px_mass_edit_error_tbl(e_indx).txn_line_detail_id := l_txn_line_detail_id_tab(ind);
              px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
              px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
              e_indx := e_indx + 1;
            END IF;

            END LOOP; -- acct_csr

          END LOOP; -- party_csr

    END LOOP;

    EXIT when inst_csr%NOTFOUND;
    END LOOP; -- inst_csr

    IF inst_csr%ISOPEN THEN
      CLOSE inst_csr;
    END IF;

    END LOOP;
    debug('  Error Table Count when exiting vld_item_instance active is: '||px_mass_edit_error_tbl.count);

END vld_batch_inst_curr_owner;


PROCEDURE vld_child_inst_location(p_instance_id_tab          IN NumTabType,
                                  p_txn_line_detail_id_tab   IN NumTabType,
                                  p_instance_usage_code_tab  IN Char30TabType,
                                  px_mass_edit_error_tbl      IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

e_indx            NUMBER := NULL;
l_object_id       NUMBER;
l_parent_found    VARCHAR2(1) := 'N';

BEGIN
  -- Set Error Table Index
  e_indx := nvl(px_mass_edit_error_tbl.count,0) + 1;

  FOR i IN 1 .. p_instance_id_tab.COUNT LOOP

    -- Get the Parent ID
    debug('  Getting top most parent for subject id: '||p_instance_id_tab(i));

    csi_ii_relationships_pvt.get_top_most_parent(p_subject_id    => p_instance_id_tab(i),
                                                 p_rel_type_code => 'COMPONENT-OF',
                                                 p_object_id     => l_object_id);

    debug('  Parent Instance: '||l_object_id);
    l_parent_found := 'N';

    IF l_object_id <> p_instance_id_tab(i) THEN

      FOR ind IN 1 .. p_instance_id_tab.COUNT LOOP
      debug('  Comparing: '||p_instance_id_tab(ind)||'-'||l_object_id);
        IF p_instance_id_tab(ind) = l_object_id THEN
          l_parent_found := 'Y';
          exit;
        END IF;
      END LOOP;

      IF l_parent_found = 'N' THEN
        -- Log error Parent Must be found
        FND_MESSAGE.SET_NAME('CSI','CSI_MU_PARENT_INST_NOT_EXISTS');
        FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
        FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(i));
        px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(i);
        px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
        px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
        px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(i);
        px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
        px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
        e_indx := e_indx + 1;
      END IF;
    END IF;
  END LOOP;
  debug('  Error Table Count when exiting vld_child_inst_location is: '||px_mass_edit_error_tbl.count);

END vld_child_inst_location;

PROCEDURE vld_item_inst_location(p_instance_id_tab           IN NumTabType,
                                 p_txn_line_id_tab           IN NumTabType,
                                 p_location_type_code_tab    IN Char30TabType,
                                 p_location_id_tab           IN NumTabType,
                                 p_install_location_id_tab   IN NumTabType,
                                 p_instance_status_id_tab    IN NumTabType,
                                 px_mass_edit_error_tbl       IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

e_indx                         NUMBER;

CURSOR dummy_csr(pc_txn_line_id   IN NUMBER) IS
  SELECT cil.location_id                  location_id
        ,cil.instance_status_id           instance_status_id
        ,cil.install_location_id          install_location_id
        ,cil.txn_line_detail_id           txn_line_detail_id
      FROM  csi_t_txn_line_details cil
      WHERE cil.transaction_line_id = pc_txn_line_id
      AND   cil.instance_id IS NULL;

dummy_rec     dummy_csr%rowtype;

CURSOR inst_status_csr(pc_instance_status_id IN NUMBER) IS
  SELECT terminated_flag
  FROM   csi_instance_statuses
  WHERE instance_status_id = pc_instance_status_id;

inst_status_rec     inst_status_csr%rowtype;

BEGIN
  -- Set Error Table Index
  e_indx := nvl(px_mass_edit_error_tbl.last,0) + 1;

  FOR ind IN 1 .. p_instance_id_tab.COUNT LOOP

    IF p_location_type_code_tab(ind) NOT IN ('HZ_PARTY_SITES','HZ_LOCATIONS','VENDOR_SITE') THEN

      FOR dummy_rec IN dummy_csr (p_txn_line_id_tab(ind)) LOOP

        IF p_instance_status_id_tab(ind) IS NOT NULL THEN
          -- Check the terminable flag for this instance_status_id
          OPEN inst_status_csr(p_instance_status_id_tab(ind));
          FETCH inst_status_csr INTO inst_status_rec;
          CLOSE inst_status_csr;
        END IF;

        IF inst_status_rec.terminated_flag = 'Y' THEN
          -- Status is Terminable so Log Error
          FND_MESSAGE.SET_NAME('CSI','CSI_MU_INVALID_INST_STATUS');
          FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
          FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
          px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
          px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
          px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
          px_mass_edit_error_tbl(e_indx).txn_line_detail_id := dummy_rec.txn_line_detail_id;
          px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
          px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
          e_indx := e_indx + 1;
        END IF;

        IF dummy_rec.location_id IS NOT NULL THEN
          -- Value cannot be provided log error
          FND_MESSAGE.SET_NAME('CSI','CSI_MU_CANNOT_UPD_CURR_LOC');
          FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
          FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
          px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
          px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
          px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
          px_mass_edit_error_tbl(e_indx).txn_line_detail_id := dummy_rec.txn_line_detail_id;
          px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
          px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
          e_indx := e_indx + 1;
        END IF;

        IF dummy_rec.install_location_id IS NOT NULL THEN
          -- Value cannot be provided so log error
          FND_MESSAGE.SET_NAME('CSI','CSI_MU_CANNOT_UPD_INSTALL_LOC');
          FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
          FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
          px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
          px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
          px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
          px_mass_edit_error_tbl(e_indx).txn_line_detail_id := dummy_rec.txn_line_detail_id;
          px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
          px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
          e_indx := e_indx + 1;
        END IF;

      END LOOP;

    END IF; -- Location Type Code

  END LOOP;
  debug('  Error Table Count when exiting vld_item_inst_location is: '||px_mass_edit_error_tbl.count);

END vld_item_inst_location;

PROCEDURE vld_term_date(p_txn_line_id_tab           IN NumTabType,
                        px_mass_edit_error_tbl      IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

e_indx                         NUMBER;

CURSOR dummy_csr(pc_txn_line_id   IN NUMBER) IS
  SELECT cil.active_end_date              active_end_date
        ,cil.txn_line_detail_id           txn_line_detail_id
  FROM  csi_t_txn_line_details cil
  WHERE cil.transaction_line_id = pc_txn_line_id
  AND   cil.instance_id IS NULL;

dummy_rec     dummy_csr%rowtype;

BEGIN
  -- Set Error Table Index
  e_indx := nvl(px_mass_edit_error_tbl.last,0) + 1;

    FOR dummy_rec IN dummy_csr (p_txn_line_id_tab(1)) LOOP

      IF (dummy_rec.active_end_date > sysdate) OR
         (nvl(dummy_rec.active_end_date,fnd_api.g_miss_date) = fnd_api.g_miss_date) THEN
          FND_MESSAGE.SET_NAME('CSI','CSI_MU_TERM_DATE');
          FND_MESSAGE.SET_TOKEN('TERMINATION_DATE',dummy_rec.active_end_date);
          FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
          FND_MESSAGE.SET_TOKEN('CURR_DATE',sysdate);
          px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
          px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
          px_mass_edit_error_tbl(e_indx).txn_line_detail_id := dummy_rec.txn_line_detail_id;
          px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
          px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
          e_indx := e_indx + 1;
      END IF;

  END LOOP;
  debug('  Error Table Count when exiting vld_term_date is: '||px_mass_edit_error_tbl.count);

END vld_term_date;

PROCEDURE vld_xfer_date(p_txn_line_id_tab      IN NumTabType,
                        px_mass_edit_error_tbl  IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

    e_indx                      NUMBER := 0;

    CURSOR party_csr (pc_txn_line_id IN NUMBER) IS
      SELECT cid.active_start_date    active_start_date
            ,cid.txn_line_detail_id   txn_line_detail_id
      FROM  csi_t_txn_line_details cil
           ,csi_t_party_details cid
      WHERE cil.transaction_line_id = pc_txn_line_id
      AND   cil.instance_id IS NULL
      AND   cid.txn_line_detail_id = cil.txn_line_detail_id
      AND   cid.relationship_type_code = 'OWNER';

    party_rec     party_csr%rowtype;

  BEGIN
    -- Set Error Table Index
    e_indx := nvl(px_mass_edit_error_tbl.last,0) + 1;

      FOR party_rec IN party_csr (p_txn_line_id_tab(1)) LOOP
        IF (party_rec.active_start_date > sysdate) OR
            (nvl(party_rec.active_start_date,fnd_api.g_miss_date) = fnd_api.g_miss_date) THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_MU_XFER_DATE');
            FND_MESSAGE.SET_TOKEN('TRANSFER_DATE',party_rec.active_start_date);
            FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
            FND_MESSAGE.SET_TOKEN('CURR_DATE',sysdate);
            px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
            px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
            px_mass_edit_error_tbl(e_indx).txn_line_detail_id := party_rec.txn_line_detail_id;
            px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
            px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
            e_indx := e_indx + 1;
        END IF;

      END LOOP;
  debug('  Error Table Count when exiting vld_xfer_date is: '||px_mass_edit_error_tbl.count);

END vld_xfer_date;

PROCEDURE check_item_inst_loc_changed(p_txn_line_detail_id_tab            IN NumTabType,
                                      p_instance_id_tab                   IN NumTabType,
                                      p_install_location_id_tab           IN NumTabType,
                                      p_location_id_tab                   IN NumTabType,
                                      p_instance_status_id_tab            IN NumTabType,
                                      p_external_reference_tab            IN Char30TabType,
                                      p_install_date_tab                  IN DateTabType,
                                      p_system_id_tab                     IN NumTabType,
                                      px_mass_edit_error_tbl  IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl) IS

e_indx                         NUMBER := 0;

CURSOR txn_det_csr (pc_txn_line_detail_id IN NUMBER) IS
  SELECT cil.install_location_id          install_location_id
        ,cil.location_id                  location_id
        ,cil.instance_status_id           instance_status_id
        ,cil.external_reference           external_reference
        ,cil.installation_date            installation_date
        ,cil.csi_system_id                csi_system_id
  FROM  csi_t_txn_line_details cil
  WHERE cil.txn_line_detail_id = pc_txn_line_detail_id
  AND   cil.instance_id IS NOT NULL;

txn_det_rec     txn_det_csr%rowtype;

BEGIN
  -- Set Error Table Index
  e_indx := nvl(px_mass_edit_error_tbl.count,0) + 1;

  FOR ind IN 1 .. p_txn_line_detail_id_tab.COUNT LOOP

  OPEN txn_det_csr(p_txn_line_detail_id_tab(ind));
  FETCH txn_det_csr INTO txn_det_rec;
  CLOSE txn_det_csr;

  IF txn_det_rec.install_location_id <> p_install_location_id_tab(ind) THEN
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_INSTALL_LOC_CHANGED');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
    px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
    px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
    px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
    px_mass_edit_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
    e_indx := e_indx + 1;
  END IF;

  IF txn_det_rec.location_id <> p_location_id_tab(ind) THEN
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_CURR_LOCATION_CHANGED');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
    px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
    px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
    px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
    px_mass_edit_error_tbl(e_indx).error_code         := 'W';
    e_indx := e_indx + 1;
  END IF;

  IF txn_det_rec.instance_status_id <> p_instance_status_id_tab(ind) THEN
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_INST_STATUS_CHANGED');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
    px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
    px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
    px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
    px_mass_edit_error_tbl(e_indx).error_code         := 'W';
    e_indx := e_indx + 1;
  END IF;

  IF txn_det_rec.external_reference <> p_external_reference_tab(ind) THEN
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_EXT_REF_CHANGED');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
    px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
    px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
    px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
    px_mass_edit_error_tbl(e_indx).error_code         := 'W';
    e_indx := e_indx + 1;
  END IF;

  IF txn_det_rec.installation_date <> p_install_date_tab(ind) THEN
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_INSTALL_DATE_CHANGED');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
    px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
    px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
    px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
    px_mass_edit_error_tbl(e_indx).error_code         := 'W';
    e_indx := e_indx + 1;
  END IF;

  IF txn_det_rec.csi_system_id <> p_system_id_tab(ind) THEN
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_SYSTEM_CHANGED');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_id_tab(ind));
    px_mass_edit_error_tbl(e_indx).instance_id        := p_instance_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).entry_id           := g_entry_id;
    px_mass_edit_error_tbl(e_indx).name               := g_batch_name;
    px_mass_edit_error_tbl(e_indx).txn_line_detail_id := p_txn_line_detail_id_tab(ind);
    px_mass_edit_error_tbl(e_indx).error_text         := fnd_message.get;
    px_mass_edit_error_tbl(e_indx).error_code         := 'W';
    e_indx := e_indx + 1;
  END IF;

  END LOOP;
  debug('  Error Table Count when exiting check_item_inst_loc_changed is: '||px_mass_edit_error_tbl.count);

END check_item_inst_loc_changed;

PROCEDURE validate_batch (px_mass_edit_rec            IN csi_mass_edit_pub.mass_edit_rec,
                          p_mode                      IN VARCHAR2,
                          x_mass_edit_error_tbl       OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl,
                          x_return_status             OUT NOCOPY VARCHAR2) IS


   -- p_mode Parameters
   -- UI  = HTML UI
   -- CRT = Create Batch
   -- UPD = Update Batch
   -- CP  = Concurrent Process

   l_api_version             NUMBER          := 1.0;
   l_api_name                CONSTANT        VARCHAR2(30)   := 'VALIDATE_BATCH';
   l_init_msg_list           VARCHAR2(1)     := FND_API.G_FALSE;
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_return_status           VARCHAR2(1);
   l_mass_edit_error_tbl      csi_mass_edit_pub.mass_edit_error_tbl;
   l_errors_found              VARCHAR2(1) := 'N';
   l_warnings_found            VARCHAR2(1) := 'N';

   l_transaction_line_id_tab          NumTabType;
   l_owner_party_source_table_tab     Char30TabType;
   l_owner_party_id_tab               NumTabType;
   l_owner_party_account_id_tab       NumTabType;
   l_txn_line_detail_id_tab           NumTabType;
   l_location_id_tab                  NumTabType;
   l_install_location_id_tab          NumTabType;
   l_instance_status_id_tab           NumTabType;
   l_external_reference_tab           Char30TabType;
   l_system_id_tab                    NumTabType;
   l_location_type_code_tab           Char30TabType;
   l_instance_usage_code_tab          Char30TabType;
   l_instance_id_tab                  NumTabType;
   l_install_date_tab                 DateTabType;

   MAX_BUFFER_SIZE      number := 1000;

   CURSOR inst_csr (pc_txn_line_id IN NUMBER) IS
     SELECT cil.transaction_line_id          transaction_line_id
           ,cii.owner_party_source_table     owner_party_source_table
           ,cii.owner_party_id               owner_party_id
           ,cii.owner_party_account_id       owner_party_account_id
           ,cil.txn_line_detail_id           txn_line_detail_id
           ,cii.location_id                  location_id
           ,cii.install_location_id          install_location_id
           ,cii.instance_status_id           instance_status_id
           ,cii.external_reference           external_reference
           ,cii.system_id                    system_id
           ,cii.location_type_code           location_type_code
           ,cii.instance_usage_code          instance_usage_code
           ,cii.instance_id                  instance_id
           ,cii.install_date                 install_date
     FROM  csi_t_txn_line_details cil
          ,csi_item_instances cii
     WHERE cil.transaction_line_id = pc_txn_line_id
     AND   cil.instance_id IS NOT NULL
     AND   cil.instance_id = cii.instance_id;

BEGIN

    csi_t_gen_utility_pvt.add('In VALIDATE_BATCH');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean( l_init_msg_list ) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --  Initialize API return status to succcess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Set the Global Batch ID
    g_entry_id   := px_mass_edit_rec.entry_id;
    g_batch_name := px_mass_edit_rec.name;

   OPEN inst_csr (px_mass_edit_rec.txn_line_id);
   LOOP

     FETCH inst_csr BULK COLLECT
     INTO  l_transaction_line_id_tab,
           l_owner_party_source_table_tab,
           l_owner_party_id_tab,
           l_owner_party_account_id_tab,
           l_txn_line_detail_id_tab,
           l_location_id_tab,
           l_install_location_id_tab,
           l_instance_status_id_tab,
           l_external_reference_tab,
           l_system_id_tab,
           l_location_type_code_tab,
           l_instance_usage_code_tab,
           l_instance_id_tab,
           l_install_date_tab
     LIMIT MAX_BUFFER_SIZE;

     IF p_mode in ('UI','CRT','UPD','CP') THEN
       -- Validate that the instance is active
       debug('Executing vld_item_instance_active');
       csi_mass_edit_pvt.vld_item_instance_active (l_instance_id_tab,
                                                   l_txn_line_detail_id_tab,
                                                   l_mass_edit_error_tbl);
     END IF;

     IF p_mode  = 'CP'  THEN
       debug('Executing vld_batch_inst_curr_owner: '||l_transaction_line_id_tab(1));
       -- check current owner
       csi_mass_edit_pvt.vld_batch_inst_curr_owner(l_transaction_line_id_tab,
                                                   l_mass_edit_error_tbl);
     END IF;

     IF px_mass_edit_rec.batch_type = 'XFER' THEN
       debug('Batch Type is transfer so call vld_batch_inst_same_owner');
       IF p_mode in ('UI','CRT','UPD','CP') THEN
         debug('Executing vld_batch_inst_same_owner');
         -- check owner type and owner
         csi_mass_edit_pvt.vld_batch_inst_same_owner(l_transaction_line_id_tab,
                                   l_mass_edit_error_tbl);
       END IF;
     END IF;

     IF p_mode in ('UPD','CP') THEN
       debug('Executing vld_child_inst_location');
       -- check child instances
       csi_mass_edit_pvt.vld_child_inst_location
                              (l_instance_id_tab,
                               l_txn_line_detail_id_tab,
                               l_instance_usage_code_tab,
                               l_mass_edit_error_tbl);
     END IF;

     IF p_mode in ('UI','CRT','UPD','CP') THEN
       debug('Executing vld_item_inst_locatoin');
       -- check instance location
       csi_mass_edit_pvt.vld_item_inst_location(l_instance_id_tab,
                              l_transaction_line_id_tab,
                              l_location_type_code_tab,
                              l_location_id_tab,
                              l_install_location_id_tab,
                              l_instance_status_id_tab,
                              l_mass_edit_error_tbl);
     END IF;

     IF p_mode = 'CP' THEN
       debug('Executing check_item_inst_loc_changed');
       -- check instance location but throw warning NO error
       csi_mass_edit_pvt.check_item_inst_loc_changed(l_txn_line_detail_id_tab,
                                   l_instance_id_tab,
                                   l_install_location_id_tab,
                                   l_location_id_tab,
                                   l_instance_status_id_tab,
                                   l_external_reference_tab,
                                   l_install_date_tab,
                                   l_system_id_tab,
                                   l_mass_edit_error_tbl);
     END IF;

     IF p_mode = 'CP' AND px_mass_edit_rec.batch_type = 'TRM' THEN
       debug('Executing vld_term_date');
       csi_mass_edit_pvt.vld_term_date(l_transaction_line_id_tab,
                                       l_mass_edit_error_tbl);
     END IF;

     IF p_mode = 'CP' AND px_mass_edit_rec.batch_type = 'XFER' THEN
       debug('Executing vld_xfer_date');
       csi_mass_edit_pvt.vld_xfer_date(l_transaction_line_id_tab,
                                       l_mass_edit_error_tbl);

     END IF;

   EXIT when inst_csr%NOTFOUND;
   END LOOP; -- Inst

   IF inst_csr%ISOPEN THEN
     CLOSE inst_csr;
   END IF;

  IF l_mass_edit_error_tbl.count > 0 THEN
    debug('Total Number of recs being passed out in the error table from validate batch: '||l_mass_edit_error_tbl.count);
    FOR f in l_mass_edit_error_tbl.first .. l_mass_edit_error_tbl.last LOOP
      IF (l_mass_edit_error_tbl(f).error_code = fnd_api.g_ret_sts_error AND
         l_errors_found = 'N') THEN
        l_errors_found := 'Y';
        debug('Errors found from validate_batch');
      ELSIF (l_mass_edit_error_tbl(f).error_code = 'W' AND
             l_warnings_found = 'N') THEN
        l_warnings_found := 'Y';
        debug('Warnings found from validate_batch');
      END IF;
    END LOOP;

    IF (l_errors_found = 'Y' and l_warnings_found = 'Y' OR
        l_errors_found = 'Y' and l_warnings_found = 'N') THEN
      debug('Errors found from validate_batch and raising FND_API.G_EXC_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_errors_found = 'N' and l_warnings_found = 'Y') THEN
      x_return_status       := 'W';
      x_mass_edit_error_tbl := l_mass_edit_error_tbl;
    END IF;
    debug('Return Status from validate_batch: '||x_return_status);
  ELSE
   x_return_status := fnd_api.g_ret_sts_success;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          debug('Encountered FND_API.G_EXC_ERROR in Validate_Batch');
          x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN OTHERS THEN
          debug('Encountered WHEN OTHERS in Validate_Batch');
          x_mass_edit_error_tbl := l_mass_edit_error_tbl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END validate_batch;


/*----------------------------------------------------*/
/* Procedure name: VLD_SYSTEM_ACTIVE               */
/* Description :   procedure to validate whether the */
/*                 system is active or not            */
/*----------------------------------------------------*/
PROCEDURE VLD_SYSTEM_ACTIVE(
         p_system_id        IN NUMBER ,
         p_txn_line_id      IN NUMBER,
         p_mu_sys_error_tbl IN OUT NOCOPY csi_mass_edit_pub.mass_edit_sys_error_tbl)
IS
CURSOR sys_active (p_system_id IN NUMBER) IS
  SELECT 1
  FROM   CSI_SYSTEMS_B
  WHERE  SYSTEM_ID = p_system_id
  AND    (end_date_active is NULL OR
        nvl(end_date_active, sysdate+1) > sysdate);

  l_sys_active              NUMBER := NULL;
  e_indx                    NUMBER := 0;

BEGIN

  -- Set Error Table Index
  e_indx := nvl(p_mu_sys_error_tbl.last,0) + 1;

  OPEN sys_active(p_system_id);
  FETCH sys_active INTO l_sys_active;
  CLOSE sys_active;

   IF l_sys_active is NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_MU_INACTIVE_SYSTEM');
      FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
      FND_MESSAGE.SET_TOKEN('SYSTEM_ID',p_system_id);
      p_mu_sys_error_tbl(e_indx).system_id          := p_system_id;
      p_mu_sys_error_tbl(e_indx).entry_id           := g_entry_id;
      p_mu_sys_error_tbl(e_indx).batch_name         := g_batch_name;
      p_mu_sys_error_tbl(e_indx).txn_line_detail_id := p_txn_line_id;
      p_mu_sys_error_tbl(e_indx).error_text         := fnd_message.get;
      p_mu_sys_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
      e_indx := e_indx + 1;
  END IF;

  debug('System Error Table Count after VLD_SYSTEM_ACTIVE is: '||p_mu_sys_error_tbl.count);

END VLD_SYSTEM_ACTIVE;


/*----------------------------------------------------*/
/* Procedure name: VLD_SYSTEM_CURRENT_OWNER               */
/* Description :   procedure to validate current system owner */
/*                 system is active or not            */
/*----------------------------------------------------*/
PROCEDURE VLD_SYSTEM_CURRENT_OWNER(
         p_system_id        IN NUMBER ,
         p_customer_id      IN NUMBER,
         p_txn_line_id      IN NUMBER,
         p_mu_sys_error_tbl IN OUT NOCOPY csi_mass_edit_pub.mass_edit_sys_error_tbl)
IS
CURSOR sys_customer_csr (p_system_id IN NUMBER) IS
  SELECT CUSTOMER_ID
  FROM CSI_SYSTEMS_B
  WHERE SYSTEM_ID = p_system_id;

 l_customer_id              NUMBER := NULL;
 e_indx                    NUMBER := 0;

BEGIN

-- Set Error Table Index
  e_indx := nvl(p_mu_sys_error_tbl.last,0) + 1;

  OPEN sys_customer_csr(p_system_id);
  FETCH sys_customer_csr INTO l_customer_id;
  CLOSE sys_customer_csr;

  IF l_customer_id <> p_customer_id THEN
    -- Raise Error owner values have changed.
    FND_MESSAGE.SET_NAME('CSI','CSI_MU_SYS_CUST_DIFF');
    FND_MESSAGE.SET_TOKEN('BATCH_NAME',g_batch_name);
    FND_MESSAGE.SET_TOKEN('SYSTEM_ID',p_system_id);
    p_mu_sys_error_tbl(e_indx).system_id        := p_system_id;
    p_mu_sys_error_tbl(e_indx).entry_id           := g_entry_id;
    p_mu_sys_error_tbl(e_indx).name               := g_batch_name;
    p_mu_sys_error_tbl(e_indx).txn_line_detail_id := p_txn_line_id;
    p_mu_sys_error_tbl(e_indx).error_text         := fnd_message.get;
    p_mu_sys_error_tbl(e_indx).error_code         := fnd_api.g_ret_sts_error;
    e_indx := e_indx + 1;
  END IF;

  debug('System Error Table Count after VLD_SYSTEM_CURRENT_OWNER is: '||p_mu_sys_error_tbl.count);

END VLD_SYSTEM_CURRENT_OWNER;

/*----------------------------------------------------*/
/* Procedure name: VLD_SYSTEM_LOCATION_CHGD               */
/* Description :   procedure to validate whether the location */
/*                and contact info changed            */
/*----------------------------------------------------*/
PROCEDURE VLD_SYSTEM_LOCATION_CHGD(
         p_system_id        IN NUMBER ,
         p_txn_line_id      IN NUMBER,
         p_mu_sys_error_tbl IN OUT NOCOPY csi_mass_edit_pub.mass_edit_sys_error_tbl)
IS
BEGIN

    -- Checking whether location id/contact id changed after batch was created
    -- This procedure is not implemented for the ER 6031179 as the locations will
    -- be cleared. But this is retained for future enhacenments
    -- This should check to make sure that location id hasnt changed since
    -- the batch was created. If it has changed an e8rror message must be
    -- displayed

    NULL;


END VLD_SYSTEM_LOCATION_CHGD;


END CSI_MASS_EDIT_PVT;

/
