--------------------------------------------------------
--  DDL for Package Body PQP_COPY_EAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_COPY_EAT" AS
/* $Header: pqpcpext.pkb 115.1 2002/03/18 12:20:21 pkm ship        $ */

-- Package Variables
g_package  	VARCHAR2(33) := '  PQP_COPY_EAT.';

-- ---------------------------------------------------------------------------+
-- |------------------------< COPY_EXTRACT_ATTRIBUTES >-----------------------|
-- ---------------------------------------------------------------------------+
PROCEDURE copy_extract_attributes
		(p_curr_ext_dfn_id 	IN NUMBER
		,p_new_ext_dfn_id	IN NUMBER
		,p_ext_prefix 		IN VARCHAR2
		,p_business_group_id 	IN NUMBER
		) IS

  CURSOR c_ext_attr IS
  SELECT *
  FROM pqp_extract_attributes
  WHERE ext_dfn_id = p_curr_ext_dfn_id;

  CURSOR c_get_seq IS
  SELECT pqp_extract_attributes_s.nextval
  FROM dual;

  CURSOR c_new_ext_name IS
  SELECT name
  FROM ben_ext_dfn
  WHERE ext_dfn_id = p_new_ext_dfn_id;

  CURSOR c_new_udt_name(p_user_table_id IN NUMBER) IS
  SELECT user_table_name
  FROM pay_user_tables
  WHERE user_table_id = p_user_table_id;

  -- Local Record Variables
  r_ext_attr		c_ext_attr%ROWTYPE;

  -- Local Variables
  l_new_put_id		NUMBER(15);
  l_new_seq_id		NUMBER(15);
  l_new_ext_name	ben_ext_dfn.name%TYPE;
  l_new_udt_name	pay_user_tables.user_table_name%TYPE;

  l_proc 		VARCHAR2(72) := g_package||'copy_extract_attributes';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  IF p_ext_prefix IS NULL THEN
    fnd_message.set_name('PQP', 'PQP_230541_EXTRACT_PREFIX_NULL');
    fnd_message.raise_error;
  END IF;

  FOR r_ext_attr in c_ext_attr
  LOOP -- 1 Get Extract Attributes data for p_curr_ext_dfn_id

    -- Copy User Table
    l_new_put_id := pqp_copy_udt.copy_user_table
    				(p_curr_udt_id		=> r_ext_attr.ext_user_table_id
    				,p_udt_prefix		=> p_ext_prefix
    				,p_business_group_id	=> p_business_group_id
    				);

    -- Get the new extract name
    OPEN c_new_ext_name;
    FETCH c_new_ext_name INTO l_new_ext_name;
    CLOSE c_new_ext_name;

    -- Get the new UDT name
    OPEN c_new_udt_name(l_new_put_id);
    FETCH c_new_udt_name INTO l_new_udt_name;
    CLOSE c_new_udt_name;

    -- Get the new sequence number for PQP_ASSIGNMENT_ATTRIBUTES
    OPEN c_get_seq;
    FETCH c_get_seq INTO l_new_seq_id;
    CLOSE c_get_seq;

    -- Insert into PQP_EXTRACT_ATTRIBUTES
    INSERT INTO pqp_extract_attributes
    (extract_attribute_id
    ,ext_dfn_id
    ,ext_dfn_name
    ,ext_dfn_type
    ,ext_user_table_id
    ,ext_user_table_name
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
    )
    VALUES
    (l_new_seq_id
    ,p_new_ext_dfn_id
    ,l_new_ext_name
    ,r_ext_attr.ext_dfn_type
    ,l_new_put_id
    ,l_new_udt_name
    ,r_ext_attr.created_by
    ,r_ext_attr.creation_date
    ,r_ext_attr.last_updated_by
    ,r_ext_attr.last_update_date
    ,r_ext_attr.last_update_login
    ,1
    );

  END LOOP; -- 1

  hr_utility.set_location('Leaving:'|| l_proc, 20);

END copy_extract_attributes;

END pqp_copy_eat;

/
