--------------------------------------------------------
--  DDL for Package Body PO_SOURCING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING_GRP" AS
/* $Header: POXGCPAB.pls 120.0 2005/06/02 00:57:38 appldev noship $*/


---
--- +=======================================================================+
--- |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
--- |                         All rights reserved.                          |
--- +=======================================================================+
--- |
--- | FILENAME
--- |     POXGCPAB.pls
--- |
--- |
--- | DESCRIPTION
--- |
--- |     This package contains procedures called from the sourcing
--- |     to create CPA in PO
--- |
--- | HISTORY
--- |
--- |     30-Sep-2004 rbairraj   Initial version
--- |
--- +=======================================================================+
---

--------------------------------------------------------------------------------

g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_SOURCING_GRP';
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
g_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_SOURCING_GRP.';

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_cpa
--Pre-reqs:
--  None
--Modifies:
--  Transaction tables for the requested document
--Locks:
--  None.
--Function:
--  Creates Contract Purchase Agreement from Sourcing document
--Parameters:
--IN:
--p_api_version
--  API standard IN parameter
--p_init_msg_list
--  True/False parameter to initialize message list
--p_commit
--  Standard parameter which dictates whether or not data should be commited in the api
--p_validation_level
--  The p_validation_level parameter to determine which validation steps should
--  be executed and which steps should be skipped
--p_interface_header_id
--  The id that will be used to uniquely identify a row in the PO_HEADERS_INTERFACE table
--p_auction_header_id
--  Id of the negotiation
--p_bid_number
--  Bid Number for which is negotiation is awarded
--p_sourcing_k_doc_type
--   Represents the OKC document type that would be created into a CPA
--   The document type that Sourcing has seeded in Contracts.
--p_conterms_exist_flag
--   Whether the sourcing document has contract template attached.
--p_document_creation_method
--   Column specific to DBI. Sourcing will pass a value of AWARD_SOURCING
--OUT:
--x_document_id
--   The unique identifier for the newly created document.
--x_document_number
--   The document number that would uniquely identify a document in a given organization.
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_ERROR - for expected error
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--x_msg_count
--   The count of number of messages added to the message list in this call
--x_msg_data
--   If the count is 1 then x_msg_data contains the message returned
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_cpa (
    p_api_version                IN               NUMBER,
    p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN               NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT    NOCOPY    VARCHAR2,
    x_msg_count                  OUT    NOCOPY    NUMBER,
    x_msg_data                   OUT    NOCOPY    VARCHAR2,
    p_interface_header_id        IN               PO_HEADERS_INTERFACE.interface_header_id%TYPE,
    p_auction_header_id          IN               PON_AUCTION_HEADERS_ALL.auction_header_id%TYPE,
    p_bid_number                 IN               PON_BID_HEADERS.bid_number%TYPE,
    p_sourcing_k_doc_type        IN               VARCHAR2,
    p_conterms_exist_flag        IN               PO_HEADERS_ALL.conterms_exist_flag%TYPE,
    p_document_creation_method   IN               PO_HEADERS_ALL.document_creation_method%TYPE,
    x_document_id                OUT    NOCOPY    PO_HEADERS_ALL.po_header_id%TYPE,
    x_document_number            OUT    NOCOPY    PO_HEADERS_ALL.segment1%TYPE
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_CPA';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_progress            VARCHAR2(2000) := '000';
    l_return_status       VARCHAR2(1);

BEGIN
    l_progress := 'PO_SOURCING_GRP: 001';
    IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => l_progress,
                             p_message  => 'PO_SOURCING_GRP: Entered');
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_api_version',
                             p_value    => p_api_version);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_init_msg_list',
                             p_value    => p_init_msg_list);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_commit',
                             p_value    => p_commit);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_validation_level',
                             p_value    => p_validation_level);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_interface_header_id',
                             p_value    => p_interface_header_id);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_auction_header_id',
                             p_value    => p_auction_header_id);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_bid_number',
                             p_value    => p_bid_number);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_sourcing_k_doc_type',
                             p_value    => p_sourcing_k_doc_type);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_conterms_exist_flag',
                             p_value    => p_conterms_exist_flag);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'p_document_creation_method',
                             p_value    => p_document_creation_method);
    END IF;

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CPA_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => g_pkg_name
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := 'PO_SOURCING_GRP: 002';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                          p_token    => l_progress,
                          p_message  => 'Before calling po_sourcing_pvt.create_cpa');
    END IF;

   PO_SOURCING_PVT.create_cpa (
                      x_return_status              => x_return_status,
                      x_msg_count                  => x_msg_count,
                      x_msg_data                   => x_msg_data,
                      p_interface_header_id        => p_interface_header_id,
                      p_auction_header_id          => p_auction_header_id,
                      p_bid_number                 => p_bid_number,
                      p_sourcing_k_doc_type        => p_sourcing_k_doc_type,
                      p_conterms_exist_flag        => p_conterms_exist_flag,
                      p_document_creation_method   => p_document_creation_method,
                      x_document_id                => x_document_id,
                      x_document_number            => x_document_number
                      );

    l_progress := 'PO_SOURCING_GRP: 003';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                          p_token    => l_progress,
                          p_message  => 'After calling po_sourcing_pvt.create_cpa');
    END IF;

    l_progress := 'PO_SOURCING_GRP: 004';
    IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                             p_token    => l_progress,
                             p_message  => 'PO_SOURCING_GRP: After calling PO_SOURCING_PVT.create_cpa');
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'x_document_id',
                             p_value    => x_document_id);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'x_document_number',
                             p_value    => x_document_number);
         PO_DEBUG.debug_var (p_log_head => g_log_head||l_api_name,
                             p_progress => l_progress,
                             p_name     => 'x_return_status',
                             p_value    => x_return_status);
    END IF;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

  	--Commit the data if p_commit is passed to the API is true
   	IF p_commit = FND_API.G_TRUE THEN
       COMMIT;
     END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     l_progress := 'PO_SOURCING_GRP: 004';
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                            p_token    => l_progress,
                            p_message  => x_msg_data);
     END IF;
     FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );
         ROLLBACK TO CREATE_CPA_GRP;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     l_progress := 'PO_SOURCING_GRP: 005';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF g_debug_unexp THEN
            PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                p_token    => l_progress,
                                p_message  => SQLERRM);
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
     ROLLBACK TO CREATE_CPA_GRP;
   WHEN OTHERS THEN
     l_progress := 'PO_SOURCING_GRP: 006';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF g_debug_unexp THEN
            PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                p_token    => l_progress,
                                p_message  => SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_GRP',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);

     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
     ROLLBACK TO CREATE_CPA_GRP;
END create_cpa;

-------------------------------------------------------------------------------
--Start of Comments
--Name: DELETE_INTERFACE_HEADER
--Pre-reqs:
--  None
--Modifies:
--  po_headers_interface
--Locks:
--  None.
--Function:
--  This deletes the interface header row from interface table
--Parameters:
--IN:
--p_api_version
--  API standard IN parameter
--p_init_msg_list
--  True/False parameter to initialize message list
--p_commit
--  Standard parameter which dictates whether or not data should be commited in the api
--p_validation_level
--  The p_validation_level parameter to determine which validation steps should
--  be executed and which steps should be skipped
--p_interface_header_id
--  The id that will be used to uniquely identify a row in the PO_HEADERS_INTERFACE table
--OUT:
--x_return_status
--   The standard OUT parameter giving return status of the API call.
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--  FND_API.G_RET_STS_SUCCESS - for success
--x_msg_count
--   The count of number of messages added to the message list in this call
--x_msg_data
--   If the count is 1 then x_msg_data contains the message returned
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE DELETE_INTERFACE_HEADER (
    p_api_version                IN               NUMBER,
    p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN               NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT    NOCOPY    VARCHAR2,
    x_msg_count                  OUT    NOCOPY    NUMBER,
    x_msg_data                   OUT    NOCOPY    VARCHAR2,
    p_interface_header_id        IN  PO_HEADERS_INTERFACE.INTERFACE_HEADER_ID%TYPE
) IS
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_INTERFACE_HEADER';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_progress            VARCHAR2(2000) := '000';

BEGIN
    l_progress := 'PO_SOURCING_GRP.DELETE_INTERFACE_HEADER: 001';
    -- Standard call to check for call compatibility.
    IF NOT FND_API.compatible_api_call (
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => g_pkg_name
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := 'PO_SOURCING_GRP.DELETE_INTERFACE_HEADER: 002';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                          p_token    => l_progress,
                          p_message  => 'Before calling po_sourcing_pvt.delete_interface_header');
    END IF;

   PO_SOURCING_PVT.DELETE_INTERFACE_HEADER (
                               x_return_status           => x_return_status,
                               p_interface_header_id     => p_interface_header_id
                               );

    l_progress := 'PO_SOURCING_GRP.DELETE_INTERFACE_HEADER: 003';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                          p_token    => l_progress,
                          p_message  => 'After calling po_sourcing_pvt.delete_interface_header');
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    l_progress := 'PO_SOURCING_GRP.DELETE_INTERFACE_HEADER: 004';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF g_debug_unexp THEN
            PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                p_token    => l_progress,
                                p_message  => x_msg_data);
         END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
   WHEN OTHERS THEN
    l_progress := 'PO_SOURCING_GRP.DELETE_INTERFACE_HEADER: 005';
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF g_debug_unexp THEN
            PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
                                p_token    => l_progress,
                                p_message  => SQLERRM);
     END IF;
     FND_MSG_PUB.add_exc_msg(
               p_pkg_name       => 'PO_SOURCING_GRP',
               p_procedure_name => l_api_name,
               p_error_text     => NULL);

     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END DELETE_INTERFACE_HEADER;

END PO_SOURCING_GRP;

/
