--------------------------------------------------------
--  DDL for Package Body WSH_UPGRADE_PICK_SLIP_DATA_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_UPGRADE_PICK_SLIP_DATA_NEW" AS
/* $Header: wshpupdb.pls 120.2 2005/07/28 11:34:20 parkhj noship $ */

--
-- Package
--   	WSH_UPGRADE_PICK_SLIP_DATA_NEW
--
-- Purpose
--

  --
  -- PACKAGE CONSTANTS
  --

    SUCCESS                 CONSTANT  BINARY_INTEGER := 0;
    FAILURE                 CONSTANT  BINARY_INTEGER := -1;

  --
  -- PACKAGE VARIABLES
  --
   error_flag		BOOLEAN := FALSE;
   error_mesg		VARCHAR2(2001);
   long_waybill_count	NUMBER := 0;

  PROCEDURE Init_Mesg( x_mesg IN VARCHAR2) IS
  BEGIN
    error_mesg := substr(x_mesg,1,2000);
  END;

  PROCEDURE Add_Mesg( x_mesg IN VARCHAR2) IS
  BEGIN
    error_mesg := substr(error_mesg || ' '||x_mesg,1,2000);
  END;

  PROCEDURE Insert_Mesg IS
  BEGIN
    insert into wsh_upgrade_log
    ( error_mesg )
    values
    ( error_mesg
    );
  END;

  PROCEDURE Insert_Mesg( x_mesg IN VARCHAR2) IS
  BEGIN
    error_mesg := substr(x_mesg,1,2000);
    insert into wsh_upgrade_log
    ( error_mesg )
    values
    ( error_mesg
    );
  END;

  PROCEDURE Get_Delivery(X_Delivery_ID  IN OUT NOCOPY  NUMBER,
  X_name IN OUT NOCOPY  VARCHAR2
) IS
      CURSOR C2 IS SELECT wsh_new_deliveries_s.nextval FROM sys.dual;

      CURSOR C3 (l_delivery_id NUMBER) IS
      SELECT 1
      FROM wsh_deliveries
      WHERE delivery_id = l_delivery_id;

      temp 		NUMBER;
      temp_id		NUMBER;

   BEGIN

      LOOP
         OPEN C2;
         FETCH C2 INTO temp_id;
            OPEN C3(temp_id);
            FETCH C3 INTO temp;
            IF (C3%NOTFOUND) THEN
               CLOSE C3;
               CLOSE C2;
               EXIT;
            END IF;
            CLOSE C3;
         CLOSE C2;
      END LOOP;

      X_Delivery_Id := temp_id;
      X_Name := TO_CHAR(X_Delivery_Id);

  EXCEPTION
    WHEN others THEN
    rollback;
    Init_mesg('Error in procedure Get_Delivery ');
    Insert_mesg;
    commit;
    raise;
  END Get_Delivery;

  PROCEDURE Get_Departure(X_Departure_Id   IN OUT NOCOPY  NUMBER,
  X_name IN OUT NOCOPY  VARCHAR2
  ) IS
      CURSOR C2 IS SELECT wsh_trips_s.nextval FROM sys.dual;

      CURSOR C3 (l_departure_id NUMBER) IS
      SELECT 1
      FROM  wsh_departures
      WHERE departure_id = l_departure_id;

      temp 		NUMBER;
      temp_id		NUMBER;
   BEGIN

      LOOP
         OPEN C2;
         FETCH C2 INTO temp_id;
            OPEN C3(temp_id);
            FETCH C3 INTO temp;
            IF (C3%NOTFOUND) THEN
               CLOSE C3;
               CLOSE C2;
               EXIT;
            END IF;
            CLOSE C3;
         CLOSE C2;
      END LOOP;

      X_Departure_Id := temp_id;
      X_Name := TO_CHAR(X_Departure_Id);


  EXCEPTION
    WHEN others THEN
      rollback;
      Init_mesg('Error in procedure Get_Departure');
      Insert_mesg;
      commit;
      Raise;
  END Get_Departure;

  --
  -- Name
  --   FUNCTION Insert_Row
  --
  -- Purpose
  --   Gets the delivery_id to be used in creating deliveries when
  --   inserting picking line details
  --
  -- Arguments
  --   p_header_id		=> order header id
  --   p_ship_to_site_use_id	=> ship to site use id (ultimate ship to)
  --   p_ship_method_code	=> ship method (freight carrier)
  --
  -- Return Values
  --  -1 => Failure
  --   others => delivery_id
  --


  FUNCTION Insert_Row(
	p_header_id		IN		BINARY_INTEGER,
	p_departure_id		IN OUT NOCOPY 		BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

  CURSOR get_picking_info(x_header_id IN BINARY_INTEGER) IS
  SELECT order_header_id,
	 ship_to_site_use_id,
	 ship_method_code,
	 warehouse_id,
	 date_shipped,
	 date_confirmed,
	 waybill_num,
	 weight,
	 weight_unit_code,
	 picked_by_id,
	 packed_by_id,
	 context,
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
	 creation_date,
	 created_by,
	 last_updated_by,
	 last_update_login,
      last_update_date,
	 expected_arrival_date	-- added: for bug 1413000
  FROM   SO_PICKING_HEADERS_ALL
  WHERE  picking_header_id = x_header_id;

  CURSOR get_order_info(x_header_id IN BINARY_INTEGER) IS
  SELECT NVL(CUSTOMER_ID,-1),
	 NVL(FOB_CODE, 'XX'),
	 NVL(FREIGHT_TERMS_CODE, 'XX'),
	 CURRENCY_CODE
  FROM   SO_HEADERS_ALL
  WHERE  HEADER_ID = x_header_id;

  CURSOR count_shipped_pls (x_header_id IN BINARY_INTEGER) IS
  SELECT count(*)
  FROM   SO_PICKING_LINES_ALL
  WHERE  picking_header_id = x_header_id
  AND    nvl(shipped_quantity,0) > 0;

  p_order_header_id	BINARY_INTEGER;
  p_ship_to_site_use_id BINARY_INTEGER;
  p_ship_method_code	VARCHAR2(30);
  p_organization_id	BINARY_INTEGER;
  p_date_shipped	DATE;
  p_date_confirmed	DATE;
  p_waybill_num		VARCHAR2(50);
  p_weight		NUMBER;
  p_weight_unit_code	VARCHAR2(3);
  p_picked_by_id	BINARY_INTEGER;
  p_packed_by_id	BINARY_INTEGER;
  p_creation_date	DATE;
  p_created_by          BINARY_INTEGER;
  p_last_updated_by     BINARY_INTEGER;
  p_last_update_login   BINARY_INTEGER;
  p_last_update_date	DATE;
  p_expected_arrival_date	DATE;  -- added: for bug 1413000
  v_customer_id		BINARY_INTEGER;
  v_fob_code		VARCHAR2(30);
  v_freight_terms_code  VARCHAR2(30);
  v_currency_code	VARCHAR2(15);
  v_delivery_name	VARCHAR2(15);
  v_delivery_id		BINARY_INTEGER := -1;
  v_departure_name	VARCHAR2(15);
  p_pick_line_count	BINARY_INTEGER;
  p_context            VARCHAR2(150);
  p_attribute1         VARCHAR2(150);
  p_attribute2         VARCHAR2(150);
  p_attribute3         VARCHAR2(150);
  p_attribute4         VARCHAR2(150);
  p_attribute5         VARCHAR2(150);
  p_attribute6         VARCHAR2(150);
  p_attribute7         VARCHAR2(150);
  p_attribute8         VARCHAR2(150);
  p_attribute9         VARCHAR2(150);
  p_attribute10        VARCHAR2(150);
  p_attribute11        VARCHAR2(150);
  p_attribute12        VARCHAR2(150);
  p_attribute13        VARCHAR2(150);
  p_attribute14        VARCHAR2(150);
  p_attribute15        VARCHAR2(150);


  BEGIN

    -- Fetch all picking header parameters
    OPEN  get_picking_info(p_header_id);
    FETCH get_picking_info
    INTO  p_order_header_id,
	  p_ship_to_site_use_id,
	  p_ship_method_code,
	  p_organization_id,
	  p_date_shipped,
	  p_date_confirmed,
	  p_waybill_num,
	  p_weight,
	  p_weight_unit_code,
	  p_picked_by_id,
	  p_packed_by_id,
	  p_context,
	  p_attribute1,
	  p_attribute2,
	  p_attribute3,
	  p_attribute4,
	  p_attribute5,
	  p_attribute6,
	  p_attribute7,
	  p_attribute8,
	  p_attribute9,
	  p_attribute10,
	  p_attribute11,
	  p_attribute12,
	  p_attribute13,
	  p_attribute14,
	  p_attribute15,
	  p_creation_date,
	  p_created_by,
	  p_last_updated_by,
	  p_last_update_login,
	  p_last_update_date,
	  p_expected_arrival_date;
    CLOSE get_picking_info;

    -- Fetch all delivery parameters
    OPEN  get_order_info(p_order_header_id);
    FETCH get_order_info
    INTO  v_customer_id,
	  v_fob_code,
	  v_freight_terms_code,
	  v_currency_code;

    IF get_order_info%NOTFOUND THEN
       Init_Mesg('Error: Cannot find order header, header_id '|| p_order_header_id);
       RETURN FAILURE;
    END IF;

    CLOSE get_order_info;

    IF (p_ship_to_site_use_id is NULL) THEN
       Init_Mesg('ERROR: Ship_To_Site_Use_Id column for picking_header_id '||p_header_id||' in so_picking_headers_all is NULL');
       RETURN FAILURE;
    END IF;

    IF (v_customer_id is NULL) THEN
       Init_Mesg('ERROR: Customer_Id column for header_id '|| p_order_header_id ||' in so_headers_all is NULL');
       RETURN FAILURE;
    END IF;

    IF (p_date_shipped is NULL) THEN
       OPEN count_shipped_pls(p_header_id);
       FETCH count_shipped_pls INTO p_pick_line_count;
       CLOSE count_shipped_pls;

       IF p_pick_line_count > 0 THEN
	       Init_Mesg('ERROR: Date_Shipped column for picking_header_id '||p_header_id||' in so_picking_headers_all is NULL');
          RETURN FAILURE;
        ELSE
          p_date_shipped := p_last_update_date;
        END IF;
    END IF;


    Get_Departure( p_departure_id, v_departure_name);

    INSERT INTO wsh_departures(
              organization_id,
              departure_id,
              name,
              source_code,
              arrive_after_departure_id,
              status_code,
              report_set_id,
              date_closed,
              vehicle_item_id,
              vehicle_number,
              freight_carrier_code,
              planned_departure_date,
              actual_departure_date,
              bill_of_lading,
              gross_weight,
              net_weight,
              weight_uom_code,
              volume,
              volume_uom_code,
              fill_percent,
              seal_code,
              routing_instructions,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              program_application_id
             ) VALUES (
              p_organization_id,
              p_departure_id,
              v_departure_name,
              'S',
              NULL,
              'CL',
              NULL,
              p_date_confirmed,
              NULL,
              '',
              p_ship_method_code,
              p_date_shipped,
              p_date_shipped,
              NULL,
              p_weight,
              p_weight,
              p_weight_unit_code,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              p_creation_date,
              p_created_by,
              SYSDATE,
              p_last_updated_by,
              p_last_update_login,
	           -999
	);

    Get_Delivery(v_delivery_id, v_delivery_name);

    IF ( length(p_waybill_num) > 30 ) THEN
	 p_waybill_num := substrb(p_waybill_num,1,30);
	 long_waybill_count := long_waybill_count + 1;
    END IF;


    INSERT INTO wsh_deliveries(
        organization_id,
        delivery_id,
        name,
        source_code,
        planned_departure_id,
        actual_departure_id,
        status_code,
        loading_order_flag,
        date_closed,
        report_set_id,
        sequence_number,
        customer_id,
        ultimate_ship_to_id,
        intermediate_ship_to_id,
        pooled_ship_to_id,
        waybill,
        gross_weight,
        weight_uom_code,
        volume,
        volume_uom_code,
        picked_by_id,
        packed_by_id,
        expected_arrival_date,
        asn_date_sent,
        asn_seq_number,
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
        freight_carrier_code,
        freight_terms_code,
        currency_code,
        fob_code,
        creation_date,
        created_by,
        last_update_date,
	   last_updated_by,
        last_update_login,
	   program_application_id
	) VALUES (
	p_organization_id,
     v_delivery_id,
     v_delivery_name,
     'S',
     p_departure_id,
	p_departure_id,
	'CL',
	NULL,
	p_date_confirmed,
	NULL,
	NULL,
	v_customer_id,
	p_ship_to_site_use_id,
	NULL,
	NULL,
	p_waybill_num,
	p_weight,
	p_weight_unit_code,
	NULL,
	NULL,
	p_picked_by_id,
	p_packed_by_id,
	p_expected_arrival_date,     -- added: for bug 1413000
	NULL,
	NULL,
	p_context,  -- attribute_category
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15,
	p_ship_method_code,
	v_freight_terms_code,
	v_currency_code,
	v_fob_code,
	p_creation_date,
     p_created_by,
     SYSDATE,
     p_last_updated_by,
     p_last_update_login,
     -999
    );

    RETURN v_delivery_id;

  EXCEPTION
     WHEN OTHERS THEN
        IF (get_picking_info%ISOPEN) THEN
		     CLOSE get_picking_info;
	     END IF;
        IF (get_order_info%ISOPEN) THEN
           CLOSE get_order_info;
        END IF;
        IF (count_shipped_pls%ISOPEN) THEN
           CLOSE count_shipped_pls;
        END IF;
        Rollback;	--  to savepoint before_insert; <bug 1475847>
        Init_mesg('Error in creating delivery/departure for picking_header_id '||p_header_id);
        Insert_mesg;
        commit;
 	raise;
  END Insert_Row;

PROCEDURE Upgrade_Rows ( num_rows    IN BINARY_INTEGER,
			 total_workers IN BINARY_INTEGER,
			 worker	IN BINARY_INTEGER,
                         batch_number IN BINARY_INTEGER
                         ) IS

  /* for parallel execution */

  l_job_min			BINARY_INTEGER := 0;
  l_job_max			BINARY_INTEGER := 0;
  l_lower_limit                 BINARY_INTEGER := 0;
  l_upper_limit                 BINARY_INTEGER := 0;
  l_worker_job_min		BINARY_INTEGER := 0;
  l_worker_job_max		BINARY_INTEGER := 0;
  l_commit_count		BINARY_INTEGER := 0;
  l_test NUMBER := 0;
  u_picking_header_id		BINARY_INTEGER;
  u_delivery_id			BINARY_INTEGER;
  u_departure_id		BINARY_INTEGER;
  i 				BINARY_INTEGER;
  j 				BINARY_INTEGER;
  NULL_ERROR			EXCEPTION;

  CURSOR get_header_id(l_min BINARY_INTEGER, l_max BINARY_INTEGER) IS
  SELECT picking_header_id
  FROM   SO_PICKING_HEADERS_ALL
  WHERE
  delivery_id is NULL
  AND    status_code = 'CLOSED'
  AND    picking_header_id BETWEEN l_min and l_max;

  CURSOR get_any_row IS
  SELECT 1
  FROM so_picking_headers_all WHERE
   delivery_id is NULL and
   picking_header_id > 0 and
   status_code = 'CLOSED';


BEGIN

  long_waybill_count := 0;

  IF num_rows IS NULL or num_rows = 0 THEN
    RAISE NULL_ERROR;
  END IF;

  open get_any_row;
  fetch get_any_row into l_test;
  if get_any_row%FOUND then

/*=======================================================
  This fix trifurcates the Picking Header ID Processing
  as per the logic given below:

  1. If wshrpupd.sql invokes this, batch_number = 0 and
     only picking_header_ids from 1 to 9999 will be processed.

  2. If wshrpupd01.sql invokes this, batch_number = 1 and
     only picking_header_ids from 10000 to 99999999 will be
     processed.

  3. If wshrpupd02.sql invokes this, batch_number = 2 and
     only picking_header_ids >= 100000000 will be processed.
========================================================*/

  IF batch_number = 0 THEN

    SELECT  NVL(MIN(picking_header_id),0), NVL(MAX(picking_header_id),0)
    INTO	l_job_min, l_job_max
    FROM	SO_PICKING_HEADERS_ALL
    WHERE   picking_header_id between 1 and 9999
    AND     delivery_id IS NULL
    AND 	status_code = 'CLOSED';

  ELSIF batch_number = 1 THEN

    SELECT  NVL(MIN(picking_header_id),0), NVL(MAX(picking_header_id),0)
    INTO	l_job_min, l_job_max
    FROM	SO_PICKING_HEADERS_ALL
    WHERE   picking_header_id between 10000 and 99999999
    AND     delivery_id IS NULL
    AND 	status_code = 'CLOSED';

  ELSIF batch_number = 2 THEN

    SELECT  NVL(MIN(picking_header_id),0), NVL(MAX(picking_header_id),0)
    INTO	l_job_min, l_job_max
    FROM	SO_PICKING_HEADERS_ALL
    WHERE   picking_header_id >= 100000000
    AND     delivery_id IS NULL
    AND 	status_code = 'CLOSED';

  END IF;


  l_worker_job_min := l_job_min + TRUNC(((worker -1)*(l_job_max - l_job_min)) / total_workers);
  l_worker_job_max := l_job_min + TRUNC((worker * (l_job_max - l_job_min)) / total_workers);

  if worker <> total_workers then
     l_worker_job_max := l_worker_job_max - 1;
  end if;

  Insert_Mesg('Worker: ' || to_char(worker) || ' processing picking_header_id ' ||
	   to_char(l_worker_job_min) || '..' || to_char(l_worker_job_max));
  commit;

  l_lower_limit := l_worker_job_min;
  l_upper_limit := l_worker_job_min - 1;

  -- Bug 1475858 : We need to close the cursor after the commit and re-open it to avoid Snapshot Too Old error.

  LOOP
     -- exit when upper limit already reach the max in previous round
     EXIT WHEN l_upper_limit = l_worker_job_max;

	  -- set the upper limit for this round
     if (l_worker_job_max - l_upper_limit) > num_rows then
         l_upper_limit := l_upper_limit + num_rows;
     else
         l_upper_limit := l_worker_job_max;
     end if;

     Insert_Mesg('Upgrading picking header id:' || l_lower_limit ||' to '|| l_upper_limit);

    OPEN  get_header_id(l_lower_limit, l_upper_limit);
    LOOP

       FETCH get_header_id INTO  u_picking_header_id;

       EXIT WHEN get_header_id%NOTFOUND;

       u_departure_id := NULL;
       u_delivery_id := Insert_Row( u_picking_header_id, u_departure_id);

       IF (u_delivery_id = FAILURE ) OR (u_departure_id is NULL) THEN
       	  Add_Mesg('Error: Failed to create departure or delivery for picking_header_id: ' ||u_picking_header_id||' , ignoring ...');
          Insert_Mesg;
       ELSE
          UPDATE SO_FREIGHT_CHARGES
          SET delivery_id = u_delivery_id
          WHERE picking_header_id = u_picking_header_id;

          UPDATE SO_PICKING_HEADERS_ALL PH
          SET PH.delivery_id = u_delivery_id
          WHERE PH.picking_header_id = u_picking_header_id;

          UPDATE SO_PICKING_LINE_DETAILS
          SET delivery_id = u_delivery_id,
          departure_id = u_departure_id,
          dpw_assigned_flag = NULL
          WHERE picking_line_detail_id IN
          ( SELECT pld.picking_line_detail_id
            FROM
               so_picking_line_details pld,
               so_picking_lines_all pl
               WHERE pl.picking_header_id = u_picking_header_id
               AND pld.picking_line_id = pl.picking_line_id );
       END IF;


    END LOOP;

    CLOSE get_header_id;
    commit;

    l_lower_limit := l_lower_limit + num_rows;

  END LOOP;
  Insert_Mesg('Long waybill count : ' || to_char(long_waybill_count));
  ELSE
   Insert_Mesg('No closed row in table SO_PICKING_HEADERS_ALL, skipping Upgrade_Row');
  END IF;
  close get_any_row;
  Commit;
  EXCEPTION
     WHEN NULL_ERROR THEN
             rollback;
	     Init_Mesg('Number of rows to commit at a time cannot be NULL or zero');
             Insert_Mesg;
             commit;
     WHEN OTHERS THEN
     IF (get_header_id%ISOPEN) THEN
        CLOSE get_header_id;
     END IF;
     ROLLBACK;
     Init_Mesg( sqlerrm || ' ' || to_char(sqlcode));
     Insert_Mesg;
     commit;
     raise;

END Upgrade_Rows;

END WSH_UPGRADE_PICK_SLIP_DATA_NEW;

/
