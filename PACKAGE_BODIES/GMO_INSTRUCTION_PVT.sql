--------------------------------------------------------
--  DDL for Package Body GMO_INSTRUCTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_INSTRUCTION_PVT" AS
/* $Header: GMOVINTB.pls 120.29.12010000.2 2008/11/13 17:17:52 srpuri ship $ */

G_PKG_NAME CONSTANT VARCHAR2(40) := 'GMO_INSTRUCTION_PVT';

--Bug 4730261: start
--This is an internal procedure to raise instruction set event
--for CBR implementation.
PROCEDURE RAISE_INSTR_SET_EVENT
(
    P_INSTRUCTION_SET_ID NUMBER
)
IS
  l_event_name VARCHAR2(100) := 'oracle.apps.gmo.instrset.update';
  l_event_key  VARCHAR2(100);
  l_event_data      clob default NULL;
  l_param_table       FND_WF_EVENT.Param_Table;
  l_parameter_list wf_parameter_list_t := wf_parameter_list_t();

  l_entity_key varchar2(500);
  cursor c_get_entity_key is select entity_key from gmo_instr_set_instance_b where instruction_set_id = P_INSTRUCTION_SET_ID;

BEGIN

	if (P_INSTRUCTION_SET_ID is not null and P_INSTRUCTION_SET_ID <> -1 ) THEN
		open c_get_entity_key;
		fetch c_get_entity_key into l_entity_key;
		close c_get_entity_key;

		--Bug 5224619: start
		--we should not raise the event when the event key is not set
                --and pi internal value is being used as entity key.
		if (instr (l_entity_key, GMO_CONSTANTS_GRP.G_INSTR_PREFIX) =  0 ) THEN
		  l_event_key := P_INSTRUCTION_SET_ID;
		  wf_event.raise3(
			p_event_name =>l_event_name ,
			p_event_key => l_event_key,
			p_event_data => l_event_data,
			p_parameter_list => l_parameter_list,
			p_send_date => sysdate
		  );
		end if;
		--Bug 5224619: end
	end if;
END RAISE_INSTR_SET_EVENT;
--Bug 4730261: end
-- This API is private, and used to update the entity key
-- stored across all temporary tables
PROCEDURE UPDATE_ENTITY_KEY
(
     P_INSTRUCTION_PROCESS_ID IN NUMBER,
     P_ENTITY_KEY IN VARCHAR2
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF(P_INSTRUCTION_PROCESS_ID IS NOT NULL AND P_ENTITY_KEY IS NOT NULL) THEN
        UPDATE GMO_INSTR_ATTRIBUTES_T SET ENTITY_KEY = P_ENTITY_KEY
        WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
        AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY;
    END IF;

    -- Commit the changes
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK;
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_INSTRUCTION_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','UPDATE_ENTITY_KEY');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_INSTRUCTION_PVT.UPDATE_ENTITY_KEY',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;

END UPDATE_ENTITY_KEY;

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition
PROCEDURE CREATE_DEFN_CONTEXT
(
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN FND_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN FND_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2
) IS PRAGMA AUTONOMOUS_TRANSACTION;

    L_INSTRUCTION_PROCESS_ID  NUMBER;

    L_ENTITY_NAME VARCHAR2(100);
    L_ENTITY_KEY VARCHAR2(1000);
    L_ENTITY_DISPLAYNAME VARCHAR2(500);

    L_INSTRUCTION_TYPE VARCHAR2(4000);

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTRUCTION_ID NUMBER;

    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_MODE_PARAM_ERR EXCEPTION;
    L_DUPLICATE_PARAM_ERR EXCEPTION;

    L_PARAM_REC1 GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_REC_TYPE;
    L_PARAM_REC2 GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_REC_TYPE;

    L_PARAM_NAME1 VARCHAR2(100);
    L_PARAM_NAME2 VARCHAR2(100);

    L_COUNT NUMBER;

    L_CONTEXT_TYPE VARCHAR2(400);

    L_RETURN_STATUS VARCHAR2(10);

    CURSOR L_GMO_INSTR_SET_CSR IS
        SELECT INSTRUCTION_SET_ID, INSTRUCTION_TYPE,
                ENTITY_NAME, ENTITY_KEY, INSTR_SET_NAME,
                INSTR_SET_DESC, ACKN_STATUS
        FROM GMO_INSTR_SET_DEFN_VL
        WHERE ENTITY_NAME = L_ENTITY_NAME
        AND NVL(ENTITY_KEY,1) = NVL(L_ENTITY_KEY,1)
        AND ACKN_STATUS = GMO_CONSTANTS_GRP.G_INSTR_SET_ACKN_STATUS;

    CURSOR L_GMO_INSTR_CSR IS
        SELECT INSTRUCTION_ID, INSTRUCTION_SET_ID, INSTRUCTION_TEXT,
            TASK_ID, TASK_ATTRIBUTE, TASK_ATTRIBUTE_ID, TASK_LABEL, INSTR_SEQ,
            INSTR_ACKN_TYPE, INSTR_NUMBER
        FROM
            GMO_INSTR_DEFN_VL
        WHERE INSTRUCTION_SET_ID  = L_INSTRUCTION_SET_ID;

    CURSOR L_GMO_INSTR_APPR_CSR IS
        SELECT INSTRUCTION_ID, APPROVER_SEQ,
            ROLE_COUNT, ROLE_NAME
        FROM
            GMO_INSTR_APPR_DEFN
        WHERE INSTRUCTION_ID = L_INSTRUCTION_ID;

    L_GMO_INSTR_SET_REC L_GMO_INSTR_SET_CSR%ROWTYPE;
    L_GMO_INSTR_REC L_GMO_INSTR_CSR%ROWTYPE;
    L_GMO_INSTR_APPR_REC L_GMO_INSTR_APPR_CSR%ROWTYPE;

    L_VALID_PROCESS NUMBER;
    L_ENTITY_EXIST_COUNT NUMBER;
    L_INSTR_SET_EXIST_COUNT NUMBER;

    CURSOR L_IS_VALID_PROCESS_CSR IS
    	SELECT COUNT(*) FROM GMO_INSTR_ATTRIBUTES_T
    	WHERE INSTRUCTION_PROCESS_ID = P_CURR_INSTR_PROCESS_ID
    	AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS
    	AND ATTRIBUTE_VALUE <> GMO_CONSTANTS_GRP.G_PROCESS_TERMINATE;

     L_API_NAME VARCHAR2(40);
     L_MESG_TEXT varchar2(1000);

BEGIN

    L_API_NAME := 'CREATE_DEFN_CONTEXT';
    L_VALID_PROCESS := 0;

    IF (P_CURR_INSTR_PROCESS_ID is null) THEN
    	L_VALID_PROCESS := 0;
    ELSE
	    open L_IS_VALID_PROCESS_CSR;
	    fetch L_IS_VALID_PROCESS_CSR into L_VALID_PROCESS;
	    close L_IS_VALID_PROCESS_CSR;
    END IF;

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
	X_CREATION_DATE => L_CREATION_DATE,
	X_CREATED_BY => L_CREATED_BY,
	X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    -- Check the MODE parameter, it must be either READ or UPDATE
    IF ((P_MODE <> GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_READ)
	AND (P_MODE <> GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE)) THEN
	RAISE L_MODE_PARAM_ERR;
    END IF;

    -- If the process is valid, then proceed with creating the definition
    -- context
    IF (L_VALID_PROCESS = 0) THEN
	  -- This API will create rows in GMO_INSTR_ATTRIBUTES_T table with
	  -- name , value pairs for entity_name, entity_key and context parameters
	  -- to create a context for the definition of Process Instructions to start
          SELECT GMO_INSTR_PROCESS_ID_S.NEXTVAL INTO L_INSTRUCTION_PROCESS_ID
	  FROM DUAL;

	  --Insert 'MODE' = P_MODE
	  INSERT INTO GMO_INSTR_ATTRIBUTES_T
	  (
		INSTRUCTION_PROCESS_ID,
		ATTRIBUTE_SEQ,
		ATTRIBUTE_NAME,
		ATTRIBUTE_VALUE,
		ATTRIBUTE_TYPE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	  )
	  VALUES
	  (
		L_INSTRUCTION_PROCESS_ID,
		GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
		GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE,
		P_MODE,
		GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
		L_CREATION_DATE,
		L_CREATED_BY,
		L_LAST_UPDATE_DATE,
		L_LAST_UPDATED_BY,
		L_LAST_UPDATE_LOGIN
	  );

          -- Insert 'DEFINITION_STATUS' = 'NO_CHANGE'
	  -- If anything is modified in definition UI, this status
	  -- gets changed from G_STATUS_NO_CHANGE to G_STATUS_MODIFIED

	  INSERT INTO GMO_INSTR_ATTRIBUTES_T
	  (
		INSTRUCTION_PROCESS_ID,
		ATTRIBUTE_SEQ,
		ATTRIBUTE_NAME,
		ATTRIBUTE_VALUE,
		ATTRIBUTE_TYPE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	  )
	  VALUES
	  (
		L_INSTRUCTION_PROCESS_ID,
		GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
		GMO_CONSTANTS_GRP.G_DEFINITION_STATUS,
		GMO_CONSTANTS_GRP.G_STATUS_NO_CHANGE,
		GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
		L_CREATION_DATE,
		L_CREATED_BY,
		L_LAST_UPDATE_DATE,
		L_LAST_UPDATED_BY,
		L_LAST_UPDATE_LOGIN
	  );

          -- Insert 'PROCESS_STATUS' = 'ERROR'
	  -- if the Process is successful, and Apply is clicked
	  -- PROCESS_STATUS = SUCCESS
	  -- if in the process, Cancel is clicked,
	  -- PROCESS_STATUS = CANCEL
	  -- If the process is error, i.e. browser close,
	  -- PROCESS_STATUS = ERROR , remains as is

	  INSERT INTO GMO_INSTR_ATTRIBUTES_T
	  (
		INSTRUCTION_PROCESS_ID,
		ATTRIBUTE_SEQ,
		ATTRIBUTE_NAME,
		ATTRIBUTE_VALUE,
		ATTRIBUTE_TYPE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	  )
	  VALUES
	  (
		L_INSTRUCTION_PROCESS_ID,
		GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
		GMO_CONSTANTS_GRP.G_PROCESS_STATUS,
		GMO_CONSTANTS_GRP.G_PROCESS_ERROR,
		GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
		L_CREATION_DATE,
		L_CREATED_BY,
		L_LAST_UPDATE_DATE,
		L_LAST_UPDATED_BY,
		L_LAST_UPDATE_LOGIN
	  );
    ELSE
    	L_INSTRUCTION_PROCESS_ID := P_CURR_INSTR_PROCESS_ID;

    	-- update the mode
    	UPDATE GMO_INSTR_ATTRIBUTES_T
	SET ATTRIBUTE_VALUE = P_MODE,
    	  LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
	  LAST_UPDATED_BY = L_LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
    	WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
    	AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE
    	AND ATTRIBUTE_TYPE = GMO_CONSTANTS_GRP.G_PARAM_INTERNAL;

	-- update the status to ERROR
    	UPDATE GMO_INSTR_ATTRIBUTES_T
	SET ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_ERROR,
    	   LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
	   LAST_UPDATED_BY = L_LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
    	WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
    	AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS
    	AND ATTRIBUTE_TYPE = GMO_CONSTANTS_GRP.G_PARAM_INTERNAL;

    END IF; -- if L_VALID_PROCESS = 0;

    --Insert Entity Name and Entity Key values in GMO_INSTR_ATTRIBUTES_T
    L_INSTRUCTION_TYPE := P_INSTRUCTION_TYPE(1);

    FOR J IN 2..P_INSTRUCTION_TYPE.count LOOP
            L_INSTRUCTION_TYPE := L_INSTRUCTION_TYPE || ',' || P_INSTRUCTION_TYPE(J);
    END LOOP;

    IF (P_ENTITY_NAME.count > 0) THEN

	-- Mark all entities as RENDER FALSE
    	UPDATE GMO_INSTR_ATTRIBUTES_T
	SET ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_RENDER_FALSE,
    	   LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
	   LAST_UPDATED_BY = L_LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
    	WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
    	AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY;

    	FOR I IN 1..P_ENTITY_NAME.COUNT LOOP
         	        L_ENTITY_NAME := P_ENTITY_NAME(I);
			L_ENTITY_KEY := P_ENTITY_KEY(I);
			L_ENTITY_DISPLAYNAME := P_ENTITY_DISPLAYNAME(I);

			L_ENTITY_EXIST_COUNT := 0;

			SELECT COUNT(*) INTO L_ENTITY_EXIST_COUNT FROM GMO_INSTR_ATTRIBUTES_T
			WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
			AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY
			AND ENTITY_NAME = L_ENTITY_NAME
			AND ENTITY_KEY = L_ENTITY_KEY;

			IF (l_entity_exist_count = 0) THEN
				-- Validate all of these before inserting
				INSERT INTO GMO_INSTR_ATTRIBUTES_T
				(
					INSTRUCTION_PROCESS_ID,
					ATTRIBUTE_SEQ,
					ATTRIBUTE_NAME,
					ATTRIBUTE_VALUE,
					ATTRIBUTE_TYPE,
					ENTITY_NAME,
					ENTITY_KEY,
					ENTITY_DISPLAY_NAME,
					INSTRUCTION_TYPE,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN
				)
				VALUES
				(
					L_INSTRUCTION_PROCESS_ID,
					GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
					GMO_CONSTANTS_GRP.G_PARAM_ENTITY,
					GMO_CONSTANTS_GRP.G_RENDER_TRUE,
					GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
					L_ENTITY_NAME,
					L_ENTITY_KEY,
					L_ENTITY_DISPLAYNAME,
					L_INSTRUCTION_TYPE,
					L_CREATION_DATE,
					L_CREATED_BY,
					L_LAST_UPDATE_DATE,
					L_LAST_UPDATED_BY,
					L_LAST_UPDATE_LOGIN
				);
			ELSE
				UPDATE GMO_INSTR_ATTRIBUTES_T
				SET ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_RENDER_TRUE,
                                    ENTITY_DISPLAY_NAME = L_ENTITY_DISPLAYNAME
				WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
				AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY
				AND ENTITY_NAME = L_ENTITY_NAME
				AND ENTITY_KEY = L_ENTITY_KEY;
			END IF;
	    END LOOP;
    END IF;

    -- Delete the existing context parameters
    IF (P_CONTEXT_PARAMETERS.COUNT > 0) THEN
    	DELETE FROM GMO_INSTR_ATTRIBUTES_T WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
	AND ATTRIBUTE_TYPE = GMO_CONSTANTS_GRP.G_PARAM_CONTEXT;
    END IF;

    -- Insert P_CONTEXT_PARAMETERS in GMO_INSTR_ATTRIBUTES_T
    FOR I IN 1..P_CONTEXT_PARAMETERS.COUNT LOOP
       IF P_CONTEXT_PARAMETERS(I).NAME = GMO_CONSTANTS_GRP.G_INSTR_RETURN_URL OR
          P_CONTEXT_PARAMETERS(I).NAME = GMO_CONSTANTS_GRP.G_INSTR_SOURCE_APPL_TYPE THEN

         L_RETURN_STATUS := SET_PROCESS_VARIABLE(P_INSTRUCTION_PROCESS_ID => L_INSTRUCTION_PROCESS_ID,
                                                 P_ATTRIBUTE_NAME         => P_CONTEXT_PARAMETERS(I).NAME,
                                                 P_ATTRIBUTE_VALUE        => P_CONTEXT_PARAMETERS(I).VALUE,
                                                 P_ATTRIBUTE_TYPE         => GMO_CONSTANTS_GRP.G_PARAM_INTERNAL);

         --Check the return status for each process attribute
	 IF (L_RETURN_STATUS = GMO_CONSTANTS_GRP.NO) THEN
           ROLLBACK;
           APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

       ELSE
         INSERT INTO GMO_INSTR_ATTRIBUTES_T
         (
           INSTRUCTION_PROCESS_ID,
           ATTRIBUTE_SEQ,
           ATTRIBUTE_NAME,
           ATTRIBUTE_VALUE,
           ATTRIBUTE_TYPE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
         )
         VALUES
         (
           L_INSTRUCTION_PROCESS_ID,
           GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
           P_CONTEXT_PARAMETERS(I).NAME,
           P_CONTEXT_PARAMETERS(I).VALUE,
           GMO_CONSTANTS_GRP.G_PARAM_CONTEXT,
           L_CREATION_DATE,
           L_CREATED_BY,
           L_LAST_UPDATE_DATE,
           L_LAST_UPDATED_BY,
           L_LAST_UPDATE_LOGIN
         );
      END IF;

    END LOOP;

    -- Also, find if there are any entries already existing in permanent tables
    -- if yes, copy them to temporary table with this new Instruction_Process_Id

    FOR I IN 1..P_ENTITY_NAME.COUNT LOOP

        L_ENTITY_NAME := P_ENTITY_NAME(I);
        L_ENTITY_KEY := P_ENTITY_KEY(I);

        OPEN L_GMO_INSTR_SET_CSR;
        LOOP
        FETCH L_GMO_INSTR_SET_CSR INTO L_GMO_INSTR_SET_REC;
        EXIT WHEN L_GMO_INSTR_SET_CSR%NOTFOUND;
            L_INSTRUCTION_SET_ID := L_GMO_INSTR_SET_REC.INSTRUCTION_SET_ID;
            L_INSTR_SET_EXIST_COUNT := 0;

	    SELECT COUNT(*) INTO L_INSTR_SET_EXIST_COUNT
            FROM GMO_INSTR_SET_DEFN_T
            WHERE INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
            AND INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

            IF ( ( L_INSTRUCTION_TYPE IS NOT NULL AND ( LENGTH(L_INSTRUCTION_TYPE) = 0 OR
                INSTR( l_instruction_type, L_GMO_INSTR_SET_REC.INSTRUCTION_TYPE) >  0 )) AND L_INSTR_SET_EXIST_COUNT = 0) THEN

                -- Insert the Instruction Set Record from permenant to temporary
                -- tables
                INSERT INTO GMO_INSTR_SET_DEFN_T
                (
                    INSTRUCTION_PROCESS_ID,
                    INSTRUCTION_SET_ID,
                    INSTRUCTION_TYPE,
                    ENTITY_NAME,
                    ENTITY_KEY,
                    INSTR_SET_NAME,
                    INSTR_SET_DESC,
                    ACKN_STATUS,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN
                )
                VALUES
                (
                    L_INSTRUCTION_PROCESS_ID,
                    L_GMO_INSTR_SET_REC.INSTRUCTION_SET_ID,
                    L_GMO_INSTR_SET_REC.INSTRUCTION_TYPE,
                    L_GMO_INSTR_SET_REC.ENTITY_NAME,
                    L_GMO_INSTR_SET_REC.ENTITY_KEY,
                    L_GMO_INSTR_SET_REC.INSTR_SET_NAME,
                    L_GMO_INSTR_SET_REC.INSTR_SET_DESC,
                    GMO_CONSTANTS_GRP.G_INSTR_SET_UNACKN_STATUS,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_LAST_UPDATE_LOGIN
                );

                -- Also copy attachments related to this Instruction Set Id
                -- from permenant entity to temporary entity

                FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_B_ENTITY,
                                                X_from_pk1_value => L_GMO_INSTR_SET_REC.INSTRUCTION_SET_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_T_ENTITY,
                                                X_to_pk1_value => L_GMO_INSTR_SET_REC.INSTRUCTION_SET_ID,
                                                X_to_pk2_value => L_INSTRUCTION_PROCESS_ID,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY ,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
                                             );

                OPEN L_GMO_INSTR_CSR;
                LOOP
                    FETCH L_GMO_INSTR_CSR INTO L_GMO_INSTR_REC;
                    EXIT WHEN L_GMO_INSTR_CSR%NOTFOUND;

                    INSERT INTO GMO_INSTR_DEFN_T
                    (
                        INSTRUCTION_PROCESS_ID,
                        INSTRUCTION_ID,
                        INSTRUCTION_SET_ID,
                        INSTRUCTION_TEXT,
                        TASK_ID,
                        TASK_ATTRIBUTE,
                        TASK_ATTRIBUTE_ID,
                        TASK_LABEL,
                        INSTR_SEQ,
                        INSTR_ACKN_TYPE,
                        INSTR_NUMBER,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN
                    )
                    VALUES
                    (
                        L_INSTRUCTION_PROCESS_ID,
                        L_GMO_INSTR_REC.INSTRUCTION_ID,
                        L_GMO_INSTR_REC.INSTRUCTION_SET_ID,
                        L_GMO_INSTR_REC.INSTRUCTION_TEXT,
                        L_GMO_INSTR_REC.TASK_ID,
                        L_GMO_INSTR_REC.TASK_ATTRIBUTE,
                        L_GMO_INSTR_REC.TASK_ATTRIBUTE_ID,
                        L_GMO_INSTR_REC.TASK_LABEL,
                        L_GMO_INSTR_REC.INSTR_SEQ,
                        L_GMO_INSTR_REC.INSTR_ACKN_TYPE,
                        L_GMO_INSTR_REC.INSTR_NUMBER,
                        L_CREATION_DATE,
                        L_CREATED_BY,
                        L_LAST_UPDATE_DATE,
                        L_LAST_UPDATED_BY,
                        L_LAST_UPDATE_LOGIN
                    );

                    -- Also copy attachments related to this Instruction Set Id
                    -- from permenant entity to temporary entity

                    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_B_ENTITY,
                                                X_from_pk1_value => L_GMO_INSTR_REC.INSTRUCTION_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_T_ENTITY,
                                                X_to_pk1_value => L_GMO_INSTR_REC.INSTRUCTION_ID,
                                                X_to_pk2_value => L_INSTRUCTION_PROCESS_ID,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY ,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
                                       );

                    L_INSTRUCTION_ID := L_GMO_INSTR_REC.INSTRUCTION_ID;

                    OPEN L_GMO_INSTR_APPR_CSR;
                    LOOP
                        FETCH L_GMO_INSTR_APPR_CSR INTO L_GMO_INSTR_APPR_REC;
                        EXIT WHEN L_GMO_INSTR_APPR_CSR%NOTFOUND;

                        INSERT INTO GMO_INSTR_APPR_DEFN_T
                        (
                            INSTRUCTION_PROCESS_ID,
                            INSTRUCTION_ID,
                            APPROVER_SEQ,
                            ROLE_COUNT,
                            ROLE_NAME,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_LOGIN
                        )
                        VALUES
                        (
                            L_INSTRUCTION_PROCESS_ID,
                            L_GMO_INSTR_APPR_REC.INSTRUCTION_ID,
                            L_GMO_INSTR_APPR_REC.APPROVER_SEQ,
                            L_GMO_INSTR_APPR_REC.ROLE_COUNT,
                            L_GMO_INSTR_APPR_REC.ROLE_NAME,
                            L_CREATION_DATE,
                            L_CREATED_BY,
                            L_LAST_UPDATE_DATE,
                            L_LAST_UPDATED_BY,
                            L_LAST_UPDATE_LOGIN
                        );

                   END LOOP;
                   CLOSE L_GMO_INSTR_APPR_CSR;

              END LOOP;
                   CLOSE L_GMO_INSTR_CSR;
           END IF;

        END LOOP;
        CLOSE L_GMO_INSTR_SET_CSR;

    END LOOP;

    -- COMMIT CHANGES
    COMMIT;

    X_INSTRUCTION_PROCESS_ID := L_INSTRUCTION_PROCESS_ID;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN L_MODE_PARAM_ERR THEN

        ROLLBACK;
        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_MODE_PARAM_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );
	FND_MESSAGE.SET_TOKEN('MODE', P_MODE );
        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        (   G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_DEFN_CONTEXT',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

        ROLLBACK;
        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   ( G_PKG_NAME,
                     L_API_NAME );
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
        (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                            'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT',
                            FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END CREATE_DEFN_CONTEXT;

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition

PROCEDURE CREATE_DEFN_CONTEXT
(
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,

    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2
)
IS

    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;
    L_INSTRUCTION_TYPE FND_TABLE_OF_VARCHAR2_255;

BEGIN

  L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();
  L_INSTRUCTION_TYPE := FND_TABLE_OF_VARCHAR2_255();

  FOR J IN 1..P_INSTRUCTION_TYPE.count LOOP
      L_INSTRUCTION_TYPE.EXTEND;
      L_INSTRUCTION_TYPE(J) := P_INSTRUCTION_TYPE(J);
  END LOOP;

  FOR I IN 1..P_ENTITY_NAME.COUNT LOOP
    L_ENTITY_NAME.EXTEND;
    L_ENTITY_KEY.EXTEND;
    L_ENTITY_DISPLAYNAME.EXTEND;

    L_ENTITY_NAME(I) := P_ENTITY_NAME(I);
    L_ENTITY_KEY(I) := P_ENTITY_KEY(I);
    L_ENTITY_DISPLAYNAME(I) := P_ENTITY_DISPLAYNAME(I);

  END LOOP;

  BEGIN

        CREATE_DEFN_CONTEXT
        (
            P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
            P_ENTITY_NAME => L_ENTITY_NAME,
            P_ENTITY_KEY => L_ENTITY_KEY,
            P_ENTITY_DISPLAYNAME => L_ENTITY_DISPLAYNAME,
            P_INSTRUCTION_TYPE => L_INSTRUCTION_TYPE,
            P_MODE => P_MODE,
            P_CONTEXT_PARAMETERS => P_CONTEXT_PARAMETERS,
            X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
            X_RETURN_STATUS => X_RETURN_STATUS,
            X_MSG_COUNT => X_MSG_COUNT,
            X_MSG_DATA => X_MSG_DATA
        );

  END;

END;

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition

PROCEDURE CREATE_DEFN_CONTEXT
(
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN VARCHAR2,
    P_ENTITY_KEY            IN VARCHAR2,
    P_ENTITY_DISPLAYNAME    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2
) IS

    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;
    L_INSTRUCTION_TYPE FND_TABLE_OF_VARCHAR2_255;

BEGIN

    L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
    L_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
    L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();
    L_INSTRUCTION_TYPE := FND_TABLE_OF_VARCHAR2_255();

    L_ENTITY_NAME.EXTEND;
    L_ENTITY_KEY.EXTEND;
    L_ENTITY_DISPLAYNAME.EXTEND;
    L_INSTRUCTION_TYPE.EXTEND;

    L_ENTITY_NAME(1) := P_ENTITY_NAME;
    L_ENTITY_KEY(1) := P_ENTITY_KEY;
    L_ENTITY_DISPLAYNAME(1) := P_ENTITY_DISPLAYNAME;
    L_INSTRUCTION_TYPE(1) := P_INSTRUCTION_TYPE;

    BEGIN
        CREATE_DEFN_CONTEXT
        (
            P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
            P_ENTITY_NAME => L_ENTITY_NAME,
            P_ENTITY_KEY => L_ENTITY_KEY,
            P_ENTITY_DISPLAYNAME => L_ENTITY_DISPLAYNAME,
            P_INSTRUCTION_TYPE => L_INSTRUCTION_TYPE,
            P_MODE => P_MODE,
            P_CONTEXT_PARAMETERS => P_CONTEXT_PARAMETERS,
            X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
            X_RETURN_STATUS => X_RETURN_STATUS,
            X_MSG_COUNT => X_MSG_COUNT,
            X_MSG_DATA => X_MSG_DATA
        );

    END;

END CREATE_DEFN_CONTEXT;

-- This API is called to delete the instructions related to an entity
-- from the Process Instructions System.

PROCEDURE DELETE_ENTITY_FOR_PROCESS
(
       P_CURR_INSTR_PROCESS_ID   IN NUMBER,
       P_ENTITY_NAME             IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       P_ENTITY_KEY              IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       X_INSTRUCTION_PROCESS_ID  OUT NOCOPY NUMBER,
       X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
       X_MSG_COUNT             OUT NOCOPY NUMBER,
       X_MSG_DATA              OUT NOCOPY VARCHAR2
)IS PRAGMA AUTONOMOUS_TRANSACTION;

L_COUNT NUMBER;

L_INSTRUCTION_TYPE FND_TABLE_OF_VARCHAR2_255;
L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
L_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;
L_CONTEXT_PARAMETERS GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE;

L_LOOKUP_TYPE VARCHAR2(300);
L_LOOKUP_CODE VARCHAR2(300);
L_EXIST_INSTR_TYPE BOOLEAN;

L_API_NAME VARCHAR2(40);

CURSOR L_CSR_GET_INSTR_TYPES IS
SELECT LOOKUP_CODE FROM FND_LOOKUPS WHERE LOOKUP_TYPE = 'GMO_INSTR_' || L_LOOKUP_TYPE;

BEGIN

    L_API_NAME := 'DELETE_ENTITY_FOR_PROCESS';

    L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
    L_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
    L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();

	FOR I IN 1..P_ENTITY_NAME.COUNT LOOP
		L_ENTITY_NAME.EXTEND;
		L_ENTITY_KEY.EXTEND;
		L_ENTITY_DISPLAYNAME.EXTEND;

		L_ENTITY_NAME(I) := P_ENTITY_NAME(I);
		L_ENTITY_KEY(I) := P_ENTITY_KEY(I);
		L_ENTITY_DISPLAYNAME(I) := '';
	END LOOP;

	L_COUNT := 0;
	L_INSTRUCTION_TYPE := FND_TABLE_OF_VARCHAR2_255();

	FOR I IN 1..P_ENTITY_NAME.COUNT LOOP

		L_LOOKUP_TYPE := P_ENTITY_NAME(I);

		OPEN L_CSR_GET_INSTR_TYPES;
		LOOP
		FETCH L_CSR_GET_INSTR_TYPES INTO L_LOOKUP_CODE;
		EXIT WHEN L_CSR_GET_INSTR_TYPES%NOTFOUND;
			IF (L_INSTRUCTION_TYPE IS NULL) THEN
				L_COUNT := L_COUNT + 1;
				L_INSTRUCTION_TYPE(L_COUNT) := l_lookup_code;
			ELSE
				L_EXIST_INSTR_TYPE := FALSE;

				FOR J IN 1..L_INSTRUCTION_TYPE.COUNT LOOP
					IF (L_INSTRUCTION_TYPE(J) = l_lookup_code) THEN
						L_EXIST_INSTR_TYPE := TRUE;
					END IF;
				END LOOP;

				IF (NOT L_EXIST_INSTR_TYPE) THEN
					L_COUNT := L_COUNT + 1;
					L_INSTRUCTION_TYPE.extend;
					L_INSTRUCTION_TYPE(L_COUNT) := L_LOOKUP_CODE;
				END IF;
			END IF;

		END LOOP;

		CLOSE L_CSR_GET_INSTR_TYPES;

    END LOOP;

    CREATE_DEFN_CONTEXT
    (
		P_CURR_INSTR_PROCESS_ID => P_CURR_INSTR_PROCESS_ID,
		P_ENTITY_NAME           => L_ENTITY_NAME,
		P_ENTITY_KEY            => L_ENTITY_KEY,
		P_ENTITY_DISPLAYNAME    => L_ENTITY_DISPLAYNAME,
		P_INSTRUCTION_TYPE      => L_INSTRUCTION_TYPE,
		P_CONTEXT_PARAMETERS    => L_CONTEXT_PARAMETERS,
		X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
		X_RETURN_STATUS          => X_RETURN_STATUS,
		X_MSG_COUNT              => X_MSG_COUNT,
		X_MSG_DATA               => X_MSG_DATA
    );

    -- update the definition status as modified and process status sucess
    SET_INSTR_STATUS_ATTRIBUTES(P_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
                                P_UPDATE_DEFN_STATUS => FND_API.G_TRUE);

    --Delete the contents of Temp Table for the specified process ID.
    DELETE FROM GMO_INSTR_APPR_DEFN_T WHERE INSTRUCTION_PROCESS_ID = X_INSTRUCTION_PROCESS_ID;
    DELETE FROM GMO_INSTR_DEFN_T WHERE INSTRUCTION_PROCESS_ID = X_INSTRUCTION_PROCESS_ID;
    DELETE FROM GMO_INSTR_SET_DEFN_T WHERE INSTRUCTION_PROCESS_ID = X_INSTRUCTION_PROCESS_ID;

    -- COMMIT CHANGES
    COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT', SQLERRM);
		FND_MESSAGE.SET_TOKEN('PKG_NAME',G_PKG_NAME);
		FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',L_API_NAME);
		FND_MSG_PUB.ADD;

		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

		IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
			'gmo.plsql.GMO_INSTRUCTION_PVT.DELETE_ENTITY_FOR_PROCESS',FALSE);

		END IF;

END DELETE_ENTITY_FOR_PROCESS;

-- This API is called to create a definition from existing
-- definition. It is called by the entity application to create
-- a new definition from existing ones

PROCEDURE CREATE_DEFN_FROM_DEFN
(
    P_SOURCE_ENTITY_NAME   IN VARCHAR2,
    P_SOURCE_ENTITY_KEY    IN VARCHAR2,
    P_TARGET_ENTITY_NAME   IN VARCHAR2,
    P_TARGET_ENTITY_KEY    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    X_INSTRUCTION_SET_ID    OUT NOCOPY NUMBER,
    X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY NUMBER,
    X_MSG_DATA             OUT NOCOPY VARCHAR2
)
IS
    L_INSTRUCTION_ID NUMBER;
    L_INSTRUCTION_SET_ID NUMBER;

    L_NEW_INSTRUCTION_ID NUMBER;
    L_NEW_INSTRUCTION_SET_ID NUMBER;

    CURSOR L_INSTR_SET_DEFN_CSR IS
    SELECT INSTRUCTION_SET_ID, INSTRUCTION_TYPE,
           ENTITY_NAME, ENTITY_KEY, INSTR_SET_NAME,
           INSTR_SET_DESC, ACKN_STATUS
    FROM GMO_INSTR_SET_DEFN_VL
    WHERE
          ENTITY_NAME = P_SOURCE_ENTITY_NAME
    AND   ENTITY_KEY = P_SOURCE_ENTITY_KEY
    AND   INSTRUCTION_TYPE = P_INSTRUCTION_TYPE;

    CURSOR L_INSTR_DEFN_CSR IS
    SELECT INSTRUCTION_ID, INSTRUCTION_SET_ID,
           INSTR_SEQ, TASK_ID, TASK_ATTRIBUTE_ID,
           TASK_ATTRIBUTE, INSTR_ACKN_TYPE, INSTR_NUMBER,
           INSTRUCTION_TEXT, TASK_LABEL
    FROM GMO_INSTR_DEFN_VL
    WHERE
          INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    CURSOR L_INSTR_APPR_DEFN_CSR IS
    SELECT INSTRUCTION_ID, APPROVER_SEQ,
           ROLE_COUNT, ROLE_NAME
    FROM GMO_INSTR_APPR_DEFN
    WHERE
          INSTRUCTION_ID = L_INSTRUCTION_ID;

    L_INSTR_SET_DEFN_REC L_INSTR_SET_DEFN_CSR%ROWTYPE;
    L_INSTR_DEFN_REC L_INSTR_DEFN_CSR%ROWTYPE;
    L_INSTR_APPR_DEFN_REC L_INSTR_APPR_DEFN_CSR%ROWTYPE;

    L_SOURCE_ENTITY_ERR EXCEPTION;
    L_TARGET_ENTITY_ERR EXCEPTION;

    L_SOURCE_ENTITY_NOT_FOUND_ERR EXCEPTION;
    L_SOURCE_COUNT NUMBER;

    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

    L_TARGET_INSTRUCTION_SET_ID NUMBER;

    l_entity_task_id number;
    l_new_task_attribute_id varchar2(4000);

BEGIN

    L_API_NAME := 'CREATE_DEFN_FROM_DEFN';

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    IF ((P_SOURCE_ENTITY_NAME IS NULL) OR (P_SOURCE_ENTITY_KEY IS NULL)
        OR (P_INSTRUCTION_TYPE IS NULL )) THEN
        RAISE L_SOURCE_ENTITY_ERR;
    END IF;

    IF ((P_TARGET_ENTITY_NAME IS NULL) OR (P_TARGET_ENTITY_KEY IS NULL)) THEN
        RAISE L_TARGET_ENTITY_ERR;
    END IF;

    BEGIN
       SELECT INSTRUCTION_SET_ID INTO L_TARGET_INSTRUCTION_SET_ID
       FROM GMO_INSTR_SET_DEFN_VL
       WHERE ENTITY_NAME = P_SOURCE_ENTITY_NAME
       AND ENTITY_KEY = P_TARGET_ENTITY_KEY
       AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           L_TARGET_INSTRUCTION_SET_ID := 0;
    END;

    IF (L_TARGET_INSTRUCTION_SET_ID > 0) THEN
       X_INSTRUCTION_SET_ID := L_TARGET_INSTRUCTION_SET_ID;
       X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
       RETURN;
    END IF;

    OPEN L_INSTR_SET_DEFN_CSR;
    FETCH L_INSTR_SET_DEFN_CSR INTO L_INSTR_SET_DEFN_REC;

    IF(L_INSTR_SET_DEFN_CSR%ROWCOUNT > 0) THEN
       L_SOURCE_COUNT := 1;

       SELECT  GMO_INSTR_SET_DEFN_S.NEXTVAL INTO L_NEW_INSTRUCTION_SET_ID FROM DUAL;

       X_INSTRUCTION_SET_ID := L_NEW_INSTRUCTION_SET_ID;

       INSERT INTO GMO_INSTR_SET_DEFN_VL
       (
            INSTRUCTION_SET_ID,
            INSTRUCTION_TYPE,
            INSTR_SET_NAME,
            INSTR_SET_DESC,
            ENTITY_NAME,
            ENTITY_KEY,
            ACKN_STATUS,
            ORIG_SOURCE,
            ORIG_SOURCE_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
       )
       VALUES
       (
            L_NEW_INSTRUCTION_SET_ID,
            P_INSTRUCTION_TYPE,
            L_INSTR_SET_DEFN_REC.INSTR_SET_NAME,
            L_INSTR_SET_DEFN_REC.INSTR_SET_DESC,
            P_TARGET_ENTITY_NAME,
            P_TARGET_ENTITY_KEY,
            GMO_CONSTANTS_GRP.G_INSTR_SET_ACKN_STATUS,
            GMO_CONSTANTS_GRP.G_ORIG_SOURCE_DEFN,
            L_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
            L_CREATION_DATE,
            L_CREATED_BY,
            L_LAST_UPDATE_DATE,
            L_LAST_UPDATED_BY,
            L_LAST_UPDATE_LOGIN
       );

        --Also copy attachments related to this Instruction set id
        FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_B_ENTITY,
                                                X_from_pk1_value => L_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_B_ENTITY,
                                                X_to_pk1_value => L_NEW_INSTRUCTION_SET_ID,
                                                X_to_pk2_value => NULL,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
                                              );

          L_INSTRUCTION_SET_ID := L_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID;

          OPEN L_INSTR_DEFN_CSR;
          LOOP
          FETCH L_INSTR_DEFN_CSR INTO L_INSTR_DEFN_REC;
	  EXIT WHEN L_INSTR_DEFN_CSR%NOTFOUND;

              SELECT GMO_INSTR_DEFN_S.NEXTVAL INTO L_NEW_INSTRUCTION_ID FROM DUAL;

	      -- get the correct task id for the new entity name and entity key
 	      l_entity_task_id := null;
	      if (L_INSTR_DEFN_REC.TASK_ID is not null) then

		select task_id into l_entity_task_id from gmo_instr_task_defn_vl
		where entity_name = P_TARGET_ENTITY_NAME
		and GMO_INSTR_ENTITY_PVT.GET_ENTITYKEY_SEPARATOR_COUNT(entity_key_pattern) = GMO_INSTR_ENTITY_PVT.GET_ENTITYKEY_SEPARATOR_COUNT(P_TARGET_ENTITY_KEY)
		and instruction_type = P_INSTRUCTION_TYPE
		and task_name = (select task_name from gmo_instr_task_defn_b where task_id = L_INSTR_DEFN_REC.TASK_ID);

	      end if;
	      l_new_task_attribute_id := '';
	      if (L_INSTR_DEFN_REC.TASK_ATTRIBUTE_ID is not null) then
			l_new_task_attribute_id := GMO_INSTR_ENTITY_PVT.GET_TARGET_TASK_ATTRIBUTE (
                                                                P_ENTITY_NAME => P_SOURCE_ENTITY_NAME,
                                                                P_SOURCE_ENTITY_KEY => P_SOURCE_ENTITY_KEY,
                                                                P_TARGET_ENTITY_KEY => P_TARGET_ENTITY_KEY,
                                                                P_TASK_ID => l_entity_task_id,
                                                                P_TASK_ATTRIBUTE_ID => L_INSTR_DEFN_REC.TASK_ATTRIBUTE_ID
							);
	      end if;

              INSERT INTO GMO_INSTR_DEFN_VL
              (
                 INSTRUCTION_ID,
                 INSTRUCTION_SET_ID,
                 INSTR_SEQ,
                 TASK_ID,
		 TASK_LABEL,
                 TASK_ATTRIBUTE_ID,
                 TASK_ATTRIBUTE,
                 INSTR_ACKN_TYPE,
                 INSTR_NUMBER,
                 INSTRUCTION_TEXT,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN
              )
              VALUES
              (
                 L_NEW_INSTRUCTION_ID,
                 X_INSTRUCTION_SET_ID,
                 L_INSTR_DEFN_REC.INSTR_SEQ,
                 l_entity_task_id,
		 L_INSTR_DEFN_REC.TASK_LABEL,
                 l_new_task_attribute_id,
                 L_INSTR_DEFN_REC.TASK_ATTRIBUTE,
                 L_INSTR_DEFN_REC.INSTR_ACKN_TYPE,
                 L_INSTR_DEFN_REC.INSTR_NUMBER,
                 L_INSTR_DEFN_REC.INSTRUCTION_TEXT,
                 L_CREATION_DATE,
                 L_CREATED_BY,
                 L_LAST_UPDATE_DATE,
                 L_LAST_UPDATED_BY,
                 L_LAST_UPDATE_LOGIN
              );

              --Also copy attachments related to this Instruction Id
              FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_B_ENTITY,
                                                X_from_pk1_value => L_INSTR_DEFN_REC.INSTRUCTION_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_B_ENTITY,
                                                X_to_pk1_value => L_NEW_INSTRUCTION_ID,
                                                X_to_pk2_value => NULL,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
                                        );

              L_INSTRUCTION_ID := L_INSTR_DEFN_REC.INSTRUCTION_ID;

              OPEN L_INSTR_APPR_DEFN_CSR;
              LOOP
                 FETCH  L_INSTR_APPR_DEFN_CSR INTO L_INSTR_APPR_DEFN_REC;
                 EXIT WHEN L_INSTR_APPR_DEFN_CSR%NOTFOUND;

                 INSERT INTO GMO_INSTR_APPR_DEFN
                 (
                    INSTRUCTION_ID,
                    APPROVER_SEQ,
                    ROLE_COUNT,
                    ROLE_NAME,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN

                 )
                 VALUES
                 (
                    L_NEW_INSTRUCTION_ID,
                    L_INSTR_APPR_DEFN_REC.APPROVER_SEQ,
                    L_INSTR_APPR_DEFN_REC.ROLE_COUNT,
                    L_INSTR_APPR_DEFN_REC.ROLE_NAME,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_LAST_UPDATE_LOGIN

                 );

              END LOOP;
              CLOSE L_INSTR_APPR_DEFN_CSR;

         END LOOP;
         CLOSE L_INSTR_DEFN_CSR;

      CLOSE L_INSTR_SET_DEFN_CSR;

    END IF;


    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN L_SOURCE_ENTITY_ERR THEN
	X_INSTRUCTION_SET_ID := -1;

	FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SOURCE_ENTITY_ER');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME);
        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        (   G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_DEFN_FROM_DEFN',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN L_TARGET_ENTITY_ERR THEN
        X_INSTRUCTION_SET_ID := -1;

        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_TARGET_ENTITY_ER');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME);
        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        (   G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_DEFN_FROM_DEFN',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        X_INSTRUCTION_SET_ID := -1;

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_DEFN_FROM_DEFN',
                 FALSE);
        END IF;

	X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END CREATE_DEFN_FROM_DEFN;

-- This API is called to send the acknowledegement of definition
-- process, and copies all the data from temporary tables
-- back to permenant tables
PROCEDURE SEND_DEFN_ACKN
(
    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN FND_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTRUCTION_ID NUMBER;

    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_INSTRUCTION_TYPE_ARR FND_TABLE_OF_VARCHAR2_255;
    L_CNT NUMBER;

    L_ENTITY_NAME VARCHAR2(200);
    L_SOURCE_ENTITY_KEY VARCHAR2(1000);
    L_TARGET_ENTITY_KEY VARCHAR2(1000);
    L_INSTRUCTION_TYPE VARCHAR2(40);

    L_INSTR_SET_COUNT NUMBER;
    L_INSTR_COUNT NUMBER;
    L_INSTR_APPR_COUNT NUMBER;
    L_PNTR NUMBER;
    L_IN_ENTITY_NAME VARCHAR2(200);
    L_IN_ENTITY_KEY  VARCHAR2(1000);

    CURSOR L_TEMP_INSTR_SET_DEFN_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, INSTRUCTION_SET_ID,
           INSTRUCTION_TYPE,
           ENTITY_NAME, ENTITY_KEY, INSTR_SET_NAME,
           INSTR_SET_DESC, CREATION_DATE,
           LAST_UPDATE_DATE, CREATED_BY, LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
    FROM GMO_INSTR_SET_DEFN_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND ENTITY_NAME = L_ENTITY_NAME
    AND ENTITY_KEY = L_TARGET_ENTITY_KEY
    AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;

    CURSOR L_TEMP_INSTR_DEFN_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, INSTRUCTION_ID, INSTRUCTION_SET_ID,
           INSTRUCTION_TEXT, INSTR_SEQ, TASK_ID, TASK_ATTRIBUTE_ID,
           TASK_ATTRIBUTE, INSTR_ACKN_TYPE, INSTR_NUMBER, CREATION_DATE,
           CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, TASK_LABEL
    FROM GMO_INSTR_DEFN_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
    ORDER BY INSTR_SEQ, INSTRUCTION_ID;

    CURSOR L_TEMP_INSTR_APPR_DEFN_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, INSTRUCTION_ID, APPROVER_SEQ,
           ROLE_COUNT, ROLE_NAME, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
           LAST_UPDATED_BY, LAST_UPDATE_LOGIN
    FROM GMO_INSTR_APPR_DEFN_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND   INSTRUCTION_ID = L_INSTRUCTION_ID;

    CURSOR L_TEMP_ENTITY_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, ATTRIBUTE_SEQ,
           ATTRIBUTE_NAME, ATTRIBUTE_VALUE,
           ENTITY_NAME, ENTITY_KEY, ENTITY_DISPLAY_NAME, INSTRUCTION_TYPE,
           CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
    FROM GMO_INSTR_ATTRIBUTES_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY
    ORDER BY ATTRIBUTE_SEQ;

    CURSOR L_TEMP_IN_ENTITY_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, ATTRIBUTE_SEQ,
           ATTRIBUTE_NAME, ATTRIBUTE_VALUE,
           ENTITY_NAME, ENTITY_KEY, ENTITY_DISPLAY_NAME, INSTRUCTION_TYPE,
           CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
    FROM GMO_INSTR_ATTRIBUTES_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY
    AND ENTITY_NAME = L_IN_ENTITY_NAME
    AND ENTITY_KEY = L_IN_ENTITY_KEY;

    L_TEMP_INSTR_SET_DEFN_REC L_TEMP_INSTR_SET_DEFN_CSR%ROWTYPE;
    L_TEMP_INSTR_DEFN_REC L_TEMP_INSTR_DEFN_CSR%ROWTYPE;
    L_TEMP_INSTR_APPR_DEFN_REC L_TEMP_INSTR_APPR_DEFN_CSR%ROWTYPE;
    L_TEMP_ENTITY_REC L_TEMP_ENTITY_CSR%ROWTYPE;

    L_ENTITY_NAME_ARR FND_TABLE_OF_VARCHAR2_255;
    L_SOURCE_ENTITY_KEY_ARR FND_TABLE_OF_VARCHAR2_255;
    L_TARGET_ENTITY_KEY_ARR FND_TABLE_OF_VARCHAR2_255;
    L_INSTRUCTION_TYPES FND_TABLE_OF_VARCHAR2_255;

    L_ENTITY_INFO_NOTFOUND_ERR EXCEPTION;
    L_INSTR_SEQ_COUNT NUMBER;

    L_DEFINITION_STATUS VARCHAR2(100);
    L_DEL_INSTR_SET_ID NUMBER;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

    L_ENTITY_COUNT_P NUMBER;
    L_ENTITY_COUNT_T NUMBER;
    L_PERM_INSTRUCTION_SET_ID NUMBER;
    L_TEMP_INSTRUCTION_SET_ID NUMBER;

    L_TEMP_INSTR_ID NUMBER;
    L_PERM_INSTR_ID NUMBER;
    L_TEMP_INSTR_SEQ NUMBER;

    CURSOR L_TEMP_INSTR_CHK_CSR IS
    SELECT INSTRUCTION_ID, INSTR_SEQ INTO L_TEMP_INSTR_ID, L_TEMP_INSTR_SEQ FROM GMO_INSTR_DEFN_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND  INSTRUCTION_SET_ID = L_PERM_INSTRUCTION_SET_ID
    ORDER BY INSTR_SEQ ;


BEGIN
	 L_API_NAME := 'SEND_DEFN_ACKN';

	 -- Validate definition
	SELECT ATTRIBUTE_VALUE INTO L_DEFINITION_STATUS	FROM GMO_INSTR_ATTRIBUTES_T
	WHERE ATTRIBUTE_NAME  = 'DEFINITION_STATUS'	AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID AND ATTRIBUTE_TYPE = 'INTERNAL';


	 -- Perform all the processing only if the definition status is
	 -- modified.
	 IF( L_DEFINITION_STATUS <> GMO_CONSTANTS_GRP.G_STATUS_MODIFIED) THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
		RETURN;
	 END IF;

	-- If P_SOURCE_ENTITY_NAME and P_SOURCE_ENTITY_KEY is null,
	-- Then construct it from GMO_INSTR_ATTRIBUTES_T table by querying
	-- entity name, entity key and instruction type values

	L_SOURCE_ENTITY_KEY_ARR := FND_TABLE_OF_VARCHAR2_255();
	L_INSTRUCTION_TYPE_ARR := FND_TABLE_OF_VARCHAR2_255();
	L_ENTITY_NAME_ARR := FND_TABLE_OF_VARCHAR2_255();
	L_TARGET_ENTITY_KEY_ARR := FND_TABLE_OF_VARCHAR2_255();

	-- check if entity information is passed or not
	-- if passed used the entity key else use the information from the
	-- temp table.
	IF(P_ENTITY_NAME IS NULL OR (P_ENTITY_NAME IS NOT NULL AND P_ENTITY_NAME.COUNT <= 0)) THEN
		OPEN L_TEMP_ENTITY_CSR;
		L_CNT := 0;
		LOOP
            	FETCH L_TEMP_ENTITY_CSR INTO L_TEMP_ENTITY_REC;
	    	EXIT WHEN L_TEMP_ENTITY_CSR%NOTFOUND;
	            	L_CNT := L_CNT + 1;

            		L_INSTRUCTION_TYPE_ARR.EXTEND;
            		L_INSTRUCTION_TYPE_ARR(L_CNT) := L_TEMP_ENTITY_REC.INSTRUCTION_TYPE;
         		L_ENTITY_NAME_ARR.EXTEND;
	       		L_ENTITY_NAME_ARR(L_CNT) := L_TEMP_ENTITY_REC.ENTITY_NAME;
	        	L_SOURCE_ENTITY_KEY_ARR.EXTEND;
       	        	L_SOURCE_ENTITY_KEY_ARR(L_CNT) := L_TEMP_ENTITY_REC.ENTITY_KEY;

			L_TARGET_ENTITY_KEY_ARR.EXTEND;
			L_TARGET_ENTITY_KEY_ARR(L_CNT) := L_TEMP_ENTITY_REC.ENTITY_KEY;

		END LOOP;

		CLOSE L_TEMP_ENTITY_CSR;
	ELSE
		L_CNT := 0;
		FOR I IN 1..P_ENTITY_NAME.COUNT LOOP
			L_IN_ENTITY_NAME := P_ENTITY_NAME(I);
			L_IN_ENTITY_KEY := P_SOURCE_ENTITY_KEY (I);

			OPEN L_TEMP_IN_ENTITY_CSR;
			LOOP
			FETCH L_TEMP_IN_ENTITY_CSR INTO L_TEMP_ENTITY_REC;
			EXIT WHEN L_TEMP_IN_ENTITY_CSR%NOTFOUND;

				L_CNT := L_CNT + 1;

				L_INSTRUCTION_TYPE_ARR.EXTEND;
				L_INSTRUCTION_TYPE_ARR(L_CNT) := L_TEMP_ENTITY_REC.INSTRUCTION_TYPE;

				L_ENTITY_NAME_ARR.EXTEND;
				L_ENTITY_NAME_ARR(L_CNT) := L_IN_ENTITY_NAME;
				L_SOURCE_ENTITY_KEY_ARR.EXTEND;
				L_SOURCE_ENTITY_KEY_ARR(L_CNT) := L_IN_ENTITY_KEY;

				L_TARGET_ENTITY_KEY_ARR.EXTEND;
				L_TARGET_ENTITY_KEY_ARR(L_CNT) := L_IN_ENTITY_KEY;
				-- If target entity key is passed, set target entity key to parameter
                		-- passed value, else target entity key is same as source entity key
		                IF(P_TARGET_ENTITY_KEY IS NOT NULL AND P_TARGET_ENTITY_KEY.COUNT > 0 AND P_TARGET_ENTITY_KEY(I) IS NOT NULL ) THEN
					L_TARGET_ENTITY_KEY_ARR(L_CNT) := P_TARGET_ENTITY_KEY(I);
				END IF;
			END LOOP;
			CLOSE L_TEMP_IN_ENTITY_CSR;
		END LOOP;
	END IF;

    -- If the count is zero, raise exception
    IF (L_CNT = 0) THEN
           RAISE L_ENTITY_INFO_NOTFOUND_ERR;
    END IF;

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );


    -- For every entity do the acknowledgement ,
    -- by copying the details from temporary tables to permenant

    FOR I IN 1..L_ENTITY_NAME_ARR.COUNT LOOP


        -- This is comma seperated set of instruction types
        L_INSTRUCTION_TYPE := L_INSTRUCTION_TYPE_ARR(I);
        L_INSTRUCTION_TYPES := FND_TABLE_OF_VARCHAR2_255();
        L_INSTRUCTION_TYPES.EXTEND;

		--Instruction Types must be a comma seperated String value
        IF(INSTR(L_INSTRUCTION_TYPE,',') > 0) THEN
			L_PNTR := 1;

			LOOP
				L_INSTRUCTION_TYPES(L_PNTR) := SUBSTR(l_instruction_type,1, instr(l_instruction_type,',') -1);
				L_INSTRUCTION_TYPES.EXTEND;
				L_INSTRUCTION_TYPE := SUBSTR(l_instruction_type, instr(l_instruction_type,',') +1);
				L_PNTR := L_PNTR + 1;

				IF(INSTR(L_INSTRUCTION_TYPE,',') = 0 AND LENGTH(L_INSTRUCTION_TYPE) > 0) THEN
					L_INSTRUCTION_TYPES.EXTEND;
					L_INSTRUCTION_TYPES(L_PNTR) := L_INSTRUCTION_TYPE;
				END IF;

			EXIT WHEN LENGTH(L_INSTRUCTION_TYPE) = 0 OR INSTR(L_INSTRUCTION_TYPE,',') = 0 ;
			END LOOP;

        ELSE
             L_INSTRUCTION_TYPES(1) := l_INSTRUCTION_TYPE;
        END IF;

       L_ENTITY_NAME := L_ENTITY_NAME_ARR(I);
       L_SOURCE_ENTITY_KEY := L_SOURCE_ENTITY_KEY_ARR(I);
       L_TARGET_ENTITY_KEY := L_TARGET_ENTITY_KEY_ARR(I);


       -- For each Instruction Type for the entity loop.
       FOR J IN 1..L_INSTRUCTION_TYPES.COUNT LOOP

			L_INSTRUCTION_TYPE := L_INSTRUCTION_TYPES(J);


			-- if the target entity keys have changed
			-- update the temp table with the data,
			-- so that the movement from temp to permanent is
			-- to the correct set of rows
			IF (L_SOURCE_ENTITY_KEY <> L_TARGET_ENTITY_KEY) THEN

				UPDATE GMO_INSTR_SET_DEFN_T
				SET ENTITY_KEY = L_TARGET_ENTITY_KEY
				WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
				AND ENTITY_NAME = L_ENTITY_NAME
				AND ENTITY_KEY = L_SOURCE_ENTITY_KEY
				AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;


				UPDATE GMO_INSTR_ATTRIBUTES_T
				SET ENTITY_KEY = L_TARGET_ENTITY_KEY
				WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
				AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PARAM_ENTITY
				AND ENTITY_NAME = L_ENTITY_NAME
				AND ENTITY_KEY = L_SOURCE_ENTITY_KEY
				AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;

				BEGIN

					L_PERM_INSTRUCTION_SET_ID := -1;
					L_TEMP_INSTRUCTION_SET_ID := -1;

					SELECT INSTRUCTION_SET_ID INTO L_PERM_INSTRUCTION_SET_ID FROM GMO_INSTR_SET_DEFN_B
					WHERE ENTITY_NAME = L_ENTITY_NAME AND ENTITY_KEY = L_TARGET_ENTITY_KEY AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;

					SELECT INSTRUCTION_SET_ID INTO L_TEMP_INSTRUCTION_SET_ID FROM GMO_INSTR_SET_DEFN_T
					WHERE ENTITY_NAME = L_ENTITY_NAME AND ENTITY_KEY = L_TARGET_ENTITY_KEY AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE
					AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

					UPDATE GMO_INSTR_SET_DEFN_T
					SET INSTRUCTION_SET_ID = L_PERM_INSTRUCTION_SET_ID
					WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
					AND ENTITY_NAME = L_ENTITY_NAME
					AND ENTITY_KEY = L_TARGET_ENTITY_KEY
					AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;

					UPDATE GMO_INSTR_DEFN_T
					SET INSTRUCTION_SET_ID = L_PERM_INSTRUCTION_SET_ID
					WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
					AND INSTRUCTION_SET_ID = L_TEMP_INSTRUCTION_SET_ID;

					--Bug 5020834: start
					--When the target entity is different the instruction id needs to be updated, after instruction
					--set id update, to ensure the correct values get updated in the permanent for the new entity.
					OPEN L_TEMP_INSTR_CHK_CSR;
					LOOP
					FETCH L_TEMP_INSTR_CHK_CSR INTO L_TEMP_INSTR_ID,L_TEMP_INSTR_SEQ;
					EXIT WHEN L_TEMP_INSTR_CHK_CSR%NOTFOUND;
						begin
							SELECT INSTRUCTION_ID INTO L_PERM_INSTR_ID FROM GMO_INSTR_DEFN_B
							WHERE INSTRUCTION_SET_ID = L_PERM_INSTRUCTION_SET_ID AND INSTR_SEQ = L_TEMP_INSTR_SEQ;
						exception
							when no_data_found then
								SELECT GMO_INSTR_DEFN_S.NEXTVAL INTO L_PERM_INSTR_ID FROM DUAL;
						end;
						update gmo_instr_defn_t set instruction_id = L_PERM_INSTR_ID where instruction_id = l_temp_instr_id;
						update gmo_instr_appr_defn_t set instruction_id = L_PERM_INSTR_ID where instruction_id = l_temp_instr_id;
					END LOOP;
					CLOSE L_TEMP_INSTR_CHK_CSR;
					--Bug 5020834: end
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						NULL;
				END;
				--Bug 5203096: start
				--we may need to update the task attribute if entity key changes
                                --the below api takes care
				GMO_INSTR_ENTITY_PVT.UPDATE_TASK_ATTRIBUTE
				(
					P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
					P_INSTRUCTION_SET_ID => L_PERM_INSTRUCTION_SET_ID,
					P_ENTITY_NAME => L_ENTITY_NAME,
					P_SOURCE_ENTITY_KEY => L_SOURCE_ENTITY_KEY,
					P_TARGET_ENTITY_KEY => L_TARGET_ENTITY_KEY
				);
				--Bug 5203096: end
			END IF;

			OPEN L_TEMP_INSTR_SET_DEFN_CSR;

			LOOP
			FETCH L_TEMP_INSTR_SET_DEFN_CSR INTO L_TEMP_INSTR_SET_DEFN_REC;
			EXIT WHEN L_TEMP_INSTR_SET_DEFN_CSR%NOTFOUND;

				L_INSTR_SET_COUNT := 0;

				SELECT COUNT(*) INTO L_INSTR_SET_COUNT FROM GMO_INSTR_SET_DEFN_B
				WHERE INSTRUCTION_SET_ID = L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID;

				-- If Instruction Set is already present in permenant table then update
				-- it with data from temporary table record
				IF (L_INSTR_SET_COUNT > 0 ) THEN
					--Bug 5224619: start
					UPDATE GMO_INSTR_SET_DEFN_B SET
						INSTR_SET_NAME = L_TEMP_INSTR_SET_DEFN_REC.INSTR_SET_NAME,
						ACKN_STATUS = GMO_CONSTANTS_GRP.G_INSTR_SET_ACKN_STATUS,
						LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
						LAST_UPDATED_BY = L_LAST_UPDATED_BY ,
						LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
					WHERE INSTRUCTION_SET_ID = L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID;

					UPDATE GMO_INSTR_SET_DEFN_TL SET
						INSTR_SET_DESC = L_TEMP_INSTR_SET_DEFN_REC.INSTR_SET_DESC,
						LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
						LAST_UPDATED_BY = L_LAST_UPDATED_BY ,
						LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
					WHERE INSTRUCTION_SET_ID = L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID;
					--Bug 5224619: end

				ELSE
					INSERT INTO GMO_INSTR_SET_DEFN_VL
					(
						 INSTRUCTION_SET_ID,
						 INSTRUCTION_TYPE,
						 INSTR_SET_NAME,
						 INSTR_SET_DESC,
						 ENTITY_NAME,
						 ENTITY_KEY,
						 ACKN_STATUS,
						 CREATION_DATE,
						 CREATED_BY,
						 LAST_UPDATE_DATE,
						 LAST_UPDATED_BY,
						 LAST_UPDATE_LOGIN
					)
					VALUES
					(
						 L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
						 L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_TYPE,
						 L_TEMP_INSTR_SET_DEFN_REC.INSTR_SET_NAME,
						 L_TEMP_INSTR_SET_DEFN_REC.INSTR_SET_DESC,
						 L_TEMP_INSTR_SET_DEFN_REC.ENTITY_NAME,
						 L_TARGET_ENTITY_KEY,
						 GMO_CONSTANTS_GRP.G_INSTR_SET_ACKN_STATUS,
						 L_CREATION_DATE,
						 L_CREATED_BY,
						 L_LAST_UPDATE_DATE,
						 L_LAST_UPDATED_BY,
						 L_LAST_UPDATE_LOGIN
					);
				END IF;


				-- Delete Attachments from permenant ENTITY, and copy them back from temporary ENTITY
				FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
					X_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_B_ENTITY,
					X_pk1_value => L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
					X_pk2_value => NULL,
					X_pk3_value => NULL,
					X_pk4_value => NULL,
					X_pk5_value => NULL,
					X_delete_document_flag => GMO_CONSTANTS_GRP.NO,
					X_automatically_added_flag => NULL);

				FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
					X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_T_ENTITY,
					X_from_pk1_value => L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
					X_from_pk2_value => P_INSTRUCTION_PROCESS_ID,
					X_from_pk3_value => NULL,
					X_from_pk4_value => NULL,
					X_from_pk5_value => NULL,
					X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_B_ENTITY,
					X_to_pk1_value => L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
					X_to_pk2_value => NULL,
					X_to_pk3_value => NULL,
					X_to_pk4_value => NULL,
					X_to_pk5_value => NULL,
					X_created_by => L_CREATED_BY,
					X_last_update_login => L_LAST_UPDATE_LOGIN,
					X_program_application_id => NULL,
					X_program_id => NULL,
					X_request_id => NULL,
					X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
					X_from_category_id => NULL,
					X_to_category_id => NULL );

				-- Delete Attachments from Temporary ENTITY now
				FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
					X_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_T_ENTITY,
					X_pk1_value => L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
					X_pk2_value => P_INSTRUCTION_PROCESS_ID,
					X_pk3_value => NULL,
					X_pk4_value => NULL,
					X_pk5_value => NULL,
					X_delete_document_flag => GMO_CONSTANTS_GRP.NO,
					X_automatically_added_flag => NULL);


				L_INSTRUCTION_SET_ID := L_TEMP_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID;
				L_INSTR_SEQ_COUNT := 0;

				OPEN L_TEMP_INSTR_DEFN_CSR;
				LOOP
				FETCH L_TEMP_INSTR_DEFN_CSR INTO L_TEMP_INSTR_DEFN_REC;
				EXIT WHEN L_TEMP_INSTR_DEFN_CSR%NOTFOUND;

					L_INSTR_COUNT := 0;

					-- Increment the Instruction Sequence
					L_INSTR_SEQ_COUNT := L_INSTR_SEQ_COUNT + 1;


					-- check if we have the instruction
					-- for that set in the permanent table
					-- if yes update the instruction
					-- else insert it

					SELECT COUNT(*) INTO L_INSTR_COUNT FROM GMO_INSTR_DEFN_B
					WHERE INSTRUCTION_ID = L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID
					AND INSTRUCTION_SET_ID = L_TEMP_INSTR_DEFN_REC.INSTRUCTION_SET_ID;

					IF(L_INSTR_COUNT > 0) THEN
						--Bug 5224619: start
						UPDATE GMO_INSTR_DEFN_B SET
							INSTR_SEQ = L_INSTR_SEQ_COUNT,
							TASK_ID = L_TEMP_INSTR_DEFN_REC.TASK_ID,
							TASK_ATTRIBUTE_ID = L_TEMP_INSTR_DEFN_REC.TASK_ATTRIBUTE_ID,
							TASK_ATTRIBUTE = L_TEMP_INSTR_DEFN_REC.TASK_ATTRIBUTE,
							INSTR_ACKN_TYPE = L_TEMP_INSTR_DEFN_REC.INSTR_ACKN_TYPE,
							INSTR_NUMBER = L_TEMP_INSTR_DEFN_REC.INSTR_NUMBER,
							LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
							LAST_UPDATED_BY = L_LAST_UPDATED_BY,
							LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
						WHERE INSTRUCTION_ID = L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID
						AND INSTRUCTION_SET_ID = L_TEMP_INSTR_DEFN_REC.INSTRUCTION_SET_ID;

						UPDATE GMO_INSTR_DEFN_TL SET
							INSTRUCTION_TEXT = L_TEMP_INSTR_DEFN_REC.INSTRUCTION_TEXT,
							TASK_LABEL = L_TEMP_INSTR_DEFN_REC.TASK_LABEL,
							LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
							LAST_UPDATED_BY = L_LAST_UPDATED_BY,
							LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
						WHERE INSTRUCTION_ID = L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID
						AND LANGUAGE = USERENV('LANG');
						--Bug 5224619: end

					ELSE

						INSERT INTO GMO_INSTR_DEFN_VL
						(
								INSTRUCTION_ID,
								INSTRUCTION_SET_ID,
								INSTR_SEQ,
								TASK_ID,
								TASK_ATTRIBUTE_ID,
								TASK_ATTRIBUTE,
								INSTR_ACKN_TYPE,
								INSTR_NUMBER,
								INSTRUCTION_TEXT,
								CREATION_DATE,
								CREATED_BY,
								LAST_UPDATE_DATE,
								LAST_UPDATED_BY,
								LAST_UPDATE_LOGIN,
								TASK_LABEL
						)
						VALUES
						(
							   L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID,
							   L_TEMP_INSTR_DEFN_REC.INSTRUCTION_SET_ID,
							   L_INSTR_SEQ_COUNT,
							   L_TEMP_INSTR_DEFN_REC.TASK_ID,
							   L_TEMP_INSTR_DEFN_REC.TASK_ATTRIBUTE_ID,
							   L_TEMP_INSTR_DEFN_REC.TASK_ATTRIBUTE,
							   L_TEMP_INSTR_DEFN_REC.INSTR_ACKN_TYPE,
							   L_TEMP_INSTR_DEFN_REC.INSTR_NUMBER,
							   L_TEMP_INSTR_DEFN_REC.INSTRUCTION_TEXT,
							   L_CREATION_DATE,
							   L_CREATED_BY,
							   L_LAST_UPDATE_DATE,
							   L_LAST_UPDATED_BY,
							   L_LAST_UPDATE_LOGIN,
							   L_TEMP_INSTR_DEFN_REC.TASK_LABEL
						);

					END IF;

					-- Delete Attachments from permenant ENTITY, and copy
					-- them back from temporary
					-- ENTITY

					FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments (
						X_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_B_ENTITY,
						X_pk1_value => L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID,
						X_pk2_value => NULL,
						X_pk3_value => NULL,
						X_pk4_value => NULL,
						X_pk5_value => NULL,
						X_delete_document_flag => GMO_CONSTANTS_GRP.NO,
						X_automatically_added_flag => NULL);

					FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
						X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_T_ENTITY,
						X_from_pk1_value => L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID,
						X_from_pk2_value => P_INSTRUCTION_PROCESS_ID,
						X_from_pk3_value => NULL,
						X_from_pk4_value => NULL,
						X_from_pk5_value => NULL,
						X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_B_ENTITY,
						X_to_pk1_value => L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID,
						X_to_pk2_value => NULL,
						X_to_pk3_value => NULL,
						X_to_pk4_value => NULL,
						X_to_pk5_value => NULL,
						X_created_by => L_CREATED_BY,
						X_last_update_login => L_LAST_UPDATE_LOGIN,
						X_program_application_id => NULL,
						X_program_id => NULL,
						X_request_id => NULL,
						X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
						X_from_category_id => NULL,
						X_to_category_id => NULL);

					-- Delete Attachments from Temporary ENTITY now
					FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
						X_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_T_ENTITY,
						X_pk1_value => L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID,
						X_pk2_value => P_INSTRUCTION_PROCESS_ID,
						X_pk3_value => NULL,
						X_pk4_value => NULL,
						X_pk5_value => NULL,
						X_delete_document_flag => GMO_CONSTANTS_GRP.NO,
						X_automatically_added_flag => NULL);


					L_INSTRUCTION_ID := L_TEMP_INSTR_DEFN_REC.INSTRUCTION_ID;

					OPEN L_TEMP_INSTR_APPR_DEFN_CSR;
					LOOP
					FETCH  L_TEMP_INSTR_APPR_DEFN_CSR INTO L_TEMP_INSTR_APPR_DEFN_REC;
					EXIT WHEN L_TEMP_INSTR_APPR_DEFN_CSR%NOTFOUND;

						L_INSTR_APPR_COUNT := 0;

						SELECT COUNT(*) INTO L_INSTR_APPR_COUNT FROM GMO_INSTR_APPR_DEFN
						WHERE INSTRUCTION_ID = L_INSTRUCTION_ID
						AND APPROVER_SEQ = L_TEMP_INSTR_APPR_DEFN_REC.APPROVER_SEQ;

						IF ( L_INSTR_APPR_COUNT > 0) THEN
							UPDATE GMO_INSTR_APPR_DEFN SET
								ROLE_COUNT = L_TEMP_INSTR_APPR_DEFN_REC.ROLE_COUNT,
								ROLE_NAME = L_TEMP_INSTR_APPR_DEFN_REC.ROLE_NAME,
								LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
								LAST_UPDATED_BY = L_LAST_UPDATED_BY,
								LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
							WHERE INSTRUCTION_ID = L_INSTRUCTION_ID
							AND  APPROVER_SEQ = L_TEMP_INSTR_APPR_DEFN_REC.APPROVER_SEQ;
						ELSE
							INSERT INTO GMO_INSTR_APPR_DEFN
							(
								INSTRUCTION_ID,
								APPROVER_SEQ,
								ROLE_COUNT,
								ROLE_NAME,
								CREATION_DATE,
								CREATED_BY,
								LAST_UPDATE_DATE,
								LAST_UPDATED_BY,
								LAST_UPDATE_LOGIN
							)
							VALUES
							(
								L_TEMP_INSTR_APPR_DEFN_REC.INSTRUCTION_ID,
								L_TEMP_INSTR_APPR_DEFN_REC.APPROVER_SEQ,
								L_TEMP_INSTR_APPR_DEFN_REC.ROLE_COUNT,
								L_TEMP_INSTR_APPR_DEFN_REC.ROLE_NAME,
								L_CREATION_DATE,
								L_CREATED_BY,
								L_LAST_UPDATE_DATE,
								L_LAST_UPDATED_BY,
								L_LAST_UPDATE_LOGIN
							);
						END IF;

					END LOOP;
					CLOSE L_TEMP_INSTR_APPR_DEFN_CSR;

                     -- Cleanup deleted approvers from approvers table
					DELETE FROM GMO_INSTR_APPR_DEFN
					WHERE INSTRUCTION_ID = L_INSTRUCTION_ID
					AND APPROVER_SEQ NOT IN
					( SELECT APPROVER_SEQ FROM GMO_INSTR_APPR_DEFN_T WHERE INSTRUCTION_ID = L_INSTRUCTION_ID
						AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID);

				END LOOP;
				CLOSE L_TEMP_INSTR_DEFN_CSR;

				--Cleanup deleted records from instruction table
				--Bug 5224619: start
				DELETE FROM GMO_INSTR_DEFN_TL
				WHERE INSTRUCTION_ID NOT IN
				( SELECT INSTRUCTION_ID FROM GMO_INSTR_DEFN_T WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
					 AND INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID)
				AND INSTRUCTION_ID IN (SELECT INSTRUCTION_ID FROM GMO_INSTR_DEFN_B WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID)
				AND LANGUAGE=USERENV('LANG');

				DELETE FROM GMO_INSTR_DEFN_B
				WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
				AND INSTRUCTION_ID NOT IN
				( SELECT INSTRUCTION_ID FROM GMO_INSTR_DEFN_T WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
					AND INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID);
				--Bug 5224619: end

			END LOOP;
			CLOSE L_TEMP_INSTR_SET_DEFN_CSR;


			--Cleanup deleted records from instruction set table
			-- Count = number of instruction sets in temporary table

			SELECT COUNT(*) INTO L_ENTITY_COUNT_T FROM GMO_INSTR_SET_DEFN_T
			WHERE ENTITY_NAME = L_ENTITY_NAME
			AND ENTITY_KEY = L_TARGET_ENTITY_KEY
			AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE
			AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

			-- Count = number of instruction sets in permanent table
			SELECT COUNT(*) INTO L_ENTITY_COUNT_P FROM GMO_INSTR_SET_DEFN_B
			WHERE ENTITY_NAME = L_ENTITY_NAME
			AND ENTITY_KEY = L_TARGET_ENTITY_KEY
			AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;

			-- If exist in permanent but not in temp, delete from permanent
			IF (L_ENTITY_COUNT_T < L_ENTITY_COUNT_P ) THEN

				SELECT count(*) INTO L_DEL_INSTR_SET_ID
				FROM GMO_INSTR_SET_DEFN_B
				WHERE ENTITY_NAME = L_ENTITY_NAME
				AND ENTITY_KEY =  L_TARGET_ENTITY_KEY
				AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;


				SELECT INSTRUCTION_SET_ID INTO L_DEL_INSTR_SET_ID
				FROM GMO_INSTR_SET_DEFN_B
				WHERE ENTITY_NAME = L_ENTITY_NAME
				AND ENTITY_KEY =  L_TARGET_ENTITY_KEY
				AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;

				-- First delete the approvers
				DELETE FROM GMO_INSTR_APPR_DEFN
				WHERE INSTRUCTION_ID IN
				(SELECT INSTRUCTION_ID FROM GMO_INSTR_DEFN_B
				WHERE INSTRUCTION_SET_ID = L_DEL_INSTR_SET_ID);

				-- Second remove the instructions
				--Bug 5224619: start
				DELETE FROM GMO_INSTR_DEFN_TL WHERE INSTRUCTION_ID IN
				(SELECT INSTRUCTION_ID FROM GMO_INSTR_DEFN_B WHERE INSTRUCTION_SET_ID = L_DEL_INSTR_SET_ID) AND LANGUAGE=USERENV('LANG');

				DELETE FROM GMO_INSTR_DEFN_B
				WHERE INSTRUCTION_SET_ID = L_DEL_INSTR_SET_ID;

				-- Finally remove the instruction set from table
				DELETE FROM GMO_INSTR_SET_DEFN_TL
				WHERE INSTRUCTION_SET_ID IN (SELECT INSTRUCTION_SET_ID FROM GMO_INSTR_SET_DEFN_B WHERE ENTITY_NAME = L_ENTITY_NAME
								AND ENTITY_KEY =  L_TARGET_ENTITY_KEY AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE)
				AND LANGUAGE=USERENV('LANG');

				DELETE FROM GMO_INSTR_SET_DEFN_B
				WHERE ENTITY_NAME = L_ENTITY_NAME
				AND ENTITY_KEY =  L_TARGET_ENTITY_KEY
				AND INSTRUCTION_TYPE = L_INSTRUCTION_TYPE;
				--Bug 5224619: end

             END IF;

		END LOOP; --Instruction Types
	END LOOP; --Entity Name Loop

	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN L_ENTITY_INFO_NOTFOUND_ERR THEN

		FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SOURCE_ENTITY_ER');
		FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
		FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );
		L_MESG_TEXT := FND_MESSAGE.GET();

		FND_MSG_PUB.ADD_EXC_MSG (G_PKG_NAME, L_API_NAME,L_MESG_TEXT );
		FND_MSG_PUB.COUNT_AND_GET (P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA );
		IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.GMO_INSTRUCTIONS_PVT.SEND_DEFN_ACKN',FALSE);
		END IF;

		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
		IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.ADD_EXC_MSG (G_PKG_NAME, L_API_NAME);
		END IF;

		FND_MSG_PUB.COUNT_AND_GET (P_COUNT => X_MSG_COUNT, P_DATA  => X_MSG_DATA);
		IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, 'gmo.plsql.GMO_INSTRUCTION_PVT.SEND_DEFN_ACKN',FALSE);
		END IF;

		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
END SEND_DEFN_ACKN;

-- This API is called to send the acknowledegement of definition
-- process, and copies all the data from temporary tables
-- back to permenant tables
PROCEDURE SEND_DEFN_ACKN
(
    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS
    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_SOURCE_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_TARGET_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;

BEGIN

    L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
    L_SOURCE_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
    L_TARGET_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();

    L_ENTITY_NAME.EXTEND;
    L_SOURCE_ENTITY_KEY.EXTEND;
    L_TARGET_ENTITY_KEY.EXTEND;

    L_ENTITY_NAME(1) := P_ENTITY_NAME;
    L_SOURCE_ENTITY_KEY(1) := P_SOURCE_ENTITY_KEY;
    L_TARGET_ENTITY_KEY(1) := P_TARGET_ENTITY_KEY;

    SEND_DEFN_ACKN
    (
             P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
             P_ENTITY_NAME => L_ENTITY_NAME,
             P_SOURCE_ENTITY_KEY => L_SOURCE_ENTITY_KEY,
             P_TARGET_ENTITY_KEY => L_TARGET_ENTITY_KEY,
             X_RETURN_STATUS => X_RETURN_STATUS,
             X_MSG_COUNT => X_MSG_COUNT,
             X_MSG_DATA => X_MSG_DATA
    );

END SEND_DEFN_ACKN;

-- This API is called to send the acknowledegement of definition
-- process, and copies all the data from temporary tables
-- back to permenant tables
PROCEDURE SEND_DEFN_ACKN
(
    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS

    L_ENTITY_NAME FND_TABLE_OF_VARCHAR2_255;
    L_SOURCE_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;
    L_TARGET_ENTITY_KEY FND_TABLE_OF_VARCHAR2_255;

BEGIN

  L_ENTITY_NAME := FND_TABLE_OF_VARCHAR2_255();
  L_SOURCE_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();
  L_TARGET_ENTITY_KEY := FND_TABLE_OF_VARCHAR2_255();


  FOR I IN 1..P_ENTITY_NAME.COUNT LOOP

    L_ENTITY_NAME.EXTEND;
    L_SOURCE_ENTITY_KEY.EXTEND;
    L_TARGET_ENTITY_KEY.EXTEND;

    L_ENTITY_NAME(I) := P_ENTITY_NAME(I);
    L_SOURCE_ENTITY_KEY(I) := P_SOURCE_ENTITY_KEY(I);
    L_TARGET_ENTITY_KEY(I) := P_TARGET_ENTITY_KEY(I);

  END LOOP;

  BEGIN

        SEND_DEFN_ACKN
        (
            P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
            P_ENTITY_NAME => L_ENTITY_NAME,
            P_SOURCE_ENTITY_KEY => L_SOURCE_ENTITY_KEY,
            P_TARGET_ENTITY_KEY => L_TARGET_ENTITY_KEY,
            X_RETURN_STATUS => X_RETURN_STATUS,
            X_MSG_COUNT => X_MSG_COUNT,
            X_MSG_DATA => X_MSG_DATA
        );

  END;

END SEND_DEFN_ACKN;

-- This API is called to create an instance from the definition
-- It is called to instantiate the instructions from definition tables
-- into runtime, and available in operator workbench

PROCEDURE CREATE_INSTANCE_FROM_DEFN
(
    P_DEFINITION_ENTITY_NAME IN VARCHAR2,
    P_DEFINITION_ENTITY_KEY IN VARCHAR2,
    P_INSTANCE_ENTITY_NAME  IN VARCHAR2,
    P_INSTANCE_ENTITY_KEY   IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,

    X_INSTRUCTION_SET_ID    OUT NOCOPY NUMBER,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2
)
IS

   L_INSTRUCTION_SET_ID NUMBER;
   L_INSTRUCTION_ID NUMBER;
   L_NEW_INSTRUCTION_SET_ID NUMBER;
   L_NEW_INSTRUCTION_ID NUMBER;

   L_CREATION_DATE DATE;
   L_CREATED_BY NUMBER;
   L_LAST_UPDATE_DATE DATE;
   L_LAST_UPDATED_BY NUMBER;
   L_LAST_UPDATE_LOGIN NUMBER;

   CURSOR L_INSTR_SET_DEFN_CSR IS
   SELECT INSTRUCTION_SET_ID, INSTRUCTION_TYPE,
          ENTITY_NAME, ENTITY_KEY, INSTR_SET_NAME,
          INSTR_SET_DESC, ACKN_STATUS
   FROM GMO_INSTR_SET_DEFN_VL
   WHERE
        ENTITY_NAME = P_DEFINITION_ENTITY_NAME
   AND ENTITY_KEY = P_DEFINITION_ENTITY_KEY
   AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
   AND ACKN_STATUS = GMO_CONSTANTS_GRP.G_INSTR_SET_ACKN_STATUS;

   CURSOR L_INSTR_DEFN_CSR IS
   SELECT INSTRUCTION_ID, INSTRUCTION_SET_ID, INSTRUCTION_TEXT,
          INSTR_SEQ, INSTR_NUMBER, INSTR_ACKN_TYPE,
          TASK_LABEL, TASK_ATTRIBUTE, TASK_ATTRIBUTE_ID, TASK_ID
   FROM GMO_INSTR_DEFN_VL
   WHERE
         INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

   CURSOR L_INSTR_APPR_DEFN_CSR IS
   SELECT INSTRUCTION_ID, APPROVER_SEQ, ROLE_COUNT, ROLE_NAME
   FROM GMO_INSTR_APPR_DEFN
   WHERE
          INSTRUCTION_ID = L_INSTRUCTION_ID
   ORDER BY APPROVER_SEQ;

   L_INSTR_SET_DEFN_REC L_INSTR_SET_DEFN_CSR%ROWTYPE;
   L_INSTR_DEFN_REC L_INSTR_DEFN_CSR%ROWTYPE;
   L_INSTR_APPR_DEFN_REC L_INSTR_APPR_DEFN_CSR%ROWTYPE;

   L_INSTANCE_ENTITY_KEY VARCHAR2(500);
   L_DEFN_NOTFOUND_ERR EXCEPTION;

   L_API_NAME VARCHAR2(40);
   L_MESG_TEXT VARCHAR2(1000);

   l_task_label varchar2(200);

BEGIN

     L_API_NAME := 'CREATE_INSTANCE_FROM_DEFN';

     GMO_UTILITIES.GET_WHO_COLUMNS
     (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
     );

     -- If the input parameters are invalid, log a message
     -- and return error status.
     IF(P_DEFINITION_ENTITY_NAME IS NULL
        OR P_DEFINITION_ENTITY_KEY IS NULL
        OR P_INSTANCE_ENTITY_NAME IS NULL
        OR P_INSTRUCTION_TYPE IS NULL ) THEN

        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_CIFD_PARAM_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );
        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        (   G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_INSTANCE_FROM_DEFN',
                 FALSE);
        END IF;

        X_INSTRUCTION_SET_ID := -1;
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

        RETURN;

     END IF;

     -- If Instance entity key is null, create a new instruction set id from sequence
     IF(P_INSTANCE_ENTITY_KEY IS NULL) THEN
         SELECT GMO_INSTR_SET_INSTANCE_S.NEXTVAL INTO L_NEW_INSTRUCTION_SET_ID
         FROM DUAL;
         L_INSTANCE_ENTITY_KEY := GMO_CONSTANTS_GRP.G_INSTR_PREFIX || L_NEW_INSTRUCTION_SET_ID;
      ELSE
          BEGIN
             SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
             FROM GMO_INSTR_SET_INSTANCE_VL
             WHERE
                 ENTITY_NAME = P_INSTANCE_ENTITY_NAME
             AND  nvl(ENTITY_KEY,1) = nvl(P_INSTANCE_ENTITY_KEY,1)
             AND  INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
	     AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 L_INSTRUCTION_SET_ID := 0;
          END;

	  -- If The Instruction Instance Already Exist For The Given
          -- Entity Name And Entity_key, Return The Set Id Of The Active
	  -- Instance Instruction Set Found Above
          IF (L_INSTRUCTION_SET_ID > 0) THEN

	      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
              X_INSTRUCTION_SET_ID := L_INSTRUCTION_SET_ID;

              RETURN;
          END IF;

	  SELECT GMO_INSTR_SET_INSTANCE_S.NEXTVAL INTO L_NEW_INSTRUCTION_SET_ID
          FROM DUAL;

          L_INSTANCE_ENTITY_KEY := P_INSTANCE_ENTITY_KEY;

     END IF;

     -- For instruction set, instruction , approvers copy data from definition
     -- tables to permenant tables
     OPEN L_INSTR_SET_DEFN_CSR;
     LOOP
     FETCH L_INSTR_SET_DEFN_CSR INTO L_INSTR_SET_DEFN_REC;
     EXIT WHEN L_INSTR_SET_DEFN_CSR%NOTFOUND;

         --INSERT DATA FROM DEFN TABLE TO INSTANCE TABLE
         INSERT INTO GMO_INSTR_SET_INSTANCE_VL
         (
               INSTRUCTION_SET_ID,
               INSTRUCTION_TYPE,
               ENTITY_NAME,
               ENTITY_KEY,
               INSTR_SET_NAME,
               INSTR_SET_DESC,
               ACKN_STATUS,
               INSTR_SET_STATUS,
               ORIG_SOURCE,
               ORIG_SOURCE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
        )
        VALUES
        (
               L_NEW_INSTRUCTION_SET_ID,
               L_INSTR_SET_DEFN_REC.INSTRUCTION_TYPE,
               P_INSTANCE_ENTITY_NAME,   -- It must insert instance entity name and key
               L_INSTANCE_ENTITY_KEY,
               L_INSTR_SET_DEFN_REC.INSTR_SET_NAME,
               L_INSTR_SET_DEFN_REC.INSTR_SET_DESC,
               GMO_CONSTANTS_GRP.G_INSTR_SET_UNACKN_STATUS,
               GMO_CONSTANTS_GRP.G_PROCESS_ACTIVE,
               GMO_CONSTANTS_GRP.G_ORIG_SOURCE_DEFN,
               L_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
               L_CREATION_DATE,
               L_CREATED_BY,
               L_LAST_UPDATE_DATE,
               L_LAST_UPDATED_BY,
               L_LAST_UPDATE_LOGIN
        );

        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
                  X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_DEFN_B_ENTITY,
                  X_from_pk1_value => L_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID,
                  X_from_pk2_value => NULL,
                  X_from_pk3_value => NULL,
                  X_from_pk4_value => NULL,
                  X_from_pk5_value => NULL,
                  X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_INSTANCE_B_ENTITY,
                  X_to_pk1_value => L_NEW_INSTRUCTION_SET_ID,
                  X_to_pk2_value => NULL,
                  X_to_pk3_value => NULL,
                  X_to_pk4_value => NULL,
                  X_to_pk5_value => NULL,
                  X_created_by => L_CREATED_BY,
                  X_last_update_login => L_LAST_UPDATE_LOGIN,
                  X_program_application_id => NULL,
                  X_program_id => NULL,
                  X_request_id => NULL,
                  X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                  X_from_category_id => NULL,
                  X_to_category_id => NULL
                );

       L_INSTRUCTION_SET_ID := L_INSTR_SET_DEFN_REC.INSTRUCTION_SET_ID;

       OPEN L_INSTR_DEFN_CSR;
       LOOP
            FETCH L_INSTR_DEFN_CSR INTO L_INSTR_DEFN_REC;
            EXIT WHEN L_INSTR_DEFN_CSR%NOTFOUND;

            SELECT GMO_INSTR_INSTANCE_S.NEXTVAL INTO L_NEW_INSTRUCTION_ID
            FROM DUAL;

	    --Bug 4730261: start
	    --if task id is available, and task label is not available, we
	    --take the task display name and assign to task label.
	    if (L_INSTR_DEFN_REC.TASK_ID is not null and trim(L_INSTR_DEFN_REC.TASK_LABEL) is null ) then
		select display_name into l_task_label from gmo_instr_task_defn_vl where task_id = L_INSTR_DEFN_REC.TASK_ID;
	    else
		l_task_label := L_INSTR_DEFN_REC.TASK_LABEL;
	    end if;
	    --Bug 4730261: end
	    -- INSERT INSTRNS FROM DEFN TABLE TO INSTANCE TABLE
            INSERT INTO  GMO_INSTR_INSTANCE_VL
            (
                INSTRUCTION_ID,
                INSTRUCTION_SET_ID,
                INSTRUCTION_TEXT,
                INSTR_STATUS,
                COMMENTS,
                TASK_LABEL,
                INSTR_NUMBER,
                INSTR_SEQ,
                OPERATOR_ACKN,
                INSTR_ACKN_TYPE,
                TASK_ID,
                TASK_ACKN_DATE,
                TASK_ACKN_STATUS,
                TASK_ATTRIBUTE,
                TASK_ATTRIBUTE_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
            )
            VALUES
            (
                L_NEW_INSTRUCTION_ID,
                L_NEW_INSTRUCTION_SET_ID,
                L_INSTR_DEFN_REC.INSTRUCTION_TEXT,
                GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING,
                NULL,
                l_task_label,
                L_INSTR_DEFN_REC.INSTR_NUMBER,
                L_INSTR_DEFN_REC.INSTR_SEQ,
                GMO_CONSTANTS_GRP.G_INSTR_OPERATOR_ACKN_NO,
                L_INSTR_DEFN_REC.INSTR_ACKN_TYPE,
                L_INSTR_DEFN_REC.TASK_ID,
                NULL,
                DECODE( L_INSTR_DEFN_REC.TASK_ID,
		        NULL,NULL,
			GMO_CONSTANTS_GRP.G_INSTR_TASK_UNACKN_STATUS ),
                --L_INSTR_DEFN_REC.TASK_ATTRIBUTE,
		decode ( L_INSTR_DEFN_REC.task_attribute_id, null, null, decode(0, instr( L_INSTR_DEFN_REC.task_attribute_id, gmo_constants_grp.all_attribute),   L_INSTR_DEFN_REC.task_attribute, null, null, 'ALL')),
                L_INSTR_DEFN_REC.TASK_ATTRIBUTE_ID,
                L_CREATION_DATE,
                L_CREATED_BY,
                L_LAST_UPDATE_DATE,
                L_LAST_UPDATED_BY,
                L_LAST_UPDATE_LOGIN
            );

            FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_DEFN_B_ENTITY,
                                                X_from_pk1_value => L_INSTR_DEFN_REC.INSTRUCTION_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_B_ENTITY,
                                                X_to_pk1_value => L_NEW_INSTRUCTION_ID,
                                                X_to_pk2_value => NULL,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
            );

            L_INSTRUCTION_ID := L_INSTR_DEFN_REC.INSTRUCTION_ID;

            OPEN L_INSTR_APPR_DEFN_CSR;

            LOOP
            FETCH L_INSTR_APPR_DEFN_CSR INTO L_INSTR_APPR_DEFN_REC;
            EXIT WHEN L_INSTR_APPR_DEFN_CSR%NOTFOUND;

                 INSERT INTO GMO_INSTR_APPR_INSTANCE
                 (
                    INSTRUCTION_ID,
                    APPROVER_SEQ,
                    ROLE_COUNT,
                    ROLE_NAME,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN
                )
                VALUES
                (
                    L_NEW_INSTRUCTION_ID,
                    GMO_INSTR_APPR_INSTANCE_S.NEXTVAL,
                    L_INSTR_APPR_DEFN_REC.ROLE_COUNT,
                    L_INSTR_APPR_DEFN_REC.ROLE_NAME,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_LAST_UPDATE_LOGIN
                );

            END LOOP;

            CLOSE L_INSTR_APPR_DEFN_CSR;
        END LOOP;
        CLOSE L_INSTR_DEFN_CSR;
    END LOOP;

    IF(L_INSTR_SET_DEFN_CSR%ROWCOUNT > 0) THEN
        X_INSTRUCTION_SET_ID := L_NEW_INSTRUCTION_SET_ID;
    ELSE
        -- Definition Instructon Set was not found, hence could
	-- not create instance, log the error and return ERROR status

	X_INSTRUCTION_SET_ID := -1;

	FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_CIFD_DIS_NOTFOUND');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        ( G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_INSTANCE_FROM_DEFIN',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE L_INSTR_SET_DEFN_CSR;
    --Bug 4730261: start
    RAISE_INSTR_SET_EVENT(P_INSTRUCTION_SET_ID => X_INSTRUCTION_SET_ID);
    --Bug 4730261: end
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
        X_INSTRUCTION_SET_ID := -1;
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
               P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_INSTANCE_FROM_DEFN',
                 FALSE);
        END IF;

END CREATE_INSTANCE_FROM_DEFN;

-- This API is called to create instance from instance
-- It creates a copy of instance from existing instance
PROCEDURE CREATE_INSTANCE_FROM_INSTANCE
(
    P_SOURCE_ENTITY_NAME IN VARCHAR2,
    P_SOURCE_ENTITY_KEY IN VARCHAR2,
    P_TARGET_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_INSTRUCTION_SET_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT  OUT NOCOPY NUMBER,
    X_MSG_DATA   OUT NOCOPY VARCHAR2
)
IS
    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTRUCTION_ID NUMBER;

    L_NEW_INSTRUCTION_SET_ID NUMBER;
    L_NEW_INSTRUCTION_ID NUMBER;

--Bug 5013199: start
--The where clause had check for instruction set status, which should
--not be there, we check in the procedure for cancel status
--Removed the clause
--Bug 5013199: end
    CURSOR L_INSTR_SET_CSR IS
    SELECT INSTRUCTION_SET_ID, INSTRUCTION_TYPE, ENTITY_NAME, ENTITY_KEY,
    INSTR_SET_NAME, INSTR_SET_DESC, ACKN_STATUS, ORIG_SOURCE, ORIG_SOURCE_ID
    FROM GMO_INSTR_SET_INSTANCE_VL
    WHERE INSTRUCTION_SET_ID = (SELECT MAX(INSTRUCTION_SET_ID)
				FROM GMO_INSTR_SET_INSTANCE_B
				WHERE  ENTITY_NAME = P_SOURCE_ENTITY_NAME AND ENTITY_KEY = P_SOURCE_ENTITY_KEY AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE);

    CURSOR L_INSTR_CSR IS
    SELECT INSTRUCTION_ID, INSTRUCTION_SET_ID, INSTRUCTION_TEXT, INSTR_STATUS,
    COMMENTS, INSTR_NUMBER, INSTR_SEQ, OPERATOR_ACKN, INSTR_ACKN_TYPE, TASK_ID,
    TASK_ACKN_DATE, TASK_ACKN_STATUS, TASK_LABEL, TASK_ATTRIBUTE, TASK_ATTRIBUTE_ID
    FROM GMO_INSTR_INSTANCE_VL
    WHERE
        INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    CURSOR L_INSTR_APPR_CSR IS
    SELECT INSTRUCTION_ID, APPROVER_SEQ, ROLE_COUNT, ROLE_NAME
    FROM GMO_INSTR_APPR_INSTANCE
    WHERE
         INSTRUCTION_ID = L_INSTRUCTION_ID;

    L_INSTR_SET_REC L_INSTR_SET_CSR%ROWTYPE;
    L_INSTR_REC L_INSTR_CSR%ROWTYPE;
    L_INSTR_APPR_REC L_INSTR_APPR_CSR%ROWTYPE;

    L_CNT NUMBER;

    L_SOURCE_ENTITY_ERR EXCEPTION;
    L_DUPLICATE_ENTITY_KEY_ERR EXCEPTION;
    L_ENTITY_NOTFOUND_ERR EXCEPTION;

    L_INSTR_SET_STATUS VARCHAR2(40);
    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    -- Do validation
    IF(P_SOURCE_ENTITY_NAME IS NULL) OR (P_SOURCE_ENTITY_KEY IS NULL)
    OR (P_INSTRUCTION_TYPE IS NULL) THEN
       RAISE L_SOURCE_ENTITY_ERR;
    END IF;

    -- if the source and target entity key are same, "valid"
    -- this case is executed, when source instr set is
    -- nullified, and a new instruction set is to be
    -- created from source
    IF(P_SOURCE_ENTITY_KEY = P_TARGET_ENTITY_KEY) THEN
    BEGIN

       -- first check if the current instruction set is
       -- nullified, if it is nullified, allow same entity
       -- key
       SELECT INSTRUCTION_SET_ID, INSTR_SET_STATUS
       INTO L_INSTRUCTION_SET_ID, L_INSTR_SET_STATUS
       FROM GMO_INSTR_SET_INSTANCE_VL
       WHERE INSTRUCTION_SET_ID = (SELECT MAX(INSTRUCTION_SET_ID)
				FROM GMO_INSTR_SET_INSTANCE_B
				WHERE  ENTITY_NAME = P_SOURCE_ENTITY_NAME AND ENTITY_KEY = P_SOURCE_ENTITY_KEY AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE);

       -- if the instruction instance already exist for the given
       -- target entity name and entity_key, it will exist
       -- as source and target entity_key are same,
       -- return error if the instr set is not nullified (already active),
       -- if it is nullified, a new instruction set is
       -- created, further in the api
       IF(L_INSTR_SET_STATUS = GMO_CONSTANTS_GRP.G_PROCESS_ACTIVE) THEN
            -- return an error conveying source instruction
            -- set already active
            X_INSTRUCTION_SET_ID := -1;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SET_ALREADY_ACTIVE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
            FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME);

            L_MESG_TEXT := FND_MESSAGE.GET();

            FND_MSG_PUB.ADD_EXC_MSG
            (    G_PKG_NAME,
                  L_API_NAME,
                  L_MESG_TEXT
            );

            FND_MSG_PUB.COUNT_AND_GET
            (
	          P_COUNT => X_MSG_COUNT,
                  P_DATA  => X_MSG_DATA
	    );

            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_DEFN_CONTEXT',
                 FALSE);
            END IF;

            RETURN;
         END IF;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
            L_INSTRUCTION_SET_ID := -1;
            X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
            RETURN;
      END;
    END IF;

    -- if the source and target entity key are different
    IF(P_TARGET_ENTITY_KEY IS NOT NULL AND P_SOURCE_ENTITY_KEY <> P_TARGET_ENTITY_KEY) THEN
       BEGIN
          SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
          FROM GMO_INSTR_SET_INSTANCE_VL
          WHERE
               ENTITY_NAME = P_SOURCE_ENTITY_NAME
          AND  ENTITY_KEY = P_TARGET_ENTITY_KEY
          AND  INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
	  AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
            L_INSTRUCTION_SET_ID := -1;
       END;

       -- if the instruction instance already exist for the given
       -- target entity name and entity_key, return this instruction_set_id
       IF (L_INSTRUCTION_SET_ID > 0) THEN
              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
              X_INSTRUCTION_SET_ID := L_INSTRUCTION_SET_ID;
              RETURN;
       END IF;
    END IF;

    -- Only 1 instruction set can be there.
    OPEN L_INSTR_SET_CSR;
    FETCH L_INSTR_SET_CSR INTO L_INSTR_SET_REC;

    IF (L_INSTR_SET_CSR%ROWCOUNT <= 0) THEN
	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
	X_INSTRUCTION_SET_ID := -1;
	RETURN;
    END IF;

	 SELECT GMO_INSTR_SET_INSTANCE_S.NEXTVAL INTO L_NEW_INSTRUCTION_SET_ID
         FROM DUAL;

         INSERT INTO GMO_INSTR_SET_INSTANCE_VL
         (
             INSTRUCTION_SET_ID,
             INSTRUCTION_TYPE,
             ENTITY_NAME,
             ENTITY_KEY,
             INSTR_SET_NAME,
             INSTR_SET_DESC,
             ACKN_STATUS,
             INSTR_SET_STATUS,
             ORIG_SOURCE,
             ORIG_SOURCE_ID,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN
        )
        VALUES
        (
             L_NEW_INSTRUCTION_SET_ID,
             L_INSTR_SET_REC.INSTRUCTION_TYPE,
             P_SOURCE_ENTITY_NAME,
             NVL(P_TARGET_ENTITY_KEY, GMO_CONSTANTS_GRP.G_INSTR_PREFIX || L_NEW_INSTRUCTION_SET_ID),
             L_INSTR_SET_REC.INSTR_SET_NAME,
             L_INSTR_SET_REC.INSTR_SET_DESC,
             GMO_CONSTANTS_GRP.G_INSTR_SET_UNACKN_STATUS,
             GMO_CONSTANTS_GRP.G_PROCESS_ACTIVE,
             GMO_CONSTANTS_GRP.G_ORIG_SOURCE_INSTANCE,
             L_INSTR_SET_REC.INSTRUCTION_SET_ID,
             L_CREATION_DATE,
             L_CREATED_BY,
             L_LAST_UPDATE_DATE,
             L_LAST_UPDATED_BY,
             L_LAST_UPDATE_LOGIN
        );

        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_INSTANCE_B_ENTITY,
                                                X_from_pk1_value => L_INSTR_SET_REC.INSTRUCTION_SET_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_SET_INSTANCE_B_ENTITY,
                                                X_to_pk1_value => L_NEW_INSTRUCTION_SET_ID,
                                                X_to_pk2_value => NULL,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
        );

        L_INSTRUCTION_SET_ID := L_INSTR_SET_REC.INSTRUCTION_SET_ID;

        OPEN L_INSTR_CSR;
        LOOP
        FETCH L_INSTR_CSR INTO L_INSTR_REC;
        EXIT WHEN L_INSTR_CSR%NOTFOUND;

	    SELECT GMO_INSTR_INSTANCE_S.NEXTVAL INTO L_NEW_INSTRUCTION_ID
            FROM DUAL;

            INSERT INTO GMO_INSTR_INSTANCE_VL
            (
               INSTRUCTION_ID,
               INSTRUCTION_SET_ID,
               INSTRUCTION_TEXT,
               INSTR_STATUS,
               COMMENTS,
               TASK_LABEL,
               INSTR_NUMBER,
               INSTR_SEQ,
               OPERATOR_ACKN,
               INSTR_ACKN_TYPE,
               TASK_ID,
               TASK_ACKN_DATE,
               TASK_ACKN_STATUS,
               TASK_ATTRIBUTE,
               TASK_ATTRIBUTE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
                L_NEW_INSTRUCTION_ID,
                L_NEW_INSTRUCTION_SET_ID,
                L_INSTR_REC.INSTRUCTION_TEXT,
                GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING,
                NULL,
                L_INSTR_REC.TASK_LABEL,
                L_INSTR_REC.INSTR_NUMBER,
                L_INSTR_REC.INSTR_SEQ,
                GMO_CONSTANTS_GRP.G_INSTR_OPERATOR_ACKN_NO,
                L_INSTR_REC.INSTR_ACKN_TYPE,
                L_INSTR_REC.TASK_ID,
                NULL,
                DECODE(L_INSTR_REC.TASK_ID,NULL,NULL,GMO_CONSTANTS_GRP.G_INSTR_TASK_UNACKN_STATUS),
                L_INSTR_REC.TASK_ATTRIBUTE,
                L_INSTR_REC.TASK_ATTRIBUTE_ID,
                L_CREATION_DATE,
                L_CREATED_BY,
                L_LAST_UPDATE_DATE,
                L_LAST_UPDATED_BY,
                L_LAST_UPDATE_LOGIN
            );

            FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
                                                X_from_entity_name => GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_B_ENTITY,
                                                X_from_pk1_value => L_INSTR_REC.INSTRUCTION_ID,
                                                X_from_pk2_value => NULL,
                                                X_from_pk3_value => NULL,
                                                X_from_pk4_value => NULL,
                                                X_from_pk5_value => NULL,
                                                X_to_entity_name => GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_B_ENTITY,
                                                X_to_pk1_value => L_NEW_INSTRUCTION_ID,
                                                X_to_pk2_value => NULL,
                                                X_to_pk3_value => NULL,
                                                X_to_pk4_value => NULL,
                                                X_to_pk5_value => NULL,
                                                X_created_by => L_CREATED_BY,
                                                X_last_update_login => L_LAST_UPDATE_LOGIN,
                                                X_program_application_id => NULL,
                                                X_program_id => NULL,
                                                X_request_id => NULL,
                                                X_automatically_added_flag => GMO_CONSTANTS_GRP.NO,
                                                X_from_category_id => NULL,
                                                X_to_category_id => NULL
            );

            L_INSTRUCTION_ID := L_INSTR_REC.INSTRUCTION_ID;

            OPEN L_INSTR_APPR_CSR;
            LOOP
            FETCH L_INSTR_APPR_CSR INTO L_INSTR_APPR_REC;
            EXIT WHEN L_INSTR_APPR_CSR%NOTFOUND;

                 INSERT INTO GMO_INSTR_APPR_INSTANCE
                 (
                    INSTRUCTION_ID,
                    APPROVER_SEQ,
                    ROLE_COUNT,
                    ROLE_NAME,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN
                )
                VALUES
                (
                    L_NEW_INSTRUCTION_ID,
                    GMO_INSTR_APPR_INSTANCE_S.NEXTVAL,
                    L_INSTR_APPR_REC.ROLE_COUNT,
                    L_INSTR_APPR_REC.ROLE_NAME,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_LAST_UPDATE_LOGIN
                );
            END LOOP;
            CLOSE L_INSTR_APPR_CSR;

        END LOOP;
        CLOSE L_INSTR_CSR;
    CLOSE L_INSTR_SET_CSR;

    -- If the L_NEW_INSTRUCTION_SET_ID is NULL, return -1
    X_INSTRUCTION_SET_ID := NVL(L_NEW_INSTRUCTION_SET_ID,-1);
    --Bug 4730261: start
    RAISE_INSTR_SET_EVENT(P_INSTRUCTION_SET_ID => X_INSTRUCTION_SET_ID);
    --Bug 4730261: end
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         X_INSTRUCTION_SET_ID := -1;
         X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN
        X_INSTRUCTION_SET_ID := -1;
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
          ( P_COUNT => X_MSG_COUNT,
           P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE ( FND_LOG.LEVEL_UNEXPECTED,
               'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_INSTANCE_FROM_INSTANCE',
               FALSE );
        END IF;

END CREATE_INSTANCE_FROM_INSTANCE;

-- This API is called to get mode for entity. The mode for entity is returned READ if all
-- instructions are compeleted in instruction set. It is UPDATE is some instructions are
-- pending, and INSERT if there are no instruction defined

PROCEDURE GET_MODE_FOR_ENTITY
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_MODE OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
    X_MSG_COUNT       OUT NOCOPY NUMBER,
    X_MSG_DATA        OUT NOCOPY VARCHAR2
)
IS
    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTR_COUNT NUMBER;
    L_INSTR_SET_COUNT NUMBER;
    L_ENTITY_ERR EXCEPTION;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN
    L_API_NAME  := 'GET_MODE_FOR_ENTITY';

    IF(P_ENTITY_NAME IS NULL) OR (P_ENTITY_KEY IS NULL)
      OR (P_INSTRUCTION_TYPE IS NULL) THEN
          RAISE L_ENTITY_ERR;
    END IF;

    SELECT COUNT(INSTRUCTION_SET_ID) INTO L_INSTR_SET_COUNT
    FROM GMO_INSTR_SET_INSTANCE_VL
    WHERE ENTITY_NAME = P_ENTITY_NAME
         AND nvl(ENTITY_KEY,1) = nvl(P_ENTITY_KEY,1)
         AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
	 AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;

    IF (L_INSTR_SET_COUNT = 0 ) THEN
       X_MODE := GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_MODE_INSERT;
    ELSE
       SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
       FROM GMO_INSTR_SET_INSTANCE_VL
       WHERE ENTITY_NAME = P_ENTITY_NAME
       AND nvl(ENTITY_KEY,1) = nvl(P_ENTITY_KEY,1)
       AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
	 AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;

       SELECT COUNT(INSTRUCTION_ID) INTO L_INSTR_COUNT
       FROM GMO_INSTR_INSTANCE_VL WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

       IF (L_INSTR_COUNT > 0) THEN
            SELECT COUNT(INSTRUCTION_ID) INTO L_INSTR_COUNT
            FROM GMO_INSTR_INSTANCE_VL WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
            AND ( INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING
                  OR INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_DONE );

            IF (L_INSTR_COUNT > 0) THEN
                 X_MODE := GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_MODE_UPDATE;
            ELSE
                 X_MODE := GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_MODE_READ;
            END IF;
       ELSE
            X_MODE := GMO_CONSTANTS_GRP.G_INSTR_INSTANCE_MODE_READ;
       END IF;
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN L_ENTITY_ERR THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SOURCE_ENTITY_ER');
      FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
      FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

      L_MESG_TEXT := FND_MESSAGE.GET();

      FND_MSG_PUB.ADD_EXC_MSG
      (     G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
      );

      FND_MSG_PUB.COUNT_AND_GET
      (
	P_COUNT => X_MSG_COUNT,
        P_DATA  => X_MSG_DATA
      );

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.GET_MODE_FOR_ENTITY',
                 FALSE);
      END IF;

    WHEN OTHERS THEN

       X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                   L_API_NAME);
       END IF;

       FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
               P_DATA  => X_MSG_DATA);

       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.GET_MODE_FOR_ENTITY',
                 FALSE);
       END IF;

END GET_MODE_FOR_ENTITY;

-- This API is called to get the list of all instructions
-- in a single table type for given entity name, entity key
-- and instruction type. It returns Definition Time Instructions.

PROCEDURE GET_DEFN_INSTRUCTIONS
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE VARCHAR2,
    X_INSTRUCTION_TABLE OUT NOCOPY GMO_DATATYPES_GRP.GMO_INSTRUCTION_TBL_TYPE,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS
     L_INSTRUCTION_SET_ID NUMBER;
     L_INSTRUCTION_REC GMO_DATATYPES_GRP.GMO_INSTRUCTION_REC_TYPE;
     L_INSTRUCTION_TBL GMO_DATATYPES_GRP.GMO_INSTRUCTION_TBL_TYPE;

     CURSOR L_INSTR_CSR IS
     SELECT INSTR_DEFN.INSTRUCTION_ID, INSTR_DEFN.INSTRUCTION_SET_ID,
     INSTR_DEFN.INSTRUCTION_TEXT,
     INSTR_DEFN.TASK_ATTRIBUTE, TSK.TASK_NAME, TSK.DISPLAY_NAME
     FROM GMO_INSTR_DEFN_VL INSTR_DEFN, GMO_INSTR_TASK_DEFN_VL TSK
     WHERE INSTR_DEFN.INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
     AND INSTR_DEFN.TASK_ID = TSK.TASK_ID;

     L_INSTR_REC L_INSTR_CSR%ROWTYPE;
     L_INSTR_CNT NUMBER;

     L_ENTITY_PARAM_ERR EXCEPTION;
     L_INVALID_ENTITY_ERR EXCEPTION;

     L_API_NAME VARCHAR2(40);
     L_MESG_TEXT VARCHAR2(1000);

BEGIN

     L_API_NAME := 'GET_DEFN_INSTRUCTIONS';

     IF ((P_ENTITY_NAME IS NULL) OR (P_ENTITY_KEY IS NULL)
     OR (P_INSTRUCTION_TYPE IS NULL) )  THEN
          RAISE L_ENTITY_PARAM_ERR;
     END IF;

     SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
     FROM GMO_INSTR_SET_DEFN_VL
     WHERE
          ENTITY_NAME = P_ENTITY_NAME
     AND  nvl(ENTITY_KEY,1) = nvl(P_ENTITY_KEY,1)
     AND  INSTRUCTION_TYPE = P_INSTRUCTION_TYPE;

     IF(SQL%NOTFOUND) THEN
        RAISE L_INVALID_ENTITY_ERR;
     END IF;

     L_INSTR_CNT := 0;

     OPEN L_INSTR_CSR;
     LOOP
     FETCH L_INSTR_CSR INTO L_INSTR_REC;
     EXIT WHEN L_INSTR_CSR%NOTFOUND;

         L_INSTR_CNT := L_INSTR_CNT + 1;

         L_INSTRUCTION_REC.INSTRUCTION_ID := L_INSTR_REC.INSTRUCTION_ID;
         L_INSTRUCTION_REC.INSTRUCTION_SET_ID := L_INSTR_REC.INSTRUCTION_SET_ID;
         L_INSTRUCTION_REC.INSTRUCTION_TEXT := L_INSTR_REC.INSTRUCTION_TEXT;
         L_INSTRUCTION_REC.TASK_ATTRIBUTE := L_INSTR_REC.TASK_ATTRIBUTE;
         L_INSTRUCTION_REC.TASK_NAME := L_INSTR_REC.TASK_NAME;
         L_INSTRUCTION_REC.TASK_DISPLAY_NAME := L_INSTR_REC.DISPLAY_NAME;

         L_INSTRUCTION_TBL(L_INSTR_CNT) := L_INSTRUCTION_REC;

     END LOOP;
     CLOSE L_INSTR_CSR;

     X_INSTRUCTION_TABLE := L_INSTRUCTION_TBL;
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN L_ENTITY_PARAM_ERR THEN
        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_API_PARAM_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        ( G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.GET_DEFN_INSTRUCTIONS',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN L_INVALID_ENTITY_ERR THEN
        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SOURCE_ENTITY_ER');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        ( G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.GET_DEFN_INSTRUCTIONS',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_DEFN_INSTRUCTIONS;

-- This API is checks if there are any pending instructions for
-- the given entity name, key and instruction type on instance
-- permenant tables

PROCEDURE HAS_PENDING_INSTRUCTIONS
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_INSTRUCTION_PENDING OUT NOCOPY VARCHAR2,
    X_TOTAL_INSTRUCTIONS OUT NOCOPY NUMBER,
    X_OPTIONAL_PENDING_INSTR OUT NOCOPY NUMBER,
    X_MANDATORY_PENDING_INSTR OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA  OUT NOCOPY VARCHAR2
)
IS
    L_TOTAL_INSTRUCTIONS NUMBER;
    L_OPTIONAL_PENDING_INSTR NUMBER;
    L_MANDATORY_PENDING_INSTR NUMBER;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTR_OPTIONAL VARCHAR2(40);
    L_INSTR_PROCEED_ALLOWED VARCHAR2(40);
    L_INSTR_MANDATORY VARCHAR2(40);

    L_ENTITY_ERR EXCEPTION;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN

    L_API_NAME := 'HAS_PENDING_INSTRUCTIONS';

    -- Validation for Entity
    IF(P_ENTITY_NAME IS NULL) OR (P_ENTITY_KEY IS NULL)
                            OR (P_INSTRUCTION_TYPE IS NULL) THEN
       RAISE L_ENTITY_ERR;
    END IF;

    L_INSTR_MANDATORY := GMO_CONSTANTS_GRP.G_INSTR_MANDATORY;
    L_INSTR_OPTIONAL := GMO_CONSTANTS_GRP.G_INSTR_OPTIONAL;
    L_INSTR_PROCEED_ALLOWED := GMO_CONSTANTS_GRP.G_INSTR_PROCEED_ALLOWED;

    -- Check if the instruction set exists, get instruction set id
    SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
    FROM GMO_INSTR_SET_INSTANCE_VL
    WHERE ENTITY_NAME = P_ENTITY_NAME
    AND nvl(ENTITY_KEY,1) = nvl(P_ENTITY_KEY,1)
    AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
    AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;

    SELECT COUNT(INSTRUCTION_ID) INTO L_TOTAL_INSTRUCTIONS
    FROM GMO_INSTR_INSTANCE_VL
    WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    SELECT COUNT(INSTRUCTION_ID) INTO L_OPTIONAL_PENDING_INSTR
    FROM GMO_INSTR_INSTANCE_VL
    WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
    AND INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING
    AND ( INSTR_ACKN_TYPE = L_INSTR_OPTIONAL );

    SELECT COUNT(INSTRUCTION_ID) INTO L_MANDATORY_PENDING_INSTR
    FROM GMO_INSTR_INSTANCE_VL
    WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
    AND INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING
    AND ( INSTR_ACKN_TYPE = L_INSTR_MANDATORY OR INSTR_ACKN_TYPE = L_INSTR_PROCEED_ALLOWED);

    X_TOTAL_INSTRUCTIONS := L_TOTAL_INSTRUCTIONS;
    X_OPTIONAL_PENDING_INSTR := L_OPTIONAL_PENDING_INSTR;
    X_MANDATORY_PENDING_INSTR := L_MANDATORY_PENDING_INSTR;

    IF ((X_OPTIONAL_PENDING_INSTR + X_MANDATORY_PENDING_INSTR ) > 0)
    THEN
       X_INSTRUCTION_PENDING := GMO_CONSTANTS_GRP.YES;
    ELSE
       X_INSTRUCTION_PENDING := GMO_CONSTANTS_GRP.NO;
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
         -- If Process Id is invalid, NO_DATA_FOUND
	 -- Exception is thrown, in that case also,
	 -- return all values as 0, and status = S
         X_TOTAL_INSTRUCTIONS := 0;
         X_OPTIONAL_PENDING_INSTR := 0;
         X_MANDATORY_PENDING_INSTR := 0;
         X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  WHEN L_ENTITY_ERR THEN
        X_TOTAL_INSTRUCTIONS := 0;
        X_OPTIONAL_PENDING_INSTR := 0;
        X_MANDATORY_PENDING_INSTR := 0;

        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_API_PARAM_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        (   G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.HAS_PENDING_INSTRUCTIONS',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
        X_TOTAL_INSTRUCTIONS := 0;
        X_OPTIONAL_PENDING_INSTR := 0;
        X_MANDATORY_PENDING_INSTR := 0;

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
               P_DATA  => X_MSG_DATA
           );

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.HAS_PENDING_INSTRUCTIONS',
                 FALSE);
        END IF;

	X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END HAS_PENDING_INSTRUCTIONS;

-- This API is checks if there are any pending instructions for
-- the given entity name, key and instruction type on instance
-- process / temporary tables
PROCEDURE HAS_PENDING_INSTR_FOR_PROCESS
(
    P_INSTRUCTION_PROCESS_ID IN VARCHAR2,
    X_INSTRUCTION_PENDING OUT NOCOPY VARCHAR2,
    X_TOTAL_INSTRUCTIONS OUT NOCOPY NUMBER,
    X_OPTIONAL_PENDING_INSTR OUT NOCOPY NUMBER,
    X_MANDATORY_PENDING_INSTR OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS

    L_TOTAL_INSTRUCTIONS NUMBER;
    L_OPTIONAL_PENDING_INSTR NUMBER;
    L_MANDATORY_PENDING_INSTR NUMBER;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTR_OPTIONAL VARCHAR2(40);
    L_INSTR_PROCEED_ALLOWED VARCHAR2(40);
    L_INSTR_MANDATORY VARCHAR2(40);

    L_ENTITY_ERR EXCEPTION;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN

    L_API_NAME := 'HAS_PENDING_INSTR_FOR_PROCESS';

    L_INSTR_MANDATORY := GMO_CONSTANTS_GRP.G_INSTR_MANDATORY;
    L_INSTR_OPTIONAL := GMO_CONSTANTS_GRP.G_INSTR_OPTIONAL;
    L_INSTR_PROCEED_ALLOWED := GMO_CONSTANTS_GRP.G_INSTR_PROCEED_ALLOWED;

    SELECT COUNT(INSTRUCTION_ID) INTO L_TOTAL_INSTRUCTIONS
    FROM GMO_INSTR_INSTANCE_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

    SELECT COUNT(TEMP.INSTRUCTION_ID) INTO L_OPTIONAL_PENDING_INSTR
    FROM GMO_INSTR_INSTANCE_T TEMP, GMO_INSTR_INSTANCE_VL PERM
    WHERE TEMP.INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND TEMP.INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING
    AND TEMP.INSTRUCTION_ID = PERM.INSTRUCTION_ID
    AND ( PERM.INSTR_ACKN_TYPE = L_INSTR_OPTIONAL);

    SELECT COUNT(TEMP.INSTRUCTION_ID) INTO L_MANDATORY_PENDING_INSTR
    FROM GMO_INSTR_INSTANCE_VL PERM, GMO_INSTR_INSTANCE_T TEMP
    WHERE TEMP.INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND TEMP.INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING
    AND TEMP.INSTRUCTION_ID = PERM.INSTRUCTION_ID
    AND ( PERM.INSTR_ACKN_TYPE = L_INSTR_MANDATORY OR PERM.INSTR_ACKN_TYPE = L_INSTR_PROCEED_ALLOWED);

    X_TOTAL_INSTRUCTIONS := L_TOTAL_INSTRUCTIONS;
    X_OPTIONAL_PENDING_INSTR := L_OPTIONAL_PENDING_INSTR;
    X_MANDATORY_PENDING_INSTR := L_MANDATORY_PENDING_INSTR;

    IF ((X_OPTIONAL_PENDING_INSTR + X_MANDATORY_PENDING_INSTR ) > 0)
    THEN
       X_INSTRUCTION_PENDING := GMO_CONSTANTS_GRP.YES;
    ELSE
       X_INSTRUCTION_PENDING := GMO_CONSTANTS_GRP.NO;
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
         -- If Process Id is invalid, NO_DATA_FOUND
	 -- Exception is thrown, in that case also,
	 -- return all values as 0, and status = S
         X_TOTAL_INSTRUCTIONS := 0;
         X_OPTIONAL_PENDING_INSTR := 0;
         X_MANDATORY_PENDING_INSTR := 0;
         X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  WHEN L_ENTITY_ERR THEN
        X_TOTAL_INSTRUCTIONS := 0;
        X_OPTIONAL_PENDING_INSTR := 0;
        X_MANDATORY_PENDING_INSTR := 0;

        FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_API_PARAM_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

        L_MESG_TEXT := FND_MESSAGE.GET();

        FND_MSG_PUB.ADD_EXC_MSG
        (   G_PKG_NAME,
            L_API_NAME,
            L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.HAS_PENDING_INSTR_FOR_PROCESS',
                 FALSE);
        END IF;
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
        X_TOTAL_INSTRUCTIONS := 0;
        X_OPTIONAL_PENDING_INSTR := 0;
        X_MANDATORY_PENDING_INSTR := 0;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           ( P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA );

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.HAS_PENDING_INSTR_FOR_PROCESS',
                 FALSE);
        END IF;
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END HAS_PENDING_INSTR_FOR_PROCESS;

-- This API is called to send the instance acknowledgment
-- It acknowledges the instruction set and copies the temporary
-- data to permenant instance tables. It also marks all DONE instructions
-- to COMPLETE

PROCEDURE SEND_INSTANCE_ACKN
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS PRAGMA AUTONOMOUS_TRANSACTION;
    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTRUCTION_ID NUMBER;

    L_INSTR_STATUS VARCHAR2(40);

    L_INSTR_EREC_COUNT NUMBER;
    L_TASK_EREC_COUNT NUMBER;

    L_ENTITY_KEY VARCHAR2(500);

    CURSOR L_TEMP_INSTR_SET_CSR IS
    SELECT INSTRUCTION_SET_ID, INSTRUCTION_PROCESS_ID, ACKN_STATUS
    FROM GMO_INSTR_SET_INSTANCE_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

    CURSOR L_TEMP_INSTR_CSR IS
    SELECT TEMP.INSTRUCTION_PROCESS_ID, TEMP.INSTRUCTION_ID, PERM.INSTRUCTION_SET_ID,
           TEMP.COMMENTS, TEMP.OPERATOR_ACKN, TEMP.INSTR_STATUS,
           TEMP.TASK_ACKN_STATUS, TEMP.TASK_ACKN_DATE, TEMP.DISABLE_TASK
    FROM GMO_INSTR_INSTANCE_T TEMP, GMO_INSTR_INSTANCE_VL PERM
    WHERE PERM.INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
    AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND PERM.INSTRUCTION_ID = TEMP.INSTRUCTION_ID FOR UPDATE;

    CURSOR L_TEMP_INSTR_EREC_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, INSTR_EREC_SEQ, INSTRUCTION_ID,
           TASK_EREC_ID, INSTR_EREC_ID
    FROM GMO_INSTR_EREC_INSTANCE_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND INSTRUCTION_ID = L_INSTRUCTION_ID
    ORDER BY INSTR_EREC_SEQ;

    CURSOR L_TEMP_TASK_EREC_CSR IS
    SELECT INSTRUCTION_PROCESS_ID, INSTR_TASK_SEQ, TASK_EREC_ID,
    TASK_IDENTIFIER, TASK_VALUE, MANUAL_ENTRY, INSTRUCTION_ID
    FROM GMO_INSTR_TASK_INSTANCE_T
    WHERE
          INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND   INSTRUCTION_ID = L_INSTRUCTION_ID
    ORDER BY INSTR_TASK_SEQ;

    L_INSTR_SET_REC L_TEMP_INSTR_SET_CSR%ROWTYPE;
    L_INSTR_REC L_TEMP_INSTR_CSR%ROWTYPE;
    L_INSTR_EREC_REC L_TEMP_INSTR_EREC_CSR%ROWTYPE;
    L_TASK_EREC_REC L_TEMP_TASK_EREC_CSR%ROWTYPE;

    L_INSTR_ACKN_TYPE VARCHAR2(40);
    L_OPERATOR_ACKN VARCHAR2(1);
    L_INSTRUCTION_COUNT NUMBER;

    L_INSTANCE_STATUS VARCHAR2(40);

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

    l_set_active NUMBER;

BEGIN

    L_API_NAME := 'SEND_INSTANCE_ACKN';

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
    FROM GMO_INSTR_SET_INSTANCE_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

    SELECT ENTITY_KEY INTO L_ENTITY_KEY
    FROM GMO_INSTR_SET_INSTANCE_VL
    WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    IF (P_ENTITY_KEY IS NOT NULL) THEN

       IF(L_ENTITY_KEY  LIKE (GMO_CONSTANTS_GRP.G_INSTR_PREFIX || '%' )) THEN
	    --Bug 5224619: start
            UPDATE GMO_INSTR_SET_INSTANCE_B
            SET ENTITY_KEY = P_ENTITY_KEY
            WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;
	    --Bug 5224619: end

            UPDATE_ENTITY_KEY
            (
                P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
                P_ENTITY_KEY => P_ENTITY_KEY
            );

        END IF;

    END IF;

    L_INSTANCE_STATUS := GET_PROCESS_VARIABLE
                           ( P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
                             P_ATTRIBUTE_NAME => GMO_CONSTANTS_GRP.G_INSTANCE_STATUS,
                             P_ATTRIBUTE_TYPE => GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
                           );

  IF(L_INSTANCE_STATUS IS NOT NULL
           AND L_INSTANCE_STATUS = GMO_CONSTANTS_GRP.G_PROCESS_COMPLETE ) THEN

    OPEN L_TEMP_INSTR_SET_CSR;
    LOOP
    FETCH L_TEMP_INSTR_SET_CSR INTO L_INSTR_SET_REC;
    EXIT WHEN L_TEMP_INSTR_SET_CSR%NOTFOUND;

	--Bug 4730261:start
	--update the instructions only when the set is active
	select count(*) into l_set_active from gmo_instr_set_instance_vl
	where instruction_set_id = L_INSTR_SET_REC.INSTRUCTION_SET_ID
	and instr_set_status = GMO_CONSTANTS_GRP.G_PROCESS_ACTIVE;

	if (l_set_active > 0) then
	--Bug 4730261: end
	 --Bug 5224619: start
         UPDATE GMO_INSTR_SET_INSTANCE_B
         SET
               ACKN_STATUS = GMO_CONSTANTS_GRP.G_INSTR_SET_ACKN_STATUS,
               LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
               LAST_UPDATED_BY = L_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
         WHERE
               INSTRUCTION_SET_ID = L_INSTR_SET_REC.INSTRUCTION_SET_ID;
	 --Bug 5224619: end

         L_INSTRUCTION_SET_ID := L_INSTR_SET_REC.INSTRUCTION_SET_ID;

         OPEN L_TEMP_INSTR_CSR;
         LOOP
         FETCH L_TEMP_INSTR_CSR INTO L_INSTR_REC;
         EXIT WHEN L_TEMP_INSTR_CSR%NOTFOUND;

               L_INSTR_STATUS := L_INSTR_REC.INSTR_STATUS;

               IF(L_INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_DONE ) THEN
                    L_INSTR_STATUS := GMO_CONSTANTS_GRP.G_INSTR_STATUS_COMPLETE;

                   UPDATE GMO_INSTR_INSTANCE_T
                   SET INSTR_STATUS = L_INSTR_STATUS
                   WHERE INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_DONE
                   AND INSTRUCTION_ID = L_INSTR_REC.INSTRUCTION_ID;

		   --Bug 5224619: start
		   UPDATE GMO_INSTR_INSTANCE_TL
		   SET
			COMMENTS = L_INSTR_REC.COMMENTS,
			LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
			LAST_UPDATED_BY = L_LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
		   WHERE
			INSTRUCTION_ID = L_INSTR_REC.INSTRUCTION_ID;

                   UPDATE GMO_INSTR_INSTANCE_B
                   SET
                       OPERATOR_ACKN = L_INSTR_REC.OPERATOR_ACKN,
                       TASK_ACKN_STATUS = L_INSTR_REC.TASK_ACKN_STATUS,
                       TASK_ACKN_DATE = L_INSTR_REC.TASK_ACKN_DATE,
                       INSTR_STATUS = L_INSTR_STATUS,
                       LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
                       LAST_UPDATED_BY = L_LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
                   WHERE
                       INSTRUCTION_ID = L_INSTR_REC.INSTRUCTION_ID;
		   --Bug 5224619: end

                   L_INSTRUCTION_ID := L_INSTR_REC.INSTRUCTION_ID;

                   --First delete data from instr_erec_instance table
                   DELETE FROM GMO_INSTR_EREC_INSTANCE
                   WHERE INSTRUCTION_ID = L_INSTR_REC.INSTRUCTION_ID;

                   OPEN L_TEMP_INSTR_EREC_CSR;
                   LOOP
                   FETCH L_TEMP_INSTR_EREC_CSR INTO L_INSTR_EREC_REC;
                   EXIT WHEN L_TEMP_INSTR_EREC_CSR%NOTFOUND;

                      INSERT INTO GMO_INSTR_EREC_INSTANCE
                      (
                         INSTRUCTION_ID,
                         INSTR_EREC_SEQ,
                         TASK_EREC_ID,
                         INSTR_EREC_ID,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN
                     )
                     VALUES
                     (
                         L_INSTR_EREC_REC.INSTRUCTION_ID,
                         L_INSTR_EREC_REC.INSTR_EREC_SEQ,
                         L_INSTR_EREC_REC.TASK_EREC_ID,
                         L_INSTR_EREC_REC.INSTR_EREC_ID,
                         L_CREATION_DATE,
                         L_CREATED_BY,
                         L_LAST_UPDATE_DATE,
                         L_LAST_UPDATED_BY,
                         L_LAST_UPDATE_LOGIN
                     );

		    END LOOP;
                    CLOSE L_TEMP_INSTR_EREC_CSR;

                --First delete data from instr_task_instance table
                DELETE FROM GMO_INSTR_TASK_INSTANCE
                WHERE INSTRUCTION_ID = L_INSTR_REC.INSTRUCTION_ID;

                OPEN L_TEMP_TASK_EREC_CSR;
                LOOP
                FETCH L_TEMP_TASK_EREC_CSR INTO L_TASK_EREC_REC;
                EXIT WHEN L_TEMP_TASK_EREC_CSR%NOTFOUND;

                    INSERT INTO GMO_INSTR_TASK_INSTANCE
                    (
                        INSTRUCTION_ID,
                        INSTR_TASK_SEQ,
                        TASK_EREC_ID,
                        TASK_IDENTIFIER,
                        TASK_VALUE,
                        MANUAL_ENTRY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN
                    )
                    VALUES
                    (
                       L_TASK_EREC_REC.INSTRUCTION_ID,
                       L_TASK_EREC_REC.INSTR_TASK_SEQ,
                       L_TASK_EREC_REC.TASK_EREC_ID,
                       L_TASK_EREC_REC.TASK_IDENTIFIER,
                       L_TASK_EREC_REC.TASK_VALUE,
                       L_TASK_EREC_REC.MANUAL_ENTRY,
                       L_CREATION_DATE,
                       L_CREATED_BY,
                       L_LAST_UPDATE_DATE,
                       L_LAST_UPDATED_BY,
                       L_LAST_UPDATE_LOGIN
                    );

                END LOOP;
                CLOSE L_TEMP_TASK_EREC_CSR;

           END IF; -- INSTR_STATUS = DONE

        END LOOP;
        CLOSE L_TEMP_INSTR_CSR;

    -- Bug 5231778 : update the Instructin Set Status before raising Event
        --Set the instruction set status to 'complete' if all the
    --instructions are complete in a given instruction set
    SELECT COUNT(*) INTO L_INSTRUCTION_COUNT
    FROM GMO_INSTR_INSTANCE_B
    WHERE INSTR_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_COMPLETE
    AND INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    -- Set the Instruction set status to complete
    IF(L_INSTRUCTION_COUNT = 0) THEN
	--Bug 5224619: start
        UPDATE GMO_INSTR_SET_INSTANCE_B
        SET INSTR_SET_STATUS = GMO_CONSTANTS_GRP.G_PROCESS_COMPLETE
        WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;
	--Bug 5224619: end
    END IF;

	--Bug 4730261: start
	RAISE_INSTR_SET_EVENT(P_INSTRUCTION_SET_ID => L_INSTRUCTION_SET_ID);
	end if; -- end if (l_set_active > 0)
	--Bug 4730261: end

    END LOOP;
    CLOSE L_TEMP_INSTR_SET_CSR;

  END IF; -- If Instance Status is COMPLETE

  --COMMIT CHANGES
  COMMIT;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;

          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
          END IF;

          FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT',
                 FALSE);
          END IF;

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END SEND_INSTANCE_ACKN;

-- This API is called to send the task acknowledgment
-- It acknowledges the task identifier, value and e-record
-- id into the GMO_INSTR_TASK_INSTANCE_T table

PROCEDURE SEND_TASK_ACKN
(
    P_INSTRUCTION_ID                IN NUMBER,
    P_INSTRUCTION_PROCESS_ID        IN NUMBER,
    P_ENTITY_KEY                    IN VARCHAR2 DEFAULT NULL,
    P_TASK_ERECORD_ID               IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_IDENTIFIER               IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_VALUE                    IN FND_TABLE_OF_VARCHAR2_255,
    P_DISABLE_TASK                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.NO,
    P_MANUAL_ENTRY                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.NO,
    X_RETURN_STATUS                 OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                     OUT NOCOPY NUMBER,
    X_MSG_DATA                      OUT NOCOPY VARCHAR2
)
IS PRAGMA AUTONOMOUS_TRANSACTION;

    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_INSTRUCTION_ID NUMBER;
    L_INSTRUCTION_SET_ID NUMBER;

    L_ENTITY_NAME VARCHAR2(200);
    L_ENTITY_KEY VARCHAR2(500);

    L_INVALID_PARAM_ERR EXCEPTION;
    L_ENTITY_KEY_ERR EXCEPTION;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

    L_PROCESS_COUNT NUMBER;

BEGIN

    L_API_NAME := 'SEND_TASK_ACKN';

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    -- VALIDATE THE INSTRUCTION ID FIRST BY SEEING IF IT EXISTS IN
    -- THE TEMPORARY TABLE

    SELECT COUNT(*) INTO L_PROCESS_COUNT
    FROM GMO_INSTR_ATTRIBUTES_T
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND ATTRIBUTE_NAME  = GMO_CONSTANTS_GRP.G_INSTANCE_STATUS
    AND ATTRIBUTE_TYPE = GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
    AND ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_ERROR;

    IF L_PROCESS_COUNT = 0 THEN
      RAISE L_INVALID_PARAM_ERR;
    END IF;

    SELECT INSTRN.INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
    FROM
        GMO_INSTR_INSTANCE_T INSTR_TEMP,
        GMO_INSTR_INSTANCE_VL INSTRN
    WHERE
        INSTR_TEMP.INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
        AND INSTR_TEMP.INSTRUCTION_ID = P_INSTRUCTION_ID
        AND INSTR_TEMP.INSTRUCTION_ID = INSTRN.INSTRUCTION_ID;

    IF ( P_MANUAL_ENTRY = GMO_CONSTANTS_GRP.YES ) THEN
        -- Remove all previously entered manual data, and enter the new
        -- rows passed in current API call, this will take care of
        -- delete task row in case of manual entry

        DELETE FROM GMO_INSTR_TASK_INSTANCE_T
        WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
        AND INSTRUCTION_ID = P_INSTRUCTION_ID
        AND MANUAL_ENTRY = GMO_CONSTANTS_GRP.YES;

    END IF;

    FOR I IN 1..P_TASK_ERECORD_ID.COUNT LOOP
      --the task erecord can be null for some cases
      --so we insert the record when either id or erecord is available
      IF ( (P_TASK_ERECORD_ID(I) IS NOT NULL)
           OR (P_TASK_IDENTIFIER(I) IS NOT NULL)) THEN

        INSERT INTO GMO_INSTR_TASK_INSTANCE_T
        (
           INSTRUCTION_PROCESS_ID,
           INSTRUCTION_ID,
           INSTR_TASK_SEQ,
           TASK_EREC_ID,
           TASK_IDENTIFIER,
           TASK_VALUE,
           MANUAL_ENTRY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
        )
        VALUES
        (
           P_INSTRUCTION_PROCESS_ID,
           P_INSTRUCTION_ID,
           GMO_INSTR_TASK_INSTANCE_S.NEXTVAL,
           TO_NUMBER(P_TASK_ERECORD_ID(I),999999999999.999999),
           P_TASK_IDENTIFIER(I),
           P_TASK_VALUE(I),
           P_MANUAL_ENTRY,
           L_CREATION_DATE,
           L_CREATED_BY,
           L_LAST_UPDATE_DATE,
           L_LAST_UPDATED_BY,
           L_LAST_UPDATE_LOGIN
        );

     END IF;

    END LOOP;

    -- UPDATE THE PARAMETER IN GMO_INSTR_INSTANCE_T 'DISABLE_TASK' = 'Y' OR 'N'
    UPDATE GMO_INSTR_INSTANCE_T
    SET
        DISABLE_TASK = P_DISABLE_TASK
    WHERE
        INSTRUCTION_ID = P_INSTRUCTION_ID
    AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

    -- UPDATE THE ENTITY KEY IN PERM TABLES FOR THAT INSTRUCTION_ID AND
    -- INSTRUCTION SET ID

    SELECT ENTITY_NAME, ENTITY_KEY
    INTO L_ENTITY_NAME, L_ENTITY_KEY
    FROM GMO_INSTR_SET_INSTANCE_VL
    WHERE
         INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    -- IF THE ENTITY KEY IS internally set by PI while creation,
    -- UPDATE IT
    IF (L_ENTITY_KEY LIKE ( GMO_CONSTANTS_GRP.G_INSTR_PREFIX || '%')
        AND P_ENTITY_KEY IS NOT NULL) THEN
	--Bug 5224619: start
	UPDATE GMO_INSTR_SET_INSTANCE_B
        SET ENTITY_KEY = P_ENTITY_KEY
        WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;
	--Bug 5224619: end

        UPDATE_ENTITY_KEY
        (
              P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
              P_ENTITY_KEY => P_ENTITY_KEY
        );
    END IF;

    -- Acknowledge the task by setting the task ackn status
    -- only if API is called by task application
    IF(P_MANUAL_ENTRY <> GMO_CONSTANTS_GRP.YES ) THEN
            UPDATE GMO_INSTR_INSTANCE_T
            SET TASK_ACKN_STATUS = GMO_CONSTANTS_GRP.G_INSTR_TASK_ACKN_STATUS,
            TASK_ACKN_DATE  = L_CREATION_DATE
            WHERE INSTRUCTION_ID = P_INSTRUCTION_ID
            AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;
    END IF;

    -- COMMIT TASK DATA
    COMMIT;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           ROLLBACK;
           X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        WHEN L_INVALID_PARAM_ERR THEN
           ROLLBACK;
           X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_API_PARAM_ERR');
           FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
           FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

           L_MESG_TEXT := FND_MESSAGE.GET();

           FND_MSG_PUB.ADD_EXC_MSG
           ( G_PKG_NAME,
             L_API_NAME,
             L_MESG_TEXT
           );

           FND_MSG_PUB.COUNT_AND_GET
           (
	     P_COUNT => X_MSG_COUNT,
             P_DATA  => X_MSG_DATA
	   );

           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.SEND_TASK_ACKN',
                 FALSE);
           END IF;

        WHEN L_ENTITY_KEY_ERR  THEN
           ROLLBACK;
           X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_API_PARAM_ERR');
           FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
           FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

           L_MESG_TEXT := FND_MESSAGE.GET();

           FND_MSG_PUB.ADD_EXC_MSG
           ( G_PKG_NAME,
             L_API_NAME,
             L_MESG_TEXT
           );

           FND_MSG_PUB.COUNT_AND_GET
           (
	     P_COUNT => X_MSG_COUNT,
             P_DATA  => X_MSG_DATA
	   );

           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.SEND_TASK_ACKN',
                 FALSE);
           END IF;

        WHEN OTHERS THEN
           ROLLBACK;
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

	   IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.ADD_EXC_MSG
                    (G_PKG_NAME,
                    L_API_NAME);
           END IF;

           FND_MSG_PUB.COUNT_AND_GET
             (   P_COUNT => X_MSG_COUNT,
                 P_DATA  => X_MSG_DATA);

           IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                     'gmo.plsql.GMO_INSTRUCTION_PVT.SEND_TASK_ACKN',
                      FALSE);
           END IF;
END SEND_TASK_ACKN;

-- This API marks the instruction set as CANCELLED
-- It is used to de-activate an instruction set/
PROCEDURE NULLIFY_INSTR_FOR_ENTITY
(
    P_ENTITY_NAME               IN VARCHAR2,
    P_ENTITY_KEY                IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
)
IS
    L_INSTRUCTION_SET_ID NUMBER;

    L_API_NAME VARCHAR2(40);

BEGIN

   L_API_NAME := 'NULLIFY_INSTR_FOR_ENTITY';

   SELECT INSTRUCTION_SET_ID INTO L_INSTRUCTION_SET_ID
   FROM GMO_INSTR_SET_INSTANCE_VL
   WHERE ENTITY_NAME = P_ENTITY_NAME
   AND ENTITY_KEY = P_ENTITY_KEY
   AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
   AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;

   --Set the instruction set status to CANCEL
   --Bug 5224619: start
   UPDATE GMO_INSTR_SET_INSTANCE_B
   SET
       INSTR_SET_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL
   WHERE
       INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;
   --Bug 5224619: end
   --Bug 4730261: start
   RAISE_INSTR_SET_EVENT(P_INSTRUCTION_SET_ID => L_INSTRUCTION_SET_ID);
   --Bug 4730261: end

   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
        (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA   );

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.NULLIFY_INSTR_FOR_ENTITY',
                 FALSE);
        END IF;

END NULLIFY_INSTR_FOR_ENTITY;

-- This API must complete optional instructions in temp table for
-- particular session
PROCEDURE COMPLETE_OPTIONAL_INSTR
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT     OUT NOCOPY NUMBER,
    X_MSG_DATA      OUT NOCOPY VARCHAR2
)
IS PRAGMA AUTONOMOUS_TRANSACTION;
   L_INSTRUCTION_SET_ID NUMBER;

   L_API_NAME VARCHAR2(40);
   L_CREATION_DATE DATE;
   L_CREATED_BY NUMBER;
   L_LAST_UPDATE_DATE DATE;
   L_LAST_UPDATED_BY NUMBER;
   L_LAST_UPDATE_LOGIN NUMBER;


BEGIN

   L_API_NAME := 'COMPLETE_OPTIONAL_INSTR';
   GMO_UTILITIES.GET_WHO_COLUMNS
   (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
   );

   SELECT INSTRUCTION_SET_ID  INTO L_INSTRUCTION_SET_ID
   FROM GMO_INSTR_SET_INSTANCE_T
   WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

   -- This must complete optional instructions in temp table for
   -- particular session
   UPDATE GMO_INSTR_INSTANCE_T
   SET
       INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_DONE,
       LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
       LAST_UPDATED_BY = L_LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
   WHERE
       INSTR_STATUS = GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING
       AND
       INSTRUCTION_ID IN (
         SELECT INSTRUCTION_ID FROM GMO_INSTR_INSTANCE_B
         WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID
         AND  INSTR_ACKN_TYPE = GMO_CONSTANTS_GRP.G_INSTR_OPTIONAL
     )
   AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   --Commit the changes
   COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

	X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
               P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.COMPLETE_OPTIONAL_INSTR',
                 FALSE);
        END IF;

END COMPLETE_OPTIONAL_INSTR;

-- This API returns the Definition process status. It can be
-- MODIFIED or NO_CHANGE.

PROCEDURE GET_DEFN_STATUS
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_DEFINITION_STATUS OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA  OUT NOCOPY VARCHAR2
)
IS
    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(4000);
BEGIN

    L_API_NAME := 'GET_DEFN_STATUS';

    SELECT ATTRIBUTE_VALUE INTO X_DEFINITION_STATUS
    FROM GMO_INSTR_ATTRIBUTES_T
    WHERE ATTRIBUTE_NAME  = GMO_CONSTANTS_GRP.G_DEFINITION_STATUS
    AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND ATTRIBUTE_TYPE = GMO_CONSTANTS_GRP.G_PARAM_INTERNAL;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

	FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_INV_PROCESSID_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );
	FND_MESSAGE.SET_TOKEN('PROCESS_ID', P_INSTRUCTION_PROCESS_ID );

        L_MESG_TEXT := FND_MESSAGE.GET();

	FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                L_API_NAME,
                                L_MESG_TEXT);

        FND_MSG_PUB.COUNT_AND_GET(P_COUNT => X_MSG_COUNT,
                                  P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.GET_DEFN_STATUS',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.GET_DEFN_STATUS',
                 FALSE);
        END IF;

END GET_DEFN_STATUS;


-- This API returns the INSTANCE_STATUS, It can be PENDING or COMPLETE
-- or TERMINATE

PROCEDURE GET_INSTANCE_STATUS
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_INSTANCE_STATUS OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA  OUT NOCOPY VARCHAR2
)
IS
    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(4000);
BEGIN

    L_API_NAME := 'GET_INSTANCE_STATUS';

    SELECT ATTRIBUTE_VALUE INTO X_INSTANCE_STATUS
    FROM GMO_INSTR_ATTRIBUTES_T
    WHERE ATTRIBUTE_NAME  = 'INSTANCE_STATUS'
    AND ATTRIBUTE_TYPE = 'INTERNAL'
    AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

	FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_INV_PROCESSID_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );
	FND_MESSAGE.SET_TOKEN('PROCESS_ID', P_INSTRUCTION_PROCESS_ID );

        L_MESG_TEXT := FND_MESSAGE.GET();

	FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,
                                L_API_NAME,
                                L_MESG_TEXT);

        FND_MSG_PUB.COUNT_AND_GET(P_COUNT => X_MSG_COUNT,
                                  P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.GET_INSTANCE_STATUS',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.GET_INSTANCE_STATUS',
                 FALSE);
        END IF;

END GET_INSTANCE_STATUS;

-- This Private API is used to capture the operator response
--  and store it in Instance Temp Table

PROCEDURE CAPTURE_OPERATOR_RESPONSE
(
    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_OPERATOR_ACKN IN VARCHAR2,
    P_INSTR_COMMENTS IN VARCHAR2,
    P_INSTR_STATUS IN VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2
)
IS PRAGMA AUTONOMOUS_TRANSACTION;
    L_INVALID_PROCESS_ID EXCEPTION;
    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN

    L_API_NAME := 'CAPTURE_OPERATOR_RESPONSE';

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    UPDATE GMO_INSTR_INSTANCE_T
    SET
        OPERATOR_ACKN  = P_OPERATOR_ACKN,
        COMMENTS = P_INSTR_COMMENTS,
        INSTR_STATUS = P_INSTR_STATUS,
        LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = L_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
    WHERE
         INSTRUCTION_ID = P_INSTRUCTION_ID
    AND  INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

    IF(SQL%NOTFOUND ) THEN
      RAISE L_INVALID_PROCESS_ID;
    END IF;

    -- SAVE CHANGES
    COMMIT;

     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN L_INVALID_PROCESS_ID THEN
        ROLLBACK;

	FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_INV_PROCESSID_ERR');
        FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
        FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );
	FND_MESSAGE.SET_TOKEN('PROCESS_ID', P_INSTRUCTION_PROCESS_ID );

        L_MESG_TEXT := FND_MESSAGE.GET();

        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.GMO_INSTRUCTIONS_PVT.CAPTURE_OPERATOR_RESPONSE',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        ROLLBACK;

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CAPTURE_OPERATOR_RESPONSE',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END CAPTURE_OPERATOR_RESPONSE;


-- This API inserts instruction e-record details in e-records table
PROCEDURE INSERT_ERECORD_DETAILS
(
    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_INSTRUCTION_ERECORD_ID IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY VARCHAR2,
    X_MSG_DATA OUT NOCOPY VARCHAR2
)
IS PRAGMA AUTONOMOUS_TRANSACTION;

   L_CREATION_DATE DATE;
   L_CREATED_BY NUMBER;
   L_LAST_UPDATE_DATE DATE;
   L_LAST_UPDATED_BY NUMBER;
   L_LAST_UPDATE_LOGIN NUMBER;

   L_PARAM_ERR EXCEPTION;

   L_API_NAME VARCHAR2(40);

BEGIN

    L_API_NAME := 'INSERT_ERECORD_DETAILS';

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

   IF (P_INSTRUCTION_ID IS NULL OR P_INSTRUCTION_PROCESS_ID IS NULL
     OR P_INSTRUCTION_ERECORD_ID IS NULL ) THEN
             RAISE L_PARAM_ERR;
   END IF;

   INSERT INTO GMO_INSTR_EREC_INSTANCE_T
   (
        INSTRUCTION_ID,
        INSTRUCTION_PROCESS_ID,
        INSTR_EREC_SEQ,
        INSTR_EREC_ID,
        TASK_EREC_ID,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
    )
    VALUES
    (
        P_INSTRUCTION_ID,
        P_INSTRUCTION_PROCESS_ID,
        GMO_INSTR_EREC_INSTANCE_S.NEXTVAL,
        P_INSTRUCTION_ERECORD_ID,
        NULL,
        L_CREATION_DATE,
        L_CREATED_BY,
        L_LAST_UPDATE_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN
    );

    -- SAVE CHANGES
    COMMIT;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;


       IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
       END IF;

       FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT',
                 FALSE);
       END IF;

END INSERT_ERECORD_DETAILS;

-- This API creates temporary instance of instructions from
-- permanent instance tables It is called from CREATE_INSTANCE_CONTEXT
PROCEDURE CREATE_TEMPORARY_INSTANCES
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2
) IS
    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTRUCTION_ID NUMBER;

    CURSOR L_INSTR_SET_CSR IS
    SELECT INSTRUCTION_SET_ID, ACKN_STATUS
    FROM GMO_INSTR_SET_INSTANCE_B
    WHERE ENTITY_NAME = P_ENTITY_NAME
    AND nvl(ENTITY_KEY,1) = nvl(P_ENTITY_KEY,1)
    AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE
    AND INSTR_SET_STATUS <> GMO_CONSTANTS_GRP.G_INSTR_STATUS_CANCEL;

    CURSOR L_INSTR_CSR IS
    SELECT INSTRUCTION_ID, INSTRUCTION_SET_ID,
           COMMENTS, OPERATOR_ACKN, INSTR_STATUS,
           TASK_ACKN_STATUS, TASK_ID
    FROM GMO_INSTR_INSTANCE_VL
    WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

    CURSOR L_INSTR_TASK_CSR IS
    SELECT INSTRUCTION_ID, INSTR_TASK_SEQ, TASK_EREC_ID,
           TASK_IDENTIFIER, TASK_VALUE, MANUAL_ENTRY
    FROM GMO_INSTR_TASK_INSTANCE
    WHERE INSTRUCTION_ID = L_INSTRUCTION_ID;

    CURSOR L_INSTR_EREC_CSR IS
    SELECT INSTRUCTION_ID, INSTR_EREC_SEQ, INSTR_EREC_ID,
    TASK_EREC_ID
    FROM GMO_INSTR_EREC_INSTANCE
    WHERE INSTRUCTION_ID = L_INSTRUCTION_ID;

    L_INSTR_SET_REC L_INSTR_SET_CSR%ROWTYPE;
    L_INSTR_REC L_INSTR_CSR%ROWTYPE;

    L_INSTR_TASK_REC L_INSTR_TASK_CSR%ROWTYPE;
    L_INSTR_EREC_REC L_INSTR_EREC_CSR%ROWTYPE;

    L_API_NAME VARCHAR2(40);

BEGIN

    L_API_NAME := 'CREATE_TEMPORARY_INSTANCES';

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    OPEN L_INSTR_SET_CSR;
    LOOP
    FETCH L_INSTR_SET_CSR INTO L_INSTR_SET_REC;
    EXIT WHEN L_INSTR_SET_CSR%NOTFOUND;

          INSERT INTO GMO_INSTR_SET_INSTANCE_T
          (
                INSTRUCTION_PROCESS_ID,
                INSTRUCTION_SET_ID,
                ACKN_STATUS,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
          )
          VALUES
          (
                P_INSTRUCTION_PROCESS_ID,
                L_INSTR_SET_REC.INSTRUCTION_SET_ID,
                L_INSTR_SET_REC.ACKN_STATUS,
                L_CREATION_DATE, -- FIGURE THIS OUT
                L_CREATED_BY,
                L_LAST_UPDATE_DATE,
                L_LAST_UPDATED_BY,
                L_LAST_UPDATE_LOGIN
          );

          L_INSTRUCTION_SET_ID := L_INSTR_SET_REC.INSTRUCTION_SET_ID;

	  OPEN L_INSTR_CSR;
          LOOP
          FETCH L_INSTR_CSR INTO L_INSTR_REC;
          EXIT WHEN L_INSTR_CSR%NOTFOUND;

               L_INSTRUCTION_ID := L_INSTR_REC.INSTRUCTION_ID;

               INSERT INTO GMO_INSTR_INSTANCE_T
               (
                    INSTRUCTION_PROCESS_ID,
                    INSTRUCTION_ID,
                    COMMENTS,
                    OPERATOR_ACKN,
                    INSTR_STATUS,
                    TASK_ACKN_STATUS,
                    TASK_ID,
                    DISABLE_TASK,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN
               )
               VALUES
               (
                    P_INSTRUCTION_PROCESS_ID,
                    L_INSTR_REC.INSTRUCTION_ID,
                    L_INSTR_REC.COMMENTS,
                    L_INSTR_REC.OPERATOR_ACKN,
                    L_INSTR_REC.INSTR_STATUS,
                    DECODE(L_INSTR_REC.TASK_ID,
		           NULL,NULL,
			   GMO_CONSTANTS_GRP.G_INSTR_TASK_UNACKN_STATUS),
                    L_INSTR_REC.TASK_ID,
                    DECODE(L_INSTR_REC.TASK_ID,NULL,NULL,GMO_CONSTANTS_GRP.NO),
                    L_CREATION_DATE, -- FIGURE THIS OUT
                    L_CREATED_BY,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_LAST_UPDATE_LOGIN
               );

               OPEN L_INSTR_TASK_CSR;
               LOOP
               FETCH L_INSTR_TASK_CSR INTO L_INSTR_TASK_REC;
               EXIT WHEN L_INSTR_TASK_CSR%NOTFOUND;

                     INSERT INTO GMO_INSTR_TASK_INSTANCE_T
                     (
                           INSTRUCTION_ID,
                           INSTRUCTION_PROCESS_ID,
                           INSTR_TASK_SEQ,
                           TASK_EREC_ID,
                           TASK_IDENTIFIER,
                           TASK_VALUE,
                           MANUAL_ENTRY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN
                     )
                     VALUES
                     (
                           L_INSTR_TASK_REC.INSTRUCTION_ID,
                           P_INSTRUCTION_PROCESS_ID,
                           L_INSTR_TASK_REC.INSTR_TASK_SEQ,
                           L_INSTR_TASK_REC.TASK_EREC_ID,
                           L_INSTR_TASK_REC.TASK_IDENTIFIER,
                           L_INSTR_TASK_REC.TASK_VALUE,
                           L_INSTR_TASK_REC.MANUAL_ENTRY,
                           L_CREATION_DATE, -- FIGURE THIS OUT
                           L_CREATED_BY,
                           L_LAST_UPDATE_DATE,
                           L_LAST_UPDATED_BY,
                           L_LAST_UPDATE_LOGIN
                     );

             END LOOP;
             CLOSE L_INSTR_TASK_CSR;

             OPEN L_INSTR_EREC_CSR;
             LOOP
             FETCH L_INSTR_EREC_CSR INTO L_INSTR_EREC_REC;
             EXIT WHEN L_INSTR_EREC_CSR%NOTFOUND;

                   INSERT INTO GMO_INSTR_EREC_INSTANCE_T
                   (
                        INSTRUCTION_ID,
                        INSTRUCTION_PROCESS_ID,
                        INSTR_EREC_SEQ,
                        INSTR_EREC_ID,
                        TASK_EREC_ID,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN

                   )
                   VALUES
                   (
                         L_INSTRUCTION_ID,
                         P_INSTRUCTION_PROCESS_ID,
                         L_INSTR_EREC_REC.INSTR_EREC_SEQ,
                         L_INSTR_EREC_REC.INSTR_EREC_ID,
                         L_INSTR_EREC_REC.TASK_EREC_ID,
                         L_CREATION_DATE, -- FIGURE THIS OUT
                         L_CREATED_BY,
                         L_LAST_UPDATE_DATE,
                         L_LAST_UPDATED_BY,
                         L_LAST_UPDATE_LOGIN
                   );

             END LOOP;
             CLOSE L_INSTR_EREC_CSR;

          END LOOP;
          CLOSE L_INSTR_CSR;

    END LOOP;
    CLOSE L_INSTR_SET_CSR;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
               P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_TEMPORARY_INSTANCES',
                 FALSE);
        END IF;

	-- propogate this exception
        RAISE;

END CREATE_TEMPORARY_INSTANCES;


-- This API creates instance context when called by entity application
-- and returns an Instruction Process Id
PROCEDURE CREATE_INSTANCE_CONTEXT
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    P_CONTEXT_PARAM_NAME IN FND_TABLE_OF_VARCHAR2_255,
    P_CONTEXT_PARAM_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_INSTRUCTION_SET_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2

) IS PRAGMA AUTONOMOUS_TRANSACTION;

    L_INSTRUCTION_PROCESS_ID NUMBER;
    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTR_SET_STATUS VARCHAR2(40);

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN

   L_API_NAME := 'CREATE_INSTANCE_CONTEXT';

   SELECT GMO_INSTR_PROCESS_ID_S.NEXTVAL INTO L_INSTRUCTION_PROCESS_ID
   FROM DUAL;

    -- Begin Validation Block
    BEGIN

        -- GET THE INSTRUCTION SET ID FROM INSTANCE INSTRUCTION SET TABLE
        SELECT MAX(INSTRUCTION_SET_ID) INTO L_INSTRUCTION_SET_ID
        FROM GMO_INSTR_SET_INSTANCE_VL
        WHERE ENTITY_NAME = P_ENTITY_NAME
        AND ENTITY_KEY = P_ENTITY_KEY
        AND INSTRUCTION_TYPE = P_INSTRUCTION_TYPE;

        -- CHECK IF THE INSTRUCTION SET IS NULLIFIED
        SELECT INSTR_SET_STATUS INTO L_INSTR_SET_STATUS
        FROM GMO_INSTR_SET_INSTANCE_VL
        WHERE INSTRUCTION_SET_ID = L_INSTRUCTION_SET_ID;

	-- CHECK THE INSTRUCTION SET STATUS, IT MUST BE ACTIVE
	-- FOR THE PROCESS TO PROCEED FURTHER
	IF( RTRIM(L_INSTR_SET_STATUS) <> GMO_CONSTANTS_GRP.G_PROCESS_ACTIVE ) THEN

	    ROLLBACK;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

	    FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SET_INACTIVE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
            FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

            L_MESG_TEXT := FND_MESSAGE.GET();

            FND_MSG_PUB.ADD_EXC_MSG
             ( G_PKG_NAME,
               L_API_NAME,
               L_MESG_TEXT
              );

             FND_MSG_PUB.COUNT_AND_GET
             (
	        P_COUNT => X_MSG_COUNT,
                P_DATA  => X_MSG_DATA
	     );

             IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                       'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_INSTANCE_CONTEXT',
                       FALSE);
             END IF;

            RETURN;

        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

            IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
            END IF;

             FND_MSG_PUB.COUNT_AND_GET
             (   P_COUNT => X_MSG_COUNT,
                 P_DATA  => X_MSG_DATA);

             IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_DEFN_CONTEXT',
                       FALSE);
             END IF;

            RETURN;
    END; -- Validation Block

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

    INSERT INTO GMO_INSTR_ATTRIBUTES_T
    (
        INSTRUCTION_PROCESS_ID,
        ATTRIBUTE_SEQ,
        ATTRIBUTE_NAME,
        ENTITY_NAME,
        ENTITY_KEY,
        INSTRUCTION_TYPE,
        ATTRIBUTE_TYPE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
    )
    VALUES
    (
        L_INSTRUCTION_PROCESS_ID,
        GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
        GMO_CONSTANTS_GRP.G_PARAM_ENTITY,
        P_ENTITY_NAME,
        P_ENTITY_KEY,
        P_INSTRUCTION_TYPE,
        GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
        L_CREATION_DATE,
        L_CREATED_BY,
        L_LAST_UPDATE_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN
    );

    INSERT INTO GMO_INSTR_ATTRIBUTES_T
    (
              INSTRUCTION_PROCESS_ID,
              ATTRIBUTE_SEQ,
              ATTRIBUTE_NAME,
              ATTRIBUTE_VALUE,
              ATTRIBUTE_TYPE,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN
    )
    VALUES
    (
              L_INSTRUCTION_PROCESS_ID,
              GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
              GMO_CONSTANTS_GRP.G_INSTANCE_STATUS,
              GMO_CONSTANTS_GRP.G_PROCESS_ERROR,
              GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
              L_CREATION_DATE,
              L_CREATED_BY,
              L_LAST_UPDATE_DATE,
              L_LAST_UPDATED_BY,
              L_LAST_UPDATE_LOGIN
    );

    IF ( (P_CONTEXT_PARAM_NAME IS NOT NULL)
      AND (P_CONTEXT_PARAM_VALUE IS NOT NULL )) THEN

     FOR I IN 1..P_CONTEXT_PARAM_NAME.COUNT LOOP
       IF(P_CONTEXT_PARAM_NAME(I) IS NOT NULL) THEN

         INSERT INTO GMO_INSTR_ATTRIBUTES_T
         (
              INSTRUCTION_PROCESS_ID,
              ATTRIBUTE_SEQ,
              ATTRIBUTE_NAME,
              ATTRIBUTE_VALUE,
              ATTRIBUTE_TYPE,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN
         )
         VALUES
         (
              L_INSTRUCTION_PROCESS_ID,
              GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
              P_CONTEXT_PARAM_NAME(i),
              P_CONTEXT_PARAM_VALUE(i),
              GMO_CONSTANTS_GRP.G_PARAM_INTERNAL,
              L_CREATION_DATE,
              L_CREATED_BY,
              L_LAST_UPDATE_DATE,
              L_LAST_UPDATED_BY,
              L_LAST_UPDATE_LOGIN
         );

        END IF;

    END LOOP;
  END IF;

  -- Create temporary table entries from perm, by calling this procedure
  CREATE_TEMPORARY_INSTANCES
  (
       P_INSTRUCTION_PROCESS_ID => L_INSTRUCTION_PROCESS_ID,
       P_ENTITY_NAME => P_ENTITY_NAME,
       P_ENTITY_KEY => P_ENTITY_KEY,
       P_INSTRUCTION_TYPE => P_INSTRUCTION_TYPE,
       X_RETURN_STATUS => X_RETURN_STATUS,
       X_MSG_COUNT => X_MSG_COUNT,
       X_MSG_DATA => X_MSG_DATA
  );

  --Commit changes
  COMMIT;

   X_INSTRUCTION_SET_ID := L_INSTRUCTION_SET_ID;
   X_INSTRUCTION_PROCESS_ID := L_INSTRUCTION_PROCESS_ID;

   X_RETURN_STATUS :=  FND_API.G_RET_STS_SUCCESS;
   X_MSG_COUNT := 0;
   X_MSG_DATA :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        X_RETURN_STATUS :=  FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_INSTANCE_CONTEXT',
                 FALSE);
        END IF;

END CREATE_INSTANCE_CONTEXT;

-- This API creates instance context when called by entity application
-- and returns an Instruction Process Id. This flavor is created for
-- calling applications which only have Instruction Set Id, and not
-- Entity Name, Entity Key and Instruction Type.

PROCEDURE CREATE_INSTANCE_CONTEXT
(
    P_INSTRUCTION_SET_ID IN NUMBER,
    P_CONTEXT_PARAM_NAME IN FND_TABLE_OF_VARCHAR2_255,
    P_CONTEXT_PARAM_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_ENTITY_NAME OUT NOCOPY VARCHAR2,
    X_ENTITY_KEY OUT NOCOPY VARCHAR2,
    X_INSTRUCTION_TYPE OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2
)
IS PRAGMA AUTONOMOUS_TRANSACTION;

    L_INSTRUCTION_SET_ID NUMBER;
    L_INSTRUCTION_TYPE VARCHAR2(40);
    L_ENTITY_NAME VARCHAR2(200);
    L_ENTITY_KEY VARCHAR2(500);

    L_API_NAME VARCHAR2(40);
    L_MESG_TEXT VARCHAR2(1000);

BEGIN

    L_API_NAME := 'CREATE_INSTANCE_CONTEXT';

    BEGIN
         SELECT INSTRUCTION_TYPE, ENTITY_NAME, ENTITY_KEY
         INTO L_INSTRUCTION_TYPE, L_ENTITY_NAME, L_ENTITY_KEY
         FROM GMO_INSTR_SET_INSTANCE_VL WHERE
         INSTRUCTION_SET_ID = P_INSTRUCTION_SET_ID;
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
                ROLLBACK;
                X_INSTRUCTION_PROCESS_ID := -1;
                X_ENTITY_NAME := NULL;
                X_ENTITY_KEY := NULL;
                X_INSTRUCTION_TYPE := NULL;

               FND_MESSAGE.SET_NAME('GMO', 'GMO_INSTR_SET_INACTIVE');
               FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', G_PKG_NAME);
               FND_MESSAGE.SET_TOKEN('API_NAME', L_API_NAME );

               L_MESG_TEXT := FND_MESSAGE.GET();

               FND_MSG_PUB.ADD_EXC_MSG
               ( G_PKG_NAME,
                 L_API_NAME,
                 L_MESG_TEXT
               );

               FND_MSG_PUB.COUNT_AND_GET
               (
	         P_COUNT => X_MSG_COUNT,
                 P_DATA  => X_MSG_DATA
	       );

               IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                     'gmo.plsql.GMO_INSTRUCTIONS_PVT.CREATE_INSTANCE_CONTEXT',
                     FALSE);
               END IF;

               X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

               RETURN;
   END;

   CREATE_INSTANCE_CONTEXT (
       P_ENTITY_NAME => L_ENTITY_NAME,
       P_ENTITY_KEY => L_ENTITY_KEY,
       P_INSTRUCTION_TYPE => L_INSTRUCTION_TYPE,
       P_CONTEXT_PARAM_NAME => P_CONTEXT_PARAM_NAME,
       P_CONTEXT_PARAM_VALUE => P_CONTEXT_PARAM_VALUE,
       X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
       X_INSTRUCTION_SET_ID => L_INSTRUCTION_SET_ID,
       X_RETURN_STATUS => X_RETURN_STATUS,
       X_MSG_COUNT=> X_MSG_COUNT,
       X_MSG_DATA => X_MSG_DATA
   );

   COMMIT;

   X_ENTITY_NAME := L_ENTITY_NAME;
   X_ENTITY_KEY := L_ENTITY_KEY;
   X_INSTRUCTION_TYPE := L_INSTRUCTION_TYPE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG
                   (G_PKG_NAME,
                    L_API_NAME);
        END IF;

        FND_MSG_PUB.COUNT_AND_GET
           (   P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                 'gmo.plsql.GMO_INSTRUCTION_PVT.CREATE_INSTANCE_CONTEXT',
                 FALSE);
        END IF;

        X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END CREATE_INSTANCE_CONTEXT;


--This procedure updates the definition and
--process status attribute values to "MODIFIED" and "SUCCESS"
--respectively in GMO_INSTR_ATTRIBUTES_T for the specified
--instruction process ID.
PROCEDURE UPDATE_INSTR_ATTRIBUTES(P_INSTRUCTION_PROCESS_ID IN VARCHAR2,
                                  P_UPDATE_DEFN_STATUS     IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
     L_INSTRUCTION_PROCESS_ID NUMBER;

     L_API_NAME VARCHAR2(40);

BEGIN

  L_API_NAME := 'UPDATE_INSTR_ATTRIBUTES';

  --Convert the instruction process ID to number.
  L_INSTRUCTION_PROCESS_ID := TO_NUMBER(P_INSTRUCTION_PROCESS_ID,'999999999999.999999');

  --Update the definition status if required based on the flag.
  IF(P_UPDATE_DEFN_STATUS = FND_API.G_TRUE) THEN
    UPDATE
      GMO_INSTR_ATTRIBUTES_T
    SET
      ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_STATUS_MODIFIED
    WHERE
      INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
    AND
      ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_DEFINITION_STATUS;
  END IF;

  --Update the PROCESS_STATUS to success.
  UPDATE
    GMO_INSTR_ATTRIBUTES_T
  SET
    ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_SUCCESS
  WHERE
    INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
  AND
    ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME',G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',L_API_NAME);

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.UPDATE_INSTR_ATTRIBUTES',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;

END UPDATE_INSTR_ATTRIBUTES;

--This procedure sets the definition and
--process status attribute values to "MODIFIED" and "SUCCESS"
--respectively in GMO_INSTR_ATTRIBUTES_T for the specified
--instruction process ID.
PROCEDURE SET_INSTR_STATUS_ATTRIBUTES(P_INSTRUCTION_PROCESS_ID IN VARCHAR2,
                                         P_UPDATE_DEFN_STATUS     IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
     L_INSTRUCTION_PROCESS_ID NUMBER;

     L_API_NAME VARCHAR2(40);

BEGIN

  L_API_NAME := 'SET_INSTR_STATUS_ATTRIBUTES';

  --Convert the instruction process ID to number.
  L_INSTRUCTION_PROCESS_ID := TO_NUMBER(P_INSTRUCTION_PROCESS_ID,'999999999999.999999');

  --Update the definition status if required based on the flag.
  IF(P_UPDATE_DEFN_STATUS = FND_API.G_TRUE) THEN
    UPDATE
      GMO_INSTR_ATTRIBUTES_T
    SET
      ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_STATUS_MODIFIED
    WHERE
      INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
    AND
      ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_DEFINITION_STATUS;
  END IF;

  --Update the PROCESS_STATUS to success.
  UPDATE
    GMO_INSTR_ATTRIBUTES_T
  SET
    ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_SUCCESS
  WHERE
    INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
  AND
    ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME',G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',L_API_NAME);

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.SET_INSTR_STATUS_ATTRIBUTES',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;

END SET_INSTR_STATUS_ATTRIBUTES;



--This procedure deletes the instruction set details in
-- GMO_INSTR_SET_DEFN_T for the specified
--process ID. It also updates the process status in
--GMO_INSTR_ATTRUBUTES_T to "CANCEL".

PROCEDURE DELETE_INSTR_SET_DETAILS
(
  P_INSTRUCTION_PROCESS_ID IN VARCHAR2
)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

L_INSTRUCTION_PROCESS_ID NUMBER;

BEGIN

  L_INSTRUCTION_PROCESS_ID := TO_NUMBER(P_INSTRUCTION_PROCESS_ID,'999999999999.999999');

  --Update the PROCESS_STATUS to cancel.
  UPDATE
    GMO_INSTR_ATTRIBUTES_T
  SET
    ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_CANCEL
  WHERE
    INSTRUCTION_PROCESS_ID = L_INSTRUCTION_PROCESS_ID
  AND
    ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_INSTRUCTION_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','DELETE_INSTR_SET_DETAILS');

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.DELETE_INSTR_SET_DETAILS',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;

END DELETE_INSTR_SET_DETAILS;

-- This function gets the value of specified process variable
FUNCTION GET_PROCESS_VARIABLE
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER,
  P_ATTRIBUTE_NAME IN VARCHAR2 ,
  P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2
IS
        L_ATTRIBUTE_VALUE VARCHAR2(1000);
BEGIN
        SELECT ATTRIBUTE_VALUE INTO L_ATTRIBUTE_VALUE
        FROM GMO_INSTR_ATTRIBUTES_T
        WHERE ATTRIBUTE_NAME = P_ATTRIBUTE_NAME
        AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
        AND ATTRIBUTE_TYPE = P_ATTRIBUTE_TYPE;

        RETURN L_ATTRIBUTE_VALUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        L_ATTRIBUTE_VALUE := NULL;
        RETURN L_ATTRIBUTE_VALUE;

END GET_PROCESS_VARIABLE;


-- This function inserts a process variable in temporary
-- session table gmo_instr_attributes_t

FUNCTION INSERT_PROCESS_VARIABLE
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER ,
  P_ATTRIBUTE_NAME IN VARCHAR2 ,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2
IS
PRAGMA AUTONOMOUS_TRANSACTION;

    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;

    L_COUNT NUMBER;

BEGIN

    GMO_UTILITIES.GET_WHO_COLUMNS
    (
        X_CREATION_DATE => L_CREATION_DATE,
        X_CREATED_BY => L_CREATED_BY,
        X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
    );

   SELECT COUNT(*) INTO L_COUNT FROM GMO_INSTR_ATTRIBUTES_T
   WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
   AND   ATTRIBUTE_NAME = P_ATTRIBUTE_NAME
   AND   ATTRIBUTE_TYPE = P_ATTRIBUTE_TYPE;

   IF (P_ATTRIBUTE_NAME IS NOT NULL AND P_INSTRUCTION_PROCESS_ID IS NOT NULL) THEN
     IF L_COUNT > 0 THEN

      UPDATE GMO_INSTR_ATTRIBUTES_T
        SET ATTRIBUTE_VALUE = P_ATTRIBUTE_VALUE,
            LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
            LAST_UPDATED_BY = L_LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN
      WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
      AND   ATTRIBUTE_NAME = P_ATTRIBUTE_NAME
      AND   ATTRIBUTE_TYPE = P_ATTRIBUTE_TYPE;


     ELSE

	INSERT INTO GMO_INSTR_ATTRIBUTES_T
        (
           INSTRUCTION_PROCESS_ID,
           ATTRIBUTE_SEQ,
           ATTRIBUTE_NAME,
           ATTRIBUTE_VALUE,
           ATTRIBUTE_TYPE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
        )
        VALUES
        (
           P_INSTRUCTION_PROCESS_ID,
           GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
           P_ATTRIBUTE_NAME,
           P_ATTRIBUTE_VALUE,
           P_ATTRIBUTE_TYPE,
           L_CREATION_DATE,
           L_CREATED_BY,
           L_LAST_UPDATE_DATE,
           L_LAST_UPDATED_BY,
           L_LAST_UPDATE_LOGIN
        );
     END IF;
   ELSE
        RETURN GMO_CONSTANTS_GRP.NO;
   END IF;

   COMMIT;

   RETURN GMO_CONSTANTS_GRP.YES;

EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          RETURN GMO_CONSTANTS_GRP.NO;

END INSERT_PROCESS_VARIABLE;


-- This function sets the process variable to the value
-- passed in the input.

FUNCTION SET_PROCESS_VARIABLE
( P_INSTRUCTION_PROCESS_ID IN NUMBER ,
  P_ATTRIBUTE_NAME IN VARCHAR2 ,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2
IS
    L_CREATION_DATE DATE;
    L_CREATED_BY NUMBER;
    L_LAST_UPDATE_DATE DATE;
    L_LAST_UPDATED_BY NUMBER;
    L_LAST_UPDATE_LOGIN NUMBER;
    L_ATTRIBUTE_VALUE VARCHAR2(1000);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

        UPDATE GMO_INSTR_ATTRIBUTES_T
        SET ATTRIBUTE_VALUE = P_ATTRIBUTE_VALUE
        WHERE ATTRIBUTE_NAME = P_ATTRIBUTE_NAME
        AND ATTRIBUTE_TYPE = P_ATTRIBUTE_TYPE
        AND INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

        IF(SQL%ROWCOUNT = 0 ) THEN

                GMO_UTILITIES.GET_WHO_COLUMNS
                (
                  X_CREATION_DATE => L_CREATION_DATE,
                  X_CREATED_BY => L_CREATED_BY,
                  X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
                  X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
                  X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
                );

                INSERT INTO GMO_INSTR_ATTRIBUTES_T
                (
                        INSTRUCTION_PROCESS_ID,
                        ATTRIBUTE_SEQ,
                        ATTRIBUTE_NAME,
                        ATTRIBUTE_VALUE,
                        ATTRIBUTE_TYPE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN
                )
                VALUES
                (
                         P_INSTRUCTION_PROCESS_ID,
                         GMO_INSTR_ATTRIBUTES_T_S.NEXTVAL,
                         P_ATTRIBUTE_NAME,
                         P_ATTRIBUTE_VALUE,
                         P_ATTRIBUTE_TYPE,
                         L_CREATION_DATE,
                         L_CREATED_BY,
                         L_LAST_UPDATE_DATE,
                         L_LAST_UPDATED_BY,
                         L_LAST_UPDATE_LOGIN
                );
        END IF;

        COMMIT;

        RETURN GMO_CONSTANTS_GRP.YES;
EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN GMO_CONSTANTS_GRP.NO;

END SET_PROCESS_VARIABLE;

-- This API is wrapper over ERES E-record Validation API.
-- Returns Y or N based on E-record Id validity

PROCEDURE VALIDATE_TASK_ERECORD_ID
(
  P_TASK_ERECORD_ID   IN FND_TABLE_OF_VARCHAR2_255,
  X_ERECORD_ID_INVALID OUT NOCOPY VARCHAR2,
  X_ERECORD_LIST_STR OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  X_MSG_COUNT  OUT NOCOPY NUMBER,
  X_MSG_DATA  OUT NOCOPY VARCHAR2
)
IS
   L_MSG_COUNT NUMBER;
   L_MSG_DATA VARCHAR2(4000);
   L_RETURN_STATUS VARCHAR2(1);
   L_ERECORD_ID VARCHAR2(100);
   L_INVALID_ERECORD_LIST VARCHAR2(4000);

   L_MESG_TEXT VARCHAR2(1000);
   L_API_NAME VARCHAR2(40);

BEGIN

    L_API_NAME  := 'VALIDATE_TASK_ERECORD_ID';

    L_INVALID_ERECORD_LIST := '';

    FOR I IN 1..P_TASK_ERECORD_ID.COUNT LOOP
           L_ERECORD_ID := P_TASK_ERECORD_ID(I);

           EDR_ERES_EVENT_PUB.VALIDATE_ERECORD
           (
                           p_api_version  => 1.0,
                           P_init_msg_list => FND_API.G_FALSE ,
                           x_return_status  => L_RETURN_STATUS ,
                           X_msg_count      => L_MSG_COUNT ,
                           x_msg_data       => L_MSG_DATA,
                           p_erecord_id      => TO_NUMBER(L_ERECORD_ID,999999999999.999999)
           );

           IF(L_RETURN_STATUS = FND_API.G_RET_STS_ERROR) THEN
                  L_INVALID_ERECORD_LIST := L_INVALID_ERECORD_LIST || ',' || L_ERECORD_ID;
           END IF;

    END LOOP;

    IF ( LENGTH(L_INVALID_ERECORD_LIST) > 0) THEN
              X_ERECORD_LIST_STR := SUBSTR(L_INVALID_ERECORD_LIST,2,LENGTH(L_INVALID_ERECORD_LIST));
              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
              X_ERECORD_ID_INVALID := GMO_CONSTANTS_GRP.YES;
    ELSE
              X_ERECORD_ID_INVALID := GMO_CONSTANTS_GRP.NO;
              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    END IF;

EXCEPTION
        WHEN OTHERS THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          X_ERECORD_ID_INVALID := GMO_CONSTANTS_GRP.YES;

	  --Diagnostics Start
          FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
          FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_INSTRUCTION_PVT');
          FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',L_API_NAME);
          L_MESG_TEXT := FND_MESSAGE.GET;

          if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                  FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.'|| L_API_NAME,
                      FALSE
                  );
         end if;

        FND_MSG_PUB.ADD_EXC_MSG
        (  G_PKG_NAME,
             L_API_NAME,
             L_MESG_TEXT
        );

        FND_MSG_PUB.COUNT_AND_GET
        (
	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	);

END VALIDATE_TASK_ERECORD_ID;

-- This procedure is used to fetch the instruction set and related
-- instruction details in XML format

PROCEDURE GET_INSTR_XML(P_INSTRUCTION_PROCESS_ID IN NUMBER,
                        X_OUTPUT_XML  OUT NOCOPY CLOB)
IS
--This variable would hold the XML details in XMLType format.
L_INSTR_XML XMLTYPE;

BEGIN
  --This SQL Query would provide all the instruction details for the specified process ID in XMLType.
  SELECT XMLELEMENT("INSTRUCTIONS",XMLAGG(XMLELEMENT("INSTRUCTION_SET_DETAILS",
                         XMLFOREST(INSTR_SET.INSTRUCTION_PROCESS_ID AS INSTRUCTION_PROCESS_ID,
                         INSTR_SET.INSTR_SET_NAME AS INSTRUCTION_SET_NAME,
                         INSTR_SET.INSTR_SET_DESC AS INSTRUCTION_SET_DESC,
                         (SELECT
                                LK.MEANING
                          FROM
                                FND_LOOKUP_VALUES_VL LK
                          WHERE
                                LK.LOOKUP_TYPE = 'GMO_INSTR_'||INSTR_SET.ENTITY_NAME
                          AND
                                LK.LOOKUP_CODE = INSTR_SET.INSTRUCTION_TYPE) AS INSTRUCTION_TYPE,
                          (SELECT
                                 XMLAGG(XMLELEMENT("INSTRUCTION_DETAILS",
                                 XMLFOREST(INSTR.INSTR_NUMBER AS INSTRUCTION_NUMBER,
                                 INSTR.INSTRUCTION_TEXT AS INSTRUCTION_TEXT,
                                 (SELECT
                                    LK1.MEANING
                                 FROM
                                     FND_LOOKUP_VALUES_VL LK1
                                 WHERE
                                    LK1.LOOKUP_TYPE = 'GMO_INSTR_ACKN_TYPES'
                                 AND
                                   LK1.LOOKUP_CODE = INSTR.INSTR_ACKN_TYPE) AS INSTRUCTION_ACKN_TYPE,
                                (SELECT
                                    TK.DISPLAY_NAME
                                FROM
                                    GMO_INSTR_TASK_DEFN_VL TK
                                WHERE
                                   TK.TASK_ID = INSTR.TASK_ID) AS TASK_NAME,
                                   INSTR.TASK_ATTRIBUTE AS TASK_ATTRIBUTE,
                                   INSTR.TASK_LABEL AS TASK_LABEL,
                                (SELECT
                                 DECODE((SELECT COUNT(*) FROM GMO_INSTR_APPR_DEFN_T APPR
                                         WHERE
                                         APPR.INSTRUCTION_PROCESS_ID = INSTR_SET.INSTRUCTION_PROCESS_ID
                                         AND APPR.INSTRUCTION_ID = INSTR.INSTRUCTION_ID),0,
                                           FND_MESSAGE.GET_STRING('GMO','GMO_INSTR_SIG_NOT_REQUIRED'),
                                           FND_MESSAGE.GET_STRING('GMO','GMO_INSTR_SIG_REQUIRED'))
                                 FROM DUAL)
                                 AS SIGNATURE_REQUIRED
                                 )
                            )
                        )
                        FROM GMO_INSTR_DEFN_T INSTR
                        WHERE INSTR.INSTRUCTION_SET_ID = INSTR_SET.INSTRUCTION_SET_ID
                        AND INSTR.INSTRUCTION_PROCESS_ID = INSTR_SET.INSTRUCTION_PROCESS_ID) AS "RELATED_INSTRUCTIONS")
                      )
                 )
             )
INTO L_INSTR_XML
FROM GMO_INSTR_SET_DEFN_T INSTR_SET
WHERE INSTR_SET.INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID;

--Convert XMLType to CLOB.
X_OUTPUT_XML := L_INSTR_XML.GETCLOBVAL();

END GET_INSTR_XML;

FUNCTION SET_PROCESS_ATTRIBUTES
(
   P_INSTRUCTION_PROCESS_ID IN NUMBER,
   P_ATTRIBUTE_NAME IN FND_TABLE_OF_VARCHAR2_255,
   P_ATTRIBUTE_VALUE IN FND_TABLE_OF_VARCHAR2_255,
   P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2
IS
PRAGMA AUTONOMOUS_TRANSACTION;

 L_PARAM_NAME VARCHAR2(200);
 L_PARAM_VALUE VARCHAR2(500);
 L_RETURN_STATUS VARCHAR2(1);

BEGIN

   FOR I IN 1..P_ATTRIBUTE_NAME.COUNT LOOP
        L_PARAM_NAME := P_ATTRIBUTE_NAME(I);

        IF( L_PARAM_NAME IS NOT NULL) THEN
          -- set process variable will update the attribute if it exists,
          -- else, inserts it
            L_RETURN_STATUS := SET_PROCESS_VARIABLE(
                               P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
                               P_ATTRIBUTE_NAME => L_PARAM_NAME,
                               P_ATTRIBUTE_VALUE => P_ATTRIBUTE_VALUE(I),
                               P_ATTRIBUTE_TYPE => P_ATTRIBUTE_TYPE);
        END IF;

	--Check the return status for each process attribute
	IF (L_RETURN_STATUS = GMO_CONSTANTS_GRP.NO) THEN
             ROLLBACK;
             APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

   END LOOP;

   -- SAVE CHANGES
   COMMIT;

   RETURN GMO_CONSTANTS_GRP.YES;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        APP_EXCEPTION.RAISE_EXCEPTION;

END SET_PROCESS_ATTRIBUTES;

-- This API returns the Task parameter from the GMO Attributes Temp table
FUNCTION GET_TASK_PARAMETER
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER,
  P_ATTRIBUTE_NAME IN VARCHAR2
)
RETURN VARCHAR2
IS PRAGMA AUTONOMOUS_TRANSACTION;
   L_PARAM_VALUE VARCHAR2(500);
BEGIN

   L_PARAM_VALUE :=  GET_PROCESS_VARIABLE(P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
                                          P_ATTRIBUTE_NAME => P_ATTRIBUTE_NAME,
                                          P_ATTRIBUTE_TYPE => GMO_CONSTANTS_GRP.G_PARAM_TASK );
   RETURN L_PARAM_VALUE;

EXCEPTION
   WHEN OTHERS THEN
     APP_EXCEPTION.RAISE_EXCEPTION;

END GET_TASK_PARAMETER;

-- This API adds the selected instruction to the working instruction set during
-- Instruction setup time.

PROCEDURE ADD_INSTRUCTIONS (
				P_INSTRUCTION_PROCESS_ID IN NUMBER,
				P_INSTRUCTION_SET_ID IN NUMBER,
				P_INSTRUCTION_ID IN NUMBER,
				P_ADD_MODE IN VARCHAR2,
				P_INSTRUCTIONS IN FND_TABLE_OF_VARCHAR2_255,
				P_INSTRUCTION_NOS IN FND_TABLE_OF_VARCHAR2_255,
				X_RETURN_STATUS OUT NOCOPY VARCHAR2,
				X_MSG_COUNT OUT NOCOPY NUMBER,
				X_MSG_DATA OUT NOCOPY VARCHAR2
			   )
IS PRAGMA AUTONOMOUS_TRANSACTION;

l_creation_date date;
l_created_by number;
l_last_update_date date;
l_last_updated_by number;
l_last_update_login number;

l_count number;
l_working_instr_seq number;

l_working_instruction_id number;
l_instruction_id number;
l_instr_seq number;
l_task_id number;
l_task_attribute_id varchar2(4000);
l_task_attribute varchar2(4000);
l_instr_ackn_type varchar2(40);
l_instr_text varchar2(4000);
l_task_label varchar2(200);
l_approver_seq number;
l_role_name varchar2(300);
l_appr_count number;
l_valid_process number;
-- Bug 5686314 : start
l_maximum_allowed_task number;
l_task_count_per_inst_set number;
-- Bug 5686314 : End

cursor get_instr_detail is
select instruction_id, task_id, task_attribute_id,
        task_attribute, instr_ackn_type,
	instruction_text, task_label
from gmo_instr_defn_vl
where instruction_id = l_instruction_id;

cursor get_instr_appr_detail is
select approver_seq, role_name, role_count
from gmo_instr_appr_defn
where instruction_id = l_instruction_id;

cursor is_valid_process is
select count(*) from gmo_instr_set_defn_t
where instruction_set_id = P_INSTRUCTION_SET_ID
and instruction_process_id = P_INSTRUCTION_PROCESS_ID;
-- Bug 5686314 : rvsingh :start
  cursor task_count_per_inst_set is
	select count(*)  from gmo_instr_defn_t where
	instruction_process_id = p_instruction_process_id
	AND instruction_set_id = p_instruction_set_id
	AND task_id =l_task_id;

 INVALID_TASK_ERR exception;
-- Bug 5686314 : rvsingh :End

INVALID_PROCESS_ERR exception;
INVALID_PROCESS_INSTR_ERR exception;

BEGIN
	GMO_UTILITIES.GET_WHO_COLUMNS
	(
		X_CREATION_DATE => L_CREATION_DATE,
		X_CREATED_BY => L_CREATED_BY,
		X_LAST_UPDATE_DATE => L_LAST_UPDATE_DATE,
		X_LAST_UPDATED_BY => L_LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN => L_LAST_UPDATE_LOGIN
	);

	open is_valid_process;
	fetch is_valid_process into l_valid_process;
	close is_valid_process;

	if (l_valid_process = 0) then
		raise INVALID_PROCESS_ERR;
	end if;

	l_count := p_instructions.count;
	l_working_instr_seq := 0;
	l_instr_seq := 0;

	if (l_count > 0) then

		if (p_instruction_id is not null) then
			select instr_seq into l_instr_seq
			from 	gmo_instr_defn_t
			where instruction_set_id = P_INSTRUCTION_SET_ID
			and instruction_process_id = P_INSTRUCTION_PROCESS_ID
			and instruction_id = P_INSTRUCTION_ID;

			if (l_instr_seq <> 0) then
				if (P_ADD_MODE = 'AFTER') then
					l_working_instr_seq := l_instr_seq + 1;
				elsif (P_ADD_MODE = 'BEFORE') then
					l_working_instr_seq := l_instr_seq;
				end if;

				update gmo_instr_defn_t
				set instr_seq = instr_seq + l_count
				where instruction_set_id = P_INSTRUCTION_SET_ID
				and instruction_process_id = P_INSTRUCTION_PROCESS_ID
				and instr_seq >= l_working_instr_seq;

			else
				raise INVALID_PROCESS_INSTR_ERR;
			end if;

		end if;

		if (l_working_instr_seq = 0) then
			select nvl(max(instr_seq), 0) into l_working_instr_seq
			from gmo_instr_defn_t
			where instruction_set_id = P_INSTRUCTION_SET_ID
			and instruction_process_id = P_INSTRUCTION_PROCESS_ID;

			l_working_instr_seq := l_working_instr_seq + 1;
		end if;

		for i in 1 .. P_INSTRUCTIONS.count loop
			l_instruction_id := to_number (P_INSTRUCTIONS (i));

			open get_instr_detail;
			fetch get_instr_detail
			into l_instruction_id,l_task_id,
			l_task_attribute_id,l_task_attribute,
			l_instr_ackn_type, l_instr_text, l_task_label;

			close get_instr_detail;

			if (l_instruction_id is not null) then
                             -- task id is not null then check with maximum allowed task
	                   if(l_task_id IS NOT NULL) THEN
			            select  max_allowed_task  into l_maximum_allowed_task from GMO_INSTR_TASK_DEFN_VL
				    where task_id = l_task_id;
			            open task_count_per_inst_set;
				    fetch task_count_per_inst_set into l_task_count_per_inst_set;
	  	                    if(l_task_count_per_inst_set >= l_maximum_allowed_task) THEN
				 	   RAISE INVALID_TASK_ERR;
			            end if;
                           end if;

			select gmo_instr_defn_s.nextval into l_working_instruction_id from dual;

			 insert into gmo_instr_defn_t
                                 (instruction_id,
                                  instruction_process_id,
                                  instruction_text,
                                  instruction_set_id,
                                  instr_seq,
                                  task_id,
                                  task_attribute_id,
                                  task_attribute,
                                  instr_ackn_type,
                                  instr_number,
                                  creation_date,
                                  created_by,
                                  last_update_date,
                                  last_updated_by,
                                  last_update_login,
                                  task_label)
		     	         values
                                 (
                                   l_working_instruction_id,
                                   p_instruction_process_id,
                                   l_instr_text,
                                   p_instruction_set_id,
                                   l_working_instr_seq,
                                   l_task_id,
                                   l_task_attribute_id,
                                   l_task_attribute,
                                   l_instr_ackn_type,
                                   P_INSTRUCTION_NOS(i),
                                   l_creation_date,
                                   l_created_by,
                                   l_last_update_date,
                                   l_last_updated_by,
                                   l_last_update_login,
                                   l_task_label
                                 );

				FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments (
				                X_from_entity_name => 'GMO_INSTR_DEFN_B',
                        			X_from_pk1_value => l_instruction_id,
                         			X_from_pk2_value => NULL,
                                	        X_from_pk3_value => NULL,
                         			X_from_pk4_value => NULL,
                    			        X_from_pk5_value => NULL,
			                        X_to_entity_name => 'GMO_INSTR_DEFN_T',
			                        X_to_pk1_value => l_working_instruction_id,
			                        X_to_pk2_value => P_INSTRUCTION_PROCESS_ID,
			                        X_to_pk3_value => NULL,
			                        X_to_pk4_value => NULL,
			                        X_to_pk5_value => NULL,
			                        X_created_by => L_CREATED_BY ,
			                        X_last_update_login => L_LAST_UPDATE_LOGIN,
			                        X_program_application_id => NULL,
			                        X_program_id => NULL,
			                        X_request_id => NULL,
			                        X_automatically_added_flag => 'N',
			                        X_from_category_id => NULL,
			                        X_to_category_id => NULL
				);

				open get_instr_appr_detail;
				loop
				fetch get_instr_appr_detail into l_approver_seq,l_role_name, l_appr_count;
				exit when get_instr_appr_detail%notfound;

					select gmo_instr_appr_defn_s.nextval
					into l_approver_seq from dual;

					insert into
					gmo_instr_appr_defn_t
  					   (instruction_id, instruction_process_id,
					    approver_seq, role_name, role_count, creation_date,
					    created_by, last_update_date, last_updated_by, last_update_login)
					values (l_working_instruction_id, p_instruction_process_id,
  					      l_approver_seq, l_role_name, l_appr_count, l_creation_date,
					      l_created_by, l_last_update_date, l_last_updated_by, l_last_update_login);

				end loop;
				close get_instr_appr_detail;
				l_working_instr_seq := l_working_instr_seq + 1;
			end if;

		end loop;

	end if;

	commit;

	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
       WHEN INVALID_TASK_ERR THEN
       ROLLBACK;

     	X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMO', 'GMO_EXCEEDED_TASK');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.COUNT_AND_GET
        (
    	    P_COUNT => X_MSG_COUNT,
            P_DATA  => X_MSG_DATA
	    );
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                'gmo.plsql.gmo_instructions_pvt.add_instructions',
                 FALSE);
        END IF;
	WHEN OTHERS THEN
		rollback;
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_INSTR_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE', SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_instructions_pvt.add_instructions', FALSE);
		end if;

END ADD_INSTRUCTIONS;


PROCEDURE GET_INSTR_INSTANCE_XML
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER,
  X_OUTPUT_XML OUT NOCOPY CLOB
)

IS

--This variable would hold the required instruction details in XML format.
L_INSTR_XML XMLTYPE;

BEGIN

 --This SQLX query will fetch us the required XML.
 SELECT XMLELEMENT("INSTRUCTION_SET",XMLAGG(XMLELEMENT("INSTRUCTION_SET_DETAILS",
                                   XMLFOREST(INSTR_SET.INSTRUCTION_PROCESS_ID AS INSTRUCTION_PROCESS_ID,
                                             INSTR_SETVL.INSTR_SET_NAME AS INSTRUCTION_SET_NAME,
                                             INSTR_SETVL.INSTR_SET_DESC AS INSTRUCTION_SET_DESC,
                                             (SELECT
                                                     LK.MEANING
                                              FROM
                                                     FND_LOOKUP_VALUES_VL LK
                                              WHERE
                                                     LK.LOOKUP_TYPE = 'GMO_INSTR_'||INSTR_SETVL.ENTITY_NAME
                                              AND
                                                     LK.LOOKUP_CODE = INSTR_SETVL.INSTRUCTION_TYPE) AS INSTRUCTION_TYPE,
                                             (SELECT
                                                     XMLAGG(XMLELEMENT("INSTRUCTION_DETAILS",XMLFOREST(INSTRVL.INSTRUCTION_TEXT,
                                                     (SELECT
                                                             MEANING
                                                      FROM
                                                             FND_LOOKUP_VALUES_VL LK1
                                                      WHERE
                                                             LK1.LOOKUP_TYPE = 'GMO_INSTR_STATUS_TYPES'
                                                      AND
                                                             LK1.LOOKUP_CODE = INSTR.INSTR_STATUS) AS INSTRUCTION_STATUS,
                                                      (SELECT
                                                             MEANING
                                                       FROM
                                                             FND_LOOKUP_VALUES_VL LK2
                                                       WHERE
                                                             LK2.LOOKUP_TYPE = 'GMO_INSTR_ACKN_TYPES'
                                                       AND LK2.LOOKUP_CODE = INSTRVL.INSTR_ACKN_TYPE)
                                                       AS INSTRUCTION_ACKN_TYPE,
                                                       decode(INSTR.INSTR_STATUS,GMO_CONSTANTS_GRP.G_INSTR_STATUS_PENDING,
                                                              NULL,
                                                              GMO_UTILITIES.GET_USER_DISPLAY_NAME(INSTR.LAST_UPDATED_BY))
                                                       AS PERFORMED_BY,
                                                       INSTR.LAST_UPDATE_DATE LAST_UPDATE_DATE,
                                                       INSTR.COMMENTS COMMENTS,
                                                       (SELECT
                                                               MAX(EREC.INSTR_EREC_ID)
                                                        FROM
                                                               GMO_INSTR_EREC_INSTANCE EREC
                                                        WHERE
                                                               EREC.INSTRUCTION_ID = INSTR.INSTRUCTION_ID)
                                                        AS INSTRUCTION_ERECORD_ID,
                                                        (SELECT XMLAGG(XMLELEMENT("TASK_DETAILS",XMLFOREST(TK.TASK_EREC_ID AS TASK_ERECORD_ID,
                                                                     TK.TASK_IDENTIFIER AS TASK_IDENTIFIER,
                                                                     TK.TASK_VALUE AS TASK_VALUE)))
                                                        FROM
                                                        GMO_INSTR_TASK_INSTANCE TK
							WHERE TK.INSTRUCTION_ID = INSTR.INSTRUCTION_ID) AS TASKS
                                                        )
                                                )
                                  )
                                  FROM GMO_INSTR_INSTANCE_T INSTR,
                                       GMO_INSTR_INSTANCE_VL INSTRVL
                                       WHERE INSTR.INSTRUCTION_PROCESS_ID = INSTR_SET.INSTRUCTION_PROCESS_ID
                                       AND   INSTR.INSTRUCTION_ID = INSTRVL.INSTRUCTION_ID) AS "INSTRUCTIONS")
                      )
                 )
             )
             INTO  L_INSTR_XML
  FROM  GMO_INSTR_SET_INSTANCE_T INSTR_SET,
        GMO_INSTR_SET_INSTANCE_VL INSTR_SETVL
  WHERE INSTR_SET.INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
  AND   INSTR_SETVL.INSTRUCTION_SET_ID = INSTR_SET.INSTRUCTION_SET_ID;

  --Return the CLOB value of the XML.
  X_OUTPUT_XML :=  L_INSTR_XML.GETCLOBVAL();

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_INSTRUCTION_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_INSTR_INSTANCE_XML');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.GET_INSTR_INSTANCE_XML',
                      FALSE
                     );
    end if;
  APP_EXCEPTION.RAISE_EXCEPTION;

END GET_INSTR_INSTANCE_XML;


--This function is used to terminate the instruction definition process identified by the
--specified process ID.
PROCEDURE TERMINATE_INSTR_DEFN_PROCESS
(P_INSTRUCTION_PROCESS_ID IN NUMBER)

IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  --Update the process status to complete for the instruction definition identified by the specified process ID.
  UPDATE GMO_INSTR_ATTRIBUTES_T
    SET   ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_TERMINATE
    WHERE INSTRUCTION_PROCESS_ID = P_INSTRUCTION_PROCESS_ID
    AND   ATTRIBUTE_TYPE = GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
    AND   ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS;

  --Commit the transaction.
  COMMIT;

  EXCEPTION WHEN OTHERS THEN

    ROLLBACK;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME',G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','TERMINATE_INSTR_DEFN_PROCESS');

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_INSTRUCTION_PVT.TERMINATE_INSTR_DEFN_PROCESS',
                      FALSE
                     );
    end if;

    APP_EXCEPTION.RAISE_EXCEPTION;

END TERMINATE_INSTR_DEFN_PROCESS;

--Bug 5383022: start
procedure is_task_attribute_used
(
	p_instruction_process_id IN number,
	p_attribute_name IN varchar2,
	p_attribute_key IN varchar2,
	x_used_flag OUT NOCOPY varchar2,
	x_return_status OUT NOCOPY varchar2,
	x_msg_count OUT NOCOPY number,
	x_msg_data OUT NOCOPY varchar2
)
IS
	l_check_attribute       varchar2(4000);
	l_count                 number;
	l_total_count           number;
	l_user_response         varchar2(1);
	l_instruction_set_id    number;
	l_instruction_process_id number;
	l_valid_process         number;
BEGIN

	 l_check_attribute := null;
	 l_count := 0;
	 l_instruction_process_id := p_instruction_process_id;

	 --check valid process
	 SELECT COUNT(*) into l_valid_process FROM GMO_INSTR_ATTRIBUTES_T
	 WHERE INSTRUCTION_PROCESS_ID = p_instruction_process_id
	 AND ATTRIBUTE_NAME = GMO_CONSTANTS_GRP.G_PROCESS_STATUS
	 AND ATTRIBUTE_VALUE = GMO_CONSTANTS_GRP.G_PROCESS_SUCCESS;

	 if (l_valid_process = 0) then
			 l_instruction_process_id := -1;
	 end if;


	 if (p_attribute_name = GMO_CONSTANTS_GRP.ENTITY_ACTIVITY) then
			 --attribute key is oprnLindId
			 l_check_attribute := p_attribute_key || '$' || '%';
	 elsif (p_attribute_name = GMO_CONSTANTS_GRP.ENTITY_RESOURCE) then
			 --attribute key is oprnLineId$Resources
			 l_check_attribute := p_attribute_key;
	 elsif (p_attribute_name = GMO_CONSTANTS_GRP.ENTITY_MATERIAL) then
			 --attribute key is formulaLineId
			 l_check_attribute := p_attribute_key;
	 end if;

	 if (l_check_attribute is not null) then
		BEGIN
			if (l_instruction_process_id is null or l_instruction_process_id = -1) then
				--if process is not valid check permanent tables
				--we are not using any specific entity, so it will take care of all levels
				select count(*) into l_count
				from gmo_instr_defn_b
				where task_attribute_id like l_check_attribute;

				l_total_count := l_count;

			else
				select count(*) into l_count
				from gmo_instr_defn_t
				where instruction_process_id = l_instruction_process_id
				and task_attribute_id like l_check_attribute;

				l_total_count := l_count;

				--now check permanent tables for the attribute usage
				--for all instructions not in current process

				select count(*) into l_count
				from gmo_instr_defn_b
				where task_attribute_id like l_check_attribute
				and instruction_set_id not in (select instruction_set_id from gmo_instr_set_defn_t where instruction_process_id = l_instruction_process_id);

				l_total_count := l_total_count + l_count;

			end if;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				null;
		END;

	 end if;

	 if (l_total_count > 0) then
		x_used_flag := GMO_CONSTANTS_GRP.YES;
	 else
		x_used_flag := GMO_CONSTANTS_GRP.NO;
	 end if;

	 x_return_status := GMO_CONSTANTS_GRP.RETURN_STATUS_SUCCESS;

EXCEPTION
	WHEN OTHERS THEN
		X_RETURN_STATUS := GMO_CONSTANTS_GRP.RETURN_STATUS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		X_MSG_DATA := fnd_message.get;
END is_task_attribute_used;

--Bug 5383022: end

END GMO_INSTRUCTION_PVT;

/
