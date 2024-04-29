--------------------------------------------------------
--  DDL for Package Body CHV_CREATE_AUTHORIZATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_CREATE_AUTHORIZATIONS" as
/* $Header: CHVPRAUB.pls 115.1 99/07/17 01:29:32 porting sh $ */

/*====================== CHV_CREATE_AUTHORIZATIONS ==========================*/

/*=============================================================================

  PROCEDURE NAME:     insert_authorizations()

=============================================================================*/
PROCEDURE insert_authorizations( p_organization_id         IN      NUMBER,
			 p_schedule_id                     IN      NUMBER,
			 p_schedule_item_id                IN      NUMBER,
                         p_asl_id                          IN      NUMBER,
			 p_horizon_start_date              IN      DATE,
			 p_horizon_end_date                IN      DATE,
			 p_starting_auth_qty		   IN      NUMBER,
			 p_starting_auth_qty_primary	   IN      NUMBER,
			 p_starting_cum_qty		   IN      NUMBER,
			 p_starting_cum_qty_primary	   IN      NUMBER,
                         p_cum_period_end_date             IN      DATE,
                         p_purch_unit_of_measure           IN      VARCHAR2,
                         p_primary_unit_of_measure         IN      VARCHAR2,
			 p_enable_cum_flag                 IN      VARCHAR2) IS

  x_progress                   VARCHAR2(3) := NULL;
  x_authorization_code         VARCHAR2(25);
  x_authorization_sequence     NUMBER := 0 ;
  x_timefence_days             NUMBER := 0 ;

  x_auth_end_date              DATE;
  x_authorization_qty          NUMBER := 0 ;
  x_authorization_qty_primary  NUMBER := 0 ;

  x_user_id                    NUMBER := 0 ;
  x_login_id                   NUMBER := 0 ;

  -- get the authorizations that are specified in the chv_authorizations
  -- for the supplier/site/item/org.

  CURSOR x_asl_auth_codes IS
    SELECT authorization_code,
           authorization_sequence,
           timefence_days
    FROM   chv_authorizations
    WHERE  reference_type = 'ASL'
    AND    reference_id = p_asl_id
    AND    using_organization_id = nvl(p_organization_id, -1);

BEGIN

  x_progress := '010';

  -- Get x_user_id and x_login_id from the global variable set.

  x_user_id  := NVL(fnd_global.user_id, 0);
  x_login_id := NVL(fnd_global.login_id, 0);

  OPEN x_asl_auth_codes;

  LOOP

    x_progress := '020';

    FETCH x_asl_auth_codes
    INTO  x_authorization_code,
          x_authorization_sequence,
          x_timefence_days;

    EXIT WHEN x_asl_auth_codes%NOTFOUND;

    -- Calculate authorization end date for each authorization based on the
    -- least of (p_horizon_end_date, cum_period_end_date and
    -- horizon_start_date + timefence_days) If cum period end date is null
    -- then auth end date is the least of horizon start date + timefence and
    -- horizon end date.

    x_authorization_qty := 0 ;
    x_authorization_qty_primary := 0 ;

    x_auth_end_date := LEAST( p_horizon_end_date,
                             (p_horizon_start_date + (x_timefence_days-1)),
                              nvl(p_cum_period_end_date,LEAST((p_horizon_start_date + (x_timefence_days-1)),
						              p_horizon_end_date))
                            ) ;

    -- Get authorization quantities in purchasing and primary UOM's from
    -- CHV_ITEM_ORDERS based on the authorization end date calculated above
    -- for each authorization

    x_progress := '030';

    BEGIN

      --May not find any records for the given authorization within the
      --time fence.  No need to raise an exception.  Authorization for
      --the schedule item will be created with zero quantity.

      SELECT sum(order_quantity),
  	     sum(order_quantity_primary)
      INTO   x_authorization_qty,
  	     x_authorization_qty_primary
      FROM   chv_item_orders cio
      WHERE  cio.schedule_id = p_schedule_id
      AND    cio.schedule_item_id = p_schedule_item_id
      AND    cio.due_date between p_horizon_start_date  and
    			          x_auth_end_date ;

    EXCEPTION
      WHEN OTHERS THEN null ;

    END ;

  --dbms_output.put_line('Auth Code:'||x_authorization_code) ;
  --dbms_output.put_line('Time Fence:'||to_char(x_timefence_days)) ;
  --dbms_output.put_line('Auth End:'||to_char(x_auth_end_date,'DD-MON-YYYY')) ;
  --dbms_output.put_line('Pri Qty:'||to_char(x_authorization_qty)) ;
  --dbms_output.put_line('Pur Qty:'||to_char(x_authorization_qty_primary)) ;

    -- Insert into CHV_AUTHORIZATIONS table the authorization code date.

    x_progress := '040';

    INSERT INTO chv_authorizations(reference_id,
                                   reference_type,
                                   authorization_code,
                                   authorization_sequence,
				   using_organization_id,
                                   last_update_date,
                                   last_updated_by,
                                   creation_date,
                                   created_by,
                                   primary_unit_of_measure,
                                   purchasing_unit_of_measure,
                                   timefence_days,
                                   cutoff_date,
                                   schedule_quantity_primary,
                                   schedule_quantity,
                                   last_update_login)
                            VALUES(p_schedule_item_id,
                                   'SCHEDULE_ITEMS',
                                   x_authorization_code,
                                   x_authorization_sequence,
				   p_organization_id,
                                   SYSDATE,
                                   x_user_id,
                                   SYSDATE,
                                   x_user_id,
                                   p_primary_unit_of_measure,
                                   p_purch_unit_of_measure,
                                   x_timefence_days,
                                   x_auth_end_date,
                                   nvl(x_authorization_qty_primary,0) +
                                            nvl(p_starting_auth_qty_primary,0),
                                   nvl(x_authorization_qty,0) +
                                            nvl(p_starting_auth_qty,0),
                                   x_login_id);
  END LOOP;

  x_progress := '050';
  CLOSE x_asl_auth_codes;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('insert_authorizations', x_progress, sqlcode);
    RAISE;

END insert_authorizations;

/*=============================================================================

  PROCEDURE NAME:     calc_high_auth_qty()

=============================================================================*/
PROCEDURE calc_high_auth_qty(p_organization_id                 IN      NUMBER,
			     p_schedule_id                     IN      NUMBER,
			     p_schedule_item_id                IN      NUMBER,
                             p_vendor_id                       IN      NUMBER,
			     p_vendor_site_id                  IN      NUMBER,
                             p_item_id                         IN      NUMBER,
                             p_asl_id                          IN      NUMBER,
                             p_horizon_start_date              IN      DATE,
                             p_cum_period_item_id              IN      NUMBER) IS

  x_progress                       VARCHAR2(3) := NULL;

  x_authorization_code             VARCHAR2(25);
  x_primary_unit_of_measure        VARCHAR2(25);
  x_purchasing_unit_of_measure     VARCHAR2(25);
  x_authorization_sequence         NUMBER := 0 ;
  x_timefence_days                 NUMBER := 0 ;
  x_schedule_quantity              NUMBER := 0 ;
  x_schedule_quantity_primary      NUMBER := 0 ;
  x_high_auth_quantity             NUMBER := 0 ;
  x_high_auth_qty_primary          NUMBER := 0 ;
  x_user_id                        NUMBER := 0 ;
  x_login_id                       NUMBER := 0 ;

  -- Get all the authorization codes from chv_authorizations for this x_asl_id
  -- for the supplier/site/item/org.

  CURSOR c_auth_codes IS

    SELECT cau.authorization_code,
           cau.authorization_sequence,
           cau.primary_unit_of_measure,
           cau.purchasing_unit_of_measure,
           cau.timefence_days
    FROM   chv_authorizations cau
    WHERE  cau.reference_type = 'ASL'
    AND    cau.reference_id   = p_asl_id
    AND    cau.using_organization_id = nvl(p_organization_id, -1);

BEGIN

  -- Get user id and login id from the global variable set.

  x_user_id  := NVL(fnd_global.user_id, 0);
  x_login_id := NVL(fnd_global.login_id, 0);

  x_progress := '010';

  OPEN c_auth_codes;

  LOOP

    x_progress := '020';

    FETCH c_auth_codes
    INTO  x_authorization_code,
          x_authorization_sequence,
          x_primary_unit_of_measure,
          x_purchasing_unit_of_measure,
          x_timefence_days;

    EXIT WHEN c_auth_codes%NOTFOUND;

    -- Select schedule(current) authorization quantity from chv_authorizations
    -- for every authorization code retreived in the above cursor
    -- for the supplier/site/item/org.

    x_progress := '030';

    SELECT cau.schedule_quantity,
           cau.schedule_quantity_primary
    INTO   x_schedule_quantity,
           x_schedule_quantity_primary
    FROM   chv_authorizations cau
    WHERE  cau.reference_id       = p_schedule_item_id
    AND    cau.reference_type     = 'SCHEDULE_ITEMS'
    AND    cau.authorization_code = x_authorization_code ;

    -- Select high authorization information for the cum period for each
    -- authorization for the supplier/site/item/org.

    x_progress := '040';

    BEGIN

      SELECT high_auth_quantity,
             high_auth_qty_primary
      INTO   x_high_auth_quantity,
             x_high_auth_qty_primary
      FROM   chv_authorizations cau
      WHERE  cau.reference_id       = p_cum_period_item_id
      AND    cau.reference_type     = 'CUM_PERIODS'
      AND    cau.authorization_code = x_authorization_code ;

      -- If this schedule(current) authorization quantity is over previous
      -- high authorization quantities then update chv_authorizations
      -- with this new qty and the schedule id.

      x_progress := '050';

      IF x_schedule_quantity_primary > x_high_auth_qty_primary THEN

        UPDATE chv_authorizations
        SET    high_auth_quantity         =  x_schedule_quantity,
               high_auth_qty_primary      =  x_schedule_quantity_primary,
               high_auth_schedule_item_id =  p_schedule_item_id,
               schedule_quantity          =  x_schedule_quantity,
               schedule_quantity_primary  =  x_schedule_quantity_primary,
               last_update_date           =  SYSDATE,
               last_updated_by            =  x_user_id,
               last_update_login          =  x_login_id
        WHERE  reference_id               =  p_cum_period_item_id
        AND    reference_type             =  'CUM_PERIODS'
        AND    authorization_code         =  x_authorization_code ;

      ELSE

        UPDATE chv_authorizations
        SET    schedule_quantity          =  x_schedule_quantity,
               schedule_quantity_primary  =  x_schedule_quantity_primary,
               last_update_date           =  SYSDATE,
               last_updated_by            =  x_user_id,
               last_update_login          =  x_login_id
        WHERE  reference_id               =  p_cum_period_item_id
        AND    reference_type             =  'CUM_PERIODS'
        AND    authorization_code         =  x_authorization_code ;

      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND then

      -- If this is the first schedule(current) authorization for the
      -- cum period insert a new high authorization record.

      x_progress := '60' ;

      INSERT INTO chv_authorizations (reference_id,
                                      reference_type,
                                      authorization_code,
                                      authorization_sequence,
                                      last_update_date,
                                      last_updated_by,
                                      creation_date,
                                      created_by,
                                      primary_unit_of_measure,
                                      purchasing_unit_of_measure,
                                      timefence_days,
                                      cutoff_date,
                                      schedule_quantity_primary,
                                      schedule_quantity,
                                      high_auth_qty_primary,
                                      high_auth_quantity,
                                      high_auth_schedule_item_id,
                                      last_update_login)
                              VALUES (p_cum_period_item_id,
                                      'CUM_PERIODS',
                                      x_authorization_code,
                                      x_authorization_sequence,
                                      SYSDATE,
                                      x_user_id,
                                      SYSDATE,
                                      x_user_id,
                                      x_primary_unit_of_measure,
                                      x_purchasing_unit_of_measure,
                                      x_timefence_days,
                                      NULL,
                                      x_schedule_quantity_primary,
                                      x_schedule_quantity,
                                      x_schedule_quantity_primary,
                                      x_schedule_quantity,
                                      p_schedule_item_id,
                                      x_login_id);
    END ;

  END LOOP;

  CLOSE c_auth_codes;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('calc_high_auth_qty', x_progress, sqlcode);
    RAISE;

END CALC_HIGH_AUTH_QTY;

END chv_create_authorizations;

/
