--------------------------------------------------------
--  DDL for Package Body GR_FIELD_NAME_PROPERTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_FIELD_NAME_PROPERTIES_PUB" AS
/*  $Header: GRPIFNPB.pls 120.1.12010000.2 2009/06/19 17:29:59 asatpute noship $
 *****************************************************************
 *                                                               *
 * Package  GR_FIELD_NAME_PROPERTIES_PUB                         *
 *                                                               *
 * Contents FIELD_NAME_PROPERTIES                                *
 *                                                               *
 *                                                               *
 * Use      This is the public layer for the FIELD_NAME_PROPERTIES*
 *          API                                                  *
 *                                                               *
 * History                                                       *
 *         Written by P A Lowe OPM Unlimited Dev                 *
 * Peter Lowe  06/26/08                                          *
 *                                                               *
 * Updated By              For                                   *
 * Peter Lowe 02/04/09    8208515                                *
 * 		                                                           *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GR_FIELD_NAME_PROPERTIES_PUB';

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
PROCEDURE FIELD_NAME_PROPERTIES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_action               IN  VARCHAR2
, p_object               IN  VARCHAR2
, p_property_id          IN VARCHAR2
, p_property_type_indicator IN VARCHAR2
, p_length               IN NUMBER
, p_precision            IN NUMBER
, p_range_min            IN NUMBER
, p_range_max            IN NUMBER
, p_language             IN VARCHAR2
, p_source_language      IN VARCHAR2
, p_description          IN VARCHAR2
, p_label_prop_values_tab IN  GR_FIELD_NAME_PROPERTIES_PUB.gr_label_prop_values_tab_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)

IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'FIELD_NAME_PROPERTIES';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_msg_count             NUMBER  :=0;
  l_debug_flag VARCHAR2(1) := set_debug_flag;

  l_property_id  VARCHAR2(6);
  l_language_code VARCHAR2(4);
  l_missing_count   NUMBER;

  l_last_update_login NUMBER(15,0) := 0;
  L_KEY_EXISTS 	VARCHAR2(1);

  l_display_order    NUMBER;
  l_value            VARCHAR2(30);
  l_value_description VARCHAR2(240);

  dummy              NUMBER;
  i   							 NUMBER;
  row_id        VARCHAR2(18);
  return_status VARCHAR2(1);
  oracle_error  NUMBER;
  msg_data      VARCHAR2(2000);

  LBins_err	EXCEPTION;
  LCins_err EXCEPTION;
  LTadd_err EXCEPTION;
  LT_Exists_Error EXCEPTION;
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
		                  FROM   GR_PROPERTIES_TL
		                  WHERE  PROPERTY_ID = p_PROPERTY_ID);

CURSOR c_get_property_id is
SELECT 1
FROM
GR_PROPERTIES_B B
    where B.PROPERTY_ID = p_property_id;

CURSOR c_get_property_flag is
SELECT 1
FROM
GR_PROPERTIES_B B
    where B.PROPERTY_ID = p_property_id
    and property_type_indicator = 'F';

CURSOR c_get_gr_properties_tl
 IS
   SELECT	1
   FROM	    gr_properties_tl prt
   WHERE	prt.property_id = p_property_id
   AND		prt.language = p_language;

L_MSG_TOKEN       VARCHAR2(100);


BEGIN

  -- Standard Start OF API savepoint

 -- SAVEPOINT FIELD_NAME_PROPERTIES;

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
    --GMD_API_PUB.Log_Message('GR_INVALID_ACTION');
    FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_ACTION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_object is NULL or p_object not in ('C','L','V') then
    --GMD_API_PUB.Log_Message('GR_INVALID_OBJECT');
    FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_OBJECT');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF p_property_id is NULL then
     -- GMD_API_PUB.Log_Message('SY_FIELDNAME');
     FND_MESSAGE.SET_NAME('GMA',
                           'SY_FIELDNAME');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- check Decimal precision is not > 6  if input   -- 8208515
  -- If an invalid value is passed in, an error message will be written to the log file.
         IF p_precision is not NULL and p_precision > 6 then
          GMD_API_PUB.Log_Message('GR_INVALID_PRECISION');
          FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_PRECISION');
    			RAISE FND_API.G_EXC_ERROR;
         END IF;

  -- end 8208515

  l_property_id := p_property_id;
  l_language_code := p_language;

  IF p_action = 'I' then

     IF p_object = 'C' then
      		 --  Validate that the value of Property Id does not already exist in the table GR_PROPERTIES_B.
      		 -- If it does, write an error to the log file.

 					 dummy:= 0;
 				   OPEN c_get_property_id;
	         FETCH c_get_property_id INTO dummy;
					 IF c_get_property_id%FOUND THEN

			        CLOSE c_get_property_id;
			        l_msg_token := p_property_id;
  						RAISE LT_Exists_Error;
			     END IF;

					 CLOSE c_get_property_id;
      		-- Property Type, Language, Source Language and Description values are required
      		-- and an error message will be written to the log file if any of the values are null.
          IF p_property_type_indicator is NULL or p_source_language is NULL or p_language is NULL or p_description is null then
    				--GMD_API_PUB.Log_Message('SY_FIELDNAME');
     				FND_MESSAGE.SET_NAME('GMA',
                           'SY_FIELDNAME');

    				RAISE FND_API.G_EXC_ERROR;
          END IF;
      --	Validate that Property Type is set to either Flag, Numeric, Alphanumeric, Date, Risk Phrase or Safety Phrase.
      --  If an invalid value is passed in, an error message will be written to the log file.
         IF p_property_type_indicator not in ('F','N','A','D','R','S') then
          GMD_API_PUB.Log_Message('SY_INVALID_TYPE');
          FND_MESSAGE.SET_NAME('GMA',
                           'SY_INVALID_TYPE');

    			RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Decimal precision is only valid for a type of numeric
         -- If an invalid value is passed in, an error message will be written to the log file.
         IF p_property_type_indicator <> 'N' and p_precision is not NULL then
          GMD_API_PUB.Log_Message('GR_INVALID_PRECISION');
          FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_PRECISION');
    			RAISE FND_API.G_EXC_ERROR;
         END IF;

         --  If minimum and maximum values are sent in, they must be validated against each other
         --  (e.g. min can't be greater than max).
         --   If an invalid value is passed in, an error message will be written to the log file.

         IF p_range_min is not null and p_range_max is not null then
          	IF (p_range_min > p_range_max ) or ( p_range_max < p_range_min  ) then
          		 GMD_API_PUB.Log_Message('GR_INVALID_RANGE');
          		 FND_MESSAGE.SET_NAME('GR',
                           'GR_INVALID_RANGE');
    					 RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF; -- IF p_range_min is not null and p_range_max is not null then

       --	The values for Property Id, Property Type, Length,
       -- Decimal Precision, Minimum Value and Maximum Value will be written to the GR_PROPERTIES_B table.

        GR_PROPERTIES_B_PKG.Insert_Row
          (p_commit                     => 'F',
          p_called_by_form              => 'F',
          p_property_id =>   p_property_id,
				  p_property_type_indicator =>  p_property_type_indicator,
				  p_length                  => p_length,
				  p_precision               => p_precision,
				  p_range_min               => p_range_min,
				  p_range_max               => p_range_max,
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



          -- need to add base row for language for GR_PROPERTIES_TL

			     gr_properties_tl_pkg.insert_row(
			     	p_commit => 'F',
						p_called_by_form => 'F',
			      p_property_id => p_property_id,
				    p_language => p_language,
				    p_source_lang => p_source_language,
				    p_description => p_description,
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


         -- Insert a record into GR_PROPERTIES_TL for each installed language.

  			 OPEN Cur_count_language;
		     FETCH Cur_count_language INTO l_missing_count;
		     CLOSE Cur_count_language;
		     IF l_missing_count > 0 THEN

		       gr_properties_tl_pkg.Add_Language
		           (p_commit			=> 'F',
							  p_called_by_form 		=> 'F',
					      p_property_id => p_property_id,
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
     						  FND_MSG_PUB.ADD;
	      					RAISE LTadd_err;
	 				  END IF;

					END IF; --  IF l_missing_count > 0 THEN

  		-- 	Insert all associated property values into the GR_PROPERTY_VALUES_TL table


  			  FOR i IN 1 .. p_label_prop_values_tab.count LOOP

		  			  l_display_order := p_label_prop_values_tab(i).display_order;
		  			  l_value := p_label_prop_values_tab(i).value;
		  			  l_value_description :=   p_label_prop_values_tab(i).value_description;


					    IF l_display_order is NOT NULL or l_value is NOT NULL then

							   gr_property_values_tl_pkg.Insert_Row
							    (p_commit			=> 'F',
								  p_called_by_form 		=> 'F',
						      p_property_id => p_property_id,
						      p_language			=> p_language,
								  p_value => l_value,
								  p_display_order=> l_display_order,
								  p_source_lang => p_source_language,
								  p_meaning  => l_value_description,
								  p_created_by   =>                fnd_global.user_id,
								 	p_creation_date   =>             sysdate,
								 	p_last_updated_by  =>            fnd_global.user_id,
								 	p_last_update_date =>            sysdate,
								 	p_last_update_login  =>          l_last_update_login,
								  x_rowid  => row_id,
								  x_return_status		=> return_status,
									x_oracle_error		=> oracle_error,
									x_msg_data			=> msg_data);



						  END IF; --IF l_display_order is NOT NULL or l_value is NOT NULL then

		      END LOOP; --   FOR i IN 1 ..p_label_prop_values_tab.count LOOP


	   ELSIF p_object = 'L' then

        -- Validate that the value of Property Id exists in the table GR_PROPERTIES_B.
        -- If it does not, write an error to the log file

           dummy:= 0;
 					 l_property_id := p_property_id;
	         OPEN c_get_property_id;
	         FETCH c_get_property_id INTO dummy;
					 IF c_get_property_id%NOTFOUND THEN

			        CLOSE c_get_property_id;
			        l_msg_token := l_property_id;
			   			RAISE Row_Missing_Error;
			     END IF;

           OPEN c_get_gr_properties_tl;
				   FETCH c_get_gr_properties_tl INTO dummy;
				   IF c_get_gr_properties_tl%FOUND THEN
				      x_return_status := 'E';
				      l_msg_token := p_property_id|| ' ' || p_language;
				      CLOSE c_get_gr_properties_tl;
				  		RAISE LT_Exists_Error;
				   END IF;
				   CLOSE c_get_gr_properties_tl;


            gr_properties_tl_pkg.insert_row(
			     	p_commit => 'F',
						p_called_by_form => 'F',
			      p_property_id => p_property_id,
				    p_language => p_language,
				    p_source_lang => p_source_language,
				    p_description => p_description,
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


     ELSE   --    object = V  value

            --Validate that the value of Property Id exists in the table GR_PROPERTIES_B and that it is
            -- of property type Flag If it does not, write an error to the log file.
           dummy:= 0;
 					 OPEN c_get_property_flag;
	         FETCH c_get_property_flag INTO dummy;
				   IF c_get_property_flag%NOTFOUND THEN

			        CLOSE c_get_property_flag;
			        l_msg_token := l_property_id|| ' F';
  						RAISE Row_Missing_Error;
			     END IF;


  			  FOR i IN 1 .. p_label_prop_values_tab.count LOOP

		  			  l_display_order := p_label_prop_values_tab(i).display_order;
		  			  l_value := p_label_prop_values_tab(i).value;
		  			  l_value_description :=   p_label_prop_values_tab(i).value_description;

		  		   -- Validate that the value of Language for the specified property exists in the table GR_PROPERTY_VALUES_TL.
		  		   -- If it does , write an error to the log file

            gr_property_values_tl_pkg.Check_Primary_Key
   	   	   		 (p_property_id,
				  	p_language,
				 	 l_value,
				 	 'F',
					  row_id,
					  l_key_exists);

   					IF FND_API.To_Boolean(l_key_exists) THEN
   				     l_msg_token := p_property_id || ' ' || p_language || ' ' || l_value;
   	 					 RAISE LT_Exists_Error;
   					END IF;


					    IF l_display_order is NOT NULL or l_value is NOT NULL then

							   gr_property_values_tl_pkg.Insert_Row
							    (p_commit			=> 'F',
								  p_called_by_form 		=> 'F',
						      p_property_id => p_property_id,
						      p_language			=> p_language,
								  p_value => l_value,
								  p_display_order=> l_display_order,
								  p_source_lang => p_source_language,
								  p_meaning  => l_value_description,
								  p_created_by   =>                fnd_global.user_id,
								 	p_creation_date   =>             sysdate,
								 	p_last_updated_by  =>            fnd_global.user_id,
								 	p_last_update_date =>            sysdate,
								 	p_last_update_login  =>          l_last_update_login,
								  x_rowid  => row_id,
								  x_return_status		=> return_status,
									x_oracle_error		=> oracle_error,
									x_msg_data			=> msg_data);

						  END IF; --IF l_display_order is NOT NULL or l_value is NOT NULL then

		      END LOOP; --   FOR i IN 1 .. p_label_prop_values_tab.count LOOP

     END IF; -- IF p_object = 'C' then

     --  next  is U action


   /*************************************************************************************/

   ELSIF p_action = 'U' then

   -- Validate that the value of Property Id exists in the table GR_PROPERTIES_B.
   -- If it does not, an error message will be written to the log file.

    		 dummy:= 0;
			   OPEN c_get_property_id;
         FETCH c_get_property_id INTO dummy;
				 IF c_get_property_id%NOTFOUND THEN
				    CLOSE c_get_property_id;
		        l_msg_token := l_property_id;
						RAISE Row_Missing_Error;
		     END IF;
		     CLOSE c_get_property_id;


	    IF p_object = 'C' then

	       -- Any non-null, valid values passed in for property type,
	       -- length, decimal precision, minimum value and maximum value will be updated in the GR_PROPERTIES_B table.

		     UPDATE GR_PROPERTIES_B
			   SET	 length     =    nvl(p_length,length),
					 precision			=	 nvl(p_precision,precision),
					 range_min				 = nvl(p_range_min,range_min),
					 range_max				 = nvl(p_range_max,range_max),
           last_updated_by			 = FND_GLOBAL.USER_ID,
					 last_update_date			 = SYSDATE,
					 last_update_login		= l_last_update_login
				 WHERE property_id = l_property_id;
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

         --	If the record for the specified phrase code and language
         -- does not exist in the GR_PROPERTIES_TL table, an error will be written to the log file


          gr_properties_tl_pkg.Check_Primary_Key(
          p_property_id,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

          IF l_key_exists = 'N'  THEN
            l_msg_token := p_property_id|| ' ' || p_language;
   				  RAISE Row_Missing_Error;
   				END IF;
   				--	The value for Property Description will be updated GR_PROPERTIES_TL table for the specified language.

			    UPDATE GR_PROPERTIES_TL
				  SET description = p_description,
						 last_updated_by			 = FND_GLOBAL.USER_ID,
						 last_update_date			 = SYSDATE,
						 last_update_login		=  l_last_update_login
				  WHERE  property_id  = p_property_id
				        and language = p_language;
				  IF SQL%NOTFOUND THEN
				        l_msg_token := p_property_id || ' ' || p_language;
				     RAISE Row_Missing_Error;
				  END IF;

     ELSE   --    object = V (Value)

            --	Validate that the value of Property Id exists in the table GR_PROPERTIES_B
            --  and that it is of property type Flag If it does not, write an error to the log file

           dummy:= 0;
 					 OPEN c_get_property_flag;
	         FETCH c_get_property_flag INTO dummy;
					 IF c_get_property_flag%NOTFOUND THEN

			        CLOSE c_get_property_flag;
			        l_msg_token := l_property_id|| ' F';
  						RAISE Row_Missing_Error;
			     END IF;

            --  Validate that the value of Language for the specified property exists in the
            --  table GR_PROPERTY_VALUES_TL.  If it does, write an error to the log file.

            gr_properties_tl_pkg.Check_Primary_Key
           		 (p_property_id,
				 			 p_language,
				 			 'F',
				 			 row_id,
				  		 l_key_exists);

   				 IF l_key_exists = 'N'  THEN
   				     l_msg_token := p_property_id || ' ' || p_language;
   	 					 RAISE LT_Exists_Error;
   				 END IF;

         -- The values for Language, Value and Value Description will be written to the GR_PROPERTY_VALUES_TL table.
         FOR i IN 1 .. p_label_prop_values_tab.count LOOP

		  			  l_display_order := p_label_prop_values_tab(i).display_order;
		  			  l_value := p_label_prop_values_tab(i).value;
		  			  l_value_description :=   p_label_prop_values_tab(i).value_description;


					    IF l_value is NOT NULL then

					       UPDATE GR_PROPERTY_values_TL
				  				SET meaning  = l_value_description,
								 last_updated_by			 = FND_GLOBAL.USER_ID,
								 last_update_date			 = SYSDATE,
								 last_update_login		=  l_last_update_login
				  			 WHERE  property_id  = p_property_id
				      	  and language = p_language
				      	  and value = l_value;
				 				 IF SQL%NOTFOUND THEN
				      		  l_msg_token := p_property_id || ' ' || p_language;
				     				RAISE Row_Missing_Error;
				  			 END IF;

					    END IF; --IF l_display_order is NOT NULL or l_value is NOT NULL then

		      END LOOP; --   FOR i IN 1 .. p_label_prop_values_tab.count LOOP




     END IF; -- IF p_object = 'C' then

   ELSE -- action is D   (delete)

    		-- Validate that the value of Property Id exists in the table GR_PROPERTIES_B.
        -- If it does not, an error message will be written to the log file.

    		 dummy:= 0;
			   OPEN c_get_property_id;
         FETCH c_get_property_id INTO dummy;
				 IF c_get_property_id%NOTFOUND THEN
				    CLOSE c_get_property_id;
		        l_msg_token := p_property_id;
						RAISE Row_Missing_Error;
		     END IF;
		     CLOSE c_get_property_id;


	      IF p_object = 'C' then

         -- 	Delete all of the property related records in the GR_PROPERTIES_B, GR_PROPERTIES_TL and GR_PROPERTY_VALUES_TL tables.

          delete from GR_PROPERTY_VALUES_TL T
				  where t.PROPERTY_ID = p_PROPERTY_ID;

          delete from GR_PROPERTIES_TL T
				  where t.PROPERTY_ID = p_PROPERTY_ID;

          DELETE FROM GR_PROPERTIES_B
          where PROPERTY_ID = p_PROPERTY_ID;

          IF SQL%NOTFOUND THEN
				        l_msg_token := p_PROPERTY_ID;
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


         -- if the record for the property_id
         --and language does not exist in the GR_PROPERTIES_TL table, an error will be written to the log file.

           gr_properties_tl_pkg.Check_Primary_Key
           		 (p_property_id,
				 			 p_language,
				 			 'F',
				 			 row_id,
				  		 l_key_exists);

   				 IF l_key_exists = 'N'  THEN
   				     l_msg_token := p_property_id || ' ' || p_language;
   	 					 RAISE LT_Exists_Error;
   				 END IF;

          -- Delete the record in GR_PROPERTIES_TL table for the specified language

			    delete  from GR_PROPERTIES_TL
				  WHERE  property_id  = p_property_id
				        and language = p_language;
				  IF SQL%NOTFOUND THEN
				        l_msg_token := p_property_id || ' ' || p_language;
				     RAISE Row_Missing_Error;
				  END IF;


     ELSE   --    object = V(value)

          --	  Validate that the value of Property Id exists in the table GR_PROPERTIES_B
            --  and that it is of property type Flag If it does not, write an error to the log file

           dummy:= 0;
 					 OPEN c_get_property_flag;
	         FETCH c_get_property_flag INTO dummy;
				   IF c_get_property_flag%NOTFOUND THEN

			        CLOSE c_get_property_flag;
			        l_msg_token := p_property_id|| ' F';
  						RAISE Row_Missing_Error;
			     END IF;



         --  Loop through records in input table

         FOR i IN 1 .. p_label_prop_values_tab.count LOOP

		  			  l_display_order := p_label_prop_values_tab(i).display_order;
		  			  l_value := p_label_prop_values_tab(i).value;
		  			  l_value_description :=   p_label_prop_values_tab(i).value_description;

		  			 -- Validate that the value of specified property and language and value does exists in the table GR_PROPERTY_VALUES_TL.
             --  If it does not , write an error to the log file

            gr_property_values_tl_pkg.Check_Primary_Key
   	   	   		 (p_property_id,
				  	p_language,
				 	 l_value,
				 	 'F',
					  row_id,
					  l_key_exists);

          	IF l_key_exists = 'N'  THEN
           		 l_msg_token := p_property_id|| ' ' || p_language || ' ' || l_value;
   				 		 RAISE Row_Missing_Error;
   				  END IF;

          	-- 	Delete the record in GR_PROPERTY_VALUES_TL table for the specified language. .

					  IF l_value is NOT NULL then


					       delete from GR_PROPERTY_values_TL
				  				WHERE property_id  = p_property_id
				      	  and language = p_language
				      	  and value = l_value;
				 				 IF SQL%NOTFOUND THEN
				      		  l_msg_token := p_property_id || ' ' || p_language;
				     				RAISE Row_Missing_Error;
				  			 END IF;

					    END IF; --IF l_value is NOT NULL then

		      END LOOP; --   FOR i IN 1 .. p_label_prop_values_tab.count LOOP


     END IF; -- IF p_object = 'C' then

   END IF; --  IF p_action = 'I' then
IF x_return_status IN (FND_API.G_RET_STS_SUCCESS) AND (FND_API.To_Boolean( p_commit ) ) THEN
 	Commit;
END IF;

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
       --ROLLBACK TO SAVEPOINT FIELD_NAME_PROPERTIES;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);

   WHEN Row_Missing_Error THEN
      --GMD_API_PUB.Log_Message('GR_RECORD_NOT_FOUND');
      --ROLLBACK TO SAVEPOINT FIELD_NAME_PROPERTIES;
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
      --ROLLBACK TO SAVEPOINT FIELD_NAME_PROPERTIES;
      x_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
					 , p_count => x_msg_count
					 , p_data  => x_msg_data
					);
       x_msg_data := FND_MESSAGE.Get;

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      --ROLLBACK TO SAVEPOINT FIELD_NAME_PROPERTIES;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --ROLLBACK TO SAVEPOINT FIELD_NAME_PROPERTIES;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END FIELD_NAME_PROPERTIES;

END GR_FIELD_NAME_PROPERTIES_PUB;

/
