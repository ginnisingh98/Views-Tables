--------------------------------------------------------
--  DDL for Package Body CN_UPGRADE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UPGRADE_UTL_PKG" as
/* $Header: cnuputlb.pls 120.2.12010000.5 2010/06/25 09:25:47 rnagaraj ship $ */

  FUNCTION get_start_date(p_period_id NUMBER,
			  p_org_id    NUMBER) RETURN DATE IS

     l_start_date DATE;

     CURSOR l_start_date_csr IS

	SELECT start_date
	  FROM cn_period_statuses_all
	  WHERE period_id = p_period_id
	  AND ((org_id = p_org_id) OR (org_id IS NULL AND p_org_id IS NULL));

  BEGIN

     IF p_period_id IS NULL THEN

	l_start_date := NULL;

      ELSE

	OPEN l_start_date_csr;
	FETCH l_start_date_csr INTO l_start_date;

	CLOSE l_start_date_csr;

     END IF;

     RETURN l_start_date;

  END get_start_date;

  FUNCTION get_end_date(p_period_id NUMBER,
			p_org_id    NUMBER) RETURN DATE IS

     l_end_date DATE;

     CURSOR l_end_date_csr IS

	SELECT end_date
	  FROM cn_period_statuses_all
	  WHERE period_id = p_period_id
	  AND ((org_id = p_org_id) OR (org_id IS NULL AND p_org_id IS NULL));

  BEGIN

     IF p_period_id IS NULL THEN

	l_end_date := NULL;

      ELSE

	OPEN l_end_date_csr;
	FETCH l_end_date_csr INTO l_end_date;

	CLOSE l_end_date_csr;

     END IF;

     RETURN l_end_date;

  END  get_end_date;


--| ---------------------------------------------------------------------+
--| Function Name :  is_release_11510
--| Desc : Check if current release is 11.5.10
--| Return 1 if current release is 11.5.10
--| Return 0 if current release is 10.7, 3i or 11.0, 11.5
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_11510 RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  upper(profile_option_name) = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '107' OR
      v_cn_upgrading_profile = '110' OR
      v_cn_upgrading_profile = '3I'  OR
      v_cn_upgrading_profile = '115' THEN
      l_result := 0;
   ELSIF v_cn_upgrading_profile = '11510' THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;

END is_release_11510;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_115
--| Desc : Check if current release is 11.5
--| Return 1 if current release is 11.5
--| Return 0 if current release is 10.7, 3i or 11.0
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_115 RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  upper(profile_option_name) = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '107' OR
      v_cn_upgrading_profile = '110' OR
      v_cn_upgrading_profile = '3I'  THEN
      l_result := 0;
   ELSIF v_cn_upgrading_profile = '115' OR
         v_cn_upgrading_profile = '11510' THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;

END is_release_115;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_107
--| Desc : Check if current release is 10.7
--| Return 1 if current release is 10.7
--| Return 0 if current release is 11.5,3i or 11.0
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_107 RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  upper(profile_option_name) = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '110' OR
      v_cn_upgrading_profile = '3I' OR
      v_cn_upgrading_profile = '115'  OR
      v_cn_upgrading_profile = '11510' THEN
      l_result := 0;
   ELSIF v_cn_upgrading_profile = '107'  THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;

END is_release_107;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_110
--| Desc : Check if current release is 11.0
--| Return 1 if current release is 11.0
--| Return 0 if current release is 10.7,3i or 11.0 or 11.5
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_110 RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  upper(profile_option_name) = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '107' OR
      v_cn_upgrading_profile = '3I' OR
      v_cn_upgrading_profile = '115'  OR
      v_cn_upgrading_profile = '11510' THEN
      l_result := 0;
   ELSIF v_cn_upgrading_profile = '110'  THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;

END is_release_110;

--| ---------------------------------------------------------------------+
--| Function Name :  is_release_3i
--| Desc : Check if current release is 3i
--| Return 1 if current release is 3i
--| Return 0 if current release is 10.7,11.0 or 11.5
--| Return -1 : not valid release
--| ---------------------------------------------------------------------+

FUNCTION is_release_3i RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  upper(profile_option_name) = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '107' OR
      v_cn_upgrading_profile = '110' OR
      v_cn_upgrading_profile = '115'  OR
      v_cn_upgrading_profile = '11510' THEN
      l_result := 0;
   ELSIF v_cn_upgrading_profile = '3I'  THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;

END is_release_3i;


FUNCTION is_release_120 RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  profile_option_name = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '120'
   THEN
      l_result := 1;
   ELSIF v_cn_upgrading_profile = '11510' THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;
END is_release_120;


FUNCTION is_release_121 RETURN NUMBER IS
   l_result NUMBER := -1;
   v_cn_upgrading_profile     fnd_profile_option_values.profile_option_value%TYPE;
   CURSOR c1 IS
   SELECT profile_option_value
   from   fnd_profile_option_values
   where  profile_option_id =
     (select profile_option_id
      from   fnd_profile_options
      where  profile_option_name = 'CN_UPGRADING_FROM_RELEASE'
      and    application_id = 283)
   and    level_id = 10001
   and    application_id = 283;

BEGIN

   OPEN c1;
   FETCH c1 INTO v_cn_upgrading_profile;

   IF c1%NOTFOUND THEN
      l_result := -1;
      raise_application_error(-20000, 'There is no value setup for the profile(CN_UPGRADING_FROM_RELEASE). Cannot continue..');
      RETURN l_result;
   END IF;

   IF c1%ISOPEN THEN
      CLOSE c1;
   END IF;

   IF v_cn_upgrading_profile = '121'
   THEN
      l_result := 1;
   ELSE
      l_result := -1;
   END IF;

   RETURN l_result;
END is_release_121;




PROCEDURE CNCMAUPD_R1212 (
                  x_errbuf        OUT NOCOPY VARCHAR2,
                  x_retcode       OUT NOCOPY VARCHAR2,
                  p_batch_size     IN NUMBER,
                  p_num_workers    IN NUMBER,
                  p_worker_id      IN NUMBER)    IS

      l_table_name      VARCHAR2(30) := 'CN_COMM_LINES_API_ALL';
      -- l_update_name     VARCHAR2(30) := 'CNGSICNCMAUPD1212';
      l_update_name  VARCHAR2(30) := 'CNSCNUPD12.0.9';

      l_product         VARCHAR2(30) := 'CN' ;
      l_status          VARCHAR2(30);
      l_industry        VARCHAR2(30);
      l_table_owner     VARCHAR2(30);

      l_worker_id       NUMBER;
      l_num_workers     NUMBER ;
      l_batch_size      VARCHAR2(30) ;

      l_start_rowid     ROWID;
      l_end_rowid       ROWID;
      l_rows_processed  NUMBER;
      l_total_rows      NUMBER;

      l_any_rows_to_process  BOOLEAN;
      l_retstatus            BOOLEAN;


BEGIN

    l_batch_size  := p_batch_size;
    l_num_workers := p_num_workers;
    l_worker_id   := p_worker_id;

     fnd_file.put_line(FND_FILE.LOG, 'Updating Comm Lines API => NVL(adjust_status,NEW), NVL(PRESERVE_CREDIT_OVERRIDE_FLAG,N) to improve performance for SCA process');
     -- get schema name of the table for ROWID range processing
     l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner);

     if ((l_retstatus = FALSE) OR  (l_table_owner is null))
     then
        raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
     end if;

     fnd_file.put_line(FND_FILE.LOG, 'Batch size        : '||l_batch_size);
     fnd_file.put_line(FND_FILE.LOG, 'Number of Workers : '||l_Num_Workers);
     fnd_file.put_line(FND_FILE.LOG, 'Worker Id         : '||l_Worker_Id);

    l_rows_processed := 0;
    l_total_rows := 0;


    /*
    -- the APIs use a combination of TABLE_NAME and UPDATE_NAME to track an
    -- update. The update should be a no-op on a rerun, provided the TABLE_NAME
    -- and UPDATE_NAME do not change.
    --
    -- If you have modified the script for upgrade logic and you want the
    -- the change.
    -- convention followed for UPDATE_NAME - scriptname suffix with version
    */


    ad_parallel_updates_pkg.initialize_rowid_range(
                   ad_parallel_updates_pkg.ROWID_RANGE,
                   l_table_owner,
                   l_table_name,
                   l_update_name,
                   l_worker_id,
                   l_num_workers,
                   l_batch_size, 0);

    ad_parallel_updates_pkg.get_rowid_range(
               l_start_rowid,
               l_END_rowid,
               l_any_rows_to_process,
               l_batch_size,
               TRUE);

    WHILE (l_any_rows_to_process = TRUE) LOOP

        BEGIN

            UPDATE /*+ ROWID (clp) */ cn_comm_lines_api_all clp
            SET    clp.preserve_credit_override_flag = NVL(clp.preserve_credit_override_flag,'N'),
                   clp.adjust_status = NVL(clp.adjust_status,'NEW')
            WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
            AND    ( CLP.PRESERVE_CREDIT_OVERRIDE_FLAG IS NULL
            OR     CLP.ADJUST_STATUS IS NULL)
            AND EXISTS ( SELECT NULL
                         FROM cn_period_statuses_all status
                         WHERE  status.org_id =  clp.org_id
                         AND  clp.processed_date BETWEEN status.start_date AND status.end_date
                         AND  status.period_status = 'O'
                        );

            l_rows_processed := SQL%ROWCOUNT;
            l_total_rows := l_total_rows + l_rows_processed;

            fnd_file.put_line(FND_FILE.LOG, l_rows_processed ||' rows updated ');

        END;

    ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_END_rowid);

    COMMIT;


    -- get new range of rowids
    ad_parallel_updates_pkg.get_rowid_range(
        l_start_rowid,
        l_end_rowid,
        l_any_rows_to_process,
        l_batch_size,
        FALSE);

   END LOOP;

   fnd_file.put_line(FND_FILE.LOG, 'Total number of Comm Lines API rows that are updated with NVL(adjust_status,NEW); NVL(PRESERVE_CREDIT_OVERRIDE_FLAG,N) = '||l_total_rows);
   X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
            raise;

END  CNCMAUPD_R1212;



PROCEDURE CNCMHUPD_R1212 (
                  x_errbuf      OUT NOCOPY VARCHAR2,
                  x_retcode     OUT NOCOPY VARCHAR2,
                  p_batch_size  IN NUMBER,
                  p_num_workers IN NUMBER,
                  p_worker_id   IN NUMBER)   IS

      l_table_name      VARCHAR2(30) := 'CN_COMMISSION_HEADERS_ALL';
      -- l_update_name     VARCHAR2(30) := 'CNGSICNCMHUPD1212';
      l_update_name  VARCHAR2(30) := 'CNADSUPD12.0.9';

      l_product         VARCHAR2(30) := 'CN' ;
      l_status          VARCHAR2(30);
      l_industry        VARCHAR2(30);
      l_table_owner     VARCHAR2(30);

      l_worker_id       NUMBER;
      l_num_workers     NUMBER ;
      l_batch_size      VARCHAR2(30) ;

      l_start_rowid     ROWID;
      l_end_rowid       ROWID;
      l_rows_processed  NUMBER;
      l_total_rows      NUMBER;


      l_any_rows_to_process  BOOLEAN;
      l_retstatus            BOOLEAN;


BEGIN

    l_batch_size  := p_batch_size;
    l_num_workers := p_num_workers;
    l_worker_id   := p_worker_id;

     fnd_file.put_line(FND_FILE.LOG, 'Updating Commission Headers => NVL(adjust_status,NEW) to improve performance for SCA process');
     -- get schema name of the table for ROWID range processing
     l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner);

     if ((l_retstatus = FALSE) OR  (l_table_owner is null))
     then
        raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
     end if;

     fnd_file.put_line(FND_FILE.LOG, 'Batch size        : '||l_batch_size);
     fnd_file.put_line(FND_FILE.LOG, 'Number of Workers : '||l_Num_Workers);
     fnd_file.put_line(FND_FILE.LOG, 'Worker Id         : '||l_Worker_Id);

    l_rows_processed := 0;
    l_total_rows := 0;

    /*
    -- the APIs use a combination of TABLE_NAME and UPDATE_NAME to track an
    -- update. The update should be a no-op on a rerun, provided the TABLE_NAME
    -- and UPDATE_NAME do not change.
    --
    -- If you have modified the script for upgrade logic and you want the
    -- the change.
    -- convention followed for UPDATE_NAME - scriptname suffix with version
    */

    ad_parallel_updates_pkg.initialize_rowid_range(
                   ad_parallel_updates_pkg.ROWID_RANGE,
                   l_table_owner,
                   l_table_name,
                   l_update_name,
                   l_worker_id,
                   l_num_workers,
                   l_batch_size, 0);

    ad_parallel_updates_pkg.get_rowid_range(
               l_start_rowid,
               l_END_rowid,
               l_any_rows_to_process,
               l_batch_size,
               TRUE);

    WHILE (l_any_rows_to_process = TRUE) LOOP

        BEGIN

            UPDATE /*+ ROWID (cha) */ CN_COMMISSION_HEADERS_ALL cha
            SET    cha.adjust_status = NVL(cha.adjust_status,'NEW')
            WHERE  ROWID BETWEEN l_start_rowid AND l_end_rowid
            AND    cha.adjust_status IS NULL
            AND EXISTS (SELECT NULL
                        FROM cn_period_statuses_all status
                        WHERE  status.org_id =  cha.org_id
                        AND  cha.processed_date BETWEEN status.start_date AND status.end_date
                        AND  status.period_status = 'O'
                        );

            l_rows_processed := SQL%ROWCOUNT;
            l_total_rows := l_total_rows + l_rows_processed;

            fnd_file.put_line(FND_FILE.LOG, l_rows_processed ||' rows updated ');

        END;

    ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_END_rowid);

    COMMIT;


    -- get new range of rowids
    ad_parallel_updates_pkg.get_rowid_range(
        l_start_rowid,
        l_end_rowid,
        l_any_rows_to_process,
        l_batch_size,
        FALSE);

   END LOOP;

   fnd_file.put_line(FND_FILE.LOG, 'Total number of Commission Headers rows that are updated with NVL(adjust_status,NEW) = '||l_total_rows);
   X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
            raise;

END CNCMHUPD_R1212;




END  cn_upgrade_utl_pkg;

/
