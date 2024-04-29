--------------------------------------------------------
--  DDL for Package Body CZ_IMP_PR_KRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_PR_KRS" AS
/*	$Header: cziprkrb.pls 115.12 2002/12/03 14:47:31 askhacha ship $		*/

PROCEDURE KRS_PRICE  (		inRUN_ID	 	IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
                                        FAILED          OUT NOCOPY     PLS_INTEGER,
                                        DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
 		/* cursor's data found indicators */
                nOnlFSKItemId           CZ_IMP_PRICE.ITEM_ID%TYPE;
                nOnlFSKPriceGroupId     CZ_IMP_PRICE.PRICE_GROUP_ID%TYPE;
                sFSKITEMMASTER          CZ_IMP_PRICE.FSK_ITEMMASTER_1_1%TYPE;
                sFSKPRICEGROUP          CZ_IMP_PRICE.FSK_PRICEGROUP_2_1%TYPE;
                sLastFSK1                       CZ_IMP_PRICE.FSK_ITEMMASTER_1_1%TYPE;
                sThisFSK1                       CZ_IMP_PRICE.FSK_ITEMMASTER_1_1%TYPE;
                sLastFSK2                       CZ_IMP_PRICE.FSK_PRICEGROUP_2_1%TYPE;
                sThisFSK2                       CZ_IMP_PRICE.FSK_PRICEGROUP_2_1%TYPE;
                sRecStatus                      CZ_IMP_PRICE.REC_STATUS%TYPE;
                sDisposition            CZ_IMP_PRICE.DISPOSITION%TYPE;
		/* Column Vars */
		x_imp_price_f						BOOLEAN:=FALSE;
		x_onl_price_f						BOOLEAN:=FALSE;
		x_onl_itemmaster_itemid_f				BOOLEAN:=FALSE;
		x_onl_pricegroup_prigrid_f				BOOLEAN:=FALSE;
		x_error						BOOLEAN:=FALSE;
		p_onl_price						CHAR(1):='';
		/* Internal vars */
		nCommitCount			PLS_INTEGER:=0;					/*COMMIT buffer index */
		nErrorCount			PLS_INTEGER:=0;					/*Error index */
		nInsertCount			PLS_INTEGER:=0;					/*Inserts */
		nUpdateCount			PLS_INTEGER:=0;					/*Updates */
		nFailed			PLS_INTEGER:=0;					/*Failed records */
		nDups				PLS_INTEGER:=0;					/*Duplicate records */
		x_usesurr_itemmaster			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_MASTERS',inXFR_GROUP);
		x_usesurr_pricegroup			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_PRICE_GROUPS',inXFR_GROUP);

            thisRowId               ROWID;

	BEGIN
		DECLARE
		CURSOR C_IMP_PRICE(x_usesurr_itemmaster PLS_INTEGER,
                               x_usesurr_pricegroup PLS_INTEGER)  IS
			SELECT DECODE(x_usesurr_itemmaster,0,FSK_ITEMMASTER_1_1,1,FSK_ITEMMASTER_1_EXT),
				 DECODE(x_usesurr_pricegroup,0,FSK_PRICEGROUP_2_1,1,FSK_PRICEGROUP_2_EXT), ROWID
                                FROM CZ_IMP_PRICE
                                WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
				ORDER BY 1,2,ROWID;
	BEGIN
	OPEN C_IMP_PRICE(x_usesurr_itemmaster,x_usesurr_pricegroup);

		LOOP
			/* COMMIT if the buffer size is reached */
			IF (nCommitCount>= COMMIT_SIZE) THEN
				BEGIN
					COMMIT;
					nCommitCount:=0;
				END;
			ELSE
				nCommitCount:=nCommitCount+1;
			END IF;

			sFSKITEMMASTER:=NULL; sFSKPRICEGROUP:=NULL;
			FETCH c_imp_price INTO sFSKITEMMASTER, sFSKPRICEGROUP, thisRowId;
			sThisFSK1:=sFSKITEMMASTER;
 			sThisFSK2:=sFSKPRICEGROUP;
			x_imp_price_f:=c_imp_price%FOUND;
			EXIT WHEN NOT x_imp_price_f;

			DECLARE
				CURSOR c_onl_itemmaster_itemid IS
					SELECT ITEM_ID
					FROM CZ_ITEM_MASTERS
					WHERE ORIG_SYS_REF=sFSKITEMMASTER;
			BEGIN
				OPEN  c_onl_itemmaster_itemid;
				nOnlFSKItemId:=NULL;
				FETCH	c_onl_itemmaster_itemid INTO nOnlFSKItemId;
				x_onl_itemmaster_itemid_f:=c_onl_itemmaster_itemid%FOUND;
				CLOSE c_onl_itemmaster_itemid;
			END;
			DECLARE
				CURSOR c_onl_pricegroup_prigrid IS
					SELECT PRICE_GROUP_ID
					FROM  CZ_PRICE_GROUPS
					WHERE ORIG_SYS_REF=sFSKPRICEGROUP;
			BEGIN
				OPEN c_onl_pricegroup_prigrid ;
				nOnlFSKPriceGroupId:=NULL;
				FETCH	c_onl_pricegroup_prigrid  INTO nOnlFSKPriceGroupId;
				x_onl_pricegroup_prigrid_f:=c_onl_pricegroup_prigrid%FOUND;
				CLOSE c_onl_pricegroup_prigrid ;
			END;
			/* Check if this is an insert or update */
			DECLARE
				CURSOR c_onl_price  IS
					SELECT 'X' FROM CZ_PRICES
					WHERE ITEM_ID=nOnlFSKItemId
					AND PRICE_GROUP_ID=nOnlFSKPriceGroupId;
			BEGIN
				OPEN c_onl_price ;
				FETCH c_onl_price INTO p_onl_price;
				x_onl_price_f:=c_onl_price%FOUND;
				CLOSE c_onl_price;
			END;
			IF( NOT x_onl_itemmaster_itemid_f OR NOT x_onl_pricegroup_prigrid_f) THEN
				BEGIN
					/* The record has missing FSKs */
					nFailed:=nFailed+1;
				 	/* Mark record as Modify and insert the item_id */
					IF (NOT x_onl_itemmaster_itemid_f AND x_usesurr_itemmaster=1 AND sFSKITEMMASTER IS NULL) THEN
						sRecStatus:='N29';
					ELSIF (NOT x_onl_itemmaster_itemid_f AND x_usesurr_itemmaster=1) THEN
						sRecStatus:='F29';
					ELSIF (NOT x_onl_itemmaster_itemid_f AND x_usesurr_itemmaster=0 AND sFSKITEMMASTER IS NULL) THEN
						sRecStatus:='N28';
					ELSIF (NOT x_onl_itemmaster_itemid_f AND x_usesurr_itemmaster=0) THEN
						sRecStatus:='F28';
					ELSIF (NOT x_onl_pricegroup_prigrid_f AND x_usesurr_pricegroup=1 AND sFSKPRICEGROUP IS NULL) THEN
						sRecStatus:='N31';
					ELSIF (NOT x_onl_pricegroup_prigrid_f AND x_usesurr_pricegroup=1) THEN
						sRecStatus:='F31';
					ELSIF(NOT x_onl_pricegroup_prigrid_f AND x_usesurr_pricegroup=0 AND sFSKPRICEGROUP IS NULL) THEN
						sRecStatus:='N30';
					ELSIF(NOT x_onl_pricegroup_prigrid_f AND x_usesurr_pricegroup=0) THEN
						sRecStatus:='F30';
					END IF;
					sDisposition:='R';
				END;
			ELSE
				/* Insert or update */
				BEGIN
					IF(
					   sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1 AND
					   sLastFSK2 IS NOT NULL AND sLastFSK2=sThisFSK2) THEN
						/* This is a duplicate record */
						sRecStatus:='DUPL';
						sDisposition:='R';
						nDups:=nDups+1;
						nFailed:=nFailed+1;
					ELSE
						BEGIN
                                                        sRecStatus:='PASS';
							IF( x_onl_price_f)THEN
								/* Update */
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

                                UPDATE CZ_IMP_PRICE
				set ITEM_ID=DECODE(sDISPOSITION,'R',ITEM_ID,nOnlFSKItemId),
				PRICE_GROUP_ID=DECODE(sDISPOSITION,'R',PRICE_GROUP_ID,nOnlFSKPriceGroupId),
				DISPOSITION=sDisposition, REC_STATUS=sRecStatus
				WHERE ROWID = thisRowId;
				sLastFSK1:=sFSKITEMMASTER;
				sLastFSK2:=sFSKPRICEGROUP;

			/* Return if MAX_ERR is reached */
			IF (nFailed >= MAX_ERR) THEN
				EXIT;
			END IF;
			sDisposition:=NULL; sRecStatus:=NULL;
		END LOOP;
		CLOSE c_imp_price;
            COMMIT;

		INSERTS:=nInsertCount;
		UPDATES:=nUpdateCount;
		FAILED:=nFailed;
		DUPS:=nDups;
	EXCEPTION
		WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_KRS.KRS_PRICE',11276);
	END;
	END;
END KRS_PRICE;
--------------------------------------------------------------------------------------------------------
PROCEDURE KRS_PRICE_GROUP (             inRUN_ID        IN      PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
                                        FAILED          OUT NOCOPY     PLS_INTEGER,
                                        DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
 		/* cursor's data found indicators */
                sOrigSysRef             CZ_IMP_PRICE_GROUP.NAME%TYPE;
                nPriceGroupId           CZ_IMP_PRICE_GROUP.PRICE_GROUP_ID%TYPE;
                sLastFSK                CZ_IMP_PRICE_GROUP.NAME%TYPE;
                sThisFSK                CZ_IMP_PRICE_GROUP.NAME%TYPE;
                sRecStatus              CZ_IMP_PRICE_GROUP.REC_STATUS%TYPE;
                sDisposition    CZ_IMP_PRICE_GROUP.DISPOSITION%TYPE;
		/* Column Vars */
		x_imp_pricegroup_f				BOOLEAN:=FALSE;
		x_onl_pricegroup_prcgrpid_f			BOOLEAN:=FALSE;
		x_error					BOOLEAN:=FALSE;
		/* Internal vars */
		nCommitCount		PLS_INTEGER:=0;						/*COMMIT buffer index */
		nErrorCount		PLS_INTEGER:=0;						/*Error index */
		nInsertCount		PLS_INTEGER:=0;						/*Inserts */
		nUpdateCount		PLS_INTEGER:=0;						/*Updates */
                nFailed                 PLS_INTEGER:=0;                                         /*Failed records */
		nDups			PLS_INTEGER:=0;						/*Duplicate records */
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;
     thisRowId                   ROWID;

	BEGIN
		DECLARE CURSOR C_IMP_PRICEGROUP IS
                        SELECT ORIG_SYS_REF, ROWID FROM CZ_IMP_PRICE_GROUP
			WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
			ORDER BY 1,ROWID;
	BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

			OPEN c_imp_pricegroup;
		LOOP
			/* COMMIT if the buffer size is reached */
			IF (nCommitCount>= COMMIT_SIZE) THEN
				BEGIN
					COMMIT;
					nCommitCount:=0;
				END;
			ELSE
				nCommitCount:=nCommitCount+1;
			END IF;

			sOrigSysRef:=NULL;
			FETCH c_imp_pricegroup INTO sOrigSysRef, thisRowId;
  			sThisFSK:=sOrigSysRef;
			x_imp_pricegroup_f:=c_imp_pricegroup%FOUND;
			EXIT WHEN NOT x_imp_pricegroup_f;

			/* Check if this is an insert or update */
			DECLARE
				CURSOR c_onl_pricegroup_prcgrpid  IS
					SELECT PRICE_GROUP_ID FROM CZ_PRICE_GROUPS
					WHERE ORIG_SYS_REF=sOrigSysRef;
			BEGIN
				OPEN c_onl_pricegroup_prcgrpid ;
				nPriceGroupId:=NULL;
				FETCH c_onl_pricegroup_prcgrpid INTO nPriceGroupId;
				x_onl_pricegroup_prcgrpid_f:=c_onl_pricegroup_prcgrpid%FOUND;
				CLOSE c_onl_pricegroup_prcgrpid;
			END;

			/* All foreign keys are resolved */
			IF(sOrigSysRef IS NULL) THEN
				BEGIN
					/* Error */
					nFailed:=nFailed+1;
                                        sRecStatus:='N5';
					sDisposition:='R';
				END;
			ELSIF(sLastFSK IS NOT NULL AND sLastFSK=sThisFSK) THEN
				/* This is a duplicate record */
				sRecStatus:='DUPL';
				sDisposition:='R';
				nDups:=nDups+1;
				nFailed:=nFailed+1;
			ELSE
				BEGIN
                                        sRecStatus:='PASS';
					IF( x_onl_pricegroup_prcgrpid_f)THEN
						/* Update so save the record */
						sDisposition:='M';
						nUpdateCount:=nUpdateCount+1;
					ELSE
					/*Insert */
						sDisposition:='I';
						nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_PRICE_GROUPS_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
					END IF;
				END;
			END IF;

                                UPDATE CZ_IMP_PRICE_GROUP
				SET price_group_id = DECODE(sDISPOSITION,'R',PRICE_GROUP_ID,'I',nNextValue+nAllocateCounter, nPriceGroupId),
				DISPOSITION=sDisposition, REC_STATUS=sRecStatus
				WHERE ROWID = thisRowId;
				sLastFSK:=sThisFSK;

			IF (nFailed >= MAX_ERR) THEN
				EXIT;
			END IF;
			sDisposition:=NULL; sRecStatus:=NULL;
		END LOOP;
		CLOSE c_imp_pricegroup;
            COMMIT;

		INSERTS:=nInsertCount;
		UPDATES:=nUpdateCount;
		FAILED:=nFailed;
		DUPS:=nDups;
	EXCEPTION
		WHEN OTHERS THEN
			x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_KRS.KRS_PRICE_GROUP',11276);
	END;
	END;
END KRS_PRICE_GROUP;
------------------------------------------------------------------------------------------------------------------------
END CZ_IMP_PR_KRS;

/
