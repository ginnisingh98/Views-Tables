--------------------------------------------------------
--  DDL for Package Body POS_IMP_SUPP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_IMP_SUPP_PKG" AS
/* $Header: POSBATCHPB.pls 120.3.12010000.3 2011/03/18 01:07:32 yaoli noship $ */

  FUNCTION func_batch_status
  (
    p_party_batch_status IN VARCHAR2,
    p_supp_batch_status  IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_batch_status VARCHAR2(30) := '';
  BEGIN
    IF (upper(p_party_batch_status) = 'PENDING' AND
       upper(p_supp_batch_status) = 'PENDING') THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'PENDING' AND
       upper(p_supp_batch_status) = 'ACTIVE') THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'PROCESSING' AND
       upper(p_supp_batch_status) = 'PENDING') THEN
      l_batch_status := 'PROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPLETED' AND
       upper(p_supp_batch_status) = 'PROCESSING') THEN
      l_batch_status := 'PROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPLETED' AND
       upper(p_supp_batch_status) = 'PREPROCESSING') THEN
      l_batch_status := 'PREPROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPLETED' AND
       upper(p_supp_batch_status) = 'COMPLETED') THEN
      l_batch_status := 'COMPLETED';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPL_ERRORS' AND
       upper(p_supp_batch_status) = 'COMPLETED') THEN
      l_batch_status := 'COMPL_ERRORS';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPL_ERRORS' AND
       upper(p_supp_batch_status) = 'COMPL_ERRORS') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPLETED' AND
       upper(p_supp_batch_status) = 'ACTION_REQUIRED') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'ACTIVE' AND
       upper(p_supp_batch_status) = 'ACTIVE') THEN
      l_batch_status := 'ACTIVE';
    END IF;

    IF (p_party_batch_status IN ('COMPLETED', 'PENDING') AND
       p_supp_batch_status IS NULL) THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPLETED' AND
       upper(p_supp_batch_status) = 'PENDING') THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'COMPLETED' AND
       upper(p_supp_batch_status) = 'ACTIVE') THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'REJECTED' AND
       upper(p_supp_batch_status) = 'REJECTED') THEN
      l_batch_status := 'REJECTED';
    END IF;

    IF (upper(p_party_batch_status) = 'ACTION_REQUIRED' AND
       upper(p_supp_batch_status) = 'PENDING') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'PENDING' AND
       upper(p_supp_batch_status) = 'ACTION_REQUIRED') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'ACTION_REQUIRED' AND
       upper(p_supp_batch_status) = 'ACTIVE') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'ACTION_REQUIRED' AND
       upper(p_supp_batch_status) = 'COMPLETED') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'ACTION_REQUIRED' AND
       upper(p_supp_batch_status) = 'COMPL_ERRORS') THEN
      l_batch_status := 'ACTION_REQUIRED';
    END IF;

    IF (upper(p_party_batch_status) = 'PENDING' AND
       upper(p_supp_batch_status) = NULL) THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'PENDING' AND
       upper(p_supp_batch_status) = 'COMPLETED') THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'PENDING' AND
       upper(p_supp_batch_status) = 'PROCESSING') THEN
      l_batch_status := 'PENDING';
    END IF;

    IF (upper(p_party_batch_status) = 'PROCESSING' AND
       upper(p_supp_batch_status) = 'COMPLETED') THEN
      l_batch_status := 'PROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'PREPROCESSING' AND
       upper(p_supp_batch_status) = 'COMPLETED') THEN
      l_batch_status := 'PREPROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'PREPROCESSING' AND
       upper(p_supp_batch_status) = 'PREPROCESSING') THEN
      l_batch_status := 'PREPROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'PREPROCESSING' AND
       upper(p_supp_batch_status) = 'PROCESSING') THEN
      l_batch_status := 'PREPROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'PROCESSING' AND
       upper(p_supp_batch_status) = 'PREPROCESSING') THEN
      l_batch_status := 'PREPROCESSING';
    END IF;

    IF (upper(p_party_batch_status) = 'PROCESSING' AND
       upper(p_supp_batch_status) = 'PROCESSING') THEN
      l_batch_status := 'PROCESSING';
    END IF;

    RETURN l_batch_status;

  END func_batch_status;

  PROCEDURE pre_import_counts
  (
    p_batch_id        IN NUMBER,
    p_original_system IN VARCHAR2
  ) IS
    l_suppliers_in_batch   NUMBER := 0;
    l_supp_sites_in_batch  NUMBER := 0;
    l_sup_contact_in_batch NUMBER := 0;
    l_prodserv_in_batch    NUMBER := 0;
    l_bus_class_in_batch   NUMBER := 0;
    l_bankdtls1_in_batch   NUMBER := 0;
    l_bankdtls2_in_batch   NUMBER := 0;
    l_taxdtls1_in_batch    NUMBER := 0;
    l_taxdtls2_in_batch    NUMBER := 0;
    l_taxdtls3_in_batch    NUMBER := 0;
    l_total_batch_records  NUMBER := 0;
    l_uda_in_batch	   NUMBER := 0;
  BEGIN
    /* Select the counts for particular batch from all the interface tables */
    SELECT COUNT(int.sdh_batch_id)
    INTO   l_suppliers_in_batch
    FROM   ap_suppliers_int INT
    WHERE  int.sdh_batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;
    SELECT COUNT(int.sdh_batch_id)
    INTO   l_supp_sites_in_batch
    FROM   ap_supplier_sites_int INT
    WHERE  int.sdh_batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;
    SELECT COUNT(int.sdh_batch_id)
    INTO   l_sup_contact_in_batch
    FROM   ap_sup_site_contact_int INT
    WHERE  int.sdh_batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;
    SELECT COUNT(int.sdh_batch_id)
    INTO   l_prodserv_in_batch
    FROM   pos_product_service_int INT
    WHERE  int.sdh_batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;

    SELECT COUNT(int.sdh_batch_id)
    INTO   l_bus_class_in_batch
    FROM   pos_business_class_int INT
    WHERE  int.sdh_batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;

    SELECT COUNT(int.batch_id)
    INTO   l_taxdtls1_in_batch
    FROM   pos_party_tax_profile_int INT
    WHERE  int.batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;

    SELECT COUNT(int.batch_id)
    INTO   l_taxdtls2_in_batch
    FROM   pos_party_tax_reg_int INT
    WHERE  int.batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;

    SELECT COUNT(int.batch_id)
    INTO   l_taxdtls3_in_batch
    FROM   pos_fiscal_class_int INT
    WHERE  int.batch_id = p_batch_id
    /*AND    int.source_system = p_original_system*/
    ;

    SELECT COUNT(int.batch_id)
    INTO   l_bankdtls1_in_batch
    FROM   pos_bank_account_det_int INT
    WHERE  int.batch_id = p_batch_id;

    SELECT COUNT(int.batch_id)
    INTO   l_bankdtls2_in_batch
    FROM   pos_bank_accnt_owners_int INT
    WHERE  int.batch_id = p_batch_id;

    SELECT COUNT(INT.BATCH_ID)
    INTO   l_uda_in_batch
    FROM   POS_SUPP_PROF_EXT_INTF INT
    WHERE  int.batch_id = p_batch_id
           and NVL(int.PROCESS_STATUS, 1) = 1;

    -- Counts to be added for UDA, Bank and Tax Details

    l_total_batch_records := l_suppliers_in_batch + l_supp_sites_in_batch +
                             l_sup_contact_in_batch + l_prodserv_in_batch +
                             l_bus_class_in_batch + l_bankdtls1_in_batch +
                             l_bankdtls2_in_batch + l_taxdtls1_in_batch +
                             l_taxdtls2_in_batch + l_taxdtls3_in_batch +
			     l_uda_in_batch ;

    /* This procedure also initializes the post count columns to zero */
    UPDATE pos_imp_batch_summary
    SET    suppliers_in_batch       = l_suppliers_in_batch,
           sites_in_batch           = l_supp_sites_in_batch,
           contacts_in_batch        = l_sup_contact_in_batch,
           buss_class_in_batch      = l_bus_class_in_batch,
           prod_serv_in_batch       = l_prodserv_in_batch,
           bank_detls_in_batch      = l_bankdtls1_in_batch +
                                      l_bankdtls2_in_batch,
           tax_dtls_in_batch        = l_taxdtls1_in_batch +
                                      l_taxdtls2_in_batch +
                                      l_taxdtls3_in_batch,
           total_batch_records      = l_total_batch_records,
           total_inserts            = 0,
           total_updates            = 0,
           total_merge_requests     = 0,
           total_auto_merged        = 0,
           suppliers_inserted       = 0,
           sites_inserted           = 0,
           contacts_inserted        = 0,
           buss_class_inserted      = 0,
           prod_serv_inserted       = 0,
           bank_detls_inserted      = 0,
           tax_dtls_inserted        = 0,
           suppliers_updated        = 0,
           sites_updated            = 0,
           contacts_updated         = 0,
           buss_class_updated       = 0,
           prod_serv_updated        = 0,
           bank_detls_updated       = 0,
           tax_dtls_updated         = 0,
           suppliers_merge_requests = 0,
           sites_merge_requests     = 0,
           contacts_merge_requests  = 0,
           suppliers_auto_merged    = 0,
           suppliers_imported       = 0,
           sites_imported           = 0,
           contacts_imported        = 0,
           buss_class_imported      = 0,
           prod_serv_imported       = 0,
           bank_detls_imported      = 0,
           tax_dtls_imported        = 0,
           --total_errors           = 0,
           --total_batch_records    = 0,
           total_records_imported = 0
    WHERE  batch_id = p_batch_id;
  END pre_import_counts;

  PROCEDURE activate_batch
  (
    p_init_msg_list IN VARCHAR2 := fnd_api.g_false,
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_batch_id        NUMBER;
    l_original_system VARCHAR2(30);
    l_pre_count_stat  VARCHAR2(200) := 'begin POS_IMP_SUPP_PKG.pre_import_counts
        (p_batch_id           => :1,
         p_original_system    => :2); end;';

  BEGIN

    -- standard start of API savepoint
    SAVEPOINT activate_batch;

    -- Check if API is called in debug mode. If yes, enable debug.

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    hz_imp_batch_summary_v2pub.activate_batch(p_init_msg_list => p_init_msg_list,
                                              p_batch_id      => p_batch_id,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data);

    ----------------
    -- do validation
    ----------------

    -- batch id must be a valid batch id in pos_imp_batch_summary table
    BEGIN
      SELECT batch_id,
             original_system
      INTO   l_batch_id,
             l_original_system
      FROM   pos_imp_batch_summary
      WHERE  batch_id = p_batch_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'p_batch_id');
        fnd_message.set_token('COLUMN', 'batch_id');
        fnd_message.set_token('TABLE', 'pos_imp_batch_summary');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- batch id must be a valid batch for processing
    BEGIN
      SELECT batch_id
      INTO   l_batch_id
      FROM   pos_imp_batch_summary
      WHERE  batch_id = p_batch_id
      AND    nvl(batch_status, 'ACTIVE') NOT IN
             ('PURGED',
               'REJECTED',
               'PROCESSING',
               'COMPLETED',
               'ACTION_REQUIRED');

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('AR', 'HZ_INVALID_IMP_BATCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    ---------------------------------
    -- update the batch summary table
    ---------------------------------

    -- update the batch record
    UPDATE pos_imp_batch_summary
    SET    batch_status      = 'ACTIVE',
           last_updated_by   = hz_utility_v2pub.last_updated_by,
           last_update_date  = hz_utility_v2pub.last_update_date,
           last_update_login = hz_utility_v2pub.last_update_login
    WHERE  batch_id = p_batch_id;

    ------------------------------------
    -- call the pre import count process
    ------------------------------------

    -- call the count of records calculation routine
    -- use dynamic sql to avoid compilation error in 8i
    EXECUTE IMMEDIATE l_pre_count_stat
      USING p_batch_id, l_original_system;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO activate_batch;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO activate_batch;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO activate_batch;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END activate_batch;

  PROCEDURE purge_batch
  (
    errbuf     OUT NOCOPY VARCHAR2,
    retcode    OUT NOCOPY VARCHAR2,
    p_batch_id IN VARCHAR2
  ) IS
    i               NUMBER;
    l_error_message VARCHAR2(2000);
    l_status        pos_imp_batch_summary.main_conc_status%TYPE;
  BEGIN

    /* Check for 8i database */
    BEGIN
      SELECT REPLACE(substr(version, 1, instr(version, '.', 1, 3)), '.')
      INTO   i
      FROM   v$instance;

      IF i >= 920 THEN
        NULL;
      ELSE
        RAISE fnd_api.g_exc_error;
      END IF;

    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        ROLLBACK WORK;
        fnd_message.set_name('AR', 'HZ_IMP_DB_VER_CHECK');
        fnd_msg_pub.add;
        fnd_msg_pub.reset;
        FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
          l_error_message := fnd_msg_pub.get(p_msg_index => i,
                                             p_encoded   => fnd_api.g_false);
          fnd_file.put_line(fnd_file.output, l_error_message);
          fnd_file.put_line(fnd_file.log, l_error_message);
        END LOOP;
        retcode := 2;
        RETURN;
      WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK WORK;
        fnd_file.put_line(fnd_file.log, 'Unexpected error occured ');
        fnd_file.put_line(fnd_file.log, SQLERRM);
        retcode := 2;
        RETURN;
      WHEN OTHERS THEN
        ROLLBACK WORK;
        fnd_file.put_line(fnd_file.log, SQLERRM);
        retcode := 2;
        RETURN;
    END;

    /* Delete party data from HZ interface tables */
    hz_imp_purge_pkg.purge_batch(errbuf, retcode, p_batch_id);

    /* Batch is Processing */
    BEGIN
      SELECT main_conc_status
      INTO   l_status
      FROM   pos_imp_batch_summary
      WHERE  batch_id = p_batch_id;

      IF l_status = 'PROCESSING' THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        ROLLBACK WORK;
        fnd_file.put_line(fnd_file.log,
                          'Error : You cannot purge a batch when a batch is being processed.');
        retcode := 2;
        RETURN;
      WHEN OTHERS THEN
        ROLLBACK WORK;
        fnd_file.put_line(fnd_file.log, SQLERRM);
        retcode := 2;
        RETURN;
    END;
    fnd_file.put_line(fnd_file.log, ' Purge Starts ... ');

    -- Interface Tables
    fnd_file.put_line(fnd_file.log, ' Purging Interface Tables ... ');

    DELETE ap_suppliers_int WHERE sdh_batch_id = p_batch_id;
    COMMIT;

    DELETE ap_supplier_sites_int WHERE sdh_batch_id = p_batch_id;
    COMMIT;

    DELETE ap_sup_site_contact_int WHERE sdh_batch_id = p_batch_id;
    COMMIT;

    DELETE pos_product_service_int WHERE sdh_batch_id = p_batch_id;
    COMMIT;

    DELETE pos_business_class_int WHERE sdh_batch_id = p_batch_id;
    COMMIT;

    DELETE pos_party_tax_profile_int WHERE batch_id = p_batch_id;
    COMMIT;

    DELETE pos_party_tax_reg_int WHERE batch_id = p_batch_id;
    COMMIT;

    DELETE pos_fiscal_class_int WHERE batch_id = p_batch_id;
    COMMIT;

    DELETE pos_bank_account_det_int WHERE batch_id = p_batch_id;
    COMMIT;

    DELETE pos_bank_accnt_owners_int WHERE batch_id = p_batch_id;
    COMMIT;

    fnd_file.put_line(fnd_file.log, ' Purged Interface Tables ... ');

    fnd_file.put_line(fnd_file.log,
                      ' Update pos_imp_batch_summary table (+)');
    -- Update pos_imp_batch_summary table.
    UPDATE pos_imp_batch_summary
    SET    batch_status      = 'PURGED',
           purge_date        = SYSDATE,
           purged_by_user_id = hz_utility_v2pub.user_id
    WHERE  batch_id = p_batch_id;
    COMMIT;

    fnd_file.put_line(fnd_file.log,
                      ' Update pos_imp_batch_summary table (-)');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK WORK;
      fnd_file.put_line(fnd_file.log, SQLERRM);
      retcode := 2;
      RETURN;
  END purge_batch;

  PROCEDURE reject_batch
  (
    p_init_msg_list IN VARCHAR2 := fnd_api.g_false,
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_batch_id        NUMBER;
    l_original_system VARCHAR2(30);
    l_pre_count_stat  VARCHAR2(200) := 'begin POS_IMP_SUPP_PKG.pre_import_counts
        (p_batch_id           => :1,
         p_original_system    => :2); end;';

  BEGIN

    -- standard start of API savepoint
    SAVEPOINT reject_batch;

    -- Check if API is called in debug mode. If yes, enable debug.

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    ----------------
    -- do validation
    ----------------

    -- batch id must be a valid batch id in pos_imp_batch_summary table and hz_imp_batch_summary
    BEGIN
      SELECT pos.batch_id,
             pos.original_system
      INTO   l_batch_id,
             l_original_system
      FROM   pos_imp_batch_summary pos,
             hz_imp_batch_summary  hz
      WHERE  pos.batch_id = hz.batch_id
      AND    pos.batch_id = p_batch_id;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'p_batch_id');
        fnd_message.set_token('COLUMN', 'batch_id');
        fnd_message.set_token('TABLE', 'pos_imp_batch_summary');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    /* -- batch id must be a valid batch for processing
    BEGIN
      SELECT pos.batch_id
      INTO   l_batch_id
      FROM   pos_imp_batch_summary pos, hz_imp_batch_summary hz
      WHERE  pos.batch_id = hz.batch_id
      and    pos.batch_id = p_batch_id
      AND    nvl(pos.batch_status,'ACTIVE') NOT IN
             ('PURGED',
              'REJECTED',
              'PROCESSING',
              'COMPLETED',
              'ACTION_REQUIRED')
      AND    nvl(hz.batch_status,'ACTIVE') NOT IN
             ('PURGED',
              'REJECTED',
              'PROCESSING',
              'COMPLETED',
              'ACTION_REQUIRED');

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('AR', 'HZ_INVALID_IMP_BATCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF; */

    ---------------------------------
    -- update the batch summary table
    ---------------------------------

    -- update the batch record
    UPDATE hz_imp_batch_summary
    SET    batch_status      = 'REJECTED',
           import_status     = 'REJECTED',
           last_updated_by   = hz_utility_v2pub.last_updated_by,
           last_update_date  = hz_utility_v2pub.last_update_date,
           last_update_login = hz_utility_v2pub.last_update_login
    WHERE  batch_id = p_batch_id;

    UPDATE pos_imp_batch_summary
    SET    batch_status      = 'REJECTED',
           import_status     = 'REJECTED',
           last_updated_by   = hz_utility_v2pub.last_updated_by,
           last_update_date  = hz_utility_v2pub.last_update_date,
           last_update_login = hz_utility_v2pub.last_update_login
    WHERE  batch_id = p_batch_id;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO reject_batch;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO reject_batch;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO reject_batch;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END reject_batch;

  PROCEDURE create_import_batch
  (
    p_batch_id          IN NUMBER,
    p_batch_name        IN VARCHAR2,
    p_description       IN VARCHAR2,
    p_original_system   IN VARCHAR2,
    p_load_type         IN VARCHAR2,
    p_est_no_of_records IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  ) IS
    os_exists_flag VARCHAR2(1) := 'N';

  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_import_batch;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    ----------------
    -- do validation
    ----------------

    -- batch name is mandatory
    hz_utility_v2pub.validate_mandatory(p_create_update_flag => 'C',
                                        p_column             => 'batch_name',
                                        p_column_value       => p_batch_name,
                                        p_restricted         => 'Y',
                                        x_return_status      => x_return_status);

    -- original_system is mandatory
    hz_utility_v2pub.validate_mandatory(p_create_update_flag => 'C',
                                        p_column             => 'original_system',
                                        p_column_value       => p_original_system,
                                        p_restricted         => 'Y',
                                        x_return_status      => x_return_status);

    BEGIN
      SELECT 'Y'
      INTO   os_exists_flag
      FROM   hz_orig_systems_b
      WHERE  orig_system = p_original_system
      AND    orig_system <> 'SST'
      AND    status = 'A';
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'orig_system');
        fnd_message.set_token('COLUMN', 'orig_system');
        fnd_message.set_token('TABLE', 'HZ_ORIG_SYSTEMS_B');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --------------------------------------------
    -- insert the record with batch id
    --------------------------------------------

    INSERT INTO pos_imp_batch_summary
      (batch_id,
       batch_name,
       description,
       original_system,
       load_type,
       est_no_of_records,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login)
    VALUES
      (p_batch_id,
       p_batch_name,
       p_description,
       p_original_system,
       p_load_type,
       p_est_no_of_records,
       hz_utility_v2pub.created_by,
       hz_utility_v2pub.creation_date,
       hz_utility_v2pub.last_updated_by,
       hz_utility_v2pub.last_update_date,
       hz_utility_v2pub.last_update_login);

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_import_batch;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_import_batch;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_import_batch;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END create_import_batch;

END POS_IMP_SUPP_PKG;

/
