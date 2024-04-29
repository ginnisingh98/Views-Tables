--------------------------------------------------------
--  DDL for Package Body CZ_IMP_AC_XFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_AC_XFR" AS
/*	$Header: cziacxfb.pls 115.14 2002/11/27 16:59:28 askhacha ship $		*/

  PROCEDURE XFR_CONTACT (    inRUN_ID                IN      PLS_INTEGER,
                                     COMMIT_SIZE     IN      PLS_INTEGER,
                                     MAX_ERR         IN      PLS_INTEGER,
                                     INSERTS         OUT NOCOPY     PLS_INTEGER,
                                     UPDATES         OUT NOCOPY     PLS_INTEGER,
                                     FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                     ) IS
  BEGIN
             DECLARE CURSOR c_xfr_contact IS
			   SELECT * FROM CZ_IMP_CONTACT
			WHERE CZ_IMP_CONTACT.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
					 x_xfr_contact_f                                         BOOLEAN:=FALSE;
                     x_error                                                 BOOLEAN:=FALSE;
                     p_xfr_contact   c_xfr_contact%ROWTYPE;
                     /* Internal vars */
                     nCommitCount            PLS_INTEGER:=0;                 /*COMMIT buffer index */
                     nInsertCount            PLS_INTEGER:=0;                 /*Inserts */
                     nUpdateCount            PLS_INTEGER:=0;                 /*Updates */
                     nFailed                 PLS_INTEGER:=0;                 /*Failed records */
                     NOUPDATE_CUSTOMER_ID                NUMBER;
                     NOUPDATE_ADDRESS_ID                NUMBER;
                     NOUPDATE_SALUTATION                NUMBER;
                     NOUPDATE_FIRSTNAME                 NUMBER;
                     NOUPDATE_MI                        NUMBER;
                     NOUPDATE_LASTNAME                  NUMBER;
                     NOUPDATE_SUFFIX                    NUMBER;
                     NOUPDATE_TITLE                     NUMBER;
                     NOUPDATE_PHONE                     NUMBER;
                     NOUPDATE_ALT_PHONE                 NUMBER;
                     NOUPDATE_FAX                       NUMBER;
                     NOUPDATE_PAGER                     NUMBER;
                     NOUPDATE_CELLULAR                  NUMBER;
                     NOUPDATE_EMAIL_ADDR                NUMBER;
                     NOUPDATE_NOTE                      NUMBER;
                     NOUPDATE_DELETED_FLAG              NUMBER;
                     NOUPDATE_USER_STR01                NUMBER;
                     NOUPDATE_USER_STR02                NUMBER;
                     NOUPDATE_USER_STR03                NUMBER;
                     NOUPDATE_USER_STR04                NUMBER;
                     NOUPDATE_USER_NUM01                NUMBER;
                     NOUPDATE_USER_NUM02                NUMBER;
                     NOUPDATE_USER_NUM03                NUMBER;
                     NOUPDATE_USER_NUM04                NUMBER;
                     NOUPDATE_CREATION_DATE                   NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE                  NUMBER;
                     NOUPDATE_CREATED_BY                NUMBER;
                     NOUPDATE_LAST_UPDATED_BY               NUMBER;
                     NOUPDATE_SECURITY_MASK             NUMBER;
                     NOUPDATE_CHECKOUT_USER             NUMBER;
                     NOUPDATE_PRIMARY_ROLE              NUMBER;
                     NOUPDATE_ORIG_SYS_REF              NUMBER;

             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_CUSTOMER_ID                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','CUSTOMER_ID',inXFR_GROUP);
                     NOUPDATE_ADDRESS_ID                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','ADDRESS_ID',inXFR_GROUP);
                     NOUPDATE_SALUTATION                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','SALUTATION',inXFR_GROUP);
                     NOUPDATE_FIRSTNAME                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','FIRSTNAME',inXFR_GROUP);
                     NOUPDATE_MI                        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','MI',inXFR_GROUP);
                     NOUPDATE_LASTNAME                  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','LASTNAME',inXFR_GROUP);
                     NOUPDATE_SUFFIX                    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','SUFFIX',inXFR_GROUP);
                     NOUPDATE_TITLE                     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','TITLE',inXFR_GROUP);
                     NOUPDATE_PHONE                     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','PHONE',inXFR_GROUP);
                     NOUPDATE_ALT_PHONE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','ALT_PHONE',inXFR_GROUP);
                     NOUPDATE_FAX                       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','FAX',inXFR_GROUP);
                     NOUPDATE_PAGER                     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','PAGER',inXFR_GROUP);
                     NOUPDATE_CELLULAR                  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','CELLULAR',inXFR_GROUP);
                     NOUPDATE_EMAIL_ADDR                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','EMAIL_ADDR',inXFR_GROUP);
                     NOUPDATE_NOTE                      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','NOTE',inXFR_GROUP);
                     NOUPDATE_DELETED_FLAG              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','DELETED_FLAG',inXFR_GROUP);
                     NOUPDATE_USER_STR01                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_STR01',inXFR_GROUP);
                     NOUPDATE_USER_STR02                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_STR02',inXFR_GROUP);
                     NOUPDATE_USER_STR03                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_STR03',inXFR_GROUP);
                     NOUPDATE_USER_STR04                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_STR04',inXFR_GROUP);
                     NOUPDATE_USER_NUM01                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_NUM01',inXFR_GROUP);
                     NOUPDATE_USER_NUM02                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_NUM02',inXFR_GROUP);
                     NOUPDATE_USER_NUM03                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_NUM03',inXFR_GROUP);
                     NOUPDATE_USER_NUM04                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','USER_NUM04',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE                   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE                  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_SECURITY_MASK             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','SECURITY_MASK',inXFR_GROUP);
                     NOUPDATE_CHECKOUT_USER             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','CHECKOUT_USER',inXFR_GROUP);
                     NOUPDATE_PRIMARY_ROLE              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','PRIMARY_ROLE',inXFR_GROUP);
                     NOUPDATE_ORIG_SYS_REF              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CONTACTS','ORIG_SYS_REF',inXFR_GROUP);

                     OPEN c_xfr_contact;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_contact  INTO       p_xfr_contact;
                             x_xfr_contact_f:=c_xfr_contact%FOUND;
                             EXIT WHEN (NOT x_xfr_contact_f Or nFailed >= Max_Err);
                             IF (p_xfr_contact.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_CONTACTS (
                                                    CONTACT_ID,CUSTOMER_ID,ADDRESS_ID,SALUTATION,FIRSTNAME,MI,LASTNAME,SUFFIX,
                                                    TITLE,PHONE,ALT_PHONE,FAX,PAGER,CELLULAR,EMAIL_ADDR,NOTE,
                                                    DELETED_FLAG,
                                                    USER_STR01,USER_STR02,USER_STR03,USER_STR04,
                                                    USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
                                                    CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,SECURITY_MASK,
                                                    CONTACT_HANDLE,CHECKOUT_USER,PRIMARY_ROLE,ORIG_SYS_REF) VALUES(
                                                    p_xfr_contact.CONTACT_ID,p_xfr_contact.CUSTOMER_ID,p_xfr_contact.ADDRESS_ID,
                                                    p_xfr_contact.SALUTATION,p_xfr_contact.FIRSTNAME,
                                                    p_xfr_contact.MI,p_xfr_contact.LASTNAME,p_xfr_contact.SUFFIX,
                                                    p_xfr_contact.TITLE,p_xfr_contact.PHONE,p_xfr_contact.ALT_PHONE,
                                                    p_xfr_contact.FAX,p_xfr_contact.PAGER,p_xfr_contact.CELLULAR,
                                                    p_xfr_contact.EMAIL_ADDR,p_xfr_contact.NOTE,
                                                    p_xfr_contact.DELETED_FLAG,
                                                    p_xfr_contact.USER_STR01,p_xfr_contact.USER_STR02,
                                                    p_xfr_contact.USER_STR03,p_xfr_contact.USER_STR04,
                                                    p_xfr_contact.USER_NUM01,p_xfr_contact.USER_NUM02,
                                                    p_xfr_contact.USER_NUM03,p_xfr_contact.USER_NUM04,
                                                    SYSDATE,SYSDATE, 1, 1, NULL,p_xfr_contact.CONTACT_HANDLE,
                                                    p_xfr_contact.CHECKOUT_USER,p_xfr_contact.PRIMARY_ROLE,
                                                    p_xfr_contact.ORIG_SYS_REF);
                                             nInsertCount:=nInsertCount+1;
                                             BEGIN
                                                UPDATE CZ_IMP_contact
                                                   SET REC_STATUS='OK'
                                                 WHERE CONTACT_ID=p_xfr_contact.CONTACT_ID AND RUN_ID=inRUN_ID;
                                             END;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_contact
                                                          SET REC_STATUS='ERR'
                                                        WHERE CONTACT_ID=p_xfr_contact.CONTACT_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_CONTACT',11276);
                                     END ;
                             ELSIF (p_xfr_contact.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_CONTACTS SET
                                               CUSTOMER_ID=DECODE(NOUPDATE_CUSTOMER_ID,0, p_xfr_contact.CUSTOMER_ID ,CUSTOMER_ID),
                                               ADDRESS_ID=DECODE(NOUPDATE_ADDRESS_ID,0, p_xfr_contact.ADDRESS_ID ,ADDRESS_ID),
                                               SALUTATION=DECODE(NOUPDATE_SALUTATION,0, p_xfr_contact.SALUTATION ,SALUTATION),
                                               FIRSTNAME=DECODE(NOUPDATE_FIRSTNAME,0, p_xfr_contact.FIRSTNAME ,FIRSTNAME),
                                               MI=DECODE(NOUPDATE_MI,0, p_xfr_contact.MI ,MI),
                                               LASTNAME=DECODE(NOUPDATE_LASTNAME,0, p_xfr_contact.LASTNAME ,LASTNAME),
                                               SUFFIX=DECODE(NOUPDATE_SUFFIX,0, p_xfr_contact.SUFFIX ,SUFFIX),
                                               TITLE=DECODE(NOUPDATE_TITLE,0, p_xfr_contact.TITLE ,TITLE),
                                               PHONE=DECODE(NOUPDATE_PHONE,0, p_xfr_contact.PHONE ,PHONE),
                                               ALT_PHONE=DECODE(NOUPDATE_ALT_PHONE,0, p_xfr_contact.ALT_PHONE ,ALT_PHONE),
                                               FAX=DECODE(NOUPDATE_FAX,0, p_xfr_contact.FAX ,FAX),
                                               PAGER=DECODE(NOUPDATE_PAGER,0, p_xfr_contact.PAGER ,PAGER),
                                               CELLULAR=DECODE(NOUPDATE_CELLULAR,0, p_xfr_contact.CELLULAR ,CELLULAR),
                                               EMAIL_ADDR=DECODE(NOUPDATE_EMAIL_ADDR,0, p_xfr_contact.EMAIL_ADDR ,EMAIL_ADDR),
                                               NOTE=DECODE(NOUPDATE_NOTE,0, p_xfr_contact.NOTE ,NOTE),
                                               CHECKOUT_USER=DECODE(NOUPDATE_CHECKOUT_USER,0,p_xfr_contact.CHECKOUT_USER,CHECKOUT_USER),
                                               PRIMARY_ROLE=DECODE(NOUPDATE_PRIMARY_ROLE,0,p_xfr_contact.PRIMARY_ROLE,PRIMARY_ROLE),
                                               ORIG_SYS_REF=DECODE(NOUPDATE_ORIG_SYS_REF,0,p_xfr_contact.ORIG_SYS_REF,ORIG_SYS_REF),
                                               DELETED_FLAG=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_contact.DELETED_FLAG ,DELETED_FLAG),
                                               USER_NUM01=DECODE(NOUPDATE_USER_NUM01,0,p_xfr_contact.USER_NUM01,USER_NUM01),
                                               USER_NUM02=DECODE(NOUPDATE_USER_NUM02,0,p_xfr_contact.USER_NUM02,USER_NUM02),
                                               USER_NUM03=DECODE(NOUPDATE_USER_NUM03,0,p_xfr_contact.USER_NUM03,USER_NUM03),
                                               USER_NUM04=DECODE(NOUPDATE_USER_NUM04,0,p_xfr_contact.USER_NUM04,USER_NUM04),
                                               USER_STR01=DECODE(NOUPDATE_USER_STR01,0,p_xfr_contact.USER_STR01,USER_STR01),
                                               USER_STR02=DECODE(NOUPDATE_USER_STR02,0,p_xfr_contact.USER_STR02,USER_STR02),
                                               USER_STR03=DECODE(NOUPDATE_USER_STR03,0,p_xfr_contact.USER_STR03,USER_STR03),
                                               USER_STR04=DECODE(NOUPDATE_USER_STR04,0,p_xfr_contact.USER_STR04,USER_STR04),
                                               CREATION_DATE=DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                               LAST_UPDATE_DATE=DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                               CREATED_BY=DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                               LAST_UPDATED_BY=DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                               SECURITY_MASK=DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK)
                                            WHERE CONTACT_ID=p_xfr_contact.CONTACT_ID;
                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_contact
                                                          SET REC_STATUS='OK'
                                                        WHERE CONTACT_ID=p_xfr_contact.CONTACT_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_contact
                                                          SET REC_STATUS='ERR'
                                                        WHERE CONTACT_ID=p_xfr_contact.CONTACT_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_CONTACT',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_contact;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_CONTACT',11276);
             END;
  END XFR_CONTACT;
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE XFR_CUSTOMER (    inRUN_ID                IN      PLS_INTEGER,
                                     COMMIT_SIZE     IN      PLS_INTEGER,
                                     MAX_ERR         IN      PLS_INTEGER,
                                     INSERTS         OUT NOCOPY     PLS_INTEGER,
                                     UPDATES         OUT NOCOPY     PLS_INTEGER,
                                     FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                     ) IS
  BEGIN
             DECLARE CURSOR c_xfr_CUSTOMER IS
                       SELECT *
                     FROM CZ_IMP_CUSTOMER
                     WHERE CZ_IMP_CUSTOMER.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
                     x_xfr_CUSTOMER_f                                         BOOLEAN:=FALSE;
                     x_error                                                 BOOLEAN:=FALSE;
                     p_xfr_CUSTOMER   c_xfr_CUSTOMER%ROWTYPE;
                     -- Internal vars --
                     nCommitCount            PLS_INTEGER:=0;                 -- COMMIT buffer index --
                     nInsertCount            PLS_INTEGER:=0;                 -- Inserts --
                     nUpdateCount            PLS_INTEGER:=0;                 -- Updates      --
                     nFailed                 PLS_INTEGER:=0;                 -- Failed records --
                     NOUPDATE_CUSTOMER_NAME              NUMBER;
                     NOUPDATE_PARENT_ID                 NUMBER;
                     NOUPDATE_DIVISION                  NUMBER;
                     NOUPDATE_NOTE                      NUMBER;
                     NOUPDATE_DESC_TEXT                 NUMBER;
                     NOUPDATE_CUSTOMER_STATUS            NUMBER;
                     NOUPDATE_ORIG_SYS_REF              NUMBER;
                     NOUPDATE_DELETED_FLAG            NUMBER;
                     NOUPDATE_USER_STR01              NUMBER;
                     NOUPDATE_USER_STR02              NUMBER;
                     NOUPDATE_USER_STR03              NUMBER;
                     NOUPDATE_USER_STR04              NUMBER;
                     NOUPDATE_USER_NUM01              NUMBER;
                     NOUPDATE_USER_NUM02              NUMBER;
                     NOUPDATE_USER_NUM03              NUMBER;
                     NOUPDATE_USER_NUM04              NUMBER;
                     NOUPDATE_CREATION_DATE                 NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE                NUMBER;
                     NOUPDATE_CREATED_BY              NUMBER;
                     NOUPDATE_LAST_UPDATED_BY             NUMBER;
                     NOUPDATE_SECURITY_MASK           NUMBER;
                     NOUPDATE_CHECKOUT_USER           NUMBER;
                     NOUPDATE_WAREHOUSE_ID           NUMBER;
                     NOUPDATE_PRICE_LIST_ID           NUMBER;

             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_CUSTOMER_NAME              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','CUSTOMER_NAME',inXFR_GROUP);
                     NOUPDATE_PARENT_ID                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','PARENT_ID',inXFR_GROUP);
                     NOUPDATE_DIVISION                          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','DIVISION',inXFR_GROUP);
                     NOUPDATE_NOTE                      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','NOTE',inXFR_GROUP);
                     NOUPDATE_DESC_TEXT                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','DESC_TEXT',inXFR_GROUP);
                     NOUPDATE_CUSTOMER_STATUS    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','CUSTOMER_STATUS',inXFR_GROUP);
                     NOUPDATE_ORIG_SYS_REF                       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','ORIG_SYS_REF',inXFR_GROUP);
                     NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','DELETED_FLAG',inXFR_GROUP);
                     NOUPDATE_USER_STR01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_STR01',inXFR_GROUP);
                     NOUPDATE_USER_STR02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_STR02',inXFR_GROUP);
                     NOUPDATE_USER_STR03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_STR03',inXFR_GROUP);
                     NOUPDATE_USER_STR04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_STR04',inXFR_GROUP);
                     NOUPDATE_USER_NUM01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_NUM01',inXFR_GROUP);
                     NOUPDATE_USER_NUM02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_NUM02',inXFR_GROUP);
                     NOUPDATE_USER_NUM03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_NUM03',inXFR_GROUP);
                     NOUPDATE_USER_NUM04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','USER_NUM04',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','SECURITY_MASK',inXFR_GROUP);
                     NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','CHECKOUT_USER',inXFR_GROUP);
                     NOUPDATE_WAREHOUSE_ID           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','WAREHOUSE_ID',inXFR_GROUP);
                     NOUPDATE_PRICE_LIST_ID           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMERS','PRICE_LIST_ID',inXFR_GROUP);

                     OPEN c_xfr_CUSTOMER;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_CUSTOMER  INTO       p_xfr_CUSTOMER;
                             x_xfr_CUSTOMER_f:=c_xfr_CUSTOMER%FOUND;
                             EXIT WHEN (NOT x_xfr_CUSTOMER_f Or nFailed >= Max_Err);
                             IF (p_xfr_CUSTOMER.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_CUSTOMERS (
                                                    ORIG_SYS_REF,CUSTOMER_ID,CUSTOMER_NAME,PARENT_ID,
                                                    DIVISION,NOTE,DESC_TEXT,CUSTOMER_STATUS,DELETED_FLAG,
                                                    USER_STR01,USER_STR02,USER_STR03,
                                                    USER_STR04,USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
                                                    CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,SECURITY_MASK,
                                                    CHECKOUT_USER,WAREHOUSE_ID/*,PRICE_LIST_ID*/) VALUES(
                                                    p_xfr_CUSTOMER.ORIG_SYS_REF,p_xfr_CUSTOMER.CUSTOMER_ID,
                                                    p_xfr_CUSTOMER.CUSTOMER_NAME,p_xfr_CUSTOMER.PARENT_ID,
                                                    p_xfr_CUSTOMER.DIVISION,p_xfr_CUSTOMER.NOTE,p_xfr_CUSTOMER.DESC_TEXT,
                                                    p_xfr_CUSTOMER.CUSTOMER_STATUS,p_xfr_CUSTOMER.DELETED_FLAG ,
                                                    p_xfr_CUSTOMER.USER_STR01,
                                                    p_xfr_CUSTOMER.USER_STR02,p_xfr_CUSTOMER.USER_STR03,p_xfr_CUSTOMER.USER_STR04,
                                                    p_xfr_CUSTOMER.USER_NUM01,p_xfr_CUSTOMER.USER_NUM02,
                                                    p_xfr_CUSTOMER.USER_NUM03,p_xfr_CUSTOMER.USER_NUM04,
                                                    SYSDATE,SYSDATE, 1, 1, NULL,
                                                    p_xfr_CUSTOMER.CHECKOUT_USER,p_xfr_CUSTOMER.WAREHOUSE_ID/*,
                                                    p_xfr_CUSTOMER.PRICE_LIST_ID*/);
                                             nInsertCount:=nInsertCount+1;
                                             BEGIN
                                                UPDATE CZ_IMP_customer
                                                   SET REC_STATUS='OK'
                                                 WHERE CUSTOMER_ID=p_xfr_customer.CUSTOMER_ID AND RUN_ID=inRUN_ID;
                                             END;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_customer
                                                          SET REC_STATUS='ERR'
                                                        WHERE CUSTOMER_ID=p_xfr_customer.CUSTOMER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_CUSTOMER',11276);
                                     END ;
                             ELSIF (p_xfr_CUSTOMER.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_CUSTOMERS SET
                                                                                             CUSTOMER_NAME=DECODE(NOUPDATE_CUSTOMER_NAME,0, p_xfr_CUSTOMER.CUSTOMER_NAME ,CUSTOMER_NAME),
                                                                                             PARENT_ID=DECODE(NOUPDATE_PARENT_ID,0, p_xfr_CUSTOMER.PARENT_ID ,PARENT_ID),
                                                                                             DIVISION=DECODE(NOUPDATE_DIVISION,0, p_xfr_CUSTOMER.DIVISION ,DIVISION),
                                                                                             NOTE=DECODE(NOUPDATE_NOTE,0, p_xfr_CUSTOMER.NOTE ,NOTE),
                                                                                             DESC_TEXT=DECODE(NOUPDATE_DESC_TEXT,0, p_xfr_CUSTOMER.DESC_TEXT ,DESC_TEXT),
                                                                                             CUSTOMER_STATUS=DECODE(NOUPDATE_CUSTOMER_STATUS,0, p_xfr_CUSTOMER.CUSTOMER_STATUS ,CUSTOMER_STATUS),
                                                                                             DELETED_FLAG=           DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_CUSTOMER.DELETED_FLAG ,DELETED_FLAG),
                                                                                             USER_NUM01=                     DECODE(NOUPDATE_USER_NUM01,  0,p_xfr_CUSTOMER.USER_NUM01,USER_NUM01),
                                                                                             USER_NUM02=                     DECODE(NOUPDATE_USER_NUM02,  0,p_xfr_CUSTOMER.USER_NUM02,USER_NUM02),
                                                                                             USER_NUM03=                     DECODE(NOUPDATE_USER_NUM03,  0,p_xfr_CUSTOMER.USER_NUM03,USER_NUM03),
                                                                                             USER_NUM04=                     DECODE(NOUPDATE_USER_NUM04,  0,p_xfr_CUSTOMER.USER_NUM04,USER_NUM04),
                                                                                             USER_STR01=                     DECODE(NOUPDATE_USER_STR01,  0,p_xfr_CUSTOMER.USER_STR01,USER_STR01),
                                                                                             USER_STR02=                     DECODE(NOUPDATE_USER_STR02,  0,p_xfr_CUSTOMER.USER_STR02,USER_STR02),
                                                                                             USER_STR03=                     DECODE(NOUPDATE_USER_STR03,  0,p_xfr_CUSTOMER.USER_STR03,USER_STR03),
                                                                                             USER_STR04=                     DECODE(NOUPDATE_USER_STR04,  0,p_xfr_CUSTOMER.USER_STR04,USER_STR04),
                                                                                             CHECKOUT_USER=                       DECODE(NOUPDATE_CHECKOUT_USER,    0,p_xfr_CUSTOMER.CHECKOUT_USER,CHECKOUT_USER),
                                                                                             WAREHOUSE_ID=                       DECODE(NOUPDATE_WAREHOUSE_ID,    0,p_xfr_CUSTOMER.WAREHOUSE_ID,WAREHOUSE_ID),
                                                                                             /*PRICE_LIST_ID=                       DECODE(NOUPDATE_PRICE_LIST_ID,    0,p_xfr_CUSTOMER.PRICE_LIST_ID,PRICE_LIST_ID),*/
                                                                                             CREATION_DATE=                        DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                                                                             LAST_UPDATE_DATE=                       DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                                                                             CREATED_BY=                     DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                                                                             LAST_UPDATED_BY=            DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                                                                             SECURITY_MASK=          DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK)
                                                                                             WHERE   CUSTOMER_ID=p_xfr_CUSTOMER.CUSTOMER_ID;
                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_customer
                                                          SET REC_STATUS='OK'
                                                        WHERE CUSTOMER_ID=p_xfr_customer.CUSTOMER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_customer
                                                          SET REC_STATUS='ERR'
                                                        WHERE CUSTOMER_ID=p_xfr_customer.CUSTOMER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_CUSTOMER',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_CUSTOMER;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_CUSTOMER',11276);
             END;
  END XFR_CUSTOMER;
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE XFR_ADDRESS (    inRUN_ID        IN      PLS_INTEGER,
                             COMMIT_SIZE     IN      PLS_INTEGER,
                             MAX_ERR         IN      PLS_INTEGER,
                             INSERTS         OUT NOCOPY     PLS_INTEGER,
                             UPDATES         OUT NOCOPY     PLS_INTEGER,
                             FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                         ) IS
  BEGIN
             DECLARE CURSOR c_xfr_ADDRESS IS
                       SELECT * FROM CZ_IMP_ADDRESS
                     WHERE CZ_IMP_ADDRESS.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
                     x_xfr_ADDRESS_f         BOOLEAN:=FALSE;
                     x_error                 BOOLEAN:=FALSE;
                     p_xfr_ADDRESS           c_xfr_ADDRESS%ROWTYPE;
                     -- Internal vars --
                     nCommitCount            PLS_INTEGER:=0;                 -- COMMIT buffer index --
                     nInsertCount            PLS_INTEGER:=0;                 -- Inserts --
                     nUpdateCount            PLS_INTEGER:=0;                 -- Updates      --
                     nFailed                 PLS_INTEGER:=0;                 -- Failed records --

                     NOUPDATE_CUSTOMER_ID     NUMBER;
                     NOUPDATE_COUNTRY        NUMBER;
                     NOUPDATE_ADDR_LINE1     NUMBER;
                     NOUPDATE_ADDR_LINE2     NUMBER;
                     NOUPDATE_CITY           NUMBER;
                     NOUPDATE_POSTAL_CODE    NUMBER;
                     NOUPDATE_STATE          NUMBER;
                     NOUPDATE_PROVINCE       NUMBER;
                     NOUPDATE_COUNTY         NUMBER;
                     NOUPDATE_BILL_TO_FLAG   NUMBER;
                     NOUPDATE_SHIP_TO_FLAG   NUMBER;
                     NOUPDATE_ORIG_SYS_REF   NUMBER;
                     NOUPDATE_CREATION_DATE        NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE       NUMBER;
                     NOUPDATE_CREATED_BY     NUMBER;
                     NOUPDATE_LAST_UPDATED_BY    NUMBER;
                     NOUPDATE_DELETED_FLAG   NUMBER;

             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_CUSTOMER_ID     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','CUSTOMER_ID',inXFR_GROUP);
                     NOUPDATE_COUNTRY        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','COUNTRY',inXFR_GROUP);
                     NOUPDATE_ADDR_LINE1     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','ADDR_LINE1',inXFR_GROUP);
                     NOUPDATE_ADDR_LINE2     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','ADDR_LINE2',inXFR_GROUP);
                     NOUPDATE_CITY           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','CITY',inXFR_GROUP);
                     NOUPDATE_POSTAL_CODE    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','POSTAL_CODE',inXFR_GROUP);
                     NOUPDATE_STATE          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','STATE',inXFR_GROUP);
                     NOUPDATE_PROVINCE       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','PROVINCE',inXFR_GROUP);
                     NOUPDATE_COUNTY         := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','COUNTY',inXFR_GROUP);
                     NOUPDATE_BILL_TO_FLAG   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','BILL_TO_FLAG',inXFR_GROUP);
                     NOUPDATE_SHIP_TO_FLAG   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','SHIP_TO_FLAG',inXFR_GROUP);
                     NOUPDATE_ORIG_SYS_REF   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','ORIG_SYS_REF',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_DELETED_FLAG   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESSES','DELETED_FLAG',inXFR_GROUP);

                     OPEN c_xfr_ADDRESS;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_ADDRESS  INTO       p_xfr_ADDRESS;
                             x_xfr_ADDRESS_f:=c_xfr_ADDRESS%FOUND;
                             EXIT WHEN (NOT x_xfr_ADDRESS_f Or nFailed >= Max_Err);

                             IF (p_xfr_ADDRESS.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_ADDRESSES (ADDRESS_ID,CUSTOMER_ID, COUNTRY,ADDR_LINE1,
                                                    ADDR_LINE2,CITY,POSTAL_CODE,STATE,PROVINCE,
                                                    COUNTY,BILL_TO_FLAG,SHIP_TO_FLAG,ORIG_SYS_REF,
                                                    CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,DELETED_FLAG
                                                    ) VALUES(
                                                    p_xfr_ADDRESS.ADDRESS_ID,p_xfr_ADDRESS.CUSTOMER_ID,
                                                    p_xfr_ADDRESS.COUNTRY,
                                                    p_xfr_ADDRESS.ADDR_LINE1,p_xfr_ADDRESS.ADDR_LINE2,
                                                    p_xfr_ADDRESS.CITY,p_xfr_ADDRESS.POSTAL_CODE,p_xfr_ADDRESS.STATE,
                                                    p_xfr_ADDRESS.PROVINCE,p_xfr_ADDRESS.COUNTY,
                                                    p_xfr_ADDRESS.BILL_TO_FLAG,p_xfr_ADDRESS.SHIP_TO_FLAG,
                                                    p_xfr_ADDRESS.ORIG_SYS_REF,
                                                    SYSDATE,SYSDATE,1,1,p_xfr_ADDRESS.DELETED_FLAG
                                                    );
                                             nInsertCount:=nInsertCount+1;
                                             BEGIN
                                               UPDATE CZ_IMP_address
                                                  SET REC_STATUS='OK'
                                                WHERE ADDRESS_ID=p_xfr_address.ADDRESS_ID AND RUN_ID=inRUN_ID;
                                             END;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_address
                                                          SET REC_STATUS='ERR'
                                                        WHERE ADDRESS_ID=p_xfr_address.ADDRESS_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_ADDRESS',11276);
                                     END ;
                             ELSIF (p_xfr_ADDRESS.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_ADDRESSES SET
                                               CUSTOMER_ID=DECODE(NOUPDATE_CUSTOMER_ID,0, p_xfr_ADDRESS.CUSTOMER_ID ,CUSTOMER_ID),
                                               COUNTRY=DECODE(NOUPDATE_COUNTRY,0, p_xfr_ADDRESS.COUNTRY ,COUNTRY),
                                               ADDR_LINE1=DECODE(NOUPDATE_ADDR_LINE1,0, p_xfr_ADDRESS.ADDR_LINE1 ,ADDR_LINE1),
                                               ADDR_LINE2=DECODE(NOUPDATE_ADDR_LINE2,0, p_xfr_ADDRESS.ADDR_LINE2,ADDR_LINE2),
                                               CITY=DECODE(NOUPDATE_CITY,0, p_xfr_ADDRESS.CITY ,CITY),
                                               POSTAL_CODE=DECODE(NOUPDATE_POSTAL_CODE,0, p_xfr_ADDRESS.POSTAL_CODE ,POSTAL_CODE),
                                               STATE=DECODE(NOUPDATE_STATE,0, p_xfr_ADDRESS.STATE,STATE),
                                               PROVINCE=DECODE(NOUPDATE_PROVINCE,0, p_xfr_ADDRESS.PROVINCE ,PROVINCE),
                                               COUNTY=DECODE(NOUPDATE_COUNTY,0, p_xfr_ADDRESS.COUNTY,COUNTY),
                                               BILL_TO_FLAG=DECODE(NOUPDATE_BILL_TO_FLAG,0, p_xfr_ADDRESS.BILL_TO_FLAG,BILL_TO_FLAG),
                                               SHIP_TO_FLAG=DECODE(NOUPDATE_SHIP_TO_FLAG,0, p_xfr_ADDRESS.SHIP_TO_FLAG,SHIP_TO_FLAG),
                                               ORIG_SYS_REF=DECODE(NOUPDATE_ORIG_SYS_REF,0, p_xfr_ADDRESS.ORIG_SYS_REF,ORIG_SYS_REF),
                                               CREATION_DATE=DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                               LAST_UPDATE_DATE=DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                               CREATED_BY=DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                               LAST_UPDATED_BY=DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                               DELETED_FLAG=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_ADDRESS.DELETED_FLAG,DELETED_FLAG)
                                             WHERE   ADDRESS_ID=p_xfr_ADDRESS.ADDRESS_ID;
                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_address
                                                          SET REC_STATUS='OK'
                                                        WHERE ADDRESS_ID=p_xfr_address.ADDRESS_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_address
                                                          SET REC_STATUS='ERR'
                                                        WHERE ADDRESS_ID=p_xfr_address.ADDRESS_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_ADDRESS',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_ADDRESS;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_ADDRESS',11276);
             END;
  END XFR_ADDRESS;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE XFR_ADDRESS_USES(inRUN_ID    IN  PLS_INTEGER,
                           COMMIT_SIZE IN  PLS_INTEGER,
                           MAX_ERR     IN  PLS_INTEGER,
                           INSERTS     OUT NOCOPY PLS_INTEGER,
                           UPDATES     OUT NOCOPY PLS_INTEGER,
                           FAILED      OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                          ) IS
BEGIN
  DECLARE
    CURSOR c_xfr_address_uses IS
    SELECT * FROM CZ_IMP_ADDRESS_USE
    WHERE Run_ID=inRUN_ID AND rec_status='PASS';

    x_xfr_address_uses_f    BOOLEAN:=FALSE;
    x_error                 BOOLEAN:=FALSE;
    p_xfr_address_uses      c_xfr_address_uses%ROWTYPE;

    -- Internal vars --
    nCommitCount            PLS_INTEGER:=0; -- COMMIT buffer index --
    nInsertCount            PLS_INTEGER:=0; -- Inserts --
    nUpdateCount            PLS_INTEGER:=0; -- Updates --
    nFailed                 PLS_INTEGER:=0; -- Failed records --

    NOUPDATE_SITE_USE_CODE  NUMBER;
    NOUPDATE_ADDRESS_ID     NUMBER;
    NOUPDATE_WAREHOUSE_ID   NUMBER;
    NOUPDATE_ORIG_SYS_REF   NUMBER;
    NOUPDATE_CREATION_DATE        NUMBER;
    NOUPDATE_LAST_UPDATE_DATE       NUMBER;
    NOUPDATE_CREATED_BY     NUMBER;
    NOUPDATE_LAST_UPDATED_BY    NUMBER;
    NOUPDATE_DELETED_FLAG   NUMBER;

 -- Make sure that the DataSet exists
    BEGIN
 -- Get the Update Flags for each column
      NOUPDATE_SITE_USE_CODE := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','SITE_USER_CODE',inXFR_GROUP);
      NOUPDATE_ADDRESS_ID    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','ADDRESS_ID',inXFR_GROUP);
      NOUPDATE_WAREHOUSE_ID  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','WAREHOUSE_ID',inXFR_GROUP);
      NOUPDATE_ORIG_SYS_REF  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','ORIG_SYS_REF',inXFR_GROUP);
      NOUPDATE_CREATION_DATE       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','CREATION_DATE',inXFR_GROUP);
      NOUPDATE_LAST_UPDATE_DATE      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','LAST_UPDATE_DATE',inXFR_GROUP);
      NOUPDATE_CREATED_BY    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','CREATED_BY',inXFR_GROUP);
      NOUPDATE_LAST_UPDATED_BY   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','LAST_UPDATED_BY',inXFR_GROUP);
      NOUPDATE_DELETED_FLAG  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ADDRESS_USES','DELETED_FLAG',inXFR_GROUP);

      OPEN c_xfr_address_uses;
      LOOP
        IF(nCommitCount>= COMMIT_SIZE) THEN
          BEGIN
            COMMIT;
            nCommitCount:=0;
          END;
        ELSE
          nCOmmitCount:=nCommitCount+1;
        END IF;

        FETCH c_xfr_address_uses INTO p_xfr_address_uses;
        x_xfr_address_uses_f:=c_xfr_address_uses%FOUND;
        EXIT WHEN (NOT x_xfr_address_uses_f OR nFailed >= Max_Err);

        IF(p_xfr_address_uses.disposition = 'I') THEN
          BEGIN
            INSERT INTO cz_address_uses (address_use_id, address_id, site_user_code,
              warehouse_id, orig_sys_ref, CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY,
              deleted_flag)
            VALUES
              (p_xfr_address_uses.address_use_id,
               p_xfr_address_uses.address_id,
               p_xfr_address_uses.site_use_code,
               p_xfr_address_uses.warehouse_id,
               p_xfr_address_uses.orig_sys_ref,
               sysdate, sysdate, 1, 1,
               p_xfr_address_uses.deleted_flag);
             nInsertCount:=nInsertCount+1;
             BEGIN
               UPDATE CZ_IMP_address_use
                  SET REC_STATUS='OK'
                WHERE ADDRESS_USE_ID=p_xfr_address_uses.ADDRESS_USE_ID AND RUN_ID=inRUN_ID;
             END;
             EXCEPTION
               WHEN OTHERS THEN
                  nFailed:=nFailed +1;
                  BEGIN
                    UPDATE CZ_IMP_address_use
                       SET REC_STATUS='ERR'
                     WHERE ADDRESS_USE_ID=p_xfr_address_uses.ADDRESS_USE_ID AND RUN_ID=inRUN_ID;
                  END;
                  x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_ADDRESS_USES',11276);
          END ;
        ELSIF(p_xfr_address_uses.disposition = 'M') THEN
          BEGIN
           UPDATE cz_address_uses SET
             address_id=DECODE(NOUPDATE_ADDRESS_ID,0,p_xfr_address_uses.address_id ,address_id),
             site_user_code=DECODE(NOUPDATE_SITE_USE_CODE,0,p_xfr_address_uses.site_use_code,site_user_code),
             warehouse_id=DECODE(NOUPDATE_WAREHOUSE_ID,0,p_xfr_address_uses.warehouse_id,warehouse_id),
             orig_sys_ref=DECODE(NOUPDATE_ORIG_SYS_REF,0,p_xfr_address_uses.orig_sys_ref,orig_sys_ref),
             CREATION_DATE=DECODE(NOUPDATE_CREATION_DATE,0,sysdate,CREATION_DATE),
             LAST_UPDATE_DATE=DECODE(NOUPDATE_LAST_UPDATE_DATE,0,sysdate,LAST_UPDATE_DATE),
             CREATED_BY=DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
             LAST_UPDATED_BY=DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
             deleted_flag=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_address_uses.deleted_flag,deleted_flag)
           WHERE address_use_id=p_xfr_address_uses.address_use_id;

           IF(SQL%NOTFOUND) THEN
             nFailed:=nFailed+1;
           ELSE
             nUpdateCount:=nUpdateCount+1;
             BEGIN
               UPDATE CZ_IMP_address_use
                  SET REC_STATUS='OK'
                WHERE ADDRESS_USE_ID=p_xfr_address_uses.ADDRESS_USE_ID AND RUN_ID=inRUN_ID;
             END;
           END IF;
           EXCEPTION
             WHEN OTHERS THEN
                nFailed:=nFailed +1;
                BEGIN
                  UPDATE CZ_IMP_address_use
                     SET REC_STATUS='ERR'
                   WHERE ADDRESS_USE_ID=p_xfr_address_uses.ADDRESS_USE_ID AND RUN_ID=inRUN_ID;
                END;
                x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_ADDRESS_USES',11276);
          END ;
        END IF;
      END LOOP;

      CLOSE c_xfr_address_uses;
      COMMIT;
      INSERTS:=nInsertCount;
      UPDATES:=nUpdateCount;
      FAILED:=nFailed;
      EXCEPTION
        WHEN OTHERS THEN
           x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_ADDRESS_USES',11276);
    END;
END XFR_ADDRESS_USES;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE XFR_CUSTOMER_END_USER (    inRUN_ID         IN      PLS_INTEGER,
                                     COMMIT_SIZE     IN      PLS_INTEGER,
                                     MAX_ERR         IN      PLS_INTEGER,
                                     INSERTS         OUT NOCOPY     PLS_INTEGER,
                                     UPDATES         OUT NOCOPY     PLS_INTEGER,
                                     FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                     ) IS
  BEGIN
             DECLARE CURSOR c_xfr_CUSTOMER_END_USER IS
                       SELECT * FROM CZ_IMP_CUSTOMER_END_USER
                     WHERE CZ_IMP_CUSTOMER_END_USER.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
                     x_xfr_CUSTOMER_END_USER_f                                BOOLEAN:=FALSE;
                     x_error                                                 BOOLEAN:=FALSE;
                     p_xfr_CUSTOMER_END_USER   c_xfr_CUSTOMER_END_USER%ROWTYPE;
                     -- Internal vars --
                     nCommitCount            PLS_INTEGER:=0;                 -- COMMIT buffer index --
                     nInsertCount            PLS_INTEGER:=0;                 -- Inserts --
                     nUpdateCount            PLS_INTEGER:=0;                 -- Updates      --
                     nFailed                 PLS_INTEGER:=0;                 -- Failed records --
                     NOUPDATE_DELETED_FLAG            NUMBER;
                     NOUPDATE_CREATION_DATE                 NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE                NUMBER;
                     NOUPDATE_CREATED_BY              NUMBER;
                     NOUPDATE_LAST_UPDATED_BY             NUMBER;
                     NOUPDATE_SECURITY_MASK           NUMBER;
                     NOUPDATE_CHECKOUT_USER           NUMBER;
             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','DELETED_FLAG',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','SECURITY_MASK',inXFR_GROUP);
                     NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_CUSTOMER_END_USERS','CHECKOUT_USER',inXFR_GROUP);

                     OPEN c_xfr_CUSTOMER_END_USER;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_CUSTOMER_END_USER  INTO       p_xfr_CUSTOMER_END_USER;
                             x_xfr_CUSTOMER_END_USER_f:=c_xfr_CUSTOMER_END_USER%FOUND;
                             EXIT WHEN (NOT x_xfr_CUSTOMER_END_USER_f Or nFailed >= Max_Err);
                             IF (p_xfr_CUSTOMER_END_USER.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_CUSTOMER_END_USERS (
                                                     CUSTOMER_ID,END_USER_ID, DELETED_FLAG,
                                                     CREATION_DATE,
                                                     LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,SECURITY_MASK,CHECKOUT_USER) VALUES
                                                    (p_xfr_CUSTOMER_END_USER.CUSTOMER_ID,p_xfr_CUSTOMER_END_USER.END_USER_ID,
                                                     p_xfr_CUSTOMER_END_USER.DELETED_FLAG ,
                                                     SYSDATE,SYSDATE, 1, 1, NULL,p_xfr_CUSTOMER_END_USER.CHECKOUT_USER);
                                             nInsertCount:=nInsertCount+1;
                                             BEGIN
                                               UPDATE CZ_IMP_customer_end_user
                                                  SET REC_STATUS='OK'
                                                WHERE CUSTOMER_ID=p_xfr_customer_end_user.CUSTOMER_ID
                                                  AND END_USER_ID=p_xfr_CUSTOMER_END_USER.END_USER_ID AND RUN_ID=inRUN_ID;
                                             END;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_customer_end_user
                                                          SET REC_STATUS='ERR'
                                                        WHERE CUSTOMER_ID=p_xfr_customer_end_user.CUSTOMER_ID
                                                          AND END_USER_ID=p_xfr_CUSTOMER_END_USER.END_USER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.XFR_CUSTOMER_END_USER',11276);
                                     END ;
                             ELSIF (p_xfr_CUSTOMER_END_USER.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_CUSTOMER_END_USERS SET
                                                                                             DELETED_FLAG=           DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_CUSTOMER_END_USER.DELETED_FLAG ,DELETED_FLAG),
                                                                                             CREATION_DATE=                        DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                                                                             LAST_UPDATE_DATE=                       DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                                                                             CREATED_BY=                     DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                                                                             LAST_UPDATED_BY=            DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                                                                             SECURITY_MASK=          DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
                                                                                             CHECKOUT_USER=          DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER)
                                                                                             WHERE   CUSTOMER_ID=p_xfr_CUSTOMER_END_USER.CUSTOMER_ID AND
                                                                                             END_USER_ID=p_xfr_CUSTOMER_END_USER.END_USER_ID;

                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_customer_end_user
                                                          SET REC_STATUS='OK'
                                                        WHERE CUSTOMER_ID=p_xfr_customer_end_user.CUSTOMER_ID
                                                          AND END_USER_ID=p_xfr_CUSTOMER_END_USER.END_USER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_customer_end_user
                                                          SET REC_STATUS='ERR'
                                                        WHERE CUSTOMER_ID=p_xfr_customer_end_user.CUSTOMER_ID
                                                          AND END_USER_ID=p_xfr_CUSTOMER_END_USER.END_USER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.XFR_CUSTOMER_END_USER',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_CUSTOMER_END_USER;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.XFR_CUSTOMER_END_USER',11276);
             END;
  END XFR_CUSTOMER_END_USER;
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE XFR_END_USER (   inRUN_ID                IN      PLS_INTEGER,
                                     COMMIT_SIZE     IN      PLS_INTEGER,
                                     MAX_ERR         IN      PLS_INTEGER,
                                     INSERTS         OUT NOCOPY     PLS_INTEGER,
                                     UPDATES         OUT NOCOPY     PLS_INTEGER,
                                     FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                     ) IS
  BEGIN
             DECLARE CURSOR c_xfr_enduser IS
                       SELECT *
                     FROM CZ_IMP_END_USER
                     WHERE CZ_IMP_END_USER.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
                     x_xfr_enduser_f                                         BOOLEAN:=FALSE;
                     x_error                                                 BOOLEAN:=FALSE;
                     p_xfr_enduser   c_xfr_enduser%ROWTYPE;
                     -- Internal vars --
                     nCommitCount            PLS_INTEGER:=0;                 -- COMMIT buffer index --
                     nInsertCount            PLS_INTEGER:=0;                 -- Inserts --
                     nUpdateCount            PLS_INTEGER:=0;                 -- Updates      --
                     nFailed                 PLS_INTEGER:=0;                 -- Failed records --
                     NOUPDATE_TITLE                     NUMBER;
                     NOUPDATE_LOGIN_NAME                NUMBER;
                     NOUPDATE_LASTNAME                  NUMBER;
                     NOUPDATE_FIRSTNAME                 NUMBER;
                     NOUPDATE_MI                        NUMBER;
                     NOUPDATE_ALLOWABLE_DISCOUNT        NUMBER;
                     NOUPDATE_DESC_TEXT                 NUMBER;
                     NOUPDATE_ADDR_LINE1                NUMBER;
                     NOUPDATE_ADDR_LINE2                NUMBER;
                     NOUPDATE_CITY                      NUMBER;
                     NOUPDATE_STATE                     NUMBER;
                     NOUPDATE_PROVINCE                  NUMBER;
                     NOUPDATE_COUNTY                    NUMBER;
                     NOUPDATE_ZIP                       NUMBER;
                     NOUPDATE_COUNTRY                   NUMBER;
                     NOUPDATE_PHONE                     NUMBER;
                     NOUPDATE_FAX                       NUMBER;
                     NOUPDATE_PAGER                     NUMBER;
                     NOUPDATE_CELLULAR                  NUMBER;
                     NOUPDATE_EMAIL_ADDR                NUMBER;
                     NOUPDATE_DELETED_FLAG            NUMBER;
                     NOUPDATE_USER_STR01              NUMBER;
                     NOUPDATE_USER_STR02              NUMBER;
                     NOUPDATE_USER_STR03              NUMBER;
                     NOUPDATE_USER_STR04              NUMBER;
                     NOUPDATE_USER_NUM01              NUMBER;
                     NOUPDATE_USER_NUM02              NUMBER;
                     NOUPDATE_USER_NUM03              NUMBER;
                     NOUPDATE_USER_NUM04              NUMBER;
                     NOUPDATE_CREATION_DATE                 NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE                NUMBER;
                     NOUPDATE_CREATED_BY              NUMBER;
                     NOUPDATE_LAST_UPDATED_BY             NUMBER;
                     NOUPDATE_SECURITY_MASK           NUMBER;
                     NOUPDATE_CHECKOUT_USER           NUMBER;
                     NOUPDATE_END_USER_ORG_ID         NUMBER;
                     NOUPDATE_ORIG_SYS_REF            NUMBER;
                     NOUPDATE_NAME                    NUMBER;

             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_TITLE                   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','TITLE',inXFR_GROUP);
                     NOUPDATE_LOGIN_NAME              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','LOGIN_NAME',inXFR_GROUP);
                     NOUPDATE_LASTNAME                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','LASTNAME',inXFR_GROUP);
                     NOUPDATE_FIRSTNAME               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','FIRSTNAME',inXFR_GROUP);
                     NOUPDATE_MI                      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','MI',inXFR_GROUP);
                     NOUPDATE_ALLOWABLE_DISCOUNT      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','ALLOWABLE_DISCOUNT',inXFR_GROUP);
                     NOUPDATE_DESC_TEXT               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','DESC_TEXT',inXFR_GROUP);
                     NOUPDATE_ADDR_LINE1              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','ADDR_LINE1',inXFR_GROUP);
                     NOUPDATE_ADDR_LINE2              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','ADDR_LINE2',inXFR_GROUP);
                     NOUPDATE_CITY                    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','CITY',inXFR_GROUP);
                     NOUPDATE_STATE                   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','STATE',inXFR_GROUP);
                     NOUPDATE_PROVINCE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','PROVINCE',inXFR_GROUP);
                     NOUPDATE_COUNTY                  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','COUNTY',inXFR_GROUP);
                     NOUPDATE_ZIP                     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','ZIP',inXFR_GROUP);
                     NOUPDATE_COUNTRY                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','COUNTRY',inXFR_GROUP);
                     NOUPDATE_PHONE                   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','PHONE',inXFR_GROUP);
                     NOUPDATE_FAX                     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','FAX',inXFR_GROUP);
                     NOUPDATE_PAGER                   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','PAGER',inXFR_GROUP);
                     NOUPDATE_CELLULAR                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','CELLULAR',inXFR_GROUP);
                     NOUPDATE_EMAIL_ADDR              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','EMAIL_ADDR',inXFR_GROUP);
                     NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','DELETED_FLAG',inXFR_GROUP);
                     NOUPDATE_USER_STR01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','USER_STR01',inXFR_GROUP);
                     NOUPDATE_USER_STR02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','USER_STR02',inXFR_GROUP);
                     NOUPDATE_USER_STR03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','USER_STR03',inXFR_GROUP);
                     NOUPDATE_USER_NUM01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','USER_NUM01',inXFR_GROUP);
                     NOUPDATE_USER_NUM02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','USER_NUM02',inXFR_GROUP);
                     NOUPDATE_USER_NUM03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','USER_NUM03',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','SECURITY_MASK',inXFR_GROUP);
                     NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','CHECKOUT_USER',inXFR_GROUP);
                     NOUPDATE_END_USER_ORG_ID         := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','END_USER_ORG_ID',inXFR_GROUP);
                     NOUPDATE_ORIG_SYS_REF            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','ORIG_SYS_REF',inXFR_GROUP);
                     NOUPDATE_NAME                    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USERS','NAME',inXFR_GROUP);

                     OPEN c_xfr_enduser;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_enduser  INTO       p_xfr_enduser;
                             x_xfr_enduser_f:=c_xfr_enduser%FOUND;
                             EXIT WHEN (NOT x_xfr_enduser_f Or nFailed >= Max_Err);
                             IF (p_xfr_enduser.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_END_USERS (
                                              END_USER_ID,TITLE,LOGIN_NAME,LASTNAME,FIRSTNAME,MI,
                                              ALLOWABLE_DISCOUNT,DESC_TEXT,ADDR_LINE1,ADDR_LINE2,
                                              CITY,STATE,PROVINCE,COUNTY,ZIP,COUNTRY,PHONE,FAX,PAGER,
                                              CELLULAR,EMAIL_ADDR,
                                              DELETED_FLAG,
                                              USER_STR01,USER_STR02,USER_STR03,USER_STR04,
                                              USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
                                              CREATION_DATE,LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY,
                                              SECURITY_MASK,CHECKOUT_USER,
                                              END_USER_ORG_ID,ORIG_SYS_REF,NAME) VALUES
                                              (p_xfr_enduser.END_USER_ID,p_xfr_enduser.TITLE,
                                               p_xfr_enduser.LOGIN_NAME,p_xfr_enduser.LASTNAME,
                                               p_xfr_enduser.FIRSTNAME,p_xfr_enduser.MI,
                                               p_xfr_enduser.ALLOWABLE_DISCOUNT,p_xfr_enduser.DESC_TEXT,
                                               p_xfr_enduser.ADDR_LINE1,p_xfr_enduser.ADDR_LINE2,
                                               p_xfr_enduser.CITY,p_xfr_enduser.STATE,p_xfr_enduser.PROVINCE,
                                               p_xfr_enduser.COUNTY,p_xfr_enduser.ZIP,p_xfr_enduser.COUNTRY,
                                               p_xfr_enduser.PHONE,p_xfr_enduser.FAX,p_xfr_enduser.PAGER,
                                               p_xfr_enduser.CELLULAR, p_xfr_enduser.EMAIL_ADDR,
                                               p_xfr_enduser.DELETED_FLAG,
                                               p_xfr_enduser.USER_STR01,p_xfr_enduser.USER_STR02,
                                               p_xfr_enduser.USER_STR03,p_xfr_enduser.USER_STR04,
                                               p_xfr_enduser.USER_NUM01,p_xfr_enduser.USER_NUM02,
                                               p_xfr_enduser.USER_NUM03,p_xfr_enduser.USER_NUM04,
                                               SYSDATE,SYSDATE, 1, 1, NULL,p_xfr_enduser.CHECKOUT_USER,
                                               p_xfr_enduser.END_USER_ORG_ID,
                                               p_xfr_enduser.ORIG_SYS_REF,
                                               p_xfr_enduser.NAME);
                                               nInsertCount:=nInsertCount+1;
                                               BEGIN
                                                 UPDATE CZ_IMP_end_user
                                                    SET REC_STATUS='OK'
                                                  WHERE END_USER_ID=p_xfr_enduser.END_USER_ID AND RUN_ID=inRUN_ID;
                                               END;

                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_end_user
                                                          SET REC_STATUS='ERR'
                                                        WHERE END_USER_ID=p_xfr_enduser.END_USER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_END_USER',11276);
                                     END ;
                             ELSIF (p_xfr_enduser.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_END_USERS SET
                                                                                             TITLE=DECODE(NOUPDATE_TITLE,0,p_xfr_enduser.TITLE,TITLE),
                                                                                             LOGIN_NAME=DECODE(NOUPDATE_LOGIN_NAME,0,p_xfr_enduser.LOGIN_NAME,LOGIN_NAME),
                                                                                             LASTNAME=DECODE(NOUPDATE_LASTNAME,0,p_xfr_enduser.LASTNAME,LASTNAME),
                                                                                             FIRSTNAME=DECODE(NOUPDATE_FIRSTNAME,0,p_xfr_enduser.FIRSTNAME,FIRSTNAME),
                                                                                             MI=DECODE(NOUPDATE_MI,0,p_xfr_enduser.MI,MI),
                                                                                             ALLOWABLE_DISCOUNT=DECODE(NOUPDATE_ALLOWABLE_DISCOUNT,0,p_xfr_enduser.ALLOWABLE_DISCOUNT,ALLOWABLE_DISCOUNT),
                                                                                             DESC_TEXT=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_enduser.DESC_TEXT,DESC_TEXT),
                                                                                             ADDR_LINE1=DECODE(NOUPDATE_ADDR_LINE1,0,p_xfr_enduser.ADDR_LINE1,ADDR_LINE1),
                                                                                             ADDR_LINE2=DECODE(NOUPDATE_ADDR_LINE2,0,p_xfr_enduser.ADDR_LINE2,ADDR_LINE2),
                                                                                             CITY =DECODE(NOUPDATE_CITY,0,p_xfr_enduser.CITY,CITY),
                                                                                             STATE=DECODE(NOUPDATE_STATE,0,p_xfr_enduser.STATE,STATE),
                                                                                             PROVINCE=DECODE(NOUPDATE_PROVINCE,0,p_xfr_enduser.PROVINCE,PROVINCE),
                                                                                             COUNTY =DECODE(NOUPDATE_COUNTY,0,p_xfr_enduser.COUNTY,COUNTY),
                                                                                             ZIP=DECODE(NOUPDATE_ZIP,0,p_xfr_enduser.ZIP,ZIP),
                                                                                             COUNTRY=DECODE(NOUPDATE_COUNTRY,0,p_xfr_enduser.COUNTRY,COUNTRY),
                                                                                             PHONE=DECODE(NOUPDATE_PHONE,0,p_xfr_enduser.PHONE,PHONE),
                                                                                             FAX=DECODE(NOUPDATE_FAX,0,p_xfr_enduser.FAX,FAX),
                                                                                             PAGER  =DECODE(NOUPDATE_PAGER,0,p_xfr_enduser.PAGER,PAGER),
                                                                                             CELLULAR =DECODE(NOUPDATE_CELLULAR,0,p_xfr_enduser.CELLULAR,CELLULAR),
                                                                                             EMAIL_ADDR =DECODE(NOUPDATE_EMAIL_ADDR,0,p_xfr_enduser.EMAIL_ADDR,EMAIL_ADDR),
                                                                                             DELETED_FLAG=           DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_enduser.DELETED_FLAG ,DELETED_FLAG),
                                                                                             USER_NUM01=                     DECODE(NOUPDATE_USER_NUM01,  0,p_xfr_enduser.USER_NUM01,USER_NUM01),
                                                                                             USER_NUM02=                     DECODE(NOUPDATE_USER_NUM02,  0,p_xfr_enduser.USER_NUM02,USER_NUM02),
                                                                                             USER_NUM03=                     DECODE(NOUPDATE_USER_NUM03,  0,p_xfr_enduser.USER_NUM03,USER_NUM03),
                                                                                             USER_NUM04=                     DECODE(NOUPDATE_USER_NUM04,  0,p_xfr_enduser.USER_NUM04,USER_NUM04),
                                                                                             USER_STR01=                     DECODE(NOUPDATE_USER_STR01,  0,p_xfr_enduser.USER_STR01,USER_STR01),
                                                                                             USER_STR02=                     DECODE(NOUPDATE_USER_STR02,  0,p_xfr_enduser.USER_STR02,USER_STR02),
                                                                                             USER_STR03=                     DECODE(NOUPDATE_USER_STR03,  0,p_xfr_enduser.USER_STR03,USER_STR03),
                                                                                             USER_STR04=                     DECODE(NOUPDATE_USER_STR04,  0,p_xfr_enduser.USER_STR04,USER_STR04),
                                                                                             CREATION_DATE=                        DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                                                                             LAST_UPDATE_DATE=                       DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                                                                             CREATED_BY=                     DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                                                                             LAST_UPDATED_BY=            DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                                                                             SECURITY_MASK=          DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
                                                                                             CHECKOUT_USER=          DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER),
                                                                                             END_USER_ORG_ID=        DECODE(NOUPDATE_END_USER_ORG_ID,0,p_xfr_enduser.END_USER_ORG_ID,END_USER_ORG_ID),
                                                                                             ORIG_SYS_REF=           DECODE(NOUPDATE_ORIG_SYS_REF,0,p_xfr_enduser.ORIG_SYS_REF,ORIG_SYS_REF),
                                                                                             NAME=                   DECODE(NOUPDATE_NAME,0,p_xfr_enduser.NAME,NAME)
                                                                                             WHERE END_USER_ID=p_xfr_enduser.END_USER_ID;
                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_end_user
                                                          SET REC_STATUS='OK'
                                                        WHERE END_USER_ID=p_xfr_enduser.END_USER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_end_user
                                                          SET REC_STATUS='ERR'
                                                        WHERE END_USER_ID=p_xfr_enduser.END_USER_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_END_USER',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_enduser;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_END_USER',11276);
             END;
  END XFR_END_USER;
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE XFR_END_USER_GROUP (     inRUN_ID        IN      PLS_INTEGER,
                                     COMMIT_SIZE     IN      PLS_INTEGER,
                                     MAX_ERR         IN      PLS_INTEGER,
                                     INSERTS         OUT NOCOPY     PLS_INTEGER,
                                     UPDATES         OUT NOCOPY     PLS_INTEGER,
                                     FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                     ) IS
  BEGIN
             DECLARE CURSOR c_xfr_endusergroup IS
                       SELECT *
                     FROM CZ_IMP_END_USER_GROUP WHERE CZ_IMP_END_USER_GROUP.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
                     x_xfr_endusergroup_f                                            BOOLEAN:=FALSE;
                     x_error                                                 BOOLEAN:=FALSE;
                     p_xfr_endusergroup   c_xfr_endusergroup%ROWTYPE;
                     -- Internal vars --
                     nCommitCount            PLS_INTEGER:=0;                 -- COMMIT buffer index --
                     nInsertCount            PLS_INTEGER:=0;                 -- Inserts --
                     nUpdateCount            PLS_INTEGER:=0;                 -- Updates      --
                     nFailed                 PLS_INTEGER:=0;                 -- Failed records --
                     NOUPDATE_DATE_ADDED_USER         NUMBER;
                     NOUPDATE_USER_ADDEDBY            NUMBER;
                     NOUPDATE_GROUP_PRIORITY          NUMBER;
                     NOUPDATE_DELETED_FLAG            NUMBER;
                     NOUPDATE_CREATION_DATE                 NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE                NUMBER;
                     NOUPDATE_CREATED_BY                NUMBER;
                     NOUPDATE_LAST_UPDATED_BY             NUMBER;
                     NOUPDATE_SECURITY_MASK           NUMBER;
                     NOUPDATE_CHECKOUT_USER           NUMBER;

             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_DATE_ADDED_USER         := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','DATE_ADDED_USER',inXFR_GROUP);
                     NOUPDATE_USER_ADDEDBY            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','USER_ADDEDBY',inXFR_GROUP);
                     NOUPDATE_GROUP_PRIORITY          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','GROUP_PRIORITY',inXFR_GROUP);
                     NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','DELETED_FLAG',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','SECURITY_MASK',inXFR_GROUP);
                     NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_END_USER_GROUPS','CHECKOUT_USER',inXFR_GROUP);


                     OPEN c_xfr_endusergroup;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_endusergroup  INTO  p_xfr_endusergroup;
                             x_xfr_endusergroup_f:=c_xfr_endusergroup%FOUND;
                             EXIT WHEN (NOT x_xfr_endusergroup_f Or nFailed >= Max_Err);
                             IF (p_xfr_endusergroup.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_END_USER_GROUPS (END_USER_ID,
                                                USER_GROUP_ID,
                                                DATE_ADDED_USER,
                                                USER_ADDEDBY,
                                                GROUP_PRIORITY,
                                                DELETED_FLAG,
                                                CREATION_DATE,
                                                LAST_UPDATE_DATE,
                                                CREATED_BY,
                                                LAST_UPDATED_BY,
                                                SECURITY_MASK,
                                                CHECKOUT_USER)
                                             VALUES
                                               (p_xfr_endusergroup.END_USER_ID,
                                                p_xfr_endusergroup.USER_GROUP_ID,
                                                p_xfr_endusergroup.DATE_ADDED_USER,
                                                p_xfr_endusergroup.USER_ADDEDBY,
                                                p_xfr_endusergroup.GROUP_PRIORITY,
                                                p_xfr_endusergroup.DELETED_FLAG,
                                                SYSDATE,
                                                SYSDATE,
                                                1,
                                                1,
                                                NULL,
                                                p_xfr_endusergroup.CHECKOUT_USER);
                                             nInsertCount:=nInsertCount+1;
                                             BEGIN
                                               UPDATE CZ_IMP_end_user_group
                                                  SET REC_STATUS='OK'
                                                WHERE END_USER_ID=p_xfr_endusergroup.END_USER_ID
                                                  AND USER_GROUP_ID=p_xfr_endusergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                             END;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_end_user_group
                                                          SET REC_STATUS='ERR'
                                                        WHERE END_USER_ID=p_xfr_endusergroup.END_USER_ID
                                                          AND USER_GROUP_ID=p_xfr_endusergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_END_USER_GROUP',11276);
                                     END ;
                             ELSIF (p_xfr_endusergroup.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_END_USER_GROUPS SET               DATE_ADDED_USER=DECODE(NOUPDATE_DATE_ADDED_USER,0,p_xfr_endusergroup.DATE_ADDED_USER,DATE_ADDED_USER),
                                                                                             USER_ADDEDBY=DECODE(NOUPDATE_USER_ADDEDBY,0,p_xfr_endusergroup.USER_ADDEDBY,USER_ADDEDBY),
                                                                                             GROUP_PRIORITY=DECODE(NOUPDATE_GROUP_PRIORITY,0,p_xfr_endusergroup.GROUP_PRIORITY,GROUP_PRIORITY),
                                                                                             DELETED_FLAG=           DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_endusergroup.DELETED_FLAG ,DELETED_FLAG),
                                                                                             CREATION_DATE=                        DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                                                                             LAST_UPDATE_DATE=                       DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                                                                             CREATED_BY=                     DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                                                                             LAST_UPDATED_BY=            DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                                                                             SECURITY_MASK=          DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
                                                                                             CHECKOUT_USER=          DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER)
                                                                                             WHERE END_USER_ID=p_xfr_endusergroup.END_USER_ID AND
                                                                                             USER_GROUP_ID=p_xfr_endusergroup.USER_GROUP_ID;
                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_end_user_group
                                                          SET REC_STATUS='OK'
                                                        WHERE END_USER_ID=p_xfr_endusergroup.END_USER_ID
                                                          AND USER_GROUP_ID=p_xfr_endusergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_end_user_group
                                                          SET REC_STATUS='ERR'
                                                        WHERE END_USER_ID=p_xfr_endusergroup.END_USER_ID
                                                          AND USER_GROUP_ID=p_xfr_endusergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_END_USER_GROUP',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_endusergroup;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_END_USER_GROUP',11276);
             END;
  END XFR_END_USER_GROUP;
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE XFR_USER_GROUP ( inRUN_ID                IN      PLS_INTEGER,
                                     COMMIT_SIZE     IN      PLS_INTEGER,
                                     MAX_ERR         IN      PLS_INTEGER,
                                     INSERTS         OUT NOCOPY     PLS_INTEGER,
                                     UPDATES         OUT NOCOPY     PLS_INTEGER,
                                     FAILED          OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                     ) IS
  BEGIN
             DECLARE CURSOR c_xfr_usergroup IS
                       SELECT *
                       FROM CZ_IMP_USER_GROUP
                       WHERE CZ_IMP_USER_GROUP.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
                     x_xfr_usergroup_f                                       BOOLEAN:=FALSE;
                     x_error                                                 BOOLEAN:=FALSE;
                     p_xfr_usergroup   c_xfr_usergroup%ROWTYPE;
                     -- Internal vars --
                     nCommitCount            PLS_INTEGER:=0;                 -- COMMIT buffer index --
                     nInsertCount            PLS_INTEGER:=0;                 -- Inserts --
                     nUpdateCount            PLS_INTEGER:=0;                 -- Updates      --
                     nFailed                 PLS_INTEGER:=0;                 -- Failed records --
                     NOUPDATE_DESC_TEXT               NUMBER;
                     NOUPDATE_GROUP_NAME              NUMBER;
                     NOUPDATE_GROUP_DESC              NUMBER;
                     NOUPDATE_READ_AUTH              NUMBER;
                     NOUPDATE_CREATE_AUTH            NUMBER;
                     NOUPDATE_DELETE_AUTH            NUMBER;
                     NOUPDATE_UPDATE_AUTH            NUMBER;
                     NOUPDATE_USER_GROUP_DISC_LIMIT  NUMBER;
                     NOUPDATE_ALLOW_CONFIG_CHANGES   NUMBER;
                     NOUPDATE_DELETED_FLAG            NUMBER;
                     NOUPDATE_CREATION_DATE                 NUMBER;
                     NOUPDATE_LAST_UPDATE_DATE                NUMBER;
                     NOUPDATE_CREATED_BY                NUMBER;
                     NOUPDATE_LAST_UPDATED_BY             NUMBER;
                     NOUPDATE_SECURITY_MASK           NUMBER;
                     NOUPDATE_CHECKOUT_USER           NUMBER;

             -- Make sure that the DataSet exists
             BEGIN
             -- Get the Update Flags for each column
                     NOUPDATE_DESC_TEXT               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','DESC_TEXT',inXFR_GROUP);
                     NOUPDATE_GROUP_NAME              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','GROUP_NAME',inXFR_GROUP);
                     NOUPDATE_GROUP_DESC              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','GROUP_DESC',inXFR_GROUP);
                     NOUPDATE_READ_AUTH               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','READ_AUTH',inXFR_GROUP);
                     NOUPDATE_CREATE_AUTH             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','CREATE_AUTH',inXFR_GROUP);
                     NOUPDATE_DELETE_AUTH             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','DELETE_AUTH',inXFR_GROUP);
                     NOUPDATE_UPDATE_AUTH             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','UPDATE_AUTH',inXFR_GROUP);
                     NOUPDATE_USER_GROUP_DISC_LIMIT   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','USER_GROUP_DISC_LIMIT',inXFR_GROUP);
                     NOUPDATE_ALLOW_CONFIG_CHANGES    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','ALLOW_CONFIG_CHANGES',inXFR_GROUP);
                     NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','DELETED_FLAG',inXFR_GROUP);
                     NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','CREATION_DATE',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','LAST_UPDATE_DATE',inXFR_GROUP);
                     NOUPDATE_CREATED_BY                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','CREATED_BY',inXFR_GROUP);
                     NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','LAST_UPDATED_BY',inXFR_GROUP);
                     NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','SECURITY_MASK',inXFR_GROUP);
                     NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_USER_GROUPS','CHECKOUT_USER',inXFR_GROUP);

                     OPEN c_xfr_usergroup;
                     LOOP
                             IF (nCommitCount>= COMMIT_SIZE) THEN
                                     BEGIN
                                             COMMIT;
                                             nCommitCount:=0;
                                     END;
                             ELSE
                                     nCOmmitCount:=nCommitCount+1;
                             END IF;
                             FETCH c_xfr_usergroup  INTO     p_xfr_usergroup;
                             x_xfr_usergroup_f:=c_xfr_usergroup%FOUND;
                             EXIT WHEN (NOT x_xfr_usergroup_f Or nFailed >= Max_Err);
                             IF (p_xfr_usergroup.DISPOSITION = 'I') THEN
                                     BEGIN
                                             INSERT INTO CZ_USER_GROUPS (
                                              USER_GROUP_ID,/*DESC_TEXT,*/
                                              GROUP_NAME,GROUP_DESC,READ_AUTH,CREATE_AUTH,DELETE_AUTH,
                                              UPDATE_AUTH,USER_GROUP_DISC_LIMIT,ALLOW_CONFIG_CHANGES,
                                              DELETED_FLAG,CREATION_DATE,LAST_UPDATE_DATE,
                                              CREATED_BY,LAST_UPDATED_BY,SECURITY_MASK,CHECKOUT_USER) VALUES
                                                                     (
                                              p_xfr_usergroup.USER_GROUP_ID,/*p_xfr_usergroup.DESC_TEXT,*/
                                              p_xfr_usergroup.GROUP_NAME,p_xfr_usergroup.GROUP_DESC,
                                              p_xfr_usergroup.READ_AUTH,p_xfr_usergroup.CREATE_AUTH,
                                              p_xfr_usergroup.DELETE_AUTH,p_xfr_usergroup.UPDATE_AUTH,
                                              p_xfr_usergroup.USER_GROUP_DISC_LIMIT,p_xfr_usergroup.ALLOW_CONFIG_CHANGES,
                                              p_xfr_usergroup.DELETED_FLAG, SYSDATE,
                                              SYSDATE, 1, 1, NULL,p_xfr_usergroup.CHECKOUT_USER);
                                             nInsertCount:=nInsertCount+1;
                                             BEGIN
                                               UPDATE CZ_IMP_user_group
                                                  SET REC_STATUS='OK'
                                                WHERE USER_GROUP_ID=p_xfr_usergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                             END;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_user_group
                                                          SET REC_STATUS='ERR'
                                                        WHERE USER_GROUP_ID=p_xfr_usergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_USER_GROUP',11276);
                                     END ;
                             ELSIF (p_xfr_usergroup.DISPOSITION = 'M') THEN
                                     BEGIN
                                             UPDATE CZ_USER_GROUPS SET
                                                                                             /*DESC_TEXT=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_usergroup.DESC_TEXT,DESC_TEXT),*/
                                                                                             GROUP_NAME=DECODE(NOUPDATE_GROUP_NAME,0,p_xfr_usergroup.GROUP_NAME,group_NAME),
                                                                                             GROUP_DESC=DECODE(NOUPDATE_GROUP_DESC,0,p_xfr_usergroup.GROUP_DESC,group_DESC),
                                                                                             READ_AUTH=DECODE(NOUPDATE_READ_AUTH,0,p_xfr_usergroup.READ_AUTH,READ_AUTH),
                                                                                             CREATE_AUTH=DECODE(NOUPDATE_CREATE_AUTH,0,p_xfr_usergroup.CREATE_AUTH,CREATE_AUTH),
                                                                                             DELETE_AUTH=DECODE(NOUPDATE_DELETE_AUTH,0,p_xfr_usergroup.DELETE_AUTH,DELETE_AUTH),
                                                                                             UPDATE_AUTH=DECODE(NOUPDATE_UPDATE_AUTH,0,p_xfr_usergroup.UPDATE_AUTH,UPDATE_AUTH),
                                                                                             USER_GROUP_DISC_LIMIT=DECODE(NOUPDATE_USER_GROUP_DISC_LIMIT,0,p_xfr_usergroup.USER_GROUP_DISC_LIMIT,USER_GROUP_DISC_LIMIT),
                                                                                             ALLOW_CONFIG_CHANGES=DECODE(NOUPDATE_ALLOW_CONFIG_CHANGES,0,p_xfr_usergroup.ALLOW_CONFIG_CHANGES,ALLOW_CONFIG_CHANGES),
                                                                                             DELETED_FLAG=           DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_usergroup.DELETED_FLAG ,DELETED_FLAG),
                                                                                             CREATION_DATE=                        DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
                                                                                             LAST_UPDATE_DATE=                       DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
                                                                                             CREATED_BY=                     DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
                                                                                             LAST_UPDATED_BY=            DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
                                                                                             SECURITY_MASK=          DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
                                                                                             CHECKOUT_USER=          DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER)
                                                                                             WHERE USER_GROUP_ID=p_xfr_usergroup.USER_GROUP_ID;
                                             IF(SQL%NOTFOUND) THEN
                                                     nFailed:=nFailed+1;
                                             ELSE
                                                     nUpdateCount:=nUpdateCount+1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_user_group
                                                          SET REC_STATUS='OK'
                                                        WHERE USER_GROUP_ID=p_xfr_usergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                             END IF;
                                     EXCEPTION
                                             WHEN OTHERS THEN
                                                     nFailed:=nFailed +1;
                                                     BEGIN
                                                       UPDATE CZ_IMP_user_group
                                                          SET REC_STATUS='ERR'
                                                        WHERE USER_GROUP_ID=p_xfr_usergroup.USER_GROUP_ID AND RUN_ID=inRUN_ID;
                                                     END;
                                                     x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_USER_GROUP',11276);
                                     END ;
                             END IF;
                     END LOOP;
                     CLOSE c_xfr_usergroup;
                     COMMIT;
                     INSERTS:=nInsertCount;
                     UPDATES:=nUpdateCount;
                     FAILED:=nFailed;
             EXCEPTION
             WHEN OTHERS THEN
             x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_XFR.XFR_USER_GROUP',11276);
             END;
  END XFR_USER_GROUP;
  /*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
 END CZ_IMP_AC_XFR;

/
