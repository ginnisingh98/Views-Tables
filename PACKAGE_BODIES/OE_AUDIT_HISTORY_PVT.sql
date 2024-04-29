--------------------------------------------------------
--  DDL for Package Body OE_AUDIT_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_AUDIT_HISTORY_PVT" AS
/* $Header: OEXPPCHB.pls 120.20.12010000.8 2009/12/08 13:00:12 msundara ship $ */

-- START 8547934

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_PC_Constraints_Admin_Pvt';

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER,
    p_org_id                        IN  NUMBER DEFAULT NULL)
RETURN VARCHAR2 IS

l_inventory_item              VARCHAR2(240) := NULL;
l_validation_org_id           NUMBER        := NULL;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF p_inventory_item_id IS NOT NULL THEN

--Kris make a global variable for validation org so we don't have to get it all the time

	/*l_validation_org_id := fnd_profile.value('OE_ORGANIZATION_ID');*/
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
    l_validation_org_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID', p_org_id);

        SELECT  concatenated_segments
        INTO    l_inventory_item
        FROM    MTL_SYSTEM_ITEMS_kfv
        WHERE   INVENTORY_ITEM_ID = p_inventory_item_id
        AND     ORGANIZATION_ID = l_validation_org_id;

        oe_debug_pub.ADD('l_inventory_item');


    END IF;
    RETURN l_inventory_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

-- END BUG 7664601

FUNCTION id_to_value ( p_attribute_id  IN NUMBER,
                       attribute_value  IN varchar2,
		       p_context_value IN VARCHAR2 DEFAULT NULL,
		       p_org_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
l_attribute_code varchar2(80);
l_attribute_display_value varchar2(2000);
l_display_name varchar2(500);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    BEGIN
        SELECT ATTRIBUTE_DISPLAY_NAME,
               ATTRIBUTE_CODE
        INTO   l_display_name,
               l_attribute_code
        FROM   OE_PC_ATTRIBUTES_V
        WHERE  ATTRIBUTE_ID = p_attribute_id
        AND    APPLICATION_ID=660;
    EXCEPTION WHEN OTHERS THEN
        l_display_name:=NULL;
    END;

    if   l_attribute_code =  'SALESREP_ID' then
         BEGIN
           SELECT NAME
           INTO   l_attribute_display_value
           FROM   RA_SALESREPS
           WHERE  salesrep_id = attribute_value and org_id = p_org_id;

         EXCEPTION WHEN OTHERS THEN
           l_attribute_display_value := NULL;
         END;
    elsif l_attribute_code = 'SALES_CREDIT_TYPE_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Sales_credit_type(attribute_value);
    elsif l_attribute_code = 'ACCOUNTING_RULE_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.accounting_rule(attribute_value);
    elsif l_attribute_code = 'AGREEMENT_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.agreement(attribute_value);
    elsif l_attribute_code = 'CONVERSION_TYPE_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.conversion_type(attribute_value);
    elsif l_attribute_code = 'DELIVER_TO_CONTACT_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Deliver_to_contact(attribute_value);
    elsif l_attribute_code = 'DELIVER_TO_ORG_ID' then
          IF attribute_value is not null then
             BEGIN
               SELECT LOCATION
               INTO   l_attribute_display_value
               FROM   HZ_CUST_SITE_USES_ALL
               WHERE  site_use_id = attribute_value
               AND    SITE_USE_CODE = 'DELIVER_TO'
               AND    ROWNUM = 1;
             END;
          END IF;
    elsif l_attribute_code = 'FOB_POINT_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.fob_point(attribute_value);
    elsif l_attribute_code = 'FREIGHT_TERMS_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.freight_terms(attribute_value);
    elsif l_attribute_code = 'INVOICE_TO_CONTACT_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Invoice_to_contact(attribute_value);
    elsif l_attribute_code = 'INVOICE_TO_ORG_ID' then
          IF attribute_value is not null then
             BEGIN
               SELECT LOCATION
               INTO   l_attribute_display_value
               FROM   HZ_CUST_SITE_USES_ALL
               WHERE  site_use_id = attribute_value
               AND    SITE_USE_CODE = 'BILL_TO'
               AND    ROWNUM = 1;
             END;
          END IF;
    elsif l_attribute_code = 'INVOICING_RULE_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Invoicing_rule(attribute_value);
    elsif l_attribute_code = 'ORDER_TYPE_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Order_type(attribute_value);
    elsif l_attribute_code = 'PAYMENT_TERM_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Payment_Term(attribute_value);
    elsif l_attribute_code = 'PRICE_LIST_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Price_List(attribute_value);
    elsif l_attribute_code = 'SHIPMENT_PRIORITY_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Shipment_Priority(attribute_value);
    elsif l_attribute_code = 'SHIP_FROM_ORG_ID' then
         IF attribute_value is not null then
            BEGIN
              SELECT name
              INTO   l_attribute_display_value
              FROM   HR_ORGANIZATION_UNITS
              WHERE  organization_id = attribute_value
               AND    ROWNUM = 1;
            END;
         END IF;
    elsif l_attribute_code = 'SHIP_TO_CONTACT_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Ship_to_contact(attribute_value);
    elsif l_attribute_code = 'SHIP_TO_ORG_ID' then
         IF attribute_value is not null then
            BEGIN
               SELECT LOCATION
               INTO   l_attribute_display_value
               FROM   HZ_CUST_SITE_USES_ALL
               WHERE  site_use_id = attribute_value
               AND    SITE_USE_CODE = 'SHIP_TO'
               AND    ROWNUM = 1;
            END;
         END IF;
    elsif l_attribute_code = 'SOLD_TO_CONTACT_ID' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Sold_to_contact(attribute_value);
    elsif l_attribute_code = 'SOLD_TO_ORG_ID' then
         IF attribute_value is not null then
            BEGIN
              SELECT SUBSTR(HZP.PARTY_NAME,1,50) name
              INTO   l_attribute_display_value
              FROM   HZ_PARTIES HZP, HZ_CUST_ACCOUNTS HZC
              WHERE  HZC.cust_account_id = attribute_value
              AND    HZP.PARTY_ID = HZC.PARTY_ID;
            END;
         END IF;
    elsif l_attribute_code = 'TAX_EXEMPT_FLAG' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.tax_exempt(attribute_value);
    elsif l_attribute_code = 'TAX_EXEMPT_REASON_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.tax_exempt_reason(attribute_value);
    elsif l_attribute_code = 'RETURN_REASON_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Return_Reason(attribute_value);
    elsif l_attribute_code = 'SHIPPING_METHOD_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.Ship_method(attribute_value);
    elsif l_attribute_code = 'SOURCE_TYPE_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.source_type(attribute_value);
    elsif l_attribute_code = 'CALCULATE_PRICE_FLAG' then
         IF attribute_value in ('Y','N','P') THEN
            BEGIN
               SELECT meaning
               INTO   l_attribute_display_value
               FROM   OE_LOOKUPS
               WHERE  LOOKUP_TYPE = 'CALCULATE_PRICE_FLAG'
               AND    LOOKUP_CODE = attribute_value;
            END;
         ELSE
            l_attribute_display_value := NULL;
         END IF;
    elsif l_attribute_code = 'OVER_SHIP_REASON_CODE' then
         l_attribute_display_value :=
                OE_ID_TO_VALUE.over_ship_reason(attribute_value);
    elsif l_attribute_code = 'INVENTORY_ITEM_ID' then
         l_attribute_display_value :=
                -- OE_ID_TO_VALUE.Inventory_Item(attribute_value); Bug 8547934
                                  Inventory_Item(attribute_value,p_org_id);
    elsif l_attribute_code = 'DISCOUNT_ID' then
         if attribute_value is not null then
             BEGIN
                SELECT name
                INTO   l_attribute_display_value
                FROM   OE_DISCOUNTS_V
                WHERE  discount_id = attribute_value;
             END;
          end if;
    elsif l_attribute_code in ( 'OVER_SHIP_RESOLVED_FLAG',
                                'SHIP_MODEL_COMPLETE_FLAG',
                                'AUTHORIZED_TO_SHIP_FLAG',
                                'FULFILLED_FLAG',
                                'AUTOMATIC_FLAG',
                                'ACCRUAL_FLAG' ,
                                'INVOICE_COMPLETE_FLAG',
                                'PRINT_ON_INVOICE_FLAG',
                                'UPDATED_FLAG',
                                'INCLUDE_ON_RETURNS_FLAG',
                                'ESTIMATED_FLAG',
                                'APPLIED_FLAG') THEN
         IF attribute_value in ('Y','N') THEN
            BEGIN
              SELECT MEANING
              INTO   l_attribute_display_value
              FROM   OE_LOOKUPS
              WHERE  LOOKUP_TYPE = 'YES_NO'
              AND    LOOKUP_CODE = attribute_value;
            END;
         else
            l_attribute_display_value := NULL;
         end if;
    elsif l_attribute_code = 'USER_ID' then
        select user_name
        into l_attribute_display_value
        from fnd_user
        where user_id = attribute_value;
    elsif l_attribute_code = 'RESPONSIBILITY_ID' then
        if attribute_value is not null then
           select responsibility_name
           into l_attribute_display_value
           from fnd_responsibility_tl fr
           where fr.responsibility_id = attribute_value
           and   fr.application_id = FND_GLOBAL.RESP_APPL_ID
           and fr.language = userenv('LANG');
        else
           l_attribute_display_value := '';
        end if;
    elsif l_attribute_code = 'REASON_CODE' then
        if (attribute_value is not null) then
           select meaning
           into l_attribute_display_value
           from oe_lookups oel
           where oel.lookup_type = 'CANCEL_CODE'
           and oel.lookup_code = attribute_value;
        else
           l_attribute_display_value := null;
        end if;

    --bug#5631508
    ELSIF l_attribute_code = 'SHIP_SET_ID' or  l_attribute_code = 'ARRIVAL_SET_ID' THEN
           IF attribute_value IS NOT NULL THEN
              begin
                    SELECT set_name
                    INTO   l_attribute_display_value
                    FROM   OE_SETS_HISTORY
                    WHERE  set_id = attribute_value
		           and rownum<2;
              Exception
                when no_data_found then
                    SELECT set_name
                    INTO   l_attribute_display_value
                    FROM   OE_SETS
                    WHERE  set_id = attribute_value;
              End;
           END IF;
    else
        IF (p_attribute_id between 1078 and 1092 ) OR (p_attribute_id between 4218 and 4222) THEN
           l_attribute_display_value := OE_AUDIT_HISTORY_PVT.Get_Translated_Value(
                                    'OE_HEADER_ATTRIBUTES',
                                    UPPER(l_display_name),
                                    attribute_value,				  				     p_context_value );
        ELSIF (p_attribute_id between 1018 and 1032) OR (p_attribute_id between 4223 and 4227) THEN
           l_attribute_display_value := OE_AUDIT_HISTORY_PVT.Get_Translated_Value(
                                    'OE_LINE_ATTRIBUTES',
                                    UPPER(l_display_name),
                                    attribute_value,
				    p_context_value);
        ELSE
           l_attribute_display_value := attribute_value; --none of the above
        END IF;
    end if;
    RETURN l_attribute_display_value;
EXCEPTION WHEN OTHERS THEN
    l_attribute_display_value := attribute_value;
    RETURN attribute_value;
END ID_TO_VALUE;

PROCEDURE set_attribute_history (
   retcode           OUT NOCOPY /* file.sql.39 change */    varchar2,
   errbuf            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
   p_org_id          IN     NUMBER,
   start_date        IN     VARCHAR2,
   end_date          IN     VARCHAR2,
   order_number_from IN     NUMBER,
   order_number_to   IN     NUMBER,
   audit_duration    IN     NUMBER)
IS

/* Get all entity ids specific history views */
-- Not including entities greater than 1000 (blankets, payments)
CURSOR c_entities IS
SELECT ENTITY_ID
      ,decode(ENTITY_ID, 1, 'oe_order_header_history',

                         2, 'oe_order_lines_history',
                         5, 'oe_sales_credit_history',
                         6, 'oe_price_adjs_history',
                         7, 'oe_sales_credit_history',
                         8, 'oe_price_adjs_history') entity_name
	 ,ENTITY_DISPLAY_NAME
FROM  OE_PC_ENTITIES_V
WHERE APPLICATION_ID = 660
AND ENTITY_ID < 1000
ORDER BY ENTITY_ID;

/* select all constrainable attributes*/
CURSOR C_ALL_ATTRIBUTES (ent_id number) IS

SELECT OEV.ATTRIBUTE_ID
      ,OEV.ATTRIBUTE_CODE
      ,OEV.COLUMN_NAME
      ,OEV.ATTRIBUTE_DISPLAY_NAME
FROM  OE_PC_ATTRIBUTES_V OEV
WHERE OEV.ENTITY_ID = ent_id
AND   OEV.APPLICATION_ID = 660
AND   OEV.CONSTRAINTS_ENABLED_FLAG = 'Y';

/* Select currently constrained attributes only */
CURSOR C_CONST_ATTRIBUTES (ent_id number) IS
SELECT OEV.ATTRIBUTE_ID
      ,OEV.ATTRIBUTE_CODE
      ,OEV.COLUMN_NAME
      ,OEV.ATTRIBUTE_DISPLAY_NAME
FROM  OE_PC_ATTRIBUTES_V OEV
WHERE OEV.ENTITY_ID = ent_id
AND   OEV.APPLICATION_ID = 660
AND   OEV.CONSTRAINTS_ENABLED_FLAG = 'Y'
AND   EXISTS ( SELECT 'CONSTRAINT EXISTS FOR THIS COLUMN'
               FROM   OE_PC_CONSTRAINTS OEP
               WHERE  OEP.COLUMN_NAME = OEV.COLUMN_NAME
               AND    OEP.ON_OPERATION_ACTION IN (1,2)
               AND    OEP.ENTITY_ID = OEV.ENTITY_ID)
ORDER BY OEV.ATTRIBUTE_ID;


/* Check Whether the entity is constrained for update */
CURSOR IS_ENTITY_CONSTRAINED (v_ent_id NUMBER) IS
SELECT 'Y' -- There is an entity level constraint'
FROM   OE_PC_CONSTRAINTS
WHERE  ENTITY_ID = v_ent_id
AND    COLUMN_NAME IS NULL
AND    ON_OPERATION_ACTION IN (1,2)
AND    CONSTRAINED_OPERATION <> 'X';

TYPE  OE_ATTR_CONSTRAINED IS RECORD
      (ENTITY_ID              NUMBER,
       ATTRIBUTE_ID           NUMBER,
       ATTRIBUTE_CODE         VARCHAR2(50),
       COLUMN_NAME            VARCHAR2(150),
       ATTRIBUTE_DISPLAY_NAME VARCHAR2(250));

TYPE  OE_ATTR_CONSTR_TABLE IS TABLE OF OE_ATTR_CONSTRAINED INDEX BY BINARY_INTEGER;
TYPE  OE_PC_ATTRIBUTE_HISTORY_REC IS RECORD
     (ENTITY_ID          NUMBER,
      ATTRIBUTE_ID       NUMBER,
      ENTITY_NUMBER      NUMBER,
      ORDER_NUMBER       NUMBER,
      RESPONSIBILITY_ID  NUMBER,
      USER_ID            NUMBER,
      ORG_ID             NUMBER,
      ORDER_TYPE_ID      NUMBER,
      SOLD_TO_ORG_ID     NUMBER,
      HIST_CREATION_DATE DATE,
      REASON_CODE        VARCHAR2(80),
      OLD_ATTRIBUTE_VALUE VARCHAR2(2000),
      NEW_ATTRIBUTE_VALUE VARCHAR2(2000),
      CHANGE_COMMENTS     VARCHAR2(2000),
      OLD_CONTEXT_VALUE   VARCHAR2(30),
      NEW_CONTEXT_VALUE   VARCHAR2(30));

TYPE oe_pc_attribute_history_tbl IS TABLE OF oe_pc_attribute_history_rec

INDEX BY BINARY_INTEGER;

C_ATTR_TBL                OE_ATTR_CONSTR_TABLE;
oe_pc_attr_tbl            OE_PC_ATTRIBUTE_HISTORY_TBL;
min_hist_creation_date    DATE;   --start date for fetch
max_hist_creation_date    DATE;   --end date for fetch
l_attribute_value         VARCHAR2(2000); /* Attrb value, desc for current , old and last*/
l_old_attribute_value     VARCHAR2(2000);
l_attribute_value_last    VARCHAR2(2000);
l_hist_creation_date      DATE;
l_old_hist_creation_date  DATE;
l_hist_creation_date_last DATE;
l_context_value           VARCHAR2(30);
l_old_context_value       VARCHAR2(30);
l_context_value_last      VARCHAR2(30);
l_order_number            NUMBER;
l_entity_number           NUMBER;
l_org_id                  NUMBER;
l_user_id                 NUMBER;
l_old_user_id             NUMBER;
l_user_id_last            NUMBER;
l_responsibility_id       NUMBER;
l_responsibility_id_last  NUMBER;
l_old_responsibility_id   NUMBER;

l_reason_code             VARCHAR2(80);
l_reason_code_last        VARCHAR2(80);
l_old_reason_code         VARCHAR2(80);
l_order_type_id           NUMBER;
l_sold_to_org_id          NUMBER;
l_change_comments         VARCHAR2(2000);
l_old_db_rec_upd_flag     BOOLEAN;
l_order_number_last       NUMBER;
i_counter                 NUMBER; -- to track end of fetch
l_rec_counter             NUMBER; --to track not null records
l_ent_stmt                VARCHAR2(500); --entity specific where
l_ent_stmt_subquery       VARCHAR2(500); -- 4394119, entity specific where used for subqueries
l_sql_stmt                VARCHAR2(4000); --main loop
l_sql_stmt_last           VARCHAR2(4000); --last condition hist/transaction table
l_sql_stmt_txn            VARCHAR2(4000); -- for txn table fetch
l_header_id_stmt           VARCHAR2(500);
l_count                   NUMBER;
l_count_last              NUMBER;
l_count_hist              NUMBER;
l_header_id               NUMBER;
l_header_id_from          NUMBER;
l_header_id_to	          NUMBER;
l_cnt_stmt                VARCHAR2(5000);
l_id_stmt                 VARCHAR2(5000);
l_order_by                VARCHAR2(100);
type refcur is ref cursor; -- for any ref cur
ref_id                    REFCUR; --for header id, line id etc.
ref_attr                  REFCUR; -- for main loop
ref_attr_last             REFCUR; -- last rec
ref_attr_txn              REFCUR; -- last rec as txn rec
v_entity_constrained      char(1) := 'N';
v_attr_index              NUMBER:=0;
j                         NUMBER:=0;
l_input_org_id            NUMBER := p_org_id;
l_org_id_clause           varchar2(80) := '';
l_org_id_stmt             varchar2(500)  := '';
l_card_number_equal	  VARCHAR2(1) := 'N';
l_new_value         VARCHAR2(2000); /* Attrb value, desc for current , old and last*/
l_credit_card_number	  VARCHAR2(80);
l_credit_card_code	  VARCHAR2(80);
l_credit_card_holder_name	VARCHAR2(80);
l_credit_card_expiration_date	DATE;
l_last_instrument_id		NUMBER;
l_instr_flag			VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Enter audit history consolidate program',1);
END IF;

--Added for MOAC
If l_input_org_id IS NOT NULL THEN
  MO_GLOBAL.set_policy_context('S', l_input_org_id);
END IF;


/* Get date range for which data needs to be collected for this entity */

SELECT nvl(fnd_date.canonical_to_date(start_date),to_date('01/01/1950','MM/DD/RRRR')),
          nvl(fnd_date.canonical_to_date(end_date), sysdate)
INTO min_hist_creation_date, max_hist_creation_date
FROM dual;
retcode := 0;

--Commented this out for bug 3630281.
/*if order_number_from is not null then
   BEGIN
     SELECT HEADER_ID
     INTO   l_header_id_from
     FROM   OE_ORDER_HEADERS_ALL
     WHERE  ORDER_NUMBER = order_number_from;
   END;
end if;
if order_number_from is not null then
   BEGIN
     SELECT HEADER_ID
     INTO   l_header_id_to
     FROM   OE_ORDER_HEADERS_ALL
     WHERE  ORDER_NUMBER = order_number_to;
   END;
end if;*/

-- added for MOAC
IF l_input_org_id IS NOT NULL THEN
  l_org_id_clause := ' and org_id = :o';
END IF;

-- changed for MOAC
if order_number_from is not null and order_number_to is null
then
   if l_input_org_id is not null then
     --8265428 l_header_id_stmt:= ' (SELECT header_id from oe_order_headers where order_number >=:m and org_id = :o)';
     l_header_id_stmt:= ' (SELECT header_id from oe_order_headers where order_number >='||order_number_from||' and org_id = '||l_input_org_id||')';    --8265428
   else
     --8265428 l_header_id_stmt:= ' (SELECT header_id from oe_order_headers where order_number >=:m)';
     l_header_id_stmt:= ' (SELECT header_id from oe_order_headers where order_number >='||order_number_from||')';  --8265428
   end if;
elsif order_number_from is null and order_number_to is not null
then
  if l_input_org_id is not null then
    --8265428 l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number <=:n and org_id = :o)';
    l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number <='||order_number_to||'  and org_id = '||l_input_org_id||')'; --8265428
  else
    --8265428 l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number <=:n)';
    l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number <='||order_number_to||')';  --8265428
  end if;
elsif order_number_from is not null and order_number_to is not null
then
   if l_input_org_id is not null then
     --8265428 l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number between :m and :n and org_id = :o)';
     l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number between '||order_number_from||' and '||order_number_to||' and org_id = '||l_input_org_id||')';   --8265428
   else
     --8265428  l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number between :m and :n)';
     l_header_id_stmt:= ' (SELECT Header_id from oe_order_headers where order_number between '||order_number_from||' and '||order_number_to||')';  --8265428
   end if;
end if;


if start_date is null and end_date is null then
   null;
elsif start_date is not null and end_date is null then
   min_hist_creation_date := fnd_date.canonical_to_date(start_date);
   max_hist_creation_date := sysdate;
elsif end_date is not null and start_date is null then
   min_hist_creation_date := sysdate;
   max_hist_creation_date := round(fnd_date.canonical_to_date(end_date)+1);
elsif end_date is not null and start_date is not null then
   min_hist_creation_date := fnd_date.canonical_to_date(start_date);
   max_hist_creation_date := round(fnd_date.canonical_to_date(end_date)+1);
end if;

if audit_duration is not null then
   min_hist_creation_date := sysdate - audit_duration;
   max_hist_creation_date := sysdate;
end if;

IF l_debug_level  > 0 THEN
   oe_debug_pub.add('History start date => '||to_char(min_hist_creation_date,'dd-mon-yyyy hh24:mi:ss'),1);
   oe_debug_pub.add('History end date => '||to_char(max_hist_creation_date,'dd-mon-yyyy hh24:mi:ss'),1);
END IF;

FOR c_ent_rec in c_entities
LOOP

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Consolidating history records for entity '||to_char(c_ent_rec.entity_id),1);
    END IF;

    /* Check whether history records exist for this entity in the date range */
    --8265428  l_cnt_stmt := 'select count(*)  from ' || c_ent_rec.entity_name || ' where trunc(hist_creation_date) between :x and :z and ';
    l_cnt_stmt := 'select count(*)  from ' || c_ent_rec.entity_name || ' where hist_creation_date between
                       to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                   to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and rownum=1 and ';  --8265428
    l_cnt_stmt := l_cnt_stmt || 'nvl(audit_flag, ''Y'') = ''Y'' and ';

--Commenting out for bug 3630281
/*    if    l_header_id_from is not null and l_header_id_to is not null then
          l_cnt_stmt := l_cnt_stmt || ' header_id between :m and :n and ';
    elsif l_header_id_from is not null and l_header_id_to is null then
          l_cnt_stmt := l_cnt_stmt || ' header_id >= :m and ';
    elsif l_header_id_from is null and l_header_id_to is not null then

          l_cnt_stmt := l_cnt_stmt || ' header_id <= :m and ';
    end if;*/

    IF l_input_org_id IS NOT NULL THEN
      --8265428  l_org_id_stmt := ' header_id IN (SELECT header_id from oe_order_headers where org_id = :o)';
      l_org_id_stmt := ' header_id IN (SELECT header_id from oe_order_headers where org_id = '||l_input_org_id||')';   --8265428
    END IF;

    if l_header_id_stmt is not null
    then
	l_cnt_stmt := l_cnt_stmt || ' header_id in ' || l_header_id_stmt || ' and' ;
    elsif l_org_id_stmt is not null then  -- added for MOAC
	 -- Org restriction must be explicitly included
        l_cnt_stmt := l_cnt_stmt || l_org_id_stmt || ' and';
    end if;

    l_cnt_stmt := l_cnt_stmt || ' 1 = 1 ';

    if order_number_from is not null and order_number_to is not null then
      If l_input_org_id IS NOT NULL THEN
       -- Single Org processing
       --8265428  OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date,order_number_from,order_number_to, l_input_org_id;
       OPEN ref_attr FOR l_cnt_stmt;  --8265428
      ELSE
       --Mulitple Org processing
       --8265428  OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date,order_number_from,order_number_to;
       OPEN ref_attr FOR l_cnt_stmt;  --8265428
      End If;
    elsif order_number_from is not null and order_number_to is null then
      If l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428  OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date,order_number_from, l_input_org_id;
	OPEN ref_attr FOR l_cnt_stmt;  --8265428
      ELSE
        --Mulitple Org processing
        --8265428 OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date,order_number_from;
        OPEN ref_attr FOR l_cnt_stmt;  --8265428
      End If;
    elsif order_number_from is null and order_number_to is not null then
      If l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428 OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date,order_number_to, l_input_org_id;
	OPEN ref_attr FOR l_cnt_stmt;   --8265428
      ELSE
	--Mulitple Org processing
        --8265428 OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date,order_number_to;
        OPEN ref_attr FOR l_cnt_stmt;   --8265428
      End If;
    else
      If l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428 OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date, l_input_org_id;
	OPEN ref_attr FOR l_cnt_stmt;   --8265428
      ELSE
	--Mulitple Org processing
        --8265428 OPEN ref_attr FOR l_cnt_stmt USING min_hist_creation_date,max_hist_creation_date;
        OPEN ref_attr FOR l_cnt_stmt;   --8265428
      End If;
    end if;
    FETCH ref_attr INTO l_count;
    CLOSE ref_attr;

    if  l_count=0 then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('NO matching history records in this date range for entity '||to_char(c_ent_rec.entity_id),1);
	END IF;
	goto End_Of_Entity;
    end if;

     /* Moved the below code from inside the Order Loop to here for FP bug4282167 */
     C_ATTR_TBL.delete;
        OPEN IS_ENTITY_CONSTRAINED(c_ent_rec.entity_id);
        FETCH IS_ENTITY_CONSTRAINED INTO v_entity_constrained;
        CLOSE IS_ENTITY_CONSTRAINED;

        v_attr_index:=1;
        IF v_entity_constrained = 'Y' THEN
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.add('Consolidating for all attributes',1);
           END IF;
           FOR c_attr_rec IN c_all_attributes(c_ent_rec.entity_id) LOOP
               c_attr_tbl(v_attr_index).entity_id := c_ent_rec.entity_id;
               c_attr_tbl(v_attr_index).attribute_id := c_attr_rec.attribute_id;
               c_attr_tbl(v_attr_index).attribute_code := c_attr_rec.attribute_code;
               c_attr_tbl(v_attr_index).column_name := c_attr_rec.column_name;
               c_attr_tbl(v_attr_index).attribute_display_name := c_attr_rec.attribute_display_name;
               v_attr_index := v_attr_index+1;
           END LOOP;
        ELSE
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.add('Consolidating for currently constrained attributes only',1);
           END IF;

           FOR c_attr_rec IN c_const_attributes(c_ent_rec.entity_id) LOOP
               c_attr_tbl(v_attr_index).entity_id := c_ent_rec.entity_id;
               c_attr_tbl(v_attr_index).attribute_id := c_attr_rec.attribute_id;
               c_attr_tbl(v_attr_index).attribute_code := c_attr_rec.attribute_code;
               c_attr_tbl(v_attr_index).column_name := c_attr_rec.column_name;
               c_attr_tbl(v_attr_index).attribute_display_name := c_attr_rec.attribute_display_name;
               v_attr_index := v_attr_index+1;
           END LOOP;
        END IF;
     /* End of changes done for FP bug4282167 */

    if (c_ent_rec.entity_id = 1) then
      l_ent_stmt := ' and hist.header_id = :a ';
    elsif (c_ent_rec.entity_id = 2) then
      l_ent_stmt := ' and hist.line_id = :a ';
    elsif (c_ent_rec.entity_id = 5) then
      l_ent_stmt := ' and hist.sales_credit_id = :a and hist.line_id is null ';
    elsif (c_ent_rec.entity_id = 6) then
      l_ent_stmt := ' and hist.price_adjustment_id = :a and hist.line_id is null ';
    elsif (c_ent_rec.entity_id = 7) then
      l_ent_stmt := ' and hist.sales_credit_id = :a and hist.line_id is not null ';
    elsif (c_ent_rec.entity_id = 8) then
      l_ent_stmt := ' and hist.price_adjustment_id = :a and hist.line_id is not null ';
    end if;

      l_ent_stmt := l_ent_stmt || ' and nvl(audit_flag, ''Y'') = ''Y'' ';

    -- Following code added for 4394119. This version of the entity statement does not
    -- use the hist table alias. As a result, when the inner query uses this statement
    -- the resultant SQL statement does not have a correlated subquery, which would cause
    -- FTSs in the outer query
    if (c_ent_rec.entity_id = 1) then
      l_ent_stmt_subquery := ' and header_id = :a ';
    elsif (c_ent_rec.entity_id = 2) then
      l_ent_stmt_subquery := ' and line_id = :a ';
    elsif (c_ent_rec.entity_id = 5) then
      l_ent_stmt_subquery := ' and sales_credit_id = :a and line_id is null ';
    elsif (c_ent_rec.entity_id = 6) then
      l_ent_stmt_subquery := ' and price_adjustment_id = :a and line_id is null ';
    elsif (c_ent_rec.entity_id = 7) then
      l_ent_stmt_subquery := ' and sales_credit_id = :a and line_id is not null ';
    elsif (c_ent_rec.entity_id = 8) then
      l_ent_stmt_subquery := ' and price_adjustment_id = :a and line_id is not null ';
    end if;

    l_ent_stmt_subquery := l_ent_stmt_subquery || ' and nvl(audit_flag, ''Y'') = ''Y'' ';

    IF l_debug_level > 0 THEN
       oe_debug_pub.add('For entity id ' || c_ent_rec.entity_id || ' Constructed subquery entity statement: ' || l_ent_stmt_subquery);
    END IF;
    -- end bug 4394119

/*8265428 start
    if (c_ent_rec.entity_id = 1) then
       l_id_stmt := ' select distinct header_id, header_id entity_number '||
                    ' from oe_order_header_history where nvl(audit_flag, ''Y'') = ''Y'' and hist_creation_date between :m and :n and ';

       l_order_by := ' 1 = 1 ';
     elsif (c_ent_rec.entity_id = 2) then
         l_id_stmt := ' select distinct header_id, line_id entity_number '
                     ||' from oe_order_lines_history where nvl(audit_flag, ''Y'') = ''Y'' and hist_type_code in (''UPDATE'',''CANCELLATION'',''SPLIT'') and hist_creation_date between :m and :n and ';

	l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 5) then
       l_id_stmt := ' select distinct header_id, sales_credit_id entity_number ' ||
                    ' from oe_sales_credit_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is null and hist_creation_date between :m and :n and ';
       l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 6) then
       l_id_stmt := ' select distinct header_id, price_adjustment_id entity_number '||
                    ' from oe_price_adjs_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is null and hist_creation_date between :m and :n and ';
       l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 7) then
       l_id_stmt := ' select distinct header_id, sales_credit_id entity_number ' ||
                    ' from oe_sales_credit_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is not null and hist_creation_date between :m and :n and ';
       l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 8) then
       l_id_stmt := ' select distinct header_id, price_adjustment_id entity_number '||
                    ' from oe_price_adjs_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is not null and hist_creation_date between :m and :n and ';
       l_order_by := ' 1 = 1 ';
    end if;
8265428 end*/

--8265428 start

    if (c_ent_rec.entity_id = 1) then
       l_id_stmt := ' select distinct header_id, header_id entity_number '||
                    ' from oe_order_header_history where nvl(audit_flag, ''Y'') = ''Y'' and hist_creation_date between
                      to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                      to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and ';

       l_order_by := ' 1 = 1 ';
     elsif (c_ent_rec.entity_id = 2) then
         l_id_stmt := ' select distinct header_id, line_id entity_number '
                     ||' from oe_order_lines_history where nvl(audit_flag, ''Y'') = ''Y'' and hist_type_code in (''UPDATE'',''CANCELLATION'',''SPLIT'')
                                                  and hist_creation_date between
                       to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                       to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and ';

	l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 5) then
       l_id_stmt := ' select distinct header_id, sales_credit_id entity_number ' ||
                    ' from oe_sales_credit_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is null and hist_creation_date between
                      to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                      to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and ';
       l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 6) then
       l_id_stmt := ' select distinct header_id, price_adjustment_id entity_number '||
                    ' from oe_price_adjs_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is null and hist_creation_date between
                      to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                      to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and ';
       l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 7) then
       l_id_stmt := ' select distinct header_id, sales_credit_id entity_number ' ||
                    ' from oe_sales_credit_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is not null and hist_creation_date between
                      to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                      to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and ';
       l_order_by := ' 1 = 1 ';
    elsif (c_ent_rec.entity_id = 8) then
       l_id_stmt := ' select distinct header_id, price_adjustment_id entity_number '||
                    ' from oe_price_adjs_history where nvl(audit_flag, ''Y'') = ''Y'' and line_id is not null and hist_creation_date between
                      to_date('''||To_Char(min_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and
                      to_date('''||To_Char(max_hist_creation_date,'DD-MON-RRRR HH24 MI SS')||''',''DD-MON-RRRR HH24 MI SS'') and ';
       l_order_by := ' 1 = 1 ';
    end if;

--8265428 end

--Commenting out for bug 3630281
/*    if l_header_id_from is not null and l_header_id_to is not null then
       l_id_stmt := l_id_stmt || ' header_id between :o and :p and ';

    elsif l_header_id_from is not null and l_header_id_to is null then
       l_id_stmt := l_id_stmt || ' header_id >= :o and ';
    elsif l_header_id_from is null and l_header_id_to is not null then
       l_id_stmt := l_id_stmt || ' header_id <= :o and ';
    end if;*/


    if l_header_id_stmt is not null
    then
	l_id_stmt := l_id_stmt || ' header_id in ' || l_header_id_stmt || ' and' ;
    elsif l_org_id_stmt is not null
    then
	-- Org restriction must be explicitly included - MOAC

	l_id_stmt := l_id_stmt || l_org_id_stmt || ' and';
    end if;

    l_id_stmt := l_id_stmt || l_order_by;

    if order_number_from is not null and order_number_to is not null then
      If l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428 OPEN ref_id FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date,order_number_from,order_number_to, l_input_org_id;
	OPEN ref_id FOR l_id_stmt;  --8265428

      ELSE
	-- Multi Org processing

        --8265428 OPEN ref_id FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date,order_number_from,order_number_to;
        OPEN ref_id FOR l_id_stmt;  --8265428
      End If;
    elsif order_number_from is not null and order_number_to is null then
      If l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428 OPEN ref_id FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date,order_number_from, l_input_org_id;
	OPEN ref_id FOR l_id_stmt;  --8265428
      ELSE
	-- Multi Org processing
        --8265428 OPEN ref_id FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date,order_number_from;
        OPEN ref_id FOR l_id_stmt;  --8265428
      End If;
    elsif order_number_from is null and order_number_to is not null then
      If l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428 OPEN ref_id FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date,order_number_to, l_input_org_id;
	OPEN ref_id FOR l_id_stmt;  --8265428
      ELSE
	--Multi Org processing
        --8265428 OPEN ref_id FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date,order_number_to;
        OPEN ref_id FOR l_id_stmt;  --8265428
      End If;
    else
      IF l_input_org_id IS NOT NULL THEN
	-- Single Org processing
	--8265428 OPEN REF_ID FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date, l_input_org_id;
	OPEN REF_ID FOR l_id_stmt;  --8265428
      ELSE
	--Multi Org processing
        --8265428 OPEN REF_ID FOR l_id_stmt using min_hist_creation_date,max_hist_creation_date;
        OPEN REF_ID FOR l_id_stmt;  --8265428
      End If;
    end if;

    LOOP /* Order number cursor */
        FETCH ref_id INTO l_header_id, l_entity_number;
        EXIT WHEN ref_id%NOTFOUND;

        BEGIN
           SELECT ORDER_NUMBER,SOLD_TO_ORG_ID,ORDER_TYPE_ID,ORG_ID
           INTO   l_order_number,l_sold_to_org_id,l_order_type_id,l_org_id
           FROM   OE_ORDER_HEADERS
           WHERE  HEADER_ID = l_header_id;

        EXCEPTION WHEN OTHERS THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Unable to locate header record for header ID : '||l_header_id||' ERROR: '||SQLERRM , 1 ) ;
           END IF;
        END;

        FOR J in 1..c_attr_tbl.count LOOP

            IF (c_ent_rec.entity_id) = 2 THEN

                l_sql_stmt :=  'select nvl(oer.reason_code, '
                          || ' hist.reason_code) , hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,hist_comments) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
--                        || ' where hist_type_code = '||''''||'UPDATE'||''''||' and '
                          || ' where hist_type_code in (''UPDATE'',''CANCELLATION'',''SPLIT'') and '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || l_ent_stmt;
            ELSIF (c_ent_rec.entity_id in (6,8)) THEN
                l_sql_stmt :=  'select nvl(oer.reason_code, '
                          || ' hist.change_reason_code), hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,change_reason_text) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
                          || ' where '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || l_ent_stmt;
            ELSIF (c_ent_rec.entity_id in (1,5,7)) THEN

                 -- R12 CC encryption
                 -- for security reason, we only store the instrument id for the
                 -- credit card, but only credit card number is updateable,
                 -- and hence the following logic for the column name.
                 IF c_attr_tbl(j).column_name IN ('CREDIT_CARD_NUMBER',
                                                  'CREDIT_CARD_CODE',
                                                  'CREDIT_CARD_HOLDER_NAME',
                                                  'CREDIT_CARD_EXPIRATION_DATE')
		 THEN


            IF c_attr_tbl(j).column_name = 'CREDIT_CARD_NUMBER' THEN
                l_sql_stmt :=  'select  nvl(oer.reason_code, '
                          || ' hist.reason_code), hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,hist_comments) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
                          || ' where '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || ' and (hist.credit_card_number IS NOT NULL OR (hist.credit_card_number IS NULL AND hist.credit_card_holder_name IS NULL AND hist.credit_card_code IS NULL AND hist.credit_card_expiration_date IS NULL))'
                          || l_ent_stmt;
            ELSIF c_attr_tbl(j).column_name = 'CREDIT_CARD_CODE' THEN
                l_sql_stmt :=  'select  nvl(oer.reason_code, '
                          || ' hist.reason_code), hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,hist_comments) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
                          || ' where '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || ' and (hist.credit_card_code IS NOT NULL OR (hist.credit_card_number IS NULL AND hist.credit_card_holder_name IS NULL AND hist.credit_card_code IS NULL AND hist.credit_card_expiration_date IS NULL))'
                          || l_ent_stmt;
            ELSIF c_attr_tbl(j).column_name = 'CREDIT_CARD_HOLDER_NAME' THEN
                l_sql_stmt :=  'select  nvl(oer.reason_code, '
                          || ' hist.reason_code), hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,hist_comments) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
                          || ' where '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || ' and (hist.credit_card_holder_name IS NOT NULL OR (hist.credit_card_number IS NULL AND hist.credit_card_holder_name IS NULL AND hist.credit_card_code IS NULL AND hist.credit_card_expiration_date IS NULL))'
                          || l_ent_stmt;
            ELSIF c_attr_tbl(j).column_name = 'CREDIT_CARD_EXPIRATION_DATE' THEN
                l_sql_stmt :=  'select  nvl(oer.reason_code, '
                          || ' hist.reason_code), hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,hist_comments) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
                          || ' where '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || ' and (hist.credit_card_expiration_date IS NOT NULL OR (hist.credit_card_number IS NULL AND hist.credit_card_holder_name IS NULL AND hist.credit_card_code IS NULL AND hist.credit_card_expiration_date IS NULL))'
                          || l_ent_stmt;

            END IF;

                  c_attr_tbl(j).column_name := 'INSTRUMENT_ID';

                ELSE
                l_sql_stmt :=  'select  nvl(oer.reason_code, '
                          || ' hist.reason_code), hist_creation_date, '
                          || ' hist_created_by , responsibility_id, nvl(oer.comments,hist_comments) hist_comments, '
                          || ' hist.' || c_attr_tbl(j).column_name || ',hist.context '
                          || ' from '
                          || c_ent_rec.entity_name || ' hist '
                          || ' , oe_reasons oer '
                          || ' where '
                          || ' trunc(hist_creation_date) between :x and :z '
                          || ' and hist.header_id = :y '
                          || ' and hist.reason_id = oer.reason_id(+) '
                          || l_ent_stmt;
                END IF;
            ELSE
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Entity id not recognized '||c_ent_rec.entity_id,1);
                 END IF;
            END IF;

            BEGIN
                OPEN ref_attr FOR l_sql_stmt
             	USING min_hist_creation_date, max_hist_creation_date, l_header_id, l_entity_number;
                i_counter     := 1;
                l_rec_counter := 1;
                /* This flag will be true when the last record in oe_audit_attr_history
                   will be updated with the new attribute value column */
                l_old_db_rec_upd_flag      := false;
                l_old_hist_creation_date   := null;
                l_old_reason_code          := null;
                l_old_user_id              := null;
                l_old_responsibility_id    := null;
                l_old_attribute_value      := null;
		l_old_context_value        := null;
                LOOP
                   l_attribute_value      := NULL;
                   l_attribute_value_last := NULL;
		   l_context_value      := NULL;
                   l_context_value_last := NULL;

                   /* Following condition for any iteration after the first */
                   IF (l_old_db_rec_upd_flag = TRUE) THEN

                      l_old_hist_creation_date := l_hist_creation_date;
                      l_old_reason_code        := l_reason_code;
                      l_old_attribute_value    := l_attribute_value;
                      l_old_user_id            := l_user_id;
                      l_old_responsibility_id  := l_responsibility_id;
		      l_old_context_value      := l_context_value;
                   END IF;

                   FETCH  ref_attr INTO
                     l_reason_code
		    ,l_hist_creation_date
		    ,l_user_id
		    ,l_responsibility_id

                    ,l_change_comments
		    ,l_attribute_value
                    ,l_context_value;
                   EXIT WHEN ref_attr%NOTFOUND;

                   -- Check if history records exist for this attribute
                   SELECT count(*)
                   INTO   l_count_hist
                   FROM   oe_audit_attr_history
                   WHERE  hist_creation_date = l_hist_creation_date
                   AND    entity_number = l_entity_number
                   AND    attribute_id = c_attr_tbl(j).attribute_id
                   AND    entity_id = c_ent_rec.entity_id
                   and    rownum = 1; -- Added for bug 7319059

                   IF  l_count_hist > 0 THEN
                       goto next_attribute;
                   END IF;

                   BEGIN
                     select credit_card_code, credit_card_number
                           ,credit_card_holder_name, credit_card_expiration_date
                     into   l_credit_card_code, l_credit_card_number
                           ,l_credit_card_holder_name, l_credit_card_expiration_date
                     from oe_order_header_history
                     where hist_creation_date = l_hist_creation_date
                     and header_id = l_header_id;
                   EXCEPTION WHEN NO_DATA_FOUND THEN
                     null;
                   END;

                   IF NOT (l_credit_card_code IS NULL
                           AND l_credit_card_number IS NULL
                           AND l_credit_card_holder_name IS NULL
                           AND l_credit_card_expiration_date IS NULL) THEN


                      IF c_attr_tbl(j).attribute_id IN (46,49) AND
                         l_credit_card_code IS NULL and l_credit_card_number IS NULL THEN
                         goto next_attribute;

                      ELSIF c_attr_tbl(j).attribute_id = 47 AND
                         l_credit_card_expiration_date IS NULL THEN
                         goto next_attribute;
                      ELSIF c_attr_tbl(j).attribute_id = 48 AND
                         l_credit_card_holder_name IS NULL THEN
                         goto next_attribute;
                      END IF;
                   END IF;

                   IF ((l_attribute_value <> l_old_attribute_value)
                       	AND (l_old_db_rec_upd_flag = true))
                        -- R12 cc encryption
 			OR (c_attr_tbl(j).attribute_id IN (46,47,48,49)
                            AND (l_old_db_rec_upd_flag = true))
                         then
                       IF c_attr_tbl(j).attribute_id IN (46,47,48,49)
                          AND l_old_db_rec_upd_flag = true
                       THEN
                        -- if the credit card attribute is the same, skip to next record.

                        Compare_Credit_Card(p_attribute_id 		=> c_attr_tbl(j).attribute_id,
                                            p_header_id 		=>l_header_id,
                                            p_old_hist_creation_date	=>l_old_hist_creation_date,
                                            p_new_hist_creation_date	=> l_hist_creation_date,
                                            x_old_attribute_value	=> l_old_attribute_value,
                                            x_new_attribute_value	=> l_attribute_value,
                                            x_card_number_equal         => l_card_number_equal);

                          IF (l_old_attribute_value = l_attribute_value
                              AND c_attr_tbl(j).attribute_id IN (46,47,48))
                             OR
                             (l_card_number_equal = 'Y'
                              AND c_attr_tbl(j).attribute_id = 49)
                           THEN
                             goto next_attribute;
                          END IF;

                      END IF;
                      -- end R12 cc encryption
                         oe_pc_attr_tbl(l_rec_counter).entity_id := c_ent_rec.entity_id;
                         oe_pc_attr_tbl(l_rec_counter).attribute_id := c_attr_tbl(j).attribute_id;
                         oe_pc_attr_tbl(l_rec_counter).old_attribute_value := l_old_attribute_value;
                         oe_pc_attr_tbl(l_rec_counter).hist_creation_date := l_old_hist_creation_date;
                         oe_pc_attr_tbl(l_rec_counter).order_number := l_order_number;
                         oe_pc_attr_tbl(l_rec_counter).entity_number:= l_entity_number;
                         oe_pc_attr_tbl(l_rec_counter).user_id := l_old_user_id;
                         oe_pc_attr_tbl(l_rec_counter).reason_code := l_old_reason_code;
                         oe_pc_attr_tbl(l_rec_counter).new_attribute_value:= l_attribute_value;
                         oe_pc_attr_tbl(l_rec_counter).responsibility_id := l_old_responsibility_id;
                         oe_pc_attr_tbl(l_rec_counter).new_context_value:= l_context_value;
                         oe_pc_attr_tbl(l_rec_counter).old_context_value:= l_old_context_value;
                         l_rec_counter := l_rec_counter +1;
                   END IF;


                   i_counter := i_counter + 1;
                   l_old_db_rec_upd_flag := FALSE;
                   l_sql_stmt_last := 'select count(*) from '
                                        || c_ent_rec.entity_name || ' hist '
--                                        || ' where hist_type_code = '||''''||'UPDATE'||''''||' and '
                                        || ' where hist_type_code in (''UPDATE'',''CANCELLATION'',''SPLIT'') and '
                                        || ' hist_creation_date > :x  '
                                        || ' and header_id = :y '
                                        || l_ent_stmt;
                   OPEN ref_attr_last FOR l_sql_stmt_last using l_hist_creation_date ,l_header_id ,l_entity_number;
                   FETCH ref_attr_last INTO l_count_last;
                   CLOSE ref_attr_last;

                   IF (l_count_last = 0) THEN

                 -- R12 CC encryption
                 -- for security reason, we only store the instrument id for the
                 -- credit card, but only credit card number is updateable,
                 -- and hence the following logic for the column name.
                 IF c_attr_tbl(j).column_name = 'INSTRUMENT_ID' THEN
                   IF c_attr_tbl(j).attribute_id = 46 THEN

                     c_attr_tbl(j).column_name := 'CARD_ISSUER_CODE';
                   ELSIF c_attr_tbl(j).attribute_id = 47 THEN
                     c_attr_tbl(j).column_name := 'CARD_EXPIRYDATE';
                   ELSIF c_attr_tbl(j).attribute_id = 48 THEN
                     c_attr_tbl(j).column_name := 'CARD_HOLDER_NAME';
                   ELSIF c_attr_tbl(j).attribute_id = 49 THEN
                     c_attr_tbl(j).column_name := 'CARD_NUMBER';

                   END IF;
                 END IF;

                 IF l_debug_level > 0 THEN
                   oe_debug_pub.add('column name is: '||c_attr_tbl(j).column_name, 5);
                 END IF;

                         if (c_ent_rec.entity_id = 1) then
                           if c_attr_tbl(j).attribute_id in (46, 47, 48,49) then

                             -- get the instrument id for cc number
                             -- bug 8586227
                             l_sql_stmt_txn := 'select itev.instrument_id'||' ,ooh.Context '||
                                  ' from oe_order_headers ooh, oe_payments op, IBY_EXTN_INSTR_DETAILS_V itev '||
                                  ' where '||
                                  ' ooh.header_id = :y'||' and ooh.header_id = op.header_id and op.line_id is null and nvl(op.payment_collection_event,''PREPAY'') = ''INVOICE'' and op.trxn_extension_id = itev.trxn_extension_id';
                          else
                             l_sql_stmt_txn := 'select '||c_attr_tbl(j).column_name||' ,Context '||
                                  ' from oe_order_headers '||
                                  ' where '||
                                  ' header_id = :y';
                           end if;

                             OPEN ref_attr_txn for l_sql_stmt_txn using l_entity_number;
                             FETCH ref_attr_txn into l_attribute_value_last,l_context_value_last;

                             CLOSE ref_attr_txn;


                         ELSIF (c_ent_rec.entity_id = 2) THEN
                              l_sql_stmt_txn := 'select '||c_attr_tbl(j).column_name||' ,Context '||
                                  ' from oe_order_lines '||
                                  ' where '||
                                  ' line_id = :y';

                              OPEN ref_attr_txn FOR l_sql_stmt_txn USING l_entity_number;
                              FETCH ref_attr_txn INTO l_attribute_value_last,l_context_value_last;
                              CLOSE ref_attr_txn;

                         elsif (c_ent_rec.entity_id = 5) then
                              l_sql_stmt_txn := 'select '||c_attr_tbl(j).column_name||' ,Context '||
                                  ' from oe_sales_credits '||
                                  ' where '||
                                  ' sales_credit_id = :y';

                              OPEN ref_attr_txn for l_sql_stmt_txn using l_entity_number;
                              FETCH ref_attr_txn into l_attribute_value_last,l_context_value_last;
                              CLOSE ref_attr_txn;
                         elsif (c_ent_rec.entity_id = 6) then
                              l_sql_stmt_txn := 'select '
                                              ||c_attr_tbl(j).column_name || ',Context '
                                              ||' from oe_price_adjustments '
                                              ||' where '
                                              ||' price_adjustment_id = :y';

                              OPEN ref_attr_txn for l_sql_stmt_txn using l_entity_number;
                              FETCH ref_attr_txn into l_attribute_value_last,l_context_value_last;
                              CLOSE ref_attr_txn;
                        elsif (c_ent_rec.entity_id = 7) then
                              l_sql_stmt_txn := 'select '||c_attr_tbl(j).column_name||',Context '||
                                  ' from oe_sales_credits '||
                                  ' where '||
                                  ' sales_credit_id = :y';

                              OPEN ref_attr_txn for l_sql_stmt_txn using l_entity_number;
                              FETCH ref_attr_txn into l_attribute_value_last,l_context_value_last;
                              CLOSE ref_attr_txn;
                        elsif (c_ent_rec.entity_id = 8) then
                              l_sql_stmt_txn := 'select '||c_attr_tbl(j).column_name||',Context '||
                                  ' from oe_price_adjustments'||
                                  ' where '||
                                  ' price_adjustment_id = :y';

                              OPEN ref_attr_txn for l_sql_stmt_txn using l_entity_number;

                              FETCH ref_attr_txn into l_attribute_value_last,l_context_value_last;
                              CLOSE ref_attr_txn;
                        end if;
                        /* End Get the last record i.e. from the transaction table */
                        l_order_number_last := l_order_number;
                   ELSE

                 -- R12 CC encryption
                 -- for security reason, we only store the instrument id for the
                 -- credit card, but only credit card number is updateable,
                 -- and hence the following logic for the column name.

                        if (l_count_last = 1) then
                           IF (c_ent_rec.entity_id in (6,8)) THEN
                              l_sql_stmt_last :=
                                  'select  hist_creation_date, nvl(oer.reason_code, change_reason_code), '
                                  || ' hist_created_by, responsibility_id, '
                                  || ' hist.' || c_attr_tbl(j).column_name || ', hist.context '
                                  || ' from '
                                  || c_ent_rec.entity_name || ' hist, oe_reasons oer '
                                  || ' where  hist_creation_date > :x '
                                  || ' and hist_type_code = '||''''||'UPDATE'||''''
                                  || ' and hist.header_id = :y '
                                  || ' and hist.reason_id = oer.reason_id(+) '
                                  || l_ent_stmt;
                           ELSE
                              l_sql_stmt_last :=
                                  'select  hist_creation_date, nvl(oer.reason_code, hist.reason_code), '
                                  || ' hist_created_by, responsibility_id, '
                                  || ' hist.' || c_attr_tbl(j).column_name || ', hist.context '
                                  || ' from '
                                  || c_ent_rec.entity_name || ' hist, oe_reasons oer '
                                  || ' where  hist_creation_date > :x '
--                                || ' and hist_type_code = '||''''||'UPDATE'||''''
                                  || ' and hist_type_code in (''UPDATE'',''CANCELLATION'',''SPLIT'') '
                                  || ' and hist.header_id = :y '
                                  || ' and hist.reason_id = oer.reason_id(+) '
                                  || l_ent_stmt;

                           END IF;
                        ELSIF (l_count_last > 1) then
                           IF l_debug_level > 0 THEN
                              oe_debug_pub.add('Executing subquery: ' ||  l_ent_stmt_subquery);
                              oe_debug_pub.add('Entity id: ' || c_ent_rec.entity_id || ' date: ' || l_hist_creation_date || ' Header Id: ' ||  l_header_id || ' entity number ' ||  l_entity_number);
                           END IF;
                           IF (c_ent_rec.entity_id in (6,8)) THEN
                               l_sql_stmt_last :=
                                   'select  hist_creation_date, nvl(oer.reason_code, hist.change_reason_code), '
                                   || ' hist_created_by, responsibility_id, '
                                   || ' hist.' || c_attr_tbl(j).column_name || ' ,hist.context '
                                   || ' from '
                                   || c_ent_rec.entity_name || ' hist, oe_reasons oer '
                                   || ' where hist.reason_id = oer.reason_id(+) '
                                   || ' and nvl(audit_flag, ''Y'') = ''Y'' '
                                   || ' and  hist.rowid = '
                                   || ' (select min(rowid) from '
                                   || c_ent_rec.entity_name
                                   || ' where hist_creation_date > :x '
                                   || ' and hist_type_code = '||''''||'UPDATE'|| ''''
                                   || ' and header_id = :y '
                                   || l_ent_stmt_subquery
                                   || ') ';
                           ELSE
                               l_sql_stmt_last :=
                                   'select  hist_creation_date, nvl(oer.reason_code, hist.reason_code), '
                                   || ' hist_created_by, responsibility_id, '
                                   || ' hist.' || c_attr_tbl(j).column_name || ' ,hist.context '
                                   || ' from '
                                   || c_ent_rec.entity_name || ' hist, oe_reasons oer '
                                   || ' where hist.reason_id = oer.reason_id(+) '
                                   || ' and nvl(audit_flag, ''Y'') = ''Y'' '
                                   || ' and  hist.rowid = '
                                   || ' (select min(rowid) from '
                                   || c_ent_rec.entity_name
                                   || ' where hist_creation_date > :x '
--                                 || ' and hist_type_code = '||''''||'UPDATE' ||''''
                                   || ' and hist_type_code in (''UPDATE'',''CANCELLATION'',''SPLIT'') '
                                   || ' and header_id = :y '
                                   || l_ent_stmt_subquery
                                   || ') ';
                           END IF;
                         END IF;
                         OPEN ref_attr_last for l_sql_stmt_last

                         USING l_hist_creation_date, l_header_id, l_entity_number;

                         FETCH ref_attr_last
     			 INTO  l_hist_creation_date_last
	      		     , l_reason_code_last
                             , l_user_id_last
			     , l_responsibility_id_last
                             , l_attribute_value_last
       			     , l_context_value_last;
                         CLOSE ref_attr_last;


                   END IF;

                 -- IF  c_attr_tbl(j).column_name = 'INSTRUMENT_ID'
                 IF  c_attr_tbl(j).column_name IN ('CARD_ISSUER_CODE',
                                                   'CARD_EXPIRYDATE',
                                                   'CARD_HOLDER_NAME',
                                                   'CARD_NUMBER')
                   AND c_ent_rec.entity_id = 1 THEN

                   BEGIN
                     select instrument_id
                     into l_last_instrument_id
                     from oe_order_header_history
                     where header_id = l_header_id
                     and   hist_creation_date =
                          (select max(hist_creation_date)
                           from oe_order_header_history
                           where header_id = l_header_id);
                   EXCEPTION WHEN NO_DATA_FOUND THEN
                     null;
                   END;

                 END IF;


                   IF (nvl(l_attribute_value_last,'Value was null') <> nvl(l_attribute_value,'Value was null'))
                   -- R12 CC encryption
                   OR c_attr_tbl(j).attribute_id IN (46,47,48,49)
  	           THEN
                      IF c_attr_tbl(j).attribute_id IN (46,47,48,49) AND l_count_last <> 0
                      --  IF c_attr_tbl(j).attribute_id IN (46,47,48,49)
                      THEN
                        -- if the credit card attribute is the same, skip to next record.

                       -- IF Card_Equal(c_attr_tbl(j).attribute_id, l_header_id, l_hist_creation_date_last, l_hist_creation_date) THEN

                        Compare_Credit_Card(p_attribute_id	=> c_attr_tbl(j).attribute_id,
                                            p_header_id 		=>l_header_id,
                                            p_old_hist_creation_date	=>l_hist_creation_date,
                                            p_new_hist_creation_date	=> l_hist_creation_date_last,
                                            x_old_attribute_value	=> l_attribute_value,
                                            x_new_attribute_value	=> l_attribute_value_last,
                                            x_card_number_equal         => l_card_number_equal);


                         IF (l_attribute_value_last = l_attribute_value
                              AND c_attr_tbl(j).attribute_id IN (46,47,48))
                             OR
                             (l_card_number_equal = 'Y'
                              AND c_attr_tbl(j).attribute_id = 49)
                           THEN
                             goto next_attribute;
                          END IF;

                           IF l_debug_level  > 0 THEN
                             oe_debug_pub.add('old date is '||to_char(l_hist_creation_date ,'HH24:MI:SS DD-MON-YYYY'),1);
                             oe_debug_pub.add('new date is '||to_char(l_hist_creation_date_last ,'HH24:MI:SS DD-MON-YYYY'),1);
                             oe_debug_pub.add('old value is '||l_attribute_value ,1);
                             oe_debug_pub.add('new value is '||l_attribute_value_last,1);
                           END IF;

                      ELSIF  c_attr_tbl(j).attribute_id IN (46,47,48, 49) AND l_count_last = 0 THEN
                        -- compare the card number between the last record and the one
                        -- in the transaction table.

                        IF  c_attr_tbl(j).attribute_id = 49

                          -- l_attribute_value_last is the instrument id on the current order
                          -- l_last_instrument_id is the last record in oe_order_header_history.
                          AND OE_GLOBALS.Is_Same_Credit_Card(p_cc_num_old    => null
                                         ,p_cc_num_new          => null
                                         ,p_instrument_id_old   => l_attribute_value_last
                                         -- ,p_instrument_id_new   => l_attribute_value) THEN
                                          ,p_instrument_id_new   => l_last_instrument_id) THEN
                            goto next_attribute;

                        ELSE

                          IF l_credit_card_number IS NULL AND
                             l_credit_card_code IS NULL
                             AND  c_attr_tbl(j).attribute_id in (47,48)
                             AND l_count_last <>0  THEN
                               l_instr_flag :='N';
                          ELSE
                            l_instr_flag := 'Y';
                          END IF;

                          l_attribute_value_last := Get_Card_Attribute_Value
                                                  (p_instr_flag => l_instr_flag,
                                                   p_attribute_id =>  c_attr_tbl(j).attribute_id,
                                                   p_instrument_id => to_number(l_attribute_value_last));

                          IF l_credit_card_number IS NULL AND
                             l_credit_card_code IS NULL
                             AND  c_attr_tbl(j).attribute_id in (47,48)
                             AND  l_count_last = 0 THEN
                             -- this is to get the last record in oe_order_header_history,
                             -- if it stores card history id then set flag to 'N' when
                             -- calling Get_Card_Attribute_Value to get l_attribute_value.

                             l_instr_flag :='N';
                          END IF;

                          l_attribute_value := Get_Card_Attribute_Value
                                             (p_instr_flag => l_instr_flag,
                                              p_attribute_id =>  c_attr_tbl(j).attribute_id,
                                              p_instrument_id => l_last_instrument_id);

                        END IF;

                      END IF;

                      -- end R12 cc encryption

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add('Found history records for order => '||l_order_number,1);
                      END IF;
                      -- PADSS Start
                      IF c_attr_tbl(j).attribute_id=47 then
                        IF l_attribute_value is null then
                         l_attribute_value:='xx/xx';
                        END IF;
                        IF l_attribute_value_last is null then
			 l_attribute_value_last:='xx/xx';
                        END IF;
                      END IF;
                      -- PADSS End
                      oe_pc_attr_tbl(l_rec_counter).old_attribute_value := l_attribute_value;
                      oe_pc_attr_tbl(l_rec_counter).new_attribute_value := l_attribute_value_last;
                      oe_pc_attr_tbl(l_rec_counter).entity_id := c_ent_rec.entity_id;
                      oe_pc_attr_tbl(l_rec_counter).attribute_id := c_attr_tbl(j).attribute_id;
                      oe_pc_attr_tbl(l_rec_counter).hist_creation_date := l_hist_creation_date;
                      oe_pc_attr_tbl(l_rec_counter).order_number := l_order_number;
                      oe_pc_attr_tbl(l_rec_counter).entity_number:= l_entity_number;
                      oe_pc_attr_tbl(l_rec_counter).user_id := l_user_id;
                      oe_pc_attr_tbl(l_rec_counter).reason_code := l_reason_code;
                      oe_pc_attr_tbl(l_rec_counter).responsibility_id := l_responsibility_id;
                      oe_pc_attr_tbl(l_rec_counter).order_type_id := l_order_type_id;
                      oe_pc_attr_tbl(l_rec_counter).org_id := l_org_id;
                      oe_pc_attr_tbl(l_rec_counter).sold_to_org_id := l_sold_to_org_id;
                      oe_pc_attr_tbl(l_rec_counter).change_comments := l_change_comments;
		      oe_pc_attr_tbl(l_rec_counter).new_context_value := l_context_value_last;
		      oe_pc_attr_tbl(l_rec_counter).old_context_value := l_context_value;
                      l_rec_counter := l_rec_counter+1;

               END IF;

               <<next_attribute>>
               null;
            END LOOP;
            CLOSE REF_ATTR;

            FOR I in 1..oe_pc_attr_tbl.count LOOP
                IF (oe_pc_attr_tbl(I).old_attribute_value is not null OR
                   oe_pc_attr_tbl(I).new_attribute_value is not null) THEN
    	           IF l_debug_level  > 0 THEN
    	               oe_debug_pub.add('Inserting history records for order number => '||oe_pc_attr_tbl(i).order_number,1);

    	           END IF;
                   INSERT INTO OE_AUDIT_ATTR_HISTORY
                   (entity_id,
                    attribute_id,
                    reason_code,
                    hist_creation_date,
                    order_number,
                    user_id,
                    responsibility_id,
                    old_attribute_value,
                    new_attribute_value,
                    entity_number,

                    order_type_id,
                    org_id,
                    sold_to_org_id,
                    change_comments,
                    old_context_value,
                    new_context_value )
                   values
                   (oe_pc_attr_tbl(I).entity_id,
                    oe_pc_attr_tbl(I).attribute_id,
                    oe_pc_attr_tbl(I).reason_code,
                    oe_pc_attr_tbl(I).hist_creation_date,
                    oe_pc_attr_tbl(I).order_number,
                    oe_pc_attr_tbl(I).user_id,

                    oe_pc_attr_tbl(I).responsibility_id,
                    oe_pc_attr_tbl(I).old_attribute_value,
                    oe_pc_attr_tbl(I).new_attribute_value,
                    oe_pc_attr_tbl(I).entity_number,
                    oe_pc_attr_tbl(I).order_type_id,
                    oe_pc_attr_tbl(I).org_id,
                    oe_pc_attr_tbl(I).sold_to_org_id,
                    oe_pc_attr_tbl(I).change_comments,
                    oe_pc_attr_tbl(I).old_context_value,   --Bug4324371
                    oe_pc_attr_tbl(I).new_context_Value );
                END IF;
            END LOOP;
            oe_pc_attr_tbl.delete;

            COMMIT;
            OE_DEBUG_PUB.add(' ramising:  Doing COMMIT....',5 ) ;

            EXCEPTION WHEN OTHERS THEN
                OE_DEBUG_PUB.add('    In EXCEPTION : deleting  oe_pc_attr_tbl ', 5);
                oe_pc_attr_tbl.delete;  -- bug# 9067627 : Delete these tables when above INSERT encounters some error(s)
                                        --        e.g. => ORA-00001: unique constraint (ONT.OE_AUDIT_ATTR_HISTORY_U1) violated

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('   In EXCEPTION : SQL stmt => '||l_sql_stmt,1);
                    oe_debug_pub.add('   In EXCEPTION : SQL stmt last => '||l_sql_stmt_last,1);
                    oe_debug_pub.add('   In EXCEPTION : SQL stmt txn => '||l_sql_stmt_txn,1);
                    oe_debug_pub.add('   In EXCEPTION : Error => '||sqlerrm,1);
                END IF;
            END;
         END LOOP; /* Attr cursor */
      END LOOP;
      <<End_of_Entity>>
      null;

   END LOOP; /* entity cursor */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Exit audit history consolidator program..',1);
   END IF;
EXCEPTION  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exiting with error '||sqlerrm,1);
    END IF;
    retcode := 2;
    errbuf := sqlerrm;
END set_attribute_history;


FUNCTION get_num_date_from_canonical(p_datatype IN VARCHAR2
				    ,p_value    IN VARCHAR2
                                    )RETURN VARCHAR2 IS
l_varchar_out varchar2(2000);
INVALID_DATA_TYPE EXCEPTION;
BEGIN
IF    p_datatype  = 'N' THEN
      l_varchar_out := to_char(fnd_number.canonical_to_number(p_value));
ELSIF p_datatype = 'X' THEN
      l_varchar_out := fnd_date.canonical_to_date(p_value);
ELSIF p_datatype = 'Y' THEN
      l_varchar_out := fnd_date.canonical_to_date(p_value);
ELSIF p_datatype = 'C' THEN
      l_varchar_out := p_value;
ELSE
      l_varchar_out := p_value;
END IF;
RETURN l_varchar_out;

EXCEPTION When Others Then
	  l_varchar_out := p_value;
END GET_NUM_DATE_FROM_CANONICAL;

PROCEDURE get_valueset_id_r(p_flexfield_name  IN  VARCHAR2,
			    p_context         IN  VARCHAR2 ,
                            p_seg             IN  VARCHAR2 ,
	      		    x_vsid            OUT NOCOPY NUMBER,
			    x_format_type     OUT NOCOPY VARCHAR2,
                            x_validation_type OUT NOCOPY VARCHAR2)
IS
L_Valueset_R   FND_VSET.VALUESET_R;
X_VALUESETID   NUMBER;
L_valueset_dr  FND_VSET.VALUESET_DR;
v_dflex_r      fnd_dflex.dflex_r;
v_segments_dr  fnd_dflex.segments_dr;
v_context_r    fnd_dflex.context_r;
BEGIN
v_dflex_r.application_id := 660;
v_dflex_r.flexfield_name := p_flexfield_name;
v_context_r.flexfield := v_dflex_r;
v_context_r.context_code := p_context;
-- Get the enabled segments for the context selected.
fnd_dflex.get_segments(v_context_r,v_segments_dr,TRUE);

FOR i IN 1..v_segments_dr.nsegments LOOP
    IF (v_segments_dr.application_column_name(i) = p_seg) THEN
    	X_VALUESETID := v_SEGMENTS_dr.VALUE_SET(i);
        exit;
    END IF;
END LOOP;

IF X_VALUESETID IS NOT NULL THEN
   FND_VSET.GET_VALUESET(X_VALUESETID,l_valueset_r,l_valueset_dr);
   X_VSID :=X_VALUESETID;
   X_FORMAT_TYPE :=l_valueset_dr.FORMAT_TYPE;
   X_VALIDATION_TYPE :=l_valueset_r.VALIDATION_TYPE;
ELSE
   X_VSID :=NULL;
   X_FORMAT_TYPE :='C';
   X_VALIDATION_TYPE :=NULL;
END IF;
end GET_VALUESET_ID_R;

FUNCTION Get_Attribute_Value(p_FlexField_Name           IN VARCHAR2
                            ,p_Context_Name             IN VARCHAR2
			    ,p_segment_name             IN VARCHAR2
			    ,p_attr_value               IN VARCHAR2
			    ,p_comparison_operator_code IN VARCHAR2 := NULL
			  ) RETURN VARCHAR2 IS
Vset  FND_VSET.valueset_r;
Fmt   FND_VSET.valueset_dr;
Found BOOLEAN;
Row   NUMBER;
Value FND_VSET.value_dr;
x_Format_Type Varchar2(1);
x_Validation_Type Varchar2(1);
x_Vsid  NUMBER;
x_attr_value_code     VARCHAR2(240);
l_attr_value     VARCHAR2(2000);
Value_Valid_In_Valueset BOOLEAN := FALSE;
l_id	VARCHAR2(240);
l_value VARCHAR2(240);

BEGIN

OE_AUDIT_HISTORY_PVT.get_valueset_id_r(p_FlexField_Name
                                      ,p_Context_Name
                                      ,p_Segment_Name
                                      ,x_Vsid
                                      ,x_Format_Type
                                      ,x_Validation_Type);

l_attr_value := get_num_date_from_canonical(x_format_type,p_attr_value);

-- if comparison operator is other than  then no need to get the
-- meaning as the value itself will be stored in qualifier_attr_value

-- change made by spgopal. added parameter called p_comparison_operator_code
-- to generalise the code for all forms and packages

IF  p_comparison_operator_code <>  'BETWEEN'  THEN
    IF x_Validation_Type In('F' ,'I')  AND x_Vsid  IS NOT NULL THEN
	IF x_Validation_Type = 'I' THEN
           FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
           FND_VSET.get_value_init(Vset,TRUE);
           FND_VSET.get_value(Vset,Row,Found,Value);
           IF Fmt.Has_Id Then    --id is defined.Hence compare for id
              While(Found) Loop
                  If  l_attr_value  = Value.id  Then
	              x_attr_value_code  := Value.value;
                      Value_Valid_In_Valueset := TRUE;
                      EXIT;
                  End If;
                  FND_VSET.get_value(Vset,Row,Found,Value);
              End Loop;
           Else -- id not defined.Hence compare for value
              While(Found) Loop
                  If  l_attr_value  = Value.value  Then
                      x_attr_value_code  := l_attr_value;
                      Value_Valid_In_Valueset := TRUE;
                      EXIT;
                  End If;
                  FND_VSET.get_value(Vset,Row,Found,Value);
              End Loop;
          End If; ---end of Fmt.Has_Id
          FND_VSET.get_value_end(Vset);
       ELSIF X_Validation_type = 'F' THEN
          FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
          IF (OE_AUDIT_HISTORY_PVT.value_exists_in_table(Vset.table_info,l_attr_value,l_id,l_value)) THEN
              IF Fmt.Has_Id Then    --id is defined.Hence compare for id
                 If  l_attr_value  = l_id  Then
	             x_attr_value_code  := l_value;
                     Value_Valid_In_Valueset := TRUE;
                 End If;
              Else                 -- id not defined.Hence compare for value
                 If  l_attr_value  = l_value  Then
	             x_attr_value_code  := l_attr_value;
                     Value_Valid_In_Valueset := TRUE;
                 End If;
	      End if;          -- End of Fmt.Has_ID
          ELSE
	      Value_Valid_In_Valueset := FALSE;
	  END IF;
       END IF;   --X_Validation_Type
    ELSE -- if validation type is not F or I or valueset id is null (not defined)
       x_attr_value_code := l_attr_value;
    END IF;
ELSE  -- if comparison operator is 'between'
    x_attr_value_code  := l_attr_value;
END IF;
RETURN x_attr_value_code;

END Get_Attribute_Value;

FUNCTION Get_Display_Name(p_attribute_ID NUMBER,
			  p_context_value VARCHAR2 DEFAULT NULL,
			   p_old_context_value VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
p_display_name VARCHAR2(500);
p_column_name  VARCHAR2(50);
BEGIN
    BEGIN
        SELECT ATTRIBUTE_DISPLAY_NAME,COLUMN_NAME
        INTO   p_display_name,p_column_name
        FROM   OE_PC_ATTRIBUTES_V
        WHERE  ATTRIBUTE_ID = p_attribute_id;
    EXCEPTION WHEN OTHERS THEN
        p_display_name:=NULL;
    END;

    IF    (p_attribute_id between 1078 and 1092 ) OR (p_attribute_id between 4218 and 4222) THEN
          p_display_name := OE_AUDIT_HISTORY_PVT.Get_column_label('OE_HEADER_ATTRIBUTES',UPPER(p_column_name), p_context_value,p_old_context_value);
    ELSIF (p_attribute_id between 1018 and 1032) OR (p_attribute_id between 4223 and 4227) THEN
          p_display_name := OE_AUDIT_HISTORY_PVT.Get_column_label('OE_LINE_ATTRIBUTES',UPPER(p_column_name),p_context_value,p_old_context_value);
    END IF;

    RETURN p_display_name;

END Get_Display_Name;

FUNCTION Get_Column_Label(p_flexfield_name IN varchar2,
                          p_appl_column_name IN varchar2,
  			  p_context_value IN Varchar2 DEFAULT NULL,
			  p_old_context_value IN Varchar2 DEFAULT NULL) RETURN VARCHAR2
IS
p_column_label VARCHAR2(500);
BEGIN
    SELECT NVL(FORM_LEFT_PROMPT,FORM_ABOVE_PROMPT)
    INTO   p_column_label
    FROM   FND_DESCR_FLEX_COL_USAGE_VL
    WHERE  APPLICATION_ID=660
    AND    APPLICATION_COLUMN_NAME=p_appl_column_name
    AND    DESCRIPTIVE_FLEXFIELD_NAME=p_flexfield_name
    AND    DESCRIPTIVE_FLEX_CONTEXT_CODE IN ('Global Data Elements',p_context_value);
    RETURN p_column_label;
EXCEPTION WHEN NO_DATA_FOUND THEN
     BEGIN
      SELECT NVL(FORM_LEFT_PROMPT,FORM_ABOVE_PROMPT)
      INTO   p_column_label
      FROM   FND_DESCR_FLEX_COL_USAGE_VL
      WHERE  APPLICATION_ID=660
      AND    APPLICATION_COLUMN_NAME=p_appl_column_name
      AND    DESCRIPTIVE_FLEXFIELD_NAME=p_flexfield_name
      AND    DESCRIPTIVE_FLEX_CONTEXT_CODE = p_old_context_value;

     RETURN p_column_label;
     EXCEPTION WHEN OTHERS THEN
            OE_DEBUG_PUB.add('Unable to get column label : '||sqlerrm,1);
            RETURN NULL;
     END;
WHEN OTHERS THEN
 OE_DEBUG_PUB.add('Unable to get column label : '||sqlerrm,1);
 RETURN NULL;
END Get_Column_Label;

FUNCTION Get_translated_value(p_flexfield_name IN varchar2,
                               p_appl_column_name IN varchar2,
                               p_column_value IN varchar2,
			       p_context_value IN Varchar2 DEFAULT NULL)
RETURN VARCHAR2
IS
p_column_translated_value VARCHAR2(500);
v_context varchar2(30) := NULL;
BEGIN

SELECT DESCRIPTIVE_FLEX_CONTEXT_CODE
INTO   v_context
FROM   FND_DESCR_FLEX_COL_USAGE_VL
WHERE  APPLICATION_ID=660
AND    APPLICATION_COLUMN_NAME=p_appl_column_name
AND    DESCRIPTIVE_FLEXFIELD_NAME=p_flexfield_name
AND    DESCRIPTIVE_FLEX_CONTEXT_CODE IN ('Global Data Elements',p_context_value);

p_column_translated_value := OE_AUDIT_HISTORY_PVT.Get_Attribute_value(p_flexfield_name
                                                                     ,v_context
                                                                     ,p_appl_column_name
                                                                     ,p_column_value
                                                                     ,'=');
IF p_column_translated_value IS NULL THEN
   RETURN p_column_value;
ELSE
   RETURN p_column_translated_value;
END IF;

EXCEPTION WHEN OTHERS THEN
          OE_DEBUG_PUB.add('Error when getting translated value : '||sqlerrm,1);
          RETURN p_column_value;
END Get_Translated_Value;

-- ==========================================================================
-- Function  value_exists_in_table
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : None
--  DESCRIPTION
--    Searches for value if it exist by building dynamic query stmt when when valueset validation type is F
--    the list populated by  get_valueset call.
-- ===========================================================================


FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
                               p_value    VARCHAR2,
             		       x_id       OUT NOCOPY VARCHAR2,
			       x_value    OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
v_selectstmt   VARCHAR2(2000) ; --dhgupta changed length from 500 to 2000 for bug # 1888160
v_cursor_id    INTEGER;
v_value        VARCHAR2(150);
v_id           VARCHAR2(150);
v_retval       INTEGER;
v_where_clause fnd_flex_validation_tables.additional_where_clause%type;
v_cols	    VARCHAR2(1000);
l_order_by                    VARCHAR2(1000);
l_pos1		number;
l_where_length  number;

BEGIN
v_cursor_id := DBMS_SQL.OPEN_CURSOR;

IF instr(UPPER(p_table_r.where_clause), 'ORDER BY') > 0 THEN
   l_order_by := substr(p_table_r.where_clause, instr(UPPER(p_table_r.where_clause), 'ORDER BY'));
   v_where_clause := replace(p_table_r.where_clause, l_order_by ,'');
ELSE
   v_where_clause := p_table_r.where_clause;
END IF;

IF instr(upper(v_where_clause),'WHERE ') > 0 then
   v_where_clause:= rtrim(ltrim(v_where_clause));
   l_pos1 := instr(upper(v_where_clause),'WHERE');
   l_where_length := LENGTHB('WHERE');
   v_where_clause:= substr(v_where_clause,l_pos1+l_where_length);

   IF (p_table_r.id_column_name IS NOT NULL) THEN
       v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' AND '||v_where_clause;  -- 2492020
   ELSE
       v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' AND '||v_where_clause;--2492020
   END IF;
ELSE
   IF (p_table_r.id_column_name IS NOT NULL) THEN
      v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' '||v_where_clause;
   ELSE
      v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' '||v_where_clause;
   END IF;
END IF;
IF l_order_by IS NOT NULL THEN
   v_where_clause := v_where_clause||' '||l_order_by;
END IF;
v_cols := p_table_r.value_column_name;
IF (p_table_r.id_column_name IS NOT NULL) THEN
    IF (p_table_r.id_column_type IN ('D', 'N')) THEN
        v_cols := v_cols || ' , To_char(' || p_table_r.id_column_name || ')';
    ELSE
	v_cols := v_cols || ' , ' || p_table_r.id_column_name;
    END IF;
ELSE
    v_cols := v_cols || ', NULL ';
END IF;
v_selectstmt := 'SELECT  '||v_cols||' FROM  '||p_table_r.table_name||' '||v_where_clause;
oe_debug_pub.add('select stmt'||v_selectstmt);
-- parse the query
DBMS_SQL.PARSE(v_cursor_id,v_selectstmt,DBMS_SQL.V7);
-- Bind the input variables
DBMS_SQL.DEFINE_COLUMN(v_cursor_id,1,v_value,150);
DBMS_SQL.DEFINE_COLUMN(v_cursor_id,2,v_id,150);
v_retval := DBMS_SQL.EXECUTE(v_cursor_id);
LOOP
-- Fetch rows in to buffer and check the exit condition from  the loop
IF( DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0) THEN
    EXIT;
END IF;
-- Retrieve the rows from buffer into PLSQL variables
DBMS_SQL.COLUMN_VALUE(v_cursor_id,1,v_value);
DBMS_SQL.COLUMN_VALUE(v_cursor_id,2,v_id);

IF v_id IS NULL AND (p_value = v_value) THEN
   DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
   x_id := v_id;
   x_value := v_value;
   RETURN TRUE;
ELSIF (p_value = v_id) THEN
   DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
   x_id := v_id;
   x_value := v_value;
   RETURN TRUE;
ELSE
   Null;
   oe_debug_pub.add('value does notmatch, continue search'||p_value||','||v_id);
END IF;
END LOOP;
DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
RETURN FALSE;
EXCEPTION
   WHEN OTHERS THEN
	oe_debug_pub.add('value_exists_in_table exception');
        DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        RETURN FALSE;
END value_exists_in_table;

PROCEDURE Compare_Credit_Card
(   p_attribute_id        	IN NUMBER
,   p_header_id       		IN NUMBER
,   p_old_hist_creation_date    IN DATE
,   p_new_hist_creation_date    IN DATE
,   x_old_attribute_value       OUT NOCOPY VARCHAR2
,   x_new_attribute_value       OUT NOCOPY VARCHAR2
,   x_card_number_equal		OUT NOCOPY VARCHAR2
)
IS

l_old_instrument_id	NUMBER;
l_new_instrument_id	NUMBER;
l_column_name		VARCHAR2(30);
l_sql_stmt		VARCHAR2(1000);
l_old_sql_stmt		VARCHAR2(1000);
l_new_sql_stmt		VARCHAR2(1000);
l_old_exp_date		DATE;
l_new_exp_date		DATE;
l_old_holder_name	VARCHAR2(80);
l_new_holder_name	VARCHAR2(80);
l_old_cc_number		VARCHAR2(80);
l_new_cc_number		VARCHAR2(80);
l_old_cc_code		VARCHAR2(80);
l_new_cc_code		VARCHAR2(80);

type refcur is ref cursor;
ref_attr                REFCUR;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering Comparing_Credit_Card for attribute_id:  '||p_attribute_id, 1);
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('p_old_hist_creation_date is:  '||p_old_hist_creation_date, 3);
    oe_debug_pub.add('p_new_hist_creation_date is:  '||p_new_hist_creation_date, 3);
  END IF;


    BEGIN
      SELECT instrument_id, credit_card_expiration_date,credit_card_number,credit_card_code
      INTO  l_old_instrument_id,l_old_exp_date,l_old_cc_number, l_old_cc_code
      FROM   oe_order_header_history
      WHERE  header_id = p_header_id
      AND    hist_creation_date = p_old_hist_creation_date;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;


    BEGIN
      SELECT instrument_id,credit_card_expiration_date, credit_card_number,credit_card_code
      INTO  l_new_instrument_id,l_new_exp_date,l_new_cc_number, l_new_cc_code
      FROM   oe_order_header_history
      WHERE  header_id = p_header_id
      AND    hist_creation_date = p_new_hist_creation_date;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;


    IF p_attribute_id in (46, 49) AND l_old_cc_number IS NULL AND l_old_cc_code IS NULL THEN
    BEGIN
      SELECT instrid
      INTO   l_old_instrument_id
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = l_old_instrument_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_old_instrument_id := null;
    END;

    END IF;

    IF p_attribute_id in (46, 49) AND l_new_cc_number IS NULL AND l_new_cc_code IS NULL THEN

    BEGIN
      SELECT instrid
      INTO   l_new_instrument_id
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = l_new_instrument_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_new_instrument_id := null;
    END;

    END IF;




--   IF p_attribute_id = 49 AND l_old_exp_date is null and l_new_exp_date is null THEN
  -- IF p_attribute_id = 49 AND l_old_cc_number is not null and l_new_cc_number is not null THEN
   IF p_attribute_id = 49 THEN
    IF l_old_instrument_id IS NOT NULL AND l_new_instrument_id IS NOT NULL THEN
      IF OE_GLOBALS.Is_Same_Credit_Card(p_cc_num_old	=> null
                                         ,p_cc_num_new 		=> null
                                         ,p_instrument_id_old 	=> l_old_instrument_id
                                         ,p_instrument_id_new 	=> l_new_instrument_id)
      THEN
        x_card_number_equal := 'Y';
      ELSE
        x_card_number_equal := 'N';
      END IF;

    ELSIF l_old_instrument_id IS NULL AND l_new_instrument_id IS NULL THEN
     x_card_number_equal := 'Y';
    ELSE
     x_card_number_equal := 'N';
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('x_card_number_equal is:  '||x_card_number_equal, 3);
  END IF;

  IF p_attribute_id = 46 THEN
    l_column_name := 'CARD_ISSUER_CODE';
  ELSIF p_attribute_id = 47 THEN
    l_column_name := 'EXPIRYDATE';
  ELSIF p_attribute_id = 48 THEN
    l_column_name := 'CHNAME';
  ELSIF p_attribute_id = 49 THEN
    l_column_name := 'MASKED_CC_NUMBER';
  END IF;

  --IF l_debug_level  > 0 THEN
    --oe_debug_pub.add('l_old_cc_code is:  '||l_old_cc_code, 3);
    --oe_debug_pub.add('l_new_cc_code is:  '||l_new_cc_code, 3);
    --oe_debug_pub.add('l_old_cc_number is:  '||l_old_cc_number, 3);
    --oe_debug_pub.add('l_new_cc_number is:  '||l_new_cc_number, 3);
  --END IF;

  --get old and new attribute values for credit card number and credit card code.
  -- instrument_id stores the instrument_id
  IF p_attribute_id = 46 OR p_attribute_id = 49

  THEN
  l_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard'
                 || ' where instrid = :x ';

  OPEN ref_attr FOR l_sql_stmt using l_old_instrument_id ;
  FETCH ref_attr INTO x_old_attribute_value;
  CLOSE ref_attr;

  OPEN ref_attr FOR l_sql_stmt using l_new_instrument_id ;
  FETCH ref_attr INTO x_new_attribute_value;
  CLOSE ref_attr;

  -- instrument_id stores the card_history_change_id
  ELSIF p_attribute_id in (47, 48) THEN
    IF (l_old_cc_number is null and l_old_cc_number is null) THEN
  -- AND (l_old_cc_code is null and l_new_cc_code is null)
  -- THEN
  l_old_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard_h'
                 || ' where card_history_change_id = :x ';
    ELSE
      l_old_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard'
                 || ' where instrid = :x ';

    END IF;

   IF (l_new_cc_code is null and l_new_cc_code is null) THEN
     l_new_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard_h'
                 || ' where card_history_change_id = :x ';
    ELSE
      l_new_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard'
                 || ' where instrid = :x ';

    END IF;


  OPEN ref_attr FOR l_old_sql_stmt using l_old_instrument_id ;
  FETCH ref_attr INTO x_old_attribute_value;
  CLOSE ref_attr;

  OPEN ref_attr FOR l_new_sql_stmt using l_new_instrument_id ;
  FETCH ref_attr INTO x_new_attribute_value;
  CLOSE ref_attr;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('x_old_attribute_value is:  '||x_old_attribute_value, 3);
    oe_debug_pub.add('x_new_attribute_value is:  '||x_new_attribute_value, 3);
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Exiting Comparing_Credit_Card. ', 1);
  END IF;

END Compare_Credit_Card;

FUNCTION Get_Card_Attribute_Value
( p_instr_flag		IN VARCHAR2
, p_attribute_id 	IN NUMBER
, p_instrument_id 	IN NUMBER)
RETURN VARCHAR2 IS

l_card_attribute_value	VARCHAR2(80);
l_column_name           VARCHAR2(30);
l_sql_stmt              VARCHAR2(1000);
type refcur is ref cursor;
ref_attr                REFCUR;

BEGIN

  IF p_attribute_id = 46 THEN
    l_column_name := 'CARD_ISSUER_CODE';
  ELSIF p_attribute_id = 47 THEN
    l_column_name := 'EXPIRYDATE';
  ELSIF p_attribute_id = 48 THEN
    l_column_name := 'CHNAME';
  ELSIF p_attribute_id = 49 THEN
    l_column_name := 'MASKED_CC_NUMBER';
  END IF;

  IF  p_instr_flag = 'N'  THEN
    l_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard_h'
                 || ' where card_history_change_id = :x ';

  ELSE
    l_sql_stmt := 'select '
                 || l_column_name
                 || ' from iby_creditcard'
                 || ' where instrid = :x ';
  END IF;

  OPEN ref_attr FOR l_sql_stmt using p_instrument_id ;
  FETCH ref_attr INTO l_card_attribute_value;
  CLOSE ref_attr;

  RETURN l_card_attribute_value;

EXCEPTION WHEN OTHERS THEN
RETURN null;

END Get_Card_Attribute_Value;

--Added for bug5631508
PROCEDURE RECORD_SET_HISTORY(
	p_header_id  IN number ,
	p_line_id    IN number,
	p_set_id     IN number,
    	x_return_status OUT NOCOPY varchar2 ) is

l_set_name varchar2(30);
l_set_type varchar2(30);
begin
        select set_name,set_type into l_set_name,l_set_type
	from oe_sets
	where set_id=p_set_id;

	insert into OE_SETS_HISTORY
	(set_id,
	set_name,
	set_type,
	line_id,
	header_id,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by)
	values(
	p_set_id,
	l_set_name,
	l_set_type,
	p_line_id,
	p_header_id,
	sysdate,
	FND_GLOBAL.USER_ID,
	sysdate,
	FND_GLOBAL.USER_ID );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
      oe_debug_pub.add('Error in inserting data in sets history');
end;

--Added for bug5631508
PROCEDURE DELETE_SET_HISTORY(
	p_line_id    IN number,
	x_return_status OUT NOCOPY varchar2 ) is
begin
	delete from OE_SETS_HISTORY
	where line_id=p_line_id;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;
exception
	WHEN OTHERS THEN
         oe_debug_pub.add('Error in Deleting data from  sets history');
	  x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
end;


END OE_AUDIT_HISTORY_PVT;

/
