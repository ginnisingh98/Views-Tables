--------------------------------------------------------
--  DDL for Package Body FII_CCC_SEC_UPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CCC_SEC_UPL_PKG" AS
/* $Header: FIICCCSECB.pls 120.1.12000000.1 2007/04/12 21:43:32 lpoon ship $ */

g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_sys_date           DATE := sysdate;
g_user_id          NUMBER := fnd_global.user_id;
g_indenting   VARCHAR2(4) := '   ';
g_space      VARCHAR2(30) := '                              ';
g_long_line  VARCHAR2(42) := '------------------------------------------';
g_short_line VARCHAR2(10) := '----------';

--------------------
--  debug
--------------------
PROCEDURE dbg(text IN VARCHAR2)
  IS
BEGIN
   IF (g_debug_flag = 'Y') THEN
      fii_util.put_line(text);
   END IF;
END dbg;


-------------------------------------------------------------------
-- Web_adi_upload called by WebADI
-------------------------------------------------------------------
FUNCTION web_adi_upload (
			 x_grantee_name       IN  VARCHAR2 DEFAULT NULL,
			 --x_grantee_key        IN  VARCHAR2 DEFAULT NULL,
			 x_role_name          IN  VARCHAR2 DEFAULT NULL,
			 x_start_date         IN  DATE     DEFAULT NULL,
			 x_end_date           IN  DATE     DEFAULT NULL,
			 x_dimension_code     IN  VARCHAR2 DEFAULT NULL,
			 x_dimension_value    IN  VARCHAR2 DEFAULT NULL
			 ) return VARCHAR2 IS

      l_err_msg         VARCHAR2(150);
      l_grantee_key     VARCHAR2(240);
      l_dimension_id    VARCHAR2(256);

BEGIN

   BEGIN
       SELECT distinct id INTO l_grantee_key
       FROM hri_dbi_cl_per_n_v
       WHERE value = x_grantee_name;
   EXCEPTION
   WHEN no_data_found THEN
        l_err_msg := fnd_message.get_string('FII', 'FII_CCC_SEC_INVALID_GRANT_TO');
	    return l_err_msg;
   WHEN too_many_rows THEN
        l_err_msg := fnd_message.get_string('FII', 'FII_CCC_SEC_MULTIPLE_GRANT_TO');
	    return l_err_msg;
   END;


   IF x_dimension_code = 'FII_COMPANIES' THEN

      BEGIN
         SELECT id INTO l_dimension_id
           FROM fii_ccc_values_v
	      WHERE dimension = 'FII_COMPANIES'
		    AND value = x_dimension_value;
      EXCEPTION
      WHEN no_data_found THEN
          l_err_msg := fnd_message.get_string('FII', 'FII_CCC_SEC_INVALID_COM_VALUE');
	      return l_err_msg;
      END;

    ELSE
     IF x_dimension_code = 'HRI_CL_ORGCC' THEN

		 BEGIN
         SELECT id INTO l_dimension_id
	       FROM fii_ccc_values_v
          WHERE dimension = 'HRI_CL_ORGCC'
		    AND value = x_dimension_value;
         EXCEPTION
		 WHEN no_data_found THEN
            l_err_msg := fnd_message.get_string('FII', 'FII_CCC_SEC_INVALID_CC_VALUE');
	        return l_err_msg;
		 END;

       ELSE
          l_err_msg := fnd_message.get_string('FII', 'FII_CCC_SEC_INVALID_DIMEN_CODE');
	      return l_err_msg;
     END IF;
   END IF;

   INSERT INTO fii_ccc_sec_interface
     (grantee_key,
      menu_name,
      start_date,
      end_date,
      dimension_code,
      dimension_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
      )
     VALUES
     (l_grantee_key,
      x_role_name,
      x_start_date,
      x_end_date,
      x_dimension_code,
      l_dimension_id,
      g_sys_date,
      g_user_id,
      g_sys_date,
      g_user_id,
      g_user_id
     );

   return null;

EXCEPTION
   WHEN OTHERS THEN
      l_err_msg := fnd_message.get_string('FII', 'FII_CCC_SEC_OTHER_ERR');
      return l_err_msg;
END web_adi_upload;



--------------------------------------------------------------------------
-- Validate Data in FII_CCC_SEC_INTERFACE before uploading into FND_GRANTS
--------------------------------------------------------------------------
PROCEDURE Validate (retcode IN OUT NOCOPY VARCHAR2) IS

   l_violations_found	BOOLEAN	:= FALSE;
   l_grantee_key        VARCHAR2(240);
   l_menu_name          VARCHAR2(30);
   l_cnt                NUMBER;
   l_diff_date_header   BOOLEAN := FALSE;
   l_msg1               VARCHAR2(100):=null;
   l_msg2               VARCHAR2(100):=null;
   l_msg_length         NUMBER := 42;
   l_date_length        NUMBER := 10;
   l_grant_to_name      VARCHAR2(153);
   l_role_user_name     VARCHAR2(80);
   l_sd                 DATE;
   l_ed                 DATE;

   CURSOR v1_csr IS
      SELECT grantee_key, menu_name, count(*)
      FROM
	  (
	   SELECT distinct grantee_key, menu_name, start_date, end_date
	   FROM  fii_ccc_sec_interface
	   WHERE status_code IS NULL
	   ) a
	   GROUP BY grantee_key, menu_name
	   HAVING COUNT(*) > 1;

   CURSOR get_sd_ed_csr(p_grantee_key VARCHAR2, p_menu_name VARCHAR2) IS
	  SELECT distinct start_date, end_date
	  FROM  fii_ccc_sec_interface
	  WHERE status_code IS NULL
	  AND grantee_key = p_grantee_key
	  AND menu_name = p_menu_name;

BEGIN

    -- debug msg time stamp of entering this procedure
    IF g_debug_flag = 'Y' THEN
      FII_MESSAGE.Func_Ent('FII_CCC_SEC_UPL_PKG.validate');
    END IF;

   --------------------------------------------------------------
   -- 1. The start/end date should be the same across all records
   --    for the same GrantTo/Role pair
   --------------------------------------------------------------
   dbg('validate: check start/end date should be the same across all records for the same GrantTo/Role pair');
   IF (NOT v1_csr%ISOPEN) THEN
      OPEN v1_csr;
   END IF;

   LOOP
      FETCH v1_csr INTO l_grantee_key, l_menu_name, l_cnt;
      EXIT WHEN v1_csr%NOTFOUND;
      l_violations_found := TRUE;

	  IF (NOT l_diff_date_header) then
          fii_util.put_line(fnd_message.get_string('FII', 'FII_CCC_SEC_DIFF_DATES'));
		  fii_util.put_line('                    Grant To (GRANTEE_KEY)' || g_indenting ||
                            '                          Role (MENU_NAME)' || g_indenting ||
							'Start Date' || g_indenting ||
							'  End Date' || g_indenting);
		  fii_util.put_line( g_long_line || g_indenting || g_long_line || g_indenting ||
							 g_short_line|| g_indenting || g_short_line);
		  l_diff_date_header := TRUE;

	  END IF;

	  BEGIN
	      SELECT distinct value INTO l_grant_to_name
          FROM  hri_dbi_cl_per_n_v
          WHERE id = l_grantee_key;
      EXCEPTION
      WHEN no_data_found THEN
          l_grant_to_name := 'N/A';
      END;

	  BEGIN
	      SELECT distinct role_user_name INTO l_role_user_name
		  FROM fii_ccc_sec_roles_v
	      WHERE role_name = l_menu_name;
      EXCEPTION
      WHEN no_data_found THEN
          l_role_user_name := 'N/A';
      END;


	  FOR get_sd_ed_rec IN get_sd_ed_csr(l_grantee_key, l_menu_name)
	  LOOP

	    -- print out the records that violate the validation 1 in the log file
	    l_msg1 := substr(l_grant_to_name,1,30) || ' (' ||  l_grantee_key || ')';
	    l_msg2 := substr(l_role_user_name,1,30) || ' (' ||  l_menu_name || ')';
	    fii_util.put_line(substr(g_space, 1, l_msg_length - length(l_msg1)) || substr(l_msg1,1,42) ||
	                      g_indenting ||
			              substr(g_space, 1, l_msg_length - length(l_msg2)) || substr(l_msg2,1,42) ||
						  g_indenting ||
						  substr(g_space, 1, l_date_length - length(to_char(get_sd_ed_rec.start_date))) ||
						  get_sd_ed_rec.start_date ||
						  g_indenting ||
						  substr(g_space, 1, l_date_length - length(to_char(get_sd_ed_rec.end_date))) ||
						  get_sd_ed_rec.end_date
						  );
      END LOOP;


      --Update the Status_Code
	  UPDATE fii_ccc_sec_interface
         SET  status_code = 'ERR - DIFFERENT DATES',
		      last_update_date = g_sys_date,
              last_updated_by = g_user_id,
              last_update_login = g_user_id
	   WHERE status_code is NULL
	     AND grantee_key = l_grantee_key
	     AND menu_name = l_menu_name;

   END LOOP;
   CLOSE v1_csr;

   IF l_violations_found = FALSE THEN
      dbg('validate: validation 1 - passed');
      retcode := 'S';

	  -- debug msg time stamp of completing this procedure successfully
      IF g_debug_flag = 'Y' THEN
         FII_MESSAGE.Func_Succ(func_name => 'FII_CCC_SEC_UPL_PKG.validate');
      END IF;

    ELSE

      ------------------------------------------------------------
      -- Update the remaining records that has status_code is NULL
      -- to VALIDATED to avoid being picked up in the next run.
      --------------------------------------------------------------
	  dbg('validate: validation 1 - failed');
      dbg('validate: update remaining valid records to VALIDATED');
      UPDATE fii_ccc_sec_interface
         SET  status_code = 'VALIDATED',
              last_update_date = g_sys_date,
              last_updated_by = g_user_id,
              last_update_login = g_user_id
       WHERE status_code is NULL;

      retcode := 'E';
	  -- debug msg time stamp of exiting this procedure
      IF g_debug_flag = 'Y' THEN
         FII_MESSAGE.Func_Succ(func_name => 'FII_CCC_SEC_UPL_PKG.validate');
      END IF;

   END IF;

END validate;

-------------------------------------------------------------------
-- Upload Data into FND_GRANTS
-------------------------------------------------------------------
PROCEDURE upload (retcode IN OUT NOCOPY VARCHAR2) IS


   CURSOR c1_csr IS
    SELECT grantee_key, menu_name,
           start_date, end_date,
           dimension_code, dimension_id
	FROM   fii_ccc_sec_interface
	WHERE status_code IS NULL
	ORDER BY grantee_key, menu_name, dimension_code;


   CURSOR get_grant_guid_csr IS
   	SELECT g.grant_guid --, g.grantee_key, g.menu_id, int.menu_name
	FROM fnd_grants g,
	     fnd_menus  m,
	     (
          SELECT distinct grantee_key, menu_name
	      FROM   fii_ccc_sec_interface
	      WHERE status_code IS NULL
	     ) int
	WHERE int.grantee_key = g.grantee_key
	AND   int.menu_name = m.menu_name
	AND   m.menu_id = g.menu_id;

   l_trunc_retcode   VARCHAR2(20) := NULL;
   x_grant_guid      raw(16);
   x_success         VARCHAR(30);
   x_errorcode       VARCHAR2(500);

BEGIN

    -- debug msg time stamp of entering this procedure
    IF g_debug_flag = 'Y' THEN
      FII_MESSAGE.Func_Ent('FII_CCC_SEC_UPL_PKG.upload');
    END IF;


    -- If there is already an existing grant for the Grant To / Role pair,
    -- the existing grant will be completely deleted and overwritten by
    -- the new grant.
    dbg('upload: delete any existing grant for the grant to / role pair');

    FOR get_grant_guid_rec IN get_grant_guid_csr LOOP

        fnd_grants_pkg.revoke_grant
        (
         p_api_version    => 1.0,
         p_grant_guid     => get_grant_guid_rec.grant_guid,
	     x_success        => x_success,
	     x_errorcode      => x_errorcode
        );

        IF x_success = FND_API.G_TRUE THEN
	        dbg('upload: revoke grant succeed. grant_guid = '||to_char(get_grant_guid_rec.grant_guid));
	    ELSE
	        dbg('upload: revoke grant failed. grant_guid = '||to_char(get_grant_guid_rec.grant_guid));
	        retcode := 'E';
		    RETURN;
      END IF;
    END LOOP;


   --
   -- Upload Data into FND_GRANTS
   --
   dbg('upload: upload data into fnd_grants');
   FOR c1_rec IN c1_csr LOOP

       dbg('upload: grantee_key='    || c1_rec.grantee_key
               || ' menu_name='      || c1_rec.menu_name
               || ' start_date='     || c1_rec.start_date
               || ' end_date='       || c1_rec.end_date
               || ' dimension_code=' || c1_rec.dimension_code
               || ' dimension_id='   || c1_rec.dimension_id);

       fnd_grants_pkg.grant_function
	   (
	    p_api_version            =>  1.0,
	    p_menu_name              =>  c1_rec.menu_name,
	    p_object_name            =>  'HRI_PER',
	    p_instance_type          =>  'INSTANCE',
	    -- p_instance_set_id     IN  NUMBER  DEFAULT NULL,
	    p_instance_pk1_value     =>  c1_rec.dimension_id,
	    -- p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
	    -- p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
	    -- p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
	    -- p_instance_pk5_value  IN  VARCHAR2 DEFAULT NULL,
	    p_grantee_type           =>  'USER',
	    p_grantee_key            =>  c1_rec.grantee_key,
	    p_start_date             =>  c1_rec.start_date,
	    p_end_date               =>  c1_rec.end_date,
	    p_program_name           =>  'BIS_PMV_GRANTS',
	    -- p_program_tag         IN  VARCHAR2 DEFAULT NULL,
	    x_grant_guid             =>  x_grant_guid, -- OUT
	    x_success                =>  x_success,    -- OUT
	    x_errorcode              =>  x_errorcode,  -- OUT
	    p_parameter1             =>  c1_rec.dimension_code
	    -- p_parameter2          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter3          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter4          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter5          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter6          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter7          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter8          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter9          IN  VARCHAR2 DEFAULT NULL,
	    -- p_parameter10         IN  VARCHAR2 DEFAULT NULL,
	    -- p_ctx_secgrp_id       IN  NUMBER default -1,
	    -- p_ctx_resp_id         IN  NUMBER default -1,
	    -- p_ctx_resp_appl_id    IN  NUMBER default -1,
	    -- p_ctx_org_id          IN  NUMBER default -1,
	    -- p_name                IN  VARCHAR2 default null,
	    -- p_description         IN  VARCHAR2 default null
	   );

      IF x_success = FND_API.G_TRUE THEN
	      dbg('upload: record created in fnd_grants. grant_guid = '||to_char(x_grant_guid));
	  ELSE
	      dbg('upload: record creation failed');
	      retcode := 'E';
		  RETURN;
      END IF;

    END LOOP;


	-- update status_code column in the interface table to 'UPLOADED'
	dbg('upload: update status_code to UPLOADED in the interface table');
    UPDATE fii_ccc_sec_interface
       SET  status_code = 'UPLOADED',
	        upload_date = g_sys_date,
            last_update_date = g_sys_date,
            last_updated_by = g_user_id,
            last_update_login = g_user_id
      WHERE status_code IS NULL;

    retcode := 'S';
	-- debug msg time stamp of completing this procedure successfully
    IF g_debug_flag = 'Y' THEN
         FII_MESSAGE.Func_Succ(func_name => 'FII_CCC_SEC_UPL_PKG.upload');
    END IF;


END upload;

----------------------------------------------------------------------
-- Upload Company Cost Center Security Data from interface table
-- to fnd_grants
-- Called by concurrent program "Upload Company Cost Center Security"
--
-- CP: FII_CCC_SEC_UPLOAD_C (Upload Company Cost Center Security)
-- Executable: FII_CCC_SEC_UPLOAD_C
-- Execution File Name: FII_CCC_SEC_UPL_PKG.CONC_UPLOAD
-- Resp: Business Intelligence Administrator
-- Request Group: DBI Requests and Reports
-------------------------------------------------------------------
PROCEDURE conc_upload
  (
   errbuf	OUT NOCOPY VARCHAR2,
   retcode	OUT NOCOPY VARCHAR2) IS

   l_record_count NUMBER;
   l_ret_status	  BOOLEAN;

BEGIN

    -- debug msg time stamp of entering this procedure
    IF g_debug_flag = 'Y' THEN
      FII_MESSAGE.Func_Ent('FII_CCC_SEC_UPL_PKG.conc_upload');
    END IF;

   --
   -- check if any data to process, exit if not
   --
   dbg('conc_upload: Check if any data in fii_ccc_sec_interface to process.');
   SELECT count(*) INTO l_record_count
   	 FROM fii_ccc_sec_interface
	WHERE status_code IS null;

   IF l_record_count = 0 THEN
        dbg('conc_upload: No data in the interface table to process. Exit.');
        -- debug msg time stamp of exiting this procedure
        IF g_debug_flag = 'Y' THEN
           FII_MESSAGE.Func_Succ('FII_CCC_SEC_UPL_PKG.conc_upload');
        END IF;
        retcode := 'W';
        errbuf := fnd_message.get_string('FII', 'FII_CCC_SEC_CP_NO_REC_TO_PROCS');
		l_ret_status := FND_CONCURRENT.Set_Completion_Status(status	 => 'WARNING',message => errbuf);
        RETURN;
   END IF;

   --
   -- validate records in fii_ccc_sec_interface table
   --
   dbg('conc_upload: Validate records in fii_ccc_sec_interface table. Calling validate procedure...');

   validate(retcode);

   IF retcode <> 'S' THEN
		-- Commit before returning for status_code
   		dbg('conc_upload: call FND_CONCURRENT.Af_Commit');
        FND_CONCURRENT.Af_Commit;

        retcode := 'E';
   		errbuf := fnd_message.get_string('FII', 'FII_CCC_SEC_CP_VALIDATE_ERR');
		l_ret_status := FND_CONCURRENT.Set_Completion_Status(status	 => 'ERROR',message => errbuf);
		dbg('conc_upload: Data validation failed. Exit.');
		-- debug msg time stamp of exiting this procedure
        IF g_debug_flag = 'Y' THEN
           FII_MESSAGE.Func_Succ('FII_CCC_SEC_UPL_PKG.conc_upload');
        END IF;
   		RETURN;
   END IF;

   --
   -- upload into fnd_grants
   --
   dbg('conc_upload: Upload data in interface table into fnd_grants. Calling upload procedure...');

   upload(retcode);

   IF retcode <> 'S' THEN
   		errbuf := fnd_message.get_string('FII', 'FII_CCC_SEC_CP_UPLOAD_ERR');
		l_ret_status := FND_CONCURRENT.Set_Completion_Status(status	 => 'ERROR',message => errbuf);
		dbg('conc_upload: Upload to fnd_grants process failed. Exit.');
		-- debug msg time stamp of exiting this procedure
        IF g_debug_flag = 'Y' THEN
           FII_MESSAGE.Func_Succ('FII_CCC_SEC_UPL_PKG.conc_upload');
        END IF;
   		RETURN;
   END IF;

   -- debug msg time stamp of completing this procedure successfully
   IF g_debug_flag = 'Y' THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_CCC_SEC_UPL_PKG.conc_upload');
   END IF;
   l_ret_status := FND_CONCURRENT.Set_Completion_Status
	        	   (status	 => 'COMPLETE', message => NULL);
EXCEPTION
   WHEN OTHERS THEN
   	  dbg('conc_upload: Unexpected error during concurrent upload process.');
      retcode := 'E';
      errbuf := fnd_message.get_string('FII', 'FII_CCC_SEC_CP_OTHERS_ERR');
      l_ret_status := FND_CONCURRENT.Set_Completion_Status(status	 => 'ERROR',message => errbuf);
      app_exception.raise_exception;
END conc_upload;



--------------------------------------------------------------------------
-- Purge interface table FII_CCC_SEC_INTERFACE
-- Called by concurrent program
-- "Purge Company Cost Center Security Interface Table"
--
-- CP: FII_CCC_SEC_PURGE_C
-- Purge Company Cost Center Security Interface Table
-- Executable: FII_CCC_SEC_PURGE_C
-- Execution File Name: FII_CCC_SEC_UPL_PKG.purge_interface
-- Resp: Business Intelligence Administrator
-- Request Group: DBI Requests and Reports
----------------------------------------------------------------------
PROCEDURE purge_interface
  (
   errbuf	OUT NOCOPY VARCHAR2,
   retcode	OUT NOCOPY VARCHAR2) IS

   l_record_count  NUMBER;
   l_ret_status	   BOOLEAN;
   l_trunc_retcode VARCHAR2(6);

BEGIN

    -- debug msg time stamp of entering this procedure
    IF g_debug_flag = 'Y' THEN
      FII_MESSAGE.Func_Ent('FII_CCC_SEC_UPL_PKG.purge_interface');
    END IF;

   --
   -- purge fii_ccc_sec_interface table
   --
   dbg('purge_interface: truncate fii_ccc_sec_interface table.');
   fii_util.truncate_table('FII_CCC_SEC_INTERFACE', 'FII', l_trunc_retcode);


   IF l_trunc_retcode = -1 THEN
        dbg('purge_interface: purge interface table failed. Exit.');
        -- debug msg time stamp of exiting this procedure
        IF g_debug_flag = 'Y' THEN
           FII_MESSAGE.Func_Succ('FII_CCC_SEC_UPL_PKG.purge_interface');
        END IF;
        retcode := 'E';
        errbuf := fnd_message.get_string('FII', 'FII_CCC_SEC_PURGE_INTR_FAILED');
		l_ret_status := FND_CONCURRENT.Set_Completion_Status(status	 => 'ERROR',message => errbuf);
        RETURN;
   ELSE
        -- debug msg time stamp of completing this procedure successfully
        IF g_debug_flag = 'Y' THEN
           FII_MESSAGE.Func_Succ(func_name => 'FII_CCC_SEC_UPL_PKG.purge_interface');
        END IF;
        l_ret_status := FND_CONCURRENT.Set_Completion_Status
	        	       (status	 => 'COMPLETE', message => NULL);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   	  dbg('purge_interface: Unexpected error during purge process.');
      retcode := 'E';
      errbuf := fnd_message.get_string('FII', 'FII_CCC_SEC_CP_PURGE_ERR');
      l_ret_status := FND_CONCURRENT.Set_Completion_Status(status	 => 'ERROR',message => errbuf);
      app_exception.raise_exception;
END purge_interface;


END FII_CCC_SEC_UPL_PKG;


/
