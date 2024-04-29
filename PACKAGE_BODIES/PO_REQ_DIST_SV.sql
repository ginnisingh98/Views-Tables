--------------------------------------------------------
--  DDL for Package Body PO_REQ_DIST_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DIST_SV" AS
/* $Header: POXRQD1B.pls 120.5.12000000.3 2007/04/26 09:23:21 ggandhi ship $ */
/*===========================================================================

  PROCEDURE NAME:       check_unique()

===========================================================================*/

FUNCTION check_unique(x_row_id VARCHAR2, x_distribution_num NUMBER,
                       x_requisition_line_id NUMBER) RETURN BOOLEAN IS

dummy varchar2(40);
x_progress VARCHAR2(3) := NULL;

BEGIN
   x_progress := '001';

  select 'that line number exists'
  into dummy
  from   po_req_distributions
  where  requisition_line_id = x_requisition_line_id
  and    distribution_num    = x_distribution_num
  AND   (rowid              <> x_row_id
       OR x_row_id IS NULL);

   RETURN(FALSE); -- there is a row with that distribution_num already

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN(TRUE);
   WHEN OTHERS THEN
      -- dbms_output.put_line('In Exception');
      po_message_s.sql_error('check_unique', x_progress, sqlcode);
      RAISE;
END check_unique;


/*===========================================================================

  PROCEDURE NAME:       check_unique_insert()

===========================================================================*/

PROCEDURE check_unique_insert(x_row_id IN OUT NOCOPY VARCHAR2, x_distribution_num NUMBER,
                       x_requisition_line_id NUMBER) IS

dummy varchar2(40);
x_progress VARCHAR2(3) := NULL;

BEGIN
   x_progress := '001';

  select '1'
  into dummy
  from dual
  where not exists (
     select 'that line number exists'
     from   po_req_distributions
     where  requisition_line_id = x_requisition_line_id
     and    distribution_num    = x_distribution_num
     AND   (rowid              <> x_row_id
            OR x_row_id IS NULL));


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      po_message_s.app_error('PO_RQ_LINE_NUM_ALREADY_EXISTS');
      RAISE;
   WHEN OTHERS THEN
      -- dbms_output.put_line('In Exception');
      po_message_s.sql_error('check_unique_insert', x_progress, sqlcode);
      RAISE;
END check_unique_insert;


/*===========================================================================

  FUNCTION NAME:       get_max_dist_num()

===========================================================================*/

FUNCTION  get_max_dist_num(x_requisition_line_id NUMBER) RETURN NUMBER IS

x_progress VARCHAR2(3) := NULL;
max_dist_num NUMBER;

cursor C1 is
select nvl(max(distribution_num),0)
from   po_req_distributions
where  requisition_line_id = x_requisition_line_id;

BEGIN
   x_progress := '001';
   open C1;
   fetch C1 into max_dist_num;
   RETURN(max_dist_num);
   close C1;

EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In Exception');
    po_message_s.sql_error('get_max_dist_num', x_progress, sqlcode);
    RAISE;
END get_max_dist_num;


/*===========================================================================

  PROCEDURE NAME:       select_summary()

===========================================================================*/

PROCEDURE  select_summary(x_requisition_line_id IN OUT NOCOPY NUMBER,
                         x_total IN OUT NOCOPY NUMBER) IS

x_progress VARCHAR2(3) := NULL;

BEGIN
select nvl(sum(req_line_quantity),0)
into x_total
from   po_req_distributions
where  requisition_line_id = x_requisition_line_id;


EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In Exception');
    po_message_s.sql_error('select_summary', x_progress, sqlcode);
    RAISE;
END select_summary;



/*===========================================================================

  PROCEDURE NAME:	update_reqs_distributions

===========================================================================*/

 PROCEDURE update_reqs_distributions
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_req_control_action      IN     VARCHAR2,
 		   X_req_action_date         IN     DATE,
                   X_req_control_error_rc    IN OUT NOCOPY VARCHAR2) IS

   X_progress            VARCHAR2(3) := NULL;
   X_gl_cancelled_date   PO_REQ_DISTRIBUTIONS.gl_cancelled_date%TYPE := NULL;
   X_gl_closed_date      PO_REQ_DISTRIBUTIONS.gl_closed_date%TYPE := NULL;

 BEGIN

   -- dbms_output.put_line('Enter update_reqs_distributions');

   X_req_control_error_rc := '';
   IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
      IF X_req_action_date is NOT NULL THEN
          X_gl_cancelled_date :=  X_req_action_date;
      ELSE
          X_gl_cancelled_date := sysdate;
      END IF;
   ELSIF X_req_control_action = 'FINALLY CLOSE' THEN
      IF X_req_action_date is NOT NULL THEN
         X_gl_closed_date :=  X_req_action_date;
      ELSE
         X_gl_closed_date := sysdate;
      END IF;
   END IF;

   IF X_req_header_id is NOT NULL OR
      X_req_line_id is NOT NULL THEN

      /* The following SQL statement is optimized to update either
      ** 1. all document lines - if header_id is passed or,
      ** 2. one document line  - if both header_id and line_id are passed.
      */
      X_progress := '010';
      UPDATE PO_REQ_DISTRIBUTIONS
      SET    gl_cancelled_date = nvl(X_gl_cancelled_date, gl_cancelled_date),
             gl_closed_date    = nvl(X_gl_closed_date, gl_closed_date)
      WHERE  requisition_line_id IN
             (SELECT requisition_line_id
              FROM   po_requisition_lines PORL
              WHERE  PORL.requisition_header_id = X_req_header_id
              AND    PORL.requisition_line_id =
                     nvl(X_req_line_id, PORL.requisition_line_id));
   ELSE
         /* DEBUG - show error message */
         X_req_control_error_rc := 'Y';
         X_progress := '015';
         po_message_s.sql_error('update_reqs_distributions', X_progress, sqlcode);
   END IF;


   -- dbms_output.put_line('Exit update_reqs_distributions');

   EXCEPTION

    WHEN NO_DATA_FOUND THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('update_reqs_distributions', X_progress, sqlcode);
      RAISE;
    WHEN OTHERS THEN
      po_message_s.sql_error('update_reqs_distributions', X_progress, sqlcode);
      RAISE;

 END update_reqs_distributions;



/*===========================================================================

  PROCEDURE NAME:	val_create_dist()

===========================================================================*/
/*
PROCEDURE val_create_dist() IS

x_progress VARCHAR2(3) := NULL;

BEGIN


   EXCEPTION
   WHEN OTHERS THEN
      po_message.set_name('val_create_dist', x_progress, sqlcode);
   RAISE;

END val_create_dist;
*/

/*===========================================================================

  PROCEDURE NAME:	create_dist_for_modify

===========================================================================*/

PROCEDURE create_dist_for_modify(x_new_req_line_id	IN NUMBER,
				 x_orig_req_line_id     IN NUMBER,
				 x_new_line_quantity	IN NUMBER) IS

x_progress      	VARCHAR2(3) := NULL;

x_distribution_id	NUMBER := NULL;
x_new_dist_quantity	NUMBER;
x_orig_line_quantity    NUMBER;
x_total_dist_qty	NUMBER;

dist_rec   po_req_distributions%rowtype;
x_rowid    VARCHAR2(30);

-- JFMIP, support for Req Modify when encumbrance is enabled START
l_base_currency        PO_HEADERS_ALL.currency_code%TYPE;
/*Bug4421065 TCA Impact: Removed the obsolete column ap_tax_rounding_rule in po_vendors_sites_all table */

l_prorated_rec_tax     PO_REQ_DISTRIBUTIONS.recoverable_tax%type;
l_prorated_nonrec_tax  PO_REQ_DISTRIBUTIONS.nonrecoverable_tax%type;
-- JFMIP, support for Req Modify when encumbrance is enabled END

CURSOR C IS
   SELECT distribution_id
   FROM   po_req_distributions
   WHERE  requisition_line_id = x_orig_req_line_id;

BEGIN

  /*
  ** Obtain the line quantity from the original
  ** line.
  */

   x_progress := '010';

   SELECT quantity
   INTO   x_orig_line_quantity
   FROM   po_requisition_lines
   WHERE  requisition_line_id = x_orig_req_line_id;

   -- dbms_output.put_line ('Original Line quantity: ' ||
-- bug1555260		  to_char(x_orig_line_quantity));

   -- JFMIP, support for Req Modify when encumbrance is enabled START
   l_base_currency := PO_CORE_S2.get_base_currency;


   -- JFMIP, support for Req Modify when encumbrance is enabled END

  /*
  ** Open cursor to loop through all the distributions
  ** of the original requisition line and create new
  ** distributions for the new requisition line.
  */

  FOR CREC IN C LOOP

    x_progress := '020';

    SELECT *
    INTO   dist_rec
    FROM   po_req_distributions
    WHERE  distribution_id = CREC.distribution_id;


    /*
    ** Compute prorated quantity for the new distributions.
    */

    x_new_dist_quantity := round(((dist_rec.req_line_quantity/
				   x_orig_line_quantity)* x_new_line_quantity),
                                   -- JFMIP
				   -- 5);
				   13);

    -- JFMIP, support for Req Modify when encumbrance is enabled START
    --Prorate and round the tax
/*Bug4421065:<R12 eTax Integration>  Assigned null values to the below variables since the tax engine will take care of calculating the tax */
    l_prorated_rec_tax:= null;

    l_prorated_nonrec_tax:= null;

    -- JFMIP, support for Req Modify when encumbrance is enabled END

    /* Clear old distribution id */

    x_distribution_id := NULL;

    -- dbms_output.put_line ('Distribution quantity: ' ||
--bug1555260			   x_new_dist_quantity);

    x_progress := '030';

    po_req_distributions_pkg1.insert_row (x_rowid,
					  x_distribution_id,
					  dist_rec.last_update_date,
               				  dist_rec.last_updated_by,
               				  x_new_req_line_id,
               				  dist_rec.set_of_books_id,
               				  dist_rec.code_combination_id,
               				  x_new_dist_quantity,
                              NULL,-- req_line_amount         -- <SERVICES FPJ>
                              NULL,-- req_line_currency_amount-- <SERVICES FPJ>
               			      dist_rec.last_update_login,
               				  dist_rec.creation_date,
               				  dist_rec.created_by,
               				  dist_rec.encumbered_flag,
               				  dist_rec.gl_encumbered_date,
               				  dist_rec.gl_encumbered_period_name,
               				  dist_rec.gl_cancelled_date,
               				  dist_rec.failed_funds_lookup_code,
    -- JFMIP, support for Req Modify when encumbrance is enabled
               				  -- dist_rec.encumbered_amount,
               				  0,
               				  dist_rec.budget_account_id,
               				  dist_rec.accrual_account_id,
               				  dist_rec.variance_account_id,
               				  dist_rec.prevent_encumbrance_flag,
               				  dist_rec.attribute_category,
               				  dist_rec.attribute1,
               				  dist_rec.attribute2,
               				  dist_rec.attribute3,
               				  dist_rec.attribute4,
               			          dist_rec.attribute5,
               				  dist_rec.attribute6,
               				  dist_rec.attribute7,
               				  dist_rec.attribute8,
               				  dist_rec.attribute9,
               				  dist_rec.attribute10,
               				  dist_rec.attribute11,
               				  dist_rec.attribute12,
               				  dist_rec.attribute13,
               				  dist_rec.attribute14,
               				  dist_rec.attribute15,
               				  NULL, --<R12 SLA>
               				  dist_rec.government_context,
               				  dist_rec.project_id,
               				  dist_rec.task_id,
               				  dist_rec.expenditure_type,
               				  dist_rec.project_accounting_context,
               				  dist_rec.expenditure_organization_id,
               				  dist_rec.gl_closed_date,
               				  dist_rec.source_req_distribution_id,
               				  dist_rec.distribution_num,
               				  dist_rec.project_related_flag,
               				  dist_rec.expenditure_item_date,
                                          dist_rec.end_item_unit_number,
					  dist_rec.recovery_rate,
                                          -- JFMIP START
					  -- dist_rec.recoverable_tax,
					  -- dist_rec.nonrecoverable_tax,
                                          l_prorated_rec_tax,
                                          l_prorated_nonrec_tax,
                                          -- JFMIP END
					  dist_rec.tax_recovery_override_flag,
					  -- <R12 MOAC Start> bug4548700 added the following to forward contract details to
                      -- newly splitted lines.
					 dist_rec.award_id, --null
                     dist_rec.oke_contract_line_id, --null
                     dist_rec.oke_contract_deliverable_id, --null
					  dist_rec.org_id
					  -- <R12 MOAC End>
					  );


   END LOOP;

   /*
   ** Obtain the difference in the requisition line
   ** quantity and the sum of the distributions quantity.
   ** Add the difference to the first distribution of the
   ** new line.
   */

   x_progress := '040';

   SELECT sum (req_line_quantity)
   INTO   x_total_dist_qty
   FROM   po_req_distributions
   WHERE  requisition_line_id = x_new_req_line_id;

   IF (x_total_dist_qty = x_new_line_quantity) THEN
     return;

   ELSE

     x_progress := '050';

     UPDATE po_req_distributions
     SET    req_line_quantity = req_line_quantity + (x_new_line_quantity -
						     x_total_dist_qty)
     WHERE  distribution_id = (SELECT min(distribution_id)
			       FROM   po_req_distributions
			       WHERE  requisition_line_id = x_new_req_line_id);

   END IF;


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('create_dist_for_modify', x_progress, sqlcode);
      raise;

END create_dist_for_modify;

END po_req_dist_sv;

/
