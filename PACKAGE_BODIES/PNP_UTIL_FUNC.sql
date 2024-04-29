--------------------------------------------------------
--  DDL for Package Body PNP_UTIL_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNP_UTIL_FUNC" AS
  -- $Header: PNPFUNCB.pls 120.19.12010000.12 2010/03/26 10:43:10 rthumma ship $

/*===========================================================================+
--  NAME         : get_total_payment_item_amt
--  DESCRIPTION  : Sum up and return the 'CASH' type payment items amount for a given
--                 payment schedule record
--  NOTES        : Currently being used in view "PN_PAYMENT_SCHEDULES_V"
--                 Requires the global table: currencies_table is populated
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN:
--                       p_status
--                       p_curr_code
--                       p_date
--                       p_payment_schedule_id
--
--                 OUT:
--                       none
--  RETURNS      : The sum of 'CASH' payment item amounts
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  14-MAY-98  Neeraj Tandon o Created
--  28-FEB-02  ftanudja      o Modified to read FROM accounted amount column
--                             Added parameters: status, curr_code, date
--  02-APR-02  ftanudja      o Modified to default to p_def_conv_type
--  02-MAY-02  achauhan      o Used the lesser of due_date, SYSDATE to perform
--                             conversion
--  03-MAY-02  ftanudja      o For conversion of type 'User', use 'rate'.
--  06-MAY-02  ftanudja      o Removed parameter 'p_def_conv_type'
--  24-JUL-02  ftanudja      o Added check for NULL conversion type
--  30-OCT-02  Satish        o Access _all table for performance issues.
--  28-NOV-05  sdmahesh      o Added org_id parameter
--                             Passed org_id to check_conversion_type
 +===========================================================================*/

  FUNCTION get_total_payment_item_amt (
                                        p_status IN VARCHAR2,
                                        p_curr_code IN VARCHAR2,
                                        p_payment_schedule_id IN NUMBER,
                                        p_called_FROM         IN VARCHAR2

                                      ) RETURN NUMBER
  IS

    total_item_amount NUMBER := 0;
    l_conv_date       DATE;
    l_conv_type       PN_CURRENCIES.CONVERSION_TYPE%TYPE;
    l_org_id          NUMBER(15);

    CURSOR amounts_cursor IS
      SELECT actual_amount, accounted_amount, currency_code, due_date, rate, org_id
      FROM   pn_payment_items_all
      WHERE  payment_schedule_id           = p_payment_schedule_id
      AND    payment_item_type_lookup_code = 'CASH';

  BEGIN

   FOR amounts_record IN amounts_cursor LOOP
      l_org_id := amounts_record.org_id;
      IF p_status = 'APPROVED' THEN
         total_item_amount := total_item_amount + NVL(amounts_record.accounted_amount,0);
      ELSE
         IF (amounts_record.currency_code = p_curr_code) THEN
            total_item_amount := total_item_amount + NVL(amounts_record.actual_amount,0);
         ELSE
            l_conv_type := pnp_util_func.check_conversion_type(p_curr_code,l_org_id);

            IF upper(l_conv_type) <> 'USER' THEN

               IF amounts_record.due_date >= SYSDATE THEN
                  l_conv_date := SYSDATE;
               ELSE
                  l_conv_date := amounts_record.due_date;
               END IF;

               total_item_amount := total_item_amount +
                                    NVL(pnp_util_func.export_curr_amount(
                                         currency_code        => amounts_record.currency_code,
                                         export_currency_code => p_curr_code,
                                         export_date          => l_conv_date,
                                         conversion_type      => l_conv_type,
                                         actual_amount        => NVL(amounts_record.actual_amount,0),
                                         p_called_FROM        => p_called_FROM)
                                       ,0);
            ElSIF upper(l_conv_type) = 'USER' THEN
              total_item_amount := total_item_amount + NVL(amounts_record.rate,0) * NVL(amounts_record.actual_amount,0);

            END IF; /* ignore cases WHERE l_conv_type is NULL */

         END IF;
      END IF;
    END LOOP;

    RETURN total_item_amount;

  EXCEPTION

    WHEN OTHERS THEN
    IF p_called_FROM = 'PNTAUPMT' THEN
       NULL;
    ELSE
       RAISE;
    END IF;

  END;

/*===========================================================================+
--  NAME         : get_total_payment_term_amt
--  DESCRIPTION  : Sum up and return the 'CASH' type payment items amount for a given
--                 payment term record
--  NOTES        : Currently being used in view "PN_PAYMENT_TERRMS_V"
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN:
--                        p_paymentTermId
--
--                  OUT:
--                        none
--  RETURNS      : The sum of 'CASH' payment item amounts
--  REFERENCE    :
--  HISTORY      :
--  14-MAY-98  Neeraj Tandon    o Created
--  30-OCT-02  Satish Tripathi  o Access _all table for performance issues.
 +===========================================================================*/

  FUNCTION GET_TOTAL_PAYMENT_TERM_AMT (
                                        p_paymentTermId IN NUMBER
                                      ) RETURN NUMBER
  IS

    l_totalTermAmt      NUMBER := NULL;

  BEGIN

    SELECT NVL(SUM(ppi.actual_amount),0)
    INTO   l_totalTermAmt
    FROM   pn_payment_items_all     ppi
    WHERE  ppi.PAYMENT_TERM_ID  =  p_paymentTermId
    AND    ppi.payment_item_type_lookup_code = 'CASH';

    RETURN l_totalTermAmt;

  EXCEPTION

    WHEN OTHERS THEN
    RAISE;

  END GET_TOTAL_PAYMENT_TERM_AMT ;

/*===========================================================================+
 | FUNCTION
 |    get_concatenated_address
 |
 | DESCRIPTION
 |      This FUNCTION RETURNs a sigle string of concatenated address
 |      segments.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    address_style
 |                    address_line1
 |                    address_line2
 |                    address_line3
 |                    address_line4
 |                    city
 |                    county
 |                    state
 |                    province
 |                    zip_code
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : Concatenated Address String
 |
 | NOTES      : Currently being used in view "PN_COMPANY_SITES_V"
 |
 | MODIFICATION HISTORY
 |
 |     08-JUN-1998  Neeraj Tandon   Created
 +===========================================================================*/
  FUNCTION get_concatenated_address (
                                      address_style        IN VARCHAR2,
                                      address_line1        IN VARCHAR2,
                                      address_line2        IN VARCHAR2,
                                      address_line3        IN VARCHAR2,
                                      address_line4        IN VARCHAR2,
                                      city                 IN VARCHAR2,
                                      county               IN VARCHAR2,
                                      state                IN VARCHAR2,
                                      province             IN VARCHAR2,
                                      zip_code             IN VARCHAR2,
                                      territory_short_name IN VARCHAR2
                                     )RETURN VARCHAR2
  IS
    l_address VARCHAR2(1000);
  BEGIN
   -- pn_addresses.address_line1 is a NOT NULL field.
    l_address := address_line1;

    IF ( address_line2 IS NOT NULL ) THEN
       l_address := l_address || ', ' || address_line2;
    END IF;

    IF ( address_line3 IS NOT NULL ) THEN
       l_address := l_address || ', ' || address_line3;
    END IF;

    IF ( address_line4 IS NOT NULL ) THEN
       l_address := l_address || ', ' || address_line4;
    END IF;

    IF ( city IS NOT NULL ) THEN
       l_address := l_address || ', ' || city;
    END IF;

    IF ( county IS NOT NULL ) THEN
       l_address := l_address || ', ' || county;
    END IF;

    IF ( state IS NOT NULL ) THEN
       l_address := l_address || ', ' || state;
    END IF;

    IF ( province IS NOT NULL ) THEN
       l_address := l_address || ', ' || province;
    END IF;

    IF ( zip_code IS NOT NULL ) THEN
       l_address := l_address || ', ' || zip_code;
    END IF;

    IF ( territory_short_name IS NOT NULL ) THEN
       l_address := l_address || ', ' || territory_short_name;
    END IF;

    RETURN( l_address );

  END get_concatenated_address;


/*=============================================================================+
--  NAME         : Get_Allocated_Area_By_CC
--  DESCRIPTION  : RETURN the Allocated Area by Cost Center
--  NOTES        : Currently being used in Space Allocations Report - PNSPALLO
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN:  p_location_id ,  p_Cost_Center
--                  OUT: none
--  RETURNS      : Allocated area for a location_id (building/floor/office ),
--                 for a cost center
--  REFERENCE    :
--  HISTORY      :

--  04-SEP-99  Naga Vijayapuram  o Created
--  16-JUN-00  Daniel Thota      o Included reference to PN_SPACE_ASSIGN_EMP
--                                 AND PN_SPACE_ASSIGN_CUST for new space
--                                 assignment architecture.
--  17-AUG-00  Daniel Thota      o Added new parameter p_as_of_date to the
--                                 function. Changed the WHERE clause to
--                                 include p_as_of_date - Bug Fix for #1379527
--  08-SEP-00  Daniel Thota      o Re-introduced comparison of p_as_of_date
--                                 with end date - Bug Fix for #1379527
--  18-SEP-00  Lakshmikanth K    o Using the variable
--                                 l_date    Date:=  TO_DATE('31-DEC-2199' ,
--                                 ('DD/MM/YYYY')) in the end date
--                                 comparision with the as_of_date
--  19-SEP-00  Lakshmikanth K    o Replacing the TO_DATE('31-DEC-2199' ,
--                                 ('DD/MM/YYYY')) with
--                                 TO_DATE('31/12/2199' , ('DD/MM/YYYY'))
--  30-OCT-02  Satish Tripathi   o Access _all table for performance issues.
--  20-OCT-03  ftanudja          o Removed nvl. 3197410.
--  18-FEB-04  abanerje          o Handled NO_DATA_FOUND to return 0.
--                                 All the select statements have been
--                                 converted to cursors. The l_location_type
--                                 is checked for null to return 0
--                                 Bug #3384965
--  15-JUN-05 piagrawa           o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP
--                                 and PN_SPACE_ASSIGN_CUST with _ALL table.
 +============================================================================*/

FUNCTION  Get_Allocated_Area_By_CC ( p_Location_Id  NUMBER ,
                                     p_Cost_Center  VARCHAR2,
                                     p_As_Of_Date   DATE )
RETURN  NUMBER  IS

  l_Location_Type           pn_locations.location_type_lookup_code%type;
  l_Allocated_Area          NUMBER;
  l_Allocated_Area_Emp      NUMBER;
  l_Allocated_Area_Cust     NUMBER;
  l_date                    DATE := TO_DATE('31/12/4712' , 'DD/MM/YYYY');
  l_as_of_date              DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE     EXCEPTION;

  CURSOR Alloc_Area_Emp_C ( p_Location_Id IN NUMBER
                           ,p_Cost_Center IN NUMBER
                           ,p_As_Of_Date  IN DATE)
  IS
  (SELECT NVL(SUM(Allocated_Area), 0) AS area
    FROM  PN_SPACE_ASSIGN_EMP_ALL
    WHERE Cost_Center_Code = p_Cost_Center
    AND   emp_assign_start_date <= p_As_Of_Date
    AND   NVL(emp_assign_end_date, l_date) >= p_As_Of_Date
    AND   Location_Id  IN (
      SELECT Location_Id
      FROM   PN_LOCATIONS_ALL
      WHERE  Location_Type_Lookup_Code = 'OFFICE'
      AND    p_As_Of_Date BETWEEN active_start_date AND active_end_date
      START WITH       Location_Id = p_Location_Id
      CONNECT BY PRIOR Location_Id = Parent_Location_Id
      AND p_As_Of_Date BETWEEN PRIOR active_start_date AND
                               PRIOR active_end_date)
  );

  CURSOR Alloc_Area_Cust_C ( p_Location_Id IN NUMBER
                            ,p_Cost_Center IN NUMBER
                            ,p_As_Of_Date  IN DATE)
  IS
  (SELECT NVL(SUM(Allocated_Area), 0) AS area
   FROM   PN_SPACE_ASSIGN_CUST_ALL
   WHERE  cust_assign_start_date <= p_As_Of_Date
   AND    NVL(cust_assign_end_date, l_date) >= p_As_Of_Date
   AND    Location_Id IN (
      SELECT Location_Id
      FROM   PN_LOCATIONS_ALL
      WHERE  Location_Type_Lookup_Code = 'OFFICE'
      AND    p_As_Of_Date BETWEEN active_start_date AND active_end_date
      START WITH       Location_Id = p_Location_Id
      CONNECT BY PRIOR Location_Id = Parent_Location_Id
      AND p_As_Of_Date BETWEEN PRIOR active_start_date AND PRIOR active_end_date)
  );

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_Location_Type IS NULL THEN

    RETURN 0;

  ELSIF l_Location_Type IN ('BUILDING', 'FLOOR', 'OFFICE') THEN

    FOR emp_area IN Alloc_Area_Emp_C( p_Location_Id
                                     ,p_Cost_Center
                                     ,l_As_Of_Date)
    LOOP
      l_Allocated_Area_Emp := emp_area.area;
    END LOOP;

    FOR cust_area IN Alloc_Area_Cust_C( p_Location_Id
                                       ,p_Cost_Center
                                       ,l_As_Of_Date)
    LOOP
      l_Allocated_Area_Cust := cust_area.area;
    END LOOP;

    l_Allocated_Area := NVL(l_Allocated_Area_Emp,0)
                        + NVL(l_Allocated_Area_Cust,0);

    RETURN ROUND(l_Allocated_Area, 0);

  ELSE
    RAISE  INVALID_LOCATION_TYPE ;

  END IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN  OTHERS  THEN
    RAISE;

END Get_Allocated_Area_By_CC ;

/*===========================================================================+
--  NAME         : Get_Vacant_Area
--  DESCRIPTION  : RETURN the Vacant Area
--  NOTES        : Currently being used in views "PN_LOCATIONS_V",
--                 "PN_BUILDING_V", "PN_FLOORS_V", "PN_OFFICES_V"
--                 AND form PNTSPACE.fmb ( Space Assignments form )
--  ASSUMPTION   : Sum of Usable Areas of Offices  =  Usable Area of Floor
--                 Sum of Usable Areas of Floors   =  Usable Area of Building
--  ALGORITHM    : Computation of Usable/Allocated/Vacant Areas proceeds FROM
--                 Office --> Floor --> Building
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN:  p_location_id
--                  OUT: none
--  RETURNS      : Vacant area for a location_id ( building/floor/office )
--
--  REFERENCE    :
--  HISTORY      :
--  14-MAY-98  Neeraj  o Created get_used_area
--  05-AUG-98  Nagabh  o Modified get_used_area to get_vacant_area
--  04-SEP-99  Nagabh  o Refined - Note ASSUMPTION/ALGORITHM above
--  16-JUN-00  Daniel  o Included reference to PN_SPACE_ASSIGN_EMP and
--                       PN_SPACE_ASSIGN_CUST for new spc asgn architecture
--  17-AUG-00  Daniel  o Bug #1379527
--  29-AUG-00  Daniel  o calculation of vacant area to be dependent on assignabl
--                       area instead of usable area - Bug #1386613
--  08-SEP-00  Daniel  o Bug #1379527 Re-introduced comparison of p_as_of_date
--  18-SEP-00  Lakshmi o Using the variable
--                       l_date  Date:=  TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                       in the end date comparision with the as_of_date
--  19-SEP-00  Lakshmi o Replacing the TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                       with TO_DATE('31/12/2199' , ('DD/MM/YYYY'))
--  01-MAR-01  Mrinal  o Separated quries for 'BUILDING','FLOOR'/'OFFICE' AND
--                       'LAND','PARCEL'/'SECTION' by putting INTO IF-ELSE cond.
--  14-MAY-01  Lakshmi o Bug #1766171. Do not round
--                       l_Assignable_Area - l_Allocated_Area
--  22-JAN-02  Kiran   o Bug #2168485. SELECT only the active locations
--  30-OCT-02  Satish  o Access _all table for performance issues.
--  10-JAN-03  Mrinal  o In the IF condn. for OFFICE/SECTION, while getting the
--                       allocated_area, the join between location and space
--                       assignment tables was fetching duplicate records. Fix
--                       by using EXISTS to check for status = 'A'.
--  20-OCT-03 ftanudja o removed nvl's from locn query. 3197410.
--  18-FEB-04 abanerje o Handled NO_DATA_FOUND to return 0. Select statements
--                       have been converted to cursors. The l_location_type
--                       is checked for null to return 0.  Bug #3384965.
--  15-JUN-05 piagrawa o Bug 4307795 - Replaced pn_space_assign_emp
--                       and pn_space_assign_cust with _ALL table.
--  11-JUN-09 sugupta    o Bug 6470318 - Replaced the cursor Utilised_Capacity_Emp_C with
--                       dynamic query to improve the performance.
 +===========================================================================*/

FUNCTION  get_vacant_area ( p_location_id  NUMBER,
                            p_as_of_date   DATE)
  RETURN NUMBER  IS

  l_location_type           pn_locations.location_type_lookup_code%type;
  l_usable_area             NUMBER;
  l_allocated_area          NUMBER;
  l_assignable_area         NUMBER;
  l_allocated_area_emp      NUMBER;
  l_allocated_area_cust     NUMBER;
  l_date                    DATE := TO_DATE('31/12/4712', 'DD/MM/YYYY');
  l_as_of_date              DATE := pnp_util_func.get_as_of_date(p_as_of_date);


  INVALID_LOCATION_TYPE     EXCEPTION;

   CURSOR Assignable_Area_C(p_Location_Id IN NUMBER
                           ,p_As_of_date IN DATE
                           ,p_location_type IN VARCHAR2) IS
     (SELECT NVL(SUM(assignable_area), 0) AS Area
      FROM   pn_locations_all
      WHERE  location_type_lookup_code = p_location_type
      AND    status = 'A'
      AND    p_as_of_date BETWEEN active_start_date AND active_end_date
      START WITH       location_id =  p_Location_Id
      CONNECT BY PRIOR location_id =  parent_location_id
      AND    p_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date
      );
/* Commented for Bug 6470318
   CURSOR Allocated_Area_Emp_C(p_Location_Id IN NUMBER
                              ,p_As_of_date IN DATE
                              ,p_location_type IN VARCHAR2) IS
     (SELECT NVL(SUM(allocated_area), 0) AS Area
      FROM   pn_space_assign_emp_all
      WHERE  emp_assign_start_date <= p_as_of_date
      AND    NVL(emp_assign_end_date, l_date) >= p_as_of_date
      AND    location_id IN (SELECT  Location_Id
                             FROM    pn_locations_all
                             WHERE   location_type_lookup_code = p_location_type
                             AND     Status = 'A'
                             AND     p_as_of_date BETWEEN active_start_date AND active_end_date
                             START WITH        Location_Id =  p_Location_Id
                             CONNECT BY PRIOR  Location_Id =  parent_location_id
                                 AND p_as_of_date BETWEEN prior active_start_date AND
                                 PRIOR active_end_date
                  )
      );
      */
  CURSOR c_location_id (p_Location_Id IN NUMBER
                              ,p_As_of_date IN DATE
                              ,p_location_type IN VARCHAR2) IS
    SELECT  Location_Id
    FROM    pn_locations_all
    WHERE   location_type_lookup_code = p_location_type
    AND     Status = 'A'
    AND     p_as_of_date BETWEEN active_start_date AND active_end_date
    START WITH        Location_Id =  p_Location_Id
    CONNECT BY PRIOR  Location_Id =  parent_location_id
    AND p_as_of_date BETWEEN prior active_start_date AND
    PRIOR active_end_date ;

    loc_index number := 0;
    l_statement varchar2(10000);
    l_cursor integer;
    alloc_area number;
    l_query VARCHAR2(12000);
    l_rows number;

-- End Bug 6470318

   CURSOR Allocated_Area_Cust_C(p_Location_Id IN NUMBER
                               ,p_As_of_date IN DATE
                               ,p_location_type IN VARCHAR2) IS
     (SELECT NVL(SUM(allocated_area), 0) AS Area
      FROM   pn_space_assign_cust_all
      WHERE  cust_assign_start_date <= p_As_of_date
      AND    NVL(cust_assign_end_date, l_date) >= p_As_of_date
      AND    location_Id IN (SELECT  location_id
                             FROM    pn_locations_all
                             WHERE   location_type_lookup_code = p_location_type
                             AND     status = 'A'
                             AND     p_as_of_date BETWEEN active_start_date AND active_end_date
                             START WITH        location_id = p_location_id
                             CONNECT BY PRIOR  location_id = parent_location_id
                              AND p_as_of_date between PRIOR active_start_date AND
                             PRIOR active_end_date)
     );

     CURSOR Assignable_Area_Child_C(p_Location_Id IN NUMBER
                                   ,p_As_of_date IN DATE) IS
     (SELECT NVL(SUM(assignable_area), 0) AS Area
      FROM   pn_locations_all
      WHERE  location_id = p_location_id
      AND    p_as_of_date BETWEEN active_start_date AND active_end_date
      AND    status = 'A'
     );

    CURSOR Allocated_Area_Child_Emp_C(p_Location_Id IN NUMBER
                                     ,p_As_of_date IN DATE) IS
     (SELECT NVL(SUM(e.allocated_area), 0) AS Area
      FROM   pn_space_assign_emp_all e
      WHERE  E.emp_assign_start_date <= p_as_of_date
      AND    NVL(e.emp_assign_end_date, l_date) >= p_as_of_date
      AND    e.location_id = p_location_id
      AND    EXISTS (SELECT NULL
                     FROM   pn_locations_all l
                     WHERE  l.status = 'A'
                     AND    l.location_id = p_Location_Id)
     );

    CURSOR Allocated_Area_Child_Cust_C(p_Location_Id IN NUMBER
                                      ,p_As_of_date  IN DATE) IS
     (SELECT NVL(SUM(c.allocated_area), 0) AS Area
      FROM   pn_space_assign_cust_all c
      WHERE  c.cust_assign_start_date <= p_as_of_date
      AND    NVL(c.cust_assign_end_date, l_date) >= p_as_of_date
      AND    c.location_id = p_location_id
      AND    EXISTS (SELECT NULL
                     FROM   pn_locations_all l
                     WHERE  l.status = 'A'
                     AND    l.location_id = p_location_id)
     );

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code(
                                   p_location_id => p_location_id,
                                   p_as_of_date  => l_as_of_date);


  IF l_location_type IS NULL THEN
      RETURN 0;

  ELSIF (l_location_type IN ('BUILDING', 'FLOOR','LAND', 'PARCEL')) THEN
     IF l_location_type in ('BUILDING', 'FLOOR') then
        l_location_type := 'OFFICE' ;
     ELSIF l_location_type in ('LAND', 'PARCEL') then
        l_location_type := 'SECTION' ;
     END IF;
/* Commented for Bug 6470318
    FOR emp_area IN Allocated_Area_Emp_C( p_Location_Id
                                         ,l_As_Of_Date
                                         ,l_location_type)
    LOOP
      l_Allocated_Area_Emp := emp_area.area;
    END LOOP;
*/
   l_query := 'SELECT NVL(SUM(allocated_area), 0) AS Area ';
   l_query := l_query || ' FROM   pn_space_assign_emp_all ';
   l_query := l_query || ' WHERE  emp_assign_start_date <= :p_as_of_date ';
   l_query := l_query || ' AND NVL(emp_assign_end_date, :l_date) >= :p_as_of_date AND location_id IN ';
   for loc in c_location_id( p_Location_Id
                            ,l_As_Of_Date
                            ,l_location_type)
   loop
    loc_index := loc_index +1;
    if loc_index = 1 then
     l_statement := '(' || loc.location_id;
    else
     l_statement := l_statement ||',' || loc.location_id;
    end if;

    if loc_index = 1000 then
      loc_index := 0;
      alloc_area := 0;
      l_statement := l_statement || ')';

      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor, l_query || l_statement, DBMS_SQL.native);
      dbms_sql.bind_variable (l_cursor,'p_as_of_date',l_As_Of_Date );
      dbms_sql.bind_variable (l_cursor,'l_date',l_date );
      dbms_sql.define_column (l_cursor, 1,alloc_area);
      l_rows :=  DBMS_SQL.execute(l_cursor);
      l_rows := dbms_sql.fetch_rows( l_cursor );
      dbms_sql.column_value (l_cursor, 1,alloc_area);
      DBMS_SQL.CLOSE_CURSOR (l_cursor);

      l_statement := '';
      l_Allocated_Area_Emp := NVL(l_Allocated_Area_Emp, 0) + alloc_area;
    end if;
   end loop;

   if loc_index > 0 then
      loc_index := 0;
      alloc_area := 0;
      l_statement := l_statement || ')';

      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor, l_query || l_statement, DBMS_SQL.native);
      dbms_sql.bind_variable (l_cursor,'p_as_of_date',l_As_Of_Date );
      dbms_sql.bind_variable (l_cursor,'l_date',l_date );
      dbms_sql.define_column (l_cursor, 1,alloc_area);
      l_rows :=  DBMS_SQL.execute(l_cursor);
      l_rows := dbms_sql.fetch_rows( l_cursor );
      dbms_sql.column_value (l_cursor, 1,alloc_area);
      DBMS_SQL.CLOSE_CURSOR (l_cursor);

      l_statement := '';
      l_Allocated_Area_Emp := NVL(l_Allocated_Area_Emp, 0) + alloc_area;
    end if;
-- EndBug 6470318

    FOR cust_area IN Allocated_Area_Cust_C( p_Location_Id
                                           ,l_As_Of_Date
                                           ,l_location_type)
    LOOP
      l_Allocated_Area_Cust := cust_area.area;
    END LOOP;

    FOR assignable_area IN Assignable_Area_C( p_Location_Id
                                             ,l_As_Of_Date
                                             ,l_location_type)
    LOOP
      l_assignable_area := assignable_area.area;
    END LOOP;

    l_Allocated_Area := NVL(l_Allocated_Area_Emp,0)
                        + NVL(l_Allocated_Area_Cust,0);

    RETURN (NVL(l_assignable_area,0) - l_allocated_area);

   ELSIF l_location_type in('OFFICE','SECTION') THEN

    FOR emp_area IN Allocated_Area_Child_Emp_C( p_Location_Id
                                               ,l_As_Of_Date)
    LOOP
      l_Allocated_Area_Emp := emp_area.area;
    END LOOP;

    FOR cust_area IN Allocated_Area_Child_Cust_C( p_Location_Id
                                                 ,l_As_Of_Date)
    LOOP
      l_Allocated_Area_Cust := cust_area.area;
    END LOOP;

    FOR assignable_area IN Assignable_Area_Child_C( p_Location_Id
                                                   ,l_As_Of_Date)
    LOOP
      l_assignable_area := assignable_area.area;
    END LOOP;

    l_Allocated_Area := NVL(l_Allocated_Area_Emp,0)
                        + NVL(l_Allocated_Area_Cust,0);

    RETURN (NVL(l_assignable_area,0) - l_allocated_area);

  ELSE

    RAISE  INVALID_LOCATION_TYPE ;

  END IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN  OTHERS  THEN
    RAISE;

END get_vacant_area;

/*===========================================================================+
 | FUNCTION
 |   Get_Vacant_Area_Percent
 |
 | DESCRIPTION
 |   RETURN the Vacant Area Percentage
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   Vacant area percentage for a location_id ( building )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |   17-AUG-2000  Daniel Thota    Added default SYSDATE to call to
 |                                pnp_util_func.Get_Vacant_Area
 |                                - Bug Fix for #1379527
 |   05-FEB-2001  Lakshmikanth    Replaced get_building_rentable_area by
 |                                get_building_assignable_area in the
 |                                get_vacant_area_percent.
 |                                - Bug Fix for #1519506.
 |   05-MAY-2004  ftanudja        handle if location type is null.
 +===========================================================================*/

FUNCTION  get_vacant_area_percent ( p_Location_Id  NUMBER ,
                                    p_as_of_date  DATE  )  RETURN  NUMBER  IS

 l_Location_Type             pn_locations.location_type_lookup_code%type;
 l_as_of_date                DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 l_Vacant_Area               NUMBER:=  Get_Vacant_Area ( p_Location_Id,
                                                         pnp_util_func.get_as_of_date(p_as_of_date));
 l_Assignable_Area           NUMBER:=  get_building_assignable_area ( p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
 INVALID_LOCATION_TYPE       EXCEPTION;
 a                           NUMBER := 0;

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code(
                                   p_location_id => p_location_id,
                                   p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
     raise NO_DATA_FOUND;
  ELSIF   l_Location_Type in('BUILDING', 'LAND')  THEN

     IF (NVL(l_Assignable_Area, 0) = 0) THEN
         a:= 0;
     ELSE
         a:=  (l_Vacant_Area * 100/l_Assignable_Area);
     END IF;

  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

  RETURN a;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_vacant_area_percent;


/*===========================================================================+
 | FUNCTION
 |   get_load_factor
 |
 | DESCRIPTION
 |   RETURN the Load Factor
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   Load Factor for a location_id ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 | 05-MAY-04 ftanudja o handle if location type is null.
 +===========================================================================*/


FUNCTION  get_load_factor ( p_Location_Id  NUMBER ,
                           p_as_of_date    DATE  )  RETURN  NUMBER  IS


  l_Location_Type             pn_locations.location_type_lookup_code%type;

  l_Rentable_Area             NUMBER:= get_building_rentable_area (p_location_id,
                                                                   pnp_util_func.get_as_of_date(p_as_of_date));
  l_Usable_Area               NUMBER:= get_building_usable_area ( p_location_id,
                                                                  pnp_util_func.get_as_of_date(p_as_of_date));
  l_return_value              NUMBER;
  l_as_of_date                DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE       EXCEPTION;
  a                           NUMBER:= 0;

BEGIN


  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
     raise NO_DATA_FOUND;
  ELSIF  l_Location_Type in ('BUILDING', 'LAND')  THEN

     IF (NVL(l_usable_area, 0) = 0) THEN
         a:= 0;
     ELSE
         a:= ((l_Rentable_Area/l_Usable_Area) - 1);
     END IF;
  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

    RETURN a;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_load_factor;


/*===========================================================================+
 | FUNCTION
 |   get_floors
 |
 | DESCRIPTION
 |   RETURN the NUMBER of floors associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the NUMBER of floors associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |   22-JAN-02  Kiran      o Bug Fix for the Bug ID#2168485.
 |                           Added the Status = 'A' condition for all the
 |                           SELECT statements to SELECT only the active
 |                           locations
 |   30-OCT-02  Satish     o Access _all table for performance issues.
 |
 |   31-OCT-01  graghuna   o added p_as_of_date for Location Date-Effectivity.
 |   20-OCT-03  ftanudja   o removed nvl's for locations tbl. 3197410.
 |   18-FEB-04  abanerje   o Handled NO_DATA_FOUND exception to return null.
 |                           The select statment has been changed to a
 |                           cursor now.
 |                           Bug #3384965.
 +===========================================================================*/

FUNCTION  get_floors ( p_Location_Id  NUMBER ,
                       p_as_of_date   DATE )
RETURN  NUMBER  IS

  l_Location_Type             pn_locations.location_type_lookup_code%type;
  l_floors                    NUMBER;
  l_as_of_date                DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE       EXCEPTION;

  CURSOR floor_count_C( p_Location_Id  NUMBER
                       ,p_as_of_date   DATE
                       ,p_location_type VARCHAR2) IS
   (SELECT COUNT(pn_locations_all.floor) AS floor_count
    FROM   pn_locations_all
    WHERE  Location_Type_Lookup_Code = p_location_type
    AND    Status = 'A'
    AND    p_as_of_date BETWEEN active_start_date AND active_end_date
    START WITH Location_Id = p_Location_Id
    CONNECT BY PRIOR Location_Id = Parent_Location_Id
    AND    p_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date
   );

BEGIN


  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
     RETURN 0;
  ELSIF l_location_type in ('BUILDING', 'LAND') THEN

     IF l_location_type = 'BUILDING' then
         l_location_type := 'FLOOR' ;
     ELSE
        l_location_type := 'PARCEL' ;
     END IF;

    FOR floor_cnt IN floor_count_C( p_Location_Id
                                   ,l_As_Of_Date
                                   ,l_location_type)
    LOOP
      l_floors := floor_cnt.floor_count;
    END LOOP;

    RETURN (NVL(l_floors,0));
  ELSE
    Raise  INVALID_LOCATION_TYPE ;

  END IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN  OTHERS  THEN
    RAISE;

END get_floors;


/*===========================================================================+
 | FUNCTION
 |   get_offices
 |
 | DESCRIPTION
 |   RETURN the NUMBER of offices associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the NUMBER of offices associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |   22-JAN-2002  Kiran      o Bug Fix for the Bug ID#2168485.
 |                             Added the Status = 'A' condition for all the
 |                             SELECT statements to SELECT only the active
 |
 |   30-OCT-2002  Satish     o Access _all table for performance issues.
 |
 |   31-OCT-2001  graghuna   o added p_as_of_date for Location Date-Effectivity.
 |   10-JUL-2003  Satish     o Added for 'FLOOR/PARCEL'
 |   20-OCT-2003  ftanudja   o removed nvl's for locations tbl. 3197410.
 |   05-MAY-2004  ftanudja   o handle if location type is null.
 +===========================================================================*/

FUNCTION  get_offices ( p_Location_Id  NUMBER ,
                        p_as_of_date   IN DATE )
RETURN  NUMBER  IS

  l_Location_Type             pn_locations.location_type_lookup_code%type;
  l_offices                   NUMBER;
  l_as_of_date                DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE       EXCEPTION;

BEGIN


  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
     raise NO_DATA_FOUND;
  ELSIF l_location_type IN ('BUILDING','LAND','FLOOR','PARCEL') THEN

     IF l_location_type IN ('BUILDING','FLOOR') THEN
         l_location_type := 'OFFICE' ;
     ELSE
        l_location_type := 'SECTION' ;
     END IF;

    SELECT COUNT(office)
    INTO   l_offices
    FROM   pn_locations_all
    WHERE  Location_Type_Lookup_Code = l_location_type   --'OFFICE'
    AND    Status = 'A'               --BUG#2168485
    AND    l_as_of_date BETWEEN active_start_date AND active_end_date
    START WITH Location_Id = p_Location_Id
    CONNECT BY PRIOR Location_Id = Parent_Location_Id
    AND l_as_of_date between prior active_start_date and
    PRIOR active_end_date;

  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

  RETURN (l_offices);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN null;
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_offices;



/*===========================================================================+
--  NAME         : get_utilized_capacity
--  DESCRIPTION  : RETURN the Utilized Capacity for a given location_id
--  NOTES        : Currently being used in view "PN_LOCATIONS_V"
--                 "PN_BUILDING_V", "PN_FLOORS_V", "PN_OFFICES_V"
--                 AND Space Assignments form - "PNTSPACE.fmb"
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN:  p_location_id
--                 OUT: none
--  RETURNS      : Total utilized capacity for a location
--
--  REFERENCE    :
--  HISTORY      :
--
--  14-MAY-98  Neeraj    o Created
--  05-AUG-98  Nagabh    o Modified to take only location_id arg.
--  16-JUN-00  Daniel    o Included reference to PN_SPACE_ASSIGN_EMP
--                         AND PN_SPACE_ASSIGN_CUST for new space
--                         assignment architecture.
--  17-AUG-00  Daniel    o Added new parameter p_as_of_date to the
--                         function. Changed the WHERE clause to
--                         include p_as_of_date - Bug Fix for #1379527
--  01-SEP-00  Daniel    o Changed to suit roll-up feature AND
--                         to use sum of utilized area
--                         Bug # 1377665 AND 1383188
--  08-SEP-00  Daniel    o Re-introduced comparison of p_as_of_date
--                         with end date - Bug Fix for #1379527
--  18-SEP-00  Lakshmi K o Using the variable l_date
--                         Date:=  TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                         in the end date comparision with the as_of_date
--  19-SEP-00  Lakshmi K o Replacing the
--                         TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                         with TO_DATE('31/12/2199' , ('DD/MM/YYYY'))
--  01-MAR-01  Mrinal    o Separated queries for 'BUILDING/LAND',
--                        'FLOOR/PARCEL'  AND 'OFFICE/SECTION'
--                         by putting IF-ELSE condition.
--  30-OCT-02  Satish    o Access _all table for performance issues.
--  20-OCT-03  ftanudja  o removed nvl's for locations tbl. 3197410.
--  18-FEB-04  abanerje  o Handled NO_DATA_FOUND to return 0.
--                         All the select statements have been converted
--                         to cursors. The l_location_type is checked
--                         for null to return 0 Bug #3384965.
--  15-JUN-05  piagrawa  o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                         PN_SPACE_ASSIGN_CUST with _ALL table.
--  11-June-09 sugupta    o Bug 6470318 - Replaced the cursor Utilised_Capacity_Emp_C with
--                       dynamic query to improve the performance.
+===========================================================================*/

FUNCTION get_utilized_capacity ( p_location_id IN NUMBER,
                                 p_As_Of_Date  IN DATE)
RETURN NUMBER
IS
    l_LocationType              pn_locations.location_type_lookup_code%TYPE;
    l_UtilizedCapacity          NUMBER:=0;
    l_UtilizedCapacityEmp       NUMBER:=0;
    l_UtilizedCapacityCust      NUMBER:=0;
    l_as_of_date                DATE   := pnp_util_func.get_as_of_date(p_as_of_date);

/* Commented and modified for bug 6470318
  CURSOR Utilised_Capacity_Emp_C( p_location_id IN NUMBER,
                                  p_As_Of_Date  IN DATE) IS
    (SELECT SUM(NVL(UTILIZED_AREA,0)) AS Area
           FROM   pn_space_assign_emp_all
           WHERE  location_id IN (SELECT a.location_id
                                  FROM   pn_locations_all a
                                  WHERE  p_As_Of_Date BETWEEN active_start_date AND
                                         active_end_date
                                  START WITH       a.location_id = p_location_id
                                  CONNECT BY PRIOR a.location_id = a.parent_location_id
                                  AND p_as_of_date
                                  BETWEEN PRIOR active_start_date AND PRIOR active_end_date)
           AND     p_as_of_date BETWEEN emp_assign_start_date AND
                   NVL(emp_assign_end_date, g_end_of_time)
    );*/
  CURSOR c_location_id (p_Location_Id IN NUMBER
                        ,p_As_of_date IN DATE) IS
    SELECT  Location_Id
    FROM    pn_locations_all
    WHERE   p_as_of_date BETWEEN active_start_date AND
            active_end_date
    START WITH        Location_Id =  p_Location_Id
    CONNECT BY PRIOR  Location_Id =  parent_location_id
    AND p_as_of_date BETWEEN prior active_start_date AND
    PRIOR active_end_date ;

    loc_index number := 0;
    l_statement varchar2(10000);
    l_cursor integer;
    utilized_cap number;
    l_query VARCHAR2(12000);
    l_rows number;

-- End Bug 6470318

  CURSOR Utilised_Capacity_Cust_C( p_location_id IN NUMBER
                                  ,p_As_Of_Date  IN DATE) IS
         (SELECT SUM(NVL(UTILIZED_AREA,0)) AS Area
          FROM   pn_space_assign_cust_all
           WHERE  location_id IN (SELECT a.location_id
                                  FROM   pn_locations_all a
                                  WHERE  p_as_of_date BETWEEN active_start_date AND
                                         active_end_date
                                  START WITH       a.location_id = p_location_id
                                  CONNECT BY PRIOR a.location_id = a.parent_location_id
                                  AND p_as_of_date
                                  BETWEEN PRIOR active_start_date AND PRIOR active_end_date)
           AND     p_as_of_date BETWEEN cust_assign_start_date AND
                   NVL(cust_assign_end_date, g_end_of_time)
          );

  CURSOR Utilised_Capacity_Child_Emp_C( p_location_id IN NUMBER,
                                        p_As_Of_Date  IN DATE) IS
   (SELECT SUM(NVL(UTILIZED_AREA,0)) AS Area
           FROM   pn_space_assign_emp_all
           WHERE  location_id = p_location_id
           AND     p_as_of_date BETWEEN emp_assign_start_date AND
                   NVL(emp_assign_end_date, g_end_of_time)
   );

  CURSOR Utilised_Capacity_Child_Cust_C( p_location_id IN NUMBER,
                                         p_As_Of_Date  IN DATE) IS
    (SELECT SUM(NVL(UTILIZED_AREA,0)) AS Area
           FROM   pn_space_assign_cust_all
           WHERE  location_id = p_location_id
           AND    p_as_of_date BETWEEN cust_assign_start_date AND
                  NVL(cust_assign_end_date, g_end_of_time)
     );
BEGIN

  l_locationtype := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date => l_as_of_date);
   IF l_LocationType IS NULL THEN
                           RETURN 0;
   ELSIF l_LocationType IN ('BUILDING','FLOOR','LAND','PARCEL') THEN
   /* Commented for Bug 6470318
    FOR emp_area IN Utilised_Capacity_Emp_C( p_Location_Id
                                            ,l_As_Of_Date)
    LOOP
      l_UtilizedCapacityEmp := emp_area.area;
    END LOOP;*/
   l_query := 'SELECT SUM(NVL(UTILIZED_AREA,0)) AS Area ';
   l_query := l_query || ' FROM   pn_space_assign_emp_all ';
   l_query := l_query || ' WHERE  :p_as_of_date BETWEEN emp_assign_start_date AND NVL(emp_assign_end_date, :g_end_of_time) ';
   l_query := l_query || ' AND location_id IN ';
   for loc in c_location_id( p_Location_Id
                            ,l_As_Of_Date)
   loop
    loc_index := loc_index +1;
    if loc_index = 1 then
     l_statement := '(' || loc.location_id;
    else
     l_statement := l_statement ||',' || loc.location_id;
    end if;

    if loc_index = 1000 then
      loc_index := 0;
      utilized_cap := 0;
      l_statement := l_statement || ')';

      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor, l_query || l_statement, DBMS_SQL.native);
      dbms_sql.bind_variable (l_cursor,'p_as_of_date',l_As_Of_Date );
      dbms_sql.bind_variable (l_cursor,'g_end_of_time',g_end_of_time );
      dbms_sql.define_column (l_cursor, 1,utilized_cap);
      l_rows :=  DBMS_SQL.execute(l_cursor);
      l_rows := dbms_sql.fetch_rows( l_cursor );
      dbms_sql.column_value (l_cursor, 1,utilized_cap);
      DBMS_SQL.CLOSE_CURSOR (l_cursor);

      l_statement := '';
      l_UtilizedCapacityEmp := NVL(l_UtilizedCapacityEmp, 0) + utilized_cap;
    end if;
   end loop;

   if loc_index > 0 then
      loc_index := 0;
      utilized_cap := 0;
      l_statement := l_statement || ')';

      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor, l_query || l_statement, DBMS_SQL.native);
      dbms_sql.bind_variable (l_cursor,'p_as_of_date',l_As_Of_Date );
      dbms_sql.bind_variable (l_cursor,'g_end_of_time',g_end_of_time );
      dbms_sql.define_column (l_cursor, 1,utilized_cap);
      l_rows :=  DBMS_SQL.execute(l_cursor);
      l_rows := dbms_sql.fetch_rows( l_cursor );
      dbms_sql.column_value (l_cursor, 1,utilized_cap);
      DBMS_SQL.CLOSE_CURSOR (l_cursor);

      l_statement := '';
      l_UtilizedCapacityEmp := NVL(l_UtilizedCapacityEmp, 0) + utilized_cap;
    end if;
-- EndBug 6470318

    FOR cust_area IN Utilised_Capacity_Cust_C( p_Location_Id
                                              ,l_As_Of_Date)
    LOOP
      l_UtilizedCapacityCust := cust_area.area;
    END LOOP;

    l_utilizedCapacity := NVL(l_UtilizedCapacityEmp,0) + NVL(l_UtilizedCapacityCust,0);

  RETURN (l_utilizedCapacity);

   ELSIF l_LocationType in ('OFFICE','SECTION') THEN

    FOR emp_area IN Utilised_Capacity_Child_Emp_C( p_Location_Id
                                                  ,l_As_Of_Date)
    LOOP
      l_UtilizedCapacityEmp := emp_area.area;
    END LOOP;

    FOR cust_area IN Utilised_Capacity_Child_Cust_C( p_Location_Id
                                                    ,l_As_Of_Date)
    LOOP
      l_UtilizedCapacityCust := cust_area.area;
    END LOOP;


    l_utilizedCapacity := NVL(l_UtilizedCapacityEmp,0) + NVL(l_UtilizedCapacityCust,0);

     RETURN (l_utilizedCapacity);

   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE;

END get_utilized_capacity ;



/*===========================================================================+
 | FUNCTION
 |    get_vacancy
 |
 | DESCRIPTION
 |    RETURN the Vacant Capacity for a given location_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    : Vacant capacity for a location (building/LAND)
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 |
 |   17-AUG-2000  Daniel Thota    Added default SYSDATE to call to
 |                                pnp_util_func.get_utilized_capacity
 |                                - Bug Fix for #1379527
 |
 |   31-OCT-2001  graghuna         o added p_as_of_date for Location
 |                                   Date-Effectivity.
 |   24-FEB-2004  abanerje         o Returned 0 for l_max_capacity < 0
 |   05-MAY-2004  ftanudja         o handle if location type is null.
 +===========================================================================*/

FUNCTION  get_vacancy ( p_Location_Id  NUMBER,
                        p_as_of_date IN DATE )
RETURN  NUMBER  IS

  l_Location_Type        pn_locations.location_type_lookup_code%type;
  l_utilized_capacity    NUMBER:= pnp_util_func.get_utilized_capacity (p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_max_capacity         NUMBER:= pnp_util_func.get_building_max_capacity ( p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_as_of_date           DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE  EXCEPTION;

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);
  IF l_location_type IS NULL THEN
     raise NO_DATA_FOUND;
  ELSIF  l_Location_Type in ('BUILDING', 'LAND')  THEN
     IF ROUND((l_max_capacity - l_utilized_capacity), 2) > 0 THEN
        RETURN ROUND((l_max_capacity - l_utilized_capacity), 2);
     ELSE
        RETURN 0;
     END IF;

  ELSE
    Raise  INVALID_LOCATION_TYPE ;

  END IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_vacancy;


/*===========================================================================+
 | FUNCTION
 |    get_occupancy_percent
 |
 | DESCRIPTION
 |    RETURN the Occupancy Percentage for a given location_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    : Occupancy Percentage for a location (building/LAND)
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 |
 |   17-AUG-2000  Daniel Thota    Added default SYSDATE to call to
 |                                pnp_util_func.get_utilized_capacity
 |                                - Bug Fix for #1379527
 |
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 |   05-MAY-2004  ftanudja        o handle if location type is null.
 +===========================================================================*/

FUNCTION  get_occupancy_percent ( p_Location_Id  NUMBER ,
                                  p_as_of_date IN DATE )  RETURN  NUMBER  IS

  l_Location_Type       pn_locations.location_type_lookup_code%type;
  l_utilized_capacity   NUMBER:= pnp_util_func.get_utilized_capacity (p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_max_capacity        NUMBER:= get_building_max_capacity ( p_Location_Id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE EXCEPTION;
  a                     NUMBER:= 0;

BEGIN



  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF  l_location_type IS NULL THEN
     raise NO_DATA_FOUND; --???
  ELSIF  l_Location_Type in ('BUILDING', 'LAND')  THEN

     IF (NVL(l_max_capacity, 0) = 0) THEN
        a:=0;
     ELSE
        a:= (l_utilized_capacity *100/l_max_capacity);
     END IF;

  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

  RETURN a;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_occupancy_percent;


/*===========================================================================+
 | FUNCTION
 |    get_area_utilized
 |
 | DESCRIPTION
 |    RETURN the Utilized Area for a given location_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    :  Utilized Area for a location (building/LAND)
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 |
 |   17-AUG-2000  Daniel Thota    Added default SYSDATE to call to
 |                                pnp_util_func.get_utilized_capacity
 |                                AND pnp_util_func.Get_Vacant_Area
 |                                - Bug Fix for #1379527
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 |  05-MAY-2004  ftanudja         o handle if location type is null.
 +===========================================================================*/

FUNCTION  get_area_utilized ( p_Location_Id  NUMBER,
                              p_as_of_date IN DATE
                            )  RETURN  NUMBER  IS

  l_Location_Type             pn_locations.location_type_lookup_code%type;

  l_Vacant_Area               NUMBER:=  Get_Vacant_Area ( p_Location_Id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_rentable_area             NUMBER:=  get_building_rentable_area ( p_Location_Id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_utilized_capacity         NUMBER:=  get_utilized_capacity ( p_Location_Id,pnp_util_func.get_as_of_date(p_as_of_date));
  INVALID_LOCATION_TYPE       EXCEPTION;
  l_as_of_date                DATE := pnp_util_func.get_as_of_date(p_as_of_date);
  a                           NUMBER := 0;

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
     raise NO_DATA_FOUND;
  ELSIF  l_Location_Type in ('BUILDING', 'LAND')  THEN

  IF ((NVL(l_rentable_area, 0) = 0) OR (NVL(l_utilized_capacity, 0) = 0)) THEN
       a:= 0;
     ELSE
       a:= (l_rentable_area/l_utilized_capacity);
  END IF;


  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;


     RETURN a;


EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_area_utilized;




/*===========================================================================+
 | FUNCTION
 |    GET_TOTAL_LEASED_AREA
 |
 | DESCRIPTION
 |    Sum up the total leased area for a given lease
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_leaseId
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : The sum of leased area for a given LEASE_ID
 |
 | NOTES      : Currently being used in view "PN_PAYMENT_TERRMS_V"
 |
 | MODIFICATION HISTORY
 |
 |  14-MAY-98  Neeraj Tandon   Created
 |  30-OCT-02  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-01  graghuna         o added p_as_of_date for Location
 |                                Date-Effectivity.
 |  20-OCT-03  ftanudja         o Removed nvl's for locations tbl. 3197410.
 |  18-FEB-04  abanerje         o Handled NO_DATA_FOUND to return 0.
 |                                All the select statements have been
 |                                converted to cursors. The l_location_type
 |                                is checked for null to return 0 .
 |                                Bug #3384965.
 +===========================================================================*/

FUNCTION get_total_leased_area (
         p_leaseId       IN NUMBER,
         p_as_of_date    IN DATE ) RETURN         NUMBER
IS

    l_totalArea         NUMBER := 0;
    l_as_of_date        DATE := pnp_util_func.get_as_of_date(p_as_of_date);


  CURSOR Total_Area_C(
         p_leaseId       IN NUMBER,
         p_as_of_date    IN DATE ) IS

  (SELECT NVL(SUM(pnl.RENTABLE_AREA),0) AS Area
   FROM   pn_locations_all pnl,
          pn_tenancies_all pnt
   WHERE  pnt.lease_id    = p_leaseId
   AND    pnt.status      = 'A'
   AND    pnl.location_id = pnt.location_id
   AND    p_as_of_date BETWEEN pnl.active_start_date AND pnl.active_end_date
  );


BEGIN

    FOR Total_Area IN Total_Area_C( p_leaseId ,l_As_Of_Date)
    LOOP
      l_totalArea := Total_Area .area;
    END LOOP;

   RETURN (NVL(l_totalArea,0));

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;

END GET_TOTAL_LEASED_AREA;


----------------------------------------------------------------------
-- GET_LEASE_STATUS --
--     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
----------------------------------------------------------------------
FUNCTION    GET_LEASE_STATUS (
                    p_leaseId        IN    NUMBER
            )
RETURN    VARCHAR2
IS
    l_leaseStatus        VARCHAR2(2);
BEGIN

    SELECT status
    INTO   l_leaseStatus
    FROM   pn_leases_all
    WHERE  lease_id    = p_leaseId;

    RETURN (l_leaseStatus);

END GET_LEASE_STATUS;


----------------------------------------------------------------------
-- pn_distinct_zip_code --
--     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
----------------------------------------------------------------------
FUNCTION pn_distinct_zip_code (
  p_address_id          NUMBER,
  p_zip_code            VARCHAR2
) RETURN NUMBER is

  l_count  NUMBER;

begin


  SELECT count(*)
  INTO   l_count
  FROM   pn_addresses_all
  WHERE  zip_code    = p_zip_code
  AND    address_id <= p_address_id ;

  RETURN l_count;

end pn_distinct_zip_code;


-------------------------------------------------------------------------------
--  NAME         : GET_LOCATION_OCCUPANCY
--  DESCRIPTION  : This FUNCTION RETURNs the NUMBER of employees assigned
--                 to a location
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_locationId,
--                      p_As_Of_Date
--  RETURNS      : the NUMBER of employees assigned to a location
--  HISTORY      :
-- 17-AUG-00  Daniel Thota   o Added new parameter p_as_of_date to the
--                             function. Changed the WHERE clause to
--                             include p_as_of_date - Bug Fix for #1379527
-- 08-SEP-00  Daniel Thota   o Re-introduced comparison of p_as_of_date
--                             with end date - Bug Fix for #1379527
-- 18-SEP-00  Lakshmikanth K o Using the variable l_date
--                             Date:=  TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                             in the end date comparision with the as_of_date
-- 19-SEP-00  Lakshmikanth K o Replacing the TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                             with TO_DATE('31/12/2199' , ('DD/MM/YYYY'))
-- 31-OCT-01  graghuna       o added p_as_of_date for Location Date-Effectivity.
-- 15-JUN-05  piagrawa       o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                             PN_SPACE_ASSIGN_CUST with _ALL table.
-------------------------------------------------------------------------------
FUNCTION GET_LOCATION_OCCUPANCY (
                p_locationId          IN    NUMBER,
                p_As_Of_Date          IN    DATE
        )
RETURN NUMBER  IS
l_occupancyCount     NUMBER := 0;
l_occupancyCountEmp  NUMBER := 0;
l_occupancyCountCust NUMBER := 0;
l_date               DATE := TO_DATE('31/12/2199' , 'DD/MM/YYYY');
l_as_of_date         DATE := pnp_util_func.get_as_of_date(p_as_of_date);

BEGIN

  SELECT NVL(count (*), 0)
  INTO   l_occupancyCountEmp
  FROM   pn_space_assign_emp_all
  WHERE  location_id = p_locationId
  AND    emp_assign_start_date <= l_as_of_date
  AND    NVL(emp_assign_end_date, l_date) >= l_as_of_date;

  SELECT NVL(count (*), 0)
  INTO   l_occupancyCountCust
  FROM   pn_space_assign_cust_all
  WHERE  location_id = p_locationId
  AND    cust_assign_start_date <= l_as_of_date
  AND    NVL(cust_assign_end_date, l_date) >= l_as_of_date;

  l_occupancyCount := l_occupancyCountEmp + l_occupancyCountCust;

RETURN (l_occupancyCount);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (0);

END GET_LOCATION_OCCUPANCY;

/*===========================================================================+
 | FUNCTION
 |    get_cost_center
 |
 | DESCRIPTION
 |    RETURN the cost center of an employee at HR assignment level
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_employee_id
 |                    p_column_name
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : cost_center
 |
 | NOTES      : Currently being used in Space Allocation Form (PNTSPACE.pll)
 |
 | MODIFICATION HISTORY
 |
 |     19-SEP-1998  Neeraj Tandon   Created
 |                  Naga   Vijay    Modified to fix bug
 |     27-JUN-2003  Satish Tripathi  o Added code to calculate p_column_name if
 |                                     p_column_name is passed NULL.
 |     03-NOV-2005  sdmahesh         o ATG mandated changes for SQL literals
 |     28-NOV-05    sdmahesh         o Added parameter org_id
 |                                     Passed org_id to get_profile_value
 +===========================================================================*/
FUNCTION get_cost_center (
  p_employee_id  IN  NUMBER,
  p_column_name  IN  VARCHAR2,
  p_org_id       IN  NUMBER
) RETURN VARCHAR2 IS

   l_column_name        VARCHAR2 (25);
   l_set_of_books_id    NUMBER;
   l_coa_id             NUMBER;
   l_segnum             VARCHAR2(25);
   l_appcol_name        VARCHAR2(25);
   l_seg_name           VARCHAR2(30);
   l_prompt             VARCHAR2(80);
   l_value_set_name     VARCHAR2(60);
   l_cost_center_code   VARCHAR2(30);
   p_cost_center        VARCHAR2(30) := NULL;
   sql_statement        VARCHAR2(2000);
   l_employee_id        NUMBER;

   l_cursor         INTEGER;
   l_rows           INTEGER;
   l_count          INTEGER;


   CURSOR get_coa_id (p_set_of_books_id IN NUMBER) IS
      SELECT gl_sob.chart_of_accounts_id
      FROM   gl_sets_of_books   gl_sob
      WHERE  gl_sob.set_of_books_id = l_set_of_books_id;

BEGIN

   IF p_column_name IS NULL THEN

      l_set_of_books_id := TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                     p_org_id));

      OPEN get_coa_id(l_set_of_books_id);
      FETCH get_coa_id INTO l_coa_id;
      CLOSE get_coa_id;

      IF fnd_flex_apis.get_qualifier_segnum
                                (
                                 appl_id                         => 101
                                ,key_flex_code                   => 'GL#'
                                ,structure_number                => l_coa_id
                                ,flex_qual_name                  => 'FA_COST_CTR'
                                ,segment_number                  => l_segnum
                                )
      THEN

         IF fnd_flex_apis.get_segment_info
                                (
                                 x_application_id                => 101
                                ,x_id_flex_code                  => 'GL#'
                                ,x_id_flex_num                   => l_coa_id
                                ,x_seg_num                       => l_segnum
                                ,x_appcol_name                   => l_appcol_name
                                ,x_seg_name                      => l_seg_name
                                ,x_prompt                        => l_prompt
                                ,x_value_set_name                => l_value_set_name
                                )
         THEN
            l_column_name := l_appcol_name;
         END IF;
      END IF;
   ELSE
      l_column_name := p_column_name;
   END IF;

   IF l_column_name IS NOT NULL THEN

      l_employee_id := p_employee_id;

      /* create statement */
      sql_statement :=
      'SELECT ' || l_column_name || '
       FROM   gl_code_combinations,
              per_employees_current_x
       WHERE  default_code_combination_id = code_combination_id
       AND    employee_id = :l_employee_id';

      /* open cursor */
       l_cursor := dbms_sql.open_cursor;

      /* parse */
       dbms_sql.parse(l_cursor, sql_statement, dbms_sql.native);

      /* bind variables */
       dbms_sql.bind_variable(l_cursor,'l_employee_id',l_employee_id);

      /* define column */
       dbms_sql.define_column (l_cursor,1,p_cost_center,30);

      /* execute query and fetch */
       l_rows   := dbms_sql.execute(l_cursor);
       l_count  := dbms_sql.fetch_rows(l_cursor);

      /* get the value */
       dbms_sql.column_value(l_cursor,1,p_cost_center);

      /* if cursor open, close */
       IF dbms_sql.is_open (l_cursor) THEN
         dbms_sql.close_cursor (l_cursor);
       END IF;



   END IF;

   RETURN p_cost_center;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_cost_center;


-------------------------------------
-- valid_lookup_code
--------------------------------------
  FUNCTION valid_lookup_code (
    p_lookup_type  VARCHAR2,
    p_lookup_code  VARCHAR2 )
  RETURN BOOLEAN

  is

    l_dummy  VARCHAR2(1);

  begin
    SELECT 'x'
      INTO l_dummy
      FROM fnd_lookups
     WHERE lookup_type = p_lookup_type
       AND lookup_code = p_lookup_code ;

    RETURN true;

  exception
    WHEN others THEN
      RETURN false;

  end valid_lookup_code;


-------------------------------------
-- valid_country_code
--------------------------------------
  FUNCTION valid_country_code (
    p_country  VARCHAR2 )
  RETURN BOOLEAN

  is

    l_dummy  VARCHAR2(1);

  begin
    SELECT 'x'
      INTO l_dummy
      FROM fnd_territories_vl
     WHERE territory_code = p_country;

    RETURN true;

  exception
    WHEN others THEN
      RETURN false;

  end valid_country_code;


-------------------------------------
-- valid_uom_code
--------------------------------------
FUNCTION valid_uom_code ( p_uom_code  VARCHAR2 ) RETURN BOOLEAN
is
  l_dummy  VARCHAR2(1);

begin

  SELECT  'x'
  INTO    l_dummy
  FROM    fnd_lookups
  WHERE   lookup_type = 'PN_UNITS_OF_MEASURE'
  AND     lookup_code =  p_uom_code;


/*-----------------------------------------------------------------------------

---------------------------------------------------------
-- WHEN we finally integrate with INV, we can use this --
---------------------------------------------------------

  SELECT  'x'
  INTO    l_dummy
  FROM    mtl_units_of_measure
  WHERE   uom_class = 'Area'
  AND     uom_code  =  p_uom_code;

-----------------------------------------------------------------------------*/

  RETURN true;

exception
  WHEN others THEN
    RETURN false;

end;


-------------------------------------
-- valid_employee
--------------------------------------
FUNCTION valid_employee ( p_employee_id  NUMBER ) RETURN BOOLEAN
is
  l_dummy  VARCHAR2(1);

begin
  SELECT  'x'
  INTO    l_dummy
  FROM    per_employees_current_x
  WHERE   employee_id               =  p_employee_id;

  RETURN true;

exception
  WHEN others THEN
    RETURN false;

end;


-------------------------------------------------------------------------------
-- get_chart_of_accounts_id
--28-NOV-05 sdmahesh o Added parameter p_org_id
--                     Passed org_id to get_chart_of_accounts_id
-------------------------------------------------------------------------------
FUNCTION get_chart_of_accounts_id(p_org_id NUMBER)
RETURN NUMBER IS
  l_set_of_books_id  NUMBER;
  coa_id             NUMBER;

BEGIN
  l_set_of_books_id := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                 p_org_id));

  SELECT chart_of_accounts_id
  INTO   coa_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = l_set_of_books_id;

  RETURN coa_id;

END get_chart_of_accounts_id;


-------------------------------------------------------------------------------
-- get_segment_column_name
--28-NOV-05 sdmahesh o Added parameter p_org_id
--                     Passed org_id to get_chart_of_accounts_id
-------------------------------------------------------------------------------
FUNCTION get_segment_column_name(p_org_id NUMBER)
RETURN VARCHAR2 IS
  coa_id          NUMBER;
  segnum          VARCHAR2(25);
  appcol_name     VARCHAR2(25);
  seg_name        VARCHAR2(30);
  prompt          VARCHAR2(80);
  value_set_name  VARCHAR2(60);

BEGIN

  coa_id  :=  get_chart_of_accounts_id(p_org_id);

  IF fnd_flex_apis.get_qualIFier_segnum (
       101, 'GL#', coa_id, 'FA_COST_CTR', segnum ) THEN

    IF fnd_flex_apis.get_segment_info (
         101, 'GL#', coa_id, segnum,
         appcol_name, seg_name, prompt, value_set_name ) THEN

      RETURN appcol_name;
    end IF;

    RETURN 'UNKNOWN';
  end IF;

  RETURN 'UNKNOWN';

END get_segment_column_name;


------------------------------------------------------------------------------------
-- valid_cost_center
-- 01-Nov-2002 Daniel Thota o Changed the sql_statement to pick up column name
--                            from segment name so that the appropriate
--                            column used by the client in the CC definiton is picked up
--                            Fix for bug # 2632150
-- 28-OCT-2005 sdmahesh     o ATG mandated changes for SQL literals
-- 28-NOV-2005 sdmahesh     o Added parameter p_org_id
--                            Passed org_id to get_segment_column_name
------------------------------------------------------------------------------------
FUNCTION valid_cost_center ( p_cost_center  VARCHAR2, p_org_id NUMBER)
RETURN BOOLEAN is

  l_column_name    VARCHAR2(15);
  sql_statement    VARCHAR2(2000);
  l_dummy          VARCHAR2(1);
  l_cost_center    VARCHAR2(15);
  l_cursor         INTEGER;
  l_rows           INTEGER;
  l_count          INTEGER;

BEGIN

  --Bug#6366630: Added the IF condition to control Cost Center Validation using Profile Option --
  IF nvl(pn_mo_cache_utils.get_profile_value('PN_VALIDATE_ASSIGN_CC', p_org_id),'Y') = 'Y' THEN
  l_column_name := ltrim(rtrim(get_segment_column_name(p_org_id)));
  l_cost_center := p_cost_center;
  l_cursor := dbms_sql.open_cursor;


  sql_statement :=
       'select account_type
       from   gl_code_combinations where  '||l_column_name||' = :l_cost_center';

  dbms_sql.parse(l_cursor, sql_statement, dbms_sql.native);
  dbms_sql.bind_variable(l_cursor,'l_cost_center',l_cost_center);
  dbms_sql.define_column (l_cursor,1,l_dummy,1);
  l_rows   := dbms_sql.execute(l_cursor);
  l_count  := dbms_sql.fetch_rows(l_cursor);
  dbms_sql.column_value (l_cursor,1,l_dummy);
  IF dbms_sql.is_open (l_cursor) THEN
     dbms_sql.close_cursor (l_cursor);
  END IF;
  IF l_count <> 1 THEN
    RETURN false;
  END IF;

  RETURN true;

    --Bug#6366630: Added the IF condition to control Cost Center Validation using Profile Option --
  ELSE
          RETURN true;
  END IF;
    --Bug#6366630: Added the IF condition to control Cost Center Validation using Profile Option --

END valid_cost_center;


-------------------------------------------------------------------------------
-- valid_emp_cc_comb
-- THIS FUNCTION HAS BEEN OBSOLETED.PLEASE DO NOT USE THIS
-------------------------------------------------------------------------------
FUNCTION valid_emp_cc_comb (
    p_employee_id  NUMBER,    p_cost_center  VARCHAR2
) RETURN BOOLEAN is

  l_dummy          NUMBER;
  l_column_name    VARCHAR2(15);
  l_cost_center    VARCHAR2(5);

begin

  l_column_name := get_segment_column_name(NULL);

  l_cost_center := get_cost_center(p_employee_id, l_column_name,NULL);

  IF (p_cost_center = l_cost_center) THEN
    RETURN true;
  else
    RETURN false;
  end IF;

  -- This should NEVER be reached, something really wrong IF reached.
  RETURN false;

EXCEPTION
  WHEN others THEN
    RETURN false;

end valid_emp_cc_comb;


-------------------------------------------------------------------------------
-- GET_CC_CODE
--28-NOV-05  sdmahesh o Added parameter P_ORG_ID
--                    o Passed org_id to get_cost_center
--                    o Passed org_id to get_segment_column_name
-------------------------------------------------------------------------------
FUNCTION get_cc_code ( p_employee_id  NUMBER,
                       p_org_id NUMBER) RETURN VARCHAR2 is

  l_dummy          NUMBER;
  l_column_name    VARCHAR2(15);
  l_cost_center    VARCHAR2(5);

BEGIN

  l_column_name := get_segment_column_name(p_org_id);
  l_cost_center := get_cost_center(p_employee_id, l_column_name,p_org_id);

  RETURN l_cost_center;

EXCEPTION
  WHEN others THEN
    RETURN 'N/A';

END get_cc_code;


---------------------------------------------------
-- VALID_LOCATION --
-- 30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
-- 31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
-- 20-OCT-2003  ftanudja         o replaced GROUP BY w/ AND filter.319741.
---------------------------------------------------
FUNCTION VALID_LOCATION ( p_Location_Id  NUMBER ,
                          p_as_of_date IN DATE )
RETURN BOOLEAN Is

  l_Dummy  VARCHAR2(1);

  l_as_of_date DATE := pnp_util_func.get_as_of_date(p_as_of_date);

Begin

  SELECT  'X'
  INTO    l_Dummy
  FROM    pn_locations_all
  WHERE   Status = 'A'
  AND     Location_Id  =  p_Location_Id
  AND     l_as_of_date BETWEEN active_start_date AND active_end_date;

  RETURN True;

Exception

  WHEN No_Data_Found THEN
    RETURN False;

  WHEN Others THEN
    RAISE;

End VALID_LOCATION;


-------------------------------------
-- PN_GET_NEXT_LOCATION_ID
--------------------------------------
FUNCTION PN_GET_NEXT_LOCATION_ID RETURN NUMBER is

  l_seqnum  NUMBER;

begin

  SELECT  pn_locations_s.NEXTVAL
  INTO    l_seqnum
  FROM    DUAL;

  RETURN  l_seqnum;

exception
  WHEN others THEN
    RETURN  -999;

end PN_GET_NEXT_LOCATION_ID;


-------------------------------------
-- PN_GET_NEXT_SPACE_ALLOC_ID
--------------------------------------
FUNCTION PN_GET_NEXT_SPACE_ALLOC_ID RETURN NUMBER is

  l_seqnum  NUMBER;

begin

  SELECT  PN_SPACE_ASSIGN_EMP_S.NEXTVAL
  INTO    l_seqnum
  FROM    dual;

  RETURN  l_seqnum;

exception
  WHEN others THEN
    RETURN  -999;

end PN_GET_NEXT_SPACE_ALLOC_ID;


-------------------------------------
-- SET_VIEW_CONTEXT
--------------------------------------
PROCEDURE SET_VIEW_CONTEXT(p_ap_ar  VARCHAR2) is

  INVALID_PARAMETER  EXCEPTION;

begin

  IF (p_ap_ar <> 'AP'  AND p_ap_ar <> 'AR') THEN
    raise INVALID_PARAMETER;
  else
    g_view_context := p_ap_ar;
  end IF;

exception
  WHEN others THEN
    RAISE;

end SET_VIEW_CONTEXT;


-------------------------------------
-- GET_VIEW_CONTEXT
--------------------------------------
FUNCTION GET_VIEW_CONTEXT RETURN VARCHAR2 is

BEGIN
  RETURN  g_view_context;

EXCEPTION
  WHEN OTHERS THEN
    RETURN  NULL;

END GET_VIEW_CONTEXT;

-------------------------------------------------------------------
-- For getting the daily conversion rate FROM GL's new API in 11.5
-- The form uses this, to display the amount in foreign currency,
-- WHEN user chooses a currency code dIFferent FROM the functional
-- currency.
-------------------------------------------------------------------
-- To RETURN EXPORT_CURRENCY_AMOUNT column
-- Get Export Currency Amount FROM GL's API
-------------------------------------------------------------------
FUNCTION Export_Curr_Amount (
  currency_code                       VARCHAR2,
  export_currency_code                VARCHAR2,
  export_date                         DATE,
  conversion_type                     VARCHAR2,
  actual_amount                       NUMBER,
  p_called_FROM                       VARCHAR2
)

RETURN NUMBER

is

  export_amount           NUMBER;

begin

  IF export_currency_code = currency_code THEN
    export_amount := actual_amount;

  ELSE
    BEGIN
       export_amount := gl_currency_api.convert_amount (
                       X_FROM_CURRENCY   => currency_code,
                       X_TO_CURRENCY     => export_currency_code,
                       X_CONVERSION_DATE => export_date,
                       X_CONVERSION_TYPE => conversion_type,
                       X_AMOUNT          => actual_amount
                     );
    EXCEPTION
       WHEN gl_currency_api.no_rate THEN
          IF p_called_FROM = 'PNTAUPMT' THEN
             NULL;
          ELSE
             fnd_message.set_name('PN','PN_EXP_NO_RATE');
             app_exception.raise_exception;
          END IF;
       WHEN gl_currency_api.invalid_currency THEN
          IF p_called_FROM = 'PNTAUPMT' THEN
             NULL;
          ELSE
             fnd_message.set_name('PN','PN_EXP_INVALID_CURRENCY');
             app_exception.raise_exception;
          END IF;
       WHEN OTHERS THEN
          IF p_called_FROM = 'PNTAUPMT' THEN
             NULL;
          ELSE
             app_exception.raise_exception;
          END IF;
    END;

  END IF;

  RETURN export_amount;

  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;

END Export_Curr_Amount;


-------------------------------------------------------------------------------
-- FUNCTION Get_Start_Date
--28-NOV-05  sdmahesh o Added parameter P_ORG_ID
--                    o Passed org_id to get_profile_value
-------------------------------------------------------------------------------
FUNCTION Get_Start_Date(p_Period_Name  VARCHAR2,p_org_id NUMBER)
RETURN DATE is

  l_Set_Of_Books_Id  NUMBER;
  l_start_date       DATE;

BEGIN

  l_Set_Of_Books_Id := pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                       p_org_id);

  IF (p_period_name = NULL) THEN
    l_start_date := SYSDATE;

  else
    SELECT  glp.start_date
    INTO    l_start_date
    FROM    gl_sets_of_books gsob,
            gl_periods glp
    WHERE   gsob.period_set_name = glp.period_set_name
    AND     gsob.set_of_books_id = l_set_of_books_id
    AND     glp.period_name      = p_period_name;

  end IF;

  RETURN TRUNC(l_start_date);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN TRUNC(SYSDATE);

END Get_Start_Date;


-------------------------------------------------------------------------------
--  NAME         : Get_Occupancy_Status
--  DESCRIPTION  : retrieves the Occupancy Status
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_location_id,
--                      p_As_Of_Date
--  RETURNS      : Occupancy Status
--  HISTORY      :
-- 17-AUG-00 Daniel Thota  o Added new parameter p_as_of_date to the
--                           function. Changed the WHERE clause to
--                           include p_as_of_date - Bug Fix for #1379527
-- 08-SEP-00 Daniel Thota  o Re-introduced comparison of p_as_of_date
--                           with end date - Bug Fix for #1379527
-- 18-SEP-00 Lakshmikanth  o Using the variable l_date
--                           Date:=  TO_DATE('31-DEC-2199' , ('DD/MM/YYYY'))
--                           in the end date comparision with the as_of_date
-- 19-SEP-00 Lakshmikanth  o Replacing the TO_DATE('31-DEC-2199',('DD/MM/YYYY'))
--                           with TO_DATE('31/12/2199' , ('DD/MM/YYYY'))
-- 15-JUN-05 piagrawa      o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                           PN_SPACE_ASSIGN_CUST with _ALL table.
-------------------------------------------------------------------------------
FUNCTION Get_Occupancy_Status(p_location_id NUMBER,
                              p_As_Of_Date  DATE)
RETURN   NUMBER
IS

  l_retnum      NUMBER := 0;
  l_retnum_emp  NUMBER := 0;
  l_retnum_cust NUMBER := 0;
  l_date        DATE   := TO_DATE('31/12/2199' , 'DD/MM/YYYY');
  l_as_of_date  DATE   := pnp_util_func.get_as_of_date(p_as_of_date);  --ASHISH

BEGIN

  SELECT 1
  INTO   l_retnum_emp
  FROM   pn_space_assign_emp_all
  WHERE  location_id = p_location_id
  AND    emp_assign_start_date                  <= l_as_of_date
  AND    NVL(emp_assign_end_date, l_date) >= l_as_of_date
  AND    rownum = 1 ;

  SELECT 1
  INTO   l_retnum_cust
  FROM   pn_space_assign_cust_all
  WHERE  location_id = p_location_id
  AND    cust_assign_start_date                  <= l_as_of_date
  AND    NVL(cust_assign_end_date, l_date) >= l_as_of_date
  AND    rownum = 1 ;

  l_retnum := l_retnum_emp + l_retnum_cust;

  RETURN l_retnum;

EXCEPTION

  WHEN others THEN
    RETURN l_retnum;

END Get_Occupancy_Status;

-------------------------------------------------------------------------------
-- FUNCTION  Get_Location_Code
-- 30-OCT-02  Satish Tripathi  o Access _all table for performance issues.
-- 31-OCT-01  graghuna         o added p_as_of_date for Location
--                               Date-Effectivity.
-- 20-OCT-03  ftanudja         o replaced GROUP BY w/ AND filter.3197410.
-- 18-FEB-04  abanerje         o Handled NO_DATA_FOUND to return 0.
--                               All the select statements have been
--                               converted to cursors. The l_location_type
--                               is checked for null to return 0.
--                               Bug #3384965.
--   24-MAR-2004  ftanudja     o added p_ignore_date.3496483.
-------------------------------------------------------------------------------
FUNCTION  Get_Location_Code (
          p_location_id  NUMBER,
          p_as_of_date   DATE,
          p_ignore_date  BOOLEAN) RETURN  VARCHAR2
IS
 l_location_code  pn_locations_all.location_code%TYPE;
 l_as_of_date     DATE := pnp_util_func.get_as_of_date(p_as_of_date);

 CURSOR fetch_loc_code IS
  SELECT location_code
  FROM   pn_locations_all
  WHERE  location_id =  p_location_id
  AND    p_as_of_date BETWEEN active_start_date AND active_end_date;

 CURSOR fetch_loc_code_ignore_date IS
  SELECT location_code
  FROM   pn_locations_all
  WHERE  location_id =  p_location_id
    AND  ROWNUM < 2;

BEGIN
   IF p_ignore_date THEN
      FOR code_rec IN fetch_loc_code_ignore_date LOOP
        l_location_code := code_rec.location_code;
      END LOOP;
   ELSE
      FOR code_rec IN fetch_loc_code LOOP
        l_location_code := code_rec.location_code;
      END LOOP;
   END IF;

   RETURN l_location_code;

EXCEPTION
  WHEN Others THEN
    RAISE;
END;

-------------------------------------------------------
-- FUNCTION  Get_Location_Type_Lookup_Code
--   30-OCT-2002  Satish Tripathi  o Removed DISTINCT, access _all table for performance issues.
--                                   Removed active_start_date, active_end_date clause.
--   20-OCT-2003  ftanudja         o replaced GROUP BY w/ AND filter.3197410.
--   24-MAR-2004  ftanudja         o added p_ignore_date.3496483.
-------------------------------------------------------
FUNCTION  Get_Location_Type_Lookup_Code (p_location_id  NUMBER ,
                                         p_as_of_date   DATE,
                                         p_ignore_date  BOOLEAN) RETURN VARCHAR2
IS
 l_location_type_lookup_code  pn_locations_all.location_type_lookup_code%TYPE;
 l_as_of_date                 DATE := pnp_util_func.get_as_of_date(p_as_of_date);

 CURSOR fetch_code IS
  SELECT location_type_lookup_code
  FROM   pn_locations_all
  WHERE  location_id =  p_location_id
    AND  l_as_of_date BETWEEN active_start_date AND active_end_date;

 CURSOR fetch_code_ignore_date IS
  SELECT location_type_lookup_code
  FROM   pn_locations_all
  WHERE  location_id =  p_location_id
    AND  ROWNUM < 2;

BEGIN

  IF p_ignore_date THEN
     FOR code_rec IN fetch_code_ignore_date LOOP
       l_location_type_lookup_code := code_rec.location_type_lookup_code;
     END LOOP;
  ELSE
     FOR code_rec IN fetch_code LOOP
       l_location_type_lookup_code := code_rec.location_type_lookup_code;
     END LOOP;
  END IF;

  RETURN l_Location_Type_Lookup_Code ;

EXCEPTION
  WHEN Others THEN
    RAISE;
END;

/*===========================================================================+
 | FUNCTION
 |    get_higH_schedule_date
 |
 | DESCRIPTION
 |    To GET the highest approved scheduled date FROM pn_payment_schedules_v
 |    for the current lease. This date is used to compare with the
 |    lease_termination_date so as not to allow early termination
 |    in the event of an approved schedule payment existing.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_leaseId
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : The highest approved scheduled date.
 |
 | NOTES      : Currently being used in view "PN_PAYMENT_SCHEDULES_V"
 |
 | MODIFICATION HISTORY
 |
 |     02-FEB-2000  Daniel Thota   Created
 |     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 +===========================================================================*/

FUNCTION GET_HIGH_SCHEDULE_DATE ( p_leaseId  IN NUMBER )
RETURN DATE IS

l_date       DATE ;

BEGIN
   BEGIN
      SELECT MAX(schedule_date)
      INTO   l_date
      FROM   pn_payment_schedules_all
      WHERE  payment_status_lookup_code = 'APPROVED'
      AND    lease_id = p_leaseId;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END;
   RETURN l_date;
END GET_HIGH_SCHEDULE_DATE;

/*=============================================================================+
 | FUNCTION
 |   create_virtual_schedules
 |
 | DESCRIPTION
 |   Given term dates and schedule dates, schedule day, frequency, returns a
 |   virtual schedule table. If a limit date is provided, the creation of
 |   virtual schedule stops on passing the limit date.
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |    p_start_date  term start date
 |    p_end_date    term end date
 |    p_sch_day     schedule day on the term
 |    p_term_freq   term frequency
 |    p_limit_date  limit date for creating virtual schedule
 |
 | RETURNS    : virtual_sched_tbl_type
 |
 | NOTES      : Used by valid_early_term_date
 |
 | MODIFICATION HISTORY
 |  23-May-2004  Kiran       o Created - bug # 3562487
 +===========================================================================*/

FUNCTION create_virtual_schedules
           ( p_start_date DATE
            ,p_end_date   DATE
            ,p_sch_day    NUMBER
            ,p_term_freq  VARCHAR2
            ,p_limit_date DATE)
RETURN PNP_UTIL_FUNC.virtual_sched_tbl_type IS


CURSOR get_freq_num(p_freq_char IN VARCHAR2) IS
  SELECT TO_NUMBER(DECODE(  p_freq_char
                           , 'OT', 0
                           , 'MON', 1
                           , 'QTR', 3
                           , 'SA', 6
                           , 'YR', 12
                           , -1)) AS freq_num
  FROM DUAL;

l_sched_tbl  PNP_UTIL_FUNC.virtual_sched_tbl_type;

l_frequency  NUMBER;

l_current_st_dt  DATE;
l_current_end_dt DATE;
l_limit_dt       DATE;

l_rec_count  NUMBER;

INVALID_PARAM EXCEPTION;

BEGIN

IF p_start_date IS NULL OR
   p_end_date   IS NULL OR
   p_sch_day    IS NULL OR
   p_sch_day    < 1 OR
   p_sch_day    > 28 OR
   p_term_freq  IS NULL THEN

  RAISE INVALID_PARAM;

END IF;

/* get frequency */
FOR freq_rec IN get_freq_num(p_term_freq) LOOP
  l_frequency := freq_rec.freq_num;
END LOOP;

IF l_frequency = -1 THEN
  RAISE INVALID_PARAM;
END IF;

IF l_frequency = 0 THEN

  l_sched_tbl(1).start_date    := p_start_date;
  l_sched_tbl(1).end_date      := p_end_date;
  l_sched_tbl(1).schedule_date := LAST_DAY(ADD_MONTHS(p_start_date, -1)) + p_sch_day;

ELSE

  l_current_st_dt  := p_start_date;
  l_current_end_dt := p_end_date;
  l_limit_dt       := LEAST(NVL(p_limit_date, p_end_date), p_end_date);
  l_rec_count      := 1;

  WHILE l_current_st_dt < l_limit_dt LOOP

    IF l_frequency = 1 THEN

      l_current_end_dt := LEAST(LAST_DAY(l_current_st_dt), p_end_date);

    ELSE

      l_current_end_dt := LEAST(ADD_MONTHS(l_current_st_dt, l_frequency) - 1
                                , p_end_date);

    END IF;

    l_sched_tbl(l_rec_count).start_date    := l_current_st_dt;
    l_sched_tbl(l_rec_count).end_date      := l_current_end_dt;
    l_sched_tbl(l_rec_count).schedule_date := LAST_DAY(ADD_MONTHS(l_current_st_dt, -1)) + p_sch_day;

    l_current_st_dt := l_current_end_dt + 1;
    l_rec_count     := l_rec_count + 1;

  END LOOP;

END IF;

RETURN l_sched_tbl;

EXCEPTION

  WHEN OTHERS THEN RAISE;

END create_virtual_schedules;

/*=============================================================================+
 | FUNCTION
 |   valid_early_term_date
 |
 | DESCRIPTION
 |   Implements the rules
 |    IF exists one approved schedule for lease
 |       and exists one normalised term with start date > early termination date
 |    THEN
 |       ERROR - STOP USER
 |
 |    IF early termination date < schedule date of (last approved schedule + 1)
 |    for normalized
 |    THEN
 |       ERROR - STOP USER
 |
 |    IF early termination date < last date of the last approved period
 |    for not normalized
 |    THEN
 |       ERROR - STOP USER
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |    p_lease_id          lease ID
 |    p_term_id           payment/billign term ID. null if called from lease
 |    p_normalized        normalized flag. null if called from lease
 |    p_frequency         term frequency. null if called from lease
 |    p_termination_date  new termination date. lease termination date when
 |                        called from lease. term termination date when called
 |                        from term
 |    p_called_from       'LEASE' or 'TERM'
 |
 |
 | RETURNS    : BOOLEAN
 |
 | NOTES      : Currently being used PNTLEASE to validate the
 |              termination date at the lease and the term level.
 |
 | MODIFICATION HISTORY
 |  23-May-04  Kiran       o Created - bug # 3562487
 |  30-Mar-05  Kiran       o Changed the rules for bug # 4229248. New rules are
 |                           reflected in the Description section above.
 +===========================================================================*/

FUNCTION valid_early_term_date(  p_lease_id         NUMBER
                                 ,p_term_id          NUMBER
                                 ,p_normalized       VARCHAR2
                                 ,p_frequency        VARCHAR2
                                 ,p_termination_date DATE
                                 ,p_called_from      VARCHAR2)
RETURN  BOOLEAN IS

/* this cursor is to figure out if
   1. If there exists a normailzed term starting after the new termination date
   AND
   2. Atleast one schedule for the lease is approved
*/
CURSOR exists_norm_term( p_lease_ID IN NUMBER
                        ,p_termination_date IN DATE) IS
  SELECT 1
    FROM dual
   WHERE EXISTS
         (SELECT 1
            FROM pn_payment_schedules_all s,
                 pn_payment_items_all i
           WHERE i.payment_term_id IN
                 (SELECT payment_term_id
                    FROM pn_payment_terms_all
                   WHERE lease_id = p_lease_ID
                     AND start_date > p_termination_date
                     AND normalize = 'Y')
              AND i.payment_schedule_id = s.payment_schedule_id
              AND s.payment_status_lookup_code = 'APPROVED'
              AND s.lease_id = p_lease_ID);

/* cursor for normalized used when called from lease */

CURSOR max_appr_sched_norm(p_lease_ID IN NUMBER) IS
  SELECT MAX(s.schedule_date) AS schedule_date
    FROM pn_payment_schedules_all s,
         pn_payment_items_all i
   WHERE i.payment_term_id IN
         (SELECT t.payment_term_id
            FROM pn_payment_terms_all t
           WHERE t.lease_id = p_lease_ID
             AND t.normalize = 'Y')
     AND i.payment_schedule_id = s.payment_schedule_id
     AND s.payment_status_lookup_code = 'APPROVED'
     AND s.lease_id = p_lease_ID;


/* cursorS for NOT normalized used when called from lease */

/* ONE TIME */
CURSOR max_appr_sched_ot(p_lease_ID IN NUMBER) IS
  SELECT MAX(s.schedule_date) AS schedule_date
    FROM pn_payment_schedules_all s,
         pn_payment_items_all i
   WHERE i.payment_term_id IN
         (SELECT t.payment_term_id
            FROM pn_payment_terms_all t
           WHERE t.lease_id = p_lease_ID
             AND t.frequency_code = 'OT'
             AND NVL(t.normalize,'N')='N')
     AND i.payment_schedule_id = s.payment_schedule_id
     AND s.payment_status_lookup_code = 'APPROVED'
     AND s.lease_id = p_lease_ID;

/* MONTHLY */
CURSOR max_appr_sched_mon(p_lease_ID IN NUMBER) IS
  SELECT MAX(s.schedule_date) AS schedule_date
    FROM pn_payment_schedules_all s,
         pn_payment_items_all i
   WHERE i.payment_term_id IN
         (SELECT t.payment_term_id
            FROM pn_payment_terms_all t
           WHERE t.lease_id = p_lease_ID
             AND t.frequency_code = 'MON'
             AND NVL(t.normalize,'N')='N')
     AND i.payment_schedule_id = s.payment_schedule_id
     AND s.payment_status_lookup_code = 'APPROVED'
     AND s.lease_id = p_lease_ID;

/* QUARTERLY, SEMI_ANNUAL, ANNUAL */
CURSOR max_appr_sched_other(p_lease_ID IN NUMBER) IS
  SELECT MAX(s.schedule_date) AS schedule_date
    FROM pn_payment_schedules_all s,
         pn_payment_items_all i
   WHERE i.payment_term_id IN
         (SELECT t.payment_term_id
            FROM pn_payment_terms_all t
           WHERE t.lease_id = p_lease_ID
             AND t.frequency_code IN ('QTR', 'SA', 'YR')
             AND NVL(t.normalize,'N')='N')
     AND i.payment_schedule_id = s.payment_schedule_id
     AND s.payment_status_lookup_code = 'APPROVED'
     AND s.lease_id = p_lease_ID;

/* get terms for max approved schedule date */
CURSOR terms_for_max_appr_sched( p_lease_ID     IN NUMBER
                                ,p_sched_date   IN DATE) IS
  SELECT payment_term_ID
        ,start_date
        ,end_date
        ,schedule_day
        ,frequency_code
    FROM pn_payment_terms_all
   WHERE lease_ID = p_lease_ID
     AND payment_term_ID IN
         (SELECT DISTINCT i.payment_term_ID
          FROM   pn_payment_items_all i
                ,pn_payment_schedules_all s
          WHERE  s.schedule_date = p_sched_date
          AND    s.lease_ID = p_lease_ID
          AND    s.payment_status_lookup_code = 'APPROVED'
          AND    i.payment_schedule_ID = s.payment_schedule_ID);

/* cursors used when called from term */
/* get the max schedule date for the term */
CURSOR max_appr_sched_term( p_lease_ID IN NUMBER
                           ,p_term_ID  IN NUMBER) IS
  SELECT MAX(s.schedule_date) AS schedule_date
    FROM pn_payment_schedules_all s,
         pn_payment_items_all i
   WHERE i.payment_term_id = p_term_ID
     AND i.payment_schedule_id = s.payment_schedule_id
     AND s.payment_status_lookup_code = 'APPROVED'
     AND s.lease_id = p_lease_ID;

CURSOR term_details(p_term_ID IN NUMBER) IS
  SELECT payment_term_ID
        ,start_date
        ,end_date
        ,schedule_day
        ,frequency_code
    FROM pn_payment_terms_all
   WHERE payment_term_ID = p_term_ID;

l_frequency  NUMBER;
l_sched_tbl  PNP_UTIL_FUNC.virtual_sched_tbl_type;

/* user defined exceptions */
INVALID_PARAM            EXCEPTION;
INVALID_TERMINATION_DATE EXCEPTION;

BEGIN

  PNP_DEBUG_PKG.log('+++ valid_early_term_date +++');
  PNP_DEBUG_PKG.log('p_lease_id         :'||p_lease_id);
  PNP_DEBUG_PKG.log('p_term_id          :'||p_term_id);
  PNP_DEBUG_PKG.log('p_normalized       :'||p_normalized);
  PNP_DEBUG_PKG.log('p_frequency        :'||p_frequency);
  PNP_DEBUG_PKG.log('p_termination_date :'||p_termination_date);
  PNP_DEBUG_PKG.log('p_called_from      :'||p_called_from);

  /* lease ID must always be passed */
  IF p_lease_id IS NULL  OR
     p_termination_date IS NULL THEN
    RAISE INVALID_PARAM;
  END IF;

  IF UPPER(p_called_from) = 'LEASE' THEN

    /* check if there exists a norm term starting after the new end date
       and if atleast one schedule for the lease has been APPROVED */
    FOR i IN exists_norm_term( p_lease_ID
                              ,p_termination_date) LOOP
      RAISE INVALID_TERMINATION_DATE;
    END LOOP;

    /* check for normalized term approved schedues */
    FOR sd_norm IN max_appr_sched_norm(p_lease_ID) LOOP
      IF p_termination_date < (LAST_DAY(sd_norm.schedule_date)+1) THEN
        RAISE INVALID_TERMINATION_DATE;
      END IF;
    END LOOP;

    /* check for not normalized terms */

    /* one time */
    FOR sd_ot IN max_appr_sched_ot(p_lease_ID) LOOP
      IF p_termination_date < sd_ot.schedule_date THEN
        RAISE INVALID_TERMINATION_DATE;
      END IF;
    END LOOP;

    /* monthly */
    FOR sd_mon IN max_appr_sched_mon(p_lease_ID) LOOP
      IF p_termination_date < LAST_DAY(sd_mon.schedule_date) THEN
        RAISE INVALID_TERMINATION_DATE;
      END IF;
    END LOOP;

    /* quarterly, semi-annual, annual */
    FOR sd_other IN max_appr_sched_other(p_lease_ID) LOOP

      FOR term_rec IN terms_for_max_appr_sched( p_lease_ID
                                               ,sd_other.schedule_date)
      LOOP

        l_sched_tbl := PNP_UTIL_FUNC.create_virtual_schedules
                          ( p_start_date => term_rec.start_date
                           ,p_end_date   => term_rec.end_date
                           ,p_sch_day    => term_rec.schedule_day
                           ,p_term_freq  => term_rec.frequency_code
                           ,p_limit_date => p_termination_date);

        IF l_sched_tbl.COUNT < 1 THEN
          RAISE INVALID_TERMINATION_DATE;
        END IF;

        IF p_termination_date < l_sched_tbl(l_sched_tbl.COUNT).end_date THEN
          RAISE INVALID_TERMINATION_DATE;
        END IF;

      END LOOP;

    END LOOP;

  ELSIF UPPER(p_called_from) = 'TERM' THEN

    /* validate if the mandatory params have been passed */
    IF p_term_id IS NULL OR
       p_normalized IS NULL OR
       p_frequency IS NULL THEN
      RAISE INVALID_PARAM;
    END IF;

    FOR term_rec IN max_appr_sched_term(p_lease_ID, p_term_ID) LOOP

      IF NVL(p_normalized, 'N') = 'Y' THEN

        IF p_termination_date < LAST_DAY(term_rec.schedule_date) + 1 THEN
          RAISE INVALID_TERMINATION_DATE;
        END IF;

      ELSE

        IF p_frequency = 'MON' THEN

          IF p_termination_date < LAST_DAY(term_rec.schedule_date) THEN
            RAISE INVALID_TERMINATION_DATE;
          END IF;

        ELSE

          IF UPPER(p_frequency) = 'QTR' THEN
            l_frequency := 3;

          ELSIF UPPER(p_frequency) = 'SA' THEN
            l_frequency := 6;

          ELSIF UPPER(p_frequency) = 'YR' THEN
            l_frequency := 12;

          END IF;

          FOR term_rec IN term_details(p_term_ID) LOOP

            l_sched_tbl := PNP_UTIL_FUNC.create_virtual_schedules
                          ( p_start_date => term_rec.start_date
                           ,p_end_date   => term_rec.end_date
                           ,p_sch_day    => term_rec.schedule_day
                           ,p_term_freq  => term_rec.frequency_code
                           ,p_limit_date => p_termination_date);

            IF l_sched_tbl.COUNT < 1 THEN
              RAISE INVALID_TERMINATION_DATE;
            END IF;

            IF p_termination_date < l_sched_tbl(l_sched_tbl.COUNT).end_date THEN
              RAISE INVALID_TERMINATION_DATE;
            END IF;

          END LOOP;

        END IF;

      END IF;

    END LOOP;

  ELSE

    RAISE INVALID_PARAM;

  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN INVALID_PARAM THEN
    PNP_DEBUG_PKG.log('Invalid PARAM passed.');
    RETURN FALSE;

  WHEN INVALID_TERMINATION_DATE THEN
    fnd_message.set_name ('PN', 'PN_NO_EARLY_TERMINATE_NORM');
    RETURN FALSE;

  WHEN OTHERS THEN
    PNP_DEBUG_PKG.log('Something went wrong here!! - '||SQLCODE||': '||SQLERRM);
    RETURN FALSE;

END valid_early_term_date;

/*============================================================================+
--  NAME         : VALIDATE_LEASE_TERMINATE_DATE
--  DESCRIPTION  : To validate the user provided lease termination date against
--                 the system computed minimum lease termination date
--  NOTES        :
--  SCOPE        : PUBLIC
--  ARGUMENTS
--    p_lease_id
--    p_termination_date
--
--  RETURNS    : BOOLEAN
--
--  NOTES      :
--
--  MODIFICATION HISTORY
--  11-SEP-07 rthumma         Bug # 6366630. Enhancement for new profile
--                             option for lease early termination
+=============================================================================*/
FUNCTION validate_lease_terminate_date (p_lease_id IN NUMBER,
                                        p_termination_date IN DATE)
RETURN BOOLEAN IS

l_min_lease_terminate_date DATE;
INVALID_TERMINATION_DATE EXCEPTION;
BEGIN
   l_min_lease_terminate_date := min_lease_terminate_date(p_lease_id);
   IF (l_min_lease_terminate_date > p_termination_date) THEN
      RAISE INVALID_TERMINATION_DATE;
   ELSE
      RETURN TRUE;
   END IF;
EXCEPTION
   WHEN INVALID_TERMINATION_DATE THEN
      fnd_message.set_name ('PN', 'PN_INVALID_TERMINATE_DATE');
      RETURN FALSE;
END validate_lease_terminate_date;

/*============================================================================+
--  NAME         : NORM_TRM_EXSTS
--  DESCRIPTION  : Find if a lease contains normalized terms
--  NOTES        :
--  SCOPE        : PUBLIC
--  ARGUMENTS
--    p_lease_id          lease ID
--  RETURNS    : BOOLEAN
--
--  NOTES      :
--
--  MODIFICATION HISTORY
--  11-SPE-07 rthumma         Bug # 6366630. Enhancement for new profile
--                             option for lease early termination
+=============================================================================*/
FUNCTION norm_trm_exsts (p_lease_id IN NUMBER) RETURN BOOLEAN IS

l_norm_trm_exsts           BOOLEAN := FALSE;

CURSOR csr_norm_term_exists(p_lease_id IN NUMBER) IS
   SELECT 1
   FROM pn_payment_terms_all
   WHERE NVL(normalize,'N') = 'Y'
   AND lease_id = p_lease_id;

BEGIN
<<label>>
   FOR rec IN csr_norm_term_exists(p_lease_id) LOOP
      l_norm_trm_exsts := TRUE;
      EXIT label;
   END LOOP;
   RETURN l_norm_trm_exsts;
END norm_trm_exsts;

/*============================================================================+
--  NAME         : MIN_LEASE_TERMINATE_DATE
--  DESCRIPTION  : To get the minimum lease termination date.This date is used
--                 to compare with the new lease termination for an
--                 ammendement so as not to allow a date earlier than this
--                 lease date
--  NOTES        :
--  SCOPE        : PUBLIC
--  ARGUMENTS
--    p_lease_id          lease ID
--  RETURNS    : DATE
--
--  NOTES      : Currently being used PNTLEASE to validate the
--               termination date at the lease
--
--  MODIFICATION HISTORY
--  11-SEP-07 rthumma         Bug # 6366630. Enhancement for new profile
--                             option for lease early termination
+=============================================================================*/
FUNCTION MIN_LEASE_TERMINATE_DATE (p_lease_id IN NUMBER) RETURN DATE IS

l_min_lease_terminate_date DATE;
l_norm_trm_exsts           BOOLEAN := FALSE;
l_item_end_dt_tbl          pnp_util_func.item_end_dt_tbl_type;
i                          NUMBER;
maxDt                      DATE := TO_DATE('01/01/0001', 'MM/DD/YYYY');

CURSOR csr_lst_appr_schd(p_lease_ID IN NUMBER) IS
   SELECT LAST_DAY(MAX(schedule_date)) AS last_appr_schd_month_end_dt
   FROM pn_payment_schedules_all
   WHERE payment_status_lookup_code = 'APPROVED'
   AND lease_id = p_lease_id;


BEGIN
   l_norm_trm_exsts := norm_trm_exsts(p_lease_id);
   IF NOT l_norm_trm_exsts THEN
      FOR rec IN csr_lst_appr_schd(p_lease_id) LOOP
         l_min_lease_terminate_date := rec.last_appr_schd_month_end_dt;
      END LOOP;
   ELSIF l_norm_trm_exsts THEN
      l_item_end_dt_tbl := fetch_item_end_dates( p_lease_id);
      FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
         IF maxDt < l_item_end_dt_tbl(i).item_end_dt THEN
            maxDt := l_item_end_dt_tbl(i).item_end_dt;
         END IF;
      END LOOP;
      l_min_lease_terminate_date := maxDt;
   END IF;
   RETURN l_min_lease_terminate_date;
END MIN_LEASE_TERMINATE_DATE;

/*============================================================================+
--  NAME         : ITEM_END_DATE
--  DESCRIPTION  : To get the item end date.This date is used
--                 to determine the term early termination date of a term while
--                 contracting a lease
--  NOTES        :
--  SCOPE        : PUBLIC
--  ARGUMENTS
--    p_term_id          payment_term_id
--    p_freq_code        frequency_code
--
--  RETURNS    : DATE
--
--  NOTES      : Currently being used PNTLEASE to validate the
--               termination date of the lease and find the termination date
--               of the term
--
--  MODIFICATION HISTORY
--  11-SEP-07 rthumma         Bug # 6366630. Enhancement for new profile
--                             option for lease early termination
+=============================================================================*/
FUNCTION item_end_date (p_term_id IN NUMBER,p_freq_code IN VARCHAR) RETURN DATE IS

l_item_end_dt DATE;

CURSOR csr_ot_item_end_date(p_term_id IN NUMBER) IS
   SELECT MAX(schedule_date) AS item_end_date
   FROM pn_payment_items_all item,
        pn_payment_terms_all term,
        pn_payment_schedules_all schd
   WHERE term.payment_term_id = p_term_id
   AND   item.payment_term_id = term.payment_term_id
   AND   item.payment_schedule_id = schd.payment_schedule_id
   AND   item.payment_item_type_lookup_code = 'CASH'
   AND   item.actual_amount <>0
   AND   schd.payment_status_lookup_code = 'APPROVED';

CURSOR csr_mon_item_end_date(p_term_id IN NUMBER) IS
   SELECT LAST_DAY(MAX(schedule_date)) AS item_end_date
   FROM pn_payment_items_all item,
        pn_payment_terms_all term,
        pn_payment_schedules_all schd
   WHERE term.payment_term_id = p_term_id
   AND   item.payment_term_id = term.payment_term_id
   AND   item.payment_schedule_id = schd.payment_schedule_id
   AND   item.payment_item_type_lookup_code = 'CASH'
   AND   item.actual_amount <>0
   AND   schd.payment_status_lookup_code = 'APPROVED';

CURSOR csr_qtr_item_end_date(p_term_id IN NUMBER) IS
   SELECT ADD_MONTHS(MAX(schedule_date),3) - 1 AS item_end_date
   FROM pn_payment_items_all item,
        pn_payment_terms_all term,
        pn_payment_schedules_all schd
   WHERE term.payment_term_id = p_term_id
   AND   item.payment_term_id = term.payment_term_id
   AND   item.payment_schedule_id = schd.payment_schedule_id
   AND   item.payment_item_type_lookup_code = 'CASH'
   AND   item.actual_amount <>0
   AND   schd.payment_status_lookup_code = 'APPROVED';

CURSOR csr_sa_item_end_date(p_term_id IN NUMBER) IS
   SELECT ADD_MONTHS(MAX(schedule_date),6) - 1 AS item_end_date
   FROM pn_payment_items_all item,
        pn_payment_terms_all term,
        pn_payment_schedules_all schd
   WHERE term.payment_term_id = p_term_id
   AND   item.payment_term_id = term.payment_term_id
   AND   item.payment_schedule_id = schd.payment_schedule_id
   AND   item.payment_item_type_lookup_code = 'CASH'
   AND   item.actual_amount <>0
   AND   schd.payment_status_lookup_code = 'APPROVED';

CURSOR csr_yr_item_end_date(p_term_id IN NUMBER) IS
   SELECT ADD_MONTHS(MAX(schedule_date),12) - 1 AS item_end_date
   FROM pn_payment_items_all item,
        pn_payment_terms_all term,
        pn_payment_schedules_all schd
   WHERE term.payment_term_id = p_term_id
   AND   item.payment_term_id = term.payment_term_id
   AND   item.payment_schedule_id = schd.payment_schedule_id
   AND   item.payment_item_type_lookup_code = 'CASH'
   AND   item.actual_amount <>0
   AND   schd.payment_status_lookup_code = 'APPROVED';

BEGIN
   IF p_freq_code = 'OT' THEN
      FOR rec IN csr_ot_item_end_date(p_term_id) LOOP
         l_item_end_dt := rec.item_end_date;
      END LOOP;
   ELSIF p_freq_code = 'MON' THEN
      FOR rec IN csr_mon_item_end_date(p_term_id) LOOP
         l_item_end_dt := rec.item_end_date;
      END LOOP;
   ELSIF p_freq_code = 'QTR' THEN
      FOR rec IN csr_qtr_item_end_date(p_term_id) LOOP
         l_item_end_dt := rec.item_end_date;
      END LOOP;
   ELSIF p_freq_code = 'SA' THEN
      FOR rec IN csr_sa_item_end_date(p_term_id) LOOP
         l_item_end_dt := rec.item_end_date;
      END LOOP;
   ELSIF p_freq_code = 'YR' THEN
      FOR rec IN csr_yr_item_end_date(p_term_id) LOOP
         l_item_end_dt := rec.item_end_date;
      END LOOP;
   END IF;
   RETURN  l_item_end_dt;
END item_end_date;

/*============================================================================+
--  NAME         : FETCH_ITEM_END_DATES
--  DESCRIPTION  : To tabulate the item end dates for all terms in a lease
--  NOTES        :
--  SCOPE        : PUBLIC
--  ARGUMENTS
--    p_lease_id          p_lease_id
--
--  RETURNS    : item_end_dt_tbl_type
--
--  NOTES      :
--
--  MODIFICATION HISTORY
--  11-SEP-07 rthumma         Bug # 6366630. Enhancement for new profile
--                             option for lease early termination
--  22-Dec-09 acprakas        Bug#8806693. Modified to use new lease termination
--                            date in case there is no approved schedule
--  24-MAR-10 acprakas        Bug#9323699. Reverted back the change of 8806693.
+=============================================================================*/
FUNCTION fetch_item_end_dates( p_lease_id NUMBER)
RETURN pnp_util_func.item_end_dt_tbl_type IS

CURSOR csr_term_info(p_lease_ID IN NUMBER) IS
   SELECT frequency_code,
          payment_term_id,
          index_period_id
   FROM pn_payment_terms_all
   WHERE lease_id = p_lease_id
   AND NVL(status,'APPROVED') = 'APPROVED';

   l_item_end_dt_tbl   pnp_util_func.item_end_dt_tbl_type;
   i                   NUMBER := 0;

BEGIN

   FOR rec IN csr_term_info(p_lease_id) LOOP
      i := i + 1;
      l_item_end_dt_tbl(i).term_id := rec.payment_term_id;
      l_item_end_dt_tbl(i).index_period_id := rec.index_period_id;
      l_item_end_dt_tbl(i).item_end_dt := item_end_date(rec.payment_term_id,rec.frequency_code);
   END LOOP;
   RETURN l_item_end_dt_tbl;
END fetch_item_end_dates;

/*============================================================================+
--  NAME         : get_high_change_comm_date
--  DESCRIPTION  : To get the highest change commencement date FROM
--                 pn_lease_changes_v for the current lease. This date is used
--                 to compare with the new change_commencement_date for an
--                 ammendement so as not to allow a date earlier than the
--                 existing change_commencement_date.
--  NOTES        : Currently being used in view "PN_LEASE_CHANGES_V"
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_leaseId
--                 OUT : NONE
--  RETURNS      : The highest change commencement date.
--
--  REFERENCE    :
--  HISTORY      :
--  03-FEB-00  Daniel Thota    o Created
--  30-OCT-02  Satish Tripathi o Access _all table for performance issues.
--  15-JUN-05  piagrawa        o Bug 4307795 - Replaced pn_lease_changes
--                               with _ALL table.
+=============================================================================*/
FUNCTION GET_HIGH_CHANGE_COMM_DATE (p_leaseId IN NUMBER) RETURN DATE IS
l_date DATE;

BEGIN
  SELECT MAX(change_commencement_date)
  INTO   l_date
  FROM   pn_lease_changes_all
  WHERE  lease_id = p_leaseId;

  RETURN l_date;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END GET_HIGH_CHANGE_COMM_DATE;

/*===========================================================================+
 | FUNCTION
 |    get_emp_hr_data
 |
 | DESCRIPTION
 |    To get an employee's hr related data for populating PNTSPACE-Assignment
 |    screen.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_personId
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : A record of hr data related to the employee.
 |
 | NOTES      : Currently being used in form "PNTSPACE-Assignmets-Employee"
 |
 | MODIFICATION HISTORY
 |
 |     04-MAY-2000 Daniel Thota      Created
 |     26-OCT-2004 Satish Tripathi   Fixed for BUG# 3927904; select job as of sysdate.
 +===========================================================================*/

FUNCTION GET_EMP_HR_DATA (p_personId IN NUMBER) RETURN EMP_HR_DATA_REC
IS

   l_emp_hr_data       EMP_HR_DATA_REC ;

   CURSOR get_emp_hr_data_csr
   IS
      SELECT ppf.person_id,
             ppf.effective_start_date,
             ppf.effective_end_date,
             paf.assignment_id,
             ppf.last_name last_name,
             ppf.employee_number employee_number,
             ppf.email_address email_address,
             ppf.first_name first_name,
             ppf.full_name full_name,
             ppf.person_type_id,
             ppttl.user_person_type employee_type,
             pp.phone_number phone_number,
             paf.position_id position_id,
             hr_general.decode_position_latest_name(paf.position_id) position,
             paf.job_id job_id,
             pj.name job ,
             paf.organization_id organization_id,
             hou.name organization,
             paf.employment_category employment_category,
             hrl.meaning employment_category_meaning
      FROM   per_jobs pj,
             hr_organization_units hou,
             hr_lookups hrl,
             per_phones pp,
             per_person_types_tl ppttl,
             per_all_assignments_f paf,
             per_all_people_f ppf
      WHERE  ppf.person_id            = p_personId
      AND    TRUNC(SYSDATE)           BETWEEN ppf.effective_start_date AND ppf.effective_end_date
      AND    paf.person_id            = ppf.person_id
      AND    TRUNC(SYSDATE)           BETWEEN paf.effective_start_date AND paf.effective_end_date
      AND    paf.primary_flag         = 'Y'
      AND    pp.parent_table(+)       = 'PER_ALL_PEOPLE_F'
      AND    pp.parent_id(+)          = ppf.person_id
      AND    ppf.effective_start_date BETWEEN pp.date_FROM(+)
                                          AND NVL(pp.date_to(+) ,TO_DATE('12/31/4712','MM/DD/YYYY'))
      AND    pp.phone_type(+)         = 'W1'
      AND    ppttl.person_type_id     = ppf.person_type_id
      AND    ppttl.language           = userenv('LANG')
      AND    hou.organization_id      = paf.organization_id -- no need of outer join it's mAND. col.
      AND    pj.job_id (+)            = paf.job_id
      AND    hrl.lookup_type (+)      = 'EMP_CAT'
      AND    hrl.lookup_code (+)      = paf.employment_category;

BEGIN
   FOR get_emp_hr_data IN get_emp_hr_data_csr
   LOOP
      l_emp_hr_data := get_emp_hr_data;
      EXIT;
   END LOOP;

   RETURN l_emp_hr_data;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;

END GET_EMP_HR_DATA;

/*============================================================================+
--  NAME         : get_emp_pr_data
--  DESCRIPTION  : To get an employee's project related data for populating
--                 PNTSPACE-Assignment screen.
--  NOTES        : Currently being used in form "PNTSPACE-Assignmets-Employee"
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_projectId
--                 OUT : NONE
--  RETURNS      : A record of pr data related to the employee.
--
--  REFERENCE    :
--  HISTORY      :
--  25-MAY-00  Daniel Thota   o Created
--  15-JUN-05  piagrawa       o Bug 4307795 - Replaced PA_PROJECTS
--                              with _ALL table.
+============================================================================*/
FUNCTION GET_EMP_PR_DATA (p_projectId IN NUMBER) RETURN EMP_PR_DATA_REC IS
l_emp_pr_data       EMP_PR_DATA_REC ;

BEGIN

    SELECT pa.segment1,
           hou.name
    INTO l_emp_pr_data
    FROM PA_PROJECTS_ALL pa,
         HR_ORGANIZATION_UNITS hou
    WHERE pa.project_id = p_projectId
          AND hou.organization_id = pa.carrying_out_organization_id;

    RETURN l_emp_pr_data;

EXCEPTION
    WHEN others THEN
            RETURN NULL;

END GET_EMP_PR_DATA;

/*===========================================================================+
 | FUNCTION
 |    get_emp_tr_data
 |
 | DESCRIPTION
 |    To get an employee's project task related data for populating
 |    PNTSPACE-Assignment screen.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_taskId
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : A record of task data related to the employee.
 |
 | NOTES      : Currently being used in form "PNTSPACE-Assignmets-Employee"
 |
 | MODIFICATION HISTORY
 |
 |     25-MAY-2000  Daniel Thota   Created
 +===========================================================================*/

FUNCTION GET_EMP_TR_DATA (
                                        p_taskId       IN NUMBER
                                ) RETURN EMP_TR_DATA_REC
IS

l_emp_tr_data       EMP_TR_DATA_REC ;

BEGIN

    SELECT pat.task_name
    INTO l_emp_tr_data
    FROM PA_TASKS pat
    WHERE pat.task_id                   = p_taskId;

    RETURN l_emp_tr_data;

EXCEPTION
    WHEN others THEN
            RETURN NULL;

END GET_EMP_TR_DATA;

/*===========================================================================+
 | FUNCTION
 |   get_building_rentable_area
 |
 | DESCRIPTION
 |   RETURN the sum of rentable_area of offices associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of rentable_area of offices associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 | 07-FEB-2001  Lakshmikanth K   o An additional check of STATUS = 'A'
 |                                 has been included for  fixing the Bug No. 1630186.
 | 30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 | 31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 | 20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 | 25-FEB-2004  ftanudja         o Revamped code for performance.
 | 05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_building_rentable_area ( p_Location_Id  NUMBER ,
                                       p_as_of_date IN DATE
                                     )  RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('BUILDING','LAND') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.rentable_area;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_building_rentable_area;

/*===========================================================================+
 | FUNCTION
 |   get_building_usable_area
 |
 | DESCRIPTION
 |   RETURN the sum of usable_area of offices associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of usable_area of offices associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                  Included the following INTO the WHERE CLAUSE
 |                                  STATUS = 'A'
 |                                  to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_building_usable_area ( p_Location_Id  NUMBER ,
                                     p_as_of_date IN DATE
          )  RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('BUILDING','LAND') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.usable_area;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_building_usable_area;

/*===========================================================================+
 | FUNCTION
 |   get_building_assignable_area
 |
 | DESCRIPTION
 |   RETURN the sum of assignable_area of offices associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of assignable_area of offices associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |    09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                     Included the following INTO the WHERE CLAUSE
 |                                     STATUS = 'A'
 |                                     to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_building_assignable_area (
              p_Location_Id  NUMBER ,
              p_as_of_date IN DATE
              )  RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('BUILDING','LAND') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.assignable_area;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_building_assignable_area;

/*===========================================================================+
 | FUNCTION
 |   get_floor_rentable_area
 |
 | DESCRIPTION
 |   RETURN the sum of rentable_area of offices associated with a ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of rentable_area of offices associated with a ( Floor/Parcel )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 | 07-FEB-2001  Lakshmikanth K   o An additional check of STATUS = 'A'
 |                                 has been included for  fixing the Bug No. 1630186.
 | 30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 | 20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 | 25-FEB-2004  ftanudja         o Revamped code for performance.
 | 05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION get_floor_rentable_area ( p_Location_Id  IN NUMBER ,
                                   p_as_of_date   IN DATE
            )
RETURN   NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('FLOOR','PARCEL') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.rentable_area;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_floor_rentable_area;

/*===========================================================================+
 | FUNCTION
 |   get_floor_usable_area
 |
 | DESCRIPTION
 |   RETURN the sum of usable_area of offices associated with a ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of usable_area of offices associated with a ( Floor/Parcel )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |  09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                     Included the following INTO the WHERE CLAUSE
 |                                     STATUS = 'A'
 |                                     to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION get_floor_usable_area ( p_Location_Id  IN NUMBER ,
                                 p_as_of_date   IN DATE )
RETURN   NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('FLOOR','PARCEL') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.usable_area;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_floor_usable_area;

/*===========================================================================+
 | FUNCTION
 |   get_floor_assignable_area
 |
 | DESCRIPTION
 |   RETURN the sum of assignable_area of offices associated with a ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of assignable_area of offices associated with a ( Floor/Parcel )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |    09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                     Included the following INTO the WHERE CLAUSE
 |                                     STATUS = 'A'
 |                                     to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_floor_assignable_area ( p_Location_Id  NUMBER ,
                                      p_as_of_date IN DATE )
RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('FLOOR','PARCEL') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.assignable_area;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_floor_assignable_area;

/*===========================================================================+
 | FUNCTION
 |   get_floor_max_capacity
 |
 | DESCRIPTION
 |   RETURN the sum of max_capacity of offices associated with a ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of max_capacity of offices associated with a ( Floor/Parcel )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                   Included the following INTO the WHERE CLAUSE
 |                                   STATUS = 'A'
 |                                   to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_floor_max_capacity (
             p_Location_Id  NUMBER ,
             p_as_of_date IN DATE
          )  RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('FLOOR','PARCEL') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.max_capacity;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_floor_max_capacity;

/*===========================================================================+
 | FUNCTION
 |   get_floor_optimum_capacity
 |
 | DESCRIPTION
 |   RETURN the sum of optimum_capacity of offices associated with a ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of optimum_capacity of offices associated with a ( Floor/Parcel )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                   Included the following INTO the WHERE CLAUSE
 |                                   STATUS = 'A'
 |                                   to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_floor_optimum_capacity ( p_Location_Id  NUMBER ,
               p_as_of_date IN DATE )  RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('FLOOR','PARCEL') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.optimum_capacity;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_floor_optimum_capacity;


/*===========================================================================+
 | FUNCTION
 |   get_building_max_capacity
 |
 | DESCRIPTION
 |   RETURN the sum of max_capacity of offices associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of max_capacity of offices associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  9-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                  Included the following INTO the WHERE CLAUSE
 |                                  STATUS = 'A'
 |                                  to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_building_max_capacity ( p_Location_Id  NUMBER ,
                                      p_as_of_date IN DATE ) RETURN NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('BUILDING','LAND') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.max_capacity;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_building_max_capacity;

/*===========================================================================+
 | FUNCTION
 |   get_building_optimum_capacity
 |
 | DESCRIPTION
 |   RETURN the sum of optimum_capacity of offices associated with a ( Building/LAND )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of optimum_capacity of offices associated with a ( Building/LAND )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                  Included the following INTO the WHERE CLAUSE
 |                                  STATUS = 'A'
 |                                  to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  25-FEB-2004  ftanudja         o Revamped code for performance.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_building_optimum_capacity ( p_Location_Id  NUMBER ,
                                          p_as_of_date IN DATE )  RETURN  NUMBER
IS
 l_location_type       pn_locations.location_type_lookup_code%type;
 l_area                pn_location_area_rec;
 l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);
 invalid_location_type EXCEPTION;

BEGIN

  l_location_type := get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF l_location_type IN ('BUILDING','LAND') THEN

    fetch_loctn_area(
       p_type        => l_location_type,
       p_location_id => p_location_id,
       p_as_of_date  => l_as_of_date,
       x_area        => l_area);

  ELSE
    raise invalid_location_type;
  END IF;

  RETURN l_area.optimum_capacity;

EXCEPTION
   WHEN invalid_location_type THEN
      raise;
   WHEN others THEN
      raise;

END get_building_optimum_capacity;

/*===========================================================================+
 | FUNTION
 |    get_floor_vacancy
 |
 | DESCRIPTION
 |    RETURN the Vacant Capacity for a given location_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    : Vacant capacity for a location (Floor/Parcel)
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 |
 |   17-AUG-2000  Daniel Thota    Added default SYSDATE to call to
 |                                pnp_util_func.get_utilized_capacity
 |                                - Bug Fix for #1379527
 |
 |  18-FEB-2004  abanerje         o Handled NO_DATA_FOUND to return 0.
 |                                  All the select statements have been
 |                                  converted to cursors. The l_location_type
 |                                  is checked for null to return 0.
 |                                  Bug #3384965.
 +===========================================================================*/

FUNCTION  get_floor_vacancy ( p_Location_Id  NUMBER,
                              p_as_of_date    DATE)  RETURN  NUMBER  IS

  l_Location_Type             pn_locations.location_type_lookup_code%type;

  l_utilized_capacity         NUMBER:= pnp_util_func.get_utilized_capacity ( p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_max_capacity              NUMBER:= pnp_util_func.get_floor_max_capacity ( p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_as_of_date                DATE  := pnp_util_func.get_as_of_date(p_as_of_date);
  INVALID_LOCATION_TYPE       EXCEPTION;



BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);
  IF  l_Location_Type IS NULL THEN
      RETURN 0;
  ELSIF  l_Location_Type IN ('FLOOR','PARCEL')  THEN

     IF ROUND((NVL(l_max_capacity,0) - NVL(l_utilized_capacity,0)), 2) > 0 THEN
        RETURN ROUND((NVL(l_max_capacity,0) - NVL(l_utilized_capacity,0)), 2);
     ELSE
        RETURN 0;
     END IF;

  ELSE
    Raise  INVALID_LOCATION_TYPE ;

  END IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN  OTHERS  THEN
    RAISE;

END get_floor_vacancy;

/*===========================================================================+
 | FUNCTION
 |    get_office_vacancy
 |
 | DESCRIPTION
 |    RETURN the Vacant Capacity for a given location_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    : Vacant capacity for a location (Office/Section)
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 |
 |  17-AUG-2000  Daniel Thota    Added default SYSDATE to call to
 |                                pnp_util_func.get_utilized_capacity
 |                                - Bug Fix for #1379527
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location
 |                                  Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl's from locn tbl. 3197410.
 |  18-FEB-2004  abanerje         o Handled NO_DATA_FOUND to return 0.
 |                                  All the select statements have been
 |                                  converted to cursors. The l_location_type
 |                                  is checked for null to return 0.
 |                                  Bug #3384965.
 +===========================================================================*/

FUNCTION  get_office_vacancy ( p_Location_Id  NUMBER ,
                               p_as_of_date IN DATE )  RETURN  NUMBER  IS

  l_Location_Type        pn_locations.location_type_lookup_code%type;
  l_utilized_capacity    NUMBER:= get_utilized_capacity(p_location_id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_max_capacity         NUMBER;
  INVALID_LOCATION_TYPE  EXCEPTION;
  l_as_of_date           DATE := pnp_util_func.get_as_of_date(p_as_of_date);


CURSOR Office_Vacancy_C( p_Location_Id   IN NUMBER
                        ,p_as_of_date    IN DATE
                        ,p_location_type IN VARCHAR2) IS
   (SELECT            NVL((max_capacity), 0) AS vacancy
    FROM              pn_locations_all
    WHERE             Location_Type_Lookup_Code  = p_location_type
    AND               p_as_of_date BETWEEN active_start_date AND active_end_date
    AND               Location_Id                =  p_Location_Id
   );

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

 IF l_Location_Type IS NULL THEN
    RETURN 0;
 ELSIF  l_Location_Type in('OFFICE' , 'SECTION') THEN
  FOR office_vacancy IN Office_Vacancy_C(p_Location_Id
                                         ,l_as_of_date
                                         ,l_location_type)
  LOOP
  l_max_capacity := office_vacancy.vacancy;
  END LOOP;
     IF ROUND((NVL(l_max_capacity,0) - NVL(l_utilized_capacity,0)), 2) > 0 THEN
        RETURN ROUND((NVL(l_max_capacity,0) - NVL(l_utilized_capacity,0)), 2);
     ELSE
        RETURN 0;
     END IF;

  ELSE
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_office_vacancy;

/*============================================================================+
--  NAME         : get_space_assigned_status
--  DESCRIPTION  : Check IF any active assignments exist for the given
--                 Location_Id. RETURNs BOOLEAN TRUE IF any assignment exists,
--                 otherwise it RETURNs FALSE.
--  NOTES        : Currently being used in Locations form - "PNSULOCN.fmb"
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  :  p_location_id, p_as_of_date
--                 OUT :  none
--  RETURNS      : True IF active assignments exist; else False
--
--  REFERENCE    :
--  HISTORY      :
-- 22-MAR-02  Kiran Hegde      o Created
-- 07-MAY-02  Satish Tripathi  o Added parameter p_action_type.
-- 14-MAY-02  Kiran Hegde      o changed the FUNCTION to have only 2 params
-- 21-MAY-02  Kiran Hegde      o replaced p_as_of_date AND SYSDATE with
--                               TRUNC(p_as_of_date) AND TRUNC(SYSDATE) resp.
--                               in the SELECT statement. Fix For bug#2381299
-- 30-OCT-02  Satish Tripathi  o Idented CURSOR csr_current_assign, removed
--                               DISTINCT for performance issues.
-- 31-OCT-01  graghuna         o added p_as_of_date for Location Date-Effectivity
-- 20-OCT-03  ftanudja         o revamped code to remove 'OR', nvl,GROUP BY.
--                               3197410
-- 15-JUN-05  piagrawa         o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                               PN_SPACE_ASSIGN_CUST with _ALL table.
-- 16-MAR-07  CSRIPERU         o Bug#5959164. Modified cursors emp_assign_future
--                               and cust_assign_future to ignore allocated_area_pct
--                               while checking for active assignments for a location.
+=============================================================================*/

FUNCTION get_space_assigned_status ( p_location_id      IN NUMBER,
                                     p_as_of_date       IN DATE )
RETURN   BOOLEAN
IS
   l_exists                                VARCHAR2(1)         := 'N';
   l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);

   CURSOR emp_assign_future (l_date DATE) IS
    SELECT 'Y'
    FROM   pn_space_assign_emp_all
    WHERE  emp_assign_start_date > l_date
 --Bug#5959164  AND  allocated_area_pct > 0
      AND  location_id IN (SELECT location_id
                           FROM   pn_locations_all
                           WHERE  l_as_of_date BETWEEN active_start_date AND active_end_date
                           START WITH location_id = p_Location_Id
                           CONNECT BY PRIOR location_id = parent_location_id
                           AND l_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date);

   CURSOR emp_assign_current (l_date DATE) IS
    SELECT 'Y'
    FROM   pn_space_assign_emp_all
    WHERE  l_date BETWEEN emp_assign_start_date AND emp_assign_end_date
      AND  location_id IN (SELECT location_id
                           FROM   pn_locations_all
                           WHERE  l_as_of_date BETWEEN active_start_date AND active_end_date
                           START WITH location_id = p_Location_Id
                           CONNECT BY PRIOR location_id = parent_location_id
                           AND l_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date);

   CURSOR emp_assign_current_open (l_date DATE) IS
    SELECT 'Y'
    FROM   pn_space_assign_emp_all
    WHERE  l_date >= emp_assign_start_date AND emp_assign_end_date IS NULL -- for open assignments time
      AND  location_id IN (SELECT location_id
                           FROM   pn_locations_all
                           WHERE  l_as_of_date BETWEEN active_start_date AND active_end_date
                           START WITH location_id = p_Location_Id
                           CONNECT BY PRIOR location_id = parent_location_id
                           AND l_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date);

   CURSOR cust_assign_future (l_date DATE) IS
    SELECT 'Y'
    FROM   pn_space_assign_cust_all
    WHERE  cust_assign_start_date > l_date
 --Bug#5959164      AND  allocated_area_pct > 0
      AND  location_id IN (SELECT location_id
                           FROM   pn_locations_all
                           WHERE  l_as_of_date BETWEEN active_start_date AND active_end_date
                           START WITH location_id = p_Location_Id
                           CONNECT BY PRIOR location_id = parent_location_id
                           AND l_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date);

   CURSOR cust_assign_current (l_date DATE) IS
    SELECT 'Y'
    FROM   pn_space_assign_cust_all
    WHERE  l_date BETWEEN cust_assign_start_date AND cust_assign_end_date
      AND  location_id IN (SELECT location_id
                           FROM   pn_locations_all
                           WHERE  l_as_of_date BETWEEN active_start_date AND active_end_date
                           START WITH location_id = p_Location_Id
                           CONNECT BY PRIOR location_id = parent_location_id
                           AND l_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date);

   CURSOR cust_assign_current_open (l_date DATE) IS
    SELECT 'Y'
    FROM   pn_space_assign_cust_all
    WHERE  l_date >= cust_assign_start_date AND cust_assign_end_date IS NULL -- for open assignments time
      AND  location_id IN (SELECT location_id
                           FROM   pn_locations_all
                           WHERE  l_as_of_date BETWEEN active_start_date AND active_end_date
                           START WITH location_id = p_Location_Id
                           CONNECT BY PRIOR location_id = parent_location_id
                           AND l_as_of_date BETWEEN PRIOR active_start_date AND PRIOR active_end_date);

   l_date DATE := NVL(TRUNC(l_as_of_date), TRUNC(SYSDATE));

BEGIN

   FOR exists_cur IN emp_assign_future(l_date) LOOP
      l_exists:= 'Y'; exit;
   END LOOP;

   IF l_exists = 'N' THEN
      FOR exists_cur IN emp_assign_current(l_date) LOOP
         l_exists:= 'Y'; exit;
      END LOOP;
   END IF;

   IF l_exists = 'N' THEN
      FOR exists_cur IN emp_assign_current_open(l_date) LOOP
         l_exists:= 'Y'; exit;
      END LOOP;
   END IF;


   IF l_exists = 'N' THEN
      FOR exists_cur IN cust_assign_future(l_date) LOOP
         l_exists:= 'Y'; exit;
      END LOOP;
   END IF;


   IF l_exists = 'N' THEN
      FOR exists_cur IN cust_assign_current(l_date) LOOP
         l_exists:= 'Y'; exit;
      END LOOP;
   END IF;

   IF l_exists = 'N' THEN
      FOR exists_cur IN cust_assign_current_open(l_date) LOOP
         l_exists:= 'Y'; exit;
      END LOOP;
   END IF;

   IF l_exists = 'Y' THEN
      RETURN TRUE ;
   ELSE
      RETURN FALSE ;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN null;
   WHEN OTHERS THEN
      RAISE;

END get_space_assigned_status;

/*===========================================================================+
 | FUNCTION
 |    get_floor_secondary_area
 |
 | DESCRIPTION
 |    RETURN the secondary_circulation_area for a given location_id ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    : secondary_circulation_area for a given location_id ( Floor/Parcel )
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 | 05-MAY-2004  ftanudja     o Handle if location type is null.
 |
 +===========================================================================*/

FUNCTION  get_floor_secondary_area ( p_Location_Id  NUMBER,
                                     p_as_of_date   DATE )  RETURN  NUMBER  IS

  l_Location_Type             pn_locations.location_type_lookup_code%type;
  l_rentable_area             NUMBER:= get_floor_rentable_area ( p_Location_Id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_usable_area               NUMBER:= get_floor_usable_area ( p_Location_Id,pnp_util_func.get_as_of_date(p_as_of_date));
  l_as_of_date                DATE := pnp_util_func.get_as_of_date(p_as_of_date);  --ASHISH
  INVALID_LOCATION_TYPE       EXCEPTION;



BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);   --ASHISH

  IF l_location_type IS NULL THEN
    raise NO_DATA_FOUND;
  ELSIF   l_Location_Type in ('FLOOR', 'PARCEL')  THEN

  RETURN round((l_rentable_area - l_usable_area), 2);

  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN  OTHERS  THEN
    RAISE;

END get_floor_secondary_area;

/*===========================================================================+
 | FUNCTION
 |    get_office_secondary_area
 |
 | DESCRIPTION
 |    RETURN the secondary_circulation_area for a given location_id ( Office/Section )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS    : secondary_circulation_area for a given location_id
 |              ( Office/Section )
 |
 | NOTES      : Currently being used in view "PN_LOCATIONS_V"
 |                                           "PN_BUILDING_V"
 |              AND Space Assignments form - "PNTSPACE.fmb"
 |
 | MODIFICATION HISTORY
 |
 |     21-MAR-2002  Kiran            o Modified FUNCTION to RETURN 0 IF
 |                                     secondary  Area is less than 0
 |     30-OCT-2002  Satish           o Access _all table for performance issues.
 |     20-OCT-2003  ftanudja         o removed nvl from locn tbl filters. 3197410.
 |     18-FEB-2004  abanerje         o Handled NO_DATA_FOUND to return 0.
 |                                     All the select statements have been
 |                                     converted to cursors. The l_location_type
 |                                     is checked for null to return 0.
 |                                     Bug #3384965
 +===========================================================================*/

FUNCTION  get_office_secondary_area ( p_Location_Id  NUMBER ,
          p_as_of_date IN DATE )  RETURN  NUMBER  IS

  l_Location_Type        pn_locations.location_type_lookup_code%type;
  l_assignable_area      NUMBER;
  l_usable_area          NUMBER;
  l_common_area          NUMBER;
  l_secondary_area       NUMBER;
  INVALID_LOCATION_TYPE  EXCEPTION;
  l_as_of_date           DATE := pnp_util_func.get_as_of_date(p_as_of_date);

   CURSOR Area_C( p_Location_Id   IN NUMBER
                 ,p_as_of_date    IN DATE
                 ,p_location_type IN VARCHAR2) IS
   (SELECT NVL((USABLE_AREA), 0) AS usable_area
          ,NVL((ASSIGNABLE_AREA), 0) AS assignable_area
          ,NVL((COMMON_AREA), 0) AS common_area
    FROM   pn_locations_all
    WHERE  Location_Type_Lookup_Code = p_location_type
    AND    p_as_of_date BETWEEN active_start_date AND active_end_date
    AND    Location_Id = p_Location_Id
     );
BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF   l_Location_Type IS NULL THEN
                     RETURN 0;
  ELSIF   l_Location_Type in ('OFFICE' , 'SECTION')  THEN
     FOR area IN Area_C(p_Location_Id
                       ,l_as_of_date
                                   ,l_location_type)
     LOOP
     l_usable_area := NVL(area.usable_area,0);
     l_assignable_area := NVL(area.assignable_area,0);
     l_common_area := NVL(area.common_area,0);
     END LOOP;

     IF( (l_usable_area - l_assignable_area - l_common_area) < 0 ) THEN
       RETURN 0;
     ELSE
       RETURN ROUND((l_usable_area - l_assignable_area - l_common_area), 2);
     END IF;

  ELSE
    RAISE  INVALID_LOCATION_TYPE ;

  END IF;

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN  OTHERS  THEN
    RAISE;

END get_office_secondary_area;

/*===========================================================================+
 | FUNCTION
 |   get_floor_common_area
 |
 | DESCRIPTION
 |   RETURN the sum of common areas of offices associated with a ( Floor/Parcel )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of common areas of offices associated with a ( Floor/Parcel )
 |
 | NOTES:
 |   Currently being used in views "PN_LOCATIONS_V"
 |                                 "PN_BUILDING_V"
 |   AND form PNSULOCN.fmb ( Locations form )
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  09-MAR-2001  Lakshmikanth K    o Bug Fix #1666611
 |                                     Included the following INTO the WHERE CLAUSE
 |                                     STATUS = 'A'
 |                                     to filter out NOCOPY INACTIVE OFFICES / SECTIONS.
 |  30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja         o Removed nvl from locn tbl. 3197410.
 |  05-MAY-2004  ftanudja         o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_floor_common_area ( p_Location_Id  NUMBER ,
                                  p_as_of_date IN DATE )  RETURN  NUMBER  IS

  l_Location_Type           pn_locations.location_type_lookup_code%type;
  l_common_area             NUMBER;
  INVALID_LOCATION_TYPE     EXCEPTION;

  l_as_of_date DATE := pnp_util_func.get_as_of_date(p_as_of_date);

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
    return null;
  ELSIF  l_Location_Type in ('FLOOR', 'PARCEL')  THEN
      if l_location_type = 'FLOOR' then
         l_location_type := 'OFFICE';
      else
         l_location_type := 'SECTION';
      end if;

    SELECT NVL(SUM(COMMON_AREA),0)
    INTO   l_common_area
    FROM   pn_locations_all
    WHERE  Location_Type_Lookup_Code = l_location_type  --'OFFICE'
    AND    Status = 'A'
    AND    l_as_of_date BETWEEN active_start_date AND active_end_date
    START WITH Location_Id = p_Location_Id
    CONNECT BY PRIOR Location_Id = Parent_Location_Id
    AND l_as_of_date between prior active_start_date and    --ASHISH
    PRIOR active_end_date;

  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

  RETURN (l_common_area);

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN NO_DATA_FOUND THEN
  RETURN NULL;

  WHEN  OTHERS  THEN
    RAISE;

END get_floor_common_area;
/*===========================================================================+
 | FUNCTION
 |   get_building_common_area
 |
 | DESCRIPTION
 |   RETURN the sum of common areas of offices associated with a ( Building/Land )
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   OUT: none
 |
 | RETURNS:
 |   RETURN the sum of common areas of offices associated with a ( Building/Land )
 |
 | NOTES:
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |
 |  31-Jan-2003  Ashish   oCreated
 |  20-OCT-2003  ftanudja o Removed nvl from locn tbl. 3197410.
 |  05-MAY-2004  ftanudja o Handle if location type is null.
 +===========================================================================*/

FUNCTION  get_building_common_area ( p_Location_Id  NUMBER ,
                                  p_as_of_date IN DATE )  RETURN  NUMBER  IS

  l_Location_Type           pn_locations.location_type_lookup_code%type;
  l_common_area             NUMBER;
  INVALID_LOCATION_TYPE     EXCEPTION;

  l_as_of_date DATE := pnp_util_func.get_as_of_date(p_as_of_date);

BEGIN

  l_location_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

  IF l_location_type IS NULL THEN
     return null;
  ELSIF  l_Location_Type in ('BUILDING', 'LAND')  THEN
      if l_location_type = 'BUILDING' then
         l_location_type := 'OFFICE';
      else
         l_location_type := 'SECTION';
      end if;

    SELECT NVL(SUM(COMMON_AREA),0)
    INTO   l_common_area
    FROM   pn_locations_all
    WHERE  Location_Type_Lookup_Code = l_location_type
    AND    Status = 'A'
    AND    l_as_of_date BETWEEN active_start_date AND active_end_date
    START WITH Location_Id = p_Location_Id
    CONNECT BY PRIOR Location_Id = Parent_Location_Id
    AND l_as_of_date between prior active_start_date and
    PRIOR active_end_date;

  Else
    Raise  INVALID_LOCATION_TYPE ;

  End IF;

  RETURN (l_common_area);

EXCEPTION
  WHEN  INVALID_LOCATION_TYPE  THEN
    RAISE;

  WHEN NO_DATA_FOUND THEN
  RETURN NULL;

  WHEN  OTHERS  THEN
    RAISE;

END get_building_common_area;


/*===========================================================================+
 | FUNCTION
 |    get_parent_location_id
 |
 | DESCRIPTION
 |    Get the parent location id of a location of any type
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_location_id
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : parent_location_id FROM PN_LOCATIONS
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |     27-JUN-2000  Neeraj Tandon    o Created
 |     30-OCT-2002  Satish Tripathi  o Removed DISTINCT, access _all table for performance issues.
 |     20-OCT-2003  ftanudja         o Created cursor get_parent_loc_id to
 |                                     replace SELECT stmt and remove GROUP BY.
 |                                     3197410.
 +===========================================================================*/

  FUNCTION get_parent_location_id (
                                    p_location_id IN NUMBER
                                  )
  RETURN   NUMBER
  IS

    CURSOR get_parent_loc_id IS
     SELECT parent_location_id
     FROM   pn_locations_all
     WHERE  location_id = p_location_id;

    l_parent_location_id NUMBER;
  BEGIN

    l_parent_location_id := 0;
    FOR get_cur IN get_parent_loc_id LOOP
       l_parent_location_id := get_cur.parent_location_id; exit;
    END LOOP;

    RETURN l_parent_location_id;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

/*===========================================================================+
 | FUNCTION
 |    get_normalize_flag
 |
 | DESCRIPTION
 |    Get the normalize flag for a payment term
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_paymentTermId
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : normalize FROM PN_PAYMENT_TERMS
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |     31-JUL-2000  Lakshmikanth Katputur   Created
 |     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 +===========================================================================*/

  FUNCTION get_normalize_flag (    p_paymentTermId IN NUMBER
                                      ) RETURN VARCHAR2

  IS

    normalize_flag  VARCHAR2(1);

  BEGIN

    SELECT NVL(normalize ,'N')
    INTO   normalize_flag
    FROM   pn_payment_terms_all
    WHERE  payment_term_id = p_paymentTermId ;

    RETURN (normalize_flag);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN 0;

    WHEN OTHERS THEN
    RAISE;

  END;

/*===========================================================================+
 | FUNCTION
 |    get_hire_date
 |
 | DESCRIPTION
 |    RETURNs the hire data of an employee given the person_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_Person_Id
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : The Hire Date of the employee
 |
 | NOTES      : Currently being used in an upgrade script pninsspa.sql
 |
 | MODIFICATION HISTORY
 |
 |     28-SEP-2000  Daniel Thota   Created
 +===========================================================================*/

  FUNCTION get_hire_date (p_PersonId IN NUMBER
                                      ) RETURN DATE
  IS

      l_hire_date DATE;

  BEGIN

    SELECT MAX(date_start)
    INTO   l_hire_date
    FROM   per_periods_of_service
    WHERE  PERSON_ID = p_PersonId ;

    RETURN (l_hire_date);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

  END;

/*============================================================================+
--  NAME         : Get_Location_Name
--  DESCRIPTION  : RETURNs Location Information given the Location_Id
--  NOTES        : Currently being used in RXi Reports
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_Location_Id
--                 OUT : NONE
--  RETURNS      : The Location Information of the Location
--  REFERENCE    :
--  HISTORY      :
--  24-OCT-00  Daniel Thota    o Created
--  03-NOV-00  Daniel Thota    o Added office_park_name,region_name in the
--                               SELECT clause AND added condition in WHERE
--                               clause to get the appropriate location_park_id
--                               AND parent_location_park_id
--  30-OCT-02  Satish Tripathi o Access _all table for performance issues.
--  31-OCT-01  graghuna        o added p_as_of_date for Location Date-Effectivity
--  20-OCT-03  ftanudja        o removed nvl from locn tbl filter. 3197410.
--  02-JUL-04  Satish Tripathi o Fixed for 3740584, added l_as_of_date BETWEEN
--                                ... for each pn_locations_all table.
--  15-JUN-05  piagrawa        o Bug 4307795 - Replaced PN_PROPERTIES
--                               with _ALL table.
+============================================================================*/

  FUNCTION get_location_name (p_Location_Id IN NUMBER,
                              p_as_of_date  IN DATE
                             )
  RETURN location_name_rec
  IS

    l_parent_location_id NUMBER;
    l_location_type_lookup_code pn_locations.location_type_lookup_code%type;
    l_location_name_rec LOCATION_NAME_REC;
    l_as_of_date          DATE := pnp_util_func.get_as_of_date(p_as_of_date);

  BEGIN

    SELECT location_type_lookup_code,parent_location_id
    INTO   l_location_type_lookup_code,l_parent_location_id
    FROM   pn_locations_all
    WHERE  location_id = p_Location_Id
      AND  p_as_of_date BETWEEN active_start_date AND active_end_date;

    IF l_location_type_lookup_code IN ('OFFICE','SECTION') THEN

       SELECT a.location_code office_location_code,a.OFFICE,b.location_code floor_location_code,
              b.FLOOR,c.location_code building_location_code,c.BUILDING,
              prop.property_code,prop.property_name,
              d.name office_park_name, e.name region_name
       INTO l_location_name_rec
       FROM pn_locations_all a,
            pn_locations_all b,
            pn_locations_all c,
            pn_location_parks d,
            pn_location_parks e,
            pn_properties_all prop
       WHERE a.location_id           = p_Location_Id
       AND   l_as_of_date BETWEEN a.active_start_date AND a.active_end_date
       AND   b.location_id           = l_parent_location_id
       AND   l_as_of_date BETWEEN b.active_start_date AND b.active_end_date
       AND   c.location_id           = pnp_util_func.GET_PARENT_LOCATION_ID(l_parent_location_id)
       AND   l_as_of_date BETWEEN c.active_start_date AND c.active_end_date
       AND   prop.property_id(+)     = c.property_id
       AND   d.location_park_id(+)   = prop.location_park_id
       AND   d.location_park_type(+) = 'OFFPRK'
       AND   d.language(+)           = userenv('LANG')
       AND   e.location_park_id(+)   = d.parent_location_park_id
       AND   e.location_park_type(+) = 'REGION'
       AND   e.language(+)           = userenv('LANG');

    ELSIF l_location_type_lookup_code IN ('FLOOR','PARCEL') THEN

       SELECT '' office_location_code,'' OFFICE,b.location_code floor_location_code,
              b.FLOOR,c.location_code building_location_code,c.BUILDING,
              prop.property_code,prop.property_name,
              d.name office_park_name, e.name region_name
       INTO l_location_name_rec
       FROM pn_locations_all b,
            pn_locations_all c,
            pn_location_parks d,
            pn_location_parks e,
            pn_properties_all prop
       WHERE b.location_id            = p_Location_Id
       AND   l_as_of_date BETWEEN b.active_start_date AND b.active_end_date
       AND   c.location_id            = l_parent_location_id
       AND   l_as_of_date BETWEEN c.active_start_date AND c.active_end_date
       AND   prop.property_id(+)      = c.property_id
       AND   d.location_park_id(+)    = prop.location_park_id
       AND   d.location_park_type(+)  = 'OFFPRK'
       AND   d.language(+)            = userenv('LANG')
       AND   e.location_park_id(+)    = d.parent_location_park_id
       AND   e.location_park_type(+)  = 'REGION'
       AND   e.language(+)            = userenv('LANG');

    ELSE

       SELECT '' office_location_code,'' OFFICE,'' floor_location_code,
              '' FLOOR,c.location_code building_location_code,c.BUILDING,
              prop.property_code,prop.property_name,
              d.name office_park_name, e.name region_name
       INTO l_location_name_rec
       FROM pn_locations_all c,
            pn_location_parks d,
            pn_location_parks e,
            pn_properties_all prop
       WHERE c.location_id           = p_Location_Id
       AND   l_as_of_date BETWEEN c.active_start_date AND c.active_end_date
       AND   prop.property_id(+)     = c.property_id
       AND   d.location_park_id(+)   = prop.location_park_id
       AND   d.location_park_type(+) = 'OFFPRK'
       AND   d.language(+)           = userenv('LANG')
       AND   e.location_park_id(+)   = d.parent_location_park_id
       AND   e.location_park_type(+) = 'REGION'
       AND   e.language(+)           = userenv('LANG');

    END IF;

    RETURN (l_location_name_rec);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

  END;

/*===========================================================================+
 | FUNCTION
 |    get_termination_date
 |
 | DESCRIPTION
 |    RETURNs the termination data of an employee given the person_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_Person_Id
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : The Termination Date of the employee
 |
 | NOTES      : Currently being used in PNEMPDSP.rdf
 |
 | MODIFICATION HISTORY
 |
 |     12-DEC-2000  Mrinal Misra   Created
 +===========================================================================*/


  FUNCTION get_termination_date (p_PersonId IN NUMBER
                                      ) RETURN DATE
  IS


      l_termination_date DATE;

  BEGIN

    SELECT MAX(NVL(actual_termination_date,TO_DATE('12/31/4712','mm/dd/yyyy')))
    INTO   l_termination_date
    FROM   per_periods_of_service
    WHERE  person_id = p_PersonId ;

    IF l_termination_date = TO_DATE('12/31/4712','mm/dd/yyyy') THEN
       l_termination_date := NULL;
    end IF;

    RETURN (l_termination_date);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

  END get_termination_date;

/*===========================================================================+
 | FUNCTION
 |    get_rentable_area
 |
 | DESCRIPTION
 |    RETURNs the rentable area given the location type lookup code AND
 |    location id.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_loc_type_lookup_code, p_location_id
 |
 |              OUT:
 |                    none
 |
 | RETURNS    : The Rentable Area
 |
 | NOTES      : Currently being used in PNSPUTIL.rdf
 |
 | MODIFICATION HISTORY
 |
 |     22-JAN-2000  Mrinal Misra     o Created
 |     07-FEB-2001  Lakshmikanth K   o An additional check of STATUS = 'A'
 |                                     has been included for  fixing the Bug No. 1630186.
 |     31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity.
 +===========================================================================*/

FUNCTION get_rentable_area (p_loc_type_lookup_code IN VARCHAR2,
                            p_location_id          IN NUMBER ,
                            p_as_of_date           IN DATE
                           ) RETURN NUMBER
  IS

     l_rentable_area NUMBER;
     l_as_of_date DATE := pnp_util_func.get_as_of_date(p_as_of_date);

BEGIN

  IF    p_loc_type_lookup_code IS NULL AND p_location_id IS NULL THEN

        l_rentable_area := 0;

  ElSIF p_loc_type_lookup_code IN ('BUILDING','LAND') THEN

        l_rentable_area := get_building_rentable_area(p_location_id , l_as_of_date);   --ASHISH ADDED L_AS_OF_DATE

  ElSIF p_loc_type_lookup_code IN ('FLOOR','PARCEL') THEN

        l_rentable_area := get_floor_rentable_area(p_location_id, l_as_of_date); --ASHISH ADDED L_AS_OF_DATE

  ElSIF p_loc_type_lookup_code IN ('OFFICE','SECTION') THEN

        /* Getting rentable area for Office/Section */

        SELECT NVL(rentable_area,0)
        INTO   l_rentable_area
        FROM   pn_locations_all
        WHERE  location_id = p_location_id
        AND    active_start_date <= l_as_of_date
        AND    active_end_date   >= l_as_of_date;

  END IF;

  RETURN (l_rentable_area);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       RETURN 0;

    WHEN OTHERS THEN
       RETURN 0;

END get_rentable_area;

/*===========================================================================+
 | FUNCTION
 |    get_default_gl_period
 |
 | DESCRIPTION
 |    RETURNs GL period name for a given Schedule(GL) date AND Lease Class Code.
 |    IF the GL period is closed for the givem Schedule(GL) DATE, next open GL
 |    period name is RETURNed. IF there does not exist an open GL period
 |    for the given Scheduel(GL) date THEN an error message is displayed. Lease
 |    Class Code is used to get the application id of AR AND AP.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_sch_date, p_lease_class_code
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : GL Period Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     02-FEB-2001  Mrinal Misra   Created
 |     19-APR-2002  Kiran Hegde    Fix for Bug#2236264 AND bug#2448324
 |                                 Changed WHERE closing_status <> 'C' to
 |                                 WHERE closing_status IN ('O', 'F')
 |     28-NOV-2005  sdmahesh    o Added parameter P_ORG_ID
 |                              o Passed org_id to get_profile_value
 |
 +===========================================================================*/

FUNCTION get_default_gl_period(p_sch_date IN DATE,
                               p_application_id IN NUMBER,
                               p_org_id IN NUMBER
                              ) RETURN VARCHAR2 IS

      l_gl_period_name   gl_period_statuses.period_name%TYPE;
      l_err_msg          VARCHAR2(2000);

BEGIN

   /* Selecting GL period name WHEN Schedule(GL) date lies between start date
      AND end date of an open GL period. */

   SELECT period_name
   INTO   l_gl_period_name
   FROM   gl_period_statuses
   WHERE  closing_status IN ('O', 'F')
   AND    set_of_books_id = pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                            p_org_id)
   AND    application_id = p_application_id
   AND    adjustment_period_flag = 'N'
   AND    p_sch_date BETWEEN start_date AND end_date;

   RETURN(l_gl_period_name);

EXCEPTION

   WHEN NO_DATA_FOUND THEN

      BEGIN

         /* WHEN GL period for a given Schedule(GL) date is closed
            next open GL period name is seleted. */

         SELECT period_name
         INTO   l_gl_period_name
         FROM   gl_period_statuses
         WHERE  closing_status IN ('O', 'F')
         AND    set_of_books_id = pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                  p_org_id)
         AND    application_id = p_application_id
         AND    adjustment_period_flag = 'N'
         AND    start_date = (SELECT MIN(start_date)
                              FROM   gl_period_statuses
                              WHERE  closing_status IN ('O', 'F')
                              AND    set_of_books_id = pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                       p_org_id)
                              AND    application_id = p_application_id
                              AND    adjustment_period_flag = 'N'
                              AND    start_date >= p_sch_date);


         RETURN(l_gl_period_name);

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

         /* RETURNing NULL WHEN no open GL Period is found */

            RETURN NULL;

      END;

END get_default_gl_period;


/*===========================================================================+
 | FUNCTION
 |   Get_Unit_Of_Measure
 |
 | DESCRIPTION
 |   RETURN The Unit Of Measure
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id
 |   IN:  p_loc_type
 |   OUT: none
 |
 | RETURNS:
 |   RETURN The Unit Of Measure for any location_id
 |
 | NOTES:
 |
 | ASSUMPTION:
 |
 | ALGORITHM
 |
 | MODIFICATION HISTORY
 |   05-FEB-2001  Lakshmikanth  o Created this FUNCTION to populate
 |                                the UOM_CODE at the Floor/Parcel AND
 |                                Office/Section to be used in the PNTSPACE.fmb
 |                                Bug Fix for the Bug ID#1540803.
 |     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 |  31-OCT-2001  graghuna         o added p_as_of_date for Location Date-Effectivity
 |  20-OCT-2003  ftanudja       o removed nvl for locn tbl. 3197410.
 |  05-MAY-2004  ftanudja       o Handle if l_loc_type is null.
 |  21-MAY-2004  ftanudja       o Removed second 'IF l_type_code = null' cond.
 +===========================================================================*/

FUNCTION Get_Unit_Of_Measure (p_location_id IN NUMBER,
                              p_loc_type    IN VARCHAR2 ,
                              p_as_of_date  IN DATE )

RETURN VARCHAR2 IS

 l_uom        PN_LOCATIONS.uom_code%type;
 l_loc_type   PN_LOCATIONS.location_type_lookup_code%type;
 l_as_of_date DATE := pnp_util_func.get_as_of_date(p_as_of_date);

  CURSOR get_uom_code_cur IS
   SELECT  uom_code
   FROM    pn_locations_all
   WHERE   location_type_lookup_code    = l_loc_type
   AND     l_as_of_date BETWEEN active_start_date AND active_end_date
   Start   with location_id             = p_location_id
   CONNECT BY PRIOR parent_location_id  = location_id
   and rownum < 2 ;
begin

  IF p_loc_type is NULL THEN

     l_loc_type := pnp_util_func.get_location_type_lookup_code (
                         p_location_id => p_location_id,
                         p_as_of_date  => l_as_of_date);

     IF l_loc_type IS NULL THEN
         raise NO_DATA_FOUND;
     ELSIF l_loc_type in ('BUILDING', 'FLOOR' , 'OFFICE') THEN
         l_loc_type:=  'BUILDING';
     ElSIF l_loc_type in ('LAND', 'PARCEL' , 'SECTION') THEN
         l_loc_type:=  'LAND';
     END IF;

  ELSE

     IF p_loc_type in ('BUILDING', 'FLOOR' , 'OFFICE') THEN
         l_loc_type:=  'BUILDING';
     ElSIF p_loc_type in ('LAND', 'PARCEL' , 'SECTION') THEN
         l_loc_type:=  'LAND';
     END IF;

  END IF;

   FOR get_uom_rec in get_uom_code_cur LOOP
       l_uom := get_uom_rec.uom_code;
   END LOOP;

 RETURN l_uom;

 exception
 WHEN others THEN
  RAISE;
  l_uom := NULL;
  RETURN l_uom;

End Get_Unit_Of_Measure;

/*===========================================================================+
 | FUNCTION
 |    get_ap_payment_term
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs Payment Terms Name for a given Payment Term Id
 |    for Payables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_ap_term_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : Payment Term Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     23-MAY-2001  Mrinal Misra   Created
 +===========================================================================*/

FUNCTION Get_Ap_Payment_term (p_ap_term_id IN NUMBER)

RETURN VARCHAR2 IS

        l_payment_term_name                ap_terms.name%type;

BEGIN

    SELECT name
    INTO   l_payment_term_name
    FROM   ap_terms
    WHERE  term_id = p_ap_term_id;

    RETURN(l_payment_term_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ap_Payment_term;

/*===========================================================================+
 | FUNCTION
 |    get_ar_payment_term
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs Payment Terms Name for a given Payment Term Id
 |    for Receivables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_ar_term_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : Payment Term Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     23-MAY-2001  Mrinal Misra   Created
 +===========================================================================*/

FUNCTION Get_Ar_Payment_term (p_ar_term_id IN NUMBER)

RETURN VARCHAR2 IS

    l_payment_term_name        ra_terms.name%type;

BEGIN

    SELECT name
    INTO   l_payment_term_name
    FROM   ra_terms
    WHERE  term_id = p_ar_term_id;

    RETURN(l_payment_term_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ar_Payment_term;

/*===========================================================================+
--  NAME         : get_distribution_set_name
--  DESCRIPTION  : This FUNCTION RETURNs Distribution Name for a given Distribution Set Id.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_dist_set_id
--  RETURNS      : Distribution Name
--  REFERENCE    :
--  HISTORY      :
--  23-MAY-01  Mrinal Misra   o Created
--  15-JUN-05  piagrawa       o Bug 4307795 - Replaced ap_distribution_sets
--                              with _ALL table.
 +===========================================================================*/

FUNCTION Get_Distribution_Set_Name (p_dist_set_id IN NUMBER)

RETURN VARCHAR2 IS

    l_dist_set_name ap_distribution_sets.distribution_set_name%type;

BEGIN

    SELECT distribution_set_name
    INTO   l_dist_set_name
    FROM   ap_distribution_sets_all
    WHERE  distribution_set_id = p_dist_set_id;

    RETURN(l_dist_set_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Distribution_Set_Name;

/*===========================================================================+
--  NAME         : get_ap_project_name
--  DESCRIPTION  : This FUNCTION RETURNsProject Name for a given Project Id
--                 FROM Payables.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_project_id
--  RETURNS      : Project Name
--  REFERENCE    :
--  HISTORY      :
--  23-MAY-01  Mrinal Misra  o Created
--  23-APR-04  ftanudja      o Changed pa_projects_expend_v to pa_projects
--                             for performance. #3239094.
--  15-JUN-05  piagrawa      o Bug 4307795 - Replaced pa_projects
--                             with _ALL table.
+===========================================================================*/
FUNCTION Get_Ap_Project_Name (p_project_id IN NUMBER) RETURN VARCHAR2 IS

    l_project_name     pa_projects.name%type;

BEGIN

    SELECT name
    INTO   l_project_name
    FROM   pa_projects_all
    WHERE  project_id = p_project_id;

    RETURN(l_project_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ap_Project_Name;

/*===========================================================================+
 | FUNCTION
 |    get_ap_task_name
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs Task Name for a given Task Id FROM Payables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_task_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : Task Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     23-MAY-2001  Mrinal Misra   Created
 +===========================================================================*/

FUNCTION Get_Ap_Task_Name (p_task_id IN NUMBER)

RETURN VARCHAR2 IS

    l_task_name         pa_tasks_expend_v.task_name%type;

BEGIN

    SELECT task_name
    INTO   l_task_name
    FROM   pa_tasks_expend_v
    WHERE  task_id = p_task_id;

    RETURN(l_task_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ap_Task_Name;

/*===========================================================================+
 | FUNCTION
 |    get_ap_organization_name
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs organization Name for a given organization Id FROM Payables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_org_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : organization Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     23-MAY-2001  Mrinal Misra   o Created
 |     25-MAR-2004  Mrinal Misra   o Changed view name in SELECT statement.
 |     17-JUL-2009  bifernan       o Bug 8370634: Added rownum condition to
 |                                   the query
 +===========================================================================*/

FUNCTION Get_Ap_organization_Name (p_org_id IN NUMBER)

RETURN VARCHAR2 IS

    l_org_name         pa_organizations_expend_v.name%type;

BEGIN

    SELECT name
    INTO   l_org_name
    FROM   pa_organizations_expend_v
    WHERE  organization_id = p_org_id
    AND    ROWNUM = 1;

    RETURN(l_org_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ap_organization_Name;

/*============================================================================+
--  NAME         : get_ar_trx_type
--  DESCRIPTION  : This FUNCTION RETURNs Transaction Type for a given Customer
--                 Transaction Type Id FROM Receivables.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_trx_id
--  RETURNS      : Transaction Type
--  REFERENCE    :
--  HISTORY      :
--  23-MAY-01  Mrinal Misra  o Created
--  15-JUN-05  piagrawa      o Bug 4307795 - Replaced ra_cust_trx_types
--                             with _ALL table.
--  24-Jun-05  Kiran         o reverted the last change
--  IMPORTANT - make not more changes to this function. This will be called
--              pre MOAC / pre R12
+============================================================================*/
FUNCTION Get_Ar_Trx_type (p_trx_id IN NUMBER) RETURN VARCHAR2 IS

l_trx_type ra_cust_trx_types.name%TYPE;


BEGIN

    SELECT name
    INTO   l_trx_type
    FROM   ra_cust_trx_types
    WHERE  cust_trx_type_id = p_trx_id;

    RETURN(l_trx_type);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ar_Trx_type;

/*===========================================================================+
 | FUNCTION
 |    get_ar_rule_name
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs Invoice Rule Name for a given Invoice Rule Id
 |    FROM Receivables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_rule_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : Invoice Rule Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     23-MAY-2001  Mrinal Misra   Created
 +===========================================================================*/

FUNCTION Get_Ar_Rule_Name (p_rule_id IN NUMBER)

RETURN VARCHAR2 IS

    l_rule_name         ra_rules.name%type;

BEGIN

    SELECT name
    INTO   l_rule_name
    FROM   ra_rules
    WHERE  rule_id = p_rule_id;

    RETURN(l_rule_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END Get_Ar_Rule_Name;

/*===========================================================================+
 | FUNCTION
 |    get_salesrep_name
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs Sales Person Name for a given Sales Person Id
 |    FROM Receivables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_salesrep_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : Sales Person Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     23-MAY-2001  Mrinal Misra   Created
 |     24-MAR-2006  Hareesha  o Bug 5116270 Added org_id parameter to
 |                              get_salesrep_name
 +===========================================================================*/

FUNCTION Get_Salesrep_Name (p_salesrep_id IN NUMBER,
                            p_org_id IN NUMBER)

RETURN VARCHAR2 IS

    l_salesrep_name        ra_salesreps.name%type;

    CURSOR get_salesrep_cur IS
       SELECT name
       FROM ra_salesreps
       WHERE salesrep_id = p_salesrep_id
       AND org_id = p_org_id;

BEGIN

    FOR rec IN get_salesrep_cur LOOP
       l_salesrep_name := rec.name;
    END LOOP;

    RETURN(l_salesrep_name);

EXCEPTION
    WHEN OTHERS THEN
       RAISE;

END Get_Salesrep_Name;

/*===========================================================================+
--  NAME         : get_min_futr_str_dt
--  DESCRIPTION  : RETURNs minimum future assignment start date for a location.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_loc_id,p_str_dt.
--                 OUT : l_emp_min_str_dt,l_cust_min_str_dt.
--  RETURNS      :  Allocated Area
--  REFERENCE    :
--  HISTORY      :
--  01-APR-02  Mrinal Misra  o Created
--  15-JUN-05  piagrawa      o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                             PN_SPACE_ASSIGN_CUST with _ALL table.
+===========================================================================*/
FUNCTION get_min_futr_str_dt(p_loc_id IN NUMBER,
                             p_str_dt IN DATE)
RETURN DATE IS

   l_emp_min_str_dt   DATE;
   l_cust_min_str_dt  DATE;

BEGIN

      SELECT MIN(emp_assign_start_date)
      INTO   l_emp_min_str_dt
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_loc_id
      AND    TRUNC(emp_assign_start_date) > TRUNC(p_str_dt);

      SELECT MIN(cust_assign_start_date)
      INTO   l_cust_min_str_dt
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_loc_id
      AND    TRUNC(cust_assign_start_date) > TRUNC(p_str_dt);

   IF NVL(TRUNC(l_emp_min_str_dt),TO_DATE('12/31/4712','mm/dd/yyyy')) <
      NVL(TRUNC(l_cust_min_str_dt),TO_DATE('12/31/4712','mm/dd/yyyy')) THEN
      RETURN l_emp_min_str_dt;
   ELSE
      RETURN l_cust_min_str_dt;
   END IF;

END get_min_futr_str_dt;

/*=============================================================================+
--  NAME         : get_allocated_area
--  DESCRIPTION  : RETURNs:
--                 o  allocated area
--                 o  new end date ( IF future assignment exists )
--                 o  p_future = 'Y' ( IF future assignment exists )
--                    for an assigned location between given date range.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : p_loc_id, p_str_dt, p_new_end_dt, p_allocated_area,
--                          p_future.
--                 IN OUT : p_new_end_dt
--                 OUT    : p_allocated_area, p_future
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
-- 01-MAY-02  Mrinal Misra o Created
-- 14-MAY-02  Kiran Hegde  o Changed FROM FUNCTION to procedure
--                           Added parameters p_new_allocated_area,
--                           p_allocated_area, p_future
--                         o Changed SELECT for getting allocated_area
-- 20-MAY-02  Mrinal Misra o Put emp_assign_end_date AND cust_assign_end_date
--                           in NVL.
-- 07-JAN-04  Daniel Thota o Added new OUT parameter p_allocated_area_pct
--                           Included allocated_area_pct in the SELECT clauses
--                           Fix for bug # 3354278
-- 30-DEC-04  Kiran        o Bug # 4093603 - Added new param p_called_frm_mode
--                           if p_called_frm_mode is PNTSPACE_UPDATE then
--                           do not get min future start date.
-- 15-JUN-05  piagrawa     o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                           PN_SPACE_ASSIGN_CUST with _ALL table.
-- 30-JAN-07  csriperu     o Bug 5854636 - Moved the future assignment check to
--                           validate_vacant_area
+===========================================================================*/

PROCEDURE get_allocated_area ( p_loc_id             IN NUMBER,
                               p_str_dt             IN DATE,
                               p_new_end_dt         IN OUT NOCOPY DATE,
                               p_allocated_area     OUT NOCOPY NUMBER,
                               p_allocated_area_pct OUT NOCOPY NUMBER,
                               p_future             OUT NOCOPY VARCHAR2,
                               p_called_frm_mode    IN VARCHAR2) IS

   l_allocated_area_emp      NUMBER;
   l_allocated_area_cust     NUMBER;
   l_allocated_area_pct_emp  NUMBER;
   l_allocated_area_pct_cust NUMBER;
   l_fut_str_dt              DATE;

BEGIN
   /* Commented and moved to validate_vacant_area  Bug 5854636
   IF p_called_frm_mode IS NULL THEN
     l_fut_str_dt := pnp_util_func.get_min_futr_str_dt(p_loc_id,p_str_dt);
   ELSIF p_called_frm_mode = 'PNTSPACE_UPDATE' THEN
     l_fut_str_dt := g_end_of_time;
   END IF;

   IF NVL( p_new_end_dt, g_end_of_time )
      > NVL( l_fut_str_dt, g_end_of_time )
   THEN
      p_new_end_dt := l_fut_str_dt - 1;
      p_future := 'Y';
   END IF;
   End Comments for Bug 5854636 */

   SELECT NVL(SUM(allocated_area), 0)
          ,NVL(SUM(allocated_area_pct), 0)
   INTO   l_allocated_area_emp
          ,l_allocated_area_pct_emp
   FROM   pn_space_assign_emp_all
   WHERE  location_id = p_loc_id
   AND    emp_assign_start_date <= NVL(p_new_end_dt,TO_DATE('12/31/4712','mm/dd/yyyy'))
   AND    NVL(emp_assign_end_date,TO_DATE('12/31/4712','mm/dd/yyyy')) >= p_str_dt;

   SELECT NVL(SUM(allocated_area), 0)
          ,NVL(SUM(allocated_area_pct), 0)
   INTO   l_allocated_area_cust
          ,l_allocated_area_pct_cust
   FROM   pn_space_assign_cust_all
   WHERE  location_id = p_loc_id
   AND    cust_assign_start_date <= NVL(p_new_end_dt,TO_DATE('12/31/4712','mm/dd/yyyy'))
   AND    NVL(cust_assign_end_date,TO_DATE('12/31/4712','mm/dd/yyyy')) >= p_str_dt;

   p_allocated_area     := l_allocated_area_emp + l_allocated_area_cust;
   p_allocated_area_pct := l_allocated_area_pct_emp + l_allocated_area_pct_cust;

END GET_ALLOCATED_AREA;

/*=============================================================================+
 | PROCEDURE
 |   validate_vacant_area
 |
 | DESCRIPTION
 |   RETURNs:
 |          o  assignable area
 |          o  new end date ( IF future assignment exists )
 |          o  p_future = 'Y' ( IF future assignment exists )
 |            o  p_available_vacant_area IF vacant area is available.
 |          for an assigned location between given date range.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN         :     p_loc_id, p_str_dt, p_new_end_dt, p_allocated_area
 |   IN OUT     :     p_new_end_dt
 |   OUT NOCOPY :     p_allocated_area, p_future
 |
 | MODIFICATION HISTORY
 | 14-MAY-02 Kiran    o Created
 | 20-MAY-02 Mrinal   o Put variables in NVL in the IF condition.
 | 30-OCT-02 Satish   o Access _all table for performance issues.
 | 31-DEC-02 Mrinal   o Added NO_DATA_FOUND exception.
 | 20-OCT-03 ftanudja o removed nvl from locn tbl filter. 3197410.
 | 07-JAN-04 Daniel   o Added new OUT parameter l_total_allocated_area_pct in
 |                      call to pnp_util_func.get_allocated_area. bug # 3354278
 | 26-MAY-04 abanerje o Added NVL to the select statement so that the
 |                      p_assignable_area is set to -99 when the area is common
 |                      Using this method we are able to distinguish the
 |                      condition when
 |                      a) Location exists for the given date ranges but its a
 |                         common area then set p_assignable_area=-99
 |                      Bug 3598315.
 | 30-DEC-04 Kiran    o Bug # 4093603 - Added new param p_called_frm_mode
 |                      and passed it to get_allocated_area.
 |                      Corrected the calculation of l_new_allocated_area_pct
 |                      and l_old_allocated_area_pct.
 | 16-Jun-06 piagrawa o Bug #4314940 - handle case if p_assignable_area = 0
 | 12-Jan-06 hkulkarn o Bug 4740867 - Deriving assignable_area based on underlying
 |                      property/location. This is useful incase of freshly imported
 |                      locations for assignment in Lease.
 | 23-FEB-06 Hareesha o Bug # 4926472. Pop-up msg PN_CANNOT_ASSIGN_SPC_COMM
 |                      when common-area-flag is set to Yes.
 | 25-JAN-07 csriperu o Bug 5854636 - Moved the future assignment check from
 |                      get_allocated_area
 +===========================================================================*/

 PROCEDURE validate_vacant_area (p_location_id            IN NUMBER,
                                 p_st_date                IN DATE,
                                 p_end_dt                 IN OUT NOCOPY DATE,
                                 p_assignable_area        IN OUT NOCOPY NUMBER,
                                 p_old_allocated_area     IN NUMBER,
                                 p_new_allocated_area     IN NUMBER,
                                 p_old_allocated_area_pct IN NUMBER,
                                 p_new_allocated_area_pct IN NUMBER,
                                 p_display_message        IN VARCHAR2,
                                 p_future                 OUT NOCOPY VARCHAR2,
                                 p_available_vacant_area  OUT NOCOPY BOOLEAN,
                                 p_called_frm_mode        IN VARCHAR2) IS

   l_new_allocated_area        NUMBER;
   l_old_allocated_area        NUMBER;
   l_new_allocated_area_pct    NUMBER;
   l_old_allocated_area_pct    NUMBER;
   l_total_allocated_area      NUMBER;
   l_total_allocated_area_pct  NUMBER;
   l_future                    VARCHAR2(1) := NULL;
   l_end_dt DATE := nvl(p_end_dt, g_end_of_time);
   l_area_rec           pnp_util_func.pn_location_area_rec;
   l_fut_str_dt              DATE; -- Added for bug#5854636
   l_common_flag VARCHAR2(1);
   CURSOR get_common_flag IS
      SELECT common_area_flag
      FROM pn_locations_all
      WHERE location_id = p_location_id
      AND active_start_date <= l_end_dt
      AND active_end_date >= p_st_date;

BEGIN
   PNP_DEBUG_PKG.debug ('validate_vacant_area(+)');

   pnp_util_func.fetch_loctn_area(
            p_type        => pnp_util_func.get_location_type_lookup_code
                                (
                                 p_location_id => p_location_id,
                                 p_as_of_date  => p_st_date
                                 ),
            p_location_id => p_location_id,
            p_as_of_date  => p_st_date,
            x_area        => l_area_rec);

   FOR rec IN get_common_flag LOOP
      l_common_flag := rec.common_area_flag;
   END LOOP;
   IF l_common_flag = 'Y' THEN
     fnd_message.set_name('PN', 'PN_CANNOT_ASSIGN_SPC_COMM');
     fnd_message.set_token('LOCATION_ID', p_location_id);
     p_available_vacant_area := FALSE;
     p_future := 'N';
     RETURN;
   END IF;

   p_assignable_area:= nvl(l_area_rec.assignable_area,-99);  -- Bug 7562922
   l_new_allocated_area     := NVL( p_new_allocated_area, (p_new_allocated_area_pct/100)*p_assignable_area );
   l_old_allocated_area     := NVL( p_old_allocated_area, (p_old_allocated_area_pct/100)*p_assignable_area );
   IF ( p_assignable_area = 0 ) THEN
     l_new_allocated_area_pct := NVL( p_new_allocated_area_pct, 0 );
     l_old_allocated_area_pct := NVL( p_old_allocated_area_pct, 0 );
   ELSE
     l_new_allocated_area_pct := NVL( p_new_allocated_area_pct, (p_new_allocated_area/p_assignable_area)*100 );
     l_old_allocated_area_pct := NVL( p_old_allocated_area_pct, (p_old_allocated_area/p_assignable_area)*100 );
   END IF;
   pnp_util_func.get_allocated_area (p_loc_id             => p_location_id,
                                     p_str_dt             => p_st_date,
                                     p_new_end_dt         => p_end_dt,
                                     p_allocated_area     => l_total_allocated_area,
                                     p_allocated_area_pct => l_total_allocated_area_pct,
                                     p_future             => l_future,
                                     p_called_frm_mode    => p_called_frm_mode);

 /* Modified the below code for Bug 5854636*/
   IF (NVL(l_new_allocated_area,0) - NVL(l_old_allocated_area,0)
       > NVL(p_assignable_area,0) - NVL(l_total_allocated_area,0)) AND
      (NVL(l_new_allocated_area_pct,0) - NVL(l_old_allocated_area_pct,0)
       > 100 - NVL(l_total_allocated_area_pct,0))
   THEN
       IF p_called_frm_mode IS NULL THEN
         l_fut_str_dt := pnp_util_func.get_min_futr_str_dt(p_location_id,p_st_date);
       ELSIF p_called_frm_mode = 'PNTSPACE_UPDATE' THEN
         l_fut_str_dt := g_end_of_time;
       END IF;

       IF NVL( p_end_dt, g_end_of_time )
          > NVL( l_fut_str_dt, g_end_of_time )
       THEN
          p_end_dt := l_fut_str_dt - 1;
          pnp_util_func.get_allocated_area (p_loc_id             => p_location_id,
                                            p_str_dt             => p_st_date,
                                            p_new_end_dt         => p_end_dt,
                                            p_allocated_area     => l_total_allocated_area,
                                            p_allocated_area_pct => l_total_allocated_area_pct,
                                            p_future             => l_future,
                                            p_called_frm_mode    => p_called_frm_mode);
          l_future := 'Y';
       END IF;
       IF (NVL(l_new_allocated_area,0) - NVL(l_old_allocated_area,0)
           > NVL(p_assignable_area,0) - NVL(l_total_allocated_area,0)) AND
          (NVL(l_new_allocated_area_pct,0) - NVL(l_old_allocated_area_pct,0)
           > 100 - NVL(l_total_allocated_area_pct,0))
       THEN
          p_available_vacant_area := FALSE;
          fnd_message.set_name ('PN','PN_AREA_UNAVAILABLE');
       ELSE
          IF ( (NVL(l_future, 'N') = 'Y') AND (p_display_message = 'Y') ) THEN
             fnd_message.set_name ('PN','PN_FUTURE_ASGN_DT_MSG');
             fnd_message.set_token ('L_FUTURE_ASGN_DT', to_char(p_end_dt));
             p_future := l_future;
          END IF;
          p_available_vacant_area := TRUE;
       END IF;
   ELSE
       p_available_vacant_area := TRUE;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      RAISE;
 PNP_DEBUG_PKG.debug ('validate_vacant_area(+)');
END validate_vacant_area;


/*===========================================================================+
 | FUNCTION
 |   check_conversion_type
 |
 | DESCRIPTION
 |   This FUNCTION check for Conversion Rate Type for a given Currency code
 |   at the profile option level AND RETURNs the same, IF it doesn't find one
 |   THEN looks at pn_currencies AND RETURNs Conversion Rate Type.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_curr_code
 |   OUT: none
 |
 | RETURNS: Conversion Type
 |
 | MODIFICATION HISTORY
 |   25-MAR-2002  Mrinal Misra   o Created
 |   28-NOV-2005  sdmahesh       o Added parameter P_ORG_ID
 |                               o Passed org_id to get_profile_value
 +===========================================================================*/
FUNCTION check_conversion_type(p_curr_code IN VARCHAR2,
                               p_org_id IN NUMBER)
RETURN VARCHAR2 IS

   l_prof_optn_curr_type   VARCHAR2(30);
   l_pn_curr_type          VARCHAR2(30);

   CURSOR curr_cursor IS
      SELECT conversion_type
      FROM pn_currencies
      WHERE currency_code = p_curr_code;

BEGIN

   l_prof_optn_curr_type := pn_mo_cache_utils.get_profile_value('PN_CURRENCY_CONV_RATE_TYPE',
                            p_org_id);

   IF l_prof_optn_curr_type IS NOT NULL THEN
      RETURN l_prof_optn_curr_type;
   ELSE
      FOR curr_rec IN curr_cursor LOOP
        l_pn_curr_type := curr_rec.conversion_type;
      END LOOP;
      RETURN l_pn_curr_type;
   END IF;

END check_conversion_type;

/*=============================================================================+
 | PROCEDURE
 |   loctn_assgn_area_update
 |
 | DESCRIPTION
 |   This PROCEDURE creates day tracking for current space assignments IF assignable
 |   area is changed for an assigned location AND updates percent allocated area.
 |   FOR future dated assignments it just updates percent allocated area.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_loc_id,p_assgn_area,p_as_of_dt.
 |   OUT: none
 |
 | MODIFICATION HISTORY
 |   02-MAY-02  Mrinal  o Created
 |   13-MAY-02  Mrinal  o Populated tlempinfo, tlcustinfo variables
 |                        used in row handlers. Removed record type
 |                        var. FROM input param. of UPDATE_ROW.
 |   15-MAY-02  Mrinal  o Corrected passed values of assignment str dt
 |                        AND end dt. in update_row calls.
 |   10-JAN-03  Mrinal  o Removed p_as_of_dt IN param's and added two
 |                        new IN param's p_str_dt,p_end_dt and modified
 |                        procedure to correct/update assignments as per
 |                        Location Day Tracking.
 |   27-aug-03  Kiran   o Corrected the cursor queries to pick up the
 |                        correct assignment records.
 |                        Replaced p_str_dt with l_assgn_str_dt in calls
 |                        to UPDATE_ROW. Populated l_assgn_str_dt conditionally.
 |   10-Oct-03  Daniel  o Created new cursors get_emp_assgn1 and get_cust_assgn2
 |                        to date track space assignment when location
 |                        attribute is changed. Fix for bug # 3174320
 |   10-Nov-03  Daniel  o Removed _all from the declaration for emp_rec
 |                        and cust_rec
 |   14-Nov-03  Satish  o Fix for BUG# 3260023 (Issue 4). Made emp_rec, cust_rec
 |                        as _ALL%ROWTYPE. Modified all 4 cursors to select from
 |                        _ALL tables.
 |   28-Apr-04  vmmehta o Fix for BUG# 3197182. Changed call to
 |                        pn_space_assign_cust_pkg.update_row
 |                        Added parameter x_return_status
 |   18-JUN-04  Mrinal  o Fixed for BUG# 3297892, calculate allocated_area
 |                        based on alloc_area_pct.
 |   13-AUG-04  Anand   o Added NVL for emp/cust_end_date attributes.
 |                        Also replaced all End Of Time occurances with
 |                        g_end_of_time. Bug # 3821420.
 +=============================================================================*/
PROCEDURE loctn_assgn_area_update(p_loc_id           IN NUMBER,
                                  p_assgn_area       IN NUMBER,
                                  p_str_dt           IN DATE,
                                  p_end_dt           IN DATE) IS

   l_new_emp_alloc_pct            PN_SPACE_ASSIGN_EMP.allocated_area_pct%TYPE;
   l_new_cust_alloc_pct           PN_SPACE_ASSIGN_CUST.allocated_area_pct%TYPE;
   l_new_emp_alloc_area           PN_SPACE_ASSIGN_EMP.allocated_area%TYPE;
   l_new_cust_alloc_area          PN_SPACE_ASSIGN_CUST.allocated_area%TYPE;
   l_assgn_str_dt                 DATE;
   l_assgn_end_dt                 DATE;
   l_date                         DATE;
   l_mode                         VARCHAR2(15);
   emp_rec                        pn_space_assign_emp_all%ROWTYPE;
   cust_rec                       pn_space_assign_cust_all%ROWTYPE;
   l_return_status                VARCHAR2(30);

   CURSOR get_emp_assgn(p_loc_id IN NUMBER,
                        p_str_dt IN DATE,
                        p_end_dt IN DATE) IS
      SELECT *
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_loc_id
      AND    emp_assign_start_date <= p_end_dt
      AND    NVL(emp_assign_end_date, g_end_of_time) >= p_str_dt;

   CURSOR get_cust_assgn(p_loc_id IN NUMBER,
                         p_str_dt IN DATE,
                         p_end_dt IN DATE) IS
      SELECT *
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_loc_id
      AND    cust_assign_start_date <= p_end_dt
      AND    NVL(cust_assign_end_date, g_end_of_time) >= p_str_dt;

-- 102403 -- date track space assignment

   CURSOR get_emp_assgn1(p_loc_id IN NUMBER,
                        p_str_dt IN DATE,
                        p_end_dt IN DATE) IS
      SELECT *
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_loc_id
      AND    NVL(emp_assign_end_date, g_end_of_time) >= p_str_dt;

   CURSOR get_cust_assgn1(p_loc_id IN NUMBER,
                         p_str_dt IN DATE,
                         p_end_dt IN DATE) IS
      SELECT *
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_loc_id
      AND    NVL(cust_assign_end_date, g_end_of_time) >= p_str_dt;

-- 102403 -- date track space assignment

BEGIN

-- 102403 -- date track space assignment
   IF nvl(p_end_dt,g_end_of_time) >= g_end_of_time THEN
      OPEN get_emp_assgn1(p_loc_id,p_str_dt, p_end_dt);
      OPEN get_cust_assgn1(p_loc_id,p_str_dt, p_end_dt);
   ELSE
      OPEN get_emp_assgn(p_loc_id,p_str_dt, p_end_dt);
      OPEN get_cust_assgn(p_loc_id,p_str_dt, p_end_dt);
   END IF;

   LOOP

      IF get_emp_assgn1%ISOPEN THEN
         FETCH get_emp_assgn1 INTO emp_rec;
         EXIT WHEN get_emp_assgn1%NOTFOUND;
      ELSIF get_emp_assgn%ISOPEN THEN
         FETCH get_emp_assgn INTO emp_rec;
         EXIT WHEN get_emp_assgn%NOTFOUND;
      END IF;
-- 102403 -- date track space assignment

      PN_SPACE_ASSIGN_EMP_PKG.tlempinfo := emp_rec;
      l_new_emp_alloc_area := ROUND(((NVL(emp_rec.allocated_area_pct,0)*p_assgn_area)/100),2);

      IF emp_rec.emp_assign_start_date >= p_str_dt AND
         NVL(emp_rec.emp_assign_end_date,g_end_of_time) <= p_end_dt THEN
         l_mode := 'CORRECT';
         l_assgn_str_dt := emp_rec.emp_assign_start_date;
      ELSE
         l_mode := 'UPDATE';
         -- 102403 -- date track space assignment
         IF emp_rec.emp_assign_start_date >= p_str_dt AND
            NVL(emp_rec.emp_assign_end_date,g_end_of_time) >= p_end_dt THEN
            l_assgn_str_dt := p_end_dt;
         ELSE
            l_assgn_str_dt := p_str_dt;
         END IF;
      END IF;

      PN_SPACE_ASSIGN_EMP_PKG.UPDATE_ROW(
         X_EMP_SPACE_ASSIGN_ID     =>   emp_rec.emp_space_assign_id,
         X_ATTRIBUTE1              =>   emp_rec.attribute1,
         X_ATTRIBUTE2              =>   emp_rec.attribute2,
         X_ATTRIBUTE3              =>   emp_rec.attribute3,
         X_ATTRIBUTE4              =>   emp_rec.attribute4,
         X_ATTRIBUTE5              =>   emp_rec.attribute5,
         X_ATTRIBUTE6              =>   emp_rec.attribute6,
         X_ATTRIBUTE7              =>   emp_rec.attribute7,
         X_ATTRIBUTE8              =>   emp_rec.attribute8,
         X_ATTRIBUTE9              =>   emp_rec.attribute9,
         X_ATTRIBUTE10             =>   emp_rec.attribute10,
         X_ATTRIBUTE11             =>   emp_rec.attribute11,
         X_ATTRIBUTE12             =>   emp_rec.attribute12,
         X_ATTRIBUTE13             =>   emp_rec.attribute13,
         X_ATTRIBUTE14             =>   emp_rec.attribute14,
         X_ATTRIBUTE15             =>   emp_rec.attribute15,
         X_LOCATION_ID             =>   emp_rec.location_id,
         X_PERSON_ID               =>   emp_rec.person_id,
         X_PROJECT_ID              =>   emp_rec.project_id,
         X_TASK_ID                 =>   emp_rec.task_id,
         X_EMP_ASSIGN_START_DATE   =>   l_assgn_str_dt,
         X_EMP_ASSIGN_END_DATE     =>   emp_rec.emp_assign_end_date,
         X_COST_CENTER_CODE        =>   emp_rec.cost_center_code,
         X_ALLOCATED_AREA_PCT      =>   emp_rec.allocated_area_pct,
         X_ALLOCATED_AREA          =>   l_new_emp_alloc_area,
         X_UTILIZED_AREA           =>   emp_rec.utilized_area,
         X_EMP_SPACE_COMMENTS      =>   emp_rec.emp_space_comments,
         X_ATTRIBUTE_CATEGORY      =>   emp_rec.attribute_category,
         X_LAST_UPDATE_DATE        =>   SYSDATE,
         X_LAST_UPDATED_BY         =>   fnd_global.user_id,
         X_LAST_UPDATE_LOGIN       =>   fnd_global.login_id,
         X_UPDATE_CORRECT_OPTION   =>   l_mode,
         X_CHANGED_START_DATE      =>   l_date);

   END LOOP;

   LOOP

      IF get_cust_assgn1%ISOPEN THEN
         FETCH get_cust_assgn1 INTO cust_rec;
         EXIT WHEN get_cust_assgn1%NOTFOUND;
      ELSIF get_cust_assgn%ISOPEN THEN
         FETCH get_cust_assgn INTO cust_rec;
         EXIT WHEN get_cust_assgn%NOTFOUND;
      END IF;

      PN_SPACE_ASSIGN_CUST_PKG.tlcustinfo := cust_rec;
      l_new_cust_alloc_area := ROUND(((NVL(cust_rec.allocated_area_pct,0)*p_assgn_area)/100),2);

      IF cust_rec.cust_assign_start_date >= p_str_dt AND
         NVL(cust_rec.cust_assign_end_date,g_end_of_time) <= p_end_dt THEN
         l_mode := 'CORRECT';
         l_assgn_str_dt := cust_rec.cust_assign_start_date;
      ELSE
         l_mode := 'UPDATE';
         IF cust_rec.cust_assign_start_date >= p_str_dt AND
            NVL(cust_rec.cust_assign_end_date,g_end_of_time) >= p_end_dt THEN
            l_assgn_str_dt := p_end_dt;
         ELSE
            l_assgn_str_dt := p_str_dt;
         END IF;
      END IF;

      PN_SPACE_ASSIGN_CUST_PKG.UPDATE_ROW(
         X_CUST_SPACE_ASSIGN_ID    =>  cust_rec.CUST_SPACE_ASSIGN_ID,
         X_LOCATION_ID             =>  cust_rec.LOCATION_ID,
         X_CUST_ACCOUNT_ID         =>  cust_rec.CUST_ACCOUNT_ID,
         X_SITE_USE_ID             =>  cust_rec.SITE_USE_ID,
         X_EXPENSE_ACCOUNT_ID      =>  cust_rec.EXPENSE_ACCOUNT_ID,
         X_PROJECT_ID              =>  cust_rec.PROJECT_ID,
         X_TASK_ID                 =>  cust_rec.TASK_ID,
         X_CUST_ASSIGN_START_DATE  =>  l_assgn_str_dt,
         X_CUST_ASSIGN_END_DATE    =>  cust_rec.CUST_ASSIGN_END_DATE,
         X_ALLOCATED_AREA_PCT      =>  cust_rec.ALLOCATED_AREA_PCT,
         X_ALLOCATED_AREA          =>  l_new_cust_alloc_area,
         X_UTILIZED_AREA           =>  cust_rec.UTILIZED_AREA,
         X_CUST_SPACE_COMMENTS     =>  cust_rec.CUST_SPACE_COMMENTS,
         X_ATTRIBUTE_CATEGORY      =>  cust_rec.ATTRIBUTE_CATEGORY,
         X_ATTRIBUTE1              =>  cust_rec.ATTRIBUTE1,
         X_ATTRIBUTE2              =>  cust_rec.ATTRIBUTE2,
         X_ATTRIBUTE3              =>  cust_rec.ATTRIBUTE3,
         X_ATTRIBUTE4              =>  cust_rec.ATTRIBUTE4,
         X_ATTRIBUTE5              =>  cust_rec.ATTRIBUTE5,
         X_ATTRIBUTE6              =>  cust_rec.ATTRIBUTE6,
         X_ATTRIBUTE7              =>  cust_rec.ATTRIBUTE7,
         X_ATTRIBUTE8              =>  cust_rec.ATTRIBUTE8,
         X_ATTRIBUTE9              =>  cust_rec.ATTRIBUTE9,
         X_ATTRIBUTE10             =>  cust_rec.ATTRIBUTE10,
         X_ATTRIBUTE11             =>  cust_rec.ATTRIBUTE11,
         X_ATTRIBUTE12             =>  cust_rec.ATTRIBUTE12,
         X_ATTRIBUTE13             =>  cust_rec.ATTRIBUTE13,
         X_ATTRIBUTE14             =>  cust_rec.ATTRIBUTE14,
         X_ATTRIBUTE15             =>  cust_rec.ATTRIBUTE15,
         X_LAST_UPDATE_DATE        =>  SYSDATE,
         X_LAST_UPDATED_BY         =>  fnd_global.user_id,
         X_LAST_UPDATE_LOGIN       =>  fnd_global.login_id,
         X_UPDATE_CORRECT_OPTION   =>  l_mode,
         X_CHANGED_START_DATE      =>  l_date,
         X_LEASE_ID                =>  cust_rec.LEASE_ID,
         X_RECOVERY_SPACE_STD_CODE =>  cust_rec.RECOVERY_SPACE_STD_CODE,
         X_RECOVERY_TYPE_CODE      =>  cust_rec.RECOVERY_TYPE_CODE,
         X_FIN_OBLIG_END_DATE      =>  cust_rec.FIN_OBLIG_END_DATE,
         X_TENANCY_ID              =>  cust_rec.TENANCY_ID,
         X_RETURN_STATUS           =>  l_return_status);

   END LOOP;
END loctn_assgn_area_update;

/*============================================================================+
--  NAME         : get_area
--  DESCRIPTION  : This PROCEDURE RETURNs the Following for a location
--                 Assignable_area,Usable_area,rentable_area,common_area,
--                 Allocated_area ,Max_capacity,Optimum_capacity Vacancy,
--                 Occupancy_percent etc.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : p_location_id,p_Location_type,p_area_type,
--                          p_as_of_date.
--                 OUT    : p_loc_area ,p_space_area
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  14-MAY-02  Ashish Kumar    o Created
--  30-OCT-02  Satish Tripathi o Access _all table for performance issues.
--  31-OCT-01  graghuna        o added p_as_of_date for Location Date-Effectivity
--  20-OCT-03  ftanudja        o removed nvl from locn tbl filter. 3197410.
--  15-JUN-05  piagrawa        o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                               PN_SPACE_ASSIGN_CUST with _ALL table.
+===========================================================================*/
PROCEDURE  get_area ( p_Location_Id                   IN     NUMBER,
                      p_location_type                 IN     VARCHAR2,
                      p_area_type                     IN     VARCHAR2 ,
                      p_as_of_date                    IN     DATE   ,
                      p_loc_area                         OUT NOCOPY PN_LOCATION_AREA_REC,
                      p_space_area                       OUT NOCOPY PN_SPACE_AREA_REC
                     )
IS
   l_location_type_lookup_code   pn_locations.location_type_lookup_code%type;
   l_assignable_area             NUMBER := 0;
   l_rentable_area               NUMBER := 0;
   l_usable_area                 NUMBER := 0;
   l_common_area                 NUMBER := 0;
   l_secondary_area              NUMBER := 0;
   l_max_capacity                NUMBER := 0;
   l_optimum_capacity            NUMBER := 0;
   l_Allocated_Area              NUMBER := 0;
   l_Allocated_Area_emp          NUMBER := 0;
   l_Allocated_Area_cust         NUMBER := 0;
   l_UtilizedCapacityCust        NUMBER := 0;
   l_UtilizedCapacityEmp         NUMBER := 0;
   l_UtilizedCapacity            NUMBER := 0;
   l_occupancy_percent           NUMBER := 0;
   l_vacant_area                 NUMBER := 0;
   l_vacant_area_percent         NUMBER := 0;
   l_vacancy                     NUMBER := 0;
   l_area_utilized               NUMBER := 0;
   l_date                        DATE  :=  TO_DATE('31/12/4712' , 'DD/MM/YYYY');
   l_as_of_date                  DATE := pnp_util_func.get_as_of_date(p_as_of_date);

   CURSOR c_loc is
      SELECT NVL(SUM(ASSIGNABLE_AREA),0) ,  NVL(SUM(RENTABLE_AREA),0) , NVL(SUM(USABLE_AREA),0)
                     , NVL(SUM(COMMON_AREA),0),NVL(SUM(MAX_CAPACITY),0), NVL(SUM(OPTIMUM_CAPACITY),0)
      FROM   pn_locations_all
      WHERE  Location_Type_Lookup_Code  =  l_location_type_lookup_code
      AND    Status                     =  'A'
      AND    l_as_of_date BETWEEN active_start_date AND active_end_date
      START WITH        Location_Id = p_Location_Id
      CONNECT BY PRIOR  Location_Id = Parent_Location_Id
     AND l_as_of_date between prior active_start_date and    --ASHISH
     PRIOR active_end_date;

   CURSOR c_space_emp is
      SELECT NVL(SUM(Allocated_Area), 0),NVL(SUM(UTILIZED_AREA),0)
      FROM   PN_SPACE_ASSIGN_EMP_ALL
      WHERE  emp_assign_start_date            <= l_as_of_date
      AND    NVL(emp_assign_end_date, l_date) >= l_as_of_date
      AND    Location_Id IN (SELECT Location_Id
                             FROM   pn_locations_all
                             WHERE  Location_Type_Lookup_Code  =  l_location_type_lookup_code
                             AND    Status                     =  'A'
                             AND    l_as_of_date BETWEEN active_start_date AND active_end_date
                             START WITH        Location_Id  =  p_Location_Id
                             CONNECT BY PRIOR  Location_Id  =  Parent_Location_Id
                             AND l_as_of_date between prior active_start_date and    --ASHISH
                             PRIOR active_end_date
                             );

   CURSOR c_space_cust is
      SELECT NVL(SUM(Allocated_Area), 0),NVL(SUM(UTILIZED_AREA),0)
      FROM   PN_SPACE_ASSIGN_CUST_ALL
      WHERE  cust_assign_start_date            <= l_as_of_date
      AND    NVL(cust_assign_end_date, l_date) >= l_as_of_date
      AND    Location_Id IN (SELECT Location_Id
                             FROM   pn_locations_all
                             WHERE  Location_Type_Lookup_Code  =  l_location_type_lookup_code
                             AND    Status                     =  'A'
                             AND    l_as_of_date BETWEEN active_start_date AND active_end_date
                             START WITH        Location_Id  =  p_Location_Id
                             CONNECT BY PRIOR  Location_Id  =  Parent_Location_Id
                             AND l_as_of_date between prior active_start_date and    --ASHISH
                             PRIOR active_end_date
                            );

BEGIN
   IF p_location_type IN('BUILDING', 'FLOOR', 'OFFICE') THEN
       l_location_type_lookup_code := 'OFFICE' ;
   ElSIF p_location_type IN('LAND', 'PARCEL','SECTION') THEN
       l_location_type_lookup_code := 'SECTION' ;
   END IF;
      open c_loc ;
      fetch  c_loc INTO l_assignable_area,l_rentable_area ,l_usable_area,
                        l_common_area,l_max_capacity    ,l_optimum_capacity ;
      IF c_loc%notfound THEN
          NULL;
      end IF;
      close c_loc;

      IF p_area_type in ('VACANT_AREA','VACANT_AREA_PERCENT','UTILIZED_CAPACITY','VACANCY','OCCUPANCY_PERCENT',
                      'AREA_UTILIZED') OR p_area_type is NULL  THEN
              Open c_space_emp;
        fetch c_space_emp INTO l_Allocated_Area_Emp,l_UtilizedCapacityEmp;
        IF c_space_emp%notfound THEN
           NULL;
        end IF;
        close c_space_emp;

        Open c_space_cust;
        fetch c_space_cust INTO l_Allocated_Area_Cust,l_UtilizedCapacityCust;
        IF c_space_cust%notfound THEN
           NULL;
        end IF;

        l_Allocated_Area := l_Allocated_Area_Emp + l_Allocated_Area_Cust;
        l_vacant_area  := l_assignable_area - l_allocated_area;
        l_utilizedCapacity := l_UtilizedCapacityEmp + l_UtilizedCapacityCust;
        l_vacancy  := round((l_max_capacity - l_utilizedCapacity), 2);
     END IF;
        l_secondary_area   := round((l_rentable_area - l_usable_area), 2);
        IF (l_Assignable_Area = 0) THEN
          l_vacant_area_percent := 0;
       ELSE
         l_vacant_area_percent:=  (l_Vacant_Area * 100/l_Assignable_Area);
       END IF;
       IF (l_max_capacity = 0) THEN
          l_occupancy_percent:=0;
       ELSE
         l_occupancy_percent:= (l_utilizedCapacity *100/l_max_capacity);
       END IF;
       IF ((l_rentable_area = 0) OR (l_utilizedCapacity = 0)) THEN
           l_area_utilized:= 0;
       ELSE
            l_area_utilized:= (l_rentable_area/l_utilizedCapacity);
       END IF;

       p_loc_area.secondary_area             := l_secondary_area;
       p_loc_area.assignable_area            := l_assignable_area;
       p_loc_area.rentable_area              := l_rentable_area ;
       p_loc_area.usable_area                := l_usable_area;
       p_loc_area.common_area                := l_common_area ;
       p_loc_area.max_capacity               := l_max_capacity;
       p_loc_area.optimum_capacity           := l_optimum_capacity;
       p_space_area.allocated_area           := l_allocated_area ;
       p_space_area.allocated_area_emp       := l_allocated_area_emp;
       p_space_area.allocated_area_cust      := l_allocated_area_cust;
       p_space_area.vacant_area_percent      := l_vacant_area_percent;
       p_space_area.utilizedCapacityEmp      := l_utilizedCapacityEmp;
       p_space_area.utilizedCapacityCust     := l_utilizedCapacityCust;
       p_space_area.utilizedCapacity         := l_utilizedCapacity;
       p_space_area.occupancy_percent        := l_occupancy_percent;
       p_space_area.vacant_area              := l_vacant_area;
       p_space_area.vacancy                  := l_vacancy;
       p_space_area.area_utilized            := l_area_utilized;

END get_area;

/*============================================================================+
--  NAME         : validate_asignable_area
--  DESCRIPTION  : This FUNCTION checks IF Assignable_Area is greater than the
--                 Allocated_Area irrespective of the date.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : Location_Id, Location_Type, Assignable_Area
--  RETURNS      : BOOLEAN
--  REFERENCE    :
--  HISTORY      :
--  29-MAY-02  Kiran Hegde   o Created - Fix for Bug#2384573
--  15-JUN-05  piagrawa      o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                             PN_SPACE_ASSIGN_CUST with _ALL table.
 +===========================================================================*/

FUNCTION validate_assignable_area ( p_Location_Id          IN    NUMBER,
                                    p_Location_Type        IN    VARCHAR2,
                                    p_Assignable_Area      IN    NUMBER )
RETURN BOOLEAN IS

   v_location_rec                        pnp_util_func.PN_LOCATION_AREA_REC;
   v_space_allocation_rec                pnp_util_func.PN_SPACE_AREA_REC;
   INVALID_ASSIGNABLE_AREA                EXCEPTION;

   CURSOR start_date_cur IS
      SELECT emp_assign_start_date
      FROM   pn_space_assign_emp_all
      WHERE  location_id = p_Location_Id
      UNION
      SELECT cust_assign_start_date
      FROM   pn_space_assign_cust_all
      WHERE  location_id = p_Location_Id
      ORDER BY 1;

BEGIN

for emp_cust_date in start_date_cur LOOP

   get_area ( p_Location_Id    => p_Location_Id,
              p_location_type  => p_Location_Type,
              p_area_type      => NULL,
              p_as_of_date     => emp_cust_date.emp_assign_start_date,
              p_loc_area       => v_location_rec,
              p_space_area     => v_space_allocation_rec );
End Loop;

RETURN TRUE;

EXCEPTION

WHEN INVALID_ASSIGNABLE_AREA THEN
   RETURN FALSE;

END validate_assignable_area;

/*===========================================================================+
 | FUNCTION
 |    validate_term_template
 |
 | DESCRIPTION
 |    This FUNCTION validates term template for all the reqiured data to create
 |    payment term, in Index Rent AND Variable Rent modules.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |    None.
 |
 | ARGUMENTS:
 |    IN: p_term_temp_id, p_lease_cls_code
 |    OUT: none
 |
 | RETURNS: BOOLEAN
 |
 | MODIFICATION HISTORY
 |    15-JUL-2002  Mrinal Misra    o Created.
 |    30-OCT-2002  Satish Tripathi o Access _all table for performance issues.
 |    27-JAN-2003  Pooja Sidhu     o Added check for distribution accounts.
 |    22-AUG-2003  Anand Tuppad    o Changed the procedure to validate against
 |                                   just 3 fields and rest validation will be
 |                                   done against term at the time of Approve.
 |    13-APR-2004  Anand Tuppad   o Changed the cursor to select only required
 |                                  cols and not all cols(ie removed  *)
 |    22-SEP-2008  kkorada        o Modified the function to exclude customer information
 |                                  while validating the term template. bug#6660956

 +===========================================================================*/

FUNCTION validate_term_template(p_term_temp_id   IN    NUMBER,
                                p_lease_cls_code IN    VARCHAR2)
RETURN BOOLEAN IS

   CURSOR term_temp_type_cur(p_term_temp_id IN NUMBER) IS
      SELECT term_template_type
      FROM   pn_term_templates_all
      WHERE  term_template_id = p_term_temp_id;

   CURSOR term_temp_bill_cur(p_term_temp_id IN NUMBER) IS
      SELECT payment_purpose_code,
             payment_term_type_code,
             currency_code,
             customer_id,
             customer_site_use_id,
             ap_ar_term_id,
             cust_trx_type_id
      FROM   pn_term_templates_all
      WHERE  term_template_id = p_term_temp_id;

   CURSOR term_temp_pay_cur(p_term_temp_id IN NUMBER) IS
      SELECT payment_purpose_code,
             payment_term_type_code,
             currency_code,
             ap_ar_term_id,
             vendor_id,
             vendor_site_id
      FROM   pn_term_templates_all
      WHERE  term_template_id = p_term_temp_id;

BEGIN

   FOR term_temp_type_rec IN term_temp_type_cur(p_term_temp_id) LOOP
      IF term_temp_type_rec.term_template_type = 'BILLING'
      THEN
         FOR template IN term_temp_bill_cur(p_term_temp_id)
         LOOP
           IF (template.payment_purpose_code IS NULL OR
               template.payment_term_type_code IS NULL OR
               template.currency_code IS NULL OR
               --template.customer_id IS NULL OR   commented for bug 6660956
               --template.customer_site_use_id IS NULL OR   commented for bug 6660956
               template.ap_ar_term_id IS NULL OR
               template.cust_trx_type_id IS NULL) THEN
             RETURN FALSE;
           END IF;
         END LOOP;
      ELSIF term_temp_type_rec.term_template_type = 'PAYMENT'
      THEN
         FOR template IN term_temp_pay_cur(p_term_temp_id)
         LOOP
           IF (template.payment_purpose_code IS NULL OR
               template.payment_term_type_code IS NULL OR
               template.currency_code IS NULL OR
               template.ap_ar_term_id IS NULL OR
               template.vendor_id IS NULL OR
               template.vendor_site_id IS NULL ) THEN
             RETURN FALSE;
           END IF;
         END LOOP;
      END IF;

   END LOOP;

   RETURN TRUE;

END validate_term_template;

/*===========================================================================+
 | FUNCTION
 |    get_term_template_name
 |
 | DESCRIPTION
 |    This FUNCTION RETURNs Term Template Name for a given Term Template Id
 |    FROM pn_term_templates.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_term_temp_id
 |
 |              OUT:
 |                    None
 |
 | RETURNS    : Term Template Name
 |
 | NOTES      : None
 |
 | MODIFICATION HISTORY
 |
 |     17-JUL-2002  Mrinal Misra   Created
 |     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
 +===========================================================================*/

FUNCTION get_term_template_name (p_term_temp_id IN NUMBER)

RETURN VARCHAR2 IS

    l_term_temp_name        pn_term_templates.name%type;

BEGIN

    SELECT name
    INTO   l_term_temp_name
    FROM   pn_term_templates_all
    WHERE  term_template_id = p_term_temp_id;

    RETURN(l_term_temp_name);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RAISE;

END get_term_template_name;


/*===========================================================================+
 | PROCEDURE
 |   get_space_assignments
 |
 | DESCRIPTION
 |   This PROCEDURE will get all the assigments for a location. IF the location is
 |   a building THEN it will get assignments for all the offices in that building
 |   for the supplied date range.
 |
 | | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id,p_Location_type,p_start_date,p_end_date,
 |   OUT: x_space_assign_cust_tbl ,x_space_assign_emp_tbl
 |
 | MODIFICATION HISTORY
 |  26-JUL-2002  graghuna o Created
 |  27-aug-2003  kkhegde  o Changed the cursor queries to pick all the ovelapping
 |                          assignments for given start-end dates.
 |  16-MAR-2007  CSRIPERU o Bug#5959164. Modified Cursors pn_space_assign_cust_cursor
 |                          and pn_space_assign_emp_cursor to ignore allocated_area while
 |                          checking for active assignments to a location.
 +===========================================================================*/


PROCEDURE Get_space_assignments
    ( p_location_id           IN  NUMBER,
      p_location_type         IN  VARCHAR2 ,
      p_start_date            IN  DATE,
      p_end_date              IN  DATE,
      x_space_assign_cust_tbl OUT NOCOPY  SPACE_ASSIGNMENT_TBL,
      x_space_assign_emp_tbl  OUT NOCOPY  SPACE_ASSIGNMENT_TBL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_return_message        OUT NOCOPY VARCHAR2
    )
IS
   CURSOR pn_space_assign_cust_cursor  IS
    SELECT  *
    FROM    pn_space_assign_cust_all
    WHERE   location_id IN
            ( SELECT location_id
              FROM pn_locations_all
              START WITH  location_id = p_location_id
              CONNECT BY PRIOR location_id = parent_location_id )
    AND     NVL(cust_assign_end_date,g_end_of_time) >= p_start_date
    AND     cust_assign_start_date <= NVL(p_end_date, g_end_of_time);
--Bug#5959164    AND     NVL(allocated_area,0) > 0;

   CURSOR pn_space_assign_emp_cursor  IS
    SELECT  *
    FROM    pn_space_assign_emp_all
    WHERE   location_id IN
            ( SELECT location_id
              FROM pn_locations_all
              START WITH  location_id = p_location_id
              CONNECT BY PRIOR location_id = parent_location_id )
    AND     NVL(emp_assign_end_date,g_end_of_time) >= p_start_date
    AND     emp_assign_start_date <= NVL(p_end_date, g_end_of_time);
--Bug#5959164    AND     NVL(allocated_area,0) > 0;

    l_index INTEGER := 0;
    l_space_assign_cust_tbl SPACE_ASSIGNMENT_TBL;
    l_space_assign_emp_tbl  SPACE_ASSIGNMENT_TBL;
    l_api_name VARCHAR2(50) := 'pnp_util_func.get_space_assignments';

BEGIN

     PNP_DEBUG_PKG.DEBUG('----------------------------------');
     PNP_DEBUG_PKG.DEBUG('pnp_util_func.get_space_assignments (+)');
     PNP_DEBUG_PKG.DEBUG('Get space assignments:INPUT');
     PNP_DEBUG_PKG.DEBUG('----------------------------------');
     PNP_DEBUG_PKG.DEBUG('Location id     : '   || p_location_id);
     PNP_DEBUG_PKG.DEBUG('Start Date      : ' || p_start_date);
     PNP_DEBUG_PKG.DEBUG('End Date        : ' || p_end_date);
     PNP_DEBUG_PKG.DEBUG('----------------------------------');



    FOR space_assign_cust_rec in pn_space_assign_cust_cursor
    LOOP
        l_index := l_index + 1;
        PNP_DEBUG_PKG.DEBUG('Assigning Cust data index : '|| l_index);
        l_space_assign_cust_tbl(l_index).cust_account_id :=
            space_assign_cust_rec.cust_account_id ;
        l_space_assign_cust_tbl(l_index).location_id :=
            space_assign_cust_rec.location_id ;
        l_space_assign_cust_tbl(l_index).assignment_id :=
            space_assign_cust_rec.cust_space_assign_id;
        l_space_assign_cust_tbl(l_index).assign_start_date :=
            space_assign_cust_rec.cust_assign_start_date;
        l_space_assign_cust_tbl(l_index).assign_end_date :=
            NVL(space_assign_cust_rec.cust_assign_end_date,pnp_util_func.g_end_of_time);
        l_space_assign_cust_tbl(l_index).allocated_area :=
            space_assign_cust_rec.allocated_area;
        l_space_assign_cust_tbl(l_index).allocated_area_pct :=
            space_assign_cust_rec.allocated_area_pct;
        l_space_assign_cust_tbl(l_index).utilized_area :=
            space_assign_cust_rec.utilized_area;
        l_space_assign_cust_tbl(l_index).project_id :=
            space_assign_cust_rec.project_id;
        l_space_assign_cust_tbl(l_index).task_id :=
            space_assign_cust_rec.task_id;
        l_space_assign_cust_tbl(l_index).org_id :=
            space_assign_cust_rec.org_id;
        l_space_assign_cust_tbl(l_index).lease_id :=
            space_assign_cust_rec.lease_id;

    END LOOP;

    x_space_assign_cust_tbl := l_space_assign_cust_tbl;


    FOR space_assign_emp_rec in pn_space_assign_emp_cursor
    LOOP
        l_index := l_index + 1;
        PNP_DEBUG_PKG.DEBUG('Assigning emp data index : '|| l_index);
        l_space_assign_emp_tbl(l_index).person_id :=
            space_assign_emp_rec.person_id ;
        l_space_assign_emp_tbl(l_index).location_id :=
            space_assign_emp_rec.location_id ;
        l_space_assign_emp_tbl(l_index).assignment_id :=
            space_assign_emp_rec.emp_space_assign_id;
        l_space_assign_emp_tbl(l_index).assign_start_date :=
            space_assign_emp_rec.emp_assign_start_date;
        l_space_assign_emp_tbl(l_index).assign_end_date :=
            NVL(space_assign_emp_rec.emp_assign_end_date,pnp_util_func.g_end_of_time);
        l_space_assign_emp_tbl(l_index).allocated_area :=
            space_assign_emp_rec.allocated_area;
        l_space_assign_emp_tbl(l_index).allocated_area_pct :=
            space_assign_emp_rec.allocated_area_pct;
        l_space_assign_emp_tbl(l_index).utilized_area :=
            space_assign_emp_rec.utilized_area;
        l_space_assign_emp_tbl(l_index).project_id :=
            space_assign_emp_rec.project_id;
        l_space_assign_emp_tbl(l_index).task_id :=
            space_assign_emp_rec.task_id;
        l_space_assign_emp_tbl(l_index).org_id :=
            space_assign_emp_rec.org_id;

    END LOOP;
       x_space_assign_emp_tbl := l_space_assign_emp_tbl;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    PNP_DEBUG_PKG.DEBUG('pnp_util_func.get_space_assignments (-)');

EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
        fnd_message.set_token('ERR_MSG',l_api_name||'='|| sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PNP_DEBUG_PKG.DEBUG('OTHERS EXCEPTION');


END get_space_assignments;


/*===========================================================================+
--  NAME         : validate_assignments_for_date
--  DESCRIPTION  : This routine will check IF there are any assignments within
--                 the specified dates for the locattion id. IF there are any
--                 assignments for that locations between the date range
--                 specified, the PROCEDURE RETURNs an error.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : p_location_id,p_start_date,p_end_date,
--                 OUT    : x_return_status ,x_return_message
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  26-JUL-02  graghuna         o Created.
--  30-OCT-02  Satish Tripathi  o Access _all table for performance issues.
--  06-JAN-03  Mrinal Misra     o Removed tokens from
--                                PN_INVALID_DATE_EFFECTIVITY mesg.
--  18-FEB-03  Mrinal Misra     o Made two cursors to be called in
--                                conditionally for change in start date or
--                                end date of location.
--  07-APR-04  abanerje         o Added NVL to end dates for cursors
--                                validate_start_date_cursor and
--                                validate_end_date_cursor. Bug #3486311
--  15-JUN-05  piagrawa         o Bug 4307795 - Replaced PN_SPACE_ASSIGN_EMP,
--                                PN_SPACE_ASSIGN_CUST with _ALL table.
--  16-MAR-07  csriperu         o Bug#5959164. Modified Cursors validate_start_date_cursor
--                                and validate_end_date_cursor to ignore allocated_area and
--                                allocated_area_pct while checking for active assignments
--                                to a location.
 +===========================================================================*/
PROCEDURE Validate_assignment_for_date (
    p_location_id IN NUMBER,
    p_start_date       IN DATE,
    p_end_date         IN DATE,
    p_start_date_old   IN DATE,
    p_end_date_old     IN DATE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_return_message   OUT NOCOPY VARCHAR2
    )
IS
    l_space_assign_cust_tbl SPACE_ASSIGNMENT_TBL;
    l_space_assign_emp_tbl  SPACE_ASSIGNMENT_TBL;
    l_api_name              VARCHAR2(50) := 'pnp_util_func.Validate_assignemnt_for_date ';
    USER_DEF_ERROR          Exception;

    CURSOR validate_start_date_cursor IS
    SELECT 'x'
    FROM   DUAL
    WHERE EXISTS (SELECT 'x'
                  FROM   pn_space_assign_emp_all
                  WHERE  location_id IN (SELECT location_id
                                         FROM   pn_locations_all
                                         START WITH location_id = p_location_id
                                         CONNECT BY PRIOR location_id = parent_location_id )
 --Bug#5959164                 AND allocated_area > 0
 --Bug#5959164                  AND allocated_area_pct > 0
                  AND emp_assign_start_date < p_start_date
                  AND NVL(emp_assign_end_date,to_date('12/31/4712','mm/dd/yyyy'))   >= p_start_date_old
                  UNION
                  SELECT 'x'
                  FROM   pn_space_assign_cust_all
                  WHERE  location_id IN (SELECT location_id
                                         FROM   pn_locations_all
                                         START WITH location_id = p_location_id
                                         CONNECT BY PRIOR location_id = parent_location_id )
 --Bug#5959164                AND allocated_area > 0
 --Bug#5959164                  AND allocated_area_pct > 0
                  AND cust_assign_start_date < p_start_date
                  AND NVL(cust_assign_end_date,to_date('12/31/4712','mm/dd/yyyy'))   >= p_start_date_old);

    CURSOR validate_end_date_cursor IS
    SELECT 'x'
    FROM   DUAL
    WHERE EXISTS (SELECT 'x'
                  FROM   pn_space_assign_emp_all
                  WHERE  location_id IN (SELECT location_id
                                         FROM   pn_locations_all
                                         START WITH location_id = p_location_id
                                         CONNECT BY PRIOR location_id = parent_location_id )
 --Bug#5959164                  AND allocated_area > 0
 --Bug#5959164                  AND allocated_area_pct > 0
                  AND NVL(emp_assign_end_date,to_date('12/31/4712','mm/dd/yyyy'))   > p_end_date
                  AND emp_assign_start_date <= p_end_date_old
                  UNION
                  SELECT 'x'
                  FROM   pn_space_assign_cust_all
                  WHERE  location_id IN (SELECT location_id
                                         FROM   pn_locations_all
                                         START WITH location_id = p_location_id
                                         CONNECT BY PRIOR location_id = parent_location_id )
 --Bug#5959164                  AND allocated_area > 0
 --Bug#5959164                  AND allocated_area_pct > 0
                  AND NVL(cust_assign_end_date,to_date('12/31/4712','mm/dd/yyyy'))   > p_end_date AND
                      cust_assign_start_date <= p_end_date_old);

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     PNP_DEBUG_PKG.log('----------------------------------');
     PNP_DEBUG_PKG.log('pnp_util_func.validate_assignment_for_date (+)');
     PNP_DEBUG_PKG.log('Validate Assignment for date:INPUT');
     PNP_DEBUG_PKG.log('----------------------------------');
     PNP_DEBUG_PKG.log('Location id     : '   || p_location_id);
     PNP_DEBUG_PKG.log('Start Date      : ' || p_start_date);
     PNP_DEBUG_PKG.log('End Date        : ' || p_end_date);
     PNP_DEBUG_PKG.log('----------------------------------');

    IF p_start_date > p_start_date_old THEN

       FOR validate_start_date_rec in validate_start_date_cursor  LOOP
          x_return_status := FND_API.G_RET_STS_ERROR;
          Raise USER_DEF_ERROR;
          EXIT;
       END LOOP;

    END IF;

    IF p_end_date < p_end_date_old THEN

       FOR validate_end_date_rec in validate_end_date_cursor  LOOP
          x_return_status := FND_API.G_RET_STS_ERROR;
          Raise USER_DEF_ERROR;
          EXIT;
       END LOOP;

    END IF;

    PNP_DEBUG_PKG.DEBUG('pnp_util_func.validate_assignment_for_date (-)');

EXCEPTION

    WHEN USER_DEF_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('PN','PN_INVALID_DATE_EFFECTIVITY');
       PNP_DEBUG_PKG.log('Assignment found for dates');

    WHEN OTHERS THEN
        fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
        fnd_message.set_token('ERR_MSG',l_api_name||'='|| sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PNP_DEBUG_PKG.log('OTHERS ERROR');

END validate_assignment_for_date;


/*===========================================================================+
 | PROCEDURE
 |   validate_assignable_area
 |
 | DESCRIPTION
 |    This routine validates to make sure that the change in assignable area
 |    does not change exisiting allocations. IF the new assignable area
 |    is less than the area that is currently being allocated in the specified
 |    date range, the PROCEDURE RETURNs an error.
 |
 | | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 |    Get_space_Assignments
 |
 | ARGUMENTS:
 |   IN:  p_location_id,,p_start_date,p_end_date,
 |   OUT: x_return_status ,x_return_message
 |
 | MODIFICATION HISTORY
 |   26-JUL-2002      graghuna o Created
 +===========================================================================*/

PROCEDURE Validate_assignable_area (
    p_location_id      IN NUMBER,
    p_assignable_area  IN NUMBER,
    p_start_date       IN DATE,
    p_end_date         IN DATE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_return_message   OUT NOCOPY VARCHAR2
    )
IS
    l_space_assign_cust_tbl SPACE_ASSIGNMENT_TBL;
    l_space_assign_emp_tbl  SPACE_ASSIGNMENT_TBL;
    l_space_assign_tbl      SPACE_ASSIGNMENT_TBL;
    l_total_Area            NUMBER := 0;
    l_index                 NUMBER := 0;
    l_api_name              VARCHAR2(50):= 'pnp_util_func.Validate_assignable_area';

    UNEXPECTED_ERROR EXCEPTION;
BEGIN

     PNP_DEBUG_PKG.log('----------------------------------');
     PNP_DEBUG_PKG.log('pnp_util_func.validate_assignable_area (+)');
     PNP_DEBUG_PKG.log('Validate Assignable area: INPUT');
     PNP_DEBUG_PKG.log('----------------------------------');
     PNP_DEBUG_PKG.log('Location id     : '   || p_location_id);
     PNP_DEBUG_PKG.log('Start Date      : ' || p_start_date);
     PNP_DEBUG_PKG.log('End Date        : ' || p_end_date);
     PNP_DEBUG_PKG.log('Assignable Area : ' || p_assignable_area);
     PNP_DEBUG_PKG.log('----------------------------------');
     PNP_DEBUG_PKG.log('Calling get space assignments');

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     Get_space_assignments (
         p_location_id           => p_location_id,
         p_start_date            => p_start_date,
         p_end_date              => p_end_date,
         x_space_assign_cust_tbl => l_space_assign_cust_tbl,
         x_space_assign_emp_tbl  => l_space_assign_emp_tbl,
         x_return_status         => x_return_status,
         x_return_message        => x_return_message
     );

     IF not(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          PNP_DEBUG_PKG.log('Error in get space_assignments');
          Raise unexpected_error;
     END IF;

     IF l_space_assign_cust_tbl.count > 0 THEN
     FOR I in l_space_assign_cust_tbl.FIRST .. l_space_assign_cust_tbl.LAST LOOP
        l_index := NVL(l_index,0) + 1;
        PNP_DEBUG_PKG.log('Assigning values to l_space_assign_tbl : '||l_index);
        l_space_assign_tbl(l_index).assignment_id :=
            l_space_assign_cust_tbl(i).assignment_id;
        l_space_assign_tbl(l_index).assign_start_date :=
            l_space_assign_cust_tbl(i).assign_start_date;
        l_space_assign_tbl(l_index).assign_end_date :=
            l_space_assign_cust_tbl(i).assign_end_date;
        l_space_assign_tbl(l_index).allocated_area :=
            l_space_assign_cust_tbl(i).allocated_area;
        l_space_assign_tbl(l_index).allocated_area_pct :=
            l_space_assign_cust_tbl(i).allocated_area_pct;
        l_space_assign_tbl(l_index).utilized_area :=
            l_space_assign_cust_tbl(i).utilized_area;
     END LOOP;
     END IF;

     IF l_space_Assign_emp_tbl.count > 0 THEN
     FOR I in l_space_assign_emp_tbl.FIRST .. l_space_assign_emp_tbl.LAST LOOP
        PNP_DEBUG_PKG.log('Assigning values to l_space_assign_tbl for emp: '||l_index);
        l_index := NVL(l_index,1) + 1;
        l_space_assign_tbl(l_index).assignment_id :=
            l_space_assign_emp_tbl(i).assignment_id;
        l_space_assign_tbl(l_index).assign_start_date :=
            l_space_assign_emp_tbl(i).assign_start_date;
        l_space_assign_tbl(l_index).assign_end_date :=
            l_space_assign_emp_tbl(i).assign_end_date;
        l_space_assign_tbl(l_index).allocated_area :=
            l_space_assign_emp_tbl(i).allocated_area;
        l_space_assign_tbl(l_index).allocated_area_pct :=
            l_space_assign_emp_tbl(i).allocated_area_pct;
        l_space_assign_tbl(l_index).utilized_area :=
            l_space_assign_emp_tbl(i).utilized_area;
     END LOOP;
     END IF;


     IF l_space_assign_tbl.count > 0 THEN
      FOR I in l_space_assign_tbl.FIRST .. l_space_assign_tbl.LAST LOOP
          L_total_area :=0;
          PNP_DEBUG_PKG.log('I := ' ||i|| ' start_date ' || l_space_assign_tbl(i).assign_start_date || ' end date '|| l_space_assign_tbl(i).assign_end_date);

          FOR J in l_space_assign_tbl.FIRST .. l_space_assign_tbl.LAST LOOP

          PNP_DEBUG_PKG.log('J := ' ||J|| ' start_date ' || l_space_assign_tbl(j).assign_start_date || ' end date '|| l_space_assign_tbl(j).assign_end_date);

              IF l_space_assign_Tbl(j).assign_start_date =
                 l_space_assign_tbl(i).assign_start_date   AND
                 l_space_assign_Tbl(j).assign_end_date =
                 l_space_assign_tbl(i).assign_end_date
              THEN
                 l_total_area := l_total_area + l_space_assign_tbl(j).allocated_area;
              ElSIF l_space_assign_Tbl(j).assign_start_date <=
                 l_space_assign_tbl(i).assign_start_date   AND
                 l_space_assign_Tbl(j).assign_end_date >
                 l_space_assign_tbl(i).assign_start_date
              THEN

                 l_total_area := l_total_area + l_space_assign_tbl(j).allocated_area;
                 PNP_DEBUG_PKG.log('Start date range : total : ' || l_total_area);
              ElSIF l_space_assign_Tbl(j).assign_start_date <
                 l_space_assign_tbl(i).assign_end_date   AND
                 l_space_assign_Tbl(j).assign_end_date >=
                 l_space_assign_tbl(i).assign_end_date
              THEN

                 PNP_DEBUG_PKG.log('end date range : total : ' || l_total_area);
                 l_total_area := l_total_area + l_space_assign_tbl(j).allocated_area;
              END IF;

           END LOOP;

       END LOOP;

     END IF;

     PNP_DEBUG_PKG.log('pnp_util_func.validate_assignable_area (-)');
EXCEPTION


    WHEN  UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        PNP_DEBUG_PKG.log('UNEXPECTED ERROR');

    WHEN OTHERS THEN
        fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
        fnd_message.set_token('ERR_MSG',l_api_name||'='|| sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PNP_DEBUG_PKG.log('OTHERS ERROR');

END validate_assignable_area;





/*===========================================================================+
 | PROCEDURE
 |   validate_date_assignable_area
 |
 | DESCRIPTION
 |   This routine is a validation PROCEDURE that will be executed before the
 |   Location Date-Effectivity changes AND the assignable area changes are commited.
 |
 |   While changing the active_start_date or the active_end_date of any location
 |   we need to make sure that space is not already assigned or there is not
 |   future assigment. In case of change to the assignment area we need to make
 |   sure that the current AND future assignments are able to handle the change in
 |   assignable_area of the location
 |
 | | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_location_id,p_Location_type,p_start_date,p_end_date,
          p_assignable_area
 |   OUT: x_return_status ,x_return_message
 |
 | MODIFICATION HISTORY
 |   26-JUL-2002  graghuna        o Created
 |   30-OCT-2002  Satish Tripathi o Access _all table for performance issues.
 |   14-JAN-2003  Mrinal Misra    o Assigned dates conditionally to Validate_assignment_for_date
 |                                  for UPDATE/CORRECT mode.
 +===========================================================================*/


PROCEDURE validate_date_assignable_area
    ( p_location_id                   IN     NUMBER,
      p_location_type                 IN     VARCHAR2,
      p_start_date                    IN     DATE,
      p_end_date                      IN     DATE,
      p_active_start_date_old         IN     DATE,
      p_active_end_date_old           IN     DATE,
      p_change_mode                   IN     VARCHAR2 ,
      p_assignable_area               IN     NUMBER   ,
      x_return_status                    OUT NOCOPY VARCHAR2,
      x_return_message                   OUT NOCOPY VARCHAR2
    )
IS


    l_space_assign_tbl    SPACE_ASSIGNMENT_TBL;
    l_api_name            VARCHAR2(50) := 'pnp_util_func.validate_date_assignable_area';
    l_filename            VARCHAR2(40) := 'Date_EFF'||to_char(SYSDATE,'DDMMYYHHMMSS');

    UNEXPECTED_ERROR      Exception;
    l_str_date_old        DATE;

    CURSOR pn_location_cursor IS
    SELECT *
    FROM   pn_locations_all
    WHERE  location_id = p_location_id
    AND    active_start_date = p_Active_start_date_old
    AND    active_end_date = p_active_end_date_old;

BEGIN
    -- Remove after debug
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    PNP_DEBUG_PKG.log('---------------------------------------');
    PNP_DEBUG_PKG.log('pnp_util_func.validate_date_assignable_area (+)');
    PNP_DEBUG_PKG.log('Validate date assignable_area : INPUT PARAMS');
    PNP_DEBUG_PKG.log('---------------------------------------');
    PNP_DEBUG_PKG.log('Location id     : ' || p_location_id);
    PNP_DEBUG_PKG.log('Location Type   : ' || p_location_type);
    PNP_DEBUG_PKG.log('Start Date      : ' || p_start_date);
    PNP_DEBUG_PKG.log('End Date        : ' || p_end_date);
    PNP_DEBUG_PKG.log('Assignable Area : ' || p_assignable_area);
    PNP_DEBUG_PKG.log('Start date old  : ' || p_active_start_date_old);
    PNP_DEBUG_PKG.log('End date old    : ' || p_active_end_date_old);
    PNP_DEBUG_PKG.log('---------------------------------------');

    FOR p_location_rec in pn_location_cursor LOOP

        IF  NVL(p_location_rec.active_start_date,g_start_of_time) < p_start_date OR
                NVL(p_location_rec.active_end_date,g_end_of_time)  > p_end_date
        THEN

            /*************************
            * validate assignemts for that location IF the
            * location is an OFFICE or a SECTION. IF the location
            * is at any level above the office or a section THEN
            * drill down to the bottom most level to see IF there
            * are any crrent valid assignments for those locations
            * Valid locations are locations WHERE the allocated_area is
            * NULL or zero AND allocated percent is NULL or zero
            *************************/

            IF p_change_mode = 'UPDATE' THEN
               l_str_date_old := p_start_date;
            ELSE
               l_str_date_old := p_active_start_date_old;
            END IF;

            PNP_DEBUG_PKG.log('Calling PROCEDURE Validate_assignment_for_date');
            Validate_assignment_for_date
                ( p_location_id      => p_location_id,
                  p_start_date       => p_start_date,
                  p_end_date         => p_end_date,
                  p_start_date_old   => l_str_date_old,
                  p_end_date_old     => p_active_end_date_old,
                  x_return_status    => x_return_status,
                  x_return_message   => x_return_message);

            IF not(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                PNP_DEBUG_PKG.log('Error in validate_assignment_for_date');
                Raise unexpected_error;
            END IF;
        END IF;
       EXIT;

    END LOOP;

    PNP_DEBUG_PKG.log('-----------------------------');
    PNP_DEBUG_PKG.log('pnp_util_func.validate_date_assignable_area (-)');
    PNP_DEBUG_PKG.log('-----------------------------');

EXCEPTION

    WHEN UNEXPECTED_ERROR THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
        PNP_DEBUG_PKG.disable_file_debug;

    WHEN OTHERS THEN
        fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
        fnd_message.set_token('ERR_MSG',l_api_name||'='|| sqlerrm);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PNP_DEBUG_PKG.disable_file_debug;

END validate_date_assignable_area;

----------------------------------------------------
-- 31-OCT-2002  graghuna o Created due for forms 6i issue.
--                         WHEN pnp_util_func are called from forms
--                         and the p_As_of_date is not passed, the
--                         form generates error even though
--                         p_as_of_date is declared as NULL in the
--                         package.
-------------------------------------------------
FUNCTION get_as_of_date ( p_as_of_date IN DATE )
RETURN DATE
IS
BEGIN

   IF p_as_of_date is NULL OR
      p_as_of_date = FND_API.G_MISS_DATE THEN
      RETURN SYSDATE;
   ELSE
      RETURN p_as_of_date;

   END IF;


END;

  ----------------------------------------------------
  -- This PROCEDURE validates that the dates on space
  -- assignments are within the effective dates of
  -- the location
  --     26-JUL-2002      graghuna o Created
  --     30-OCT-2002  Satish Tripathi  o Access _all table for performance issues.
  --     05-NOV-2002  Satish Tripathi  o Fix for BUG# 2657009, Changed < = to <= in
  --                                     the cursor Validate_date_for_assignments.
  --     11-OCT-2006  acprakas         o Bug#5587012. Modified query of Cursor locations_cursor
  --     24-DEC-2008  rkartha          o Bug#7666462 : Modified the Cursor locations_cursor
  --                                                   to handle NULL condition for end date.
  -------------------------------------------------

PROCEDURE Validate_date_for_assignments
   ( p_location_id                   IN     NUMBER,
     p_start_date                    IN     DATE,
     p_end_date                      IN     DATE,
     x_return_status                    OUT NOCOPY VARCHAR2,
     x_return_message                   OUT NOCOPY VARCHAR2
   )
IS

/* Bug#7666462 : Modified the Cursor SELECT query to handle NULL condition for end date */

   CURSOR locations_cursor Is
   SELECT *
   FROM   pn_locations_all
   WHERE  location_id = p_location_id
   AND    (active_start_date <= NVL(p_start_Date, active_start_date)
           AND nvl(active_end_Date, TO_DATE('12/31/4712','MM/DD/YYYY')) >=
               nvl( p_end_date, TO_DATE('12/31/4712','MM/DD/YYYY')));

BEGIN

   x_return_status := FND_API.G_RET_STS_ERROR;

   FOR locations_rec in locations_cursor LOOP
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       EXIT;
   END LOOP;

   IF NOT ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        fnd_message.set_name('PN','PN_INVALID_SPACE_ASSIGN_DATE');
   END IF;
END Validate_date_for_Assignments;

-------------------------------------------------------------------------------
--  NAME         : Exist_Tenancy_For_End_Date
--  DESCRIPTION  : This Function validates if there exists atleast one primary
--                 tenancy with an end date greater than the new end date
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : p_location_id,p_New_End_Date
--  RETURNS      : BOOLEAN
--  REFERENCE    :
--  HISTORY      :
--  24-jun-03  Kiran    o Created. CAM impact on Locations.
--  20-OCT-03  ftanudja o removed GROUP BY expression. 3197410.
--  15-JUN-05  piagrawa o Bug 4307795 - Replaced pn_tenancies and pn_locations
--                        with _ALL table.
-------------------------------------------------------------------------------

FUNCTION Exist_Tenancy_For_End_Date
  ( p_Location_Id            IN  NUMBER,
    p_New_End_Date           IN  DATE
  )
RETURN BOOLEAN IS

  CURSOR tenancy_exists IS
  SELECT 'Y'
  FROM   dual
  WHERE  exists
         (select tenancy_id
          from   pn_tenancies_all
          where  location_id in
                 (select loc.location_id
                  from   pn_locations_all loc
                  connect by prior loc.location_id = loc.parent_location_id
                  start with loc.location_id = p_Location_Id)
          and    primary_flag = 'Y'
          and    EXPIRATION_DATE > p_New_End_Date
        );
BEGIN

  FOR ten in tenancy_exists LOOP
    RETURN true;
  END LOOP;

  RETURN false;

END Exist_Tenancy_For_End_Date;

-------------------------------------------------------------------------------
--  NAME         : Exist_Tenancy_For_Start_Date
--  DESCRIPTION  : This Function validates if there exists atleast one primary
--                 tenancy with a start date lesser than the new start date
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : p_location_id,p_New_Start_Date
--  RETURNS      : BOOLEAN
--  REFERENCE    :
--  HISTORY      :
--  24-jun-03  Kiran    o Created. CAM impact on Locations.
--  20-OCT-03  ftanudja o removed GROUP BY expression. 3197410.
--  15-JUN-05  piagrawa o Bug 4307795 - Replaced pn_tenancies and pn_locations
--                        with _ALL table.
-------------------------------------------------------------------------------

FUNCTION Exist_Tenancy_For_Start_Date
  ( p_Location_Id            IN  NUMBER,
    p_New_Start_Date         IN  DATE
  )
RETURN BOOLEAN IS

  CURSOR tenancy_exists IS
  SELECT 'Y'
  FROM   dual
  WHERE  exists
         (select tenancy_id
          from   pn_tenancies_all
          where  location_id in
                 (select loc.location_id
                  from   pn_locations_all loc
                  connect by prior loc.location_id = loc.parent_location_id
                  start with loc.location_id = p_Location_Id)
          and    primary_flag = 'Y'
          and    nvl(OCCUPANCY_DATE,ESTIMATED_OCCUPANCY_DATE) < p_New_Start_Date
        );
BEGIN

  FOR ten in tenancy_exists LOOP
    RETURN true;
  END LOOP;

  RETURN false;

END Exist_Tenancy_For_Start_Date;

-------------------------------------------------------------------------------
--  NAME         : Exist_Tenancy_For_Start_Date
--  DESCRIPTION  : This function returns TRUE if there exists if there is atleast
--                 one Area Class Detail for the goven Location or any of its
--                 child locations. The check is actually mde against the
--                 pn_rec_arcl_dtlln table.
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : p_location_id,p_New_Start_Date
--  RETURNS      : BOOLEAN
--  REFERENCE    :
--  HISTORY      :
--  24-jun-03  Kiran    o Created. CAM impact on Locations.
--  20-OCT-03  ftanudja o removed GROUP BY expression. 3197410.
--  15-JUN-05  piagrawa o Bug 4307795 - Replaced pn_rec_arcl_dtlln and
--                        pn_locations with _ALL table.
-------------------------------------------------------------------------------
FUNCTION Exist_Area_Class_Dtls_For_Loc
  ( p_Location_Id            IN  NUMBER,
    p_active_start_date      IN  DATE   default NULL,
    p_active_end_date        IN  DATE   default NULL)
RETURN BOOLEAN IS

  CURSOR Area_Class_Dtls_Exist IS
  SELECT  'Y'
  FROM    dual
  WHERE   exists
          (select area_class_dtl_line_id
           from   pn_rec_arcl_dtlln_all
           where  location_id in
                 (select loc.location_id
                  from   pn_locations_all loc
                  connect by prior loc.location_id = loc.parent_location_id
                  start with loc.location_id = p_Location_Id)
          );

  CURSOR Area_CLass_Dtls_Exist_For_Dt IS
  select 'Y'
  from   dual
  where  exists
  (select arclDtl.area_class_dtl_line_id
   from   pn_rec_arcl_dtlln_all arclDtl
   where  arclDtl.location_id = p_location_id
   and    (arclDtl.from_date between p_active_start_date
                         and p_active_end_date
           or
           arclDtl.to_date between p_active_start_date
                         and p_active_end_date)
  );

BEGIN

  IF (p_active_start_date IS NULL)
     AND (p_active_end_date IS NULL) THEN

    FOR arcl_dtl in Area_Class_Dtls_Exist LOOP
      RETURN true;
    END LOOP;

    RETURN false;

  ELSE

    FOR arcl_dlt_for_dt in Area_CLass_Dtls_Exist_For_Dt LOOP
      RETURN true;
    END LOOP;

    RETURN false;

  END IF;

END Exist_Area_Class_Dtls_For_Loc;

--------------------------------------------------------------------------
-- PROCEDURE  : batch_update_terms_area
-- DESCRIPTION: performs batch updates of area value onto the payment
--              terms table.
-- HISTORY
-- 08-JAN-04 ftanudja o created
-- 24-MAR-04 ftanudja o set l_user to fnd_global.user_id.
--------------------------------------------------------------------------
PROCEDURE batch_update_terms_area(
             x_area_tbl    num_tbl,
             x_term_id_tbl num_tbl)
IS
   l_user NUMBER  := fnd_global.user_id;
BEGIN

   FORALL i IN 0 .. x_term_id_tbl.COUNT - 1
      UPDATE pn_payment_terms_all
         SET area             = x_area_tbl(i),
             last_updated_by  = l_user,
             last_update_date = SYSDATE
       WHERE payment_term_id  = x_term_id_tbl(i);

END batch_update_terms_area;

--------------------------------------------------------------------------
-- FUNCTION   : chk_terms_for_tenancy
-- DESCRIPTION: checks payment terms for ties to tenancy
-- RETURNS    : TRUE if any payment term is associated to the tenancy
--            : FALSE otherwise
-- HISTORY
-- 15-JAN-04 ftanudja o created.
--------------------------------------------------------------------------
FUNCTION chk_terms_for_tenancy(
             p_tenancy_id  NUMBER,
             p_type        VARCHAR2) RETURN BOOLEAN
IS

   -- note that tenancy dates are not used because there is no restriction
   -- that payment term dates has to lie between tenancy dates

   CURSOR get_assoc_payment_terms_w_type IS
      SELECT 'Y' answer
        FROM pn_tenancies_all tnc
       WHERE tnc.tenancy_id = p_tenancy_id
         AND EXISTS (SELECT 'Y' FROM pn_payment_terms_all trm
                     WHERE trm.lease_id = tnc.lease_id
                       AND trm.location_id = tnc.location_id
                       AND trm.area_type_code = p_type);

   CURSOR get_assoc_payment_terms IS
      SELECT 'Y' answer
        FROM pn_tenancies_all tnc
       WHERE tnc.tenancy_id = p_tenancy_id
         AND EXISTS (SELECT 'Y' FROM pn_payment_terms_all trm
                     WHERE trm.lease_id = tnc.lease_id
                       AND trm.location_id = tnc.location_id);

   l_answer BOOLEAN := FALSE;

BEGIN

   IF p_type IS NOT NULL THEN

      FOR chk_cur IN get_assoc_payment_terms_w_type LOOP
         IF chk_cur.answer = 'Y' THEN l_answer := TRUE; END IF;
      END LOOP;

   ELSE

      FOR chk_cur IN get_assoc_payment_terms LOOP
         IF chk_cur.answer = 'Y' THEN l_answer := TRUE; END IF;
      END LOOP;

   END IF;

   RETURN l_answer;
END;

--------------------------------------------------------------------------
-- PROCEDURE  : chk_terms_for_lease_area_chg
-- DESCRIPTION: checks payment terms for possible impacts of changes in
--              lease rentable, usable or assignable area.
-- RETURNS    : 1) a table containing list of impacted term ID's.
--              2) a table containing their new respective areas.
-- HISTORY
-- 08-JAN-04 ftanudja o created
-- 11-FEB-04 ftanudja o added NOCOPY hint for OUT param
-- 20-FEB-04 ftanudja o added param p_share_pct. 3450659
--------------------------------------------------------------------------
PROCEDURE chk_terms_for_lease_area_chg (
             p_tenancy_id  NUMBER,
             p_lease_id    NUMBER,
             p_rentable    NUMBER,
             p_usable      NUMBER,
             p_assignable  NUMBER,
             p_share_pct   NUMBER,
             x_term_id_tbl OUT NOCOPY num_tbl,
             x_area_tbl    OUT NOCOPY num_tbl)
IS
   l_rentable_flag     BOOLEAN := FALSE;
   l_usable_flag       BOOLEAN := FALSE;
   l_assignable_flag   BOOLEAN := FALSE;
   l_share_pct_flag    BOOLEAN := FALSE;
   l_has_items         BOOLEAN := FALSE;
   l_area_rec          pn_location_area_rec;

   CURSOR get_lease_area IS
      SELECT lease_rentable_area,
             lease_usable_area,
             lease_assignable_area,
             tenants_proportionate_share,
             estimated_occupancy_date,
             occupancy_date,
             expiration_date,
             location_id
        FROM pn_tenancies_all
       WHERE tenancy_id = p_tenancy_id;

   CURSOR get_affected_payment_terms (p_loc_id NUMBER, p_occ_date DATE, p_exp_date DATE) IS
      SELECT trm.area_type_code,
             trm.payment_term_id,
             trm.start_date,
             loc.location_type_lookup_code,
             loc.rentable_area,
             loc.usable_area,
             loc.assignable_area
        FROM pn_payment_terms_all trm,
             pn_locations_all     loc
       WHERE trm.lease_id = p_lease_id
         AND loc.location_id = p_loc_id
         AND trm.location_id = p_loc_id
         AND trm.area_type_code NOT IN ('OTHER')
         AND trm.area_type_code IS NOT NULL
         AND trm.start_date BETWEEN p_occ_date AND p_exp_date
         AND trm.start_date BETWEEN loc.active_start_date AND loc.active_end_date;

   CURSOR search_for_items (p_payment_term_id NUMBER) IS
      SELECT 'Y' answer
        FROM dual
       WHERE EXISTS (SELECT 'Y' FROM pn_payment_items_all
                     WHERE payment_term_id = p_payment_term_id);

BEGIN
         FOR chk_area IN get_lease_area LOOP

            IF NOT ((chk_area.lease_rentable_area = p_rentable) OR
                    (chk_area.lease_rentable_area IS NULL AND p_rentable IS NULL)) THEN
               l_rentable_flag := TRUE;
            END IF;

            IF NOT ((chk_area.lease_usable_area = p_usable) OR
                    (chk_area.lease_usable_area IS NULL AND p_usable IS NULL)) THEN
               l_usable_flag := TRUE;
            END IF;

            IF NOT ((chk_area.lease_assignable_area = p_assignable) OR
                    (chk_area.lease_assignable_area IS NULL AND p_assignable IS NULL)) THEN
               l_assignable_flag := TRUE;
            END IF;

            IF NOT ((chk_area.tenants_proportionate_share = p_share_pct) OR
                    (chk_area.tenants_proportionate_share IS NULL AND p_share_pct IS NULL)) THEN
               l_share_pct_flag := TRUE;
            END IF;

            IF l_rentable_flag OR l_usable_flag OR l_assignable_flag OR l_share_pct_flag THEN
               FOR find_terms IN get_affected_payment_terms (chk_area.location_id, nvl(chk_area.occupancy_date, chk_area.estimated_occupancy_date), chk_area.expiration_date) LOOP

                  IF (l_rentable_flag AND find_terms.area_type_code = 'LEASE_RENTABLE') OR
                     (l_usable_flag AND find_terms.area_type_code = 'LEASE_USABLE') OR
                     (l_assignable_flag AND find_terms.area_type_code = 'LEASE_ASSIGNABLE') OR
                     l_share_pct_flag THEN

                     l_has_items := FALSE;
                     FOR find_items IN search_for_items(find_terms.payment_term_id) LOOP
                        IF find_items.answer = 'Y' THEN l_has_items := TRUE; END IF;
                     END LOOP;

                     IF NOT l_has_items THEN
                       x_term_id_tbl(x_term_id_tbl.COUNT) := find_terms.payment_term_id;

                       IF find_terms.area_type_code = 'LEASE_RENTABLE' AND (l_share_pct_flag OR l_rentable_flag) THEN
                          x_area_tbl(x_area_tbl.COUNT) := p_rentable * nvl(p_share_pct / 100, 1);
                       ELSIF find_terms.area_type_code = 'LEASE_USABLE' AND (l_share_pct_flag OR l_usable_flag) THEN
                          x_area_tbl(x_area_tbl.COUNT) := p_usable * nvl(p_share_pct / 100, 1);
                       ELSIF find_terms.area_type_code = 'LEASE_ASSIGNABLE' AND (l_share_pct_flag OR l_assignable_flag) THEN
                          x_area_tbl(x_area_tbl.COUNT) := p_assignable * nvl(p_share_pct / 100, 1);
                       ELSIF l_share_pct_flag THEN

                          fetch_loctn_area(
                             p_type        => find_terms.location_type_lookup_code,
                             p_location_id => chk_area.location_id,
                             p_as_of_date  => find_terms.start_date,
                             x_area        => l_area_rec);

                          IF find_terms.area_type_code = 'LOCTN_RENTABLE' THEN
                                x_area_tbl(x_area_tbl.COUNT) := l_area_rec.rentable_area * nvl(p_share_pct / 100, 1);
                          ELSIF find_terms.area_type_code = 'LOCTN_USABLE' THEN
                                x_area_tbl(x_area_tbl.COUNT) := l_area_rec.usable_area * nvl(p_share_pct / 100, 1);
                          ELSIF find_terms.area_type_code = 'LOCTN_ASSIGNABLE' THEN
                                x_area_tbl(x_area_tbl.COUNT) := l_area_rec.assignable_area * nvl(p_share_pct / 100, 1);
                          END IF;

                       END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;

END chk_terms_for_lease_area_chg;

--------------------------------------------------------------------------
-- FUNCTION    : get_tenants_share
-- RETURNS     : gets share % for a given lease, location, and as_of_date
-- NOTES       : private function called by chk_terms_for_locn_area_chg
-- HISTORY
-- 20-FEB-04 ftanudja o created. #3450659
-- 09-FEB-09 jsundara o Bug# 8819189 changed tenancy_proporshanate_share to allocated_area_pct
--------------------------------------------------------------------------
FUNCTION get_tenants_share (
            p_lease_id    NUMBER,
            p_location_id NUMBER,
            p_as_of_date  DATE) RETURN NUMBER
IS
CURSOR get_share IS
       SELECT allocated_area_pct share_pct /* 8819189 */
       FROM pn_tenancies_all
       WHERE location_id = p_location_id
       AND lease_id = p_lease_id
       AND p_as_of_date BETWEEN nvl(occupancy_date, estimated_occupancy_date)
                        AND expiration_date;

   l_result NUMBER := null;

BEGIN

   FOR ans_cur IN get_share LOOP l_result := ans_cur.share_pct; exit; END LOOP;

   RETURN l_result;
END get_tenants_share;

-------------------------------------------------------------------------------
-- FUNCTION    : fetch_tenancy_area
-- RETURNS     : gets area given an area type code, taking into account
--               the tenancy percentage share.
-- NOTES       : since overlapping tenancy is now allowed (ref #4150676)
--               make sure the area and share pct is summed.
-- HISTORY
-- 21-APR-05 ftanudja o created. #4324777
-- 01-SEP-05 Kiran    o Changed the type of params from
--                      pn_payment_terms.%TYPE to pn_payment_terms_all.%TYPE
------------------------------------------------------------------------------
FUNCTION fetch_tenancy_area (
            p_lease_id       pn_payment_terms_all.lease_id%TYPE,
            p_location_id    pn_payment_terms_all.location_id%TYPE,
            p_as_of_date     pn_payment_terms_all.start_date%TYPE,
            p_area_type_code pn_payment_terms_all.area_type_code%TYPE)
RETURN NUMBER
IS

 CURSOR get_tenancy_info IS
   SELECT sum(tnc.lease_assignable_area)       lease_assignable_area,
          sum(tnc.lease_rentable_area)         lease_rentable_area,
          sum(tnc.lease_usable_area)           lease_usable_area
   FROM pn_tenancies_all tnc
    WHERE tnc.lease_id = p_lease_id
      AND tnc.location_id = p_location_id
      AND p_as_of_date BETWEEN nvl(tnc.occupancy_date, tnc.estimated_occupancy_date) AND tnc.expiration_date;

 l_area_rec pnp_util_func.pn_location_area_rec;
 l_area     NUMBER := null;
 l_desc     VARCHAR2(100);

BEGIN

   l_desc := 'pnp_util_func.fetch_tenancy_area';

   pnp_debug_pkg.log(l_desc ||' (+)');

   FOR area_cur IN get_tenancy_info LOOP

      IF p_area_type_code IN ('LOCTN_RENTABLE','LOCTN_USABLE','LOCTN_ASSIGNABLE') THEN

          pnp_util_func.fetch_loctn_area(
             p_type        => pnp_util_func.get_location_type_lookup_code(
                                 p_location_id, p_as_of_date),
             p_location_id => p_location_id,
             p_as_of_date  => p_as_of_date,
             x_area        => l_area_rec);

          IF p_area_type_code = 'LOCTN_RENTABLE' THEN
             l_area := l_area_rec.rentable_area;
	  ELSIF p_area_type_code = 'LOCTN_USABLE' THEN
             l_area := l_area_rec.usable_area;
          ELSIF p_area_type_code = 'LOCTN_ASSIGNABLE' THEN
             l_area := l_area_rec.assignable_area;
          END IF;

      ELSIF p_area_type_code IN ('LEASE_RENTABLE','LEASE_USABLE','LEASE_ASSIGNABLE') THEN

          IF p_area_type_code = 'LEASE_RENTABLE' THEN
             l_area := area_cur.lease_rentable_area;
          ELSIF p_area_type_code = 'LEASE_USABLE' THEN
             l_area := area_cur.lease_usable_area;
          ELSIF p_area_type_code = 'LEASE_ASSIGNABLE' THEN
             l_area := area_cur.lease_assignable_area;
          END IF;
      END IF;
   END LOOP;

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN ROUND(l_area, 2);

END fetch_tenancy_area;

--------------------------------------------------------------------------
-- PROCEDURE  : chk_terms_for_locn_area_chg
-- DESCRIPTION: checks payment terms for possible impacts of changes in
--              location rentable, usable or assignable area.
-- RETURNS    : 1) a table containing list of impacted term ID's.
--              2) a table containing their new respective areas.
-- HISTORY
-- 08-JAN-04 ftanudja o created
-- 11-FEB-04 ftanudja o added NOCOPY hint for OUT param
-- 20-FEB-04 ftanudja o take into account tenants' share %. #3450659
--------------------------------------------------------------------------
PROCEDURE chk_terms_for_locn_area_chg (
             p_bld_loc_id  NUMBER,
             p_flr_loc_id  NUMBER,
             p_ofc_loc_id  NUMBER,
             p_rentable    NUMBER,
             p_usable      NUMBER,
             p_assignable  NUMBER,
             x_term_id_tbl OUT NOCOPY num_tbl,
             x_area_tbl    OUT NOCOPY num_tbl)
IS
   l_bld_rentable      NUMBER;
   l_bld_usable        NUMBER;
   l_bld_assignable    NUMBER;
   l_flr_rentable      NUMBER;
   l_flr_usable        NUMBER;
   l_flr_assignable    NUMBER;
   l_share             NUMBER;
   l_rentable_flag     BOOLEAN := FALSE;
   l_usable_flag       BOOLEAN := FALSE;
   l_assignable_flag   BOOLEAN := FALSE;
   l_has_items         BOOLEAN := FALSE;
   l_building_flag     BOOLEAN := FALSE;
   l_floor_flag        BOOLEAN := FALSE;

   CURSOR get_locn_area IS
      SELECT rentable_area,
             usable_area,
             assignable_area,
             active_start_date,
             active_end_date
        FROM pn_locations_all
       WHERE location_id = p_ofc_loc_id;

   CURSOR get_affected_payment_terms (p_ofc_id NUMBER, p_flr_id NUMBER, p_bld_id NUMBER,
                                      p_start_date DATE, p_end_date DATE) IS
      SELECT area_type_code,
             payment_term_id,
             start_date,
             location_id,
             lease_id,
             DECODE(location_id, p_ofc_id, 'OFFICE', p_flr_id, 'FLOOR', p_bld_id, 'BUILDING') type
        FROM pn_payment_terms_all
       WHERE location_id IN (p_ofc_id, p_flr_id, p_bld_id)
         AND area_type_code IN ('LOCTN_RENTABLE','LOCTN_USABLE','LOCTN_ASSIGNABLE')
         AND start_date BETWEEN p_start_date AND p_end_date;

   CURSOR search_for_items (p_payment_term_id NUMBER) IS
      SELECT 'Y' answer
        FROM dual
       WHERE EXISTS (SELECT 'Y' FROM pn_payment_items_all
                     WHERE payment_term_id = p_payment_term_id);

   -- note that the old office area is excluded
   CURSOR get_flr_area (p_as_of_date DATE) IS
      SELECT sum(nvl(rentable_area,0)) rentable,
             sum(nvl(usable_area,0)) usable,
             sum(nvl(assignable_area,0)) assignable
        FROM pn_locations_all loc
       WHERE loc.parent_location_id = p_flr_loc_id
         AND p_as_of_date BETWEEN active_start_date AND active_end_date
         AND location_id <> p_ofc_loc_id;

   -- note that the old office area is excluded
   CURSOR get_bld_area (p_as_of_date DATE) IS
      SELECT sum(nvl(o.rentable_area,0)) rentable,
             sum(nvl(o.usable_area,0)) usable,
             sum(nvl(o.assignable_area,0)) assignable
        FROM pn_locations_all f, pn_locations_all o
       WHERE p_bld_loc_id = f.parent_location_id
         AND f.location_id = o.parent_location_id
         AND p_as_of_date BETWEEN f.active_start_date AND f.active_end_date
         AND p_as_of_date BETWEEN o.active_start_date AND o.active_end_date
         AND o.location_id <> p_ofc_loc_id;

BEGIN

         FOR chk_area IN get_locn_area LOOP

            IF NOT ((chk_area.rentable_area = p_rentable) OR
                    (chk_area.rentable_area IS NULL AND p_rentable IS NULL)) THEN
               l_rentable_flag := TRUE;
            END IF;

            IF NOT ((chk_area.usable_area = p_usable) OR
                    (chk_area.usable_area IS NULL AND p_usable IS NULL)) THEN
               l_usable_flag := TRUE;
            END IF;

            IF NOT ((chk_area.assignable_area = p_assignable) OR
                    (chk_area.assignable_area IS NULL AND p_assignable IS NULL)) THEN
               l_assignable_flag := TRUE;
            END IF;

            IF l_rentable_flag OR l_usable_flag OR l_assignable_flag THEN

               FOR find_terms IN get_affected_payment_terms (p_ofc_loc_id, p_flr_loc_id, p_bld_loc_id, chk_area.active_start_date, chk_area.active_end_date) LOOP

                  IF (l_rentable_flag AND find_terms.area_type_code = 'LOCTN_RENTABLE') OR
                     (l_usable_flag AND find_terms.area_type_code = 'LOCTN_USABLE') OR
                     (l_assignable_flag AND find_terms.area_type_code = 'LOCTN_ASSIGNABLE') THEN

                     l_has_items := FALSE;
                     FOR find_items IN search_for_items(find_terms.payment_term_id) LOOP
                        IF find_items.answer = 'Y' THEN l_has_items := TRUE; END IF;
                     END LOOP;

                     IF NOT l_has_items THEN
                       x_term_id_tbl(x_term_id_tbl.COUNT) := find_terms.payment_term_id;

                       IF find_terms.type = 'BUILDING' AND NOT l_building_flag THEN

                          FOR bld_area_cur IN get_bld_area(find_terms.start_date) LOOP
                             l_bld_rentable   := bld_area_cur.rentable;
                             l_bld_usable     := bld_area_cur.usable;
                             l_bld_assignable := bld_area_cur.assignable;

                          END LOOP;

                          IF NOT (l_bld_rentable IS NULL AND p_rentable IS NULL) THEN
                             l_bld_rentable   := nvl(l_bld_rentable,0)   + nvl(p_rentable,0);
                          END IF;

                          IF NOT (l_bld_usable IS NULL AND p_usable IS NULL) THEN
                             l_bld_usable     := nvl(l_bld_usable,0)     + nvl(p_usable,0);
                          END IF;

                          IF NOT (l_bld_assignable IS NULL AND p_assignable IS NULL) THEN
                             l_bld_assignable := nvl(l_bld_assignable,0) + nvl(p_assignable,0);
                          END IF;

                          l_building_flag  := TRUE;

                       ELSIF find_terms.type = 'FLOOR' AND NOT l_floor_flag THEN

                          FOR flr_area_cur IN get_flr_area(find_terms.start_date) LOOP
                             l_flr_rentable   := flr_area_cur.rentable;
                             l_flr_usable     := flr_area_cur.usable;
                             l_flr_assignable := flr_area_cur.assignable;
                          END LOOP;

                          IF NOT (l_flr_rentable IS NULL AND p_rentable IS NULL) THEN
                             l_flr_rentable   := nvl(l_flr_rentable,0)   + nvl(p_rentable,0);
                          END IF;

                          IF NOT (l_flr_usable IS NULL AND p_usable IS NULL) THEN
                             l_flr_usable     := nvl(l_flr_usable,0)     + nvl(p_usable,0);
                          END IF;

                          IF NOT (l_flr_assignable IS NULL AND p_assignable IS NULL) THEN
                             l_flr_assignable := nvl(l_flr_assignable,0) + nvl(p_assignable,0);
                          END IF;

                          l_floor_flag := TRUE;

                       END IF;

                       l_share := get_tenants_share(
                                     p_lease_id    => find_terms.lease_id,
                                     p_location_id => find_terms.location_id,
                                     p_as_of_date  => find_terms.start_date);

                       l_share := nvl(l_share / 100, 1);

                       IF l_rentable_flag AND find_terms.area_type_code = 'LOCTN_RENTABLE' THEN
                          IF find_terms.type = 'BUILDING' THEN
                             x_area_tbl(x_area_tbl.COUNT) := l_bld_rentable * l_share;
                          ELSIF find_terms.type = 'FLOOR' THEN
                             x_area_tbl(x_area_tbl.COUNT) := l_flr_rentable * l_share;
                          ELSIF find_terms.type = 'OFFICE' THEN
                             x_area_tbl(x_area_tbl.COUNT) := p_rentable * l_share;
                          END IF;
                       ELSIF l_usable_flag AND find_terms.area_type_code = 'LOCTN_USABLE' THEN
                          IF find_terms.type = 'BUILDING' THEN
                             x_area_tbl(x_area_tbl.COUNT) := l_bld_usable * l_share;
                          ELSIF find_terms.type = 'FLOOR' THEN
                             x_area_tbl(x_area_tbl.COUNT) := l_flr_usable * l_share;
                          ELSIF find_terms.type = 'OFFICE' THEN
                             x_area_tbl(x_area_tbl.COUNT) := p_usable * l_share;
                          END IF;
                       ELSIF l_assignable_flag AND find_terms.area_type_code = 'LOCTN_ASSIGNABLE' THEN
                          IF find_terms.type = 'BUILDING' THEN
                             x_area_tbl(x_area_tbl.COUNT) := l_bld_assignable * l_share;
                          ELSIF find_terms.type = 'FLOOR' THEN
                             x_area_tbl(x_area_tbl.COUNT) := l_flr_assignable * l_share;
                          ELSIF find_terms.type = 'OFFICE' THEN
                             x_area_tbl(x_area_tbl.COUNT) := p_assignable * l_share;
                          END IF;
                       END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;

END chk_terms_for_locn_area_chg;

--------------------------------------------------------------------------
-- PROCEDURE  : fetch_loctn_area
-- DESCRIPTION: Generic function to fetch area. Benefits:
--               SQL more performant than prior schemes.
--               Code reuse / centralized logic / maintenance.
--               Higher db cache hit rate because same SQL is used.
-- HISTORY
-- 25-FEB-04 ftanudja o created.
-- 05-MAY-04 ftanuja  o added elsif for p_type = null.
--------------------------------------------------------------------------

PROCEDURE fetch_loctn_area(
              p_type        VARCHAR2,
              p_location_id NUMBER,
              p_as_of_date  DATE,
              x_area        OUT NOCOPY pn_location_area_rec)
IS
   CURSOR building_area IS
      SELECT nvl(sum(ofc.rentable_area),0)          rentable,
             nvl(sum(ofc.usable_area),0)            usable,
             nvl(sum(ofc.assignable_area),0)        assignable,
             nvl(sum(ofc.max_capacity),0)           max_capacity,
             nvl(sum(ofc.optimum_capacity),0)       optimum_capacity
        FROM pn_locations_all ofc,
             pn_locations_all flr
       WHERE p_as_of_date BETWEEN ofc.active_start_date AND ofc.active_end_date
         AND p_as_of_date BETWEEN flr.active_start_date AND flr.active_end_date
         AND flr.parent_location_id = p_location_id
         AND ofc.parent_location_id = flr.location_id;

   CURSOR floor_area IS
      SELECT nvl(sum(ofc.rentable_area),0)      rentable,
             nvl(sum(ofc.usable_area),0)        usable,
             nvl(sum(ofc.assignable_area),0)    assignable,
             nvl(sum(ofc.max_capacity),0)       max_capacity,
             nvl(sum(ofc.optimum_capacity),0)   optimum_capacity
        FROM pn_locations_all ofc
       WHERE p_as_of_date BETWEEN ofc.active_start_date AND ofc.active_end_date
         AND ofc.parent_location_id = p_location_id;

   CURSOR office_area IS
      SELECT rentable_area                      rentable,
             usable_area                        usable,
             assignable_area                    assignable,
             max_capacity                       max_capacity,
             optimum_capacity                   optimum_capacity
        FROM pn_locations_all ofc
       WHERE p_as_of_date BETWEEN ofc.active_start_date AND ofc.active_end_date
         AND ofc.location_id = p_location_id;

BEGIN

   IF p_type IN ('BUILDING','LAND') THEN
      FOR ans_cur IN building_area LOOP
         x_area.rentable_area   := ans_cur.rentable;
         x_area.usable_area     := ans_cur.usable;
         x_area.assignable_area := ans_cur.assignable;
         x_area.max_capacity    := ans_cur.max_capacity;
         x_area.optimum_capacity:= ans_cur.optimum_capacity;
      END LOOP;
   ELSIF p_type IN ('FLOOR','PARCEL') THEN
      FOR ans_cur IN floor_area LOOP
         x_area.rentable_area   := ans_cur.rentable;
         x_area.usable_area     := ans_cur.usable;
         x_area.assignable_area := ans_cur.assignable;
         x_area.max_capacity    := ans_cur.max_capacity;
         x_area.optimum_capacity:= ans_cur.optimum_capacity;
      END LOOP;
   ELSIF p_type IN ('OFFICE','SECTION') THEN
      FOR ans_cur IN office_area LOOP
         x_area.rentable_area   := ans_cur.rentable;
         x_area.usable_area     := ans_cur.usable;
         x_area.assignable_area := ans_cur.assignable;
         x_area.max_capacity    := ans_cur.max_capacity;
         x_area.optimum_capacity:= ans_cur.optimum_capacity;
      END LOOP;
   /* added per Amita's request */
   ELSIF p_type IS NULL THEN
         x_area.rentable_area   := 0;
         x_area.usable_area     := 0;
         x_area.assignable_area := 0;
         x_area.max_capacity    := 0;
         x_area.optimum_capacity:= 0;
   END IF;

END fetch_loctn_area;

-- Retro Start
-------------------------------------------------------------------------------
-- PROCEDURE  : retro_enabled
-- DESCRIPTION: Works as a On/Off switch for Lease Retro Changes Phase - 1
--              functionality. Returns boolean value of TRUE if functionality
--              is switched ON else returns FALSE.
-- HISTORY
-- 15-OCT-2004   Mrinal Misra   o Created.
-------------------------------------------------------------------------------
FUNCTION retro_enabled RETURN BOOLEAN IS

BEGIN

   RETURN g_retro_enabled;

END retro_enabled;

-------------------------------------------------------------------------------
-- PROCEDURE  : retro_enabled_char
-- DESCRIPTION: Works as a On/Off switch for Lease Retro Changes Phase - 1
--              functionality. Returns character value of 'Y' if functionality
--              is switched ON else returns 'N'. It was created to be used in
--              OA framewrork VOs.
-- HISTORY
-- 15-OCT-2004   Mrinal Misra   o Created.
-------------------------------------------------------------------------------
FUNCTION retro_enabled_char RETURN VARCHAR2 IS
BEGIN

   IF g_retro_enabled THEN
     RETURN 'Y';
   ELSE
     RETURN 'N';
   END IF;

END retro_enabled_char;

--------------------------------------------------------------------------------
--
--  NAME         : check_var_rent_retro
--  DESCRIPTION  : Stops the user if a Retro change in term dates will cause an
--                 abatement line for an invoice in VR to go out of the invoice
--                 date.
--  PURPOSE      :
--  INVOKED FROM : PNTLEASE
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  12-NOV-2004   Kiran Hegde   o Created.
--------------------------------------------------------------------------------
PROCEDURE check_var_rent_retro( p_term_id        IN NUMBER
                               ,p_new_start_date IN DATE
                               ,p_new_end_date   IN DATE
                               ,p_error          OUT NOCOPY BOOLEAN)
IS

   /* Get all abatements lines that will go bad with the new term dates */
   CURSOR chk_abat_retro IS
   SELECT  pvr.rent_num
   FROM    pn_var_rents_all      pvr,
           pn_var_rent_inv_all   pvri,
           pn_var_abatements_all pva
   WHERE   pva.payment_term_id = p_term_id
   AND     pvri.var_rent_inv_id = pva.var_rent_inv_id
   AND     pvri.invoice_date NOT BETWEEN p_new_start_date
                                     AND p_new_end_date
   AND     pvr.var_rent_ID = pvri.var_rent_ID;

   l_var_rent_num VARCHAR2(30);
   RETRO_VARENT_EXCEPTION EXCEPTION;

BEGIN
   pnp_debug_pkg.log('check_var_rent_retro - (+)');

   FOR abat IN chk_abat_retro LOOP

     l_var_rent_num := abat.rent_num;

     RAISE RETRO_VARENT_EXCEPTION;

   END LOOP;

   pnp_debug_pkg.log('check_var_rent_retro - (-)');
EXCEPTION

   WHEN RETRO_VARENT_EXCEPTION THEN
      fnd_message.set_name('PN', 'PN_RETRO_VARENT_ERR');
      fnd_message.set_token('VAR_RENT_NUM', l_var_rent_num);
      p_error := TRUE;
      RETURN;

   WHEN others THEN
      RAISE;

END check_var_rent_retro;

-------------------------------------------------------------------------------
-- PROCEDURE  : get_yr_mth_days
-- DESCRIPTION: For From and To date input params., procedure returns
--              years, months and days between them.
-- HISTORY
-- 15-OCT-04 MMisra  o Created.
-- 19-SEP-05 pikhar  o Added IF condition to supress negetive values of
--                     number of days returned
-- 10-JAN-06 pikhar  o Calculated number of days after reducing start and end
--                     dates by 1 day if start date is month end
-------------------------------------------------------------------------------
PROCEDURE get_yr_mth_days(p_from_date IN DATE
                         ,p_to_date   IN DATE
                         ,p_yrs       OUT NOCOPY NUMBER
                         ,p_mths      OUT NOCOPY NUMBER
                         ,p_days      OUT NOCOPY NUMBER) IS

l_days number;
l_from_date DATE;
l_to_date   DATE;
BEGIN
   pnp_debug_pkg.log('get_yr_mth_days - (+)');

   /* init local start - end dates */
   l_from_date := p_from_date;
   l_to_date := p_to_date;

   IF TO_NUMBER(TO_CHAR(p_from_date, 'mm'))
      <> TO_NUMBER(TO_CHAR(p_from_date + 1, 'mm')) THEN
      /* last day of month */

      IF TO_NUMBER(TO_CHAR(p_from_date, 'mm')) = 2 AND
         TO_NUMBER(TO_CHAR(p_from_date, 'dd')) = 29 THEN
         /* 29th Feb in a leap year */
         l_from_date := p_from_date - 2;
         l_to_date := p_to_date - 2;

      ELSE
         /* any other last day of month */
         l_from_date := p_from_date - 1;
         l_to_date := p_to_date - 1;

      END IF;

   END IF;

   p_yrs  := FLOOR(MONTHS_BETWEEN(l_to_date+1, l_from_date)/12);
   p_mths := MOD(FLOOR(MONTHS_BETWEEN(l_to_date+1, l_from_date)), 12);
   p_days := l_to_date + 1 - ADD_MONTHS(l_from_date, FLOOR(MONTHS_BETWEEN(l_to_date + 1, l_from_date)));

   /* for handling exceptional situations */
   IF p_days<0 THEN
     p_days:=0;
   END IF;

   pnp_debug_pkg.log('get_yr_mth_days - (-)');

END get_yr_mth_days;

-------------------------------------------------------------------------------
-- FUNCTION : get_date_from_ymd
-- DESCRIPTION: This functions returns a date if a From Date and Year/Month/Days
--              are given as input parameters.
-- HISTORY
-- 13-JAN-2005   Mrinal Misra   o Created.
-------------------------------------------------------------------------------
FUNCTION get_date_from_ymd(p_from_date IN DATE
                          ,p_yrs       IN NUMBER
                          ,p_mths      IN NUMBER
                          ,p_days      IN NUMBER)
RETURN DATE IS

   l_to_date   DATE;

BEGIN

   pnp_debug_pkg.log('get_date_from_ymd - (+)');

   IF p_from_date IS NOT NULL THEN
      IF NVL(p_yrs,0) = 0 AND
         NVL(p_mths,0) = 0 AND
         NVL(p_days,0) = 0 THEN

         RETURN p_from_date;
      ELSE
         -- Bug 9345928
         SELECT ADD_MONTHS( (p_from_date - 1), NVL(p_yrs,0) * 12 + NVL(p_mths,0)) + NVL(p_days,0)
         INTO l_to_date
         FROM DUAL;

         RETURN l_to_date;
      END IF;
   ELSE
      RETURN NULL;
   END IF;

   pnp_debug_pkg.log('get_date_from_ymd - (-)');
END get_date_from_ymd;
-- Retro End

/* public view as of date setter/getters functions */
-------------------------------------------------------------------------------
--  NAME         : set_as_of_date_4_loc_pubview
--  DESCRIPTION  : Sets the as of date for location public view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_Date
--  RETURNS      : NUMNER
--  REFERENCE    :
--  HISTORY      :
-- 15-jun-05  piagrawa   o Bug 4307795 - Created
-------------------------------------------------------------------------------
FUNCTION set_as_of_date_4_loc_pubview(p_date  DATE) RETURN NUMBER IS
BEGIN
   g_as_of_date_4_loc_pubview  := p_date;
   RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
   g_as_of_date_4_loc_pubview  := SYSDATE;
   RETURN -1;

END set_as_of_date_4_loc_pubview;

-------------------------------------------------------------------------------
--  NAME         : get_as_of_date_4_loc_pubview
--  DESCRIPTION  : Retrieves the as of date for location public view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : NONE
--  RETURNS      : As of date value
--  REFERENCE    :
--  HISTORY      :
-- 15-jun-05  piagrawa   o Bug 4307795 - Created
-------------------------------------------------------------------------------
FUNCTION get_as_of_date_4_loc_pubview RETURN DATE IS
BEGIN
  RETURN g_as_of_date_4_loc_pubview;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_as_of_date_4_loc_pubview;

-------------------------------------------------------------------------------
--  NAME         : set_as_of_date_4_loc_pubview
--  DESCRIPTION  : Sets the as of date for location public view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_Date
--  RETURNS      : NUMNER
--  REFERENCE    :
--  HISTORY      :
-- 15-jun-05  piagrawa   o Bug 4307795 - Created
-------------------------------------------------------------------------------
FUNCTION set_as_of_date_4_emp_pubview(p_date  DATE) RETURN NUMBER IS
BEGIN
   g_as_of_date_4_emp_pubview  := p_date;
   RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
   g_as_of_date_4_emp_pubview  := SYSDATE;
   RETURN -1;

END set_as_of_date_4_emp_pubview;

-------------------------------------------------------------------------------
--  NAME         : get_as_of_date_4_loc_pubview
--  DESCRIPTION  : Retrieves the as of date for location public view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : NONE
--  RETURNS      : As of date value
--  REFERENCE    :
--  HISTORY      :
-- 15-jun-05  piagrawa   o Bug 4307795 - Created
-------------------------------------------------------------------------------
FUNCTION get_as_of_date_4_emp_pubview RETURN DATE IS
BEGIN
 RETURN NVL(g_as_of_date_4_emp_pubview, SYSDATE);

EXCEPTION
 WHEN OTHERS THEN
   RAISE;

END get_as_of_date_4_emp_pubview;
/* public view as of date setter/getters functions */

/* --- OVERLOADED functions and procedures for MOAC START --- */
/*============================================================================+
--  NAME         : get_ar_trx_type
--  DESCRIPTION  : This FUNCTION RETURNs Transaction Type for a given Customer
--                 Transaction Type Id FROM Receivables.
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_trx_id
--  RETURNS      : Transaction Type
--  HISTORY      :
--  24-Jun-05  Kiran         o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
+============================================================================*/
FUNCTION Get_Ar_Trx_type( p_trx_id IN NUMBER
                         ,p_org_id IN NUMBER) RETURN VARCHAR2 IS

l_trx_type ra_cust_trx_types.name%TYPE;

BEGIN

  SELECT name
  INTO   l_trx_type
  FROM   ra_cust_trx_types_all
  WHERE  cust_trx_type_id = p_trx_id
  AND    org_id = p_org_id;

  RETURN(l_trx_type);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
  RETURN NULL;

  WHEN OTHERS THEN
  RAISE;

END Get_Ar_Trx_type;

/* --- OVERLOADED functions and procedures for MOAC END   --- */

-------------------------------------------------------------------------------
-- PROCEDURE  : mini_retro_enabled
-- DESCRIPTION: Works as a On/Off switch for Lease Mini Retro Changes
--              functionality. Returns boolean value of TRUE if functionality
--              is switched ON else returns FALSE.
-- HISTORY
-- 01-AUG-05  piagrawa   o Created.
-------------------------------------------------------------------------------
FUNCTION mini_retro_enabled RETURN BOOLEAN IS

BEGIN

   RETURN g_mini_retro_enabled;

END mini_retro_enabled;

-------------------------------------------------------------------------------
-- PROCEDURE  : mini_retro_enabled_char
-- DESCRIPTION: Works as a On/Off switch for Lease Mini Retro Changes
--              functionality. Returns character value of 'Y' if functionality
--              is switched ON else returns 'N'. It was created to be used in
--              OA framewrork VOs.
-- HISTORY
-- 01-AUG-05  piagrawa   o Created.
-------------------------------------------------------------------------------
FUNCTION mini_retro_enabled_char RETURN VARCHAR2 IS
BEGIN

   IF g_mini_retro_enabled THEN
     RETURN 'Y';
   ELSE
     RETURN 'N';
   END IF;

END mini_retro_enabled_char;

/*============================================================================+
--  NAME         : get_loc_name_disp
--  DESCRIPTION  : RETURNs primary Location_name
--  NOTES        : Currently being called from leases form-view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_lease_Id,p_as_of_date
--                 OUT : location_name
--  RETURNS      : The Location Information of the Location
--  REFERENCE    :
--  HISTORY      :
--  20-SEP-06    Hareesha   o Created -MTM uptake
+============================================================================*/

FUNCTION get_loc_name_disp(p_lease_id IN NUMBER,
                           p_as_of_date IN DATE)
RETURN VARCHAR2 IS
   l_location_name_rec location_name_rec;

CURSOR get_loc_cur(p_lease_id NUMBER) IS
   SELECT location_id
   FROM   pn_tenancies_all
   WHERE  lease_id = p_lease_id
   AND    NVL(primary_flag ,'N') = 'Y'
   AND    ROWNUM < 2;

BEGIN

   FOR rec IN get_loc_cur(p_lease_id) LOOP
      l_location_name_rec := pnp_util_func.get_location_name(rec.location_id,p_as_of_date);
   END LOOP;

   RETURN NVL(l_location_name_rec.office,
              NVL(l_location_name_rec.floor,l_location_name_rec.building)
             );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RAISE;

END get_loc_name_disp;

/*============================================================================+
--  NAME         : get_loc_code_disp
--  DESCRIPTION  : RETURNs primary Location_code
--  NOTES        : Currently being called from leases form-view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_lease_Id,p_as_of_date
--                 OUT : location_code
--  RETURNS      : The Location Information of the Location
--  REFERENCE    :
--  HISTORY      :
--  20-SEP-06    Hareesha   o Created -MTM uptake
+============================================================================*/

FUNCTION get_loc_code_disp(p_lease_id IN NUMBER,
                           p_as_of_date IN DATE)
RETURN VARCHAR2 IS
   l_location_name_rec location_name_rec;

CURSOR get_loc_cur(p_lease_id NUMBER) IS
   SELECT location_id
   FROM   pn_tenancies_all
   WHERE  lease_id = p_lease_id
   AND    NVL(primary_flag ,'N') = 'Y'
   AND    ROWNUM < 2;

BEGIN

   FOR rec IN get_loc_cur(p_lease_id) LOOP
      l_location_name_rec := pnp_util_func.get_location_name(rec.location_id,p_as_of_date);
   END LOOP;

   RETURN NVL(l_location_name_rec.office_location_code,
              NVL(l_location_name_rec.floor_location_code,l_location_name_rec.building_location_code)
             );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RAISE;

END get_loc_code_disp;

/*============================================================================+
--  NAME         : get_prop_name_disp
--  DESCRIPTION  : RETURNs property associated with the primary location
--  NOTES        : Currently being called from leases form-view
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_lease_Id,p_as_of_date
--                 OUT : property_name
--  RETURNS      : The property Information of the Location
--  REFERENCE    :
--  HISTORY      :
--  20-SEP-06    Hareesha   o Created -MTM uptake
+============================================================================*/

FUNCTION get_prop_name_disp(p_lease_id IN NUMBER,
                            p_as_of_date IN DATE)
RETURN VARCHAR2 IS
   l_location_name_rec location_name_rec;

CURSOR get_loc_cur(p_lease_id NUMBER) IS
   SELECT location_id
   FROM   pn_tenancies_all
   WHERE  lease_id = p_lease_id
   AND    NVL(primary_flag ,'N') = 'Y'
   AND    ROWNUM < 2;

BEGIN

   FOR rec IN get_loc_cur(p_lease_id) LOOP
      l_location_name_rec := pnp_util_func.get_location_name(rec.location_id,p_as_of_date);
   END LOOP;

   RETURN l_location_name_rec.property_name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RAISE;

END get_prop_name_disp;

-------------------------------------
-- End of Package --
--------------------------------------
END pnp_util_func;

/
