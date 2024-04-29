--------------------------------------------------------
--  DDL for Package Body XXAH_VA_OBIEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_OBIEE_PKG" AS
/**************************************************************************
 * VERSION      : $Id$
 * DESCRIPTION  : Contains functionality for the OBIEE reporting tool
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 05-OCT-2010 Serge Vervaet     Genesis
 * 07-Nov-2014 Vema Reddy        Added Combined Approval Flag, Automatic Accrual, Cost Center, Line Description,Tax Code, Open Item Key based on new Banners Project.
 *************************************************************************/

  PROCEDURE extract_obiee_data ( errbuf               OUT VARCHAR2
                               , retcode              OUT NUMBER
                               , p_refresh_from_date  IN  VARCHAR2
                               )
  IS

    l_count_update    NUMBER;
    l_count_insert    NUMBER;

    l_start_date      DATE;

    l_statement       VARCHAR2(255);


  BEGIN

    fnd_file.PUT_LINE (fnd_file.OUTPUT, 'Start extract_obiee_data  ('|| TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')||')');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, '  Parameter --> p_date = '|| p_refresh_from_date);
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_BLANKET_HEADERS_ALL');

    l_statement    := 'Maintain XXBI_VA_BLANKET_HEADERS_ALL';
    l_count_update := 0;
    l_count_insert := 0;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_BLANKET_HEADERS_ALL';

    FOR I in (
                SELECT obha.ATTRIBUTE2
                     , obha.ATTRIBUTE3
                     , obha.ATTRIBUTE4
                     , obha.ATTRIBUTE5
                     , obha.ATTRIBUTE6
                     , obha.ATTRIBUTE7
                     , obha.ATTRIBUTE9  -- Combined Approval Flag
                     , obha.ATTRIBUTE10 -- Automatic Accrual
                     , obha.BOOKED_FLAG
                     , obha.CREATED_BY
                     , obha.CREATION_DATE
                     , obha.CUSTOMER_SIGNATURE
                     , TRUNC(obha.CUSTOMER_SIGNATURE_DATE) CUSTOMER_SIGNATURE_DATE
                     , obha.DRAFT_SUBMITTED_FLAG
                     , obha.FLOW_STATUS_CODE
                     , obha.HEADER_ID
                     , obha.INVOICE_TO_ORG_ID
                     , obha.LAST_UPDATED_BY
                     , obha.LAST_UPDATE_DATE
                     , obha.OPEN_FLAG
                     , obha.ORDER_NUMBER
                     , obha.ORDER_TYPE_ID
                     , obha.ORG_ID
                     , obha.PAYMENT_TERM_ID
                     , obha.PRICE_LIST_ID
  --                   , obha.SALESREP_ID
       , ( SELECT  rs.SALESREP_ID * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD'))
           FROM per_all_people_f per
              , per_all_assignments_f         paf
              , jtf_rs_salesreps              rs
              , hr_all_organization_units     haou
                WHERE paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
                  AND trunc(obha.creation_date) BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,SYSDATE+1)
                  AND rs.PERSON_ID = per.PERSON_ID
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
                  and rs.salesrep_id= obha.salesrep_id) salesrep_id
  --
                     , obha.SOLD_TO_CONTACT_ID
                     , obha.SOLD_TO_ORG_ID
                     , obha.SOURCE_DOCUMENT_ID
                     , obha.SOURCE_DOCUMENT_TYPE_ID
                     , obha.SOURCE_DOCUMENT_VERSION_NUMBER
                     , obha.SUPPLIER_SIGNATURE
                     , obha.SUPPLIER_SIGNATURE_DATE
                     , obha.TRANSACTIONAL_CURR_CODE
                     , obha.VERSION_NUMBER
                     , obhe.BLANKET_MAX_AMOUNT
                     , obhe.BLANKET_MIN_AMOUNT
                     , TRUNC(obhe.END_DATE_ACTIVE) END_DATE_ACTIVE
                     , obhe.ENFORCE_INVOICE_TO_FLAG
                     , obhe.ENFORCE_PAYMENT_TERM_FLAG
                     , obhe.ENFORCE_PRICE_LIST_FLAG
                     , obhe.FULFILLED_AMOUNT
                     , obhe.NEW_PRICE_LIST_ID
                     , obhe.ON_HOLD_FLAG
                     , obhe.OVERRIDE_AMOUNT_FLAG
                     , obhe.RELEASED_AMOUNT
                     , obhe.RETURNED_AMOUNT
                     , TRUNC(obhe.START_DATE_ACTIVE) START_DATE_ACTIVE
                     , (SELECT MIN(TRUNC(besd.EXCEPTION_DATE))
                          FROM BOM_EXCEPTION_SETS      bes
                             , BOM_EXCEPTION_SET_DATES besd
                         WHERE bes.EXCEPTION_SET_NAME = obha.ORDER_NUMBER
                           AND bes.EXCEPTION_SET_ID   = besd.EXCEPTION_SET_ID
                           AND NOT EXISTS (
                                            SELECT 'Y'
                                              FROM OE_ORDER_HEADERS_ALL ooh
                                             WHERE ooh.BLANKET_NUMBER = obha.ORDER_NUMBER
                                               AND TRUNC(fnd_date.CANONICAL_TO_DATE(ooh.ATTRIBUTE2)) = besd.EXCEPTION_DATE
                                           )
                       ) invoice_date
                     , obha.SALES_DOCUMENT_NAME
                     , 'EBS' USED_BY
                  FROM oe_blanket_headers_all obha
                     , oe_blanket_headers_ext obhe
                 WHERE obha.ORDER_NUMBER = obhe.ORDER_NUMBER
             )
    LOOP

      UPDATE XXBI_VA_BLANKET_HEADERS_ALL
         SET
              ORG_ID                          = I.ORG_ID
           ,  PAYMENT_TERM_ID                 = I.PAYMENT_TERM_ID
           ,  PRICE_LIST_ID                   = I.PRICE_LIST_ID
           ,  SALESREP_ID                     = I.SALESREP_ID
           ,  SOLD_TO_CONTACT_ID              = I.SOLD_TO_CONTACT_ID
           ,  SOLD_TO_ORG_ID                  = I.SOLD_TO_ORG_ID
           ,  SOURCE_DOCUMENT_ID              = I.SOURCE_DOCUMENT_ID
           ,  SOURCE_DOCUMENT_TYPE_ID         = I.SOURCE_DOCUMENT_TYPE_ID
           ,  SOURCE_DOCUMENT_VERSION_NUMBER  = I.SOURCE_DOCUMENT_VERSION_NUMBER
           ,  SUPPLIER_SIGNATURE              = I.SUPPLIER_SIGNATURE
           ,  SUPPLIER_SIGNATURE_DATE         = I.SUPPLIER_SIGNATURE_DATE
           ,  TRANSACTIONAL_CURR_CODE         = I.TRANSACTIONAL_CURR_CODE
           ,  VERSION_NUMBER                  = I.VERSION_NUMBER
           ,  BLANKET_MAX_AMOUNT              = I.BLANKET_MAX_AMOUNT
           ,  BLANKET_MIN_AMOUNT              = I.BLANKET_MIN_AMOUNT
           ,  END_DATE_ACTIVE                 = I.END_DATE_ACTIVE
           ,  ENFORCE_INVOICE_TO_FLAG         = I.ENFORCE_INVOICE_TO_FLAG
           ,  ENFORCE_PAYMENT_TERM_FLAG       = I.ENFORCE_PAYMENT_TERM_FLAG
           ,  ENFORCE_PRICE_LIST_FLAG         = I.ENFORCE_PRICE_LIST_FLAG
           ,  FULFILLED_AMOUNT                = I.FULFILLED_AMOUNT
           ,  NEW_PRICE_LIST_ID               = I.NEW_PRICE_LIST_ID
           ,  ON_HOLD_FLAG                    = I.ON_HOLD_FLAG
           ,  OVERRIDE_AMOUNT_FLAG            = I.OVERRIDE_AMOUNT_FLAG
           ,  RELEASED_AMOUNT                 = I.RELEASED_AMOUNT
           ,  RETURNED_AMOUNT                 = I.RETURNED_AMOUNT
           ,  START_DATE_ACTIVE               = I.START_DATE_ACTIVE
           ,  INVOICE_DATE                    = I.INVOICE_DATE
           ,  ATTRIBUTE2                      = I.ATTRIBUTE2
           ,  ATTRIBUTE3                      = I.ATTRIBUTE3
           ,  ATTRIBUTE4                      = I.ATTRIBUTE4
           ,  ATTRIBUTE5                      = I.ATTRIBUTE5
           ,  ATTRIBUTE6                      = I.ATTRIBUTE6
           ,  ATTRIBUTE7                      = I.ATTRIBUTE7
           ,  ATTRIBUTE9                      = I.ATTRIBUTE9
           ,  ATTRIBUTE10                     = I.ATTRIBUTE10
           ,  BOOKED_FLAG                     = I.BOOKED_FLAG
           ,  CREATED_BY                      = I.CREATED_BY
           ,  CREATION_DATE                   = I.CREATION_DATE
           ,  CUSTOMER_SIGNATURE              = I.CUSTOMER_SIGNATURE
           ,  CUSTOMER_SIGNATURE_DATE         = I.CUSTOMER_SIGNATURE_DATE
           ,  DRAFT_SUBMITTED_FLAG            = I.DRAFT_SUBMITTED_FLAG
           ,  FLOW_STATUS_CODE                = I.FLOW_STATUS_CODE
           ,  HEADER_ID                       = I.HEADER_ID
           ,  INVOICE_TO_ORG_ID               = I.INVOICE_TO_ORG_ID
           ,  LAST_UPDATED_BY                 = I.LAST_UPDATED_BY
           ,  LAST_UPDATE_DATE                = I.LAST_UPDATE_DATE
           ,  OPEN_FLAG                       = I.OPEN_FLAG
           ,  ORDER_NUMBER                    = I.ORDER_NUMBER
           ,  ORDER_TYPE_ID                   = I.ORDER_TYPE_ID
           ,  SALES_DOCUMENT_NAME             = I.SALES_DOCUMENT_NAME
           ,  USED_BY                         = I.USED_BY
       WHERE HEADER_ID = I.HEADER_ID;

      IF SQL%NOTFOUND
      THEN

        INSERT INTO XXBI_VA_BLANKET_HEADERS_ALL
             (  ORG_ID
             ,  PAYMENT_TERM_ID
             ,  PRICE_LIST_ID
             ,  SALESREP_ID
             ,  SOLD_TO_CONTACT_ID
             ,  SOLD_TO_ORG_ID
             ,  SOURCE_DOCUMENT_ID
             ,  SOURCE_DOCUMENT_TYPE_ID
             ,  SOURCE_DOCUMENT_VERSION_NUMBER
             ,  SUPPLIER_SIGNATURE
             ,  SUPPLIER_SIGNATURE_DATE
             ,  TRANSACTIONAL_CURR_CODE
             ,  VERSION_NUMBER
             ,  BLANKET_MAX_AMOUNT
             ,  BLANKET_MIN_AMOUNT
             ,  END_DATE_ACTIVE
             ,  ENFORCE_INVOICE_TO_FLAG
             ,  ENFORCE_PAYMENT_TERM_FLAG
             ,  ENFORCE_PRICE_LIST_FLAG
             ,  FULFILLED_AMOUNT
             ,  NEW_PRICE_LIST_ID
             ,  ON_HOLD_FLAG
             ,  OVERRIDE_AMOUNT_FLAG
             ,  RELEASED_AMOUNT
             ,  RETURNED_AMOUNT
             ,  START_DATE_ACTIVE
             ,  INVOICE_DATE
             ,  ATTRIBUTE2
             ,  ATTRIBUTE3
             ,  ATTRIBUTE4
             ,  ATTRIBUTE5
             ,  ATTRIBUTE6
             ,  ATTRIBUTE7
             ,  ATTRIBUTE9
             ,  ATTRIBUTE10
             ,  BOOKED_FLAG
             ,  CREATED_BY
             ,  CREATION_DATE
             ,  CUSTOMER_SIGNATURE
             ,  CUSTOMER_SIGNATURE_DATE
             ,  DRAFT_SUBMITTED_FLAG
             ,  FLOW_STATUS_CODE
             ,  HEADER_ID
             ,  INVOICE_TO_ORG_ID
             ,  LAST_UPDATED_BY
             ,  LAST_UPDATE_DATE
             ,  OPEN_FLAG
             ,  ORDER_NUMBER
             ,  ORDER_TYPE_ID
             ,  SALES_DOCUMENT_NAME
             ,  USED_BY
             )
        VALUES
             (  I.ORG_ID
             ,  I.PAYMENT_TERM_ID
             ,  I.PRICE_LIST_ID
             ,  I.SALESREP_ID
             ,  I.SOLD_TO_CONTACT_ID
             ,  I.SOLD_TO_ORG_ID
             ,  I.SOURCE_DOCUMENT_ID
             ,  I.SOURCE_DOCUMENT_TYPE_ID
             ,  I.SOURCE_DOCUMENT_VERSION_NUMBER
             ,  I.SUPPLIER_SIGNATURE
             ,  I.SUPPLIER_SIGNATURE_DATE
             ,  I.TRANSACTIONAL_CURR_CODE
             ,  I.VERSION_NUMBER
             ,  I.BLANKET_MAX_AMOUNT
             ,  I.BLANKET_MIN_AMOUNT
             ,  I.END_DATE_ACTIVE
             ,  I.ENFORCE_INVOICE_TO_FLAG
             ,  I.ENFORCE_PAYMENT_TERM_FLAG
             ,  I.ENFORCE_PRICE_LIST_FLAG
             ,  I.FULFILLED_AMOUNT
             ,  I.NEW_PRICE_LIST_ID
             ,  I.ON_HOLD_FLAG
             ,  I.OVERRIDE_AMOUNT_FLAG
             ,  I.RELEASED_AMOUNT
             ,  I.RETURNED_AMOUNT
             ,  I.START_DATE_ACTIVE
             ,  I.INVOICE_DATE
             ,  I.ATTRIBUTE2
             ,  I.ATTRIBUTE3
             ,  I.ATTRIBUTE4
             ,  I.ATTRIBUTE5
             ,  I.ATTRIBUTE6
             ,  I.ATTRIBUTE7
             ,  I.ATTRIBUTE9
             ,  I.ATTRIBUTE10
             ,  I.BOOKED_FLAG
             ,  I.CREATED_BY
             ,  I.CREATION_DATE
             ,  I.CUSTOMER_SIGNATURE
             ,  I.CUSTOMER_SIGNATURE_DATE
             ,  I.DRAFT_SUBMITTED_FLAG
             ,  I.FLOW_STATUS_CODE
             ,  I.HEADER_ID
             ,  I.INVOICE_TO_ORG_ID
             ,  I.LAST_UPDATED_BY
             ,  I.LAST_UPDATE_DATE
             ,  I.OPEN_FLAG
             ,  I.ORDER_NUMBER
             ,  I.ORDER_TYPE_ID
             ,  I.SALES_DOCUMENT_NAME
             ,  I.USED_BY
             );

        l_count_insert := l_count_insert + 1;

      ELSE

        l_count_update := l_count_update + 1;

      END IF;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_BLANKET_HEADERS_ALL', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_BLANKET_LINES_ALL');

    l_statement    := 'Maintain XXBI_VA_BLANKET_LINES_ALL';
    l_count_update := 0;
    l_count_insert := 0;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_BLANKET_LINES_ALL';

    FOR I in (
                SELECT obla.ATTRIBUTE1
                     , NVL(obla.ATTRIBUTE2,'Y') ATTRIBUTE2
                     , obla.attribute4  -- Cost Center
                     , obla.attribute5  -- Line Description
                     , obla.attribute6  -- Billing Type
                     , obla.attribute7  -- Open Item Key
                     , obla.attribute8  -- billing by
                     , obla.attribute9  -- Brand Indicator
                     , obla.CONTEXT
                     , obla.CREATED_BY
                     , obla.CREATION_DATE
                     , obla.HEADER_ID
                     , obla.INVENTORY_ITEM_ID
                     , obla.INVOICE_TO_ORG_ID
                     , obla.LAST_UPDATED_BY
                     , obla.LAST_UPDATE_DATE
                     , obla.LINE_ID
                     , obla.ORDERED_ITEM
                     , obla.ORDER_QUANTITY_UOM
                     , obla.ORG_ID
                     , obla.PAYMENT_TERM_ID
                     , obla.PRICE_LIST_ID
--                     , obla.SALESREP_ID
       , ( SELECT  rs.SALESREP_ID * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD'))
           FROM per_all_people_f per
              , per_all_assignments_f         paf
              , jtf_rs_salesreps              rs
              , hr_all_organization_units     haou
                WHERE paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
                  AND trunc(obla.creation_date) BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,SYSDATE+1)
                  AND rs.PERSON_ID = per.PERSON_ID
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
                  and rs.salesrep_id= obla.salesrep_id) salesrep_id
--
                     , oble.BLANKET_LINE_MAX_AMOUNT
                     , oble.BLANKET_LINE_MIN_AMOUNT
                     , oble.BLANKET_MAX_QUANTITY
                     , oble.BLANKET_MIN_QUANTITY
                     , TRUNC(oble.END_DATE_ACTIVE) END_DATE_ACTIVE
                     , oble.ENFORCE_INVOICE_TO_FLAG
                     , oble.ENFORCE_PAYMENT_TERM_FLAG
                     , oble.ENFORCE_PRICE_LIST_FLAG
                     , oble.FULFILLED_AMOUNT
                     , oble.FULFILLED_QUANTITY
                     , oble.LINE_NUMBER
                     , oble.MAX_RELEASE_AMOUNT
                     , oble.MAX_RELEASE_QUANTITY
                     , oble.MIN_RELEASE_AMOUNT
                     , oble.MIN_RELEASE_QUANTITY
                     , oble.ORDER_NUMBER
                     , oble.RELEASED_AMOUNT
                     , oble.RELEASED_QUANTITY
                     , oble.RETURNED_AMOUNT
                     , oble.RETURNED_QUANTITY
                     , TRUNC(oble.START_DATE_ACTIVE)  START_DATE_ACTIVE
                     , 'EBS' USED_BY
                  FROM oe_blanket_lines_all obla
                     , oe_blanket_lines_ext oble
                 WHERE obla.LINE_ID = oble.line_id
             )
    LOOP

      UPDATE XXBI_VA_BLANKET_LINES_ALL
         SET
              ATTRIBUTE1                      = I.ATTRIBUTE1
           ,  ATTRIBUTE2                      = I.ATTRIBUTE2
           ,  ATTRIBUTE4                      = I.ATTRIBUTE4
           ,  ATTRIBUTE5                      = I.ATTRIBUTE5
           ,  ATTRIBUTE6                      = I.ATTRIBUTE6
           ,  ATTRIBUTE7                      = I.ATTRIBUTE7
           ,  ATTRIBUTE8                      = I.ATTRIBUTE8
           ,  ATTRIBUTE9                      = I.ATTRIBUTE9
           ,  CONTEXT                         = I.CONTEXT
           ,  CREATED_BY                      = I.CREATED_BY
           ,  CREATION_DATE                   = I.CREATION_DATE
           ,  HEADER_ID                       = I.HEADER_ID
           ,  INVENTORY_ITEM_ID               = I.INVENTORY_ITEM_ID
           ,  INVOICE_TO_ORG_ID               = I.INVOICE_TO_ORG_ID
           ,  LAST_UPDATED_BY                 = I.LAST_UPDATED_BY
           ,  LAST_UPDATE_DATE                = I.LAST_UPDATE_DATE
           ,  LINE_ID                         = I.LINE_ID
           ,  ORDERED_ITEM                    = I.ORDERED_ITEM
           ,  ORDER_QUANTITY_UOM              = I.ORDER_QUANTITY_UOM
           ,  ORG_ID                          = I.ORG_ID
           ,  PAYMENT_TERM_ID                 = I.PAYMENT_TERM_ID
           ,  PRICE_LIST_ID                   = I.PRICE_LIST_ID
           ,  SALESREP_ID                     = I.SALESREP_ID
           ,  BLANKET_LINE_MAX_AMOUNT         = I.BLANKET_LINE_MAX_AMOUNT
           ,  BLANKET_LINE_MIN_AMOUNT         = I.BLANKET_LINE_MIN_AMOUNT
           ,  BLANKET_MAX_QUANTITY            = I.BLANKET_MAX_QUANTITY
           ,  BLANKET_MIN_QUANTITY            = I.BLANKET_MIN_QUANTITY
           ,  END_DATE_ACTIVE                 = I.END_DATE_ACTIVE
           ,  ENFORCE_INVOICE_TO_FLAG         = I.ENFORCE_INVOICE_TO_FLAG
           ,  ENFORCE_PAYMENT_TERM_FLAG       = I.ENFORCE_PAYMENT_TERM_FLAG
           ,  ENFORCE_PRICE_LIST_FLAG         = I.ENFORCE_PRICE_LIST_FLAG
           ,  FULFILLED_AMOUNT                = I.FULFILLED_AMOUNT
           ,  FULFILLED_QUANTITY              = I.FULFILLED_QUANTITY
           ,  LINE_NUMBER                     = I.LINE_NUMBER
           ,  MAX_RELEASE_AMOUNT              = I.MAX_RELEASE_AMOUNT
           ,  MAX_RELEASE_QUANTITY            = I.MAX_RELEASE_QUANTITY
           ,  MIN_RELEASE_AMOUNT              = I.MIN_RELEASE_AMOUNT
           ,  MIN_RELEASE_QUANTITY            = I.MIN_RELEASE_QUANTITY
           ,  ORDER_NUMBER                    = I.ORDER_NUMBER
           ,  RELEASED_AMOUNT                 = I.RELEASED_AMOUNT
           ,  RELEASED_QUANTITY               = I.RELEASED_QUANTITY
           ,  RETURNED_AMOUNT                 = I.RETURNED_AMOUNT
           ,  RETURNED_QUANTITY               = I.RETURNED_QUANTITY
           ,  START_DATE_ACTIVE               = I.START_DATE_ACTIVE
           ,  USED_BY                         = I.USED_BY
       WHERE LINE_ID = I.LINE_ID;

      IF SQL%NOTFOUND
      THEN

        INSERT INTO XXBI_VA_BLANKET_LINES_ALL
             (  ATTRIBUTE1
             ,  ATTRIBUTE2
             ,  ATTRIBUTE4
             ,  ATTRIBUTE5
             ,  ATTRIBUTE6
             ,  ATTRIBUTE7
             ,  ATTRIBUTE8
             ,  ATTRIBUTE9
             ,  CONTEXT
             ,  CREATED_BY
             ,  CREATION_DATE
             ,  HEADER_ID
             ,  INVENTORY_ITEM_ID
             ,  INVOICE_TO_ORG_ID
             ,  LAST_UPDATED_BY
             ,  LAST_UPDATE_DATE
             ,  LINE_ID
             ,  ORDERED_ITEM
             ,  ORDER_QUANTITY_UOM
             ,  ORG_ID
             ,  PAYMENT_TERM_ID
             ,  PRICE_LIST_ID
             ,  SALESREP_ID
             ,  BLANKET_LINE_MAX_AMOUNT
             ,  BLANKET_LINE_MIN_AMOUNT
             ,  BLANKET_MAX_QUANTITY
             ,  BLANKET_MIN_QUANTITY
             ,  END_DATE_ACTIVE
             ,  ENFORCE_INVOICE_TO_FLAG
             ,  ENFORCE_PAYMENT_TERM_FLAG
             ,  ENFORCE_PRICE_LIST_FLAG
             ,  FULFILLED_AMOUNT
             ,  FULFILLED_QUANTITY
             ,  LINE_NUMBER
             ,  MAX_RELEASE_AMOUNT
             ,  MAX_RELEASE_QUANTITY
             ,  MIN_RELEASE_AMOUNT
             ,  MIN_RELEASE_QUANTITY
             ,  ORDER_NUMBER
             ,  RELEASED_AMOUNT
             ,  RELEASED_QUANTITY
             ,  RETURNED_AMOUNT
             ,  RETURNED_QUANTITY
             ,  START_DATE_ACTIVE
             ,  USED_BY
             )
           VALUES
             (  I.ATTRIBUTE1
             ,  I.ATTRIBUTE2
             ,  I.ATTRIBUTE4
             ,  I.ATTRIBUTE5
             ,  I.ATTRIBUTE6
             ,  I.ATTRIBUTE7
             ,  I.ATTRIBUTE8
             ,  I.ATTRIBUTE9
             ,  I.CONTEXT
             ,  I.CREATED_BY
             ,  I.CREATION_DATE
             ,  I.HEADER_ID
             ,  I.INVENTORY_ITEM_ID
             ,  I.INVOICE_TO_ORG_ID
             ,  I.LAST_UPDATED_BY
             ,  I.LAST_UPDATE_DATE
             ,  I.LINE_ID
             ,  I.ORDERED_ITEM
             ,  I.ORDER_QUANTITY_UOM
             ,  I.ORG_ID
             ,  I.PAYMENT_TERM_ID
             ,  I.PRICE_LIST_ID
             ,  I.SALESREP_ID
             ,  I.BLANKET_LINE_MAX_AMOUNT
             ,  I.BLANKET_LINE_MIN_AMOUNT
             ,  I.BLANKET_MAX_QUANTITY
             ,  I.BLANKET_MIN_QUANTITY
             ,  I.END_DATE_ACTIVE
             ,  I.ENFORCE_INVOICE_TO_FLAG
             ,  I.ENFORCE_PAYMENT_TERM_FLAG
             ,  I.ENFORCE_PRICE_LIST_FLAG
             ,  I.FULFILLED_AMOUNT
             ,  I.FULFILLED_QUANTITY
             ,  I.LINE_NUMBER
             ,  I.MAX_RELEASE_AMOUNT
             ,  I.MAX_RELEASE_QUANTITY
             ,  I.MIN_RELEASE_AMOUNT
             ,  I.MIN_RELEASE_QUANTITY
             ,  I.ORDER_NUMBER
             ,  I.RELEASED_AMOUNT
             ,  I.RELEASED_QUANTITY
             ,  I.RETURNED_AMOUNT
             ,  I.RETURNED_QUANTITY
             ,  I.START_DATE_ACTIVE
             ,  I.USED_BY
             );

        l_count_insert := l_count_insert + 1;

      ELSE

        l_count_update := l_count_update + 1;

      END IF;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_BLANKET_LINES_ALL', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_ORDER_HEADERS_ALL');

    l_statement    := 'Maintain XXBI_VA_ORDER_HEADERS_ALL';
    l_count_update := 0;
    l_count_insert := 0;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_ORDER_HEADERS_ALL';

    FOR I in (
                SELECT ooh.ATTRIBUTE1
                     , ooh.ATTRIBUTE2
                     , ooh.ATTRIBUTE3
                     , ooh.ATTRIBUTE4
                     , ooh.ATTRIBUTE5
                     , ooh.BLANKET_NUMBER
                     , ooh.BOOKED_DATE
                     , ooh.BOOKED_FLAG
                     , ooh.CANCELLED_FLAG
                     , ooh.CREATED_BY
                     , ooh.CREATION_DATE
                     , ooh.FLOW_STATUS_CODE
                     , ooh.HEADER_ID
                     , ooh.INVOICE_TO_ORG_ID
                     , ooh.LAST_UPDATED_BY
                     , ooh.LAST_UPDATE_DATE
                     , ooh.OPEN_FLAG
                     , ooh.ORDERED_DATE
                     , ooh.ORDER_NUMBER
                     , ooh.ORDER_TYPE_ID
                     , ooh.ORG_ID
                     , ooh.PAYMENT_TERM_ID
                     , ooh.PRICE_LIST_ID
                     , ooh.REQUEST_DATE
--                     , ooh.SALESREP_ID
       , ( SELECT  rs.SALESREP_ID
                   * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD'))
           FROM per_all_people_f per
              , per_all_assignments_f         paf
              , jtf_rs_salesreps              rs
              , hr_all_organization_units     haou
                WHERE paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
                  AND trunc(ooh.creation_date) BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,SYSDATE+1)
                  AND rs.PERSON_ID = per.PERSON_ID
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
                  and rs.salesrep_id= ooh.salesrep_id) salesrep_id
--
                     , ooh.TRANSACTIONAL_CURR_CODE
                     , ot.name   ORDER_TYPE
                  FROM oe_order_headers_all    ooh
                     , oe_transaction_types_tl ot
                 WHERE ooh.order_type_id = ot.transaction_type_id
                   AND ot.language = USERENV('lang')
             )
    LOOP

      UPDATE XXBI_VA_ORDER_HEADERS_ALL
         SET
             ATTRIBUTE1                      = I.ATTRIBUTE1
           , ATTRIBUTE2                      = I.ATTRIBUTE2
           , ATTRIBUTE3                      = I.ATTRIBUTE3
           , ATTRIBUTE4                      = I.ATTRIBUTE4
           , ATTRIBUTE5                      = I.ATTRIBUTE5
           , BLANKET_NUMBER                  = I.BLANKET_NUMBER
           , BOOKED_DATE                     = I.BOOKED_DATE
           , BOOKED_FLAG                     = I.BOOKED_FLAG
           , CANCELLED_FLAG                  = I.CANCELLED_FLAG
           , CREATED_BY                      = I.CREATED_BY
           , CREATION_DATE                   = I.CREATION_DATE
           , FLOW_STATUS_CODE                = I.FLOW_STATUS_CODE
           , HEADER_ID                       = I.HEADER_ID
           , INVOICE_TO_ORG_ID               = I.INVOICE_TO_ORG_ID
           , LAST_UPDATED_BY                 = I.LAST_UPDATED_BY
           , LAST_UPDATE_DATE                = I.LAST_UPDATE_DATE
           , OPEN_FLAG                       = I.OPEN_FLAG
           , ORDERED_DATE                    = I.ORDERED_DATE
           , ORDER_NUMBER                    = I.ORDER_NUMBER
           , ORDER_TYPE_ID                   = I.ORDER_TYPE_ID
           , ORG_ID                          = I.ORG_ID
           , PAYMENT_TERM_ID                 = I.PAYMENT_TERM_ID
           , PRICE_LIST_ID                   = I.PRICE_LIST_ID
           , REQUEST_DATE                    = I.REQUEST_DATE
           , SALESREP_ID                     = I.SALESREP_ID
           , TRANSACTIONAL_CURR_CODE         = I.TRANSACTIONAL_CURR_CODE
           , ORDER_TYPE                      = I.ORDER_TYPE
       WHERE HEADER_ID = I.HEADER_ID;

      IF SQL%NOTFOUND
      THEN

        INSERT INTO XXBI_VA_ORDER_HEADERS_ALL
             (  ATTRIBUTE1
             ,  ATTRIBUTE2
             ,  ATTRIBUTE3
             ,  ATTRIBUTE4
             ,  ATTRIBUTE5
             ,  BLANKET_NUMBER
             ,  BOOKED_DATE
             ,  BOOKED_FLAG
             ,  CANCELLED_FLAG
             ,  CREATED_BY
             ,  CREATION_DATE
             ,  FLOW_STATUS_CODE
             ,  HEADER_ID
             ,  INVOICE_TO_ORG_ID
             ,  LAST_UPDATED_BY
             ,  LAST_UPDATE_DATE
             ,  OPEN_FLAG
             ,  ORDERED_DATE
             ,  ORDER_NUMBER
             ,  ORDER_TYPE_ID
             ,  ORG_ID
             ,  PAYMENT_TERM_ID
             ,  PRICE_LIST_ID
             ,  REQUEST_DATE
             ,  SALESREP_ID
             ,  TRANSACTIONAL_CURR_CODE
             ,  ORDER_TYPE
             )
        VALUES
             (  I.ATTRIBUTE1
             ,  I.ATTRIBUTE2
             ,  I.ATTRIBUTE3
             ,  I.ATTRIBUTE4
             ,  I.ATTRIBUTE5
             ,  I.BLANKET_NUMBER
             ,  I.BOOKED_DATE
             ,  I.BOOKED_FLAG
             ,  I.CANCELLED_FLAG
             ,  I.CREATED_BY
             ,  I.CREATION_DATE
             ,  I.FLOW_STATUS_CODE
             ,  I.HEADER_ID
             ,  I.INVOICE_TO_ORG_ID
             ,  I.LAST_UPDATED_BY
             ,  I.LAST_UPDATE_DATE
             ,  I.OPEN_FLAG
             ,  I.ORDERED_DATE
             ,  I.ORDER_NUMBER
             ,  I.ORDER_TYPE_ID
             ,  I.ORG_ID
             ,  I.PAYMENT_TERM_ID
             ,  I.PRICE_LIST_ID
             ,  I.REQUEST_DATE
             ,  I.SALESREP_ID
             ,  I.TRANSACTIONAL_CURR_CODE
             ,  I.ORDER_TYPE
             );

        l_count_insert := l_count_insert + 1;

      ELSE

        l_count_update := l_count_update + 1;

      END IF;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_ORDER_HEADERS_ALL', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_ORDER_LINES_ALL');

    l_statement    := 'Maintain XXBI_VA_ORDER_LINES_ALL';
    l_count_update := 0;
    l_count_insert := 0;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_ORDER_LINES_ALL';

    FOR I in (
                SELECT ool.LINE_ID
                     , ool.LINE_NUMBER
                     , ool.LINE_TYPE_ID
                     , ool.OPEN_FLAG
                     , ool.ORDERED_QUANTITY
                     , ool.ORDER_QUANTITY_UOM
                     , ool.ORG_ID
                     , ool.PAYMENT_TERM_ID
                     , ool.PRICE_LIST_ID
                     , ool.PRICING_DATE
                     , ool.PRICING_QUANTITY
                     , ool.PRICING_QUANTITY_UOM
                     , ool.REQUEST_DATE
                     , ool.RETURN_REASON_CODE
--                     , ool.SALESREP_ID
       , ( SELECT  rs.SALESREP_ID * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD'))
           FROM per_all_people_f per
              , per_all_assignments_f         paf
              , jtf_rs_salesreps              rs
              , hr_all_organization_units     haou
                WHERE paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
                  AND trunc(ool.creation_date) BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,SYSDATE+1)
                  AND rs.PERSON_ID = per.PERSON_ID
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
                  and rs.salesrep_id= ool.salesrep_id) salesrep_id
--
                     , ool.UNIT_LIST_PRICE
                     , ool.UNIT_LIST_PRICE_PER_PQTY
                     , ool.UNIT_SELLING_PERCENT
                     , ool.UNIT_SELLING_PRICE
                     , ool.UNIT_SELLING_PRICE_PER_PQTY
                     , ool.ACTUAL_FULFILLMENT_DATE
                     , ool.BLANKET_LINE_NUMBER
                     , ooh.BLANKET_NUMBER
                     , ool.BLANKET_VERSION_NUMBER
                     , ool.BOOKED_FLAG
                     , ool.CALCULATE_PRICE_FLAG
                     , ool.CANCELLED_FLAG
                     , ool.CANCELLED_QUANTITY
                     , ool.CREATED_BY
                     , ool.CREATION_DATE
                     , ool.CUSTOMER_PAYMENT_TERM_ID
                     , ool.FLOW_STATUS_CODE
                     , ool.FULFILLED_FLAG
                     , ool.FULFILLED_QUANTITY
                     , ool.FULFILLMENT_DATE
                     , ool.HEADER_ID
                     , ool.INVENTORY_ITEM_ID
                     , ool.INVOICED_QUANTITY
                     , ool.INVOICE_INTERFACE_STATUS_CODE
                     , ool.INVOICE_TO_CONTACT_ID
                     , ool.INVOICE_TO_ORG_ID
                     , ool.attribute2  -- Line Description
                     , ool.attribute3  -- Cost Center
                     , ool.attribute4  -- Open Item Key
                     , ool.attribute5  -- Bill Type
                     , ool.attribute6  -- Supplier document Nrs
                     , ool.attribute7  -- Chartfield3
                     , ool.tax_code
                     , ool.LAST_UPDATED_BY
                     , ool.LAST_UPDATE_DATE
                     , ool.LINE_CATEGORY_CODE
                  FROM oe_order_lines_all ool
                     , oe_order_headers_all    ooh
                 WHERE ooh.HEADER_ID = ool.HEADER_ID
             )
    LOOP

      UPDATE XXBI_VA_ORDER_LINES_ALL
         SET
              LINE_ID                         = I.LINE_ID
            , LINE_NUMBER                     = I.LINE_NUMBER
            , LINE_TYPE_ID                    = I.LINE_TYPE_ID
            , OPEN_FLAG                       = I.OPEN_FLAG
            , ORDERED_QUANTITY                = DECODE(I.LINE_CATEGORY_CODE
                                                       ,'RETURN', -1 * I.ORDERED_QUANTITY
                                                       ,I.ORDERED_QUANTITY)
            , ORDER_QUANTITY_UOM              = I.ORDER_QUANTITY_UOM
            , ORG_ID                          = I.ORG_ID
            , PAYMENT_TERM_ID                 = I.PAYMENT_TERM_ID
            , PRICE_LIST_ID                   = I.PRICE_LIST_ID
            , PRICING_DATE                    = I.PRICING_DATE
            , PRICING_QUANTITY                = I.PRICING_QUANTITY
            , PRICING_QUANTITY_UOM            = I.PRICING_QUANTITY_UOM
            , REQUEST_DATE                    = I.REQUEST_DATE
            , RETURN_REASON_CODE              = I.RETURN_REASON_CODE
            , SALESREP_ID                     = I.SALESREP_ID
            , UNIT_LIST_PRICE                 = I.UNIT_LIST_PRICE
            , UNIT_LIST_PRICE_PER_PQTY        = I.UNIT_LIST_PRICE_PER_PQTY
            , UNIT_SELLING_PERCENT            = I.UNIT_SELLING_PERCENT
            , UNIT_SELLING_PRICE              = I.UNIT_SELLING_PRICE
            , UNIT_SELLING_PRICE_PER_PQTY     = I.UNIT_SELLING_PRICE_PER_PQTY
            , ACTUAL_FULFILLMENT_DATE         = I.ACTUAL_FULFILLMENT_DATE
            , BLANKET_LINE_NUMBER             = I.BLANKET_LINE_NUMBER
            , BLANKET_NUMBER                  = I.BLANKET_NUMBER
            , BLANKET_VERSION_NUMBER          = I.BLANKET_VERSION_NUMBER
            , BOOKED_FLAG                     = I.BOOKED_FLAG
            , CALCULATE_PRICE_FLAG            = I.CALCULATE_PRICE_FLAG
            , CANCELLED_FLAG                  = I.CANCELLED_FLAG
            , CANCELLED_QUANTITY              = I.CANCELLED_QUANTITY
            , CREATED_BY                      = I.CREATED_BY
            , CREATION_DATE                   = I.CREATION_DATE
            , CUSTOMER_PAYMENT_TERM_ID        = I.CUSTOMER_PAYMENT_TERM_ID
            , FLOW_STATUS_CODE                = I.FLOW_STATUS_CODE
            , FULFILLED_FLAG                  = I.FULFILLED_FLAG
            , FULFILLED_QUANTITY              = I.FULFILLED_QUANTITY
            , FULFILLMENT_DATE                = I.FULFILLMENT_DATE
            , HEADER_ID                       = I.HEADER_ID
            , INVENTORY_ITEM_ID               = I.INVENTORY_ITEM_ID
            , INVOICED_QUANTITY               = I.INVOICED_QUANTITY
            , INVOICE_INTERFACE_STATUS_CODE   = I.INVOICE_INTERFACE_STATUS_CODE
            , INVOICE_TO_CONTACT_ID           = I.INVOICE_TO_CONTACT_ID
            , INVOICE_TO_ORG_ID               = I.INVOICE_TO_ORG_ID
            , ATTRIBUTE2                      = I.ATTRIBUTE2
            , ATTRIBUTE3                      = I.ATTRIBUTE3
            , ATTRIBUTE4                      = I.ATTRIBUTE4
            , attribute5                      = I.attribute5
            , attribute6                      = I.attribute6
            , attribute7                      = I.attribute7
            , TAX_CODE                        = I.TAX_CODE
            , LAST_UPDATED_BY                 = I.LAST_UPDATED_BY
            , LAST_UPDATE_DATE                = I.LAST_UPDATE_DATE
       WHERE LINE_ID = I.LINE_ID;

      IF SQL%NOTFOUND
      THEN

        INSERT INTO XXBI_VA_ORDER_LINES_ALL
             (  LINE_ID
             ,  LINE_NUMBER
             ,  LINE_TYPE_ID
             ,  OPEN_FLAG
             ,  ORDERED_QUANTITY
             ,  ORDER_QUANTITY_UOM
             ,  ORG_ID
             ,  PAYMENT_TERM_ID
             ,  PRICE_LIST_ID
             ,  PRICING_DATE
             ,  PRICING_QUANTITY
             ,  PRICING_QUANTITY_UOM
             ,  REQUEST_DATE
             ,  RETURN_REASON_CODE
             ,  SALESREP_ID
             ,  UNIT_LIST_PRICE
             ,  UNIT_LIST_PRICE_PER_PQTY
             ,  UNIT_SELLING_PERCENT
             ,  UNIT_SELLING_PRICE
             ,  UNIT_SELLING_PRICE_PER_PQTY
             ,  ACTUAL_FULFILLMENT_DATE
             ,  BLANKET_LINE_NUMBER
             ,  BLANKET_NUMBER
             ,  BLANKET_VERSION_NUMBER
             ,  BOOKED_FLAG
             ,  CALCULATE_PRICE_FLAG
             ,  CANCELLED_FLAG
             ,  CANCELLED_QUANTITY
             ,  CREATED_BY
             ,  CREATION_DATE
             ,  CUSTOMER_PAYMENT_TERM_ID
             ,  FLOW_STATUS_CODE
             ,  FULFILLED_FLAG
             ,  FULFILLED_QUANTITY
             ,  FULFILLMENT_DATE
             ,  HEADER_ID
             ,  INVENTORY_ITEM_ID
             ,  INVOICED_QUANTITY
             ,  INVOICE_INTERFACE_STATUS_CODE
             ,  INVOICE_TO_CONTACT_ID
             ,  INVOICE_TO_ORG_ID
             ,  ATTRIBUTE2
             ,  ATTRIBUTE3
             ,  ATTRIBUTE4
             ,  ATTRIBUTE5
             ,  ATTRIBUTE6
             ,  ATTRIBUTE7
             ,  TAX_CODE
             ,  LAST_UPDATED_BY
             ,  LAST_UPDATE_DATE
             )
           VALUES
             (  I.LINE_ID
             ,  I.LINE_NUMBER
             ,  I.LINE_TYPE_ID
             ,  I.OPEN_FLAG
             ,  DECODE(I.LINE_CATEGORY_CODE
                      ,'RETURN', -1 * I.ORDERED_QUANTITY
                      ,I.ORDERED_QUANTITY)
             ,  I.ORDER_QUANTITY_UOM
             ,  I.ORG_ID
             ,  I.PAYMENT_TERM_ID
             ,  I.PRICE_LIST_ID
             ,  I.PRICING_DATE
             ,  I.PRICING_QUANTITY
             ,  I.PRICING_QUANTITY_UOM
             ,  I.REQUEST_DATE
             ,  I.RETURN_REASON_CODE
             ,  I.SALESREP_ID
             ,  I.UNIT_LIST_PRICE
             ,  I.UNIT_LIST_PRICE_PER_PQTY
             ,  I.UNIT_SELLING_PERCENT
             ,  I.UNIT_SELLING_PRICE
             ,  I.UNIT_SELLING_PRICE_PER_PQTY
             ,  I.ACTUAL_FULFILLMENT_DATE
             ,  I.BLANKET_LINE_NUMBER
             ,  I.BLANKET_NUMBER
             ,  I.BLANKET_VERSION_NUMBER
             ,  I.BOOKED_FLAG
             ,  I.CALCULATE_PRICE_FLAG
             ,  I.CANCELLED_FLAG
             ,  I.CANCELLED_QUANTITY
             ,  I.CREATED_BY
             ,  I.CREATION_DATE
             ,  I.CUSTOMER_PAYMENT_TERM_ID
             ,  I.FLOW_STATUS_CODE
             ,  I.FULFILLED_FLAG
             ,  I.FULFILLED_QUANTITY
             ,  I.FULFILLMENT_DATE
             ,  I.HEADER_ID
             ,  I.INVENTORY_ITEM_ID
             ,  I.INVOICED_QUANTITY
             ,  I.INVOICE_INTERFACE_STATUS_CODE
             ,  I.INVOICE_TO_CONTACT_ID
             ,  I.INVOICE_TO_ORG_ID
             ,  I.ATTRIBUTE2
             ,  I.ATTRIBUTE3
             ,  I.ATTRIBUTE4
             ,  I.ATTRIBUTE5
             ,  I.ATTRIBUTE6
             ,  I.ATTRIBUTE7
             ,  I.TAX_CODE
             ,  I.LAST_UPDATED_BY
             ,  I.LAST_UPDATE_DATE
             );

        l_count_insert := l_count_insert + 1;

      ELSE

        l_count_update := l_count_update + 1;

      END IF;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_ORDER_LINES_ALL', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_GL_PERIODS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_GL_PERIODS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_GL_PERIODS';

    FOR I IN ( SELECT gp.period_set_name
                    , gp.start_date
                    , gp.end_date
                    , gp.user_period_type
                    , gp.period_year
                    , gp.period_num
                    , SUBSTR(gp.period_name,1,7) period_name
                    , gp.description
                    , hoi.organization_id
                    , hoi.org_information17
                    , NULL                       org_information18
                 FROM GL_PERIODS_V                gp
                    , HR_ORGANIZATION_INFORMATION hoi
                WHERE gp.period_set_name = hoi.ORG_INFORMATION16
                  AND gp.period_type = hoi.ORG_INFORMATION17
                  AND hoi.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
                  AND gp.ADJUSTMENT_PERIOD_FLAG != 'Y'
               UNION ALL
               SELECT gp.period_set_name
                    , gp.start_date
                    , gp.end_date
                    , gp.user_period_type
                    , gp.period_year
                    , gp.period_num
                    , SUBSTR(gp.period_name,1,7) period_name
                    , gp.description
                    , hoi.organization_id
                    , NULL                       org_information17
                    , hoi.ORG_INFORMATION18
                 FROM GL_PERIODS_V                gp
                    , HR_ORGANIZATION_INFORMATION hoi
                WHERE gp.period_set_name = hoi.ORG_INFORMATION16
                  AND gp.period_type = hoi.ORG_INFORMATION18
                  AND hoi.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
                  AND gp.ADJUSTMENT_PERIOD_FLAG != 'Y'
             )
    LOOP

      l_start_date := I.start_date;

      WHILE TRUE
      LOOP

        IF l_start_date > I.end_date
        THEN
          EXIT;
        END IF;

        IF I.ORG_INFORMATION17 IS NOT NULL
        THEN

          INSERT INTO XXBI_GL_PERIODS
              (
                PERIOD_SET_NAME
               , JULIAN_DAY
               , FULL_DATE
               , DAY_NUM_OF_PERIOD
               , DAY_NUM_OF_YEAR
               , NUM_OF_PERIOD
               , NUM_OF_MONTH
               , NUM_OF_YEAR
               , JULIAN_DAY_NUM_OF_YEAR
               , JULIAN_PERIOD_NUM_OF_YEAR
               , START_OF_PERIOD
               , END_OF_PERIOD
               , START_OF_YEAR
               , END_OF_YEAR
               , PERIOD_NAME
               , ORG_ID
               , USED_BY
              )
            VALUES
              ( I.period_set_name
              , TO_CHAR(l_start_date,'J')
              , l_start_date
              , (l_start_date - I.start_date) + 1
              , TO_NUMBER(TO_CHAR(l_start_date,'DDD'))
              , I.period_num
              , TO_NUMBER(TO_CHAR(l_start_date,'MM'))
              , I.period_year
              , TO_NUMBER (TO_CHAR(I.period_year) || TO_CHAR(TO_CHAR(l_start_date,'DDD'),'FM099'))
              , TO_NUMBER (TO_CHAR(I.period_year) || TO_CHAR(I.period_num,'FM09'))
              , I.start_date
              , I.end_date
              , ( select min(start_date)
                    from gl_periods_v
                   where period_set_name  = I.period_set_name
                     and user_period_type = I.user_period_type
                     and period_year      = I.period_year )
              , ( select max(end_date)
                    from gl_periods_v
                   where period_set_name  = I.period_set_name
                     and user_period_type = I.user_period_type
                     and period_year      = I.period_year )
              , I.period_name
              , I.organization_id
              ,'EBS'
              );
        END IF;

        IF I.ORG_INFORMATION18 IS NOT NULL
        THEN

          INSERT INTO XXBI_GL_PERIODS
              (
                PERIOD_SET_NAME
               , JULIAN_DAY
               , FULL_DATE
               , DAY_NUM_OF_PERIOD
               , DAY_NUM_OF_YEAR
               , NUM_OF_PERIOD
               , NUM_OF_MONTH
               , NUM_OF_YEAR
               , JULIAN_DAY_NUM_OF_YEAR
               , JULIAN_PERIOD_NUM_OF_YEAR
               , START_OF_PERIOD
               , END_OF_PERIOD
               , START_OF_YEAR
               , END_OF_YEAR
               , PERIOD_NAME
               , ORG_ID
               , USED_BY
              )
            VALUES
              ( I.period_set_name
              , TO_CHAR(l_start_date,'J')
              , l_start_date
              , (l_start_date - I.start_date) + 1
              , TO_NUMBER(TO_CHAR(l_start_date,'DDD'))
              , I.period_num
              , TO_NUMBER(TO_CHAR(l_start_date,'MM'))
              , I.period_year
              , TO_NUMBER (TO_CHAR(I.period_year) || TO_CHAR(TO_CHAR(l_start_date,'DDD'),'FM099'))
              , TO_NUMBER (TO_CHAR(I.period_year) || TO_CHAR(I.period_num,'FM09'))
              , I.start_date
              , I.end_date
              , ( select min(start_date)
                    from gl_periods_v
                   where period_set_name  = I.period_set_name
                     and user_period_type = I.user_period_type
                     and period_year      = I.period_year )
              , ( select max(end_date)
                    from gl_periods_v
                   where period_set_name  = I.period_set_name
                     and user_period_type = I.user_period_type
                     and period_year      = I.period_year )
              , I.period_name
              , I.organization_id
              ,'ACP'
              );
        END IF;

        l_start_date := l_start_date + 1 ;

      END LOOP;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_GL_PERIODS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_CUSTOMERS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_CUSTOMERS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_CUSTOMERS';

    FOR I IN ( SELECT hp.PARTY_ID
                    , hp.PARTY_NAME
                    , hp.PARTY_NUMBER
                    , hca.CUST_ACCOUNT_ID
                 FROM hz_parties hp
                    , hz_cust_accounts  hca
                WHERE hca.PARTY_ID = hp.PARTY_ID
             )
    LOOP

      INSERT INTO XXBI_CUSTOMERS
              ( PARTY_ID
              , PARTY_NAME
              , PARTY_NUMBER
              , CUST_ACCOUNT_ID
              )
        VALUES
              ( I.PARTY_ID
              , I.PARTY_NAME
              , I.PARTY_NUMBER
              , I.CUST_ACCOUNT_ID
              );

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_CUSTOMERS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_ITEMS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_ITEMS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_ITEMS';

    FOR I IN (
               SELECT xx.org_id
                    , xx.inventory_item_id
                    , xx.segment1
                    , xx.description
                    , NVL(xx.beneficiary,'????')                                                             beneficiary
                    , NVL(xx.vendor_allowance_type,'????')                                                   vendor_allowance_type
                    , NVL(mcr.CROSS_REFERENCE_TYPE,DECODE(mcr.cross_reference_id,NULL,'????'))               cross_reference_type
                    , NVL(mcrt.ATTRIBUTE1,DECODE(mcr.cross_reference_id,NULL,'????'))                        business_unit
                    , NVL(DECODE(mcr.ATTRIBUTE_CATEGORY,'Vendor Allowance',  mcr.ATTRIBUTE1)
                         ,DECODE(mcr.cross_reference_id,NULL, '????'))                                       general_accrual_account
                    , NVL(DECODE(mcr.ATTRIBUTE_CATEGORY,'Vendor Allowance',  mcr.ATTRIBUTE2)
                         ,DECODE(mcr.cross_reference_id,NULL, '????'))                                       beneficiary_accrual_account
                    , NVL(DECODE(mcr.ATTRIBUTE_CATEGORY,'Vendor Allowance',  mcr.ATTRIBUTE3)
                         ,DECODE(mcr.cross_reference_id,NULL, '????'))                                       revenue_invoice_account
                    , NVL(DECODE(mcr.ATTRIBUTE_CATEGORY,'Vendor Allowance',  mcr.ATTRIBUTE4)
                         ,DECODE(mcr.cross_reference_id,NULL, '????'))                                       receivables_invoice_account
                 FROM
                     (
                       SELECT hoi.ORG_INFORMATION19
                            ,hoi.ORGANIZATION_ID   org_id
                            , msi.inventory_item_id
                            , msi.segment1
                            , msi.description
                            , NVL(mc.segment1,'????')            beneficiary
                            , NVL(mc2.segment1,'????')           vendor_allowance_type
                         FROM mtl_system_items    msi
                            , mtl_parameters      mp
                            , mtl_categories      mc
                            , mtl_item_categories mic
                            , mtl_category_sets   mcs
                            , mtl_categories      mc2
                            , mtl_item_categories mic2
                            , mtl_category_sets   mcs2
                            , HR_ORGANIZATION_INFORMATION hoi
                        WHERE mp.MASTER_ORGANIZATION_ID   = mp.ORGANIZATION_ID
                          and mp.ORGANIZATION_ID          = msi.ORGANIZATION_ID
                          AND mcs.CATEGORY_SET_NAME       = 'BENEFICIARY'
                          AND mcs.CATEGORY_SET_ID (+)         = mic.CATEGORY_SET_ID
                          AND mic.INVENTORY_ITEM_ID (+)       = msi.INVENTORY_ITEM_ID
                          AND mc.CATEGORY_ID (+)            = mic.CATEGORY_ID
                          AND mcs2.CATEGORY_SET_NAME      = 'VENDOR_ALLOWANCE_TYPE'
                          AND mcs2.CATEGORY_SET_ID (+)       = mic2.CATEGORY_SET_ID
                          AND mic2.INVENTORY_ITEM_ID (+)    = msi.INVENTORY_ITEM_ID
                          AND mc2.CATEGORY_ID (+)            = mic2.CATEGORY_ID
                          AND hoi.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
                          AND hoi.ORG_INFORMATION19 IS NOT NULL
                     ) xx
                     , mtl_cross_references        mcr
                     , mtl_cross_reference_types   mcrt
                 WHERE mcr.CROSS_REFERENCE_TYPE  (+)  = xx.ORG_INFORMATION19
                   AND mcrt.CROSS_REFERENCE_TYPE (+)  = mcr.CROSS_REFERENCE_TYPE
                   AND mcr.INVENTORY_ITEM_ID (+)      = xx.INVENTORY_ITEM_ID
                   AND exists (
                                SELECT 'Y'
                                  FROM XXBI_VA_BLANKET_LINES_ALL bl
                                 where bl.inventory_item_id = xx.inventory_item_id
                                 union
                                 SELECT 'Y'
                                  FROM XXBI_VA_ORDER_LINES_ALL ol
                                 where ol.inventory_item_id = xx.inventory_item_id
                              )
             )
    LOOP

      INSERT INTO XXBI_ITEMS
              (
                ORG_ID
              , INVENTORY_ITEM_ID
              , ITEM_NUMBER
              , ITEM_DESCRIPTION
              , BENEFICIARY
              , VENDOR_ALLOWANCE_TYPE
              , CROSS_REFERENCE_TYPE
              , BUSINESS_UNIT
              , GENERAL_ACCRUAL_ACCOUNT
              , BENEFICIARY_ACCRUAL_ACCOUNT
              , REVENUE_INVOICE_ACCOUNT
              , RECEIVABLES_INVOICE_ACCOUNT
              )
        VALUES
              ( I.org_id
              , I.inventory_item_id
              , I.segment1
              , I.description
              , I.beneficiary
              , I.vendor_allowance_type
              , I.CROSS_REFERENCE_TYPE
              , I.business_unit
              , I.general_accrual_account
              , I.beneficiary_accrual_account
              , I.revenue_invoice_account
              , I.receivables_invoice_account
              );

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_ITEMS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_ORG_HIERARCHY');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_ORG_HIERARCHY';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_ORG_HIERARCHY';

    FOR I IN (
               SELECT level  tree
                    , DECODE ( level
                             , 1 , 'Center of Excellence'
                             , 2 , 'Unit'
                             , 3 , 'Team'
                             , 4 , 'European Sourcing Manger'
                             , 5 , 'Onbekend') label
                    , haou_child.NAME d_child_name
                    , haou_parent.NAME d_parent_name
                    , pos.name org_hierarchy_name
                    , haou.NAME org_parent_name
                 FROM per_org_structure_elements  pose
                    , per_org_structure_versions  posv
                    , hr_all_organization_units   haou
                    , hr_all_organization_units   haou_child
                    , hr_all_organization_units   haou_parent
                    , per_organization_structures pos
                WHERE 1 = 1
                  AND pose.org_structure_version_id = posv.org_structure_version_id
                  AND haou.organization_id = pos.business_group_id
                  AND haou_child.organization_id = pose.organization_id_child
                  AND haou_parent.organization_id = pose.organization_id_parent
                  AND pos.organization_structure_id = posv.organization_structure_id
                  AND pos.NAME = 'Ahold European Sourcing'
                   START WITH (pose.organization_id_parent, pose.org_structure_version_id) =
                                 (SELECT pos2.business_group_id,
                                         posv2.org_structure_version_id
                                    FROM per_organization_structures pos2,
                                         per_org_structure_versions posv2
                                   WHERE pos2.NAME = 'Ahold European Sourcing'
                                     AND pos2.organization_structure_id =
                                                               posv2.organization_structure_id)
                   CONNECT BY PRIOR pose.organization_id_child = pose.organization_id_parent
                 order by 1 desc
             )
    LOOP

      IF I.tree = 3
      THEN

        INSERT INTO XXBI_ORG_HIERARCHY
                (
                  ORG_HIERARCHY_NAME
                , ORG_PARENT_NAME
                , CENTER_OF_EXCELLENCE
                , UNIT
                , TEAM
                )
          VALUES
                ( I.org_hierarchy_name
                , I.org_parent_name
                , '?'
                , I.D_PARENT_NAME
                , I.D_CHILD_NAME
                );
      END IF;

      IF I.tree = 2
      THEN

        UPDATE XXBI_ORG_HIERARCHY
           SET CENTER_OF_EXCELLENCE = I.D_PARENT_NAME
         WHERE UNIT = I.D_CHILD_NAME;
        IF SQL%ROWCOUNT = 0
        THEN
          INSERT INTO XXBI_ORG_HIERARCHY
                (
                  ORG_HIERARCHY_NAME
                , ORG_PARENT_NAME
                , CENTER_OF_EXCELLENCE
                , UNIT
                , TEAM
                )
            VALUES
                  ( I.org_hierarchy_name
                  , I.org_parent_name
                  , I.D_PARENT_NAME
                  , I.D_CHILD_NAME
                  , I.D_CHILD_NAME    -- '-' 25 Nov to avoid duplicate team names
                  );
         END IF;

      END IF;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_ORG_HIERARCHY', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SALESREPS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_SALESREPS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SALESREPS';

    FOR I IN (
               SELECT per.last_name
                    , per.FIRST_NAME
                    , per.FULL_NAME
                    , per.PERSON_ID
-- SVE 20120626                    , rs.SALESREP_ID
                    , rs.SALESREP_ID * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD')) SALESREP_ID                 , haou.name        organization_name
                    , haou.ATTRIBUTE1  costcenter_psft
                 FROM per_all_people_f per
                    , per_all_assignments_f         paf
                    , jtf_rs_salesreps              rs
                    , hr_all_organization_units     haou
                WHERE paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
-- SVE 20120626                   AND paf.effective_end_date = (SELECT Max(effective_end_date)
-- SVE 20120626                                                 FROM per_all_assignments_f paf2
-- SVE 20120626                                                 WHERE paf2.person_id = per.person_id)
--                  AND SYSDATE BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,sysdate+1)
                  AND rs.PERSON_ID = per.PERSON_ID
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
-- BEGIN organization_name should be a team 25 Nov SVE
                  AND EXISTS (select 'Y'
                                from XXBI_ORG_HIERARCHY
                               where team = haou.name)
-- END  organization_name should be a team 25 Nov SVE
              )
    LOOP

      INSERT INTO XXBI_SALESREPS
                (
                  LAST_NAME
                , FIRST_NAME
                , FULL_NAME
                , PERSON_ID
                , SALESREP_ID
                , ORGANIZATION
                , COSTCENTER_PSFT
                )
          VALUES
                ( I.last_name
                , I.FIRST_NAME
                , I.FULL_NAME
                , I.PERSON_ID
                , I.SALESREP_ID
                , I.organization_name
                , I.costcenter_psft
                );

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SALESREPS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_CONTRACT_TERMS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_CONTRACT_TERMS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_CONTRACT_TERMS';

    FOR I IN (
               SELECT oaa.article_title             clause_title
                    , os.heading                    section
                    , oav.display_name
                    , flv.DESCRIPTION               type
                    , oav.article_description       description
                    , oka.MANDATORY_YN
                    , oaa.standard_yn
                    , oaa.article_intent
                    , oka.document_id
                    , ota.document_number
                    , ott.template_name
                    , ott.template_id
                 FROM okc_articles_all         oaa
                    , okc_article_versions     oav
                    , okc_k_articles_b         oka
                    , okc_template_usages      ota
                    , okc_sections_b           os
                    , fnd_lookup_values        flv
                    , okc_terms_templates_all  ott
                WHERE oaa.standard_yn    = 'N'
                  AND oaa.article_intent = 'S'
                  AND oaa.ARTICLE_ID = oav.ARTICLE_ID
                  AND oka.ARTICLE_VERSION_ID = oav.ARTICLE_VERSION_ID
                  AND oka.DOCUMENT_ID = ota.DOCUMENT_ID
                  AND oka.DOCUMENT_TYPE = ota.DOCUMENT_TYPE
                  AND os.DOCUMENT_ID  = ota.DOCUMENT_ID
                  AND os.DOCUMENT_TYPE  = ota.DOCUMENT_TYPE
                  AND flv.LOOKUP_TYPE = 'OKC_SUBJECT'
                  AND flv.LOOKUP_CODE = oaa.ARTICLE_TYPE
                  AND ott.TEMPLATE_ID = ota.TEMPLATE_ID
             )
    LOOP

      INSERT INTO XXBI_CONTRACT_TERMS
                (
                  CLAUSE_TITLE
                , SECTION
                , DISPLAY_NAME
                , TYPE
                , DESCRIPTION
                , MANDATORY_YN
                , STANDARD_YN
                , ARTICLE_INTENT
                , DOCUMENT_ID
                , DOCUMENT_NUMBER
                , TEMPLATE_NAME
                , TEMPLATE_ID
                )
          VALUES
                ( I.clause_title
                , I.section
                , I.display_name
                , I.type
                , I.description
                , I.MANDATORY_YN
                , I.standard_yn
                , I.article_intent
                , I.document_id
                , I.document_number
                , I.template_name
                , I.template_id
                );

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_CONTRACT_TERMS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_OPERATING_UNITS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');


    l_statement    := 'Maintain XXBI_OPERATING_UNITS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_OPERATING_UNITS';

    FOR I IN (
               SELECT haou.organization_id
                    , haou.name
                 FROM hr_all_organization_units_tl  haou
                WHERE haou.LANGUAGE = USERENV('lang')
             )
    LOOP

      INSERT INTO XXBI_OPERATING_UNITS
                (
                  ORGANIZATION_ID
                , NAME
                )
          VALUES
                ( I.organization_id
                , I.name
                );

    END LOOP;


    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_OPERATING_UNITS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_CATEGORIES');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_statement    := 'Maintain XXBI_CATEGORIES';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_CATEGORIES';

    FOR I IN (
               SELECT category_id
                    , structure_id
                    , segment1                category
                    , segment2                subcategory
                    , concatenated_segments
                 FROM MTL_CATEGORIES_B_KFV
                WHERE structure_id = (select meaning from FND_LOOKUP_VALUES
where lookup_type='XXAH_STRUCTURE_ID')
             )
    LOOP

      INSERT INTO XXBI_CATEGORIES
                (
                  CATEGORY_ID
                , STRUCTURE_ID
                , CATEGORY
                , SUBCATEGORY
                , CONCATENATED_SEGMENTS
                )
          VALUES
                ( I.category_id
                , I.structure_id
                , I.category
                , I.subcategory
                , I.concatenated_segments
                );

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_CATEGORIES', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain PeoplSoft Data');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    FOR I IN (
               SELECT LINE_ID
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'ACCRUAL', TO_NUMBER(FOREIGN_AMOUNT_LEN,'FM999999999.99'))
                         ) PSFT_ACCRUAL_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'ACCRUAL', TO_DATE(JOURNAL_DATE_LEN,'YYYY-MM-DD'))
                         ) PSFT_ACCRUAL_DATE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'ACCRUAL', ACCOUNT_LEN)
                         ) PSFT_ACCRUAL_ACCOUNT
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'INVOICE', JRNL_LN_REF_LEN)
                         ) PSFT_INVOICE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'INVOICE', ACCOUNT_LEN)
                         ) PSFT_INVOICE_ACCOUNT
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'INVOICE', TO_DATE(JOURNAL_DATE_LEN,'YYYY-MM-DD'))
                         ) PSFT_INVOICE_DATE
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'INVOICE', TO_NUMBER(FOREIGN_AMOUNT_LEN,'FM999999999.99'))
                         ) PSFT_INVOICE_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAY-OUT', PRODUCT_LEN)
                         ) PSFT_PAY_OUT_OPCO
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAY-OUT', ACCOUNT_LEN)
                         ) PSFT_PAY_OUT_ACCOUNT
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAY-OUT', TO_DATE(JOURNAL_DATE_LEN,'YYYY-MM-DD'))
                         ) PSFT_PAY_OUT_DATE
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'PAY-OUT', TO_NUMBER(FOREIGN_AMOUNT_LEN,'FM999999999.99'))
                         ) PSFT_PAY_OUT_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAYMENT', PRODUCT_LEN)
                         ) PSFT_PAYMENT_CMPY
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAYMENT', ACCOUNT_LEN)
                         ) PSFT_PAYMENT_ACCOUNT
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAYMENT', TO_DATE(JOURNAL_DATE_LEN,'YYYY-MM-DD'))
                         ) PSFT_PAYMENT_DATE
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'PAYMENT', TO_NUMBER(FOREIGN_AMOUNT_LEN,'FM999999999.99'))
                         ) PSFT_PAYMENT_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'WRITEOF', PRODUCT_LEN)
                         ) PSFT_WRITEOF
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'WRITEOF', ACCOUNT_LEN)
                         ) PSFT_WRITEOF_ACCOUNT
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'WRITEOF', TO_DATE(JOURNAL_DATE_LEN,'YYYY-MM-DD'))
                         ) PSFT_WRITEOF_DATE
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'WRITEOF', TO_NUMBER(FOREIGN_AMOUNT_LEN,'FM999999999.99'))
                         ) PSFT_WRITEOF_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'ACCRUAL', CHART3)
                         ) PSFT_ACCRUAL_REV_ACCOUNT
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'ACCRUAL', TO_NUMBER(PROJECT_ID_LEN,'FM999999999.99'))
                         ) PSFT_ACCRUAL_REV_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'INVOICE', CHART3)
                         ) PSFT_INVOICE_REV_ACCOUNT
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'INVOICE', TO_NUMBER(PROJECT_ID_LEN,'FM999999999.99'))
                         ) PSFT_INVOICE_REV_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAY-OUT', CHART3)
                         ) PSFT_PAY_OUT_REV_ACCOUNT
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'PAY-OUT', TO_NUMBER(PROJECT_ID_LEN,'FM999999999.99'))
                         ) PSFT_PAY_OUT_REV_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'PAYMENT', CHART3)
                         ) PSFT_PAYMENT_REV_ACCOUNT
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'PAYMENT', TO_NUMBER(PROJECT_ID_LEN,'FM999999999.99'))
                         ) PSFT_PAYMENT_REV_VALUE
                    , MAX(DECODE(ACTIVITY_LEN
                                ,'WRITEOF', CHART3)
                         ) PSFT_WRITEOF_REV_ACCOUNT
                    , SUM(DECODE(ACTIVITY_LEN
                                ,'WRITEOF', TO_NUMBER(PROJECT_ID_LEN,'FM999999999.99'))
                         ) PSFT_WRITEOF_REV_VALUE
                 FROM XXBI_PSFT_DATA
                GROUP BY LINE_ID
             )
    LOOP

      UPDATE XXBI_VA_ORDER_LINES_ALL
         SET PSFT_ACCRUAL_VALUE        = NVL(PSFT_ACCRUAL_VALUE,0) + I.PSFT_ACCRUAL_VALUE
           , PSFT_ACCRUAL_DATE         = I.PSFT_ACCRUAL_DATE
           , PSFT_ACCRUAL_ACCOUNT      = I.PSFT_ACCRUAL_ACCOUNT
           , PSFT_INVOICE              = I.PSFT_INVOICE
           , PSFT_INVOICE_DATE         = I.PSFT_INVOICE_DATE
           , PSFT_INVOICE_VALUE        = NVL(PSFT_INVOICE_VALUE,0) + I.PSFT_INVOICE_VALUE
           , PSFT_INVOICE_ACCOUNT      = I.PSFT_INVOICE_ACCOUNT
           , PSFT_PAY_OUT_OPCO         = I.PSFT_PAY_OUT_OPCO
           , PSFT_PAY_OUT_DATE         = I.PSFT_PAY_OUT_DATE
           , PSFT_PAY_OUT_VALUE        = NVL(PSFT_PAY_OUT_VALUE,0) + I.PSFT_PAY_OUT_VALUE
           , PSFT_PAY_OUT_ACCOUNT      = I.PSFT_PAY_OUT_ACCOUNT
           , PSFT_PAYMENT_CMPY         = I.PSFT_PAYMENT_CMPY
           , PSFT_PAYMENT_DATE         = I.PSFT_PAYMENT_DATE
           , PSFT_PAYMENT_VALUE        = NVL(PSFT_PAYMENT_VALUE,0) + I.PSFT_PAYMENT_VALUE
           , PSFT_PAYMENT_ACCOUNT      = I.PSFT_PAYMENT_ACCOUNT
           , PSFT_WRITEOF              = I.PSFT_WRITEOF
           , PSFT_WRITEOF_DATE         = I.PSFT_WRITEOF_DATE
           , PSFT_WRITEOF_VALUE        = NVL(PSFT_WRITEOF_VALUE,0) + I.PSFT_WRITEOF_VALUE
           , PSFT_WRITEOF_ACCOUNT      = I.PSFT_WRITEOF_ACCOUNT
           , PSFT_ACCRUAL_REV_ACCOUNT  = I.PSFT_ACCRUAL_REV_ACCOUNT
           , PSFT_INVOICE_REV_ACCOUNT  = I.PSFT_INVOICE_REV_ACCOUNT
           , PSFT_PAY_OUT_REV_ACCOUNT  = I.PSFT_PAY_OUT_REV_ACCOUNT
           , PSFT_PAYMENT_REV_ACCOUNT  = I.PSFT_PAYMENT_REV_ACCOUNT
           , PSFT_WRITEOF_REV_ACCOUNT  = I.PSFT_WRITEOF_REV_ACCOUNT
           , PSFT_ACCRUAL_REV_VALUE    = NVL(PSFT_ACCRUAL_REV_VALUE,0) + I.PSFT_ACCRUAL_REV_VALUE
           , PSFT_INVOICE_REV_VALUE    = NVL(PSFT_INVOICE_REV_VALUE,0) + I.PSFT_INVOICE_REV_VALUE
           , PSFT_PAY_OUT_REV_VALUE    = NVL(PSFT_PAY_OUT_REV_VALUE,0) + I.PSFT_PAY_OUT_REV_VALUE
           , PSFT_PAYMENT_REV_VALUE    = NVL(PSFT_PAYMENT_REV_VALUE,0) + I.PSFT_PAYMENT_REV_VALUE
           , PSFT_WRITEOF_REV_VALUE    = NVL(PSFT_WRITEOF_REV_VALUE,0) + I.PSFT_WRITEOF_REV_VALUE
       WHERE LINE_ID = I.LINE_ID;

    END LOOP;

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain Department Hierarchy Data');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_DEPT_HIERARCHY';

    FOR I IN (
               SELECT xoh.center_of_excellence
                    , xoh.unit
                    , xoh.team
                    , xs.FIRST_NAME
                    , xs.FULL_NAME
                    , xs.LAST_NAME
                    , xs.SALESREP_ID
                 FROM xxbi_org_hierarchy  xoh
                    , xxbi_salesreps      xs
               WHERE xoh.center_of_excellence = xs.organization
               UNION
               SELECT xoh.center_of_excellence
                    , xoh.unit
                    , xoh.team
                    , xs.FIRST_NAME
                    , xs.FULL_NAME
                    , xs.LAST_NAME
                    , xs.SALESREP_ID
                 FROM xxbi_org_hierarchy  xoh
                    , xxbi_salesreps      xs
               WHERE (xoh.center_of_excellence = xs.organization or xoh.unit = xs.organization)
               UNION
               SELECT xoh.center_of_excellence
                    , xoh.unit
                    , xoh.team
                    , xs.FIRST_NAME
                    , xs.FULL_NAME
                    , xs.LAST_NAME
                    , xs.SALESREP_ID
                 FROM xxbi_org_hierarchy  xoh
                    , xxbi_salesreps      xs
                WHERE (xoh.center_of_excellence = xs.organization or xoh.unit = xs.organization or xoh.team = xs.organization)
             )
    LOOP

      INSERT INTO XXBI_DEPT_HIERARCHY
                (
                  CENTER_OF_EXCELLENCE
                , UNIT
                , TEAM
                , FIRST_NAME
                , FULL_NAME
                , LAST_NAME
                , SALESREP_ID
                )
          VALUES
                ( I.center_of_excellence
                , I.unit
                , I.team
                , I.FIRST_NAME
                , I.FULL_NAME
                , I.LAST_NAME
                , I.SALESREP_ID
                );

    END LOOP;

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_BH_BL_OH_OL');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_BH_BL_OH_OL';

    INSERT INTO XXBI_VA_BH_BL_OH_OL
             (
               BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , BL_LINE_ID
             , BL_BLANKET_LINE_MIN_AMOUNT
             , BL_BLANKET_MIN_QUANTITY
             , BL_INVENTORY_ITEM_ID
             , BL_LINE_NUMBER
             , BL_END_DATE_ACTIVE
             , BL_START_DATE_ACTIVE
             , OH_HEADER_ID
             , OL_LINE_ID
             , OL_ACCRUAL_TOTAL_PRICE
             , OL_INVOICE_TOTAL_PRICE
             , BH_CATEGORY_ID
             , OH_DATE_INTF_PSFT
             , BH_FINAL_OH
             , OL_PSFT_ACCRUAL_VALUE
             , OL_PSFT_INVOICE_VALUE
             , OL_PSFT_PAY_OUT_VALUE
             , OL_PSFT_PAYMENT_VALUE
             , OL_PSFT_WRITEOF_VALUE
             , OL_PSFT_ACCRUAL_REV_VALUE
             , OL_PSFT_INVOICE_REV_VALUE
             , OL_PSFT_PAY_OUT_REV_VALUE
             , OL_PSFT_PAYMENT_REV_VALUE
             , OL_PSFT_WRITEOF_REV_VALUE
             , OL_PSFT_ACCRUAL_DATE
             , OL_PSFT_INVOICE_DATE
             , OL_PSFT_PAY_OUT_DATE
             , OL_PSFT_PAYMENT_DATE
             , OL_PSFT_WRITEOF_DATE
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , OVERDUE_LT_60
             , OVERDUE_60_100
             , OVERDUE_GT_100
             , OVERDUE_DAYS
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT
             , KEY_BH_BL_OH_OL
             )
        SELECT bh.header_id                                                                         bh_header_id
             , bh.salesrep_id                                                                       bh_salesrep_id
             , bh.sold_to_org_id                                                                    bh_sold_to_org_id
             , bh.start_date_active                                                                 bh_start_date_active
             , bh.end_date_active                                                                   bh_end_date_active
             , NVL(bh.invoice_date,'01-JAN-1900')                                                   bh_invoice_date
             , bh.org_id                                                                            org_id
             , bl.line_id                                                                           bl_line_id
             , bl.blanket_line_min_amount                                                           bl_blanket_line_min_amount
             , bl.blanket_min_quantity                                                              bl_blanket_min_quantity
             , bl.inventory_item_id                                                                 bl_inventory_item_id
             , bl.line_number                                                                       bl_line_number
             , bl.end_date_active                                                                   bl_end_date_active
             , bl.start_date_active                                                                 bl_start_date_active
             , oh.header_id                                                                         oh_header_id
             , ol.line_id                                                                           ol_line_id
             , DECODE (UPPER(SUBSTR(oh.order_type,5))
                      ,'ACCRUAL', ol.unit_selling_price * ol.ordered_quantity
                      )                                                                             ol_accrual_total_price
             , DECODE (UPPER(SUBSTR(oh.order_type,5))
                      ,'INVOICE', ol.unit_selling_price * ol.ordered_quantity
                      )                                                                             ol_invoice_total_price
             , bh.attribute2                                                                        category_id
             , NVL(TRUNC(fnd_date.CANONICAL_TO_DATE (oh.ATTRIBUTE1)),'01-JAN-1900')                                    oh_date_intf_psft
             , (SELECT MAX (SUBSTR(attribute3,1,1))
                  FROM xxbi_va_order_headers_all
                 WHERE blanket_number = bh.order_number)                                            bh_final_oh
             , ol.psft_accrual_value                                                                ol_psft_accrual_value
             , ol.psft_invoice_value                                                                ol_psft_invoice_value
             , ol.psft_pay_out_value                                                                ol_psft_pay_out_value
             , ol.psft_payment_value                                                                ol_psft_payment_value
             , ol.psft_writeof_value                                                                ol_psft_writeof_value
             , ol.psft_accrual_rev_value                                                            ol_psft_accrual_rev_value
             , ol.psft_invoice_rev_value                                                            ol_psft_invoice_rev_value
             , ol.psft_pay_out_rev_value                                                            ol_psft_pay_out_rev_value
             , ol.psft_payment_rev_value                                                            ol_psft_payment_rev_value
             , ol.psft_writeof_rev_value                                                            ol_psft_writeof_rev_value
             , NVL(ol.psft_accrual_date,'01-JAN-1900')                                                                 ol_psft_accrual_date
             , NVL(ol.psft_invoice_date,'01-JAN-1900')                                                                 ol_psft_invoice_date
             , NVL(ol.psft_pay_out_date,'01-JAN-1900')                                                                 ol_psft_pay_out_date
             , NVL(ol.psft_payment_date,'01-JAN-1900')                                                                 ol_psft_payment_date
             , NVL(ol.psft_writeof_date,'01-JAN-1900')                                                                 ol_psft_writeof_date
             , 'EBS'                                                                                EBS_USED_BY
             , 'ACP'                                                                                PSFT_USED_BY
             , xxah_vpd_pkg.GET_HASH_KEY ( bh.salesrep_id
                                         , NULL
                                         , NULL
                                         , 'ALL'
                                         , bh.CREATION_DATE )                                       hash_key
             , case when trunc(sysdate) - bh.start_date_active between  0 and  59 then 'Y' end      overdue_lt_60
             , case when trunc(sysdate) - bh.start_date_active between 60 and 100 then 'Y' end      overdue_60_100
             , case when trunc(sysdate) - bh.start_date_active > 100              then 'Y' end      overdue_gt_100
             , trunc(sysdate) - bh.start_date_active                                                overdue_days
             , NVL(bh.CUSTOMER_SIGNATURE_DATE,'01-JAN-1900')
             , bh.BLANKET_MIN_AMOUNT
             , to_char(BH.HEADER_ID) ||'-' || to_char(NVL(BL.LINE_ID,0)) ||'-' || to_char(NVL(OH.HEADER_ID,0)) ||'-' || to_char(NVL(OL.LINE_ID,0))
          FROM xxbi_va_blanket_headers_all bh
             , xxbi_va_blanket_lines_all   bl
             , xxbi_va_order_headers_all   oh
             , xxbi_va_order_lines_all     ol
         WHERE bh.header_id               = bl.header_id(+)
           and ol.blanket_number (+)      = bl.order_number
           and ol.blanket_line_number (+) = bl.line_number
           AND oh.header_id (+)           = ol.header_id ;

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_BH_BL');
    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_BH_BL';

    INSERT INTO XXBI_VA_BH_BL
             (
               BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , BL_LINE_ID
             , BL_BLANKET_LINE_MIN_AMOUNT
             , BL_BLANKET_MIN_QUANTITY
             , BL_INVENTORY_ITEM_ID
             , BL_LINE_NUMBER
             , BL_END_DATE_ACTIVE
             , BL_START_DATE_ACTIVE
             , OL_ACCRUAL_TOTAL_PRICE
             , OL_INVOICE_TOTAL_PRICE
             , BH_CATEGORY_ID
             , BH_FINAL_OH
             , OL_PSFT_ACCRUAL_VALUE
             , OL_PSFT_INVOICE_VALUE
             , OL_PSFT_PAY_OUT_VALUE
             , OL_PSFT_PAYMENT_VALUE
             , OL_PSFT_WRITEOF_VALUE
             , OL_PSFT_ACCRUAL_REV_VALUE
             , OL_PSFT_INVOICE_REV_VALUE
             , OL_PSFT_PAY_OUT_REV_VALUE
             , OL_PSFT_PAYMENT_REV_VALUE
             , OL_PSFT_WRITEOF_REV_VALUE
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT
             , KEY_BH_BL_OH_OL
             )
        SELECT BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , BL_LINE_ID
             , BL_BLANKET_LINE_MIN_AMOUNT
             , BL_BLANKET_MIN_QUANTITY
             , BL_INVENTORY_ITEM_ID
             , BL_LINE_NUMBER
             , BL_END_DATE_ACTIVE
             , BL_START_DATE_ACTIVE
             , SUM(OL_ACCRUAL_TOTAL_PRICE) OL_ACCRUAL_TOTAL_PRICE
             , SUM(OL_INVOICE_TOTAL_PRICE) OL_INVOICE_TOTAL_PRICE
             , BH_CATEGORY_ID
             , BH_FINAL_OH
             , SUM(OL_PSFT_ACCRUAL_VALUE) OL_PSFT_ACCRUAL_VALUE
             , SUM(OL_PSFT_INVOICE_VALUE) OL_PSFT_INVOICE_VALUE
             , SUM(OL_PSFT_PAY_OUT_VALUE) OL_PSFT_PAY_OUT_VALUE
             , SUM(OL_PSFT_PAYMENT_VALUE) OL_PSFT_PAYMENT_VALUE
             , SUM(OL_PSFT_WRITEOF_VALUE) OL_PSFT_WRITEOF_VALUE
             , SUM(OL_PSFT_ACCRUAL_REV_VALUE) OL_PSFT_ACCRUAL_REV_VALUE
             , SUM(OL_PSFT_INVOICE_REV_VALUE) OL_PSFT_INVOICE_REV_VALUE
             , SUM(OL_PSFT_PAY_OUT_REV_VALUE) OL_PSFT_PAY_OUT_REV_VALUE
             , SUM(OL_PSFT_PAYMENT_REV_VALUE) OL_PSFT_PAYMENT_REV_VALUE
             , SUM(OL_PSFT_WRITEOF_REV_VALUE) OL_PSFT_WRITEOF_REV_VALUE
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT
             , NVL(BH_HEADER_ID,0) || '-' || NVL(BL_LINE_ID,0) || '-0-0' KEY_BH_BL_OH_OL
          from xxbi_va_bh_bl_oh_ol
      group by BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , BL_LINE_ID
             , BL_BLANKET_LINE_MIN_AMOUNT
             , BL_BLANKET_MIN_QUANTITY
             , BL_INVENTORY_ITEM_ID
             , BL_LINE_NUMBER
             , BL_END_DATE_ACTIVE
             , BL_START_DATE_ACTIVE
             , BH_CATEGORY_ID
             , BH_FINAL_OH
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_BH_BL', estimate_percent => 80, degree => 2);


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_BH');
    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_BH';

    INSERT INTO XXBI_VA_BH
             (
               BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , BL_BLANKET_LINE_MIN_AMOUNT
             , BL_BLANKET_MIN_QUANTITY
             , OL_ACCRUAL_TOTAL_PRICE
             , OL_INVOICE_TOTAL_PRICE
             , BH_CATEGORY_ID
             , BH_FINAL_OH
             , OL_PSFT_ACCRUAL_VALUE
             , OL_PSFT_INVOICE_VALUE
             , OL_PSFT_PAY_OUT_VALUE
             , OL_PSFT_PAYMENT_VALUE
             , OL_PSFT_WRITEOF_VALUE
             , OL_PSFT_ACCRUAL_REV_VALUE
             , OL_PSFT_INVOICE_REV_VALUE
             , OL_PSFT_PAY_OUT_REV_VALUE
             , OL_PSFT_PAYMENT_REV_VALUE
             , OL_PSFT_WRITEOF_REV_VALUE
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT
             , KEY_BH_BL_OH_OL
             )
        SELECT BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , SUM(BL_BLANKET_LINE_MIN_AMOUNT) BL_BLANKET_LINE_MIN_AMOUNT
             , SUM(BL_BLANKET_MIN_QUANTITY) BL_BLANKET_MIN_QUANTITY
             , SUM(OL_ACCRUAL_TOTAL_PRICE) OL_ACCRUAL_TOTAL_PRICE
             , SUM(OL_INVOICE_TOTAL_PRICE) OL_INVOICE_TOTAL_PRICE
             , BH_CATEGORY_ID
             , BH_FINAL_OH
             , SUM(OL_PSFT_ACCRUAL_VALUE) OL_PSFT_ACCRUAL_VALUE
             , SUM(OL_PSFT_INVOICE_VALUE) OL_PSFT_INVOICE_VALUE
             , SUM(OL_PSFT_PAY_OUT_VALUE) OL_PSFT_PAY_OUT_VALUE
             , SUM(OL_PSFT_PAYMENT_VALUE) OL_PSFT_PAYMENT_VALUE
             , SUM(OL_PSFT_WRITEOF_VALUE) OL_PSFT_WRITEOF_VALUE
             , SUM(OL_PSFT_ACCRUAL_REV_VALUE) OL_PSFT_ACCRUAL_REV_VALUE
             , SUM(OL_PSFT_INVOICE_REV_VALUE) OL_PSFT_INVOICE_REV_VALUE
             , SUM(OL_PSFT_PAY_OUT_REV_VALUE) OL_PSFT_PAY_OUT_REV_VALUE
             , SUM(OL_PSFT_PAYMENT_REV_VALUE) OL_PSFT_PAYMENT_REV_VALUE
             , SUM(OL_PSFT_WRITEOF_REV_VALUE) OL_PSFT_WRITEOF_REV_VALUE
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT
             , NVL(BH_HEADER_ID,0) || '-' || '0-0-0' KEY_BH_BL_OH_OL
          from xxbi_va_bh_bl
      group by BH_HEADER_ID
             , BH_SALESREP_ID
             , BH_SOLD_TO_ORG_ID
             , BH_START_DATE_ACTIVE
             , BH_END_DATE_ACTIVE
             , BH_INVOICE_DATE
             , ORG_ID
             , BH_CATEGORY_ID
             , BH_FINAL_OH
             , EBS_USED_BY
             , PSFT_USED_BY
             , HASH_KEY
             , BH_CUSTOMER_SIGNATURE_DATE
             , BH_BLANKET_MIN_AMOUNT;
    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_BH', estimate_percent => 80, degree => 2);


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PH_PL_PBI');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PH_PL_PBI';

    INSERT INTO XXBI_SRC_PH_PL_PBI
             (
               ORG_ID,
               PH_ATTRIBUTE1,
               PH_ATTRIBUTE2,
               PH_ATTRIBUTE4,
               PH_VENDOR_ID,
               PH_VENDOR_SITE_ID,
               PH_VENDOR_CONTACT_ID,
               PH_START_DATE,
               PH_END_DATE,
               PH_PO_HEADER_ID,
               PH_AGENT_ID,
               PH_WHICH_ATTACH,
               PH_USED_BY,
               PH_PK1_VALUE,
               PH_CREATION_DATE_TRUNC,
               PL_PO_LINE_ID,
               PBI_savings_type,
               PBI_opco,
               PBI_year,
               PH_BLANKET_TOTAL_AMOUNT,
               PL_UNIT_PRICE,
               PBI_ESTIMATED_SAVINGS,
               PBI_PURCHASE_VALUE,
               KEY_PH_PL_PBI
             )
        SELECT
               ph.ORG_ID
             , ph.ATTRIBUTE1
             , ph.ATTRIBUTE2
             , ph.ATTRIBUTE4
             , ph.VENDOR_ID
             , ph.VENDOR_SITE_ID
             , ph.VENDOR_CONTACT_ID
             , ph.START_DATE
             , ph.END_DATE
             , ph.PO_HEADER_ID
             , ph.AGENT_ID
             , ph.WHICH_ATTACH
             , ph.USED_BY
             , ph.PK1_VALUE
             , ph.CREATION_DATE_TRUNC
             , pl.PO_LINE_ID
             , pbi.savings_type
             , pbi.opco
             , pbi.year
             , ph.BLANKET_TOTAL_AMOUNT
             , pl.UNIT_PRICE
             , pbi.ESTIMATED_SAVINGS
             , pbi.PURCHASE_VALUE
             , TO_CHAR(ph.PO_HEADER_ID) ||'_'||TO_CHAR(pl.PO_LINE_ID) ||'_'||pbi.savings_type||'_'||pbi.opco||'_'||TO_CHAR(pbi.year)
          FROM xxbi_src_agreements       ph
             , xxbi_src_agreement_lines  pl
             , xxah_po_blanket_info      pbi
         WHERE ph.po_header_id      = pl.po_header_id
           and pbi.po_header_id (+) = pl.po_header_id
           and pbi.po_line_id (+)   = pl.po_line_id;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PH_PL_PBI', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PH_PL');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PH_PL';

    INSERT INTO XXBI_SRC_PH_PL
             (
               ORG_ID,
               PH_ATTRIBUTE1,
               PH_ATTRIBUTE2,
               PH_ATTRIBUTE4,
               PH_VENDOR_ID,
               PH_VENDOR_SITE_ID,
               PH_VENDOR_CONTACT_ID,
               PH_START_DATE,
               PH_END_DATE,
               PH_PO_HEADER_ID,
               PH_AGENT_ID,
               PH_WHICH_ATTACH,
               PH_USED_BY,
               PH_PK1_VALUE,
               PH_CREATION_DATE_TRUNC,
               PL_PO_LINE_ID,
               PH_BLANKET_TOTAL_AMOUNT,
               PL_UNIT_PRICE,
               PBI_ESTIMATED_SAVINGS,
               PBI_PURCHASE_VALUE,
               KEY_PH_PL_PBI
             )
        SELECT
               ORG_ID
             , PH_ATTRIBUTE1
             , PH_ATTRIBUTE2
             , PH_ATTRIBUTE4
             , PH_VENDOR_ID
             , PH_VENDOR_SITE_ID
             , PH_VENDOR_CONTACT_ID
             , PH_START_DATE
             , PH_END_DATE
             , PH_PO_HEADER_ID
             , PH_AGENT_ID
             , PH_WHICH_ATTACH
             , PH_USED_BY
             , PH_PK1_VALUE
             , PH_CREATION_DATE_TRUNC
             , PL_PO_LINE_ID
             , PH_BLANKET_TOTAL_AMOUNT
             , PL_UNIT_PRICE
             , SUM(PBI_ESTIMATED_SAVINGS)
             , SUM(PBI_PURCHASE_VALUE)
             , TO_CHAR(PH_PO_HEADER_ID) ||'_'||TO_CHAR(PL_PO_LINE_ID) ||'_0_0_0'
          FROM XXBI_SRC_PH_PL_PBI
        GROUP BY                ORG_ID
             , PH_ATTRIBUTE1
             , PH_ATTRIBUTE2
             , PH_ATTRIBUTE4
             , PH_VENDOR_ID
             , PH_VENDOR_SITE_ID
             , PH_VENDOR_CONTACT_ID
             , PH_START_DATE
             , PH_END_DATE
             , PH_PO_HEADER_ID
             , PH_AGENT_ID
             , PH_WHICH_ATTACH
             , PH_USED_BY
             , PH_PK1_VALUE
             , PH_CREATION_DATE_TRUNC
             , PL_PO_LINE_ID
             , PH_BLANKET_TOTAL_AMOUNT
             , PL_UNIT_PRICE
             , TO_CHAR(PH_PO_HEADER_ID) ||'_'||TO_CHAR(PL_PO_LINE_ID) ||'_0_0_0';

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PH_PL', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PH');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PH';

    INSERT INTO XXBI_SRC_PH
             (
               ORG_ID,
               PH_ATTRIBUTE1,
               PH_ATTRIBUTE2,
               PH_ATTRIBUTE4,
               PH_VENDOR_ID,
               PH_VENDOR_SITE_ID,
               PH_VENDOR_CONTACT_ID,
               PH_START_DATE,
               PH_END_DATE,
               PH_PO_HEADER_ID,
               PH_AGENT_ID,
               PH_WHICH_ATTACH,
               PH_USED_BY,
               PH_PK1_VALUE,
               PH_CREATION_DATE_TRUNC,
               PH_BLANKET_TOTAL_AMOUNT,
               PL_UNIT_PRICE,
               PBI_ESTIMATED_SAVINGS,
               PBI_PURCHASE_VALUE,
               KEY_PH_PL_PBI
             )
        SELECT
               ORG_ID
             , PH_ATTRIBUTE1
             , PH_ATTRIBUTE2
             , PH_ATTRIBUTE4
             , PH_VENDOR_ID
             , PH_VENDOR_SITE_ID
             , PH_VENDOR_CONTACT_ID
             , PH_START_DATE
             , PH_END_DATE
             , PH_PO_HEADER_ID
             , PH_AGENT_ID
             , PH_WHICH_ATTACH
             , PH_USED_BY
             , PH_PK1_VALUE
             , PH_CREATION_DATE_TRUNC
             , PH_BLANKET_TOTAL_AMOUNT
             , SUM(PL_UNIT_PRICE)
             , SUM(PBI_ESTIMATED_SAVINGS)
             , SUM(PBI_PURCHASE_VALUE)
             , TO_CHAR(PH_PO_HEADER_ID) ||'_0_0_0_0'
          FROM XXBI_SRC_PH_PL
        GROUP BY                ORG_ID
             , PH_ATTRIBUTE1
             , PH_ATTRIBUTE2
             , PH_ATTRIBUTE4
             , PH_VENDOR_ID
             , PH_VENDOR_SITE_ID
             , PH_VENDOR_CONTACT_ID
             , PH_START_DATE
             , PH_END_DATE
             , PH_PO_HEADER_ID
             , PH_AGENT_ID
             , PH_WHICH_ATTACH
             , PH_USED_BY
             , PH_PK1_VALUE
             , PH_CREATION_DATE_TRUNC
             , PH_BLANKET_TOTAL_AMOUNT
             , TO_CHAR(PH_PO_HEADER_ID) ||'_'||TO_CHAR(PL_PO_LINE_ID) ||'_0_0_0';

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PH', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_VA_PROGRESS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_VA_PROGRESS';

    INSERT INTO XXBI_VA_PROGRESS
             ( ORG_ID
             , SALESREP_ID
             , FLOW_STATUS_CODE
             , NUM_OF_YEAR
             , NUM_OF_PERIOD
             , USED_BY
             , START_OF_PERIOD
             , BLANKET_MIN_AMOUNT
             , NUMBER_OF_BH
             , PREV_YR_BLANKET_MIN_AMOUNT
             , PREV_YR_NUMBER_OF_BH
             )
       SELECT BH.org_id
            , BH.salesrep_id
          , BH.flow_status_code
          , GP2.NUM_OF_YEAR
          , GP2.NUM_OF_PERIOD
          , GP2.USED_BY
          , GP2.START_OF_PERIOD
          , SUM(BH.blanket_min_amount) blanket_min_amount
          , SUM(1) number_of_bh
          , SUM(0) prev_yr_blanket_min_amount
          , SUM(0) prev_yr_number_of_bh
       FROM xxbi_va_blanket_headers_all BH
          , xxbi_gl_periods             GP
          , (SELECT DISTINCT num_of_year
                  , num_of_period
                  , org_id
                  , used_by
                  , start_of_period
               FROM xxbi_gl_periods)    GP2
      WHERE gp.FULL_DATE = bh.START_DATE_ACTIVE
        AND gp.ORG_ID    = bh.ORG_ID
        AND gp.USED_BY   = 'ACP'
        AND gp.NUM_OF_YEAR = gp2.NUM_OF_YEAR
        AND gp.NUM_OF_PERIOD <= gp2.NUM_OF_PERIOD
        AND gp.USED_BY = gp2.USED_BY
        AND gp.ORG_ID = gp2.ORG_ID
      GROUP BY BH.org_id
             , BH.salesrep_id
             , BH.flow_status_code
             , GP2.NUM_OF_YEAR
             , GP2.NUM_OF_PERIOD
             , GP2.USED_BY
             , GP2.START_OF_PERIOD
     UNION
       SELECT BH.org_id
            , BH.salesrep_id
            , ' '  flow_status_code
            , GP2.NUM_OF_YEAR
            , GP2.NUM_OF_PERIOD
            , GP2.USED_BY
            , GP2.START_OF_PERIOD
            , SUM(0) blanket_min_amount
            , SUM(0) number_of_bh
            , SUM(BH.blanket_min_amount) prev_yr_blanket_min_amount
            , SUM(1) prev_yr_number_of_bh
         FROM xxbi_va_blanket_headers_all BH
            , xxbi_gl_periods             GP
            , (SELECT DISTINCT num_of_year
                    , num_of_period
                    , org_id
                    , used_by
                    , start_of_period
                 FROM xxbi_gl_periods)    GP2
        WHERE gp.FULL_DATE = bh.SUPPLIER_SIGNATURE_DATE
          AND gp.ORG_ID    = bh.ORG_ID
          AND gp.USED_BY   = 'ACP'
          AND gp.NUM_OF_YEAR + 1 = gp2.NUM_OF_YEAR
          AND gp.NUM_OF_PERIOD <= gp2.NUM_OF_PERIOD
          AND gp.USED_BY = gp2.USED_BY
          AND gp.ORG_ID = gp2.ORG_ID
        GROUP BY BH.org_id
               , BH.salesrep_id
               , GP2.NUM_OF_YEAR
               , GP2.NUM_OF_PERIOD
               , GP2.USED_BY
               , GP2.START_OF_PERIOD
             ;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_VA_PROGRESS', estimate_percent => 80, degree => 2);

    --
    --
    --  GLUE
    --
    --
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_PO_BUYERS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_PO_BUYERS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_PO_BUYERS';

    FOR I IN (
               SELECT distinct per.last_name
                    , per.FIRST_NAME
                    , per.FULL_NAME
                    , per.PERSON_ID
                    , (pa.AGENT_ID * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD'))) agent_id
                    , haou.name        organization_name
                    , fu.user_id
                 FROM per_all_people_f per
                    , per_all_assignments_f         paf
                    , hr_all_organization_units     haou
                    , fnd_user         fu
                    , po_agents        pa
                WHERE per.PERSON_ID = fu.EMPLOYEE_ID
                  AND pa.AGENT_ID   = fu.EMPLOYEE_ID
                  AND paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND NVL(per.effective_end_date,sysdate+1)
--                  AND SYSDATE BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,sysdate+1)
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
-- BEGIN organization_name should be a team 25 Nov SVE
                  AND EXISTS (select 'Y'
                                from XXBI_ORG_HIERARCHY
                               where team = haou.name)
-- END  organization_name should be a team 25 Nov SVE
             )
      LOOP

        INSERT INTO XXBI_PO_BUYERS
             (
               PERSON_ID
             , AGENT_ID
             , FULL_NAME
             , FIRST_NAME
             , LAST_NAME
             , ORGANIZATION_NAME
             , USER_ID
             )
        VALUES
             (
               I.PERSON_ID
             , I.AGENT_ID
             , I.FULL_NAME
             , I.FIRST_NAME
             , I.LAST_NAME
             , I.ORGANIZATION_NAME
             , I.USER_ID
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_PO_BUYERS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain Department Hierarchy Data Buyer');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_DEPT_HIER_BUYER';

    FOR I IN (
               SELECT xoh.center_of_excellence
                    , xoh.unit
                    , xoh.team
                    , xs.FIRST_NAME
                    , xs.FULL_NAME
                    , xs.LAST_NAME
                    , xs.AGENT_ID
                 FROM xxbi_org_hierarchy  xoh
                    , xxbi_po_buyers      xs
               WHERE xoh.center_of_excellence = xs.organization_name
               UNION
               SELECT xoh.center_of_excellence
                    , xoh.unit
                    , xoh.team
                    , xs.FIRST_NAME
                    , xs.FULL_NAME
                    , xs.LAST_NAME
                    , xs.AGENT_ID
                 FROM xxbi_org_hierarchy  xoh
                    , xxbi_po_buyers      xs
               WHERE (xoh.center_of_excellence = xs.organization_name or xoh.unit = xs.organization_name)
               UNION
               SELECT xoh.center_of_excellence
                    , xoh.unit
                    , xoh.team
                    , xs.FIRST_NAME
                    , xs.FULL_NAME
                    , xs.LAST_NAME
                    , xs.AGENT_ID
                 FROM xxbi_org_hierarchy  xoh
                    , xxbi_po_buyers      xs
                WHERE (xoh.center_of_excellence = xs.organization_name or xoh.unit = xs.organization_name or xoh.team = xs.organization_name)
             )
    LOOP

      INSERT INTO XXBI_DEPT_HIER_BUYER
                (
                  CENTER_OF_EXCELLENCE
                , UNIT
                , TEAM
                , FIRST_NAME
                , FULL_NAME
                , LAST_NAME
                , AGENT_ID
                )
          VALUES
                ( I.center_of_excellence
                , I.unit
                , I.team
                , I.FIRST_NAME
                , I.FULL_NAME
                , I.LAST_NAME
                , I.AGENT_ID
                );

    END LOOP;


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_PO_VENDORS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_PO_VENDORS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_PO_VENDORS';

    FOR I IN (
               SELECT ALLOW_AWT_FLAG ,
                      ALWAYS_TAKE_DISC_FLAG ,
                      --AMOUNT_INCLUDES_TAX_FLAG ,
                      --AP_TAX_ROUNDING_RULE ,
                      ATTRIBUTE1 ,
                      ATTRIBUTE10 ,
                      ATTRIBUTE11 ,
                      ATTRIBUTE12 ,
                      ATTRIBUTE2 ,
                      ATTRIBUTE3 ,
                      ATTRIBUTE4 ,
                      TO_CHAR(fnd_date.CANONICAL_TO_DATE(ATTRIBUTE5),'DD-MON-YYYY') ATTRIBUTE5,
                      ATTRIBUTE6 ,
                      TO_CHAR(fnd_date.CANONICAL_TO_DATE(ATTRIBUTE7),'DD-MON-YYYY') ATTRIBUTE7,
                      ATTRIBUTE8 ,
                      ATTRIBUTE9 ,
                      AUTO_CALCULATE_INTEREST_FLAG ,
                      CREATED_BY ,
                      CREATION_DATE ,
                      ENABLED_FLAG ,
                      END_DATE_ACTIVE ,
                      EXCLUDE_FREIGHT_FROM_DISCOUNT ,
                      FEDERAL_REPORTABLE_FLAG ,
                      HOLD_ALL_PAYMENTS_FLAG ,
                      HOLD_BY ,
                      HOLD_DATE ,
                      HOLD_FLAG ,
                      HOLD_FUTURE_PAYMENTS_FLAG ,
                      HOLD_UNMATCHED_INVOICES_FLAG ,
                      LAST_UPDATED_BY ,
                      LAST_UPDATE_DATE ,
                      LAST_UPDATE_LOGIN ,
                      MATCH_OPTION ,
                      NI_NUMBER ,
                      NUM_1099 ,
                      ONE_TIME_FLAG ,
                      PARENT_VENDOR_ID ,
                      PARTY_ID ,
                      PAYMENT_PRIORITY ,
                      PAY_DATE_BASIS_LOOKUP_CODE ,
                      SEGMENT1 ,
                      SMALL_BUSINESS_FLAG ,
                      STANDARD_INDUSTRY_CLASS ,
                      START_DATE_ACTIVE ,
                      STATE_REPORTABLE_FLAG ,
                      SUMMARY_FLAG ,
                      --TCA_SYNC_VAT_REG_NUM ,
                      --TCA_SYNC_VENDOR_NAME ,
                      TERMS_DATE_BASIS ,
                      TERMS_ID ,
                      VALIDATION_NUMBER ,
                      VAT_REGISTRATION_NUM ,
                      VENDOR_ID ,
                      VENDOR_NAME ,
                      VENDOR_NAME_ALT ,
                      WOMEN_OWNED_FLAG
                 FROM po_vendors
             )
    LOOP

        INSERT INTO XXBI_PO_VENDORS
             (  ALLOW_AWT_FLAG ,
                ALWAYS_TAKE_DISC_FLAG ,
                --AMOUNT_INCLUDES_TAX_FLAG ,
                --AP_TAX_ROUNDING_RULE ,
                ATTRIBUTE1 ,
                ATTRIBUTE10 ,
                ATTRIBUTE11 ,
                ATTRIBUTE12 ,
                ATTRIBUTE2 ,
                ATTRIBUTE3 ,
                ATTRIBUTE4 ,
                ATTRIBUTE5 ,
                ATTRIBUTE6 ,
                ATTRIBUTE7 ,
                ATTRIBUTE8 ,
                ATTRIBUTE9 ,
                AUTO_CALCULATE_INTEREST_FLAG ,
                CREATED_BY ,
                CREATION_DATE ,
                ENABLED_FLAG ,
                END_DATE_ACTIVE ,
                EXCLUDE_FREIGHT_FROM_DISCOUNT ,
                FEDERAL_REPORTABLE_FLAG ,
                HOLD_ALL_PAYMENTS_FLAG ,
                HOLD_BY ,
                HOLD_DATE ,
                HOLD_FLAG ,
                HOLD_FUTURE_PAYMENTS_FLAG ,
                HOLD_UNMATCHED_INVOICES_FLAG ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE ,
                LAST_UPDATE_LOGIN ,
                MATCH_OPTION ,
                NI_NUMBER ,
                NUM_1099 ,
                ONE_TIME_FLAG ,
                PARENT_VENDOR_ID ,
                PARTY_ID ,
                PAYMENT_PRIORITY ,
                PAY_DATE_BASIS_LOOKUP_CODE ,
                SEGMENT1 ,
                SMALL_BUSINESS_FLAG ,
                STANDARD_INDUSTRY_CLASS ,
                START_DATE_ACTIVE ,
                STATE_REPORTABLE_FLAG ,
                SUMMARY_FLAG ,
                --TCA_SYNC_VAT_REG_NUM ,
                --TCA_SYNC_VENDOR_NAME ,
                TERMS_DATE_BASIS ,
                TERMS_ID ,
                VALIDATION_NUMBER ,
                VAT_REGISTRATION_NUM ,
                VENDOR_ID ,
                VENDOR_NAME ,
                VENDOR_NAME_ALT ,
                WOMEN_OWNED_FLAG
             )
        VALUES
             (  I.ALLOW_AWT_FLAG ,
                I.ALWAYS_TAKE_DISC_FLAG ,
                --AMOUNT_INCLUDES_TAX_FLAG ,
                --AP_TAX_ROUNDING_RULE ,
                I.ATTRIBUTE1 ,
                I.ATTRIBUTE10 ,
                I.ATTRIBUTE11 ,
                I.ATTRIBUTE12 ,
                I.ATTRIBUTE2 ,
                I.ATTRIBUTE3 ,
                I.ATTRIBUTE4 ,
                I.ATTRIBUTE5 ,
                I.ATTRIBUTE6 ,
                I.ATTRIBUTE7 ,
                I.ATTRIBUTE8 ,
                I.ATTRIBUTE9 ,
                I.AUTO_CALCULATE_INTEREST_FLAG ,
                I.CREATED_BY ,
                I.CREATION_DATE ,
                I.ENABLED_FLAG ,
                I.END_DATE_ACTIVE ,
                I.EXCLUDE_FREIGHT_FROM_DISCOUNT ,
                I.FEDERAL_REPORTABLE_FLAG ,
                I.HOLD_ALL_PAYMENTS_FLAG ,
                I.HOLD_BY ,
                I.HOLD_DATE ,
                I.HOLD_FLAG ,
                I.HOLD_FUTURE_PAYMENTS_FLAG ,
                I.HOLD_UNMATCHED_INVOICES_FLAG ,
                I.LAST_UPDATED_BY ,
                I.LAST_UPDATE_DATE ,
                I.LAST_UPDATE_LOGIN ,
                I.MATCH_OPTION ,
                I.NI_NUMBER ,
                I.NUM_1099 ,
                I.ONE_TIME_FLAG ,
                I.PARENT_VENDOR_ID ,
                I.PARTY_ID ,
                I.PAYMENT_PRIORITY ,
                I.PAY_DATE_BASIS_LOOKUP_CODE ,
                I.SEGMENT1 ,
                I.SMALL_BUSINESS_FLAG ,
                I.STANDARD_INDUSTRY_CLASS ,
                I.START_DATE_ACTIVE ,
                I.STATE_REPORTABLE_FLAG ,
                I.SUMMARY_FLAG ,
                --TCA_SYNC_VAT_REG_NUM ,
                --TCA_SYNC_VENDOR_NAME ,
                I.TERMS_DATE_BASIS ,
                I.TERMS_ID ,
                I.VALIDATION_NUMBER ,
                I.VAT_REGISTRATION_NUM ,
                I.VENDOR_ID ,
                I.VENDOR_NAME ,
                I.VENDOR_NAME_ALT ,
                I.WOMEN_OWNED_FLAG
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_PO_VENDORS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_PO_VENDOR_SITES');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_PO_VENDOR_SITES';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_PO_VENDOR_SITES';

    FOR I IN (
               SELECT vendor_id
                    , vendor_site_id
                    , vendor_site_code
                    , org_id
                 FROM po_vendor_sites_all
             )
    LOOP

        INSERT INTO XXBI_PO_VENDOR_SITES
             (
               VENDOR_ID
             , VENDOR_SITE_ID
             , VENDOR_SITE_CODE
             , ORG_ID
             )
        VALUES
             (
               I.VENDOR_ID
             , I.VENDOR_SITE_ID
             , I.VENDOR_SITE_CODE
             , I.ORG_ID
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_PO_VENDOR_SITES', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_PO_VENDOR_CONTACTS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_PO_VENDOR_CONTACTS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_PO_VENDOR_CONTACTS';

    FOR I IN (
               SELECT vendor_contact_id
                    , vendor_site_id
                    , NVL(first_name,'?') first_name
                    , NVL(last_name,'?') last_name
                    , NVL(last_name,'?') ||', '|| NVL(prefix,'?') ||' '|| NVL(first_name,'?') full_name
                 FROM po_vendor_contacts
             )
    LOOP

        INSERT INTO XXBI_PO_VENDOR_CONTACTS
             (
               VENDOR_CONTACT_ID
             , VENDOR_SITE_ID
             , FIRST_NAME
             , LAST_NAME
             , FULL_NAME
             )
        VALUES
             (
               I.VENDOR_CONTACT_ID
             , I.VENDOR_SITE_ID
             , I.FIRST_NAME
             , I.LAST_NAME
             , I.FULL_NAME
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_PO_VENDOR_CONTACTS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_PO_AUCTION_DOC_TYPES');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_PO_AUCTION_DOC_TYPES';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_PO_AUCTION_DOC_TYPES';

    FOR I IN (
               SELECT pad.DOCTYPE_ID
                    , flv.meaning
                    , pad.DOCTYPE_GROUP_NAME
                    , flv.LANGUAGE
                 FROM PON_AUC_DOCTYPES          pad
                    , fnd_lookup_values         flv
                WHERE flv.LOOKUP_TYPE = 'PON_AUCTION_DOC_TYPES'
                  AND flv.LOOKUP_CODE = pad.DOCTYPE_GROUP_NAME
                  AND flv.LANGUAGE    = USERENV('lang')
             )
    LOOP

        INSERT INTO XXBI_PO_AUCTION_DOC_TYPES
             (  DOCTYPE_ID ,
                MEANING ,
                DOCTYPE_GROUP_NAME ,
                LANGUAGE
             )
        VALUES
             (  I.DOCTYPE_ID ,
                I.MEANING ,
                I.DOCTYPE_GROUP_NAME ,
                I.LANGUAGE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_PO_AUCTION_DOC_TYPES', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_AGREEMENTS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_AGREEMENTS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_AGREEMENTS';

    FOR I IN (
               SELECT PoHeaderMergeEO.OWNER_USER_ID
                    , PoHeaderMergeEO.OWNER_ROLE
                    , NVL(PoHeaderMergeEO.STATUS,'-') STATUS
                    , PoHeaderMergeEO.DRAFT_ID
                    , PoHeaderMergeEO.CHANGE_ACCEPTED_FLAG
                    , PoHeaderMergeEO.DELETE_FLAG
                    , PoHeaderMergeEO.EMAIL_ADDRESS
                    , PoHeaderMergeEO.FAX
                    , PoHeaderMergeEO.SUPPLIER_NOTIF_METHOD
                    , PoHeaderMergeEO.AUTO_SOURCING_FLAG
                    , PoHeaderMergeEO.UPDATE_SOURCING_RULES_FLAG
                    , PoHeaderMergeEO.RETRO_PRICE_APPLY_UPDATES_FLAG
                    , PoHeaderMergeEO.RETRO_PRICE_COMM_UPDATES_FLAG
                    , PoHeaderMergeEO.CLOSED_CODE
                    , PoHeaderMergeEO.USSGL_TRANSACTION_CODE
                    , PoHeaderMergeEO.GOVERNMENT_CONTEXT
                    , PoHeaderMergeEO.REQUEST_ID
                    , PoHeaderMergeEO.PROGRAM_APPLICATION_ID
                    , PoHeaderMergeEO.PROGRAM_ID
                    , PoHeaderMergeEO.PROGRAM_UPDATE_DATE
                    , PoHeaderMergeEO.ORG_ID
                    , PoHeaderMergeEO.COMMENTS
                    , PoHeaderMergeEO.REPLY_DATE
                    , PoHeaderMergeEO.REPLY_METHOD_LOOKUP_CODE
                    , PoHeaderMergeEO.RFQ_CLOSE_DATE
                    , PoHeaderMergeEO.QUOTE_TYPE_LOOKUP_CODE
                    , PoHeaderMergeEO.QUOTATION_CLASS_CODE
                    , PoHeaderMergeEO.QUOTE_WARNING_DELAY_UNIT
                    , PoHeaderMergeEO.QUOTE_WARNING_DELAY
                    , PoHeaderMergeEO.QUOTE_VENDOR_QUOTE_NUMBER
                    , PoHeaderMergeEO.ACCEPTANCE_REQUIRED_FLAG
                    , PoHeaderMergeEO.ACCEPTANCE_DUE_DATE
                    , PoHeaderMergeEO.CLOSED_DATE
                    , PoHeaderMergeEO.USER_HOLD_FLAG
                    , PoHeaderMergeEO.APPROVAL_REQUIRED_FLAG
                    , PoHeaderMergeEO.CANCEL_FLAG
                    , PoHeaderMergeEO.FIRM_STATUS_LOOKUP_CODE
                    , PoHeaderMergeEO.FIRM_DATE
                    , PoHeaderMergeEO.FROZEN_FLAG
                    , PoHeaderMergeEO.EDI_PROCESSED_FLAG
                    , PoHeaderMergeEO.EDI_PROCESSED_STATUS
                    , PoHeaderMergeEO.ATTRIBUTE_CATEGORY
                    , fnd_date.CANONICAL_TO_DATE(PoHeaderMergeEO.ATTRIBUTE1)  attribute1
                    , PoHeaderMergeEO.ATTRIBUTE2
                    , PoHeaderMergeEO.ATTRIBUTE3
                    , fnd_date.CANONICAL_TO_DATE(PoHeaderMergeEO.ATTRIBUTE4)  attribute4
                    , PoHeaderMergeEO.ATTRIBUTE5 -- Combined Approval Flag
                    , PoHeaderMergeEO.ATTRIBUTE6 -- Commited Value (Linear Depreciation)
                    , PoHeaderMergeEO.ATTRIBUTE7
                    , PoHeaderMergeEO.ATTRIBUTE8
                    , PoHeaderMergeEO.ATTRIBUTE9
                    , PoHeaderMergeEO.ATTRIBUTE10
                    , PoHeaderMergeEO.ATTRIBUTE11
                    , PoHeaderMergeEO.ATTRIBUTE12 -- Amount in Foreign Currency
                    , PoHeaderMergeEO.ATTRIBUTE13 -- Commited Value (Fixed Value)
                    , PoHeaderMergeEO.ATTRIBUTE14
                    , PoHeaderMergeEO.ATTRIBUTE15
                    , PoHeaderMergeEO.CREATED_BY
                    , PoHeaderMergeEO.VENDOR_ID
                    , PoHeaderMergeEO.VENDOR_SITE_ID
                    , PoHeaderMergeEO.VENDOR_CONTACT_ID
                    , PoHeaderMergeEO.SHIP_TO_LOCATION_ID
                    , PoHeaderMergeEO.BILL_TO_LOCATION_ID
                    , PoHeaderMergeEO.TERMS_ID
                    , PoHeaderMergeEO.SHIP_VIA_LOOKUP_CODE
                    , PoHeaderMergeEO.FOB_LOOKUP_CODE
                    , PoHeaderMergeEO.FREIGHT_TERMS_LOOKUP_CODE
                    , PoHeaderMergeEO.STATUS_LOOKUP_CODE
                    , PoHeaderMergeEO.CURRENCY_CODE
                    , PoHeaderMergeEO.RATE_TYPE
                    , PoHeaderMergeEO.RATE_DATE
                    , PoHeaderMergeEO.RATE
                    , PoHeaderMergeEO.FROM_HEADER_ID
                    , PoHeaderMergeEO.FROM_TYPE_LOOKUP_CODE
                    , PoHeaderMergeEO.START_DATE
                    , PoHeaderMergeEO.END_DATE
                    , PoHeaderMergeEO.BLANKET_TOTAL_AMOUNT
                    , PoHeaderMergeEO.AUTHORIZATION_STATUS
                    , PoHeaderMergeEO.REVISION_NUM
                    , PoHeaderMergeEO.REVISED_DATE
                    , PoHeaderMergeEO.APPROVED_FLAG
                    , PoHeaderMergeEO.APPROVED_DATE
                    , PoHeaderMergeEO.AMOUNT_LIMIT
                    , PoHeaderMergeEO.MIN_RELEASE_AMOUNT
                    , PoHeaderMergeEO.NOTE_TO_AUTHORIZER
                    , PoHeaderMergeEO.NOTE_TO_VENDOR
                    , PoHeaderMergeEO.NOTE_TO_RECEIVER
                    , PoHeaderMergeEO.PRINT_COUNT
                    , PoHeaderMergeEO.PRINTED_DATE
                    , PoHeaderMergeEO.VENDOR_ORDER_NUM
                    , PoHeaderMergeEO.CONFIRMING_ORDER_FLAG
                    , PoHeaderMergeEO.PO_HEADER_ID
  --                  , PoHeaderMergeEO.AGENT_ID
       , ( SELECT  PoHeaderMergeEO.AGENT_ID * 100000000 +
                      TO_NUMBER(TO_CHAR(paf.EFFECTIVE_START_DATE,'YYYYMMDD')) || TO_NUMBER(TO_CHAR(paf.EFFECTIVE_END_DATE,'YYYYMMDD'))
           FROM per_all_people_f per
              , per_all_assignments_f         paf
              , po_agents                     pa
              , fnd_user                      fu
              , hr_all_organization_units     haou
                WHERE paf.person_id = per.person_id
                  AND paf.primary_flag = 'Y'
                  AND SYSDATE BETWEEN per.effective_start_date AND per.effective_end_date
                  AND trunc(PoHeaderMergeEO.creation_date) BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,SYSDATE+1)
                  AND per.PERSON_ID = fu.EMPLOYEE_ID
                  AND pa.AGENT_ID   = fu.EMPLOYEE_ID
                  AND haou.ORGANIZATION_ID = paf.ORGANIZATION_ID
                  and pa.AGENT_ID= PoHeaderMergeEO.AGENT_ID) agent_id
  --
                    , PoHeaderMergeEO.TYPE_LOOKUP_CODE
                    , PoHeaderMergeEO.LAST_UPDATE_DATE
                    , PoHeaderMergeEO.LAST_UPDATED_BY
                    , PoHeaderMergeEO.SEGMENT1
                    , PoHeaderMergeEO.SUMMARY_FLAG
                    , PoHeaderMergeEO.ENABLED_FLAG
                    , PoHeaderMergeEO.SEGMENT2
                    , PoHeaderMergeEO.SEGMENT3
                    , PoHeaderMergeEO.SEGMENT4
                    , PoHeaderMergeEO.SEGMENT5
                    , PoHeaderMergeEO.START_DATE_ACTIVE
                    , PoHeaderMergeEO.END_DATE_ACTIVE
                    , PoHeaderMergeEO.LAST_UPDATE_LOGIN
                    , PoHeaderMergeEO.CREATION_DATE
                    , PoHeaderMergeEO.SUPPLY_AGREEMENT_FLAG
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE_CATEGORY
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE1
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE2
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE3
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE4
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE5
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE6
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE7
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE8
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE9
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE10
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE11
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE12
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE13
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE14
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE15
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE16
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE17
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE18
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE19
                    , PoHeaderMergeEO.GLOBAL_ATTRIBUTE20
                    , PoHeaderMergeEO.INTERFACE_SOURCE_CODE
                    , PoHeaderMergeEO.REFERENCE_NUM
                    , PoHeaderMergeEO.WF_ITEM_TYPE
                    , PoHeaderMergeEO.WF_ITEM_KEY
                    , PoHeaderMergeEO.PCARD_ID
                    , PoHeaderMergeEO.PRICE_UPDATE_TOLERANCE
                    , PoHeaderMergeEO.MRC_RATE_TYPE
                    , PoHeaderMergeEO.MRC_RATE_DATE
                    , PoHeaderMergeEO.MRC_RATE
                    , PoHeaderMergeEO.PAY_ON_CODE
                    , PoHeaderMergeEO.XML_FLAG
                    , PoHeaderMergeEO.XML_SEND_DATE
                    , PoHeaderMergeEO.XML_CHANGE_SEND_DATE
                    , PoHeaderMergeEO.GLOBAL_AGREEMENT_FLAG
                    , PoHeaderMergeEO.CONSIGNED_CONSUMPTION_FLAG
                    , PoHeaderMergeEO.CBC_ACCOUNTING_DATE
                    , PoHeaderMergeEO.CONSUME_REQ_DEMAND_FLAG
                    , PoHeaderMergeEO.CHANGE_REQUESTED_BY
                    , PoHeaderMergeEO.SHIPPING_CONTROL
                    , PoHeaderMergeEO.CONTERMS_EXIST_FLAG
                    , PoHeaderMergeEO.CONTERMS_ARTICLES_UPD_DATE
                    , PoHeaderMergeEO.CONTERMS_DELIV_UPD_DATE
                    , PoHeaderMergeEO.ENCUMBRANCE_REQUIRED_FLAG
                    , PoHeaderMergeEO.PENDING_SIGNATURE_FLAG
                    , PoHeaderMergeEO.CHANGE_SUMMARY
                    , PoHeaderMergeEO.DOCUMENT_CREATION_METHOD
                    , PoHeaderMergeEO.SUBMIT_DATE
                    , PoHeaderMergeEO.CREATED_LANGUAGE
                    , PoHeaderMergeEO.CPA_REFERENCE
                    , PoHeaderMergeEO.STYLE_ID
                    , PoHeaderMergeEO.TAX_ATTRIBUTE_UPDATE_CODE
                    , PoHeaderMergeEO.SUPPLIER_AUTH_ENABLED_FLAG
                    , PoHeaderMergeEO.CAT_ADMIN_AUTH_ENABLED_FLAG
                    , 'PO_HEADERS'                                   WHICH_ATTACH
                    , 'EBS'                                          USED_BY
                    , TO_CHAR(PoHeaderMergeEO.PO_HEADER_ID)          PK1_VALUE
                    , NVL(flv.MEANING,'-')                           STATUS_DESCRIPTION
                    , hrl.DESCRIPTION                                DEFAULT_SHIP_TO_LOCATION
                    , at.DESCRIPTION                                 PAYMENT_TERMS
                    , TRUNC(PoHeaderMergeEO.creation_date)           CREATION_DATE_TRUNC
               FROM PO_HEADERS_MERGE_V  PoHeaderMergeEO
                  , fnd_lookup_values   flv
                  , hr_locations_all_tl hrl
                  , ap_terms            at
              WHERE flv.lookup_type(+) = 'AUTHORIZATION STATUS'
                AND flv.lookup_code(+) = PoHeaderMergeEO.AUTHORIZATION_STATUS
                AND hrl.location_id(+) = PoHeaderMergeEO.ship_to_location_id
                AND hrl.LANGUAGE(+)    = USERENV ('LANG')
                AND at.term_id(+)      = PoHeaderMergeEO.terms_id
             )
    LOOP

        INSERT INTO XXBI_SRC_AGREEMENTS
             (
               OWNER_USER_ID
             , OWNER_ROLE
             , STATUS
             , DRAFT_ID
             , CHANGE_ACCEPTED_FLAG
             , DELETE_FLAG
             , EMAIL_ADDRESS
             , FAX
             , SUPPLIER_NOTIF_METHOD
             , AUTO_SOURCING_FLAG
             , UPDATE_SOURCING_RULES_FLAG
             , RETRO_PRICE_APPLY_UPDATES_FLAG
             , RETRO_PRICE_COMM_UPDATES_FLAG
             , CLOSED_CODE
             , USSGL_TRANSACTION_CODE
             , GOVERNMENT_CONTEXT
             , REQUEST_ID
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , PROGRAM_UPDATE_DATE
             , ORG_ID
             , COMMENTS
             , REPLY_DATE
             , REPLY_METHOD_LOOKUP_CODE
             , RFQ_CLOSE_DATE
             , QUOTE_TYPE_LOOKUP_CODE
             , QUOTATION_CLASS_CODE
             , QUOTE_WARNING_DELAY_UNIT
             , QUOTE_WARNING_DELAY
             , QUOTE_VENDOR_QUOTE_NUMBER
             , ACCEPTANCE_REQUIRED_FLAG
             , ACCEPTANCE_DUE_DATE
             , CLOSED_DATE
             , USER_HOLD_FLAG
             , APPROVAL_REQUIRED_FLAG
             , CANCEL_FLAG
             , FIRM_STATUS_LOOKUP_CODE
             , FIRM_DATE
             , FROZEN_FLAG
             , EDI_PROCESSED_FLAG
             , EDI_PROCESSED_STATUS
             , ATTRIBUTE_CATEGORY
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , ATTRIBUTE9
             , ATTRIBUTE10
             , ATTRIBUTE11
             , ATTRIBUTE12
             , ATTRIBUTE13
             , ATTRIBUTE14
             , ATTRIBUTE15
             , CREATED_BY
             , VENDOR_ID
             , VENDOR_SITE_ID
             , VENDOR_CONTACT_ID
             , SHIP_TO_LOCATION_ID
             , BILL_TO_LOCATION_ID
             , TERMS_ID
             , SHIP_VIA_LOOKUP_CODE
             , FOB_LOOKUP_CODE
             , FREIGHT_TERMS_LOOKUP_CODE
             , STATUS_LOOKUP_CODE
             , CURRENCY_CODE
             , RATE_TYPE
             , RATE_DATE
             , RATE
             , FROM_HEADER_ID
             , FROM_TYPE_LOOKUP_CODE
             , START_DATE
             , END_DATE
             , BLANKET_TOTAL_AMOUNT
             , AUTHORIZATION_STATUS
             , REVISION_NUM
             , REVISED_DATE
             , APPROVED_FLAG
             , APPROVED_DATE
             , AMOUNT_LIMIT
             , MIN_RELEASE_AMOUNT
             , NOTE_TO_AUTHORIZER
             , NOTE_TO_VENDOR
             , NOTE_TO_RECEIVER
             , PRINT_COUNT
             , PRINTED_DATE
             , VENDOR_ORDER_NUM
             , CONFIRMING_ORDER_FLAG
             , PO_HEADER_ID
             , AGENT_ID
             , TYPE_LOOKUP_CODE
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , SEGMENT1
             , SUMMARY_FLAG
             , ENABLED_FLAG
             , SEGMENT2
             , SEGMENT3
             , SEGMENT4
             , SEGMENT5
             , START_DATE_ACTIVE
             , END_DATE_ACTIVE
             , LAST_UPDATE_LOGIN
             , CREATION_DATE
             , SUPPLY_AGREEMENT_FLAG
             , GLOBAL_ATTRIBUTE_CATEGORY
             , GLOBAL_ATTRIBUTE1
             , GLOBAL_ATTRIBUTE2
             , GLOBAL_ATTRIBUTE3
             , GLOBAL_ATTRIBUTE4
             , GLOBAL_ATTRIBUTE5
             , GLOBAL_ATTRIBUTE6
             , GLOBAL_ATTRIBUTE7
             , GLOBAL_ATTRIBUTE8
             , GLOBAL_ATTRIBUTE9
             , GLOBAL_ATTRIBUTE10
             , GLOBAL_ATTRIBUTE11
             , GLOBAL_ATTRIBUTE12
             , GLOBAL_ATTRIBUTE13
             , GLOBAL_ATTRIBUTE14
             , GLOBAL_ATTRIBUTE15
             , GLOBAL_ATTRIBUTE16
             , GLOBAL_ATTRIBUTE17
             , GLOBAL_ATTRIBUTE18
             , GLOBAL_ATTRIBUTE19
             , GLOBAL_ATTRIBUTE20
             , INTERFACE_SOURCE_CODE
             , REFERENCE_NUM
             , WF_ITEM_TYPE
             , WF_ITEM_KEY
             , PCARD_ID
             , PRICE_UPDATE_TOLERANCE
             , MRC_RATE_TYPE
             , MRC_RATE_DATE
             , MRC_RATE
             , PAY_ON_CODE
             , XML_FLAG
             , XML_SEND_DATE
             , XML_CHANGE_SEND_DATE
             , GLOBAL_AGREEMENT_FLAG
             , CONSIGNED_CONSUMPTION_FLAG
             , CBC_ACCOUNTING_DATE
             , CONSUME_REQ_DEMAND_FLAG
             , CHANGE_REQUESTED_BY
             , SHIPPING_CONTROL
             , CONTERMS_EXIST_FLAG
             , CONTERMS_ARTICLES_UPD_DATE
             , CONTERMS_DELIV_UPD_DATE
             , ENCUMBRANCE_REQUIRED_FLAG
             , PENDING_SIGNATURE_FLAG
             , CHANGE_SUMMARY
             , DOCUMENT_CREATION_METHOD
             , SUBMIT_DATE
             , CREATED_LANGUAGE
             , CPA_REFERENCE
             , STYLE_ID
             , TAX_ATTRIBUTE_UPDATE_CODE
             , SUPPLIER_AUTH_ENABLED_FLAG
             , CAT_ADMIN_AUTH_ENABLED_FLAG
             , WHICH_ATTACH
             , USED_BY
             , PK1_VALUE
             , STATUS_DESCRIPTION
             , DEFAULT_SHIP_TO_LOCATION
             , PAYMENT_TERMS
             , CREATION_DATE_TRUNC
             )
        VALUES
             (
               I.OWNER_USER_ID
             , I.OWNER_ROLE
             , I.STATUS
             , I.DRAFT_ID
             , I.CHANGE_ACCEPTED_FLAG
             , I.DELETE_FLAG
             , I.EMAIL_ADDRESS
             , I.FAX
             , I.SUPPLIER_NOTIF_METHOD
             , I.AUTO_SOURCING_FLAG
             , I.UPDATE_SOURCING_RULES_FLAG
             , I.RETRO_PRICE_APPLY_UPDATES_FLAG
             , I.RETRO_PRICE_COMM_UPDATES_FLAG
             , I.CLOSED_CODE
             , I.USSGL_TRANSACTION_CODE
             , I.GOVERNMENT_CONTEXT
             , I.REQUEST_ID
             , I.PROGRAM_APPLICATION_ID
             , I.PROGRAM_ID
             , I.PROGRAM_UPDATE_DATE
             , I.ORG_ID
             , I.COMMENTS
             , I.REPLY_DATE
             , I.REPLY_METHOD_LOOKUP_CODE
             , I.RFQ_CLOSE_DATE
             , I.QUOTE_TYPE_LOOKUP_CODE
             , I.QUOTATION_CLASS_CODE
             , I.QUOTE_WARNING_DELAY_UNIT
             , I.QUOTE_WARNING_DELAY
             , I.QUOTE_VENDOR_QUOTE_NUMBER
             , I.ACCEPTANCE_REQUIRED_FLAG
             , I.ACCEPTANCE_DUE_DATE
             , I.CLOSED_DATE
             , I.USER_HOLD_FLAG
             , I.APPROVAL_REQUIRED_FLAG
             , I.CANCEL_FLAG
             , I.FIRM_STATUS_LOOKUP_CODE
             , I.FIRM_DATE
             , I.FROZEN_FLAG
             , I.EDI_PROCESSED_FLAG
             , I.EDI_PROCESSED_STATUS
             , I.ATTRIBUTE_CATEGORY
             , I.ATTRIBUTE1
             , I.ATTRIBUTE2
             , I.ATTRIBUTE3
             , I.ATTRIBUTE4
             , I.ATTRIBUTE5
             , I.ATTRIBUTE6
             , I.ATTRIBUTE7
             , I.ATTRIBUTE8
             , I.ATTRIBUTE9
             , I.ATTRIBUTE10
             , I.ATTRIBUTE11
             , I.ATTRIBUTE12
             , I.ATTRIBUTE13
             , I.ATTRIBUTE14
             , I.ATTRIBUTE15
             , I.CREATED_BY
             , I.VENDOR_ID
             , I.VENDOR_SITE_ID
             , I.VENDOR_CONTACT_ID
             , I.SHIP_TO_LOCATION_ID
             , I.BILL_TO_LOCATION_ID
             , I.TERMS_ID
             , I.SHIP_VIA_LOOKUP_CODE
             , I.FOB_LOOKUP_CODE
             , I.FREIGHT_TERMS_LOOKUP_CODE
             , I.STATUS_LOOKUP_CODE
             , I.CURRENCY_CODE
             , I.RATE_TYPE
             , I.RATE_DATE
             , I.RATE
             , I.FROM_HEADER_ID
             , I.FROM_TYPE_LOOKUP_CODE
             , I.START_DATE
             , I.END_DATE
             , I.BLANKET_TOTAL_AMOUNT
             , I.AUTHORIZATION_STATUS
             , I.REVISION_NUM
             , I.REVISED_DATE
             , I.APPROVED_FLAG
             , I.APPROVED_DATE
             , I.AMOUNT_LIMIT
             , I.MIN_RELEASE_AMOUNT
             , I.NOTE_TO_AUTHORIZER
             , I.NOTE_TO_VENDOR
             , I.NOTE_TO_RECEIVER
             , I.PRINT_COUNT
             , I.PRINTED_DATE
             , I.VENDOR_ORDER_NUM
             , I.CONFIRMING_ORDER_FLAG
             , I.PO_HEADER_ID
             , I.AGENT_ID
             , I.TYPE_LOOKUP_CODE
             , I.LAST_UPDATE_DATE
             , I.LAST_UPDATED_BY
             , I.SEGMENT1
             , I.SUMMARY_FLAG
             , I.ENABLED_FLAG
             , I.SEGMENT2
             , I.SEGMENT3
             , I.SEGMENT4
             , I.SEGMENT5
             , I.START_DATE_ACTIVE
             , I.END_DATE_ACTIVE
             , I.LAST_UPDATE_LOGIN
             , I.CREATION_DATE
             , I.SUPPLY_AGREEMENT_FLAG
             , I.GLOBAL_ATTRIBUTE_CATEGORY
             , I.GLOBAL_ATTRIBUTE1
             , I.GLOBAL_ATTRIBUTE2
             , I.GLOBAL_ATTRIBUTE3
             , I.GLOBAL_ATTRIBUTE4
             , I.GLOBAL_ATTRIBUTE5
             , I.GLOBAL_ATTRIBUTE6
             , I.GLOBAL_ATTRIBUTE7
             , I.GLOBAL_ATTRIBUTE8
             , I.GLOBAL_ATTRIBUTE9
             , I.GLOBAL_ATTRIBUTE10
             , I.GLOBAL_ATTRIBUTE11
             , I.GLOBAL_ATTRIBUTE12
             , I.GLOBAL_ATTRIBUTE13
             , I.GLOBAL_ATTRIBUTE14
             , I.GLOBAL_ATTRIBUTE15
             , I.GLOBAL_ATTRIBUTE16
             , I.GLOBAL_ATTRIBUTE17
             , I.GLOBAL_ATTRIBUTE18
             , I.GLOBAL_ATTRIBUTE19
             , I.GLOBAL_ATTRIBUTE20
             , I.INTERFACE_SOURCE_CODE
             , I.REFERENCE_NUM
             , I.WF_ITEM_TYPE
             , I.WF_ITEM_KEY
             , I.PCARD_ID
             , I.PRICE_UPDATE_TOLERANCE
             , I.MRC_RATE_TYPE
             , I.MRC_RATE_DATE
             , I.MRC_RATE
             , I.PAY_ON_CODE
             , I.XML_FLAG
             , I.XML_SEND_DATE
             , I.XML_CHANGE_SEND_DATE
             , I.GLOBAL_AGREEMENT_FLAG
             , I.CONSIGNED_CONSUMPTION_FLAG
             , I.CBC_ACCOUNTING_DATE
             , I.CONSUME_REQ_DEMAND_FLAG
             , I.CHANGE_REQUESTED_BY
             , I.SHIPPING_CONTROL
             , I.CONTERMS_EXIST_FLAG
             , I.CONTERMS_ARTICLES_UPD_DATE
             , I.CONTERMS_DELIV_UPD_DATE
             , I.ENCUMBRANCE_REQUIRED_FLAG
             , I.PENDING_SIGNATURE_FLAG
             , I.CHANGE_SUMMARY
             , I.DOCUMENT_CREATION_METHOD
             , I.SUBMIT_DATE
             , I.CREATED_LANGUAGE
             , I.CPA_REFERENCE
             , I.STYLE_ID
             , I.TAX_ATTRIBUTE_UPDATE_CODE
             , I.SUPPLIER_AUTH_ENABLED_FLAG
             , I.CAT_ADMIN_AUTH_ENABLED_FLAG
             , I.WHICH_ATTACH
             , I.USED_BY
             , I.PK1_VALUE
             , I.STATUS_DESCRIPTION
             , I.DEFAULT_SHIP_TO_LOCATION
             , I.PAYMENT_TERMS
             , I.CREATION_DATE_TRUNC
             );
        l_count_insert := l_count_insert + 1;

    END LOOP;
    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_AGREEMENTS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_AGREEMENT_LINES');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_AGREEMENT_LINES';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_AGREEMENT_LINES';

    FOR I IN (
               SELECT PoLineMergeEO.DRAFT_ID
                    , PoLineMergeEO.CHANGE_ACCEPTED_FLAG
                    , PoLineMergeEO.DELETE_FLAG
                    , PoLineMergeEO.ATTRIBUTE9
                    , PoLineMergeEO.ATTRIBUTE10
                    , PoLineMergeEO.REFERENCE_NUM
                    , PoLineMergeEO.ATTRIBUTE11
                    , PoLineMergeEO.ATTRIBUTE12
                    , PoLineMergeEO.ATTRIBUTE13
                    , PoLineMergeEO.ATTRIBUTE14
                    , PoLineMergeEO.ATTRIBUTE15
                    , PoLineMergeEO.MIN_RELEASE_AMOUNT
                    , PoLineMergeEO.PRICE_TYPE_LOOKUP_CODE
                    , PoLineMergeEO.CLOSED_CODE
                    , PoLineMergeEO.PRICE_BREAK_LOOKUP_CODE
                    , PoLineMergeEO.USSGL_TRANSACTION_CODE
                    , PoLineMergeEO.GOVERNMENT_CONTEXT
                    , PoLineMergeEO.REQUEST_ID
                    , PoLineMergeEO.PROGRAM_APPLICATION_ID
                    , PoLineMergeEO.PROGRAM_ID
                    , PoLineMergeEO.PROGRAM_UPDATE_DATE
                    , PoLineMergeEO.CLOSED_DATE
                    , PoLineMergeEO.CLOSED_REASON
                    , PoLineMergeEO.CLOSED_BY
                    , PoLineMergeEO.TRANSACTION_REASON_CODE
                    , PoLineMergeEO.ORG_ID
                    , PoLineMergeEO.HAZARD_CLASS_ID
                    , PoLineMergeEO.NOTE_TO_VENDOR
                    , PoLineMergeEO.FROM_HEADER_ID
                    , PoLineMergeEO.FROM_LINE_ID
                    , PoLineMergeEO.MIN_ORDER_QUANTITY
                    , PoLineMergeEO.MAX_ORDER_QUANTITY
                    , PoLineMergeEO.QTY_RCV_TOLERANCE
                    , PoLineMergeEO.OVER_TOLERANCE_ERROR_FLAG
                    , PoLineMergeEO.MARKET_PRICE
                    , PoLineMergeEO.UNORDERED_FLAG
                    , PoLineMergeEO.CLOSED_FLAG
                    , PoLineMergeEO.USER_HOLD_FLAG
                    , PoLineMergeEO.CANCEL_FLAG
                    , PoLineMergeEO.CANCELLED_BY
                    , PoLineMergeEO.CANCEL_DATE
                    , PoLineMergeEO.CANCEL_REASON
                    , PoLineMergeEO.FIRM_STATUS_LOOKUP_CODE
                    , PoLineMergeEO.FIRM_DATE
                    , PoLineMergeEO.VENDOR_PRODUCT_NUM
                    , PoLineMergeEO.CONTRACT_NUM
                    , PoLineMergeEO.TAXABLE_FLAG
                    , PoLineMergeEO.TYPE_1099
                    , PoLineMergeEO.CAPITAL_EXPENSE_FLAG
                    , PoLineMergeEO.NEGOTIATED_BY_PREPARER_FLAG
                    , PoLineMergeEO.ATTRIBUTE_CATEGORY
                    , PoLineMergeEO.ATTRIBUTE1
                    , PoLineMergeEO.ATTRIBUTE2
                    , PoLineMergeEO.ATTRIBUTE3
                    , PoLineMergeEO.ATTRIBUTE4
                    , PoLineMergeEO.ATTRIBUTE5
                    , PoLineMergeEO.ATTRIBUTE6
                    , PoLineMergeEO.ATTRIBUTE7
                    , PoLineMergeEO.ATTRIBUTE8
                    , PoLineMergeEO.QC_GRADE
                    , PoLineMergeEO.BASE_UOM
                    , PoLineMergeEO.BASE_QTY
                    , PoLineMergeEO.SECONDARY_UOM
                    , PoLineMergeEO.SECONDARY_QTY
                    , PoLineMergeEO.PO_LINE_ID
                    , PoLineMergeEO.LAST_UPDATE_DATE
                    , PoLineMergeEO.LAST_UPDATED_BY
                    , PoLineMergeEO.PO_HEADER_ID
                    , PoLineMergeEO.LINE_TYPE_ID
                    , PoLineMergeEO.LINE_NUM
                    , PoLineMergeEO.LAST_UPDATE_LOGIN
                    , PoLineMergeEO.CREATION_DATE
                    , PoLineMergeEO.CREATED_BY
                    , PoLineMergeEO.ITEM_ID
                    , PoLineMergeEO.ITEM_REVISION
                    , PoLineMergeEO.CATEGORY_ID
                    , PoLineMergeEO.ITEM_DESCRIPTION
                    , PoLineMergeEO.UNIT_MEAS_LOOKUP_CODE
                    , PoLineMergeEO.QUANTITY_COMMITTED
                    , PoLineMergeEO.COMMITTED_AMOUNT
                    , PoLineMergeEO.ALLOW_PRICE_OVERRIDE_FLAG
                    , PoLineMergeEO.NOT_TO_EXCEED_PRICE
                    , PoLineMergeEO.LIST_PRICE_PER_UNIT
                    , PoLineMergeEO.UNIT_PRICE
                    , PoLineMergeEO.QUANTITY
                    , PoLineMergeEO.UN_NUMBER_ID
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE_CATEGORY
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE1
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE2
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE3
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE4
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE5
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE6
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE7
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE8
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE9
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE10
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE11
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE12
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE13
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE14
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE15
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE16
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE17
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE18
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE19
                    , PoLineMergeEO.GLOBAL_ATTRIBUTE20
                    , PoLineMergeEO.LINE_REFERENCE_NUM
                    , PoLineMergeEO.PROJECT_ID
                    , PoLineMergeEO.TASK_ID
                    , PoLineMergeEO.EXPIRATION_DATE
                    , PoLineMergeEO.TAX_CODE_ID
                    , PoLineMergeEO.OKE_CONTRACT_HEADER_ID
                    , PoLineMergeEO.OKE_CONTRACT_VERSION_ID
                    , PoLineMergeEO.TAX_NAME
                    , PoLineMergeEO.SECONDARY_UNIT_OF_MEASURE
                    , PoLineMergeEO.SECONDARY_QUANTITY
                    , PoLineMergeEO.PREFERRED_GRADE
                    , PoLineMergeEO.AUCTION_HEADER_ID
                    , PoLineMergeEO.AUCTION_DISPLAY_NUMBER
                    , PoLineMergeEO.AUCTION_LINE_NUMBER
                    , PoLineMergeEO.BID_NUMBER
                    , PoLineMergeEO.BID_LINE_NUMBER
                    , PoLineMergeEO.RETROACTIVE_DATE
                    , PoLineMergeEO.SUPPLIER_REF_NUMBER
                    , PoLineMergeEO.CONTRACT_ID
                    , PoLineMergeEO.JOB_ID
                    , PoLineMergeEO.AMOUNT
                    , PoLineMergeEO.START_DATE
                    , PoLineMergeEO.CONTRACTOR_FIRST_NAME
                    , PoLineMergeEO.CONTRACTOR_LAST_NAME
                    , PoLineMergeEO.ORDER_TYPE_LOOKUP_CODE
                    , PoLineMergeEO.PURCHASE_BASIS
                    , PoLineMergeEO.MATCHING_BASIS
                    , PoLineMergeEO.SVC_AMOUNT_NOTIF_SENT
                    , PoLineMergeEO.SVC_COMPLETION_NOTIF_SENT
                    , PoLineMergeEO.FROM_LINE_LOCATION_ID
                    , PoLineMergeEO.BASE_UNIT_PRICE
                    , PoLineMergeEO.MANUAL_PRICE_CHANGE_FLAG
                    , PoLineMergeEO.RETAINAGE_RATE
                    , PoLineMergeEO.MAX_RETAINAGE_AMOUNT
                    , PoLineMergeEO.PROGRESS_PAYMENT_RATE
                    , PoLineMergeEO.RECOUPMENT_RATE
                    , PoLineMergeEO.SUPPLIER_PART_AUXID
                    , PoLineMergeEO.IP_CATEGORY_ID
                    , PoLineMergeEO.TAX_ATTRIBUTE_UPDATE_CODE
                    , plt.LINE_TYPE
                    , mc.SEGMENT1                                     category
                    , mc.SEGMENT2                                     subcategory
                    , mc.SEGMENT1||'.'||mc.SEGMENT2                   category_subcategory
               FROM PO_LINES_MERGE_V PoLineMergeEO
                  , po_line_types    plt
                  , mtl_categories   mc
              WHERE plt.LINE_TYPE_ID (+) = PoLineMergeEO.LINE_TYPE_ID
                AND mc.CATEGORY_ID(+) = PoLineMergeEO.CATEGORY_ID
             )
    LOOP

        INSERT INTO XXBI_SRC_AGREEMENT_LINES
             (
               DRAFT_ID
             , CHANGE_ACCEPTED_FLAG
             , DELETE_FLAG
             , ATTRIBUTE9
             , ATTRIBUTE10
             , REFERENCE_NUM
             , ATTRIBUTE11
             , ATTRIBUTE12
             , ATTRIBUTE13
             , ATTRIBUTE14
             , ATTRIBUTE15
             , MIN_RELEASE_AMOUNT
             , PRICE_TYPE_LOOKUP_CODE
             , CLOSED_CODE
             , PRICE_BREAK_LOOKUP_CODE
             , USSGL_TRANSACTION_CODE
             , GOVERNMENT_CONTEXT
             , REQUEST_ID
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , PROGRAM_UPDATE_DATE
             , CLOSED_DATE
             , CLOSED_REASON
             , CLOSED_BY
             , TRANSACTION_REASON_CODE
             , ORG_ID
             , HAZARD_CLASS_ID
             , NOTE_TO_VENDOR
             , FROM_HEADER_ID
             , FROM_LINE_ID
             , MIN_ORDER_QUANTITY
             , MAX_ORDER_QUANTITY
             , QTY_RCV_TOLERANCE
             , OVER_TOLERANCE_ERROR_FLAG
             , MARKET_PRICE
             , UNORDERED_FLAG
             , CLOSED_FLAG
             , USER_HOLD_FLAG
             , CANCEL_FLAG
             , CANCELLED_BY
             , CANCEL_DATE
             , CANCEL_REASON
             , FIRM_STATUS_LOOKUP_CODE
             , FIRM_DATE
             , VENDOR_PRODUCT_NUM
             , CONTRACT_NUM
             , TAXABLE_FLAG
             , TYPE_1099
             , CAPITAL_EXPENSE_FLAG
             , NEGOTIATED_BY_PREPARER_FLAG
             , ATTRIBUTE_CATEGORY
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , QC_GRADE
             , BASE_UOM
             , BASE_QTY
             , SECONDARY_UOM
             , SECONDARY_QTY
             , PO_LINE_ID
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , PO_HEADER_ID
             , LINE_TYPE_ID
             , LINE_NUM
             , LAST_UPDATE_LOGIN
             , CREATION_DATE
             , CREATED_BY
             , ITEM_ID
             , ITEM_REVISION
             , CATEGORY_ID
             , ITEM_DESCRIPTION
             , UNIT_MEAS_LOOKUP_CODE
             , QUANTITY_COMMITTED
             , COMMITTED_AMOUNT
             , ALLOW_PRICE_OVERRIDE_FLAG
             , NOT_TO_EXCEED_PRICE
             , LIST_PRICE_PER_UNIT
             , UNIT_PRICE
             , QUANTITY
             , UN_NUMBER_ID
             , GLOBAL_ATTRIBUTE_CATEGORY
             , GLOBAL_ATTRIBUTE1
             , GLOBAL_ATTRIBUTE2
             , GLOBAL_ATTRIBUTE3
             , GLOBAL_ATTRIBUTE4
             , GLOBAL_ATTRIBUTE5
             , GLOBAL_ATTRIBUTE6
             , GLOBAL_ATTRIBUTE7
             , GLOBAL_ATTRIBUTE8
             , GLOBAL_ATTRIBUTE9
             , GLOBAL_ATTRIBUTE10
             , GLOBAL_ATTRIBUTE11
             , GLOBAL_ATTRIBUTE12
             , GLOBAL_ATTRIBUTE13
             , GLOBAL_ATTRIBUTE14
             , GLOBAL_ATTRIBUTE15
             , GLOBAL_ATTRIBUTE16
             , GLOBAL_ATTRIBUTE17
             , GLOBAL_ATTRIBUTE18
             , GLOBAL_ATTRIBUTE19
             , GLOBAL_ATTRIBUTE20
             , LINE_REFERENCE_NUM
             , PROJECT_ID
             , TASK_ID
             , EXPIRATION_DATE
             , TAX_CODE_ID
             , OKE_CONTRACT_HEADER_ID
             , OKE_CONTRACT_VERSION_ID
             , TAX_NAME
             , SECONDARY_UNIT_OF_MEASURE
             , SECONDARY_QUANTITY
             , PREFERRED_GRADE
             , AUCTION_HEADER_ID
             , AUCTION_DISPLAY_NUMBER
             , AUCTION_LINE_NUMBER
             , BID_NUMBER
             , BID_LINE_NUMBER
             , RETROACTIVE_DATE
             , SUPPLIER_REF_NUMBER
             , CONTRACT_ID
             , JOB_ID
             , AMOUNT
             , START_DATE
             , CONTRACTOR_FIRST_NAME
             , CONTRACTOR_LAST_NAME
             , ORDER_TYPE_LOOKUP_CODE
             , PURCHASE_BASIS
             , MATCHING_BASIS
             , SVC_AMOUNT_NOTIF_SENT
             , SVC_COMPLETION_NOTIF_SENT
             , FROM_LINE_LOCATION_ID
             , BASE_UNIT_PRICE
             , MANUAL_PRICE_CHANGE_FLAG
             , RETAINAGE_RATE
             , MAX_RETAINAGE_AMOUNT
             , PROGRESS_PAYMENT_RATE
             , RECOUPMENT_RATE
             , SUPPLIER_PART_AUXID
             , IP_CATEGORY_ID
             , TAX_ATTRIBUTE_UPDATE_CODE
             , LINE_TYPE
             , CATEGORY
             , SUBCATEGORY
             , CATEGORY_SUBCATEGORY
             )
        VALUES
             (
               I.DRAFT_ID
             , I.CHANGE_ACCEPTED_FLAG
             , I.DELETE_FLAG
             , I.ATTRIBUTE9
             , I.ATTRIBUTE10
             , I.REFERENCE_NUM
             , I.ATTRIBUTE11
             , I.ATTRIBUTE12
             , I.ATTRIBUTE13
             , I.ATTRIBUTE14
             , I.ATTRIBUTE15
             , I.MIN_RELEASE_AMOUNT
             , I.PRICE_TYPE_LOOKUP_CODE
             , I.CLOSED_CODE
             , I.PRICE_BREAK_LOOKUP_CODE
             , I.USSGL_TRANSACTION_CODE
             , I.GOVERNMENT_CONTEXT
             , I.REQUEST_ID
             , I.PROGRAM_APPLICATION_ID
             , I.PROGRAM_ID
             , I.PROGRAM_UPDATE_DATE
             , I.CLOSED_DATE
             , I.CLOSED_REASON
             , I.CLOSED_BY
             , I.TRANSACTION_REASON_CODE
             , I.ORG_ID
             , I.HAZARD_CLASS_ID
             , I.NOTE_TO_VENDOR
             , I.FROM_HEADER_ID
             , I.FROM_LINE_ID
             , I.MIN_ORDER_QUANTITY
             , I.MAX_ORDER_QUANTITY
             , I.QTY_RCV_TOLERANCE
             , I.OVER_TOLERANCE_ERROR_FLAG
             , I.MARKET_PRICE
             , I.UNORDERED_FLAG
             , I.CLOSED_FLAG
             , I.USER_HOLD_FLAG
             , I.CANCEL_FLAG
             , I.CANCELLED_BY
             , I.CANCEL_DATE
             , I.CANCEL_REASON
             , I.FIRM_STATUS_LOOKUP_CODE
             , I.FIRM_DATE
             , I.VENDOR_PRODUCT_NUM
             , I.CONTRACT_NUM
             , I.TAXABLE_FLAG
             , I.TYPE_1099
             , I.CAPITAL_EXPENSE_FLAG
             , I.NEGOTIATED_BY_PREPARER_FLAG
             , I.ATTRIBUTE_CATEGORY
             , I.ATTRIBUTE1
             , I.ATTRIBUTE2
             , I.ATTRIBUTE3
             , I.ATTRIBUTE4
             , I.ATTRIBUTE5
             , I.ATTRIBUTE6
             , I.ATTRIBUTE7
             , I.ATTRIBUTE8
             , I.QC_GRADE
             , I.BASE_UOM
             , I.BASE_QTY
             , I.SECONDARY_UOM
             , I.SECONDARY_QTY
             , I.PO_LINE_ID
             , I.LAST_UPDATE_DATE
             , I.LAST_UPDATED_BY
             , I.PO_HEADER_ID
             , I.LINE_TYPE_ID
             , I.LINE_NUM
             , I.LAST_UPDATE_LOGIN
             , I.CREATION_DATE
             , I.CREATED_BY
             , I.ITEM_ID
             , I.ITEM_REVISION
             , I.CATEGORY_ID
             , I.ITEM_DESCRIPTION
             , I.UNIT_MEAS_LOOKUP_CODE
             , I.QUANTITY_COMMITTED
             , I.COMMITTED_AMOUNT
             , I.ALLOW_PRICE_OVERRIDE_FLAG
             , I.NOT_TO_EXCEED_PRICE
             , I.LIST_PRICE_PER_UNIT
             , I.UNIT_PRICE
             , I.QUANTITY
             , I.UN_NUMBER_ID
             , I.GLOBAL_ATTRIBUTE_CATEGORY
             , I.GLOBAL_ATTRIBUTE1
             , I.GLOBAL_ATTRIBUTE2
             , I.GLOBAL_ATTRIBUTE3
             , I.GLOBAL_ATTRIBUTE4
             , I.GLOBAL_ATTRIBUTE5
             , I.GLOBAL_ATTRIBUTE6
             , I.GLOBAL_ATTRIBUTE7
             , I.GLOBAL_ATTRIBUTE8
             , I.GLOBAL_ATTRIBUTE9
             , I.GLOBAL_ATTRIBUTE10
             , I.GLOBAL_ATTRIBUTE11
             , I.GLOBAL_ATTRIBUTE12
             , I.GLOBAL_ATTRIBUTE13
             , I.GLOBAL_ATTRIBUTE14
             , I.GLOBAL_ATTRIBUTE15
             , I.GLOBAL_ATTRIBUTE16
             , I.GLOBAL_ATTRIBUTE17
             , I.GLOBAL_ATTRIBUTE18
             , I.GLOBAL_ATTRIBUTE19
             , I.GLOBAL_ATTRIBUTE20
             , I.LINE_REFERENCE_NUM
             , I.PROJECT_ID
             , I.TASK_ID
             , I.EXPIRATION_DATE
             , I.TAX_CODE_ID
             , I.OKE_CONTRACT_HEADER_ID
             , I.OKE_CONTRACT_VERSION_ID
             , I.TAX_NAME
             , I.SECONDARY_UNIT_OF_MEASURE
             , I.SECONDARY_QUANTITY
             , I.PREFERRED_GRADE
             , I.AUCTION_HEADER_ID
             , I.AUCTION_DISPLAY_NUMBER
             , I.AUCTION_LINE_NUMBER
             , I.BID_NUMBER
             , I.BID_LINE_NUMBER
             , I.RETROACTIVE_DATE
             , I.SUPPLIER_REF_NUMBER
             , I.CONTRACT_ID
             , I.JOB_ID
             , I.AMOUNT
             , I.START_DATE
             , I.CONTRACTOR_FIRST_NAME
             , I.CONTRACTOR_LAST_NAME
             , I.ORDER_TYPE_LOOKUP_CODE
             , I.PURCHASE_BASIS
             , I.MATCHING_BASIS
             , I.SVC_AMOUNT_NOTIF_SENT
             , I.SVC_COMPLETION_NOTIF_SENT
             , I.FROM_LINE_LOCATION_ID
             , I.BASE_UNIT_PRICE
             , I.MANUAL_PRICE_CHANGE_FLAG
             , I.RETAINAGE_RATE
             , I.MAX_RETAINAGE_AMOUNT
             , I.PROGRESS_PAYMENT_RATE
             , I.RECOUPMENT_RATE
             , I.SUPPLIER_PART_AUXID
             , I.IP_CATEGORY_ID
             , I.TAX_ATTRIBUTE_UPDATE_CODE
             , I.LINE_TYPE
             , I.CATEGORY
             , I.SUBCATEGORY
             , I.CATEGORY_SUBCATEGORY
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_AGREEMENT_LINES', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_NEGOTIATIONS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_NEGOTIATIONS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_NEGOTIATIONS';

    FOR I IN (
               SELECT ah.sealed_auction_status
                    , ah.sealed_actual_unlock_date
                    , ah.sealed_actual_unseal_date
                    , ah.sealed_unlock_tp_contact_id
                    , ah.sealed_unseal_tp_contact_id
                    , ah.share_award_decision
                    , ah.auction_header_id
                    , ah.auction_title
                    , ah.trading_partner_contact_id
                    , ah.doctype_id
                    , fl_security.meaning security_level
                    , fl_style.meaning auction_style
                    , fl_bid_ranking.meaning bid_ranking_display
                    , ah.bid_ranking
                    , ah.show_bidder_scores
                    , haou.name org_name
                    , ah.contract_type
                    , ah.event_title
                    , ah.approval_status
                    , ah.negotiation_status
                    , ah.currency_code currency_code
                    , ah.number_price_decimals
                    , loc_bill.location_code bill_to_address
                    , loc_ship.location_code ship_to_address
                    , ap.name                                                   payment_terms
                    , fl_fob.meaning                                            fob
                    , fl_freight_terms.meaning                                  freight_terms
                    , ah.open_bidding_date
                    , ah.close_bidding_date
                    , ah.award_by_date
                    , ah.view_by_date
                    , ah.manual_close_flag
                    , ah.manual_extend_flag
                    , ah.auto_extend_flag
                    , ah.auto_extend_number
                    , NVL(ah.auto_extend_duration, 20)                          auto_extend_duration
                    , ah.note_to_bidders
                    , ah.auto_extend_all_lines_flag
                    , ah.auto_extend_type_flag
                    , ah.bid_list_type
                    , ah.show_bidder_notes
                    , fl_rank_ind.meaning                                       rank_indicator_display
                    , ah.bid_scope_code
                    , ah.full_quantity_bid_code
                    , ah.bid_frequency_code
                    , ah.multiple_rounds_flag
                    , ah.price_driven_auction_flag
                    , ah.min_bid_decrement
                    , ah.min_bid_change_type
                    , ah.rate_type
                    , ah.rate_date
                    , NVL(gdct.description, gdct.user_conversion_type)          rate_type_display
                    , ah.po_agreed_amount                                       po_agreed_amount
                    , ah.po_min_rel_amount                                      po_min_rel_amount
                    , ah.po_start_date
                    , ah.po_end_date
                    , ah.global_agreement_flag
                    , fc.precision                                              fnd_precision
                    , ah.currency_code                                          auc_currency_code
                    , fl_status.meaning                                         negotiation_status_display
                    , fl_sealed_status.meaning                                  sealed_status_display
                    , ah.trading_partner_id
                    , ah.bid_visibility_code
                    , ah.award_status
                    , ah.outcome_status
                    , ah.security_level_code
                    , ah.auction_round_number
                    , ah.auction_status
                    , ah.trading_partner_name
                    , ah.trading_partner_contact_name
                    , ah.auction_origination_code
                    , ah.allow_other_bid_currency_flag
                    , ah.publish_rates_to_bidders_flag
                    , ah.attachment_flag
                    , 'N' is_template_flag
                    , ah.document_number
                    , ah.ship_to_location_id
                    , ah.bill_to_location_id
                    , fpg.multi_org_flag
                    , ah.org_id
                    , ah.source_doc_number
                    , ah.source_doc_msg
                    , ah.source_doc_msg_app
                    , NVL(ah.award_approval_flag, 'N')                          award_approval_flag
                    , NVL(ah.award_approval_status, 'NOT_REQUIRED')             award_approval_status
                    , ah.publish_date
                    , ah.AMENDMENT_NUMBER
                    , ah.AMENDMENT_DESCRIPTION
                    , ah.AUCTION_HEADER_ID_ORIG_AMEND
                    , ah.AUCTION_HEADER_ID_PREV_AMEND
                    , ah.derive_type
                    , ah.HDR_ATTR_DISPLAY_SCORE
                    , ah.ATTRIBUTE_LINE_NUMBER
                    , ah.HDR_ATTR_ENABLE_WEIGHTS
                    , ah.conterms_exist_flag
                    , ah.source_doc_line_msg
                    , ah.has_hdr_attr_flag
                    , ah.pause_remarks
                    , ah.event_id
                    , ah.pf_type_allowed
                    , ah.supplier_view_type
                    , ah.has_items_flag
                    , ah.currency_code auction_currency_code
                    , ah.number_price_decimals                                  auction_precision
                    , fc.precision                                              auction_fnd_precision
                    , ah.abstract_status
                    , ah.INCLUDE_PDF_IN_EXTERNAL_PAGE
                    , ah.ABSTRACT_DETAILS
                    , ah.team_scoring_enabled_flag
                    , ah.has_scoring_teams_flag
                    , ah.scoring_lock_date
                    , ah.scoring_lock_tp_contact_id
                    , ah.neg_team_enabled_flag
                    , ah.price_element_enabled_flag
                    , ah.hdr_attribute_enabled_flag
                    , ns.style_name
                    , ah.rfi_line_enabled_flag
                    , ah.large_neg_enabled_flag
                    , ah.NUMBER_OF_LINES
                    , ah.PROGRESS_PAYMENT_TYPE
                    , ah.ADVANCE_NEGOTIABLE_FLAG
                    , ah.RECOUPMENT_NEGOTIABLE_FLAG
                    , ah.PROGRESS_PYMT_NEGOTIABLE_FLAG
                    , ah.RETAINAGE_NEGOTIABLE_FLAG
                    , ah.MAX_RETAINAGE_NEGOTIABLE_FLAG
                    , ah.SUPPLIER_ENTERABLE_PYMT_FLAG
                    , ah.PROJECT_ID
                    , pa.segment1                                               Sourcing_Project_Number
                    , BID_DECREMENT_METHOD
                    , ah.AUTO_EXTEND_ENABLED_FLAG
                    , ah.last_line_number
                    , ah.STAGGERED_CLOSING_INTERVAL
                    , ah.FIRST_LINE_CLOSE_DATE
                    , nvl2(ah.staggered_closing_interval, 'Y', 'N')             STAGGERED_CLOSING_ENABLED_FLAG
                    , ah.display_best_price_blind_flag
                    , NVL(ah.ENFORCE_PREVRND_BID_PRICE_FLAG, 'N')               ENFORCE_PREVRND_BID_PRICE_FLAG
                    , ah.AUCTION_HEADER_ID_PREV_ROUND
                    , ah.auto_extend_min_trigger_rank
                    , 'PON_BID_HEADERS'                                         which_attach
                    , 'EBS'                                                     used_by
                    , TRUNC(ah.open_bidding_date)                               open_bidding_date_trunc
                    , TRUNC(ah.close_bidding_date)                              close_bidding_date_trunc
                    , fl.meaning                                                outcome
                    , ah.NUMBER_OF_BIDS
                    , ah.CREATED_BY
               FROM pon_auction_headers_all_v       ah
                  , fnd_lookups                     fl_style
                  , fnd_lookups                     fl_security
                  , fnd_lookups                     fl_bid_ranking
                  , hr_all_organization_units_tl    haou
                  , hr_locations_all_tl             loc_bill
                  , hr_locations_all_tl             loc_ship
                  , fnd_lookup_values               fl_fob
                  , fnd_lookup_values               fl_freight_terms
                  , ap_terms                        ap
                  , fnd_lookups                     fl_rank_ind
                  , gl_daily_conversion_types       gdct
                  , fnd_currencies                  fc
                  , fnd_product_groups              fpg
                  , fnd_lookups                     fl_status
                  , fnd_lookups                     fl_status_supplier
                  , fnd_lookups                     fl_sealed_status
                  , pon_negotiation_styles_vl       ns
                  , pa_projects_all                 pa
                  , fnd_lookups                     fl
              WHERE fl_style.lookup_type                    = 'PON_BID_VISIBILITY_CODE'
                AND fl_style.lookup_code                    = ah.bid_visibility_code
                AND fl_status.lookup_type                   = 'PON_AUCTION_STATUS'
                AND fl_status.lookup_code                   = ah.negotiation_status
                AND fl_status_supplier.lookup_type          = 'PON_AUCTION_STATUS'
                AND fl_status_supplier.lookup_code          = ah.suppl_negotiation_status
                AND fl_security.lookup_type                 = 'PON_SECURITY_LEVEL_CODE'
                AND fl_security.lookup_code                 = ah.security_level_code
                AND fl_bid_ranking.lookup_type              = 'PON_BID_RANKING_CODE'
                AND fl_bid_ranking.lookup_code              = ah.bid_ranking
                AND fl_rank_ind.lookup_type                 = 'PON_RANK_INDICATOR_CODE'
                AND fl_rank_ind.lookup_code                 = ah.rank_indicator
                AND fl_sealed_status.lookup_type(+)         = 'PON_SEALED_AUCTION_STATUS'
                AND fl_sealed_status.lookup_code(+)         = ah.sealed_auction_status
                AND haou.organization_id(+)                 = ah.org_id
                AND haou.language(+)                        = userenv('LANG')
                AND loc_bill.location_id(+)                 = ah.bill_to_location_id
                AND loc_bill.language(+)                    = userenv('LANG')
                AND loc_ship.location_id(+)                 = ah.ship_to_location_id
                AND loc_ship.language(+)                    = userenv('LANG')
                AND ap.term_id(+)                           = ah.payment_terms_id
                AND fl_fob.lookup_type(+)                   = 'FOB'
                AND fl_fob.lookup_code(+)                   = ah.fob_code
                AND fl_fob.language(+)                      = userenv('LANG')
                AND fl_fob.view_application_id(+)           = 201
                AND fl_fob.security_group_id(+)             = 0
                AND fl_freight_terms.lookup_type(+)         = 'FREIGHT TERMS'
                AND fl_freight_terms.lookup_code(+)         = ah.freight_terms_code
                AND fl_freight_terms.language(+)            = userenv('LANG')
                AND fl_freight_terms.view_application_id(+) = 201
                AND fl_freight_terms.security_group_id(+)   = 0
                AND gdct.conversion_type(+)                 = ah.rate_type
                AND fc.currency_code                        = ah.currency_code
                AND ah.style_id                             = ns.style_id
                AND ah.project_id                           = pa.project_id(+)
                AND fl.lookup_type(+)                       = 'PON_CONTRACT_TYPE'
                AND fl.lookup_code(+)                       = ah.contract_type
             )
    LOOP

        INSERT INTO XXBI_SRC_NEGOTIATIONS
             (
               SEALED_AUCTION_STATUS
             , SEALED_ACTUAL_UNLOCK_DATE
             , SEALED_ACTUAL_UNSEAL_DATE
             , SEALED_UNLOCK_TP_CONTACT_ID
             , SEALED_UNSEAL_TP_CONTACT_ID
             , SHARE_AWARD_DECISION
             , AUCTION_HEADER_ID
             , AUCTION_TITLE
             , TRADING_PARTNER_CONTACT_ID
             , DOCTYPE_ID
             , SECURITY_LEVEL
             , AUCTION_STYLE
             , BID_RANKING_DISPLAY
             , BID_RANKING
             , SHOW_BIDDER_SCORES
             , ORG_NAME
             , CONTRACT_TYPE
             , EVENT_TITLE
             , APPROVAL_STATUS
             , NEGOTIATION_STATUS
             , CURRENCY_CODE
             , NUMBER_PRICE_DECIMALS
             , BILL_TO_ADDRESS
             , SHIP_TO_ADDRESS
             , PAYMENT_TERMS
             , FOB
             , FREIGHT_TERMS
             , OPEN_BIDDING_DATE
             , CLOSE_BIDDING_DATE
             , AWARD_BY_DATE
             , VIEW_BY_DATE
             , MANUAL_CLOSE_FLAG
             , MANUAL_EXTEND_FLAG
             , AUTO_EXTEND_FLAG
             , AUTO_EXTEND_NUMBER
             , AUTO_EXTEND_DURATION
             , NOTE_TO_BIDDERS
             , AUTO_EXTEND_ALL_LINES_FLAG
             , AUTO_EXTEND_TYPE_FLAG
             , BID_LIST_TYPE
             , SHOW_BIDDER_NOTES
             , RANK_INDICATOR_DISPLAY
             , BID_SCOPE_CODE
             , FULL_QUANTITY_BID_CODE
             , BID_FREQUENCY_CODE
             , MULTIPLE_ROUNDS_FLAG
             , PRICE_DRIVEN_AUCTION_FLAG
             , MIN_BID_DECREMENT
             , MIN_BID_CHANGE_TYPE
             , RATE_TYPE
             , RATE_DATE
             , RATE_TYPE_DISPLAY
             , PO_AGREED_AMOUNT
             , PO_MIN_REL_AMOUNT
             , PO_START_DATE
             , PO_END_DATE
             , GLOBAL_AGREEMENT_FLAG
             , FND_PRECISION
             , AUC_CURRENCY_CODE
             , NEGOTIATION_STATUS_DISPLAY
             , SEALED_STATUS_DISPLAY
             , TRADING_PARTNER_ID
             , BID_VISIBILITY_CODE
             , AWARD_STATUS
             , OUTCOME_STATUS
             , SECURITY_LEVEL_CODE
             , AUCTION_ROUND_NUMBER
             , AUCTION_STATUS
             , TRADING_PARTNER_NAME
             , TRADING_PARTNER_CONTACT_NAME
             , AUCTION_ORIGINATION_CODE
             , ALLOW_OTHER_BID_CURRENCY_FLAG
             , PUBLISH_RATES_TO_BIDDERS_FLAG
             , ATTACHMENT_FLAG
             , IS_TEMPLATE_FLAG
             , DOCUMENT_NUMBER
             , SHIP_TO_LOCATION_ID
             , BILL_TO_LOCATION_ID
             , MULTI_ORG_FLAG
             , ORG_ID
             , SOURCE_DOC_NUMBER
             , SOURCE_DOC_MSG
             , SOURCE_DOC_MSG_APP
             , AWARD_APPROVAL_FLAG
             , AWARD_APPROVAL_STATUS
             , PUBLISH_DATE
             , AMENDMENT_NUMBER
             , AMENDMENT_DESCRIPTION
             , AUCTION_HEADER_ID_ORIG_AMEND
             , AUCTION_HEADER_ID_PREV_AMEND
             , DERIVE_TYPE
             , HDR_ATTR_DISPLAY_SCORE
             , ATTRIBUTE_LINE_NUMBER
             , HDR_ATTR_ENABLE_WEIGHTS
             , CONTERMS_EXIST_FLAG
             , SOURCE_DOC_LINE_MSG
             , HAS_HDR_ATTR_FLAG
             , PAUSE_REMARKS
             , EVENT_ID
             , PF_TYPE_ALLOWED
             , SUPPLIER_VIEW_TYPE
             , HAS_ITEMS_FLAG
             , AUCTION_CURRENCY_CODE
             , AUCTION_PRECISION
             , AUCTION_FND_PRECISION
             , ABSTRACT_STATUS
             , INCLUDE_PDF_IN_EXTERNAL_PAGE
             , ABSTRACT_DETAILS
             , TEAM_SCORING_ENABLED_FLAG
             , HAS_SCORING_TEAMS_FLAG
             , SCORING_LOCK_DATE
             , SCORING_LOCK_TP_CONTACT_ID
             , NEG_TEAM_ENABLED_FLAG
             , PRICE_ELEMENT_ENABLED_FLAG
             , HDR_ATTRIBUTE_ENABLED_FLAG
             , STYLE_NAME
             , RFI_LINE_ENABLED_FLAG
             , LARGE_NEG_ENABLED_FLAG
             , NUMBER_OF_LINES
             , PROGRESS_PAYMENT_TYPE
             , ADVANCE_NEGOTIABLE_FLAG
             , RECOUPMENT_NEGOTIABLE_FLAG
             , PROGRESS_PYMT_NEGOTIABLE_FLAG
             , RETAINAGE_NEGOTIABLE_FLAG
             , MAX_RETAINAGE_NEGOTIABLE_FLAG
             , SUPPLIER_ENTERABLE_PYMT_FLAG
             , PROJECT_ID
             , SOURCING_PROJECT_NUMBER
             , BID_DECREMENT_METHOD
             , AUTO_EXTEND_ENABLED_FLAG
             , LAST_LINE_NUMBER
             , STAGGERED_CLOSING_INTERVAL
             , FIRST_LINE_CLOSE_DATE
             , STAGGERED_CLOSING_ENABLED_FLAG
             , DISPLAY_BEST_PRICE_BLIND_FLAG
             , ENFORCE_PREVRND_BID_PRICE_FLAG
             , AUCTION_HEADER_ID_PREV_ROUND
             , AUTO_EXTEND_MIN_TRIGGER_RANK
             , WHICH_ATTACH
             , USED_BY
             , OPEN_BIDDING_DATE_TRUNC
             , CLOSE_BIDDING_DATE_TRUNC
             , OUTCOME
             , NUMBER_OF_BIDS
             , CREATED_BY
             )
        VALUES
             (
               I.SEALED_AUCTION_STATUS
             , I.SEALED_ACTUAL_UNLOCK_DATE
             , I.SEALED_ACTUAL_UNSEAL_DATE
             , I.SEALED_UNLOCK_TP_CONTACT_ID
             , I.SEALED_UNSEAL_TP_CONTACT_ID
             , I.SHARE_AWARD_DECISION
             , I.AUCTION_HEADER_ID
             , I.AUCTION_TITLE
             , I.TRADING_PARTNER_CONTACT_ID
             , I.DOCTYPE_ID
             , I.SECURITY_LEVEL
             , I.AUCTION_STYLE
             , I.BID_RANKING_DISPLAY
             , I.BID_RANKING
             , I.SHOW_BIDDER_SCORES
             , I.ORG_NAME
             , I.CONTRACT_TYPE
             , I.EVENT_TITLE
             , I.APPROVAL_STATUS
             , I.NEGOTIATION_STATUS
             , I.CURRENCY_CODE
             , I.NUMBER_PRICE_DECIMALS
             , I.BILL_TO_ADDRESS
             , I.SHIP_TO_ADDRESS
             , I.PAYMENT_TERMS
             , I.FOB
             , I.FREIGHT_TERMS
             , I.OPEN_BIDDING_DATE
             , I.CLOSE_BIDDING_DATE
             , I.AWARD_BY_DATE
             , I.VIEW_BY_DATE
             , I.MANUAL_CLOSE_FLAG
             , I.MANUAL_EXTEND_FLAG
             , I.AUTO_EXTEND_FLAG
             , I.AUTO_EXTEND_NUMBER
             , I.AUTO_EXTEND_DURATION
             , I.NOTE_TO_BIDDERS
             , I.AUTO_EXTEND_ALL_LINES_FLAG
             , I.AUTO_EXTEND_TYPE_FLAG
             , I.BID_LIST_TYPE
             , I.SHOW_BIDDER_NOTES
             , I.RANK_INDICATOR_DISPLAY
             , I.BID_SCOPE_CODE
             , I.FULL_QUANTITY_BID_CODE
             , I.BID_FREQUENCY_CODE
             , I.MULTIPLE_ROUNDS_FLAG
             , I.PRICE_DRIVEN_AUCTION_FLAG
             , I.MIN_BID_DECREMENT
             , I.MIN_BID_CHANGE_TYPE
             , I.RATE_TYPE
             , I.RATE_DATE
             , I.RATE_TYPE_DISPLAY
             , I.PO_AGREED_AMOUNT
             , I.PO_MIN_REL_AMOUNT
             , I.PO_START_DATE
             , I.PO_END_DATE
             , I.GLOBAL_AGREEMENT_FLAG
             , I.FND_PRECISION
             , I.AUC_CURRENCY_CODE
             , I.NEGOTIATION_STATUS_DISPLAY
             , I.SEALED_STATUS_DISPLAY
             , I.TRADING_PARTNER_ID
             , I.BID_VISIBILITY_CODE
             , I.AWARD_STATUS
             , I.OUTCOME_STATUS
             , I.SECURITY_LEVEL_CODE
             , I.AUCTION_ROUND_NUMBER
             , I.AUCTION_STATUS
             , I.TRADING_PARTNER_NAME
             , I.TRADING_PARTNER_CONTACT_NAME
             , I.AUCTION_ORIGINATION_CODE
             , I.ALLOW_OTHER_BID_CURRENCY_FLAG
             , I.PUBLISH_RATES_TO_BIDDERS_FLAG
             , I.ATTACHMENT_FLAG
             , I.IS_TEMPLATE_FLAG
             , I.DOCUMENT_NUMBER
             , I.SHIP_TO_LOCATION_ID
             , I.BILL_TO_LOCATION_ID
             , I.MULTI_ORG_FLAG
             , I.ORG_ID
             , I.SOURCE_DOC_NUMBER
             , I.SOURCE_DOC_MSG
             , I.SOURCE_DOC_MSG_APP
             , I.AWARD_APPROVAL_FLAG
             , I.AWARD_APPROVAL_STATUS
             , I.PUBLISH_DATE
             , I.AMENDMENT_NUMBER
             , I.AMENDMENT_DESCRIPTION
             , I.AUCTION_HEADER_ID_ORIG_AMEND
             , I.AUCTION_HEADER_ID_PREV_AMEND
             , I.DERIVE_TYPE
             , I.HDR_ATTR_DISPLAY_SCORE
             , I.ATTRIBUTE_LINE_NUMBER
             , I.HDR_ATTR_ENABLE_WEIGHTS
             , I.CONTERMS_EXIST_FLAG
             , I.SOURCE_DOC_LINE_MSG
             , I.HAS_HDR_ATTR_FLAG
             , I.PAUSE_REMARKS
             , I.EVENT_ID
             , I.PF_TYPE_ALLOWED
             , I.SUPPLIER_VIEW_TYPE
             , I.HAS_ITEMS_FLAG
             , I.AUCTION_CURRENCY_CODE
             , I.AUCTION_PRECISION
             , I.AUCTION_FND_PRECISION
             , I.ABSTRACT_STATUS
             , I.INCLUDE_PDF_IN_EXTERNAL_PAGE
             , I.ABSTRACT_DETAILS
             , I.TEAM_SCORING_ENABLED_FLAG
             , I.HAS_SCORING_TEAMS_FLAG
             , I.SCORING_LOCK_DATE
             , I.SCORING_LOCK_TP_CONTACT_ID
             , I.NEG_TEAM_ENABLED_FLAG
             , I.PRICE_ELEMENT_ENABLED_FLAG
             , I.HDR_ATTRIBUTE_ENABLED_FLAG
             , I.STYLE_NAME
             , I.RFI_LINE_ENABLED_FLAG
             , I.LARGE_NEG_ENABLED_FLAG
             , I.NUMBER_OF_LINES
             , I.PROGRESS_PAYMENT_TYPE
             , I.ADVANCE_NEGOTIABLE_FLAG
             , I.RECOUPMENT_NEGOTIABLE_FLAG
             , I.PROGRESS_PYMT_NEGOTIABLE_FLAG
             , I.RETAINAGE_NEGOTIABLE_FLAG
             , I.MAX_RETAINAGE_NEGOTIABLE_FLAG
             , I.SUPPLIER_ENTERABLE_PYMT_FLAG
             , I.PROJECT_ID
             , I.SOURCING_PROJECT_NUMBER
             , I.BID_DECREMENT_METHOD
             , I.AUTO_EXTEND_ENABLED_FLAG
             , I.LAST_LINE_NUMBER
             , I.STAGGERED_CLOSING_INTERVAL
             , I.FIRST_LINE_CLOSE_DATE
             , I.STAGGERED_CLOSING_ENABLED_FLAG
             , I.DISPLAY_BEST_PRICE_BLIND_FLAG
             , I.ENFORCE_PREVRND_BID_PRICE_FLAG
             , I.AUCTION_HEADER_ID_PREV_ROUND
             , I.AUTO_EXTEND_MIN_TRIGGER_RANK
             , I.WHICH_ATTACH
             , I.USED_BY
             , I.OPEN_BIDDING_DATE_TRUNC
             , I.CLOSE_BIDDING_DATE_TRUNC
             , I.OUTCOME
             , I.NUMBER_OF_BIDS
             , I.CREATED_BY
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_NEGOTIATIONS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_NEGOTIATIONS_RESPONSE');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_NEGOTIATIONS_RESPONSE';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_NEGOTIATIONS_RESPONSE';

    FOR I IN (
               SELECT TO_CHAR(bh.bid_number)                                    bid
                    , bh.bid_number                                             bid_number
                    , bh.publish_date
                    , bh.trading_partner_name                                   bidder
                    , bh.trading_partner_id                                     bidder_company_id
                    , TO_CHAR(ah.trading_partner_contact_id)                    buyer_id
                    , TO_CHAR(ah.trading_partner_id)                            auctioneer_company_id
                    , TO_CHAR(bh.trading_partner_contact_id)                    bidder_id
                    , bh.bid_status
                    , bh.bid_currency_code
                    , PON_LOCALE_PKG.get_party_display_name(bh.trading_partner_contact_id) trading_partner_contact_name
                    , fl.meaning                                                bid_display_status
                    , ah.doctype_id
                    , bh.bid_expiration_date
                    , ah.auction_header_id
                    , bh.vendor_id                                              bidder_vendor_id
                    , bh.vendor_site_code
                    , ah.document_number
                    , ah.supplier_view_type
                 FROM pon_auction_headers_all_v ah
                    , pon_bid_headers           bh
                    , fnd_lookups               fl
                WHERE ah.auction_header_id = bh.auction_header_id(+)
                  AND fl.lookup_type       ='PON_BID_STATUS'
                  AND fl.lookup_code       = bh.bid_status
                  AND (
                            bh.bid_status <> 'DRAFT'
                        AND bh.bid_status <> 'ARCHIVED_DRAFT')
             )
    LOOP

        INSERT INTO XXBI_SRC_NEGOTIATIONS_RESPONSE
             (
               BID
             , BID_NUMBER
             , PUBLISH_DATE
             , BIDDER
             , BIDDER_COMPANY_ID
             , BUYER_ID
             , AUCTIONEER_COMPANY_ID
             , BIDDER_ID
             , BID_STATUS
             , BID_CURRENCY_CODE
             , TRADING_PARTNER_CONTACT_NAME
             , BID_DISPLAY_STATUS
             , DOCTYPE_ID
             , BID_EXPIRATION_DATE
             , AUCTION_HEADER_ID
             , BIDDER_VENDOR_ID
             , VENDOR_SITE_CODE
             , DOCUMENT_NUMBER
             , SUPPLIER_VIEW_TYPE
             )
        VALUES
             (
               I.BID
             , I.BID_NUMBER
             , I.PUBLISH_DATE
             , I.BIDDER
             , I.BIDDER_COMPANY_ID
             , I.BUYER_ID
             , I.AUCTIONEER_COMPANY_ID
             , I.BIDDER_ID
             , I.BID_STATUS
             , I.BID_CURRENCY_CODE
             , I.TRADING_PARTNER_CONTACT_NAME
             , I.BID_DISPLAY_STATUS
             , I.DOCTYPE_ID
             , I.BID_EXPIRATION_DATE
             , I.AUCTION_HEADER_ID
             , I.BIDDER_VENDOR_ID
             , I.VENDOR_SITE_CODE
             , I.DOCUMENT_NUMBER
             , I.SUPPLIER_VIEW_TYPE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_NEGOTIATIONS_RESPONSE', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_NEGOTIATIONS_REQ');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_NEGOTIATIONS_REQ';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_NEGOTIATIONS_REQ';

    FOR I IN (
               SELECT attr_group_seq_number
                    , attribute_list_id
                    , auction_header_id
                    , line_number
                    , section_name
                    , attr_level
                    , attribute_name
                 FROM pon_auction_attributes paa
                WHERE line_number = -1
             )
    LOOP

        INSERT INTO XXBI_SRC_NEGOTIATIONS_REQ
             (
               ATTR_GROUP_SEQ_NUMBER
             , ATTRIBUTE_LIST_ID
             , AUCTION_HEADER_ID
             , LINE_NUMBER
             , SECTION_NAME
             , ATTR_LEVEL
             , ATTRIBUTE_NAME
             )
        VALUES
             (
               I.ATTR_GROUP_SEQ_NUMBER
             , I.ATTRIBUTE_LIST_ID
             , I.AUCTION_HEADER_ID
             , I.LINE_NUMBER
             , I.SECTION_NAME
             , I.ATTR_LEVEL
             , I.ATTRIBUTE_NAME
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_NEGOTIATIONS_REQ', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_NEGOTIATIONS_COLLAB');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_NEGOTIATIONS_COLLAB';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_NEGOTIATIONS_COLLAB';

    FOR I IN (
               SELECT TM.COMPLETION_DATE
                    , TM.AUCTION_HEADER_ID
                    , TM.LIST_ID
                    , TM.USER_ID
                    , P.full_name
                    , S.NAME position_name
                    , DECODE(tm.approver_flag, 'Y', 'ApprYes', 'ApprNo') approver_switch
                    , DECODE(tm.menu_name, 'PON_SOURCING_VIEWNEG', 'ViewYes', 'ViewNo') view_only_switch
                    , tm.task_name
                    , tm.target_date
                    , tm.approval_status
                    , DECODE(tm.approval_status, 'REJECTED', 'Rejected', 'APPROVED', 'Approved', NULL) approval_status_switch
                    , u.person_party_id party_id
                    , u.user_name
                    , flv.meaning TEAM_MEMBER_ACCESS
                    , TM.LAST_NOTIFIED_DATE
                 FROM PON_NEG_TEAM_MEMBERS TM,
                      FND_USER U,
                      PER_ALL_PEOPLE_F P,
                      PER_ALL_ASSIGNMENTS_F A,
                      PER_ALL_POSITIONS S,
                      PON_AUCTION_HEADERS_ALL AH,
                      FND_LOOKUPS flv
                WHERE TM.LAST_AMENDMENT_UPDATE <= AH.AMENDMENT_NUMBER
                  AND U.USER_ID                 = TM.USER_ID
                  AND U.EMPLOYEE_ID             = P.PERSON_ID
                  AND P.EFFECTIVE_END_DATE      =
                    (SELECT
                      /*+ no_unnest */
                      MAX(PP.EFFECTIVE_END_DATE)
                    FROM PER_ALL_PEOPLE_F PP
                    WHERE PP.PERSON_ID = U.EMPLOYEE_ID
                    )
                  AND A.PERSON_ID             = P.PERSON_ID
                  AND A.PRIMARY_FLAG          = 'Y'
                  AND ((A.ASSIGNMENT_TYPE     = 'E'
                  AND P.CURRENT_EMPLOYEE_FLAG = 'Y')
                  OR (A.ASSIGNMENT_TYPE       = 'C'
                  AND P.CURRENT_NPW_FLAG      = 'Y'))
                  AND A.EFFECTIVE_END_DATE    =
                    (SELECT
                      /*+ no_unnest */
                      MAX(AA.EFFECTIVE_END_DATE)
                    FROM PER_ALL_ASSIGNMENTS_F AA
                    WHERE AA.PRIMARY_FLAG   = 'Y'
                    AND AA.ASSIGNMENT_TYPE IN ('E', 'C')
                    AND AA.PERSON_ID        = P.PERSON_ID
                    )
                  AND A.POSITION_ID        = S.POSITION_ID(+)
                  AND TM.AUCTION_HEADER_ID = AH.AUCTION_HEADER_ID
                  AND TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
                  AND flv.lookup_type = 'PON_NEG_TEAM_MEMBER_ACCESS'
                  AND flv.lookup_code = tm.menu_name
             )
    LOOP

        INSERT INTO XXBI_SRC_NEGOTIATIONS_COLLAB
             (
               COMPLETION_DATE
             , AUCTION_HEADER_ID
             , LIST_ID
             , USER_ID
             , FULL_NAME
             , POSITION_NAME
             , APPROVER_SWITCH
             , VIEW_ONLY_SWITCH
             , TASK_NAME
             , TARGET_DATE
             , APPROVAL_STATUS
             , APPROVAL_STATUS_SWITCH
             , PARTY_ID
             , USER_NAME
             , TEAM_MEMBER_ACCESS
             , LAST_NOTIFIED_DATE
             )
        VALUES
             (
               I.COMPLETION_DATE
             , I.AUCTION_HEADER_ID
             , I.LIST_ID
             , I.USER_ID
             , I.FULL_NAME
             , I.POSITION_NAME
             , I.APPROVER_SWITCH
             , I.VIEW_ONLY_SWITCH
             , I.TASK_NAME
             , I.TARGET_DATE
             , I.APPROVAL_STATUS
             , I.APPROVAL_STATUS_SWITCH
             , I.PARTY_ID
             , I.USER_NAME
             , I.TEAM_MEMBER_ACCESS
             , I.LAST_NOTIFIED_DATE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_NEGOTIATIONS_COLLAB', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_NEGOTIATIONS_LINES');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_NEGOTIATIONS_LINES';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_NEGOTIATIONS_LINES';

    FOR I IN (
               SELECT itm.auction_header_id
                    , itm.line_number
                    , itm.item_number
                    , itm.item_revision
                    , PON_OA_UTIL_PKG.truncate_display_string(itm.item_description) item_desc_trunc
                    , units.unit_of_measure_tl unit_of_measure
                    , itm.quantity
                    , itm.need_by_start_date
                    , itm.need_by_date
                    , itm.category_name
                    , itm.best_bid_number
                    , itm.best_bid_bid_price best_bid_bid_price
                    , itm.best_bid_score
                    , itm.best_bid_bid_number
                 FROM pon_auction_item_prices_all itm
                    , mtl_units_of_measure_tl units
                    , pon_auction_headers_all ah
                 WHERE itm.auction_header_id     = ah.auction_header_id
                   AND itm.uom_code                = units.uom_code(+)
                   AND units.language(+)           = userenv('LANG')
                   AND DECODE(itm.parent_line_number,NULL,itm.line_number,itm.parent_line_number) NOT IN
                          (SELECT line_number
                             FROM pon_party_line_exclusions pple
                            WHERE pple.auction_header_id = ah.auction_header_id
                              AND pple.trading_partner_id  = ah.trading_partner_id
                          )
             )
    LOOP

        INSERT INTO XXBI_SRC_NEGOTIATIONS_LINES
             (
               AUCTION_HEADER_ID
             , LINE_NUMBER
             , ITEM_NUMBER
             , ITEM_REVISION
             , ITEM_DESC_TRUNC
             , UNIT_OF_MEASURE
             , QUANTITY
             , NEED_BY_START_DATE
             , NEED_BY_DATE
             , CATEGORY_NAME
             , BEST_BID_NUMBER
             , BEST_BID_BID_PRICE
             , BEST_BID_SCORE
             , BEST_BID_BID_NUMBER
             )
        VALUES
             (
               I.AUCTION_HEADER_ID
             , I.LINE_NUMBER
             , I.ITEM_NUMBER
             , I.ITEM_REVISION
             , I.ITEM_DESC_TRUNC
             , I.UNIT_OF_MEASURE
             , I.QUANTITY
             , I.NEED_BY_START_DATE
             , I.NEED_BY_DATE
             , I.CATEGORY_NAME
             , I.BEST_BID_NUMBER
             , I.BEST_BID_BID_PRICE
             , I.BEST_BID_SCORE
             , I.BEST_BID_BID_NUMBER
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_NEGOTIATIONS_LINES', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_NEGOTIATIONS_SUPPLIER');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_NEGOTIATIONS_SUPPLIER';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_NEGOTIATIONS_SUPPLIER';

    FOR I IN (
               SELECT DISTINCT PON_OA_UTIL_PKG.truncate(pbp.trading_partner_name)                               bidder_display
                    , PON_LOCALE_PKG.get_party_display_name(pbp.trading_partner_contact_id)                     contact_name
                    , PON_OA_UTIL_PKG.truncate(additional_contact_email)                                        additional_contact_email_dsp
                    , PON_OA_UTIL_PKG.truncate(hcp1.email_address)
                        || nvl2(pbp.additional_contact_email, nvl2(hcp1.email_address, '/', NULL),NULL)
                        || PON_OA_UTIL_PKG.truncate(pbp.additional_contact_email)                               email_display
                    , pbp.round_number
                    , DECODE(pbp.supp_acknowledgement, NULL, NULL, 'Y', 'AckYes', 'AckNo')                      supp_acknowledgement_switch
                    , DECODE(pbp.bid_currency_code, NULL, 'AnyCurrency', 'BidCurrency')                         bid_currency_switch
                    , pbp.bid_currency_code
                    , DECODE(NVL(pbp.number_price_decimals, 10000), 10000, 'AnyPrecision', 'SuppPrecision')     precision_switch
                    , pbp.number_price_decimals
                    , pbp.rate_dsp
                    , pbp.trading_partner_id                                                                    trading_partner_id
                    , DECODE(NVL(pbp.round_number,0), 0, 'NotAvailable', 'RoundNumber')                         invited_in_round_switch
                    , pbp.trading_partner_contact_id
                    , pbp.trading_partner_contact_name
                    , pbh.bid_number
                    , pbp.sequence
                    , ah.auction_header_id
                    , 'buying' AS                                                                               app_name
                    , pbp.vendor_site_code
                    , pov.vendor_id                                                                             vendor_id
                    , pbp.access_type
                    , pbp.trading_partner_name
                    , pbp.vendor_site_id
                    , pov.segment1                                                                              supplier_number
                    , pbp.requested_supplier_id
                    , pbp.requested_supplier_name
                    , pbp.requested_supplier_contact_id
                    , pbp.requested_supp_contact_name
                 FROM pon_bidding_parties pbp,
                      pon_bid_headers pbh,
                      hz_contact_points hcp1,
                      hz_contact_points hcp2,
                      pon_auction_headers_all ah,
                      po_vendors pov,
                      pos_supplier_users_v psuv
                WHERE ah.auction_header_id    = pbp.auction_header_id
                  AND pbp.auction_header_id   =pbh.auction_header_id(+)
                  AND pbp.trading_partner_id  =pbh.trading_partner_id(+)
                  AND pbp.vendor_site_code=decode(pbp.vendor_site_code,'-1','-1',pbh.vendor_site_code(+))
                  AND 'ACTIVE' = pbh.bid_status(+)
                  AND hcp1.owner_table_id(+) = psuv.rel_party_id
                  AND hcp1.contact_point_type(+) = 'EMAIL'
                  and hcp1.owner_table_name(+) = 'HZ_PARTIES'
                  AND hcp1.status(+) = 'A'
                  AND hcp1.primary_flag(+) = 'Y'
                  AND hcp2.owner_table_id(+) = psuv.rel_party_id
                  AND hcp2.contact_point_type(+) = 'PHONE'
                  AND hcp2.phone_line_type(+) = 'GEN'
                  AND hcp2.owner_table_name(+) = 'HZ_PARTIES'
                  AND hcp2.status(+) = 'A'
                  AND hcp2.primary_flag(+) = 'Y'
                  AND pov.party_id(+) = pbp.trading_partner_id
                  AND psuv.vendor_party_id(+) = pbp.trading_partner_id
                  AND psuv.person_party_id(+) = pbp.trading_partner_contact_id
             )
    LOOP

        INSERT INTO XXBI_SRC_NEGOTIATIONS_SUPPLIER
             (
               BIDDER_DISPLAY
             , CONTACT_NAME
             , ADDITIONAL_CONTACT_EMAIL_DSP
             , EMAIL_DISPLAY
             , ROUND_NUMBER
             , SUPP_ACKNOWLEDGEMENT_SWITCH
             , BID_CURRENCY_SWITCH
             , BID_CURRENCY_CODE
             , PRECISION_SWITCH
             , NUMBER_PRICE_DECIMALS
             , RATE_DSP
             , TRADING_PARTNER_ID
             , INVITED_IN_ROUND_SWITCH
             , TRADING_PARTNER_CONTACT_ID
             , TRADING_PARTNER_CONTACT_NAME
             , BID_NUMBER
             , SEQUENCE
             , AUCTION_HEADER_ID
             , APP_NAME
             , VENDOR_SITE_CODE
             , VENDOR_ID
             , ACCESS_TYPE
             , TRADING_PARTNER_NAME
             , VENDOR_SITE_ID
             , SUPPLIER_NUMBER
             , REQUESTED_SUPPLIER_ID
             , REQUESTED_SUPPLIER_NAME
             , REQUESTED_SUPPLIER_CONTACT_ID
             , REQUESTED_SUPP_CONTACT_NAME
             )
        VALUES
             (
               I.BIDDER_DISPLAY
             , I.CONTACT_NAME
             , I.ADDITIONAL_CONTACT_EMAIL_DSP
             , I.EMAIL_DISPLAY
             , I.ROUND_NUMBER
             , I.SUPP_ACKNOWLEDGEMENT_SWITCH
             , I.BID_CURRENCY_SWITCH
             , I.BID_CURRENCY_CODE
             , I.PRECISION_SWITCH
             , I.NUMBER_PRICE_DECIMALS
             , I.RATE_DSP
             , I.TRADING_PARTNER_ID
             , I.INVITED_IN_ROUND_SWITCH
             , I.TRADING_PARTNER_CONTACT_ID
             , I.TRADING_PARTNER_CONTACT_NAME
             , I.BID_NUMBER
             , I.SEQUENCE
             , I.AUCTION_HEADER_ID
             , I.APP_NAME
             , I.VENDOR_SITE_CODE
             , I.VENDOR_ID
             , I.ACCESS_TYPE
             , I.TRADING_PARTNER_NAME
             , I.VENDOR_SITE_ID
             , I.SUPPLIER_NUMBER
             , I.REQUESTED_SUPPLIER_ID
             , I.REQUESTED_SUPPLIER_NAME
             , I.REQUESTED_SUPPLIER_CONTACT_ID
             , I.REQUESTED_SUPP_CONTACT_NAME
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_NEGOTIATIONS_SUPPLIER', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PROJECTS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_PROJECTS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PROJECTS';

    FOR I IN (
               SELECT proj.project_id
                    , PA_PROJECT_PARTIES_UTILS.GET_CURRENT_PROJ_MANAGER_NAME(proj.project_id) project_manager
                    , proj.name
                    , proj.segment1
                    , proj.project_type
                    , proj.PROJECT_TYPE_CLASS_CODE
                    , proj.carrying_out_organization_id
                    , proj.carrying_out_organization_name
                    , proj.start_date
                    , proj.completion_date
                    , proj.description
                    , proj.public_sector_flag
                    , proj.project_status_name
                    , proj.project_status_code
                    , proj.wf_status_code
                    , proj.country_name
                    , proj.country_code
                    , proj.region
                    , proj.city
                    , proj.location_id
                    , proj.project_currency_code
                    , proj.record_version_number
                    , proj.country_name                                              old_country_name
                    , proj.region                                                    old_region
                    , proj.city                                                      old_city
                    , proj.role_list_id
                    , proj.PUBLIC_SECTOR_MEANING
                    , proj.attribute_category
                    , proj.attribute1
                    , proj.attribute2
                    , proj.attribute3
                    , proj.attribute4
                    , proj.attribute5
                    , proj.attribute6
                    , proj.attribute7
                    , proj.attribute8
                    , proj.attribute9
                    , proj.attribute10
                    , proj.projfunc_currency_code
                    , proj.priority_code
                    , proj.target_start_date
                    , proj.target_finish_date
                    , proj.scheduled_start_date
                    , proj.scheduled_finish_date
                    , proj.baseline_start_date
                    , proj.baseline_finish_date
                    , proj.actual_start_date
                    , proj.actual_finish_date
                    , proj.derived_start_date
                    , proj.derived_finish_date
                    , proj.last_update_date
                    , proj.scheduled_as_of_date
                    , proj.baseline_as_of_date
                    , proj.actual_as_of_date
                    , proj.scheduled_duration
                    , proj.baseline_duration
                    , proj.actual_duration
                    , proj.security_level
                    , proj.long_name
                    , proj.funding_approval_status_code
                    , proj.funding_approval_status_name
                    , proj.funding_approval_system_code
                    , proj.org_id
                    , opr.name                                                  operating_unit
                    , 'PA_PROJECTS'                                             WHICH_ATTACH
                    , 'EBS'                                                     USED_BY
                    , TO_CHAR(proj.project_id)                                       PK1_VALUE
                    , NVL (ppru.completed_percentage, ppru.eff_rollup_percent_comp) COMPLETED_PERCENTAGE
                 FROM pa_projects_prm_v             proj
                    , hr_all_organization_units_vl  opr
                    , pa_progress_rollup            ppru
                    , pa_proj_elem_ver_structure    ppevs
                WHERE proj.org_id = opr.ORGANIZATION_ID
                  AND proj.project_id = ppru.project_id
                  AND ppru.object_type = 'PA_STRUCTURES'
                  AND ppevs.project_id = ppru.project_id
                  AND ppevs.current_flag = 'Y'
                  AND ppru.current_flag = 'Y'
             )
    LOOP

        INSERT INTO XXBI_SRC_PROJECTS
             (
               PROJECT_ID
             , PROJECT_MANAGER
             , NAME
             , SEGMENT1
             , PROJECT_TYPE
             , PROJECT_TYPE_CLASS_CODE
             , CARRYING_OUT_ORGANIZATION_ID
             , CARRYING_OUT_ORGANIZATION_NAME
             , START_DATE
             , COMPLETION_DATE
             , DESCRIPTION
             , PUBLIC_SECTOR_FLAG
             , PROJECT_STATUS_NAME
             , PROJECT_STATUS_CODE
             , WF_STATUS_CODE
             , COUNTRY_NAME
             , COUNTRY_CODE
             , REGION
             , CITY
             , LOCATION_ID
             , PROJECT_CURRENCY_CODE
             , RECORD_VERSION_NUMBER
             , OLD_COUNTRY_NAME
             , OLD_REGION
             , OLD_CITY
             , ROLE_LIST_ID
             , PUBLIC_SECTOR_MEANING
             , ATTRIBUTE_CATEGORY
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , ATTRIBUTE9
             , ATTRIBUTE10
             , PROJFUNC_CURRENCY_CODE
             , PRIORITY_CODE
             , TARGET_START_DATE
             , TARGET_FINISH_DATE
             , SCHEDULED_START_DATE
             , SCHEDULED_FINISH_DATE
             , BASELINE_START_DATE
             , BASELINE_FINISH_DATE
             , ACTUAL_START_DATE
             , ACTUAL_FINISH_DATE
             , DERIVED_START_DATE
             , DERIVED_FINISH_DATE
             , LAST_UPDATE_DATE
             , SCHEDULED_AS_OF_DATE
             , BASELINE_AS_OF_DATE
             , ACTUAL_AS_OF_DATE
             , SCHEDULED_DURATION
             , BASELINE_DURATION
             , ACTUAL_DURATION
             , SECURITY_LEVEL
             , LONG_NAME
             , FUNDING_APPROVAL_STATUS_CODE
             , FUNDING_APPROVAL_STATUS_NAME
             , FUNDING_APPROVAL_SYSTEM_CODE
             , ORG_ID
             , OPERATING_UNIT
             , WHICH_ATTACH
             , USED_BY
             , PK1_VALUE
             , COMPLETED_PERCENTAGE
             )
        VALUES
             (
               I.PROJECT_ID
             , I.PROJECT_MANAGER
             , I.NAME
             , I.SEGMENT1
             , I.PROJECT_TYPE
             , I.PROJECT_TYPE_CLASS_CODE
             , I.CARRYING_OUT_ORGANIZATION_ID
             , I.CARRYING_OUT_ORGANIZATION_NAME
             , I.START_DATE
             , I.COMPLETION_DATE
             , I.DESCRIPTION
             , I.PUBLIC_SECTOR_FLAG
             , I.PROJECT_STATUS_NAME
             , I.PROJECT_STATUS_CODE
             , I.WF_STATUS_CODE
             , I.COUNTRY_NAME
             , I.COUNTRY_CODE
             , I.REGION
             , I.CITY
             , I.LOCATION_ID
             , I.PROJECT_CURRENCY_CODE
             , I.RECORD_VERSION_NUMBER
             , I.OLD_COUNTRY_NAME
             , I.OLD_REGION
             , I.OLD_CITY
             , I.ROLE_LIST_ID
             , I.PUBLIC_SECTOR_MEANING
             , I.ATTRIBUTE_CATEGORY
             , I.ATTRIBUTE1
             , I.ATTRIBUTE2
             , I.ATTRIBUTE3
             , I.ATTRIBUTE4
             , I.ATTRIBUTE5
             , I.ATTRIBUTE6
             , I.ATTRIBUTE7
             , I.ATTRIBUTE8
             , I.ATTRIBUTE9
             , I.ATTRIBUTE10
             , I.PROJFUNC_CURRENCY_CODE
             , I.PRIORITY_CODE
             , I.TARGET_START_DATE
             , I.TARGET_FINISH_DATE
             , I.SCHEDULED_START_DATE
             , I.SCHEDULED_FINISH_DATE
             , I.BASELINE_START_DATE
             , I.BASELINE_FINISH_DATE
             , I.ACTUAL_START_DATE
             , I.ACTUAL_FINISH_DATE
             , I.DERIVED_START_DATE
             , I.DERIVED_FINISH_DATE
             , I.LAST_UPDATE_DATE
             , I.SCHEDULED_AS_OF_DATE
             , I.BASELINE_AS_OF_DATE
             , I.ACTUAL_AS_OF_DATE
             , I.SCHEDULED_DURATION
             , I.BASELINE_DURATION
             , I.ACTUAL_DURATION
             , I.SECURITY_LEVEL
             , I.LONG_NAME
             , I.FUNDING_APPROVAL_STATUS_CODE
             , I.FUNDING_APPROVAL_STATUS_NAME
             , I.FUNDING_APPROVAL_SYSTEM_CODE
             , I.ORG_ID
             , I.OPERATING_UNIT
             , I.WHICH_ATTACH
             , I.USED_BY
             , I.PK1_VALUE
             , I.COMPLETED_PERCENTAGE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PROJECTS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PROJ_DIRECTORIES');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_PROJ_DIRECTORIES';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PROJ_DIRECTORIES';

    FOR I IN (
               SELECT *
                 FROM
                      ( SELECT DISTINCT PPP.PROJECT_PARTY_ID                    project_party_id
                             , PPP.OBJECT_ID                                    object_id
                             , PPP.OBJECT_TYPE                                  object_type
                             , PPP.PROJECT_ID                                   project_id
                             , PPP.RESOURCE_ID                                  resource_id
                             , PPP.RESOURCE_TYPE_ID                             resource_type_id
                             , PPP.RESOURCE_SOURCE_ID                           resource_source_id
                             , PE.FULL_NAME                                     resource_source_name
                             , PPP.PROJECT_ROLE_ID                              project_role_id
                             , PPRT.PROJECT_ROLE_TYPE                           project_role_type
                             , DECODE(pa_project_parties_utils.enable_edit_link(ppp.project_id, ppp.scheduled_flag, pa.assignment_id)
                                     , 'T', 'AttrWithEditLink'
                                     , 'S', 'AttrWithTeamLink'
                                     , 'AttrWithNoLink')                        project_role_meaning_link
                             , DECODE(PA.ASSIGNMENT_ID,NULL,PPRT.MEANING,PA.ASSIGNMENT_NAME) project_role_meaning
                             , PPP.START_DATE_ACTIVE                            start_date_active
                             , PPP.END_DATE_ACTIVE                              end_date_active
                             , PA_PROJECT_PARTIES_UTILS.ACTIVE_PARTY(PPP.START_DATE_ACTIVE,PPP.END_DATE_ACTIVE) active
                             , PPP.SCHEDULED_FLAG                               scheduled_flag
                             , DECODE(PA.ASSIGNMENT_ID,NULL,'N',pa_asgmt_wfstd.is_approval_pending(pa.assignment_id)) pending_approval
                             , PPP.RECORD_VERSION_NUMBER                        record_version_number
                             , PPA.START_DATE                                   project_start_date
                             , PPA.COMPLETION_DATE                              project_end_date
                             , PA.ASSIGNMENT_ID                                 assignment_id
                             , PA.RECORD_VERSION_NUMBER                         assign_record_version_number
                             , prd.org_name                                     organization_name
                             , PRD.ORG_ID                                       organization_id
                             , HR_GENERAL.GET_WORK_PHONE(PE.PERSON_ID)          phone_number
                             , PE.EMAIL_ADDRESS                                 email_address
                             , prd.job_name                                     job_title
                             , 'EMPLOYEE'                                       party_type
                             , DECODE(DECODE(PE.CURRENT_EMPLOYEE_FLAG,'Y','Y', DECODE(PE.CURRENT_NPW_FLAG,'Y','Y','N')), 'N', 'AttrNameWithNoLink','AttrNameWithLink') name_switcher
                             , DECODE(DECODE(PE.CURRENT_EMPLOYEE_FLAG,'Y','Y', DECODE(PE.CURRENT_NPW_FLAG,'Y','Y','N')), 'N', 0, 1) project_edit_privelege
                          FROM PA_PROJECT_PARTIES PPP
                             , PA_PROJECTS_ALL    PPA
                             , PA_PROJECT_ROLE_TYPES PPRT
                             , PER_ALL_PEOPLE_F PE
                             , PA_PROJECT_ASSIGNMENTS PA
                             , fnd_user u
                             , (
                                 SELECT pj.name job_name
                                      , haou.organization_id org_id
                                      , haou.name org_name
                                      , paf.person_id
                                      , paf.assignment_type
                                   FROM per_all_assignments_f paf
                                      , per_jobs pj
                                      , hr_all_organization_units haou
                                  WHERE TRUNC(sysdate) BETWEEN TRUNC(paf.effective_start_date) AND TRUNC(paf.effective_end_date)
                                    AND paf.primary_flag     = 'Y'
                                    AND paf.organization_id  = haou.organization_id
                                    AND NVL(paf.job_id, -99) = pj.job_id(+)
                               ) prd
                         WHERE PPP.RESOURCE_TYPE_ID                 = 101
                           AND PPP.PROJECT_ID                       = PPA.PROJECT_ID
                           AND PPP.PROJECT_ROLE_ID                  = PPRT.PROJECT_ROLE_ID
                           AND PPP.RESOURCE_SOURCE_ID               = PE.PERSON_ID
                           AND PE.EFFECTIVE_START_DATE              = (
                                                                        SELECT MIN(PAPF.EFFECTIVE_START_DATE)
                                                                          FROM PER_ALL_PEOPLE_F PAPF
                                                                         WHERE PAPF.PERSON_ID         =PE.PERSON_ID
                                                                           AND PAPF.EFFECTIVE_END_DATE >= TRUNC(SYSDATE)
                                                                      )
                           AND PE.EFFECTIVE_END_DATE                >=TRUNC(SYSDATE)
                           AND PPP.PROJECT_PARTY_ID                 = PA.PROJECT_PARTY_ID(+)
                           AND NVL(prd.assignment_type,-99)         IN ('C',DECODE(DECODE(PE.CURRENT_EMPLOYEE_FLAG,'Y','Y', DECODE(PE.CURRENT_NPW_FLAG,'Y','Y','N')),'Y','E', 'B'),'E', -99)
                           AND ppp.resource_source_id               = prd.person_id(+)
                           AND u.employee_id (+)                    = ppp.resource_source_id
                      UNION ALL
                        SELECT DISTINCT ppp.project_party_id
                             , ppp.object_id
                             , ppp.object_type
                             , ppp.project_id
                             , ppp.resource_id
                             , ppp.resource_type_id
                             , ppp.resource_source_id
                             , hzp.party_name
                             , ppp.project_role_id
                             , pprt.project_role_type
                             , DECODE(pa_project_parties_utils.enable_edit_link(ppp.project_id, ppp.scheduled_flag, -999), 'T', 'AttrWithEditLink', 'S', 'AttrWithTeamLink', 'AttrWithNoLink')
                             , pprt.meaning
                             , ppp.start_date_active
                             , ppp.end_date_active
                             , PA_PROJECT_PARTIES_UTILS.ACTIVE_PARTY(PPP.START_DATE_ACTIVE,PPP.END_DATE_ACTIVE)
                             , ppp.scheduled_flag
                             , 'N'
                             , ppp.record_version_number
                             , ppa.start_date
                             , ppa.completion_date
                             , -999
                             , -999
                             , hzo.party_name
                             , hzo.party_id
                             , hzcp.phone_area_code
                                || DECODE(hzcp.phone_number,NULL,NULL,DECODE(hzcp.phone_area_code,NULL,hzcp.phone_number,'-'
                                ||hzcp.phone_number) )
                                || DECODE(hzcp.phone_extension,NULL,NULL,'+'
                                || hzcp.phone_extension)
                             , hzp.email_address
                             , NULL
                             , 'PERSON'
                             , 'AttrNameWithLink'
                             , 1
                          FROM pa_project_parties       ppp
                             , pa_projects_all          ppa
                             , pa_project_role_types    pprt
                             , hz_parties               hzp
                             , hz_parties               hzo
                             , hz_relationships         hzr
                             , hz_contact_points        hzcp
                             , fnd_user                 u
                         WHERE ppp.resource_type_id       = 112
                           AND ppp.project_id             = ppa.project_id
                           AND ppp.project_role_id        = pprt.project_role_id
                           AND ppp.resource_source_id     = hzp.party_id
                           AND hzp.party_type             = 'PERSON'
                           AND hzo.party_type             = 'ORGANIZATION'
                           AND hzr.relationship_code     IN ('EMPLOYEE_OF', 'CONTACT_OF')
                           AND hzr.status                 = 'A'
                           AND hzr.subject_id             = hzp.party_id
                           AND hzr.object_id              = hzo.party_id
                           AND hzr.object_table_name      = 'HZ_PARTIES'
                           AND hzr.directional_flag       = 'F'
                           AND hzcp.owner_table_name (+)  = 'HZ_PARTIES'
                           AND hzcp.owner_table_id (+)    = hzp.party_id
                           AND hzcp.contact_point_type (+)= 'PHONE'
                           AND hzcp.phone_line_type (+)   = 'GEN'
                           AND hzcp.primary_flag (+)      = 'Y'
                           AND u.person_party_id (+)      = ppp.resource_source_id
                      UNION ALL
                        SELECT DISTINCT ppp.project_party_id
                             , ppp.object_id
                             , ppp.object_type
                             , ppp.project_id
                             , ppp.resource_id
                             , ppp.resource_type_id
                             , ppp.resource_source_id
                             , hzo.party_name
                             , ppp.project_role_id
                             , pprt.project_role_type
                             , DECODE(pa_project_parties_utils.enable_edit_link(ppp.project_id, ppp.scheduled_flag, -999), 'T', 'AttrWithEditLink', 'S', 'AttrWithTeamLink', 'AttrWithNoLink')
                             , pprt.meaning
                             , ppp.start_date_active
                             , ppp.end_date_active
                             , PA_PROJECT_PARTIES_UTILS.ACTIVE_PARTY(PPP.START_DATE_ACTIVE,PPP.END_DATE_ACTIVE)
                             , ppp.scheduled_flag
                             , 'N'
                             , ppp.record_version_number
                             , ppa.start_date
                             , ppa.completion_date
                             , -999
                             , -999
                             , NULL
                             , -999
                             , hzcp.phone_area_code
                                 || DECODE(hzcp.phone_number,NULL,NULL,DECODE(hzcp.phone_area_code,NULL,hzcp.phone_number,'-'
                                 || hzcp.phone_number) )
                                 || DECODE(hzcp.phone_extension,NULL,NULL,'+'
                                 || hzcp.phone_extension)
                             , hzo.email_address
                             , NULL
                             , 'ORGANIZATION'
                             , DECODE(PA_SECURITY_PVT.check_user_privilege('PA_PRJ_SETUP_SUBTAB', 'PA_PROJECTS', ppp.project_id), 'T' , 'AttrNameWithLink', 'AttrNameWithNoLink')
                             , DECODE(PA_SECURITY_PVT.check_user_privilege('PA_PRJ_SETUP_SUBTAB', 'PA_PROJECTS', ppp.project_id), 'T' , 1, 0)
                          FROM pa_project_parties       ppp
                             , pa_projects_all          ppa
                             , pa_project_role_types_vl pprt
                             , hz_parties               hzo
                             , hz_contact_points        hzcp
                         WHERE ppp.resource_type_id       = 112
                           AND ppp.project_id             = ppa.project_id
                           AND ppp.project_role_id        = pprt.project_role_id
                           AND ppp.resource_source_id     = hzo.party_id
                           AND hzo.party_type             = 'ORGANIZATION'
                           AND hzcp.owner_table_name (+)  = 'HZ_PARTIES'
                           AND hzcp.owner_table_id (+)    = hzo.party_id
                           AND hzcp.contact_point_type (+)= 'PHONE'
                           AND hzcp.phone_line_type (+)   = 'GEN'
                           AND hzcp.primary_flag (+)      = 'Y'
                      ) QRSLT
                 WHERE active   = 'Y'
             )
    LOOP

        INSERT INTO XXBI_SRC_PROJ_DIRECTORIES
             (
               PROJECT_PARTY_ID
             , OBJECT_ID
             , OBJECT_TYPE
             , PROJECT_ID
             , RESOURCE_ID
             , RESOURCE_TYPE_ID
             , RESOURCE_SOURCE_ID
             , RESOURCE_SOURCE_NAME
             , PROJECT_ROLE_ID
             , PROJECT_ROLE_TYPE
             , PROJECT_ROLE_MEANING_LINK
             , PROJECT_ROLE_MEANING
             , START_DATE_ACTIVE
             , END_DATE_ACTIVE
             , ACTIVE
             , SCHEDULED_FLAG
             , PENDING_APPROVAL
             , RECORD_VERSION_NUMBER
             , PROJECT_START_DATE
             , PROJECT_END_DATE
             , ASSIGNMENT_ID
             , ASSIGN_RECORD_VERSION_NUMBER
             , ORGANIZATION_NAME
             , ORGANIZATION_ID
             , PHONE_NUMBER
             , EMAIL_ADDRESS
             , JOB_TITLE
             , PARTY_TYPE
             , NAME_SWITCHER
             , PROJECT_EDIT_PRIVELEGE
             )
        VALUES
             (
               I.PROJECT_PARTY_ID
             , I.OBJECT_ID
             , I.OBJECT_TYPE
             , I.PROJECT_ID
             , I.RESOURCE_ID
             , I.RESOURCE_TYPE_ID
             , I.RESOURCE_SOURCE_ID
             , I.RESOURCE_SOURCE_NAME
             , I.PROJECT_ROLE_ID
             , I.PROJECT_ROLE_TYPE
             , I.PROJECT_ROLE_MEANING_LINK
             , I.PROJECT_ROLE_MEANING
             , I.START_DATE_ACTIVE
             , I.END_DATE_ACTIVE
             , I.ACTIVE
             , I.SCHEDULED_FLAG
             , I.PENDING_APPROVAL
             , I.RECORD_VERSION_NUMBER
             , I.PROJECT_START_DATE
             , I.PROJECT_END_DATE
             , I.ASSIGNMENT_ID
             , I.ASSIGN_RECORD_VERSION_NUMBER
             , I.ORGANIZATION_NAME
             , I.ORGANIZATION_ID
             , I.PHONE_NUMBER
             , I.EMAIL_ADDRESS
             , I.JOB_TITLE
             , I.PARTY_TYPE
             , I.NAME_SWITCHER
             , I.PROJECT_EDIT_PRIVELEGE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PROJ_DIRECTORIES', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PROJ_CLASSIFICATIONS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_PROJ_CLASSIFICATIONS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PROJ_CLASSIFICATIONS';

    FOR I IN (
               SELECT object_id
                    , class_category
                    , class_code
                    , code_percentage
                    , attribute_category
                    , attribute1
                    , attribute2
                    , attribute3
                    , attribute4
                    , attribute5
                    , attribute6
                    , attribute7
                    , attribute8
                    , attribute9
                    , attribute10
                    , attribute11
                    , attribute12
                    , attribute13
                    , attribute14
                    , attribute15
                    , record_version_number
                 FROM pa_project_classes
                WHERE object_type = 'PA_PROJECTS'
             )
    LOOP

        INSERT INTO XXBI_SRC_PROJ_CLASSIFICATIONS
             (
               OBJECT_ID
             , CLASS_CATEGORY
             , CLASS_CODE
             , CODE_PERCENTAGE
             , ATTRIBUTE_CATEGORY
             , ATTRIBUTE1
             , ATTRIBUTE2
             , ATTRIBUTE3
             , ATTRIBUTE4
             , ATTRIBUTE5
             , ATTRIBUTE6
             , ATTRIBUTE7
             , ATTRIBUTE8
             , ATTRIBUTE9
             , ATTRIBUTE10
             , ATTRIBUTE11
             , ATTRIBUTE12
             , ATTRIBUTE13
             , ATTRIBUTE14
             , ATTRIBUTE15
             , RECORD_VERSION_NUMBER
             )
        VALUES
             (
               I.OBJECT_ID
             , I.CLASS_CATEGORY
             , I.CLASS_CODE
             , I.CODE_PERCENTAGE
             , I.ATTRIBUTE_CATEGORY
             , I.ATTRIBUTE1
             , I.ATTRIBUTE2
             , I.ATTRIBUTE3
             , I.ATTRIBUTE4
             , I.ATTRIBUTE5
             , I.ATTRIBUTE6
             , I.ATTRIBUTE7
             , I.ATTRIBUTE8
             , I.ATTRIBUTE9
             , I.ATTRIBUTE10
             , I.ATTRIBUTE11
             , I.ATTRIBUTE12
             , I.ATTRIBUTE13
             , I.ATTRIBUTE14
             , I.ATTRIBUTE15
             , I.RECORD_VERSION_NUMBER
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PROJ_CLASSIFICATIONS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');


    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_ATTACHMENTS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_SRC_ATTACHMENTS';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_ATTACHMENTS';

    FOR I IN (
               SELECT DISTINCT ad.ATTACHED_DOCUMENT_ID ATTACHED_DOCUMENT_ID
                    , ad.DOCUMENT_ID AS DOCUMENT_ID
                    , ad.LAST_UPDATE_DATE
                    , ad.LAST_UPDATED_BY
                    , u.USER_NAME LAST_UPDATED_BY_NAME
                    , ad.ENTITY_NAME
                    , ad.PK1_VALUE
                    , ad.PK2_VALUE
                    , ad.PK3_VALUE
                    , ad.PK4_VALUE
                    , ad.PK5_VALUE
                    , DECODE (d.dm_node
                             , NULL,(SELECT short_name FROM fnd_dm_nodes WHERE node_id = 0)
                             , 0,(SELECT short_name FROM fnd_dm_nodes WHERE node_id = 0)
                             , node.short_name) LOCATION
                    , d.DOCUMENT_ID DOCUMENT_ID1
                    , d.DATATYPE_ID
                    , d.DATATYPE_NAME
                    , d.DESCRIPTION
                    , DECODE(d.FILE_NAME
                            , NULL, (SELECT message_text
                                       FROM fnd_new_messages
                                      WHERE message_name = 'FND_UNDEFINED'
                                        AND application_id = 0
                                        AND language_code  = userenv('LANG')
                                    )
                            , d.FILE_NAME) FILE_NAME
                    , d.MEDIA_ID
                    , d.dm_type
                    , d.dm_node
                    , d.dm_folder_path
                    , e.DATA_OBJECT_CODE
                    , e.DOCUMENT_ENTITY_ID
                    , 'ALLOW_ATTACH_UPDATE' ALLOW_ATTACH_UPDATE
                    , 'ALLOW_ATTACH_DELETE' ALLOW_ATTACH_DELETE
                    , ad.category_id category_id
                    , cl.user_name attachment_category_name
                    , ad.status
                    , ad.creation_date
                    , (SELECT u1.user_name
                         FROM fnd_user u1
                        WHERE u1.user_id=ad.CREATED_BY
                      ) ATTACHED_BY_NAME
                    , DECODE(d.datatype_id
                            , 5, NVL(d.title,d.description)
                                 ||'('||SUBSTR(d.URL, 1, least(LENGTH(d.URL),15))||'...)'
                            , DECODE(d.datatype_id
                                    , 6, NVL(d.title, d.file_name)
                                    , DECODE(D.TITLE
                                            , NULL,(SELECT message_text
                                                      FROM fnd_new_messages
                                                     WHERE message_name = 'FND_UNDEFINED'
                                                       AND application_id = 0
                                                       AND language_code  = userenv('LANG')
                                                   )
                                            , D.TITLE)
                                     )
                            ) FILE_NAME_SORT
                    , d.usage_type
                    , d.security_id
                    , d.security_type
                    , d.publish_flag
                    , cl.category_id category_id_query
                    , ad.seq_num
                    , d.URL
                    , d.TITLE
               FROM FND_DOCUMENTS_VL d,
                    FND_ATTACHED_DOCUMENTS ad,
                    FND_DOCUMENT_ENTITIES e,
                    FND_USER u,
                    FND_DOCUMENT_CATEGORIES_TL cl,
                    FND_DM_NODES node
              WHERE ad.DOCUMENT_ID   = d.DOCUMENT_ID
                AND ad.ENTITY_NAME     = e.DATA_OBJECT_CODE(+)
                AND ad.LAST_UPDATED_BY = u.USER_ID(+)
                AND cl.language        = userenv('LANG')
                AND cl.category_id     = NVL(ad.category_id, d.category_id)
                AND d.dm_node          = node.node_id(+)
                AND ad.entity_name IN ('PA_PROJECTS', 'PO_HEADERS','PON_BID_HEADERS')
                AND datatype_id IN (6,2,1,5) AND (SECURITY_TYPE =4 OR PUBLISH_FLAG ='Y')             )
    LOOP

        INSERT INTO XXBI_SRC_ATTACHMENTS
             (
               ATTACHED_DOCUMENT_ID
             , DOCUMENT_ID
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATED_BY_NAME
             , ENTITY_NAME
             , PK1_VALUE
             , PK2_VALUE
             , PK3_VALUE
             , PK4_VALUE
             , PK5_VALUE
             , LOCATION
             , DOCUMENT_ID1
             , DATATYPE_ID
             , DATATYPE_NAME
             , DESCRIPTION
             , FILE_NAME
             , MEDIA_ID
             , DM_TYPE
             , DM_NODE
             , DM_FOLDER_PATH
             , DATA_OBJECT_CODE
             , DOCUMENT_ENTITY_ID
             , ALLOW_ATTACH_UPDATE
             , ALLOW_ATTACH_DELETE
             , CATEGORY_ID
             , ATTACHMENT_CATEGORY_NAME
             , STATUS
             , CREATION_DATE
             , ATTACHED_BY_NAME
             , FILE_NAME_SORT
             , USAGE_TYPE
             , SECURITY_ID
             , SECURITY_TYPE
             , PUBLISH_FLAG
             , CATEGORY_ID_QUERY
             , SEQ_NUM
             , URL
             , TITLE
             )
        VALUES
             (
               I.ATTACHED_DOCUMENT_ID
             , I.DOCUMENT_ID
             , I.LAST_UPDATE_DATE
             , I.LAST_UPDATED_BY
             , I.LAST_UPDATED_BY_NAME
             , I.ENTITY_NAME
             , I.PK1_VALUE
             , I.PK2_VALUE
             , I.PK3_VALUE
             , I.PK4_VALUE
             , I.PK5_VALUE
             , I.LOCATION
             , I.DOCUMENT_ID1
             , I.DATATYPE_ID
             , I.DATATYPE_NAME
             , I.DESCRIPTION
             , I.FILE_NAME
             , I.MEDIA_ID
             , I.DM_TYPE
             , I.DM_NODE
             , I.DM_FOLDER_PATH
             , I.DATA_OBJECT_CODE
             , I.DOCUMENT_ENTITY_ID
             , I.ALLOW_ATTACH_UPDATE
             , I.ALLOW_ATTACH_DELETE
             , I.CATEGORY_ID
             , I.ATTACHMENT_CATEGORY_NAME
             , I.STATUS
             , I.CREATION_DATE
             , I.ATTACHED_BY_NAME
             , I.FILE_NAME_SORT
             , I.USAGE_TYPE
             , I.SECURITY_ID
             , I.SECURITY_TYPE
             , I.PUBLISH_FLAG
             , I.CATEGORY_ID_QUERY
             , I.SEQ_NUM
             , I.URL
             , I.TITLE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_ATTACHMENTS', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_WF_APPROVAL_PATH');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    l_count_update := 0;
    l_count_insert := 0;

    l_statement    := 'Maintain XXBI_WF_APPROVAL_PATH';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_WF_APPROVAL_PATH';

    FOR I IN (
               SELECT aca.transaction_type_id
                    , atoal.order_number
                    , NVL(atoal.approval_status,'Future Approver') approval_status
                    , P.full_name approver_name
                    , aag.NAME approval_group_name
                    , SUBSTR(atoal.transaction_id,1,DECODE(INSTR(atoal.transaction_id,'#'),0,50,INSTR(atoal.transaction_id,'#'))-1) transaction_id
                    , (
                        select MAX(aah.row_timestamp)
                          from ame_approvals_history  aah
                         where aah.transaction_id = atoal.transaction_id
                           and aah.application_id = atoal.application_id
                           and aah.group_or_chain_id = atoal.group_or_chain_id
                           and aah.occurrence = atoal.occurrence
                           and aah.approval_status = atoal.approval_status
                           and aah.ACTION_TYPE_ID = atoal.ACTION_TYPE_ID
                           and aah.name = fu.user_name
                      ) history_done
                 FROM ame_temp_old_approver_lists atoal
                    , ame_approval_groups         aag
                    , fnd_user                    fu
                    , per_people_x                P
                    , ame_calling_apps            aca
                WHERE 1=1 --atoal.transaction_id = :transaction_id
                  AND atoal.application_id = aca.application_id
                  AND aca.transaction_type_id in ( 'XXAH Blanket Purchase Agreement','VA-AGREEMENT')
                  AND sysdate BETWEEN aca.start_date AND nvl(aca.end_date,sysdate)
                  AND aag.approval_group_id(+) = atoal.group_or_chain_id
                  AND sysdate BETWEEN aag.start_date(+) AND aag.end_date(+)
                  AND fu.user_name = atoal.NAME
                  AND fu.employee_id = P.person_id
             )
    LOOP

        INSERT INTO XXBI_WF_APPROVAL_PATH
             (
               TRANSACTION_TYPE_ID
             , ORDER_NUMBER
             , APPROVAL_STATUS
             , APPROVER_NAME
             , APPROVAL_GROUP_NAME
             , TRANSACTION_ID
             , HISTORY_DONE
             )
        VALUES
             (
               I.TRANSACTION_TYPE_ID
             , I.ORDER_NUMBER
             , I.APPROVAL_STATUS
             , I.APPROVER_NAME
             , I.APPROVAL_GROUP_NAME
             , I.TRANSACTION_ID
             , I.HISTORY_DONE
             );

        l_count_insert := l_count_insert + 1;

    END LOOP;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_WF_APPROVAL_PATH', estimate_percent => 80, degree => 2);

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records inserted =' || LPAD(l_count_insert,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' --> number of records  updated =' || LPAD(l_count_update,9,' '));
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')|| '- Maintain XXBI_SRC_PROGRESS');
    fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');

    EXECUTE IMMEDIATE 'TRUNCATE TABLE XXBI.XXBI_SRC_PROGRESS';

    INSERT INTO XXBI_SRC_PROGRESS
             ( ORG_ID
             , AGENT_ID
             , STATUS
             , NUM_OF_YEAR
             , NUM_OF_PERIOD
             , USED_BY
             , START_OF_PERIOD
             , PD_AMOUNT
             , NUMBER_OF_PD
             , PREV_YR_PD_AMOUNT
             , PREV_YR_NUMBER_OF_PD
             , PV_AMOUNT
             , NUMBER_OF_PV
             , PREV_YR_PV_AMOUNT
             , PREV_YR_NUMBER_OF_PV
             , VA_AMOUNT
             , NUMBER_OF_VA
             , PREV_YR_VA_AMOUNT
             , PREV_YR_NUMBER_OF_VA
             )
    SELECT gp2.org_id
         , xx.AGENT_ID
         , SUBSTR(xx.authorization_status,1,15)
         , gp2.num_of_year
         , gp2.num_of_period
         , gp2.used_by
         , gp2.START_OF_PERIOD
         , SUM(xx.pd_amount)            pd_amount
         , SUM(xx.number_of_pd)         number_of_pd
         , SUM(xx.prev_yr_pd_amount)    prev_yr_pd_amount
         , SUM(xx.prev_yr_number_of_pd) prev_yr_number_of_pd
         , SUM(xx.pv_amount)            pv_amount
         , SUM(xx.number_of_pv)         number_of_pv
         , SUM(xx.prev_yr_pv_amount)    prev_yr_pv_amount
         , SUM(xx.prev_yr_number_of_pv) prev_yr_number_of_pv
         , SUM(xx.va_amount)            va_amount
         , SUM(xx.number_of_va)         number_of_va
         , SUM(xx.prev_yr_va_amount)    prev_yr_va_amount
         , SUM(xx.prev_yr_number_of_va) prev_yr_number_of_va
      FROM
          (
            SELECT xsa.org_id
                 , xsa.AGENT_ID
                 , xsa.authorization_status
                 , xsa.num_of_year
                 , xsa.num_of_period
                 , xsa.used_by
                 , xsa.START_OF_PERIOD
                 , SUM(DECODE(xsa.year
                             ,xsa.num_of_year,DECODE(xsa.savings_type,'PD', xsa.estimated_savings,0)
                             ,0))                                                                               pd_amount
                 , DECODE(xsa.year
                             ,xsa.num_of_year,DECODE(xsa.savings_type,'PD', count(distinct xsa.po_header_id),0)
                             ,0)                                                                                number_of_pd
                 , SUM(DECODE(xsa.year
                             ,xsa.num_of_year - 1,DECODE(xsa.savings_type,'PD', xsa.estimated_savings,0)
                             ,0))                                                                               prev_yr_pd_amount
                 , DECODE(xsa.year
                             ,xsa.num_of_year - 1,DECODE(xsa.savings_type,'PD', count(distinct xsa.po_header_id),0)
                             ,0)                                                                                prev_yr_number_of_pd
                 , SUM(DECODE(xsa.year
                             ,xsa.num_of_year,DECODE(xsa.savings_type,'PV', xsa.estimated_savings,0)
                             ,0))                                                                               pv_amount
                 , DECODE(xsa.year
                             ,xsa.num_of_year,DECODE(xsa.savings_type,'PV', count(distinct xsa.po_header_id),0)
                             ,0)                                                                                number_of_pv
                 , SUM(DECODE(xsa.year
                             ,xsa.num_of_year - 1,DECODE(xsa.savings_type,'PV', xsa.estimated_savings,0)
                             ,0))                                                                               prev_yr_pv_amount
                 , DECODE(xsa.year
                             ,xsa.num_of_year - 1,DECODE(xsa.savings_type,'PV', count(distinct xsa.po_header_id),0)
                             ,0)                                                                                prev_yr_number_of_pv
                 , SUM(DECODE(xsa.year
                             ,xsa.num_of_year,DECODE(xsa.savings_type,'VA', xsa.estimated_savings,0)
                             ,0))                                                                               va_amount
                 , DECODE(xsa.year
                             ,xsa.num_of_year,DECODE(xsa.savings_type,'VA', count(distinct xsa.po_header_id),0)
                             ,0)                                                                                number_of_va
                 , SUM(DECODE(xsa.year
                             ,xsa.num_of_year - 1,DECODE(xsa.savings_type,'VA', xsa.estimated_savings,0)
                             ,0))                                                                               prev_yr_va_amount
                 , DECODE(xsa.year
                             ,xsa.num_of_year - 1,DECODE(xsa.savings_type,'VA', count(distinct xsa.po_header_id),0)
                             ,0)                                                                                prev_yr_number_of_va
              FROM
                  (
                    SELECT
                           sa.org_id
                         , sa.AGENT_ID
                         , sa.authorization_status
                         , TO_NUMBER(TO_CHAR(sa.start_date,'YYYY')) num_of_year
                         , TO_NUMBER(TO_CHAR(sa.start_date,'MM'))   num_of_period
                         , TRUNC(sa.start_date,'MON')      start_of_period
                         , 'EBS'                           used_by
                         , pbi.po_header_id
                         , pbi.po_line_id
                         , pbi.year
                         , DECODE(pbi.SAVINGS_TYPE
                                 ,'PD','PD'
                                 ,'PV','PV'
                                 ,'VA')                    SAVINGS_TYPE
                         , pbi.OPCO
                         , pbi.estimated_savings
                         , sa.start_date                   FULL_DATE
                      FROM xxah_po_blanket_info pbi
                         , xxbi_src_agreements sa
                     WHERE pbi.estimated_savings != 0
                       AND pbi.savings_type in ('PD','VBI VA','Promo VA','Other VA','PV')
                       AND sa.PO_HEADER_ID = pbi.PO_HEADER_ID
                       AND pbi.year = TO_NUMBER(TO_CHAR(sa.start_date,'YYYY'))
                  UNION ALL
                    SELECT
                           sa.org_id
                         , sa.AGENT_ID
                         , sa.authorization_status
                         , TO_NUMBER(TO_CHAR(sa.start_date,'YYYY')) + 1
                         , TO_NUMBER(TO_CHAR(sa.start_date,'MM'))
                         , TRUNC(sa.start_date,'MON')
                         , 'EBS'
                         , pbi.po_header_id
                         , pbi.po_line_id
                         , pbi.year
                         , DECODE(pbi.SAVINGS_TYPE
                                 ,'PD','PD'
                                 ,'PV','PV'
                                 ,'VA')             SAVINGS_TYPE
                         , pbi.OPCO
                         , pbi.estimated_savings
                         , sa.start_date
                      FROM xxah_po_blanket_info pbi
                         , xxbi_src_agreements sa
                     WHERE pbi.estimated_savings != 0
                       AND pbi.savings_type in ('PD','VBI VA','Promo VA','Other VA','PV')
                       AND sa.PO_HEADER_ID = pbi.PO_HEADER_ID
                       AND pbi.year = TO_NUMBER(TO_CHAR(sa.start_date,'YYYY'))
                   ) xsa
              GROUP BY org_id
                     , AGENT_ID
                     , authorization_status
                     , num_of_year
                     , num_of_period
                     , START_OF_PERIOD
                     , used_by
                     , year
                     , savings_type
          ) xx
         ,( SELECT DISTINCT org_id
                          , num_of_year
                          , num_of_month num_of_period
                          , to_date ( num_of_year||'-'||TO_CHAR(num_of_month ,'FM99'),'YYYY-MM') start_of_period
                          , used_by
              FROM xxbi_gl_periods
             WHERE used_by = 'EBS'
          ) gp2
     WHERE gp2.NUM_OF_YEAR = xx.num_of_year
       AND gp2.ORG_ID = xx.org_id
       AND gp2.NUM_OF_PERIOD >= xx.num_of_period
--       AND gp2.NUM_OF_PERIOD = xx.num_of_period
       AND gp2.USED_BY = xx.used_by
     GROUP BY gp2.org_id
            , xx.AGENT_ID
            , xx.authorization_status
            , gp2.num_of_year
            , gp2.num_of_period
            , gp2.START_OF_PERIOD
            , gp2.used_by;

    dbms_stats.gather_table_stats(ownname => 'XXBI',tabname => 'XXBI_SRC_PROGRESS', estimate_percent => 80, degree => 2);

    COMMIT;
    -- Return 0 for successful completion.
    fnd_file.PUT_LINE (fnd_file.OUTPUT, '--End extract_obiee_data  ('|| TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')||')');
    errbuf  := '';
    retcode := 0;

  EXCEPTION

    WHEN OTHERS
    THEN
      fnd_file.PUT_LINE (fnd_file.LOG, ' an unexpected error occured during '|| l_statement||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      errbuf  := sqlerrm;
      retcode := 2;

  END extract_obiee_data;

END XXAH_VA_OBIEE_PKG;

/
