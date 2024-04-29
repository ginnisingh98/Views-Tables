--------------------------------------------------------
--  DDL for Package Body PNRX_RENT_LES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_RENT_LES" AS
/* $Header: PNRXRRLB.pls 120.2 2005/12/01 14:39:03 appldev ship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : PN_RENT_LES
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_payment_terms with _ALL table
-- 27-OCT-05  sdmahesh o ATG Mandated changes for SQL literals
-------------------------------------------------------------------------------
PROCEDURE pn_rent_les(
           lease_resp_user             IN                    VARCHAR2,
           location_code_low           IN                    VARCHAR2,
           location_code_high          IN                    VARCHAR2,
           lease_type                  IN                    VARCHAR2,
           lease_number_low            IN                    VARCHAR2,
           lease_number_high           IN                    VARCHAR2,
           lease_termination_from      IN                    DATE,
           lease_termination_to        IN                    DATE,
           lease_status                IN                    VARCHAR2,
           lease_class                 IN                    VARCHAR2,        --bug#2099864
           l_request_id                IN                    NUMBER,
           l_user_id                   IN                    NUMBER,
           retcode                     OUT NOCOPY            VARCHAR2,
           errbuf                      OUT NOCOPY            VARCHAR2
                      )
 IS
   l_login_id                                                  NUMBER;
   type cur_typ is ref cursor;
   c_lease_pn                                                  CUR_TYP;
   c_tlease_pn                                                 CUR_TYP;
   c_loc_pn                                                    CUR_TYP;
   c_tloc_pn                                                   CUR_TYP;
   c_landlord_pn                                               CUR_TYP;
   c_rent_pn                                                   CUR_TYP;
   c_deposit_pn                                                CUR_TYP;
   c_oe_pn                                                     CUR_TYP;
   c_tenant_pn                                                 CUR_TYP;
   c_pay_pn                                                    CUR_TYP;
   c_schedule_pn                                               CUR_TYP;
   query_str                                                   VARCHAR2(20000);

 --declare the 'where clauses here........'
   lease_number_where_clause                                   VARCHAR2(4000);
   location_code_where_clause                                  VARCHAR2(4000);
   les_resp_user_where_clause                                  VARCHAR2(4000);
   lease_type_where_clause                                     VARCHAR2(4000);
   lease_date_where_clause                                     VARCHAR2(4000);
   lease_status_where_clause                                   VARCHAR2(4000);
   lease_class_where_clause                                    VARCHAR2(4000);      --bug#2099864
   l_location_date_clause                                      VARCHAR2(4000);

 --declare all columns as variables here
   V_LEASE_ID                                                  NUMBER;
   V_LEASE_NAME                                                VARCHAR2(50);
   V_LEASE_NUMBER                                              VARCHAR2(30);
   V_LEASE_COM_DATE                                            DATE;
   V_LEASE_TERM_DATE                                           DATE;
   V_LEASE_EXE_DATE                                            DATE;
   V_LEASE_TERM                                                NUMBER;
   V_LEASE_CLASS                                               VARCHAR2(80);
   V_LEASE_CLASS_CODE                                          VARCHAR2(80);     --bug#2099864
   V_LEASE_RESP_USER                                           VARCHAR2(100);
   V_LEASE_STATUS                                              VARCHAR2(80);
   V_LEASE_TYPE                                                VARCHAR2(80);
   V_ESTIMATED_OCCUPANCY_DATE                                  DATE;
   V_ACTUAL_OCCUPANCY_DATE                                     DATE;
   V_LOCATION_ID                                               NUMBER;
   V_LOCATION_ID_1                                             NUMBER;
   V_LOCATION_ID_2                                             NUMBER;
   V_ACTIVE_START_DATE                                         DATE;
   V_LOCATION_TYPE                                             VARCHAR2(80);
   V_LOCATION_NAME                                             VARCHAR2(80);
   V_LOCATION_CODE                                             VARCHAR2(90);
   V_SPACE_TYPE                                                VARCHAR2(80);
   V_PROPERTY_CODE                                             VARCHAR2(90);
   V_REGION_NAME                                               VARCHAR2(50);
   V_ADDRESS                                                   VARCHAR2(1500);
   V_COUNTY                                                    VARCHAR2(60);
   V_CITY                                                      VARCHAR2(60);
   V_STATE                                                     VARCHAR2(60);
   V_PROVINCE                                                  VARCHAR2(60);
   V_ZIP_CODE                                                  VARCHAR2(60);
   V_COUNTRY                                                   VARCHAR2(60);
   V_RENTABLE_AREA                                             NUMBER;
   V_USABLE_AREA                                               NUMBER;
   V_GROSS_AREA                                                NUMBER;
   V_TENURE                                                    VARCHAR2(80);
   V_VENDOR_ID                                                 NUMBER;
   V_VENDOR_SITE_ID                                            NUMBER;
   V_VENDOR_SITE                                               VARCHAR2(15);
   V_ANNUAL_BASE_RENT                                          NUMBER := 0;
   V_MONTHLY_BASE_RENT                                         NUMBER := 0;
   V_VENDOR_NAME                                               VARCHAR2(360);
   V_INVOICING_ADDRESS                                         VARCHAR2(1500);
   V_CUSTOMER_ID                                               NUMBER;
   V_CUSTOMER_SITE                                             VARCHAR2(40);
   V_CUSTOMER_SITE_USE_ID                                      NUMBER;
   V_CUSTOMER_NAME                                             VARCHAR2(360);
   V_ACTUAL_AMOUNT                                             NUMBER;
   V_DEPOSIT                                                   NUMBER:=0;
   V_MONTHLY_OPERATING_EXPENSES                                NUMBER:=0;
   V_ANNUAL_OPERATING_EXPENSES                                 NUMBER:=0;
   V_TOTAL_LEASE_LIABILITY                                     NUMBER:=0;
   V_AMOUNT_EXPORTED                                           NUMBER:=0;
   V_REMAINING_LEASE_LIABILITY                                 NUMBER:=0;
   V_ANNUAL_RENT_PER_RENT_AREA                                 NUMBER:=0;
   V_PAYMENT_TERM_ID                                           NUMBER;
   V_PAYMENT_TERM_TYPE_CODE                                    VARCHAR2(30);
   V_PAYMENT_SCHEDULE_ID                                       NUMBER;
   V_ATTRIBUTE_CATEGORY                                        VARCHAR2(30);
   V_ATTRIBUTE1                                                VARCHAR2(150);
   V_ATTRIBUTE2                                                VARCHAR2(150);
   V_ATTRIBUTE3                                                VARCHAR2(150);
   V_ATTRIBUTE4                                                VARCHAR2(150);
   V_ATTRIBUTE5                                                VARCHAR2(150);
   V_ATTRIBUTE6                                                VARCHAR2(150);
   V_ATTRIBUTE7                                                VARCHAR2(150);
   V_ATTRIBUTE8                                                VARCHAR2(150);
   V_ATTRIBUTE9                                                VARCHAR2(150);
   V_ATTRIBUTE10                                               VARCHAR2(150);
   V_ATTRIBUTE11                                               VARCHAR2(150);
   V_ATTRIBUTE12                                               VARCHAR2(150);
   V_ATTRIBUTE13                                               VARCHAR2(150);
   V_ATTRIBUTE14                                               VARCHAR2(150);
   V_ATTRIBUTE15                                               VARCHAR2(150);
   V_LAST_UPDATE_DATE                                          DATE;
   V_LAST_UPDATED_BY                                           NUMBER;
   V_LAST_UPDATE_LOGIN                                         NUMBER;
   V_CREATION_DATE                                             DATE;
   V_CREATED_BY                                                NUMBER;
   V_PRORATION_RULE                                            NUMBER;       --added for BUG#2102098
   V_NO_OF_MONTHS                                              NUMBER ;      --added for BUG#2102098
   V_AVG_ANNUAL_BASE_RENT                                      NUMBER := 0;  --added for BUG#2102098
   V_AVG_MONTHLY_BASE_RENT                                     NUMBER := 0;  --added for BUG#2102098
   V_AVG_MONTHLY_OPERATING_EXP                                 NUMBER:=0;    --added for BUG#2102098
   V_AVG_ANNUAL_OPERATING_EXP                                  NUMBER:=0;    --added for BUG#2102098

   l_cursor                                                    INTEGER;
   l_rows                                                      INTEGER;
   l_count                                                     INTEGER;
   l_lease_resp_user                                           VARCHAR2(100);
   l_location_code_low                                         VARCHAR2(90);
   l_location_code_high                                        VARCHAR2(90);
   l_lease_type                                                VARCHAR2(30);
   l_lease_number_low                                          VARCHAR2(30);
   l_lease_number_high                                         VARCHAR2(30);
   l_lease_termination_from                                    DATE;
   l_lease_termination_to                                      DATE;
   l_lease_status                                              VARCHAR2(1);
   l_lease_class                                               VARCHAR2(30);
   l_statement                                                 VARCHAR2(10000);



--declare the record type for the function here.........
v_code_data                  PNP_UTIL_FUNC.location_name_rec := NULL;
-- declare cursors.....
CURSOR pterm (V_LEASE_ID IN NUMBER) IS
  SELECT payment_term_id,start_date,END_date,payment_term_type_code,vENDor_id,vENDor_site_id,
         customer_id, customer_site_use_id
  FROM   pn_payment_terms_all
  WHERE  lease_id = V_LEASE_ID;

CURSOR pitem(V_LEASE_ID IN NUMBER) IS
  SELECT SUM(NVL(ppi.estimated_amount,ppi.actual_amount))  amount
  FROM pn_payment_items_all ppi, pn_payment_terms_all ppt, pn_payment_schedules_all pps
  WHERE ppi.payment_term_id                = ppt.payment_term_id
    AND ppi.payment_schedule_id            = pps.payment_schedule_id
    AND ppt.lease_id                       = V_LEASE_ID
    AND pps.lease_id                       = V_LEASE_ID
    AND ppi.payment_item_type_lookup_code  = 'CASH'
    AND ppt.payment_term_type_code         = 'BASER';

CURSOR pitem1(V_LEASE_ID IN NUMBER) IS
  SELECT SUM(NVL(ppi.estimated_amount,ppi.actual_amount))  amount
  FROM pn_payment_items_all ppi, pn_payment_terms_all ppt, pn_payment_schedules_all pps
  WHERE ppi.payment_term_id                = ppt.payment_term_id
    AND ppi.payment_schedule_id            = pps.payment_schedule_id
    AND ppt.lease_id                       = V_LEASE_ID
    AND pps.lease_id                       = V_LEASE_ID
    AND ppi.payment_item_type_lookup_code  = 'CASH'
    AND ppt.payment_term_type_code         = 'DEP';

CURSOR pitem2(V_LEASE_ID IN NUMBER) IS
  SELECT SUM(NVL(ppi.estimated_amount,ppi.actual_amount))  amount
  FROM pn_payment_items_all ppi, pn_payment_terms_all ppt, pn_payment_schedules_all pps
  WHERE ppi.payment_term_id                = ppt.payment_term_id
    AND ppi.payment_schedule_id            = pps.payment_schedule_id
    AND ppt.lease_id                       = V_LEASE_ID
    AND pps.lease_id                       = V_LEASE_ID
    AND ppi.payment_item_type_lookup_code  = 'CASH'
    AND ppt.payment_term_type_code         = 'OEXP';

CURSOR pitem3(V_LEASE_ID IN NUMBER) IS
  SELECT SUM(NVL(ppi.estimated_amount,ppi.actual_amount))  amount
  FROM pn_payment_items_all ppi, pn_payment_terms_all ppt
  WHERE ppi.payment_term_id               = ppt.payment_term_id
    AND ppt.lease_id                      = V_LEASE_ID
    AND ppi.payment_item_type_lookup_code = 'CASH';

CURSOR pitem4(V_LEASE_ID IN NUMBER) IS
  SELECT SUM(NVL(ppi.estimated_amount,ppi.actual_amount))  amount
  FROM pn_payment_items_all ppi, pn_payment_terms_all ppt
  WHERE ppi.payment_term_id               = ppt.payment_term_id
    AND ppt.lease_id                      = V_LEASE_ID
    AND ppi.payment_item_type_lookup_code = 'CASH'
    AND (ppi.transferred_to_ap_flag       = 'Y' OR
         ppi.transferred_to_ar_flag       = 'Y') ;   --  Bug # 1671866

BEGIN

 PNP_DEBUG_PKG.put_log_msg('pn_rentroll_where_cond_set(+)');

--Initialise status parameters...
  retcode:=0;
  errbuf:='';
  fnd_profile.get('LOGIN_ID', l_login_id);

  l_cursor := dbms_sql.open_cursor;
--lease responsible user conditions....
  l_lease_resp_user := lease_resp_user;
  IF lease_resp_user IS NOT NULL THEN
   les_resp_user_where_clause := ' AND fnd4.user_name = :l_lease_resp_user';
  ELSE les_resp_user_where_clause:=' AND 1=1 ';
  END IF;

--location code conditions.....
l_location_code_low  := location_code_low;
l_location_code_high := location_code_high;

IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
   location_code_where_clause := ' WHERE loc.location_code  BETWEEN
   :l_location_code_low AND :l_location_code_high';
 ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
       location_code_where_clause := ' WHERE loc.location_code =
       :l_location_code_high';
 ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
        location_code_where_clause := ' WHERE loc.location_code =
        :l_location_code_low';
 ELSE  location_code_where_clause := ' WHERE 2=2 ';
END IF;

--lease type conditions....
l_lease_type := lease_type;
IF lease_type IS NOT NULL THEN
   lease_type_where_clause:= ' AND les.lease_type_code = :l_lease_type';
ELSE lease_type_where_clause:=' AND 3=3 ';
END IF;

--lease number conditions.....

  l_lease_number_low := lease_number_low;
  l_lease_number_high := lease_number_high;

IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   lease_number_where_clause := ' AND les.lease_num  BETWEEN
   :l_lease_number_low AND :l_lease_number_high';
ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
   lease_number_where_clause := ' AND les.lease_num = :l_lease_number_high';
ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
   lease_number_where_clause := ' AND les.lease_num = :l_lease_number_low';
ELSE  lease_number_where_clause := ' AND 4=4 ';

END IF;

--lease date conditions.....
l_lease_termination_from :=  lease_termination_from;
l_lease_termination_to   :=  lease_termination_to;
IF lease_termination_from IS NOT NULL AND lease_termination_to IS NOT NULL THEN
   lease_date_where_clause := ' AND les.lease_termination_date  BETWEEN :l_lease_termination_from
                                                                   AND :l_lease_termination_to';
ELSIF lease_termination_from IS NULL AND lease_termination_to IS NOT NULL THEN
        lease_date_where_clause := ' AND les.lease_termination_date =
        :l_lease_termination_to';
ELSIF lease_termination_from IS NOT NULL AND lease_termination_to IS NULL THEN
        lease_date_where_clause := ' AND les.lease_termination_date =
        :l_lease_termination_from';
ELSE  lease_date_where_clause := ' AND 5=5 ';
END IF;

--lease status conditions.....
l_lease_status := lease_status;
IF lease_status IS NOT NULL THEN
   lease_status_where_clause := 'AND les.status = :l_lease_status';
ELSE lease_status_where_clause := ' AND 6=6 ';
END IF;

--lease class conditions..... bug#2099864
l_lease_class := lease_class;
IF lease_class IS NOT NULL THEN
   lease_class_where_clause := 'AND les.lease_class_code = :l_lease_class';
ELSE lease_class_where_clause := ' AND 7=7 ';
END IF;

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_where_cond_set(-)');
  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_open_c_lease_pn(+)');


  -- Adding to where clause in pn_locations in order to select
  -- the location that is active
  --  for that lease period

  l_location_date_clause := 'AND loc.active_start_date <= ldet.lease_commencement_date ' ;
  l_location_date_clause := l_location_date_clause ||
                            ' AND loc.active_END_date >= ldet.lease_termination_date ';

--lease cursor.....

l_statement :=
'SELECT
  distinct
  ten.location_id                                  LOCATION_ID,
  fnd2.meaning                                     USAGE_TYPE,
  les.lease_id                                     LEASE_ID,
  les.name                                         LEASE_NAME,
  les.lease_num                                    LEASE_NUMBER,
  ldet.lease_commencement_date                     LEASE_COMMENCEMENT_DATE,
  ldet.lease_termination_date                      LEASE_TERMINATION_DATE,
  ldet.lease_execution_date                        LEASE_EXECUTION_DATE,
  (TRUNC(ldet.lease_termination_date)- TRUNC(ldet.lease_commencement_date)+1) LEASE_TERM,
  fnd1.meaning                                     LEASE_CLASS,
  les.lease_class_code                             LEASE_CLASS_1,       --bug#2099864
  fnd4.user_name                                   LEASE_RESPONSIBLE_USER,
  fnd.meaning                                      LEASE_STATUS,
  fnd3.meaning                                     LEASE_TYPE,
  ten.estimated_occupancy_date                     ESTIMATED_OCCUPANCY_DATE,
  ten.occupancy_date                               OCCUPANCY_DATE,
  ten.attribute_category                           ATTRIBUTE_CATEGORY,
  ten.attribute1                                   ATTRIBUTE1,
  ten.attribute2                                   ATTRIBUTE2,
  ten.attribute3                                   ATTRIBUTE3,
  ten.attribute4                                   ATTRIBUTE4,
  ten.attribute5                                   ATTRIBUTE5,
  ten.attribute6                                   ATTRIBUTE6,
  ten.attribute7                                   ATTRIBUTE7,
  ten.attribute8                                   ATTRIBUTE8,
  ten.attribute9                                   ATTRIBUTE9,
  ten.attribute10                                  ATTRIBUTE10,
  ten.attribute11                                  ATTRIBUTE11,
  ten.attribute12                                  ATTRIBUTE12,
  ten.attribute13                                  ATTRIBUTE13,
  ten.attribute14                                  ATTRIBUTE14,
  ten.attribute15                                  ATTRIBUTE15,
  ldet.last_update_date                            LAST_UPDATE_DATE,
  ldet.last_updated_by                             LAST_UPDATED_BY,
  ldet.last_update_login                           LAST_UPDATE_LOGIN,
  ldet.creation_date                               CREATION_DATE,
  ldet.created_by                                  CREATED_BY,
  les.payment_term_proration_rule                  PRORATION_RULE     -- added for bug#2102098
 FROM    pn_lease_details   ldet,
         pn_tenancies_all        ten,
         fnd_lookups             fnd,
         fnd_lookups             fnd1,
         fnd_lookups             fnd2,
         fnd_lookups             fnd3,
         fnd_user                fnd4,
         pn_leases_all           les
 WHERE ten.lease_id     = les.lease_id
   AND les.lease_id     = ldet.lease_id
   AND ten.primary_flag = '||'''' || 'Y'||''''||'
   AND les.status = fnd.lookup_code
   AND fnd.lookup_type = '||''''||'PN_LEASE_STATUS_TYPE'||''''||'
   AND fnd1.lookup_code = les.lease_class_code
   AND fnd1.lookup_type = '||''''||'PN_LEASE_CLASS'||''''||'
   AND fnd2.lookup_code = ten.tenancy_usage_lookup_code
   AND fnd2.lookup_type = '||''''||'PN_TENANCY_USAGE_TYPE'||''''||'
   AND fnd3.lookup_code = les.lease_type_code
   AND fnd3.lookup_type = '||''''||'PN_LEASE_TYPE'||''''||'
   AND fnd4.user_id     = ldet.responsible_user
   AND ten.location_id IN(SELECT loc.location_id from pn_locations loc'||location_code_where_clause||' ' ||
   l_location_date_clause ||')'
   ||les_resp_user_where_clause
   ||lease_type_where_clause
   ||lease_number_where_clause
   ||lease_date_where_clause
   ||lease_status_where_clause
   ||lease_class_where_clause
   ||'ORDER BY les.lease_class_code';


  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_open_c_lease_pn(-)');

  dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);

  --lease responsible user conditions....

IF lease_resp_user IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_resp_user',l_lease_resp_user);
END IF;


--location code conditions.....
IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
   dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
 ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
 ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
END IF;

--lease type conditions....
IF lease_type IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_type',l_lease_type);
END IF;

--lease number conditions.....
IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
END IF;

--lease date conditions.....
IF lease_termination_from IS NOT NULL AND lease_termination_to IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_from',l_lease_termination_from);
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_to',l_lease_termination_to);
ELSIF lease_termination_from IS NULL AND lease_termination_to IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_to',l_lease_termination_to);
ELSIF lease_termination_from IS NOT NULL AND lease_termination_to IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_from',l_lease_termination_from);
END IF;


--lease status conditions.....
IF lease_status IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_status',l_lease_status);
END IF;

--lease class conditions..... bug#2099864
IF lease_class IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_class',l_lease_class);
END IF;

   dbms_sql.define_column (l_cursor,1,V_LOCATION_ID_1);
   dbms_sql.define_column (l_cursor,2,V_SPACE_TYPE,80);
   dbms_sql.define_column (l_cursor,3,V_LEASE_ID);
   dbms_sql.define_column (l_cursor,4,V_LEASE_NAME,50);
   dbms_sql.define_column (l_cursor,5,V_LEASE_NUMBER,30);
   dbms_sql.define_column (l_cursor,6,V_LEASE_COM_DATE);
   dbms_sql.define_column (l_cursor,7,V_LEASE_TERM_DATE);
   dbms_sql.define_column (l_cursor,8,V_LEASE_EXE_DATE);
   dbms_sql.define_column (l_cursor,9,V_LEASE_TERM);
   dbms_sql.define_column (l_cursor,10,V_LEASE_CLASS,80);
   dbms_sql.define_column (l_cursor,11,V_LEASE_CLASS_CODE,30);
   dbms_sql.define_column (l_cursor,12,V_LEASE_RESP_USER,100);
   dbms_sql.define_column (l_cursor,13,V_LEASE_STATUS,80);
   dbms_sql.define_column (l_cursor,14,V_LEASE_TYPE,80);
   dbms_sql.define_column (l_cursor,15,V_ESTIMATED_OCCUPANCY_DATE);
   dbms_sql.define_column (l_cursor,16,V_ACTUAL_OCCUPANCY_DATE);
   dbms_sql.define_column (l_cursor,17,V_ATTRIBUTE_CATEGORY,30);
   dbms_sql.define_column (l_cursor,18,V_ATTRIBUTE1,150);
   dbms_sql.define_column (l_cursor,19,V_ATTRIBUTE2,150);
   dbms_sql.define_column (l_cursor,20,V_ATTRIBUTE3,150);
   dbms_sql.define_column (l_cursor,21,V_ATTRIBUTE4,150);
   dbms_sql.define_column (l_cursor,22,V_ATTRIBUTE5,150);
   dbms_sql.define_column (l_cursor,23,V_ATTRIBUTE6,150);
   dbms_sql.define_column (l_cursor,24,V_ATTRIBUTE7,150);
   dbms_sql.define_column (l_cursor,25,V_ATTRIBUTE8,150);
   dbms_sql.define_column (l_cursor,26,V_ATTRIBUTE9,150);
   dbms_sql.define_column (l_cursor,27,V_ATTRIBUTE10,150);
   dbms_sql.define_column (l_cursor,28,V_ATTRIBUTE11,150);
   dbms_sql.define_column (l_cursor,29,V_ATTRIBUTE12,150);
   dbms_sql.define_column (l_cursor,30,V_ATTRIBUTE13,150);
   dbms_sql.define_column (l_cursor,31,V_ATTRIBUTE14,150);
   dbms_sql.define_column (l_cursor,32,V_ATTRIBUTE15,150);
   dbms_sql.define_column (l_cursor,33,V_LAST_UPDATE_DATE);
   dbms_sql.define_column (l_cursor,34,V_LAST_UPDATED_BY);
   dbms_sql.define_column (l_cursor,35,V_LAST_UPDATE_LOGIN);
   dbms_sql.define_column (l_cursor,36,V_CREATION_DATE);
   dbms_sql.define_column (l_cursor,37,V_CREATED_BY);
   dbms_sql.define_column (l_cursor,38,V_PRORATION_RULE);

   l_rows   := dbms_sql.execute(l_cursor);



  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_c_lease_pn_loop(+)');
LOOP  --start lease loop....

 l_count := dbms_sql.fetch_rows( l_cursor );

 EXIT WHEN l_count <> 1;

   dbms_sql.column_value (l_cursor,1,V_LOCATION_ID_1);
   dbms_sql.column_value (l_cursor,2,V_SPACE_TYPE);
   dbms_sql.column_value (l_cursor,3,V_LEASE_ID);
   dbms_sql.column_value (l_cursor,4,V_LEASE_NAME);
   dbms_sql.column_value (l_cursor,5,V_LEASE_NUMBER);
   dbms_sql.column_value (l_cursor,6,V_LEASE_COM_DATE);
   dbms_sql.column_value (l_cursor,7,V_LEASE_TERM_DATE);
   dbms_sql.column_value (l_cursor,8,V_LEASE_EXE_DATE);
   dbms_sql.column_value (l_cursor,9,V_LEASE_TERM);
   dbms_sql.column_value (l_cursor,10,V_LEASE_CLASS);
   dbms_sql.column_value (l_cursor,11,V_LEASE_CLASS_CODE);
   dbms_sql.column_value (l_cursor,12,V_LEASE_RESP_USER);
   dbms_sql.column_value (l_cursor,13,V_LEASE_STATUS);
   dbms_sql.column_value (l_cursor,14,V_LEASE_TYPE);
   dbms_sql.column_value (l_cursor,15,V_ESTIMATED_OCCUPANCY_DATE);
   dbms_sql.column_value (l_cursor,16,V_ACTUAL_OCCUPANCY_DATE);
   dbms_sql.column_value (l_cursor,17,V_ATTRIBUTE_CATEGORY);
   dbms_sql.column_value (l_cursor,18,V_ATTRIBUTE1);
   dbms_sql.column_value (l_cursor,19,V_ATTRIBUTE2);
   dbms_sql.column_value (l_cursor,20,V_ATTRIBUTE3);
   dbms_sql.column_value (l_cursor,21,V_ATTRIBUTE4);
   dbms_sql.column_value (l_cursor,22,V_ATTRIBUTE5);
   dbms_sql.column_value (l_cursor,23,V_ATTRIBUTE6);
   dbms_sql.column_value (l_cursor,24,V_ATTRIBUTE7);
   dbms_sql.column_value (l_cursor,25,V_ATTRIBUTE8);
   dbms_sql.column_value (l_cursor,26,V_ATTRIBUTE9);
   dbms_sql.column_value (l_cursor,27,V_ATTRIBUTE10);
   dbms_sql.column_value (l_cursor,28,V_ATTRIBUTE11);
   dbms_sql.column_value (l_cursor,29,V_ATTRIBUTE12);
   dbms_sql.column_value (l_cursor,30,V_ATTRIBUTE13);
   dbms_sql.column_value (l_cursor,31,V_ATTRIBUTE14);
   dbms_sql.column_value (l_cursor,32,V_ATTRIBUTE15);
   dbms_sql.column_value (l_cursor,33,V_LAST_UPDATE_DATE);
   dbms_sql.column_value (l_cursor,34,V_LAST_UPDATED_BY);
   dbms_sql.column_value (l_cursor,35,V_LAST_UPDATE_LOGIN);
   dbms_sql.column_value (l_cursor,36,V_CREATION_DATE);
   dbms_sql.column_value (l_cursor,37,V_CREATED_BY);
   dbms_sql.column_value (l_cursor,38,V_PRORATION_RULE);

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_open_c_loc_pn(+)');
OPEN c_loc_pn FOR
SELECT
  distinct
  loc.location_id                                      LOCATION_ID,
  loc.active_start_date                                ACTIVE_START_DATE,
  fnd1.meaning                                         LOCATION_TYPE,
  NVL(NVL(loc.building, loc.FLOOR), loc.office)        LOCATION_NAME,
  loc.location_code                                    LOCATION_CODE,
  pa.address_line1||pa.address_line2||pa.address_line3||pa.address_line4||pa.county||pa.city||pa.state||pa.province||pa.zip_code||pa.country               ADDRESS,
  pa.county                                            COUNTY,
  pa.city                                              CITY,
  pa.state                                             STATE,
  pa.province                                          PROVINCE,
  pa.zip_code                                          ZIP_CODE,
  pa.country                                           COUNTRY,
  DECODE (location_type_lookup_code,'OFFICE',loc.rentable_area,
          'FLOOR',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id, loc.active_start_date),
          'PARCEL',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id, loc.active_start_date),
          'BUILDING',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id, loc.active_start_date),
          'LAND',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id, loc.active_start_date),
                rentable_area)                         RENTABLE_AREA,
  DECODE (location_type_lookup_code,'OFFICE',loc.usable_area,
          'FLOOR',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id, loc.active_start_date),
          'PARCEL',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id, loc.active_start_date),
          'BUILDING',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id, loc.active_start_date),
          'LAND',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id, loc.active_start_date),
                usable_area)                           USABLE_AREA,
  loc.gross_area                                       GROSS_AREA,
  fnd.meaning                                          TENURE
FROM pn_locations_all       loc,
     pn_addresses_all       pa,
     fnd_lookups            fnd,
     fnd_lookups            fnd1
WHERE pa.address_id(+) = loc.address_id
  AND loc.lease_or_owned = fnd.lookup_code(+)
  AND fnd.lookup_type(+) = 'PN_LEASED_OR_OWNED'
  AND fnd1.lookup_code(+) = loc.location_type_lookup_code
  AND fnd1.lookup_type(+) = 'PN_LOCATION_TYPE'
  AND loc.location_id  = V_LOCATION_ID_1;

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_open_c_loc_pn(-)');
  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_c_loc_pn_loop(+)');
LOOP --start location loop
 FETCH c_loc_pn INTO V_LOCATION_ID                              ,
                     V_ACTIVE_START_DATE                        ,
                     V_LOCATION_TYPE                            ,
                     V_LOCATION_NAME                            ,
                     V_LOCATION_CODE                            ,
                     V_ADDRESS                                  ,
                     V_COUNTY                                   ,
                     V_CITY                                     ,
                     V_STATE                                    ,
                     V_PROVINCE                                 ,
                     V_ZIP_CODE                                 ,
                     V_COUNTRY                                  ,
                     V_RENTABLE_AREA                            ,
                     V_USABLE_AREA                              ,
                     V_GROSS_AREA                               ,
                     V_TENURE                                   ;
 EXIT WHEN c_loc_pn%notfound;

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_payment_term_loop(+)');

--bug#2099864
/* This IF condition eliminates the need for the earlier existing 2 loops -
   one for 'DIRECT' leases and the other for not 'DIRECT'.
   IF Lease Class is 'DIRECT', get Customer info,
   ELSE get VENDor info.
*/

IF ( V_LEASE_CLASS_CODE = 'DIRECT' ) THEN

 V_CUSTOMER_ID    := NULL;
 V_CUSTOMER_SITE  := NULL;
 V_CUSTOMER_NAME  := NULL;
FOR c IN pterm(V_LEASE_ID)
 LOOP --Payment Term Loop
  SELECT
   pv.vENDor_id                                                     VENDOR_ID,
   pvs.vENDor_site_code                                             VENDOR_SITE,
   pv.vENDor_name                                                   VENDOR_NAME,
   pvs.address_line1||pvs.address_line2||pvs.address_line3||pvs.address_line4||pvs.county||pvs.city||pvs.state||pvs.province||pvs.zip||pvs.country       INVOICING_ADDRESS
  INTO V_VENDOR_ID        ,
     V_VENDOR_SITE      ,
     V_VENDOR_NAME      ,
     V_INVOICING_ADDRESS
  FROM po_vENDors       pv,
       po_vENDor_sites  pvs
  WHERE pv.vENDor_id       = pvs.vENDor_id
    AND pvs.vENDor_id      = c.vENDor_id
    AND pvs.vENDor_site_id = c.vENDor_site_id;
 END LOOP;   -- END Payment Term Loop

ELSIF ( V_LEASE_CLASS_CODE IN ( 'SUB_LEASE', 'THIRD_PARTY' )) THEN

 V_VENDOR_ID   := NULL;
 V_VENDOR_SITE := NULL;
 V_VENDOR_NAME := NULL;
FOR t IN pterm(V_LEASE_ID)
 LOOP --Payment Term Loop
  SELECT
   hca.cust_account_id                                   CUSTOMER_ID,
   hcs.location                                          CUSTOMER_SITE_ID,
   hp.party_name                                         CUSTOMER_NAME,
   hp.address1||hp.address2||hp.address3||hp.address4||hp.county||hp.city||hp.state||hp.province||hp.postal_code||hp.country                                 INVOICING_ADDRESS
  INTO V_CUSTOMER_ID,
     V_CUSTOMER_SITE,
     V_CUSTOMER_NAME,
     V_INVOICING_ADDRESS
  FROM hz_parties       hp,
     hz_cust_accounts hca,
     hz_cust_site_uses hcs
  WHERE hca.cust_account_id = t.customer_id
    AND hcs.site_use_id     = t.customer_site_use_id
    AND hca.party_id        = hp.party_id;
 END LOOP;   -- END Payment Term Loop

END IF;

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_payment_term_loop(-)');

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_pop_vari(+)');


FOR w IN pitem(V_LEASE_ID)
 LOOP
   V_ANNUAL_BASE_RENT:= w.amount;
 END LOOP;

FOR x IN pitem1(V_LEASE_ID)
 LOOP
   V_DEPOSIT:= x.amount;
 END LOOP;

FOR y IN pitem2(V_LEASE_ID)
 LOOP
   V_ANNUAL_OPERATING_EXPENSES:= y.amount;
 END LOOP;

FOR z IN pitem3(V_LEASE_ID)
 LOOP
   V_TOTAL_LEASE_LIABILITY:= z.amount;
 END LOOP;

FOR z1 in pitem4(V_LEASE_ID)
 LOOP
   V_AMOUNT_EXPORTED:= NVL(z1.amount,0);
 END LOOP;

 --BUG#2102098 calculate the effective no of months


IF V_PRORATION_RULE = 999 THEN
    select  MONTHS_BETWEEN(LAST_DAY(ADD_MONTHS(V_LEASE_TERM_DATE,-1)),LAST_DAY(V_LEASE_COM_DATE)) +
    ROUND(TO_CHAR(TO_DATE(V_LEASE_TERM_DATE,'DD/MM/YY'),'DD')/TO_CHAR(TO_DATE(LAST_DAY(V_LEASE_TERM_DATE),'DD/MM/YY'),'DD'),3)
    + ROUND((TO_CHAR(TO_DATE(LAST_DAY(V_LEASE_COM_DATE),'DD/MM/YY'),'DD')-TO_CHAR(TO_DATE(V_LEASE_COM_DATE,'DD/MM/YY'),'DD')+1)/
    TO_CHAR(TO_DATE(LAST_DAY(V_LEASE_COM_DATE),'DD/MM/YY'),'DD'),3)
    into v_no_of_months from dual;

ELSIF V_PRORATION_RULE IN ( 365, 360 ) THEN
IF v_lease_term_date = v_lease_com_date THEN
   SELECT ROUND(1/(V_PRORATION_RULE/12),3) INTO v_no_of_months FROM dual;
ELSIF TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'dd') =1
      AND LAST_DAY(v_lease_term_date) = v_lease_term_date THEN
     SELECT ROUND(MONTHS_BETWEEN(v_lease_term_date,v_lease_com_date),0) INTO v_no_of_months FROM dual;
ELSIF TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'dd') =1 AND
      TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'mmyy') <TO_CHAR(TO_DATE(v_lease_term_date,'dd/mm/yy'),'mmyy') THEN
    SELECT ROUND(MONTHS_BETWEEN(LAST_DAY(ADD_MONTHS(v_lease_term_date,-1)),v_lease_com_date),0)
    +ROUND((TO_CHAR(TO_DATE(v_lease_term_date,'dd/mm/yy'),'dd'))/(V_PRORATION_RULE/12),3) INTO v_no_of_months FROM dual;
ELSIF LAST_DAY(v_lease_term_date) =v_lease_term_date AND
      TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'mmyy') < TO_CHAR(TO_DATE(v_lease_term_date,'dd/mm/yy'),'mmyy') THEN
      SELECT MONTHS_BETWEEN(v_lease_term_date,LAST_DAY(v_lease_com_date))+
     ROUND((TO_CHAR(TO_DATE(LAST_DAY(v_lease_com_date),'dd/mm/yy'),'dd')
     -TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'dd')+1)/(V_PRORATION_RULE/12),3) INTO v_no_of_months FROM dual;
ELSIF TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'mmyy') =TO_CHAR(TO_DATE(v_lease_term_date,'dd/mm/yy'),'mmyy') THEN
      SELECT ROUND((TO_CHAR(TO_DATE(v_lease_term_date,'dd/mm/yy'),'dd') - TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'dd') +1)/
      (V_PRORATION_RULE/12),3) INTO v_no_of_months FROM dual;
ELSE
    SELECT ROUND(MONTHS_BETWEEN(LAST_DAY(ADD_MONTHS(v_lease_term_date,-1)),LAST_DAY(v_lease_com_date)),0)
    +ROUND((TO_CHAR(TO_DATE(v_lease_term_date,'dd/mm/yy'),'dd'))/(V_PRORATION_RULE/12),3)
    + ROUND((TO_CHAR(TO_DATE(LAST_DAY(v_lease_com_date),'dd/mm/yy'),'dd')-TO_CHAR(TO_DATE(v_lease_com_date,'dd/mm/yy'),'dd')+1)
    /(V_PRORATION_RULE/12),3) INTO v_no_of_months FROM dual;
END IF;

END IF;

V_AVG_ANNUAL_BASE_RENT  := ROUND(V_ANNUAL_BASE_RENT *12/V_NO_OF_MONTHS,2)  ;           --ADDED FOR BUG#2102098
V_AVG_ANNUAL_OPERATING_EXP := ROUND(V_ANNUAL_OPERATING_EXPENSES *12/V_NO_OF_MONTHS,2) ; --ADDED FOR BUG#2102098
V_AVG_MONTHLY_BASE_RENT          := ROUND(V_AVG_ANNUAL_BASE_RENT/12,2);                 --BUG#2102098
V_AVG_MONTHLY_OPERATING_EXP := ROUND(V_AVG_ANNUAL_OPERATING_EXP/12,2);                  --BUG#2102098
IF NVL(V_RENTABLE_AREA,0) <> 0 then
    V_ANNUAL_RENT_PER_RENT_AREA  := TRUNC((V_ANNUAL_BASE_RENT)/(V_RENTABLE_AREA),3);
ELSE
    V_ANNUAL_RENT_PER_RENT_AREA := NULL;
END IF;

v_code_data                  :=pnp_util_func.get_location_name(V_LOCATION_ID, V_ACTIVE_START_DATE);
  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_pop_vari(-)');
  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_insert1(+)');


INSERT INTO pn_rent_roll_lease_exp_itf
 (LEASE_ID                                      ,
 LEASE_NAME                                     ,
 LEASE_NUMBER                                   ,
 LEASE_COMMENCEMENT_DATE                        ,
 LEASE_TERMINATION_DATE                         ,
 LEASE_EXECUTION_DATE                           ,
 LEASE_TERM                                     ,
 LEASE_CLASS                                    ,
 LEASE_RESPONSIBLE_USER                         ,
 LEASE_STATUS                                   ,
 LEASE_TYPE                                     ,
 ESTIMATED_OCCUPANCY_DATE                       ,
 ACTUAL_OCCUPANCY_DATE                          ,
 TENANT_NAME                                    ,
 TENANT_SITE                                    ,
 LANDLORD_NAME                                  ,
 LANDLORD_SITE                                  ,
 ANNUAL_BASE_RENT                               ,
 MONTHLY_BASE_RENT                              ,
 DEPOSIT                                        ,
 MONTHLY_OPERATING_EXPENSE                      ,
 TOTAL_LEASE_LIABILITY                          ,
 REMAINING_LEASE_LIABILITY                      ,
 ANNUAL_RENT_PER_RENTABLE_AREA                  ,
 INVOICING_ADDRESS                              ,
 LOCATION_ID                                    ,
 LOCATION_TYPE                                  ,
 LOCATION_NAME                                  ,
 LOCATION_CODE                                  ,
 SPACE_TYPE                                     ,
 REGION                                         ,
 PROPERTY_NAME                                  ,
 BUILDING_OR_LAND_NAME                          ,
 FLOOR_OR_PARCEL_NAME                           ,
 OFFICE_OR_SECTION_NAME                         ,
 ADDRESS                                        ,
 COUNTY                                         ,
 CITY                                           ,
 STATE                                          ,
 PROVINCE                                       ,
 ZIP_CODE                                       ,
 COUNTRY                                        ,
 GROSS_AREA                                     ,
 RENTABLE_AREA                                  ,
 USABLE_AREA                                    ,
 TENURE                                         ,
 TEN_ATTRIBUTE_CATEGORY                         ,
 TEN_ATTRIBUTE1                                 ,
 TEN_ATTRIBUTE2                                 ,
 TEN_ATTRIBUTE3                                 ,
 TEN_ATTRIBUTE4                                 ,
 TEN_ATTRIBUTE5                                 ,
 TEN_ATTRIBUTE6                                 ,
 TEN_ATTRIBUTE7                                 ,
 TEN_ATTRIBUTE8                                 ,
 TEN_ATTRIBUTE9                                 ,
 TEN_ATTRIBUTE10                                ,
 TEN_ATTRIBUTE11                                ,
 TEN_ATTRIBUTE12                                ,
 TEN_ATTRIBUTE13                                ,
 TEN_ATTRIBUTE14                                ,
 TEN_ATTRIBUTE15                                ,
 LAST_UPDATE_DATE                               ,
 LAST_UPDATED_BY                                ,
 LAST_UPDATE_LOGIN                              ,
 CREATION_DATE                                  ,
 CREATED_BY                                     ,
 REQUEST_ID                                     )
VALUES
 (V_LEASE_ID                                    ,
 V_LEASE_NAME                                   ,
 V_LEASE_NUMBER                                 ,
 V_LEASE_COM_DATE                               ,
 V_LEASE_TERM_DATE                              ,
 V_LEASE_EXE_DATE                               ,
 V_LEASE_TERM                                   ,
 V_LEASE_CLASS                                  ,
 V_LEASE_RESP_USER                              ,
 V_LEASE_STATUS                                 ,
 V_LEASE_TYPE                                   ,
 V_ESTIMATED_OCCUPANCY_DATE                     ,
 V_ACTUAL_OCCUPANCY_DATE                        ,
 V_CUSTOMER_NAME                                ,  --bug#2099864
 V_CUSTOMER_SITE                                ,  --bug#2099864
 V_VENDOR_NAME                                  ,
 V_VENDOR_SITE                                  ,
 V_AVG_ANNUAL_BASE_RENT                         ,    ---BUG#2102098 CHANGED FROM ANNUAL TO AVG
 V_AVG_MONTHLY_BASE_RENT                        ,   --- BUG #2102098  CHANGED FROM ANNUAL TO AVG
 V_DEPOSIT                                      ,
 V_AVG_MONTHLY_OPERATING_EXP                    ,    ---BUG #2102098 CHANGED FROM ANNUAL TO AVG
 V_TOTAL_LEASE_LIABILITY                        ,
 (V_TOTAL_LEASE_LIABILITY)-(V_AMOUNT_EXPORTED)  ,
 V_ANNUAL_RENT_PER_RENT_AREA                    ,
 V_INVOICING_ADDRESS                            ,
 V_LOCATION_ID                                  ,
 V_LOCATION_TYPE                                ,
 V_LOCATION_NAME                                ,
 V_LOCATION_CODE                                ,
 V_SPACE_TYPE                                   ,
 v_code_data.REGION_NAME                        ,
 v_code_data.PROPERTY_NAME                      ,
 v_code_data.BUILDING                           ,
 v_code_data.FLOOR                              ,
 v_code_data.OFFICE                             ,
 V_ADDRESS                                      ,
 V_COUNTY                                       ,
 V_CITY                                         ,
 V_STATE                                        ,
 V_PROVINCE                                     ,
 V_ZIP_CODE                                     ,
 V_COUNTRY                                      ,
 V_GROSS_AREA                                   ,
 V_RENTABLE_AREA                                ,
 V_USABLE_AREA                                  ,
 V_TENURE                                       ,
 V_ATTRIBUTE_CATEGORY                           ,
 V_ATTRIBUTE1                                   ,
 V_ATTRIBUTE2                                   ,
 V_ATTRIBUTE3                                   ,
 V_ATTRIBUTE4                                   ,
 V_ATTRIBUTE5                                   ,
 V_ATTRIBUTE6                                   ,
 V_ATTRIBUTE7                                   ,
 V_ATTRIBUTE8                                   ,
 V_ATTRIBUTE9                                   ,
 V_ATTRIBUTE10                                  ,
 V_ATTRIBUTE11                                  ,
 V_ATTRIBUTE12                                  ,
 V_ATTRIBUTE13                                  ,
 V_ATTRIBUTE14                                  ,
 V_ATTRIBUTE15                                  ,
 V_LAST_UPDATE_DATE                             ,
 V_LAST_UPDATED_BY                              ,
 V_LAST_UPDATE_LOGIN                            ,
 V_CREATION_DATE                                ,
 V_CREATED_BY                                   ,
 l_request_id                     );

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_insert1(-)');
  END LOOP; --END location loop...

  PNP_DEBUG_PKG.put_log_msg('pn_rentroll_c_loc_pn_loop(-)');
END LOOP; --END lease loop...
   PNP_DEBUG_PKG.put_log_msg('pn_rentroll_c_lease_pn_loop(-)');

IF dbms_sql.is_open (l_cursor) THEN
 dbms_sql.close_cursor (l_cursor);
END IF;


--IF there is something amiss...
EXCEPTION
WHEN OTHERS THEN
  retcode:=2;
  errbuf:=SUBSTR(SQLERRM,1,235);
  RAISE;
  COMMIT;
END pn_rent_les;
END pnrx_rent_les;

/
