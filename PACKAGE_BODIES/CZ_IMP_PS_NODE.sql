--------------------------------------------------------
--  DDL for Package Body CZ_IMP_PS_NODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_PS_NODE" as
/*	$Header: czipsnb.pls 120.11.12010000.4 2010/04/29 19:16:17 lamrute ship $		*/

CAPTION_RULE_TYPE           CONSTANT NUMBER:=700;
JAVA_SYS_PROP_RULE_TYPE     CONSTANT NUMBER:=501;

G_CONFIG_ENGINE_TYPE        VARCHAR2(10);

/*--INTL_TEXT IMPORT SECTION START------------------------------------------*/
------------------------------------------------------------------------------
PROCEDURE KRS_INTL_TEXT(inRUN_ID    IN  PLS_INTEGER,
                        COMMIT_SIZE IN  PLS_INTEGER,
                        MAX_ERR     IN  PLS_INTEGER,
                        INSERTS     IN OUT NOCOPY PLS_INTEGER,
                        UPDATES     IN OUT NOCOPY PLS_INTEGER,
                        FAILED      IN OUT NOCOPY PLS_INTEGER,
                        DUPS        IN OUT NOCOPY PLS_INTEGER,
                        inXFR_GROUP       IN    VARCHAR2
                       ) IS
     CURSOR c_imp_intl_text IS
     SELECT DISTINCT orig_sys_ref, fsk_devlproject_1_1
     FROM CZ_IMP_LOCALIZED_TEXTS
     WHERE rec_status IS NULL AND Run_ID = inRUN_ID
     ORDER BY orig_sys_ref;

   /* cursor's data found indicator */
     x_imp_intl_text_f           BOOLEAN:=FALSE;
     x_imp_localized_text_f      BOOLEAN:=FALSE;
     x_onl_intl_text_f           BOOLEAN:=FALSE;
     x_onl_intl_text_2_f         BOOLEAN:=FALSE;
     x_translated_intl_text_f    BOOLEAN:=FALSE;
     x_intl_text_found		 BOOLEAN := FALSE;
     x_text_not_matching 	 BOOLEAN := TRUE;
     x_error                     BOOLEAN:=FALSE;

    TYPE     tImpIntlTextId		         IS TABLE OF CZ_IMP_LOCALIZED_TEXTS.INTL_TEXT_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE     tImpLocalizedStr            IS TABLE OF CZ_IMP_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE INDEX BY BINARY_INTEGER;
    TYPE     tImpLanguage		         IS TABLE OF CZ_IMP_LOCALIZED_TEXTS.LANGUAGE%TYPE INDEX BY BINARY_INTEGER;
    TYPE     tImpSourceLang		         IS TABLE OF CZ_IMP_LOCALIZED_TEXTS.SOURCE_LANG%TYPE INDEX BY BINARY_INTEGER;
    TYPE     tImpFSKDevlProject          IS TABLE OF CZ_IMP_LOCALIZED_TEXTS.FSK_DEVLPROJECT_1_1%TYPE INDEX BY BINARY_INTEGER;
    TYPE     tImpOrigSysRef			     IS TABLE OF CZ_IMP_LOCALIZED_TEXTS.ORIG_SYS_REF%TYPE INDEX BY BINARY_INTEGER;
    TYPE     tNumber                     IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    nImpIntlTextId     tImpIntlTextId;
    sImpLocalizedStr   tImpLocalizedStr;
    sImpLanguage       tImpLanguage;
    sImpSourceLang     tImpSourceLang;
    sImpFSKDevlProject tImpFSKDevlProject;
    sImpOrigSysRef     tImpOrigSysRef;

    nOnlIntlTextId   CZ_IMP_LOCALIZED_TEXTS.INTL_TEXT_ID%TYPE;
    nOnlIntlText     CZ_IMP_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE;
    nOnlLanguage     CZ_IMP_LOCALIZED_TEXTS.LANGUAGE%TYPE;
    nOnlSourceLangn  CZ_IMP_LOCALIZED_TEXTS.SOURCE_LANG%TYPE;
    nOnlModelId      CZ_IMP_LOCALIZED_TEXTS.MODEL_ID%TYPE;
    nModelId         CZ_IMP_LOCALIZED_TEXTS.MODEL_ID%TYPE;
    nOnlOrigSysRef   CZ_IMP_LOCALIZED_TEXTS.ORIG_SYS_REF%TYPE;

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
     nNextId                     NUMBER;
     nCount                      NUMBER;
     l_msg              VARCHAR2(2000);

     v_settings_id      VARCHAR2(40);
     v_section_name     VARCHAR2(30);
     var_tl_prop        NUMBER;
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

    OPEN c_imp_intl_text;

    LOOP

      FETCH c_imp_intl_text
      bulk collect
      into sImpOrigSysRef, sImpFSKDevlProject
      limit COMMIT_SIZE;
      EXIT WHEN c_imp_intl_text%NOTFOUND AND sImpOrigSysRef.COUNT = 0;

      FOR I in 1..sImpOrigSysRef.COUNT LOOP

        /* Return if MAX_ERR is reached */
        IF(FAILED >= MAX_ERR) THEN
           x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.KRS_INTL_TEXT:MAX',11276,inRun_Id);
           RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
        END IF;

           DECLARE

        	   -- check online table for this text in this language for this model

        	   CURSOR c_onl_intl_text IS
        	   SELECT ol.intl_text_id,ol.localized_str, ol.model_id, ol.orig_sys_ref
        	   FROM cz_localized_texts ol, cz_devl_projects od, cz_ps_nodes op,
                   cz_imp_ps_nodes ip, cz_imp_devl_project id
        	   WHERE ol.orig_sys_ref = sImpOrigSysRef(i)
        	   AND ip.fsk_intltext_1_1 = sImpOrigSysRef(i)
        	   AND op.intl_text_id = ol.intl_text_id
        	   AND ip.orig_sys_ref = op.orig_sys_ref
        	   AND ol.model_id = od.devl_project_id
                   AND id.devl_project_id = od.devl_project_id
        	   AND id.orig_sys_ref = sImpFSKDevlProject(i)
        	   AND op.devl_project_id = ol.model_id
        	   AND ip.fsk_devlproject_5_1 = od.orig_sys_ref
                   AND ol.deleted_flag = '0'
                   AND op.deleted_flag = '0'
                   AND od.deleted_flag = '0'
                   AND ip.run_id = inRUN_ID
                   AND id.run_id = inRUN_ID
                   AND id.rec_status='OK';

           BEGIN
               OPEN c_onl_intl_text;
               FETCH c_onl_intl_text INTO nOnlIntlTextId,nOnlIntlText,nOnlModelId,nOnlOrigSysRef;
               x_onl_intl_text_f:=c_onl_intl_text%FOUND;
               CLOSE c_onl_intl_text;

               IF x_onl_intl_text_f THEN   /* update */

                            -- get the model_id from this import job

        		    UPDATE cz_imp_localized_texts
        		    SET intl_text_id = nOnlIntlTextId,
        		    model_id = nOnlModelId,
        		    disposition = 'M',
        		    rec_status = 'PASS'
        		    WHERE orig_sys_ref = sImpOrigSysRef(i)
        		    AND fsk_devlproject_1_1 = sImpFSKDevlProject(i)
                            AND run_id = inRUN_ID;

        		    UPDATE CZ_IMP_PS_NODES
        		    SET INTL_TEXT_ID =nOnlIntlTextId
        		    WHERE fsk_intltext_1_1 = sImpOrigSysRef(i)
                            AND fsk_devlproject_5_1 = sImpFSKDevlProject(i)
                            AND RUN_ID = inRUN_ID;

        		    nUpdateCount:=nUpdateCount+1;

               ELSE  /* insert */

                   BEGIN
                      SELECT devl_project_id INTO nModelId
                      FROM cz_imp_devl_project
                      WHERE orig_sys_ref = sImpFSKDevlProject(i)
                      AND run_id = inRUN_ID
                      AND rec_status = 'OK';

                        nAllocateCounter:=nAllocateCounter+1;
                        IF(nAllocateCounter=nAllocateBlock)THEN
                          nAllocateCounter:=0;
                          SELECT CZ_INTL_TEXTS_S.NEXTVAL INTO nNextValue FROM DUAL;
                        END IF;
                        nNextId := nNextValue + nAllocateCounter;

                        UPDATE cz_imp_localized_texts
                        SET intl_text_id = nNextId,
                        model_id = nModelId,
                        disposition = 'I',
                        rec_status = 'PASS'
                        WHERE orig_sys_ref = sImpOrigSysRef(i)
                        AND fsk_devlproject_1_1 = sImpFSKDevlProject(i)
                        AND run_id = inRUN_ID;

                    	UPDATE CZ_IMP_PS_NODES
                        SET INTL_TEXT_ID =nNextId
                        WHERE fsk_intltext_1_1 = sImpOrigSysRef(i)
                        AND fsk_devlproject_5_1 = sImpFSKDevlProject(i)
                        AND RUN_ID = inRUN_ID;

                       nInsertCount:=nInsertCount+1;

                   EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FAILED:=FAILED+1;
                        UPDATE cz_imp_localized_texts
                        SET disposition='R',
                        rec_status='FAIL'
                        WHERE orig_sys_ref = sImpOrigSysRef(i)
                        AND fsk_devlproject_1_1 = sImpFSKDevlProject(i)
                        AND run_id = inRUN_ID;
                   END;

               END IF;

               nCommitCount:=nCommitCount+1;
               /* COMMIT if the buffer size is reached */
               IF(nCommitCount>= COMMIT_SIZE) THEN
                 COMMIT;
                 nCommitCount:=0;
               END IF;
           END;

   -- Bug8519380 FIx.

---Checking first if the TL text property exists in CZ_IMP_ITEM_PROPERTY_VALUES table -- MASCO R12 Bug - 8226777
---conditionalize the cursor only if the the relevent data available in imp_item_property table.
--  FSK_LOCALIZEDTEXT_3_1 will be NOT NULL for data type 8 (TL text property)

        BEGIN
                SELECT COUNT(*) INTO var_tl_prop FROM cz_imp_item_property_value
                 WHERE run_id = inRUN_ID
                   AND FSK_LOCALIZEDTEXT_3_1 IS NOT NULL
                   AND FSK_LOCALIZEDTEXT_3_1=sImpOrigSysRef(i) AND rownum<2;


        IF var_tl_prop > 0 THEN

           DECLARE

        	   -- check online table for this text in this language for this model

        	   CURSOR c_tl_onl_intl_text IS
        	   SELECT ol.intl_text_id,ol.localized_str, ol.orig_sys_ref
        	   FROM cz_localized_texts ol
        	   WHERE ol.orig_sys_ref = sImpOrigSysRef(i)
        	         AND EXISTS(SELECT NULL FROM cz_imp_item_property_value
        	                    WHERE run_id = inRUN_ID
                                      AND FSK_LOCALIZEDTEXT_3_1 IS NOT NULL
                                      AND FSK_LOCALIZEDTEXT_3_1=ol.ORIG_SYS_REF)
                          AND ol.deleted_flag = '0';

           BEGIN
               OPEN c_tl_onl_intl_text;
               FETCH c_tl_onl_intl_text INTO nOnlIntlTextId,nOnlIntlText,nOnlOrigSysRef;
               x_onl_intl_text_f:=c_tl_onl_intl_text%FOUND;
               CLOSE c_tl_onl_intl_text;

               IF x_onl_intl_text_f THEN   /* update */
                            -- get the model_id from this import job

        		    UPDATE cz_imp_localized_texts
        		    SET intl_text_id = nOnlIntlTextId,
        		    model_id = 0,
        		    disposition = 'M',
        		    rec_status = 'PASS'
        		    WHERE orig_sys_ref = sImpOrigSysRef(i)
                            AND run_id = inRUN_ID;

        		    nUpdateCount:=nUpdateCount+1;

               ELSE  /* insert */

                   BEGIN --#####

                        SELECT COUNT(*) INTO var_tl_prop FROM cz_imp_item_property_value
                         WHERE run_id = inRUN_ID
                           AND FSK_LOCALIZEDTEXT_3_1 IS NOT NULL
                           AND FSK_LOCALIZEDTEXT_3_1=sImpOrigSysRef(i)
                           AND rownum<2;

                        IF var_tl_prop > 0 THEN

                          nAllocateCounter:=nAllocateCounter+1;

                          IF(nAllocateCounter=nAllocateBlock)THEN
                            nAllocateCounter:=0;
                            SELECT CZ_INTL_TEXTS_S.NEXTVAL INTO nNextValue FROM DUAL;
                          END IF;
                          nNextId := nNextValue + nAllocateCounter;

                          UPDATE cz_imp_localized_texts
                          SET intl_text_id = nNextId,
                              model_id = 0,
                              disposition = 'I',
                              rec_status = 'PASS'
                          WHERE orig_sys_ref = sImpOrigSysRef(i)
                                AND run_id = inRUN_ID;

                          nInsertCount:=nInsertCount+1;
                       END IF;

                   EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FAILED:=FAILED+1;
                        UPDATE cz_imp_localized_texts
                        SET disposition='R',
                        rec_status='FAIL'
                        WHERE orig_sys_ref = sImpOrigSysRef(i)
                              AND run_id = inRUN_ID;
                   END;

               END IF;

               nCommitCount:=nCommitCount+1;
               /* COMMIT if the buffer size is reached */
               IF(nCommitCount>= COMMIT_SIZE) THEN
                 COMMIT;
                 nCommitCount:=0;
               END IF;
           END;

         END IF;
       END;

      END LOOP;
      sImpOrigSysRef.DELETE;
      sImpFSKDevlProject.DELETE;
      sImpLanguage.DELETE;
      sImpSourceLang.DELETE;

    END LOOP;
	CLOSE c_imp_intl_text;

    INSERTS:=nInsertCount;
    UPDATES:=nUpdateCount;
    DUPS:=nDups;

EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.KRS_INTL_TEXT',11276,inRun_Id);
    RAISE;
END KRS_INTL_TEXT;
------------------------------------------------------------------------------
PROCEDURE CND_INTL_TEXT(inRUN_ID    IN  PLS_INTEGER,
                        COMMIT_SIZE IN  PLS_INTEGER,
			MAX_ERR     IN  PLS_INTEGER,
			FAILED      IN OUT NOCOPY PLS_INTEGER
			     ) IS
 -- passing records of this phase
 CURSOR l_csr_1 IS
 SELECT DISTINCT orig_sys_ref FROM cz_imp_localized_texts
 WHERE rec_status IS NULL AND run_id = inRUN_ID AND orig_sys_ref IS NOT NULL
 AND fsk_devlproject_1_1 IS NOT NULL AND language IS NOT NULL AND source_lang IS NOT NULL;

 -- failing records of this phase
 CURSOR l_csr_2 IS
 SELECT DISTINCT orig_sys_ref FROM cz_imp_localized_texts
 WHERE rec_status IS NULL AND run_id = inRUN_ID
 AND (orig_sys_ref IS NULL OR language IS NULL OR source_lang IS NULL);
-- APC changes AND (orig_sys_ref IS NULL OR fsk_devlproject_1_1 IS NULL OR language IS NULL OR source_lang IS NULL);


 TYPE orig_sys_ref_tbl_type     IS TABLE OF cz_imp_localized_texts.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;

 l_orig_sys_ref_tbl                    orig_sys_ref_tbl_type;
 x_error                               BOOLEAN:=FALSE;
 l_msg                                 VARCHAR2(2000);

BEGIN
   OPEN l_csr_1;
   LOOP
        l_orig_sys_ref_tbl.DELETE;
        FETCH l_csr_1  BULK COLLECT INTO l_orig_sys_ref_tbl
        LIMIT COMMIT_SIZE;
        EXIT WHEN l_csr_1%NOTFOUND AND l_orig_sys_ref_tbl.COUNT = 0;
        IF l_orig_sys_ref_tbl.COUNT > 0 THEN
          FORALL i IN l_orig_sys_ref_tbl.FIRST..l_orig_sys_ref_tbl.LAST
             UPDATE cz_imp_localized_texts
             SET deleted_flag = '0'
             WHERE orig_sys_ref = l_orig_sys_ref_tbl(i)
             AND run_id = inRUN_ID
             AND deleted_flag IS NULL;
          COMMIT;
        END IF;
   END LOOP;
   CLOSE l_csr_1;

   OPEN l_csr_2;
   LOOP
        l_msg := CZ_UTILS.GET_TEXT('CZ_IMP_INTLTXT_REQ_COLS');
        l_orig_sys_ref_tbl.DELETE;
        FETCH l_csr_2  BULK COLLECT INTO l_orig_sys_ref_tbl
        LIMIT COMMIT_SIZE;
        EXIT WHEN l_csr_2%NOTFOUND AND l_orig_sys_ref_tbl.COUNT = 0;
        IF l_orig_sys_ref_tbl.COUNT > 0 THEN
          FORALL i IN l_orig_sys_ref_tbl.FIRST..l_orig_sys_ref_tbl.LAST
             UPDATE cz_imp_localized_texts
             SET disposition = 'R',
             rec_status = 'FAIL',
             message = l_msg
             WHERE orig_sys_ref = l_orig_sys_ref_tbl(i) AND run_id = inRUN_ID;
          COMMIT;
          l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_INTLTXT_FAIL',
                                   'COUNT' , SQL%ROWCOUNT);
          x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_INTL_TEXT',11276,inRun_Id);
          FAILED := FAILED + SQL%ROWCOUNT;

          /* Return if MAX_ERR is reached */
          IF(FAILED >= MAX_ERR) THEN
             x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,
                                          'CZ_IMP_PS_NODE.CND_INTL_TEXT',11276,inRun_Id);
             RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
          END IF;
        END IF;
   END LOOP;
   CLOSE l_csr_2;

EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    IF l_csr_1%ISOPEN THEN CLOSE l_csr_1; END IF;
    IF l_csr_2%ISOPEN THEN CLOSE l_csr_2; END IF;
    RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    IF l_csr_1%ISOPEN THEN CLOSE l_csr_1; END IF;
    IF l_csr_2%ISOPEN THEN CLOSE l_csr_2; END IF;
    RAISE;
  WHEN OTHERS THEN
    IF l_csr_1%ISOPEN THEN CLOSE l_csr_1; END IF;
    IF l_csr_2%ISOPEN THEN CLOSE l_csr_2; END IF;
    x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.CND_INTL_TEXT',11276,inRun_Id);
    RAISE;
END CND_INTL_TEXT;
------------------------------------------------------------------------------
PROCEDURE MAIN_INTL_TEXT(inRUN_ID    IN  PLS_INTEGER,
                         COMMIT_SIZE IN  PLS_INTEGER,
                         MAX_ERR     IN  PLS_INTEGER,
                         INSERTS     IN OUT NOCOPY PLS_INTEGER,
                         UPDATES     IN OUT NOCOPY PLS_INTEGER,
                         FAILED      IN OUT NOCOPY PLS_INTEGER,
                         DUPS        IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                        ) IS
    /* Internal vars */
    nCommitCount     PLS_INTEGER:=0; /* COMMIT buffer index */
    nErrorCount      PLS_INTEGER:=0; /* Error index */
    nXfrInsertCount  PLS_INTEGER:=0; /* Inserts */
    nXfrUpdateCount  PLS_INTEGER:=0; /* Updates */
    nFailed          PLS_INTEGER:=0; /* Failed records */
    nDups            PLS_INTEGER:=0; /* Dupl records */
    x_error          BOOLEAN:=FALSE;
    dummy            CHAR(1);

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
            x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.MAIN_INTL_TEXT:RUNID',11276,inRun_Id);
            RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
        END;

    if (CZ_IMP_ALL.get_time) then
      st_time := dbms_utility.get_time();
    end if;

    CND_INTL_TEXT(inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

    if (CZ_IMP_ALL.get_time) then
      end_time := dbms_utility.get_time();
      d_str := inRun_id || '     CND intl text :' || (end_time-st_time)/100.00;
      x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299,inRun_Id);
    end if;

    KRS_INTL_TEXT(inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
      end_time := dbms_utility.get_time();
      d_str := inRun_id || '     KRS intl text :' || (end_time-st_time)/100.00;
      x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299,inRun_Id);
    end if;

    /* Make sure that the error count has not been reached */

    XFR_INTL_TEXT(inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
      end_time := dbms_utility.get_time();
      d_str := inRun_id || '     XFR intl text :' || (end_time-st_time)/100.00;
      x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299,inRun_Id);
    end if;

    /* Report Insert Errors */
    IF(nXfrInsertCount<> INSERTS) THEN
      x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_PS_NODE.MAIN_INTL_TEXT:INSERTS ',11276,inRun_Id);
    END IF;
    /* Report Update Errors */
    IF(nXfrUpdateCount<> UPDATES) THEN
      x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_PS_NODE.MAIN_INTL_TEXT:UPDATES ',11276,inRun_Id);
    END IF;
    /* Return the transferred number of rows and not the number of rows with keys resolved */
    INSERTS:=nXfrInsertCount;
    UPDATES:=nXfrUpdateCount;

    CZ_IMP_PS_NODE.RPT_INTL_TEXT(inRUN_ID);

END MAIN_INTL_TEXT;
------------------------------------------------------------------------------

PROCEDURE XFR_INTL_TEXT(inRUN_ID    IN  PLS_INTEGER,
                        COMMIT_SIZE IN  PLS_INTEGER,
                        MAX_ERR     IN  PLS_INTEGER,
                        INSERTS     IN OUT NOCOPY PLS_INTEGER,
                        UPDATES     IN OUT NOCOPY PLS_INTEGER,
                        FAILED      IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                       ) IS
    CURSOR c_xfr_intl_text IS
    SELECT intl_text_id, localized_str, language, source_lang, deleted_flag,creation_date
           last_update_date, created_by, last_updated_by,orig_sys_ref, model_id, disposition,
           rec_status, ROWID
      FROM CZ_IMP_LOCALIZED_TEXTS
     WHERE Run_ID=inRUN_ID AND rec_status = 'PASS';

    x_xfr_intl_text_f    BOOLEAN:=FALSE;
    x_error              BOOLEAN:=FALSE;
    p_xfr_intl_text      c_xfr_intl_text%ROWTYPE;

    sIntlTextId		 CZ_IMP_LOCALIZED_TEXTS.INTL_TEXT_ID%TYPE;

    -- Internal vars --
    nCommitCount            PLS_INTEGER:=0; -- COMMIT buffer index --
    nInsertCount            PLS_INTEGER:=0; -- Inserts --
    nUpdateCount            PLS_INTEGER:=0; -- Updates --
    nFailed                 PLS_INTEGER:=0; -- Failed records --

    l_row_id                ROWID;

    NOUPDATE_ORIG_SYS_REF     NUMBER;
    NOUPDATE_LOCALIZED_STR   	NUMBER;
    NOUPDATE_LANGUAGE 		NUMBER;
    NOUPDATE_SOURCE_LANG 	NUMBER;
    NOUPDATE_CREATION_DATE    NUMBER;
    NOUPDATE_LAST_UPDATE_DATE NUMBER;
    NOUPDATE_CREATED_BY     	NUMBER;
    NOUPDATE_LAST_UPDATED_BY  NUMBER;
    NOUPDATE_DELETED_FLAG   	NUMBER;

 -- Make sure that the DataSet exists
BEGIN
 -- Get the Update Flags for each column
      NOUPDATE_ORIG_SYS_REF   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','ORIG_SYS_REF',inXFR_GROUP);
      NOUPDATE_LOCALIZED_STR      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','LOCALIZED_STR',inXFR_GROUP);
      NOUPDATE_LANGUAGE      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','LANGUAGE',inXFR_GROUP);
      NOUPDATE_SOURCE_LANG      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','SOURCE_LANG',inXFR_GROUP);
      NOUPDATE_CREATION_DATE       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','CREATION_DATE',inXFR_GROUP);
      NOUPDATE_LAST_UPDATE_DATE      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','LAST_UPDATE_DATE',inXFR_GROUP);
      NOUPDATE_CREATED_BY    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','CREATED_BY',inXFR_GROUP);
      NOUPDATE_LAST_UPDATED_BY   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','LAST_UPDATED_BY',inXFR_GROUP);
      NOUPDATE_DELETED_FLAG  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_LOCALIZED_TEXTS','DELETED_FLAG',inXFR_GROUP);

      OPEN c_xfr_intl_text;
      LOOP
        IF(nCommitCount>= COMMIT_SIZE) THEN
          BEGIN
            COMMIT;
            nCommitCount:=0;
          END;
        ELSE
          nCOmmitCount:=nCommitCount+1;
        END IF;

        FETCH c_xfr_intl_text INTO p_xfr_intl_text;
        x_xfr_intl_text_f:=c_xfr_intl_text%FOUND;
        EXIT WHEN NOT x_xfr_intl_text_f;

        IF(FAILED >= MAX_ERR) THEN
          ROLLBACK;
          x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.XFR_INTL_TEXT:MAX',11276,inRun_Id);
          RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
        END IF;

        IF(p_xfr_intl_text.disposition = 'I') THEN
          BEGIN

            INSERT INTO cz_localized_texts (intl_text_id, localized_str, language, source_lang, deleted_flag,
              creation_date, last_update_date, created_by, last_updated_by,orig_sys_ref, model_id)
            VALUES
              (p_xfr_intl_text.intl_text_id,
               p_xfr_intl_text.localized_str,
               p_xfr_intl_text.language,
               p_xfr_intl_text.source_lang,
               p_xfr_intl_text.deleted_flag,
               sysdate, sysdate, -UID, -UID,p_xfr_intl_text.orig_sys_ref, p_xfr_intl_text.model_id);

             nInsertCount:=nInsertCount+1;

               UPDATE cz_imp_localized_texts
                  SET intl_text_id=p_xfr_intl_text.intl_text_id,
                      REC_STATUS='OK'
                WHERE ROWID =  p_xfr_intl_text.ROWID;

          EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                    UPDATE cz_imp_localized_texts
                       SET DISPOSITION='R',
                           REC_STATUS='DUPL'
                     WHERE ROWID = p_xfr_intl_text.ROWID;
               WHEN OTHERS THEN
                  FAILED:=FAILED +1;
                    UPDATE cz_imp_localized_texts
                       SET REC_STATUS='ERR'
                     WHERE ROWID = p_xfr_intl_text.ROWID;
                    x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.XFR_INTL_TEXT:INSERT',11276,inRun_Id);
          END;
        ELSIF(p_xfr_intl_text.disposition = 'M') THEN
          BEGIN
             UPDATE cz_localized_texts SET
              localized_str=DECODE(NOUPDATE_LOCALIZED_STR,0,p_xfr_intl_text.localized_str,localized_str),
              deleted_flag=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_intl_text.deleted_flag,deleted_flag),
              source_lang=DECODE(NOUPDATE_SOURCE_LANG,0,p_xfr_intl_text.source_lang,source_lang),
              LAST_UPDATE_DATE=DECODE(NOUPDATE_LAST_UPDATE_DATE,0,sysdate,LAST_UPDATE_DATE),
              LAST_UPDATED_BY=DECODE(NOUPDATE_LAST_UPDATED_BY,0,-UID,LAST_UPDATED_BY)
             WHERE intl_text_id=p_xfr_intl_text.intl_text_id
               AND model_id = p_xfr_intl_text.model_id
	       AND language = p_xfr_intl_text.language;

             IF(SQL%NOTFOUND) THEN
               FAILED:=FAILED+1;
             ELSE
               nUpdateCount:=nUpdateCount+1;
                 UPDATE cz_imp_localized_texts
                    SET REC_STATUS='OK'
                  WHERE ROWID = p_xfr_intl_text.ROWID;
             END IF;

          EXCEPTION
            WHEN OTHERS THEN
                FAILED:=FAILED +1;
                  UPDATE cz_imp_localized_texts
                  SET REC_STATUS='ERR'
                  WHERE ROWID = p_xfr_intl_text.ROWID;
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.XFR_INTL_TEXT:UPDATE',11276,inRun_Id);
          END;

        END IF;
      END LOOP;

      CLOSE c_xfr_intl_text;
      COMMIT;
      INSERTS:=nInsertCount;
      UPDATES:=nUpdateCount;
EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
   x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.XFR_INTL_TEXT',11276,inRun_Id);
   RAISE;
END XFR_INTL_TEXT;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE RPT_INTL_TEXT ( inRUN_ID IN PLS_INTEGER ) AS
                            x_error     BOOLEAN:=FALSE;

    v_table_name  VARCHAR2(30) := 'CZ_LOCALIZED_TEXTS';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';

      CURSOR c_xfr_run_result IS
      SELECT DISPOSITION,REC_STATUS,COUNT(*)
      FROM cz_imp_localized_texts
      WHERE RUN_ID = inRUN_ID
      GROUP BY DISPOSITION,REC_STATUS;

      ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
      ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
      ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

BEGIN

       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;
       EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
       END;

       OPEN c_xfr_run_result;
          LOOP
             FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
             EXIT WHEN c_xfr_run_result%NOTFOUND;
             INSERT INTO CZ_XFR_RUN_RESULTS  (RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
             VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);
          END LOOP;
       CLOSE c_xfr_run_result;
       COMMIT;

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
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_INTL_TEXT',11276,inRun_Id);
              END;
EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_INTL_TEXT',11276,inRun_Id);
    RAISE;
END;
/*--INTL_TEXT IMPORT SECTION END--------------------------------------------*/

/*--DEVL_PROJECT IMPORT SECTION START---------------------------------------*/
------------------------------------------------------------------------------
PROCEDURE KRS_DEVL_PROJECT(inRUN_ID    IN  PLS_INTEGER,
                           COMMIT_SIZE IN  PLS_INTEGER,
                           MAX_ERR     IN  PLS_INTEGER,
                           INSERTS     IN  OUT NOCOPY PLS_INTEGER,
                           UPDATES     IN OUT NOCOPY PLS_INTEGER,
                           FAILED      IN OUT NOCOPY PLS_INTEGER,
                           DUPS        IN OUT NOCOPY PLS_INTEGER,
                           inXFR_GROUP IN VARCHAR2
                          ) IS
     CURSOR c_imp_devl_project IS
     SELECT plan_level,orig_sys_ref,name,fsk_intltext_1_1,organization_id,
            top_item_id,explosion_type,model_id,model_type, ROWID
       FROM CZ_IMP_DEVL_PROJECT
      WHERE rec_status IS NULL AND Run_ID = inRUN_ID
      ORDER BY model_id,plan_level,ORIG_SYS_REF,NAME,ROWID;

   /* cursor's data found indicator */
     x_imp_devl_project_f        BOOLEAN:=FALSE;
     x_onl_devl_project_f        BOOLEAN:=FALSE;
     x_onl_intl_text_f           BOOLEAN:=FALSE;
     x_onl_root_f                BOOLEAN:=FALSE;
     x_onl_child_f               BOOLEAN:=FALSE;
     x_error                     BOOLEAN:=FALSE;

     sOrigSysRef                 CZ_IMP_DEVL_PROJECT.ORIG_SYS_REF%TYPE;
     sName                       CZ_IMP_DEVL_PROJECT.NAME%TYPE;
     onlName                     CZ_DEVL_PROJECTS.NAME%TYPE;
     sFskIntlText11              CZ_IMP_DEVL_PROJECT.FSK_INTLTEXT_1_1%TYPE;
     nPlanLevel                  CZ_IMP_DEVL_PROJECT.PLAN_LEVEL%TYPE;
     nOnlDevlProjectId           CZ_IMP_DEVL_PROJECT.DEVL_PROJECT_ID%TYPE;
     REFRESH_MODEL_ID            CZ_IMP_DEVL_PROJECT.DEVL_PROJECT_ID%TYPE;
     nPersistentProjectId        CZ_IMP_DEVL_PROJECT.PERSISTENT_PROJECT_ID%TYPE;
     nOnlIntlTextId              CZ_IMP_DEVL_PROJECT.INTL_TEXT_ID%TYPE;
     sRecStatus                  CZ_IMP_DEVL_PROJECT.REC_STATUS%TYPE;
     sDisposition                CZ_IMP_DEVL_PROJECT.DISPOSITION%TYPE;
     cDeletedFlag                CZ_DEVL_PROJECTS.DELETED_FLAG%TYPE;
     nOrgId                      CZ_IMP_DEVL_PROJECT.ORGANIZATION_ID%TYPE;
     nTopId                      CZ_IMP_DEVL_PROJECT.TOP_ITEM_ID%TYPE;
     sExplType                   CZ_IMP_DEVL_PROJECT.EXPLOSION_TYPE%TYPE;
     nModelId                    CZ_DEVL_PROJECTS.DEVL_PROJECT_ID%TYPE;
     sModelId                    CZ_DEVL_PROJECTS.DEVL_PROJECT_ID%TYPE;
     nExplId                     NUMBER;
     COPY_CHILD_MODELS           CZ_XFR_PROJECT_BILLS.COPY_ADDL_CHILD_MODELS%TYPE;
     nModelType			   CZ_IMP_DEVL_PROJECT.MODEL_TYPE%TYPE;
     sModelType			   CZ_IMP_DEVL_PROJECT.MODEL_TYPE%TYPE;

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
     nDummy                      NUMBER;
     nInstances			   NUMBER;

     TYPE tLastFSK1              IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
     TYPE tLastModel             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     sLastFSK1                   tLastFSK1;
     sLastModel                  tLastModel;

     thisRowId                   ROWID;
     l_err_msg                   VARCHAR2(255);

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

    OPEN c_imp_devl_project;

      LOOP
      /* COMMIT if the buffer size is reached */
        IF(nCommitCount>= COMMIT_SIZE) THEN
          BEGIN
           COMMIT;
           nCommitCount:=0;
          END;
        ELSE
           nCommitCount:=nCommitCount+1;
        END IF;

        sOrigSysRef:=NULL; sFskIntlText11:=NULL;
        FETCH c_imp_devl_project INTO nPlanLevel,sOrigSysRef,sName,sFskIntlText11,
        nOrgId,nTopId,sExplType,REFRESH_MODEL_ID,nModelType,thisRowId;

        sLastFSK1(sLastFSK1.COUNT + 1) := sOrigSysRef;
        sLastModel(sLastModel.COUNT + 1) := REFRESH_MODEL_ID;

        x_imp_devl_project_f:=c_imp_devl_project%FOUND;
        EXIT WHEN NOT x_imp_devl_project_f;

      /*Get the COPY_CHILD_MODELS value*/

        BEGIN

          SELECT NVL(copy_addl_child_models,'0') INTO COPY_CHILD_MODELS
          FROM cz_xfr_project_bills
          WHERE model_ps_node_id = REFRESH_MODEL_ID;

        EXCEPTION
          WHEN OTHERS THEN
            COPY_CHILD_MODELS := '0';
        END;

      /* Check the online database */
        DECLARE
          CURSOR c_onl_devl_project IS
            SELECT devl_project_id FROM cz_devl_projects
            WHERE ORIG_SYS_REF=sOrigSysRef
              AND DEVL_PROJECT_ID=PERSISTENT_PROJECT_ID
              AND DELETED_FLAG='0';
        BEGIN
           nOnlDevlProjectId := NULL;
           OPEN c_onl_devl_project;
           FETCH c_onl_devl_project INTO nOnlDevlProjectId;
           x_onl_devl_project_f:=c_onl_devl_project%FOUND;
           CLOSE c_onl_devl_project;
           nPersistentProjectId := nOnlDevlProjectId;

           IF(REFRESH_MODEL_ID IS NULL OR REFRESH_MODEL_ID < 0)THEN
             IF(nPlanLevel = 0 OR COPY_CHILD_MODELS = '1')THEN
               x_onl_devl_project_f := FALSE;
             END IF;
           ELSE
             DECLARE
               CURSOR c_onl_model_root IS
                 SELECT NULL FROM cz_devl_projects
                 WHERE devl_project_id = REFRESH_MODEL_ID
                   AND deleted_flag = '0';
               CURSOR c_onl_model_id IS
                 SELECT d.devl_project_id, e.model_ref_expl_id FROM cz_devl_projects d, cz_model_ref_expls e
                 WHERE d.deleted_flag = '0'
                   AND e.deleted_flag = '0'
                   AND d.orig_sys_ref = sOrigSysRef
                   AND e.model_id = REFRESH_MODEL_ID
                   AND d.devl_project_id = e.component_id;
             BEGIN
               IF(nPlanLevel = 0)THEN
                 x_onl_root_f := FALSE;
                 OPEN c_onl_model_root;
                 FETCH c_onl_model_root INTO nModelId;
                 x_onl_root_f := c_onl_model_root%FOUND;
                 CLOSE c_onl_model_root;
                 x_onl_devl_project_f := x_onl_root_f;
                 nOnlDevlProjectId := REFRESH_MODEL_ID;
               ELSE
                 IF(NOT x_onl_root_f)THEN
                  x_onl_devl_project_f := FALSE;
                 ELSE
                   IF(COPY_CHILD_MODELS = '1')THEN
                     x_onl_devl_project_f := FALSE;
                   ELSE
                     nModelId := NULL; nExplId := NULL;
                     OPEN c_onl_model_id;
                     FETCH c_onl_model_id INTO nModelId, nExplId;
                     x_onl_child_f := c_onl_model_id%FOUND;
                     CLOSE c_onl_model_id;

                     IF(x_onl_child_f)THEN
                       nOnlDevlProjectId := nModelId;
                       x_onl_devl_project_f := TRUE;
                     END IF;
                   END IF;
                 END IF;
               END IF;
             END;
           END IF;
        END;

        IF(NOT x_onl_devl_project_f)THEN
         DECLARE
          CURSOR c_check IS
            SELECT null FROM cz_rp_entries rp, cz_devl_projects dv
             WHERE rp.deleted_flag = '0'
               AND rp.object_type = 'PRJ'
               AND rp.name = sName
               AND dv.deleted_flag = '0'
               AND dv.orig_sys_ref = sOrigSysRef
               AND rp.object_id = dv.devl_project_id;
         BEGIN

          OPEN c_check;
          FETCH c_check INTO nDummy;
          IF(c_check%FOUND)THEN

            BEGIN
              SELECT MAX(cz_utils.conv_num(SUBSTR(rp.name, 7, INSTR(rp.name, ')') - 7))) INTO nDummy
                FROM cz_rp_entries rp, cz_devl_projects dv
               WHERE rp.deleted_flag = '0'
                 AND rp.object_type = 'PRJ'
                 AND rp.name like 'Copy (%) of ' || sName
                 AND dv.deleted_flag = '0'
                 AND dv.orig_sys_ref = sOrigSysRef
                 AND rp.object_id = dv.devl_project_id;

              IF(nDummy IS NULL)THEN nDummy := 0; END IF;
              sName := 'Copy (' || TO_CHAR(nDummy + 1) || ') of ' || sName;

            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          END IF;
          CLOSE c_check;
         END;

        ELSE

         BEGIN
           SELECT name, model_type INTO onlName, sModelType
           FROM cz_devl_projects WHERE devl_project_id = nOnlDevlProjectId;

           IF(SUBSTR(onlName,1,6) = 'Copy (')THEN
             sName := SUBSTR(onlName,1,INSTR(onlName,') of')+4) || sName;
           END IF;

         EXCEPTION
           WHEN OTHERS THEN
             NULL;
         END;
        END IF;

        sRecStatus := NULL;
        IF(sOrigSysRef IS NULL)THEN
           sRecStatus:='N7';
           sDisposition:='R';
        ELSE
          IF(sLastFSK1.COUNT > 1)THEN
           FOR i IN 1..sLastFSK1.COUNT - 1 LOOP
            IF(sLastFSK1(i) = sOrigSysRef AND sLastModel(i) = REFRESH_MODEL_ID)THEN
        /* This is a duplicate record */
              sRecStatus:='DUPL';
              sDisposition:='R';
              nDups:=nDups+1;
             EXIT;
            END IF;
           END LOOP;
          END IF;
        END IF;

        IF(sRecStatus IS NULL)THEN
          sRecStatus:='PASS';
          IF(x_onl_devl_project_f)THEN
		   sDisposition:='M';
		   nUpdateCount:=nUpdateCount+1;

               --If the configuration model type is changed from the 'Container Model', log a warning.

               IF(sModelType = 'N' AND nModelType <> 'N')THEN

                 --'The Configuration Model Type for ''%MODELNAME'' has changed from ''Container'' to ''Standard''.'
                 x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_CONTAINER_REFRESH', 'MODELNAME', sName), 1, 'CZ_IMP_PS_NODE.KRS_DEVL_PROJECT ', 11276,inRun_Id);
                 cz_imp_all.setReturnCode(cz_imp_all.CONCURRENT_WARNING, CZ_UTILS.GET_TEXT('CZ_IMP_CONTAINER_REFRESH', 'MODELNAME', sName));
               END IF;

	         -- Don't update model_type if it is 'P'

		   IF (sModelType = 'P' AND nModelType NOT IN ('P', 'N')) THEN

			CZ_REFS.SolutionBasedModelCheck(nOnlDevlProjectId, nInstances);

			if (nInstances > 0) then
			  begin
			    sModeltype := 'P';
			    /*If the model has multiple instances, then do not refresh this or its parent model */
			    x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_CANNOT_REFRESH_PTO', 'MODELNAME', sName), 1, 'CZ_IMP_PS_NODE.KRS_DEVL_PROJECT ', 11276,inRun_Id);
			    sRecStatus := 'N8';
			    sDisposition := 'R';
			  end;
			else sModelType := nModelType; end if;
		   END IF;
          ELSE
          /* Insert */
            sDisposition:='I';
            nInsertCount:=nInsertCount+1;
            nAllocateCounter:=nAllocateCounter+1;
            IF(nAllocateCounter=nAllocateBlock)THEN
              nAllocateCounter:=0;
              SELECT CZ_PS_NODES_S.NEXTVAL INTO nNextValue FROM DUAL;
            END IF;
            nOnlDevlProjectId:=nNextValue+nAllocateCounter;
          END IF;
        END IF;

         UPDATE CZ_IMP_DEVL_PROJECT SET
         DEVL_PROJECT_ID=DECODE(sDisposition,'R',DEVL_PROJECT_ID,nOnlDevlProjectId),
         PERSISTENT_PROJECT_ID=DECODE(sDisposition,'I',NVL(nPersistentProjectId,nOnlDevlProjectId),PERSISTENT_PROJECT_ID),
         INTL_TEXT_ID=DECODE(sDisposition,'R',INTL_TEXT_ID,nOnlIntlTextId),
         NAME=DECODE(sDisposition,'R',NAME,sName),
         DISPOSITION=sDisposition,
         REC_STATUS=sRecStatus,
	 MODEL_TYPE = DECODE(sDisposition,'M',DECODE(sModelType,'P',DECODE(nModelType,'N',nModelType,sModelType),nModelType),nModelType)
         WHERE ROWID = thisRowId;

	  /* If PTO is being changed to an ATO model, reject import of the model's parents and children */
	  IF(nPlanLevel > 0 AND sDisposition = 'R' AND sRecStatus = 'N8')THEN

              UPDATE CZ_IMP_DEVL_PROJECT SET
              DISPOSITION=sDisposition,
              REC_STATUS=sRecStatus
              WHERE MODEL_ID = REFRESH_MODEL_ID;

            l_err_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PTOTOATO_DISALLOWED','MODELID', REFRESH_MODEL_ID);
            x_error:=CZ_UTILS.LOG_REPORT(l_err_msg,1,'KRS_DEVL_PROJECT:TYPE',11276,inRun_Id);
            FAILED:=FAILED+1;
	  END IF;

        IF(sDisposition<>'R')THEN

           UPDATE CZ_IMP_PS_NODES SET
            DEVL_PROJECT_ID=nOnlDevlProjectId
            WHERE fsk_devlproject_5_1 = sOrigSysRef
            AND RUN_ID=inRUN_ID;

        END IF;

       /* Return if MAX_ERR is reached */
       IF(FAILED >= MAX_ERR) THEN
        x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.KRS_DEVL_PROJECT:MAX',11276,inRun_Id);
        RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
       END IF;

        sDisposition:=NULL; sRecStatus:=NULL;

      END LOOP;
    /* No more data */

    CLOSE c_imp_devl_project;
    COMMIT;

    INSERTS:=nInsertCount;
    UPDATES:=nUpdateCount;
    DUPS:=nDups;

EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
  WHEN OTHERS THEN
   x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.KRS_DEVL_PROJECT',11276,inRun_Id);
   RAISE;
END KRS_DEVL_PROJECT;
------------------------------------------------------------------------------
PROCEDURE CND_DEVL_PROJECT(inRUN_ID    IN  PLS_INTEGER,
                           COMMIT_SIZE IN  PLS_INTEGER,
			   MAX_ERR     IN  PLS_INTEGER,
			   FAILED      IN OUT NOCOPY PLS_INTEGER
			        ) IS

    CURSOR c_imp_devl_project IS
      SELECT DELETED_FLAG, bom_caption_rule_id, nonbom_caption_rule_id,
      orig_sys_ref, name, model_id, model_type, seeded_flag, ROWID FROM CZ_IMP_DEVL_PROJECT
      WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
    /* Internal vars */
	nCommitCount  PLS_INTEGER:=0;	/*COMMIT buffer index */
	nErrorCount   PLS_INTEGER:=0;	/*Error index */
	nFailed       PLS_INTEGER:=0;	/*Failed records */
	nDups         PLS_INTEGER:=0;	/*Duplicate records */
	x_error       BOOLEAN:=FALSE;

    /*Cursor Var for Import */
	p_imp_devl_project    c_imp_devl_project%ROWTYPE;
	x_imp_devl_project_f  BOOLEAN:=FALSE;
    l_msg                     VARCHAR2(2000);
    l_nbr                     NUMBER;
    l_disposition                                   cz_imp_devl_project.disposition%TYPE;
    l_rec_status                                    cz_imp_devl_project.rec_status%TYPE;

    FUNCTION is_rule_id_valid(p_id NUMBER, p_type NUMBER, p_orig_sys_ref IN VARCHAR2) RETURN BOOLEAN
    IS
    l_nbr number;
    BEGIN
          BEGIN
           SELECT 1 INTO l_nbr
           FROM cz_rules a
           WHERE rule_id = p_id
           AND rule_type = p_type
           AND deleted_flag = '0'
           AND (devl_project_id = 0
                 OR
               (devl_project_id <> 0 AND EXISTS
                   (SELECT 1 FROM cz_devl_projects
                    WHERE deleted_flag = '0'
                    AND devl_project_id = a.devl_project_id
                    AND orig_sys_ref = p_orig_sys_ref)))
           AND ROWNUM < 2;

          EXCEPTION
           WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
          END;
          RETURN TRUE;
    END is_rule_id_valid;

BEGIN
    OPEN c_imp_devl_project;
	LOOP

        l_rec_status := NULL;
        l_disposition := NULL;

        FETCH c_imp_devl_project INTO p_imp_devl_project;
        x_imp_devl_project_f:=c_imp_devl_project%FOUND;

        EXIT WHEN NOT x_imp_devl_project_f;

        IF(FAILED >= MAX_ERR) THEN
          x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.CND_DEVL_PROJECT:MAX',11276,inRun_Id);
          RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
        END IF;
        -- only seeded models from contracts can be imported
        IF (p_imp_devl_project.seeded_flag = '1' AND NOT gContractsModel)  THEN
             l_rec_status := 'FAIL';
             l_disposition := 'R';
             l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PRJ_SEEDED_FLG',
                                      'MODELNAME', p_imp_devl_project.name,
                                      'MODLELOSR', p_imp_devl_project.orig_sys_ref
                                     );
             x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_DEVL_PROJECT',11276,inRun_Id);
        END IF;
        -- validate only for generic import, for BOM we populate during extraction so no need for validation
        IF (p_imp_devl_project.bom_caption_rule_id IS NOT NULL AND p_imp_devl_project.model_type NOT IN ('A', 'P', 'N')) THEN
           IF NOT (is_rule_id_valid(p_imp_devl_project.bom_caption_rule_id,
                                    CAPTION_RULE_TYPE,
                                    p_imp_devl_project.orig_sys_ref)
                   OR
                   is_rule_id_valid(p_imp_devl_project.bom_caption_rule_id,
                                    JAVA_SYS_PROP_RULE_TYPE,
                                    p_imp_devl_project.orig_sys_ref)
                  ) THEN
             l_rec_status := 'FAIL';
             l_disposition := 'R';
             l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PRJ_BOM_CPTN_RULE',
                                      'MODELNAME', p_imp_devl_project.name,
                                      'MODLELOSR', p_imp_devl_project.orig_sys_ref
                                                  );
             x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_DEVL_PROJECT',11276,inRun_Id);
           END IF;
        END IF;
        -- validate only for generic import, for BOM we populate during extraction so no need for validation
        IF (p_imp_devl_project.nonbom_caption_rule_id IS NOT NULL AND p_imp_devl_project.model_type NOT IN ('A', 'P', 'N')) THEN
           IF NOT (is_rule_id_valid(p_imp_devl_project.nonbom_caption_rule_id,
                                    CAPTION_RULE_TYPE,
                                    p_imp_devl_project.orig_sys_ref)
                   OR
                   is_rule_id_valid(p_imp_devl_project.nonbom_caption_rule_id,
                                    JAVA_SYS_PROP_RULE_TYPE,
                                    p_imp_devl_project.orig_sys_ref)
                  ) THEN
              l_rec_status := 'FAIL';
              l_disposition := 'R';
              l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PRJ_NONBOM_CPTN_RULE',
                                       'MODELNAME', p_imp_devl_project.name,
                                       'MODLELOSR', p_imp_devl_project.orig_sys_ref
                                                   );
              x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_DEVL_PROJECT',11276,inRun_Id);
            END IF;
        END IF;

           UPDATE CZ_IMP_DEVL_PROJECT SET
           DELETED_FLAG=DECODE(DELETED_FLAG,NULL,'0',DELETED_FLAG),
           SEEDED_FLAG=DECODE(SEEDED_FLAG,NULL,'0',SEEDED_FLAG),
           DISPOSITION=l_disposition,
           REC_STATUS=l_rec_status
           WHERE ROWID = p_imp_devl_project.ROWID;

           nCommitCount:=nCommitCount+1;
           /* COMMIT if the buffer size is reached */
           IF(nCommitCount>= COMMIT_SIZE) THEN
             COMMIT;
             nCommitCount:=0;
           END IF;

      END LOOP;
      CLOSE c_imp_devl_project;

EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.CND_DEVL_PROJECT',11276,inRun_Id);
    RAISE;
END CND_DEVL_PROJECT;
------------------------------------------------------------------------------
PROCEDURE MAIN_DEVL_PROJECT(inRUN_ID    IN     PLS_INTEGER,
                            COMMIT_SIZE IN     PLS_INTEGER,
                            MAX_ERR     IN     PLS_INTEGER,
                            INSERTS     IN OUT NOCOPY PLS_INTEGER,
                            UPDATES     IN OUT NOCOPY PLS_INTEGER,
                            FAILED      IN OUT NOCOPY PLS_INTEGER,
                            DUPS        IN OUT NOCOPY PLS_INTEGER,
                            inXFR_GROUP IN     VARCHAR2,
                            p_rp_folder_id IN  NUMBER
                        ) IS

    /* Internal vars */
    nCommitCount     PLS_INTEGER:=0; /* COMMIT buffer index */
    nErrorCount      PLS_INTEGER:=0; /* Error index */
    nXfrInsertCount  PLS_INTEGER:=0; /* Inserts */
    nXfrUpdateCount  PLS_INTEGER:=0; /* Updates */
    nFailed          PLS_INTEGER:=0; /* Failed records */
    nDups            PLS_INTEGER:=0; /* Dupl records */
    x_error          BOOLEAN:=FALSE;
    dummy            CHAR(1);

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
        END;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

    CND_DEVL_PROJECT(inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     CND projects :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299,inRun_Id);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;

    KRS_DEVL_PROJECT(inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     KRS projects :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299,inRun_Id);
    end if;

    if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
    end if;
      XFR_DEVL_PROJECT(inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,
                       nXfrUpdateCount,FAILED,inXFR_GROUP, p_rp_folder_id);
    if (CZ_IMP_ALL.get_time) then
   		end_time := dbms_utility.get_time();
   		d_str := inRun_id || '     XFR projects :' || (end_time-st_time)/100.00;
       		x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299,inRun_Id);
    end if;

    /* Report Insert Errors */
    IF(nXfrInsertCount<> INSERTS) THEN
      x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'CZ_IMP_PS_NODE.MAIN_DEVL_PROJECT:INSERTS ',11276,inRun_Id);
    END IF;
    /* Report Update Errors */
    IF(nXfrUpdateCount<> UPDATES) THEN
      x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'CZ_IMP_PS_NODE.MAIN_DEVL_PROJECT:UPDATES ',11276,inRun_Id);
    END IF;

    /* Return the transferred number of rows and not the number of rows with keys resolved */
    INSERTS:=nXfrInsertCount;
    UPDATES:=nXfrUpdateCount;

    CZ_IMP_PS_NODE.RPT_DEVL_PROJECT(inRUN_ID);

END MAIN_DEVL_PROJECT;
------------------------------------------------------------------------------
PROCEDURE XFR_DEVL_PROJECT(inRUN_ID    IN  PLS_INTEGER,
                        COMMIT_SIZE IN  PLS_INTEGER,
                        MAX_ERR     IN  PLS_INTEGER,
                        INSERTS     IN OUT NOCOPY PLS_INTEGER,
                        UPDATES     IN OUT NOCOPY PLS_INTEGER,
                        FAILED      IN OUT NOCOPY PLS_INTEGER,
                        inXFR_GROUP       IN    VARCHAR2,
                        p_rp_folder_id IN NUMBER
                       ) IS

    CURSOR c_xfr_devl_project IS
    SELECT * FROM CZ_IMP_DEVL_PROJECT
    WHERE Run_ID=inRUN_ID AND rec_status='PASS'
    ORDER BY model_id, plan_level;

    x_xfr_devl_project_f    BOOLEAN:=FALSE;
    x_error                 BOOLEAN:=FALSE;
    p_xfr_devl_project      c_xfr_devl_project%ROWTYPE;

    copy_child_models       cz_xfr_project_bills.copy_addl_child_models%TYPE;
    server_id               cz_xfr_project_bills.source_server%TYPE;

    dbModelType		    cz_devl_projects.model_type%TYPE;

    -- Internal vars --
    nCommitCount            PLS_INTEGER:=0; -- COMMIT buffer index --
    nInsertCount            PLS_INTEGER:=0; -- Inserts --
    nUpdateCount            PLS_INTEGER:=0; -- Updates --
    nFailed                 PLS_INTEGER:=0; -- Failed records --

    NOUPDATE_NAME           NUMBER;
    NOUPDATE_VERSION        NUMBER;
    NOUPDATE_INTL_TEXT_ID   NUMBER;
    NOUPDATE_CREATION_DATE        NUMBER;
    NOUPDATE_LAST_UPDATE_DATE     NUMBER;
    NOUPDATE_CREATED_BY           NUMBER;
    NOUPDATE_LAST_UPDATED_BY      NUMBER;
    NOUPDATE_DELETED_FLAG   NUMBER;
    NOUPDATE_ORIG_SYS_REF   NUMBER;
    NOUPDATE_DESC_TEXT      NUMBER;
    NOUPDATE_MODEL_TYPE     NUMBER;
    NOUPDATE_PRODUCT_KEY    NUMBER;
    NOUPDATE_ORGANIZATION_ID     NUMBER;
    NOUPDATE_INVENTORY_ITEM_ID   NUMBER;
    NOUPDATE_BOM_CPTN_RULE_ID    NUMBER;
    NOUPDATE_NONBOM_CPTN_RULE_ID NUMBER;
    NOUPDATE_BOM_CPTN_TEXT_ID    NUMBER;
    NOUPDATE_NONBOM_CPTN_TEXT_ID NUMBER;

 BEGIN

 -- Get the Update Flags for each column
      NOUPDATE_NAME          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','NAME',inXFR_GROUP);
      NOUPDATE_VERSION       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','VERSION',inXFR_GROUP);
      NOUPDATE_INTL_TEXT_ID  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','INTL_TEXT_ID',inXFR_GROUP);
      NOUPDATE_CREATION_DATE       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','CREATION_DATE',inXFR_GROUP);
      NOUPDATE_LAST_UPDATE_DATE      := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','LAST_UPDATE_DATE',inXFR_GROUP);
      NOUPDATE_CREATED_BY    := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','CREATED_BY',inXFR_GROUP);
      NOUPDATE_LAST_UPDATED_BY   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','LAST_UPDATED_BY',inXFR_GROUP);
      NOUPDATE_DELETED_FLAG  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','DELETED_FLAG',inXFR_GROUP);
      NOUPDATE_ORIG_SYS_REF  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','ORIG_SYS_REF',inXFR_GROUP);
      NOUPDATE_DESC_TEXT     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','DESC_TEXT',inXFR_GROUP);
      NOUPDATE_MODEL_TYPE     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','MODEL_TYPE',inXFR_GROUP);
      NOUPDATE_INVENTORY_ITEM_ID   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','INVENTORY_ITEM_ID',inXFR_GROUP);
      NOUPDATE_ORGANIZATION_ID := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','ORGANIZATION_ID',inXFR_GROUP);
      NOUPDATE_PRODUCT_KEY     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','PRODUCT_KEY',inXFR_GROUP);
      NOUPDATE_BOM_CPTN_RULE_ID     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','BOM_CAPTION_RULE_ID',inXFR_GROUP);
      NOUPDATE_NONBOM_CPTN_RULE_ID     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','NONBOM_CAPTION_RULE_ID',inXFR_GROUP);
      NOUPDATE_BOM_CPTN_TEXT_ID     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','BOM_CAPTION_TEXT_ID',inXFR_GROUP);
      NOUPDATE_NONBOM_CPTN_TEXT_ID     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_DEVL_PROJECTS','NONBOM_CAPTION_TEXT_ID',inXFR_GROUP);

      OPEN c_xfr_devl_project;
      LOOP
        IF(nCommitCount>= COMMIT_SIZE) THEN
          BEGIN
            COMMIT;
            nCommitCount:=0;
          END;
        ELSE
          nCOmmitCount:=nCommitCount+1;
        END IF;

        FETCH c_xfr_devl_project INTO p_xfr_devl_project;
        x_xfr_devl_project_f:=c_xfr_devl_project%FOUND;
        EXIT WHEN NOT x_xfr_devl_project_f;

       IF(FAILED >= MAX_ERR) THEN
        ROLLBACK;
        x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.XFR_DEVL_PROJECT:MAX',11276,inRun_Id);
        RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
       END IF;

        --
        -- check corectness of CZ_IMP_DEVL_PROJECT.config_engine_type
        --
        IF inXFR_GROUP='GENERIC' THEN
          G_CONFIG_ENGINE_TYPE := p_xfr_devl_project.config_engine_type;
          IF  p_xfr_devl_project.config_engine_type NOT IN('F', 'L') THEN
            ROLLBACK;
            UPDATE cz_imp_devl_project
               SET REC_STATUS='ERR'
             WHERE DEVL_PROJECT_ID=p_xfr_devl_project.DEVL_PROJECT_ID AND RUN_ID=inRUN_ID
                   AND DISPOSITION=p_xfr_devl_project.disposition;

            x_error:=CZ_UTILS.LOG_REPORT('Incorrect value of config_engine_type="'||p_xfr_devl_project.config_engine_type||'"',1,'CZ_IMP_PS_NODE.XFR_DEVL_PROJECT:INSERT',11276,inRun_Id);
            COMMIT;

            RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;

          END IF;

        END IF;

        IF(p_xfr_devl_project.disposition = 'I') THEN
          BEGIN

            INSERT INTO cz_devl_projects (devl_project_id, intl_text_id,
              name, version, deleted_flag, orig_sys_ref, desc_text,
              creation_date, last_update_date, created_by, last_updated_by,
              persistent_project_id, model_type, organization_id, inventory_item_id, product_key,
              bom_caption_rule_id, nonbom_caption_rule_id, config_engine_type)
            VALUES
              (p_xfr_devl_project.devl_project_id,
               p_xfr_devl_project.intl_text_id,
               p_xfr_devl_project.name,
               p_xfr_devl_project.version,
               p_xfr_devl_project.deleted_flag,
               p_xfr_devl_project.orig_sys_ref,
               p_xfr_devl_project.desc_text,
               sysdate, sysdate, -UID, -UID, p_xfr_devl_project.persistent_project_id,
	       p_xfr_devl_project.model_type, p_xfr_devl_project.organization_id,
               p_xfr_devl_project.inventory_item_id, p_xfr_devl_project.product_key,
               p_xfr_devl_project.bom_caption_rule_id, p_xfr_devl_project.nonbom_caption_rule_id, p_xfr_devl_project.config_engine_type);

             nInsertCount:=nInsertCount+1;

             UPDATE cz_imp_devl_project
             SET REC_STATUS='OK'
             WHERE DEVL_PROJECT_ID=p_xfr_devl_project.DEVL_PROJECT_ID AND RUN_ID=inRUN_ID
             AND DISPOSITION='I';

             INSERT INTO CZ_RULE_FOLDERS
             (RULE_FOLDER_ID,NAME,TREE_SEQ,DEVL_PROJECT_ID,CREATED_BY,LAST_UPDATED_BY,
             CREATION_DATE,LAST_UPDATE_DATE,DELETED_FLAG)
             SELECT CZ_RULE_FOLDERS_S.NEXTVAL,p_xfr_devl_project.name||' Rules',0,
             p_xfr_devl_project.devl_project_id,UID,UID,sysdate,sysdate,'0'
             FROM DUAL WHERE NOT EXISTS
             (SELECT 1 FROM CZ_RULE_FOLDERS WHERE
             DEVL_PROJECT_ID=p_xfr_devl_project.devl_project_id AND
             PARENT_RULE_FOLDER_ID IS NULL AND NAME=p_xfr_devl_project.name||' Rules'
             AND deleted_flag = '0');

             INSERT INTO CZ_RP_ENTRIES
             (OBJECT_TYPE,OBJECT_ID,ENCLOSING_FOLDER,NAME,DESCRIPTION,DELETED_FLAG,SEEDED_FLAG)
             SELECT 'PRJ',p_xfr_devl_project.devl_project_id,p_rp_folder_id,
             p_xfr_devl_project.name,p_xfr_devl_project.desc_text,'0',p_xfr_devl_project.seeded_flag
             FROM DUAL WHERE NOT EXISTS
             (SELECT 1 FROM CZ_RP_ENTRIES WHERE deleted_flag = '0' AND (
             (OBJECT_TYPE='PRJ' AND OBJECT_ID=p_xfr_devl_project.devl_project_id) OR
             (ENCLOSING_FOLDER=p_rp_folder_id AND NAME=p_xfr_devl_project.name)));


             IF(p_xfr_devl_project.plan_level = 0)THEN
               UPDATE CZ_XFR_PROJECT_BILLS SET
               MODEL_PS_NODE_ID=p_xfr_devl_project.devl_project_id,
               DESCRIPTION=p_xfr_devl_project.desc_text,
               COMPONENT_ITEM_ID=p_xfr_devl_project.top_item_id,
               LAST_IMPORT_RUN_ID=inRUN_ID,
               LAST_IMPORT_DATE=SYSDATE
               WHERE ORGANIZATION_ID=p_xfr_devl_project.ORGANIZATION_ID AND
               TOP_ITEM_ID=p_xfr_devl_project.TOP_ITEM_ID AND
               EXPLOSION_TYPE=p_xfr_devl_project.EXPLOSION_TYPE AND
               MODEL_PS_NODE_ID = p_xfr_devl_project.model_id
               RETURNING copy_addl_child_models,source_server INTO copy_child_models, server_id;

             ELSE
               INSERT INTO cz_xfr_project_bills
               (model_ps_node_id, description, component_item_id, last_import_run_id,
               last_import_date, organization_id, top_item_id, explosion_type,
               copy_addl_child_models, source_server, deleted_flag)
               SELECT p_xfr_devl_project.devl_project_id, p_xfr_devl_project.desc_text,
               p_xfr_devl_project.top_item_id, inRUN_ID, SYSDATE,
               NVL(p_xfr_devl_project.ORGANIZATION_ID, 0), NVL(p_xfr_devl_project.TOP_ITEM_ID, 0),
               NVL(p_xfr_devl_project.EXPLOSION_TYPE, 'GENERIC'), '0', NVL(server_id, 0), '0'
               FROM DUAL WHERE NOT EXISTS
               (SELECT NULL FROM cz_xfr_project_bills
               WHERE model_ps_node_id = p_xfr_devl_project.devl_project_id
               AND deleted_flag = '0');
             END IF;

           EXCEPTION
             WHEN OTHERS THEN
                FAILED:=FAILED +1;
                UPDATE cz_imp_devl_project  SET REC_STATUS='ERR'
                WHERE DEVL_PROJECT_ID=p_xfr_devl_project.DEVL_PROJECT_ID AND RUN_ID=inRUN_ID
                AND DISPOSITION='I';
                x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.XFR_DEVL_PROJECT:INSERT',11276,inRun_Id);
           END;

       ELSIF(p_xfr_devl_project.disposition = 'M') THEN
          BEGIN

           UPDATE cz_devl_projects SET
             intl_text_id=DECODE(NOUPDATE_INTL_TEXT_ID,0,p_xfr_devl_project.intl_text_id,intl_text_id),
             name=DECODE(NOUPDATE_NAME,0,p_xfr_devl_project.name,name),
             version=DECODE(NOUPDATE_VERSION,0,p_xfr_devl_project.version,version),
             deleted_flag=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_devl_project.deleted_flag,deleted_flag),
             orig_sys_ref=DECODE(NOUPDATE_DELETED_FLAG,0,p_xfr_devl_project.orig_sys_ref,orig_sys_ref),
             desc_text=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_devl_project.desc_text,desc_text),
             LAST_UPDATE_DATE=DECODE(NOUPDATE_LAST_UPDATE_DATE,0,sysdate,LAST_UPDATE_DATE),
             LAST_UPDATED_BY=DECODE(NOUPDATE_LAST_UPDATED_BY,0,-UID,LAST_UPDATED_BY),
             MODEL_TYPE = DECODE(NOUPDATE_MODEL_TYPE,0,p_xfr_devl_project.model_type),
             organization_id=DECODE(NOUPDATE_ORGANIZATION_ID,0,p_xfr_devl_project.organization_id,organization_id),
             inventory_item_id=DECODE(NOUPDATE_INVENTORY_ITEM_ID,0,p_xfr_devl_project.inventory_item_id,inventory_item_id),
             product_key= DECODE(NOUPDATE_PRODUCT_KEY,0,p_xfr_devl_project.product_key,product_key),
             bom_caption_rule_id= DECODE(NOUPDATE_BOM_CPTN_RULE_ID,0,p_xfr_devl_project.bom_caption_rule_id,bom_caption_rule_id),
             nonbom_caption_rule_id= DECODE(NOUPDATE_NONBOM_CPTN_RULE_ID,0,p_xfr_devl_project.nonbom_caption_rule_id,nonbom_caption_rule_id)
           WHERE devl_project_id=p_xfr_devl_project.devl_project_id;

           IF(SQL%NOTFOUND) THEN
               FAILED:=FAILED+1;
           ELSE
               nUpdateCount:=nUpdateCount+1;
               UPDATE cz_imp_devl_project
               SET REC_STATUS='OK'
               WHERE DEVL_PROJECT_ID=p_xfr_devl_project.DEVL_PROJECT_ID AND RUN_ID=inRUN_ID
               AND DISPOSITION='M';
           END IF;

           UPDATE CZ_RP_ENTRIES SET
            NAME = DECODE(NOUPDATE_NAME,0,p_xfr_devl_project.name,name),
            DESCRIPTION = DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_devl_project.desc_text,description),
            DELETED_FLAG = '0',
            SEEDED_FLAG = p_xfr_devl_project.seeded_flag
           WHERE OBJECT_TYPE='PRJ' AND OBJECT_ID=p_xfr_devl_project.devl_project_id
           AND NOT EXISTS
           (SELECT 1 FROM CZ_RP_ENTRIES
           WHERE ENCLOSING_FOLDER=0
           AND NAME=p_xfr_devl_project.name
           AND deleted_flag = '0');
-- dbms_output.put_line ('Updating .. M : ' || p_xfr_devl_project.devl_project_id);

           UPDATE CZ_XFR_PROJECT_BILLS SET
            DESCRIPTION=DECODE(NOUPDATE_DESC_TEXT,0,p_xfr_devl_project.desc_text,description),
            COMPONENT_ITEM_ID=p_xfr_devl_project.top_item_id,
            LAST_IMPORT_RUN_ID=inRUN_ID,
            LAST_IMPORT_DATE=SYSDATE,
            deleted_flag = '0'
           WHERE ORGANIZATION_ID=p_xfr_devl_project.ORGANIZATION_ID AND
           TOP_ITEM_ID=p_xfr_devl_project.TOP_ITEM_ID AND
           EXPLOSION_TYPE=p_xfr_devl_project.EXPLOSION_TYPE AND
           MODEL_PS_NODE_ID = p_xfr_devl_project.devl_project_id
           RETURNING copy_addl_child_models, source_server INTO copy_child_models, server_id;

           --This was necessary because cz_refs won't update explosions when creating new copies of
           --child models. However, this brings in problems when refreshing BOM models with
           --eventually created rules. As the functionality of creating new copies of child models
           --is frozen, we can go without this thus not having problems refreshing with rules.

           --DELETE FROM cz_model_ref_expls WHERE model_id = p_xfr_devl_project.devl_project_id
           --AND parent_expl_node_id IS NOT NULL;

         EXCEPTION
           WHEN OTHERS THEN
             FAILED:=FAILED +1;

             UPDATE cz_imp_devl_project SET REC_STATUS='ERR'
             WHERE DEVL_PROJECT_ID=p_xfr_devl_project.DEVL_PROJECT_ID AND RUN_ID=inRUN_ID
             AND DISPOSITION='M';
             x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.XFR_DEVL_PROJECT:UPDATE',11276,inRun_Id);
        END ;
       END IF;
      END LOOP;

      CLOSE c_xfr_devl_project;
      COMMIT;
      INSERTS:=nInsertCount;
      UPDATES:=nUpdateCount;
EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
  WHEN OTHERS THEN
   x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.XFR_DEVL_PROJECT',11276,inRun_Id);
   RAISE;
END XFR_DEVL_PROJECT;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE RPT_DEVL_PROJECT ( inRUN_ID IN PLS_INTEGER ) AS
                               x_error     BOOLEAN:=FALSE;

    v_table_name  VARCHAR2(30) := 'CZ_DEVL_PROJECTS';
    v_ok          VARCHAR2(4)  := 'OK';
    v_completed   VARCHAR2(1)  := '1';

        CURSOR c_xfr_run_result IS
        SELECT DISPOSITION,REC_STATUS,COUNT(*)
        FROM cz_imp_devl_project
        WHERE RUN_ID = inRUN_ID
        GROUP BY DISPOSITION,REC_STATUS;

        ins_disposition        CZ_XFR_RUN_RESULTS.disposition%TYPE;
        ins_rec_status         CZ_XFR_RUN_RESULTS.rec_status%TYPE ;
        ins_rec_count          CZ_XFR_RUN_RESULTS.records%TYPE    ;

BEGIN
       BEGIN
         DELETE FROM CZ_XFR_RUN_RESULTS WHERE RUN_ID=inRUN_ID AND IMP_TABLE=v_table_name;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
       END;

       OPEN c_xfr_run_result;
       LOOP
           FETCH c_xfr_run_result INTO ins_disposition,ins_rec_status,ins_rec_count;
           EXIT WHEN c_xfr_run_result%NOTFOUND;

           INSERT INTO CZ_XFR_RUN_RESULTS  (RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
           VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);
       END LOOP;
       CLOSE c_xfr_run_result;
       COMMIT;

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
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_DEVL_PROJECT',11276,inRun_Id);
              END;
EXCEPTION
    WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
      RAISE;
    WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
      RAISE;
    WHEN OTHERS THEN
      x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_DEVL_PROJECT',11276,inRun_Id);
      RAISE;
END;
/*--DEVL_PROJECT IMPORT SECTION END-----------------------------------------*/

/*--PS_NODE IMPORT SECTION START--------------------------------------------*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE KRS_PS_NODE (inRUN_ID     IN  PLS_INTEGER,
                       COMMIT_SIZE  IN  PLS_INTEGER,
                       MAX_ERR      IN  PLS_INTEGER,
                       INSERTS      IN OUT NOCOPY PLS_INTEGER,
                       UPDATES      IN OUT NOCOPY PLS_INTEGER,
                       FAILED       IN OUT NOCOPY PLS_INTEGER,
                       DUPS         IN OUT NOCOPY PLS_INTEGER,
                              inXFR_GROUP       IN    VARCHAR2
                      ) IS

      TYPE tStringArray IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

            CURSOR c_imp_psnode (x_usesurr_psnode PLS_INTEGER,
                                 x_usesurr_intltext PLS_INTEGER,
                                 x_usesurr_itemmaster PLS_INTEGER,
                                 x_usesurr_devlproject PLS_INTEGER)
            IS
            SELECT PLAN_LEVEL,ORIG_SYS_REF,USER_STR03,DEVL_PROJECT_ID,PS_NODE_TYPE,NAME,
              FSK_INTLTEXT_1_1,FSK_INTLTEXT_1_EXT,
              FSK_ITEMMASTER_2_1,FSK_ITEMMASTER_2_EXT,
              FSK_PSNODE_3_1,FSK_PSNODE_3_EXT,
              FSK_PSNODE_4_1,FSK_PSNODE_4_EXT,
              FSK_DEVLPROJECT_5_1,FSK_DEVLPROJECT_5_EXT,
              fsk_psnode_6_1, COMPONENT_SEQUENCE_PATH, ROWID, MINIMUM, MAXIMUM,
              nvl(SRC_APPLICATION_ID, cnDefSrcAppId),
              nvl(FSK_ITEMMASTER_2_2, cnDefSrcAppId)
            FROM CZ_IMP_PS_NODES WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID
            ORDER BY PLAN_LEVEL,
              DECODE(x_usesurr_psnode,0,ORIG_SYS_REF,1,USER_STR03),
              DECODE(x_usesurr_intltext,0,FSK_INTLTEXT_1_1,1,FSK_INTLTEXT_1_EXT),
              DECODE(x_usesurr_itemmaster,0,FSK_ITEMMASTER_2_1,1,FSK_ITEMMASTER_2_EXT),
              DECODE(x_usesurr_psnode,0,FSK_PSNODE_3_1,1,FSK_PSNODE_3_EXT),
              DECODE(x_usesurr_devlproject,0,FSK_DEVLPROJECT_5_1,1,FSK_DEVLPROJECT_5_EXT),
              ROWID;

 		/* cursor's data found indicator */
		x_imp_psnode_psnodeid_f			    	      BOOLEAN:=FALSE;
		x_onl_intltext_intltextid_f				BOOLEAN:=FALSE;
		X_ONL_ITEMMASTER_ITEMID_F				BOOLEAN:=FALSE;
		x_onl_psnode_parentid_f					BOOLEAN:=FALSE;
		x_onl_psnode_psnodeid_f					BOOLEAN:=FALSE;
		x_onl_devlprj_devlprjid_f                       BOOLEAN:=FALSE;
                x_onl_reference_f                               BOOLEAN:=FALSE;
		x_error							BOOLEAN:=FALSE;
		x_project_f							BOOLEAN:=FALSE;
		sImpOrigsysref	 					CZ_IMP_PS_NODES.ORIG_SYS_REF%TYPE;
		sImpUserstr03						CZ_IMP_PS_NODES.USER_STR03%TYPE;
		nOnlPsnodeId						CZ_IMP_PS_NODES.PS_NODE_ID%TYPE;
		nImpParentId						CZ_IMP_PS_NODES.PARENT_ID%TYPE;
		nOnlParentId						CZ_IMP_PS_NODES.PARENT_ID%TYPE;
		nImpPlanLevel						CZ_IMP_PS_NODES.PLAN_LEVEL%TYPE;
		nOnlItemId							CZ_IMP_PS_NODES.ITEM_ID%TYPE;
		nReferredItemId						CZ_IMP_PS_NODES.ITEM_ID%TYPE;
		nOnlIntlTextId						CZ_IMP_PS_NODES.INTL_TEXT_ID%TYPE;
		nOnlDevlProjectId						CZ_IMP_PS_NODES.DEVL_PROJECT_ID%TYPE;
		nOnlReference						CZ_IMP_PS_NODES.PS_NODE_ID%TYPE;
                localName                                       CZ_IMP_PS_NODES.NAME%TYPE;
                nImpTreeSeq                                     CZ_IMP_PS_NODES.COMPONENT_SEQUENCE_PATH%TYPE;
  		sFSKINTLTEXT11						    CZ_IMP_PS_NODES.FSK_INTLTEXT_1_1%TYPE;
		sFSKINTLTEXT1EXT						CZ_IMP_PS_NODES.FSK_INTLTEXT_1_EXT%TYPE;
  		sFSKITEMMASTER21						CZ_IMP_PS_NODES.FSK_ITEMMASTER_2_1%TYPE;
		sFSKITEMMASTER2EXT					    CZ_IMP_PS_NODES.FSK_ITEMMASTER_2_EXT%TYPE;
                nFSKITEMMASTER22						CZ_IMP_PS_NODES.FSK_ITEMMASTER_2_2%TYPE;
                nImpSrcApplicationId					CZ_IMP_PS_NODES.SRC_APPLICATION_ID%TYPE;
  		sFSKPSNODE31						CZ_IMP_PS_NODES.FSK_PSNODE_3_1%TYPE;
		sFSKPSNODE3EXT						CZ_IMP_PS_NODES.FSK_PSNODE_3_EXT%TYPE;
  		sFSKPSNODE41						CZ_IMP_PS_NODES.FSK_PSNODE_4_1%TYPE;
		sFSKPSNODE4EXT						CZ_IMP_PS_NODES.FSK_PSNODE_4_EXT%TYPE;
  		sFSKDEVLPROJECT51						CZ_IMP_PS_NODES.FSK_DEVLPROJECT_5_1%TYPE;
		sFSKDEVLPROJECT5EXT					CZ_IMP_PS_NODES.FSK_DEVLPROJECT_5_EXT%TYPE;
                sFSKREFERENCE                                   CZ_IMP_PS_NODES.fsk_psnode_6_1%TYPE;
		sLastFSK							CZ_IMP_PS_NODES.NAME%TYPE;
		sThisFSK							CZ_IMP_PS_NODES.NAME%TYPE;
		nLastTreeSeq 						CZ_IMP_PS_NODES.COMPONENT_SEQUENCE_PATH%TYPE;
		nThisTreeSeq						CZ_IMP_PS_NODES.COMPONENT_SEQUENCE_PATH%TYPE;
		sRecStatus							CZ_IMP_PS_NODES.REC_STATUS%TYPE;
		sDisposition						CZ_IMP_PS_NODES.DISPOSITION%TYPE;
            sOnlItemRefPartNbr                              CZ_IMP_PS_NODES.NAME%TYPE;
            nDevlProjectId                                  CZ_IMP_PS_NODES.DEVL_PROJECT_ID%TYPE;
            nPsNodeType                                     CZ_IMP_PS_NODES.PS_NODE_TYPE%TYPE;
            sPsNodeName                                     CZ_DB_SETTINGS.VALUE%TYPE;
            cDeletedFlag                                    CZ_DEVL_PROJECTS.DELETED_FLAG%TYPE;
            cDummyDeletedFlag                               CZ_DEVL_PROJECTS.DELETED_FLAG%TYPE;

	sMinimum				CZ_IMP_PS_NODES.MINIMUM%TYPE;
        sMaximum                                CZ_IMP_PS_NODES.MAXIMUM%TYPE;
	impMinimum				CZ_IMP_PS_NODES.MINIMUM%TYPE;
        impMaximum                              CZ_IMP_PS_NODES.MAXIMUM%TYPE;
	nModelType				CZ_DEVL_PROJECTS.MODEL_TYPE%TYPE;
        ibTrackable                             cz_imp_ps_nodes.ib_trackable%TYPE;

	/* Internal vars */
	nCommitCount				PLS_INTEGER:=0;			/*COMMIT buffer index */
	nErrorCount				PLS_INTEGER:=0;			/*Error index */
	nInsertCount				PLS_INTEGER:=0;			/*Inserts */
	nUpdateCount				PLS_INTEGER:=0;			/*Updates */
	nFailed					PLS_INTEGER:=0;	            /*Failed records */
	nDups					PLS_INTEGER:=0;			/*Dupl records */
	x_usesurr_psnode			PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_PS_NODES',inXFR_GROUP);
		x_usesurr_intltext		PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_INTL_TEXTS',inXFR_GROUP);
		x_usesurr_itemmaster		PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_MASTERS',inXFR_GROUP);
		x_usesurr_devlproject		PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_DEVL_PROJECTS',inXFR_GROUP);
     nAllocateBlock              PLS_INTEGER:=1;
     nAllocateCounter            PLS_INTEGER;
     nNextValue                  NUMBER;
     nNextId                     NUMBER;
     NamePrefix                  VARCHAR2(8);
     p_out_err              INTEGER;

     thisRowId              ROWID;

     nDebug                 PLS_INTEGER := 1000;
     nCounter               PLS_INTEGER;

     tabName                tStringArray;
     tabParentRef           tStringArray;


     nOnlMaxtreeSeq_forParent  CZ_PS_NODES.TREE_SEQ%TYPE;
     nNextTreeSeq              number;
     nSameParentTreeSeq        number;
     thisParentId              number;

     v_settings_id      VARCHAR2(40);
     v_section_name     VARCHAR2(30);
BEGIN

nDebug := 1001;

    v_settings_id := 'OracleSequenceIncr';
    v_section_name := 'SCHEMA';

    BEGIN
     SELECT VALUE INTO nAllocateBlock FROM CZ_DB_SETTINGS
     WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
    EXCEPTION
      WHEN OTHERS THEN
        nAllocateBlock:=1;
    END;

    v_settings_id := 'PsNodeName';
    v_section_name := 'ORAAPPS_INTEGRATE';

    BEGIN
     SELECT VALUE INTO sPsNodeName FROM CZ_DB_SETTINGS
     WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    nAllocateCounter:=nAllocateBlock-1;

nDebug := 1002;

		OPEN c_imp_psnode(x_usesurr_psnode,x_usesurr_intltext,x_usesurr_itemmaster,x_usesurr_devlproject);

nDebug := 1003;

		LOOP
nDebug := 1004;
			/* COMMIT if the buffer size is reached */
			IF (nCommitCount>= COMMIT_SIZE) THEN
				BEGIN
					COMMIT;
					nCommitCount:=0;
				END;
			ELSE
				nCOmmitCount:=nCommitCount+1;
			END IF;
nDebug := 1005;
		nImpPlanLevel:=NULL; sImpUserstr03:=NULL; sImpOrigsysref:=NULL;
                  nDevlProjectId:=NULL; sFSKINTLTEXT11:=NULL; sFSKINTLTEXT1EXT:=NULL;
                  sFSKITEMMASTER21:=NULL; sFSKITEMMASTER2EXT:=NULL;
                  sFSKPSNODE31:=NULL; sFSKPSNODE3EXT:=NULL; localName := NULL;
                  sFSKPSNODE41:=NULL; sFSKPSNODE4EXT:=NULL; nPsNodeType := NULL;
                  sFSKDEVLPROJECT51:=NULL; sFSKDEVLPROJECT5EXT:=NULL; sFSKREFERENCE := NULL;
                  nImpTreeSeq := NULL;nImpSrcApplicationId:=NULL; nFSKITEMMASTER22:=NULL;
		FETCH c_imp_psnode INTO
                   nImpPlanLevel,sImpOrigsysref,sImpUserstr03,nDevlProjectId, nPsNodeType, localName,
                   sFSKINTLTEXT11,sFSKINTLTEXT1EXT,sFSKITEMMASTER21,sFSKITEMMASTER2EXT,
                   sFSKPSNODE31,sFSKPSNODE3EXT,sFSKPSNODE41,sFSKPSNODE4EXT,
                   sFSKDEVLPROJECT51,sFSKDEVLPROJECT5EXT,sFSKREFERENCE,nImpTreeSeq, thisRowId,
                   impMinimum, impMaximum, nImpSrcApplicationId, nFSKITEMMASTER22;
		IF(x_usesurr_psnode=1) THEN
			sThisFSK:=sImpUserStr03;
		ELSE
			sThisFSK:=sImpOrigsysref;
		END IF;
                  nThisTreeSeq := nImpTreeSeq;
nDebug := 1006;
		x_imp_psnode_psnodeid_f:=c_imp_psnode%FOUND;
		EXIT WHEN NOT x_imp_psnode_psnodeid_f;

		/* Check that the Online data exists for the 2 FSK */
		DECLARE
		 CURSOR c_onl_itemmaster IS
		 SELECT ITEM_ID,REF_PART_NBR FROM CZ_ITEM_MASTERS
                 WHERE ORIG_SYS_REF=sFSKITEMMASTER21 AND deleted_flag = '0'
                 AND SRC_APPLICATION_ID=nFSKITEMMASTER22;
		 CURSOR c_onl_itemmaster_usesurr IS
        	 SELECT ITEM_ID,REF_PART_NBR FROM CZ_ITEM_MASTERS
                 WHERE ORIG_SYS_REF=sFSKITEMMASTER2EXT AND deleted_flag = '0'
                 AND SRC_APPLICATION_ID=nFSKITEMMASTER22;
        	BEGIN
nDebug := 1009;
                  nonlitemid:=NULL; sOnlItemRefPartNbr:=NULL;
                 IF( x_usesurr_itemmaster = 0 ) THEN
                   OPEN  c_onl_itemmaster;
                   FETCH c_onl_itemmaster INTO nonlitemid,sOnlItemRefPartNbr;
	           x_onl_itemmaster_itemid_f:=c_onl_itemmaster%FOUND;
                   CLOSE c_onl_itemmaster;
                 ELSE
		   OPEN  c_onl_itemmaster_usesurr;
		   FETCH c_onl_itemmaster_usesurr INTO nonlitemid,sOnlItemRefPartNbr;
		   x_onl_itemmaster_itemid_f:=c_onl_itemmaster_usesurr%FOUND;
                   CLOSE c_onl_itemmaster_usesurr;
                 END IF;
nDebug := 1010;
		END;

		/* Check that the Online data exists for the 3 FSK */
		DECLARE
		  CURSOR c_onl_psnode_parentid IS
		  SELECT PS_NODE_ID, PLAN_LEVEL FROM CZ_IMP_PS_NODES WHERE ORIG_SYS_REF=DECODE(x_usesurr_psnode, 0, sFSKPSNODE31, 1, sFSKPSNODE3EXT)
                  AND DEVL_PROJECT_ID=nDevlProjectId AND RUN_ID=inRUN_ID
                  AND ps_node_id IS NOT NULL
                  AND src_application_id = nImpSrcApplicationId
                  AND NVL(COMPONENT_SEQUENCE_PATH, -1) = NVL(SUBSTR(nImpTreeSeq, 1, INSTR(nImpTreeSeq, '-', -1, 1) - 1), -1);
		BEGIN
nDebug := 1011;
		  OPEN  c_onl_psnode_parentid;
		  nImpparentid:=NULL;
		  FETCH c_onl_psnode_parentid INTO nImpparentid, nImpPlanLevel;
		  x_onl_psnode_parentid_f:=c_onl_psnode_parentid%FOUND;
		  CLOSE c_onl_psnode_parentid;
nDebug := 1012;
		END;

		/* Check the PSNODE Data from Online Dbase */
		DECLARE
		 CURSOR c_onl_psnode IS
		  SELECT PS_NODE_ID,PARENT_ID,NAME FROM CZ_PS_NODES
                  WHERE ORIG_SYS_REF=DECODE(x_usesurr_psnode,0, sImpOrigsysref, 1, sImpUserstr03)
                  AND DEVL_PROJECT_ID = nDevlProjectId
                  AND NVL(COMPONENT_SEQUENCE_PATH, -1) = NVL(nImpTreeSeq, -1)
                  AND deleted_flag = '0'
                  AND src_application_id = nImpSrcApplicationId;
		BEGIN
nDebug := 1013;
		  OPEN  c_onl_psnode;
		  nOnlPsnodeId:=NULL;
		  FETCH c_onl_psnode INTO  nOnlPsnodeId,nOnlParentId,localName;
		  x_onl_psnode_psnodeId_f:=c_onl_psnode%FOUND;
		  CLOSE c_onl_psnode;
nDebug := 1014;
	        END;

                  IF(nPsNodeType = cnReference)THEN
                    DECLARE
                     CURSOR c_onl_reference IS
                      SELECT PS_NODE_ID, devl_project_id, item_id, ib_trackable FROM CZ_IMP_PS_NODES
                      WHERE ORIG_SYS_REF = sFSKREFERENCE
                        AND RUN_ID=inRun_ID
                        AND ps_node_id IS NOT NULL;
                     CURSOR c_model_type IS
                      SELECT model_type FROM cz_imp_devl_project
                       WHERE devl_project_id = nDevlProjectId
                         AND RUN_ID=inRun_ID;
                     CURSOR c_onl_name IS
                      SELECT name FROM cz_imp_devl_project
                      WHERE devl_project_id = nOnlDevlProjectId
                        AND RUN_ID=inRun_ID;
                     CURSOR c_onl_refpartnbr IS
                      SELECT ref_part_nbr FROM cz_item_masters
                      WHERE item_id = nReferredItemId;
                     CURSOR c_reference IS
                      SELECT p.PS_NODE_ID, p.devl_project_id, p.item_id FROM CZ_PS_NODES p, CZ_DEVL_PROJECTS d
                      WHERE p.ORIG_SYS_REF = sFSKREFERENCE
                        AND p.ps_node_id = p.persistent_node_id
                        AND p.deleted_flag = '0'
                        AND p.ps_node_id = d.devl_project_id
                        AND d.deleted_flag = '0';

                    BEGIN
nDebug := 1015;
                       OPEN c_onl_reference;
                       nOnlReference := NULL;
                       FETCH c_onl_reference INTO nOnlReference, nOnlDevlProjectId, nReferredItemId, ibTrackable;
                       x_onl_reference_f := c_onl_reference%FOUND;
                       CLOSE c_onl_reference;
nDebug := 1016;
                       IF(x_onl_reference_f)THEN

                         OPEN c_model_type;
                         FETCH c_model_type INTO nModelType;
                         CLOSE c_model_type;

                         IF(sPsNodeName = 'DESCRIPTION')THEN
                          OPEN c_onl_name;
                          FETCH c_onl_name INTO localName;
                          CLOSE c_onl_name;
                         ELSE
                          OPEN c_onl_refpartnbr;
                          FETCH c_onl_refpartnbr INTO localName;
                          CLOSE c_onl_refpartnbr;
                         END IF;

                         tabName(tabName.COUNT + 1) := localName;
                         tabParentRef(tabParentRef.COUNT + 1) := sFSKPSNODE31;

                         nCounter := 0;

                         FOR i IN 1..tabName.COUNT LOOP
                           IF(tabName(i) = localName AND tabParentRef(i) = sFSKPSNODE31)THEN
                             nCounter := nCounter + 1;
                           END IF;
                         END LOOP;

                         IF(nCounter > 1)THEN
                           localName := localName || ' (' || TO_CHAR(nCounter) || ')';
                         END IF;

			     -- Stellar bug
                       ELSE
                         -- get reference_id, name into localName
                         -- nOnlReference := cz_imp_single.childModelExists(inRun_Id,inOrgId,inTopId,inExplType);

                         OPEN c_reference;
                         nOnlReference := NULL;
                         FETCH c_reference INTO nOnlReference, nOnlDevlProjectId, nReferredItemId;
                         x_onl_reference_f := c_reference%FOUND;
                         CLOSE c_reference;

                         tabName(tabName.COUNT + 1) := localName;
                         tabParentRef(tabParentRef.COUNT + 1) := sFSKPSNODE31;

                         nCounter := 0;

                         FOR i IN 1..tabName.COUNT LOOP
                           IF(tabName(i) = localName AND tabParentRef(i) = sFSKPSNODE31)THEN
                             nCounter := nCounter + 1;
                           END IF;
                         END LOOP;

                         IF(nCounter > 1)THEN
                           localName := localName || ' (' || TO_CHAR(nCounter) || ')';
                         END IF;
			     -- Stellar bug end
                       END IF;
                    END;
                  ELSE
                   x_onl_reference_f := TRUE;
                  END IF;

nDebug := 1017;

		IF((NOT x_onl_reference_f OR (nPsNodeType = cnReference AND sFSKREFERENCE IS NULL)) OR
	           (NOT x_onl_itemmaster_itemid_f AND ((x_usesurr_itemmaster=0 AND sFSKITEMMASTER21 IS NOT NULL) OR
	           (x_usesurr_itemmaster=1 AND sFSKITEMMASTER2EXT IS NOT NULL))
                    AND nImpPlanLevel>1) OR
	           (NOT x_onl_psnode_parentid_f AND nImpPlanLevel<>0) OR
	           (x_usesurr_psnode=1 AND sImpUserstr03 IS NULL) OR
	           (x_usesurr_psnode=0 AND sImpOrigsysref IS NULL) OR
                    nDevlProjectId IS NULL
                    /*OR (NOT x_onl_devlprj_devlprjid_f) OR
                     (x_usesurr_devlproject=0 AND sFSKDEVLPROJECT51 IS NULL) OR
                     (x_usesurr_devlproject=1 AND sFSKDEVLPROJECT5EXT IS NULL)*/) THEN
		    BEGIN
			FAILED:=FAILED+1;
			IF(x_usesurr_psnode=1 AND sImpUserstr03 IS NULL) THEN
				sRecStatus:='N35';
			ELSIF(x_usesurr_psnode=0 AND sImpOrigsysref IS NULL ) THEN
					sRecStatus:='N9';
			ELSIF(nDevlProjectId IS NULL) THEN
					sRecStatus:='N3';
			ELSIF(NOT x_onl_itemmaster_itemid_f AND x_usesurr_itemmaster=1 AND sFSKITEMMASTER2EXT IS NOT NULL) THEN
   		 	                       sRecStatus:='F47';
			ELSIF(NOT x_onl_itemmaster_itemid_f AND x_usesurr_itemmaster=0 AND sFSKITEMMASTER21 IS NOT NULL) THEN
					sRecStatus:='F46';
			ELSIF(NOT x_onl_psnode_parentid_f AND nImpPlanLevel<>0 AND x_usesurr_psnode=1 AND sFSKPSNODE3EXT IS NULL) THEN
					sRecStatus:='N49';
			ELSIF(NOT x_onl_psnode_parentid_f AND nImpPlanLevel<>0 AND x_usesurr_psnode=1) THEN
					sRecStatus:='F49';
			ELSIF(NOT x_onl_psnode_parentid_f AND nImpPlanLevel<>0 AND x_usesurr_psnode=0 AND sFSKPSNODE31 IS NULL) THEN
					sRecStatus:='N48';
			ELSIF(NOT x_onl_psnode_parentid_f AND nImpPlanLevel<>0 AND x_usesurr_psnode=0) THEN
					sRecStatus:='F48';
			ELSIF(NOT x_onl_reference_f AND sFSKREFERENCE IS NULL)THEN
					sRecStatus:='N52';
			ELSIF(NOT x_onl_reference_f AND sFSKREFERENCE IS NOT NULL)THEN
					sRecStatus:='F52';
			ELSE
					sRecStatus:='XXX';
			END IF;
			sDisposition:='R';
		    END;
		ELSE
nDebug := 1018;
		/*  Insert or update */
		BEGIN
    		  IF((sLastFSK IS NOT NULL AND sLastFSK=sThisFSK) AND
                   ((nLastTreeSeq IS NULL AND nPsNodeType = bomModel) OR
                   (nLastTreeSeq IS NOT NULL AND nLastTreeSeq = nThisTreeSeq))) THEN
	            /* This is a duplicate record */
			sRecStatus:='DUPL';
			sDisposition:='R';
			nDups:=nDups+1;
	  	  ELSE
nDebug := 1019;
		    BEGIN
                      sRecStatus:='PASS';

                      NamePrefix := NULL;

                      IF(x_onl_psnode_psnodeid_f)THEN
nDebug := 1020;
                       /* We cannot recreate references because we currently have no mechanism
                        to update model_ref_expl_id of rules' participants

                        IF(nPsNodeType = cnReference)THEN

                          UPDATE cz_ps_nodes SET deleted_flag='1' WHERE ps_node_id = nOnlPsnodeId;
                          cz_refs.delete_Node(nOnlPsnodeId, cnReference, p_out_err, '1');
                          sDisposition:='I';
                          nInsertCount:=nInsertCount+1;
                          nAllocateCounter:=nAllocateCounter+1;
                          IF(nAllocateCounter=nAllocateBlock)THEN
                          nAllocateCounter:=0;
                          SELECT CZ_PS_NODES_S.NEXTVAL INTO nNextValue FROM DUAL;
                        END IF;
                        nNextId := nNextValue+nAllocateCounter;
nDebug := 1021;
                      ELSE
                    */
		      sDisposition:='M';
		      nUpdateCount:=nUpdateCount+1;

                      --END IF;

		      ELSE
		      /*Insert */
nDebug := 1022;
                        sDisposition:='I';
                        nInsertCount:=nInsertCount+1;

                        IF(nPsNodeType NOT IN (cnModel, bomModel) AND
                          (nPsNodeType NOT IN (cnProduct, cnComponent) OR nImpParentId IS NOT NULL))THEN

                          nAllocateCounter:=nAllocateCounter+1;
                          IF(nAllocateCounter=nAllocateBlock)THEN
                            nAllocateCounter:=0;
                            SELECT CZ_PS_NODES_S.NEXTVAL INTO nNextValue FROM DUAL;
                          END IF;
                          nNextId := nNextValue+nAllocateCounter;
nDebug := 1023;
                        ELSE

                         nNextId := nDevlProjectId;
                        END IF;
		      END IF;
		    END;
		  END IF;
		END;
               END IF;
nDebug := 1024;

              -- If the reference model is trackable and if its immediate parent BOM
              -- is a Container model, set its min/max or 0/N on insert. Don't update on refresh.

              IF(nPsNodeType = cnReference AND ibTrackable = '1' AND nModelType = 'N')THEN

                IF(sDisposition = 'M')THEN
                  SELECT nvl(MINIMUM,0), nvl(MAXIMUM,-1) INTO sMinimum, sMaximum
		         FROM CZ_PS_NODES
		         WHERE PS_NODE_ID = nOnlPsnodeId
		         AND DELETED_FLAG = '0';
                ELSE
                  sMinimum := 0;
                  sMaximum := -1;
                END IF;
              END IF;

		  -- Don't update min/max for references in a model (PTO)
		  -- For an existing reference, get min/max values from cz_ps_nodes

			DECLARE
			 CURSOR c_node IS
			  SELECT model_type
		    	  FROM CZ_DEVL_PROJECTS
		    	  WHERE DEVL_PROJECT_ID IN (SELECT PARENT_ID FROM CZ_PS_NODES
							  	WHERE PS_NODE_ID = nOnlPsnodeId
								AND DELETED_FLAG = '0')
			   AND DELETED_FLAG = '0';
			BEGIN
			x_project_f:=false;
			IF (nPsNodeType = cnReference) THEN

  			    IF(sDisposition = 'M')THEN
			      BEGIN
                       	  OPEN  c_node;
                      	  FETCH c_node INTO nModelType;
                     	  x_project_f:=c_node%FOUND;
                      	  CLOSE c_node;
			      END;
			    END IF;

                      --Bug #2804225. Decided to make import never restore the number of instances,
                      --therefore removing all the conditions on model_type. nModelType can be equal
                      --to 'C' for generic import and in this case we want to use the values from
                      --the import table.

			    IF (x_project_f AND (nModelType <> 'C')) THEN
		    		SELECT nvl(MINIMUM,1), nvl(MAXIMUM,1) INTO sMinimum, sMaximum
		    		FROM CZ_PS_NODES
		    		WHERE PS_NODE_ID = nOnlPsnodeId
			   	AND DELETED_FLAG = '0';
			    ELSE
				sMinimum := impMinimum;
				sMaximum := impMaximum;
			    END IF;
			END IF;
			EXCEPTION
			    WHEN OTHERS THEN null;
			END;

                  /* This Code is added to Preserve the user modified tree_seq in a mixed tree bug # 3495030*/
                        nOnlMaxtreeSeq_forParent := NULL;
                        nNextTreeSeq := NULL;
                   IF (sDisposition = 'I' ) THEN
                     IF (nvl(thisParentid,0) <>  nImpparentid ) THEN
                     BEGIN
                      thisParentid := nImpparentid ;

                      select max(tree_seq) into nOnlMaxtreeSeq_forParent
                      from cz_ps_nodes
                      where parent_id = nImpparentid
                      and deleted_flag = '0';

                      nNextTreeSeq := nOnlMaxtreeSeq_forParent + 1;
                      nSameParentTreeSeq := nNextTreeSeq;

                      EXCEPTION
                      WHEN OTHERS THEN null;


                     END;
                    ELSE
                     nNextTreeSeq := nSameParentTreeSeq +1;
                    END IF;
                   END IF;

                 /* End Fix for bug # 3495030 */

		    UPDATE CZ_IMP_PS_NODES SET
                    ORIG_SYS_REF=DECODE(x_usesurr_psnode,1,DECODE(sDISPOSITION,NULL,sImpUserStr03,ORIG_SYS_REF), ORIG_SYS_REF),
                    PS_NODE_ID=DECODE(sDISPOSITION,'R',PS_NODE_ID,'I',
                                      DECODE(PS_NODE_TYPE,bomModel,DEVL_PROJECT_ID,cnModel,DEVL_PROJECT_ID,nNextId),nOnlPsnodeId),
                    ITEM_ID=DECODE(sDISPOSITION,'R',ITEM_ID,nonlitemid),
                    NAME=DECODE(inXFR_GROUP,'GENERIC',NAME,
                                     NamePrefix || DECODE(sDISPOSITION,'R',NAME,
                                              DECODE(nPsNodeType,cnReference,DECODE(localName,NULL,NAME,localName),
                                                     DECODE(sOnlItemRefPartNbr,NULL,NAME,
                                                            DECODE(sPsNodeName,'DESCRIPTION',NAME,sOnlItemRefPartNbr))))),
                    PARENT_ID=DECODE(sDISPOSITION,'R',PARENT_ID,nImpparentid),
                    REFERENCE_ID=DECODE(sDISPOSITION,'R',REFERENCE_ID,DECODE(PS_NODE_TYPE,cnReference,nOnlReference,REFERENCE_ID)),
		    MINIMUM = DECODE(nPsNodeType,cnReference,sMinimum, MINIMUM),
		    MAXIMUM = DECODE(nPsNodeType,cnReference,sMaximum, MAXIMUM),
--------------------bug3495030
                    TREE_SEQ = DECODE(sDISPOSITION,'I',nvl(nNextTreeSeq,TREE_SEQ),TREE_SEQ),
                    DISPOSITION=sDisposition,
                    REC_STATUS=sRecStatus
                    WHERE ROWID = thisRowId;

nDebug := 1025;
			IF(x_usesurr_psnode=1) THEN
				sLastFSK:=sImpUserStr03;
			ELSE
				sLastFSK:=sImpOrigsysref;
			END IF;
                  nLastTreeSeq := nThisTreeSeq;
nDebug := 1026;
			/* Return if MAX_ERR is reached */
			IF (FAILED >= MAX_ERR) THEN
                           x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.KRS_PS_NODE',11276,inRun_Id);
				RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
			END IF;
			sDisposition:=NULL; sRecStatus:=NULL;

		END LOOP;
		/* No more data */

		CLOSE c_imp_psnode;
		COMMIT;
nDebug := 1027;
		INSERTS:=nInsertCount;
		UPDATES:=nUpdateCount;
		DUPS:=nDups;

EXCEPTION
   WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
      RAISE;
   WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
      RAISE;
   WHEN OTHERS THEN
      x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.KRS_PS_NODE',nDebug,inRun_ID);
      RAISE;
END KRS_PS_NODE;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE CND_PS_NODE(inRUN_ID 	   IN 	         PLS_INTEGER,
                      COMMIT_SIZE  IN            PLS_INTEGER,
                      MAX_ERR	   IN 	         PLS_INTEGER,
                      FAILED	   IN OUT NOCOPY PLS_INTEGER
			   ) IS

		CURSOR c_imp_psnode  IS
			SELECT DELETED_FLAG, SYSTEM_NODE_FLAG, SRC_APPLICATION_ID, ORIG_SYS_REF,
                        PS_NODE_TYPE, MINIMUM, MAXIMUM, INSTANTIABLE_FLAG, NAME, FSK_DEVLPROJECT_5_1,
                        FSK_PSNODE_3_1, FSK_PSNODE_3_EXT, REFERENCE_ID, INITIAL_NUM_VALUE, DECIMAL_QTY_FLAG,
                        MINIMUM_SELECTED, MAXIMUM_SELECTED, UI_OMIT, DISPLAY_IN_SUMMARY_FLAG,  ROWID
                  FROM CZ_IMP_PS_NODES
                  WHERE REC_STATUS IS NULL AND RUN_ID = inRUN_ID;
		/* Internal vars */
		nCommitCount						PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount						PLS_INTEGER:=0;			/*Error index */
		nFailed							PLS_INTEGER:=0;			/*Failed records */
		nDups							PLS_INTEGER:=0;			/*Dupl records */
		x_error							BOOLEAN:=FALSE;


		/*Cursor Var for Import */
		p_imp_psnode   					c_imp_psnode%ROWTYPE;
		x_imp_psnode_f					BOOLEAN:=FALSE;
                l_disposition                                   cz_imp_ps_nodes.disposition%TYPE;
                l_rec_status                                    cz_imp_ps_nodes.rec_status%TYPE;

                sInstantiableFlag    cz_ps_nodes.instantiable_flag%type;
                l_msg                                           VARCHAR2(255);
                l_model_name         cz_devl_projects.name%type;
                l_debug              NUMBER;
                l_minimum            cz_imp_ps_nodes.minimum%TYPE;
                l_maximum            cz_imp_ps_nodes.maximum%TYPE;
                l_minimum_selected   cz_imp_ps_nodes.minimum_selected%TYPE;
                l_maximum_selected   cz_imp_ps_nodes.maximum_selected%TYPE;

BEGIN

           --
           --  All dups are rejected because we don't know which to accept, GENERIC IMPORT ONLY
           --

           UPDATE cz_imp_ps_nodes a
           SET disposition = 'R', rec_status = 'DUP'
           WHERE run_id = inRun_ID
           AND rec_status IS NULL
           AND EXISTS (SELECT count(*), orig_sys_ref,fsk_devlproject_5_1,src_application_id
                       FROM cz_imp_ps_nodes
                       WHERE run_id = a.run_id
                       AND rec_status IS NULL
                       AND orig_sys_ref = a.orig_sys_ref
                       AND fsk_devlproject_5_1 = a.fsk_devlproject_5_1
                       AND src_application_id = a.src_application_id
                       AND src_application_id <> 702
                       GROUP BY orig_sys_ref, fsk_devlproject_5_1, src_application_id
                       HAVING count(*) > 1);

           IF (SQL%ROWCOUNT > 0 ) THEN
              l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_DUPS', 'PSNODES', SQL%ROWCOUNT);
              x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
           END IF;

	   OPEN c_imp_psnode;
	   LOOP
		FETCH c_imp_psnode INTO p_imp_psnode;
		x_imp_psnode_f:=c_imp_psnode%FOUND;

		EXIT WHEN NOT x_imp_psnode_f;

                IF(FAILED >= MAX_ERR) THEN
                 x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                  RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
                END IF;

                l_disposition := NULL;
                l_rec_status := NULL;
                l_minimum_selected := p_imp_psnode.minimum_selected;
                l_maximum_selected := p_imp_psnode.maximum_selected;

                -- validate min and max for root nodes
                IF (p_imp_psnode.FSK_PSNODE_3_1 IS NULL AND p_imp_psnode.FSK_PSNODE_3_EXT IS NULL
                    AND p_imp_psnode.PS_NODE_TYPE <> bomModel) THEN
                    IF (p_imp_psnode.MINIMUM IS NOT NULL AND p_imp_psnode.MINIMUM <> 1) OR
                          (p_imp_psnode.MAXIMUM IS NOT NULL AND p_imp_psnode.MAXIMUM <> 1) THEN

                         l_disposition:='R';

                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_ROOT_MINMAX',
                                                  'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                  'OSR', p_imp_psnode.ORIG_SYS_REF
                                                  );
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                    END IF;
                    IF p_imp_psnode.minimum IS NULL THEN
                       l_minimum:=1;
                    ELSE
                       l_minimum:=p_imp_psnode.minimum;
                    END IF;
                    IF p_imp_psnode.maximum IS NULL THEN
                       l_maximum:=1;
                    ELSE
                       l_maximum:=p_imp_psnode.maximum;
                    END IF;

                    -- ui_omit flag cannot be '1' for root nodes

                    IF p_imp_psnode.ui_omit = '1' THEN

                         l_disposition:='R';

                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_ROOT_UI_OMIT',
                                                  'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                  'OSR', p_imp_psnode.ORIG_SYS_REF
                                                  );
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                    END IF;

                ELSE
                       l_minimum:=p_imp_psnode.minimum;
                       l_maximum:=p_imp_psnode.maximum;
                END IF;

                -- validate min/max and initial values for BOM standard items and BOM option calsses,
                -- and convert to integers if decimal

                IF (p_imp_psnode.PS_NODE_TYPE IN (bomStandard, bomOptionClass)) THEN
                   IF (p_imp_psnode.DECIMAL_QTY_FLAG = '0') THEN
                      l_minimum := CEIL(p_imp_psnode.minimum);
                      IF (p_imp_psnode.maximum <> -1) THEN
                          l_maximum := FLOOR(p_imp_psnode.maximum);
                      ELSE
                          l_maximum := p_imp_psnode.maximum;
                      END IF;

                      IF (p_imp_psnode.initial_num_value IS NOT NULL AND
                          MOD(p_imp_psnode.initial_num_value,FLOOR(p_imp_psnode.initial_num_value)) <> 0) THEN
                         l_disposition := 'R';
                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_INV_INIT_VALUE',
                                                  'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                  'OSR', p_imp_psnode.ORIG_SYS_REF
                                                 );
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                      END IF;

                      IF (l_minimum > l_maximum  AND  l_maximum <> -1) THEN
                         l_disposition := 'R';
                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_INV_MINMAX',
                                                  'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                  'OSR', p_imp_psnode.ORIG_SYS_REF
                                                 );
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                      END IF;
                   END IF;
                END IF;

                -- validate min/max and initial values for references,
                -- and convert to integers if decimal

                IF (p_imp_psnode.PS_NODE_TYPE = cnReference) THEN
                   IF (p_imp_psnode.DECIMAL_QTY_FLAG = '0') THEN
                      l_minimum_selected := CEIL(p_imp_psnode.minimum_selected);
                      IF (p_imp_psnode.maximum_selected <> -1) THEN
                        l_maximum_selected := FLOOR(p_imp_psnode.maximum_selected);
                      ELSE
                        l_maximum_selected := p_imp_psnode.maximum_selected;
                      END IF;

                      IF (p_imp_psnode.initial_num_value IS NOT NULL AND
                          MOD(p_imp_psnode.initial_num_value,FLOOR(p_imp_psnode.initial_num_value)) <> 0) THEN
                         l_disposition := 'R';
                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_INV_INIT_VALUE',
                                                  'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                  'OSR', p_imp_psnode.ORIG_SYS_REF
                                                 );
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                      END IF;

                      IF (l_minimum_selected > l_maximum_selected AND l_maximum_selected <> -1) THEN
                         l_disposition := 'R';
                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_INV_MINMAX',
                                                  'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                  'OSR', p_imp_psnode.ORIG_SYS_REF
                                                 );
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                      END IF;
                   END IF;
                END IF;

                IF p_imp_psnode.PS_NODE_TYPE NOT IN (cnComponent,cnFeature,cnOption,cnReference,cnConnector,
                                                     cnTotal,cnResource,bomModel,bomOptionClass,bomStandard) THEN
                  l_disposition := 'R';

                  l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_TYPE_INVALID',
                                             'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                             'OSR', p_imp_psnode.ORIG_SYS_REF
                                            );
                  x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                END IF;

                IF(p_imp_psnode.NAME IS NULL) THEN

                    l_disposition:='R';

                    l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_NAME_IS_NULL',
                                             'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                             'OSR', p_imp_psnode.ORIG_SYS_REF
                                            );
                    x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                END IF;

                IF(p_imp_psnode.PS_NODE_TYPE NOT IN (cnReference,cnConnector) AND
                   p_imp_psnode.REFERENCE_ID IS NOT NULL) THEN

                    l_disposition := 'R';

                    l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_REFID_NULL',
                                             'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                             'OSR', p_imp_psnode.ORIG_SYS_REF
                                            );
                    x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                END IF;

                IF(p_imp_psnode.INSTANTIABLE_FLAG IS NULL) THEN
                            sInstantiableFlag := NULL;
			    IF(p_imp_psnode.PS_NODE_TYPE = bomModel)THEN
			      sInstantiableFlag := '2';
			    ELSIF(p_imp_psnode.PS_NODE_TYPE IN (cnReference, cnComponent, cnProduct)) THEN
			      IF(p_imp_psnode.MINIMUM = 1 AND p_imp_psnode.MAXIMUM = 1)THEN
				sInstantiableFlag := '2';
			      ELSIF(p_imp_psnode.MINIMUM = 0 AND p_imp_psnode.MAXIMUM = 1)THEN
				sInstantiableFlag := '1';
			      ELSE
				sInstantiableFlag := '4';
			      END IF;
			    END IF;
                ELSE
                      IF(p_imp_psnode.PS_NODE_TYPE IN (cnReference, cnComponent, cnProduct)) THEN
                         IF (p_imp_psnode.MINIMUM = 1 AND p_imp_psnode.MAXIMUM = 1 AND p_imp_psnode.INSTANTIABLE_FLAG <> '2') THEN
                             l_disposition := 'R';
                         ELSIF(p_imp_psnode.MINIMUM = 0 AND p_imp_psnode.MAXIMUM = 1 AND p_imp_psnode.INSTANTIABLE_FLAG <> '1') THEN
                             l_disposition := 'R';
                         END IF;
                      ELSIF(p_imp_psnode.PS_NODE_TYPE = bomModel AND p_imp_psnode.INSTANTIABLE_FLAG <> '2') THEN
                         l_disposition := 'R';
                      END IF;

                      IF (l_disposition = 'R') THEN
                           l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_INSTFLAG',
                                                    'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                                    'OSR', p_imp_psnode.ORIG_SYS_REF
                                                   );
                           x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                      END IF;
                END IF;

                IF (p_imp_psnode.DISPLAY_IN_SUMMARY_FLAG NOT IN (NULL,'1')) THEN
                    l_disposition := 'R';
                    l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_PSNODE_SUMRY_FLAG',
                                             'MODELNAME', p_imp_psnode.FSK_DEVLPROJECT_5_1,
                                             'OSR', p_imp_psnode.ORIG_SYS_REF
                                                   );
                    x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
                END IF;

                   IF l_disposition='R' THEN
                      FAILED:=FAILED+1;
                      l_rec_status:='FAIL';
                   END IF;

                   UPDATE cz_imp_ps_nodes SET
                   deleted_flag=DECODE(deleted_flag,NULL,'0',deleted_flag),
                   system_node_flag=DECODE(system_node_flag,NULL,'0',SYSTEM_NODE_FLAG),
                   instantiable_flag=DECODE(instantiable_flag,NULL,sInstantiableFlag,instantiable_flag),
                   src_application_id=DECODE(src_application_id,NULL,cnDefSrcAppId,src_application_id),
                   minimum=l_minimum,
                   maximum=l_maximum,
                   minimum_selected=l_minimum_selected,
                   maximum_selected=l_maximum_selected,
                   disposition=l_disposition,
                   rec_status=l_rec_status
                   WHERE ROWID = p_imp_psnode.ROWID;
                   nCOmmitCount:=nCommitCount+1;
                   /* COMMIT if the buffer size is reached */
                   IF (nCommitCount>= COMMIT_SIZE) THEN
                       COMMIT;
                       nCommitCount:=0;
                   END IF;


	  END LOOP;
	  CLOSE c_imp_psnode;

EXCEPTION
   WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
      RAISE;
   WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
      RAISE;
   WHEN OTHERS THEN
      x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.CND_PS_NODE',11276,inRun_Id);
      RAISE;
END CND_PS_NODE ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
PROCEDURE MAIN_PS_NODE (inRUN_ID 	IN            PLS_INTEGER,
			COMMIT_SIZE	IN            PLS_INTEGER,
			MAX_ERR		IN            PLS_INTEGER,
			INSERTS		IN OUT NOCOPY PLS_INTEGER,
			UPDATES		IN OUT NOCOPY PLS_INTEGER,
			FAILED		IN OUT NOCOPY PLS_INTEGER,
			DUPS		IN OUT NOCOPY PLS_INTEGER,
                        inXFR_GROUP     IN            VARCHAR2
					) IS

		/* Internal vars */
		nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
		nErrorCount		PLS_INTEGER:=0;			/*Error index */
		nXfrInsertCount		PLS_INTEGER:=0;			/*Inserts */
		nXfrUpdateCount		PLS_INTEGER:=0;			/*Updates */
		nFailed			PLS_INTEGER:=0;			/*Failed records */
		nDups			PLS_INTEGER:=0;			/*Dupl records */
		x_error			BOOLEAN:=FALSE;
                dummy                   CHAR(1);

                st_time          number;
                end_time         number;
                loop_end_time    number;
                insert_end_time  number;
                d_str            varchar2(255);

                -- bug 9496782
                genStatisticsCz    PLS_INTEGER;
                v_settings_id      VARCHAR2(40);
                v_section_name     VARCHAR2(30);

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
              x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.MAIN_PS_NODE',11276,inRun_Id);
              RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
         END;

         if (CZ_IMP_ALL.get_time) then
   		st_time := dbms_utility.get_time();
         end if;

         CND_PS_NODE (inRun_ID,COMMIT_SIZE,MAX_ERR,FAILED);

         if (CZ_IMP_ALL.get_time) then
           end_time := dbms_utility.get_time();
           d_str := inRun_id || '     CND ps  :' || (end_time-st_time)/100.00;
           x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'CND',11299,inRun_Id);
         end if;

         KRS_PS_NODE (inRUN_ID,COMMIT_SIZE,MAX_ERR,INSERTS,UPDATES,FAILED,DUPS,inXFR_GROUP);

         if (CZ_IMP_ALL.get_time) then
           end_time := dbms_utility.get_time();
           d_str := inRun_id || '     KRS ps  :' || (end_time-st_time)/100.00;
           x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'KRS',11299,inRun_Id);
         end if;

         --bug 9496782 Added this section for gather stats

         --Depending on db setting, generate the statistics here for the tables used in the queries bellow.

         v_settings_id := 'GENSTATISTICSCZ';
         v_section_name := 'IMPORT';

         BEGIN
           SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1','0','0','YES','1','NO','0','Y','1','N','0','0')
           INTO genStatisticsCz FROM CZ_DB_SETTINGS
           WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
         EXCEPTION
           WHEN OTHERS THEN
             genStatisticsCz := 0;
         END;

         IF(genStatisticsCz = 1)THEN
           x_error:=cz_utils.log_report('Gather Stats : Start' ,1,'CZ_IMP_PS_NODE.XFR',11299,inRun_Id);
           fnd_stats.gather_table_stats('CZ', 'CZ_IMP_PS_NODES');
           fnd_stats.gather_table_stats('CZ', 'CZ_IMP_DEVL_PROJECT');
           fnd_stats.gather_table_stats('CZ', 'CZ_PS_NODES');
           x_error:=cz_utils.log_report('Gather Stats : End' ,1,'CZ_IMP_PS_NODE.XFR',11299,inRun_Id);

           if (CZ_IMP_ALL.get_time) then
             end_time := dbms_utility.get_time();
             d_str := inRun_id || '     XFR gather_stats  :' || (end_time-st_time)/100.00;
             x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299,inRun_Id);
           end if;
         END IF;

         XFR_PS_NODE (inRUN_ID,COMMIT_SIZE,MAX_ERR,nXfrInsertCount,nXfrUpdateCount,FAILED,inXFR_GROUP);

         if (CZ_IMP_ALL.get_time) then
           end_time := dbms_utility.get_time();
           d_str := inRun_id || '     XFR ps  :' || (end_time-st_time)/100.00;
           x_ERROR:=CZ_UTILS.LOG_REPORT(d_str,1,'XFR',11299,inRun_Id);
         end if;

         /* Report Insert Errors */
         IF (nXfrInsertCount<> INSERTS) THEN
            x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_INSERTERRORS','RESOLVED',to_char(INSERTS),'ACTUAL',to_char(nXfrInsertCount)),1,'IMP_IM_PS_NODE.MAIN_PS_NODE',11276,inRun_Id);
         END IF;

         /* Report Update Errors */
         IF (nXfrUpdateCount<> UPDATES) THEN
           x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_UPDATEERRORS','RESOLVED',to_char(UPDATES),'ACTUAL',to_char(nXfrUpdateCount)),1,'IMP_IM_PS_NODE.MAIN_PS_NODE',11276,inRun_Id);
         END IF;

         /* Return the transferred number of rows and not the number of rows with keys resolved*/
         INSERTS:=nXfrInsertCount;
         UPDATES:=nXfrUpdateCount;

         CZ_IMP_PS_NODE.RPT_PS_NODE(inRUN_ID);

END MAIN_PS_NODE ;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

PROCEDURE XFR_PS_NODE	 (inRUN_ID 		IN 	        PLS_INTEGER,
                          COMMIT_SIZE           IN              PLS_INTEGER,
			  MAX_ERR		IN 	        PLS_INTEGER,
			  INSERTS		IN   OUT NOCOPY PLS_INTEGER,
			  UPDATES		IN   OUT NOCOPY PLS_INTEGER,
			  FAILED		IN   OUT NOCOPY PLS_INTEGER,
                          inXFR_GROUP           IN              VARCHAR2
					) IS

  TYPE tPsNodeId              IS TABLE OF cz_imp_ps_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDevlProjectId         IS TABLE OF cz_imp_ps_nodes.devl_project_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tFromPopulatorId       IS TABLE OF cz_imp_ps_nodes.from_populator_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPropertyBackptr       IS TABLE OF cz_imp_ps_nodes.property_backptr%TYPE INDEX BY BINARY_INTEGER;
  TYPE tItemTypeBackptr       IS TABLE OF cz_imp_ps_nodes.item_type_backptr%TYPE INDEX BY BINARY_INTEGER;
  TYPE tIntlTextId            IS TABLE OF cz_imp_ps_nodes.intl_text_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSubConsId             IS TABLE OF cz_imp_ps_nodes.sub_cons_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tItemId                IS TABLE OF cz_imp_ps_nodes.item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tName                  IS TABLE OF cz_imp_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tResourceFlag          IS TABLE OF cz_imp_ps_nodes.resource_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInitialValue          IS TABLE OF cz_imp_ps_nodes.initial_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInitialNumValue       IS TABLE OF cz_imp_ps_nodes.initial_num_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tParentId              IS TABLE OF cz_imp_ps_nodes.parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMinimum               IS TABLE OF cz_imp_ps_nodes.minimum%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMaximum               IS TABLE OF cz_imp_ps_nodes.maximum%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPsNodeType            IS TABLE OF cz_imp_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tFeatureType           IS TABLE OF cz_imp_ps_nodes.feature_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tProductFlag           IS TABLE OF cz_imp_ps_nodes.product_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tReferenceId           IS TABLE OF cz_imp_ps_nodes.reference_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMultiConfigFlag       IS TABLE OF cz_imp_ps_nodes.multi_config_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tOrderSeqFlag          IS TABLE OF cz_imp_ps_nodes.order_seq_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSystemNodeFlag        IS TABLE OF cz_imp_ps_nodes.system_node_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tTreeSeq               IS TABLE OF cz_imp_ps_nodes.tree_seq%TYPE INDEX BY BINARY_INTEGER;
  TYPE tCountedOptionsFlag    IS TABLE OF cz_imp_ps_nodes.counted_options_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUiOmit                IS TABLE OF cz_imp_ps_nodes.ui_omit%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUiSection             IS TABLE OF cz_imp_ps_nodes.ui_section%TYPE INDEX BY BINARY_INTEGER;
  TYPE tBomTreatment          IS TABLE OF cz_imp_ps_nodes.bom_treatment%TYPE INDEX BY BINARY_INTEGER;
  TYPE tOrigSysRef            IS TABLE OF cz_imp_ps_nodes.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
  TYPE tCheckoutUser          IS TABLE OF cz_imp_ps_nodes.checkout_user%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDisposition           IS TABLE OF cz_imp_ps_nodes.disposition%TYPE INDEX BY BINARY_INTEGER;
  TYPE tRecStatus             IS TABLE OF cz_imp_ps_nodes.rec_status%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDeletedFlag           IS TABLE OF cz_imp_ps_nodes.deleted_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tEffectiveFrom         IS TABLE OF cz_imp_ps_nodes.effective_from%TYPE INDEX BY BINARY_INTEGER;
  TYPE tEffectiveUntil        IS TABLE OF cz_imp_ps_nodes.effective_until%TYPE INDEX BY BINARY_INTEGER;
  TYPE tEffectiveUsageMask    IS TABLE OF cz_imp_ps_nodes.EFFECTIVE_USAGE_MASK%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserStr01             IS TABLE OF cz_imp_ps_nodes.USER_STR01%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserStr02             IS TABLE OF cz_imp_ps_nodes.USER_STR02%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserStr03             IS TABLE OF cz_imp_ps_nodes.USER_STR03%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserStr04             IS TABLE OF cz_imp_ps_nodes.USER_STR04%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserNum01             IS TABLE OF cz_imp_ps_nodes.USER_NUM01%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserNum02             IS TABLE OF cz_imp_ps_nodes.USER_NUM02%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserNum03             IS TABLE OF cz_imp_ps_nodes.USER_NUM03%TYPE INDEX BY BINARY_INTEGER;
  TYPE tUserNum04             IS TABLE OF cz_imp_ps_nodes.USER_NUM04%TYPE INDEX BY BINARY_INTEGER;
  TYPE tCreationDate          IS TABLE OF cz_imp_ps_nodes.CREATION_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tLastUpdateDate        IS TABLE OF cz_imp_ps_nodes.LAST_UPDATE_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tCreatedBy             IS TABLE OF cz_imp_ps_nodes.CREATED_BY%TYPE INDEX BY BINARY_INTEGER;
  TYPE tLastUpdatedBy         IS TABLE OF cz_imp_ps_nodes.LAST_UPDATED_BY%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSecurityMask          IS TABLE OF cz_imp_ps_nodes.SECURITY_MASK%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPlanLevel             IS TABLE OF cz_imp_ps_nodes.PLAN_LEVEL%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSoItemTypeCode        IS TABLE OF cz_imp_ps_nodes.SO_ITEM_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMinimumSelected       IS TABLE OF cz_imp_ps_nodes.MINIMUM_SELECTED%TYPE INDEX BY BINARY_INTEGER;
  TYPE tMaximumSelected       IS TABLE OF cz_imp_ps_nodes.MAXIMUM_SELECTED%TYPE INDEX BY BINARY_INTEGER;
  TYPE tBomRequired           IS TABLE OF cz_imp_ps_nodes.BOM_REQUIRED%TYPE INDEX BY BINARY_INTEGER;
  TYPE tComponentSequenceId   IS TABLE OF cz_imp_ps_nodes.COMPONENT_SEQUENCE_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE tOrganizationId        IS TABLE OF cz_imp_ps_nodes.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE tTopItemId             IS TABLE OF cz_imp_ps_nodes.TOP_ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExplosionType         IS TABLE OF cz_imp_ps_nodes.EXPLOSION_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDecimalQtyFlag        IS TABLE OF cz_imp_ps_nodes.DECIMAL_QTY_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInstantiableFlag      IS TABLE OF cz_imp_ps_nodes.INSTANTIABLE_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE tQuoteableFlag         IS TABLE OF cz_imp_ps_nodes.QUOTEABLE_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPrimaryUomCode        IS TABLE OF cz_imp_ps_nodes.PRIMARY_UOM_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tBomSortOrder          IS TABLE OF cz_imp_ps_nodes.BOM_SORT_ORDER%TYPE INDEX BY BINARY_INTEGER;
  TYPE tComponentSequencePath IS TABLE OF cz_imp_ps_nodes.COMPONENT_SEQUENCE_PATH%TYPE INDEX BY BINARY_INTEGER;
  TYPE tIbTrackable           IS TABLE OF cz_imp_ps_nodes.IB_TRACKABLE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSrcApplicationId      IS TABLE OF cz_imp_ps_nodes.SRC_APPLICATION_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE tChar_tbl              IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE tModelType             IS TABLE OF cz_imp_devl_project.MODEL_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE tDisplayInSummaryFlag  IS TABLE OF cz_imp_ps_nodes.DISPLAY_IN_SUMMARY_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE tIBLinkItemFlag        IS TABLE OF cz_imp_ps_nodes.IB_LINK_ITEM_FLAG%TYPE INDEX BY BINARY_INTEGER;

  TYPE tPSShippableItemFlag IS TABLE OF cz_imp_ps_nodes.shippable_item_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tInventoryTransactableFlag IS TABLE OF cz_imp_ps_nodes.inventory_transactable_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tAssembleToOrderFlag IS TABLE OF cz_imp_ps_nodes.assemble_to_order_flag%TYPE INDEX BY BINARY_INTEGER;
  TYPE tSerializableItemFlag IS TABLE OF cz_imp_ps_nodes.serializable_item_flag%TYPE INDEX BY BINARY_INTEGER;

  iPsNodeId tPsNodeId;
  iDevlProjectId tDevlProjectId;
  iFromPopulatorId tFromPopulatorId;
  iPropertyBackptr tPropertyBackptr;
  iItemTypeBackptr tItemTypeBackptr;
  iIntlTextid tIntlTextId;
  iSubConsid tSubConsId;
  iItemId tItemId;
  iName tName;
  iresourceFlag tResourceFlag;
  iInitialValue tInitialValue;
  iInitialNumValue tInitialNumValue;
  iParentId tParentId;
  iMinimum tMinimum;
  iMaximum tMaximum;
  iPsNodeType tPsNodeType;
  iFeatureType tFeatureType;
  iProductFlag tProductFlag;
  iReferenceId tReferenceId;
  iMultiConfigflag tmultiConfigFlag;
  iOrderSeqFlag tOrderSeqFlag;
  iSystemNodeFlag tSystemNodeFlag;
  iTreeSeq tTreeSeq;
  iCountedOptionsFlag tCountedOptionsFlag;
  iUiOmit tUiOmit;
  iUiSection tUiSection;
  iBomTreatment tBomTreatment;
  iOrigSysRef tOrigSysRef;
  iCheckoutUser tCheckoutUser;
  iDisposition tDisposition;
  iDeletedFlag tDeletedFlag;
  iEffectivefrom tEffectiveFrom;
  iEffectiveUntil tEffectiveUntil;
  iEffectiveUsageMask tEffectiveUsageMask;
  iUserStr01 tUserStr01;
  iUserStr02 tUserStr03;
  iUserStr03 tUserStr03;
  iUserStr04 tUserStr04;
  iUserNum01 tUserNum01;
  iUserNum02 tUserNum02;
  iUserNum03 tUserNum03;
  iUserNum04 tUserNum04;
  iCreationDate tCreationDate;
  iLastUpdateDate tLastUpdateDate;
  iCreatedBy tCreatedBy;
  iLastUpdatedBy tLastUpdatedBy;
  iSecurityMask tSecurityMask;
  iPlanLevel tPlanLevel;
  iSoItemTypeCode tSoItemTypeCode;
  iMinimumSelected tMinimumSelected;
  iMaximumSelected tMaximumSelected;
  iBomRequired tBomRequired;
  iComponentSequenceId tComponentSequenceId;
  iOrganizationid torganizationId;
  iTopItemId tTopItemId;
  iexplosionType tExplosionType;
  iDecimalQtyFlag tDecimalQtyFlag;
  iInstantiableFlag tinstantiableFlag;
  iQuoteableFlag tQuoteableFlag;
  iPrimaryUomCode tPrimaryUomCode;
  iBomSortorder tBomSortOrder;
  iComponentSequencePath tComponentSequencePath;
  iIbTrackable tIbTrackable;
  iSrcApplicationid tSrcApplicationId;
  iDisplayInSummaryFlag tDisplayInSummaryFlag;
  iIBLinkItemFlag tIBLinkItemFlag;

  iShippableItemFlag         tPSShippableItemFlag;
  iInventoryTransactableFlag tInventoryTransactableFlag;
  iAssembleToOrder           tAssembleToOrderFlag;
  iSerializableItemFlag      tSerializableItemFlag;

  --  PS nodes that are references, connectors or componentns, NOT ROOTS
  CURSOR l_model_refs_csr IS
  SELECT plan_level, ps_node_id, devl_project_id, reference_id,
  minimum, maximum, ps_node_type, parent_id, disposition
  FROM cz_imp_ps_nodes
  WHERE ps_node_type IN (cnReference,cnConnector,cnComponent)
  AND deleted_flag='0' AND rec_status='OK' AND run_id=inRun_ID
  ORDER BY plan_level, devl_project_id, reference_id;

  -- root nodes containing NO refs but ARE referenced, order by reference_id
  CURSOR C1 IS
  SELECT REFS.plan_level, ROOTS.devl_project_id, ROOTS.ps_node_id, ROOTS.disposition, REFS.devl_project_id AS REFERRING_MODEL_ID,
  ROOTS.ps_node_type, ROOTS.minimum, ROOTS.maximum, ROOTS.rec_status, ROOTS.name, d.model_type
  FROM cz_imp_ps_nodes ROOTS, cz_imp_ps_nodes REFS,cz_imp_devl_project d
  WHERE (ROOTS.ps_node_id = ROOTS.devl_project_id OR (ROOTS.parent_id IS NULL AND ROOTS.plan_level=0))
  AND ROOTS.devl_project_id=REFS.reference_id
  AND NOT EXISTS (SELECT 1 FROM cz_imp_ps_nodes
                           WHERE run_id=inRUN_ID
                           AND rec_status='PASS'
                           AND devl_project_id=ROOTS.devl_project_id
                           AND ps_node_type IN (cnReference,cnConnector))
  AND ROOTS.run_id = inRUN_ID
  AND ROOTS.rec_status='PASS'
  AND ROOTS.devl_project_id = d.devl_project_id
  AND d.rec_status = 'OK'
  AND d.run_id = inRun_ID
  AND REFS.run_id = inRUN_ID
  AND REFS.rec_status = 'PASS'
  ORDER BY ROOTS.devl_project_id;

  -- root nodes that ARE referenced by other models AND have references to others
  CURSOR C2 IS
  SELECT REFS.plan_level, ROOTS.devl_project_id, ROOTS.ps_node_id, ROOTS.disposition,
  REFS.devl_project_id AS REFERRING_MODEL_ID, ROOTS.ps_node_type,
  ROOTS.minimum, ROOTS.maximum, ROOTS.rec_status, ROOTS.name, d.model_type
  FROM cz_imp_ps_nodes ROOTS, cz_imp_ps_nodes REFS, cz_imp_devl_project d
  WHERE (ROOTS.ps_node_id = ROOTS.devl_project_id OR (ROOTS.parent_id IS NULL AND ROOTS.plan_level=0))
  AND ROOTS.ps_node_id = REFS.reference_id
  AND REFS.ps_node_type IN (cnReference,cnConnector)
  AND EXISTS (SELECT 1 FROM cz_imp_ps_nodes
                           WHERE run_id=inRUN_ID
                           AND rec_status='PASS'
                           AND devl_project_id=ROOTS.devl_project_id
                           AND ps_node_type IN (cnReference,cnConnector))
  AND ROOTS.run_id=inRUN_ID
  AND ROOTS.rec_status='PASS'
  AND REFS.rec_status='PASS'
  AND REFS.run_id=inRUN_ID
  AND ROOTS.devl_project_id = d.devl_project_id
  AND d.run_id=inRUN_ID
  AND d.rec_status='OK'
  ORDER BY ROOTS.devl_project_id;

  -- root nodes that are NOT referenced but DO contain references to other models
  CURSOR C3 IS
  SELECT ROOTS.plan_level, ROOTS.devl_project_id, ROOTS.ps_node_id, ROOTS.disposition,
  REFS.reference_id, ROOTS.ps_node_type, ROOTS.minimum, ROOTS.maximum, ROOTS.rec_status, d.model_type
  FROM cz_imp_ps_nodes ROOTS,  cz_imp_ps_nodes REFS, cz_imp_devl_project d
  WHERE (ROOTS.ps_node_id = ROOTS.devl_project_id OR (ROOTS.parent_id IS NULL AND ROOTS.plan_level=0))
  AND ROOTS.ps_node_id = REFS.devl_project_id
  AND REFS.ps_node_type IN (cnReference,cnConnector)
  AND ROOTS.run_id=inRUN_ID
  AND ROOTS.rec_status='PASS'
  AND ROOTS.devl_project_id = d.devl_project_id
  AND d.run_id=inRUN_ID
  AND d.rec_status='OK'
  AND REFS.rec_status='PASS'
  AND REFS.run_id=inRUN_ID
  AND NOT EXISTS (SELECT 1 FROM cz_imp_ps_nodes
                           WHERE run_id=inRUN_ID
                           AND rec_status='PASS'
                           AND reference_id=ROOTS.devl_project_id
                           AND ps_node_type IN (cnReference,cnConnector))
  ORDER BY ROOTS.devl_project_id;

  -- Remaining models if any (NOT referenced AND with NO references)
  CURSOR C4 IS
  SELECT p.plan_level, p.devl_project_id, p.ps_node_id, p.disposition,
  p.ps_node_type, p.minimum, p.maximum, p.rec_status, d.model_type
  FROM cz_imp_ps_nodes p, cz_imp_devl_project d
  WHERE p.run_id=inRUN_ID
  AND p.rec_status='PASS'
  AND (p.ps_node_id = p.devl_project_id OR (p.parent_id IS NULL AND p.plan_level=0))
  AND p.devl_project_id=d.devl_project_id
  AND d.run_id=inRUN_ID
  AND d.rec_status='OK';

  /* used to load l_model_csr */
  l_PsNodeId tPsNodeId;
  l_DevlProjectId tDevlProjectId;
  l_PsNodeType tPsNodeType;
  l_PlanLevel tPlanLevel;
  l_referenceId tDevlProjectId;
  l_parentId tParentId;
  l_Minimum tMinimum;
  l_Maximum tMaximum;
  l_dis tDisposition;
  l_this_model_id number;

  l_c1_prj_id_tbl tDevlProjectId;
  l_c1_node_id_tbl tPsNodeId;
  l_c1_plan_level_tbl tPlanLevel;
  l_c1_dis_tbl tDisposition;
  l_c1_ref_model_id_tbl tDevlProjectId;
  l_c1_max_tbl tMaximum;
  l_c1_min_tbl tMinimum;
  l_c1_nodetype_tbl tPsNodeType;
  l_c1_rec_status_tbl tRecStatus;
  l_c1_name_tbl tName;
  l_c1_model_type tModelType;

  l_c2_prj_id_tbl tDevlProjectId;
  l_c2_node_id_tbl tPsNodeId;
  l_c2_plan_level_tbl tPlanLevel;
  l_c2_dis_tbl tDisposition;
  l_c2_ref_model_id_tbl tDevlProjectId;
  l_c2_max_tbl tMaximum;
  l_c2_min_tbl tMinimum;
  l_c2_nodetype_tbl tPsNodeType;
  l_c2_rec_status_tbl tRecStatus;
  l_c2_name_tbl tName;
  l_c2_model_type tModelType;

  l_c3_prj_id_tbl tDevlProjectId;
  l_c3_node_id_tbl tPsNodeId;
  l_c3_plan_level_tbl tPlanLevel;
  l_c3_dis_tbl tDisposition;
  l_c3_ref_id_tbl tDevlProjectId;
  l_c3_max_tbl tMaximum;
  l_c3_min_tbl tMinimum;
  l_c3_nodetype_tbl tPsNodeType;
  l_c3_rec_status_tbl tRecStatus;
  l_c3_model_type tModelType;

  l_c4_prj_id_tbl tDevlProjectId;
  l_c4_node_id_tbl tPsNodeId;
  l_c4_plan_level_tbl tPlanLevel;
  l_c4_dis_tbl tDisposition;
  l_c4_ref_id_tbl tDevlProjectId;
  l_c4_max_tbl tMaximum;
  l_c4_min_tbl tMinimum;
  l_c4_nodetype_tbl tPsNodeType;
  l_c4_rec_status_tbl tRecStatus;
  l_c4_model_type tModelType;

  l_root_node_id_tbl tPsNodeId;
  l_root_dis_tbl tDisposition;
  l_ref_node_id_tbl tPsNodeId;
  l_ref_model_id_tbl tDevlProjectId;
  l_ref_plan_level_tbl tPlanLevel;
  l_ref_dis_tbl tDisposition;
  l_ref_model_id_tbl tDevlProjectId;

 -- parametic cursor: model_id and disposition
  CURSOR c_xfr_psnode (inModelId NUMBER, inDisposition VARCHAR2)IS
  SELECT PS_NODE_ID,DEVL_PROJECT_ID,FROM_POPULATOR_ID,PROPERTY_BACKPTR,
  ITEM_TYPE_BACKPTR,INTL_TEXT_ID,SUB_CONS_ID,ITEM_ID,NAME,RESOURCE_FLAG,
  INITIAL_VALUE,initial_num_value, PARENT_ID,MINIMUM,MAXIMUM,PS_NODE_TYPE,FEATURE_TYPE,
  PRODUCT_FLAG,REFERENCE_ID,MULTI_CONFIG_FLAG,ORDER_SEQ_FLAG,SYSTEM_NODE_FLAG,TREE_SEQ,
  COUNTED_OPTIONS_FLAG,UI_OMIT,UI_SECTION,BOM_TREATMENT,ORIG_SYS_REF,CHECKOUT_USER,
  DISPOSITION,DELETED_FLAG,EFFECTIVE_FROM,EFFECTIVE_UNTIL,EFFECTIVE_USAGE_MASK,USER_STR01,USER_STR02,USER_STR03,
  USER_STR04,USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,CREATION_DATE,LAST_UPDATE_DATE,
  CREATED_BY,LAST_UPDATED_BY,SECURITY_MASK, PLAN_LEVEL, SO_ITEM_TYPE_CODE,
  MINIMUM_SELECTED,MAXIMUM_SELECTED,BOM_REQUIRED,COMPONENT_SEQUENCE_ID,
  ORGANIZATION_ID,TOP_ITEM_ID,EXPLOSION_TYPE,DECIMAL_QTY_FLAG,INSTANTIABLE_FLAG,
  QUOTEABLE_FLAG,PRIMARY_UOM_CODE,BOM_SORT_ORDER,COMPONENT_SEQUENCE_PATH,IB_TRACKABLE, SRC_APPLICATION_ID,DISPLAY_IN_SUMMARY_FLAG,
  IB_LINK_ITEM_FLAG,
  SHIPPABLE_ITEM_FLAG,
  INVENTORY_TRANSACTABLE_FLAG,
  ASSEMBLE_TO_ORDER_FLAG,
  SERIALIZABLE_ITEM_FLAG
  FROM CZ_IMP_PS_NODES
  WHERE CZ_IMP_PS_NODES.RUN_ID = inRUN_ID AND REC_STATUS='PASS'
  AND devl_project_id=inModelId AND disposition=inDisposition
  ORDER BY PLAN_LEVEL,USER_NUM04 DESC;

  x_xfr_psnode_f		BOOLEAN:=FALSE;
  x_error			BOOLEAN:=FALSE;

  p_xfr_psnode  c_xfr_psnode%ROWTYPE;

  /* Internal vars */
  nCommitCount		PLS_INTEGER:=0;			/*COMMIT buffer index */
  nInsertCount		PLS_INTEGER:=0;			/*Inserts */
  nUpdateCount		PLS_INTEGER:=0;			/*Updates */
  nFailed		PLS_INTEGER:=0;			/*Failed records */
  p_out_err               INTEGER;
  p_out_virtual_flag      INTEGER;
  p_parent_id             cz_ps_nodes.parent_id%TYPE;

  NOUPDATE_PS_NODE_ID              NUMBER;
  NOUPDATE_DEVL_PROJECT_ID         NUMBER;
  NOUPDATE_FROM_POPULATOR_ID	   NUMBER;
  NOUPDATE_PROPERTY_BACKPTR        NUMBER;
  NOUPDATE_ITEM_TYPE_BACKPTR	   NUMBER;
  NOUPDATE_INTL_TEXT_ID		   NUMBER;
  NOUPDATE_SUB_CONS_ID		   NUMBER;
  NOUPDATE_ITEM_ID                 NUMBER;
  NOUPDATE_NAME			   NUMBER;
  NOUPDATE_RESOURCE_FLAG	   NUMBER;
  NOUPDATE_INITIAL_VALUE	   NUMBER;
  NOUPDATE_INITIAL_NUM_VALUE	   NUMBER;
  NOUPDATE_PARENT_ID               NUMBER;
  NOUPDATE_MINIMUM		   NUMBER;
  NOUPDATE_MAXIMUM		   NUMBER;
  NOUPDATE_PS_NODE_TYPE		   NUMBER;
  NOUPDATE_FEATURE_TYPE		   NUMBER;
  NOUPDATE_PRODUCT_FLAG		   NUMBER;
  NOUPDATE_REFERENCE_ID            NUMBER;
  NOUPDATE_MULTI_CONFIG_FLAG       NUMBER;
  NOUPDATE_ORDER_SEQ_FLAG          NUMBER;
  NOUPDATE_SYSTEM_NODE_FLAG        NUMBER;
  NOUPDATE_TREE_SEQ      	   NUMBER;
  NOUPDATE_COUNTED_OPTIONS_FLAG	   NUMBER;
  NOUPDATE_UI_OMIT                 NUMBER;
  NOUPDATE_UI_SECTION		   NUMBER;
  NOUPDATE_BOM_TREATMENT 	   NUMBER;
  NOUPDATE_ORIG_SYS_REF		   NUMBER;
  NOUPDATE_CHECKOUT_USER	   NUMBER;
  NOUPDATE_DELETED_FLAG            NUMBER;
  NOUPDATE_EFF_FROM                NUMBER;
  NOUPDATE_EFF_TO                  NUMBER;
  NOUPDATE_EFF_MASK                NUMBER;
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
  NOUPDATE_SO_ITEM_TYPE_CODE       NUMBER;
  NOUPDATE_MINIMUM_SELECTED        NUMBER;
  NOUPDATE_MAXIMUM_SELECTED        NUMBER;
  NOUPDATE_BOM_REQUIRED            NUMBER;
  NOUPDATE_COMPONENT_SEQUENCE_ID   NUMBER;
  NOUPDATE_DECIMAL_QTY_FLAG        NUMBER;
  NOUPDATE_QUOTEABLE_FLAG          NUMBER;
  NOUPDATE_PRIMARY_UOM_CODE        NUMBER;
  NOUPDATE_BOM_SORT_ORDER          NUMBER;
  NOUPDATE_SEQUENCE_PATH           NUMBER;
  NOUPDATE_IB_TRACKABLE            NUMBER;
  NOUPDATE_DSPLY_SMRY_FLG          NUMBER;
  NOUPDATE_IBLINKITEM_FLG          NUMBER;
  NOUPDATE_INSTANTIABLE_FLAG       NUMBER;

  -- TSO changes --
  NOUPDATE_SHIPPABLE_ITEM_FLAG     NUMBER;
  NOUPDATE_INV_TXN_FLAG            NUMBER;
  NOUPDATE_ASM_TO_ORDER_FLAG       NUMBER;
  NOUPDATE_SERIAL_ITEM_FLAG        NUMBER;


  sVirtualFlag       cz_ps_nodes.virtual_flag%type := '1';
  l_last_model_id    cz_ps_nodes.devl_project_id%type := 0;
  l_msg              VARCHAR2(2000);
  l_model_name       cz_devl_projects.name%type;
  l_disposition      cz_imp_ps_nodes.disposition%type;
  i integer;
  j integer;
  l_debug number:=0;
  l_retcode number;

  -- Private prcedure that inserts all PS nodes for the model passed in, it bulk fetches and
  -- tries to bulk insert, if bulk insert fails, then it inserts row by row
  -- it rollbacks if root node fails to insert other wise it logs rows failed to insert
  -- and continues untill all ps nodes are inserted

  -- Returns 0 if the model ps nodes prcessed successfully (the root ps node is inserted successfully)
  -- Returns 1 if error: when root node fails to insert

  PROCEDURE insert_ps_nodes(p_model_id IN NUMBER, x_retcode OUT NOCOPY NUMBER)
  IS
  BEGIN
        nCommitCount:=0;
        x_retcode := 0;

        IF c_xfr_psnode%ISOPEN THEN
          CLOSE c_xfr_psnode;
        END IF;

        OPEN c_xfr_psnode (p_model_id, 'I');

  <<OUTER_LOOP>>
        LOOP  -- bulk fetch for insert

          iPSNODEID.DELETE; iDEVLPROJECTID.DELETE; iFROMPOPULATORID.DELETE; iPROPERTYBACKPTR.DELETE;
          iITEMTYPEBACKPTR.DELETE; iINTLTEXTID.DELETE; iSUBCONSID.DELETE; iITEMID.DELETE; iNAME.DELETE; iRESOURCEFLAG.DELETE;
          iINITIALVALUE.DELETE; iInitialnumvalue.DELETE; iPARENTID.DELETE; iMINIMUM.DELETE; iMAXIMUM.DELETE; iPSNODETYPE.DELETE;
          iFEATURETYPE.DELETE; iPRODUCTFLAG.DELETE; iREFERENCEID.DELETE; iMULTICONFIGFLAG.DELETE; iORDERSEQFLAG.DELETE;
          iSYSTEMNODEFLAG.DELETE; iTREESEQ.DELETE; iCOUNTEDOPTIONSFLAG.DELETE; iUIOMIT.DELETE; iUISECTION.DELETE; iBOMTREATMENT.DELETE;
          iORIGSYSREF.DELETE; iCHECKOUTUSER.DELETE; iDISPOSITION.DELETE; iDELETEDFLAG.DELETE; iEFFECTIVEFROM.DELETE;
          iEFFECTIVEUNTIL.DELETE; iEFFECTIVEUSAGEMASK.DELETE; iUSERSTR01.DELETE; iUSERSTR02.DELETE;
          iUSERSTR03.DELETE; iUSERSTR04.DELETE; iUSERNUM01.DELETE; iUSERNUM02.DELETE; iUSERNUM03.DELETE; iUSERNUM04.DELETE;
          iCREATIONDATE.DELETE; iLASTUPDATEDATE.DELETE; iCREATEDBY.DELETE; iLASTUPDATEDBY.DELETE; iSECURITYMASK.DELETE;
          iPLANLEVEL.DELETE;  iSOITEMTYPECODE.DELETE; iMINIMUMSELECTED.DELETE; iMAXIMUMSELECTED.DELETE; iBOMREQUIRED.DELETE;
          iCOMPONENTSEQUENCEID.DELETE; iORGANIZATIONID.DELETE; iTOPITEMID.DELETE; iEXPLOSIONTYPE.DELETE; iDECIMALQTYFLAG.DELETE;
          iINSTANTIABLEFLAG.DELETE; iQUOTEABLEFLAG.DELETE; iPRIMARYUOMCODE.DELETE; iBOMSORTORDER.DELETE;
          iCOMPONENTSEQUENCEPATH.DELETE;iIBTRACKABLE.DELETE;iSRCAPPLICATIONID.DELETE;iDisplayInSummaryFlag.DELETE;iIBLinkItemFlag.DELETE;

          iShippableItemFlag.DELETE;
          iInventoryTransactableFlag.DELETE;
          iAssembleToOrder.DELETE;
          iSerializableItemFlag.DELETE;

          FETCH c_xfr_psnode BULK COLLECT INTO
          iPSNODEID,iDEVLPROJECTID,iFROMPOPULATORID,iPROPERTYBACKPTR,
          iITEMTYPEBACKPTR,iINTLTEXTID,iSUBCONSID,iITEMID,iNAME,iRESOURCEFLAG,
          iINITIALVALUE,iINITIALNUMVALUE,iPARENTID,iMINIMUM,iMAXIMUM,iPSNODETYPE,iFEATURETYPE,
          iPRODUCTFLAG,iREFERENCEID,iMULTICONFIGFLAG,iORDERSEQFLAG,iSYSTEMNODEFLAG,iTREESEQ,
          iCOUNTEDOPTIONSFLAG,iUIOMIT,iUISECTION,iBOMTREATMENT,iORIGSYSREF,iCHECKOUTUSER,
          iDISPOSITION,iDELETEDFLAG,iEFFECTIVEFROM,iEFFECTIVEUNTIL,iEFFECTIVEUSAGEMASK,iUSERSTR01,iUSERSTR02,iUSERSTR03,
          iUSERSTR04,iUSERNUM01,iUSERNUM02,iUSERNUM03,iUSERNUM04,iCREATIONDATE,iLASTUPDATEDATE,
          iCREATEDBY,iLASTUPDATEDBY,iSECURITYMASK, iPLANLEVEL, iSOITEMTYPECODE,
          iMINIMUMSELECTED,iMAXIMUMSELECTED,iBOMREQUIRED,iCOMPONENTSEQUENCEID,
          iORGANIZATIONID,iTOPITEMID,iEXPLOSIONTYPE,iDECIMALQTYFLAG,iINSTANTIABLEFLAG,
          iQUOTEABLEFLAG,iPRIMARYUOMCODE,iBOMSORTORDER,iCOMPONENTSEQUENCEPATH,iIBTRACKABLE,iSRCAPPLICATIONID,iDisplayInSummaryFlag,
          iIBLinkItemFlag,
          iShippableItemFlag,
          iInventoryTransactableFlag,
          iAssembleToOrder,
          iSerializableItemFlag
          LIMIT COMMIT_SIZE;

          EXIT WHEN (c_xfr_psnode%NOTFOUND AND iPSNODEID.COUNT=0);

         IF iPsNodeId.COUNT > 0 THEN
           --
           -- changes for Solver
           -- raise an exception if maximum value is not specified in case of Generic Import plus FCE, CZ_BOM_DEFAULT_QTY_DOMN='N'
           --
           IF G_CONFIG_ENGINE_TYPE='F' AND FND_PROFILE.VALUE('CZ_BOM_DEFAULT_QTY_DOMN')='N' AND
              inXFR_GROUP='GENERIC' THEN
             FOR j IN iPsNodeID.FIRST..iPsNodeId.LAST
             LOOP
               IF (iPSNODETYPE(j)=263 AND (iMAXIMUMSELECTED(j) IS NULL OR iMAXIMUMSELECTED(j) IN(0,-1))) OR
                  (iPSNODETYPE(j)<>263 AND (iMAXIMUM(j) IS NULL OR iMAXIMUM(j) IN(0,-1))) THEN
                 ROLLBACK;
                 x_error:=CZ_UTILS.LOG_REPORT('Fatal Error : CZ_IMP_PS_NODES.MAXIMUM  should be specified in Generic Import',1,'CZ_IMP_PS_NODE.XFR_PS_NODE',11276,inRun_Id);
                 UPDATE CZ_IMP_PS_NODES
                    SET REC_STATUS='ERR'
                  WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
                        AND DISPOSITION='I';
                 COMMIT;
                 RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
               END IF;
             END LOOP;
           END IF;

          BEGIN  -- bulk insert
            FORALL j IN iPsNodeID.FIRST..iPsNodeId.LAST
                     INSERT INTO CZ_PS_NODES (PS_NODE_ID,
                                              DEVL_PROJECT_ID,
                                              FROM_POPULATOR_ID,
                                              PROPERTY_BACKPTR,
                                              ITEM_TYPE_BACKPTR,
                                              INTL_TEXT_ID,
                                              SUB_CONS_ID,
                                              ITEM_ID,
                                              NAME,
                                              RESOURCE_FLAG,
                                              INITIAL_VALUE,
                                              initial_num_value,
                                              PARENT_ID,
                                              MINIMUM,
                                              MAXIMUM,
                                              PS_NODE_TYPE,
                                              FEATURE_TYPE,
                                              PRODUCT_FLAG,
                                              REFERENCE_ID,
                                              MULTI_CONFIG_FLAG,
                                              ORDER_SEQ_FLAG,
                                              SYSTEM_NODE_FLAG,
                                              TREE_SEQ,
                                              COUNTED_OPTIONS_FLAG,
                                              UI_OMIT,UI_SECTION,
                                              BOM_TREATMENT,
                                              ORIG_SYS_REF,
                                              CHECKOUT_USER,
                                              USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,USER_STR01,USER_STR02,USER_STR03,USER_STR04,
                                              CREATION_DATE,
                                              LAST_UPDATE_DATE,
                                              DELETED_FLAG,
                                              EFFECTIVE_FROM,
                                              EFFECTIVE_UNTIL,
                                              CREATED_BY,
                                              LAST_UPDATED_BY,
                                              SECURITY_MASK,
                                              --EFFECTIVE_USAGE_MASK,
                                              SO_ITEM_TYPE_CODE,
                                              MINIMUM_SELECTED,
                                              MAXIMUM_SELECTED,
                                              BOM_REQUIRED_FLAG,
                                              COMPONENT_SEQUENCE_ID,
                                              DECIMAL_QTY_FLAG,
                                              QUOTEABLE_FLAG,
                                              PRIMARY_UOM_CODE,
                                              BOM_SORT_ORDER,
                                              COMPONENT_SEQUENCE_PATH,
                                              IB_TRACKABLE,
                                              SRC_APPLICATION_ID,
                                              VIRTUAL_FLAG,
                                              INSTANTIABLE_FLAG,
                                              DISPLAY_IN_SUMMARY_FLAG,
                                              IB_LINK_ITEM_FLAG,
                                              SHIPPABLE_ITEM_FLAG,
                                              INVENTORY_TRANSACTABLE_FLAG,
                                              ASSEMBLE_TO_ORDER_FLAG,
                                              SERIALIZABLE_ITEM_FLAG)
                                            VALUES
   			                                 ( iPSNODEID(j),
                                                           iDEVLPROJECTID(j),
                                                           iFROMPOPULATORID(j),  iPROPERTYBACKPTR(j),
                                                           iITEMTYPEBACKPTR(j), iINTLTEXTID(j),
                                                           iSUBCONSID(j), iITEMID(j),
                                                           iNAME(j),iRESOURCEFLAG(j),
                                                           iINITIALVALUE(j), iINITIALNUMVALUE(j),
                                                           iPARENTID(j),
                                                           iMINIMUM(j), iMAXIMUM(j),
                                                           iPSNODETYPE(j), iFEATURETYPE(j),
                                                           iPRODUCTFLAG(j),iREFERENCEID(j),iMULTICONFIGFLAG(j),iORDERSEQFLAG(j),
                                                           iSYSTEMNODEFLAG(j),iTREESEQ(j), iCOUNTEDOPTIONSFLAG(j), iUIOMIT(j),
                                                           iUISECTION(j), iBOMTREATMENT(j),
                                                           iORIGSYSREF(j), iCHECKOUTUSER (j),iUSERNUM01(j),iUSERNUM02(j),
                                                           iUSERNUM03(j), iUSERNUM04(j),
                                                           iUSERSTR01(j), iUSERSTR02(j), iUSERSTR03(j), iUSERSTR04(j),
                                                           SYSDATE, SYSDATE,
                                                           iDELETEDFLAG(j),
                                                           iEFFECTIVEFROM (j), iEFFECTIVEUNTIL (j),
                                                           -UID, -UID, NULL,
                                                           -- iEFFECTIVEUSAGEMASK(j),
                                                           iSOITEMTYPECODE(j),
                                                           iMINIMUMSELECTED(j),
                                                           iMAXIMUMSELECTED(j),
                                                           iBOMREQUIRED(j),
                                                           iCOMPONENTSEQUENCEID(j),
                                                           iDECIMALQTYFLAG(j),
                                                           iQUOTEABLEFLAG(j),
                                                           iPRIMARYUOMCODE(j),
                                                           iBOMSORTORDER(j),
                                                           iCOMPONENTSEQUENCEPATH(j),
                                                           iIBTRACKABLE(j),
                                                           iSRCAPPLICATIONID(j),
                                                           sVirtualFlag,
                                                           iINSTANTIABLEFLAG(j),
                                                           iDisplayInSummaryFlag(j),
                                                           iIBLinkItemFlag(j),
                                                           iShippableItemFlag(j),
                                                           iInventoryTransactableFlag(j),
                                                           iAssembleToOrder(j),
                                                           iSerializableItemFlag(j));

           nInsertCount:= nInsertCount + SQL%ROWCOUNT;
           nCommitCount:= nCommitCount + SQL%ROWCOUNT;

           BEGIN
             FORALL j IN iPsNodeID.FIRST..iPsNodeId.LAST
               UPDATE CZ_IMP_PS_NODES
               SET REC_STATUS='OK'
               WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
               AND DISPOSITION='I';

              /* COMMIT if the buffer size is reached */
              IF(nCommitCount>= COMMIT_SIZE) THEN
                 COMMIT;
                 nCommitCount:=0;
              END IF;

           EXCEPTION
            WHEN OTHERS THEN
  l_debug:=0861;
              ROLLBACK;  -- need to insert row by row to log errors
              l_msg:=p_model_id||':'||SQLERRM;
              x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE('||l_debug||')',11276,inRun_Id);
              RAISE;
           END;

        EXCEPTION  -- bulk insert
         WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
          RAISE;
         WHEN OTHERS THEN

  l_debug:=0862;
          l_msg:=p_model_id||':'||SQLERRM;
          x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE('||l_debug||')',11276,inRun_Id);
           --
           -- changes for Solver
           -- raise an exception if maximum value is not specified in case of Generic Import plus FCE, CZ_BOM_DEFAULT_QTY_DOMN='N'
           --
           IF G_CONFIG_ENGINE_TYPE='F' AND FND_PROFILE.VALUE('CZ_BOM_DEFAULT_QTY_DOMN')='N' AND
              inXFR_GROUP='GENERIC' THEN
             FOR j IN iPsNodeID.FIRST..iPsNodeId.LAST
             LOOP
               IF (iPSNODETYPE(j)=263 AND (iMAXIMUMSELECTED(j) IS NULL OR iMAXIMUMSELECTED(j) IN(0,-1))) OR
                  (iPSNODETYPE(j)<>263 AND (iMAXIMUM(j) IS NULL OR iMAXIMUM(j) IN(0,-1))) THEN

                 ROLLBACK;
                 x_error:=CZ_UTILS.LOG_REPORT('Fatal Error : CZ_IMP_PS_NODES.MAXIMUM should be specified in Generic Import',1,'CZ_IMP_PS_NODE.XFR_PS_NODE',11276,inRun_Id);
                 UPDATE CZ_IMP_PS_NODES
                    SET REC_STATUS='ERR'
                  WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
                        AND DISPOSITION='I';
                 COMMIT;
                 RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
               END IF;
             END LOOP;
           END IF;

          FOR j IN iPsNodeID.FIRST..iPsNodeId.LAST LOOP  -- singe row loop

            IF(FAILED >= MAX_ERR) THEN
              ROLLBACK;
              x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.XFR_PS_NODE',11276,inRun_Id);
              RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
            END IF;

            BEGIN  -- single row insert
                     INSERT INTO CZ_PS_NODES (PS_NODE_ID,
                                              DEVL_PROJECT_ID,
                                              FROM_POPULATOR_ID,
                                              PROPERTY_BACKPTR,
                                              ITEM_TYPE_BACKPTR,
                                              INTL_TEXT_ID,
                                              SUB_CONS_ID,
                                              ITEM_ID,
                                              NAME,
                                              RESOURCE_FLAG,
                                              INITIAL_VALUE,
                                              initial_num_value,
                                              PARENT_ID,
                                              MINIMUM,
                                              MAXIMUM,
                                              PS_NODE_TYPE,
                                              FEATURE_TYPE,
                                              PRODUCT_FLAG,
                                              REFERENCE_ID,
                                              MULTI_CONFIG_FLAG,
                                              ORDER_SEQ_FLAG,
                                              SYSTEM_NODE_FLAG,
                                              TREE_SEQ,
                                              COUNTED_OPTIONS_FLAG,
                                              UI_OMIT,UI_SECTION,
                                              BOM_TREATMENT,
                                              ORIG_SYS_REF,
                                              CHECKOUT_USER,
                                              USER_NUM01,USER_NUM02,USER_NUM03,USER_NUM04,USER_STR01,USER_STR02,USER_STR03,USER_STR04,
                                              CREATION_DATE,
                                              LAST_UPDATE_DATE,
                                              DELETED_FLAG,
                                              EFFECTIVE_FROM,
                                              EFFECTIVE_UNTIL,
                                              CREATED_BY,
                                              LAST_UPDATED_BY,
                                              SECURITY_MASK,
                                              --EFFECTIVE_USAGE_MASK,
                                              SO_ITEM_TYPE_CODE,
                                              MINIMUM_SELECTED,
                                              MAXIMUM_SELECTED,
                                              BOM_REQUIRED_FLAG,
                                              COMPONENT_SEQUENCE_ID,
                                              DECIMAL_QTY_FLAG,
                                              QUOTEABLE_FLAG,
                                              PRIMARY_UOM_CODE,
                                              BOM_SORT_ORDER,
                                              COMPONENT_SEQUENCE_PATH,
                                              IB_TRACKABLE,
                                              SRC_APPLICATION_ID,
                                              VIRTUAL_FLAG,
                                              INSTANTIABLE_FLAG,
                                              DISPLAY_IN_SUMMARY_FLAG,
                                              IB_LINK_ITEM_FLAG,
                                              SHIPPABLE_ITEM_FLAG,
                                              INVENTORY_TRANSACTABLE_FLAG,
                                              ASSEMBLE_TO_ORDER_FLAG,
                                              SERIALIZABLE_ITEM_FLAG)
                                            VALUES
   			                                 ( iPSNODEID(j),
                                                           iDEVLPROJECTID(j),
                                                           iFROMPOPULATORID(j),  iPROPERTYBACKPTR(j),
                                                           iITEMTYPEBACKPTR(j), iINTLTEXTID(j),
                                                           iSUBCONSID(j), iITEMID(j),
                                                           iNAME(j),iRESOURCEFLAG(j),
                                                           iINITIALVALUE(j), iINITIALNUMVALUE(j),
                                                           iPARENTID(j),
                                                           iMINIMUM(j), iMAXIMUM(j),
                                                           iPSNODETYPE(j), iFEATURETYPE(j),
                                                           iPRODUCTFLAG(j),iREFERENCEID(j),iMULTICONFIGFLAG(j),iORDERSEQFLAG(j),
                                                           iSYSTEMNODEFLAG(j),iTREESEQ(j), iCOUNTEDOPTIONSFLAG(j), iUIOMIT(j),
                                                           iUISECTION(j), iBOMTREATMENT(j),
                                                           iORIGSYSREF(j), iCHECKOUTUSER (j),iUSERNUM01(j),iUSERNUM02(j),
                                                           iUSERNUM03(j), iUSERNUM04(j),
                                                           iUSERSTR01(j), iUSERSTR02(j), iUSERSTR03(j), iUSERSTR04(j),
                                                           SYSDATE, SYSDATE,
                                                           iDELETEDFLAG(j),
                                                           iEFFECTIVEFROM (j), iEFFECTIVEUNTIL (j),
                                                           -UID, -UID, NULL,
                                                           -- iEFFECTIVEUSAGEMASK(j),
                                                           iSOITEMTYPECODE(j),
                                                           iMINIMUMSELECTED(j),
                                                           iMAXIMUMSELECTED(j),
                                                           iBOMREQUIRED(j),
                                                           iCOMPONENTSEQUENCEID(j),
                                                           iDECIMALQTYFLAG(j),
                                                           iQUOTEABLEFLAG(j),
                                                           iPRIMARYUOMCODE(j),
                                                           iBOMSORTORDER(j),
                                                           iCOMPONENTSEQUENCEPATH(j),
                                                           iIBTRACKABLE(j),
                                                           iSRCAPPLICATIONID(j),
                                                           sVirtualFlag,
                                                           iINSTANTIABLEFLAG(j),
                                                           iDisplayInSummaryFlag(j),
                                                           iIBLinkItemFlag(j),
                                                           iShippableItemFlag(j),
                                                           iInventoryTransactableFlag(j),
                                                           iAssembleToOrder(j),
                                                           iSerializableItemFlag(j));


			nInsertCount:=nInsertCount+1;

              UPDATE CZ_IMP_PS_NODES
              SET REC_STATUS='OK'
              WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
              AND DISPOSITION='I';

              nCommitCount:=nCommitCount+1;
              /* COMMIT if the buffer size is reached */
              IF(nCommitCount>= COMMIT_SIZE) THEN
                 COMMIT;
                 nCommitCount:=0;
              END IF;


          EXCEPTION  -- single row insert
           WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
             RAISE;
           WHEN OTHERS THEN
                         IF(iPSNODEID(j) = iDEVLPROJECTID(j))THEN
                            x_retcode := 1;

                            -- get model name for  message log
                              SELECT name INTO l_model_name
                              FROM cz_imp_devl_project
                              WHERE devl_project_id=p_model_id
                              AND deleted_flag='0'
                              AND run_id=inRun_ID
                              AND rec_status='OK'
                              AND rownum <2;

                            l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_XFR_ROOT_NODE_I',
                                                     'MODELNAME', l_model_name,
                                                     'NODENAME', iName(j),
                                                     'NODEID', iPsNodeId(j),
                                                     'ERRORTEXT', SQLERRM);

                            x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                            COMMIT;

                            EXIT OUTER_LOOP;
                         ELSE
                          --  not a root node, so import continues
                          FAILED:=FAILED +1;
                          UPDATE CZ_IMP_PS_NODES
                          SET REC_STATUS='ERR'
                          WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
                          AND DISPOSITION='I';

                          -- get model name
                           SELECT name INTO l_model_name
                           FROM cz_imp_devl_project
                           WHERE devl_project_id=p_model_id
                           AND deleted_flag='0'
                           AND run_id=inRun_ID
                           AND rec_status='OK'
                           AND rownum <2;

                          l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_XFR_NODE_I',
                                                   'MODELNAME', l_model_name,
                                                   'NODENAME', iName(j),
                                                   'NODEID', iPsNodeId(j),
                                                   'ERRORTEXT', SQLERRM);
                          x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                        END IF;

              END;         --single row insert
             END lOOP;  -- single row for loop
           END;      -- bulk insert
          END IF;   -- if count > 0
        END LOOP;  -- bulk fetch for insert
        IF c_xfr_psnode%ISOPEN THEN
           CLOSE c_xfr_psnode;
        END IF;

  END insert_ps_nodes;

  -- Private prcedure that update all PS nodes for the model passed in, it bulk fetches and
  -- tries to bulk update, if bulk insert fails, then it updates row by row
  -- and logs rows failed to update and continues untill all ps nodes are processed

  -- returns nothing

  PROCEDURE update_ps_nodes(p_model_id IN NUMBER)
  IS
  BEGIN


        IF c_xfr_psnode%ISOPEN THEN
          CLOSE c_xfr_psnode;
        END IF;

        OPEN c_xfr_psnode (p_model_id, 'M');

        LOOP   -- bulk fetch for update

         iPSNODEID.DELETE; iDEVLPROJECTID.DELETE; iFROMPOPULATORID.DELETE; iPROPERTYBACKPTR.DELETE;
         iITEMTYPEBACKPTR.DELETE; iINTLTEXTID.DELETE; iSUBCONSID.DELETE; iITEMID.DELETE; iNAME.DELETE; iRESOURCEFLAG.DELETE;
         iINITIALVALUE.DELETE; iInitialnumvalue.DELETE; iPARENTID.DELETE; iMINIMUM.DELETE; iMAXIMUM.DELETE; iPSNODETYPE.DELETE;
         iFEATURETYPE.DELETE; iPRODUCTFLAG.DELETE; iREFERENCEID.DELETE; iMULTICONFIGFLAG.DELETE; iORDERSEQFLAG.DELETE;
         iSYSTEMNODEFLAG.DELETE; iTREESEQ.DELETE; iCOUNTEDOPTIONSFLAG.DELETE; iUIOMIT.DELETE; iUISECTION.DELETE; iBOMTREATMENT.DELETE;
         iORIGSYSREF.DELETE; iCHECKOUTUSER.DELETE; iDISPOSITION.DELETE; iDELETEDFLAG.DELETE; iEFFECTIVEFROM.DELETE;
         iEFFECTIVEUNTIL.DELETE; iEFFECTIVEUSAGEMASK.DELETE; iUSERSTR01.DELETE; iUSERSTR02.DELETE;
         iUSERSTR03.DELETE; iUSERSTR04.DELETE; iUSERNUM01.DELETE; iUSERNUM02.DELETE; iUSERNUM03.DELETE; iUSERNUM04.DELETE;
         iCREATIONDATE.DELETE; iLASTUPDATEDATE.DELETE; iCREATEDBY.DELETE; iLASTUPDATEDBY.DELETE; iSECURITYMASK.DELETE;
         iPLANLEVEL.DELETE;  iSOITEMTYPECODE.DELETE; iMINIMUMSELECTED.DELETE; iMAXIMUMSELECTED.DELETE; iBOMREQUIRED.DELETE;
         iCOMPONENTSEQUENCEID.DELETE; iORGANIZATIONID.DELETE; iTOPITEMID.DELETE; iEXPLOSIONTYPE.DELETE; iDECIMALQTYFLAG.DELETE;
         iINSTANTIABLEFLAG.DELETE; iQUOTEABLEFLAG.DELETE; iPRIMARYUOMCODE.DELETE; iBOMSORTORDER.DELETE;
         iCOMPONENTSEQUENCEPATH.DELETE;iIBTRACKABLE.DELETE;iSRCAPPLICATIONID.DELETE;iDisplayInSummaryFlag.DELETE;iIBLinkItemFlag.DELETE;

         iShippableItemFlag.DELETE;
         iInventoryTransactableFlag.DELETE;
         iAssembleToOrder.DELETE;
         iSerializableItemFlag.DELETE;

         FETCH c_xfr_psnode BULK COLLECT INTO
         iPSNODEID,iDEVLPROJECTID,iFROMPOPULATORID,iPROPERTYBACKPTR,
         iITEMTYPEBACKPTR,iINTLTEXTID,iSUBCONSID,iITEMID,iNAME,iRESOURCEFLAG,
         iINITIALVALUE,iInitialnumvalue,iPARENTID,iMINIMUM,iMAXIMUM,iPSNODETYPE,iFEATURETYPE,
         iPRODUCTFLAG,iREFERENCEID,iMULTICONFIGFLAG,iORDERSEQFLAG,iSYSTEMNODEFLAG,iTREESEQ,
         iCOUNTEDOPTIONSFLAG,iUIOMIT,iUISECTION,iBOMTREATMENT,iORIGSYSREF,iCHECKOUTUSER,
         iDISPOSITION,iDELETEDFLAG,iEFFECTIVEFROM,iEFFECTIVEUNTIL,iEFFECTIVEUSAGEMASK,iUSERSTR01,iUSERSTR02,iUSERSTR03,
         iUSERSTR04,iUSERNUM01,iUSERNUM02,iUSERNUM03,iUSERNUM04,iCREATIONDATE,iLASTUPDATEDATE,
         iCREATEDBY,iLASTUPDATEDBY,iSECURITYMASK, iPLANLEVEL, iSOITEMTYPECODE,
         iMINIMUMSELECTED,iMAXIMUMSELECTED,iBOMREQUIRED,iCOMPONENTSEQUENCEID,
         iORGANIZATIONID,iTOPITEMID,iEXPLOSIONTYPE,iDECIMALQTYFLAG,iINSTANTIABLEFLAG,
         iQUOTEABLEFLAG,iPRIMARYUOMCODE,iBOMSORTORDER,iCOMPONENTSEQUENCEPATH,iIBTRACKABLE,iSRCAPPLICATIONID,iDisplayInSummaryFlag,
         iIBLinkItemFlag,
         iShippableItemFlag,
         iInventoryTransactableFlag,
         iAssembleToOrder,
         iSerializableItemFlag
         LIMIT COMMIT_SIZE;
         EXIT WHEN (c_xfr_psnode%NOTFOUND AND iPSNODEID.COUNT=0);

       IF iPsNodeId.COUNT > 0 THEN
         --
         -- changes for Solver
         -- raise an exception if maximum value is not specified in case of Generic Import plus FCE, CZ_BOM_DEFAULT_QTY_DOMN='N'
         --
         IF G_CONFIG_ENGINE_TYPE='F' AND FND_PROFILE.VALUE('CZ_BOM_DEFAULT_QTY_DOMN')='N' AND
            inXFR_GROUP='GENERIC' THEN
           FOR j IN iPsNodeID.FIRST..iPsNodeId.LAST
           LOOP
               IF (iPSNODETYPE(j)=263 AND (iMAXIMUMSELECTED(j) IS NULL OR iMAXIMUMSELECTED(j) IN(0,-1))) OR
                  (iPSNODETYPE(j)<>263 AND (iMAXIMUM(j) IS NULL OR iMAXIMUM(j) IN(0,-1))) THEN
               ROLLBACK;
               x_error:=CZ_UTILS.LOG_REPORT('Fatal Error : CZ_IMP_PS_NODES.MAXIMUM should be specified in Generic Import',1,'CZ_IMP_PS_NODE.XFR_PS_NODE',11276,inRun_Id);
               UPDATE CZ_IMP_PS_NODES
                  SET REC_STATUS='ERR'
                WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
                      AND DISPOSITION='M';
               COMMIT;
               RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
             END IF;
           END LOOP;
         END IF;

         BEGIN -- bulk update
          FORALL j IN iPsNodeID.FIRST..iPsNodeId.LAST
	   UPDATE CZ_PS_NODES SET
  	   DEVL_PROJECT_ID=		DECODE(NOUPDATE_DEVL_PROJECT_ID,0,iDEVLPROJECTID(j),DEVL_PROJECT_ID),
	   FROM_POPULATOR_ID=	DECODE(NOUPDATE_FROM_POPULATOR_ID,0,iFROMPOPULATORID(j),FROM_POPULATOR_ID),
  	   PROPERTY_BACKPTR=		DECODE(NOUPDATE_PROPERTY_BACKPTR,0,iPROPERTYBACKPTR(j),PROPERTY_BACKPTR),
	   ITEM_TYPE_BACKPTR=	DECODE(NOUPDATE_ITEM_TYPE_BACKPTR,0,iITEMTYPEBACKPTR(j),ITEM_TYPE_BACKPTR),
	   INTL_TEXT_ID=		DECODE(NOUPDATE_INTL_TEXT_ID,0,iINTLTEXTID(j),INTL_TEXT_ID),
	   SUB_CONS_ID=		DECODE(NOUPDATE_SUB_CONS_ID,0,iSUBCONSID(j),SUB_CONS_ID),
	   ITEM_ID=			DECODE(NOUPDATE_ITEM_ID,0,iITEMID(j),ITEM_ID),
           NAME=				DECODE(NOUPDATE_NAME,0,iNAME(j),NAME),
 	   RESOURCE_FLAG=		DECODE(NOUPDATE_RESOURCE_FLAG,0,iRESOURCEFLAG(j),RESOURCE_FLAG),
	   INITIAL_VALUE=		DECODE(NOUPDATE_INITIAL_VALUE,0,iINITIALVALUE(j),INITIAL_VALUE),
           initial_num_value=		DECODE(NOUPDATE_initial_num_value,0,iINITIALNUMVALUE(j),initial_num_value),
	   PARENT_ID=DECODE(NOUPDATE_PARENT_ID,0,DECODE(iPLANLEVEL(j),0,PARENT_ID,iPARENTID(j)),PARENT_ID),
	   MINIMUM=		DECODE(NOUPDATE_MINIMUM,0,iMINIMUM(j),MINIMUM),
	   MAXIMUM=	DECODE(NOUPDATE_MAXIMUM,0,iMAXIMUM(j),MAXIMUM),
	   PS_NODE_TYPE=		DECODE(NOUPDATE_PS_NODE_TYPE,0,iPSNODETYPE(j),PS_NODE_TYPE),
	   FEATURE_TYPE=		DECODE(NOUPDATE_FEATURE_TYPE,0,iFEATURETYPE(j),FEATURE_TYPE),
	   PRODUCT_FLAG=		DECODE(NOUPDATE_PRODUCT_FLAG,0,iPRODUCTFLAG(j),PRODUCT_FLAG),
	   REFERENCE_ID=		DECODE(NOUPDATE_REFERENCE_ID,0,iREFERENCEID(j),REFERENCE_ID),
	   MULTI_CONFIG_FLAG=	DECODE(NOUPDATE_MULTI_CONFIG_FLAG,0,iMULTICONFIGFLAG(j),MULTI_CONFIG_FLAG),
	   ORDER_SEQ_FLAG=		DECODE(NOUPDATE_ORDER_SEQ_FLAG,0,iORDERSEQFLAG(j),ORDER_SEQ_FLAG),
	   SYSTEM_NODE_FLAG=		DECODE(NOUPDATE_SYSTEM_NODE_FLAG,0,iSYSTEMNODEFLAG(j),SYSTEM_NODE_FLAG),
	   TREE_SEQ=			DECODE(NOUPDATE_TREE_SEQ,0,iTREESEQ(j),TREE_SEQ),
	   COUNTED_OPTIONS_FLAG=	DECODE(NOUPDATE_COUNTED_OPTIONS_FLAG,0,iCOUNTEDOPTIONSFLAG(j),COUNTED_OPTIONS_FLAG),
	   UI_OMIT=			DECODE(NOUPDATE_UI_OMIT,0,iUIOMIT(j),UI_OMIT),
	   UI_SECTION=			DECODE(NOUPDATE_UI_SECTION,0,iUISECTION(j),UI_SECTION),
           BOM_TREATMENT= 		DECODE(NOUPDATE_BOM_TREATMENT,0,iBOMTREATMENT(j),BOM_TREATMENT),
	   ORIG_SYS_REF=		DECODE(NOUPDATE_ORIG_SYS_REF,0,iORIGSYSREF(j),ORIG_SYS_REF),
	   CHECKOUT_USER=		DECODE(NOUPDATE_CHECKOUT_USER,0,iCHECKOUTUSER(j),CHECKOUT_USER),
   	   DELETED_FLAG=		DECODE(NOUPDATE_DELETED_FLAG,0,iDELETEDFLAG(j),DELETED_FLAG),
	   USER_NUM01=			DECODE(NOUPDATE_USER_NUM01,0,iUSERNUM01(j),USER_NUM01),
 	   USER_NUM02=			DECODE(NOUPDATE_USER_NUM02,0,iUSERNUM02(j),USER_NUM02),
	   USER_NUM03=			DECODE(NOUPDATE_USER_NUM03,0,iUSERNUM03(j),USER_NUM03),
	   USER_NUM04=			DECODE(NOUPDATE_USER_NUM04,0,iUSERNUM04(j),USER_NUM04),
  	   USER_STR01=			DECODE(NOUPDATE_USER_STR01,0,iUSERSTR01(j),USER_STR01),
	   USER_STR02=			DECODE(NOUPDATE_USER_STR02,0,iUSERSTR02(j),USER_STR02),
	   USER_STR03=			DECODE(NOUPDATE_USER_STR03,0,iUSERSTR03(j),USER_STR03),
	   USER_STR04=			DECODE(NOUPDATE_USER_STR04,0,iUSERSTR04(j),USER_STR04),
	   --CREATION_DATE=		DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
	   LAST_UPDATE_DATE=		DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
	   EFFECTIVE_FROM=		DECODE(NOUPDATE_EFF_FROM,0,iEFFECTIVEFROM(j),EFFECTIVE_FROM),
	   EFFECTIVE_UNTIL=		DECODE(NOUPDATE_EFF_TO,0,iEFFECTIVEUNTIL(j),EFFECTIVE_UNTIL),
	   --CREATED_BY=		DECODE(NOUPDATE_CREATED_BY,0,-UID,CREATED_BY),
	   LAST_UPDATED_BY=		DECODE(NOUPDATE_LAST_UPDATED_BY,0,-UID,LAST_UPDATED_BY),
	   SECURITY_MASK=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
	   --EFFECTIVE_USAGE_MASK=	DECODE(NOUPDATE_EFF_MASK,0,iEFFECTIVEUSAGEMASK(j),EFFECTIVE_USAGE_MASK),
          SO_ITEM_TYPE_CODE=      DECODE(NOUPDATE_SO_ITEM_TYPE_CODE,0,iSOITEMTYPECODE(j),SO_ITEM_TYPE_CODE),
          MINIMUM_SELECTED=       DECODE(NOUPDATE_MINIMUM_SELECTED,0,iMINIMUMSELECTED(j),MINIMUM_SELECTED),
          MAXIMUM_SELECTED=       DECODE(NOUPDATE_MAXIMUM_SELECTED,0,iMAXIMUMSELECTED(j),MAXIMUM_SELECTED),
          BOM_REQUIRED_FLAG=      DECODE(NOUPDATE_BOM_REQUIRED,0,iBOMREQUIRED(j),BOM_REQUIRED_FLAG),
          COMPONENT_SEQUENCE_ID=  DECODE(NOUPDATE_COMPONENT_SEQUENCE_ID,0,iCOMPONENTSEQUENCEID(j),COMPONENT_SEQUENCE_ID),
          DECIMAL_QTY_FLAG=       DECODE(NOUPDATE_DECIMAL_QTY_FLAG,0,iDECIMALQTYFLAG(j),DECIMAL_QTY_FLAG),
          QUOTEABLE_FLAG=         DECODE(NOUPDATE_QUOTEABLE_FLAG,0,iQUOTEABLEFLAG(j),QUOTEABLE_FLAG),
          PRIMARY_UOM_CODE=       DECODE(NOUPDATE_PRIMARY_UOM_CODE,0,iPRIMARYUOMCODE(j),PRIMARY_UOM_CODE),
          BOM_SORT_ORDER=         DECODE(NOUPDATE_BOM_SORT_ORDER,0,iBOMSORTORDER(j),BOM_SORT_ORDER),
          COMPONENT_SEQUENCE_PATH=DECODE(NOUPDATE_SEQUENCE_PATH,0,iCOMPONENTSEQUENCEPATH(j),COMPONENT_SEQUENCE_PATH),
          IB_TRACKABLE=	          DECODE(NOUPDATE_IB_TRACKABLE,0,iIBTRACKABLE(j),IB_TRACKABLE),
          SRC_APPLICATION_ID=   iSRCAPPLICATIONID(j),
          DISPLAY_IN_SUMMARY_FLAG=DECODE(NOUPDATE_DSPLY_SMRY_FLG,0,iDisplayInSummaryFlag(j),DISPLAY_IN_SUMMARY_FLAG),
          IB_LINK_ITEM_FLAG=DECODE(NOUPDATE_IBLINKITEM_FLG,0,iIBLinkItemFlag(j),IB_LINK_ITEM_FLAG),
          INSTANTIABLE_FLAG=DECODE(NOUPDATE_INSTANTIABLE_FLAG,0,iINSTANTIABLEFLAG(j),INSTANTIABLE_FLAG),
          SHIPPABLE_ITEM_FLAG         = DECODE(NOUPDATE_SHIPPABLE_ITEM_FLAG,0,iShippableItemFlag(j), SHIPPABLE_ITEM_FLAG),
          INVENTORY_TRANSACTABLE_FLAG = DECODE(NOUPDATE_INV_TXN_FLAG, 0, iInventoryTransactableFlag(j), INVENTORY_TRANSACTABLE_FLAG),
          ASSEMBLE_TO_ORDER_FLAG      = DECODE(NOUPDATE_ASM_TO_ORDER_FLAG, 0, iAssembleToOrder(j), ASSEMBLE_TO_ORDER_FLAG),
          SERIALIZABLE_ITEM_FLAG      = DECODE(NOUPDATE_SERIAL_ITEM_FLAG, 0, iSerializableItemFlag(j), SERIALIZABLE_ITEM_FLAG)
          WHERE PS_NODE_ID=iPSNODEID(j);

          nUpdateCount:= nUpdateCount + SQL%ROWCOUNT;
          nCommitCount:= nCommitCount + SQL%ROWCOUNT;

          BEGIN  -- bulk update
            FORALL j IN iPsNodeID.FIRST..iPsNodeId.LAST
               UPDATE CZ_IMP_PS_NODES
               SET REC_STATUS='OK'
               WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
               AND DISPOSITION='M';

              /* COMMIT if the buffer size is reached */
              IF(nCommitCount>= COMMIT_SIZE) THEN
                 COMMIT;
                 nCommitCount:=0;
              END IF;

          EXCEPTION
           WHEN OTHERS THEN
  l_debug:=0871;
                  ROLLBACK;  -- need to insert row by row to log error messages
                  l_msg:=p_model_id||':'||SQLERRM;
                  x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE('||l_debug||')',11276,inRun_Id);
                  RAISE;
          END;

         EXCEPTION  -- bulk update
          WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
           RAISE;
          WHEN OTHERS THEN
  l_debug:=0872;
          l_msg:=p_model_id||':'||SQLERRM;
          x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE('||l_debug||')',11276,inRun_Id);
           --
           -- changes for Solver
           -- raise an exception if maximum value is not specified in case of Generic Import plus FCE, CZ_BOM_DEFAULT_QTY_DOMN='N'
           --
           IF G_CONFIG_ENGINE_TYPE='F' AND FND_PROFILE.VALUE('CZ_BOM_DEFAULT_QTY_DOMN')='N' AND
              inXFR_GROUP='GENERIC' THEN
           FOR j IN iPsNodeID.FIRST..iPsNodeId.LAST
           LOOP
               IF (iPSNODETYPE(j)=263 AND (iMAXIMUMSELECTED(j) IS NULL OR iMAXIMUMSELECTED(j) IN(0,-1))) OR
                  (iPSNODETYPE(j)<>263 AND (iMAXIMUM(j) IS NULL OR iMAXIMUM(j) IN(0,-1))) THEN
               ROLLBACK;
               x_error:=CZ_UTILS.LOG_REPORT('Fatal Error : CZ_IMP_PS_NODES.MAXIMUM should be specified in Generic Import',1,'CZ_IMP_PS_NODE.XFR_PS_NODE',11276,inRun_Id);
               RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
               END IF;
             END LOOP;
           END IF;

           FOR j IN iPsNodeID.FIRST..iPsNodeId.LAST LOOP  --  single row loop

             IF (FAILED >= MAX_ERR) THEN
               ROLLBACK;
               x_error:=CZ_UTILS.LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED'),1,'CZ_IMP_PS_NODE.XFR_PS_NODE',11276,inRun_Id);
               RAISE CZ_ADMIN.IMP_MAXERR_REACHED;
             END IF;


             BEGIN -- single row update
    	      UPDATE CZ_PS_NODES SET
    	      DEVL_PROJECT_ID=		DECODE(NOUPDATE_DEVL_PROJECT_ID,0,iDEVLPROJECTID(j),DEVL_PROJECT_ID),
	      FROM_POPULATOR_ID=	DECODE(NOUPDATE_FROM_POPULATOR_ID,0,iFROMPOPULATORID(j),FROM_POPULATOR_ID),
  	      PROPERTY_BACKPTR=		DECODE(NOUPDATE_PROPERTY_BACKPTR,0,iPROPERTYBACKPTR(j),PROPERTY_BACKPTR),
	      ITEM_TYPE_BACKPTR=	DECODE(NOUPDATE_ITEM_TYPE_BACKPTR,0,iITEMTYPEBACKPTR(j),ITEM_TYPE_BACKPTR),
	      INTL_TEXT_ID=		DECODE(NOUPDATE_INTL_TEXT_ID,0,iINTLTEXTID(j),INTL_TEXT_ID),
	      SUB_CONS_ID=		DECODE(NOUPDATE_SUB_CONS_ID,0,iSUBCONSID(j),SUB_CONS_ID),
	      ITEM_ID=			DECODE(NOUPDATE_ITEM_ID,0,iITEMID(j),ITEM_ID),
              NAME=				DECODE(NOUPDATE_NAME,0,iNAME(j),NAME),
 	      RESOURCE_FLAG=		DECODE(NOUPDATE_RESOURCE_FLAG,0,iRESOURCEFLAG(j),RESOURCE_FLAG),
	      INITIAL_VALUE=		DECODE(NOUPDATE_INITIAL_VALUE,0,iINITIALVALUE(j),INITIAL_VALUE),
              initial_num_value=		DECODE(NOUPDATE_initial_num_value,0,iINITIALNUMVALUE(j),initial_num_value),
	   PARENT_ID=DECODE(NOUPDATE_PARENT_ID,0,DECODE(iPLANLEVEL(j),0,PARENT_ID,iPARENTID(j)),PARENT_ID),
	   MINIMUM=		DECODE(NOUPDATE_MINIMUM,0,iMINIMUM(j),MINIMUM),
	   MAXIMUM=	DECODE(NOUPDATE_MAXIMUM,0,iMAXIMUM(j),MAXIMUM),
	   PS_NODE_TYPE=		DECODE(NOUPDATE_PS_NODE_TYPE,0,iPSNODETYPE(j),PS_NODE_TYPE),
	   FEATURE_TYPE=		DECODE(NOUPDATE_FEATURE_TYPE,0,iFEATURETYPE(j),FEATURE_TYPE),
	   PRODUCT_FLAG=		DECODE(NOUPDATE_PRODUCT_FLAG,0,iPRODUCTFLAG(j),PRODUCT_FLAG),
	   REFERENCE_ID=		DECODE(NOUPDATE_REFERENCE_ID,0,iREFERENCEID(j),REFERENCE_ID),
	   MULTI_CONFIG_FLAG=	DECODE(NOUPDATE_MULTI_CONFIG_FLAG,0,iMULTICONFIGFLAG(j),MULTI_CONFIG_FLAG),
	   ORDER_SEQ_FLAG=		DECODE(NOUPDATE_ORDER_SEQ_FLAG,0,iORDERSEQFLAG(j),ORDER_SEQ_FLAG),
	   SYSTEM_NODE_FLAG=		DECODE(NOUPDATE_SYSTEM_NODE_FLAG,0,iSYSTEMNODEFLAG(j),SYSTEM_NODE_FLAG),
	   TREE_SEQ=			DECODE(NOUPDATE_TREE_SEQ,0,iTREESEQ(j),TREE_SEQ),
	   COUNTED_OPTIONS_FLAG=	DECODE(NOUPDATE_COUNTED_OPTIONS_FLAG,0,iCOUNTEDOPTIONSFLAG(j),COUNTED_OPTIONS_FLAG),
	   UI_OMIT=			DECODE(NOUPDATE_UI_OMIT,0,iUIOMIT(j),UI_OMIT),
	   UI_SECTION=			DECODE(NOUPDATE_UI_SECTION,0,iUISECTION(j),UI_SECTION),
           BOM_TREATMENT= 		DECODE(NOUPDATE_BOM_TREATMENT,0,iBOMTREATMENT(j),BOM_TREATMENT),
	   ORIG_SYS_REF=		DECODE(NOUPDATE_ORIG_SYS_REF,0,iORIGSYSREF(j),ORIG_SYS_REF),
	   CHECKOUT_USER=		DECODE(NOUPDATE_CHECKOUT_USER,0,iCHECKOUTUSER(j),CHECKOUT_USER),
   	   DELETED_FLAG=		DECODE(NOUPDATE_DELETED_FLAG,0,iDELETEDFLAG(j),DELETED_FLAG),
	   USER_NUM01=			DECODE(NOUPDATE_USER_NUM01,0,iUSERNUM01(j),USER_NUM01),
 	   USER_NUM02=			DECODE(NOUPDATE_USER_NUM02,0,iUSERNUM02(j),USER_NUM02),
	   USER_NUM03=			DECODE(NOUPDATE_USER_NUM03,0,iUSERNUM03(j),USER_NUM03),
	   USER_NUM04=			DECODE(NOUPDATE_USER_NUM04,0,iUSERNUM04(j),USER_NUM04),
  	   USER_STR01=			DECODE(NOUPDATE_USER_STR01,0,iUSERSTR01(j),USER_STR01),
	   USER_STR02=			DECODE(NOUPDATE_USER_STR02,0,iUSERSTR02(j),USER_STR02),
	   USER_STR03=			DECODE(NOUPDATE_USER_STR03,0,iUSERSTR03(j),USER_STR03),
	   USER_STR04=			DECODE(NOUPDATE_USER_STR04,0,iUSERSTR04(j),USER_STR04),
	   --CREATION_DATE=		DECODE(NOUPDATE_CREATION_DATE,0,SYSDATE,CREATION_DATE),
	   LAST_UPDATE_DATE=		DECODE(NOUPDATE_LAST_UPDATE_DATE,0,SYSDATE,LAST_UPDATE_DATE),
	   EFFECTIVE_FROM=		DECODE(NOUPDATE_EFF_FROM,0,iEFFECTIVEFROM(j),EFFECTIVE_FROM),
	   EFFECTIVE_UNTIL=		DECODE(NOUPDATE_EFF_TO,0,iEFFECTIVEUNTIL(j),EFFECTIVE_UNTIL),
	   --CREATED_BY=		DECODE(NOUPDATE_CREATED_BY,0,-UID,CREATED_BY),
	   LAST_UPDATED_BY=		DECODE(NOUPDATE_LAST_UPDATED_BY,0,-UID,LAST_UPDATED_BY),
	   SECURITY_MASK=		DECODE(NOUPDATE_SECURITY_MASK,0,NULL,SECURITY_MASK),
	   --EFFECTIVE_USAGE_MASK=	DECODE(NOUPDATE_EFF_MASK,0,iEFFECTIVEUSAGEMASK(j),EFFECTIVE_USAGE_MASK),
          SO_ITEM_TYPE_CODE=      DECODE(NOUPDATE_SO_ITEM_TYPE_CODE,0,iSOITEMTYPECODE(j),SO_ITEM_TYPE_CODE),
          MINIMUM_SELECTED=       DECODE(NOUPDATE_MINIMUM_SELECTED,0,iMINIMUMSELECTED(j),MINIMUM_SELECTED),
          MAXIMUM_SELECTED=       DECODE(NOUPDATE_MAXIMUM_SELECTED,0,iMAXIMUMSELECTED(j),MAXIMUM_SELECTED),
          BOM_REQUIRED_FLAG=      DECODE(NOUPDATE_BOM_REQUIRED,0,iBOMREQUIRED(j),BOM_REQUIRED_FLAG),
          COMPONENT_SEQUENCE_ID=  DECODE(NOUPDATE_COMPONENT_SEQUENCE_ID,0,iCOMPONENTSEQUENCEID(j),COMPONENT_SEQUENCE_ID),
          DECIMAL_QTY_FLAG=       DECODE(NOUPDATE_DECIMAL_QTY_FLAG,0,iDECIMALQTYFLAG(j),DECIMAL_QTY_FLAG),
          QUOTEABLE_FLAG=         DECODE(NOUPDATE_QUOTEABLE_FLAG,0,iQUOTEABLEFLAG(j),QUOTEABLE_FLAG),
          PRIMARY_UOM_CODE=       DECODE(NOUPDATE_PRIMARY_UOM_CODE,0,iPRIMARYUOMCODE(j),PRIMARY_UOM_CODE),
          BOM_SORT_ORDER=         DECODE(NOUPDATE_BOM_SORT_ORDER,0,iBOMSORTORDER(j),BOM_SORT_ORDER),
          COMPONENT_SEQUENCE_PATH=DECODE(NOUPDATE_SEQUENCE_PATH,0,iCOMPONENTSEQUENCEPATH(j),COMPONENT_SEQUENCE_PATH),
          IB_TRACKABLE=	      DECODE(NOUPDATE_IB_TRACKABLE,0,iIBTRACKABLE(j),IB_TRACKABLE),
          SRC_APPLICATION_ID=   iSRCAPPLICATIONID(j),
          DISPLAY_IN_SUMMARY_FLAG=DECODE(NOUPDATE_DSPLY_SMRY_FLG,0,iDisplayInSummaryFlag(j),DISPLAY_IN_SUMMARY_FLAG),
          IB_LINK_ITEM_FLAG=DECODE(NOUPDATE_IBLINKITEM_FLG,0,iIBLinkItemFlag(j),IB_LINK_ITEM_FLAG),
          INSTANTIABLE_FLAG=DECODE(NOUPDATE_INSTANTIABLE_FLAG,0,iINSTANTIABLEFLAG(j),INSTANTIABLE_FLAG),
          SHIPPABLE_ITEM_FLAG         = DECODE(NOUPDATE_SHIPPABLE_ITEM_FLAG,0,iShippableItemFlag(j), SHIPPABLE_ITEM_FLAG),
          INVENTORY_TRANSACTABLE_FLAG = DECODE(NOUPDATE_INV_TXN_FLAG, 0, iInventoryTransactableFlag(j), INVENTORY_TRANSACTABLE_FLAG),
          ASSEMBLE_TO_ORDER_FLAG      = DECODE(NOUPDATE_ASM_TO_ORDER_FLAG, 0, iAssembleToOrder(j), ASSEMBLE_TO_ORDER_FLAG),
          SERIALIZABLE_ITEM_FLAG      = DECODE(NOUPDATE_SERIAL_ITEM_FLAG, 0, iSerializableItemFlag(j), SERIALIZABLE_ITEM_FLAG)
          WHERE PS_NODE_ID=iPSNODEID(j);

            nUpdateCount:= nUpdateCount + 1;

            UPDATE CZ_IMP_PS_NODES  -- single row update
            SET REC_STATUS='OK'
            WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
            AND DISPOSITION='M';

            nCommitCount:=nCommitCount+1;
            /* COMMIT if the buffer size is reached */
            IF(nCommitCount>= COMMIT_SIZE) THEN
              COMMIT;
              nCommitCount:=0;
            END IF;

          EXCEPTION  -- single row update
            WHEN OTHERS THEN
                          FAILED:=FAILED +1;
                          UPDATE CZ_IMP_PS_NODES
                          SET REC_STATUS='ERR'
                          WHERE PS_NODE_ID=iPSNODEID(j) AND RUN_ID=inRUN_ID
                          AND DISPOSITION='M';

                          -- get model name
                           SELECT name INTO l_model_name
                           FROM cz_imp_devl_project
                           WHERE devl_project_id=p_model_id
                           AND deleted_flag='0'
                           AND run_id=inRun_ID
                           AND rec_status='OK'
                           AND rownum <2;

                          l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_XFR_NODE_M',
                                                   'MODELNAME', l_model_name,
                                                   'NODENAME', iName(j),
                                                   'NODEID', iPsNodeId(j),
                                                   'ERRORTEXT', SQLERRM);
                          x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
         END;         -- single row  update
        END LOOP;  -- single row loop
       END;      -- bulk update
      END IF;   -- IF count > 0
      END LOOP;  -- bulk fetch for update

      IF c_xfr_psnode%ISOPEN THEN
        CLOSE c_xfr_psnode;
      END IF;

  END update_ps_nodes;


  -- private procdure to delete PS nodes that are no longer present in the cz_imp_ps_nodes of this run id
  -- deletes the nodes logically and calls the cz_refs.delete_node logically to delete the expls
  -- for refs, connectors and non-virtual components

  PROCEDURE delete_ps_nodes(p_model_id IN NUMBER, x_retcode OUT NOCOPY NUMBER)
  IS
   l_ps_node_id   tPsNodeId;
   l_ps_node_type tPsNodeType;

   CURSOR C1 IS
   SELECT ps_node_id, ps_node_type
   FROM cz_ps_nodes a
   WHERE deleted_flag = '0'
   AND devl_project_id = p_model_id
   AND ps_node_type IN (cnReference, cnConnector, cnComponent)
   AND NOT EXISTS (SELECT NULL FROM cz_imp_ps_nodes
                   WHERE orig_sys_ref = a.orig_sys_ref
                   AND devl_project_id = p_model_id
                   AND src_application_id = a.src_application_id
                   AND run_id=inRun_Id);
  BEGIN
   x_retcode := 0;
   OPEN C1;
   FETCH C1 BULK COLLECT INTO l_ps_node_id,l_ps_node_type;
   CLOSE C1;

   UPDATE cz_ps_nodes a
   SET deleted_flag = '1'
   WHERE devl_project_id = p_model_id
   AND NOT EXISTS (SELECT NULL FROM cz_imp_ps_nodes
                   WHERE orig_sys_ref = a.orig_sys_ref
                   AND devl_project_id = p_model_id
                   AND src_application_id = a.src_application_id
                   AND run_id=inRun_Id);

   IF (l_ps_node_id.COUNT > 0) THEN
     FOR i IN l_ps_node_id.FIRST..l_ps_node_id.LAST LOOP
      cz_refs.delete_Node(l_ps_node_id(i),l_ps_node_type(i), p_out_err, '1');
      IF (p_out_err > 0) THEN
          l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_CZREFS_DELNODE',
                                   'MODELID', p_model_id,
                                   'NODEID', l_ps_node_id(i),
                                   'RUNID', p_out_err);
          x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
          x_retcode := 1;
      END IF;
     END LOOP;
   END IF;
  END delete_ps_nodes;

 BEGIN
        -- Get the Update Flags for each column
	NOUPDATE_PS_NODE_ID              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','PS_NODE_ID',inXFR_GROUP);
	NOUPDATE_DEVL_PROJECT_ID         := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','DEVL_PROJECT_ID',inXFR_GROUP);
	NOUPDATE_FROM_POPULATOR_ID	   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','FROM_POPULATOR_ID',inXFR_GROUP);
	NOUPDATE_PROPERTY_BACKPTR        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','PROPERTY_BACKPTR',inXFR_GROUP);
	NOUPDATE_ITEM_TYPE_BACKPTR	   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','ITEM_TYPE_BACKPTR',inXFR_GROUP);
	NOUPDATE_INTL_TEXT_ID		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','INTL_TEXT_ID',inXFR_GROUP);
	NOUPDATE_SUB_CONS_ID		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','SUB_CONS_ID',inXFR_GROUP);
	NOUPDATE_ITEM_ID                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','ITEM_ID',inXFR_GROUP);
	NOUPDATE_NAME			   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','NAME',inXFR_GROUP);
	NOUPDATE_RESOURCE_FLAG		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','RESOURCE_FLAG',inXFR_GROUP);
	NOUPDATE_INITIAL_VALUE		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','INITIAL_VALUE',inXFR_GROUP);
	NOUPDATE_initial_num_value	:= CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','initial_num_value',inXFR_GROUP);
	NOUPDATE_PARENT_ID               := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','PARENT_ID',inXFR_GROUP);
	NOUPDATE_MINIMUM		:= CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','MINIMUM',inXFR_GROUP);
	NOUPDATE_MAXIMUM		:= CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','MAXIMUM',inXFR_GROUP);
	NOUPDATE_PS_NODE_TYPE		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','PS_NODE_TYPE',inXFR_GROUP);
	NOUPDATE_FEATURE_TYPE		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','FEATURE_TYPE',inXFR_GROUP);
	NOUPDATE_PRODUCT_FLAG		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','PRODUCT_FLAG',inXFR_GROUP);
	NOUPDATE_REFERENCE_ID            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','REFERENCE_ID',inXFR_GROUP);
	NOUPDATE_MULTI_CONFIG_FLAG       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','MULTI_CONFIG_FLAG',inXFR_GROUP);
	NOUPDATE_ORDER_SEQ_FLAG          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','ORDER_SEQ_FLAG',inXFR_GROUP);
	NOUPDATE_SYSTEM_NODE_FLAG        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','SYSTEM_NODE_FLAG',inXFR_GROUP);
	NOUPDATE_TREE_SEQ      	         := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','TREE_SEQ',inXFR_GROUP);
	NOUPDATE_COUNTED_OPTIONS_FLAG	   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','COUNTED_OPTIONS_FLAG',inXFR_GROUP);
	NOUPDATE_UI_OMIT                 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','UI_OMIT',inXFR_GROUP);
	NOUPDATE_UI_SECTION		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','UI_SECTION',inXFR_GROUP);
	NOUPDATE_BOM_TREATMENT 		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','BOM_TREATMENT',inXFR_GROUP);
	NOUPDATE_ORIG_SYS_REF		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','ORIG_SYS_REF',inXFR_GROUP);
	NOUPDATE_CHECKOUT_USER		   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','CHECKOUT_USER',inXFR_GROUP);
	NOUPDATE_DELETED_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','DELETED_FLAG',inXFR_GROUP);
	NOUPDATE_EFF_FROM                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','EFFECTIVE_FROM',inXFR_GROUP);
	NOUPDATE_EFF_TO                  := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','EFFECTIVE_UNTIL',inXFR_GROUP);
	NOUPDATE_EFF_MASK                := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','EFFECTIVE_USAGE_MASK',inXFR_GROUP);
	NOUPDATE_USER_STR01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_STR01',inXFR_GROUP);
	NOUPDATE_USER_STR02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_STR02',inXFR_GROUP);
	NOUPDATE_USER_STR03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_STR03',inXFR_GROUP);
	NOUPDATE_USER_STR04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_STR04',inXFR_GROUP);
	NOUPDATE_USER_NUM01              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_NUM01',inXFR_GROUP);
	NOUPDATE_USER_NUM02              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_NUM02',inXFR_GROUP);
	NOUPDATE_USER_NUM03              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_NUM03',inXFR_GROUP);
	NOUPDATE_USER_NUM04              := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','USER_NUM04',inXFR_GROUP);
	NOUPDATE_CREATION_DATE           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','CREATION_DATE',inXFR_GROUP);
	NOUPDATE_LAST_UPDATE_DATE        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','LAST_UPDATE_DATE',inXFR_GROUP);
	NOUPDATE_CREATED_BY          	 := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','CREATED_BY',inXFR_GROUP);
	NOUPDATE_LAST_UPDATED_BY         := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','LAST_UPDATED_BY',inXFR_GROUP);
	NOUPDATE_SECURITY_MASK           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','SECURITY_MASK',inXFR_GROUP);
        NOUPDATE_SO_ITEM_TYPE_CODE       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','SO_ITEM_TYPE_CODE',inXFR_GROUP);
        NOUPDATE_MINIMUM_SELECTED        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','MINIMUM_SELECTED',inXFR_GROUP);
        NOUPDATE_MAXIMUM_SELECTED        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','MAXIMUM_SELECTED',inXFR_GROUP);
        NOUPDATE_BOM_REQUIRED            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','BOM_REQUIRED_FLAG',inXFR_GROUP);
        NOUPDATE_COMPONENT_SEQUENCE_ID   := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','COMPONENT_SEQUENCE_ID',inXFR_GROUP);
        NOUPDATE_DECIMAL_QTY_FLAG        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','DECIMAL_QTY_FLAG',inXFR_GROUP);
        NOUPDATE_QUOTEABLE_FLAG          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','QUOTEABLE_FLAG',inXFR_GROUP);
        NOUPDATE_PRIMARY_UOM_CODE        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','PRIMARY_UOM_CODE',inXFR_GROUP);
        NOUPDATE_BOM_SORT_ORDER          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','BOM_SORT_ORDER',inXFR_GROUP);
        NOUPDATE_SEQUENCE_PATH           := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','COMPONENT_SEQUENCE_PATH',inXFR_GROUP);
        NOUPDATE_IB_TRACKABLE            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','IB_TRACKABLE',inXFR_GROUP);
        NOUPDATE_DSPLY_SMRY_FLG          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','DISPLAY_IN_SUMMARY_FLAG',inXFR_GROUP);
        NOUPDATE_IBLINKITEM_FLG          := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','IB_LINK_ITEM_FLAG',inXFR_GROUP);
        NOUPDATE_INSTANTIABLE_FLAG       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','INSTANTIABLE_FLAG',inXFR_GROUP);

        --Updates of instantiable_flag are always prohibited for BOM import.

        IF(inXFR_GROUP = 'IMPORT')THEN NOUPDATE_INSTANTIABLE_FLAG := 1; END IF;

        NOUPDATE_SHIPPABLE_ITEM_FLAG     := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','SHIPPABLE_ITEM_FLAG',inXFR_GROUP);
        NOUPDATE_INV_TXN_FLAG            := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','INVENTORY_TRANSACTABLE_FLAG',inXFR_GROUP);
        NOUPDATE_ASM_TO_ORDER_FLAG       := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','ASSEMBLE_TO_ORDER_FLAG ',inXFR_GROUP);
        NOUPDATE_SERIAL_ITEM_FLAG        := CZ_UTILS.GET_NOUPDATE_FLAG('CZ_PS_NODES','SERIALIZABLE_ITEM_FLAG',inXFR_GROUP);

  OPEN C1;
  FETCH C1 BULK COLLECT INTO
  l_c1_plan_level_tbl,l_c1_prj_id_tbl,l_c1_node_id_tbl, l_c1_dis_tbl,l_c1_ref_model_id_tbl,
  l_c1_nodetype_tbl,l_c1_min_tbl,l_c1_max_tbl,l_c1_rec_status_tbl,l_c1_name_tbl,l_c1_model_type;
  CLOSE C1;

  OPEN C2;
  FETCH C2 BULK COLLECT INTO
  l_c2_plan_level_tbl,l_c2_prj_id_tbl,l_c2_node_id_tbl,l_c2_dis_tbl,l_c2_ref_model_id_tbl,
  l_c2_nodetype_tbl,l_c2_min_tbl,l_c2_max_tbl,l_c2_rec_status_tbl,l_c2_name_tbl,l_c2_model_type;
  CLOSE C2;

  OPEN C3;
  FETCH c3 BULK COLLECT INTO
  l_c3_plan_level_tbl,l_c3_prj_id_tbl,l_c3_node_id_tbl,l_c3_dis_tbl,l_c3_ref_id_tbl,
  l_c3_nodetype_tbl,l_c3_min_tbl,l_c3_max_tbl,l_c3_rec_status_tbl,l_c3_model_type;
  CLOSE C3;

  -- Bugfix 9446997
  -- Requirement to reset an array (of reference models) before making check_node call
  -- which will drive update_node_depth call
  cz_refs.reset_model_array;


  IF (l_c1_prj_id_tbl.COUNT = 0)  THEN
    GOTO PROCESS_C2;
  END IF;
  -- processing C1: models referenced but have no refs

  -- if a new model fails to insert, it is marked 'ERR' and
  -- any referencing models in C2 and C3 will be marked 'SKP'

  FOR i IN l_c1_prj_id_tbl.FIRST..l_c1_prj_id_tbl.LAST LOOP

        l_retcode := 0;
        p_out_err := 0;

        -- process any ps nodes with disposition of insert

        IF l_c1_prj_id_tbl(i) <> l_last_model_id THEN
           insert_ps_nodes(l_c1_prj_id_tbl(i), l_retcode);
        END IF;

        IF l_retcode = 1 THEN

           l_c1_rec_status_tbl(i):='ERR';

           -- also set rec_status for for any references this model in C2 and C3

           IF l_c2_prj_id_tbl.COUNT > 0 THEN
             -- also set rec_status for for any nodes referencing this model
             FOR j IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP
               IF l_c2_prj_id_tbl(j) = l_c1_ref_model_id_tbl(i) THEN
                  l_c2_rec_status_tbl(j):='SKP';
               END IF;
             END LOOP;
           END IF;

           IF l_c3_prj_id_tbl.COUNT > 0 THEN
             FOR j IN l_c3_prj_id_tbl.FIRST..l_c3_prj_id_tbl.LAST LOOP
                IF l_c3_prj_id_tbl(j)=l_c1_ref_model_id_tbl(i) THEN
                  l_c3_rec_status_tbl(j):='SKP';
               END IF;
             END LOOP;
           END IF;

        ELSE

             -- process any ps nodes with disposition of update for this model

             IF l_c1_prj_id_tbl(i) <> l_last_model_id THEN

                update_ps_nodes(l_c1_prj_id_tbl(i));

                -- call cz_refs.check_node for ROOT only, for now

                IF l_c1_prj_id_tbl(i)=l_c1_node_id_tbl(i) THEN

                    cz_refs.check_Node(l_c1_prj_id_tbl(i),
                                       l_c1_node_id_tbl(i),
                                       l_c1_max_tbl(i),
                                       l_c1_min_tbl(i),
                                       NULL,
                                       p_out_err,
                                       p_out_virtual_flag,
                                       '0',
                                       null,
                                       l_c1_nodetype_tbl(i),
                                       NULL, '1');
                END IF;

                IF (p_out_err > 0) THEN

                    l_c1_rec_status_tbl(i):='ERR';

                    IF l_c2_prj_id_tbl.COUNT > 0 THEN
                      -- also set rec_status for for any nodes referencing this model
                      FOR j IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP
                        IF l_c2_prj_id_tbl(j)=l_c1_ref_model_id_tbl(i) THEN
                          l_c2_rec_status_tbl(j):='SKP';
                        END IF;
                      END LOOP;
                    END IF;

                    IF l_c3_ref_id_tbl.COUNT > 0 THEN
                      FOR j IN l_c3_prj_id_tbl.FIRST..l_c3_prj_id_tbl.LAST LOOP
                        IF l_c3_prj_id_tbl(j)=l_c1_ref_model_id_tbl(i) THEN
                          l_c3_rec_status_tbl(j):='SKP';
                       END IF;
                      END LOOP;
                    END IF;

                    l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_ROOT_CHECKNODE',
                                             'MODELID', l_c1_prj_id_tbl(i),
                                             'PSNODEID', l_c1_node_id_tbl(i),
                                             'REFID', NULL);
                    x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);

                ELSE
                 -- Nodes not in this run id are assumed deleted - non-BOM models only
                    IF l_c1_model_type(i) NOT IN ('A','P','N') THEN
                      l_retcode := 0;
                      delete_ps_nodes(l_c1_prj_id_tbl(i),l_retcode);
                      IF (l_retcode = 1) THEN
                         l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_RB_DELNODE', 'MODELID', l_c1_prj_id_tbl(i));
                         x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                         l_c1_rec_status_tbl(i):='ERR';
                         ROLLBACK;
                      END IF;
                    END IF;
                    IF (l_retcode = 0) THEN
                      l_c1_rec_status_tbl(i):='OK';
                      COMMIT;
                          -- get model name
                           SELECT name INTO l_model_name
                           FROM cz_imp_devl_project
                           WHERE devl_project_id=l_c1_prj_id_tbl(i)
                           AND deleted_flag='0'
                           AND run_id=inRun_ID
                           AND rec_status='OK'
                           AND rownum <2;

                      l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_MODEL_IMPORTED',
                                               'MODELNAME', l_model_name,
                                               'MODELID', l_c1_prj_id_tbl(i));
                      x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                    END IF;
                END IF;  -- if p_out_err
             END IF;  -- last
        END IF;  -- if retcode

        l_last_model_id := l_c1_prj_id_tbl(i);

    END LOOP;  -- c1 models

<<PROCESS_C2>>

  -- process C2

  -- before processing PS nodes, check the status of each model in C2 and if not to be processed (SKP or ERR)
  -- then mark the models referencing it in both C2 and C3 to SKP

  IF (l_c2_prj_id_tbl.COUNT = 0)  THEN
    GOTO PROCESS_C3;
  END IF;

  FOR i IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP

    l_retcode := 0;
    p_out_err := 0;

    IF l_c2_rec_status_tbl(i) IN ('ERR','SKP') THEN

        FOR j IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP
          IF l_c2_prj_id_tbl(j)=l_c2_ref_model_id_tbl(i) THEN
             l_c2_rec_status_tbl(j):= 'SKP';
          END IF;
        END LOOP;

        IF l_c3_prj_id_tbl.COUNT > 0 THEN
          FOR j IN l_c3_prj_id_tbl.FIRST..l_c3_prj_id_tbl.LAST LOOP
             IF l_c3_prj_id_tbl(j)=l_c2_ref_model_id_tbl(i) THEN
                l_c3_rec_status_tbl(j):='SKP';
             END IF;
          END LOOP;
        END IF;

    ELSE

        -- to be processed, so process the insert it not already done so

        IF l_c2_prj_id_tbl(i) <> l_last_model_id  THEN
          l_retcode:=0;
          insert_ps_nodes(l_c2_prj_id_tbl(i), l_retcode);
        END IF;

        -- if this C2 model errored out then update status of this model to 'ERR' and search
        -- for any references to this model in C2 and C3 and set the status of those to 'SKP'

        IF l_retcode = 1 THEN

           l_c2_rec_status_tbl(i):='ERR';

           FOR j IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP
              IF l_c2_prj_id_tbl(j)=l_c2_prj_id_tbl(i) THEN
                 l_c2_rec_status_tbl(j):='ERR';
              END IF;
           END LOOP;

           IF l_c3_prj_id_tbl.COUNT > 0 THEN
             FOR j IN l_c3_ref_id_tbl.FIRST..l_c3_ref_id_tbl.LAST LOOP
                IF l_c3_ref_id_tbl(j)=l_c2_prj_id_tbl(i) THEN
                   l_c3_rec_status_tbl(j):='SKP';
                END IF;
             END LOOP;
           END IF;

        ELSE

          -- process the PS nodes with disposition of update, if already not done so

          IF l_c2_prj_id_tbl(i) <> l_last_model_id THEN

             update_ps_nodes(l_c2_prj_id_tbl(i));

             -- call check_node for ROOT node only

                  IF l_c2_prj_id_tbl(i)=l_c2_node_id_tbl(i) THEN

                     cz_refs.check_Node(l_c2_prj_id_tbl(i),
                                        l_c2_node_id_tbl(i),
                                        l_c2_max_tbl(i),
                                        l_c2_min_tbl(i),
                                        NULL,
                                        p_out_err,
                                        p_out_virtual_flag,
                                        '0',
                                        null,
                                        l_c2_nodetype_tbl(i),
                                        NULL, '1');
                  END IF;

              IF (p_out_err > 0) THEN

                   l_c2_rec_status_tbl(i):='ERR';

                   FOR j IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP
                     IF l_c2_prj_id_tbl(j)=l_c2_prj_id_tbl(i) THEN
                       l_c2_rec_status_tbl(j):='ERR';
                     END IF;
                   END LOOP;

                   IF l_c3_prj_id_tbl.COUNT > 0 THEN
                     FOR j IN l_c3_ref_id_tbl.FIRST..l_c3_ref_id_tbl.LAST LOOP
                       IF l_c3_ref_id_tbl(j)=l_c2_prj_id_tbl(i) THEN
                         l_c3_rec_status_tbl(j):='SKP';
                       END IF;
                     END LOOP;
                   END IF;

                 l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_ROOT_CHECKNODE',
                                          'MODELID', l_c2_prj_id_tbl(i),
                                          'PSNODEID', l_c2_node_id_tbl(i),
                                          'REFID', NULL);
                 x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
              ELSE
                 -- Nodes not in this run id are assumed deleted - non-BOM models only
                 IF l_c2_model_type(i) NOT IN ('A','P','N') THEN
                    l_retcode := 0;
                    delete_ps_nodes(l_c2_prj_id_tbl(i),l_retcode);
                    IF (l_retcode = 1) THEN
                       l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_RB_DELNODE', 'MODELID', l_c2_prj_id_tbl(i));
                       x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                       l_c2_rec_status_tbl(i):='ERR';
                       ROLLBACK;
                    END IF;
                 END IF;
                 IF (l_retcode = 0) THEN
                   l_c2_rec_status_tbl(i):='OK';
                   COMMIT;
                           SELECT name INTO l_model_name
                           FROM cz_imp_devl_project
                           WHERE devl_project_id=l_c2_prj_id_tbl(i)
                           AND deleted_flag='0'
                           AND run_id=inRun_ID
                           AND rec_status='OK'
                           AND rownum <2;
                   l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_MODEL_IMPORTED',
                                            'MODELNAME', l_model_name,
                                            'MODELID', l_c2_prj_id_tbl(i));
                   x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                 END IF;
              END IF;  -- if p_out_err
          END IF; -- last
        END IF;  -- if retcode

    END IF; -- if rec status

    l_last_model_id := l_c2_prj_id_tbl(i);

   END LOOP;  -- c2 models

<<PROCESS_C3>>

  IF (l_c3_prj_id_tbl.COUNT = 0)  THEN
    GOTO UPDATE_IMP_TABLE;
  END IF;

  -- Process C3 models

  -- The models here are not referenced, the PS nodes will be processed, and if root node fails to insert
  -- the model will be set to 'ERR'
  -- But before processing the PS nodes, chekc the status of each model here and if it is 'SKP' then
  -- do not process

  FOR i IN l_c3_prj_id_tbl.FIRST..l_c3_prj_id_tbl.LAST LOOP

     l_retcode := 0;
     p_out_err := 0;

     -- porcess if not 'ERR' or 'SKP'

     IF l_c3_rec_status_tbl(i) NOT IN ('ERR','SKP')  THEN

        -- process PS nodes with disposition of insert if haven't already done so
        IF l_c3_prj_id_tbl(i) <> l_last_model_id THEN
           insert_ps_nodes(l_c3_prj_id_tbl(i), l_retcode);
        END IF;

        IF l_retcode = 1 THEN
           l_c3_rec_status_tbl(i):='ERR';
        ELSE

           IF l_c3_prj_id_tbl(i) <> l_last_model_id THEN

               -- process PS nodes with disposition of update if haven't already done so

                  update_ps_nodes(l_c3_prj_id_tbl(i));

               -- call check_node for ROOT only, for now
                  IF l_c3_prj_id_tbl(i)=l_c3_node_id_tbl(i) THEN

                     cz_refs.check_Node(l_c3_prj_id_tbl(i),
                                        l_c3_node_id_tbl(i),
                                        l_c3_max_tbl(i),
                                        l_c3_min_tbl(i),
                                        NULL,
                                        p_out_err,
                                        p_out_virtual_flag,
                                        '0',
                                        null,
                                        l_c3_nodetype_tbl(i),
                                        NULL, '1');
                   END IF;

               IF (p_out_err > 0) THEN

                  l_c3_rec_status_tbl(i):='ERR';
                  l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_ROOT_CHECKNODE',
                                           'MODELID', l_c3_prj_id_tbl(i),
                                           'PSNODEID', l_c3_node_id_tbl(i),
                                           'REFID', NULL);
                   x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);

               ELSE
                 -- Nodes not in this run id are assumed deleted - non-BOM models only
                 IF l_c3_model_type(i) NOT IN ('A','P','N') THEN
                    l_retcode := 0;
                    delete_ps_nodes(l_c3_prj_id_tbl(i),l_retcode);
                    IF (l_retcode = 1) THEN
                       l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_RB_DELNODE', 'MODELID', l_c3_prj_id_tbl(i));
                       x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                       l_c3_rec_status_tbl(i):='ERR';
                       ROLLBACK;
                    END IF;
                 END IF;
                 IF (l_retcode = 0) THEN
                   l_c3_rec_status_tbl(i):='OK';
                   COMMIT;
                           SELECT name INTO l_model_name
                           FROM cz_imp_devl_project
                           WHERE devl_project_id=l_c3_prj_id_tbl(i)
                           AND deleted_flag='0'
                           AND run_id=inRun_ID
                           AND rec_status='OK'
                           AND rownum <2;
                   l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_MODEL_IMPORTED',
                                            'MODELNAME', l_model_name,
                                            'MODELID', l_c3_prj_id_tbl(i));
                   x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                 END IF;
               END IF;  -- if p_out_err
           END IF; -- last
        END IF;  -- if retcode
     END IF; -- if rec status

     l_last_model_id := l_c3_prj_id_tbl(i);

  END LOOP;  -- c3 models

<<UPDATE_IMP_TABLE>>

   -- Now update the imp tables for failed models of C1

   IF l_c1_prj_id_tbl.COUNT > 0 THEN
     FOR i IN l_c1_prj_id_tbl.FIRST..l_c1_prj_id_tbl.LAST LOOP
       IF l_c1_rec_status_tbl(i)='ERR' THEN

                UPDATE CZ_IMP_PS_NODES
                SET REC_STATUS='ERR'
                WHERE DEVL_PROJECT_ID=l_c1_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID;

                UPDATE CZ_IMP_DEVL_PROJECT
                SET REC_STATUS='ERR'
                WHERE DEVL_PROJECT_ID=l_c1_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID
                AND DISPOSITION=l_c1_dis_tbl(i);

                --  delete if failed model was a new model

                IF l_c1_dis_tbl(i) = 'I' THEN
                  DELETE FROM cz_devl_projects
                  WHERE devl_project_id = l_c1_prj_id_tbl(i);
                  DELETE FROM cz_rp_entries
                  WHERE object_id = l_c1_prj_id_tbl(i)
                  AND object_type = 'PRJ';
                END IF;
       END IF;
     END LOOP;
   END IF;

   -- Now update the imp tables for failed or skipped  models of C2

   IF l_c2_prj_id_tbl.COUNT > 0 THEN
     FOR i IN l_c2_prj_id_tbl.FIRST..l_c2_prj_id_tbl.LAST LOOP
       IF l_c2_rec_status_tbl(i) IN ('SKP','ERR') THEN

                UPDATE CZ_IMP_PS_NODES
                SET REC_STATUS=DECODE(l_c2_rec_status_tbl(i),'SKP','PASS',l_c2_rec_status_tbl(i))
                WHERE DEVL_PROJECT_ID=l_c2_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID;

                UPDATE CZ_IMP_DEVL_PROJECT
                SET REC_STATUS=DECODE(l_c2_rec_status_tbl(i),'SKP','PASS',l_c2_rec_status_tbl(i))
                WHERE DEVL_PROJECT_ID=l_c2_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID
                AND DISPOSITION=l_c2_dis_tbl(i);

                --  delete if failed model was a new model

                IF l_c2_dis_tbl(i) = 'I' THEN
                  DELETE FROM cz_devl_projects
                  WHERE devl_project_id = l_c2_prj_id_tbl(i);
                  DELETE FROM cz_rp_entries
                  WHERE object_id = l_c2_prj_id_tbl(i)
                  AND object_type = 'PRJ';
                END IF;
       END IF;
     END LOOP;
   END IF;

   -- Now update the imp tables for failed or skipped  models of C3

   IF l_c3_prj_id_tbl.COUNT > 0 THEN
     FOR i IN l_c3_prj_id_tbl.FIRST..l_c3_prj_id_tbl.LAST LOOP
       IF l_c3_rec_status_tbl(i) IN ('SKP','ERR') THEN

                UPDATE CZ_IMP_PS_NODES
                SET REC_STATUS=DECODE(l_c3_rec_status_tbl(i),'SKP','PASS',l_c3_rec_status_tbl(i))
                WHERE DEVL_PROJECT_ID=l_c3_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID;

                UPDATE CZ_IMP_DEVL_PROJECT
                SET REC_STATUS=DECODE(l_C3_rec_status_tbl(i),'SKP','PASS',l_c3_rec_status_tbl(i))
                WHERE DEVL_PROJECT_ID=l_c3_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID
                AND DISPOSITION=l_c3_dis_tbl(i);

                --  delete if failed model was a new model

                IF l_c3_dis_tbl(i) = 'I' THEN
                  DELETE FROM cz_devl_projects
                  WHERE devl_project_id = l_c3_prj_id_tbl(i);
                  DELETE FROM cz_rp_entries
                  WHERE object_id = l_c3_prj_id_tbl(i)
                  AND object_type = 'PRJ';
                END IF;
       END IF;
     END LOOP;
   END IF;

  -- Process C4 models - models with no refs and not referenced

  OPEN C4;
  FETCH C4 BULK COLLECT INTO
  l_c4_plan_level_tbl,l_c4_prj_id_tbl,l_c4_node_id_tbl,l_c4_dis_tbl,
  l_c4_nodetype_tbl,l_c4_min_tbl,l_c4_max_tbl,l_c4_rec_status_tbl,l_c4_model_type;
  CLOSE C4;

  IF (l_c4_prj_id_tbl.COUNT = 0)  THEN
    GOTO PROCESS_REFS;
  END IF;

  FOR i IN l_c4_prj_id_tbl.FIRST..l_c4_prj_id_tbl.LAST LOOP

         l_retcode := 0;
         p_out_err := 0;

         -- process PS nodes with disposition of insert

         insert_ps_nodes(l_c4_prj_id_tbl(i), l_retcode);

         IF l_retcode = 1 THEN
            l_c4_rec_status_tbl(i):='ERR';
         ELSE

             -- process PS nodes with disposition of update
             update_ps_nodes(l_c4_prj_id_tbl(i));

             -- call check node for ROOT node for now
                 IF l_c4_prj_id_tbl(i)=l_c4_node_id_tbl(i) THEN

                  cz_refs.check_Node(l_c4_prj_id_tbl(i),
                                      l_c4_node_id_tbl(i),
                                      l_c4_max_tbl(i),
                                      l_c4_min_tbl(i),
                                      NULL,
                                      p_out_err,
                                      p_out_virtual_flag,
                                      '0',
                                      null,
                                      l_c4_nodetype_tbl(i),
                                      NULL, '1');
                 END IF;

             IF (p_out_err > 0) THEN

                l_c4_rec_status_tbl(i):='ERR';
                l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_ROOT_CHECKNODE',
                                         'MODELID', l_c4_prj_id_tbl(i),
                                         'PSNODEID', l_c4_node_id_tbl(i),
                                         'REFID', NULL);
                 x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
             ELSE
                 -- Nodes not in this run id are assumed deleted - non-BOM models only
                 IF l_c4_model_type(i) NOT IN ('A','P','N') THEN
                    l_retcode := 0;
                    delete_ps_nodes(l_c4_prj_id_tbl(i),l_retcode);
                    IF (l_retcode = 1) THEN
                       l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_RB_DELNODE', 'MODELID', l_c4_prj_id_tbl(i));
                       x_error:=CZ_UTILS.LOG_REPORT(l_msg ,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                       l_c4_rec_status_tbl(i):='ERR';
                       ROLLBACK;
                    END IF;
                 END IF;
                 IF (l_retcode = 0) THEN
                   l_c4_rec_status_tbl(i):='OK';
                   COMMIT;
                           SELECT name INTO l_model_name
                           FROM cz_imp_devl_project
                           WHERE devl_project_id=l_c4_prj_id_tbl(i)
                           AND deleted_flag='0'
                           AND run_id=inRun_ID
                           AND rec_status='OK'
                           AND rownum <2;
                   l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_MODEL_IMPORTED',
                                            'MODELNAME', l_model_name,
                                            'MODELID', l_c4_prj_id_tbl(i));
                   x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
                 END IF;
             END IF;  -- p_out_err
      END IF; -- if retcode ..
    END LOOP;  -- c4 models

   -- Now update the imp tables for failed models of C4

   IF l_c4_prj_id_tbl.COUNT > 0 THEN
     FOR i IN l_c4_prj_id_tbl.FIRST..l_c4_prj_id_tbl.LAST LOOP
       IF l_c4_rec_status_tbl(i)='ERR' THEN

                UPDATE CZ_IMP_PS_NODES
                SET REC_STATUS='ERR'
                WHERE DEVL_PROJECT_ID=l_c4_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID;

                UPDATE CZ_IMP_DEVL_PROJECT
                SET REC_STATUS='PASS'
                WHERE DEVL_PROJECT_ID=l_c4_prj_id_tbl(i)
                AND RUN_ID=inRUN_ID
                AND DISPOSITION=l_c4_dis_tbl(i);

                --  delete if failed model was a new model

                IF l_c4_dis_tbl(i) = 'I' THEN
                  DELETE FROM cz_devl_projects
                  WHERE devl_project_id = l_c4_prj_id_tbl(i);
                  DELETE FROM cz_rp_entries
                  WHERE object_id = l_c4_prj_id_tbl(i)
                  AND object_type = 'PRJ';
                END IF;
       END IF;
     END LOOP;
   END IF;

<<PROCESS_REFS>>
---------------------------------------------------------------------------------------------------------------
  --  DONE transferring PS nodes for all models in this run id -- call check nodes for refs and components only
---------------------------------------------------------------------------------------------------------------
  OPEN l_model_refs_csr;
  FETCH l_model_refs_csr BULK COLLECT INTO
  l_PlanLevel,l_PsNodeId,l_DevlProjectId,l_ReferenceId,
  l_minimum,l_maximum,l_PsNodeType,l_ParentId,l_dis;
  CLOSE l_model_refs_csr;

  IF l_PsNodeId.COUNT > 0 THEN

     FOR i IN l_PsNodeId.FIRST..l_PsNodeId.LAST LOOP

               p_out_err := 0;

               cz_refs.check_Node(l_PsNodeId(i),
                                  l_DevlProjectId(i),
                                  l_Maximum(i),
                                  l_Minimum(i),
                                  l_ReferenceId(i),
                                  p_out_err,
                                  p_out_virtual_flag,
                                  '0',
                                  null,
                                  l_PsNodeType(i),
                                  NULL, '1');

               IF (p_out_err > 0) THEN
                   FAILED:=FAILED +1;
                   UPDATE CZ_IMP_PS_NODES
                   SET REC_STATUS='ERR'
                   WHERE PS_NODE_ID=l_PsNodeId(i)
                   AND RUN_ID=inRUN_ID
                   AND DISPOSITION=l_dis(i);

                   SELECT name INTO l_model_name
                   FROM cz_imp_devl_project
                   WHERE devl_project_id=l_DevlProjectId(i)
                   AND deleted_flag='0'
                   AND run_id=inRun_ID
                   AND rec_status='OK'
                   AND rownum <2;
                 l_msg:=CZ_UTILS.GET_TEXT('CZ_IMP_CHECKNODE',
                                          'MODELID', l_DevlProjectId(i),
                                          'PSNODEID', l_PsNodeId(i),
                                          'REFID', l_ReferenceId(i));
                   x_error:=CZ_UTILS.LOG_REPORT(l_msg,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
               END IF;
     END LOOP;
  END IF;


  -- Bugfix 9446997
  -- Call update_node_depth explicitly due to it's removal from check_node procedure
  cz_refs.update_node_depth(NULL) ;

--Fix for the bug #3040079. We need to call a new cz_refs procedure for every model we inserted.
    FOR c_model IN (SELECT devl_project_id FROM cz_imp_devl_project
                    WHERE run_id = inRUN_ID
                    AND rec_status = 'OK')LOOP
               cz_refs.populate_component_id(c_model.devl_project_id);
    END LOOP;

    COMMIT;
    INSERTS:=nInsertCount;
    UPDATES:=nUpdateCount;
EXCEPTION
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   IF c_xfr_psnode%ISOPEN THEN close c_xfr_psnode; END IF;
   RAISE;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
  WHEN OTHERS THEN
   IF c_xfr_psnode%ISOPEN THEN close c_xfr_psnode; END IF;
   x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'IMP_IM_XFR.XFR_PS_NODE',11276,inRun_Id);
END XFR_PS_NODE;

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
  PROCEDURE RPT_PS_NODE ( inRUN_ID IN PLS_INTEGER ) AS
                          x_error     BOOLEAN:=FALSE;

    v_table_name  VARCHAR2(30) := 'CZ_PS_NODES';
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
                                  FROM CZ_IMP_PS_NODES
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

                     INSERT INTO CZ_XFR_RUN_RESULTS (RUN_ID,IMP_TABLE,DISPOSITION,REC_STATUS,RECORDS)
                     VALUES(inRUN_ID,v_table_name,ins_disposition,ins_rec_status,ins_rec_count);

                  END LOOP;
                  CLOSE c_xfr_run_result;
                  COMMIT;

                  EXCEPTION
                   WHEN OTHERS THEN
                     x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_PS_NODE',11276,inRun_Id);
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
                  x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_PS_NODE',11276,inRun_Id);
              END;
       EXCEPTION
        WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
          RAISE;
        WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
          RAISE;
        WHEN OTHERS THEN
          x_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'CZ_IMP_PS_NODE.RPT_PS_NODE',11276,inRun_Id);
  END;
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/*--PS_NODE IMPORT SECTION END----------------------------------------------*/
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
END CZ_IMP_PS_NODE;

/
