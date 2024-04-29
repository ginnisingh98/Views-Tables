--------------------------------------------------------
--  DDL for Package Body GR_ITEM_PROPERTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ITEM_PROPERTIES_PUB" AS
/*  $Header: GRPIITPB.pls 120.6.12010000.2 2009/06/19 16:20:36 plowe noship $
 *****************************************************************
 *                                                               *
 * Package  GR_ITEM_PROPERTIES_PUB                               *
 *                                                               *
 * Contents ITEM_PROPERTIES                                      *
 *                                                               *
 *                                                               *
 * Use      This is the public layer for the ITEM_PROPERTIES     *
 *          API                                                  *
 *                                                               *
 * History                                                       *
 *         Written by P A Lowe OPM Unlimited Dev                 *
 * Peter Lowe  07/03/08                                          *
 *                                                               *
 * Updated By              For                                   *
 *                                                               *
 * 		                                                           *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GR_ITEM_PROPERTIES_PUB';

--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
  l_debug VARCHAR2(1):= 'N';
  BEGIN
   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     l_debug := 'Y';
   END IF;
   l_debug := 'Y';
   RETURN l_debug;
  END set_debug_flag;
PROCEDURE ITEM_PROPERTIES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_item_properties_tab  IN  GR_ITEM_PROPERTIES_PUB.gr_item_properties_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)

IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'ITEM_PROPERTIES';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_msg_count             NUMBER  :=0;
  l_debug_flag VARCHAR2(1) := set_debug_flag;

  l_missing_count   NUMBER;

	l_action     VARCHAR2(1);
	l_organization VARCHAR2(3);
	l_organization_id NUMBER;
	l_item VARCHAR2(40);
	l_inventory_item_id NUMBER;
	l_field_name_code VARCHAR2(5);
	l_property_id varchar2(6);
	l_numeric_value NUMBER(15,9);  -- 8208515   increased decimal precision from 6 to 9.
	l_alpha_value VARCHAR2(240);
	l_phrase_code VARCHAR2(15);
	l_phrase_code2 VARCHAR2(15);
	l_date_value date;
	l_language_code VARCHAR2(4);
	l_sequence_number NUMBER;

  lv_organization VARCHAR2(3);
  lv_organization_id NUMBER;
  lv_inventory_item_id NUMBER;
  lv_date date;

  l_message1 VARCHAR2(240);

  l_LENGTH NUMBER;
  l_PRECISION NUMBER;
  l_range_min NUMBER;
  l_range_max NUMBER;

  l_calc_PRECISION NUMBER;
  l_last_update_login NUMBER(15,0) := 0;
  L_KEY_EXISTS 	VARCHAR2(1);
  l_property_type_indicator VARCHAR2(1) := NULL;
  l_form_block VARCHAR2(14);

  dummy              NUMBER;
  i   							 NUMBER;
  row_id        VARCHAR2(18);
  return_status VARCHAR2(1);
  oracle_error  NUMBER;
  msg_data      VARCHAR2(2000);

  L_ORACLE_ERROR		NUMBER;
  L_CODE_BLOCK		VARCHAR2(2000);


  loop_exception EXCEPTION;

-- Cursor Definitions
cursor c_get_org_id is
SELECT    organization_id INTO l_organization_id
          FROM mtl_organizations
          WHERE organization_code = l_organization;

cursor c_get_item_id is
SELECT inventory_item_id into l_inventory_item_id
       FROM mtl_system_items_b_kfv
       WHERE concatenated_segments = l_item
			 AND organization_id = l_organization_id;

cursor c_hazardous_material_flag is
SELECT 1
 FROM mtl_system_items_b
       WHERE inventory_item_id = l_inventory_item_id
       AND organization_id = l_organization_id
       AND hazardous_material_flag = 'Y';

CURSOR c_get_field_name is
SELECT 1
FROM
GR_LABELS_B B
    where B.LABEL_CODE = l_field_name_code;

cursor c_val_fname is
SELECT lcb.form_block
FROM
GR_LABELS_B B , gr_label_classes_b lcb
    where B.LABEL_CODE = l_field_name_code and
    lcb.label_class_code = b.label_class_code
    and lcb.form_block in ('SAFETY_PHRASES', 'RISK_PHRASES' );

CURSOR c_get_safety_phrase_code IS
  SELECT safety_phrase_code
  FROM	gr_safety_phrases_vl
  WHERE	safety_phrase_code = l_phrase_code;

CURSOR c_get_risk_phrase_code IS
  SELECT risk_phrase_code
  FROM	gr_risk_phrases_vl
  WHERE	risk_phrase_code = l_phrase_code;
riskcode			c_get_risk_phrase_code%ROWTYPE;

CURSOR c_get_item_safety_phrase IS
  SELECT safety_phrase_code
  FROM	gr_inv_item_safety_phrases
  WHERE	safety_phrase_code = l_phrase_code
  and organization_id = l_organization_id
  and inventory_item_id = l_inventory_item_id;
item_safetycode			c_get_item_safety_phrase%ROWTYPE;

CURSOR c_get_item_risk_phrase IS
  SELECT risk_phrase_code
  FROM	gr_inv_item_risk_phrases
  WHERE	risk_phrase_code = l_phrase_code
  and organization_id = l_organization_id
  and inventory_item_id = l_inventory_item_id;
item_riskcode			c_get_item_risk_phrase%ROWTYPE;

CURSOR Cur_get_seq_no IS
SELECT lp.sequence_number
FROM	gr_label_properties lp
WHERE  lp.label_code = l_field_name_code
AND    lp.property_id = l_property_id;

CURSOR c_get_property_id is
SELECT 1
FROM
GR_PROPERTIES_B B
    where B.PROPERTY_ID = l_property_id;

CURSOR c_get_property_flag is
SELECT property_type_indicator,
LENGTH,
PRECISION,
range_min,
range_max
FROM
GR_PROPERTIES_B B
    where B.PROPERTY_ID = l_property_id;

cursor c_get_PROPERTY_values is
select 1
from GR_PROPERTY_values_TL
WHERE property_id  = l_property_id
and language = l_language_code
and value = l_alpha_value;


L_MSG_TOKEN       VARCHAR2(100);


BEGIN

  /*  Standard call to check for call compatibility.  */

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_int_msg_list is set TRUE.   */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --   Initialize API return Parameters
  gmd_debug.log_initialize('euro trash');
  x_return_status   := FND_API.G_RET_STS_SUCCESS;

-- IF (l_debug = 'Y') THEN
--    gmd_debug.log_initialize('GR ITEM_PROPERTIES API');
-- END IF;

FOR i IN 1 .. p_item_properties_tab.count LOOP


BEGIN

			  l_action := p_item_properties_tab(i).action;
				l_organization := p_item_properties_tab(i).organization;
				l_organization_id := p_item_properties_tab(i).organization_id;
				l_item := p_item_properties_tab(i).item;
				l_inventory_item_id  := p_item_properties_tab(i).inventory_item_id;
				l_field_name_code := p_item_properties_tab(i).field_name_code;
				l_property_id := p_item_properties_tab(i).property_id;
				l_numeric_value := p_item_properties_tab(i).numeric_value;
				l_alpha_value := p_item_properties_tab(i).alpha_value;
				l_phrase_code := p_item_properties_tab(i).phrase_code;
				l_date_value := p_item_properties_tab(i).date_value;
				l_language_code := p_item_properties_tab(i).language_code;


        IF l_action is NULL or l_action not in ('I','D','U')  then
						FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_ACTION');
           	RAISE loop_exception;
				END IF;

			  IF l_organization is NULL and l_organization_id is NULL then
			    l_msg_token := 'organization or organization_id';
			    --GMD_API_PUB.Log_Message('GR_NULL_VALUE');
			    FND_MESSAGE.SET_NAME('GR',
			                           'GR_NULL_VALUE');
			    FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
     	    RAISE loop_exception;
			  END IF;

        IF l_organization is not NULL then

           OPEN c_get_org_id;
	         FETCH c_get_org_id into lv_organization_id;
					 IF c_get_org_id%NOTFOUND THEN
					    CLOSE c_get_org_id;
			        l_msg_token := l_organization;
			        FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      				FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
             RAISE loop_exception;
			     END IF;
			     l_organization_id := lv_organization_id;
           CLOSE c_get_org_id;

        END IF; --  IF l_organization is not NULL then

        IF l_item is NULL and l_inventory_item_id is NULL then
			    GMD_API_PUB.Log_Message('GR_INVALID_ITEM');
			    l_msg_token := l_item;
			    FND_MESSAGE.SET_NAME('GR',
			                           'GR_INVALID_ITEM');
			    FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,FALSE);
         RAISE loop_exception;
			  END IF; --  IF l_item is NULL and l_inventory_item_id is NULL then

        IF l_item is not NULL then

           OPEN c_get_item_id;
	         FETCH c_get_item_id into l_inventory_item_id;
					 IF c_get_org_id%NOTFOUND THEN

			        CLOSE c_get_item_id;
			        l_msg_token := l_item;
			        FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      				FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
            	RAISE loop_exception;
			     END IF;
           CLOSE c_get_item_id;

        END IF; --  IF l_item is not NULL then

        IF l_inventory_item_id is not NULL then

           OPEN c_hazardous_material_flag;
	         FETCH c_hazardous_material_flag into dummy;
					 IF c_hazardous_material_flag%NOTFOUND THEN

			        CLOSE c_hazardous_material_flag;
			        l_msg_token := l_item;
			        FND_MESSAGE.SET_NAME('GR',
                           'GR_NOT_REG_ITEM');
      				FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      		    RAISE loop_exception;
			     END IF;
           CLOSE c_hazardous_material_flag;

        END IF; --   IF l_inventory_item_id is not NULL then


       IF l_field_name_code is NULL then
    				 --GMD_API_PUB.Log_Message('GR_NULL_VALUE');
    				 l_msg_token := l_field_name_code;
             FND_MESSAGE.SET_NAME('GR',
				               'GR_NULL_VALUE');
				     FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
				  RAISE loop_exception;
       END IF;


      -- 	Validate that the value of Field Name code exists in the table GR_LABELS_B.
      -- If it does not, write an error to the log file

        OPEN c_get_field_name;
				FETCH c_get_field_name INTO dummy;
				IF c_get_field_name%NOTFOUND THEN
				  l_msg_token := l_field_name_code;
	        CLOSE c_get_field_name;
	         FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      		 FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
           RAISE loop_exception;
	      END IF;
			  CLOSE c_get_field_name;

        -- check if valid property id


        IF l_property_id is not null then
			        dummy:= 0;
			        OPEN c_get_property_id;
			        FETCH c_get_property_id INTO dummy;
							IF c_get_property_id%NOTFOUND THEN
							     l_msg_token := l_property_id;
					        CLOSE c_get_property_id;
					        FND_MESSAGE.SET_NAME('GR',
			                           'GR_RECORD_NOT_FOUND');
			     			  FND_MESSAGE.SET_TOKEN('CODE',
			         		            l_msg_token,
			            			    FALSE);
			            RAISE loop_exception;
					    END IF;
					    CLOSE c_get_property_id;


              OPEN Cur_get_seq_no;
						  FETCH Cur_get_seq_no INTO l_sequence_number;
							IF Cur_get_seq_no%NOTFOUND THEN
								  l_msg_token := l_field_name_code || ' ' || l_property_id;
								  CLOSE Cur_get_seq_no;
							    FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
     							FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
     							RAISE loop_exception;

           		END IF;
						  CLOSE Cur_get_seq_no;

		    END IF; --  IF l_property_id is not null then


        IF l_action <> 'D' then  -- validate inputs for I   and U

          IF l_property_id is NULL  then
             IF l_action = 'I' then   -- not valid for U action
			        		 OPEN c_val_fname;
						       FETCH c_val_fname INTO l_form_block;
									 IF c_val_fname%NOTFOUND THEN
									    close c_val_fname;
											FND_MESSAGE.SET_NAME('GR',
							               'GR_FNAME_NOT_ASSOC_PHRASE');
							 			  RAISE loop_exception;
							     END IF;
			       		   close c_val_fname;
       		  END IF; -- IF l_action = 'I' then   -- not valid for U action



          END IF; -- IF l_property_id is NULL then


         IF l_property_id is not NULL then

           OPEN c_get_property_flag;
	         FETCH c_get_property_flag INTO l_property_type_indicator,
		        l_LENGTH,
  					l_PRECISION,
  					l_range_min,
  					l_range_max;
				   IF c_get_property_flag%NOTFOUND THEN

			        CLOSE c_get_property_flag;
			        l_msg_token := l_property_id || ' F';
  						RAISE loop_exception;
			     END IF;
           close c_get_property_flag;

         END IF;   -- IF l_property_id is not NULL then

         --Property Type phrase is not used anymore.
         IF (l_property_type_indicator = 'P') THEN
           l_alpha_value := NULL;
           l_msg_token := ' phrase code';
           FND_MESSAGE.SET_NAME('GR','GR_PROPERTY_IND_INVALID');
           FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
           RAISE loop_exception;
         END IF;

           -- If the property is of type Safety Phrase or the field name is
           -- associated to a field name class using the Safety Phrases form block,
           IF (l_property_type_indicator = 'S' or l_form_block = 'SAFETY_PHRASES' )  and l_action = 'I' THEN   -- not valid for U action

             --  If the value for Phrase Code is null, an error message will be written to the log file.
             IF l_phrase_code is null then
                l_msg_token := ' phrase code';
                FND_MESSAGE.SET_NAME('GR',
				               'GR_NULL_VALUE');
				        FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
							  RAISE loop_exception;
             END IF; -- IF l_phrase_code is null then

             -- Validate the value for phrase code against the GR_SAFETY_PHRASES_VL.
             -- An error message will be written to the log file if the value is invalid

							  OPEN c_get_safety_phrase_code;
							  FETCH c_get_safety_phrase_code INTO l_phrase_code2;
								IF c_get_safety_phrase_code%NOTFOUND THEN
								  l_msg_token := l_phrase_code;
								  CLOSE c_get_safety_phrase_code;
							    FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
     							FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
     							 RAISE loop_exception;
             		END IF;
							 CLOSE c_get_safety_phrase_code;
           END IF;   -- IF l_property_type_indicator = 'S' or l_form_block = 'SAFETY_PHRASES' and l_action = 'I' THEN

          --	If the property is of type Risk Phrase
          -- or the field name is associated to a field name class using the Risk Phrases form block,
           IF (l_property_type_indicator = 'R' or l_form_block = 'RISK_PHRASES' ) and l_action = 'I' THEN   -- not valid for U action

             --  If the value for Phrase Code is null, an error message will be written to the log file.
             IF l_phrase_code is null then
                l_msg_token := ' phrase code';
                FND_MESSAGE.SET_NAME('GR',
				               'GR_NULL_VALUE');
				        FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
							  RAISE loop_exception;
             END IF; -- IF l_phrase_code is null then

             -- Validate the value for phrase code against the GR_RISK_PHRASES_VL.
             -- An error message will be written to the log file if the value is invalid
		         OPEN c_get_risk_phrase_code;
							  FETCH c_get_risk_phrase_code INTO riskcode;
								IF c_get_risk_phrase_code%NOTFOUND THEN
								  l_msg_token := l_phrase_code;
								  CLOSE c_get_risk_phrase_code;
							    FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
     							FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
     							 RAISE loop_exception;
             		END IF;
							 CLOSE c_get_risk_phrase_code;

           END IF;   -- IF l_property_type_indicator = 'R' or l_form_block = 'RISK_PHRASES' THEN

			    -- If the property is of type Numeric
         IF l_property_type_indicator = 'N' then

	            -- If the value for Numeric Value is null, an error message will be written to the log file.
	            IF l_numeric_value is NULL then
	               l_msg_token := ' numeric value';
	                FND_MESSAGE.SET_NAME('GR',
					               'GR_NULL_VALUE');
					        FND_MESSAGE.SET_TOKEN('TEXT',
	         		            l_msg_token,
	            			    FALSE);
								  RAISE loop_exception;
	            END IF; -- IF l_numeric_value is NULL then

	           -- Validate the value for Numeric Value against the property definition in the GR_PROPERTIES_B table.
					   -- An error message will be written to the log file if the value is invalid
					    --	Validate the value for Alphanumeric Value against the property definition in the GR_PROPERTIES_B table.
             -- Just the length   An error message will be written to the log file if the value is invalid
             IF (length(l_numeric_value) > l_length )  then
                --l_msg_token := l_length;
                FND_MESSAGE.SET_NAME('GR',
					               'GR_LENGTH_INVALID');
					       FND_MESSAGE.SET_TOKEN('LENGTH', l_length);

	              RAISE loop_exception;
             END IF;  -- IF (length(l_numeric_value) > l_length )  then


	           IF l_numeric_value > l_range_max or l_numeric_value < l_range_min then
	              FND_MESSAGE.SET_NAME('GR',
					               'GR_MIN_MAX_ERROR');
	              RAISE loop_exception;
	           END IF; -- IF l_numeric_value > l_range_max or l_numeric_value < l_range_min then


	           l_calc_precision := (length(l_numeric_value - trunc(l_numeric_value))) - 1;
	         --  IF l_calc_precision <> l_precision THEN --  01/15/09 7709185 replace with below
	           IF l_calc_precision > l_precision or l_calc_precision > 6   -- 8208515   table only will store up to 6 dec. places
	           THEN  --  01/15/09 7709185
	             FND_MESSAGE.SET_NAME('GR',
					               'GR_PRECISION_INVALID');
	             RAISE loop_exception;
	           END IF; -- IF l_calc_precision <> l_precision THEN

         ELSIF l_property_type_indicator = 'A' then
           --  If the value for Alphanumeric Value is null, an error message will be written to the log file
              IF l_alpha_value is NULL then
	               l_msg_token := ' alphanumeric value';
	                FND_MESSAGE.SET_NAME('GR',
					               'GR_NULL_VALUE');
					        FND_MESSAGE.SET_TOKEN('CODE',
	         		            l_msg_token,
	            			    FALSE);
								  RAISE loop_exception;
	            END IF; -- IF l_alpha_value is NULL then

             --	Validate the value for Alphanumeric Value against the property definition in the GR_PROPERTIES_B table.
             -- Just the length   An error message will be written to the log file if the value is invalid
             IF (length(l_alpha_value) > l_length )  then  --
                l_msg_token := (length(l_alpha_value));
                FND_MESSAGE.SET_NAME('GR',
					               'GR_LENGTH_INVALID');
					        FND_MESSAGE.SET_TOKEN('LENGTH', l_length);

	              RAISE loop_exception;
             END IF;  -- IF (length(l_alpha_value) > l_length )  then

           ELSIF l_property_type_indicator = 'D' then

           --  If the value for date Value is null, an error message will be written to the log file

              IF p_item_properties_tab(i).date_value  is NULL then
	               l_msg_token := ' date value';
	                FND_MESSAGE.SET_NAME('GR',
					               'GR_NULL_VALUE');
					        FND_MESSAGE.SET_TOKEN('CODE',
	         		            l_msg_token,
	            			    FALSE);
								  RAISE loop_exception;
	            END IF; -- IF l_date_value is NULL then

             -- Validate the format of the value for Date Value, converting to database format if necessary.
             -- An error message will be written to the log file if the value is invalid
              begin

              l_date_value := p_item_properties_tab(i).date_value;

							exception
							when others then
							   FND_MESSAGE.SET_NAME('GMA',
					       'SY_BAD_DATEFORMAT');
					    RAISE loop_exception;
							end;

           ELSIF l_property_type_indicator = 'F' then

           --  If the value for alphanumeric Value is null, an error message will be written to the log file
              IF l_alpha_value is NULL then
	               l_msg_token := ' alphanumeric value';
	                FND_MESSAGE.SET_NAME('GR',
					               'GR_NULL_VALUE');
					        FND_MESSAGE.SET_TOKEN('CODE',
	         		            l_msg_token,
	            			    FALSE);
								  RAISE loop_exception;
	            END IF; -- IF l_alpha_value is NULL then

			       dummy:= 0;
						 OPEN c_get_PROPERTY_values;
			       FETCH c_get_PROPERTY_values INTO dummy;
						 IF c_get_PROPERTY_values%NOTFOUND THEN
						    close c_get_PROPERTY_values;
								FND_MESSAGE.SET_NAME('GR',
				               'GR_ALPHA_INVALID');
				       	FND_MSG_PUB.ADD;
							  RAISE loop_exception;
				     END IF;
				     close c_get_PROPERTY_values;

           END IF;  --   IF l_property_type_indicator = 'N' then
         -- END IF;  -- IF l_property_id is not NULL then

        END IF;  -- IF l_action <> 'D' then

 -- below is to check if the field name is associated to a field name class using the Safety or Risk Phrases form block

      IF l_action = 'I' then
             OPEN c_val_fname;
		       FETCH c_val_fname INTO l_form_block;
					 IF c_val_fname%NOTFOUND THEN
					    null;
					 END IF;
		 		   close c_val_fname;

           -- If the field name is associated to a field name class using the Safety Phrases form block
            -- validate that the record does not already exist, and insert the record into the GR_INV_ITEM_SAFETY_PHRASES table
            -- An error message will be written to the log file if the record already exists
           IF l_form_block = 'SAFETY_PHRASES' THEN

             dummy:= 0;
             -- Validate the value for phrase code against the GR_SAFETY_PHRASES_VL.
             -- An error message will be written to the log file if the value is invalid

							  OPEN c_get_safety_phrase_code;
							  FETCH c_get_safety_phrase_code INTO l_phrase_code2;
							IF c_get_safety_phrase_code%NOTFOUND THEN
							  l_msg_token := l_phrase_code;
							  CLOSE c_get_safety_phrase_code;
							  FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
     							  FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
     							   RAISE loop_exception;
             		                                 END IF;
							 CLOSE c_get_safety_phrase_code;

 				  	 OPEN c_get_item_safety_phrase;
	        	 FETCH c_get_item_safety_phrase INTO l_phrase_code2;
						 IF c_get_item_safety_phrase%FOUND THEN

					      CLOSE c_get_item_safety_phrase;
			        	l_msg_token := l_phrase_code;
			        	FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
    						FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
			        	RAISE loop_exception;
			    	 END IF;
             CLOSE c_get_item_safety_phrase;


	          INSERT INTO GR_INV_ITEM_SAFETY_PHRASES
	   		  	     (organization_id,
									inventory_item_id,
									safety_phrase_code,
									created_by,
									creation_date,
									last_updated_by,
									last_update_date,
									last_update_login)
	          VALUES
			         (l_organization_id,
								l_inventory_item_id,
								l_phrase_code,
							  fnd_global.user_id,
				  	 		sysdate,
				  	 		fnd_global.user_id,
				  	 		sysdate,
				  	 		l_last_update_login);


           ELSIF l_form_block = 'RISK_PHRASES' THEN
             -- Validate the value for phrase code against the GR_RISK_PHRASES_VL.
             -- An error message will be written to the log file if the value is invalid
		         OPEN c_get_risk_phrase_code;
			 FETCH c_get_risk_phrase_code INTO riskcode;
			 IF c_get_risk_phrase_code%NOTFOUND THEN
			   l_msg_token := l_phrase_code;
			   CLOSE c_get_risk_phrase_code;
			   FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
     			   FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
     			   RAISE loop_exception;
             		 END IF;
			 CLOSE c_get_risk_phrase_code;

              --	If the field name is associated to a field name class using the Risk Phrases form block,
              --  validate that the record does not already exist, and insert the record into the GR_INV_ITEM_RISK_PHRASES table
              --   An error message will be written to the log file if the record already exists

       			 OPEN c_get_item_risk_phrase;
	        	 FETCH c_get_item_risk_phrase INTO l_phrase_code2;
						 IF c_get_item_risk_phrase%FOUND THEN
					      CLOSE c_get_item_risk_phrase;
			        	l_msg_token := l_phrase_code;
			        	FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
    						FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
			        	RAISE loop_exception;
			    	 END IF;

             CLOSE c_get_item_risk_phrase;

	          INSERT INTO GR_INV_ITEM_RISK_PHRASES
	   		  	     (organization_id,
									inventory_item_id,
									risk_phrase_code,
									created_by,
									creation_date,
									last_updated_by,
									last_update_date,
									last_update_login)
	          VALUES
			         (l_organization_id,
								l_inventory_item_id,
								l_phrase_code,
							  fnd_global.user_id,
				  	 		sysdate,
				  	 		fnd_global.user_id,
				  	 		sysdate,
				  	 		l_last_update_login);

         -- With the exception of those values listed above, all other records will be inserted into the GR_INV_ITEM_PROPERTIES table.
         -- An error message will be written to the log file if the record already exists

         ELSE

             --  get l_sequence_number

                  IF l_property_id is not null then
			              OPEN Cur_get_seq_no;
									  FETCH Cur_get_seq_no INTO l_sequence_number;
										IF Cur_get_seq_no%NOTFOUND THEN
											  l_msg_token := l_field_name_code || ' ' || l_property_id;
											  CLOSE Cur_get_seq_no;
										    FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
			     							FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
			     							 RAISE loop_exception;
			           		END IF;
									  CLOSE Cur_get_seq_no;
                  END IF; --  IF l_property_id is not null then

		          GR_INV_ITEM_PROPERTIES_PKG.Insert_Row (
		          p_commit                     => p_commit,
		          p_called_by_form              => 'F',
		          p_organization_id   => l_organization_id,
		          p_inventory_item_id => l_inventory_item_id,
						  p_sequence_number   => l_sequence_number,  -- populated by gr_item_safety.get_properties
						  p_property_id       => l_property_id ,
						  p_label_code        => l_field_name_code,
						  p_number_value      => l_numeric_value,
						  p_alpha_value       => l_alpha_value,
						  p_date_value        => l_date_value,
						  p_created_by   =>                FND_GLOBAL.USER_ID,
						  p_creation_date   =>             SYSDATE,
						  p_last_updated_by  =>            FND_GLOBAL.USER_ID,
						  p_last_update_date =>            SYSDATE,
						  p_last_update_login  =>          l_last_update_login,
						  x_rowid  => row_id,
						  x_return_status		=> return_status,
							x_oracle_error		=> oracle_error,
							x_msg_data			=> msg_data);



			         IF return_status <> 'S' THEN

			                l_oracle_error := APP_EXCEPTION.Get_Code;
										   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
										   FND_MESSAGE.SET_NAME('GR',
										                        'GR_NO_RECORD_INSERTED');
										   FND_MESSAGE.SET_TOKEN('CODE',
										                        l_code_block,
										                        FALSE);
									      APP_EXCEPTION.Raise_Exception;

			               x_return_status := return_status;
			      				RAISE loop_exception;
			 				 END IF;

          END IF; --IF l_form_block = 'SAFETY_PHRASES' THEN





       ELSIF l_action = 'U' then

          IF l_property_type_indicator not in ('S','R','P') then

			          update gr_inv_item_properties
			          set number_value = l_numeric_value   ,
		              alpha_value = l_alpha_value,
		              date_value =  l_date_value,
		              last_updated_by				 = fnd_global.user_id,
				 					last_update_date				 = sysdate,
				 					last_update_login			 = l_last_update_login
				        WHERE organization_id = l_organization_id and
		            inventory_item_id = l_inventory_item_id
		            and label_code = l_field_name_code
		            and property_id =  l_property_id;
					   		IF SQL%NOTFOUND THEN
					   		  FND_MESSAGE.SET_NAME('GR',
		                           'GR_RECORD_NOT_FOUND');
		      				FND_MESSAGE.SET_TOKEN('CODE',
		         		            l_msg_token,
		            			    FALSE);
		            	l_msg_token := l_organization_id || ' ' || l_inventory_item_id || ' ' || l_phrase_code;
	          		  RAISE loop_exception;

			           END IF; -- IF SQL%NOTFOUND THEN


            END IF; -- IF (l_property_type_indicator not in ('S','R') then


       ELSIF l_action = 'D' then

           OPEN c_val_fname;
		       FETCH c_val_fname INTO l_form_block;
					 IF c_val_fname%NOTFOUND THEN
					    null;
					 END IF;
		 		   close c_val_fname;


         -- 	If the field name is associated to a field name class using the Safety Phrases form block, validate that
         -- the record exists, and delete the record from the GR_INV_ITEM_SAFETY_PHRASES table
         --  An error message will be written to the log file if the record does not exist

           IF l_form_block = 'SAFETY_PHRASES' THEN

	             dummy:= 0;
	 				  	 OPEN c_get_item_safety_phrase;
		        	 FETCH c_get_item_safety_phrase INTO l_phrase_code2;
							 IF c_get_item_safety_phrase%NOTFOUND THEN
						      CLOSE c_get_item_safety_phrase;
				        	l_msg_token := l_phrase_code;
				        	FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
	     					  FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
				        	RAISE loop_exception;
				    	 END IF;
	             CLOSE c_get_item_safety_phrase;

		          DELETE from GR_INV_ITEM_SAFETY_PHRASES
	            WHERE organization_id = l_organization_id and
	            inventory_item_id = l_inventory_item_id
	            and safety_phrase_code = l_phrase_code;
				   		IF SQL%NOTFOUND THEN

				   		  FND_MESSAGE.SET_NAME('GR',
	                           'GR_RECORD_NOT_FOUND');
	      				FND_MESSAGE.SET_TOKEN('CODE',
	         		            l_msg_token,
	            			    FALSE);
				   		  l_msg_token := l_organization_id || ' ' || l_inventory_item_id || ' ' || l_phrase_code;

				     		RAISE loop_exception;
				   		END IF;

           ELSIF l_form_block = 'RISK_PHRASES' THEN

           		-- 	If the field name is associated to a field name class using the Risk Phrases form block,
           		--  validate that the record exists, and delete the record from the GR_INV_ITEM_RISK_PHRASES table
           		--  An error message will be written to the log file if the record does not exist

	 				  	 OPEN c_get_item_risk_phrase;
		        	 FETCH c_get_item_risk_phrase INTO l_phrase_code2;
							 IF c_get_item_risk_phrase%NOTFOUND THEN
						      CLOSE c_get_item_risk_phrase;
				        	l_msg_token := l_phrase_code;
				        	FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
	     					  FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
	     					 	RAISE loop_exception;
				    	 END IF;
	             CLOSE c_get_item_risk_phrase;

		   	  	  DELETE from GR_INV_ITEM_RISK_PHRASES
	            WHERE organization_id = l_organization_id and
	            inventory_item_id = l_inventory_item_id
	            and risk_phrase_code = l_phrase_code;
				   		IF SQL%NOTFOUND THEN
				   		  FND_MESSAGE.SET_NAME('GR',
	                           'GR_RECORD_NOT_FOUND');
	      				FND_MESSAGE.SET_TOKEN('CODE',
	         		            l_msg_token,
	            			    FALSE);
				   		  l_msg_token := l_organization_id || ' ' || l_inventory_item_id || ' ' || l_phrase_code;
          		RAISE loop_exception;
				   		END IF;

         -- With the exception of those values listed above, all other records will be deleted from the GR_INV_ITEM_PROPERTIES table.
         -- An error message will be written to the log file if the record does not exist


           ELSE

		          GR_INV_ITEM_PROPERTIES_PKG.delete_Rows
		         (p_commit                     => p_commit,
		          p_called_by_form              => 'F',
		          p_delete_option     => 'B', --  'B' Delete all rows using the item and label combination.
  		        p_organization_id   => l_organization_id,
		          p_inventory_item_id => l_inventory_item_id,
     				  p_label_code        => l_field_name_code,
     					x_return_status		=> return_status,
							x_oracle_error		=> oracle_error,
							x_msg_data			=> msg_data);

							 IF return_status <> 'S' THEN

			                l_oracle_error := APP_EXCEPTION.Get_Code;
										   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
										   FND_MESSAGE.SET_NAME('GR',
										                        'GR_NO_RECORD_INSERTED');
										   FND_MESSAGE.SET_TOKEN('CODE',
										                        l_code_block,
										                        FALSE);
									      APP_EXCEPTION.Raise_Exception;

			               x_return_status := return_status;
			      				RAISE loop_exception;
			 				END IF;

        END IF;  --   IF l_form_block = 'SAFETY_PHRASES' THEN



     END IF;  --  IF action = 'I' then

EXCEPTION

WHEN loop_exception THEN

x_return_status := 'E';
FND_MSG_PUB.ADD;

WHEN OTHERS THEN

          gmi_reservation_util.println('- entering when others ');
          x_return_status := 'U';
          oracle_error := SQLCODE;
          x_msg_data := SUBSTR(SQLERRM, 1, 200);
          FND_MESSAGE.SET_NAME('GR',
                               'GR_UNEXPECTED_ERROR');
          FND_MESSAGE.SET_TOKEN('TEXT',
                                l_msg_token,
                                FALSE);
          FND_MSG_PUB.ADD;
          x_msg_data := FND_MESSAGE.Get;

END;

END LOOP; --   FOR i IN 1 .. p_item_properties_tab.count LOOP


IF x_return_status = 'E' or x_return_status = 'U' then
	 FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
					 , p_count => x_msg_count
					 , p_data  => x_msg_data
					);
END IF;


IF x_return_status IN (FND_API.G_RET_STS_SUCCESS) AND (FND_API.To_Boolean( p_commit ) ) THEN
  	Commit;
END IF;
END ITEM_PROPERTIES;

END GR_ITEM_PROPERTIES_PUB;

/
