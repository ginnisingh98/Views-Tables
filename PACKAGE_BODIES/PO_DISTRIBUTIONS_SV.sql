--------------------------------------------------------
--  DDL for Package Body PO_DISTRIBUTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DISTRIBUTIONS_SV" AS
/* $Header: POXPOD1B.pls 120.4 2007/12/04 09:25:43 bisdas ship $ */

/*===========================================================================

  PROCEDURE NAME:	check_unique()

===========================================================================*/

FUNCTION check_unique(x_line_location_id NUMBER,
                      x_distribution_num NUMBER,
                      x_rowid            VARCHAR2) RETURN BOOLEAN IS

l_is_unique BOOLEAN;

x_progress VARCHAR2(3) := NULL;
x_dummy VARCHAR2(12) := NULL;

BEGIN
   x_progress := '001';

   -- bug3322899
   -- The sql statement to check for uniqueness has been moved
   -- to distribution_num_unique

   l_is_unique :=
       distribution_num_unique
       ( p_line_location_id => x_line_location_id,
         p_distribution_num => x_distribution_num,
         p_rowid            => x_rowid
       );

   IF (l_is_unique) THEN
       RETURN TRUE;
   ELSE
    --   po_message_s.app_error('PO_PO_ENTER_UNIQUE_DIST_NUM');
       RETURN(FALSE);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('In Exception');
      po_message_s.sql_error('check_unique', x_progress, sqlcode);
   RAISE;

END check_unique;

-- bug3322899 START


-----------------------------------------------------------------------
--Start of Comments
--Name: disribution_num_unique
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Return TRUE if the distribution number does not exist in the
--  Shipment being passed in. Return FALSE otherwise
--Parameters:
--IN:
--p_line_location_id
--  Line location id of the shipment
--p_distribution_num
--  Distribution Number being checked
--p_rowid
--  Rowid of the dsitribution being cheked. If provided, the record
--  with this ROWID will be excluded from being checked
--IN OUT:
--OUT:
--Returns: BOOLEAN that says whether the distribution number is unique
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION distribution_num_unique
( p_line_location_id IN NUMBER,
  p_distribution_num IN NUMBER,
  p_rowid            IN VARCHAR2
) RETURN BOOLEAN IS

  l_progress VARCHAR2(3);
  l_dummy    VARCHAR2(20);
BEGIN

    l_progress := '000';

    --SQL WHAT: Given line_location_id and distribution_num,
    --          check whether there is already a duplicate
    --SQL WHY:  To ensure that we do not insert multiple distributions
    --          with same distribution num for a shipment

    SELECT 'unique'
    INTO   l_dummy
    FROM   dual
    WHERE  NOT EXISTS
           ( SELECT 1
             FROM   po_distributions
             WHERE  line_location_id = p_line_location_id
             AND    distribution_num = p_distribution_num
             AND   (rowid              <> p_rowid
                    OR p_rowid IS NULL));

    RETURN TRUE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
WHEN OTHERS THEN
    PO_MESSAGE_S.sql_error('distribution_num_unique', l_progress, SQLCODE);
    RAISE;
END distribution_num_unique;
-- bug3322899 END


/*===========================================================================

  FUNCTION NAME:       get_max_dist_num()

===========================================================================*/

FUNCTION  get_max_dist_num(x_line_location_id NUMBER) RETURN NUMBER IS

x_progress VARCHAR2(3) := NULL;
max_dist_num NUMBER;

cursor C1 is
select nvl(max(distribution_num),0)
from   po_distributions
where  line_location_id = x_line_location_id;

BEGIN
   x_progress := '001';
   open C1;
   fetch C1 into max_dist_num;
   RETURN(max_dist_num);
   close C1;

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('get_max_dist_num', x_progress, sqlcode);
    RAISE;
END get_max_dist_num;


/*===========================================================================

  PROCEDURE NAME:       select_summary()

===========================================================================*/

PROCEDURE  select_summary(x_line_location_id IN OUT NOCOPY NUMBER,
                         x_total IN OUT NOCOPY NUMBER) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

-- Services FPJ calculate the total from amounts for service lines

select nvl(sum(decode(pol.order_type_lookup_code,'RATE',pod.amount_ordered,
                    'FIXED PRICE',pod.amount_ordered,pod.quantity_ordered)),0)
into x_total
from   po_distributions pod,
       po_lines pol
where pod.po_line_id = pol.po_line_id
and   pod.line_location_id = x_line_location_id;


EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('select_summary', x_progress, sqlcode);
    RAISE;
END select_summary;


/*===========================================================================

  FUNCTION NAME:       post_query()

===========================================================================*/

PROCEDURE post_query(
                    x_deliver_to_location_id NUMBER,
                    x_deliver_to_person_id NUMBER,
                    x_ship_to_org_id NUMBER,
                    x_project_id     NUMBER,
                    x_task_id        NUMBER,
                    x_org_id         NUMBER,
                    x_destination_type_code  VARCHAR2,
                    x_deliver_to_location  IN OUT NOCOPY VARCHAR2,
                    x_deliver_to_person    IN OUT NOCOPY VARCHAR2,
                    x_project_num          IN OUT NOCOPY VARCHAR2,
                    x_task_num             IN OUT NOCOPY VARCHAR2,
                    x_org_code             IN OUT NOCOPY VARCHAR2,
		    --togeorge 10/03/2000
		    -- added to bring oke line info during post query.
		    x_oke_contract_header_id	   IN		NUMBER default null,
		    x_oke_contract_line_id	   IN		NUMBER default null,
		    x_oke_contract_line_num	   IN OUT NOCOPY       VARCHAR2,
	            x_oke_contract_deliverable_id  IN		NUMBER default null,
	            x_oke_contract_deliverable_num IN OUT NOCOPY       VARCHAR2
		    ) IS

x_progress VARCHAR2(3):=NULL;

-- As part of hr_location changes bug# 2393886

cursor c1 is
   select location_code from hr_locations
   where nvl(inventory_organization_id,x_ship_to_org_id) = x_ship_to_org_id
   and   location_id = x_deliver_to_location_id
   UNION
   select (substrb(rtrim(address1)||'-'||rtrim(city),1,20)) location_code from hz_locations
   where location_id = x_deliver_to_location_id ;

/* Bug 1323765
   and   nvl(inactive_date, trunc(sysdate + 1)) > trunc(sysdate);
*/

--< Bug 3370335 > Remove cursor c2 for employee name.

cursor c3 is
   --Bug 610292 ecso 1/19/97
   --Owing to PJM changes,
   --use new view PJM_PROJECTS_V
   --instead of MTL_PROJECTS_V
   --         select project_number
   --         from PJM_PROJECTS_V
   --         where project_id = x_project_id;
   --Bug# 1223698 - To select Closed Projects during Query
   --Copied the same logic as in MRP_GET_PROJECT.PROJECT
                                select  segment1
                                from    pa_projects_all
                                where   project_id = x_project_id
                                union
                                select  project_number
                                from    mrp_seiban_numbers
                                where   project_id = x_project_id;


cursor c4 is
--            select task_number
--            from pa_tasks_expend_v
--            where project_id = x_project_id
--            and      task_id = x_task_id;
-- Bug# 1223698 - To select Non-Chargeable Task during Query
-- Copied the same logic as in MRP_GET_PROJECT.TASK
-- Copying the same logic as in
        select  task_number
        from    pa_tasks
        where   task_id = x_task_id;

cursor c5 is
            select name
            from HR_ORGANIZATION_UNITS --bug 3342946 (used to be pa_organizations_expend_v)
            where organization_id = x_org_id;
--togeorge 10/03/2000
--added cursors for oke info.
cursor c6 is
	select line_number
	  from okc_k_lines_b
--Bug# 1633032, togeorge 02/21/2001
-- Just line id enough to pick the line num.
--	 where dnz_chr_id =x_oke_contract_header_id
--	   and id = x_oke_contract_line_id;
	 where id = x_oke_contract_line_id;

cursor c7 is
	select deliverable_num
	  from oke_k_deliverables_b
	 where k_line_id = x_oke_contract_line_id
	   and deliverable_id = x_oke_contract_deliverable_id;

BEGIN

   x_progress := '001';

   IF x_deliver_to_location_id IS NOT NULL THEN
      open c1;
      fetch c1 into x_deliver_to_location;
      close c1;
   END IF;

   IF x_deliver_to_person_id IS NOT NULL THEN
      x_progress := '002';
      --< Bug 3370335 Start >
      -- Use utility procedure to get the emp name directly from base table
      x_deliver_to_person :=
          PO_EMPLOYEES_SV.get_emp_name( x_person_id => x_deliver_to_person_id );
      --< Bug 3370335 End >
   END IF;

   /* If the PROJECT_ID is not null, then if the destination_type='INVENTORY'
      then get the project_reference_enabled and the project_control_level
      flags for Project Manugacturing
   */
   IF x_project_id IS NOT NULL THEN

      IF x_destination_type_code='EXPENSE' THEN

        x_progress := '003';
        open c3;
        fetch c3 into x_project_num;
        close c3;

        open c4;
        fetch c4 into x_task_num;
        close c4;

        open c5;
        fetch c5 into x_org_code;
        close c5;

      ELSIF x_destination_type_code IN ('INVENTORY','SHOP FLOOR') THEN

        x_progress := '004';
        open c3;
        fetch c3 into x_project_num;
        close c3;

        IF x_task_id IS NOT NULL THEN
            x_progress := '004';
            open c4;
            fetch c4 into x_task_num;
            close c4;
         END IF;

      END IF;

   END IF;


   IF x_oke_contract_line_id is not null then

        x_progress := '006';
        open c6;
        fetch c6 into x_oke_contract_line_num;
        close c6;

      IF x_oke_contract_deliverable_id is not null then
         x_progress := '007';
         open c7;
         fetch c7 into x_oke_contract_deliverable_num;
         close c7;
      END IF;
   END IF;



EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('post_query', x_progress, sqlcode);
    RAISE;
END post_query;


/*===========================================================================

  FUNCTION NAME:       get_dest_type()

===========================================================================*/

FUNCTION get_dest_type( x_destination_type_code  VARCHAR2) return VARCHAR2 IS

x_progress VARCHAR2(3) := NULL;

x_dest_type VARCHAR2(40);

BEGIN

  select displayed_field
  into x_dest_type
  from   po_destination_types_all_v
  where  lookup_code = x_destination_type_code;

  RETURN(x_dest_type);

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('get_dest_type', x_progress, sqlcode);
    RAISE;
END get_dest_type;


/*===========================================================================

  PROCEDURE NAME:       delete_distributions()

===========================================================================*/

PROCEDURE delete_distributions(x_delete_id NUMBER,
			      x_delete_entity VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

  x_progress := '010';
  IF (X_delete_entity = 'RELEASE') THEN

     	   delete po_distributions_all     /*Bug6632095: using base table instead of view */
	   where line_location_id in
              (select line_location_id
                 from po_line_locations_all
                where po_release_id = x_delete_id);

  ELSIF (X_delete_entity = 'SHIPMENT') THEN

	   delete po_distributions
	   where  line_location_id = x_delete_id;

  ELSIF (X_delete_entity = 'LINE') THEN

	   delete po_distributions
	   where line_location_id in
	      (select line_location_id
	       from po_line_locations
	       where po_line_id = x_delete_id
	       and shipment_type in ('STANDARD', 'PLANNED'));

  ELSIF (X_delete_entity = 'HEADER') THEN

           --<BUG 3230237 START>
           --We can have encumbrance distributions tied to a BPA header.
           --Allow distributions with distribution_type 'AGREEMENT' to be deleted.
           DELETE    PO_DISTRIBUTIONS_ALL        /*Bug6632095: using base table instead of view */
           WHERE     po_header_id = x_delete_id
                     AND distribution_type in ('STANDARD', 'PLANNED', 'AGREEMENT');
           --<BUG 3230237 END>

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('In Exception');
    po_message_s.sql_error('delete_distributions', x_progress, sqlcode);
    RAISE;
END delete_distributions;

/*===========================================================================
  PROCEDURE NAME:	test_get_total_dist_qty
===========================================================================*/
   PROCEDURE test_get_total_dist_qty(X_po_line_location_id IN NUMBER) IS
      X_total_quantitya     NUMBER;
      BEGIN
         --dbms_output.put_line('before call');
         po_dist_s.get_total_dist_qty(X_po_line_location_id, X_total_quantitya);


         --dbms_output.put_line('after call');
         --dbms_output.put_line(X_total_quantitya);
      END test_get_total_dist_qty;
/*===========================================================================
  PROCEDURE NAME:	get_total_dist_qty
===========================================================================*/
   PROCEDURE get_total_dist_qty
		      (X_po_line_location_id 	      IN     NUMBER,
                       X_total_quantity               IN OUT NOCOPY NUMBER) IS
      X_progress varchar2(3) := '';
      CURSOR C is
	 SELECT sum(POD.quantity_ordered)
	 FROM   po_distributions POD
	 WHERE  POD.po_distribution_id = X_po_line_location_id;
      BEGIN
	 --dbms_output.put_line('Before open cursor');
	 if (X_po_line_location_id is not null) then
	    X_progress := '010';
            OPEN C;
	    X_progress := '020';
            FETCH C into X_total_quantity;
            CLOSE C;
         else
	   X_progress := '030';
	   po_message_s.sql_error('get_total_dist_qty', X_progress, sqlcode);
	 end if;
      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_total_dist_qty', X_progress, sqlcode);
      END get_total_dist_qty;
/*===========================================================================
  FUNCTION NAME:	test_val_distribution_exists
===========================================================================*/
   PROCEDURE test_val_distribution_exists(X_po_line_location_id IN NUMBER) IS
      X_val_dist BOOLEAN;
      BEGIN
         --dbms_output.put_line('before call');
         X_val_dist := po_dist_s.val_distribution_exists(X_po_line_location_id);


         --dbms_output.put_line('after call');
      END test_val_distribution_exists;
/*===========================================================================
  FUNCTION NAME:	val_distribution_exists
===========================================================================*/
   FUNCTION val_distribution_exists
		      (X_po_line_location_id         IN     NUMBER) RETURN BOOLEAN IS
      X_progress             VARCHAR2(3) := '';
      X_max_distribution_id  NUMBER      := '';
      BEGIN
	 SELECT max(POD.po_distribution_id)
	 INTO   X_max_distribution_id
	 FROM   po_distributions POD
	 WHERE  POD.line_location_id = X_po_line_location_id;
	 IF (X_max_distribution_id is null) THEN
	    --dbms_output.put_line('returned false');
	    return(FALSE);
	 ELSE
	    --dbms_output.put_line('returned true');
	    return(TRUE);
         END IF;
      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('val_distribution_exists', X_progress, sqlcode);
      END val_distribution_exists;

/*===================================================================

PROCEDURE NAME : performed_rcv_or_bill_activity (bug 4239813, 4239805)

=====================================================================*/
function performed_rcv_or_bill_activity(p_line_location_id IN NUMBER,
                                        p_distribution_id  IN NUMBER)
RETURN BOOLEAN IS
l_exists VARCHAR2(1);
Begin
  l_exists :='N';
  /* Find if any record for the shipment exists in rcv_transactions table */
  begin
    select 'Y'
    into   l_exists
    from   dual
	 where exists
             (select 'rcv transaction records'
                  from   rcv_transactions
                  where  po_line_location_id = p_line_location_id);

  exception
    when no_data_found then
      l_exists:= 'N';
    when others then
      raise;
  end;

  if (l_exists = 'Y') then
    return (TRUE);
  end if;

  begin
    select 'Y'
    into   l_exists
	from   dual
	where  exists
             (select 'transaction interface records'
                  from   rcv_transactions_interface
                  where  po_line_location_id = p_line_location_id
                  and    transaction_status_code = 'PENDING');

  exception
    when no_data_found then
      l_exists:= 'N';
    when others then
      raise;
  end;

  if (l_exists = 'Y') then
    return (TRUE);
  end if;

  /* trying to get all uncancelled, unreversed associated invoice distributions
   * , if they exist disallow change of destination type.
   */
  begin
    select 'Y'
    into   l_exists
	from   dual
	where exists
              (select 'Active invoice distributions'
                 from   ap_invoice_distributions
                 where  po_distribution_id = p_distribution_id
                 and    nvl(cancellation_flag,'N') <> 'Y'
                 and    nvl(reversal_flag,'N') <> 'Y');

  exception
    when no_data_found then
      l_exists:= 'N';
    when others then
      raise;
  end;

  if (l_exists = 'Y') then
    return (TRUE);
  end if;

  return (FALSE);
end;
-----------------------------------------------------------------------------
--Start of Comments
--Name: validate_delete_distribution
--Pre-reqs:
--  Before calling this procedure one must call validate_delete_line_loc
--  to ensure that deletion of the line location is a valid action
--Modifies:
--  PO_LINES_ALL
--  PO_LINE_LOCATIONS_ALL
--Locks:
--  None
--Function:
--  Deletes the selected Line Location from the Database and
--  calls the pricing APIs to calculate the new price if a Standard PO
-- shipment with a source reference is deleted
--Parameters:
--IN:
--p_po_distribution_id
--  Distribution ID for the Po Distribution to be deleted
--p_line_loc_id
--  Line Location ID for the Po Shipment to be deleted
--p_doc_subtype
--  Document Sub type of the PO [STANDARD/BLANKET]
--p_approved_date
--  Date on which the document was last approved. Get it  from the PO header.
--p_style_disp_name
--  Display Name of the document style
--OUT:
--x_message_text
--  Will hold the error message in case the header cannot be deleted
--Notes:
--  Rules: Do not allow deletion of a distribution which satisfies any of the following
--  condition
--  >  Approved atleast once
--  >  Created from an on-line Requisition
--  >  Has been Delivered
--  >  Has been Billed
--  >  is Encumbered
--  >  if only distribution
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE validate_delete_distribution(p_po_distribution_id IN NUMBER
                                      ,p_line_loc_id        IN NUMBER
                                      ,p_approved_date      IN VARCHAR2
                                      ,p_style_disp_name    IN VARCHAR2
                                      ,x_message_text      OUT NOCOPY VARCHAR2) IS
  l_creation_date       po_distributions_all.creation_date%TYPE;
  l_req_distribution_id po_distributions_all.req_distribution_id%TYPE;
  l_quantity_delivered  po_distributions_all.quantity_delivered%TYPE;
  l_amount_delivered    po_distributions_all.amount_delivered%TYPE;
  l_encumbered_flag     po_distributions_all.encumbered_flag%TYPE;
  l_quantity_billed     po_distributions_all.quantity_billed%TYPE;
  l_amount_billed       po_distributions_all.amount_billed%TYPE;
  --BUG 5553581
  l_po_header_id        po_distributions_all.po_header_id%TYPE;
  l_is_complex_work_po  BOOLEAN;
  l_dummy                    NUMBER := 0;
  d_pos                      NUMBER := 0;
  l_api_name CONSTANT        VARCHAR2(30) := 'validate_delete_distribution';
  d_module   CONSTANT        VARCHAR2(70) := 'po.plsql.PO_DISTRIBUTIONS_SV.validate_delete_distribution';

BEGIN

  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module); PO_LOG.proc_begin(d_module,'p_line_loc_id', p_line_loc_id); PO_LOG.proc_begin(d_module,'p_style_disp_name', p_style_disp_name);
  END IF;

    SELECT creation_date,
           req_distribution_id,
           po_header_id,
           nvl(quantity_delivered, 0),
           nvl(amount_delivered, 0),
           nvl(encumbered_flag, 'N'),
           nvl(quantity_billed, 0),
           nvl(amount_billed, 0)
    INTO   l_creation_date,
           l_req_distribution_id,
           l_po_header_id,
           l_quantity_delivered,
           l_amount_delivered,
           l_encumbered_flag,
           l_quantity_billed,
           l_amount_billed
    FROM   po_distributions_all
    WHERE  po_distribution_id = p_po_distribution_id;

  l_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(l_po_header_id);

    d_pos := 10;
    --Created from an on-line Requisition
    IF l_req_distribution_id IS NOT NULL
    THEN
      IF(l_is_complex_work_po = FALSE) --BUG 5553581
      THEN
        x_message_text := PO_CORE_S.get_translated_text('PO_PO_DEL_DIST_ONLINE_REQ_NA');
        RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
      ELSE
        BEGIN --5553581
          select po_distribution_id
          into l_dummy
          FROM po_distributions_all pod
          WHERE pod.line_location_id = p_line_loc_id
          AND   pod.req_distribution_id = l_req_distribution_id;

          x_message_text := PO_CORE_S.get_translated_text('PO_PO_DEL_DIST_ONLINE_REQ_NA');
          RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
        EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           --If there are multiple rows then we can go ahead and delete
           NULL;
        END;
      END IF;
    END IF;

    d_pos := 20;
    -- Has been Delivered
    IF l_quantity_delivered > 0
       OR l_amount_delivered > 0
    THEN
       x_message_text := PO_CORE_S.get_translated_text('PO_PO_DELETE_DEL_DIST_NA');
       RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
    END IF;

    d_pos := 30;
    --Has been Billed
    IF l_quantity_billed > 0
       OR l_amount_billed > 0
    THEN
       x_message_text := PO_CORE_S.get_translated_text('PO_PO_DELETE_DIST_BILLED_NA');
       RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
    END IF;

    d_pos := 40;
    -- is Encumbered
    IF l_encumbered_flag = 'Y'
    THEN
       x_message_text := PO_CORE_S.get_translated_text('PO_PO_USE_CANCEL_ON_ENCUMB_PO');
       RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
    END IF;

    d_pos := 50;
    -- Approved atleast once
    IF (l_creation_date <= p_approved_date)
    THEN
       x_message_text := PO_CORE_S.get_translated_text('PO_PO_USE_CANCEL_ON_APRVD_PO3');
       RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
    END IF;

    d_pos := 60;
   -- If there is only one single viable distribution then we should not allow to
   -- to delete the distribution
   BEGIN
     select po_distribution_id
     into l_dummy
     FROM po_distributions_all pod
     WHERE pod.line_location_id = p_line_loc_id;

     x_message_text := PO_CORE_S.get_translated_text('PO_CANT_DELETE_ONLY_DIST');
     RAISE PO_CORE_S.G_EARLY_RETURN_EXC;
   EXCEPTION
     WHEN TOO_MANY_ROWS THEN
       --If there are multiple rows then we can go ahead and delete
       NULL;
   END;
EXCEPTION
  WHEN PO_CORE_S.G_EARLY_RETURN_EXC THEN
    NULL;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_pos,'x_message_text',x_message_text);
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg('PO_DISTRIBUTIONS_SV', l_api_name||':'||d_pos);
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_module,d_pos,'Unhandled Exception in'  || d_module);
    END IF;
    RAISE;
END validate_delete_distribution;

END po_distributions_sv;

/
