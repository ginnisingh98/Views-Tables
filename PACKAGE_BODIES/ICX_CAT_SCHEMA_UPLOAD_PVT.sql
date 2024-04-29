--------------------------------------------------------
--  DDL for Package Body ICX_CAT_SCHEMA_UPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_SCHEMA_UPLOAD_PVT" AS
/* $Header: ICXVSULB.pls 120.12.12010000.2 2014/08/20 10:44:01 rkandima ship $*/

-- Default number of characters for columns created as VARCHAR2
DEFAULT_COLUMN_SIZE	CONSTANT Number := 700;

gLastTableName VARCHAR2(30) := null;
gLastTableExist VARCHAR2(1) := 'N';
BATCH_SIZE	 NUMBER:= 10000;
-------------------------------------------------------------------------
--			     Rebuild Index			       --
-------------------------------------------------------------------------
--
-- Copied from ICXCGCDB.pls
--



----------------------------- by sudsubra --------------------

-- global cursor to select all installed languages
-- used in mutliple procedures
CURSOR installed_languages_csr IS
SELECT language_code
FROM fnd_languages
WHERE installed_flag IN ('B', 'I');

-- Procedure the get the nullify values for the different datatypes
-- this returns the values for varchar, number and date
PROCEDURE get_nullify_values
(
  x_nullify_char OUT NOCOPY VARCHAR2,
  x_nullify_num OUT NOCOPY NUMBER,
  x_nullify_date OUT NOCOPY DATE
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  x_nullify_char := PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR;
  x_nullify_num := PO_PDOI_CONSTANTS.g_NULLIFY_NUM;
  x_nullify_date := PO_PDOI_CONSTANTS.g_NULLIFY_DATE;

  l_err_loc := 200;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.get_nullify_values(' ||
     l_err_loc || '), ' || SQLERRM);
END get_nullify_values;

-- Procedure to validate the descriptor before it gets created
-- this method is only called from item load
PROCEDURE validate_descriptor_for_create
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_cat_id IN NUMBER,
  p_language IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_error OUT NOCOPY VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_num_val PLS_INTEGER := 0;
  l_start_pos PLS_INTEGER;
  l_end_pos PLS_INTEGER;
  l_first_zero_pos PLS_INTEGER;
BEGIN

  x_is_valid := 'Y';

  l_err_loc := 100;

  BEGIN
    IF (p_cat_id = 0) THEN
      -- root descriptor
      -- check that descriptor key has to be unique across all root and category
      -- descriptor keys
      l_err_loc := 110;
      SELECT 1
      INTO l_num_val
      FROM DUAL
      WHERE EXISTS (SELECT 1
                    FROM icx_cat_attributes_tl
                    WHERE UPPER(key) = UPPER(p_key)
                    AND language = p_language);
    ELSE
      l_err_loc := 120;
      -- category descriptor
      -- check that descriptor key has to be unique across all root descriptor
      -- keys and descriptor keys within the category
      SELECT 1
      INTO l_num_val
      FROM DUAL
      WHERE EXISTS (SELECT 1
                    FROM icx_cat_attributes_tl
                    WHERE UPPER(key) = UPPER(p_key)
                    AND language = p_language
                    AND (rt_category_id = p_cat_id OR
                         rt_category_id = 0));
    END IF;

    -- found a descriptor,  error error out
    l_err_loc := 150;
    x_error := 'ICX_CAT_ATTRIBUTE_NOT_UNIQUE';
    x_is_valid := 'N';
  EXCEPTION
  WHEN no_data_found THEN
    l_err_loc := 170;
    null;
  END;


  IF (x_is_valid = 'Y') THEN
    l_err_loc := 200;

    -- now we check for uniqueness of name
    -- if we are trying to add a root descriptor then name has to be unique
    -- across all categories
    -- else it just has to be unique in that category and root category
    BEGIN
      IF (p_cat_id = 0) THEN
        l_err_loc := 220;
        -- for base descriptor
        SELECT 1
        INTO l_num_val
        FROM DUAL
        WHERE EXISTS (SELECT 1
                      FROM icx_cat_attributes_tl
                      WHERE UPPER(attribute_name) = UPPER(p_name)
                      AND language = p_language);
      ELSE
        l_err_loc := 230;
        -- for category descriptor
        SELECT 1
        INTO l_num_val
        FROM DUAL
        WHERE EXISTS (SELECT 1
                      FROM icx_cat_attributes_tl
                      WHERE UPPER(attribute_name) = UPPER(p_name)
                      AND language = p_language
                      AND (rt_category_id = p_cat_id OR
                           rt_category_id = 0));
      END IF;

      l_err_loc := 250;
      -- if it found a name then error
      x_error := 'ICX_CAT_ATTRIBUTE_NOT_UNIQUE';
      x_is_valid := 'N';

    EXCEPTION
      WHEN no_data_found THEN
      -- we are fine
      l_err_loc := 270;
      NULL;
    END;
  END IF;

  l_err_loc := 300;

  -- now we check to see if the max number of descriptors has been reached
  -- for this type
  -- for base this is 100 (other than the seeded ones), for category 50
  IF (x_is_valid = 'Y') THEN
    IF (p_cat_id = 0) THEN
      -- for base
      l_err_loc := 310;
      SELECT COUNT(*)
      INTO l_num_val
      FROM icx_cat_attributes_tl
      WHERE rt_category_id = 0
      AND language = p_language
      AND to_char(type) = p_type
      AND attribute_id > 100;

      l_err_loc := 320;

      -- make sure the section_map is fine for creating a new base descriptor
      IF p_type = 0 THEN
        l_start_pos := 1;
        l_end_pos := 100;
      ELSIF p_type = 1 THEN
        l_start_pos := 101;
        l_end_pos := 200;
      ELSIF p_type = 2 THEN
        l_start_pos := 201;
        l_end_pos := 300;
      END IF;

      l_err_loc := 325;

      SELECT instr(section_map, '0', l_start_pos, 1)
      INTO l_first_zero_pos
      FROM icx_cat_categories_tl
      WHERE rt_category_id = 0
      AND language = p_language;

      l_err_loc := 330;

      IF (l_num_val >= 100 OR l_first_zero_pos > l_end_pos) THEN
        l_err_loc := 330;
        x_error := 'ICX_CAT_BASE_ATT_NUM_EXCEEDED';
        x_is_valid := 'N';
      END IF;
    ELSE
      -- for category
      l_err_loc := 340;
      SELECT COUNT(*)
      INTO l_num_val
      FROM icx_cat_attributes_tl
      WHERE rt_category_id = p_cat_id
      AND language = p_language
      AND to_char(type) = p_type;

      l_err_loc := 345;

      -- make sure the section_map is fine for creating a new category descriptor
      IF p_type = 0 THEN
        l_start_pos := 1;
        l_end_pos := 50;
      ELSIF p_type = 1 THEN
        l_start_pos := 101;
        l_end_pos := 150;
      ELSIF p_type = 2 THEN
        l_start_pos := 201;
        l_end_pos := 250;
      END IF;

      l_err_loc := 350;

      SELECT instr(section_map, '0', l_start_pos, 1)
      INTO l_first_zero_pos
      FROM icx_cat_categories_tl
      WHERE rt_category_id = p_cat_id
      AND language = p_language;

      l_err_loc := 355;

      IF (l_num_val >= 50 OR l_first_zero_pos > l_end_pos) THEN
        l_err_loc := 360;
        x_error := 'ICX_CAT_CAT_ATT_NUM_EXCEED';
        x_is_valid := 'N';
      END IF;

    END IF;
  END IF;

  l_err_loc := 400;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.validate_descriptor_for_create(' ||
     l_err_loc || '), ' || SQLERRM);

END validate_descriptor_for_create;

-- procedure to save the failed category into the failed lines table
PROCEDURE save_failed_category
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_description IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 100;

  insert_failed_line(p_request_id, p_line_number, p_action, 'CATEGORY',
    'ICX_CAT_KEY', p_key);

  l_err_loc := 200;

  insert_failed_line(p_request_id, p_line_number, p_action, 'CATEGORY',
    'ICX_CAT_NAME', p_name);

  l_err_loc := 300;

  insert_failed_line(p_request_id, p_line_number, p_action, 'CATEGORY',
    'ICX_CAT_TYPE', p_type);

  l_err_loc := 400;

  insert_failed_line(p_request_id, p_line_number, p_action, 'CATEGORY',
    'ICX_CAT_DESCRIPTION', p_description);

  l_err_loc := 500;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
   ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.save_failed_category(' ||
     l_err_loc || '), ' || SQLERRM);
END save_failed_category;

-- procedure to save the failed descriptor into the failed lines table
PROCEDURE save_failed_descriptor
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_description IN VARCHAR2,
  p_owner_key IN VARCHAR2,
  p_owner_name IN VARCHAR2,
  p_sequence IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_search_results_visible IN VARCHAR2,
  p_restrict_access IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 100;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_KEY', p_key);

  l_err_loc := 200;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_NAME', p_name);

  l_err_loc := 300;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_TYPE', p_type);

  l_err_loc := 400;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_DESCRIPTION', p_description);

  l_err_loc := 500;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_OWNER_KEY', p_owner_key);

  l_err_loc := 600;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_OWNER_NAME', p_owner_name);

  l_err_loc := 700;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_SEQUENCE', p_sequence);

  l_err_loc := 800;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_SEARCHABLE', p_searchable);

  l_err_loc := 900;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_ITEM_DETAIL_VISIBLE', p_item_detail_visible);

  l_err_loc := 1000;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_SEARCH_RESULTS_VISIBLE', p_search_results_visible);

  l_err_loc := 1100;

  insert_failed_line(p_request_id, p_line_number, p_action, 'DESCRIPTOR',
    'ICX_CAT_RESTRICT_ACCESS', p_restrict_access);

  l_err_loc := 1200;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.save_failed_descriptor(' ||
     l_err_loc || '), ' || SQLERRM);
END save_failed_descriptor;

-- procedure to save the failed relationships into the failed lines table
PROCEDURE save_failed_relationship
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_parent_key IN VARCHAR2,
  p_parent_name IN VARCHAR2,
  p_child_key IN VARCHAR2,
  p_child_name IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 100;

  insert_failed_line(p_request_id, p_line_number, p_action, 'RELATIONSHIP',
    'ICX_CAT_PARENT_KEY', p_parent_key);

  l_err_loc := 200;

  insert_failed_line(p_request_id, p_line_number, p_action, 'RELATIONSHIP',
    'ICX_CAT_PARENT_NAME', p_parent_name);

  l_err_loc := 300;

  insert_failed_line(p_request_id, p_line_number, p_action, 'RELATIONSHIP',
    'ICX_CAT_CHILD_KEY', p_child_key);

  l_err_loc := 400;

  insert_failed_line(p_request_id, p_line_number, p_action, 'RELATIONSHIP',
    'ICX_CAT_CHILD_NAME', p_child_name);

  l_err_loc := 500;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.save_failed_relationship(' ||
     l_err_loc || '), ' || SQLERRM);
END save_failed_relationship;

-- inserts a row into the failed lines table
PROCEDURE insert_failed_line
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  p_row_type IN VARCHAR2,
  p_descriptor_key IN VARCHAR2,
  p_descriptor_value IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  INSERT INTO icx_por_failed_lines
    (job_number, line_number, action, row_type, descriptor_key, descriptor_value,
    request_id, program_id, program_application_id, program_login_id)
  VALUES (p_request_id, p_line_number, p_action, p_row_type, p_descriptor_key,
    p_descriptor_value, p_request_id, fnd_global.conc_program_id,
    fnd_global.prog_appl_id, fnd_global.conc_login_id);

  l_err_loc := 200;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.insert_failed_line(' ||
     l_err_loc || '), ' || SQLERRM);
END insert_failed_line;

-- inserts a row into the failed messages table
PROCEDURE insert_failed_message
(
  p_request_id IN NUMBER,
  p_descriptor_key IN VARCHAR2,
  p_message_name IN VARCHAR2,
  p_line_number IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  INSERT INTO icx_por_failed_line_messages
    (job_number, descriptor_key, message_name, line_number, request_id, program_id,
    program_application_id, program_login_id)
  VALUES (p_request_id, p_descriptor_key, p_message_name, p_line_number, p_request_id,
    fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id);

  l_err_loc := 200;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.insert_failed_message(' ||
     l_err_loc || '), ' || SQLERRM);
END insert_failed_message;


-- procedure to create a category
-- assumes that the parameters are valid
-- called from schema load
PROCEDURE create_category
(
  x_category_id OUT NOCOPY NUMBER,
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN NUMBER,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
BEGIN

  l_err_loc := 100;

  -- xxx why is the sequence icx_por_categoryid
  SELECT icx_por_categoryid.nextval
  INTO x_category_id
  FROM dual;

  l_err_loc := 200;

  FOR language_row IN installed_languages_csr LOOP

    l_err_loc := 300;

    INSERT INTO icx_cat_categories_tl
      (rt_category_id, language, source_lang, category_name, description, type,
      key, upper_key, upper_category_name, request_id, rebuild_flag, section_map,
      created_by, creation_date, last_updated_by, last_update_date, last_update_login,
      program_id, program_application_id, program_login_id)
    VALUES (x_category_id, language_row.language_code, p_language, p_name,
      p_description, p_type, p_key, upper(p_key), upper(p_name), p_request_id,
      'N', lpad('0', '300', '0'), p_user_id, sysdate, p_user_id, sysdate, p_login_id,
      fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id);

  END LOOP;

  l_err_loc := 400;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.create_category(' ||
     l_err_loc || '), ' || SQLERRM);
END create_category;

-- procedure to update a category
-- assumes that the parameters are valid
-- called from schema load
PROCEDURE update_category
(
  p_category_id IN NUMBER,
  p_language IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;

  l_lang_table DBMS_SQL.VARCHAR2_TABLE;

  CURSOR translate_category_lang_csr
  IS
    SELECT language
    FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    and type = p_type
    and source_lang = p_language
    and  source_lang <> language
    UNION
    SELECT p_language FROM dual;

BEGIN

  l_err_loc := 100;

  -- bulk fetch all languages to update the category for
  OPEN translate_category_lang_csr;
  FETCH translate_category_lang_csr BULK COLLECT into l_lang_table;
  CLOSE translate_category_lang_csr;

  l_err_loc := 200;

  -- we update category name and description and source lang
  -- only for those langauages that were sourced from current lang
  -- and have not themselves been translated
  -- only description can be specified as #DEL
  FORALL i in 1..l_lang_table.COUNT
    UPDATE icx_cat_categories_tl
    SET category_name = nvl(p_name, category_name),
      upper_category_name = nvl(upper(p_name), upper_category_name),
      description = decode(p_description, '#DEL', null, null, description, p_description),
      source_lang = p_language,
      last_updated_by = p_user_id,
      last_update_date = sysdate,
      last_update_login = p_login_id,
      request_id = p_request_id,
      rebuild_flag = decode(p_name, category_name, rebuild_flag, null, rebuild_flag, 'Y'),
      program_id = fnd_global.conc_program_id,
      program_application_id = fnd_global.prog_appl_id,
      program_login_id = fnd_global.conc_login_id
    WHERE rt_category_id = p_category_id
    AND language = l_lang_table(i);

  l_err_loc := 300;

  -- we need to update the category name in icx_cat_items_ctx_hdrs_tlp
  -- if it is an item category

  IF (p_type = 2) THEN
    FORALL i in 1..l_lang_table.COUNT
      UPDATE icx_cat_items_ctx_hdrs_tlp
      SET ip_category_name = p_name
      WHERE ip_category_id = p_category_id
      AND language = l_lang_table(i);
  END IF;

 l_err_loc := 400;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.update_category(' ||
     l_err_loc || '), ' || SQLERRM);
END update_category;


-- procedure to delete a category
-- assumes that the parameters are valid
-- called from schema load
PROCEDURE delete_category
(
  p_category_id IN NUMBER,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;

  l_child_cat_table DBMS_SQL.NUMBER_TABLE;
  l_child_cat_type_table DBMS_SQL.VARCHAR2_TABLE;
  l_parent_cat_count_table DBMS_SQL.NUMBER_TABLE;

  CURSOR category_children_csr
  IS
    SELECT browse.child_category_id, cat.type, count(*)
    FROM icx_cat_browse_trees browse, icx_cat_categories_tl cat
    WHERE browse.child_category_id IN
      (SELECT child_category_id
       FROM icx_cat_browse_trees
      WHERE parent_category_id = p_category_id)
    AND browse.child_category_id = cat.rt_category_id
    AND language = p_language
    GROUP BY browse.child_category_id, cat.type;
BEGIN

  l_err_loc := 100;
  -- first check to see if it is a root category
  -- do not allow delete to root category
  IF (p_category_id > 0) THEN

    l_err_loc := 200;
    -- we check if category can be deleted
    -- this is checked in validate, but we do it here just for sanity
    -- and to prevent data corruption
    IF (can_category_be_deleted(p_category_id) = 0) THEN

      l_err_loc := 300;
      -- now we can safely begin the delete category process

      -- first delete the category itself
      DELETE FROM icx_cat_categories_tl
      WHERE rt_category_id = p_category_id;

      l_err_loc := 310;

      -- then we delete the attributes for that category
      DELETE FROM icx_cat_attributes_tl
      WHERE rt_category_id = p_category_id;

      l_err_loc := 320;

      --delete the mappings for the item category.
      DELETE FROM icx_por_category_order_map
      WHERE rt_category_id = p_category_id;

      l_err_loc := 320;

      -- xxx make sure we can use category id here
      -- and do not need to use key
      DELETE FROM icx_por_category_data_sources
      WHERE rt_category_id = p_category_id;

      -- now delete the link from this category to its parents
      DELETE FROM icx_cat_browse_trees
      WHERE child_category_id = p_category_id;

       -- bulk fetch all children of this category
      OPEN category_children_csr;
      FETCH category_children_csr
      BULK COLLECT INTO l_child_cat_table, l_child_cat_type_table,  l_parent_cat_count_table;
      CLOSE category_children_csr;

      -- now delete all the links from this category to its children
      FORALL i in 1..l_child_cat_table.COUNT
        DELETE FROM icx_cat_browse_trees
        WHERE parent_category_id = p_category_id
        AND child_category_id = l_child_cat_table(i);

      -- now for all those children of this category that we are deleting
      -- if the type is 1 and the child category has no other parents
      -- i.e. parent count is 1 then we put the child under the root
      -- xxx why are we using 0 instead of ids? for this
      -- we were doing this in 11.5.10 now changed
      FORALL i in 1..l_child_cat_table.COUNT
        INSERT INTO icx_cat_browse_trees
         	 (parent_category_id, child_category_id, created_by, creation_date,
           last_updated_by, last_update_date, last_update_login, request_id,
           program_id, program_application_id, program_login_id)
        SELECT 0, l_child_cat_table(i), p_user_id, sysdate, p_user_id, sysdate, p_login_id, p_request_id,
        fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id
        FROM dual
        WHERE l_child_cat_type_table(i) = 1
        AND l_parent_cat_count_table(i) = 1;

    END IF; -- can_category_be...
  END IF; -- p_category_id > 0

  l_err_loc := 400;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.delete_category(' ||
     l_err_loc || '), ' || SQLERRM);
END delete_category;

-- procedure to validate a category
PROCEDURE validate_category
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_type IN VARCHAR2,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_action IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_system_action OUT NOCOPY VARCHAR2,
  x_category_id OUT NOCOPY NUMBER,
  x_converted_type OUT NOCOPY VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_current_type NUMBER;
  l_count PLS_INTEGER := 0;
BEGIN

  l_err_loc := 100;

  x_is_valid := 'Y';

  -- first thing is key should not be null
  IF (p_key is null) THEN
      -- key is null, error regardless of action
      l_err_loc := 110;
      insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CAT_KEY_REQUIRED',
        p_line_number);
      x_is_valid := 'N';
  ELSE

    -- key is provided

    -- now we try to derive system action and at the same time get the
    -- category id, type for existing category for update and delete
    -- possible user actions can be only 'SYNC' and 'DELETE'
    -- this is validated in the DTD
    -- we need to derive system action only for SYNC
    l_err_loc := 200;

    BEGIN

      SELECT rt_category_id, type
      INTO x_category_id, l_current_type
      FROM icx_cat_categories_tl
      WHERE upper_key = upper(p_key)
      AND language = p_language
      AND rownum = 1;

      l_err_loc := 210;

      -- if this is successful that means we found the category
      -- if it was sync it is an UPDATE, else we are ok for delete
      IF (p_user_action = 'SYNC') THEN
        l_err_loc := 230;
        x_system_action := 'UPDATE';
      ELSE
        l_err_loc := 240;
        x_system_action := 'DELETE';
      END IF;

    EXCEPTION
    WHEN no_data_found THEN
      l_err_loc := 250;

      -- this means we did not find a category
      -- now if this is DELETE then it is an error
      -- if it was sync it is an ADD
      IF (p_user_action = 'DELETE') THEN
        l_err_loc := 260;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CAT_DOES_NOT_EXIST',
          p_line_number);
        x_is_valid := 'N';
        x_system_action := p_user_action;
      ELSIF (p_user_action = 'SYNC') THEN
        l_err_loc := 270;
        x_system_action := 'ADD';
      END IF;
    END;
  END IF;

  l_err_loc := 300;

  -- next we will validate type for add and update
  IF (x_is_valid = 'Y') THEN

    l_err_loc := 310;



    -- next we validate type since this is similar for add and update
    IF (x_system_action IN ('ADD', 'UPDATE')) THEN
      -- we default type to 2 if add and not provided
      IF (x_system_action = 'ADD' AND p_type is null) THEN
        l_err_loc := 320;
        x_converted_type := '2';
      ELSIF (p_type IN ('0', '1', '2')) THEN
        l_err_loc := 340;
        x_converted_type := p_type;
      ELSIF (p_type is not null) THEN
        l_err_loc := 350;

        BEGIN
          SELECT lookup_code INTO x_converted_type
          FROM fnd_lookup_values
          WHERE lookup_type = 'ICX_CAT_TYPE'
          AND UPPER(meaning) = UPPER(p_type)
          AND language = p_language;

        EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 360;
          insert_failed_message(p_request_id, 'ICX_CAT_TYPE', 'ICX_CAT_INVALID_CAT_TYPE',
        p_line_number);
          x_is_valid := 'N';
        END;
      END IF;
    END IF;
  END IF;

  -- now we have found system action, now we validate based on it
  -- we continue validation only if valid
  IF (x_is_valid = 'Y') THEN
    l_err_loc := 400;
    IF (x_system_action = 'ADD') THEN

      l_err_loc := 500;

      -- for add we do the following validations
      -- 1. The name must be non-null and unique

      IF (p_name IS NULL) THEN
        l_err_loc := 510;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CATEGORY_NAME_REQUIRED',
          p_line_number);
          x_is_valid := 'N';
      ELSE
        l_err_loc := 520;
        SELECT count(1) INTO l_count
        FROM icx_cat_categories_tl
        WHERE upper_category_name = UPPER(p_name);

        l_err_loc := 530;

        IF (l_count > 0) THEN
          l_err_loc := 540;
          insert_failed_message(p_request_id, 'ICX_CAT_NAME', 'ICX_CAT_CAT_NAME_NONUNIQUE_ADD',
            p_line_number);
          x_is_valid := 'N';
        END IF;
      END IF;

    ELSIF (x_system_action = 'UPDATE') THEN

      l_err_loc := 600;

      -- for update we do the following validations
      -- 1. Cannot update root category
      IF (x_category_id = 0) THEN
        l_err_loc := 630;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CANNOT_UPD_ROOT_CAT',
          p_line_number);
        x_is_valid := 'N';
      END IF;
      -- 2. The name if provided must be unique among other categories

      IF (p_name IS NOT NULL) THEN
        l_err_loc := 610;
        SELECT count(1) INTO l_count
        FROM icx_cat_categories_tl
        WHERE upper_category_name = UPPER(p_name)
        and rt_category_id <> x_category_id;

        l_err_loc := 620;

        IF (l_count > 0) THEN
          l_err_loc := 630;
          insert_failed_message(p_request_id, 'ICX_CAT_NAME', 'ICX_CAT_CAT_NAME_NONUNIQUE_UPD',
            p_line_number);
          x_is_valid := 'N';
        END IF;
      END IF;

      l_err_loc := 630;

      -- 2. Type must match the current type
      IF (x_converted_type IS NOT NULL AND x_converted_type <> l_current_type) THEN
        l_err_loc := 630;
        insert_failed_message(p_request_id, 'ICX_CAT_TYPE', 'ICX_CAT_CANNOT_CHANGE_CAT_TYPE',
          p_line_number);
        x_is_valid := 'N';
      END IF;

    ELSIF (x_system_action = 'DELETE') THEN

      l_err_loc := 700;
      -- for delete we do the following validations
      -- 1. Cannot update root category
      IF (x_category_id = 0) THEN
        l_err_loc := 630;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CANNOT_DEL_ROOT_CAT',
          p_line_number);
        x_is_valid := 'N';
      END IF;
      -- 2. The category must not be referenced on any documents or master items
      -- Here we ignore name and type since we just match on key
      IF (can_category_be_deleted(x_category_id) = 1) THEN
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CAT_HAS_ITEMS',
          p_line_number);
        x_is_valid := 'N';
      END IF;

    END IF;

  END IF;

  l_err_loc := 800;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.validate_category(' ||
     l_err_loc || '), ' || SQLERRM);
END validate_category;



-- function to check if category can be deleted
-- a category can be deleted if it is not referenced on any documents and master items
FUNCTION can_category_be_deleted
(
  p_ip_category_id IN NUMBER
)
RETURN NUMBER
IS
  l_err_loc PLS_INTEGER;
  l_category_referenced PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  -- assume not referenced at first
  l_category_referenced := 0;

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM icx_cat_items_ctx_hdrs_tlp
                  WHERE ip_category_id = p_ip_category_id);

    l_err_loc := 150;

  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  l_err_loc := 200;

  -- now check the po tables
  -- first the transaction table

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM po_lines_all
                  WHERE ip_category_id = p_ip_category_id);

    l_err_loc := 250;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 300;

  -- then the draft table

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM po_lines_draft_all
                  WHERE ip_category_id = p_ip_category_id);

    l_err_loc := 350;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  -- now we check the sourcing tables
  l_err_loc := 400;

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_auction_item_prices_all
                  WHERE ip_category_id = p_ip_category_id);

    l_err_loc := 450;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 500;

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_item_prices_interface
                  WHERE ip_category_id = p_ip_category_id);

    l_err_loc := 550;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 600;

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_auc_items_interface
                  WHERE ip_category_id = p_ip_category_id);

    l_err_loc := 650;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  -- now we also need to check for category name in the sourcing interface table

  l_err_loc := 700;

  BEGIN
    SELECT 1
    INTO l_category_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_item_prices_interface
                  WHERE ip_category_name IN (SELECT category_name
                                             FROM icx_cat_categories_tl
                                             WHERE rt_category_id = p_ip_category_id));

    l_err_loc := 750;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 800;

  RETURN l_category_referenced;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.can_category_be_deleted(' ||
     l_err_loc || '), ' || SQLERRM);
END can_category_be_deleted;


-- procedure to add a relationship
-- assumes that the categories to be related are valid
PROCEDURE add_relationship
(
  p_parent_id IN NUMBER,
  p_child_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_type NUMBER;
BEGIN

  l_err_loc := 100;

  SELECT type
  INTO l_type
  FROM icx_cat_categories_tl
  WHERE rt_category_id = p_parent_id
  AND rownum = 1;

  l_err_loc := 110;

  -- for sanity only proceed if parent is root or parent is of type 1
  IF (p_parent_id = 0 OR l_type = 1) THEN

    l_err_loc := 120;


    -- now we insert the relationship, if it does not already exist
    INSERT INTO icx_cat_browse_trees(parent_category_id, child_category_id,
      created_by, creation_date, last_updated_by, last_update_date, last_update_login,
      request_id, program_id, program_application_id, program_login_id)
    SELECT p_parent_id, p_child_id, p_user_id, sysdate, p_user_id, sysdate, p_login_id,
    p_request_id, fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id
    FROM dual
    WHERE NOT EXISTS (SELECT 1
                      FROM icx_cat_browse_trees
                      WHERE parent_category_id = p_parent_id
                      AND child_category_id = p_child_id);

    l_err_loc := 130;

    IF (p_parent_id <> 0) THEN

      l_err_loc := 140;
      -- if parent is not root we need to do more stuff
      -- first we remove any link from the child to root if it exists
      DELETE FROM icx_cat_browse_trees
      WHERE parent_category_id = 0
      AND child_category_id = p_child_id;

      l_err_loc := 150;

      -- if the parent is does not have a parent
      --  then we need to attach it to the root
      INSERT INTO icx_cat_browse_trees(parent_category_id, child_category_id,
      created_by, creation_date, last_updated_by, last_update_date, last_update_login,
      request_id, program_id, program_application_id, program_login_id)
      SELECT 0, p_parent_id, p_user_id, sysdate, p_user_id, sysdate, p_login_id,
      p_request_id, fnd_global.conc_program_id, fnd_global.prog_appl_id, fnd_global.conc_login_id
      FROM dual
      WHERE NOT EXISTS (SELECT 1
                        FROM icx_cat_browse_trees
                        WHERE child_category_id = p_parent_id);

      l_err_loc := 160;

    END IF;

    l_err_loc := 170;

  END IF;

  l_err_loc := 180;

  COMMIT;

  l_err_loc := 190;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.add_relationship(' ||
     l_err_loc || '), ' || SQLERRM);
END add_relationship;


-- procedure to delete a relationship
-- assumes that the categories to be related are valid
PROCEDURE delete_relationship
(
  p_parent_id IN NUMBER,
  p_child_id IN NUMBER,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_type NUMBER;
BEGIN

  l_err_loc := 100;

  -- xxx should we add a link from child to root if no parent exists

  SELECT type
  INTO l_type
  FROM icx_cat_categories_tl
  WHERE rt_category_id = p_parent_id
  AND rownum = 1;

  l_err_loc := 110;

   -- for sanity only proceed if parent is root or parent is of type 1
  IF (p_parent_id = 0 OR l_type = 1) THEN

    l_err_loc := 120;
    DELETE FROM icx_cat_browse_trees
    WHERE parent_category_id = p_parent_id
    AND child_category_id = p_child_id;

    l_err_loc := 130;
  END IF;

  l_err_loc := 140;

  COMMIT;

  l_err_loc := 150;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.delete_relationship(' ||
     l_err_loc || '), ' || SQLERRM);
END delete_relationship;


-- procedure to delete a relationship
-- assumes that the categories to be related are valid
PROCEDURE validate_relationship
(
  p_parent_key IN VARCHAR2,
  p_parent_name IN VARCHAR2,
  p_child_key IN VARCHAR2,
  p_child_name IN VARCHAR2,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_action IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_system_action OUT NOCOPY VARCHAR2,
  x_parent_id OUT NOCOPY NUMBER,
  x_child_id OUT NOCOPY NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_parent_type NUMBER;
  l_parent_id_from_name NUMBER;
  l_child_id_from_name NUMBER;
  l_count PLS_INTEGER;
BEGIN

  l_err_loc := 100;

  x_is_valid := 'Y';

  -- user action has to be sync or delete
  -- this is validated by the DTD

  -- first get system action
  IF (p_user_action = 'SYNC') THEN
    -- sync is basically add
    l_err_loc := 110;
    x_system_action := 'ADD';
  ELSE
    l_err_loc := 120;
    x_system_action := 'DELETE';
  END IF;

  l_err_loc := 130;

  -- now first we try to get the parent category from key and name
  IF (p_parent_key IS NULL AND p_parent_name IS NULL) THEN

    l_err_loc := 140;
    insert_failed_message(p_request_id, 'ICX_CAT_PARENT_KEY', 'ICX_CAT_PARENT_KEY_NAME_REQD',
      p_line_number);
    x_is_valid := 'N';

  END IF;

  l_err_loc := 150;

  IF (x_is_valid = 'Y') THEN

    l_err_loc := 160;

    IF (p_parent_key IS NOT NULL) THEN

      l_err_loc := 170;
      -- there is a key, try to get the category from the key

      BEGIN

      SELECT rt_category_id, type
      INTO x_parent_id, l_parent_type
      FROM icx_cat_categories_tl
      WHERE upper_key = UPPER(p_parent_key)
      AND language = p_language;

      l_err_loc := 180;

      EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 190;
          insert_failed_message(p_request_id, 'ICX_CAT_PARENT_KEY',
            'ICX_CAT_PARENT_KEY_NOT_EXIST', p_line_number);
        x_is_valid := 'N';
      END;

    END IF;

    l_err_loc := 200;

    IF (p_parent_name IS NOT NULL) THEN

      l_err_loc := 210;
      -- there is a name, try to get the category from the name

      BEGIN

      SELECT rt_category_id, type
      INTO l_parent_id_from_name, l_parent_type
      FROM icx_cat_categories_tl
      WHERE upper_category_name = UPPER(p_parent_name)
      AND language = p_language;

      l_err_loc := 220;

      EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 230;
          insert_failed_message(p_request_id, 'ICX_CAT_PARENT_NAME',
            'ICX_CAT_PARENT_NAME_NOT_EXIST', p_line_number);
        x_is_valid := 'N';
      END;

    END IF;

    l_err_loc := 240;

    -- now if both were provided then we need to compare the categories they got
    IF (x_parent_id IS NOT NULL) THEN
      IF (l_parent_id_from_name IS NOT NULL AND x_parent_id <> l_parent_id_from_name) THEN
        l_err_loc := 250;
        insert_failed_message(p_request_id, 'ICX_CAT_PARENT_KEY',
          'ICX_CAT_PARENT_KEY_NAME_DIFF', p_line_number);
        x_is_valid := 'N';
      END IF;
    ELSE
      x_parent_id := l_parent_id_from_name;
    END IF;

    l_err_loc := 260;

    -- also either way we have to make sure that the parent category is a
    -- browsing category or the root category
    IF (l_parent_type = 2) THEN
      l_err_loc := 270;
      IF (p_parent_key IS NOT NULL) THEN
        l_err_loc := 280;
        insert_failed_message(p_request_id, 'ICX_CAT_PARENT_KEY',
          'ICX_CAT_ITEM_CAT_CANNOT_PARENT', p_line_number);
        x_is_valid := 'N';
      ELSE
        l_err_loc := 290;
        insert_failed_message(p_request_id, 'ICX_CAT_PARENT_NAME',
          'ICX_CAT_ITEM_CAT_CANNOT_PARENT', p_line_number);
        x_is_valid := 'N';
      END IF;
	  END IF;

  END IF;


  l_err_loc := 300;

  -- now we do the same for the child
  IF (p_child_key IS NULL AND p_child_name IS NULL) THEN

    l_err_loc := 310;
    insert_failed_message(p_request_id, 'ICX_CAT_CHILD_KEY', 'ICX_CAT_CHILD_KEY_NAME_REQD',
      p_line_number);
    x_is_valid := 'N';

  END IF;

  l_err_loc := 320;

  IF (x_is_valid = 'Y') THEN

    l_err_loc := 330;

    IF (p_child_key IS NOT NULL) THEN

      l_err_loc := 340;
      -- there is a key, try to get the category from the key

      BEGIN

      SELECT rt_category_id
      INTO x_child_id
      FROM icx_cat_categories_tl
      WHERE upper_key = UPPER(p_child_key)
      AND language = p_language;

      l_err_loc := 350;

      EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 360;
          insert_failed_message(p_request_id, 'ICX_CAT_CHILD_KEY',
            'ICX_CAT_CHILD_KEY_NOT_EXIST', p_line_number);
        x_is_valid := 'N';
      END;

    END IF;

    l_err_loc := 370;

    IF (p_child_name IS NOT NULL) THEN

      l_err_loc := 380;
      -- there is a name, try to get the category from the name

      BEGIN

      SELECT rt_category_id
      INTO l_child_id_from_name
      FROM icx_cat_categories_tl
      WHERE upper_category_name = UPPER(p_child_name)
      AND language = p_language;

      l_err_loc := 390;

      EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 400;
          insert_failed_message(p_request_id, 'ICX_CAT_CHILD_NAME',
            'ICX_CAT_CHILD_NAME_NOT_EXIST', p_line_number);
        x_is_valid := 'N';
      END;

    END IF;

    l_err_loc := 410;

    -- now if both were provided then we need to compare the categories they got
    IF (x_child_id IS NOT NULL) THEN
      IF (l_child_id_from_name IS NOT NULL AND x_child_id <> l_child_id_from_name) THEN
        l_err_loc := 420;
        insert_failed_message(p_request_id, 'ICX_CAT_CHILD_KEY',
          'ICX_CAT_CHILD_KEY_NAME_DIFF', p_line_number);
        x_is_valid := 'N';
      END IF;
    ELSE
      x_child_id := l_child_id_from_name;
    END IF;

  END IF;

  l_err_loc := 500;

  -- now if we have got both parent and child category, we do some more validations

  IF (x_child_id IS NOT NULL AND x_parent_id IS NOT NULL) THEN

    l_err_loc := 510;

    IF (x_system_action = 'ADD') THEN

      l_err_loc := 520;
      -- for add parent and child have to be different

      IF (x_child_id = x_parent_id) THEN

        l_err_loc := 530;

        IF (p_child_key IS NOT NULL) THEN
          l_err_loc := 540;
          insert_failed_message(p_request_id, 'ICX_CAT_CHILD_KEY',
            'ICX_CAT_SAME_PARENT_CHILD', p_line_number);
          x_is_valid := 'N';
        ELSE
          l_err_loc := 550;
          insert_failed_message(p_request_id, 'ICX_CAT_CHILD_NAME',
            'ICX_CAT_SAME_PARENT_CHILD', p_line_number);
          x_is_valid := 'N';
        END IF;
      END IF;

      l_err_loc := 552;

      -- now we check to see if this relationship will add a cycle
      SELECT COUNT(*)
      INTO l_count
      FROM icx_cat_browse_trees
      WHERE child_category_id = x_parent_id
      START WITH parent_category_id = x_child_id
      CONNECT BY NOCYCLE PRIOR child_category_id = parent_category_id;

      l_err_loc := 554;

      IF (l_count > 0) THEN
        -- there will be a cycle
        -- so error
        IF (p_child_key IS NOT NULL) THEN
          l_err_loc := 556;
          insert_failed_message(p_request_id, 'ICX_CAT_CHILD_KEY',
            'ICX_CAT_NO_CYCLIC_RELATIONSHIP', p_line_number);
          x_is_valid := 'N';
        ELSE
          l_err_loc := 558;
          insert_failed_message(p_request_id, 'ICX_CAT_CHILD_NAME',
            'ICX_CAT_NO_CYCLIC_RELATIONSHIP', p_line_number);
          x_is_valid := 'N';
        END IF;
      END IF;

    ELSE
      -- action is delete
      -- the relationship that we want to delete has to exist
      l_err_loc := 560;

      BEGIN
        SELECT 1 INTO l_count
        FROM dual
        WHERE EXISTS (SELECT 1 FROM icx_cat_browse_trees
                      WHERE parent_category_id = x_parent_id
                      AND child_category_id = x_child_id);

        l_err_loc := 570;

      EXCEPTION
         WHEN no_data_found THEN
            l_err_loc := 580;
            IF (p_child_key IS NOT NULL) THEN
              l_err_loc := 590;
              insert_failed_message(p_request_id, 'ICX_CAT_CHILD_KEY',
                'ICX_CAT_REL_NOT_EXISTS', p_line_number);
              x_is_valid := 'N';
            ELSE
              l_err_loc := 600;
              insert_failed_message(p_request_id, 'ICX_CAT_CHILD_NAME',
                'ICX_CAT_REL_NOT_EXISTS', p_line_number);
              x_is_valid := 'N';
            END IF;
      END;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.validate_relationship(' ||
     l_err_loc || '), ' || SQLERRM);
END validate_relationship;


-- procedure to create a descriptr
-- this assumes that everything has been validated
PROCEDURE create_descriptor
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN VARCHAR2,
  p_sequence IN NUMBER,
  p_search_results_visible IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_language IN VARCHAR2,
  p_category_id IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  x_descriptor_id OUT NOCOPY NUMBER,
  x_stored_in_table OUT NOCOPY VARCHAR2,
  x_stored_in_column OUT NOCOPY VARCHAR2,
  x_section_tag OUT NOCOPY NUMBER,
  p_restrict_access IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_type VARCHAR2(1);
  l_sequence NUMBER;
  l_search_results_visible VARCHAR2(1);
  l_item_detail_visible VARCHAR2(1);
  l_searchable VARCHAR2(1);
BEGIN

  l_err_loc := 100;

  -- first we default type to text if null
  IF (p_type IS NULL) THEN
    l_err_loc := 110;
    l_type := g_TEXT_TYPE;
  ELSE
    l_err_loc := 115;
    l_type := p_type;
  END IF;

  l_err_loc := 120;

  -- next default sequence if not provided
  -- sequence defaults to the floor of the max current sequence + 1
  -- for that category and language
  -- xxx why language
  IF (p_sequence IS NULL) THEN
    l_err_loc := 130;
    SELECT floor(nvl(max(sequence), 0)) + 1
    INTO l_sequence
    FROM icx_cat_attributes_tl
    WHERE rt_category_id = p_category_id
    AND language = p_language;
  ELSE
    l_err_loc := 135;
    l_sequence := p_sequence;
  END IF;

  l_err_loc := 140;
  -- Now default SRV, IDV and Searchable
  IF (p_search_results_visible IS NULL) THEN
    l_err_loc := 150;
    l_search_results_visible := g_NO;
  ELSE
    l_err_loc := 155;
    l_search_results_visible := p_search_results_visible;
  END IF;

  l_err_loc := 160;

  IF (p_item_detail_visible IS NULL) THEN
    l_err_loc := 170;
    l_item_detail_visible := g_YES;
  ELSE
    l_err_loc := 175;
    l_item_detail_visible := p_item_detail_visible;
  END IF;

  l_err_loc := 170;

  IF (p_searchable IS NULL) THEN
    l_err_loc := 180;
    l_searchable := g_NO;
  ELSE
    l_err_loc := 185;
    l_searchable := p_searchable;
  END IF;

  l_err_loc := 190;

  -- now get the descriptor id from the sequence
  -- xxx change to icx_cat_attributes_s
  SELECT icx_por_descriptorid.nextval
  INTO x_descriptor_id
  FROM dual;

  l_err_loc := 200;
  -- now we create the descriptor

  INSERT INTO icx_cat_attributes_tl (attribute_id, rt_category_id, language,
    source_lang, attribute_name, description, type, key, sequence, searchable,
    search_results_visible, item_detail_visible, request_id, rebuild_flag,
    created_by, creation_date, last_updated_by, last_update_date, last_update_login,
    program_id, program_application_id, program_login_id,restrict_access)
  SELECT x_descriptor_id, p_category_id, fnd_languages.language_code, p_language,
    p_name, decode(p_description, '#DEL', null, p_description), to_number(l_type),
    p_key, l_sequence, to_number(l_searchable), l_search_results_visible,
    l_item_detail_visible, p_request_id, 'N', p_user_id, sysdate,
    p_user_id, sysdate, p_login_id, fnd_global.conc_program_id,
    fnd_global.prog_appl_id, fnd_global.conc_login_id,p_restrict_access
  FROM fnd_languages
  WHERE installed_flag IN ('B', 'I');

  l_err_loc := 210;

  -- since we are creating a descriptor
  -- we update the schema version for search
  inc_schema_change_version(p_category_id, p_request_id, p_user_id, p_login_id);

  l_err_loc := 220;

  -- finally we assign a section tag for the descriptor
  assign_section_tag(p_category_id, x_descriptor_id, l_type, x_section_tag,
    x_stored_in_table, x_stored_in_column, p_request_id);

  l_err_loc := 230;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.create_descriptor(' ||
     l_err_loc || '), ' || SQLERRM);
END create_descriptor;

-- procedure to increment the schema version
PROCEDURE inc_schema_change_version
(
  p_category_id IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_attribute_id NUMBER;
BEGIN

  l_err_loc := 100;

  IF (p_category_id = 0) THEN
    l_err_loc := 110;
    l_attribute_id := g_ROOT_ATTRIB_ID;
  ELSE
    l_err_loc := 120;
    l_attribute_id := g_LOCAL_ATTRIB_ID;
  END IF;

  l_err_loc := 130;

  -- now update the appropriate row
  UPDATE icx_cat_schema_versions
  SET version = version + 1,
      last_updated_by = p_user_id,
      last_update_date = sysdate,
      last_update_login = p_login_id,
      request_id = p_request_id,
      program_id = fnd_global.conc_program_id,
      program_application_id = fnd_global.prog_appl_id,
      program_login_id = fnd_global.conc_login_id
  WHERE descriptor_set_id = l_attribute_id;

  l_err_loc := 140;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.inc_schema_change_version(' ||
     l_err_loc || '), ' || SQLERRM);
END inc_schema_change_version;


-- Procedure to assign the section tag to a given descriptor
-- If the descriptor is already assigned a section tag it will be returned
-- xxx we are not doing select for update now?
-- Before calling this the rows in icx_cat_categories_tl with the
-- given rt_category_id should be locked thru a SELECT...FOR UPDATE
-- to avoid concurrent access to the SECTION_MAP column.  The calling
-- code is responsible for committing the changes.
PROCEDURE assign_section_tag
(
  p_category_id IN NUMBER,
  p_descriptor_id IN NUMBER,
  p_type IN VARCHAR2,
  p_section_tag OUT NOCOPY NUMBER,
  p_stored_in_table OUT NOCOPY VARCHAR2,
  p_stored_in_column OUT NOCOPY VARCHAR2,
  p_request_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_section_map VARCHAR2(300);
  l_col_prefix VARCHAR2(5);
BEGIN

  l_err_loc := 100;

  -- First check whether a section tag is already assigned
  SELECT section_tag, stored_in_table, stored_in_column
  INTO p_section_tag, p_stored_in_table, p_stored_in_column
  FROM icx_cat_attributes_tl
  WHERE attribute_id = p_descriptor_id
  AND rownum = 1;

  l_err_loc := 110;

  -- only proceed if no section tag assigned
  IF (p_section_tag IS NULL) THEN
    l_err_loc := 120;

    -- now get the section map and section tag based on the type
    IF (p_type = 0) THEN

      l_err_loc := 120;
      SELECT section_map, INSTR(section_map, '0', 1, 1)
      INTO l_section_map, p_section_tag
      FROM icx_cat_categories_tl
      WHERE rt_category_id = p_category_id
      AND rownum = 1;

    ELSIF (p_type = 1) THEN

      l_err_loc := 130;
      SELECT section_map, INSTR(section_map, '0', 101, 1)
      INTO l_section_map, p_section_tag
      FROM icx_cat_categories_tl
      WHERE rt_category_id = p_category_id
      AND rownum = 1;

    ELSIF (p_type = 2) THEN

      l_err_loc := 140;
      SELECT section_map, INSTR(section_map, '0', 201, 1)
      INTO l_section_map, p_section_tag
      FROM icx_cat_categories_tl
      WHERE rt_category_id = p_category_id
      AND rownum = 1;
    END IF;

    -- only proceed if we get a valid section tag (should always happen)
    l_err_loc := 150;
    IF (p_section_tag > 0) THEN

      l_err_loc := 160;

      -- now we do the stored in table and column
      -- for stored in column we have either <TYPE>_<COLPREFIX>_ATTRIBUTE<i>

      -- identify the column prefix
      IF (p_category_id = 0) THEN
        l_err_loc := 170;
        l_col_prefix := 'BASE';
      ELSE
        l_err_loc := 180;
        l_col_prefix := 'CAT';
      END IF;

      l_err_loc := 190;

      -- now use type to determine the stored in table and column
      IF (p_type = g_TEXT_TYPE) THEN

        l_err_loc := 200;

        p_stored_in_table := 'PO_ATTRIBUTE_VALUES';
        p_stored_in_column := 'TEXT_' || l_col_prefix || '_ATTRIBUTE' || to_char(p_section_tag);
      ELSIF (p_type = g_NUMERIC_TYPE) THEN

        l_err_loc := 210;
        p_stored_in_table := 'PO_ATTRIBUTE_VALUES';
        p_section_tag := p_section_tag - 100;
        p_stored_in_column := 'NUM_'|| l_col_prefix || '_ATTRIBUTE' || to_char(p_section_tag);
        p_section_tag := p_section_tag + 100;
      ELSE

        l_err_loc := 220;
        p_stored_in_table := 'PO_ATTRIBUTE_VALUES_TLP';
        p_section_tag := p_section_tag - 200;
        p_stored_in_column := 'TL_TEXT_' || l_col_prefix || '_ATTRIBUTE' || to_char(p_section_tag);
        p_section_tag := p_section_tag + 200;
      END IF;

      l_err_loc := 230;
      -- now we compute the new section map

      l_section_map := substr(l_section_map, 1, p_section_tag - 1) || '1' ||
        substr(l_section_map, p_section_tag + 1);

      l_err_loc := 235;
      -- we also need to start section tag off appropriately
      IF (p_category_id > 0) THEN
        -- for category attributes
        p_section_tag := p_section_tag + 5000;
      ELSE
        -- for base attributes
        p_section_tag := p_section_tag + 1000;
      END IF;

      l_err_loc := 240;
      -- now we update the category table with the section map

      UPDATE icx_cat_categories_tl
      SET section_map = l_section_map,
          request_id = p_request_id,
          program_id = fnd_global.conc_program_id,
          program_application_id = fnd_global.prog_appl_id,
          program_login_id = fnd_global.conc_login_id
      WHERE rt_category_id = p_category_id;

      l_err_loc := 250;
      -- now we update the attributes table with the section tag,
      -- stored_in_table and stored_in_column
      UPDATE icx_cat_attributes_tl
      SET section_tag = p_section_tag,
          stored_in_table = p_stored_in_table,
          stored_in_column = p_stored_in_column,
          request_id = p_request_id,
          program_id = fnd_global.conc_program_id,
          program_application_id = fnd_global.prog_appl_id,
          program_login_id = fnd_global.conc_login_id
      WHERE attribute_id = p_descriptor_id;

      l_err_loc := 260;

   END IF;

   l_err_loc := 270;

  END IF;

  l_err_loc := 280;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.assign_section_tag(' ||
     l_err_loc || '), ' || SQLERRM);
END assign_section_tag;


-- Procedure to release the section tag to a given descriptor
-- should be called before the descriptor is actually deleted
-- xxx we are not doing select for update now?
-- Before calling this the rows in icx_cat_categories_tl with the
-- given rt_category_id should be locked thru a SELECT...FOR UPDATE
-- to avoid concurrent access to the SECTION_MAP column.  The calling
-- code is responsible for committing the changes.
PROCEDURE release_section_tag
(
  p_category_id IN NUMBER,
  p_descriptor_id IN NUMBER,
  p_request_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_section_map VARCHAR2(300);
  l_section_tag PLS_INTEGER;
  l_bit_position PLs_INTEGER;
BEGIN

  l_err_loc := 100;

  -- first get the existing section map
  SELECT section_map
  INTO l_section_map
  FROM icx_cat_categories_tl
  WHERE rt_category_id = p_category_id
  AND rownum = 1;

  l_err_loc := 110;

  -- now get the existing section tag
  SELECT section_tag
  INTO l_section_tag
  FROM icx_cat_attributes_tl
  WHERE attribute_id = p_descriptor_id
  AND rownum = 1;

  l_err_loc := 120;

  -- only proceed if there is a section tag assigned
  IF (l_section_tag IS NOT NULL) THEN

    l_err_loc := 130;

    -- now nullify the section tag in attributes table
    UPDATE icx_cat_attributes_tl
    SET section_tag = null,
        request_id = p_request_id,
        program_id = fnd_global.conc_program_id,
        program_application_id = fnd_global.prog_appl_id,
        program_login_id = fnd_global.conc_login_id
    WHERE attribute_id = p_descriptor_id;

    l_err_loc := 140;

    -- now compute the bit position
    IF (p_category_id > 0) THEN
      l_bit_position := l_section_tag - 5000;
    ELSIF (p_descriptor_id >= g_NUM_SEEDED_DESCRIPTORS) THEN
      l_bit_position := l_section_tag - 1000;
    END IF;

    -- now use bit position to compute new section map
    l_err_loc := 150;

    l_section_map := substr(l_section_map, 1, l_bit_position - 1) || '0' ||
      substr(l_section_map, l_bit_position + 1);

    l_err_loc := 150;
    -- now update the section map in the categories table

    UPDATE icx_cat_categories_tl
    SET section_map = l_section_map,
        request_id = p_request_id,
        program_id = fnd_global.conc_program_id,
        program_application_id = fnd_global.prog_appl_id,
        program_login_id = fnd_global.conc_login_id
    WHERE rt_category_id = p_category_id;

    l_err_loc := 160;

  END IF;

  l_err_loc := 170;

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.release_section_tag(' ||
     l_err_loc || '), ' || SQLERRM);
END release_section_tag;


-- procedure to update a descriptr
-- this assumes that everything has been validated
PROCEDURE update_descriptor
(
  p_descriptor_id IN NUMBER,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_category_id IN VARCHAR2,
  p_sequence IN NUMBER,
  p_search_results_visible IN VARCHAR2,
  p_item_detail_visible IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_language IN VARCHAR2,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_restrict_access IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_searchable VARCHAR2(1);
  l_rebuild_flag VARCHAR2(1) := 'N';
BEGIN

  l_err_loc := 100;

  -- first select the current value of searchable

  SELECT to_char(searchable)
  INTO l_searchable
  FROM icx_cat_attributes_tl
  WHERE attribute_id = p_descriptor_id
  AND rownum = 1;

  -- if searchable has changed then we need to rebuild
  l_err_loc := 110;
  IF (p_searchable IS NOT NULL AND p_searchable <> l_searchable) THEN
    l_err_loc := 120;
    l_rebuild_flag := 'Y';
  END IF;

  -- now update the attributes table

  l_err_loc := 120;
  -- first we update the translatable attributes only in the current lang
  -- i.e. name and description
  UPDATE icx_cat_attributes_tl
  SET attribute_name = nvl (p_name, attribute_name),
      description = decode(p_description, '#DEL', null, null, description, p_description),
      source_lang = p_language,
      last_updated_by = p_user_id,
      last_update_date = sysdate,
      last_update_login = p_login_id,
      request_id = p_request_id,
      program_id = fnd_global.conc_program_id,
      program_application_id = fnd_global.prog_appl_id,
      program_login_id = fnd_global.conc_login_id
  WHERE attribute_id = p_descriptor_id
  AND language = p_language;

  l_err_loc := 130;

  -- now update searchable, SRV and IDV and sequence in all languages
  UPDATE icx_cat_attributes_tl
  SET sequence = decode (p_sequence, '#DEL', null, null, sequence, p_sequence),
      searchable = to_number(nvl(p_searchable, searchable)),
      search_results_visible = to_number(nvl(p_search_results_visible, search_results_visible)),
      item_detail_visible = to_number(nvl(p_item_detail_visible, item_detail_visible)),
      rebuild_flag = l_rebuild_flag,
      last_updated_by = p_user_id,
      last_update_date = sysdate,
      last_update_login = p_login_id,
      request_id = p_request_id,
      program_id = fnd_global.conc_program_id,
      program_application_id = fnd_global.prog_appl_id,
      program_login_id = fnd_global.conc_login_id,
      restrict_access = Nvl(p_restrict_access,restrict_access)
  WHERE attribute_id = p_descriptor_id;

  l_err_loc := 140;

  -- now increment the schema version
  inc_schema_change_version(p_category_id, p_request_id, p_user_id, p_login_id);

  l_err_loc := 150;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.update_descriptor(' ||
     l_err_loc || '), ' || SQLERRM);
END update_descriptor;


-- procedure to delete a descriptr
-- this assumes that everything has been validated
PROCEDURE delete_descriptor
(
  p_descriptor_id IN NUMBER,
  p_request_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_category_id NUMBER;
  l_searchable VARCHAR2(1);
BEGIN

  l_err_loc := 100;

  -- for sanity do not allow seeded root descriptor deletion
  IF (p_descriptor_id > g_NUM_SEEDED_DESCRIPTORS) THEN

    l_err_loc := 110;

    -- also for sanity check if descriptor is deletable
    IF (can_descriptor_be_deleted(p_descriptor_id) = 0) THEN

      l_err_loc := 120;

      -- select some information about the descriptor
      SELECT rt_category_id, to_char(searchable)
      INTO l_category_id, l_searchable
      FROM icx_cat_attributes_tl
      WHERE attribute_id = p_descriptor_id
      AND rownum = 1;

      l_err_loc := 130;

      -- then release the section tag before deleting the descriptor
      release_section_tag(l_category_id, p_descriptor_id, p_request_id);

      l_err_loc := 140;

      -- now delete the descriptor
      DELETE from icx_cat_attributes_tl
      WHERE attribute_id = p_descriptor_id;

      l_err_loc := 150;

      -- increment the schema version
      inc_schema_change_version(l_category_id, p_request_id, p_user_id, p_login_id);

      l_err_loc := 160;

    END IF;

    l_err_loc := 190;

  END IF;

  l_err_loc := 200;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.delete_descriptor(' ||
     l_err_loc || '), ' || SQLERRM);
END delete_descriptor;


-- function to check if descriptor can be deleted
-- a descriptor can be deleted if it has no values for any documents
-- we assume that this will be called only for deletable attributes
-- i.e. those that have stored_in_table and stored_in_column as not null
FUNCTION can_descriptor_be_deleted
(
  p_descriptor_id IN NUMBER
)
RETURN NUMBER
IS
  l_err_loc PLS_INTEGER;
  l_descriptor_referenced PLS_INTEGER;
  l_stored_in_table VARCHAR2(30);
  l_stored_in_column VARCHAR2(30);
  l_draft_stored_in_table VARCHAR2(30);
  l_category_id NUMBER;
BEGIN
  l_err_loc := 100;

  -- first select stored in table and stored in column
  SELECT rt_category_id, stored_in_table, stored_in_column
  INTO l_category_id, l_stored_in_table, l_stored_in_column
  FROM icx_cat_attributes_tl
  WHERE attribute_id = p_descriptor_id
  AND rownum = 1;

  -- now assume that the descriptor is not referenced
  l_err_loc := 200;
  l_descriptor_referenced := 0;

  l_err_loc := 300;

  -- now check in the po transaction table
  BEGIN
    EXECUTE IMMEDIATE
    'SELECT 1 '||
    'FROM dual ' ||
    'WHERE EXISTS ( ' ||
           'SELECT 1 ' ||
           'FROM ' || l_stored_in_table ||
           ' WHERE ' || l_stored_in_table || '.' || l_stored_in_column || ' IS NOT NULL' ||
           ' AND ip_category_id = decode(' || l_category_id || ', 0, ip_category_id, ' || l_category_id || '))'
    INTO l_descriptor_referenced;

    l_err_loc := 350;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 300;

  -- now check in the po draft table
  IF (l_stored_in_table = 'PO_ATTRIBUTE_VALUES') THEN
    l_err_loc := 325;
    l_draft_stored_in_table := 'PO_ATTRIBUTE_VALUES_DRAFT';
  ELSE
    -- it is tlp
    l_err_loc := 350;
    l_draft_stored_in_table := 'PO_ATTRIBUTE_VALUES_TLP_DRAFT';
  END IF;

  l_err_loc := 400;

  BEGIN
    EXECUTE IMMEDIATE
    'SELECT 1 '||
    'FROM dual ' ||
    'WHERE EXISTS ( ' ||
           'SELECT 1 ' ||
           'FROM ' || l_draft_stored_in_table ||
           ' WHERE ' || l_draft_stored_in_table || '.' || l_stored_in_column || ' IS NOT NULL' ||
           ' AND ip_category_id = decode(' || l_category_id || ', 0, ip_category_id, ' || l_category_id || '))'
    INTO l_descriptor_referenced;

    l_err_loc := 450;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  -- now we check the sourcing tables
  l_err_loc := 500;

  BEGIN
    SELECT 1
    INTO l_descriptor_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_auction_attributes
                  WHERE ip_descriptor_id = p_descriptor_id
                  AND ip_category_id = l_category_id);

    l_err_loc := 550;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 600;

  BEGIN
    SELECT 1
    INTO l_descriptor_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_auc_attributes_interface
                  WHERE ip_descriptor_id = p_descriptor_id
                  AND ip_category_id = l_category_id);

    l_err_loc := 650;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 700;

  BEGIN
    SELECT 1
    INTO l_descriptor_referenced
    FROM dual
    WHERE EXISTS (SELECT 1
                  FROM pon_attributes_interface
                  WHERE ip_descriptor_id = p_descriptor_id
                  AND ip_category_id = l_category_id);

    l_err_loc := 750;

  EXCEPTION
  WHEN no_data_found THEN
    NULL;
  END;

  l_err_loc := 800;

  RETURN l_descriptor_referenced;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.can_descriptor_be_deleted(' ||
     l_err_loc || '), ' || SQLERRM);
END can_descriptor_be_deleted;


-- procedure to validate a descriptor
PROCEDURE validate_descriptor
(
  p_key IN VARCHAR2,
  p_name IN VARCHAR2,
  p_description IN VARCHAR2,
  p_type IN VARCHAR2,
  p_owner_key IN VARCHAR2,
  p_owner_name IN VARCHAR2,
  p_language IN VARCHAR2,
  p_sequence IN VARCHAR2,
  p_searchable IN VARCHAR2,
  p_search_results_visible IN VARCHAR2,
	p_item_detail_visible IN VARCHAR2,
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_user_action IN VARCHAR2,
  x_is_valid OUT NOCOPY VARCHAR2,
  x_system_action OUT NOCOPY VARCHAR2,
  x_descriptor_id OUT NOCOPY NUMBER,
  x_owner_id OUT NOCOPY NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_owner_id_from_name NUMBER;
  l_num_val NUMBER;
  l_current_type VARCHAR2(1);
  l_start_pos PLS_INTEGER;
  l_end_pos PLS_INTEGER;
  l_first_zero_pos PLS_INTEGER;
BEGIN

  l_err_loc := 100;

  x_is_valid := 'Y';

  -- first we check the owner key and name
  -- since we need to determine the owner first to know what the descriptor is

  IF (p_owner_key IS NULL AND p_owner_name IS NULL) THEN
    l_err_loc := 110;
    insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_OWNER_KEY_NAME_REQD',
      p_line_number);
    x_is_valid := 'N';
  ELSE

    l_err_loc := 120;

    -- check if owner key is provided
    IF (p_owner_key IS NOT NULL) THEN

      BEGIN
        l_err_loc := 130;

        SELECT rt_category_id
        INTO x_owner_id
        FROM icx_cat_categories_tl
        WHERE upper_key = UPPER(p_owner_key)
        AND language = p_language
        AND type IN (0,2);

      EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 140;
          insert_failed_message(p_request_id, 'ICX_CAT_OWNER_KEY',
            'ICX_CAT_INVALID_OWNER_KEY', p_line_number);
          x_is_valid := 'N';
      END;
    END IF;

    l_err_loc := 150;

    -- now check if owner name is provided
    IF (p_owner_name IS NOT NULL) THEN

      BEGIN

        l_err_loc := 160;

        SELECT rt_category_id
        INTO l_owner_id_from_name
        FROM icx_cat_categories_tl
        WHERE upper_category_name = UPPER(p_owner_name)
        AND language = p_language
        AND type IN (0,2);

      EXCEPTION
        WHEN no_data_found THEN
          insert_failed_message(p_request_id, 'ICX_CAT_OWNER_NAME',
            'ICX_CAT_INVALID_OWNER_NAME', p_line_number);
          x_is_valid := 'N';
      END;
    END IF;

    -- now if both were provided then we need to compare the categories they got
    IF (x_owner_id IS NOT NULL) THEN
      IF (l_owner_id_from_name IS NOT NULL AND x_owner_id <> l_owner_id_from_name) THEN
        l_err_loc := 420;
        insert_failed_message(p_request_id, 'ICX_CAT_OWNER_KEY',
          'ICX_CAT_OWNER_KEY_NAME_DIFF', p_line_number);
        x_is_valid := 'N';
      END IF;
    ELSE
      l_err_loc := 430;
      -- we set actual id to temp id
      x_owner_id := l_owner_id_from_name;
    END IF;

  END IF;

  l_err_loc := 440;
  -- now we check the key to see if it is provided
  -- key is required for both sync and delete
  IF (p_key IS NULL) THEN
    l_err_loc := 450;
    insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_DESCRIPTOR_KEY_REQD',
      p_line_number);
     x_is_valid := 'N';
  END IF;



  l_err_loc := 460;

  -- now we do rest of validations only if is valid so far
  -- i.e. we have a valid owner id and a non-null key
  -- also action has to be either SYNC or DELETE.. validated by DTD

  IF (x_is_valid = 'Y') THEN

    BEGIN

      l_err_loc := 460;

      -- we try to get the descriptor from the database
      -- for this key and category
      SELECT attribute_id, to_char(type)
      INTO x_descriptor_id, l_current_type
      FROM icx_cat_attributes_tl
      WHERE UPPER(key) = UPPER(p_key)
      AND language = p_language
      AND rt_category_id = x_owner_id
      AND rownum = 1;

      l_err_loc := 470;

      -- we found the key, set system action to ADD if it was SYNC
      -- DELETE is fine .. we found the row
      IF (p_user_action = 'SYNC') THEN
        l_err_loc := 480;
        x_system_action := 'UPDATE';
      ELSIF (p_user_action = 'DELETE') THEN
        l_err_loc := 490;
        x_system_action := 'DELETE';
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        l_err_loc := 500;
        -- we did not find the key for this category
        -- so for SYNC we set system action to ADD
        -- for delete, we did not get the row, so error
        IF (p_user_action = 'SYNC') THEN
          l_err_loc := 510;
          x_system_action := 'ADD';
        ELSIF (p_user_action = 'DELETE') THEN
          l_err_loc := 210;
          x_system_action := 'DELETE';
          insert_failed_message(p_request_id,'ICX_CAT_KEY','ICX_CAT_DESC_DOES_NOT_EXIST',
            p_line_number);
          x_is_valid := 'N';
        END IF;
    END;

    l_err_loc := 530;
  END IF;

  l_err_loc := 540;
  -- now we have got system action, so we validate based on system action

  IF (x_is_valid = 'Y') THEN
    l_err_loc := 550;
    IF (x_system_action = 'ADD') THEN
      -- first we need to make sure this key does not exist elsewhere
      -- if we are trying to create a root descriptor then it should not
      -- exist in any category else it should not exist in current category
      -- and root
      l_err_loc := 551;
      BEGIN
        IF (x_owner_id = 0) THEN
          l_err_loc := 552;
          SELECT 1
          INTO l_num_val
          FROM DUAL
          WHERE EXISTS (SELECT 1
                        FROM icx_cat_attributes_tl
                        WHERE UPPER(key) = UPPER(p_key)
                        AND language = p_language);
        ELSE
          l_err_loc := 553;
          SELECT 1
          INTO l_num_val
          FROM DUAL
          WHERE EXISTS (SELECT 1
                        FROM icx_cat_attributes_tl
                        WHERE UPPER(key) = UPPER(p_key)
                        AND language = p_language
                        AND (rt_category_id = x_owner_id OR
                             rt_category_id = 0));
        END IF;

        -- found a descriptor,  error error out
         l_err_loc := 555;
        insert_failed_message(p_request_id,'ICX_CAT_KEY','ICX_CAT_DESC_KEY_NONUNIQUE',
          p_line_number);
        x_is_valid := 'N';
      EXCEPTION
        WHEN no_data_found THEN
          l_err_loc := 555;
          null;
      END;


      l_err_loc := 559;
      -- for add Name is required
      IF (p_name IS NULL) THEN
        l_err_loc := 560;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_DESCRIPTOR_NAME_REQD',
          p_line_number);
        x_is_valid := 'N';
      ELSE
        l_err_loc := 570;

        BEGIN

          -- now we check for uniqueness of name
          -- if we are trying to add a root descriptor then name has to be unique
          -- across all categories
          -- else it just has to be unique in that category and root category
          IF (x_owner_id = 0) THEN
            l_err_loc := 580;
            -- for base descriptor
            SELECT 1
            INTO l_num_val
            FROM DUAL
            WHERE EXISTS (SELECT 1
                          FROM icx_cat_attributes_tl
                          WHERE UPPER(attribute_name) = UPPER(p_name)
                          AND language = p_language);
          ELSE
             l_err_loc := 590;
            -- for category descriptor
            SELECT 1
            INTO l_num_val
            FROM DUAL
            WHERE EXISTS (SELECT 1
                          FROM icx_cat_attributes_tl
                          WHERE UPPER(attribute_name) = UPPER(p_name)
                          AND language = p_language
                          AND (rt_category_id = x_owner_id OR
                               rt_category_id = 0));
          END IF;

          l_err_loc := 600;
          -- if it found a name then error
          insert_failed_message(p_request_id,'ICX_CAT_NAME','ICX_CAT_DES_NAME_NONUNIQUE_ADD',
            p_line_number);
          x_is_valid := 'N';

        EXCEPTION
          WHEN no_data_found THEN
            -- we are fine
            l_err_loc := 610;
            null;
        END;

        l_err_loc := 620;
        -- now we check to see if the max number of descriptors has been reached
        -- for this type
        -- for base this is 100(other than the seeded attributes), for category 50

        IF (x_owner_id = 0) THEN
          -- for base
          l_err_loc := 630;
          SELECT COUNT(*)
          INTO l_num_val
          FROM icx_cat_attributes_tl
          WHERE rt_category_id = 0
          AND language = p_language
          AND to_char(type) = p_type
          AND attribute_id > 100;

          l_err_loc := 640;

          -- make sure the section_map is fine for creating a new base descriptor
          IF p_type = 0 THEN
            l_start_pos := 1;
            l_end_pos := 100;
          ELSIF p_type = 1 THEN
            l_start_pos := 101;
            l_end_pos := 200;
          ELSIF p_type = 2 THEN
            l_start_pos := 201;
            l_end_pos := 300;
          END IF;

          l_err_loc := 645;

          SELECT instr(section_map, '0', l_start_pos, 1)
          INTO l_first_zero_pos
          FROM icx_cat_categories_tl
          WHERE rt_category_id = 0
          AND language = p_language;

          l_err_loc := 650;

          IF (l_num_val >= 100 OR l_first_zero_pos > l_end_pos) THEN
            l_err_loc := 655;
            insert_failed_message(p_request_id,'ICX_CAT_KEY','ICX_CAT_BASE_ATT_NUM_EXCEED',
              p_line_number);
            x_is_valid := 'N';
          END IF;
        ELSE
          -- for category
          l_err_loc := 660;
          SELECT COUNT(*)
          INTO l_num_val
          FROM icx_cat_attributes_tl
          WHERE rt_category_id = x_owner_id
          AND language = p_language
          AND to_char(type) = p_type;

          l_err_loc := 670;

          -- make sure the section_map is fine for creating a new category descriptor
          IF p_type = 0 THEN
            l_start_pos := 1;
            l_end_pos := 50;
          ELSIF p_type = 1 THEN
            l_start_pos := 101;
            l_end_pos := 150;
          ELSIF p_type = 2 THEN
            l_start_pos := 201;
            l_end_pos := 250;
          END IF;

          l_err_loc := 672;

          SELECT instr(section_map, '0', l_start_pos, 1)
          INTO l_first_zero_pos
          FROM icx_cat_categories_tl
          WHERE rt_category_id = x_owner_id
          AND language = p_language;

          l_err_loc := 675;

          IF (l_num_val >= 50 OR l_first_zero_pos > l_end_pos) THEN
            l_err_loc := 680;
            insert_failed_message(p_request_id,'ICX_CAT_KEY','ICX_CAT_CAT_ATT_NUM_EXCEED',
              p_line_number);
            x_is_valid := 'N';
          END IF;

        END IF; -- end IF (x_owner_id...

      END IF; -- IF (p_name...

    ELSIF (x_system_action = 'UPDATE') THEN

      l_err_loc := 690;

        BEGIN

          -- for update we check for uniqueness of name similar to add
          -- if we are trying to add a root descriptor then name has to be unique
          -- across all categories
          -- else it just has to be unique in that category and root category
          -- in addition we only check other descriptors than the one we are updating
          -- since we can update a descriptor to a same name
          IF (x_owner_id = 0) THEN
            l_err_loc := 700;
            -- for base descriptor
            SELECT 1
            INTO l_num_val
            FROM dual
            WHERE EXISTS (SELECT 1
                          FROM icx_cat_attributes_tl
                          WHERE UPPER(attribute_name) = UPPER(p_name)
                          AND attribute_id <> x_descriptor_id);
          ELSE
             l_err_loc := 710;
            -- for category descriptor
            SELECT 1
            INTO l_num_val
            FROM dual
            WHERE EXISTS (SELECT 1
                          FROM icx_cat_attributes_tl
                          WHERE UPPER(attribute_name) = UPPER(p_name)
                          AND (rt_category_id = x_owner_id OR
                              rt_category_id = 0)
                          AND attribute_id <> x_descriptor_id);
          END IF;

          l_err_loc := 720;
          -- if it found a name then error
          insert_failed_message(p_request_id,'ICX_CAT_NAME','ICX_CAT_DES_NAME_NONUNIQUE_UPD',
            p_line_number);
          x_is_valid := 'N';

        EXCEPTION
          WHEN no_data_found THEN
            -- we are fine
            l_err_loc := 730;
            null;
        END;

        l_err_loc := 740;

        -- now we validate that the type cannot be updated
        IF (p_type IS NOT NULL AND p_type <> l_current_type) THEN
          -- Cannot update type
          l_err_loc := 750;
          insert_failed_message(p_request_id, 'ICX_CAT_TYPE', 'ICX_CAT_CANNOT_CHANGE_DES_TYPE',
            p_line_number);
          x_is_valid := 'N';
        END IF;

        l_err_loc := 752;

        -- now certain properties i.e. sequence, Searchable, SRV, IDV
        -- cannot be updated for certain seeded base attributes
        -- we validate those now

        IF (upper(p_key) IN ('THUMBNAIL_IMAGE', 'PICTURE', 'UOM',  'CURRENCY',
                             'FUNCTIONAL_CURRENCY', 'LONG_DESCRIPTION') AND
            p_sequence is not null) THEN

          l_err_loc := 753;
          -- cannot change sequence for these
          -- we say if user provided a sequence, we error
          insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CANNOT_CHANGE_SEQUENCE',
            p_line_number);
          x_is_valid := 'N';

        END IF;

        l_err_loc := 754;

        IF (upper(p_key)IN ('PURCHASING_CATEGORY', 'THUMBNAIL_IMAGE', 'SUPPLIER', 'SUPPLIER_SITE',
                            'PICTURE', 'UOM', 'PRICE', 'CURRENCY', 'FUNCTIONAL_PRICE',
                            'FUNCTIONAL_CURRENCY', 'ATTACHMENT_URL', 'SUPPLIER_URL',
                            'MANUFACTURER_URL') AND
            p_searchable = '1') THEN

          l_err_loc := 755;
          -- cannot change searchable for these
          -- and default is 0 so we just check for 1
          insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CANNOT_CHANGE_SRCHABLE',
            p_line_number);
          x_is_valid := 'N';

        END IF;

         l_err_loc := 757;

        IF (upper(p_key) = 'PICTURE' AND
            p_search_results_visible = '1') THEN

          l_err_loc := 760;
          -- cannot make PICTURE SRV
          insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CANNOT_CHANGE_SRV',
            p_line_number);
          x_is_valid := 'N';

        END IF;

        l_err_loc := 762;

    ELSIF (x_system_action = 'DELETE') THEN

      l_err_loc := 770;
      -- for delete we first check to see that the seeded base descriptors
      -- cannot be deleted
      IF(x_descriptor_id <= g_NUM_SEEDED_DESCRIPTORS) THEN
        l_err_loc := 780;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_CANNOT_DEL_SEEDED_DESC',
          p_line_number);
        x_is_valid := 'N';
      END IF;

      l_err_loc := 790;

      -- now we check to see if descriptor can be deleted
      -- descriptor can be deleted if there are no items referencing it
      IF (can_descriptor_be_deleted(x_descriptor_id) = 1) THEN
        l_err_loc := 800;
        insert_failed_message(p_request_id, 'ICX_CAT_KEY', 'ICX_CAT_DESC_HAS_ITEMS',
          p_line_number);
        x_is_valid := 'N';
      END IF;

    END IF; -- IF  (p_system_action...  no other actions possible

  END IF; -- IF (p

EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.validate_descriptor(' ||
     l_err_loc || '), ' || SQLERRM);
END validate_descriptor;


-- procedure to delete old jobs from the tables
-- (icx_por_batch_jobs, icx_cat_batch_jobs, icx_por_failed_line_messages,
--  icx_por_failed_lines, icx_por_contract_references, icx_cat_parse_errors)
PROCEDURE purge_loader_tables
IS
  l_err_loc PLS_INTEGER;
  l_number_of_days NUMBER;
  l_commit_size NUMBER;
  l_job_number_tbl DBMS_SQL.NUMBER_TABLE;
  l_continue BOOLEAN := TRUE;
BEGIN

  l_err_loc := 100;

  -- get the POR_LOAD_PURGE_BEYOND_DAYS and POR_LOAD_PURGE_COMMIT_SIZE profiles
  fnd_profile.get('POR_LOAD_PURGE_BEYOND_DAYS', l_number_of_days);
  fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', l_commit_size);

  l_err_loc := 110;

  -- this loop is to used to purge tables for pre R12 jobs
  WHILE l_continue LOOP

    l_err_loc := 120;

    DELETE FROM icx_por_batch_jobs
    WHERE submission_datetime <= (sysdate - l_number_of_days)
    AND rownum <= l_commit_size
    RETURNING job_number BULK COLLECT INTO l_job_number_tbl;

    l_err_loc := 130;

    IF (SQL%ROWCOUNT < l_commit_size) THEN
      l_err_loc := 140;
      l_continue := FALSE;
    END IF;

    l_err_loc := 150;

    FORALL i IN 1..l_job_number_tbl.COUNT
      DELETE FROM icx_por_failed_line_messages
      WHERE job_number = l_job_number_tbl(i);

    l_err_loc := 160;

    FORALL i IN 1..l_job_number_tbl.COUNT
      DELETE FROM icx_por_failed_lines
      WHERE job_number = l_job_number_tbl(i);

    l_err_loc := 170;

    FORALL i IN 1..l_job_number_tbl.COUNT
      DELETE FROM icx_por_contract_references
      WHERE job_number = l_job_number_tbl(i);

    l_err_loc := 180;

    COMMIT;
  END LOOP;

  l_err_loc := 200;

  l_continue := TRUE;
  l_job_number_tbl.DELETE;

  -- this loop is to used to purge tables for R12 jobs
  WHILE l_continue LOOP

    l_err_loc := 210;

    DELETE FROM icx_cat_batch_jobs
    WHERE submission_datetime <= (sysdate - l_number_of_days)
    AND rownum <= l_commit_size
    RETURNING job_number BULK COLLECT INTO l_job_number_tbl;

    l_err_loc := 220;

    IF (SQL%ROWCOUNT < l_commit_size) THEN
      l_err_loc := 230;
      l_continue := FALSE;
    END IF;

    l_err_loc := 240;

    FORALL i IN 1..l_job_number_tbl.COUNT
      DELETE FROM icx_por_failed_line_messages
      WHERE job_number = l_job_number_tbl(i);

    l_err_loc := 250;

    FORALL i IN 1..l_job_number_tbl.COUNT
      DELETE FROM icx_por_failed_lines
      WHERE job_number = l_job_number_tbl(i);

    l_err_loc := 260;

    FORALL i IN 1..l_job_number_tbl.COUNT
      DELETE FROM icx_cat_parse_errors
      WHERE request_id = l_job_number_tbl(i);

    l_err_loc := 270;

    COMMIT;
  END LOOP;

  l_err_loc := 280;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.purge_loader_tables(' ||
     l_err_loc || '), ' || SQLERRM);
END purge_loader_tables;

-- procedure to populate the ctx desc for schema load
-- this will handle the following cases
-- 1. category name change
-- 2. Change of descriptor searchability
PROCEDURE populate_ctx_desc
(
  p_request_id IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;

  l_category_id NUMBER;
  l_descriptor_key VARCHAR2(250);
  l_searchable NUMBER;

  -- cursor to handle category name change
  CURSOR populate_category_csr
  IS
    SELECT rt_category_id, category_name, language
    FROM icx_cat_categories_tl
    WHERE request_id = p_request_id
    AND rebuild_flag = 'Y';

  -- cursor to handle special descriptor update
  CURSOR populate_special_descs_csr
  IS
    SELECT key, searchable
    FROM icx_cat_attributes_tl
    WHERE request_id = p_request_id
    AND rebuild_flag = 'Y'
    AND rt_category_id = 0
    AND key IN ('SUPPLIER_PART_NUM', 'SUPPLIER_PART_AUXID', 'SUPPLIER',
                'INTERNAL_ITEM_NUM', 'SOURCE', 'ITEM_REVISION',
                'SHOPPING_CATEGORY');

  -- cursor that handles the descriptor update for regular (non-special) descriptors
  CURSOR populate_regular_descs_csr
  IS
    SELECT distinct rt_category_id
    FROM icx_cat_attributes_tl
    WHERE request_id = p_request_id
    AND rebuild_flag = 'Y'
    AND key NOT IN ('SUPPLIER_PART_NUM', 'SUPPLIER_PART_AUXID', 'SUPPLIER',
                    'INTERNAL_ITEM_NUM', 'SOURCE', 'ITEM_REVISION',
                    'SHOPPING_CATEGORY');
BEGIN

  l_err_loc := 100;

  -- set the batch size
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 103;

  -- set commit to true
  ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);

  l_err_loc := 105;


  -- first we get all the categories whose name has changed
  -- and call populate for those
  FOR category_row IN populate_category_csr LOOP

    l_err_loc := 110;

    ICX_CAT_POPULATE_CTXSTRING_PVT.handleCategoryRename(category_row.rt_category_id,
      category_row.category_name, category_row.language);

  END LOOP;

  -- now we get all the special descriptors that have their searchable property changed
  l_err_loc := 200;

  FOR special_descriptor_row IN populate_special_descs_csr LOOP

    l_err_loc := 210;

    -- for special descriptors we have individual rows so we call it one
    -- descriptor at a time

    ICX_CAT_POPULATE_CTXSTRING_PVT.rePopulateBaseAttributes(special_descriptor_row.key,
      special_descriptor_row.searchable);

  END LOOP;

   -- now we get all thed distinct categories for which
   -- non-special descriptors have been updated
  l_err_loc := 300;

  FOR descriptor_cat_row IN populate_regular_descs_csr LOOP

    l_err_loc := 310;

    -- now get the category id
    l_category_id := descriptor_cat_row.rt_category_id;

    l_err_loc := 320;

    IF (l_category_id = 0) THEN
      -- handle update of non-special root descriptors
      -- since these are not special we will just call it once for root category
      -- and pass nulls as the parameters

      l_err_loc := 330;

      ICX_CAT_POPULATE_CTXSTRING_PVT.rePopulateBaseAttributes(null, null);

    ELSE
      -- handle update of category descriptors for this category
      -- this is called one category at a time

      l_err_loc := 340;

      ICX_CAT_POPULATE_CTXSTRING_PVT.rePopulateCategoryAttributes(l_category_id);

    END IF;

  END LOOP;

  l_err_loc := 400;

  -- finally we rebuild the index
  ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

  l_err_loc := 500;

  -- reset rebuild flag to null
  UPDATE icx_cat_categories_tl
  SET rebuild_flag = null
  WHERE rebuild_flag is not null;

  l_err_loc := 600;

  -- reset rebuild flag to null
  UPDATE icx_cat_attributes_tl
  SET rebuild_flag = null
  WHERE rebuild_flag is not null;

  l_err_loc := 700;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.populate_ctx_desc(' ||
     l_err_loc || '), ' || SQLERRM);
END populate_ctx_desc;

-- methods for online schema
-- submitted through concurrent programs

-- method to populate the ctx desc for category rename
PROCEDURE populate_for_cat_rename
(
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY NUMBER,
  p_category_id IN NUMBER,
  p_category_name IN VARCHAR2,
  p_language IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
  l_request_id NUMBER;

BEGIN

  l_err_loc := 100;

  -- get the concurrent request ID
  l_request_id := fnd_global.conc_request_id;

  l_err_loc := 150;

  update_job_status(l_request_id, 'RUNNING');

  l_err_loc := 200;

  ICX_CAT_POPULATE_CTXSTRING_PVT.handleCategoryRename(p_category_id,
    p_category_name, p_language);

  l_err_loc := 300;

  update_job_status(l_request_id, 'COMPLETED');

  l_err_loc := 400;

  x_retcode := 0;
  x_errbuf := '';

  l_err_loc := 500;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  x_retcode := 2;
  x_errbuf := 'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.populate_for_cat_rename(' ||
     l_err_loc || '), ' || SQLERRM;
  update_job_status(l_request_id, 'ERROR');
END populate_for_cat_rename;

-- method to populate the ctx_desc for a searchability change
PROCEDURE populate_for_searchable_change
(
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY NUMBER,
  p_attribute_id IN NUMBER,
  p_attribute_key IN VARCHAR2,
  p_category_id IN NUMBER,
  p_searchable IN NUMBER
)
IS
  l_err_loc PLS_INTEGER;
  l_request_id NUMBER;

BEGIN

  l_err_loc := 100;

  -- get the concurrent request ID
  l_request_id := fnd_global.conc_request_id;

  l_err_loc := 150;

  update_job_status(l_request_id, 'RUNNING');

  l_err_loc := 200;

  ICX_CAT_POPULATE_CTXSTRING_PVT.handleSearchableFlagChange(p_attribute_id,
    p_attribute_key, p_category_id, p_searchable);

  l_err_loc := 300;

  update_job_status(l_request_id, 'COMPLETED');

  l_err_loc := 400;

  x_retcode := 0;
  x_errbuf := '';

  l_err_loc := 500;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  x_retcode := 2;
  x_errbuf := 'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.populate_for_searchable_change(' ||
     l_err_loc || '), ' || SQLERRM;
  update_job_status(l_request_id, 'ERROR');

END populate_for_searchable_change;

-- method to update the status of a job
PROCEDURE update_job_status
(
  p_job_number IN NUMBER,
  p_job_status IN VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;

BEGIN

  l_err_loc := 100;

  UPDATE icx_cat_batch_jobs
  SET job_status = p_job_status,
      last_updated_by = fnd_global.user_id,
      last_update_date = sysdate,
      last_update_login = fnd_global.login_id
  WHERE job_number = p_job_number;

  l_err_loc := 200;

  COMMIT;

  l_err_loc := 300;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_SCHEMA_UPLOAD_PVT.update_job_status(' ||
     l_err_loc || '), ' || SQLERRM);
END update_job_status;

END ICX_CAT_SCHEMA_UPLOAD_PVT;

/
