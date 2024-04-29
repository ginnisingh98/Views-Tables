--------------------------------------------------------
--  DDL for Package Body GR_FIELD_NAMES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_FIELD_NAMES_PUB" AS
/*  $Header: GRPIFNSB.pls 120.3.12010000.2 2009/06/19 16:17:37 plowe noship $
 *****************************************************************
 *                                                               *
 * Package  GR_FIELD_NAMES_PUB                                   *
 *                                                               *
 * Contents FIELD_NAMES                                          *
 *                                                               *
 *                                                               *
 * Use      This is the public layer for the FIELD NAMES API     *
 *                                                               *
 * History                                                       *
 *         Written by P A Lowe OPM Unlimited Dev                 *
 * Peter Lowe  06/12/08                                          *
 *                                                               *
 * Updated By              For                                   *
 *                                                               *
 * Peter Lowe    07/10/08  Bug 7247651                           *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GR_FIELD_NAMES_PUB';

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



PROCEDURE FIELD_NAMES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_action               IN  VARCHAR2
, p_object               IN  VARCHAR2
, p_field_name           IN  VARCHAR2
, p_field_name_class     IN VARCHAR2
, p_technical_parameter_flag IN VARCHAR2
, p_language             IN VARCHAR2
, p_source_language      IN VARCHAR2
, p_description          IN VARCHAR2
, p_label_properties_tab IN  GR_FIELD_NAMES_PUB.gr_label_properties_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)

IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'FIELD_NAMES';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_msg_count             NUMBER  :=0;
  l_debug_flag VARCHAR2(1) := set_debug_flag;
  l_label_properties_flag VARCHAR2(1);
  l_language_code VARCHAR2(4);
  l_missing_count   NUMBER;
  l_technical_parameter_flag NUMBER;
  l_label_value_required NUMBER := 0;
  l_sequence_number NUMBER := 0;
  l_property_required  NUMBER := 0;
  l_property_id 		 VARCHAR2(6);
  l_print_size NUMBER := 1;
  l_last_update_login NUMBER(15,0) := 0;
  L_KEY_EXISTS 	VARCHAR2(1);

  dummy              NUMBER;
  i   							 NUMBER;

  row_id        VARCHAR2(18);
  return_status VARCHAR2(1);
  oracle_error  NUMBER;
  msg_data      VARCHAR2(2000);



  LBins_err	EXCEPTION;
  LTadd_err EXCEPTION;
  LP_ins_err EXCEPTION;
  LBTLadd_err EXCEPTION;
  LTL_del_err EXCEPTION;
  LT_EXISTS_ERROR EXCEPTION;
  LP_del_err EXCEPTION;
  ROW_MISSING_ERROR EXCEPTION;
-- Cursor Definitions

CURSOR c_get_language
 IS
   SELECT 	lng.language_code
   FROM		fnd_languages lng
   WHERE	lng.language_code = l_language_code;
   LangRecord			c_get_language%ROWTYPE;

CURSOR c_get_field_name is
SELECT 1
FROM
GR_LABELS_B B
    where B.LABEL_CODE = p_field_name;

 CURSOR Cur_count_language IS
		      SELECT count (language_code)
		      FROM   fnd_languages
		      WHERE  installed_flag IN ('I', 'B')
		             AND language_code not in
		                 (SELECT language
		                  FROM   gr_labels_tl_v
		                  WHERE  label_code = p_field_name);

/*	 Label Class Codes */

CURSOR c_get_label_class
 IS
   SELECT	lcb.label_class_code, lcb.form_block
   FROM		gr_label_classes_b lcb
   WHERE	lcb.label_class_code = p_field_name_class;
LabelClsRcd			c_get_label_class%ROWTYPE;

CURSOR c_get_property_id is
SELECT 1
FROM
GR_PROPERTIES_B B
    where B.PROPERTY_ID = l_property_id;

CURSOR c_get_property_ind is
SELECT property_type_indicator
FROM GR_PROPERTIES_B B
where B.PROPERTY_ID = l_property_id;

l_prop_type_ind VARCHAR2(1);

CURSOR c_get_label_properties_rowid
 IS
   SELECT lp.rowid
   FROM	  gr_label_properties lp
   WHERE  lp.property_id = l_property_id
   AND	  lp.label_code =  p_field_name;
LabelTLRecord			   c_get_label_properties_rowid%ROWTYPE;


L_MSG_TOKEN       VARCHAR2(100);


BEGIN

  -- Standard Start OF API savepoint

 -- SAVEPOINT FIELD_NAMES;

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
  gmd_debug.log_initialize('PAL euro trash');
  x_return_status   := FND_API.G_RET_STS_SUCCESS;

 -- IF (l_debug = 'Y') THEN
 --     gmd_debug.log_initialize('GR FIELD NAMES API');
 -- END IF;



/* check mandatory inputs */

  IF p_action is NULL or p_action not in ('I','U','D')  then
    FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_ACTION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_object is NULL or p_object not in ('C','L','P') then
  FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_OBJECT');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Will raise the error message if property type phrase is passed in.
  FOR i IN 1 .. p_label_properties_tab.count LOOP
   l_property_id := p_label_properties_tab(i).property_id;
   IF p_label_properties_tab(i).property_id IS NOT NULL THEN
     OPEN c_get_property_ind;
     FETCH c_get_property_ind into l_prop_type_ind;
     CLOSE c_get_property_ind;
     IF (l_prop_type_ind = 'P') THEN
       FND_MESSAGE.SET_NAME('GR','GR_PROPERTY_IND_INVALID');
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
  END LOOP;

  IF p_field_name is NULL then
    FND_MESSAGE.SET_NAME('GMA',
                           'SY_FIELDNAME');
    RAISE FND_API.G_EXC_ERROR;

  END IF;

   IF p_action = 'I' then

     IF p_object = 'C' then

        -- validate field_name

	     OPEN c_get_field_name;
				FETCH c_get_field_name INTO dummy;
				IF NOT c_get_field_name%NOTFOUND THEN
	        CLOSE c_get_field_name;
	        GMD_API_PUB.Log_Message('PON_AUC_DUP_FIELD_NAME');
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
			 CLOSE c_get_field_name;


       /*   Check the language codes */

         l_language_code := p_language;
			   OPEN c_get_language;
			   FETCH c_get_language INTO LangRecord;
			   IF c_get_language%NOTFOUND THEN
			      CLOSE c_get_language;
				  l_msg_token := l_language_code;
				  RAISE Row_Missing_Error;
			   END IF;
			   CLOSE c_get_language;

			   l_language_code := p_source_language;
			   OPEN c_get_language;
			   FETCH c_get_language INTO LangRecord;
			   IF c_get_language%NOTFOUND THEN
			      CLOSE c_get_language;
				  l_msg_token := l_language_code;
				  RAISE Row_Missing_Error;
			   END IF;
			   CLOSE c_get_language;

      -- fn class and desc are required


        IF p_field_name_class IS  NULL then
        	 FND_MESSAGE.SET_NAME('GR',
                           'GR_CLASS_REQUIRED');
     		   FND_MSG_PUB.ADD;
           GMD_API_PUB.Log_Message('GR_CLASS_REQUIRED');
    			 RAISE FND_API.G_EXC_ERROR;

  			ELSE
          /*   Check the label class code */

				   OPEN c_get_label_class;
				   FETCH c_get_label_class INTO LabelClsRcd;
				   IF c_get_label_class%NOTFOUND THEN
				      x_return_status := 'E';
				      l_msg_token := p_field_name_class;
				      CLOSE c_get_label_class;
				  		RAISE Row_Missing_Error;
				   END IF;
				   CLOSE c_get_label_class;

  			END IF; --  IF p_field_name_class IS  NULL then

        IF p_description IS  NULL then
            FND_MESSAGE.SET_NAME('GR',
                           'GR_DESC_REQUIRED');
     		  	FND_MSG_PUB.ADD;
            GMD_API_PUB.Log_Message('GR_DESC_REQUIRED');
    			  RAISE FND_API.G_EXC_ERROR;
  			END IF;

  			-- write to gr_labels_b table.

  			-- first check table p_label_properties_tab   for any input
  			l_label_properties_flag := 'N';
  			FOR i in 1 .. p_label_properties_tab.count LOOP
					      IF p_label_properties_tab(i).property_id IS NOT NULL THEN
					        l_label_properties_flag := 'Y';
					      END IF;
				END LOOP;
  			-- insert row
  			 IF p_technical_parameter_flag = 'Y' then
  			   l_technical_parameter_flag := 1;
  			 ELSE
  			   l_technical_parameter_flag := 0;
  			 END IF;


  		  GR_LABELS_B_PKG.Insert_Row
         (p_commit                      => 'F',
          p_called_by_form              => 'F',
          p_label_code                  => p_field_name,
          p_safety_category_code        => 'NU',  -- dummy default as no longer used
          p_label_class_code            => p_field_name_class,
          p_data_position_indicator     => 'I',  -- dummy default as no longer used
          p_label_properties_flag       => l_label_properties_flag,  -- Y if some input in input table
          p_label_value_required        => l_label_value_required, --  dummy default as no longer used
          p_item_properties_flag        => 'Y', -- bug 7247651 this needs to be set
          p_ingredient_value_flag       => 'N',  -- dummy default as no longer used
          p_inherit_from_label_code    =>  NULL,
				  p_print_ingredient_indicator  => NULL,
				  p_print_font     =>              NULL,
				  p_print_size   =>                l_print_size,
				  p_ingredient_label_code    =>    NULL,
				  p_value_procedure    =>          NULL,
				  p_attribute_category    =>       NULL,
				  p_attribute1    =>               NULL,
				  p_attribute2    =>               NULL,
				  p_attribute3    =>               NULL,
				  p_attribute4    =>               NULL,
				  p_attribute5    =>               NULL,
				  p_attribute6    =>               NULL,
				  p_attribute7    =>               NULL,
				  p_attribute8    =>               NULL,
				  p_attribute9    =>               NULL,
				  p_attribute10    =>              NULL,
				  p_attribute11    =>              NULL,
				  p_attribute12    =>              NULL,
				  p_attribute13    =>              NULL,
				  p_attribute14    =>              NULL,
				  p_attribute15    =>              NULL,
				  p_attribute16    =>              NULL,
				  p_attribute17    =>              NULL,
				  p_attribute18    =>              NULL,
				  p_attribute19    =>              NULL,
				  p_attribute20    =>              NULL,
				  p_attribute21    =>              NULL,
				  p_attribute22    =>              NULL,
				  p_attribute23    =>              NULL,
				  p_attribute24    =>              NULL,
				  p_attribute25    =>              NULL,
				  p_attribute26    =>              NULL,
				  p_attribute27    =>              NULL,
				  p_attribute28    =>              NULL,
				  p_attribute29    =>              NULL,
				  p_attribute30    =>              NULL,
				  p_created_by   =>                FND_GLOBAL.USER_ID,
				  p_creation_date   =>             SYSDATE,
				  p_last_updated_by  =>            FND_GLOBAL.USER_ID,
				  p_last_update_date =>            SYSDATE,
				  p_last_update_login  =>          l_last_update_login,
				  p_tech_parm       =>             l_technical_parameter_flag,
				  p_rollup_disclosure_code    =>   NULL,
				  x_rowid                       => row_id,
          x_return_status               => return_status,
          x_oracle_error                => oracle_error,
          x_msg_data                    => msg_data);

         /* dbms_output.put_line('msg_data =>  ' || msg_data);
          dbms_output.put_line(' oracle_error =>  ' || oracle_error);
          dbms_output.put_line('return_status =>  ' || return_status); */

           IF return_status <> 'S' THEN

              IF (l_debug = 'Y') THEN
      					gmd_debug.put_line('error');
    					END IF;
              GMD_API_PUB.Log_Message(msg_data);
      				RAISE LBins_err;
 				  END IF;

        --source lang and lang input


      GR_LABELS_TL_PKG.INSERT_ROW(
			P_COMMIT => 'F'
			,P_CALLED_BY_FORM => 'F'
			,P_LABEL_CODE => p_field_name
			,P_LANGUAGE => P_LANGUAGE
			,P_LABEL_DESCRIPTION => p_description
			,P_SOURCE_LANG => p_source_language
			,P_CREATED_BY => FND_GLOBAL.USER_ID
			,P_CREATION_DATE => sysdate
			,P_LAST_UPDATED_BY => FND_GLOBAL.USER_ID
			,P_LAST_UPDATE_DATE => sysdate
			,P_LAST_UPDATE_LOGIN => 0
			,X_ROWID => row_id
			,X_RETURN_STATUS => return_status
			,X_ORACLE_ERROR => oracle_error
			,X_MSG_DATA => msg_data);


			   /* dbms_output.put_line(' msg_data =>  ' || msg_data);
          dbms_output.put_line(' oracle_error =>  ' || oracle_error);
          dbms_output.put_line(' return_status =>  ' || return_status); */


			IF return_status <> 'S' THEN

              IF (l_debug = 'Y') THEN
      					gmd_debug.put_line('error');
    					END IF;
              GMD_API_PUB.Log_Message(msg_data);
      				RAISE LBTLadd_err;
 			END IF;


        -- insert a row into gr_labels_tl for every language installed

		     OPEN Cur_count_language;
		     FETCH Cur_count_language INTO l_missing_count;
		     CLOSE Cur_count_language;
		     IF l_missing_count > 0 THEN
		        GR_LABELS_TL_PKG.add_language
						 (p_commit			=> 'F',
						  p_called_by_form 		=> 'F',
						  p_label_code			=> p_field_name,
						  p_language			=> p_language,
						  x_return_status		=> return_status,
						  x_oracle_error		=> oracle_error,
						  x_msg_data			=> msg_data);

					/*dbms_output.put_line(' msg_data =>  ' || msg_data);
          dbms_output.put_line(' oracle_error =>  ' || oracle_error);
          dbms_output.put_line(' return_status =>  ' || return_status); */

						  IF return_status <> 'S' THEN
						    GMD_API_PUB.Log_Message('GR_LABELS_TL_PKG_ADD_LANG');
						    FND_MESSAGE.SET_NAME('GR',
                           'GR_LABELS_TL_PKG_ADD_LANG');
						    GMD_API_PUB.Log_Message(msg_data);
      					RAISE LTadd_err;
 				  		END IF;

					END IF;

				  -- If field name class is not associated to a form type of Properties or Names
				  -- and the properties table is not empty, an error message will be written to the log file.
					-- field_names_class association check  next

					IF l_label_properties_flag = 'Y' and LabelClsRcd.form_block <> 'NAMES' and LabelClsRcd.form_block <> 'PROPERTIES'
					then

						 GMD_API_PUB.Log_Message('GR_FNAME_NOT_ASSOC');
						 FND_MESSAGE.SET_NAME('GR',
                           'GR_FNAME_NOT_ASSOC');
    				 RAISE FND_API.G_EXC_ERROR;
  			 	END IF;


					-- load properties table input into gl_label_properties table

					/* Loop through records in input table and insert into gr_label_properties table for each record*/

        FOR i IN 1 .. p_label_properties_tab.count LOOP
          l_property_id := p_label_properties_tab(i).property_id;
          IF p_label_properties_tab(i).property_id IS NOT NULL THEN
                     -- check if valid_id
					          dummy:= 0;
					         OPEN c_get_property_id;
					         FETCH c_get_property_id INTO dummy;
									IF c_get_property_id%NOTFOUND THEN

							        CLOSE c_get_property_id;
							        l_msg_token := l_property_id;
				  						RAISE Row_Missing_Error;
							     END IF;

									 CLOSE c_get_property_id;

		      -- load properties table input into gl_label_properties table
					GR_LABEL_PROPERTIES_PKG.Insert_Row
					(p_commit                     => 'F',
          p_called_by_form              => 'F',
          p_sequence_number             => p_label_properties_tab(i).sequence_number,
          p_property_id 								=> l_property_id,
				  p_label_code                  => p_field_name,
				  p_rollup_type => 0,
				  p_property_required            => p_label_properties_tab(i).property_required,
				  p_created_by   =>                0,
				  p_creation_date   =>             SYSDATE,
				  p_last_updated_by  =>            0,
				  p_last_update_date =>            SYSDATE,
				  p_last_update_login  =>            0,
				  x_rowid                       => row_id,
          x_return_status               => return_status,
          x_oracle_error                => oracle_error,
          x_msg_data                    => msg_data);

				 /* dbms_output.put_line(' msg_data =>  ' || msg_data);
          dbms_output.put_line(' oracle_error =>  ' || oracle_error);
          dbms_output.put_line(' return_status =>  ' || return_status); */

				 	 IF return_status <> FND_API.g_ret_sts_success THEN
				 	  GMD_API_PUB.Log_Message('GR_LABEL_PROPERTIES_PKG_INS_RO');
				 	  FND_MESSAGE.SET_NAME('GR',
                           'GR_LABEL_PROPERTIES_PKG_INS_RO');
        		RAISE LP_ins_err;
           END IF;

				 END IF; -- IF p_label_properties_tab(i).property_id IS NOT NULL THEN

		    END LOOP;

			--DONE

	   ELSIF p_object = 'L' then

        -- 	Validate that the value of Field Name code exists in the table GR_LABELS_B.
        -- If it does not, write an error to the log file

	        OPEN c_get_field_name;
					FETCH c_get_field_name INTO dummy;
					IF c_get_field_name%NOTFOUND THEN
		        CLOSE c_get_field_name;
		        l_msg_token := p_field_name;
				  	RAISE Row_Missing_Error;
		      END IF;
				  CLOSE c_get_field_name;

        -- Validate that the value of Language for the specified property does not exist in the table GR_LABELS_TL.
        --  If it does, write an error to the log file.
         GR_LABELS_TL_PKG.Check_Primary_Key(
          p_field_name,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

          IF FND_API.To_Boolean(l_key_exists) THEN
            l_msg_token := p_field_name || ' ' || p_language;
   				  RAISE LT_Exists_Error;
   				END IF;

            -- insert row for source lang and lang input

		      GR_LABELS_TL_PKG.INSERT_ROW(
					P_COMMIT => 'F'
					,P_CALLED_BY_FORM => 'F'
					,P_LABEL_CODE => p_field_name
					,P_LANGUAGE => P_LANGUAGE
					,P_LABEL_DESCRIPTION => p_description
					,P_SOURCE_LANG => p_source_language
					,P_CREATED_BY => FND_GLOBAL.USER_ID
					,P_CREATION_DATE => sysdate
					,P_LAST_UPDATED_BY => FND_GLOBAL.USER_ID
					,P_LAST_UPDATE_DATE => sysdate
					,P_LAST_UPDATE_LOGIN => 0
					,X_ROWID =>  row_id
					,X_RETURN_STATUS => return_status
					,X_ORACLE_ERROR => oracle_error
					,X_MSG_DATA => msg_data);

			   /* dbms_output.put_line(' msg_data =>  ' || msg_data);
          dbms_output.put_line(' oracle_error =>  ' || oracle_error);
          dbms_output.put_line(' return_status =>  ' || return_status); */


					IF return_status <> 'S' THEN

              IF (l_debug = 'Y') THEN
      					gmd_debug.put_line('error');
    					END IF;
    					FND_MESSAGE.SET_NAME('GR',
                           'GR_LABEL_PROPERTIES_PKG_INS_RO');
              GMD_API_PUB.Log_Message(msg_data);
      				RAISE LBTLadd_err;
 					END IF;

     ELSE   --    object = P
        -- 	Validate that the value of Field Name code exists in the table GR_LABELS_B.
        -- If it does not, write an error to the log file

	        OPEN c_get_field_name;
					FETCH c_get_field_name INTO dummy;
					IF c_get_field_name%NOTFOUND THEN
		        CLOSE c_get_field_name;
		        l_msg_token := p_field_name;
				  	RAISE Row_Missing_Error;
		      END IF;
				  CLOSE c_get_field_name;


          /* Loop through records in input table and insert into gr_label_properties table for each record*/

	        FOR i IN 1 .. p_label_properties_tab.count LOOP
	          l_property_id := p_label_properties_tab(i).property_id;
	          IF p_label_properties_tab(i).property_id IS NOT NULL THEN
		                     -- check if valid_id
							         dummy:= 0;
							         OPEN c_get_property_id;
							         FETCH c_get_property_id INTO dummy;
											 IF c_get_property_id%NOTFOUND THEN
											     CLOSE c_get_property_id;
									         l_msg_token := l_property_id;
						  					   RAISE Row_Missing_Error;
									     END IF;
									     CLOSE c_get_property_id;

				             --Validate that the specified property does not exist in the table GR_LABEL_PROPERTIES.
				             -- If it does, write an error to the log file.

				               OPEN c_get_label_properties_rowid;
										   FETCH c_get_label_properties_rowid INTO LabelTLRecord;
										   IF c_get_label_properties_rowid%NOTFOUND THEN
										      null;
									     ELSE
										      x_return_status := 'E';
										      l_msg_token := p_field_name || ' ' || l_property_id;
										      CLOSE c_get_label_properties_rowid;
										  		RAISE LT_Exists_Error;
										   END IF;
										   CLOSE c_get_label_properties_rowid;


								      -- load properties table input into gl_label_properties table
											GR_LABEL_PROPERTIES_PKG.Insert_Row
											(p_commit                     => 'F',
						          p_called_by_form              => 'F',
						          p_sequence_number             => p_label_properties_tab(i).sequence_number,
						          p_property_id 								=> l_property_id,
										  p_label_code                  => p_field_name,
										  p_rollup_type => 0,
										  p_property_required            => p_label_properties_tab(i).property_required,
										  p_created_by   =>                0,
										  p_creation_date   =>             SYSDATE,
										  p_last_updated_by  =>            0,
										  p_last_update_date =>            SYSDATE,
										  p_last_update_login  =>            0,
										  x_rowid                       => row_id,
						          x_return_status               => return_status,
						          x_oracle_error                => oracle_error,
						          x_msg_data                    => msg_data);

										 /* dbms_output.put_line(' msg_data =>  ' || msg_data);
						          dbms_output.put_line(' oracle_error =>  ' || oracle_error);
						          dbms_output.put_line(' return_status =>  ' || return_status); */

										 	 IF return_status <> FND_API.g_ret_sts_success THEN
										 	  FND_MESSAGE.SET_NAME('GR',
                           'GR_LABEL_PROPERTIES_PKG_INS_RO');
										 	  GMD_API_PUB.Log_Message('GR_LABEL_PROPERTIES_PKG_INS_RO');
						        		RAISE LP_ins_err;
						           END IF;

					 END IF; -- IF p_label_properties_tab(i).property_id IS NOT NULL THEN

			    END LOOP;

     END IF; -- IF p_object = 'C' then

     --  next  is U action

   /*************************************************************************************/

   ELSIF p_action = 'U' then

     -- Validate that the value of Property Id exists in the table GR_PROPERTIES_B.
     -- If it does not, an error message will be written to the log file.

     FOR i IN 1 .. p_label_properties_tab.count LOOP
          l_property_id := p_label_properties_tab(i).property_id;
          IF p_label_properties_tab(i).property_id IS NOT NULL THEN
                     -- check if valid_id
					          dummy:= 0;
					         OPEN c_get_property_id;
					         FETCH c_get_property_id INTO dummy;
									 IF c_get_property_id%NOTFOUND THEN
									    CLOSE c_get_property_id;
							        l_msg_token := l_property_id;
							       	RAISE Row_Missing_Error;
							     END IF;
							    CLOSE c_get_property_id;
         END IF;
     END LOOP; -- FOR i IN 1 .. p_label_properties_tab.count LOOP


     IF p_object = 'C' then

       --	Any non-null, valid values passed in for field name class and
       -- technical parameter flag will be updated in the GR_LABELS_B table.

				    IF p_field_name_class IS  NOT NULL then
						  /*   Check the label class code */

						 OPEN c_get_label_class;
						 FETCH c_get_label_class INTO LabelClsRcd;
						 IF c_get_label_class%NOTFOUND THEN
						      x_return_status := 'E';
						      l_msg_token := p_field_name_class;
							    CLOSE c_get_label_class;
							 		RAISE Row_Missing_Error;
							END IF;
							CLOSE c_get_label_class;
						END IF; --  IF p_field_name_class IS  NOT NULL then

				    IF p_technical_parameter_flag = 'Y' then
  			        l_technical_parameter_flag := 1;
  			 	  ELSE
  			       l_technical_parameter_flag := 0;
  			    END IF;

				    UPDATE gr_labels_b
					  SET	  label_class_code	 = p_field_name_class,
							 last_updated_by			 = FND_GLOBAL.USER_ID,
							 last_update_date			 = SYSDATE, -- pal
							 last_update_login		 = l_last_update_login,
							 tech_parm 				     = l_technical_parameter_flag
					  WHERE  label_code  = p_field_name;

				    IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name;
	     					RAISE Row_Missing_Error;
	  				END IF;


	   ELSIF p_object = 'L' then

        -- If the value for Language is null or invalid, write an error to the log file.

        IF p_language is NULL then
            l_msg_token := l_language_code;
				    RAISE Row_Missing_Error;
        END IF;

         /*   Check the language codes */

         l_language_code := p_language;
			   OPEN c_get_language;
			   FETCH c_get_language INTO LangRecord;
			   IF c_get_language%NOTFOUND THEN
			      CLOSE c_get_language;
				    l_msg_token := l_language_code;
				    RAISE Row_Missing_Error;
			   END IF;
			   CLOSE c_get_language;

        --	If the record for the specified field name code and language does not exist in
        -- the GR_LABELS_TL table, an error will be written to the log file.

          GR_LABELS_TL_PKG.Check_Primary_Key(
          p_field_name,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

          IF l_key_exists = 'N'  THEN
            l_msg_token := p_field_name || ' ' || p_language;
   				  RAISE Row_Missing_Error;
   				END IF;

          -- update  description lang input

			    UPDATE gr_labels_tl
				  SET label_description		 = p_description,
						 source_lang					 = p_source_language,
						 last_updated_by			 = FND_GLOBAL.USER_ID,
						 last_update_date			 = SYSDATE,
						 last_update_login		= l_last_update_login
				  WHERE  label_code  = p_field_name
				        and language = p_language;
				  IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name || ' ' || p_language;
				     RAISE Row_Missing_Error;
				  END IF;


     ELSE   --    object = P


          /* Loop through records in input table
          Validate that the value of Property Id exists in the table GR_LABEL_PROPERTIES
          and is associated to the specified field name code If it does not, write an error to the log  */

	        FOR i IN 1 .. p_label_properties_tab.count LOOP
	          l_property_id := p_label_properties_tab(i).property_id;
	          l_sequence_number := p_label_properties_tab(i).sequence_number;
	          l_property_required := p_label_properties_tab(i).property_required;
	          IF p_label_properties_tab(i).property_id IS NOT NULL THEN
		                     -- check if valid_id
							         dummy:= 0;
							         OPEN c_get_property_id;
							         FETCH c_get_property_id INTO dummy;
											 IF c_get_property_id%NOTFOUND THEN

									        CLOSE c_get_property_id;
									        l_msg_token := l_property_id;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE c_get_property_id;

				             -- Validate that the value of Property Id is associated to the specified field name code.
				             -- If it does, write an error to the log file.

				               OPEN c_get_label_properties_rowid;
										   FETCH c_get_label_properties_rowid INTO LabelTLRecord;
										   IF c_get_label_properties_rowid%NOTFOUND THEN
										      x_return_status := 'E';
										      l_msg_token := p_field_name || ' ' || l_property_id;
										      CLOSE c_get_label_properties_rowid;
										  		RAISE Row_Missing_Error;
										   END IF;
										   CLOSE c_get_label_properties_rowid;



						  	      -- The the non-null values for required flag
								      -- and display sequence will be updated to the GR_LABEL_PROPERTIES table
												UPDATE gr_label_properties
											  SET sequence_number      = l_sequence_number,
													 property_required 		 = l_property_required,
													 last_updated_by			 = FND_GLOBAL.USER_ID,
													 last_update_date			 = SYSDATE,
													 last_update_login		 = l_last_update_login
											  WHERE  property_id = l_property_id
											      and label_code = p_field_name;

											  IF SQL%NOTFOUND THEN
											     l_msg_token := p_field_name || ' ' || l_property_id;
											     RAISE Row_Missing_Error;
											  END IF;


					 END IF; -- IF p_label_properties_tab(i).property_id IS NOT NULL THEN

			    END LOOP; -- FOR i IN 1 .. p_label_properties_tab.count LOOP


     END IF; -- IF p_object = 'C' then



   ELSE -- action is D

   		 -- 	Validate that the value of Field Name code exists in the table GR_LABELS_B.
        -- If it does not, write an error to the log file

	        OPEN c_get_field_name;
					FETCH c_get_field_name INTO dummy;
					IF c_get_field_name%NOTFOUND THEN
		        CLOSE c_get_field_name;
		        l_msg_token := p_field_name;
				  	RAISE Row_Missing_Error;
		      END IF;
				  CLOSE c_get_field_name;



	      IF p_object = 'C' then
             -- -- Delete all of the property related records in the GR_LABELS_B, GR_LABELS_TL and GR_LABEL_PROPERTIES tables.

	         gr_labels_tl_pkg.delete_rows
		   	 	 (p_commit 			=> 'F',
		   		 p_called_by_form 		=> 'F',
	    	   p_label_code		=> p_field_name,
		       x_return_status		=> return_status,
		       x_oracle_error		=> oracle_error,
		       x_msg_data			=> msg_data);

	        IF return_status <> FND_API.g_ret_sts_success THEN
											 	  GMD_API_PUB.Log_Message('GR_LABELS_TL_PKG_DEL_ROWS');
											 	  FND_MESSAGE.SET_NAME('GR',
                           'GR_LABELS_TL_PKG_DEL_ROWS');
											 	  l_msg_token := p_field_name;
							        		RAISE LTL_del_err;
				  END IF;


	        gr_label_properties_pkg.delete_rows
		      (p_commit 			=> 'F',
		       p_called_by_form 		=> 'T',
	    	   p_delete_option		=> 'L',
		       p_property_id		=> NULL,
		       p_label_code		=> p_field_name,
		       x_return_status		=> return_status,
		       x_oracle_error		=> oracle_error,
		       x_msg_data			=> msg_data);

          IF return_status <> FND_API.g_ret_sts_success THEN
											 	  GMD_API_PUB.Log_Message('GR_LABEL_PROPERTIES_PKG_DEL_RO');
											 	  FND_MESSAGE.SET_NAME('GR',
                           'GR_LABEL_PROPERTIES_PKG_DEL_RO');
							        		RAISE LP_del_err;
				  END IF;

         DELETE FROM gr_labels_b
         WHERE  	   label_code  = p_field_name;

         IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name || ' ' || p_language;
				 RAISE Row_Missing_Error;
         END IF;




	   ELSIF p_object = 'L' then

        -- If the value for Language is null or invalid, write an error to the log file.

        IF p_language is NULL then
            l_msg_token := l_language_code;
				    RAISE Row_Missing_Error;
        END IF;

         /*   Check the language codes */

         l_language_code := p_language;
			   OPEN c_get_language;
			   FETCH c_get_language INTO LangRecord;
			   IF c_get_language%NOTFOUND THEN
			      CLOSE c_get_language;
				    l_msg_token := l_language_code;
				    RAISE Row_Missing_Error;
			   END IF;
			   CLOSE c_get_language;

        --	If the record for the specified field name code and language does not exist in
        -- the GR_LABELS_TL table, an error will be written to the log file.
          GR_LABELS_TL_PKG.Check_Primary_Key(
          p_field_name,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

          IF l_key_exists = 'N'  THEN
            l_msg_token := p_field_name || ' ' || p_language;
   				  RAISE Row_Missing_Error;
   				END IF;

          -- delete update  description lang input

			    delete  gr_labels_tl
				  WHERE  label_code  = p_field_name
				        and language = p_language;
				  IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name || ' ' || p_language;
				     RAISE Row_Missing_Error;
				  END IF;

     ELSE   --    object = P

          /* Loop through records in input table
          Validate that the value of Property Id exists in the table GR_LABEL_PROPERTIES
          and is associated to the specified field name code If it does not, write an error to the log  */

	        FOR i IN 1 .. p_label_properties_tab.count LOOP
	          l_property_id := p_label_properties_tab(i).property_id;
	          l_sequence_number := p_label_properties_tab(i).sequence_number;
	          l_property_required := p_label_properties_tab(i).property_required;
	          IF p_label_properties_tab(i).property_id IS NOT NULL THEN
		                     -- check if valid_id
							         dummy:= 0;
							         OPEN c_get_property_id;
							         FETCH c_get_property_id INTO dummy;
											 IF c_get_property_id%NOTFOUND THEN

									        CLOSE c_get_property_id;
									        l_msg_token := l_property_id;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE c_get_property_id;

				             -- Validate that the value of Property Id is associated to the specified field name code.
				             -- If it does, write an error to the log file.

				               OPEN c_get_label_properties_rowid;
										   FETCH c_get_label_properties_rowid INTO LabelTLRecord;
										   IF c_get_label_properties_rowid%NOTFOUND THEN
										      x_return_status := 'E';
										      l_msg_token := p_field_name || ' ' || l_property_id;
										      CLOSE c_get_label_properties_rowid;
										  		RAISE Row_Missing_Error;
										   END IF;
										   CLOSE c_get_label_properties_rowid;

										   --	Delete the record in GR_LABEL_PROPERTIES table for the specified field name and property id.

						  	      	   delete from gr_label_properties
						  	      	   WHERE  property_id = l_property_id
											      and label_code = p_field_name;

											  IF SQL%NOTFOUND THEN
											     l_msg_token := p_field_name || ' ' || l_property_id;
											     RAISE Row_Missing_Error;
											  END IF;


					  END IF; -- IF p_label_properties_tab(i).property_id IS NOT NULL THEN

			    END LOOP; -- FOR i IN 1 .. p_label_properties_tab.count LOOP

     END IF; -- IF p_object = 'C' then

   END IF; --  IF p_action = 'I' then

IF x_return_status IN (FND_API.G_RET_STS_SUCCESS) AND (FND_API.To_Boolean( p_commit ) ) THEN
 	Commit;
END IF;

EXCEPTION

     WHEN LTadd_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       --ROLLBACK TO SAVEPOINT FIELD_NAMES;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);

     WHEN LBins_err THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAMES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

     WHEN LP_ins_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAMES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

		WHEN LTL_del_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAMES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

		WHEN LP_del_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAMES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);
     WHEN LBTLadd_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       --ROLLBACK TO SAVEPOINT FIELD_NAMES;
        --x_msg_data := msg_data;
       FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

   WHEN Row_Missing_Error THEN
      --GMD_API_PUB.Log_Message('GR_RECORD_NOT_FOUND');
      --ROLLBACK TO SAVEPOINT FIELD_NAMES;
	    x_return_status := 'E';
	    FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

     WHEN LT_Exists_Error THEN

	   x_return_status := 'E';
	   oracle_error := APP_EXCEPTION.Get_Code;
     FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
     FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
       FND_MSG_PUB.ADD;

	     FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);


      WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO SAVEPOINT FIELD_NAMES;
      x_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
					 , p_count => x_msg_count
					 , p_data  => x_msg_data
					);
       x_msg_data := FND_MESSAGE.Get;

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      --ROLLBACK TO SAVEPOINT FIELD_NAMES;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --ROLLBACK TO SAVEPOINT FIELD_NAMES;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END FIELD_NAMES;

END GR_FIELD_NAMES_PUB;

/
