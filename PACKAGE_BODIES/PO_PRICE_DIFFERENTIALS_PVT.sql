--------------------------------------------------------
--  DDL for Package Body PO_PRICE_DIFFERENTIALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_DIFFERENTIALS_PVT" AS
/* $Header: POXVPDFB.pls 120.2 2005/09/02 01:33:45 arudas noship $*/


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: allows_price_differentials
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks the "Allow Price Differentials" flag on the Requisition Line.
--Parameters:
--IN:
--p_req_line_id
--  Unique ID of the Requisition Line.
--Returns:
--  TRUE if the "Allow Price Differentials" flag is set to 'Y'.
--  FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION allows_price_differentials
(
    p_req_line_id              IN         NUMBER
)
RETURN BOOLEAN
IS
    l_allow_price_diff_flag    PO_REQUISITION_LINES.overtime_allowed_flag%TYPE;

BEGIN

    SELECT overtime_allowed_flag
    INTO   l_allow_price_diff_flag
    FROM   po_requisition_lines_all
    WHERE  requisition_line_id = p_req_line_id;

    IF ( nvl(l_allow_price_diff_flag,'N') = 'Y' )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.allows_price_differentials', '000', SQLCODE );
        RAISE;

END allows_price_differentials;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_unique_price_diff_num
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks if the Price Differential Num for the given record is unique
--  among its set of Price Differentials.
--Parameters:
--IN:
--p_row_id
--  ROWID of record whose Price Differential Num the uniqueness check
--  is performed on.
--p_entity_type
--  Entity Type of the set of Price Differentials.
--p_entity_id
--  Unique identifier for the Entity Type.
--p_price_differential_num
--  Value of Price Differential Num to check uniqueness on.
--Returns:
--  TRUE if the Price Differential Num is unique for the given set of
--  Price Differentials. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION check_unique_price_diff_num
(
    p_row_id                      IN      ROWID
,   p_entity_type                 IN      VARCHAR2
,   p_entity_id                   IN      NUMBER
,   p_price_differential_num      IN      NUMBER
)
RETURN BOOLEAN
IS
    l_num_duplicates              NUMBER;

BEGIN

    SELECT count('# of Price Differentials with same Number')
    INTO   l_num_duplicates
    FROM   po_price_differentials
    WHERE  entity_type = p_entity_type
    AND    entity_id   = p_entity_id
    AND    price_differential_num = p_price_differential_num
    AND    ( ( p_row_id IS NULL ) OR ( ROWID <> p_row_id ) );

    IF ( l_num_duplicates >= 1 )
    THEN
        return (FALSE);
    ELSE
        return (TRUE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.check_unique_price_diff_num', '000', SQLCODE );
        RAISE;

END check_unique_price_diff_num;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_unique_price_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks if the Price Type for the given record is unique
--  among its set of Price Differentials.
--Parameters:
--IN:
--p_row_id
--  ROWID of record whose Price Type the uniqueness check
--  is performed on.
--p_entity_type
--  Entity Type of the set of Price Differentials.
--p_entity_id
--  Unique identifier for the Entity Type.
--p_price_type
--  Value of Price Type to check uniqueness on.
--Returns:
--  TRUE if the Price Type is unique for the given set of
--  Price Differentials. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION check_unique_price_type
(
    p_row_id                      IN      ROWID
,   p_entity_type                 IN      VARCHAR2
,   p_entity_id                   IN      NUMBER
,   p_price_type                  IN      VARCHAR2
)
RETURN BOOLEAN
IS
    l_num_duplicates              NUMBER;

BEGIN

    SELECT count('# of Price Differentials with same Price Type')
    INTO   l_num_duplicates
    FROM   po_price_differentials
    WHERE  entity_type = p_entity_type
    AND    entity_id   = p_entity_id
    AND    price_type = p_price_type
    AND    ( ( p_row_id IS NULL ) OR ( ROWID <> p_row_id ) );

    IF ( l_num_duplicates >= 1 )
    THEN
        return (FALSE);
    ELSE
        return (TRUE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.check_unique_price_type', '000', SQLCODE );
        RAISE;

END check_unique_price_type;


-------------------------------------------------------------------------------
--Start of Comments
--Name:         copy_price_differentials
--
--Pre-reqs:     None
--
--Modifies:     None
--
--Locks:        None
--
--Function:     This procedure copied price differentials from one entity to
--              the other
--
--
--Parameters:
--IN:
--   p_to_entity_id
--      Id of the to document entity
--   p_to_entity_type
--      Type of the to document entity : PO LINE, BLANKET LINE , PRICE BREAK
--   p_from_entity_id
--      Id of the from document entity
--   p_from_entity_type
--      Type of the from document entity : PO LINE, BLANKET LINE , PRICE BREAK
--
--Testing:  -
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE copy_price_differentials
(
    p_from_entity_type  IN  VARCHAR2
,   p_from_entity_id    IN  NUMBER
,   p_to_entity_type    IN  VARCHAR2
,   p_to_entity_id      IN  NUMBER
)
IS
BEGIN

   -- Inserts valid price differentials from the from entity to the to entity

    INSERT INTO po_price_differentials
    (   price_differential_id
    ,   price_differential_num
    ,   entity_type
    ,   entity_id
    ,   price_type
    ,   multiplier
    ,   max_multiplier
    ,   min_multiplier
    ,   enabled_flag
    ,   last_update_date
    ,   last_updated_by
    ,   last_update_login
    ,   creation_date
    ,   created_by
	)
    SELECT PO_PRICE_DIFFERENTIALS_S.NEXTVAL
    ,      PD.price_differential_num
    ,      p_to_entity_type
    ,      p_to_entity_id
    ,      PD.price_type
    ,      PD.multiplier
    ,      PD.max_multiplier
    ,      PD.min_multiplier
    ,      PD.enabled_flag
    ,      SYSDATE
    ,      fnd_global.user_id
    ,      fnd_global.login_id
    ,      SYSDATE
    ,      fnd_global.user_id
   FROM	   po_price_differentials    PD
   WHERE   PD.entity_type = p_from_entity_type
   AND     PD.entity_id = p_from_entity_id
   AND     nvl(PD.enabled_flag,'Y') = 'Y';

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.copy_price_differentials', '000', SQLCODE );
        RAISE;

END;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: create_from_interface
--Pre-reqs:
--  The Parent Lines of the Price Differentials must already be
--  inserted into their respective base tables.
--Modifies:
--  PO_PRICE_DIFFERENTIALS
--Locks:
--  None.
--Function:
--  Copies from PO_PRICE_DIFF_INTERFACE -> PO_PRICE_DIFFERENTIALS
--Parameters:
--IN:
--p_entity_id
--  Entity ID to which the Price Differentials belong
--p_interface_line_id
--  interface_line_id to which current batch of Price Diff's will belong
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE create_from_interface
(
    p_entity_id           IN  NUMBER
,   p_interface_line_id   IN  NUMBER
)
IS
BEGIN

    INSERT INTO po_price_differentials
    (    price_differential_id
    ,    price_differential_num
    ,    entity_type
    ,    entity_id
    ,    price_type
    ,    enabled_flag
    ,    min_multiplier
    ,    max_multiplier
    ,    multiplier
    ,    last_update_date
    ,    last_updated_by
    ,    last_update_login
    ,    creation_date
    ,    created_by
    )
    SELECT PO_PRICE_DIFFERENTIALS_S.nextval
    ,      PDI.price_differential_num
    ,      PDI.entity_type
    ,      p_entity_id
    ,      PDI.price_type
    ,      PDI.enabled_flag
    ,      PDI.min_multiplier
    ,      PDI.max_multiplier
    ,      PDI.multiplier
    ,      nvl(PDI.last_update_date, sysdate)
    ,      nvl(PDI.last_updated_by, FND_GLOBAL.user_id)
    ,      nvl(PDI.last_update_login, FND_GLOBAL.login_id)
    ,      nvl(PDI.creation_date, sysdate)
    ,      nvl(PDI.created_by, FND_GLOBAL.user_id)
    FROM   po_price_diff_interface    PDI
    WHERE  PDI.interface_line_id = p_interface_line_id
    AND    nvl(process_status,'ACCEPTED') = 'ACCEPTED';

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.CREATE_FROM_INTERFACE', '000', SQLCODE );
        RAISE;

END create_from_interface;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: default_price_differentials
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Defaults Price Differentials from a GA Line/Price Break to a PO Line.
--  This procedure differs from the COPY_PRICE_DIFFERENTIALS procedure in
--  that the GA's MIN_MULTIPLIER is carried over as the MULTIPLIER on the PO.
--Parameters:
--IN:
--p_from_entity_type
--  Entity Type of Price Differentials from which to copy.
--  (Must be either 'BLANKET LINE' or 'PRICE BREAK').
--p_from_entity_id
--  Entity ID of Price Differentials from which to copy.
--p_to_entity_type
--  Entity Type of the newly copied Price Differentials.
--  (Must be 'PO LINE').
--p_to_entity_id
--  Entity ID of the newly copied Price Differentials.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE default_price_differentials
(
    p_from_entity_type    IN         VARCHAR2
,   p_from_entity_id      IN         NUMBER
,   p_to_entity_type      IN         VARCHAR2
,   p_to_entity_id        IN         NUMBER
)
IS
BEGIN

    INSERT INTO po_price_differentials
    (   price_differential_id
    ,   price_differential_num
    ,   entity_type
    ,   entity_id
    ,   price_type
    ,   multiplier
    ,   max_multiplier
    ,   min_multiplier
    ,   enabled_flag
    ,   last_update_date
    ,   last_updated_by
    ,   last_update_login
    ,   creation_date
    ,   created_by
	)
    SELECT PO_PRICE_DIFFERENTIALS_S.NEXTVAL
    ,      PD.price_differential_num
    ,      p_to_entity_type
    ,      p_to_entity_id
    ,      PD.price_type
    ,      PD.min_multiplier        --> multiplier
    ,      NULL                     --> min_multiplier
    ,      NULL                     --> max_multiplier
    ,      PD.enabled_flag
    ,      SYSDATE
    ,      fnd_global.user_id
    ,      fnd_global.login_id
    ,      SYSDATE
    ,      fnd_global.user_id
   FROM	   po_price_differentials    PD
   WHERE   PD.entity_type = p_from_entity_type
   AND     PD.entity_id = p_from_entity_id
   AND     nvl(PD.enabled_flag,'Y') = 'Y';

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.default_price_differentials', '000', SQLCODE );
        RAISE;

END default_price_differentials;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_price_differentials
--Pre-reqs:
--  None.
--Modifies:
--  PO_PRICE_DIFFERENTIALS
--Locks:
--  None.
--Function:
--  Deletes the set of Price Differentials specified by the Entity Type/ID.
--Parameters:
--IN:
--p_entity_type
--  Entity Type of Price Differential
--  ['REQ LINE','PO LINE','BLANKET LINE','PRICE BREAK']
--p_entity_id
--  Unique ID of the Line or Price Break
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE delete_price_differentials
(
    p_entity_type           IN      VARCHAR2
,   p_entity_id             IN      VARCHAR2
)
IS
BEGIN

    DELETE FROM po_price_differentials
    WHERE       entity_type = p_entity_type
    AND         entity_id = p_entity_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_PRICE_DIFFERENTIALS_PVT.delete_price_differentials','000',sqlcode);
        RAISE;

END delete_price_differentials;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_max_price_diff_num
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Gets the maximum Price Differential Num for a set of Price Differentials
--  ( i.e. Price Differentials belonging to the same Entity Type/ID )
--Parameters:
--IN:
--p_entity_type
--  Entity Type of Price Differential
--  ['REQ LINE','PO LINE','BLANKET LINE','PRICE BREAK']
--p_entity_id
--  Unique ID of the Line or Price Break
--Returns:
--  NUMBER representing the current maximum Price Differential Num.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_max_price_diff_num
(
    p_entity_type         IN         VARCHAR2
,   p_entity_id           IN         NUMBER
)
RETURN NUMBER
IS
    x_max                 PO_PRICE_DIFFERENTIALS.price_differential_num%TYPE;

BEGIN

    SELECT nvl( max(price_differential_num), 0 )
    INTO   x_max
    FROM   po_price_differentials
    WHERE  entity_type = p_entity_type
    AND    entity_id = p_entity_id;

    return (x_max);

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_PRICE_DIFFERENTIALS_PVT.get_max_price_diff_num','000',SQLCODE);
        RAISE;

END get_max_price_diff_num;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_min_max_multiplier
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Gets the Minimum and Maximum Multiplier values for a given
--  Price Differential.
--Parameters:
--IN:
--p_entity_type
--  Entity Type of Price Differential
--  ['REQ LINE','PO LINE','BLANKET LINE','PRICE BREAK']
--p_entity_id
--  Unique ID of the Line or Price Break
--p_price_type
--  Price Differential Price Type
--OUT:
--x_min_multiplier
--  Minimum Multiplier
--x_max_multiplier
--  Maximum Multiplier
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_min_max_multiplier
(
    p_entity_type         IN         VARCHAR2
,   p_entity_id           IN         NUMBER
,   p_price_type          IN         VARCHAR2
,   x_min_multiplier      OUT NOCOPY NUMBER
,   x_max_multiplier      OUT NOCOPY NUMBER
)
IS
BEGIN

    SELECT min_multiplier
    ,      max_multiplier
    INTO   x_min_multiplier
    ,      x_max_multiplier
    FROM   po_price_differentials
    WHERE  entity_type = p_entity_type
    AND    entity_id = p_entity_id
    AND    price_type = p_price_type;

EXCEPTION

    WHEN OTHERS THEN
        x_min_multiplier := NULL;
        x_max_multiplier := NULL;

END get_min_max_multiplier;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_context
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Gets the Line Num, Price Break Num, Job Name and Description for a
--  particular Entity Type/ID.
--Parameters:
--IN:
--p_entity_type
--  Entity Type to which the Price Differentials will belong
--  ( Note: Does not currently support 'REQ LINE' Entity Types. )
--p_entity_id
--  Unique ID for the given Entity Type.
--OUT:
--x_line_num
--  Line Num of the Standard PO or Global Agreement Line
--x_price_break_num
--  Price Break Num (only applicable to Global Agreement Price Breaks)
--x_job_name
--  Job Name on the Standard PO or Global Agreement Line
--x_job_description
--  Job Description on the Standard PO or Global Agreement Line
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_context
(   p_entity_type         IN           VARCHAR2
,   p_entity_id           IN           NUMBER
,   x_line_num            OUT NOCOPY   NUMBER
,   x_price_break_num     OUT NOCOPY   NUMBER
,   x_job_name            OUT NOCOPY   VARCHAR2
,   x_job_description     OUT NOCOPY   VARCHAR2
)
IS
BEGIN

    IF ( p_entity_type = 'PRICE BREAK' ) THEN

        SELECT POL.line_num
        ,      POLL.shipment_num
        ,      PJ.name
        ,      POJA.job_description
        INTO   x_line_num
        ,      x_price_break_num
        ,      x_job_name
        ,      x_job_description
        FROM   po_lines_all           POL
        ,      po_line_locations_all  POLL
        ,      per_jobs_vl            PJ
        ,      po_job_associations    POJA
        WHERE  p_entity_id = POLL.line_location_id
        AND    POLL.po_line_id = POL.po_line_id
        AND    POL.job_id = PJ.job_id
        AND    PJ.job_id = POJA.job_id;

    ELSE -- ( p_entity_type IN ('PO LINE','BLANKET LINE') )

        SELECT POL.line_num
        ,      NULL
        ,      PJ.name
        ,      POJA.job_description
        INTO   x_line_num
        ,      x_price_break_num
        ,      x_job_name
        ,      x_job_description
        FROM   po_lines_all         POL
        ,      per_jobs_vl          PJ
        ,      po_job_associations  POJA
        WHERE  p_entity_id = POL.po_line_id
        AND    POL.job_id = PJ.job_id
        AND    PJ.job_id = POJA.job_id;

    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.GET_CONTEXT', '000', SQLCODE );
        RAISE;

END get_context;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: has_price_differentials
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if Price Differentials exist for a given Entity Type/ID.
--Parameters:
--IN:
--p_entity_type
--  Entity Type of Price Differential
--  ['REQ LINE','PO LINE','BLANKET LINE','PRICE BREAK']
--p_entity_id
--  Unique ID of the Line or Price Break
--Returns:
--BOOLEAN - TRUE if Price Differentials exist for the given Entity Type/ID.
--          FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION has_price_differentials
(
    p_entity_type   IN   VARCHAR2
,   p_entity_id     IN   NUMBER
)
RETURN BOOLEAN
IS
    CURSOR l_price_differentials_csr IS SELECT 'Price Differential'
                                        FROM   po_price_differentials
                                        WHERE  entity_type = p_entity_type
                                        AND    entity_id = p_entity_id
                                        AND    enabled_flag = 'Y';

    l_dummy                          l_price_differentials_csr%ROWTYPE;
    l_has_price_differentials        BOOLEAN;

BEGIN

    OPEN  l_price_differentials_csr;
    FETCH l_price_differentials_csr INTO l_dummy;
    l_has_price_differentials := l_price_differentials_csr%FOUND;
    CLOSE l_price_differentials_csr;

    return (l_has_price_differentials);

END has_price_differentials;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_price_type_enabled
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if a particular Price Type exists and is enabled for the
--  set of Price Differentials determined by the given Entity Type/ID.
--Parameters:
--IN:
--p_price_type
--  Price Type to check for.
--p_entity_type
--  Entity Type of Price Differential
--p_entity_id
--  Unique ID of the Line or Price Break
--Returns:
--  TRUE if the Price Type exists and is enabled for the given Entity Type/ID
--  Price Differentials. FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_price_type_enabled
(
    p_price_type             IN      VARCHAR2
,   p_entity_type            IN      VARCHAR2
,   p_entity_id              IN      NUMBER
)
RETURN BOOLEAN
IS
    CURSOR l_price_type_csr IS SELECT 'Price Type exists'
                               FROM   po_price_differentials
                               WHERE  entity_type = p_entity_type
                               AND    entity_id = p_entity_id
                               AND    price_type = p_price_type
                               AND    enabled_flag = 'Y';

    l_dummy                    l_price_type_csr%ROWTYPE;
    l_is_price_type_enabled    BOOLEAN;

BEGIN

    OPEN l_price_type_csr;
    FETCH l_price_type_csr INTO l_dummy;
    l_is_price_type_enabled := l_price_type_csr%FOUND;
    CLOSE l_price_type_csr;

    return (l_is_price_type_enabled);

END is_price_type_enabled;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: setup_interface_table
--Pre-reqs:
--  The Parent Lines of the Price Differentials must already be
--  inserted into their respective Interface tables.
--Modifies:
--  PO_PRICE_DIFF_INTERFACE
--Locks:
--  None.
--Function:
--  Copies from PO_PRICE_DIFFERENTIALS -> PO_PRICE_DIFF_INTERFACE
--  Fills up the Price Differentials Interface table based on the following
--  order of precedence:
--  1) The Req Line's Price Differentials if the Req Line has its
--     Resource Status as 'COMPLETE'
--  2) The Blanket Price Break's Price Differentials if the Pricing API
--     returned a Price Break for the new Standard PO Line and the
--     "Allow Price Differentials" flag is set on the Req Line.
--  3) The Blanket Line Price Differentials if the Req Line references one and
--     the "Allow Price Differentials" flag is set on the Req Line.
--Parameters:
--IN:
--p_entity_type
--  Entity Type to which the Price Differentials will belong
--  (NOTE: the procedure currently only supports the Entity Type of 'PO LINE')
--p_interface_header_id
--  interface_header_id to which current batch of Price Diff's will belong
--p_interface_line_id
--  interface_line_id to which current batch of Price Diff's will belong
--p_req_line_id
--  Req Line ID from which is being Autocreated
--p_from_line_Id
--  Blanket Line ID which the Req Line references (may be NULL)
--p_price_break_id
--  Blanket Price Break which was returned by the Pricing API when
--  pricing the PO Line (may be NULL)
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE setup_interface_table
(
    p_entity_type              IN      VARCHAR2
,   p_interface_header_id      IN      NUMBER
,   p_interface_line_id        IN      NUMBER
,   p_req_line_id              IN      NUMBER
,   p_from_line_id             IN      NUMBER
,   p_price_break_id           IN      NUMBER
)
IS
    l_source_entity_type    PO_PRICE_DIFFERENTIALS.entity_type%TYPE;
    l_source_entity_id      PO_PRICE_DIFFERENTIALS.entity_id%TYPE;
    l_user_id               PO_PRICE_DIFFERENTIALS.created_by%TYPE :=
                                     to_number(FND_PROFILE.value('user_id'));
BEGIN

    -- Determine where to get the Price Differentials from.

    IF ( PO_SERVICES_PVT.get_contractor_status(p_req_line_id) = 'ASSIGNED' ) THEN

        l_source_entity_type := 'REQ LINE';
        l_source_entity_id := p_req_line_id;

    ELSIF ( allows_price_differentials(p_req_line_id) ) THEN

        IF ( p_price_break_id IS NOT NULL ) THEN

            l_source_entity_type := 'PRICE BREAK';
            l_source_entity_id := p_price_break_id;

        ELSIF ( p_from_line_id IS NOT NULL ) THEN

            l_source_entity_type := 'BLANKET LINE';
            l_source_entity_id := p_from_line_id;

        END IF;

    END IF;

    -- Insert into Interface Table

    INSERT INTO po_price_diff_interface
    (
        price_diff_interface_id
    ,   price_differential_num
    ,   interface_header_id
    ,   interface_line_id
    ,   entity_type
    ,   price_type
    ,   min_multiplier
    ,   max_multiplier
    ,   multiplier
    ,   enabled_flag
    ,   process_status
    ,   last_update_date
    ,   last_updated_by
    ,   last_update_login
    ,   creation_date
    ,   created_by
    )
    SELECT PO_PRICE_DIFF_INTERFACE_S.nextval
    ,      PD.price_differential_num
    ,      p_interface_header_id
    ,      p_interface_line_id
    ,      p_entity_type
    ,      PD.price_type
    ,      NULL
    ,      NULL
    ,      decode ( PD.entity_type
                  , 'REQ LINE'     , PD.multiplier
                  , 'PO LINE'      , PD.multiplier
                  , 'PRICE BREAK'  , PD.min_multiplier
                  , 'BLANKET LINE' , PD.min_multiplier
                  )
    ,      PD.enabled_flag
    ,      'ACCEPTED'
    ,      sysdate
    ,      l_user_id
    ,      l_user_id
    ,      sysdate
    ,      l_user_id
    FROM   po_price_differentials    PD
    WHERE  PD.entity_type = l_source_entity_type
    AND    PD.entity_id = l_source_entity_id
    AND    nvl(PD.enabled_flag,'N') = 'Y';

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error ( 'PO_PRICE_DIFFERENTIALS_PVT.SETUP_INTERFACE_TABLE', '000', SQLCODE );
        RAISE;

END setup_interface_table;

--<SERVICES FPJ START>
------------------------------------------------------------------------
--Start of Comments
--Name: validate_price_differentials
--Pre-reqs:
--  None
--Modifies:
--  PO_PRICE_DIFF_INTERFACE
--Locks:
--  None
--Function:
--  1) Performs validations on the price differentials data in the
--     PO_PRICE_DIFF_INTERFACE table.
--     a) Price Differential has a valid interface header ID.
--     b) Price Differential has a valid Price Type that is seeded
--        in the PO_PRICE_TYPE lookup table.
--     c) No multiple price differentials records of the same type
--        for a line or price break.
--     d) Price Differential is tied to a valid entity type.
--     e) For Blankets, minimum multiplier is mandatory and maximum
--        multiplier is optional. If the maximum multiplier is specified,
--        it has to be greater than the minimum multiplier.
--     f) Multiplier column should be null for blankets.
--     g) For Standard PO's, only a single value for the multiplier may
--        be specified.
--     h) Min/Max multiplier columns should be null for Standard PO's.
--  2) Generates unique price_differential_num's
--  3) Fill in the entity type if it is null.
--  4) If an error occurs during the validation, sets
--     the process_status for those rows to 'REJECTED'.
--Parameters:
--IN:
--p_interface_header_id
--  interface_header_id in the interface table
--p_interface_line_id
--  interface_line_id in the interface table
--p_entity_type
--  The type of the entity this price differential is tied to.
--  ['PO LINE','BLANKET LINE','PRICE BREAK']
--p_entity_id
--  Unique ID of the Line or Price Break
--p_header_processable_flag
--
--Testing:
--  None
--End of Comments
------------------------------------------------------------------------

PROCEDURE validate_price_differentials(
  p_interface_header_id      IN NUMBER,
  p_interface_line_id        IN NUMBER,
  p_entity_type              IN VARCHAR2,
  p_entity_id                IN NUMBER,
  p_header_processable_flag  IN VARCHAR2

)
IS

  CURSOR l_price_diff_csr IS
   SELECT *
   FROM PO_PRICE_DIFF_INTERFACE
   WHERE interface_line_id = p_interface_line_id;

  l_price_diff_record l_price_diff_csr%ROWTYPE;
  l_price_diff_num PO_PRICE_DIFFERENTIALS.price_differential_num%TYPE;
  l_count  NUMBER;
  l_error_flag  VARCHAR2(1);
  l_progress VARCHAR2(3) := '000';
  l_header_processable_flag VARCHAR2(1);

Begin

  l_header_processable_flag := p_header_processable_flag;
  l_price_diff_num := PO_PRICE_DIFFERENTIALS_PVT.get_max_price_diff_num (
                          p_entity_type => p_entity_type,
                          p_entity_id   => p_entity_id);

  OPEN l_price_diff_csr;
  LOOP
       FETCH l_price_diff_csr INTO l_price_diff_record;
       EXIT WHEN l_price_diff_csr%NOTFOUND;

       l_error_flag := 'N';

       l_progress := '010';

       IF l_price_diff_record.interface_header_id IS NULL THEN
            l_error_flag := 'Y';

            PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          	=> 'PO_DOCS_OPEN_INTERFACE',
               X_error_type          		=> 'WARNING',
               X_batch_id                	=> NULL,
               X_interface_header_id     	=> p_interface_header_id,
               X_interface_line_id       	=> p_interface_line_id,
               X_error_message_name      	=> 'PO_PDOI_COLUMN_NOT_NULL',
               X_table_name              	=> 'PO_PRICE_DIFF_INTERFACE',
               X_column_name             	=> 'INTERFACE_HEADER_ID',
               X_TokenName1              	=> 'COLUMN_NAME',
               X_TokenName2              	=> NULL,
               X_TokenName3              	=> NULL,
               X_TokenName4              	=> NULL,
               X_TokenName5              	=> NULL,
               X_TokenName6              	=> NULL,
               X_TokenValue1             	=> 'INTERFACE_HEADER_ID',
               X_TokenValue2             	=> NULL,
               X_TokenValue3             	=> NULL,
               X_TokenValue4             	=> NULL,
               X_TokenValue5             	=> NULL,
               X_TokenValue6             	=> NULL,
               X_header_processable_flag 	=> l_header_processable_flag,
               X_interface_dist_id       	=> NULL);

       ELSIF (l_price_diff_record.interface_header_id
                <> p_interface_header_id) THEN
           l_error_flag := 'Y';
           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_INVALID_INT_HDR_ID',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'INTERFACE_HEADER_ID',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);
       END IF;

       l_progress := '020';

       IF l_price_diff_record.price_type IS NULL THEN
           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'PRICE_TYPE',
               X_TokenName1              => 'COLUMN_NAME',
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => 'PRICE_TYPE',
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

       ELSE --l_price_diff_record.price_type is not null

         l_progress := '030';

         --Check that the Price Differentials record have a valid
         --Price Type that is seeded in the PO_PRICE_TYPE lookup table.

         SELECT COUNT(*)
         INTO   l_count
         FROM   PO_PRICE_DIFF_LOOKUPS_V
         WHERE  price_differential_type = l_price_diff_record.price_type;

         IF  (l_count <> 1) THEN

           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_INVALID_PRICE_TYPE',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'PRICE_TYPE',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         END IF; --IF (l_count <> 1)

         l_progress := '040';

         --Check that we are not creating multiple price differential
         --records of the same type for a line/price break record.

         SELECT COUNT(*)
         INTO   l_count
         FROM   PO_PRICE_DIFFERENTIALS
         WHERE  entity_type = p_entity_type
                AND entity_id = p_entity_id
                AND price_type = l_price_diff_record.price_type;

         IF (l_count > 0) THEN

           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_MULTI_DIFF',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'PRICE_TYPE',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         ELSE --l_count <= 0

           l_progress := '050';

           SELECT COUNT(*)
           INTO   l_count
           FROM   PO_PRICE_DIFF_INTERFACE
           WHERE  interface_line_id = p_interface_line_id
                  AND price_type = l_price_diff_record.price_type;

           IF (l_count > 1) THEN
             l_error_flag := 'Y';

             PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_MULTI_DIFF',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'NULL',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         END IF; --IF (l_count > 1)
        END IF; --IF (l_count > 0)
       END IF; --IF l_price_diff_record.price_type IS NULL

       l_progress := '060';

       IF (l_price_diff_record.entity_type <> p_entity_type) THEN

           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_INVALID_ENT_TYPE',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'ENTITY_TYPE',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);
       END IF; --IF (l_price_diff_record.entity_type IS NOT NULL...

       l_progress := '070';

       IF (p_entity_type = 'PO LINE') THEN

         --Price Differentials for a PO must have a non-null value
         --for the multiplier column

         IF (l_price_diff_record.multiplier IS NULL) THEN
           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_MUST_MULTIPLIER',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'MULTIPLIER',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         END IF; --IF (l_price_diff_record.multiplier IS NULL)

         IF (l_price_diff_record.min_multiplier IS NOT NULL) THEN
            l_error_flag := 'Y';

            PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_MIN_MULT',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'MIN_MULTIPLIER',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         END IF; --IF (l_price_diff_record.min_multiplier IS NOT NULL)

         IF (l_price_diff_record.max_multiplier IS NOT NULL) THEN
            l_error_flag := 'Y';

            PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_MAX_MULT',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'MAX_MULTIPLIER',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         END IF; --IF (l_price_diff_record.max_multiplier IS NOT NULL)

       ELSE --p_entity_type IN ('BLANKET', 'PRICE BREAK')

         l_progress := '080';

         --The minimum multiplier column should not be null
         --if this price differential is for a blanket or a price
         --break

         IF (l_price_diff_record.min_multiplier IS NULL) THEN

           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_MUST_MIN_MULT',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'MIN_MULTIPLIER',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

         END IF;

         IF (l_price_diff_record.max_multiplier IS NOT NULL
             AND l_price_diff_record.min_multiplier >
                 l_price_diff_record.max_multiplier) THEN

           l_error_flag := 'Y';

           PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_MAX_MULT_GE_MIN',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'MAX_MULTIPLIER',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

          END IF;

          IF (l_price_diff_record.multiplier IS NOT NULL) THEN
             l_error_flag := 'Y';

             PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
               X_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
               X_Error_type              => 'WARNING',
               X_Batch_id                => NULL,
               X_Interface_Header_Id     => p_interface_header_id,
               X_Interface_Line_id       => p_interface_line_id,
               X_Error_message_name      => 'PO_PDOI_SVC_NO_MULTIPLIER',
               X_Table_name              => 'PO_PRICE_DIFF_INTERFACE',
               X_Column_name             => 'MULTIPLIER',
               X_TokenName1              => NULL,
               X_TokenName2              => NULL,
               X_TokenName3              => NULL,
               X_TokenName4              => NULL,
               X_TokenName5              => NULL,
               X_TokenName6              => NULL,
               X_TokenValue1             => NULL,
               X_TokenValue2             => NULL,
               X_TokenValue3             => NULL,
               X_TokenValue4             => NULL,
               X_TokenValue5             => NULL,
               X_TokenValue6             => NULL,
               X_header_processable_flag => l_header_processable_flag,
               X_Interface_Dist_Id       => NULL);

          END IF; --IF (l_price_diff_record.multiplier IS NOT NULL)

       END IF; --IF (p_entity_type = 'PO LINE')

       l_progress := '090';

       IF (l_error_flag = 'Y') THEN
         UPDATE PO_PRICE_DIFF_INTERFACE
         SET process_status = 'REJECTED'
         WHERE price_diff_interface_id = l_price_diff_record.price_diff_interface_id;
       ELSE

         l_price_diff_num := l_price_diff_num + 1;

         UPDATE PO_PRICE_DIFF_INTERFACE
         SET process_status = 'ACCEPTED',
             price_differential_num = l_price_diff_num,
             entity_type = NVL(entity_type, p_entity_type)
         WHERE price_diff_interface_id = l_price_diff_record.price_diff_interface_id;

       END IF;

 END LOOP;
 CLOSE l_price_diff_csr;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('validate_price_differentials', l_progress, sqlcode);
    RAISE;
END validate_price_differentials;
--<SERVICES FPJ END>

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_price_for_price_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Gets the price for a given Price Differential.
--Parameters:
--IN:
--p_entity_type
--  Entity Type of Price Differential
--  ['REQ LINE','PO LINE','BLANKET LINE','PRICE BREAK']
--p_entity_id
--  Unique ID of the Line or Price Break
--p_price_type
--  Price Differential Price Type
--OUT:
--x_price : The line price multiplied by the multiplier for the price type
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_price_for_price_type
(
    p_entity_id           IN         NUMBER
,   p_entity_type         IN         VARCHAR2
,   p_price_type          IN         VARCHAR2
,   x_price               OUT NOCOPY NUMBER
)
IS

l_line_price  PO_LINES_ALL.unit_price%TYPE;
l_multiplier  PO_PRICE_DIFFERENTIALS.multiplier%TYPE;

BEGIN

    -- Return is any of the input parameters are not provided
    IF p_entity_type is null OR
       p_entity_id is null OR
       p_price_type is null
    THEN
       Return;
    END IF;

    SELECT unit_price
    INTO   l_line_price
    FROM   po_lines_all
    WHERE  po_line_id = p_entity_id;

    Begin
      SELECT multiplier
      INTO   l_multiplier
      FROM   po_price_differentials
      WHERE  entity_type = p_entity_type
      AND    entity_id = p_entity_id
      AND    price_type = p_price_type;
    Exception
      When NO_DATA_FOUND Then
        l_multiplier := 1;
    End;

      x_price := l_line_price * l_multiplier;


EXCEPTION

    WHEN OTHERS THEN
       x_price := null;

END get_price_for_price_type;

--<HTML Agreements R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_entity_type
--Pre-reqs:
-- None.
--Modifies:
-- None.
--Locks:
-- None.
--Function:
-- Given the document level, document type it returns the entity type with
-- with which the price differentials are created for that level/doc type.
--Parameters:
-- IN
-- p_doc_level
--  Document Level {LINE/SHIPMENT}
-- p_doc_level_id
--  Unique Identifier for the Document Line/Shipment
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_entity_type( p_doc_level   IN VARCHAR2
                         ,p_doc_level_id IN NUMBER)
RETURN VARCHAR2
IS
  l_entity_type PO_PRICE_DIFFERENTIALS.entity_type%type := NULL;
  l_ga_flag  PO_HEADERS_ALL.global_agreement_flag%TYPE;
  l_doc_subtype PO_HEADERS_ALL.type_lookup_code%TYPE;
  l_value_basis  PO_LINE_TYPES_B.order_type_lookup_code%TYPE;
  l_purchase_basis  PO_LINE_TYPES_B.purchase_basis%TYPE;

  d_module_name CONSTANT VARCHAR2(30) := 'GET_ENTITY_TYPE';
  d_module_base CONSTANT VARCHAR2(70) := 'po.plsql.PO_PRICE_DIFFERENTIALS_PVT.get_entity_type';
  d_pos NUMBER := 0;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base, 'p_doc_level', p_doc_level); PO_LOG.proc_begin(d_module_base, 'p_doc_level_id', p_doc_level_id);
  END IF;

  IF p_doc_level = PO_CORE_S.g_doc_level_LINE THEN
    d_pos := 10;

    SELECT poh.global_agreement_flag,
           poh.type_lookup_code,
           pol.order_type_lookup_code,
           pol.purchase_basis
    INTO l_ga_flag,
         l_doc_subtype,
         l_value_basis,
         l_purchase_basis
    FROM PO_LINES_ALL pol,
         PO_HEADERS_ALL poh
    WHERE poh.po_header_id = pol.po_header_id
    AND po_line_id = p_doc_level_id;

  ELSIF p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT THEN
    d_pos := 20;

    SELECT poh.global_agreement_flag,
           poh.type_lookup_code,
           pol.order_type_lookup_code,
           pol.purchase_basis
    INTO l_ga_flag,
         l_doc_subtype,
         l_value_basis,
         l_purchase_basis
    FROM PO_HEADERS_ALL poh,
         PO_LINES_ALL pol,
         PO_LINE_LOCATIONS_ALL poll
    WHERE poh.po_header_id = pol.po_header_id
    AND pol.po_line_id = poll.po_line_id
    AND poll.line_location_id = p_doc_level_id;

  END IF;

  d_pos := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module_name,d_pos,'l_ga_flag',l_ga_flag); PO_LOG.stmt(d_module_name,d_pos,'l_value_basis',l_value_basis); PO_LOG.stmt(d_module_name,d_pos,'l_purchase_basis',l_purchase_basis);
    PO_LOG.stmt(d_module_name,d_pos,'l_doc_subtype',l_doc_subtype);
  END IF;

  d_pos := 35;
  --Price Differentials are only allowed for Rate Based Temp Labor
  IF (l_value_basis <> 'RATE' OR l_purchase_basis <> 'TEMP LABOR') THEN
    RAISE PO_CORE_S.g_early_return_exc ;
  END IF;

  IF l_doc_subtype = PO_CONSTANTS_SV.STANDARD THEN
    d_pos := 40;

    IF p_doc_level = PO_CORE_S.g_doc_level_LINE THEN
      l_entity_type := 'PO LINE';
    END IF;

  ELSIF l_doc_subtype = PO_CONSTANTS_SV.BLANKET THEN
    d_pos := 50;
    --Price Differentials are only allowed for Global Blankets
    IF p_doc_level = PO_CORE_S.g_doc_level_LINE
       AND l_ga_flag = 'Y' THEN
      l_entity_type := 'BLANKET LINE';
    ELSIF p_doc_level = PO_CORE_S.g_doc_level_SHIPMENT THEN
      l_entity_type := 'PRICE BREAK';

    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base,'l_entity_type',l_entity_type);
  END IF;

  return l_entity_type;
EXCEPTION
  WHEN PO_CORE_S.g_early_return_exc THEN
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_name,d_pos,'Early exit from ' || d_module_name);
    END IF;
    return l_entity_type;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, d_module_name || ':'|| d_pos);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_pos, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END get_entity_type;

--<HTML Agreements R12 End>
END PO_PRICE_DIFFERENTIALS_PVT;

/
