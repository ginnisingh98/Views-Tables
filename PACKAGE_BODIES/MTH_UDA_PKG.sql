--------------------------------------------------------
--  DDL for Package Body MTH_UDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTH_UDA_PKG" AS
/*$Header: mthuntbb.pls 120.6.12010000.7 2010/03/15 22:07:29 lvenkatr ship $*/

PROCEDURE UPDATE_TO_PRIMARY_KEY(P_ENTITY IN VARCHAR2) IS
--initialize variables here
v_entity_code NUMBER;
v_pk_column VARCHAR2(40);
v_stmt VARCHAR2(200);
v_temp NUMBER;
v_i_num NUMBER;
v_t_num NUMBER;
v_master_table VARCHAR2(200);
e_tname_not_found EXCEPTION;
e_issue_with_data EXCEPTION;
e_no_pk_key EXCEPTION;

CURSOR c_null_check IS
SELECT DISTINCT GROUP_ID FROM MTH_EXT_ATTR_T_STG;
-- main body
BEGIN
    NULL;     -- allow compilation



-- Get the pk key
v_pk_column := MTH_UDA_PKG.Get_Mst_Pk_Name(p_entity);
IF (v_pk_column IS null) THEN
	RAISE e_tname_not_found;
END IF;

/*
Make a check:
1. we should have only one row with db_col as null for each GROUP_ID, which will be the primary key.
2. if we have no row with db_col as null, then no primary key info has been provided.
*/

FOR v_row IN c_null_check
LOOP
	SELECT COUNT (1) INTO v_temp FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID = v_row.GROUP_ID
	AND DB_COL IS NULL;

	IF (v_temp > 1) THEN	-- Case 1
		RAISE e_issue_with_data;
	ELSIF (v_temp = 0) THEN -- Case 2
		RAISE e_no_pk_key;
	END IF;
END LOOP;

/* Once we have the column name, update those rows
in MTH_EXT_ATTR_T_STG, where db_col is null. This is
because, we expect only those rows to have db_col as null
which consists ATTR_VALUE as the primary key value. For
others since, meta data will be configured, db_col should not be
null.
*/

v_stmt := 'UPDATE MTH_EXT_ATTR_T_STG SET ATTR_NAME = '||''''||v_pk_column||''''||'  WHERE DB_COL IS NULL';
EXECUTE IMMEDIATE v_stmt;
COMMIT;

    EXCEPTION
    WHEN e_tname_not_found THEN
	RAISE_APPLICATION_ERROR(-20001,'Incorrect Entity provided');
    WHEN e_issue_with_data THEN
	RAISE_APPLICATION_ERROR(-20002,'There is an issue with data, one or more columns except primary key have NO meta data defined. Please recheck');
    WHEN e_no_pk_key THEN

	RAISE_APPLICATION_ERROR(-20003,'No primary Key column has been provided: A primary key column should not have meta data defined');

WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20006, SQLERRM||v_stmt);

END;
-- End of UPDATE_TO_PRIMARY_KEY;

PROCEDURE NTB_UPLOAD_STANDARD_WHO(P_EXT_TBL_NAME IN VARCHAR2,  P_EXTENSION_ID IN NUMBER,  P_IF_ROW_EXISTS IN NUMBER) IS
--initialize variables here
l_updated_by NUMBER := 15;
l_last_update_login NUMBER := 15;
v_stmt VARCHAR2(20000);
-- main body
BEGIN
    NULL;     -- allow compilation
/*
Check whether we need to insert or update these values
by checking p_if_row_exists. if this is 0, we are inserting.
*/

IF (p_if_row_exists = 0) THEN
/* Row does not exists, assign values to creation_date
and created_by*/
v_stmt := 'UPDATE '||p_ext_tbl_name||' SET LAST_UPDATE_DATE = '||''''||SYSDATE||''''||', LAST_UPDATED_BY = '||l_updated_by||', LAST_UPDATE_LOGIN = ';
v_stmt := v_stmt||l_last_update_login||', CREATED_BY = '||l_updated_by||', CREATION_DATE = '||''''||SYSDATE||''''||' WHERE EXTENSION_ID = '||p_extension_id;

ELSE
/* Row Exists, no need for creation_date and created_by */
v_stmt := 'UPDATE '||p_ext_tbl_name||' SET LAST_UPDATE_DATE = '||''''||SYSDATE||''''||', LAST_UPDATED_BY = '||l_updated_by||', LAST_UPDATE_LOGIN = '||l_last_update_login||' WHERE EXTENSION_ID = '||p_extension_id;
END IF;

--DBMS_OUTPUT.PUT_LINE (v_stmt);

EXECUTE IMMEDIATE v_stmt;
COMMIT;




    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,' in the procedure to update who columns');

END;
-- End of NTB_UPLOAD_STANDARD_WHO;

PROCEDURE NTB_UPLOADTL(P_ENTITY IN VARCHAR2,  P_EXTID IN NUMBER,  P_IF_ROW_EXISTS IN NUMBER) IS
--initialize variables here
v_pk_column VARCHAR2(30);
v_tname_b VARCHAR2(30);
v_tname_tl VARCHAR2(30);
e_tname_not_found EXCEPTION;
v_stmt VARCHAR2(30000);
-- main body
BEGIN
    NULL;     -- allow compilation
/*
Using the p_entity, get the primary key column name
*/
v_pk_column := MTH_UDA_PKG.Get_Mst_Pk_Name(p_entity);
IF (v_pk_column = null) THEN
 RAISE e_tname_not_found;
END IF;

/*
Now get the EXT_TL and EXT_B names
*/
v_tname_b := MTH_UDA_PKG.Get_Ext_Table_Name(p_entity);
IF (v_tname_b = NULL) THEN
 RAISE e_tname_not_found;
END IF;

v_tname_tl := MTH_UDA_PKG.Get_Ext_TL_Table_Name(p_entity);
IF (v_tname_tl = NULL) THEN
 RAISE e_tname_not_found;
END IF;

/*
Now, check if it was already existing, if not, we will insert a new row,
else call the upload who procedure to update who columns
*/

IF (p_if_row_exists = 0) THEN
 -- INSERT A NEW ROW
 --DBMS_OUTPUT.PUT_LINE('inserting the rows');
 v_stmt := 'INSERT INTO '||v_tname_tl||'(EXTENSION_ID, ATTR_GROUP_ID, '||v_pk_column||',
 SOURCE_LANG, LANGUAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE)
 SELECT EXTENSION_ID, ATTR_GROUP_ID, '||v_pk_column||', ''US''SOURCE_LANG, ''US'' LANGUAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,LAST_UPDATE_LOGIN, CREATED_BY,CREATION_DATE FROM '||v_tname_b||' WHERE EXTENSION_ID = '||p_extId;
 --DBMS_OUTPUT.PUT_LINE(v_stmt);
 EXECUTE IMMEDIATE v_stmt;
 COMMIT;

ELSE
 -- CALL to who upload column
 --DBMS_OUTPUT.PUT_LINE('UPDating the who columns');
 MTH_UDA_PKG.NTB_Upload_Standard_Who(v_tname_tl,p_extId,p_if_row_exists);
END IF;




    EXCEPTION
        WHEN e_tname_not_found THEN
 RAISE_APPLICATION_ERROR(-20001,'Incorrect Entity provided at ');
WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20002, SQLERRM);

END;
-- End of NTB_UPLOADTL;

PROCEDURE NTB_UPLOAD(P_TARGET IN VARCHAR2) IS
--initialize variables here
v_stmt_no NUMBER;
v_if_row_exists NUMBER;
v_attr_group NUMBER;
v_extId NUMBER;
v_cnt_rows NUMBER;
v_cnt_existing NUMBER;
v_col_name VARCHAR2(20);
v_col_val VARCHAR2(255);
v_stmt VARCHAR2(20000);
v_stmt_var VARCHAR2(20000);
v_mrc VARCHAR2(3);
v_date_val VARCHAR2(20);
e_tname_not_found EXCEPTION;
v_entity VARCHAR2(200) := p_target;
v_tname VARCHAR2(200);


/*
This cursor is used to loop through all the columns to
be filled in for a row. This helps to insert as well as
update a row in the EXT table.
*/
CURSOR c_row_iterator(R_ID NUMBER, ATTR_GRP NUMBER) IS
SELECT STG.ATTR_GROUP_ID,STG.ATTR_NAME, STG.ATTR_VALUE, STG.DB_COL FROM MTH_EXT_ATTR_T_STG STG
WHERE STG.GROUP_ID = R_ID AND STG.ATTR_GROUP_ID = ATTR_GRP;

/*
This cursor is used to find all the attribute groups ids having
the same row ids and process the same.
*/
CURSOR c_row_iterator1(GROUP_ID1 NUMBER) IS
SELECT DISTINCT ATTR_GROUP_ID FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID= GROUP_ID1;

/*
This cursor first gets all the rows for which DB_COL is null.
Essentially, these are going to be the ones which are the primary
keys of the table. This helps to locate a particular row and to decide
whether we update or insert a new row.
*/
CURSOR c_row_iterator2(GROUP_ID2 NUMBER, AID NUMBER) IS
SELECT ATTR_NAME, ATTR_VALUE FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID = GROUP_ID2 AND DB_COL IS NULL AND ATTR_GROUP_ID = AID;

/*This cursor will get all the NAME VALUE pair for which c_unique_key_flag = 'Y' */
CURSOR c_unique_key_flag(GROUP_ID3 NUMBER, AID3 NUMBER) IS
SELECT DB_COL, ATTR_VALUE FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID = GROUP_ID3 AND ATTR_GROUP_ID = AID3 AND UNIQUE_KEY_FLAG='Y';

-- main body
BEGIN
    NULL;     -- allow compilation
-- Call the procedure to rename columns to the pkey columns
 MTH_UDA_PKG.Update_To_Primary_Key(v_entity);


 -- Code to get find out table name depending on the entity input
v_stmt_no := 5;
v_tname := MTH_UDA_PKG.Get_Ext_Table_Name(v_entity);
IF (v_tname is NULL) THEN
	RAISE e_tname_not_found;
END IF;

-- DBMS_OUTPUT.PUT_LINE('The target table is '||TNAME);
/*
Select the different row ids present, each different row id refers to the data for a single
row. It is possible to have one to many relationship between row id and attribute group.
*/
v_stmt_no:= 10;

/*Changed the following select statement
SELECT COUNT(DISTINCT GROUP_ID) INTO v_cnt_rows FROM MTH_EXT_ATTR_T_STG;
due to bug 8349873. Due to the above statement, the logic fails when we have discontinous group ids such as 1,3,5 etc.
Changing the statement to select max group_id allows complete iteration through
discontinous set.
*/
SELECT MAX(GROUP_ID) INTO v_cnt_rows FROM MTH_EXT_ATTR_T_STG;

/* Loop through each row of data. A row of data is identified as having the
same row id.
*/
--DBMS_OUTPUT.PUT_LINE('Entering logic to process one set of rows with same row id');
FOR VAR IN 1..v_cnt_rows
LOOP
	v_stmt_no := 20;

	/*
	This loop will help to process data for one row id, with provision
	to have more than one attribute group id having the same row.
	*/
	FOR A_ID IN c_row_iterator1(VAR)
	LOOP
		v_attr_group:= A_ID.ATTR_GROUP_ID; --Get the attribute group id in a variable
		--DBMS_OUTPUT.PUT_LINE('The attribute group is '||v_attr_group);
		--DBMS_OUTPUT.PUT_LINE('Processing Row '||VAR);

		/*
		This variable helps to prepare statement to get the EXT ID value
		for a particular row
		*/
		v_stmt_var := 'SELECT EXTENSION_ID FROM '||v_tname||' WHERE ATTR_GROUP_ID ='||v_attr_group;

		/*
		This variable helps to prepare statement to see whether the particular row
		for which data is being processed is present in the EXT table or not.
		*/
		v_stmt := 'SELECT COUNT(1) FROM '||v_tname||' WHERE ATTR_GROUP_ID ='||v_attr_group;

		/*
		This statement helps to prepare the above statements correctly
		by helping to choose proper WHERE CLAUSES. This is achieved by
		using the v_cnt_existing varaiable
		*/
		v_stmt_no := 30;
		SELECT COUNT(1) INTO v_cnt_existing FROM MTH_EXT_ATTR_T_STG
		WHERE DB_COL IS NULL AND
		ATTR_GROUP_ID = v_attr_group AND
		GROUP_ID = VAR;
	--	DBMS_OUTPUT.PUT_LINE('No of primary key columns = '||v_cnt_existing);

		/*
		This cursor first gets all the rows for which DB_COL is null.
		Essentially, these are going to be the ones which are the primary
		keys of the table. This helps to locate a particular row and to decide
		whether we update or insert a new row.
		*/
		--DBMS_OUTPUT.PUT_LINE('Preparing query using pkey columns');
		FOR VAR2 IN c_row_iterator2(VAR, v_attr_group)
		LOOP
			v_col_name := VAR2.ATTR_NAME;
			v_col_val := VAR2.ATTR_VALUE;
			v_cnt_existing := v_cnt_existing -1;

			/*
			If the pkey columns happen to be date columns, we need
			to add the logic to process the data by converting it
			to date. This has been done in the loops which follow
			*/
			v_stmt := v_stmt||' AND '||v_col_name||'='||v_col_val;
			v_stmt_var := v_stmt_var||' AND '||v_col_name||'='||v_col_val;

		END LOOP;

	--	DBMS_OUTPUT.PUT_LINE('The queries for pkeys are as follows:');
	--	DBMS_OUTPUT.PUT_LINE(v_stmt);
	--	DBMS_OUTPUT.PUT_LINE(v_stmt_var);

		/* Now add where clause to check for unique keys. For a multi row
		attribute group, distinction between attribute group id and pkeys would
		not suffice. For such a case, we designate few attribute columns as unique.
		These attributes allow us to distinguish between multi row data.
		Skip this check if the attribute group is not multi row.
		*/
		--DBMS_OUTPUT.PUT_LINE('Now check logic for MULTI ROW');
		v_stmt_no := 40;
		SELECT MULTI_ROW_CODE INTO v_mrc FROM EGO_ATTR_GROUPS_V
		WHERE ATTR_GROUP_ID = v_attr_group;

		IF v_mrc = 'Y' THEN
		--DBMS_OUTPUT.PUT_LINE('Attribute group is MULTI ROW');
		/* LOGIC FOR multi row attribute groups */
			SELECT COUNT(1) INTO v_cnt_existing FROM MTH_EXT_ATTR_T_STG
			WHERE UNIQUE_KEY_FLAG='Y' AND
			ATTR_GROUP_ID = v_attr_group AND
			GROUP_ID = VAR;
		--	DBMS_OUTPUT.PUT_LINE('No of unique columns = '||v_cnt_existing);

			FOR C IN c_unique_key_flag(VAR, v_attr_group)
			LOOP
		--	DBMS_OUTPUT.PUT_LINE('Adding MULTI ROW column where clause to the earlier query');
				v_col_name := C.DB_COL;
				v_col_val := C.ATTR_VALUE;
				v_cnt_existing := v_cnt_existing-1;
				v_stmt_no := 50;

				/*
				Check for proper where clause. This is done to
				get the correct timestamp for date columns.
				*/
			--	DBMS_OUTPUT.PUT_LINE('Statement so far '||STMT);

				IF SUBSTR(v_col_name,1,1)= 'D' THEN
			--		DBMS_OUTPUT.PUT_LINE('We have a unique date column');
					v_date_val := TO_CHAR(TO_DATE(v_col_val,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');
					v_stmt := v_stmt||' AND '||v_col_name||'='||'TO_DATE('||''''||v_date_val||''''||',''MM/DD/YYYY HH24:MI:SS'')';
					v_stmt_var := v_stmt_var||' AND '||v_col_name||'='||'TO_DATE('||''''||v_date_val||''''||',''MM/DD/YYYY HH24:MI:SS'')';
				ELSE
					v_stmt := v_stmt||' AND '||v_col_name||'='||''''||v_col_val||'''';
					v_stmt_var := v_stmt_var||' AND '||v_col_name||'='||''''||v_col_val||'''';
				END IF;

			END LOOP;
		ELSE
			null;
			--DBMS_OUTPUT.PUT_LINE('The A Group is single row');
		END IF;

--		DBMS_OUTPUT.PUT_LINE('The updated statements after unique key check are ');
--		DBMS_OUTPUT.PUT_LINE(v_stmt);
	--	DBMS_OUTPUT.PUT_LINE(v_stmt_var);

		v_stmt_no := 60;
		/*
		Get the count of the row in the variable v_if_row_exists
		If the count is 0, it means the row with these values
		of pkeys are not present. So proceed with inserting a
		new surrogate key value
		*/
		EXECUTE IMMEDIATE v_stmt INTO v_if_row_exists ;

		IF v_if_row_exists = 0 THEN
			--DBMS_OUTPUT.PUT_LINE('This row is not present in the EXT table');
			--DBMS_OUTPUT.PUT_LINE('INSERT THE NEW ROW');


			v_stmt_no := 70;
			v_stmt := 'SELECT EGO_EXTFWK_S.NEXTVAL FROM DUAL';
			EXECUTE IMMEDIATE v_stmt INTO v_extId;

			v_stmt := 'INSERT INTO '||v_tname||' (EXTENSION_ID, ATTR_GROUP_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY, CREATION_DATE) VALUES (:1, :2, '||''''||SYSDATE||''''||', -1, -1,'||''''||SYSDATE||''''||'  )';
			--DBMS_OUTPUT.PUT_LINE('The new EXT ID is'||v_extId);
			--DBMS_OUTPUT.PUT_LINE('The new EXT ID is'||v_stmt);
			v_stmt_no := 80;
			EXECUTE IMMEDIATE v_stmt USING v_extId, v_attr_group ;
			--COMMIT;

		ELSE
		--	DBMS_OUTPUT.PUT_LINE('This data is already present in the EXT table');
		--	DBMS_OUTPUT.PUT_LINE('UPDATE THE DATA');
			v_stmt_no := 90;
			EXECUTE IMMEDIATE v_stmt_var INTO v_extId;
			--DBMS_OUTPUT.PUT_LINE('The EXT ID for this data is '||v_extId);
		END IF;

		/*
		Iterate over all the name value pair for the row id
		to insert/update in the EXT Table
		*/
		--DBMS_OUTPUT.PUT_LINE('Iterate over all the columns to insert/update');
		FOR EXT_VAL IN c_row_iterator(VAR,v_attr_group)
		LOOP
			/*
			Check whether this is a pkey value,
			in such cases, DB_COL will be null
			*/
			IF EXT_VAL.DB_COL IS NULL THEN
				v_col_name := EXT_VAL.ATTR_NAME;
			ELSE
				v_col_name := EXT_VAL.DB_COL;
			END IF;

			--DBMS_OUTPUT.PUT_LINE('The column name to be updated/inserted '||v_col_name);

			/*
			Check for a date column to use the appropiate TO_DATE FUNCTION
			*/
			IF SUBSTR(v_col_name,1,1) = 'D' THEN
--				DBMS_OUTPUT.PUT_LINE('A DATE COLUMN');

--				DBMS_OUTPUT.PUT_LINE('The TIMESTAMP is ');
--				DBMS_OUTPUT.PUT_LINE(TO_CHAR(TO_DATE(EXT_VAL.ATTR_VALUE,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS'));
				v_date_val := TO_CHAR(TO_DATE(EXT_VAL.ATTR_VALUE,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');
				v_stmt := 'UPDATE '||v_tname||' SET '||v_col_name||' = '||'TO_DATE('||''''||v_date_val||''''||',''MM/DD/YYYY HH24:MI:SS'')'||' WHERE EXTENSION_ID = '||v_extId;
			ELSE
				v_col_val := EXT_VAL.ATTR_VALUE;
				--DBMS_OUTPUT.PUT_LINE('The data is '||v_col_val);
				v_stmt := 'UPDATE '||v_tname||' SET '||v_col_name||' = '||''''||v_col_val||''''||' WHERE EXTENSION_ID = '||v_extId;
			END IF;

			--DBMS_OUTPUT.PUT_LINE('The statement to be executed is '||v_stmt);

			v_stmt_no := 100;
			EXECUTE IMMEDIATE v_stmt;

		END LOOP; -- Completing insertion or updating a single row

		--Commit after all the attributes for one group id is
		--updated
		COMMIT;
	/*
	call procedure to update standard who columns
	*/
	--DBMS_OUTPUT.PUT_LINE('calling who procedure');
	MTH_UDA_PKG.NTB_Upload_Standard_Who(v_tname,v_extId, v_if_row_exists);

	/*
	Call the procedure to update TL Table
	*/
	MTH_UDA_PKG.NTB_UploadTL(v_entity,v_extId,v_if_row_exists);

	END LOOP;
END LOOP;




    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	RAISE_APPLICATION_ERROR(-20002,'No data found at line number '||v_stmt_no);

WHEN e_tname_not_found THEN
	RAISE_APPLICATION_ERROR(-20001,'Incorrect Entity provided at '||v_stmt_no);

WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20003,SQLERRM||' at '||v_stmt_no);
	ROLLBACK;
END;
-- End of NTB_UPLOAD;

FUNCTION GET_MST_TABLE_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2 IS
--initialize variables here
v_entity_code	NUMBER;
v_mst_tbl_name	VARCHAR2(50) DEFAULT NULL;
-- main body
BEGIN
    NULL;     -- allow compilation

-- Get the code for the entity
v_entity_code := MTH_UDA_PKG.Get_Entity_Code(p_entity);

-- Check if v_entity_code is -1, if so, return NULL
IF (v_entity_code = -1) THEN
	RETURN NULL;
END IF;

CASE
	WHEN v_entity_code = 1 THEN v_mst_tbl_name := 'MTH_EQUIPMENTS_D';
	WHEN v_entity_code = 2 THEN v_mst_tbl_name := 'MTH_ITEMS_D';
	WHEN v_entity_code = 3 THEN v_mst_tbl_name := 'MTH_OTHERS_D';
	WHEN v_entity_code = 4 THEN v_mst_tbl_name := 'MTH_PRODUCTION_SCHEDULES_F';
	WHEN v_entity_code = 5 THEN v_mst_tbl_name := 'MTH_PRODUCTION_SEGMENTS_F';
  WHEN v_entity_code = 6 THEN v_mst_tbl_name := 'MTH_ALL_ENTITIES_V';

END CASE;

RETURN v_mst_tbl_name;

END;
-- End of GET_MST_TABLE_NAME;

FUNCTION GET_MST_PK_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2 IS
--initialize variables here
v_entity_code	NUMBER;
v_mst_pk_name	VARCHAR2(50) DEFAULT NULL;
-- main body
BEGIN
    NULL;     -- allow compilation
-- Get the code for the entity
v_entity_code := MTH_UDA_PKG.Get_Entity_Code(p_entity);

-- Check if v_entity_code is -1, if so, return NULL
IF (v_entity_code = -1) THEN
	RETURN NULL;
END IF;

CASE
	WHEN v_entity_code = 1 THEN v_mst_pk_name := 'EQUIPMENT_PK_KEY';
	WHEN v_entity_code = 2 THEN v_mst_pk_name := 'ITEM_PK_KEY';
	WHEN v_entity_code = 3 THEN v_mst_pk_name := 'OTHER_PK_KEY';
	WHEN v_entity_code = 4 THEN v_mst_pk_name := 'WORKORDER_PK_KEY';
	WHEN v_entity_code = 5 THEN v_mst_pk_name := 'SEGMENT_PK_KEY';
  WHEN v_entity_code = 6 THEN v_mst_pk_name := 'ENTITY_PK_KEY';
END CASE;

RETURN v_mst_pk_name;
END;
-- End of GET_MST_PK_NAME;

FUNCTION GET_EXT_TL_TABLE_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2 IS
--initialize variables here
v_entity_code	NUMBER;
v_ext_tbl_name	VARCHAR2(50) DEFAULT NULL;
-- main body
BEGIN
    NULL;     -- allow compilation

-- Get the code for the entity
v_entity_code := MTH_UDA_PKG.Get_Entity_Code(p_entity);

-- Check if v_entity_code is -1, if so, return NULL
IF (v_entity_code = -1) THEN
	RETURN NULL;
END IF;

CASE
	WHEN v_entity_code = 1 THEN v_ext_tbl_name := 'MTH_EQUIPMENTS_EXT_TL';
	WHEN v_entity_code = 2 THEN v_ext_tbl_name := 'MTH_ITEMS_EXT_TL';
	WHEN v_entity_code = 3 THEN v_ext_tbl_name := 'MTH_OTHERS_EXT_TL';
	WHEN v_entity_code = 4 THEN v_ext_tbl_name := 'MTH_PRODUCTION_SCHEDULE_EXT_TL';
	WHEN v_entity_code = 5 THEN v_ext_tbl_name := 'MTH_PRODUCTION_SEGMENTS_EXT_TL';
    WHEN v_entity_code = 6 THEN v_ext_tbl_name := 'MTH_USER_ENTITIES_EXT_TL';
END CASE;

RETURN v_ext_tbl_name;
END;
-- End of GET_EXT_TL_TABLE_NAME;

FUNCTION GET_EXT_TABLE_NAME(P_ENTITY IN VARCHAR2) RETURN VARCHAR2 IS
--initialize variables here
v_entity_code	NUMBER;
v_ext_tbl_name	VARCHAR2(50) DEFAULT NULL;
-- main body
BEGIN
    NULL;     -- allow compilation
    -- Get the code for the entity
v_entity_code := MTH_UDA_PKG.Get_Entity_Code(p_entity);

-- Check if v_entity_code is -1, if so, return NULL
IF (v_entity_code = -1) THEN
	RETURN NULL;
END IF;

CASE
	WHEN v_entity_code = 1 THEN v_ext_tbl_name := 'MTH_EQUIPMENTS_EXT_B';
	WHEN v_entity_code = 2 THEN v_ext_tbl_name := 'MTH_ITEMS_EXT_B';
	WHEN v_entity_code = 3 THEN v_ext_tbl_name := 'MTH_OTHERS_EXT_B';
	WHEN v_entity_code = 4 THEN v_ext_tbl_name := 'MTH_PRODUCTION_SCHEDULES_EXT_B';
	WHEN v_entity_code = 5 THEN v_ext_tbl_name := 'MTH_PRODUCTION_SEGMENTS_EXT_B';
  	WHEN v_entity_code = 6 THEN v_ext_tbl_name := 'MTH_USER_ENTITIES_EXT_B';

END CASE;

RETURN v_ext_tbl_name;

END;
-- End of GET_EXT_TABLE_NAME;

FUNCTION GET_ENTITY_CODE(P_ENTITY IN VARCHAR2) RETURN NUMBER IS
--initialize variables here
v_entity_code NUMBER;
v_entity VARCHAR2(50);
-- main body
BEGIN
    NULL;     -- allow compilation
-- First make it case insensitive
v_entity := UPPER(p_entity);

CASE
	WHEN v_entity = 'EQUIPMENTS' THEN v_entity_code := 1;
	WHEN v_entity = 'ITEMS' THEN v_entity_code := 2;
	WHEN v_entity = 'OTHERS' THEN v_entity_code := 3;
	WHEN v_entity = 'PRODUCTION_SCHEDULES' THEN v_entity_code := 4;
	WHEN v_entity = 'PRODUCTION_SEGMENTS' THEN v_entity_code := 5;
    	WHEN v_entity = 'USER_ENTITIES' THEN v_entity_code := 6;

	ELSE v_entity_code := -1;
END CASE;
RETURN v_entity_code;

END;
-- End of GET_ENTITY_CODE;



PROCEDURE DEVICE_POST_LOG(P_TARGET IN VARCHAR2) IS
-- Intialize variables
e_duplicate_run EXCEPTION;
e_not_allowed EXCEPTION;
v_l_stmt NUMBER; -- To track the line where the error has occcured
v_count NUMBER;
v_to_date DATE;
v_fact_table VARCHAR2(50) := UPPER(p_target); -- FACT Table Name
v_last_update_date DATE; -- Standard WHO column
v_last_update_system_id NUMBER; -- Standard WHO column
v_stmt VARCHAR2(500);


-- main body
BEGIN

  /*Make a check against v_fact_table, it should be MTH_EQUIPMENTS_EXT_B only and nothing else*/
  v_l_stmt := 10;
  IF v_fact_table <> 'MTH_EQUIPMENTS_EXT_B' THEN
	RAISE e_not_allowed;
  END IF;

  -- Get the sysdate
  v_l_stmt := 20;
    SELECT SYSDATE INTO v_last_update_date FROM	DUAL;

   -- get the unassigned value for system id
  v_l_stmt := 30;
  SELECT MTH_UTIL_PKG.MTH_UA_GET_VAL() INTO v_last_update_system_id FROM DUAL;


  -- Check whether the pre map operation has been run or not
  v_l_stmt := 40;
  SELECT COUNT(FACT_TABLE) INTO v_count
  FROM MTH_RUN_LOG
  WHERE FACT_TABLE = v_fact_table;

  -- DBMS_OUTPUT.PUT_LINE('THE COUNT IS '||v_count);

  IF v_count <> 0 THEN

  -- Another check
  v_l_stmt := 45;
  SELECT TO_DATE INTO v_to_date
  FROM MTH_RUN_LOG
  WHERE FACT_TABLE = v_fact_table;

  -- DBMS_OUTPUT.PUT_LINE('THE TO_DATE IS '||v_to_date);

  END IF;

  v_l_stmt := 50;
  IF (v_count = 0)OR(v_to_date IS NULL) THEN
    -- Log is being run for the first time
    RAISE e_duplicate_run;
  ELSE
    -- Update TO_DATE to SYSDATE, LAST_UPDATE_DATE, and LAST_UPDATE_SYSTEM_ID


    v_stmt := 'UPDATE MTH_RUN_LOG SET FROM_DATE = TO_DATE, LAST_UPDATE_DATE = :1, LAST_UPDATE_SYSTEM_ID =:2 WHERE
            FACT_TABLE =:3';

     -- DBMS_OUTPUT.PUT_LINE('UPDATING THE LOG TABLE '||v_stmt);

    v_l_stmt := 60;
    EXECUTE IMMEDIATE v_stmt USING v_last_update_date, v_last_update_system_id, v_fact_table;
    v_l_stmt := 65;
    COMMIT;

    v_l_stmt := 70;
    v_stmt := 'UPDATE MTH_RUN_LOG SET TO_DATE = NULL WHERE
            FACT_TABLE =:1';

    -- DBMS_OUTPUT.PUT_LINE('UPDATING THE LOG TABLE '||v_stmt);

    EXECUTE IMMEDIATE v_stmt USING v_fact_table;
    v_l_stmt := 75;
    COMMIT;
  END IF;

    EXCEPTION
        WHEN e_not_allowed THEN
		RAISE_APPLICATION_ERROR(-20201,'This fact CANNOT BE logged using the procedure at line '||v_l_stmt);
        WHEN e_duplicate_run THEN
                RAISE_APPLICATION_ERROR (-20201,'Pre Map logging not available, run the load first, ABORTING');
        WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20203,SQLERRM||'at line '||v_l_stmt);
END;
-- End of DEVICE_POST_LOG;

PROCEDURE DEVICE_PRE_LOG(P_TARGET IN VARCHAR2) IS
-- Intialize variables
v_l_stmt NUMBER; -- To track the line where the error has occcured
v_to_date DATE; -- To Date
v_from_date DATE := TO_DATE('01/01/1900','MM-DD-YYYY HH:MIAM'); -- From Date # Bug fix: need to specify the date format
v_cnt NUMBER;
v_fact_table VARCHAR2(50) := UPPER(p_target); -- The instance name in the ETL
/*
CREATION_DATE will be same as v_last_update_date if the load is run for the first time,
else if the load is being run again, CREATION_DATE would already be populated, so there is no
need for this variable
*/
v_last_update_date DATE; -- Standard WHO column
/*
CREATION_SYSTEM_ID will be same as LAST_UPDATE_SYSTEM_ID if the load is run for the first time,
else if the load is being run again, CREATION_SYSTEM_ID would already be populated, so there is no
need for this variable
*/
v_last_update_system_id NUMBER; -- Standard WHO column
v_stmt VARCHAR2(500);
e_not_allowed EXCEPTION;


-- main body
BEGIN

  /*Make a check against v_fact_table, it should be MTH_EQUIPMENTS_EXT_B only and nothing else*/
  v_l_stmt := 5;
  IF v_fact_table <> 'MTH_EQUIPMENTS_EXT_B' THEN
	RAISE e_not_allowed;
  END IF;

  -- get the system date
  v_l_stmt := 10;
  SELECT SYSDATE INTO v_to_date FROM DUAL;

  v_last_update_date := v_to_date;

  -- get the unassigned value for system id
  v_l_stmt := 15;
  SELECT MTH_UTIL_PKG.MTH_UA_GET_VAL() INTO v_last_update_system_id FROM DUAL;

  -- Check whether the load is being run for the first time or not
  v_l_stmt := 20;
  SELECT COUNT(FACT_TABLE) INTO v_cnt
  FROM MTH_RUN_LOG
  WHERE FACT_TABLE = v_fact_table;

  -- DBMS_OUTPUT.PUT_LINE('Count of the fact table '||v_cnt);

  v_l_stmt := 30;
  IF v_cnt = 0 THEN
    -- Log is being run for the first time

    v_stmt := 'INSERT INTO MTH_RUN_LOG (FACT_TABLE, FROM_DATE, TO_DATE, CREATION_DATE,
    LAST_UPDATE_DATE, CREATION_SYSTEM_ID, LAST_UPDATE_SYSTEM_ID) VALUES (:1, :2, :3, :4, :5, :6, :7)';
    v_l_stmt := 40;
    -- DBMS_OUTPUT.PUT_LINE('Inserting'||v_stmt);
    EXECUTE IMMEDIATE v_stmt USING v_fact_table, v_from_date, v_to_date, v_last_update_date,
    v_last_update_date, v_last_update_system_id, v_last_update_system_id;
    v_l_stmt := 45;
    COMMIT;
  ELSE
    -- Update TO_DATE to SYSDATE, LAST_UPDATE_DATE, and LAST_UPDATE_SYSTEM_ID

    v_stmt := 'UPDATE MTH_RUN_LOG SET TO_DATE = :1, LAST_UPDATE_DATE = :2, LAST_UPDATE_SYSTEM_ID =:3 WHERE
            FACT_TABLE =:4';
    v_l_stmt := 50;
    -- DBMS_OUTPUT.PUT_LINE('Updating'||v_stmt);
    EXECUTE IMMEDIATE v_stmt USING v_to_date, v_last_update_date, v_last_update_system_id, v_fact_table;
    v_l_stmt := 55;
    COMMIT;
  END IF;

    EXCEPTION
	WHEN e_not_allowed THEN
		RAISE_APPLICATION_ERROR(-20201,'This fact CANNOT BE logged using the procedure at line '||v_l_stmt);
        WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20203,SQLERRM||'at '||v_l_stmt);
END;
-- End of DEVICE_PRE_LOG;

PROCEDURE TB_UPLOAD IS
v_colname VARCHAR2(30);
v_tl_colname VARCHAR2(30);
v_stmt VARCHAR2(32767);
v_stmt_no NUMBER;
CURSOR DISTINCT_COLUMN IS
SELECT DISTINCT DB_COL FROM MTH_TAG_READINGS_T_STG;


BEGIN

  v_stmt_no := 5;
  FOR DBCOL IN DISTINCT_COLUMN
  LOOP
		v_colname := DBCOL.DB_COL;
		v_stmt_no := 10;
		v_stmt := 'MERGE INTO MTH_EQUIPMENTS_EXT_B ED
		USING (
		SELECT * FROM MTH_TAG_READINGS_T_STG,(SELECT NVL(FND_GLOBAL.User_Id,-1)l_updated_by,NVL(FND_GLOBAL.Login_Id,-1)l_last_update_login FROM DUAL )D
		WHERE DB_COL = '||''''||v_colname||''''||') TS
		ON (';

		v_stmt := v_stmt||'ED.EQUIPMENT_PK_KEY = TS.EQUIPMENT_FK_KEY AND
		ED.READ_TIME = TS.READ_TIME)
		WHEN MATCHED THEN
		UPDATE
		SET ED.'||v_colname||' = TS.TAG_DATA,
		ED.LAST_UPDATE_DATE = ''''||SYSDATE||'''',
		ED.LAST_UPDATED_BY = TS.l_updated_by,';

		v_stmt := v_stmt||'ED.LAST_UPDATE_LOGIN = TS.l_last_update_login
		WHEN NOT MATCHED THEN
		INSERT ('||v_colname||',EXTENSION_ID, EQUIPMENT_PK_KEY,WORKORDER_FK_KEY,SEGMENT_FK_KEY,SHIFT_WORKDAY_FK_KEY, HOUR_FK_KEY, ITEM_FK_KEY, READ_TIME, ATTR_GROUP_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,';

		v_stmt:=
v_stmt||'LAST_UPDATE_LOGIN,CREATED_BY,CREATION_DATE,RECIPE_NUM,RECIPE_VERSION)
		VALUES (TS.TAG_DATA,EGO_EXTFWK_S.NEXTVAL, TS.EQUIPMENT_FK_KEY, TS.WORKORDER_FK_KEY, TS.SEGMENT_FK_KEY,TS.SHIFT_WORKDAY_FK_KEY,TS.HOUR_FK_KEY, TS.ITEM_FK_KEY, TS.READ_TIME,';

		v_stmt := v_stmt||'TS.ATTR_GROUP_ID,'||''''||SYSDATE||''''||',TS.l_updated_by,TS.l_last_update_login,TS.l_updated_by,'||''''||SYSDATE||''''||',TS.RECIPE_NUM, TS.RECIPE_VERSION)';

		--DBMS_OUTPUT.PUT_LINE(v_stmt);
	v_stmt_no := 20;
		EXECUTE IMMEDIATE v_stmt;
		COMMIT;

    END LOOP;



EXCEPTION
		WHEN INVALID_NUMBER THEN
		RAISE_APPLICATION_ERROR(-20008,'The Tag Data you are tyring to insert is of Character Data Type. A number is expected instead.');
		WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20008,SQLERRM||' at '||v_stmt_no);

END;
-- End of TB_UPLOAD;

/* Support Composite Pk Key */

PROCEDURE GET_MST_COMPOSITE_PK_NAME(P_ENTITY IN VARCHAR2,v_mst_pk_name OUT NOCOPY v_mst_pk_key_columns,
                                    v_entity_code OUT NUMBER, v_csv_columns OUT NOCOPY v_csv_column_names)
IS
--initialize variables here
--v_entity_code	NUMBER;
--v_mst_pk_name1	VARCHAR2(50) DEFAULT NULL;
--v_mst_pk_name2	VARCHAR2(30) DEFAULT NULL;

-- main body
BEGIN
    NULL;     -- allow compilation
-- Get the code for the entity
v_entity_code := MTH_UDA_PKG.Get_Entity_Code(p_entity);

-- Check if v_entity_code is -1, if so, return NULL
--IF (v_entity_code = -1) THEN
--	RETURN NULL;
--END IF;

CASE
  WHEN v_entity_code = 6 THEN
	v_mst_pk_name := v_mst_pk_key_columns('ENTITY_PK_KEY', 'ENTITY_TYPE');
	v_csv_columns := v_csv_column_names('USER_ENTITY','ENTITY_TYPE');
END CASE;

END; -- End GET_MST_COMPOSITE_PK_NAME

PROCEDURE UPDATE_COMPOSITE_PRIMARY_KEY(P_ENTITY IN VARCHAR2) IS
--initialize variables here
v_entity_code NUMBER;
v_mst_pk_column v_mst_pk_key_columns;
v_csv_cols v_csv_column_names;
v_stmt1 VARCHAR2(1000);
v_stmt2 VARCHAR2(200);
v_temp NUMBER;
v_i_num NUMBER;
v_t_num NUMBER;
v_master_table VARCHAR2(200);
e_tname_not_found EXCEPTION;
e_issue_with_data EXCEPTION;
e_no_pk_key EXCEPTION;
v_pk_column1 VARCHAR2(40);
v_pk_column2 VARCHAR2(30);
ctr_csv_col NUMBER;
v_csv_ctr NUMBER;



CURSOR c_null_check IS
SELECT DISTINCT GROUP_ID FROM MTH_EXT_ATTR_T_STG;
-- main body
BEGIN
    --NULL;     -- allow compilation



-- Get the pk key
--EXECUTE MTH_UDA_PKG.GET_MST_COMPOSITE_PK_NAME(p_entity,v_pk_column1,v_pk_column2);
--EXECUTE IMMEDIATE
MTH_UDA_PKG.GET_MST_COMPOSITE_PK_NAME(p_entity,v_mst_pk_column,v_entity_code, v_csv_cols);
--IF (v_pk_column IS NULL  OR v_pk_column2 IS NULL ) THEN
IF (v_mst_pk_column IS NULL OR v_entity_code = -1) THEN
	RAISE e_tname_not_found;
END IF;

/*
Make a check:
1. if we have no row with db_col as null, then no primary key info has been provided.
*/

FOR v_row IN c_null_check
LOOP
	SELECT COUNT (1) INTO v_temp FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID = v_row.GROUP_ID
	AND DB_COL IS NULL;

	IF (v_temp > v_mst_pk_column.count) THEN	-- Case 1
		RAISE e_issue_with_data;
	ELSIF (v_temp = 0) THEN -- Case 2
		RAISE e_no_pk_key;
	END IF;
END LOOP;

/* Once we have the column name, update those rows
in MTH_EXT_ATTR_T_STG, where db_col is null. This is
because, we expect only those rows to have db_col as null
which consists ATTR_VALUE as the primary key value. For
others since, meta data will be configured, db_col should not be
null.
*/

--The assumption is the csv columns are in the same order as the primary key columns.
v_csv_ctr := v_csv_cols.FIRST;
For ctr in v_mst_pk_column.FIRST..v_mst_pk_column.LAST
LOOP
	v_stmt1 := 'UPDATE MTH_EXT_ATTR_T_STG SET ATTR_NAME = '||''''||v_mst_pk_column(ctr)||''''||'  WHERE DB_COL IS NULL AND ATTR_NAME = ' || ''''|| v_csv_cols(v_csv_ctr) || '''';
	--DBMS_OUTPUT.PUT_LINE(v_stmt1);
--	v_stmt2 := 'UPDATE MTH_EXT_ATTR_T_STG SET ATTR_NAME = '||''''||v_pk_column(ctr)||''''||'  WHERE DB_COL IS NULL ' AND ATTR_NAME = 'ENTITY_TYPE';
	EXECUTE IMMEDIATE v_stmt1;
--			EXECUTE IMMEDIATE v_stmt2;
    v_csv_ctr := v_csv_cols.NEXT(v_csv_ctr);

END LOOP;
COMMIT;

EXCEPTION
	WHEN e_tname_not_found THEN
		RAISE_APPLICATION_ERROR(-20001,'Incorrect Entity provided');
    WHEN e_issue_with_data THEN
		RAISE_APPLICATION_ERROR(-20002,'There is an issue with data, one or more columns except primary key have NO meta data defined. Please recheck');
    WHEN e_no_pk_key THEN
		RAISE_APPLICATION_ERROR(-20003,'No primary Key column has been provided: A primary key column should not have meta data defined');
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20006, SQLERRM||v_stmt1);

END;    -- End of UPDATE_TO_COMPOSITE_PRIMARY_KEY;

---------


----------
PROCEDURE NTB_UPLOAD_COMPOSITETL(P_ENTITY IN VARCHAR2,  P_EXTID IN NUMBER,  P_IF_ROW_EXISTS IN NUMBER) IS
--initialize variables here
v_pk_column v_mst_pk_key_columns;
v_csv_column v_csv_column_names;
v_entity_code NUMBER;
v_tname_b VARCHAR2(30);
v_tname_tl VARCHAR2(30);
e_tname_not_found EXCEPTION;
v_stmt VARCHAR2(30000);
v_concat_pk_key VARCHAR2(3000);
-- main body
BEGIN
    NULL;     -- allow compilation
/*
Using the p_entity, get the primary key column name
*/
MTH_UDA_PKG.GET_MST_COMPOSITE_PK_NAME(p_entity,v_pk_column, v_entity_code, v_csv_column);
--IF (v_pk_column1 IS NULL  OR v_pk_column2 IS NULL OR (v_pk_column1 IS NULL AND  v_pk_column2 IS NULL)) THEN
IF (v_pk_column IS NULL OR v_entity_code = -1) THEN
	RAISE e_tname_not_found;
END IF;

/*
Now get the EXT_TL and EXT_B names
*/
v_tname_b := MTH_UDA_PKG.Get_Ext_Table_Name(p_entity);
IF (v_tname_b = NULL) THEN
 RAISE e_tname_not_found;
END IF;

v_tname_tl := MTH_UDA_PKG.Get_Ext_TL_Table_Name(p_entity);
IF (v_tname_tl = NULL) THEN
 RAISE e_tname_not_found;
END IF;

/*
Now, check if it was already existing, if not, we will insert a new row,
else call the upload who procedure to update who columns
*/

IF (p_if_row_exists = 0) THEN
 -- INSERT A NEW ROW
 --DBMS_OUTPUT.PUT_LINE('inserting the rows');
   FOR ctr IN v_pk_column.FIRST..v_pk_column.LAST
  LOOP
	v_concat_pk_key := v_concat_pk_key || v_pk_column(ctr) || ', ';

  END LOOP;

  v_stmt := 'INSERT INTO '||v_tname_tl||'(EXTENSION_ID, ATTR_GROUP_ID, ' || v_concat_pk_key || 'SOURCE_LANG, LANGUAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE) SELECT EXTENSION_ID, ATTR_GROUP_ID, ';
 v_stmt := v_stmt ||v_concat_pk_key || ' ''US''SOURCE_LANG, ''US'' LANGUAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,LAST_UPDATE_LOGIN, CREATED_BY,CREATION_DATE FROM '||v_tname_b||' WHERE EXTENSION_ID = '||p_extId;
 --DBMS_OUTPUT.PUT_LINE(v_stmt);
 EXECUTE IMMEDIATE v_stmt;
 COMMIT;

ELSE
 -- CALL to who upload column
 --DBMS_OUTPUT.PUT_LINE('UPDating the who columns');
 MTH_UDA_PKG.NTB_Upload_Standard_Who(v_tname_tl,p_extId,p_if_row_exists);
END IF;




    EXCEPTION
        WHEN e_tname_not_found THEN
 RAISE_APPLICATION_ERROR(-20001,'Incorrect Entity provided at ');
WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20002, SQLERRM);

END;
-- End of NTB_UPLOADCOMPOSITETL;


/* Support Composite Pk Key */

PROCEDURE NTB_UPLOAD_COMPOSITE_PK(P_TARGET IN VARCHAR2) IS
--initialize variables here
v_stmt_no NUMBER;
v_if_row_exists NUMBER;
v_attr_group NUMBER;
v_extId NUMBER;
v_cnt_rows NUMBER;
v_cnt_existing NUMBER;
v_col_name VARCHAR2(20);
v_col_val VARCHAR2(255);
v_stmt VARCHAR2(20000);
v_stmt_var VARCHAR2(20000);
v_mrc VARCHAR2(3);
v_date_val VARCHAR2(20);
e_tname_not_found EXCEPTION;
v_entity VARCHAR2(200) := p_target;
v_tname VARCHAR2(200);


/*
This cursor is used to loop through all the columns to
be filled in for a row. This helps to insert as well as
update a row in the EXT table.
*/
CURSOR c_row_iterator(R_ID NUMBER, ATTR_GRP NUMBER) IS
SELECT STG.ATTR_GROUP_ID,STG.ATTR_NAME, STG.ATTR_VALUE, STG.DB_COL FROM MTH_EXT_ATTR_T_STG STG
WHERE STG.GROUP_ID = R_ID AND STG.ATTR_GROUP_ID = ATTR_GRP;

/*
This cursor is used to find all the attribute groups ids having
the same row ids and process the same.
*/
CURSOR c_row_iterator1(GROUP_ID1 NUMBER) IS
SELECT DISTINCT ATTR_GROUP_ID FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID= GROUP_ID1;

/*
This cursor first gets all the rows for which DB_COL is null.
Essentially, these are going to be the ones which are the primary
keys of the table. This helps to locate a particular row and to decide
whether we update or insert a new row.
*/
CURSOR c_row_iterator2(GROUP_ID2 NUMBER, AID NUMBER) IS
SELECT ATTR_NAME, ATTR_VALUE FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID = GROUP_ID2 AND DB_COL IS NULL AND ATTR_GROUP_ID = AID;

/*This cursor will get all the NAME VALUE pair for which c_unique_key_flag = 'Y' */
CURSOR c_unique_key_flag(GROUP_ID3 NUMBER, AID3 NUMBER) IS
SELECT DB_COL, ATTR_VALUE FROM MTH_EXT_ATTR_T_STG WHERE GROUP_ID = GROUP_ID3 AND ATTR_GROUP_ID = AID3 AND UNIQUE_KEY_FLAG='Y';

-- main body
BEGIN
    NULL;     -- allow compilation
-- Call the procedure to rename columns to the pkey columns
 MTH_UDA_PKG.UPDATE_COMPOSITE_PRIMARY_KEY(v_entity);


 -- Code to get find out table name depending on the entity input
v_stmt_no := 5;
v_tname := MTH_UDA_PKG.Get_Ext_Table_Name(v_entity);
IF (v_tname is NULL) THEN
	RAISE e_tname_not_found;
END IF;

 --DBMS_OUTPUT.PUT_LINE('The target table is '||v_tname);
/*
Select the different row ids present, each different row id refers to the data for a single
row. It is possible to have one to many relationship between row id and attribute group.
*/
v_stmt_no:= 10;

/*Changed the following select statement
SELECT COUNT(DISTINCT GROUP_ID) INTO v_cnt_rows FROM MTH_EXT_ATTR_T_STG;
due to bug 8349873. Due to the above statement, the logic fails when we have discontinous group ids such as 1,3,5 etc.
Changing the statement to select max group_id allows complete iteration through
discontinous set.
*/
SELECT MAX(GROUP_ID) INTO v_cnt_rows FROM MTH_EXT_ATTR_T_STG;

/* Loop through each row of data. A row of data is identified as having the
same row id.
*/
--DBMS_OUTPUT.PUT_LINE('Entering logic to process one set of rows with same row id');
FOR VAR IN 1..v_cnt_rows
LOOP
	v_stmt_no := 20;

	/*
	This loop will help to process data for one row id, with provision
	to have more than one attribute group id having the same row.
	*/
	FOR A_ID IN c_row_iterator1(VAR)
	LOOP
		v_attr_group:= A_ID.ATTR_GROUP_ID; --Get the attribute group id in a variable
		--DBMS_OUTPUT.PUT_LINE('The attribute group is '||v_attr_group);
		--DBMS_OUTPUT.PUT_LINE('Processing Row '||VAR);

		/*
		This variable helps to prepare statement to get the EXT ID value
		for a particular row
		*/
		v_stmt_var := 'SELECT EXTENSION_ID FROM '||v_tname||' WHERE ATTR_GROUP_ID ='||v_attr_group;

		/*
		This variable helps to prepare statement to see whether the particular row
		for which data is being processed is present in the EXT table or not.
		*/
		v_stmt := 'SELECT COUNT(1) FROM '||v_tname||' WHERE ATTR_GROUP_ID ='||v_attr_group;

		/*
		This statement helps to prepare the above statements correctly
		by helping to choose proper WHERE CLAUSES. This is achieved by
		using the v_cnt_existing varaiable
		*/
		v_stmt_no := 30;
		SELECT COUNT(1) INTO v_cnt_existing FROM MTH_EXT_ATTR_T_STG
		WHERE DB_COL IS NULL AND
		ATTR_GROUP_ID = v_attr_group AND
		GROUP_ID = VAR;
		--DBMS_OUTPUT.PUT_LINE('No of primary key columns = '||v_cnt_existing);

		/*
		This cursor first gets all the rows for which DB_COL is null.
		Essentially, these are going to be the ones which are the primary
		keys of the table. This helps to locate a particular row and to decide
		whether we update or insert a new row.
		*/
		--DBMS_OUTPUT.PUT_LINE('Preparing query using pkey columns');
		FOR VAR2 IN c_row_iterator2(VAR, v_attr_group)
		LOOP
			v_col_name := VAR2.ATTR_NAME;
			v_col_val := VAR2.ATTR_VALUE;
			v_cnt_existing := v_cnt_existing -1;

			/*
			If the pkey columns happen to be date columns, we need
			to add the logic to process the data by converting it
			to date. This has been done in the loops which follow
			*/
			v_stmt := v_stmt||' AND TO_CHAR('||v_col_name||') = ''' || v_col_val || '''';
			v_stmt_var := v_stmt_var||' AND TO_CHAR('||v_col_name||') = '''||v_col_val || '''';

		END LOOP;

		--DBMS_OUTPUT.PUT_LINE('The queries for pkeys are as follows:');
		--DBMS_OUTPUT.PUT_LINE(v_stmt);
		--DBMS_OUTPUT.PUT_LINE(v_stmt_var);

		/* Now add where clause to check for unique keys. For a multi row
		attribute group, distinction between attribute group id and pkeys would
		not suffice. For such a case, we designate few attribute columns as unique.
		These attributes allow us to distinguish between multi row data.
		Skip this check if the attribute group is not multi row.
		*/
		--DBMS_OUTPUT.PUT_LINE('Now check logic for MULTI ROW');
		v_stmt_no := 40;
		SELECT MULTI_ROW_CODE INTO v_mrc FROM EGO_ATTR_GROUPS_V
		WHERE ATTR_GROUP_ID = v_attr_group;

		IF v_mrc = 'Y' THEN
		--DBMS_OUTPUT.PUT_LINE('Attribute group is MULTI ROW');
		/* LOGIC FOR multi row attribute groups */
			SELECT COUNT(1) INTO v_cnt_existing FROM MTH_EXT_ATTR_T_STG
			WHERE UNIQUE_KEY_FLAG='Y' AND
			ATTR_GROUP_ID = v_attr_group AND
			GROUP_ID = VAR;
		--	DBMS_OUTPUT.PUT_LINE('No of unique columns = '||v_cnt_existing);

			FOR C IN c_unique_key_flag(VAR, v_attr_group)
			LOOP
		--	DBMS_OUTPUT.PUT_LINE('Adding MULTI ROW column where clause to the earlier query');
				v_col_name := C.DB_COL;
				v_col_val := C.ATTR_VALUE;
				v_cnt_existing := v_cnt_existing-1;
				v_stmt_no := 50;

				/*
				Check for proper where clause. This is done to
				get the correct timestamp for date columns.
				*/
			--	DBMS_OUTPUT.PUT_LINE('Statement so far '||STMT);

				IF SUBSTR(v_col_name,1,1)= 'D' THEN
			--		DBMS_OUTPUT.PUT_LINE('We have a unique date column');
					v_date_val := TO_CHAR(TO_DATE(v_col_val,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');
					v_stmt := v_stmt||' AND '||v_col_name||'='||'TO_DATE('||''''||v_date_val||''''||',''MM/DD/YYYY HH24:MI:SS'')';
					v_stmt_var := v_stmt_var||' AND '||v_col_name||'='||'TO_DATE('||''''||v_date_val||''''||',''MM/DD/YYYY HH24:MI:SS'')';
				ELSE
					v_stmt := v_stmt||' AND '||v_col_name||'='||''''||v_col_val||'''';
					v_stmt_var := v_stmt_var||' AND '||v_col_name||'='||''''||v_col_val||'''';
				END IF;

			END LOOP;
		ELSE
			null;
			--DBMS_OUTPUT.PUT_LINE('The A Group is single row');
		END IF;

		--DBMS_OUTPUT.PUT_LINE('The updated statements after unique key check are ');
		--DBMS_OUTPUT.PUT_LINE(v_stmt);
	--	DBMS_OUTPUT.PUT_LINE(v_stmt_var);

		v_stmt_no := 60;
		/*
		Get the count of the row in the variable v_if_row_exists
		If the count is 0, it means the row with these values
		of pkeys are not present. So proceed with inserting a
		new surrogate key value
		*/
		EXECUTE IMMEDIATE v_stmt INTO v_if_row_exists ;

		IF v_if_row_exists = 0 THEN
			--DBMS_OUTPUT.PUT_LINE('This row is not present in the EXT table');
			--DBMS_OUTPUT.PUT_LINE('INSERT THE NEW ROW');


			v_stmt_no := 70;
			v_stmt := 'SELECT EGO_EXTFWK_S.NEXTVAL FROM DUAL';
			EXECUTE IMMEDIATE v_stmt INTO v_extId;

			v_stmt := 'INSERT INTO '||v_tname||' (EXTENSION_ID, ATTR_GROUP_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY, CREATION_DATE) VALUES (:1, :2, '||''''||SYSDATE||''''||', -1, -1,'||''''||SYSDATE||''''||'  )';
			--DBMS_OUTPUT.PUT_LINE('The new EXT ID is'||v_extId);
			--DBMS_OUTPUT.PUT_LINE('The new EXT ID is'||v_stmt);
			v_stmt_no := 80;
			EXECUTE IMMEDIATE v_stmt USING v_extId, v_attr_group ;
			--COMMIT;

		ELSE
		--	DBMS_OUTPUT.PUT_LINE('This data is already present in the EXT table');
		--	DBMS_OUTPUT.PUT_LINE('UPDATE THE DATA');
			v_stmt_no := 90;
			EXECUTE IMMEDIATE v_stmt_var INTO v_extId;
			--DBMS_OUTPUT.PUT_LINE('The EXT ID for this data is '||v_extId);
		END IF;

		/*
		Iterate over all the name value pair for the row id
		to insert/update in the EXT Table
		*/
		--DBMS_OUTPUT.PUT_LINE('Iterate over all the columns to insert/update');
		FOR EXT_VAL IN c_row_iterator(VAR,v_attr_group)
		LOOP
			/*
			Check whether this is a pkey value,
			in such cases, DB_COL will be null
			*/
			IF EXT_VAL.DB_COL IS NULL THEN
				v_col_name := EXT_VAL.ATTR_NAME;
			ELSE
				v_col_name := EXT_VAL.DB_COL;
			END IF;

			--DBMS_OUTPUT.PUT_LINE('The column name to be updated/inserted '||v_col_name);

			/*
			Check for a date column to use the appropiate TO_DATE FUNCTION
			*/
			IF SUBSTR(v_col_name,1,1) = 'D' THEN
--				DBMS_OUTPUT.PUT_LINE('A DATE COLUMN');

--				DBMS_OUTPUT.PUT_LINE('The TIMESTAMP is ');
--				DBMS_OUTPUT.PUT_LINE(TO_CHAR(TO_DATE(EXT_VAL.ATTR_VALUE,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS'));
				v_date_val := TO_CHAR(TO_DATE(EXT_VAL.ATTR_VALUE,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');
				v_stmt := 'UPDATE '||v_tname||' SET '||v_col_name||' = '||'TO_DATE('||''''||v_date_val||''''||',''MM/DD/YYYY HH24:MI:SS'')'||' WHERE EXTENSION_ID = '||v_extId;
			ELSE
				v_col_val := EXT_VAL.ATTR_VALUE;
				--DBMS_OUTPUT.PUT_LINE('The data is '||v_col_val);
				v_stmt := 'UPDATE '||v_tname||' SET '||v_col_name||' = '||''''||v_col_val||''''||' WHERE EXTENSION_ID = '||v_extId;
			END IF;

			--DBMS_OUTPUT.PUT_LINE('The statement to be executed is '||v_stmt);

			v_stmt_no := 100;
			EXECUTE IMMEDIATE v_stmt;

		END LOOP; -- Completing insertion or updating a single row

		--Commit after all the attributes for one group id is
		--updated
		COMMIT;
	/*
	call procedure to update standard who columns
	*/
	--DBMS_OUTPUT.PUT_LINE('calling who procedure');
	MTH_UDA_PKG.NTB_Upload_Standard_Who(v_tname,v_extId, v_if_row_exists);

	/*
	Call the procedure to update TL Table
	*/
	MTH_UDA_PKG.NTB_Upload_COMPOSITETL(v_entity,v_extId,v_if_row_exists);

	END LOOP;
END LOOP;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
	RAISE_APPLICATION_ERROR(-20002,'No data found at line number '||v_stmt_no);

WHEN e_tname_not_found THEN
	RAISE_APPLICATION_ERROR(-20001,'Incorrect Entity provided at '||v_stmt_no);

WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20003,SQLERRM||' at '||v_stmt_no);
	ROLLBACK;

END; --End NTB_UPLOAD_COMPOSITE_PK

END MTH_UDA_PKG;

/
