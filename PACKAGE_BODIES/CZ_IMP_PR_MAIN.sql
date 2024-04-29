--------------------------------------------------------
--  DDL for Package Body CZ_IMP_PR_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_PR_MAIN" AS
/*	$Header: cziprmnb.pls 115.18 2002/12/03 14:47:45 askhacha ship $		*/


PROCEDURE CND_PRICE (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_price IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_PRICE WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_price   				c_imp_price%ROWTYPE;
		x_imp_price_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_price;
		LOOP
			FETCH c_imp_price INTO p_imp_price;
			x_imp_price_f:=c_imp_price%FOUND;

		EXIT WHEN(NOT x_imp_price_f Or nFailed >= Max_Err);
		IF (p_imp_price.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_PRICE SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_price.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.CND_PRICE',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_price;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.CND_PRICE',11276);
	END;

END CND_PRICE;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_PRICE_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_pricegroup IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_PRICE_GROUP WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_pricegroup   				c_imp_pricegroup%ROWTYPE;
		x_imp_pricegroup_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_pricegroup;
		LOOP
			FETCH c_imp_pricegroup INTO p_imp_pricegroup;
			x_imp_pricegroup_f:=c_imp_pricegroup%FOUND;

		EXIT WHEN(NOT x_imp_pricegroup_f Or nFailed >= Max_Err);
		IF (p_imp_pricegroup.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_PRICE_GROUP SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_pricegroup.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.CND_PRICE_GROUP',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_pricegroup;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.CND_PRICE_GROUP',11276);
	END;

END CND_PRICE_GROUP;


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_PRICE (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                                        DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);

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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.MAIN_PRICE',11276);
         END;

		CZ_IMP_PR_MAIN.CND_PRICE (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
		IF (nFailed=MAX_ERR) THEN
			INSERTS:=0;
			UPDATES:=0;
			FAILED:=MAX_ERR;
			DUPS:=0;
			return;
		END IF;

		CZ_IMP_PR_KRS.KRS_PRICE (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);

		/* Make sure that the error count has not been reached */
		IF(nFailed < MAX_ERR) THEN
			CZ_IMP_PR_XFR.XFR_PRICE (inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_PR_MAIN.MAIN_PRICE ',11276);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_PR_MAIN.MAIN_PRICE',11276);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

			FAILED:=FAILED+nFailed;
		ELSE
			FAILED:=nFailed;
		END IF;

          CZ_IMP_PR_MAIN.RPT_PRICE(inRUN_ID);
        END ;
END MAIN_PRICE ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_PRICE_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		IN   OUT NOCOPY PLS_INTEGER,
					UPDATES		IN OUT NOCOPY 	PLS_INTEGER,
					FAILED		IN   OUT NOCOPY PLS_INTEGER,
                                        DUPS            IN OUT NOCOPY  PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					) IS
BEGIN
	DECLARE
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
                nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
		nXfrInsertCount						PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount						PLS_INTEGER:=0;			/*Updates */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
                nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
		x_error							BOOLEAN:=FALSE;
                dummy                                                   CHAR(1);
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.MAIN_PRICE_GROUP',11276);
         END;

                CZ_IMP_PR_MAIN.CND_PRICE_GROUP (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
		IF (nFailed=MAX_ERR) THEN
			INSERTS:=0;
			UPDATES:=0;
			FAILED:=MAX_ERR;
			DUPS:=0;
			return;
		END IF;

		CZ_IMP_PR_KRS.KRS_PRICE_GROUP (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);

		/* Make sure that the error count has not been reached */
		IF(nFailed < MAX_ERR) THEN
			CZ_IMP_PR_XFR.XFR_PRICE_GROUP(inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_PR_MAIN.MAIN_PRICE_GROUP ',11276);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_PR_MAIN.MAIN_PRICE_GROUP ',11276);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

			FAILED:=FAILED+nFailed;
		ELSE
			FAILED:=nFailed;
		END IF;

          CZ_IMP_PR_MAIN.RPT_PRICE_GROUP(inRUN_ID);
	END ;
END MAIN_PRICE_GROUP;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_PRICE ( inRUN_ID IN PLS_INTEGER ) AS
                        x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_PRICES';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_price
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
                     VALUES(inRUN_ID,'CZ_PRICES',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.RPT_PRICE',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_PRICES';
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED='1'
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.RPT_PRICE',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.RPT_PRICE',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_PRICE_GROUP ( inRUN_ID IN PLS_INTEGER ) AS
                              x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_PRICE_GROUPS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM CZ_IMP_price_group
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
                     VALUES(inRUN_ID,'CZ_PRICE_GROUPS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.RPT_PRICE_GROUP',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_PRICE_GROUPS';
              BEGIN
                OPEN c_get_nErrors;
                FETCH c_get_nErrors INTO nErrors;
                CLOSE c_get_nErrors;
                UPDATE CZ_XFR_RUN_INFOS
                 SET TOTAL_ERRORS=NVL(TOTAL_ERRORS,0)+NVL(nErrors,0),
                     COMPLETED='1'
                WHERE RUN_ID=inRUN_ID;
               COMMIT;
               EXCEPTION
                WHEN OTHERS THEN
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.RPT_PRICE_GROUP',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_PR_MAIN.RPT_PRICE_GROUP',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

END CZ_IMP_PR_MAIN;

/
