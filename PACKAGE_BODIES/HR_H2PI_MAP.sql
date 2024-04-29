--------------------------------------------------------
--  DDL for Package Body HR_H2PI_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_MAP" AS
/* $Header: hrh2pimp.pkb 115.1 2002/03/07 15:35:34 pkm ship     $ */
--
--Declaring the local variables for the package
--
l_mesg VARCHAR2(200);
g_package  VARCHAR2(33) := '  hr_h2pi_map.';
MAPPING_ID_MISSING EXCEPTION;
MAPPING_ID_MISSING_NUMBER CONSTANT NUMBER := -20010;
PRAGMA EXCEPTION_INIT (MAPPING_ID_MISSING, -20010);
--
--
-- ----------------------------------------------------------------------------
-- |--< Create_Id_Mapping >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- Description:   Insert a record into HR_H2PI_ID_MAPPING to map internal ids
--                from the HR to Payroll system.
-- ----------------------------------------------------------------------------
PROCEDURE create_id_mapping (p_table_name  VARCHAR2,
                             p_from_id     NUMBER,
                             p_to_id       NUMBER) IS

l_proc            VARCHAR2(72) := g_package||'create_id_mapping';
INVALID_PARAM EXCEPTION;
PRAGMA EXCEPTION_INIT(INVALID_PARAM,-20001);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  IF p_table_name IS NULL THEN
    hr_utility.set_location(l_proc, 20);
    l_mesg :='FATAL - CREATE_ID_MAPPING:' ||
             ' The Parameter Value for TABLE_NAME cannot be null';
    RAISE INVALID_PARAM;
  ELSIF p_from_id IS NULL THEN
    hr_utility.set_location(l_proc, 30);
    l_mesg := 'FATAL - CREATE_ID_MAPPING: '||
              'The Parameter Value for FROM_ID cannot be null';
    RAISE INVALID_PARAM;
  ELSIF p_to_id IS NULL THEN
    hr_utility.set_location(l_proc, 40);
    l_mesg := 'FATAL - CREATE_ID_MAPPING: '||
              'The Parameter Value for TO_ID cannot be null';
    RAISE INVALID_PARAM;
  END IF;

  INSERT INTO hr_h2pi_id_mapping
    (to_business_group_id, from_id, to_id,  table_name)
  SELECT distinct hr_h2pi_upload.g_to_business_group_id,
         p_from_id,
         p_to_id,
         p_table_name
  FROM   hr_h2pi_id_mapping im1
  WHERE NOT EXISTS (SELECT 1
                    FROM   hr_h2pi_id_mapping im2
                    WHERE  to_business_group_id =
                                   hr_h2pi_upload.g_to_business_group_id
                    AND    from_id = p_from_id
                    AND    to_id = p_to_id
                    AND    table_name = p_table_name);
  hr_utility.set_location('Leaving:'|| l_proc, 50);
EXCEPTION
  WHEN INVALID_PARAM THEN
    hr_utility.set_location(l_proc, 60);
    fnd_file.put_line(FND_FILE.LOG,l_mesg);
    RAISE;
  WHEN OTHERS THEN
    hr_utility.set_location(l_proc, 70);
    fnd_file.put_line(FND_FILE.LOG, 'FATAL - ' || SQLERRM);
    RAISE;
END create_id_mapping;
--
--
-- ----------------------------------------------------------------------------
-- |--< Get_to_Id >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- Description: Returns the internal id of Payroll system for the passed
--              internal id of HR system and table name.
-- ----------------------------------------------------------------------------
FUNCTION get_to_id (p_table_name   VARCHAR2,
                    p_from_id      NUMBER,
                    p_report_error BOOLEAN DEFAULT FALSE) RETURN NUMBER IS

l_proc            VARCHAR2(72) := g_package||'get_to_id';
l_to_id hr_h2pi_id_mapping.to_id%type;
INVALID_PARAM EXCEPTION;
PRAGMA EXCEPTION_INIT(INVALID_PARAM,-20001);

BEGIN
  IF p_table_name IS NULL THEN
    l_mesg := 'FATAL - GET_TO_ID: '||
              'The Parameter Value for TABLE_NAME cannot be null';
    RAISE INVALID_PARAM;
  ELSIF p_from_id IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT to_id INTO l_to_id
    FROM hr_h2pi_id_mapping
   WHERE to_business_group_id = hr_h2pi_upload.g_to_business_group_id
     AND table_name = p_table_name
     AND from_id = p_from_id;
  RETURN l_to_id;

EXCEPTION
  WHEN INVALID_PARAM THEN
    fnd_file.put_line(FND_FILE.LOG,l_mesg);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    IF p_report_error THEN
      ROLLBACK;
      hr_h2pi_error.data_error(
               p_from_id       => p_from_id
              ,p_table_name    => p_table_name
              ,p_message_level => 'FATAL'
              ,p_message_name  => 'HR_289241_MAPPING_ID_MISSING');
      COMMIT;
      raise_application_error(MAPPING_ID_MISSING_NUMBER,'MAPPING_ID_MISSING');
    END IF;
    return -1;
  WHEN OTHERS THEN
    fnd_file.put_line(FND_FILE.LOG, ' GET_TO_ID : ' || SQLERRM);
    return -1;
END get_to_id;
--
--
-- ----------------------------------------------------------------------------
-- |--< Date_Error >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- Description: Returns the internal id of HR system for the passed
--              internal id of Payroll System and table name.
-- ----------------------------------------------------------------------------

FUNCTION get_from_id (p_table_name   VARCHAR2,
                      p_to_id        NUMBER,
                      p_report_error BOOLEAN DEFAULT FALSE) RETURN NUMBER IS

l_proc        VARCHAR2(72) := g_package||'get_from_id';
l_from_id     hr_h2pi_id_mapping.from_id%type;
INVALID_PARAM EXCEPTION;
PRAGMA EXCEPTION_INIT(INVALID_PARAM,-20001);

BEGIN
  IF p_table_name is null then
    l_mesg := 'FATAL - GET_FROM_ID : '||
              'The Parameter Value for TABLE_NAME cannot be null';
    RAISE INVALID_PARAM;
  ELSIF p_to_id is null then
    RETURN NULL;
  END IF;

  SELECT from_id INTO l_from_id
    FROM hr_h2pi_id_mapping
   WHERE to_business_group_id = hr_h2pi_upload.g_to_business_group_id
     AND table_name = p_table_name
     AND to_id = p_to_id;

  RETURN l_from_id;

EXCEPTION
  WHEN INVALID_PARAM THEN
    fnd_file.put_line(FND_FILE.LOG,l_mesg);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    IF p_report_error THEN
      ROLLBACK;
      hr_h2pi_error.data_error(
               p_from_id       => p_to_id
              ,p_table_name    => p_table_name
              ,p_message_level => 'FATAL'
              ,p_message_name  => 'HR_289241_MAPPING_ID_MISSING');
      COMMIT;
      raise_application_error(MAPPING_ID_MISSING_NUMBER,'MAPPING_ID_MISSING');
   END IF;
    RETURN -1;
  WHEN OTHERS THEN
    fnd_file.put_line(FND_FILE.LOG, ' GET_TO_ID : ' || SQLERRM);
    RETURN -1;
END get_from_id;
--
END hr_h2pi_map;

/
