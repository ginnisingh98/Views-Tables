--------------------------------------------------------
--  DDL for Package Body PO_ORGS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ORGS_SV" as
/* $Header: POXCOO2B.pls 120.1.12010000.3 2008/09/24 07:12:02 cvardia ship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');
/*===========================================================================

 PROCEDURE NAME :  get_org_info()

===========================================================================*/

 PROCEDURE get_org_info(X_org_id IN NUMBER, X_set_of_books_id IN NUMBER,
                        X_org_code IN OUT NOCOPY varchar2,
                        X_org_name IN OUT NOCOPY varchar2 ) IS


     X_progress varchar2(3) := '';



 begin

           X_progress := '010';

          /* Get the Org Code and name for a specific Org ID and Set Of Books
          ** Please Note that this select DOES NOT fetch the ORG_ID back
          ** as it is already a part of the where clause. R10 code always
          ** selects it into a bind variable. This means that the procedure
          ** that calls this api should take care of that logic if necessary */

          select  ood.organization_code,
                  ood.organization_name
          into    X_org_code,
                  X_org_name
          from org_organization_definitions ood
          where ood.organization_id(+) = X_org_id;

exception

             when no_data_found then
                  X_org_code := '';
                  X_org_name := '';
             when others then
                   po_message_s.sql_error('get_org_info',X_progress,sqlcode);
                   raise;


end get_org_info;



/*===========================================================================

 PROCEDURE NAME :  val_dest_org()

===========================================================================*/

FUNCTION val_dest_org(  X_org_id 	IN    NUMBER,
                        X_item_id	IN    NUMBER,
                        X_item_rev	IN    VARCHAR2,
			X_dest_type	IN    VARCHAR2,
			X_sob_id	IN    NUMBER)
RETURN BOOLEAN IS

X_progress 	varchar2(3) := '';
x_org_count	NUMBER	    := 0;

BEGIN

 /*
 ** Stop processing if org is null.
 */

  IF (x_org_id is null) THEN
    return (FALSE);

  END IF;


 /*
 ** Validate that the org is currently
 ** active in the current set of books.
 */

     x_progress := '010';

     SELECT count(1)
     INTO   x_org_count
     FROM   org_organization_definitions ood
     WHERE  ood.set_of_books_id = x_sob_id
     AND    ood.organization_id = x_org_id
     AND    nvl(ood.disable_date, trunc(sysdate + 1)) > trunc(sysdate);


     IF (x_org_count = 0) THEN
      return (FALSE);

     END IF;

     x_org_count := 0;

  /* Validation for destination type 'INVENTORY */

  -- BUG#7395502
  -- Modified the SQL's for Better Performance
  -- SQL ID : 28306002 , 28305956 ,28305980

  IF (x_dest_type = 'INVENTORY') THEN

      x_progress := '020';

      IF ( x_item_id is not null ) THEN
	      SELECT count(1)
	      INTO   x_org_count
	      FROM   mtl_system_items  msi
	      WHERE  msi.inventory_item_id = x_item_id
	      AND    msi.stock_enabled_flag = 'Y'
	      AND    msi.purchasing_enabled_flag = 'Y'
	      AND    msi.organization_id = x_org_id;

      ELSE
	      SELECT count(1)
	      INTO   x_org_count
	      FROM   mtl_system_items  msi
	      WHERE  msi.stock_enabled_flag = 'Y'
	      AND    msi.purchasing_enabled_flag = 'Y'
	      AND    msi.organization_id = x_org_id
              AND    ROWNUM <   2;
      END IF;

      IF (x_org_count = 0) THEN
       return (FALSE);

      END IF;

  /* Validation for destination type 'EXPENSE' */

  ELSIF (x_dest_type = 'EXPENSE') THEN

     x_progress := '030';

      IF ( x_item_id is not null ) THEN
	     SELECT count(1)
	     INTO   x_org_count
	     FROM   mtl_system_items msi
	     WHERE  msi.inventory_item_id = x_item_id
	     AND    msi.organization_id = x_org_id;
      ELSE
	     SELECT count(1)
	     INTO   x_org_count
	     FROM   mtl_system_items msi
	     WHERE  msi.organization_id = x_org_id
             AND    ROWNUM <   2;
      END IF;

     IF (x_org_count = 0) THEN
       return (FALSE);

     END IF;

  /* Validation for destination type 'SHOP FLOOR' */

  ELSIF (x_dest_type = 'SHOP FLOOR') THEN

     x_progress := '040';

     IF ( x_item_id is not null ) THEN
	     SELECT count(1)
	     INTO   x_org_count
	     FROM   mtl_system_items msi
	     WHERE  msi.inventory_item_id = x_item_id
	     AND    msi.organization_id = x_org_id
	     AND    msi.outside_operation_flag = 'Y';
      ELSE
	     SELECT count(1)
	     INTO   x_org_count
	     FROM   mtl_system_items msi
	     WHERE  msi.organization_id = x_org_id
	     AND    msi.outside_operation_flag = 'Y'
             AND    ROWNUM <   2;

      END IF;
     IF (x_org_count = 0) THEN
       return (FALSE);

     END IF;

  END IF;

     /*
     ** Validate that the item revision
     ** is valid for the org.
     */

     x_org_count := 0;
     x_progress := '050';

     SELECT count(1)
     INTO   x_org_count
     FROM   mtl_item_revisions mir
     WHERE  mir.revision = nvl(x_item_rev, mir.revision)
     AND    mir.inventory_item_id = x_item_id
     AND    mir.organization_id = x_org_id;

  IF (x_org_count = 0) THEN
     return (FALSE);

  END IF;

  return (TRUE);

exception
   when others then
      po_message_s.sql_error('val_dest_org',X_progress,sqlcode);
      raise;

end val_dest_org;



/*===========================================================================

 PROCEDURE NAME :  val_source_org()

===========================================================================*/

FUNCTION val_source_org(X_src_org_id		IN    NUMBER,
                        X_dest_org_id		IN    NUMBER,
			X_dest_type		IN    VARCHAR2,
                        X_item_id		IN    VARCHAR2,
			X_mrp_planned_item	IN    VARCHAR2,
			X_sob_id		IN    NUMBER)
RETURN BOOLEAN IS

X_progress		varchar2(3) := '';
x_org_count		NUMBER	    := 0;
x_intransit_type	mtl_interorg_parameters.intransit_type%type;

BEGIN

 /*
 ** Stop processing if src org is null.
 */

  IF (x_src_org_id is null) THEN
    return (FALSE);

  END IF;

 /*
 ** Stop processing if destination org
 ** is null.
 */

  IF (x_dest_org_id is null) THEN
    return (FALSE);

  END IF;

 /*
 ** Validate that the org is currently
 ** active in the current set of books.
 */

     x_progress := '010';

     SELECT count(1)
     INTO   x_org_count
     FROM   org_organization_definitions ood
     WHERE  ood.set_of_books_id = x_sob_id
     AND    ood.organization_id = x_src_org_id
     AND    nvl(ood.disable_date, trunc(sysdate + 1)) > trunc(sysdate);


     IF (x_org_count = 0) THEN
      return (FALSE);

     END IF;


  /*
  ** Validate that if the item is a planned
  ** item then the source and destination orgs
  ** cannot be the same. Display the message
  ** PO_RQ_INV_SOURCE_SAME_AS_DEST when this is
  ** is the case.
  */

   IF (x_mrp_planned_item = 'Y') THEN
     IF (x_src_org_id = x_dest_org_id) THEN
     po_message_s.app_error('PO_RQ_INV_SOURCE_SAME_AS_DEST');

     return (FALSE);

     END IF;
   END IF;


  /* Validate that the item is stock enabled
  ** and internal order enabled in the source
  ** organization.
  */

      x_progress := '020';

      SELECT count(1)
      INTO   x_org_count
      FROM   mtl_system_items msi
      WHERE  msi.organization_id = x_src_org_id
      AND    msi.inventory_item_id = x_item_id
      AND    msi.stock_enabled_flag = 'Y'
      AND    msi.internal_order_enabled_flag = 'Y';

      IF (x_org_count = 0) THEN
       return (FALSE);

      END IF;


  /*
  ** Validate that there is a row in
  ** mtl_interorg_parameters for the source
  ** and destination organization combination.
  */

     x_org_count := 0;
     x_progress := '030';

     SELECT mip.intransit_type
     INTO   x_intransit_type
     FROM   mtl_interorg_parameters mip
     WHERE  mip.from_organization_id  = x_src_org_id
     AND    mip.to_organization_id = x_dest_org_id;



  IF ((x_intransit_type = 1) AND

      (x_dest_type <> 'EXPENSE'))  THEN

  /* Bug# 4446916, We need to allow for Source having serial control as
  * 'At Sales Order Issue' to destination having serial control as
  * 'At Receipt or Predefine'. Removed the 6( 'At Sales Order Issue') in code
  *       OR (ms1.serial_number_control_code IN (1,6)
  */

    SELECT count(1)
    INTO   x_org_count
    FROM   mtl_system_items ms1,
           mtl_system_items ms2
    WHERE  ms1.inventory_item_id = x_item_id
    AND    ms1.organization_id   = x_src_org_id
    AND    ms2.inventory_item_id = x_item_id
    AND    ms2.organization_id   = x_dest_org_id
    AND    ((ms1.lot_control_code = 1 AND
	     ms2.lot_control_code = 2)
	   OR (ms1.serial_number_control_code IN (1)
	   AND ms2.serial_number_control_code IN (2,3,5))
	   OR (ms1.revision_qty_control_code = 1
	   AND ms2.revision_qty_control_code = 2));

    IF (x_org_count = 1) THEN
      po_message_s.app_error('PO_RQ_INV_LOOSER_TIGHTER');

      return (FALSE);

    END IF;
  END IF;

  return (TRUE);

exception
   when no_data_found then
    return (FALSE);
   when others then
      po_message_s.sql_error('val_source_org',X_progress,sqlcode);
      raise;

end val_source_org;


-- ksareddy - performance fix 2506961 - rewrote derive_org_info to not use dynamic sql
/*===========================================================================

 PROCEDURE NAME :  derive_org_info()

===========================================================================*/
 PROCEDURE derive_org_info (
               p_org_record IN OUT NOCOPY rcv_shipment_object_sv.Organization_id_record_type) IS

 cid            INTEGER;
 x_org_code p_org_record.organization_code%TYPE;

 /* Fix for Bug 2813343.
    Replaced p_org_record.organization_code%TYPE
    with p_org_record.organization_id%TYPE  for
    the variable x_org_id.
 */
 x_org_id p_org_record.organization_id%TYPE;

 BEGIN

    IF p_org_record.organization_code IS NULL   and
       p_org_record.organization_id   IS NULL   THEN

          p_org_record.error_record.error_status := 'W';
          RETURN;

    END IF;

    IF p_org_record.organization_code IS NOT NULL and
       p_org_record.organization_id IS NOT NULL   THEN

          p_org_record.error_record.error_status := 'S';
          RETURN;
    END IF;
   IF p_org_record.organization_id IS NOT NULL and
	p_org_record.organization_code IS NOT NULL THEN
    	 SELECT organization_code, organization_id INTO   x_org_code, x_org_id
     	 FROM   mtl_parameters
    	 WHERE  organization_code = p_org_record.organization_code
      	 AND organization_id = p_org_record.organization_id;
       	 p_org_record.error_record.error_status := 'S';
	 p_org_record.organization_id := x_org_id;
	 p_org_record.organization_code := x_org_code;
	 RETURN;
   END IF;

   IF p_org_record.organization_code IS NOT NULL THEN
     	 SELECT organization_code, organization_id INTO   x_org_code, x_org_id
     	 FROM   mtl_parameters
	 WHERE organization_code = p_org_record.organization_code;
       	 p_org_record.error_record.error_status := 'S';
	 p_org_record.organization_id := x_org_id;
	 p_org_record.organization_code := x_org_code;
	 RETURN;
   END IF;

   IF p_org_record.organization_id IS NOT NULL THEN
     	 SELECT organization_code, organization_id INTO   x_org_code, x_org_id
     	 FROM   mtl_parameters
     	 WHERE  organization_id = p_org_record.organization_id;
       	 p_org_record.error_record.error_status := 'S';
	 p_org_record.organization_id := x_org_id;
	 p_org_record.organization_code := x_org_code;
	 RETURN;
   END IF;

 EXCEPTION
    WHEN no_data_found THEN
	p_org_record.error_record.error_status := 'W';
    WHEN others THEN
       p_org_record.error_record.error_status := 'U';
       p_org_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_org_record.error_record.error_message);
       END IF;

 END derive_org_info;

/*===========================================================================

 PROCEDURE NAME :  validate_org_info()

===========================================================================*/

 PROCEDURE validate_org_info (
               p_org_record IN OUT NOCOPY rcv_shipment_object_sv.Organization_id_record_type) IS

/* bao */
 x_organization_id   NUMBER;
 x_organization_code VARCHAR2(3);
 x_sysdate           DATE := sysdate;
 x_is_cached         BOOLEAN := FALSE;

/*
 X_cid            INTEGER;
 X_rows_processed INTEGER;
 X_sql_str        VARCHAR2(2000);

 X_org_code_null  BOOLEAN := TRUE;
 X_org_id_null    BOOLEAN := TRUE;

 X_user_definition_enable_date DATE;
 X_disable_date                DATE;
 X_sysdate                     DATE := sysdate;
*/
 BEGIN

/* bao */
   IF (p_org_record.organization_code IS NULL AND
       p_org_record.organization_id IS NULL) THEN
          dbms_output.put_line('All Blanks');
          p_org_record.error_record.error_message := 'All blanks';
          p_org_record.error_record.error_status := 'E';
          RETURN;
   END IF;

   x_organization_code := p_org_record.organization_code;

   IF (p_org_record.organization_id IS NULL) THEN
     SELECT organization_id
     INTO   x_organization_id
     FROM   mtl_parameters
     WHERE  organization_code = p_org_record.organization_code;
   ELSE
     x_organization_id := p_org_record.organization_id;
   END IF;

   IF (x_date_table.EXISTS(x_organization_id) AND
       x_date_table(x_organization_id).v_organization_code =
         NVL(x_organization_code, x_date_table(x_organization_id).v_organization_code)) THEN
     x_is_cached := TRUE;
   END IF;

   IF (NOT x_is_cached) THEN
     IF (x_organization_code IS NULL) THEN
       SELECT user_definition_enable_date,
              disable_date,
              organization_code
       INTO   x_date_table(x_organization_id).v_enable_date,
              x_date_table(x_organization_id).v_disable_date,
              x_date_table(x_organization_id).v_organization_code
       FROM   org_organization_definitions
       WHERE  organization_id = x_organization_id;
     ELSE
       SELECT user_definition_enable_date,
              disable_date,
              organization_code
       INTO   x_date_table(x_organization_id).v_enable_date,
              x_date_table(x_organization_id).v_disable_date,
              x_date_table(x_organization_id).v_organization_code
       FROM   org_organization_definitions
       WHERE  organization_id = x_organization_id AND
              organization_code = x_organization_code;
     END IF;
   END IF;

   IF NOT x_sysdate BETWEEN
         NVL(x_date_table(x_organization_id).v_enable_date, X_sysdate-1) AND
         NVL(x_date_table(x_organization_id).v_disable_date, X_sysdate+1) THEN

     dbms_output.put_line('Not Active');
     p_org_record.error_record.error_status := 'E';
     p_org_record.error_record.error_message := 'ORG_DISABLED';
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       dbms_output.put_line('Invalid Organization Code');
       p_org_record.error_record.error_status := 'E';
       p_org_record.error_record.error_message := 'ORG_ID';
  WHEN TOO_MANY_ROWS THEN
       dbms_output.put_line('Too many rows');
       p_org_record.error_record.error_status := 'E';
       p_org_record.error_record.error_message := 'TOOMANYROWS';
  WHEN OTHERS THEN
       p_org_record.error_record.error_status := 'U';
       p_org_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_org_record.error_record.error_message);
       END IF;





/*
    X_sql_str := 'SELECT user_definition_enable_date, disable_date FROM org_organization_definitions WHERE ';

    IF p_org_record.organization_code IS NULL   and
       p_org_record.organization_id   IS NULL   THEN

          dbms_output.put_line('All Blanks');
          p_org_record.error_record.error_message := 'All blanks';
          p_org_record.error_record.error_status := 'E';
          RETURN;

    END IF;

    IF p_org_record.organization_code IS NOT NULL THEN

      X_sql_str := X_sql_str || ' organization_code  = :v_org_code and';
      X_org_code_null := FALSE;

    END IF;

    IF p_org_record.organization_id IS NOT NULL THEN

      X_sql_str := X_sql_str || ' organization_id = :v_org_id and';
      X_org_id_null := FALSE;

    END IF;

    X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    dbms_output.put_line(substr(X_sql_str,1,255));
    dbms_output.put_line(substr(X_sql_str,256,255));
    dbms_output.put_line(substr(X_sql_str,513,255));

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,X_user_definition_enable_date);
    dbms_sql.define_column(X_cid,2,X_disable_date);

    IF NOT X_org_code_null THEN

      dbms_sql.bind_variable(X_cid,'v_org_code',p_org_record.organization_code);

    END IF;

    IF NOT X_org_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_org_id',p_org_record.organization_id);

    END IF;

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);

    IF X_rows_processed = 1 THEN

       dbms_sql.column_value(X_cid,1,X_user_definition_enable_date);
       dbms_sql.column_value(X_cid,2,X_disable_date);
*/
       /* Check whether organization is Active */
/*
       IF NOT X_sysdate BETWEEN
               nvl(X_user_definition_enable_date,X_sysdate - 1) and
               nvl(X_disable_date,X_sysdate + 1) THEN

          dbms_output.put_line('Not Active');
          p_org_record.error_record.error_status := 'E';
          p_org_record.error_record.error_message := 'ORG_DISABLED';

          IF dbms_sql.is_open(X_cid) THEN
             dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

       p_org_record.error_record.error_status := 'S';
       p_org_record.error_record.error_message := NULL;


    ELSIF X_rows_processed = 0 THEN

       dbms_output.put_line('Invalid Organization Code');
       p_org_record.error_record.error_status := 'E';
       p_org_record.error_record.error_message := 'ORG_ID';

       IF dbms_sql.is_open(X_cid) THEN
          dbms_sql.close_cursor(X_cid);
       END IF;

       RETURN;

    ELSE

       dbms_output.put_line('Too many rows');
       p_org_record.error_record.error_status := 'E';
       p_org_record.error_record.error_message := 'TOOMANYROWS';

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
       p_org_record.error_record.error_status  := 'U';
       p_org_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_org_record.error_record.error_message);
       END IF;
*/
 END validate_org_info;

END PO_ORGS_SV;

/
