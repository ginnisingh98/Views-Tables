--------------------------------------------------------
--  DDL for Package Body CHV_CONFIRM_SCHEDULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_CONFIRM_SCHEDULES" as
/* $Header: CHVPRCSB.pls 115.3 2002/11/26 23:40:01 sbull ship $ */

/*======================= CHV_CONFIRM_SCHEDULES =============================*/

/*=============================================================================

  PROCEDURE NAME:     confirm_schedule_item()

=============================================================================*/
FUNCTION confirm_schedule_item(p_schedule_id             in NUMBER,
                               p_schedule_item_id        in NUMBER,
			       p_vendor_id               in NUMBER,
			       p_vendor_site_id          in NUMBER,
			       p_organization_id         in NUMBER,
			       p_item_id                 in NUMBER) return boolean is

  x_progress                  VARCHAR2(3) := NULL;
  x_message                   VARCHAR2(240);
  x_item_confirm              BOOLEAN DEFAULT FALSE;

  x_user_id                   NUMBER := NVL(fnd_global.user_id, 0);
  x_login_id                  NUMBER := NVL(fnd_global.login_id, 0);

BEGIN

  x_progress := '010';

    -- Call asl action procedure to verify if this schedule item for
    -- the supplier/site/item/org can be confirmed.

    IF po_asl_sv.check_asl_action('3_SCHEDULE_CONFIRMATION',
                                  p_vendor_id,
                                  p_vendor_site_id,
                                  p_item_id,
                                  -1,
                                  p_organization_id) = 1 THEN

       x_item_confirm := TRUE;

      --If the above action returned TRUE then the schedule item can be
      --confirmed.  Update the status and the standard who columns.

      x_progress := '020';

      UPDATE chv_schedule_items
      SET    item_confirm_status = 'CONFIRMED',
             last_update_date    = SYSDATE,
             last_updated_by     = x_user_id,
             last_update_login   = x_login_id
      WHERE  schedule_item_id    = p_schedule_item_id ;

    ELSE

      --Action returned FALSE that the schedule item cannot be confirmed.
      --So initialize the message and also create a record in the PO
      --Interface table.

      x_message := FND_MESSAGE.GET_STRING('CHV', 'CHV_NOT_CONFIRMED');

      x_progress := '030';

      dbms_output.put_line(x_message) ;
      /* Now since we have the online report as messages we do not need this

      INSERT INTO po_interface_errors(interface_type,
                                      interface_transaction_id,
                                      column_name,
                                      error_message,
                                      processing_date,
                                      creation_date,
                                      created_by,
                                      last_update_date,
                                      last_updated_by,
                                      last_update_login)
                               VALUES('SCHEDULE_BUILD',
                                      p_schedule_item_id,
                                      'ITEM_CONFIRM_STATUS',
				      x_message,
                                      SYSDATE,
                                      SYSDATE,
                                      x_user_id,
                                      SYSDATE,
                                      x_user_id,
                                      x_login_id);

       */
    END IF;

  --dbms_output.put_line('confirm schedule item : Exiting') ;

  --Return the boolean value to the calling procedure.

  RETURN(x_item_confirm) ;

EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('confirm_schedule_item', x_progress, sqlcode);
  RAISE;

END confirm_schedule_item ;
/*=============================================================================

  PROCEDURE NAME:     confirm_schedule_header()

=============================================================================*/
PROCEDURE confirm_schedule_header(p_schedule_id             in NUMBER,
                                  p_schedule_type           in VARCHAR2,
				  p_communication_code      in VARCHAR2 default null,
				  p_confirm_source          in VARCHAR2,
                                  p_confirmed               IN OUT NOCOPY VARCHAR2) IS

  x_progress                   VARCHAR2(3)    := NULL;

  x_vendor_id                  NUMBER         := 0   ;
  x_vendor_site_id             NUMBER         := 0   ;
  x_item_org_id                NUMBER         := 0   ;
  x_schedule_item_id           NUMBER         := 0   ;
  x_item_id                    NUMBER         := 0   ;
  x_schedule_horizon_start     DATE                  ;
  x_enable_cum_flag            VARCHAR2(1)           ;
  x_cum_period_id              NUMBER         := 0   ;
  x_cum_period_item_id         NUMBER         := 0   ;
  x_asl_id                     NUMBER         := 0   ;
  x_enable_authorization_flag  VARCHAR2(1)           ;
  x_item_confirm               BOOLEAN        := TRUE;
  x_item_confirm_status        VARCHAR2(25)          ;
  x_purchasing_unit_of_measure VARCHAR2(25)          ;
  x_primary_unit_of_measure    VARCHAR2(25)          ;
  x_dummy_org                  NUMBER         := 0   ;
  x_message                    VARCHAR2(240)         ;
  x_open_cum_period            VARCHAR2(1) := 'N';

  -- X_header_confirm is initialized to 'Y' => to confirm schedule header;
  -- When any item can not be confirmed, it will be set to 'N', =>
  -- not to confirm schedule header.

  x_header_confirm            VARCHAR2(1) := 'Y';

  x_user_id                   NUMBER := NVL(fnd_global.user_id, 0);
  x_login_id                  NUMBER := NVL(fnd_global.login_id, 0);


  CURSOR c_all_schedule_items IS
    SELECT csh.schedule_horizon_start,
	   csh.vendor_id,
	   csh.vendor_site_id,
           csi.schedule_item_id,
           csi.item_id,
           csi.organization_id,
           csi.item_confirm_status,
           csi.primary_unit_of_measure,
	   csi.purchasing_unit_of_measure,
           coo.enable_cum_flag
    FROM   chv_schedule_items csi,
           chv_schedule_headers csh,
	   chv_org_options coo
    WHERE  csi.schedule_id     =    p_schedule_id
    AND    csi.schedule_id     =    csh.schedule_id
    AND    csi.organization_id =    coo.organization_id ;

BEGIN

  --dbms_output.put_line('Confirm Header: Entering') ;

  x_progress := '010';

  OPEN c_all_schedule_items;

    -- Set a savepoint.if any item belonging to this header can not
    -- be confirmed then the header can not be confirmed
    -- and rollback all items belong to this header.

  x_progress := '020';

  SAVEPOINT confirm_schedule_savepoint;

  LOOP

  --dbms_output.put_line('Confirm Header: Looping') ;

    x_progress := '030';

    FETCH c_all_schedule_items
    INTO  x_schedule_horizon_start,
	  x_vendor_id,
	  x_vendor_site_id,
          x_schedule_item_id,
          x_item_id,
          x_item_org_id,
          x_item_confirm_status,
          x_primary_unit_of_measure,
	  x_purchasing_unit_of_measure,
	  x_enable_cum_flag  ;

    EXIT WHEN c_all_schedule_items%NOTFOUND;

    x_progress := '040';

    IF nvl(x_item_confirm_status,'IN_PROCESS') = 'IN_PROCESS' then

      --dbms_output.put_line('Confirm Header: item_status'||x_item_confirm_status) ;

      x_item_confirm := confirm_schedule_item(p_schedule_id,
				              x_schedule_item_id,
				              x_vendor_id,
					      x_vendor_site_id,
				              x_item_org_id,
					      x_item_id) ;

    END IF ;

    IF x_item_confirm  = TRUE and
       p_schedule_type = 'PLAN_SCHEDULE' THEN

       -- Item is confirmed and the schedule on the schedule header is a
       -- planning schedule.

       BEGIN

         SELECT 'Y'
         INTO x_open_cum_period
         FROM chv_cum_periods ccp
         WHERE x_schedule_horizon_start between ccp.cum_period_start_date
				      and     ccp.cum_period_end_date
           AND    ccp.organization_id = x_item_org_id;


       EXCEPTION
         WHEN NO_DATA_FOUND THEN null;
	 WHEN OTHERS THEN raise;

       END;


       IF nvl(x_enable_cum_flag,'N') = 'Y' AND x_open_cum_period = 'Y' THEN

         -- Cums are enabled for this Organization.  Select cum details
         -- in order to update high authorizations for the supplier/site
         -- item/org.

           --dbms_output.put_line('Confirm Header: select cum period id') ;

           -- Select the open cum period for the organization.  The period
           -- should cover the schedule horizon start date.

           x_progress := '050' ;

           SELECT ccp.cum_period_id
           INTO   x_cum_period_id
           FROM   chv_cum_periods ccp
           WHERE  x_schedule_horizon_start
 	          BETWEEN ccp.cum_period_start_date
                      AND ccp.cum_period_end_date
           AND    ccp.organization_id = x_item_org_id;

           --dbms_output.put_line('Confirm Header cum period id:'||to_char(x_cum_period_id)) ;

           -- For the item select asl info with reference to authorizations
           -- for the supplier/site/item/org.

           x_progress := '060' ;

           SELECT paa.using_organization_id,
                  paa.asl_id,
                  paa.enable_authorizations_flag
           INTO   x_dummy_org,
	          x_asl_id,
                  x_enable_authorization_flag
           FROM   po_asl_attributes_val_v paa
	   WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_item_org_id
                 AND    paa2.vendor_id = x_vendor_id
                 AND    paa2.vendor_site_id = x_vendor_site_id
                 AND    paa2.item_id = x_item_id))
                or
                (paa.using_organization_id = x_item_org_id))
           AND    paa.vendor_id             = x_vendor_id
           AND    paa.vendor_site_id        = x_vendor_site_id
           AND    paa.item_id               = x_item_id;
/*           GROUP BY paa.asl_id, paa.enable_authorizations_flag; */

           IF x_enable_cum_flag = 'Y' AND
              p_schedule_type = 'PLAN_SCHEDULE' AND
              x_enable_authorization_flag = 'Y' THEN

              -- The schedule is a planning schedule, authorizations for the
              -- supplier/site/item/org are on and the cums are being maintained
              -- for all the items in the Organization so calculate high authorization
              -- information.

              BEGIN

                x_progress := '070' ;

                --Select cum period item id for the supplier/site/item/org.

		SELECT cum_period_item_id
	 	INTO   x_cum_period_item_id
                FROM   chv_cum_period_items
                WHERE  cum_period_id  = x_cum_period_id
                AND    vendor_id      = x_vendor_id
		AND    vendor_site_id = x_vendor_site_id
                AND    item_id        = x_item_id ;

              EXCEPTION WHEN NO_DATA_FOUND then

                x_progress := '080' ;

                -- No cum period item record found so create a new one.

                SELECT chv_cum_period_items_s.nextval
		INTO   x_cum_period_item_id
                FROM   dual ;

	        INSERT into chv_cum_period_items(cum_period_item_id,
					         cum_period_id,
					         organization_id,
						 vendor_id,
						 vendor_site_id,
						 item_id,
						 last_update_date,
						 last_updated_by,
						 creation_date,
						 created_by,
						 last_update_login)
					  VALUES(x_cum_period_item_id,
						 x_cum_period_id,
						 x_item_org_id,
				                 x_vendor_id,
						 x_vendor_site_id,
						 x_item_id,
						 SYSDATE,
						 x_user_id,
						 SYSDATE,
						 x_user_id,
						 x_login_id) ;
             WHEN OTHERS then
	       RAISE ;
             END ;

              x_progress := '080' ;

              --Execute procedure to calculate high authorization quantities for
              --all the authorization codes for the supplier/site/item/org.

              chv_create_authorizations.calc_high_auth_qty(x_item_org_id,
                                                           p_schedule_id,
                                                           x_schedule_item_id,
                                                           x_vendor_id,
                                                           x_vendor_site_id,
                                                           x_item_id,
                                                           x_asl_id,
                                                           x_schedule_horizon_start,
                                                           x_cum_period_item_id);
           END IF;

       END IF ;

    ELSIF x_item_confirm = FALSE THEN

      ROLLBACK TO confirm_schedule_savepoint;

      x_header_confirm := 'N';

      EXIT;

    END IF ;

  END LOOP;

  CLOSE c_all_schedule_items;

    -- Confirm header is x_header_confirm is set to 'Y'

   IF x_header_confirm = 'Y' THEN

      x_progress := '080' ;

      -- All the items have been successfully confirmed so
      -- confirm the schedule header.

      UPDATE chv_schedule_headers
      SET    schedule_status    = 'CONFIRMED',
     	     confirm_date       = SYSDATE,
             last_update_date   = SYSDATE,
             last_updated_by    = x_user_id,
             last_update_login  = x_login_id,
	     communication_code = p_communication_code
      WHERE  schedule_id        = p_schedule_id;

   END IF;

   p_confirmed := x_header_confirm;

EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('confirm_schedules', x_progress, sqlcode);
  RAISE;

END confirm_schedule_header;

END CHV_CONFIRM_SCHEDULES;

/
