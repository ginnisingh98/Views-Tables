--------------------------------------------------------
--  DDL for Package Body CZ_IMP_IM_XFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_IM_XFR" AS
/*	$Header: cziimxfb.pls 120.7.12010000.2 2010/01/13 10:03:09 kksriram ship $		*/

G_BOM_APPLICATION_ID CONSTANT NUMBER := 702;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE XFR_ITEM_MASTER (	 inRUN_ID 	IN 	PLS_INTEGER,
                              COMMIT_SIZE       IN    PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		   OUT NOCOPY PLS_INTEGER,
					UPDATES		   OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
                                        inXFR_GROUP     IN     VARCHAR2
					) IS
BEGIN
		DECLARE CURSOR c_xfr_itemmaster IS
		 SELECT ITEM_ID,ITEM_TYPE_ID,DESC_TEXT,REF_PART_NBR,QUOTEABLE_FLAG,
                    LEAD_TIME,ITEM_STATUS,RUN_ID,REC_STATUS,DISPOSITION,DELETED_FLAG,
                    CHECKOUT_USER,USER_STR01,USER_STR02,
                    USER_STR03,USER_STR04,USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
                    ORIG_SYS_REF,PRIMARY_UOM_CODE,DECIMAL_QTY_FLAG,
                    SRC_APPLICATION_ID, SRC_TYPE_CODE
             FROM CZ_IMP_ITEM_MASTER
             WHERE CZ_IMP_ITEM_MASTER.RUN_ID = inRUN_ID AND REC_STATUS='PASS';

			x_xfr_itemmaster_f		BOOLEAN:=FALSE;
			x_error							BOOLEAN:=FALSE;

			p_xfr_itemmaster 	c_xfr_itemmaster%ROWTYPE;

			/* Internal vars */
			nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
			nInsertCount		PLS_INTEGER:=0;			/*Inserts */
			nUpdateCount		PLS_INTEGER:=0;			/*Updates */

			NOUPDATE_DESC_TEXT               NUMBER;
			NOUPDATE_REF_PART_NBR            NUMBER;
			NOUPDATE_ORIG_SYS_REF            NUMBER;
			NOUPDATE_QUOTEABLE_FLAG          NUMBER;
			NOUPDATE_LEAD_TIME               NUMBER;
			NOUPDATE_ITEM_STATUS             NUMBER;
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
                        NOUPDATE_PRIMARY_UOM_CODE        NUMBER;
                  NOUPDATE_ITEM_TYPE_ID                  NUMBER;
                  NOUPDATE_DECIMAL_QTY_FLAG              NUMBER;

		-- Make sure that the DataSet exists
		BEGIN

		-- Get the Update Flags for each column
                        NOUPDATE_DESC_TEXT               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','DESC_TEXT',inXFR_GROUP);
                        NOUPDATE_REF_PART_NBR            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','REF_PART_NBR',inXFR_GROUP);
			NOUPDATE_ORIG_SYS_REF            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','ORIG_SYS_REF',inXFR_GROUP);
                        NOUPDATE_QUOTEABLE_FLAG          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','QUOTEABLE_FLAG',inXFR_GROUP);
                        NOUPDATE_LEAD_TIME               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','LEAD_TIME',inXFR_GROUP);
			NOUPDATE_ITEM_STATUS             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','ITEM_STATUS',inXFR_GROUP);
			NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','DELETED_FLAG',inXFR_GROUP);
			NOUPDATE_USER_STR01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_STR01',inXFR_GROUP);
			NOUPDATE_USER_STR02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_STR02',inXFR_GROUP);
			NOUPDATE_USER_STR03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_STR03',inXFR_GROUP);
			NOUPDATE_USER_STR04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_STR04',inXFR_GROUP);
			NOUPDATE_USER_NUM01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_NUM01',inXFR_GROUP);
			NOUPDATE_USER_NUM02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_NUM02',inXFR_GROUP);
			NOUPDATE_USER_NUM03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_NUM03',inXFR_GROUP);
			NOUPDATE_USER_NUM04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','USER_NUM04',inXFR_GROUP);
			NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','CREATION_DATE',inXFR_GROUP);
			NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','LAST_UPDATE_DATE',inXFR_GROUP);
			NOUPDATE_CREATED_BY          	   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','CREATED_BY',inXFR_GROUP);
			NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','LAST_UPDATED_BY',inXFR_GROUP);
			NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','SECURITY_MASK',inXFR_GROUP);
			NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','CHECKOUT_USER',inXFR_GROUP);
			NOUPDATE_PRIMARY_UOM_CODE        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','PRIMARY_UOM_CODE',inXFR_GROUP);
			NOUPDATE_ITEM_TYPE_ID            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','ITEM_TYPE_ID',inXFR_GROUP);
			NOUPDATE_DECIMAL_QTY_FLAG        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_MASTERS','DECIMAL_QTY_FLAG',inXFR_GROUP);

			OPEN c_xfr_itemmaster ;

			LOOP
				IF (nCommitCount>= COMMIT_SIZE) THEN
					BEGIN
						COMMIT;
						nCommitCount:=0;
					END;
				ELSE
					nCOmmitCount:=nCommitCount+1;
				END IF;
				FETCH c_xfr_itemmaster  INTO	p_xfr_itemmaster;
				x_xfr_itemmaster_f:=c_xfr_itemmaster%FOUND;
				EXIT WHEN NOT x_xfr_itemmaster_f;

                                IF ( FAILED >= Max_Err) THEN
                                   x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_XFR.XFR_ITEM_MASTER:MAX',11276,inRun_Id);
                                   RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
                                END IF;

				IF (p_xfr_itemmaster.DISPOSITION = 'I') THEN
				 BEGIN
					INSERT INTO CZ_ITEM_MASTERS
                                     (ITEM_ID,ITEM_TYPE_ID,DESC_TEXT,REF_PART_NBR,
                                      QUOTEABLE_FLAG,LEAD_TIME,ITEM_STATUS,USER_NUM01,
                                      USER_NUM02,USER_NUM03,USER_NUM04,USER_STR01,
                                      USER_STR02,USER_STR03,USER_STR04,CREATION_DATE,LAST_UPDATE_DATE,
                                      DELETED_FLAG,CREATED_BY,LAST_UPDATED_BY,
                                      SECURITY_MASK,CHECKOUT_USER,ORIG_SYS_REF,
                                      PRIMARY_UOM_CODE,DECIMAL_QTY_FLAG,
                                      SRC_APPLICATION_ID, SRC_TYPE_CODE)
                                    VALUES
                                     (p_xfr_itemmaster.ITEM_ID,p_xfr_itemmaster.ITEM_TYPE_ID,
                                      p_xfr_itemmaster.DESC_TEXT,p_xfr_itemmaster.REF_PART_NBR,
                                      p_xfr_itemmaster.QUOTEABLE_FLAG,p_xfr_itemmaster.LEAD_TIME,
                                      p_xfr_itemmaster.ITEM_STATUS,p_xfr_itemmaster.USER_NUM01,
                                      p_xfr_itemmaster.USER_NUM02,p_xfr_itemmaster.USER_NUM03,
                                      p_xfr_itemmaster.USER_NUM04,p_xfr_itemmaster.USER_STR01,
                                      p_xfr_itemmaster.USER_STR02,p_xfr_itemmaster.USER_STR03,
                                      p_xfr_itemmaster.USER_STR04,SYSDATE,SYSDATE,
                                      p_xfr_itemmaster.DELETED_FLAG,
                                      1,1,NULL,
                                      p_xfr_itemmaster.CHECKOUT_USER,
                                      p_xfr_itemmaster.ORIG_SYS_REF,
                                      p_xfr_itemmaster.PRIMARY_UOM_CODE,
                                      NVL(p_xfr_itemmaster.DECIMAL_QTY_FLAG,'0'),
                                      NVL(p_xfr_itemmaster.SRC_APPLICATION_ID,cnDefSrcAppId),
                                      NVL(p_xfr_itemmaster.SRC_TYPE_CODE,cnDefSrcTypeCode));
					nInsertCount:=nInsertCount+1;

                                        UPDATE CZ_IMP_item_master
                                        SET REC_STATUS='OK'
                                        WHERE ITEM_ID=p_xfr_itemmaster.ITEM_ID AND RUN_ID=inRUN_ID
                                        AND DISPOSITION='I';

				 EXCEPTION
					WHEN OTHERS THEN
						FAILED:=FAILED +1;

                                                UPDATE CZ_IMP_item_master
                                                SET REC_STATUS='ERR'
                                                WHERE ITEM_ID=p_xfr_itemmaster.ITEM_ID AND RUN_ID=inRUN_ID
                                                AND DISPOSITION='I';

						x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_MASTER',11276,inRUN_ID);
				 END ;
				ELSIF (p_xfr_itemmaster.DISPOSITION = 'M') THEN
		                BEGIN
				 UPDATE CZ_ITEM_MASTERS SET
                                 ITEM_TYPE_ID=DECODE(NOUPDATE_ITEM_TYPE_ID,0,p_xfr_itemmaster.ITEM_TYPE_ID,ITEM_TYPE_ID),
			         DESC_TEXT=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_itemmaster.DESC_TEXT,DESC_TEXT),
 				 REF_PART_NBR=DECODE(NOUPDATE_REF_PART_NBR,0, p_xfr_itemmaster.REF_PART_NBR,REF_PART_NBR),
 				 ORIG_SYS_REF=DECODE(NOUPDATE_ORIG_SYS_REF,0, p_xfr_itemmaster.ORIG_SYS_REF,ORIG_SYS_REF),
				 QUOTEABLE_FLAG=DECODE(NOUPDATE_QUOTEABLE_FLAG,0,p_xfr_itemmaster.QUOTEABLE_FLAG,QUOTEABLE_FLAG),
				 LEAD_TIME=DECODE(NOUPDATE_LEAD_TIME,0,p_xfr_itemmaster.LEAD_TIME,LEAD_TIME),
				 ITEM_STATUS=DECODE(NOUPDATE_ITEM_STATUS,0,p_xfr_itemmaster.ITEM_STATUS,ITEM_STATUS),
				 DELETED_FLAG=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_itemmaster.DELETED_FLAG,DELETED_FLAG),
				 USER_NUM01=DECODE(NOUPDATE_USER_NUM01,0,p_xfr_itemmaster.USER_NUM01,USER_NUM01),
				 USER_NUM02=DECODE(NOUPDATE_USER_NUM02,0,p_xfr_itemmaster.USER_NUM02,USER_NUM02),
				 USER_NUM03=DECODE(NOUPDATE_USER_NUM03,0,p_xfr_itemmaster.USER_NUM03,USER_NUM03),
				 USER_NUM04=DECODE(NOUPDATE_USER_NUM04,0,p_xfr_itemmaster.USER_NUM04,USER_NUM04),
				 USER_STR01=DECODE(NOUPDATE_USER_STR01,0,p_xfr_itemmaster.USER_STR01,USER_STR01),
				 USER_STR02=DECODE(NOUPDATE_USER_STR02,0,p_xfr_itemmaster.USER_STR02,USER_STR02),
				 USER_STR03=DECODE(NOUPDATE_USER_STR03,0,p_xfr_itemmaster.USER_STR03,USER_STR03),
				 USER_STR04=DECODE(NOUPDATE_USER_STR04,0,p_xfr_itemmaster.USER_STR04,USER_STR04),
				 CREATION_DATE=DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
				 LAST_UPDATE_DATE=DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
				 CREATED_BY=DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
				 LAST_UPDATED_BY=DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
				 SECURITY_MASK=DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
                                 CHECKOUT_USER=DECODE(NOUPDATE_CHECKOUT_USER,0,p_xfr_itemmaster.CHECKOUT_USER,CHECKOUT_USER),
                                 PRIMARY_UOM_CODE=DECODE(NOUPDATE_PRIMARY_UOM_CODE,0,p_xfr_itemmaster.PRIMARY_UOM_CODE,PRIMARY_UOM_CODE),
                                 SRC_APPLICATION_ID=NVL(p_xfr_itemmaster.SRC_APPLICATION_ID,cnDefSrcAppId),
                                 SRC_TYPE_CODE=NVL(p_xfr_itemmaster.SRC_TYPE_CODE,cnDefSrcTypeCode),
                                 DECIMAL_QTY_FLAG=DECODE(NOUPDATE_DECIMAL_QTY_FLAG,0,p_xfr_itemmaster.DECIMAL_QTY_FLAG,DECIMAL_QTY_FLAG)
				 WHERE ITEM_ID=p_xfr_itemmaster.ITEM_ID;
 				  IF(SQL%NOTFOUND) THEN
					FAILED:=FAILED+1;
				  ELSE
					nUpdateCount:=nUpdateCount+1;

                                          UPDATE CZ_IMP_item_master
                                          SET REC_STATUS='OK'
                                          WHERE ITEM_ID=p_xfr_itemmaster.ITEM_ID AND RUN_ID=inRUN_ID
                                          AND DISPOSITION='M';

				  END IF;
				EXCEPTION
					WHEN OTHERS THEN
				  	 FAILED:=FAILED +1;

                                          UPDATE CZ_IMP_item_master
                                          SET REC_STATUS='ERR'
                                          WHERE ITEM_ID=p_xfr_itemmaster.ITEM_ID AND RUN_ID=inRUN_ID
                                          AND DISPOSITION='M';

  					  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_MASTER',11276,inRUN_ID);
				END ;

				END IF;

			END LOOP;
			CLOSE c_xfr_itemmaster;
			COMMIT;
			INSERTS:=nInsertCount;
			UPDATES:=nUpdateCount;
		EXCEPTION
                 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                  RAISE;
		 WHEN OTHERS THEN
 		  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_MASTER',11276,inRUN_ID);
		END;
END XFR_ITEM_MASTER;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE XFR_ITEM_PROPERTY_VALUE (     inRUN_ID        IN      PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					)IS
		CURSOR c_xfr_itempropertyvalue IS -- sselahi
                SELECT PROPERTY_ID,ITEM_ID,PROPERTY_VALUE,PROPERTY_NUM_VALUE,
                RUN_ID,REC_STATUS,DISPOSITION,DELETED_FLAG,
                CHECKOUT_USER,USER_STR01,USER_STR02,USER_STR03,USER_STR04,
                USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
                ORIG_SYS_REF, NVL(FSK_PROPERTY_1_1, FSK_PROPERTY_1_EXT) AS FSK_PROPERTY,
                NVL(FSK_ITEMMASTER_2_1, FSK_ITEMMASTER_2_EXT) AS FSK_ITEMMASTER,
                SRC_APPLICATION_ID
                FROM CZ_IMP_ITEM_PROPERTY_VALUE WHERE
                RUN_ID=inRUN_ID AND REC_STATUS IN ('PASS','F3X');

		x_xfr_itempropertyvalue_f		BOOLEAN:=FALSE;
		x_error							BOOLEAN:=FALSE;

		p_xfr_itempropertyvalue	c_xfr_itempropertyvalue%ROWTYPE;

		/* Internal vars */
		nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
		nInsertCount		PLS_INTEGER:=0;			/*Inserts */
		nUpdateCount		PLS_INTEGER:=0;			/*Updates */

                NOUPDATE_PROPERTY_VALUE          NUMBER;
		NOUPDATE_DELETED_FLAG            NUMBER;
		NOUPDATE_CREATION_DATE           NUMBER;
		NOUPDATE_LAST_UPDATE_DATE        NUMBER;
                NOUPDATE_CREATED_BY              NUMBER;
		NOUPDATE_LAST_UPDATED_BY         NUMBER;
		NOUPDATE_SECURITY_MASK           NUMBER;
		NOUPDATE_CHECKOUT_USER           NUMBER;
                NOUPDATE_PROPERTY_NUM_VALUE      NUMBER;   -- sselahi

                sOrigSysRef             cz_item_property_values.orig_sys_ref%TYPE;
                l_msg                            VARCHAR2(2000);

	-- Make sure that the DataSet exists
BEGIN

-- Get the Update Flags for each column --sselahi
   NOUPDATE_PROPERTY_VALUE          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','PROPERTY_VALUE',inXFR_GROUP);
   NOUPDATE_PROPERTY_NUM_VALUE          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','PROPERTY_NUM_VALUE',inXFR_GROUP);
   NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','DELETED_FLAG',inXFR_GROUP);
   NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','CREATION_DATE',inXFR_GROUP);
   NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','LAST_UPDATE_DATE',inXFR_GROUP);
   NOUPDATE_CREATED_BY              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','CREATED_BY',inXFR_GROUP);
   NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','LAST_UPDATED_BY',inXFR_GROUP);
NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','SECURITY_MASK',inXFR_GROUP);
NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_PROPERTY_VALUES','CHECKOUT_USER',inXFR_GROUP);


  OPEN c_xfr_itempropertyvalue ;
  LOOP
	IF (nCommitCount>= COMMIT_SIZE) THEN
          COMMIT;
          nCommitCount:=0;
	ELSE
          nCOmmitCount:=nCommitCount+1;
        END IF;
        FETCH c_xfr_itempropertyvalue  INTO	p_xfr_itempropertyvalue;

	x_xfr_itempropertyvalue_f:=c_xfr_itempropertyvalue%FOUND;
	EXIT WHEN NOT x_xfr_itempropertyvalue_f;
        IF ( FAILED >= Max_Err) THEN
            x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),
                                         1,'CZ_IMP_IM_XFR.XFR_ITEM_PROPERTY_VALUE:MAX',11276,inRun_Id);
            RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
        END IF;

        IF(p_xfr_itempropertyvalue.ORIG_SYS_REF IS NOT NULL)THEN
          sOrigSysRef := p_xfr_itempropertyvalue.ORIG_SYS_REF;
        ELSE
          sOrigSysRef := p_xfr_itempropertyvalue.FSK_ITEMMASTER || ':' || p_xfr_itempropertyvalue.FSK_PROPERTY;
        END IF;

	IF (p_xfr_itempropertyvalue.DISPOSITION = 'I') THEN
		BEGIN
			INSERT INTO CZ_ITEM_PROPERTY_VALUES (PROPERTY_ID,ITEM_ID,
			PROPERTY_VALUE,PROPERTY_NUM_VALUE, --sselahi
			/* USER_NUM01,USER_NUM02, USER_NUM03,
			USER_NUM04,USER_STR01,USER_STR02,USER_STR03,USER_STR04,
			*/
			CREATION_DATE, LAST_UPDATE_DATE, DELETED_FLAG,
			CREATED_BY, LAST_UPDATED_BY, SECURITY_MASK,
			CHECKOUT_USER, ORIG_SYS_REF, SRC_APPLICATION_ID) VALUES
		        (p_xfr_itempropertyvalue.PROPERTY_ID,p_xfr_itempropertyvalue.ITEM_ID,
		        p_xfr_itempropertyvalue.PROPERTY_VALUE,
                        p_xfr_itempropertyvalue.PROPERTY_NUM_VALUE,
		        /*p_xfr_itempropertyvalue.USER_NUM01,p_xfr_itempropertyvalue.USER_NUM02,
		        p_xfr_itempropertyvalue.USER_NUM03,p_xfr_itempropertyvalue.USER_NUM04,
		        p_xfr_itempropertyvalue.USER_STR01,p_xfr_itempropertyvalue.USER_STR02,
		        p_xfr_itempropertyvalue.USER_STR03,p_xfr_itempropertyvalue.USER_STR04,*/
		        SYSDATE, SYSDATE, p_xfr_itempropertyvalue.DELETED_FLAG , 1, 1, NULL,
		        p_xfr_itempropertyvalue.CHECKOUT_USER, sOrigSysRef, p_xfr_itempropertyvalue.SRC_APPLICATION_ID);

 			nInsertCount:=nInsertCount+1;

                        UPDATE CZ_IMP_item_property_value
                        SET REC_STATUS='OK'
                        WHERE PROPERTY_ID=p_xfr_itempropertyvalue.PROPERTY_ID
                        AND ITEM_ID=p_xfr_itempropertyvalue.ITEM_ID AND RUN_ID=inRUN_ID
                        AND DISPOSITION='I' AND ORIG_SYS_REF=p_xfr_itempropertyvalue.ORIG_SYS_REF;

		EXCEPTION
			WHEN OTHERS THEN
				FAILED:=FAILED +1;

                                UPDATE CZ_IMP_item_property_value
                                SET REC_STATUS='ERR'
                                WHERE PROPERTY_ID=p_xfr_itempropertyvalue.PROPERTY_ID
                                AND ITEM_ID=p_xfr_itempropertyvalue.ITEM_ID AND RUN_ID=inRUN_ID
                                AND DISPOSITION='I' AND ORIG_SYS_REF=p_xfr_itempropertyvalue.ORIG_SYS_REF;

			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_PROPERTY_VALUE',11276,inRUN_ID);
		END ;
	ELSIF (p_xfr_itempropertyvalue.DISPOSITION = 'M' OR
             (p_xfr_itempropertyvalue.DISPOSITION = 'R' AND p_xfr_itempropertyvalue.REC_STATUS = 'F3X'))THEN
          BEGIN -- sselahi
  	   UPDATE CZ_ITEM_PROPERTY_VALUES SET
           PROPERTY_VALUE=DECODE(NOUPDATE_PROPERTY_VALUE,0,p_xfr_itempropertyvalue.PROPERTY_VALUE,PROPERTY_VALUE),
           PROPERTY_NUM_VALUE=DECODE(NOUPDATE_PROPERTY_NUM_VALUE,0,p_xfr_itempropertyvalue.PROPERTY_NUM_VALUE,PROPERTY_NUM_VALUE),
           DELETED_FLAG=		        DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_itempropertyvalue.DELETED_FLAG ,DELETED_FLAG),
		CREATION_DATE=			DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
		LAST_UPDATE_DATE=			DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
		CREATED_BY=			DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
		LAST_UPDATED_BY=		DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
		SECURITY_MASK=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
		CHECKOUT_USER=		DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER),
                ORIG_SYS_REF = sOrigSysRef
		WHERE PROPERTY_ID=p_xfr_itempropertyvalue.PROPERTY_ID AND
		ITEM_ID=p_xfr_itempropertyvalue.ITEM_ID;

		IF(SQL%NOTFOUND) THEN
			FAILED:=FAILED+1;
                        l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_NOTFOUND_IPV','OSR', p_xfr_itempropertyvalue.orig_sys_ref);
			x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IM_XFR.XFR_ITEM_PROPERTY_VALUE',11276,inRUN_ID);
		ELSE
                           IF(p_xfr_itempropertyvalue.REC_STATUS<>'F3X')THEN nUpdateCount:=nUpdateCount+1; END IF;

                               UPDATE CZ_IMP_item_property_value
                               SET REC_STATUS=DECODE(p_xfr_itempropertyvalue.REC_STATUS,'PASS','OK',p_xfr_itempropertyvalue.REC_STATUS)
                               WHERE PROPERTY_ID=p_xfr_itempropertyvalue.PROPERTY_ID
                               AND ITEM_ID=p_xfr_itempropertyvalue.ITEM_ID AND RUN_ID=inRUN_ID
                               AND DISPOSITION='M' AND ORIG_SYS_REF=p_xfr_itempropertyvalue.ORIG_SYS_REF;

                END IF;
	  EXCEPTION
		WHEN OTHERS THEN
			FAILED:=FAILED +1;

                         UPDATE CZ_IMP_item_property_value
                         SET REC_STATUS='ERR'
                         WHERE PROPERTY_ID=p_xfr_itempropertyvalue.PROPERTY_ID
                         AND ITEM_ID=p_xfr_itempropertyvalue.ITEM_ID AND RUN_ID=inRUN_ID
                         AND DISPOSITION='M' AND ORIG_SYS_REF=p_xfr_itempropertyvalue.ORIG_SYS_REF;

			x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_PROPERTY_VALUE',11276,inRUN_ID);
 	  END;

    END IF;
  END LOOP;
  CLOSE c_xfr_itempropertyvalue;
  COMMIT;
  INSERTS:=nInsertCount;
  UPDATES:=nUpdateCount;
EXCEPTION
   WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
     RAISE;
   WHEN OTHERS THEN
     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_PROPERTY_VALUE',11276,inRUN_ID);
END XFR_ITEM_PROPERTY_VALUE;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE XFR_ITEM_TYPE (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
				)IS
BEGIN
		DECLARE CURSOR c_xfr_itemtype IS
                          SELECT  ITEM_TYPE_ID,DESC_TEXT,NAME,RUN_ID ,REC_STATUS ,DISPOSITION ,DELETED_FLAG ,
                           CHECKOUT_USER, USER_STR01,USER_STR02,USER_STR03,
                           USER_STR04,USER_NUM01,USER_NUM02, USER_NUM03, USER_NUM04,ORIG_SYS_REF,SRC_APPLICATION_ID
                          FROM CZ_IMP_ITEM_TYPE WHERE CZ_IMP_ITEM_TYPE.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
			x_xfr_itemtype_f		BOOLEAN:=FALSE;
			x_error							BOOLEAN:=FALSE;

			p_xfr_itemtype 	c_xfr_itemtype%ROWTYPE;

			/* Internal vars */
			nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
			nInsertCount		PLS_INTEGER:=0;			/*Inserts */
			nUpdateCount		PLS_INTEGER:=0;			/*Updates */

			NOUPDATE_DESC_TEXT               NUMBER;
                        NOUPDATE_NAME                    NUMBER;
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

		-- Make sure that the DataSet exists
		BEGIN
		-- Get the Update Flags for each column
			NOUPDATE_DESC_TEXT    		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','DESC_TEXT',inXFR_GROUP);
			NOUPDATE_NAME			   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','NAME',inXFR_GROUP);
			NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','DELETED_FLAG',inXFR_GROUP);
			NOUPDATE_USER_STR01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_STR01',inXFR_GROUP);
			NOUPDATE_USER_STR02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_STR02',inXFR_GROUP);
			NOUPDATE_USER_STR03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_STR03',inXFR_GROUP);
			NOUPDATE_USER_STR04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_STR04',inXFR_GROUP);
			NOUPDATE_USER_NUM01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_NUM01',inXFR_GROUP);
			NOUPDATE_USER_NUM02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_NUM02',inXFR_GROUP);
			NOUPDATE_USER_NUM03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_NUM03',inXFR_GROUP);
			NOUPDATE_USER_NUM04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','USER_NUM04',inXFR_GROUP);
			NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','CREATION_DATE',inXFR_GROUP);
			NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','LAST_UPDATE_DATE',inXFR_GROUP);
			NOUPDATE_CREATED_BY          	   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','CREATED_BY',inXFR_GROUP);
			NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','LAST_UPDATED_BY',inXFR_GROUP);
			NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','SECURITY_MASK',inXFR_GROUP);
			NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_ITEM_TYPES','CHECKOUT_USER',inXFR_GROUP);
			OPEN c_xfr_itemtype ;

			LOOP
				IF (nCommitCount>= COMMIT_SIZE) THEN
					BEGIN
						COMMIT;
						nCommitCount:=0;
					END;
				ELSE
					nCOmmitCount:=nCommitCount+1;
				END IF;
				FETCH c_xfr_itemtype  INTO	p_xfr_itemtype;

				x_xfr_itemtype_f:=c_xfr_itemtype%FOUND;
				EXIT WHEN NOT x_xfr_itemtype_f;
                                IF ( FAILED >= Max_Err) THEN
                                   x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_XFR.XFR_ITEM_TYPE:MAX',11276,inRun_Id);
                                   RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
                                END IF;

				IF (p_xfr_itemtype.DISPOSITION = 'I') THEN
					BEGIN
						INSERT INTO CZ_ITEM_TYPES (ITEM_TYPE_ID,DESC_TEXT,NAME,USER_NUM01,USER_NUM02,
                                     USER_NUM03,USER_NUM04,USER_STR01,USER_STR02,USER_STR03,USER_STR04,
                                     CREATION_DATE, LAST_UPDATE_DATE, DELETED_FLAG,
                                     CREATED_BY, LAST_UPDATED_BY, SECURITY_MASK,
                                     CHECKOUT_USER,ORIG_SYS_REF,SRC_APPLICATION_ID) VALUES
					      (p_xfr_itemtype.ITEM_TYPE_ID,p_xfr_itemtype.DESC_TEXT,p_xfr_itemtype.NAME,
                                     p_xfr_itemtype.USER_NUM01,p_xfr_itemtype.USER_NUM02,p_xfr_itemtype.USER_NUM03,
                                     p_xfr_itemtype.USER_NUM04, p_xfr_itemtype.USER_STR01,p_xfr_itemtype.USER_STR02,
                                     p_xfr_itemtype.USER_STR03,p_xfr_itemtype.USER_STR04, SYSDATE, SYSDATE,
                                     p_xfr_itemtype.DELETED_FLAG,
                                     1, 1, NULL, p_xfr_itemtype.CHECKOUT_USER,
                                     p_xfr_itemtype.ORIG_SYS_REF,p_xfr_itemtype.SRC_APPLICATION_ID);
						nInsertCount:=nInsertCount+1;
                                                BEGIN
                                                  UPDATE CZ_IMP_item_type
                                                     SET REC_STATUS='OK'
                                                   WHERE ITEM_TYPE_ID=p_xfr_itemtype.ITEM_TYPE_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='I';
                                                END;
					EXCEPTION
						WHEN OTHERS THEN
							FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_item_type
                                                              SET REC_STATUS='ERR'
                                                            WHERE ITEM_TYPE_ID=p_xfr_itemtype.ITEM_TYPE_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='I';
                                                        END;
							x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_TYPE',11276,inRUN_ID);
					END ;
				ELSIF (p_xfr_itemtype.DISPOSITION = 'M') THEN
					BEGIN
						UPDATE CZ_ITEM_TYPES SET		DESC_TEXT=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_itemtype.DESC_TEXT, DESC_TEXT),
								NAME=DECODE(NOUPDATE_NAME,0,p_xfr_itemtype.NAME,NAME),
								DELETED_FLAG=		DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_itemtype.DELETED_FLAG ,DELETED_FLAG),
								USER_NUM01=			DECODE(NOUPDATE_USER_NUM01,  0,p_xfr_itemtype.USER_NUM01,USER_NUM01),
								USER_NUM02=			DECODE(NOUPDATE_USER_NUM02,  0,p_xfr_itemtype.USER_NUM02,USER_NUM02),
								USER_NUM03=			DECODE(NOUPDATE_USER_NUM03,  0,p_xfr_itemtype.USER_NUM03,USER_NUM03),
								USER_NUM04=			DECODE(NOUPDATE_USER_NUM04,  0,p_xfr_itemtype.USER_NUM04,USER_NUM04),
								USER_STR01=			DECODE(NOUPDATE_USER_STR01,  0,p_xfr_itemtype.USER_STR01,USER_STR01),
								USER_STR02=			DECODE(NOUPDATE_USER_STR02,  0,p_xfr_itemtype.USER_STR02,USER_STR02),
								USER_STR03=			DECODE(NOUPDATE_USER_STR03,  0,p_xfr_itemtype.USER_STR03,USER_STR03),
								USER_STR04=			DECODE(NOUPDATE_USER_STR04,  0,p_xfr_itemtype.USER_STR04,USER_STR04),
								CREATION_DATE=			DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
								LAST_UPDATE_DATE=			DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
								CREATED_BY=			DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
								LAST_UPDATED_BY=		DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
								SECURITY_MASK=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
								CHECKOUT_USER=		DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER)
								WHERE ITEM_TYPE_ID=p_xfr_itemtype.ITEM_TYPE_ID;
						IF(SQL%NOTFOUND) THEN
							FAILED:=FAILED+1;
						ELSE
							nUpdateCount:=nUpdateCount+1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_item_type
                                                              SET REC_STATUS='OK'
                                                            WHERE ITEM_TYPE_ID=p_xfr_itemtype.ITEM_TYPE_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_item_type
                                                              SET REC_STATUS='ERR'
                                                            WHERE ITEM_TYPE_ID=p_xfr_itemtype.ITEM_TYPE_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
							x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_TYPE',11276,inRUN_ID);
					END ;

				END IF;

			END LOOP;
			CLOSE c_xfr_itemtype;
			COMMIT;
			INSERTS:=nInsertCount;
			UPDATES:=nUpdateCount;
		EXCEPTION
                 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                  RAISE;
		 WHEN OTHERS THEN
		  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_TYPE',11276,inRUN_ID);
		END;
END XFR_ITEM_TYPE;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE XFR_ITEM_TYPE_PROPERTY (      inRUN_ID        IN      PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
					)IS

BEGIN
  DECLARE CURSOR c_xfr_itemtypeprop IS
   SELECT ITEM_TYPE_ID,PROPERTY_ID,RUN_ID,REC_STATUS ,DISPOSITION ,DELETED_FLAG,
          CHECKOUT_USER, USER_STR01,USER_STR02,USER_STR03,USER_STR04,USER_NUM01,
          USER_NUM02,USER_NUM03, USER_NUM04, ORIG_SYS_REF,
          NVL(FSK_ITEMTYPE_1_1, FSK_ITEMTYPE_1_EXT) AS FSK_ITEMTYPE,
          NVL(FSK_PROPERTY_2_1, FSK_PROPERTY_2_EXT) AS FSK_PROPERTY,
          SRC_APPLICATION_ID
  FROM CZ_IMP_ITEM_TYPE_PROPERTY
WHERE CZ_IMP_ITEM_TYPE_PROPERTY.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
			x_xfr_itemtypeprop_f		BOOLEAN:=FALSE;
			x_error				BOOLEAN:=FALSE;

			p_xfr_itemtypeprop 	c_xfr_itemtypeprop%ROWTYPE;

			/* Internal vars */
			nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
			nInsertCount		PLS_INTEGER:=0;			/*Inserts */
			nUpdateCount		PLS_INTEGER:=0;			/*Updates */
			NOUPDATE_DELETED_FLAG            NUMBER;
			NOUPDATE_CREATION_DATE           NUMBER;
			NOUPDATE_LAST_UPDATE_DATE        NUMBER;
                  NOUPDATE_CREATED_BY              NUMBER;
			NOUPDATE_LAST_UPDATED_BY         NUMBER;
			NOUPDATE_SECURITY_MASK           NUMBER;
			NOUPDATE_CHECKOUT_USER           NUMBER;

                  sOrigSysRef             cz_item_type_properties.orig_sys_ref%TYPE;

		-- Make sure that the DataSet exists
		BEGIN
		-- Get the Update Flags for each column
			NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','DELETED_FLAG',inXFR_GROUP);
			NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','CREATION_DATE',inXFR_GROUP);
			NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','LAST_UPDATE_DATE',inXFR_GROUP);
                        NOUPDATE_CREATED_BY              := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','CREATED_BY',inXFR_GROUP);
			NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','LAST_UPDATED_BY',inXFR_GROUP);
			NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','SECURITY_MASK',inXFR_GROUP);
			NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('ITEM_TYPE_PROPERTY','CHECKOUT_USER',inXFR_GROUP);

			OPEN c_xfr_itemtypeprop ;

			LOOP
				IF (nCommitCount>= COMMIT_SIZE) THEN
					BEGIN
						COMMIT;
						nCommitCount:=0;
					END;
				ELSE
					nCOmmitCount:=nCommitCount+1;
				END IF;
				FETCH c_xfr_itemtypeprop  INTO	p_xfr_itemtypeprop;

				x_xfr_itemtypeprop_f:=c_xfr_itemtypeprop%FOUND;
				EXIT WHEN NOT x_xfr_itemtypeprop_f;
                                IF ( FAILED >= Max_Err) THEN
                                   x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_XFR.XFR_ITEM_TYPE_PROPERTY:MAX',11276,inRun_Id);
                                   RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
                                END IF;

IF(p_xfr_itemtypeprop.ORIG_SYS_REF IS NOT NULL)THEN sOrigSysRef := p_xfr_itemtypeprop.ORIG_SYS_REF;
ELSE sOrigSysRef := p_xfr_itemtypeprop.FSK_ITEMTYPE || ':' || p_xfr_itemtypeprop.FSK_PROPERTY;
END IF;

				IF (p_xfr_itemtypeprop.DISPOSITION = 'I') THEN
					BEGIN
INSERT INTO CZ_ITEM_TYPE_PROPERTIES (ITEM_TYPE_ID,PROPERTY_ID,
/* USER_NUM01,USER_NUM02, USER_NUM03,USER_NUM04,USER_STR01,USER_STR02,USER_STR03,USER_STR04,*/
CREATION_DATE, LAST_UPDATE_DATE, DELETED_FLAG ,CREATED_BY, LAST_UPDATED_BY,
 SECURITY_MASK, ORIG_SYS_REF, SRC_APPLICATION_ID) VALUES
(p_xfr_itemtypeprop.ITEM_TYPE_ID,p_xfr_itemtypeprop.PROPERTY_ID,
/* p_xfr_itemtypeprop.USER_NUM01,p_xfr_itemtypeprop.USER_NUM02,p_xfr_itemtypeprop.USER_NUM03,p_xfr_itemtypeprop.USER_NUM04,
 p_xfr_itemtypeprop.USER_STR01,p_xfr_itemtypeprop.USER_STR02,p_xfr_itemtypeprop.USER_STR03,p_xfr_itemtypeprop.USER_STR04,
*/ SYSDATE, SYSDATE, p_xfr_itemtypeprop.DELETED_FLAG , 1, 1, NULL, sOrigSysRef, p_xfr_itemtypeprop.SRC_APPLICATION_ID);
						nInsertCount:=nInsertCount+1;
                                                BEGIN
                                                  UPDATE CZ_IMP_item_type_property
                                                     SET REC_STATUS='OK'
                                                   WHERE ITEM_TYPE_ID=p_xfr_itemtypeprop.ITEM_TYPE_ID
                                                     AND PROPERTY_ID=p_xfr_itemtypeprop.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='I';
                                                END;
					EXCEPTION
						WHEN OTHERS THEN
							FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_item_type_property
                                                              SET REC_STATUS='ERR'
                                                            WHERE ITEM_TYPE_ID=p_xfr_itemtypeprop.ITEM_TYPE_ID
                                                              AND PROPERTY_ID=p_xfr_itemtypeprop.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='I';
                                                        END;
							x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_TYPE_PROP',11276,inRUN_ID);
					END ;
				ELSIF (p_xfr_itemtypeprop.DISPOSITION = 'M') THEN
					BEGIN
						UPDATE CZ_ITEM_TYPE_PROPERTIES SET
												DELETED_FLAG=		DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_itemtypeprop.DELETED_FLAG ,DELETED_FLAG),
											/*	USER_NUM01=			DECODE(NOUPDATE_USER_NUM01,  0,p_xfr_itemtypeprop.USER_NUM01,USER_NUM01),
												USER_NUM02=			DECODE(NOUPDATE_USER_NUM02,  0,p_xfr_itemtypeprop.USER_NUM02,USER_NUM02),
												USER_NUM03=			DECODE(NOUPDATE_USER_NUM03,  0,p_xfr_itemtypeprop.USER_NUM03,USER_NUM03),
												USER_NUM04=			DECODE(NOUPDATE_USER_NUM04,  0,p_xfr_itemtypeprop.USER_NUM04,USER_NUM04),
												USER_STR01=			DECODE(NOUPDATE_USER_STR01,  0,p_xfr_itemtypeprop.USER_STR01,USER_STR01),
												USER_STR02=			DECODE(NOUPDATE_USER_STR02,  0,p_xfr_itemtypeprop.USER_STR02,USER_STR02),
												USER_STR03=			DECODE(NOUPDATE_USER_STR03,  0,p_xfr_itemtypeprop.USER_STR03,USER_STR03),
												USER_STR04=			DECODE(NOUPDATE_USER_STR04,  0,p_xfr_itemtypeprop.USER_STR04,USER_STR04),*/
												CREATION_DATE=			DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
												LAST_UPDATE_DATE=			DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
												CREATED_BY=			DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
												LAST_UPDATED_BY=		DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
												SECURITY_MASK=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
												CHECKOUT_USER=		DECODE(NOUPDATE_CHECKOUT_USER,0,NULL,CHECKOUT_USER),
                                                                        ORIG_SYS_REF = sOrigSysRef
												WHERE ITEM_TYPE_ID=p_xfr_itemtypeprop.ITEM_TYPE_ID AND
												PROPERTY_ID=p_xfr_itemtypeprop.PROPERTY_ID;
						IF(SQL%NOTFOUND) THEN
							FAILED:=FAILED+1;
						ELSE
							nUpdateCount:=nUpdateCount+1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_item_type_property
                                                              SET REC_STATUS='OK'
                                                            WHERE ITEM_TYPE_ID=p_xfr_itemtypeprop.ITEM_TYPE_ID
                                                              AND PROPERTY_ID=p_xfr_itemtypeprop.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
						END IF;

					EXCEPTION
						WHEN OTHERS THEN
							FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_item_type_property
                                                              SET REC_STATUS='ERR'
                                                            WHERE ITEM_TYPE_ID=p_xfr_itemtypeprop.ITEM_TYPE_ID
                                                              AND PROPERTY_ID=p_xfr_itemtypeprop.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
							x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_TYPE_PROP',11276,inRUN_ID);
					END ;

				END IF;

			END LOOP;
			CLOSE c_xfr_itemtypeprop;
			COMMIT;
			INSERTS:=nInsertCount;
			UPDATES:=nUpdateCount;
		EXCEPTION
                WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                 RAISE;
		WHEN OTHERS THEN
		x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_ITEM_TYPE_PROP',11276,inRUN_ID);
		END;
END XFR_ITEM_TYPE_PROPerty;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE XFR_PROPERTY (	inRUN_ID 		IN 	PLS_INTEGER,
                                        COMMIT_SIZE     IN      PLS_INTEGER,
					MAX_ERR		IN 	PLS_INTEGER,
					INSERTS		  OUT NOCOPY PLS_INTEGER,
					UPDATES		  OUT NOCOPY PLS_INTEGER,
					FAILED		IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2,
                                        p_rp_folder_id IN  NUMBER
					) IS
BEGIN
		DECLARE CURSOR c_xfr_property IS
                          SELECT PROPERTY_ID,PROPERTY_UNIT,DESC_TEXT,NAME,DATA_TYPE,DEF_VALUE,DEF_NUM_VALUE,RUN_ID,
                           REC_STATUS,DISPOSITION,DELETED_FLAG,CHECKOUT_USER,
                           USER_STR01,USER_STR02,USER_STR03,USER_STR04,USER_NUM01,USER_NUM02,
                           USER_NUM03,USER_NUM04,ORIG_SYS_REF,SRC_APPLICATION_ID, rec_nbr
                          FROM CZ_IMP_property WHERE CZ_IMP_property.RUN_ID = inRUN_ID AND REC_STATUS='PASS';
			x_xfr_property_f		BOOLEAN:=FALSE;
			x_error							BOOLEAN:=FALSE;

			p_xfr_property   c_xfr_property%ROWTYPE;

			/* Internal vars */
			nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
			nInsertCount		PLS_INTEGER:=0;			/*Inserts */
			nUpdateCount		PLS_INTEGER:=0;			/*Updates */

                  l_def_num_value         NUMBER;

            NOUPDATE_PROPERTY_UNIT           NUMBER;
			NOUPDATE_DESC_TEXT               NUMBER;
            NOUPDATE_NAME                    NUMBER;
			NOUPDATE_DATA_TYPE	             NUMBER;
            NOUPDATE_DEF_VALUE               NUMBER;
            NOUPDATE_DEF_NUM_VALUE           NUMBER;
			NOUPDATE_DELETED_FLAG            NUMBER;
			NOUPDATE_USER_STR01              NUMBER;
			NOUPDATE_USER_STR02              NUMBER;
			NOUPDATE_USER_STR03              NUMBER;
			NOUPDATE_USER_STR04              NUMBER;
			NOUPDATE_USER_NUM01              NUMBER;
			NOUPDATE_USER_NUM02              NUMBER;
			NOUPDATE_USER_NUM03              NUMBER;
			NOUPDATE_USER_NUM04              NUMBER;
			NOUPDATE_CREATION_DATE           NUMBER;
			NOUPDATE_LAST_UPDATE_DATE        NUMBER;
            NOUPDATE_CREATED_BY              NUMBER;
			NOUPDATE_LAST_UPDATED_BY         NUMBER;
			NOUPDATE_SECURITY_MASK           NUMBER;
			NOUPDATE_CHECKOUT_USER           NUMBER;

    --Bug #5162016, batch commit support.

    TYPE table_of_rowid     IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    TYPE table_of_number    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    t_rowid                 table_of_rowid;
    t_value                 table_of_number;

    CURSOR c_item_prop IS
       SELECT ROWID FROM cz_item_property_values
        WHERE property_id = p_xfr_property.property_id;

    CURSOR c_ps_prop IS
       SELECT ROWID FROM cz_ps_prop_vals
        WHERE property_id = p_xfr_property.property_id;

		-- Make sure that the DataSet exists
		BEGIN

		-- Get the Update Flags for each column
			NOUPDATE_PROPERTY_UNIT		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','PROPERTY_UNIT',inXFR_GROUP);
			NOUPDATE_DESC_TEXT    		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','DESC_TEXT',inXFR_GROUP);
			NOUPDATE_NAME			   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','NAME',inXFR_GROUP);
			NOUPDATE_DATA_TYPE		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','DATA_TYPE',inXFR_GROUP);
			NOUPDATE_DEF_VALUE		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','DEF_VALUE',inXFR_GROUP);
			NOUPDATE_DEF_NUM_VALUE	   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','DEF_NUM_VALUE',inXFR_GROUP);
			NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','DELETED_FLAG',inXFR_GROUP);
			NOUPDATE_USER_STR01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_STR01',inXFR_GROUP);
			NOUPDATE_USER_STR02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_STR02',inXFR_GROUP);
			NOUPDATE_USER_STR03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_STR03',inXFR_GROUP);
			NOUPDATE_USER_STR04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_STR04',inXFR_GROUP);
			NOUPDATE_USER_NUM01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_NUM01',inXFR_GROUP);
			NOUPDATE_USER_NUM02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_NUM02',inXFR_GROUP);
			NOUPDATE_USER_NUM03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_NUM03',inXFR_GROUP);
			NOUPDATE_USER_NUM04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','USER_NUM04',inXFR_GROUP);
			NOUPDATE_CREATION_DATE                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','CREATION_DATE',inXFR_GROUP);
			NOUPDATE_LAST_UPDATE_DATE                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','LAST_UPDATE_DATE',inXFR_GROUP);
                        NOUPDATE_CREATED_BY              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','CREATED_BY',inXFR_GROUP);
			NOUPDATE_LAST_UPDATED_BY             := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','LAST_UPDATED_BY',inXFR_GROUP);
			NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','SECURITY_MASK',inXFR_GROUP);
			NOUPDATE_CHECKOUT_USER           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PROPERTIES','CHECKOUT_USER',inXFR_GROUP);

			OPEN c_xfr_property;

			LOOP
				IF (nCommitCount>= COMMIT_SIZE) THEN
					BEGIN
						COMMIT;
						nCommitCount:=0;
					END;
				ELSE
					nCOmmitCount:=nCommitCount+1;
				END IF;
				FETCH c_xfr_property  INTO 	p_xfr_property;

				x_xfr_property_f:=c_xfr_property%FOUND;
				EXIT WHEN NOT x_xfr_property_f;
                                IF ( FAILED >= Max_Err) THEN
                                   x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_IM_XFR.XFR_PROPERTY:MAX',11276,inRun_Id);
                                   RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
                                END IF;

				IF (p_xfr_property.DISPOSITION = 'I') THEN
					BEGIN
                                    IF p_xfr_property.DATA_TYPE = 8 THEN
                                      --###1
                                      SELECT CZ_INTL_TEXTS_S.NEXTVAL INTO l_def_num_value FROM dual;
                                      FOR i IN(SELECT language_code FROM FND_LANGUAGES
                                                WHERE installed_flag in( 'B', 'I'))
                                      LOOP
                                         INSERT INTO cz_localized_texts (intl_text_id, localized_str,
                                           language, source_lang, deleted_flag,
                                           creation_date, last_update_date, created_by,
                                           last_updated_by,orig_sys_ref, model_id)
                                         VALUES
                                           (l_def_num_value,
                                            p_xfr_property.DEF_VALUE,
                                            i.language_code,
                                            USERENV('LANG'),
                                            '0',
                                            SYSDATE, SYSDATE, -UID, -UID,p_xfr_property.ORIG_SYS_REF, 0);
                                      END LOOP;
                                    ELSE
                                      l_def_num_value := p_xfr_property.DEF_NUM_VALUE;
                                    END IF;

						INSERT INTO CZ_PROPERTIES (PROPERTY_ID,PROPERTY_UNIT,DESC_TEXT,NAME,
                                     DATA_TYPE,DEF_VALUE,DEF_NUM_VALUE,USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,
                                     USER_STR01,USER_STR02,USER_STR03,USER_STR04,CREATION_DATE,
                                     LAST_UPDATE_DATE,DELETED_FLAG,CHECKOUT_USER,
                                     CREATED_BY,LAST_UPDATED_BY,SECURITY_MASK,ORIG_SYS_REF,SRC_APPLICATION_ID) VALUES
                                    (p_xfr_property.PROPERTY_ID,p_xfr_property.PROPERTY_UNIT,
                                     p_xfr_property.DESC_TEXT,p_xfr_property.NAME,p_xfr_property.DATA_TYPE,
                                     p_xfr_property.DEF_VALUE,
                                                                 l_def_num_value,
                                     p_xfr_property.USER_NUM01,
                                     p_xfr_property.USER_NUM02,p_xfr_property.USER_NUM03,
                                     p_xfr_property.USER_NUM04,p_xfr_property.USER_STR01,
                                     p_xfr_property.USER_STR02,p_xfr_property.USER_STR03,
                                     p_xfr_property.USER_STR04, SYSDATE, SYSDATE,
                                     p_xfr_property.DELETED_FLAG,p_xfr_property.CHECKOUT_USER,
                                     1, 1, NULL, p_xfr_property.ORIG_SYS_REF,p_xfr_property.SRC_APPLICATION_ID);
						nInsertCount:=nInsertCount+1;
                                                BEGIN
                                                   UPDATE CZ_IMP_property
                                                      SET REC_STATUS='OK'
                                                    WHERE PROPERTY_ID=p_xfr_property.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='I';
                                                END;

                    -- insert into an entry into cz_rp_entires for this property
                    BEGIN
                    INSERT INTO cz_rp_entries
                           (object_id,object_type,enclosing_folder,name,description)
                    VALUES (p_xfr_property.property_id,
                            'PRP',
                            p_rp_folder_id,
                            p_xfr_property.name,
                            p_xfr_property.desc_text);
                     EXCEPTION
                       WHEN OTHERS THEN
                         x_error:=CZ_UTILS.LOG_REPORT('Insert into cz_rp_entries FAILED. PROPERTY_ID:'|| p_xfr_property.property_id||'. '||SQLERRM,1,'CZ_IM_XFR.XFR_PROPERTY' ,11276,inRUN_ID);
                     END;

					EXCEPTION
						WHEN OTHERS THEN
							FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_property
                                                              SET REC_STATUS='ERR'
                                                            WHERE PROPERTY_ID=p_xfr_property.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='I';
                                                        END;
							x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_PROPERTY',11276,inRUN_ID);
					END ;

				ELSIF (p_xfr_property.DISPOSITION = 'M') THEN
					BEGIN

     --Bug #5162016. The data type is allowed for update and is different in this import session.
     --Need to move all property values for this property into the correct value field.

     IF(NOUPDATE_DATA_TYPE = 0 AND p_xfr_property.rec_nbr <> p_xfr_property.data_type)THEN

       IF(p_xfr_property.data_type = 4)THEN

        --The property was numeric and has just been made text.

        BEGIN
           OPEN c_item_prop;
           LOOP

              t_rowid.DELETE;

              FETCH c_item_prop BULK COLLECT INTO t_rowid LIMIT COMMIT_SIZE;
              EXIT WHEN c_item_prop%NOTFOUND AND t_rowid.COUNT = 0;

              FORALL i IN 1..t_rowid.COUNT
                 UPDATE cz_item_property_values SET
                    property_value = TO_CHAR(property_num_value),
                    property_num_value = NULL
                  WHERE ROWID = t_rowid(i);

              COMMIT;
           END LOOP;
           CLOSE c_item_prop;

           --This property may have been assigned to structure nodes directly.

           OPEN c_ps_prop;
           LOOP

              t_rowid.DELETE;

              FETCH c_ps_prop BULK COLLECT INTO t_rowid LIMIT COMMIT_SIZE;
              EXIT WHEN c_ps_prop%NOTFOUND AND t_rowid.COUNT = 0;

              FORALL i IN 1..t_rowid.COUNT
                 UPDATE cz_ps_prop_vals SET
                    data_value = TO_CHAR(data_num_value),
                    data_num_value = NULL
                  WHERE ROWID = t_rowid(i);

              COMMIT;
           END LOOP;
           CLOSE c_ps_prop;

        EXCEPTION
          WHEN OTHERS THEN
            if c_item_prop%ISOPEN then
            CLOSE c_item_prop;
	      end if;
	      if c_ps_prop%ISOPEN then
            CLOSE c_ps_prop;
	      end if;
            RAISE;
        END;

       ELSIF(p_xfr_property.data_type = 2)THEN

        --The property was text and has just been made numeric.

         BEGIN

           --Try to convert all possible values to numbers, if this fails, no updates
           --will be done.

           SELECT TO_NUMBER(property_value) BULK COLLECT INTO t_value
             FROM cz_item_property_values
            WHERE property_id = p_xfr_property.property_id;

           SELECT TO_NUMBER(data_value) BULK COLLECT INTO t_value
             FROM cz_ps_prop_vals
            WHERE property_id = p_xfr_property.property_id;

           OPEN c_item_prop;
           LOOP

              t_rowid.DELETE;

              FETCH c_item_prop BULK COLLECT INTO t_rowid LIMIT COMMIT_SIZE;
              EXIT WHEN c_item_prop%NOTFOUND AND t_rowid.COUNT = 0;

              FORALL i IN 1..t_rowid.COUNT
                 UPDATE cz_item_property_values SET
                    property_num_value = TO_NUMBER(property_value),
                    property_value = NULL
                  WHERE ROWID = t_rowid(i);

              COMMIT;
           END LOOP;
           CLOSE c_item_prop;

           --This property may have been assigned to structure nodes directly.

           OPEN c_ps_prop;
           LOOP

              t_rowid.DELETE;

              FETCH c_ps_prop BULK COLLECT INTO t_rowid LIMIT COMMIT_SIZE;
              EXIT WHEN c_ps_prop%NOTFOUND AND t_rowid.COUNT = 0;

              FORALL i IN 1..t_rowid.COUNT
                 UPDATE cz_ps_prop_vals SET
                    data_num_value = TO_NUMBER(data_value),
                    data_value = NULL
                  WHERE ROWID = t_rowid(i);

              COMMIT;
           END LOOP;
           CLOSE c_ps_prop;

         EXCEPTION
           WHEN INVALID_NUMBER THEN
             --'Property ''%PROPERTYNAME'' cannot be converted to ''Numeric'' data type because it
             -- has one or more non-numeric values.'
             x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_CONVERT_PROP', 'PROPERTYNAME', p_xfr_property.NAME),
                      1, 'CZ_IM_XFR.XFR_PROPERTY', 11276, inRUN_ID);
      	      if c_item_prop%ISOPEN then
             CLOSE c_item_prop;
	      end if;
	      if c_ps_prop%ISOPEN then
             CLOSE c_ps_prop;
	      end if;
             RAISE;
         END;
       END IF;
     END IF;

                                    IF p_xfr_property.DATA_TYPE = 8 THEN
                                      IF p_xfr_property.DEF_NUM_VALUE IS NULL THEN
                                        SELECT CZ_INTL_TEXTS_S.NEXTVAL INTO l_def_num_value FROM dual;
                                        FOR i IN(SELECT language_code FROM FND_LANGUAGES
                                                  WHERE installed_flag in( 'B', 'I'))
                                        LOOP
                                           INSERT INTO cz_localized_texts (intl_text_id, localized_str,
                                             language, source_lang, deleted_flag,
                                             creation_date, last_update_date, created_by,
                                             last_updated_by,orig_sys_ref, model_id)
                                           VALUES
                                             (l_def_num_value,
                                              p_xfr_property.DEF_VALUE,
                                              i.language_code,
                                              USERENV('LANG'),
                                              '0',
                                              SYSDATE, SYSDATE, -UID, -UID,p_xfr_property.ORIG_SYS_REF, 0);
                                        END LOOP;
                                      ELSE
                                        UPDATE cz_localized_texts
                                           SET localized_str=DECODE(NOUPDATE_DEF_VALUE,0,p_xfr_property.DEF_VALUE,localized_str)
                                         WHERE intl_text_id=p_xfr_property.DEF_NUM_VALUE;
                                      END IF;
                                    ELSE
                                      l_def_num_value := p_xfr_property.DEF_NUM_VALUE;
                                    END IF;

						UPDATE CZ_PROPERTIES SET
										 		PROPERTY_UNIT=DECODE(NOUPDATE_PROPERTY_UNIT,0,p_xfr_property.PROPERTY_UNIT, PROPERTY_UNIT),
												DESC_TEXT=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_property.DESC_TEXT,DESC_TEXT),
												NAME=DECODE(NOUPDATE_NAME,0,p_xfr_property.NAME,NAME),
												DATA_TYPE=DECODE(NOUPDATE_DATA_TYPE,0,p_xfr_property.DATA_TYPE,DATA_TYPE),
												DEF_VALUE=DECODE(NOUPDATE_DEF_VALUE,0,p_xfr_property.DEF_VALUE,DEF_VALUE),
												DEF_NUM_VALUE=DECODE(NOUPDATE_DEF_NUM_VALUE,0,l_def_num_value,DEF_NUM_VALUE),
												DELETED_FLAG=		DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_property.DELETED_FLAG ,DELETED_FLAG),
												USER_NUM01=			DECODE(NOUPDATE_USER_NUM01,  0,p_xfr_property.USER_NUM01,USER_NUM01),
												USER_NUM02=			DECODE(NOUPDATE_USER_NUM02,  0,p_xfr_property.USER_NUM02,USER_NUM02),
												USER_NUM03=			DECODE(NOUPDATE_USER_NUM03,  0,p_xfr_property.USER_NUM03,USER_NUM03),
												USER_NUM04=			DECODE(NOUPDATE_USER_NUM04,  0,p_xfr_property.USER_NUM04,USER_NUM04),
												USER_STR01=			DECODE(NOUPDATE_USER_STR01,  0,p_xfr_property.USER_STR01,USER_STR01),
												USER_STR02=			DECODE(NOUPDATE_USER_STR02,  0,p_xfr_property.USER_STR02,USER_STR02),
												USER_STR03=			DECODE(NOUPDATE_USER_STR03,  0,p_xfr_property.USER_STR03,USER_STR03),
												USER_STR04=			DECODE(NOUPDATE_USER_STR04,  0,p_xfr_property.USER_STR04,USER_STR04),
												CREATION_DATE=			DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
												LAST_UPDATE_DATE=			DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
												CREATED_BY=			DECODE(NOUPDATE_CREATED_BY,0,1,CREATED_BY),
												LAST_UPDATED_BY=		DECODE(NOUPDATE_LAST_UPDATED_BY,0,1,LAST_UPDATED_BY),
												SECURITY_MASK=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
												CHECKOUT_USER=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,CHECKOUT_USER)
												WHERE PROPERTY_ID=p_xfr_property.PROPERTY_ID;

						IF(SQL%NOTFOUND) THEN
							FAILED:=FAILED+1;
						ELSE
							nUpdateCount:=nUpdateCount+1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_property
                                                              SET REC_STATUS='OK'
                                                            WHERE PROPERTY_ID=p_xfr_property.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
                            -- update the entry for this property in cz_rp_entries
                            BEGIN
                                UPDATE cz_rp_entries
                                   SET name = p_xfr_property.name, description = p_xfr_property.desc_text
                                 WHERE object_id = p_xfr_property.property_id
                                   AND object_type = 'PRP';
                            EXCEPTION
                                WHEN OTHERS THEN
                                    x_error:=CZ_UTILS.LOG_REPORT('Update of PROPERTY_ID:'|| p_xfr_property.property_id||' in cz_rp_entries FAILED. '||SQLERRM,1,'CZ_IM_XFR.XFR_PROPERTY' ,11276,inRUN_ID);
                            END;
                                                 END IF;
                                        EXCEPTION WHEN INVALID_NUMBER THEN
                                               FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_property
                                                              SET REC_STATUS='ERR'
                                                            WHERE PROPERTY_ID=p_xfr_property.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
					WHEN OTHERS THEN
					    FAILED:=FAILED +1;
                                                        BEGIN
                                                           UPDATE CZ_IMP_property
                                                              SET REC_STATUS='ERR'
                                                            WHERE PROPERTY_ID=p_xfr_property.PROPERTY_ID AND RUN_ID=inRUN_ID
                                                           AND DISPOSITION='M';
                                                        END;
							x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_PROPERTY',11276,inRUN_ID);
					END ;

				END IF;

			END LOOP;
			CLOSE c_xfr_property;
			COMMIT;
			INSERTS:=nInsertCount;
			UPDATES:=nUpdateCount;
		EXCEPTION
                 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
                  RAISE;
	         WHEN OTHERS THEN
		  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IM_XFR.XFR_PROPERTY',11276,inRUN_ID);
		END;
END XFR_PROPERTY;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
END CZ_IMP_IM_XFR;

/
