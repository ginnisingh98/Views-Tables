--------------------------------------------------------
--  DDL for Package Body GR_DISPATCH_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DISPATCH_HISTORY_PVT" AS
/* $Header: GRVDSPHB.pls 120.5 2005/10/19 12:22:14 pbamb noship $ */

PROCEDURE log_msg(p_msg_text IN VARCHAR2);

/*  Global variables */
G_tmp	       BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
						              -- msg level threshhold gobal
							      -- variable.
G_debug_level  NUMBER := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
							       -- to decide to log a debug msg.
G_PKG_NAME CONSTANT varchar2(30) := 'GR_DISPATCH_HISTORY_PVT';

g_log_head    CONSTANT VARCHAR2(50) := 'gr.plsql.'|| G_PKG_NAME || '.';

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_dispatch_history
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure inserts records in the dispatch history table after validations.
--Parameters:
--IN:
-- Version of API to validate compatibility
--p_api_version                      IN      		NUMBER,
-- Initialize message  stack  (TRUE or FALSE)
--p_init_msg_list         	         IN      		VARCHAR2,
-- Issue database commit after update (TRUE or FALSE)
--p_commit                  	         IN      		VARCHAR2,
-- iInventory_item_id of item/product that document is related to
--p_inventory_tem_id                     IN                	NUMBER,
-- Item/product that document is related to
--p_organization_id                      IN          		NUMBER,
-- Organization_id that document is generated for
--p_item                                 IN                		VARCHAR2,
-- CAS # of item/product that document is related to
--p_cas_number                    IN                		VARCHAR2,
-- Document recipient ID
--p_recipient_id                    IN                		NUMBER,
-- Document recipient site ID
--p_recipient_site_id             IN                		NUMBER,
-- Date document was sent to recipient
--p_date_sent                         IN                		DATE,
-- Method used to send the document to recipient
--p_dispatch_method_code  IN      	 	NUMBER,
-- ID of saved document (document is already in the system)
--p_document_id                  IN               		NUMBER,
-- Physical Location of the document
--p_document_location         IN               		VARCHAR2,
-- Actual name of File
--p_document_name             IN               		VARCHAR2,
-- Version of document
--p_document_version          IN               		VARCHAR2,
-- Category to assign document to
--p_document_category        IN               		VARCHAR2,
-- Format of file - e.g. XML, pdf, etc
--p_file_format                      IN               		VARCHAR2,
-- Description of document
--p_file_description              IN                		VARCHAR2,
-- Type of  regulatory document - e.g. US16, CA16, etc.
--p_document_code              IN             		VARCHAR2,
-- Disclosure code used to generate the document
--p_disclosure_code              IN          		VARCHAR2,
-- Language that document was generated in
--p_language                         IN          		VARCHAR2,
-- Organization document was created for
--p_organization_code          IN          		VARCHAR2,
-- User id to use for who columns
--p_user_id                            IN      		NUMBER,
-- Specifies the application calling this API (0 - External application ,1- Internal application, 2 - Form)
--p_creation_source  	         IN      		NUMBER,

--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_count                Number of error message in the error message
--                           list
--
--x_msg_data                 If the number of error message in the error
--                           message list is one, the error message
--                           is in this output parameter
--Testing:
--
-- History:
-- M. Grosser 23-May-2005  Modified code for Inventory Convergence.
--            Added validation of organization_id and modified validations of
--            inventory_item_id and cas_number.
--  M. Grosser 29-Jun-2005  Modified code to use organization code from
--             organization_id validation for files_upload.
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE CREATE_DISPATCH_HISTORY_REC(
    p_item                 IN VARCHAR2,
    p_organization_id      IN NUMBER,
    p_inventory_item_id    IN NUMBER,
    p_cas_number           IN VARCHAR2,
    p_recipient_id         IN NUMBER,
    p_recipient_site_id    IN NUMBER,
    p_date_sent            IN DATE,
    p_dispatch_method_code IN NUMBER,
    p_document_id          IN NUMBER,
    p_document_location    IN VARCHAR2,
    p_document_name        IN VARCHAR2,
    p_document_version     IN VARCHAR2,
    p_document_category    IN VARCHAR2,
    p_file_format          IN VARCHAR2,
    p_file_description     IN VARCHAR2,
    p_document_code        IN VARCHAR2,
    p_disclosure_code      IN VARCHAR2,
    p_language             IN VARCHAR2,
    p_organization_code    IN VARCHAR2,
    p_user_id              IN NUMBER,
    p_creation_source  	   IN NUMBER,
    x_return_status        OUT NOCOPY   VARCHAR2 ,
    x_msg_count            OUT NOCOPY   NUMBER ,
    x_msg_data             OUT NOCOPY   VARCHAR2
)
IS

  l_progress	 VARCHAR2(3) := '000';

  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1);


--Cursor used to validate document id
CURSOR c_val_document_id IS
SELECT 1
FROM   fnd_documents
WHERE  document_id = p_document_id;

--Cursor used to see if document,version is already in the system
CURSOR c_check_document_edr IS
SELECT fnd_document_id , version_label
FROM   edr_files_b
WHERE  original_file_name = p_document_name
AND    version_label = nvl(p_document_version, version_label)
order by version_label desc;

CURSOR c_check_document_fnd IS
SELECT document_id
FROM   fnd_documents_vl
WHERE  file_name = p_document_name;

--Cursor used to see if document is already in the system
CURSOR c_get_doc_id IS
SELECT fnd_document_id
FROM   edr_files_b
WHERE  original_file_name = p_document_name;

--Cursor used to validate document category
CURSOR c_val_document_category IS
SELECT category_id
FROM   fnd_document_categories
WHERE  name = p_document_category;

--Cursor used to validate document language
CURSOR c_val_language IS
SELECT 1
FROM   fnd_languages
WHERE  language_code = p_language;

--Cursor used to validate user id
CURSOR c_val_user_id IS
SELECT 1
FROM   fnd_user
WHERE  user_id = p_user_id;

--Cursor used to retrieve actual file from temp table
CURSOR  c_get_file_data IS
SELECT  file_data
FROM    gr_upload_file_tmp
WHERE   request_id = -12345;

--Cursor used to retrieve the next dispatch history id
CURSOR  c_get_dispatch_history_id IS
SELECT  gr_dispatch_history_s.nextval
FROM    DUAL;

INVALID_VALUE EXCEPTION;
INVALID_USER_ID EXCEPTION;
INVALID_DOCUMENT_ID EXCEPTION;
INVALID_DOCUMENT_CATEGORY EXCEPTION;
INVALID_DISPATCH_METHOD_CODE EXCEPTION;
INVALID_DISCLOSURE_CODE EXCEPTION;
INVALID_DOCUMENT_LANGUAGE EXCEPTION;
INVALID_DATE_SENT EXCEPTION;
INVALID_CREATION_SOURCE EXCEPTION;
INVALID_RECIPIENT_ID EXCEPTION;
INVALID_RECIPIENT_SITE_ID EXCEPTION;
INVALID_DOCUMENT_VERSION EXCEPTION;
FILE_ERROR EXCEPTION;


   /****************  Local Variables****************/
     l_api_name              	CONSTANT    VARCHAR2(30)  := 'Creat Dispatch History';
     l_api_version           	CONSTANT    NUMBER        := 1.0;
     l_temp                     NUMBER;
     l_item                     VARCHAR2(240);
     l_file_data                BLOB;
     l_category_id              NUMBER;
     l_document_id              NUMBER;
     l_document_version         VARCHAR2(15);
     l_doc_found                BOOLEAN := FALSE;
     l_document_category_id     NUMBER;
     l_dispatch_history_id      NUMBER;
     l_concurrent_id            NUMBER;
     l_document_managment       VARCHAR2(50);
     l_file_exists_action       VARCHAR2(50);
     l_content_type             VARCHAR2(100);
     l_submit_for_approval      VARCHAR2(50);
     l_rowid                    VARCHAR2(80);
     l_inventory_item_id        NUMBER;
     l_document_location        VARCHAR2(240);
     l_document_name            VARCHAR2(240);
     l_org                      INV_VALIDATE.org;
     dummy                      BOOLEAN;



  l_phase          VARCHAR2(30) ;
  l_status         VARCHAR2(30) ;
  l_dev_phase      VARCHAR2(30) ;
  l_dev_status     VARCHAR2(30) ;
  l_line           VARCHAR2(80) ;
  l_message        VARCHAR2(240);
  l_interval       NUMBER := 5;
  l_maxwait        NUMBER := 6000;
  l_ret_status     BOOLEAN  ;
  l_commit_file    VARCHAR2(1) := 'F';


 BEGIN

    -- M. Grosser 23-May-2005  Added code for Inventory Convergence.
    --
    l_org.organization_id := p_organization_id;

    -- Validate organization
    l_temp := INV_VALIDATE.organization(l_org);
    IF (l_temp = INV_VALIDATE.F) THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
          log_msg('Organization id provided - organization validation failed.');
       END IF;
       RAISE INVALID_VALUE;
    END IF; -- If organization id is valid
    -- M. Grosser 23-May-2005  End of changes

   IF p_item IS NOT NULL THEN
      --Validate the item

      -- M. Grosser 23-May-2005  Modified code for Inventory Convergence.
      IF NOT (GR_VALIDATE.validate_item(p_organization_id, p_item, l_inventory_item_id)) THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	    log_msg('Item provided - item validation failed.');
         END IF;
         FND_MESSAGE.SET_NAME('GR','GR_INVALID_ITEM');
         FND_MESSAGE.SET_TOKEN('ITEM',p_item);
         FND_MSG_PUB.Add;
         RAISE INVALID_VALUE;
      END IF;

      l_item := p_item;

   ELSE
      --Validate the CAS #, return item
      -- M. Grosser 23-May-2005  Modified code for Inventory Convergence.
      IF NOT (GR_VALIDATE.validate_cas_number(p_organization_id, p_cas_number, l_item, l_inventory_item_id)) THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	    log_msg('CAS Number provided - CAS Number validation failed.');
         END IF;
         FND_MESSAGE.SET_NAME('GR','GR_INVALID_CAS_NUMBER');
         FND_MESSAGE.SET_TOKEN('CAS_NUMBER',p_cas_number);
         FND_MSG_PUB.Add;
         RAISE INVALID_VALUE;
      END IF;

   END IF;

   -- M. Grosser 23-May-2005  Added code for Inventory Convergence.
   --
   --  Make sure that inventory item matches item if it is not NULL
   IF ( (p_inventory_item_id is NOT NULL) AND
        (p_inventory_item_id <> -1)  AND
        (p_inventory_item_id <> l_inventory_item_id)) THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('Inventory Item ID provided -  No match to item provided.');
      END IF;
      FND_MESSAGE.SET_NAME('GR','GR_NO_ITEM_ID_MATCH');
      FND_MESSAGE.SET_TOKEN('ITEM_ID',p_inventory_item_id);
      FND_MESSAGE.SET_TOKEN('ITEM',l_item);
      FND_MSG_PUB.Add;
      RAISE INVALID_VALUE;

   END IF; -- ID matches item
   -- M. Grosser 23-May-2005  End of changes

   IF p_document_id is NOT NULL and p_document_id <> -1 THEN

      --Validate the document_id
      OPEN c_val_document_id;
      FETCH c_val_document_id INTO l_temp;

      --If document id not found
      IF c_val_document_id%NOTFOUND THEN
         CLOSE c_val_document_id;
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	    log_msg('Document ID provided - Document ID validation failed.');
         END IF;
         RAISE INVALID_DOCUMENT_ID;
      END IF;

      l_document_id := p_document_id ;
      CLOSE c_val_document_id ;

   ELSE

      -- See if document is already in the sytem
      OPEN c_check_document_edr;
      FETCH c_check_document_edr INTO l_document_id, l_document_version;
      --If document exists check its version. If the version is different then we need
      --to load a new version of this document.
      IF c_check_document_edr%FOUND THEN
         IF p_document_version IS NOT NULL and p_document_version <> l_document_version THEN
            l_doc_found := FALSE;
         ELSE
            l_doc_found := TRUE;
         END IF;
      ELSIF c_check_document_edr%NOTFOUND THEN
         --If document does not exist in fnd documents then we need to upload it.
         OPEN c_check_document_fnd;
         FETCH c_check_document_fnd INTO l_document_id;

         IF c_check_document_fnd%NOTFOUND THEN
            l_doc_found := FALSE;
         ELSE
            l_doc_found := TRUE;
         END IF;
         CLOSE c_check_document_fnd;
      END IF;
      CLOSE c_check_document_edr;

      --If it's not in the system, we will upload it
      IF NOT l_doc_found THEN

         --Validate the document category
         OPEN c_val_document_category;
         FETCH c_val_document_category INTO l_document_category_id;

         --If document category not found
         IF c_val_document_category%NOTFOUND THEN
            CLOSE c_val_document_category;
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Document Category provided - Document Category validation failed.');
            END IF;
            RAISE INVALID_DOCUMENT_CATEGORY;
         END IF;

         CLOSE c_val_document_category;

         --Validate the dispatch_method
         IF NOT(GR_VALIDATE.validate_dispatch_method_code(p_dispatch_method_code)) THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Dispatch Method provided - Dispatch Method validation failed.');
            END IF;
            RAISE INVALID_DISPATCH_METHOD_CODE;
         END IF;


         --Validate the disclosure code
         IF NOT(GR_VALIDATE.validate_disclosure_code(p_disclosure_code)) THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Disclosure Code provided - Disclosure Code validation failed.');
            END IF;
            RAISE INVALID_DISCLOSURE_CODE;
         END IF;


         --Validate the document language
         OPEN c_val_language;
         FETCH c_val_language INTO l_temp;

         --If document language is not found
         IF c_val_language %NOTFOUND THEN
            CLOSE c_val_language;
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Document Language provided - Document Language validation failed.');
            END IF;
            RAISE INVALID_DOCUMENT_LANGUAGE;
         END IF;

         CLOSE c_val_language;

         IF p_document_version IS NULL THEN
            RAISE INVALID_DOCUMENT_VERSION;
         END IF;


         l_document_location := substr(p_document_location,1,instr(p_document_location,':')-1);
         l_document_name := substr(p_document_location,instr(p_document_location,':')+1)||'/'||p_document_name;

         /* Submit the java concurrent program, to upload file to temp table. */
         l_concurrent_id := FND_REQUEST.SUBMIT_REQUEST
                                  ('GR', 'GR_FILE_UPLOAD', '', '', FALSE,
                                   l_document_location,l_document_name,
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '');
         IF l_concurrent_id = 0 THEN
            /* Java concurrent program failed, to print the attached document to an output file */
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Document upload to temp table failed.');
            END IF;
            FND_MESSAGE.SET_NAME('GR','GR_CONC_REQ_FILE_UPLOAD');
            FND_MESSAGE.SET_TOKEN('FILE_NAME', p_document_name, FALSE);
            FND_MSG_PUB.Add;
            RAISE FILE_ERROR;
         ELSE
            COMMIT;
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Document upload concurrent program fired - concurrent_id:'||to_char(l_concurrent_id));
            END IF;
            l_ret_status := FND_CONCURRENT.WAIT_FOR_REQUEST(l_concurrent_id,
                                                         l_interval,
                                                         l_maxwait,
                                                         l_phase,
                                                         l_status,
                                                         l_dev_phase,
                                                         l_dev_status,
                                                         l_message);
            IF (NOT l_ret_status) OR ((l_dev_phase = 'COMPLETE') and (l_dev_status = 'ERROR')) THEN
               RAISE FILE_ERROR;
            END IF;
         END IF;

         --Get the handle to the File
         OPEN c_get_file_data;
         FETCH c_get_file_data INTO l_file_data;
         IF c_get_file_data%NOTFOUND THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('Document cannot be read from temp table.');
            END IF;
            FND_MESSAGE.SET_NAME('GR','GR_CONC_REQ_FILE_UPLOAD');
            FND_MESSAGE.SET_TOKEN('FILE_NAME', p_document_name, FALSE);
            FND_MSG_PUB.Add;
            RAISE FILE_ERROR;
         END IF;
         CLOSE c_get_file_data;

         Delete from gr_upload_file_tmp where request_id = -12345;

         --Get the profile value to use to determine if file should be sent for approvals
         l_document_managment :=  FND_PROFILE.Value('GR_DOC_MANAGEMENT');

         /* Set the submit for approval variable */
         IF l_document_managment = 'A' THEN
            l_submit_for_approval := 'Y';
            l_commit_file         := 'T';
         ELSE
            l_submit_for_approval := 'N';
         END IF;

         --Get the profile value to use to determine what should be done if the file alredy exists
         l_file_exists_action := FND_PROFILE.Value('GR_DOC_MGMT_FILE_EXISTS_ACT');

         -- M. Grosser 29-Jun-2005:  Changed code to use organization_code returned from org validation
         --Call the Upload file API to upload the file into the iSignatures system
         EDR_FILES_PUB.UPLOAD_FILE
         (
                P_API_VERSION         =>         1.0,
		P_COMMIT              =>         l_commit_file,
		P_CALLED_FROM_FORMS   =>         'F',
		P_FILE_NAME           =>         p_document_name,
		P_CATEGORY            =>         p_document_category,
		P_CONTENT_TYPE        =>         p_file_format,
		P_VERSION_LABEL       =>         p_document_version,
		P_FILE_DATA           =>         l_file_data,
       	        P_FILE_FORMAT         =>         p_file_format,
       	        P_SOURCE_LANG         =>         p_language,
		P_DESCRIPTION         =>         p_file_description,
		P_FILE_EXISTS_ACTION  =>         l_file_exists_action,
 	 	P_SUBMIT_FOR_APPROVAL =>         l_submit_for_approval,
		P_ATTRIBUTE1          =>         l_item,
		P_ATTRIBUTE2          =>         p_document_code,
		P_ATTRIBUTE3          =>         p_language,
		P_ATTRIBUTE4          =>         p_disclosure_code,
		P_ATTRIBUTE5          =>         l_org.organization_code,
		P_ATTRIBUTE6          =>         NULL,
		P_ATTRIBUTE7          =>         NULL,
		P_ATTRIBUTE8          =>         NULL,
		P_ATTRIBUTE9          =>         NULL,
		P_ATTRIBUTE10         =>         NULL,
		P_CREATED_BY          =>         p_user_id,
		P_CREATION_DATE       =>         SYSDATE,
		P_LAST_UPDATED_BY     =>         p_user_id,
		P_LAST_UPDATE_LOGIN   =>         NULL,
		P_LAST_UPDATE_DATE    =>         SYSDATE,
		X_RETURN_STATUS       =>         x_return_status,
		X_MSG_DATA            =>         x_msg_data);

         IF (x_return_status = FND_API.G_RET_STS_ERROR)
         THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('EDR Upload failed with expected error.');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
         THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('EDR Upload failed with unexpected error.');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         IF (c_check_document_edr%ISOPEN) THEN
            CLOSE c_check_document_edr;
         END IF;
         IF (c_check_document_fnd%ISOPEN) THEN
            CLOSE c_check_document_fnd;
         END IF;
         -- Since document is uploaded correctly get document_id
         OPEN c_get_doc_id;
         FETCH c_get_doc_id INTO l_document_id;

         --If it's not in the system, error out.
         IF c_get_doc_id%NOTFOUND THEN
            CLOSE c_get_doc_id;
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
    	       log_msg('EDR Upload successful but doc id could not be fetched.');
            END IF;
            RAISE FILE_ERROR;
         END IF;
         CLOSE c_get_doc_id;

      END IF; /* c_check_document%NOTFOUND THEN */
   END IF; /*p_document_id is NOT NULL */

   --Check the date sent
   IF p_date_sent IS NULL OR p_date_sent > SYSDATE THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('Date Sent provided : Date Sent validation failed.');
      END IF;
      RAISE INVALID_DATE_SENT;
   END IF;

   --Check the creation source
   IF p_creation_source NOT IN (0,1,2) THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('Creation Source provided : Creation Source validation failed.');
      END IF;
      RAISE INVALID_CREATION_SOURCE;
   END IF;

   --Validate the recipient_id
   IF NOT (GR_VALIDATE.validate_recipient_id(p_recipient_id)) THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('Recipient ID provided - Recipient ID validation failed.');
      END IF;
      RAISE INVALID_RECIPIENT_ID;
   END IF;

   --Validate the recipient_site_id
   IF NOT (GR_VALIDATE.validate_recipient_site_id(p_recipient_id,p_recipient_site_id)) THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('Recipient Site ID provided - Recipient Site ID validation failed.');
      END IF;
      RAISE INVALID_RECIPIENT_SITE_ID;
   END IF;

   --Validate the dispatch_method
   IF NOT (GR_VALIDATE.validate_dispatch_method_code(p_dispatch_method_code)) THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('Dispatch Method provided - Dispatch Method validation failed.');
      END IF;
      RAISE INVALID_DISPATCH_METHOD_CODE;
   END IF;

   --Validate the user id
   OPEN c_val_user_id;
   FETCH c_val_user_id  INTO l_temp;

   --If user id not found
   IF c_val_user_id%NOTFOUND THEN
      CLOSE c_val_user_id;
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('User ID provided - User ID validation failed.');
      END IF;
      RAISE INVALID_USER_ID;
   END IF;

   CLOSE c_val_user_id;

   --Retrieve new dispatch history id
   OPEN c_get_dispatch_history_id;
   FETCH c_get_dispatch_history_id INTO l_dispatch_history_id;
   CLOSE c_get_dispatch_history_id;


          INSERT INTO GR_DISPATCH_HISTORY (
               dispatch_history_id	 ,
               document_id		 ,
               item                      ,
               organization_id	         ,
               inventory_item_id	 ,
               recipient_id              ,
               recipient_site_id         ,
               date_sent                 ,
               dispatch_method_code      ,
               creation_source	         ,
               attribute_category        ,
               attribute1                ,
               attribute2                ,
               attribute3                ,
               attribute4                ,
               attribute5                ,
               attribute6                ,
               attribute7                ,
               attribute8                ,
               attribute9                ,
               attribute10               ,
               attribute11               ,
               attribute12               ,
               attribute13               ,
               attribute14               ,
               attribute15               ,
               attribute16               ,
               attribute17               ,
               attribute18               ,
               attribute19               ,
               attribute20               ,
               attribute21               ,
               attribute22               ,
               attribute23               ,
               attribute24               ,
               attribute25               ,
               attribute26               ,
               attribute27               ,
               attribute28               ,
               attribute29               ,
               attribute30               ,
               created_by	         ,
               creation_date	         ,
               last_updated_by           ,
               last_update_date          ,
               last_update_login
             ) VALUES (
                l_dispatch_history_id	 ,
                l_document_id		 ,
                l_item                   ,
                p_organization_id	 ,
                l_inventory_item_id	 ,
                p_recipient_id           ,
                p_recipient_site_id      ,
                p_date_sent              ,
                p_dispatch_method_code   ,
                p_creation_source	 ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
                NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		NULL       ,
		p_user_id  ,
		sysdate ,
		p_user_id,
		sysdate,
		-1);

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION

        WHEN INVALID_VALUE THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_USER_ID THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_USER_ID');
          FND_MESSAGE.SET_TOKEN('USER_ID', p_user_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DOCUMENT_ID THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DOCUMENT_ID');
          FND_MESSAGE.SET_TOKEN('DOCUMENT_ID', p_document_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DOCUMENT_CATEGORY THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DOCUMENT_CATEGORY');
          FND_MESSAGE.SET_TOKEN('DOC_CATEGORY', p_document_category);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DISPATCH_METHOD_CODE THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DISPATCH_METHOD');
          FND_MESSAGE.SET_TOKEN('DISPATCH_METHOD_CODE', p_dispatch_method_code);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DISCLOSURE_CODE THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DISCLOSURE_CODE');
          FND_MESSAGE.SET_TOKEN('CODE', p_disclosure_code);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DOCUMENT_LANGUAGE THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_LANGUAGE');
          FND_MESSAGE.SET_TOKEN('LANGUAGE', p_language);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DOCUMENT_VERSION THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DOC_VERSION');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_DATE_SENT THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DATE_SENT');
          FND_MESSAGE.SET_TOKEN('DATE_SENT', p_date_sent);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_CREATION_SOURCE THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_CREATION_SOURCE');
          FND_MESSAGE.SET_TOKEN('CREATION_SOURCE', p_creation_source);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_RECIPIENT_ID THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_RECIPIENT_ID');
          FND_MESSAGE.SET_TOKEN('RECIPIENT_ID', p_recipient_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN INVALID_RECIPIENT_SITE_ID THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_RECIPIENT_SITE_ID');
          FND_MESSAGE.SET_TOKEN('RECIPIENT_SITE_ID', p_recipient_site_id);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );
        WHEN FILE_ERROR THEN
          FND_MESSAGE.SET_NAME('GR', 'GR_FILE_ERROR');
          FND_MESSAGE.SET_TOKEN('FILE', p_document_location||'/'||p_document_name);
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get (
                          p_count => x_msg_count,
                          p_data  => x_msg_data   );

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count,
                                         p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_AND_GET (  p_count => x_msg_count,
                                         p_data  => x_msg_data);

        WHEN OTHERS THEN
          fnd_msg_pub.add_exc_msg (G_PKG_NAME, l_api_name, SQLERRM);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get (    p_count => x_msg_count,
                          	         p_data  => x_msg_data   );

END CREATE_DISPATCH_HISTORY_REC;

--------------------------------------------------------------------------------
--Start of Comments
--Name: GET_CAS_NO
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure returns the CAS number for a given item.
--Parameters:
--IN:
-- Version of API to validate compatibility
--p_item                      IN      		ITEM NUMBER,
-- Initialize message  stack  (TRUE or FALSE)

--OUT:
--p_cas_no CAS Number of the item

--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE GET_CAS_NO(p_item IN varchar2,
                     p_organization_id IN NUMBER,
                     p_cas_no OUT NOCOPY  varchar2)
IS
BEGIN
  select NVL(CAS_Number,' ')
  into P_CAS_NO
  from mtl_system_items_kfv
  WHERE concatenated_segments = p_item
  AND   organization_id = p_organization_id ;

  EXCEPTION
     WHEN OTHERS THEN
        p_cas_no := NULL;

end;

--------------------------------------------------------------------------------
--Start of Comments
--Name: log_msg
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is used for common logging.
--Parameters:
--IN:
-- Version of API to validate compatibility
--p_msg_text                      IN      		VARCHAR2
-- Initialize message  stack  (TRUE or FALSE)

--OUT:
--None

--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GR','GR_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;


--------------------------------------------------------------------------------
--Start of Comments
--Name: ger_organization_code
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is used to get organization Code
--Parameters:
--IN:
-- Orgn_id    -   Organization Id

--OUT:
-- Orgn_code  -  Organization Code

--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE GET_ORGANIZATION_CODE(   p_orgn_id IN NUMBER,
                         p_orgn_code OUT NOCOPY VARCHAR2)
IS
BEGIN
      select NVL(ORGANIZATION_CODE,' ') into p_orgn_code
        from MTL_PARAMETERS
        where ORGANIZATION_ID =  p_orgn_id;
    EXCEPTION
     WHEN OTHERS THEN
        p_orgn_code := NULL;
END;


--------------------------------------------------------------------------------
--Start of Comments
--Name: ger_item_desc
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is used to get organization Code
--Parameters:
--IN:
-- Orgn_id    -   Organization Id
-- Item_id    -   Item Id

--OUT:
-- Orgn_code  -  Organization Code

--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE GET_ITEM_DESC( P_item_id IN NUMBER,
                         p_orgn_id IN NUMBER,
                         p_item_desc OUT NOCOPY VARCHAR2)
IS
BEGIN
      select NVL(DESCRIPTION,' ') into p_item_desc
        from MTL_SYSTEM_ITEMS
        where INVENTORY_ITEM_ID = p_item_id
        and   ORGANIZATION_ID = p_orgn_id;
    EXCEPTION
     WHEN OTHERS THEN
        p_item_desc := NULL;
END;

END GR_DISPATCH_HISTORY_PVT; -- Package body

/
