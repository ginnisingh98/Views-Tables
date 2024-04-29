--------------------------------------------------------
--  DDL for Package Body OTAFRUDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTAFRUDT" AS
/* $Header: otafrudt.pkb 120.2 2005/10/31 05:37:55 hwinsor noship $ */

--------------------------------------------------------------------------------
--        the PROCEDURE - insert_table_data enters data into tables 	      --
--------------------------------------------------------------------------------

PROCEDURE insert_table_data (P_BUSINESS_GROUP_ID_ITD	IN number,
			     P_LEGISLATION_CODE_ITD	IN varchar2,
			     P_APPLICATION_ID_ITD	IN number,
			     P_RANGE_OR_MATCH_ITD	IN varchar2,
			     P_USER_KEY_UNITS_ITD	IN varchar2,
			     P_USER_TABLE_NAME_ITD	IN varchar2,
			     P_USER_ROW_TITLE_ITD	IN varchar2)
IS
   v_table_rowid		varchar2(100);
   v_user_table_id		number;
BEGIN
   hr_utility.trace ('PROCEDURE insert_data entered.');

   v_table_rowid := NULL;
   v_user_table_id := NULL;

	PAY_USER_TABLES_PKG.INSERT_ROW
		(P_ROWID 		=> v_table_rowid,
		 P_USER_TABLE_ID	=> v_user_table_id,
		 P_BUSINESS_GROUP_ID	=> P_BUSINESS_GROUP_ID_ITD,
		 P_LEGISLATION_CODE	=> P_LEGISLATION_CODE_ITD,
		 P_LEGISLATION_SUBGROUP	=> NULL,
		 P_RANGE_OR_MATCH	=> P_RANGE_OR_MATCH_ITD,
		 P_USER_KEY_UNITS	=> P_USER_KEY_UNITS_ITD,
		 P_USER_TABLE_NAME	=> P_USER_TABLE_NAME_ITD,
		 P_USER_ROW_TITLE	=> P_USER_ROW_TITLE_ITD);

   hr_utility.trace ('PROCEDURE insert_data exiting.');
END insert_table_data;


--------------------------------------------------------------------------------
--   procedure - create_table will insert seed data for French localisation   --
-- 			it inserts for user defined tables		      --
--------------------------------------------------------------------------------

PROCEDURE create_table (P_BUSINESS_GROUP_ID_CT	IN number,
			P_APPLICATION_ID_CT	IN number,
			P_RANGE_OR_MATCH_CT	IN varchar2,
			P_USER_KEY_UNITS_CT	IN varchar2,
			P_USER_TABLE_NAME_CT	IN varchar2,
			P_USER_ROW_TITLE_CT	IN varchar2)
IS
   -- ensures table not already created for business group
   CURSOR	user_table_name_csr IS
   SELECT	user_table_name
   FROM		pay_user_tables
   WHERE	business_group_id = P_BUSINESS_GROUP_ID_CT
   AND		user_table_name = P_USER_TABLE_NAME_CT;

   v_legislation_code		per_business_groups.legislation_code%TYPE;
   v_user_table_name		varchar (100);
BEGIN

   hr_utility.trace ('PROCEDURE create table entered.');

   SELECT 	legislation_code
   INTO		v_legislation_code
   FROM		per_business_groups
   WHERE	business_group_id = P_BUSINESS_GROUP_ID_CT;
   --
   OPEN user_table_name_csr;
   FETCH user_table_name_csr INTO v_user_table_name;
   --
   IF user_table_name_csr%NOTFOUND THEN
      hr_utility.trace ('inserting data into '||P_USER_TABLE_NAME_CT||' from create_table.');
      --
      insert_table_data (P_BUSINESS_GROUP_ID_ITD	=> P_BUSINESS_GROUP_ID_CT,
   		         P_LEGISLATION_CODE_ITD		=> v_legislation_code,
		         P_APPLICATION_ID_ITD		=> P_APPLICATION_ID_CT,
		         P_RANGE_OR_MATCH_ITD		=> P_RANGE_OR_MATCH_CT,
		         P_USER_KEY_UNITS_ITD		=> P_USER_KEY_UNITS_CT,
		         P_USER_TABLE_NAME_ITD		=> P_USER_TABLE_NAME_CT,
		         P_USER_ROW_TITLE_ITD		=> P_USER_ROW_TITLE_CT);
   ELSE
      hr_utility.trace ('TABLE ALREADY EXISTS - create_table abandoned.');
   END IF;

   hr_utility.trace ('PROCEDURE create table exiting.');

   exception
   when others then
   null;
END create_table;

--------------------------------------------------------------------------------
--           PROCEDURE - create_column enters data into tables 		      --
--------------------------------------------------------------------------------

PROCEDURE create_column (P_BUSINESS_GROUP_ID_CC	IN number,
		         P_USER_TABLE_NAME_CC	IN varchar2,
		         P_USER_COLUMN_NAME_CC	IN varchar2)
IS
   v_column_row_id	varchar2 (100) := NULL;
   v_user_column_id	number := NULL;

   v_user_table_id	number;
   v_legislation_code	per_business_groups.legislation_code%TYPE;
   v_user_column_name	varchar2 (100);

   CURSOR	user_column_id_csr IS
   SELECT 	user_column_id
   FROM		pay_user_columns
   WHERE 	user_table_id =
   		(SELECT 	user_table_id
   		 FROM		pay_user_tables
   		 WHERE		business_group_id = P_BUSINESS_GROUP_ID_CC
   		 AND		user_table_name = P_USER_TABLE_NAME_CC)
   AND		user_column_name = P_USER_COLUMN_NAME_CC;

BEGIN
   hr_utility.trace ('PROCEDURE create column entered.');

   SELECT 	user_table_id
   INTO		v_user_table_id
   FROM		pay_user_tables
   WHERE	user_table_name = P_USER_TABLE_NAME_CC
   AND		business_group_id = P_BUSINESS_GROUP_ID_CC;
   --
   SELECT 	legislation_code
   INTO		v_legislation_code
   FROM		per_business_groups
   WHERE	business_group_id = P_BUSINESS_GROUP_ID_CC;
   --
   OPEN user_column_id_csr;
   FETCH user_column_id_csr INTO v_user_column_id;
   --
   IF user_column_id_csr%NOTFOUND THEN
      PAY_USER_COLUMNS_PKG.INSERT_ROW
         (P_ROWID			=> v_column_row_id,
   	  P_USER_COLUMN_ID		=> v_user_column_id,
   	  P_USER_TABLE_ID		=> v_user_table_id,
   	  P_BUSINESS_GROUP_ID		=> P_BUSINESS_GROUP_ID_CC,
   	  P_LEGISLATION_CODE		=> v_legislation_code,
   	  P_LEGISLATION_SUBGROUP	=> NULL,
   	  P_USER_COLUMN_NAME		=> P_USER_COLUMN_NAME_CC,
   	  P_FORMULA_ID			=> NULL);
   ELSE
      --
      hr_utility.trace ('column entry already exists, column not entered.');
      --
   END IF;

   hr_utility.trace ('PROCEDURE create column exiting.');

END create_column;

--------------------------------------------------------------------------------
--    	   PROCEDURE - create_row enters row level data into tables 	      --
--------------------------------------------------------------------------------

PROCEDURE create_row (P_BUSINESS_GROUP_ID_CR		IN number,
		      P_USER_TABLE_NAME_CR		IN varchar2,
		      P_USER_COLUMN_NAME_CR		IN varchar2,
		      P_ROW_LOW_RANGE_OR_NAME_CR	IN varchar2,
		      P_DISPLAY_SEQUENCE_CR		IN number,
		      P_VALUE_CR			IN varchar2)
IS
   v_legislation_code		per_business_groups.legislation_code%TYPE;
   v_start_date			date := TO_DATE ('01/01/1900', 'DD/MM/YYYY');
   v_end_date			date := TO_DATE ('31/12/4712', 'DD/MM/YYYY');
   --
   v_user_table_id		number;
   v_user_row_id		number := NULL;
   --
   v_column_instance_rowid	varchar2 (100) := NULL;
   v_user_column_instance_id	number := NULL;
   v_user_column_id		varchar2 (100);

   CURSOR 	user_row_id_csr IS
   SELECT 	user_row_id
   FROM		pay_user_rows_f
   WHERE	user_table_id = (SELECT	user_table_id
   				 FROM 	pay_user_tables
   				 WHERE	user_table_name = P_USER_TABLE_NAME_CR
   				 AND	business_group_id = P_BUSINESS_GROUP_ID_CR)
   AND		 P_ROW_LOW_RANGE_OR_NAME_CR = row_low_range_or_name;

   CURSOR	row_instance_csr (p_user_row_id number, p_user_column_id number) IS
   SELECT	user_column_instance_id
   FROM		pay_user_column_instances_f
   WHERE	user_row_id = p_user_row_id
   AND		user_column_id = p_user_column_id;

BEGIN
   hr_utility.trace ('PROCEDURE create row entered.');
   --
   SELECT 	user_table_id, legislation_code
   INTO		v_user_table_id, v_legislation_code
   FROM		pay_user_tables
   WHERE	user_table_name = P_USER_TABLE_NAME_CR
   AND		business_group_id = P_BUSINESS_GROUP_ID_CR;
   --
   OPEN user_row_id_csr;
   FETCH user_row_id_csr INTO v_user_row_id;
   --
   IF user_row_id_csr%NOTFOUND THEN
	--
   	SELECT		pay_user_rows_s.nextval
	INTO		v_user_row_id
	FROM		dual;

   	-- this insertion creates the row

        hr_utility.trace ('Inserting row '||P_ROW_LOW_RANGE_OR_NAME_CR);
        hr_utility.trace ('          INTO '||P_BUSINESS_GROUP_ID_CR);
  	INSERT INTO pay_user_rows_f (user_row_id,
    				     effective_start_date,
    				     effective_end_date,
	    			     business_group_id,
    				     legislation_code,
    				     user_table_id,
    				     row_low_range_or_name,
    				     display_sequence,
    				     legislation_subgroup,
    				     row_high_range)

	VALUES		       	    (v_user_row_id,
   				     v_start_date,
   				     v_end_date,
				     P_BUSINESS_GROUP_ID_CR,
				     v_legislation_code,
				     v_user_table_id,
				     P_ROW_LOW_RANGE_OR_NAME_CR,
				     P_DISPLAY_SEQUENCE_CR,
				     NULL,
				     NULL);
      --
    hr_utility.set_location ('Created row '||P_ROW_LOW_RANGE_OR_NAME_CR,1);
      --
   ELSE
      --
      hr_utility.set_location ('row already exists, row not entered.', 202);
      --
   END IF;

   CLOSE user_row_id_csr;

   hr_utility.trace ('PROCEDURE create_row exiting');
   --
   SELECT	user_column_id
   INTO		v_user_column_id
   FROM		pay_user_columns_v
   WHERE	user_column_name = P_USER_COLUMN_NAME_CR
   AND		user_table_id = v_user_table_id;
   --
   OPEN row_instance_csr (v_user_row_id, v_user_column_id);
   FETCH row_instance_csr INTO v_user_column_instance_id;
   IF row_instance_csr%NOTFOUND THEN
   --
      hr_utility.set_location ('inserting instance', 10);
      PAY_USER_COLUMN_INSTANCES_PKG.INSERT_ROW
         (P_ROWID			=> v_column_instance_rowid
         ,P_USER_COLUMN_INSTANCE_ID	=> v_user_column_instance_id
         ,P_EFFECTIVE_START_DATE	=> v_start_date
         ,P_EFFECTIVE_END_DATE		=> v_end_date
         ,P_USER_ROW_ID			=> v_user_row_id
         ,P_USER_COLUMN_ID		=> v_user_column_id
         ,P_BUSINESS_GROUP_ID		=> P_BUSINESS_GROUP_ID_CR
         ,P_LEGISLATION_CODE		=> v_legislation_code
         ,P_LEGISLATION_SUBGROUP	=> NULL
         ,P_VALUE			=> P_VALUE_CR);
  --
  ELSE
      hr_utility.set_location ('instance already exists', 10);
  END IF;
  END create_row;

--------------------------------------------------------------------------------
--  PROCEDURE - create_from_lookup creates user defined tables from lookups   --
--------------------------------------------------------------------------------

PROCEDURE create_from_lookup (P_BUSINESS_GROUP_ID	IN varchar2,
			      P_REQUIRED_DEFAULTS	IN varchar2,
			      P_DEFAULT_VALUE		IN varchar2,
			      P_LOOKUP_TYPE		IN varchar2,
			      P_USER_COLUMN_NAME	IN varchar2,
			      P_USER_KEY_UNITS		IN varchar2)
IS
   v_lookup_code	fnd_common_lookups.lookup_code%TYPE;
   v_meaning		fnd_common_lookups.meaning%TYPE;

   v_sequence		number := 10;

   v_legislation_code	varchar2 (10) := NULL; -- holds legislation code returned

   CURSOR 	lookup_code_csr IS
   SELECT	lookup_code, meaning
   FROM 	fnd_common_lookups
   WHERE	lookup_type = P_LOOKUP_TYPE;

BEGIN
   hr_utility.trace ('PROCEDURE create_from_lookup entered.');

   OPEN lookup_code_csr;
   FETCH lookup_code_csr INTO v_lookup_code, v_meaning;
   IF lookup_code_csr%FOUND THEN
      hr_utility.set_location ('Valid lookup: '||P_LOOKUP_TYPE, 40);

      create_table (P_BUSINESS_GROUP_ID_CT	=> P_BUSINESS_GROUP_ID,
                    P_APPLICATION_ID_CT		=> 800,
                    P_RANGE_OR_MATCH_CT		=> 'M',
                    P_USER_KEY_UNITS_CT		=> P_USER_KEY_UNITS,
                    P_USER_TABLE_NAME_CT	=> P_LOOKUP_TYPE,
                    P_USER_ROW_TITLE_CT		=> P_LOOKUP_TYPE);

      hr_utility.set_location ('Adding: '||P_USER_COLUMN_NAME, 50);

      create_column (P_BUSINESS_GROUP_ID_CC	=> P_BUSINESS_GROUP_ID,
		     P_USER_TABLE_NAME_CC	=> P_LOOKUP_TYPE,
		     P_USER_COLUMN_NAME_CC	=> P_USER_COLUMN_NAME);

      LOOP
         EXIT WHEN lookup_code_csr%NOTFOUND;

         IF P_REQUIRED_DEFAULTS = 'NONE' THEN
            hr_utility.trace ('sequence number: '||v_sequence);
            create_row (P_BUSINESS_GROUP_ID_CR		=> P_BUSINESS_GROUP_ID,
	   	        P_USER_TABLE_NAME_CR		=> P_LOOKUP_TYPE,
		        P_USER_COLUMN_NAME_CR		=> P_USER_COLUMN_NAME,
		        P_ROW_LOW_RANGE_OR_NAME_CR	=> v_lookup_code,
		        P_DISPLAY_SEQUENCE_CR		=> v_sequence,
		        P_VALUE_CR			=> NULL);
	 ELSIF P_REQUIRED_DEFAULTS = 'QUICKCODE_VALUE' THEN
            hr_utility.trace ('sequence number: '||v_sequence);
	    create_row (P_BUSINESS_GROUP_ID_CR		=> P_BUSINESS_GROUP_ID,
	   	        P_USER_TABLE_NAME_CR		=> P_LOOKUP_TYPE,
		        P_USER_COLUMN_NAME_CR		=> P_USER_COLUMN_NAME,
		        P_ROW_LOW_RANGE_OR_NAME_CR	=> v_lookup_code,
		        P_DISPLAY_SEQUENCE_CR		=> v_sequence,
		        P_VALUE_CR			=> v_meaning);
         ELSE
            hr_utility.trace ('sequence number: '||v_sequence);
            create_row (P_BUSINESS_GROUP_ID_CR		=> P_BUSINESS_GROUP_ID,
  	   	        P_USER_TABLE_NAME_CR		=> P_LOOKUP_TYPE,
		        P_USER_COLUMN_NAME_CR		=> P_USER_COLUMN_NAME,
		        P_ROW_LOW_RANGE_OR_NAME_CR	=> v_lookup_code,
		        P_DISPLAY_SEQUENCE_CR		=> v_sequence,
		        P_VALUE_CR			=> P_DEFAULT_VALUE);
         END IF;
         FETCH lookup_code_csr INTO v_lookup_code, v_meaning;
         v_sequence := v_sequence + 10;
      END LOOP;
   END IF;
   CLOSE lookup_code_csr;

   hr_utility.trace ('PROCEDURE create_from_lookup exited.');

END;
--
procedure load_alternate_lookup (l_business_group_id in number)
is
BEGIN
  -- this is no longer required for the 2005 2483
  null;
---------------------------------------------------------
-- creation of user defined rows from existing lookups --
---------------------------------------------------------
  --	create_from_lookup (P_BUSINESS_GROUP_ID	=> l_business_group_id,
  --			    P_REQUIRED_DEFAULTS	=> 'NONE',
  --			    P_DEFAULT_VALUE	=> NULL,
  --			    P_LOOKUP_TYPE	=> 'FR_EMPLOYEE_CATEGORY',
  --			    P_USER_COLUMN_NAME	=> 'BS_EMP_CAT',
  --			    P_USER_KEY_UNITS	=> 'T');
  --
  --	create_from_lookup (P_BUSINESS_GROUP_ID	=> l_business_group_id,
  --			    P_REQUIRED_DEFAULTS	=> 'NONE',
  --			    P_DEFAULT_VALUE	=> NULL,
  --			    P_LOOKUP_TYPE	=> 'ACTIVITY_CATEGORY',
  --			    P_USER_COLUMN_NAME	=> '2483_ACT_CAT',
  --			    P_USER_KEY_UNITS	=> 'T');
  --
END load_alternate_lookup;
--
END OTAFRUDT;

/
