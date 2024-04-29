--------------------------------------------------------
--  DDL for Package Body PO_AP_MERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_MERGE_GRP" AS
/* $Header: POXPVENB.pls 115.24 2004/05/26 21:58:29 mbhargav noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PO_AP_MERGE_GRP';

G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME|| '.';

g_debug_stmt    CONSTANT    BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp   CONSTANT    BOOLEAN := PO_DEBUG.is_debug_unexp_on;


PO_INVALID_VENDOR_SITE_ID            EXCEPTION;
PO_GA_REFERENCING_DOCS_EXIST         EXCEPTION;
PO_ENABLED_OU_SITE_UNDEFINED         EXCEPTION;
PO_GA_ENABLED_REF_DOCS_EXIST         EXCEPTION;
PO_CONSIGNMENT_EXIST                 EXCEPTION;

-- <VENDOR MERGE FPJ START>
GA_FOR_SITE_AND_PGOA_SITE_DIFF       EXCEPTION;
GA_FOR_SITE_W_POREF_FRM_OTR_OU       EXCEPTION;
GA_FOR_SITE_W_POREF_DIFF_SITE        EXCEPTION;
PGOA_FOR_SITE_AND_GA_SITE_DIFF       EXCEPTION;
SPO_FOR_SITE_AND_GA_SITE_DIFF        EXCEPTION;
REQ_FOR_VDR_REF_GA_IN_OTHER_OU       EXCEPTION;
REQ_FOR_SITE_REF_GA_DIFF_SITE        EXCEPTION;
GA_FOR_SITE_W_REQREF_DIFF_SITE       EXCEPTION;
-- <VENDOR MERGE FPJ END>

/*=========================================================================*/
/*====================== SPECIFICATIONS (PRIVATE) =========================*/
/*=========================================================================*/


-- <VENDOR MERGE FPJ START>


PROCEDURE get_vdr_and_site_name
( p_vendor_id           IN          NUMBER,
  p_vendor_site_id      IN          NUMBER,
  x_vendor_name         OUT NOCOPY  VARCHAR2,
  x_vendor_site_code    OUT NOCOPY  VARCHAR2
);

PROCEDURE update_req_line_vdr_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
);

PROCEDURE update_req_temp_vdr_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
);

PROCEDURE update_fte_vdr_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
);

-- bug3237045
PROCEDURE update_okc_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
);

-- Starting from 11i FPJ we no longer need the following functions as
-- we will embed all logic within validate_merge

-- FUNCTION  get_vendor_site_code
-- (   p_vendor_site_id      IN   PO_VENDOR_SITES.vendor_site_id%TYPE
-- ) RETURN VARCHAR2;
--
-- FUNCTION  supplier_site_exist
-- (   p_org_id            IN   PO_VENDOR_SITES_ALL.org_id%TYPE,
--     p_vendor_id         IN   PO_VENDOR_SITES_ALL.vendor_id%TYPE,
--     p_vendor_site_code  IN   PO_VENDOR_SITES_ALL.vendor_site_code%TYPE
-- ) RETURN BOOLEAN;
--
--FUNCTION referencing_asl_exist
--(   p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE,
--    p_call_from          IN     VARCHAR2
--) RETURN BOOLEAN;
--
--FUNCTION referencing_docs_exist
--(   p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
--) RETURN BOOLEAN;
--

-- <VENDOR MERGE FPJ END>


/*=========================================================================*/
/*========================== BODY (PUBLIC) ================================*/
/*=========================================================================*/

/**==========================================================================
 *
 * PUBLIC PROCEDURE : validate_merge                       <GA FPI>
 *
 * REQUIRES:
 *     The TO vendor_site_id must be defined in po_vendor_sites_all.
 *
 * MODIFIES:
 *     API Message List - any messages will be appended to the API Message List
 *
 * EFFECTS:
 *     Determines if it is not ok to perform a Supplier Merge.
 *
 * RETURNS:
 *     x_return_status - (a) FND_API.G_RET_STS_SUCCESS if validation successful
 *                       (b) FND_API.G_RET_STS_ERROR if error during validation
 *                       (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
 *
 *     x_result - (a) FND_API.G_TRUE if restrictions are met
 *                (b) FND_API.G_FALSE if not ok to perform Supplier Merge
 *
 *===========================================================================
 */
PROCEDURE validate_merge
(
    p_api_version    IN         NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    p_from_vendor_id IN         PO_VENDORS.vendor_id%TYPE,
    p_from_site_id   IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE,
    p_to_vendor_id   IN         PO_VENDORS.vendor_id%TYPE,
    p_to_site_id     IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE,
    x_result         OUT NOCOPY VARCHAR2
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'validate_merge';
    l_api_version           CONSTANT NUMBER := 1.0;
    l_module                FND_LOG_MESSAGES.module%TYPE :=
                                           G_MODULE_PREFIX || l_api_name;

    l_from_site_code        PO_VENDOR_SITES_ALL.vendor_site_code%TYPE;

    x_validation_error      VARCHAR2(80);
    l_consigned_ret_sts     VARCHAR2(1);
    l_consigned_msg_count   NUMBER;
    l_consigned_msg_data    VARCHAR2(2000);
    l_consigned_can_merge   VARCHAR2(1);

    l_from_vendor_name      PO_VENDORS.vendor_name%TYPE;   --bug 2814321

    l_pass_val              VARCHAR2(1) := 'Y';    -- <VENDOR MERGE FPJ>

    l_progress              VARCHAR2(3);
BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_module
        );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS; -- Initialize return status

    l_progress := '000';

    -- <VENDOR MERGE FPJ START>

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- get vendor name info in case we need to report an error
    get_vdr_and_site_name
    ( p_vendor_id           => p_from_vendor_id,
      p_vendor_site_id      => p_from_site_id,
      x_vendor_name         => l_from_vendor_name,
      x_vendor_site_code    => l_from_site_code
    );

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head => l_module,
          p_token    => l_progress,
          p_message  => l_progress || ': vdrname = ' || l_from_vendor_name ||
                        ', sitecode = ' || l_from_site_code
        );
    END IF;

    l_progress := '010';

    IF (p_from_vendor_id <> p_to_vendor_id) THEN
        -- All the new checks are performed only if from vendor and to vendor
        -- are different.

        l_progress := '020';

        -- Check 1
        -- SQL What:Prevent Merge, if there is GA/GC for from supplier/site in
        --          current OU and a purchasing site exists in PGOA which is
        --          different from the vendor site on the doc header

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_headers GA,
                                po_ga_org_assignments PGOA
                        WHERE   GA.global_agreement_flag = 'Y'
                        AND     GA.vendor_id = p_from_vendor_id
                        AND     GA.vendor_site_id = p_from_site_id
                        AND     GA.po_header_id = PGOA.po_header_id
                        AND     PGOA.vendor_site_id <> p_from_site_id );

            IF (l_pass_val = 'F') THEN
                RAISE   GA_FOR_SITE_AND_PGOA_SITE_DIFF;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 1'
            );
        END IF;

        l_progress := '030';

        -- Check 2
        -- SQL What: Prevent Merge, if there is GA/GC for from supplier/site in
        --          current OU and there are execution docs in other OU
        --          referencing the GA/GC

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_headers GA,
                                po_lines_all POL
                        WHERE   GA.global_agreement_flag = 'Y'
                        AND     GA.vendor_id = p_from_vendor_id
                        AND     GA.vendor_site_id = p_from_site_id
                        AND     POL.org_id <> GA.org_id
                        AND     GA.po_header_id IN (POL.contract_id,
                                                    POL.from_header_id));

            IF (l_pass_val = 'F') THEN
                RAISE   GA_FOR_SITE_W_POREF_FRM_OTR_OU;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 2'
            );
        END IF;

        l_progress := '040';

        -- Check 3:
        -- SQL What:Prevent Merge, if there is GA/GC for from supplier/site in
        --          current OU and there are executeion docs in current OU
        --          referencing the GA/GC but the PO has a diff vendor site

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_headers GA,
                                po_lines POL,
                                po_headers POH
                        WHERE   GA.global_agreement_flag = 'Y'
                        AND     GA.vendor_id = p_from_vendor_id
                        AND     GA.vendor_site_id = p_from_site_id
                        AND     GA.po_header_id IN (POL.contract_id,
                                                      POL.from_header_id)
                        AND     POH.po_header_id = POL.po_header_id
                        AND     POH.vendor_id = p_from_vendor_id
                        AND     POH.vendor_site_id <> p_from_site_id);

            IF (l_pass_val = 'F') THEN
                RAISE   GA_FOR_SITE_W_POREF_DIFF_SITE;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 3'
            );
        END IF;

        l_progress := '050';

        -- Check 4:
        -- SQL What:Prevent Merge, if there is a GA/GC in another OU, where
        --          from vendor site is defined as Purchasing site.

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_headers_all GA,
                                po_ga_org_assignments PGOA
                        WHERE   GA.global_agreement_flag = 'Y'
                        AND     GA.vendor_id = p_from_vendor_id
                        AND     GA.po_header_id = PGOA.po_header_id
                        AND     PGOA.vendor_site_id = p_from_site_id
                        AND     GA.vendor_site_id <> p_from_site_id);

            IF (l_pass_val = 'F') THEN
                RAISE   PGOA_FOR_SITE_AND_GA_SITE_DIFF;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 4'
            );
        END IF;

        l_progress := '060';

        -- Check 5:
        -- SQL What:Prevent Merge, if there are execution docs in current OU
        --          with from supplier/site, referencing a GA/GC, but the GA/GC
        --          has a diff vendor site on the header

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_headers POH,
                                po_lines POL,
                                po_headers_all GA
                        WHERE   POH.vendor_id = p_from_vendor_id
                        AND     POH.vendor_site_id = p_from_site_id
                        AND     POH.po_header_id = POL.po_header_id
                        AND     GA.po_header_id IN (POL.contract_id,
                                                    POL.from_header_id)
                        AND     GA.global_agreement_flag = 'Y'
                        AND     GA.vendor_id = p_from_vendor_id
                        AND     GA.vendor_site_id <> POH.vendor_site_id);

            IF (l_pass_val = 'F') THEN
                RAISE   SPO_FOR_SITE_AND_GA_SITE_DIFF;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 5'
            );
        END IF;

        l_progress := '070';

        -- Check 6:
        -- SQL WHat:Prevent Merge, if there are requisitions in current OU
        --          for the from vendor that references a GA/GC owned by
        --          another OU.

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_requisition_lines RL,
                                po_headers_all GA
                        WHERE   RL.vendor_id = p_from_vendor_id
                        AND     RL.blanket_po_header_id = GA.po_header_id
                        AND     GA.global_agreement_flag = 'Y'
                        AND     GA.org_id <> RL.org_id);

            IF (l_pass_val = 'F') THEN
                RAISE   REQ_FOR_VDR_REF_GA_IN_OTHER_OU;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 6'
            );
        END IF;

        l_progress := '080';

        -- Check 7:
        -- SQL What:Prevent Purge, if there are reqs in any OU with the from
        --          vendor and from vendor site, referencing GA/GC in current
        --          OU, but the vendor/site on the GA/GC is different from
        --          the from vendor/site

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_requisition_lines_all RL,
                                po_headers GA
                        WHERE   RL.vendor_id = p_from_vendor_id
                        AND     RL.vendor_site_id = p_from_site_id
                        AND     RL.blanket_po_header_id = GA.po_header_id
                        AND     GA.global_agreement_flag = 'Y'
                        AND     GA.vendor_id = p_from_vendor_id
                        AND     GA.vendor_site_id <> p_from_site_id);

            IF (l_pass_val = 'F') THEN
                RAISE   REQ_FOR_SITE_REF_GA_DIFF_SITE;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 7'
            );
        END IF;

        l_progress := '090';

        -- Check 8:
        -- SQL What:Prevent Merge, if there are requisitions in any OU
        --          referencing GA/GC with the from vendor/site, but the
        --          req may have a different suggested vendor site

        BEGIN
            SELECT  'F'
            INTO    l_pass_val
            FROM    dual
            WHERE   EXISTS (
                        SELECT  NULL
                        FROM    po_requisition_lines_all RL,
                                po_headers GA
                        WHERE   GA.vendor_id = p_from_vendor_id
                        AND     GA.vendor_site_id = p_from_site_id
                        AND     GA.global_agreement_flag = 'Y'
                        AND     GA.po_header_id = RL.blanket_po_header_id
                        AND     RL.vendor_id = p_from_vendor_id
                        AND     RL.vendor_site_id <> p_from_site_id);

            IF (l_pass_val = 'F') THEN
                RAISE   GA_FOR_SITE_W_REQREF_DIFF_SITE;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': passed check 8'
            );
        END IF;

    END IF; -- p_from_vendor_id <> p_to_vendor_id

    -- <VENDOR MERGE FPJ END>

    l_progress := '100';

    IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': checking consignments'
            );
    END IF;

    -- Check for any consignements for the from supplier

    PO_THIRD_PARTY_STOCK_GRP.validate_supplier_merge(
        p_api_version       => 1.0
      , p_init_msg_list     => NULL
      , p_commit            => NULL
      , p_validation_level  => NULL
      , x_return_status     => l_consigned_ret_sts
      , x_msg_count         => l_consigned_msg_count
      , x_msg_data          => l_consigned_msg_data
      , p_vendor_site_id    => p_from_site_id
      , p_vendor_id         => p_from_vendor_id --bug 3649022
      , x_can_merge         => l_consigned_can_merge
      , x_validation_error  => x_validation_error
      );

    IF (l_consigned_ret_sts = FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_consigned_can_merge = FND_API.G_FALSE) THEN
        RAISE PO_CONSIGNMENT_EXIST;
      END IF;
    ELSE
      x_result := FND_API.G_FALSE;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head => l_module
        );
    END IF;

    -- If no exceptions were raised in previous loops, then validation passed
    x_result := FND_API.G_TRUE;

EXCEPTION

    WHEN GA_FOR_SITE_AND_PGOA_SITE_DIFF THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 1'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_GA_PGOA_SITE_DIFF');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN GA_FOR_SITE_W_POREF_FRM_OTR_OU THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 2'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_GA_W_POREF_FRM_OTR_OU');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN GA_FOR_SITE_W_POREF_DIFF_SITE THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 3'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_GA_W_POREF_DIFF_SITE');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN PGOA_FOR_SITE_AND_GA_SITE_DIFF THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 4'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_PGOA_GA_SITE_DIFF');
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN SPO_FOR_SITE_AND_GA_SITE_DIFF THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 5'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_SPO_GA_SITE_DIFF');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN REQ_FOR_VDR_REF_GA_IN_OTHER_OU THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 6'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_REQ_REF_GA_IN_OTR_OU');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);

        APP_EXCEPTION.raise_exception;

    WHEN REQ_FOR_SITE_REF_GA_DIFF_SITE THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 7'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_REQ_REF_GA_DIFF_SITE');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN GA_FOR_SITE_W_REQREF_DIFF_SITE THEN
        x_result := FND_API.G_FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => l_progress || ': violated rule 8'
            );
        END IF;

        FND_MESSAGE.set_name('PO', 'PO_MERGE_GA_W_REQREF_DIFF_SITE');
        FND_MESSAGE.set_token('FROM_VENDOR', l_from_vendor_name);
        FND_MESSAGE.set_token('FROM_VENDOR_SITE', l_from_site_code);

        APP_EXCEPTION.raise_exception;

    WHEN PO_CONSIGNMENT_EXIST THEN
        x_result := FND_API.G_FALSE;
        FND_MESSAGE.set_name('PO', x_validation_error);

        APP_EXCEPTION.raise_exception;

    WHEN PO_INVALID_VENDOR_SITE_ID THEN

        -- bug2814492
        -- set x_result to G_FALSE whenever there is an error
        x_result := FND_API.G_FALSE;
po_message_s.sql_error(l_api_name, l_progress || '-1', sqlcode);
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
        -- bug2814492
        x_result := FND_API.G_FALSE;
po_message_s.sql_error(l_api_name, l_progress ||'-2', sqlcode);
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- bug2814492
        x_result := FND_API.G_FALSE;
po_message_s.sql_error(l_api_name, l_progress || '-3', sqlcode);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        -- bug2814492
        x_result := FND_API.G_FALSE;
po_message_s.sql_error(l_api_name, l_progress || '-4', sqlcode);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_merge;

/**==========================================================================
 *
 * PUBLIC PROCEDURE : update_org_assignments                <GA FPI>
 *
 * REQUIRES:
 *     validate_purge must have been successful.
 *     The To vendor_site_id must be defined in po_vendor_sites_all.
 *
 * MODIFIES:
 *     API Message List - any messages will be appended to the API Message List
 *
 * EFFECTS:
 *     Updates the Global Agreements' Org Assignment table - replaces every
 *     instance of the old Supplier/SiteName with the new vendor_site_id.
 *
 * RETURNS:
 *     x_return_status - (a) FND_API.G_RET_STS_SUCCESS if validation successful
 *                       (b) FND_API.G_RET_STS_ERROR if error during validation
 *                       (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
 *
 *===========================================================================
 */
PROCEDURE update_org_assignments
(
    p_api_version    IN         NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    p_from_vendor_id IN         PO_VENDORS.vendor_id%TYPE,
    p_from_site_id   IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE,
    p_to_vendor_id   IN         PO_VENDORS.vendor_id%TYPE,
    p_to_site_id     IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'update_org_assignments';
    l_module                FND_LOG_MESSAGES.module%TYPE :=
                                           G_MODULE_PREFIX || l_api_name;
    l_api_version           CONSTANT NUMBER := 1.0;

    l_progress              VARCHAR2(3);

BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_module
        );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS; -- Initialize return status
    l_progress := '000';

    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '010';

    -- <VENDOR MERGE FPJ START>

    -- Starting from 11i FPJ we no longer update ga org assignments based on
    -- vendor site code. Instead we just need to update org assignment with
    -- vendor site id that matches p_from_vendor_id

    UPDATE  po_ga_org_assignments PGOA
    SET     PGOA.vendor_site_id = p_to_site_id,
            -- Bug 3387904 START - Need to update the WHO columns:
            PGOA.last_update_date = SYSDATE,
            PGOA.last_updated_by = FND_GLOBAL.user_id,
            PGOA.last_update_login = FND_GLOBAL.login_id
            -- Bug 3387904 END
    WHERE   PGOA.vendor_site_id = p_from_site_id;

    UPDATE  po_ga_org_assignments_archive PGOA
    SET     PGOA.vendor_site_id = p_to_site_id,
            -- Bug 3387904 START - Need to update the WHO columns:
            PGOA.last_update_date = SYSDATE,
            PGOA.last_updated_by = FND_GLOBAL.user_id,
            PGOA.last_update_login = FND_GLOBAL.login_id
            -- Bug 3387904 END
    WHERE   PGOA.vendor_site_id = p_from_site_id;

    l_progress := '020';

    update_req_line_vdr_info
    ( p_from_vendor_id  => p_from_vendor_id,
      p_from_site_id    => p_from_site_id,
      p_to_vendor_id    => p_to_vendor_id,
      p_to_site_id      => p_to_site_id
    );

    l_progress := '030';

    update_req_temp_vdr_info
    ( p_from_vendor_id  => p_from_vendor_id,
      p_from_site_id    => p_from_site_id,
      p_to_vendor_id    => p_to_vendor_id,
      p_to_site_id      => p_to_site_id
    );

    l_progress := '040';

    update_fte_vdr_info
    ( p_from_vendor_id  => p_from_vendor_id,
      p_from_site_id    => p_from_site_id,
      p_to_vendor_id    => p_to_vendor_id,
      p_to_site_id      => p_to_site_id
    );

    l_progress := '050';

    update_okc_info
    ( p_from_vendor_id  => p_from_vendor_id,
      p_from_site_id    => p_from_site_id,
      p_to_vendor_id    => p_to_vendor_id,
      p_to_site_id      => p_to_site_id
    );

    l_progress := '060';

    -- <VENDOR MERGE FPJ END>

    -- Call the iSP API to handle events after merge

     POS_SUP_PROF_MRG_GRP.handle_merge (
                                        p_to_vendor_id           ,
                                        p_to_site_id      ,
                                        p_from_vendor_id         ,
                                        p_from_site_id    ,
                                        x_return_status
                                        );

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head => l_module
        );
    END IF;

EXCEPTION

    WHEN PO_INVALID_VENDOR_SITE_ID THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END update_org_assignments;


/*=========================================================================*/
/*=========================== BODY (PRIVATE) ==============================*/
/*=========================================================================*/

-- <VENDOR MERGE FPJ START>

-----------------------------------------------------------------------
--Start of Comments
--Name: get_vdr_and_site_name
--Pre-reqs: p_vendor_site_id should be a site under vendor identified by
--          p_vendor_id
--Modifies: None
--Locks:
--  None
--Function:
--  Returns vendor_namd and vendor_site_code givent vendor id and
--  vendor site id
--Parameters:
--IN:
--p_vendor_id
--  Vendor Unique identifier
--p_vendor_site_id
--  Vendor Site unique identifier
--IN OUT:
--OUT:
--x_vendor_name
--  Name of the vendor identified by p_vendor_id
--x_vendor_site_code
--  Name of the vendor site identified by p_vendor_site_id
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE get_vdr_and_site_name
( p_vendor_id           IN          NUMBER,
  p_vendor_site_id      IN          NUMBER,
  x_vendor_name         OUT NOCOPY  VARCHAR2,
  x_vendor_site_code    OUT NOCOPY  VARCHAR2
) IS
BEGIN

    SELECT  PV.vendor_name,
            PVS.vendor_site_code
    INTO    x_vendor_name,
            x_vendor_site_code
    FROM    po_vendors PV,
            po_vendor_sites_all PVS
    WHERE   PV.vendor_id = p_vendor_id
    AND     PVS.vendor_site_id = p_vendor_site_id
    AND     PV.vendor_id = PVS.vendor_id;

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.set_name('PO','PO_INVALID_VENDOR_SITE_ID');
        FND_MESSAGE.set_token('VENDOR_SITE_ID',p_vendor_site_id);
        APP_EXCEPTION.raise_exception;
END get_vdr_and_site_name;


-----------------------------------------------------------------------
--Start of Comments
--Name: update_req_line_vdr_info
--Pre-reqs:
--Modifies: po_requisition_lines_all
--Locks:
--  None
--Function:
--  Update requisition lines in all OU with the new supplier information
--  for those with the supplier/site that has been merged
--Parameters:
--IN:
--p_from_vendor_id
--  Vendor that has been merged
--p_from_site_id
--  Vendor Site that has been merged
--p_to_vendor_id
--  New Vendor for the old one
--p_to_vendor_site_id
--  New vendor site for the old one
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE update_req_line_vdr_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
) IS
    l_api_name         CONSTANT VARCHAR2(30) := 'update_req_line_vdr_info';
    l_module           FND_LOG_MESSAGES.module%TYPE :=
                           G_MODULE_PREFIX || l_api_name || '.';
    l_progress         VARCHAR2(3);
BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_module
        );
    END IF;

    l_progress := '000';

    -- modify  PO_REQUISITION_LINES_ALL to use new vendor in all OUs

    --SQL What: Update suggested vendor information to reflect vendor merge
    --          on req in all OU
    --SQL Why:  Vendor Merge functionality

    UPDATE  po_requisition_lines_all
    SET     suggested_vendor_name =
                (SELECT PV.vendor_name
                 FROM   po_vendors PV
                 WHERE  PV.vendor_id = p_to_vendor_id),
            suggested_vendor_location =
                (SELECT PVS.vendor_site_code
                 FROM   po_vendor_sites PVS
                 WHERE  PVS.vendor_site_id = p_to_site_id),
            vendor_id = p_to_vendor_id,
            vendor_site_id = p_to_site_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
    WHERE   vendor_id = p_from_vendor_id
    AND     vendor_site_id = p_from_site_id;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Updated rows: ' || SQL%ROWCOUNT
        );
    END IF;

    l_progress := '010';

    --SQL What: Update suggested vendor information to reflect vendor merge
    --          for reqs in all OUs, if the req does not have vendor site
    --          info, and the supplier becomes inactive due to vendor merge
    --SQL Why:  Vendor Merge functionality

    UPDATE  po_requisition_lines_all
    SET     suggested_vendor_name =
                (SELECT PV.vendor_name
                 FROM   po_vendors PV
                 WHERE  PV.vendor_id = p_to_vendor_id),
            vendor_id = p_to_vendor_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
    WHERE   vendor_id = p_from_vendor_id
    AND     vendor_site_id IS NULL
    AND     EXISTS
                (SELECT vendor_id
                 FROM   po_vendors PV
                 WHERE  vendor_id = p_from_vendor_id
                 AND    NVL(PV.end_date_active, SYSDATE+1) <= SYSDATE);


    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Updated rows: ' || SQL%ROWCOUNT
        );

        PO_DEBUG.debug_end
        ( p_log_head => l_module
        );
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (g_debug_unexp) THEN
        PO_DEBUG.debug_exc
        ( p_log_head    => l_module,
          p_progress    => l_progress
        );
    END IF;

    RAISE;

END update_req_line_vdr_info;


-----------------------------------------------------------------------
--Start of Comments
--Name: update_req_temp_vdr_info
--Pre-reqs:
--Modifies: po_reqexpress_lines_all
--Locks:
--  None
--Function:
--  Update requisition template in all OU with the new supplier information
--  for those with the supplier/site that has been merged
--Parameters:
--IN:
--p_from_vendor_id
--  Vendor that has been merged
--p_from_site_id
--  Vendor Site that has been merged
--p_to_vendor_id
--  New Vendor for the old one
--p_to_vendor_site_id
--  New vendor site for the old one
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE update_req_temp_vdr_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
) IS
    l_api_name         CONSTANT VARCHAR2(30) := 'update_req_temp_vdr_info';
    l_module           FND_LOG_MESSAGES.module%TYPE :=
                           G_MODULE_PREFIX || l_api_name || '.';
    l_progress         VARCHAR2(3);
BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_module
        );
    END IF;

    l_progress := '000';

    -- Update Req Template Records

    UPDATE  po_reqexpress_lines_all PRL
    SET     PRL.suggested_vendor_id = p_to_vendor_id,
            PRL.suggested_vendor_site_id = p_to_site_id,
            PRL.last_update_date = SYSDATE,
            PRL.last_updated_by = FND_GLOBAL.user_id,
            PRL.last_update_login = FND_GLOBAL.login_id
    WHERE   PRL.suggested_vendor_id = p_from_vendor_id
    AND     PRL.suggested_vendor_site_id = p_from_site_id;


    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Updated rows: ' || SQL%ROWCOUNT
        );
    END IF;

    l_progress := '010';

    --SQL What: update requisition template with the new supplier if supplier
    --          site is null in the template, and the supplier is getting
    --          invalidatad because of the merge
    --SQL Why:  If the supplier is not active after vendor merge,the records
    --          associated to that supplier should be moved to point to the
    --          new supplier

    UPDATE  po_reqexpress_lines_all PRL
    SET     PRL.suggested_vendor_id = p_to_vendor_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
    WHERE   PRL.suggested_vendor_id = p_from_vendor_id
    AND     PRL.suggested_vendor_site_id IS NULL
    AND     EXISTS (
                SELECT  NULL
                FROM    po_vendors PV
                WHERE   PV.vendor_id = p_from_vendor_id
                AND     NVL(PV.end_date_active, SYSDATE + 1) <= SYSDATE);

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Updated rows: ' || SQL%ROWCOUNT
        );

        PO_DEBUG.debug_end
        ( p_log_head => l_module
        );
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (g_debug_unexp) THEN
        PO_DEBUG.debug_exc
        ( p_log_head    => l_module,
          p_progress    => l_progress
        );
    END IF;

    RAISE;
END update_req_temp_vdr_info;



-----------------------------------------------------------------------
--Start of Comments
--Name: update_fte_vdr_info
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Call FTE API to notify them about the occurrent of vendor merge
--Parameters:
--IN:
--p_from_vendor_id
--  Vendor that has been merged
--p_from_site_id
--  Vendor Site that has been merged
--p_to_vendor_id
--  New Vendor for the old one
--p_to_vendor_site_id
--  New vendor site for the old one
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE update_fte_vdr_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
) IS

l_api_name         CONSTANT VARCHAR2(30) := 'update_fte_vdr_info';
l_module           FND_LOG_MESSAGES.module%TYPE :=
                       G_MODULE_PREFIX || l_api_name || '.';
l_progress         VARCHAR2(3);

l_fte_in_rec            WSH_PO_INTG_TYPES_GRP.merge_in_rectype;
l_fte_out_rec           WSH_PO_INTG_TYPES_GRP.merge_out_rectype;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);

BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_module
        );
    END IF;

    l_progress := '000';

    -- Construct in record for FTE call out

    l_fte_in_rec.caller             := 'PO_VENDOR_MERGE';
    l_fte_in_rec.p_from_vendor_id   := p_from_vendor_id;
    l_fte_in_rec.p_from_site_id     := p_from_site_id;
    l_fte_in_rec.p_to_vendor_id     := p_to_vendor_id;
    l_fte_in_rec.p_to_site_id       := p_to_site_id;

    l_progress := '010';

    WSH_PO_INTEGRATION_GRP.vendor_merge
    ( p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_commit              => FND_API.G_FALSE,
      p_in_rec              => l_fte_in_rec,
      x_out_rec             => l_fte_out_rec,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );

    l_progress := '020';


    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Called WSH Merge API. status = ' || l_return_status
        );
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '030';

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head => l_module
        );
    END IF;

EXCEPTION
WHEN OTHERS THEN

    IF (g_debug_unexp) THEN

        IF (l_msg_count IS NOT NULL) THEN
            FOR i IN 1..l_msg_count LOOP

                l_msg_data := FND_MSG_PUB.get
                              ( p_msg_index => i,
                                p_encoded => 'F');
                PO_DEBUG.debug_stmt
                ( p_log_head => l_module,
                  p_token    => l_progress,
                  p_message  => l_msg_data
                );
            END LOOP;
        END IF;

        PO_DEBUG.debug_exc
        ( p_log_head    => l_module,
          p_progress    => l_progress
        );
    END IF;

    RAISE;
END update_fte_vdr_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_okc_info
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Call OKC API to notify them about the occurrence of vendor merge
--Parameters:
--IN:
--p_from_vendor_id
--  Vendor that has been merged
--p_from_site_id
--  Vendor Site that has been merged
--p_to_vendor_id
--  New Vendor for the old one
--p_to_vendor_site_id
--  New vendor site for the old one
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE update_okc_info
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER
) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_okc_info';
l_module    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_progress  VARCHAR2(3);

l_msg_data  VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(1);

BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_module
        );
    END IF;

    l_progress := '000';

    IF (PO_CONTERMS_UTL_GRP.is_contracts_enabled = FND_API.G_TRUE) THEN

        OKC_MANAGE_DELIVERABLES_GRP.updateExtPartyOnDeliverables
        ( p_api_version                 => 1.0,
          p_init_msg_list               => FND_API.G_TRUE,
          p_commit                      => FND_API.G_FALSE,
          p_document_class              => 'PO',
          p_from_external_party_id      => p_from_vendor_id,
          p_from_external_party_site_id => p_from_site_id,
          p_to_external_party_id        => p_to_vendor_id,
          p_to_external_party_site_id   => p_to_site_id,
          x_msg_data                    => l_msg_data,
          x_msg_count                   => l_msg_count,
          x_return_status               => l_return_status
        );

    END IF;

    l_progress := '010';


    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Called OKC Merge API. status = ' || l_return_status
        );
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head => l_module
        );
    END IF;

EXCEPTION
WHEN OTHERS THEN

    IF (g_debug_unexp) THEN

        IF (l_msg_count IS NOT NULL) THEN
            FOR i IN 1..l_msg_count LOOP

                l_msg_data := FND_MSG_PUB.get
                              ( p_msg_index => i,
                                p_encoded => 'F');
                PO_DEBUG.debug_stmt
                ( p_log_head => l_module,
                  p_token    => l_progress,
                  p_message  => l_msg_data
                );
            END LOOP;
        END IF;

        PO_DEBUG.debug_exc
        ( p_log_head    => l_module,
          p_progress    => l_progress
        );
    END IF;

    RAISE;

END update_okc_info;

-- <VENDOR MERGE FPJ END>

END PO_AP_MERGE_GRP;

/
