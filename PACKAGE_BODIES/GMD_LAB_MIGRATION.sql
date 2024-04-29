--------------------------------------------------------
--  DDL for Package Body GMD_LAB_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_LAB_MIGRATION" AS
/* $Header: GMDLMIGB.pls 120.1 2005/08/12 09:41:13 txdaniel noship $  pxkumar*/

  PROCEDURE INSERT_LAB_FORMULA IS

     error_msg  VARCHAR2(240);

    /*Cursor to get all the formula which have no tpformula_id attached*/

    CURSOR Cur_non_tp_formula IS
      SELECT *
      FROM   lm_form_mst
      WHERE  exists (SELECT distinct d.formula_id
                     FROM   lm_form_dtl d
                     WHERE  NVL(d.tpformula_id, 0) = 0
                     AND    d.formula_id = formula_id)
      order by formula_no, formula_vers;
    /*Cursor to get all the formula which have tpformula_id attached*/

    CURSOR Cur_tp_formula IS
      SELECT *
      FROM   lm_form_mst
      WHERE  formula_id IN (SELECT distinct d.formula_id
                            FROM   lm_form_dtl d
                            WHERE  NVL(d.tpformula_id, 0) > 0
                            AND    d.formula_id = formula_id)
      order by formula_no, formula_vers;

    /*Cursor to check whether a formula with same no and version exists,
    if so then get the max version of the formula*/

    CURSOR Cur_check_formula_exists (V_formula_no VARCHAR2, V_formula_vers NUMBER) IS
      SELECT formula_vers , formula_status
      FROM   fm_form_mst
      WHERE  formula_no = V_formula_no
      AND    formula_vers = V_formula_vers ;


      CURSOR Cur_formula_trans_exists (V_formula_id NUMBER) IS
        select count(*)
         FROM  gmd_lab_formula_assoc
         WHERE old_formula_id = v_formula_id;

    CURSOR Cur_get_max_vers(V_formula_no VARCHAR2) IS
      SELECT max(formula_vers)
      FROM   fm_form_mst
      WHERE  formula_no = V_formula_no;


  /*Cursor to get the formula_id of the formula with tpformula_id > 0*/

    CURSOR Cur_get_tp_id (V_formula_id NUMBER) IS
      SELECT formula_id
      FROM   fm_form_mst
      WHERE  (formula_no, formula_vers)
      IN     (SELECT formula_no, formula_vers
              FROM   lm_form_mst
              WHERE  formula_id = V_formula_id);

  /*Cursor to create sequence of the formula_id*/

   CURSOR fm_formula_id  is
     select  gem5_formula_id_s.nextval from sys.dual;

   /*Cursor to get all formula details for a given formula_id */

       CURSOR lab_detail (Vformula_id IN NUMBER) is
        select * from lm_form_dtl
        where formula_id = Vformula_id ;

   /*Cursor to create sequence of the formulaline_id */

       CURSOR fm_formulaline_id  is

       select  gem5_formulaline_id_s.nextval from sys.dual;

/* local parameters*/
       Xformula_id  number;
       Xformulaline_id  number;
       X_formula_vers	NUMBER;
       X_tp_formula_id  NUMBER;
       l_orgn_code	VARCHAR2(4);
       X_FLAG           VARCHAR2(32) := 'FALSE' ;
       X_FORMULA_STATUS VARCHAR2(32) ;
       lab_rec  Cur_non_tp_formula%ROWTYPE;
       lab_detail_rec lab_detail%ROWTYPE;
       l_count NUMBER DEFAULT 0;
       X_STATUS         VARCHAR2(30); -- Bug 3217071
    Begin
    /*get all the formula with no tpformula_id */

      FOR lab_rec IN Cur_non_tp_formula LOOP
      BEGIN
        SAVEPOINT header;

        /* Step 1 : To migrate data ino the lab formula Header table  */

        OPEN fm_formula_id ;
        fetch fm_formula_id into Xformula_id ;
        close fm_formula_id;


         /* Step 2 : To check for those formula no and version which
                         exists in the formula Header table. If a formula with same
                         formula no and version exists in the formula header table,
                         increase the version of formula to be inserted. */
        X_flag := 'FALSE' ;

          OPEN Cur_check_formula_exists (lab_rec.formula_no, lab_rec.formula_vers);
          FETCH Cur_check_formula_exists INTO X_formula_vers, x_formula_status;
          IF Cur_check_formula_exists%FOUND THEN
           /* Commented this portion of the code */
           /* When same lab exists in the formula table we suffix the lab name */
           /* with _LAB after the formula_no */
            OPEN Cur_formula_trans_exists(lab_rec.formula_id);
            FETCH Cur_formula_trans_exists INTO l_count;
            CLOSE Cur_formula_trans_exists;
            IF (l_count = 0) THEN
              lab_rec.formula_no := lab_rec.formula_no||'_LAB';
              X_formula_vers := lab_rec.formula_vers;
              X_FLAG := 'TRUE';
            END IF;
          ELSE
              X_formula_vers := lab_rec.formula_vers;
              X_FLAG := 'TRUE' ;
          END IF ;
         CLOSE Cur_check_formula_exists;


          IF   X_FLAG = 'TRUE'  THEN


        select fnd_profile.value_specific('GEMMS_DEFAULT_ORGN',lab_rec.created_by)
        INTO l_orgn_code
        FROM sys.dual;

 	/* Step 3 : To insert  data ino the fm_form_mst_b and fm_form_mst_vl
                               table  */
        /* changed x_formula_vers to lab_rec.formula_vers */

        /* BEGIN BUG#3217071*/
        IF lab_rec.inactive_ind = 1 THEN
          X_STATUS := 1000;
        ELSIF lab_rec.inactive_ind = 0 THEN
          X_STATUS := 400;
        END IF;
        /* END BUG#3217071*/

        INSERT INTO FM_FORM_MST_B (formula_id, orgn_code, total_input_qty, total_output_qty, formula_status,
                                   formula_uom, owner_id, attribute_category, text_code, delete_mark,
                                   formula_no, formula_vers, formula_type, attribute1, attribute2, attribute3,
                                   attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,
                                   attribute10, attribute11, attribute12, attribute13, attribute14, attribute15,
                                   attribute16, attribute17, attribute18, attribute19, attribute20, attribute21,
                                   attribute22, attribute23, attribute24, attribute25, attribute26, attribute27,
                                   attribute28, attribute29, attribute30, inactive_ind, scale_type, formula_class,
                                   fmcontrol_class, creation_date, created_by, last_update_date, last_updated_by,
                                   last_update_login)
        VALUES                    (xFormula_Id, l_orgn_code, 0, 0, X_status,
                                   NULL, lab_rec.created_by, lab_rec.attribute_category, lab_rec.text_code, lab_rec.delete_mark,
                                   lab_rec.formula_no, X_formula_vers, lab_rec.formula_type, lab_rec.attribute1, lab_rec.attribute2, lab_rec.attribute3,
                                   lab_rec.attribute4, lab_rec.attribute5, lab_rec.attribute6, lab_rec.attribute7, lab_rec.attribute8, lab_rec.attribute9,
                                   lab_rec.attribute10, lab_rec.attribute11, lab_rec.attribute12, lab_rec.attribute13, lab_rec.attribute14, lab_rec.attribute15,
                                   lab_rec.attribute16, lab_rec.attribute17, lab_rec.attribute18, lab_rec.attribute19, lab_rec.attribute20, lab_rec.attribute21,
                                   lab_rec.attribute22, lab_rec.attribute23, lab_rec.attribute24, lab_rec.attribute25, lab_rec.attribute26, lab_rec.attribute27,
                                   lab_rec.attribute28, lab_rec.attribute29, lab_rec.attribute30, lab_rec.inactive_ind, lab_rec.scale_type, lab_rec.formula_class,
                                   lab_rec.fmcontrol_class, lab_rec.creation_date, lab_rec.created_by, lab_rec.last_update_date, lab_rec.last_updated_by,
                                   lab_rec.last_update_login);

         INSERT INTO FM_FORM_MST_TL (formula_id, formula_desc1, formula_desc2, language, source_lang,
                                     created_by, creation_date, last_updated_by, last_update_date, last_update_login)
         SELECT xFormula_Id, lab_rec.formula_desc1, lab_rec.formula_desc2, l.language_code, userenv('LANG'),
                lab_rec.created_by, lab_rec.creation_date, lab_rec.last_updated_by, lab_rec.last_update_date, lab_rec.last_update_login
         FROM FND_LANGUAGES l
         WHERE l.installed_flag IN ('I', 'B')
         AND NOT EXISTS (SELECT NULL FROM FM_FORM_MST_TL T WHERE t.formula_id = xFormula_Id AND t.language = l.language_code);



         INSERT INTO GMD_LAB_FORMULA_ASSOC(old_formula_id,old_formula_no,old_formula_vers,
 			              new_formula_id,new_formula_no,new_formula_vers
                                     ,migrated)
         VALUES(lab_rec.formula_id,lab_rec.formula_no,lab_rec.formula_vers,
                                       xformula_id,lab_rec.formula_no,x_formula_vers,'YES');

            /* Step 4 : To migrate data ino the lab formula detail table  */

        For lab_detail_rec IN lab_detail(lab_rec.formula_id)
        LOOP
          OPen fm_formulaline_id ;
          fetch fm_formulaline_id into Xformulaline_id ;
          close fm_formulaline_id;


          insert INTO FM_MATL_DTL (

       	 	FORMULALINE_ID ,
  		FORMULA_ID           ,
  		LINE_TYPE             ,
  		LINE_NO                ,
  		ITEM_ID                ,
  		QTY                    ,
  		ITEM_UM                ,
  		RELEASE_TYPE           ,
  		SCRAP_FACTOR           ,
  		SCALE_TYPE             ,
  		COST_ALLOC             ,
  		PHANTOM_TYPE           ,
  		REWORK_TYPE            ,
  		TEXT_CODE              ,
  		LAST_UPDATED_BY        ,
  		CREATED_BY             ,
  		LAST_UPDATE_DATE       ,
  		CREATION_DATE          ,
  		LAST_UPDATE_LOGIN      ,
  		ATTRIBUTE1             ,
  		ATTRIBUTE2             ,
  		ATTRIBUTE3             ,
  		ATTRIBUTE4             ,
  		ATTRIBUTE5             ,
  		ATTRIBUTE6             ,
  		ATTRIBUTE7             ,
  		ATTRIBUTE8             ,
  		ATTRIBUTE9             ,
  		ATTRIBUTE10            ,
  		ATTRIBUTE11            ,
  		ATTRIBUTE12            ,
  		ATTRIBUTE13            ,
  		ATTRIBUTE14            ,
  		ATTRIBUTE15            ,
  		ATTRIBUTE16            ,
  		ATTRIBUTE17            ,
  		ATTRIBUTE18            ,
  		ATTRIBUTE19            ,
  		ATTRIBUTE20            ,
  		ATTRIBUTE21            ,
  		ATTRIBUTE22            ,
  		ATTRIBUTE23            ,
  		ATTRIBUTE24            ,
  		ATTRIBUTE25            ,
  		ATTRIBUTE26            ,
  		ATTRIBUTE27            ,
  		ATTRIBUTE28            ,
  		ATTRIBUTE29            ,
  		ATTRIBUTE30            ,
  		ATTRIBUTE_CATEGORY     ,
  		TPFORMULA_ID           )
      	values (
    		Xformulaline_id ,
   	 	XFORMULA_ID           ,
  		lab_detail_rec.LINE_TYPE             ,
  		lab_detail_rec.LINE_NO                ,
  		lab_detail_rec.ITEM_ID                ,
  		lab_detail_rec.QTY                    ,
  		lab_detail_rec.ITEM_UM                ,
  		lab_detail_rec.RELEASE_TYPE           ,
  		lab_detail_rec.SCRAP_FACTOR           ,
  		lab_detail_rec.SCALE_TYPE             ,
  		lab_detail_rec.COST_ALLOC             ,
  		0           ,
  		0         ,
  		lab_detail_rec.TEXT_CODE              ,
  		lab_detail_rec.LAST_UPDATED_BY        ,
  		lab_detail_rec.CREATED_BY             ,
  		lab_detail_rec.LAST_UPDATE_DATE       ,
  		lab_detail_rec.CREATION_DATE          ,
  		lab_detail_rec.LAST_UPDATE_LOGIN      ,
  		lab_detail_rec.ATTRIBUTE1             ,
  		lab_detail_rec.ATTRIBUTE2             ,
  		lab_detail_rec.ATTRIBUTE3             ,
  		lab_detail_rec.ATTRIBUTE4             ,
  		lab_detail_rec.ATTRIBUTE5             ,
  		lab_detail_rec.ATTRIBUTE6             ,
  		lab_detail_rec.ATTRIBUTE7             ,
  		lab_detail_rec.ATTRIBUTE8             ,
  		lab_detail_rec.ATTRIBUTE9             ,
  		lab_detail_rec.ATTRIBUTE10            ,
  		lab_detail_rec.ATTRIBUTE11            ,
  		lab_detail_rec.ATTRIBUTE12            ,
  		lab_detail_rec.ATTRIBUTE13            ,
  		lab_detail_rec.ATTRIBUTE14            ,
  		lab_detail_rec.ATTRIBUTE15            ,
  		lab_detail_rec.ATTRIBUTE16            ,
  		lab_detail_rec.ATTRIBUTE17            ,
  		lab_detail_rec.ATTRIBUTE18            ,
  		lab_detail_rec.ATTRIBUTE19            ,
  		lab_detail_rec.ATTRIBUTE20            ,
  		lab_detail_rec.ATTRIBUTE21            ,
  		lab_detail_rec.ATTRIBUTE22            ,
  		lab_detail_rec.ATTRIBUTE23            ,
  		lab_detail_rec.ATTRIBUTE24            ,
  		lab_detail_rec.ATTRIBUTE25            ,
  		lab_detail_rec.ATTRIBUTE26            ,
  		lab_detail_rec.ATTRIBUTE27            ,
  		lab_detail_rec.ATTRIBUTE28            ,
  		lab_detail_rec.ATTRIBUTE29            ,
  		lab_detail_rec.ATTRIBUTE30            ,
  		lab_detail_rec.ATTRIBUTE_CATEGORY     ,
  		lab_detail_rec.TPFORMULA_ID           );

        end loop;
  	END IF ;


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
	   						'LM_FORM_MST AND LM_FORM_DTL',
	   						'FM_FORM_MST AND MF_MATL_DTL',
	   						lab_rec.formula_id,
	   						Xformula_id,
	   						error_msg
	   				FROM 	DUAL;


      END;

    END LOOP;



            /*get all the formula with tpformula_id */
      FOR lab_rec IN Cur_tp_formula LOOP
      BEGIN
        SAVEPOINT header;

        /* Step 1 : To migrate data ino the lab formula Header table  */

        OPen fm_formula_id ;
        fetch fm_formula_id into Xformula_id ;
        close fm_formula_id;

           /* Step 2 : To check for those formula no and version which
                         exists in the formula Header table. If a formula with same
                         formula no and version exists in the formula header table,
                         increase the version of formula to be inserted. */
 X_flag := 'FALSE' ;

          OPEN Cur_check_formula_exists (lab_rec.formula_no, lab_rec.formula_vers);
          FETCH Cur_check_formula_exists INTO X_formula_vers, x_formula_status;
          IF Cur_check_formula_exists%FOUND THEN
            OPEN Cur_formula_trans_exists(lab_rec.formula_id);
            FETCH Cur_formula_trans_exists INTO l_count;
            CLOSE Cur_formula_trans_exists;
            IF (l_count = 0) THEN
              lab_rec.formula_no := lab_rec.formula_no||'_LAB';
              X_formula_vers := lab_rec.formula_vers;
              X_FLAG := 'TRUE';
            END IF;
          ELSE
              X_formula_vers := lab_rec.formula_vers;
              X_FLAG := 'TRUE' ;
          END IF ;
         CLOSE Cur_check_formula_exists;
          IF   X_FLAG = 'TRUE'  THEN


        select fnd_profile.value_specific('GEMMS_DEFAULT_ORGN',lab_rec.created_by)
        INTO l_orgn_code
        FROM sys.dual;

          /* Step 3 : To insert  data ino the fm_form_mst_b and fm_form_mst_vl
                               table  */
        INSERT INTO GMD_LAB_FORMULA_ASSOC(old_formula_id,old_formula_no,old_formula_vers,
 			              new_formula_id,new_formula_no,new_formula_vers
                                     ,migrated)
                               VALUES(lab_rec.formula_id,lab_rec.formula_no,lab_rec.formula_vers,
                                       xformula_id,lab_rec.formula_no,x_formula_vers,'YES');

        /* BEGIN BUG#3217071*/
        IF lab_rec.inactive_ind = 1 THEN
          X_STATUS := 1000;
        ELSIF lab_rec.inactive_ind = 0 THEN
          X_STATUS := 400;
        END IF;
        /* END BUG#3217071*/

        INSERT INTO FM_FORM_MST_B (formula_id, orgn_code, total_input_qty, total_output_qty, formula_status,
                                   formula_uom, owner_id, attribute_category, text_code, delete_mark,
                                   formula_no, formula_vers, formula_type, attribute1, attribute2, attribute3,
                                   attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,
                                   attribute10, attribute11, attribute12, attribute13, attribute14, attribute15,
                                   attribute16, attribute17, attribute18, attribute19, attribute20, attribute21,
                                   attribute22, attribute23, attribute24, attribute25, attribute26, attribute27,
                                   attribute28, attribute29, attribute30, inactive_ind, scale_type, formula_class,
                                   fmcontrol_class, creation_date, created_by, last_update_date, last_updated_by,
                                   last_update_login)
        VALUES                    (xFormula_Id, l_orgn_code, 0, 0, X_status,
                                   NULL, lab_rec.created_by, lab_rec.attribute_category, lab_rec.text_code, lab_rec.delete_mark,
                                   lab_rec.formula_no, X_formula_vers, lab_rec.formula_type, lab_rec.attribute1, lab_rec.attribute2, lab_rec.attribute3,
                                   lab_rec.attribute4, lab_rec.attribute5, lab_rec.attribute6, lab_rec.attribute7, lab_rec.attribute8, lab_rec.attribute9,
                                   lab_rec.attribute10, lab_rec.attribute11, lab_rec.attribute12, lab_rec.attribute13, lab_rec.attribute14, lab_rec.attribute15,
                                   lab_rec.attribute16, lab_rec.attribute17, lab_rec.attribute18, lab_rec.attribute19, lab_rec.attribute20, lab_rec.attribute21,
                                   lab_rec.attribute22, lab_rec.attribute23, lab_rec.attribute24, lab_rec.attribute25, lab_rec.attribute26, lab_rec.attribute27,
                                   lab_rec.attribute28, lab_rec.attribute29, lab_rec.attribute30, lab_rec.inactive_ind, lab_rec.scale_type, lab_rec.formula_class,
                                   lab_rec.fmcontrol_class, lab_rec.creation_date, lab_rec.created_by, lab_rec.last_update_date, lab_rec.last_updated_by,
                                   lab_rec.last_update_login);

         INSERT INTO FM_FORM_MST_TL (formula_id, formula_desc1, formula_desc2, language, source_lang,
                                     created_by, creation_date, last_updated_by, last_update_date, last_update_login)
         SELECT xFormula_Id, lab_rec.formula_desc1, lab_rec.formula_desc2, l.language_code, userenv('LANG'),
                lab_rec.created_by, lab_rec.creation_date, lab_rec.last_updated_by, lab_rec.last_update_date, lab_rec.last_update_login
         FROM FND_LANGUAGES l
         WHERE l.installed_flag IN ('I', 'B')
         AND NOT EXISTS (SELECT NULL FROM FM_FORM_MST_TL T WHERE t.formula_id = xFormula_Id AND t.language = l.language_code);


        For lab_detail_rec IN lab_detail(lab_rec.formula_id)
        LOOP
        /* Step 4 : To migrate data ino the lab formula detail table  */

          OPen fm_formulaline_id ;
          fetch fm_formulaline_id into Xformulaline_id ;
          close fm_formulaline_id;

          /* Step 4 : To get the new tpformula_id for a given tpformula_id  */

          IF NVL(lab_detail_rec.tpformula_id, 0) > 0 THEN
            OPEN Cur_get_tp_id (lab_detail_rec.tpformula_id);
            FETCH Cur_get_tp_id INTO X_tp_formula_id;
            CLOSE Cur_get_tp_id;
          ELSE
            X_tp_formula_id := NULL;
          END IF;
            INSERT INTO GMD_LAB_FORMULA_ASSOC(old_formula_id,old_formula_no,old_formula_vers,
 			              new_formula_id,new_formula_no,new_formula_vers
                                     ,migrated,old_tp_formula_id,new_tp_formula_id)
                               VALUES(lab_rec.formula_id,lab_rec.formula_no,lab_rec.formula_vers,
                                       xformula_id,lab_rec.formula_no,x_formula_vers,'YES',
                                       lab_detail_rec.tpformula_id,X_tp_formula_id);

          insert INTO FM_MATL_DTL (

       	 	FORMULALINE_ID ,
  		FORMULA_ID           ,
  		LINE_TYPE             ,
  		LINE_NO                ,
  		ITEM_ID                ,
  		QTY                    ,
  		ITEM_UM                ,
  		RELEASE_TYPE           ,
  		SCRAP_FACTOR           ,
  		SCALE_TYPE             ,
  		COST_ALLOC             ,
  		PHANTOM_TYPE           ,
  		REWORK_TYPE            ,
  		TEXT_CODE              ,
  		LAST_UPDATED_BY        ,
  		CREATED_BY             ,
  		LAST_UPDATE_DATE       ,
  		CREATION_DATE          ,
  		LAST_UPDATE_LOGIN      ,
  		ATTRIBUTE1             ,
  		ATTRIBUTE2             ,
  		ATTRIBUTE3             ,
  		ATTRIBUTE4             ,
  		ATTRIBUTE5             ,
  		ATTRIBUTE6             ,
  		ATTRIBUTE7             ,
  		ATTRIBUTE8             ,
  		ATTRIBUTE9             ,
  		ATTRIBUTE10            ,
  		ATTRIBUTE11            ,
  		ATTRIBUTE12            ,
  		ATTRIBUTE13            ,
  		ATTRIBUTE14            ,
  		ATTRIBUTE15            ,
  		ATTRIBUTE16            ,
  		ATTRIBUTE17            ,
  		ATTRIBUTE18            ,
  		ATTRIBUTE19            ,
  		ATTRIBUTE20            ,
  		ATTRIBUTE21            ,
  		ATTRIBUTE22            ,
  		ATTRIBUTE23            ,
  		ATTRIBUTE24            ,
  		ATTRIBUTE25            ,
  		ATTRIBUTE26            ,
  		ATTRIBUTE27            ,
  		ATTRIBUTE28            ,
  		ATTRIBUTE29            ,
  		ATTRIBUTE30            ,
  		ATTRIBUTE_CATEGORY     ,
  		TPFORMULA_ID           )
      	values (

    		Xformulaline_id ,
   	 	XFORMULA_ID           ,
  		lab_detail_rec.LINE_TYPE             ,
  		lab_detail_rec.LINE_NO                ,
  		lab_detail_rec.ITEM_ID                ,
  		lab_detail_rec.QTY                    ,
  		lab_detail_rec.ITEM_UM                ,
  		lab_detail_rec.RELEASE_TYPE           ,
  		lab_detail_rec.SCRAP_FACTOR           ,
  		lab_detail_rec.SCALE_TYPE             ,
  		lab_detail_rec.COST_ALLOC             ,
  		0           ,
  		0         ,
  		lab_detail_rec.TEXT_CODE              ,
  		lab_detail_rec.LAST_UPDATED_BY        ,
  		lab_detail_rec.CREATED_BY             ,
  		lab_detail_rec.LAST_UPDATE_DATE       ,
  		lab_detail_rec.CREATION_DATE          ,
  		lab_detail_rec.LAST_UPDATE_LOGIN      ,
  		lab_detail_rec.ATTRIBUTE1             ,
  		lab_detail_rec.ATTRIBUTE2             ,
  		lab_detail_rec.ATTRIBUTE3             ,
  		lab_detail_rec.ATTRIBUTE4             ,
  		lab_detail_rec.ATTRIBUTE5             ,
  		lab_detail_rec.ATTRIBUTE6             ,
  		lab_detail_rec.ATTRIBUTE7             ,
  		lab_detail_rec.ATTRIBUTE8             ,
  		lab_detail_rec.ATTRIBUTE9             ,
  		lab_detail_rec.ATTRIBUTE10            ,
  		lab_detail_rec.ATTRIBUTE11            ,
  		lab_detail_rec.ATTRIBUTE12            ,
  		lab_detail_rec.ATTRIBUTE13            ,
  		lab_detail_rec.ATTRIBUTE14            ,
  		lab_detail_rec.ATTRIBUTE15            ,
  		lab_detail_rec.ATTRIBUTE16            ,
  		lab_detail_rec.ATTRIBUTE17            ,
  		lab_detail_rec.ATTRIBUTE18            ,
  		lab_detail_rec.ATTRIBUTE19            ,
  		lab_detail_rec.ATTRIBUTE20            ,
  		lab_detail_rec.ATTRIBUTE21            ,
  		lab_detail_rec.ATTRIBUTE22            ,
  		lab_detail_rec.ATTRIBUTE23            ,
  		lab_detail_rec.ATTRIBUTE24            ,
  		lab_detail_rec.ATTRIBUTE25            ,
  		lab_detail_rec.ATTRIBUTE26            ,
  		lab_detail_rec.ATTRIBUTE27            ,
  		lab_detail_rec.ATTRIBUTE28            ,
  		lab_detail_rec.ATTRIBUTE29            ,
  		lab_detail_rec.ATTRIBUTE30            ,
  		lab_detail_rec.ATTRIBUTE_CATEGORY     ,
  		X_tp_formula_id           );

        end loop;

END IF ;


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
	   						'LM_FORM_MST AND LM_FORM_DTL',
	   						'FM_FORM_MST AND MF_MATL_DTL',
	   						lab_rec.formula_id,
	   						Xformula_id,
	   						error_msg
	   				FROM 	DUAL;


      END;

    END LOOP;



end insert_lab_formula;

END GMD_LAB_MIGRATION;

/
