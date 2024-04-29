--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV4" as
/* $Header: POXPOH4B.pls 120.1 2008/02/25 09:22:51 adevadul ship $*/

/*=============================================================================

    FUNCTION:      is_quotation                        <GA FPI>

    DESCRIPTION:   Returns TRUE if the po_header_id is of type_lookup_code
                   'QUOTATION'. FALSE, otherwise.

=============================================================================*/
FUNCTION is_quotation
(
    p_po_header_id             IN   PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_type_lookup_code	            PO_HEADERS_ALL.type_lookup_code%TYPE;

BEGIN

    SELECT	type_lookup_code
    INTO	l_type_lookup_code
    FROM	po_headers_all
    WHERE	po_header_id = p_po_header_id;

    IF ( l_type_lookup_code = 'QUOTATION' ) THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        return (FALSE);

END is_quotation;


/*===========================================================================

  PROCEDURE NAME:	get_doc_type_lookup_code()

===========================================================================*/

PROCEDURE get_doc_type_lookup_code   (X_doc_type_code        IN     VARCHAR2,
				      X_doc_subtype          IN     VARCHAR2,
                                      X_def_doc_type_name    IN OUT NOCOPY VARCHAR2,
                                      X_def_type_lookup_code IN OUT NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   SELECT  type_name, document_subtype
     INTO  X_def_doc_type_name, X_def_type_lookup_code
     FROM  po_document_types
    WHERE  document_type_code = X_doc_type_code and
           document_subtype   = X_doc_subtype;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_def_doc_type_name    := '';
      x_def_type_lookup_code := '';
   WHEN OTHERS THEN
      po_message_s.sql_error('get_doc_type_lookup_code', x_progress, sqlcode);
   RAISE;

END get_doc_type_lookup_code;


/*===========================================================================

  PROCEDURE NAME:	get_lookup_code_dsp()

===========================================================================*/


 procedure get_lookup_code_dsp	 (X_lookup_type        	        IN VARCHAR2,
				  X_lookup_code 	        IN VARCHAR2,
                            	  X_lookup_code_dsp             IN OUT NOCOPY VARCHAR2) is

  X_progress varchar2(3) := '';

 begin
           X_progress := '010';

           select polc.displayed_field
           into   X_lookup_code_dsp
           from   po_lookup_codes polc
           where  polc.lookup_type = X_lookup_type
           and    polc.lookup_code = X_lookup_code;

 exception
      WHEN NO_DATA_FOUND THEN
           X_lookup_code_dsp := '';
      WHEN OTHERS THEN
           po_message_s.sql_error('get_lookup_code_dsp', X_progress, sqlcode);
           raise;

 end get_lookup_code_dsp;


/*=============================================================================

    PROCEDURE:      get_type_name                     <GA FPI>

    DESCRIPTION:    Gets the displayed type name for a particular po_header_id.

=============================================================================*/
FUNCTION get_type_name
(
    p_po_header_id            IN    PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN PO_DOCUMENT_TYPES_ALL.type_name%TYPE
IS
    x_type_name              PO_DOCUMENT_TYPES_ALL.type_name%TYPE;

    l_org_id                 PO_HEADERS_ALL.org_id%TYPE;
    l_type_lookup_code       PO_HEADERS_ALL.type_lookup_code%TYPE;
    l_quote_type_lookup_code PO_HEADERS_ALL.quote_type_lookup_code%TYPE;

    l_document_type_code     PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
    l_document_subtype       PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;

BEGIN

    SELECT    type_lookup_code,
              quote_type_lookup_code,
              org_id
    INTO      l_type_lookup_code,
              l_quote_type_lookup_code,
              l_org_id
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    -- based on PO_HEADERS_ALL.type_lookup_code & .quote_type_lookup_code,
    -- sets PO_DOCUMENT_TYPES_ALL.document_type_code & .document_subtype
    --
    IF ( l_type_lookup_code = 'BLANKET' ) THEN         -- Blanket Agreement
        l_document_type_code := 'PA';
        l_document_subtype := l_type_lookup_code;
    ELSIF ( l_type_lookup_code = 'QUOTATION' ) THEN    -- Quotation
        l_document_type_code := l_type_lookup_code;
        l_document_subtype := l_quote_type_lookup_code;
    ELSIF ( l_type_lookup_code = 'PLANNED' ) THEN      -- Planned PO
        l_document_type_code := 'PO';
        l_document_subtype := l_type_lookup_code;
    ELSIF ( l_type_lookup_code = 'CONTRACT' ) THEN     -- Contract Agreement
        l_document_type_code := 'PA';
        l_document_subtype := l_type_lookup_code;
    ELSIF ( l_type_lookup_code = 'RFQ' ) THEN          -- RFQ
        l_document_type_code := l_type_lookup_code;
        l_document_subtype := l_quote_type_lookup_code;
    ELSIF ( l_type_lookup_code = 'STANDARD' ) THEN     -- Standard PO
        l_document_type_code := 'PO';
        l_document_subtype := l_type_lookup_code;
    ELSE
        return (NULL);
    END IF;

    SELECT    type_name
    INTO      x_type_name
    FROM      po_document_types_all
    WHERE     document_type_code = l_document_type_code
    AND       document_subtype = l_document_subtype
    AND       org_id = l_org_id;

    return (x_type_name);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_type_name;


/*=============================================================================

    FUNCTION:       get_doc_num                      <GA FPI>

    DESCRIPTION:    Gets document number (segment1) for a po_header_id.

=============================================================================*/
FUNCTION get_doc_num
(
    p_po_header_id            IN    PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN PO_HEADERS_ALL.segment1%TYPE
IS
    x_segment1                PO_HEADERS_ALL.segment1%TYPE;

BEGIN

    SELECT    segment1
    INTO      x_segment1
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    return (x_segment1);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_doc_num;


/*=============================================================================

    FUNCTION:       get_vendor_quote_num                      <GA FPI>

    DESCRIPTION:    Gets quote_vendor_quote_num for a particular po_header_id.

=============================================================================*/
FUNCTION get_vendor_quote_num
(
    p_po_header_id        IN    PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN PO_HEADERS_ALL.quote_vendor_quote_number%TYPE
IS
    x_vendor_quote_num          PO_HEADERS_ALL.quote_vendor_quote_number%TYPE;

BEGIN

    SELECT    quote_vendor_quote_number
    INTO      x_vendor_quote_num
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    return (x_vendor_quote_num);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_vendor_quote_num;


/*===========================================================================

  FUNCTION NAME:	val_vendor_has_contracts()

===========================================================================*/

 function  val_vendor_has_contracts(X_vendor_id IN number)
           return varchar2 is
  X_vendor_has_contracts varchar2(5) := 'FALSE';
  X_contract_count  number := 0;
  X_Progress varchar2(3) := '';

 begin
       X_progress := '010';

       -- bug 411933
       -- Replace Select count by Where Exists to improve performance

       select  1
       into  X_contract_count
       from  sys.dual
       where exists
             (SELECT 'Vendor has contract'
       		from  po_headers ph
       		where ph.vendor_id = X_vendor_id
       		and  ph.type_lookup_code = 'CONTRACT'
       		and  nvl(ph.cancel_flag,'N') = 'N'
       		and  sysdate between nvl(ph.start_date, sysdate - 1)
       		and  nvl(ph.end_date, sysdate + 1));

       if X_contract_count > 0 then
            X_vendor_has_contracts := 'TRUE';
       else
            X_vendor_has_contracts := 'FALSE';
       end if;
       return(X_vendor_has_contracts);

 exception
       when no_data_found then
             X_vendor_has_contracts := 'FALSE';
             return(X_vendor_has_contracts);
       when others then
             X_vendor_has_contracts := 'FALSE';
             return(X_vendor_has_contracts);
 end val_vendor_has_contracts;

/*===========================================================================

  PROCEDURE NAME:	 get_preparer_approve_flag()

===========================================================================*/


 procedure  get_preparer_approve_flag
            (X_document_type             IN VARCHAR2,
	     X_document_subtype          IN VARCHAR2,
             X_can_preparer_approve_flag IN OUT NOCOPY VARCHAR2) is

  X_progress varchar2(3) := '';

 begin
        X_progress := '010';

        SELECT  nvl(can_preparer_approve_flag,'N')
	 INTO   X_can_preparer_approve_flag
	 FROM   po_document_types
	 WHERE  document_type_code = X_document_type
	 AND    document_subtype = X_document_subtype;

 exception
      WHEN NO_DATA_FOUND THEN
           X_can_preparer_approve_flag := '';
      WHEN OTHERS THEN
           po_message_s.sql_error(' get_preparer_approve_flag', X_progress, sqlcode);
           raise;

 end  get_preparer_approve_flag;


--=============================================================================
-- Function    : cumulative_lines_exist              -- <2706225>
-- Type        : Private
--
-- Pre-reqs    : -
-- Modifies    : -
-- Description : Determines if the document has any lines which have the
--               'Cumulative Pricing' set.
--
-- Parameters  : p_po_header_id - document ID
--
-- Returns     : TRUE if the document has 'Cumulative Pricing' lines.
--               FALSE otherwise.
-- Exceptions  : -
--=============================================================================
FUNCTION cumulative_lines_exist
(
    p_po_header_id           IN     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    l_price_break_lookup_code     PO_LINES_ALL.price_break_lookup_code%TYPE;

    CURSOR l_cumulative_csr  IS   SELECT  price_break_lookup_code
                                  FROM    po_lines_all
                                  WHERE   po_header_id = p_po_header_id;
BEGIN

    OPEN l_cumulative_csr;
    LOOP

        FETCH l_cumulative_csr INTO l_price_break_lookup_code;
        EXIT WHEN l_cumulative_csr%NOTFOUND;

        IF ( l_price_break_lookup_code = 'CUMULATIVE' )
        THEN
            return (TRUE);   -- line is Cumulative Pricing, return TRUE
        END IF;

    END LOOP;
    CLOSE l_cumulative_csr;

    return (FALSE);          -- if loop finishes, no cumulative lines found

END cumulative_lines_exist;


/*=============================================================================

    FUNCTION:     references_exist                           <GA FPI>

    DESCRIPTION:  Returns TRUE if there exist any references for any line in
                  the input po_header_id. FALSE, otherwise.

=============================================================================*/
/*FUNCTION references_exist
(
    p_po_header_id     PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN BOOLEAN
IS
    CURSOR l_reference_csr IS
        SELECT  from_header_id, from_line_id
        FROM    po_lines_all
        WHERE   po_header_id = p_po_header_id;

    l_from_header_id    PO_LINES_ALL.from_header_id%TYPE;
    l_from_line_id      PO_LINES_ALL.from_line_id%TYPE;

BEGIN

    OPEN l_reference_csr;
    LOOP

        FETCH l_reference_csr INTO l_from_header_id, l_from_line_id;
        EXIT WHEN l_reference_csr%NOTFOUND;

        IF  (   ( l_from_header_id IS NOT NULL )
            AND ( l_from_line_id IS NOT NULL ) )
        THEN
            return (TRUE);   -- reference found, return TRUE
        END IF;

    END LOOP;
    CLOSE l_reference_csr;

    return (FALSE);          -- if loop finishes, no references were found

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('references_exist','000',sqlcode);
        RAISE;
END references_exist;
*/

-- <GC FPJ START>

/**=========================================================================
* Procedure: is_contract_valid                               <GC FPJ>
* Effects:   Check whether a contract is valid to be referenced by new PO line,
*            i.e., the contract is:
*            - Not cancelled
*            - open
*            - approved
*            - not frozen
*            - not expired
* Requires:  none
* Modifies:  none
* Returns:   x_result: FND_API.G_TRUE if valid
*                      FND_API.G_FALSE otherwise
==========================================================================**/
PROCEDURE is_contract_valid
(  p_po_header_id IN         NUMBER,
   x_result       OUT NOCOPY VARCHAR2
) IS

l_is_valid VARCHAR2(1) := 'N';

BEGIN

    SELECT 'Y'
    INTO   l_is_valid
    FROM   po_headers_all POH
    WHERE  POH.po_header_id = p_po_header_id
    AND    POH.type_lookup_code = 'CONTRACT'
    AND    NVL(POH.cancel_flag, 'N') = 'N'
    AND    NVL(POH.closed_code, 'OPEN') = 'OPEN'
	AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
 	       and poh.approved_date is not null )
 	    OR POH.authorization_status = 'APPROVED' )
    AND    NVL(POH.frozen_flag, 'N') = 'N'
    AND    TRUNC(SYSDATE) BETWEEN NVL(TRUNC(POH.start_date), SYSDATE - 1)
                          AND     NVL(TRUNC(POH.end_date), SYSDATE + 1);

    IF (l_is_valid = 'Y') THEN
        x_result := FND_API.G_TRUE;
    ELSE
        x_result := FND_API.G_FALSE;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_result := FND_API.G_FALSE;
END is_contract_valid;

-- <GC FPJ END>

END PO_HEADERS_SV4;

/
