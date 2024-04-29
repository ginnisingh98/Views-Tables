--------------------------------------------------------
--  DDL for Package Body GMD_LAB_ORGN_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LAB_ORGN_MIGRATION" AS
/* $Header: GMDLOMGB.pls 120.1 2005/09/29 11:19:40 srsriran noship $  pxkumar*/

 PROCEDURE INSERT_LAB_ORGN IS

  error_msg		VARCHAR2(240);

  CURSOR Cur_get_text(ptext_code NUMBER) IS
    SELECT * FROM lm_text_tbl
    WHERE text_code = ptext_code;

    l_count      NUMBER;
    l_row_id     VARCHAR2(80);
    l_temp_rec   Cur_get_text%ROWTYPE;
    l_text_code  NUMBER DEFAULT NULL;

  BEGIN

    FOR cur_lab_tmp IN (SELECT * FROM lm_ltyp_mst l
						where not exists (	select 1 from sy_orgn_mst
											where orgn_code = l.lab_type)) LOOP
    Begin

        /* Get the text code */
        IF (Cur_lab_tmp.text_code IS NOT NULL) THEN
          SELECT Gem5_text_code_s.nextval INTO l_text_code FROM sys.dual;

          OPEN Cur_get_text(Cur_lab_tmp.text_code);
          	LOOP
          		FETCH Cur_get_text INTO l_temp_rec;
          		EXIT WHEN Cur_get_text%NOTFOUND;

          		gma_sy_text_tbl_pkg.insert_row(x_rowid       => l_row_id,
                                         x_text_code         => l_text_code,
                                         x_paragraph_code    => l_temp_rec.paragraph_code,
                                         x_sub_paracode      => l_temp_rec.sub_paracode,
                                         x_line_no           => l_temp_rec.line_no,
                                         x_lang_code         => l_temp_rec.lang_code,
                                         x_text              => l_temp_rec.text,
                                         x_creation_date     => l_temp_rec.creation_date,
                                         x_created_by        => l_temp_rec.created_by,
                                         x_last_update_date  => l_temp_rec.last_update_date,
                                         x_last_updated_by   => l_temp_rec.last_updated_by,
                                         x_last_update_login => l_temp_rec.last_update_login);
           	END LOOP;/* for cur_get_text */
           CLOSE Cur_get_text;
        ELSE
          l_text_code := NULL;
        END IF; /* End of get text code logic */

        INSERT INTO sy_orgn_mst (orgn_code,
                                 parent_orgn_code,
                                 co_code,
                                 orgn_name,
                                 plant_ind,
                                 poc_ind,
                                 text_code,
                                 delete_mark,
                                 trans_cnt,
                                 creation_date,
                                 last_update_date,
                                 created_by,
                                 last_updated_by,
                                 last_update_login)
                           VALUES(Cur_lab_tmp.lab_type,
                                  Cur_lab_tmp.lab_type,
                                  Cur_lab_tmp.lab_type,
                                  Cur_lab_tmp.lab_description,
                                  2,
                                  0,
                                  l_text_code,
                                  decode(Cur_lab_tmp.active_ind,1,0,1),
                                  Cur_lab_tmp.trans_cnt,
                                  Cur_lab_tmp.creation_date,
                                  Cur_lab_tmp.last_update_date,
                                  Cur_lab_tmp.created_by,
                                  Cur_lab_tmp.last_updated_by,
                                  Cur_lab_tmp.last_update_login);

      EXCEPTION
  		WHEN OTHERS THEN
  			error_msg := SQLERRM;
  			INSERT INTO GMD_MIGRATION (	migration_id,
		    						source_table,
		    						target_table,
		    						source_id 	,
		    						target_id 	,
		    						message_text )
		    				SELECT 	GMD_REQUEST_ID_S.nextval,
		    						'LM_LTYP_MST',
		    						'SY_ORGN_MST',
		    						Cur_lab_tmp.lab_type,
		    						Cur_lab_tmp.lab_type,
		    						error_msg
		    				FROM 	DUAL	;
	 End;

  	END LOOP;

  END INSERT_LAB_ORGN;

END GMD_LAB_ORGN_MIGRATION;

/
