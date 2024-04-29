--------------------------------------------------------
--  DDL for Package Body PO_AP_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_PURGE_PVT" AS
/* $Header: POXVPUDB.pls 120.7.12010000.3 2012/06/11 08:34:00 dtoshniw ship $ */

-- <DOC PURGE FPJ START>

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PO_AP_PURGE_PVT';
g_fnd_debug     VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_MODULE_PREFIX CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-- product installation status
g_inv_install_status        VARCHAR2(1);
g_wip_install_status        VARCHAR2(1);
g_mrp_install_status        VARCHAR2(1);
g_chv_install_status        VARCHAR2(1);
g_pa_install_status         VARCHAR2(1);
g_pjm_install_status        VARCHAR2(1);
g_set_product_inst_status   VARCHAR2(1) := FND_API.G_FALSE;


--*********************************************************************
----------------- Private Procedure Prototypes-------------------------
--*********************************************************************

PROCEDURE seed_simple_req
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_last_activity_date  IN          DATE
);

PROCEDURE seed_po
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_last_activity_date  IN          DATE
);

PROCEDURE set_product_inst_status
( x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE get_installation_status
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_appl_id             IN          NUMBER,
  x_inst_status         OUT NOCOPY  VARCHAR2
);

PROCEDURE filter_referenced_req
( x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE filter_referenced_po
( x_return_status       OUT NOCOPY  VARCHAR2
);

PROCEDURE filter_dependent_po_req_list
( x_return_status       OUT NOCOPY  VARCHAR2,
  x_po_records_filtered OUT NOCOPY  VARCHAR2
);

PROCEDURE filter_dependent_po_ap_list
( x_return_status       OUT NOCOPY  VARCHAR2,
  x_po_records_filtered OUT NOCOPY  VARCHAR2
);

PROCEDURE remove_filtered_records
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2
);

PROCEDURE confirm_simple_req
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_last_activity_date  IN          DATE
);

PROCEDURE confirm_po
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2,
  p_last_activity_date  IN          DATE
);

PROCEDURE get_purge_list_range
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_category            IN          VARCHAR2,
  x_lower_limit         OUT NOCOPY  NUMBER,
  x_upper_limit        OUT NOCOPY  NUMBER
);

PROCEDURE summarize_reqs
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_range_size          IN          NUMBER,
  p_req_lower_limit     IN          NUMBER,
  p_req_upper_limit     IN          NUMBER
);

PROCEDURE summarize_pos
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
);

PROCEDURE delete_reqs
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_size          IN          NUMBER,
  p_req_lower_limit     IN          NUMBER,
  p_req_upper_limit     IN          NUMBER
);

PROCEDURE delete_pos
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
);

--bug3256316
--Dump All messages to FND_LOG

PROCEDURE dump_msg_to_log
(  p_module            IN      VARCHAR2
);

--*********************************************************************
-------------------------- Public Procedures --------------------------
--*********************************************************************

-----------------------------------------------------------------------
--Start of Comments
--Name: seed_records
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Based on the purge category, insert requisition or PO document header
--  information into purge list
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  Whether the API should commit
--p_purge_name
--  Name of this purge process
--p_purge_category
--  Purge Category
--p_last_activity_date
--  cutoff date for a document to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  return any error message
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE seed_records
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_last_activity_date IN DATE
) IS

l_api_name      CONSTANT  VARCHAR2(50) := 'seed_records';
l_api_version   CONSTANT  NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    SAVEPOINT seed_records_pvt;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;  -- not compatible_api

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    IF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_REQ) THEN

        l_progress := '020';

        seed_simple_req
        ( x_return_status       => x_return_status,
          p_purge_name          => p_purge_name,
          p_last_activity_date  => p_last_activity_date
        );

    ELSIF (p_purge_category IN (PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO,
                                PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV)) THEN

        l_progress := '030';

        seed_po
        ( x_return_status       => x_return_status,
          p_purge_category      => p_purge_category,
          p_purge_name          => p_purge_name,
          p_last_activity_date  => p_last_activity_date
        );

    ELSE
        -- wrong purge_category
        l_progress := '040';

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => l_progress || ': Param Mismatch' );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF; -- p_purge_category

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

        l_progress := '050';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF (FND_API.to_boolean(p_commit)) THEN

        l_progress := '060';
        COMMIT;

    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO seed_records_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress

    );
    x_msg_data := FND_MSG_PUB.get(p_msg_index => l_msg_idx,
                                  p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END seed_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_records
--Pre-reqs: seed_recores is already called
--          set_product_inst_status is already called
--Modifies:
--Locks:
--  None
--Function:
--  Eliminate records from the purge list if they do not satisfies
--  additional purge criteria
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: commit changes
--  FND_API.G_FALSE: do not commit changes
--p_purge_status
--  Current stage of the purge process
--p_purge_name
--  Name of this purge process
--p_purge_category
--  Purge Category
--p_action
--  Applicable when purge category = 'MATCHED PO AND INVOICES'.
--  Possible values:
--    'FILTER REF PO AND REQ': remove PO/REQ from the purge list if they
--        are referenced by other products
--    'FILTER DEPENDENT PO AND REQ': Filter Purge list so that for all
--        PO/CONTRACT/REQ remaining in the purge list, all the dependent
--        PO/CONTRACT/REQ are in the purge list as well
--    'FILTER DEPENDENT PO AND AP': Remove PO from purge list if the
--        corresponding invoice is not in the purge list
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  return any error msg
--x_records_filtered
--  indicate whether there is any PO getting excluded after this call
--  Applicable for purge category = 'MATCHED PO AND INVOICES', when
--  p_action is 'FILTER DEPENDENT PO AND REQ' or 'FILTER DEPENDENT PO AND AP'
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_records
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_status  IN VARCHAR2,
   p_purge_name IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_action         IN VARCHAR2,
   x_po_records_filtered OUT NOCOPY VARCHAR2
) IS

l_api_name      CONSTANT  VARCHAR2(50) := 'filter_records';
l_api_version   CONSTANT  NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    SAVEPOINT filter_records_pvt;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;  -- not compatible_api

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_po_records_filtered := FND_API.G_FALSE;

    l_progress := '010';

    -- if product installation statuses have not been set, set them
    IF (NOT FND_API.to_boolean(g_set_product_inst_status)) THEN
        l_progress := '020';

        set_product_inst_status
        ( x_return_status   => l_return_status
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF; -- not g_set_product_inst_status

    IF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_REQ) THEN
        l_progress := '030';

        filter_referenced_req (x_return_status  => l_return_status );

    ELSIF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO) THEN
        l_progress := '040';

        filter_referenced_req (x_return_status  => l_return_status);

        IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

            filter_referenced_po (x_return_status   => l_return_status);
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

            filter_dependent_po_req_list
            ( x_return_status       => l_return_status,
              x_po_records_filtered => x_po_records_filtered);
        END IF;

    ELSIF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV) THEN
        l_progress := '050';

        IF (p_action = PO_AP_PURGE_GRP.G_FILTER_ACT_REF_PO_REQ) THEN
            l_progress := '060';

            filter_referenced_req
            (   x_return_status => l_return_status  );

            IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_progress := '070';

                filter_referenced_po
                (   x_return_status => l_return_status  );
            END IF;

        ELSIF (p_action = PO_AP_PURGE_GRP.G_FILTER_ACT_DEP_PO_REQ) THEN
            l_progress := '080';

            filter_dependent_po_req_list
            (   x_return_status         =>  l_return_status,
                x_po_records_filtered   =>  x_po_records_filtered   );

        ELSIF (p_action = PO_AP_PURGE_GRP.G_FILTER_ACT_DEP_PO_AP) THEN
            l_progress := '090';

            filter_dependent_po_ap_list
            (   x_return_status         =>  l_return_status,
                x_po_records_filtered   =>  x_po_records_filtered   );
        ELSE
            l_progress := '100';

            FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => g_pkg_name,
              p_procedure_name  => l_api_name || '.' || l_progress,
              p_error_text      => l_progress || ': Param Mismatch' );

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF; -- p_action = ...

    ELSE
        l_progress := '110';

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => l_progress || ': Param Mismatch' );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;  -- p_purge_category

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '120';

    IF (p_purge_status = 'INITIATING') THEN
        l_progress := '130';

        remove_filtered_records
        ( x_return_status   => l_return_status,
          p_purge_category  => p_purge_category
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF; -- p_purge_status = 'INITIATING'

    IF (FND_API.to_boolean(p_commit)) THEN
        COMMIT;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO filter_records_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress

    );
    x_msg_data := FND_MSG_PUB.get(p_msg_index => l_msg_idx,
                                  p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END filter_records;



-----------------------------------------------------------------------
--Start of Comments
--Name: confirm_records
--Pre-reqs: It is only called from AP Purge program during confirmation
--          stage
--Modifies:
--Locks:
--  None
--Function:
--  Remove records from the purge list by setting double_check_flag = 'Y'
--  if the records do not satisfy the initial purge criteria anymore
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_purge_name
--  Name of the purge
--p_purge_category
--  Purge Category
--p_last_activity_date
--  Cutoff date for a document to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  This parameter will be not null if an error happens
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE confirm_records
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_name IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_last_activity_date IN DATE
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'confirm_records';
l_api_version   CONSTANT NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;
BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    SAVEPOINT confirm_records_pvt;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    IF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_REQ) THEN
        l_progress := '020';

        confirm_simple_req
        ( x_return_status       => l_return_status,
          p_last_activity_date  => p_last_activity_date );

    ELSIF (p_purge_category IN (PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO,
                                PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV)) THEN
        l_progress := '030';

        confirm_po
        ( x_return_status       => l_return_status,
          p_purge_category      => p_purge_category,
          p_last_activity_date  => p_last_activity_date );
    ELSE
            -- wrong purge_category
        l_progress := '040';

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => l_progress || ': Param Mismatch' );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; -- p_purge_category

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (FND_API.to_boolean(p_commit)) THEN
        COMMIT;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO confirm_records_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_msg_index => l_msg_idx,
                                   p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END confirm_records;



-----------------------------------------------------------------------
--Start of Comments
--Name: summarize_records
--Pre-reqs: It is only called from AP Purge program during summarization
--          stage
--Modifies:
--Locks:
--  None
--Function:
--  Insert the document information into history tables before actual
--  deletion happens. Documents to be recorded include reqs, pos and
--  receipts
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_purge_name
--  Name of the purge
--p_purge_category
--  Purge Category
--p_range_size
--  This program inserts data in batches. This parameter specifies
--  the size of the id range per commit cycle
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  This parameter will be not null if an error happens
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE summarize_records
(  p_api_version        IN          NUMBER,
   p_init_msg_list      IN          VARCHAR2,
   p_commit             IN          VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_data           OUT NOCOPY  VARCHAR2,
   p_purge_name         IN          VARCHAR2,
   p_purge_category     IN          VARCHAR2,
   p_range_size         IN          NUMBER
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'summarize_records';
l_api_version   CONSTANT NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_req_lower_limit   NUMBER;
l_req_upper_limit  NUMBER;
l_po_lower_limit    NUMBER;
l_po_upper_limit   NUMBER;
l_msg_idx       NUMBER;
BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    -- This API will commit for each batch it processes. The p_commit
    -- parameter has to be FND_API.G_TRUE

    IF (p_commit <> FND_API.G_TRUE) THEN

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => 'Internal Error. summarize_records must commit'
        );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '020';

    get_purge_list_range
    ( x_return_status   => l_return_status,
      p_category        => 'REQ',
      x_lower_limit     => l_req_lower_limit,
      x_upper_limit     => l_req_upper_limit
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    summarize_reqs
    ( x_return_status       => l_return_status,
      p_purge_name          => p_purge_name,
      p_range_size          => p_range_size,
      p_req_lower_limit     => l_req_lower_limit,
      p_req_upper_limit     => l_req_upper_limit
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'After summ_reqs. rtn_status = ' || l_return_status
        );
        END IF;
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_purge_category IN (PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO,
                             PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV)) THEN

        l_progress := '030';

        get_purge_list_range
        ( x_return_status   => l_return_status,
          p_category        => 'PO',
          x_lower_limit     => l_po_lower_limit,
          x_upper_limit     => l_po_upper_limit
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '040';

        summarize_pos
        ( x_return_status   => l_return_status,
          p_purge_name      => p_purge_name,
          p_range_size      => p_range_size,
          p_po_lower_limit  => l_po_lower_limit,
          p_po_upper_limit  => l_po_upper_limit
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After summ_pos. rtn_status = ' || l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '050';

        RCV_AP_PURGE_PVT.summarize_receipts
        ( x_return_status   => l_return_status,
          p_purge_name      => p_purge_name,
          p_range_size      => p_range_size,
          p_po_lower_limit     => l_po_lower_limit,
          p_po_upper_limit     => l_po_upper_limit
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After summ_rcv. rtn_status = ' || l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;  -- p_purge_category IN (simple_po, matched_po_inv)

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Exception in ' || l_api_name || '.' ||
                       l_progress
        );
        END IF;
    END IF;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_msg_index => l_msg_idx,
                                   p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END summarize_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_records
--Pre-reqs: It is only called from AP Purge program during deletion
--          stage
--Modifies:
--Locks:
--  None
--Function:
--  Delete REQ, PO and RCV transaction tables if the corresponding
--  documents are in the purge list
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_purge_name
--  Name of the purge
--p_purge_category
--  Purge Category
--p_range_size
--  This program deletes data in batches. This parameter specifies
--  the number of documents to be purged per commit cycle
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  This parameter will be not null if an error happens
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_records
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_name IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_range_size IN NUMBER
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'delete_records';
l_api_version   CONSTANT NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;

l_req_lower_limit   NUMBER;
l_req_upper_limit  NUMBER;
l_po_lower_limit    NUMBER;
l_po_upper_limit   NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    -- This API will commit for each batch it processes. The p_commit
    -- parameter has to be FND_API.G_TRUE
    IF (p_commit <> FND_API.G_TRUE) THEN

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => 'Internal Error. delete_records must commit'
        );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '020';

    get_purge_list_range
    ( x_return_status   => l_return_status,
      p_category        => 'REQ',
      x_lower_limit     => l_req_lower_limit,
      x_upper_limit     => l_req_upper_limit
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    delete_reqs
    ( x_return_status       => l_return_status,
      p_range_size          => p_range_size,
      p_req_lower_limit     => l_req_lower_limit,
      p_req_upper_limit     => l_req_upper_limit
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_purge_category IN (PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO,
                             PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV)) THEN

        l_progress := '030';

        get_purge_list_range
        ( x_return_status   => l_return_status,
          p_category        => 'PO',
          x_lower_limit     => l_po_lower_limit,
          x_upper_limit     => l_po_upper_limit
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '040';

        delete_pos
        ( x_return_status   => l_return_status,
          p_range_size      => p_range_size,
          p_po_lower_limit  => l_po_lower_limit,
          p_po_upper_limit  => l_po_upper_limit
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '050';

        RCV_AP_PURGE_PVT.delete_receipts
        ( x_return_status   => l_return_status,
          p_range_size      => p_range_size,
          p_po_lower_limit  => l_po_lower_limit,
          p_po_upper_limit  => l_po_upper_limit
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;  -- if purge category = simple_po or matched po_inv

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_msg_index => l_msg_idx,
                                   p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END delete_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_purge_lists
--Pre-reqs: It is only called from AP Purge program during summarization
--          or abortion stage
--Modifies:
--Locks:
--  None
--Function:
--  Truncate REQ/PO purge list
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_purge_name
--  Name of the purge
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  This parameter will be not null if an error happens
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_purge_lists
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2
) IS


l_api_name      CONSTANT VARCHAR2(50) := 'delete_purge_lists';
l_api_version   CONSTANT NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    SAVEPOINT delete_purge_lists_pvt;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    -- clear the purge lists

    DELETE
    FROM    po_purge_req_list;

    DELETE
    FROM    po_purge_po_list;

    IF (FND_API.to_boolean(p_commit)) THEN
        COMMIT;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO delete_purge_lists_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_msg_index => l_msg_idx,
                                   p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END delete_purge_lists;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_history_tables
--Pre-reqs: It is only called from AP Purge program during abort
--          stage
--Modifies:
--Locks:
--  None
--Function:
--  Delete records from history tables that were inserted by the current
--  purge process (identified by p_purge_name)
--Parameters:
--IN:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--p_commit
--  FND_API.G_TRUE: procedure should commit
--  FND_API.G_FALSE: procedure should not commit
--p_purge_name
--  Name of the purge
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  This parameter will be not null if an error happens
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_history_tables
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_name IN VARCHAR2
) IS


l_api_name      CONSTANT VARCHAR2(50) := 'delete_history_tables';
l_api_version   CONSTANT NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    SAVEPOINT delete_history_tables_pvt;

    l_progress := '010';

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '020';

    DELETE
    FROM    po_history_pos
    WHERE   purge_name = p_purge_name;

    l_progress := '030';

    DELETE
    FROM    po_history_requisitions
    WHERE   purge_name = p_purge_name;

    l_progress := '040';

    DELETE
    FROM    po_history_receipts
    WHERE   purge_name = p_purge_name;

    IF (FND_API.to_boolean(p_commit)) THEN
        COMMIT;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO delete_history_tables_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_msg_index => l_msg_idx,
                                   p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END delete_history_tables;


-----------------------------------------------------------------------
--Start of Comments
--Name: count_po_rows
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Get the count of some PO transaction tables for reporting
--Parameters:
--p_api_version
--  Version of the api the caller is assuming
--p_init_msg_list
--  FND_API.G_TRUE: initialize the message list
--  FND_API.G_FALSE: do not initialize the message list
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_msg_data
--  This parameter will be not null if an error happens
--x_po_hdr_coun
--  Number of records in po_headers
--x_rcv_line_count
--  Number of records in rcv_shipment_lines
--x_req_hdr_count
--  Number of records in po_requisition_headers
--x_vendor_count
--  Number of records in po_vendors
--x_asl_count
--  Number of records in po_approved_supplier_list
--x_asl_attr_count
--  Number of records in po_asl_attributes
--x_asl_doc_count
--  Number of records in po_asl_documents
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE count_po_rows
(  p_api_version    IN          NUMBER,
   p_init_msg_list  IN          VARCHAR2,
   x_return_status  OUT NOCOPY  VARCHAR2,
   x_msg_data       OUT NOCOPY  VARCHAR2,
   x_po_hdr_count   OUT NOCOPY  NUMBER,
   x_rcv_line_count OUT NOCOPY  NUMBER,
   x_req_hdr_count  OUT NOCOPY  NUMBER,
   x_vendor_count   OUT NOCOPY  NUMBER,
   x_asl_count      OUT NOCOPY  NUMBER,
   x_asl_attr_count OUT NOCOPY  NUMBER,
   x_asl_doc_count  OUT NOCOPY  NUMBER
) IS

l_api_name      VARCHAR2(50) := 'count_po_rows';
l_api_version   NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
l_msg_idx       NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_msg_idx := FND_MSG_PUB.count_msg + 1;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT  COUNT(1)
    INTO    x_po_hdr_count
    FROM    po_headers;

    l_progress := '010';

    SELECT  COUNT(1)
    INTO    x_rcv_line_count
    FROM    rcv_shipment_lines;

    l_progress := '020';

    SELECT  COUNT(1)
    INTO    x_req_hdr_count
    FROM    po_requisition_headers;

    l_progress := '030';

    SELECT  COUNT(1)
    INTO    x_vendor_count
    FROM    po_vendors;

    l_progress := '040';

    SELECT  COUNT(1)
    INTO    x_asl_count
    FROM    po_approved_supplier_list;

    l_progress := '050';

    SELECT  COUNT(1)
    INTO    x_asl_attr_count
    FROM    po_asl_attributes;

    l_progress := '060';

    SELECT  COUNT(1)
    INTO    x_asl_doc_count
    FROM    po_asl_documents;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

    x_msg_data := FND_MSG_PUB.get (p_msg_index => l_msg_idx,
                                   p_encoded => 'F');
    dump_msg_to_log( p_module => l_module || l_progress );
END count_po_rows;

--*********************************************************************
-------------------------- Private Procedures -------------------------
--*********************************************************************


-----------------------------------------------------------------------
--Start of Comments
--Name: seed_simple_req
--Pre-reqs:
--Modifies: po_purge_req_list
--Locks:
--  None
--Function:
--  Populate req purge list with eligible reqs that have not been updated
--  since last activity date
--Parameters:
--IN:
--p_purge_name
--  Name of this purge process
--p_last_activity_date
--  Cutoff date of the purge process. req will not be purged if it has been
--  updated since this date
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE seed_simple_req
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_last_activity_date  IN          DATE
) IS

l_api_name      CONSTANT  VARCHAR2(50) := 'seed_simple_req';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- SQL What: Generate a list of requisitions that are eligible for purging
    -- SQL Why:  This is the initial list of reqs to be purged. Later on the
    --           records in this list will be removed if the records are no
    --           longer eligible for purging after additional rules are applied

    INSERT INTO po_purge_req_list
    (   requisition_header_id,
        purge_name,
        double_check_flag
    )
    SELECT  PRH.requisition_header_id,
            p_purge_name,
            'Y'
    FROM    po_requisition_headers PRH
    WHERE   PRH.last_update_date <= p_last_activity_date
    AND     (PRH.closed_code = 'FINALLY CLOSED'
             OR PRH.authorization_status = 'CANCELLED')
    AND     NOT EXISTS
                (SELECT NULL
                 FROM   po_requisition_lines PRL
                 WHERE  PRL.requisition_header_id = PRH.requisition_header_id
                 AND    NVL(PRL.modified_by_agent_flag, 'N') = 'N'
                 AND    (PRL.last_update_date > p_last_activity_date
                         OR
                         PRL.line_location_id IS NOT NULL
                         OR
                         PRL.source_type_code = 'INVENTORY'
                         OR
                         EXISTS (
                            SELECT  NULL
                            FROM    po_price_differentials PPD
                            WHERE   PPD.entity_type = 'REQ LINE'
                            AND     PPD.entity_id = PRL.requisition_line_id
                            AND     PPD.last_update_date >
                                    p_last_activity_date)
                         OR
                         EXISTS (
                            SELECT  NULL
                            FROM    po_req_distributions PRD
                            WHERE   PRD.requisition_line_id =
                                    PRL.requisition_line_id
                            AND     PRD.last_update_date >
                                    p_last_activity_date)));

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Inserted ' || SQL%ROWCOUNT || ' Reqs to purge list'
        );
        END IF;
    END IF;

    l_progress := '010';

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'REQ'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END seed_simple_req;



-----------------------------------------------------------------------
--Start of Comments
--Name: seed_po
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function:
--  Populate po purge list with eligible pos that have not been updated
--  since last activity date. It will also populate req list as well
--Parameters:
--IN:
--p_purge_category
--  Describe what type of documents user wants to purge.
--p_purge_name
--  Name of this purge process
--p_last_activity_date
--  Cutoff date of the purge process. po will not be purged if it has been
--  updated since this date
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE seed_po
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_last_activity_date  IN          DATE
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'seed_po';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --<ACTION FOR 11iX START>
    --Initiated by: BAO
    --The check for Code Level below will be unnecessary in 11iX.
    --The code from PO_AP_PURGE_UTIL_PVT.seed_po will be moved to
    --here and there will be no need to branch the logic based on code level

    IF (PO_CODE_RELEASE_GRP.Current_Release <
        PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) THEN

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'PO level is less than FPJ '
            );
            END IF;
        END IF;

        IF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO) THEN

            l_progress := '010';

            -- The subquery on po_distributions is to make sure that no invoice
            -- has matched to this PO yet

            --SQL What: Generate a list of POs that are eligibible for purge
            --SQL Why:  This is the initial list of pos to be purged. There
            --          will be additional rules getting applied to this table
            --          to remove records that are actually not eligible for
            --          purge

            INSERT INTO po_purge_po_list
            (   po_header_id,
                purge_name,
                double_check_flag
            )
            SELECT  PH.po_header_id,
                    p_purge_name,
                    'Y'
            FROM    po_headers PH
            WHERE   PH.type_lookup_code IN ('STANDARD', 'PLANNED',
                                            'BLANKET',  'CONTRACT')
            AND     PH.last_update_date <= p_last_activity_date
            AND     (PH.closed_code = 'FINALLY CLOSED'
                     OR PH.cancel_flag = 'Y')
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_releases PR
                         WHERE  PR.po_header_id = PH.po_header_id
                         AND    PR.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_lines PL
                         WHERE  PL.po_header_id = PH.po_header_id
                         AND    PL.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_line_locations PLL
                         WHERE  PLL.po_header_id = PH.po_header_id
                         AND    PLL.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_distributions PD
                         WHERE  PD.po_header_id = PH.po_header_id
                         AND    (PD.last_update_date > p_last_activity_date
                                 OR
                                 EXISTS
                                    (SELECT NULL
                                     FROM   ap_invoice_distributions AD
                                     WHERE  AD.po_distribution_id =
                                            PD.po_distribution_id)))
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   rcv_transactions RT
                         WHERE  RT.po_header_id = PH.po_header_id
                         AND    RT.last_update_date > p_last_activity_date)
            AND     PO_AP_PURGE_GRP.validate_purge(PH.po_header_id) = 'T';


        ELSIF (p_purge_category =PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV) THEN

            l_progress := '020';

            -- POs that have invoices are still candidates for purging when
            -- purge category = 'MATCHED POS AND INVOICES'

            --SQL What: Generate a list of POs that are eligibible for purge
            --SQL Why:  This is the initial list of pos to be purged. There
            --          will be additional rules getting applied to this table
            --          to remove records that are actually not eligible for
            --          purge

            INSERT INTO po_purge_po_list
            (   po_header_id,
                purge_name,
                double_check_flag
            )
            SELECT  PH.po_header_id,
                    p_purge_name,
                    'Y'
            FROM    po_headers PH
            WHERE   PH.type_lookup_code IN ('STANDARD', 'PLANNED',
                                            'BLANKET',  'CONTRACT')
            AND     PH.last_update_date <= p_last_activity_date
            AND     (PH.closed_code = 'FINALLY CLOSED'
                     OR PH.cancel_flag = 'Y')
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_releases PR
                         WHERE  PR.po_header_id = PH.po_header_id
                         AND    PR.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_lines PL
                         WHERE  PL.po_header_id = PH.po_header_id
                         AND    PL.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_line_locations PLL
                         WHERE  PLL.po_header_id = PH.po_header_id
                         AND    PLL.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   po_distributions PD
                         WHERE  PD.po_header_id = PH.po_header_id
                         AND    PD.last_update_date > p_last_activity_date)
            AND     NOT EXISTS
                        (SELECT NULL
                         FROM   rcv_transactions RT
                         WHERE  RT.po_header_id = PH.po_header_id
                         AND    RT.last_update_date > p_last_activity_date)
            AND     PO_AP_PURGE_GRP.validate_purge(PH.po_header_id) = 'T';

        END IF; -- p_purge_category = ...

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'inserted ' || SQL%ROWCOUNT || ' POs to purge'
                           || ' list. purge_cat = ' || p_purge_category
            );
            END IF;
        END IF;

        l_progress := '030';

        -- We will put the req in the purge list even if it has turned into
        -- a PO.

        -- SQL What: Generate a list of requisitions that are eligible for
        --           purging
        -- SQL Why:  This is the initial list of reqs to be purged. Later on
        --           the records in this list will be removed if the records
        --           are no longer eligible for purging after additional rules
        --           are applied

        INSERT INTO po_purge_req_list
        (   requisition_header_id,
            purge_name,
            double_check_flag
        )
        SELECT  PRH.requisition_header_id,
                p_purge_name,
                'Y'
        FROM    po_requisition_headers PRH
        WHERE   PRH.last_update_date <= p_last_activity_date
        AND     (PRH.closed_code = 'FINALLY CLOSED'
                 OR PRH.authorization_status = 'CANCELLED')
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_requisition_lines PRL
                     WHERE  PRL.requisition_header_id =
                            PRH.requisition_header_id
                     AND    NVL(PRL.modified_by_agent_flag, 'N') = 'N'
                     AND    (PRL.last_update_date > p_last_activity_date
                             OR
                             PRL.source_type_code = 'INVENTORY'
                             OR
                             EXISTS (
                                SELECT  NULL
                                FROM    po_req_distributions PRD
                                WHERE   PRD.requisition_line_id =
                                        PRL.requisition_line_id
                                AND     PRD.last_update_date >
                                        p_last_activity_date)));

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'inserted ' || SQL%ROWCOUNT || ' REQs to purge list'
            );
            END IF;
        END IF;


        l_progress := '040';

    ELSE  -- Family Pack level >= 11i FPJ

        l_progress := '050';

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'PO Code Level > FPJ'
            );
            END IF;
        END IF;

        PO_AP_PURGE_UTIL_PVT.seed_po
        ( x_return_status       => l_return_status,
          p_purge_category      => p_purge_category,
          p_purge_name          => p_purge_name,
          p_last_activity_date  => p_last_activity_date
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;   -- current release < 11i FPJ

    --<ACTION FOR 11iX END>

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'REQ'
    );

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'PO'
    );


    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
END seed_po;


-----------------------------------------------------------------------
--Start of Comments
--Name: set_product_inst_status
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  derive product installation status and store the results into package
--  variables
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_product_inst_status
( x_return_status   OUT NOCOPY  VARCHAR2
) IS

l_api_name      CONSTANT    VARCHAR2(50) := 'set_product_inst_status';
l_api_version   CONSTANT    NUMBER := 1.0;
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- inv installation status
    get_installation_status
    ( x_return_status   => l_return_status,
      p_appl_id         => 401,
      x_inst_status     => g_inv_install_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_progress := '000';

    -- wip installation status
    get_installation_status
    ( x_return_status   => l_return_status,
      p_appl_id         => 706,
      x_inst_status     => g_wip_install_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_progress := '000';

    -- mrp installation status
    get_installation_status
    ( x_return_status   => l_return_status,
      p_appl_id         => 704,
      x_inst_status     => g_mrp_install_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_progress := '000';

    -- pa installation status
    get_installation_status
    ( x_return_status   => l_return_status,
      p_appl_id         => 275,
      x_inst_status     => g_pa_install_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_progress := '000';

    -- chv installation status
    get_installation_status
    ( x_return_status   => l_return_status,
      p_appl_id         => 202,
      x_inst_status     => g_chv_install_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_progress := '000';

    -- pjm installation_status
    get_installation_status
    ( x_return_status   => l_return_status,
      p_appl_id         => 712,
      x_inst_status     => g_pjm_install_status
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'inv  = ' || g_inv_install_status ||
                       ',wip = ' || g_wip_install_status ||
                       ',mrp = ' || g_mrp_install_status ||
                       ',pa  = ' || g_pa_install_status  ||
                       ',chv = ' || g_chv_install_status ||
                       ',pjm = ' || g_pjm_install_status
        );
        END IF;
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_progress := '010';

    -- set g_set_product_inst_status to true to indicate that this procedure
    -- has been called and all the product installation status have been set
    g_set_product_inst_status := FND_API.G_TRUE;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END set_product_inst_status;


-----------------------------------------------------------------------
--Start of Comments
--Name: get_installation_status
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  get the installation status of a specific product
--Parameters:
--IN:
--p_appl_id
--  ID for the product
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_inst_status
--  indicate whether the product is installed or not. 'Y' represents that
--  the product is isntalled
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE get_installation_status
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_appl_id             IN          NUMBER,
  x_inst_status         OUT NOCOPY  VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'get_installation_status';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_inst_check    VARCHAR2(1);
l_dummy         VARCHAR2(1);

l_fnd_inst_exception    EXCEPTION;
BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (FND_INSTALLATION.get(   appl_id     => p_appl_id,
                                dep_appl_id => p_appl_id,
                                status      => l_inst_check,
                                industry    => l_dummy
                            ))
    THEN
        l_progress := '010';

        IF (l_inst_check = 'I') THEN
            x_inst_status := 'Y';
        ELSE
            x_inst_status := 'N';
        END IF;
    ELSE
        -- FND_INSTALLATION.get returns an error

        l_progress := '020';
        RAISE l_fnd_inst_exception;

    END IF;  -- FND_INSTALLATION.get()

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END get_installation_status;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_referenced_req
--Pre-reqs:
--Modifies: po_purge_req_list
--Locks:
--  None
--Function:
--  Remove req from the req purge list if it is referenced by records
--  that will not purged
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_referenced_req
( x_return_status       OUT NOCOPY  VARCHAR2
)IS

l_api_name      VARCHAR2(50) := 'filter_referenced_req';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_return_status VARCHAR2(1);

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_chv_install_status = 'Y') THEN
        l_progress := '010';

        UPDATE  po_purge_req_list PPRL
        SET     PPRL.double_check_flag = 'N'
        WHERE   PPRL.double_check_flag = 'Y'
        AND     EXISTS
                    (SELECT NULL
                     FROM   chv_item_orders CIO
                     WHERE  CIO.document_header_id = PPRL.requisition_header_id
                     AND    CIO.supply_document_type = 'REQUISITION');

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check CHV. Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_chv_install_status = 'Y'

    IF (g_pa_install_status = 'Y') THEN
        l_progress := '020';

        UPDATE  po_purge_req_list PPRL
        SET     PPRL.double_check_flag = 'N'
        WHERE   PPRL.double_check_flag = 'Y'
        AND     EXISTS
                    (SELECT NULL
                     FROM   po_req_distributions RD,
                            po_requisition_lines RL
                     WHERE  RL.requisition_header_id =
                            PPRL.requisition_header_id
                     AND    RD.requisition_line_id =
                            RL.requisition_line_id
                     AND    RD.project_id IS NOT NULL
                     AND    RL.destination_type_code = 'EXPENSE');

        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses PA as schema name even though it's text
        -- due to extra _. Modified message from _PA_ to PA product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check PA product. ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_pa_install_status = 'Y'

    IF (g_pjm_install_status = 'Y') THEN
        l_progress := '030';

        UPDATE  po_purge_req_list PPRL
        SET     PPRL.double_check_flag = 'N'
        WHERE   PPRL.double_check_flag = 'Y'
        AND     EXISTS
                    (SELECT NULL
                     FROM   po_req_distributions RD,
                            po_requisition_lines RL
                     WHERE  RL.requisition_header_id =
                            PPRL.requisition_header_id
                     AND    RD.requisition_line_id =
                            RL.requisition_line_id
                     AND    RD.project_id IS NOT NULL
                     AND    RL.destination_type_code IN ('INVENTORY',
                                                         'SHOP FLOOR'));
        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses PJM as schema name even though it's text
        -- due to extra _. Modified message from _PJM_ to PJM product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check PJM product, ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_pjm_install_status = 'Y'

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'REQ'
    );

    l_progress := '040';

    PO_AP_PURGE_UTIL_PVT.filter_more_referenced_req
    ( x_return_status => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '050';

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'REQ'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_referenced_req;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_referenced_po
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function:
--  Remove po from the req purge list if it is referenced by records
--  that will not purged
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_referenced_po
( x_return_status       OUT NOCOPY  VARCHAR2
)IS

l_api_name      VARCHAR2(50) := 'filter_referenced_po';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_inv_install_status = 'Y') THEN
        l_progress := '010';

        UPDATE  po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    mtl_material_transactions MMT
                    WHERE   MMT.transaction_source_type_id = 1
                    AND     MMT.transaction_source_id = PPL.po_header_id);

        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses INV as schema name even though it's text
        -- due to extra _. Modified message from _INV_ to INV product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check INV product. ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_inv_install_status = 'Y'

    IF (g_wip_install_status = 'Y') THEN
        l_progress := '020';

        UPDATE po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    wip_transactions WT
                    WHERE   WT.po_header_id = PPL.po_header_id);

        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses WIP as schema name even though it's text
        -- due to extra _. Modified message from _WIP_ to WIP product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check WIP product. ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_wip_install_status = 'Y'

    IF (g_mrp_install_status = 'Y') THEN
        l_progress := '030';

        UPDATE po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    mrp_schedule_consumptions MSC
                    WHERE   MSC.disposition_type IN (2,6)
                    AND     MSC.disposition_id = PPL.po_header_id);

        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses MRP as schema name even though it's text
        -- due to extra _. Modified message from _MRP_ to MRP product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check MRP product. ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_mrp_install_status = 'Y'

    IF (g_chv_install_status = 'Y') THEN
        l_progress := '040';

        UPDATE  po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     EXISTS(
                    SELECT  NULL
                    FROM    chv_item_orders CIO
                    WHERE   CIO.document_header_id = PPL.po_header_id
                    AND     CIO.supply_document_type = 'RELEASE');

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check CHV. Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_chv_install_status

    IF (g_pa_install_status = 'Y') THEN
        l_progress := '050';

        UPDATE  po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_distributions PD
                    WHERE   PPL.po_header_id = PD.po_header_id
                    AND     PD.project_id IS NOT NULL
                    AND     PD.destination_type_code = 'EXPENSE');

        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses PA as schema name even though it's text
        -- due to extra _. Modified message from _PA_ to PA product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check PA product. ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF; -- g_pa_install_status = 'Y'

    IF (g_pjm_install_status = 'Y') THEN
        l_progress := '060';

        UPDATE  po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_distributions PD
                    WHERE   PPL.po_header_id = PD.po_header_id
                    AND     PD.project_id IS NOT NULL
                    AND     PD.destination_type_code IN ('INVENTORY',
                                                         'SHOP FLOOR'));
        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses PJM as schema name even though it's text
        -- due to extra _. Modified message from _PJM_ to PJM product.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Check PJM product. ' ||
                           'Updated rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;
    END IF; -- g_pjm_install_status

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'PO'
    );

    l_progress := '070';

    PO_AP_PURGE_UTIL_PVT.filter_more_referenced_po
    ( x_return_status => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_referenced_po;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_dependent_po_req_list
--Pre-reqs:
--Modifies: po_purge_po_list, po_purge_req_list
--Locks:
--  None
--Function:
--  Remove documents (req, po, ga, contract) from the purge list if their
--  dependent documents are not in the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_po_records_filtered
--  indicate whether a po has been excluded from the list after the procedure
--  is executed
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_dependent_po_req_list
( x_return_status       OUT NOCOPY  VARCHAR2,
  x_po_records_filtered OUT NOCOPY  VARCHAR2
) IS

l_api_name          VARCHAR2(50) := 'filter_dependent_po_req_list';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_po_count          NUMBER;
l_req_count         NUMBER;

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_po_records_filtered := FND_API.G_FALSE;

    LOOP

        -- SQL What: 1) Remove PO from purge list if the corresponding
        --              requisition is not in the req purge list, and
        --           2) Remove PO from purge list if the corresponding contract
        --              not in the PO purge list
        --           3) Remove PO from purge list if the referencing GBPA is
        --              not in the purge list
        --           4) Remove Contract from purge list if the po referencing
        --              it is not in the po purge list
        --           5) Remove GBPA from purge list if the po referencing it
        --              is not in the purge list
        -- SQL Why:  If PO has backing req, either both of them are purged or
        --           none of them are purged. Same for the PO-Contract and
        --           PO-GA relationship

        UPDATE  po_purge_po_list PPL
        SET     PPL.double_check_flag = 'N'
        WHERE   PPL.double_check_flag = 'Y'
        AND     (EXISTS (    -- rm po if req not in purge list
                    SELECT NULL
                    FROM   po_line_locations_all PLL,
                           po_requisition_lines_all RL
                    WHERE  PLL.po_header_id = PPL.po_header_id
                    AND    PLL.line_location_id = RL.line_location_id
                    AND    NOT EXISTS (
                                    SELECT NULL
                                    FROM   po_purge_req_list PRL
                                    WHERE  PRL.requisition_header_id =
                                           RL.requisition_header_id
                                    AND    PRL.double_check_flag = 'Y'))
                OR
                 EXISTS (   -- rm po if contract not in purge list
                    SELECT NULL
                    FROM   po_lines_all POL
                    WHERE  POL.po_header_id = PPL.po_header_id
                    AND    POL.contract_id IS NOT NULL
                    AND    NOT EXISTS (
                                    SELECT NULL
                                    FROM   po_purge_po_list PPL1
                                    WHERE  PPL1.double_check_flag = 'Y'
                                    AND    PPL1.po_header_id =
                                           POL.contract_id))
                OR
                 EXISTS (   -- rm po if ga not in purge list
                    SELECT  NULL
                    FROM    po_lines_all POL,
                            po_headers_all POH
                    WHERE   PPL.po_header_id = POL.po_header_id
                    AND     POL.from_header_id = POH.po_header_id
                    AND     POH.type_lookup_code = 'BLANKET'
                    AND     POH.global_agreement_flag = 'Y'
                    AND     NOT EXISTS (
                                    SELECT  NULL
                                    FROM    po_purge_po_list PPL1
                                    WHERE   PPL1.double_check_flag = 'Y'
                                    AND     POH.po_header_id =
                                            PPL1.po_Header_id))
                OR
                 EXISTS (   -- rm contract if po not in purge list
                    SELECT NULL
                    FROM   po_lines_all POL
                    WHERE  PPL.po_header_id = POL.contract_id
                    AND    NOT EXISTS (
                                    SELECT NULL
                                    FROM   po_purge_po_list PPL1
                                    WHERE  PPL1.double_check_flag = 'Y'
                                    AND    POL.po_header_id =
                                           PPL1.po_header_id))
                OR
                 EXISTS (   -- rm ga if po not in purge list
                    SELECT  NULL
                    FROM    po_headers_all POH,
                            po_lines_all POL
                    WHERE   POH.po_header_id = PPL.po_header_id
                    AND     POH.type_lookup_code = 'BLANKET'
                    AND     POH.global_agreement_flag = 'Y'
                    AND     POL.from_header_id = POH.po_header_id
                    AND     NOT EXISTS (
                                    SELECT  NULL
                                    FROM    po_purge_po_list PPL1
                                    WHERE   PPL1.double_check_flag = 'Y'
                                    AND     POL.po_header_id =
                                            PPL1.po_header_id)));

        l_po_count := SQL%ROWCOUNT;


        -- SQL What: Remove REQ from purge list if the corresponding po
        --           is not in the po purge list
        -- SQL Why:  If PO and REQ are linked, either both of them are purged or
        --           none of them are purged

        UPDATE  po_purge_req_list PPRL
        SET     PPRL.double_check_flag = 'N'
        WHERE   PPRL.double_check_flag = 'Y'
        AND     EXISTS (
                    SELECT NULL
                    FROM   po_requisition_lines_all RL,
                           po_line_locations_all PLL
                    WHERE  RL.requisition_header_id =
                           PPRL.requisition_header_id
                    AND    RL.line_location_id = PLL.line_location_id
                    AND    NOT EXISTS (
                                    SELECT NULL
                                    FROM   po_purge_po_list PPL
                                    WHERE  PPL.double_check_flag = 'Y'
                                    AND    PPL.po_header_id =
                                           PLL.po_header_id));
        l_req_count := SQL%ROWCOUNT;

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Updated po_count = ' || l_po_count ||
                           ', Updated req_count = ' || l_req_count
            );
            END IF;
        END IF;

        IF (l_po_count > 0) THEN
            x_po_records_filtered := FND_API.G_TRUE;
        END IF;

        PO_AP_PURGE_UTIL_PVT.log_purge_list_count
        ( p_module  => l_module || l_progress,
          p_entity  => 'REQ'
        );

        PO_AP_PURGE_UTIL_PVT.log_purge_list_count
        ( p_module  => l_module || l_progress,
          p_entity  => 'PO'
        );

        IF (l_req_count = 0 AND l_po_count = 0) THEN
            EXIT;
        END IF;

    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_dependent_po_req_list;



-----------------------------------------------------------------------
--Start of Comments
--Name: filter_dependent_po_ap_list
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function:
--  Remove PO from the list if its depending invoice is not in the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_po_records_filtered
--  indicate whether any PO has been excluded after this procedure is executed
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE filter_dependent_po_ap_list
( x_return_status       OUT NOCOPY  VARCHAR2,
  x_po_records_filtered OUT NOCOPY  VARCHAR2
) IS

l_api_name          VARCHAR2(50) := 'filter_dependent_po_ap_list';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_po_count          NUMBER;

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_po_records_filtered := FND_API.G_FALSE;

    -- SQL What: Remove PO from purge list if the Invoices referencing it
    --           is not in the po purge list
    -- SQL Why:  If PO and Invoice are linked, either both of them are
    --           purged or none of them is purged

    UPDATE  po_purge_po_list PPL
    SET     PPL.double_check_flag = 'N'
    WHERE   PPL.double_check_flag = 'Y'
    AND     EXISTS (
                SELECT  NULL
                FROM    po_distributions PD,
                        ap_invoice_distributions AD
                WHERE   PD.po_header_id = PPL.po_header_id
                AND     AD.po_distribution_id = PD.po_distribution_id
                AND     NOT EXISTS (
                                SELECT  NULL
                                FROM    ap_purge_invoice_list APL
                                WHERE   APL.invoice_id = AD.invoice_id));

    l_po_count := SQL%ROWCOUNT;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Updated po rowcount = ' || l_po_count
        );
        END IF;
    END IF;

    IF (l_po_count > 0) THEN
        x_po_records_filtered := FND_API.G_TRUE;
    END IF;

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_dependent_po_ap_list;


-----------------------------------------------------------------------
--Start of Comments
--Name: remove_filtered_records
--Pre-reqs:
--Modifies: po_purge_po_list, po_purge_req_list
--Locks:
--  None
--Function:
--  Delete records from purge list if the record has double_check_flag = 'N'
--  This is supposed to be called during initiation stage of the purge process
--Parameters:
--IN:
--p_purge_category
--  Describe what type of documents user wants to purge.
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE remove_filtered_records
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'remove_filtered_records';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM po_purge_req_list
    WHERE  double_check_flag = 'N';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Deleted ' || SQL%ROWCOUNT || ' reqs from purge list'
        );
        END IF;
    END IF;

    l_progress := '010';

    IF (p_purge_category IN (PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO,
                             PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV)) THEN
        l_progress := '020';

        DELETE FROM po_purge_po_list
        WHERE  double_check_flag = 'N';

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' pos from purge list'
            );
            END IF;
        END IF;

    END IF; -- p_purge_category

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END remove_filtered_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: confirm_simple_req
--Pre-reqs:
--Modifies: po_purge_req_list
--Locks:
--  None
--Function:
--  Exclude req records from the purge list that have been updated recently
--Parameters:
--IN:
--p_last_activity_date
--  Cutoff date of the purge process. req will not be purged if it has been
--  updated since this date
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE confirm_simple_req
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_last_activity_date  IN          DATE
) IS

l_api_name          VARCHAR2(50) := 'confirm_simple_req';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- SQL What: Exclude Reqs that are no longer eligible for purging. The logic
    --           is similar to the one during initiation stage, but this time
    --           we are excluding records that are not eligible rather than
    --           including records that are eligible
    -- SQL Why:  At Confirmation Stage, we need to make sure that all the
    --           remaining records in the purge list are still eligible for
    --           purging

    UPDATE  po_purge_req_list PPRL
    SET     double_check_flag = 'N'
    WHERE   double_check_flag = 'Y'
    AND     NOT EXISTS (
                SELECT  NULL
                FROM    po_requisition_headers RH
                WHERE   RH.requisition_header_id  =
                        PPRL.requisition_header_id
                AND     RH.last_update_date <= p_last_activity_date
                AND     (RH.closed_code = 'FINALLY CLOSED'
                        OR RH.authorization_status = 'CANCELLED')
                AND     NOT EXISTS (
                            SELECT  NULL
                            FROM    po_requisition_lines RL
                            WHERE   RL.requisition_header_id =
                                    RH.requisition_header_id
                            AND     NVL(RL.modified_by_agent_flag,'N') = 'N'
                            AND     (RL.last_update_date > p_last_activity_date
                                     OR
                                     RL.line_location_id IS NOT NULL
                                     OR
                                     RL.source_type_code = 'INVENTORY'
                                     OR
                                     EXISTS (
                                        SELECT  NULL
                                        FROM    po_price_differentials PPD
                                        WHERE   PPD.entity_type = 'REQ LINE'
                                        AND     PPD.entity_id =
                                                RL.requisition_line_id
                                        AND     PPD.last_update_date >
                                                p_last_activity_date)
                                     OR
                                     EXISTS (
                                        SELECT  NULL
                                        FROM    po_req_distributions RD
                                        WHERE   RD.requisition_line_id =
                                                RL.requisition_line_id
                                        AND     RD.last_update_date >
                                                p_last_activity_date))));

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Excluded ' || SQL%ROWCOUNT || ' reqs in purge list'
        );
        END IF;
    END IF;

    l_progress := '010';

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'REQ'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END confirm_simple_req;


-----------------------------------------------------------------------
--Start of Comments
--Name: confirm_po
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function:
--  Exclude pos that have been updated recently from the purge list
--Parameters:
--IN:
--p_purge_category
--  Describe what type of documents user wants to purge.
--p_last_activity_date
--  Cutoff date of the purge process. req will not be purged if it has been
--  updated since this date
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE confirm_po
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2,
  p_last_activity_date  IN          DATE
) IS

l_api_name          VARCHAR2(50) := 'confirm_po';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO) THEN

        l_progress := '010';

        -- SQL What: Exclude POs that are no longer eligible for purging. The
        --           logic is similar to the one during initiation stage, but
        --           this time we are excluding records that are not eligible
        --           rather than including records that are eligible
        -- SQL Why:  At Confirmation Stage, we need to make sure that all the
        --           remaining records in the purge list are still eligible for
        --           purging

        UPDATE  po_purge_po_list PPL
        SET     double_check_flag = 'N'
        WHERE   double_check_flag = 'Y'
        AND     NOT EXISTS (
                    SELECT  NULL
                    FROM    po_headers PH
                    WHERE   PH.po_header_id = PPL.po_header_id
                    AND     PH.type_lookup_code IN ('STANDARD', 'BLANKET',
                                                    'PLANNED', 'CONTRACT')
                    AND     (PH.cancel_flag = 'Y'
                             OR PH.closed_code = 'FINALLY CLOSED')
                    AND     PH.last_update_date <= p_last_activity_date
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_releases PR
                             WHERE  PR.po_header_id = PPL.po_header_id
                             AND    PR.last_update_date > p_last_activity_date)
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_lines PL
                             WHERE  PL.po_header_id = PPL.po_header_id
                             AND    (PL.last_update_date > p_last_activity_date
                                     OR
                                     EXISTS
                                     (SELECT NULL
                                      FROM   po_price_differentials PPD
                                      WHERE  PPD.entity_type IN ('PO LINE',
                                                                'BLANKET LINE')
                                      AND    PPD.entity_id = PL.po_line_id
                                      AND    PPD.last_update_date >
                                             p_last_activity_date)))
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_line_locations PLL
                             WHERE  PLL.po_header_id = PPL.po_header_id
                             AND    (PLL.last_update_date >p_last_activity_date
                                     OR
                                     EXISTS
                                     (SELECT NULL
                                      FROM   po_price_differentials PPD
                                      WHERE  PPD.entity_type = 'PRICE BREAK'
                                      AND    PPD.entity_id =
                                             PLL.line_location_id
                                      AND    PPD.last_update_date >
                                             p_last_activity_date)))
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_distributions PD
                             WHERE  PD.po_header_id = PPL.po_header_id
                             AND    (PD.last_update_date > p_last_activity_date
                                     OR
                                     EXISTS
                                     (SELECT NULL
                                      FROM   ap_invoice_distributions AD
                                      WHERE  AD.po_distribution_id =
                                             PD.po_distribution_id))));

    ELSIF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV) THEN

        l_progress := '020';

        -- SQL What: Exclude POs that are no longer eligible for purging. The
        --           logic is similar to the one during initiation stage, but
        --           this time we are excluding records that are not eligible
        --           rather than including records that are eligible
        -- SQL Why:  At Confirmation Stage, we need to make sure that all the
        --           remaining records in the purge list are still eligible for
        --           purging

        UPDATE  po_purge_po_list PPL
        SET     double_check_flag = 'N'
        WHERE   double_check_flag = 'Y'
        AND     NOT EXISTS (
                    SELECT  NULL
                    FROM    po_headers PH
                    WHERE   PH.po_header_id = PPL.po_header_id
                    AND     PH.type_lookup_code IN ('STANDARD', 'BLANKET',
                                                    'PLANNED', 'CONTRACT')
                    AND     (PH.cancel_flag = 'Y'
                             OR PH.closed_code = 'FINALLY CLOSED')
                    AND     PH.last_update_date <= p_last_activity_date
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_releases PR
                             WHERE  PR.po_header_id = PH.po_header_id
                             AND    PR.last_update_date > p_last_activity_date)
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_lines PL
                             WHERE  PL.po_header_id = PH.po_header_id
                             AND    (PL.last_update_date > p_last_activity_date
                                     OR
                                     EXISTS
                                     (SELECT NULL
                                      FROM   po_price_differentials PPD
                                      WHERE  PPD.entity_type IN ('PO LINE',
                                                                 'BLANKET LINE')
                                      AND    PPD.entity_id = PL.po_line_id
                                      AND    PPD.last_update_date >
                                             p_last_activity_date)))
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_line_locations PLL
                             WHERE  PLL.po_header_id = PH.po_header_id
                             AND    (PLL.last_update_date > p_last_activity_date
                                     OR
                                     EXISTS
                                     (SELECT NULL
                                      FROM   po_price_differentials PPD
                                      WHERE  PPD.entity_type = 'PRICE BREAK'
                                      AND    PPD.entity_id =
                                             PLL.line_location_id
                                      AND    PPD.last_update_date >
                                             p_last_activity_date)))
                    AND     NOT EXISTS
                            (SELECT NULL
                             FROM   po_distributions PD
                             WHERE  PD.po_header_id = PH.po_header_id
                             AND    PD.last_update_date >
                                    p_last_activity_date));

    END IF; -- purge_category = 'SIMPLE PO'


    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Excluded ' || SQL%ROWCOUNT || ' pos frm purge ' ||
                       'list. p_purge_category = ' || p_purge_category
        );
        END IF;
    END IF;

    l_progress := '030';

    -- SQL What: Exclude REQs that are no longer eligible for purging. The
    --           logic is similar to the one during initiation stage, but
    --           this time we are excluding records that are not eligible
    --           rather than including records that are eligible
    -- SQL Why:  At Confirmation Stage, we need to make sure that all the
    --           remaining records in the purge list are still eligible for
    --           purging
    UPDATE po_purge_req_list PPRL
    SET     double_check_flag = 'N'
    WHERE   double_check_flag = 'Y'
    AND     NOT EXISTS (
                SELECT  NULL
                FROM    po_requisition_headers RH
                WHERE   RH.requisition_header_id  =
                        PPRL.requisition_header_id
                AND     RH.last_update_date <= p_last_activity_date
                AND     (RH.closed_code = 'FINALLY CLOSED'
                        OR RH.authorization_status = 'CANCELLED')
                AND     NOT EXISTS (
                            SELECT  NULL
                            FROM    po_requisition_lines RL
                            WHERE   RL.requisition_header_id =
                                    RH.requisition_header_id
                            AND     NVL(RL.modified_by_agent_flag,'N') = 'N'
                            AND     (RL.last_update_date > p_last_activity_date
                                     OR
                                     RL.source_type_code = 'INVENTORY'
                                     OR
                                     EXISTS (
                                        SELECT  NULL
                                        FROM    po_price_differentials PPD
                                        WHERE   PPD.entity_type = 'REQ LINE'
                                        AND     PPD.entity_id =
                                                RL.requisition_line_id
                                        AND     PPD.last_update_date >
                                                p_last_activity_date)
                                     OR
                                     EXISTS (
                                        SELECT  NULL
                                        FROM    po_req_distributions RD
                                        WHERE   RD.requisition_line_id =
                                                RL.requisition_line_id
                                        AND     RD.last_update_date >
                                                p_last_activity_date))));


    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Excluded ' || SQL%ROWCOUNT || ' reqs frm purge ' ||
                       'list'
        );
        END IF;
    END IF;

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'REQ'
    );

    PO_AP_PURGE_UTIL_PVT.log_purge_list_count
    ( p_module  => l_module || l_progress,
      p_entity  => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END confirm_po;


-----------------------------------------------------------------------
--Start of Comments
--Name: get_purge_list_range
--Pre-reqs:
--Modifies: None
--Locks:
--  None
--Function:
--  return the min id and max id among all documents in the purge list
--Parameters:
--IN:
--p_category
--  REQ - get the values from req purge list
--  PO  - get the values from po purge list
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--x_lower_limit
--  min id in the purge list
--x_upper_limit
--  max id in the purge list
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE get_purge_list_range
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_category            IN          VARCHAR2,
  x_lower_limit         OUT NOCOPY  NUMBER,
  x_upper_limit         OUT NOCOPY  NUMBER
) IS

l_api_name          VARCHAR2(50) := 'get_purge_list_range';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_category = 'REQ') THEN
        l_progress := '010';

        -- SQL What: Get the lower and upper bound of the req header ids in
        --           req purge list
        -- SQL Why:  They are return values
        SELECT  NVL ( MIN (PPRL.requisition_header_id), -1 ),
                NVL ( MAX (PPRL.requisition_header_id), -1 )
        INTO    x_lower_limit,
                x_upper_limit
        FROM    po_purge_req_list PPRL
        WHERE   PPRL.double_check_flag = 'Y';

    ELSIF (p_category = 'PO') THEN
        l_progress := '020';

        -- SQL What: Get the lower and upper bound of the po header ids in
        --           po purge list
        -- SQL Why:  They are return values
        SELECT  NVL ( MIN (PPL.po_header_id), -1 ),
                NVL ( MAX (PPL.po_header_id), -1 )
        INTO    x_lower_limit,
                x_upper_limit
        FROM    po_purge_po_list PPL
        WHERE   PPL.double_check_flag = 'Y';

    END IF; -- p_category


    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'p_category = ' || p_category || ', lower_limit = ' ||
                       x_lower_limit || ', higher_limit = ' || x_upper_limit
        );
        END IF;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END get_purge_list_range;


-----------------------------------------------------------------------
--Start of Comments
--Name: summarize_reqs
--Pre-reqs:
--Modifies: po_history_requisitions
--Locks:
--  None
--Function:
--  Record necessary information for requisitions that are about to be purged
--Parameters:
--IN:
--p_purge_name
--  Name of this purge process
--p_range_size
--  The id range size of the documents being inserted into history tables
--  per commit cycle
--p_req_lower_limit
--  min id among all reqs to be purged
--p_req_upper_limit
--  max id among all reqs to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE summarize_reqs
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_range_size          IN          NUMBER,
  p_req_lower_limit     IN          NUMBER,
  p_req_upper_limit     IN          NUMBER
) IS

l_api_name          VARCHAR2(50) := 'summarize_reqs';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_range_inserted    VARCHAR2(1);
l_range_low         NUMBER;
l_range_high        NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_req_lower_limit = -1) THEN
        RETURN;
    END IF;

    l_range_low := p_req_lower_limit;
    l_range_high := p_req_lower_limit + p_range_size;

    LOOP
        l_progress := '010';

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'range_low=' || l_range_low ||
                           ' range_high=' || l_range_high
            );
            END IF;
        END IF;

        BEGIN

            -- SQL What: Return 'Y' if there are req records being inserted
            --           inot req history table by the current batch
            -- SQL Why:  We need to make sure that the current batch of records
            --           has not been inserted into history tables; otherwise
            --           we may end up inserting the same records multiple
            --           times.
            SELECT  'Y'
            INTO    l_range_inserted
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_requisition_headers PRH,
                                po_history_requisitions PHR
                        WHERE   PRH.segment1 = PHR.segment1
                        AND     PRH.type_lookup_code = PHR.type_lookup_code
                        AND     PHR.purge_name = p_purge_name
                        AND     PRH.requisition_header_id BETWEEN l_range_low
                                                          AND     l_range_high);

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_progress := '020';
            l_range_inserted := 'N';
        END;


        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'range inserted = ' || l_range_inserted
            );
            END IF;
        END IF;

        IF (l_range_inserted = 'N') THEN
            l_progress := '030';

            -- bug3256316
            -- Also calculate amount for amount based lines

            -- SQL What: Insert requisition information into history tables
            -- SQL Why:  Summarization functionality

            INSERT INTO po_history_requisitions
            ( segment1,
              type_lookup_code,
              creation_date,
              requisition_total,
              preparer_name,
              purge_name,
              org_id  -- bug5446437
            )
            SELECT  RH.segment1,
                    RH.type_lookup_code,
                    RH.creation_date,
                    SUM( DECODE (RL.amount,
                                 NULL, RL.quantity * RL.unit_price,
                                 RL.amount)),
                    PAPF.full_name,
                    p_purge_name,
                    RH.org_id -- bug5446437
            FROM    po_purge_req_list PRL,
                    per_all_people_f PAPF,
                    po_requisition_headers RH,
                    po_requisition_lines RL
            WHERE   PRL.requisition_header_id = RH.requisition_header_id
            AND     RH.requisition_header_id = RL.requisition_header_id
            AND     RH.preparer_id = PAPF.person_id
            AND     TRUNC(SYSDATE) BETWEEN PAPF.effective_start_date
                                   AND     PAPF.effective_end_date
            AND     PRL.double_check_flag = 'Y'
            AND     PRL.requisition_header_id BETWEEN l_range_low
                                              AND     l_range_high
            GROUP BY    RH.segment1,
                        RH.type_lookup_code,
                        RH.creation_date,
                        PAPF.full_name,
                        RH.org_id; -- bug5446437
            COMMIT;

        END IF; -- l_range_inserted = 'N'


        l_range_low := l_range_high + 1;
        l_range_high := l_range_low + p_range_size;

        IF (l_range_low > p_req_upper_limit) THEN
            l_progress := '040';

            EXIT;
        END IF;

    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END summarize_reqs;


-----------------------------------------------------------------------
--Start of Comments
--Name: summarize_pos
--Pre-reqs:
--Modifies: po_history_pos
--Locks:
--  None
--Function:
--  Record necessary information for pos that are about to be purged
--Parameters:
--IN:
--p_purge_name
--  Name of this purge process
--p_range_size
--  The id range size of the documents being inserted into history tables
--  per commit cycle
--p_po_lower_limit
--  min id among all pos to be purged
--p_po_upper_limit
--  max id among all pos to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE summarize_pos
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
) IS

l_api_name          VARCHAR2(50) := 'summarize_pos';
l_progress          VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_range_inserted    VARCHAR2(1);
l_range_low         NUMBER;
l_range_high        NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_po_lower_limit = -1) THEN
        RETURN;
    END IF;

    l_range_low := p_po_lower_limit;
    l_range_high := p_po_lower_limit + p_range_size;

    LOOP
        l_progress := '010';

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'range_low=' || l_range_low ||
                           ' range_high=' || l_range_high
            );
            END IF;
        END IF;

        BEGIN

            -- SQL What: Return 'Y' if there are po records being inserted
            --           inot po history table by the current batch
            -- SQL Why:  We need to make sure that the current batch of records
            --           has not been inserted into history tables; otherwise
            --           we may end up inserting the same records multiple
            --           times.
            SELECT  'Y'
            INTO    l_range_inserted
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_headers PH,
                                po_history_pos PHP
                        WHERE   PH.segment1 = PHP.segment1
                        AND     PH.type_lookup_code = PHP.type_lookup_code
                        AND     PHP.purge_name = p_purge_name
                        AND     PH.po_header_id BETWEEN l_range_low
                                                AND     l_range_high);

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_progress := '020';
            l_range_inserted := 'N';
        END;


        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'range inserted = ' || l_range_inserted
            );
            END IF;
        END IF;

        IF (l_range_inserted = 'N') THEN  -- current batch is not inserted
            l_progress := '030';

            -- SQL What: Insert data into history tables for records in the
            --           purge list that are Standard POs, Planned POs, and
            --           Local Blanket PA
            -- SQL Why:  Need to record data in history table before actual
            --           purge happens

            INSERT INTO po_history_pos
            ( segment1,
              type_lookup_code,
              vendor_id,
              vendor_site_code,
              po_total,
              currency_code,
              agent_name,
              creation_date,
              purge_name,
              org_id -- bug5446437
            )
            SELECT  PH.segment1,
                    PH.type_lookup_code,
                    PH.vendor_id,
                    VDS.vendor_site_code,
                    NVL (ROUND (
                            SUM (
                                DECODE (
                                    PLL.quantity,
                                    NULL,
                                    PLL.amount - NVL(PLL.amount_cancelled, 0),
                                    (PLL.quantity - NVL(PLL.quantity_cancelled,
                                                        0)) *
                                      PLL.price_override)),
                            2),
                         0),
                    PH.currency_code,
                    PAPF.full_name,
                    PH.creation_date,
                    p_purge_name,
                    PH.org_id -- bug5446437
            FROM    per_all_people_f PAPF,
                    po_vendor_sites VDS,
                    po_headers PH,
                    po_line_locations PLL,
                    po_purge_po_list PPL
            WHERE   PPL.po_header_id BETWEEN l_range_low AND l_range_high
            AND     PPL.double_check_flag = 'Y'
            AND     PPL.po_header_id = PH.po_header_id
            AND     NVL(PH.global_agreement_flag, 'N') = 'N'
            AND     PH.type_lookup_code IN ('STANDARD', 'PLANNED', 'BLANKET')
            AND     PH.po_header_id = PLL.po_header_id(+)
            AND     PLL.shipment_type (+) <> 'PRICE BREAK'
            AND     PH.agent_id = PAPF.person_id
            AND     TRUNC(SYSDATE) BETWEEN PAPF.effective_start_date
                                   AND     PAPF.effective_end_date
            AND     PH.vendor_site_id = VDS.vendor_site_id
            GROUP BY  PH.segment1,
                      PH.type_lookup_code,
                      PH.vendor_id,
                      VDS.vendor_site_code,
                      PH.currency_code,
                      PAPF.full_name,
                      PH.creation_date,
                      PH.org_id; -- bug5446437


            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string
                ( log_level => FND_LOG.LEVEL_STATEMENT,
                  module    => l_module || l_progress,
                  message   => 'Rows inserted for std/planned po/local bpa:' ||
                               SQL%ROWCOUNT
                );
                END IF;
            END IF;

            l_progress := '040';

            -- SQL What: Insert data into history tables for records in the
            --           purge list that are Global Blanket PA
            -- SQL Why:  Need to record data in history table before actual
            --           purge happens

            INSERT INTO po_history_pos
            ( segment1,
              type_lookup_code,
              vendor_id,
              vendor_site_code,
              po_total,
              currency_code,
              agent_name,
              creation_date,
              purge_name,
              org_id  -- bug5446437
            )
            SELECT  PH.segment1,
                    PH.type_lookup_code,
                    PH.vendor_id,
                    VDS.vendor_site_code,
                    NVL (ROUND (
                            SUM (
                                DECODE (
                                    PLL.quantity,
                                    NULL,
                                    PLL.amount - NVL(PLL.amount_cancelled, 0),
                                    (PLL.quantity - NVL(PLL.quantity_cancelled,
                                                        0)) *
                                      PLL.price_override)),
                            2),
                         0),
                    PH.currency_code,
                    PAPF.full_name,
                    PH.creation_date,
                    p_purge_name,
                    PH.org_id -- bug5446437
            FROM    per_all_people_f PAPF,
                    po_vendor_sites VDS,
                    po_headers PH,
                    po_line_locations_all PLL,
                    po_purge_po_list PPL
            WHERE   PPL.po_header_id BETWEEN l_range_low AND l_range_high
            AND     PPL.double_check_flag = 'Y'
            AND     PPL.po_header_id = PH.po_header_id
            AND     PH.global_agreement_flag = 'Y'
            AND     PH.type_lookup_code = 'BLANKET'
            AND     PH.po_header_id = PLL.from_header_id(+)
            AND     PH.agent_id = PAPF.person_id
            AND     TRUNC(SYSDATE) BETWEEN PAPF.effective_start_date
                                   AND     PAPF.effective_end_date
            AND     PH.vendor_site_id = VDS.vendor_site_id
            GROUP BY  PH.segment1,
                      PH.type_lookup_code,
                      PH.vendor_id,
                      VDS.vendor_site_code,
                      PH.currency_code,
                      PAPF.full_name,
                      PH.creation_date,
                      PH.org_id; -- bug5446437

            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string
                ( log_level => FND_LOG.LEVEL_STATEMENT,
                  module    => l_module || l_progress,
                  message   => 'Rows inserted for gbpa:' || SQL%ROWCOUNT
                );
                END IF;
            END IF;

            l_progress := '050';

            -- SQL What: Insert data into history tables for records in the
            --           purge list that are contracts
            -- SQL Why:  Need to record data in history table before actual
            --           purge happens

            INSERT INTO po_history_pos
            ( segment1,
              type_lookup_code,
              vendor_id,
              vendor_site_code,
              po_total,
              currency_code,
              agent_name,
              creation_date,
              purge_name,
              org_id -- bug5446437
            )
            SELECT  PH.segment1,
                    PH.type_lookup_code,
                    PH.vendor_id,
                    VDS.vendor_site_code,
                    NVL (ROUND (
                            SUM (
                                DECODE (
                                    PLL.quantity,
                                    NULL,
                                    PLL.amount - NVL(PLL.amount_cancelled, 0),
                                    (PLL.quantity - NVL(PLL.quantity_cancelled,
                                                        0)) *
                                      PLL.price_override)),
                            2),
                         0),
                    PH.currency_code,
                    PAPF.full_name,
                    PH.creation_date,
                    p_purge_name,
                    PH.org_id -- bug5446437
            FROM   per_all_people_f PAPF,
                    po_vendor_sites VDS,
                    po_headers PH,
                    po_lines_all POL,
                    po_line_locations_all PLL,
                    po_purge_po_list PPL
            WHERE  PPL.po_header_id BETWEEN l_range_low AND l_range_high
            AND    PPL.double_check_flag = 'Y'
            AND    PPL.po_header_id = PH.po_header_id
            AND    PH.type_lookup_code = 'CONTRACT'
            AND    PH.po_header_id = POL.contract_id (+)
            AND    POL.po_line_id = PLL.po_line_id (+)
            AND    PH.agent_id = PAPF.person_id
            AND    TRUNC(SYSDATE) BETWEEN PAPF.effective_start_date
                                   AND     PAPF.effective_end_date
            AND    PH.vendor_site_id = VDS.vendor_site_id
            GROUP BY PH.segment1,
                      PH.type_lookup_code,
                      PH.vendor_id,
                      VDS.vendor_site_code,
                      PH.currency_code,
                      PAPF.full_name,
                      PH.creation_date,
                      PH.org_id; -- bug5446437

            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string
                ( log_level => FND_LOG.LEVEL_STATEMENT,
                  module    => l_module || l_progress,
                  message   => 'Rows inserted for contracts:' || SQL%ROWCOUNT
                );
                END IF;
            END IF;

            l_progress := '060';

            -- SQL What: For each release that is going to be purged, insert
            --           its related information into purge history table
            -- SQl Why:  Need to record data in history table before actual
            --           purge happens

            INSERT INTO po_history_pos
            ( segment1,
              type_lookup_code,
              vendor_id,
              vendor_site_code,
              release_num,
              po_total,
              currency_code,
              agent_name,
              creation_date,
              purge_name,
              org_id -- bug5446437
            )
            SELECT  PH.segment1,
                    PH.type_lookup_code,
                    PH.vendor_id,
                    VDS.vendor_site_code,
                    PREL.release_num,
                    NVL (ROUND (
                            SUM (
                                DECODE (
                                    PLL.quantity,
                                    NULL,
                                    PLL.amount - NVL(PLL.amount_cancelled, 0),
                                    (PLL.quantity - NVL(PLL.quantity_cancelled,
                                                        0)) *
                                      PLL.price_override)),
                            2),
                         0),
                    PH.currency_code,
                    PAPF.full_name,
                    PH.creation_date,
                    p_purge_name,
                    PH.org_id -- bug5446437
            FROM    po_vendor_sites VDS,
                    per_all_people_f PAPF,
                    po_releases PREL,
                    po_headers PH,
                    po_line_locations PLL,
                    po_purge_po_list PPL
            WHERE   PPL.po_header_id = PH.po_header_id
            AND     PH.po_header_id = PREL.po_header_id
            AND     PREL.po_release_id = PLL.po_release_id
            AND     PLL.shipment_type IN ('SCHEDULED', 'BLANKET')
            AND     PH.vendor_site_id = VDS.vendor_site_id
            AND     PH.agent_id = PAPF.person_id
            AND     TRUNC(SYSDATE) BETWEEN PAPF.effective_start_date
                                   AND     PAPF.effective_end_date
            AND     PPL.double_check_flag = 'Y'
            AND     PPL.po_header_id BETWEEN l_range_low
                                     AND     l_range_high
            GROUP BY  PH.segment1,
                      PH.type_lookup_code,
                      PH.vendor_id,
                      VDS.vendor_site_code,
                      PREL.release_num,
                      PH.currency_code,
                      PAPF.full_name,
                      PH.creation_date,
                      PH.org_id; -- bug5446437

            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string
                ( log_level => FND_LOG.LEVEL_STATEMENT,
                  module    => l_module || l_progress,
                  message   => 'Rows inserted for releases: ' || SQL%ROWCOUNT
                );
                END IF;
            END IF;

            COMMIT;
        END IF;  -- l_range_inserted = 'N'

        l_range_low := l_range_high + 1;
        l_range_high := l_range_low + p_range_size;

        IF (l_range_low > p_po_upper_limit) THEN
            l_progress := '070';

            EXIT;
        END IF;

    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END summarize_pos;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_reqs
--Pre-reqs:
--Modifies: Multiple REQ transaction tables
--Locks:
--  None
--Function:
--  Purge POs that are remaining in the purge list
--Parameters:
--IN:
--p_range_size
--  The id range size of the documents being purged per commit cycle
--p_req_lower_limit
--  min id among all reqs to be purged
--p_req_upper_limit
--  max id among all reqs to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_reqs
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_size          IN          NUMBER,
  p_req_lower_limit     IN          NUMBER,
  p_req_upper_limit     IN          NUMBER
) IS

TYPE num_tbltyp IS TABLE OF NUMBER;
l_ids_tbl       num_tbltyp;


l_api_name      VARCHAR2(50) := 'delete_reqs';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_range_low     NUMBER;
l_range_high    NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_req_lower_limit = -1) THEN
        RETURN;
    END IF;

    --SQL What: This cursor will divide po_purge_req_list into groups of
    --          records with size p_range_size. Each fetch will return the
    --          highest req id of that group
    --SQL Why:  We want to delete data in smaller groups to avoid running
    --          out of rollback segments

    SELECT  PPRL2.req_header_id
    BULK COLLECT INTO l_ids_tbl
    FROM    (SELECT PPRL.requisition_header_id req_header_id,
                    MOD(ROWNUM, p_range_size) mod_result
             FROM   po_purge_req_list PPRL
             WHERE  PPRL.double_check_flag = 'Y'
             ORDER BY PPRL.requisition_header_id) PPRL2
    WHERE   PPRL2.mod_result = 0;

    l_progress := '010';

    l_range_low := p_req_lower_limit;

    FOR i IN 0..l_ids_tbl.COUNT LOOP

        IF i = l_ids_tbl.COUNT THEN
            l_range_high := p_req_upper_limit;
        ELSE
            l_range_high := l_ids_tbl(i+1);
        END IF;

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'range_low = ' || l_range_low ||
                           ', range_high = ' || l_range_high
            );
            END IF;
        END IF;

        l_progress := '015';

        -- Before deleting reqs, delate the records that
        -- reference these documents.
        PO_AP_PURGE_UTIL_PVT.delete_req_related_records
        ( x_return_status   => l_return_status,
          p_range_low       => l_range_low,
          p_range_high      => l_range_high
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '020';

        --SQL What: Delete req headers with id within the range
        DELETE
        FROM    po_requisition_headers RH
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_req_list PPRL
                    WHERE   PPRL.requisition_header_id =
                            RH.requisition_header_id
                    AND     PPRL.double_check_flag = 'Y'
                    AND     PPRL.requisition_header_id BETWEEN l_range_low
                                                       AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from RH'
            );
            END IF;
        END IF;

        l_progress := '030';

        --SQL What: Delete req distributions with header within the range
        DELETE
        FROM    po_req_distributions RD
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_req_list PPRL,
                            po_requisition_lines RL
                    WHERE   PPRL.requisition_header_id =
                            RL.requisition_header_id
                    AND     RL.requisition_line_id =
                            RD.requisition_line_id
                    AND     PPRL.double_check_flag = 'Y'
                    AND     PPRL.requisition_header_id BETWEEN l_range_low
                                                       AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from RD'
            );
            END IF;
        END IF;

        l_progress := '040';

        --SQL What: Delete req lines with header within the range
        DELETE
        FROM    po_requisition_lines RL
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_req_list PPRL
                    WHERE   PPRL.requisition_header_id =
                            RL.requisition_header_id
                    AND     PPRL.double_check_flag = 'Y'
                    AND     PPRL.requisition_header_id BETWEEN l_range_low
                                                       AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from RL'
            );
            END IF;
        END IF;

        l_progress := '050';
        --SQL What: Delete req action history with header within the range
        DELETE
        FROM    po_action_history PA
        WHERE   PA.object_type_code = 'REQUISITION'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_req_list PPRL
                    WHERE   PPRL.requisition_header_id = PA.object_id
                    AND     PPRL.double_check_flag = 'Y'
                    AND     PPRL.requisition_header_id BETWEEN l_range_low
                                                       AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec frm act_history'
            );
            END IF;
        END IF;

        l_progress := '060';

        COMMIT;

        l_range_low := l_range_high + 1;

        IF (l_range_low > p_req_upper_limit) THEN
            EXIT;
        END IF;

    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_reqs;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_pos
--Pre-reqs:
--Modifies: Multiple PO transaction tables
--Locks:
--  None
--Function:
--  Purge POs that are remaining in the purge list
--Parameters:
--IN:
--p_range_size
--  The number of documents being purged per commit cycle
--p_po_lower_limit
--  min id among all reqs to be purged
--p_po_upper_limit
--  max id among all reqs to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_pos
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
) IS

TYPE num_tbltyp IS TABLE OF NUMBER;
l_ids_tbl       num_tbltyp;

--<R12 eTax Integration Start>
l_po_header_id_tbl      PO_TBL_NUMBER;
l_type_lookup_code_tbl  PO_TBL_VARCHAR30; -- bug5446437
l_po_release_id_tbl     PO_TBL_NUMBER;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
--<R12 eTax Integration End>

l_api_name      VARCHAR2(50) := 'delete_pos';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

-- bug3209532
l_pos_dynamic_call VARCHAR2(2000);

l_range_low     NUMBER;
l_range_high    NUMBER;
l_return_status VARCHAR2(1);
BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_po_lower_limit = -1) THEN
        RETURN;
    END IF;

    --SQL What: This cursor will divide po_purge_po_list into groups of
    --          records with size p_range_size. Each fetch will return the
    --          highest req id of that group
    --SQL Why:  We want to delete data in smaller groups to avoid running
    --          out of rollback segments

    SELECT  PPL2.po_header_id
    BULK COLLECT INTO l_ids_tbl
    FROM    (SELECT PPL.po_header_id po_header_id,
                    MOD(ROWNUM, p_range_size) mod_result
             FROM   po_purge_po_list PPL
             WHERE  PPL.double_check_flag = 'Y'
             ORDER BY PPL.po_header_id) PPL2
    WHERE   PPL2.mod_result = 0;

    l_progress := '010';

    l_range_low := p_po_lower_limit;

    FOR i IN 0..l_ids_tbl.COUNT LOOP

        IF i = l_ids_tbl.COUNT THEN
            l_range_high := p_po_upper_limit;
        ELSE
            l_range_high := l_ids_tbl(i+1);
        END IF;

        l_progress := '015';

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'range_low = ' || l_range_low ||
                           ', range_high = ' || l_range_high
            );
            END IF;
        END IF;

        -- Before deleting the po documents, delate the records that
        -- reference these documents.
        PO_AP_PURGE_UTIL_PVT.delete_po_related_records
        ( x_return_status   => l_return_status,
          p_range_low       => l_range_low,
          p_range_high      => l_range_high
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '020';

        --SQL What: Delete po headers within the range
        DELETE
        FROM    po_headers PH
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PH.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high)
        --<R12 eTax Integration Start>
        RETURNING po_header_id, type_lookup_code
        BULK COLLECT INTO l_po_header_id_tbl, l_type_lookup_code_tbl;
        --<R12 eTax Integration End>

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PH'
            );
            END IF;
        END IF;

        l_progress := '030';

        --SQL What: Delete po headers archive within the range
        DELETE
        FROM    po_headers_archive PHA
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PHA.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PHA'
            );
            END IF;
        END IF;

        l_progress := '040';

        --SQL What: Delete po lines with header within the range
        DELETE
        FROM    po_lines PL
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PL.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PL'
            );
            END IF;
        END IF;

         --<Unified Catalog R12: Start>
         l_progress := '045';

          --SQL What: Delete PO Attr with line_ids within the range
          DELETE
          FROM    PO_ATTRIBUTE_VALUES POATR
          WHERE   EXISTS (
                      SELECT  NULL
                      FROM    po_purge_po_list PPL,
                              po_lines_all POL
                      WHERE   PPL.po_header_id = POL.po_header_id
                      AND     POATR.po_line_id = POL.po_line_id
                      AND     PPL.double_check_flag = 'Y'
                      AND     PPL.po_header_id BETWEEN l_range_low
                                               AND     l_range_high);

          IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string
              ( log_level => FND_LOG.LEVEL_STATEMENT,
                module    => l_module || l_progress,
                message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from POATR'
              );
              END IF;
          END IF;

         l_progress := '048';

          --SQL What:Delete po TLP with line_ids within the range
          DELETE
          FROM    PO_ATTRIBUTE_VALUES_TLP POTLP
          WHERE   EXISTS (
                      SELECT  NULL
                      FROM    po_purge_po_list PPL,
                              po_lines_all POL
                      WHERE   PPL.po_header_id = POL.po_header_id
                      AND     POTLP.po_line_id = POL.po_line_id
                      AND     PPL.double_check_flag = 'Y'
                      AND     PPL.po_header_id BETWEEN l_range_low
                                               AND     l_range_high);

          IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string
              ( log_level => FND_LOG.LEVEL_STATEMENT,
                module    => l_module || l_progress,
                message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from POTLP'
              );
              END IF;
          END IF;
         --<Unified Catalog R12: End>

        l_progress := '050';

        --SQL What: Delete po lines archive with header within the range
        DELETE
        FROM    po_lines_archive PLA
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PLA.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PLA'
            );
            END IF;
        END IF;

         --<Unified Catalog R12: Start>
         l_progress := '055';

          --SQL What: Delete po Attr Archive with line_ids within the range
          DELETE
          FROM    PO_ATTR_VALUES_ARCHIVE POATRA
          WHERE   EXISTS (
                      SELECT  NULL
                      FROM    po_purge_po_list PPL,
                              po_lines_all POL
                      WHERE   PPL.po_header_id = POL.po_header_id
                      AND     POATRA.po_line_id = POL.po_line_id
                      AND     PPL.double_check_flag = 'Y'
                      AND     PPL.po_header_id BETWEEN l_range_low
                                               AND     l_range_high);

          IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string
              ( log_level => FND_LOG.LEVEL_STATEMENT,
                module    => l_module || l_progress,
                message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from POATRA'
              );
              END IF;
          END IF;

         --SQL What: Delete po TLP Archive with line_ids within the range
         l_progress := '058';

          DELETE
          FROM    PO_ATTR_VALUES_TLP_ARCHIVE POTLPA
          WHERE   EXISTS (
                      SELECT  NULL
                      FROM    po_purge_po_list PPL,
                              po_lines_all POL
                      WHERE   PPL.po_header_id = POL.po_header_id
                      AND     POTLPA.po_line_id = POL.po_line_id
                      AND     PPL.double_check_flag = 'Y'
                      AND     PPL.po_header_id BETWEEN l_range_low
                                               AND     l_range_high);

          IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string
              ( log_level => FND_LOG.LEVEL_STATEMENT,
                module    => l_module || l_progress,
                message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from POTLPA'
              );
              END IF;
          END IF;
         --<Unified Catalog R12: End>

        l_progress := '060';

        --SQL What: Delete po line_loc with header within the range
        DELETE
        FROM    po_line_locations PLL
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PLL.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PLL'
            );
            END IF;
        END IF;

        l_progress := '070';

        --SQL What: Delete po line_loc archive with header within the range
        DELETE
        FROM    po_line_locations_archive PLLA
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PLLA.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PLLA'
            );
            END IF;
        END IF;

        l_progress := '080';

        --SQL What: Delete po distributions with header within the range
        DELETE
        FROM    po_distributions PD
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PD.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PD'
            );
            END IF;
        END IF;

        l_progress := '090';

        --SQL What: Delete po dist archive with header within the range
        DELETE
        FROM    po_distributions_archive PDA
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PDA.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PDA'
            );
            END IF;
        END IF;

        l_progress := '100';

        --SQL What: Delete po releases with header within the range
        DELETE
        FROM    po_releases PR
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PR.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high)
        --<R12 eTax Integration Start>
        RETURNING po_release_id
        BULK COLLECT INTO l_po_release_id_tbl;
        --<R12 eTax Integration End>


        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PR'
            );
            END IF;
        END IF;

        l_progress := '110';

        --SQL What: Delete po releases archive with header within the range
        DELETE
        FROM    po_releases_archive PRA
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PRA.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from PRA'
            );
            END IF;
        END IF;

        l_progress := '120';

        --SQL What: Delete po acceptances with header within the range
        DELETE
        FROM    po_acceptances PA
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PA.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec from po_accept'
            );
            END IF;
        END IF;

        l_progress := '130';

        --SQL What: Delete po action history with header within the range
        DELETE
        FROM    po_action_history PAH
        WHERE   PAH.object_type_code = 'PO'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = PAH.object_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted ' || SQL%ROWCOUNT || ' rec frm act_history'
            );
            END IF;
        END IF;

        l_progress := '140';

        --SQL What: NULL out src doc reference for reqs if the src doc has been
        --          purged
        UPDATE  po_requisition_lines_all PRL
        SET     PRL.blanket_po_header_id = NULL,
                PRL.blanket_po_line_num = NULL,
                PRL.last_update_date = SYSDATE,
                PRL.last_updated_by = FND_GLOBAL.user_id,
                PRL.last_update_login = FND_GLOBAL.login_id
        WHERE   PRL.blanket_po_header_id IS NOT NULL
        AND     PRL.blanket_po_header_id IN (
                        SELECT  po_header_id
                        FROM    po_purge_po_list PPL
                        WHERE   PPL.double_check_flag = 'Y'
                        AND     PPL.po_header_id BETWEEN l_range_low
                                                 AND     l_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Null out DocRef on ' || SQL%ROWCOUNT || 'req lines'
            );
            END IF;
        END IF;
        --<R12 eTax Integration Start> Purge corresponding tax lines
          FORALL i in 1..l_po_header_id_tbl.count
          insert into zx_purge_transactions_gt(
            application_id,
            entity_code,
            event_class_code,
            trx_id
          )
          select
            PO_CONSTANTS_SV.APPLICATION_ID,
/* Bug 14004400: Applicaton id being passed to EB Tax was responsibility id rather than 201 which
               is pased when the tax lines are created. Same should be passed when they are deleted.  */
            PO_CONSTANTS_SV.PO_ENTITY_CODE,
            PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE,
            l_po_header_id_tbl(i)
          from dual
          where l_type_lookup_code_tbl(i) IN ('STANDARD', 'PLANNED');

        FORALL i in 1..l_po_release_id_tbl.count
          insert into zx_purge_transactions_gt(
            application_id,
            entity_code,
            event_class_code,
            trx_id
          )
          select
            PO_CONSTANTS_SV.APPLICATION_ID,
/* Bug 14004400: Applicaton id being passed to EB Tax was responsibility id rather than 201 which
               is pased when the tax lines are created. Same should be passed when they are deleted.  */
            PO_CONSTANTS_SV.REL_ENTITY_CODE,
            PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE,
            l_po_release_id_tbl(i)
          from dual;


        -- call ZX_API_PUB.PURGE_TAX_REPOSITORY in PURGE mode
        ZX_API_PUB.PURGE_TAX_REPOSITORY(
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data );

       --<R12 eTax Integration End> Purge corresponding tax lines

        COMMIT;

        l_range_low := l_range_high + 1;

        IF (l_range_low > p_po_upper_limit) THEN
            EXIT;
        END IF;

    END LOOP;

    l_progress := '150';

    --<ACTION FOR 11iX START>
    --Initiated by: BAO
    --The check for Code Level below will be unnecessary in 11iX.
    --Plan is to only remove the if-else condition and only call
    --POX_SUP_PROF_PRG_GRP.handle_purge instead

    -- PO_AP_PURGE_GRP.purge does two things: Delete from org assignments
    -- and call a POS purge api.
    -- If PO FP level is larger than 11i FPJ, then we should have taken
    -- care of deleting org assignments somewhere else. Hence we only
    -- need to call POS purge api.

    IF (PO_CODE_RELEASE_GRP.Current_Release <
        PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) THEN

        l_progress := '160';

        PO_AP_PURGE_GRP.purge
        ( p_api_version     => 1.0,
          x_return_status   => l_return_status
        );

    ELSE
        l_progress := '170';

        -- Bug 4459947
        -- Do not hardcode schema name.
        -- GSCC checker parses POS as schema name even though it's text
        -- due to extra _. Modified message from _POS_. to POS API.
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'PO Code Level >= FPJ. Call POS API handle_purge only'
            );
            END IF;
        END IF;

        -- bug3209532
        -- We need to use dynamic sql here because POS is not present in 11i
        -- In order to avoid compilation error, we need to put in in dynamic
        -- sql. If this dynamic sql is erroring out due to non-existence
        -- of the package, ignore the error.

  IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string
       ( log_level => FND_LOG.LEVEL_STATEMENT,
         module    => l_module || l_progress,
         message   => 'Before calling POS Purge API'
       );
       END IF;
  END IF;

        -- Call the iSP API to handle events after purge
        l_pos_dynamic_call :=
            'BEGIN
                 POS_SUP_PROF_PRG_GRP.handle_purge (:l_return_status);
             END;';

        BEGIN
            EXECUTE IMMEDIATE l_pos_dynamic_call
            USING   OUT       l_return_status;
        EXCEPTION
        WHEN OTHERS THEN
            IF (SQLCODE = -6550) THEN
                l_return_status := FND_API.G_RET_STS_SUCCESS;

                IF (g_fnd_debug = 'Y') THEN
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
                      FND_LOG.string
                    ( log_level => FND_LOG.LEVEL_PROCEDURE,
                      module    => l_module || l_progress,
                      message   => 'Ignore exception from POS call. SQLERRM: '||
                                   SQLERRM
                    );
                    END IF;
                END IF;
            ELSE
                RAISE;
            END IF;
        END;

  IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string
       ( log_level => FND_LOG.LEVEL_STATEMENT,
         module    => l_module || l_progress,
         message   => 'After calling POS Purge API'
       );
       END IF;
  END IF;

    END IF;  -- Current Release < FPJ

    --<ACTION FOR 11iX END>

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_pos;

--bug3256316
--Added procedure dump_msg_to_log for more detail debug messages
--when exception happens

-----------------------------------------------------------------------
--Start of Comments
--Name: dump_msg_to_log
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Dump all the messages from message stack to FND_LOG
--Parameters:
--IN:
--p_module
--  Place where this procedure is called
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE dump_msg_to_log
( p_module            IN      VARCHAR2
) IS
BEGIN

    IF (g_fnd_debug = 'Y') THEN
        FND_MSG_PUB.reset;

        FOR i IN 1..FND_MSG_PUB.count_msg LOOP
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => p_module,
              message   => 'DUMPMSG: ' ||
                           FND_MSG_PUB.get
                           ( p_msg_index => i,
                             p_encoded   => 'F')
            );
            END IF;
        END LOOP;
    END IF;

END dump_msg_to_log;

-- <DOC PURGE FPJ END>

END PO_AP_PURGE_PVT;

/
