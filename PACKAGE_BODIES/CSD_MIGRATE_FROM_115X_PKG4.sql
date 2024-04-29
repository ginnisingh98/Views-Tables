--------------------------------------------------------
--  DDL for Package Body CSD_MIGRATE_FROM_115X_PKG4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MIGRATE_FROM_115X_PKG4" 
/* $Header: csdmig4b.pls 120.1 2007/04/24 18:51:06 rfieldma ship $ */
AS

    /*-------------------------------------------------------------------------------*/

    /* procedure name: CSD_GENERIC_MESSAGES_MIG4                                      */

    /* description   : procedure for migrating CSD_GENERIC_ERRMSGS table data        */

    /*                 from 11.5.9 to 11.5.10                                        */

    /*                                                                               */

    /*-------------------------------------------------------------------------------*/

    PROCEDURE csd_generic_messages_mig4
    IS


	   --Changed since the 8i does no tsupport the collections type.
        --TYPE SN_ERRS_REC_ARRAY_TYPE IS VARRAY(1000) OF CSD.CSD_MASS_RO_SN_ERRORS%ROWTYPE;
        TYPE MRS_ERROR_ID_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.MASS_RO_SN_ERROR_ID%TYPE;
        TYPE MASS_RO_SN_ID_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.MASS_RO_SN_ID%TYPE;
        TYPE REPAIR_LINE_ID_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.REPAIR_LINE_ID%TYPE;
        TYPE ERROR_TYPE_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.ERROR_TYPE%TYPE;
        TYPE ERROR_MSG_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.ERROR_MSG%TYPE;
        TYPE CREATED_BY_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.CREATED_BY%TYPE;
        TYPE CREATION_DT_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.CREATION_DATE%TYPE;
        TYPE LAST_UPD_BY_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.LAST_UPDATED_BY%TYPE;
        TYPE LAST_UPD_DT_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.LAST_UPDATE_DATE%TYPE;
        TYPE LAST_UPD_LGN_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.LAST_UPDATE_LOGIN%TYPE;
        TYPE OBJ_VER_NUM_ARRAY_TYPE IS VARRAY(1000)
	               OF CSD.CSD_MASS_RO_SN_ERRORS.OBJECT_VERSION_NUMBER%TYPE;

        --sn_errors_arr        SN_ERRS_REC_ARRAY_TYPE;
	   mrs_error_id_arr      MRS_ERROR_ID_ARRAY_TYPE;
	   mASS_RO_SN_id_arr      MASS_RO_SN_ID_ARRAY_TYPE;
        REPAIR_LINE_ID_arr REPAIR_LINE_ID_ARRAY_TYPE ;
        ERROR_TYPE_arr ERROR_TYPE_ARRAY_TYPE ;
        ERROR_MSG_arr ERROR_MSG_ARRAY_TYPE ;
        CREATED_BY_arr CREATED_BY_ARRAY_TYPE ;
        CREATION_DT_arr CREATION_DT_ARRAY_TYPE ;
        LAST_UPD_BY_arr LAST_UPD_BY_ARRAY_TYPE ;
        LAST_UPD_DT_arr LAST_UPD_DT_ARRAY_TYPE ;
        LAST_UPD_LGN_arr LAST_UPD_LGN_ARRAY_TYPE ;
        OBJ_VER_NUM_arr OBJ_VER_NUM_ARRAY_TYPE ;




        v_min                NUMBER;
        v_max                NUMBER;
        v_error_text         VARCHAR2(2000);
        MAX_BUFFER_SIZE      NUMBER                 := 500;
        l_generic_errmsgs_id NUMBER;
        error_process EXCEPTION;
        l_dummy varchar2(1);

        CURSOR get_mass_sn_errors
        IS
          SELECT
			MASS_RO_SN_ERROR_ID, REPAIR_LINE_ID, MASS_RO_SN_ID,
			ERROR_TYPE, ERROR_MSG, CREATED_BY,
            CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
            lAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER
          FROM   csd_mass_ro_sn_errors;

        CURSOR cur_check_exists(p_rep_line_id NUMBER, p_id2 NUMBER) IS
          SELECT 'x'
          FROM CSD_GENERIC_ERRMSGS
          WHERE MODULE_CODE ='SN'
          AND SOURCE_ENTITY_ID1= p_rep_line_id
          AND SOURCE_ENTITY_ID2 = p_id2
          AND SOURCE_ENTITY_TYPE_CODE = 'SERIAL_NUMBER';

    BEGIN

        -- Migration code for Generic Error messages
        OPEN get_mass_sn_errors;

	   if( FND_LOG.LEVEL_PROCEDURE >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
						 'CSD.PLSQL.CSD_Migrate_From_115X_PKG4.csd_generic_messages_mig4',
						 'Opened the input cursor');
	   end if;

        LOOP
            --FETCH get_mass_sn_errors BULK COLLECT INTO sn_errors_arr LIMIT MAX_BUFFER_SIZE;
            FETCH get_mass_sn_errors BULK COLLECT INTO
		           MRS_ERROR_ID_arr, REPAIR_LINE_ID_arr, MASS_RO_SN_ID_arr,
                   ERROR_TYPE_arr,   ERROR_MSG_arr, CREATED_BY_arr,
                   CREATION_DT_arr,  LAST_UPD_BY_arr,LAST_UPD_DT_arr,
                   LAST_UPD_LGN_arr, OBJ_VER_NUM_arr;
            --FOR j IN 1..sn_errors_arr.COUNT
            FOR j IN 1..mrs_error_id_arr.COUNT
                LOOP
                    SAVEPOINT CSD_MASS_RO_SN_ERRORS;

               	   if( FND_LOG.LEVEL_PROCEDURE >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               			 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
               						 'CSD.PLSQL.CSD_Migrate_From_115X_PKG4.csd_generic_messages_mig4',
               						 'SAving in the record in the new table,j['
                                     ||j||']');
               	   end if;
                    BEGIN
                        --OPEN cur_check_exists(sn_errors_arr(j).repair_line_id,sn_errors_arr(j).mass_ro_sn_id);
                        OPEN cur_check_exists(repair_line_id_arr(j),mass_ro_sn_id_arr(j));
                        FETCH cur_check_exists INTO l_dummy;
                        IF(cur_check_exists%NOTFOUND) THEN

				    /* rfieldma forward port 5600336
				    base r10 bug#5598542
				      l_generic_errmsgs_id is initialized to null, because PX_GENERIC_ERRMSGS_ID is 'in-out'
					 parameter. Without re initialization it would retain the value from last call and
					 would cause the unique constraint violation error.
				    */
				    l_generic_errmsgs_id :=NULL;
                            APPS.CSD_GENERIC_ERRMSGS_PKG.INSERT_ROW(PX_GENERIC_ERRMSGS_ID     => l_generic_errmsgs_id,
                                              P_MODULE_CODE             => 'SN',
                                              --P_SOURCE_ENTITY_ID1       => sn_errors_arr(j).repair_line_id,
                                              P_SOURCE_ENTITY_ID1       => repair_line_id_arr(j),
                                              --P_SOURCE_ENTITY_ID2       => sn_errors_arr(j).mass_ro_sn_id,
                                              P_SOURCE_ENTITY_ID2       => mass_ro_sn_id_arr(j),
                                              P_SOURCE_ENTITY_TYPE_CODE => 'SERIAL_NUMBER',
                                              P_MSG_TYPE_CODE           => 'E',
                                              --P_MSG                     => sn_errors_arr(j).ERROR_MSG,
                                              P_MSG                     => ERROR_MSG_arr(j),
                                              P_MSG_STATUS              => 'O',
                                              P_CREATED_BY              => fnd_global.user_id,
                                              P_CREATION_DATE           => sysdate,
                                              P_LAST_UPDATED_BY         => fnd_global.user_id,
                                              P_LAST_UPDATE_DATE        => sysdate,
                                              P_LAST_UPDATE_LOGIN       => fnd_global.login_id,
                                              P_OBJECT_VERSION_NUMBER   => 1);
                            IF SQL%NOTFOUND
                                THEN
                                    RAISE error_process;
                            END IF;
                        END IF;
                        CLOSE cur_check_exists;


                        EXCEPTION
                            WHEN error_process THEN
                                CLOSE cur_check_exists;
                                ROLLBACK TO CSD_MASS_RO_SN_ERRORS;
                                v_error_text := substr(sqlerrm, 1, 1000)
                                                || 'Mass ro sn Id:'
                                                --|| sn_errors_arr(j).mass_ro_sn_error_id;
                                                || mrs_error_id_arr(j);

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_MASS_RO_SN_ERRORS',
                                            'CSD_GENERIC_ERRMSGS',
                                            --sn_errors_arr(j).mass_ro_sn_error_id,
                                            mrs_error_id_arr(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

						        commit;

                           		raise_application_error( -20000, 'Error while migrating CSD_GENERIC_ERRMSGS table data: Error while inserting into CSD_GENERIC_ERRMSGS. '|| v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_mass_sn_errors%NOTFOUND;
        END LOOP;

        IF get_mass_sn_errors%ISOPEN
            THEN
                CLOSE get_mass_sn_errors;
        END IF;
        COMMIT;

  END csd_generic_messages_mig4;



END CSD_Migrate_From_115X_PKG4;

/
