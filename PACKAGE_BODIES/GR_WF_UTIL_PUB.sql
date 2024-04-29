--------------------------------------------------------
--  DDL for Package Body GR_WF_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_WF_UTIL_PUB" AS
/*  $Header: GRWFUPBB.pls 120.8 2007/12/13 21:25:26 plowe ship $    */
/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_ITEM_CHNG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Item Properties change for a regulatory item. And it will be called from the
--    trigger on Item properties table.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_user_id       IN  NUMBER            - User Id
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_ITEM_CHNG(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE INITIATE_PROCESS_ITEM_CHNG
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_orgn_id                  IN	           NUMBER,
	 p_item_id                  IN	           NUMBER,
	 p_user_id                  IN             NUMBER,
	 x_return_status           OUT 	NOCOPY     VARCHAR2,
	 x_error_code              OUT 	NOCOPY     NUMBER,
	 x_msg_data                OUT 	NOCOPY     VARCHAR2
	) IS
        /************* Local Variables *************/
        -- Bug 4510201 Start
	--l_item_no           IC_ITEM_MST_B.item_no%TYPE;
        --l_item_desc         IC_ITEM_MST_B.item_desc1%TYPE;
	l_item_no           mtl_system_items_kfv.CONCATENATED_SEGMENTS%TYPE;
        l_item_desc         mtl_system_items_kfv.DESCRIPTION%TYPE;
        -- Bug 4510201 End
        l_item_code         GR_ITEM_GENERAL.item_code%TYPE;
        l_code_block        VARCHAR2(2000);
        l_return_status     VARCHAR2(1);
        l_msg_data          VARCHAR2(2000);
        l_commit            VARCHAR2(1);
        l_opm_version       FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
        l_api_name          CONSTANT VARCHAR2(80)  := 'GR Workflow Utilities Public API';
        l_error_code        NUMBER;
        l_api_version       CONSTANT NUMBER := 1.0;
        l_doc_rbld_req      VARCHAR2(80);

        /******* Exceptions ********/
        INCOMPATIBLE_API_VERSION_ERROR EXCEPTION;
        ITEM_ID_IS_NULL                EXCEPTION;
        ORGN_ID_IS_NULL                EXCEPTION;
      BEGIN

         l_commit      := 'F';
         /************* Initialize the message list if true *************/
         IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
         END IF;

         /************* Check the API version passed in matches the internal API version. *************/

         IF NOT FND_API.Compatible_API_Call
 					 (l_api_version,
					  p_api_version,
					  l_api_name,
					  g_pkg_name)
         THEN
            RAISE Incompatible_API_Version_Error;
         END IF;

         /************* Set return status to successful *************/
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         /************* Check for Parameter Organization Id *************/

         IF p_orgn_id is NULL THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             gr_wf_util_pvt.log_msg(g_pkg_name || ' : Organization provided is null - failed to initate the Document Rebuild Workflow.');
           END IF;
           RAISE ORGN_ID_IS_NULL;
  	     END IF;

         /************* Check for Parameter Item Id *************/

         IF p_item_id is NULL THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             gr_wf_util_pvt.log_msg(g_pkg_name || ' : Item provided is null - failed to initate the Document Rebuild Workflow.');
           END IF;
           RAISE ITEM_ID_IS_NULL;
  	     END IF;

         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            gr_wf_util_pvt.log_msg(g_pkg_name || ' : Check for the GR_DOC_UPD_REQ_WF_ENABLE Profile defined.');
         END IF;
         /************* Check for Profiles *************/
         IF (FND_PROFILE.DEFINED('GR_DOC_UPD_REQ_WF_ENABLED')) THEN

            l_doc_rbld_req    := FND_PROFILE.Value('GR_DOC_UPD_REQ_WF_ENABLED');

            /************* If the Workflow Profile is Enabled *************/
            IF (l_doc_rbld_req = 'E') THEN
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is enabled and get thee Item details for the Item ID : ' || p_item_id);
               END IF;
               /************* Get the Item Details *************/
               Gr_Wf_Util_PVT.Get_Item_Details(p_orgn_id, p_item_id, l_item_no, l_item_desc);
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Details for the Organization ID : ' || p_orgn_id || ' Item ID : ' || p_item_id || ' Item Number : ' || l_item_no || ' Item Description : ' || l_item_desc);
               END IF;
               IF  l_item_no IS NOT NULL THEN
                   /************* Initiate the Document Rebuild Required Workflow *************/
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Regulatory Item found. ');
                   END IF;
                   Gr_Wf_Util_PVT.WF_INIT (p_orgn_id, p_item_id, l_item_no, l_item_desc, NULL, NULL, p_user_id);
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiate the workflow for Item Change. ');
                   END IF;
               ELSE
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiation of the workflow failed as the Item is not a Regulatory Item.');
                   END IF;
               END IF;
            ELSE
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is disabled, therefore the initiation of the workflow failed.');
               END IF;
            END IF;
         ELSE
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is Undefined.');
            END IF;
         END IF;
	     /************* Initialize commit flag only if true *************/
	     IF FND_API.To_Boolean(p_commit) THEN
	        COMMIT WORK;
	     END IF;
	     x_return_status := 'S';
	EXCEPTION
    WHEN INCOMPATIBLE_API_VERSION_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_API_VERSION_ERROR');
	  FND_MESSAGE.SET_TOKEN('VERSION',
	                        p_api_version,
							FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'API version error');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN ITEM_ID_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ITEM_ID_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_item_id,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Item Id is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN OTHERS THEN
	  x_return_status := 'U';
	  x_error_code := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      x_msg_data := FND_MESSAGE.Get;

END INITIATE_PROCESS_ITEM_CHNG;

/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_FORMULA_CHNG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Formula change for a regulatory item. And it will be called from the
--    trigger from a Formula API.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_formula_no    IN  VARCHAR2          - Formula No of product
--    p_formula_vers  IN  NUMBER            - Formula Vers of product
--    p_user_id       IN  NUMBER            - User Id
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_FORMULA_CHNG(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,l_formula_id,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */
	PROCEDURE INITIATE_PROCESS_FORMULA_CHNG
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_orgn_id                  IN	           NUMBER,
	 p_item_id                  IN	           NUMBER,
	 p_formula_no               IN	           VARCHAR2,
	 p_formula_vers             IN	           NUMBER,
	 p_user_id                  IN             NUMBER,
	 x_return_status           OUT 	NOCOPY VARCHAR2,
	 x_error_code              OUT 	NOCOPY NUMBER,
	 x_msg_data                OUT 	NOCOPY VARCHAR2
	) IS
        /************* Local Variables *************/
               -- Bug 4510201 Start
	--l_item_no           IC_ITEM_MST_B.item_no%TYPE;
        --l_item_desc         IC_ITEM_MST_B.item_desc1%TYPE;
	l_item_no           mtl_system_items_kfv.CONCATENATED_SEGMENTS%TYPE;
        l_item_desc         mtl_system_items_kfv.DESCRIPTION%TYPE;
        -- Bug 4510201 End
        l_formula_no        FM_FORM_MST_B.formula_no%TYPE;
        l_formula_vers      FM_FORM_MST_B.formula_vers%TYPE;
        l_item_code         GR_ITEM_GENERAL.item_code%TYPE;
        l_code_block		VARCHAR2(2000);
        l_return_status     VARCHAR2(1);
        l_msg_data          VARCHAR2(2000);
        l_commit            VARCHAR2(1);
        l_opm_version       FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
        l_api_name          CONSTANT VARCHAR2(80)  := 'GR Workflow Utilities Public API';
        l_error_code        NUMBER;
        l_api_version       CONSTANT NUMBER := 1.0;
        l_doc_rbld_req      VARCHAR2(80);

        /******* Exceptions ********/
        INCOMPATIBLE_API_VERSION_ERROR EXCEPTION;
        ITEM_ID_IS_NULL                EXCEPTION;
        FORMULA_ID_IS_NULL             EXCEPTION;
        ORGN_ID_IS_NULL                EXCEPTION;
      BEGIN

        l_code_block := 'Initialize';
        l_commit      := 'F';

         /************* Initialize the message list if true *************/
         IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
         END IF;

         /************* Check the API version passed in matches the internal API version. *************/

         IF NOT FND_API.Compatible_API_Call
 					 (l_api_version,
					  p_api_version,
					  l_api_name,
					  g_pkg_name)
         THEN
            RAISE Incompatible_API_Version_Error;
         END IF;

         /************* Set return status to successful *************/
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         /************* Check for Parameter Organization Id *************/

         IF p_orgn_id is NULL THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             gr_wf_util_pvt.log_msg(g_pkg_name || ' : Organization provided is null - failed to initate the Document Rebuild Workflow.');
           END IF;
           RAISE ORGN_ID_IS_NULL;
  	     END IF;


         /************* Check for Parameter Item Id *************/

         IF p_item_id is NULL THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Item ID provided is null - failed to initate the Document Rebuild Workflow.');
            END IF;
		    RAISE ITEM_ID_IS_NULL;
		 END IF;

         /************* Check for Parameter Formula Id but not for for Validity rules (formula vers passed as -1 )*************/

         IF p_formula_vers <> -1 and p_formula_no is NULL AND p_formula_vers is NULL THEN -- bug 6193989 added check for -1
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             gr_wf_util_pvt.log_msg(g_pkg_name || ' : Formula No provided is null - failed to initate the Document Rebuild Workflow.');
           END IF;
	   RAISE FORMULA_ID_IS_NULL;
	 END IF;


         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            gr_wf_util_pvt.log_msg(g_pkg_name || ' : Check for the GR_DOC_UPD_REQ_WF_ENABLE Profile defined.');
         END IF;
         /************* Check for Profiles *************/
         IF (FND_PROFILE.DEFINED('GR_DOC_UPD_REQ_WF_ENABLED')) THEN

            l_doc_rbld_req    := FND_PROFILE.Value('GR_DOC_UPD_REQ_WF_ENABLED');

            /************* If the Workflow Profile is Enabled *************/
            IF (l_doc_rbld_req = 'E') THEN
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is enabled and get thee Item details for the Item ID : ' || p_item_id);
               END IF;
               /************* Get the Item Details *************/
               Gr_Wf_Util_PVT.Get_Item_Details(p_orgn_id, p_item_id, l_item_no, l_item_desc);
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                  gr_wf_util_pvt.log_msg(g_pkg_name || ' : Details for the Organization ID : ' || p_orgn_id || ' Item ID : ' || p_item_id || ' Item Number : ' || l_item_no || ' Item Description : ' || l_item_desc);
               END IF;
               /************* Get the Formula Details ************
               Gr_Wf_Util_PVT.Get_formula_Details(p_formula_id, l_formula_no, l_formula_vers);
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Details for the Formula ID : ' || p_formula_id || ' Formula Number : ' || l_formula_no || ' Formula Version : ' || l_formula_vers);
               END IF; */
               IF  l_item_no IS NOT NULL THEN
                   /************* Initiate the Document Rebuild Required Workflow *************/
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Regulatory Item found. ');
                   END IF;
                   Gr_Wf_Util_PVT.WF_INIT (p_orgn_id, p_item_id, l_item_no, l_item_desc, p_formula_no, p_formula_vers, p_user_id);
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiate the workflow for Formula Change. ');
                   END IF;
               ELSE
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiation of the workflow failed as the Item is not a Regulatory Item.');
                   END IF;
               END IF;
            ELSE
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is disabled, therefore the initiation of the workflow failed.');
               END IF;
            END IF;
         ELSE
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is Undefined.');
            END IF;
         END IF;

	     /************* Initialize commit flag only if true *************/
	     IF FND_API.To_Boolean(p_commit) THEN
	        COMMIT WORK;
	     END IF;
	     x_return_status := 'S';
	EXCEPTION
    WHEN INCOMPATIBLE_API_VERSION_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_API_VERSION_ERROR');
	  FND_MESSAGE.SET_TOKEN('VERSION',
	                        p_api_version,
							FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'API version error');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN ITEM_ID_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ITEM_ID_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_item_id,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Item Id is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN FORMULA_ID_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_FORMULA_ID_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_formula_no,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Formula Id is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN OTHERS THEN
	  x_return_status := 'U';
	  x_error_code := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      x_msg_data := FND_MESSAGE.Get;

END INITIATE_PROCESS_FORMULA_CHNG;

/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_SALES_ORDER
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Sales Order change for a hazardrous regulatory item. And it will be called from the
--    trigger from GMI Move Orders API.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_sales_order_org_id  IN NUMBER       - Organization Id (OU) for the Sales Order
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_sales_order_noIN  VARCHAR2          - Sales Order Number of an Item
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_SALES_ORDER(l_api_version,l_init_msg_list,l_commit, l_sales_order_org_id, l_orgn_id
--                               l_item_id,l_sales_order_no,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--    Peter Lowe     13-Dec-2007  Bug 6689912 added p_sales_order_org_id parameter
--
--=========================================================================== */

	PROCEDURE INITIATE_PROCESS_SALES_ORDER
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_sales_order_org_id       IN             NUMBER,   -- 6689912
	 p_orgn_id                  IN	           NUMBER,
	 p_item_id                  IN	           NUMBER,
	 p_sales_order_no           IN	           VARCHAR2,
	 x_return_status           OUT 	NOCOPY VARCHAR2,
	 x_error_code              OUT 	NOCOPY NUMBER,
	 x_msg_data                OUT 	NOCOPY VARCHAR2
	) IS
        /************* Local Variables *************/
       -- Bug 4510201 Start
	--l_item_no           IC_ITEM_MST_B.item_no%TYPE;
        --l_item_desc         IC_ITEM_MST_B.item_desc1%TYPE;
	l_item_no           mtl_system_items_kfv.CONCATENATED_SEGMENTS%TYPE;
        l_item_desc         mtl_system_items_kfv.DESCRIPTION%TYPE;
        -- Bug 4510201 End
        l_item_code         GR_ITEM_GENERAL.item_code%TYPE;
        l_code_block		VARCHAR2(2000);
        l_return_status     VARCHAR2(1);
        l_msg_data          VARCHAR2(2000);
        l_commit            VARCHAR2(1);
        l_opm_version       FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
        l_api_name          CONSTANT VARCHAR2(80)  := 'GR Workflow Utilities Public API';
        l_error_code        NUMBER;
        l_api_version       CONSTANT NUMBER := 1.0;
        l_so_chk_hzrd       VARCHAR2(80);

        /******* Exceptions ********/
        INCOMPATIBLE_API_VERSION_ERROR EXCEPTION;
        ITEM_ID_IS_NULL                EXCEPTION;
        SO_NUMBER_IS_NULL              EXCEPTION;
        ORGN_ID_IS_NULL                EXCEPTION;

      BEGIN

         l_code_block := 'Initialize';
         l_commit     := 'F';

         /************* Initialize the message list if true *************/
         IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
         END IF;

         /************* Check the API version passed in matches the internal API version. *************/

         IF NOT FND_API.Compatible_API_Call
 					 (l_api_version,
					  p_api_version,
					  l_api_name,
					  g_pkg_name)
         THEN
            RAISE Incompatible_API_Version_Error;
         END IF;

         /************* Set return status to successful *************/
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         /************* Check for Parameter Organization Id *************/

         IF p_orgn_id is NULL THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             gr_wf_util_pvt.log_msg(g_pkg_name || ' : Organization provided is null - failed to initate the Document Rebuild Workflow.');
           END IF;
           RAISE ORGN_ID_IS_NULL;
  	     END IF;

         /************* Check for Parameter Item Id *************/

         IF p_item_id is NULL THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Item ID provided is null - failed to initate the Document Rebuild Workflow.');
            END IF;
		    RAISE ITEM_ID_IS_NULL;
		 END IF;

         /************* Check for Parameter Formula Id *************/

         IF p_sales_order_no is NULL THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Sales Order Number provided is null - failed to initate the Document Rebuild Workflow.');
            END IF;
		    RAISE SO_NUMBER_IS_NULL;
		 END IF;

         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            gr_wf_util_pvt.log_msg(g_pkg_name || ' : Check for the GR_SO_CHECK_FOR_HAZARDS Profile defined.');
         END IF;

         /************* Check for Profiles *************/
         IF (FND_PROFILE.DEFINED('GR_SO_CHECK_FOR_HAZARDS')) THEN
               l_so_chk_hzrd    := FND_PROFILE.Value('GR_SO_CHECK_FOR_HAZARDS');

            /************* If the Workflow Profile is Enabled *************/
            IF (l_so_chk_hzrd = 'Y') THEN
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_SO_CHECK_FOR_HAZARDS is set to Yes and get the Item details for the Item ID : ' || p_item_id);
               END IF;

               /************* Get the Item Details *************/
               Gr_Wf_Util_PVT.Get_Item_Details(p_orgn_id, p_item_id, l_item_no, l_item_desc);
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Details for the
                 Organization ID : ' || p_orgn_id ||
                 ' Item ID : ' || p_item_id || ' Item Number : ' || l_item_no ||
                 ' Item Description : ' ||l_item_desc ||' Sales Order Number : '
                 || p_sales_order_no);
               END IF;

               IF l_item_no IS NOT NULL  THEN
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Sales Order is created for a Regulatory Item. ');
                   END IF;
                   /************* Initiate the XML Outbound Message  *************/
                   Gr_Wf_Util_PVT.SEND_OUTBOUND_DOCUMENT ('GR', 'GRIOO', p_sales_order_no,p_sales_order_org_id); -- 6689912
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiated the Outbound for Sales Order. ');
                   END IF;
               ELSE
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiation of the Outbound Message failed as the Sales Order Line Item is not a Regulatory Item.');
                   END IF;
               END IF;
            ELSE
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_SO_CHECK_FOR_HAZARDS is disabled, therefore the initiation of the Outbound Message failed.');
               END IF;
            END IF;
         ELSE
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_SO_CHECK_FOR_HAZARDS is Undefined.');
            END IF;
         END IF;

	     /************* Initialize commit flag only if true *************/
	     IF FND_API.To_Boolean(p_commit) THEN
	        COMMIT WORK;
	     END IF;
	     x_return_status := 'S';
	EXCEPTION
    WHEN INCOMPATIBLE_API_VERSION_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_API_VERSION_ERROR');
	  FND_MESSAGE.SET_TOKEN('VERSION',
	                        p_api_version,
							FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'API version error');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN ITEM_ID_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ITEM_ID_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_item_id,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Item Id is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN SO_NUMBER_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_SO_NUMBER_IS_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_sales_order_no,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Sales Order Number is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN OTHERS THEN
	  x_return_status := 'U';
	  x_error_code := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      x_msg_data := FND_MESSAGE.Get;

END INITIATE_PROCESS_SALES_ORDER;

/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_TECH_CHNG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Technical Parameters change for a regulatory item. And it will be called from the
--    trigger on Item Technical Data Header table.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_tech_data_id  IN  NUMBER            - Technical Data_Id of product
--    p_user_id       IN  NUMBER            - User Id
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_TECH_CHNG(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,l_tech_data_id,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE INITIATE_PROCESS_TECH_CHNG
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_orgn_id                  IN	           NUMBER,
	 p_tech_data_id             IN	           NUMBER,
	 p_tech_parm_id             IN             NUMBER,
	 p_user_id                  IN             NUMBER,
	 x_return_status           OUT 	NOCOPY VARCHAR2,
	 x_error_code              OUT 	NOCOPY NUMBER,
	 x_msg_data                OUT 	NOCOPY VARCHAR2
	) IS
        /************* Local Variables *************/
       -- Bug 4510201 Start
	--l_item_no           IC_ITEM_MST_B.item_no%TYPE;
        --l_item_desc         IC_ITEM_MST_B.item_desc1%TYPE;
        l_item_id           GMD_TECHNICAL_DATA_HDR.item_id%TYPE;
	l_item_no           mtl_system_items_kfv.CONCATENATED_SEGMENTS%TYPE;
        l_item_desc         mtl_system_items_kfv.DESCRIPTION%TYPE;
        -- Bug 4510201 End
        l_item_code         GR_ITEM_GENERAL.item_code%TYPE;
        l_code_block		VARCHAR2(2000);
        l_return_status     VARCHAR2(1);
        l_msg_data          VARCHAR2(2000);
        l_commit            VARCHAR2(1);
        l_opm_version       FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
        l_api_name          CONSTANT VARCHAR2(80)  := 'GR Workflow Utilities Public API';
        l_error_code        NUMBER;
        l_api_version       CONSTANT NUMBER := 1.0;
        l_doc_rbld_req      VARCHAR2(80);

        CURSOR get_tech_parm_details IS
        select a.TECH_PARM_NAME
        from gmd_tech_parameters_b a
        where a.tech_parm_id = p_tech_parm_id;

        CURSOR get_item_details (V_tech_data_id NUMBER) IS
        select a.inventory_item_id --Bug# 5363620 use inventory_item_id instead of item_id
        from gmd_technical_data_hdr a
        where a.tech_data_id = V_tech_data_id;

        /******* Exceptions ********/
        INCOMPATIBLE_API_VERSION_ERROR EXCEPTION;
        ITEM_ID_IS_NULL                EXCEPTION;
        TECH_DATA_ID_IS_NULL           EXCEPTION;
        ORGN_ID_IS_NULL                EXCEPTION;

      BEGIN

         l_code_block := 'Initialize';

         /************* Initialize the message list if true *************/
         IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
         END IF;

         /************* Check the API version passed in matches the internal API version. *************/

         IF NOT FND_API.Compatible_API_Call
 					 (l_api_version,
					  p_api_version,
					  l_api_name,
					  g_pkg_name)
         THEN
            RAISE Incompatible_API_Version_Error;
         END IF;

         /************* Set return status to successful *************/
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         /************* Check for Parameter Organization Id *************/

         IF p_orgn_id is NULL THEN
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             gr_wf_util_pvt.log_msg(g_pkg_name || ' : Organization provided is null - failed to initate the Document Rebuild Workflow.');
           END IF;
           RAISE ORGN_ID_IS_NULL;
  	     END IF;

         /************* Check for Parameter Item Id *************/

         IF p_tech_parm_id is NULL THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Tech Data ID provided is null - failed to initate the Document Rebuild Workflow.');
            END IF;
		    RAISE ITEM_ID_IS_NULL;
		 END IF;

         /************* Check for Parameter Tech Data Id *************/

         IF p_tech_data_id is NULL THEN
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Technical Data ID provided is null - failed to initate the Document Rebuild Workflow.');
            END IF;
		    RAISE TECH_DATA_ID_IS_NULL;
		 END IF;

         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            gr_wf_util_pvt.log_msg(g_pkg_name || ' : Check for the GR_DOC_UPD_REQ_WF_ENABLE Profile defined.');
         END IF;
         /************* Check for Profiles *************/
         IF (FND_PROFILE.DEFINED('GR_DOC_UPD_REQ_WF_ENABLED')) THEN

            l_doc_rbld_req    := FND_PROFILE.Value('GR_DOC_UPD_REQ_WF_ENABLED');

            /************* If the Workflow Profile is Enabled *************/
            IF (l_doc_rbld_req = 'E') THEN

               OPEN get_item_details(p_tech_data_id);
               FETCH get_item_details INTO l_item_id;
               CLOSE get_item_details;
               IF l_item_id IS NULL THEN
                  RAISE ITEM_ID_IS_NULL;
               END IF;

               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is enabled and get the Item details for the Item ID : '|| l_item_id);
               END IF;

               FOR c1 in get_tech_parm_details LOOP
                   /************* Get the Item Details *************/
                   Gr_Wf_Util_PVT.Get_Item_Details(p_orgn_id, l_item_id, l_item_no, l_item_desc);
                   IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                     gr_wf_util_pvt.log_msg(g_pkg_name || ' : Details for the
                     Organization ID : ' || p_orgn_id || ' Item ID : ' ||
                     l_item_id || ' Item Number : ' || l_item_no ||
                     ' Item Description : ' || l_item_desc || 'Technical
                     Parameter : ' || c1.tech_parm_name);
                   END IF;
                   /************* Check for Technical Parameters and Regulatory Item *************/
                   IF  Gr_Wf_Util_PVT.CHECK_FOR_TECH_PARAM (c1.tech_parm_name)  AND
                       l_item_no IS NOT NULL THEN
                       /************* Initiate the Document Rebuild Required Workflow *************/
                       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                         gr_wf_util_pvt.log_msg(g_pkg_name || ' : Technical Parameter ' || c1.tech_parm_name || ' is defined for this Item ' || l_item_no);
                       END IF;
                       /************* Initiate the Workflow *************/
                       Gr_Wf_Util_PVT.WF_INIT (p_orgn_id, l_item_id, l_item_no, l_item_desc, NULL, NULL, p_user_id);
                       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                         gr_wf_util_pvt.log_msg(g_pkg_name || ' : Initiate the workflow for Formula Change. ');
                       END IF;
               ELSE
                  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                    gr_wf_util_pvt.log_msg(g_pkg_name || ' : Technical Parameter ' || c1.tech_parm_name || ' is not defined for this Item ' || l_item_no);
                  END IF;
               END IF;
               END LOOP;
               CLOSE get_tech_parm_details;
            ELSE
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is disabled, therefore the initiation of the workflow failed.');
               END IF;
            END IF;
         ELSE
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
              gr_wf_util_pvt.log_msg(g_pkg_name || ' : Profile GR_DOC_UPD_REQ_WF_ENABLE is Undefined.');
            END IF;
         END IF;

	     /************* Initialize commit flag only if true *************/
	     IF FND_API.To_Boolean(p_commit) THEN
	        COMMIT WORK;
	     END IF;
	     x_return_status := 'S';
	EXCEPTION
    WHEN INCOMPATIBLE_API_VERSION_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_API_VERSION_ERROR');
	  FND_MESSAGE.SET_TOKEN('VERSION',
	                        p_api_version,
							FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'API version error');
	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN ITEM_ID_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ITEM_ID_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_tech_data_id,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Item Id is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN TECH_DATA_ID_IS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
 	  x_error_code := APP_EXCEPTION.Get_Code;

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_TECH_DATA_ID_NULL');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_tech_data_id,
            			    FALSE);
      X_msg_data := FND_MESSAGE.GET;
      FND_FILE.PUT(FND_FILE.LOG,'Technical Data Id is null');
  	  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
    WHEN OTHERS THEN
	  x_return_status := 'U';
	  x_error_code := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
          x_msg_data := FND_MESSAGE.Get;
END INITIATE_PROCESS_TECH_CHNG;

END GR_WF_UTIL_PUB;

/
