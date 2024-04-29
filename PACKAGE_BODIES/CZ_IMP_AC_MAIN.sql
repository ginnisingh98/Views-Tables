--------------------------------------------------------
--  DDL for Package Body CZ_IMP_AC_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_AC_MAIN" AS
/*	$Header: cziacmnb.pls 115.19 2002/12/03 14:44:34 askhacha ship $		*/

PROCEDURE CND_CONTACT (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_contact IS
		SELECT DELETED_FLAG, ROWID FROM CZ_IMP_CONTACT WHERE REC_STATUS IS NULL
		AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_contact   				c_imp_contact%ROWTYPE;
		x_imp_contact_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_contact;
		LOOP
			FETCH c_imp_contact INTO p_imp_contact;
			x_imp_contact_f:=c_imp_contact%FOUND;

		EXIT WHEN(NOT x_imp_contact_f Or nFailed >= Max_Err);
		IF (p_imp_contact.DELETED_FLAG IS NULL) THEN
			BEGIN
				UPDATE CZ_IMP_CONTACT
				SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG)
				WHERE ROWID = p_imp_contact.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_CONTACT',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_contact;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_CONTACT',11276);
	END;

END CND_CONTACT;


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_CUSTOMER (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_customer IS
		SELECT DELETED_FLAG, ROWID FROM CZ_IMP_CUSTOMER WHERE REC_STATUS IS NULL
		AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_customer   				c_imp_customer%ROWTYPE;
		x_imp_customer_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_customer;
		LOOP
			FETCH c_imp_customer INTO p_imp_customer;
			x_imp_customer_f:=c_imp_customer%FOUND;

		EXIT WHEN(NOT x_imp_customer_f Or nFailed >= Max_Err);
		IF (p_imp_customer.DELETED_FLAG IS NULL) THEN
			BEGIN
				UPDATE CZ_IMP_CUSTOMER
				SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG)
			WHERE ROWID = p_imp_customer.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_CUSTOMER',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_customer;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_CUSTOMER',11276);
	END;

END CND_CUSTOMER;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_ADDRESS (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_address IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_ADDRESS WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_address   				c_imp_address%ROWTYPE;
		x_imp_address_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_address;
		LOOP
			FETCH c_imp_address INTO p_imp_address;
			x_imp_address_f:=c_imp_address%FOUND;

		EXIT WHEN(NOT x_imp_address_f Or nFailed >= Max_Err);
		IF (p_imp_address.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_ADDRESS SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_address.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_ADDRESS',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_address;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_ADDRESS',11276);
	END;

END CND_ADDRESS;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE CND_ADDRESS_USES(inRUN_ID    IN	 PLS_INTEGER,
                           COMMIT_SIZE IN	 PLS_INTEGER,
				   MAX_ERR	   IN	 PLS_INTEGER,
				   FAILED	   OUT NOCOPY PLS_INTEGER
				  ) IS
BEGIN
  DECLARE
    CURSOR c_imp_address_uses IS
      SELECT DELETED_FLAG, ROWID FROM CZ_IMP_ADDRESS_USE
      WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
    /* Internal vars */
	nCommitCount  PLS_INTEGER:=0;	/*COMMIT buffer index */
	nErrorCount   PLS_INTEGER:=0;	/*Error index */
	nFailed       PLS_INTEGER:=0;	/*Failed records */
	nDups         PLS_INTEGER:=0;	/*Duplicate records */
	x_error       BOOLEAN:=FALSE;

    /*Cursor Var for Import */
	p_imp_address_uses    c_imp_address_uses%ROWTYPE;
	x_imp_address_uses_f  BOOLEAN:=FALSE;

  BEGIN
    OPEN c_imp_address_uses;
	LOOP
        FETCH c_imp_address_uses INTO p_imp_address_uses;
        x_imp_address_uses_f:=c_imp_address_uses%FOUND;

        EXIT WHEN(NOT x_imp_address_uses_f Or nFailed >= Max_Err);

        IF(p_imp_address_uses.DELETED_FLAG IS NULL) THEN
          BEGIN
           UPDATE CZ_IMP_ADDRESS_USE
           SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG)
           WHERE ROWID = p_imp_address_uses.ROWID;

           nCOmmitCount:=nCommitCount+1;
           /* COMMIT if the buffer size is reached */
           IF(nCommitCount>= COMMIT_SIZE) THEN
             COMMIT;
             nCommitCount:=0;
           END IF;

           EXCEPTION
             WHEN OTHERS THEN
               x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_ADDRESS_USES',11276);
               nFailed:=nFailed+1;
          END;
        END IF;
      END LOOP;
	CLOSE c_imp_address_uses;
	FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
        x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_ADDRESS_USES',11276);
END;
END CND_ADDRESS_USES;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_CUSTOMER_END_USER (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_customerenduser IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_CUSTOMER_END_USER WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_customerenduser   				c_imp_customerenduser%ROWTYPE;
		x_imp_customerenduser_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_customerenduser;
		LOOP
			FETCH c_imp_customerenduser INTO p_imp_customerenduser;
			x_imp_customerenduser_f:=c_imp_customerenduser%FOUND;

		EXIT WHEN(NOT x_imp_customerenduser_f Or nFailed >= Max_Err);
		IF (p_imp_customerenduser.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_CUSTOMER_END_USER SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_customerenduser.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_CUSTOMER_END_USER',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_customerenduser;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_CUSTOMER',11276);
	END;

END CND_CUSTOMER_END_USER;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_END_USER(	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_enduser IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_END_USER WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_enduser   				c_imp_enduser%ROWTYPE;
		x_imp_enduser_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_enduser;
		LOOP
			FETCH c_imp_enduser INTO p_imp_enduser;
			x_imp_enduser_f:=c_imp_enduser%FOUND;

		EXIT WHEN(NOT x_imp_enduser_f Or nFailed >= Max_Err);
		IF (p_imp_enduser.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_END_USER SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_enduser.ROWID;
				nCOmmitCount:=nCommitCount+1;
      			/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_END_USER',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_enduser;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_END_USER',11276);

	END;

END CND_END_USER;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_END_USER_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_endusergroup IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_END_USER_GROUP WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_endusergroup   				c_imp_endusergroup%ROWTYPE;
		x_imp_endusergroup_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_endusergroup;
		LOOP
			FETCH c_imp_endusergroup INTO p_imp_endusergroup;
			x_imp_endusergroup_f:=c_imp_endusergroup%FOUND;

		EXIT WHEN(NOT x_imp_endusergroup_f Or nFailed >= Max_Err);
		IF (p_imp_endusergroup.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_END_USER_GROUP SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_endusergroup.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_END_USER_GROUP',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_endusergroup;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_END_USER_GROUP',11276);
	END;

END CND_END_USER_GROUP;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_USER_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
					COMMIT_SIZE		IN	PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					FAILED		  OUT NOCOPY PLS_INTEGER
					) IS
BEGIN
	DECLARE
		CURSOR c_imp_usergroup IS
                        SELECT DELETED_FLAG, ROWID FROM CZ_IMP_USER_GROUP WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount							PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups								PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_usergroup   				c_imp_usergroup%ROWTYPE;
		x_imp_usergroup_f				BOOLEAN:=FALSE;

	BEGIN

		OPEN 	c_imp_usergroup;
		LOOP
			FETCH c_imp_usergroup INTO p_imp_usergroup;
			x_imp_usergroup_f:=c_imp_usergroup%FOUND;

		EXIT WHEN(NOT x_imp_usergroup_f Or nFailed >= Max_Err);
		IF (p_imp_usergroup.DELETED_FLAG IS NULL) THEN
			BEGIN
                                UPDATE CZ_IMP_USER_GROUP SET DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG) WHERE ROWID = p_imp_usergroup.ROWID;
				nCOmmitCount:=nCommitCount+1;
				/* COMMIT if the buffer size is reached */
				IF (nCommitCount>= COMMIT_SIZE) THEN
					COMMIT;
					nCommitCount:=0;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_USER_GROUP',11276);
				nFailed:=nFailed+1;
			END;
		END IF;
		END LOOP;
		CLOSE c_imp_usergroup;
		FAILED:=nFailed;

	EXCEPTION
	WHEN OTHERS THEN
		x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.CND_USER_GROUP',11276);
	END;

END CND_USER_GROUP;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_CONTACT (	inRUN_ID 		IN 	PLS_INTEGER,
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_CONTACT',11276);
         END;

		CZ_IMP_AC_MAIN.CND_CONTACT (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
		IF (nFailed=MAX_ERR) THEN
			INSERTS:=0;
			UPDATES:=0;
			FAILED:=MAX_ERR;
			DUPS:=0;
			RETURN;
		END IF;

		CZ_IMP_AC_KRS.KRS_CONTACT (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);

		/* Make sure that the error count has not been reached */
		IF(nFailed < MAX_ERR) THEN
			CZ_IMP_AC_XFR.XFR_CONTACT (inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_AC.MAIN_CONTACT',11276);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_AC.MAIN_CONTACT',11276);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

			FAILED:=FAILED+nFailed;
		ELSE
			FAILED:=nFailed;
		END IF;

           CZ_IMP_AC_MAIN.RPT_CONTACT(inRUN_ID);
	END ;
END MAIN_CONTACT ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_CUSTOMER (           inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         IN OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         IN OUT NOCOPY     PLS_INTEGER,
                                   FAILED          IN OUT NOCOPY     PLS_INTEGER,
                                   DUPS            IN OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           /* Internal vars */
           nCommitCount                                            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
           nXfrInsertCount                                         PLS_INTEGER:=0;                 /*Inserts */
           nXfrUpdateCount                                         PLS_INTEGER:=0;                 /*Updates */
           nFailed                                                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
           x_error                                                 BOOLEAN:=FALSE;
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_CUSTOMER',11276);
         END;

           CZ_IMP_AC_MAIN.CND_CUSTOMER (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
           IF (nFailed=MAX_ERR) THEN
                   INSERTS:=0;
                   UPDATES:=0;
                   FAILED:=MAX_ERR;
                   DUPS:=0;
                   return;
           END IF;
           CZ_IMP_AC_KRS.KRS_CUSTOMER (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);
           /* Make sure that the error count has not been reached */
           IF(nFailed < MAX_ERR) THEN
                   CZ_IMP_AC_XFR.XFR_CUSTOMER (inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
                   /* Report Insert Errors */
                   IF (nXfrInsertCount<> INSERTS) THEN
                           x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_AC.MAIN_CUSTOMER ',11276);
                   END IF;
                   /* Report Update Errors */
                   IF (nXfrUpdateCount<> UPDATES) THEN
                           x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_AC.MAIN_CUSTOMER ',11276);
                   END IF;
                   /* Return the transferred number of rows and not the number of rows with keys resolved*/
                   INSERTS:=nXfrInsertCount;
                   UPDATES:=nXfrUpdateCount;
                   FAILED:=FAILED+nFailed;
           ELSE
                   FAILED:=nFailed;
           END IF;

     CZ_IMP_AC_MAIN.RPT_CUSTOMER(inRUN_ID);
   END;
END MAIN_CUSTOMER ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_ADDRESS (           inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         IN OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         IN OUT NOCOPY     PLS_INTEGER,
                                   FAILED          IN OUT NOCOPY     PLS_INTEGER,
                                   DUPS            IN OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           /* Internal vars */
           nCommitCount                                            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
           nXfrInsertCount                                         PLS_INTEGER:=0;                 /*Inserts */
           nXfrUpdateCount                                         PLS_INTEGER:=0;                 /*Updates */
           nFailed                                                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
           x_error                                                 BOOLEAN:=FALSE;
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_ADDRESS',11276);
         END;

           CZ_IMP_AC_MAIN.CND_ADDRESS (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
           IF (nFailed=MAX_ERR) THEN
                   INSERTS:=0;
                   UPDATES:=0;
                   FAILED:=MAX_ERR;
                   DUPS:=0;
                   return;
           END IF;
           CZ_IMP_AC_KRS.KRS_ADDRESS (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);
           /* Make sure that the error count has not been reached */
           IF(nFailed < MAX_ERR) THEN
                   CZ_IMP_AC_XFR.XFR_ADDRESS (inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
                   /* Report Insert Errors */
                   IF (nXfrInsertCount<> INSERTS) THEN
                           x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_AC.MAIN_ADDRESS ',11276);
                   END IF;
                   /* Report Update Errors */
                   IF (nXfrUpdateCount<> UPDATES) THEN
                           x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_AC.MAIN_ADDRESS ',11276);
                   END IF;
                   /* Return the transferred number of rows and not the number of rows with keys resolved*/
                   INSERTS:=nXfrInsertCount;
                   UPDATES:=nXfrUpdateCount;
                   FAILED:=FAILED+nFailed;
           ELSE
                   FAILED:=nFailed;
           END IF;

     CZ_IMP_AC_MAIN.RPT_ADDRESS(inRUN_ID);
   END;
END MAIN_ADDRESS ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_ADDRESS_USES(inRUN_ID    IN  PLS_INTEGER,
                            COMMIT_SIZE IN  PLS_INTEGER,
                            MAX_ERR     IN  PLS_INTEGER,
                            INSERTS     IN OUT NOCOPY PLS_INTEGER,
                            UPDATES     IN OUT NOCOPY PLS_INTEGER,
                            FAILED      IN OUT NOCOPY PLS_INTEGER,
                            DUPS        IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                           ) IS
BEGIN
  DECLARE
    /* Internal vars */
    nCommitCount     PLS_INTEGER:=0; /* COMMIT buffer index */
    nErrorCount      PLS_INTEGER:=0; /* Error index */
    nXfrInsertCount  PLS_INTEGER:=0; /* Inserts */
    nXfrUpdateCount  PLS_INTEGER:=0; /* Updates */
    nFailed          PLS_INTEGER:=0; /* Failed records */
    nDups            PLS_INTEGER:=0; /* Dupl records */
    x_error          BOOLEAN:=FALSE;
    dummy            CHAR(1);

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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_ADDRESS_USES',11276);
         END;

    CZ_IMP_AC_MAIN.CND_ADDRESS_USES(inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
    IF(nFailed=MAX_ERR) THEN
      INSERTS:=0;
      UPDATES:=0;
      FAILED:=MAX_ERR;
      DUPS:=0;
     return;
    END IF;
    CZ_IMP_AC_KRS.KRS_ADDRESS_USES(inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);
    /* Make sure that the error count has not been reached */
    IF(nFailed < MAX_ERR) THEN
      CZ_IMP_AC_XFR.XFR_ADDRESS_USES(inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
      /* Report Insert Errors */
      IF(nXfrInsertCount<> INSERTS) THEN
        x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_AC.MAIN_ADDRESS_USES ',11276);
      END IF;
      /* Report Update Errors */
      IF(nXfrUpdateCount<> UPDATES) THEN
        x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_AC.MAIN_ADDRESS_USES ',11276);
      END IF;
    /* Return the transferred number of rows and not the number of rows with keys resolved */
     INSERTS:=nXfrInsertCount;
     UPDATES:=nXfrUpdateCount;
     FAILED:=FAILED+nFailed;
    ELSE
     FAILED:=nFailed;
    END IF;

    CZ_IMP_AC_MAIN.RPT_ADDRESS_USES(inRUN_ID);
  END;
END MAIN_ADDRESS_USES;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_CUSTOMER_END_USER (  inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         IN OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         IN OUT NOCOPY     PLS_INTEGER,
                                   FAILED          IN OUT NOCOPY     PLS_INTEGER,
                                   DUPS            IN OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           /* Internal vars */
           nCommitCount                                            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
           nXfrInsertCount                                         PLS_INTEGER:=0;                 /*Inserts */
           nXfrUpdateCount                                         PLS_INTEGER:=0;                 /*Updates */
           nFailed                                                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
           x_error                                                 BOOLEAN:=FALSE;
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_CUSTOMER_END_USER',11276);
         END;

           CZ_IMP_AC_MAIN.CND_CUSTOMER_END_USER (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
           IF (nFailed=MAX_ERR) THEN
                   INSERTS:=0;
                   UPDATES:=0;
                   FAILED:=MAX_ERR;
                   DUPS:=0;
                   return;
           END IF;
           CZ_IMP_AC_KRS.KRS_CUSTOMER_END_USER (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);
           /* Make sure that the error count has not been reached */
           IF(nFailed < MAX_ERR) THEN
                   CZ_IMP_AC_XFR.XFR_CUSTOMER_END_USER (inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
                   /* Report Insert Errors */
                   IF (nXfrInsertCount<> INSERTS) THEN
                           x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_AC.MAIN_CUSTOMER_END_USER ',11276);
                   END IF;
                   /* Report Update Errors */
                   IF (nXfrUpdateCount<> UPDATES) THEN
                           x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_AC.MAIN_CUSTOMER_END_USER ',11276);
                   END IF;
                   /* Return the transferred number of rows and not the number of rows with keys resolved*/
                   INSERTS:=nXfrInsertCount;
                   UPDATES:=nXfrUpdateCount;
                   FAILED:=FAILED+nFailed;
           ELSE
                   FAILED:=nFailed;
           END IF;

     CZ_IMP_AC_MAIN.RPT_CUSTOMER_END_USER(inRUN_ID);
   END;
END MAIN_CUSTOMER_END_USER ;


/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_END_USER (	inRUN_ID 		IN 	PLS_INTEGER,
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_END_USER',11276);
         END;

		CZ_IMP_AC_MAIN.CND_END_USER (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
		IF (nFailed=MAX_ERR) THEN
			INSERTS:=0;
			UPDATES:=0;
			FAILED:=MAX_ERR;
			DUPS:=0;
			RETURN;
		END IF;

		CZ_IMP_AC_KRS.KRS_END_USER(inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);

		/* Make sure that the error count has not been reached */
		IF(nFailed < MAX_ERR) THEN
			CZ_IMP_AC_XFR.XFR_END_USER(inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_AC.MAIN_END_USER ',11276);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_AC.MAIN_END_USER ',11276);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

			FAILED:=FAILED+nFailed;
		ELSE
			FAILED:=nFailed;
		END IF;

          CZ_IMP_AC_MAIN.RPT_END_USER(inRUN_ID);
	END ;
END MAIN_END_USER;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_END_USER_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_END_USER_GROUP',11276);
         END;

		CZ_IMP_AC_MAIN.CND_END_USER_GROUP (inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
		IF (nFailed=MAX_ERR) THEN
			INSERTS:=0;
			UPDATES:=0;
			FAILED:=MAX_ERR;
			DUPS:=0;
			RETURN;
		END IF;

		CZ_IMP_AC_KRS.KRS_END_USER_GROUP(inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);

		/* Make sure that the error count has not been reached */
		IF(nFailed < MAX_ERR) THEN
			CZ_IMP_AC_XFR.XFR_END_USER_GROUP(inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_AC.MAIN_END_USER_GROUP ',11276);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_AC.MAIN_END_USER_GROUP ',11276);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

			FAILED:=FAILED+nFailed;
		ELSE
			FAILED:=nFailed;
		END IF;

          CZ_IMP_AC_MAIN.RPT_END_USER_GROUP(inRUN_ID);
	END ;
END MAIN_END_USER_GROUP;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE MAIN_USER_GROUP (	inRUN_ID 		IN 	PLS_INTEGER,
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
            x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.MAIN_USER_GROUP',11276);
         END;

        	CZ_IMP_AC_MAIN.CND_USER_GROUP(inRun_ID,COMMIT_SIZE,MAX_ERR,nFailed);
		IF (nFailed=MAX_ERR) THEN
			INSERTS:=0;
			UPDATES:=0;
			FAILED:=MAX_ERR;
			DUPS:=0;
			RETURN;
		END IF;

		CZ_IMP_AC_KRS.KRS_USER_GROUP(inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,nFailed,DUPS,inXFR_GROUP);

		/* Make sure that the error count has not been reached */
		IF(nFailed < MAX_ERR) THEN
			CZ_IMP_AC_XFR.XFR_USER_GROUP (inRUN_ID,COMMIT_SIZE,MAX_ERR-nFailed,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);
			/* Report Insert Errors */
			IF (nXfrInsertCount<> INSERTS) THEN
	 			x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_AC.MAIN_USER_GROUP',11276);
			END IF;

			/* Report Update Errors */
			IF (nXfrUpdateCount<> UPDATES) THEN
				x_error:=CZ_IMP_ALL.REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_AC.MAIN_USER_GROUP ',11276);
			END IF;

			/* Return the transferred number of rows and not the number of rows with keys resolved*/
			INSERTS:=nXfrInsertCount;
			UPDATES:=nXfrUpdateCount;

			FAILED:=FAILED+nFailed;
		ELSE
			FAILED:=nFailed;
		END IF;

          CZ_IMP_AC_MAIN.RPT_USER_GROUP(inRUN_ID);
	END ;
END MAIN_USER_GROUP;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_CONTACT ( inRUN_ID IN PLS_INTEGER ) AS
                          x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_CONTACTS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_contact
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_CONTACTS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CONTACT',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_CONTACTS';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CONTACT',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CONTACT',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_CUSTOMER ( inRUN_ID IN PLS_INTEGER ) AS
                          x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_CUSTOMERS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_customer
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_CUSTOMERS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CUSTOMER',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_CUSTOMERS';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CUSTOMER',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CUSTOMER',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_ADDRESS ( inRUN_ID IN PLS_INTEGER ) AS
                          x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_ADDRESSES';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_address
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_ADDRESSES',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_ADDRESS',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_ADDRESSES';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_ADDRESS',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_ADDRESS',11276);
  END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_ADDRESS_USES ( inRUN_ID IN PLS_INTEGER ) AS
                               x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_ADDRESS_USES';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_address_use
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_ADDRESS_USES',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_ADDRESS_USES',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_ADDRESS_USES';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_ADDRESS_USES',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_ADDRESS_USES',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_CUSTOMER_END_USER ( inRUN_ID IN PLS_INTEGER ) AS
                                   x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_CUSTOMER_END_USERS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_customer_end_user
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_CUSTOMER_END_USERS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CUSTOMER_END_USER',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_CUSTOMER_END_USERS';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CUSTOMER_END_USER',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_CUSTOMER_END_USER',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_END_USER ( inRUN_ID IN PLS_INTEGER ) AS
                           x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_END_USERS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_end_user
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_END_USERS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_END_USER',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_END_USERS';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_END_USER',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_END_USER',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_END_USER_GROUP ( inRUN_ID IN PLS_INTEGER ) AS
                                 x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_END_USER_GROUPS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_end_user_group
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_END_USER_GROUPS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_END_USER_GROUP',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_END_USER_GROUPS';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_END_USER_GROUP',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_END_USER_GROUP',11276);
  END;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_USER_GROUP ( inRUN_ID IN PLS_INTEGER ) AS
                             x_error     BOOLEAN:=FALSE;
  BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE='CZ_USER_GROUPS';

         EXCEPTION
              WHEN NO_DATA_FOUND THEN NULL;
       END;

       DECLARE
             CURSOR c_xfr_run_result IS
                                SELECT DISPOSITION,REC_STATUS,COUNT(*)
                                  FROM cz_imp_user_group
                                 WHERE RUN_ID = inRUN_ID
                              GROUP BY DISPOSITION,REC_STATUS;

                              ins_disposition        cz_xfr_run_results.disposition%TYPE;
                              ins_rec_status         cz_xfr_run_results.rec_status%TYPE ;
                              ins_rec_count          cz_xfr_run_results.records%TYPE    ;

              BEGIN

                  OPEN c_xfr_run_result;
                  LOOP
                     FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
                     EXIT WHEN c_xfr_run_result%NOTFOUND;

                     INSERT INTO CZ_XFR_RUN_RESULTS(RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,'CZ_USER_GROUPS',ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_USER_GROUP',11276);
              END;

              DECLARE
               nErrors  PLS_INTEGER;
               CURSOR c_get_nErrors IS
                SELECT SUM(NVL(RECORDS,0)) FROM CZ_XFR_RUN_RESULTS
                WHERE REC_STATUS<>'OK' AND RUN_ID=inRUN_ID
                AND IMP_TABLE='CZ_USER_GROUPS';
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
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_USER_GROUP',11276);
              END;
       EXCEPTION
        WHEN OTHERS THEN
          x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.RPT_USER_GROUP',11276);
  END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

END CZ_IMP_AC_MAIN;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/
