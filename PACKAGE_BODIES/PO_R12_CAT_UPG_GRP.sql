--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_GRP" AS
/* $Header: PO_R12_CAT_UPG_GRP.plb 120.2 2006/05/31 19:03:59 vkartik noship $ */

g_debug BOOLEAN := FALSE;

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_GRP';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

--------------------------------------------------------------------------------
--Start of Comments
--Name: upgrade_existing_docs
--Pre-reqs:
--  The datamodel changes for Unified Catlog Upgrade should have been applied.
--Modifies:
--  a) PO Transaction tables (headers, lines, attributes, TLP,
--                            po_reqexpress_lines_all, po_approved_supplier_list)
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  PASS 1: Migrate existing agreeements(and quotations)/Req templates.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be committed?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_log_level
--  Specifies the level for which logging is enabled.
--p_batch_size
--  The maximum number of rows that should be processed at a time, to avoid
--  exceeding rollback segment. The transaction would be committed after
--  processing each batch.
--OUT:
--x_return_status
-- Apps API Std
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_msg_count
-- Apps API Std
-- The number of error messages returned in the FND error stack in case
-- x_return_status returned FND_API.G_RET_STS_ERROR or
-- FND_API.G_RET_STS_UNEXP_ERROR
--x_msg_data
-- Apps API Std
--  Contains error msg in case x_return_status returned FND_API.G_RET_STS_ERROR
--  or FND_API.G_RET_STS_UNEXP_ERROR
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE upgrade_existing_docs
(
   p_api_version      IN NUMBER
,  p_commit           IN VARCHAR2 default FND_API.G_FALSE
,  p_init_msg_list    IN VARCHAR2 default FND_API.G_FALSE
,  p_validation_level IN NUMBER default FND_API.G_VALID_LEVEL_FULL
,  p_log_level        IN NUMBER default 1
,  p_batch_size       IN NUMBER default 2500
,  x_return_status    OUT NOCOPY VARCHAR2
,  x_msg_count        OUT NOCOPY NUMBER
,  x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'upgrade_existing_docs';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_module        CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
  l_return_status VARCHAR2(1);
BEGIN
  l_progress := '010';

  -- Set logging options
  PO_R12_CAT_UPG_DEBUG.set_logging_options(p_log_level => p_log_level);
  g_debug := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'START'); END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_API_call(
                        p_current_version_number => l_api_version,
                        p_caller_version_number  => p_api_version,
                        p_api_name               => l_api_name,
                        p_pkg_name               => g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '020';
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_progress := '030';
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  l_progress := '040';
  -- Call the main procedure for upgrading existing documents
  PO_R12_CAT_UPG_EXISTING_DOCS.upgrade_existing_docs(
                      p_batch_size    => p_batch_size
                    , x_return_status => x_return_status);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'Migration failed.'); END IF;
  END IF; -- IF (l_return_status = FND_API.G_RET_STS_SUCCESS)

  l_progress := '050';
  -- Standard check of p_commit.
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  l_progress := '110';
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'END'); END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'EXPECTED Start'); END IF;
    x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data );
    IF g_debug THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status);
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'EXPECTED End');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'UNEXPECTED Start'); END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data );
    IF g_debug THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status);
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'UNEXPECTED End');
    END IF;

  WHEN OTHERS THEN
   BEGIN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'OTHERS Start'); END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status); END IF;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data );

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'OTHERS End'); END IF;
   EXCEPTION
     WHEN OTHERS THEN
       NULL; -- If exception occurs inside the outer exception handling block, ignore it.
     END;
END upgrade_existing_docs;

--------------------------------------------------------------------------------
--Start of Comments
--Name: migrate_catalog
--Pre-reqs:
--  The iP catalog data is populated in PO Interface tables.
--Modifies:
--  a) PO Interface Tables (inserts new po_header_id for successful rows, back
--     to the Interface tables.
--  b) PO_INTERFACE_ERRORS table: Inserts error messages for those rows that
--     failed the migration.
--  c) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Migrate the iP Catalog Data to PO. This API should be called during the
--  upgrade phase only.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be committed?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_log_level
--  Specifies the level for which logging is enabled.
--p_batch_id
--  Batch ID to identify the data in interface tables that needs to be migrated.
--p_batch_size
--  The maximum number of rows that should be processed at a time, to avoid
--  exceeding rollback segment. The transaction would be committed after
--  processing each batch.
--OUT:
--x_return_status
-- Apps API Std
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_msg_count
-- Apps API Std
-- The number of error messages returned in the FND error stack in case
-- x_return_status returned FND_API.G_RET_STS_ERROR or
-- FND_API.G_RET_STS_UNEXP_ERROR
--x_msg_data
-- Apps API Std
--  Contains error msg in case x_return_status returned FND_API.G_RET_STS_ERROR
--  or FND_API.G_RET_STS_UNEXP_ERROR
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE migrate_catalog
(
   p_api_version        IN NUMBER
,  p_commit             IN VARCHAR2 default FND_API.G_FALSE
,  p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
,  p_validation_level   IN NUMBER default FND_API.G_VALID_LEVEL_FULL
,  p_log_level          IN NUMBER default 1
,  p_batch_id           IN NUMBER
,  p_batch_size         IN NUMBER default 2500
,  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_catalog';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_module        CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
  l_return_status VARCHAR2(1);
  l_org_id_list PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';

  -- Set logging options
  PO_R12_CAT_UPG_DEBUG.set_logging_options(p_log_level => p_log_level);
  g_debug := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_api_version='||p_api_version); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_commit='||p_commit); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_init_msg_list='||p_init_msg_list); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_validation_level='||p_validation_level); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_log_level='||p_log_level); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_batch_id='||p_batch_id); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_batch_size='||p_batch_size); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_validate_only_mode='||p_validate_only_mode); END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_API_call(
                        p_current_version_number => l_api_version,
                        p_caller_version_number  => p_api_version,
                        p_api_name               => l_api_name,
                        p_pkg_name               => g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '020';
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_progress := '030';
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  PO_R12_CAT_UPG_PVT.get_distinct_orgs(
                           p_batch_id           => p_batch_id
                         , p_batch_size         => p_batch_size
                         , p_validate_only_mode => p_validate_only_mode
                         , x_org_id_list        => l_org_id_list);

  l_progress := '040';
  -- To handle data from multiple orgs, we start this loop, once for each org
  FOR i IN 1 .. l_org_id_list.COUNT
  LOOP
    l_progress := '050';
    -- Set the org_id in g_job structure. It will be used while stamping the
    -- processing_id for rows that have this org_id. Only those lines that are
    -- stamped with a processing_id are picked up for migration.
    PO_R12_CAT_UPG_PVT.g_job.org_id := l_org_id_list(i);

    -- Set the org contetxt. Some of the defaulting/validation code uses
    -- org-striped views. Moreover, some of the other product API's may
    -- be using the org context, such as Tax/MRC/FV(JFMIP vendor validation)
    -- /GL Rate API's, etc.
    /*PO_UC9+10*/
    --FND_CLIENT_INFO.set_org_context(PO_R12_CAT_UPG_PVT.g_job.org_id);
    /*/PO_UC9+10*/
    -- For Release 12, use the following API.
    /*PO_UC12*/
    mo_global.set_policy_context('S', PO_R12_CAT_UPG_PVT.g_job.org_id); -- Bug#5259328
    /*/PO_UC12*/

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'Migration for org='||PO_R12_CAT_UPG_PVT.g_job.org_id); END IF;

    l_progress := '060';
    -- Migrate GBPA, BPA, Quotation (Headers and Lines) from interface tables
    PO_R12_CAT_UPG_PVT.migrate_documents
                        (  p_batch_id           => p_batch_id
                         , p_batch_size         => p_batch_size
                         , p_commit             => p_commit
                         , p_validate_only_mode => p_validate_only_mode
                         , x_return_status      => l_return_status
                         , x_msg_count          => x_msg_count
                         , x_msg_data           => x_msg_data);

    -- If return status is not success, no further migration should be performed
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'Document migration failed.'); END IF;
    END IF;

    l_progress := '070';
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      -- Migrate Attribute data for GBPA, BPA, Quotation and ReqTemplates
      PO_R12_CAT_UPG_PVT.migrate_attributes(p_validate_only_mode => p_validate_only_mode);
    END IF; -- IF (l_return_status = FND_API.G_RET_STS_SUCCESS)

    l_progress := '080';
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      -- Migrate TLP data for GBPA, BPA, Quotation and ReqTemplates
      PO_R12_CAT_UPG_PVT.migrate_attributes_tlp(p_validate_only_mode => p_validate_only_mode);
    END IF; -- IF (l_return_status = FND_API.G_RET_STS_SUCCESS)

    l_progress := '090';
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      -- Migrate the data for ReqTemplates
      PO_R12_CAT_UPG_PVT.update_req_templates
                                    (  p_batch_size     => p_batch_size
                                     , p_validate_only_mode         => p_validate_only_mode
                                     , x_return_status  => l_return_status);

      -- If return status is not success, no further migration should be performed
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'Document migration failed.'); END IF;
      END IF;
    END IF; -- IF (l_return_status = FND_API.G_RET_STS_SUCCESS)

    l_progress := '100';

    -- If all lines for a header have errors, then do not create the header.
    -- Clean up the header from the txn table.
    PO_R12_CAT_UPG_PVT.cleanup_err_docs;

  END LOOP; -- end of loop to handle data from multiple orgs

  l_progress := '110';

  -- Standard check of p_commit.
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  l_progress := '120';

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data );

  l_progress := '130';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'END'); END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'EXPECTED Start'); END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data );
    IF g_debug THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status);
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'EXPECTED End');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'UNEXPECTED Start'); END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data );
    IF g_debug THEN
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status);
      PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'UNEXPECTED End');
    END IF;

  WHEN OTHERS THEN
   BEGIN
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'OTHERS Start'); END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status); END IF;

      --TODO: remove after manual UT
      RAISE_APPLICATION_ERROR(-20000,l_module||','||l_progress || ','|| SQLERRM);

      --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      --   FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      --END IF;

      -- Standard call to get message count and if count is 1, get message info.
      --FND_MSG_PUB.count_and_get(p_count => x_msg_count,
      --                          p_data  => x_msg_data );

      --IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_msg_count='||x_msg_count); END IF;
      --IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_msg_data='||x_msg_data); END IF;

      --IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'OTHERS End'); END IF;

   EXCEPTION
     WHEN OTHERS THEN
       NULL; -- If exception occurs inside the outer exception handling block, ignore it.

       --TODO: remove after manual UT
       RAISE_APPLICATION_ERROR(-20000,l_module||','||l_progress || ','|| SQLERRM);
     END;
END migrate_catalog;

END PO_R12_CAT_UPG_GRP;

/
