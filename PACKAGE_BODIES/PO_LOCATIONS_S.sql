--------------------------------------------------------
--  DDL for Package Body PO_LOCATIONS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LOCATIONS_S" AS
/* $Header: POXCOL2B.pls 120.2 2005/09/15 05:11:11 asista noship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');

/* create client package body */
/*
PACKAGE BODY PO_LOCATIONS_S IS
*/

/* local procedure - added for hz_location changes : bug 1942696 */
PROCEDURE validate_hz_loc_info(p_loc_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Location_id_record_type);

/*===========================================================================

  FUNCTION NAME:	get_ship_to_location()

===========================================================================*/
FUNCTION get_ship_to_location(X_deliver_to_loc_id IN 	  NUMBER,
			      X_ship_to_loc_id    IN OUT NOCOPY  NUMBER) return BOOLEAN IS

  X_progress      varchar2(3) := NULL;
  X_location_id_v number      := NULL;

BEGIN

  X_progress := '010';

  /* Select the ship-to location associated with a given
  ** deliver-to location.
  */

begin
  SELECT ship_to_location_id
  INTO   X_ship_to_loc_id
  FROM   hr_locations_all
  WHERE  location_id = X_deliver_to_loc_id;

exception
       --bug 1942696 hr_location changes to reflect the new view
      when no_data_found then
       SELECT location_id
       INTO   X_ship_to_loc_id
       FROM   hz_locations
       WHERE  location_id = X_deliver_to_loc_id;
end;

  /* Check to see if this location is still valid.  If so, return TRUE.
  ** If not, return FALSE.
  */

begin
  SELECT location_id
  INTO   X_location_id_v
  FROM	 hr_locations_all
  WHERE  location_id = X_ship_to_loc_id
  AND    sysdate < nvl(inactive_date, sysdate + 1);
exception
      when no_data_found then
         --bug 1942696 hr_location changes to reflect the new view
        SELECT location_id
        INTO   X_location_id_v
        FROM   hz_locations
        WHERE  location_id = X_ship_to_loc_id
        AND    sysdate < nvl(address_expiration_date, sysdate + 1);
end;

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('get_ship_to_location',X_progress,sqlcode);
    raise;

END get_ship_to_location;

/*===========================================================================

  FUNCTION NAME:	val_location(...)

===========================================================================*/

FUNCTION val_location
(
        x_location_id           IN NUMBER,
        x_destination_type      IN VARCHAR2,
        x_organization_id       IN NUMBER
)
RETURN NUMBER IS

x_progress VARCHAR2(3) := NULL;
x_status   VARCHAR2(20) := NULL;

BEGIN
   x_progress := '000';

   IF x_location_id IS NULL THEN
     IF x_destination_type = 'RECEIVING' THEN
        RETURN 2; /* missing receive to */
     ELSE
        RETURN 3; /* missing deliver to */
     END IF;
   END IF;

 begin
   SELECT 'location_ok'
   INTO   x_status
   FROM   HR_LOCATIONS_ALL
   WHERE  LOCATION_ID = x_location_id
   AND    NVL(INVENTORY_ORGANIZATION_ID, x_organization_id) = x_organization_id
   AND    NVL(INACTIVE_DATE, SYSDATE+1) > SYSDATE;

 exception
  when no_data_found then
    --bug 1942696 hr_location changes to reflect the new view
   SELECT 'location_ok'
   INTO   x_status
   FROM   HZ_LOCATIONS
   WHERE  LOCATION_ID = x_location_id
   AND    NVL(ADDRESS_EXPIRATION_DATE, SYSDATE+1) > SYSDATE;
 end;

   IF x_status = 'location_ok' THEN
      RETURN 0;
   ELSE
      RETURN 1;
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 4; /* Require this Staate in Release Shipment */
   WHEN OTHERS THEN
      po_message_s.sql_error('val_location', x_progress, sqlcode);
   RAISE;


END val_location;

/*===========================================================================

  PROCEDURE NAME:	get_loc_attributes(...)

===========================================================================*/

procedure get_loc_attributes ( X_temp_loc_id IN number, X_loc_dsp IN OUT NOCOPY varchar2,
                                        X_org_id IN OUT NOCOPY  number)  IS
 X_progress varchar2(3) := '';

 begin
         X_progress := '010';
         X_org_id := NULL;
         X_loc_dsp := NULL;


           select location_code,
                  inventory_organization_id
           into   X_loc_dsp,
                  X_org_id
           from   hr_locations
           where  location_id = X_temp_loc_id;

 exception
             when no_data_found then
             begin
--- As part of hr_location changes bug# 2393886
               select (substrb(rtrim(address1)||'-'||rtrim(city),1,20)) location_code ,
                      null
               into   X_loc_dsp,
                      x_org_id
               from   hz_locations
               where  location_id = X_temp_loc_id;
              exception
                when no_data_found then
                  X_loc_dsp := '';
                  X_org_id := '';
            end;
             when too_many_rows then
                  X_loc_dsp := '';
                  X_org_id := '';
             when others then
                   po_message_s.sql_error('get_loc_attributes',X_progress,sqlcode);
                   raise;
 end get_loc_attributes;

/*===========================================================================

  PROCEDURE NAME:	get_tax_name(...)

===========================================================================*/
procedure get_tax_name ( X_location_id IN NUMBER,
                          X_org_id      IN NUMBER,
                          X_tax_name    IN OUT NOCOPY VARCHAR2) IS

  X_Progress varchar2(3) := '';

begin

  X_Progress := '010';
  --
  -- <R12 eTax Integration>
  -- This procedure is no longer used
  --
exception
    when no_data_found then
         null;   /* Not an error */
    when others then
         po_message_s.sql_error('get_tax_name',X_progress,sqlcode);
         raise;

end get_tax_name;



/*===========================================================================

  PROCEDURE NAME:	get_loc_org (...)

===========================================================================*/

procedure get_loc_org ( X_location_id IN NUMBER,
                        X_sob_id      IN NUMBER,
                        X_org_id      IN OUT NOCOPY NUMBER,
                        X_org_code    IN OUT NOCOPY VARCHAR2,
			X_org_name    IN OUT NOCOPY VARCHAR2) IS

  x_progress varchar2(3) := '';

begin

     x_progress := '010';
     x_org_id := NULL;
     x_org_name := NULL;
     x_org_code := NULL;

	SELECT hrl.inventory_organization_id
	INTO   x_org_id
	FROM   hr_locations	hrl,
	       org_organization_definitions ood
	WHERE  ood.organization_id = hrl.inventory_organization_id
	AND    ood.set_of_books_id = x_sob_id
	AND    hrl.location_id	   = x_location_id;

    x_progress := '020';

	SELECT ood.organization_name,
               ood.organization_code
	INTO   x_org_name,
               X_org_code
	FROM   org_organization_definitions ood
	WHERE  ood.organization_id = x_org_id;

exception
 	when no_data_found then
	  x_org_id 	:= null;
	  x_org_name 	:= null;
        when others then
             po_message_s.sql_error('get_loc_org', x_progress, sqlcode);
             raise;

end get_loc_org;

/*===========================================================================

  PROCEDURE NAME:	val_if_inventory_destination

===========================================================================*/

/*
**   Check to see if any of the distributions are of type inventory
*/
FUNCTION val_if_inventory_destination (X_line_location_id  IN NUMBER,
				       X_shipment_line_id     IN NUMBER)
RETURN BOOLEAN IS

X_number_of_inv_dest         NUMBER := 0;
X_progress       	     VARCHAR2(4)  := '000';

BEGIN

   X_progress := '600';
   /*
   ** Check to see which id is set to know which table to check for
   ** inventory destination_type_code
   */
   IF (X_line_location_id IS NOT NULL) THEN

      X_progress := '610';

      SELECT count(1)
      INTO   X_number_of_inv_dest
      FROM   po_distributions pd
      WHERE  pd.line_location_id = X_line_location_id
      AND    pd.destination_type_code = 'INVENTORY';

   ELSE

      X_progress := '620';

      SELECT count(1)
      INTO   X_number_of_inv_dest
      FROM   rcv_shipment_lines rsl
      WHERE  rsl.shipment_line_id = X_shipment_line_id
      AND    rsl.destination_type_code = 'INVENTORY';
   END IF;

   IF (X_number_of_inv_dest > 0) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_if_inventory_destination', x_progress, sqlcode);
   RAISE;

END val_if_inventory_destination;



/*===========================================================================

  PROCEDURE NAME:	get_location_code (...)

===========================================================================*/

procedure get_location_code (x_location_id 	IN  	NUMBER,
			     x_location_code 	IN OUT NOCOPY  VARCHAR2) IS

  x_progress varchar2(3) := '';

begin

     x_progress := '010';


	SELECT hrl.location_code
	INTO   x_location_code
	FROM   hr_locations	hrl
	WHERE  hrl.location_id	 = x_location_id;


exception
 	when no_data_found then
-- part of hr_location changes bug# 2393886
        po_shipments_sv2.get_drop_ship_cust_locations
                        (x_location_id , x_location_code );

when others then
      po_message_s.sql_error('get_location_code', x_progress, sqlcode);
      raise;

end get_location_code;


--=============================================================================
-- FUNCTION    : get_location_code                             <2699040>
-- TYPE        : Private
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : Gets the location_code for the input location_id.
--
-- PARAMETERS  : location_id
--
-- RETURNS     : location_code for the input location_id
--               (NULL for invalid location_id's)
--
-- EXCEPTIONS  : -
--=============================================================================
FUNCTION get_location_code
(
    p_location_id        IN       HR_LOCATIONS.location_id%TYPE
)
RETURN HR_LOCATIONS.location_code%TYPE
IS
    x_location_code       HR_LOCATIONS.location_code%TYPE;
BEGIN

    get_location_code( p_location_id, x_location_code );

    return (x_location_code);

EXCEPTION

    WHEN OTHERS THEN
        return (NULL);

END get_location_code;


 /*============================================================================
 ** FUNCTION : val_ship_to_site_in_org
 **===========================================================================*/

 FUNCTION val_ship_to_site_in_org
         ( X_location_id           IN NUMBER,
           X_organization_id       IN NUMBER
         )
          RETURN BOOLEAN IS

   X_Progress  varchar2(3)  := '';
   X_valid_loc varchar2(1);

 begin

        X_Progress := '010';

        if X_location_id is not null then

         begin
           SELECT 'Y'
           INTO   X_valid_loc
           FROM   HR_LOCATIONS_ALL
           WHERE  LOCATION_ID = x_location_id
           AND    NVL(SHIP_TO_SITE_FLAG,'N') = 'Y'
           AND    NVL(INVENTORY_ORGANIZATION_ID, X_organization_id) = X_organization_id
           AND    NVL(INACTIVE_DATE, SYSDATE+1) > SYSDATE;
        exception
         when no_data_found then
          --bug 1942696 hr_location changes to reflect the new view
           SELECT 'Y'
           INTO   X_valid_loc
           FROM   HZ_LOCATIONS
           WHERE  LOCATION_ID = x_location_id
           AND    NVL(ADDRESS_EXPIRATION_DATE, SYSDATE+1) > SYSDATE;
        end;

           return(TRUE);

       else

           return(FALSE);

       end if;

 exception

       when no_data_found then
            return(FALSE);
       when others then
            po_message_s.sql_error('val_ship_to_site_in_org', X_progress, sqlcode);
            raise;


 end val_ship_to_site_in_org;


 /*============================================================================
 ** FUNCTION : val_receipt_site_in_org
 **===========================================================================*/

 FUNCTION val_receipt_site_in_org
         ( X_location_id           IN NUMBER,
           X_organization_id       IN NUMBER
         )
          RETURN BOOLEAN IS

   X_Progress  varchar2(3)  := '';
   X_valid_loc varchar2(1);

 begin

        X_Progress := '010';

        if X_location_id is not null then

         begin
           SELECT 'Y'
           INTO   X_valid_loc
           FROM   HR_LOCATIONS_ALL
           WHERE  LOCATION_ID = x_location_id
           AND    NVL(RECEIVING_SITE_FLAG,'N') = 'Y'
           AND    NVL(INVENTORY_ORGANIZATION_ID, X_organization_id) = X_organization_id
           AND    NVL(INACTIVE_DATE, SYSDATE+1) > SYSDATE;
         exception
         when no_data_found then
        --bug 1942696 hr_location changes to reflect the new view
           SELECT 'Y'
           INTO   X_valid_loc
           FROM   HZ_LOCATIONS
           WHERE  LOCATION_ID = x_location_id
           AND    NVL(ADDRESS_EXPIRATION_DATE, SYSDATE+1) > SYSDATE;
        end;

           return(TRUE);

       else

           return(FALSE);

       end if;

 exception

       when no_data_found then
            return(FALSE);
       when others then
            po_message_s.sql_error('val_receipt_site_in_org', X_progress, sqlcode);
            raise;


 end val_receipt_site_in_org;


/*===========================================================================

  PROCEDURE NAME:	derive_location_info()

===========================================================================*/

 PROCEDURE derive_location_info (
               p_loc_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Location_id_record_type) IS

 cid            INTEGER;
 rows_processed INTEGER;
 sql_str        VARCHAR2(2000);

 loc_code_null BOOLEAN := TRUE;
 loc_id_null   BOOLEAN := TRUE;

 BEGIN
    sql_str := 'SELECT location_code, location_id FROM hr_locations   WHERE ';

    IF p_loc_record.location_code IS NULL   and
       p_loc_record.location_id   IS NULL   THEN
          p_loc_record.error_record.error_status := 'W';
          RETURN;

    END IF;

    IF p_loc_record.location_code IS NOT NULL and
       p_loc_record.location_id   IS NOT NULL   THEN

          p_loc_record.error_record.error_status := 'S';
          RETURN;

    END IF;

    IF p_loc_record.location_code IS NOT NULL THEN

      sql_str := sql_str || ' location_code  = :v_loc_code and';
      loc_code_null := FALSE;

    END IF;

    IF p_loc_record.location_id IS NOT NULL THEN
      sql_str := sql_str || ' location_id = :v_loc_id and';
      loc_id_null := FALSE;

    END IF;

    sql_str := substr(sql_str,1,length(sql_str)-3);
    /* dbms_output.put_line(substr(sql_str,1,255));
    dbms_output.put_line(substr(sql_str,256,255));
    dbms_output.put_line(substr(sql_str,513,255)); */

    cid := dbms_sql.open_cursor;

    dbms_sql.parse(cid, sql_str , dbms_sql.native);

    dbms_sql.define_column(cid,1,p_loc_record.location_code,25);
    dbms_sql.define_column(cid,2,p_loc_record.location_id);

    IF not loc_code_null THEN

      dbms_sql.bind_variable(cid,'v_loc_code',p_loc_record.location_code);

    END IF;

    IF NOT loc_id_null THEN

      dbms_sql.bind_variable(cid,'v_loc_id',p_loc_record.location_id);

    END IF;

    rows_processed := dbms_sql.execute_and_fetch(cid);

    IF rows_processed = 1 THEN
       IF loc_code_null THEN
          dbms_sql.column_value(cid,1,p_loc_record.location_code);
       END IF;

       IF loc_id_null THEN
          dbms_sql.column_value(cid,2,p_loc_record.location_id);
       END IF;

       p_loc_record.error_record.error_status := 'S';

    ELSIF rows_processed = 0 and p_loc_record.location_id IS NOT NULL THEN
-- part of hr_location changes new bug 2393886

    sql_str := 'SELECT (substrb(rtrim(address1)||' || '''-'''||
                '||rtrim(city),1,20)) location_code, location_id '||
                'FROM hz_locations WHERE ';

   --     IF p_loc_record.location_id IS NOT NULL THEN
          sql_str := sql_str ||  'location_id = :v_loc_id ';
          loc_id_null := FALSE;
  --      END IF;
          sql_str := substr(sql_str,1,length(sql_str));


         cid := dbms_sql.open_cursor;

         dbms_sql.parse(cid, sql_str , dbms_sql.native);
         dbms_sql.define_column(cid,1,p_loc_record.location_code,25);
         dbms_sql.define_column(cid,2,p_loc_record.location_id);
  /*
        IF not loc_code_null THEN
         dbms_sql.bind_variable(cid,'v_loc_code',p_loc_record.location_code);
        END IF;
   */
        IF NOT loc_id_null THEN
         dbms_sql.bind_variable(cid,'v_loc_id',p_loc_record.location_id);
        END IF;

        rows_processed := dbms_sql.execute_and_fetch(cid);

                        IF rows_processed = 1 THEN

                             IF loc_code_null THEN
                                dbms_sql.column_value(cid,1,p_loc_record.location_code);
                             END IF;

                         /*  IF loc_id_null THEN
                                dbms_sql.column_value(cid,2,p_loc_record.location_id);
                             END IF;
                         */
                            p_loc_record.error_record.error_status := 'S';


                       ELSIF rows_processed = 0 THEN
                       p_loc_record.error_record.error_status := 'W';

                      ELSE
                      p_loc_record.error_record.error_status := 'W';
                    END IF;
-- part of new bug 2393886
    ELSE
       p_loc_record.error_record.error_status := 'W';

    END IF;

    IF dbms_sql.is_open(cid) THEN
       dbms_sql.close_cursor(cid);
    END IF;

 EXCEPTION
    WHEN others THEN

       IF dbms_sql.is_open(cid) THEN
           dbms_sql.close_cursor(cid);
       END IF;

       p_loc_record.error_record.error_status := 'U';
       p_loc_record.error_record.error_message := sqlerrm;

 END derive_location_info;

/*===========================================================================

  PROCEDURE NAME:	validate_location_info()

===========================================================================*/

 PROCEDURE validate_location_info (
               p_loc_record IN OUT NOCOPY rcv_shipment_object_sv.Location_id_record_type) IS

 X_cid            INTEGER;
 X_rows_processed INTEGER;
 X_sql_str        VARCHAR2(2000);

 X_loc_code_null  BOOLEAN := TRUE;
 X_loc_id_null    BOOLEAN := TRUE;

 X_inactive_date  DATE;
 X_receiving_site_flag VARCHAR2(1);
 X_inventory_organization_id NUMBER;

 X_sysdate  DATE := sysdate;

 BEGIN

   X_sql_str := 'select inactive_date,receiving_site_flag,inventory_organization_id from hr_locations where ';

    IF p_loc_record.location_code IS NULL   and
       p_loc_record.location_id   IS NULL   THEN

          p_loc_record.error_record.error_status := 'E';
          p_loc_record.error_record.error_message := 'All Blanks';
          RETURN;

    END IF;

    IF p_loc_record.location_code IS NOT NULL THEN

      X_sql_str := X_sql_str || ' location_code  = :v_loc_code and';
      X_loc_code_null := FALSE;

    END IF;

    IF p_loc_record.location_id IS NOT NULL THEN
      X_sql_str := X_sql_str || ' location_id = :v_loc_id and';
      X_loc_id_null := FALSE;

    END IF;

    X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    /* dbms_output.put_line(substr(X_sql_str,1,255));
    dbms_output.put_line(substr(X_sql_str,256,255));
    dbms_output.put_line(substr(X_sql_str,513,255)); */

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,X_inactive_date);
    dbms_sql.define_column(X_cid,2,X_receiving_site_flag,1);
    dbms_sql.define_column(X_cid,3,X_inventory_organization_id);

    IF NOT X_loc_code_null THEN

      dbms_sql.bind_variable(X_cid,'v_loc_code',p_loc_record.location_code);

    END IF;

    IF NOT X_loc_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_loc_id',p_loc_record.location_id);

    END IF;

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);

    IF X_rows_processed = 1 THEN

       dbms_sql.column_value(X_cid,1,X_inactive_date);
       dbms_sql.column_value(X_cid,2,X_receiving_site_flag);
       dbms_sql.column_value(X_cid,3,X_inventory_organization_id);

     /* Check whether specified location is active */

       IF nvl(X_inactive_date,X_sysdate + 1) < X_sysdate THEN

          p_loc_record.error_record.error_status := 'E';
          p_loc_record.error_record.error_message := 'LOC_DISABLED';

          IF dbms_sql.is_open(X_cid) THEN
            dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;


     /* Check whether location is receiving location */

       IF nvl(X_receiving_site_flag,'Y') = 'N' THEN

          p_loc_record.error_record.error_status := 'E';
          p_loc_record.error_record.error_message := 'LOC_NOT_RCV_SITE';

          IF dbms_sql.is_open(X_cid) THEN
            dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

     /* Check whether the location is within the ship_to_organization */
     /* Bug 989583 :
            the location may not be connected to any inventory org in some cases
            Therefore changing the nvl to equate it to p_loc_record.organization_id in such cases
     */

       IF nvl(X_inventory_organization_id,p_loc_record.organization_id) <> p_loc_record.organization_id THEN

          p_loc_record.error_record.error_status := 'E';
          p_loc_record.error_record.error_message := 'LOC_NOT_IN_ORG';

          IF dbms_sql.is_open(X_cid) THEN
            dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

       p_loc_record.error_record.error_status := 'S';
       p_loc_record.error_record.error_message := NULL;

    ELSIF X_rows_processed = 0 THEN

-- fix as part of 2393886
--    p_loc_record.error_record.error_status := 'E';
       p_loc_record.error_record.error_message := 'LOC_ID';

       IF dbms_sql.is_open(X_cid) THEN
         dbms_sql.close_cursor(X_cid);
       END IF;
       /* validate from hz_locations */
      IF p_loc_record.location_code IS NULL   and
         p_loc_record.location_id   IS NOT NULL   THEN
       validate_hz_loc_info(p_loc_record);
      ELSE
       RETURN;
      END IF;

    ELSE

       p_loc_record.error_record.error_status := 'E';
       p_loc_record.error_record.error_message := 'TOOMANYROWS';
       IF dbms_sql.is_open(X_cid) THEN
         dbms_sql.close_cursor(X_cid);
       END IF;

       RETURN;

    END IF;

    IF dbms_sql.is_open(X_cid) THEN
      dbms_sql.close_cursor(X_cid);
    END IF;

 EXCEPTION

    WHEN others THEN
       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;

       p_loc_record.error_record.error_status := 'U';
       p_loc_record.error_record.error_message := sqlerrm;

 END validate_location_info;

/*===========================================================================

  PROCEDURE NAME:	validate_hz_loc_info()

===========================================================================*/

 PROCEDURE validate_hz_loc_info (
               p_loc_record IN OUT NOCOPY rcv_shipment_object_sv.Location_id_record_type) IS

 X_cid            INTEGER;
 X_rows_processed INTEGER;
 X_sql_str        VARCHAR2(2000);

 X_loc_code_null  BOOLEAN := TRUE;
 X_loc_id_null    BOOLEAN := TRUE;

 X_add_exp_date  DATE;

 X_sysdate  DATE := sysdate;

 BEGIN

   X_sql_str := 'select address_expiration_date from hz_locations where ';


    IF p_loc_record.location_id IS NOT NULL THEN

      X_sql_str := X_sql_str || ' location_id = :v_loc_id and';
      X_loc_id_null := FALSE;

    END IF;

    X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,X_add_exp_date);


    IF NOT X_loc_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_loc_id',p_loc_record.location_id);

    END IF;

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);


    IF X_rows_processed = 1 THEN

       dbms_sql.column_value(X_cid,1,X_add_exp_date);

     /* Check whether specified location is active */

       IF nvl(X_add_exp_date,X_sysdate + 1) < X_sysdate THEN

          p_loc_record.error_record.error_status := 'E';
          p_loc_record.error_record.error_message := 'LOC_DISABLED';

          IF dbms_sql.is_open(X_cid) THEN
            dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

       p_loc_record.error_record.error_status := 'S';
       p_loc_record.error_record.error_message := NULL;

    ELSIF X_rows_processed = 0 THEN

       p_loc_record.error_record.error_status := 'E';
       p_loc_record.error_record.error_message := 'LOC_ID';

       IF dbms_sql.is_open(X_cid) THEN
         dbms_sql.close_cursor(X_cid);
       END IF;

       RETURN;

    ELSE

       p_loc_record.error_record.error_status := 'E';
       p_loc_record.error_record.error_message := 'TOOMANYROWS';

       IF dbms_sql.is_open(X_cid) THEN
         dbms_sql.close_cursor(X_cid);
       END IF;

       RETURN;

    END IF;

    IF dbms_sql.is_open(X_cid) THEN
      dbms_sql.close_cursor(X_cid);
    END IF;

 EXCEPTION

    WHEN others THEN

       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;

       p_loc_record.error_record.error_status := 'U';
       p_loc_record.error_record.error_message := sqlerrm;

 END validate_hz_loc_info;

/*===========================================================================

  PROCEDURE NAME:	validate_tax_info(...)

===========================================================================*/

 PROCEDURE validate_tax_info(
         p_tax_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.TaxRecType) IS

 X_Progress varchar2(3);
 BEGIN

  X_Progress := '010';
  --
  -- <R12 eTax Integration>
  -- This procedure is no longer used
  --

 EXCEPTION
 WHEN others THEN
     po_message_s.sql_error('validate_tax_info',X_progress,sqlcode);
     raise;

 END validate_tax_info;



  /*===========================================================================

    PROCEDURE NAME:	po_predel_validation(...)
    DESCRIPTION:    This procedure is used primarily by the HR Location form
                    (PERWSLOC) to validate any locations that can be deleted
                    from the database.  It checks for any location that is
                    currently in use in the PO, RCV, CHV base tables

   ==========================================================================*/
  PROCEDURE PO_PREDEL_VALIDATION (p_location_id IN NUMBER) IS

     v_delete_allowed VARCHAR2(1);
     l_msg            VARCHAR2(30);

  BEGIN

     hr_utility.set_location('PO_LOCATIONS_S.PO_PREDEL_VALIDATION', 1);

     BEGIN

        -- we will do an exhaustive search in all the base tables with some
        -- sort of location column.  if the tables have a location_id =
        -- p_location_id, then the outer select will raise a NO_DATA_FOUND
        -- exception.  otherwise, the select clause finishes with no error,
        -- the validation will pass, and the procedure will exit normally.
        -- we do NOT return anything from this procedure.

        l_msg := 'PO_LOC_AGENTS';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_AGENTS
                             WHERE location_id 			= p_location_id
        );

        l_msg := 'PO_LOC_CONTROL_RULES';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_CONTROL_RULES
                             WHERE location_id 			= p_location_id
        );

        l_msg := 'PO_LOC_DISTRIBUTIONS_ALL';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_DISTRIBUTIONS_ALL
                             WHERE deliver_to_location_id	= p_location_id
        );

        l_msg := 'PO_LOC_DISTRIBUTIONS_ARCHIVE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_DISTRIBUTIONS_ARCHIVE_ALL
                             WHERE deliver_to_location_id	= p_location_id
        );

        l_msg := 'PO_LOC_DISTRIBUTIONS_INTERFACE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_DISTRIBUTIONS_INTERFACE
                             WHERE deliver_to_location_id	= p_location_id
        );

        l_msg := 'PO_LOC_HEADERS_ALL';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_HEADERS_ALL
                             WHERE ship_to_location_id		= p_location_id
                                OR bill_to_location_id          = p_location_id
        );

        l_msg := 'PO_LOC_HEADERS_ARCHIVE_ALL';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_HEADERS_ARCHIVE_ALL
                             WHERE ship_to_location_id		= p_location_id
                                OR bill_to_location_id          = p_location_id
        );

        l_msg := 'PO_LOC_HEADERS_INTERFACE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_HEADERS_INTERFACE
                             WHERE ship_to_location_id 		= p_location_id
                                OR bill_to_location_id		= p_location_id
        );

        l_msg := 'PO_LOC_LINES_INTERFACE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_LINES_INTERFACE
                             WHERE ship_to_location_id 		= p_location_id
        );

        l_msg := 'PO_LOC_LINE_LOCATIONS_ALL';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_LINE_LOCATIONS_ALL
                             WHERE ship_to_location_id 		= p_location_id
        );

        l_msg := 'PO_LOC_LINE_LOCATIONS_ARCHIVE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_LINE_LOCATIONS_ARCHIVE_ALL
                             WHERE ship_to_location_id 		= p_location_id
        );

        l_msg := 'PO_LOC_LOCATION_ASSOCIATIONS';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_LOCATION_ASSOCIATIONS
                             WHERE location_id 			= p_location_id
        );

        l_msg := 'PO_LOC_REQUISITIONS_INTERFACE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_REQUISITIONS_INTERFACE_ALL
                             WHERE deliver_to_location_id 	= p_location_id
        );

        l_msg := 'PO_LOC_REQUISITION_LINES_ALL';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_REQUISITION_LINES_ALL
                             WHERE deliver_to_location_id 	= p_location_id
        );
-- Bug# 4546121:ship_to_location_id and bill_to_location_id have been nulled out
--              on po_vendors. This validation is not viable any longer.
/*
        l_msg := 'PO_LOC_VENDORS';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_VENDORS
                             WHERE ship_to_location_id 		= p_location_id
                                OR bill_to_location_id    	= p_location_id
        );
*/

        l_msg := 'PO_LOC_VENDOR_SITES_ALL';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM PO_VENDOR_SITES_ALL
                             WHERE ship_to_location_id 		= p_location_id
                                OR bill_to_location_id    	= p_location_id
        );

        l_msg := 'RCV_LOC_HEADERS_INTERFACE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM RCV_HEADERS_INTERFACE
                             WHERE location_id 			= p_location_id
        );

        l_msg := 'RCV_LOC_SHIPMENT_HEADERS';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM RCV_SHIPMENT_HEADERS
                             WHERE ship_to_location_id 		= p_location_id
        );

        l_msg := 'RCV_LOC_SHIPMENT_LINES';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM RCV_SHIPMENT_LINES
                             WHERE ship_to_location_id 		= p_location_id
                                OR deliver_to_location_id  	= p_location_id
        );

        l_msg := 'RCV_LOC_SUPPLY';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM RCV_SUPPLY
                             WHERE location_id	 		= p_location_id
        );

        l_msg := 'RCV_LOC_TRANSACTIONS';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM RCV_TRANSACTIONS
                             WHERE deliver_to_location_id 	= p_location_id
	                        OR location_id			= p_location_id
        );

        l_msg := 'RCV_LOC_TRANSACTIONS_INTERFACE';
        SELECT 'Y'
          INTO v_delete_allowed
          FROM sys.dual
         WHERE NOT EXISTS (
                            SELECT null
                              FROM RCV_TRANSACTIONS_INTERFACE
                             WHERE ship_to_location_id 		= p_location_id
                                OR deliver_to_location_id 	= p_location_id
                                OR location_id 			= p_location_id
        );


     EXCEPTION

        WHEN NO_DATA_FOUND THEN
             -- this means that the location already exists in our base tables.
             -- set an error message and raise an error to disallow the
             -- deletion of the location.
             hr_utility.set_message(201, l_msg);
             hr_utility.raise_error;

     END;

  END PO_PREDEL_VALIDATION;


END PO_LOCATIONS_S;

/
