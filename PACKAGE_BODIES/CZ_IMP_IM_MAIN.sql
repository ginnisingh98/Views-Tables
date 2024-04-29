--------------------------------------------------------
--  DDL for Package Body CZ_IMP_IM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_IM_MAIN" AS
/*	$Header: cziimmnb.pls 120.1 2006/06/22 16:27:25 asiaston ship $		*/


PROCEDURE CND_ITEM_MASTER (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
 DECLARE
		CURSOR c_imp_itemmaster IS
                        SELECT DELETED_FLAG, SRC_APPLICATION_ID, SRC_TYPE_CODE, DECIMAL_QTY_FLAG, ROWID
                        FROM CZ_IMP_ITEM_MASTER
                        WHERE REC_STATUS IS NULL
                        AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_itemmaster   					c_imp_itemmaster%ROWTYPE;
		x_imp_itemmaster_f					BOOLEAN:=FALSE;

 BEGIN

  OPEN 	c_imp_itemmaster;
  LOOP
	FETCH c_imp_itemmaster INTO p_imp_itemmaster;
	x_imp_itemmaster_f:=c_imp_itemmaster%FOUND;

	EXIT WHEN NOT x_imp_itemmaster_f;
    IF (FAILED >= MAX_ERR) THEN
         x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_MAIN.CND_ITEM_MASTER:MAX',11276,inRun_Id);
         RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
    END IF;

	IF (p_imp_itemmaster.DELETED_FLAG IS NULL) THEN
 		 BEGIN
                   UPDATE CZ_IMP_ITEM_MASTER
                   SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG)
                   WHERE ROWID = p_imp_itemmaster.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
		 EXCEPTION
		  WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_MASTER',11276,inRun_ID);
			FAILED:=FAILED+1;
		  END;
	END IF;

	IF (p_imp_itemmaster.DECIMAL_QTY_FLAG IS NULL) THEN
 		 BEGIN
                   UPDATE CZ_IMP_ITEM_MASTER SET DECIMAL_QTY_FLAG = '0'
                   WHERE ROWID = p_imp_itemmaster.ROWID;

				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
		 EXCEPTION
		  WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_MASTER',11276,inRun_ID);
			FAILED:=FAILED+1;
		  END;
	END IF;

        IF (p_imp_itemmaster.SRC_APPLICATION_ID IS NULL AND p_imp_itemmaster.SRC_TYPE_CODE IS NULL) THEN
		BEGIN
                   UPDATE CZ_IMP_ITEM_MASTER
                   SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG),
                       SRC_APPLICATION_ID = cnDefSrcAppId,
                       SRC_TYPE_CODE = cnDefSrcTypeCode
                   WHERE ROWID = p_imp_itemmaster.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
		EXCEPTION
		 WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_MASTER',11276,inRun_ID);
			FAILED:=FAILED+1;
		END;
        ELSIF (p_imp_itemmaster.SRC_APPLICATION_ID IS NULL) THEN
		BEGIN
                   UPDATE CZ_IMP_ITEM_MASTER
                   SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG),
                       SRC_APPLICATION_ID = cnDefSrcAppId
                   WHERE ROWID = p_imp_itemmaster.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
		EXCEPTION
		 WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_MASTER',11276,inRun_ID);
			FAILED:=FAILED+1;
		END;
        ELSIF (p_imp_itemmaster.SRC_TYPE_CODE IS NULL) THEN
		BEGIN
                   UPDATE CZ_IMP_ITEM_MASTER
                   SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG),
                       SRC_TYPE_CODE = cnDefSrcTypeCode
                   WHERE ROWID = p_imp_itemmaster.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
		EXCEPTION
		 WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_MASTER',11276,inRun_ID);
			FAILED:=FAILED+1;
		END;
        END IF;

   END LOOP;
   CLOSE c_imp_itemmaster;

 EXCEPTION
         WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
	 WHEN OTHERS THEN
	  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_MASTER',11276,inRun_ID);
 END;

END CND_ITEM_MASTER ;


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE CND_ITEM_PROPERTY_VALUE (inRUN_ID 		IN 	       PLS_INTEGER,
				   COMMIT_SIZE		IN     	       PLS_INTEGER,
			   	   MAX_ERR		IN 	       PLS_INTEGER,
				   FAILED		IN  OUT NOCOPY PLS_INTEGER
				  ) IS
        CURSOR c_imp_itempropertyvalue IS
        SELECT a.DELETED_FLAG,a.PROPERTY_VALUE,a.PROPERTY_NUM_VALUE,
        a.FSK_PROPERTY_1_1,a.FSK_PROPERTY_1_EXT,a.ORIG_SYS_REF,a.DISPOSITION,a.REC_STATUS,b.data_type
        FROM CZ_IMP_ITEM_PROPERTY_VALUE a, cz_properties b
        WHERE a.REC_STATUS IS NULL AND a.RUN_ID = inRUN_ID
        AND (b.orig_sys_ref = a.fsk_property_1_1 OR b.orig_sys_ref = a.fsk_property_1_ext)
        AND b.deleted_flag='0';

	/* Internal vars */
	nCommitCount				PLS_INTEGER:=0;			/*COMMIT buffer index */
	nErrorCount				PLS_INTEGER:=0;			/*Error index */
	nDups					PLS_INTEGER:=0;			/*Dupl records */
	x_error					BOOLEAN:=FALSE;
	/*Cursor Var for Import */
	p_imp_itempropertyvalue   		c_imp_itempropertyvalue%ROWTYPE;
	x_imp_itempropertyvalue_f		BOOLEAN:=FALSE;
        xERROR                                  BOOLEAN:=FALSE;

        TYPE tPropertyValue    IS TABLE OF cz_imp_item_property_value.property_value%TYPE INDEX BY BINARY_INTEGER;
        TYPE tPropertyNumValue IS TABLE OF cz_imp_item_property_value.property_num_value%TYPE INDEX BY BINARY_INTEGER;
        TYPE tFskProperty      IS TABLE OF cz_imp_item_property_value.fsk_property_1_1%TYPE INDEX BY BINARY_INTEGER;
        TYPE tFskPropertyExt   IS TABLE OF cz_imp_item_property_value.fsk_property_1_ext%TYPE INDEX BY BINARY_INTEGER;
        TYPE tFskItemMaster    IS TABLE OF cz_imp_item_property_value.fsk_itemmaster_2_1%TYPE INDEX BY BINARY_INTEGER;
        TYPE tDisposition      IS TABLE OF cz_imp_item_property_value.disposition%TYPE INDEX BY BINARY_INTEGER;
        TYPE tRecStatus        IS TABLE OF cz_imp_item_property_value.rec_status%TYPE INDEX BY BINARY_INTEGER;
        TYPE tDeletedFlag      IS TABLE OF cz_imp_item_property_value.deleted_flag%TYPE INDEX BY BINARY_INTEGER;
        TYPE tOrigSysRef       IS TABLE OF cz_imp_item_property_value.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
        TYPE tDataType         IS TABLE OF cz_properties.data_type%TYPE INDEX BY BINARY_INTEGER;

        iFskProperty           tFskProperty;
        iFskPropertyExt        tFskPropertyExt;
        iOrigSysRef            tOrigSysRef;
        iPropertyValue         tPropertyValue;
        iPropertyNumValue      tPropertyNumValue;
        iFskItemMaster         tFskItemMaster;
        iDisposition           tDisposition;
        iRecStatus             tRecStatus;
        iDeletedFlag           tDeletedFlag;
        iDataType              tDataType;

        st_time                NUMBER;
        end_time               NUMBER;
        loop_end_time          NUMBER;
        insert_end_time        NUMBER;

BEGIN
   OPEN c_imp_itempropertyvalue;
   LOOP
       iDeletedFlag.delete;               iFskProperty.delete;
       iPropertyValue.delete;             iRecStatus.delete;
       iPropertyNumValue.delete;          iDisposition.delete;
       iFskPropertyExt.delete;            iDataType.delete;

       FETCH c_imp_itempropertyvalue BULK COLLECT INTO
       iDeletedFlag,iPropertyValue,iPropertyNumValue,
       iFskProperty,iFskPropertyExt,iOrigSysRef,iDisposition,iRecStatus,iDataType
       LIMIT COMMIT_SIZE;
       EXIT WHEN iDeletedFlag.COUNT = 0 AND c_imp_itempropertyvalue%NOTFOUND;

       IF iDeletedFlag.COUNT > 0 THEN

            IF (FAILED >= MAX_ERR) THEN
              x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,
                                          'CZ_IMP_IM_MAIN.CND_ITEM_PROPERTY_VALUE:MAX',11276,inRun_Id);
              RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
            END IF;
            FOR i IN iDeletedFlag.FIRST..iDeletedFlag.LAST LOOP
                IF iDeletedFlag(i) IS NULL THEN
                  iDeletedFlag(i) := '0';
                END IF;

                IF (iPropertyValue(i) IS NULL AND iPropertyNumValue(i) IS NULL) THEN
                     iDisposition(i) := 'R';
                     iRecStatus(i) := 'FAIL';
                     FAILED := FAILED + 1;
                     xERROR:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_NULL_PROPVAL',
                                                                   'PROPNAME',iFskProperty(i))||iFskPropertyExt(i),
                                                 1,'EXTR_ITEM_PROPERTY_VALUES',11276,inRun_ID);
                END IF;
                BEGIN
                    IF (iDataType(i) = 2 AND iPropertyValue(i) IS NOT NULL AND iPropertyNumValue(i) IS NULL) THEN
                      iPropertyNumValue(i) := TO_NUMBER(iPropertyValue(i));
                      iPropertyValue(i) := NULL;
                    END IF;
                EXCEPTION
                  WHEN VALUE_ERROR THEN
                     iDisposition(i) := 'R';
                     iRecStatus(i) := 'FAIL';
                     FAILED := FAILED + 1;
                     xERROR:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_PROPVAL',
                                                                   'PROPNAME',iFskProperty(i)||iFskPropertyExt(i),
                                                                   'PROPVAL',iPropertyValue(i)),
                                                 1,'EXTR_ITEM_PROPERTY_VALUES',11276,inRun_ID);
                END;
            END LOOP;
            FORALL i IN iDeletedFlag.FIRST..iDeletedFlag.LAST
                 UPDATE cz_imp_item_property_value
                    SET deleted_flag = iDeletedFlag(i),
                        property_value = iPropertyValue(i),
                        property_num_value = iPropertyNumValue(i),
                        disposition = iDisposition(i),
                        rec_status = iRecStatus(i)
                  WHERE orig_sys_ref = iOrigSysRef(i)
                    AND run_id = inRun_id
                    AND rec_status IS NULL;
       END IF;
   END LOOP;
   CLOSE c_imp_itempropertyvalue;
EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
  WHEN OTHERS THEN
   x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_PROPERTY_VALUE',11276,inRun_ID);
    RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END CND_ITEM_PROPERTY_VALUE ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_ITEM_TYPE (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_itemtype IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_ITEM_TYPE WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_itemtype   				c_imp_itemtype%ROWTYPE;
		x_imp_itemtype_f				BOOLEAN:=FALSE;

	BEGIN
		OPEN 	c_imp_itemtype;
		LOOP
			FETCH c_imp_itemtype INTO p_imp_itemtype;
			x_imp_itemtype_f:=c_imp_itemtype%FOUND;

		EXIT WHEN NOT x_imp_itemtype_f;
    IF (FAILED >= MAX_ERR) THEN
         x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_MAIN.CND_ITEM_TYPE:MAX',11276,inRun_Id);
         RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
    END IF;

		IF (p_imp_itemtype.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_ITEM_TYPE SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_itemtype.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_TYPE',11276,inRun_ID);
				FAILED:=FAILED+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_itemtype;

	EXCEPTION
         WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
	 WHEN OTHERS THEN
	  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_TYPE',11276,inRun_ID);
	END;

END CND_ITEM_TYPE;


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_ITEM_TYPE_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_itemtypeprop IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_ITEM_TYPE_PROPERTY WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_itemtypeprop   				c_imp_itemtypeprop%ROWTYPE;
		x_imp_itemtypeprop_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_itemtypeprop;
		LOOP
			FETCH c_imp_itemtypeprop INTO p_imp_itemtypeprop;
			x_imp_itemtypeprop_f:=c_imp_itemtypeprop%FOUND;

		EXIT WHEN NOT x_imp_itemtypeprop_f;
    IF (FAILED >= MAX_ERR) THEN
         x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_MAIN.CND_ITEM_TYPE_PROPERTY:MAX',11276,inRun_Id);
         RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
    END IF;

		IF (p_imp_itemtypeprop.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_ITEM_TYPE_PROPERTY SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_itemtypeprop.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_TYPE_PROPERTY',11276,inRun_ID);
				FAILED:=FAILED+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_itemtypeprop;

	EXCEPTION
         WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
	 WHEN OTHERS THEN
	  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_ITEM_TYPE_PROPERTY',11276,inRun_ID);
	END;

END CND_ITEM_TYPE_PROPERTY;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/



PROCEDURE CND_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		IN  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_property IS
                        SELECT DELETED_FLAG, DATA_TYPE, ROWID
                        FROM CZ_IMP_property WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_property   				c_imp_property%ROWTYPE;
		x_imp_property_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_property;
		LOOP
			FETCH c_imp_property INTO p_imp_property;
			x_imp_property_f:=c_imp_property%FOUND;

		EXIT WHEN NOT x_imp_property_f;
    IF (FAILED >= MAX_ERR) THEN
         x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_MAIN.CND_PROPERTY:MAX',11276,inRun_Id);
         RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
    END IF;

		IF (p_imp_property.DELETED_FLAG IS NULL) THEN
 		 BEGIN
                  UPDATE CZ_IMP_property SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_property.ROWID;
	 	  nCOmmitCount:=nCommitCount+1;
		  /* COMMIT if the buffer size is reached */
	 	  IF (nCommitCount>= COMMIT_SIZE) THEN
			COMMIT;
			nCommitCount:=0;
		  END IF;
		EXCEPTION
		 WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_PROPERTY',11276,inRun_ID);
			FAILED:=FAILED+1;
		END;
	       END IF;

		IF (p_imp_property.DATA_TYPE IS NULL) THEN
 		 BEGIN

                  UPDATE CZ_IMP_property SET DATA_TYPE = 4 WHERE ROWID = p_imp_property.ROWID;

	 	  nCOmmitCount:=nCommitCount+1;
		  /* COMMIT if the buffer size is reached */
	 	  IF (nCommitCount>= COMMIT_SIZE) THEN
			COMMIT;
			nCommitCount:=0;
		  END IF;
		EXCEPTION
		 WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_PROPERTY',11276,inRun_ID);
			FAILED:=FAILED+1;
		END;
	       END IF;
	     END LOOP;
	     CLOSE c_imp_property;

	EXCEPTION
         WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
	 WHEN OTHERS THEN
	  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.CND_PROPERTY',11276,inRun_ID);
	END;

END CND_PROPERTY;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE MAIN_ITEM_MASTER (		inRUN_ID 	IN 	PLS_INTEGER,
					COMMIT_SIZE	IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
					DUPS		IN   OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount						PLS_INTEGER:=0;			/*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
		nDups							PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);

   st_time          number;
   end_time         number;
   loop_end_time    number;
   insert_end_time  number;
   d_str            varchar2(255);

	BEGIN

         BEGIN
           SELECT 'X' INTO dummy FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=inRUN_ID;

           UPDATE CZ_XFR_RUN_INFOS SET
            STARTED=SYSDATE,
            LAST_ACTIVITY=SYSDATE
          WHERE RUN_ID=inRUN_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY)
           VALUES(inRUN_ID,SYSDATE,SYSDATE);

           WHEN OTHERS THEN
            x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.MAIN_ITEM_MASTER',11276,inRun_ID);
         END;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

		CZ_IMP_IM_MAIN.CND_ITEM_MASTER (inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     CND item master :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

		CZ_IMP_IM_KRS.KRS_ITEM_MASTER (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     KRS item master :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

			CZ_IMP_IM_XFR.XFR_ITEM_MASTER (inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     XFR item master :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299);
    end if;

			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'IMP_IM.MAIN_ITEM_MASTER ',11276,inRun_ID);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'IMP_IM.MAIN_ITEM_MASTER ',11276,inRun_ID);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

           CZ_IMP_IM_MAIN.RPT_ITEM_MASTER (inRUN_ID);
        END;
END MAIN_ITEM_MASTER ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_ITEM_PROPERTY_VALUE(	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
					DUPS			IN   OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
                nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
                nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);

   st_time          number;
   end_time         number;
   loop_end_time    number;
   insert_end_time  number;
   d_str            varchar2(255);

	BEGIN

         BEGIN
           SELECT 'X' INTO dummy FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=inRUN_ID;

           UPDATE CZ_XFR_RUN_INFOS SET
            STARTED=SYSDATE,
            LAST_ACTIVITY=SYSDATE
          WHERE RUN_ID=inRUN_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY)
           VALUES(inRUN_ID,SYSDATE,SYSDATE);

           WHEN OTHERS THEN
            x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.MAIN_ITEM_PROPERTY_VALUE',11276,inRun_ID);
         END;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

                CZ_IMP_IM_MAIN.CND_ITEM_PROPERTY_VALUE (inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     CND item prop val :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299);
    end if;


    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

		CZ_IMP_IM_KRS.KRS_ITEM_PROPERTY_VALUE (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     KRS item prop val :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

			CZ_IMP_IM_XFR.XFR_ITEM_PROPERTY_VALUE(inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     XFR item prop val :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299);
    end if;

			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IM_MAIN.MAIN_ITEM_PROPERTY_VALUE',11276,inRun_ID);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IM_MAIN.MAIN_ITEM_PROPERTY_VALUE',11276,inRun_ID);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

           CZ_IMP_IM_MAIN.RPT_ITEM_PROPERTY_VALUE(inRUN_ID);
        END;
END MAIN_ITEM_PROPERTY_VALUE ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_ITEM_TYPE  (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
					DUPS			IN   OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
                nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
                nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);

   st_time          number;
   end_time         number;
   loop_end_time    number;
   insert_end_time  number;
   d_str            varchar2(255);

	BEGIN

         BEGIN
           SELECT 'X' INTO dummy FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=inRUN_ID;

           UPDATE CZ_XFR_RUN_INFOS SET
            STARTED=SYSDATE,
            LAST_ACTIVITY=SYSDATE
          WHERE RUN_ID=inRUN_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY)
           VALUES(inRUN_ID,SYSDATE,SYSDATE);

           WHEN OTHERS THEN
            x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.MAIN_ITEM_TYPE',11276,inRun_ID);
         END;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;
                CZ_IMP_IM_MAIN.CND_ITEM_TYPE (inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);
    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     CND item type :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

		CZ_IMP_IM_KRS.KRS_ITEM_TYPE (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     KRS item type :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

			CZ_IMP_IM_XFR.XFR_ITEM_TYPE  (inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     XFR item type :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299);
    end if;

			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IM_MAIN.MAIN_ITEM_TYPE',11276,inRun_ID);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IM_MAIN.MAIN_ITEM_TYPE',11276,inRun_ID);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

          CZ_IMP_IM_MAIN.RPT_ITEM_TYPE(inRUN_ID);
        END;
END MAIN_ITEM_TYPE ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_ITEM_TYPE_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
					DUPS			IN   OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
                nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
                nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);

   st_time          number;
   end_time         number;
   loop_end_time    number;
   insert_end_time  number;
   d_str            varchar2(255);

	BEGIN

         BEGIN
           SELECT 'X' INTO dummy FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=inRUN_ID;

           UPDATE CZ_XFR_RUN_INFOS SET
            STARTED=SYSDATE,
            LAST_ACTIVITY=SYSDATE
          WHERE RUN_ID=inRUN_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY)
           VALUES(inRUN_ID,SYSDATE,SYSDATE);

           WHEN OTHERS THEN
            x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.MAIN_ITEM_TYPE_PROPERTY',11276,inRun_ID);
         END;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

        	CZ_IMP_IM_MAIN.CND_ITEM_TYPE_PROPERTY (inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     CND item type prop :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

		CZ_IMP_IM_KRS.KRS_ITEM_TYPE_PROPERTY (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     KRS item type prop :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

			CZ_IMP_IM_XFR.XFR_ITEM_TYPE_PROPERTY (inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     XFR item type prop :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299);
    end if;

			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IM_MAIN.MAIN_ITEM_TYPE_PROPERTY',11276,inRun_ID);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IM_MAIN.MAIN_ITEM_TYPE_PROPERTY',11276,inRun_ID);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

          CZ_IMP_IM_MAIN.RPT_ITEM_TYPE_PROPERTY(inRUN_ID);
        END;
END MAIN_ITEM_TYPE_PROPERTY ;



/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
					DUPS			IN   OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2,
                                        p_rp_folder_id IN  NUMBER
					) IS
BEGIN
	DECLARE
		/* Interal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);

   st_time          number;
   end_time         number;
   loop_end_time    number;
   insert_end_time  number;
   d_str            varchar2(255);

	BEGIN

         BEGIN
           SELECT 'X' INTO dummy FROM CZ_XFR_RUN_INFOS WHERE RUN_ID=inRUN_ID;

           UPDATE CZ_XFR_RUN_INFOS SET
            STARTED=SYSDATE,
            LAST_ACTIVITY=SYSDATE
          WHERE RUN_ID=inRUN_ID;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY)
           VALUES(inRUN_ID,SYSDATE,SYSDATE);

           WHEN OTHERS THEN
            x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.MAIN_PROPERTY',11276,inRun_ID);
         END;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

                CZ_IMP_IM_MAIN.CND_PROPERTY (inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     CND property :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

		CZ_IMP_IM_KRS.KRS_PROPERTY (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     KRS property :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

			CZ_IMP_IM_XFR.XFR_PROPERTY (inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP, p_rp_folder_id);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     XFR property :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299);
    end if;

			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IM_MAIN.MAIN_PROPERTY',11276,inRun_ID);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IM_MAIN.MAIN_PROPERTY',11276,inRun_ID);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

          CZ_IMP_IM_MAIN.RPT_PROPERTY(inRUN_ID);
        END ;

END MAIN_PROPERTY ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_ITEM_MASTER ( inRUN_ID IN PLS_INTEGER ) AS
                              x_error     BOOLEAN:=FALSE;
    v_table_name  VARCHAR2(30) := 'CZ_ITEM_MASTERS';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_item_master
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
                              ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
                              ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_MASTER',11276,inRun_ID);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>v_ok AND RUN_ID=inRUN_ID
                AND IMP_TABLE=v_table_name;
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED=v_completed
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_MASTER',11276,inRun_ID);
              END;
       EXCEPTION
        WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
         RAISE;
        WHEN OTHERS THEN
         x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_MASTER',11276,inRun_ID);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

  PROCEDURE RPT_ITEM_PROPERTY_VALUE ( inRUN_ID IN PLS_INTEGER ) AS
                                      x_error     BOOLEAN:=FALSE;
    v_table_name  VARCHAR2(30) := 'CZ_ITEM_PROPERTY_VALUES';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_item_property_value
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
                              ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
                              ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_PROPERTY_VALUE',11276,inRun_ID);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>v_ok AND RUN_ID=inRUN_ID
                AND IMP_TABLE=v_table_name;
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED=v_completed
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_PROPERTY_VALUE',11276,inRun_ID);
              END;
       EXCEPTION
        WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
         RAISE;
        WHEN OTHERS THEN
         x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_PROPERTY_VALUE',11276,inRun_ID);
  END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

  PROCEDURE RPT_ITEM_TYPE ( inRUN_ID IN PLS_INTEGER ) AS
                            x_error     BOOLEAN:=FALSE;
    v_table_name  VARCHAR2(30) := 'CZ_ITEM_TYPES';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_item_type
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
                              ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
                              ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_TYPE',11276,inRun_ID);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>v_ok AND RUN_ID=inRUN_ID
                AND IMP_TABLE=v_table_name;
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED=v_completed
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_TYPE',11276,inRun_ID);
              END;
       EXCEPTION
        WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
        WHEN OTHERS THEN
          x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_TYPE',11276,inRun_ID);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

  PROCEDURE RPT_ITEM_TYPE_PROPERTY ( inRUN_ID IN PLS_INTEGER ) AS
                                     x_error     BOOLEAN:=FALSE;
    v_table_name  VARCHAR2(30) := 'CZ_ITEM_TYPE_PROPERTIES';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_item_type_property
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
                              ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
                              ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_TYPE_PROPERTY',11276,inRun_ID);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>v_ok AND RUN_ID=inRUN_ID
                AND IMP_TABLE=v_table_name;
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED=v_completed
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_TYPE_PROPERTY',11276,inRun_ID);
              END;
       EXCEPTION
        WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
        WHEN OTHERS THEN
          x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_ITEM_TYPE_PROPERTY',11276,inRun_ID);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_PROPERTY ( inRUN_ID IN PLS_INTEGER ) AS
                           x_error     BOOLEAN:=FALSE;
    v_table_name  VARCHAR2(30) := 'CZ_PROPERTIES';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_property
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
                              ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
                              ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_PROPERTY',11276,inRun_ID);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>v_ok AND RUN_ID=inRUN_ID
                AND IMP_TABLE=v_table_name;
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED=v_completed
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_PROPERTY',11276,inRun_ID);
              END;
       EXCEPTION
        WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
        WHEN OTHERS THEN
          x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_MAIN.RPT_PROPERTY',11276,inRun_ID);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

END CZ_IMP_IM_MAIN;

/
