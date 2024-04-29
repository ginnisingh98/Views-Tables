--------------------------------------------------------
--  DDL for Package Body GR_RISK_SAFETY_PHRASES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_RISK_SAFETY_PHRASES_PUB" AS
/*  $Header: GRRISAPB.pls 120.1.12010000.2 2009/06/19 16:22:49 plowe noship $
 *****************************************************************
 *                                                               *
 * Package  GR_RISK_SAFETY_PHRASES_PUB                           *
 *                                                               *
 * Contents RISK_SAFETY_PHRASES                                  *
 *                                                               *
 *                                                               *
 * Use      This is the public layer for the RISK_SAFETY_PHRASES *
 *          API                                                  *
 *                                                               *
 * History                                                       *
 *         Written by Raju OPM Unlimited Dev                     *
 * Peter Lowe  06/30/08                                          *
 *                                                               *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GR_RISK_SAFETY_PHRASES_PUB';

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

PROCEDURE RISK_SAFETY_PHRASES
( p_api_version           IN NUMBER
, p_init_msg_list         IN VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit                IN VARCHAR2        DEFAULT FND_API.G_FALSE
, p_action                IN VARCHAR2
, p_object                IN VARCHAR2
, p_phrase_type           IN VARCHAR2
, p_phrase_code           IN VARCHAR2
, p_language              IN VARCHAR2
, p_source_language       IN VARCHAR2
, p_phrase_text           IN VARCHAR2
, p_attribute_category    IN VARCHAR2
, p_attribute1            IN VARCHAR2
, p_attribute2            IN VARCHAR2
, p_attribute3            IN VARCHAR2
, p_attribute4            IN VARCHAR2
, p_attribute5            IN VARCHAR2
, p_attribute6            IN VARCHAR2
, p_attribute7            IN VARCHAR2
, p_attribute8            IN VARCHAR2
, p_attribute9            IN VARCHAR2
, p_attribute10           IN VARCHAR2
, p_attribute11           IN VARCHAR2
, p_attribute12           IN VARCHAR2
, p_attribute13           IN VARCHAR2
, p_attribute14           IN VARCHAR2
, p_attribute15           IN VARCHAR2
, p_attribute16           IN VARCHAR2
, p_attribute17           IN VARCHAR2
, p_attribute18           IN VARCHAR2
, p_attribute19           IN VARCHAR2
, p_attribute20           IN VARCHAR2
, p_attribute21           IN VARCHAR2
, p_attribute22           IN VARCHAR2
, p_attribute23           IN VARCHAR2
, p_attribute24           IN VARCHAR2
, p_attribute25           IN VARCHAR2
, p_attribute26           IN VARCHAR2
, p_attribute27           IN VARCHAR2
, p_attribute28           IN VARCHAR2
, p_attribute29           IN VARCHAR2
, p_attribute30           IN VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2) IS

  --local variables
  l_api_name              CONSTANT VARCHAR2 (30) := 'RISK_SAFETY_PHRASES';
  l_api_version           CONSTANT NUMBER        := 1.0;
  l_msg_count             NUMBER  :=0;
  l_debug_flag VARCHAR2(1) := 'N';-- set_debug_flag;
  l_language_code VARCHAR2(4);
  l_missing_count   NUMBER;
  l_last_update_login NUMBER(15,0) := 0;
  l_key_exists 	VARCHAR2(1);


  return_status VARCHAR2(1);
  oracle_error  NUMBER;
  msg_data      VARCHAR2(2000);
  row_id        VARCHAR2(18);
  dummy         NUMBER;

--Exception
  LBins_err EXCEPTION;
  LCins_err EXCEPTION;
  LTadd_err EXCEPTION;
  LTL_del_err EXCEPTION;
  LT_EXISTS_ERROR EXCEPTION;
  ROW_MISSING_ERROR EXCEPTION;

-- Cursor Definitions

CURSOR c_get_language IS
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
                    FROM   gr_safety_phrases_TL
                    WHERE  safety_phrase_code = p_phrase_code);

CURSOR Cur_count_risk_language IS
  SELECT count (language_code)
  FROM   fnd_languages
  WHERE  installed_flag IN ('I', 'B')
  AND language_code not in
                   (SELECT language
                    FROM   gr_risk_phrases_TL
                    WHERE  risk_phrase_code = p_phrase_code);

CURSOR c_get_safety_phrase_code IS
  SELECT safety_phrase_code
  FROM	gr_safety_phrases_b
  WHERE	safety_phrase_code = p_phrase_code;
safetycode			c_get_safety_phrase_code%ROWTYPE;

CURSOR c_get_safety_phrase_tl IS
  SELECT  1
  FROM   gr_safety_phrases_TL
  WHERE  safety_phrase_code = p_phrase_code
  AND language = p_language;

CURSOR c_get_risk_phrase_code IS
  SELECT risk_phrase_code
  FROM	gr_risk_phrases_b
  WHERE	risk_phrase_code = p_phrase_code;
riskcode			c_get_risk_phrase_code%ROWTYPE;

CURSOR c_get_risk_phrase_tl IS
  SELECT  1
  FROM   gr_risk_phrases_TL
  WHERE  risk_phrase_code = p_phrase_code
  AND language = p_language;

  L_MSG_TOKEN       VARCHAR2(100);
BEGIN
  /*  Standard call to check for call compatibility.  */

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_int_msg_list is set TRUE.   */
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --   Initialize API return Parameters
  x_return_status   := FND_API.G_RET_STS_SUCCESS;

/* check mandatory inputs */

  IF p_action is NULL or p_action not in ('I','U','D')  then
     FND_MESSAGE.SET_NAME('GR','GR_INVALID_ACTION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_object is NULL or p_object not in ('C','L') then
    FND_MESSAGE.SET_NAME('GR','GR_INVALID_OBJECT');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_phrase_type is NULL or p_phrase_type not in ('R','S') then
    FND_MESSAGE.SET_NAME('GR','GR_INVALID_PHRASE');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_phrase_code is NULL then
    FND_MESSAGE.SET_NAME('GMA','SY_FIELDNAME');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_action = 'I' then
    -- Language, Source Language and Description values are required
    -- and an error message will be written to the log file if any of the values are null.
    IF p_language is NULL or p_source_language is NULL or p_phrase_text is null then
      FND_MESSAGE.SET_NAME('GMA','SY_FIELDNAME');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_phrase_type = 'S' THEN
      IF p_object = 'C' then
        --  Validate that the value of Safety phrase code does not already exist in the table
        --  GR_SAFETY_PHRASES_B.If it does, write an error to the log file
        OPEN c_get_safety_phrase_code;
	FETCH c_get_safety_phrase_code INTO safetycode;
	IF c_get_safety_phrase_code%NOTFOUND THEN
	  null;
	ELSE
	  x_return_status := 'E';
	  l_msg_token := p_phrase_code;
	  CLOSE c_get_safety_phrase_code;
	  RAISE LT_Exists_Error;
	END IF;
	CLOSE c_get_safety_phrase_code;

         -- insert a record for GR_SAFETY_PHRASES_B
         gr_safety_phrases_b_pkg.Insert_Row
          (p_commit               => 'T',
           p_called_by_form       => 'F',
	   p_safety_phrase_code   => p_phrase_code,
	   p_additional_text_type => 'N',
           p_lookup_type          => NULL  ,
	   p_lookup_code 	  => NULL 	,
	   p_attribute_category   => p_attribute_category 	,
	   p_attribute1 	  => p_attribute1  	,
	   p_attribute2 	  => p_attribute2 	,
	   p_attribute3 	  => p_attribute3 	,
	   p_attribute4 	  => p_attribute4 	,
	   p_attribute5 	  => p_attribute5 	,
	   p_attribute6 	  => p_attribute6 	,
	   p_attribute7 	  => p_attribute7 	,
	   p_attribute8 	  => p_attribute8  	,
	   p_attribute9 	  => p_attribute9  	,
	   p_attribute10 	  => p_attribute10 	,
	   p_attribute11 	  => p_attribute11 	,
	   p_attribute12 	  => p_attribute12 	,
	   p_attribute13 	  => p_attribute13 	,
	   p_attribute14 	  => p_attribute14 	,
	   p_attribute15 	  => p_attribute15 	,
	   p_attribute16 	  => p_attribute16 	,
	   p_attribute17 	  => p_attribute17 	,
	   p_attribute18 	  => p_attribute18 	,
	   p_attribute19 	  => p_attribute19 	,
	   p_attribute20 	  => p_attribute20	,
	   p_attribute21 	  => p_attribute21 	,
	   p_attribute22	  => p_attribute22 	,
	   p_attribute23 	  => p_attribute23 	,
	   p_attribute24 	  => p_attribute24 	,
	   p_attribute25 	  => p_attribute25 	,
	   p_attribute26 	  => p_attribute26 	,
	   p_attribute27 	  => p_attribute27 	,
	   p_attribute28 	  => p_attribute28 	,
	   p_attribute29 	  => p_attribute29      ,
	   p_attribute30 	  => p_attribute30      ,
	   p_created_by           => FND_GLOBAL.USER_ID,
	   p_creation_date        => SYSDATE,
	   p_last_updated_by      => FND_GLOBAL.USER_ID,
	   p_last_update_date     => SYSDATE,
	   p_last_update_login    => l_last_update_login,
	   x_rowid  		  => row_id,
	   x_return_status	  => return_status,
	   x_oracle_error	  => oracle_error,
	   x_msg_data		  => msg_data);

         IF return_status <> 'S' THEN
           GMD_API_PUB.Log_Message(msg_data);
      	   RAISE LBins_err;
 	 END IF;

         -- need to add base row for language for GR_SAFETY_PHRASES_TL
         gr_safety_phrases_tl_pkg.insert_row(p_commit 			=> 'T',
					    p_called_by_form 		=> 'F',
					    p_safety_phrase_code 	=> p_phrase_code,
					    p_language 			=> p_language,
					    p_source_language 		=> p_source_language,
					    p_safety_phrase_description => p_phrase_text,
					    p_created_by                => fnd_global.user_id,
				  	    p_creation_date   		=> sysdate,
				  	    p_last_updated_by  		=> fnd_global.user_id,
				  	    p_last_update_date 		=> sysdate,
				  	    p_last_update_login  	=> l_last_update_login,
				 	    x_rowid  			=> row_id,
				            x_return_status		=> return_status,
					    x_oracle_error		=> oracle_error,
					    x_msg_data			=> msg_data);

          IF return_status <> 'S' THEN
            GMD_API_PUB.Log_Message(msg_data);
            RAISE LCins_err;
 	  END IF;

          -- Insert a record into GR_SAFETY_PHRASES_TL for each installed language.
          OPEN Cur_count_language;
	  FETCH Cur_count_language INTO l_missing_count;
	  CLOSE Cur_count_language;
	  IF l_missing_count > 0 THEN
	    gr_safety_phrases_tl_pkg.Add_Language (p_commit	      => 'T',
						  p_called_by_form    => 'F',
					          p_safety_phrase_code => p_phrase_code,
					          p_language	      => p_language,
						  x_return_status     => return_status,
						  x_oracle_error      => oracle_error,
						  x_msg_data	      => msg_data);
	    IF return_status <> 'S' THEN
	      GMD_API_PUB.Log_Message('GR_SAFET_PHRASE_ADD_LANG_ERROR');
	      FND_MESSAGE.SET_NAME('GR','GR_SAFET_PHRASE_ADD_LANG_ERROR');
              FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
      	      FND_MSG_PUB.ADD;
	      RAISE LTadd_err;
	    END IF;
	  END IF; --  IF l_missing_count > 0 THEN

      ELSIF p_object = 'L' then
        --  Validate that the value of Safety phrase code does not already exist in the table
        --  GR_SAFETY_PHRASES_B.If it does, write an error to the log file
        OPEN c_get_safety_phrase_code;
	FETCH c_get_safety_phrase_code INTO safetycode;
	IF c_get_safety_phrase_code%NOTFOUND THEN
	  x_return_status := 'E';
	  l_msg_token := p_phrase_code;
	  CLOSE c_get_safety_phrase_code;
	  RAISE LT_Exists_Error;
	END IF;
	CLOSE c_get_safety_phrase_code;

        -- Validate that the value of Language for the specified property does not exist in the table
        -- GR_SAFETY_PHRASES_TL. if it does, write an error to the log file.

        OPEN c_get_safety_phrase_tl;
	FETCH c_get_safety_phrase_tl INTO dummy;
	IF c_get_safety_phrase_tl%FOUND THEN
	  x_return_status := 'E';
	  l_msg_token := p_phrase_code|| ' ' || p_language;
          CLOSE c_get_safety_phrase_tl;
          RAISE LT_Exists_Error;
	END IF;
	CLOSE c_get_safety_phrase_tl;

         -- The values for Source Language, Language and Description will be written to the GR_SAFETY_PHRASES_TL table;
         gr_safety_phrases_tl_pkg.insert_row(p_commit 			=> 'T',
					    p_called_by_form 		=> 'F',
					    p_safety_phrase_code 	=> p_phrase_code,
					    p_language 			=> p_language,
					    p_source_language 		=> p_source_language,
					    p_safety_phrase_description => p_phrase_text,
					    p_created_by                => fnd_global.user_id,
				  	    p_creation_date   		=> sysdate,
				  	    p_last_updated_by  		=> fnd_global.user_id,
				  	    p_last_update_date 		=> sysdate,
				  	    p_last_update_login  	=> l_last_update_login,
				 	    x_rowid  			=> row_id,
				            x_return_status		=> return_status,
					    x_oracle_error		=> oracle_error,
					    x_msg_data			=> msg_data);

          IF return_status <> 'S' THEN
            GMD_API_PUB.Log_Message(msg_data);
            RAISE LCins_err;
 	  END IF;
      END IF; -- IF p_object = 'C' then

    ELSIF p_phrase_type = 'R' THEN
      IF p_object = 'C' then
        --  Validate that the value of Risk phrase code does not already exist in the table
        --  GR_RISK_PHRASES_B.If it does, write an error to the log file
        OPEN c_get_risk_phrase_code;
	FETCH c_get_risk_phrase_code INTO riskcode;
	IF c_get_risk_phrase_code%NOTFOUND THEN
	  null;
	ELSE
	  x_return_status := 'E';
	  l_msg_token := p_phrase_code;
	  CLOSE c_get_risk_phrase_code;
	  RAISE LT_Exists_Error;
	END IF;
	CLOSE c_get_risk_phrase_code;

         -- insert a record for GR_RISK_PHRASES_B
         gr_risk_phrases_b_pkg.Insert_Row
          (p_commit               => 'T',
           p_called_by_form       => 'F',
	   p_risk_phrase_code     => p_phrase_code,
	   p_additional_text_indicator => 'N',
           p_lookup_type          => NULL  ,
	   p_lookup_code 	  => NULL 	,
	   p_attribute_category   => p_attribute_category 	,
	   p_attribute1 	  => p_attribute1  	,
	   p_attribute2 	  => p_attribute2 	,
	   p_attribute3 	  => p_attribute3 	,
	   p_attribute4 	  => p_attribute4 	,
	   p_attribute5 	  => p_attribute5 	,
	   p_attribute6 	  => p_attribute6 	,
	   p_attribute7 	  => p_attribute7 	,
	   p_attribute8 	  => p_attribute8  	,
	   p_attribute9 	  => p_attribute9  	,
	   p_attribute10 	  => p_attribute10 	,
	   p_attribute11 	  => p_attribute11 	,
	   p_attribute12 	  => p_attribute12 	,
	   p_attribute13 	  => p_attribute13 	,
	   p_attribute14 	  => p_attribute14 	,
	   p_attribute15 	  => p_attribute15 	,
	   p_attribute16 	  => p_attribute16 	,
	   p_attribute17 	  => p_attribute17 	,
	   p_attribute18 	  => p_attribute18 	,
	   p_attribute19 	  => p_attribute19 	,
	   p_attribute20 	  => p_attribute20	,
	   p_attribute21 	  => p_attribute21 	,
	   p_attribute22	  => p_attribute22 	,
	   p_attribute23 	  => p_attribute23 	,
	   p_attribute24 	  => p_attribute24 	,
	   p_attribute25 	  => p_attribute25 	,
	   p_attribute26 	  => p_attribute26 	,
	   p_attribute27 	  => p_attribute27 	,
	   p_attribute28 	  => p_attribute28 	,
	   p_attribute29 	  => p_attribute29      ,
	   p_attribute30 	  => p_attribute30      ,
	   p_created_by           => FND_GLOBAL.USER_ID,
	   p_creation_date        => SYSDATE,
	   p_last_updated_by      => FND_GLOBAL.USER_ID,
	   p_last_update_date     => SYSDATE,
	   p_last_update_login    => l_last_update_login,
	   x_rowid  		  => row_id,
	   x_return_status	  => return_status,
	   x_oracle_error	  => oracle_error,
	   x_msg_data		  => msg_data);

         IF return_status <> 'S' THEN
           GMD_API_PUB.Log_Message(msg_data);
      	   RAISE LBins_err;
 	 END IF;

         -- need to add base row for language for GR_RISK_PHRASES_TL
         gr_risk_phrases_tl_pkg.insert_row(p_commit 			=> 'T',
					    p_called_by_form 		=> 'F',
					    p_risk_phrase_code 		=> p_phrase_code,
					    p_language 			=> p_language,
					    p_source_language 		=> p_source_language,
					    p_risk_description 		=> p_phrase_text,
					    p_created_by                => fnd_global.user_id,
				  	    p_creation_date   		=> sysdate,
				  	    p_last_updated_by  		=> fnd_global.user_id,
				  	    p_last_update_date 		=> sysdate,
				  	    p_last_update_login  	=> l_last_update_login,
				 	    x_rowid  			=> row_id,
				            x_return_status		=> return_status,
					    x_oracle_error		=> oracle_error,
					    x_msg_data			=> msg_data);

          IF return_status <> 'S' THEN
            GMD_API_PUB.Log_Message(msg_data);
            RAISE LCins_err;
 	  END IF;

          -- Insert a record into GR_RISK_PHRASES_TL for each installed language.
          OPEN Cur_count_risk_language;
	  FETCH Cur_count_risk_language INTO l_missing_count;
	  CLOSE Cur_count_risk_language;
	  IF l_missing_count > 0 THEN
	    gr_risk_phrases_tl_pkg.Add_Language (p_commit	      => 'T',
						  p_called_by_form    => 'F',
					          p_risk_phrase_code  => p_phrase_code,
					          p_language	      => p_language,
						  x_return_status     => return_status,
						  x_oracle_error      => oracle_error,
						  x_msg_data	      => msg_data);
	    IF return_status <> 'S' THEN
	      GMD_API_PUB.Log_Message('GR_RISK_PHRASE_ADD_LANG_ERROR');
	      FND_MESSAGE.SET_NAME('GR','GR_RISK_PHRASE_ADD_LANG_ERROR');
              FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
      	      FND_MSG_PUB.ADD;
	      RAISE LTadd_err;
	    END IF;
	  END IF; --  IF l_missing_count > 0 THEN

      ELSIF p_object = 'L' then
        --  Validate that the value of Safety phrase code does not already exist in the table
        --  GR_RISK_PHRASES_B.If it does, write an error to the log file
        OPEN c_get_risk_phrase_code;
	FETCH c_get_risk_phrase_code INTO safetycode;
	IF c_get_risk_phrase_code%NOTFOUND THEN
	  x_return_status := 'E';
	  l_msg_token := p_phrase_code;
	  CLOSE c_get_risk_phrase_code;
	  RAISE LT_Exists_Error;
	END IF;
	CLOSE c_get_risk_phrase_code;

        -- Validate that the value of Language for the specified risk phrase does not exist in the table
        -- GR_RISK_PHRASES_TL.If it does, write an error to the log file.

        OPEN c_get_risk_phrase_tl;
	FETCH c_get_risk_phrase_tl INTO dummy;
	IF c_get_risk_phrase_tl%FOUND THEN
	  x_return_status := 'E';
	  l_msg_token := p_phrase_code|| ' ' || p_language;
          CLOSE c_get_risk_phrase_tl;
          RAISE LT_Exists_Error;
	END IF;
	CLOSE c_get_risk_phrase_tl;

         -- The values for Source Language, Language and Description will be written to the GR_RISK_PHRASES_TL table;
         gr_risk_phrases_tl_pkg.insert_row(p_commit 			=> 'T',
					    p_called_by_form 		=> 'F',
					    p_risk_phrase_code 		=> p_phrase_code,
					    p_language 			=> p_language,
					    p_source_language 		=> p_source_language,
					    p_risk_description 		=> p_phrase_text,
					    p_created_by                => fnd_global.user_id,
				  	    p_creation_date   		=> sysdate,
				  	    p_last_updated_by  		=> fnd_global.user_id,
				  	    p_last_update_date 		=> sysdate,
				  	    p_last_update_login  	=> l_last_update_login,
				 	    x_rowid  			=> row_id,
				            x_return_status		=> return_status,
					    x_oracle_error		=> oracle_error,
					    x_msg_data			=> msg_data);

          IF return_status <> 'S' THEN
            GMD_API_PUB.Log_Message(msg_data);
            RAISE LCins_err;
 	  END IF;
      END IF; -- IF p_object = 'C' then
    END IF; -- IF p_phrase_type = 'S' THEN
  ELSIF p_action = 'U' then
    --  Validate that the value of Safety phrase code does not already exist in the table
    --  GR_SAFETY_PHRASES_B.If it does, write an error to the log file
    IF p_phrase_type = 'S' THEN
      OPEN c_get_safety_phrase_code;
      FETCH c_get_safety_phrase_code INTO safetycode;
      IF c_get_safety_phrase_code%NOTFOUND THEN
        x_return_status := 'E';
        l_msg_token := p_phrase_code;
        CLOSE c_get_safety_phrase_code;
        RAISE LT_Exists_Error;
      END IF;
      CLOSE c_get_safety_phrase_code;
      IF p_object = 'C' THEN
        UPDATE GR_SAFETY_PHRASES_B
        SET attribute_category = p_attribute_category 	,
	   attribute1 	  = p_attribute1  	,
	   attribute2 	  = p_attribute2 	,
	   attribute3 	  = p_attribute3 	,
	   attribute4 	  = p_attribute4 	,
	   attribute5 	  = p_attribute5 	,
	   attribute6 	  = p_attribute6 	,
	   attribute7 	  = p_attribute7 	,
	   attribute8 	  = p_attribute8  	,
	   attribute9 	  = p_attribute9  	,
	   attribute10 	  = p_attribute10 	,
	   attribute11 	  = p_attribute11 	,
	   attribute12 	  = p_attribute12 	,
	   attribute13 	  = p_attribute13 	,
	   attribute14 	  = p_attribute14 	,
	   attribute15 	  = p_attribute15 	,
	   attribute16 	  = p_attribute16 	,
	   attribute17 	  = p_attribute17 	,
	   attribute18 	  = p_attribute18 	,
	   attribute19 	  = p_attribute19 	,
	   attribute20 	  = p_attribute20	,
	   attribute21 	  = p_attribute21 	,
	   attribute22	  = p_attribute22 	,
	   attribute23 	  = p_attribute23 	,
	   attribute24 	  = p_attribute24 	,
	   attribute25 	  = p_attribute25 	,
	   attribute26 	  = p_attribute26 	,
	   attribute27 	  = p_attribute27 	,
	   attribute28 	  = p_attribute28 	,
	   attribute29 	  = p_attribute29      ,
	   attribute30 	  = p_attribute30      ,
	   last_updated_by      = FND_GLOBAL.USER_ID,
	   last_update_date     = SYSDATE,
	   last_update_login    = l_last_update_login
        WHERE safety_phrase_code = p_phrase_code;
        IF SQL%NOTFOUND THEN
          RAISE Row_Missing_Error;
        END IF;
      ELSIF p_object = 'L' then
        -- If the value for Language is null or invalid, write an error to the log file.
        IF p_language is NULL then
          l_msg_token := l_language_code;
	  RAISE Row_Missing_Error;
        END IF;

        /*Check the language codes */
        l_language_code := p_language;
        OPEN c_get_language;
        FETCH c_get_language INTO LangRecord;
        IF c_get_language%NOTFOUND THEN
          CLOSE c_get_language;
          l_msg_token := l_language_code;
	  RAISE Row_Missing_Error;
        END IF;
        CLOSE c_get_language;
        -- If the record for the specified safety phrase and language does not exist in the
        -- GR_SAFETY_PHRASES_TL table,an error will be written to the log file.
        gr_safety_phrases_tl_pkg.Check_Primary_Key(
            			  p_phrase_code,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

        IF l_key_exists = 'N'  THEN
          l_msg_token := p_phrase_code|| ' ' || p_language;
          RAISE Row_Missing_Error;
   	END IF;
        -- The value for Description will be updated GR_SAFETY_PHRASES_TL table for the specified language.
        UPDATE GR_SAFETY_PHRASES_TL
	SET safety_phrase_description = p_phrase_text,
            source_lang 		= p_source_language,
            last_updated_by	        = FND_GLOBAL.USER_ID,
            last_update_date		= SYSDATE,
	    last_update_login		= l_last_update_login
        WHERE safety_phrase_code      = p_phrase_code
	AND language = p_language;
        IF SQL%NOTFOUND THEN
	  l_msg_token := p_phrase_code || ' ' || p_language;
	  RAISE Row_Missing_Error;
	END IF;
      END IF;

    ELSIF p_phrase_type = 'R' THEN
      OPEN c_get_risk_phrase_code;
      FETCH c_get_risk_phrase_code INTO riskcode;
      IF c_get_risk_phrase_code%NOTFOUND THEN
        x_return_status := 'E';
        l_msg_token := p_phrase_code;
        CLOSE c_get_risk_phrase_code;
        RAISE LT_Exists_Error;
      END IF;
      CLOSE c_get_risk_phrase_code;
      IF p_object = 'C' THEN
        UPDATE GR_RISK_PHRASES_B
        SET  attribute_category = p_attribute_category 	,
	   attribute1 	  = p_attribute1  	,
	   attribute2 	  = p_attribute2 	,
	   attribute3 	  = p_attribute3 	,
	   attribute4 	  = p_attribute4 	,
	   attribute5 	  = p_attribute5 	,
	   attribute6 	  = p_attribute6 	,
	   attribute7 	  = p_attribute7 	,
	   attribute8 	  = p_attribute8  	,
	   attribute9 	  = p_attribute9  	,
	   attribute10 	  = p_attribute10 	,
	   attribute11 	  = p_attribute11 	,
	   attribute12 	  = p_attribute12 	,
	   attribute13 	  = p_attribute13 	,
	   attribute14 	  = p_attribute14 	,
	   attribute15 	  = p_attribute15 	,
	   attribute16 	  = p_attribute16 	,
	   attribute17 	  = p_attribute17 	,
	   attribute18 	  = p_attribute18 	,
	   attribute19 	  = p_attribute19 	,
	   attribute20 	  = p_attribute20	,
	   attribute21 	  = p_attribute21 	,
	   attribute22	  = p_attribute22 	,
	   attribute23 	  = p_attribute23 	,
	   attribute24 	  = p_attribute24 	,
	   attribute25 	  = p_attribute25 	,
	   attribute26 	  = p_attribute26 	,
	   attribute27 	  = p_attribute27 	,
	   attribute28 	  = p_attribute28 	,
	   attribute29 	  = p_attribute29      ,
	   attribute30 	  = p_attribute30      ,
	   last_updated_by      = FND_GLOBAL.USER_ID,
	   last_update_date     = SYSDATE,
	   last_update_login    = l_last_update_login
        WHERE risk_phrase_code = p_phrase_code;
        IF SQL%NOTFOUND THEN
          RAISE Row_Missing_Error;
        END IF;
      ELSIF p_object = 'L' then
        -- If the value for Language is null or invalid, write an error to the log file.
        IF p_language is NULL then
          l_msg_token := l_language_code;
	  RAISE Row_Missing_Error;
        END IF;

        /*Check the language codes */
        l_language_code := p_language;
        OPEN c_get_language;
        FETCH c_get_language INTO LangRecord;
        IF c_get_language%NOTFOUND THEN
          CLOSE c_get_language;
          l_msg_token := l_language_code;
	  RAISE Row_Missing_Error;
        END IF;
        CLOSE c_get_language;
        -- If the record for the specified risk phrase and language does not exist in the
        -- GR_RISK_PHRASES_TL table,an error will be written to the log file.
        gr_risk_phrases_tl_pkg.Check_Primary_Key(
            			  p_phrase_code,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);

        IF l_key_exists = 'N'  THEN
          l_msg_token := p_phrase_code|| ' ' || p_language;
          RAISE Row_Missing_Error;
   	END IF;
        -- The value for Description will be updated GR_RISK_PHRASES_TL table for the specified language.
        UPDATE GR_RISK_PHRASES_TL
	SET risk_description   = p_phrase_text,
            source_lang        = p_source_language,
            last_updated_by    = FND_GLOBAL.USER_ID,
            last_update_date   = SYSDATE,
	    last_update_login  = l_last_update_login
        WHERE risk_phrase_code = p_phrase_code
	AND language = p_language;
        IF SQL%NOTFOUND THEN
	  l_msg_token := p_phrase_code || ' ' || p_language;
	  RAISE Row_Missing_Error;
	END IF;
      END IF;
    END IF;
  ELSE -- action is D (delete)
    IF p_phrase_type = 'S' THEN
      OPEN c_get_safety_phrase_code;
      FETCH c_get_safety_phrase_code INTO safetycode;
      IF c_get_safety_phrase_code%NOTFOUND THEN
        x_return_status := 'E';
        l_msg_token := p_phrase_code;
        CLOSE c_get_safety_phrase_code;
        RAISE LT_Exists_Error;
      END IF;
      CLOSE c_get_safety_phrase_code;
      IF p_object = 'C' THEN
        --Delete all the rows in tl and b tables for the passed safety phrase code
        DELETE FROM gr_safety_phrases_tl
        WHERE safety_phrase_code = p_phrase_code;

        DELETE FROM gr_safety_phrases_b
        WHERE safety_phrase_code = p_phrase_code;
        IF SQL%NOTFOUND THEN
          l_msg_token := p_phrase_code || ' ' || p_language;
	   RAISE Row_Missing_Error;
        END IF;
      ELSIF p_object = 'L' THEN
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
        -- If the record for the specified safety phrase and language does not exist in the
        -- GR_SAFETY_PHRASES_TL table,an error will be written to the log file.
        gr_safety_phrases_tl_pkg.Check_Primary_Key(
            			  p_phrase_code,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);
        IF l_key_exists = 'N'  THEN
          l_msg_token := p_phrase_code|| ' ' || p_language;
          RAISE Row_Missing_Error;
   	END IF;
        -- delete form tl table for that language specific row

	DELETE  gr_safety_phrases_tl
	WHERE  safety_phrase_code  = p_phrase_code
	and language = p_language;
	IF SQL%NOTFOUND THEN
	  l_msg_token := p_phrase_code || ' ' || p_language;
	  RAISE Row_Missing_Error;
	END IF;
      END IF;
    ELSIF p_phrase_type = 'R' THEN
      OPEN c_get_risk_phrase_code;
      FETCH c_get_risk_phrase_code INTO riskcode;
      IF c_get_risk_phrase_code%NOTFOUND THEN
        x_return_status := 'E';
        l_msg_token := p_phrase_code;
        CLOSE c_get_risk_phrase_code;
        RAISE LT_Exists_Error;
      END IF;
      CLOSE c_get_risk_phrase_code;
      IF p_object = 'C' THEN
        --Delete all the rows in tl and b tables for the passed risk phrase code
        DELETE FROM gr_risk_phrases_tl
        WHERE risk_phrase_code = p_phrase_code;

        DELETE FROM gr_risk_phrases_b
        WHERE risk_phrase_code = p_phrase_code;
        IF SQL%NOTFOUND THEN
          l_msg_token := p_phrase_code || ' ' || p_language;
	   RAISE Row_Missing_Error;
        END IF;
      ELSIF p_object = 'L' THEN
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
        -- If the record for the specified safety phrase and language does not exist in the
        -- GR_SAFETY_PHRASES_TL table,an error will be written to the log file.
        gr_risk_phrases_tl_pkg.Check_Primary_Key(
            			  p_phrase_code,
				  p_language,
				  'F',
				  row_id,
				  l_key_exists);
        IF l_key_exists = 'N'  THEN
          l_msg_token := p_phrase_code|| ' ' || p_language;
          RAISE Row_Missing_Error;
   	END IF;
        -- delete form tl table for that language specific row

	DELETE  gr_risk_phrases_tl
	WHERE  risk_phrase_code  = p_phrase_code
	and language = p_language;
	IF SQL%NOTFOUND THEN
	  l_msg_token := p_phrase_code || ' ' || p_language;
	  RAISE Row_Missing_Error;
	END IF;
      END IF;
    END IF;
  END IF; -- IF p_action = 'I' then
  IF (X_RETURN_STATUS = 'S') THEN
    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
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

      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
	  			   , p_count => x_msg_count
				   , p_data  => x_msg_data);
        x_msg_data := FND_MESSAGE.Get;

      WHEN LT_Exists_Error THEN
       x_return_status := 'E';
       oracle_error := APP_EXCEPTION.Get_Code;
     FND_MESSAGE.SET_NAME('GR','GR_RECORD_EXISTS');
     FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

     WHEN LTadd_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       --ROLLBACK TO SAVEPOINT FIELD_NAME_CLASSES;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                 P_data  => x_msg_data);

   WHEN Row_Missing_Error THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR','GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',l_msg_token,FALSE);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
				 , p_count => x_msg_count
				 , p_data  => x_msg_data);

     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name);

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data);

END RISK_SAFETY_PHRASES;

END GR_RISK_SAFETY_PHRASES_PUB;

/
