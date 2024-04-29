--------------------------------------------------------
--  DDL for Package Body PO_RFQS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RFQS_SV" as
/* $Header: POXSORFB.pls 120.0.12000000.3 2007/10/11 13:50:58 ppadilam ship $ */

/*=============================  PO_RFQS_SV  ===============================*/

/*===========================================================================

  PROCEDURE NAME:	test_val_header_delete()

===========================================================================*/

PROCEDURE test_val_header_delete(X_po_header_id	  IN	NUMBER) IS

X_allow_delete		BOOLEAN;

BEGIN

  -- dbms_output.put_line('Before_call');

  po_rfqs_sv.val_header_delete(X_po_header_id, X_allow_delete);

  -- dbms_output.put_line('After call');


END test_val_header_delete;

/*===========================================================================

  PROCEDURE NAME:	val_header_delete()

===========================================================================*/

PROCEDURE val_header_delete(X_po_header_id	  IN	    NUMBER,
			    X_allow_delete	  IN OUT NOCOPY    BOOLEAN) IS

x_progress 		VARCHAR2(3) := '';
x_delete_test		VARCHAR2(1) := 'Y';

BEGIN
  x_progress := '010';

  /*
  ** Check to see if the RFQ header has been printed
  **   if it has NOT, allow deletion.
  **   if it has, display message and prevent deletion.
  */
  SELECT MAX('N')
  INTO   X_delete_test
  FROM   po_rfq_vendors
  WHERE  printed_date is not null
  AND    po_header_id = X_po_header_id;

  x_progress := '020';

  IF (nvl(X_delete_test,'Y') = 'Y') THEN
      x_progress := '030';

      /*
      ** Check to see if RFQ is referenced on a Quotation
      **   if it is NOT, allow deletion.
      **   if it is, display message and prevent deletion.
      */
      SELECT MAX('N')
      INTO   X_delete_test
      FROM   po_headers poh
      WHERE  from_header_id = X_po_header_id;

      x_progress := '040';

      IF (nvl(X_delete_test,'Y') ='Y') THEN
          X_allow_delete := TRUE;
      ELSE
          X_allow_delete := FALSE;
          po_message_s.app_error('PO_RFQ_QT_DELETE_NA');
      END IF;

  ELSE
      X_allow_delete := FALSE;
      po_message_s.app_error('PO_RFQ_DELETE_PRINT_RFQ_NA');
  END IF;

  --dbms_output.put_line('Allow delete = '||X_delete_test);

EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In VAL exception');
    po_message_s.sql_error('val_header_delete', x_progress, sqlcode);

END val_header_delete;

/*===========================================================================

  PROCEDURE NAME:	test_val_line_delete()

===========================================================================*/

PROCEDURE test_val_line_delete(X_po_line_id	  IN	NUMBER,
			       X_po_header_id	  IN	NUMBER) IS

X_allow_delete		VARCHAR2(1) := '';

BEGIN

  -- dbms_output.put_line('Before_call');

  po_rfqs_sv.val_line_delete(X_po_line_id, X_po_header_id, X_allow_delete);

  -- dbms_output.put_line('After call');
  -- dbms_output.put_line('Allow Delete = '||X_allow_delete);

END test_val_line_delete;

/*===========================================================================

  PROCEDURE NAME:	val_line_delete()

===========================================================================*/

PROCEDURE val_line_delete(X_po_line_id	  	  IN	   NUMBER,
			  X_po_header_id	  IN	   NUMBER,
			  X_allow_delete	  IN OUT NOCOPY   VARCHAR2) IS

x_progress 		VARCHAR2(3) := '';
x_fetched_line_id	NUMBER	    := '';

CURSOR C is
 	SELECT 	pol.po_line_id
	FROM	po_lines pol
	WHERE  	pol.from_header_id = X_po_header_id
	AND    	pol.from_line_id = X_po_line_id;

BEGIN

  -- dbms_output.put_line('Before open cursor');

  x_progress := '010';
  OPEN C;
  x_progress := '020';

  FETCH C into x_fetched_line_id;

  /*
  ** Check to see if the RFQ line is used on a quotation
  **   if it is NOT, allow deletion.
  **   if it is, display message and prevent deletion.
  */
  IF C%NOTFOUND THEN
    X_allow_delete := 'Y';
    -- dbms_output.put_line('Allow delete = '||X_allow_delete);

  ELSE
    X_allow_delete := 'N';
    po_message_s.app_error('PO_RFQ_QT_DELETE_NA');
    -- dbms_output.put_line('Allow delete = '||X_allow_delete);

  END IF;

  CLOSE C;

EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In VAL exception');
    po_message_s.sql_error('val_line_delete', x_progress, sqlcode);

END val_line_delete;

/*===========================================================================

  FUNCTION NAME:	get_vendor_count

===========================================================================*/

 FUNCTION get_vendor_count
	(X_vendor_list_header_id  NUMBER) return number is

 x_vendor_count  NUMBER;
 X_Progress      varchar2(3) := '';

 BEGIN

  X_progress := '010';

/* Bug 875124 :
   Using po_vendor_list_entries_v to get the count
   as po_vendor_list_entries_v contains vendor_list with active vendors
*/
   SELECT count(*)
   INTO   X_vendor_count
   FROM   po_vendor_list_entries_v
   WHERE  vendor_list_header_id = X_vendor_list_header_id;

  X_progress := '020';

   return(x_vendor_count);

   EXCEPTION
   WHEN OTHERS THEN
      return(0);
      RAISE;

 END get_vendor_count;

/*===========================================================================

  FUNCTION NAME:	val_vendor_site()

===========================================================================*/

 FUNCTION val_vendor_site
		(X_po_header_id		IN	NUMBER,
		 X_vendor_id		IN	NUMBER,
		 X_vendor_site_id	IN	NUMBER,
		 X_row_id		IN	VARCHAR2) RETURN BOOLEAN is

 x_duplicate_vendor_site	varchar2(1)  := 'Y';
 X_Progress      		varchar2(3)  := '000';

 BEGIN

   X_progress := '010';

   SELECT MAX('N')
   INTO   X_duplicate_vendor_site
   FROM   po_rfq_vendors
   WHERE  po_header_id   = X_po_header_id
   AND    vendor_id      = X_vendor_id
   AND    vendor_site_id = X_vendor_site_id
   AND    (X_row_id IS NULL
          OR rowid <> X_row_id);

   X_progress := '020';

   if (nvl(X_duplicate_vendor_site,'Y') = 'Y') then
      return(TRUE);

   else
      po_message_s.app_error('PO_RFQ_VENDOR_ALREADY_EXISTS');
      return(FALSE);

   end if;

   EXCEPTION
   WHEN OTHERS THEN
      return(FALSE);
      po_message_s.sql_error('val_vendor_site', x_progress, sqlcode);
      RAISE;

 END val_vendor_site;


/*===========================================================================

  FUNCTION NAME:	val_vendor_update

===========================================================================*/

 FUNCTION val_vendor_update
		(X_po_header_id		IN	NUMBER,
		 X_vendor_id		IN	NUMBER,
		 X_vendor_site_id	IN	NUMBER) RETURN BOOLEAN is

 X_allow_update		varchar2(1)  := 'Y';
 X_Progress      	varchar2(3)  := '000';

 BEGIN

  X_progress := '010';

   SELECT MAX('N')
   INTO   X_allow_update
   FROM   po_headers
   WHERE  from_header_id = X_po_header_id
   AND    vendor_id = X_vendor_id
   AND    vendor_site_id = X_vendor_site_id
   AND    from_type_lookup_code = 'RFQ'
   AND    type_lookup_code = 'QUOTATION';


  X_progress := '020';

   if (nvl(X_allow_update,'Y') = 'Y') then
      return(TRUE);

   else
      po_message_s.app_error('PO_QUOTE_ENTERED_UPDATE_NA');
      return(FALSE);

   end if;

   EXCEPTION
   WHEN OTHERS THEN
      return(FALSE);
      po_message_s.sql_error('val_vendor_update', x_progress, sqlcode);
      RAISE;

 END val_vendor_update;

/*===========================================================================

  PROCEDURE NAME:	copy_vendor_list_to_rfq()

===========================================================================*/

PROCEDURE copy_vendor_list_to_rfq(X_rowid		IN OUT	NOCOPY VARCHAR2,
			  	  X_po_header_id	IN OUT	NOCOPY NUMBER,
				  X_max_sequence_num	IN	NUMBER,
				  X_last_update_date	IN	DATE,
				  X_last_updated_by	IN	NUMBER,
				  X_last_update_login	IN	NUMBER,
				  X_creation_date	IN	DATE,
				  X_created_by		IN	NUMBER,
				  X_list_header_id	IN	NUMBER,
           x_vendors_hold IN OUT NOCOPY VARCHAR2 ) IS

  CURSOR C IS SELECT rowid FROM PO_RFQ_VENDORS
               WHERE po_header_id = X_po_header_id
	         AND sequence_num = X_max_sequence_num + 1;

  CURSOR C2 IS SELECT po_headers_s.nextval FROM sys.dual;

/* Bug # 6161855 */
  l_list_header_id NUMBER := X_list_header_id;
  CURSOR C3  IS SELECT vendor_id FROM po_vendor_list_entries WHERE vendor_list_header_id= l_list_header_id ;
/*end of  Bug # 6161855*/

  x_progress 		VARCHAR2(3) := '';
  x_vendor_list_name	po_vendor_list_headers.vendor_list_name%type := null;

/* Bug # 6161855 */
  l_vendor_name  po_vendors.vendor_name%TYPE := NULL;
  myResult number;
  flagValue varchar2(1);
/*end of  Bug # 6161855*/

BEGIN

/* Bug # 6161855 */
  OPEN C3;
  LOOP
  FETCH C3 into myResult;
  EXIT WHEN C3%NOTFOUND;
     SELECT Nvl(hold_flag,'F'),vendor_name INTO flagValue, l_vendor_name  FROM po_vendors WHERE vendor_id=myResult;

  IF flagValue='Y' then
     x_vendors_hold:=x_vendors_hold ||', '|| l_vendor_name;
  END if;

  END LOOP;
  CLOSE C3;
/*end of  Bug # 6161855*/

  X_progress := '010';

      if (X_po_header_id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_po_header_id;
        CLOSE C2;
      end if;

  X_progress := '020';

/* Bug 875124 :
   Using po_vendor_list_entries_v to insert into po_rfq_vendors
   as po_vendor_list_entries_v contains vendor_list with active vendors
*/
      insert into po_rfq_vendors
            (po_header_id,
             sequence_num,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             vendor_id,
             vendor_site_id,
             vendor_contact_id,
             print_flag,
             print_count)
      select
             X_po_header_id,
             rownum + X_max_sequence_num,
             X_last_update_date,
             X_last_updated_by,
             X_last_update_login,
             X_creation_date,
             X_created_by,
             vle.vendor_id,
             vle.vendor_site_id,
             vle.vendor_contact_id,
             'Y',
             '0'
      from   po_vendor_list_entries_v vle
      where  vle.vendor_list_header_id = X_list_header_id
      and    not exists (select 'vendor already there'
                         from po_rfq_vendors rv
                         where vle.vendor_site_id = rv.vendor_site_id
                         and rv.po_header_id = X_po_header_id);

  X_progress := '030';

  OPEN C;
  FETCH C INTO X_rowid;
  if (C%NOTFOUND) then
    CLOSE C;

    select vendor_list_name
    into   x_vendor_list_name
    from   po_vendor_list_headers
    where  vendor_list_header_id = X_list_header_id;

    Raise NO_DATA_FOUND;
  end if;
  CLOSE C;

EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In VAL exception');

    -- Bug 430179  set message name and token here, and later retrieve it on the client side

    po_message_s.app_error('PO_COPY_SUPPLIERS_TO_RFQ','LIST',x_vendor_list_name);

END copy_vendor_list_to_rfq;

END PO_RFQS_SV;

/
