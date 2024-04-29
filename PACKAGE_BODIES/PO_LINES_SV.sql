--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV" as
/* $Header: POXPOL1B.pls 120.6.12010000.6 2009/10/08 10:01:30 dtoshniw ship $ */

/*=============================  PO_LINES_SV  ===============================*/


/*===========================================================================

  PROCEDURE NAME: delete_line()

===========================================================================*/

PROCEDURE delete_line(X_type_lookup_code  IN  VARCHAR2,
                      X_po_line_id        IN  NUMBER,
                      X_row_id            IN  VARCHAR2,
                      p_skip_validation   IN VARCHAR2) --<HTML Agreements R12>)
IS
x_progress  VARCHAR2(3) := '';
X_allow_delete  VARCHAR2(1) := '';
X_po_line_num   NUMBER      := '';
X_po_header_id  NUMBER      := '';
l_type_name     po_document_types.type_name%type; --Bug 3453216;
BEGIN
  x_progress := '010';
  --<HTML Agreements R12 Start>
  -- If the calling source is HTML then we need not do the validations as we
  -- would have already performed these validations in
  -- PO_LINES_SV.check_deletion_allowed
  IF p_skip_validation = 'Y' THEN
      x_allow_delete := 'Y';
  ELSE
      /*
      ** Get additional line information for delete verification
      */
      SELECT line_num,
         po_header_id
      INTO   X_po_line_num,
             X_po_header_id
      FROM   po_lines pol
      WHERE  po_line_id = X_po_line_id;

      /*
      ** Verify a line can be deleted
      */
      IF (X_type_lookup_code = 'RFQ') THEN
        /*
        ** verify rfq line can be deleted.
        */
        po_rfqs_sv.val_line_delete (X_po_line_id,
                    X_po_header_id,
                    X_allow_delete);

      ELSIF (X_type_lookup_code = 'QUOTATION') THEN
        /*
        ** verify quotation line can be deleted.
        */
        po_quotes_sv.val_line_delete(X_po_line_id,
                     X_po_line_num,
                     X_po_header_id,
                     X_allow_delete);

      -- bug 424099
      -- Check for Blanket PO

      ELSIF (X_type_lookup_code IN ('STANDARD', 'PLANNED','BLANKET')) THEN
      /*
      ** verify PO line can be deleted.
      */
      --Bug 3453216. Added token values for the message
      --'PO_PO_USE_CANCEL_ON_APRVD_PO3'. Deriving the token values here from
      --X_type_lookup_code
      Begin
        IF X_type_lookup_code IN ('STANDARD','PLANNED') THEN
           select type_name
           into l_type_name
           from po_document_types
           where document_type_code = 'PO'
           and document_subtype=X_type_lookup_code;
        ELSIF X_type_lookup_code='BLANKET' THEN
           select type_name
           into l_type_name
           from po_document_types
           where document_type_code = 'PA'
           and document_subtype='BLANKET';
        END IF;
      Exception when others THEN
        l_type_name := X_type_lookup_code;
      End;
      po_lines_sv.val_line_delete(X_po_line_id    => X_po_line_id,
                                  X_allow_delete  => X_allow_delete,
                                  p_token         => 'DOCUMENT_TYPE',
                                  p_token_value   => l_type_name);

      ELSE
        x_progress:= '020';
        po_message_s.sql_error('document type is invalid', x_progress, sqlcode);

      END IF;
  END IF; --p_skip_validation = 'Y'
  /*
  ** If deletion is permitted, call the Lines table handler to delete row.
  */
  IF (x_allow_delete = 'Y') THEN

    /* call the ATTACHMENTS PKG to delete all attachments*/
    fnd_attached_documents2_pkg.delete_attachments('PO_LINES',
                                     x_po_line_id,
                                     '', '', '', '', 'Y');


    /*
    ** Delete all children of the selected line.
    */

    po_lines_sv.delete_children(X_type_lookup_code, X_po_line_id);
    --dbms_output.put_line('after delete children');

    --<Enhanced Pricing Start:>
    PO_PRICE_ADJUSTMENTS_PKG.delete_price_adjustments
      ( p_po_header_id => X_po_header_id
      , p_po_line_id => X_po_line_id
      );
    --<Enhanced Pricing End>

    /*
    ** Delete the Line.
    */

    po_lines_pkg_sud.delete_row(X_row_id);
    --dbms_output.put_line('after call to delete row');


  END IF;

EXCEPTION

  WHEN OTHERS THEN
    --dbms_output.put_line('In exception');
    po_message_s.sql_error('delete_line', x_progress, sqlcode);
    raise;


END delete_line;

/*===========================================================================

  PROCEDURE NAME: delete_all_lines

===========================================================================*/
PROCEDURE delete_all_lines( X_po_header_id        IN     NUMBER
                           ,p_type_lookup_code    IN     VARCHAR2) IS

  X_progress                VARCHAR2(3)  := '';
  X_po_line_id              NUMBER       := '';

 CURSOR C_LINE is
         SELECT po_line_id
         FROM   po_lines_all /*Bug6632095: using base table instead of view */
         WHERE  po_header_id = X_po_header_id;


BEGIN

    X_progress := '010';

    -- delete attachements associated with shipment.
        OPEN C_LINE;

        LOOP

           FETCH C_LINE INTO x_po_line_id;
           EXIT WHEN C_LINE%notfound;

           fnd_attached_documents2_pkg.delete_attachments('PO_LINES',
                              x_po_line_id,
                              '', '', '', '', 'Y');

           --<HTML Agreements R12 Start>
           --Delete the Price differentials entity type for the given Line
            PO_PRICE_DIFFERENTIALS_PKG.del_level_specific_price_diff(
                                   p_doc_level => PO_CORE_S.g_doc_level_LINE
                                  ,p_doc_level_id => x_po_line_id);
           --<HTML Agreements R12 End>
        END LOOP;

        CLOSE C_LINE;

  X_progress := '015';

  --<Unified Catalog R12: Start>
  PO_ATTRIBUTE_VALUES_PVT.delete_attributes_for_header
  (
    p_doc_type     => p_type_lookup_code
  , p_po_header_id => x_po_header_id
  );
  --<Unified Catalog R12: End>

  --Enhanced Pricing
  PO_PRICE_ADJUSTMENTS_PKG.delete_price_adjustments(p_po_header_id => X_po_header_id );

  --dbms_output.put_line('Before delete all lines');
  DELETE FROM PO_LINES_ALL /*Bug6632095: using base table instead of view */
  WHERE  po_header_id = X_po_header_id;

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In exception');
    po_message_s.sql_error('delete_all_lines', X_progress, sqlcode);
    raise;
END delete_all_lines;

/*===========================================================================

  PROCEDURE NAME: delete_children

===========================================================================*/
PROCEDURE delete_children(X_type_lookup_code  IN  VARCHAR2,
        X_po_line_id    IN  NUMBER) IS

X_progress                VARCHAR2(3)  := '';
BEGIN

  IF (X_type_lookup_code IN ('PLANNED', 'STANDARD')) THEN

     /* Delete Distributions for a PO */
     X_progress := '010';
     --dbms_output.put_line('Before Delete All Distributions');
     po_distributions_sv.delete_distributions(X_po_line_id, 'LINE');

  END IF;

  X_progress := '020';
  --dbms_output.put_line('In call to delete children');
  po_shipments_sv4.delete_all_shipments(X_po_line_id, 'LINE',
          X_type_lookup_code);

   X_progress := '030';
   --<Unified Catalog R12: Start>
   -- Deleting the Attribute values associated with the BLANKET or QUOTATION
   IF X_type_lookup_code IN ('BLANKET', 'QUOTATION') THEN
     PO_ATTRIBUTE_VALUES_PVT.delete_attributes
     (
       p_doc_type   => x_type_lookup_code
     , p_po_line_id => x_po_line_id
     );
   END IF;
   --<Unified Catalog R12: End>

   --<HTML Agreements R12 Start>
   --Delete the Price differentials entity type for the given Line
    PO_PRICE_DIFFERENTIALS_PKG.del_level_specific_price_diff(
                           p_doc_level => PO_CORE_S.g_doc_level_LINE
                          ,p_doc_level_id => x_po_line_id);
   --<HTML Agreements R12 End>

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In exception');
    po_message_s.sql_error('delete_children', X_progress, sqlcode);
    raise;
END delete_children;
/*===========================================================================

  PROCEDURE NAME: test_val_line_delete()

===========================================================================*/

PROCEDURE test_val_line_delete(X_po_line_id   IN  NUMBER) IS

X_allow_delete    VARCHAR2(1) := '';

BEGIN

  --dbms_output.put_line('Before_call');

  po_lines_sv.val_line_delete(X_po_line_id, X_allow_delete);

  --dbms_output.put_line('After call');
  --dbms_output.put_line('Allow Delete = '||X_allow_delete);

END test_val_line_delete;


/*===========================================================================

  PROCEDURE NAME: check_line_deletion_allowed()

===========================================================================*/
 --
 -- This is the same procedure as what is val_line_delete, but the exceptions are not
 -- raised.  The are returned in x_message_text.
 --
PROCEDURE check_line_deletion_allowed
    (X_po_line_id   IN  NUMBER,
     X_allow_delete     IN OUT  NOCOPY VARCHAR2,
                 p_token    IN  VARCHAR2,
                 p_token_value    IN  VARCHAR2,
     x_message_text         OUT NOCOPY VARCHAR2)
IS
x_progress VARCHAR2(3) := '';

l_type_lookup_code  PO_HEADERS_ALL.type_lookup_code%TYPE;
l_some_dists_reserved_flag  VARCHAR2(1);

l_approved_flag PO_HEADERS_ALL.approved_flag%type;
l_po_header_id  PO_HEADERS_ALL.po_header_id%type;
l_approved_date PO_HEADERS_ALL.approved_date%type;

l_line_creation_date PO_LINES_ALL.creation_date%type;
BEGIN
  x_progress := '010';

  -- Get type lookup code and approval status. Variables are used in later checks
  SELECT POH.type_lookup_code,
         POH.approved_flag,
         POH.po_header_id,
         POH.approved_date,
         POL.creation_date
   INTO  l_type_lookup_code,
         l_approved_flag,
         l_po_header_id,
         l_approved_date,
         l_line_creation_date
   FROM  po_headers_all POH,
         po_lines_all POL
   WHERE POH.po_header_id = POL.po_header_id
     AND POL.po_line_id = X_po_line_id;

  -- Following check is in key_delrec and not in val_line_delete
  -- Therefore, it was not included in the original revision of this method
  --<HTML Agreements R12 Start>
  -- Removing checks mentioned below and straight away checking if the line was
  -- atleast approved once. We wont allow deletion of the line if it has been part
  -- of an Approved Document.
  -- These checks below are NOT DONE ANY MORE
  -- For blanket PO's, do the following checks:
  -- 1) If the document status has been approved, do not allow user to delete line
  -- 2) If the document is in requires reapproval state, do not allow deletion if:
  --    - If the line under consideration has been archived already OR
  --    - Any open releases exist on the document. We have to do this second check
  --      because a document in requires re-approval status is not necessarily
  --      archived. This happens if the set up is for archive on print.
  --<HTML Agreements R12 End>

  IF (l_type_lookup_code = 'BLANKET') THEN
    IF (l_approved_flag = 'Y') THEN

      X_allow_delete := 'N';

    ELSIF (l_approved_flag = 'R') THEN

        --<HTML Agreements R12 Start>
        --Modified the above mentioned checks for Blanket Agreements in Version 120.2
        IF (l_approved_date IS NOT NULL
             AND l_line_creation_date <= l_approved_date) THEN
               X_allow_delete := 'N';
        END IF;
         --<HTML Agreements R12 End>

    END IF; -- if l_approved_flag = 'Y'
  END IF;   -- if l_type_lookup_code = 'BLANKET'

  -- If any checks have failed so far, there's no need to do further checks
  -- Fill out message text and skip to the end of this procedure
  IF (X_allow_delete = 'N') THEN
    x_message_text := PO_CORE_S.get_translated_text(
                                 'PO_PO_USE_CANCEL_ON_APRVD_PO3',
                                  p_token,
                                  p_token_value);

    RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
  END IF;

  --
  -- Check to see if the Purchase Order line has approved or
  -- previously approved shipments.
  --   If it does NOT, verify the shipments are not encumbered.
  --   If it does, put a message on the stack
  --
  SELECT MAX('N')
  INTO   X_allow_delete
  FROM   po_line_locations pll
  WHERE  pll.po_line_id  = X_po_line_id
  AND    pll.approved_flag IN ('Y','R');

  IF (X_allow_delete is NULL) THEN

    --
    -- Check to see if the Purchase Order line has encumbered shipments.
    --   If it does NOT, allow deletion.
    --   If it does, put the appropriate message on the stack
    --

   SELECT POH.type_lookup_code
   INTO l_type_lookup_code
   FROM PO_HEADERS_ALL POH,
  PO_LINES_ALL POL
   WHERE POH.po_header_id = POL.po_header_id
   AND POL.po_line_id = x_po_line_id;

   X_allow_delete := 'Y';

   IF (l_type_lookup_code IN ('STANDARD','PLANNED')) THEN

      PO_CORE_S.are_any_dists_reserved(
         p_doc_type => PO_CORE_S.g_doc_type_PO
      ,  p_doc_level => PO_CORE_S.g_doc_level_LINE
      ,  p_doc_level_id => x_po_line_id
      ,  x_some_dists_reserved_flag => l_some_dists_reserved_flag
      );

      IF (l_some_dists_reserved_flag = 'N') THEN
         x_allow_delete := 'Y';
      ELSE
         x_allow_delete := 'N';
   x_message_text := PO_CORE_S.get_translated_text(
               'PO_PO_USE_CANCEL_ON_ENCUMB_PO');
      END IF;
   END IF;


  ELSE
    x_message_text := PO_CORE_S.get_translated_text(
      'PO_PO_USE_CANCEL_ON_APRVD_PO3',
      p_token,
      p_token_value);
  END IF;


EXCEPTION
  WHEN PO_CORE_S.G_EARLY_RETURN_EXC THEN
   NULL;

  WHEN NO_DATA_FOUND then
       -- There are no shipments for the given line
       X_allow_delete := 'Y';

  WHEN OTHERS THEN
    po_message_s.sql_error('val_delete', x_progress, sqlcode);
    raise;
END check_line_deletion_allowed;



/*===========================================================================

  PROCEDURE NAME: val_line_delete()

===========================================================================*/
  /*
  ** this val line delete is specific to purchase orders.
  */
PROCEDURE val_line_delete
    (X_po_line_id   IN  NUMBER,
     X_allow_delete     IN OUT  NOCOPY VARCHAR2,
                 p_token    IN  VARCHAR2,  -- Bug 3453216
                 p_token_value    IN  VARCHAR2)  -- Bug 3453216
IS
x_progress VARCHAR2(3) := '';

--<Encumbrance FPJ>
l_type_lookup_code  PO_HEADERS_ALL.type_lookup_code%TYPE;
l_some_dists_reserved_flag  VARCHAR2(1);

BEGIN
  x_progress := '010';

  /*
  ** Check to see if the Purchase Order line has approved or
  ** previously approved shipments.
  **   If it does NOT, verify the shipments are not encumbered.
  **   If it does, display message and prevent deletion.
  */
  SELECT MAX('N')
  INTO   X_allow_delete
  FROM   po_line_locations pll
  WHERE  pll.po_line_id  = X_po_line_id
  AND    pll.approved_flag IN ('Y','R');

  IF (X_allow_delete is NULL) THEN

    /*
    ** Check to see if the Purchase Order line has encumbered shipments.
    **   If it does NOT, allow deletion.
    **   If it does, display message and prevent deletion.
    */

   --<Encumbrance FPJ START>
   -- Only check for reserved distributions for Standard and Planned PO lines.

   SELECT POH.type_lookup_code
   INTO l_type_lookup_code
   FROM PO_HEADERS_ALL POH
   ,  PO_LINES_ALL POL
   WHERE POH.po_header_id = POL.po_header_id
   AND POL.po_line_id = x_po_line_id
   ;


  --Bug 8611806: Check for GBPA. If this line has been referred in SPO, do not allow delete.

   IF(l_type_lookup_code='BLANKET') THEN
      SELECT Max('N')
        INTO X_allow_delete
        FROM po_lines_all pol
       WHERE pol.from_line_id = X_po_line_id ;

     IF ( X_allow_delete = 'N' ) THEN
        po_message_s.app_error('PO_PO_USE_CANCEL_ON_APRVD_PO3',p_token,p_token_value);
        RETURN ;
     END IF ;
   END IF;



   -- Bug 3320400,
   -- Should initialize X_allow_delete for document other than
   -- Standard/Planned PO, otherwise, val_line_delete will return NULL.
   X_allow_delete := 'Y';

   IF (l_type_lookup_code IN ('STANDARD','PLANNED')) THEN

      PO_CORE_S.are_any_dists_reserved(
         p_doc_type => PO_CORE_S.g_doc_type_PO
      ,  p_doc_level => PO_CORE_S.g_doc_level_LINE
      ,  p_doc_level_id => x_po_line_id
      ,  x_some_dists_reserved_flag => l_some_dists_reserved_flag
      );

      IF (l_some_dists_reserved_flag = 'N') THEN
         x_allow_delete := 'Y';
      ELSE
         x_allow_delete := 'N';
         po_message_s.app_error('PO_PO_USE_CANCEL_ON_ENCUMB_PO');
      END IF;
   END IF;
   --<Encumbrance FPJ END>


  ELSE
    --Bug 3453216. Updated the message name and set the token values
    po_message_s.app_error('PO_PO_USE_CANCEL_ON_APRVD_PO3',p_token,p_token_value);
  END IF;

  --dbms_output.put_line('Allow delete = '||X_allow_delete);

EXCEPTION
  when no_data_found then

       /* There are no shipments for the given line */
       X_allow_delete := 'Y';

  WHEN OTHERS THEN
    --dbms_output.put_line('In VAL exception');
    po_message_s.sql_error('val_delete', x_progress, sqlcode);
    raise;
END val_line_delete;

/*===========================================================================

  PROCEDURE NAME: val_update()

===========================================================================*/

PROCEDURE val_update
    (X_po_line_id   IN  NUMBER,
     X_quantity_ordered IN  NUMBER) IS

X_progress    VARCHAR2(3)  := '';
X_entity_level    VARCHAR2(25) := 'LINE';
X_quantity_released NUMBER       := '';
X_ordered_lt_released VARCHAR2(1)  := '';

BEGIN

  X_progress := '010';
  /*
  ** The client side will call this procedure only if the type lookup code
  ** is either PLANNED or BLANKET.
  */
  --po_shipments_sv.val_sched_released_qty(X_entity_level,
  --         X_po_line_id,
  --         '',
  --         '',
  --         X_quantity_ordered,
  --         X_quantity_released,
  --         X_ordered_lt_released);
  /*
  ** DEBUG: Kim is changing the function called above to a procedure,
  ** passing back X_quantity_released and <I assume> X_ordered_lt_released.
  ** need to verify X_ordered_lt_released.
  */

  X_progress := '020';
  --dbms_output.put_line ('after call to val_sched_release_qty');

  /*
  ** If the quantity ordered is less than the quantity released, a message
  ** is displayed.
  */
  IF (X_ordered_lt_released = 'Y') THEN
    po_message_s.app_error('PO_PO_REL_EXCEEDS_QTY',
         'SCHEDULED_QTY', TO_CHAR(X_quantity_released));
  END IF;

  --dbms_output.put_line ('Ordered < Released = '||X_ordered_lt_released);
  --dbms_output.put_line ('Quantity released = '||X_quantity_released);

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('val_update', x_progress, sqlcode);
    raise;
END val_update;

/*===========================================================================

  PROCEDURE NAME: test_val_approval_status

===========================================================================*/
PROCEDURE test_val_approval_status
  (X_po_line_id     IN  NUMBER,
   X_type_lookup_code   IN  VARCHAR2,
   X_unit_price     IN  NUMBER,
   X_line_num     IN  NUMBER,
   X_item_id      IN  NUMBER,
   X_item_description   IN  VARCHAR2,
   X_quantity     IN  NUMBER,
   X_unit_meas_lookup_code  IN  VARCHAR2,
   X_from_header_id   IN  NUMBER,
   X_from_line_id     IN  NUMBER,
   X_hazard_class_id    IN  NUMBER,
   X_vendor_product_num   IN  VARCHAR2,
   X_un_number_id     IN  NUMBER,
   X_note_to_vendor   IN  VARCHAR2,
   X_item_revision    IN  VARCHAR2,
   X_category_id      IN  NUMBER,
   X_price_type_lookup_code IN  VARCHAR2,
   X_not_to_exceed_price    IN  NUMBER,
   X_quantity_committed   IN  NUMBER,
   X_committed_amount   IN  NUMBER,
         p_contract_id                  IN      NUMBER    -- <GC FPJ>
) IS

X_expiration_date      DATE;
BEGIN

  --dbms_output.put_line('before call');

  IF po_lines_sv.val_approval_status
  (X_po_line_id   ,
   X_type_lookup_code ,
   X_unit_price   ,
   X_line_num   ,
   X_item_id    ,
   X_item_description ,
   X_quantity   ,
   X_unit_meas_lookup_code,
   X_from_header_id ,
   X_from_line_id   ,
   X_hazard_class_id  ,
   X_vendor_product_num ,
   X_un_number_id   ,
   X_note_to_vendor ,
   X_item_revision  ,
   X_category_id    ,
   X_price_type_lookup_code,
   X_not_to_exceed_price  ,
   X_quantity_committed ,
   X_committed_amount,
         X_expiration_date,
         p_contract_id                   -- <GC FPJ>
        ) THEN
    --dbms_output.put_line('TRUE');
    null;
  ELSE
    null;
    --dbms_output.put_line('FALSE');
  END IF;

END test_val_approval_status;


/*===========================================================================

  FUNCTION NAME:  val_approval_status()

===========================================================================*/

FUNCTION val_approval_status
    (X_po_line_id     IN  NUMBER,
     X_type_lookup_code   IN  VARCHAR2,
     X_unit_price     IN  NUMBER,
     X_line_num     IN  NUMBER,
     X_item_id      IN  NUMBER,
     X_item_description   IN  VARCHAR2,
     X_quantity     IN  NUMBER,
     X_unit_meas_lookup_code  IN  VARCHAR2,
     X_from_header_id   IN  NUMBER,
     X_from_line_id     IN  NUMBER,
     X_hazard_class_id    IN  NUMBER,
     X_vendor_product_num   IN  VARCHAR2,
     X_un_number_id     IN  NUMBER,
     X_note_to_vendor   IN  VARCHAR2,
     X_item_revision    IN  VARCHAR2,
     X_category_id      IN  NUMBER,
     X_price_type_lookup_code IN  VARCHAR2,
     X_not_to_exceed_price    IN  NUMBER,
     X_quantity_committed   IN  NUMBER,
     X_committed_amount   IN  NUMBER,
                 X_expiration_date             IN      DATE,
     p_contract_id                  IN      NUMBER, -- <GC FPJ>
                 -- <SERVICES FPJ START>
     X_contractor_first_name        IN      VARCHAR2 default null,
                 X_contractor_last_name         IN      VARCHAR2 default null,
                 X_assignment_start_date        IN      DATE     default null,
     X_amount_db                    IN      NUMBER   default null
                 -- <SERVICES FPJ END>
                ) RETURN BOOLEAN IS

X_progress      VARCHAR2(3)  := '';
X_approval_status_changed VARCHAR2(1)  := 'N';

BEGIN

  X_progress := '010';

  IF (X_type_lookup_code IN ('STANDARD', 'PLANNED')) THEN

    --dbms_output.put_line('Unit Price = '||X_unit_price);
    --dbms_output.put_line('Line Num = '||X_line_num);
    --dbms_output.put_line('Item Id = '||X_item_id);
    --dbms_output.put_line('Item Description = '||X_item_description);
    --dbms_output.put_line('Quantity = '||X_quantity);
    --dbms_output.put_line('Unit of Measure = '||X_unit_meas_lookup_code);
    --dbms_output.put_line('From PO Id = '||X_from_header_id);
    --dbms_output.put_line('From Line Id = '||X_from_line_id);
    --dbms_output.put_line('Hazard Class Id = '||X_hazard_class_id);
    --dbms_output.put_line('Contract Num = '||X_contract_num);
    --dbms_output.put_line('Vendor Product Num = '||X_vendor_product_num);
    --dbms_output.put_line('UN Num Id = '||X_un_number_id);
    --dbms_output.put_line('Note To Vendor = '||X_note_to_vendor);
    --dbms_output.put_line('Item Revision = '||X_item_revision);
    --dbms_output.put_line('Category Id = '||X_category_id);
    --dbms_output.put_line('Price Type = '||X_price_type_lookup_code);
    --dbms_output.put_line('Not to Exceed Price = '||X_not_to_exceed_price);

    SELECT 'Y'
    INTO   X_approval_status_changed
    FROM   po_lines pol
    WHERE  pol.po_line_id  = X_po_line_id
    AND    ((pol.unit_price <> X_unit_price)
         OR (pol.unit_price is NULL
             AND
       X_unit_price is NOT NULL)
               OR (pol.unit_price is NOT NULL
       AND
       X_unit_price is NULL)
         OR (pol.line_num <> X_line_num)
         OR (pol.line_num is NULL
       AND
       X_line_num IS NOT NULL)
         OR (pol.line_num IS NOT NULL
       AND
       X_line_num IS NULL)
         OR (pol.item_id <> X_item_id)
         OR (pol.item_id is NULL
       AND
       X_item_id IS NOT NULL)
         OR (pol.item_id IS NOT NULL
       AND
       X_item_id IS NULL)
         OR (pol.item_description <> X_item_description)
         OR (pol.item_description is NULL
       AND
       X_item_description IS NOT NULL)
         OR (pol.item_description IS NOT NULL
       AND
       X_item_description IS NULL)
         OR (pol.quantity <> X_quantity)
         OR (pol.quantity is NULL
       AND
       X_quantity IS NOT NULL)
         OR (pol.quantity IS NOT NULL
       AND
       X_quantity IS NULL)
         OR (pol.unit_meas_lookup_code <> X_unit_meas_lookup_code)
         OR (pol.unit_meas_lookup_code is NULL
       AND
       X_unit_meas_lookup_code IS NOT NULL)
         OR (pol.unit_meas_lookup_code IS NOT NULL
       AND
       X_unit_meas_lookup_code IS NULL)
         OR (pol.from_header_id <> X_from_header_id)
         OR (pol.from_header_id is NULL
       AND
       X_from_header_id IS NOT NULL)
         OR (pol.from_header_id IS NOT NULL
       AND
       X_from_header_id IS NULL)
         OR (pol.from_line_id <> X_from_line_id)
         OR (pol.from_line_id is NULL
       AND
       X_from_line_id IS NOT NULL)
         OR (pol.from_line_id IS NOT NULL
       AND
       X_from_line_id IS NULL)
         OR (pol.hazard_class_id <> X_hazard_class_id)
         OR (pol.hazard_class_id is NULL
       AND
       X_hazard_class_id IS NOT NULL)
         OR (pol.hazard_class_id IS NOT NULL
       AND
       X_hazard_class_id IS NULL)
               -- <GC FPJ>
               -- Remove the check for contract_num
         OR (pol.vendor_product_num <> X_vendor_product_num)
         OR (pol.vendor_product_num is NULL
       AND
       X_vendor_product_num IS NOT NULL)
         OR (pol.vendor_product_num IS NOT NULL
       AND
       X_vendor_product_num IS NULL)
         OR (pol.un_number_id <> X_un_number_id)
         OR (pol.un_number_id is NULL
       AND
       X_un_number_id IS NOT NULL)
         OR (pol.un_number_id IS NOT NULL
       AND
       X_un_number_id IS NULL)
         OR (pol.note_to_vendor <> X_note_to_vendor)
         OR (pol.note_to_vendor is NULL
       AND
       X_note_to_vendor IS NOT NULL)
         OR (pol.note_to_vendor IS NOT NULL
       AND
       X_note_to_vendor IS NULL)
         OR (pol.item_revision <> X_item_revision)
         OR (pol.item_revision is NULL
       AND
       X_item_revision IS NOT NULL)
         OR (pol.item_revision IS NOT NULL
       AND
       X_item_revision IS NULL)
         OR (pol.category_id <> X_category_id)
         OR (pol.category_id is NULL
       AND
       X_category_id IS NOT NULL)
         OR (pol.category_id IS NOT NULL
       AND
       X_category_id IS NULL)
         OR (pol.price_type_lookup_code <> X_price_type_lookup_code)
         OR (pol.price_type_lookup_code is NULL
       AND
       X_price_type_lookup_code IS NOT NULL)
         OR (pol.price_type_lookup_code IS NOT NULL
       AND
       X_price_type_lookup_code IS NULL)
         OR (pol.not_to_exceed_price <> X_not_to_exceed_price)
         OR (pol.not_to_exceed_price is NULL
       AND
       X_not_to_exceed_price IS NOT NULL)
         OR (pol.not_to_exceed_price IS NOT NULL
       AND
       X_not_to_exceed_price IS NULL)
               -- <GC FPJ START>
               OR (pol.contract_id <> p_contract_id)
               OR (pol.contract_id IS NOT NULL
                   AND
                   p_contract_id IS NULL)
               OR (pol.contract_id IS NULL
                   AND
                   p_contract_id IS NOT NULL)
               -- <GC FPJ END>
               -- <SERVICES FPJ START>
               OR (pol.contractor_first_name <> X_contractor_first_name)
               OR (pol.contractor_first_name IS NOT NULL
                   AND
                   X_contractor_first_name IS NULL)
               OR (pol.contractor_first_name IS NULL
                   AND
                   X_contractor_first_name IS NOT NULL)

               OR (pol.contractor_last_name <> X_contractor_last_name)
               OR (pol.contractor_last_name IS NOT NULL
                   AND
                   X_contractor_last_name IS NULL)
               OR (pol.contractor_last_name IS NULL
                   AND
                   X_contractor_first_name IS NOT NULL)

               OR (pol.start_date <> X_assignment_start_date)
               OR (pol.start_date IS NOT NULL
                   AND
                   X_assignment_start_date IS NULL)
               OR (pol.start_date IS NULL
                   AND
                   X_assignment_start_date IS NOT NULL)

               OR (pol.expiration_date <> X_expiration_date)
               OR (pol.expiration_date IS NOT NULL
                   AND
                   X_expiration_date IS NULL)
               OR (pol.expiration_date IS NULL
                   AND
                   X_expiration_date IS NOT NULL)

               OR (pol.amount <> X_amount_db)
               OR (pol.amount IS NOT NULL
                   AND
                   X_amount_db IS NULL)
               OR (pol.amount IS NULL
                   AND
                   X_amount_db IS NOT NULL)
               -- <SERVICES FPJ END>
           );


    X_progress := '020';

  ELSIF (X_type_lookup_code = 'BLANKET') THEN

    --dbms_output.put_line('Unit Price = '||X_unit_price);
    --dbms_output.put_line('Line Num = '||X_line_num);
    --dbms_output.put_line('Item Id = '||X_item_id);
    --dbms_output.put_line('Item Description = '||X_item_description);
    --dbms_output.put_line('Unit of Measure = '||X_unit_meas_lookup_code);
    --dbms_output.put_line('From PO Id = '||X_from_header_id);
    --dbms_output.put_line('From Line Id = '||X_from_line_id);
    --dbms_output.put_line('Hazard Class Id = '||X_hazard_class_id);
    --dbms_output.put_line('Vendor Product Num = '||X_vendor_product_num);
    --dbms_output.put_line('UN Num Id = '||X_un_number_id);
    --dbms_output.put_line('Note To Vendor = '||X_note_to_vendor);
    --dbms_output.put_line('Item Revision = '||X_item_revision);
    --dbms_output.put_line('Category Id = '||X_category_id);
    --dbms_output.put_line('Price Type = '||X_price_type_lookup_code);
    --dbms_output.put_line('Not to Exceed Price = '||X_not_to_exceed_price);
    --dbms_output.put_line('Quantity Committed = '||X_quantity_committed);
    --dbms_output.put_line('Committed Amount = '||X_committed_amount);

    X_progress := '030';


/*  Bug 944367
    The sql statement below was split to fix the error(bug426305)
    PLS-00103: Parser stack overflow error.
    ,BUT if the first sql statement returned no rows , then
    it goes to the exception block of the procedure (though
    it returns a true) and thereby not performing the
    following sql statement and thereby returning the incorrect approval
    status change which results in incorrect authorization status
    of the Blanket agreement.
    To fix the error encapsulating the first sql statment in a separate
    plsql block and handling no data found exception to make sure that
    it does process the second sql statement if the first returns no rows.

*/
    /* ER- 1260356 - Added expiration_date so that any change to expiration_date
   at the Line Level of the blanket can also be archived  */

    BEGIN

    SELECT 'Y'
    INTO   X_approval_status_changed
    FROM   po_lines pol
    WHERE  pol.po_line_id  = X_po_line_id
    AND    ((pol.unit_price <> X_unit_price)
         OR (pol.unit_price is NULL
             AND
       X_unit_price is NOT NULL)
               OR (pol.unit_price is NOT NULL
       AND
       X_unit_price is NULL)
         OR (pol.line_num <> X_line_num)
         OR (pol.line_num is NULL
       AND
       X_line_num IS NOT NULL)
         OR (pol.line_num IS NOT NULL
       AND
       X_line_num IS NULL)
         OR (pol.item_id <> X_item_id)
         OR (pol.item_id is NULL
       AND
       X_item_id IS NOT NULL)
         OR (pol.item_id IS NOT NULL
       AND
       X_item_id IS NULL)
         OR (pol.item_description <> X_item_description)
         OR (pol.item_description is NULL
       AND
       X_item_description IS NOT NULL)
         OR (pol.item_description IS NOT NULL
       AND
       X_item_description IS NULL)
         OR (pol.quantity <> X_quantity)
         OR (pol.quantity is NULL
       AND
       X_quantity IS NOT NULL)
         OR (pol.quantity IS NOT NULL
       AND
       X_quantity IS NULL)
         OR (pol.unit_meas_lookup_code <> X_unit_meas_lookup_code)
         OR (pol.unit_meas_lookup_code is NULL
       AND
       X_unit_meas_lookup_code IS NOT NULL)
         OR (pol.unit_meas_lookup_code IS NOT NULL
       AND
       X_unit_meas_lookup_code IS NULL)
         OR (pol.from_header_id <> X_from_header_id)
         OR (pol.from_header_id is NULL
       AND
       X_from_header_id IS NOT NULL)
         OR (pol.from_header_id IS NOT NULL
       AND
       X_from_header_id IS NULL)
         OR (pol.from_line_id <> X_from_line_id)
         OR (pol.from_line_id is NULL
       AND
       X_from_line_id IS NOT NULL)
         OR (pol.from_line_id IS NOT NULL
       AND
       X_from_line_id IS NULL)
         OR (pol.hazard_class_id <> X_hazard_class_id)
         OR (pol.hazard_class_id is NULL
       AND
       X_hazard_class_id IS NOT NULL)
         OR (pol.hazard_class_id IS NOT NULL
       AND
       X_hazard_class_id IS NULL)
               -- <GC FPJ>
               -- Remove the check for CONTRACT_NUM
         OR (pol.vendor_product_num <> X_vendor_product_num)
         OR (pol.vendor_product_num is NULL
       AND
       X_vendor_product_num IS NOT NULL)
         OR (pol.vendor_product_num IS NOT NULL
       AND
       X_vendor_product_num IS NULL)
               OR (trunc(pol.expiration_date) <> trunc(X_expiration_date))
               OR (pol.expiration_date IS NULL
                   AND
                   X_expiration_date IS NOT NULL)
               OR (pol.expiration_date IS NOT NULL
                   AND
                   X_expiration_date IS NULL)
         OR (pol.un_number_id <> X_un_number_id)
         OR (pol.un_number_id is NULL
       AND
       X_un_number_id IS NOT NULL)
         OR (pol.un_number_id IS NOT NULL
       AND
       X_un_number_id IS NULL)
               -- <GC FPJ START>
               OR (pol.contract_id <> p_contract_id)
               OR (pol.contract_id IS NOT NULL
                   AND
                   p_contract_id IS NULL)
               OR (pol.contract_id IS NULL
                   AND
                   p_contract_id IS NOT NULL));
               -- <GC FPJ END>

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
              --dbms_output.put_line('No data found');
              null;
           WHEN OTHERS THEN
              --dbms_output.put_line('In Val Approval Status First exception');
              po_message_s.sql_error('val_approval_status', x_progress, sqlcode);
              raise;
       END;


    -- Bug 426305
    -- Break the SQL check into two statements to prevent
    -- from getting the server package compilation error:
    -- PLS-00103: Parser stack overflow error.
    --
    -- Continue to check the rest if the flat is not marked.
    --
    IF X_approval_status_changed <> 'Y' THEN

       SELECT 'Y'
       INTO   X_approval_status_changed
       FROM   po_lines pol
       WHERE  pol.po_line_id  = X_po_line_id
  AND (
            (pol.note_to_vendor <> X_note_to_vendor)
         OR (pol.note_to_vendor is NULL
       AND
       X_note_to_vendor IS NOT NULL)
         OR (pol.note_to_vendor IS NOT NULL
       AND
       X_note_to_vendor IS NULL)
         OR (pol.item_revision <> X_item_revision)
         OR (pol.item_revision is NULL
       AND
       X_item_revision IS NOT NULL)
         OR (pol.item_revision IS NOT NULL
       AND
       X_item_revision IS NULL)
         OR (pol.category_id <> X_category_id)
         OR (pol.category_id is NULL
       AND
       X_category_id IS NOT NULL)
         OR (pol.category_id IS NOT NULL
       AND
       X_category_id IS NULL)
         OR (pol.price_type_lookup_code <> X_price_type_lookup_code)
         OR (pol.price_type_lookup_code is NULL
       AND
       X_price_type_lookup_code IS NOT NULL)
         OR (pol.price_type_lookup_code IS NOT NULL
       AND
       X_price_type_lookup_code IS NULL)
         OR (pol.not_to_exceed_price <> X_not_to_exceed_price)
         OR (pol.not_to_exceed_price is NULL
       AND
       X_not_to_exceed_price IS NOT NULL)
         OR (pol.not_to_exceed_price IS NOT NULL
       AND
       X_not_to_exceed_price IS NULL)
         OR (pol.quantity_committed <> X_quantity_committed)
         OR (pol.quantity_committed is NULL
       AND
       X_quantity_committed IS NOT NULL)
         OR (pol.quantity_committed IS NOT NULL
       AND
       X_quantity_committed IS NULL)
         OR (pol.committed_amount <> X_committed_amount)
         OR (pol.committed_amount is NULL
       AND
       X_committed_amount IS NOT NULL)
         OR (pol.committed_amount IS NOT NULL
       AND
                   X_committed_amount IS NULL)
               -- <SERVICES FPJ START>
               OR (pol.amount <> X_amount_db)
               OR (pol.amount IS NOT NULL
                   AND
                   X_amount_db IS NULL)
               OR (pol.amount IS NULL
                   AND
                   X_amount_db IS NOT NULL)
               -- <SERVICES FPJ END>
            );
        END IF;
  END IF;

  X_progress := '040';

  IF (X_approval_status_changed = 'Y') THEN
    --dbms_output.put_line('status changed = Y');
    return(FALSE);
  ELSE
    --dbms_output.put_line('status changed = N');
    return(TRUE);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --dbms_output.put_line('No data found');
    return(TRUE);
  WHEN OTHERS THEN
    --dbms_output.put_line('In Val Approval Status exception');
    po_message_s.sql_error('val_approval_status', x_progress, sqlcode);
    raise;
END val_approval_status;

/*===========================================================================

  PROCEDURE NAME: update_released_quantity()

===========================================================================*/

PROCEDURE update_released_quantity
    (X_event    IN  VARCHAR2,
     X_shipment_type  IN  VARCHAR2,
     X_po_line_id   IN  NUMBER,
     X_original_quantity  IN  NUMBER,
     X_quantity   IN  NUMBER) IS

x_progress VARCHAR2(3) := '';

BEGIN

  x_progress := '010';

  /* Bug# 3104460 - PO_LINES.QUANTITY should not be updated. */
  IF (X_shipment_type = 'BLANKET') THEN

    IF (X_event = 'INSERT') THEN

      UPDATE PO_LINES
      SET   closed_code = 'OPEN'
      WHERE  po_line_id = X_po_line_id
      -- Bug 3202973 Should not update quantity for Services lines:
      AND    order_type_lookup_code NOT IN ('RATE', 'FIXED PRICE')
      and nvl(closed_code,'OPEN')<>'OPEN';  --Bug 8529004

    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('update_released_quantity', x_progress, sqlcode);
    raise;
END update_released_quantity;

END PO_LINES_SV;

/
