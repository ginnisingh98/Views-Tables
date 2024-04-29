--------------------------------------------------------
--  DDL for Package Body CS_QKMENU_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_QKMENU_DML_PKG" AS
/* $Header: csqkmenb.pls 115.7 2002/12/17 05:10:25 bhroy ship $ */
-- 12-17-2002	bhroy 	Removed default NULL, added WHENEVER OSERROR EXIT FAILURE ROLLBACK

  PROCEDURE SAVE_FOLDER_INTO_DB(l_user_id         IN  NUMBER,
	  		                 l_description     IN  VARCHAR2,
                                l_folder_name     IN  VARCHAR2, /*save as name*/
			                 l_default_flag    IN  VARCHAR2)
						  IS

    record_exist              NUMBER := 0;
    next_sequence             NUMBER := 0;
    current_view_folder_val   VARCHAR2(30);
    col_value                 VARCHAR2(30);

    CURSOR function_rec IS
      SELECT function_id, filter_id, function_filter_id
      FROM   cs_qm_function_filters
      WHERE  active_flag = 'Y';



  BEGIN


     -- find out if the folder exists, if so, update it, if not, insert it
     SELECT NVL(COUNT(*), 0)
     INTO record_exist
     FROM cs_qm_user_folders
     WHERE folder_name = l_folder_name
	AND user_id = l_user_id;

     SELECT CS_QM_USER_FOLDERS_S.NextVal
     INTO next_sequence
     FROM dual;

     IF (record_exist > 0) THEN
        UPDATE cs_qm_user_folders
  	   SET description = l_description
	   WHERE folder_name = l_folder_name
	   AND user_id = l_user_id;
        COMMIT;
     ELSE
   	   INSERT INTO cs_qm_user_folders
	       (user_folder_id, last_update_date, last_updated_by, creation_date,
		   created_by,  user_id, folder_name, description, default_flag,
	        active_flag, object_version_number)
	   VALUES
	       (next_sequence, sysdate, l_user_id, sysdate, l_user_id,
	        l_user_id, l_folder_name,
		   l_description, 'N', 'Y', 1);
        COMMIT;
     END IF;


    -- find out if the checkbox is checked, if not, do nothing, if so
    -- clean up the older default_flag and set the new default_flag
    IF (l_default_flag = 'N') THEN
   	  RETURN;
    ELSE
       UPDATE cs_qm_user_folders
  	  SET default_flag = 'N'
	  WHERE default_flag = 'Y';
	  COMMIT;

       IF (record_exist > 0) THEN
	     UPDATE cs_qm_user_folders
	     SET default_flag = 'Y'
	     WHERE folder_name = l_folder_name
		AND user_id = l_user_id;
	     COMMIT;
       ELSE
          UPDATE cs_qm_user_folders
	     SET default_flag = 'Y'
	     WHERE user_folder_id = next_sequence
		AND user_id = l_user_id;
	     COMMIT;
       END IF;

    END IF;

  END SAVE_FOLDER_INTO_DB;

  PROCEDURE insert_holder(l_user_folder_id        NUMBER,
			  l_function_filter_id    NUMBER,
			  l_user_id               NUMBER,
                          l_filter_value          VARCHAR2,
                          l_filter_value_id       NUMBER)
 IS

  BEGIN

    INSERT INTO cs_qm_folder_filters
	  (folder_filter_id, user_folder_id, function_filter_id,
           filter_operator, filter_value, filter_value_id,
 	   last_update_date, last_updated_by, last_update_login,
	   creation_date, created_by, object_version_number)
    VALUES
       (cs_qm_folder_filters_s.nextVal, l_user_folder_id, l_function_filter_id,
        '=', l_filter_value, l_filter_value_id,
	   sysdate, l_user_id, l_user_id, sysdate, l_user_id, 1);
    COMMIT;

  END insert_holder;


  PROCEDURE update_holder(l_user_folder_id        NUMBER,
			           l_function_filter_id    NUMBER,
			           l_user_id               NUMBER,
                          l_filter_value          VARCHAR2,
                          l_filter_value_id       NUMBER
                          )
IS

  BEGIN

    UPDATE cs_qm_folder_filters
    SET filter_value = l_filter_value,
        filter_value_id = l_filter_value_id
    WHERE user_folder_id = l_user_folder_id
    AND   function_filter_id = l_function_filter_id;
    COMMIT;

  END update_holder;


  PROCEDURE insert_empty_folder(l_user_id       NUMBER,
						  l_folder_name   VARCHAR2) IS

    l_user_folder_id      NUMBER;

    CURSOR filter_rec IS
	 SELECT function_filter_id
	 FROM   cs_qm_function_filters;


  BEGIN

    SELECT user_folder_id
    INTO   l_user_folder_id
    FROM   cs_qm_user_folders
    WHERE  user_id = l_user_id
    AND    folder_name = l_folder_name;

    FOR filter_item in filter_rec LOOP

        INSERT INTO cs_qm_folder_filters
         (folder_filter_id, user_folder_id, function_filter_id, filter_operator,
   	     filter_value,
	     last_update_date, last_updated_by, last_update_login,
		creation_date, created_by, object_version_number)
        VALUES
	    (cs_qm_folder_filters_s.nextVal, l_user_folder_id,
		filter_item.function_filter_id, '=', '',
		sysdate, l_user_id, l_user_id, sysdate, l_user_id, 1);
        COMMIT;

    END LOOP;


  END insert_empty_folder;


  PROCEDURE new_folder(l_user_id      NUMBER,
				   folder_name    VARCHAR2,
				   description    VARCHAR2) IS

     next_sequence     NUMBER;

  BEGIN

     SELECT CS_QM_USER_FOLDERS_s.NextVal
     INTO next_sequence
     FROM dual;

     INSERT INTO cs_qm_user_folders
              (user_folder_id, last_update_date, last_updated_by, creation_date,
	  	     created_by,  user_id, folder_name, description, default_flag,
	          active_flag, object_version_number)
	VALUES
	         (next_sequence, sysdate, l_user_id, sysdate, l_user_id,
	          l_user_id, folder_name,
	   	     description, 'N', 'Y', 1);
     COMMIT;
  END new_folder;

  PROCEDURE update_default_flag(l_user_id      NUMBER,
                                l_folder_name    VARCHAR2,
						  l_default_flag VARCHAR2) IS

    record_exist         NUMBER;

  BEGIN

    IF (l_default_flag = 'N') THEN
   	  RETURN;
    ELSE
       UPDATE cs_qm_user_folders
  	  SET default_flag = 'N'
	  WHERE default_flag = 'Y'
	  AND user_id = l_user_id;
	  COMMIT;

       UPDATE cs_qm_user_folders
       SET default_flag = 'Y'
       WHERE folder_name = l_folder_name
	  AND user_id = l_user_id;
       COMMIT;
    END IF;


  END update_default_flag;





END CS_QKMENU_DML_PKG;

/
