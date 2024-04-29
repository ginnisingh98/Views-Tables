--------------------------------------------------------
--  DDL for Package Body ZPB_SOLVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_SOLVE" AS
/* $Header: zpbsolve.plb 120.14 2007/12/05 12:51:14 mbhat ship $ */

/*****************************************************************
  *                 PROPAGATE INPUT SELECTIONS                   *
  *                                                              *
  *                                                              *
  *                                                              *
  ****************************************************************/
PROCEDURE propagateInput(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                         p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE)

IS
fromSource    NUMBER;
ipRec     ZPB_SOLVE_INPUT_SELECTIONS%ROWTYPE;
isSetSrcPropFlag boolean := FALSE;

CURSOR c1 IS
        SELECT * FROM ZPB_SOLVE_INPUT_SELECTIONS
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
  BEGIN
    SELECT SOURCE_TYPE INTO fromSource
    FROM ZPB_SOLVE_MEMBER_DEFS
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

   IF(fromSource <> CALCULATED_SOURCE AND fromSource <> AGGREGATED_SOURCE) THEN
             FOR i IN propagateList.FIRST..propagateList.LAST
             LOOP
                  IF(propagateSourceType(i) = WS_INPUT_SOURCE OR propagateSourceType(i) = INIT_WS_INPUT_SOURCE OR
             (propagateSourceType(i) = LOADED_SOURCE AND fromSource = LOADED_SOURCE))THEN
              isSetSrcPropFlag  := TRUE;
                    --delete all i/p selections if target's source type is =INPUT
                    -- For CASES:C1-a,C1-b,C2-b
              DELETE FROM ZPB_SOLVE_INPUT_SELECTIONS
                  WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(i);
            --insert
                   ELSE
                               isSetSrcPropFlag  := TRUE;
                  DELETE ZPB_SOLVE_INPUT_SELECTIONS
                  where member =  propagateList(i)
                  and analysis_cycle_id = p_ac_id
                  and dimension in ( select dimension from zpb_solve_input_selections
                                    where member =  p_from_member
                                    and analysis_cycle_id = p_ac_id);

           END IF;
          INSERT INTO ZPB_SOLVE_INPUT_SELECTIONS
                    (ANALYSIS_CYCLE_ID,
                     MEMBER,
                     MEMBER_ORDER,
                     DIMENSION,
                     HIERARCHY,
                     SELECTION_NAME,
                     SELECTION_PATH,
                     PROPAGATED_FLAG,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATE_LOGIN)
                 SELECT ANALYSIS_CYCLE_ID,
                     propagateList(i),
                     propagateOrder(i),
                     DIMENSION,
                     HIERARCHY,
                     SELECTION_NAME,
                     SELECTION_PATH,
                     'Y',
                     fnd_global.USER_ID,
                     SYSDATE,
                     fnd_global.USER_ID,
                     SYSDATE,
                     fnd_global.LOGIN_ID
                  FROM ZPB_SOLVE_INPUT_SELECTIONS
                  WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

                 END LOOP;
        END IF;

        --Update PROPAGATED_FLAG of source member.
        IF isSetSrcPropFlag = TRUE THEN

        UPDATE ZPB_SOLVE_INPUT_SELECTIONS
        SET PROPAGATED_FLAG ='Y'
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
    END IF;

        EXCEPTION
        WHEN OTHERS THEN
    IF c1%ISOPEN THEN
                CLOSE c1;
        END IF;
        ROLLBACK;

  END propagateInput;




  /****************************************************************
  *                 COPY DIMENSION HANDLING INFO                  *
  *                                                               *
  *                                                               *
  *****************************************************************/
  PROCEDURE copyDimHandlingInfo(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                                p_to_index IN INTEGER,
                                p_dimensionality_flag IN VARCHAR2 DEFAULT 'NO')
  IS

   dimRec               ZPB_LINE_DIMENSIONALITY%ROWTYPE;

   CURSOR c1 IS
                SELECT * FROM ZPB_LINE_DIMENSIONALITY
               WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
  BEGIN
    --Update PROPAGATED_FLAG of source member.
    UPDATE ZPB_LINE_DIMENSIONALITY
    SET PROPAGATED_FLAG ='Y'
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
        --Copy dim handling info.
        FOR dimRec IN c1
    LOOP
        IF p_dimensionality_flag  = 'RECREATE' THEN

                DELETE FROM ZPB_LINE_DIMENSIONALITY
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(p_to_index);

                INSERT INTO ZPB_LINE_DIMENSIONALITY
                   (ANALYSIS_CYCLE_ID,
                   MEMBER,
                   MEMBER_ORDER,
                   DIMENSION,
                   SUM_MEMBERS_NUMBER,
                   SUM_MEMBERS_FLAG ,
                   EXCLUDE_FROM_SOLVE_FLAG,
                   FORCE_INPUT_FLAG,
                   SUM_SELECTION_NAME,
                   SUM_SELECTION_PATH,
                   PROPAGATED_FLAG,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN)
                SELECT
                   ANALYSIS_CYCLE_ID,
                   propagateList(p_to_index),
                   propagateOrder(p_to_index),
                   DIMENSION,
                   SUM_MEMBERS_NUMBER,
                   SUM_MEMBERS_FLAG ,
                   EXCLUDE_FROM_SOLVE_FLAG,
                   FORCE_INPUT_FLAG,
                   SUM_SELECTION_NAME,
                   SUM_SELECTION_PATH,
                   'Y',
                   fnd_global.USER_ID,
                   SYSDATE,
                   fnd_global.USER_ID,
                   SYSDATE,
                   fnd_global.LOGIN_ID
                FROM ZPB_LINE_DIMENSIONALITY
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

        ELSE
            UPDATE ZPB_LINE_DIMENSIONALITY
                        SET SUM_MEMBERS_NUMBER          =       dimRec.SUM_MEMBERS_NUMBER,
                                SUM_MEMBERS_FLAG        =       dimRec.SUM_MEMBERS_FLAG,
                                EXCLUDE_FROM_SOLVE_FLAG =       dimRec.EXCLUDE_FROM_SOLVE_FLAG,
                                FORCE_INPUT_FLAG        =       dimRec.FORCE_INPUT_FLAG,
                                SUM_SELECTION_NAME      =       dimRec.SUM_SELECTION_NAME,
                                SUM_SELECTION_PATH      =       dimRec.SUM_SELECTION_PATH,
                                PROPAGATED_FLAG         =       'Y',
                                LAST_UPDATED_BY         =       fnd_global.USER_ID,
                                LAST_UPDATE_DATE        =       SYSDATE,
                                LAST_UPDATE_LOGIN       =       fnd_global.LOGIN_ID
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(p_to_index) AND
                DIMENSION =dimRec.DIMENSION;
    END IF;
        END LOOP;

        EXCEPTION
        WHEN OTHERS THEN
        IF c1%ISOPEN THEN
                CLOSE c1;
        END IF;
        ROLLBACK;

  END copyDimHandlingInfo;


  /****************************************************************
  *                 COPY INPUT SELECTIONS                         *
  *                                                               *
  *                                                               *
  *****************************************************************/

  PROCEDURE copyInputSelections(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                                p_to_index IN INTEGER,
                                p_dimensionality_flag IN VARCHAR2 DEFAULT 'NO')
  IS
  ipRec         ZPB_SOLVE_INPUT_SELECTIONS%ROWTYPE;
  CURSOR c1 IS


        SELECT * FROM ZPB_SOLVE_INPUT_SELECTIONS
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
  BEGIN
     --Update PROPAGATED_FLAG of source member.
    UPDATE ZPB_SOLVE_INPUT_SELECTIONS
    SET PROPAGATED_FLAG ='Y'
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

        IF p_dimensionality_flag  = 'RECREATE' THEN

                DELETE FROM ZPB_SOLVE_INPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(p_to_index);


                INSERT INTO ZPB_SOLVE_INPUT_SELECTIONS
                    (ANALYSIS_CYCLE_ID,
                    MEMBER,
                    MEMBER_ORDER,
                    DIMENSION,
                    HIERARCHY,
                    SELECTION_NAME,
                    SELECTION_PATH,
                    PROPAGATED_FLAG,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN)
        SELECT
                    ANALYSIS_CYCLE_ID,
                    propagateList(p_to_index),
                    propagateOrder(p_to_index),
                    DIMENSION,
                    HIERARCHY,
                    SELECTION_NAME,
                    SELECTION_PATH,
                    'Y',
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.LOGIN_ID
                FROM ZPB_SOLVE_INPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
        ELSE
                FOR ipRec IN c1 LOOP
                UPDATE ZPB_SOLVE_INPUT_SELECTIONS
                SET
                        SELECTION_NAME          =       ipRec.SELECTION_NAME,
                        SELECTION_PATH          =       ipRec.SELECTION_PATH,
                        PROPAGATED_FLAG         =       'Y',
                        LAST_UPDATED_BY         =       fnd_global.USER_ID,
                        LAST_UPDATE_DATE        =       SYSDATE,
                        LAST_UPDATE_LOGIN       =       fnd_global.LOGIN_ID
                 WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(p_to_index) AND
                DIMENSION =ipRec.DIMENSION AND HIERARCHY =      ipRec.HIERARCHY;
                 END LOOP;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        IF c1%ISOPEN THEN
                CLOSE c1;
        END IF;
        ROLLBACK;



  END copyInputSelections;


  PROCEDURE copyOutputSelections(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                                p_to_index IN INTEGER,
                                p_dimensionality_flag IN VARCHAR2)
  IS
  opRec         ZPB_SOLVE_OUTPUT_SELECTIONS%ROWTYPE;
  CURSOR c1 IS
        SELECT * FROM ZPB_SOLVE_OUTPUT_SELECTIONS
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
  BEGIN
     --Update PROPAGATED_FLAG of source member.
    UPDATE ZPB_SOLVE_OUTPUT_SELECTIONS
    SET PROPAGATED_FLAG ='Y'
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

        IF p_dimensionality_flag  = 'RECREATE' THEN

                DELETE FROM ZPB_SOLVE_OUTPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(p_to_index);


                INSERT INTO ZPB_SOLVE_OUTPUT_SELECTIONS
                    (ANALYSIS_CYCLE_ID,
                    MEMBER,
                    MEMBER_ORDER,
                    DIMENSION,
                    HIERARCHY,
                    SELECTION_NAME,
                    SELECTION_PATH,
                    PROPAGATED_FLAG,
                    MATCH_INPUT_FLAG,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN)
                SELECT
                    ANALYSIS_CYCLE_ID,
                    propagateList(p_to_index),
                    propagateOrder(p_to_index),
                    DIMENSION,
                    HIERARCHY,
                    SELECTION_NAME,
                    SELECTION_PATH,
                    'Y',
                    MATCH_INPUT_FLAG,
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.LOGIN_ID
                FROM ZPB_SOLVE_OUTPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
        ELSIF p_dimensionality_flag  = 'COPY' THEN
                FOR opRec IN c1 LOOP
                UPDATE ZPB_SOLVE_OUTPUT_SELECTIONS
                SET
                        SELECTION_NAME          =       opRec.SELECTION_NAME,
                        SELECTION_PATH          =       opRec.SELECTION_PATH,
                        PROPAGATED_FLAG         =       'Y',
                        LAST_UPDATED_BY         =       fnd_global.USER_ID,
                        LAST_UPDATE_DATE        =       SYSDATE,
                        LAST_UPDATE_LOGIN       =       fnd_global.LOGIN_ID
                 WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(p_to_index) AND
                 DIMENSION =opRec.DIMENSION AND HIERARCHY =     opRec.HIERARCHY;
                 END LOOP;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        IF c1%ISOPEN THEN
                CLOSE c1;
        END IF;
        ROLLBACK;


  END copyOutputSelections;


  PROCEDURE removeCalcObjectInfo(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                 p_to_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE)
  IS
  BEGIN
      UPDATE ZPB_SOLVE_MEMBER_DEFS
      SET CALCSTEP_PATH       =  NULL,
          CALC_TYPE           =  NULL,
          CALC_DESCRIPTION    =  NULL,
          CALC_PARAMETERS     =  NULL,
          MODEL_EQUATION      =  NULL,
          LAST_UPDATED_BY     =  fnd_global.USER_ID,
          LAST_UPDATE_DATE    =  SYSDATE,
          LAST_UPDATE_LOGIN   =  fnd_global.LOGIN_ID
      WHERE ANALYSIS_CYCLE_ID =  p_ac_id AND MEMBER = p_to_member;
  END removeCalcObjectInfo;

  PROCEDURE deleteInializedInputSettings(p_ac_id IN ZPB_DATA_INITIALIZATION_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                         p_to_member IN ZPB_DATA_INITIALIZATION_DEFS.MEMBER%TYPE)
  IS
  BEGIN
        DELETE ZPB_DATA_INITIALIZATION_DEFS
              WHERE ANALYSIS_CYCLE_ID  =  p_ac_id AND MEMBER = p_to_member;


        DELETE ZPB_COPY_DIM_MEMBERS
              WHERE ANALYSIS_CYCLE_ID  =  p_ac_id AND LINE_MEMBER_ID = p_to_member;
  END deleteInializedInputSettings;


  PROCEDURE copyInializedInputSettings(p_ac_id IN ZPB_DATA_INITIALIZATION_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                       p_from_member IN ZPB_DATA_INITIALIZATION_DEFS.MEMBER%TYPE,
                                       p_to_member IN ZPB_DATA_INITIALIZATION_DEFS.MEMBER%TYPE)
  IS

    l_source_query_name  ZPB_DATA_INITIALIZATION_DEFS.SOURCE_QUERY_NAME%TYPE;
    l_target_query_name  ZPB_DATA_INITIALIZATION_DEFS.TARGET_QUERY_NAME%TYPE;

    CURSOR src_trg_qry_names_cur(p_ac_id IN ZPB_DATA_INITIALIZATION_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                       p_from_member IN ZPB_DATA_INITIALIZATION_DEFS.MEMBER%TYPE) IS
        SELECT SOURCE_QUERY_NAME,TARGET_QUERY_NAME
        FROM ZPB_DATA_INITIALIZATION_DEFS
        WHERE ANALYSIS_CYCLE_ID  =  p_ac_id AND MEMBER = p_from_member;

  BEGIN
/* Bug#5092815, Commented for because we copy the initialize settings
   from source line item.
        OPEN  src_trg_qry_names_cur(p_ac_id,p_from_member);
        FETCH src_trg_qry_names_cur INTO l_source_query_name,l_target_query_name;
        CLOSE src_trg_qry_names_cur;

        IF(l_source_query_name is NOT NULL) THEN
          l_source_query_name := 'CD_SOURCE_'||p_to_member;
        END IF;

        IF(l_target_query_name is NOT NULL) THEN
          l_target_query_name := 'CD_TARGET_'||p_to_member;
        END IF;
*/

        --INSERT into ZPB_DATA_INITIALIZATION_DEFS table.
        INSERT INTO ZPB_DATA_INITIALIZATION_DEFS
                    (ANALYSIS_CYCLE_ID,
                    MEMBER,
                    SOURCE_VIEW,
                    LAG_TIME_PERIODS,
                    LAG_TIME_LEVEL,
                    CHANGE_NUMBER,
                    PERCENTAGE_FLAG,
                    QUERY_PATH,
                    SOURCE_QUERY_NAME,
                    TARGET_QUERY_NAME,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    PROPAGATED_FLAG)
            SELECT ANALYSIS_CYCLE_ID,
                    p_to_member,
                    SOURCE_VIEW,
                    LAG_TIME_PERIODS,
                    LAG_TIME_LEVEL,
                    CHANGE_NUMBER,
                    PERCENTAGE_FLAG,
                    QUERY_PATH,
                    source_query_name,
                    target_query_name,
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.USER_ID,
                    SYSDATE,
                  fnd_global.LOGIN_ID,
                  PROPAGATED_FLAG
        FROM ZPB_DATA_INITIALIZATION_DEFS
              WHERE ANALYSIS_CYCLE_ID  =  p_ac_id AND MEMBER = p_from_member;

        INSERT INTO zpb_copy_dim_members
                (DIM,
                ANALYSIS_CYCLE_ID,
                SOURCE_NUM_MEMBERS,
                TARGET_NUM_MEMBERS,
        	CREATED_BY,
        	CREATION_DATE,
        	LAST_UPDATED_BY,
        	LAST_UPDATE_DATE,
        	LAST_UPDATE_LOGIN,
        	SAME_SELECTION,
        	LINE_MEMBER_ID)
            SELECT DIM,
        	ANALYSIS_CYCLE_ID,
        	SOURCE_NUM_MEMBERS,
        	TARGET_NUM_MEMBERS,
        	fnd_global.USER_ID,
        	SYSDATE,
        	fnd_global.USER_ID,
        	SYSDATE,
        	fnd_global.LOGIN_ID,
          	SAME_SELECTION,
        	p_to_member
            FROM zpb_copy_dim_members
              WHERE ANALYSIS_CYCLE_ID  = p_ac_id AND LINE_MEMBER_ID = p_from_member;

  END copyInializedInputSettings;



  /***********************************************************************
  *          CHECK MATCH_INPUT_FLAG                                      *
  * If ZPB_SOLVE_OUTPUT_SELECTIONS.MATCH_INPUT_FLAG = 'Y' for            *
  * Loaded,i/p or worksheet i/p line member                              *
  * then before changing the source type to calc or hier total           *
  * copy the input selection to output selection and set                 *
  * MATCH_INPUT_FLAG to 'N'                                              *
  ***********************************************************************/

  PROCEDURE checkMatchInputToOutputFlag(p_ac_id IN ZPB_SOLVE_OUTPUT_SELECTIONS.ANALYSIS_CYCLE_ID%TYPE,
                                        p_from_member IN ZPB_SOLVE_OUTPUT_SELECTIONS.MEMBER%TYPE)
  IS
        l_selectionPath   ZPB_SOLVE_INPUT_SELECTIONS.SELECTION_PATH%TYPE;
        l_selectionName   ZPB_SOLVE_INPUT_SELECTIONS.SELECTION_NAME%TYPE;

        CURSOR c1 IS
                SELECT MEMBER_ORDER,DIMENSION,HIERARCHY,
                       SELECTION_PATH,SELECTION_NAME,MATCH_INPUT_FLAG
                FROM ZPB_SOLVE_OUTPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member
                FOR UPDATE;

        CURSOR c2(p_ac_id ZPB_SOLVE_INPUT_SELECTIONS.ANALYSIS_CYCLE_ID%TYPE,
                  p_from_member ZPB_SOLVE_INPUT_SELECTIONS.MEMBER%TYPE,
                  p_member_order ZPB_SOLVE_INPUT_SELECTIONS.MEMBER_ORDER%TYPE,
                  p_dimension ZPB_SOLVE_INPUT_SELECTIONS.DIMENSION%TYPE,
                  p_hierarchy ZPB_SOLVE_INPUT_SELECTIONS.HIERARCHY%TYPE)IS
                SELECT SELECTION_PATH,SELECTION_NAME
                FROM ZPB_SOLVE_INPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member AND
                        MEMBER_ORDER = p_member_order AND DIMENSION = p_dimension AND
                        HIERARCHY = p_hierarchy;
   BEGIN
        FOR opRec IN c1 LOOP
            IF opRec.MATCH_INPUT_FLAG = 'Y' THEN

                OPEN c2(p_ac_id,p_from_member,opRec.MEMBER_ORDER,opRec.DIMENSION,opRec.HIERARCHY);
                FETCH c2 INTO l_selectionPath,l_selectionName;
                CLOSE c2;

                UPDATE ZPB_SOLVE_OUTPUT_SELECTIONS
                SET SELECTION_PATH = l_selectionPath,
                    SELECTION_NAME = l_selectionName,
                    MATCH_INPUT_FLAG = 'N'
                WHERE CURRENT OF c1;

            END IF;
        END LOOP;

        EXCEPTION
        WHEN OTHERS THEN
        IF c1%ISOPEN THEN
                CLOSE c1;
        END IF;
        IF c2%ISOPEN THEN
                CLOSE c2;
        END IF;
        ROLLBACK;
  END;




  /****************************************************************
  *          PROPAGATE SOURCE TYPE&(DIM INFO or I/P SELECTIONS    *
  *                                                               *
  *                                                               *
  *****************************************************************/
   PROCEDURE propagateCalc(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                          p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                          p_prop_dimhandling IN INTEGER,
                          p_prop_input IN INTEGER,
                          p_prop_output IN INTEGER)


  IS
    fromSource      ZPB_SOLVE_MEMBER_DEFS.SOURCE_TYPE%TYPE;
    updateSolve     BOOLEAN;
    l_calcDesc      ZPB_SOLVE_MEMBER_DEFS.CALC_DESCRIPTION%TYPE;
    l_calcType      ZPB_SOLVE_MEMBER_DEFS.CALC_TYPE%TYPE;
    l_calcParams    ZPB_SOLVE_MEMBER_DEFS.CALC_PARAMETERS%TYPE;
    l_modelEquation ZPB_SOLVE_MEMBER_DEFS.MODEL_EQUATION%TYPE;
  BEGIN
    SELECT SOURCE_TYPE INTO fromSource
    FROM ZPB_SOLVE_MEMBER_DEFS
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

    --Check whether Source Type of Target Member needs updation
    --Bug#5092815, changed into bulk operation
    FORALL i IN propagateList.FIRST..propagateList.LAST
    UPDATE      ZPB_SOLVE_MEMBER_DEFS
    SET SOURCE_TYPE       =     fromSource,
        LAST_UPDATED_BY       =         fnd_global.USER_ID,
        LAST_UPDATE_DATE      =         SYSDATE,
        LAST_UPDATE_LOGIN         =     fnd_global.LOGIN_ID
    WHERE ANALYSIS_CYCLE_ID =   p_ac_id AND MEMBER = propagateList(i);

    --Bug#5092815, mark the source line as propagated, so that
    --the same settings can be copied to target line
    IF fromsource=INIT_WS_INPUT_SOURCE THEN

      UPDATE ZPB_DATA_INITIALIZATION_DEFS
      SET propagated_flag='Y'
      WHERE ANALYSIS_CYCLE_ID=p_ac_id
      AND MEMBER=p_from_member;

    END IF;

    FOR i IN propagateList.FIRST..propagateList.LAST
          LOOP
                UPDATE  ZPB_SOLVE_MEMBER_DEFS
                SET
                    SOURCE_TYPE           =     fromSource,
                    LAST_UPDATED_BY       =     fnd_global.USER_ID,
                    LAST_UPDATE_DATE      =     SYSDATE,
                LAST_UPDATE_LOGIN         =     fnd_global.LOGIN_ID
        WHERE ANALYSIS_CYCLE_ID =   p_ac_id AND MEMBER = propagateList(i);
    END LOOP;

        FOR i IN propagateList.FIRST..propagateList.LAST
        LOOP

           IF fromSource = LOADED_SOURCE THEN
            --For CASE:D1-a,D1-b,D1-c
            IF p_prop_dimhandling = iTrueValue THEN
                copyDimHandlingInfo(p_ac_id,p_from_member,i,'RECREATE');
            END IF;
            IF p_prop_input = iTrueValue THEN
                copyInputSelections(p_ac_id,p_from_member,i,'RECREATE');
            END IF;

            --Patch B
            IF p_prop_output = iTrueValue THEN
                  copyOutputSelections(p_ac_id,p_from_member,i,'RECREATE');

        ELSE -- delete the o/p selections for non hier dims
           deleteOutputSelections(p_ac_id,i);
        END IF;



            --Remove intialized settings if the source member's source type is INIT_WS_INPUT_SOURCE
            IF propagateSourceType(i) = INIT_WS_INPUT_SOURCE THEN
                deleteInializedInputSettings(p_ac_id,propagateList(i));
            END IF;
            --Remove CalcStep Obj info if the source member's source type is CALCULATED_SOURCE

            IF propagateSourceType(i) = CALCULATED_SOURCE THEN
                removeCalcObjectInfo(p_ac_id,propagateList(i));
            END IF;
        ELSIF fromSource = WS_INPUT_SOURCE THEN
              IF propagateSourceType(i) = LOADED_SOURCE THEN
                DELETE ZPB_LINE_DIMENSIONALITY WHERE
                ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER=propagateList(i);
            END IF;
            IF p_prop_input = iTrueValue THEN
                copyInputSelections(p_ac_id,p_from_member,i,'RECREATE');
            END IF;

            --Patch B

         IF p_prop_output = iTrueValue THEN
                  copyOutputSelections(p_ac_id,p_from_member,i,'RECREATE');

        ELSE -- delete the o/p selections for non hier dims
           deleteOutputSelections(p_ac_id,i);
        END IF;


            --Remove intialized settings if the source member's source type is INIT_WS_INPUT_SOURCE
            IF propagateSourceType(i) = INIT_WS_INPUT_SOURCE THEN

                deleteInializedInputSettings(p_ac_id,propagateList(i));
            END IF;
            --Remove CalcStep Obj info if the source member's source type is CALCULATED_SOURCE
            IF propagateSourceType(i) = CALCULATED_SOURCE THEN
               removeCalcObjectInfo(p_ac_id,propagateList(i));
            END IF;

      ELSIF fromSource = INIT_WS_INPUT_SOURCE THEN
            IF propagateSourceType(i) = LOADED_SOURCE THEN
                DELETE ZPB_LINE_DIMENSIONALITY WHERE
                ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER=propagateList(i);
            END IF;
            IF p_prop_input = iTrueValue THEN
                  copyInputSelections(p_ac_id,p_from_member,i,'RECREATE');
            END IF;
            IF propagateSourceType(i) = INIT_WS_INPUT_SOURCE THEN
                deleteInializedInputSettings(p_ac_id,propagateList(i));
            END IF;

            --Patch B
            IF p_prop_output = iTrueValue THEN
                 copyOutputSelections(p_ac_id,p_from_member,i,'RECREATE');

        ELSE -- delete the o/p selections for non hier dims
           deleteOutputSelections(p_ac_id,i);
        END IF;

            --Remove CalcStep Obj info if the source member's source type is CALCULATED_SOURCE
            IF propagateSourceType(i) = CALCULATED_SOURCE THEN
               removeCalcObjectInfo(p_ac_id,propagateList(i));
            END IF;
            --For all source types of source member copy the initilized input settings from source member.
            copyInializedInputSettings(p_ac_id,p_from_member,propagateList(i));

      ELSIF(fromSource = CALCULATED_SOURCE OR fromSource = AGGREGATED_SOURCE )THEN

            IF(propagateSourceType(i) = LOADED_SOURCE) THEN
                        --For CASES:A3-a
                checkMatchInputToOutputFlag(p_ac_id,propagateList(i));

                DELETE ZPB_LINE_DIMENSIONALITY WHERE
                ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER=propagateList(i);

                DELETE ZPB_SOLVE_INPUT_SELECTIONS WHERE
                ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER=propagateList(i);

            ELSIF(propagateSourceType(i) = WS_INPUT_SOURCE) THEN
                       --For CASES:A3-b
                checkMatchInputToOutputFlag(p_ac_id,propagateList(i));

                DELETE ZPB_SOLVE_INPUT_SELECTIONS WHERE
                ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER=propagateList(i);

             ELSIF(propagateSourceType(i) = INIT_WS_INPUT_SOURCE) THEN
                --For CASES:A3-b
                checkMatchInputToOutputFlag(p_ac_id,propagateList(i));

                DELETE ZPB_SOLVE_INPUT_SELECTIONS WHERE
                ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER=propagateList(i);

                deleteInializedInputSettings(p_ac_id,propagateList(i));
           ELSIF(propagateSourceType(i) = CALCULATED_SOURCE AND fromSource = AGGREGATED_SOURCE )THEN
                removeCalcObjectInfo(p_ac_id,propagateList(i));
           END IF;

           --Patch B
           IF p_prop_output = iTrueValue THEN
                copyOutputSelections(p_ac_id,p_from_member,i,'RECREATE');
          ELSIF fromSource = AGGREGATED_SOURCE THEN -- delete the o/p selections for non hier dims
           deleteOutputSelections(p_ac_id,i);
                /*IF propagateSourceType(i) <> CALCULATED_SOURCE THEN
                        copyOutputSelections(p_ac_id,p_from_member,i,'COPY');
                ELSIF propagateSourceType(i) = CALCULATED_SOURCE THEN
                        copyOutputSelections(p_ac_id,p_from_member,i,'RECREATE');
                END IF;*/
       END IF;

            --Copy Calc related columns
            IF(fromSource = CALCULATED_SOURCE) THEN

                SELECT CALC_DESCRIPTION,CALC_TYPE,CALC_PARAMETERS,MODEL_EQUATION
                INTO    l_calcDesc,l_calcType,l_calcParams,l_modelEquation

                FROM    ZPB_SOLVE_MEMBER_DEFS
                WHERE   ANALYSIS_CYCLE_ID  = p_ac_id AND MEMBER = p_from_member;

                UPDATE ZPB_SOLVE_MEMBER_DEFS
                SET CALCSTEP_PATH       =  propagateList(i),
                    CALC_TYPE           =  l_calcType,
                    CALC_DESCRIPTION    =  l_calcDesc,
                    CALC_PARAMETERS     =  l_calcParams,
                    MODEL_EQUATION      =  l_modelEquation,
                    LAST_UPDATED_BY     =  fnd_global.USER_ID,
                    LAST_UPDATE_DATE    =  SYSDATE,
                    LAST_UPDATE_LOGIN   =  fnd_global.LOGIN_ID
                 WHERE ANALYSIS_CYCLE_ID =  p_ac_id AND MEMBER = propagateList(i);

            END IF;

           END IF;
           END LOOP;
   END propagateCalc;

  /****************************************************************
  *                 PROPAGATE ALLOCATIONS                         *
  *                                                               *
  *                                                               *
  *****************************************************************/

  PROCEDURE propagateAlloc(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,

                           p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE)

  IS
  BEGIN
    --delete existing rows
    FORALL i IN propagateList.FIRST..propagateList.LAST
     DELETE FROM ZPB_SOLVE_ALLOCATION_DEFS
       WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(i);
    --add new rows
    FORALL i IN propagateList.FIRST..propagateList.LAST
      INSERT INTO ZPB_SOLVE_ALLOCATION_DEFS
                (ANALYSIS_CYCLE_ID,
                MEMBER,
                MEMBER_ORDER,
                RULE_NAME,
                METHOD,
                EVALUATION_OPTION,
                ROUND_DECIMALS,
                ROUND_ENABLED,
                BASIS,
                QUALIFIER,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
      SELECT ANALYSIS_CYCLE_ID, propagateList(i), propagateOrder(i), RULE_NAME,
      METHOD, EVALUATION_OPTION, ROUND_DECIMALS, ROUND_ENABLED,
      BASIS, QUALIFIER, fnd_global.USER_ID, SYSDATE,

      fnd_global.USER_ID, SYSDATE, fnd_global.LOGIN_ID
        FROM ZPB_SOLVE_ALLOCATION_DEFS
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
  END propagateAlloc;


  /****************************************************************
  *                 PROPAGATE OUTPUT SELECTIONS                   *
  *                                                               *
  *                                                               *
  *****************************************************************/

   PROCEDURE propagateOutput(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                            p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE)

  IS
        opRec  ZPB_SOLVE_OUTPUT_SELECTIONS%ROWTYPE;

    CURSOR c1 IS
                SELECT * FROM ZPB_SOLVE_OUTPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

         fromSource      ZPB_SOLVE_MEMBER_DEFS.SOURCE_TYPE%TYPE;
  BEGIN
    SELECT SOURCE_TYPE INTO fromSource
    FROM ZPB_SOLVE_MEMBER_DEFS
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

    --For all cases update PROPAGATED_FLAG of source member.
    UPDATE ZPB_SOLVE_OUTPUT_SELECTIONS
    SET PROPAGATED_FLAG ='Y'
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

    FOR i IN propagateList.FIRST..propagateList.LAST LOOP

        --IF propagateList(i) = CALCULATED_SOURCE OR  propagateList(i) = AGGREGATED_SOURCE THEN
          IF propagateSourceType(i) = CALCULATED_SOURCE THEN
           IF fromSource = CALCULATED_SOURCE THEN
                DELETE ZPB_SOLVE_OUTPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(i);
           ELSE
            DELETE ZPB_SOLVE_OUTPUT_SELECTIONS
                WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(i) AND
           HIERARCHY <> 'NONE' ;
           END IF ;
           FOR opRec IN c1 LOOP
                 INSERT INTO ZPB_SOLVE_OUTPUT_SELECTIONS
                         (ANALYSIS_CYCLE_ID,
                         MEMBER,
                         MEMBER_ORDER,
                         DIMENSION,
                         HIERARCHY,
                         SELECTION_NAME,
                         SELECTION_PATH,
                         PROPAGATED_FLAG,
                         MATCH_INPUT_FLAG,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN)
                       VALUES(opRec.ANALYSIS_CYCLE_ID,
                         propagateList(i),
                         propagateOrder(i),
                         opRec.DIMENSION,
                         opRec.HIERARCHY,
                         opRec.SELECTION_NAME,
                         opRec.SELECTION_PATH,
                         'Y',
                         opRec.MATCH_INPUT_FLAG,
                         fnd_global.USER_ID,
                         SYSDATE,
                         fnd_global.USER_ID,
                         SYSDATE,
                         fnd_global.LOGIN_ID);
       END LOOP;



          -- ELSIF ( fromSource = CALCULATED_SOURCE OR  fromSource = AGGREGATED_SOURCE ) AND
                -- (propagateList(i) <> CALCULATED_SOURCE AND  propagateList(i) <> AGGREGATED_SOURCE)THEN
           ELSIF fromSource = CALCULATED_SOURCE AND  propagateSourceType(i) <> CALCULATED_SOURCE THEN

       FOR opRec IN c1 LOOP
        DELETE ZPB_SOLVE_OUTPUT_SELECTIONS
           WHERE ANALYSIS_CYCLE_ID = p_ac_id AND
                 DIMENSION in (select dimension from ZPB_SOLVE_OUTPUT_SELECTIONS
                                  where member = opRec.member
                                    and dimension = opRec.dimension
                                    and analysis_cycle_id = p_ac_id)
                  and member = propagateList(i);
         END LOOP;
          FOR opRec IN c1 LOOP
            if opRec.hierarchy <> 'NONE' then
                 INSERT INTO ZPB_SOLVE_OUTPUT_SELECTIONS
                         (ANALYSIS_CYCLE_ID,
                         MEMBER,
                         MEMBER_ORDER,
                         DIMENSION,
                         HIERARCHY,
                         SELECTION_NAME,
                         SELECTION_PATH,
                         PROPAGATED_FLAG,
                         MATCH_INPUT_FLAG,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN)
                       VALUES(opRec.ANALYSIS_CYCLE_ID,
                         propagateList(i),
                         propagateOrder(i),
                         opRec.DIMENSION,
                         opRec.HIERARCHY,
                         opRec.SELECTION_NAME,
                         opRec.SELECTION_PATH,
                         'Y',
                         opRec.MATCH_INPUT_FLAG,
                         fnd_global.USER_ID,
                         SYSDATE,
                         fnd_global.USER_ID,
                         SYSDATE,
                         fnd_global.LOGIN_ID);
             end if;
       END LOOP;



     ELSE
                     DELETE ZPB_SOLVE_OUTPUT_SELECTIONS
                     WHERE ANALYSIS_CYCLE_ID = p_ac_id AND
                         MEMBER = propagateList(i) ;

             FOR opRec IN c1 LOOP
                 INSERT INTO ZPB_SOLVE_OUTPUT_SELECTIONS
                         (ANALYSIS_CYCLE_ID,
                         MEMBER,
                         MEMBER_ORDER,
                         DIMENSION,
                         HIERARCHY,
                         SELECTION_NAME,
                         SELECTION_PATH,
                         PROPAGATED_FLAG,
                         MATCH_INPUT_FLAG,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN)
                       VALUES(opRec.ANALYSIS_CYCLE_ID,
                         propagateList(i),
                         propagateOrder(i),
                         opRec.DIMENSION,
                         opRec.HIERARCHY,
                         opRec.SELECTION_NAME,
                         opRec.SELECTION_PATH,
                         'Y',
                         opRec.MATCH_INPUT_FLAG,
                         fnd_global.USER_ID,
                         SYSDATE,
                         fnd_global.USER_ID,
                         SYSDATE,
                         fnd_global.LOGIN_ID);
       END LOOP;

    End if;


        END LOOP;


        EXCEPTION
        WHEN OTHERS THEN
        IF c1%ISOPEN THEN
                CLOSE c1;
        END IF;
        ROLLBACK;
  END propagateOutput;

  /****************************************************************
  *                 PROPAGATE DIMENSION INFO                      *
  *                                                               *
  *                                                               *

  *****************************************************************/

  PROCEDURE propagateDimhandling(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                 p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE)
  IS
  fromSource    NUMBER;
  dimRec        ZPB_LINE_DIMENSIONALITY%ROWTYPE;
  isSetSrcPropFlag boolean := FALSE;
  CURSOR c1 IS
        SELECT * FROM ZPB_LINE_DIMENSIONALITY
          WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
  BEGIN
    SELECT SOURCE_TYPE INTO fromSource

    FROM ZPB_SOLVE_MEMBER_DEFS
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

        IF fromSource = LOADED_SOURCE THEN
        FOR i IN propagateList.FIRST..propagateList.LAST
                LOOP
                IF propagateSourceType(i) = LOADED_SOURCE THEN
            isSetSrcPropFlag := TRUE;

                        DELETE ZPB_LINE_DIMENSIONALITY
                          WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = propagateList(i);
                    --For CASE: B1-a
                        FOR dimRec IN c1 LOOP

            INSERT INTO ZPB_LINE_DIMENSIONALITY
                    (ANALYSIS_CYCLE_ID,
                     MEMBER,
                     MEMBER_ORDER,
                     DIMENSION,
                     SUM_MEMBERS_NUMBER,
                     SUM_MEMBERS_FLAG ,
                     EXCLUDE_FROM_SOLVE_FLAG,
                     FORCE_INPUT_FLAG,
                     SUM_SELECTION_NAME,
                     SUM_SELECTION_PATH,
                     PROPAGATED_FLAG,
                     CREATED_BY,
                     CREATION_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATE_LOGIN)
            VALUES (dimRec.ANALYSIS_CYCLE_ID,
                    propagateList(i),
                    propagateOrder(i),
                    dimRec.DIMENSION,
                    dimRec.SUM_MEMBERS_NUMBER,
                    dimRec.SUM_MEMBERS_FLAG ,
                    dimRec.EXCLUDE_FROM_SOLVE_FLAG,
                    dimRec.FORCE_INPUT_FLAG,
                    dimRec.SUM_SELECTION_NAME,
                    dimRec.SUM_SELECTION_PATH,
                    'Y',
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.LOGIN_ID);
            END LOOP;
                END IF;
                END LOOP;
        END IF;
        --Update PROPAGATED_FLAG of source member.
        IF isSetSrcPropFlag = TRUE THEN

        UPDATE ZPB_LINE_DIMENSIONALITY
        SET PROPAGATED_FLAG ='Y'
        WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;
    END IF;

        EXCEPTION
        WHEN  OTHERS THEN
        IF c1%ISOPEN THEN
        CLOSE c1;
        END IF;
        ROLLBACK;
  END propagateDimhandling;



 /****************************************************************
  *                 PROPAGATE SETTINGS                           *
  *                                                              *
  *                                                              *
  *                                                              *
  ****************************************************************/

  PROCEDURE propagateSolve (
                       p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                       p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                       p_view_dim_name IN VARCHAR2,
                       p_view_member_column IN VARCHAR2,
                       p_view_short_lbl_column IN VARCHAR2,
                       p_prop_calc IN INTEGER, -- source flag
                       p_prop_alloc IN INTEGER,
                       p_prop_input IN INTEGER,
                       p_prop_output IN INTEGER, -- o/p flag
                                   p_prop_dimhandling IN INTEGER)
  IS
  tableselect varchar(5000);
  fromSource  NUMBER;

  c4 ref_cursor;
  BEGIN
  --get all the members that have the propagate flag set

    tableselect := 'Select member, member_order,  memberlookup.';
    tableselect := tableselect ||  p_view_short_lbl_column || ' as MemberName,';
    tableselect := tableselect ||  ' SOURCE_TYPE';
    tableselect := tableselect || ' FROM ZPB_SOLVE_MEMBER_DEFS defs, ';
    tableselect := tableselect ||  p_view_dim_name || ' memberlookup';
    tableselect := tableselect || ' WHERE defs.ANALYSIS_CYCLE_ID = ' || p_ac_id;
    tableselect := tableselect || '   AND defs.PROPAGATE_TARGET = ' ||  iTrueValue;
    tableselect := tableselect || '   AND defs.member = memberlookup.' ||  p_view_member_column;

   OPEN c4 FOR tableSelect;
   Fetch c4 BULK COLLECT into propagateList, propagateOrder, propagateName, propagateSourceType;

    SELECT SOURCE_TYPE INTO fromSource

    FROM ZPB_SOLVE_MEMBER_DEFS
    WHERE ANALYSIS_CYCLE_ID = p_ac_id AND MEMBER = p_from_member;

    if p_prop_calc = iTrueValue THEN
      propagateCalc(p_ac_id, p_from_member,p_prop_dimhandling,p_prop_input,p_prop_output);
    END IF;
    if p_prop_alloc = iTrueValue THEN
      propagateAlloc(p_ac_id, p_from_member);
    END IF;
    if p_prop_input = iTrueValue and p_prop_calc = iFalseValue THEN
      propagateInput(p_ac_id, p_from_member);
    END IF;
    if p_prop_output = iTrueValue and p_prop_calc = iFalseValue THEN
       propagateOutput(p_ac_id, p_from_member);
    END IF;
    if p_prop_dimhandling = iTrueValue and p_prop_calc = iFalseValue THEN
           propagateDimhandling(p_ac_id, p_from_member);
    END IF;
    --reset propagate flag
    UPDATE ZPB_SOLVE_MEMBER_DEFS
       SET  PROPAGATE_TARGET    = iFalseValue,
            LAST_UPDATED_BY     =  fnd_global.USER_ID,
            LAST_UPDATE_DATE    = SYSDATE,
            LAST_UPDATE_LOGIN   = fnd_global.LOGIN_ID
       WHERE ANALYSIS_CYCLE_ID  = p_ac_id AND PROPAGATE_TARGET = iTrueValue;
  END propagateSolve;



  FUNCTION getDimSettingMeaning(p_lookup_code IN FND_LOOKUP_VALUES_VL.LOOKUP_CODE%TYPE)
  RETURN VARCHAR2 IS
    ret_meaning FND_LOOKUP_VALUES_VL.MEANING%TYPE;
  BEGIN
    SELECT MEANING||',' INTO ret_meaning
    FROM FND_LOOKUP_VALUES_VL
    WHERE LOOKUP_TYPE = 'ZPB_SOLVE_DIMENSIONLIST_SELECT' AND LOOKUP_CODE = p_lookup_code;
    RETURN ret_meaning;
  END getDimSettingMeaning;

  PROCEDURE updateCleanup(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                        p_line_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                        p_src_type IN ZPB_SOLVE_MEMBER_DEFS.SOURCE_TYPE%TYPE)
  IS

  BEGIN
    IF p_src_type <> LOADED_SOURCE THEN
      delete from zpb_line_dimensionality where analysis_cycle_id = p_ac_id and member = p_line_member;
    END IF;
    IF p_src_type = CALCULATED_SOURCE OR p_src_type = AGGREGATED_SOURCE THEN
      delete from zpb_solve_input_selections where analysis_cycle_id = p_ac_id and member = p_line_member;
      update ZPB_SOLVE_OUTPUT_SELECTIONS
      set MATCH_INPUT_FLAG = 'N'
      where analysis_cycle_id = p_ac_id and member = p_line_member;
    END IF;
    IF p_src_type <> CALCULATED_SOURCE THEN
      delete from zpb_solve_output_selections where analysis_cycle_id = p_ac_id and member = p_line_member
      AND hierarchy = 'NONE';
    END IF;
    IF p_src_type <> INIT_WS_INPUT_SOURCE THEN
     -- for bug 5001437
      delete from zpb_status_sql
      where query_path in (select query_path||'/'||target_query_name
                           from zpb_data_initialization_defs
                           where analysis_cycle_id = p_ac_id
                           and member = p_line_member);

      delete from zpb_status_sql
      where query_path in (select query_path||'/'||source_query_name
                           from zpb_data_initialization_defs
                           where analysis_cycle_id = p_ac_id
                           and   member = p_line_member);

      delete from ZPB_DATA_INITIALIZATION_DEFS where analysis_cycle_id = p_ac_id and member = p_line_member;
      delete from ZPB_COPY_DIM_MEMBERS where analysis_cycle_id = p_ac_id and line_member_id = p_line_member;
    END IF;
    IF p_src_type <> CALCULATED_SOURCE then
        removeCalcObjectInfo(p_ac_id,p_line_member);
    END IF;
END updateCleanup;


  PROCEDURE deleteOutputSelections(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                  p_targetIndex IN INTEGER )
  IS
  BEGIN
     DELETE ZPB_SOLVE_OUTPUT_SELECTIONS
              WHERE ANALYSIS_CYCLE_ID  =  p_ac_id AND MEMBER = propagateList(p_targetIndex)
          AND HIERARCHY = 'NONE';

  END deleteOutputSelections;

   PROCEDURE  insertDefaultOutput(p_ac_id IN ZPB_SOLVE_OUTPUT_SELECTIONS.ANALYSIS_CYCLE_ID%TYPE,
                        p_line_member IN ZPB_SOLVE_OUTPUT_SELECTIONS.MEMBER%TYPE,
                        p_memberOrder IN ZPB_SOLVE_OUTPUT_SELECTIONS.MEMBER_ORDER%TYPE,
                        p_dimension IN ZPB_SOLVE_OUTPUT_SELECTIONS.DIMENSION%TYPE)
  IS
   BEGIN
     INSERT INTO ZPB_SOLVE_OUTPUT_SELECTIONS
                    (ANALYSIS_CYCLE_ID,
                    MEMBER,
                    MEMBER_ORDER,
                    DIMENSION,
                    HIERARCHY,
                    SELECTION_NAME,
                    MATCH_INPUT_FLAG,
                    PROPAGATED_FLAG,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN)
    VALUES (p_ac_id,
            p_line_member,
            p_memberOrder,
            p_dimension,
            'NONE',
            'DEFAULT',
             'N',
             'N',
             fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.USER_ID,
                    SYSDATE,
                    fnd_global.LOGIN_ID);


   END insertDefaultOutput;

--
-- Looks for removed hierarchies in zpb_solve_in/output_selections
-- and removes them, and defaults to other hiers if necessary (4705541)
--
PROCEDURE initialize_solve_selections
   (p_ac_id   IN zpb_analysis_cycles.analysis_cycle_id%TYPE) is
      l_count     number;
      l_ba_id     number;
      l_shadow    number;
      l_new_hier  ZPB_SOLVE_INPUT_SELECTIONS.HIERARCHY%type;
      l_dimension ZPB_SOLVE_INPUT_SELECTIONS.DIMENSION%type;

      cursor input_hiers is
         select distinct hierarchy, dimension
           from zpb_solve_input_selections
           where analysis_cycle_id = p_ac_id
            and hierarchy <> 'NONE'
          MINUS
         select distinct a.epb_id, b.aw_name
           from zpb_hierarchies a,
            zpb_dimensions b,
            zpb_hier_scope c
           where a.dimension_id = b.dimension_id
            and b.bus_area_id = l_ba_id
            and b.is_data_dim = 'YES'
            and a.hierarchy_id = c.hierarchy_id
            and c.user_id = l_shadow;

      cursor output_hiers is
         select distinct hierarchy, dimension
           from zpb_solve_output_selections
           where analysis_cycle_id = p_ac_id
            and hierarchy <> 'NONE'
          MINUS
         select distinct a.EPB_ID, b.aw_name
           from zpb_hierarchies a,
            zpb_dimensions b,
            zpb_hier_scope c
           where a.dimension_id = b.dimension_id
            and b.bus_area_id = l_ba_id
            and b.is_data_dim = 'YES'
            and a.hierarchy_id = c.hierarchy_id
            and c.user_id = l_shadow;
begin
   l_ba_id  := sys_context('ZPB_CONTEXT', 'business_area_id');
   l_shadow := sys_context('ZPB_CONTEXT', 'shadow_id');
   for each in input_hiers loop
      --
      -- First check how many hiers are left, if none, we need to reset to NONE
      --
      select count(*)
        into l_count
        from zpb_dimensions a,
         zpb_hierarchies b,
         zpb_hier_scope c
        where a.aw_name = each.dimension
         and a.bus_area_id = l_ba_id
         and a.dimension_id = b.dimension_id
         and b.epb_id <> 'NULL_GID'
         and b.hierarchy_id = c.hierarchy_id
         and c.user_id = l_shadow;

      if (l_count > 0) then
         --
         -- First delete any selections where there is another selection
         -- on another hierarchy already
         --
         delete from zpb_solve_input_selections
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy
            and member in
            (select member
             from zpb_solve_input_selections
             where analysis_cycle_id = p_ac_id
              and dimension = each.dimension
              and hierarchy <> each.hierarchy);

         --
         -- Now update the rest to be the default on another hierarchy
         -- First find what that other hierarchy will be
         --
         begin
            select a.DEFAULT_HIER
              into l_new_hier
              from zpb_dimensions a,
               zpb_hierarchies b,
               zpb_hier_scope c
              where a.aw_name = each.dimension
               and a.bus_area_id = l_ba_id
               and a.dimension_id = b.dimension_id
               and b.epb_id = a.default_hier
               and b.hierarchy_id = c.hierarchy_id
               and c.user_id = l_shadow;
         exception
            when no_data_found then
               --
               -- User doesnt have access to the default hier, so pick the
               -- first one
               --
               select min(b.epb_id)
                 into l_new_hier
                 from zpb_dimensions a,
                  zpb_hierarchies b,
                  zpb_hier_scope c
                 where a.aw_name = each.dimension
                  and a.bus_area_id = l_ba_id
                  and a.dimension_id = b.dimension_id
                  and b.hierarchy_id = c.hierarchy_id
                  and c.user_id = l_shadow;
         end;
         update zpb_solve_input_selections
           set selection_name = 'DEFAULT',
            selection_path = null,
            hierarchy = l_new_hier,
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.USER_ID,
            last_update_login = FND_GLOBAL.LOGIN_ID
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy;
       else
         --
         -- The case when there are no hierarchies left on the dimension.
         -- First delete any input selections where we have already set the
         -- HIERARCHY to NONE... case when mutliple hiers have been removed
         --
         delete from zpb_solve_input_selections
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy
            and member in
            (select member
             from zpb_solve_input_selections
             where analysis_cycle_id = p_ac_id
              and dimension = each.dimension
              and hierarchy = 'NONE');

         --
         -- Now update the rest to be set to NONE
         --
         update zpb_solve_input_selections
           set hierarchy = 'NONE',
            selection_path = null,
            selection_name = 'DEFAULT',
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.USER_ID,
            last_update_login = FND_GLOBAL.LOGIN_ID
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy;
      end if;
   end loop;

   for each in output_hiers loop
      --
      -- First check how many hiers are left, if none, we need to reset to NONE
      --
      select count(*)
        into l_count
        from zpb_dimensions a,
         zpb_hierarchies b,
         zpb_hier_scope c
        where a.aw_name = each.dimension
         and a.bus_area_id = l_ba_id
         and a.dimension_id = b.dimension_id
         and b.epb_id <> 'NULL_GID'
         and b.hierarchy_id = c.hierarchy_id
         and c.user_id = l_shadow;

      if (l_count > 0) then
         --
         -- First delete any selections where there is another selection
         -- on another hierarchy already
         --
         delete from zpb_solve_output_selections
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy
            and member in
            (select member
             from zpb_solve_output_selections
             where analysis_cycle_id = p_ac_id
              and dimension = each.dimension
              and hierarchy <> each.hierarchy);

         --
         -- Now update the rest to be the default on another hierarchy
         -- First find what that other hierarchy will be
         --
         begin
            select a.DEFAULT_HIER
              into l_new_hier
              from zpb_dimensions a,
               zpb_hierarchies b,
               zpb_hier_scope c
              where a.aw_name = each.dimension
               and a.bus_area_id = l_ba_id
               and a.dimension_id = b.dimension_id
               and b.epb_id = a.default_hier
               and b.hierarchy_id = c.hierarchy_id
               and c.user_id = l_shadow;
         exception
            when no_data_found then
               --
               -- User doesnt have access to the default hier, so pick the
               -- first one
               --
               select min(b.epb_id)
                 into l_new_hier
                 from zpb_dimensions a,
                  zpb_hierarchies b,
                  zpb_hier_scope c
                 where a.aw_name = each.dimension
                  and a.bus_area_id = l_ba_id
                  and a.dimension_id = b.dimension_id
                  and b.hierarchy_id = c.hierarchy_id
                  and c.user_id = l_shadow;
         end;
         update zpb_solve_output_selections
           set selection_name = 'DEFAULT',
            selection_path = null,
            hierarchy = l_new_hier,
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.USER_ID,
            last_update_login = FND_GLOBAL.LOGIN_ID
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy;
       else
         --
         -- The case when there are no hierarchies left on the dimension.
         -- First delete any output selections where we have already set the
         -- HIERARCHY to NONE... case when mutliple hiers have been removed
         --
         delete from zpb_solve_output_selections
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy
            and member in
            (select member
             from zpb_solve_output_selections
             where analysis_cycle_id = p_ac_id
              and dimension = each.dimension
              and hierarchy = 'NONE');

         --
         -- Now update the rest to be set to NONE
         --
         update zpb_solve_output_selections
           set hierarchy = 'NONE',
            selection_path = null,
            selection_name = 'DEFAULT',
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.USER_ID,
            last_update_login = FND_GLOBAL.LOGIN_ID
           where analysis_cycle_id = p_ac_id
            and dimension = each.dimension
            and hierarchy = each.hierarchy;
      end if;
   end loop;

end initialize_solve_selections;

/*=========================================================================+
  |                       PROCEDURE RUN_SOLVE
  |
  | DESCRIPTION
  |   Runs Solve in shared
  |
  |
  |
 +=========================================================================*/
 procedure RUN_SOLVE (errbuf out nocopy varchar2,
                     retcode out nocopy varchar2,
                     p_business_area_id in number,
			   p_instance_id in number)
   IS

   attached   varchar2(1) := 'N';
   l_dbname   varchar2(150);
   l_count    number;
   l_userid   number := fnd_global.USER_ID;
   l_taskid   number;


BEGIN
  retcode := '0';

  --Log
  FND_FILE.put_line(FND_FILE.LOG,'p_business_area_id=' ||p_business_area_id );
  FND_FILE.put_line(FND_FILE.LOG,'p_instance_id=' ||p_instance_id);

  -- Get the task id to pass on to the solve program
  SELECT task_id INTO l_taskid
  FROM zpb_analysis_cycle_tasks
  WHERE sequence =
  ( SELECT max(sequence)
    FROM zpb_analysis_cycle_tasks
    WHERE  analysis_cycle_id = p_instance_id
    AND status_code IN ('COMPLETE')
    ) + 1
  AND analysis_cycle_id = p_instance_id;

 -- Log
  FND_FILE.put_line(FND_FILE.LOG,'l_taskid=' ||l_taskid);


  -- Test run of solve
  ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_TRUE,
                            x_return_status     => retcode,
                            x_msg_count         => l_count,
                            x_msg_data          => errbuf,
                            p_analysis_cycle_id => p_instance_id,
                            p_shared_rw         => FND_API.G_TRUE);
  attached := 'Y';

  l_dbname := ZPB_AW.GET_SCHEMA || '.' || ZPB_AW.GET_SHARED_AW;
  ZPB_AW.EXECUTE('APPS_USER_ID = ''' || TO_CHAR(l_userid) || '''');

  -- intializes the pv_status variable
  ZPB_ERROR_HANDLER.INIT_CONC_REQ_STATUS;
  ZPB_AW.EXECUTE('call SV.RUN.SOLVE(''' || l_dbname || ''', ''' || TO_CHAR(p_instance_id) || ''', ''' || TO_CHAR(l_taskid) || ''')');
  -- retcode is an OUT parameter conc program standard - 0=success, 1=warning or 2=error.
  retcode := ZPB_ERROR_HANDLER.GET_CONC_REQ_STATUS;

  -- update
  --ZPB_AW.EXECUTE('upd');
  ZPB_AW.EXECUTE('pa.commit');

  commit;

  ZPB_AW.DETACH_ALL;
  attached := 'N';

  --log solve OK
  FND_FILE.put_line(FND_FILE.LOG,'Solve ok');
  return;

  exception
    when no_data_found then
    -- There are no active tasks
    retcode :='2';

    if attached = 'Y' then
       ZPB_AW.DETACH_ALL;
    end if;

    FND_FILE.put_line(FND_FILE.LOG, 'Solve not ok');
    errbuf := 'No task found';


    when others then
    retcode :='2';

    if attached = 'Y' then
       ZPB_AW.DETACH_ALL;
    end if;

    --log solve not OK
    FND_FILE.put_line(FND_FILE.LOG, 'Solve not ok');
    errbuf:=substr(sqlerrm, 1, 255);

end run_solve;

END zpb_solve;

/
