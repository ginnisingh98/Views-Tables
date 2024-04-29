--------------------------------------------------------
--  DDL for Package Body PO_DIST_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DIST_S" as
/* $Header: POXPOPDB.pls 120.2.12010000.2 2014/07/16 06:55:02 yuandli ship $ */
/*========================  PO_DIST_S  ====================================*/
   g_pkg_name  CONSTANT VARCHAR2(100) := 'PO_DIST_S'; --Bug 18729747
   g_log_head  CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.'; --Bug 18729747
   g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on; --Bug 18729747

/*===========================================================================
  PROCEDURE NAME:	test_get_total_dist_qty
===========================================================================*/
   PROCEDURE test_get_total_dist_qty(X_po_line_location_id IN NUMBER) IS
      X_total_quantitya     NUMBER;
      BEGIN
         --  dbms_output.put_line('before call');
         po_dist_s.get_total_dist_qty(X_po_line_location_id, X_total_quantitya);


        -- dbms_output.put_line('after call');
        -- dbms_output.put_line(X_total_quantitya);
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
	-- dbms_output.put_line('Before open cursor');
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
	 -- dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_total_dist_qty', X_progress, sqlcode);
      END get_total_dist_qty;
/*===========================================================================
  FUNCTION NAME:	test_val_distribution_exists
===========================================================================*/
   PROCEDURE test_val_distribution_exists(X_po_line_location_id IN NUMBER) IS
      X_val_dist BOOLEAN;
      BEGIN
         -- dbms_output.put_line('before call');
         X_val_dist := po_dist_s.val_distribution_exists(X_po_line_location_id);


         -- dbms_output.put_line('after call');
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
	    -- dbms_output.put_line('returned false');
	    return(FALSE);
	 ELSE
	    -- dbms_output.put_line('returned true');
	    return(TRUE);
         END IF;
      EXCEPTION
	when others then
	  -- dbms_output.put_line('In exception');
	  po_message_s.sql_error('val_distribution_exists', X_progress, sqlcode);
      END val_distribution_exists;

/*===========================================================================

  FUNCTION  NAME:	val_approval_status

===========================================================================*/
FUNCTION val_approval_status
		      (X_distribution_id          IN NUMBER,
                       X_distribution_num         IN NUMBER,
		       X_deliver_to_person_id     IN NUMBER,
		       X_quantity_ordered         IN NUMBER,
		       X_amount_ordered           IN NUMBER,
		       X_rate	                  IN NUMBER,
		       X_rate_date                IN DATE,
		       X_gl_encumbered_date       IN DATE,
		       X_charge_account_id        IN NUMBER,
		       X_project_id               IN NUMBER,     -- Bug # 6408034
         --< Shared Proc FPJ Start >
         p_dest_charge_account_id   IN NUMBER,
         --< Shared Proc FPJ End >

		       X_recovery_rate		  IN NUMBER,
         X_destination_subinventory IN VARCHAR2) RETURN NUMBER IS

X_temp_deliver_to_person_id NUMBER;
X_temp_quantity_ordered NUMBER;
X_temp_amount_ordered NUMBER;
X_temp_rate NUMBER;
X_temp_rate_date DATE;
X_temp_gl_encumbered_date DATE;
X_temp_charge_account_id NUMBER;
X_temp_project_id NUMBER;      -- Bug # 6408034
X_temp_recovery_rate	 NUMBER;
X_temp_distribution_num       NUMBER;
X_need_to_approve         NUMBER := NULL;
X_temp_dest_subinventory VARCHAR2(10);
X_progress                VARCHAR2(3)  := '';

  --< Shared Proc FPJ Start >
  l_temp_dest_charge_account_id NUMBER;
  --< Shared Proc FPJ End >

l_log_head CONSTANT VARCHAR2(1000) := g_log_head||'val_approval_status'; --Bug 18729747

BEGIN

   X_progress := '010';

   --Bug 18729747 Start
IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_distribution_id',X_distribution_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_distribution_num',X_distribution_num );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_deliver_to_person_id',X_deliver_to_person_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_quantity_ordered',X_quantity_ordered );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_amount_ordered',X_amount_ordered );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_rate',X_rate );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_rate_date',X_rate_date );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_gl_encumbered_date',X_gl_encumbered_date );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_charge_account_id',X_charge_account_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_project_id',X_project_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'p_dest_charge_account_id',p_dest_charge_account_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_recovery_rate',X_recovery_rate );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_destination_subinventory',X_destination_subinventory );
END IF;
   --End Bug 18729747

   SELECT
      deliver_to_person_id,
      quantity_ordered,
      amount_ordered,
      rate,
      rate_date,
      gl_encumbered_date,
      code_combination_id,
      project_id,  -- Bug # 6408034
      --< Shared Proc FPJ Start >
      dest_charge_account_id,
      --< Shared Proc FPJ End >

      recovery_rate,
      distribution_num,
      destination_subinventory
   INTO
      X_temp_deliver_to_person_id,
      X_temp_quantity_ordered,
      X_temp_amount_ordered,
      X_temp_rate,
      X_temp_rate_date,
      X_temp_gl_encumbered_date,
      X_temp_charge_account_id,
      X_temp_project_id,          -- Bug # 6408034
      --< Shared Proc FPJ Start >
      l_temp_dest_charge_account_id,
      --< Shared Proc FPJ End >

      X_temp_recovery_rate,
      X_temp_distribution_num,
      X_temp_dest_subinventory
   FROM   po_distributions
   WHERE  po_distribution_id = X_distribution_id;

   --Bug 18729747 Start
IF g_debug_stmt THEN
   X_progress := '011';
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_deliver_to_person_id',X_temp_deliver_to_person_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_quantity_ordered',X_temp_quantity_ordered );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_amount_ordered',X_temp_amount_ordered );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_rate',X_temp_rate );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_rate_date',X_temp_rate_date );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_gl_encumbered_date',X_temp_gl_encumbered_date );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_charge_account_id',X_temp_charge_account_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_project_id',X_temp_project_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'l_temp_dest_charge_account_id',l_temp_dest_charge_account_id );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_recovery_rate',X_temp_recovery_rate );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_distribution_num',X_temp_distribution_num );
   PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_dest_subinventory',X_temp_dest_subinventory );
END IF;
   --End Bug 18729747

   -- Bug 5409088: Added check for amount ordered
   IF ((X_temp_quantity_ordered <> X_quantity_ordered )
	         OR (X_temp_quantity_ordered is NULL
	             AND
		     X_quantity_ordered is NOT NULL)
                 OR (X_temp_quantity_ordered is NOT NULL
		     AND
		     X_quantity_ordered is NULL)
               OR (X_temp_amount_ordered <> X_amount_ordered )
	       OR (X_temp_amount_ordered is NULL
	           AND
		   X_amount_ordered is NOT NULL)
               OR (X_temp_amount_ordered is NOT NULL
		   AND
		   X_amount_ordered is NULL)
	       OR (X_temp_deliver_to_person_id <> X_deliver_to_person_id)
	       OR (X_temp_deliver_to_person_id is NULL
		   AND
		   X_deliver_to_person_id IS NOT NULL)
	       OR (X_temp_deliver_to_person_id IS NOT NULL
		   AND
		   X_deliver_to_person_id IS NULL)
	       OR (trunc(X_temp_rate_date) <> trunc(X_rate_date)) --Bug 18729747: add trunc
	       OR (X_temp_rate_date IS NULL
	           AND
	           X_rate_date IS NOT NULL)
	       OR (X_temp_rate_date IS NOT NULL
		   AND
		   X_rate_date IS NULL)
               OR (X_temp_rate       <> X_rate)
	       OR (X_temp_rate IS NULL
	           AND
	           X_rate IS NOT NULL)
	       OR (X_temp_rate IS NOT NULL
		   AND
		   X_rate IS NULL)
-- Bug 3268649
--	OR (X_gl_encumbered_date        <> X_gl_encumbered_date)
	       OR (trunc(X_temp_gl_encumbered_date) <> trunc(X_gl_encumbered_date)) --Bug 18729747: add trunc
	       OR (X_temp_gl_encumbered_date IS NULL
		   AND
		   X_gl_encumbered_date IS NOT NULL)
	       OR (X_temp_gl_encumbered_date IS NOT NULL
		   AND
		   X_gl_encumbered_date IS NULL)
               OR (X_temp_recovery_rate       <> X_recovery_rate)
	       OR (X_temp_recovery_rate IS NULL
	           AND
	           X_recovery_rate IS NOT NULL)
	       OR (X_temp_recovery_rate IS NOT NULL
		   AND
		   X_recovery_rate IS NULL)
               OR (X_temp_dest_subinventory      <> X_destination_subinventory)
	       OR (X_temp_dest_subinventory IS NULL
	           AND
	           X_destination_subinventory IS NOT NULL)
	       OR (X_temp_dest_subinventory IS NOT NULL
		   AND
		   X_destination_subinventory IS NULL)

	       OR (X_temp_charge_account_id        <> X_charge_account_id)
	       OR (X_temp_charge_account_id IS NULL
	           AND
		   X_charge_account_id IS NOT NULL)
	       OR (X_temp_charge_account_id IS NOT NULL
		   AND
		   X_charge_account_id IS NULL)

	 /*  start Bug # 6408034 */
              OR (X_temp_project_id        <> X_project_id)
	       OR (X_temp_project_id IS NULL
	           AND
		   X_project_id IS NOT NULL)
	       OR (X_temp_project_id IS NOT NULL
		   AND
		   X_project_id IS NULL)

   /* end  Bug # 6408034 */

     --< Shared Proc FPJ Start >
     OR (l_temp_dest_charge_account_id <> p_dest_charge_account_id)
     OR (l_temp_dest_charge_account_id IS NULL AND
         p_dest_charge_account_id IS NOT NULL)
     OR (l_temp_dest_charge_account_id IS NOT NULL AND
         p_dest_charge_account_id IS NULL)
     --< Shared Proc FPJ End >

     ) then
               --Bug 18729747 Start
           IF g_debug_stmt THEN
               X_progress := '012';
               PO_DEBUG.debug_var(l_log_head,X_progress,'X_gl_encumbered_date',X_gl_encumbered_date );
               PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_gl_encumbered_date',X_temp_gl_encumbered_date );
           END IF;
               --End Bug 18729747

               /* Unapprove Both the doc and the shipment */

               X_need_to_approve := 2;

      END IF;

      /* Bug 3268649: The code below was moved to before the return.
       * Otherwise, it would never be run!
       */

     /* bug 1046786 added the distribution_num check to unapprove the PO header */

      if
	         ((X_temp_distribution_num        <> X_distribution_num)
	       OR (X_temp_distribution_num IS NULL
	           AND
		   X_distribution_num IS NOT NULL)
	       OR (X_temp_distribution_num IS NOT NULL
		   AND
		   X_distribution_num IS NULL)) then

               --Bug 18729747 Start
             IF g_debug_stmt THEN
               X_progress := '013';
               PO_DEBUG.debug_var(l_log_head,X_progress,'X_temp_distribution_num',X_temp_distribution_num );
               PO_DEBUG.debug_var(l_log_head,X_progress,'X_distribution_num',X_distribution_num );
             END IF;
               --End Bug 18729747

             /* Unapprove Only the Doc if this is the only change.
             ** If the document already needs to be re-approved due to other
             ** changes above, leave it at 2. */

                 if X_need_to_approve is NULL then
                    X_need_to_approve  := 1;
                 end if;

              end if; /* Dist num Check */

      /* End Bug 3268649 */

       --Bug 18729747 Start
     IF g_debug_stmt THEN
       X_progress := '020';
       PO_DEBUG.debug_end(l_log_head);
       PO_DEBUG.debug_var(l_log_head,X_progress,'X_need_to_approve',X_need_to_approve );
     END IF;
       --End Bug 18729747

       return(X_need_to_approve);


      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   -- dbms_output.put_line('No data found');
	   return(0);
	WHEN OTHERS THEN
	  -- dbms_output.put_line('In UPDATE exception');
	  po_message_s.sql_error('val_approval_status', X_progress, sqlcode);
          raise;

END val_approval_status;


END PO_DIST_S;

/
