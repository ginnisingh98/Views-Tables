--------------------------------------------------------
--  DDL for Package Body PO_INTERFACE_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INTERFACE_S2" AS
/* $Header: POXBWP2B.pls 120.5.12010000.2 2012/09/25 23:13:55 yuewliu ship $*/

c_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_INTERFACE_S2.';


-- <GC FPJ START>

PROCEDURE get_distinct_src_id
(  p_po_header_id IN         NUMBER,
   p_src_doc_type IN         VARCHAR2,
   p_global_flag  IN         VARCHAR2,
   x_src_doc_id   OUT NOCOPY NUMBER);

-- <GC FPJ END>

/* ============================================================================
     NAME: GET_SOURCE_INFO
     DESC: Get quote info
     ARGS: x_requisition_line_id IN number,
           x_vendor_id IN number,
           x_quote_header_id IN OUT number,
           x_quote_line_id OUT number
     ALGR:
     History: 09-25-03 mbhargav Changed the signature to not take vendor_site_code
   ==========================================================================*/
PROCEDURE get_source_info(x_requisition_line_id IN number,
                         x_vendor_id IN number,
                         x_currency  IN varchar2,
                         x_source_header_id IN OUT NOCOPY number,
                         x_source_line_id OUT NOCOPY number,
                         p_vendor_site_id IN NUMBER,                -- <GC FPJ>
                         p_purchasing_org_id IN NUMBER,             -- <GC FPJ>
                         x_src_document_type OUT NOCOPY VARCHAR2    -- <GC FPJ>
) IS

x_source_line_num    number := null;
x_progress varchar2(3) ;

l_doc_type_code     PO_REQUISITION_LINES_ALL.document_type_code%TYPE;
BEGIN

   x_progress:='000';

   BEGIN
     SELECT blanket_po_header_id,
            blanket_po_line_num,
            document_type_code        -- <GC FPJ>
       INTO x_source_header_id,
            x_source_line_num,
            l_doc_type_code           -- <GC FPJ>
       FROM po_requisition_lines
      WHERE requisition_line_id = x_requisition_line_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_source_header_id := null;
       x_source_line_id := null;
       return;
   END;


   /*
    ** Get po_line_id for the source line if the vendor info/currency on the PO and
    ** the source doc match
    */

   x_progress:='001';


   BEGIN

      -- <GC FPJ START>
      IF (l_doc_type_code = 'CONTRACT') THEN

          -- Return contract referenece (global or local) of the req if the ref
          -- is consistent with the document the req line is going to add to.

          -- SQL What: Determine whether the contract reference on the req
          --           line can be carried over to PO line
          -- SQL Why:  Autocreate should not create a line with incorrect
          --           contract reference

          SELECT PH.po_header_id,
                 PH.type_lookup_code
          INTO   x_source_header_id,
                 x_src_document_type
          FROM   po_headers_all PH
          WHERE  PH.po_header_id = x_source_header_id
          AND    PH.type_lookup_code = 'CONTRACT'
          AND    PH.vendor_id = x_vendor_id
          AND    ((PH.global_agreement_flag = 'Y'
                   AND PH.currency_code = x_currency
                   AND (ph.vendor_site_id = p_vendor_site_id --<Shared Proc FPJ>
                        OR EXISTS (SELECT 1
                               FROM   po_ga_org_assignments PGOA
                               WHERE  PGOA.po_header_id = PH.po_header_id
                               AND    PGOA.enabled_flag = 'Y'
                               AND    PGOA.vendor_site_id = decode(Nvl(PH.Enable_All_Sites,'N'),'N',p_vendor_site_id, PGOA.vendor_site_id ))))
                  OR
                  (NVL(PH.global_agreement_flag, 'N') = 'N')
                   AND NVL(PH.org_id, -1) = NVL(p_purchasing_org_id, -1));
      ELSE
      -- <GC FPJ END>

          SELECT pl.po_line_id,
                 ph.type_lookup_code   -- <GC FPJ>
            INTO x_source_line_id,
                 x_src_document_type   -- <GC FPJ>
            FROM po_headers_all ph,
                 po_lines_all pl
           WHERE ph.po_header_id = pl.po_header_id
             AND ph.vendor_id = x_vendor_id
             AND ph.currency_code = x_currency --<Bug 3613912>
             AND ((ph.type_lookup_code = 'BLANKET'
                      and nvl(ph.global_agreement_flag,'N') = 'Y'
                      --<Shared Proc FPJ START>
                      --Need to ensure the site is header site or one of the
                      --purchasing site on Global Agreement
                      AND (ph.vendor_site_id = p_vendor_site_id
                           OR EXISTS (SELECT 1
                                FROM   po_ga_org_assignments PGOA
                                WHERE  PGOA.po_header_id = x_source_header_id
                                AND    PGOA.enabled_flag = 'Y'
                                AND    PGOA.vendor_site_id = p_vendor_site_id)))
                   OR (ph.type_lookup_code = 'QUOTATION'
                       AND ph.vendor_site_id = p_vendor_site_id))
                       --<Shared Proc FPJ END>
             AND ph.po_header_id = x_source_header_id
             AND pl.line_num = x_source_line_num;
      END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN

       x_source_header_id := null;
       x_source_line_id := null;
       return;
   END;

EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('GET SOURCE INFO',x_progress,sqlcode);
     raise;
END get_source_info;

PROCEDURE get_doc_header_info (p_add_to_doc_id                    IN NUMBER,
                               p_add_to_type                      OUT NOCOPY VARCHAR2,
                               p_add_to_vendor_id                 OUT NOCOPY NUMBER,
                               p_add_to_vendor_site_id            OUT NOCOPY NUMBER,
                               p_add_to_currency_code             OUT NOCOPY VARCHAR2,
                               p_add_to_terms_id                  OUT NOCOPY NUMBER,
                               p_add_to_ship_via_lookup_code      OUT NOCOPY VARCHAR2,
                               p_add_to_fob_lookup_code           OUT NOCOPY VARCHAR2,
                               p_add_to_freight_lookup_code       OUT NOCOPY VARCHAR2,
                               x_add_to_shipping_control          OUT NOCOPY VARCHAR2    -- <INBOUND LOGISTICS FPJ>
) IS


BEGIN

  Select type_lookup_code,
         vendor_id,
         vendor_site_id,
         currency_code,
         terms_id,
         ship_via_lookup_code,
         fob_lookup_code,
         freight_terms_lookup_code,
         shipping_control    -- <INBOUND LOGISTICS FPJ>
  into   p_add_to_type,
         p_add_to_vendor_id ,
         p_add_to_vendor_site_id  ,
         p_add_to_currency_code ,
         p_add_to_terms_id     ,
         p_add_to_ship_via_lookup_code   ,
         p_add_to_fob_lookup_code   ,
         p_add_to_freight_lookup_code,
         x_add_to_shipping_control    -- <INBOUND LOGISTICS FPJ>
  From po_headers_all
  Where po_header_id = p_add_to_doc_id;

EXCEPTION
 when others then
         p_add_to_type                       := null;
         p_add_to_vendor_id                  := null;
         p_add_to_vendor_site_id             := null;
         p_add_to_currency_code              := null;
         p_add_to_terms_id                   := null;
         p_add_to_ship_via_lookup_code       := null;
         p_add_to_fob_lookup_code            := null;
         p_add_to_freight_lookup_code        := null;
         x_add_to_shipping_control           := NULL;    -- <INBOUND LOGISTICS FPJ>
END get_doc_header_info;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_req_in_pool
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if a Requisition line is currently in the Requisition Pool.
--Parameters:
--IN:
--p_req_line_id
--  Unique ID of the Requisition Line
--Returns:
--  TRUE if the Requisition line is in the Requisition Pool. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_req_in_pool
(
    p_req_line_id             IN        NUMBER
)
RETURN BOOLEAN
IS
    l_reqs_in_pool_flag       PO_REQUISITION_LINES_ALL.reqs_in_pool_flag%TYPE;
    -- <REQINPOOL> variable deletion

BEGIN

    -- <REQINPOOL START>
    SELECT  reqs_in_pool_flag
    INTO    l_reqs_in_pool_flag
    FROM    po_requisition_lines_all
    WHERE   requisition_line_id = p_req_line_id;

    IF (l_reqs_in_pool_flag = 'Y') THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;
    -- <REQINPOOL END>

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_INTERFACE_S2.is_in_req_pool', '000', SQLCODE );
        RAISE;

END is_req_in_pool;


PROCEDURE update_terms(p_new_po_id IN number) IS


l_source_doc_id     number;

l_terms_id                   po_headers.terms_id%TYPE;
l_fob_lookup_code            po_headers.fob_lookup_code%TYPE;
l_freight_lookup_code        po_headers.freight_terms_lookup_code%TYPE;
l_supplier_note              po_headers.note_to_vendor%TYPE;
l_receiver_note              po_headers.note_to_receiver%TYPE;

l_ship_via_lookup_code   PO_HEADERS_ALL.ship_via_lookup_code%TYPE; -- <2748409>
l_pay_on_code            PO_HEADERS_ALL.pay_on_code%TYPE;          -- <2748409>
l_bill_to_location_id    PO_HEADERS_ALL.bill_to_location_id%TYPE;  -- <2748409>
l_ship_to_location_id    PO_HEADERS_ALL.ship_to_location_id%TYPE;  -- <2748409>

-- <GC FPJ START>
l_ga_count                   NUMBER;
l_quotation_count            NUMBER;
l_lc_count                   NUMBER;
l_gc_count                   NUMBER;
-- <GC FPJ END>

l_shipping_control       PO_HEADERS_ALL.shipping_control%TYPE;    -- <INBOUND LOGISTICS FPJ>
l_return_status VARCHAR2(1);

l_api_name CONSTANT VARCHAR2(30) := 'update_terms ';

BEGIN
IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || '.begin','update terms');
END IF;
IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || 'new PO ' , to_char(p_new_po_id));
END IF;


    -- <GC FPJ START>

    -- SQL What: Get the number of distinct source documents for each source
    --           documents type referenced on this standard PO
    -- SQL Why:  Based on the terms default hierarchy, we want to default the
    --           terms and conditions from the source document if there is only
    --           one distinct document of that document type.

     /*  Bug# 5873206, The condition for checking Quotation
        was coded incorrectly. Due to this we were not considering
        Terms and conditions when Source document was a Quotation.
        Commented the NULL and added it in the else of decode. */

    SELECT COUNT(DISTINCT (DECODE(POSRC.type_lookup_code,
                                  'BLANKET',
                                  POSRC.po_header_id,
                                  NULL))),
           COUNT(DISTINCT (DECODE(POSRC.type_lookup_code,
                                  'QUOTATION',
                                  --NULL,               --Bug# 5873206,
                                  POSRC.po_header_id,
                                  NULL))),
           COUNT(DISTINCT (DECODE(POC.global_agreement_flag,
                                  'Y',
                                  NULL,
                                  POC.po_header_id))),
           COUNT(DISTINCT (DECODE(POC.global_agreement_flag,
                                  'Y',
                                  POC.po_header_id,
                                  NULL)))
    INTO   l_ga_count,
           l_quotation_count,
           l_lc_count,
           l_gc_count
    FROM   po_lines POL,
           po_headers_all POSRC,
           po_headers_all POC
    WHERE  POL.po_header_id = p_new_po_id
    AND    POL.from_header_id = POSRC.po_header_id (+)
    AND    POL.contract_id = POC.po_header_id (+);
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                    c_log_head || l_api_name || '.after_get_cnt',
                    ' ga cnt = ' || l_ga_count || ' quot cnt = ' ||
                    l_quotation_count || ' lc cnt = ' || l_lc_count ||
                    ' gc cnt = ' || l_gc_count);
    END IF;

    -- Rules of defaulting terms and conditions:
    -- The source document hieararchy for terms and conditions defaulting is:
    -- Global Agreement, Quotation, Local Contract, Global Contract.
    -- 1) For a src document type, if there is only one distinct documents
    --    referenced on the standard PO lines, default terms and conditions
    --    from that src document
    -- 2) If there are more than one distinct documents on that type being
    --    referenced on the standard PO, do not default terms and conditions
    -- 3) If there is no document of this type being referenced on the standard
    --    PO, get the next document type and repeat the same checking.

    IF (l_ga_count > 0) THEN
        IF (l_ga_count = 1) THEN

            -- default terms from GA
            get_distinct_src_id
            (  p_po_header_id => p_new_po_id,
               p_src_doc_type => 'BLANKET',
               p_global_flag  => 'Y',
               x_src_doc_id   => l_source_doc_id
            );
        END IF;
    ELSIF (l_quotation_count > 0) THEN
        IF (l_quotation_count = 1) THEN

            -- default terms from Quotation
            get_distinct_src_id
            (  p_po_header_id => p_new_po_id,
               p_src_doc_type => 'QUOTATION',
               p_global_flag  => 'N',
               x_src_doc_id   => l_source_doc_id
            );
        END IF;
    ELSIF (l_lc_count > 0) THEN
        IF (l_lc_count = 1) THEN

            -- default terms from local contract
            get_distinct_src_id
            (  p_po_header_id => p_new_po_id,
               p_src_doc_type => 'CONTRACT',
               p_global_flag  => 'N',
               x_src_doc_id   => l_source_doc_id
            );
        END IF;
    ELSIF (l_gc_count > 0) THEN
        IF (l_gc_count = 1) THEN

            -- default terms from global contract
            get_distinct_src_id
            (  p_po_header_id => p_new_po_id,
               p_src_doc_type => 'CONTRACT',
               p_global_flag  => 'Y',
               x_src_doc_id   => l_source_doc_id
            );
        END IF;
    END IF;

    -- The original method of getting l_source_doc_id is not used
    -- anymore. The code has been removed

    -- <GC FPJ END>

    IF (l_source_doc_id IS NOT NULL) THEN           -- bug2930830
IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || 'source ' , to_char(l_source_doc_id));
END IF;

       Select  terms_id,
              fob_lookup_code,
              freight_terms_lookup_code,
              note_to_vendor,
              note_to_receiver,
              ship_via_lookup_code,                 -- <2748409>
              pay_on_code,                          -- <2748409>
              bill_to_location_id,                  -- <2748409>
              ship_to_location_id,                  -- <2748409>
              shipping_control    -- <INBOUND LOGISTICS FPJ>
       into   l_terms_id     ,
              l_fob_lookup_code   ,
              l_freight_lookup_code ,
              l_supplier_note,
              l_receiver_note,
              l_ship_via_lookup_code,               -- <2748409>
              l_pay_on_code,                        -- <2748409>
              l_bill_to_location_id,                -- <2748409>
              l_ship_to_location_id,                -- <2748409>
              l_shipping_control    -- <INBOUND LOGISTICS FPJ>
       From po_headers_all
       Where po_header_id = l_source_doc_id;
IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || 'After SELECTing Terms and Conditions.' , 0);
END IF;

       -- Bug 3807992: Added nvl to the terms to retain existing values if the
       -- source doc does not have terms
       update po_headers_all
       set terms_id = nvl(l_terms_id ,terms_id),
           fob_lookup_code =  nvl(l_fob_lookup_code,fob_lookup_code),
           freight_terms_lookup_code =  nvl(l_freight_lookup_code,freight_terms_lookup_code),
           note_to_vendor = l_supplier_note,
           note_to_receiver = l_receiver_note,
           shipping_control = nvl(l_shipping_control,shipping_control)    -- <INBOUND LOGISTICS FPJ>
       where po_header_id = p_new_po_id;
IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || 'After UPDATEing Global Terms and Conditions. l_ship_to_location_id: '||l_ship_to_location_id, 0);
END IF;

        -- <2748409 START>: If Req references a Global Agreement in the
        -- Owning Org, update PO w/ Local Terms and Conditions from the GA.
        --

        -- <GC PFJ>
        -- Update local terms as well if source doc is a local contract

        IF ( PO_GA_PVT.is_owning_org(l_source_doc_id) OR
             PO_GA_PVT.is_local_document(l_source_doc_id, 'CONTRACT') OR
			 (l_quotation_count = 1 and l_ship_to_location_id is not null)) --Bug 14553745
        THEN

            UPDATE    po_headers_all
            SET       ship_via_lookup_code = nvl(l_ship_via_lookup_code ,ship_via_lookup_code),
                      pay_on_code          = nvl(l_pay_on_code ,pay_on_code ),
                      bill_to_location_id  = l_bill_to_location_id ,
                      ship_to_location_id  = l_ship_to_location_id
            WHERE     po_header_id = p_new_po_id;

        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          --
        -- <2748409 END>

FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || 'After UPDATEing Local Terms and Conditions.' , 0);
        END IF;

    end if;

     -- < 11i10+ - R12  Contracts ER Start>
     -- Auto Apply the contract terms if the PO does not have any source
     -- documents on any of the lines. We already have variables above
     -- which have the src doc count. we will use these to check
     -- Bug 4618614: GSCC error to check the log level
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||
                        'Auto Apply Contract terms if applicable.' , 0);
     END IF;

     IF l_ga_count = 0        AND
        l_quotation_count = 0 AND
        l_lc_count = 0        AND
        l_gc_count   = 0
     THEN
       PO_CONTERMS_UTL_GRP.Auto_Apply_ConTerms (
            p_document_id     => p_new_po_id,
            p_template_id     => NULL,
            x_return_status   => l_return_status);
     END IF;

     -- Bug 4618614: GSCC error to check the log level
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name ||
                        'Return Status: '||l_return_status  , 0);
     END IF;
     -- < 11i10+ - R12 Contracts ER End>

exception
when others then
 IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
   FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,c_log_head || l_api_name ||'.EXCEPTION', 'update terms: Inside exception :'|| '000' ||sqlcode);
 END IF;
END update_terms;

-- <GC FPJ START>

/**=========================================================================
* Procedure: get_distinct_src_id                            <GC FPJ>
* Effects:   Get the distinct source document on the standard PO, given
*            the the source document type.
* Requires:  The proceudre assumes that there is only one distinct reference
*            document of the type specified within the whole standard PO.
* Parameters: p_po_header_id - header id of the standard PO
*             p_src_doc_type - src document type being searched for
*             p_global_flag  - whether the src document is global
*             x_src_doc_id   - return value (header id of the src document)
==========================================================================**/

PROCEDURE get_distinct_src_id
(  p_po_header_id IN         NUMBER,
   p_src_doc_type IN         VARCHAR2,
   p_global_flag  IN         VARCHAR2,
   x_src_doc_id   OUT NOCOPY NUMBER) IS

l_src_doc_id PO_HEADERS_ALL.po_header_id%TYPE := NULL;
l_global_flag PO_HEADERS_ALL.global_agreement_flag%TYPE;

BEGIN
  IF (p_src_doc_type IN ('BLANKET', 'QUOTATION')) THEN
    SELECT POH.po_header_id
    INTO   x_src_doc_id
    FROM   po_lines POL,
           po_headers_all POH
    WHERE  POL.po_header_id = p_po_header_id
    AND    POH.po_header_id = POL.from_header_id
    AND    POH.type_lookup_code = p_src_doc_type
    AND    NVL(POH.global_agreement_flag, 'N') = p_global_flag
    AND    ROWNUM = 1;

  ELSIF (p_src_doc_type = 'CONTRACT') THEN

    SELECT POH.po_header_id
    INTO   x_src_doc_id
    FROM   po_lines POL,
           po_headers_all POH
    WHERE  POL.po_header_id = p_po_header_id
    AND    POH.po_header_id = POL.contract_id
    AND    NVL(POH.global_agreement_flag, 'N') = p_global_flag
    AND    ROWNUM = 1;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_src_doc_id := NULL;
END get_distinct_src_id;

-- <GC FPJ END>

END po_interface_s2;

/
