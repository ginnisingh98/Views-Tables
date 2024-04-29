--------------------------------------------------------
--  DDL for Package Body PO_VENDORS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORS_GRP" AS
/* $Header: POXGVENB.pls 120.2 2005/12/14 14:52:27 bao noship $ */
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
--  This procedure is built as a wrapper over procedure get_supplier_userlist
--  in the package PO_VENDORS_PVT to be allowed to be called by other apps.
--  This procedure is called by external apps team to determine the supplier users
--  to send notifications to.
--Parameters:
--IN:
--p_document_id
--  PO header ID
--p_document_type
--  Contracts business document type ex: PA_BLANKET or PO_STANDARD
--  This will be parsed to retrieve the PO document type
--p_external_contact_id
--  Supplier contact id on the deliverable. Default is null.
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
--x_external_user_tbl
--  PL/SQL table of supplier user names
--Notes:
--  SAHEGDE 07/18/2003
--  This procedure calls get_supplier_userlist in PO_VENDORS_PVT to
--  retrieve supplier user names as VARCHAR2 as well as PL/SQL table, besides
--  other OUT parameters. Going forward, signature of the get_supplier_userlist
--  might change to return only PL/SQL table. The callout then will need to
--  accomodate this change. This however will not change the GRP API signature.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER
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
  l_api_version CONSTANT NUMBER := 1.0;
  l_document_type po_headers.type_lookup_code%TYPE;
  l_supplier_userlist_for_sql VARCHAR2(32000) := NULL;
  l_num_users NUMBER := 0;
  l_supplier_userlist VARCHAR2(31990);
  l_vendor_id NUMBER;
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


   -- parse doc type if contracts document type
   IF (p_document_type IN ('PO_STANDARD', 'PA_BLANKET', 'PA_CONTRACT')) THEN
     l_document_type := SUBSTR(p_document_type, 1, 2);
   ELSE
     l_document_type := p_document_type;
   END IF;

   -- call procedure to fetch supplier user list.
   po_vendors_pvt.get_supplier_userlist(
                         p_document_id               => p_document_id
                        ,p_document_type             => l_document_type
			,p_external_contact_id       => p_external_contact_id
                        ,x_return_status             => l_return_status
                        ,x_supplier_user_tbl         => l_external_user_tbl
                        ,x_supplier_userlist         => l_supplier_userlist
                        ,x_supplier_userlist_for_sql => l_supplier_userlist_for_sql
                        ,x_num_users                 => l_num_users
                        ,x_vendor_id                 => l_vendor_id);


   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- populate the out parameter.
   x_external_user_tbl := l_external_user_tbl;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(FND_LOG.level_unexpected
                         ,g_module_prefix ||l_api_name
                         ,SQLERRM);
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
--  This procedure is built as a wrapper over procedure get_supplier_userlist
--  in the package PO_VENDORS_PVT to be allowed to be called by other apps.
--  This procedure overloaded to return additional data elements required by
--  one of its caller po_reapproval_inti1.locate_notifier
--Parameters:
--IN:
--p_document_id
--  PO header ID
--p_document_type
--  Contracts business document type ex: PA_BLANKET or PO_STANDARD
--  This will be parsed to retrieve the PO document type
--p_external_contact_id
--  Supplier contact id on the deliverable. Default is null.
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
--x_external_user_tbl
--  PL/SQL table of supplier user names
--x_supplier_userlist
--  space delimited user list
--x_supplier_userlist_for_sql
--  comma delimited user list
--x_num_users
--  number of users
--x_vendor_id
--  vendor id on the PO
--Notes:
--  SAHEGDE 07/18/2003
--  This procedure calls get_supplier_userlist in PO_VENDORS_PVT to
--  retrieve supplier user names as VARCHAR2 as well as PL/SQL table, besides
--  other OUT parameters. Going forward, signature of the get_supplier_userlist
--  might change to return only PL/SQL table. The callout then will need to
--  accomodate this change. This however will not change the GRP API signature.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_user_tbl         OUT NOCOPY external_user_tbl_type
          ,x_supplier_userlist         OUT NOCOPY VARCHAR2
          ,x_supplier_userlist_for_sql OUT NOCOPY VARCHAR2
          ,x_num_users                 OUT NOCOPY NUMBER
          ,x_vendor_id                 OUT NOCOPY NUMBER) IS

  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'get_external_userlist';
  l_api_version CONSTANT NUMBER := 1.0;
  l_document_type po_headers.type_lookup_code%TYPE;
  l_supplier_userlist_for_sql VARCHAR2(32000) := NULL;
  l_num_users NUMBER := 0;
  l_supplier_userlist VARCHAR2(31990);
  l_vendor_id NUMBER;
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

   -- parse doc type if contracts document type
   IF (p_document_type IN ('PO_STANDARD', 'PA_BLANKET', 'PA_CONTRACT')) THEN
     l_document_type := SUBSTR(p_document_type, 1, 2);
   ELSE
     l_document_type := p_document_type;
   END IF;

   -- call procedure to fetch supplier user list.
   po_vendors_pvt.get_supplier_userlist(
                         p_document_id               => p_document_id
                        ,p_document_type             => l_document_type
			,p_external_contact_id       => p_external_contact_id
                        ,x_return_status             => l_return_status
                        ,x_supplier_user_tbl         => l_external_user_tbl
                        ,x_supplier_userlist         => l_supplier_userlist
                        ,x_supplier_userlist_for_sql => l_supplier_userlist_for_sql
                        ,x_num_users                 => l_num_users
                        ,x_vendor_id                 => l_vendor_id);


   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- populate the out parameter.
   x_external_user_tbl := l_external_user_tbl;
   x_supplier_userlist := l_supplier_userlist;
   x_supplier_userlist_for_sql := l_supplier_userlist_for_sql;
   x_num_users := l_num_users;
   x_vendor_id := l_vendor_id;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
         IF (g_fnd_debug='Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(FND_LOG.level_unexpected
                         ,g_module_prefix ||l_api_name
                         ,SQLERRM);
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
END get_external_userlist;

END PO_VENDORS_GRP;

/
