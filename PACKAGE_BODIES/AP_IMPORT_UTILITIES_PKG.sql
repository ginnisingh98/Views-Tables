--------------------------------------------------------
--  DDL for Package Body AP_IMPORT_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_IMPORT_UTILITIES_PKG" AS
/* $Header: apiimutb.pls 120.67.12010000.27 2010/04/14 03:33:09 bgoyal ship $ */

-- Bug 3929697
-- Declared two global variables for getting the value of
-- distribution line number

lg_invoice_id                NUMBER :=0;
lg_dist_line_num             NUMBER ;

--==============================================================
-- copy attachment association
--
--==============================================================
FUNCTION copy_attachments(p_from_invoice_id    IN NUMBER,
                          p_to_invoice_id      IN NUMBER)
        RETURN NUMBER IS
  l_attachments_count   NUMBER := 0;
  debug_info            VARCHAR2(500);
BEGIN
  select count(1)
  into   l_attachments_count
  from   fnd_attached_documents
  where  entity_name = 'AP_INVOICES_INTERFACE'
  and    pk1_value = p_from_invoice_id;

  -- we only need to copy attachments if there is one
  if ( l_attachments_count > 0 )
  then
    fnd_attached_documents2_pkg.copy_attachments(
      x_from_entity_name => 'AP_INVOICES_INTERFACE',
      x_from_pk1_value   => p_from_invoice_id,
      x_to_entity_name   => 'AP_INVOICES',
      x_to_pk1_value     => p_to_invoice_id);
  end if;

  return l_attachments_count;
EXCEPTION

 WHEN OTHERS then

    IF (SQLCODE < 0) then
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN 0;
END copy_attachments;


/*======================================================================
 Function: Check_Control_Table
   This function is called at the beginning of the Import Program to handle
   concurrency control.  It prevents the program from running if another
   process is running for the same set of parameters.
========================================================================*/
FUNCTION Check_control_table(
          p_source              IN     VARCHAR2,
          p_group_id            IN     VARCHAR2,
          p_calling_sequence    IN     VARCHAR2) RETURN BOOLEAN IS

-- Bug 4145391. Modified the select for the cursor to improve performance.
-- Removed the p_group_id where clause and added it to the cursor
-- import_requests_group
CURSOR import_requests IS
    SELECT request_id,
           group_id
      FROM ap_interface_controls
     WHERE source = p_source
     ORDER BY request_id DESC;

CURSOR import_requests_group IS
    SELECT request_id,
           group_id
      FROM ap_interface_controls
     WHERE source = p_source
       AND group_id = p_group_id
     ORDER BY request_id DESC;

  check_control_failure    EXCEPTION;
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(500);
  l_phase                  VARCHAR2(30);
  l_status                 VARCHAR2(30);
  l_dev_phase              VARCHAR2(30);
  l_dev_status             VARCHAR2(30);
  l_message                VARCHAR2(240);
  l_new_record             VARCHAR2(1)  := 'Y';
  l_previous_request_id    NUMBER;
  l_group_id               VARCHAR2(80);

BEGIN

  -- Update the calling sequence

  current_calling_sequence :=
   'AP_Import_Utilities_Pkg.Check_control_table<-'||P_calling_sequence;

  -----------------------------------------------------------------------
  -- Step 1,
  -- Lock the control table, in case some other concurrent process try to
  -- insert a idential record
  -----------------------------------------------------------------------

  debug_info := '(Check_control_table 1) Lock the control table ';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  LOCK TABLE AP_INTERFACE_CONTROLS IN EXCLUSIVE MODE;

  debug_info := '(Check_control_table) Open import_requests cursor';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Bug 4145391. To improve the performance of the import program coding two
  -- different cursors based on the parameter p_group_id
  IF (p_group_id IS NULL) THEN
      OPEN import_requests;
  ELSE
      OPEN import_requests_group;
  END IF;

  LOOP
    -------------------------------------------------------------------------
    -- Step 2, Fetch l_previous_request_id from ap_interface_controls with
    -- the same source and group_id (optional). If group_id is null,
    -- all requests from the source will be fetched
    -------------------------------------------------------------------------

    debug_info := '(Check_control_table 2) Fetch import_requests';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Bug 4145391
    IF (p_group_id IS NULL) THEN
        FETCH import_requests INTO l_previous_request_id,
                                   l_group_id;
        EXIT WHEN import_requests%NOTFOUND OR
                  import_requests%NOTFOUND IS NULL;
    ELSE
        FETCH import_requests_group INTO l_previous_request_id,
                                         l_group_id;
        EXIT WHEN import_requests_group%NOTFOUND OR
                  import_requests_group%NOTFOUND IS NULL;
    END IF;


    -- It won't be new record if program is up to this point
    l_new_record := 'N';

    -----------------------------------------------------------------------
    -- Step 3,
    -- Check status for the concurrent program from the request_id
    -----------------------------------------------------------------------

    debug_info := '(Check_control_table 3) Check concurrent program status';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            debug_info||' previous req id ='||l_previous_request_id);
    END IF;

    IF (FND_CONCURRENT.GET_REQUEST_STATUS(
    request_id  =>l_previous_request_id,
    appl_shortname  =>'',
    program    =>'',
    phase    =>l_phase,
    status    =>l_status,
    dev_phase  =>l_dev_phase,
    dev_status  =>l_dev_status,
    message    =>l_message) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'FUNCTION GET_REQUEST_STATUS ERROR, Reason: '||l_message);
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'FND_CONCURRENT.GET_REQUEST_STATUS<-'||current_calling_sequence);
      END IF;
      RAISE Check_control_failure;

    END IF;

    -- show output values (only if debug_switch = 'Y')

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------> l_dev_phase = '||l_dev_phase
        ||' l_dev_status = '||l_dev_status
        ||' l_previous_request_id = '||to_char(l_previous_request_id));
    END IF;

    -------------------------------------------------------------------------
    -- Step 4.1
    -- Reject if any process for the source and group_id (optional) is
    -- currentlt running
    -------------------------------------------------------------------------
    IF (l_dev_phase in ('PENDING','RUNNING','INACTIVE')) then

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         'ERROR: There are existing import processes currently in the status '
         ||l_dev_phase||' for this source ('||p_source||') and group_id ('
         ||p_group_id
         ||') , please check your concurrent process requests');
      END IF;
      RAISE Check_control_failure;

    ELSIF (l_dev_phase = 'COMPLETE') THEN

       ---------------------------------------------------------------------
       -- Step 4.2
       -- Delete the previous record in ap_interface_controls if the status
       -- is 'COMPLETE'
       ---------------------------------------------------------------------
       debug_info := '(Check_control_table 4.2) Delete the previous record '||
                     'in ap_interface_controls';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
       END IF;

       -- Bug 4145391
       IF (p_group_id IS NULL) THEN
           DELETE FROM AP_INTERFACE_CONTROLS
            WHERE source = p_source
              AND request_id = l_previous_request_id;
       ELSE
           DELETE FROM AP_INTERFACE_CONTROLS
            WHERE source = p_source
              AND group_id = p_group_id
              AND request_id = l_previous_request_id;
       END IF;

    END IF;   -- for step 4

  END LOOP;

  debug_info := '(Check_control_table) CLOSE import_requests cursor';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- Bug 4145391
  IF (p_group_id IS NULL) THEN
      CLOSE import_requests;
  ELSE
      CLOSE import_requests_group;
  END IF;

  -----------------------------------------
  -- Step 5
  -- Insert record into control table
  -----------------------------------------

  debug_info := '(Check_control_table 5) Insert record into control table';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  INSERT INTO AP_INTERFACE_CONTROLS(
          source,
          group_id,
          request_id)
  VALUES (p_source,
          p_group_id,
          AP_IMPORT_INVOICES_PKG.g_conc_request_id);

  ----------------------------------------------------------------------------
  -- Step 6
  -- Commit the change to database, it will also release the lock for the table
  ----------------------------------------------------------------------------

  debug_info := '(Check_control_table 6) Commit';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  COMMIT;

  RETURN(TRUE);

EXCEPTION

 WHEN OTHERS then
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    -- Bug 4145391
    IF (p_group_id IS NULL) THEN
        CLOSE import_requests;
    ELSE
        CLOSE import_requests_group;
    END IF;

    RETURN (FALSE);

END Check_control_table;


/*======================================================================
 Procedure: Print
   Procedure to output debug messages in strings no longer than 80 chars.
========================================================================*/
PROCEDURE Print (
          P_debug               IN     VARCHAR2,
          P_string              IN     VARCHAR2)
IS
  stemp    VARCHAR2(80);
  nlength  NUMBER := 1;
BEGIN

  IF (P_Debug = 'Y') THEN
     WHILE(length(P_string) >= nlength)
     LOOP

        stemp := substrb(P_string, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
        nlength := (nlength + 80);

     END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;

/*======================================================================
 Function: Insert_Rejections
   This function is called whenever the process needs to insert a
   rejection.  If the process is called in the context of the 'XML
   Gateway' as source, the supplier must be notifies and the rejection
   code is one of a fixed list of rejection codes, then it inserts all
   tokens into the interface rejections table, else it ignores token
   parameters.
========================================================================*/
FUNCTION insert_rejections (
          p_parent_table        IN     VARCHAR2,
          p_parent_id           IN     NUMBER,
          p_reject_code         IN     VARCHAR2,
          p_last_updated_by     IN     NUMBER,
          p_last_update_login   IN     NUMBER,
          p_calling_sequence    IN     VARCHAR2,
          p_notify_vendor_flag  IN     VARCHAR2 DEFAULT NULL,
          p_token_name1         IN     VARCHAR2 DEFAULT NULL,
          p_token_value1        IN     VARCHAR2 DEFAULT NULL,
          p_token_name2         IN     VARCHAR2 DEFAULT NULL,
          p_token_value2        IN     VARCHAR2 DEFAULT NULL,
          p_token_name3         IN     VARCHAR2 DEFAULT NULL,
          p_token_value3        IN     VARCHAR2 DEFAULT NULL,
          p_token_name4         IN     VARCHAR2 DEFAULT NULL,
          p_token_value4        IN     VARCHAR2 DEFAULT NULL,
          p_token_name5         IN     VARCHAR2 DEFAULT NULL,
          p_token_value5        IN     VARCHAR2 DEFAULT NULL,
          p_token_name6         IN     VARCHAR2 DEFAULT NULL,
          p_token_value6        IN     VARCHAR2 DEFAULT NULL,
          p_token_name7         IN     VARCHAR2 DEFAULT NULL,
          p_token_value7        IN     VARCHAR2 DEFAULT NULL,
          p_token_name8         IN     VARCHAR2 DEFAULT NULL,
          p_token_value8        IN     VARCHAR2 DEFAULT NULL,
          p_token_name9         IN     VARCHAR2 DEFAULT NULL,
          p_token_value9        IN     VARCHAR2 DEFAULT NULL,
          p_token_name10        IN     VARCHAR2 DEFAULT NULL,
          p_token_value10       IN     VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN IS

  current_calling_sequence    VARCHAR2(2000);
  debug_info               VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'AP_Import_Utilities_Pkg.Insert_rejections<-'
                              ||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step1
  -- Insert into AP_INTERFACE_REJECTIONS
  --------------------------------------------------------------------------

  debug_info := '(Insert Rejections 1) Insert into AP_INTERFACE_REJECTIONS, '||
                'REJECT CODE:'||p_reject_code;

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  IF(AP_IMPORT_INVOICES_PKG.g_source = 'XML GATEWAY'
     AND NVL(p_notify_vendor_flag,'Y') = 'Y'
     AND p_reject_code in ('CAN MATCH TO ONLY 1 LINE',
                           'DUPLICATE INVOICE NUMBER',
                           'DUPLICATE LINE NUMBER',
                           'INCONSISTENT CURR',
                           'INCONSISTENT PO LINE INFO',
                           'INCONSISTENT PO SUPPLIER',
                           'INVALID INVOICE AMOUNT',
                           'INVALID ITEM',
                           'INVALID PO INFO',
                           'INVALID PO NUM',
                           'INVALID PO RELEASE INFO',
                           'INVALID PO RELEASE NUM',
                           'INVALID PO SHIPMENT NUM',
                           'NEGATIVE QUANTITY BILLED',  --Bug 5134622
                           'INVALID PRICE/QUANTITY',
                           'INVALID QUANTITY',
                           'INVALID UNIT PRICE',
                           'NO PO LINE NUM',
                           'RELEASE MISSING',
                           'MISSING PO NUM') ) THEN
    -------------------------------------------------
    -- Step 2
    -- Set notify_vendor_flag for XML GATEWAY source
    -------------------------------------------------

    debug_info := '(Insert Rejections 2) '||
                  'Set notify_vendor_flag for XML GATEWAY';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    INSERT INTO AP_INTERFACE_REJECTIONS(
          parent_table,
          parent_id,
          reject_lookup_code,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date,
          notify_vendor_flag,
          token_name1,
          token_value1,
          token_name2,
          token_value2,
          token_name3,
          token_value3,
          token_name4,
          token_value4,
          token_name5,
          token_value5,
          token_name6,
          token_value6,
          token_name7,
          token_value7,
          token_name8,
          token_value8,
          token_name9,
          token_value9,
          token_name10,
          token_value10)
   VALUES (
          p_parent_table,
          p_parent_id,
          p_reject_code,
          p_last_updated_by,
          SYSDATE,
          p_last_update_login,
          p_last_updated_by,
          SYSDATE,
          'Y', -- p_notify_vendor_flag,
          p_token_name1,
          p_token_value1,
          p_token_name2,
          p_token_value2,
          p_token_name3,
          p_token_value3,
          p_token_name4,
          p_token_value4,
          p_token_name5,
          p_token_value5,
          p_token_name6,
          p_token_value6,
          p_token_name7,
          p_token_value7,
          p_token_name8,
          p_token_value8,
          p_token_name9,
          p_token_value9,
          p_token_name10,
          p_token_value10);
  ELSE
    INSERT INTO AP_INTERFACE_REJECTIONS(
          parent_table,
          parent_id,
          reject_lookup_code,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date)
    VALUES (
          p_parent_table,
          p_parent_id,
          p_reject_code,
          p_last_updated_by,
          SYSDATE,
          p_last_update_login,
          p_last_updated_by,
          SYSDATE);

  END IF; -- if XML GATEWAY supplier rejection

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END insert_rejections;


FUNCTION get_overbill_for_shipment (
          p_po_shipment_id      IN             NUMBER,
          p_quantity_invoiced   IN             NUMBER,
	  p_amount_invoiced	   IN	       NUMBER,
          p_overbilled             OUT NOCOPY  VARCHAR2,
          p_quantity_outstanding   OUT NOCOPY  NUMBER,
          p_quantity_ordered       OUT NOCOPY  NUMBER,
          p_qty_already_billed     OUT NOCOPY  NUMBER,
	  p_amount_outstanding     OUT NOCOPY  NUMBER,
	  p_amount_ordered	   OUT NOCOPY  NUMBER,
	  p_amt_already_billed	   OUT NOCOPY  NUMBER,
          P_calling_sequence    IN             VARCHAR2) RETURN BOOLEAN IS

current_calling_sequence    VARCHAR2(2000);
debug_info           VARCHAR2(500);
l_matching_basis	    PO_LINE_LOCATIONS_ALL.MATCHING_BASIS%TYPE;

BEGIN
  -- Update the calling sequence

  current_calling_sequence :=
         'AP_Import_Utilities_Pkg.get_overbill_for_shipment<-'
         ||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 1
  -- Get quantity_outstanding
  --------------------------------------------------------------------------

  debug_info := '(Get Overbill for Shipment 1) Get quantity_outstanding';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  --Contract Payments: modified the SELECT clause
  SELECT   decode(pod.distribution_type,'PREPAYMENT',
                  sum(NVL(pod.quantity_ordered,0) - NVL(pod.quantity_financed,0)
                       - NVL(pod.quantity_cancelled,0)),
                  sum(NVL(pod.quantity_ordered,0) - NVL(pod.quantity_billed,0)
                       - NVL(pod.quantity_cancelled,0))
	         ),
           sum(NVL(pod.quantity_ordered,0) - NVL(pod.quantity_cancelled,0)),
           decode(pod.distribution_type,'PREPAYMENT',
                 sum(NVL(pod.quantity_financed,0)),
                 sum(NVL(pod.quantity_billed,0))
                 ),
	   decode(pod.distribution_type,'PREPAYMENT',
                  sum(NVL(pod.amount_ordered,0) - NVL(pod.amount_financed,0)
                       - NVL(pod.amount_cancelled,0)),
                  sum(NVL(pod.amount_ordered,0) - NVL(pod.amount_billed,0)
                       - NVL(pod.amount_cancelled,0))
                 ),
           sum(NVL(pod.amount_ordered,0) - NVL(pod.amount_cancelled,0)),
           decode(pod.distribution_type,'PREPAYMENT',
                 sum(NVL(pod.amount_financed,0)),
                 sum(NVL(pod.amount_billed,0))
                 ),
	   pll.matching_basis
    INTO   p_quantity_outstanding,
           p_quantity_ordered,
           p_qty_already_billed,
	   p_amount_outstanding,
	   p_amount_ordered,
	   p_amt_already_billed,
	   l_matching_basis
    FROM   po_distributions_ap_v pod,
	   po_line_locations pll
   WHERE   pod.line_location_id = p_po_shipment_id
   AND     pll.line_location_id = pod.line_location_id
   GROUP BY  pod.distribution_type,pll.matching_basis ;


  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,'------------------>
            p_quantity_outstanding = '||to_char(p_quantity_outstanding)
            ||' p_quantity_ordered = '||to_char(p_quantity_ordered)
            ||' p_qty_already_billed = '||to_char(p_qty_already_billed)
	    ||' p_amount_outstanding = '||to_char(p_amount_outstanding)
            ||' p_amount_ordered = '||to_char(p_amount_ordered)
            ||' p_amt_already_billed = '||to_char(p_amt_already_billed)
         );
  END IF;

  ---------------------------------------------------------------------------
  -- Decide if overbilled
  -- Bug 562898
  -- Overbill flag should be Y is l_quantity_outstanding =0
  ---------------------------------------------------------------------------

  IF (l_matching_basis = 'QUANTITY') THEN
  IF ((p_quantity_outstanding - p_quantity_invoiced) <= 0) THEN
    P_overbilled := 'Y';
  ELSE
    P_overbilled := 'N';
  END IF;
  ELSIF (l_matching_basis = 'AMOUNT') THEN
     IF ((p_amount_outstanding - p_amount_invoiced) <= 0) THEN
        P_overbilled := 'Y';
     ELSE
        P_overbilled := 'N';
     END IF;
  END IF;

  RETURN(TRUE);

EXCEPTION

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END get_overbill_for_shipment;


/*======================================================================
 Function: Get_Batch_ID
   This function returns a batch_id and batch_type given a batch_name.
   If the batch already exists the batch_type returned is 'OLD BATCH',
   else the batch_type returned is 'NEW BATCH'.  If this is a NEW
   BATCH the batch_id is obtained from the appropriate sequence, else
   it is read off the AP_BATCHES table.
========================================================================*/
FUNCTION get_batch_id (
          p_batch_name          IN             VARCHAR2,
          P_batch_id               OUT NOCOPY  NUMBER,
          p_batch_type             OUT NOCOPY  VARCHAR2,
          P_calling_sequence    IN             VARCHAR2)
RETURN BOOLEAN
IS
  l_batch_id      NUMBER;
  current_calling_sequence    VARCHAR2(2000);
  debug_info               VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence :=
    'AP_Import_Utilities_Pkg.get_batch_id<-'||P_calling_sequence;

  ------------------------------------------------------------------
  -- Find the old batch_id if it's existing batch, or use sequence
  -- find the next available batch_id
  ------------------------------------------------------------------
  debug_info := 'Check batch_name existance';

  BEGIN
   debug_info := '(Get_batch_id 1) Get old batch id';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

   SELECT  'OLD BATCH',
            batch_id
     INTO   p_batch_type,
            l_batch_id
     FROM   ap_batches_all
    WHERE   batch_name = P_batch_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_batch_type := 'NEW BATCH';
  END;

  IF (p_batch_type = 'NEW BATCH') THEN

    ---------------------------------------------
    -- Get New batch_id and Batch_date
    ---------------------------------------------

    debug_info := '(Get_batch_id 2) Get New batch_id';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    SELECT  ap_batches_s.nextval
    INTO    l_batch_id
    FROM    sys.dual;

  END IF;

  p_batch_id := l_batch_id;

  RETURN(TRUE);

EXCEPTION
 WHEN OTHERS then
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

   IF (SQLCODE < 0) THEN
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
       Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
     END IF;
   END IF;

   RETURN (FALSE);

END get_batch_id;

FUNCTION get_auto_batch_name(
          p_source                      IN            VARCHAR2,
          p_batch_name                     OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  l_batch_num                     NUMBER;
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_Import_Utilities_Pkg.get_auto_batch_name<-' ||p_calling_sequence;

  debug_info := '(Get_auto_batch_name 1) automatically create batch name';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  SELECT  ap_batches_s2.nextval
  INTO    l_batch_num
  FROM    sys.dual;

  p_batch_name := p_source || ':' || to_char(l_batch_num);
  RETURN(TRUE);

EXCEPTION

  WHEN OTHERS THEN
    RETURN(FALSE);

END get_auto_batch_name;


/*======================================================================
 Function: Get_Info
   This function returns values of system options, profile options and
   financials options once an OU has been detected.
========================================================================*/
FUNCTION get_info (
          p_org_id                         IN         NUMBER,
          p_set_of_books_id                OUT NOCOPY NUMBER,
          p_multi_currency_flag            OUT NOCOPY VARCHAR2,
          p_make_rate_mandatory_flag       OUT NOCOPY VARCHAR2,
          p_default_exchange_rate_type     OUT NOCOPY VARCHAR2,
          p_base_currency_code             OUT NOCOPY VARCHAR2,
          p_batch_control_flag             OUT NOCOPY VARCHAR2,
          p_invoice_currency_code          OUT NOCOPY VARCHAR2,
          p_base_min_acct_unit             OUT NOCOPY NUMBER,
          p_base_precision                 OUT NOCOPY NUMBER,
          p_sequence_numbering             OUT NOCOPY VARCHAR2,
          p_awt_include_tax_amt            OUT NOCOPY VARCHAR2,
          p_gl_date                     IN OUT NOCOPY DATE,
       -- p_ussgl_transcation_code         OUT NOCOPY VARCHAR2, - Bug 4277744
          p_trnasfer_desc_flex_flag        OUT NOCOPY VARCHAR2,
          p_gl_date_from_receipt_flag      OUT NOCOPY VARCHAR2,
          p_purch_encumbrance_flag         OUT NOCOPY VARCHAR2,
	  p_retainage_ccid		   OUT NOCOPY NUMBER,
          P_pa_installed                   OUT NOCOPY VARCHAR2,
          p_chart_of_accounts_id           OUT NOCOPY NUMBER,
          p_inv_doc_cat_override           OUT NOCOPY VARCHAR2,
          p_calc_user_xrate                OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2,
          p_approval_workflow_flag         OUT NOCOPY VARCHAR2,
          p_freight_code_combination_id    OUT NOCOPY NUMBER,
	  p_allow_interest_invoices	   OUT NOCOPY VARCHAR2, --bug 4113223
	  p_add_days_settlement_date       OUT NOCOPY NUMBER,   --bug 4930111
          p_disc_is_inv_less_tax_flag      OUT NOCOPY VARCHAR2, --bug 4931755
          p_source                         IN         VARCHAR2, --bug 5382889. LE TimeZone
          p_invoice_date                   IN         DATE,     -- bug 5382889. LE TimeZone
          p_goods_received_date            IN         DATE,     -- bug 5382889. LE TimeZone
          p_asset_book_type                OUT NOCOPY VARCHAR2  -- Bug 5448579
        )
RETURN BOOLEAN
IS

  l_status                   VARCHAR2(10);
  l_industry                 VARCHAR2(10);
  get_info_failure           EXCEPTION;
  current_calling_sequence   VARCHAR2(2000);
  debug_info                 VARCHAR2(500);
  l_ext_precision            NUMBER(2);



  l_inv_gl_date                DATE;   --Bug 5382889. LE Timezone
  l_rts_txn_le_date            DATE;   --Bug 5382889. LE Timezone
  l_inv_le_date                DATE;   --Bug 5382889. LE Timezone
  l_sys_le_date                DATE;   --Bug 5382889. LE Timezone

  l_asset_book_count           NUMBER;

BEGIN
  -- Update the calling sequence

  current_calling_sequence :=
    'AP_Import_Utilities_Pkg.Get_info<-'||P_calling_sequence;

  debug_info := '(Get_info 1) Read from ap_system_parameters';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  SELECT
          set_of_books_id,
          multi_currency_flag,
          make_rate_mandatory_flag,
          default_exchange_rate_type,
          base_currency_code,
          aps.invoice_currency_code,
          awt_include_tax_amt,
       -- ussgl_transaction_code, - Bug 4277744
          transfer_desc_flex_flag,
          gl_date_from_receipt_flag,
          inv_doc_category_override,
          NVL(calc_user_xrate, 'N'),
          NVL(approval_workflow_flag,'N'),
          freight_code_combination_id ,
	  /*we need to get the value of allow_interest_invoices
	  from system_parameters versus product setup, since the value
	  in the product setup is only for defaulting into suppliers,
	  whereas the value in asp decides whether we create INT invoices
	  or not*/
	  asp.auto_calculate_interest_flag,
	  --bugfix:4930111
	  asp.add_days_settlement_date,
          NVL(asp.disc_is_inv_less_tax_flag, 'N') /* bug 4931755 */
     INTO p_set_of_books_id,
          p_multi_currency_flag,
          p_make_rate_mandatory_flag,
          p_default_exchange_rate_type,
          p_base_currency_code,
          p_invoice_currency_code,
          p_awt_include_tax_amt,
       -- p_ussgl_transcation_code, - Bug 4277744
          p_trnasfer_desc_flex_flag,
          p_gl_date_from_receipt_flag,
          p_inv_doc_cat_override,
          p_calc_user_xrate,
          p_approval_workflow_flag,
          p_freight_code_combination_id,
	  p_allow_interest_invoices,
	  p_add_days_settlement_date,
          p_disc_is_inv_less_tax_flag
    FROM  ap_system_parameters_all asp,
          ap_product_setup aps
   WHERE  asp.org_id = p_org_id;

  debug_info := '(Get_info 2) Get Batch Control Profile Option';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  BEGIN
    FND_PROFILE.GET('AP_USE_INV_BATCH_CONTROLS',p_batch_control_flag);

  EXCEPTION
    WHEN OTHERS THEN
    p_batch_control_flag := 'N';
  END ;

  debug_info := '(Get_info 3) Get encumbrance option';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  SELECT  purch_encumbrance_flag, retainage_code_combination_id
    INTO  p_purch_encumbrance_flag, p_retainage_ccid
    FROM  financials_system_params_all
   WHERE  org_id = p_org_id;

  debug_info := '(Get_info 4) Get minimum_accountable_unit';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  FND_CURRENCY.GET_INFO(
          p_base_currency_code  ,
          p_base_precision ,
          l_ext_precision ,
          p_base_min_acct_unit);

  debug_info := '(Get_info 5) Get p_sequence_numbering';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  p_sequence_numbering := FND_PROFILE.VALUE('UNIQUE:SEQ_NUMBERS');


  debug_info := '(Get_info 6) Get gl_date based on report parameters';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  -- Bug 5645581. Gl_date will calculated at the Import_Invoices
  -- Procedure in the Main Package
  /*IF p_source = 'ERS' THEN     -- bug 5382889, LE TimeZone

    debug_info := 'Determine gl_date from ERS invoice';

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    l_rts_txn_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => nvl(p_goods_received_date, p_invoice_date)
                         ,p_ou_id        => p_org_id);

    l_inv_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => p_invoice_date
                         ,p_ou_id        => p_org_id);

    l_sys_le_date :=  INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Ou(
                          p_trxn_date    => sysdate
                         ,p_ou_id        => p_org_id);


      -- The gl_date id determined from the flag gl_date_from_receipt_flag
      -- If the flag = 'I' -- take Invoice_date
      --             = 'S' -- take System date
      --             = 'N' -- take nvl(receipt_date, invoice_date)
      --             = 'Y' -- take nvl(receipt_date, sysdate)
      -- Note here that the Invoice date is no longer the same as the receipt_date,
      -- i.e. the RETURN tranasaction_date , so case I and N are no longer the same

    debug_info := 'Determine invoice gl_date from LE Timezone API ';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    If (p_gl_date_from_receipt_flag = 'I') Then
        l_inv_gl_date := l_inv_le_date;
    Elsif (p_gl_date_from_receipt_flag = 'N') Then
        l_inv_gl_date := nvl(l_rts_txn_le_date, l_inv_le_date);
    Elsif (p_gl_date_from_receipt_flag = 'S') Then
        l_inv_gl_date := l_sys_le_date;
    Elsif (p_gl_date_from_receipt_flag = 'Y') then
        l_inv_gl_date := nvl(l_rts_txn_le_date, l_sys_le_date);
    End if;

    p_gl_date  := l_inv_gl_date;

  ELSE
    IF (p_gl_date IS NULL) THEN
      IF (p_gl_date_from_receipt_flag IN ('S','Y')) THEN
        debug_info := '(Get_info 6a) GL Date is Sysdate';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        p_gl_date := sysdate;

      ELSE
        debug_info := '(Get_info 6b) GL Date should be Invoice Date';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;
      END IF;
    END IF;
  END IF;

  p_gl_date := trunc(p_gl_date); */
  debug_info := '(Get_info 7) Check if PA is installed';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  IF (FND_INSTALLATION.GET(275, 275, l_status, l_industry)) THEN
    IF (l_status <> 'I') THEN
      P_PA_INSTALLED := 'N';
    ELSE
      P_PA_INSTALLED := 'Y';
      AP_IMPORT_INVOICES_PKG.g_pa_allows_overrides :=
         NVL(FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES'), 'N');
    END IF;
  ELSE
    RAISE get_info_failure;
  END IF;

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------> l_status = '|| l_status
        ||' l_industry  = '   ||l_industry
        ||' p_pa_installed = '||p_pa_installed);
  END IF;

  debug_info := '(Get_info 8) Get chart_of_accounts_id from p_set_of_books_id';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  SELECT chart_of_accounts_id
    INTO p_chart_of_accounts_id
    FROM gl_sets_of_books
   WHERE set_of_books_id = p_set_of_books_id;

  -- Bug 5448579

  /* debug_info := '(Get_info 9) Get Asset Book Type Code';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  BEGIN
    SELECT count(*)
    INTO l_asset_book_count
    FROM fa_book_controls bc
    WHERE bc.book_class = 'CORPORATE'
    AND bc.set_of_books_id = p_set_of_books_id
    AND bc.date_ineffective IS NULL;

    IF (l_asset_book_count = 1) THEN
      SELECT bc.book_type_code
      INTO p_asset_book_type
      FROM fa_book_controls bc
      WHERE  bc.book_class = 'CORPORATE'   --bug7040148
      AND bc.set_of_books_id = p_set_of_books_id
      AND bc.date_ineffective IS NULL;

    ELSE
      p_asset_book_type := NULL;
    END IF;

  EXCEPTION
      -- No need to error handle if FA information not available.
      WHEN no_data_found THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
  END; */ --bug 7584682

  p_asset_book_type := NULL; --bug 7584682

  debug_info := '(Get_info 9) Get system tolerances';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- For EDI transactions, if the price and qty tolerance is set to null
  -- we assume this to be zero. This is implemented as per discussion with
  -- Subir.

  --Bug 4051803 commented out the below code and moved it to
  --function get_tolerance_info, which will be called to for
  --get tolerance info specific to site as oppose to org.
 /*
 SELECT
  DECODE(price_tolerance, NULL,1,(1 + (price_tolerance/100))),
  DECODE(price_tolerance, NULL,1,(1 - (price_tolerance/100))),
  DECODE(quantity_tolerance, NULL,1, (1 + (quantity_tolerance/100))),
  DECODE(qty_received_tolerance, NULL,NULL, (1 +(qty_received_tolerance/100))),
  max_qty_ord_tolerance,
  max_qty_rec_tolerance,
  ship_amt_tolerance,
  rate_amt_tolerance,
  total_amt_tolerance
 INTO
  p_positive_price_tolerance,
  p_negative_price_tolerance,
  p_qty_tolerance,
  p_qty_rec_tolerance,
  p_max_qty_ord_tolerance,
  p_max_qty_rec_tolerance,
  p_ship_amt_tolerance,
  p_rate_amt_tolerance,
  p_total_amt_tolerance
 FROM  ap_tolerances_all
where  org_id = p_org_id; */

  RETURN (TRUE);


EXCEPTION
 WHEN OTHERS then
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

   IF (SQLCODE < 0) then
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
       Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
     END IF;
   END IF;

   RETURN (FALSE);

END get_info;


-- Bug 4051803
--===================================================================
-- Function: get_tolerance_info
-- Get tolerance info. from po_vendor_sites_all
-- based on vendor_site_id
--===================================================================
FUNCTION get_tolerance_info(
	p_vendor_site_id		IN 		NUMBER,
        p_positive_price_tolerance      OUT NOCOPY      NUMBER,
        p_negative_price_tolerance      OUT NOCOPY      NUMBER,
        p_qty_tolerance                 OUT NOCOPY      NUMBER,
        p_qty_rec_tolerance             OUT NOCOPY      NUMBER,
        p_max_qty_ord_tolerance         OUT NOCOPY      NUMBER,
        p_max_qty_rec_tolerance         OUT NOCOPY      NUMBER,
	p_amt_tolerance		        OUT NOCOPY      NUMBER,
	p_amt_rec_tolerance		OUT NOCOPY	NUMBER,
	p_max_amt_ord_tolerance         OUT NOCOPY      NUMBER,
	p_max_amt_rec_tolerance         OUT NOCOPY      NUMBER,
        p_goods_ship_amt_tolerance      OUT NOCOPY      NUMBER,
        p_goods_rate_amt_tolerance      OUT NOCOPY      NUMBER,
        p_goods_total_amt_tolerance     OUT NOCOPY      NUMBER,
	p_services_ship_amt_tolerance   OUT NOCOPY      NUMBER,
        p_services_rate_amt_tolerance   OUT NOCOPY      NUMBER,
        p_services_total_amt_tolerance  OUT NOCOPY      NUMBER,
        p_calling_sequence		IN		VARCHAR2)
RETURN BOOLEAN IS
  debug_info                      VARCHAR2(500);
  l_price_tolerance		  ap_tolerance_templates.price_tolerance%TYPE;
BEGIN

  debug_info := '(Get_tolerance_info 1) Get tolerance info...';
  If AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' then
   Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  End if;

  -- For EDI transactions, if the price and qty tolerance is set to null
  -- we assume this to be zero. This is implemented as per discussion with
  -- Subir.

  BEGIN

      select price_tolerance,
             decode(price_tolerance, NULL,1,(1 + (price_tolerance/100))),
             decode(price_tolerance, NULL,1,(1 - (price_tolerance/100))),
            -- decode(quantity_tolerance, NULL,1, (1 + (quantity_tolerance/100))), Commented and added for bug 9381715
             decode(quantity_tolerance, NULL,NULL, (1 + (quantity_tolerance/100))),
	     decode(qty_received_tolerance, NULL,NULL, (1 +(qty_received_tolerance/100))),
             max_qty_ord_tolerance,
             max_qty_rec_tolerance,
             ship_amt_tolerance,
             rate_amt_tolerance,
             total_amt_tolerance
      into
             l_price_tolerance,
             p_positive_price_tolerance,
             p_negative_price_tolerance,
             p_qty_tolerance,
             p_qty_rec_tolerance,
             p_max_qty_ord_tolerance,
             p_max_qty_rec_tolerance,
             p_goods_ship_amt_tolerance,
             p_goods_rate_amt_tolerance,
             p_goods_total_amt_tolerance
      from   ap_tolerance_templates att,
             po_vendor_sites_all pvs
      where  pvs.vendor_site_id = p_vendor_site_id
      and    pvs.tolerance_id = att.tolerance_id;

  EXCEPTION
     when no_data_found then
       debug_info := '(get_tolerance_info 1) NO_DATA_FOUND exception';
       If AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' then
         Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
       End if;
  END;


  BEGIN
      select decode(quantity_tolerance, NULL,1, (1 + (quantity_tolerance/100))),
             decode(qty_received_tolerance, NULL,NULL, (1 +(qty_received_tolerance/100))),
	     max_qty_ord_tolerance,
	     max_qty_rec_tolerance,
             ship_amt_tolerance,
             rate_amt_tolerance,
             total_amt_tolerance
      into
             p_amt_tolerance,
             p_amt_rec_tolerance,
	     p_max_amt_ord_tolerance,
	     p_max_amt_rec_tolerance,
             p_services_ship_amt_tolerance,
             p_services_rate_amt_tolerance,
             p_services_total_amt_tolerance
      from   ap_tolerance_templates att,
             po_vendor_sites_all pvs
      where  pvs.vendor_site_id = p_vendor_site_id
      and    pvs.services_tolerance_id = att.tolerance_id;


  EXCEPTION WHEN NO_DATA_FOUND THEN

       debug_info := '(get_tolerance_info 2) NO_DATA_FOUND exception';
       If AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' then
         Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
       End if;

  END;

  If AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'  then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,'------------------> p_vendor_site_id = '||
                to_char(p_vendor_site_id)
                ||' l_price_tolerance  = '||to_char(l_price_tolerance)
                ||' l_positive_price_tolerance  = '||to_char(p_positive_price_tolerance)
                ||' l_negative_price_tolerance  = '||to_char(p_negative_price_tolerance)
                ||' l_qty_tolerance  = '||to_char(p_qty_tolerance)
                ||' l_qty_received_tolerance  = '||to_char(p_qty_rec_tolerance)
                ||' l_max_qty_ord_tolerance  = '||to_char(p_max_qty_ord_tolerance)
                ||' l_max_qty_rec_tolerance  = '||to_char(p_max_qty_rec_tolerance)
		||' l_amt_tolerance  = '||to_char(p_amt_tolerance)
                ||' l_amt_received_tolerance  = '||to_char(p_amt_rec_tolerance)
		||' l_max_amt_ord_tolerance  = '||to_char(p_max_amt_ord_tolerance)
	        ||' l_max_amt_rec_tolerance  = '||to_char(p_max_amt_rec_tolerance)
                ||' l_goods_ship_amt_tolerance  = '||to_char(p_goods_ship_amt_tolerance)
                ||' l_goods_rate_amttolerance  = '||to_char(p_goods_rate_amt_tolerance)
                ||' l_goods_total_amt_tolerance  = '||to_char(p_goods_total_amt_tolerance)
		||' l_services_ship_amt_tolerance  = '||to_char(p_services_ship_amt_tolerance)
                ||' l_services_rate_amttolerance  = '||to_char(p_services_rate_amt_tolerance)
                ||' l_services_total_amt_tolerance  = '||to_char(p_services_total_amt_tolerance));
  end if;

  RETURN (TRUE);

EXCEPTION

 WHEN OTHERS then
    If AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info); End if;

    IF (SQLCODE < 0) then
      If AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y'
      then Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM); End if;
    END IF;

    RETURN (FALSE);

END get_tolerance_info;


/*======================================================================
 Function: find_vendor_primary_paysite
  This function is called when import program is  trying to default a
  vendor site in case user did not give input of vendor site information.
   1. Return primary site id if there is one
   2. Return the only paysite if there is no primary paysite
   3. Return null if there are multiple paysite but no primary paysite
   4. Return null if there is no paysite
========================================================================*/
FUNCTION find_vendor_primary_paysite(
          p_vendor_id                   IN            NUMBER,
          p_vendor_primary_paysite_id      OUT NOCOPY NUMBER,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS

  CURSOR primary_pay_site_cur IS
  SELECT vendor_site_id
    FROM po_vendor_sites PVS
   WHERE vendor_id = p_vendor_id
     AND pay_site_flag = 'Y'
     AND primary_pay_site_flag = 'Y'
     AND NVL(trunc(PVS.INACTIVE_DATE),AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
         > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

  CURSOR pay_site_cur IS
  SELECT vendor_site_id
    FROM po_vendor_sites PVS
   WHERE vendor_id = p_vendor_id
    AND pay_site_flag = 'Y'
    AND NVL(trunc(PVS.INACTIVE_DATE),AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
         > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

  l_vendor_site_id           PO_VENDOR_SITES.VENDOR_SITE_ID%TYPE;
  l_paysite_count            NUMBER;
  current_calling_sequence   VARCHAR2(2000);
  debug_info                 VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence :=
         'AP_IMPORT_UTILITIES_PKG.find_vendor_primary_paysite<-'
         ||P_calling_sequence;

  debug_info := '(Find vendor primary paysite 1) Get the primary paysite';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  OPEN primary_pay_site_cur;
  FETCH primary_pay_site_cur INTO l_vendor_site_id;
  CLOSE primary_pay_site_cur;

  IF ( l_vendor_site_id is null ) THEN

    SELECT count(*)
      INTO l_paysite_count
      FROM po_vendor_sites PVS
     WHERE vendor_id = p_vendor_id
      AND pay_site_flag = 'Y'
      AND NVL(trunc(PVS.INACTIVE_DATE),AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
          > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

    IF ( l_paysite_count = 1 ) THEN
      OPEN pay_site_cur;
      FETCH pay_site_cur INTO l_vendor_site_id;
      CLOSE pay_site_cur;
      p_vendor_primary_paysite_id := l_vendor_site_id;
    ELSE
      p_vendor_primary_paysite_id := null;
    END IF;
  ELSE
    p_vendor_primary_paysite_id := l_vendor_site_id;
  END IF;

  RETURN(TRUE);

EXCEPTION

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END find_vendor_primary_paysite;


FUNCTION get_employee_id(
          p_invoice_id                  IN            NUMBER,
          p_vendor_id                   IN            NUMBER,
          p_employee_id                    OUT NOCOPY NUMBER,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_current_invoice_status         OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  get_employee_failure    EXCEPTION;
  l_current_invoice_status  VARCHAR2(1) := 'Y';
  l_employee_id      NUMBER;
  current_calling_sequence    VARCHAR2(2000);
  debug_info               VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'get_employee_id<-'||P_calling_sequence;

  BEGIN
    debug_info := '(Get_employee_id 1) Get employee id from po_vendors';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    SELECT  employee_id
      INTO  l_employee_id
      FROM  po_vendors
     WHERE  vendor_id = p_vendor_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

    -- Potentially this should never happen
    -- as vendor is already validated at the invoice level

    debug_info := '(Get_employee_id 2) Vendor Id is invalid';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Reject Here for Invalid Vendor

    debug_info := '(Get emloyee_id 3) Check for invalid Supplier.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (insert_rejections(AP_IMPORT_INVOICES_PKG.g_invoices_table,
          p_invoice_id,
          'INVALID SUPPLIER',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE get_employee_failure;
    END IF;
    l_current_invoice_status := 'N';
  END;

  IF (l_employee_id IS NULL) THEN

    -- We shall not reject if employee id is Null

    debug_info := '(Get_employee_id 3) Employee_id id Null';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

  END IF;
  --
  p_employee_id            :=l_employee_id;
  p_current_invoice_status := l_current_invoice_status;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END get_employee_id;


FUNCTION get_next_dist_line_num(
          p_invoice_id         IN            NUMBER,
          p_line_num           IN            NUMBER,
          p_next_dist_num         OUT NOCOPY NUMBER,
          P_calling_sequence   IN            VARCHAR2)
RETURN BOOLEAN
IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info               VARCHAR2(500);

BEGIN

  -- Update the calling sequence

  current_calling_sequence := 'get_next_dist_line_num<-'||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 1
  -- Get the next available distribution line number given the invoice
  -- and line number
  --------------------------------------------------------------------------

  debug_info := '(Get Next Dist Line Num 1) Get the next available '||
                'distribution line number';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
     Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

/* For bug 3929697
   * Before executing the select for getting the value
   * of distribution line number check whether it is already
   * fetched. If so, increment distribution line number
   * else execute the select to get the corresponding value
   * */

  If (lg_invoice_id = p_invoice_id and lg_dist_line_num is not null) Then
    p_next_dist_num := lg_dist_line_num + 1;
  Else
     SELECT max(distribution_line_number)
       INTO p_next_dist_num
       FROM ap_invoice_distributions
      WHERE invoice_id = p_invoice_id
     AND invoice_line_number = p_line_num;
    p_next_dist_num := nvl(p_next_dist_num,0) + 1;
  End if;
  lg_invoice_id := p_invoice_id;
  lg_dist_line_num := p_next_dist_num;

  RETURN(TRUE);

RETURN NULL; EXCEPTION

  WHEN NO_DATA_FOUND THEN
    p_next_dist_num := 1;
    /* For bug 3929697
       Initialized the global variables */
    lg_invoice_id := p_invoice_id;
    lg_dist_line_num := p_next_dist_num;
    RETURN(TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END get_next_dist_line_num;


FUNCTION get_overbill_for_po_line(
          p_po_line_id                  IN            NUMBER,
          p_quantity_invoiced           IN            NUMBER,
	  p_amount_invoiced		IN	      NUMBER,
          p_overbilled                     OUT NOCOPY VARCHAR2,
          p_outstanding                 OUT NOCOPY    NUMBER,
          p_ordered                     OUT NOCOPY    NUMBER,
          p_already_billed              OUT NOCOPY    NUMBER,
	  p_po_line_matching_basis	OUT NOCOPY    VARCHAR2,
          P_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN

IS
  current_calling_sequence   VARCHAR2(2000);
  debug_info                 VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'get_overbill_for_po_line<-'||P_calling_sequence;

  ----------------------------------------------------------------------------
  -- Step 1
  -- Get quantity_outstanding
  ----------------------------------------------------------------------------
  debug_info := '(Get Overbill for PO Line 1) Get quantity_outstanding';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  --Contract Payments: Modified the SELECT clause
  /*-----------------------------------------------------------------------------------------+
   --For the case of complex works, following scenarios are possible:
  1.Matching Basis at PO Line = 'AMOUNT' and
     shipments could have matching_basis of 'QUANTITY'/'AMOUNT'. And within that
     shipment_type could be 'PREPAYMENT' or 'STANDARD'. For 'PREPAYMENT'
     we need to go off of financed columns and
     for 'STANDARD' we need to go off of Billed columns.
  2.Matching Basis at PO Line = 'QUANTITY'
    and then shipments can have the matching basis of only 'QUANTITY'. And within that
     shipment_type could be 'PREPAYMENT' or 'STANDARD'. For 'PREPAYMENT'
     we need to go off of financed columns and
     for 'STANDARD' we need to go off of Billed columns.
  +------------------------------------------------------------------------------------------*/

  SELECT
  	 DECODE(pl.matching_basis, 'QUANTITY',
     	          DECODE(pll.shipment_type,'PREPAYMENT',
                         sum(NVL(pll.quantity,0) - NVL(pll.quantity_financed,0) -
                             NVL(pll.quantity_cancelled,0)),
                         sum(NVL(pll.quantity,0) - NVL(pll.quantity_billed,0) -
                             NVL(pll.quantity_cancelled,0))
		 ),
	          'AMOUNT',
		   SUM(DECODE(pll.matching_basis,'QUANTITY',
			      (DECODE(pll.shipment_type,'PREPAYMENT',
                                      NVL(pll.quantity,0) - NVL(pll.quantity_financed,0) -
                                          NVL(pll.quantity_cancelled,0),
                                      NVL(pll.quantity,0) - NVL(pll.quantity_billed,0) -
                                          NVL(pll.quantity_cancelled,0)
                                     )
                              )*pll.price_override,
			      'AMOUNT',
			      DECODE(pll.shipment_type,'PREPAYMENT',
                         	     NVL(pll.amount,0) - NVL(pll.amount_financed,0) -
                             		 NVL(pll.amount_cancelled,0),
                         	     NVL(pll.amount,0) - NVL(pll.amount_billed,0) -
                                         NVL(pll.amount_cancelled,0)
	                            )
                             )
                      )
                 ),
           DECODE(pl.matching_basis,
		  'QUANTITY',
	    	  SUM(NVL(pll.quantity,0) - NVL(pll.quantity_cancelled,0)),
		  'AMOUNT',
		  SUM(DECODE(pll.matching_basis,
			     'QUANTITY',
			     (NVL(pll.quantity,0) - NVL(pll.quantity_cancelled,0))*pll.price_override,
			     'AMOUNT',
			      NVL(pll.amount,0) - NVL(pll.amount_cancelled,0)
			    )
		     )
                 ),
          DECODE(pl.matching_basis,
		 'QUANTITY',
  	         DECODE(shipment_type,'PREPAYMENT',
                        sum(NVL(quantity_financed,0)),sum(NVL(quantity_billed,0))
                       ),
		 'AMOUNT',
		 SUM(DECODE(pll.matching_basis,
			    'QUANTITY',
           		    DECODE(shipment_type,'PREPAYMENT',
                        	   NVL(quantity_financed,0),NVL(quantity_billed,0)
                                   )*pll.price_override,
			    'AMOUNT',
			    DECODE(pll.shipment_type,'PREPAYMENT',
                          	  NVL(pll.amount_financed,0),NVL(pll.amount_billed,0)
  		                  )
			   )
		    )
		 ),
	   pl.matching_basis
    INTO   p_outstanding,
           p_ordered,
           p_already_billed,
	   p_po_line_matching_basis
    FROM   po_line_locations pll,
	   po_lines pl
   WHERE   pll.po_line_id = p_po_line_id
   AND     pl.po_line_id = pll.po_line_id
   -- bug fix 6959362 starts
   group by pl.matching_basis, pll.shipment_type;
   -- bug fix 6959362 ends

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
     '------------------> p_outstanding = '
        ||to_char(p_outstanding)
        ||' p_ordered = '||to_char(p_ordered)
  ||' p_already_billed = '||to_char(p_already_billed));
  END IF;

  ----------------------------------------------------
  -- Decide if overbilled
  ----------------------------------------------------
  -- Bug 562898
  -- Overbill flag should be Y is l_quantity_outstanding =0
  IF (p_po_line_matching_basis = 'QUANTITY') THEN
     IF ((p_outstanding - p_quantity_invoiced) <= 0) THEN
    P_overbilled := 'Y';
  ELSE
    P_overbilled := 'N';
  END IF;
  ELSIF (p_po_line_matching_basis = 'AMOUNT') THEN
     IF ((p_outstanding - p_amount_invoiced) <= 0) THEN
        P_overbilled := 'Y';
     ELSE
        P_overbilled := 'N';
     END IF;
  END IF;

  RETURN(TRUE);

  EXCEPTION
    WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END get_overbill_for_po_line;


FUNCTION pa_flexbuild (
          p_invoice_rec                 IN
             AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_invoice_lines_rec           IN OUT NOCOPY
             AP_IMPORT_INVOICES_PKG.r_line_info_rec,
          p_accounting_date             IN            DATE,
          p_pa_installed                IN            VARCHAR2,
          p_employee_id                 IN            NUMBER,
          p_base_currency_code          IN            VARCHAR2,
          p_chart_of_accounts_id        IN            NUMBER,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_pa_default_dist_ccid           OUT NOCOPY NUMBER,
          p_pa_concatenated_segments       OUT NOCOPY VARCHAR2,
          p_current_invoice_status         OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  pa_flexbuild_failure         EXCEPTION;
  l_current_invoice_status     VARCHAR2(1) := 'Y';
  user_id                      NUMBER;
  procedure_billable_flag      VARCHAR2(60) := '';
  l_msg_application            VARCHAR2(25);
  l_msg_type                   VARCHAR2(25);
  l_msg_token1                 VARCHAR2(30);
  l_msg_token2                 VARCHAR2(30);
  l_msg_token3                 VARCHAR2(30);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(500);
  l_concat_ids                 VARCHAR2(200);
  -- CHANGES FOR BUG - 3657665 ** STARTS **
  --l_errmsg                     VARCHAR2(200);
    l_errmsg                     VARCHAR2(2000);
  -- CHANGES FOR BUG - 3657665 ** ENDS   **
  l_concat_descrs              VARCHAR2(500);
  l_concat_segs                VARCHAR2(2000);
  current_calling_sequence     VARCHAR2(2000);
  debug_info                   VARCHAR2(500);
  l_sys_link_function          VARCHAR2(2); --Bugfix:5725904

BEGIN

  -- Update the calling sequence

  current_calling_sequence :=
    'AP_IMPORT_UTILITIES_PKG.pa_flexbuild<-'||P_calling_sequence;

  ----------------------------------------------------------------------------
  -- Step 1
  ----------------------------------------------------------------------------

  debug_info := '(PA Flexbuild 1) Check for PA installation and Project Info';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF (p_pa_installed = 'Y' AND
      p_invoice_lines_rec.project_id is not null) THEN

    -- We only care to VAlidate Transactions and flexbuild if PA is
    -- installed and there is a project_id; that is, the invoice is
    -- project-related.

    debug_info := '(PA Flexbuild 1) Get User Id';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    user_id := to_number(FND_GLOBAL.USER_ID);

    debug_info := '(PA Flexbuild 1) PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    --bugfix:5725904
    If (p_invoice_rec.invoice_type_lookup_code ='EXPENSE REPORT') Then
        l_sys_link_function :='ER' ;
    Else
        l_sys_link_function :='VI' ;
    End if;

    PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
    X_PROJECT_ID         => p_invoice_lines_rec.project_id,
    X_TASK_ID            => p_invoice_lines_rec.task_id,
    X_EI_DATE            => p_invoice_lines_rec.expenditure_item_date,
    X_EXPENDITURE_TYPE   => p_invoice_lines_rec.expenditure_type,
    X_NON_LABOR_RESOURCE => NULL,
    X_PERSON_ID          => p_employee_id,
    X_QUANTITY           => '1',
    X_DENOM_CURRENCY_CODE=> p_invoice_rec.invoice_currency_code,
    X_ACCT_CURRENCY_CODE => p_base_currency_code,
    X_DENOM_RAW_COST     => p_invoice_lines_rec.amount,
    X_ACCT_RAW_COST      => p_invoice_lines_rec.base_amount,
    X_ACCT_RATE_TYPE     => p_invoice_rec.exchange_rate_type,
    X_ACCT_RATE_DATE     => p_invoice_rec.exchange_date,
    X_ACCT_EXCHANGE_RATE => p_invoice_rec.exchange_rate,
    X_TRANSFER_EI        => null,
    X_INCURRED_BY_ORG_ID => p_invoice_lines_rec.expenditure_organization_id,
    X_NL_RESOURCE_ORG_ID => null,
    X_TRANSACTION_SOURCE => l_sys_link_function,--bug2853287 --bug:5725904
    X_CALLING_MODULE     => 'APXIIMPT',
    X_VENDOR_ID          => p_invoice_rec.vendor_id,
    X_ENTERED_BY_USER_ID => user_id,
    X_ATTRIBUTE_CATEGORY => p_invoice_lines_rec.attribute_category,
    X_ATTRIBUTE1         => p_invoice_lines_rec.attribute1,
    X_ATTRIBUTE2         => p_invoice_lines_rec.attribute2,
    X_ATTRIBUTE3         => p_invoice_lines_rec.attribute3,
    X_ATTRIBUTE4         => p_invoice_lines_rec.attribute4,
    X_ATTRIBUTE5         => p_invoice_lines_rec.attribute5,
    X_ATTRIBUTE6         => p_invoice_lines_rec.attribute6,
    X_ATTRIBUTE7         => p_invoice_lines_rec.attribute7,
    X_ATTRIBUTE8         => p_invoice_lines_rec.attribute8,
    X_ATTRIBUTE9         => p_invoice_lines_rec.attribute9,
    X_ATTRIBUTE10        => p_invoice_lines_rec.attribute10,
    X_ATTRIBUTE11        => p_invoice_lines_rec.attribute11,
    X_ATTRIBUTE12        => p_invoice_lines_rec.attribute12,
    X_ATTRIBUTE13        => p_invoice_lines_rec.attribute13,
    X_ATTRIBUTE14        => p_invoice_lines_rec.attribute14,
    X_ATTRIBUTE15        => p_invoice_lines_rec.attribute15,
    X_MSG_APPLICATION    => l_msg_application,  -- IN OUT
    X_MSG_TYPE           => l_msg_type,    -- OUT NOCOPY
    X_MSG_TOKEN1         => l_msg_token1,  -- OUT NOCOPY
    X_MSG_TOKEN2         => l_msg_token2,  -- OUT NOCOPY
    X_MSG_TOKEN3         => l_msg_token3,  -- OUT NOCOPY
    X_MSG_COUNT          => l_msg_count,  -- OUT NOCOPY
    X_MSG_DATA           => l_msg_data,    -- OUT NOCOPY
    X_BILLABLE_FLAG      => procedure_billable_flag ,       -- OUT NOCOPY
    P_Document_Type      => p_invoice_rec.invoice_type_lookup_code,
    P_Document_Line_Type => p_invoice_lines_rec.line_type_lookup_code,
    P_SYS_LINK_FUNCTION  => 'VI'); -- Added for bug2714409

    IF (l_msg_data IS NOT NULL) THEN
      debug_info :=
          '(PA Flexbuild 1) PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION '||
          'Failed :Insert Rejection';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      -- Bug 5214592 . Added the debug message.
      debug_info := SUBSTR(l_msg_data,1,80);
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;


      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
          'PA FLEXBUILD FAILED',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<- '||current_calling_sequence);
            END IF;
            RAISE pa_flexbuild_failure;
      END IF;

      l_current_invoice_status := 'N';
      p_current_invoice_status := l_current_invoice_status;
      RETURN (TRUE);

    END IF; -- l_msg_data is not null

    --------------------------------------------------------------------------
    -- Step 2 - Flexbuild
    --------------------------------------------------------------------------

    debug_info := '(PA Flexbuild 2) Call for flexbuilding';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------> '
        ||' P_CHART_OF_ACCOUNTS_ID = '||to_char(P_CHART_OF_ACCOUNTS_ID)
        ||' PROJECT_ID = '||to_char(P_invoice_lines_rec.PROJECT_ID)
        ||' TASK_ID = '||to_char(P_invoice_lines_rec.TASK_ID)
        ||' award_ID = '||to_char(P_invoice_lines_rec.AWARD_ID)
        ||' EXPENDITURE_TYPE = '||P_invoice_lines_rec.EXPENDITURE_TYPE
        ||' EXPENDITURE_ORGANIZATION_ID = '
        ||to_char(P_invoice_lines_rec.EXPENDITURE_ORGANIZATION_ID)
        ||' VENDOR_ID = '||to_char(P_invoice_rec.VENDOR_ID)
        ||' procedure_billable_flag= '||procedure_billable_flag);
    END IF;

    -- Flexbuild using Workflow.

    debug_info :=
       '(PA Flexbuild 2) Call pa_acc_gen_wf_pkg.ap_inv_generate_account '||
       'for flexbuilding';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF ( NOT pa_acc_gen_wf_pkg.ap_inv_generate_account (
        p_project_id              => p_invoice_lines_rec.project_id,
        p_task_id                 => p_invoice_lines_rec.task_id,
        p_award_id                => p_invoice_lines_rec.award_id,
        --replacing p_award_id in place of X_AWARD_PSET_ID for bug#8474307
        p_expenditure_type        => p_invoice_lines_rec.expenditure_type,
        p_vendor_id               => P_invoice_rec.VENDOR_ID,
        p_expenditure_organization_id =>
                       P_invoice_lines_rec.EXPENDITURE_ORGANIZATION_ID,
        p_expenditure_item_date   =>
                       P_invoice_lines_rec.EXPENDITURE_ITEM_DATE,
        p_billable_flag           => procedure_billable_flag,
        p_chart_of_accounts_id    => P_CHART_OF_ACCOUNTS_ID,
        p_accounting_date         => P_ACCOUNTING_DATE,
        P_ATTRIBUTE_CATEGORY      => P_invoice_rec.ATTRIBUTE_CATEGORY,
        P_ATTRIBUTE1              => P_invoice_rec.ATTRIBUTE1,
        P_ATTRIBUTE2              => P_invoice_rec.ATTRIBUTE2,
        P_ATTRIBUTE3              => P_invoice_rec.ATTRIBUTE3,
        P_ATTRIBUTE4              => P_invoice_rec.ATTRIBUTE4,
        P_ATTRIBUTE5              => P_invoice_rec.ATTRIBUTE5,
        P_ATTRIBUTE6              => P_invoice_rec.ATTRIBUTE6,
        P_ATTRIBUTE7              => P_invoice_rec.ATTRIBUTE7,
        P_ATTRIBUTE8              => P_invoice_rec.ATTRIBUTE8,
        P_ATTRIBUTE9              => P_invoice_rec.ATTRIBUTE9,
        P_ATTRIBUTE10             => P_invoice_rec.ATTRIBUTE10,
        P_ATTRIBUTE11             => P_invoice_rec.ATTRIBUTE11,
        P_ATTRIBUTE12             => P_invoice_rec.ATTRIBUTE12,
        P_ATTRIBUTE13             => P_invoice_rec.ATTRIBUTE13,
        P_ATTRIBUTE14             => P_invoice_rec.ATTRIBUTE14,
        P_ATTRIBUTE15             => P_invoice_rec.ATTRIBUTE15,
        P_DIST_ATTRIBUTE_CATEGORY => p_invoice_lines_rec.attribute_category,
        P_DIST_ATTRIBUTE1         => p_invoice_lines_rec.attribute1,
        P_DIST_ATTRIBUTE2         => p_invoice_lines_rec.attribute2,
        P_DIST_ATTRIBUTE3         => p_invoice_lines_rec.attribute3,
        P_DIST_ATTRIBUTE4         => p_invoice_lines_rec.attribute4,
        P_DIST_ATTRIBUTE5         => p_invoice_lines_rec.attribute5,
        P_DIST_ATTRIBUTE6         => p_invoice_lines_rec.attribute6,
        P_DIST_ATTRIBUTE7         => p_invoice_lines_rec.attribute7,
        P_DIST_ATTRIBUTE8         => p_invoice_lines_rec.attribute8,
        P_DIST_ATTRIBUTE9         => p_invoice_lines_rec.attribute9,
        P_DIST_ATTRIBUTE10        => p_invoice_lines_rec.attribute10,
        P_DIST_ATTRIBUTE11        => p_invoice_lines_rec.attribute11,
        P_DIST_ATTRIBUTE12        => p_invoice_lines_rec.attribute12,
        P_DIST_ATTRIBUTE13        => p_invoice_lines_rec.attribute13,
        P_DIST_ATTRIBUTE14        => p_invoice_lines_rec.attribute14,
        P_DIST_ATTRIBUTE15        => p_invoice_lines_rec.attribute15,
        x_return_ccid             => P_PA_DEFAULT_DIST_CCID, --OUT
        x_concat_segs             => l_concat_segs,   -- OUT NOCOPY
        x_concat_ids              => l_concat_ids,    -- OUT NOCOPY
        x_concat_descrs           => l_concat_descrs, -- OUT NOCOPY
        x_error_message           => l_errmsg,        -- OUT NOCOPY
        p_input_ccid		=> p_invoice_lines_rec.dist_code_combination_id)) THEN  /* IN for bug#9010924 */

      -- Show error message

      -- CHANGES FOR BUG - 3657665 ** STARTS **
      -- Need to encode the message and then print the value for the same returned by PA.
         fnd_message.set_encoded(l_errmsg);
         l_errmsg := fnd_message.get;
      -- CHANGES FOR BUG - 3657665 ** ENDS   **

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------>  l_errmsg '|| l_errmsg);
      END IF;

      -- REJECT here

      debug_info :=
        '(PA Flexbuild 2) pa_acc_gen_wf_pkg.ap_inv_generate_account '||
        'Failed :Insert Rejection';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'PA FLEXBUILD FAILED',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE pa_flexbuild_failure;
      END IF;

      l_current_invoice_status   := 'N';
      P_PA_CONCATENATED_SEGMENTS := l_concat_segs;
      p_current_invoice_status   := l_current_invoice_status;

      RETURN (TRUE);

    END IF; -- If not pa generate account

    debug_info := '(PA Flexbuild 2) Return Concatenated Segments';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    P_PA_CONCATENATED_SEGMENTS := l_concat_segs;
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         '------------>  p_pa_default_dist_ccid = '
         || to_char(p_pa_default_dist_ccid)
         ||' p_pa_concatenated_segments = '||p_pa_concatenated_segments
         ||' l_concat_segs = '||l_concat_segs
         ||' l_concat_ids = '||l_concat_ids
         ||' procedure_billable_flag = '||procedure_billable_flag
         ||' l_concat_descrs = '||l_concat_descrs
         ||' l_errmsg = '||l_errmsg);
    END IF;
  END IF; -- pa installed and project id is not null

  debug_info := '(PA Flexbuild 3) Return Invoice Status';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  p_current_invoice_status := l_current_invoice_status;
  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);
END pa_flexbuild;

/*==========================================================================
 Private Function: Get Document Sequence
 Note: Method has to be automatic!
       Mode 1: Simple Manual Entry without Audit
               (Use Voucher Num, Seq Num "Not Used")
       Mode 3: Auto voucher numbering with Audit
               (Use doc_sequence_value, Seq Num 'P','A'))
       Mode 3 will override Mode 1
       Mode 2 Audited Manual Entry is not supported

 The following is a brief description of the implementation of Document
 Sequential Numbering in Invoice Open Interface (R11 only)

 The two modes for numbering can be:
   - Simple Manual Entry without Audit: Any value entered in the column
     AP_INVOICES_INTERFACE.VOUCHER_NUM will be inserted in AP_INVOICES.
     VOUCHER_NUM without validation.

   - Auto Voucher Numbering with Audit: A value will be obtained
     automatically for the record being imported and will be populated in
     AP_INVOICES. DOC_SEQUENCE_VALUE. Also audit information would be inserted
     into the audit table.

 The latter mode will always override the first one.

 The logic for the five new rejections is as follows:
   - 'Category not needed' - 'Document sequential numbering is not used'.
   - 'Invalid Category' - 'Document category specified is not valid'.
   - 'Override Disabled' - 'Document Category Override Payables option
                            is disabled'
   - 'Invalid Assignment' - 'Invalid sequence assigned to specified document
                             category'
   - 'Invalid Sequence' - 'Could not retrieve document sequence value from
                           the given sequence'

   If the profile value for the "Sequential Numbering" option is "Not Used"
   and the user specifies a document category then the invoice would be
   rejected for 'Category not needed'.

   If the profile value is "Partial" or "Always" and
   the payables option of Invoice Document Category override is
   "Yes" then the user can specify  the document category, else the
   invoice will be rejected for 'Override Disabled', if the user populates
   AP_INVOICES_INTERFACE.DOC_CATEGORY_CODE (and override is "No").

   If the profile value is "Always" and no document category is specified
   by the user, then "Standard Invoices" category will be used for
   standard invoices and "Credit Memo Invoices" category will be used
   for credits.
   We assume that a valid automatic sequence exists for such categories.

   If the payables option of Invoice Document Category override is
   "Yes" and the user specifies any of the following categories then
   the invoice is rejected for 'Invalid Category'.

                                       ('INT INV',
                                        'MIX INV',
                                        'DBM INV',
                                        'CHECK PAY',
                                        'CLEAR PAY',
                                        'EFT PAY',
                                        'FUTURE PAY',
                                        'MAN FUTURE PAY',
 ... 8995762 -- this now accepted ...   --'PREPAY INV',
                                        'REC INV',
                                        'WIRE PAY',
                                        'EXP REP INV')

   If the document category is "Standard Invoices" and the invoice amount
   is less than zero, or, the document category is "Credit Memo Invoices"
   and the invoice amount is greated than zero then the invoice will be
   rejected for 'Invalid Category'.

   The document category specified should be valid in
   FND_DOC_SEQUENCE_CATEGORIES for AP_INVOICES or AP_INVOICES_ALL
   table. If not then the invoice will be rejected for 'Invalid Category'.

   If the document category is valid then Check the status of the
   sequence assigned to this category.The sequence should be automatic
   and active. If not then reject for 'Invalid Assignment'.

   If the sequence is valid then get the next value for the assigned
   sequence. If there is an error in retrieving the nextval then reject
   for 'Invalid Sequence'. This should not happen in the ideal scenario.
============================================================================*/

FUNCTION get_doc_sequence(
          p_invoice_rec                 IN OUT
                 AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_inv_doc_cat_override        IN            VARCHAR2,
          p_set_of_books_id             IN            NUMBER,
          p_sequence_numbering          IN            VARCHAR2,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_db_sequence_value              OUT NOCOPY NUMBER,
          p_db_seq_name                    OUT NOCOPY VARCHAR2,
          p_db_sequence_id                 OUT NOCOPY NUMBER,
          p_current_invoice_status         OUT NOCOPY VARCHAR2,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  get_doc_seq_failure       EXCEPTION;
  l_name                    VARCHAR2(80);
  l_doc_category_code
      ap_invoices.doc_category_code%TYPE := p_invoice_rec.doc_category_code;
  l_application_id          NUMBER;
  l_doc_seq_ass_id          NUMBER;
  l_current_invoice_status  VARCHAR2(1) := 'Y';
  current_calling_sequence  VARCHAR2(2000);
  debug_info                VARCHAR2(500);
  l_return_code             NUMBER;

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'get_doc_sequence<-'||P_calling_sequence;

  IF ((p_sequence_numbering = 'N') AND
      (p_invoice_rec.doc_category_code IS NOT NULL)) THEN
    --------------------------------------------------------------------------
    -- Step 1
    -- p_sequence_numbering should be in ('A','P')
    -- Do not use seq num if N (Not Used)
    -- Reject if Doc category provided is provided by user in this case.
    --------------------------------------------------------------------------

    debug_info := '(Get Doc Sequence 1) Reject Seq Num is not enabled ';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print( AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            'AP_INVOICE_INTERFACE',
            p_invoice_rec.invoice_id,
            'DOC CAT NOT REQD',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print( AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<- '||current_calling_sequence);
      END IF;
      RAISE get_doc_seq_failure;
      l_current_invoice_status := 'N';
      p_current_invoice_status := l_current_invoice_status;
    END IF;
    RETURN (TRUE);

  ELSIF (p_sequence_numbering IN ('A','P')) THEN

    -------------------------------------------------------------------------
    -- Step 2
    -- Seq Numbering is enabled process doc category
    -------------------------------------------------------------------------
    IF (p_invoice_rec.doc_category_code IS NOT NULL) THEN
      debug_info := '(Get Doc Sequence 2) Seq Numbering is enabled AND doc_cat'
                    || ' is not null  process doc category  ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

      IF (p_inv_doc_cat_override = 'Y') THEN
        ---------------------------------------------------------------------
        -- Step 2.1
        --  Doc Category Override is allowed
        ---------------------------------------------------------------------
        debug_info := '(Get Doc Sequence 2.1) Doc Category Override allowed';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        -- Reject if category is a seeded one and not allowed in this case

	--Bug: 4410499, Added the support for EXP REP INV doc category type

	-- Contract Payments: Modified the below IF condition to add logic for
	-- 'Prepayment' type invoices.

        IF (  ( p_invoice_rec.doc_category_code = 'STD INV' and
	        p_invoice_rec.invoice_type_lookup_code <> 'STANDARD')
            OR
              ( p_invoice_rec.doc_category_code = 'PAY REQ INV' and
                p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST')
            OR
              ( p_invoice_rec.doc_category_code = 'CRM INV' and
                p_invoice_rec.invoice_type_lookup_code <> 'CREDIT')
            -- Bug 7299826: Added support for Debit Memos
            OR
              ( p_invoice_rec.doc_category_code = 'DBM INV' and
                p_invoice_rec.invoice_type_lookup_code <> 'DEBIT')
            OR
	      ( p_invoice_rec.doc_category_code = 'PREPAY INV' and
	        p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT')
            OR
	      ( p_invoice_rec.doc_category_code = 'EXP REP INV' and
	        p_invoice_rec.invoice_type_lookup_code <> 'EXPENSE REPORT')

            OR
              ( p_invoice_rec.doc_category_code IN (
                                  'INT INV',
                                  'MIX INV',
                                  --'DBM INV', -- bug 7299826
                                  'CHECK PAY',
                                  'CLEAR PAY',
                                  'EFT PAY',
                                  'FUTURE PAY',
                                  'MAN FUTURE PAY',
                                  --'PREPAY INV',  .. B 8995762
                                  'REC INV',
                                  'WIRE PAY'))) THEN

          debug_info := '(Get Doc Sequence 2.1)  Reject->category seeded one';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoices_table,
                   p_invoice_rec.invoice_id,
                   'INVALID DOC CATEGORY',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence) <> TRUE) THEN

            debug_info := 'insert_rejections<- '||current_calling_sequence;
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;
            RAISE get_doc_seq_failure;
          END IF;
          l_current_invoice_status := 'N';
        END IF;  -- end of seeded category check

        -----------------------------------------------------------------------
        -- Step 2.2
        -- Validate Doc Category
        -----------------------------------------------------------------------
        debug_info := '(Get Doc Sequence 2.2)  Check Doc Category ' ||
                      'exists and valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        BEGIN
          SELECT name, application_id
            INTO l_name, l_application_id
            FROM fnd_doc_sequence_categories
           WHERE code = p_invoice_rec.doc_category_code
             AND table_name IN ('AP_INVOICES','AP_INVOICES_ALL');
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            debug_info := debug_info || 'Reject->Doc cat does not exist';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoices_table,
                    p_invoice_rec.invoice_id,
                    'INVALID DOC CATEGORY',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN

              debug_info := 'insert_rejections<- '||current_calling_sequence;
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              END IF;
              RAISE get_doc_seq_failure;
            END IF;
            l_current_invoice_status := 'N';
          END;
      ELSE  -- override is no
        -----------------------------------------------------------------------
        -- Step 3
        -- override <> 'Y'
        -- Reject Override not allowed
        -----------------------------------------------------------------------

        debug_info := '(Get Doc Sequence 3) Reject->cat override not allowed';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'OVERRIDE DISALLOWED',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
          debug_info := 'insert_rejections<- '||current_calling_sequence;
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;
          RAISE get_doc_seq_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF; -- end of check l_doc_cat_override = 'Y'
    ELSIF ( (p_invoice_rec.doc_category_code IS NULL) AND
            (p_sequence_numbering in ('A','P'))) THEN  --Introduced 'P' for bug#9088303
      ---------------------------------------------------------------------
      -- Step 4
      -- Use Default Doc Category
      ---------------------------------------------------------------------
      debug_info := '(Get Doc Sequence 4) Use Default Category, Seq:Always';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

      --Contract Payments: Modified the IF condition to look at the invoice_type
      --rather than the sign of the invoice_amount in deciding which category to
      --apply, and also added the logic for 'PREPAYMENT' invoices.

      IF (p_invoice_rec.invoice_type_lookup_code = 'STANDARD') THEN
        l_doc_category_code := 'STD INV';
      ELSIF (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST') THEN
        l_doc_category_code := 'PAY REQ INV';
      ELSIF (p_invoice_rec.invoice_type_lookup_code = 'CREDIT') THEN
        l_doc_category_code := 'CRM INV';
      -- Bug 7299826
      ELSIF (p_invoice_rec.invoice_type_lookup_code = 'DEBIT') THEN
        l_doc_category_code := 'DBM INV';
      -- Bug 7299826 End
      ELSIF (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT') THEN
        l_doc_category_code := 'PREPAY INV';
      --Bug8408197
      ELSIF (p_invoice_rec.invoice_type_lookup_code = 'EXPENSE REPORT') THEN
        l_doc_category_code := 'EXP REP INV';
      --End of Bug8408197
      END IF;

      debug_info := '-----> l_doc_category_code = ' || l_doc_category_code ;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;
    END IF; -- end of check Doc_category_code is not null

    ---------------------------------------------------------------------------
    -- Step 5
    -- Get Doc Sequence Number
    ---------------------------------------------------------------------------

    IF ((l_doc_category_code IS NOT NULL) AND
        (l_current_invoice_status = 'Y')) THEN

       debug_info := '(Get Doc Sequence 5) Valid Category ->Check if valid ' ||
                     ' Sequence assigned';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
       END IF;

       BEGIN
           SELECT SEQ.DB_SEQUENCE_NAME,
                SEQ.DOC_SEQUENCE_ID,
                SA.doc_sequence_assignment_id
           INTO p_db_seq_name,
                p_db_sequence_id ,
                l_doc_seq_ass_id
           FROM FND_DOCUMENT_SEQUENCES SEQ,
                FND_DOC_SEQUENCE_ASSIGNMENTS SA
          WHERE SEQ.DOC_SEQUENCE_ID        = SA.DOC_SEQUENCE_ID
            AND SA.APPLICATION_ID          = 200
            AND SA.CATEGORY_CODE           = l_doc_category_code
            AND NVL(SA.METHOD_CODE,'A')    = 'A'
            AND NVL(SA.SET_OF_BOOKS_ID,
                    p_set_of_books_id)     = p_set_of_books_id   -- 3817492
            AND NVL(p_invoice_rec.gl_date,
                    AP_IMPORT_INVOICES_PKG.g_inv_sysdate) between
                  SA.START_DATE and
                  NVL(SA.END_DATE, TO_DATE('31/12/4712','DD/MM/YYYY'));

        -- Bug 5064959 starts. Check for inconsistent Voucher info. When a valid sequence exists ,
        -- user should not manually enter the voucher number.

       If (p_invoice_rec.voucher_num IS NOT NULL) Then

          debug_info := '(Get Doc Sequence 5) Reject: Inconsistent Voucher Info';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections( AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INCONSISTENT VOUCHER INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
             debug_info := 'insert_rejections<- '||current_calling_sequence;
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
             END IF;
             RAISE get_doc_seq_failure;

          END IF;

          l_current_invoice_status := 'N';

      End If;

        -- Bug 5064959 ends.

       EXCEPTION
         WHEN NO_DATA_FOUND Then

           --bug5854731 starts.Added the below If clause
           --Only if the Sequenctial numbering option is 'Always Used',we raise the error.
         IF(p_sequence_numbering='A') THEN  --bug5854731.Only if the Sequenctial numbering op
              debug_info := '(Get Doc Sequence 5) Reject:Invalid Sequence' ||
                            'assignment';
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
             END IF;

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                   AP_IMPORT_INVOICES_PKG.g_invoices_table,
                   p_invoice_rec.invoice_id,
                   'INVALID ASSIGNMENT',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence) <> TRUE) THEN
                   debug_info := 'insert_rejections<- '||current_calling_sequence;
                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                   END IF;
               RAISE get_doc_seq_failure;
             END IF;
             l_current_invoice_status := 'N';
         END IF;  --end of p_sequence_numbering='A' bug5854731 ends
       END; -- end of the above BEGION


       IF (l_current_invoice_status = 'Y'
           and  p_db_sequence_id is NOT NULL) THEN --bug5854731.Added the AND clause.
           --Only if the sequence_id fetched from the step5 is not null,
           --we proceed forward to get the sequence value.

        ----------------------------------------------------------------------
        -- Step 6
        -- Get Doc Sequence Val
        ----------------------------------------------------------------------
        debug_info := '(Get Doc Sequence 6) Get Next Val';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        l_return_code := FND_SEQNUM.GET_SEQ_VAL(
                             200,
                             l_doc_category_code,
                             p_set_of_books_id,
                             'A',
                             NVL(p_invoice_rec.gl_date,
                                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate),
                             p_db_sequence_value,
                             p_db_sequence_id ,
                             'N',
                             'N');
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '-----------> l_doc_category_code = '|| l_doc_category_code
              || ' p_set_of_books_id = '||to_char(p_set_of_books_id)
              || ' p_db_sequence_id  = '||to_char(p_db_sequence_id )
              ||' p_db_seq_name = '||p_db_seq_name
              ||' p_db_sequence_value = '||to_char(p_db_sequence_value));
        END IF;

        IF ((p_db_sequence_value IS NULL) or (l_return_code <> 0)) THEN
          debug_info := '(Get Doc Sequence 7) Reject:Invalid Sequence';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoices_table,
                  p_invoice_rec.invoice_id,
                  'INVALID SEQUENCE',
                  p_default_last_updated_by,
                  p_default_last_update_login,
                  current_calling_sequence) <> TRUE) THEN
            debug_info := 'insert_rejections<- '||current_calling_sequence;
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;
            RAISE get_doc_seq_failure;
          END IF;
          l_current_invoice_status := 'N';
        END IF;  -- end of check l_return_code and seqval
      END IF; -- end of check l_current_invoice_status = 'Y' for step 6
    END IF; -- end of check l_current_invoice_status/doc_category_code

    -- Bug 5064959 starts. The validation for seq value should be done if the profile value is 'A' or 'P'.

     --Bug 7214515/7261280 Uncommented the code changes done in 6492341 and only commented
    -- length check condition
    -- Bug 6492431 The code is commented to remove the 9 digit restriction on doc_sequnce_number.
    --  if ( ( LENGTH( nvl(p_db_sequence_value,0)) > 9 ) or --Condition value changed from 8 to 9 for BUG 5950643
         If  ( TRANSLATE( p_db_sequence_value ,'x1234567890','x') IS NOT NULL) then

          debug_info := '(Get Doc Sequence 8) Reject: Invalid Voucher Number';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections( AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INCONSISTENT VOUCHER INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
             debug_info := 'insert_rejections<- '||current_calling_sequence;
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
             END IF;
             RAISE get_doc_seq_failure;

          END IF;
         l_current_invoice_status := 'N';
       END IF;

   -- Bug 5064959 ends.

  END IF; -- p_sequence_numbering = 'N'

  p_invoice_rec.doc_category_code := l_doc_category_code;
  p_current_invoice_status := l_current_invoice_status;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);
END get_doc_sequence;

/*===================================================================
  Private function: get_invoice_info
  Get some values for creating invoices from po_vendors,
  po_headers
  =================================================================== */

FUNCTION get_invoice_info(
          p_invoice_rec                 IN OUT NOCOPY
              AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
      p_default_last_updated_by     IN            NUMBER,
      p_default_last_update_login   IN            NUMBER,
          p_pay_curr_invoice_amount        OUT NOCOPY NUMBER,
          p_payment_priority               OUT NOCOPY NUMBER,
          p_invoice_amount_limit           OUT NOCOPY NUMBER,
          p_hold_future_payments_flag      OUT NOCOPY VARCHAR2,
          p_supplier_hold_reason           OUT NOCOPY VARCHAR2,
          p_exclude_freight_from_disc      OUT NOCOPY VARCHAR2, /* bug 4931755 */
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  get_invoice_info_failure     EXCEPTION;
  debug_info                   VARCHAR2(500);
  current_calling_sequence     VARCHAR2(2000);
BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'get_invoice_info->'||P_calling_sequence;

  ----------------------------------------------------------------------------
  -- Step 1
  -- Calculate the invoice amount in payment currency
  ----------------------------------------------------------------------------

  debug_info := '(Get Invoice Info step 1) Calculate invoice amount in ' ||
                'payment currency ';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF ( p_invoice_rec.payment_cross_rate is NOT NULL) THEN
    p_pay_curr_invoice_amount := gl_currency_api.convert_amount(
          p_invoice_rec.invoice_currency_code,
          p_invoice_rec.payment_currency_code,
          p_invoice_rec.payment_cross_rate_date,
          p_invoice_rec.payment_cross_rate_type,
          p_invoice_rec.invoice_amount);

  END IF;

  -----------------------------------------------------------------------------
  -- Step 2
  -- Get amount_applicable_to_discount
  -----------------------------------------------------------------------------

  debug_info := '(Get Invoice Info step 2) Get amt_applicable_to_discount ' ||
                ' value if not given';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  p_invoice_rec.amount_applicable_to_discount :=
      NVL(p_invoice_rec.amount_applicable_to_discount,
          p_invoice_rec.invoice_amount);

  -----------------------------------------------------------------------------
  -- Step 3
  -- Get information from supplier site if null in invoice record or never
  -- read:
  --       payment_method_lookup_code     into invoice rec
  --       pay_group_lookup_code          into invoice rec
  --       accts_pay_code_combination_id  into invoice rec
  --       payment_priority               into OUT parameter
  --       invoice_amount_limit           into OUT parameter
  --       hold_future_payments_flag      into OUT parameter
  --       hold_reason                    into OUT parameter
  -----------------------------------------------------------------------------

  -- Payment Requests: Added the if condition for payment requests type invoices
  IF (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST') THEN

     debug_info := '(Get Invoice Info step 3) Get payment default info ';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
       Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
     END IF;
     BEGIN

       SELECT DECODE(p_invoice_rec.pay_group_lookup_code,
                     NULL,asp.vendor_pay_group_lookup_code,
                     p_invoice_rec.pay_group_lookup_code),
              DECODE(p_invoice_rec.accts_pay_code_combination_id, Null,
                     fsp.accts_pay_code_combination_id,
                     p_invoice_rec.accts_pay_code_combination_id),
              p_invoice_rec.payment_priority,
              NULL, --invoice_amount_limit,
              'N', --hold_future_payments_flag,
              NULL, --hold_reason
              'N'  -- exclude_freight_from_discount.bug 4931755
         INTO p_invoice_rec.pay_group_lookup_code,
              p_invoice_rec.accts_pay_code_combination_id,
              p_payment_priority,
              p_invoice_amount_limit,
              p_hold_future_payments_flag,
              p_supplier_hold_reason,
              p_exclude_freight_from_disc
         FROM ap_system_parameters asp,
              financials_system_parameters fsp
        WHERE asp.org_id = p_invoice_rec.org_id
          AND asp.org_id = fsp.org_id;
     EXCEPTION
         WHEN no_data_found THEN
           debug_info := debug_info || '->no data found in query';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 debug_info);
           END IF;
           RAISE get_invoice_info_failure;
     END;

  ELSE

     debug_info := '(Get Invoice Info step 3) Get supplier site default info ';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
       Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
     END IF;
     BEGIN

       SELECT DECODE(p_invoice_rec.pay_group_lookup_code,
                     NULL,pay_group_lookup_code,
                     p_invoice_rec.pay_group_lookup_code),
              DECODE(p_invoice_rec.accts_pay_code_combination_id, Null,
                     accts_pay_code_combination_id,
                     p_invoice_rec.accts_pay_code_combination_id),
              payment_priority,
              invoice_amount_limit,
              hold_future_payments_flag,
              hold_reason,
              NVL(exclude_freight_from_discount, 'N')  /*bug 4931755 */
         INTO p_invoice_rec.pay_group_lookup_code,
              p_invoice_rec.accts_pay_code_combination_id,
              p_payment_priority,
              p_invoice_amount_limit,
              p_hold_future_payments_flag,
              p_supplier_hold_reason,
              p_exclude_freight_from_disc
         FROM ap_supplier_sites_all
        WHERE vendor_id = p_invoice_rec.vendor_id
          AND vendor_site_id = p_invoice_rec.vendor_site_id;
     EXCEPTION
         WHEN no_data_found THEN
           debug_info := debug_info || '->no data found in query';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 debug_info);
           END IF;
           RAISE get_invoice_info_failure;
     END;
  END IF;

  -----------------------------------------------------------------------------
  -- Step 4
  -- Populate who columns if null
  -----------------------------------------------------------------------------
  debug_info := '(Get Invoice Info step 4) Get WHO columns ';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;
  p_invoice_rec.last_updated_by  :=
    NVL(p_invoice_rec.last_updated_by,p_default_last_updated_by);
  p_invoice_rec.last_update_login :=
    NVL(p_invoice_rec.last_update_login,NVL(p_default_last_update_login,
                                            p_default_last_updated_by));
  p_invoice_rec.created_by        :=
    NVL(p_invoice_rec.created_by,p_default_last_updated_by);
  p_invoice_rec.creation_date     :=
    NVL(p_invoice_rec.creation_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate);
  p_invoice_rec.last_update_date  :=
    NVL(p_invoice_rec.last_update_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate);

  RETURN(TRUE);
EXCEPTION
  WHEN OTHERS then
    debug_info := debug_info || '->exception';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END get_invoice_info;

/*=========================================================================

  Function  Insert_Ap_Invoices
  Program Flow:

  =========================================================================*/
-- Payment Request: Added p_needs_invoice_approval for payment request invoices
FUNCTION insert_ap_invoices(
          p_invoice_rec                 IN OUT
                AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_base_invoice_id                OUT NOCOPY NUMBER,
          p_set_of_books_id             IN NUMBER,
          p_doc_sequence_id             IN
                AP_INVOICES.doc_sequence_id%TYPE,
          p_doc_sequence_value          IN
                AP_INVOICES.doc_sequence_value%TYPE,
          p_batch_id                    IN            AP_INVOICES.batch_id%TYPE,
          p_pay_curr_invoice_amount     IN            NUMBER,
          p_approval_workflow_flag      IN            VARCHAR2,
          p_needs_invoice_approval      IN            VARCHAR2,
	  p_add_days_settlement_date    IN            NUMBER,  --bug 493011
          p_disc_is_inv_less_tax_flag   IN            VARCHAR2, --bug 4931755
          p_exclude_freight_from_disc   IN            VARCHAR2, --bug 4931755
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  l_invoice_id              NUMBER;
  debug_info                VARCHAR2(500);
  current_calling_sequence  VARCHAR2(2000);
  l_approval_ready_flag     VARCHAR2(1) := 'Y';
  l_wfapproval_status       VARCHAR2(30);
  --bugfix:4930111
  l_earliest_settlement_date DATE;
  l_attachments_count       NUMBER;

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'insert_ap_invoices<-'||P_calling_sequence;

  -----------------------------------------------------------------------------
  -- Step 1
  -- get new invoice_id for base table ap_invoices
  -----------------------------------------------------------------------------

  debug_info := '(Insert ap invoices step 1) Get new invoice_id for base ' ||
                'table ap_invoices';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;
 -- Bug 5448579
/*
  SELECT  ap_invoices_s.nextval
    INTO  l_invoice_id
    FROM  sys.dual;
*/
  -----------------------------------------------------------------------------
  -- Step 2
  -- get wfapproval_status from profile value - ASP.approval_workflow_flag
  -----------------------------------------------------------------------------

  debug_info := '(Insert ap invoices step 2)-Get wfapproval_status ' ||
                'depends on profile value';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF p_approval_workflow_flag = 'N' THEN
    l_wfapproval_status := 'NOT REQUIRED';
  ELSE

    -- Payment Request: Added IF condition
    -- We need to set the approval status to approved if the
    -- invoice does not need approval
    IF p_needs_invoice_approval = 'N' AND
            p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST' THEN
       l_wfapproval_status := 'WFAPPROVED';
    ELSE
       l_wfapproval_status := 'REQUIRED';
    END IF;

  END IF;
 -- BUG 6785691. Aded to make approval not required in case of expense reports.

  IF  p_invoice_rec.INVOICE_TYPE_LOOKUP_CODE = 'EXPENSE REPORT' THEN
     	l_wfapproval_status := 'NOT REQUIRED';
  END IF;
 -- BUG 6785691. END

/* Bug 4014019: Commenting the call to jg_globe_flex_val due to build issues.

  -----------------------------------------------------------------------------
  -- Step 3
  -- Insert jg_zz_invoice_info
  -----------------------------------------------------------------------------
  debug_info := '(Insert ap invoices step 3) - Call ' ||
                'jg_globe_flex_val.insert_jg_zz_invoice_info';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  jg_globe_flex_val.insert_jg_zz_invoice_info(
          l_invoice_id,
          p_invoice_rec.global_attribute_category,
          p_invoice_rec.global_attribute1,
          p_invoice_rec.global_attribute2,
          p_invoice_rec.global_attribute3,
          p_invoice_rec.global_attribute4,
          p_invoice_rec.global_attribute5,
          p_invoice_rec.global_attribute6,
          p_invoice_rec.global_attribute7,
          p_invoice_rec.global_attribute8,
          p_invoice_rec.global_attribute9,
          p_invoice_rec.global_attribute10,
          p_invoice_rec.global_attribute11,
          p_invoice_rec.global_attribute12,
          p_invoice_rec.global_attribute13,
          p_invoice_rec.global_attribute14,
          p_invoice_rec.global_attribute15,
          p_invoice_rec.global_attribute16,
          p_invoice_rec.global_attribute17,
          p_invoice_rec.global_attribute18,
          p_invoice_rec.global_attribute19,
          p_invoice_rec.global_attribute20,
          p_invoice_rec.last_updated_by,
          p_invoice_rec.last_update_date,
          p_invoice_rec.last_update_login,
          p_invoice_rec.created_by,
          p_invoice_rec.creation_date,
          current_calling_sequence);

*/


  debug_info := '(Insert ap invoices step 3) Calculate earliest settlement date for Prepayment type invoices';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT') THEN
     l_earliest_settlement_date := sysdate + nvl(p_add_days_settlement_date,0);
  END IF;


  -----------------------------------------------------------------------------
  -- Step 4
  -- Insert into ap_invoices table
  -----------------------------------------------------------------------------

  debug_info := '(Insert ap invoices step 4) - Insert into ap_invoices';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  -- Payment Requests: Added party_id, party_site_id,
  -- pay_proc_trxn_type_code, payment_function to the insert stmt
  INSERT INTO ap_invoices_all(
          invoice_id,
          org_id,
          last_update_date,
          last_updated_by,
          last_update_login,
          vendor_id,
          invoice_num,
          invoice_amount,
          vendor_site_id,
          amount_paid,
          discount_amount_taken,
          invoice_date,
          invoice_type_lookup_code,
          description,
          batch_id,
          amount_applicable_to_discount,
          terms_id,
          approved_amount,
          approval_status,
          approval_description,
          pay_group_lookup_code,
          set_of_books_id,
          accts_pay_code_combination_id,
          invoice_currency_code,
          payment_currency_code,
          payment_cross_rate,
          exchange_date,
          exchange_rate_type,
          exchange_rate,
          base_amount,
          payment_status_flag,
          posting_status,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          global_attribute_category,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute11,
          global_attribute12,
          global_attribute13,
          global_attribute14,
          global_attribute15,
          global_attribute16,
          global_attribute17,
          global_attribute18,
          global_attribute19,
          global_attribute20,
          creation_date,
          created_by,
          vendor_prepay_amount,
          prepay_flag,
          recurring_payment_id,
          terms_date,
          source,
          payment_method_code,
          doc_sequence_id,
          doc_sequence_value,
          doc_category_code,
          voucher_num,
          exclusive_payment_flag,
	  quick_po_header_id,   --Bug 8556975
          awt_group_id,
          pay_awt_group_id,--bug6639866
          payment_cross_rate_type,
          payment_cross_rate_date,
          pay_curr_invoice_amount,
          goods_received_date,
          invoice_received_date,
       -- ussgl_transaction_code, - Bug 4277744
          gl_date,
          approval_ready_flag,
          wfapproval_status,
          requester_id,
          control_amount,
          tax_related_invoice_id,
          taxation_country,
          document_sub_type,
          supplier_tax_invoice_number,
          supplier_tax_invoice_date,
          supplier_tax_exchange_rate,
          tax_invoice_recording_date,
          tax_invoice_internal_seq,
          legal_entity_id,
	  application_id,
	  product_table,
	  reference_key1,
	  reference_key2,
	  reference_key3,
	  reference_key4,
	  reference_key5,
	  reference_1,
	  reference_2,
	  net_of_retainage_flag,
          cust_registration_code,
          cust_registration_number,
	  paid_on_behalf_employee_id,
          party_id,
          party_site_id,
          pay_proc_trxn_type_code,
          payment_function,
          BANK_CHARGE_BEARER,
          REMITTANCE_MESSAGE1,
          REMITTANCE_MESSAGE2,
          REMITTANCE_MESSAGE3,
          UNIQUE_REMITTANCE_IDENTIFIER,
          URI_CHECK_DIGIT,
          SETTLEMENT_PRIORITY,
          PAYMENT_REASON_CODE,
          PAYMENT_REASON_COMMENTS,
          DELIVERY_CHANNEL_CODE,
          EXTERNAL_BANK_ACCOUNT_ID,
	  --bugfix:4930111
	  EARLIEST_SETTLEMENT_DATE,
          --bug 4931755
          DISC_IS_INV_LESS_TAX_FLAG,
          EXCLUDE_FREIGHT_FROM_DISCOUNT,
         --Bug 7357218 Quick Pay and Dispute Resolution Project
          ORIGINAL_INVOICE_AMOUNT,
          DISPUTE_REASON,
	  --Third Party Payments
	  REMIT_TO_SUPPLIER_NAME,
	  REMIT_TO_SUPPLIER_ID,
	  REMIT_TO_SUPPLIER_SITE,
	  REMIT_TO_SUPPLIER_SITE_ID,
	  RELATIONSHIP_ID
          )
  VALUES (ap_invoices_s.nextval,  -- l_invoice_id, Bug 5448579
          p_invoice_rec.org_id,
          p_invoice_rec.last_update_date,
          --bug 6951863 fix -start
          --p_invoice_rec.last_update_login,
          p_invoice_rec.last_updated_by,
          --p_invoice_rec.last_updated_by,
          p_invoice_rec.last_update_login,
	  --bug 6951863 fix -end
          p_invoice_rec.vendor_id,
          p_invoice_rec.invoice_num,
          p_invoice_rec.invoice_amount,
          p_invoice_rec.vendor_site_id,
          0,                               -- amount_paid
          0,                               -- discount_amount_taken,
          p_invoice_rec.invoice_date,
          p_invoice_rec.invoice_type_lookup_code,
          p_invoice_rec.description,       -- description
          p_batch_id,                      -- batch_id
          p_invoice_rec.amount_applicable_to_discount,
          p_invoice_rec.terms_id,          -- terms_id
          NULL,                            -- approved_amount
          NULL,                            -- approval_status
          NULL,                            -- approval_description
          p_invoice_rec.pay_group_lookup_code,
          p_set_of_books_id,
          p_invoice_rec.accts_pay_code_combination_id,
          p_invoice_rec.invoice_currency_code,
          p_invoice_rec.payment_currency_code,
          p_invoice_rec.payment_cross_rate,
          p_invoice_rec.exchange_date,
          p_invoice_rec.exchange_rate_type,
          p_invoice_rec.exchange_rate,
          p_invoice_rec.no_xrate_base_amount,  -- base_amount
          'N',  -- payment_status_flag
          NULL, -- posting_status
          p_invoice_rec.attribute_category,
          p_invoice_rec.attribute1,
          p_invoice_rec.attribute2,
          p_invoice_rec.attribute3,
          p_invoice_rec.attribute4,
          p_invoice_rec.attribute5,
          p_invoice_rec.attribute6,
          p_invoice_rec.attribute7,
          p_invoice_rec.attribute8,
          p_invoice_rec.attribute9,
          p_invoice_rec.attribute10,
          p_invoice_rec.attribute11,
          p_invoice_rec.attribute12,
          p_invoice_rec.attribute13,
          p_invoice_rec.attribute14,
          p_invoice_rec.attribute15,
          p_invoice_rec.global_attribute_category,
          p_invoice_rec.global_attribute1,
          p_invoice_rec.global_attribute2,
          p_invoice_rec.global_attribute3,
          p_invoice_rec.global_attribute4,
          p_invoice_rec.global_attribute5,
          p_invoice_rec.global_attribute6,
          p_invoice_rec.global_attribute7,
          p_invoice_rec.global_attribute8,
          p_invoice_rec.global_attribute9,
          p_invoice_rec.global_attribute10,
          p_invoice_rec.global_attribute11,
          p_invoice_rec.global_attribute12,
          p_invoice_rec.global_attribute13,
          p_invoice_rec.global_attribute14,
          p_invoice_rec.global_attribute15,
          p_invoice_rec.global_attribute16,
          p_invoice_rec.global_attribute17,
          p_invoice_rec.global_attribute18,
          p_invoice_rec.global_attribute19,
          p_invoice_rec.global_attribute20,
          p_invoice_rec.creation_date,
          p_invoice_rec.created_by,
          0,                            --  vendor_prepay_amount,
          'N',                          --  prepay_flag,
          NULL,                         --  recurring_payment_id,
          p_invoice_rec.terms_date,
          p_invoice_rec.source,
          p_invoice_rec.payment_method_code,
          p_doc_sequence_id,
          p_doc_sequence_value,                   -- doc_sequence_value
          p_invoice_rec.doc_category_code,        -- doc_category_code
          DECODE(p_invoice_rec.doc_category_code, NULL,
                 p_invoice_rec.voucher_num, ''),  -- voucher_num
          --p_invoice_rec.exclusive_payment_flag,   -- **exclusive_payment_flag
	  DECODE(p_invoice_rec.invoice_type_lookup_code, 'CREDIT', 'N', p_invoice_rec.exclusive_payment_flag), -- BUG 7195865
	  (select po_header_id from po_headers where segment1 =p_invoice_rec.po_number),  /* Bug 8556975 Changed po_headers_all to po_headers for * bug#9577089 */
          p_invoice_rec.awt_group_id,             -- awt_group_id
          p_invoice_rec.pay_awt_group_id,             -- pay_awt_group_id--bug6639866
          p_invoice_rec.payment_cross_rate_type,  -- payment_cross_rate_type
          p_invoice_rec.payment_cross_rate_date,  -- payment_crosss_rate_date
          p_pay_curr_invoice_amount,              -- pay_curr_invoice_amount
          p_invoice_rec.goods_received_date,      -- goods_received_date
          p_invoice_rec.invoice_received_date,    -- invoice_received_date
       -- Removed for bug 4277744
       -- p_invoice_rec.ussgl_transaction_code,   -- ussgl_transaction_code
          TRUNC(p_invoice_rec.gl_date),           -- gl_date
          l_approval_ready_flag,                  -- approval_ready_flag
          l_wfapproval_status,                    -- wfapproval_status
          p_invoice_rec.requester_id,             -- request_id
          p_invoice_rec.control_amount,           -- control_amount
          p_invoice_rec.tax_related_invoice_id,   -- tax_related_invoice_id
          p_invoice_rec.taxation_country,         -- taxation_country
          p_invoice_rec.document_sub_type,        -- document_sub_type
          p_invoice_rec.supplier_tax_invoice_number,
            -- supplier_tax_invoice_number
          p_invoice_rec.supplier_tax_invoice_date,
            -- supplier_tax_invoice_date
          p_invoice_rec.supplier_tax_exchange_rate,
             -- supplier_tax_exchange_rate
          p_invoice_rec.tax_invoice_recording_date,
             -- tax_invoice_recording_date
          p_invoice_rec.tax_invoice_internal_seq,  -- tax_invoice_internal_seq
          p_invoice_rec.legal_entity_id,           -- legal_entity_id
	  p_invoice_rec.application_id,		   --application identifier
	  p_invoice_rec.product_table,		   --product_table
	  p_invoice_rec.reference_key1,		   --reference_key1
	  p_invoice_rec.reference_key2,		   --reference_key2
	  p_invoice_rec.reference_key3,		   --reference_key3
	  p_invoice_rec.reference_key4,		   --reference_key4
	  p_invoice_rec.reference_key5,		   --reference_key5
	  p_invoice_rec.reference_1,		   --reference_1
	  p_invoice_rec.reference_2,		   --reference_2
	  p_invoice_rec.net_of_retainage_flag,	   --net_of_retainage_flag
          P_invoice_rec.cust_registration_code,
          P_invoice_rec.cust_registration_number,
	  P_invoice_rec.paid_on_behalf_employee_id,
          p_invoice_rec.party_id,
          p_invoice_rec.party_site_id,
          p_invoice_rec.pay_proc_trxn_type_code,
          p_invoice_rec.payment_function,
          p_invoice_rec.BANK_CHARGE_BEARER,
          p_invoice_rec.REMITTANCE_MESSAGE1,
          p_invoice_rec.REMITTANCE_MESSAGE2,
          p_invoice_rec.REMITTANCE_MESSAGE3,
          p_invoice_rec.UNIQUE_REMITTANCE_IDENTIFIER,
          p_invoice_rec.URI_CHECK_DIGIT,
          p_invoice_rec.SETTLEMENT_PRIORITY,
          p_invoice_rec.PAYMENT_REASON_CODE,
          p_invoice_rec.PAYMENT_REASON_COMMENTS,
          p_invoice_rec.DELIVERY_CHANNEL_CODE,
          p_invoice_rec.EXTERNAL_BANK_ACCOUNT_ID,
	  --bugfix:4930111
	  l_earliest_settlement_date,
          --bug4931755
          p_disc_is_inv_less_tax_flag,
          p_exclude_freight_from_disc,
          --Bug 7357218 Quick Pay and Dispute Resolution Project
          p_invoice_rec.ORIGINAL_INVOICE_AMOUNT,
          p_invoice_rec.DISPUTE_REASON,
	  --Third Party Payments
	  p_invoice_rec.REMIT_TO_SUPPLIER_NAME,
	  p_invoice_rec.REMIT_TO_SUPPLIER_ID,
	  p_invoice_rec.REMIT_TO_SUPPLIER_SITE,
	  p_invoice_rec.REMIT_TO_SUPPLIER_SITE_ID,
	  p_invoice_rec.RELATIONSHIP_ID
        ) RETURNING invoice_id INTO l_invoice_id;

  -----------------------------------------------------------------------------
  -- Step 5
  -- copy attachment for the invoice
  -----------------------------------------------------------------------------
  debug_info := '(Insert ap invoices step 5) before copy attachments: '||
        'source = ' || p_invoice_rec.source || ', from_invoice_id = ' ||
        p_invoice_rec.invoice_id || ', to_invoice_id = ' || l_invoice_id;
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  l_attachments_count :=
                copy_attachments(p_invoice_rec.invoice_id, l_invoice_id);
  debug_info := '(Insert ap invoices step 5) copy attachments done: ' ||
                l_attachments_count;
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  -----------------------------------------------------------------------------
  -- Step 6
  -- Assign the out parameter for new invoice_id
  -----------------------------------------------------------------------------
  debug_info := '(Insert ap invoices step 6) - Return the new invoice_id-> ' ||
                to_char(l_invoice_id);
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;


  p_base_invoice_id := l_invoice_id;

  RETURN( TRUE );
EXCEPTION
  WHEN OTHERS THEN
    debug_info := debug_info || '->exception';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          debug_info);
    END IF;
    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            SQLERRM);
      END IF;
    END IF;
    RETURN (FALSE);

END insert_ap_invoices;

/*======================================================================
 Function: Change_invoice_status

 The available statuses are:
 'PROCESSING' - Temporary status to prevent the invoice cursor pick it up
                again. It means invoice is ok during this run and will be
                changed to 'PROCESSED' after the batch finished.
 'REJECTING' - Temporary status to prevent the invoice cursor pick it up
                again. It means invoice is rejected during this run and
                will be changed to 'REJECTED' after the batch finished.
 'PROCESSED' - It means invoice has been successfully imported
 'REJECTED' - It means there are some rejections or error for this invoice.
  Interface invoice cannot be purged if the flag is other than 'PRECESSED'
  ========================================================================*/

FUNCTION change_invoice_status(
          p_status                      IN            VARCHAR2,
          p_import_invoice_id           IN            NUMBER,
          P_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'Change_invoice_status<-'||P_calling_sequence;

  ---------------------------------------------
  -- Step 1
  -- Update status to p_invoices_interface
  ---------------------------------------------

  debug_info := '(Change_invoice_status 1) Change invoice status to '||
                p_status;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  UPDATE AP_INVOICES_INTERFACE
     SET status = p_status
   WHERE invoice_id = p_import_invoice_id;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END change_invoice_status;

/*======================================================================
 Private Funtion: Update_temp_invoice_status

  Change temporary invoice status from
                  'PROCESSING' to 'PROCESSED'
                  'REJECTING' to 'REJECTED'
  ======================================================================*/

FUNCTION Update_temp_invoice_status(
          p_source                      IN            VARCHAR2,
          p_group_id                    IN            VARCHAR2,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500);
--4019310, use binds for literals
l_processed  varchar2(10);
l_rejected   varchar2(10);
l_processing varchar2(10);
l_rejecting  varchar2(10);
BEGIN

l_processed := 'PROCESSED';
l_rejected  := 'REJECTED';
l_rejecting := 'REJECTING';
l_processing:= 'PROCESSING';
 -- Update the calling sequence
  --
  current_calling_sequence := 'Update_temp_invoice_status<-'||
                              P_calling_sequence;

  ---------------------------------------------
  -- 1.  Change PROCESSING to PROCESSED
  ---------------------------------------------
  debug_info := '(Update_temp_invoice_status 1) Change '||
                'PROCESSING to PROCESSED ';

  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  ---------------------------------------------
  -- 2.  Change REJECTING to REJECTED
  ---------------------------------------------
  debug_info := '(Update_temp_invoice_status 2) Change REJECTING to REJECTED';

  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
--  Bug fix: 1952122
--  Rewrite with two statements avoiding AND ((p_group_id is NULL) OR (group_id = --p_group_id))
--3910020, used binds in the sql below

  --Bug 6801046
  --Update statement should only update the status of Invoices
  --pertaining to the current request. Modified the below 4 update stmts.
  	 -- bug 7608232 added an additional or in request_id = AP_IMPORT_INVOICES_PKG.g_conc_request_id
 	  -- as  (request_id = AP_IMPORT_INVOICES_PKG.g_conc_request_id or request_id is null)

  IF p_group_id IS NULL THEN

   UPDATE AP_INVOICES_INTERFACE
      SET status = l_processed
    WHERE source = p_source
      AND p_group_id is NULL
      AND status = l_processing
      AND (request_id = AP_IMPORT_INVOICES_PKG.g_conc_request_id or request_id is null);
      -- bug 7608232

   UPDATE AP_INVOICES_INTERFACE
      SET status = l_rejected
    WHERE source = p_source
      AND p_group_id is NULL
      AND status = l_rejecting
      AND (request_id = AP_IMPORT_INVOICES_PKG.g_conc_request_id or request_id is null);
-- bug 7608232
  ELSE

   UPDATE AP_INVOICES_INTERFACE
      SET status = l_processed
    WHERE source = p_source
      AND group_id = p_group_id
      AND status = l_processing
      AND (request_id = AP_IMPORT_INVOICES_PKG.g_conc_request_id or request_id is null);
-- bug 7608232
   UPDATE AP_INVOICES_INTERFACE
      SET status = l_rejected
    WHERE source = p_source
      AND group_id = p_group_id
      AND status = l_rejecting
      AND (request_id =AP_IMPORT_INVOICES_PKG.g_conc_request_id or request_id is null);
-- bug 7608232
  END IF;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END Update_temp_invoice_status;

/*======================================================================
  Private Procedure: Insert new AP_BATCHES lines

  Insert New Batch line if the batch name is new
  ======================================================================*/

FUNCTION Insert_ap_batches(
          p_batch_id                    IN            NUMBER,
          p_batch_name                  IN            VARCHAR2,
          p_invoice_currency_code       IN            VARCHAR2,
          p_payment_currency_code       IN            VARCHAR2,
          p_actual_invoice_count        IN            NUMBER,
          p_actual_invoice_total        IN            NUMBER,
          p_last_updated_by             IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500);
BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'Insert_ap_batches<-'||p_calling_sequence;

  ---------------------------------------------
  -- Insert ap_batches
  ---------------------------------------------
  debug_info := 'Insert ap_batches';
  -- bug 5441261. Insert should be into AP_BATCHES_ALL
  INSERT INTO ap_batches_all(
          batch_id,
          batch_name,
          batch_date,
          last_update_date,
          last_updated_by,
          control_invoice_count,
          control_invoice_total,
          actual_invoice_count,
          actual_invoice_total,
          invoice_currency_code,
          payment_currency_code,
          creation_date,
          created_by)
  VALUES(
          p_batch_id,
          p_batch_name,
          TRUNC(SYSDATE),
          SYSDATE,
          p_last_updated_by,
          p_actual_invoice_count ,
          p_actual_invoice_total ,
          p_actual_invoice_count ,
          p_actual_invoice_total ,
          p_invoice_currency_code,
          p_payment_currency_code,
          SYSDATE,
          p_last_updated_by);

   RETURN(TRUE);

EXCEPTION

 WHEN OTHERS then
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END Insert_ap_batches;

/*======================================================================
  Function: Update_Ap_Batches
  This function updates the value of control invoice count and
  control invoice total in ap_batches
  ======================================================================*/

FUNCTION Update_Ap_Batches(
          p_batch_id                    IN            NUMBER,
          p_batch_name                  IN            VARCHAR2,
          p_actual_invoice_count        IN            NUMBER,
          p_actual_invoice_total        IN            NUMBER,
          p_last_updated_by             IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  current_calling_sequence  varchar2(2000);
  debug_info     varchar2(500);

BEGIN

  -- Update the calling sequence

  current_calling_sequence :='Update_Ap_Batches<-'||p_calling_sequence;

  -- Update ap_batches

  debug_info :='Update ap_batches';

  UPDATE ap_batches_all --Bug 8419706 Changed the table ap_batches to ap_batches_all
                        --    as the update is not taking place, since org_id is updated
                        --    as null in ap_batches_all during insertion of data.
     SET control_invoice_count =
              NVL(control_invoice_count,0)+
              p_actual_invoice_count,
         control_invoice_total =
              NVL(control_invoice_total,0)+
              p_actual_invoice_total,
         actual_invoice_count =
              actual_invoice_count+
              p_actual_invoice_count,
         actual_invoice_total =
              actual_invoice_total+
              p_actual_invoice_total
   WHERE batch_id = p_batch_id; -- Added for bug2003024

RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE<0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

RETURN(FALSE);

END Update_ap_Batches;

/*=========================================================================*/
/*                                                                         */
/* Function  Insert_Ap_Invoices_lines                                      */
/* Program Flow:                                                           */
/* 1. Insert into ap_invoice_lines with the validated interface lines      */
/*    data                                                                 */
/* 2. Bulk  select primary key of lines                                    */
/* Parameters                                                              */
/*    p_base_invoice_id                                                    */
/*    p_invoice_lines_tab - validated interface lines data                 */
/*    p_set_of_books_id - set_of_books_id populated in get_info()          */
/*    p_default_last_updated_by                                            */
/*    p_default_last_update_login                                          */
/*    p_calling_sequence  - for debug purpose                              */
/*                                                                         */
/*=========================================================================*/

FUNCTION insert_ap_invoice_lines(
          p_base_invoice_id             IN            NUMBER,
          p_invoice_lines_tab           IN
                     AP_IMPORT_INVOICES_PKG.t_lines_table,
          p_set_of_books_id             IN            NUMBER,
          p_approval_workflow_flag      IN            VARCHAR2,
          p_tax_only_flag               IN            VARCHAR2,
          p_tax_only_rcv_matched_flag   IN            VARCHAR2,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  debug_info                VARCHAR2(500);
  current_calling_sequence  VARCHAR2(2000);
  i                         BINARY_INTEGER := 0;
  l_generate_dists          AP_INVOICE_LINES.generate_dists%TYPE := 'Y';
  l_wfapproval_status       AP_INVOICE_LINES.wfapproval_status%TYPE := NULL;
  l_key_value_list          gl_ca_utility_pkg.r_key_value_arr;

  l_inv_code				VARCHAR2(50); -- BUG 6785691

   -- bug# 6989166 starts
  Cursor c_ship_to_location (p_ship_to_loc_code HR_LOCATIONS.LOCATION_CODE%TYPE) Is
  Select ship_to_location_id
  From   hr_locations
  Where  location_code = p_ship_to_loc_code
  and	nvl(ship_to_site_flag, 'N') = 'Y';
  -- bug# 6989166 ends

  Cursor c_ship_to (c_invoice_id NUMBER) Is
  Select aps.ship_to_location_id
  From   ap_invoices_all       ai,
         ap_supplier_sites_all aps
  Where  ai.invoice_id     = c_invoice_id
  And    ai.vendor_site_id = aps.vendor_site_id;

  l_ship_to_location_id  ap_supplier_sites_all.ship_to_location_id%type;
  -- bug# 6989166 starts
  p_ship_to_location_id  ap_supplier_sites_all.ship_to_location_id%type;
  -- bug# 6989166 ends

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'insert_ap_invoice_lines<-'||P_calling_sequence;

  -----------------------------------------------------------------------------
  -- Step 1
  -- Initialize the work flow approval flag
  -----------------------------------------------------------------------------

  debug_info := '(Insert ap invoice lines step 1) - populate the '||
                'wfapproval_status_flag';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF ( NVL(p_approval_workflow_flag, 'N') = 'N' ) THEN
    l_wfapproval_status := 'NOT REQUIRED';
  ELSE
    l_wfapproval_status := 'REQUIRED';
  END IF;

  -- BUG 6785691. START
   select INVOICE_TYPE_LOOKUP_CODE
   into l_inv_code
   from ap_invoices_all
   where invoice_id = p_base_invoice_id;

   	IF  l_inv_code = 'EXPENSE REPORT' THEN
	  	l_wfapproval_status := 'NOT REQUIRED';
	END IF;
   -- BUG 6785691. END

  -----------------------------------------------------------------------------
  -- Step 2
  -- Insert into the ap_invoice_lines table
  -----------------------------------------------------------------------------

  debug_info := '(Insert ap invoice lines step 2) - Loop the Pl/sql table';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  Open  c_ship_to (p_base_invoice_id);
  Fetch c_ship_to
  Into  p_ship_to_location_id; --l_ship_to_location_id; -- bug 6989166
  Close c_ship_to;

  BEGIN
    FOR i IN p_invoice_lines_tab.FIRST..p_invoice_lines_tab.LAST LOOP
       -- bUg 7537802
        l_generate_dists := 'Y';
	-- bug# 6989166 starts
	  IF (p_invoice_lines_tab(i).ship_to_location_code IS NOT NULL AND
		p_invoice_lines_tab(i).ship_to_location_id IS NULL) THEN

		Open  c_ship_to_location (p_invoice_lines_tab(i).ship_to_location_code);
		Fetch c_ship_to_location
		Into  l_ship_to_location_id;
		Close c_ship_to_location;
	  ELSE
		l_ship_to_location_id  := p_ship_to_location_id;
	  END IF;
	-- bug# 6989166 ends

/*      IF (p_invoice_lines_tab(i).line_type_lookup_code <> 'TAX'
          OR (p_invoice_lines_tab(i).line_type_lookup_code = 'TAX'
	      and nvl(p_tax_only_flag, 'N') <> 'Y'
              and nvl(p_tax_only_rcv_matched_flag, 'N') <> 'Y')) THEN */
             /* commented for 6010950 as all the lines we first need to insert into
                ap_invoice_lines as user is importing DFF's  also while importing invoice.
                So if we are copying the tax line from zx_lines_summary instead of inserting
                the Tax line first in ap_invoice_lines then we are loosing DFF information.  */

	        --Bug 7427463/7379883 project_id, code_combination information is not populate
		--at ap_exp_report_lines_all table. We are allowing expense reports, payment requests
	        --to generate distribution without checking any values.

	      IF  (l_inv_code IN ('EXPENSE REPORT','PAYMENT REQUEST')) THEN
	  	  l_generate_dists := 'Y';

		 -- End of Bug 7427463/7379883

                 -- BUG 7291580 checking for po_number, project_id, distribution_set_id, dist_code_combination_id
		 -- rcv_transaction_id. If all are null then set generate_dist to 'N', else to 'Y'

              -- bug 8288304
          ELSIF (p_invoice_lines_tab(i).line_type_lookup_code <> 'ITEM'
            AND NVL(p_invoice_lines_tab(i).prorate_across_flag, 'N') = 'Y') THEN -- bug 8851140: modify
                l_generate_dists := 'Y';

	      ELSIF ( p_invoice_lines_tab(i).project_id IS NULL
			AND p_invoice_lines_tab(i).distribution_set_id IS NULL
			AND p_invoice_lines_tab(i).po_header_id IS NULL
			AND p_invoice_lines_tab(i).dist_code_combination_id IS NULL
			AND p_invoice_lines_tab(i).rcv_transaction_id IS NULL
		) THEN
			l_generate_dists := 'N';
	      END IF;
	        -- End of BUG 7291580

        -- Insert only non-tax lines
        -- tax lines will be created after calling import_document_with_tax
        -- or calculate tax in the case of tax only lines matched to receipts

        INSERT INTO ap_invoice_lines_all(
            INVOICE_ID,
            LINE_NUMBER,
            LINE_TYPE_LOOKUP_CODE,
            REQUESTER_ID,
            DESCRIPTION,
            LINE_SOURCE,
            ORG_ID,
            LINE_GROUP_NUMBER,
            INVENTORY_ITEM_ID,
            ITEM_DESCRIPTION,
            SERIAL_NUMBER,
            MANUFACTURER,
            MODEL_NUMBER,
            WARRANTY_NUMBER,
            GENERATE_DISTS,
            MATCH_TYPE,
            DISTRIBUTION_SET_ID,
            ACCOUNT_SEGMENT,
            BALANCING_SEGMENT,
            COST_CENTER_SEGMENT,
            OVERLAY_DIST_CODE_CONCAT,
            DEFAULT_DIST_CCID,
            PRORATE_ACROSS_ALL_ITEMS,
            ACCOUNTING_DATE,
            PERIOD_NAME ,
            DEFERRED_ACCTG_FLAG ,
            DEF_ACCTG_START_DATE ,
            DEF_ACCTG_END_DATE,
            DEF_ACCTG_NUMBER_OF_PERIODS,
            DEF_ACCTG_PERIOD_TYPE ,
            SET_OF_BOOKS_ID,
            AMOUNT,
            BASE_AMOUNT,
            ROUNDING_AMT,
            QUANTITY_INVOICED,
            UNIT_MEAS_LOOKUP_CODE ,
            UNIT_PRICE,
            WFAPPROVAL_STATUS,
         -- USSGL_TRANSACTION_CODE, - Bug 4277744
            DISCARDED_FLAG,
            ORIGINAL_AMOUNT,
            ORIGINAL_BASE_AMOUNT ,
            ORIGINAL_ROUNDING_AMT ,
            CANCELLED_FLAG ,
            INCOME_TAX_REGION,
            TYPE_1099   ,
            STAT_AMOUNT  ,
            PREPAY_INVOICE_ID ,
            PREPAY_LINE_NUMBER  ,
            INVOICE_INCLUDES_PREPAY_FLAG ,
            CORRECTED_INV_ID ,
            CORRECTED_LINE_NUMBER ,
            PO_HEADER_ID,
            PO_LINE_ID  ,
            PO_RELEASE_ID ,
            PO_LINE_LOCATION_ID ,
            PO_DISTRIBUTION_ID,
            RCV_TRANSACTION_ID,
	    --Bug 7344899
	    RCV_SHIPMENT_LINE_ID,
            FINAL_MATCH_FLAG,
            ASSETS_TRACKING_FLAG ,
            ASSET_BOOK_TYPE_CODE ,
            ASSET_CATEGORY_ID ,
            PROJECT_ID ,
            TASK_ID ,
            EXPENDITURE_TYPE ,
            EXPENDITURE_ITEM_DATE ,
            EXPENDITURE_ORGANIZATION_ID ,
            PA_QUANTITY,
            PA_CC_AR_INVOICE_ID ,
            PA_CC_AR_INVOICE_LINE_NUM ,
            PA_CC_PROCESSED_CODE ,
            AWARD_ID,
            AWT_GROUP_ID ,
            PAY_AWT_GROUP_ID ,--bug6639866
            REFERENCE_1 ,
            REFERENCE_2 ,
            RECEIPT_VERIFIED_FLAG  ,
            RECEIPT_REQUIRED_FLAG ,
            RECEIPT_MISSING_FLAG ,
            JUSTIFICATION  ,
            EXPENSE_GROUP ,
            START_EXPENSE_DATE ,
            END_EXPENSE_DATE ,
            RECEIPT_CURRENCY_CODE  ,
            RECEIPT_CONVERSION_RATE,
            RECEIPT_CURRENCY_AMOUNT ,
            DAILY_AMOUNT ,
            WEB_PARAMETER_ID ,
            ADJUSTMENT_REASON ,
            MERCHANT_DOCUMENT_NUMBER ,
            MERCHANT_NAME ,
            MERCHANT_REFERENCE ,
            MERCHANT_TAX_REG_NUMBER,
            MERCHANT_TAXPAYER_ID  ,
            COUNTRY_OF_SUPPLY,
            CREDIT_CARD_TRX_ID ,
            COMPANY_PREPAID_INVOICE_ID,
            CC_REVERSAL_FLAG ,
            CREATION_DATE ,
            CREATED_BY,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATE_LOGIN ,
            PROGRAM_APPLICATION_ID ,
            PROGRAM_ID ,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID ,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2 ,
            ATTRIBUTE3 ,
            ATTRIBUTE4 ,
            ATTRIBUTE5 ,
            ATTRIBUTE6 ,
            ATTRIBUTE7 ,
            ATTRIBUTE8,
            ATTRIBUTE9 ,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13 ,
            ATTRIBUTE14,
            ATTRIBUTE15,
            GLOBAL_ATTRIBUTE_CATEGORY,
            GLOBAL_ATTRIBUTE1,
            GLOBAL_ATTRIBUTE2,
            GLOBAL_ATTRIBUTE3,
            GLOBAL_ATTRIBUTE4 ,
            GLOBAL_ATTRIBUTE5 ,
            GLOBAL_ATTRIBUTE6 ,
            GLOBAL_ATTRIBUTE7 ,
            GLOBAL_ATTRIBUTE8 ,
            GLOBAL_ATTRIBUTE9 ,
            GLOBAL_ATTRIBUTE10,
            GLOBAL_ATTRIBUTE11,
            GLOBAL_ATTRIBUTE12 ,
            GLOBAL_ATTRIBUTE13,
            GLOBAL_ATTRIBUTE14,
            GLOBAL_ATTRIBUTE15,
            GLOBAL_ATTRIBUTE16,
            GLOBAL_ATTRIBUTE17 ,
            GLOBAL_ATTRIBUTE18 ,
            GLOBAL_ATTRIBUTE19 ,
            GLOBAL_ATTRIBUTE20 ,
            CONTROL_AMOUNT,
            ASSESSABLE_VALUE,
            PRIMARY_INTENDED_USE,
            SHIP_TO_LOCATION_ID,
            PRODUCT_TYPE,
            PRODUCT_CATEGORY,
            PRODUCT_FISC_CLASSIFICATION,
            USER_DEFINED_FISC_CLASS,
            TRX_BUSINESS_CATEGORY,
	    APPLICATION_ID,
	    PRODUCT_TABLE,
	    REFERENCE_KEY1,
	    REFERENCE_KEY2,
	    REFERENCE_KEY3,
	    REFERENCE_KEY4,
	    REFERENCE_KEY5,
	    PURCHASING_CATEGORY_ID,
	    COST_FACTOR_ID,
	    SOURCE_APPLICATION_ID,
	    SOURCE_ENTITY_CODE,
	    SOURCE_EVENT_CLASS_CODE,
	    SOURCE_TRX_ID,
	    SOURCE_LINE_ID,
	    SOURCE_TRX_LEVEL_TYPE,
	    TAX_CLASSIFICATION_CODE,
	    RETAINED_AMOUNT,
	    RETAINED_AMOUNT_REMAINING,
	    TAX_REGIME_CODE,
	    TAX,
	    TAX_JURISDICTION_CODE,
	    TAX_STATUS_CODE,
	    TAX_RATE_ID,
	    TAX_RATE_CODE,
	    TAX_RATE
         )VALUES (
             p_Base_invoice_id,
             -- invoice_id
              p_invoice_lines_tab(i).line_number,
             -- line_number
              p_invoice_lines_tab(i).line_type_lookup_code,
             -- line_type_lookup_code
              p_invoice_lines_tab(i).requester_id,
             -- requester_id
              p_invoice_lines_tab(i).description,
             -- description
              'IMPORTED',
             -- line_source
              p_invoice_lines_tab(i).org_id,
             -- org_id
              p_invoice_lines_tab(i).line_group_number,
             -- line_group_number
              p_invoice_lines_tab(i).inventory_item_id,
             -- inventory_item_id
              p_invoice_lines_tab(i).item_description,
             -- item_description
              p_invoice_lines_tab(i).serial_number,
             -- serial_number
              p_invoice_lines_tab(i).manufacturer,
             -- manufacturer
              p_invoice_lines_tab(i).model_number,
             -- model_number
              p_invoice_lines_tab(i).warranty_number,
             -- warranty_number
              l_generate_dists,
             -- generate_dists
            /* Bug 5400087 */
            decode(p_invoice_lines_tab(i).line_type_lookup_code, 'ITEM',
                   decode(p_invoice_lines_tab(i).match_type, NULL, 'NOT_MATCHED',
                          p_invoice_lines_tab(i).match_type),
                   decode(p_invoice_lines_tab(i).rcv_transaction_id, NULL, 'NOT_MATCHED',
                          'OTHER_TO_RECEIPT')),
            /*decode(p_invoice_lines_tab(i).rcv_transaction_id, NULL,
                   decode(p_invoice_lines_tab(i).po_header_id, NULL,
                          decode(p_invoice_lines_tab(i).corrected_inv_id,
                                 NULL,'NOT_MATCHED','PRICE_CORRECTION'),
                          'ITEM_TO_PO'),
                   decode(p_invoice_lines_tab(i).line_type_lookup_code, 'ITEM',
                          'ITEM_TO_RECEIPT', 'OTHER_TO_RECEIPT')), */
             -- match_type
              p_invoice_lines_tab(i).distribution_set_id,
             -- distribution_set_id
              p_invoice_lines_tab(i).account_segment,
             -- account_segment
              p_invoice_lines_tab(i).balancing_segment,
             -- balancing_segment
              p_invoice_lines_tab(i).cost_center_segment,
             -- cost_center_segment
              p_invoice_lines_tab(i).dist_code_concatenated,
             -- overlay_dist_code_concat
              p_invoice_lines_tab(i).dist_code_combination_id,
             -- default_dist_ccid
              p_invoice_lines_tab(i).prorate_across_flag,
             -- prorate_across_all_items
              p_invoice_lines_tab(i).accounting_date,
             -- accounting_date
              p_invoice_lines_tab(i).period_name,
             -- period_name
              p_invoice_lines_tab(i).deferred_acctg_flag,
             -- deferred_acctg_flag
              p_invoice_lines_tab(i).def_acctg_start_date,
             -- def_acctg_start_date
              p_invoice_lines_tab(i).def_acctg_end_date,
             -- def_acctg_end_date
              p_invoice_lines_tab(i).def_acctg_number_of_periods,
             -- def_acctg_number_of_periods
              p_invoice_lines_tab(i).def_acctg_period_type,
             -- def_acctg_period_type
              p_set_of_books_id,
             -- set_of_books_id
              p_invoice_lines_tab(i).amount,
             -- amount
              p_invoice_lines_tab(i).base_amount,
             -- base_amount
              NULL,  -- rounding_amt
              p_invoice_lines_tab(i).quantity_invoiced,
             -- quantity_invoiced
              p_invoice_lines_tab(i).unit_of_meas_lookup_code,
             -- unit_meas_lookup_code
              p_invoice_lines_tab(i).unit_price,
             -- unit_price
              l_wfapproval_status,
             -- wfapproval_status
           -- p_invoice_lines_tab(i).ussgl_transaction_code,
             -- ussgl_transaction_code  - Bug 4277744
              'N',   -- discarded_flag
              NULL,  -- original_amount
              NULL,  -- original_base_amount
              NULL,  -- original_rounding_amt
              'N',   -- cancelled_flag
              p_invoice_lines_tab(i).income_tax_region,
             -- income_tax_region
              p_invoice_lines_tab(i).type_1099,
             -- type_1099
              p_invoice_lines_tab(i).stat_amount,
             -- stat_amount
              NULL,
             -- prepay_invoice_id
             NULL,
            -- prepay_line_number
             NULL,
            -- invoice_includes_prepay_flag
             p_invoice_lines_tab(i).corrected_inv_id,  -- corrected_inv_id
             p_invoice_lines_tab(i).price_correct_inv_line_num,  -- corrected_line_number
             p_invoice_lines_tab(i).po_header_id,
            -- po_header_id
             p_invoice_lines_tab(i).po_line_id,
            -- po_line_id
             p_invoice_lines_tab(i).po_release_id,
            -- po_release_id
             p_invoice_lines_tab(i).po_line_location_id,
            -- po_line_location_id
             p_invoice_lines_tab(i).po_distribution_id,
            -- po_distribution_id
             p_invoice_lines_tab(i).rcv_transaction_id,
            -- rcv_transaction_id
	    --bug 7344899
	     p_invoice_lines_tab(i).rcv_shipment_line_id,
	    --rcv_shipment_line_id
             p_invoice_lines_tab(i).final_match_flag,
            -- final_match_flag
             nvl(p_invoice_lines_tab(i).assets_tracking_flag, 'N'),
            -- assets_tracking_flag
             p_invoice_lines_tab(i).asset_book_type_code,
            -- asset_book_type_code,
             p_invoice_lines_tab(i).asset_category_id,
            -- asset_category_id
             p_invoice_lines_tab(i).project_id,
            -- project_id
             p_invoice_lines_tab(i).task_id,
            -- task_id
             p_invoice_lines_tab(i).expenditure_type,
            -- expenditure_type
             p_invoice_lines_tab(i).expenditure_item_date,
            -- expenditure_item_date
             p_invoice_lines_tab(i).expenditure_organization_id,
            -- expenditure_organization_id
             p_invoice_lines_tab(i).pa_quantity,
            -- pa_quantity
             p_invoice_lines_tab(i).pa_cc_ar_invoice_id,
            -- pa_cc_ar_invoice_id
             p_invoice_lines_tab(i).pa_cc_ar_invoice_line_num,
            -- pa_cc_ar_invoice_line_num
         p_invoice_lines_tab(i).pa_cc_processed_code,
        -- pa_cc_processed_code
             p_invoice_lines_tab(i).award_id,
            -- award_id
             p_invoice_lines_tab(i).awt_group_id,
            -- awt_group_id
              p_invoice_lines_tab(i).pay_awt_group_id,
            -- pay_awt_group_id --bug6639866
         p_invoice_lines_tab(i).reference_1,
        -- reference_1
         p_invoice_lines_tab(i).reference_2,
        -- reference_2
             NULL,  -- receipt_verified_flag
             NULL,  -- receipt_required_flag
             NULL,  -- receipt_missing_flag
             p_invoice_lines_tab(i).justification,  -- justification				--Bug6167068 Populated the colum values from AP_lines_interface rather than putting only NULL vaules
             p_invoice_lines_tab(i).expense_group,  -- expense_group				--Bug6167068
             p_invoice_lines_tab(i).expense_start_date, --NULL,  -- expense_start_date -- bug 8658097
             p_invoice_lines_tab(i).expense_end_date, --NULL,  -- expense_end_date	--bug 8658097
             p_invoice_lines_tab(i).receipt_currency_code,  -- receipt_currency_code		--Bug6167068
             p_invoice_lines_tab(i).receipt_conversion_rate,  -- receipt_conversion_rate	--Bug6167068
             p_invoice_lines_tab(i).receipt_currency_amount,  -- receipt_currency_amount	--Bug6167068
             NULL,  -- daily_amount
             NULL,  -- web_parameter_id
             NULL,  -- adjustment_reason
             p_invoice_lines_tab(i).merchant_document_number,  -- merchant_document_number	--Bug6167068
             p_invoice_lines_tab(i).merchant_name,  -- merchant_name				--Bug6167068
             p_invoice_lines_tab(i).merchant_reference,  -- merchant_reference			--Bug6167068
             p_invoice_lines_tab(i).merchant_tax_reg_number,  -- merchant_tax_reg_number	--Bug6167068
             p_invoice_lines_tab(i).merchant_taxpayer_id,  -- merchant_taxpayer_id		--Bug6167068
             p_invoice_lines_tab(i).country_of_supply,  -- country_of_supply			--Bug6167068
             p_invoice_lines_tab(i).credit_card_trx_id,
        -- credit_card_trx_id
             p_invoice_lines_tab(i).company_prepaid_invoice_id,  -- company_prepaid_invoice_id	--Bug6167068
             p_invoice_lines_tab(i).cc_reversal_flag,  -- cc_reversal_flag			--Bug6167068
         AP_IMPORT_INVOICES_PKG.g_inv_sysdate,
        -- creation_date
         p_default_last_updated_by,
        -- created_by
         p_default_last_updated_by,
        -- last_updated_by
             AP_IMPORT_INVOICES_PKG.g_inv_sysdate,
            -- last_update_date
         p_default_last_update_login,
        -- last_update_login
         AP_IMPORT_INVOICES_PKG.g_program_application_id,
        -- program_application_id
         AP_IMPORT_INVOICES_PKG.g_program_id,
        -- program_id
         AP_IMPORT_INVOICES_PKG.g_inv_sysdate,
        -- program_update_date
         AP_IMPORT_INVOICES_PKG.g_conc_request_id,
        -- request_id
             p_invoice_lines_tab(i).attribute_category,
            -- attribute_category
             p_invoice_lines_tab(i).attribute1,
            -- attribute1
             p_invoice_lines_tab(i).attribute2,
            -- attribute2
             p_invoice_lines_tab(i).attribute3,
            -- attribute3
             p_invoice_lines_tab(i).attribute4,
            -- attribute4
             p_invoice_lines_tab(i).attribute5,
            -- attribute5
             p_invoice_lines_tab(i).attribute6,
            -- attribute6
             p_invoice_lines_tab(i).attribute7,
            -- attribute7
             p_invoice_lines_tab(i).attribute8,
            -- attribute8
             p_invoice_lines_tab(i).attribute9,
            -- attribute9
             p_invoice_lines_tab(i).attribute10,
            -- attribute10
             p_invoice_lines_tab(i).attribute11,
            -- attribute11
             p_invoice_lines_tab(i).attribute12,
            -- attribute12
             p_invoice_lines_tab(i).attribute13,
            -- attribute13
             p_invoice_lines_tab(i).attribute14,
            -- attribute14
             p_invoice_lines_tab(i).attribute15,
            -- attribute15
             p_invoice_lines_tab(i).global_attribute_category,
            -- global_attribute_category
             p_invoice_lines_tab(i).global_attribute1,
            -- global_attribute1
             p_invoice_lines_tab(i).global_attribute2,
            -- global_attribute2
             p_invoice_lines_tab(i).global_attribute3,
            -- global_attribute3
             p_invoice_lines_tab(i).global_attribute4,
            -- global_attribute4
             p_invoice_lines_tab(i).global_attribute5,
            -- global_attribute5
             p_invoice_lines_tab(i).global_attribute6,
            -- global_attribute6
             p_invoice_lines_tab(i).global_attribute7,
            -- global_attribute7
             p_invoice_lines_tab(i).global_attribute8,
            -- global_attribute8
             p_invoice_lines_tab(i).global_attribute9,
            -- global_attribute9
             p_invoice_lines_tab(i).global_attribute10,
            -- global_attribute10
             p_invoice_lines_tab(i).global_attribute11,
            -- global_attribute11
             p_invoice_lines_tab(i).global_attribute12,
            -- global_attribute12
             p_invoice_lines_tab(i).global_attribute13,
            -- global_attribute13
             p_invoice_lines_tab(i).global_attribute14,
            -- global_attribute14
             p_invoice_lines_tab(i).global_attribute15,
            -- global_attribute15
             p_invoice_lines_tab(i).global_attribute16,
            -- global_attribute16
             p_invoice_lines_tab(i).global_attribute17,
            -- global_attribute17
             p_invoice_lines_tab(i).global_attribute18,
            -- global_attribute18
             p_invoice_lines_tab(i).global_attribute19,
            -- global_attribute19
             p_invoice_lines_tab(i).global_attribute20,
            -- global_attribute20
             p_invoice_lines_tab(i).control_amount,
            -- control_amount
             p_invoice_lines_tab(i).assessable_value,
            -- assessable_value
             p_invoice_lines_tab(i).primary_intended_use,
            -- primary_intended_use
             nvl(p_invoice_lines_tab(i).ship_to_location_id, l_ship_to_location_id),
            -- ship_to_location_id
             p_invoice_lines_tab(i).product_type,
            -- product_type
             p_invoice_lines_tab(i).product_category,
            -- product_category
             p_invoice_lines_tab(i).product_fisc_classification,
            -- product_fisc_classification
             p_invoice_lines_tab(i).user_defined_fisc_class,
            -- user_defined_fisc_class
             p_invoice_lines_tab(i).trx_business_category,
	    -- application_id
	     p_invoice_lines_tab(i).application_id,
            -- product_table
	     p_invoice_lines_tab(i).product_table,
            -- reference_key1
	     p_invoice_lines_tab(i).reference_key1,
            -- reference_key2
	     p_invoice_lines_tab(i).reference_key2,
            -- reference_key3
	     p_invoice_lines_tab(i).reference_key3,
            -- reference_key4
	     p_invoice_lines_tab(i).reference_key4,
            -- reference_key5
	     p_invoice_lines_tab(i).reference_key5,
	    -- purchasing_category_id
	     p_invoice_lines_tab(i).purchasing_category_id,
	    -- cost_factor_id
	     p_invoice_lines_tab(i).cost_factor_id,
	     -- source_application_id
	     p_invoice_lines_tab(i).source_application_id,
	     -- source_entity_code
	     p_invoice_lines_tab(i).source_entity_code,
	     --source_event_class_code
	     p_invoice_lines_tab(i).source_event_class_code,
	     --source_trx_id
	     p_invoice_lines_tab(i).source_trx_id,
	     --source_line_id
	     p_invoice_lines_tab(i).source_line_id,
	     --source_trx_level_type
	     p_invoice_lines_tab(i).source_trx_level_type,
	     --tax_classification_code
	     p_invoice_lines_tab(i).tax_classification_code,
	     --retained_amount
	     p_invoice_lines_tab(i).retained_amount,
	     --retained_amount_remaining
	     (-p_invoice_lines_tab(i).retained_amount),
             --tax_regime_code
             p_invoice_lines_tab(i).tax_regime_code,
             --tax
             p_invoice_lines_tab(i).tax,
             --tax_jurisdiction_code
             p_invoice_lines_tab(i).tax_jurisdiction_code,
             --tax_status_code
             p_invoice_lines_tab(i).tax_status_code,
             --tax_rate_id
             p_invoice_lines_tab(i).tax_rate_id,
             --tax_rate_code
             p_invoice_lines_tab(i).tax_rate_code,
             --tax_rate
             p_invoice_lines_tab(i).tax_rate);

             --        END IF;    Commented for bug 6010950

      END LOOP;
    End; -- end of insert

  RETURN( TRUE );
EXCEPTION
  WHEN OTHERS THEN
    debug_info := debug_info || '->exception';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END insert_ap_invoice_lines;

/*=========================================================================*/
/*                                                                         */
/* Private Function  Create_Lines                                          */
/* Program Flow:                                                           */
/*   1. Insert interface lines data into transaction lines table           */
/*   2. Allocate base amount rounding for lines inserted into transaction  */
/*      table                                                              */
/*   3. Loop through lines and either match to PO/RCV, produce price       */
/*      correction or create allocation rules.                             */
/* Parameters:                                                             */
/*                                                                         */
/*   p_batch_id                                                            */
/*   p_base_invoice_id                                                     */
/*   p_invoice_lines_tab                                                   */
/*   p_base_currency_code                                                  */
/*   p_set_of_books_id                                                     */
/*   p_chart_of_accounts_id                                                */
/*   p_default_last_updated_by                                             */
/*   p_default_last_update_login                                           */
/*   p_calling_sequence                                                    */
/*                                                                         */
/*=========================================================================*/

FUNCTION Create_Lines(
          p_batch_id                    IN            NUMBER,
          p_base_invoice_id             IN            NUMBER,
          p_invoice_lines_tab           IN
                 AP_IMPORT_INVOICES_PKG.t_lines_table,
          p_base_currency_code          IN            VARCHAR2,
          p_set_of_books_id             IN            NUMBER,
          p_approval_workflow_flag      IN            VARCHAR2,
          p_tax_only_flag               IN            VARCHAR2,
          p_tax_only_rcv_matched_flag   IN            VARCHAR2,
          p_default_last_updated_by     IN            NUMBER,
          p_default_last_update_login   IN            NUMBER,
          p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  create_lines_failure        EXCEPTION;
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(500);
  l_debug_context             VARCHAR2(1000);
  l_round_amt_exist           BOOLEAN := FALSE;
  l_rounded_line_num          NUMBER;
  l_rounded_amt               NUMBER := 0;
  l_error_code                VARCHAR2(30);
  i                           BINARY_INTEGER := 0;
  l_overbill_flag	      VARCHAR2(1) := 'N';
  l_quantity_outstanding      NUMBER;
  l_quantity_ordered          NUMBER;
  l_qty_already_billed	      NUMBER;
  l_amount_outstanding        NUMBER;
  l_amount_ordered            NUMBER;
  l_amt_already_billed        NUMBER;

  l_modified_line_rounding_amt   NUMBER; --6892789
  l_base_amt                     NUMBER; --6892789
  l_round_inv_line_numbers       AP_INVOICES_UTILITY_PKG.inv_line_num_tab_type; --6892789

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'Create_lines<-'||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 1
  -- Call API that Bulk insert invoice lines regardless of line type.
  --------------------------------------------------------------------------

  debug_info := '(Create lines 1) Call API to Insert all the lines ';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF ( insert_ap_invoice_lines(
          p_base_invoice_id           => p_base_invoice_id,
          p_invoice_lines_tab         => p_invoice_lines_tab,
          p_set_of_books_id           => p_set_of_books_id,
          p_approval_workflow_flag    => p_approval_workflow_flag,
          p_tax_only_flag             => p_tax_only_flag,
          p_tax_only_rcv_matched_flag => p_tax_only_rcv_matched_flag,
          p_default_last_updated_by   => p_default_last_updated_by,
          p_default_last_update_login => p_default_last_update_login,
          p_calling_sequence          => current_calling_sequence )<>TRUE) THEN

    debug_info := debug_info || 'exceptions';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      RAISE create_lines_failure;
    END IF;
  END IF;

  --------------------------------------------------------------------------
  -- Step 2
  -- Call API to do base amount rounding for x_base_invoice_id in
  -- ap_invoice_lines core transaction table
  --------------------------------------------------------------------------

  debug_info := '(Create lines 2) Call Utility function to round the line '||
                ' before create distributions';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

    /* modifying following code as per the bug 6892789 as there is a chance
     that line base amt goes to -ve value (line amount being +ve) so in such
     case, adjust line base amount upto zero and adjust the remaing amount in
     another line having next max amount */

  -- get the lines which can be adjusted
    l_round_amt_exist := AP_INVOICES_UTILITY_PKG.round_base_amts(
                           X_Invoice_Id           => p_base_invoice_id,
                           X_Reporting_Ledger_Id  => NULL,
                           X_Rounded_Line_Numbers => l_round_inv_line_numbers,
                           X_Rounded_Amt          => l_rounded_amt,
                           X_Debug_Info           => debug_info,
                           X_Debug_Context        => l_debug_context,
                           X_Calling_sequence     => current_calling_sequence);

    -- adjustment required and there exist line numbers that can be adjusted
    IF ( l_round_amt_exist  AND l_round_inv_line_numbers.count > 0 ) THEN
    -- iterate throgh lines until there is no need to adjust
      for i in 1 .. l_round_inv_line_numbers.count
      loop
        IF l_rounded_amt <> 0 THEN
        -- get the existing base amount for the selected line
          select base_amount
          INTO   l_base_amt
          FROM   AP_INVOICE_LINES
          WHERE  invoice_id = p_base_invoice_id
          AND    line_number = l_round_inv_line_numbers(i);

         -- get the calculated adjusted base amount and rounding amount
         -- get rounding amount for the next line if required
         l_base_amt := AP_APPROVAL_PKG.get_adjusted_base_amount(
                                p_base_amount => l_base_amt,
                                p_rounding_amt => l_modified_line_rounding_amt,
                                p_next_line_rounding_amt => l_rounded_amt);

         -- update the calculatd base amount, rounding amount
          UPDATE AP_INVOICE_LINES
          SET    base_amount = l_base_amt,
                 rounding_amt = ABS( NVL(l_modified_line_rounding_amt, 0) ),
                 last_update_date = SYSDATE,
                 last_updated_by = FND_GLOBAL.user_id,
                 last_update_login = FND_GLOBAL.login_id
          WHERE  invoice_id = p_base_invoice_id
          AND    line_number = l_round_inv_line_numbers(i);
        ELSE
        -- adjustment not required or there are no lines that can be adjusted
         EXIT;
        END IF;
      end loop;

  END IF;

  --------------------------------------------------------------------------
  -- Step 3
  -- Loop through lines and call matching package if line is to be matched
  -- or call allocations package if allocation rule/lines need to be created
  --------------------------------------------------------------------------
  debug_info := '(Create lines 3) Call Matching or Allocations';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  BEGIN

    FOR i IN p_invoice_lines_tab.FIRST..p_invoice_lines_tab.LAST LOOP

     IF (p_invoice_lines_tab(i).line_type_lookup_code = 'ITEM') THEN

       IF (p_invoice_lines_tab(i).po_line_location_id IS NOT NULL) THEN
	  debug_info := '(Create Lines 3.1) Check for quantity overbill '
                        ||'for PO Shipment';

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.get_overbill_for_shipment(
                p_invoice_lines_tab(i).po_line_location_id,    -- IN
                p_invoice_lines_tab(i).quantity_invoiced,      -- IN
		p_invoice_lines_tab(i).amount,		       -- IN
                l_overbill_flag,                    -- OUT NOCOPY
                l_quantity_outstanding,             -- OUT NOCOPY
                l_quantity_ordered,                 -- OUT NOCOPY
                l_qty_already_billed,               -- OUT NOCOPY
		l_amount_outstanding,               -- OUT NOCOPY
		l_amount_ordered,                   -- OUT NOCOPY
		l_amt_already_billed,               -- OUT NOCOPY
                current_calling_sequence) <> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'get_overbill_for_shipment<-'||current_calling_sequence);
            END IF;
            RAISE create_lines_failure;
          END IF;

        END IF;

	debug_info := '(Create lines 4) Calling Matching API';

	ap_matching_utils_pkg.match_invoice_line(
				P_Invoice_Id => p_base_invoice_id,
				P_Invoice_Line_Number => p_invoice_lines_tab(i).line_number,
				P_Overbill_Flag => l_overbill_flag,
				P_Calling_Sequence => current_calling_sequence);

     ELSIF (p_invoice_lines_tab(i).line_type_lookup_code <> 'ITEM' AND
            NVL(p_invoice_lines_tab(i).prorate_across_flag, 'N') = 'Y' AND
            p_invoice_lines_tab(i).line_group_number IS NULL) THEN

          IF (NOT (ap_allocation_rules_pkg.insert_fully_prorated_rule(
		                     p_base_invoice_id,
                                     p_invoice_lines_tab(i).line_number,
		                     l_error_code))) THEN

             debug_info := '(Create lines 5) Error encountered: '||l_error_code;
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
             END IF;
             RETURN(FALSE);

          END IF;

       ELSIF (p_invoice_lines_tab(i).line_type_lookup_code <> 'ITEM' AND
              NVL(p_invoice_lines_tab(i).prorate_across_flag, 'N') = 'Y' AND
              p_invoice_lines_tab(i).line_group_number IS NOT NULL) THEN

          IF (NOT (ap_allocation_rules_pkg.insert_from_line_group_number(
      				             p_base_invoice_id,
                                	     p_invoice_lines_tab(i).line_number,
			                     l_error_code))) THEN

	      debug_info := '(Create lines 6) Error encountered: '||l_error_code;

	      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
	            Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
	      END IF;

	      RETURN(FALSE);
	  END IF;

      END IF;

    END LOOP;

  END;

  RETURN( TRUE );
EXCEPTION
  WHEN OTHERS THEN

    debug_info := debug_info || '->exception';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        Print( AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN (FALSE);
END Create_lines;

FUNCTION insert_holds(
          p_base_invoice_id             IN            NUMBER,
          p_hold_code                   IN            VARCHAR2,
          p_hold_reason                 IN            VARCHAR2,
          p_hold_future_payments_flag   IN            VARCHAR2,
          p_supplier_hold_reason        IN            VARCHAR2,
          p_invoice_amount_limit        IN            NUMBER,
          p_invoice_base_amount         IN            NUMBER,
          p_last_updated_by             IN            NUMBER,
          P_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN
IS
  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(500);

BEGIN
  -- Update the calling sequence

  current_calling_sequence := 'insert_holds<-'||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 1
  -- Insert invoice holds FROM the import batch
  --------------------------------------------------------------------------

  debug_info := '(Insert Holds 1)  Insert invoice holds FROM the import batch';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  IF (p_hold_code is NOT NULL) THEN
    ap_holds_pkg.insert_single_hold(
          X_invoice_id          =>p_base_invoice_id,
          X_hold_lookup_code    =>p_hold_code,
          X_hold_type           =>'INVOICE HOLD REASON',
          X_hold_reason         =>p_hold_reason,
          X_held_by             =>p_last_updated_by,
          X_calling_sequence    =>current_calling_sequence);
  END IF;

  ---------------------------------------------------------------------------
  -- Step 2
  -- Insert Suppler's holds
  ---------------------------------------------------------------------------

  debug_info := '(Insert Holds 2) Insert Suppler holds';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  iF (NVL(p_hold_future_payments_flag,'N') = 'Y') THEN
     ap_holds_pkg.insert_single_hold(
          X_invoice_id          =>p_base_invoice_id,
          --Bug 7448784 Changed 'Vendor' to 'VENDOR'
          X_hold_lookup_code    =>'VENDOR',
          X_hold_type           =>'INVOICE HOLD REASON',
          X_hold_reason         =>p_supplier_hold_reason,
          X_held_by             =>5,
          X_calling_sequence    =>current_calling_sequence);
  END IF;

  IF (p_invoice_base_amount > p_invoice_amount_limit) THEN

    --------------------------------------------------------------------------
    -- Step 3
    -- Insert Hold IF invoice_base_amount > invoice_amount_limit
    --------------------------------------------------------------------------
    debug_info := '(Insert Holds 3) Insert Hold IF invoice_base_amount > '||
                  'invoice_amount_limit';
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    ap_holds_pkg.insert_single_hold(
          X_invoice_id                      =>p_base_invoice_id,
          X_hold_lookup_code                =>'AMOUNT',
          X_hold_type                       =>'INVOICE HOLD REASON',
          X_hold_reason                     =>p_supplier_hold_reason,
          X_held_by                         =>5,
          X_calling_sequence                =>current_calling_sequence);
   END IF;

   RETURN(TRUE);

EXCEPTION
 WHEN OTHERS THEN
    IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN (FALSE);

END insert_holds;

/*=========================================================================*/
/*                                                                         */
/* Function  Get_tax_only_rcv_matched_flag                                 */
/*  This function is used to determine if the invoice is a tax only and if */
/*  the existing tax lines are rcv matched and no tax information is       */
/*  populated for the lines.                                               */
/*                                                                         */
/* Parameters                                                              */
/*    p_invoice_id                                                         */
/*                                                                         */
/*=========================================================================*/

FUNCTION get_tax_only_rcv_matched_flag(
  P_invoice_id             IN NUMBER) RETURN VARCHAR2

IS

  l_tax_only_rcv_matched_flag   VARCHAR2(1);

BEGIN

  --------------------------------------------------------------------------
  -- Select Y if invoice is tax only and tax lines are RCV matched and no
  -- tax line has tax info populated
  --------------------------------------------------------------------------

  IF (p_invoice_id IS NOT NULL) THEN

    BEGIN
      SELECT 'N'
        INTO l_tax_only_rcv_matched_flag
        FROM ap_invoice_lines_interface
       WHERE invoice_id = p_invoice_id
         AND (line_type_lookup_code <> 'TAX' OR
             (line_type_lookup_code = 'TAX' AND
              rcv_transaction_id IS NULL AND
              (tax_regime_code IS NOT NULL OR
               tax IS NOT NULL OR
               tax_jurisdiction_code IS NOT NULL OR
               tax_status_code IS NOT NULL OR
               tax_rate_id IS NOT NULL OR
               tax_rate_code IS NOT NULL OR
               tax_rate IS NOT NULL OR
               incl_in_taxable_line_flag IS NOT NULL OR
               tax_classification_code is not null)))  --bug6255826
         AND ROWNUM = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_tax_only_rcv_matched_flag := 'Y';
    END;

  END IF;

  RETURN l_tax_only_rcv_matched_flag;

END get_tax_only_rcv_matched_flag;

/*=========================================================================*/
/*                                                                         */
/* Function  Get_tax_only_flag                                             */
/*  This function is used to determine if the invoice is a tax only one    */
/*  This flag will be used by the eTax validate_default_import API to      */
/*  determine how the global temporary tables for the tax lines should be  */
/*  populated.                                                             */
/*                                                                         */
/* Parameters                                                              */
/*    p_invoice_id                                                         */
/*                                                                         */
/*=========================================================================*/

FUNCTION get_tax_only_flag(
  P_invoice_id             IN NUMBER) RETURN VARCHAR2

IS

  l_tax_only_flag   VARCHAR2(1);

BEGIN

  --------------------------------------------------------------------------
  -- Select Y if invoice is tax only
  --------------------------------------------------------------------------
  IF (p_invoice_id IS NOT NULL) THEN

    BEGIN
      SELECT 'N'
        INTO l_tax_only_flag
        FROM ap_invoice_lines_interface
       WHERE invoice_id = p_invoice_id
         AND line_type_lookup_code <> 'TAX'
         AND ROWNUM = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_tax_only_flag := 'Y';
    END;
  END IF;

  RETURN l_tax_only_flag;

END get_tax_only_flag;

/*  5039042. Function for Checking if Distribution Generation Event is rgeistered for the
   source application */
FUNCTION Is_Product_Registered(P_Application_Id      IN         NUMBER,
                               X_Registration_Api    OUT NOCOPY VARCHAR2,
                               X_Registration_View   OUT NOCOPY VARCHAR2,
                               P_Calling_Sequence    IN         VARCHAR2)
  RETURN BOOLEAN IS

  l_debug_info VARCHAR2(1000);
  l_curr_calling_sequence VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'Is_Product_Registered <-'||p_calling_sequence;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_curr_calling_sequence);
  END IF;

  l_debug_info := 'Check if the other application is registered for Distribution Generation';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;


  BEGIN

     SELECT registration_api,
            registration_view
     INTO x_registration_api,
          x_registration_view
     FROM ap_product_registrations
     WHERE application_id = 200
     AND reg_application_id = p_application_id
     AND registration_event_type = 'DISTRIBUTION_GENERATION';

  EXCEPTION WHEN NO_DATA_FOUND THEN
     x_registration_view := NULL;
     x_registration_api := NULL;
     RETURN(FALSE);
  END;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                         '  Application Id  = '    || to_char(P_Application_Id) );
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Is_Product_Registered;

-- Bug 5448579. This function will be used for caching org_id, name
FUNCTION Cache_Org_Id_Name (
          P_Moac_Org_Table     OUT NOCOPY   AP_IMPORT_INVOICES_PKG.moac_ou_tab_type,
          P_Fsp_Org_Table      OUT NOCOPY   AP_IMPORT_INVOICES_PKG.fsp_org_tab_type,
          P_Calling_Sequence    IN   VARCHAR2 )

  RETURN BOOLEAN IS

  CURSOR moac_org  IS
  SELECT organization_id,
         mo_global.get_ou_name(organization_id)
  FROM Mo_Glob_Org_Access_Tmp;

  CURSOR fsp_org IS
  SELECT org_id
  FROM Financials_System_Parameters;

  l_debug_info    VARCHAR2(1000);
  l_curr_calling_sequence  VARCHAR2(2000);


BEGIN

  l_curr_calling_sequence := 'Cache_Org_Id_Name <- '||P_calling_sequence;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_curr_calling_sequence);
  END IF;

  l_debug_info := 'Caching Org_id , Name from MO: Security Profile';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  OPEN moac_org;
    FETCH  moac_org
    BULK COLLECT INTO  P_Moac_Org_Table;
  CLOSE moac_org;

  l_debug_info := 'Caching Org_id  from Financials Systems';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  OPEN fsp_org;
    FETCH  fsp_org
    BULK COLLECT INTO  P_Fsp_Org_Table;
  CLOSE fsp_org;


  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Cache_Org_Id_Name;

-- Bug 5448579. This function will be used for checking term claendar based on terms_id
PROCEDURE Check_For_Calendar_Term
             (p_terms_id          IN       number,
              p_terms_date        IN       date,
              p_no_cal            IN OUT NOCOPY  varchar2,
              p_calling_sequence  IN       varchar2) IS

CURSOR c IS
  SELECT calendar
  FROM   ap_terms,
         ap_terms_lines
  WHERE  ap_terms.term_id = ap_terms_lines.term_id
  AND    ap_terms.term_id = p_terms_id
  AND    ap_terms_lines.calendar is not null;

l_calendar               VARCHAR2(30);
l_cal_exists             VARCHAR2(1);
l_debug_info             VARCHAR2(100);
l_curr_calling_sequence  VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  l_curr_calling_sequence :=
  'AP_IMPORT_UTILITIES_PKG.Check_For_Calendar_Term<-'||p_calling_sequence;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_curr_calling_sequence);
  END IF;

  --------------------------------------------------------
  l_debug_info := 'OPEN  cursor c';
  --------------------------------------------------------
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  l_cal_exists := '';
  OPEN c;

  LOOP
     --------------------------------------------------------
     l_debug_info := 'Fetch cursor C';
     --------------------------------------------------------
     IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
     AP_IMPORT_UTILITIES_PKG.Print(
       AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
     END IF;

     FETCH c INTO l_calendar;
     EXIT WHEN c%NOTFOUND;

     --------------------------------------------------------
     l_debug_info := 'Check for calendar';
     --------------------------------------------------------
     IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
     AP_IMPORT_UTILITIES_PKG.Print(
       AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
     END IF;

     BEGIN

       -- Bug1769230 Added truncate function to eliminate time part
       -- from p_terms_date variable.
       SELECT 'Y'
       INTO   l_cal_exists
       FROM   ap_other_periods aop,
              ap_other_period_types aopt
       WHERE  aopt.period_type = l_calendar
       AND    aopt.module = 'PAYMENT TERMS'
       AND    aopt.module = aop.module -- bug 2902681
       AND    aopt.period_type = aop.period_type
       AND    aop.start_date <= trunc(p_terms_date)
       AND    aop.end_date >= trunc(p_terms_date);
     EXCEPTION
       WHEN NO_DATA_FOUND then
         null;
     END;

     if (l_cal_exists <> 'Y') or (l_cal_exists is null) then
         p_no_cal := 'Y';
         return;
     end if;

  END LOOP;
  --------------------------------------------------------
  l_debug_info := 'CLOSE  cursor c';
  --------------------------------------------------------
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  CLOSE c;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                    'Payment Terms = '|| p_terms_id
                 ||' Terms date = '||to_char(p_terms_date));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Check_For_Calendar_Term;

-- Bug 5448579. This function will be used for caching Pay Group
FUNCTION Cache_Pay_Group (
         P_Pay_Group_Table    OUT NOCOPY  AP_IMPORT_INVOICES_PKG.pay_group_tab_type,
         P_Calling_Sequence   IN    VARCHAR2)
RETURN BOOLEAN IS

  CURSOR pay_group  IS
  SELECT lookup_code
  FROM po_lookup_codes
  WHERE lookup_type = 'PAY GROUP'
  AND DECODE(SIGN(NVL(inactive_date,
               AP_IMPORT_INVOICES_PKG.g_inv_sysdate) -
               AP_IMPORT_INVOICES_PKG.g_inv_sysdate),
               -1,'','*') = '*';

  l_debug_info    VARCHAR2(1000);
  l_curr_calling_sequence  VARCHAR2(2000);


BEGIN

  l_curr_calling_sequence := 'Cache_Pay_group <- '||P_calling_sequence;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_curr_calling_sequence);
  END IF;

  l_debug_info := 'Caching Pay Group from PO Lookup Codes';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  OPEN pay_group;
    FETCH pay_group
    BULK COLLECT INTO  P_Pay_Group_Table;
  CLOSE pay_group;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Cache_Pay_Group;

-- Bug 5448579. This function will be used for caching Payment Method from IBY
FUNCTION Cache_Payment_Method (
         P_Payment_Method_Table    OUT NOCOPY AP_IMPORT_INVOICES_PKG.payment_method_tab_type,
         P_Calling_Sequence        IN    VARCHAR2)
RETURN BOOLEAN IS

  CURSOR payment_method  IS
  SELECT payment_method_code
  FROM IBY_PAYMENT_METHODS_VL;

  l_debug_info    VARCHAR2(1000);
  l_curr_calling_sequence  VARCHAR2(2000);


BEGIN

  l_curr_calling_sequence := 'Cache_Payment_Method <- '||P_calling_sequence;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_curr_calling_sequence);
  END IF;

  l_debug_info := 'Caching Payment Method from IBY';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  OPEN payment_method;
    FETCH payment_method
    BULK COLLECT INTO  P_Payment_Method_Table;
  CLOSE payment_method;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Cache_Payment_Method;

FUNCTION Cache_Fnd_Currency (
         P_Fnd_Currency_Table    OUT NOCOPY  AP_IMPORT_INVOICES_PKG.fnd_currency_tab_type,
         P_Calling_Sequence      IN   VARCHAR2)
RETURN BOOLEAN IS

  CURSOR currency_code_cur  IS
  SELECT currency_code,
         start_date_active,
         end_date_active,
         minimum_accountable_unit,
         precision,
         enabled_flag
  FROM fnd_currencies;

  l_debug_info    VARCHAR2(1000);
  l_curr_calling_sequence  VARCHAR2(2000);


BEGIN

  l_curr_calling_sequence := 'Cache_Fnd_Currency <- '||P_calling_sequence;
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_curr_calling_sequence);
  END IF;

  l_debug_info := 'Caching Currency from Fnd Currency';
  IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,l_debug_info);
  END IF;

  OPEN currency_code_cur;
    FETCH currency_code_cur
    BULK COLLECT INTO  P_Fnd_Currency_Table;
  CLOSE currency_code_cur;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS then
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

END Cache_Fnd_Currency;

END AP_IMPORT_UTILITIES_PKG;

/
