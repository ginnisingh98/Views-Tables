--------------------------------------------------------
--  DDL for Package Body CZ_IMP_IM_KRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_IM_KRS" AS
/*	$Header: cziimkrb.pls 120.5.12010000.2 2008/09/29 17:27:31 kksriram ship $		  */


PROCEDURE KRS_ITEM_MASTER(inRUN_ID 	  IN 	PLS_INTEGER,
                          COMMIT_SIZE IN  PLS_INTEGER,
				  MAX_ERR	  IN 	PLS_INTEGER,
				  INSERTS	    OUT NOCOPY PLS_INTEGER,
				  UPDATES	  OUT NOCOPY PLS_INTEGER,
				  FAILED	  IN  OUT NOCOPY PLS_INTEGER,
				  DUPS	    OUT NOCOPY PLS_INTEGER,
                          inXFR_GROUP       IN    VARCHAR2
				 ) IS
BEGIN
  DECLARE
    CURSOR c_imp_itemmaster(x_usesurr_itemtype pls_integer) IS
     SELECT ORIG_SYS_REF, SRC_APPLICATION_ID, SRC_TYPE_CODE,
      DECODE(x_usesurr_itemtype,0,FSK_ITEMTYPE_1_1,1,FSK_ITEMTYPE_1_EXT), ROWID
     FROM CZ_IMP_ITEM_MASTER
     WHERE REC_STATUS IS NULL AND RUN_ID=inRUN_ID
     ORDER BY 1,2,ROWID;

    v_settings_id      VARCHAR2(40);
    v_section_name     VARCHAR2(30);

    CURSOR C_ITEM_TYPE_ID IS
     SELECT VALUE FROM CZ_DB_SETTINGS
     WHERE SECTION_NAME=v_section_name
       AND SETTING_ID=v_settings_id;

    CURSOR C_ITEM_TYPE(nItemTypeId PLS_INTEGER) IS
     SELECT 'F' FROM CZ_ITEM_TYPES
     WHERE ITEM_TYPE_ID=nItemTypeId;

  /* cursor's data found indicator */
  x_imp_itemmaster_itemid_f		BOOLEAN:=FALSE;
  x_onl_itemtype_itemtypeid_f		BOOLEAN:=FALSE;
  x_onl_itemmaster_itemid_f		BOOLEAN:=FALSE;
  x_onl_default_itemtypeid_f        BOOLEAN:=FALSE;
  x_error					BOOLEAN:=FALSE;
  sDfltItemTypeId                   CZ_DB_SETTINGS.VALUE%TYPE;
  nOnlItemId                        CZ_IMP_ITEM_MASTER.ITEM_ID%TYPE;
  nOnlItemTypeId                    CZ_IMP_ITEM_MASTER.ITEM_TYPE_ID%TYPE;
  nDfltItemTypeId                   CZ_IMP_ITEM_MASTER.ITEM_TYPE_ID%TYPE;
  sImpOrigSysRef                    CZ_IMP_ITEM_MASTER.ORIG_SYS_REF%TYPE;
  sFSKITEMTYPE                      CZ_IMP_ITEM_MASTER.FSK_ITEMTYPE_1_1%TYPE;
  sLastFSK                          CZ_IMP_ITEM_MASTER.REF_PART_NBR%TYPE;
  sThisFSK                          CZ_IMP_ITEM_MASTER.REF_PART_NBR%TYPE;
  sRecStatus                        CZ_IMP_ITEM_MASTER.REC_STATUS%TYPE;
  sDisposition                      CZ_IMP_ITEM_MASTER.DISPOSITION%TYPE;
  nImpSrcApplicationId              CZ_IMP_ITEM_MASTER.SRC_APPLICATION_ID%TYPE;
  nImpSrcTypeCode                   CZ_IMP_ITEM_MASTER.SRC_TYPE_CODE%TYPE;

  p_onl_itemtype_itemtypeid		CHAR(1);
  /* Internal vars */
  nCommitCount				PLS_INTEGER:=0;	/*COMMIT buffer index */
  nErrorCount				PLS_INTEGER:=0;	/*Error index */
  nInsertCount				PLS_INTEGER:=0;	/*Inserts */
  nUpdateCount				PLS_INTEGER:=0;	/*Updates */
  nDups					PLS_INTEGER:=0;	/*Dupl records */

  x_usesurr_itemtype			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_TYPES',inXFR_GROUP);
  nAllocateBlock                    PLS_INTEGER:=1;
  nAllocateCounter                  PLS_INTEGER;
  nNextValue                        NUMBER;

  thisRowId                         ROWID;

  BEGIN

    v_settings_id := 'OracleSequenceIncr';
    v_section_name := 'SCHEMA';

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

    v_settings_id := 'IMPORT_ITEM_TYPE';
    v_section_name := 'ORAAPPS_INTEGRATE';

    OPEN C_ITEM_TYPE_ID;
    FETCH C_ITEM_TYPE_ID INTO sDfltItemTypeId;
    IF(C_ITEM_TYPE_ID%NOTFOUND)THEN
     nOnlItemTypeId:=0;
    ELSIF CZ_UTILS.ISNUM(sDfltItemTypeId)=TRUE THEN
     nOnlItemTypeId:=TO_NUMBER(sDfltItemTypeId);
    ELSE
     nOnlItemTypeId:=0;
    END IF;
    CLOSE C_ITEM_TYPE_ID;

    nDfltItemTypeId := nOnlItemTypeId;

    OPEN C_ITEM_TYPE(nOnlItemTypeId);
    FETCH C_ITEM_TYPE INTO p_onl_itemtype_itemtypeid;
    x_onl_default_itemtypeid_f:=C_ITEM_TYPE%FOUND;
    CLOSE C_ITEM_TYPE;

    OPEN c_imp_itemmaster(x_usesurr_itemtype) ;
	LOOP
	/* COMMIT if the buffer size is reached */
	 IF(nCommitCount>= COMMIT_SIZE) THEN
	  BEGIN
		COMMIT;
		nCommitCount:=0;
	  END;
	 ELSE
		nCOmmitCount:=nCommitCount+1;
	 END IF;

	sImpOrigSysRef:=NULL; sfskitemtype:=NULL;
	FETCH c_imp_itemmaster  INTO sImpOrigSysRef,
        nImpSrcApplicationId, nImpSrcTypeCode, sfskitemtype, thisRowId;
	sThisFSK:=sImpOrigSysRef;
	x_imp_itemmaster_itemid_f:=c_imp_itemmaster%FOUND;
	EXIT WHEN NOT x_imp_itemmaster_itemid_f;

	/* Check The Item Data from Online Dbase */
	DECLARE
	  CURSOR c_onl_itemmaster IS
	   SELECT ITEM_ID FROM CZ_ITEM_MASTERS
         WHERE ORIG_SYS_REF=sImpOrigSysRef
         AND SRC_APPLICATION_ID=nImpSrcApplicationId;

	BEGIN
	 OPEN  c_onl_itemmaster;
	 nOnlItemId:=NULL;
	 FETCH c_onl_itemmaster INTO  nOnlItemId;
	 x_onl_itemmaster_itemid_f:=c_onl_itemmaster%FOUND;
	 CLOSE c_onl_itemmaster;
	END;

	/* Make sure that Item_Type_Id exists for this item in ITEM_TYPE table */
	/* The following if is necessary because DECODE does not take BOOLEAN vars */
	DECLARE
  	 CURSOR c_onl_itemtype_itemtypeid IS
	  SELECT ITEM_TYPE_ID FROM CZ_ITEM_TYPES WHERE ORIG_SYS_REF=sFSKITEMTYPE;
	BEGIN
	 nOnlItemTypeId := nDfltItemTypeId;
       IF(sFSKITEMTYPE IS NOT NULL)THEN
  	  OPEN c_onl_itemtype_itemtypeid;
	  FETCH c_onl_itemtype_itemtypeid INTO nOnlItemTypeId;
	  x_onl_itemtype_itemtypeid_f:=c_onl_itemtype_itemtypeid%FOUND;
	  CLOSE c_onl_itemtype_itemtypeid;
       END IF;
       IF(NOT x_onl_itemtype_itemtypeid_f)THEN
        x_onl_itemtype_itemtypeid_f:=x_onl_default_itemtypeid_f;
       END IF;
	END;

  	IF(NOT x_onl_itemtype_itemtypeid_f OR (sImpOrigSysRef IS NULL)) THEN
  	 BEGIN
	  /* The record has Item ID but no Item_type_id */
	  FAILED:=FAILED+1;
	  /* Found ITEM_ID, mark record as Modify and insert the item_id */
	  IF(sImpOrigSysRef IS NULL)THEN
	   sRecStatus:='N9';
	  ELSIF(NOT x_onl_itemtype_itemtypeid_f AND x_usesurr_itemtype=1)THEN
	   sRecStatus:='F28';
	  ELSIF(NOT x_onl_itemtype_itemtypeid_f AND x_usesurr_itemtype=0)THEN
	   sRecStatus:='F27';
	  END IF;
	  sDisposition:='R';
	 END;
			ELSE
				/* ItemTypeID exists, so insert or update */
				BEGIN
					IF(sLastFSK IS NOT NULL AND sLastFSK=sThisFSK) THEN
						/* This is a duplicate record */
						sRecStatus:='DUPL';
						sDisposition:='R';
						nDups:=nDups+1;
					ELSE
						BEGIN
                                          sRecStatus:='PASS';
	      					IF( x_onl_itemmaster_itemid_f)THEN
								/* Update so save also the Product_line_id */
								sDisposition:='M';
								nUpdateCount:=nUpdateCount+1;
							ELSE
								/*Insert */
								sDisposition:='I';
								nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_ITEM_MASTERS_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
							END IF;
						END;
					END IF;
				END;
			END IF;
            UPDATE CZ_IMP_ITEM_MASTER
            SET ITEM_ID=DECODE(sDISPOSITION,'R',ITEM_ID,'I',nNextValue+nAllocateCounter, nOnlItemId),
	    ITEM_TYPE_ID=DECODE(sDISPOSITION,'R',ITEM_TYPE_ID,nOnlItemTypeId),
	    DISPOSITION=sDisposition,
	    REC_STATUS=sRecStatus
            WHERE ROWID = thisRowId;
	    sLastFSK:=sImpOrigSysRef;

            /* Return if MAX_ERR is reached */
	    IF (FAILED >= MAX_ERR) THEN
              x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_KRS.KRS_ITEM_MASTER:MAX',11276,inRun_Id);
              RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
	    END IF;

	    sDisposition:=NULL; sRecStatus:=NULL;
	END LOOP;

	/* No more data in ITEM_MASTER */
	CLOSE c_imp_itemmaster;
	COMMIT;
	INSERTS:=nInsertCount;
	UPDATES:=nUpdateCount;
	DUPS:=nDups;
	EXCEPTION
                WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                 RAISE;
		WHEN OTHERS THEN
		x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_IM_KRS.KRS_ITEM_MASTER',11276,inRun_ID);
	END;
END KRS_ITEM_MASTER;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_ITEM_PROPERTY_VALUE (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE			IN	PLS_INTEGER,
					MAX_ERR			IN 	PLS_INTEGER,
					INSERTS			  OUT NOCOPY PLS_INTEGER,
					UPDATES			  OUT NOCOPY PLS_INTEGER,
					FAILED			IN OUT NOCOPY PLS_INTEGER,
					DUPS				  OUT NOCOPY PLS_INTEGER,
                          inXFR_GROUP       IN    VARCHAR2
					) IS

TYPE tFskItemMaster21 IS TABLE OF cz_imp_item_property_value.fsk_itemmaster_2_1%TYPE INDEX BY BINARY_INTEGER;
TYPE tFskItemMaster2Ext IS TABLE OF cz_imp_item_property_value.fsk_itemmaster_2_EXT%TYPE INDEX BY BINARY_INTEGER;
TYPE tFskProperty11 IS TABLE OF cz_imp_item_property_value.fsk_property_1_1%TYPE INDEX BY BINARY_INTEGER;
TYPE tFskProperty1Ext IS TABLE OF cz_imp_item_property_value.fsk_property_1_EXT%TYPE INDEX BY BINARY_INTEGER;
TYPE tOrigSysRef IS TABLE OF cz_imp_item_property_value.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
TYPE tItemId IS TABLE OF cz_imp_item_property_value.item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tPropertyId IS TABLE OF cz_imp_item_property_value.property_id%TYPE INDEX BY BINARY_INTEGER;

iFskItemMaster21 tFskItemMaster21;
iFskItemMaster2Ext tFskItemMaster2Ext;
iFskProperty11  tFskProperty11;
iFskProperty1Ext tFskProperty1Ext;
iOrigSysRef tOrigSysRef;
iItemId tItemId;
iPropertyId tPropertyId;

x_usesurr_itempropertyvalue  PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_PROPERTY_VALUES',inXFR_GROUP);
x_usesurr_property           PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_PROPERTIES',inXFR_GROUP);
x_usesurr_itemmaster         PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_MASTERS',inXFR_GROUP);

-- passing records
CURSOR C1 (x_usersurr_itemmaster PLS_INTEGER, x_usesurr_property PLS_INTEGER) IS
SELECT a.fsk_itemmaster_2_1,a.fsk_itemmaster_2_ext, a.fsk_property_1_1, a.fsk_property_1_ext,
       b.item_id, c.property_id, a.orig_sys_ref
  FROM cz_imp_item_property_value a, cz_item_masters b, cz_properties c
 WHERE b.orig_sys_ref=DECODE(x_usesurr_itemmaster,1,a.fsk_itemmaster_2_ext,a.fsk_itemmaster_2_1)
   AND c.orig_sys_ref=DECODE(x_usesurr_property,1,a.fsk_property_1_ext,a.fsk_property_1_1)
   AND b.deleted_flag = '0'
   AND c.deleted_flag = '0'
   AND a.rec_status IS NULL
   AND a.run_id=inRUN_ID;

-- invalid fsk_property
CURSOR C2 (x_usersurr_itemmaster PLS_INTEGER, x_usesurr_property PLS_INTEGER) IS
SELECT a.fsk_itemmaster_2_1,a.fsk_itemmaster_2_ext, a.fsk_property_1_1, a.fsk_property_1_ext,
       a.orig_sys_ref, b.item_id
FROM cz_imp_item_property_value a, cz_item_masters b
WHERE b.orig_sys_ref=DECODE(x_usesurr_itemmaster,1,a.fsk_itemmaster_2_ext,a.fsk_itemmaster_2_1)
AND b.deleted_flag = '0'
AND NOT EXISTS (SELECT NULL FROM cz_properties
                WHERE orig_sys_ref = DECODE(x_usesurr_property,1,a.fsk_property_1_ext,a.fsk_property_1_1)
                AND deleted_flag = '0')
AND a.rec_status IS NULL
AND a.run_id=inRUN_ID;

-- invalid fsk_itemmaster
CURSOR C3 (x_usersurr_itemmaster PLS_INTEGER, x_usesurr_property PLS_INTEGER) IS
SELECT a.fsk_itemmaster_2_1,a.fsk_itemmaster_2_ext, a.fsk_property_1_1, a.fsk_property_1_ext,
       a.orig_sys_ref, b.property_id
FROM cz_imp_item_property_value a, cz_properties b
WHERE b.orig_sys_ref=DECODE(x_usesurr_property,1,a.fsk_property_1_ext,a.fsk_property_1_1)
AND b.deleted_flag = '0'
AND NOT EXISTS (SELECT NULL FROM cz_item_masters
                WHERE orig_sys_ref = DECODE(x_usesurr_itemmaster,1,a.fsk_itemmaster_2_ext,a.fsk_itemmaster_2_1)
                AND deleted_flag = '0')
AND a.rec_status IS NULL
AND a.run_id=inRUN_ID;

-- invalid fsk_property and fsk_itemmaster
CURSOR C4 (x_usersurr_itemmaster PLS_INTEGER, x_usesurr_property PLS_INTEGER) IS
SELECT a.fsk_itemmaster_2_1,a.fsk_itemmaster_2_ext, a.fsk_property_1_1, a.fsk_property_1_ext, a.orig_sys_ref
FROM cz_imp_item_property_value a
WHERE NOT EXISTS (SELECT NULL FROM cz_item_masters
                  WHERE orig_sys_ref = DECODE(x_usesurr_itemmaster,1,a.fsk_itemmaster_2_ext,a.fsk_itemmaster_2_1)
                  AND deleted_flag = '0')
AND NOT EXISTS (SELECT NULL FROM cz_properties
                WHERE orig_sys_ref = DECODE(x_usesurr_property,1,a.fsk_property_1_ext,a.fsk_property_1_1)
                AND deleted_flag = '0')
AND a.rec_status IS NULL
AND a.run_id=inRUN_ID;

-- invalid fsk_localizedtext_3_1
CURSOR C5(x_usesurr_itempropertyvalue PLS_INTEGER) IS
SELECT orig_sys_ref FROM cz_imp_item_property_value a
 WHERE run_id=inRUN_ID AND EXISTS(SELECT NULL FROM cz_imp_property
               WHERE run_id=inRUN_ID AND property_id=a.property_id AND
                     data_type=8 AND deleted_flag='0')
       AND NOT EXISTS (SELECT NULL FROM cz_imp_localized_texts
                      WHERE run_id=inRUN_ID AND orig_sys_ref = DECODE(x_usesurr_itempropertyvalue,0,a.FSK_LOCALIZEDTEXT_3_1,a.FSK_LOCALIZEDTEXT_3_EXT)
                            AND deleted_flag='0');

nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
nErrorCount		PLS_INTEGER:=0;			/*Error index */
nInsertCount		PLS_INTEGER:=0;			/*Inserts */
nUpdateCount		PLS_INTEGER:=0;			/*Updates */
nDups			PLS_INTEGER:=0;			/*Duplicate records */

x_error			     BOOLEAN:=FALSE;
l_msg                        VARCHAR2(2000);

BEGIN

     OPEN C1(x_usesurr_itemmaster, x_usesurr_property);
     LOOP
       iFskItemMaster21.delete; iFskItemMaster2Ext.delete; iFskProperty11.delete; iFskProperty1Ext.delete;
       iOrigSysRef.delete; iItemId.delete; iPropertyId.delete;
       FETCH C1 BULK COLLECT INTO iFskItemMaster21,iFskItemMaster2Ext,iFskProperty11,iFskProperty1Ext,
       iItemId, iPropertyId, iOrigSysRef
       LIMIT COMMIT_SIZE;
       EXIT WHEN C1%NOTFOUND AND iOrigSysRef.COUNT = 0;

       IF iOrigSysRef.COUNT > 0 THEN

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value a
              SET item_id=iItemId(i),
                  property_id=iPropertyId(i),
                  disposition='M',
                  rec_status='PASS'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i)
              AND EXISTS (SELECT NULL FROM cz_item_property_values
                          WHERE orig_sys_ref = a.orig_sys_ref);

            UPDATES := UPDATES + SQL%ROWCOUNT;
            COMMIT;

--------------------- New code ------------------------------------

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value a
              SET property_num_value=(SELECT DISTINCT intl_text_id FROM cz_imp_localized_texts
                                       WHERE run_id=inRUN_ID AND orig_sys_ref = a.FSK_LOCALIZEDTEXT_3_1
                                             AND deleted_flag='0'),
                  disposition='M',
                  rec_status='PASS'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i)
              AND EXISTS(SELECT NULL FROM cz_imp_property
                         WHERE run_id=inRUN_ID AND property_id=iPropertyId(i) AND
                               data_type=8 AND deleted_flag='0')
              AND EXISTS (SELECT NULL FROM cz_imp_localized_texts
                          WHERE run_id=inRUN_ID AND orig_sys_ref = a.FSK_LOCALIZEDTEXT_3_1
                          AND deleted_flag='0');

          COMMIT;

--------------------- End of new code ------------------------------

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value a
              SET item_id=iItemId(i),
                  property_id=iPropertyId(i),
                  disposition='I',
                  rec_status='PASS'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i)
              AND NOT EXISTS (SELECT NULL FROM cz_item_property_values
                              WHERE orig_sys_ref = a.orig_sys_ref);

           INSERTS := INSERTS + SQL%ROWCOUNT;
           COMMIT;
       END IF;
     END LOOP;
     CLOSE C1;

     OPEN C2(x_usesurr_itemmaster, x_usesurr_property);
     LOOP
       iFskItemMaster21.delete; iFskItemMaster2Ext.delete; iFskProperty11.delete; iFskProperty1Ext.delete;
       iOrigSysRef.delete; iItemId.delete; iPropertyId.delete;
       FETCH C2 BULK COLLECT INTO iFskItemMaster21,iFskItemMaster2Ext,iFskProperty11,iFskProperty1Ext,iOrigSysRef,iItemId
       LIMIT COMMIT_SIZE;
       EXIT WHEN C2%NOTFOUND AND iOrigSysRef.COUNT = 0;

       IF iOrigSysRef.COUNT > 0 THEN

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value
              SET item_id=iItemId(i),
                  disposition='R',
                  rec_status='I0P1'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i);

           FAILED := FAILED + SQL%ROWCOUNT;
           COMMIT;
       END IF;
     END LOOP;
     CLOSE C2;

     OPEN C3(x_usesurr_itemmaster, x_usesurr_property);
     LOOP
       iFskItemMaster21.delete; iFskItemMaster2Ext.delete; iFskProperty11.delete; iFskProperty1Ext.delete;
       iOrigSysRef.delete; iItemId.delete; iPropertyId.delete;
       FETCH C3 BULK COLLECT INTO iFskItemMaster21,iFskItemMaster2Ext,iFskProperty11,iFskProperty1Ext,iOrigSysRef,iPropertyId
       LIMIT COMMIT_SIZE;
       EXIT WHEN C3%NOTFOUND AND iOrigSysRef.COUNT = 0;
       IF iOrigSysRef.COUNT > 0 THEN

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value
              SET property_id=iPropertyId(i),
                  disposition='R',
                  rec_status='I1P0'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i);

           FAILED := FAILED + SQL%ROWCOUNT;
           COMMIT;
       END IF;
     END LOOP;
     CLOSE C3;

     OPEN C4(x_usesurr_itemmaster, x_usesurr_property);
     LOOP
       iFskItemMaster21.delete; iFskItemMaster2Ext.delete; iFskProperty11.delete; iFskProperty1Ext.delete;
       iOrigSysRef.delete; iItemId.delete; iPropertyId.delete;
       FETCH C4 BULK COLLECT INTO iFskItemMaster21,iFskItemMaster2Ext,iFskProperty11,iFskProperty1Ext,iOrigSysRef
       LIMIT COMMIT_SIZE;
       EXIT WHEN C4%NOTFOUND AND iOrigSysRef.COUNT = 0;
       IF iOrigSysRef.COUNT > 0 THEN

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value
              SET disposition='R',
                  rec_status='I1P1'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i);

           FAILED := FAILED + SQL%ROWCOUNT;
           COMMIT;
       END IF;
     END LOOP;
     CLOSE C4;

     OPEN C5(x_usesurr_itempropertyvalue);
     LOOP
       iOrigSysRef.delete;
       FETCH C5 BULK COLLECT INTO iOrigSysRef
       LIMIT COMMIT_SIZE;
       EXIT WHEN C5%NOTFOUND AND iOrigSysRef.COUNT = 0;
       IF iOrigSysRef.COUNT > 0 THEN

         FORALL i IN iOrigSysRef.FIRST..iOrigSysRef.LAST
           UPDATE cz_imp_item_property_value
              SET disposition='R',
                  rec_status='I1P2'
            WHERE run_id=inRUN_ID
              AND orig_sys_ref=iOrigSysRef(i);

           FAILED := FAILED + SQL%ROWCOUNT;
           COMMIT;
       END IF;
     END LOOP;
     CLOSE C5;


     /* Check if any properties have been deleted in APPS */

     UPDATE cz_item_property_values iv
        SET deleted_flag = '1'
      WHERE deleted_flag = '0'
        AND NOT EXISTS
           (SELECT NULL FROM cz_imp_item_property_value
             WHERE run_id = inRUN_ID AND deleted_flag = '0'
               AND item_id = iv.item_id
               AND property_id = iv.property_id)
        AND EXISTS
           (SELECT NULL FROM cz_imp_item_master
             WHERE item_id = iv.item_id
               AND run_id = inRUN_ID)
        AND EXISTS
           (SELECT NULL FROM cz_properties
             WHERE orig_sys_ref IS NOT NULL
               AND deleted_flag = '0'
               AND property_id = iv.property_id);
    COMMIT;
EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN OTHERS THEN
    l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_IM_KRS.KRS_ITEM_PROPERTY_VALUE',11276,inRun_ID);
    RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END KRS_ITEM_PROPERTY_VALUE ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_ITEM_TYPE (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		   OUT NOCOPY PLS_INTEGER,
					UPDATES		   OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
					DUPS		   OUT NOCOPY PLS_INTEGER,
                          inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_itemtype IS
               SELECT ORIG_SYS_REF, ROWID FROM CZ_IMP_ITEM_TYPE
               WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
               ORDER BY 1,ROWID;
 		/* cursor's data found indicators */
                sImpName                        CZ_IMP_ITEM_TYPE.NAME%TYPE;
                nItemTypeId                     CZ_IMP_ITEM_TYPE.ITEM_TYPE_ID%TYPE;
                sLastFSK                        CZ_IMP_ITEM_TYPE.NAME%TYPE;
                sThisFSK                        CZ_IMP_ITEM_TYPE.NAME%TYPE;
                sRecStatus                      CZ_IMP_ITEM_TYPE.REC_STATUS%TYPE;
                sDisposition                    CZ_IMP_ITEM_TYPE.DISPOSITION%TYPE;
		/* Column Vars */
		x_imp_itemtype_f						BOOLEAN:=FALSE;
		x_onl_itemtype_itemtypeid_f				BOOLEAN:=FALSE;
		x_error							BOOLEAN:=FALSE;
		/* Internal vars */
		nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount			PLS_INTEGER:=0;			/*Error index */
		nInsertCount		PLS_INTEGER:=0;			/*Inserts */
		nUpdateCount		PLS_INTEGER:=0;			/*Updates */
		nDups				PLS_INTEGER:=0;			/*Duplicate records */

     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;

     thisRowId                         ROWID;

     v_settings_id      VARCHAR2(40);
     v_section_name     VARCHAR2(30);

   BEGIN

    v_settings_id := 'OracleSequenceIncr';
    v_section_name := 'SCHEMA';

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

		/* This type casting is necessary to use decode stmt */
		OPEN c_imp_itemtype;
		LOOP
			/* COMMIT if the buffer size is reached */
			IF (nCommitCount>= COMMIT_SIZE) THEN
				BEGIN
					COMMIT;
					nCommitCount:=0;
				END;
			ELSE
				nCOmmitCount:=nCommitCount+1;
			END IF;

			sImpName:=NULL;
			FETCH c_imp_itemtype INTO sImpName, thisRowId;
			sThisFSK:=sImpName;
			x_imp_itemtype_f:=c_imp_itemtype%FOUND;
			EXIT WHEN NOT x_imp_itemtype_f;

			/* Check if this is an insert or update */
			DECLARE
				CURSOR c_onl_itemtype_itemtypeid  IS
					SELECT ITEM_TYPE_ID FROM CZ_ITEM_TYPES WHERE ORIG_SYS_REF=sImpName;
			BEGIN
				OPEN c_onl_itemtype_itemtypeid ;
				nItemTypeId:=NULL;
				FETCH c_onl_itemtype_itemtypeid INTO nItemTypeId;
				x_onl_itemtype_itemtypeid_f:=c_onl_itemtype_itemtypeid%FOUND;
				CLOSE c_onl_itemtype_itemtypeid;
			END;
			/* All foreign keys are resolved */
			IF(sImpName IS NULL ) THEN
				BEGIN
					/* The record has Item ID but no Item_type_id */
					FAILED:=FAILED+1;
				 	/* Found ITEM_ID, mark record as Modify and insert the item_id */
					sRecStatus:='N14';
					sDisposition:='R';
				END;
			ELSIF(sLastFSK IS NOT NULL AND sLastFSK=sThisFSK) THEN
				/* This is a duplicate record */
				sRecStatus:='DUPL';
				sDisposition:='R';
				nDups:=nDups+1;
			ELSE
				BEGIN
                                        sRecStatus:='PASS';
					IF( x_onl_itemtype_itemtypeid_f)THEN
						/* Update so save also the Product_line_id */
						sDisposition:='M';
						nUpdateCount:=nUpdateCount+1;
					ELSE
						/*Insert */
						sDisposition:='I';
						nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_ITEM_TYPES_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
	   END IF;
	  END;
         END IF;

            UPDATE CZ_IMP_ITEM_TYPE SET
            ITEM_TYPE_ID=DECODE(sDISPOSITION,'R',ITEM_TYPE_ID,'I',nNextValue+nAllocateCounter, nItemTypeId ),
            DISPOSITION=sDisposition, REC_STATUS=sRecStatus
            WHERE ROWID = thisRowId;
 	    sLastFSK:=sImpName;

            IF (FAILED >= MAX_ERR) THEN
              x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_KRS.KRS_ITEM_TYPE:MAX',11276,inRun_Id);
              RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
            END IF;
			sDisposition:=NULL; sRecStatus:=NULL;
		END LOOP;
		CLOSE c_imp_itemtype;
		COMMIT;
		INSERTS:=nInsertCount;
		UPDATES:=nUpdateCount;
		DUPS:=nDups;
	EXCEPTION
                WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                 RAISE;
		WHEN OTHERS THEN
			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_IM_KRS.KRS_ITEM_TYPE',11276,inRun_ID);
	END;
END KRS_ITEM_TYPE;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_ITEM_TYPE_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		   OUT NOCOPY PLS_INTEGER,
					UPDATES		   OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
					DUPS		   OUT NOCOPY PLS_INTEGER,
                          inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_itemtypeprop(x_usesurr_itemtype	PLS_INTEGER,
                                      x_usesurr_property    PLS_INTEGER) IS
SELECT DECODE(x_usesurr_itemtype,0,FSK_ITEMTYPE_1_1,1,FSK_ITEMTYPE_1_EXT),
DECODE(x_usesurr_property,0,FSK_PROPERTY_2_1,1,FSK_PROPERTY_2_EXT), ROWID
FROM CZ_IMP_ITEM_TYPE_PROPERTY  WHERE REC_STATUS IS NULL  AND RUN_ID = inRUN_ID  ORDER BY 1, 2,ROWID;
 		/* cursor's data found indicators */
                nOnlItemTypeId                  CZ_IMP_ITEM_TYPE_PROPERTY.ITEM_TYPE_ID%TYPE;
                nOnlPropertyId                  CZ_IMP_ITEM_TYPE_PROPERTY.PROPERTY_ID%TYPE;
                sFSKITEMTYPE                    CZ_IMP_ITEM_TYPE_PROPERTY.FSK_ITEMTYPE_1_1%TYPE;
                sFSKPROPERTY                    CZ_IMP_ITEM_TYPE_PROPERTY.FSK_PROPERTY_2_1%TYPE;
                sLastFSK1                       CZ_IMP_ITEM_TYPE_PROPERTY.FSK_ITEMTYPE_1_1%TYPE;
                sThisFSK1                       CZ_IMP_ITEM_TYPE_PROPERTY.FSK_ITEMTYPE_1_1%TYPE;
                sLastFSK2                       CZ_IMP_ITEM_TYPE_PROPERTY.FSK_PROPERTY_2_1%TYPE;
                sThisFSK2                       CZ_IMP_ITEM_TYPE_PROPERTY.FSK_PROPERTY_2_1%TYPE;
                sRecStatus                      CZ_IMP_ITEM_TYPE_PROPERTY.REC_STATUS%TYPE;
                sDisposition                    CZ_IMP_ITEM_TYPE_PROPERTY.DISPOSITION%TYPE;
		/* Column Vars */
		x_imp_itemtypeprop_f					BOOLEAN:=FALSE;
		x_onl_itemtypeprop_f					BOOLEAN:=FALSE;
		x_onl_itemtype_itemtypeid_f				BOOLEAN:=FALSE;
		x_onl_property_propertyid_f				BOOLEAN:=FALSE;
		x_error							BOOLEAN:=FALSE;
		p_onl_itemtype_itemtypeid					CHAR(1):='';
		p_onl_property_propertyid					CHAR(1):='';
		p_onl_itemtypeprop						CHAR(1):='';
		/* Internal vars */
		nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount			PLS_INTEGER:=0;			/*Error index */
		nInsertCount		PLS_INTEGER:=0;			/*Inserts */
		nUpdateCount		PLS_INTEGER:=0;			/*Updates */
		nDups				PLS_INTEGER:=0;			/*Duplicate records */
		x_usesurr_itemtypeprop			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_TYPE_PROPERTIES',inXFR_GROUP);
												    			/*Use surrogates */
		x_usesurr_itemtype			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_TYPES',inXFR_GROUP);
												    			/*Use surrogates */
		x_usesurr_property			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_PROPERTIES',inXFR_GROUP);
												    			/*Use surrogates */
   thisRowId    ROWID;
   BEGIN

		OPEN c_imp_itemtypeprop(x_usesurr_itemtypeprop,x_usesurr_property) ;

		LOOP
			/* COMMIT if the buffer size is reached */
			IF (nCommitCount>= COMMIT_SIZE) THEN
				BEGIN
					COMMIT;
					nCommitCount:=0;
				END;
			ELSE
				nCOmmitCount:=nCommitCount+1;
			END IF;
			sFSKITEMTYPE:=NULL; sFSKITEMTYPE:=NULL ;
			FETCH c_imp_itemtypeprop INTO sFSKITEMTYPE,sFSKPROPERTY,thisRowId ;
			sThisFSK1:=sFSKITEMTYPE;
			sThisFSK2:=sFSKPROPERTY;

			x_imp_itemtypeprop_f:=c_imp_itemtypeprop%FOUND;
			EXIT WHEN NOT x_imp_itemtypeprop_f;
			DECLARE
				CURSOR c_onl_itemtype_itemtypeid IS
					SELECT ITEM_TYPE_ID FROM CZ_ITEM_TYPES WHERE ORIG_SYS_REF=sFSKITEMTYPE;
			BEGIN
				OPEN  c_onl_itemtype_itemtypeid;
				nOnlItemTypeId:=NULL;
				FETCH	c_onl_itemtype_itemtypeid INTO nOnlItemTypeId;
				x_onl_itemtype_itemtypeid_f:=c_onl_itemtype_itemtypeid%FOUND;
				CLOSE c_onl_itemtype_itemtypeid;
			END;
			DECLARE
				CURSOR c_onl_property_propertyid IS
					SELECT PROPERTY_ID FROM CZ_PROPERTIES WHERE ORIG_SYS_REF=sFSKPROPERTY;
			BEGIN
				OPEN c_onl_property_propertyid;
				nOnlPropertyId:=NULL;
				FETCH	c_onl_property_propertyid INTO nOnlPropertyId;
				x_onl_property_propertyid_f:=c_onl_property_propertyid%FOUND;
				CLOSE c_onl_property_propertyid;
			END;
			/* Check if this is an insert or update */
			DECLARE
				CURSOR c_onl_itemtypeprop  IS
					SELECT 'X' FROM CZ_ITEM_TYPE_PROPERTIES
					WHERE ITEM_TYPE_ID=nOnlItemTypeId AND PROPERTY_ID=nOnlPropertyId;
			BEGIN
				OPEN c_onl_itemtypeprop ;
				FETCH c_onl_itemtypeprop INTO p_onl_itemtypeprop;
				x_onl_itemtypeprop_f:=c_onl_itemtypeprop%FOUND;
				CLOSE c_onl_itemtypeprop;
			END;
			IF(NOT x_onl_itemtype_itemtypeid_f OR NOT x_onl_property_propertyid_f) THEN
				BEGIN
					/* The record has Item ID but no Item_type_id */
					FAILED:=FAILED+1;
					IF(NOT x_onl_itemtype_itemtypeid_f AND x_usesurr_itemtype=1 AND sFSKITEMTYPE IS NULL) THEN
							sRecStatus:='N23';
					ELSIF(NOT x_onl_itemtype_itemtypeid_f AND x_usesurr_itemtype=1) THEN
							sRecStatus:='F23';
				      ELSIF(NOT x_onl_itemtype_itemtypeid_f  AND x_usesurr_itemtype=0 AND sFSKITEMTYPE IS NULL) THEN
							sRecStatus:='N22';
				      ELSIF(NOT x_onl_itemtype_itemtypeid_f  AND x_usesurr_itemtype=0) THEN
							sRecStatus:='F22';
					ELSIF(NOT x_onl_property_propertyid_f AND x_usesurr_property=1 AND sFSKPROPERTY IS NULL) THEN
							sRecStatus:='N25';
					ELSIF(NOT x_onl_property_propertyid_f AND x_usesurr_property=1) THEN
							sRecStatus:='F25';
					ELSIF(NOT x_onl_property_propertyid_f AND x_usesurr_property=0
                              AND sFSKPROPERTY IS NULL) THEN
							sRecStatus:='N24';
					ELSIF(NOT x_onl_property_propertyid_f AND x_usesurr_property=0) THEN
							sRecStatus:='F24';
					END IF;
					sDisposition:='R';
				END;
			ELSE
				/* ItemTypeID exists, so insert or update */
				BEGIN
					IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1 AND
					   sLastFSK2 IS NOT NULL AND sLastFSK2=sThisFSK2) THEN
						/* This is a duplicate record */
						sRecStatus:='DUPL';
						sDisposition:='R';
						nDups:=nDups+1;
					ELSE
						BEGIN
                                                        sRecStatus:='PASS';
							IF( x_onl_itemtypeprop_f)THEN
								/* Update so save also the Product_line_id */
								sDisposition:='M';
								nUpdateCount:=nUpdateCount+1;
							ELSE
								/*Insert */
								sDisposition:='I';
								nInsertCount:=nInsertCount+1;
							END IF;
						END;
					END IF;
				END;
			END IF;
                  UPDATE CZ_IMP_ITEM_TYPE_PROPERTY SET
                    ITEM_TYPE_ID=DECODE(sDISPOSITION,'R',ITEM_TYPE_ID,nOnlItemTypeId),
                    PROPERTY_ID=DECODE(sDISPOSITION,'R',PROPERTY_ID,nOnlPropertyId ),
                    DISPOSITION=sDisposition, REC_STATUS=sRecStatus
                  WHERE ROWID = thisRowId;
			sLastFSK1:=sFSKITEMTYPE;
			sLastFSK2:=sFSKPROPERTY;

			/* Return if MAX_ERR is reached */
     IF (FAILED >= MAX_ERR) THEN
       x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_KRS.KRS_ITEM_TYPE_PROPERTY:MAX',11276,inRun_Id);
       RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
     END IF;
         sDisposition:=NULL; sRecStatus:=NULL;
	END LOOP;
	CLOSE c_imp_itemtypeprop;
	/* Check if item type's property that's already been imported to CZ
	   has been deleted in APPS */
		BEGIN
			UPDATE CZ_ITEM_TYPE_PROPERTIES
			SET DELETED_FLAG = '1'
			WHERE ITEM_TYPE_ID IN (SELECT ITEM_TYPE_ID FROM CZ_IMP_ITEM_TYPE
						     	WHERE RUN_ID = inRUN_ID
							AND DELETED_FLAG = '0')
			AND PROPERTY_ID NOT IN (SELECT PROPERTY_ID FROM CZ_IMP_ITEM_TYPE_PROPERTY
						     	WHERE RUN_ID = inRUN_ID
							AND ITEM_TYPE_ID = CZ_ITEM_TYPE_PROPERTIES.ITEM_TYPE_ID
							AND DELETED_FLAG = '0')
			AND PROPERTY_ID IN (SELECT PROPERTY_ID FROM CZ_PROPERTIES
							WHERE ORIG_SYS_REF IS NOT NULL
							AND DELETED_FLAG = '0')
                        AND ORIG_SYS_REF IS NOT NULL
			AND DELETED_FLAG = '0';

                        UPDATE CZ_ITEM_PROPERTY_VALUES
                        SET DELETED_FLAG = '1'
                        WHERE ITEM_ID IN (SELECT IM.ITEM_ID
                                          FROM CZ_ITEM_MASTERS IM, CZ_ITEM_TYPES IT,CZ_ITEM_TYPE_PROPERTIES ITP
                                          WHERE IM.ITEM_TYPE_ID = IT.ITEM_TYPE_ID
                                          AND IT.ITEM_TYPE_ID = ITP.ITEM_TYPE_ID
                                          AND ITP.DELETED_FLAG = '1'
                                          AND CZ_ITEM_PROPERTY_VALUES.PROPERTY_ID = ITP.PROPERTY_ID);

		END;
		COMMIT;
		INSERTS:=nInsertCount;
		UPDATES:=nUpdateCount;
		DUPS:=nDups;
	EXCEPTION
                WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                 RAISE;
		WHEN OTHERS THEN
		x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_IM_KRS.KRS_ITEM_TYPE_PROPERTY',11276,inRun_ID);
	END;
END KRS_ITEM_TYPE_PROPERTY ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE	IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		   OUT NOCOPY PLS_INTEGER,
					UPDATES		   OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
					DUPS		   OUT NOCOPY PLS_INTEGER,
                          inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_property IS
              SELECT ORIG_SYS_REF, ROWID FROM CZ_IMP_PROPERTY
              WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
              ORDER BY 1,ROWID;
 		/* cursor's data found indicator*/
                sImpName                                CZ_IMP_PROPERTY.NAME%TYPE;
                nPropertyId                             CZ_IMP_PROPERTY.PROPERTY_ID%TYPE;
		nPropertyName                             CZ_IMP_PROPERTY.NAME%TYPE;
                sLastFSK                                CZ_IMP_PROPERTY.NAME%TYPE;
                sThisFSK                                CZ_IMP_PROPERTY.NAME%TYPE;
                sRecStatus                              CZ_IMP_PROPERTY.REC_STATUS%TYPE;
                sDisposition                    CZ_IMP_PROPERTY.DISPOSITION%TYPE;
		/* Column Vars */
		x_imp_property_f					BOOLEAN:=FALSE;
		x_onl_property_propertyid_f			BOOLEAN:=FALSE;
		x_onl_property_propertyname_f			BOOLEAN:=FALSE;
		x_error						BOOLEAN:=FALSE;
		/* Internal vars */
		nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount			PLS_INTEGER:=0;			/*Error index */
		nInsertCount		PLS_INTEGER:=0;			/*Inserts */
		nUpdateCount		PLS_INTEGER:=0;			/*Updates */
		nDups				PLS_INTEGER:=0;			/*Duplicate records */

     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;

     thisRowId                   ROWID;

     v_settings_id      VARCHAR2(40);
     v_section_name     VARCHAR2(30);

     l_data_type        CZ_PROPERTIES.DATA_TYPE%TYPE;

   BEGIN

    v_settings_id := 'OracleSequenceIncr';
    v_section_name := 'SCHEMA';

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

		/* This type casting is necessary to use decode stmt */
		OPEN c_imp_property;
		LOOP
			/* COMMIT if the buffer size is reached */
			IF (nCommitCount>= COMMIT_SIZE) THEN
				BEGIN
					COMMIT;
					nCommitCount:=0;
				END;
			ELSE
				nCOmmitCount:=nCommitCount+1;
			END IF;
			sImpName:=NULL;
			FETCH c_imp_property INTO sImpName, thisRowId;
			sThisFSK:=sImpName;
			x_imp_property_f:=c_imp_property%FOUND;
			EXIT WHEN NOT x_imp_property_f;
			/* Check if this is an insert or update */
			DECLARE
				CURSOR c_onl_property_propertyid IS
					SELECT PROPERTY_ID, data_type FROM CZ_PROPERTIES WHERE ORIG_SYS_REF=sImpName;
			BEGIN
				OPEN c_onl_property_propertyid ;
				nPropertyId:=NULL;
                                l_data_type := NULL;
				FETCH c_onl_property_propertyid INTO nPropertyId, l_data_type;
				x_onl_property_propertyid_f:=c_onl_property_propertyid%FOUND;
				CLOSE c_onl_property_propertyid;
			END;
			/* All foreign keys are resolved */
			IF(sImpName IS NULL ) THEN
				BEGIN
					/* The record has Item ID but no Item_type_id */
					FAILED:=FAILED+1;
				 	/* Found ITEM_ID, mark record as Modify and insert the item_id */
					sRecStatus:='N17';
					sDisposition:='R';
				END;
			ELSIF(sLastFSK IS NOT NULL AND sLastFSK=sThisFSK) THEN
				/* This is a duplicate record */
				sRecStatus:='DUPL';
				sDisposition:='R';
				nDups:=nDups+1;
			ELSE
				BEGIN
                                        sRecStatus:='PASS';
					IF( x_onl_property_propertyid_f)THEN
						/* Update so save also the Product_line_id */
						sDisposition:='M';
						nUpdateCount:=nUpdateCount+1;
					ELSE
						BEGIN
						DECLARE
							CURSOR c_onl_property_propertyname IS
								SELECT NAME FROM CZ_PROPERTIES WHERE NAME=sImpName AND ORIG_SYS_REF IS NULL AND DELETED_FLAG=0;
								BEGIN
								OPEN c_onl_property_propertyname;
								FETCH c_onl_property_propertyname INTO nPropertyName;
								x_onl_property_propertyname_f:=c_onl_property_propertyname%FOUND;
								CLOSE c_onl_property_propertyname;
								END;
								IF( x_onl_property_propertyname_f)THEN
									sRecStatus:='DUPL';
									sDisposition:='R';
									nDups:=nDups+1;
									x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_PROPERTY_EXISTS','NAME',nPropertyName),1,'CZ_IMP_IM_KRS.KRS_PROPERTY',11276,inRun_Id);
									CZ_IMP_ALL.setReturnCode(cz_imp_all.CONCURRENT_WARNING,CZ_UTILS.GET_TEXT('CZ_IMP_PROPERTY_EXISTS','NAME',nPropertyName));
								ELSE
						/*Insert */
						sDisposition:='I';
						nInsertCount:=nInsertCount+1;
                                                nAllocateCounter:=nAllocateCounter+1;
                                                IF(nAllocateCounter=nAllocateBlock)THEN
                                                  nAllocateCounter:=0;
                                                  SELECT CZ_PROPERTIES_S.NEXTVAL INTO nNextValue FROM DUAL;
                                                END IF;
								END IF;
						END;
                                        END IF;
                               END;
                        END IF;
         UPDATE CZ_IMP_PROPERTY SET
         PROPERTY_ID=DECODE(sDISPOSITION,'R',PROPERTY_ID,'I',nNextValue+nAllocateCounter,nPropertyId),
         --
         --Bug #5162016 - use an existing but never before used field to store the on-line property data type.
         --For new properties this field will stay null.
         --
         REC_NBR = l_data_type,
         DISPOSITION=sDisposition, REC_STATUS=sRecStatus
         WHERE ROWID = thisRowId;
         sLastFSK:=sImpName;
         sDisposition:=NULL; sRecStatus:=NULL;
	 IF (FAILED >= MAX_ERR) THEN
           x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_KRS.KRS_PROPERTY:MAX',11276,inRun_Id);
           RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
           COMMIT;
         END IF;
	END LOOP;
	CLOSE c_imp_property;
	COMMIT;
	INSERTS:=nInsertCount;
	UPDATES:=nUpdateCount;
	DUPS:=nDups;
	EXCEPTION
                WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
x_error:=CZ_UTILS.LOG_REPORT('raised max_err',1,'CZ_IMP_IM_KRS.KRS_PROPERTY:MAX',11276,inRun_Id);
                 RAISE;
		WHEN OTHERS THEN
 		 x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_IM_KRS.KRS_PROPERTY',11276,inRun_ID);
	END;
END KRS_PROPERTY ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
END CZ_IMP_IM_KRS;

/
