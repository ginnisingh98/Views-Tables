--------------------------------------------------------
--  DDL for Package Body PO_AP_PURGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_PURGE_GRP" AS
/* $Header: POXGPUDB.pls 120.1 2005/06/29 18:36:25 shsiung noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PO_AP_PURGE_GRP';

-- <DOC PURGE FPJ START>
g_fnd_debug     VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_MODULE_PREFIX CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';
-- <DOC PURGE FPJ END>


INVALID_PO_HEADER_ID  EXCEPTION;

/*=========================================================================*/
/*====================== SPECIFICATIONS (PRIVATE) =========================*/
/*=========================================================================*/

FUNCTION  is_global_agreement
(   p_po_header_id    IN  PO_HEADERS.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION referencing_asl_exist
(   p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION referencing_po_exist
(   p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION referencing_req_exist
(   p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION stdpo_ref_ga_check
(  p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

/*=========================================================================*/
/*========================== BODY (PUBLIC) ================================*/
/*=========================================================================*/
/**==========================================================================
 *
 * PUBLIC FUNCTION: validate_purge                     <GA FPI>
 *
 * EFFECTS:
 *     Determines if it is ok to purge the given document.
 *     It is NOT ok to purge the given document if it is a Global Agreement
 *     and there exist any documents (in any status) in enabled OUs referencing
 *     the Global Agreement.
 *
 * RETURNS:
 *     FND_API.G_TRUE ('T') if it is ok to purge the given document.
 *     FND_API.G_FALSE ('F') otherwise.
 *
 *===========================================================================
 */

FUNCTION validate_purge
(
    p_po_header_id          IN          PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN  VARCHAR2
IS
BEGIN

    IF ( is_global_agreement(p_po_header_id) ) THEN

        IF ( PO_AP_PURGE_GRP.referencing_docs_exist(p_po_header_id) ) OR
           ( referencing_asl_exist(p_po_header_id) ) THEN
                                         -- IF no documents/Asl's reference
            return (FND_API.G_FALSE);    -- this GA from another OU
                                         -- THEN, OK to purge document
        ELSE                             -- ELSE, POs exist
                                         -- and NOT OK to purge
            return (FND_API.G_TRUE);

        END IF;

    ELSE      -- if not a GA then check if its std PO referencing an open GA

        IF  ( stdpo_ref_ga_check (p_po_header_id) ) THEN      -- Bug 2812416

            return (FND_API.G_TRUE);

        ELSE                 -- for all other cases OK to purge

            return (FND_API.G_FALSE);

        END IF;

    END IF;

    return (FND_API.G_TRUE);

EXCEPTION

    WHEN OTHERS THEN
        return (FND_API.G_FALSE);

END validate_purge;


/**==========================================================================
 *
 * PUBLIC PROCEDURE: purge                            <GA FPI>
 *
 * MODIFIES:
 *     API Message List - any messages will be appended to the API Message List
 *
 * EFFECTS:
 *     Purges all entries of the given Document ID from the Global Agreements'
 *     Organization Assignment table. (This procedure does not commit.)
 *
 * RETURNS:
 *     x_return_status - (a) FND_API.G_RET_STS_SUCCESS if purge successful
 *                       (b) FND_API.G_RET_STS_ERROR if error during purge
 *                       (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
 *
 *===========================================================================
 */
PROCEDURE purge
(
    p_api_version           IN          NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'purge';
    l_api_version           CONSTANT NUMBER := 1.0;

    l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

    l_progress      VARCHAR2(3);

    -- bug3209532
    l_pos_dynamic_call VARCHAR2(2000);

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS; -- Initialize return status

    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '000';

    DELETE FROM po_ga_org_assignments
    WHERE       po_header_id in (select po_header_id
                                 from po_purge_po_list
                                 where double_check_flag = 'Y');

    l_progress := '010';

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
        USING   OUT       x_return_status;
    EXCEPTION
    WHEN OTHERS THEN
        IF (SQLCODE = -6550) THEN
            x_return_status := FND_API.G_RET_STS_SUCCESS;

            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string
                ( log_level => FND_LOG.LEVEL_STATEMENT,
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
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string
         ( log_level => FND_LOG.LEVEL_PROCEDURE,
           module    => l_module || l_progress,
           message   => 'After calling POS Purge API'
         );
         END IF;
    END IF;

/*
    -- Call the iSP API to handle events after purge
    POS_SUP_PROF_PRG_GRP.handle_purge (
                                       x_return_status
                                      );
*/

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END purge;


/*=========================================================================*/
/*=========================== BODY (PRIVATE) ==============================*/
/*=========================================================================*/

/**==========================================================================
 *
 * PRIVATE FUNCTION: is_global_agreement               <GA FPI>
 *
 * MODIFIES:
 *     API Message List
 *
 * EFFECTS:
 *     Determines if input document is a Global Agreement in the current OU.
 *
 * PARAMETERS:
 *     p_po_header_id - po_header_id of document
 *
 * RETURNS:
 *     TRUE if doc is a Global Agreement owned by current OU. FALSE otherwise.
 *
 * EXCEPTIONS:
 *     INVALID_PO_HEADER_ID - p_po_header_id was not found in PO_HEADERS table.
 *
 *===========================================================================
 */
FUNCTION  is_global_agreement
(
    p_po_header_id    IN  PO_HEADERS.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_global_agreement_flag     PO_HEADERS.global_agreement_flag%TYPE;
BEGIN

    SELECT    global_agreement_flag
    INTO      l_global_agreement_flag
    FROM      po_headers                             -- only look in current OU
    WHERE     po_header_id = p_po_header_id;

    IF ( nvl(l_global_agreement_flag,'N') = 'Y' )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        return (FALSE);

END is_global_agreement;


/**==========================================================================
 *
 * FUNCTION: referencing_docs_exist          <GA FPI>
 *
 * REQUIRES:
 *     p_po_header_id should correspond to a Global Agreement.
 *
 * EFFECTS:
 *     Determines if any documents - Standard POs, Requisitions, ASLs -
 *     (in any status and from any org) still reference the GA from another OU.
 *
 * PARAMETERS:
 *     p_po_header_id - Document ID of Global Agreement
 *
 * RETURNS:
 *     TRUE if referencing documents exist for the GA in another OU.
 *     FALSE otherwise.
 *
 *===========================================================================
 */
FUNCTION referencing_docs_exist
(
    p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
BEGIN

    IF  (   ( referencing_po_exist(p_po_header_id) )
        OR  ( referencing_req_exist(p_po_header_id) ) )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

END referencing_docs_exist;


/**==========================================================================
 *
 * FUNCTION: referencing_asl_exist          <GA FPI>
 *
 * REQUIRES:
 *     p_po_header_id should correspond to a Global Agreement.
 *
 * EFFECTS:
 *     Determines if any ASLs (in any status and from any org)
 *     still reference the GA *from another OU*.
 *
 * PARAMETERS:
 *     p_po_header_id - Document ID of Global Agreement
 *
 * RETURNS:
 *     TRUE if referencing ASL exists for the GA. FALSE otherwise.
 *
 *===========================================================================
 */
FUNCTION referencing_asl_exist
(
    p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_dummy              VARCHAR2(20);
BEGIN

    SELECT   'ASLs'
    INTO     l_dummy
    FROM     po_asl_documents        pasl,
             po_system_parameters    psp
    WHERE    pasl.document_header_id = p_po_header_id;

    return (TRUE);                  -- one record found for each doc type

EXCEPTION

    WHEN NO_DATA_FOUND THEN         -- no records founds
        return (FALSE);

    WHEN TOO_MANY_ROWS THEN         -- multiple records founds
        return (TRUE);

    WHEN OTHERS THEN
        return (FALSE);

END referencing_asl_exist;


/**==========================================================================
 *
 * FUNCTION: referencing_req_exist          <GA FPI>
 *
 * REQUIRES:
 *     p_po_header_id should correspond to a Global Agreement.
 *
 * EFFECTS:
 *     Determines if any reqs (in any status and from any org)
 *     still reference the GA *from another OU*.
 *
 * PARAMETERS:
 *     p_po_header_id - Document ID of Global Agreement
 *
 * RETURNS:
 *     TRUE if referencing Reqs  exists for the GA. FALSE otherwise.
 *
 *===========================================================================
 */
FUNCTION referencing_req_exist
(
    p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_dummy              VARCHAR2(20);
BEGIN

    SELECT   'Requisitions'
    INTO     l_dummy
    FROM     po_requisition_lines_all   prl,
             po_system_parameters       psp
    WHERE    prl.blanket_po_header_id = p_po_header_id
    AND      prl.org_id <> psp.org_id;

    return (TRUE);                  -- one record found for each doc type

EXCEPTION

    WHEN NO_DATA_FOUND THEN         -- no records founds
        return (FALSE);

    WHEN TOO_MANY_ROWS THEN         -- multiple records founds
        return (TRUE);

    WHEN OTHERS THEN
        return (FALSE);

END referencing_req_exist;


/**==========================================================================
 *
 * FUNCTION: referencing_po_exist          <GA FPI>
 *
 * REQUIRES:
 *     p_po_header_id should correspond to a Global Agreement.
 *
 * EFFECTS:
 *     Determines if any PO's (in any status and from any org)
 *     still reference the GA *from another OU*.
 *
 * PARAMETERS:
 *     p_po_header_id - Document ID of Global Agreement
 *
 * RETURNS:
 *     TRUE if referencing PO's exists for the GA. FALSE otherwise.
 *
 *===========================================================================
 */
FUNCTION referencing_po_exist
(
    p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_dummy              VARCHAR2(20);
BEGIN

    SELECT   'Standard POs'
    INTO     l_dummy
    FROM     po_lines_all           pol,
             po_system_parameters   psp
    WHERE    pol.from_header_id = p_po_header_id
    AND      pol.org_id <> psp.org_id;

    return (TRUE);                  -- one record found for each doc type

EXCEPTION

    WHEN NO_DATA_FOUND THEN         -- no records founds
        return (FALSE);

    WHEN TOO_MANY_ROWS THEN         -- multiple records founds
        return (TRUE);

    WHEN OTHERS THEN
        return (FALSE);
END referencing_po_exist;

/**==========================================================================
 *
 * FUNCTION: stdpo_ref_open_ga          <Bug 2812416>
 *
 * REQUIRES:
 *     p_po_header_id should correspond to a standard PO
 *
 * EFFECTS:
 *     Determines if this standard PO references any open GA from
 *     another OU or current OU
 *
 * PARAMETERS:
 *     p_po_header_id - Document ID of the std PO
 *
 * RETURNS:
 *     TRUE if if this standard PO references any open GA
 *
 *===========================================================================
 */
FUNCTION stdpo_ref_ga_check
(
    p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
   l_src_doc_id          PO_LINES_ALL.from_header_id%TYPE;
   l_ga_flag             PO_HEADERS_ALL.global_agreement_flag%TYPE;
   l_closed_code         PO_HEADERS_ALL.closed_code%TYPE;
   l_cancel_flag         PO_HEADERS_ALL.cancel_flag%TYPE;
   l_purge_doc           varchar2(1) := 'Y';

CURSOR C1 is
SELECT  distinct from_header_id
FROM    po_lines
WHERE   po_header_id = p_po_header_id
AND     from_header_id is not null;

BEGIN

    OPEN C1;
    LOOP

    -- get all the source documents referenced by the std PO

    FETCH C1 into l_src_doc_id;
    EXIT WHEN C1%NOTFOUND;

   -- Sql What : check the type, closed status and cancel status of the source
   -- Sql Why  : To determine if the std PO referencing this is eligible for purge

   SELECT   nvl(ph.global_agreement_flag,'N'),
            nvl(ph.closed_code,'OPEN'),
            nvl(ph.cancel_flag,'N')
    INTO    l_ga_flag,
            l_closed_code,
            l_cancel_flag
    FROM    po_headers_all ph
    WHERE   ph.po_header_id = l_src_doc_id;

    -- if the source is not a GA or if its finally closed/cancelled then
    -- the std PO can be purged

    IF l_ga_flag = 'N' OR
       l_closed_code = 'FINALLY CLOSED'  OR
       l_cancel_flag = 'Y'  THEN

           l_purge_doc := 'Y';

    --  if not you cannot purge. even if there is one line with a source doc
    --  which does not satisfy the above conditions we do not purge and exit
    --  out of the loop
    ELSE
           l_purge_doc := 'N';
           exit;

    END IF;


    END LOOP;
    CLOSE C1;

    IF  l_purge_doc = 'Y'
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        CLOSE C1;
        return (FALSE);

END stdpo_ref_ga_check;


-- <DOC PURGE FPJ START>
-----------------------------------------------------------------------
--------------------------   <DOC PURGE FPJ> ------------------------------
-----------------------------------------------------------------------

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

l_api_name      CONSTANT VARCHAR2(50) := 'seed_records';
l_api_version   CONSTANT NUMBER := 1.0;
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

    SAVEPOINT seed_records_grp;

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.seed_records
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_name          => p_purge_name,
      p_purge_category      => p_purge_category,
      p_last_activity_date  => p_last_activity_date
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO seed_records_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    ROLLBACK TO seed_records_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');

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

l_api_name      CONSTANT VARCHAR2(50) := 'filter_records';
l_api_version   CONSTANT NUMBER := 1.0;
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

    SAVEPOINT filter_records_grp;

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.filter_records
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_status        => p_purge_status,
      p_purge_name          => p_purge_name,
      p_purge_category      => p_purge_category,
      p_action              => p_action,
      x_po_records_filtered => x_po_records_filtered
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO filter_records_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    ROLLBACK TO filter_records_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get( p_encoded => 'F');

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
(  p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_purge_name         IN VARCHAR2,
   p_purge_category     IN VARCHAR2,
   p_last_activity_date IN DATE
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'confirm_records';
l_api_version   CONSTANT NUMBER := 1.0;
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

    SAVEPOINT confirm_records_grp;

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.confirm_records
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_name          => p_purge_name,
      p_purge_category      => p_purge_category,
      p_last_activity_date  => p_last_activity_date
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO confirm_records_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    ROLLBACK TO confirm_records_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');


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

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.summarize_records
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_name          => p_purge_name,
      p_purge_category      => p_purge_category,
      p_range_size          => p_range_size
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');

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
(  p_api_version    IN NUMBER,
   p_init_msg_list  IN VARCHAR2,
   p_commit         IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_range_size     IN NUMBER
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'delete_records';
l_api_version   CONSTANT NUMBER := 1.0;
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

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.delete_records
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_name          => p_purge_name,
      p_purge_category      => p_purge_category,
      p_range_size          => p_range_size
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');

END delete_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_purge_list
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

    SAVEPOINT delete_purge_lists_grp;

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.delete_purge_lists
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_name          => p_purge_name
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_purge_lists_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    ROLLBACK TO delete_purge_lists_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');

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
(  p_api_version    IN NUMBER,
   p_init_msg_list  IN VARCHAR2,
   p_commit         IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'delete_history_tables';
l_api_version   CONSTANT NUMBER := 1.0;
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

    SAVEPOINT delete_history_tables_grp;

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.delete_history_tables
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      p_purge_name          => p_purge_name
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_history_tables_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    ROLLBACK TO delete_history_tables_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');

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

l_api_name      CONSTANT VARCHAR2(50) := 'count_po_rows';
l_api_version   CONSTANT NUMBER := 1.0;
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

    IF (FND_API.to_boolean (p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

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

    PO_AP_PURGE_PVT.count_po_rows
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      x_po_hdr_count        => x_po_hdr_count,
      x_rcv_line_count      => x_rcv_line_count,
      x_req_hdr_count       => x_req_hdr_count,
      x_vendor_count        => x_vendor_count,
      x_asl_count           => x_asl_count,
      x_asl_attr_count      => x_asl_attr_count,
      x_asl_doc_count       => x_asl_doc_count
    );

    l_progress := '020';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := FND_MSG_PUB.get (p_encoded => 'F');

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
    x_msg_data := FND_MSG_PUB.get (p_encoded => 'F');

END count_po_rows;

-- <DOC PURGE FPJ END>


END PO_AP_PURGE_GRP;

/
