--------------------------------------------------------
--  DDL for Package Body IGC_CC_OPN_UPD_GET_LNK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_OPN_UPD_GET_LNK_PUB" AS
/* $Header: IGCOUGLB.pls 120.10.12000000.5 2007/10/25 14:29:21 smannava ship $ */

-- --------------------------------------------------------------------
-- Define Global variables for package below
-- --------------------------------------------------------------------

   G_PKG_NAME     VARCHAR2(30)   ;
   g_debug_msg	VARCHAR2(10000);

-- l_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');

-- Variables for logging levels
--bug 3199488
   g_debug_level          NUMBER;
   g_state_level          NUMBER;
   g_proc_level           NUMBER;
   g_event_level          NUMBER;
   g_excep_level          NUMBER;
   g_error_level          NUMBER;
   g_unexp_level          NUMBER;
   g_path                 VARCHAR2(255);
   g_debug_mode           VARCHAR2(1);

--
-- Generic Procedure for putting out NOCOPY debug information
--
PROCEDURE Output_Debug (
   p_path             IN VARCHAR2,
   p_debug_msg        IN VARCHAR2
);

--
-- This procedure is called with cc_open_api_main procedure
-- This validates the entire record.
--
PROCEDURE CC_OPEN_API_VALIDATE (
   p_cc_header_rec       IN OUT NOCOPY CC_HEADER_REC_TYPE,
   p_current_org_id          IN igc_cc_headers.org_id%TYPE,
   p_current_sob_id          IN igc_cc_headers.set_of_books_id%TYPE,
   p_func_currency_code      IN igc_cc_headers.currency_code%TYPE,
   x_valid_cc               OUT NOCOPY VARCHAR2,
   x_currency_code          OUT NOCOPY igc_cc_headers.currency_code%TYPE,
   x_conversion_type        OUT NOCOPY igc_cc_headers.conversion_type%TYPE,
   x_conversion_date        OUT NOCOPY igc_cc_headers.conversion_date%TYPE,
   x_conversion_rate        OUT NOCOPY igc_cc_headers.conversion_rate%TYPE
);

--
-- This procedure is called with cc_open_api_main procedure
-- This procedure is used to derive the cc_header_id number.

PROCEDURE CC_OPEN_API_DERIVE (
   x_header_id     OUT NOCOPY NUMBER
);

-- Main program which selects all the records from Header PL-SQL table
-- and calls other programs for processing
PROCEDURE CC_Open_API_Main (
   p_api_version         IN   NUMBER,
   p_init_msg_list       IN   VARCHAR2 ,
   p_commit              IN   VARCHAR2,
   p_validation_level    IN   NUMBER,
   p_cc_header_rec       IN   CC_HEADER_REC_TYPE,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
) IS

   l_api_name       		VARCHAR2(30);
   l_api_version    		NUMBER ;
   l_debug          		VARCHAR2 (1);
   l_valid_cc		    	VARCHAR2(2000);
   l_error_status         	VARCHAR2(1);
   l_current_org_id       	NUMBER;
   l_current_user_id      	NUMBER;
   l_current_login_id     	NUMBER;
   l_current_set_of_books_id 	NUMBER;
   l_row_id               	VARCHAR2(18);
   l_flag                 	VARCHAR2(1);
   l_header_id            	NUMBER;
   l_parent_header_id     	NUMBER;
   l_func_currency_code   	VARCHAR2(15);
   l_return_status        	VARCHAR2(1);
   l_msg_count            	NUMBER;
   l_msg_data             	VARCHAR2(12000);
   l_error_text           	VARCHAR2(12000);
   l_msg_buf              	VARCHAR2(2000);
   l_error_message	      	VARCHAR2(240);
   l_cc_header_rec              CC_HEADER_REC_TYPE;
   l_status		      	VARCHAR2(240);
   x_valid_cc			VARCHAR2(2000);
   x_currency_code          	igc_cc_headers.currency_code%TYPE;
   x_conversion_type        	igc_cc_headers.conversion_type%TYPE;
   x_conversion_date        	igc_cc_headers.conversion_date%TYPE;
   x_conversion_rate        	igc_cc_headers.conversion_rate%TYPE;
   l_full_path                  VARCHAR(500);


   l_init_msg_list         VARCHAR2(2000);
   l_commit                VARCHAR2(2000);
   l_validation_level      NUMBER;
BEGIN
--Added by svaithil for GSCC warnings

   l_init_msg_list    := nvl(p_init_msg_list,FND_API.G_FALSE);
   l_commit           := nvl(p_commit,FND_API.G_FALSE);
   l_validation_level := nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL);
   l_api_name         := 'CC_Open_API_Main';
   l_api_version      := 1.0;
   l_error_status     := NVL(l_error_status,'N');

-- -------------------------------------------------------------------
-- Initialize the return values
-- -------------------------------------------------------------------
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_msg_data       := NULL;
   x_msg_count      := 0;
   SAVEPOINT CC_Open_API_PT;
   l_full_path := g_path||'cc_open_api_main';

-- -------------------------------------------------------------------
-- Setup Debug info for API usage if needed.
-- -------------------------------------------------------------------
--   l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
   IF (g_debug_mode = 'Y') THEN
      l_debug := FND_API.G_TRUE;
   ELSE
      l_debug := FND_API.G_FALSE;
   END IF;
   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);
   IF g_debug_mode = 'Y'
   THEN
	g_debug_msg := 'CC Open API Main debug mode enabled...';
	Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
   END IF;

-- -------------------------------------------------------------------
-- Make sure that the appropriate version is being used
-- -------------------------------------------------------------------
   IF (NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )) THEN
	g_debug_msg := 'CC Open API Main Incorrect Version...';
	IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
    END IF;
 --   Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

-- -------------------------------------------------------------------
-- Make sure that if the message stack is to be initialized it is.
-- -------------------------------------------------------------------
   IF (FND_API.to_Boolean ( l_init_msg_list )) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- -------------------------------------------------------------------
-- Open API starts here.
-- -------------------------------------------------------------------
   l_cc_header_rec := p_cc_header_rec;

-- -------------------------------------------------------------------
-- Get the profile values
-- -------------------------------------------------------------------
   l_current_org_id := NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99);
   IF (l_current_org_id = -99) THEN
      dbms_application_info.set_client_info(l_cc_header_rec.org_id);
      l_current_org_id := l_cc_header_rec.org_id;
   END IF;
   l_current_set_of_books_id := l_cc_header_rec.set_of_books_id;
   l_current_user_id := l_cc_header_rec.last_updated_by;
   l_current_login_id := l_cc_header_rec.last_update_login;

-- -------------------------------------------------------------------
-- Get the Functional Currency Code
-- -------------------------------------------------------------------
   BEGIN

      l_full_path := g_path||'cc_open_api_main';

      SELECT currency_code INTO l_func_currency_code
        FROM gl_sets_of_books
       WHERE set_of_books_id = l_current_set_of_books_id;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN
            g_debug_msg := 'CC Open API Main  Unable to get functional currency...';
         --   Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;

         -- Bug 3199488
         IF ( g_excep_level >=  g_debug_level ) THEN
            FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
         END IF;
         -- Bug 3199488
            NULL;
   END;

-- -------------------------------------------------------------------
-- Header record validation.
-- -------------------------------------------------------------------
   IF g_debug_mode = 'Y'
   THEN
       g_debug_msg := 'CC Open API Main Header Record Validation Starts Here...';
       Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
   END IF;

   l_valid_cc := FND_API.G_FALSE;

   CC_OPEN_API_VALIDATE (l_cc_header_rec,
                         l_current_org_id,
                         l_current_set_of_books_id,
                         l_func_currency_code,
                         x_valid_cc,
                         x_currency_code,
                         x_conversion_type,
                         x_conversion_date,
                         x_conversion_rate
                        );

-- -------------------------------------------------------------------
-- If validation succeeds, get the derived values and insert header record.
-- -------------------------------------------------------------------
   IF (x_valid_cc <> FND_API.G_TRUE) THEN

      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;

      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Main Header Validation Not Successful...';
         IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

   ELSE

      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Main Header Id Derivation  Starts Here...';
         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

      CC_OPEN_API_DERIVE ( l_header_id );

      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Main Header Record Insert Row Starts Here...';
         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

      IF (l_header_id IS NULL) THEN

-- --------------------------------------------------------------------
-- Failure in retrieving the sequesnce number for the Header ID.
-- --------------------------------------------------------------------
         FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NO_CC_HDR_SEQ');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

      ELSE

         IGC_CC_HEADERS_PKG.Insert_Row (1.0,
                                        FND_API.G_FALSE,
                                        FND_API.G_FALSE,
                                        FND_API.G_VALID_LEVEL_FULL,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_row_id,
                                        l_header_id,
                                        l_cc_header_rec.org_id,
                                        l_cc_header_rec.CC_Type,
                                        l_cc_header_rec.CC_Num,
                                        l_cc_header_rec.CC_Ref_Num,
                                        0,                                 -- CC version number
                                        l_cc_header_rec.parent_header_id,
                                        'PR',                              -- CC state
                                        'E',                               -- CC Control Status
                                        'N',                               -- CC Encumbrance Status
                                        'IN',                              -- CC Approval Status
                                        l_cc_header_rec.Vendor_Id,
                                        l_cc_header_rec.Vendor_Site_Id,
                                        l_cc_header_rec.Vendor_Contact_Id,
                                        l_cc_header_rec.Term_Id,
                                        l_cc_header_rec.Location_Id,
                                        l_cc_header_rec.Set_Of_Books_Id,
                                        NULL,                              -- CC_Acct_Date
                                        l_cc_header_rec.CC_Desc,
                                        l_cc_header_rec.CC_Start_Date,
                                        l_cc_header_rec.CC_End_Date,
                                        l_cc_header_rec.CC_Owner_User_Id,
                                        l_cc_header_rec.CC_Preparer_User_Id,
                                        x_currency_code,
                                        x_conversion_type,
                                        x_conversion_date,
                                        x_conversion_rate,
                                        SYSDATE,
                                        l_current_user_id,
                                        l_current_login_id,
                                        NVL(l_cc_header_rec.Created_By, l_current_user_id),
                                        NVL(l_cc_header_rec.Creation_Date, sysdate),
                                        l_cc_header_rec.CC_Preparer_User_Id,  -- CC_Current_User_Id,
                                        NULL,                                 -- Wf_Item_Type,
                                        NULL,                                 -- Wf_Item_Key,
                                        l_cc_header_rec.Attribute1,
                                        l_cc_header_rec.Attribute2,
                                        l_cc_header_rec.Attribute3,
                                        l_cc_header_rec.Attribute4,
                                        l_cc_header_rec.Attribute5,
                                        l_cc_header_rec.Attribute6,
                                        l_cc_header_rec.Attribute7,
                                        l_cc_header_rec.Attribute8,
                                        l_cc_header_rec.Attribute9,
                                        l_cc_header_rec.Attribute10,
                                        l_cc_header_rec.Attribute11,
                                        l_cc_header_rec.Attribute12,
                                        l_cc_header_rec.Attribute13,
                                        l_cc_header_rec.Attribute14,
                                        l_cc_header_rec.Attribute15,
                                        l_cc_header_rec.Context,
                                        l_cc_header_rec.CC_Guarantee_Flag,
                                        l_flag
                                       );
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

            ROLLBACK to CC_Open_API_PT;
            x_msg_data      := FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count     := 1;
            g_debug_msg := 'CC Open API Main Header Record Insert Row Not Successful...'||l_msg_data;
           -- Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            IF(g_excep_level >= g_debug_level) THEN
              FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSE

            IF (FND_API.To_Boolean(l_commit)) THEN
               IF g_debug_mode = 'Y'
               THEN
                   g_debug_msg := 'CC Open API Main Commiting CC header Record...';
                   Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
               COMMIT WORK;
            END IF;

         END IF;

      END IF;

   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the CC_Open_API_Main Procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK to CC_Open_API_PT;
       x_msg_data      := FND_MESSAGE.GET;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := 1;

       -- Bug 3199488
       IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       -- Bug 3199488
       RETURN;

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488
       RETURN;

END CC_Open_API_Main;


-- To perform validations on the CC Header record.
-- Validate the CC Header record and return the result

PROCEDURE CC_OPEN_API_VALIDATE (
   p_cc_header_rec       IN OUT NOCOPY CC_HEADER_REC_TYPE,
   p_current_org_id          IN igc_cc_headers.org_id%TYPE,
   p_current_sob_id  	     IN igc_cc_headers.set_of_books_id%TYPE,
   p_func_currency_code      IN igc_cc_headers.currency_code%TYPE,
   x_valid_cc               OUT NOCOPY VARCHAR2,
   x_currency_code          OUT NOCOPY igc_cc_headers.currency_code%TYPE,
   x_conversion_type        OUT NOCOPY igc_cc_headers.conversion_type%TYPE,
   x_conversion_date        OUT NOCOPY igc_cc_headers.conversion_date%TYPE,
   x_conversion_rate        OUT NOCOPY igc_cc_headers.conversion_rate%TYPE
) IS

   l_api_name       		VARCHAR2(30);
   l_error_message 		VARCHAR2(240);
   l_error_count 		NUMBER;
   l_count 			NUMBER;
   l_valid_cc			VARCHAR2(2000);
   l_return_status      	VARCHAR2(1);
   l_msg_count          	NUMBER;
   l_msg_data           	VARCHAR2(12000);
   l_encumbrance_flag   	VARCHAR2(1);
   l_relation_flag		VARCHAR2(1);
   l_parent_header_id   	NUMBER;
   l_vendor_id    		NUMBER;
   l_vendor_site_id   		NUMBER;
   l_vendor_contact_id    	NUMBER;
   l_term_id  			NUMBER;
   l_location_id  		NUMBER;
   l_populate_terms_id          NUMBER;
   l_billed_to_location_id      NUMBER;
   l_vendor_curr_code 		VARCHAR2(15);
   l_vendor_site_curr_code 	VARCHAR2(15);
   l_currency_code    		VARCHAR2(15);
   l_cov_curr_code    		VARCHAR2(15);
   l_cov_conversion_type 	VARCHAR2(30);
   l_cov_conversion_rate 	NUMBER;
   l_cov_conversion_date 	DATE;
   l_conversion_type 		VARCHAR2(30);
   l_conversion_rate 		NUMBER;
   l_conversion_date 		DATE;
   l_set_of_books_id  		NUMBER;
   l_user_id  			NUMBER;
   l_login_id  			NUMBER;
   l_cc_num_method              igc_cc_system_options_all.cc_num_method%TYPE;
   l_cc_num_datatype            igc_cc_system_options_all.cc_num_datatype%TYPE;
   l_cc_num_created             NUMBER;
   l_org_name                   hr_organization_units.name%TYPE;
   l_sob_id                     igc_cc_headers.set_of_books_id%TYPE;
   l_cc_num                     igc_cc_headers.cc_num%TYPE;
   l_name                       hr_all_organization_units.name%TYPE;
   l_full_path                  VARCHAR(500);

   CURSOR c_validate_sob_id IS
      SELECT GL.set_of_books_id
        FROM gl_sets_of_books GL
       WHERE GL.set_of_books_id = p_cc_header_rec.set_of_books_id;

   CURSOR c_validate_org_id IS
      SELECT name
        FROM hr_organization_units
       WHERE organization_id =  p_cc_header_rec.org_id;

   CURSOR c_validate_sob_org_combo IS
      SELECT HAOU.name
        FROM hr_organization_information OOD,
             hr_all_organization_units HAOU
       WHERE OOD.organization_id = p_cc_header_rec.org_id
         AND OOD.organization_id = HAOU.organization_id
         AND OOD.org_information3 || '' = to_char(p_cc_header_rec.set_of_books_id)
         AND HAOU.organization_id || '' = OOD.organization_id;

   CURSOR c_val_cover_state_stat IS
      SELECT cc_num
        FROM igc_cc_headers
       WHERE cc_header_id = p_cc_header_rec.parent_header_id
         AND cc_state IN ('PR','CM')
         AND cc_apprvl_status = 'AP';

BEGIN
--Added by svaithil for GSCC warnings
  l_api_name  := 'CC_Open_API_Validate';
-- -------------------------------------------------------------------
-- Initialize the return values
-- -------------------------------------------------------------------
   x_valid_cc         := FND_API.G_FALSE;
   x_currency_code    := NULL;
   x_conversion_type  := NULL;
   x_conversion_date  := NULL;
   x_conversion_rate  := NULL;
   l_error_count      := 0;
   l_full_path := g_path||'cc_open_api_validate';

   IF g_debug_mode = 'Y'
   THEN
       Output_Debug( l_full_path,'Starting Validation..... CC NUM     : ' || p_cc_header_rec.cc_num);
       Output_Debug( l_full_path,'Starting Validation..... CC REF NUM : ' || p_cc_header_rec.cc_ref_num);

   END IF;

-- -------------------------------------------------------------------
-- Validate the Org Id.
-- -------------------------------------------------------------------
   IF (p_cc_header_rec.org_id <> p_current_org_id) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ORGID_NO_MATCH');
      FND_MESSAGE.SET_TOKEN('ORGID', TO_CHAR(p_cc_header_rec.org_id), TRUE);
      FND_MESSAGE.SET_TOKEN('CURR_ORGID', TO_CHAR(p_current_org_id), TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;

   IF g_debug_mode = 'Y'
   THEN
      g_debug_msg := 'CC Open API Validate Org Id...';
      Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
   END IF;

   IF (p_cc_header_rec.org_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NO_ORG_ID');
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;

      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Validate Org Id is NULL...';
         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   ELSE

-- -------------------------------------------------------------------
-- Ensure that the Organization ID number actually exists in system
-- -------------------------------------------------------------------
      OPEN c_validate_org_id;
      FETCH c_validate_org_id
       INTO l_org_name;

      IF (c_validate_org_id%NOTFOUND) THEN

         FND_MESSAGE.SET_NAME('IGC', 'IGC_ORG_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ORG_ID', TO_CHAR(p_cc_header_rec.org_id),TRUE);
         FND_MSG_PUB.ADD;
         l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
              g_debug_msg := 'CC Open API Validate Org Id is Not Found...';
              IF(g_excep_level >= g_debug_level) THEN
                 FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
              END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

      END IF;
      CLOSE c_validate_org_id;

   END IF;

-- -------------------------------------------------------------------
-- Validate Set of Books Id
-- -------------------------------------------------------------------
   IF (p_cc_header_rec.set_of_books_id <> p_current_sob_id) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_SOB_NO_MATCH_USER_SOB');
      FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(p_cc_header_rec.set_of_books_id), TRUE);
      FND_MESSAGE.SET_TOKEN('CURRENT_SOB_ID', TO_CHAR(p_current_sob_id), TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate Set Of Books Id...';
          Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

   IF (p_cc_header_rec.set_of_books_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NO_SOB');
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;

      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate NULL Set of books ID...';
          Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   ELSE

-- -------------------------------------------------------------------
-- Ensure that the Set Of Books ID actually exists in system
-- -------------------------------------------------------------------
      OPEN c_validate_sob_id;
      FETCH c_validate_sob_id
       INTO l_sob_id;

      IF (c_validate_sob_id%NOTFOUND) THEN

         FND_MESSAGE.SET_NAME('IGC', 'IGC_SOB_ID_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(p_cc_header_rec.set_of_books_id));
         FND_MSG_PUB.ADD;
         l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate SOB Id is Not Found...';
             IF(g_excep_level >= g_debug_level) THEN
               FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
   END IF;

      END IF;
      CLOSE c_validate_sob_id;

   END IF;

-- -------------------------------------------------------------------
-- Validate Org ID and set of Books ID Combination.
-- -------------------------------------------------------------------
    OPEN c_validate_sob_org_combo;
   FETCH c_validate_sob_org_combo
    INTO l_name;

   IF (c_validate_sob_org_combo%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_NO_SOB_ORG_COMBO');
      FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(p_cc_header_rec.set_of_books_id), TRUE);
      FND_MESSAGE.SET_TOKEN('ORG_ID', TO_CHAR(p_cc_header_rec.org_id), TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate Set of books ID and Org ID Combo Failed...';
          IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

   CLOSE c_validate_sob_org_combo;

-- -------------------------------------------------------------------
-- Validate the CC type.
-- -------------------------------------------------------------------
   IF UPPER(p_cc_header_rec.cc_type) NOT IN ('S', 'C', 'R') THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CCTYPE_INVALID');
      FND_MESSAGE.SET_TOKEN('CC_TYPE', p_cc_header_rec.cc_type, TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate CC Type...';
          Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

-- -------------------------------------------------------------------
-- Get the numbering method begins here.
-- -------------------------------------------------------------------
   BEGIN

      SELECT CCNM.cc_num_method,
             CCNM.cc_num_datatype
        INTO l_cc_num_method,
             l_cc_num_datatype
        FROM igc_cc_system_options_all CCNM
       WHERE CCNM.org_id = p_current_org_id;

      EXCEPTION
         WHEN OTHERS THEN
	    l_error_count := l_error_count + 1;
            FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NUM_METHOD_NOT_DEFINED');
            FND_MSG_PUB.ADD;
            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Open API Validate Numbering method not found...';
                IF(g_excep_level >= g_debug_level) THEN
                   FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
            -- Bug 3199488
            IF ( g_unexp_level >= g_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
            END IF;
            -- Bug 3199488
   END;

-- -------------------------------------------------------------------
-- Check to ensure that the CC Reference Number given is NOT NULL.
-- -------------------------------------------------------------------
   IF (p_cc_header_rec.cc_ref_num IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NO_REF_NUM');
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Validate CC Reference Number failure is NULL...';
         IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

-- -------------------------------------------------------------------
-- Check to ensure that if the method for automatic numbering being
-- on and the CC_NUM given is NOT NULL then raise error message.
-- -------------------------------------------------------------------
   IF ((l_cc_num_method = 'A') AND
       (p_cc_header_rec.cc_num IS NOT NULL)) THEN

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_AUTO_NUMBERING_ENABLED');
      FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_header_rec.cc_num);
      FND_MESSAGE.SET_TOKEN('ORG_ID', p_current_org_id);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Validate CC Number failure with auto numbering on...';
         IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

   ELSIF ((l_cc_num_method = 'M') AND
          (l_cc_num_datatype = 'N') AND
          (p_cc_header_rec.cc_num IS NOT NULL)) THEN

      IGC_CC_SYSTEM_OPTIONS_PKG.Validate_Numeric_CC_Num (p_api_version      => 1.0,
                                                         p_init_msg_list    => FND_API.G_FALSE,
                                                         p_commit           => FND_API.G_FALSE,
                                                         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                         x_return_status    => l_return_status,
                                                         x_msg_count        => l_msg_count,
                                                         x_msg_data         => l_msg_data,
                                                         p_cc_num           => p_cc_header_rec.cc_num
                                                        );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_NUMERIC_CC_NUM');
            FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_header_rec.cc_num);
            FND_MESSAGE.SET_TOKEN('ORG_ID', p_current_org_id);
            FND_MSG_PUB.ADD;
         END IF;

         l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Numbering method not found...';
             IF(g_excep_level >= g_debug_level) THEN
                 FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

      END IF;

   ELSIF ((l_cc_num_method = 'M') AND
          (p_cc_header_rec.cc_num IS NULL)) THEN

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NUM_NULL_FOR_MANUAL');
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate CC Number failure with Manual numbering on and CC num NULL...';
          IF(g_excep_level >= g_debug_level) THEN
             FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- If auto numbering is enabled and the CC number given is NULL
-- then build the CC Number for the record that is to be created.
-- -------------------------------------------------------------------
   IF ((l_cc_num_method = 'A') AND
       (p_cc_header_rec.cc_num IS NULL)) THEN

      IGC_CC_SYSTEM_OPTIONS_PKG.Create_Auto_CC_Num (p_api_version      => 1.0,
                                                    p_init_msg_list    => FND_API.G_FALSE,
                                                    p_commit           => FND_API.G_FALSE,
                                                    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                    x_return_status    => l_return_status,
                                                    x_msg_count        => l_msg_count,
                                                    x_msg_data         => l_msg_data,
                                                    p_org_id           => p_current_org_id,
                                                    p_sob_id           => p_cc_header_rec.set_of_books_id,
                                                    x_cc_num           => l_cc_num_created
                                                   );
      IF (l_cc_num_created >= 0) THEN

         p_cc_header_rec.cc_num := to_char (l_cc_num_created);

      ELSE

         FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_API_AUTO_CC_NUM_FAIL');
         FND_MESSAGE.SET_TOKEN('ORG_ID', p_current_org_id);
         FND_MSG_PUB.ADD;
         l_error_count := l_error_count + 1;

         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate CC Number failure with auto numbering on...';
             IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Check whether the CC Number already exists in the database.
-- -------------------------------------------------------------------
   BEGIN
      l_count := 0;
      SELECT COUNT(*) INTO l_count
        FROM igc_cc_headers
       WHERE /*org_id = p_cc_header_rec.org_id
         AND --Commented during MOAC uptake */
	cc_num = p_cc_header_rec.cc_num;

      EXCEPTION
         WHEN OTHERS THEN
	    l_error_count := l_error_count + 1;
	    g_debug_msg := 'CC Open API Validate CC Number Unable to Validate...';
	    --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
        IF(g_excep_level >= g_debug_level) THEN
             FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
        END IF;
        -- Bug 3199488
        IF ( g_unexp_level >= g_debug_level ) THEN
             FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
             FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
             FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
             FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
        END IF;
        -- Bug 3199488


   END;

   IF (l_count > 0) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DUP_CC_NUMBER');
      FND_MESSAGE.SET_TOKEN('CC_NUMBER', p_cc_header_rec.cc_num);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Validate CC Number...';
         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

-- -------------------------------------------------------------------
-- Check if the CC Reference Number Already exists in the database.
-- -------------------------------------------------------------------
   BEGIN
      l_count := 0;
      SELECT COUNT(*) INTO l_count
        FROM igc_cc_headers
       WHERE /*org_id = p_cc_header_rec.org_id
         AND --Commented during MOAC uptake */
	cc_ref_num = p_cc_header_rec.cc_ref_num;

      EXCEPTION

        WHEN OTHERS THEN
	   l_error_count := l_error_count + 1;
	   g_debug_msg := 'CC Open API Validate CC Reference Number Unable to Validate...';
	   IF g_debug_mode = 'Y' THEN
               IF(g_excep_level >= g_debug_level) THEN
                  FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
               END IF;
           END IF;
           --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
           -- Bug 3199488
           IF ( g_unexp_level >= g_debug_level ) THEN
                FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
           END IF;
           -- Bug 3199488
   END;

   IF l_count > 0 THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DUP_CC_REF_NUM');
      FND_MESSAGE.SET_TOKEN('CC_REF_NUM', p_cc_header_rec.cc_ref_num);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate CC Reference Number...';
          Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;


-- -------------------------------------------------------------------
-- Parent_header_id should not be null and should be a valid value
-- for CC type 'R'
-- -------------------------------------------------------------------
   IF p_cc_header_rec.cc_type = 'R' THEN

      IF p_cc_header_rec.parent_header_Id IS NULL THEN

	 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_HDR_ID_REQD');
         FND_MSG_PUB.ADD;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Parent Header Id Null...';
	         IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                 END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

      ELSE

          OPEN c_val_cover_state_stat;
         FETCH c_val_cover_state_stat
          INTO l_cc_num;

         IF (c_val_cover_state_stat%NOTFOUND) THEN
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_NOT_VAL_STATE');
            FND_MSG_PUB.ADD;
            l_error_count := l_error_count + 1;
            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Open API Validate Parent Header State and Status invalid...';
                IF(g_excep_level >= g_debug_level) THEN
                  FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
                --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
         END IF;

         BEGIN

            SELECT cchd.currency_code,
                   cchd.conversion_type,
                   cchd.conversion_rate,
                   cchd.conversion_date
              INTO l_cov_curr_code,
                   l_cov_conversion_type,
                   l_cov_conversion_rate,
                   l_cov_conversion_date
              FROM igc_cc_headers cchd
             WHERE cchd.cc_header_id = p_cc_header_rec.parent_header_id
               AND cchd.cc_type = 'C';

            EXCEPTION

	       WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_NOT_VALID_OAPI');
	          FND_MESSAGE.SET_TOKEN('PARENT_HEADER_ID', TO_CHAR(p_cc_header_rec.parent_header_id), TRUE);
             	  FND_MSG_PUB.ADD;
	          l_error_count := l_error_count + 1;
                  IF g_debug_mode = 'Y'
                  THEN
                      g_debug_msg := 'CC Open API Validate Invalid Cover Details...';
	     	      IF(g_excep_level >= g_debug_level) THEN
                         FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                      END IF;
                  --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                  END IF;
         END;

      END IF;

   ELSE

      IF p_cc_header_rec.parent_header_id IS NOT NULL THEN
	 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_ID_NULL_OAPI');
         FND_MSG_PUB.ADD;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Parent Header Id Must be Null...';
	         IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                 END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Check Budgetary Control is on
-- -------------------------------------------------------------------
   IGC_CC_BUDGETARY_CTRL_PKG.CHECK_BUDGETARY_CTRL_ON (p_api_version      => 1.0,
                                                      p_init_msg_list 	 => FND_API.G_FALSE,
                                                      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                      X_return_status    => l_return_status,
                                                      X_msg_count        => l_msg_count,
                                                      X_msg_data         => l_msg_data,
                                                      p_org_id		 => p_cc_header_rec.org_id,
                                                      p_sob_id		 => p_cc_header_rec.set_of_books_id,
                                                      p_cc_state	 => 'PR',
                                                      X_encumbrance_on   => l_encumbrance_flag
                                                     );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_error_count := l_error_count + NVL(l_msg_count,0);
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate Check Budgetary Control Not Successful...';
          IF(g_excep_level >= g_debug_level) THEN
             FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

-- -------------------------------------------------------------------
-- Validate the Start_Date.
-- -------------------------------------------------------------------
   IGC_CC_BUDGETARY_CTRL_PKG.Validate_CC (p_api_version         => 1.0,
                                          p_init_msg_list 	=> FND_API.G_FALSE,
                                          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
                                          x_return_status	=> l_return_status,
                                          x_msg_count		=> l_msg_count,
                                          x_msg_data		=> l_msg_data,
                                          p_cc_header_id	=> NULL,
                                          X_valid_cc		=> l_valid_cc,
                                          p_mode		=> 'E',
                                          p_field_from		=> 'START_DATE',
                                          p_encumbrance_flag	=> l_encumbrance_flag,
                                          p_sob_id		=> p_cc_header_rec.set_of_books_id,
                                          p_org_id		=> p_cc_header_rec.org_id,
                                          p_start_date		=> TRUNC(p_cc_header_rec.cc_start_date),
                                          p_end_date		=> TRUNC(p_cc_header_rec.cc_end_date),
                                          p_cc_type_code	=> p_cc_header_rec.cc_type,
                                          p_parent_cc_header_id	=> p_cc_header_rec.parent_header_id,
                                          p_cc_det_pf_date	=> NULL,
                                          p_acct_date		=> NULL,
                                          p_prev_acct_date	=> NULL,
                                          p_cc_state	        => 'PR'
                                         );

   IF ((l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
       (l_valid_cc <> FND_API.G_TRUE)) THEN
      l_error_count := l_error_count + NVL(l_msg_count,0);
       IF g_debug_mode = 'Y'
       THEN
          g_debug_msg := 'CC Open API Validate CC for start date Not Successful...';
          IF(g_excep_level >= g_debug_level) THEN
             FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

-- -------------------------------------------------------------------
-- Validate the End Date.
-- -------------------------------------------------------------------
   IGC_CC_BUDGETARY_CTRL_PKG.Validate_CC (p_api_version 		=> 1.0,
                                          p_init_msg_list 	=> FND_API.G_FALSE,
                                          p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
                                          x_return_status	=> l_return_status,
                                          x_msg_count		=> l_msg_count,
                                          x_msg_data		=> l_msg_data,
                                          p_cc_header_id	=> NULL,
                                          X_valid_cc		=> l_valid_cc,
                                          p_mode		=> 'E',
                                          p_field_from		=> 'END_DATE',
                                          p_encumbrance_flag	=> l_encumbrance_flag,
                                          p_sob_id		=> p_cc_header_rec.set_of_books_id,
                                          p_org_id		=> p_cc_header_rec.org_id,
                                          p_start_date		=> TRUNC(p_cc_header_rec.cc_start_date),
                                          p_end_date		=> TRUNC(p_cc_header_rec.cc_end_date),
                                          p_cc_type_code	=> p_cc_header_rec.cc_type,
                                          p_parent_cc_header_id	=> p_cc_header_rec.parent_header_id,
                                          p_cc_det_pf_date	=> NULL,
                                          p_acct_date		=> NULL,
                                          p_prev_acct_date	=> NULL,
                                          p_cc_state	        => 'PR'
                                         );

   IF ((l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
       (l_valid_cc <> FND_API.G_TRUE)) THEN
      l_error_count := l_error_count + NVL(l_msg_count,0);
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate CC for end date Not Successful...';
          IF(g_excep_level >= g_debug_level) THEN
             FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
   END IF;

-- -------------------------------------------------------------------
-- Validate Vendor Id
-- -------------------------------------------------------------------
   IF p_cc_header_rec.vendor_id IS NOT NULL THEN

      BEGIN
         SELECT vendor_id,
                invoice_currency_code
	   INTO l_vendor_id,
                l_vendor_curr_code
           FROM po_vendors
          WHERE vendor_id = p_cc_header_rec.vendor_id
            AND enabled_flag = 'Y'
            AND sysdate BETWEEN NVL(start_date_active, sysdate-1)
            AND NVL(end_date_active, sysdate+1);

         EXCEPTION

            WHEN NO_DATA_FOUND THEN
	       FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_VENDOR_ID');
	       FND_MESSAGE.SET_TOKEN('VENDOR_ID', TO_CHAR(p_cc_header_rec.vendor_id), TRUE);
               FND_MSG_PUB.ADD;
	       l_error_count := l_error_count + 1;
               IF g_debug_mode = 'Y'
               THEN
	           g_debug_msg := 'CC Open API Validate Vendor Info Not Successful...';
	           IF(g_excep_level >= g_debug_level) THEN
                      FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
      END;

   END IF;

-- -------------------------------------------------------------------
-- Validate Vendor Site Id
-- -------------------------------------------------------------------
   IF p_cc_header_rec.vendor_site_id IS NOT NULL THEN

      BEGIN
         SELECT vendor_site_id,
                invoice_currency_code,
                terms_id,
                bill_to_location_id
           INTO l_vendor_site_id,
                l_vendor_site_curr_code,
                l_populate_terms_id,
                l_billed_to_location_id
           FROM po_vendor_sites_all
          WHERE org_id = p_cc_header_rec.org_id /* Addded this condition for MOAC uptake */
	    AND vendor_site_id = p_cc_header_rec.vendor_site_id
            AND vendor_id = p_cc_header_rec.vendor_id
            AND purchasing_site_flag = 'Y'
            AND NVL(inactive_date, sysdate+1) > sysdate;

         EXCEPTION

	   WHEN NO_DATA_FOUND THEN
	      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_VENDOR_SITE_ID');
	      FND_MESSAGE.SET_TOKEN('VENDOR_SITE_ID', TO_CHAR(p_cc_header_rec.vendor_site_id), TRUE);
              FND_MSG_PUB.ADD;
	      l_error_count := l_error_count + 1;
              IF g_debug_mode = 'Y'
              THEN
	          g_debug_msg := 'CC Open API Validate Vendor Site Info Not Successful...';
	          IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                  END IF;
              --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
              END IF;
      END;

   END IF;

   IF g_debug_mode = 'Y'
   THEN
       Output_Debug( l_full_path,'Contact ID : ' || p_cc_header_rec.vendor_contact_id);
       Output_Debug( l_full_path,'Site ID    : ' || p_cc_header_rec.vendor_site_id);
       Output_Debug( l_full_path,'Vendor ID  : ' || p_cc_header_rec.vendor_id);
   END IF;

-- -------------------------------------------------------------------
-- Validate Vendor Contact Id
-- -------------------------------------------------------------------
   IF (p_cc_header_rec.vendor_contact_id IS NOT NULL) THEN

      IF ((p_cc_header_rec.vendor_site_id IS NULL) OR
          (p_cc_header_rec.vendor_id IS NULL)) THEN

         FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_VNDR_SITE_CONT_ID_NULL');
         FND_MSG_PUB.ADD;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Vendor Contact and Vendor Validation Not Successful...';
	         IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                 END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

      ELSE

         BEGIN
            SELECT vendor_contact_id
              INTO l_vendor_contact_id
              FROM po_vendor_contacts
             WHERE vendor_site_id = p_cc_header_rec.vendor_site_id
               AND vendor_contact_id = p_cc_header_rec.vendor_contact_id
               AND NVL(inactive_date, sysdate+1) > sysdate;

            EXCEPTION

	       WHEN NO_DATA_FOUND THEN
	    	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_VEDR_CONTACT_ID');
	    	  FND_MESSAGE.SET_TOKEN('VENDOR_CONTACT_ID', TO_CHAR(p_cc_header_rec.vendor_contact_id), TRUE);
                  FND_MSG_PUB.ADD;
	          l_error_count := l_error_count + 1;
                  IF g_debug_mode = 'Y'
                  THEN
	             g_debug_msg := 'CC Open API Validate Vendor Contact Not Successful...';
	    	     IF(g_excep_level >= g_debug_level) THEN
                         FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                     END IF;
                 --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                   END IF;
         END;

      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Validate Term Id
-- -------------------------------------------------------------------
   IF p_cc_header_rec.term_id IS NOT NULL THEN

      BEGIN
         SELECT term_id
           INTO l_term_id
           FROM ap_terms_val_v
          WHERE term_id = p_cc_header_rec.term_id;

         EXCEPTION

	    WHEN NO_DATA_FOUND THEN
	       FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_TERM_ID');
	       FND_MESSAGE.SET_TOKEN('TERM_ID', TO_CHAR(p_cc_header_rec.term_id), TRUE);
               FND_MSG_PUB.ADD;
	       l_error_count := l_error_count + 1;
               IF g_debug_mode = 'Y'
               THEN
	           g_debug_msg := 'CC Open API Validate Term Not Successful...';
	           IF(g_excep_level >= g_debug_level) THEN
                      FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
               --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
      END;

   ELSE

-- -----------------------------------------------------------------------------------
-- If there is a site ID given and the term ID is NULL then assign the site ID
-- to the term ID.
-- -----------------------------------------------------------------------------------
      IF p_cc_header_rec.vendor_site_id IS NOT NULL THEN
         p_cc_header_rec.term_id := l_populate_terms_id;
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Validate Location Id
-- -------------------------------------------------------------------
   IF p_cc_header_rec.location_id IS NOT NULL THEN

      IF p_cc_header_rec.vendor_id IS NULL THEN
	 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_LOCATION_ID_NULL');
         FND_MSG_PUB.ADD;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Vendor and Location Valdiation Not Successful...';
	     IF(g_excep_level >= g_debug_level) THEN
                 FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
        END IF;
      ELSE

         BEGIN
            SELECT location_id
              INTO l_location_id
              FROM hr_locations
             WHERE location_id = p_cc_header_rec.location_id
               AND bill_to_site_flag = 'Y'
               AND NVL(inactive_date, sysdate+1) > sysdate;

            EXCEPTION
	       WHEN NO_DATA_FOUND THEN
	          FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LOCATION_ID');
	          FND_MESSAGE.SET_TOKEN('LOCATION_ID', TO_CHAR(p_cc_header_rec.location_id), TRUE);
            	  FND_MSG_PUB.ADD;
	    	  l_error_count := l_error_count + 1;
                 IF g_debug_mode = 'Y'
                 THEN
	             g_debug_msg := 'CC Open API Validate Location Not Successful...';
	    	     IF(g_excep_level >= g_debug_level) THEN
                        FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                     END IF;
                 --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                 END IF;
         END;

      END IF;

   ELSE

-- -----------------------------------------------------------------------------------
-- If there is a site ID given and the location ID is NULL then assign the site ID
-- to the location ID.
-- -----------------------------------------------------------------------------------
      IF p_cc_header_rec.vendor_site_id IS NOT NULL THEN
         p_cc_header_rec.location_id := l_billed_to_location_id;
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Validate Cc Owner User Id
-- -------------------------------------------------------------------
   BEGIN
      -- Performance Tuning, Replaced the following query with
      -- the one below.
      -- SELECT fu.user_id
      --   INTO l_user_id
      --   FROM fnd_user fu, hr_employees he
      --  WHERE fu.user_id =  p_cc_header_rec.cc_owner_user_id
      --    AND sysdate BETWEEN NVL(fu.start_date, sysdate)
      --    AND NVL(fu.end_date, sysdate)
      --    AND fu.employee_id IS NOT NULL
      --    AND fu.employee_id = he.employee_id;
      SELECT fu.user_id
      INTO l_user_id
      FROM   fnd_user fu,
            per_people_f p, /* per_all_people_f p, --Commented during MOAC uptake for bug#6341012*/
             per_all_assignments_f a,
             per_assignment_status_types past
      WHERE fu.user_id =  p_cc_header_rec.cc_owner_user_id
      AND   sysdate BETWEEN NVL(fu.start_date, sysdate)
      AND   NVL(fu.end_date, sysdate)
      AND   fu.employee_id IS NOT NULL
      AND   fu.employee_id = p.person_id
     /* AND   p.business_group_id = (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp) --Commented during MOAC uptake for bug #6341012 */
      AND   p.employee_number is not null
      AND   trunc(sysdate) between p.effective_start_date and p.effective_end_date
      AND   a.person_id = p.person_id
      AND   a.primary_flag = 'Y'
      AND   trunc(sysdate) between a.effective_start_date
      AND   a.effective_end_date
      AND   a.assignment_status_type_id = past.assignment_status_type_id
      AND   past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
      AND   a.assignment_type = 'E';

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_OWNER_UID_INVALID');
	    FND_MESSAGE.SET_TOKEN('OWNER_UID', TO_CHAR(p_cc_header_rec.cc_owner_user_id), TRUE);
            FND_MSG_PUB.ADD;
	    l_error_count := l_error_count + 1;
           IF g_debug_mode = 'Y'
           THEN
	        g_debug_msg := 'CC Open API Validate Owner Not Successful...';
	        IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
            --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
   END;

-- -------------------------------------------------------------------
-- Validate Cc Preparer User Id
-- -------------------------------------------------------------------
   BEGIN
      -- Performance tuning, Replaced the following sql
      -- with the one below.
      -- SELECT fu.user_id
      --   INTO l_user_id
      --   FROM fnd_user fu, hr_employees he
      --  WHERE fu.user_id = p_cc_header_rec.cc_preparer_user_id
      --    AND sysdate BETWEEN NVL(fu.start_date, sysdate)
      --    AND NVL(fu.end_date, sysdate)
      --    AND fu.employee_id IS NOT NULL
      --    AND fu.employee_id = he.employee_id;

      SELECT fu.user_id
      INTO l_user_id
      FROM   fnd_user fu,
             per_people_f p, /* per_all_people_f p, --Commented for Bug#6341012
 during MOAC uptake*/
             per_all_assignments_f a,
             per_assignment_status_types past
      WHERE fu.user_id =  p_cc_header_rec.cc_preparer_user_id
      AND   sysdate BETWEEN NVL(fu.start_date, sysdate)
      AND   NVL(fu.end_date, sysdate)
      AND   fu.employee_id IS NOT NULL
      AND   fu.employee_id = p.person_id
      /*AND   p.business_group_id = (SELECT NVL(MAX(fsp.business_group_id),0)
                                   FROM   financials_system_parameters fsp)
	--Commented during MOAC uptake for bug#6341012 */
      AND   p.employee_number is not null
      AND   trunc(sysdate) between p.effective_start_date and p.effective_end_date
      AND   a.person_id = p.person_id
      AND   a.primary_flag = 'Y'
      AND   trunc(sysdate) between a.effective_start_date
      AND   a.effective_end_date
      AND   a.assignment_status_type_id = past.assignment_status_type_id
      AND   past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
      AND   a.assignment_type = 'E';

      EXCEPTION

         WHEN NO_DATA_FOUND THEN
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PREPARER_UID_INVALID');
	    FND_MESSAGE.SET_TOKEN('PREPARER_UID', TO_CHAR(p_cc_header_rec.cc_preparer_user_id), TRUE);
            FND_MSG_PUB.ADD;
	    l_error_count := l_error_count + 1;
            IF g_debug_mode = 'Y'
            THEN
	        g_debug_msg := 'CC Open API Validate Preparer Not Successful...';
	        IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
            --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
   END;

-- -------------------------------------------------------------------
-- Validate Currency Code and the conversion columns
-- -------------------------------------------------------------------
   x_currency_code   := p_cc_header_rec.currency_code;
   x_conversion_type := p_cc_header_rec.conversion_type;
   x_conversion_date := p_cc_header_rec.conversion_date;
   x_conversion_rate := p_cc_header_rec.conversion_rate;

   IF (x_currency_code IS NULL) THEN

      IF l_vendor_site_curr_code IS NOT NULL THEN
         x_currency_code := l_vendor_site_curr_code;
         IF g_debug_mode = 'Y'
         THEN
            g_debug_msg := 'CC Open API Validate Vendor Site Invoice Currency...'||x_currency_code;
            Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
      ELSIF l_vendor_curr_code IS NOT NULL THEN
         x_currency_code := l_vendor_curr_code;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Vendor Invoice Currency...'||x_currency_code;
             Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
      END IF;

   END IF;

   IF x_currency_code IS NULL THEN

      IF p_func_currency_code IS NULL THEN
   	 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CODE_REQD');
         FND_MSG_PUB.ADD;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
	     g_debug_msg := 'CC Open API Validate Currency cannot be null...';
	     --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
             IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
         END IF;
      ELSE
         x_currency_code := p_func_currency_code;
      END IF;

   END IF;

   l_currency_code := NULL;

-- -------------------------------------------------------------------
-- Check if the non-functional currency is a valid currency.
-- -------------------------------------------------------------------
   BEGIN
      SELECT currency_code
        INTO l_currency_code
        FROM fnd_currencies_vl
       WHERE enabled_flag  = 'Y'
         AND currency_flag = 'Y'
         AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
                         AND NVL(end_date_active, SYSDATE)
	 AND currency_code = x_currency_code;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CODE_INVALID');
	    FND_MESSAGE.SET_TOKEN('CURR_CODE', x_currency_code, TRUE);
            FND_MSG_PUB.ADD;
	    l_error_count := l_error_count + 1;
            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Open API Validate Currency Invalid...';
	        IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
            --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
   END;

   IF (l_currency_code IS NOT NULL) THEN

      IF ((x_currency_code <> p_func_currency_code) AND
          ((x_conversion_type IS NULL) OR
           (x_conversion_rate IS NULL) OR
           (x_conversion_date IS NULL))) THEN

         BEGIN

            l_relation_flag := gl_currency_api.is_fixed_rate (x_currency_code,
   	                                 		      p_func_currency_code,
                                                              NVL(x_conversion_date, SYSDATE)
                                                             );
            IF l_relation_flag = 'Y' THEN
  	       x_conversion_type := 'EMU FIXED';
            ELSE

              IF (x_conversion_type IS NULL) THEN

                 BEGIN
                    SELECT ccsp.default_rate_type
                      INTO x_conversion_type
                      FROM igc_cc_system_options_all ccsp
                     WHERE ccsp.org_id = p_cc_header_rec.org_id;

                    EXCEPTION

   		       WHEN OTHERS THEN
                          FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CONV_TYPE_RATE_DT_REQD');
            	          FND_MSG_PUB.ADD;
	       	          l_error_count := l_error_count + 1;
                          IF g_debug_mode = 'Y'
                          THEN
	    	              g_debug_msg := 'CC Open API Validate No default rate type defined...';
   	    	              IF(g_excep_level >= g_debug_level) THEN
                                   FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                              END IF;
                           --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                          END IF;
                          -- Bug 3199488
                          IF ( g_unexp_level >= g_debug_level ) THEN
                              FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                              FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                              FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                              FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                          END IF;
                          -- Bug 3199488

	         END;

              END IF;

	   END IF;

           EXCEPTION

              WHEN OTHERS THEN
                 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CODE_INVALID');
	    	 FND_MESSAGE.SET_TOKEN('CURR_CODE', x_currency_code, TRUE);
                 FND_MSG_PUB.ADD;
                 l_error_count := l_error_count + 1;
                 IF g_debug_mode = 'Y'
                 THEN
                     g_debug_msg := 'CC Open API Validate Invalid Currency Code defined...';
                     IF(g_excep_level >= g_debug_level) THEN
                         FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                     END IF;
                    --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                 END IF;
                 -- Bug 3199488
                 IF ( g_unexp_level >= g_debug_level ) THEN
                    FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                    FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                    FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                    FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                 END IF;
                 -- Bug 3199488

	 END;

      END IF;

      IF l_cov_curr_code <> p_func_currency_code AND p_cc_header_rec.cc_type = 'R' AND
 	 ( x_currency_code <> l_cov_curr_code OR
	   x_conversion_type <> l_cov_conversion_type OR
	   x_conversion_rate <> l_cov_conversion_rate OR
	   x_conversion_date <> l_cov_conversion_date) THEN

	 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CD_CT_CR_CD_SAME');
         FND_MSG_PUB.ADD;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Open API Validate Cover and Release currency does not match...';
	         IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                 END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
      END IF;

-- -------------------------------------------------------------------
-- Conversion Type Validation.
-- -------------------------------------------------------------------
      IF x_currency_code <> p_func_currency_code AND
         x_conversion_type IS NOT NULL THEN

         IF x_conversion_type <>  'EMU FIXED' AND
	    x_conversion_type <> 'Period Average (Upgrade)' THEN

            l_conversion_type := NULL;

            BEGIN
               IF g_debug_mode = 'Y'
               THEN
      	           g_debug_msg := 'CC Open API Validate Other Conversion Type...';
	           Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;

	       SELECT conversion_type
	 	 INTO l_conversion_type
		 FROM gl_daily_conversion_types
	        WHERE conversion_type <> 'Period Average (Upgrade)'
	 	  AND conversion_type <> 'EMU FIXED'
		  AND conversion_type = x_conversion_type;

	       EXCEPTION

                  WHEN NO_DATA_FOUND THEN
	    	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CONV_TYPE_INVALID');
	    	     FND_MESSAGE.SET_TOKEN('CONVTYPE', x_conversion_type, TRUE);
            	     FND_MSG_PUB.ADD;
	    	     l_error_count := l_error_count + 1;
                     IF g_debug_mode = 'Y'
                     THEN
	                 g_debug_msg := 'CC Open API Validate Invalid Conversion Type...';
	    	         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                     END IF;
	    END;

	 END IF;

         IF UPPER(x_conversion_type) = 'USER' AND
            l_conversion_type IS NOT NULL AND
	    (x_conversion_date IS NULL OR
	     x_conversion_rate IS NULL) THEN

	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CONV_DATE_RATE_REQD');
            FND_MSG_PUB.ADD;
	    l_error_count := l_error_count + 1;
            IF g_debug_mode = 'Y'
            THEN
	         g_debug_msg := 'CC Open API Validate Rate and Date required...';
	         IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                 END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;

         ELSIF (UPPER(x_conversion_type) <> 'USER' AND
                l_conversion_type IS NOT NULL AND
	        UPPER(x_conversion_type) = 'EMU FIXED') OR
	        (UPPER(x_conversion_type) NOT IN ('USER','EMU FIXED') AND
	         (x_conversion_date IS NULL OR
	          x_conversion_rate IS NULL)) THEN
            BEGIN

               l_conversion_rate := gl_currency_api.get_rate (p_cc_header_rec.set_of_books_id,
						              x_currency_code,
						      	      NVL(x_conversion_date,SYSDATE),
				                              x_conversion_type
                                                             );

               x_conversion_rate := ROUND(l_conversion_rate,15);
	       IF x_conversion_date IS NULL THEN
                  x_conversion_date := SYSDATE;
	       END IF;

               EXCEPTION

                  WHEN OTHERS THEN
                     FND_MESSAGE.SET_NAME('IGC', 'IGC_API_CONV_RATE_FAILURE');
                     FND_MESSAGE.SET_TOKEN('CONV_TYPE', x_conversion_type, TRUE);
                     FND_MESSAGE.SET_TOKEN('CONV_DATE', x_conversion_date, TRUE);
                     FND_MESSAGE.SET_TOKEN('CURR_CODE', x_currency_code, TRUE);
                     FND_MSG_PUB.ADD;
                     l_error_count := l_error_count + 1;
                     IF g_debug_mode = 'Y'
                     THEN
                          g_debug_msg := 'CC Open API Validate Get RATE is could not be obtained...';
                          IF(g_excep_level >= g_debug_level) THEN
                            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                          END IF;
                          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                     END IF;
                     -- Bug 3199488
                     IF ( g_unexp_level >= g_debug_level ) THEN
                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                     END IF;
                     -- Bug 3199488

            END;

         ELSIF (UPPER(x_conversion_type) <> 'USER' AND
                l_conversion_type IS NOT NULL AND
                UPPER(x_conversion_type) = 'EMU FIXED') OR
                (UPPER(x_conversion_type) NOT IN ('USER','EMU FIXED') AND
                 (x_conversion_date IS NULL OR
                  x_conversion_rate IS NOT NULL)) THEN

            FND_MESSAGE.SET_NAME('IGC', 'IGC_API_CONV_RATE_NOT_ALLWD');
            FND_MESSAGE.SET_TOKEN('CONV_TYPE', x_conversion_type, TRUE);
            FND_MESSAGE.SET_TOKEN('CONV_DATE', x_conversion_date, TRUE);
            FND_MESSAGE.SET_TOKEN('CONV_RATE', x_conversion_rate, TRUE);
            FND_MSG_PUB.ADD;
            l_error_count := l_error_count + 1;
            IF g_debug_mode = 'Y'
            THEN
                 g_debug_msg := 'CC Open API Validate Rate NOT required...';
                 IF(g_excep_level >= g_debug_level) THEN
                       FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                 END IF;
                 --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;

         END IF;

      END IF;

      IF x_currency_code = p_func_currency_code AND
	 (x_conversion_type IS NOT NULL OR
	  x_conversion_date IS NOT NULL OR
	  x_conversion_rate IS NOT NULL ) THEN
	 FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CONV_TYPE_RTDT_NULL');
         FND_MSG_PUB.ADD;
	 x_conversion_type := NULL;
	 x_conversion_date := NULL;
	 x_conversion_rate := NULL;
	 l_error_count := l_error_count + 1;
         IF g_debug_mode = 'Y'
         THEN
	     g_debug_msg := 'CC Open API Validate Conversion type, rate, date not required...';
	     IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Validate Created By
-- -------------------------------------------------------------------
   IF p_cc_header_rec.created_by IS NOT NULL THEN

      BEGIN
         SELECT user_id
           INTO l_user_id
           FROM fnd_user
          WHERE user_id = p_cc_header_rec.created_by;

         EXCEPTION

	    WHEN NO_DATA_FOUND THEN
	       FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_CREATED_BY');
	       FND_MESSAGE.SET_TOKEN('CREATED_BY', TO_CHAR(p_cc_header_rec.created_by), TRUE);
               FND_MSG_PUB.ADD;
	       l_error_count := l_error_count + 1;
               IF g_debug_mode = 'Y'
               THEN
	           g_debug_msg := 'CC Open API Validate Invalid Created By...';
	           IF(g_excep_level >= g_debug_level) THEN
                       FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
               --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
      END;

   ELSE

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_CREATED_BY');
      FND_MESSAGE.SET_TOKEN('CREATED_BY', TO_CHAR(p_cc_header_rec.created_by), TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Validate Invalid Created By is NULL...';
         IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Validate Last Updated By
-- -------------------------------------------------------------------
   IF p_cc_header_rec.last_updated_by IS NOT NULL THEN

      BEGIN
         SELECT user_id
           INTO l_user_id
           FROM fnd_user
          WHERE user_id = p_cc_header_rec.last_updated_by;

         EXCEPTION

	    WHEN NO_DATA_FOUND THEN
	       FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPDATED_BY');
	       FND_MESSAGE.SET_TOKEN('LAST_UPDATED_BY', TO_CHAR(p_cc_header_rec.last_updated_by), TRUE);
               FND_MSG_PUB.ADD;
	       l_error_count := l_error_count + 1;
               IF g_debug_mode = 'Y'
               THEN
	           g_debug_msg := 'CC Open API Validate Invalid Last Updated By...';
	           IF(g_excep_level >= g_debug_level) THEN
                         FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
               --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
      END;
   ELSE

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPDATED_BY');
      FND_MESSAGE.SET_TOKEN('LAST_UPDATED_BY', TO_CHAR(p_cc_header_rec.last_updated_by), TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Open API Validate Invalid Last Updated By is NULL...';
          IF(g_excep_level >= g_debug_level) THEN
             FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Validate Last Update Login
-- -------------------------------------------------------------------
   IF p_cc_header_rec.last_update_login IS NOT NULL THEN

      BEGIN
         SELECT login_id
           INTO l_login_id
           FROM fnd_logins
          WHERE login_id = p_cc_header_rec.last_update_login;

         EXCEPTION

            WHEN NO_DATA_FOUND THEN
	       FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPD_LOGIN');
	       FND_MESSAGE.SET_TOKEN('LAST_UPDATE_LOGIN', TO_CHAR(p_cc_header_rec.last_update_login), TRUE);
               FND_MSG_PUB.ADD;
	       l_error_count := l_error_count + 1;
                   IF g_debug_mode = 'Y'
                   THEN
    	               g_debug_msg := 'CC Open API Validate Invalid Last Update Login...';
	               IF(g_excep_level >= g_debug_level) THEN
                          FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                       END IF;
                       -- Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
      END;

   ELSE

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPD_LOGIN');
      FND_MESSAGE.SET_TOKEN('LAST_UPDATE_LOGIN', TO_CHAR(p_cc_header_rec.last_update_login), TRUE);
      FND_MSG_PUB.ADD;
      l_error_count := l_error_count + 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Open API Validate Invalid Last Update Login is NULL...';
         IF(g_excep_level >= g_debug_level) THEN
               FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- --------------------------------------------------------------------
-- Ensure that all cursors are closed upon exit.
-- --------------------------------------------------------------------
   IF (c_validate_sob_id%ISOPEN) THEN
      CLOSE c_validate_sob_id;
   END IF;
   IF (c_validate_org_id%ISOPEN) THEN
      CLOSE c_validate_org_id;
   END IF;
   IF (c_validate_sob_org_combo%ISOPEN) THEN
      CLOSE c_validate_sob_org_combo;
   END IF;
   IF (c_val_cover_state_stat%ISOPEN) THEN
      CLOSE c_val_cover_state_stat;
   END IF;

   IF g_debug_mode = 'Y'
   THEN
       g_debug_msg := 'CC Open API Validate Error Count...' || to_char(l_error_count);
       Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
   END IF;

   IF l_error_count > 0 THEN
      x_valid_cc := FND_API.G_FALSE;
   ELSE
      x_valid_cc := FND_API.G_TRUE;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the CC_Open_API_Validate Procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN OTHERS THEN
       x_valid_cc        := FND_API.G_FALSE;
       x_currency_code   := NULL;
       x_conversion_type := NULL;
       x_conversion_date := NULL;
       x_conversion_rate := NULL;
       IF g_debug_mode = 'Y'
       THEN

          Output_Debug( l_full_path,'Exception encountered for this record.');
       END IF;
       IF (c_validate_sob_id%ISOPEN) THEN
          CLOSE c_validate_sob_id;
       END IF;
       IF (c_validate_org_id%ISOPEN) THEN
          CLOSE c_validate_org_id;
       END IF;
       IF (c_validate_sob_org_combo%ISOPEN) THEN
          CLOSE c_validate_sob_org_combo;
       END IF;
       IF (c_val_cover_state_stat%ISOPEN) THEN
          CLOSE c_val_cover_state_stat;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488
       RETURN;

END CC_OPEN_API_VALIDATE;


PROCEDURE CC_OPEN_API_DERIVE (
   x_header_id      OUT NOCOPY NUMBER
) IS

   l_api_name       		VARCHAR2(30);

   l_full_path                  VARCHAR(500);
BEGIN
--Added by svaithil for GSCC warnings
 l_api_name   := 'CC_Open_API_Derive';

   x_header_id := NULL;
   l_full_path := g_path||'cc_open_api_derive';
   SELECT igc_cc_headers_s.nextval
     INTO x_header_id
     FROM DUAL;

-- --------------------------------------------------------------------
-- Exception handler section for the CC_Open_API_Derive Procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN OTHERS THEN
       x_header_id := NULL;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488
       RETURN;

END CC_OPEN_API_DERIVE;


-- To perform commitment action from an external system on a particular contract commitment.

PROCEDURE CC_Update_Control_Status_API (
   p_api_version         IN   NUMBER,
   p_init_msg_list       IN   VARCHAR2,
   p_commit              IN   VARCHAR2,
   p_validation_level    IN   NUMBER,
   p_cc_num              IN   igc_cc_headers.cc_num%TYPE,
   p_set_of_books_id     IN   igc_cc_headers.set_of_books_id%TYPE,
   p_org_id              IN   igc_cc_headers.org_id%TYPE,
   p_action_code	 IN   fnd_lookups.lookup_code%TYPE,
   p_last_updated_by     IN   igc_cc_headers.last_updated_by%TYPE,
   p_last_update_login   IN   igc_cc_headers.last_update_login%TYPE,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
) IS

   l_api_name           VARCHAR2(30);
   l_api_version        NUMBER;
   l_debug              VARCHAR2 (1);
   l_cc_header_rec      igc_cc_headers%ROWTYPE;
   l_cc_header_id       igc_cc_headers.cc_header_id%TYPE;
   l_cc_ref_num         igc_cc_headers.cc_ref_num%TYPE;
   l_cc_num             igc_cc_headers.cc_num%TYPE;
   l_valid_cc           VARCHAR2(2000);
   l_return_status      VARCHAR2(1);
   l_result             VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(12000);
   l_encumbrance_flag   VARCHAR2(1);
   l_new_ctrl_status    igc_cc_headers.cc_ctrl_status%TYPE;
   l_new_apprvl_status  igc_cc_headers.cc_apprvl_status%TYPE;
   l_prev_ctrl_status   igc_cc_headers.cc_ctrl_status%TYPE;
   l_prev_apprvl_status igc_cc_headers.cc_apprvl_status%TYPE;
   l_action_type_code   fnd_lookups.lookup_code%TYPE;
   l_action_meaning     fnd_lookups.meaning%TYPE;
   l_control_meaning    fnd_lookups.meaning%TYPE;
   l_seq                VARCHAR2(40);
   l_itemkey            igc_cc_headers.wf_item_key%TYPE;
   l_itemtype           igc_cc_headers.wf_item_type%TYPE;
   l_row_id             VARCHAR2(18);
   l_current_user_id    NUMBER;
   l_current_login_id   NUMBER;
   l_user_id            NUMBER;
   l_login_id           NUMBER;
--   l_debug_mode         VARCHAR2(1);
   l_name               hr_all_organization_units.name%TYPE;
   l_current_org_id     NUMBER;
  l_init_msg_list    varchar2(2000);
   l_commit          varchar2(2000);
   l_validation_level  NUMBER;

   CURSOR c_validate_sob_org_combo IS
      SELECT HAOU.name
        FROM hr_organization_information OOD,
             hr_all_organization_units HAOU
       WHERE OOD.organization_id = l_current_org_id
         AND OOD.organization_id = HAOU.organization_id
         AND OOD.org_information3 || '' = to_char(p_set_of_books_id)
         AND HAOU.organization_id || '' = OOD.organization_id;

   CURSOR c_cc_header_exist IS
      SELECT cchd.cc_header_id
        FROM igc_cc_headers cchd
       WHERE cchd.cc_num          = p_cc_num;
	/* AND cchd.set_of_books_id = p_set_of_books_id
         AND cchd.org_id          = l_current_org_id; --Commented during MOAC up	take*/

   CURSOR c_val_ref_num IS
      SELECT cchd.cc_ref_num
        FROM igc_cc_headers cchd
       WHERE cchd.cc_header_id = l_cc_header_id
         AND cchd.cc_ref_num IS NOT NULL;

   CURSOR c_cc_header_state IS
      SELECT *
        FROM igc_cc_headers cchd
       WHERE cchd.cc_header_id     = l_cc_header_id
         AND cchd.cc_apprvl_status = 'AP'
         AND cchd.cc_state         = 'CM';

   e_invalid_action     EXCEPTION;
   e_cc_not_found       EXCEPTION;

   l_full_path                  VARCHAR(500);
BEGIN

--Added by svaithil for GSCC warnings

   l_init_msg_list := nvl(p_init_msg_list,FND_API.G_FALSE);
   l_commit        := nvl(p_commit,FND_API.G_FALSE);
   l_validation_level  := nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL);
   l_api_name         := 'CC_Update_Control_Status_API';
   l_api_version      := 1.0;
-- -------------------------------------------------------------------
-- Initialize the return values
-- -------------------------------------------------------------------
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_msg_data       := NULL;
   x_msg_count      := 0;
   l_full_path := g_path||'cc_update_control_status_API';
   SAVEPOINT CC_Update_API_PT;

-- -------------------------------------------------------------------
-- Setup Debug info for API usage if needed.
-- -------------------------------------------------------------------
--   l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);
   IF g_debug_mode = 'Y'
   THEN
	g_debug_msg := 'CC Update API Debug mode enabled...';
	Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
   END IF;

-- -------------------------------------------------------------------
-- Make sure that the appropriate version is being used
-- -------------------------------------------------------------------
   IF (NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )) THEN
   IF g_debug_mode = 'Y'
   THEN
      g_debug_msg := 'CC Update APi Incorrect version...';
      --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
      END IF;
   END IF;
      raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

-- -------------------------------------------------------------------
-- Make sure that if the message stack is to be initialized it is.
-- -------------------------------------------------------------------
   IF (FND_API.to_Boolean ( l_init_msg_list )) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- --------------------------------------------------------------------
-- Update API logic.
-- --------------------------------------------------------------------
   IF g_debug_mode = 'Y'
   THEN
      g_debug_msg := 'CC Update API Starts Here...';
      Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Get the profile values
-- --------------------------------------------------------------------
   l_current_user_id 	:= p_last_updated_by;
   l_current_login_id 	:= p_last_update_login;
--   l_debug_mode         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
   l_current_org_id     := NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99);
   IF (l_current_org_id = -99) THEN
      dbms_application_info.set_client_info(p_org_id);
      l_current_org_id := p_org_id;
   ELSE
      l_current_org_id := p_org_id;
   END IF;

-- -------------------------------------------------------------------
-- Validate Org ID and set of Books ID Combination.
-- -------------------------------------------------------------------
    OPEN c_validate_sob_org_combo;
   FETCH c_validate_sob_org_combo
    INTO l_name;

   IF (c_validate_sob_org_combo%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME('IGC', 'IGC_NO_SOB_ORG_COMBO');
      FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(p_set_of_books_id), TRUE);
      FND_MESSAGE.SET_TOKEN('ORG_ID', TO_CHAR(p_org_id), TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Update API Validate Set of books ID and Org ID Combo Failed...';
          IF(g_excep_level >= g_debug_level) THEN
              FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_CC_NOT_FOUND;
   END IF;

-- --------------------------------------------------------------------
-- Make sure that the CC can be found.
-- --------------------------------------------------------------------
    OPEN c_cc_header_exist;
   FETCH c_cc_header_exist
    INTO l_cc_header_id;

   IF (c_cc_header_exist%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num, TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update APi CC Found or not...'||x_msg_data;
         IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_CC_NOT_FOUND;
   END IF;

-- --------------------------------------------------------------------
-- Validate that the CC Reference number is NOT NULL
-- --------------------------------------------------------------------
    OPEN c_val_ref_num;
   FETCH c_val_ref_num
    INTO l_cc_ref_num;

   IF (c_val_ref_num%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NO_UPD_NO_REF');
      FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num,TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update APi CC Found or not...'||x_msg_data;
         IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_CC_NOT_FOUND;
   END IF;

    OPEN c_cc_header_state;
   FETCH c_cc_header_state
    INTO l_cc_header_rec;

   IF (c_cc_header_state%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_APPRVD_CONFIRMED');
      FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num, TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update APi CC Found or not approved / confirmed...'||x_msg_data;
         IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_CC_NOT_FOUND;
   END IF;

   IF l_cc_header_rec.cc_type = 'C' THEN
      FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_TYPE_NOT_ALWD');
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update APi Action Not Allowed...'||x_msg_data;
         IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_INVALID_ACTION;
   END IF;

   BEGIN
      SELECT lkup.lookup_code,
             lkup.meaning
	INTO l_action_type_code,
             l_action_meaning
        FROM fnd_lookups lkup
       WHERE lkup.lookup_type = 'IGC_CC_ACTION_TYPE'
	 AND lkup.lookup_code = p_action_code
	 AND lkup.lookup_code IN ('OP','CL','OH','RH');

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
      	   FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_INVALID_ACTION_CODE');
      	   FND_MESSAGE.SET_TOKEN('ACTION_CODE', p_action_code,TRUE);
      	   FND_MSG_PUB.ADD;
           x_msg_data      := FND_MESSAGE.GET;
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_count     := 1;
           IF g_debug_mode = 'Y'
           THEN
              g_debug_msg := 'CC Update APi Invalid Action Code...'||x_msg_data;
              IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
              END IF;
              --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
           END IF;
	   RAISE E_INVALID_ACTION;
   END;

-- -------------------------------------------------------------------
-- Validate Last Update Login
-- -------------------------------------------------------------------
   IF l_current_login_id IS NOT NULL THEN

      BEGIN
         SELECT login_id
           INTO l_login_id
           FROM fnd_logins
          WHERE login_id = l_current_login_id;

         EXCEPTION

            WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPD_LOGIN');
               FND_MESSAGE.SET_TOKEN('LAST_UPDATE_LOGIN', TO_CHAR(l_current_login_id), TRUE);
               FND_MSG_PUB.ADD;
               x_msg_data      := FND_MESSAGE.GET;
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count     := 1;
               IF g_debug_mode = 'Y'
               THEN
                  g_debug_msg := 'CC Update API Validate Invalid Last Update Login...';
                  IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                  END IF;
                  --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
               RAISE E_CC_NOT_FOUND;
      END;

   ELSE

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPD_LOGIN');
      FND_MESSAGE.SET_TOKEN('LAST_UPDATE_LOGIN', TO_CHAR(l_current_login_id), TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Update API Validate Invalid Last Update Login is NULL...';
          IF(g_excep_level >= g_debug_level) THEN
               FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
          END IF;
          --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_CC_NOT_FOUND;

   END IF;

-- -------------------------------------------------------------------
-- Validate Last Updated By
-- -------------------------------------------------------------------
   IF l_current_user_id IS NOT NULL THEN

      BEGIN
         SELECT user_id
           INTO l_user_id
           FROM fnd_user
          WHERE user_id = l_current_user_id;

         EXCEPTION

            WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPDATED_BY');
               FND_MESSAGE.SET_TOKEN('LAST_UPDATED_BY', TO_CHAR(l_current_user_id), TRUE);
               FND_MSG_PUB.ADD;
               x_msg_data      := FND_MESSAGE.GET;
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count     := 1;
               IF g_debug_mode = 'Y'
               THEN
                   g_debug_msg := 'CC Update API Validate Invalid Last Updated By...';
                   IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
                  --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
               RAISE E_CC_NOT_FOUND;
      END;
   ELSE

      FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LAST_UPDATED_BY');
      FND_MESSAGE.SET_TOKEN('LAST_UPDATED_BY', TO_CHAR(l_current_user_id), TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update API Validate Invalid Last Updated By is NULL...';
         IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_CC_NOT_FOUND;

   END IF;

   BEGIN
      SELECT lkup.lookup_code,
             lkup.meaning
        INTO l_action_type_code,
             l_control_meaning
        FROM fnd_lookups lkup
       WHERE lkup.lookup_type = 'IGC_CC_CONTROL_STATUS'
         AND lkup.lookup_code = l_cc_header_rec.cc_ctrl_status;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_INVALID_CONTROL_STATUS');
           FND_MESSAGE.SET_TOKEN('CTRL_STATUS', l_cc_header_rec.cc_ctrl_status,TRUE);
           FND_MSG_PUB.ADD;
           x_msg_data      := FND_MESSAGE.GET;
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_count     := 1;
           IF g_debug_mode = 'Y'
           THEN
               g_debug_msg := 'CC Update APi Invalid Control Status ...'||x_msg_data;
                IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
                --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
           END IF;
           RAISE E_INVALID_ACTION;
   END;

-- --------------------------------------------------------------------
-- Check if the commitment action is allowed or not.
-- --------------------------------------------------------------------
   IF (l_cc_header_rec.cc_ctrl_status = 'E') THEN

      IF p_action_code NOT IN ('OP','OH') THEN
      	 FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_ACTION_NOT_ALLOWED');
      	 FND_MESSAGE.SET_TOKEN('CODE_MEANING', l_action_meaning,TRUE);
      	 FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num,TRUE);
      	 FND_MESSAGE.SET_TOKEN('CONT_STATUS', l_control_meaning,TRUE);
      	 FND_MSG_PUB.ADD;
         x_msg_data      := FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
        IF g_debug_mode = 'Y'
        THEN
            g_debug_msg := 'CC Update APi '||p_action_code||' Action not allowed ...'||x_msg_data;
            IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
            END IF;
            --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
	 RAISE E_INVALID_ACTION;
      END IF;

   ELSIF (l_cc_header_rec.cc_ctrl_status = 'O') THEN

      IF p_action_code NOT IN ('CL','OH') THEN
      	 FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_ACTION_NOT_ALLOWED');
         FND_MESSAGE.SET_TOKEN('CODE_MEANING', l_action_meaning,TRUE);
         FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num,TRUE);
         FND_MESSAGE.SET_TOKEN('CONT_STATUS', l_control_meaning,TRUE);
         FND_MSG_PUB.ADD;
       	 x_msg_data      := FND_MESSAGE.GET;
       	 x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Update APi '||p_action_code||' Action not allowed ...'||x_msg_data;
             IF(g_excep_level >= g_debug_level) THEN
                 FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
	 RAISE E_INVALID_ACTION;
      END IF;

   ELSIF (l_cc_header_rec.cc_ctrl_status = 'C') THEN

      IF p_action_code NOT IN ('OP','OH') THEN
         FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_ACTION_NOT_ALLOWED');
         FND_MESSAGE.SET_TOKEN('CODE_MEANING', l_action_meaning,TRUE);
         FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num,TRUE);
         FND_MESSAGE.SET_TOKEN('CONT_STATUS', l_control_meaning,TRUE);
      	 FND_MSG_PUB.ADD;
      	 x_msg_data      := FND_MESSAGE.GET;
       	 x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Update APi '||p_action_code||' Action not allowed ...'||x_msg_data;
             IF(g_excep_level >= g_debug_level) THEN
                 FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
	 RAISE E_INVALID_ACTION;
      END IF;

   ELSIF (l_cc_header_rec.cc_ctrl_status = 'H') THEN

      IF p_action_code NOT IN ('RH') THEN
         FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_ACTION_NOT_ALLOWED');
         FND_MESSAGE.SET_TOKEN('CODE_MEANING', l_action_meaning,TRUE);
         FND_MESSAGE.SET_TOKEN('CC_NUM', p_cc_num,TRUE);
         FND_MESSAGE.SET_TOKEN('CONT_STATUS', l_control_meaning,TRUE);
      	 FND_MSG_PUB.ADD;
         x_msg_data      := FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Update APi '||p_action_code||' Action not allowed ...'||x_msg_data;
             IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
	 RAISE E_INVALID_ACTION;
      END IF;

   END IF;

-- --------------------------------------------------------------------
-- Retaining the previous statuses of the contract
-- --------------------------------------------------------------------
   l_prev_ctrl_status   := l_cc_header_rec.cc_ctrl_status;
   l_prev_apprvl_status := l_cc_header_rec.cc_apprvl_status;

   IF (p_action_code = 'OP') THEN
      l_new_ctrl_status := 'O';
   ELSIF (p_action_code = 'CL') THEN
      l_new_ctrl_status := 'C';
   ELSIF (p_action_code = 'OH') THEN
      l_new_ctrl_status := 'H';
   ELSIF (p_action_code = 'RH') THEN
      l_new_ctrl_status := 'O';
      l_new_apprvl_status := 'RR';
   ELSE
      FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_INVALID_ACTION_CODE');
      FND_MESSAGE.SET_TOKEN('ACTION_CODE', p_action_code,TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update APi Invalid Action Code...'||x_msg_data;
         IF(g_excep_level >= g_debug_level) THEN
              FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
         END IF;
         --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      RAISE E_INVALID_ACTION;
   END IF;

   IF p_action_code = 'RH' THEN
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Update APi Release On Hold begins here ...';
         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

-- --------------------------------------------------------------------
-- Check Budgetary Control is on
-- --------------------------------------------------------------------
      IGC_CC_BUDGETARY_CTRL_PKG.CHECK_BUDGETARY_CTRL_ON (p_api_version	  => 1.0,
                                                         p_init_msg_list 	  => FND_API.G_FALSE,
                                                         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                                         X_return_status	  => l_return_status,
                                                         X_msg_count	  => l_msg_count,
                                                         X_msg_data	  => l_msg_data,
                                                         p_org_id		  => l_cc_header_rec.org_id,
                                                         p_sob_id		  => l_cc_header_rec.set_of_books_id,
                                                         p_cc_state	  => l_cc_header_rec.cc_state,
                                                         X_encumbrance_on   => l_encumbrance_flag
                                                        );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_msg_data      := FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Update APi Check Budgetary Control Not Successful...'||x_msg_data;
             IF(g_excep_level >= g_debug_level) THEN
                FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;
      	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSE
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Update APi Validate CC begins here ...';
             Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

-- --------------------------------------------------------------------
-- Validate the Accounting Date.
-- --------------------------------------------------------------------
	 IGC_CC_BUDGETARY_CTRL_PKG.Validate_CC (p_api_version 	      => 1.0,
						p_init_msg_list       => FND_API.G_FALSE,
						p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
						x_return_status	      => l_return_status,
						x_msg_count	      => l_msg_count,
						x_msg_data	      => l_msg_data,
						p_cc_header_id	      => l_cc_header_rec.cc_header_id,
						X_valid_cc	      => l_valid_cc,
						p_mode		      => 'E',
						p_field_from	      => 'APPROVAL',
						p_encumbrance_flag    => l_encumbrance_flag,
						p_sob_id	      => l_cc_header_rec.set_of_books_id,
						p_org_id	      => l_cc_header_rec.org_id,
						p_start_date          => TRUNC(l_cc_header_rec.cc_start_date),
					        p_end_date	      => TRUNC(l_cc_header_rec.cc_end_date),
						p_cc_type_code	      => l_cc_header_rec.cc_type,
						p_parent_cc_header_id => l_cc_header_rec.parent_header_id,
						p_cc_det_pf_date      => NULL,
						p_acct_date	      => TRUNC(l_cc_header_rec.cc_acct_date),
						p_prev_acct_date      => TRUNC(l_cc_header_rec.cc_acct_date),
						p_cc_state	      => l_cc_header_rec.cc_state
                                               );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_msg_data      := FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count     := 1;
            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Update APi Validate CC Not Successful...'||x_msg_data;
                IF(g_excep_level >= g_debug_level) THEN
                  FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
                --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
      	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	 ELSE
            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Update APi Approval Process begins here ...';
                Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;

	    SELECT to_char(IGC_CC_WF_ITEMKEY_S.NEXTVAL)
              INTO l_seq
              FROM sys.dual;

            l_itemkey  := TO_CHAR(l_cc_header_id) || '-' || l_seq;
	    l_itemtype :=  'CCAPPWF';

	    UPDATE igc_cc_headers_all  ICH
	       SET ICH.cc_ctrl_status   = l_new_ctrl_status,
		   ICH.cc_apprvl_status = l_new_apprvl_status,
		   ICH.wf_item_type     =  'CCAPPWF',
		   ICH.wf_item_key      = l_itemkey
	     WHERE ICH.cc_header_id     = l_cc_header_id
	       AND ICH.cc_num           = l_cc_header_rec.cc_num
	       AND ICH.set_of_books_id  = l_cc_header_rec.set_of_books_id
	       AND ICH.org_id           = l_cc_header_rec.org_id;

-- ---------------------------------------------------------------------
-- If the number of rows updated is NOT 1 then an exception must be
-- encountered.
-- ---------------------------------------------------------------------
            IF ((SQL%ROWCOUNT <> 1) AND (SQL%ROWCOUNT <> 0) ) THEN
               IF g_debug_mode = 'Y'
               THEN
                   g_debug_msg := 'CC Update APi Incorrect Update ...';
                   IF(g_excep_level >= g_debug_level) THEN
                      FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
                   --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;

	       ROLLBACK to CC_Update_API_PT;

	       FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_FOUND');
	       FND_MESSAGE.SET_TOKEN ('CC_NUM', to_char(l_cc_header_id));
	       x_msg_data      := FND_MESSAGE.GET;
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       x_msg_count     := 1;
            ELSE

               IF g_debug_mode = 'Y'
               THEN
                   g_debug_msg := 'CC Update APi Insert into Action History begins here ...';
                   Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;

-- ------------------------------------------------------------
-- Insert record into table IGC_CC_ACTIONS for action history.
-- ------------------------------------------------------------
               IGC_CC_ACTIONS_PKG.Insert_Row (1.0,
                     			      FND_API.G_FALSE,
                        		      FND_API.G_FALSE,
                        		      FND_API.G_VALID_LEVEL_FULL,
                        		      l_return_status,
                        		      l_msg_count,
                        		      l_msg_data,
                        		      l_row_id,
              	        		      l_cc_header_id,
	                		      NVL(l_cc_header_rec.cc_version_num, 0),
	                		      SUBSTR(p_action_code,1,2),
	                		      l_cc_header_rec.cc_state,
	                		      l_new_ctrl_status,
	                		      l_new_apprvl_status,
					      'CC Update API',
	                		      SYSDATE,
	                		      l_current_user_id,
	                		      l_current_login_id,
	                		      SYSDATE,
	                		      l_current_user_id
                                             );

               IF l_return_status IN ('E','U') THEN
		  ROLLBACK to CC_Update_API_PT;
		  x_msg_data      := FND_MESSAGE.GET;
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_msg_count     := 1;
                  IF g_debug_mode = 'Y'
                  THEN
              	      g_debug_msg := 'CC Update APi Action History Insertion Not Successful...'||l_msg_data;
                      IF(g_excep_level >= g_debug_level) THEN
                         FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                      END IF;
                      --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                  END IF;
      		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	       ELSE

-- ------------------------------------------------------------
-- Commit Have to be done here.
-- ------------------------------------------------------------
                  IF g_debug_mode = 'Y'
                  THEN
	     	      g_debug_msg := 'CC Update API Commiting before Approval process...';
		      Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                  END IF;
		  COMMIT WORK;

               END IF;

               IF g_debug_mode = 'Y'
               THEN
                   g_debug_msg := 'CC Update APi Preparer Can Approve Check begins here ...';
                  Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;

-- ------------------------------------------------------------
-- Approval process.
-- ------------------------------------------------------------
	       IGC_CC_APPROVAL_PROCESS.preparer_can_approve (p_api_version	=> 1.0,
 		    			 	             p_init_msg_list     => FND_API.G_FALSE,
		     					     p_commit           	=> FND_API.G_FALSE,
		   			  		     p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
					    		     x_return_status     => l_return_status,
		   			  		     x_msg_count	      	=> l_msg_count,
		  			   		     x_msg_data	      	=> l_msg_data,
							     p_org_id		=> l_cc_header_rec.org_id,
		    					     p_cc_state  	=> l_cc_header_rec.cc_state,
		    					     p_cc_type   	=> l_cc_header_rec.cc_type,
							     x_result		=> l_result
                                                            );

	       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        	  x_msg_data      := FND_MESSAGE.GET;
        	  x_return_status := FND_API.G_RET_STS_ERROR;
        	  x_msg_count     := 1;
                  IF g_debug_mode = 'Y'
                  THEN
              	      g_debug_msg := 'CC Update APi Preparer Can Approve Not Successful...'||x_msg_data;
                      IF(g_excep_level >= g_debug_level) THEN
                        FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                      END IF;
                      --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                  END IF;
      		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	       ELSE
		  IF l_result <> FND_API.G_TRUE THEN
                     IF g_debug_mode = 'Y'
                     THEN
        	          g_debug_msg := 'CC Update APi Workflow Call begins here ...'||l_result;
                          Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                     END IF;

-- ------------------------------------------------------------
-- call to Approval Workflow Procedure
-- ------------------------------------------------------------
		     IGC_CC_APPROVAL_WF_PKG.Start_Process (p_api_version	      => 1.0,
 		  				   	   p_init_msg_list    => FND_API.G_FALSE,
		   				  	   p_commit           => FND_API.G_FALSE,
						     	   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
							   p_wf_version	      => 2,
						    	   x_return_status    => l_return_status,
		 				    	   x_msg_count	      => l_msg_count,
						     	   x_msg_data	      => l_msg_data,
							   p_item_key	      => l_itemkey,
						     	   p_cc_header_id     => l_cc_header_rec.cc_header_id,
                                                           p_acct_date        => l_cc_header_rec.cc_acct_date,
							   p_note	      => 'CC Update API',
							   p_debug_mode	      => g_debug_mode
                                                          );
	          ELSE

                    IF g_debug_mode = 'Y'
                    THEN
        	         g_debug_msg := 'CC Update APi Approved by preparer begins here ...';
                         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                     END IF;

		     IGC_CC_APPROVAL_PROCESS.approved_by_preparer (
                                                            p_api_version       => 1.0,
	 			     			    p_init_msg_list     => FND_API.G_FALSE,
		     					    p_commit            => FND_API.G_FALSE,
		     					    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
		    					    p_return_status     => l_return_status,
		     					    p_msg_count	        => l_msg_count,
		     					    p_msg_data	        => l_msg_data,
		     					    p_cc_header_id      => l_cc_header_rec.cc_header_id,
		     					    p_org_id	        => l_cc_header_rec.org_id,
		     					    p_sob_id	        => l_cc_header_rec.set_of_books_id,
		     					    p_cc_state	        => l_cc_header_rec.cc_state,
		     					    p_cc_type	        => l_cc_header_rec.cc_type,
		     					    p_cc_preparer_id    => l_cc_header_rec.cc_preparer_user_id,
		     					    p_cc_owner_id       => l_cc_header_rec.cc_owner_user_id,
		     					    p_cc_current_owner  => l_cc_header_rec.cc_current_user_id,
		     					    p_cc_apprvl_status  => l_cc_header_rec.cc_apprvl_status,
		     					    p_cc_encumb_status  => l_cc_header_rec.cc_encmbrnc_status,
		     					    p_cc_ctrl_status    => l_cc_header_rec.cc_ctrl_status,
		     					    p_cc_version_number => l_cc_header_rec.cc_version_num,
		     					    p_cc_notes	        => 'CC Update API',
							    p_acct_date         => SYSDATE
		     				                        );

         	  END IF; -- l_result validation.
	       END IF; -- Preparer Can approve call.
            END IF; -- Update of statuses.
	 END IF; -- Validate CC Accounting date validation.
      END IF; -- Check Budgetary Control on or not.

   ELSIF p_action_code IN ('OP','CL','OH') THEN

      IF g_debug_mode = 'Y'
      THEN
          g_debug_msg := 'CC Update APi Open, Close, On Hold Actions begins here ...';
          Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;

      UPDATE igc_cc_headers_all  ICH
	 SET ICH.cc_ctrl_status  = l_new_ctrl_status
       WHERE ICH.cc_header_id    = l_cc_header_id
	 AND ICH.cc_num          = l_cc_header_rec.cc_num
	 AND ICH.set_of_books_id = l_cc_header_rec.set_of_books_id
	 AND ICH.org_id          = l_cc_header_rec.org_id;

-- ---------------------------------------------------------------------
-- If the number of rows updated is NOT 1 then an exception must be
-- encountered.
-- ---------------------------------------------------------------------
      IF ((SQL%ROWCOUNT <> 1) AND (SQL%ROWCOUNT <> 0) ) THEN

	 ROLLBACK to CC_Update_API_PT;

	 FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_FOUND');
	 FND_MESSAGE.SET_TOKEN ('CC_NUM', to_char(l_cc_header_id));
	 x_msg_data      := FND_MESSAGE.GET;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 x_msg_count     := 1;
         IF g_debug_mode = 'Y'
         THEN
             g_debug_msg := 'CC Update APi Incorrect Update...'||x_msg_data;
             IF(g_excep_level >= g_debug_level) THEN
                   FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
             END IF;
             --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
         END IF;

      ELSE

	 IGC_CC_PO_INTERFACE_PKG.UPDATE_PO_APPROVED_FLAG (
 					p_api_version 		=> 1.0,
					p_init_msg_list 	=> FND_API.G_FALSE,
					p_commit 		=> FND_API.G_FALSE,
					p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
					X_return_status 	=> l_return_status,
					X_msg_count 		=> l_msg_count,
					X_msg_data 		=> l_msg_data,
                        		p_cc_header_id 		=> l_cc_header_rec.cc_header_id);

	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

            ROLLBACK to CC_Update_API_PT;
	    x_msg_data      := FND_MESSAGE.GET;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_msg_count     := 1;
            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Update APi Update PO Approved Flag Not Successful...'||x_msg_data;
                IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                END IF;
                --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;
      	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

	 ELSE

            IF g_debug_mode = 'Y'
            THEN
                g_debug_msg := 'CC Update APi Insert into Action History begins here ...';
                Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
            END IF;

-- ------------------------------------------------------------
-- Insert record into table IGC_CC_ACTIONS for action history.
-- ------------------------------------------------------------
	    IGC_CC_ACTIONS_PKG.Insert_Row (1.0,
                     			FND_API.G_FALSE,
                        		FND_API.G_FALSE,
                        		FND_API.G_VALID_LEVEL_FULL,
                        		l_return_status,
                        		l_msg_count,
                        		l_msg_data,
                        		l_row_id,
              	        		l_cc_header_id,
	                		NVL(l_cc_header_rec.cc_version_num, 0),
	                		SUBSTR(p_action_code,1,2),
	                		l_cc_header_rec.cc_state,
	                		l_new_ctrl_status,
	                		l_cc_header_rec.cc_apprvl_status,
					'CC Update API',
	                		sysdate,
	                		l_current_user_id,
	                		l_current_login_id,
	                		sysdate,
	                		l_current_user_id );

            IF l_return_status IN ('E','U') THEN
	       ROLLBACK to CC_Update_API_PT;
	       x_msg_data      := FND_MESSAGE.GET;
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       x_msg_count     := 1;
               IF g_debug_mode = 'Y'
               THEN
                   g_debug_msg := 'CC Update APi Action History Insertion Not Successful...'||l_msg_data;
                   IF(g_excep_level >= g_debug_level) THEN
                     FND_LOG.STRING(g_excep_level, l_full_path,g_debug_msg );
                   END IF;
                   --Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
               END IF;
      	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSE

 	       IF FND_API.To_Boolean(l_commit) THEN
                  IF g_debug_mode = 'Y'
                  THEN
	      	      g_debug_msg := 'CC Update API Commiting After Successful Commitment Actions Open or Close or On Hold...';
		      Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
                  END IF;
   		  COMMIT WORK;
	       END IF;

            END IF;
	 END IF; -- Update PO Approved Flag results.
      END IF; -- Update Control Statuses.
   END IF; -- Commitment Actions line Open , Close , On Hold.

-- --------------------------------------------------------------------
-- Close Cursor
-- --------------------------------------------------------------------
   IF (c_cc_header_state%ISOPEN) THEN
      CLOSE c_cc_header_state;
   END IF;
   IF (c_cc_header_exist%ISOPEN) THEN
      CLOSE c_cc_header_exist;
   END IF;
   IF (c_val_ref_num%ISOPEN) THEN
      CLOSE c_val_ref_num;
   END IF;
   IF (c_validate_sob_org_combo%ISOPEN) THEN
      CLOSE c_validate_sob_org_combo;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the CC_Update_API procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR  THEN
       x_msg_data      := FND_MESSAGE.GET;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       ROLLBACK to CC_Update_API_PT;
       IF (c_cc_header_state%ISOPEN) THEN
          CLOSE c_cc_header_state;
       END IF;
       IF (c_cc_header_exist%ISOPEN) THEN
          CLOSE c_cc_header_exist;
       END IF;
       IF (c_val_ref_num%ISOPEN) THEN
          CLOSE c_val_ref_num;
       END IF;
       IF (c_validate_sob_org_combo%ISOPEN) THEN
          CLOSE c_validate_sob_org_combo;
       END IF;
       -- Bug 3199488
       IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
       END IF;
       -- Bug 3199488
       RETURN;

   WHEN E_INVALID_ACTION  THEN
       x_msg_data      := FND_MESSAGE.GET;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := 1;
       ROLLBACK to CC_Update_API_PT;
       IF (c_cc_header_state%ISOPEN) THEN
          CLOSE c_cc_header_state;
       END IF;
       IF (c_cc_header_exist%ISOPEN) THEN
          CLOSE c_cc_header_exist;
       END IF;
       IF (c_val_ref_num%ISOPEN) THEN
          CLOSE c_val_ref_num;
       END IF;
       IF (c_validate_sob_org_combo%ISOPEN) THEN
          CLOSE c_validate_sob_org_combo;
       END IF;
       -- Bug 3199488
       IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'E_INVALID_ACTION Exception Raised');
       END IF;
       -- Bug 3199488
       RETURN;

   WHEN E_CC_NOT_FOUND THEN
       x_msg_data      := FND_MESSAGE.GET;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := 1;
       ROLLBACK to CC_Update_API_PT;
       IF (c_cc_header_state%ISOPEN) THEN
          CLOSE c_cc_header_state;
       END IF;
       IF (c_cc_header_exist%ISOPEN) THEN
          CLOSE c_cc_header_exist;
       END IF;
       IF (c_val_ref_num%ISOPEN) THEN
          CLOSE c_val_ref_num;
       END IF;
       IF (c_validate_sob_org_combo%ISOPEN) THEN
          CLOSE c_validate_sob_org_combo;
       END IF;
       -- Bug 3199488
       IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'E_CC_NOT_FOUND Exception Raised');
       END IF;
-- Bug 3199488
       RETURN;

   WHEN OTHERS THEN
       x_msg_data      := FND_MESSAGE.GET;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       IF (c_cc_header_state%ISOPEN) THEN
          CLOSE c_cc_header_state;
       END IF;
       IF (c_cc_header_exist%ISOPEN) THEN
          CLOSE c_cc_header_exist;
       END IF;
       IF (c_val_ref_num%ISOPEN) THEN
          CLOSE c_val_ref_num;
       END IF;
       IF (c_validate_sob_org_combo%ISOPEN) THEN
          CLOSE c_validate_sob_org_combo;
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488
       RETURN;

END CC_Update_Control_Status_API;


--
-- Output_Debug Procedure is the Generic procedure designed for outputting debug
-- information that is required from this procedure.
--
-- Parameters :
--
-- p_debug_msg ==> Record to be output into the debug log file.
--
PROCEDURE Output_Debug (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2
) IS

-- Constants :

/*   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(6)           := 'CC_API';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';*/

BEGIN

/*   IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;
*/
   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level,p_path, p_debug_msg);
   END IF;
   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;

   WHEN OTHERS THEN
       /*IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;*/
       RETURN;

END Output_Debug;

-- ---------------------------------------------------------------------------
-- The CC_Get_API procedure is designed to be an API that can
-- be used by external systems to obtain the existing reference number for
-- a given Contract Commitment Number
-- ---------------------------------------------------------------------------
PROCEDURE CC_Get_API (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   p_validation_level   IN NUMBER,
   p_cc_num             IN igc_cc_headers.cc_num%TYPE,
   p_org_id             IN igc_cc_headers.org_id%TYPE,
   p_set_of_books_id    IN igc_cc_headers.set_of_books_id%TYPE,
   x_cc_header_id      OUT NOCOPY igc_cc_headers.cc_header_id%TYPE,
   x_cc_ref_num        OUT NOCOPY igc_cc_headers.cc_ref_num%TYPE,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
) IS

   CURSOR c_check_cc_num IS
      SELECT ICH.cc_header_id,
             ICH.cc_ref_num
        FROM igc_cc_headers ICH
       WHERE ICH.org_id          = p_org_id
         AND ICH.set_of_books_id = p_set_of_books_id
         AND ICH.cc_num          = p_cc_num;

   CURSOR c_validate_sob_org_combo IS
      SELECT HAOU.name
        FROM hr_organization_information OOD,
             hr_all_organization_units HAOU
       WHERE OOD.organization_id = p_org_id
         AND OOD.organization_id = HAOU.organization_id
         AND OOD.org_information3 || '' = to_char(p_set_of_books_id)
         AND HAOU.organization_id || '' = OOD.organization_id;

   l_api_name       VARCHAR2(30);
   l_api_version    NUMBER;
   l_debug          VARCHAR2 (1);
   l_name           hr_all_organization_units.name%TYPE;

   l_full_path                  VARCHAR(500);
   l_init_msg_list varchar2(2000);
   l_commit    varchar2(2000);
   l_validation_level NUMBER;
BEGIN
--Added by svaithil for GSCC warnings

   l_init_msg_list := nvl(p_init_msg_list,FND_API.G_FALSE);
   l_commit        := nvl(p_commit,FND_API.G_FALSE);
   l_validation_level  := nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL);
   l_api_name   := 'CC_Get_API';
   l_api_version      := 1.0;

-- -------------------------------------------------------------------
-- Initialize the return values
-- -------------------------------------------------------------------
   x_cc_header_id   := NULL;
   x_cc_ref_num     := NULL;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_msg_data       := NULL;
   x_msg_count      := 0;
   l_full_path := g_path||'cc_get_API';
-- -------------------------------------------------------------------
-- Setup Debug info for API usage if needed.
-- -------------------------------------------------------------------
--   l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

-- -------------------------------------------------------------------
-- Make sure that the appropriate version is being used
-- -------------------------------------------------------------------
   IF (NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

-- -------------------------------------------------------------------
-- Make sure that if the message stack is to be initialized it is.
-- -------------------------------------------------------------------
   IF (FND_API.to_Boolean ( l_init_msg_list )) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- -------------------------------------------------------------------
-- Validate Org ID and set of Books ID Combination.
-- -------------------------------------------------------------------
    OPEN c_validate_sob_org_combo;
   FETCH c_validate_sob_org_combo
    INTO l_name;

   IF (c_validate_sob_org_combo%NOTFOUND) THEN

      FND_MESSAGE.SET_NAME('IGC', 'IGC_NO_SOB_ORG_COMBO');
      FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(p_set_of_books_id), TRUE);
      FND_MESSAGE.SET_TOKEN('ORG_ID', TO_CHAR(p_org_id), TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_cc_header_id  := NULL;
      x_cc_ref_num    := NULL;

   ELSE

-- -------------------------------------------------------------------
-- Open the Cursor that will determine if the CC Header ID can be
-- found based upon the CC number, ORG ID, and SOB ID.
-- -------------------------------------------------------------------
       OPEN c_check_cc_num;
      FETCH c_check_cc_num
       INTO x_cc_header_id,
            x_cc_ref_num;

      IF (c_check_cc_num%NOTFOUND) THEN

         FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN ('CC_NUM', p_cc_num);
         FND_MSG_PUB.ADD;
         x_msg_data      := FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
         x_cc_header_id  := NULL;
         x_cc_ref_num    := NULL;

      END IF;

   END IF;

-- -------------------------------------------------------------------
-- Close all cursors.
-- -------------------------------------------------------------------
   IF (c_check_cc_num%ISOPEN) THEN
      CLOSE c_check_cc_num;
   END IF;
   IF (c_validate_sob_org_combo%ISOPEN) THEN
      CLOSE c_validate_sob_org_combo;
   END IF;

   RETURN;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_cc_header_id  := NULL;
      x_cc_ref_num    := NULL;
      IF (c_check_cc_num%ISOPEN) THEN
         CLOSE c_check_cc_num;
      END IF;
      IF (c_validate_sob_org_combo%ISOPEN) THEN
         CLOSE c_validate_sob_org_combo;
      END IF;
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                  l_api_name);
      END IF;
      -- Bug 3199488
      IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
      END IF;
      -- Bug 3199488
      RETURN;

END CC_Get_API;

-- ---------------------------------------------------------------------------
-- The CC_Link_API procedure is designed to be an API that can
-- be used by external systems to Link a Contract Commitment document to a
-- document that was created via an External System
-- ---------------------------------------------------------------------------
PROCEDURE CC_Link_API (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   p_validation_level   IN NUMBER ,
   p_cc_ref_num         IN igc_cc_headers.cc_ref_num%TYPE,
   p_org_id             IN igc_cc_headers.org_id%TYPE,
   p_set_of_books_id    IN igc_cc_headers.set_of_books_id%TYPE,
   p_cc_num             IN igc_cc_headers.cc_num%TYPE,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
) IS

   CURSOR c_check_cc_num IS
      SELECT ICH.cc_num,
             ICH.cc_header_id
        FROM igc_cc_headers ICH
       WHERE /*ICH.org_id          = p_org_id
         AND ICH.set_of_books_id = p_set_of_books_id
         AND --Commented during r12 MOAC uptake */
	ICH.cc_num          = p_cc_num;

   CURSOR c_check_dup_ref_num IS
      SELECT ICH.cc_ref_num
        FROM igc_cc_headers ICH
       WHERE /*ICH.org_id          = p_org_id
         AND ICH.set_of_books_id = p_set_of_books_id
         AND --Commented during MOAC uptake */
	ICH.cc_ref_num      = p_cc_ref_num;

   CURSOR c_validate_sob_org_combo IS
      SELECT HAOU.name
        FROM hr_organization_information OOD,
             hr_all_organization_units HAOU
       WHERE OOD.organization_id = p_org_id
         AND OOD.organization_id = HAOU.organization_id
         AND OOD.org_information3 || '' = to_char(p_set_of_books_id)
         AND HAOU.organization_id || '' = OOD.organization_id;

   l_api_name       VARCHAR2(30);
   l_api_version    NUMBER ;
   l_debug          VARCHAR2(1);
   l_cc_num         igc_cc_headers.cc_num%TYPE;
   l_cc_ref_num     igc_cc_headers.cc_ref_num%TYPE;
   l_cc_header_id   igc_cc_headers.cc_header_id%TYPE;
   l_name           hr_all_organization_units.name%TYPE;

   l_full_path                  VARCHAR(500);
   l_init_msg_list    varchar2(2000);
   l_commit          varchar2(2000);
   l_validation_level  NUMBER;
BEGIN

--Added by svaithil for GSCC warnings

   l_init_msg_list    := nvl(p_init_msg_list,FND_API.G_FALSE);
   l_commit           := nvl(p_commit,FND_API.G_FALSE);
   l_validation_level := nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL);
   l_api_name         := 'CC_Link_API';
   l_api_version      := 1.0;
-- -------------------------------------------------------------------
-- Initialize the return values
-- -------------------------------------------------------------------
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_msg_data       := NULL;
   x_msg_count      := 0;

   SAVEPOINT CC_Link_API_PT;
   l_full_path := g_path||'cc_link_API';

-- -------------------------------------------------------------------
-- Setup Debug info for API usage if needed.
-- -------------------------------------------------------------------
--   l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

-- --------------------------------------------------------------------
-- Make sure that the appropriate version is being used
-- --------------------------------------------------------------------
   IF (NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

-- --------------------------------------------------------------------
-- Make sure that if the message stack is to be initialized it is.
-- --------------------------------------------------------------------
   IF (FND_API.to_Boolean ( l_init_msg_list )) THEN
      FND_MSG_PUB.initialize ;
   END IF;

-- -------------------------------------------------------------------
-- Validate Org ID and set of Books ID Combination.
-- -------------------------------------------------------------------
    OPEN c_validate_sob_org_combo;
   FETCH c_validate_sob_org_combo
    INTO l_name;

   IF (c_validate_sob_org_combo%NOTFOUND) THEN

      FND_MESSAGE.SET_NAME('IGC', 'IGC_NO_SOB_ORG_COMBO');
      FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(p_set_of_books_id), TRUE);
      FND_MESSAGE.SET_TOKEN('ORG_ID', TO_CHAR(p_org_id), TRUE);
      FND_MSG_PUB.ADD;
      x_msg_data      := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;

   ELSE

-- --------------------------------------------------------------------
-- Make sure that the CC can be found.
-- --------------------------------------------------------------------
      OPEN c_check_cc_num;
     FETCH c_check_cc_num
      INTO l_cc_num,
           l_cc_header_id;

      IF (c_check_cc_num%NOTFOUND) THEN

         FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN ('CC_NUM', p_cc_num);
         FND_MSG_PUB.ADD;
         x_msg_data      := FND_MESSAGE.GET;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;

      ELSE

          OPEN c_check_dup_ref_num;
         FETCH c_check_dup_ref_num
          INTO l_cc_ref_num;

         IF (c_check_dup_ref_num%NOTFOUND) THEN

            UPDATE igc_cc_headers_all  ICH
               SET ICH.cc_ref_num      = p_cc_ref_num
             WHERE ICH.cc_header_id    = l_cc_header_id
               AND ICH.cc_num          = p_cc_num
               AND ICH.set_of_books_id = p_set_of_books_id
               AND ICH.org_id          = p_org_id;

-- ---------------------------------------------------------------------
-- If the number of rows updated is NOT 1 then an exception must be
-- encountered.
-- ---------------------------------------------------------------------
            IF ( (SQL%ROWCOUNT <> 1) AND (SQL%ROWCOUNT <> 0) ) THEN

               ROLLBACK to CC_Link_API_PT;

               FND_MESSAGE.SET_NAME ('IGC', 'IGC_CC_NOT_FOUND');
               FND_MESSAGE.SET_TOKEN ('CC_NUM', p_cc_num);
               FND_MSG_PUB.ADD;
               x_msg_data      := FND_MESSAGE.GET;
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count     := 1;

            END IF;

         ELSE

-- --------------------------------------------------------------------
-- Duplicate Reference numbers not allowed for the same org and SOB
-- --------------------------------------------------------------------
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DUP_CC_REF_NUM');
            FND_MESSAGE.SET_TOKEN('CC_REF_NUM', p_cc_ref_num);
            FND_MSG_PUB.ADD;
            x_msg_data      := FND_MESSAGE.GET;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count     := 1;

         END IF;

      END IF;

   END IF;

-- --------------------------------------------------------------------
-- Committing the record based on the value passed as a parameter.
-- --------------------------------------------------------------------
   IF FND_API.To_Boolean(l_commit) THEN
      IF g_debug_mode = 'Y'
      THEN
         g_debug_msg := 'CC Link API Commiting After Successful Link...';
         Output_Debug( l_full_path,p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END IF;

-- --------------------------------------------------------------------
-- Close Cursor
-- --------------------------------------------------------------------
   IF (c_check_cc_num%ISOPEN) THEN
      CLOSE c_check_cc_num;
   END IF;
   IF (c_check_dup_ref_num%ISOPEN) THEN
      CLOSE c_check_dup_ref_num;
   END IF;
   IF (c_validate_sob_org_combo%ISOPEN) THEN
      CLOSE c_validate_sob_org_combo;
   END IF;

   RETURN;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_check_cc_num%ISOPEN) THEN
         CLOSE c_check_cc_num;
      END IF;
      IF (c_check_dup_ref_num%ISOPEN) THEN
         CLOSE c_check_dup_ref_num;
      END IF;
      IF (c_validate_sob_org_combo%ISOPEN) THEN
         CLOSE c_validate_sob_org_combo;
      END IF;

      ROLLBACK to CC_Link_API_PT;

      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                  l_api_name);
      END IF;
      -- Bug 3199488
      IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
      END IF;
      -- Bug 3199488
      RETURN;

END CC_Link_API;

/* Added below API during MOAC uptake for bug#6341012
This procedure intilalizes global variables and MOAC initialization will be done
It also validates the ORG_ID and sets ORG Context */

PROCEDURE Set_Global_Info
          (p_api_version_number  IN NUMBER,
           p_responsibility_id   IN NUMBER,
           p_user_id           IN NUMBER,
           p_resp_appl_id      IN NUMBER,
           p_operating_unit_id   IN NUMBER,
           x_return_status      OUT NOCOPY   VARCHAR2,
           x_msg_count          OUT NOCOPY   NUMBER,
           x_msg_data           OUT NOCOPY   VARCHAR2

) IS
l_operating_unit_id NUMBER;
l_api_version_number    CONSTANT    NUMBER      :=  1.0;
l_api_name              CONSTANT    VARCHAR2(30):= 'Set_Global_Info';
l_value_conversion_error            BOOLEAN     :=  FALSE;
l_return_status                     VARCHAR2(1);
l_dummy         VARCHAR2(1);
l_temp_num              NUMBER ;

l_msg_data varchar2(2000);
l_msg_count number;
l_product_code varchar2(3) := 'IGI';


/** cursor l_resp_csr to check the combination of
resposibility and application id. **/

CURSOR l_resp_csr IS
SELECT 'x'
FROM  fnd_responsibility
WHERE responsibility_id = p_responsibility_id
AND application_id = p_resp_appl_id;



CURSOR l_user_csr IS
SELECT 'x'
FROM fnd_user
WHERE user_id = p_user_id;
l_resp_csr_rec      l_resp_csr%ROWTYPE;

BEGIN
  -- Standard Api compatibility call
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Ensure the responsibility id passed is valid
    IF p_responsibility_id IS NULL  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_RESP_ID_INVALID');
        FND_MSG_PUB.add;
    END IF;

    RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN l_resp_csr;
    FETCH l_resp_csr INTO l_dummy;
    IF l_resp_csr%NOTFOUND THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('IGC','IGC_RESP_ID_INVALID');
          FND_MSG_PUB.add;
       END IF;
       CLOSE l_resp_csr;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       CLOSE l_resp_csr;
    END IF;

  -- Ensure the user id passed is valid
    IF p_user_id IS NULL  THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_USER_ID_INVALID');
        FND_MSG_PUB.add;
    END IF;

    RAISE FND_API.G_EXC_ERROR;
    END IF;


    OPEN l_user_csr ;
    FETCH l_user_csr INTO l_dummy;
    IF l_user_csr%NOTFOUND THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('IGC','IGC_USER_ID_INVALID');
          FND_MSG_PUB.add;
       END IF;
       CLOSE l_user_csr;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       CLOSE l_user_csr;    END IF;


-- Based on the Responsibility, Intialize the Application

        FND_GLOBAL.Apps_Initialize
                ( user_id               => p_user_id
                  , resp_id             => p_responsibility_id
                  , resp_appl_id        => p_resp_appl_id
                );



        If NVL(mo_global.get_ou_count, 0)  = 0  then
   		 MO_GLOBAL.INIT(l_product_code);
 	 end if ;

  	 l_operating_unit_id := GET_VALID_OU(p_operating_unit_id, l_product_code);

    IF l_operating_unit_id IS NULL THEN
       FND_MSG_PUB.Initialize;

      x_return_status := FND_API.G_RET_STS_ERROR;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

		FND_MESSAGE.SET_NAME('IGC','IGC_MOAC_PASS_VALID_ORG');
		FND_MSG_PUB.add;
		FND_MSG_PUB.Count_And_Get
				(   p_count  =>	x_msg_count 	,
				    p_data   =>	x_msg_data	);
	END IF;
    else
        MO_GLOBAL.SET_POLICY_CONTEXT('S',l_operating_unit_id);
    END IF;

        IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR ;
        END IF ;

        -- -----------------------------------------------------------------------------


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
            (   p_count     =>  x_msg_count ,
                p_data      =>  x_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  x_msg_count ,
                p_data      =>  x_msg_data  );

    WHEN OTHERS
    THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  x_msg_count ,
                p_data      =>  x_msg_data  );

END Set_global_info;

FUNCTION GET_VALID_OU
( p_org_id  hr_operating_units.organization_id%TYPE DEFAULT NULL , p_product_code VARCHAR2  )
RETURN NUMBER

/*
-- This function is used to determine and get valid operating unit where cc is enabled for this operating unit.
-- Returns ORG_ID if valid and CC is enabled or retruns NULL if invalid or CC is not enabled.

-- This function uses  MO_GLOBAL.validate_orgid_pub_api(...) to get valid org_id.
-- MO_GLOBAL.validate_orgid_pub_api retruns p_org_id if Valid or returns NULL if invalid .
-- If p_org_id  does not exist in Global table, then it would throw up error.
-- Before calling this function, global temp table should be populated using MO initialization routine. */

IS
 l_org_id NUMBER ;
 l_status  VARCHAR2(1);

BEGIN
   l_org_id := p_org_id ;

  -- VALIDATE_ORGID_PUB_API will retrun either
 -- Success ( 'S','O','C','D') or Failure ( 'F')

      mo_global.validate_orgid_pub_api( l_org_id, 'Y',l_status );
/* This function is used to determine and get valid operating unit where CC is enabled.

 -- Checking if CC is enabled or not */

  If l_org_id is not null and l_status IN ( 'S','O','C','D')  then
       If p_product_code = 'CC' then
          If  igi_gen.is_req_installed(p_product_code,l_org_id) = 'Y' then
             RETURN l_org_id ;
          else
             RETURN NULL  ;
          end if ;
        End if ;
  else
   RETURN NULL;
  End if ;

END GET_VALID_OU;


--Added by svaithil for GSCC warnings on 20/05/2004
begin
   G_PKG_NAME     := 'IGC_CC_OPN_UPD_GET_LNK_PUB';
   g_debug_msg    := NULL;
   g_debug_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_state_level  := FND_LOG.LEVEL_STATEMENT;
   g_proc_level   := FND_LOG.LEVEL_PROCEDURE;
   g_event_level  := FND_LOG.LEVEL_EVENT;
   g_excep_level  := FND_LOG.LEVEL_EXCEPTION;
   g_error_level  := FND_LOG.LEVEL_ERROR;
   g_unexp_level  := FND_LOG.LEVEL_UNEXPECTED;
   g_path         := 'IGC.PLSQL.IGCOUGLB.IGC_CC_OPN_UPD_GET_LNK_PUB.';
   g_debug_mode   := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


END IGC_CC_OPN_UPD_GET_LNK_PUB;

/
