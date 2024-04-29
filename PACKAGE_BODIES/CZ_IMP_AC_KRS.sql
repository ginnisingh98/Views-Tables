--------------------------------------------------------
--  DDL for Package Body CZ_IMP_AC_KRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_AC_KRS" AS
--$Header: cziackrb.pls 115.16 2002/11/27 16:58:20 askhacha ship $

PROCEDURE KRS_CONTACT      (       inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           CURSOR c_imp_contact IS
                   SELECT ORIG_SYS_REF , FSK_CUSTOMER_1_1, FSK_address_2_1, ROWID FROM CZ_IMP_CONTACT
                   WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
                   ORDER BY ORIG_SYS_REF, FSK_CUSTOMER_1_1 , FSK_address_2_1, ROWID;

           /* cursor's data found indicator */
           x_imp_contact_f                                         BOOLEAN:=FALSE;
           x_onl_contact_f                                         BOOLEAN:=FALSE;
           x_onl_customer_customerid_f                               BOOLEAN:=FALSE;
           x_onl_address_addressid_f                               BOOLEAN:=FALSE;
           x_error                                                 BOOLEAN:=FALSE;
           nOnlContactId                                           CZ_IMP_CONTACT.CONTACT_ID%TYPE;
           nOnlcustomerId                                           CZ_IMP_CUSTOMER.CUSTOMER_ID%TYPE;
           nOnladdressId                                           CZ_IMP_ADDRESS.ADDRESS_ID%TYPE;
           sImpOrigSysRef                                          CZ_IMP_CONTACT.ORIG_SYS_REF%TYPE;
           sFSKcustomer                                             CZ_IMP_CONTACT.FSK_CUSTOMER_1_1%TYPE;
           sFSKaddress                                             CZ_IMP_CONTACT.FSK_ADDRESS_2_1%TYPE;
           sLastFSK1                                               CZ_IMP_CONTACT.ORIG_SYS_REF%TYPE;
           sThisFSK1                                               CZ_IMP_CONTACT.ORIG_SYS_REF%TYPE;
           sLastFSK2                                               CZ_IMP_CONTACT.FSK_CUSTOMER_1_1%TYPE;
           sThisFSK2                                               CZ_IMP_CONTACT.FSK_CUSTOMER_1_1%TYPE;
           sLastFSK3                                               CZ_IMP_CONTACT.FSK_ADDRESS_2_1%TYPE;
           sThisFSK3                                               CZ_IMP_CONTACT.FSK_ADDRESS_2_1%TYPE;
           sRecStatus                                              CZ_IMP_CONTACT.REC_STATUS%TYPE;
           sDisposition                                            CZ_IMP_CONTACT.DISPOSITION%TYPE;
           /* Internal vars */
           nCommitCount                                            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                                             PLS_INTEGER:=0;                 /*Error index */
           nInsertCount                                            PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount                                            PLS_INTEGER:=0;                 /*Updates */
           nFailed                                                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                                                   PLS_INTEGER:=0;                 /*Dupl records */
  	     /* No surrogates for Contact, CUSTOMER and Address since all three tables use ORIG_SYS_REF */
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;

     thisRowId                   ROWID;

   BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

           /* This type casting is necessary to use decode stmt */
           OPEN c_imp_contact ;

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

                   sImpOrigsysref:=NULL; sFSKcustomer:=NULL; sFSKaddress:=NULL;
                   FETCH c_imp_contact INTO sImpOrigSysref, sFSKcustomer, sFSKaddress, thisRowId;
                   sThisFSK1:=sImpOrigSysRef;
                   sThisFSK2:=sFSKcustomer;
                   sThisFSK3:=sFSKAddress;
                   x_imp_contact_f:=c_imp_contact%FOUND;

                   EXIT WHEN NOT x_imp_contact_f;
                   /* Check  Online Dbase */
                   DECLARE
                           CURSOR c_onl_contact IS
                   SELECT CONTACT_ID FROM CZ_CONTACTS WHERE ORIG_SYS_REF=sImpOrigsysref;
                   BEGIN
                           OPEN  c_onl_contact;
                           nOnlContactId:=NULL;
                           FETCH c_onl_contact INTO  nOnlContactId;
                           x_onl_contact_f:=c_onl_contact%FOUND;
                           CLOSE c_onl_contact;
                   END;

                   DECLARE
                           CURSOR c_onl_customer_customerid IS
                                   SELECT CUSTOMER_ID FROM CZ_CUSTOMERS WHERE ORIG_SYS_REF= sFSKcustomer;
                   BEGIN
                           OPEN  c_onl_customer_customerid;
                           nOnlcustomerId:=NULL;
                           FETCH c_onl_customer_customerid INTO nOnlcustomerId;
                           x_onl_customer_customerid_f:=c_onl_customer_customerid%FOUND;
                           CLOSE c_onl_customer_customerid;
                   END;

                   DECLARE
                           CURSOR c_onl_address_addressid IS
                                   SELECT ADDRESS_ID FROM CZ_ADDRESSES WHERE ORIG_SYS_REF= sFSKaddress;
                   BEGIN
                           OPEN  c_onl_address_addressid;
                           nOnladdressId:=NULL;
                           FETCH c_onl_address_addressid INTO nOnladdressId;
                           x_onl_address_addressid_f:=c_onl_address_addressid%FOUND;
                           CLOSE c_onl_address_addressid;
                   END;

                   IF(NOT x_onl_customer_customerid_f OR (sFSKcustomer IS NULL) OR
                      NOT x_onl_address_addressid_f OR (sFSKAddress IS NULL) OR
                      (sImpOrigSysref IS NULL )) THEN
                           BEGIN
                                   /* The record has no FSK or Surrogate key*/
                                   nFailed:=nFailed+1;
                                   IF (sImpOrigSysref IS NULL) THEN
                                                   sRecStatus:='N17';
                                   ELSIF(NOT x_onl_customer_customerid_f AND sFSKcustomer IS NULL) THEN
                                                   sRecStatus:='N41';
                                   ELSIF(NOT x_onl_customer_customerid_f) THEN
                                                   sRecStatus:='F41';
                                   ELSIF(NOT x_onl_address_addressid_f AND sFSKaddress IS NULL) THEN
                                                   sRecStatus:='N44';
                                   ELSIF(NOT x_onl_address_addressid_f) THEN
                                                   sRecStatus:='F44';
                                   END IF;
                                   sDisposition:='R';
                           END;
                   ELSE
                           BEGIN
					IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1 AND
					   sLastFSK2 IS NOT NULL AND sLastFSK2=sThisFSK2 AND
					   sLastFSK3 IS NOT NULL AND sLastFSK3=sThisFSK3) THEN
                                           /* This is a duplicate record */
                                           sRecStatus:='DUPL';
                                           sDisposition:='R';
                                           nDups:=nDups+1;
                                           nFailed:=nFailed+1;
                                   ELSE
                                           BEGIN
                                                   sRecStatus:='PASS';
                                                   IF( x_onl_contact_f)THEN
                                                           /* Update */
                                                           sDisposition:='M';
                                                           nUpdateCount:=nUpdateCount+1;
                                                   ELSE
                                                           /*Insert */
                                                           sDisposition:='I';
                                                           /* Get PK for this record */
                                                           nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_CONTACTS_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
                                                   END IF;
                                           END;
                                   END IF;
                           END;
                   END IF;

                   UPDATE CZ_IMP_CONTACT SET
                    CONTACT_ID=DECODE(sDISPOSITION,'R',CONTACT_ID,'I', nNextValue+nAllocateCounter, nOnlContactId),
                    CUSTOMER_ID=DECODE(sDISPOSITION,'R',CUSTOMER_ID,nonlcustomerid),
                    ADDRESS_ID=DECODE(sDISPOSITION,'R',ADDRESS_ID,nonladdressid),
                    DISPOSITION=sDisposition, REC_STATUS=sRecStatus
                   WHERE ROWID = thisRowId;
                   sLastFSK1:=sImpOrigSysref;
                   sLastFSK2:=sFSKcustomer;
                   sLastFSK3:=sFSKAddress;

                   /* Return if MAX_ERR is reached */
                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           /* No more data */
           CLOSE c_imp_contact;

           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
           x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_CONTACT',11276);
   END;
END KRS_CONTACT;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*   *comment_label:                                                                                */
/*   01.06.99 -- no parent-child relationships for this table                                       */
/*            -- no references to PRICE_GROUP table                                                 */
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_CUSTOMER     (       inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           CURSOR c_imp_customer (x_usesurr_pricegroup    PLS_INTEGER) IS
                   SELECT ORIG_SYS_REF, DECODE(x_usesurr_pricegroup,0,FSK_PRICEGROUP_1_1,1,FSK_PRICEGROUP_1_EXT) ,FSK_CUSTOMER_2_1, ROWID
                   FROM CZ_IMP_CUSTOMER WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID ORDER BY 1,2,3, ROWID;

           /* cursor's data found indicator */
           x_imp_customer_f                                       BOOLEAN:=FALSE;
           x_onl_customer_f                                         BOOLEAN:=FALSE;
           x_onl_pricegroup_prgrpid_f                              BOOLEAN:=FALSE;
           x_onl_customer_parentid_f                                BOOLEAN:=FALSE;
           x_error                                                 BOOLEAN:=FALSE;
           nOnlcustomerId                                           CZ_IMP_CUSTOMER.CUSTOMER_ID%TYPE;
           nOnlFskParentId                                         CZ_IMP_CUSTOMER.PARENT_ID%TYPE;
           nOnlFSKPriceGroupId                                     CZ_IMP_CUSTOMER.PRICE_list_ID%TYPE;
           sImpOrigsysref                                          CZ_IMP_CUSTOMER.ORIG_SYS_REF%TYPE;
           sFSKPRICEGROUP                                          CZ_IMP_CUSTOMER.FSK_PRICEGROUP_1_1%TYPE;
           sFSKCUSTOMER                                             CZ_IMP_CUSTOMER.FSK_CUSTOMER_2_1%TYPE;
           sLastFSK1                                                CZ_IMP_CUSTOMER.ORIG_SYS_REF%TYPE;
           sThisFSK1                                                CZ_IMP_CUSTOMER.ORIG_SYS_REF%TYPE;
           sLastFSK2                                                CZ_IMP_CUSTOMER.FSK_PRICEGROUP_1_1%TYPE;
           sThisFSK2                                                CZ_IMP_CUSTOMER.FSK_PRICEGROUP_1_1%TYPE;
           sLastFSK3                                                CZ_IMP_CUSTOMER.FSK_CUSTOMER_2_1%TYPE;
           sThisFSK3                                                CZ_IMP_CUSTOMER.FSK_CUSTOMER_2_1%TYPE;
           sRecStatus                                              CZ_IMP_CUSTOMER.REC_STATUS%TYPE;
           sDisposition                                            CZ_IMP_CUSTOMER.DISPOSITION%TYPE;
           /* Internal vars */
           nCommitCount                                            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                                                     PLS_INTEGER:=0;                 /*Error index */
           nInsertCount                                            PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount                                            PLS_INTEGER:=0;                 /*Updates */
           nFailed                                                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                                                           PLS_INTEGER:=0;                 /*Dupl records */
           x_usesurr_pricegroup                                    PLS_INTEGER:=                 /*Use surrogates */
       											CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_PRICE_GROUPS',inXFR_GROUP);
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;
     thisRowId                   ROWID;

   BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

           /* This type casting is necessary to use decode stmt */
           OPEN c_imp_CUSTOMER(x_usesurr_pricegroup) ;

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

                   sImporigsysref:=NULL; sfskPriceGroup:=NULL; sfskCUSTOMER:=NULL;
                   FETCH c_imp_CUSTOMER INTO sImpOrigSysref, sfskPriceGroup, sfskCUSTOMER, thisRowId;
                   sThisFSK1:=sImpOrigSysref;
		   sThisFSK2:=sFSKPriceGroup;
                   sThisFSK3:=sFSKCUSTOMER;

                   x_imp_CUSTOMER_f:=c_imp_CUSTOMER%FOUND;

                   EXIT WHEN NOT x_imp_CUSTOMER_f;
                   /* Check Online Dbase */
                   DECLARE
                           CURSOR c_onl_CUSTOMER IS
                                   SELECT CUSTOMER_ID FROM CZ_CUSTOMERS
WHERE ORIG_SYS_REF=sImpOrigSysref;
                   BEGIN
                           OPEN  c_onl_CUSTOMER;
                           nOnlCUSTOMERId:=NULL;
                           FETCH c_onl_CUSTOMER INTO  nOnlCUSTOMERId;
                           x_onl_CUSTOMER_f:=c_onl_CUSTOMER%FOUND;
                           CLOSE c_onl_CUSTOMER;
                   END;
/*------------------------------------01.06.99--------------------------------------------------
                   nOnlFSKPriceGroupid:=NULL;
                   DECLARE
                           CURSOR c_onl_pricegroup_prgrpid IS
                                   SELECT PRICE_GROUP_ID FROM PRICE_GROUP WHERE NAME=sFSKPRICEGROUP;
                   BEGIN
                           OPEN  c_onl_pricegroup_prgrpid;
                           nOnlFSKPriceGroupid:=NULL;
                           FETCH c_onl_pricegroup_prgrpid INTO nOnlFSKPriceGroupid;
                           x_onl_pricegroup_prgrpid_f:=c_onl_pricegroup_prgrpid%FOUND;
                           CLOSE c_onl_pricegroup_prgrpid;
                   END;
                   nOnlFSKParentid:=NULL;
                   DECLARE
                           CURSOR c_onl_CUSTOMER_parentid IS
                                   SELECT CUSTOMER_ID FROM CUSTOMER WHERE ORIG_SYS_REF= sFSKCUSTOMER;
                   BEGIN
                           OPEN  c_onl_CUSTOMER_parentid;
                           nOnlFSKParentid:=NULL;
                           FETCH c_onl_CUSTOMER_parentid INTO nOnlFSKParentid;
                           x_onl_CUSTOMER_parentid_f:=c_onl_CUSTOMER_parentid%FOUND;
                           CLOSE c_onl_CUSTOMER_parentid;
                   END;
----------------------------------------------------------------------------------------------*/
                   x_onl_pricegroup_prgrpid_f:=TRUE;
                   x_onl_CUSTOMER_parentid_f:=TRUE;

                   IF(NOT x_onl_pricegroup_prgrpid_f OR
                     (NOT x_onl_CUSTOMER_parentid_f AND sFSKCUSTOMER IS NOT NULL) OR
                     (sImpOrigSysref IS NULL )) THEN
                           BEGIN
                                   /* The record has CUSTOMERID but no Price GroupId or FSK CUSTOMERId */
                                   nFailed:=nFailed+1;
                                   IF (sImporigsysref IS NULL) THEN
                                                   sRecStatus:='N8';
                                   ELSIF(NOT x_onl_pricegroup_prgrpid_f AND x_usesurr_pricegroup=1 AND sFSKPRICEGROUP IS NULL) THEN
                                                   sRecStatus:='N30';
                                   ELSIF(NOT x_onl_pricegroup_prgrpid_f AND x_usesurr_pricegroup=1) THEN
                                                   sRecStatus:='F30';
                                   ELSIF (NOT x_onl_pricegroup_prgrpid_f AND x_usesurr_pricegroup=0 AND sFSKPRICEGROUP IS NULL) THEN
                                                   sRecStatus:='N29';
                                   ELSIF (NOT x_onl_pricegroup_prgrpid_f AND x_usesurr_pricegroup=0) THEN
                                                   sRecStatus:='F29';
                                   ELSIF(NOT x_onl_CUSTOMER_parentid_f AND sFSKCUSTOMER IS NOT NULL) THEN
                                                   sRecStatus:='F32';
                                   END IF;
                                  sDisposition:='R';
                           END;
                   ELSE
                           /*  insert or update */
                           BEGIN
					IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1 /*AND
					   sLastFSK2 IS NOT NULL AND sLastFSK2=sThisFSK2 AND
					   sLastFSK3 IS NOT NULL AND sLastFSK3=sThisFSK3 */) THEN
                                           /* This is a duplicate record */
                                           sRecStatus:='DUPL';
                                           sDisposition:='R';
                                           nDups:=nDups+1;
                                           nFailed:=nFailed+1;
                                   ELSE
                                           BEGIN
                                                   sRecStatus:='PASS';
                                                   IF( x_onl_CUSTOMER_f)THEN
                                                           /* Update  */
                                                           sDisposition:='M';
                                                           nUpdateCount:=nUpdateCount+1;
                                                   ELSE
                                                           /*Insert */
                                                           sDisposition:='I';
                                                           /* Get PK for this record */
                                                           nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_CUSTOMERS_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
                                                   END IF;
                                           END;
                                   END IF;
                           END;
                   END IF;

                   UPDATE CZ_IMP_CUSTOMER SET CUSTOMER_ID=DECODE(sDISPOSITION,'R',CUSTOMER_ID,'I',nNextValue+nAllocateCounter,nonlCUSTOMERid),
                                                    PRICE_LIST_ID=DECODE(sDISPOSITION,'R',PRICE_list_ID,nOnlFSKPriceGroupId),
                                                    PARENT_ID=DECODE(sDISPOSITION,'R',PARENT_ID,nonlFSKParentid),
                                                    DISPOSITION=sDisposition, REC_STATUS=sRecStatus   WHERE ROWID = thisRowId;
                   sLastFSK1:=sImpOrigSysref;
 		       sLastFSK2:=sFSKPriceGroup;
                   sLastFSK3:=sFSKCUSTOMER;

                   /* Return if MAX_ERR is reached */
                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           /* No more data */
           CLOSE c_imp_CUSTOMER;

           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
           x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_CUSTOMER',11276);
   END;
END KRS_CUSTOMER;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_ADDRESS (     inRUN_ID               IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           CURSOR c_imp_address IS
                   SELECT ORIG_SYS_REF, FSK_CUSTOMER_1_1, ROWID FROM CZ_IMP_ADDRESS WHERE REC_STATUS IS NULL  AND RUN_ID = inRUN_ID  ORDER BY ORIG_SYS_REF,FSK_CUSTOMER_1_1, ROWID;
           /* cursor's data found indicators */
           nOnlADDRESSId                           CZ_IMP_ADDRESS.ADDRESS_ID%TYPE;
           nOnlFSKCUSTOMERID                        CZ_IMP_ADDRESS.FSK_CUSTOMER_1_1%TYPE;
           sImpOrigSysRef                          CZ_IMP_ADDRESS.ORIG_SYS_REF%TYPE;
           sFSKCUSTOMER11                           CZ_IMP_ADDRESS.FSK_CUSTOMER_1_1%TYPE;
           sLastFSK1                               CZ_IMP_ADDRESS.ADDRESS_ID%TYPE;
           sThisFSK1                               CZ_IMP_ADDRESS.ADDRESS_ID%TYPE;
           sRecStatus                              CZ_IMP_ADDRESS.REC_STATUS%TYPE;
           sDisposition                            CZ_IMP_ADDRESS.DISPOSITION%TYPE;
           /* Column Vars */
           x_imp_address_f                                            BOOLEAN:=FALSE;
           x_onl_address_f                                            BOOLEAN:=FALSE;
           x_onl_CUSTOMER_CUSTOMERid_f                                      BOOLEAN:=FALSE;
           x_error                                                    BOOLEAN:=FALSE;
           p_onl_CUSTOMER                                              CHAR(1):='';
           /* Internal vars */
           nCommitCount            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                     PLS_INTEGER:=0;                 /*Error index */
           nInsertCount            PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount            PLS_INTEGER:=0;                 /*Updates */
           nFailed                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                           PLS_INTEGER:=0;                 /*Duplicate records */
           x_usesurr                       PLS_INTEGER:=                 /*Use surrogates */
       											CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ADDRESSES',inXFR_GROUP);
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;

     thisRowId                   ROWID;

   BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

           OPEN c_imp_address  ;

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
                   sImpOrigSysRef:=NULL; sFSKCUSTOMER11:=NULL;
                   FETCH c_imp_address INTO sImporigsysref, sFSKCUSTOMER11, thisRowId;
                   sThisFSK1:=sImporigsysref;
                   x_imp_address_f:=c_imp_address%FOUND;

                   EXIT WHEN NOT x_imp_address_f;
                   DECLARE
                           CURSOR c_onl_address_addressid IS
                                   SELECT ADDRESS_ID FROM CZ_ADDRESSES WHERE ORIG_SYS_REF=sImpOrigSysRef;
                   BEGIN
                           OPEN  c_onl_address_addressid;
                           nOnlAddressId:=NULL;
                           FETCH   c_onl_address_addressid INTO nOnladdressId;
                           x_onl_address_f:=c_onl_address_addressid%FOUND;
                           CLOSE c_onl_address_addressid;
                   END;
                   DECLARE
                           CURSOR c_onl_CUSTOMER_CUSTOMERid IS
                                   SELECT CUSTOMER_ID FROM CZ_CUSTOMERS  WHERE ORIG_SYS_REF=sFSKCUSTOMER11;
                   BEGIN
                           OPEN c_onl_CUSTOMER_CUSTOMERid ;
                           nOnlFSKCUSTOMERId:=NULL;
                           FETCH   c_onl_CUSTOMER_CUSTOMERid  INTO nOnlFSKCUSTOMERId;
                           x_onl_CUSTOMER_CUSTOMERid_f:=c_onl_CUSTOMER_CUSTOMERid%FOUND;
                           CLOSE c_onl_CUSTOMER_CUSTOMERid ;
                   END;
                   IF(NOT x_onl_CUSTOMER_CUSTOMERid_f ) THEN
                           BEGIN
                                   /* The record has missing FSKs */
                                   nFailed:=nFailed+1;
                                   IF(sFSKCUSTOMER11 IS NULL) THEN
                                                   sRecStatus:='N28';
                                   ELSE
                                                   sRecStatus:='F28';
                                   END IF;
                                   sDisposition:='R';
                           END;
                   ELSE
                           /* Insert or update */
                           BEGIN
                                   IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1) THEN
                                           /* This is a duplicate record */
                                           sRecStatus:='DUPL';
                                           sDisposition:='R';
                                           nDups:=nDups+1;
                                           nFailed:=nFailed+1;
                                   ELSE
                                           BEGIN
                                                   sRecStatus:='PASS';
                                                   IF( x_onl_address_f)THEN
                                                           /* Update  */
                                                           sDisposition:='M';
                                                           nUpdateCount:=nUpdateCount+1;
                                                   ELSE
                                                           /*Insert */
                                                           sDisposition:='I';
                                                           nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_ADDRESSES_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
                                                   END IF;
                                           END;
                                   END IF;
                           END;
                   END IF;
                   UPDATE CZ_IMP_ADDRESS SET ADDRESS_ID=DECODE(sDISPOSITION,
                   'R',ADDRESS_ID,'I',nNextValue+nAllocateCounter,
                   nOnlADDRESSId),
                   CUSTOMER_ID=DECODE(sDISPOSITION,'R',CUSTOMER_ID,
                   nOnlFSKCUSTOMERId),DISPOSITION=sDisposition, REC_STATUS=sRecStatus
                   WHERE ROWID = thisRowId;
                   sLastFSK1:=sImporigsysref;

                   /* Return if MAX_ERR is reached */
                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           CLOSE c_imp_address;

           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
           x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_ADDRESS',11276);
   END;
END KRS_ADDRESS ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_ADDRESS_USES(inRUN_ID    IN  PLS_INTEGER,
                           COMMIT_SIZE IN  PLS_INTEGER,
                           MAX_ERR     IN  PLS_INTEGER,
                           INSERTS     OUT NOCOPY PLS_INTEGER,
                           UPDATES     OUT NOCOPY PLS_INTEGER,
                           FAILED      OUT NOCOPY PLS_INTEGER,
                           DUPS        OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                          ) IS
BEGIN
   DECLARE
     CURSOR c_imp_address_uses IS
     SELECT orig_sys_ref, fsk_address_1_1, ROWID
     FROM CZ_IMP_ADDRESS_USE
     WHERE rec_status IS NULL AND Run_ID = inRUN_ID
     ORDER BY orig_sys_ref, fsk_address_1_1, ROWID;

   /* cursor's data found indicator */
     x_imp_address_uses_f        BOOLEAN:=FALSE;
     x_onl_address_uses_f        BOOLEAN:=FALSE;
     x_onl_address_addressid_f   BOOLEAN:=FALSE;
     x_error                     BOOLEAN:=FALSE;

     nOnladdressusesId           CZ_IMP_ADDRESS_USE.ADDRESS_USE_ID%TYPE;
     nOnladdressId               CZ_IMP_ADDRESS.ADDRESS_ID%TYPE;
     sImpOrigSysRef              CZ_IMP_ADDRESS_USE.ORIG_SYS_REF%TYPE;
     sFSKaddress                 CZ_IMP_ADDRESS_USE.FSK_ADDRESS_1_1%TYPE;
     sThisFSK1                   CZ_IMP_ADDRESS_USE.ORIG_SYS_REF%TYPE;
     sLastFSK1                   CZ_IMP_ADDRESS_USE.ORIG_SYS_REF%TYPE;
     sRecStatus                  CZ_IMP_ADDRESS_USE.REC_STATUS%TYPE;
     sDisposition                CZ_IMP_ADDRESS_USE.DISPOSITION%TYPE;

   /* Internal vars */
     nCommitCount                PLS_INTEGER:=0; /*COMMIT buffer index */
     nErrorCount                 PLS_INTEGER:=0; /*Error index */
     nInsertCount                PLS_INTEGER:=0; /*Inserts */
     nUpdateCount                PLS_INTEGER:=0; /*Updates */
     nFailed                     PLS_INTEGER:=0; /*Failed records */
     nDups                       PLS_INTEGER:=0; /*Dupl records */
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;

     thisRowId                   ROWID;

   BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

    OPEN c_imp_address_uses ;

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

        sImpOrigSysRef:=NULL; sFSKaddress:=NULL;
        FETCH c_imp_address_uses INTO sImpOrigSysRef, sFSKaddress, thisRowId;
        sThisFSK1:=sImpOrigSysRef;
        x_imp_address_uses_f:=c_imp_address_uses%FOUND;

        EXIT WHEN NOT x_imp_address_uses_f;

      /* Check the online database */
        DECLARE
          CURSOR c_onl_address_uses IS
          SELECT address_use_id FROM CZ_ADDRESS_USES WHERE orig_sys_ref=sImpOrigSysRef;
            BEGIN
              OPEN c_onl_address_uses;
              nOnladdressusesId:=NULL;
              FETCH c_onl_address_uses INTO nOnladdressusesId;
              x_onl_address_uses_f:=c_onl_address_uses%FOUND;
              CLOSE c_onl_address_uses;
            END;

        DECLARE
          CURSOR c_onl_address_addressid IS
          SELECT address_id FROM CZ_ADDRESSES WHERE orig_sys_ref=sFSKaddress;
            BEGIN
              OPEN c_onl_address_addressid;
              nOnladdressId:=NULL;
              FETCH c_onl_address_addressid INTO nOnladdressId;
              x_onl_address_addressid_f:=c_onl_address_addressid%FOUND;
              CLOSE c_onl_address_addressid;
            END;

        IF(NOT x_onl_address_addressid_f OR (sFSKaddress IS NULL) OR
           (sImpOrigSysRef IS NULL)) THEN
          BEGIN
          /* The record has no FSK or Surrogate key */
            nFailed:=nFailed+1;
            IF(sImpOrigSysRef IS NULL) THEN
              sRecStatus:='N7';
            ELSIF(NOT x_onl_address_addressid_f AND sFSKaddress IS NULL) THEN
              sRecStatus:='N5';
            ELSIF(NOT x_onl_address_addressid_f) THEN
              sRecStatus:='F5';
            END IF;
            sDisposition:='R';
          END;
        ELSE
          BEGIN
            IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1) THEN
            /* This is a duplicate record */
              sRecStatus:='DUPL';
              sDisposition:='R';
              nDups:=nDups+1;
              nFailed:=nFailed+1;
            ELSE
              BEGIN
                sRecStatus:='PASS';
                IF(x_onl_address_uses_f)THEN
                /* Update */
                  sDisposition:='M';
                  nUpdateCount:=nUpdateCount+1;
                ELSE
                /*Insert */
                  sDisposition:='I';
                  nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_ADDRESS_USES_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
                END IF;
              END;
            END IF;
          END;
        END IF;

        UPDATE CZ_IMP_ADDRESS_USE SET
          ADDRESS_USE_ID=DECODE(sDisposition,'R',ADDRESS_USE_ID,'I',nNextValue+nAllocateCounter,nOnladdressusesId),
          ADDRESS_ID=DECODE(sDisposition,'R',ADDRESS_ID,nOnladdressid),
          DISPOSITION=sDisposition,
          REC_STATUS=sRecStatus
        WHERE ROWID = thisRowId;

        sLastFSK1:=sImpOrigSysref;

        /* Return if MAX_ERR is reached */
        IF(nFailed >= MAX_ERR) THEN
          EXIT;
        END IF;

        sDisposition:=NULL; sRecStatus:=NULL;

      END LOOP;
    /* No more data */

    CLOSE c_imp_address_uses;
    COMMIT;

    INSERTS:=nInsertCount;
    UPDATES:=nUpdateCount;
    FAILED:=nFailed;
    DUPS:=nDups;

    EXCEPTION
      WHEN OTHERS THEN
      x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_ADDRESS_USES',11276);
   END;
END KRS_address_uses;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_CUSTOMER_END_USER (  inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                                   inXFR_GROUP     IN      VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           CURSOR c_imp_CUSTOMERenduser(x_usesurr_enduser   PLS_INTEGER) IS
                   SELECT FSK_CUSTOMER_1_1,DECODE(x_usesurr_enduser,0,FSK_ENDUSER_2_1,1,FSK_ENDUSER_2_EXT), ROWID FROM CZ_IMP_CUSTOMER_END_USER WHERE REC_STATUS IS NULL  AND RUN_ID = inRUN_ID ORDER BY 1,2, ROWID;
           /* cursor's data found indicators */
           sFSKCUSTOMER                     CZ_IMP_CUSTOMER_END_USER.CUSTOMER_ID%TYPE;
           sFskEndUser                     CZ_IMP_CUSTOMER_END_USER.FSK_ENDUSER_2_1%TYPE;
           nOnlCUSTOMERId                   CZ_IMP_CUSTOMER_END_USER.CUSTOMER_ID%TYPE;
           nOnlEndUserId                   CZ_IMP_CUSTOMER_END_USER.END_USER_ID%TYPE;
           sLastFSK1                       CZ_IMP_CUSTOMER_END_USER.FSK_CUSTOMER_1_1%TYPE;
           sThisFSK1                       CZ_IMP_CUSTOMER_END_USER.FSK_CUSTOMER_1_1%TYPE;
           sLastFSK2                       CZ_IMP_CUSTOMER_END_USER.FSK_ENDUSER_2_1%TYPE;
           sThisFSK2                       CZ_IMP_CUSTOMER_END_USER.FSK_ENDUSER_2_1%TYPE;
           sRecStatus                      CZ_IMP_CUSTOMER_END_USER.REC_STATUS%TYPE;
           sDisposition                    CZ_IMP_CUSTOMER_END_USER.DISPOSITION%TYPE;
           /* Column Vars */
           x_imp_CUSTOMERenduser_f                                                 BOOLEAN:=FALSE;
           x_onl_CUSTOMER_CUSTOMERid_f                                            BOOLEAN:=FALSE;
           x_onl_enduser_enduserid_f                                          BOOLEAN:=FALSE;
           x_onl_CUSTOMERenduser_f                                       BOOLEAN:=FALSE;
           x_error                                                         BOOLEAN:=FALSE;
           p_onl_CUSTOMERenduser                                              CHAR(1):='';
           /* Internal vars */
           nCommitCount            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                     PLS_INTEGER:=0;                 /*Error index */
           nInsertCount            PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount            PLS_INTEGER:=0;                 /*Updates */
           nFailed                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                           PLS_INTEGER:=0;                 /*Duplicate records */
           x_usesurr_enduser                       PLS_INTEGER:=                 /*Use surrogates */
       											CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_END_USERS',inXFR_GROUP);

           thisRowId               ROWID;

   BEGIN

           /* This type casting is necessary to use decode stmt */
           OPEN c_imp_CUSTOMERenduser (x_usesurr_enduser) ;

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

                   sFSKCUSTOMER:=NULL;  sFSKENDUSER:=NULL;
                   FETCH c_imp_CUSTOMERenduser      INTO sFSKCUSTOMER, sFSKENDUSER, thisRowId ;
                   x_imp_CUSTOMERenduser_f:=c_imp_CUSTOMERenduser%FOUND;
                   sThisFSK1:=sFSKCUSTOMER;
                   sThisFSK2:=sFSKENDUSER;

                   EXIT WHEN NOT x_imp_CUSTOMERenduser_f;

                   DECLARE
                           CURSOR c_onl_CUSTOMER_CUSTOMERid IS
                                   SELECT CUSTOMER_ID FROM CZ_CUSTOMERS WHERE ORIG_SYS_REF=sFSKCUSTOMER;
                   BEGIN
                           OPEN  c_onl_CUSTOMER_CUSTOMERid;
                           nOnlCUSTOMERId:=NULL;
                           FETCH   c_onl_CUSTOMER_CUSTOMERid INTO nOnlCUSTOMERId;
                           x_onl_CUSTOMER_CUSTOMERid_f:=c_onl_CUSTOMER_CUSTOMERid%FOUND;
                           CLOSE c_onl_CUSTOMER_CUSTOMERid;
                   END;
                   DECLARE
                           CURSOR c_onl_enduser_enduserid IS
                                   SELECT END_USER_ID FROM CZ_END_USERS  WHERE LOGIN_NAME=sFSKENDUSER;
                   BEGIN
                           OPEN c_onl_enduser_enduserid ;
                           nOnlEnduserId:=NULL;
                           FETCH   c_onl_enduser_enduserid  INTO nOnlenduserId;
                           x_onl_enduser_enduserid_f:=c_onl_enduser_enduserid%FOUND;
                           CLOSE c_onl_enduser_enduserid ;
                   END;
                   /* Check if this is an insert or update */
                   DECLARE
                           CURSOR c_onl_CUSTOMERenduser  IS
                                   SELECT 'X' FROM CZ_CUSTOMER_END_USERS WHERE CUSTOMER_ID=nOnlCUSTOMERId
                                   AND END_USER_ID=nOnlEnduserId;
                   BEGIN
                           OPEN c_onl_CUSTOMERenduser ;
                           FETCH c_onl_CUSTOMERenduser INTO p_onl_CUSTOMERenduser;
                           x_onl_CUSTOMERenduser_f:=c_onl_CUSTOMERenduser%FOUND;
                           CLOSE c_onl_CUSTOMERenduser;
                   END;
                   IF(NOT x_onl_CUSTOMER_CUSTOMERid_f OR NOT x_onl_enduser_enduserid_f) THEN
                           BEGIN
                                   /* The record has missing FSKs */
                                   nFailed:=nFailed+1;
                                   IF(NOT x_onl_CUSTOMER_CUSTOMERid_f AND sFSKCUSTOMER IS NULL) THEN
                                                   sRecStatus:='N13';
                                   ELSIF(NOT x_onl_CUSTOMER_CUSTOMERid_f) THEN
                                                   sRecStatus:='F13';
                                   ELSIF (NOT x_onl_enduser_enduserid_f  AND x_usesurr_enduser=0 AND sFSKENDUSER IS NULL) THEN
                                                   sRecStatus:='N15';
                                   ELSIF (NOT x_onl_enduser_enduserid_f  AND x_usesurr_enduser=0) THEN
                                                   sRecStatus:='F15';
                                   ELSIF(NOT x_onl_enduser_enduserid_f   AND x_usesurr_enduser=1 AND sFSKENDUSER IS NULL) THEN
                                                   sRecStatus:='N14';
                                   ELSIF(NOT x_onl_enduser_enduserid_f AND x_usesurr_enduser=1) THEN
                                                   sRecStatus:='F14';
                                   END IF;
                                   sDisposition:='R';
                           END;
                   ELSE
                           /* Insert or update */
                           BEGIN
                                   IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1 AND
                                      sLastFSK2 IS NOT NULL AND sLastFSK2=sThisFSK2) THEN
                                           /* This is a duplicate record */
                                           sRecStatus:='DUPL';
                                           sDisposition:='R';
                                           nDups:=nDups+1;
                                           nFailed:=nFailed+1;
                                   ELSE
                                           BEGIN
                                                   sRecStatus:='PASS';
                                                   IF( x_onl_CUSTOMERenduser_f)THEN
                                                           /* Update  */
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

                   UPDATE CZ_IMP_CUSTOMER_END_USER
                   SET CUSTOMER_ID=DECODE(sDISPOSITION,'R',CUSTOMER_ID,nOnlCUSTOMERId),
                   END_USER_ID=DECODE(sDISPOSITION,'R',END_USER_ID,nOnlendUserId),
                   DISPOSITION=sDisposition, REC_STATUS=sRecStatus
                   WHERE ROWID = thisRowId;

                   sLastFSK1:=sFSKCUSTOMER;
                   sLastFSK2:=sFSKENDUSER;

                   /* Return if MAX_ERR is reached */
                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           CLOSE c_imp_CUSTOMERenduser;
           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
           x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_AC.KRS_CUSTOMER_END_USER',11276);
   END;
END KRS_CUSTOMER_END_USER;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_END_USER (inRUN_ID        IN      PLS_INTEGER,
                        COMMIT_SIZE     IN      PLS_INTEGER,
                        MAX_ERR         IN      PLS_INTEGER,
                        INSERTS         OUT NOCOPY     PLS_INTEGER,
                        UPDATES         OUT NOCOPY     PLS_INTEGER,
                        FAILED          OUT NOCOPY     PLS_INTEGER,
                        DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                       ) IS
BEGIN
   DECLARE
           CURSOR c_imp_enduser IS
             SELECT ORIG_SYS_REF, ROWID FROM CZ_IMP_END_USER WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
           ORDER BY 1, ROWID;

           /* cursor's data found indicators */
           sImpOrigSysRef                  CZ_IMP_END_USER.LOGIN_NAME%TYPE;
           nUserId                         CZ_IMP_END_USER.END_USER_ID%TYPE;
           sLastFSK                        CZ_IMP_END_USER.LOGIN_NAME%TYPE;
           sThisFSK                        CZ_IMP_END_USER.LOGIN_NAME%TYPE;
           sRecStatus                      CZ_IMP_END_USER.REC_STATUS%TYPE;
           sDisposition                    CZ_IMP_END_USER.DISPOSITION%TYPE;
           /* Column Vars */
           x_imp_enduser_f                 BOOLEAN:=FALSE;
           x_onl_enduser_userid_f          BOOLEAN:=FALSE;
           x_error                         BOOLEAN:=FALSE;
           /* Internal vars */
           nCommitCount            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount             PLS_INTEGER:=0;                 /*Error index */
           nInsertCount            PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount            PLS_INTEGER:=0;                 /*Updates */
           nFailed                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                   PLS_INTEGER:=0;                 /*Duplicate records */
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;
     sAutoCreateUsers            CZ_DB_SETTINGS.VALUE%TYPE := 'NO';

     thisRowId                   ROWID;

   BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;
    BEGIN
     SELECT VALUE INTO sAutoCreateUsers FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='AUTOCREATE_IMPORTED_USERS' AND SECTION_NAME='ORAAPPS_INTEGRATE';
    EXCEPTION
      WHEN OTHERS THEN
        sAutoCreateUsers:='NO';
    END;

           /* This type casting is necessary to use decode stmt */
           OPEN c_imp_enduser;

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

                  sImpOrigSysRef:=NULL;
                  FETCH c_imp_enduser INTO sImpOrigSysRef, thisRowId;
                  sThisFSK:=sImpOrigSysRef;
                  x_imp_enduser_f:=c_imp_enduser%FOUND;

                  EXIT WHEN NOT x_imp_enduser_f;

                   /* Check if this is an insert or update */
                   DECLARE
                      CURSOR c_onl_enduser_userid  IS
                        SELECT END_USER_ID FROM CZ_END_USERS WHERE ORIG_SYS_REF=sImpOrigSysRef;
                   BEGIN
                      OPEN c_onl_enduser_userid ;
                      nUserId:=NULL;
                      FETCH c_onl_enduser_userid INTO nUserId;
                      x_onl_enduser_userid_f:=c_onl_enduser_userid%FOUND;
                      CLOSE c_onl_enduser_userid;
                   END;
                   /* All foreign keys are resolved */
                   IF(sImpOrigSysRef IS NULL)THEN
                           BEGIN
                                   /* Error */
                                   nFailed:=nFailed+1;
                                   sRecStatus:='N43';
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
                                   IF(x_onl_enduser_userid_f)THEN
                                           /* Update */
                                           sDisposition:='M';
                                           nUpdateCount:=nUpdateCount+1;
                                   ELSE
                                           /*Insert */
                                           sDisposition:='I';
                                           nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_END_USERS_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
                                   END IF;
                           END;
                   END IF;

                   UPDATE CZ_IMP_END_USER SET
                     END_USER_ID=DECODE(sDISPOSITION,'R',END_USER_ID,'I',nNextValue+nAllocateCounter,nUserId),
                     DISPOSITION=sDisposition,REC_STATUS=sRecStatus
                   WHERE ROWID = thisRowId;
                   IF(sAutoCreateUsers='YES')THEN
                     UPDATE CZ_IMP_END_USER SET
                       LOGIN_NAME=DECODE(sDISPOSITION,'I',DECODE(LOGIN_NAME,NULL,USER||'_'||to_char(END_USER_ID),LOGIN_NAME),LOGIN_NAME)
                     WHERE ROWID = thisRowId;
                   END IF;

                   sLastFSK:=sImpOrigSysRef;

                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           CLOSE c_imp_enduser;
           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
                   x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_END_USER',11276);
   END;
END KRS_END_USER;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_END_USER_GROUP (     inRUN_ID        IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           CURSOR c_imp_endusergroup (x_usesurr_enduser   PLS_INTEGER,
                                      x_usesurr_usergroup PLS_INTEGER) IS
           SELECT DECODE(x_usesurr_enduser,0,FSK_ENDUSER_1_1,1,FSK_ENDUSER_1_EXT),DECODE(x_usesurr_usergroup,0,FSK_USERGROUP_2_1,1,FSK_USERGROUP_2_EXT), ROWID
           FROM CZ_IMP_END_USER_GROUP
           WHERE REC_STATUS IS NULL AND RUN_ID=inRUN_ID ORDER BY 1,2,ROWID;

           /* cursor's data found indicators */
           nOnlFSKUserId                 CZ_IMP_END_USER_GROUP.END_USER_ID%TYPE;
           nOnlFSKGroupId                CZ_IMP_END_USER_GROUP.USER_GROUP_ID%TYPE;
           sFSKENDUSER                   CZ_IMP_END_USER_GROUP.FSK_ENDUSER_1_1%TYPE;
           sFSKUSERGROUP                 CZ_IMP_END_USER_GROUP.FSK_USERGROUP_2_1%TYPE;
           sLastFSK1                     CZ_IMP_END_USER_GROUP.FSK_ENDUSER_1_1%TYPE;
           sThisFSK1                     CZ_IMP_END_USER_GROUP.FSK_ENDUSER_1_1%TYPE;
           sLastFSK2                     CZ_IMP_END_USER_GROUP.FSK_USERGROUP_2_1%TYPE;
           sThisFSK2                     CZ_IMP_END_USER_GROUP.FSK_USERGROUP_2_1%TYPE;
           sRecStatus                    CZ_IMP_END_USER_GROUP.REC_STATUS%TYPE;
           sDisposition                  CZ_IMP_END_USER_GROUP.DISPOSITION%TYPE;
           /* Column Vars */
           x_imp_endusergroup_f          BOOLEAN:=FALSE;
           x_onl_endusergroup_f          BOOLEAN:=FALSE;
           x_onl_enduser_userid_f        BOOLEAN:=FALSE;
           x_onl_usergroup_groupid_f     BOOLEAN:=FALSE;
           x_error                       BOOLEAN:=FALSE;
           p_onl_endusergroup            CHAR(1):='';
           /* Internal vars */
           nCommitCount                  PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                   PLS_INTEGER:=0;                 /*Error index */
           nInsertCount                  PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount                  PLS_INTEGER:=0;                 /*Updates */
           nFailed                       PLS_INTEGER:=0;                 /*Failed records */
           nDups                         PLS_INTEGER:=0;                 /*Duplicate records */
           x_usesurr_enduser             PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_END_USERS',inXFR_GROUP);
           x_usesurr_usergroup           PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_USER_GROUPS',inXFR_GROUP);

           thisRowId                     ROWID;

   BEGIN

           /* This type casting is necessary to use decode stmt */
           OPEN c_imp_endusergroup (x_usesurr_enduser, x_usesurr_usergroup);

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

                   sFSKENDUSER:=NULL; sFSKUSERGROUP:=NULL;
                   FETCH c_imp_endusergroup INTO sFSKENDUSER, sFSKUSERGROUP, thisRowId;
                   sThisFSK1:=sFSKENDUSER;
                   sThisFSK2:=sFSKUSERGROUP;
                   x_imp_endusergroup_f:=c_imp_endusergroup%FOUND;

                   EXIT WHEN NOT x_imp_endusergroup_f;

                   DECLARE
                           CURSOR c_onl_enduser_userid IS
                             SELECT END_USER_ID FROM CZ_END_USERS WHERE ORIG_SYS_REF=sFSKENDUSER;
                   BEGIN
                           OPEN c_onl_enduser_userid;
                           nOnlFSKUserId:=NULL;
                           FETCH c_onl_enduser_userid INTO nOnlFSKUserId;
                           x_onl_enduser_userid_f:=c_onl_enduser_userid%FOUND;
                           CLOSE c_onl_enduser_userid;
                   END;
                   DECLARE
                           CURSOR c_onl_usergroup_groupid IS
                             SELECT USER_GROUP_ID FROM CZ_USER_GROUPS WHERE GROUP_NAME=sFSKUSERGROUP;
                   BEGIN
                           OPEN c_onl_usergroup_groupid ;
                           nOnlFSKGroupId:=NULL;
                           FETCH c_onl_usergroup_groupid INTO nOnlFSKGroupId;
                           x_onl_usergroup_groupid_f:=c_onl_usergroup_groupid%FOUND;
                           CLOSE c_onl_usergroup_groupid ;
                   END;
                   /* Check if this is an insert or update */
                   DECLARE
                           CURSOR c_onl_endusergroup  IS
                             SELECT 'X' FROM CZ_END_USER_GROUPS WHERE END_USER_ID=nOnlFSKUserId AND USER_GROUP_ID=nOnlFSKGroupId;
                   BEGIN
                           OPEN c_onl_endusergroup ;
                           FETCH c_onl_endusergroup INTO p_onl_endusergroup;
                           x_onl_endusergroup_f:=c_onl_endusergroup%FOUND;
                           CLOSE c_onl_endusergroup;
                   END;
                   IF(NOT x_onl_enduser_userid_f OR NOT x_onl_usergroup_groupid_f) THEN
                           BEGIN
                                   /* The record has missing FSKs */
                                   nFailed:=nFailed+1;
                                   IF(NOT x_onl_enduser_userid_f AND x_usesurr_enduser=1 AND sFSKENDUSER IS NULL) THEN
                                                   sRecStatus:='N21';
                                   ELSIF(NOT x_onl_enduser_userid_f AND x_usesurr_enduser=1) THEN
                                                   sRecStatus:='F21';
                                   ELSIF (NOT x_onl_enduser_userid_f  AND x_usesurr_enduser=0 AND sFSKENDUSER IS NULL) THEN
                                                   sRecStatus:='N20';
                                   ELSIF (NOT x_onl_enduser_userid_f  AND x_usesurr_enduser=0) THEN
                                                   sRecStatus:='F20';
                                   ELSIF(NOT x_onl_usergroup_groupid_f AND x_usesurr_usergroup=1 AND sFSKUSERGROUP IS NULL) THEN
                                                   sRecStatus:='N23';
                                   ELSIF(NOT x_onl_usergroup_groupid_f AND x_usesurr_usergroup=1) THEN
                                                   sRecStatus:='F23';
                                   ELSIF(NOT x_onl_usergroup_groupid_f AND x_usesurr_usergroup=0 AND sFSKUSERGROUP IS NULL) THEN
                                                   sRecStatus:='N22';
                                   ELSIF(NOT x_onl_usergroup_groupid_f AND x_usesurr_usergroup=0) THEN
                                                   sRecStatus:='F22';
                                   END IF;
                                   sDisposition:='R';
                           END;
                   ELSE
                           /* Insert or update */
                           BEGIN
                                   IF(sLastFSK1 IS NOT NULL AND sLastFSK1=sThisFSK1 AND
                                      sLastFSK2 IS NOT NULL AND sLastFSK2=sThisFSK2) THEN
                                           /* This is a duplicate record */
                                           sRecStatus:='DUPL';
                                           sDisposition:='R';
                                           nDups:=nDups+1;
                                           nFailed:=nFailed+1;
                                   ELSE
                                           BEGIN
                                                   sRecStatus:='PASS';
                                                   IF( x_onl_endusergroup_f)THEN
                                                           /* Update  */
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


                  UPDATE CZ_IMP_END_USER_GROUP SET
                    END_USER_ID=DECODE(sDISPOSITION,'R',END_USER_ID,nOnlFSKUserId),
                    USER_GROUP_ID=DECODE(sDISPOSITION,'R',USER_GROUP_ID,nOnlFSKGroupId),
                    DISPOSITION=sDisposition,
                    REC_STATUS=sRecStatus
                  WHERE ROWID = thisRowId;

                  sLastFSK1:=sFSKENDUSER;
                  sLastFSK2:=sFSKUSERGROUP;

                   /* Return if MAX_ERR is reached */
                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           CLOSE c_imp_endusergroup;
           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
           x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_END_USER_GROUP',11276);
   END;
END KRS_END_USER_GROUP ;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_USER_GROUP ( inRUN_ID                IN      PLS_INTEGER,
                                   COMMIT_SIZE     IN      PLS_INTEGER,
                                   MAX_ERR         IN      PLS_INTEGER,
                                   INSERTS         OUT NOCOPY     PLS_INTEGER,
                                   UPDATES         OUT NOCOPY     PLS_INTEGER,
                                   FAILED          OUT NOCOPY     PLS_INTEGER,
                                   DUPS            OUT NOCOPY     PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                                   ) IS
BEGIN
   DECLARE
           CURSOR c_imp_usergroup(x_usesurr_usergroup PLS_INTEGER) IS
SELECT DECODE(x_usesurr_usergroup,0, GROUP_NAME,1,USER_STR03), ROWID FROM CZ_IMP_USER_GROUP WHERE REC_STATUS IS NULL  AND RUN_ID = inRUN_ID ORDER BY 1, ROWID;


           /* cursor's data found indicators */
           sImpName                                CZ_IMP_USER_GROUP.GROUP_NAME%TYPE;
           nGroupId                                CZ_IMP_USER_GROUP.USER_GROUP_ID%TYPE;
           sLastFSK                                CZ_IMP_USER_GROUP.GROUP_NAME%TYPE;
           sThisFSK                                CZ_IMP_USER_GROUP.GROUP_NAME%TYPE;
           sRecStatus                              CZ_IMP_USER_GROUP.REC_STATUS%TYPE;
           sDisposition                    CZ_IMP_USER_GROUP.DISPOSITION%TYPE;
           /* Column Vars */
           x_imp_usergroup_f                                       BOOLEAN:=FALSE;
           x_onl_usergroup_groupid_f                       BOOLEAN:=FALSE;
           x_error                                         BOOLEAN:=FALSE;
           /* Internal vars */
           nCommitCount            PLS_INTEGER:=0;                 /*COMMIT buffer index */
           nErrorCount                     PLS_INTEGER:=0;                 /*Error index */
           nInsertCount            PLS_INTEGER:=0;                 /*Inserts */
           nUpdateCount            PLS_INTEGER:=0;                 /*Updates */
           nFailed                 PLS_INTEGER:=0;                 /*Failed records */
           nDups                           PLS_INTEGER:=0;                 /*Duplicate records */
           x_usesurr_usergroup                       PLS_INTEGER:=                 /*Use surrogates */
       											CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_USER_GROUPS',inXFR_GROUP);
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;

     thisRowId                   ROWID;

   BEGIN

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID='OracleSequenceIncr' AND SECTION_NAME='SCHEMA';
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;
    nAllocateCounter:=nAllocateBlock-1;

           /* This type casting is necessary to use decode stmt */
           OPEN c_imp_usergroup (x_usesurr_usergroup) ;

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
                   FETCH c_imp_usergroup INTO sImpName, thisRowId;
                   sThisFSK:=sImpName;
                   x_imp_usergroup_f:=c_imp_usergroup%FOUND;

                   EXIT WHEN NOT x_imp_usergroup_f;

                   /* Check if this is an insert or update */
                   DECLARE
                           CURSOR c_onl_usergroup_groupid  IS
                                   SELECT user_GROUP_ID FROM CZ_USER_GROUPS WHERE group_NAME=sImpName;
                   BEGIN
                           OPEN c_onl_usergroup_groupid ;
                           nGroupId:=NULL;
                           FETCH c_onl_usergroup_groupid INTO nGroupId;
                           x_onl_usergroup_groupid_f:=c_onl_usergroup_groupid%FOUND;
                           CLOSE c_onl_usergroup_groupid;
                   END;

                   /* All foreign keys are resolved */
                   IF(sImpName IS NULL) THEN
                           BEGIN
                                   /* Error */
                                   nFailed:=nFailed+1;
                                   IF (x_usesurr_usergroup=1 ) THEN
                                                   sRecStatus:='N25';
                                   ELSIF (x_usesurr_usergroup=0 ) THEN
                                                   sRecStatus:='N2';
                                   END IF;
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
                                   IF( x_onl_usergroup_groupid_f)THEN
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
              SELECT CZ_USER_GROUPS_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
                                   END IF;
                           END;
                   END IF;

                   UPDATE CZ_IMP_USER_GROUP SET
                     GROUP_NAME=DECODE(sDISPOSITION,'R',GROUP_NAME,sImpName),
                     USER_GROUP_ID=DECODE(sDISPOSITION,'R',USER_GROUP_ID,'I',
                     nNextValue+nAllocateCounter,nGroupId),
                     DISPOSITION=sDisposition, REC_STATUS=sRecStatus
                   WHERE ROWID = thisRowId;
                   sLastFSK:=sImpName;

                   IF (nFailed >= MAX_ERR) THEN
                           EXIT;
                   END IF;
                   sDisposition:=NULL; sRecStatus:=NULL;
           END LOOP;
           CLOSE c_imp_usergroup;
           COMMIT;

           INSERTS:=nInsertCount;
           UPDATES:=nUpdateCount;
           FAILED:=nFailed;
           DUPS:=nDups;
   EXCEPTION
           WHEN OTHERS THEN
                   x_error:=CZ_IMP_ALL.REPORT(SQLERRM,1,'CZ_IMP_AC_KRS.KRS_USER_GROUP',11276);
   END;
END KRS_USER_GROUP;
END CZ_IMP_AC_KRS;

/
