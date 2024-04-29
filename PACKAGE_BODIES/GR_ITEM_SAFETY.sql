--------------------------------------------------------
--  DDL for Package Body GR_ITEM_SAFETY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ITEM_SAFETY" AS
/*$Header: GRFMISB.pls 120.3 2005/10/20 07:30:09 methomas noship $*/

PROCEDURE get_properties
			(p_organization_id   IN NUMBER,
                         p_inventory_item_id IN NUMBER,
			 p_label_code        IN VARCHAR2,
			 x_prop_data         IN OUT NOCOPY t_property_data)
 IS

/* Numeric variables */

L_RECORD_NUMBER	NUMBER := 0;
L_ORACLE_ERROR	NUMBER;

/* Alpha Variables */

L_CODE_BLOCK VARCHAR2(80);

/* 	Define the cursor
**
** 	Get the label properties
GR*/

CURSOR c_get_label_props
 IS
   SELECT lp.property_id,
	  lp.label_code,
	  lp.sequence_number,
	  pro.property_type_indicator,
	  pro.length,
	  pro.precision,
	  pro.range_min,
	  pro.range_max,
	  pd.description
   FROM	  gr_properties_tl pd,
   	  gr_label_properties lp,
          gr_properties_b pro
   WHERE  lp.label_code = p_label_code
   AND    lp.property_id = pro.property_id
   AND	  pd.property_id = lp.property_id
   AND    pd.language = USERENV('LANG')
   ORDER BY lp.sequence_number;
PropRecord		c_get_label_props%ROWTYPE;

/*	Get the item properties */
CURSOR c_get_item_props
 IS
   SELECT ip.rowid,
          ip.organization_id,
          ip.inventory_item_id,
	  ip.number_value,
	  ip.alpha_value,
	  ip.date_value,
	  ip.created_by,
	  ip.creation_date,
	  ip.last_updated_by,
	  ip.last_update_date,
	  ip.last_update_login
   FROM	  gr_inv_item_properties ip
   WHERE  ip.organization_id   = p_organization_id
   AND    ip.inventory_item_id = p_inventory_item_id
   AND 	  ip.label_code        = p_label_code
   AND    ip.property_id       = PropRecord.property_id;
ItemPropRecord		c_get_item_props%ROWTYPE;

/*	Get the property value meaning */

CURSOR c_get_value_meaning
 IS
   SELECT   pv.meaning
   FROM	    gr_property_values_tl pv
   WHERE    pv.property_id = PropRecord.property_id
   AND	    pv.language = USERENV('LANG')
   AND	    pv.value = ItemPropRecord.alpha_value;
ValueRecord			c_get_value_meaning%ROWTYPE;

BEGIN
/*	Start by initialising the table. Ideally it should be an OUT
**	parameter only, but that conflicts with the requirements of
**	Forms to handle the data.
*/
   x_prop_data.DELETE;

   OPEN c_get_label_props;
   l_code_block := 'Opened the cursor';

/*	Read the label properties first to get all of the properties
**	associated with the label.
*/
   LOOP
      l_record_number := l_record_number + 1;
      l_code_block := 'Into the loop';

      FETCH c_get_label_props INTO PropRecord;

/*	Have the label properties data -- move that into the data record
**	and then read the item properties.
*/

      IF c_get_label_props%FOUND THEN
	 x_prop_data(l_record_number).property_id             := PropRecord.property_id;
	 x_prop_data(l_record_number).label_code              := PropRecord.label_code;
	 x_prop_data(l_record_number).sequence_number         := PropRecord.sequence_number;
	 x_prop_data(l_record_number).property_type_indicator := PropRecord.property_type_indicator;
	 x_prop_data(l_record_number).length                  := PropRecord.length;
	 x_prop_data(l_record_number).precision               := PropRecord.precision;
	 x_prop_data(l_record_number).range_min               := PropRecord.range_min;
	 x_prop_data(l_record_number).range_max               := PropRecord.range_max;
	 x_prop_data(l_record_number).description             := PropRecord.description;

	 OPEN c_get_item_props;
	 FETCH c_get_item_props INTO ItemPropRecord;

/*	If the item properties row is found then move that information into
**	the data record, otherwise leave it blank.
*/
  	 IF c_get_item_props%FOUND THEN
	    x_prop_data(l_record_number).rowid             := ItemPropRecord.rowid;
	    x_prop_data(l_record_number).organization_id   := ItemPropRecord.organization_id;
	    x_prop_data(l_record_number).inventory_item_id := ItemPropRecord.inventory_item_id;
	    x_prop_data(l_record_number).number_value      := ItemPropRecord.number_value;
	    x_prop_data(l_record_number).alpha_value       := ItemPropRecord.alpha_value;
	    x_prop_data(l_record_number).date_value        := ItemPropRecord.date_value;
	    x_prop_data(l_record_number).created_by        := ItemPropRecord.created_by;
	    x_prop_data(l_record_number).creation_date     := ItemPropRecord.creation_date;
	    x_prop_data(l_record_number).last_updated_by   := ItemPropRecord.last_updated_by;
	    x_prop_data(l_record_number).last_update_date  := ItemPropRecord.last_update_date;
	    x_prop_data(l_record_number).last_update_login := ItemPropRecord.last_update_login;

/*
**	If property type is 'F' for a flag, get the meaning of the alpha value
*/
	IF PropRecord.property_type_indicator = 'F' THEN
	   OPEN c_get_value_meaning;
	   FETCH c_get_value_meaning INTO ValueRecord;
	   IF c_get_value_meaning%FOUND THEN
	      x_prop_data(l_record_number).meaning := ValueRecord.meaning;
	   END IF;
	   CLOSE c_get_value_meaning;
        END IF;
      END IF;
      CLOSE c_get_item_props;
   ELSE
	 EXIT;
      END IF;
   END LOOP;
   CLOSE c_get_label_props;

EXCEPTION

   WHEN OTHERS THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END get_properties;

PROCEDURE paste_item_safety
				(p_organization_id   IN NUMBER,
                                 p_copy_from_item    IN NUMBER,
				 p_paste_to_item     IN NUMBER,
				 x_return_status    OUT NOCOPY VARCHAR2,
				 x_oracle_error     OUT NOCOPY NUMBER,
				 x_msg_data         OUT NOCOPY VARCHAR2)
 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK  	  VARCHAR2(2000);
L_ROWID           VARCHAR2(18);
L_CALLED_BY_FORM  VARCHAR2(1) := 'F';
L_KEY_EXISTS      VARCHAR2(1);
L_COMMIT          VARCHAR2(1) := 'F';
L_MSG_DATA        VARCHAR2(2000);
L_RETURN_STATUS   VARCHAR2(1);

L_CURRENT_DATE    DATE := sysdate;
/*
** 	Numeric Variables
*/
L_ORACLE_ERROR	  NUMBER;
L_USER_ID         NUMBER;

/*
** Exceptions
*/
ITEM_NULL_ERROR         EXCEPTION;
INVALID_ITEM_CODE       EXCEPTION;
PASTE_ITEM_EXISTS_ERROR EXCEPTION;
INSERT_ROWS_ERROR       EXCEPTION;
UPDATE_ROWS_ERROR       EXCEPTION;

/*
** Cursors
**
** Get the Copy item general information
*/
CURSOR c_get_item_general
 IS
   SELECT  ig1.ROWID,
	   ig1.ingredient_flag,
	   ig1.explode_ingredient_flag,
	   ig1.organization_id,
	   ig1.inventory_item_id,
	   ig1.actual_hazard
   FROM    gr_item_explosion_properties ig1
   WHERE   ig1.organization_id   = p_organization_id
   AND     ig1.inventory_item_id = p_copy_from_item;
LocalItemRecord            c_get_item_general%ROWTYPE;

/*
** Cursors
**
** Get the paste item general information
*/

CURSOR c_get_item_general_rowid
 IS
   SELECT  ig1.ROWID
   FROM    gr_item_explosion_properties ig1
   WHERE   ig1.organization_id   = p_organization_id
   AND     ig1.inventory_item_id = p_paste_to_item;
LocalPItemRecord            c_get_item_general_rowid%ROWTYPE;

/*
** Copy Item Properties
*/
CURSOR c_get_item_properties
 IS
   SELECT  ip.sequence_number,
           ip.property_id,
	   ip.label_code,
	   ip.number_value,
	   ip.alpha_value,
	   ip.date_value
   FROM    gr_inv_item_properties ip
   WHERE   ip.organization_id   = p_organization_id
   AND     ip.inventory_item_id = p_copy_from_item;
LocalItemPropRecord			c_get_item_properties%ROWTYPE;

/*
** Copy Item Properties
*/
CURSOR c_get_item_properties_rowid (V_label_code VARCHAR2, V_property_id VARCHAR2, V_sequence_number NUMBER)
 IS
   SELECT  ip.rowid
   FROM    gr_inv_item_properties ip
   WHERE   ip.organization_id   = p_organization_id
   AND     ip.inventory_item_id = p_paste_to_item
   AND     ip.label_code        = V_label_code
   AND     ip.property_id       = V_property_id
   AND     ip.sequence_number   = V_sequence_number;
LocalPItemPropRecord			c_get_item_properties_rowid%ROWTYPE;

/*
**
*/
/*
** Get the Item Code
*/
CURSOR c_get_item_code (V_item_id NUMBER) IS
select item_code
from gr_item_general_v
where organization_id = p_organization_id
and   inventory_item_id = V_item_id;

l_copy_item  VARCHAR2(240);
l_paste_item VARCHAR2(240);

BEGIN

   l_code_block := NULL;
   l_user_id := FND_GLOBAL.User_id;
/*
** Check the entered item codes are not null
*/
   IF p_copy_from_item IS NULL THEN
      RAISE Item_Null_Error;
   END IF;

   OPEN c_get_item_code (p_copy_from_item);
   FETCH c_get_item_code INTO l_copy_item;
   CLOSE c_get_item_code;

   IF p_paste_to_item IS NULL THEN
      RAISE Item_Null_Error;
   END IF;

   OPEN c_get_item_code (p_paste_to_item);
   FETCH c_get_item_code INTO l_paste_item;
   CLOSE c_get_item_code;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
** Check the copy from item exists.
*/
   OPEN c_get_item_general;
   FETCH c_get_item_general INTO LocalItemRecord;
   IF c_get_item_general%NOTFOUND THEN
      CLOSE c_get_item_general;
      RAISE Invalid_Item_Code;
   END IF;

   CLOSE c_get_item_general;
/*
** Check the paste to item does not exist
*/
   GR_ITEM_EXPLOSION_PROP_PKG.Check_Primary_Key
                  (p_organization_id,
                   p_paste_to_item,
                   l_called_by_form,
                   l_rowid,
                   l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
--      RAISE Paste_Item_Exists_Error;
      /*
      ** Now get the from info and write the to info
      **
      ** Item General -- data is already there from the earlier
      ** cursor read
      */
      l_code_block := ' table - Update gr_item_explosion_properties';
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      /*
      ** Check the copy from item exists.
      */
      OPEN c_get_item_general_rowid;
      FETCH c_get_item_general_rowid INTO LocalPItemRecord;
      CLOSE c_get_item_general_rowid;

      GR_ITEM_EXPLOSION_PROP_PKG.Update_Row
	   			    (l_commit,
				     l_called_by_form,
                     LocalPItemRecord.rowid,
				     LocalItemRecord.ingredient_flag,
				     LocalItemRecord.explode_ingredient_flag,
				     p_organization_id,
				     p_paste_to_item,
				     LocalItemRecord.actual_hazard,
				     l_user_id,
				     l_current_date,
				     l_user_id,
				     l_current_date,
				     l_user_id,
				     l_return_status,
				     l_oracle_error,
				     l_msg_data);

     IF l_return_status <> 'S' THEN
        RAISE Update_Rows_Error;
     END IF;

   ELSE
      /*
      ** Now get the from info and write the to info
      **
      ** Item General -- data is already there from the earlier
      ** cursor read
      */
      l_code_block := ' table - Insert gr_item_explosion_properties';
      GR_ITEM_EXPLOSION_PROP_PKG.Insert_Row
	   			    (l_commit,
				     l_called_by_form,
				     LocalItemRecord.ingredient_flag,
				     LocalItemRecord.explode_ingredient_flag,
				     p_organization_id,
				     p_paste_to_item,
				     LocalItemRecord.actual_hazard,
				     l_user_id,
				     l_current_date,
				     l_user_id,
				     l_current_date,
				     l_user_id,
                     l_rowid,
				     l_return_status,
				     l_oracle_error,
				     l_msg_data);

     IF l_return_status <> 'S' THEN
        RAISE Insert_Rows_Error;
     END IF;
   END IF;
/*
** Item Properties
*/
   OPEN c_get_item_properties;
   FETCH c_get_item_properties INTO LocalItemPropRecord;
   IF c_get_item_properties%FOUND THEN
      WHILE c_get_item_properties%FOUND LOOP
         l_code_block := ' table - gr_inv_item_properties ';
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         /*B1319565 Added for Technical Parameters */

         OPEN c_get_item_properties_rowid (LocalItemPropRecord.label_code,
		                                   LocalItemPropRecord.property_id,
										   LocalItemPropRecord.sequence_number);
         FETCH c_get_item_properties_rowid INTO LocalPItemPropRecord;
         IF c_get_item_properties_rowid%NOTFOUND THEN
            l_code_block := ' Insert table - gr_inv_item_properties ';
            GR_INV_ITEM_PROPERTIES_PKG.Insert_Row
         	   			 (l_commit,
				          l_called_by_form,
				          p_organization_id,
				          p_paste_to_item,
				          LocalItemPropRecord.sequence_number,
     				      LocalItemPropRecord.property_id,
				          LocalItemPropRecord.label_code,
				          LocalItemPropRecord.number_value,
				          LocalItemPropRecord.alpha_value,
				          LocalItemPropRecord.date_value,
				          l_user_id,
				          l_current_date,
				          l_user_id,
				          l_current_date,
				          l_user_id,
				          l_rowid,
				          l_return_status,
				          l_oracle_error,
				          l_msg_data);

            IF l_return_status <> 'S' THEN
               RAISE Insert_Rows_Error;
            END IF;
         ELSE
            l_code_block := ' Update table - gr_inv_item_properties ';
            GR_INV_ITEM_PROPERTIES_PKG.Update_Row
         	   			 (l_commit,
				          l_called_by_form,
				          LocalPItemPropRecord.rowid,
				          p_organization_id,
				          p_paste_to_item,
				          LocalItemPropRecord.sequence_number,
     				      LocalItemPropRecord.property_id,
				          LocalItemPropRecord.label_code,
				          LocalItemPropRecord.number_value,
				          LocalItemPropRecord.alpha_value,
				          LocalItemPropRecord.date_value,
				          l_user_id,
				          l_current_date,
				          l_user_id,
				          l_current_date,
				          l_user_id,
				          l_return_status,
				          l_oracle_error,
				          l_msg_data);

            IF l_return_status <> 'S' THEN
               RAISE Update_Rows_Error;
            END IF;
         END IF;
         CLOSE c_get_item_properties_rowid;
         FETCH c_get_item_properties INTO LocalItemPropRecord;
      END LOOP;
   END IF;
   CLOSE c_get_item_properties;

EXCEPTION

   WHEN Item_Null_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_PRINT_ITEM_NULL');
      APP_EXCEPTION.Raise_Exception;

   WHEN Invalid_Item_Code THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_INVALID_ITEM_CODE');
	   FND_MESSAGE.SET_TOKEN('CODE',
	                        l_copy_item,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN Paste_Item_Exists_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_RECORD_EXISTS');
	   FND_MESSAGE.SET_TOKEN('CODE',
	                        l_paste_item,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN Insert_Rows_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_NO_RECORD_INSERTED');
	   FND_MESSAGE.SET_TOKEN('CODE',
	                        l_code_block,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN Update_Rows_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_NO_RECORD_INSERTED');
	   FND_MESSAGE.SET_TOKEN('CODE',
	                        l_code_block,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN OTHERS THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;

END paste_item_safety;

PROCEDURE delete_item_safety
				(p_delete_item IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)

 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_ROWID           VARCHAR2(18);
L_CALLED_BY_FORM  VARCHAR2(1) := 'F';
L_KEY_EXISTS      VARCHAR2(1);
L_DELETE_OPTION   VARCHAR2(1);
L_COMMIT          VARCHAR2(1) := 'F';
L_MSG_DATA        VARCHAR2(2000);
L_RETURN_STATUS   VARCHAR2(1);

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;


/*
**    Exceptions
*/
ITEM_NULL_ERROR         EXCEPTION;
INVALID_ITEM_ERROR      EXCEPTION;
CANNOT_LOCK_ITEM_ERROR  EXCEPTION;
OTHER_API_ERROR         EXCEPTION;

/*
** Cursors
**
** Get the item general information
*/
CURSOR c_get_item_general
 IS
   SELECT      ig1.ROWID,
               ig1.item_group_code,
				   ig1.primary_cas_number,
				   ig1.ingredient_flag,
				   ig1.explode_ingredient_flag,
				   ig1.formula_source_indicator,
				   ig1.user_id,
				   ig1.internal_reference_number,
				   ig1.product_label_code,
				   ig1.version_code,
				   ig1.last_version_code,
				   ig1.product_class,
				   ig1.item_code,
				   ig1.actual_hazard,
				   ig1.print_ingredient_phrases_flag,
				   ig1.attribute_category,
				   ig1.attribute1,
				   ig1.attribute2,
				   ig1.attribute3,
				   ig1.attribute4,
				   ig1.attribute5,
				   ig1.attribute6,
				   ig1.attribute7,
				   ig1.attribute8,
				   ig1.attribute9,
				   ig1.attribute10,
				   ig1.attribute11,
				   ig1.attribute12,
				   ig1.attribute13,
				   ig1.attribute14,
				   ig1.attribute15,
				   ig1.attribute16,
				   ig1.attribute17,
				   ig1.attribute18,
				   ig1.attribute19,
				   ig1.attribute20,
				   ig1.attribute21,
				   ig1.attribute22,
				   ig1.attribute23,
				   ig1.attribute24,
				   ig1.attribute25,
				   ig1.attribute26,
				   ig1.attribute27,
				   ig1.attribute28,
				   ig1.attribute29,
				   ig1.attribute30,
				   ig1.created_by,
				   ig1.creation_date,
				   ig1.last_updated_by,
				   ig1.last_update_date,
				   ig1.last_update_login
   FROM        gr_item_general ig1
   WHERE       ig1.item_code = p_delete_item;
LocalItemRecord            c_get_item_general%ROWTYPE;
/*
** Get the EMEA row
*/
CURSOR c_get_item_emea
 IS
	SELECT     em.ROWID,
				  em.item_code,
				  em.european_index_number,
				  em.eec_number,
				  em.consolidated_risk_phrase,
				  em.consolidated_safety_phrase,
				  em.approved_supply_list_conc,
				  em.attribute_category,
				  em.attribute1,
				  em.attribute2,
				  em.attribute3,
				  em.attribute4,
				  em.attribute5,
				  em.attribute6,
				  em.attribute7,
				  em.attribute8,
				  em.attribute9,
				  em.attribute10,
				  em.attribute11,
				  em.attribute12,
				  em.attribute13,
				  em.attribute14,
				  em.attribute15,
				  em.attribute16,
				  em.attribute17,
				  em.attribute18,
				  em.attribute19,
				  em.attribute20,
				  em.attribute21,
				  em.attribute22,
				  em.attribute23,
				  em.attribute24,
				  em.attribute25,
				  em.attribute26,
				  em.attribute27,
				  em.attribute28,
				  em.attribute29,
				  em.attribute30,
				  em.created_by,
				  em.creation_date,
				  em.last_updated_by,
				  em.last_update_date,
				  em.last_update_login
   FROM       gr_emea em
   WHERE      em.item_code = p_delete_item;
LocalEmeaRecord            c_get_item_emea%ROWTYPE;

BEGIN

   l_code_block := NULL;
/*
** Check the entered item code is not null
*/
   IF p_delete_item IS NULL THEN
      RAISE Item_Null_Error;
   END IF;
/*
** Check the item exists
*/
   OPEN c_get_item_general;
   FETCH c_get_item_general INTO LocalItemRecord;
   IF c_get_item_general%NOTFOUND THEN
      CLOSE c_get_item_general;
      RAISE Invalid_Item_Error;
   ELSE
      CLOSE c_get_item_general;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
	GR_ITEM_GENERAL_PKG.Lock_Row
	   			 (l_commit,
				     l_called_by_form,
				     LocalItemRecord.ROWID,
				     LocalItemRecord.item_group_code,
				     LocalItemRecord.primary_cas_number,
				     LocalItemRecord.ingredient_flag,
				     LocalItemRecord.explode_ingredient_flag,
				     LocalItemRecord.formula_source_indicator,
				     LocalItemRecord.user_id,
				     LocalItemRecord.internal_reference_number,
				     LocalItemRecord.product_label_code,
				     LocalItemRecord.version_code,
				     LocalItemRecord.last_version_code,
				     LocalItemRecord.product_class,
				     LocalItemRecord.item_code,
				     LocalItemRecord.actual_hazard,
				     LocalItemRecord.print_ingredient_phrases_flag,
				     LocalItemRecord.attribute_category,
				     LocalItemRecord.attribute1,
				     LocalItemRecord.attribute2,
				     LocalItemRecord.attribute3,
				     LocalItemRecord.attribute4,
				     LocalItemRecord.attribute5,
				     LocalItemRecord.attribute6,
				     LocalItemRecord.attribute7,
				     LocalItemRecord.attribute8,
				     LocalItemRecord.attribute9,
				     LocalItemRecord.attribute10,
				     LocalItemRecord.attribute11,
				     LocalItemRecord.attribute12,
				     LocalItemRecord.attribute13,
				     LocalItemRecord.attribute14,
				     LocalItemRecord.attribute15,
				     LocalItemRecord.attribute16,
				     LocalItemRecord.attribute17,
				     LocalItemRecord.attribute18,
				     LocalItemRecord.attribute19,
				     LocalItemRecord.attribute20,
				     LocalItemRecord.attribute21,
				     LocalItemRecord.attribute22,
				     LocalItemRecord.attribute23,
				     LocalItemRecord.attribute24,
				     LocalItemRecord.attribute25,
				     LocalItemRecord.attribute26,
				     LocalItemRecord.attribute27,
				     LocalItemRecord.attribute28,
				     LocalItemRecord.attribute29,
				     LocalItemRecord.attribute30,
				     LocalItemRecord.created_by,
				     LocalItemRecord.creation_date,
				     LocalItemRecord.last_updated_by,
				     LocalItemRecord.last_update_date,
				     LocalItemRecord.last_update_login,
				     l_return_status,
				     l_oracle_error,
				     l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Cannot_Lock_Item_Error;
   END IF;
/*
** Main row locked ok, now delete the subsidiary tables
*/
   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_OTHER_NAMES_TL_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_MULTILINGUAL_NAME_TL_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_SAFETY_PHRASES_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_RISK_PHRASES_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_RIGHT_TO_KNOW_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_item,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_SAFETY.Delete_item_document
                  (p_delete_item,
                   '',
			 l_delete_option,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_CLASSNS_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_DISCLOSURES_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_item,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_CONC_DETAILS_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_item,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_CONCENTRATIONS_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_item,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_PROPERTIES_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_TOXIC_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   '',
                   '',
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'I';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_EXPOSURE_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   '',
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'G';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_GENERIC_ML_NAME_TL_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_delete_option := 'G';
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_GENERIC_ITEMS_B_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   l_delete_option,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;
/*
** Clear the EMEA row
*/
   OPEN c_get_item_emea;
   FETCH c_get_item_emea INTO LocalEmeaRecord;
   IF c_get_item_emea%NOTFOUND THEN
      CLOSE c_get_item_emea;
   ELSE
      CLOSE c_get_item_emea;

      l_return_status := FND_API.G_RET_STS_SUCCESS;
      GR_EMEA_PKG.Delete_Row
	   			 (l_commit,
				     l_called_by_form,
				     LocalEmeaRecord.ROWID,
				     LocalEmeaRecord.item_code,
				     LocalEmeaRecord.european_index_number,
				     LocalEmeaRecord.eec_number,
				     LocalEmeaRecord.consolidated_risk_phrase,
				     LocalEmeaRecord.consolidated_safety_phrase,
				     LocalEmeaRecord.approved_supply_list_conc,
				     LocalEmeaRecord.attribute_category,
				     LocalEmeaRecord.attribute1,
				     LocalEmeaRecord.attribute2,
				     LocalEmeaRecord.attribute3,
				     LocalEmeaRecord.attribute4,
				     LocalEmeaRecord.attribute5,
				     LocalEmeaRecord.attribute6,
				     LocalEmeaRecord.attribute7,
				     LocalEmeaRecord.attribute8,
				     LocalEmeaRecord.attribute9,
				     LocalEmeaRecord.attribute10,
				     LocalEmeaRecord.attribute11,
				     LocalEmeaRecord.attribute12,
				     LocalEmeaRecord.attribute13,
				     LocalEmeaRecord.attribute14,
				     LocalEmeaRecord.attribute15,
				     LocalEmeaRecord.attribute16,
				     LocalEmeaRecord.attribute17,
				     LocalEmeaRecord.attribute18,
				     LocalEmeaRecord.attribute19,
				     LocalEmeaRecord.attribute20,
				     LocalEmeaRecord.attribute21,
				     LocalEmeaRecord.attribute22,
				     LocalEmeaRecord.attribute23,
				     LocalEmeaRecord.attribute24,
				     LocalEmeaRecord.attribute25,
				     LocalEmeaRecord.attribute26,
				     LocalEmeaRecord.attribute27,
				     LocalEmeaRecord.attribute28,
				     LocalEmeaRecord.attribute29,
				     LocalEmeaRecord.attribute30,
				     LocalEmeaRecord.created_by,
				     LocalEmeaRecord.creation_date,
				     LocalEmeaRecord.last_updated_by,
				     LocalEmeaRecord.last_update_date,
				     LocalEmeaRecord.last_update_login,
				     l_return_status,
				     l_oracle_error,
				     l_msg_data);

      IF l_return_status <> 'S' THEN
         RAISE Other_API_ERROR;
      END IF;
   END IF;
/*
** Delete the item general row
*/
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_GENERAL_PKG.Delete_Row
	   			 (l_commit,
				     l_called_by_form,
				     LocalItemRecord.ROWID,
				     LocalItemRecord.item_group_code,
				     LocalItemRecord.primary_cas_number,
				     LocalItemRecord.ingredient_flag,
				     LocalItemRecord.explode_ingredient_flag,
				     LocalItemRecord.formula_source_indicator,
				     LocalItemRecord.user_id,
				     LocalItemRecord.internal_reference_number,
				     LocalItemRecord.product_label_code,
				     LocalItemRecord.version_code,
				     LocalItemRecord.last_version_code,
				     LocalItemRecord.product_class,
				     LocalItemRecord.item_code,
				     LocalItemRecord.actual_hazard,
				     LocalItemRecord.print_ingredient_phrases_flag,
				     LocalItemRecord.attribute_category,
				     LocalItemRecord.attribute1,
				     LocalItemRecord.attribute2,
				     LocalItemRecord.attribute3,
				     LocalItemRecord.attribute4,
				     LocalItemRecord.attribute5,
				     LocalItemRecord.attribute6,
				     LocalItemRecord.attribute7,
				     LocalItemRecord.attribute8,
				     LocalItemRecord.attribute9,
				     LocalItemRecord.attribute10,
				     LocalItemRecord.attribute11,
				     LocalItemRecord.attribute12,
				     LocalItemRecord.attribute13,
				     LocalItemRecord.attribute14,
				     LocalItemRecord.attribute15,
				     LocalItemRecord.attribute16,
				     LocalItemRecord.attribute17,
				     LocalItemRecord.attribute18,
				     LocalItemRecord.attribute19,
				     LocalItemRecord.attribute20,
				     LocalItemRecord.attribute21,
				     LocalItemRecord.attribute22,
				     LocalItemRecord.attribute23,
				     LocalItemRecord.attribute24,
				     LocalItemRecord.attribute25,
				     LocalItemRecord.attribute26,
				     LocalItemRecord.attribute27,
				     LocalItemRecord.attribute28,
				     LocalItemRecord.attribute29,
				     LocalItemRecord.attribute30,
				     LocalItemRecord.created_by,
				     LocalItemRecord.creation_date,
				     LocalItemRecord.last_updated_by,
				     LocalItemRecord.last_update_date,
				     LocalItemRecord.last_update_login,
				     l_return_status,
				     l_oracle_error,
				     l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

EXCEPTION

   WHEN Item_Null_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_code_block,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN Invalid_Item_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_INVALID_ITEM_CODE');
	   FND_MESSAGE.SET_TOKEN('CODE',
	                         p_delete_item,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN Cannot_Lock_Item_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_code_block,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN OTHER_API_ERROR THEN
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_msg_data,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN OTHERS THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_code_block,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

END delete_item_safety;

PROCEDURE delete_item_document
				(p_delete_item IN VARCHAR2,
                         p_document_code IN VARCHAR2,
                         p_delete_option IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_ROWID           VARCHAR2(18);
L_CALLED_BY_FORM  VARCHAR2(1) := 'F';
L_KEY_EXISTS      VARCHAR2(1);
L_COMMIT          VARCHAR2(1) := 'F';
L_MSG_DATA        VARCHAR2(2000);
L_RETURN_STATUS   VARCHAR2(1);

/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;


/*
**    Exceptions
*/
ITEM_NULL_ERROR         EXCEPTION;
OTHER_API_ERROR         EXCEPTION;

/*
** Get the document print header information
*/
CURSOR c_get_document_print
 IS
   SELECT      dp.document_text_id
   FROM        gr_document_print dp
   WHERE       dp.item_code = p_delete_item
     AND	   (p_document_code IS NULL OR
               dp.document_code = p_document_code);
LocalDocumentPrint      c_get_document_print%ROWTYPE;

BEGIN

   l_code_block := NULL;
/*
** Check the entered item code is not null
*/
   IF p_delete_item IS NULL THEN
      RAISE Item_Null_Error;
   END IF;


   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_DOCUMENT_DTLS_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_option,
                   p_delete_item,
                   p_document_code,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_ITEM_DOC_STATUSES_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_option,
                   p_delete_item,
                   p_document_code,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_ERROR;
   END IF;

/*
** Delete from dispatch history
*/
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_DISPATCH_HISTORIES_PKG.Delete_Rows
                  (l_commit,
                   l_called_by_form,
                   p_delete_option,
                   p_document_code,
                   p_delete_item,
                   '',
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);
/*
** Delete from document print tables.
*/
   OPEN c_get_document_print;
   FETCH c_get_document_print INTO LocalDocumentPrint;
   IF c_get_document_print%FOUND THEN
      WHILE c_get_document_print%FOUND LOOP
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         GR_DOCUMENT_DETAILS_PKG.Delete_Rows
                            (l_commit,
                             l_called_by_form,
                             LocalDocumentPrint.document_text_id,
                             l_return_status,
                             l_oracle_error,
                             l_msg_data);
         IF l_return_status <> 'S' THEN
            RAISE Other_API_Error;
         END IF;

         FETCH c_get_document_print INTO LocalDocumentPrint;
      END LOOP;
   END IF;
   CLOSE c_get_document_print;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   GR_DOCUMENT_PRINT_PKG.Delete_Rows
                    (l_commit,
                     l_called_by_form,
                     p_delete_option,
                     p_document_code,
                     p_delete_item,
                     '',
                     '',
                     l_return_status,
                     l_oracle_error,
                     l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_Error;

   END IF;

EXCEPTION

   WHEN Item_Null_Error THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_code_block,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN OTHER_API_ERROR THEN
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_msg_data,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

   WHEN OTHERS THEN
      l_oracle_error := APP_EXCEPTION.Get_Code;
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_code_block,
	                         FALSE);
      APP_EXCEPTION.Raise_Exception;

END delete_item_document;

END GR_ITEM_SAFETY;

/
