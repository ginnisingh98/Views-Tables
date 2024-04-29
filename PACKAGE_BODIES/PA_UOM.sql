--------------------------------------------------------
--  DDL for Package Body PA_UOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UOM" AS
/* $Header: PATXUOMB.pls 120.3 2008/02/14 06:59:56 anuragar ship $ */


PROCEDURE update_fnd_lookup_values(
  X_LOOKUP_TYPE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER default NULL,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_LANGUAGE  in VARCHAR2,
  X_TAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_TERRITORY_CODE in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
sgid NUMBER ;

begin

   if (X_SECURITY_GROUP_ID is NULL) then
       sgid:= FND_GLOBAL.SECURITY_GROUP_ID;
   else
       sgid := X_SECURITY_GROUP_ID;
   end if;

     -- Update "non-translated" values in all languages
     update FND_LOOKUP_VALUES set
       TAG = X_TAG,
       ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
       ATTRIBUTE1 = X_ATTRIBUTE1,
       ATTRIBUTE2 = X_ATTRIBUTE2,
       ATTRIBUTE3 = X_ATTRIBUTE3,
       ATTRIBUTE4 = X_ATTRIBUTE4,
       ENABLED_FLAG = X_ENABLED_FLAG,
       START_DATE_ACTIVE = X_START_DATE_ACTIVE,
       END_DATE_ACTIVE = X_END_DATE_ACTIVE,
       TERRITORY_CODE = X_TERRITORY_CODE,
       ATTRIBUTE5 = X_ATTRIBUTE5,
       ATTRIBUTE6 = X_ATTRIBUTE6,
       ATTRIBUTE7 = X_ATTRIBUTE7,
       ATTRIBUTE8 = X_ATTRIBUTE8,
       ATTRIBUTE9 = X_ATTRIBUTE9,
       ATTRIBUTE10 = X_ATTRIBUTE10,
       ATTRIBUTE11 = X_ATTRIBUTE11,
       ATTRIBUTE12 = X_ATTRIBUTE12,
       ATTRIBUTE13 = X_ATTRIBUTE13,
       ATTRIBUTE14 = X_ATTRIBUTE14,
       ATTRIBUTE15 = X_ATTRIBUTE15,
       LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
       LAST_UPDATED_BY = X_LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
     where LOOKUP_TYPE = X_LOOKUP_TYPE
     and SECURITY_GROUP_ID = sgid
     and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
     and LOOKUP_CODE = X_LOOKUP_CODE
     and LANGUAGE= X_LANGUAGE;


    -- Update "translated" values in current language
     update FND_LOOKUP_VALUES set
       MEANING = X_MEANING,
       DESCRIPTION = X_DESCRIPTION,
       SOURCE_LANG = userenv('LANG')
     where LOOKUP_TYPE = X_LOOKUP_TYPE
     and SECURITY_GROUP_ID = sgid
     and VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID
     and LOOKUP_CODE = X_LOOKUP_CODE
     and LANGUAGE=X_LANGUAGE;


     if (sql%notfound) then
          raise no_data_found;
     end if;


  exception
    when others then
    raise;
  end update_fnd_lookup_values;

/******************************************************************************/
------------------------------  Function Get_UOM  ------------------------------
/******************************************************************************/

FUNCTION get_uom(P_user_id IN number , P_uom_code IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS

/*****************************************************************************/
/*****  This procedure will first Identify any Upadted UOM in MTL. And   *****/
/*****  reflect the same in FND LOOKUP VALUES. Once Updated existing UOM *****/
/*****  it will Insert any newly introduced UOMs in MTL to FND LOOKUP    *****/
/*****  VALUES. This is done using BulkInsertion.                        *****/
/*****************************************************************************/

l_conc_login_id NUMBER ;
l_security_group_id NUMBER ;
l_return_str VARCHAR2(2000);
l_rowid VARCHAR2(2000);

CURSOR cur_chg_uom_code_1(p_uom_code IN VARCHAR2) IS /*cursor to select records whose meaning have been updated by the users in the mtl table */
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE mtl_uom.uom_code  = p_uom_code
/* AND  language = userenv('LANG') */
AND    EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    flv.meaning <> mtl_uom.unit_of_measure_tl
	    AND    flv.lookup_code = mtl_uom.uom_code
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND NOT EXISTS
            (SELECT 1
             FROM   fnd_lookup_values  flv1
             WHERE  flv1.lookup_type = 'UNIT'
	     AND    flv1.meaning = mtl_uom.unit_of_measure_tl
             AND    flv1.view_application_id = 275
             AND    flv1.security_group_id = fnd_global.lookup_security_group('UNIT',275)
             AND    flv1.language = mtl_uom.language
            )
AND  rowid =		(
			SELECT max(rowid) from Mtl_Units_Of_Measure_TL mtl_uom_2
			WHERE  mtl_uom.unit_of_measure_tl = mtl_uom_2.unit_of_measure_tl
			AND  mtl_uom.language = mtl_uom_2.language
			);	   /*Bug 6740153 added the rowid condition to fetch unique record only */
CURSOR cur_chg_uom_code IS /*cursor to select records whose meaning have been updated by the users in the mtl table */
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE  /* language = userenv('LANG') */
EXISTS (SELECT UOM_CODE FROM MTL_UOM_CONVERSIONS MUC_UOM
          WHERE MUC_UOM.UOM_CODE = MTL_UOM.UOM_CODE
	   )
AND    EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    flv.meaning <> mtl_uom.unit_of_measure_tl
	    AND    flv.lookup_code = mtl_uom.uom_code
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND NOT EXISTS
            (SELECT 1
             FROM   fnd_lookup_values  flv1
             WHERE  flv1.lookup_type = 'UNIT'
	     AND    flv1.meaning = mtl_uom.unit_of_measure_tl
             AND    flv1.view_application_id = 275
             AND    flv1.security_group_id = fnd_global.lookup_security_group('UNIT',275)
             AND    flv1.language = mtl_uom.language
            )
AND  rowid =		(
			SELECT max(rowid) from Mtl_Units_Of_Measure_TL mtl_uom_2
			WHERE  mtl_uom.unit_of_measure_tl = mtl_uom_2.unit_of_measure_tl
			AND  mtl_uom.language = mtl_uom_2.language
			);	   /*Bug 6740153 added the rowid condition to fetch unique record only */
/* Removed check for bug 4130638
AND EXISTS
           ( SELECT 1
              FROM pa_transaction_interface_all pa
              WHERE pa.unit_of_measure =  mtl_uom.uom_code
           ) ;
*/

CURSOR cur_chg_uom_code_y(p_uom_code IN VARCHAR2 ) IS /*cursor to update records with @meaning where duplication for meaning exists*/
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE  mtl_uom.uom_code = p_uom_code
/* AND    language = userenv('LANG') */
AND    EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    flv.meaning <> mtl_uom.unit_of_measure_tl
	    AND    flv.lookup_code = mtl_uom.uom_code
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND NOT EXISTS
            (SELECT 1
             FROM   fnd_lookup_values  flv1
             WHERE  flv1.lookup_type = 'UNIT'
	     AND    flv1.meaning = '@'||mtl_uom.unit_of_measure_tl
             AND    flv1.view_application_id = 275
             AND    flv1.security_group_id = fnd_global.lookup_security_group('UNIT',275)
             AND    flv1.language = mtl_uom.language
            );
CURSOR cur_chg_uom_code_x IS /*cursor to update records with @meaning where duplication for meaning exists*/
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE  /* language = userenv('LANG') */
EXISTS (SELECT UOM_CODE FROM MTL_UOM_CONVERSIONS MUC_UOM
          WHERE MUC_UOM.UOM_CODE = MTL_UOM.UOM_CODE
	   )
AND    EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    flv.meaning <> mtl_uom.unit_of_measure_tl
	    AND    flv.lookup_code = mtl_uom.uom_code
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND NOT EXISTS
            (SELECT 1
             FROM   fnd_lookup_values  flv1
             WHERE  flv1.lookup_type = 'UNIT'
	     AND    flv1.meaning = '@'||mtl_uom.unit_of_measure_tl
             AND    flv1.view_application_id = 275
             AND    flv1.security_group_id = fnd_global.lookup_security_group('UNIT',275)
             AND    flv1.language = mtl_uom.language
            );
/* Removed check for bug 4130638
AND EXISTS
           ( SELECT 1
              FROM pa_transaction_interface_all pa
              WHERE pa.unit_of_measure =  mtl_uom.uom_code
           ) ;
*/

CURSOR cur_chg_uom_meaning_1 (p_uom_code IN VARCHAR2) IS/*cursor to select records where different UOM code exists for the same meaning */
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE /* language = userenv('LANG') */
	   mtl_uom.uom_code = p_uom_code
AND    EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    flv.meaning = mtl_uom.unit_of_measure_tl
     	    AND    flv.lookup_code <> mtl_uom.uom_code
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND NOT EXISTS
            (SELECT 1
             FROM   fnd_lookup_values  flv1
             WHERE  flv1.lookup_type = 'UNIT'
	     AND    flv1.lookup_code = mtl_uom.uom_code
             AND    flv1.view_application_id = 275
             AND    flv1.security_group_id = fnd_global.lookup_security_group('UNIT',275)
             AND    flv1.language = mtl_uom.language
            );

CURSOR cur_chg_uom_meaning IS/*cursor to select records where different UOM code exists for the same meaning */
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE   /* language = userenv('LANG') */
EXISTS (SELECT UOM_CODE FROM MTL_UOM_CONVERSIONS MUC_UOM
          WHERE MUC_UOM.UOM_CODE = MTL_UOM.UOM_CODE
	   )
AND    EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    flv.meaning = mtl_uom.unit_of_measure_tl
     	    AND    flv.lookup_code <> mtl_uom.uom_code
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND NOT EXISTS
            (SELECT 1
             FROM   fnd_lookup_values  flv1
             WHERE  flv1.lookup_type = 'UNIT'
	     AND    flv1.lookup_code = mtl_uom.uom_code
             AND    flv1.view_application_id = 275
             AND    flv1.security_group_id = fnd_global.lookup_security_group('UNIT',275)
             AND    flv1.language = mtl_uom.language
            );

/* Removed check for bug 4130638
AND EXISTS
           ( SELECT 1
              FROM pa_transaction_interface_all pa
              WHERE pa.unit_of_measure =  mtl_uom.uom_code
           ) ;
*/


CURSOR cur_new_uom_1(p_uom_code IN VARCHAR2 ) IS /* cursor to select new unit of measure codes which are not present in pa_lookup */
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE  mtl_uom.uom_code = p_uom_code
/* AND    language = userenv('LANG') */
AND    NOT EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    (flv.meaning = mtl_uom.unit_of_measure_tl OR flv.lookup_code = mtl_uom.uom_code)
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND  rowid =		(
			SELECT max(rowid) from Mtl_Units_Of_Measure_TL mtl_uom_2
			WHERE  mtl_uom.unit_of_measure_tl = mtl_uom_2.unit_of_measure_tl
			AND  mtl_uom.language = mtl_uom_2.language
			);	   /*Bug 6740153 added the rowid condition to fetch unique record only */
CURSOR cur_new_uom IS /* cursor to select new unit of measure codes which are not present in pa_lookup */
SELECT  language
       ,uom_code
       ,disable_date
       ,unit_of_measure_tl
       ,description
       ,source_lang
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
FROM   Mtl_Units_Of_Measure_TL mtl_uom
WHERE  /* language = userenv('LANG') */
EXISTS (SELECT UOM_CODE FROM MTL_UOM_CONVERSIONS MUC_UOM
          WHERE MUC_UOM.UOM_CODE = MTL_UOM.UOM_CODE
	   )
AND    NOT EXISTS
           (SELECT lookup_code
            FROM   fnd_lookup_values  flv
            WHERE  flv.lookup_type = 'UNIT'
            AND    (flv.meaning = mtl_uom.unit_of_measure_tl OR flv.lookup_code = mtl_uom.uom_code)
            AND    flv.view_application_id = 275
            AND    flv.security_group_id = fnd_global.lookup_security_group('UNIT',275)
            AND    flv.language = mtl_uom.language
	   )
AND  rowid =		(
			SELECT max(rowid) from Mtl_Units_Of_Measure_TL mtl_uom_2
			WHERE  mtl_uom.unit_of_measure_tl = mtl_uom_2.unit_of_measure_tl
			AND  mtl_uom.language = mtl_uom_2.language
			);	   /*Bug 6740153 added the rowid condition to fetch unique record only */
/* Removed check for bug 4130638
AND EXISTS
           ( SELECT 1
              FROM pa_transaction_interface_all pa
              WHERE pa.unit_of_measure =  mtl_uom.uom_code
           ) ;
*/
BEGIN --Function Get_UOM Begins

l_conc_login_id      := fnd_global.CONC_LOGIN_ID;
l_security_group_id  := fnd_global.lookup_security_group('UNIT',275);
l_return_str         := 'S';

/* Bug 6740153 Changed the logic so that new UOMS defined in MTL are inserted first
(only one record per meaning) so that the next record is updated with @meaning */
-------------------------------------------------------------------------------
----------------------------  Insert New UOMs  ----------------------------
-------------------------------------------------------------------------------

If p_uom_code IS NOT NULL then -- When PJF team calls they pass p_uom_code
 FOR rec_new_uom_1 IN cur_new_uom_1 ( p_uom_code )
  LOOP
  fnd_lookup_values_pkg.insert_row (
  x_rowid => l_rowid,
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_new_uom_1.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_new_uom_1.Attribute_Category,
  x_attribute1 => rec_new_uom_1.Attribute1,
  x_attribute2 => rec_new_uom_1.Attribute2,
  x_attribute3 => rec_new_uom_1.Attribute3,
  x_attribute4 => rec_new_uom_1.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_new_uom_1.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_new_uom_1.Attribute5,
  x_attribute6 => rec_new_uom_1.Attribute6,
  x_attribute7 => rec_new_uom_1.Attribute7,
  x_attribute8 => rec_new_uom_1.Attribute8,
  x_attribute9 => rec_new_uom_1.Attribute9,
  x_attribute10 => rec_new_uom_1.Attribute10,
  x_attribute11 => rec_new_uom_1.Attribute11,
  x_attribute12 => rec_new_uom_1.Attribute12,
  x_attribute13 => rec_new_uom_1.Attribute13,
  x_attribute14 => rec_new_uom_1.Attribute14,
  x_attribute15 => rec_new_uom_1.Attribute15,
  x_meaning => rec_new_uom_1.unit_of_measure_tl,
  x_description => rec_new_uom_1.description,
  x_creation_date => SYSDATE,
  x_created_by => P_user_id,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id);
END LOOP ;
else   -- When PA calls p_uom_code will be NULL
FOR rec_new_uom IN cur_new_uom
 LOOP
  fnd_lookup_values_pkg.insert_row (
  x_rowid => l_rowid,
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_new_uom.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_new_uom.Attribute_Category,
  x_attribute1 => rec_new_uom.Attribute1,
  x_attribute2 => rec_new_uom.Attribute2,
  x_attribute3 => rec_new_uom.Attribute3,
  x_attribute4 => rec_new_uom.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_new_uom.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_new_uom.Attribute5,
  x_attribute6 => rec_new_uom.Attribute6,
  x_attribute7 => rec_new_uom.Attribute7,
  x_attribute8 => rec_new_uom.Attribute8,
  x_attribute9 => rec_new_uom.Attribute9,
  x_attribute10 => rec_new_uom.Attribute10,
  x_attribute11 => rec_new_uom.Attribute11,
  x_attribute12 => rec_new_uom.Attribute12,
  x_attribute13 => rec_new_uom.Attribute13,
  x_attribute14 => rec_new_uom.Attribute14,
  x_attribute15 => rec_new_uom.Attribute15,
  x_meaning => rec_new_uom.unit_of_measure_tl,
  x_description => rec_new_uom.description,
  x_creation_date => SYSDATE,
  x_created_by => P_user_id,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id);
END LOOP ;

end if ;

-------------------------------------------------------------------------------
---------------------------  Update Existing UOMs  ----------------------------
-------------------------------------------------------------------------------


/*****  Update UOM Code in FND LOOKUP VALUES from PLSQL Tables. Here all  ****/
/*****  the UOM Codes where meaning is changed in MTL, will be updated to ****/
/*****  Reflect the same in Lookups                                       ****/
If p_uom_code IS NOT NULL then -- When PJF team calls they pass p_uom_code
 FOR rec_chg_uom_code_1 IN cur_chg_uom_code_1(p_uom_code )
 LOOP
  fnd_lookup_values_pkg.update_row (
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_chg_uom_code_1.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_chg_uom_code_1.Attribute_Category,
  x_attribute1 => rec_chg_uom_code_1.Attribute1,
  x_attribute2 => rec_chg_uom_code_1.Attribute2,
  x_attribute3 => rec_chg_uom_code_1.Attribute3,
  x_attribute4 => rec_chg_uom_code_1.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_chg_uom_code_1.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_chg_uom_code_1.Attribute5,
  x_attribute6 => rec_chg_uom_code_1.Attribute6,
  x_attribute7 => rec_chg_uom_code_1.Attribute7,
  x_attribute8 => rec_chg_uom_code_1.Attribute8,
  x_attribute9 => rec_chg_uom_code_1.Attribute9,
  x_attribute10 => rec_chg_uom_code_1.Attribute10,
  x_attribute11 => rec_chg_uom_code_1.Attribute11,
  x_attribute12 => rec_chg_uom_code_1.Attribute12,
  x_attribute13 => rec_chg_uom_code_1.Attribute13,
  x_attribute14 => rec_chg_uom_code_1.Attribute14,
  x_attribute15 => rec_chg_uom_code_1.Attribute15,
  x_meaning => rec_chg_uom_code_1.unit_of_measure_tl,
  x_description => rec_chg_uom_code_1.description,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id
  ) ;
 END LOOP;
else   -- When PA calls p_uom_code will be NULL
 FOR rec_chg_uom_code IN cur_chg_uom_code
  LOOP

  /*  commented for bug 5624048
  fnd_lookup_values_pkg.update_row (
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_chg_uom_code.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_chg_uom_code.Attribute_Category,
  x_attribute1 => rec_chg_uom_code.Attribute1,
  x_attribute2 => rec_chg_uom_code.Attribute2,
  x_attribute3 => rec_chg_uom_code.Attribute3,
  x_attribute4 => rec_chg_uom_code.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_chg_uom_code.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_chg_uom_code.Attribute5,
  x_attribute6 => rec_chg_uom_code.Attribute6,
  x_attribute7 => rec_chg_uom_code.Attribute7,
  x_attribute8 => rec_chg_uom_code.Attribute8,
  x_attribute9 => rec_chg_uom_code.Attribute9,
  x_attribute10 => rec_chg_uom_code.Attribute10,
  x_attribute11 => rec_chg_uom_code.Attribute11,
  x_attribute12 => rec_chg_uom_code.Attribute12,
  x_attribute13 => rec_chg_uom_code.Attribute13,
  x_attribute14 => rec_chg_uom_code.Attribute14,
  x_attribute15 => rec_chg_uom_code.Attribute15,
  x_meaning => rec_chg_uom_code.unit_of_measure_tl,
  x_description => rec_chg_uom_code.description,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id
  ) ; */

 /* changed the call for bug 5624048  */
 update_fnd_lookup_values (
    x_lookup_type => 'UNIT',
    x_security_group_id => l_security_group_id,
    x_view_application_id => 275,
    x_lookup_code => rec_chg_uom_code.Uom_Code,
    x_language => rec_chg_uom_code.language,
    x_tag => NULL,
    x_attribute_category => rec_chg_uom_code.Attribute_Category,
    x_attribute1 => rec_chg_uom_code.Attribute1,
    x_attribute2 => rec_chg_uom_code.Attribute2,
    x_attribute3 => rec_chg_uom_code.Attribute3,
    x_attribute4 => rec_chg_uom_code.Attribute4,
    x_enabled_flag => 'Y',
    x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
    x_end_date_active => rec_chg_uom_code.disable_date,
    x_territory_code => NULL,
    x_attribute5 => rec_chg_uom_code.Attribute5,
    x_attribute6 => rec_chg_uom_code.Attribute6,
    x_attribute7 => rec_chg_uom_code.Attribute7,
    x_attribute8 => rec_chg_uom_code.Attribute8,
    x_attribute9 => rec_chg_uom_code.Attribute9,
    x_attribute10 => rec_chg_uom_code.Attribute10,
    x_attribute11 => rec_chg_uom_code.Attribute11,
    x_attribute12 => rec_chg_uom_code.Attribute12,
    x_attribute13 => rec_chg_uom_code.Attribute13,
    x_attribute14 => rec_chg_uom_code.Attribute14,
    x_attribute15 => rec_chg_uom_code.Attribute15,
    x_meaning => rec_chg_uom_code.unit_of_measure_tl,
    x_description => rec_chg_uom_code.description,
    x_last_update_date => SYSDATE,
    x_last_updated_by => P_user_id,
    x_last_update_login => l_conc_login_id
  ) ;

  END LOOP;

end if ;

If p_uom_code IS NOT NULL then -- When PJF team calls they pass p_uom_code
  FOR rec_chg_uom_code_y IN cur_chg_uom_code_y(p_uom_code )
  LOOP
  fnd_lookup_values_pkg.update_row (
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_chg_uom_code_y.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_chg_uom_code_y.Attribute_Category,
  x_attribute1 => rec_chg_uom_code_y.Attribute1,
  x_attribute2 => rec_chg_uom_code_y.Attribute2,
  x_attribute3 => rec_chg_uom_code_y.Attribute3,
  x_attribute4 => rec_chg_uom_code_y.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_chg_uom_code_y.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_chg_uom_code_y.Attribute5,
  x_attribute6 => rec_chg_uom_code_y.Attribute6,
  x_attribute7 => rec_chg_uom_code_y.Attribute7,
  x_attribute8 => rec_chg_uom_code_y.Attribute8,
  x_attribute9 => rec_chg_uom_code_y.Attribute9,
  x_attribute10 => rec_chg_uom_code_y.Attribute10,
  x_attribute11 => rec_chg_uom_code_y.Attribute11,
  x_attribute12 => rec_chg_uom_code_y.Attribute12,
  x_attribute13 => rec_chg_uom_code_y.Attribute13,
  x_attribute14 => rec_chg_uom_code_y.Attribute14,
  x_attribute15 => rec_chg_uom_code_y.Attribute15,
  x_meaning => '@'||rec_chg_uom_code_y.unit_of_measure_tl,
  x_description => rec_chg_uom_code_y.description,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id
  ) ;
  END LOOP;
 else   -- When PA calls p_uom_code will be NULL
  FOR rec_chg_uom_code IN cur_chg_uom_code_x
  LOOP
  /* changed the call for bug 5624048  */
  update_fnd_lookup_values (
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_chg_uom_code.Uom_Code,
  x_language  => rec_chg_uom_code.language,
  x_tag => NULL,
  x_attribute_category => rec_chg_uom_code.Attribute_Category,
  x_attribute1 => rec_chg_uom_code.Attribute1,
  x_attribute2 => rec_chg_uom_code.Attribute2,
  x_attribute3 => rec_chg_uom_code.Attribute3,
  x_attribute4 => rec_chg_uom_code.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_chg_uom_code.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_chg_uom_code.Attribute5,
  x_attribute6 => rec_chg_uom_code.Attribute6,
  x_attribute7 => rec_chg_uom_code.Attribute7,
  x_attribute8 => rec_chg_uom_code.Attribute8,
  x_attribute9 => rec_chg_uom_code.Attribute9,
  x_attribute10 => rec_chg_uom_code.Attribute10,
  x_attribute11 => rec_chg_uom_code.Attribute11,
  x_attribute12 => rec_chg_uom_code.Attribute12,
  x_attribute13 => rec_chg_uom_code.Attribute13,
  x_attribute14 => rec_chg_uom_code.Attribute14,
  x_attribute15 => rec_chg_uom_code.Attribute15,
  x_meaning => '@'||rec_chg_uom_code.unit_of_measure_tl,
  x_description => rec_chg_uom_code.description,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id
  ) ;
  END LOOP;

 end if;

/*****  Insert New UOM Code in FND LOOKUP VALUES from PLSQL Tables. Here  ****/
/*****  all the UOMs in MTL where Meaning meaning exists in Lookups but   ****/
/*****  corresponding Code is different, will be inserted to Reflect the  ****/
/*****  same in Lookups                                                   ****/

If p_uom_code IS NOT NULL then -- When PJF team calls they pass p_uom_code
 FOR rec_chg_uom_meaning_1  IN cur_chg_uom_meaning_1(p_uom_code )
  LOOP
  fnd_lookup_values_pkg.insert_row (
  x_rowid => l_rowid,
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_chg_uom_meaning_1.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_chg_uom_meaning_1.Attribute_Category,
  x_attribute1 => rec_chg_uom_meaning_1.Attribute1,
  x_attribute2 => rec_chg_uom_meaning_1.Attribute2,
  x_attribute3 => rec_chg_uom_meaning_1.Attribute3,
  x_attribute4 => rec_chg_uom_meaning_1.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_chg_uom_meaning_1.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_chg_uom_meaning_1.Attribute5,
  x_attribute6 => rec_chg_uom_meaning_1.Attribute6,
  x_attribute7 => rec_chg_uom_meaning_1.Attribute7,
  x_attribute8 => rec_chg_uom_meaning_1.Attribute8,
  x_attribute9 => rec_chg_uom_meaning_1.Attribute9,
  x_attribute10 => rec_chg_uom_meaning_1.Attribute10,
  x_attribute11 => rec_chg_uom_meaning_1.Attribute11,
  x_attribute12 => rec_chg_uom_meaning_1.Attribute12,
  x_attribute13 => rec_chg_uom_meaning_1.Attribute13,
  x_attribute14 => rec_chg_uom_meaning_1.Attribute14,
  x_attribute15 => rec_chg_uom_meaning_1.Attribute15,
  x_meaning => '@'||rec_chg_uom_meaning_1.unit_of_measure_tl,
  x_description => rec_chg_uom_meaning_1.description,
  x_creation_date => SYSDATE,
  x_created_by => P_user_id,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id);
 END LOOP;
else   -- When PA calls p_uom_code will be NULL
 FOR rec_chg_uom_meaning  IN cur_chg_uom_meaning
  LOOP

  fnd_lookup_values_pkg.insert_row (
  x_rowid => l_rowid,
  x_lookup_type => 'UNIT',
  x_security_group_id => l_security_group_id,
  x_view_application_id => 275,
  x_lookup_code => rec_chg_uom_meaning.Uom_Code,
  x_tag => NULL,
  x_attribute_category => rec_chg_uom_meaning.Attribute_Category,
  x_attribute1 => rec_chg_uom_meaning.Attribute1,
  x_attribute2 => rec_chg_uom_meaning.Attribute2,
  x_attribute3 => rec_chg_uom_meaning.Attribute3,
  x_attribute4 => rec_chg_uom_meaning.Attribute4,
  x_enabled_flag => 'Y',
  x_start_date_active => to_date('01/01/1951','DD/MM/YYYY'),
  x_end_date_active => rec_chg_uom_meaning.disable_date,
  x_territory_code => NULL,
  x_attribute5 => rec_chg_uom_meaning.Attribute5,
  x_attribute6 => rec_chg_uom_meaning.Attribute6,
  x_attribute7 => rec_chg_uom_meaning.Attribute7,
  x_attribute8 => rec_chg_uom_meaning.Attribute8,
  x_attribute9 => rec_chg_uom_meaning.Attribute9,
  x_attribute10 => rec_chg_uom_meaning.Attribute10,
  x_attribute11 => rec_chg_uom_meaning.Attribute11,
  x_attribute12 => rec_chg_uom_meaning.Attribute12,
  x_attribute13 => rec_chg_uom_meaning.Attribute13,
  x_attribute14 => rec_chg_uom_meaning.Attribute14,
  x_attribute15 => rec_chg_uom_meaning.Attribute15,
  x_meaning => '@'||rec_chg_uom_meaning.unit_of_measure_tl,
  x_description => rec_chg_uom_meaning.description,
  x_creation_date => SYSDATE,
  x_created_by => P_user_id,
  x_last_update_date => SYSDATE,
  x_last_updated_by => P_user_id,
  x_last_update_login => l_conc_login_id);
 END LOOP;

end if;



  RETURN l_return_str;

EXCEPTION
  WHEN OTHERS THEN
   l_return_str := 'UNEXPECTED_ERR : '||SQLERRM;
   return l_return_str;
END get_uom;

END pa_uom;

/
