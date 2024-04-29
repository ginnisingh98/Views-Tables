--------------------------------------------------------
--  DDL for Package Body PO_SIGNATURE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SIGNATURE_GRP" AS
/* $Header: POXGSIGB.pls 120.1 2005/06/29 18:44:55 shsiung noship $ */

-------------------------------------------------------------------------------
--Start of Comments
--Name: Update_Po_Details
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Updates PO tables
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_status
--  Indicates if the Document is 'ACCEPTED' or 'REJECTED' while signing
--p_action_code
--  Action code to be inserted in PO_ACTION_HISTORY table.
--  Valid values 'SIGNED', 'BUYER REJECTED', 'SUPPLIER REJECTED'
--p_object_type_code
--  Document type - 'PO', 'PA' etc
--p_object_subtype_code
--  Document Subtype - 'STANDARD', 'CONTRACT', 'BLANKET' etc
--p_employee_id
--  Employee Id of the Buyer
--p_revision_num
--  Revision Number of the document
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

--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE Update_Po_Details(p_api_version         IN NUMBER, -- bug3488839
                            p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                            p_po_header_id        IN NUMBER,
                            p_status              IN VARCHAR2,
                            p_action_code         IN VARCHAR2,
                            p_object_type_code    IN VARCHAR2,
                            p_object_subtype_code IN VARCHAR2,
                            p_employee_id         IN NUMBER,
                            p_revision_num        IN NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2) IS
  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'update_po_details';
  l_api_version CONSTANT NUMBER := 1.0;  -- bug3488839

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

   PO_SIGNATURE_PVT.update_po_details(
                            p_po_header_id        => p_po_header_id,
                            p_status              => p_status,
                            p_action_code         => p_action_code,
                            p_object_type_code    => p_object_type_code,
                            p_object_subtype_code => p_object_subtype_code,
                            p_employee_id         => p_employee_id,
                            p_revision_num        => p_revision_num);

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
END update_po_details;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_ITEM_KEY
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Creates and Returns item key for the Document Signature Process
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--p_document_type
--  Document type - 'PO', 'PA' etc
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
--x_itemkey
--  Item key of the Document Signature Process
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE Get_Item_Key(p_api_version   IN NUMBER, -- bug3488839
                       p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                       p_po_header_id  IN  NUMBER,
                       p_revision_num  IN  NUMBER,
                       p_document_type IN  VARCHAR2,
                       x_itemkey       OUT NOCOPY VARCHAR2,
                       x_result        OUT NOCOPY VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                       x_msg_data      OUT NOCOPY VARCHAR2) IS


  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'get_item_key';
  l_api_version CONSTANT NUMBER := 1.0; -- bug3488839

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

   PO_SIGNATURE_PVT.get_item_key(
                       p_po_header_id  => p_po_header_id,
                       p_revision_num  => p_revision_num,
                       p_document_type => p_document_type,
                       x_itemkey       => x_itemkey,
                       x_result        => x_result);

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
END get_item_key;

-------------------------------------------------------------------------------
--Start of Comments
--Name: FIND_ITEM_KEY
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Returns item key of the active Document Signature Process
--Parameters:
--IN:
--p_po_header_id
--  PO_HEADER_ID
--p_revision_num
--  Revision Number of the document
--p_document_type
--  Document type - 'PO', 'PA' etc
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
--x_itemkey
--  Item key of the active Document Signature Process
--x_result
--  Returns 'S' for success and 'E' for Error
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE find_item_key(p_api_version   IN NUMBER,  -- bug3488839
                        p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                        p_po_header_id  IN  NUMBER,
                        p_revision_num  IN  NUMBER,
                        p_document_type IN  VARCHAR2,
                        x_itemkey       OUT NOCOPY VARCHAR2,
                        x_result        OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2) IS


  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'find_item_key';
  l_api_version CONSTANT NUMBER := 1.0; -- bug3488839

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

   PO_SIGNATURE_PVT.find_item_key(
                        p_po_header_id  => p_po_header_id,
                        p_revision_num  => p_revision_num,
                        p_document_type => p_document_type,
                        x_itemkey       => x_itemkey,
                        x_result        => x_result);

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
END find_item_key;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Abort_Doc_Sign_Process
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Once signatures are complete aborts the Document Signature Process
--Parameters:
--IN:
--p_itemkey
--  Item key of the PO Approval workflow Document Signature Process
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
--x_result
--  Returns 'S' for success and 'E' for Error
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE abort_doc_sign_process(p_api_version   IN NUMBER, -- bug3488839
                                 p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                                 p_itemkey       IN  VARCHAR2,
                                 x_result        OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2) IS

  -- local variables
  l_api_name         CONSTANT VARCHAR2(30)  := 'abort_doc_sign_process';
  l_api_version      CONSTANT NUMBER   := 1.0;  -- bug3488839


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

   PO_SIGNATURE_PVT.Abort_Doc_Sign_Process(
                                 p_itemkey => p_itemkey,
                                 x_result  => x_result);

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

END abort_doc_sign_process;
-------------------------------------------------------------------------------
--Start of Comments
--Name: ERECORDS_ENABLED
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  If eRecords patch is applied and eRecords is enabled returns 'Y'
--  else returns 'N'
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
--x_erecords_enabled
--  Returns 'Y' if eRecords patch is applied and eRecords is enabled.
--  Otherwise returns 'N'.
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE erecords_enabled(p_api_version       IN NUMBER, -- bug3488839
                           p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
                           x_erecords_enabled  OUT NOCOPY VARCHAR2,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2) IS

  -- local variables
  l_api_name         CONSTANT VARCHAR2(30)  := 'erecords_enabled';
  l_api_version      CONSTANT NUMBER        := 1.0; -- bug3488839


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

   PO_ERECORDS_PVT.erecords_enabled(
                             x_erecords_enabled => x_erecords_enabled);

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

END erecords_enabled;

END PO_SIGNATURE_GRP;

/
