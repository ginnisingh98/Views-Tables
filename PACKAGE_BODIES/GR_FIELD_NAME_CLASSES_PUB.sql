--------------------------------------------------------
--  DDL for Package Body GR_FIELD_NAME_CLASSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_FIELD_NAME_CLASSES_PUB" AS
/*  $Header: GRPIFNCB.pls 120.2.12010000.2 2009/06/19 16:12:48 plowe noship $
 *****************************************************************
 *                                                               *
 * Package  GR_FIELD_NAME_CLASSES_PUB                            *
 *                                                               *
 * Contents FIELD_NAME_CLASSES                                   *
 *                                                               *
 *                                                               *
 * Use      This is the public layer for the FIELD NAME_CLASSES  *
 *          API                                                  *
 *                                                               *
 * History                                                       *
 *         Written by P A Lowe OPM Unlimited Dev                 *
 * Peter Lowe  06/20/08                                          *
 *                                                               *
 * Updated By              For                                   *
 *                                                               *
 * Peter Lowe  07/10/08      BUG 7249054                         *
 * Peter Lowe  08/01/08      BUG 7293765                         *
 * 		                                                           *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GR_FIELD_NAME_CLASSES_PUB';

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

PROCEDURE FIELD_NAME_CLASSES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_action               IN  VARCHAR2
, p_object               IN  VARCHAR2
, p_field_name_class     IN VARCHAR2
, p_form_block           IN VARCHAR2
, p_language             IN VARCHAR2
, p_source_language      IN VARCHAR2
, p_description          IN VARCHAR2
, p_label_class_resp_tab IN  GR_FIELD_NAME_CLASSES_PUB.gr_label_class_resp_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)

IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'FIELD_NAME_CLASSES';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_msg_count             NUMBER  :=0;
  l_debug_flag VARCHAR2(1) := set_debug_flag;

  l_language_code VARCHAR2(4);
  l_missing_count   NUMBER;
  l_form_block VARCHAR2(14);
  l_application_id   NUMBER := 557;

  l_last_update_login NUMBER(15,0) := 0;
  L_KEY_EXISTS 	VARCHAR2(1);

  l_responsibility_id NUMBER;
  l_responsibility   VARCHAR2(100);
  l_display_sequence    NUMBER;
  l_allow_create_update VARCHAR2(1);


  dummy              NUMBER;
  i   							 NUMBER;

  row_id        VARCHAR2(18);
  return_status VARCHAR2(1);
  oracle_error  NUMBER;
  msg_data      VARCHAR2(2000);

  LBins_err	EXCEPTION;
  LCins_err EXCEPTION;
  LTadd_err EXCEPTION;
  LTL_del_err EXCEPTION;
  LT_EXISTS_ERROR EXCEPTION;
  ROW_MISSING_ERROR EXCEPTION;

-- Cursor Definitions

CURSOR c_get_language
 IS
   SELECT 	lng.language_code
   FROM		fnd_languages lng
   WHERE	lng.language_code = l_language_code;
   LangRecord			c_get_language%ROWTYPE;

CURSOR Cur_count_language IS
		      SELECT count (language_code)
		      FROM   fnd_languages
		      WHERE  installed_flag IN ('I', 'B')
		             AND language_code not in
		                 (SELECT language
		                  FROM   GR_LABEL_CLASSES_TL
		                  WHERE  label_class_code = p_field_name_class);

/*	 Label Class Codes */

CURSOR c_get_label_class
 IS
   SELECT	lcb.label_class_code, lcb.form_block
   FROM		gr_label_classes_b lcb
   WHERE	lcb.label_class_code = p_field_name_class;
LabelClsRcd			c_get_label_class%ROWTYPE;

CURSOR c_get_label_class_tl
 IS
 SELECT  1
		FROM   GR_LABEL_CLASSES_TL
		WHERE  label_class_code = p_field_name_class
		and language = p_language;

cursor resp_id_cur is
      select 1
      from fnd_responsibility
      where responsibility_id = l_responsibility_id;

 cursor resp_name_cur is
      select responsibility_id
      from fnd_responsibility_vl
      where responsibility_name = l_responsibility;

cursor label_class_resp1 is
 select 1
  from GR_LABEL_CLASS_RESPS
  where LABEL_CLASS_CODE = p_field_name_class;


cursor label_class_resp is
 select 1
  from GR_LABEL_CLASS_RESPS
  where LABEL_CLASS_CODE = p_field_name_class
  and   APPLICATION_ID = 557
  and   RESPONSIBILITY_ID = l_responsibility_id;

cursor label_class_resp_ds is
 select 1
  from GR_LABEL_CLASS_RESPS
  where LABEL_CLASS_CODE = p_field_name_class
  and   APPLICATION_ID = 557
  and   display_sequence = l_display_sequence;

L_MSG_TOKEN       VARCHAR2(100);


BEGIN

  -- Standard Start OF API savepoint

 -- SAVEPOINT FIELD_NAME_CLASSES;

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
 --     gmd_debug.log_initialize('GR FIELD NAME CLASSES API');
 -- END IF;



/* check mandatory inputs */

  IF p_action is NULL or p_action not in ('I','U','D')  then
     FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_ACTION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_object is NULL or p_object not in ('C','L','R') then
    FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_OBJECT');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF p_field_name_class is NULL then
     FND_MESSAGE.SET_NAME('GMA',
                           'SY_FIELDNAME');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   IF p_action = 'I' then

     IF p_object = 'C' then


        --  Validate that the value of Field Name Class does not already exist in the table GR_LABEL_CLASSES_B.
        --  If it does, write an error to the log file

				   OPEN c_get_label_class;
				   FETCH c_get_label_class INTO LabelClsRcd;
				   IF c_get_label_class%NOTFOUND THEN
				   		null;
				   ELSE
				      x_return_status := 'E';
				      l_msg_token := p_field_name_class;
				      CLOSE c_get_label_class;
				  		RAISE LT_Exists_Error;
				   END IF;
				   CLOSE c_get_label_class;

       -- Language, Source Language and Description values are required
       -- and an error message will be written to the log file if any of the values are null.
          IF p_language is NULL or p_source_language is NULL or p_description is null or p_form_block is NULL then
    				FND_MESSAGE.SET_NAME('GMA',
                           'SY_FIELDNAME');
    				RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Validate that Form Block is set to either Properties, Risk Phrases, Safety Phrases or Names.
         -- If an invalid value is passed in, an error message will be written to the log file.
        IF p_form_block not in ('Properties','Risk Phrases','Safety Phrases','Names') then
       FND_MESSAGE.SET_NAME('GMA',
                           'SY_INVALID_TYPE');
    			RAISE FND_API.G_EXC_ERROR;

         END IF;

       -- 7293765
	       IF p_form_block = 'Risk Phrases' then
	           l_form_block := 'RISK_PHRASES';
	       END IF;
	       IF p_form_block = 'Safety Phrases' then
	           l_form_block := 'SAFETY_PHRASES';
	       END IF;


       -- insert a record for GR_LABEL_CLASSES_B
         gr_label_classes_b_pkg.Insert_Row
          (p_commit                     => 'T',
          p_called_by_form              => 'F',
				  p_label_class_code            => p_field_name_class,
				  p_form_block                  => l_form_block,
				  p_rollup_type => NULL,
				  p_rollup_property => NULL,
				  p_rollup_label => NULL,
				  p_attribute_category => NULL,
				  p_attribute1 => NULL,
				  p_attribute2 => NULL,
				  p_attribute3 => NULL,
				  p_attribute4 => NULL,
				  p_attribute5 => NULL,
				  p_attribute6 => NULL,
				  p_attribute7 => NULL,
				  p_attribute8 => NULL,
				  p_attribute9 => NULL,
				  p_attribute10 => NULL,
				  p_attribute11 => NULL,
				  p_attribute12 => NULL,
				  p_attribute13 => NULL,
				  p_attribute14 => NULL,
				  p_attribute15 => NULL,
				  p_attribute16 => NULL,
				  p_attribute17 => NULL,
				  p_attribute18 => NULL,
				  p_attribute19 => NULL,
				  p_attribute20 => NULL,
				  p_attribute21 => NULL,
				  p_attribute22=> NULL,
				  p_attribute23 => NULL,
				  p_attribute24 => NULL,
				  p_attribute25 => NULL,
				  p_attribute26 => NULL,
				  p_attribute27 => NULL,
				  p_attribute28 => NULL,
				  p_attribute29 => NULL,
				  p_attribute30 => NULL,
				  p_created_by   =>                FND_GLOBAL.USER_ID,
				  p_creation_date   =>             SYSDATE,
				  p_last_updated_by  =>            FND_GLOBAL.USER_ID,
				  p_last_update_date =>            SYSDATE,
				  p_last_update_login  =>          l_last_update_login,
				  x_rowid  => row_id,
				  x_return_status		=> return_status,
					x_oracle_error		=> oracle_error,
					x_msg_data			=> msg_data);

				 /*dbms_output.put_line('msg_data =>  ' || msg_data);
         dbms_output.put_line('oracle_error =>  ' || oracle_error);
         dbms_output.put_line(' return_status =>  ' || return_status); */

         IF return_status <> 'S' THEN

              IF (l_debug_flag = 'Y') THEN
      					gmd_debug.put_line('error');
    					END IF;
              GMD_API_PUB.Log_Message(msg_data);
      				RAISE LBins_err;
 				 END IF;

          -- need to add base row for language for GR_LABEL_CLASSES_TL

			      gr_label_classes_tl_pkg.insert_row(
						p_commit => 'T',
						p_called_by_form => 'F',
						p_label_class_code => p_field_name_class,
						p_language => p_language,
						p_label_class_description => p_description,
						p_source_lang => p_source_language,
						p_created_by   =>                fnd_global.user_id,
				  	p_creation_date   =>             sysdate,
				  	p_last_updated_by  =>            fnd_global.user_id,
				  	p_last_update_date =>            sysdate,
				  	p_last_update_login  =>          l_last_update_login,
				 	  x_rowid  => row_id,
				    x_return_status		=> return_status,
					  x_oracle_error		=> oracle_error,
					  x_msg_data			=> msg_data);


           IF return_status <> 'S' THEN

              IF (l_debug_flag = 'Y') THEN
      					gmd_debug.put_line('error');
    					END IF;
              GMD_API_PUB.Log_Message(msg_data);
              RAISE LCins_err;
 				   END IF;



  		   -- Insert a record into GR_LABEL_CLASSES_TL for each installed language.

  			 OPEN Cur_count_language;
		     FETCH Cur_count_language INTO l_missing_count;
		     CLOSE Cur_count_language;
		     IF l_missing_count > 0 THEN


			     GR_LABEL_CLASSES_TL_PKG.Add_Language
		           (p_commit			=> 'T',
							  p_called_by_form 		=> 'F',
					      p_label_class_code => p_field_name_class,
					      p_language			=> p_language,
							  x_return_status		=> return_status,
							  x_oracle_error		=> oracle_error,
							  x_msg_data			=> msg_data);


						/*dbms_output.put_line('msg_data =>  ' || msg_data);
	          dbms_output.put_line('oracle_error =>  ' || oracle_error);
	          dbms_output.put_line('return_status =>  ' || return_status); */

						IF return_status <> 'S' THEN
							    GMD_API_PUB.Log_Message('GR_LABEL_CLASS_ADD_LANG_ERROR');
	      					FND_MESSAGE.SET_NAME('GR',
                           'GR_LABEL_CLASS_ADD_LANG_ERROR');
     						  FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      						FND_MSG_PUB.ADD;
	      					RAISE LTadd_err;
	 				  END IF;

					END IF; --  IF l_missing_count > 0 THEN

  			-- Insert a record into GR_LABEL_CLASS_RESPS for each valid record in the passed table.

  			  FOR i IN 1 .. p_label_class_resp_tab.count LOOP

  			  l_responsibility_id := p_label_class_resp_tab(i).responsibility_id;
  			  l_responsibility := p_label_class_resp_tab(i).responsibility;
  			  l_display_sequence :=   p_label_class_resp_tab(i).display_sequence;
  				l_allow_create_update := p_label_class_resp_tab(i).allow_create_update;

          IF l_responsibility_id IS NOT NULL THEN
                     -- check if valid_id
					         dummy:= 0;
					         OPEN resp_id_cur;
					         FETCH resp_id_cur INTO dummy;
							  	 IF resp_id_cur%NOTFOUND THEN
									    CLOSE resp_id_cur;
							        l_msg_token := l_responsibility_id;
				  						RAISE Row_Missing_Error;
							     END IF;
							     CLOSE resp_id_cur;
			   END IF;

			   IF l_responsibility IS NOT NULL THEN
                     -- check if valid resp

					         OPEN resp_name_cur;
					         FETCH resp_name_cur INTO l_responsibility_id;
									 IF resp_name_cur%NOTFOUND THEN
									    CLOSE resp_name_cur;
							        l_msg_token := l_responsibility;
				  						RAISE Row_Missing_Error;
							     END IF;
							     CLOSE resp_name_cur;
			   END IF;
			   IF l_responsibility_id is NOT NULL or l_responsibility is NOT NULL then

		     -- Insert a record into GR_LABEL_CLASS_RESPS for each valid record in the passed table

							insert into gr_label_class_resps (
						  label_class_code, application_id, responsibility_id, display_sequence,
						  allow_create_update, created_by, creation_date, last_updated_by,
						  last_update_date, last_update_login ) values
						 ( p_field_name_class,
						  l_application_id,
						  l_responsibility_id,
						  l_display_sequence,
						  l_allow_create_update,
						  fnd_global.user_id,
				  	  sysdate,
				  	  fnd_global.user_id,
				  	  sysdate,
				  	  l_last_update_login
						  );

				 END IF; --IF l_responsibility_id is NOT NULL or responsibility_id is NOT NULL then

		    END LOOP; --   FOR i IN 1 .. p_label_class_resp_tab.count LOOP


	   ELSIF p_object = 'L' then

        -- Validate that the value of Field Name Class exists in the table GR_LABEL_CLASSES_B.
	      -- If it does not, write an error to the log file
           OPEN c_get_label_class;
				   FETCH c_get_label_class INTO LabelClsRcd;
				   IF c_get_label_class%NOTFOUND THEN
				      x_return_status := 'E';
				      l_msg_token := p_field_name_class;
				      CLOSE c_get_label_class;
				  		RAISE Row_Missing_Error;
				   END IF;
				   CLOSE c_get_label_class;

        -- Validate that the value of Language for the specified property does not exist in the table table GR_LABEL_CLASSES_TL.
        --  If it does, write an error to the log file.

           OPEN c_get_label_class_tl;
				   FETCH c_get_label_class_tl INTO dummy;
				   IF c_get_label_class_tl%FOUND THEN
				      x_return_status := 'E';
				      l_msg_token := p_field_name_class|| ' ' || p_language;
				      CLOSE c_get_label_class_tl;
				  		RAISE LT_Exists_Error;
				   END IF;
				   CLOSE c_get_label_class_tl;

           -- The values for Source Language, Language and Description will be written to the GR_LABEL_CLASSES_TL table
           gr_label_classes_tl_pkg.insert_row(
						p_commit => 'T',
						p_called_by_form => 'F',
						p_label_class_code => p_field_name_class,
						p_language => p_language,
						p_label_class_description => p_description,
						p_source_lang => p_source_language,
						p_created_by   => fnd_global.user_id,
				  	p_creation_date => sysdate,
				  	p_last_updated_by  => fnd_global.user_id,
				  	p_last_update_date =>  sysdate,
				  	p_last_update_login => l_last_update_login,
				 	  x_rowid  => row_id,
				    x_return_status		=> return_status,
					  x_oracle_error		=> oracle_error,
					  x_msg_data			=> msg_data);

           IF return_status <> 'S' THEN

              IF (l_debug_flag = 'Y') THEN
      					gmd_debug.put_line('error');
    					END IF;
    				  GMD_API_PUB.Log_Message(msg_data);
      				RAISE LCins_err;
 				   END IF;


     ELSE   --    object = R

         -- Insert a record into GR_LABEL_CLASS_RESPS for each valid record in the passed table.

  			  FOR i IN 1 .. p_label_class_resp_tab.count LOOP

		  			  l_responsibility_id := p_label_class_resp_tab(i).responsibility_id;
		  			  l_responsibility := p_label_class_resp_tab(i).responsibility;
		  			  l_display_sequence :=   p_label_class_resp_tab(i).display_sequence;
		  				l_allow_create_update := p_label_class_resp_tab(i).allow_create_update;

		  			 --	It is required that either the responsibility id or the responsibility name is passed in.
		         --If neither is sent in, a 'Responsibility required' error message will be written to the log file.
		  			  IF l_responsibility_id is NULL and l_responsibility is NULL then
		    			FND_MESSAGE.SET_NAME('GMA',
                           'SY_FIELDNAME');
		    				RAISE FND_API.G_EXC_ERROR;
		  			  END IF;

		  			  -- If a responsibility name is sent in, the responsibility id will be retrieved from FND_RESPONSIBILITY_VL.
		  			  -- If a responsibility id is sent in, it is validated against the FND_RESPONSIBILITY table.
		  			  -- An error message will be written to the log file if the value is invalid.

		          IF l_responsibility_id IS NOT NULL THEN
		                     -- check if valid_id
							         dummy:= 0;
							         OPEN resp_id_cur;
							         FETCH resp_id_cur INTO dummy;
											 IF resp_id_cur%NOTFOUND THEN
											    CLOSE resp_id_cur;
									        l_msg_token := l_responsibility_id;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE resp_id_cur;
					   END IF;

					   IF l_responsibility IS NOT NULL THEN
		                     -- check if valid resp

							         OPEN resp_name_cur;
							         FETCH resp_name_cur INTO l_responsibility_id;
											 IF resp_name_cur%NOTFOUND THEN
											    CLOSE resp_name_cur;
									        l_msg_token := l_responsibility;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE resp_name_cur;
					   END IF;

					   --  Validate that the value of Responsibility Id for the specified field name class
					   --  does not exist in the table GR_LABEL_CLASS_RESPS.
					   --  If it does, write an error to the log file.

					   OPEN label_class_resp;
						 FETCH label_class_resp INTO dummy;
						 IF label_class_resp%NOTFOUND THEN
					      null;
						 ELSE
					      x_return_status := 'E';
					      l_msg_token := p_field_name_class || ' ' || l_responsibility_id;
					      CLOSE label_class_resp;
					  		RAISE LT_Exists_Error;
						 END IF;
						 CLOSE label_class_resp;

			       -- Validate that the value of display sequence for the specified  field name class does not exist
			       -- in the table GR_LABEL_CLASS_RESPS.  If it does, write an error to the log file

			       OPEN label_class_resp_ds;
						 FETCH label_class_resp_ds INTO dummy;
						 IF label_class_resp_ds%NOTFOUND THEN
						      null;
						 ELSE
						      x_return_status := 'E';
						      l_msg_token := p_field_name_class || ' ' || l_display_sequence;
						      CLOSE label_class_resp_ds;
						  		RAISE LT_Exists_Error;
						 END IF;
						 CLOSE label_class_resp_ds;

			       -- The values for field name class, responsibility id,
			       -- display_sequence and allow edit will be written to the GR_LABEL_CLASS_RESPS table.

					   IF l_responsibility_id is NOT NULL then

				     -- Insert a record into GR_LABEL_CLASS_RESPS for each valid record in the passed table

									insert into gr_label_class_resps (
								  label_class_code, application_id, responsibility_id, display_sequence,
								  allow_create_update, created_by, creation_date, last_updated_by,
								  last_update_date, last_update_login ) values
								 ( p_field_name_class,
								  l_application_id,
								  l_responsibility_id,
								  l_display_sequence,
								  l_allow_create_update,
								  fnd_global.user_id,
						  	  sysdate,
						  	  fnd_global.user_id,
						  	  sysdate,
						  	  l_last_update_login
								  );


						 END IF; --IF l_responsibility_id is NOT NULL or responsibility_id is NOT NULL then

		    END LOOP; --   FOR i IN 1 .. p_label_class_resp_tab.count LOOP



     END IF; -- IF p_object = 'C' then

     --  next  is U action

   /*************************************************************************************/

   ELSIF p_action = 'U' then

   --	Validate that the value of Label Class exists in the table GR_LABEL_CLASSES_B.
   -- If it does not, an error message will be written to the log file.

	    OPEN c_get_label_class;
			FETCH c_get_label_class INTO LabelClsRcd;
			IF c_get_label_class%NOTFOUND THEN
					      x_return_status := 'E';
					      l_msg_token := p_field_name_class;
					      CLOSE c_get_label_class;
					  		RAISE Row_Missing_Error;
			END IF;
			CLOSE c_get_label_class;



	    IF p_object = 'C' then
	     -- bug 7249054 - need to validate p_form_block

         -- Validate that Form Block is set to either Properties, Risk Phrases, Safety Phrases or Names.
         -- If an invalid value is passed in, an error message will be written to the log file.
         IF p_form_block not in ('Properties','Risk Phrases','Safety Phrases','Names') then
       					FND_MESSAGE.SET_NAME('GMA',
                           'SY_INVALID_TYPE');
    						RAISE FND_API.G_EXC_ERROR;

         END IF;

	       -- 7293765
	       IF p_form_block = 'Risk Phrases' then
	           l_form_block := 'RISK_PHRASES';
	       END IF;
	       IF p_form_block = 'Safety Phrases' then
	           l_form_block := 'SAFETY_PHRASES';
	       END IF;

	     --	The value of Form Block will be updated in the GR_ GR_LABEL_CLASSES_B table.

		     UPDATE gr_label_classes_b
			   SET	 form_block	         = l_form_block,
					 last_updated_by				 = fnd_global.user_id,
					 last_update_date				 = sysdate,
					 last_update_login			 = l_last_update_login
			   WHERE  label_class_code = p_field_name_class;
			   IF SQL%NOTFOUND THEN
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

         -- If the record for the specified field name class and language does not exist in the GR_LABEL_CLASSES_TL table,
         -- an error will be written to the log file.

          gr_label_classes_tl_pkg.Check_Primary_Key(
          p_field_name_class,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

          IF l_key_exists = 'N'  THEN
            l_msg_token := p_field_name_class|| ' ' || p_language;
   				  RAISE Row_Missing_Error;
   				END IF;
          -- The value for Description will be updated GR_LABEL_CLASSES_TL table for the specified language.

			    UPDATE GR_LABEL_CLASSES_TL
				  SET label_class_description		 = p_description,
						 source_lang					 = p_source_language,
						 last_updated_by			 = FND_GLOBAL.USER_ID,
						 last_update_date			 = SYSDATE,
						 last_update_login		= l_last_update_login
				  WHERE  label_class_code  = p_field_name_class
				        and language = p_language;
				  IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name_class || ' ' || p_language;
				     RAISE Row_Missing_Error;
				  END IF;

     ELSE   --    object = R (responsibility)

          FOR i IN 1 .. p_label_class_resp_tab.count LOOP

		  			  l_responsibility_id := p_label_class_resp_tab(i).responsibility_id;
		  			  l_responsibility := p_label_class_resp_tab(i).responsibility;
		  			  l_display_sequence :=   p_label_class_resp_tab(i).display_sequence;
		  				l_allow_create_update := p_label_class_resp_tab(i).allow_create_update;

		  			  -- If a responsibility name is sent in, the responsibility id will be retrieved from FND_RESPONSIBILITY_VL.
		  			  -- If a responsibility id is sent in, it is validated against the FND_RESPONSIBILITY table.
		  			  -- An error message will be written to the log file if the value is invalid.

		          IF l_responsibility_id IS NOT NULL THEN
		                     -- check if valid_id
							         dummy:= 0;
							         OPEN resp_id_cur;
							         FETCH resp_id_cur INTO dummy;
											 IF resp_id_cur%NOTFOUND THEN
											    CLOSE resp_id_cur;
									        l_msg_token := l_responsibility_id;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE resp_id_cur;
					   END IF;

					   IF l_responsibility IS NOT NULL THEN
		                     -- check if valid resp
							         OPEN resp_name_cur;
							         FETCH resp_name_cur INTO l_responsibility_id;
											 IF resp_name_cur%NOTFOUND THEN
											    CLOSE resp_name_cur;
									        l_msg_token := l_responsibility;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE resp_name_cur;
					   END IF;

					    --	Validate that the value of Responsibility Id for the specified field name class exists in the table
		  			  -- GR_LABEL_CLASS_RESPS. If it does not, write an error to the log file.


					   OPEN label_class_resp;
						 FETCH label_class_resp INTO dummy;
						 IF label_class_resp%NOTFOUND THEN
						      x_return_status := 'E';
						      l_msg_token := p_field_name_class || ' ' || l_responsibility_id;
						      CLOSE label_class_resp;
						  		RAISE LT_Exists_Error;
						 END IF;
						 CLOSE label_class_resp;

			       --	If sent in, validate that the value of display sequence for the specified Responsibility Id
			       -- and field name class does not exist in the table GR_LABEL_CLASS_RESPS.
			       -- If it does, write an error to the log file

			       IF l_display_sequence is NOT NULL then
				       OPEN label_class_resp_ds;
							 FETCH label_class_resp_ds INTO dummy;
							 IF label_class_resp_ds%NOTFOUND THEN
									      null;
							 ELSE
									      x_return_status := 'E';
									      l_msg_token := p_field_name_class || ' ' || l_display_sequence;
									      CLOSE label_class_resp_ds;
									  		RAISE LT_Exists_Error;
							 END IF;
							 CLOSE label_class_resp_ds;
			       END IF; --   IF l_display_sequence is NOT NULL then

			     -- The non-null values for display sequence and allow edit will be updated in the GR_LABEL_CLASS_RESPS table.
			   	   IF l_responsibility_id is NOT NULL then
					 		  	update gr_label_class_resps
									set display_sequence = l_display_sequence,
									allow_create_update = l_allow_create_update
								  where label_class_code = p_field_name_class
								  and application_id = l_application_id
								  and responsibility_id = l_responsibility_id;
						 END IF; --IF l_responsibility_id is NOT NULL then

		    END LOOP; --   FOR i IN 1 .. p_label_class_resp_tab.count LOOP

     END IF; -- IF p_object = 'C' then

   ELSE -- action is D   (delete)

    		-- 	Validate that the value of Field Name class  exists in the table GR_LABEL_CLASSES_B.
        -- If it does not, write an error to the log file

	        OPEN c_get_label_class;
				   FETCH c_get_label_class INTO LabelClsRcd;
				   IF c_get_label_class%NOTFOUND THEN
				      x_return_status := 'E';
				      l_msg_token := p_field_name_class;
				      CLOSE c_get_label_class;
				  		RAISE Row_Missing_Error;
				   END IF;
				   CLOSE c_get_label_class;

	      IF p_object = 'C' then

         -- Delete all of the property related records in the
         -- GR_LABEL_CLASSES_B, GR_LABEL_CLASSES_TL and GR_LABEL_CLASS_RESPS tables.

	         gr_label_classes_tl_pkg.delete_rows
		   	 	 (p_commit 			=> 'T',
		   		 p_called_by_form 		=> 'F',
	    	   p_label_class_code		=> p_field_name_class,
		       x_return_status		=> return_status,
		       x_oracle_error		=> oracle_error,
		       x_msg_data			=> msg_data);

	        IF return_status <> FND_API.g_ret_sts_success THEN
	                        GMD_API_PUB.Log_Message('GR_LABEL_CLASS_DEL_LANG_ERROR');
	      									FND_MESSAGE.SET_NAME('GR',
                           'GR_LABEL_CLASS_DEL_LANG_ERROR');
     						  				FND_MSG_PUB.ADD;
	        		        		RAISE LTL_del_err;
				  END IF;

          DELETE FROM  gr_label_class_resps
          WHERE label_class_code = p_field_name_class;

          DELETE FROM gr_label_classes_b
          WHERE label_class_code = p_field_name_class;

          IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name_class;
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

         -- If the record for the specified field name class and language does not exist
         --in the GR_LABEL_CLASSES_TL table, an error will be written to the log file

          gr_label_classes_tl_pkg.Check_Primary_Key(
          p_field_name_class,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

          IF l_key_exists = 'N'  THEN
            l_msg_token := p_field_name_class|| ' ' || p_language;
   				  RAISE Row_Missing_Error;
   				END IF;

          -- Delete the record in GR_LABEL_CLASSES_TL table for the specified language

			    delete  from GR_LABEL_CLASSES_TL
				  WHERE  label_class_code  = p_field_name_class
				        and language = p_language;
				  IF SQL%NOTFOUND THEN
				        l_msg_token := p_field_name_class || ' ' || p_language;
				     RAISE Row_Missing_Error;
				  END IF;


     ELSE   --    object = R   -- up to here

        -- Validate that the value of Field Name Class exists in the table GR_LABEL_CLASS_RESPS.
	      -- If it does not, write an error to the log file
           OPEN label_class_resp1; -- lap
						 FETCH label_class_resp1 INTO dummy;
						 IF label_class_resp1%NOTFOUND THEN
								      x_return_status := 'E';
								      l_msg_token := p_field_name_class;
								      CLOSE label_class_resp1;
								  		RAISE Row_Missing_Error;
						 END IF;
						 CLOSE label_class_resp1;

         --  Loop through records in input table


         FOR i IN 1 .. p_label_class_resp_tab.count LOOP

		  			  l_responsibility_id := p_label_class_resp_tab(i).responsibility_id;
		  			  l_responsibility := p_label_class_resp_tab(i).responsibility;
		  			  l_display_sequence :=   p_label_class_resp_tab(i).display_sequence;
		  				l_allow_create_update := p_label_class_resp_tab(i).allow_create_update;

		  			  -- If a responsibility name is sent in, the responsibility id will be retrieved from FND_RESPONSIBILITY_VL.
		  			  -- If a responsibility id is sent in, it is validated against the FND_RESPONSIBILITY table.
		  			  -- An error message will be written to the log file if the value is invalid.

		          IF l_responsibility_id IS NOT NULL THEN
		                     -- check if valid_id
							         dummy:= 0;
							         OPEN resp_id_cur;
							         FETCH resp_id_cur INTO dummy;
											 IF resp_id_cur%NOTFOUND THEN
											    CLOSE resp_id_cur;
									        l_msg_token := l_responsibility_id;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE resp_id_cur;
					   END IF;

					   IF l_responsibility IS NOT NULL THEN
		                     -- check if valid resp
							         OPEN resp_name_cur;
							         FETCH resp_name_cur INTO l_responsibility_id;
											 IF resp_name_cur%NOTFOUND THEN
											    CLOSE resp_name_cur;
									        l_msg_token := l_responsibility;
						  						RAISE Row_Missing_Error;
									     END IF;
									     CLOSE resp_name_cur;
					   END IF;

		  			 -- Validate that the value of Responsibility Id for the specified field name class exists in the
              --table GR_LABEL_CLASS_RESPS.  If it does not, write an error to the log file.

					   OPEN label_class_resp;
						 FETCH label_class_resp INTO dummy;
						 IF label_class_resp%NOTFOUND THEN
								      x_return_status := 'E';
								      l_msg_token := p_field_name_class || ' ' || l_responsibility_id;
								      CLOSE label_class_resp;
								  		RAISE LT_Exists_Error;
						 END IF;
						 CLOSE label_class_resp;

			     -- Delete the record in GR_ GR_LABEL_CLASS_RESPS
			     -- table for the specified field name class and responsibility id.
			   	   IF l_responsibility_id is NOT NULL then
					 		  	delete from gr_label_class_resps
									where label_class_code = p_field_name_class
								  and application_id = l_application_id
								  and responsibility_id = l_responsibility_id ;
						 END IF; --IF l_responsibility_id is NOT NULL then

		    END LOOP; --   FOR i IN 1 .. p_label_class_resp_tab.count LOOP

     END IF; -- IF p_object = 'C' then

   END IF; --  IF p_action = 'I' then


EXCEPTION
     WHEN LBins_err THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAMES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

       WHEN LCins_err THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAMES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

     WHEN LTadd_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       --ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);

		 WHEN LTL_del_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
       --x_msg_data := msg_data;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

   WHEN Row_Missing_Error THEN
      --GMD_API_PUB.Log_Message('GR_RECORD_NOT_FOUND');
      --ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
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
      --ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
      x_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
					 , p_count => x_msg_count
					 , p_data  => x_msg_data
					);
       x_msg_data := FND_MESSAGE.Get;

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      --ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END FIELD_NAME_CLASSES;

END GR_FIELD_NAME_CLASSES_PUB;

/
