--------------------------------------------------------
--  DDL for Package Body PO_CONTERMS_UTL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CONTERMS_UTL_GRP" AS
/* $Header: POXGCTUB.pls 120.19.12010000.4 2014/03/13 10:41:45 jemishra ship $ */

-- Initialize debug variables
g_debug_stmt    CONSTANT    BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.' ;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_contracts_enabled
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function determines if Contracts is enabled or not.
--Parameters:
--  None
--Returns:
--  FND_API.G_TRUE if Procurement Contracts is enabled
--  FND_API.G_FALSE if Procurement Contracts is disabled.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_contracts_enabled RETURN VARCHAR2 IS

BEGIN

  -- read the global variable that stores the profile option.
  IF (g_contracts_enabled = 'Y') THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END is_contracts_enabled;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_contracts_enabled
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure determines if Contracts is enabled or not.
--Parameters:
--IN:
--p_init_msg_list
--  True/False parameter to initialize message list
--p_api_version
--  API version
--OUT:
--x_msg_count
--  Message count
--x_msg_data
--  message data
--x_return_status
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--x_contracts_enabled
--  FND_API.G_TRUE if Procurement Contracts is enabled
--  FND_API.G_FALSE if Procurement Contracts is disabled.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE is_contracts_enabled
            (p_api_version               IN NUMBER      --bug4028805
            ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
            ,x_return_status             OUT NOCOPY VARCHAR2
            ,x_msg_count                 OUT NOCOPY NUMBER
            ,x_msg_data                  OUT NOCOPY VARCHAR2
            ,x_contracts_enabled         OUT NOCOPY VARCHAR2) IS

  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'is_contracts_enabled';
  l_api_version CONSTANT NUMBER := 1.0; --bug 4028805

BEGIN

   IF NOT (FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize API return status to success
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- initialize meesage list
   IF (FND_API.to_Boolean(p_init_msg_list)) THEN
       FND_MSG_PUB.initialize;
   END IF;

   x_contracts_enabled := is_contracts_enabled;

EXCEPTION
     WHEN OTHERS THEN
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name
                         ,message   => SQLERRM);
           END IF;
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END is_contracts_enabled;


-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_PO_CONTRACT_DOCTYPE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the Contract document type to be used for a purchase order
--Parameters:
--IN:
--p_sub_doc_type
--  The sub document type of Purchase Order
--Returns:
--  Contract document type to be used with the call
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Po_Contract_Doctype(p_sub_doc_type IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
     IF (p_sub_doc_type = 'STANDARD') THEN
         RETURN 'PO_STANDARD';
     ELSIF (p_sub_doc_type = 'BLANKET') THEN
         RETURN 'PA_BLANKET';
     ELSIF (p_sub_doc_type = 'CONTRACT') THEN
         RETURN 'PA_CONTRACT';
     ELSE
         RETURN NULL;
     END IF;

END Get_Po_Contract_Doctype;



-------------------------------------------------------------------------------
--Start of Comments
--Name: get_external_userlist
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is built as a wrapper over procedure get_external_userlist
--  in the new group API po_vendors_grp.
--  This procedure is called by Contracts API to determine the supplier users
--  to send notifications to, when deliverables undergo a status change
--  (example: it is overdue).
--Parameters:
--IN:
--p_document_id
--  PO header ID
--p_document_type
--  Contracts business document type ex: PA_BLANKET or PO_STANDARD
--  This will be parsed to retrieve the PO document type
--p_external_contact_id
--  supplier contact ID on a contract deliverable. Default is NULL
--p_init_msg_list
--  True/False parameter to initialize message list
--p_api_version
--  API version
--OUT:
--x_msg_count
--  Message count
--x_msg_data
--  message data
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--x_supplier_userlist
--  PL/SQL table of supplier user names
--Notes:
--  SAHEGDE 07/18/2003
--  This procedure calls get_external_userlist in PO_VENDORS_GRP to
--  retrieve supplier user names as VARCHAR2 as well as PL/SQL table, besides
--  other OUT parameters. Going forward, signature of the get_external_userlist
--  might change to return only PL/SQL table. The callout then will need to
--  accomodate this change. This however will not change the GRP API signature.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER      --bug4028805
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_user_tbl         OUT NOCOPY external_user_tbl_type) IS


  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'get_external_userlist';
  l_api_version CONSTANT NUMBER := 1.0; --bug4028805
  l_document_type po_headers.type_lookup_code%TYPE;
  l_return_status VARCHAR2(1);
  l_external_user_tbl external_user_tbl_type;


BEGIN

   IF NOT (FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize API return status to success
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- initialize meesage list
   IF (FND_API.to_Boolean(p_init_msg_list)) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- parse the contracts document type to type lookup
   l_document_type := SUBSTR(p_document_type, 1, 2);


   po_vendors_grp.get_external_userlist
          (p_api_version               => 1.0  --bug4028805
          ,p_document_id               => p_document_id
          ,p_document_type             => l_document_type
          ,p_external_contact_id       => p_external_contact_id
          ,x_return_status             => l_return_status
          ,x_msg_count                 => x_msg_count
          ,x_msg_data                  => x_msg_data
          ,x_external_user_tbl         => l_external_user_tbl);


   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- populate the out parameter. Contracts need comma delimited list of users.
   x_external_user_tbl := l_external_user_tbl;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
   WHEN OTHERS THEN
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name
                         ,message   => SQLERRM);
           END IF;
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END get_external_userlist;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_external_userlist
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is built as a wrapper over procedure get_external_userlist
--  in the new group API po_vendors_grp.
--  This procedure is called by Contracts team to determine the supplier users
--  to send notifications to, when deliverables undergo a status change
--  (example: it is overdue) and supplier user is not specified on the deliverable.
--Parameters:
--IN:
--p_document_id
--  PO header ID
--p_document_type
--  Contracts business document type ex: PA_BLANKET or PO_STANDARD
--  This will be parsed to retrieve the PO document type
--p_external_contact_id
--  Supplier contact ID on the deliverable. Default is null.
--p_init_msg_list
--  True/False parameter to initialize message list
--p_api_version
--  API version
--OUT:
--x_msg_count
--  Message count
--x_msg_data
--  message data
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--x_supplier_userlist
--  Comma delimited list of supplier user names
--Notes:
--  This is an overloaded API to return the supplier names in a comma delimited
--  fashion.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER      --bug4028805
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_userlist         OUT NOCOPY VARCHAR2) IS


  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'get_external_userlist';
  l_api_version CONSTANT NUMBER := 1.0;
  l_document_type po_headers.type_lookup_code%TYPE;
  l_return_status VARCHAR2(1);
  l_external_userlist VARCHAR2(2000);
  l_external_userlist_for_sql VARCHAR2(2000);
  l_external_user_tbl external_user_tbl_type;
  l_num_users NUMBER;
  l_vendor_id NUMBER;



BEGIN

   IF NOT (FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize API return status to success
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- initialize meesage list
   IF (FND_API.to_Boolean(p_init_msg_list)) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- parse the contracts document type to type lookup
   l_document_type := SUBSTR(p_document_type, 1, 2);

   PO_VENDORS_GRP.get_external_userlist
          (p_api_version               => 1.0 --bug4028805
          ,p_init_msg_list             => FND_API.G_FALSE
          ,p_document_id               => p_document_id
          ,p_document_type             => l_document_type
          ,p_external_contact_id       => p_external_contact_id
          ,x_return_status             => l_return_status
          ,x_msg_count                 => x_msg_count
          ,x_msg_data                  => x_msg_data
          ,x_external_user_tbl         => l_external_user_tbl
          ,x_supplier_userlist         => l_external_userlist
          ,x_supplier_userlist_for_sql => l_external_userlist_for_sql
          ,x_num_users                 => l_num_users
          ,x_vendor_id                 => l_vendor_id);



   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- populate the out parameter. Contracts need comma delimited list of users.
   x_external_userlist := l_external_userlist;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
   WHEN OTHERS THEN
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name
                         ,message   => SQLERRM);
           END IF;
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END get_external_userlist;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_item_categorylist
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure returns a PL/SQl table of concatenated item category names for
--  all PO lines, except for those cancelled.
--  It also returns concatenated items in a PL/SQL table
--Parameters:
--IN:
--p_doc_type
--  OKC Document Type
--p_document_id
--  PO header ID
--p_init_msg_list
--  True/False parameter to initialize message list
--p_api_version
--  API version
--OUT:
--x_msg_count
--  Message count
--x_msg_data
--  message data
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--x_category_tbl
--  PL/SQL table of concatenated category names for lines used in the PO
--x_item_tbl
--  PL/SQL table of concatenated items for the lines used in the PO
--Notes:
--  SAHEGDE 07/17/2003
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_item_categorylist
          (p_api_version   IN  NUMBER
          ,p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
          ,p_doc_type      IN VARCHAR2 := NULL  -- CLM Mod project
          ,p_document_id   IN  NUMBER
          ,x_return_status OUT NOCOPY VARCHAR2
          ,x_msg_count     OUT NOCOPY NUMBER
          ,x_msg_data      OUT NOCOPY VARCHAR2
          ,x_category_tbl  OUT NOCOPY item_category_tbl_type
          ,x_item_tbl      OUT NOCOPY item_tbl_type) IS

  -- local variables
  l_api_name         CONSTANT VARCHAR2(30)  := 'get item categorylist';
  l_api_version      CONSTANT NUMBER   := 1.0;


  TYPE category_table_type IS TABLE OF
      mtl_categories_b_kfv.concatenated_segments%TYPE;

  TYPE item_table_type IS TABLE OF
      mtl_system_items_b_kfv.concatenated_segments%TYPE;

  l_category_tbl category_table_type;
  l_item_tbl item_table_type;

BEGIN

   IF NOT (FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize API return status to success
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- initialize meesage list
   IF (FND_API.to_Boolean(p_init_msg_list)) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- what: for the given document id, bulk collect item categories
   --       into the PL/SQL table
   -- why : Contracts needs to validate terms based on categories
   -- join: po_header_id, category_id
   SELECT  DISTINCT kfv.concatenated_segments
     BULK  COLLECT INTO l_category_tbl
     FROM  po_lines_all pol, mtl_categories_b_kfv kfv
     WHERE pol.category_id = kfv.category_id
     AND   pol.po_header_id = p_document_id
     AND   NVL(pol.cancel_flag,'N') ='N';

   -- return null when no data.
   IF SQL%NOTFOUND THEN
     NULL;
   END IF;

   -- what: for the given document id, bulk collect items
   --       into the PL/SQL table
   -- why : Contracts needs to validate terms based on items
   -- join: po_header_id, item_id
   SELECT  DISTINCT kfv.concatenated_segments
     BULK  COLLECT INTO l_item_tbl
     FROM  po_lines_all pol, mtl_system_items_b_kfv kfv
     WHERE pol.item_id = kfv.inventory_item_id
     AND   pol.po_header_id = p_document_id
     AND   NVL(pol.cancel_flag,'N') ='N';

   -- return null when no data.
   IF SQL%NOTFOUND THEN
     NULL;
   END IF;


   -- move the data into Contracts Table types.
   -- Bug 3293119, Oracle 8i bulk collect limitation
   x_category_tbl.delete();
   x_item_tbl.delete();

   IF (l_category_tbl.COUNT > 0) THEN
     FOR l_index in l_category_tbl.FIRST..l_category_tbl.LAST LOOP
       x_category_tbl(l_index).category_name := l_category_tbl(l_index);
     END LOOP;
   END IF;

   IF (l_item_tbl.COUNT > 0) THEN
     FOR l_index in l_item_tbl.FIRST..l_item_tbl.LAST loop
       x_item_tbl(l_index).name := l_item_tbl(l_index);
    end loop;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name
                         ,message   => SQLERRM);
           END IF;
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);

END get_item_categorylist;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Is_po_update_allowed
--Pre-reqs:
-- 1.DONOT Use this API from wherever Functional Security Check is needed. This API
--   Assumes that the org context is already set
-- 2.If the p_lock_flag is set to Y when this API is  called, the calling API is expected to commit or
--   rollback to release the lock
--Modifies:
-- None.
--Locks:
-- PO_headers_all if p_lock_flag parameter is set to Y
--Function:
-- This procedure is called by Contracts team to determine whether
-- the Purchase Order against which terms will be saved is in updatable
-- status or not. This API will compare the passed in status and version to
-- the current status and version of the PO and if it is same, it will do some extra checks and
-- Return the current status and version back to Contracts with the results.
--Parameters:
--IN:
--p_api_version
-- Standard Parameter. API version number expected by the caller
--p_init_msg_list
-- Standard parameter.Initialize message list
--p_doc_type
--  OKC Document Type
--p_header_id
-- PO header id
--p_callout_string
-- This string will contain concatenation of following parameters, delimited by comma
--                   : Status of the PO stored in Calling application
--                   : Revision Number of the PO stored in calling application
--                   : Employee id
-- Note that the above parameters should always be concatenated in the same order with no extra spaces around
-- Status and revision are always expected to be there. For Employee Id pass 'Null' if status is not 'IN PROCESS'
--p_lock_flag
-- tells whether po_headers_all be locked for the record
--OUT:
--x_update_allowed
-- Returns Y or N depending PO is in updatable status or not
--x_msg_count
-- Standard parameter.Message count
--x_msg_data
-- Standard parameter.message data
--x_return_status
-- Standard parameter. Status Returned to calling API. Possible values are following
-- FND_API.G_RET_STS_ERROR - for expected error
-- FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
-- FND_API.G_RET_STS_SUCCESS - for success
--Notes:
-- 07/11/2003 smhanda
-- 1. This API has been written specifically for integration with contracts wherein Contracts Changes
--    are treated as extension to PO Entry form changes of the PO. Before using it in any other place
--    Please diagnose the impact including security.
-- 2. Though the generic API for Document status check is called in this, right now it is not doing much
--    as the only extra check needed from there is for closed code or cancel flag which cannot be changed
--    If user is in PO updatable mode. Say the PO was requires reapproval when callout was made. Now to
--    set cancel flag on PO it must be in status Approved. In that case the first check itself in this
--    API - "Approved <> Requires Reapproval" will fail and the API will return
--    But still the call is being kept to cover for any future changes in Document Status check API
-- 3. The check for revision is needed at least for one corner case in which while the callout was made
--    in revision 0.0 in normal mode but while the changes were saved to Contracts, the revision changed to
--    1.0 . Now the callout should have been made in Amend mode and not in normal mode. So, this API will
--    return "Update not allowed"
--Testing:
-- Test this API by passing various status and revision of PO while changing those for the PO thru UI
-- Test for changing the closed code and cancel status
-- Test for Inprocess status
-- Test for Changing just the revison while keeping the status same
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE IS_po_update_allowed (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_header_id              IN NUMBER,
  p_callout_string         IN VARCHAR2,
  p_lock_flag              IN VARCHAR2 DEFAULT 'N',
  x_update_allowed         OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER
) IS
  l_api_name          CONSTANT VARCHAR(30) := 'IS_PO_UPDATE_ALLOWED';
  l_api_version       CONSTANT NUMBER := 1.0;
  l_callout_status    PO_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE;
  l_callout_revision  PO_HEADERS_ALL.REVISION_NUM%TYPE;
  l_po_status         PO_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE;
  l_po_revision       PO_HEADERS_ALL.REVISION_NUM%TYPE;

  l_emp_id            NUMBER;
  l_emp               VARCHAR2(100);
  l_doc_type_code     PO_DOCUMENT_TYPES_ALL_B.DOCUMENT_SUBTYPE%TYPE;
  l_document_type     PO_DOCUMENT_TYPES_ALL_B.DOCUMENT_TYPE_CODE%TYPE;
  l_modify_action     BOOLEAN;
  l_start             NUMBER;
  l_end               NUMBER;
  l_Status_changed    EXCEPTION;
  l_DONOT_update      EXCEPTION;
  l_po_status_rec     PO_STATUS_REC_TYPE;

BEGIN
     If g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'10: Start' ||l_api_name);
       END IF;
     End if;

     -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (p_current_version_number=>l_api_version,
                                       p_caller_version_number =>p_api_version,
                                       p_api_name              =>l_api_name,
                                       p_pkg_name              =>G_PKG_NAME)

   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   X_update_allowed := 'Y';

   If g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'50: Do basic validations');
       END IF;
   End if;

 -- Basic validations about in parameters
   IF p_header_id is null then
      Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'p_header_id');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   If p_callout_string is not null then
     L_start  := 1;
     L_end    := instr(p_callout_string,',',1,1)-1;
     L_callout_status := substr(p_callout_string,l_start,l_end);
     L_start  := l_end+2;
     L_end    := instr(p_callout_string,',',l_start,1)-1;
     L_callout_revision := to_number(substr(p_callout_string,l_start,(l_end-l_start+1)));
     L_start  := l_end+2;
     L_emp    := substr(p_callout_string,l_start);
     If l_emp = 'NULL' then
       L_emp := null;
     Else
       l_emp_id := to_number(l_emp);
     END IF;

   ELSE
      Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'p_callout_string');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;

   END IF;-- p_callout _string
   If g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'100: callout status '||l_callout_status);
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'110:callout revision '||l_callout_revision);
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'120:callout employee '||l_emp_id);
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'140:Header id '||p_header_id);
       END IF;
   END IF;
   IF l_callout_status is null then
       Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'callout_status');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_callout_revision is null then
       Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'callout_revision');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
    BEGIN
     -- SQL WHAT-get the current status and revision of the PO
     -- SQL WHY - Needed to compare status and revision with passed in values
     -- SQL JOIN- PO_header_id
        SELECT nvl(authorization_status,'INCOMPLETE'), revision_num, type_lookup_code
        ,DECODE(type_lookup_code,'STANDARD','PO','BLANKET','PA','CONTRACT','PA',null)
        INTO  l_po_status,l_po_revision, l_doc_type_code
             ,l_document_type
        FROM  po_headers_all
        WHERE po_header_id = p_header_id;

       EXCEPTION
        WHEN NO_DATA_FOUND then
            Fnd_message.set_name('PO','PO_DOESNOT_EXIST');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;

    END;

    IF g_fnd_debug = 'Y' then
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'200:current status '||l_po_status);
       END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'220:current revision '||l_po_revision);
       END IF;

    END IF;
     IF (l_po_status = l_callout_status) and (l_po_revision = l_callout_revision) then

           If (l_callout_status in ('IN PROCESS','PRE-APPROVED')) then --- Bug 5606590
              If l_emp_id is null then
                    Fnd_message.set_name('PO','PO_VALUE_MISSING');
                    Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'emp_id_in_callout_str');
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    RAISE FND_API.G_EXC_ERROR;
              End if;--emp id is null
              --Check if current user is the current approver for the PO
             IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'250:doc type '||l_doc_type_code);
                      END IF;
                                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                                     FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'255:before Call to PO_DOCUMENT_CHECKS_GRP.PO_STATUS_CHECK. l_emp_id '||l_emp_id);
                                   END IF;
             END IF;
             PO_SECURITY_CHECK_SV.Check_before_lock(
                      x_type_lookup_code => l_doc_type_code,
                      x_object_id        => p_header_id,
                      x_logged_emp_id    => l_emp_id,
                      x_modify_action    => l_modify_action
                      );
             IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'260:After Call to PO_DOCUMENT_CHECKS_GRP.PO_STATUS_CHECK. modify action ');
                      END IF;
             END IF;
                --This API suppresses the exception. So if something fails, we won't be able to catch it.
                IF l_modify_action then
                  IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'270:modify action true ');
                      END IF;
                  END IF;

                ELSE
                   x_update_allowed := 'N';
                   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'290:modify action false ');
                      END IF;
                   END IF;
                   RAISE l_DONOT_update;

                END IF;
          END IF; -- po status INPROCESS
          IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'292:before status check po id -update allowed '||p_header_id||x_update_allowed);
                      END IF;
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'295:before status check lock '||p_lock_flag);
                      END IF;
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'297:before status check doc type '||l_document_type);
                      END IF;
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'299:Before Call to PO_DOCUMENT_CHECKS_GRP.PO_STATUS_CHECK');
                      END IF;
          END IF;
           -- call Generic PO Document Checks API for further checks
          PO_DOCUMENT_CHECKS_GRP.PO_STATUS_CHECK (
              p_api_version   => 1.0,
              p_header_id     => p_header_id,
              p_document_type => l_document_type,
              p_mode          => 'CHECK_UPDATEABLE',
              p_lock_flag     => p_lock_flag,
              x_po_status_rec => l_po_status_rec,
              x_return_status => x_return_status
          );
          IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'295:After Call to PO_DOCUMENT_CHECKS_GRP.PO_STATUS_CHECK. Return status '||x_return_status);
                      END IF;
          END IF;
          ---Return status handling.
          --If any errors happen abort API.
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		       RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           --PO Status check returns N if document is in status "In Process"
           -- But for Terms authoring it is a valid status. So ignore
           -- results by PO Status Check in that case because the other flags
           -- for which we need to call Po status Check(Firm,cancelled,closed)
           -- also are not possible in this status.
           -- Bug 4914819: we should also ignore results in a "pre-approved"
           -- case as the check will return N for that also but we do allow
           -- approver to edit such a PO
           IF (l_callout_status not in ('IN PROCESS','PRE-APPROVED')) THEN
              x_update_allowed := l_po_status_Rec.updatable_flag(
				   l_po_status_rec.updatable_flag.FIRST);
           END IF;
           IF x_update_allowed = 'N' then
               RAISE l_DONOT_update;
           END IF;
     ELSE -- status and revision same
        RAISE l_Status_Changed;
     END IF; -- if po_status and revision same
     IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'400:End '||l_api_name);
                      END IF;
     END IF;
EXCEPTION
  WHEN l_STATUS_CHANGED then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_update_allowed := 'N';
         FND_MESSAGE.set_name('PO', 'PO_STATUS_CHANGED');
         FND_MSG_PUB.Add;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
         IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'500:Exception l_status_changed ');
                      END IF;
          END IF;


  WHEN l_DONOT_UPDATE then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_update_allowed := 'N';
         FND_MESSAGE.set_name('PO', 'PO_NO_UPDATE_ALLOWED');
         FND_MSG_PUB.Add;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
          IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'550:Exception l_donot_update ');
                      END IF;
          END IF;

  WHEN FND_API.G_EXC_ERROR then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_update_allowed := 'N';
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
         IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'600:Exception Expected error ');
                      END IF;
                      FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'600:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                      END LOOP;

         END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_update_allowed := 'N';
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
         IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'610:Exception UnExpected error ');
                      END IF;
                      FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'610:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                      END LOOP;

         END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    X_update_allowed := 'N';

    IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PO_CONTERMS_UTL_GRP',
		p_procedure_name  => l_api_name);
   END IF;   --msg level
   FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'650:Exception UnExpected error '||sqlcode||':'||sqlerrm);
                      END IF;
   End if;

END is_po_update_allowed;


-------------------------------------------------------------------------------
--Start of Comments
--Name: Apply_template_change
--Pre-reqs:
-- 1.DONOT Use this API from wherever Functional Security Check is needed. This API
--   Assumes that the org context is already set
-- 2.when this API is  called, the calling API is expected to commit or
--   rollback to release the lock on Po_headers_all unless p_commit is set to Y
--Modifies:
-- PO_headers_ALL. The following Columns will be modified
-- CONTERMS_EXIST_FLAG
-- CONTERMS_ARTICLES_UPD_DATE
-- CONTERMS_DELIV_UPD_DATE
--Locks:
-- PO_headers_all
--Function:
-- This API will be called by Contracts  when user attaches or deletes a template
-- from a purchasing document. This API will first check if Po is in updatable status. If yes
-- It will update the conterms fields in po_headers_all based on the action taken in contracts
-- Contracts will populate parameter p_template_changed to Y when this API is called
-- after a new template is attached to PO. Contracts will populate parameter p_template_changed to D when
-- this API is called after template is removed.

--Parameters:
--IN:
--p_api_version
-- Standard Parameter. API version number expected by the caller
--p_init_msg_list
-- Standard parameter.Initialize message list
--p_doc_type
--  OKC Document Type
--p_header_id
-- PO header id
--p_callout_string
-- This string will contain concatenation of following parameters, delimited by comma
--                   : Status of the PO stored in Calling application
--                   : Revision Number of the PO stored in calling application
--                   : Employee id
-- Note that the above parameters should always be concatenated in the same order with no extra spaces around
-- Status and revision are always expected to be there. For Employee Id pass 'Null' if status is not 'IN PROCESS'
--p_template_changed
-- tells Whether this call is being made when a new template was  attached
-- or existing template was dropped. Possible values for this parameter are
-- Y:  Template was added (or contract source changes to attached document)
-- D:  Template was dropped
--OUT:
--x_update_allowed
-- Returns Y or N depending PO is in updatable status or not
--x_msg_count
-- Standard parameter.Message count
--x_msg_data
-- Standard parameter.message data
--x_return_status
-- Standard parameter. Status Returned to calling API. Possible values are following
-- FND_API.G_RET_STS_ERROR - for expected error
-- FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
-- FND_API.G_RET_STS_SUCCESS - for success
--Notes:
-- 07/11/2003 smhanda
-- 1. This API has been written specifically for integration with contracts wherein Contracts Changes
--    are treated as extension to PO Entry form changes of the PO. Before using it in any other place
--    Please diagnose the impact about security and all.
-- 2.Template can only be removed when a PO is in status Incomplete or rejected and PO revision
--   number is 0.
--   This should be enforced by Contracts UI but this API will also enforce that because
--   Contracts Enforces that template can be dropped in Update mode. So, if this
--   API is called in Update mode with Status InProcess, Contracts UI will show the button
--   "Remove Contract Template" but this API will not let user do it as Dropping a template
--   when the PO is "in process" would require that we set the workflow parameter "Procurement Contract"
--   Everytime PO goes from one approver to next. This is a very corner case and functionally
--   Not very viable as an approver should be rejecting the PO rather than making it non procuremet
--   contract from a procurement contract during approval. If there is any valid business
--   requirement during customer implementation rather than what is being mandated here
--   the changes in workflow approval should also be taken care of.
-- 3.Since this API also checks PO updatable status, Contracts should call just this
--   API when template is attached. There is no need to call PO_UPDATE_ALLOWED in this case
--
--Testing:
-- Test this API by passing various status of PO while changing those for the PO thru UI
-- Test for passing various values for p_template_change
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Apply_template_change (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_header_id              IN NUMBER,
  p_callout_string         IN VARCHAR2,
  p_template_changed       IN VARCHAR2,
  p_commit                 IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_update_allowed         OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER
) IS
  l_api_name          CONSTANT VARCHAR(30) := 'Apply_template_Change';
  l_api_version       CONSTANT NUMBER := 1.0;
  l_update_not_allowed         EXCEPTION;
  l_date                       DATE;
  l_conterms_exist_flag       VARCHAR2(1);

  l_callout_status            PO_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE;
  l_callout_revision          PO_HEADERS_ALL.REVISION_NUM%TYPE;
  l_old_conterms_flag         VARCHAR2(1); -- <11i10+ Contracts ER Migrate PO>
  l_start                     NUMBER;
  l_end                       NUMBER;
BEGIN
   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'10: Start' ||l_api_name);
                      END IF;
   End if;
   --Savepoint
   SAVEPOINT SP_APPLY_TEMPLATE_CHANGE;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (p_current_version_number=>l_api_version,
                                       p_caller_version_number =>p_api_version,
                                       p_api_name              =>l_api_name,
                                       p_pkg_name              =>G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_update_allowed := 'N';

   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'50: x_update_allowed' ||x_update_allowed);
                      END IF;
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'70: p_template_changed' ||p_template_changed);
                      END IF;
                       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'100: p_callout_string' ||p_callout_string);
                       END IF;
                       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                         FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'120: p_header_id' ||p_header_id);
                       END IF;

   End if;
   IF P_template_changed in ('Y','D') then

      -- Business Rule- You cannot remove or attach template if PO is in status
      -- other than incomplete or rejected OR PO revision is greater than 0
        If p_callout_string is not null then
           L_start  := 1;
           L_end    := instr(p_callout_string,',',1,1)-1;
           L_callout_status := substr(p_callout_string,l_start,l_end);
           L_start  := l_end+2;
           L_end    := instr(p_callout_string,',',l_start,1)-1;
           l_callout_revision := to_number(substr(p_callout_string,l_start,(l_end-l_start+1)));

       ELSE
              Fnd_message.set_name('PO','PO_VALUE_MISSING');
              Fnd_message.set_token( token  => 'VARIABLE'
                                   , VALUE => 'p_callout_string');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;

       END IF;-- p_callout _string
       IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'150: po status should be Incomplete/rejected-'||l_callout_status);
                      END IF;
                                            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                                              FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'155: po revision should be 0-'||l_callout_revision);
                                            END IF;
       End if;

       -- <Start Bug 4007548>: Comment out check
       -- See bug for version that needs to be added back in
       -- if we allow add/drop template in ammend, this needs to
       -- be modified as mentioned in the bug
       --
       -- IF (l_callout_status   NOT IN  ('INCOMPLETE','REJECTED', 'APPROVED'))
       -- THEN
       --  RAISE l_update_not_allowed;
       -- END IF;
       --
       -- <End Bug 4007548>

       -- <11i10+ Migrate PO Start>
       -- Added the following condition to prevent adding/dropping conterms
       -- if the approver comes in  between the workflow process. The message
       -- is also modified accordingly
       IF (l_callout_status  IN  ('PRE-APPROVED','IN PROCESS'))
       THEN

           SELECT poh.conterms_exist_flag
           INTO l_old_conterms_flag
           FROM PO_HEADERS_ALL poh
           WHERE poh.po_header_id = p_header_id;

           --12934631 add NVL() function to handle the null value when create a
           --new docutment
           IF ((NVL(l_old_conterms_flag, 'N') = 'N') AND (p_template_changed = 'Y'))
              OR ((l_old_conterms_flag = 'Y') AND (p_template_changed = 'D'))
           THEN
             RAISE l_update_not_allowed;
           END IF;
       END IF;
       -- <11i10+ Migrate PO End>

       -- call po update allowed to check PO status
          IS_PO_UPDATE_ALLOWED (
              p_api_version    => p_api_version,
              p_header_id      => p_header_id,
              p_callout_string => p_callout_string,
              p_lock_flag      => 'Y',
              x_update_allowed => x_update_allowed,
              x_return_status  => x_return_status,
              x_msg_data       => x_msg_data,
              x_msg_count      => x_msg_count);
          ---Return status handling.
          --If any errors happen abort API.
          IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'200:update allowed after calling is_po_update_allowed'||x_update_allowed);
                      END IF;
          End if;
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		         RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

         -- take action on PO if update is allowed. The Control should reach here
         -- only if x_update_allowed = Y. Otherwise po_update_allowed
         -- would return Error

          If (p_template_changed = 'Y') then -- set flag to Y if template is added
                       L_date := Sysdate;
                       L_conterms_exist_flag := 'Y';
                       IF g_fnd_debug = 'Y' then
                             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                               FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                              MODULE   =>g_module_prefix||l_api_name,
                              MESSAGE  =>'250:Procurement Contract. id'||p_header_id);
                             END IF;
                       End if;
          ELSE   -- if template is being deleted set dates to null, flag to N;
                       L_date := null;
                       L_conterms_exist_flag := 'N';
                       IF g_fnd_debug = 'Y' then
                            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                              FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                            MODULE   =>g_module_prefix||l_api_name,
                            MESSAGE  =>'270:No More Procurement Contract. id'||p_header_id);
                            END IF;
                      End if;
          END IF;

         -- SQL WHAT-Update the conterms_exist_flag and the contract terms dates in po_headers_all
         -- SQL WHY - Update the flag based on if contract terms template attached or removed
         -- SQL JOIN- None
         Update po_headers_all
              Set conterms_exist_flag = l_conterms_exist_flag,
                  Conterms_articles_upd_date = l_date,
                  Conterms_DELIV_upd_date = l_date,
                  Last_update_date = sysdate,
                  Last_updated_by = FND_GLOBAl.USER_ID,
                  Last_update_login = FND_GLOBAL.LOGIN_ID
         WHERE po_header_id= p_header_id;

         IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'300:Po headers all updated for header id'||p_header_id);
                      END IF;
         End if;

     ELSE -- if p_template_changed other than Y or D

      Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'p_template_changed');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;

     END IF; -- if p_template_changed other than Y or D

   -- Commit the transaction if p_commit set true
   IF FND_API.TO_BOOLEAN(p_commit) then
       IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'390: Commit set to true');
                      END IF;
       End if;
       COMMIT;
   END IF;
   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'400: End' ||l_api_name);
                      END IF;
   End if;
EXCEPTION
  WHEN l_update_not_allowed then
         x_return_status := FND_API.G_RET_STS_ERROR;
         X_update_allowed := 'N';
         ROLLBACK TO SP_APPLY_TEMPLATE_CHANGE;
        FND_MESSAGE.set_name('PO', 'PO_NO_TEMPLATE_CHANGE');
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
        IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'450:Exception l_update_not_allowed ');
                      END IF;
        END IF;
  WHEN FND_API.G_EXC_ERROR then
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO SP_APPLY_TEMPLATE_CHANGE;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
         IF g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'470: expected error ');
            END IF;
            FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'470:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
           END LOOP;
         END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK TO SP_APPLY_TEMPLATE_CHANGE;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
         IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'480:Exception UnExpected error ');
                      END IF;
                      FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'480:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                      END LOOP;

         END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO SP_APPLY_TEMPLATE_CHANGE;
    IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PO_CONTERMS_UTL_GRP',
		        p_procedure_name  => l_api_name);
   END IF;   --msg level
   FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'500:Exception UnExpected error '||sqlcode||':'||sqlerrm);
                      END IF;
    END IF;
END Apply_template_change;
-------------------------------------------------------------------------------
--Start of Comments
--Name: Attribute_value_changed
--Pre-reqs:
-- 1.DONOT Use this API from wherever Functional Security Check is needed. This API
--   Assumes that the org context is already set
-- 2.This API should only be called when Contracts QA is in Amend mode
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by Contracts to check if values of system variables
-- Changed between latest revision (working copy)  and the last archived one.
--Parameters:
--IN:
--p_api_version
-- Standard Parameter. API version number expected by the caller
--p_init_msg_list
-- Standard parameter.Initialize message list
--p_doc_type
--  OKC Document Type
--p_doc_id
-- PO header id
--IN OUT:
--p_sys_var_tbl
-- A table of varchar2(40) to hold the system variable codes which changed between the two revisions
-- Contracts will pass list of all PO attributes being used in Contract terms fot that PO
-- This APi will filter that list to return only those which changed since last revsion
--OUT:
--x_msg_count
-- Standard parameter.Message count
--x_msg_data
-- Standard parameter.message data
--x_return_status
-- Standard parameter. Status Returned to calling API. Possible values are following
-- FND_API.G_RET_STS_ERROR - for expected error
-- FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
-- FND_API.G_RET_STS_SUCCESS - for success
--Notes:
-- 07/11/2003 smhanda
-- 1. This API has been written specifically for integration with contracts Before using it in any other place
--    Please diagnose the impact about including security
--Testing:
-- Test this API by passing different po Header where in some are archived, some are not, some are signed
-- Test for value changes between last version and current
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE attribute_value_changed (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_doc_id                 IN NUMBER,
  p_sys_var_tbl            IN OUT NOCOPY VARIABLE_CODE_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER
) IS
  l_api_name          CONSTANT VARCHAR(30) := 'Attribute_value_changed';
  l_api_version       CONSTANT NUMBER := 1.0;
  l_type_lookup_code  po_headers_all.type_lookup_code%type;
  -- the length varchar40 fixed with the assumption that the length of variable code
  -- will not exceed this. For using %type, dependence on OKC tables. Consider for refactor
  l_po_attrib_tbl        VARIABLE_CODE_TBL_TYPE;
  l_sys_var_index        BINARY_INTEGER;
  l_po_attribute_index   BINARY_INTEGER;
  l_found                   BOOLEAN;
  l_check                   VARCHAR2(1);
  l_spo_amt                  NUMBER;
  l_archived_spo_amt        NUMBER;
BEGIN
   IF g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
        MODULE   =>g_module_prefix||l_api_name,
        MESSAGE  =>'10: Start API' ||l_api_name);
        END IF;
   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (p_current_version_number=>l_api_version,
                                       p_caller_version_number =>p_api_version,
                                       p_api_name              =>l_api_name,
                                       p_pkg_name              =>G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Basic validations about in parameters
   IF p_doc_id is null then
      Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'p_doc_id');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- SQL WHAT-get the changed status for PO system Variables
   -- SQL WHY - Needed by Contracts to check if amendments generated for changed ones
   -- SQL JOIN- PO_header_id
   -- This query assumes that there is a record in archives since this procedure
   -- should be called by contracts only in amend mode, which happens, if PO has been
   -- archived at least once.
   SELECT
   DECODE(poh.org_id,poha.org_id,'N','OKC$B_ORGANIZATION')
  ,DECODE(poh.vendor_id,poha.vendor_id,'N','OKC$B_SUPPLIER_NAME')
  ,DECODE(poh.vendor_site_id,poha.vendor_site_id,'N','OKC$B_SUPPLIER_SITE')
  ,DECODE(poh.vendor_contact_id,poha.vendor_contact_id,'N','OKC$B_SUPPLIER_CONTACT')
  ,DECODE(poh.ship_to_location_id,poha.ship_to_location_id,'N','OKC$B_SHIP_TO_ADDRESS')
  ,DECODE(poh.bill_to_location_id,poha.bill_to_location_id,'N','OKC$B_BILL_TO_ADDRESS')
  ,DECODE(poh.currency_code,poha.currency_code,'N','OKC$B_TXN_CURRENCY')
  ,DECODE(poh.agent_id,poha.agent_id,'N','OKC$B_BUYER')
  ,DECODE(poh.blanket_total_amount,poha.blanket_total_amount,'N','OKC$B_AGREEMENT_AMOUNT_TXN')
  ,DECODE(poh.blanket_total_amount,poha.blanket_total_amount,'N','OKC$B_AGREEMENT_AMOUNT_FUNC')
  ,DECODE(poh.global_agreement_flag,poha.global_agreement_flag,'N','OKC$B_GLOBAL_FLAG')
  ,DECODE(poh.rate_type,poha.rate_type,'N','OKC$B_RATE_TYPE')
  ,DECODE(poh.rate_date,poha.rate_date,'N','OKC$B_RATE_DATE')
  ,DECODE(poh.rate,poha.rate,'N','OKC$B_RATE')
  ,DECODE(poh.terms_id ,poha.terms_id,'N','OKC$B_PAYMENT_TERMS')
  ,DECODE(poh.freight_terms_lookup_code,poha.freight_terms_lookup_code,'N','OKC$B_FREIGHT_TERMS')
  ,DECODE(poh.ship_via_lookup_code,poha.ship_via_lookup_code,'N','OKC$B_CARRIER')
  ,DECODE(poh.fob_lookup_code,poha.fob_lookup_code,'N','OKC$B_FOB')
  ,DECODE(poh.pay_on_code,poha.pay_on_code,'N','OKC$B_PAY_ON_CODE')
  ,DECODE(poh.acceptance_required_flag,poha.acceptance_required_flag,'N','OKC$B_ACCEPTANCE_METHOD')
  ,DECODE(poh.acceptance_due_date,poha.acceptance_due_date,'N','OKC$B_ACCEPTANCE_REQD_DATE')
  ,DECODE(poh.supply_agreement_flag,poha.supply_agreement_flag,'N','OKC$B_SUPPLY_AGREEMENT_FLAG')
  ,DECODE(poh.start_date,poha.start_date,'N','OKC$B_AGREEMENT_START_DATE')
  ,DECODE(poh.end_date,poha.end_date,'N','OKC$B_AGREEMENT_END_DATE')
  ,DECODE(poh.min_release_amount,poha.min_release_amount,'N','OKC$B_MINIMUM_RELEASE_AMT_TXN')
  ,DECODE(poh.min_release_amount,poha.min_release_amount,'N','OKC$B_MINIMUM_RELEASE_AMT_FUNC')
  ,poh.type_lookup_code
  ,DECODE(poh.shipping_control, poha.shipping_control, 'N', 'OKC$B_TRANSPORTATION_ARRANGED') --<HTML Agreements R12>
INTO
       l_po_attrib_tbl(1)
      ,l_po_attrib_tbl(2)
      ,l_po_attrib_tbl(3)
      ,l_po_attrib_tbl(4)
      ,l_po_attrib_tbl(5)
      ,l_po_attrib_tbl(6)
      ,l_po_attrib_tbl(7)
      ,l_po_attrib_tbl(8)
      ,l_po_attrib_tbl(9)
      ,l_po_attrib_tbl(10)
      ,l_po_attrib_tbl(11)
      ,l_po_attrib_tbl(12)
      ,l_po_attrib_tbl(13)
      ,l_po_attrib_tbl(14)
      ,l_po_attrib_tbl(15)
      ,l_po_attrib_tbl(16)
      ,l_po_attrib_tbl(17)
      ,l_po_attrib_tbl(18)
      ,l_po_attrib_tbl(19)
      ,l_po_attrib_tbl(20)
      ,l_po_attrib_tbl(21)
      ,l_po_attrib_tbl(22)
      ,l_po_attrib_tbl(23)
      ,l_po_attrib_tbl(24)
      ,l_po_attrib_tbl(25)
      ,l_po_attrib_tbl(26)
      --before adding next running index here Note that l_po_attrib_tbl(27) and l_po_attrib_tbl(28)
      --are used below for header amounts
      ,l_type_lookup_code
      ,l_po_attrib_tbl(29) --<HTML Agreement R12>

FROM
   po_headers_all              poh
  ,po_headers_archive_all      poha
WHERE poh.po_header_id  = p_doc_id
  AND  poh.po_header_id = poha.po_header_id
  AND  poha.latest_external_flag = 'Y';

   IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'120: selected columns with changed values');
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'130: document type '||l_type_lookup_code);
                    END IF;

   END IF;
       -- Get Change for PO_total_amount for SPO
       -- The following query has an outer join based on the assumption that
       -- it is possible that only header was archived and the line was not
       -- since all the changes that happened were in Header only
       IF l_type_lookup_code = 'STANDARD' then
            -- get total amount for working copy of PO
            l_spo_amt := po_core_s.get_total(x_object_type=>'H',
                                             x_object_id  =>p_doc_id);
             --get total amount for last archived version of PO
            l_archived_spo_amt:=po_core_s.get_archive_total
						  (p_object_id  =>p_doc_id,
                           p_doc_type => 'PO',
                           p_doc_subtype => 'STANDARD');
           IF l_spo_amt <> l_archived_spo_amt THEN
              l_po_attrib_tbl(27) := 'OKC$B_PO_TOTAL_AMOUNT_TXN' ;
              --If amount for transaction currency has changed, then assume that amount in
              --Function currency Changed as well.
              l_po_attrib_tbl(28) := 'OKC$B_PO_TOTAL_AMOUNT_FUNC';
           END IF; -- l_spo_amt <> l_archived_spo_amt


           IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'150: Got header amount differnce');
                    END IF;
           END IF;
        END IF;-- type_lookup_code='STANDARD'
        IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'160: First p_sys_var'||p_sys_var_tbl.FIRST);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'165: Last p_sys_var'||p_sys_var_tbl.LAST);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'170: first l_po_var'||p_sys_var_tbl.FIRST);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'175: last l_po_var'||p_sys_var_tbl.LAST);
                    END IF;
        END IF;
-- filter the changed value sent by contracts
  l_sys_var_index := p_sys_var_tbl.FIRST;
  While l_sys_var_index <= p_sys_var_tbl.last
  LOOP
        IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'180: current p_sys_var index'||l_sys_var_index);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'185: current p_sys_var value'||p_sys_var_tbl(l_sys_var_index));
                    END IF;
       END IF;
       l_found := false;
       l_po_attribute_index := l_po_attrib_tbl.FIRST;
       While l_po_attribute_index <= l_po_attrib_tbl.LAST
       LOOP
               IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                  MODULE   =>g_module_prefix||l_api_name,
                                  MESSAGE  =>'190: current l_po_var index'||l_po_attribute_index);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                   MODULE   =>g_module_prefix||l_api_name,
                                   MESSAGE  =>'200: current l_po_var value'||l_po_attrib_tbl(l_po_attribute_index));
                    END IF;

              END IF;
             IF l_po_attrib_tbl(l_po_attribute_index)= 'N' then
                    IF g_fnd_debug = 'Y' then
                        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                          FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                         MODULE   =>g_module_prefix||l_api_name,
                         MESSAGE  =>'210: Delete l_po_var'||l_po_attrib_tbl(l_po_attribute_index));
                        END IF;
                    END IF;
                   l_po_attrib_tbl.DELETE(l_po_attribute_index);
                   IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'215: Deleted');
                      END IF;
                   END IF;

             ELSIF l_po_attrib_tbl(l_po_attribute_index) = p_sys_var_tbl(l_sys_var_index) then
                   l_found:=true;
                   Exit;
             END IF;-- if l_po_attrib_tbl has something other than 'N'
             l_po_attribute_index := l_po_attrib_tbl.next(l_po_attribute_index);
       END LOOP;-- l_po_attribute_index inner loop
       If NOT l_found then
         IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'220: Delete p_sys_var'||p_sys_var_tbl(l_sys_var_index));
                    END IF;
         END IF;
          p_sys_var_tbl.delete(l_sys_var_index);
         IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'225: Deleted');
                    END IF;
         END IF;
       End if; --not l_found
       l_sys_var_index := p_sys_var_tbl.next(l_sys_var_index);

  END LOOP;-- l_sys_var_index outer loop
  IF g_fnd_debug = 'Y' then
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'230: Filtering ended. element in p_sys_var'||p_sys_var_tbl.count);
     END IF;

    l_sys_var_index := p_sys_var_tbl.FIRST;
    While l_sys_var_index <= p_sys_var_tbl.last
     LOOP
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'240: current index' ||l_sys_var_index);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'250: column being sent'||p_sys_var_tbl(l_sys_var_index));
                    END IF;

            l_sys_var_index := p_sys_var_tbl.next(l_sys_var_index);
       END LOOP;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'500: End API ' ||l_api_name);
        END IF;
    END IF; -- if fnd debug
EXCEPTION

  WHEN FND_API.G_EXC_ERROR then
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
          IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'600:Exception Expected error ');
                    END IF;
                    FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'600:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                    END LOOP;

          END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
          IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'610:Exception UnExpected error ');
                    END IF;
                    FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'610:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                    END LOOP;

          END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PO_CONTERMS_UTILS_GRP',
		p_procedure_name  => l_api_name);
   END IF;   --msg level
   FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
   IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'700:Exception UnExpected error '||sqlcode||':'||sqlerrm);
                    END IF;
   END IF;
END attribute_value_changed;



-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_PO_Attribute_values
--Pre-reqs:
-- 1.DONOT Use this API from wherever Functional Security Check is needed.
-- 2. This API Assumes that the org context is already set
-- 3. This API will return valid values for System Variables used in Configurator
--    OR for the system variables who reside directly on Po Headers. For the
--    rest, it returns dummy value( See HLD)- No need to check whether value
--    exists or not for setup system variables. This API returns dummy value
--    so that the QA check for any value exists does not return uneccesary warnings
--    For set up variables that are not directly on PO
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by Contracts to get values of system variables
-- used in Contract terms configurator rules ( Non tabular ones)
-- This API is also being called by Contracts QA to check if the used variables
-- have a value.
--Parameters:
--IN:
--p_api_version
-- Standard Parameter. API version number expected by the caller
--p_init_msg_list
-- Standard parameter.Initialize message list
--p_doc_type
--  OKC Document Type
--p_doc_id
-- PO header id
--IN OUT:
--p_sys_var_value_tbl
-- A table of records to hold the system variable codes and values in working copy
--OUT:
--x_msg_count
-- Standard parameter.Message count
--x_msg_data
-- Standard parameter.message data
--x_return_status
-- Standard parameter. Status Returned to calling API. Possible values are following
-- FND_API.G_RET_STS_ERROR - for expected error
-- FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
-- FND_API.G_RET_STS_SUCCESS - for success
--Notes:
-- 07/11/2003 smhanda
-- 1. This API has been written specifically for integration with contracts Before using it in any other place
--    Please diagnose the impact about including security
--
--Testing:
-- Test for existing/not existing values in PO
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_PO_Attribute_values(
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_doc_id                 IN NUMBER,
  p_sys_var_value_tbl      IN OUT NOCOPY VARIABLE_VALUE_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER) IS

  l_api_name          CONSTANT VARCHAR(30) := 'Get_PO_Attribute_values';
  l_api_version       CONSTANT NUMBER := 1.0;
  l_type_lookup_code  po_headers_all.type_lookup_code%type;
  -- the length varchar40 fixed with the assumption that the length of variable code
  -- will not exceed this. For using %type, dependence on OKC tables. Consider for refactor
  l_po_attrib_tbl           VARIABLE_VALUE_TBL_TYPE;
  l_sys_var_index                       BINARY_INTEGER;
  l_po_attribute_index                       BINARY_INTEGER;
  l_found                   BOOLEAN;
  l_check                   VARCHAR2(1);
  --BUG#3809298.Introducing the variables below to fetch the
  --parameters involved in calculating the functional and trancastion amounts
  --from the SQL query below.
  l_poh_type_lookup_code          PO_HEADERS.type_lookup_code%type;
  l_poh_rate                      PO_HEADERS.rate%type    ;
  l_cu_MINIMUM_ACCOUNTABLE_UNIT   FND_CURRENCIES_VL.minimum_accountable_unit%type;
  l_cu_precision                  FND_CURRENCIES_VL.precision%type;
  l_cuf_MINIMUM_ACCOUNTABLE_UNIT  FND_CURRENCIES_VL.minimum_accountable_unit%type;
  l_cuf_precision                 FND_CURRENCIES_VL.precision%type;
  l_po_total_amount               NUMBER;
  --BUG#3809298 End of variable declarations.

  -- Bug 3250745. l_dummy_value will be returned for all the variables which neither
  --live in po tables nor are needed for configurator (As per HLD)
  -- The reason for doing this is to avoid extra processing and joins
  -- For setup system variables whose values are not changed frequently
  --If a system variable is changed to use in Configurator. Make sure
  --its actual value is returned and not dummy
  l_dummy_value             VARCHAR2(10) := 'NOT_NULL';
BEGIN
   IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'10: Start API' ||l_api_name);
                    END IF;
  END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (p_current_version_number=>l_api_version,
                                       p_caller_version_number =>p_api_version,
                                       p_api_name              =>l_api_name,
                                       p_pkg_name              =>G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Basic validations about in parameters
   IF p_doc_id is null then
      Fnd_message.set_name('PO','PO_VALUE_MISSING');
      Fnd_message.set_token( token  => 'VARIABLE'
                           , VALUE => 'p_doc_id');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- make the return table with attribute names
      l_po_attrib_tbl(1).variable_code:= 'OKC$B_ORGANIZATION';
      l_po_attrib_tbl(2).variable_code:= 'OKC$B_DOCUMENT_TYPE';
      l_po_attrib_tbl(3).variable_code:= 'OKC$B_SUPPLIER_NAME';
      l_po_attrib_tbl(4).variable_code:= 'OKC$B_SUPPLIER_SITE';
      l_po_attrib_tbl(5).variable_code:= 'OKC$B_SUPPLIER_STATE';
      l_po_attrib_tbl(6).variable_code:= 'OKC$B_SUPPLIER_ZIP';
      l_po_attrib_tbl(7).variable_code:= 'OKC$B_SUPPLIER_COUNTRY';
      l_po_attrib_tbl(8).variable_code:= 'OKC$B_SHIP_TO_ADDRESS';
      l_po_attrib_tbl(9).variable_code:= 'OKC$B_BILL_TO_ADDRESS';
      l_po_attrib_tbl(10).variable_code:= 'OKC$B_TXN_CURRENCY';
      l_po_attrib_tbl(11).variable_code:= 'OKC$B_FUNC_CURRENCY';
      l_po_attrib_tbl(12).variable_code:= 'OKC$B_PO_TOTAL_AMOUNT_TXN';
      l_po_attrib_tbl(13).variable_code:= 'OKC$B_PO_TOTAL_AMOUNT_FUNC';
      l_po_attrib_tbl(14).variable_code:= 'OKC$B_AGREEMENT_AMOUNT_TXN';
      l_po_attrib_tbl(15).variable_code:= 'OKC$B_AGREEMENT_AMOUNT_FUNC';
      l_po_attrib_tbl(16).variable_code:= 'OKC$B_GLOBAL_FLAG';
      l_po_attrib_tbl(17).variable_code:= 'OKC$B_RATE_TYPE';
      l_po_attrib_tbl(18).variable_code:= 'OKC$B_PAYMENT_TERMS';
      l_po_attrib_tbl(19).variable_code:= 'OKC$B_FREIGHT_TERMS';
      l_po_attrib_tbl(20).variable_code:= 'OKC$B_CARRIER';
      l_po_attrib_tbl(21).variable_code:= 'OKC$B_FOB';
      l_po_attrib_tbl(22).variable_code:= 'OKC$B_PAY_ON_CODE';
      l_po_attrib_tbl(23).variable_code:= 'OKC$B_SUPPLY_AGREEMENT_FLAG';
      l_po_attrib_tbl(24).variable_code:= 'OKC$B_MINIMUM_RELEASE_AMT_TXN';
      l_po_attrib_tbl(25).variable_code:= 'OKC$B_MINIMUM_RELEASE_AMT_FUNC';
      l_po_attrib_tbl(26).variable_code:= 'OKC$B_LEGAL_ENTITY';
      l_po_attrib_tbl(27).variable_code:= 'OKC$B_DOCUMENT_NUMBER';
      l_po_attrib_tbl(28).variable_code:= 'OKC$B_DOCUMENT_REVISION';
      l_po_attrib_tbl(29).variable_code:= 'OKC$B_SUPPLIER_CONTACT';
      l_po_attrib_tbl(30).variable_code:= 'OKC$B_BUYER';
      l_po_attrib_tbl(31).variable_code:= 'OKC$B_RATE_DATE';
      l_po_attrib_tbl(32).variable_code:= 'OKC$B_RATE';
      l_po_attrib_tbl(33).variable_code:= 'OKC$B_ACCEPTANCE_METHOD';
      l_po_attrib_tbl(34).variable_code:= 'OKC$B_ACCEPTANCE_REQD_DATE';
      l_po_attrib_tbl(35).variable_code:= 'OKC$B_AGREEMENT_START_DATE';
      l_po_attrib_tbl(36).variable_code:= 'OKC$B_AGREEMENT_END_DATE';


   --------------------------------------------------------------------
   -- As per HLD (BUG 3250745), the system variables which are part of Oracle setup but neither
   -- live in PO tables nor used in Configurator Contract Expert, we
   -- donot need to return the value for QA Check- "If some value is there"
   -- So we are returning dummy value so that unnecessary warnings are not
   -- generated in QA
   --START - SET UP DUMMIES--------------------------------------------
     l_po_attrib_tbl(37).variable_code:= 'OKC$B_ORGANIZATION_REGION1';
     l_po_attrib_tbl(37).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(38).variable_code:= 'OKC$B_ORGANIZATION_REGION2';
     l_po_attrib_tbl(38).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(39).variable_code:= 'OKC$B_ORGANIZATION_REGION3';
     l_po_attrib_tbl(39).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(40).variable_code:= 'OKC$B_ORGANIZATION_ADDR_STYLE';
     l_po_attrib_tbl(40).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(41).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR';
     l_po_attrib_tbl(41).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(42).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_STYLE';
     l_po_attrib_tbl(42).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(43).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_1';
     l_po_attrib_tbl(43).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(44).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_2';
     l_po_attrib_tbl(44).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(45).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_3';
     l_po_attrib_tbl(45).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(46).variable_code:= 'OKC$B_LEGAL_ENTITY_CITY';
     l_po_attrib_tbl(46).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(47).variable_code:= 'OKC$B_LEGAL_ENTITY_ZIP';
     l_po_attrib_tbl(47).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(48).variable_code:= 'OKC$B_LEGAL_ENTITY_COUNTRY';
     l_po_attrib_tbl(48).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(49).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION1';
     l_po_attrib_tbl(49).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(50).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION2';
     l_po_attrib_tbl(50).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(51).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION3';
     l_po_attrib_tbl(51).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(52).variable_code:= 'OKC$B_SUPPLIER_ADDRESS';
     l_po_attrib_tbl(52).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(53).variable_code:= 'OKC$B_SUPPLIER_ADDRESS_LINE_1';
     l_po_attrib_tbl(53).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(54).variable_code:= 'OKC$B_SUPPLIER_ADDRESS_LINE_2';
     l_po_attrib_tbl(54).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(55).variable_code:= 'OKC$B_SUPPLIER_ADDRESS_LINE_3';
     l_po_attrib_tbl(55).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(56).variable_code:= 'OKC$B_SUPPLIER_CITY';
     l_po_attrib_tbl(56).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(57).variable_code:= 'OKC$B_SUPPLIER_CLASSIFICATION';
     l_po_attrib_tbl(57).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(58).variable_code:= 'OKC$B_SUPPLIER_MINORITY_TYPE';
     l_po_attrib_tbl(58).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(59).variable_code:= 'OKC$B_SHIP_TO_ADDR_STYLE';
     l_po_attrib_tbl(59).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(60).variable_code:= 'OKC$B_SHIP_TO_ADDR_LINE1';
     l_po_attrib_tbl(60).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(61).variable_code:= 'OKC$B_SHIP_TO_ADDR_LINE2';
     l_po_attrib_tbl(61).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(62).variable_code:= 'OKC$B_SHIP_TO_ADDR_LINE3';
     l_po_attrib_tbl(62).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(63).variable_code:= 'OKC$B_SHIP_TO_ADDR_CITY';
     l_po_attrib_tbl(63).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(64).variable_code:= 'OKC$B_SHIP_TO_ADDR_ZIP';
     l_po_attrib_tbl(64).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(65).variable_code:= 'OKC$B_SHIP_TO_ADDR_COUNTRY';
     l_po_attrib_tbl(65).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(66).variable_code:= 'OKC$B_SHIP_TO_ADDR_REGION1';
     l_po_attrib_tbl(66).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(67).variable_code:= 'OKC$B_SHIP_TO_ADDR_REGION2';
     l_po_attrib_tbl(67).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(68).variable_code:= 'OKC$B_SHIP_TO_ADDR_REGION3';
     l_po_attrib_tbl(68).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(69).variable_code:= 'OKC$B_BILL_TO_ADDR_STYLE';
     l_po_attrib_tbl(69).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(70).variable_code:= 'OKC$B_BILL_TO_ADDR_LINE1';
     l_po_attrib_tbl(70).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(71).variable_code:= 'OKC$B_BILL_TO_ADDR_LINE2';
     l_po_attrib_tbl(71).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(72).variable_code:= 'OKC$B_BILL_TO_ADDR_LINE3';
     l_po_attrib_tbl(72).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(73).variable_code:= 'OKC$B_BILL_TO_ADDR_CITY';
     l_po_attrib_tbl(73).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(74).variable_code:= 'OKC$B_BILL_TO_ADDR_ZIP';
     l_po_attrib_tbl(74).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(75).variable_code:= 'OKC$B_BILL_TO_ADDR_COUNTRY';
     l_po_attrib_tbl(75).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(76).variable_code:= 'OKC$B_BILL_TO_ADDR_REGION1';
     l_po_attrib_tbl(76).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(77).variable_code:= 'OKC$B_BILL_TO_ADDR_REGION2';
     l_po_attrib_tbl(77).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(78).variable_code:= 'OKC$B_BILL_TO_ADDR_REGION3';
     l_po_attrib_tbl(78).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(79).variable_code:= 'OKC$B_ORGANIZATION_ADDR';
     l_po_attrib_tbl(79).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(80).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_1';
     l_po_attrib_tbl(80).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(81).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_2';
     l_po_attrib_tbl(81).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(82).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_3';
     l_po_attrib_tbl(82).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(83).variable_code:= 'OKC$B_ORGANIZATION_CITY';
     l_po_attrib_tbl(83).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(84).variable_code:= 'OKC$B_ORGANIZATION_ZIP';
     l_po_attrib_tbl(84).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(85).variable_code:= 'OKC$B_ORGANIZATION_COUNTRY';
     l_po_attrib_tbl(85).variable_value_id:= l_dummy_value;

     l_po_attrib_tbl(86).variable_code:= 'OKC$B_SUPPLIER_ADDRESS_LINE_4';
     l_po_attrib_tbl(86).variable_value_id:= l_dummy_value;

   --END SET UP DUMMIES-----------------------------------------------

   l_po_attrib_tbl(87).variable_code := 'OKC$B_TRANSPORTATION_ARRANGED';--<HTML Agreement R12>
   l_po_attrib_tbl(88).variable_code := 'OKC$B_PURCHASING_STYLE';       --<R12 STYLES PHASE II>

   -------------------------------------------------------------------
    -- SQL WHAT-get the value for PO system Variables
   -- SQL WHY - Needed by Contracts to default in contract expert
   -- SQL JOIN- None
      SELECT
   poh.org_id
  ,poh.type_lookup_code
  ,poh.vendor_id
  ,poh.vendor_site_id
  ,pvs.state
  ,pvs.zip
  ,pvs.country
  ,poh.ship_to_location_id
  ,poh.bill_to_location_id
  ,poh.currency_code
  ,gsb.currency_code
  --Bug#3809298.Selecting the following columns also to calculate the
  --functional and transaction amounts.
  ,poh.type_lookup_code
  ,poh.rate
  ,cu.MINIMUM_ACCOUNTABLE_UNIT
  ,cu.precision
  ,cuf.MINIMUM_ACCOUNTABLE_UNIT
  ,cuf.precision
  --Bug#3809298.Commenting out the below two calculations of funational
  --and transaction amounts as they will be replaced subsequently.
  /*Start of commenting for Bug#3809298 .
  ,decode(poh.type_lookup_code, 'STANDARD',l_po_total_amount,0)
  ,round(round(
               decode (poh.type_lookup_code,
                'STANDARD',l_po_total_amount,0)
                * nvl(poh.rate,1)/nvl(cu.MINIMUM_ACCOUNTABLE_UNIT,1),decode(cu.MINIMUM_ACCOUNTABLE_UNIT,null,cu.precision,0)
              ) * nvl(cu.MINIMUM_ACCOUNTABLE_UNIT,1) /
                  nvl(cuf.MINIMUM_ACCOUNTABLE_UNIT,1),decode(cuf.MINIMUM_ACCOUNTABLE_UNIT,null,cuf.precision,0)
         )* nvl(cuf.MINIMUM_ACCOUNTABLE_UNIT,1)  po_total_amount_func
   End of Commenting.for Bug#3809298	 */
  ,nvl(poh.blanket_total_amount,0)
  ,round(round(
               nvl(poh.blanket_total_amount,0) *
               nvl(poh.rate,1)/nvl(cu.MINIMUM_ACCOUNTABLE_UNIT,1),decode(cu.MINIMUM_ACCOUNTABLE_UNIT,null,cu.precision,0)
              ) * nvl(cu.MINIMUM_ACCOUNTABLE_UNIT,1) /
                  nvl(cuf.MINIMUM_ACCOUNTABLE_UNIT,1),decode(cuf.MINIMUM_ACCOUNTABLE_UNIT,null,cuf.precision,0)
         )* nvl(cuf.MINIMUM_ACCOUNTABLE_UNIT,1)  agreement_amount_func
  ,NVL(poh.global_agreement_flag,'N')
  ,poh.rate_type
  ,poh.terms_id
  ,poh. freight_terms_lookup_code
  ,poh. ship_via_lookup_code
  ,poh. fob_lookup_code
  ,poh.pay_on_code
  ,nvl(poh.supply_agreement_flag, 'N')   --<CONTRACT EXPERT 11.5.10+>
  ,nvl(poh.min_release_amount,0)
  ,round(round(
               nvl(poh. min_release_amount,0) *
               nvl(poh.rate,1)/nvl(cu.MINIMUM_ACCOUNTABLE_UNIT,1),decode(cu.MINIMUM_ACCOUNTABLE_UNIT,null,cu.precision,0)
              ) * nvl(cu.MINIMUM_ACCOUNTABLE_UNIT,1) /
                  nvl(cuf.MINIMUM_ACCOUNTABLE_UNIT,1),decode(cuf.MINIMUM_ACCOUNTABLE_UNIT,null,cuf.precision,0)
         )* nvl(cuf.MINIMUM_ACCOUNTABLE_UNIT,1)  min_release_amount_func
  ,PO_CORE_S.get_default_legal_entity_id(poh.org_id)  -- Bug 4654758, Bug 4691758
  ,poh.segment1
  ,poh.revision_num
  ,poh.vendor_contact_id
  ,poh.agent_id
  ,poh.rate_date
  ,poh.rate
  ,poh.acceptance_required_flag
  ,poh.acceptance_due_date
  ,poh.start_date
  ,poh.end_date
  ,poh.shipping_control                         --<HTML Agreement R12>
  ,poh.style_id || '-' || poh.type_lookup_code  -- Bug 5063781
  ,pov.vendor_type_lookup_code --Bug#18329158
  ,pov.MINORITY_GROUP_LOOKUP_CODE --Bug#18329158

INTO
       l_po_attrib_tbl(1).variable_value_id
      ,l_po_attrib_tbl(2).variable_value_id
      ,l_po_attrib_tbl(3).variable_value_id
      ,l_po_attrib_tbl(4).variable_value_id
      ,l_po_attrib_tbl(5).variable_value_id
      ,l_po_attrib_tbl(6).variable_value_id
      ,l_po_attrib_tbl(7).variable_value_id
      ,l_po_attrib_tbl(8).variable_value_id
      ,l_po_attrib_tbl(9).variable_value_id
      ,l_po_attrib_tbl(10).variable_value_id
      ,l_po_attrib_tbl(11).variable_value_id
      --Bug#3809298.Commenting out l_po_attrib_tbl(12).variable_value_id
      --and l_po_attrib_tbl(13).variable_value_id and replacing them
      --with the local variables declared .
         /*   ,l_po_attrib_tbl(12).variable_value_id
              ,l_po_attrib_tbl(13).variable_value_id   */
      ,l_poh_type_lookup_code
      ,l_poh_rate
      ,l_cu_MINIMUM_ACCOUNTABLE_UNIT
      ,l_cu_precision
      ,l_cuf_MINIMUM_ACCOUNTABLE_UNIT
      ,l_cuf_precision
      --Bug#3809298.
      ,l_po_attrib_tbl(14).variable_value_id
      ,l_po_attrib_tbl(15).variable_value_id
      ,l_po_attrib_tbl(16).variable_value_id
      ,l_po_attrib_tbl(17).variable_value_id
      ,l_po_attrib_tbl(18).variable_value_id
      ,l_po_attrib_tbl(19).variable_value_id
      ,l_po_attrib_tbl(20).variable_value_id
      ,l_po_attrib_tbl(21).variable_value_id
      ,l_po_attrib_tbl(22).variable_value_id
      ,l_po_attrib_tbl(23).variable_value_id
      ,l_po_attrib_tbl(24).variable_value_id
      ,l_po_attrib_tbl(25).variable_value_id
      ,l_po_attrib_tbl(26).variable_value_id
      ,l_po_attrib_tbl(27).variable_value_id
      ,l_po_attrib_tbl(28).variable_value_id
      ,l_po_attrib_tbl(29).variable_value_id
      ,l_po_attrib_tbl(30).variable_value_id
      ,l_po_attrib_tbl(31).variable_value_id
      ,l_po_attrib_tbl(32).variable_value_id
      ,l_po_attrib_tbl(33).variable_value_id
      ,l_po_attrib_tbl(34).variable_value_id
      ,l_po_attrib_tbl(35).variable_value_id
      ,l_po_attrib_tbl(36).variable_value_id
      ,l_po_attrib_tbl(87).variable_value_id --<HTML Agreement R12>
      ,l_po_attrib_tbl(88).variable_value_id --<R12 STYLES PHASE II>
      ,l_po_attrib_tbl(57).variable_value_id --Bug#18329158
      ,l_po_attrib_tbl(58).variable_value_id --Bug#18329158

FROM
   po_headers_all                 poh
  ,FINANCIALS_SYSTEM_PARAMS_ALL    FP
  ,FND_CURRENCIES_VL               CU
  ,GL_SETS_OF_BOOKS               gsb
  ,FND_CURRENCIES_VL              cuf
  ,po_vendor_sites_all            pvs
  ,po_vendors                     pov  --Bug#18329158
WHERE
        poh.po_header_id    = p_doc_id
    AND poh.vendor_site_id  = pvs.vendor_site_id(+)
    AND poh.currency_code   = cu.currency_code
    AND nvl(poh.org_id,-99) = nvl(fp.org_id,-99)
    AND FP.set_of_books_id  = gsb.set_of_books_id
    AND cuf.currency_code   = gsb.currency_code
    AND poh.vendor_id    = pov.vendor_id  --Bug#18329158
  ;

--Bug#3809298.Check if the document type is "Standard"
--If so then calculate the amount in functional and transaction currency.
--If not assign zero those two.
  IF(l_poh_type_lookup_code='STANDARD')THEN
      l_po_total_amount :=po_core_s.get_total('H',p_doc_id);
      l_po_attrib_tbl(12).variable_value_id :=l_po_total_amount;
      SELECT  ROUND
                (
                  ROUND ( l_po_total_amount * NVL (l_poh_rate, 1) / NVL (l_cu_minimum_accountable_unit, 1),
                       	   	 DECODE (l_cu_minimum_accountable_unit, NULL, l_cu_precision, 0)
                   	       )
                 * NVL (l_cu_minimum_accountable_unit, 1) / NVL (l_cuf_minimum_accountable_unit, 1),
                   DECODE (l_cuf_minimum_accountable_unit, NULL, l_cuf_precision, 0)
                )
           * NVL (l_cuf_minimum_accountable_unit, 1) po_total_amount_func
      INTO   l_po_attrib_tbl(13).variable_value_id
      FROM DUAL;
  ELSE
        l_po_attrib_tbl(12).variable_value_id :=0;
        l_po_attrib_tbl(13).variable_value_id :=0;

  END IF;
 --Bug#3809298.End of bug.

        IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'50: First p_sys_var'||p_sys_var_value_tbl.FIRST);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'60: Last p_sys_var'||p_sys_var_value_tbl.LAST);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'70: first l_po_var'||p_sys_var_value_tbl.FIRST);
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'80: last l_po_var'||p_sys_var_value_tbl.LAST);
                    END IF;
      END IF;
-- filter the changed value sent by contracts
  l_sys_var_index := p_sys_var_value_tbl.FIRST;
  While l_sys_var_index <= p_sys_var_value_tbl.last
  LOOP
        IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                   MODULE   =>g_module_prefix||l_api_name,
                                   MESSAGE  =>'100: current p_sys_var index'||l_sys_var_index);
                    END IF;
                            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                              FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                   MODULE   =>g_module_prefix||l_api_name,
                                   MESSAGE  =>'110: current p_sys_var value code'
                                             ||p_sys_var_value_tbl(l_sys_var_index).variable_code);
                            END IF;
        END IF;
        l_found := false;
        l_po_attribute_index := l_po_attrib_tbl.FIRST;
        While l_po_attribute_index <= l_po_attrib_tbl.LAST
           LOOP
                       IF g_fnd_debug = 'Y' then
                             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                               FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                            MODULE   =>g_module_prefix||l_api_name,
                                            MESSAGE  =>'160: current l_po_var index'||l_po_attribute_index);
                             END IF;
                             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                               FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                            MODULE   =>g_module_prefix||l_api_name,
                                            MESSAGE  =>'165: next l_po_var value'||l_po_attrib_tbl.next(l_po_attribute_index));
                             END IF;
                                                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                                                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                            MODULE   =>g_module_prefix||l_api_name,
                                            MESSAGE  =>'165: current l_po_var value'||l_po_attrib_tbl(l_po_attribute_index).variable_code);
                                                    END IF;
                       END IF;

             If l_po_attrib_tbl(l_po_attribute_index).variable_code =
                        p_sys_var_value_tbl(l_sys_var_index).variable_code then
                            IF g_fnd_debug = 'Y' then
                                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                                  FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                               MODULE   =>g_module_prefix||l_api_name,
                                               MESSAGE  =>'180: value found for'||l_po_attrib_tbl(l_po_attribute_index).variable_code);
                                END IF;
                            END IF;
                    p_sys_var_value_tbl(l_sys_var_index).variable_value_id :=
                        l_po_attrib_tbl(l_po_attribute_index).variable_value_id;
                   l_found:=true;
                   Exit;
             END IF;-- if l_po_attrib_tbl variable code found in p_sys_var-value_tbl
             l_po_attribute_index := l_po_attrib_tbl.next(l_po_attribute_index);
          END LOOP;-- l_po_attribute_index inner loop
          If NOT l_found then

              IF g_fnd_debug = 'Y' then
                             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                               FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                                            MODULE   =>g_module_prefix||l_api_name,
                                            MESSAGE  =>'190: Po does not have the variable code'||
                                                       p_sys_var_value_tbl(l_sys_var_index).variable_code);
                             END IF;
              END IF;


         End if;

       l_sys_var_index := p_sys_var_value_tbl.next(l_sys_var_index);

  END LOOP;-- l_sys_var_index outer loop
  IF g_fnd_debug = 'Y' then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                           MODULE   =>g_module_prefix||l_api_name,
                          MESSAGE  =>'220: Filtering ended. element in p_sys_var_value'||p_sys_var_value_tbl.count);
           END IF;

   l_sys_var_index := p_sys_var_Value_tbl.FIRST;
   While l_sys_var_index <= p_sys_var_value_tbl.last
   LOOP
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'240: current index' ||l_sys_var_index);
     END IF;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'250: column being sent'||p_sys_var_value_tbl(l_sys_var_index).variable_code);
     END IF;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'270: value being sent'||p_sys_var_value_tbl(l_sys_var_index).variable_value_id);
     END IF;
     l_sys_var_index := p_sys_var_value_tbl.next(l_sys_var_index);
  end loop;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'300: End API ' ||l_api_name);
     END IF;
 END IF;-- if fnd debug
EXCEPTION

  WHEN FND_API.G_EXC_ERROR then
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
          IF g_fnd_debug = 'Y' then
                  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                    FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                                 MODULE   =>g_module_prefix||l_api_name,
                                 MESSAGE  =>'400:Exception Expected error ');
                  END IF;
                  FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'610:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                 END LOOP;
          END IF;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
          IF g_fnd_debug = 'Y' then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                      FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                    MODULE   =>g_module_prefix||l_api_name,
                    MESSAGE  =>'410:Exception Expected error ');
                    END IF;
                    FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                             FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'410:errors '||FND_MSG_PUB.Get(p_msg_index=>i,p_encoded =>'F' ));
                           END IF;
                    END LOOP;

          END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PO_CONTERMS_UTILS_GRP',
		p_procedure_name  => l_api_name);
   END IF;   --msg level
   FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
   IF g_fnd_debug = 'Y' then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
          FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                       MODULE   =>g_module_prefix||l_api_name,
                       MESSAGE  =>'500:Exception UnExpected error '||sqlcode||':'||sqlerrm);
        END IF;
   END IF;
End Get_PO_Attribute_values;


-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Last_Signed_Revision
--Pre-reqs:
-- None
--Modifies:
-- None
--Locks:
-- None
--Function:
-- This API will be called by Contracts to get the last signed document revision
--Parameters:
--IN:
--p_api_version
-- Standard Parameter. API version number expected by the caller
--p_init_msg_list
-- Standard parameter.Initialize message list
--p_doc_type
--  OKC Document Type
--p_header_id
-- PO header id
--p_revision_num
-- Document Revision Number
--OUT:
--x_msg_count
-- Standard parameter.Message count
--x_msg_data
-- Standard parameter.message data
--x_return_status
-- Standard parameter. Status Returned to calling API. Possible values are following
-- FND_API.G_RET_STS_ERROR - for expected error
-- FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
-- FND_API.G_RET_STS_SUCCESS - for success
--x_signed_records
-- Returns 'Y' if there exists a Signed record. Otherwise returns 'N'
--Notes:
-- 09/23/2003 rbairraj
-- 1. This API has been written specifically for integration with contracts Before using it in any other place
--    Please diagnose the impact
--
--Testing:
-- Testing to be done based on the test cases in Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_Last_Signed_Revision (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_header_id              IN NUMBER,
  p_revision_num           IN NUMBER,
  x_signed_revision_num    OUT NOCOPY NUMBER,
  x_signed_records         OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'get_last_signed_revision';
  l_api_version CONSTANT NUMBER := 1.0;

  l_archived_conterms_flag PO_headers_all.conterms_exist_Flag%Type :='N';
  l_signed_revision_num    NUMBER;
  l_signed_records         VARCHAR2(1);

BEGIN


   IF NOT (FND_API.compatible_api_call(l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize API return status to success
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- initialize meesage list
   IF (FND_API.to_Boolean(p_init_msg_list)) THEN
       FND_MSG_PUB.initialize;
   END IF;

    PO_SIGNATURE_PVT.get_last_signed_revision(
                           p_po_header_id        => p_header_id,
                           p_revision_num        => p_revision_num,
                           x_signed_revision_num => l_signed_revision_num,
                           x_signed_records      => l_signed_records,
                           x_return_status       => x_return_status);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_signed_revision_num is not null THEN
     -- Migrate PO
     -- Check if this last signed revision has contract terms
     -- Before sending it to contracts
     BEGIN

        SELECT poha.conterms_exist_flag
        INTO   l_archived_conterms_flag
        FROM   po_headers_archive_all      poha
        WHERE  poha.po_header_id = p_header_id
        AND    poha.revision_num = l_signed_revision_num;

     EXCEPTION
        When no_data_found then
          l_archived_conterms_flag := 'N';
     END;

     IF NVL(l_archived_conterms_flag,'N') = 'Y' THEN
         x_signed_records := l_signed_records;
         x_signed_revision_num := l_signed_revision_num;
     ELSE
         x_signed_records := 'N';
         x_signed_revision_num := NULL;
     END IF;

   ELSE
       -- If the revision num is null return the out parameters as is
       x_signed_records := l_signed_records;
       x_signed_revision_num := l_signed_revision_num;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
     WHEN OTHERS THEN
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name
                         ,message   => SQLERRM);
           END IF;
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END Get_Last_Signed_Revision;

----------------------------------------------------------------------------------
--Start of Comments
--<11i10+ Auto Apply Contracts>
--Name: Auto_Apply_Conterms()
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is a wrapper to call the OKC API's to get the default template
--  and apply it to the current document type
--Parameters:
--IN:
--p_document_id
--  PO header ID
--p_document_type
--  PO Type lookup Code
--p_template_id
--  defaulted template id
--OUT:
--x_msg_count
--  Message count
--x_msg_data
--  message data
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Testing:
--
--End of Comments
------------------------------------------------------------------------------
PROCEDURE  Auto_Apply_ConTerms (
          p_document_id     IN  NUMBER,
          p_template_id     IN  NUMBER,
          x_return_status   OUT NOCOPY VARCHAR2) IS

l_api_name CONSTANT VARCHAR2(30)  := 'Auto_Apply_ConTerms';
l_log_head CONSTANT VARCHAR2(100) := g_log_head||l_api_name;

l_template_id      OKC_TERMS_TEMPLATES_ALL.template_id%TYPE;
l_template_name    OKC_TERMS_TEMPLATES_ALL.template_name%TYPE;
l_template_desc    OKC_TERMS_TEMPLATES_ALL.description%TYPE;
l_k_doc_type       VARCHAR2(240);
l_document_type    PO_HEADERS_ALL.type_lookup_code%TYPE;
l_doc_number       PO_HEADERS_ALL.segment1%TYPE;   -- Bug 4096095
l_agent_id         PO_HEADERS_ALL.agent_id%TYPE;   -- Bug 4096095
l_vendor_id        PO_HEADERS_ALL.vendor_id%TYPE;   -- Bug 4096095
l_vendor_site_id   PO_HEADERS_ALL.vendor_site_id%TYPE;   -- Bug 4096095
l_status           PO_HEADERS_ALL.authorization_status%TYPE;
l_conterms_flag    PO_HEADERS_ALL.conterms_exist_flag%TYPE;
l_revision         PO_HEADERS_ALL.revision_num%TYPE;
l_org_id           PO_HEADERS_ALL.org_id%TYPE;
l_msg_data         VARCHAR2(2000);
l_msg_count        NUMBER;

l_progress         NUMBER := 0;

BEGIN
     l_progress := 10;

     IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(l_log_head);
     END IF;

     l_progress := 20;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_progress := 25;
     IF g_contracts_enabled = 'N' OR
        g_auto_apply_template  = 'N'   THEN

       l_progress := 30;
       IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Auto Apply Template is off or contracts in not enabled');
          END IF;
       END IF;

       Return;
     END IF;

     l_progress := 35;
     IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
        || l_progress,'Derive parameters for OKC calls');
        END IF;
     END IF;

     -- SQL What: Get the document type ,segment1 and org id from the document
     --           that is passed in
     -- SQL Why:  These are required by the OKC calls to get and apply the
     --           default template
     Begin
        SELECT poh.type_lookup_code,
               poh.org_id,
               poh.segment1,  -- Bug 4096095
               nvl(poh.authorization_status,'INCOMPLETE'),
               poh.revision_num,
               poh.vendor_id,
               poh.vendor_site_id,
               poh.agent_id,
               poh.conterms_exist_flag
        INTO   l_document_type,
               l_org_id,
               l_doc_number,  -- Bug 4096095
               l_status,
               l_revision,
               l_vendor_id,
               l_vendor_site_id,
               l_agent_id,
               l_conterms_flag
        FROM   po_headers_all poh
        WHERE  poh.po_header_id = p_document_id;
     Exception
        When others then
         l_document_type := null;
         l_org_id := null;
     End;

     -- Check the Contract terms auto Apply profile option value
     IF  l_document_type not in ('STANDARD', 'BLANKET','CONTRACT') OR
         nvl(l_conterms_flag,'N') = 'Y' THEN

       l_progress := 40;
       IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'not the compatible doc type');
          END IF;
       END IF;

       Return;
     END IF;

     -- Create doc type code to be sent over to
     -- Contracts (consider doing a parameter)
     l_k_doc_type := get_po_contract_doctype(l_document_type);

     -- we make a call out to the OKC API to get the default
     -- template and apply . This API will attach the default
     -- template to the given PO header and sets the
     -- conterms_exists_flag through a call back API

     IF p_template_id is null THEN

       l_progress := 50;
       IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Call OKC API to get default template');
          END IF;
       END IF;

          OKC_TERMS_UTIL_GRP.GET_DEFAULT_TEMPLATE(
                                  p_api_version    =>	1.0,
                                  p_init_msg_list  => FND_API.G_TRUE,
                                  x_return_status  => x_return_status,
                                  x_msg_data       => l_msg_data,
                                  x_msg_count      => l_msg_count,
                                  p_document_type  => l_k_doc_type,
                                  p_org_id         => l_org_id,
                                  p_valid_date     => sysdate,
                                  x_template_id    => l_template_id,
                                  x_template_name  => l_template_name,
                                  x_template_description  => l_template_desc);

          IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress,'Return status from get default template:'||x_return_status );
            END IF;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

     ELSE
          l_progress := 60;
          IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
              || l_progress,'Default template passed in from the client side');
            END IF;
          END IF;

          l_template_id := p_template_id;
     END IF;

     IF l_template_id is not null     THEN

            l_progress := 70;
            IF g_debug_stmt THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                || l_progress,'Call the OKC API to apply terms');
              END IF;
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                || l_progress ,'Template: ' || l_template_id);
              END IF;
            END IF;

            -- Call the OKC API to apply the template
            -- Bug 4028805: Change '1.0' to 1.0 as api version should be a NUMBER.
            -- Bug 4096095: Passed in segment1 to the API
            OKC_TERMS_COPY_GRP.copy_terms(
                                 p_api_version   => 1.0,              --bug4028805
                                 x_return_status => x_return_status,
                                 x_msg_data      => l_msg_data,
                                 x_msg_count     => l_msg_count,
                                 p_commit        => FND_API.G_FALSE,
                                 p_template_id            => l_template_id,
                                 p_target_doc_type        => l_k_doc_type,
                                 p_target_doc_id          => p_document_id,
                                 p_document_number        => l_doc_number,  -- Bug 4096095
                                 p_internal_party_id      => l_org_id,      -- Bug 4096095
                                 p_external_party_id      => l_vendor_id,   -- Bug 4096095
                                 p_external_party_site_id => l_vendor_site_id,  -- Bug 4096095
                                 p_retain_deliverable     => 'N',
                                 p_internal_contact_id    => l_agent_id,
                                 p_article_effective_date => sysdate,
                                 p_validate_commit        => FND_API.G_TRUE,
                                 p_validation_string      => l_status ||','||l_revision||','|| null
                                );

            IF g_debug_stmt THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
              || l_progress,'Return status from copy terms:'||x_return_status );
              END IF;
            END IF;
      ELSE
         -- Do not apply any terms if the template is null
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

  l_progress := 80;
  IF g_debug_stmt THEN
     PO_DEBUG.debug_end(l_log_head);
  END IF;

Exception
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_and_Get(p_count => l_msg_count
                              ,p_data  => l_msg_data);
     WHEN OTHERS THEN
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(log_level => FND_LOG.level_unexpected
                         ,module    => g_module_prefix ||l_api_name
                         ,message   => SQLERRM);
           END IF;
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => l_msg_count
                              ,p_data  => l_msg_data);
End Auto_Apply_ConTerms;


----------------------------------------------------------------------------------
--Start of Comments
--<Auto Apply Contracts>
--Name: get_def_proc_contract_info()
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is a wrapper to call the OKC API's to get the default template
--Parameters:
--IN:
--p_doc_subtype
--  PO Doc Subtype
--p_org_id
--  Org Id
--p_conterms_exist_flag
--  Flag indicating if conterms exists
--OUT:
--x_template_id
--  defaulted template id
--x_template_name
--  defaulted template name
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Testing:
--
--End of Comments
------------------------------------------------------------------------------
PROCEDURE get_def_proc_contract_info  (
	              p_doc_subtype     IN  VARCHAR2,
	              p_org_id          IN NUMBER,
	              p_conterms_exist_flag IN VARCHAR2,
	              x_template_id     OUT NOCOPY VARCHAR2,
	              x_template_name   OUT NOCOPY VARCHAR2,
                      x_authoring_party   OUT NOCOPY VARCHAR2,
	              x_return_status   OUT NOCOPY VARCHAR2) IS

   l_api_name   CONSTANT VARCHAR2 (30)        := 'get_def_proc_contract_info';
   l_log_head   CONSTANT VARCHAR2 (100)           := g_log_head || l_api_name;
   l_template_desc       okc_terms_templates_all.description%TYPE;
   l_contract_source     VARCHAR2(2000);
   l_k_doc_type          VARCHAR2 (240);
   l_msg_data            VARCHAR2 (2000);
   l_msg_count           NUMBER;
   l_progress            NUMBER   := 0;
BEGIN
	   l_progress := 10;

	   IF g_debug_stmt
	   THEN
	      po_debug.debug_begin (l_log_head);
	   END IF;

	   l_progress := 20;
	   --  Initialize API return status to success
	   x_return_status := fnd_api.g_ret_sts_success;
	   l_progress := 25;

	   IF g_contracts_enabled = 'N' OR g_auto_apply_template = 'N'
	   THEN
	      l_progress := 30;

	      IF g_debug_stmt
	      THEN
	         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	           fnd_log.STRING (fnd_log.level_statement,
	                          g_log_head || '.' || l_api_name || '.' || l_progress,
	                         'Auto Apply Template is off or contracts in not enabled'
	                        );
	         END IF;
	      END IF;

	      RETURN;
	   END IF;

	   -- Check the Contract terms auto Apply profile option value
	   IF    p_doc_subtype NOT IN ('STANDARD', 'BLANKET', 'CONTRACT')
	      OR NVL (p_conterms_exist_flag, 'N') = 'Y'
	   THEN
	      l_progress := 40;

	      IF g_debug_stmt
	      THEN
	         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	           fnd_log.STRING (fnd_log.level_statement,
	                          g_log_head || '.' || l_api_name || '.' || l_progress,
	                         'not the compatible doc type'
	                        );
	         END IF;
	      END IF;

	      RETURN;
	   END IF;

	   -- Create doc type code to be sent over to
	   -- Contracts (consider doing a parameter)
	   l_k_doc_type := get_po_contract_doctype(p_doc_subtype);

	   -- we make a call out to the OKC API to get the default
	   -- template.
	   l_progress := 50;

	   IF g_debug_stmt
	   THEN
	      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	        fnd_log.STRING (fnd_log.level_statement,
	                       g_log_head || '.' || l_api_name || '.' || l_progress,
	                      'Call OKC API to get default template'
	                     );
	      END IF;
	   END IF;

	   okc_terms_util_grp.get_default_template (
	                             p_api_version               => 1.0,
	                             p_init_msg_list             => fnd_api.g_true,
	                             x_return_status             => x_return_status,
	                             x_msg_data                  => l_msg_data,
	                             x_msg_count                 => l_msg_count,
	                             p_document_type             => l_k_doc_type,
	                             p_org_id                    => p_org_id,
	                             p_valid_date                => SYSDATE,
	                             x_template_id               => x_template_id,
	                             x_template_name             => x_template_name,
	                             x_template_description      => l_template_desc
	                                           );

	   IF g_debug_stmt
	   THEN
	      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	        fnd_log.STRING (fnd_log.level_statement,
	                       g_log_head || '.' || l_api_name || '.' || l_progress,
	                          'Return status from get default template:'
	                       || x_return_status
	                     );
	      END IF;
	   END IF;

	   IF x_return_status <> fnd_api.g_ret_sts_success
	   THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

	   IF x_template_id IS NOT NULL
	   THEN
	      okc_terms_util_grp.get_contract_defaults (
	                             p_api_version               => 1.0,
	                             p_init_msg_list             => fnd_api.g_true,
	                             x_return_status             => x_return_status,
	                             x_msg_data                  => l_msg_data,
	                             x_msg_count                 => l_msg_count,
	                             p_template_id               => x_template_id,
	                             p_document_type             => l_k_doc_type,
	                             x_authoring_party           => x_authoring_party,
	                             x_contract_source           => l_contract_source,
	                             x_template_name             => x_template_name,
	                             x_template_description      => l_template_desc
	                                               );

	      IF x_return_status <> fnd_api.g_ret_sts_success
	      THEN
	         RAISE fnd_api.g_exc_unexpected_error;
	      END IF;
	   END IF;

	   l_progress := 60;

	   IF g_debug_stmt
	   THEN
	      po_debug.debug_end (l_log_head);
	   END IF;
EXCEPTION
	   WHEN fnd_api.g_exc_unexpected_error
	   THEN
	      x_return_status := fnd_api.g_ret_sts_unexp_error;
	      fnd_msg_pub.count_and_get (p_count      => l_msg_count,
	                                 p_data       => l_msg_data);
	   WHEN OTHERS
	   THEN
	      x_return_status := fnd_api.g_ret_sts_unexp_error;

	      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
	      THEN
	         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

	         IF (g_fnd_debug = 'Y')
	         THEN
	            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	              fnd_log.STRING (log_level      => fnd_log.level_unexpected,
	                            module         => g_module_prefix || l_api_name,
	                            MESSAGE        => SQLERRM
	                           );
	            END IF;
	         END IF;
	      END IF;

	      fnd_msg_pub.count_and_get (p_count      => l_msg_count,
	                                 p_data       => l_msg_data);
END get_def_proc_contract_info;

----------------------------------------------------------------------------------
--Start of Comments
--<R12 Procurement Contracts Integration>
--Name: Get_Contract_Details()
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure is a wrapper to call the OKC API's to get contract details
--Parameters:
--IN:
--p_doc_subtype
--  PO Doc Subtype
--p_document_id
--  PO Header ID
--OUT:
--x_template_name
--  template name
--x_authoring_party
--  authoring party
--x_return_status
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--Testing:
--
--End of Comments
------------------------------------------------------------------------------
Procedure Get_Contract_Details(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_doc_type              IN  VARCHAR2,
    p_doc_subtype           IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    x_authoring_party       OUT NOCOPY VARCHAR2,
    x_template_name         OUT NOCOPY VARCHAR2
) IS

  l_api_version              CONSTANT NUMBER := 1;
  l_api_name                 CONSTANT VARCHAR2 (30) := 'Get_Contract_Details';
  l_log_head                 CONSTANT VARCHAR2 (100) := g_log_head || l_api_name;
  l_template_desc            okc_terms_templates_all.description%TYPE;
  l_contract_source          VARCHAR2(2000);
  l_k_doc_type               VARCHAR2(240);
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_progress                 NUMBER   := 0;
  l_template_name_none_msg   okc_terms_templates_all.template_name%TYPE;
  l_authoring_party_none_msg okc_template_usages.authoring_party_code%TYPE;
BEGIN


  -- Check that the doc subtype is allowed.
  IF p_doc_subtype NOT IN ('STANDARD', 'BLANKET', 'CONTRACT')
  THEN
    l_progress := 20;
      IF g_debug_stmt
      THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	  fnd_log.STRING (fnd_log.level_statement,
	                g_log_head || '.' || l_api_name || '.' || l_progress,
	                'not the compatible doc type'
	                );
	END IF;
      END IF;

  RETURN;
  END IF;

  l_k_doc_type := get_po_contract_doctype(p_doc_subtype);

  -- we make a call out to the OKC API to get the default
  -- template.
  l_progress := 10;

  IF g_debug_stmt
  THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       fnd_log.STRING (fnd_log.level_statement,
                     g_log_head || '.' || l_api_name || '.' || l_progress,
                     'Call OKC API to get contract details'
                    );
     END IF;
  END IF;

  OKC_TERMS_UTIL_GRP.Get_Contract_Details(
    p_api_version           => l_api_version,
    p_init_msg_list         => FND_API.G_TRUE,
    x_return_status         => x_return_status,
    x_msg_data              => l_msg_data,
    x_msg_count             => l_msg_count,
    p_document_type         => l_k_doc_type,
    p_document_id           => p_document_id,
    x_authoring_party       => x_authoring_party,
    x_contract_source       => l_contract_source,
    x_template_name         => x_template_name,
    x_template_description  => l_template_desc
  );

  l_progress := 20;

  IF g_debug_stmt
  THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       fnd_log.STRING (fnd_log.level_statement,
                      g_log_head || '.' || l_api_name || '.' || l_progress,
                      'Return status from get contract details:'
                      || x_return_status
                    );
     END IF;
  END IF;

  IF x_return_status <> fnd_api.g_ret_sts_success
  THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Bug 4691053
  -- Override template name and authoring party names to be null in case
  -- contract terms do not exist.

  fnd_message.set_name('OKC','OKC_TERMS_TEMPLATE_NAME_NONE');
  l_template_name_none_msg:= fnd_message.get;

  IF x_template_name = l_template_name_none_msg THEN
    x_template_name := NULL;
  END IF;

  fnd_message.set_name('OKC','OKC_TERMS_AUTH_PARTY_NONE');
  l_authoring_party_none_msg := fnd_message.get;

  IF x_authoring_party = l_authoring_party_none_msg THEN
    x_authoring_party := NULL;
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                p_data       => l_msg_data);
  WHEN OTHERS
  THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

        IF (g_fnd_debug = 'Y')
        THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             fnd_log.STRING (log_level      => fnd_log.level_unexpected,
                           module         => g_module_prefix || l_api_name,
                           MESSAGE        => SQLERRM
                          );
           END IF;
        END IF;
     END IF;

     fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                p_data       => l_msg_data);
END Get_Contract_Details;

----------------------------------------------------------------------------------
--Start of Comments
--<FP CU2-R12 : Migrate PO>
--Name: get_archive_conterms_flag()
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function checks if the latest archived version has conterms
--Parameters:
--IN:
--p_document_id
--  PO header ID
--Testing:
--
--End of Comments
------------------------------------------------------------------------------
FUNCTION get_archive_conterms_flag (p_po_header_id  IN NUMBER)
RETURN VARCHAR2 IS

l_archived_conterms_flag PO_headers_all.conterms_exist_Flag%Type :='N';

BEGIN

  -- SQL What: Query to check if the last archived version had conterms
  -- SQL Why: To check if the conterms were applied to the last archived rev
  SELECT nvl(poha.conterms_exist_flag,'N')
  INTO   l_archived_conterms_flag
  FROM   po_headers_archive_all      poha
  WHERE  poha.po_header_id = p_po_header_id
  AND  poha.latest_external_flag = 'Y';

  Return l_archived_conterms_flag;

EXCEPTION
   -- Never Archived
   When no_data_found  THEN
     l_archived_conterms_flag := 'X';

END get_archive_conterms_flag;

END PO_CONTERMS_UTL_GRP;

/
