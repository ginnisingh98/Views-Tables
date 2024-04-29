--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_SV4" as
/* $Header: POXPOR4B.pls 120.1 2006/03/23 04:50:22 amony noship $ */


/*===========================================================================

  PROCEDURE NAME:	release_post_query

===========================================================================*/
PROCEDURE release_post_query
(
    X_release_id                IN  NUMBER,
    X_rel_total                 OUT NOCOPY NUMBER,
    X_encumbered_flag           OUT NOCOPY VARCHAR2,
    X_release_type              IN  VARCHAR2,
    X_po_header_id              IN  NUMBER,
    X_rel_total_2               OUT NOCOPY NUMBER,
    X_ship_via_lookup_code      OUT NOCOPY VARCHAR2,
    X_ship_num                  OUT NOCOPY NUMBER,
    p_ship_to_org_id            IN  NUMBER,             --< Bug 3378554 Start >
    p_po_authorization_status   IN  VARCHAR2,
    p_freight_terms_lookup_code IN  VARCHAR2,
    p_fob_lookup_code           IN  VARCHAR2,
    p_pay_on_code               IN  VARCHAR2,
    x_ship_to_org_code          OUT NOCOPY VARCHAR2,
    x_agreement_status          OUT NOCOPY VARCHAR2,
    x_freight_terms             OUT NOCOPY VARCHAR2,
    x_fob                       OUT NOCOPY VARCHAR2,
    x_pay_on_dsp                OUT NOCOPY VARCHAR2     --< Bug 3378554 End >
)
IS
      X_progress varchar2(3) := '';

BEGIN

	 X_progress := '010';

X_rel_total := po_core_s.get_total('R', X_release_id,FALSE);

/* Bug#2567391 : Replaced the following call which gets the release header
total with the above call to handle the rounding problem in running
total implementation. Commenting the following call
         X_rel_total :=
		po_line_locations_pkg_s3.select_summary(X_release_id); */


--<Encumbrance FPJ>
PO_CORE_S.should_display_reserved(
   p_doc_type => PO_CORE_S.g_doc_type_RELEASE
,  p_doc_level => PO_CORE_S.g_doc_level_HEADER
,  p_doc_level_id => x_release_id
,  x_display_reserved_flag => x_encumbered_flag
);


         IF (X_release_type = 'BLANKET') THEN
	    X_rel_total_2 := po_core_s.get_total('B', X_po_header_id);
	 ELSE
            X_rel_total_2 := po_core_s.get_total('P', X_po_header_id);
         END IF;

	 SELECT ship_via_lookup_code
         INTO   X_ship_via_lookup_code
         FROM   po_headers
         WHERE  po_header_id = X_po_header_id;

	 X_ship_num := po_line_locations_pkg_s3.get_max_shipment_num(NULL,
                          X_release_id,
			  X_release_type);

    --< Bug 3378554 Start >
    IF (p_ship_to_org_id IS NOT NULL) THEN
        BEGIN
            --SQL What: Get org code of p_ship_to_org_id if it is in current SOB
            --SQL Why: Used for defaulting ship to org
            SELECT mp.organization_code
              INTO x_ship_to_org_code
              FROM financials_system_parameters fsp,
                   hr_organization_information hoi,
                   mtl_parameters mp
             WHERE mp.organization_id = p_ship_to_org_id
               AND mp.organization_id = hoi.organization_id
               AND hoi.org_information_context = 'Accounting Information'
               AND hoi.org_information1 = TO_CHAR(fsp.set_of_books_id);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- If not found, then do nothing
                NULL;
        END;
    END IF;  --< if p_ship_to_org_id not null >

    PO_CORE_S.get_displayed_value
       (x_lookup_type => 'AUTHORIZATION STATUS',
        x_lookup_code => NVL(p_po_authorization_status,'INCOMPLETE'),
        x_disp_value  => x_agreement_status);

    IF (p_freight_terms_lookup_code IS NOT NULL) THEN
        PO_CORE_S.get_displayed_value
           (x_lookup_type => 'FREIGHT TERMS',
            x_lookup_code => p_freight_terms_lookup_code,
            x_disp_value  => x_freight_terms);
    END IF;

    IF (p_fob_lookup_code IS NOT NULL) THEN
        PO_CORE_S.get_displayed_value
           (x_lookup_type => 'FOB',
            x_lookup_code => p_fob_lookup_code,
            x_disp_value  => x_fob);
    END IF;

    IF (p_pay_on_code IS NOT NULL) THEN
        PO_CORE_S.get_displayed_value
           (x_lookup_type => 'PAY ON CODE',
            x_lookup_code => p_pay_on_code,
            x_disp_value  => x_pay_on_dsp);
    END IF;
    --< Bug 3378554 End >

EXCEPTION
        when NO_DATA_FOUND then null;
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('release_post_query', X_progress, sqlcode);
          raise;

END release_post_query;



/*===========================================================================

  PROCEDURE NAME:	get_release_num

===========================================================================*/
   PROCEDURE get_release_num
		      (X_po_header_id 	     IN     NUMBER,
                       X_release_num         IN OUT NOCOPY NUMBER) IS

      X_progress varchar2(3) := '';

      CURSOR C is
         SELECT to_number(max(POR.release_num) + 1)
         FROM   po_releases POR
         WHERE  POR.po_header_id = X_po_header_id;

      BEGIN

	 --dbms_output.put_line('Before open cursor');

	 if (X_po_header_id is not null) then
	    X_progress := '010';
            OPEN C;
	    X_progress := '020';

            FETCH C into X_release_num;

            CLOSE C;

	    --
	    -- If there is not a release number then this is the
	    -- first release to be created and the release number
	    -- should be defaulted to 1.
	    --
	    if (X_release_num is null) then
               X_release_num := 1;
	    end if;

	    --dbms_output.put_line('Release Num'||X_release_num);

         else
	   X_progress := '030';
	   po_message_s.sql_error('get_release_num', X_progress, sqlcode);

	 end if;

      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_release_num', X_progress, sqlcode);
          raise;
      END get_release_num;

/*===========================================================================

  PROCEDURE NAME:	get_po_release_id()

===========================================================================*/

 PROCEDURE get_po_release_id
                (X_po_release_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.release_id_record_type) is

 v_count number;

 BEGIN

   /* If shipment_num, po_line_id and release_num are provided
      then we can find the exact po_line_location_record */

   IF X_po_release_id_record.shipment_num IS NOT NULL AND
      X_po_release_id_record.release_num IS NOT NULL THEN

      begin

         select pll.po_release_id, pll.line_location_id
         into   X_po_release_id_record.po_release_id ,
                X_po_release_id_record.po_line_location_id
         from po_line_locations pll, po_releases pr where
         pll.po_line_id = nvl(X_po_release_id_record.po_line_id,pll.po_line_id) and --1830177
         pll.po_release_id = pr.po_release_id and
         pr.po_header_id   = X_po_release_id_record.po_header_id and
         pr.release_num = X_po_release_id_record.release_num and
         pll.shipment_num = X_po_release_id_record.shipment_num;

     exception

         when no_data_found then

	 -- Bug 4881909 : Returning proper error_message in case of exception.

           begin

             select 1
             into   v_count
             from   po_releases
             where  po_header_id = X_po_release_id_record.po_header_id
               and  release_num  = X_po_release_id_record.release_num;

           exception

              when no_data_found then

                 X_po_release_id_record.error_record.error_status  := 'F';
                 X_po_release_id_record.error_record.error_message := 'RCV_ROI_INVALID_RELEASE_NUM';

           end;

           if (X_po_release_id_record.error_record.error_status <> 'F' ) then

                 X_po_release_id_record.error_record.error_status  := 'F';
                 X_po_release_id_record.error_record.error_message := 'RCV_ROI_INVALID_REL_SHIP_NUM';

	   end if;
     end;

   END IF;

   /* If shipment_num is null and po_line_id and release_num are
      provided then
        we can find the po_release_id
        we can FIND the po_line_location_id if there is only one record for this release_num */

   IF X_po_release_id_record.shipment_num IS NULL AND
      X_po_release_id_record.release_num IS NOT NULL  THEN

         select count(*) into v_count
         from po_line_locations pll, po_releases pr where
         pll.po_line_id = nvl(X_po_release_id_record.po_line_id,pll.po_line_id) and --1830177
         pll.po_release_id = pr.po_release_id and
         pr.po_header_id   = X_po_release_id_record.po_header_id and
         pr.release_num = X_po_release_id_record.release_num;

         IF v_count = 1 THEN

            select pll.po_release_id, pll.line_location_id, pll.shipment_num
            into   X_po_release_id_record.po_release_id ,
                   X_po_release_id_record.po_line_location_id,
                   X_po_release_id_record.shipment_num
            from po_line_locations pll, po_releases pr where
                 pll.po_line_id = nvl(X_po_release_id_record.po_line_id,pll.po_line_id) and --1830177
                 pll.po_release_id = pr.po_release_id and
                 pr.po_header_id   = X_po_release_id_record.po_header_id and
                 pr.release_num = X_po_release_id_record.release_num;

         ELSIF v_count > 1 then

            select distinct pll.po_release_id
            into   X_po_release_id_record.po_release_id
            from po_line_locations pll, po_releases pr where
                 pll.po_line_id = nvl(X_po_release_id_record.po_line_id,pll.po_line_id) and--1830177
                 pll.po_release_id = pr.po_release_id and
                 pr.po_header_id   = X_po_release_id_record.po_header_id and
                 pr.release_num = X_po_release_id_record.release_num;

            /* Bug# 2677526 */
            x_po_release_id_record.po_line_location_id := NULL;

         ELSIF v_count = 0 then

            x_po_release_id_record.po_line_location_id          := NULL;
            x_po_release_id_record.po_release_id                := NULL;
	    x_po_release_id_record.error_record.error_status	:= 'F';
	    x_po_release_id_record.error_record.error_message	:= 'RCV_ITEM_PO_REL_ID';

         END IF;

   END IF;

   /* If po_line_id, shipment_num are not null and release_num is null then
      we can find the po_line_location_id and po_release_id if there is only
      one record for this po_line_id + shipment_num combination (ie no multiple releases) */

   /* Bug 1830177. The following if statements should include the condition
    * po_line_id not null
   */
   IF (X_po_release_id_record.po_line_id is not null) THEN

   IF X_po_release_id_record.shipment_num IS NOT NULL AND
      X_po_release_id_record.release_num IS NULL THEN

      select count(*) into v_count
      from po_line_locations pll
      where
          pll.po_line_id = X_po_release_id_record.po_line_id and
          pll.shipment_num = X_po_release_id_record.shipment_num;

      IF v_count = 1 THEN

         select pll.po_release_id, pll.line_location_id
         into  X_po_release_id_record.po_release_id ,
               X_po_release_id_record.po_line_location_id
         from po_line_locations pll
         where
             pll.po_line_id   = X_po_release_id_record.po_line_id and
             pll.shipment_num = X_po_release_id_record.shipment_num;

      ELSE

            x_po_release_id_record.po_line_location_id          := NULL;
            x_po_release_id_record.po_release_id                := NULL;
	    x_po_release_id_record.error_record.error_status	:= 'F';

           -- Bug 4881909 : Returning proper error_message in case of exception.
            x_po_release_id_record.error_record.error_message   := 'RCV_ROI_INVALID_PO_SHIP_NUM';

      END IF;

    END IF;

   /* If po_line_id is not null and release_num, shipment_num is null then
      we can find the po_line_location_id, po_release_id, shipment_num if there is only
      one record for this po_line_id (ie no multiple shipments/releases) */

   IF X_po_release_id_record.shipment_num IS NULL AND
      X_po_release_id_record.release_num IS NULL THEN

      select count(*) into v_count
      from po_line_locations pll
      where
          pll.po_line_id = X_po_release_id_record.po_line_id
      and NVL(pll.APPROVED_FLAG,'N')   = 'Y'
      and NVL(pll.CANCEL_FLAG, 'N')    = 'N'
      and NVL(pll.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
      and pll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED');

      IF v_count = 1 THEN

         select pll.po_release_id, pll.line_location_id, pll.shipment_num
         into  X_po_release_id_record.po_release_id ,
               X_po_release_id_record.po_line_location_id,
               X_po_release_id_record.shipment_num
         from po_line_locations pll
         where
             pll.po_line_id   = X_po_release_id_record.po_line_id
         and NVL(pll.APPROVED_FLAG,'N')   = 'Y' -- bug 610238 should include the same clause as above
         and NVL(pll.CANCEL_FLAG, 'N')    = 'N'
         and NVL(pll.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
         and pll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED');

      ELSE

            x_po_release_id_record.po_line_location_id          := NULL;
            x_po_release_id_record.po_release_id                := NULL;
	    x_po_release_id_record.error_record.error_status	:= 'S';
	    x_po_release_id_record.error_record.error_message	:= NULL;

      END IF;

    END IF;
    END IF;

 exception
   when others then
	x_po_release_id_record.error_record.error_status	:= 'U';

 END get_po_release_id;

/*===========================================================================

  PROCEDURE NAME:	val_release_date

===========================================================================*/

   PROCEDURE val_release_date
		      (X_po_header_id 	          IN     NUMBER,
                       X_release_date             IN     DATE,
		       X_valid_release_date_flag  IN OUT NOCOPY VARCHAR2) IS

      X_progress varchar2(3) := '';


   -- <Cursor modified Action Date TZ FPJ>
      CURSOR C is
         SELECT 'Y'
	      FROM   PO_HEADERS POH
	      WHERE  POH.po_header_id = X_po_header_id
         AND    TRUNC(X_release_date) BETWEEN
		   		 TRUNC(nvl(POH.start_date, X_release_date))
		               AND
			       TRUNC(nvl(POH.end_date, X_release_date));

      BEGIN

	 --dbms_output.put_line('Before open cursor');

	 if (X_po_header_id is not null) then

	    OPEN C;
	    X_progress := '020';

            FETCH C into X_valid_release_date_flag;

            CLOSE C;

         else
	   X_progress := '030';
	   po_message_s.sql_error('val_release_date', X_progress, sqlcode);

	 end if;

      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('val_release_date', X_progress, sqlcode);
          raise;
      END val_release_date;

/*===========================================================================

  FUNCTION NAME:	val_doc_num_unique

===========================================================================*/
   FUNCTION val_doc_num_unique
		      (X_po_header_id         IN     NUMBER,
		       X_release_num 	      IN     NUMBER,
		       X_rowid                IN     VARCHAR2)
				RETURN BOOLEAN IS

      X_progress            VARCHAR2(3) := '';
      X_release_num_unqiue  VARCHAR2(1) := 'Y';

      /*
      ** Check to see if the release number for the
      ** po header id exists in the database.
      */
      CURSOR C is
         SELECT 'N'
	 FROM   PO_RELEASES POR
	 WHERE  POR.po_header_id = X_po_header_id
	 AND    POR.release_num  = X_release_num
	 AND    (X_rowid is null OR
		 X_rowid <> POR.rowid);

      BEGIN

	 --dbms_output.put_line('Before open cursor');

	 IF (X_po_header_id is not null AND X_release_num is not null) THEN

	    OPEN C;
	    X_progress := '020';

            FETCH C into X_release_num_unqiue;

            CLOSE C;

	    /*
	    ** If the release number does exist, then the release
	    ** number is not unique and we should return false
	    */
	    IF (X_release_num_unqiue = 'Y') THEN
	       return(TRUE);
	    ELSE
	       return(FALSE);
	    END IF;

         ELSE
	   X_progress := '030';
	   po_message_s.sql_error('val_doc_num_unique', X_progress, sqlcode);

	 END if;


      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('val_doc_num_unique', X_progress, sqlcode);
          raise;
      END val_doc_num_unique;


/*===========================================================================

  FUNCTION NAME:	val_approval_status


===========================================================================*/
   FUNCTION val_approval_status
		      (X_po_release_id            IN NUMBER,
		       X_release_num              IN NUMBER,
		       X_agent_id                 IN NUMBER,
		       X_release_date             IN DATE,
	 	       X_acceptance_required_flag IN VARCHAR2,
		       X_acceptance_due_date      IN VARCHAR2,
                       p_shipping_control         IN VARCHAR2
                       -- <INBOUND LOGISTICS FPJ>
                      ) RETURN BOOLEAN IS

      X_progress                VARCHAR2(3)  := '';
      X_approval_status_changed VARCHAR2(1)  := 'N';

      /*
      ** Check to see if the if any of the follosing release header values
      ** have changed.
      */
      CURSOR C is
         SELECT 'Y'
	 FROM   PO_RELEASES POR
	 WHERE  POR.po_release_id  = X_po_release_id
	 AND (  POR.release_num   <> X_release_num
	 OR     POR.agent_id      <> X_agent_id
	 OR     POR.release_date  <> X_release_date
	 OR   ((POR.acceptance_required_flag <> X_acceptance_required_flag)
	     OR (POR.acceptance_required_flag IS NULL
		 AND
	         X_acceptance_required_flag IS NOT NULL)
	     OR (POR.acceptance_required_flag IS NOT NULL
	         AND
		 X_acceptance_required_flag IS NULL))
	 OR   ((POR.acceptance_due_date <> X_acceptance_due_date)
	     OR (POR.acceptance_due_date IS NULL
		 AND
	         X_acceptance_due_date IS NOT NULL)
	     OR (POR.acceptance_due_date IS NOT NULL
	         AND
		 X_acceptance_due_date IS NULL))
         -- <INBOUND LOGISTICS FPJ START>
	 OR   ((POR.shipping_control <> p_shipping_control)
	     OR (POR.shipping_control IS NULL
		 AND
	         p_shipping_control IS NOT NULL)
	     OR (POR.shipping_control IS NOT NULL
	         AND
		 p_shipping_control IS NULL))
         -- <INBOUND LOGISTICS FPJ END>
        );

      BEGIN

	 --dbms_output.put_line('Before open cursor');

	 IF (X_po_release_id is not null) THEN

	    OPEN C;
	    X_progress := '020';

            FETCH C into X_approval_status_changed;

            CLOSE C;

        END IF;

	/*
	** If the approval status changed flag is Y, one of
	** the values on the release header has changed since it
	** was last saved to the database.
	*/
	IF (X_approval_status_changed = 'Y') THEN
	   --dbms_output.put_line('status changed = Y');
	   return(FALSE);
	ELSE
	   --dbms_output.put_line('status changed = N');
	   return(TRUE);
        END IF;

      EXCEPTION
	WHEN OTHERS THEN
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('val_approval_status', X_progress, sqlcode);
          raise;
      END val_approval_status;


END PO_RELEASES_SV4;

/
