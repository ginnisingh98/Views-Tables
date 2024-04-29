--------------------------------------------------------
--  DDL for Package Body PO_LINE_TYPES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_TYPES_SV" as
/* $Header: POXSTLTB.pls 120.1.12010000.3 2009/01/28 10:37:36 mugoel ship $ */
/*==========================  PO_LINE_TYPES_SV  ===========================*/

/*===========================================================================

  FUNCTION NAME:	val_line_type()

===========================================================================*/
FUNCTION val_line_type(X_line_type_id IN NUMBER) return BOOLEAN IS

  X_progress 	    varchar2(3) := NULL;
  X_line_type_id_v  number 	:= NULL;

BEGIN

  X_progress := '010';

  /* Check if the given Line Type is active */

  SELECT line_type_id
  INTO   X_line_type_id_v
  FROM   po_line_types
  WHERE  sysdate < nvl(inactive_date, sysdate + 1)
  AND    line_type_id = X_line_type_id;

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('val_line_type',X_progress,sqlcode);
    raise;

END val_line_type;

/*===========================================================================

  PROCEDURE NAME:	test_get_line_type_def()

===========================================================================*/

PROCEDURE test_get_line_type_def
		(X_Line_Type_Id			 IN	 NUMBER) IS

X_Order_Type_Lookup_Code	VARCHAR2(25) := '';
X_Category_Id			NUMBER       := '';
X_Unit_Meas_Lookup_Code	 	VARCHAR2(25) := '';
X_Unit_Price			NUMBER	     := '';
X_Outside_Operations_Flag	VARCHAR2(1)  := '';
X_Receiving_Flag		VARCHAR2(1)  := '';
X_Receive_close_tolerance	NUMBER       := '';

BEGIN

  -- dbms_output.put_line('before call');
  -- Bug: 1189629 Added receive close tolerance to the list of parameters
  po_line_types_sv.get_line_type_def(X_Line_Type_Id,
				     X_Order_Type_Lookup_Code,
				     X_Category_Id,
				     X_Unit_Meas_Lookup_Code,
				     X_Unit_Price,
				     X_Outside_Operations_Flag,
				     X_Receiving_Flag,
                                     X_Receive_close_tolerance);

  -- dbms_output.put_line('Order Type value is = '||X_Order_Type_Lookup_Code);
  -- dbms_output.put_line('Category Id value is = '||X_Category_Id);
  -- dbms_output.put_line('Unit Measure value is = '||X_Unit_Meas_Lookup_Code);
  -- dbms_output.put_line('Unit Price  is = '||X_Unit_Price);
  -- dbms_output.put_line('Outside Op value is = '||X_Outside_Operations_Flag);
  -- dbms_output.put_line('Receiving Flag value is = '||X_Receiving_Flag);

END test_get_line_type_def;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_type_def
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function: Retrieves all attributes associated with a given line type.
--
--Parameters:
--IN:
--p_line_type_id - Unique ID of Line Type
--
--OUT:
--x_order_type_lookup_code
--x_purchase_basis
--x_matching_basis
--x_category_id
--x_unit_meas_lookup_code
--x_unit_price
--x_outside_operations_flag
--x_receiving_flag
--x_receive_close_tolerance
--
--Notes:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_line_type_def
(    p_line_type_id              IN           NUMBER
,    x_order_type_lookup_code    OUT NOCOPY   VARCHAR2
,    x_purchase_basis            OUT NOCOPY   VARCHAR2
,    x_matching_basis            OUT NOCOPY   VARCHAR2
,    x_category_id               OUT NOCOPY   NUMBER
,    x_unit_meas_lookup_code     OUT NOCOPY   VARCHAR2
,    x_unit_price                OUT NOCOPY   NUMBER
,    x_outside_operations_flag   OUT NOCOPY   VARCHAR2
,    x_receiving_flag            OUT NOCOPY   VARCHAR2
,    x_receive_close_tolerance   OUT NOCOPY   NUMBER
)
IS

x_progress VARCHAR2(3) := '';
invalid_id EXCEPTION;

-- Bug: 1189629 selected receive close tolerance also in the cursor
CURSOR C is
	SELECT 	lt.order_type_lookup_code,
            lt.purchase_basis,                                -- <SERVICES FPJ>
            lt.matching_basis,                                -- <SERVICES FPJ>
                lt.category_id,
            	lt.unit_of_measure,
            	lt.unit_price,
		nvl(lt.outside_operation_flag,'N'),
            	lt.receiving_flag,
                lt.receive_close_tolerance
	FROM   	po_line_types_b   lt                              -- <SERVICES FPJ>
     	WHERE  	lt.line_type_id = p_line_type_id;             -- <SERVICES FPJ>

BEGIN

  -- dbms_output.put_line('Before open cursor');

  IF (p_line_type_id IS NOT NULL) THEN                        -- <SERVICES FPJ>

    x_progress := '010';
    OPEN C;
    x_progress := '020';

    FETCH C into X_Order_Type_Lookup_Code,
         x_purchase_basis,                                    -- <SERVICES FPJ>
         x_matching_basis,                                    -- <SERVICES FPJ>
		 X_Category_Id,
		 X_Unit_Meas_Lookup_Code,
		 X_Unit_Price,
		 X_Outside_Operations_Flag,
		 X_Receiving_Flag,
                 X_Receive_close_tolerance;
    CLOSE C;

    -- dbms_output.put_line('Order Type value is = '||X_Order_Type_Lookup_Code);
    -- dbms_output.put_line('Category Id value is = '||X_Category_Id);
    -- dbms_output.put_line('Unit Measure value is = '||X_Unit_Meas_Lookup_Code);
    -- dbms_output.put_line('Unit Price  is = '||X_Unit_Price);
    -- dbms_output.put_line('Outside Op value is = '||X_Outside_Operations_Flag);
    -- dbms_output.put_line('Receiving Flag value is = '||X_Receiving_Flag);

  else
    x_progress := '030';
    raise invalid_id;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In exception');
    po_message_s.sql_error('get_line_type_def', x_progress, sqlcode);
    raise;

END get_line_type_def;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_type_def
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function: Retrieves all attributes associated with a given line type.
--
--Parameters:
--IN:
--p_line_type_id - Unique ID of Line Type
--
--OUT:
--x_order_type_lookup_code
--x_purchase_basis
--x_category_id
--x_unit_meas_lookup_code
--x_unit_price
--x_outside_operations_flag
--x_receiving_flag
--x_receive_close_tolerance
--
--Notes:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_line_type_def
(    p_line_type_id              IN           NUMBER
,    x_order_type_lookup_code    OUT NOCOPY   VARCHAR2
,    x_purchase_basis            OUT NOCOPY   VARCHAR2
,    x_category_id               OUT NOCOPY   NUMBER
,    x_unit_meas_lookup_code     OUT NOCOPY   VARCHAR2
,    x_unit_price                OUT NOCOPY   NUMBER
,    x_outside_operations_flag   OUT NOCOPY   VARCHAR2
,    x_receiving_flag            OUT NOCOPY   VARCHAR2
,    x_receive_close_tolerance   OUT NOCOPY   NUMBER
)
IS
    l_matching_basis             PO_LINE_TYPES_B.matching_basis%TYPE;

BEGIN

     PO_LINE_TYPES_SV.get_line_type_def
     (   p_line_type_id              => p_line_type_id
     ,   x_order_type_lookup_code    => x_order_type_lookup_code
     ,   x_purchase_basis            => x_purchase_basis
     ,   x_matching_basis            => l_matching_basis
     ,   x_category_id               => x_category_id
     ,   x_unit_meas_lookup_code     => x_unit_meas_lookup_code
     ,   x_unit_price                => x_unit_price
     ,   x_outside_operations_flag   => x_outside_operations_flag
     ,   x_receiving_flag            => x_receiving_flag
     ,   x_receive_close_tolerance   => x_receive_close_tolerance
     );

END;

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_type_def
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function: Retrieves attributes associated with a given line type.
--
--Parameters:
--IN:
--p_line_type_id - Unique ID of Line Type
--
--OUT:
--x_order_type_lookup_code
--x_purchase_basis
--x_matching_basis
--x_outside_operations_flag
--
--Notes:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_line_type_def
(    p_line_type_id              IN           NUMBER
,    x_order_type_lookup_code    OUT NOCOPY   VARCHAR2
,    x_purchase_basis            OUT NOCOPY   VARCHAR2
,    x_matching_basis            OUT NOCOPY   VARCHAR2
,    x_outside_operation_flag    OUT NOCOPY   VARCHAR2
)
IS
    l_category_id                PO_LINE_TYPES_B.category_id%TYPE;
    l_unit_meas_lookup_code      PO_LINE_TYPES_B.unit_of_measure%TYPE;
    l_unit_price                 PO_LINE_TYPES_B.unit_price%TYPE;
    l_receiving_flag             PO_LINE_TYPES_B.receiving_flag%TYPE;
    l_receive_close_tolerance    PO_LINE_TYPES_B.receive_close_tolerance%TYPE;

BEGIN

    PO_LINE_TYPES_SV.get_line_type_def
    (   p_line_type_id             => p_line_type_id
    ,   x_order_type_lookup_code   => x_order_type_lookup_code
    ,   x_purchase_basis           => x_purchase_basis
    ,   x_matching_basis           => x_matching_basis
    ,   x_category_id              => l_category_id
    ,   x_unit_meas_lookup_code    => l_unit_meas_lookup_code
    ,   x_unit_price               => l_unit_price
    ,   x_outside_operations_flag  => x_outside_operation_flag
    ,   x_receiving_flag           => l_receiving_flag
    ,   x_receive_close_tolerance  => l_receive_close_tolerance
    );

END get_line_type_def;


/*===========================================================================

  PROCEDURE NAME:	get_line_type_def()

===========================================================================*/

PROCEDURE get_line_type_def
		(X_Line_Type_Id			 IN	 NUMBER,
		 X_Order_Type_Lookup_Code	 IN OUT NOCOPY  VARCHAR2,
		 X_Category_Id			 IN OUT	NOCOPY  NUMBER,
		 X_Unit_Meas_Lookup_Code	 IN OUT	NOCOPY  VARCHAR2,
		 X_Unit_Price			 IN OUT NOCOPY  NUMBER,
		 X_Outside_Operations_Flag	 IN OUT NOCOPY  VARCHAR2,
		 X_Receiving_Flag		 IN OUT NOCOPY  VARCHAR2,
                 X_Receive_close_tolerance	 IN OUT NOCOPY  NUMBER)
IS
    l_purchase_basis     PO_LINE_TYPES_B.purchase_basis%TYPE; -- <SERVICES FPJ>

BEGIN

    -- <SERVICES FPJ START> Call to overloaded 'get_line_type_def' procedure.
    --
    PO_LINE_TYPES_SV.get_line_type_def
    (   p_line_type_id             => X_Line_Type_Id
    ,   x_order_type_lookup_code   => X_Order_Type_Lookup_Code
    ,   x_purchase_basis           => l_purchase_basis
    ,   x_category_id              => X_Category_Id
    ,   x_unit_meas_lookup_code    => X_Unit_Meas_Lookup_Code
    ,   x_unit_price               => X_Unit_Price
    ,   x_outside_operations_flag  => X_Outside_Operations_Flag
    ,   x_receiving_flag           => X_Receiving_Flag
    ,   x_receive_close_tolerance  => X_Receive_close_tolerance
    );
    -- <SERVICES FPJ END>

END get_line_type_def;



/*===========================================================================

  FUNCTION NAME:	get_line_type

===========================================================================*/

FUNCTION get_line_type (x_line_type_id NUMBER)
  RETURN VARCHAR2 is
  x_progress      VARCHAR2(3) := NULL;
  x_line_type     VARCHAR2(25);
begin
  x_progress := 10;

  SELECT polt.line_type
  INTO   x_line_type
  FROM   po_line_types polt
  WHERE  polt.line_type_id = x_line_type_id
  AND    nvl(polt.inactive_date,sysdate + 1) > sysdate;

  return(x_line_type);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  return('');

  WHEN OTHERS THEN
     po_message_s.sql_error('get_line_type', x_progress, sqlcode);
  raise;

end get_line_type;


/*===========================================================================

  FUNCTION NAME:    outside_processing_items_exist

  DESCRIPTION:      Global Agreements (FP-I): Takes a po_header_id and
                    returns TRUE if that header contains any lines with
                    Outside Processing items. FALSE otherwise.

===========================================================================*/
FUNCTION outside_processing_items_exist
(
    p_po_header_id      NUMBER
)
RETURN BOOLEAN
IS
    CURSOR l_item_csr IS
    	SELECT 	item_id, org_id
    	FROM	po_lines_all
    	WHERE 	po_header_id = p_po_header_id;

    l_item_id 		PO_LINES_ALL.item_id%TYPE;
    l_org_id		PO_LINES_ALL.org_id%TYPE;

BEGIN

    OPEN l_item_csr;
    LOOP --------------------------------------------------

	FETCH l_item_csr INTO l_item_id, l_org_id;

	EXIT WHEN l_item_csr%NOTFOUND;

	IF ( is_outside_processing_item( l_item_id, l_org_id ) ) THEN
	    return (TRUE);
	END IF;

    END LOOP; ---------------------------------------------
    CLOSE l_item_csr;

    return (false);		-- no outside processing items were found

EXCEPTION

    WHEN OTHERS THEN
	PO_MESSAGE_S.sql_error('outside_processing_items_exist','000',sqlcode);
	RAISE;

END outside_processing_items_exist;


/*===========================================================================

  FUNCTION NAME:	is_outside_processing_item

  DESCRIPTION:		Global Agreements (FP-I): Takes an item_id and
			returns TRUE if it is an Outside Processing item.
			FALSE otherwise.

===========================================================================*/
FUNCTION is_outside_processing_item
(
    p_item_id       NUMBER
,   p_org_id        NUMBER
)
RETURN BOOLEAN
IS
    l_outside_operation_flag	MTL_SYSTEM_ITEMS.outside_operation_flag%TYPE;

BEGIN

    SELECT	outside_operation_flag
    INTO	l_outside_operation_flag
    FROM	mtl_system_items
    WHERE	inventory_item_id = p_item_id
    AND		organization_id	= p_org_id;

    IF ( l_outside_operation_flag = 'Y' ) THEN
	return (TRUE);
    ELSE
	return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
	return (FALSE);
END;


/*===========================================================================

	FUNCTION:	is_outside_processing

  	DESCRIPTION: 	Takes a line_type_id and returns TRUE if that line
			type is Outside Processing, FALSE otherwise.

===========================================================================*/

FUNCTION is_outside_processing
(
	p_line_type_id 	     NUMBER
)
RETURN BOOLEAN
IS
    x_outside_operation_flag 	VARCHAR2(1) := 'N';

BEGIN

    SELECT 	outside_operation_flag
    INTO	x_outside_operation_flag
    FROM 	po_line_types
    WHERE	line_type_id = p_line_type_id;

    IF ( x_outside_operation_flag = 'Y' )
    THEN
        return (TRUE);
    ELSE
        return (FALSE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('outside_operation_flag','000',sqlcode);
        RAISE;

END is_outside_processing;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: transactions_exist
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determine if any transactions exist with the given Line Type.
--Parameters:
--IN:
--p_line_type_id
--  Unique ID of Line Type
--Returns:
--  TRUE if any transactions (in any status) exist with the given Line Type.
--  FALSE otherwise.
--Notes:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION transactions_exist
(
    p_line_type_id   NUMBER
)
RETURN VARCHAR2
IS
    l_sourcing_negs_exist_flag          VARCHAR2(1);
    l_error_code                        VARCHAR2(100);
    l_error_message                     VARCHAR2(250);

    l_transactions_exist                VARCHAR2(30);

BEGIN

    -- <Bug 8203958>
    -- Handle NO_DATA_FOUND, and set l_transactions_exist to NULL.
    BEGIN
--Bug# 7395515 START
--Remove all the cursor's with exists clauses.
--SQL ID : 28308519, 28308573, 28308549
	SELECT 'Lines Exist'
	into l_transactions_exist
        FROM   dual
	where  EXISTS (SELECT 'Req Lines Exist'
		  	   From po_requisition_lines_all PRL
			   WHERE  PRL.line_type_id = p_line_type_id)

                OR EXISTS (SELECT 'PO Lines Exist'
		           FROM   po_lines_all POL
		           WHERE  POL.line_type_id = p_line_type_id)

                OR EXISTS (SELECT  'Archived PO Lines Exist'
			   FROM   po_lines_archive_all POAL
		           WHERE  POAL.line_type_id = p_line_type_id ) ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_transactions_exist := NULL;
    END;

    If (l_transactions_exist is not null) then
	   return 'Y';
    END IF;


    PON_SOURCING_API_GRP.val_neg_exists_for_line_type
    (   p_line_type_id  => p_line_type_id
    ,   x_result        => l_sourcing_negs_exist_flag
    ,   x_error_code    => l_error_code
    ,   x_error_message => l_error_message
    );
    IF l_sourcing_negs_exist_flag = 'Y' THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;

END transactions_exist;


END po_line_types_sv;

/
