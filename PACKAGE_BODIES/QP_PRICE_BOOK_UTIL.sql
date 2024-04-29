--------------------------------------------------------
--  DDL for Package Body QP_PRICE_BOOK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_BOOK_UTIL" AS
/*$Header: QPXUPBKB.pls 120.106.12010000.7 2009/11/30 05:04:48 jputta ship $*/

--Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_PRICE_BOOK_UTIL';

/*****************************************************************************
  Procedure to insert Price Book related error and warning messages into
  qp_price_book_messages table.
*****************************************************************************/
PROCEDURE Insert_Price_Book_Messages (
                       p_price_book_messages_tbl IN  price_book_messages_tbl)
IS

i NUMBER;
l_user_id  NUMBER;
l_login_id  NUMBER;

l_message_type_tbl FLAG_TYPE;
l_message_code_tbl VARCHAR30_TYPE;
l_message_text_tbl VARCHAR2000_TYPE;
l_pb_input_header_id_tbl   NUMBER_TYPE;
l_price_book_header_id_tbl NUMBER_TYPE;
l_price_book_line_id_tbl   NUMBER_TYPE;

BEGIN

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.conc_login_id;

  --The following assignments in a loop is required since the database(including
  --10g) does not support the use of a record's attribute in a DML with FORALL.
  IF p_price_book_messages_tbl.COUNT > 0 THEN
    FOR i IN p_price_book_messages_tbl.FIRST..p_price_book_messages_tbl.LAST
    LOOP
      l_message_type_tbl(i) := p_price_book_messages_tbl(i).message_type;
      l_message_code_tbl(i) := p_price_book_messages_tbl(i).message_code;
      l_message_text_tbl(i) := p_price_book_messages_tbl(i).message_text;
      l_pb_input_header_id_tbl(i) :=
                       p_price_book_messages_tbl(i).pb_input_header_id;
      l_price_book_header_id_tbl(i) :=
                       p_price_book_messages_tbl(i).price_book_header_id;
      l_price_book_line_id_tbl(i) :=
                       p_price_book_messages_tbl(i).price_book_line_id;
    END LOOP;
  END IF; --If p_price_book_messages_tbl.count > 0

  FORALL i IN p_price_book_messages_tbl.FIRST..p_price_book_messages_tbl.LAST
    INSERT INTO qp_price_book_messages
    (message_id,
     message_type,
     message_code,
     message_text,
     pb_input_header_id,
     price_book_header_id,
     price_book_line_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login
    )
    VALUES
     (qp_price_book_messages_s.nextval,
      l_message_type_tbl(i),
      l_message_code_tbl(i),
      l_message_text_tbl(i),
      l_pb_input_header_id_tbl(i),
      l_price_book_header_id_tbl(i),
      l_price_book_line_id_tbl(i),
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      l_login_id);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Insert_Price_Book_Messages;

FUNCTION GET_PRICE_LIST_ID
(
  p_price_list_name IN VARCHAR2
)
RETURN NUMBER IS
  x_return NUMBER;
BEGIN
  SELECT list_header_id
  INTO   x_return
  FROM   qp_list_headers_vl
  WHERE  name = p_price_list_name
  AND    list_type_code = 'PRL'
  AND    rownum = 1;
  RETURN x_return;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END GET_PRICE_LIST_ID;

FUNCTION GET_AGREEMENT_ID
(
  p_agreement_name IN VARCHAR2,
  p_pricing_effective_date IN DATE
)
RETURN NUMBER IS
  x_return NUMBER;
BEGIN
  SELECT agreement_id
  INTO   x_return
  FROM   oe_agreements_vl a
  WHERE  name = p_agreement_name
  AND    trunc(nvl(p_pricing_effective_date, sysdate))
           between trunc(nvl(a.start_date_active,
                             p_pricing_effective_date))
           and trunc(nvl(a.end_date_active,
                         p_pricing_effective_date))
  AND    rownum = 1;
  RETURN x_return;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END GET_AGREEMENT_ID;

FUNCTION GET_BSA_ID
(
  p_bsa_name IN VARCHAR2
)
RETURN NUMBER IS
  x_return NUMBER;
BEGIN
  SELECT header_id
  INTO   x_return
  FROM   oe_blanket_headers_all
  WHERE  order_number = p_bsa_name;
  RETURN x_return;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END GET_BSA_ID;

PROCEDURE DEFAULT_CUST_ACCOUNT_ID
(
  p_customer_attr_value IN VARCHAR2,
  x_cust_account_id OUT NOCOPY VARCHAR2
)
IS
BEGIN
  SELECT cust_account_id
  INTO   x_cust_account_id
  FROM   hz_cust_accounts
  WHERE  party_id = p_customer_attr_value;
EXCEPTION
  WHEN OTHERS THEN
    x_cust_account_id := null;
END DEFAULT_CUST_ACCOUNT_ID;


/*****************************************************************************
  Procedure to convert values to ids for Price Book Request's Input Criteria.
*****************************************************************************/
PROCEDURE Convert_PB_Input_Value_to_Id (
      p_pb_input_header_rec IN OUT NOCOPY QP_PRICE_BOOK_PUB.pb_input_header_rec)
IS
BEGIN

  IF p_pb_input_header_rec.limit_products_by = 'PRICE_LIST' THEN
    IF p_pb_input_header_rec.pl_agr_bsa_id IS NULL AND
       p_pb_input_header_rec.pl_agr_bsa_name IS NOT NULL
    THEN
      p_pb_input_header_rec.pl_agr_bsa_id :=
        GET_PRICE_LIST_ID(p_pb_input_header_rec.pl_agr_bsa_name);
    END IF;
  END IF;

  IF p_pb_input_header_rec.price_based_on = 'PRICE_LIST' THEN
    IF p_pb_input_header_rec.pl_agr_bsa_id IS NULL AND
       p_pb_input_header_rec.pl_agr_bsa_name IS NOT NULL
    THEN
      p_pb_input_header_rec.pl_agr_bsa_id :=
        GET_PRICE_LIST_ID( p_pb_input_header_rec.pl_agr_bsa_name);
    END IF;

  ELSIF p_pb_input_header_rec.price_based_on = 'AGREEMENT' THEN
    IF p_pb_input_header_rec.pl_agr_bsa_id IS NULL AND
       p_pb_input_header_rec.pl_agr_bsa_name IS NOT NULL
    THEN
      p_pb_input_header_rec.pl_agr_bsa_id :=
        GET_AGREEMENT_ID(p_pb_input_header_rec.pl_agr_bsa_name,
                         p_pb_input_header_rec.effective_date);
    END IF;

  ELSIF p_pb_input_header_rec.price_based_on = 'BSA' THEN
    IF p_pb_input_header_rec.pl_agr_bsa_id IS NULL AND
       p_pb_input_header_rec.pl_agr_bsa_name IS NOT NULL
    THEN
      p_pb_input_header_rec.pl_agr_bsa_id :=
        GET_BSA_ID(p_pb_input_header_rec.pl_agr_bsa_name);
    END IF;

  END IF;

  IF p_pb_input_header_rec.pub_template_code IS NULL AND
     p_pb_input_header_rec.pub_template_name IS NOT NULL
  THEN
    BEGIN
      SELECT template_code
      INTO   p_pb_input_header_rec.pub_template_code
      FROM   xdo_templates_vl
      WHERE  template_name = p_pb_input_header_rec.pub_template_name
      AND    application_short_name = 'QP'
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        p_pb_input_header_rec.pub_template_code := NULL;
    END;
  END IF;

END Convert_PB_Input_Value_to_Id;


/*****************************************************************************
  Procedure to default values for Price Book Request's Input Criteria.
*****************************************************************************/
PROCEDURE Default_PB_Input_Criteria (
      p_pb_input_header_rec IN OUT NOCOPY QP_PRICE_BOOK_PUB.pb_input_header_rec)
IS
  l_application_id    NUMBER;
  l_user_id           NUMBER;
  l_customer_id       NUMBER;
  l_resp_appl_id      NUMBER;
  l_sold_to_org_id    NUMBER;

BEGIN

  l_user_id := fnd_global.user_id;
  l_resp_appl_id := fnd_global.resp_appl_id;

  IF p_pb_input_header_rec.pricing_perspective_code IS NULL THEN
    BEGIN
      SELECT customer_id
      INTO   l_customer_id
      FROM   fnd_user
      WHERE  user_id = l_user_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_customer_id := NULL;
    END;

    IF l_customer_id IS NOT NULL --external customer
    THEN
      p_pb_input_header_rec.pricing_perspective_code :=
               fnd_profile.value('QP_EXT_DEFAULT_PRICING_PERSPECTIVE');
    ELSE --internal customer
      p_pb_input_header_rec.pricing_perspective_code :=
               fnd_profile.value('QP_INT_DEFAULT_PRICING_PERSPECTIVE');
    END IF;
  END IF;

  IF p_pb_input_header_rec.customer_context IS NULL THEN
    p_pb_input_header_rec.customer_context := 'CUSTOMER';
  END IF;

  --default customer_attribute to 'Customer Name'
  IF p_pb_input_header_rec.customer_attribute IS NULL THEN
    p_pb_input_header_rec.customer_attribute := 'QUALIFIER_ATTRIBUTE2';
  END IF;

  IF p_pb_input_header_rec.customer_attr_value IS NULL THEN
    IF p_pb_input_header_rec.pricing_perspective_code = 'PO' THEN
      p_pb_input_header_rec.customer_attr_value := -1;
    ELSE
      BEGIN
        SELECT customer_id
        INTO   l_customer_id
        FROM   fnd_user
        WHERE  user_id = l_user_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_customer_id := NULL;
      END;

      IF l_customer_id IS NOT NULL THEN
        --If external customer then the price book can be generated only for that
        --customer
        p_pb_input_header_rec.customer_attr_value := l_customer_id;
      END IF;
    END IF; --pricing perspective is 'PO'
  END IF; --customer_attr_value is null


  IF p_pb_input_header_rec.price_book_type_code IS NULL THEN
    p_pb_input_header_rec.price_book_type_code := 'F';
  END IF;

  --Default the cust_account_id using the party_id(customer_id) if there is
  --only one cust_account_id for the party.
  IF p_pb_input_header_rec.cust_account_id IS NULL AND
     p_pb_input_header_rec.customer_attr_value IS NOT NULL
  THEN
    DEFAULT_CUST_ACCOUNT_ID(p_pb_input_header_rec.customer_attr_value,
                            p_pb_input_header_rec.cust_account_id);
  END IF;

  --Default party_id(customer_id) using cust_account_id if specified
  IF p_pb_input_header_rec.customer_attr_value IS NULL AND
     p_pb_input_header_rec.cust_account_id IS NOT NULL
  THEN
    BEGIN
      SELECT party_id
      INTO   p_pb_input_header_rec.customer_attr_value
      FROM   hz_cust_accounts
      WHERE  cust_account_id = p_pb_input_header_rec.cust_account_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_pb_input_header_rec.customer_attr_value := NULL;
    END;
  END IF;

  --Get application id for the appl corresponding to pricing perspective
  BEGIN
    SELECT application_id
    INTO   l_application_id
    FROM   fnd_application
    WHERE  application_short_name =
             p_pb_input_header_rec.pricing_perspective_code;
  EXCEPTION
    WHEN OTHERS THEN
      l_application_id := NULL;
  END;

  --Set the apps context for the pricing perspective application so that
  --profile options at the application level are retrieved for this
  --application and not QP.
  fnd_global.apps_initialize(l_user_id,
                             fnd_global.resp_id,
                             l_application_id);

  --No defaulting reqd for columns that do not impact Delta price book creation
  IF nvl(p_pb_input_header_rec.price_book_type_code, 'F') <> 'D' THEN

    IF p_pb_input_header_rec.limit_products_by IN ('ITEM', 'ITEM_CATEGORY',
                                                   'ALL_ITEMS') AND
       p_pb_input_header_rec.product_context IS NULL
    THEN
      p_pb_input_header_rec.product_context := 'ITEM';
    END IF;

    IF p_pb_input_header_rec.limit_products_by = 'ITEM' AND
       p_pb_input_header_rec.product_attribute IS NULL
    THEN
      p_pb_input_header_rec.product_attribute := 'PRICING_ATTRIBUTE1';
    END IF;

    IF p_pb_input_header_rec.limit_products_by = 'ITEM_CATEGORY' AND
       p_pb_input_header_rec.product_attribute IS NULL
    THEN
      p_pb_input_header_rec.product_attribute := 'PRICING_ATTRIBUTE2';
    END IF;

    IF p_pb_input_header_rec.limit_products_by = 'ALL_ITEMS' AND
       p_pb_input_header_rec.product_attribute IS NULL
    THEN
      p_pb_input_header_rec.product_attribute := 'PRICING_ATTRIBUTE3';
      p_pb_input_header_rec.product_attr_value := 'ALL';
    END IF;

    IF p_pb_input_header_rec.limit_products_by = 'PRICE_LIST' AND
       p_pb_input_header_rec.price_based_on IS NULL
    THEN
      p_pb_input_header_rec.price_based_on := 'PRICE_LIST';
    END IF;


    IF p_pb_input_header_rec.currency_code IS NULL THEN
      IF p_pb_input_header_rec.limit_products_by = 'PRICE_LIST' AND
         p_pb_input_header_rec.pl_agr_bsa_id IS NOT NULL
      THEN

        --If multi-currency is not installed, default to currency of pricelist
        IF  NOT(UPPER(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED')) IN
                ('Y','YES'))
        AND nvl(fnd_profile.value('QP_MULTI_CURRENCY_USAGE'), 'N') <> 'Y'
        THEN
          BEGIN
            SELECT currency_code
            INTO   p_pb_input_header_rec.currency_code
            FROM   qp_list_headers_b
            WHERE  list_header_id = p_pb_input_header_rec.pl_agr_bsa_id;
          EXCEPTION
            WHEN OTHERS THEN
              p_pb_input_header_rec.currency_code := NULL;
          END;
        END IF; --If multi-currency is not installed

      END IF; --if pl_agr_bsa_id is not null
    END IF;--if currency_code is null

    IF p_pb_input_header_rec.item_quantity IS NULL THEN
      p_pb_input_header_rec.item_quantity := 1;
    END IF;

  END IF; --Defaulting only if not Delta Price Book

  IF p_pb_input_header_rec.effective_date IS NULL THEN
    p_pb_input_header_rec.effective_date := sysdate;
  END IF;

  IF p_pb_input_header_rec.dlv_xml_flag IS NULL THEN
    p_pb_input_header_rec.dlv_xml_flag := 'N';
  END IF;

  IF p_pb_input_header_rec.dlv_email_flag IS NULL THEN
    p_pb_input_header_rec.dlv_email_flag := 'N';
  END IF;

  IF p_pb_input_header_rec.dlv_printer_flag IS NULL THEN
    p_pb_input_header_rec.dlv_printer_flag := 'N';
  END IF;

  IF p_pb_input_header_rec.generation_time_code IS NULL THEN
    p_pb_input_header_rec.generation_time_code := 'IMMEDIATE';
  END IF;

  IF p_pb_input_header_rec.org_id IS NULL THEN
    p_pb_input_header_rec.org_id := MO_UTILS.get_default_org_id;
  END IF;

  IF p_pb_input_header_rec.request_type_code IS NULL THEN
    p_pb_input_header_rec.request_type_code :=
         fnd_profile.value('QP_PRICING_PERSPECTIVE_REQUEST_TYPE');
  END IF;

  IF p_pb_input_header_rec.publish_existing_pb_flag IS NULL THEN
    p_pb_input_header_rec.publish_existing_pb_flag := 'N';
  END IF;

  IF p_pb_input_header_rec.overwrite_existing_pb_flag IS NULL THEN
    p_pb_input_header_rec.overwrite_existing_pb_flag := 'N';
  END IF;

  IF p_pb_input_header_rec.request_origination_code IS NULL THEN
    p_pb_input_header_rec.request_origination_code := 'API';
  END IF;

  IF p_pb_input_header_rec.pub_template_code IS NOT NULL AND
     p_pb_input_header_rec.pub_output_document_type IS NULL AND
     p_pb_input_header_rec.dlv_printer_flag = 'Y' AND
     nvl(p_pb_input_header_rec.dlv_email_flag, 'N') <> 'Y'
  THEN
    p_pb_input_header_rec.pub_output_document_type := 'PDF';
  END IF;

  --reset the application_id back to the original appl id
  fnd_global.apps_initialize(l_user_id,
                             fnd_global.resp_id,
                             l_resp_appl_id);

END Default_PB_Input_Criteria;


/*****************************************************************************
  Procedure to Validate Price Book Input Validation messages into
  qp_price_book_messages table and also return all messages concatenated in
  x_return_status for use with get_catalog and UI.
*****************************************************************************/
PROCEDURE Validate_PB_Input_Criteria (
              p_pb_input_header_rec IN qp_pb_input_headers_vl%ROWTYPE,
              p_pb_input_lines_tbl  IN pb_input_lines_tbl,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_return_text         IN OUT NOCOPY VARCHAR2)
IS

TYPE currency_code_tbl IS TABLE OF fnd_currencies_vl.currency_code%TYPE
  INDEX BY BINARY_INTEGER;

l_customer_id                NUMBER;
l_valid_pl                   VARCHAR2(1);
l_pte_code                   VARCHAR2(30);
l_request_type_code          VARCHAR2(30);
l_count                      NUMBER;
l_valid_currency       VARCHAR2 (1);
l_currency_code_tbl          currency_code_tbl;
l_price_book_messages_tbl    price_book_messages_tbl;
l_message_text               VARCHAR2(2000);
i                            NUMBER := 1;
l_application_id             NUMBER;
l_user_id                    NUMBER;
l_pricing_status       VARCHAR2(1);
l_resp_appl_id               NUMBER;
l_party_id_match       VARCHAR2(1);
l_category_valid             BOOLEAN;
l_name                       VARCHAR2(2000);
l_desc                       VARCHAR2(2000);
l_count2               NUMBER := 0;

v_valueset_r     fnd_vset.valueset_r;
v_valueset_dr    fnd_vset.valueset_dr;
l_datatype       VARCHAR2(1);
l_value          VARCHAR2(150);
l_id             VARCHAR2(150);
l_valueset_id    NUMBER;

BEGIN

  l_user_id := fnd_global.user_id;
  l_resp_appl_id := fnd_global.resp_appl_id;

  --If generating price book
  IF nvl(p_pb_input_header_rec.publish_existing_pb_flag, 'N') <> 'Y' THEN
    --Check if org_id is not null and valid. Else return, do not proceed.
    IF p_pb_input_header_rec.org_id IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('FND', 'MO_ORG_REQUIRED');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'MO_ORG_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
      Insert_Price_Book_Messages (l_price_book_messages_tbl);
      l_price_book_messages_tbl.delete;
      RETURN;
    ELSE
      IF MO_GLOBAL.check_access(p_pb_input_header_rec.org_id) <> 'Y' THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('FND', 'MO_ORG_INVALID');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'MO_ORG_INVALID';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
        Insert_Price_Book_Messages (l_price_book_messages_tbl);
        l_price_book_messages_tbl.delete;
        RETURN;
      END IF; --If check_access returns 'N'
    END IF; --If org id is null
  END IF;--If generating new pb


  IF p_pb_input_header_rec.pricing_perspective_code IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICING_PERSPECTIVE_CODE');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
    Insert_Price_Book_Messages (l_price_book_messages_tbl);
    l_price_book_messages_tbl.delete;
    RETURN;
  ELSE
    --Get application id for the appl corresponding to pricing perspective
    BEGIN
      SELECT application_id
      INTO   l_application_id
      FROM   fnd_application
      WHERE  application_short_name =
                 p_pb_input_header_rec.pricing_perspective_code;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_PRICING_PERSPECTIVE');
        FND_MESSAGE.SET_TOKEN('CODE',
                         p_pb_input_header_rec.pricing_perspective_code);
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code
                        := 'QP_INVALID_PRICING_PERSPECTIVE';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        l_application_id := NULL;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
        Insert_Price_Book_Messages (l_price_book_messages_tbl);
        l_price_book_messages_tbl.delete;
        RETURN;
    END;

    IF p_pb_input_header_rec.pricing_perspective_code = 'QP' THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_PRICING_PERSPECTIVE');
      FND_MESSAGE.SET_TOKEN('CODE',
                         p_pb_input_header_rec.pricing_perspective_code);
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_INVALID_PRICING_PERSPECTIVE';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
      Insert_Price_Book_Messages (l_price_book_messages_tbl);
      l_price_book_messages_tbl.delete;
      RETURN;
    END IF;

    --Set the application id corresponding to the pricing perspective so that
    --profile options at the application level are retrieved for this
    --application and not QP.
    fnd_global.apps_initialize(l_user_id,
                             fnd_global.resp_id,
                             l_application_id);

    l_request_type_code :=
                 fnd_profile.value('QP_PRICING_PERSPECTIVE_REQUEST_TYPE');

    IF l_request_type_code IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_REQUEST_TYPE_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('APPLICATION',
                    p_pb_input_header_rec.pricing_perspective_code);
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_REQUEST_TYPE_NOT_FOUND';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      l_application_id := NULL;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
      Insert_Price_Book_Messages (l_price_book_messages_tbl);
      l_price_book_messages_tbl.delete;
      RETURN;
    END IF;

    --Update the input_header table with the request_type_code
    UPDATE qp_pb_input_headers_b
    SET    request_type_code = l_request_type_code
    WHERE  pb_input_header_id = p_pb_input_header_rec.pb_input_header_id;

    BEGIN
      SELECT pte_code
      INTO   l_pte_code
      FROM   qp_pte_request_types_v
      WHERE  request_type_code = l_request_type_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_pte_code := NULL;
    END;
  END IF; --pricing_perspective_code is null

  --Check if Customer Context is valid
  IF p_pb_input_header_rec.customer_context IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CUSTOMER_CONTEXT');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  ELSIF p_pb_input_header_rec.customer_context <> 'CUSTOMER' THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_CUSTOMER_CONTEXT');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_CUSTOMER_CONTEXT';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;


  --Check if Customer Attribute is valid
  IF p_pb_input_header_rec.customer_attribute IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CUSTOMER_ATTRIBUTE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
  ELSIF p_pb_input_header_rec.customer_attribute <> 'QUALIFIER_ATTRIBUTE2'
  THEN
      x_return_status := 'E';
      --Must be only Customer Name
       FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_CUSTOMER_ATTRIBUTE');
       l_message_text := FND_MESSAGE.GET;
       l_price_book_messages_tbl(i).message_code := 'QP_INVALID_CUSTOMER_ATTRIBUTE';
       l_price_book_messages_tbl(i).message_text := l_message_text;
       l_price_book_messages_tbl(i).pb_input_header_id :=
                              p_pb_input_header_rec.pb_input_header_id;
       i := i + 1;
       x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;


  --Check if the user is an external or internal user
  BEGIN
    SELECT customer_id
    INTO   l_customer_id
    FROM   fnd_user
    WHERE  user_id = l_user_id;

  EXCEPTION
    WHEN OTHERS THEN
      l_customer_id := NULL;

  END; --Check if external or internal user

  IF l_customer_id IS NOT NULL THEN --External User

    BEGIN
      SELECT 'Y'
      INTO   l_party_id_match
      FROM   dual
      WHERE  EXISTS (
               SELECT 'x'
               FROM   hz_relationships rel, hz_parties party3,
                      hz_parties party4, hz_parties party5
               WHERE rel.party_id = party5.party_id
               AND   party5.party_type = 'PARTY_RELATIONSHIP'
               AND   party5.status = 'A'
               AND   trunc(rel.start_date) <= trunc(sysdate)
               AND   trunc(nvl(rel.end_date, sysdate)) >= trunc(sysdate)
               AND   rel.subject_id = party3.party_id
               AND   party3.party_type = 'PERSON'
               AND   party3.status = 'A'
               AND   rel.object_id = party4.party_id
               AND   party4.party_type = 'ORGANIZATION'
               AND   party4.status = 'A'
               AND   rel.subject_table_name = 'HZ_PARTIES'
               AND   rel.object_table_name = 'HZ_PARTIES'
               AND   rel.relationship_id IN
                    (SELECT party_relationship_id
                     FROM   hz_org_contacts org_con
                     WHERE  rel.relationship_id =
                                      org_con.party_relationship_id
                     AND org_con.status ='A' )
               AND party5.party_id = l_customer_id
               AND party4.party_id = p_pb_input_header_rec.customer_attr_value);
    EXCEPTION
      WHEN OTHERS THEN
        l_party_id_match := 'N';
    END;

    --Input customer must match the customer associated with the user
    IF p_pb_input_header_rec.customer_attr_value IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CUSTOMER_ATTR_VALUE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);

    --either the party id on the price book should match the party id on the
    --user or the party id on the user must belong to another party of type
    --organization such that the org party id matches the one on the price book
    ELSIF (p_pb_input_header_rec.customer_attr_value <> l_customer_id AND
           l_party_id_match <> 'Y')
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_CUSTOMER_NOT_MATCHING');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_CUSTOMER_NOT_MATCHING';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    IF p_pb_input_header_rec.pricing_perspective_code = 'PO' THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICING_PERSPECTIVE_CODE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

  ELSE -- Internal User

    --Get Catalog not supported for Internal User
    IF p_pb_input_header_rec.request_origination_code = 'XML' THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_GET_CAT_NOT_FOR_INT_USER');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_GET_CAT_NOT_FOR_INT_USER';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    IF p_pb_input_header_rec.customer_attr_value IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CUSTOMER_ATTR_VALUE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);

    ELSE --If customer_attr_value is not null

      --If pricing perspective is PO then cust_attr_value must be -1
      IF p_pb_input_header_rec.pricing_perspective_code = 'PO' THEN
        IF p_pb_input_header_rec.customer_attr_value <> -1 THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_PO_CUSTOMER');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_PO_CUSTOMER';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        END IF;

      ELSIF (p_pb_input_header_rec.customer_context = 'CUSTOMER') AND
            (p_pb_input_header_rec.customer_attribute = 'QUALIFIER_ATTRIBUTE2') THEN
            --Check if Customer is valid
        BEGIN
          SELECT 1
          INTO   l_count
          FROM   hz_parties
          WHERE  party_id = p_pb_input_header_rec.customer_attr_value
          AND    rownum = 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_count := 0;
        END;

        IF l_count = 0 THEN -- invalid customer
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_CUSTOMER');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_CUSTOMER';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        END IF;

      END IF; --Check if customer is valid

    END IF; --If customer attr value is null

  END IF; --If External User

  IF p_pb_input_header_rec.pricing_perspective_code = 'PO' THEN
    --If pricing perspective is PO then cust_account_id must be null
    IF p_pb_input_header_rec.cust_account_id IS NOT NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_PO_CUST_ACCT');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_PO_CUST_ACCT';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

  ELSE --pricing perspective is not PO

    --Validate if the party_id(customer) and cust_account_id combination is valid
    IF p_pb_input_header_rec.cust_account_id IS NOT NULL
    THEN
      BEGIN
        SELECT 1
        INTO   l_count
        FROM   hz_cust_accounts
        WHERE  cust_account_id = p_pb_input_header_rec.cust_account_id
        AND    party_id = p_pb_input_header_rec.customer_attr_value;
      EXCEPTION
        WHEN OTHERS THEN
          l_count := 0;
      END;

      IF l_count = 0 THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_CUST_AND_ACCT_COMBI_INVALID');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code :=
                                      'QP_CUST_AND_ACCT_COMBI_INVALID';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      END IF;
    END IF; --If cust_account_id is not null

  END IF; --If pricing perspective is PO

  --Get Pricing Status - Basic Pricing or Advanced Pricing
  l_pricing_status := QP_UTIL.Get_QP_Status;

  --Check if price_book_type_code is valid
  IF p_pb_input_header_rec.price_book_type_code IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICE_BOOK_TYPE_CODE');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  ELSE
    IF l_pricing_status = 'I' THEN --Advanced Pricing
      IF NOT (p_pb_input_header_rec.price_book_type_code = 'F' OR
              p_pb_input_header_rec.price_book_type_code = 'D')
      THEN -- invalid price_book_type_code
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICE_BOOK_TYPE_CODE');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      END IF;
    ELSIF l_pricing_status = 'S' THEN --Basic Pricing
      IF nvl(p_pb_input_header_rec.price_book_type_code, 'F') <> 'F' THEN
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICE_BOOK_TYPE_CODE');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      END IF;
    END IF; --If Advanced Pricing
  END IF; --If price_book_type_code is null


  --Check if price book name is not-null
  IF p_pb_input_header_rec.price_book_name IS NULL THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICE_BOOK_NAME');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;


  --If delta price book to be generated
  IF (nvl(p_pb_input_header_rec.publish_existing_pb_flag, 'N') <> 'Y') AND
     (p_pb_input_header_rec.price_book_type_code = 'D')
  THEN
    --Check if a corresponding full price book exists
    BEGIN
      SELECT 1
      INTO   l_count
      FROM   qp_price_book_headers_vl
      WHERE  price_book_name = p_pb_input_header_rec.price_book_name
      AND    price_book_type_code = 'F'
      AND    customer_id = p_pb_input_header_rec.customer_attr_value
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_count := 0;
    END;

    IF l_count = 0 THEN --corresponding full price book does not exist
      FND_MESSAGE.SET_NAME('QP', 'QP_FULL_PRICE_BOOK_MUST_EXIST');
      x_return_status := 'E';
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_FULL_PRICE_BOOK_MUST_EXIST';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

  END IF; --If delta price book to be generated, check if full price book exists

  --If Basic Pricing user then xml messaging is not supported
  IF l_pricing_status = 'S' THEN
    IF p_pb_input_header_rec.request_origination_code = 'XML' OR
       p_pb_input_header_rec.dlv_xml_flag = 'Y'
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_XML_NOT_FOR_BASIC');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_XML_NOT_FOR_BASIC';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;

  --If pricing perspective is PO then xml messaging is not supported
  IF p_pb_input_header_rec.pricing_perspective_code = 'PO' THEN
    IF p_pb_input_header_rec.request_origination_code = 'XML' OR
       p_pb_input_header_rec.dlv_xml_flag = 'Y'
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_XML_NOT_FOR_PO');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_XML_NOT_FOR_PO';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    IF p_pb_input_header_rec.dlv_xml_site_id IS NOT NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_PO_XML_SITE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_PO_XML_SITE';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;

  --If called from Get_Catalog only XML Message allowed, not printing or email.
  IF p_pb_input_header_rec.request_origination_code = 'XML' THEN
    IF nvl(p_pb_input_header_rec.dlv_printer_flag, 'N') = 'Y' OR
       nvl(p_pb_input_header_rec.dlv_email_flag, 'N') = 'Y'
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ONLY_XML_DELIVERY_ALLOWED');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ONLY_XML_DELIVERY_ALLOWED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;


  --Validate that flags are either 'Y', 'N' or null
  IF p_pb_input_header_rec.publish_existing_pb_flag IS NOT NULL AND
     p_pb_input_header_rec.publish_existing_pb_flag NOT IN ('Y', 'N')
  THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PUBLISH_EXISTING_PB_FLAG');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;

  IF p_pb_input_header_rec.overwrite_existing_pb_flag IS NOT NULL AND
     p_pb_input_header_rec.overwrite_existing_pb_flag NOT IN ('Y', 'N')
  THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'OVERWRITE_EXISTING_PB_FLAG');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;

  IF p_pb_input_header_rec.dlv_email_flag IS NOT NULL AND
     p_pb_input_header_rec.dlv_email_flag NOT IN ('Y', 'N')
  THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DLV_EMAIL_FLAG');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;

  IF p_pb_input_header_rec.dlv_printer_flag IS NOT NULL AND
     p_pb_input_header_rec.dlv_printer_flag NOT IN ('Y', 'N')
  THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DLV_PRINTER_FLAG');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;

  IF p_pb_input_header_rec.dlv_xml_flag IS NOT NULL AND
     p_pb_input_header_rec.dlv_xml_flag NOT IN ('Y', 'N')
  THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DLV_XML_FLAG');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;



  --If delivery option is email then email_addresses must be specified.
  IF p_pb_input_header_rec.dlv_email_flag = 'Y' THEN
    IF p_pb_input_header_rec.dlv_email_addresses IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DLV_EMAIL_ADDRESSES');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;

  IF p_pb_input_header_rec.generation_time_code NOT IN ('IMMEDIATE', 'SCHEDULE')
  THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'GENERATION_TIME_CODE');
    l_message_text := FND_MESSAGE.GET;
    l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
    l_price_book_messages_tbl(i).message_text := l_message_text;
    l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
    i := i + 1;
    x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END IF;

  IF p_pb_input_header_rec.generation_time_code = 'SCHEDULE' THEN
    IF p_pb_input_header_rec.gen_schedule_date IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'GEN_SCHEDULE_DATE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;

  --Validate publishing template information
  IF nvl(p_pb_input_header_rec.dlv_email_flag, 'N') = 'Y' OR
     nvl(p_pb_input_header_rec.dlv_printer_flag, 'N') = 'Y' OR
     p_pb_input_header_rec.pub_template_code IS NOT NULL --view document
  THEN

    IF p_pb_input_header_rec.pub_template_code is NULL
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'pub_template_code');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    IF p_pb_input_header_rec.pub_language is NULL
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'pub_language');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    IF p_pb_input_header_rec.pub_territory is NULL
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'pub_territory');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    BEGIN
      SELECT 1
      INTO   l_count
      FROM   xdo_templates_vl
      WHERE  template_code = p_pb_input_header_rec.pub_template_code
      AND    application_short_name = 'QP'
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_count := 0;
    END;

    IF l_count = 0 THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PUB_TEMPLATE_CODE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    BEGIN
      SELECT 1
      INTO   l_count
      FROM   xdo_lobs tmpl, xdo_templates_vl t
      WHERE  t.APPLICATION_SHORT_NAME = 'QP'
      AND    t.TEMPLATE_CODE = tmpl.LOB_CODE
      AND    tmpl.LOB_TYPE in ('TEMPLATE','MLS_TEMPLATE')
      AND    tmpl.FILE_STATUS = 'E'
      AND    t.template_code = p_pb_input_header_rec.pub_template_code
      AND    lower(tmpl.LANGUAGE) = lower(p_pb_input_header_rec.pub_language)
      AND    upper(tmpl.TERRITORY) = upper(p_pb_input_header_rec.pub_territory);
    EXCEPTION
      WHEN OTHERS THEN
        l_count := 0;
    END;

    IF l_count = 0 THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_TEMPLATE_COMBI_INVALID');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_TEMPLATE_COMBI_INVALID';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

  END IF; --If email or printer delivery flag is 'Y' or template code not null

  --If printer flag is checked and email flag is not checked then only
  --pdf output doc type is permitted
  IF nvl(p_pb_input_header_rec.dlv_printer_flag, 'N') = 'Y' AND
     nvl(p_pb_input_header_rec.dlv_email_flag, 'N') <> 'Y'
  THEN
    IF p_pb_input_header_rec.pub_output_document_type <> 'PDF' THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PUB_OUTPUT_DOCUMENT_TYPE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;

  --If template_code is not null but document type is null
  IF p_pb_input_header_rec.dlv_email_flag= 'Y' OR
    (nvl(p_pb_input_header_rec.dlv_email_flag, 'N') = 'N' AND
     nvl(p_pb_input_header_rec.dlv_printer_flag, 'N') = 'N')
  THEN
    IF p_pb_input_header_rec.pub_template_code IS NOT NULL AND
       p_pb_input_header_rec.pub_output_document_type IS NULL
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PUB_OUTPUT_DOCUMENT_TYPE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;
  END IF;

  --If dlv_xml_flag is checked then dlv_xml_site_id is required
  IF p_pb_input_header_rec.dlv_xml_flag = 'Y' THEN
    IF p_pb_input_header_rec.dlv_xml_site_id IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DLV_XML_SITE_ID');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    ELSE       --dlv_xml_site_id is not null
      BEGIN
        SELECT 1
        INTO   l_count
        FROM   ecx_tp_headers eth, ecx_tp_details etd,
               ecx_ext_processes eep, ecx_transactions et,
               hz_parties hp, hz_party_sites hps, hz_locations hl
        WHERE eth.party_id = p_pb_input_header_rec.customer_attr_value
        AND   eth.party_site_id = p_pb_input_header_rec.dlv_xml_site_id
        AND   eth.tp_header_id = etd.tp_header_id
        AND   etd.EXT_PROCESS_ID = eep.EXT_PROCESS_ID
        AND   eth.party_id = hp.party_id
        AND   eth.party_site_id = hps.party_site_id
        AND   hps.location_id = hl.location_id
        AND   eep.transaction_id = et.transaction_id
        AND   et.transaction_type = 'QP'
        AND   et.transaction_subtype = 'CATSO'
        AND   eep.direction = 'OUT';
      EXCEPTION
        WHEN OTHERS THEN
          l_count := 0;
      END;

      IF l_count = 0 THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DLV_XML_SITE_ID');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      END IF;

    END IF;
  END IF;

  --If re-publishing an existing price book, no generation is involved
  IF p_pb_input_header_rec.publish_existing_pb_flag = 'Y' THEN

    --The price book to be re-published must exist
    BEGIN
      SELECT 1
      INTO   l_count
      FROM   qp_price_book_headers_vl
      WHERE  price_book_name = p_pb_input_header_rec.price_book_name
      AND    price_book_type_code = p_pb_input_header_rec.price_book_type_code
      AND    customer_id = p_pb_input_header_rec.customer_attr_value
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_count := 0;
    END;

    IF l_count = 0 THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_PRICE_BOOK_DOES_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          p_pb_input_header_rec.price_book_name);
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_TYPE_CODE',
                          p_pb_input_header_rec.price_book_type_code);
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_PRICE_BOOK_DOES_NOT_EXIST';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

  ELSE--Generate and/or publish new price book

    --Check that Price Book(s) to be generated does(do) not exist
    BEGIN
      SELECT 1
      INTO   l_count
      FROM   qp_price_book_headers_vl
      WHERE  price_book_name = p_pb_input_header_rec.price_book_name
      AND    price_book_type_code = p_pb_input_header_rec.price_book_type_code
      AND    customer_id = p_pb_input_header_rec.customer_attr_value
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_count := 0;
    END;

    IF l_count > 0 AND nvl(p_pb_input_header_rec.overwrite_existing_pb_flag, 'N') = 'N'
    THEN
      x_return_status := 'E';
      -- Price book to be generated already exists
      FND_MESSAGE.SET_NAME('QP', 'QP_PRICE_BOOK_ALREADY_EXISTS');
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          p_pb_input_header_rec.price_book_name);
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_TYPE_CODE',
                          p_pb_input_header_rec.price_book_type_code);
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_PRICE_BOOK_ALREADY_EXISTS';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    --Check that Price Book(s) to be generated does(do) not exist in another
    --org outside the accessible orgs
    BEGIN
      SELECT 1
      INTO   l_count2
      FROM   qp_price_book_headers_all_b b, qp_price_book_headers_tl t
      WHERE  b.price_book_header_id = t.price_book_header_id
      AND    t.language = userenv('LANG')
      AND    b.price_book_type_code = p_pb_input_header_rec.price_book_type_code
      AND    b.customer_id = p_pb_input_header_rec.customer_attr_value
      AND    t.price_book_name = p_pb_input_header_rec.price_book_name
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_count2 := 0;
    END;

    IF l_count = 0 AND l_count2 > 0 THEN
      x_return_status := 'E';
      -- Price book to be generated already exists
      FND_MESSAGE.SET_NAME('QP', 'QP_PB_EXISTS_IN_ANOTHER_ORG');
      FND_MESSAGE.SET_TOKEN('PRICE_BOOK_NAME',
                          p_pb_input_header_rec.price_book_name);
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_PB_EXISTS_IN_ANOTHER_ORG';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    --Check if limit_products_by is valid
    IF p_pb_input_header_rec.limit_products_by IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'LIMIT_PRODUCTS_BY');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    ELSIF p_pb_input_header_rec.limit_products_by NOT IN
                ('ITEM', 'ITEM_CATEGORY', 'ALL_ITEMS', 'PRICE_LIST')
    THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'LIMIT_PRODUCTS_BY');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                           p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    ELSE --Validate product_context, product_attribute, product_attr_value
      IF p_pb_input_header_rec.limit_products_by = 'ITEM' THEN
        IF p_pb_input_header_rec.product_context IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attribute IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_context <> 'ITEM' THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attribute <> 'PRICING_ATTRIBUTE1'
          THEN --Product Attribute must be 'Item Number'
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attr_value IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTR_VALUE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSE
          BEGIN
            SELECT 1
            INTO   l_count
            FROM   mtl_system_items_kfv
            WHERE  inventory_item_id =
                       to_number(p_pb_input_header_rec.product_attr_value)
            AND    organization_id = QP_UTIL.Get_Item_Validation_Org
            AND    purchasing_enabled_flag =
                    decode(p_pb_input_header_rec.pricing_perspective_code,
                           'PO', 'Y', purchasing_enabled_flag)
            AND    rownum = 1;
          EXCEPTION
            WHEN OTHERS THEN
              l_count := 0;
          END;

          IF l_count = 0 THEN
            x_return_status := 'E';
            FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTR_VALUE');
            l_message_text := FND_MESSAGE.GET;
            l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                  p_pb_input_header_rec.pb_input_header_id;
            i := i + 1;
            x_return_text := x_return_text || substr(l_message_text, 1, 240);
          END IF;
        END IF;

      ELSIF p_pb_input_header_rec.limit_products_by = 'ITEM_CATEGORY' THEN
        IF p_pb_input_header_rec.product_context IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attribute IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_context <> 'ITEM' THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                  p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attribute <> 'PRICING_ATTRIBUTE2'
        THEN --Product Attribute must be 'Item Category'
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                  p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attr_value IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTR_VALUE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSE
          --Get pte_code for the request_type_code
          BEGIN
            SELECT pte_code
            INTO   l_pte_code
            FROM   qp_pte_request_types_b
            WHERE  request_type_code = l_request_type_code;
          EXCEPTION
            WHEN OTHERS THEN
              l_pte_code := 'ORDFUL';
          END;

          --Check if category is valid using Product Hierarchy validation API
          QP_UTIL.get_item_cat_info(
               p_item_id => to_number(p_pb_input_header_rec.product_attr_value),
                                    --category_id
               p_item_pte => l_pte_code,
               p_item_ss => null, --all source systems in the pte
               x_item_name => l_name,
               x_item_desc => l_desc,
               x_is_valid => l_category_valid);

          IF l_category_valid = FALSE THEN
            x_return_status := 'E';
            FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTR_VALUE');
            l_message_text := FND_MESSAGE.GET;
            l_price_book_messages_tbl(i).message_code :=
                                              'QP_INVALID_ATTRIBUTE';
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                    p_pb_input_header_rec.pb_input_header_id;
            i := i + 1;
            x_return_text := x_return_text || substr(l_message_text, 1, 240);
          END IF;
        END IF; --If product_context is null...

      ELSIF p_pb_input_header_rec.limit_products_by = 'ALL_ITEMS' THEN
        IF p_pb_input_header_rec.product_context IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attribute IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_context <> 'ITEM' THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                  p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attribute <> 'PRICING_ATTRIBUTE3'
        THEN --Product Attribute must be 'All Items'
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                  p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attr_value IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTR_VALUE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_header_rec.product_attr_value <> 'ALL' THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRODUCT_ATTR_VALUE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        END IF;--If product context is null when limit by is ALL_ITEMS

      ELSIF p_pb_input_header_rec.limit_products_by = 'PRICE_LIST' THEN
        IF p_pb_input_header_rec.pl_agr_bsa_id IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PL_AGR_BSA_ID');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code :=
                                              'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF nvl(p_pb_input_header_rec.price_based_on, 'X') <> 'PRICE_LIST' THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICE_BASED_ON');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                  p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSE
          BEGIN
            SELECT 1
            INTO   l_count
            FROM   qp_list_headers_vl
            WHERE  list_type_code = 'PRL'
            AND    nvl(list_source_code, 'X') <> 'BSO'
            AND    nvl(active_flag, 'N') = 'Y'
            AND    (global_flag = 'Y' OR
                      orig_org_id = p_pb_input_header_rec.org_id)
            AND    source_system_code IN (SELECT application_short_name
                                          FROM   qp_pte_source_systems
                                          WHERE  pte_code = l_pte_code)
            AND    list_header_id = p_pb_input_header_rec.pl_agr_bsa_id
            AND    rownum = 1;
          EXCEPTION
            WHEN OTHERS THEN
              l_count := 0;
          END;

          IF l_count = 0 THEN
            x_return_status := 'E';
            FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PL_AGR_BSA_ID');
            l_message_text := FND_MESSAGE.GET;
            l_price_book_messages_tbl(i).message_code :=
                                          'QP_INVALID_ATTRIBUTE';
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                   p_pb_input_header_rec.pb_input_header_id;
            i := i + 1;
            x_return_text := x_return_text || substr(l_message_text, 1, 240);
          END IF;

        END IF; --If pl_agr_bsa_id is null
      END IF; --If limit_products_by = 'ITEM'
    END IF; --If limit_products_by <> ITEM,ITEM_CATEGORY,ALL_ITEMS or PRICE_LIST


    --Validate price_based_on
    IF p_pb_input_header_rec.price_based_on IS NOT NULL THEN

      --If pricing perspective is PO then only PRICE_LIST is valid
      IF  p_pb_input_header_rec.pricing_perspective_code = 'PO' AND
          p_pb_input_header_rec.price_based_on  <> 'PRICE_LIST'
      THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_PO_PRICE_BASED_ON');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_PO_PRICE_BASED_ON';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      ELSIF  p_pb_input_header_rec.price_based_on NOT IN ('PRICE_LIST',
                                                'AGREEMENT', 'BSA')
      THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PRICE_BASED_ON');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      ELSE --validate pl_agr_bsa_id
        IF p_pb_input_header_rec.pl_agr_bsa_id IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PL_AGR_BSA_ID');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSE
          IF p_pb_input_header_rec.price_based_on = 'PRICE_LIST' THEN
            BEGIN
              SELECT 1
              INTO   l_count
              FROM   qp_list_headers_vl
              WHERE  list_type_code = 'PRL'
              AND    nvl(list_source_code, 'X') <> 'BSO'
              AND    nvl(active_flag, 'N') = 'Y'
              AND    (global_flag = 'Y' OR
                        orig_org_id = p_pb_input_header_rec.org_id)
              AND    source_system_code IN (SELECT application_short_name
                                            FROM   qp_pte_source_systems
                                            WHERE  pte_code = l_pte_code)
              AND    list_header_id = p_pb_input_header_rec.pl_agr_bsa_id
              AND    rownum = 1;
            EXCEPTION
              WHEN OTHERS THEN
                l_count := 0;
            END;

            IF l_count = 0 THEN
              x_return_status := 'E';
              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PL_AGR_BSA_ID');
              l_message_text := FND_MESSAGE.GET;
              l_price_book_messages_tbl(i).message_code :=
                                         'QP_INVALID_ATTRIBUTE';
              l_price_book_messages_tbl(i).message_text := l_message_text;
              l_price_book_messages_tbl(i).pb_input_header_id :=
                                     p_pb_input_header_rec.pb_input_header_id;
              i := i + 1;
              x_return_text := x_return_text || substr(l_message_text, 1, 240);
            END IF;

          ELSIF p_pb_input_header_rec.price_based_on = 'AGREEMENT' THEN
            BEGIN
              SELECT 1
              INTO   l_count
              FROM   oe_agreements_vl
              WHERE  agreement_id = p_pb_input_header_rec.pl_agr_bsa_id
              AND    (sold_to_org_id = -1 OR
                      sold_to_org_id IN (SELECT cust_account_id
                                         FROM   hz_cust_accounts
                                         WHERE  party_id =
                                         p_pb_input_header_rec.customer_attr_value
                                         AND    cust_account_id =
                 nvl(p_pb_input_header_rec.cust_account_id, cust_account_id))
                     )
              AND    price_list_id IN (SELECT list_header_id
                                       FROM   qp_list_headers_vl
                                       WHERE  list_type_code IN ('PRL','AGR')
                                       AND    nvl(active_flag, 'N') = 'Y'
                                       AND    (global_flag = 'Y' OR
                                     orig_org_id = p_pb_input_header_rec.org_id)
                                       AND    source_system_code IN
                                           (SELECT application_short_name
                                            FROM   qp_pte_source_systems
                                            WHERE  pte_code = l_pte_code)
                                      )
              AND    (trunc(nvl(p_pb_input_header_rec.effective_date, sysdate))
                     between trunc(nvl(start_date_active,
                                 p_pb_input_header_rec.effective_date))
                     and trunc(nvl(end_date_active,
                             p_pb_input_header_rec.effective_date)))
              AND    rownum = 1;
            EXCEPTION
              WHEN OTHERS THEN
                l_count := 0;
            END;

            IF l_count = 0 THEN
              x_return_status := 'E';
              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PL_AGR_BSA_ID');
              l_message_text := FND_MESSAGE.GET;
              l_price_book_messages_tbl(i).message_code :=
                                                'QP_INVALID_ATTRIBUTE';
              l_price_book_messages_tbl(i).message_text := l_message_text;
              l_price_book_messages_tbl(i).pb_input_header_id :=
                                     p_pb_input_header_rec.pb_input_header_id;
              i := i + 1;
              x_return_text := x_return_text || substr(l_message_text, 1, 240);
            END IF;

          ELSIF p_pb_input_header_rec.price_based_on = 'BSA' THEN
            BEGIN
              SELECT 1
              INTO   l_count
              FROM   oe_blanket_headers_all a
              WHERE  a.header_id = p_pb_input_header_rec.pl_agr_bsa_id
              AND    (a.sold_to_org_id IS NULL OR
                      a.sold_to_org_id IN (SELECT cust_account_id
                                           FROM   hz_cust_accounts
                                           WHERE  party_id =
                                     p_pb_input_header_rec.customer_attr_value
                                           AND    cust_account_id =
                 nvl(p_pb_input_header_rec.cust_account_id, cust_account_id))
                     )
              AND    a.org_id = p_pb_input_header_rec.org_id
              AND    EXISTS (SELECT 'x'
                             FROM   qp_qualifiers
                             WHERE  qualifier_context = 'ORDER'
                             AND    qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
                             AND    qualifier_attr_value = a.header_id)
              AND    rownum = 1;
            EXCEPTION
              WHEN OTHERS THEN
                l_count := 0;
            END;

            IF l_count = 0 THEN
              x_return_status := 'E';
              FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PL_AGR_BSA_ID');
              l_message_text := FND_MESSAGE.GET;
              l_price_book_messages_tbl(i).message_code :=
                                           'QP_INVALID_ATTRIBUTE';
              l_price_book_messages_tbl(i).message_text := l_message_text;
              l_price_book_messages_tbl(i).pb_input_header_id :=
                                     p_pb_input_header_rec.pb_input_header_id;
              i := i + 1;
              x_return_text := x_return_text || substr(l_message_text, 1, 240);
            END IF;

          END IF; --if price_based_on = 'PRICE_LIST'

        END IF; --If pl_agr_bsa_id is null
      END IF; --if price_based_on <> 'PRICE_LIST','AGREEMENT' or 'BSA'
    END IF; --if price_based_on is not null

    --Check if currency_code is not null
    IF p_pb_input_header_rec.currency_code IS NULL THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CURRENCY_CODE');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    --Check if currency_code is valid
    IF p_pb_input_header_rec.limit_products_by = 'PRICE_LIST' AND
       p_pb_input_header_rec.pl_agr_bsa_id IS NOT NULL
    THEN
      QP_UTIL_PUB.Validate_Price_list_Curr_code (
              l_price_list_id => p_pb_input_header_rec.pl_agr_bsa_id,
              l_currency_code => p_pb_input_header_rec.currency_code,
              l_pricing_effective_date => p_pb_input_header_rec.effective_date,
              l_validate_result => l_valid_currency);

      IF l_valid_currency = 'N' THEN
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_PRICELIST_N_CURR');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_INVALID_PRICELIST_N_CURR';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      END IF;
    ELSE
      BEGIN
        SELECT 1
        INTO   l_count
        FROM   fnd_currencies_vl
        WHERE  currency_flag = 'Y'
        AND    currency_code = p_pb_input_header_rec.currency_code
        AND    enabled_flag = 'Y'
        AND    trunc(NVL(start_date_active,
                         p_pb_input_header_rec.effective_date)
                    ) <= trunc(p_pb_input_header_rec.effective_date)
        AND    trunc(NVL(end_date_active, p_pb_input_header_rec.effective_date))
                      >= trunc(p_pb_input_header_rec.effective_date)
        AND    rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_count := 0;
      END;

      IF l_count = 0 THEN -- invalid currency_code
        x_return_status := 'E';
        FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CURRENCY_CODE');
        l_message_text := FND_MESSAGE.GET;
        l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
        l_price_book_messages_tbl(i).message_text := l_message_text;
        l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
        i := i + 1;
        x_return_text := x_return_text || substr(l_message_text, 1, 240);
      END IF;
    END IF; -- check if currency_code is valid

    --Validate item_quantity
    IF p_pb_input_header_rec.item_quantity <= 0 THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_ITEM_QTY_NEGATIVE_OR_ZERO');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code := 'QP_ITEM_QTY_NEGATIVE_OR_ZERO';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id :=
                             p_pb_input_header_rec.pb_input_header_id;
      i := i + 1;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
    END IF;

    --Validate the Input Line Records
    IF p_pb_input_lines_tbl.COUNT > 0 THEN
      FOR j IN p_pb_input_lines_tbl.FIRST..p_pb_input_lines_tbl.LAST
      LOOP

        IF p_pb_input_lines_tbl(j).context IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'CONTEXT');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                               p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_lines_tbl(j).attribute IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'ATTRIBUTE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_lines_tbl(j).attribute_type IS NULL THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'ATTRIBUTE_TYPE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_ATTRIBUTE_REQUIRED';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSIF p_pb_input_lines_tbl(j).attribute_type NOT IN
              ('QUALIFIER', 'PRICING_ATTRIBUTE') THEN
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'ATTRIBUTE_TYPE');
          l_message_text := FND_MESSAGE.GET;
          l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
          l_price_book_messages_tbl(i).message_text := l_message_text;
          l_price_book_messages_tbl(i).pb_input_header_id :=
                                 p_pb_input_header_rec.pb_input_header_id;
          i := i + 1;
          x_return_text := x_return_text || substr(l_message_text, 1, 240);
        ELSE

          --Check if context is valid
          BEGIN
            SELECT 1
            INTO   l_count
            FROM   qp_prc_contexts_b
            WHERE  prc_context_code = p_pb_input_lines_tbl(j).context
            AND    prc_context_type = p_pb_input_lines_tbl(j).attribute_type;
          EXCEPTION
            WHEN OTHERS THEN
              l_count := 0;
          END;

          IF l_count = 0 THEN
            x_return_status := 'E';
            FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     'CONTEXT'||'-'||substr(p_pb_input_lines_tbl(j).context, 1, 20));
            l_message_text := FND_MESSAGE.GET;
            l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                   p_pb_input_header_rec.pb_input_header_id;
            i := i + 1;
            x_return_text := x_return_text || substr(l_message_text, 1, 240);
          END IF;

          --Check if attribute is valid
          BEGIN
            SELECT 1, nvl(user_valueset_id, seeded_valueset_id)
            INTO   l_count, l_valueset_id
            FROM   qp_segments_b s, qp_prc_contexts_b c,
                   qp_pte_segments ps, qp_pte_request_types_b pr
            WHERE  s.segment_mapping_column = p_pb_input_lines_tbl(j).attribute
            AND    s.prc_context_id = c.prc_context_id
            AND    c.prc_context_code = p_pb_input_lines_tbl(j).context
            AND    c.prc_context_type = p_pb_input_lines_tbl(j).attribute_type
            AND    c.prc_context_code <> 'ITEM'
            AND    NOT ((c.prc_context_code = 'CUSTOMER' AND
                         s.segment_code = 'PARTY_ID') OR
                        (c.prc_context_code = 'ASOPARTYINFO' AND
                         s.segment_code = 'CUSTOMER PARTY') OR
                        (c.prc_context_code = 'CUSTOMER' AND
                         s.segment_code = 'SOLD_TO_ORG_ID') OR
                        (c.prc_context_code = 'MODLIST' AND
                         s.segment_code = 'PRICE_LIST') OR
                        (c.prc_context_code = 'CUSTOMER' AND
                         s.segment_code = 'AGREEMENT_NAME') OR
                        (c.prc_context_code = 'ORDER' AND
                         s.segment_code = 'BLANKET_NUMBER') OR
                        (c.prc_context_code = 'ORDER' AND
                         s.segment_code = 'BLANKET_HEADER_ID')
                       )
            AND    s.segment_id = ps.segment_id
            AND    ps.pte_code = pr.pte_code
            AND    pr.request_type_code = l_request_type_code
            AND    (l_pricing_status = 'I' OR
                    l_pricing_status = 'S'  AND
                    s.availability_in_basic IN ('Y','F')
                   )
            AND    (nvl(ps.user_sourcing_method, ps.seeded_sourcing_method) =
                               'USER ENTERED'
                    OR
                    nvl(ps.user_sourcing_method, ps.seeded_sourcing_method) =
                               'ATTRIBUTE MAPPING'
                    AND EXISTS (SELECT 'X'
                                FROM   qp_attribute_sourcing a
                                WHERE a.request_type_code = pr.request_type_code
                                AND    a.segment_id = s.segment_id
                                AND    a.enabled_flag = 'Y'
                                AND    a.attribute_sourcing_level <> 'LINE'
                                AND    nvl(user_value_string,
                                           seeded_value_string)
                                       LIKE pr.order_level_global_struct||'%'
                               )
                   ) ;
          EXCEPTION
            WHEN OTHERS THEN
              l_count := 0;
              l_valueset_id := null;
          END;

          IF l_count = 0 THEN
            x_return_status := 'E';
            FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'ATTRIBUTE'||'-'||substr(p_pb_input_lines_tbl(j).attribute, 1, 20));
            l_message_text := FND_MESSAGE.GET;
            l_price_book_messages_tbl(i).message_code := 'QP_INVALID_ATTRIBUTE';
            l_price_book_messages_tbl(i).message_text := l_message_text;
            l_price_book_messages_tbl(i).pb_input_header_id :=
                                   p_pb_input_header_rec.pb_input_header_id;
            i := i + 1;
            x_return_text := x_return_text || substr(l_message_text, 1, 240);

          ELSE --If l_count <> 0, that is, attribute is valid

            IF l_valueset_id IS NOT NULL THEN

              fnd_vset.get_valueset(l_valueset_id, v_valueset_r, v_valueset_dr);
              l_datatype := v_valueset_dr.format_type;

              IF (v_valueset_r.validation_type = 'I') AND
                                         --Validation type is independent
                 NOT QP_UTIL.value_exists(l_valueset_id,
                                  p_pb_input_lines_tbl(j).attribute_value)
              OR (v_valueset_r.validation_type = 'F') AND
                                         --Validation type is table
                 NOT QP_UTIL.value_exists_in_table(v_valueset_r.table_info,
                        p_pb_input_lines_tbl(j).attribute_value, l_id, l_value)
              OR ((v_valueset_r.validation_type = 'N') OR
                  l_datatype in( 'N','X','Y')) AND
                     --added for handling of dates/number in multilingual envs.
                 QP_UTIL.validate_num_date(l_datatype,
                     p_pb_input_lines_tbl(j).attribute_value) <> 0
              THEN
                x_return_status := 'E';
                FND_MESSAGE.SET_NAME('QP', 'QP_INVALID_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'VALUE'||'-'||substr(p_pb_input_lines_tbl(j).attribute_value, 1, 20));
                l_message_text := FND_MESSAGE.GET;
                l_price_book_messages_tbl(i).message_code :=
                                            'QP_INVALID_ATTRIBUTE';
                l_price_book_messages_tbl(i).message_text := l_message_text;
                l_price_book_messages_tbl(i).pb_input_header_id :=
                                   p_pb_input_header_rec.pb_input_header_id;
                i := i + 1;
                x_return_text := x_return_text || substr(l_message_text,1,240);
              END IF; --validation_type = 'I'

            END IF; --If l_valueset_id is not null

          END IF;--If l_count = 0

        END IF;

      END LOOP; --Loop over Input Line records
    END IF; --If p_pb_input_lines_tbl.count > 0

  END IF; --Publish existing price book. No generation.

  --reset the application_id back to the original appl id
  fnd_global.apps_initialize(l_user_id,
                             fnd_global.resp_id,
                             l_resp_appl_id);

  IF x_return_status = 'E' THEN
    Insert_Price_Book_Messages (l_price_book_messages_tbl);
    --commit;
    l_price_book_messages_tbl.delete;
  END IF;

END Validate_PB_Input_Criteria;


/*****************************************************************************
  Wrapper procedure around Validate_PB_Input_Criteria that can be called
  directly by get_catalog and private API to validate Price Book input criteria
*****************************************************************************/
PROCEDURE Validate_PB_Inp_Criteria_Wrap(
              p_pb_input_header_id  IN  NUMBER,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_return_text         IN OUT NOCOPY VARCHAR2)
IS
  l_pb_input_header_rec        qp_pb_input_headers_vl%ROWTYPE;
  l_price_book_messages_tbl    price_book_messages_tbl;
  l_pb_input_lines_tbl         pb_input_lines_tbl;
  l_message_text    VARCHAR2(2000);
  i                 NUMBER := 1;

BEGIN
  --Fetch the Price Book Input Header record into variable
  BEGIN
    SELECT *
    INTO   l_pb_input_header_rec
    FROM   qp_pb_input_headers_vl
    WHERE  pb_input_header_id = p_pb_input_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('QP', 'QP_INPUT_REC_NOT_FOUND');
      l_message_text := FND_MESSAGE.GET;
      l_price_book_messages_tbl(i).message_code :=
                           'QP_INPUT_REC_NOT_FOUND';
      l_price_book_messages_tbl(i).message_text := l_message_text;
      l_price_book_messages_tbl(i).pb_input_header_id := p_pb_input_header_id;
      x_return_text := x_return_text || substr(l_message_text, 1, 240);
  END;

  IF x_return_status = 'E' THEN
    --Insert error associated with the retrieving the price book input criteria
    Insert_Price_Book_Messages (l_price_book_messages_tbl);
    l_price_book_messages_tbl.delete;
    --commit;
    RETURN;
  END IF;

  --Fetch the Price Book Input Lines into a table of records
  SELECT * BULK COLLECT
  INTO   l_pb_input_lines_tbl
  FROM   qp_pb_input_lines
  WHERE  pb_input_header_id = p_pb_input_header_id;

  --Perform validation of input criteria
  Validate_PB_Input_Criteria(p_pb_input_header_rec => l_pb_input_header_rec,
                         p_pb_input_lines_tbl => l_pb_input_lines_tbl,
                             x_return_status => x_return_status,
                             x_return_text => x_return_text);

END Validate_PB_Inp_Criteria_Wrap;


/******************************************************************************
  Procedure to insert Price Book Header info into qp_price_book_headers_b
  and _tl tables.
******************************************************************************/
PROCEDURE Insert_Price_Book_Header (
      p_pb_input_header_rec IN qp_pb_input_headers_vl%ROWTYPE,
      x_price_book_header_id OUT NOCOPY NUMBER)
IS
 l_application_id       NUMBER;
 l_request_type_code    VARCHAR2(30);
 l_user_id              NUMBER;
 l_price_book_header_id NUMBER;
 l_count    NUMBER;

BEGIN

  l_user_id := fnd_global.user_id;

/*Not required since request type code is already available in input header rec
  --Get application id for the appl corresponding to pricing perspective
  BEGIN
    SELECT application_id
    INTO   l_application_id
    FROM   fnd_application
    WHERE  application_short_name =
               p_pb_input_header_rec.pricing_perspective_code;
  EXCEPTION
    l_application_id := NULL;
  END;

  l_request_type_code := fnd_profile.value_specific(
               name => 'QP_PRICING_PERSPECTIVE_REQUEST_TYPE',
               application_id => l_application_id);
*/

  --Check if the price book already exists for an org that is not accessible
  BEGIN
    SELECT 1
    INTO   l_count
    FROM   qp_price_book_headers_all_b b, qp_price_book_headers_tl t
    WHERE  b.price_book_header_id = t.price_book_header_id
    AND    t.language = userenv('LANG')
    AND    b.price_book_type_code = p_pb_input_header_rec.price_book_type_code
    AND    b.customer_id = p_pb_input_header_rec.customer_attr_value
    AND    t.price_book_name = p_pb_input_header_rec.price_book_name
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      l_count := 0;
  END;

  IF l_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  INSERT INTO qp_price_book_headers_all_b (
      price_book_header_id,
      price_book_type_code,
      currency_code,
      effective_date,
      org_id,
      customer_id,
      cust_account_id,
      item_category,
      price_based_on,
      pl_agr_bsa_id,
      pricing_perspective_code,
      item_quantity,
      request_id,
      request_type_code,
      pb_input_header_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
     )
  VALUES
     (qp_price_book_headers_all_b_s.nextval,
      p_pb_input_header_rec.price_book_type_code,
      p_pb_input_header_rec.currency_code,
      p_pb_input_header_rec.effective_date,
      p_pb_input_header_rec.org_id,
      p_pb_input_header_rec.customer_attr_value,
      p_pb_input_header_rec.cust_account_id,
      decode(p_pb_input_header_rec.product_attribute,
             'PRICING_ATTRIBUTE2', p_pb_input_header_rec.product_attr_value,
             null),
      p_pb_input_header_rec.price_based_on,
      p_pb_input_header_rec.pl_agr_bsa_id,
      p_pb_input_header_rec.pricing_perspective_code,
      p_pb_input_header_rec.item_quantity,
      null, --Will be updated with the child request id later
      p_pb_input_header_rec.request_type_code,
      p_pb_input_header_rec.pb_input_header_id,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      fnd_global.conc_login_id
     ) RETURNING price_book_header_id INTO l_price_book_header_id;

  INSERT INTO qp_price_book_headers_tl (
     price_book_header_id,
     price_book_name,
     pl_agr_bsa_name,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     language,
     source_lang
     )
  SELECT
     l_price_book_header_id,
     p_pb_input_header_rec.price_book_name,
     p_pb_input_header_rec.pl_agr_bsa_name,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     fnd_global.conc_login_id,
     l.language_code,
     userenv('LANG')
     FROM  FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG in ('I','B')
     AND   NOT EXISTS (SELECT NULL
                       FROM   qp_price_book_headers_tl T
                       WHERE  t.price_book_header_id =
                                  l_price_book_header_id
                       AND    t.language = l.language_code);

  x_price_book_header_id := l_price_book_header_id;

END Insert_Price_Book_Header;

FUNCTION value_to_meaning( p_code IN VARCHAR2,p_type IN VARCHAR2) RETURN VARCHAR2
IS
l_meaning VARCHAR2(80) := Null;
BEGIN
select meaning into l_meaning from qp_lookups where lookup_code = p_code and
lookup_type = p_type;
return l_meaning;
exception
when no_data_found then return NULL;
end value_to_meaning;

FUNCTION get_attribute_name(p_context_code in varchar2,p_attribute_code in
varchar2,p_attribute_type in varchar2)
return varchar2 is
l_attribute_name varchar2(80) := Null;
begin
select nvl(s.user_segment_name,s.seeded_segment_name) into l_attribute_name from qp_segments_v
s,qp_prc_contexts_v p where s.segment_mapping_column = p_attribute_code and
s.prc_context_id = p.prc_context_id and p.prc_context_code = p_context_code and
p.prc_context_type = p_attribute_type;
return l_attribute_name;
exception
when no_data_found then return NULL;
end;

FUNCTION get_product_value(p_attribute_code in varchar2,p_attribute_value_code in
varchar2,p_org_id in varchar2)
return varchar2 is
l_attribute_value varchar2(240) := Null;   --8721800
begin
if (p_attribute_code = 'PRICING_ATTRIBUTE1') then
              select concatenated_segments
                into l_attribute_value
                from mtl_system_items_kfv
                where inventory_item_id = to_number(p_attribute_value_code) and rownum = 1;

elsif (p_attribute_code = 'PRICING_ATTRIBUTE2') then
      begin
              select concat_cat_parentage
                into l_attribute_value
                from eni_prod_den_hrchy_parents_v
                where category_id = to_number(p_attribute_value_code) and rownum = 1;
       exception when others then
              select concatenated_segments
                into l_attribute_value
                from mtl_categories_kfv
                where category_id = to_number(p_attribute_value_code);
              return l_attribute_value;
       end;

end if;
return l_attribute_value;
exception
when no_data_found then return null;
end;

FUNCTION get_customer_value(p_attribute_code in varchar2, p_attribute_value_code in
varchar2) return varchar2 is
l_customer_name varchar2(360) := Null;
begin
if (p_attribute_code = 'QUALIFIER_ATTRIBUTE2') then
  IF to_number(p_attribute_value_code) = -1 THEN
  RETURN NULL;
  ELSE
  BEGIN
  select party_name into l_customer_name
  from hz_parties
  where party_id = to_number(p_attribute_value_code);
  END;
  END IF;
elsif (p_attribute_code = 'QUALIFIER_ATTRIBUTE1') then
select meaning into l_customer_name from ar_lookups where lookup_code=
p_attribute_value_code and lookup_type= 'CUSTOMER CLASS';
end if;
return l_customer_name;
exception
when  no_data_found then return null;
end;


FUNCTION get_customer_name(p_customer_id  in varchar2)
return varchar2 is
l_customer_name varchar2(360) := Null;
begin
  IF TO_NUMBER(p_customer_id) = -1 THEN
  RETURN null;
  else
    begin
    SELECT party_name INTO l_customer_name
    FROM hz_parties where party_id = to_number(p_customer_id);
    RETURN l_customer_name;
   EXCEPTION
   WHEN  no_data_found THEN RETURN null;
    end;
  end if;
end;

FUNCTION get_operating_unit(p_orgid in number) return varchar2
is
l_operating_unit varchar2(240) :=Null;
begin
     select name into l_operating_unit
     from HR_ALL_ORGANIZATION_UNITS_TL
     WHERE ORGANIZATION_ID =  p_orgid
     AND LANGUAGE = userenv('LANG');
return l_operating_unit;
exception
when no_data_found then return null;
end;

FUNCTION get_context_name (p_context in varchar2,p_attribute_type in varchar2) return varchar2
is
l_context_name varchar2(240) :=Null;
begin
select nvl(user_prc_context_name,seeded_prc_context_name) into l_context_name from qp_prc_contexts_v where prc_context_code =
p_context and prc_context_type = p_attribute_type;
return l_context_name;
exception
when no_data_found then return null;
end;

FUNCTION get_item_description(p_item_number in  number,p_pb_header_id in number)
return varchar2 is
l_item_description varchar2(240) := Null;
begin
select description into l_item_description from mtl_system_items_tl where
language = userenv('LANG') and inventory_item_id = p_item_number and rownum =1;
return l_item_description;
exception
when no_data_found then return null;
end;

FUNCTION get_item_category (p_item_category in number)  return varchar2 is
l_item_category varchar2(240) :=null;
begin
 begin
       select concat_cat_parentage into l_item_category from eni_prod_den_hrchy_parents_v
        where  category_id = p_item_category and  rownum = 1;
       return l_item_category;
 exception when others then
      select concatenated_segments into l_item_category from mtl_categories_kfv where
      category_id = p_item_category ;
      return l_item_category;
 end;
exception
when no_data_found then return null;
end;

FUNCTION get_item_cat_description (p_item_category in number)  return varchar2 is
l_item_cat_description varchar2(240) := Null;
begin
 begin
       select category_desc into l_item_cat_description from eni_prod_den_hrchy_parents_v where
       category_id = p_item_category and rownum = 1;
       return l_item_cat_description;
 exception when others then
        select description into l_item_cat_description from mtl_categories_kfv  where
        category_id = p_item_category;
        return l_item_cat_description;
 end ;
exception
when no_data_found then return null;
end;

FUNCTION get_item_number(p_item_number in number, p_pb_header_id in number)
return varchar2 is
l_item_number varchar2(240) := Null;   --8721800
begin
select concatenated_segments into l_item_number from mtl_system_items_kfv where
inventory_item_id = p_item_number and rownum = 1;
return l_item_number;
exception
when no_data_found then return null;
end;

/*** Function to get customer_item_number given the inventory_item_id ***/
FUNCTION get_customer_number (p_item_number in number,p_pb_header_id in number)
RETURN varchar2
IS
  l_customer_item_number VARCHAR2(50) := null;
  l_cust_account_id      NUMBER := null;
  l_master_org           NUMBER;
BEGIN
  BEGIN
    SELECT cust_account_id
    INTO   l_cust_account_id
    FROM   qp_price_book_headers_b
    WHERE  price_book_header_id = p_pb_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_cust_account_id := null;
  END;

  IF l_cust_account_id IS NULL THEN
    RETURN null;
  END IF;

  --Getting the master_organization_id for the Inventory Org Id.
  BEGIN
    SELECT master_organization_id
    INTO   l_master_org
    FROM   mtl_parameters
    WHERE  organization_id = QP_UTIL.Get_Item_Validation_Org;
  END;

  --Per M. Antyakula of INV team specifying master org filter as well in
  --the query below will ensure that a unique customer_item_number is selected.
  BEGIN
    SELECT ci.customer_item_number
    INTO   l_customer_item_number
    FROM   mtl_customer_item_xrefs xref, mtl_customer_items_all_v ci
    WHERE  xref.inventory_item_id = p_item_number
    AND    xref.master_organization_id = l_master_org
    AND    xref.inactive_flag = 'N'
    AND    ci.customer_item_id = xref.customer_item_id
    AND    ci.customer_id = l_cust_account_id
    AND    ci.address_id is null
    AND    ci.customer_category_code is null
    AND    ci.item_definition_level = 1;
  EXCEPTION
    WHEN OTHERS THEN
      l_customer_item_number :=  null;
  END;

  RETURN  l_customer_item_number;
END get_customer_number;

FUNCTION get_customer_item_desc (p_item_number in number,p_pb_header_id in number)
RETURN varchar2
IS
  l_customer_item_desc VARCHAR2(240) := null;
  l_cust_account_id    NUMBER := null;
  l_master_org         NUMBER;
BEGIN
  BEGIN
    SELECT cust_account_id
    INTO   l_cust_account_id
    FROM   qp_price_book_headers_b
    WHERE  price_book_header_id = p_pb_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_cust_account_id := null;
  END;

  IF l_cust_account_id IS NULL THEN
    RETURN null;
  END IF;

  --Getting the master_organization_id for the Inventory Org Id.
  BEGIN
    SELECT master_organization_id
    INTO   l_master_org
    FROM   mtl_parameters
    WHERE  organization_id = QP_UTIL.Get_Item_Validation_Org;
  END;

  --Per M. Antyakula of INV team specifying master org filter as well in
  --the query below will ensure that a unique record is selected.
  -- Replaceing mtl_customer_items_all_v with the view definition  for
  -- fix for sql id 17903884
  BEGIN
       SELECT MCI.CUSTOMER_ITEM_DESC
      INTO   l_customer_item_desc
      FROM MTL_CUSTOMER_ITEMS MCI,
      HZ_PARTIES HZP, HZ_CUST_ACCOUNTS HZC, (SELECT LOC.COUNTRY,
                                                    ACCT_SITE.CUST_ACCT_SITE_ID ADDRESS_ID
        FROM   HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
               HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
               HZ_PARTY_SITES PARTY_SITE
        WHERE  ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
               AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
               AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
               AND NVL(ACCT_SITE.ORG_ID,- 99) = NVL(LOC_ASSIGN.ORG_ID,- 99)
         AND NVL(ACCT_SITE.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,SUBSTRB(USERENV('CLIENT_INFO'),1, 10))),- 99)) =
                      NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1, 1),' ', NULL,SUBSTRB(USERENV('CLIENT_INFO'), 1,10))),- 99)) RAD,
               MTL_COMMODITY_CODES MCC,
               MTL_CUSTOMER_ITEMS MCIM, ( SELECT B.TERRITORY_CODE
                                          FROM  FND_TERRITORIES_TL T, FND_TERRITORIES B
                                          WHERE B.TERRITORY_CODE = T.TERRITORY_CODE
                                          AND T.LANGUAGE = USERENV('LANG')) TERR,
               AR_LOOKUPS ARL,
               MFG_LOOKUPS MFL, mtl_customer_item_xrefs xref
       WHERE  MCI.CUSTOMER_ID   = HZC.CUST_ACCOUNT_ID
       AND MCI.ADDRESS_ID   = RAD.ADDRESS_ID(+)
       AND MCI.COMMODITY_CODE_ID  = MCC.COMMODITY_CODE_ID
       AND MCI.MODEL_CUSTOMER_ITEM_ID    =     MCIM.CUSTOMER_ITEM_ID(+)
       AND TERR.TERRITORY_CODE(+)  = RAD.COUNTRY
       AND MCI.CUSTOMER_CATEGORY_CODE = ARL.LOOKUP_CODE(+)
       AND ARL.LOOKUP_TYPE(+)  = 'ADDRESS_CATEGORY'
       AND MCI.ITEM_DEFINITION_LEVEL = MFL.LOOKUP_CODE
       AND MFL.LOOKUP_TYPE   = 'INV_ITEM_DEFINITION_LEVEL'
       AND HZC.PARTY_ID = HZP.PARTY_ID
       AND xref.inventory_item_id = p_item_number
       AND xref.master_organization_id = l_master_org
       AND xref.inactive_flag = 'N'
       AND mci.customer_item_id = xref.customer_item_id
       AND mci.customer_id = l_cust_account_id
       AND mci.address_id is null
       AND mci.customer_category_code is null
       AND mci.item_definition_level = 1;

  EXCEPTION
    WHEN OTHERS THEN
      l_customer_item_desc :=  null;
  END;

  RETURN  l_customer_item_desc;
END get_customer_item_desc;


FUNCTION get_attribute_value_common(p_attribute_type in varchar2,p_context in
varchar2,p_attribute in varchar2,p_attribute_value in
varchar2,p_comparison_operator varchar2 default'=')
return varchar2 is
l_attribute_value varchar2(240) := Null;     --8721800
begin
if p_attribute_type = 'QUALIFIER' then
l_attribute_value := QP_UTIL.Get_Attribute_Value('QP_ATTR_DEFNS_QUALIFIER',
                             p_context,
        p_attribute,
        p_attribute_value,
        p_comparison_operator);
elsif p_attribute_type = 'PRICING_ATTRIBUTE' then
 if p_context = 'ITEM' and p_attribute = 'PRICING_ATTRIBUTE2' then
  begin
   select concat_cat_parentage
                into l_attribute_value
                from eni_prod_den_hrchy_parents_v
                where category_id = to_number(p_attribute_value) and rownum = 1;
  exception when others then
   select concatenated_segments
                into l_attribute_value
                from mtl_categories_kfv
                where category_id = to_number(p_attribute_value);
    return l_attribute_value;
   end;
 else
   l_attribute_value := QP_UTIL.Get_Attribute_Value('QP_ATTR_DEFNS_PRICING',
                             p_context,
                                p_attribute,
                                p_attribute_value,
                                p_comparison_operator);
 end if;
end if;
return l_attribute_value;
exception
when others then return null;
end;

FUNCTION get_list_name(p_list_header_id in number)
return varchar2 is
l_list_name varchar2(240) := Null;
begin
select name into l_list_name from qp_list_headers_tl
where list_header_id = p_list_header_id and
language = userenv('LANG');
return l_list_name;
exception
when no_data_found then return null;
end;

PROCEDURE Delete_PriceBook_Info(p_price_book_header_id in number)
is

l_pb_input_header_id  number := null;
l_price_book_name  varchar2(2000) := null;
d_pb_input_header_id  number := null;
d_price_book_header_id  number :=null;
l_customer_id number := null;
l_document_id number := null;
d_document_id number := null;

BEGIN

BEGIN
SELECT CUSTOMER_ID,PB_INPUT_HEADER_ID,PRICE_BOOK_NAME,DOCUMENT_ID
  into l_customer_id,l_pb_input_header_id ,l_price_book_name,l_document_id
from QP_PRICE_BOOK_HEADERS_V
WHERE PRICE_BOOK_HEADER_ID = p_price_book_header_id;
EXCEPTION
when no_data_found then
null;
END;

BEGIN
  SELECT PB_INPUT_HEADER_ID,PRICE_BOOK_HEADER_ID,DOCUMENT_ID
     into d_pb_input_header_id,d_price_book_header_id, d_document_id
  FROM QP_PRICE_BOOK_HEADERS_V
  WHERE PRICE_BOOK_HEADER_ID <> p_price_book_header_id AND
  PRICE_BOOK_NAME = l_price_book_name and
  PRICE_BOOK_TYPE_CODE = 'D' and
  CUSTOMER_ID = l_customer_id;
  EXCEPTION
  when no_data_found then
  null;
END;

-- Commiting after each delete as it will give rollback segment error if the data is huge

 DELETE FROM QP_PRICE_BOOK_ATTRIBUTES WHERE PRICE_BOOK_HEADER_ID in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PRICE_BOOK_BREAK_LINES WHERE PRICE_BOOK_HEADER_ID in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PRICE_BOOK_LINE_DETAILS WHERE PRICE_BOOK_HEADER_ID  in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PRICE_BOOK_LINES WHERE PRICE_BOOK_HEADER_ID   in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PRICE_BOOK_HEADERS_TL WHERE PRICE_BOOK_HEADER_ID  in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PRICE_BOOK_HEADERS_B WHERE PRICE_BOOK_HEADER_ID  in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PB_INPUT_LINES WHERE PB_INPUT_HEADER_ID in (l_pb_input_header_id,  d_pb_input_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PB_INPUT_HEADERS_TL WHERE PB_INPUT_HEADER_ID in  (l_pb_input_header_id,  d_pb_input_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PB_INPUT_HEADERS_B WHERE PB_INPUT_HEADER_ID   in  (l_pb_input_header_id,  d_pb_input_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PRICE_BOOK_MESSAGES  WHERE PRICE_BOOK_HEADER_ID   in (p_price_book_header_id,d_price_book_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;


 DELETE FROM QP_DOCUMENTS WHERE DOCUMENT_ID in (l_document_id,d_document_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

END;


PROCEDURE Delete_Input_Criteria(p_pb_input_header_id in number)
is

BEGIN
--[prarasto]Deleting the Input Header and Lines is not required as the same header_id will be
--updated in case of an error. Commenting the code.
/*
-- Commiting after each delete as it will give rollback segment error if the data is huge
 DELETE FROM QP_PB_INPUT_LINES WHERE PB_INPUT_HEADER_ID in (p_pb_input_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PB_INPUT_HEADERS_TL WHERE PB_INPUT_HEADER_ID in (p_pb_input_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;

 DELETE FROM QP_PB_INPUT_HEADERS_B WHERE PB_INPUT_HEADER_ID   in (p_pb_input_header_id);
 IF SQL%FOUND  THEN
 COMMIT;
 END IF;
*/
 DELETE FROM QP_PRICE_BOOK_MESSAGES  WHERE PB_INPUT_HEADER_ID in (p_pb_input_header_id);
 IF SQL%FOUND  THEN
 --COMMIT;
 null;  --Commit will be done only after successful insertion.
 END IF;

 END;


FUNCTION get_currency_name (p_currency_code in varchar2) return varchar2
is
l_currency_name varchar2(240) := null;
begin
select name into l_currency_name from fnd_currencies_vl where currency_code =
p_currency_code;
return l_currency_name;
exception
when no_data_found then  return null;
end;

/** KDURGASI **/

FUNCTION get_content_type (p_document_type  IN VARCHAR2) return VARCHAR2 IS
l_mime VARCHAR2(50):= G_MIME_PDF;
BEGIN
    IF (G_TYPE_PDF = p_document_type) THEN
      l_mime := G_MIME_PDF;
    ELSIF (G_TYPE_HTML = p_document_type) THEN
      l_mime := G_MIME_HTML;
    ELSIF (G_TYPE_EXCEL = p_document_type) THEN
      l_mime := G_MIME_EXCEL;
    ELSIF (G_TYPE_RTF = p_document_type) THEN
      l_mime := G_MIME_RTF;
    END IF;
    RETURN l_mime;

END;

FUNCTION get_document_name (p_pb_input_header_id IN NUMBER, p_document_type in varchar2) return VARCHAR2 IS
l_extension VARCHAR2(50):= G_EXT_PDF;
BEGIN
    IF (G_TYPE_PDF = p_document_type) THEN
      l_extension := G_EXT_PDF;
    ELSIF (G_TYPE_HTML = p_document_type) THEN
      l_extension := G_EXT_HTML;
    ELSIF (G_TYPE_EXCEL = p_document_type) THEN
      l_extension := G_EXT_EXCEL;
    ELSIF (G_TYPE_RTF = p_document_type) THEN
      l_extension := G_EXT_RTF;
    END IF;
    RETURN G_FILE_NAME_PREFIX || p_pb_input_header_id ||'.'||l_extension;
END;
/** KDURGASI **/
---------------------------------------------------------

PROCEDURE INSERT_PB_TL_RECORDS
(
  p_pb_input_header_id IN VARCHAR2,
  p_price_book_name IN VARCHAR2,
  p_pl_agr_bsa_name IN VARCHAR2
)
IS
BEGIN
  INSERT INTO QP_PB_INPUT_HEADERS_TL (
    PB_INPUT_HEADER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PRICE_BOOK_NAME,
    PL_AGR_BSA_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    p_pb_input_header_id,
    PBIH.CREATION_DATE,
    PBIH.CREATED_BY,
    PBIH.LAST_UPDATE_DATE,
    PBIH.LAST_UPDATED_BY,
    PBIH.LAST_UPDATE_LOGIN,
    p_price_book_name,
    p_pl_agr_bsa_name,
    L.LANGUAGE_CODE,
    userenv('LANG')
    FROM FND_LANGUAGES L, QP_PB_INPUT_HEADERS_B PBIH
    WHERE L.INSTALLED_FLAG in ('I', 'B')
    AND PBIH.PB_INPUT_HEADER_ID = p_pb_input_header_id
    AND NOT EXISTS
      (SELECT NULL
      FROM QP_PB_INPUT_HEADERS_TL T
      WHERE T.PB_INPUT_HEADER_ID = p_pb_input_header_id
      AND T.LANGUAGE = L.LANGUAGE_CODE);
END INSERT_PB_TL_RECORDS;

PROCEDURE CATGI_HEADER_CONVERSIONS
(
  p_org_id IN NUMBER,
  p_pricing_effective_date IN DATE,
  p_limit_products_by_code IN VARCHAR2,
  p_price_based_on_code IN VARCHAR2,
  p_customer_id IN VARCHAR2,
  p_item_number IN VARCHAR2,
  p_item_number_cust IN VARCHAR2,
  p_item_id IN VARCHAR2,
  p_item_category_name IN VARCHAR2,
  p_item_category_id IN VARCHAR2,
  p_price_list_name IN VARCHAR2,
  p_price_list_id IN VARCHAR2,
  p_agreement_name IN VARCHAR2,
  p_agreement_id IN VARCHAR2,
  p_bsa_name IN VARCHAR2,
  p_bsa_id IN VARCHAR2,
  x_prod_attr_value OUT NOCOPY VARCHAR2,
  x_pl_agr_bsa_id OUT NOCOPY VARCHAR2,
  x_pl_agr_bsa_name OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
)
IS
BEGIN

  --[julin] x_prod_attr_value - item number, item category
  IF (p_limit_products_by_code = 'ITEM') THEN
    IF (p_item_id is not null) THEN
      x_prod_attr_value := p_item_id;
    ELSIF (p_item_number is not null) THEN
      BEGIN
        SELECT inventory_item_id
        INTO   x_prod_attr_value
        FROM   mtl_system_items_vl
        WHERE  concatenated_segments = p_item_number
        AND    organization_id = p_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_prod_attr_value := 'ITEM_LOOKUP_FAILED';
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP', 'QP_XML_ITEM_NOT_FOUND');
          FND_MESSAGE.SET_TOKEN('ITEM_NUMBER', p_item_number);
          x_return_text := FND_MESSAGE.GET;
        WHEN TOO_MANY_ROWS THEN
          x_prod_attr_value := 'ITEM_LOOKUP_FAILED';
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP', 'QP_XML_ITEM_MULTI_FOUND');
          FND_MESSAGE.SET_TOKEN('ITEM_NUMBER', p_item_number);
          x_return_text := FND_MESSAGE.GET;
      END;
    /*
    ELSIF (p_item_number_cust is not null) THEN
      BEGIN
        SELECT inventory_item_id
        INTO    x_prod_attr_value
        FROM (
          SELECT  Inventory_Item_Id
          FROM    MTL_CUSTOMER_ITEM_XREFS x, MTL_CUSTOMER_ITEMS i
          WHERE   i.customer_id = p_customer_id
          AND     i.customer_item_number = p_item_number_cust
          AND     i.Customer_Item_Id = x.customer_item_id
          AND     x.Master_Organization_Id  =
                          (SELECT Master_Organization_Id
                           FROM   MTL_PARAMETERS
                           WHERE  Organization_Id = p_org_id)
          ORDER BY Preference_Number ASC)
        WHERE     rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND Then
          x_prod_attr_value := 'CUST_ITEM_NUM_LOOKUP_FAILED';
      END;
    */
    END IF;
  ELSIF (p_limit_products_by_code = 'ITEM_CATEGORY') THEN
    IF (p_item_category_id is not null) THEN
      x_prod_attr_value := p_item_category_id;
    ELSIF (p_item_category_name is not null) THEN
      BEGIN
        SELECT distinct category_id
        INTO   x_prod_attr_value
        FROM   qp_item_categories_v
        WHERE  category_name = p_item_category_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_prod_attr_value := 'CATEGORY_LOOKUP_FAILED';
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP', 'QP_XML_CATEGORY_NOT_FOUND');
          FND_MESSAGE.SET_TOKEN('CATEGORY_NAME', p_item_category_name);
          x_return_text := FND_MESSAGE.GET;
        WHEN TOO_MANY_ROWS THEN
          x_prod_attr_value := 'CATEGORY_LOOKUP_FAILED';
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP', 'QP_XML_CATEGORY_MULTI_FOUND');
          FND_MESSAGE.SET_TOKEN('CATEGORY_NAME', p_item_category_name);
          x_return_text := FND_MESSAGE.GET;
      END;
    END IF;
  ELSIF (p_limit_products_by_code = 'ALL_ITEMS') THEN
    x_prod_attr_value := 'ALL';
  END IF;

  --[julin] x_pl_agr_bsa_id - price list, agreement, bsa
  IF (p_price_based_on_code = 'PRICE_LIST') THEN
    IF (p_price_list_id is not null) THEN
      x_pl_agr_bsa_id := p_price_list_id;
    ELSIF (p_price_list_name is not null) THEN
      x_pl_agr_bsa_id := GET_PRICE_LIST_ID(p_price_list_name);
      IF x_pl_agr_bsa_id is null THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP', 'QP_XML_PRICELIST_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('PRICELIST_NAME', p_price_list_name);
        x_return_text := FND_MESSAGE.GET;
      END IF;
      x_pl_agr_bsa_name := p_price_list_name;
    END IF;
  ELSIF (p_price_based_on_code = 'AGREEMENT') THEN
    IF (p_agreement_id is not null) THEN
      x_pl_agr_bsa_id := p_agreement_id;
    ELSIF (p_agreement_name is not null) THEN
      x_pl_agr_bsa_id := GET_AGREEMENT_ID(p_agreement_name, p_pricing_effective_date);
      IF x_pl_agr_bsa_id is null THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP', 'QP_XML_AGREEMENT_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('AGREEMENT_NAME', p_agreement_name);
        FND_MESSAGE.SET_TOKEN('EFFECTIVE_DATE', p_pricing_effective_date);
        x_return_text := FND_MESSAGE.GET;
      END IF;
      x_pl_agr_bsa_name := p_agreement_name;
    END IF;
  ELSIF (p_price_based_on_code = 'BSA') THEN
    IF (p_bsa_id is not null) THEN
      x_pl_agr_bsa_id := p_bsa_id;
    ELSIF (p_bsa_name is not null) THEN
      x_pl_agr_bsa_id := GET_BSA_ID(p_bsa_name);
      IF x_pl_agr_bsa_id is null THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP', 'QP_XML_BSA_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('BSA_NAME', p_bsa_name);
        x_return_text := FND_MESSAGE.GET;
      END IF;
      x_pl_agr_bsa_name := p_bsa_name;
    END IF;
  END IF;

END CATGI_HEADER_CONVERSIONS;

PROCEDURE GET_CONTEXT_CODE
(
  p_context_name IN VARCHAR2,
  p_attribute_type IN VARCHAR2,
  x_context_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
)
IS
BEGIN
  SELECT c.prc_context_code
  INTO   x_context_code
  FROM   qp_prc_contexts_v c
  WHERE  nvl(c.user_prc_context_name,c.seeded_prc_context_name) = p_context_name
  AND    prc_context_type = p_attribute_type;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_context_code := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_CONTEXT_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('CONTEXT_NAME', p_context_name);
    FND_MESSAGE.SET_TOKEN('CONTEXT_TYPE', p_attribute_type);
    x_return_text := FND_MESSAGE.GET;
  WHEN TOO_MANY_ROWS THEN
    x_context_code := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_CONTEXT_MULTI_FOUND');
    FND_MESSAGE.SET_TOKEN('CONTEXT_NAME', p_context_name);
    FND_MESSAGE.SET_TOKEN('CONTEXT_TYPE', p_attribute_type);
    x_return_text := FND_MESSAGE.GET;
END GET_CONTEXT_CODE;

PROCEDURE GET_ATTRIBUTE_CODE
(
  p_context_code IN VARCHAR2,
  p_attribute_name IN VARCHAR2,
  p_attribute_type IN VARCHAR2,
  x_attribute_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
)
IS
BEGIN
  SELECT sb.segment_mapping_column
  INTO   x_attribute_code
  FROM   qp_prc_contexts_b p, qp_segments_b sb, qp_segments_tl stl
  WHERE  p.prc_context_code = p_context_code
  AND    p.prc_context_type = p_attribute_type
  AND    sb.prc_context_id = p.prc_context_id
  AND    stl.segment_id = sb.segment_id
  AND    stl.language = userenv('LANG')
  AND    nvl(stl.user_segment_name,stl.seeded_segment_name) = p_attribute_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_attribute_code := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_ATTRIBUTE_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', p_attribute_name);
    FND_MESSAGE.SET_TOKEN('CONTEXT_TYPE', p_attribute_type);
    FND_MESSAGE.SET_TOKEN('CONTEXT_CODE', p_context_code);
    x_return_text := FND_MESSAGE.GET;
  WHEN TOO_MANY_ROWS THEN
    x_attribute_code := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_ATTRIBUTE_MULTI_FOUND');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', p_attribute_name);
    FND_MESSAGE.SET_TOKEN('CONTEXT_TYPE', p_attribute_type);
    FND_MESSAGE.SET_TOKEN('CONTEXT_CODE', p_context_code);
    x_return_text := FND_MESSAGE.GET;
END GET_ATTRIBUTE_CODE;

PROCEDURE GET_ATTRIBUTE_VALUE_CODE
(
  p_context_code IN VARCHAR2,
  p_attribute_code IN VARCHAR2,
  p_attribute_value_name IN VARCHAR2,
  p_attribute_type IN VARCHAR2,
  x_attribute_value_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_text OUT NOCOPY VARCHAR2
)
IS
  Vset FND_VSET.valueset_r;
  Fmt FND_VSET.valueset_dr;

  Found BOOLEAN;
  ROW NUMBER;
  VALUE FND_VSET.value_dr;

  x_Format_Type VARCHAR2(1);

  x_Validation_Type VARCHAR2(1);
  x_Vsid NUMBER;
  l_count NUMBER := 0;
  l_segment_code VARCHAR2(240);
  l_flexfield_name VARCHAR2(240);

BEGIN
  -- get segment_code from segment_mapping_column
  SELECT segment_code
  INTO   l_segment_code
  FROM   qp_prc_contexts_b p, qp_segments_b sb, qp_segments_tl stl
  WHERE  p.prc_context_code = p_context_code
  AND    p.prc_context_type = p_attribute_type
  AND    sb.prc_context_id = p.prc_context_id
  AND    stl.segment_id = sb.segment_id
  AND    stl.language = userenv('LANG')
  AND    sb.segment_mapping_column = p_attribute_code;

  -- get flexfield name
  IF p_attribute_type = 'QUALIFIER' THEN
    l_flexfield_name := 'QP_ATTR_DEFNS_QUALIFIER';
  ELSIF p_attribute_type = 'PRICING_ATTRIBUTE' THEN
    l_flexfield_name := 'QP_ATTR_DEFNS_PRICING';
  END IF;

  -- get valueset
  qp_util.get_valueset_id(l_FlexField_Name, p_Context_Code,
                          l_segment_code, x_Vsid,
                          x_Format_Type, x_Validation_Type);

  IF x_Validation_Type IN('F', 'I') AND x_Vsid IS NOT NULL THEN

    FND_VSET.get_valueset(x_Vsid, Vset, Fmt);
    FND_VSET.get_value_init(Vset, TRUE);
    FND_VSET.get_value(Vset, ROW, Found, VALUE);

    IF Fmt.Has_Id THEN -- id defined, get id
      WHILE(Found) LOOP
        IF p_attribute_value_name = VALUE.VALUE THEN
          x_attribute_value_code := VALUE.id;
          l_count := l_count + 1;
          EXIT;
        END IF;
        FND_VSET.get_value(Vset, ROW, Found, VALUE);
      END LOOP;
    ELSE -- id not defined, get value
      WHILE(Found) LOOP
        IF p_attribute_value_name = VALUE.VALUE THEN
          x_attribute_value_code := p_attribute_value_name;
          l_count := l_count + 1;
          EXIT;
        END IF;
        FND_VSET.get_value(Vset, ROW, Found, VALUE);
      END LOOP;
    END IF; -- end of Fmt.Has_Id

    FND_VSET.get_value_end(Vset);

    IF l_count = 0 THEN
      RAISE NO_DATA_FOUND;
    ELSIF l_count > 1 THEN
      RAISE TOO_MANY_ROWS;
    END IF;

  ELSE -- if validation type is not F or I or valueset id is null (not defined)

    x_attribute_value_code := p_attribute_value_name;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_attribute_value_code := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_ATTR_VALUE_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_NAME', p_attribute_value_name);
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_CODE', p_attribute_code);
    FND_MESSAGE.SET_TOKEN('CONTEXT_TYPE', p_attribute_type);
    FND_MESSAGE.SET_TOKEN('CONTEXT_CODE', p_context_code);
    x_return_text := FND_MESSAGE.GET;
  WHEN TOO_MANY_ROWS THEN
    x_attribute_value_code := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_ATTR_VALUE_MULTI_FOUND');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE_NAME', p_attribute_value_name);
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE_CODE', p_attribute_code);
    FND_MESSAGE.SET_TOKEN('CONTEXT_TYPE', p_attribute_type);
    FND_MESSAGE.SET_TOKEN('CONTEXT_CODE', p_context_code);
    x_return_text := FND_MESSAGE.GET;
END GET_ATTRIBUTE_VALUE_CODE;

PROCEDURE PUBLISH_AND_DELIVER_CP
(
  err_buff                OUT NOCOPY VARCHAR2,
  retcode                 OUT NOCOPY NUMBER,
  p_pb_input_header_id NUMBER,
  p_price_book_id NUMBER,
  p_servlet_url IN VARCHAR2
)
IS
  l_status VARCHAR2(30);
  l_status_text VARCHAR2(2000);
BEGIN
  PUBLISH_AND_DELIVER(p_pb_input_header_id, p_price_book_id, p_servlet_url, l_status, l_status_text);
  IF l_status <> FND_API.G_RET_STS_SUCCESS THEN
    retcode := 2;
    err_buff := l_status_text;
  ELSE
    retcode := 0;
    err_buff := '';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    err_buff := l_status || ':' || l_status_text;
END PUBLISH_AND_DELIVER_CP;

PROCEDURE PUBLISH_AND_DELIVER
(
  p_pb_input_header_id IN NUMBER,
  p_price_book_header_id IN NUMBER,
  p_servlet_url IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_status_text OUT NOCOPY VARCHAR2
)
IS
L_MAX_STATUS_REQUESTS        NUMBER:=240;
L_STATUS_REQUEST_INTERVAL    NUMBER:=10;   -- seconds
L_TRANSFER_TIMEOUT           NUMBER:=3600; -- seconds
l_routine             VARCHAR2(240):='QP_PRICE_BOOK_UTIL.PUBLISH_AND_DELIVER';
l_output_file         VARCHAR2(240);
l_debug               VARCHAR2(3);
l_url_servlet_string    VARCHAR2(240);
l_url_param_string    VARCHAR2(240);
l_return_status       VARCHAR2(240);
l_return_status_text  VARCHAR2(2000);
l_status_request_cnt  NUMBER;
l_dummy_return_details UTL_HTTP.HTML_PIECES;
l_status_code VARCHAR(240);

err_buff VARCHAR2(240);
retcode NUMBER;

INVALID_PARAMS_ERROR EXCEPTION;
E_ROUTINE_ERRORS EXCEPTION;
MAX_STATUS_REQUESTS_REACHED EXCEPTION;
INVALID_PRICE_BOOK_HEADER EXCEPTION;

BEGIN

  QP_PREQ_GRP.Set_QP_Debug;
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
    l_output_file := OE_DEBUG_PUB.SET_DEBUG_MODE('FILE');
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'The output file is : ' || l_output_file );
  END IF;

  IF (p_pb_input_header_id IS NULL or p_price_book_header_id IS NULL) THEN
    RAISE INVALID_PARAMS_ERROR;
  END IF;

  BEGIN
    UPDATE QP_PRICE_BOOK_HEADERS_B
    SET PUB_STATUS_CODE = 'REQUESTED'
    WHERE PRICE_BOOK_HEADER_ID = p_price_book_header_id;
    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE INVALID_PRICE_BOOK_HEADER;
  END;

  l_url_servlet_string := nvl(p_servlet_url, fnd_profile.value('APPS_FRAMEWORK_AGENT') ||
                                             '/OA_HTML/RequestPriceBook');
  l_url_param_string := 'pbInputHeaderId='||nvl(p_pb_input_header_id, -1)||
    qp_java_engine_util_pub.G_HARD_CHAR||'priceBookHeaderId='||nvl(p_price_book_header_id, -1);
  qp_java_engine_util_pub.send_java_request(l_url_servlet_string,
                                            l_url_param_string,
                                            l_return_status,
                                            l_return_status_text,
                                            l_dummy_return_details,
                                            false,
                                            L_TRANSFER_TIMEOUT,
                                            FND_API.G_TRUE);

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_return_status_text = 'UTL_TCP.END_OF_INPUT') THEN
      l_status_request_cnt := 0;
      BEGIN
        LOOP
          DBMS_LOCK.SLEEP(L_STATUS_REQUEST_INTERVAL);

          SELECT PUB_STATUS_CODE
          INTO l_status_code
          FROM QP_PRICE_BOOK_HEADERS_B
          WHERE PRICE_BOOK_HEADER_ID = p_price_book_header_id;

          IF l_status_code = 'ERROR' THEN
            RAISE E_ROUTINE_ERRORS;
          END IF;
          EXIT WHEN l_status_code = 'COMPLETED';
          IF l_status_request_cnt > L_MAX_STATUS_REQUESTS THEN
            RAISE MAX_STATUS_REQUESTS_REACHED;
          END IF;
          l_status_request_cnt := l_status_request_cnt + 1;
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE INVALID_PRICE_BOOK_HEADER;
      END;
    ELSE
      RAISE E_ROUTINE_ERRORS;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN INVALID_PARAMS_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'Invalid parameter values.';
  WHEN E_ROUTINE_ERRORS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||'l_return_status_text:'||l_return_status_text);
      QP_PREQ_GRP.engine_debug(l_routine||'SQLERRM:'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := l_return_status_text;
  WHEN MAX_STATUS_REQUESTS_REACHED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'Request has exceeded '||(L_MAX_STATUS_REQUESTS*L_STATUS_REQUEST_INTERVAL)||' seconds.';
  WHEN INVALID_PRICE_BOOK_HEADER THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'Invalid price book header id.';
  WHEN OTHERS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||'l_return_status_text:'||l_return_status_text);
      QP_PREQ_GRP.engine_debug(l_routine||'SQLERRM:'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := l_return_status_text;
END PUBLISH_AND_DELIVER;

PROCEDURE SEND_SYNC_CATALOG
(
  p_price_book_header_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_return_status_text OUT NOCOPY VARCHAR2
)
IS
  x_progress VARCHAR2(1000);
  transaction_type VARCHAR2(240);
  transaction_subtype VARCHAR2(240);
  document_direction VARCHAR2(240);
  party_id NUMBER;
  party_site_id NUMBER;
  party_type VARCHAR2(30);
  return_code PLS_INTEGER;
  errmsg VARCHAR2(2000);
  result BOOLEAN;
  l_error_code NUMBER;
  l_error_msg VARCHAR2(2000);

  -- parameters for raising event
  l_send_syct_event VARCHAR2(100);
  l_create_cln_event VARCHAR2(100);
  l_event_key VARCHAR2(100);
  l_syncctlg_seq NUMBER;
  l_send_syct_parameter_list wf_parameter_list_t;
  l_create_cln_parameter_list wf_parameter_list_t;
  l_operating_unit_id NUMBER;
  l_inv_org_id NUMBER;
  l_date DATE;
  l_canonical_date VARCHAR2(100);

  -- parameters for dealing with the number of items restriction
  counter BINARY_INTEGER;
  msgs_sent_flag BOOLEAN;

  l_debug               VARCHAR2(3);

  BEGIN
    -- set debug level
    QP_PREQ_GRP.Set_QP_Debug;
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('ENTERING QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG');
    END IF;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('With the following parameters:');
      QP_PREQ_GRP.engine_debug('p_price_book_header_id:' || p_price_book_header_id);
    END IF;

    -- initialize parameters
    x_progress := '000';
    transaction_type := 'QP';
    transaction_subtype := 'CATSO';
    document_direction := 'OUT';
    party_type := 'C';
    result := FALSE;

    l_send_syct_event := 'oracle.apps.qp.pricebook.catso';
    l_create_cln_event := 'oracle.apps.cln.ch.collaboration.create';

    --transaction_type := 'CLN';
    --transaction_subtype := 'SYNCCTLGO';
    --l_send_syct_event := 'oracle.apps.cln.event.syncctlg';

    l_send_syct_parameter_list := wf_parameter_list_t();
    l_create_cln_parameter_list := wf_parameter_list_t();

    counter := 1;
    msgs_sent_flag := FALSE;

    SELECT i.customer_attr_value, i.DLV_XML_SITE_ID
    INTO   party_id, party_site_id
    FROM   qp_price_book_headers_b p, qp_pb_input_headers_b i
    WHERE  p.price_book_header_id = p_price_book_header_id
    AND    p.pb_input_header_id = i.pb_input_header_id;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('party_id:' || party_id);
      QP_PREQ_GRP.engine_debug('party_site_id:' || party_site_id);
    END IF;

    SELECT FND_PROFILE.VALUE('ORG_ID')
    INTO l_operating_unit_id
    FROM dual;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('l_operating_unit_id:' || l_operating_unit_id);
    END IF;

    l_inv_org_id := qp_util.Get_Item_Validation_Org;
    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('l_inv_org_id:' || l_inv_org_id);
    END IF;

    x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : Parameters Initialized';
    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
    END IF;

    -- XML Setup Check
    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('Parameters before ecx_document.isDeliveryRequired:');
      QP_PREQ_GRP.engine_debug('transaction_type:' || transaction_type);
      QP_PREQ_GRP.engine_debug('transaction_subtype:' || transaction_subtype);
      QP_PREQ_GRP.engine_debug('party_id:' || party_id);
      QP_PREQ_GRP.engine_debug('party_site_id:' || party_site_id);
      QP_PREQ_GRP.engine_debug('return_code:' || return_code);
      QP_PREQ_GRP.engine_debug('errmsg:' || errmsg);
    END IF;

    ecx_document.isDeliveryRequired(
                                    transaction_type => transaction_type,
                                    transaction_subtype => transaction_subtype,
                                    party_id => party_id,
                                    party_site_id => party_site_id,
                                    resultout => result,
                                    retcode => return_code,
                                    errmsg => errmsg);

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('Values returned from ecx_document.isDeliveryRequired:');
      QP_PREQ_GRP.engine_debug('return_code:' || return_code);
      QP_PREQ_GRP.engine_debug('errmsg:' || errmsg);
    END IF;

    x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : XML Setup Check';
    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
    END IF;

    IF NOT(result) THEN
      -- trading partner not found
      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : No Trading Partner found during XML Setup Check';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      END IF;

    ELSE -- no number specified, send in one message

      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : No Number Limit Specified';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      END IF;

      -- create unique key
      SELECT QP_XML_MESSAGES_S.NEXTVAL INTO l_syncctlg_seq FROM dual;
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('l_syncctlg_seq:' || l_syncctlg_seq);
      END IF;
      l_event_key := to_char(p_price_book_header_id) || '.' || to_char(l_syncctlg_seq);

      SELECT SYSDATE INTO l_date FROM dual;
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('l_date:' || l_date);
      END IF;
      l_canonical_date := FND_DATE.DATE_TO_CANONICAL(l_date);

      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : Created Unique Key';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      END IF;

      -- add parameters to list for create collaboration event
      wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                  p_value => transaction_type,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                  p_value => transaction_subtype,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                  p_value => document_direction,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                  p_value => l_event_key,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                  p_value => party_id,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                  p_value => party_site_id,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                  p_value => party_type,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                  p_value => l_event_key,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'ORG_ID',
                                  p_value => l_operating_unit_id,
                                  p_parameterlist => l_create_cln_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                  p_value => l_canonical_date,
                                  p_parameterlist => l_create_cln_parameter_list);

      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : Initialize Create Event Parameters';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      end if;

      -- raise create collaboration event
      wf_event.raise(p_event_name => l_create_cln_event,
                     p_event_key  => l_event_key,
                     p_parameters => l_create_cln_parameter_list);

      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : Create Event Raised';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      end if;

      -- add parameters to list for send show shipment document
      wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_TYPE',
                                  p_value => transaction_type,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_TRANSACTION_SUBTYPE',
                                  p_value => transaction_subtype,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_TYPE',
                                  p_value => transaction_type,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'XMLG_INTERNAL_TXN_SUBTYPE',
                                  p_value => transaction_subtype,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_DIRECTION',
                                  p_value => document_direction,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARTY_ID',
                                  p_value => party_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARTY_SITE_ID',
                                  p_value => party_site_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARTY_TYPE',
                                  p_value => party_type,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_ID',
                                  p_value => party_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_SITE',
                                  p_value => party_site_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'TRADING_PARTNER_TYPE',
                                  p_value => party_type,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_DOCUMENT_ID',
                                  p_value => l_event_key,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'XMLG_DOCUMENT_ID',
                                  p_value => l_event_key,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_NO',
                                  p_value => l_event_key,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'USER_ID',
                                  p_value => fnd_global.user_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'APPLICATION_ID',
                                  p_value => fnd_global.resp_appl_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'RESPONSIBILITY_ID',
                                  p_value => fnd_global.resp_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ORG_ID',
                                  p_value => l_inv_org_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'DOCUMENT_CREATION_DATE',
                                  p_value => l_canonical_date,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARAMETER1',
                                  p_value => p_price_book_header_id,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARAMETER2',
                                  p_value => NULL,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARAMETER3',
                                  p_value => NULL,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARAMETER4',
                                  p_value => NULL,
                                  p_parameterlist => l_send_syct_parameter_list);
      wf_event.AddParameterToList(p_name => 'ECX_PARAMETER5',
                                  p_value => NULL,
                                  p_parameterlist => l_send_syct_parameter_list);

      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : Send Document Event Parameters Initialized';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      END IF;

      -- raise event for send show shipment document
      wf_event.RAISE(p_event_name => l_send_syct_event,
                     p_event_key => l_event_key,
                     p_parameters => l_send_syct_parameter_list);

      x_progress := 'QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG : Send Document Event Raised';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      END IF;

    END IF;

    IF (l_debug = FND_API.G_TRUE) THEN
      QP_PREQ_GRP.engine_debug('EXITING QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG Successfully');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      l_error_code := SQLCODE;
      l_error_msg := SQLERRM;
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Exception ' || ':' || l_error_code || ':' || l_error_msg);
      END IF;

      x_progress := 'EXITING QP_PRICE_BOOK_UTIL.SEND_SYNC_CATALOG in Error ';
      IF (l_debug = FND_API.G_TRUE) THEN
        QP_PREQ_GRP.engine_debug('Failure point ' || x_progress);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := l_error_msg;
  END SEND_SYNC_CATALOG;

PROCEDURE GENERATE_PUBLISH_PRICE_BOOK_WF
(
  itemtype   in VARCHAR2,
  itemkey    in VARCHAR2,
  actid      in NUMBER,
  funcmode   in VARCHAR2,
  resultout  in OUT NOCOPY VARCHAR2
)
IS
  l_pb_input_header_id       VARCHAR2(240);
  l_pricing_perspective_code VARCHAR2(30);
  l_user_name                VARCHAR2(240);
  l_status_code              VARCHAR2(240);
  l_status_text              VARCHAR2(240);
  l_request_id               NUMBER;
  l_ret_code                 NUMBER;
  l_err_buf                  VARCHAR2(240);
  l_debug VARCHAR2(3);
  l_routine VARCHAR2(240):='QP_PRICE_BOOK_UTIL.GENERATE_PUBLISH_PRICE_BOOK_WF:';
BEGIN
  l_pb_input_header_id  := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'PARAMETER1');
  IF (l_pb_input_header_id is null) THEN
    wf_core.token('PARAMETER1','NULL');
    wf_core.raise('WFSQL_ARGS');
  END IF;

  /*
  l_pricing_perspective_code  := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'PARAMETER2');
  IF (l_pricing_perspective_code is null) THEN
    wf_core.token('PARAMETER2','NULL');
    wf_core.raise('WFSQL_ARGS');
  END IF;
  */

  l_user_name  := Wf_Engine.GetItemAttrText(itemtype, itemkey, 'PARAMETER4');
  IF (l_user_name is null) THEN
    wf_core.token('PARAMETER4','NULL');
    wf_core.raise('WFSQL_ARGS');
  END IF;

  SET_XML_CONTEXT(l_user_name, l_status_code, l_status_text);

  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine||'calling GENERATE_PUBLISH_PRICE_BOOK');
  END IF;
  QP_PRICE_BOOK_PVT.GENERATE_PUBLISH_PRICE_BOOK(l_pb_input_header_id,
                                                l_request_id,
                                                l_status_code,
                                                l_ret_code,
                                                l_err_buf);
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine||'returned from GENERATE_PUBLISH_PRICE_BOOK');
  END IF;

  resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('QP_PRICE_BOOK_UTIL', 'GENERATE_PUBLISH_PRICE_BOOK_WF', itemtype, itemkey, to_char(actid), funcmode);
    raise;
END GENERATE_PUBLISH_PRICE_BOOK_WF;

PROCEDURE CATSO_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;
  l_parameter1          NUMBER;
  l_debug               VARCHAR2(3);
  l_application_code    VARCHAR2(30);
  a varchar2(100);

BEGIN

  QP_PREQ_GRP.Set_QP_Debug;
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

  IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(  'ENTERING CATSO_SELECTOR PROCEDURE' ) ;
      QP_PREQ_GRP.engine_debug(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE ) ;
  END IF;

  IF (p_funcmode = 'RUN') THEN
    IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(  'P_FUNCMODE IS RUN' ) ;
    END IF;
    p_x_result := 'COMPLETE';
  ELSIF(p_funcmode = 'TEST_CTX') THEN
    IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(  'P_FUNCMODE IS TEST_CTX' ) ;
    END IF;

    l_org_id := wf_engine.GetItemAttrNumber (itemtype   => p_itemtype,
                                             itemkey    => p_itemkey,
                                             aname      => 'ORG_ID');

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(  'l_org_id (from workflow)=>'|| l_org_id ) ;
      QP_PREQ_GRP.engine_debug(  'mo_global.get_current_org_id =>'|| mo_global.get_current_org_id ) ;
    END IF;

    IF (mo_global.get_current_org_id is null OR MO_GLOBAL.get_access_mode is null) THEN
      p_x_result := 'NOTSET';
    ELSE
      IF (NVL(mo_global.get_current_org_id,-99) <> l_Org_Id) THEN
        p_x_result := 'FALSE';
      ELSE
        p_x_result := 'TRUE';
      END IF;
    END IF;

  ELSIF(p_funcmode = 'SET_CTX') THEN
    IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug(  'P_FUNCMODE IS SET_CTX' ) ;
    END IF;

    l_user_id := wf_engine.GetItemAttrNumber (itemtype   => p_itemtype,
                                              itemkey    => p_itemkey,
                                              aname      => 'USER_ID');
    l_resp_appl_id := wf_engine.GetItemAttrNumber (itemtype   => p_itemtype,
                                              itemkey    => p_itemkey,
                                              aname      => 'APPLICATION_ID');
    l_resp_id := wf_engine.GetItemAttrNumber (itemtype   => p_itemtype,
                                              itemkey    => p_itemkey,
                                              aname      => 'RESPONSIBILITY_ID');
    l_org_id := wf_engine.GetItemAttrNumber  (itemtype   => p_itemtype,
                                              itemkey    => p_itemkey,
                                              aname      => 'ORG_ID');

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('l_user_id =>' || l_user_id || ' l_resp_id =>' || l_resp_id || ' l_resp_appl_id =>' || l_resp_appl_id || ' l_org_id =>' || l_org_id);
    END IF;

    IF l_resp_appl_id is null OR l_resp_id is null THEN
      dbms_application_info.set_client_info(l_org_id);
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('set org using dbms_application_info.set_client_info');
      END IF;
    ELSE
      -- Set the database session context
      FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
      /*
      BEGIN
        SELECT application_short_name
        INTO   l_application_code
        FROM   fnd_application
        WHERE  application_id = fnd_global.resp_appl_id; --Responsibility of user
      EXCEPTION
        WHEN OTHERS THEN
          l_application_code := 'QP';
      END;
      */
      MO_GLOBAL.Init('QP');
      --mo_global.set_policy_context(p_access_mode => 'S', p_org_id=>l_Org_Id);
    END IF;

    p_x_result := 'COMPLETE';
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('p_x_result =>'||p_x_result);
  END IF;

EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('QP_PRICE_BOOK_UTIL', 'CATSO_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;

END CATSO_SELECTOR;

PROCEDURE SET_XML_CONTEXT
(
  p_user_name               IN VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_return_text             IN OUT NOCOPY VARCHAR2
)
IS
  l_user_id NUMBER;
  l_pricing_perspective_code VARCHAR(30);
  l_pricing_perspective_appl_id NUMBER;
  l_resp_id NUMBER;
  l_resp_appl_id NUMBER;
  l_resp_appl_name VARCHAR2(30);
  l_debug VARCHAR2(3);
  l_routine VARCHAR2(240):='QP_PRICE_BOOK_UTIL.SET_XML_CONTEXT';
BEGIN
  -- get user based on user name
  SELECT user_id
  INTO l_user_id
  FROM fnd_user
  WHERE user_name = upper(p_user_name);

  -- get pricing perpective based on user
  fnd_global.apps_initialize(l_user_id,
                             null,
                             null);
  l_pricing_perspective_code := FND_PROFILE.VALUE('QP_EXT_DEFAULT_PRICING_PERSPECTIVE');
  QP_PREQ_GRP.Set_QP_Debug;
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine || ':l_user_id=' || l_user_id);
    QP_PREQ_GRP.engine_debug(l_routine || ':l_pricing_perspective_code=' || l_pricing_perspective_code);
  END IF;

  -- get pricing perspective application id based on pricing perspective code
  SELECT a.application_id
  INTO   l_pricing_perspective_appl_id
  FROM   fnd_application a
  WHERE  a.application_short_name = l_pricing_perspective_code;
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine || ':l_pricing_perspective_appl_id=' || l_pricing_perspective_appl_id);
  END IF;

  -- get responsibility based on pricing perspective
  fnd_global.apps_initialize(l_user_id,
                             null,
                             l_pricing_perspective_appl_id);
  l_resp_id := FND_PROFILE.VALUE('QP_XML_RESP');
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine || ':l_resp_id=' || l_resp_id);
  END IF;

  -- get application id and short name based on responsibility
  SELECT a.application_id, a.application_short_name
  INTO   l_resp_appl_id, l_resp_appl_name
  FROM   fnd_responsibility r, fnd_application a
  WHERE  r.responsibility_id = l_resp_id
  AND    a.application_id = r.application_id;
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine || ':l_resp_appl_id=' || l_resp_appl_id || ',l_resp_appl_name=' || l_resp_appl_name);
  END IF;

  -- set context
  fnd_global.apps_initialize(l_user_id,
                             l_resp_id,
                             l_resp_appl_id);
  MO_GLOBAL.Init('QP');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP', 'QP_XML_RESPONSIBILITY_REQUIRED');
    x_return_text := FND_MESSAGE.GET;
END;

PROCEDURE CATGI_UPDATE_PUBLISH_OPTIONS
(
  p_price_book_name     IN VARCHAR2,
  p_customer_attr_value IN NUMBER,
  p_effective_date      IN DATE,
  p_price_book_type_code IN VARCHAR2,
  p_dlv_xml_site_id     IN NUMBER,
  p_generation_time_code IN VARCHAR2,
  p_gen_schedule_date   IN DATE,
  x_pb_input_header_id  OUT NOCOPY NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         IN OUT NOCOPY VARCHAR2
)
IS
  l_pb_input_header_id NUMBER;
BEGIN

  SELECT pb_input_header_id
  INTO l_pb_input_header_id
  FROM qp_pb_input_headers_vl
  WHERE price_book_name = p_price_book_name
  AND   customer_attr_value = p_customer_attr_value
  --AND   effective_date = p_effective_date
  AND   price_book_type_code = p_price_book_type_code;

  UPDATE QP_PB_INPUT_HEADERS_B
  SET PUB_TEMPLATE_CODE = NULL,
      PUB_LANGUAGE = NULL,
      PUB_TERRITORY = NULL,
      PUB_OUTPUT_DOCUMENT_TYPE = NULL,
      DLV_XML_FLAG = 'Y',
      DLV_XML_SITE_ID = p_dlv_xml_site_id,
      DLV_EMAIL_FLAG = 'N',
      DLV_EMAIL_ADDRESSES = NULL,
      DLV_PRINTER_FLAG = 'N',
      DLV_PRINTER_NAME = NULL,
      PUBLISH_EXISTING_PB_FLAG = 'Y',
      GENERATION_TIME_CODE = p_generation_time_code,
      GEN_SCHEDULE_DATE = p_gen_schedule_date,
      REQUEST_ORIGINATION_CODE = 'XML',
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = FND_GLOBAL.USER_ID
  WHERE pb_input_header_id = l_pb_input_header_id;

  x_pb_input_header_id := l_pb_input_header_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_text := '';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_text := 'Could not find price book ' || p_price_book_name || ', ' || p_customer_attr_value || ', ' || p_effective_date;
END CATGI_UPDATE_PUBLISH_OPTIONS;

PROCEDURE CATGI_POST_INSERT_PROCESSING
(
  p_pb_input_header_id  IN NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         IN OUT NOCOPY VARCHAR2
)
IS
  l_pb_input_header_id NUMBER;
  l_pb_input_header_rec        qp_pb_input_headers_vl%ROWTYPE;
  l_full_pb_input_header_rec        qp_pb_input_headers_vl%ROWTYPE;

  l_context_tbl   QP_PRICE_BOOK_UTIL.VARCHAR30_TYPE;
  l_attribute_tbl       QP_PRICE_BOOK_UTIL.VARCHAR30_TYPE;
  l_attribute_value_tbl QP_PRICE_BOOK_UTIL.VARCHAR_TYPE;
  l_attribute_type_tbl  QP_PRICE_BOOK_UTIL.VARCHAR30_TYPE;

  l_user_id     NUMBER;
  l_login_id    NUMBER;
  l_sysdate     DATE;

  l_cust_account_id     NUMBER;
BEGIN
  --Fetch the Price Book Input Header record into variable
  BEGIN
    SELECT *
    INTO   l_pb_input_header_rec
    FROM   qp_pb_input_headers_vl
    WHERE  pb_input_header_id = p_pb_input_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_text := 'CATGI_POST_INSERT_PROCESSING: pb not found - ' || SQLERRM;
  END;

  IF l_pb_input_header_rec.cust_account_id is null THEN
    DEFAULT_CUST_ACCOUNT_ID(l_pb_input_header_rec.customer_attr_value,
                            l_cust_account_id);
    IF l_cust_account_id is not null THEN
      UPDATE QP_PB_INPUT_HEADERS_B
      SET CUST_ACCOUNT_ID = l_cust_account_id
      WHERE pb_input_header_id = p_pb_input_header_id;
    END IF;
  END IF;

  IF l_pb_input_header_rec.price_book_type_code = 'D' THEN
  --Fetch the Price Book Input Header record into variable
    BEGIN
      SELECT *
      INTO   l_full_pb_input_header_rec
      FROM   qp_pb_input_headers_vl
      WHERE  price_book_name = l_pb_input_header_rec.price_book_name
      AND    customer_attr_value = l_pb_input_header_rec.customer_attr_value
      AND    customer_context = l_pb_input_header_rec.customer_context
      AND    customer_attribute = l_pb_input_header_rec.customer_attribute
      AND    price_book_type_code = 'F';
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP', 'QP_FULL_PRICE_BOOK_MUST_EXIST');
        x_return_text := FND_MESSAGE.GET;
        RETURN;
    END;

    UPDATE qp_pb_input_headers_b
    SET    customer_context     = l_full_pb_input_header_rec.customer_context,
           customer_attribute   = l_full_pb_input_header_rec.customer_attribute,
           customer_attr_value  = l_full_pb_input_header_rec.customer_attr_value,
           cust_account_id      = l_full_pb_input_header_rec.cust_account_id,
           currency_code        = l_full_pb_input_header_rec.currency_code,
           limit_products_by    = l_full_pb_input_header_rec.limit_products_by,
           product_context      = l_full_pb_input_header_rec.product_context,
           product_attribute    = l_full_pb_input_header_rec.product_attribute,
           product_attr_value   = l_full_pb_input_header_rec.product_attr_value,
           item_quantity        = l_full_pb_input_header_rec.item_quantity,
           org_id               = l_full_pb_input_header_rec.org_id,
           price_based_on       = l_full_pb_input_header_rec.price_based_on,
           pl_agr_bsa_id        = l_full_pb_input_header_rec.pl_agr_bsa_id,
           pricing_perspective_code = l_full_pb_input_header_rec.pricing_perspective_code,
           request_type_code    = l_full_pb_input_header_rec.request_type_code
    WHERE  pb_input_header_id = p_pb_input_header_id;

    UPDATE qp_pb_input_headers_tl
    SET    pl_agr_bsa_name      = l_full_pb_input_header_rec.pl_agr_bsa_name
    WHERE  pb_input_header_id = p_pb_input_header_id;

    --Select the certain columns of input lines from the full price book
    BEGIN
      SELECT context, attribute, attribute_value, attribute_type
      BULK COLLECT INTO l_context_tbl, l_attribute_tbl,
      l_attribute_value_tbl, l_attribute_type_tbl
      FROM   qp_pb_input_lines
      WHERE  pb_input_header_id = l_full_pb_input_header_rec.pb_input_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;

    IF l_context_tbl.count > 0 THEN
      --Insert the Input criteria into input lines tables
      l_sysdate := sysdate;
      l_user_id := fnd_global.user_id;
      l_login_id := fnd_global.login_id;
      BEGIN
        FORALL k IN l_context_tbl.FIRST..l_context_tbl.LAST
          INSERT INTO qp_pb_input_lines
          (pb_input_line_id, pb_input_header_id,
           context, attribute, attribute_value,
           attribute_type, creation_date, created_by, last_update_date,
           last_updated_by, last_update_login
          )
          VALUES
          (qp_pb_input_lines_s.nextval,
           p_pb_input_header_id,
           l_context_tbl(k), l_attribute_tbl(k),
           l_attribute_value_tbl(k), l_attribute_type_tbl(k),
           l_sysdate, l_user_id, l_sysdate, l_user_id, l_login_id
          );
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_return_text := 'CATGI_POST_INSERT_PROCESSING: error while inserting lines - ' || SQLERRM;
      END;
    END IF;

  END IF;

  --x_pb_input_header_id := l_pb_input_header_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_text := '';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_text := 'Could not find price book ' || p_pb_input_header_id;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_text := 'CATGI_POST_INSERT_PROCESSING: general error - ' || SQLERRM;
END CATGI_POST_INSERT_PROCESSING;

PROCEDURE CATGI_UPDATE_CUST_ACCOUNT_ID
(
  p_pb_input_header_id  IN NUMBER,
  p_cust_account_id     IN NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         IN OUT NOCOPY VARCHAR2
)
IS
BEGIN
  UPDATE QP_PB_INPUT_HEADERS_B
  SET CUST_ACCOUNT_ID = p_cust_account_id
  WHERE pb_input_header_id = p_pb_input_header_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_text := '';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_text := 'Could not find price book ' || p_pb_input_header_id;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_text := 'CATGI_UPDATE_MISC: general error - ' || SQLERRM;
END CATGI_UPDATE_CUST_ACCOUNT_ID;

---------------------------------------------------------

FUNCTION GET_PTE_CODE(p_request_type_code VARCHAR2) RETURN VARCHAR2
IS
  l_pte_code VARCHAR2(30);
BEGIN
  select   pte_code
  into     l_pte_code
  from     qp_pte_request_types_b
  where    request_type_code = p_request_type_code;
  return l_pte_code;
EXCEPTION
  when others then
       l_pte_code := 'ORDFUL';
       return l_pte_code;
END GET_PTE_CODE;

---------------------------------------------------------

--  SNIMMAGA.
--
--  Added implementation of this function.

FUNCTION Get_Processing_BatchSize RETURN NATURAL
IS
  l_value NATURAL;
BEGIN
  l_value :=  To_Number(
           fnd_profile.Value('QP_PRICEBOOK_PROCESSOR_BATCH_SIZE')
        );
  RETURN  Nvl(l_value, 5000);
EXCEPTION
  WHEN Others THEN
    RETURN  5000;
END Get_Processing_BatchSize;

/** KDURGASI **/
PROCEDURE GENERATE_PRICE_BOOK_XML
(
  p_price_book_hdr_id	IN NUMBER,
  p_document_content_type IN VARCHAR2,
  p_document_name	IN VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_text         OUT NOCOPY VARCHAR2
) IS
 l_qryCtx DBMS_XMLQUERY.ctxHandle;
 l_st_time number;
 l_end_time number;
 l_result CLOB;
 l_doc_id number;
BEGIN
l_qryCtx := DBMS_XMLQUERY.newContext('SELECT XMLElement(
		"PriceBookHeadersVORow",
		XMLForest( PBHDR.PRICE_BOOK_HEADER_ID "PriceBookHeaderId",
		       replace(to_char(hz_timezone_pub.convert_datetime(FND_PROFILE.VALUE(''SERVER_TIMEZONE_ID''),0,PBHDR.CREATION_DATE), ''YYYY-MM-DD HH24:MI:SS''), '' '', ''T'') "CreationDate",
		       PBHDR.CREATED_BY "CreatedBy",
		       replace(to_char(hz_timezone_pub.convert_datetime(FND_PROFILE.VALUE(''SERVER_TIMEZONE_ID''),0,PBHDR.LAST_UPDATE_DATE), ''YYYY-MM-DD HH24:MI:SS''), '' '', ''T'') "LastUpdateDate",
		       PBHDR.LAST_UPDATED_BY "LastUpdatedBy",
		       PBHDR.LAST_UPDATE_LOGIN "LastUpdateLogin",
		       PBHDR.CUSTOMER_ID "CustomerId",
		       PBHDR.CURRENCY_CODE "CurrencyCode",
		       replace(to_char(hz_timezone_pub.convert_datetime(FND_PROFILE.VALUE(''SERVER_TIMEZONE_ID''),0,PBHDR.EFFECTIVE_DATE), ''YYYY-MM-DD HH24:MI:SS''), '' '', ''T'') "EffectiveDate",
		       PBHDR.ITEM_QUANTITY "ItemQuantity",
		       PBHDR.REQUEST_ID "RequestId",
		       PBHDR.ORG_ID "OrgId",
		       PBHDR.OPERATING_UNIT "OperatingUnit",
		       PBHDR.PRICE_BOOK_TYPE_CODE "PriceBookTypeCode",
		       PBHDR.REQUEST_TYPE_CODE "RequestTypeCode",
		       PBHDR.PRICE_BOOK_NAME "PriceBookName",
		       PBHDR.CUSTOMER_NAME "CustomerName",
		       PBHDR.ITEM_CATEGORY "ItemCategory",
		       PBHDR.PB_INPUT_HEADER_ID "PbInputHeaderId",
		       PBHDR.PRICE_BOOK_TYPE "PriceBookType",
		       PBHDR.CURRENCY "Currency",
		       PBHDR.PRICING_PERSPECTIVE_CODE "PricingPerspectiveCode",
		       PBHDR.PL_AGR_BSA_ID "PlAgrBsaId",
		       PBHDR.PL_AGR_BSA_NAME "PlAgrBsaName",
		       PBHDR.LANGUAGE "Language",
		       PBHDR.SOURCE_LANG "SourceLang",
		       PBHDR.PRICE_BASED_ON "PriceBasedOn",
		       PBHDR.CUST_ACCOUNT_ID "CustAccountId"),
		XMLElement(
			"PBInputHeadersVO",
			(SELECT XMLAgg(
				XMLElement(
					"PBInputHeadersVORow",
					XMLForest(PBInputHDR.PB_INPUT_HEADER_ID "PbInputHeaderId",
					       PBInputHDR.CUSTOMER_CONTEXT "CustomerContext",
					       PBInputHDR.CUSTOMER_ATTRIBUTE "CustomerAttribute",
					       PBInputHDR.CUSTOMER_ATTR_VALUE "CustomerAttrValue",
					       PBInputHDR.CURRENCY_CODE "CurrencyCode",
					       PBInputHDR.PRODUCT_CONTEXT "ProductContext",
					       PBInputHDR.PRODUCT_ATTRIBUTE "ProductAttribute",
					       PBInputHDR.PRODUCT_ATTR_VALUE "ProductAttrValue",
						replace(to_char(hz_timezone_pub.convert_datetime(FND_PROFILE.VALUE(''SERVER_TIMEZONE_ID''),0,PBInputHDR.EFFECTIVE_DATE), ''YYYY-MM-DD HH24:MI:SS''), '' '', ''T'') "EffectiveDate",
					       PBInputHDR.ITEM_QUANTITY "ItemQuantity",
					       PBInputHDR.GENERATION_TIME_CODE "GenerationTimeCode",
					       PBInputHDR.GEN_SCHEDULE_DATE "GenScheduleDate",
					       PBInputHDR.REQUEST_ID "RequestId",
					       PBInputHDR.ORG_ID "OrgId",
					       PBInputHDR.OPERATING_UNIT "OperatingUnit",
					       PBInputHDR.PRICE_BOOK_TYPE_CODE "PriceBookTypeCode",
					       PBInputHDR.PUBLISH_EXISTING_PB_FLAG "PublishExistingPbFlag",
					       PBInputHDR.REQUEST_TYPE_CODE "RequestTypeCode",
					       PBInputHDR.PRICE_BOOK_NAME "PriceBookName",
					       PBInputHDR.CUSTOMER_NAME "CustomerName",
					       PBInputHDR.PRODUCT_NAME "ProductName",
					       PBInputHDR.GENERATION_TIME "GenerationTime",
					       PBInputHDR.PRICE_BOOK_TYPE "PriceBookType",
					       PBInputHDR.PRODUCT_ATTRIBUTE_NAME "ProductAttributeName",
					       PBInputHDR.CUSTOMER_ATTRIBUTE_NAME "CustomerAttributeName",
					       PBInputHDR.VALIDATION_ERROR_FLAG "ValidationErrorFlag",
					       PBInputHDR.PRICING_PERSPECTIVE_CODE "PricingPerspectiveCode",
					       PBInputHDR.OVERWRITE_EXISTING_PB_FLAG "OverwriteExistingPbFlag",
					       PBInputHDR.CURRENCY "Currency",
					       PBInputHDR.LIMIT_PRODUCTS_BY "LimitProductsBy",
					       PBInputHDR.PRICE_BASED_ON "PriceBasedOn",
					       PBInputHDR.PL_AGR_BSA_ID "PlAgrBsaId",
					       PBInputHDR.LIMIT_PRODUCTS_BY_NAME "LimitProductsByName",
					       PBInputHDR.PRICE_BASED_ON_NAME "PriceBasedOnName",
					       PBInputHDR.PL_AGR_BSA_NAME "PlAgrBsaName",
					       PBInputHDR.PUB_TEMPLATE_CODE "PubTemplateCode",
					       PBInputHDR.PUB_LANGUAGE "PubLanguage",
					       PBInputHDR.PUB_TERRITORY "PubTerritory",
					       PBInputHDR.PUB_OUTPUT_DOCUMENT_TYPE "PubOutputDocumentType",
					       PBInputHDR.DLV_XML_FLAG "DlvXmlFlag",
					       PBInputHDR.DLV_EMAIL_FLAG "DlvEmailFlag",
					       PBInputHDR.DLV_EMAIL_ADDRESSES "DlvEmailAddresses",
					       PBInputHDR.DLV_PRINTER_FLAG "DlvPrinterFlag",
					       PBInputHDR.DLV_PRINTER_NAME "DlvPrinterName",
					       PBInputHDR.PRICING_PERSPECTIVE "PricingPerspective"),
						XMLElement(
							"PBInputLinesVO",
								(SELECT XMLAgg(
									XMLElement(
										"PBInputLinesVORow",
										XMLForest(PBInputLIN.PB_INPUT_LINE_ID "PbInputLineId",
										       PBInputLIN.PB_INPUT_HEADER_ID "PbInputHeaderId",
										       PBInputLIN.CONTEXT "Context",
										       PBInputLIN.ATTRIBUTE "Attribute",
										       PBInputLIN.ATTRIBUTE_VALUE "AttributeValue",
										       PBInputLIN.ATTRIBUTE_TYPE "AttributeType",
										       PBInputLIN.CONTEXT_NAME "ContextName",
										       PBInputLIN.ATTRIBUTE_NAME "AttributeName",
										       PBInputLIN.ATTRIBUTE_VALUE_NAME "AttributeValueName",
										       PBInputLIN.ATTRIBUTE_TYPE_VALUE "AttributeTypeValue",
										       QP_Price_Book_Util.value_to_meaning(''='',''COMPARISON_OPERATOR_FWK'') "OperatorCodeName")
										)
									)
									FROM QP_PB_INPUT_LINES_V PBInputLIN
									WHERE PBInputLIN.Pb_Input_Header_Id = PBInputHDR.Pb_Input_Header_Id
								)
							)
						)
					)
					FROM QP_PB_INPUT_HEADERS_V PBInputHDR
					WHERE PBInputHDR.Pb_Input_Header_Id = PBHDR.Pb_Input_Header_Id
				)
			),
		XMLElement(
			"PriceBookLinesVO",
			(SELECT XMLAgg(
				XMLElement(
					"PriceBookLinesVORow",
					XMLForest(PBLin.PRICE_BOOK_LINE_ID "PriceBookLineId",
					       PBLin.PRICE_BOOK_HEADER_ID "PriceBookHeaderId",
					       PBLin.ITEM_NUMBER "ItemNumber",
					       PBLin.PRODUCT_UOM_CODE "ProductUomCode",
					       PBLin.LIST_PRICE "ListPrice",
					       PBLin.NET_PRICE "NetPrice",
					       PBLin.SYNC_ACTION_CODE "SyncActionCode",
					       PBLin.LINE_STATUS_CODE "LineStatusCode",
					       PBLin.DESCRIPTION "Description",
					       PBLin.CUSTOMER_ITEM_NUMBER "CustomerItemNumber",
					       PBLin.DISPLAY_ITEM_NUMBER "DisplayItemNumber",
					       PBLin.SYNC_ACTION "SyncAction",
					       nvl(PBLin.CUSTOMER_ITEM_NUMBER,PBLin.DISPLAY_ITEM_NUMBER) "UiItemNumber",
					       PBLin.CUSTOMER_ITEM_DESC "CustomerItemDesc",
					       to_char(PBLin.LIST_PRICE,FND_CURRENCY.GET_FORMAT_MASK(PBHDR.CURRENCY_CODE,60)) "ListPriceDisp",
					       to_char(PBLin.NET_PRICE,FND_CURRENCY.GET_FORMAT_MASK(PBHDR.CURRENCY_CODE,60)) "NetPriceDisp"),
					XMLElement(
						"PriceBookLineDetailsVO",
							(SELECT XMLAgg(
								XMLElement(
									"PriceBookLineDetailsVORow",
									XMLForest(PBLinDet.PRICE_BOOK_LINE_ID "PriceBookLineId",
									       PBLinDet.PRICE_BOOK_HEADER_ID "PriceBookHeaderId",
									       PBLinDet.LIST_PRICE "ListPrice",
									       PBLinDet.ADJUSTED_NET_PRICE "AdjustedNetPrice",
									       PBLinDet.PRICE_BOOK_LINE_DET_ID "PriceBookLineDetId",
									       PBLinDet.LIST_HEADER_ID "ListHeaderId",
									       PBLinDet.LIST_LINE_ID "ListLineId",
									       PBLinDet.LIST_LINE_NO "ListLineNo",
									       PBLinDet.MODIFIER_OPERAND "ModifierOperand",
									       PBLinDet.MODIFIER_APPLICATION_METHOD "ModifierApplicationMethod",
									       PBLinDet.ADJUSTMENT_AMOUNT "AdjustmentAmount",
									       PBLinDet.LIST_LINE_TYPE_CODE "ListLineTypeCode",
									       PBLinDet.PRICE_BREAK_TYPE_CODE "PriceBreakTypeCode",
									       PBLinDet.LIST_NAME "ListName",
									       PBLinDet.LIST_LINE_TYPE "ListLineType",
									       PBLinDet.PRICE_BREAK_TYPE "PriceBreakType",
									       DECODE((SELECT ''X''
									               from dual
										       where exists(SELECT ''X''
										                    from QP_PRICE_BOOK_ATTRIBUTES_V pba
												    where pba.PRICE_BOOK_LINE_DET_ID = PBLinDet.PRICE_BOOK_LINE_DET_ID
												      and pba.PRICE_BOOK_LINE_ID = PBLinDet.PRICE_BOOK_LINE_ID)),''X'',''PricingAttrEnabled'',''PricingAttrDisabled'') "PricingAttribute",
									       DECODE((SELECT ''X''
									               from dual
										       where exists(SELECT ''X''
										                    from QP_PRICE_BOOK_BREAK_LINES_V pbb
												    where pbb.PRICE_BOOK_LINE_DET_ID= PBLinDet.PRICE_BOOK_LINE_DET_ID
												      and pbb.PRICE_BOOK_LINE_ID = PBLinDet.PRICE_BOOK_LINE_ID)),''X'',''BreaksEnabled'',''BreaksDisabled'') "Breaks",
									      ''MessageCheck'' "Messages",
									      to_char(PBLinDet.LIST_PRICE,FND_CURRENCY.GET_FORMAT_MASK(PBHDR.CURRENCY_CODE,60)) "ListPriceDisp",
									      to_char(PBLinDet.ADJUSTED_NET_PRICE,FND_CURRENCY.GET_FORMAT_MASK(PBHDR.CURRENCY_CODE,60)) "AdjustedNetPriceDisp"),
									      DECODE(PBLinDet.LIST_LINE_TYPE_CODE,''PBH'',
														XMLElement(
															"PriceBookBreakLinesVO",
															(SELECT XMLAgg(
																XMLElement(
																	"PriceBookBreakLinesVORow",
																	XMLForest(pbk.PRICE_BOOK_LINE_DET_ID "PriceBookLineDetId",
																	       pbk.COMPARISON_OPERATOR_NAME "ComparisonOperatorName",
																	       pbk.ATTRIBUTE_NAME "AttributeName",
																	       pbk.PRICING_ATTR_VALUE_FROM "PricingAttrValueFrom",
																	       pbk.PRICING_ATTR_VALUE_TO "PricingAttrValueTo",
																		decode(LD.LIST_LINE_NO, null, fnd_message.get_string(''QP'',''QP_PRICE_BOOK_LISTPRICE''), fnd_message.get_string(''QP'',''QP_PRICE_BOOK_ADDITIONAL''))
																		||'' ''
																		||pbk.ATTRIBUTE_NAME
																		||'' ''
																		||decode(pbk.PRICING_ATTR_VALUE_TO,
																			999999999999999,fnd_message.get_string(''QP'',''QP_PRICE_BOOK_PBH_GREATER'')||'' ''||pbk.PRICING_ATTR_VALUE_FROM,
																			decode(pll.continuous_price_break_flag,
																				''Y'', fnd_message.get_string(''QP'',''QP_PRICE_BOOK_COMPARISON''),
																				pbk.COMPARISON_OPERATOR_NAME)||'' ''|| pbk.PRICING_ATTR_VALUE_FROM||'' ''
																				|| decode(pll.continuous_price_break_flag, ''Y'',
																				fnd_message.get_string(''QP'',''QP_PRICE_BOOK_MORE''),fnd_message.get_string(''QP'',''QP_PRICE_BOOK_AND''))||'' ''|| pbk.PRICING_ATTR_VALUE_TO
																			) "Description",
																	      LD.LIST_LINE_NO "ModifierNumber",
																	      pbk.OPERAND "Operand",
																	      pbk.APPLICATION_METHOD_NAME "ApplicationMethodName",
																	      pbk.RECURRING_VALUE "RecurringValue")
																	)
																)
																FROM QP_PRICE_BOOK_LINE_DETAILS_V LD, QP_PRICE_BOOK_BREAK_LINES_V pbk, qp_list_lines pll
																WHERE LD.PRICE_BOOK_LINE_DET_ID = pbk.PRICE_BOOK_LINE_DET_ID
																AND ld.list_line_id = pll.list_line_id
																AND LD.PRICE_BOOK_LINE_DET_ID = PBLinDet.PRICE_BOOK_LINE_DET_ID
															)
														)
														,
														NULL)
									)
								)
								FROM QP_PRICE_BOOK_LINE_DETAILS_V PBLinDet
								WHERE PBLinDet.Price_Book_Line_Id = PBLin.Price_Book_Line_Id
							)
						),
					DECODE((SELECT ''X''
						from dual
						where exists(SELECT ''X''
								from QP_PRICE_BOOK_MESSAGES_V pbm
								where pbm.Price_Book_Line_Id = PBLin.Price_Book_Line_Id )),
						''X'',
						XMLElement(
						"PriceBookMessagesVO",
							(SELECT XMLAgg(
								XMLElement(
									"PriceBookMessagesVORow",
									XMLForest(QPPBMSGS.MESSAGE_ID "MessageId",
										       QPPBMSGS.MESSAGE_TYPE "MessageType",
										       QPPBMSGS.MESSAGE_CODE "MessageCode",
										       QPPBMSGS.MESSAGE_TEXT "MessageText",
										       QPPBMSGS.PB_INPUT_HEADER_ID "PbInputHeaderId",
										       QPPBMSGS.PRICE_BOOK_HEADER_ID "PriceBookHeaderId",
										       QPPBMSGS.PRICE_BOOK_LINE_ID "PriceBookLineId")
									)
								)
								FROM QP_PRICE_BOOK_MESSAGES_V  QPPBMSGS
								WHERE QPPBMSGS.Price_Book_Line_Id = PBLin.Price_Book_Line_Id

							)
						)
						,NULL),
					XMLElement(
						"PriceBookLineCatsVO",
							(SELECT XMLAgg(
								XMLElement(
									"PriceBookLineCatsVORow",
									XMLForest(QPPBATTRS.price_book_line_id "PriceBookLineId",
										QPPBATTRS.attribute_value_name "CategoryName",
										QPPBATTRS.PRICING_PROD_ATTR_VALUE_FROM "CategoryId")
									)
								)
								FROM QP_PRICE_BOOK_ATTRIBUTES_V  QPPBATTRS
								WHERE QPPBATTRS.PRICE_BOOK_LINE_DET_ID = -1
								AND QPPBATTRS.ATTRIBUTE_TYPE = ''PRODUCT''
								AND QPPBATTRS.PRICING_PROD_CONTEXT = ''ITEM''
								AND QPPBATTRS.PRICING_PROD_ATTRIBUTE = ''PRICING_ATTRIBUTE2''
								AND QPPBATTRS.Price_Book_Line_Id = PBLin.Price_Book_Line_Id

							)
						)
					)
				)
				FROM QP_PRICE_BOOK_LINES_V PBLin
				WHERE PBLin.Price_Book_Header_Id = PBHDR.Price_Book_Header_Id
			)
		)
	) as "PriceBookHeadersVO"
FROM QP_PRICE_BOOK_HEADERS_V PBHDR
WHERE PRICE_BOOK_HEADER_ID = :PBHDRID');
-- Set the row header to be QP_PRICE_BOOK
DBMS_XMLQUERY.setRowSetTag(l_qryCtx, 'QP_PRICE_BOOK');
DBMS_XMLQUERY.setRowTag(l_qryCtx, NULL);

DBMS_XMLQUERY.setBindValue(l_qryCtx, 'PBHDRID', p_price_book_hdr_id);
--DBMS_XMLQUERY.setNullHandling(l_qryCtx, DBMS_XMLQUERY.DROP_NULLS);
-- Get the result
l_st_time := dbms_utility.get_time;
DBMS_XMLQUERY.SETENCODINGTAG(l_qryCtx,'UTF-8');
l_result := DBMS_XMLQUERY.getXML(l_qryCtx);


l_end_time := dbms_utility.get_time;
FND_FILE.PUT_LINE( FND_FILE.LOG, 'Time Taken for Creation of XML: '||((l_end_time-l_st_time)/100));

--delete from qp_xml_documents where PRICE_BOOK_HEADER_ID=p_price_book_hdr_id;
DELETE FROM QP_DOCUMENTS
WHERE DOCUMENT_ID = (SELECT DOCUMENT_ID
				FROM qp_price_book_headers_b
				WHERE PRICE_BOOK_HEADER_ID = p_price_book_hdr_id);

--INSERT INTO qp_xml_documents VALUES(p_price_book_hdr_id,result);
INSERT INTO QP_DOCUMENTS(
		DOCUMENT_ID,
		DOCUMENT_CONTENT,
		DOCUMENT_CONTENT_TYPE,
		DOCUMENT_NAME,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		XML_CONTENT
		)
		VALUES(
		qp_price_book_messages_s.nextval,
		EMPTY_BLOB(),
		p_document_content_type,
		p_document_name,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.conc_login_id,
		l_result
		) RETURNING DOCUMENT_ID INTO l_doc_id;

UPDATE qp_price_book_headers_b
SET document_id=l_doc_id
WHERE PRICE_BOOK_HEADER_ID = p_price_book_hdr_id;

--Close context
DBMS_XMLQUERY.closeContext(l_qryCtx);

x_return_status := FND_API.G_RET_STS_SUCCESS;

COMMIT;
EXCEPTION
WHEN OTHERS
THEN
 FND_FILE.PUT_LINE( FND_FILE.LOG, 'error message:' || SQLERRM );
 x_return_status := FND_API.G_RET_STS_ERROR;
 x_return_text := 'Error in XML Generation: '||SQLERRM;
END GENERATE_PRICE_BOOK_XML;
/** KDURGASI **/

END QP_PRICE_BOOK_UTIL;

/
